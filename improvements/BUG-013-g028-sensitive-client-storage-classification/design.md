# Bug Fix Design: BUG-013 G028 Sensitive Client Storage Classification

> Ownership note: this is the substantive discovery-phase design required for
> atomic packet creation. `bubbles.design` must reconcile and own the design
> before implementation dispatch; no design-specialist invocation occurred in
> this session.

## Root Cause Analysis

### Investigation Summary

The production scanner, its managed selftest, the G028 registry entry, Research
Lab's `rldata.js`/`rlapp.js` storage paths, and the project configuration
contract were inspected. The canonical scanner was then executed against both
Research Lab Feature 001 and a disposable five-case JavaScript fixture.

The fixture intentionally held storage behavior constant while varying the
semantic discriminator: indirect durable key, exact provider, unknown provider,
comment-only sensitive terms, and removal rather than persistence. The scanner
returned the predicted broken matrix. The managed selftest was also executed
with the normal shell environment and a stock macOS system `PATH`; both runs
failed before invoking the scanner because `timeout` was not found.

### Root Cause

Scan 2B is a collection of six regular expressions applied independently to
individual physical lines:

1. Five patterns look for a literal storage API and a sensitive substring on
   that same line.
2. A sixth pattern looks for a sensitive substring followed anywhere later on
   the same line by any storage identifier.
3. Only lines beginning with a comment marker are excluded. Inline comments
   remain part of the match input.
4. The scanner does not parse `setItem` versus `removeItem`, resolve string
   constants, follow aliases, inspect the persisted value, or classify a
   provider.
5. Scan 2B does not read project config, so it has no exact approval boundary.

This creates both error classes from one root cause: textual co-occurrence is
being treated as storage semantics. `localStorage.setItem(KEY_STORE, ...)`
contains no sensitive token on its call line and is missed. Conversely, a
market-cache write whose inline comment mentions an auth token and a cleanup
line with `authToken && localStorage.removeItem(...)` satisfy textual patterns
despite persisting no credential.

The portability defect is independent but shares the managed validation
surface. All three selftest runner functions call raw `timeout 180`. The
framework already ships `bubbles_run_with_timeout` in `guard-lib.sh`, but this
selftest neither sources nor uses it. On macOS, `gtimeout` may exist while the
command `timeout` does not, so direct selftest execution fails before any case
reaches the scanner. `framework-validate.sh`'s private PATH shim does not make
the managed selftest independently portable.

### Impact Analysis

- **Affected component:** G028 Scan 2B and its managed selftest.
- **False-negative impact:** durable credential persistence can pass when a
  storage key or helper hides the sensitive name from the call line.
- **False-positive impact:** safe cache and cleanup code blocks completion,
  encouraging suppressions or unsafe broad exceptions.
- **Policy impact:** the framework cannot express the one requested narrow
  session-only market-provider classification without weakening universal
  auth/payment protections.
- **Portability impact:** maintainers cannot run the focused selftest directly
  on a stock macOS command surface.
- **Downstream impact:** every consumer of installed G028 behavior is affected;
  no downstream file should be patched directly.

## Fix Design

### Decision Model

Scan 2B must produce one semantic event per storage operation:

| Field | Closed interpretation |
| --- | --- |
| `path` | normalized literal repo-relative source path |
| `line` | physical source line of the storage operation |
| `storage` | localStorage, sessionStorage, IndexedDB, AsyncStorage, SharedPreferences, equivalent-durable |
| `operation` | read, persist, remove, clear, scrubbed-rewrite |
| `key` | exact resolved literal or unresolved |
| `provider` | exact resolved literal, none, or unresolved |
| `credentialClass` | none, third-party-market-data, auth-session, payment, other-sensitive, unresolved |
| `configMatch` | exact, absent, invalid, or ambiguous |

The decision order is fixed:

1. Remove/clear and proven scrubbed rewrites are cleanup, not persistence.
2. A noncredential key/value is clear regardless of comment vocabulary.
3. A forbidden auth/session/payment class is blocking in every storage kind.
4. Credential-bearing durable storage is blocking and cannot consult an
   approval entry for permission.
5. Credential-bearing `sessionStorage` is allowed only after an exact valid
   tuple match with one resolved provider and all closed classification fields.
6. Every unresolved, unknown, malformed, duplicate, or ambiguous state blocks.

### Semantic Extraction

The implementation owner should replace the six regex loops with one bounded,
token-aware classifier. It may live inside the shell script or in one focused
internal helper under `bubbles/scripts/`; a new general policy engine is not
justified.

Required extraction capabilities:

- strip line/block comments without losing string literals or source line
  identity;
- recognize storage method calls and distinguish read/persist/remove/clear;
- resolve immutable string literals through bounded constant and alias chains;
- detect reassignment and mark the value unresolved rather than trusting the
  first assignment;
- track credential-shaped value variables/object fields over a bounded local
  function/block path;
- recognize a scrubbed rewrite only when every sensitive field in the persisted
  object is proven deleted before the write;
- resolve provider literals from an exact key encoding, an immutable provider
  constant, or a finite literal call site; a dynamic provider remains
  unresolved and blocking; and
- emit no credential values in diagnostics or temporary files.

The helper must parse source as data and never evaluate source text. If a
supported storage call is syntactically present but cannot be classified, it
must produce an unresolved classification violation rather than disappear.

### Exact Project Configuration

Add `scans.sensitiveClientStorage.approvedSessionCredentials` to
`project-config-contract.md`. Each list item has exactly seven required fields:
`path`, `storage`, `key`, `provider`, `credentialClass`, `privilege`, and
`lifetime`.

