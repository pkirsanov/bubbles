# Expected Behavior: BUG-013 G028 Sensitive Client Storage Classification

## Problem Contract

G028 must block real credential persistence without converting harmless browser
caches, inline comments, or credential-removal code into security findings. The
only configurable exception is a narrow, explicit classification for exact
same-tab `sessionStorage` use of low-privilege third-party market-data provider
credentials. Absence or ambiguity is blocking.

## Actors

- A downstream project that uses browser storage for noncredential market data.
- A downstream project that needs one same-tab market-provider API credential.
- A security reviewer relying on G028 to reject durable or high-trust secrets.
- The canonical Bubbles scanner and its project-owned configuration boundary.

## Terminology

- **Credential-bearing operation:** a storage read or persistence operation
  whose key, value, object field, or bounded data-flow source is credential
  material.
- **Durable storage:** `localStorage`, IndexedDB, AsyncStorage,
  SharedPreferences, or an equivalent store that survives the current tab.
- **Approved session credential:** an exact config tuple classifying one source
  path, one `sessionStorage` key, and one provider as
  `third-party-market-data`, `low`, and `same-tab`.
- **Cleanup operation:** `removeItem`, delete, clear, or a rewrite for which the
  scanner proves the sensitive fields were removed before persistence.

## Requirements

### BR-001 Semantic Storage Detection

Scan 2B must classify storage kind, operation kind, resolved key, provider, and
credential taint. A physical-line regex match is not sufficient evidence.

### BR-002 Constant And Indirection Resolution

The scanner must resolve bounded immutable string constants and alias chains
used as storage keys. A credential write through `KEY_STORE` must receive the
same result as the equivalent string-literal write. Unresolved suspicious keys
or providers fail closed.

### BR-003 Durable Credential Storage Is Always Blocked

Credential-bearing access to `localStorage`, IndexedDB, AsyncStorage,
SharedPreferences, or another durable client store is blocking. Project config
must not authorize durable credential storage.

### BR-004 Session Storage Is Default-Deny

Credential-bearing `sessionStorage` access is blocking unless an exact project
configuration entry matches all of:

- normalized repo-relative source path;
- literal or resolved storage key;
- literal or otherwise statically resolved provider;
- `storage: sessionStorage`;
- `credentialClass: third-party-market-data`;
- `privilege: low`; and
- `lifetime: same-tab`.

No field may be inferred from a filename, comment, provider display name, or
runtime input.

### BR-005 Closed Exact-Match Configuration

The project-owned schema is:

```yaml
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: path/to/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
```

Entries are literal exact matches. Absolute paths, `..`, symlink escape,
globs, regexes, empty values, duplicate tuples, unknown fields, unknown enum
values, provider wildcards, and key wildcards are invalid and block configured
session credential use. A dynamic provider that cannot be reduced to one exact
configured provider remains blocked.

### BR-006 Unknown Provider Fails Closed

Changing only the provider from an approved literal to an unknown literal or a
runtime-derived value must change the result from allowed to blocking. A broad
path/key match must not authorize an unlisted provider.

### BR-007 High-Trust Secret Classes Cannot Be Approved

Auth tokens, login/session identifiers or secrets, JWTs, bearer tokens, refresh
tokens, cookies, passwords, client secrets, payment/card data, CVV/CVC, SSNs,
and equivalent trust material are blocking in every client storage kind. An
otherwise exact config entry cannot override this rule. The narrow market-data
classification may cover only a provider API credential whose configured class
and privilege are the closed values above.

### BR-008 Cleanup Is Not Persistence

`removeItem`, clear/delete operations, and rewrites proven to persist only an
object after all credential fields are deleted must not be reported as
credential persistence. A function name such as `cleanup` or `migrate` is not
proof; operation and bounded data flow control the result.

### BR-009 Noncredential Cache And Comment Protection

Inline and block comments must not contribute credential taint. A resolved
noncredential market-cache key and untainted market-data value must remain
clear even when nearby comments mention auth, session, payment, or secrets.

### BR-010 Config Parsing Fails Closed

No configuration means no session credential approvals. If the
`sensitiveClientStorage` section is present but malformed, unparseable, or
cannot be evaluated because its required parser is unavailable, the scanner
must emit a configuration-integrity violation rather than ignore the section.

### BR-011 Stable Diagnostics

Every Scan 2B finding must identify a stable reason class, source path, source
line, storage kind, operation, resolved or unresolved key, provider status, and
config-match status without printing a credential value. At minimum, distinct
diagnostics must exist for durable credential storage, unapproved session
credential, unknown provider, forbidden secret class, invalid config, and
unresolved classification.

### BR-012 Portable Managed Selftest

The selftest must source `guard-lib.sh` and use `bubbles_run_with_timeout` (or a
contract-equivalent shipped helper), preserve timeout exit `124`, and run when
only macOS system tools are available. Raw GNU `timeout` is not permitted in the
managed selftest.

### BR-013 Canonical-Only Delivery

The repair lands in canonical Bubbles source and reaches consumers only through
the supported release/install/upgrade path. No downstream managed copy may be
edited or manually synchronized.

## Acceptance Scenarios

```gherkin
Feature: Fail-closed sensitive client storage classification

  Scenario: Indirected durable credential storage is blocked
    Given a credential storage key is declared as an immutable string constant
    And localStorage persists a credential through that constant
    When G028 Scan 2B analyzes the implementation
    Then it reports durable credential storage at the persistence operation
    And the result is identical to the equivalent literal-key write

  Scenario: One exact market provider is allowed only in configured session storage
    Given project config approves one exact path, sessionStorage key, and provider
    And the classification is third-party-market-data, low privilege, and same-tab
    When the matching source writes that provider credential to sessionStorage
    Then Scan 2B does not report a violation for that operation
    But the same operation with an unknown provider is blocking
    And the same tuple written to localStorage is blocking

  Scenario: High-trust secrets cannot use the session exception
    Given project config contains an otherwise matching session credential tuple
    When source persists auth, login-session, bearer, refresh, or payment material
    Then Scan 2B reports a forbidden secret-class violation

  Scenario: Cache comments and cleanup do not masquerade as persistence
    Given a noncredential market cache write has an inline comment naming auth tokens
    And cleanup removes a legacy credential or deletes its fields before a scrubbed rewrite
    When Scan 2B analyzes both operations
    Then neither operation is reported as credential persistence
    But a neighboring real credential write remains blocking

  Scenario: Classification uncertainty fails closed
    Given a session credential provider is dynamic, unknown, or ambiguously configured
    When Scan 2B cannot prove one exact approved tuple
    Then it reports an unresolved or unapproved classification violation

  Scenario: The managed selftest runs on macOS without GNU timeout
    Given PATH has no command named timeout
    And the shipped portable timeout helper is available
    When the implementation-reality scanner selftest runs
    Then every scanner fixture executes
    And a timed-out fixture would return exit 124
```

## Non-Goals

- Permitting credential-bearing `localStorage` or other durable storage.
- Authorizing OAuth, auth, login-session, bearer, refresh, payment, or card
  secrets in `sessionStorage`.
- Supporting config regexes, path globs, provider wildcards, or bypass flags.
- Performing whole-program JavaScript type inference.
- Editing Research Lab as part of the canonical scanner repair.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
