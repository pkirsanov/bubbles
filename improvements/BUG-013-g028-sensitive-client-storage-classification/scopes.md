# Scopes: BUG-013 G028 Sensitive Client Storage Classification

Related artifacts: [spec.md](spec.md), [design.md](design.md), [report.md](report.md), [uservalidation.md](uservalidation.md)

## Execution Outline

### Purpose

Replace Scan 2B textual co-occurrence with fail-closed storage semantics, add
the narrow exact session credential project hook, protect cache/cleanup code,
and make the managed scanner selftest portable without weakening any durable or
high-trust secret prohibition.

### Phase Order

1. **Scope 1 - Semantic Scan 2B And Exact Session Classification:** implement
   the classifier and config contract, prove the adversarial matrix, update
   direct G028 consumers, and validate canonical release readiness.

This is one vertical policy scope. Landing a permissive config hook before
constant/operation semantics, or portability without security regressions,
would create an unsafe intermediate contract.

### New Types and Signatures

- `StorageEvent(path, line, storage, operation, key, provider, credentialClass, configMatch)` is the bounded semantic classification record used by Scan 2B.
- `scans.sensitiveClientStorage.approvedSessionCredentials[]` is an exact seven-field tuple: `path`, `storage`, `key`, `provider`, `credentialClass`, `privilege`, and `lifetime`.
- Stable Scan 2B reasons are `DURABLE_CREDENTIAL_STORAGE`, `SESSION_CREDENTIAL_UNAPPROVED`, `SESSION_PROVIDER_UNKNOWN`, `FORBIDDEN_SECRET_CLASS`, `SENSITIVE_STORAGE_CONFIG_INVALID`, and `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED`.
- The existing `SENSITIVE_CLIENT_STORAGE` diagnostic family and scanner exit contract remain unchanged; no route, API, generated client, or persistence schema is introduced.

### Validation Checkpoints

- **Scenario checkpoint:** `tests/regression/test_24_g028_sensitive_client_storage.sh` exercises every acceptance scenario through the production scanner with exact assertion labels listed in the Test Plan.
- **Shared-gate checkpoint:** `bubbles/scripts/implementation-reality-scan-selftest.sh` protects unrelated scanner families plus the semantic storage/config/portable-timeout matrix.
- **Regression-integrity checkpoint:** `regression-quality-guard.sh --bugfix` proves the persistent regression retains adversarial signal and no silent-pass bailout.
- **Framework checkpoint:** full framework validation runs only after the focused production regression and managed selftest are green.
- **Release checkpoint:** `release-check` proves generated registries, manifest bytes, and installer provenance are current.
- **Planning checkpoint:** artifact lint, freshness, and traceability must pass before execution status is refreshed.

## Scope Inventory

| # | Scope | Depends On | Primary surfaces | Status |
| --- | --- | --- | --- | --- |
| 1 | Semantic Scan 2B And Exact Session Classification | - | scanner, managed selftest, persistent regression, project config contract, G028 registry/docs | In Progress |

## Scope 1: Semantic Scan 2B And Exact Session Classification

**Status:** In Progress
**Depends On:** -
**Scope-Kind:** runtime-behavior

### Outcome

G028 blocks credential-bearing durable storage through literals, constants, and
bounded indirection; permits only an exact configured low-privilege market
provider tuple in `sessionStorage`; blocks unknown providers and high-trust
secrets; does not flag comments, noncredential cache writes, or proven cleanup;
and has a focused selftest that runs without GNU `timeout`.

### Gherkin Scenarios

#### SCN-BUG-013-001: Indirected durable credential storage is blocked

```gherkin
Scenario Outline: Indirected durable credential storage is blocked
  Given a credential storage key is expressed as <key-form>
  And localStorage persists a provider credential through that key
  When the production G028 scanner analyzes the file
  Then it exits 1
  And it reports DURABLE_CREDENTIAL_STORAGE at the persistence operation
  And the blocking result matches the equivalent literal-key write
  And no credential value appears in output

Examples:
  | key-form |
  | a string literal |
  | one immutable constant |
  | a two-hop immutable alias chain |
  | a bounded immutable helper |
  | an unresolved runtime-derived helper |
```

#### SCN-BUG-013-002: One exact market provider is allowed only in configured session storage