Validation rules:

- `path` is normalized, repo-relative, inside the target worktree, and contains
  no glob/regex/traversal syntax;
- `storage` is exactly `sessionStorage`;
- `key` and `provider` are nonempty literal values with no wildcard syntax;
- classification values are exactly `third-party-market-data`, `low`, and
  `same-tab`;
- unknown keys are rejected, duplicate tuples are rejected, and one config
  entry approves one provider only;
- missing config yields zero approvals;
- when the section is present, missing parser support or malformed YAML is a
  blocking config-integrity finding; and
- no tuple is considered until the forbidden secret-class check has passed.

The scanner must not auto-generate, mutate, or normalize project config. It is
read-only enforcement of operator-owned classification.

### Cleanup And Cache Protection

Whole-line comment skipping is insufficient. The classifier must remove inline
comments before token analysis, then use resolved key/value semantics.

Cleanup controls must cover:

- `storage.removeItem(exactKey)`;
- storage/object clear or delete operations;
- `delete object.apiKey` followed by persistence of that same object after all
  sensitive fields are removed; and
- equivalent multi-field scrub for known credential fields.

The classifier must not clear a line merely because a function is called
`cleanup`, `migrate`, or `scrub`. A read that extracts a durable credential or a
later write that repersists credential-bearing data remains blocking.

### Diagnostic Contract

Keep the existing `SENSITIVE_CLIENT_STORAGE` family for compatibility and add a
stable reason token to context, for example:

- `DURABLE_CREDENTIAL_STORAGE`
- `SESSION_CREDENTIAL_UNAPPROVED`
- `SESSION_PROVIDER_UNKNOWN`
- `FORBIDDEN_SECRET_CLASS`
- `SENSITIVE_STORAGE_CONFIG_INVALID`
- `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED`

Diagnostics identify path, line, storage, operation, key/provider status, and
config match, but redact credential values.

### Portable Selftest

`implementation-reality-scan-selftest.sh` should source `guard-lib.sh` and
replace all three raw `timeout 180` calls with
`bubbles_run_with_timeout 180`. Tests must distinguish timeout `124` from the
scanner's expected exits `0`, `1`, and `2`.

The selftest must include an environment with no `timeout` or `gtimeout` command
to exercise the watchdog fallback, not merely rely on `framework-validate.sh`'s
compatibility shim.

### Persistent Regression

Add `tests/regression/test_24_g028_sensitive_client_storage.sh` and register it
as a source-only check in `framework-validate.sh`. It must invoke the production
scanner against real disposable feature directories and exact project config,
not duplicate classifier logic.

The persistent adversarial pairs are:

1. literal credential key versus a two-hop constant alias;
2. exact approved provider versus unknown/dynamic provider;
3. approved `sessionStorage` versus the same tuple in `localStorage`;
4. comment-only sensitive words versus executable credential flow; and
5. credential-bearing object before scrub versus the same object after proven
   field deletion.

Each pair must fail if the corresponding semantic discriminator is removed.

### Alternative Approaches Considered

1. **Add more regexes for `KEY_STORE`.** Rejected because arbitrary constant
   names, aliases, comments, and operation kinds reproduce the same bug class.
2. **Allowlist Research Lab files.** Rejected because it would suppress real
   durable credential findings in those files and is not project-agnostic.
3. **Allow any market-looking API key in sessionStorage.** Rejected because
   provider identity and privilege would be caller-controlled guesses.
4. **Allow path/key regexes in project config.** Rejected because one broad
   expression could authorize unknown providers or auth secrets.
5. **Treat all cleanup-named functions as safe.** Rejected because names are
   not evidence that credential material was removed.
6. **Rely on framework-validate's timeout shim.** Rejected because the managed
   selftest is a public focused validation surface and must run independently.

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Bounded token/data-flow classifier | Expand line regexes | Cannot resolve constants or distinguish persistence, cleanup, and comments |
| Seven-field exact config tuple | File/key allowlist | Cannot prove provider, privilege, lifetime, or storage kind |
| Unknown classification blocks | Ignore unresolved constructs | Recreates the durable credential false negative |
| Persistent adversarial regression | Selftest-only cases | A managed selftest registration or behavior regression could otherwise disappear |

## Security And Privacy

The classifier must never log credential values. Temporary analysis data stays
inside a guard-owned directory with cleanup on success and failure. Source is
parsed, never executed. Config cannot downgrade universal forbidden classes,
and durable storage has no approval branch.

## macOS And Linux Portability

- Shell remains compatible with macOS Bash 3.2.
- Use `bubbles_run_with_timeout`; preserve exit `124`.
- Do not add raw `timeout`, GNU `sed -i`, `grep -P`, `readlink -f`, `mapfile`,
  or associative arrays.
- Use stable `LC_ALL=C` ordering for committed/generated output.
- Optional parser modules must not turn a configured approval section into a
  silent skip.

## Rollout And Rollback

Canonical source is fixed and validated first. Release ownership regenerates
derived registries and the release manifest last, then runs `release-check`.
Consumers receive the change only through the supported upgrade mechanism and
verify installed provenance and managed-byte integrity.

Rollback reinstalls the prior validated release through the same mechanism. It
does not edit consumer source or preserve a permissive project exception. A
rollback honestly restores the Scan 2B defect and therefore cannot be described
as a security-equivalent state.

## Open Questions

None in the requested policy boundary. `bubbles.design` still owns formal
reconciliation of this discovery-phase design before implementation begins.