```gherkin
Scenario Outline: One exact market provider is allowed only in configured session storage
  Given project config contains one valid approvedSessionCredentials entry
  And source path, storage key, and provider resolve to <match-state>
  And the storage kind is <storage-kind>
  When the production G028 scanner analyzes the operation
  Then the result is <result>

Examples:
  | match-state | storage-kind | result |
  | exact       | sessionStorage | clear |
  | unknown provider | sessionStorage | SESSION_PROVIDER_UNKNOWN violation |
  | dynamic provider | sessionStorage | SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED violation |
  | exact       | localStorage | DURABLE_CREDENTIAL_STORAGE violation |
```

#### SCN-BUG-013-003: High-trust secrets cannot use the session exception

```gherkin
Scenario Outline: High-trust secrets cannot use the session exception
  Given an otherwise exact configured session tuple
  And the persisted material is <secret-class>
  When the production G028 scanner analyzes the operation
  Then it exits 1 with FORBIDDEN_SECRET_CLASS

Examples:
  | secret-class |
  | authentication bearer token |
  | login-session secret |
  | refresh token |
  | payment card data |
  | CVV or CVC |
```

#### SCN-BUG-013-004: Cache comments and cleanup do not masquerade as persistence

```gherkin
Scenario Outline: Cache comments and cleanup do not masquerade as persistence
  Given source contains <safe-case>
  And a neighboring real credential persistence operation remains in the fixture
  When the production G028 scanner analyzes the file
  Then <safe-case> has no Scan 2B violation
  And the neighboring credential operation is still reported

Examples:
  | safe-case |
  | a market-cache write with auth and payment words only in an inline comment |
  | removeItem of a legacy credential key |
  | delete of all credential fields followed by persistence of the scrubbed object |
```

#### SCN-BUG-013-005: Classification uncertainty fails closed

```gherkin
Scenario Outline: Classification uncertainty fails closed
  Given session credential classification contains <uncertain-state>
  When Scan 2B cannot prove one exact approved tuple
  Then the scanner exits 1 with <reason>

Examples:
  | uncertain-state | reason |
  | an unknown literal provider | SESSION_PROVIDER_UNKNOWN |
  | a runtime-derived provider | SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED |
  | an absolute, traversing, or non-normalized path | SENSITIVE_STORAGE_CONFIG_INVALID |
  | a path, key, or provider wildcard | SENSITIVE_STORAGE_CONFIG_INVALID |
  | a duplicate or ambiguous tuple | SENSITIVE_STORAGE_CONFIG_INVALID |
  | an unknown field or enum value | SENSITIVE_STORAGE_CONFIG_INVALID |
  | malformed YAML or an unavailable parser | SENSITIVE_STORAGE_CONFIG_INVALID |
```

#### SCN-BUG-013-006: The managed selftest runs on macOS without GNU timeout

```gherkin
Scenario: The managed selftest runs on macOS without GNU timeout
  Given PATH has no command named timeout or gtimeout
  And guard-lib.sh is available
  When implementation-reality-scan-selftest.sh executes its fixture matrix
  Then every production scanner invocation executes through the portable helper
  And the selftest passes
  And a helper timeout is classified as exit 124 rather than a scanner verdict
```

### UI Scenario Matrix

None found - G028 is a non-interactive source scanner. The user-visible surface
is deterministic terminal diagnostics and numeric exit status.

### Implementation Plan

1. Add failing hermetic cases for all six scenarios before changing Scan 2B.
2. Replace the six line-local regex loops with one bounded token-aware storage
   event classifier that preserves source line identity and never evaluates
   source code.
3. Resolve immutable key/provider literals through bounded aliases, detect
   reassignments, classify operation kind, and fail closed on unresolved
   credential-shaped operations.
4. Add the exact seven-field project configuration parser and validation model;
   apply it only after durable-storage and forbidden-secret checks.
5. Strip inline comments from semantic input and recognize only proven
   remove/clear/scrubbed-rewrite cleanup paths.
6. Emit stable reason tokens and redacted context while retaining the existing
   `SENSITIVE_CLIENT_STORAGE` family.
7. Source `guard-lib.sh` in the managed selftest, replace raw timeout calls, and
   add a no-timeout/no-gtimeout fallback case that checks exit `124` semantics.
8. Add and register the persistent adversarial regression, then run its
   regression-quality guard in bugfix mode.
9. Reconcile the project configuration contract and G028 registry/operator text
   with executable behavior; regenerate derived registries and release manifest
   only through canonical generators.
10. Run focused, portability, framework, agnosticity, release, artifact, and
    boundary checks; propagate only through the supported upgrade path.

### Consumer Impact Sweep

The implementation and test owners must inspect and reconcile:

- `state-transition-guard.sh` Check 15 invocation and output consumption;
- `cli.sh scan` and every direct scanner caller;
- `framework-validate.sh` selftest and persistent-regression registration;
- G028 in `bubbles/registry/gates.yaml` and generated `bubbles/workflows.yaml`;
- `critical-requirements.md` Scan 2B policy text;
- `project-config-contract.md` and project setup examples/schema consumers;
- `generate-release-manifest.sh`, source-only regression inventory, and
  installer-managed scanner/selftest checksums;
- docs/CHEATSHEET and other generated/direct G028 descriptions; and
- downstream installations reached by the standard upgrade mechanism.

No consumer may infer that a session approval authorizes durable storage or a
forbidden secret class.

### Shared Infrastructure Impact Sweep

`implementation-reality-scan.sh` is an installer-managed, high-fan-out gate.
Independent canaries required before broad validation are:

- existing Scan 1/1B/1C/1D/2/3/4/5/6/7/8 selftest behavior;
- literal and alias-chain durable credential positives;
- exact-provider versus unknown-provider session pair;
- session versus local storage pair;
- cache/comment versus credential-flow pair;
- before-scrub versus after-scrub pair;
- absent config, valid config, malformed config, and parser-unavailable cases;
- no-`timeout` and no-`gtimeout` watchdog fallback; and
- source scanner exit classes `0`, `1`, `2`, plus helper timeout `124`.

Rollback is prior validated release installation through the supported
mechanism. No cache, config, state, or downstream source mutation is part of the
scanner itself.

### Change Boundary

Allowed file families are exactly those listed in [bug.md](bug.md#change-boundary).
Any new parser/helper, config surface, generated output, or documentation path
outside that list requires planning-owner reconciliation before modification.

### Test Plan

| Test Type | Test ID | Scenario | Category | File / Location | Exact current assertion titles / behavior | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| regression E2E | T-BUG-013-01 | SCN-BUG-013-001 - Indirected durable credential storage is blocked | e2e-api | `tests/regression/test_24_g028_sensitive_client_storage.sh` | literal, two-hop alias, helper-indirected, dynamic key, IndexedDB object-store, and SharedPreferences durable credential assertions | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | Yes |
| regression E2E | T-BUG-013-02 | SCN-BUG-013-002 - One exact market provider is allowed only in configured session storage | e2e-api | `tests/regression/test_24_g028_sensitive_client_storage.sh` | exact configured session tuple and immutable provider object pass; unknown, dynamic, and localStorage variants block | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | Yes |
| regression E2E | T-BUG-013-03 | SCN-BUG-013-003 - High-trust secrets cannot use the session exception | e2e-api | `tests/regression/test_24_g028_sensitive_client_storage.sh` | bearer, login-session, refresh, payment, CVV/CVC, partial-scrub, and AsyncStorage high-trust assertions | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | Yes |
| regression E2E | T-BUG-013-04 | SCN-BUG-013-004 - Cache comments and cleanup do not masquerade as persistence | e2e-api | `tests/regression/test_24_g028_sensitive_client_storage.sh` | comment/cache, removeItem, before-scrub, proven scrub, conditional scrub, separate-helper, complete loaded scrub, and partial loaded scrub assertions | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | Yes |
| regression E2E | T-BUG-013-05 | SCN-BUG-013-005 - Classification uncertainty fails closed | e2e-api | `tests/regression/test_24_g028_sensitive_client_storage.sh` | unknown/dynamic provider plus invalid path, wildcard, duplicate, ambiguous, unknown-field/enum, malformed, parser-unavailable, absent, and empty-config assertions | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | Yes |
| regression E2E | T-BUG-013-06 | SCN-BUG-013-006 - The managed selftest runs on macOS without GNU timeout | e2e-api | `tests/regression/test_24_g028_sensitive_client_storage.sh` | `managed selftest runs with the system-only PATH`; `managed selftest preserves watchdog exit 124` | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | Yes |
| managed selftest | T-BUG-013-07 | SCN-BUG-013-001, SCN-BUG-013-002, SCN-BUG-013-003, SCN-BUG-013-004, SCN-BUG-013-005, SCN-BUG-013-006 | functional | `bubbles/scripts/implementation-reality-scan-selftest.sh` | `Literal and alias-resolved durable credentials are blocked`; `High-trust session material cannot use approval`; `Proven scrubbed rewrite remains clear`; invalid-config matrix; `Portable watchdog preserves exit 124` | `bash bubbles/scripts/implementation-reality-scan-selftest.sh` | No |
| regression integrity | T-BUG-013-08 | SCN-BUG-013-001, SCN-BUG-013-002, SCN-BUG-013-003, SCN-BUG-013-004, SCN-BUG-013-005, SCN-BUG-013-006 | functional | `bubbles/scripts/regression-quality-guard.sh` | persistent BUG-013 regression has adversarial signal and no bailout | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_24_g028_sensitive_client_storage.sh` | No |
| framework integration | T-BUG-013-09 | SCN-BUG-013-001, SCN-BUG-013-002, SCN-BUG-013-003, SCN-BUG-013-004, SCN-BUG-013-005, SCN-BUG-013-006 | integration | `bubbles/scripts/cli.sh` | `framework-validate` preserves every scanner family, registry consumer, and portability shim | `bash bubbles/scripts/cli.sh framework-validate` | Yes |
| release integration | T-BUG-013-10 | SCN-BUG-013-001, SCN-BUG-013-002, SCN-BUG-013-003, SCN-BUG-013-004, SCN-BUG-013-005, SCN-BUG-013-006 | integration | `bubbles/scripts/cli.sh` | `release-check` proves canonical generated surfaces, manifest freshness, and install provenance | `bash bubbles/scripts/cli.sh release-check` | Yes |

`Live System: Yes` means the real executable governance scanner/framework is
invoked as a subprocess against disposable repositories. No HTTP or browser
runtime applies.

### Impact-Aware Validation

The canonical Bubbles source repository has no downstream `testImpact` or wired
runtime `traceContracts` workflow applicable to this local governance scanner.
Validation therefore runs in this order: focused production regression,
managed selftest, regression-integrity guard, full framework validation,
release readiness, then packet artifact lint, freshness, and traceability. No
external telemetry workflow is inferred.

### Stress Coverage Classification

Stress coverage is not applicable to this scope. BUG-013 defines no latency,
throughput, response-time, capacity, or service-level target; it changes a
bounded source-classification gate executed against disposable repositories.
The production-scanner E2E matrix and full framework/release integration rows
cover behavioral and fan-out risk without inventing a load or stress contract.

### Definition of Done - Tiered Validation

Core behavior:

- [x] Root cause is confirmed by pre-fix production-scanner evidence for the indirect miss, session non-differentiation, cache/comment false positive, cleanup false positive, and raw-timeout portability failure. Evidence: [pre-fix semantic matrix and timeout reproduction](report.md#bug-reproduction---before-fix-hermetic-semantic-matrix)
- [x] `SCN-BUG-013-001` - **Indirected durable credential storage is blocked:** literal, constant, helper, dynamic, alias-chain, and durable-handle operations block with stable redacted diagnostics. Evidence: [implementation semantic regression](report.md#implementation-semantic-regression-evidence)
- [x] `SCN-BUG-013-002` - **One exact market provider is allowed only in configured session storage:** the exact valid session tuple passes while unknown/dynamic providers and the identical localStorage tuple fail closed. Evidence: [implementation semantic regression](report.md#implementation-semantic-regression-evidence)
- [x] `SCN-BUG-013-003` - **High-trust secrets cannot use the session exception:** bearer, login-session, refresh, payment-card, and CVV/CVC material returns `FORBIDDEN_SECRET_CLASS` regardless of an otherwise matching config tuple. Evidence: [implementation semantic regression](report.md#implementation-semantic-regression-evidence)
- [x] `SCN-BUG-013-004` - **Cache comments and cleanup do not masquerade as persistence:** comments, noncredential cache, remove/clear, and proven scrubbed rewrites stay clear while neighboring real persistence remains blocking. Evidence: [implementation semantic regression](report.md#implementation-semantic-regression-evidence)
- [x] `SCN-BUG-013-005` - **Classification uncertainty fails closed:** unknown/dynamic providers and malformed, wildcard, duplicate, ambiguous, absent/default-deny, or unevaluable config cannot create an approval. Evidence: [config and portability regression](report.md#implementation-config-and-portability-evidence)
- [x] `SCN-BUG-013-006` - **The managed selftest runs on macOS without GNU timeout:** the managed selftest runs on the system-only macOS path and preserves helper timeout exit `124`. Evidence: [config and portability regression](report.md#implementation-config-and-portability-evidence)
- [x] Exact path/key/provider diagnostics never print credential values. Evidence: [implementation semantic regression](report.md#implementation-semantic-regression-evidence)
- [x] Consumer and shared-infrastructure impact sweeps are complete, rollback
  remains supported, and no excluded surface changes. Evidence: [framework and release validation](report.md#framework-and-release-evidence)
- [x] Direct docs/registry config semantics match executable behavior and all
  generated files are produced only by canonical tooling. Evidence: [framework and release validation](report.md#framework-and-release-evidence)

Test evidence, one item per Test Plan row:

- [x] `T-BUG-013-01` passes with current-session production-scanner evidence for literal and indirect durable credential assertions. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session 57-case production regression](report.md#current-session-production-regression---t-bug-013-01-through-t-bug-013-06).
- [x] `T-BUG-013-02` passes with current-session production-scanner evidence for exact, unknown, dynamic, and durable provider/storage variants. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session 57-case production regression](report.md#current-session-production-regression---t-bug-013-01-through-t-bug-013-06).
- [x] `T-BUG-013-03` passes with current-session production-scanner evidence for all five forbidden trust-material assertions. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session 57-case production regression](report.md#current-session-production-regression---t-bug-013-01-through-t-bug-013-06).
- [x] `T-BUG-013-04` passes with current-session production-scanner evidence for comment, cache, cleanup, scrubbed, and neighboring-positive assertions. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session 57-case production regression](report.md#current-session-production-regression---t-bug-013-01-through-t-bug-013-06).
- [x] `T-BUG-013-05` passes with current-session production-scanner evidence for invalid, absent, empty, ambiguous, and parser-unavailable config assertions. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session 57-case production regression](report.md#current-session-production-regression---t-bug-013-01-through-t-bug-013-06).
- [x] `T-BUG-013-06` passes with current-session system-only-path and timeout-124 assertions. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session 57-case production regression](report.md#current-session-production-regression---t-bug-013-01-through-t-bug-013-06).
- [x] `T-BUG-013-07` passes with current-session managed-selftest output covering the focused semantic/config/portability matrix and unrelated scanner canaries. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session managed selftest](report.md#current-session-managed-selftest---t-bug-013-07).
- [x] `T-BUG-013-08` passes with current-session regression-integrity output proving adversarial signal and no silent-pass bailout. **Phase:** implement. **Claim Source:** executed. Evidence: [current-session regression integrity](report.md#current-session-regression-integrity---t-bug-013-08).
- [ ] `T-BUG-013-09` passes with current-session full framework-validation output.
  > **Uncertainty Declaration**
  > **What was attempted:** All focused BUG-013 commands and scoped quality gates passed, followed by repeated shared-slot process checks.
  > **What was observed:** Existing PIDs `27929`/`28213` are still running `framework-validate`; PIDs `37973`/`38134`/`38163` are still running `release-check` and its nested framework validation.
  > **Why this is uncertain:** A new full command was not started because overlapping broad validators make timing and install-provenance ownership ambiguous.
  > **What would resolve this:** After the active owner settles the shared slot and IMP-020 managed inputs, execute one serial `bash bubbles/scripts/cli.sh framework-validate` against the resulting canonical tree.
- [ ] `T-BUG-013-10` passes with current-session release-manifest freshness and release-readiness output.
  > **Uncertainty Declaration**
  > **What was attempted:** `bash bubbles/scripts/generate-release-manifest.sh --check` executed after the focused suite.
  > **What was observed:** The check exited `1`; `state-transition-guard.sh` now matches at `1f80ab...`, while foreign IMP-020 `adversarial-resolve.sh` is `33b657...` and the manifest records `e4cfad...`.
  > **Why this is uncertain:** The required release command was not started under the active overlapping release process, and regeneration is unsafe while the foreign managed input is unsettled.
  > **What would resolve this:** The IMP-020 owner settles its canonical source and generated metadata, then one serial `bash bubbles/scripts/cli.sh release-check` executes after framework validation.

Independent-test handoff requirements (planning-owned contracts; existing
checked implementation and test evidence above remains unchanged):

- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior pass: `bubbles.test` independently executes `T-BUG-013-01` through `T-BUG-013-06` against the production scanner and records each exact scenario assertion set with zero skips, bailouts, or intercepted production behavior.
  > **Uncertainty Declaration**
  > **What was attempted:** The preceding implementation owner executed the focused production regression and reported 57 passing assertions.
  > **What was observed:** The six scenario rows and their concrete production test path remain mapped in this plan and `scenario-manifest.json`.
  > **Why this is uncertain:** This planning invocation does not own or infer a fresh independent-test verdict after the planning contract repair.
  > **What would resolve this:** `bubbles.test` executes `T-BUG-013-01` through `T-BUG-013-06` on the current tree and records owner-tagged evidence without changing checked historical evidence.
- [ ] Broader E2E regression suite passes: after the focused rows pass, `bubbles.test` executes `T-BUG-013-09` and `T-BUG-013-10` serially and records complete current-tree framework-validation and release-check results; focused evidence is not reused as the broader-suite verdict.
  > **Uncertainty Declaration**
  > **What was attempted:** Prior specialist runs exercised broad validation, but the latest implementation handoff did not start these rows while a foreign validator occupied the shared path.
  > **What was observed:** Both broader rows remain explicit, live-system integration entries in the Markdown and JSON Test Plans.
  > **Why this is uncertain:** No current independent owner has executed the serial pair after this planning reconciliation.
  > **What would resolve this:** `bubbles.test` executes `T-BUG-013-09` followed by `T-BUG-013-10` on one settled current-tree snapshot and records both exits and full verdicts.
- [ ] Change Boundary is respected and zero excluded file families were changed: `bubbles.test` verifies that BUG-013-attributed delivery changes stay within the allowed families in `bug.md`, no Research Lab or downstream managed copy is changed for this bug, and unrelated BUG-012, IMP-020, release, and foreign dirty work remains preserved and unclaimed.
  > **Uncertainty Declaration**
  > **What was attempted:** The implementation handoff captured scoped source identities and a clean scoped whitespace check.
  > **What was observed:** This planning repair changes only planning-owned BUG-013 packet metadata and contracts.
  > **Why this is uncertain:** Independent attribution and excluded-surface verification belong to the test owner and are not inferred from planning edits.
  > **What would resolve this:** `bubbles.test` records a current-tree boundary audit covering every allowed and excluded family before routing to validation.

Build quality gate:

- [ ] Artifact lint/freshness/traceability, shell syntax/portability,
  agnosticity, release-manifest freshness, install provenance, focused tests,
  full framework validation, and release readiness pass with current-session
  evidence; finding accounting is one-to-one; no specialist phase,
  certification, release, propagation, or downstream upgrade is inferred.
  > **Uncertainty Declaration**
  > **What was attempted:** Focused regression, managed selftest, regression quality, syntax, portability, artifact lint, freshness, traceability, agnosticity, identity, and manifest checks all executed.
  > **What was observed:** Every scoped command passed except manifest freshness; current broad framework/release commands remain unstarted because another owner still occupies both validation paths.
  > **Why this is uncertain:** The grouped claim requires all checks, including current-tree install provenance, full framework validation, and release readiness.
  > **What would resolve this:** Resolve `BUG013-IMPLEMENT-20260715-002`, then execute the two remaining canonical commands serially and account for every resulting finding.

### Execution Handoff

Planning now maps each scenario to concrete current test paths and assertion
labels, machine-readable entries, faithful DoD claims, an explicit no-stress
classification, and a bounded change contract. Scope 1 remains **In Progress**
and certification remains unchanged. The next required owner is `bubbles.test`
to execute the current-tree Test Plan, account for every resulting finding, and
route the packet to validation ownership without inferring certification,
propagation, downstream upgrade, or terminal completion.

### Sequential Gate

Scope 1 cannot become Done until every core, test, regression, and build-quality
item has owner-tagged execution evidence and validate-owned certification.
