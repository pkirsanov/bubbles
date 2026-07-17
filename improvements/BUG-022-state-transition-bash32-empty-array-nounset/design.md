# Bug Fix Design: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` runs with `set -euo pipefail`,
discovers scopes and reports into indexed arrays, and sources two guard modules
into the same shell process. Stock macOS Bash 3.2 aborts when an initialized
empty indexed array is expanded as `"${array[@]}"`.

The current physical inventory contains 40 accepted sites in the main guard,
one positive-count control in the main guard, one accepted site in
`bubbles/scripts/guards/planning-checks.sh`, and two accepted sites in
`bubbles/scripts/guards/control-plane-checks.sh`. The prior design contained
competing active maps and authorized only the main guard, so it could not safely
authorize implementation.

### Target State

The accepted repair is one atomic 43-site transformation across the main guard
and its two sourced modules. Every accepted site uses the Bash-3.2-safe
conditional expansion `${array[@]+"${array[@]}"}` while every count-guarded or
fixed-nonempty control retains its current bytes.

The guard keeps strict mode, array initialization, append logic, ordering,
deduplication, diagnostics, result fields, failure counts, blocking codes, and
process exits. Empty collections supply zero arguments or zero loop iterations
and serialize as `[]`; no sentinel or empty-string placeholder is introduced.

### Patterns to Follow

- Treat the two sourced modules as inline parts of the guard execution surface.
- Match every site by file, array, ordinal, and local operation before editing.
- Change only the raw array token at the 43 accepted sites.
- Preserve the main guard's positive-count `scope_files` control and all other
  proven nonempty/count-only controls byte-for-byte.
- Use the current physical `test_29` only after `bubbles.test` establishes a
  new exact-byte RED identity for those bytes.

### Patterns to Avoid

- No 40-site main-guard-only repair.
- No `set +u`, shell-version branch, sentinel, default value, `eval`, nameref,
  associative array, helper accepting an already-expanded array, or reparsing.
- No broad replacement of every `[@]` expansion.
- No production edit before planner synchronization and test-owned RED recapture.
- No edit to tests, planner artifacts, report evidence, release identity,
  registries, sibling bugs, installers, or downstream managed copies by design.

### Resolved Decisions

- The three sourced-module sites are part of the accepted BUG-022 production
  inventory because they execute inline, consume the same global arrays, and
  can observe the same valid zero-cardinality states.
- The production inventory is exactly 43 accepted sites: 40 main, one planning
  module, and two control-plane module sites.
- Main-guard line 575 remains the raw positive-count control.
- Main-guard line 141 is accepted, not a nonempty control: pre-resolution
  `block_contract` can call the result formatter before applicable classes are
  populated.
- Implementation and rollback are atomic across all three production files.
- The drifted regression hash remains exclusively `bubbles.test` owned.

### Open Questions

None. Planning synchronization and test-owned RED recapture are required next,
but the technical source boundary is closed.

## Purpose And Scope

BUG-022 repairs one existing capability: the state-transition guard's handling
of zero, one, and multiple indexed-array elements under the supported stock
macOS Bash 3.2 runtime. It does not add a command, result field, workflow mode,
configuration key, dependency, storage model, public API, or alternate guard.

The production change is limited to conditional expansion at 43 accepted call
boundaries. It changes how an existing in-memory list becomes an argument
vector; it does not change what any guard check decides.

## Current Physical Baseline

The design reconciliation inspected the current bytes before authoring this
contract. These identities are collision detectors, not RED or GREEN evidence:

| Surface | SHA-256 observed at design reconciliation |
| --- | --- |
| `bubbles/scripts/state-transition-guard.sh` | `09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a` |
| `bubbles/scripts/guards/planning-checks.sh` | `a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583` |
| `bubbles/scripts/guards/control-plane-checks.sh` | `1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22` |
| Physical `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17` |

The prior report associates valid RED with test hash
`c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`.
That is not the current physical test identity. Design neither repairs nor
re-records this evidence. After planning is synchronized, `bubbles.test` must
decide the final test bytes and execute a fresh RED against unchanged 43-site
production bytes.

Every delivery owner must re-read hashes and local context immediately before
its edit. A mismatch is a collision requiring owner reconciliation, never a
reason to reset, checkout, normalize, or overwrite current work.

## Architecture And Execution Surface

### Main Guard Flow

```text
state-transition-guard.sh
  -> set -euo pipefail
  -> initialize result, scope, report, and evidence arrays
  -> discover scope_files[] and report_files[]
  -> execute inline checks
  -> source guards/control-plane-checks.sh in the same shell
  -> execute more inline checks
  -> source guards/planning-checks.sh in the same shell
  -> classify the result and emit TRANSITION_GUARD_RESULT_V1
```

Both module headers explicitly declare that they are sourced fragments whose
variables and pass/fail functions come from `state-transition-guard.sh`. There
is no subprocess boundary, serialization boundary, copied array, or separate
error contract between the main file and either module.

### Sourced-Module Inclusion Decision

The three module sites belong to BUG-022 for these concrete reasons:

1. The main guard sources `control-plane-checks.sh` at its current line 943 and
   `planning-checks.sh` at its current line 2208 using `source`, so Bash executes
   their expansions under the main guard's active `set -u`.
2. `control-plane-checks.sh` passes global `scope_files` and `report_files`
   directly to `detect_red_green_ordering`. Parameter expansion happens before
   that function starts. A selected per-scope layout can validly discover zero
   scopes, and a layout with scopes can discover zero reports.
3. `planning-checks.sh` iterates the same global `scope_files` during Check 8D.
   The guard records the missing-scope finding and continues, so the empty list
   remains reachable when the fragment is sourced.
4. Repairing only the main file leaves those same valid malformed-packet paths
   able to abort before the guard emits its complete failure result.

This decision is falsifiable. A module site would be excluded if the live bytes
showed a subprocess boundary, a local independently initialized list, or a
positive cardinality guard dominating expansion. None is present. A future
change introducing one of those conditions changes the inventory and must stop
implementation for design reconciliation; implementation must not guess.

### Pre-Resolution Formatter Reclassification

`transition_applicable_check_classes` is nonempty after successful contract
resolution, but that invariant does not dominate every call to
`emit_transition_result`. Usage and contract errors call `block_contract`
before profile fields are populated. The formatter at current main-guard line
141 therefore has a real zero state and is included in the 40 main sites. This
also matches the blocked-result contract requiring
`applicableCheckClasses: []`.

## Selected Compatibility Contract

At every accepted site, replace only:

```bash
"${items[@]}"
```

with:

```bash
${items[@]+"${items[@]}"}
```

For an unset or initialized-empty Bash 3.2 indexed array, the outer `+`
expansion omits its word, so a loop performs zero iterations, an array copy has
zero elements, and a function receives zero arguments. When elements exist,
the inner quoted expansion preserves one argument per element, including an
empty-string element, whitespace, duplicates, and order.

Use the same expression in each existing context:

```bash
for item in ${items[@]+"${items[@]}"}; do
  consume "$item"
done

copy=(${items[@]+"${items[@]}"})

consume_many ${items[@]+"${items[@]}"}
```

No append, loop body, branch, function signature, diagnostic, or formatter
statement changes.

## Accepted Production Inventory

Line numbers are current-byte anchors only. File, array, ordinal, and operation
together identify a site. If any tuple no longer resolves exactly once,
implementation stops without making a partial edit.

### Main Guard: 40 Accepted Sites

Path: `bubbles/scripts/state-transition-guard.sh`

| Site ID | Current line | Array | Operation |
| --- | ---: | --- | --- |
| `ACC-PASS` | 72 | `passed_gate_ids` | first passed-gate membership |
| `ACC-FAILED-GATE` | 77 | `failed_gate_ids` | first failed-gate membership |
| `ACC-FAILED-CHECK` | 82 | `failed_check_ids` | first failed-check membership |
| `RESULT-REQUIRED-LOOP` | 124 | `transition_required_gate_ids` | PASS required-gate loop |
| `RESULT-PASSED-LOOP` | 128 | `passed_gate_ids` | effective passed-gate loop |
| `RESULT-FAILED-FILTER` | 129 | `failed_gate_ids` | failed-gate exclusion membership |
| `RESULT-APPLICABLE-FORMAT` | 141 | `transition_applicable_check_classes` | blocked/pre-resolution formatter |
| `RESULT-NOT-APPLICABLE-FORMAT` | 142 | `transition_not_applicable_checks` | result formatter |
| `RESULT-PASSED-FORMAT` | 143 | `effective_passed_gate_ids` | result formatter |
| `RESULT-FAILED-GATE-FORMAT` | 144 | `failed_gate_ids` | result formatter |
| `RESULT-FAILED-CHECK-FORMAT` | 145 | `failed_check_ids` | result formatter |
| `SCOPE-BUILD-UNITS` | 558 | `scope_files` | build analysis units |
| `SCOPE-COPY` | 563 | `scope_files` | zero-length analysis copy |
| `SCOPE-LABELS` | 564 | `scope_files` | fallback analysis labels |
| `SCOPE-GHERKIN` | 594 | `scope_files` | scenario counting |
| `SCOPE-REPORT-CHECK` | 637 | `scope_files` | per-scope report check |
| `SCOPE-DOD-COUNT` | 1004 | `scope_files` | DoD aggregation |
| `SCOPE-DOD-DIAGNOSTICS` | 1022 | `scope_files` | unchecked-DoD diagnostics |
| `SCOPE-DOD-FORMAT` | 1056 | `scope_files` | format-manipulation scan |
| `SCOPE-STATUS-VOCAB` | 1115 | `scope_files` | status vocabulary scan |
| `SCOPE-STATUS-AGGREGATE` | 1167 | `scope_files` | scope status aggregation |
| `SCOPE-PLANNING-HONESTY` | 1186 | `scope_files` | planning status honesty |
| `SCOPE-INDEX-PARITY` | 1245 | `scope_files` | index/status parity |
| `SCOPE-PHANTOM-CHECK` | 1313 | `scope_files` | phantom completion scan |
| `SCOPE-SLA-SCAN` | 1363 | `scope_files` | SLA scan |
| `SCOPE-CHECK8-PATHS` | 2142 | `scope_files` | Check 8 test-path collection |
| `SCOPE-DOD-EVIDENCE` | 2351 | `scope_files` | DoD evidence scan |
| `SCOPE-TEMPLATE-SCAN` | 2454 | `scope_files` | scope template scan |
| `REPORT-TEMPLATE-SCAN` | 2464 | `report_files` | report template scan |
| `REPORT-REQUIRED-SECTIONS` | 2510 | `report_files` | report section/evidence scan |
| `SCOPE-DUPLICATE-EVIDENCE` | 2627 | `scope_files` | scope evidence traversal |
| `EVIDENCE-FIRST-COMPARE` | 2642 | `evidence_hashes` | compare first real hash with zero predecessors |
| `REPORT-DELTA-EVIDENCE` | 2712 | `report_files` | implementation-delta scan |
| `SCOPE-IMPLEMENTATION-PATHS` | 2750 | `scope_files` | implementation path discovery |
| `SCOPE-DEFERRAL-SCAN` | 2974 | `scope_files` | scope completion-language scan |
| `REPORT-DEFERRAL-SCAN` | 3002 | `report_files` | report completion-language scan |
| `REPORT-ENV-FAILURE-SCAN` | 3041 | `report_files` | report environment-failure scan |
| `SCOPE-ENV-FAILURE-SCAN` | 3055 | `scope_files` | scope environment-failure scan |
| `SCOPE-EVIDENCE-SIMILARITY` | 3079 | `scope_files` | evidence similarity collection |
| `FINAL-GATE-LOOKUP` | 3458 | `failed_gate_ids` | final `G073` classification lookup |

### Sourced Modules: 3 Accepted Sites

| Site ID | Exact path | Current line | Array | Operation |
| --- | --- | ---: | --- | --- |
| `PLANNING-CHANGE-BOUNDARY-SCOPE` | `bubbles/scripts/guards/planning-checks.sh` | 201 | `scope_files` | Check 8D change-boundary loop |
| `CONTROL-PLANE-TDD-SCOPES` | `bubbles/scripts/guards/control-plane-checks.sh` | 311 | `scope_files` | first list argument to `detect_red_green_ordering` |
| `CONTROL-PLANE-TDD-REPORTS` | `bubbles/scripts/guards/control-plane-checks.sh` | 311 | `report_files` | second list argument to `detect_red_green_ordering` |

The two line-311 expansions are independent sites. A packet can have nonempty
scopes and zero reports, so repairing only the first argument is insufficient.

### Controls That Must Remain Unchanged

The raw `scope_files` expansion at current main-guard line 575 is dominated by
positive cardinality checks and is the inventory's explicit raw control. It
must remain raw so the regression proves it distinguishes accepted sites from
safe uses instead of performing a blind replacement.

Count-only uses and expansions of arrays with a positive-count or fixed-
nonempty invariant also remain unchanged, including:

- `transition_resolver_args`
- `scope_section_tmp_files`
- `required_files`
- `required_specialists`
- `planning_required_agents`
- `timestamps`
- `intervals`
- `block_words`
- `test_files_in_plan`
- `required_headers`
- `impl_files`
- `evidence_blocks`

Any newly discovered raw expansion is a design finding. It is not silently
added to or excluded from this inventory during implementation.

## Preserved Behavioral Contracts

### Zero Elements

- Membership helpers inspect zero candidates and return their existing
  not-found status, allowing the real first value to append once.
- Empty loops perform zero iterations and empty copies remain empty.
- `format_result_list` receives zero arguments and emits exactly `[]`.
- Empty scope/report discovery reaches the existing structural diagnostics.
- The first evidence hash compares with zero prior hashes, then appends.
- An untagged failure retains `failedGateIds: []` and
  `blockingCode: PLANNING_GATE_FAILED`.

### One And Multiple Elements

- One empty-string element remains one argument.
- Whitespace and argument boundaries are preserved.
- Existing append order and first-seen deduplication remain authoritative.
- Multiple gate/check values retain current attribution and blocking behavior.
- `G073` still selects `SOURCE_EDIT_LOCKOUT`.

### Complete Result And Exit Contract

Pass, fail, and blocked paths each emit exactly one ordered
`TRANSITION_GUARD_RESULT_V1` block with unchanged field names and grammar.
Genuine findings remain nonzero. The compatibility change cannot suppress a
finding, convert failure to success, or replace the guard result with Bash's
`unbound variable` diagnostic.

## Data, API, UI, Configuration, And Migration Impact

No data model, storage schema, migration, endpoint, public API, UI, role,
authorization rule, feature flag, environment variable, deployment topology,
or external dependency changes. No data rollback or configuration conversion
exists for this repair.

## Security And Failure Handling

- `set -euo pipefail` remains active for the entire production process.
- No required input receives a default or fallback.
- No user-controlled string becomes code or a variable name.
- No stderr, check, gate, failure count, or nonzero exit is suppressed.
- No bypass flag or test-only production branch is introduced.
- A path, ordinal, hash, or protected-byte mismatch stops the active phase.

## Source Containment And Ownership

### Design Invocation Boundary

This design reconciliation may change only:

- `improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md`.

It does not change `state.json`, top-level status, or any `certification.*`
field.

### Authorized Delivery Surfaces

| Owner | Exact surface | Authorized responsibility |
| --- | --- | --- |
| `bubbles.design` | `design.md` | Maintain this single technical truth. |
| `bubbles.plan` | `scopes.md`, `test-plan.json`, and planning-owned manifest fields if synchronization requires them | Synchronize the atomic three-file/43-site boundary, commands, Test Plan, DoD, and owner route. |
| `bubbles.test` | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Own final bytes, exact hash, fresh RED, identical-byte GREEN, behavior fixtures, and 43 site mutants. |
| `bubbles.implement` | `bubbles/scripts/state-transition-guard.sh` | Apply only the 40 mapped token substitutions. |
| `bubbles.implement` | `bubbles/scripts/guards/planning-checks.sh` | Apply only the one mapped token substitution. |
| `bubbles.implement` | `bubbles/scripts/guards/control-plane-checks.sh` | Apply only the two mapped token substitutions. |
| `bubbles.test` | `bubbles/scripts/state-transition-guard-selftest.sh` | Add focused managed canaries only when required by the synchronized plan. |
| `bubbles.test` | `bubbles/scripts/framework-validate.sh` | Own the nonoverlapping source-only regression registration while preserving BUG-021 bytes. |
| `bubbles.test` | `bubbles/scripts/install-provenance-selftest.sh` | Own managed/source-only provenance assertions. |
| `bubbles.releases` | `bubbles/release-manifest.json` | Reconcile generated identity only after canonical inputs settle. |
| `bubbles.validate` | `state.json::certification.*` and terminal status | Independently certify only after complete delivery evidence exists. |

Implementation authorization is atomic: `bubbles.implement` receives all
three production paths together after planning and RED gates, or receives none.
No comment, formatting change, cleanup, or neighboring refactor is required or
authorized in those files.

### Protected Bytes

The following remain byte-protected from BUG-022 implementation:

- every nonmapped byte in the three production files;
- the BUG-019 Check 8 marker-bounded region and all `test_26` bytes;
- BUG-012 tail-gate bytes in the main guard;
- BUG-020 `fun-mode.sh`, packet, and test bytes;
- BUG-021 timeout, `framework-validate.sh`, packet, and `test_28` bytes except
  for the later test-owned collision-safe registration authorized by plan;
- the current physical `test_29` until `bubbles.test` acts;
- `BUGS.md`, installer bytes, generated release metadata, release generator,
  train/flag config, every sibling packet, and every downstream repository;
- all planner-owned artifacts during implementation;
- top-level and certification state during design, plan, test, and implement.

## Required Planning Reconciliation

`bubbles.plan` must synchronize all of the following before routing to test:

1. Replace every main-guard-only implementation boundary with the exact three
   production paths and counts `40 + 1 + 2 = 43`.
2. State that implementation is atomic and that a 40-site partial repair or
   partial rollback is forbidden.
3. Add the three module site IDs and their valid zero-state rationale to the
   implementation plan, change boundary, protected-byte inventory, and
   source-containment DoD.
4. Preserve main-guard line 575 as the raw positive-count control and classify
   main-guard line 141 as a zero-reachable blocked-result formatter.
5. Update the strict-mode/syntax test row to parse all three production files
   and scan the three-file repair surface for nounset suppression, unsafe
   indirection, or bypasses while requiring strict mode in the main guard.
6. Update the protected-byte/inventory row and matching DoD to assert 43 mapped
   sites, three exact production paths, one raw positive-count control, and
   unchanged nonmapped bytes.
7. Correct `T-BUG-022-09` in both `scopes.md` and `test-plan.json` to invoke
   `regression-quality-guard.sh --bugfix` with the physical `test_29` path,
   not the feature directory.
8. Keep all 21 Markdown/JSON Test Plan rows, 21 test-related DoD items, three
   scenarios, and manifest links in parity unless a planner-owned validation
   proves an exact synchronized change is required.
9. Route next to `bubbles.test`, not implementation, because the physical
   `test_29` hash differs from the recorded RED identity.

Planning must not copy the prior RED claim onto the current test hash.

## Test And Validation Obligations

### Fresh Final-Byte RED

After planning synchronization and before any production edit,
`bubbles.test` must select the final physical `test_29` bytes, record their
SHA-256, and execute the exact planned command against unchanged production.
A valid RED must prove:

- canonical inventory is 40 raw main sites and three raw module sites;
- all 11 production fixtures execute with zero harness/control/unrelated-abort
  failures;
- each valid zero family reaches its named production discriminator;
- all 43 independently staged site mutants are rejected;
- failure is caused by the mapped production defect, not fixture, parser,
  syntax, or protected-byte drift; and
- the test exits nonzero without a RED mode, bailout, inverted assertion, or
  canonical source mutation.

The earlier RED hash is historical evidence only and cannot authorize current
test bytes.

### Atomic Implementation Gate

Only after fresh RED may `bubbles.implement` transform all 43 accepted sites.
Before editing it records current hashes for all three source files and the
protected regions. After editing it proves:

- each accepted tuple changed exactly once to the selected expression;
- the main inventory is 40 guarded plus one raw control;
- the module inventory is three guarded;
- no accepted raw site remains;
- no control or nonmapped byte changed; and
- all three files parse under stock Bash 3.2.

Any failure leaves the implementation incomplete and blocks test routing.

### Identical-Byte GREEN And Runtime Matrix

`bubbles.test` reruns the exact RED test hash after implementation. GREEN must
cover zero, one, one-empty-string, and multiple values; pass, fail, and blocked
results; empty scope/report discovery; first and duplicate evidence hashes;
untagged and `G073` failures; ten behavior-family mutants; all 43 one-site
inventory mutants; and protected-byte containment.

The same exact test bytes run under:

| Lane | Required identity and proof |
| --- | --- |
| Stock macOS | `/bin/bash` reports 3.2.x; full regression and BUG-019 compatibility execute. |
| Newer macOS | Explicit Homebrew or MacPorts Bash reports its version and runs the identical regression. |
| Linux/WSL | Supported Bash reports platform/version and runs the identical regression plus managed/broad checks. |

No lane substitutes for another. An unavailable required lane remains a
blocking result rather than an inferred pass.

### Focused And Broad Checks

The owner-recorded sequence is:

1. exact inventory and targeted three-file diff;
2. Bash 3.2 syntax for all three production files;
3. physical-path regression-quality guard;
4. BUG-022 production regression;
5. unchanged BUG-019 `test_26`;
6. managed guard and structured-result consumer canaries;
7. portability, artifact lint, freshness, capability, and traceability checks;
8. install-provenance assertions;
9. full framework validation;
10. release-owner identity reconciliation and release check;
11. supported downstream upgrade provenance; and
12. independent validation/certification.

Design-phase artifact checks prove only design coherence. They do not prove
RED, GREEN, runtime behavior, release readiness, downstream propagation, or
certification.

## Observability And Consumer Impact

This shell guard has no service telemetry plane. Its observable contract is
stdout/stderr check labels, structured result fields, failure counts, blocking
codes, and process exit. Regression output must identify interpreter, fixture,
child exit, result delimiters, array field, inventory totals, mutant identity,
source/test hashes, and verdict.

No consumer command or schema changes. `bubbles/scripts/cli.sh`, validate/audit
flows, MCP wrappers, state-transition selftests, and structured-result linters
continue to consume the same command shape and ordered result grammar.

## Provenance Impact

All three production files are install-managed. The current release manifest
records both module paths, and `install.sh` copies the managed
`bubbles/scripts/guards/` directory. The installer algorithm does not change.

`bubbles.test` must extend install-provenance coverage so the main guard,
`guards/planning-checks.sh`, and `guards/control-plane-checks.sh` are each
verified byte-identical after installation, while `test_29` remains source-only
and release-recorded. After source, tests, registration, and provenance settle,
only `bubbles.releases` regenerates `bubbles/release-manifest.json` and runs the
release check. No implementation or test owner hand-edits generated identity.

Downstream repositories are read-only during canonical work. They receive the
coherent release through the supported installer/upgrade path; direct edits to
installed `.github/bubbles/**` files are forbidden.

## Rollout And Rollback

Rollout is atomic across the three production files and one exact regression
identity: synchronized plan, fresh final-byte RED, 43-site implementation,
identical-byte GREEN, runtime matrix, focused canaries, framework validation,
release-owner identity, then supported downstream upgrade.

Before implementation, record a three-file base-hash set and a patch containing
only the 43 token substitutions. Before release, rollback reverses that exact
BUG-022 patch across all three files against the recorded post-edit hashes. If
any hash no longer matches, stop and reconcile with the current owner; never
restore a file from `HEAD` or rewrite the whole file.

After release, rollback selects the previous validated canonical release and
uses canonical release/install tooling. It never hand-edits an installed copy.
A rollback that restores only the main guard, only a module, or fewer than 43
sites is invalid because it creates a mixed execution surface.

## Exact Next-Owner Handoff

`nextRequiredOwner` is `bubbles.plan`.

Planning must apply the nine-item reconciliation above and keep the packet
blocked. Its next route is `bubbles.test` for fresh exact-byte RED. Only after a
valid, unchanged RED may planning's synchronized boundary route all three
production files together to `bubbles.implement`.

No direct design-to-implementation route is authorized.

## Alternatives And Tradeoffs

| Alternative | Rejection reason |
| --- | --- |
| Repair only the 40 main sites | Leaves three inline sourced expansions nounset-unsafe and violates complete finding accounting. |
| Wrap each use in a count branch | Duplicates control flow around 43 sites and risks skipping existing behavior. |
| Helper accepting expanded values | Expansion aborts before helper entry. |
| Helper accepting an array name | Bash 3.2 lacks nameref; `eval` or reparsing adds risk. |
| Sentinel element | Fabricates data and changes counts and formatting. |
| Disable nounset | Hides unrelated unset-variable defects and violates the strict-mode requirement. |
| Require newer Bash | Violates the supported stock macOS runtime. |
| Blindly rewrite every array expansion | Changes safe controls and expands ownership beyond the diagnosed defect. |

## Complexity Tracking

None - simplest viable approach used. One existing Bash expression is applied
at the exact expansion boundary in three files that already form one sourced
execution surface. The 43-site validation matrix reflects masked blast radius;
it does not add a production abstraction.

### Single-Implementation Justification

This is a narrow bug fix inside one existing guard capability. The sourced
files are fragments of that implementation, not providers or variants. A new
foundation, adapter, list API, or shell-version strategy would add indirection
without removing the expansion-before-call failure.

## Risks And Open Questions

No blocking design question remains.

Bounded risks are exact and owner-controlled:

- a site tuple can drift under concurrent work, which blocks rather than
  broadens implementation;
- the current test hash lacks valid RED identity, which requires test-owned
  execution after planning;
- a broad replacement can alter the raw control or foreign bytes, which exact
  inventory and three-file hashes reject;
- modern Bash can conceal the runtime defect, so actual Bash 3.2 is mandatory;
- registration and release surfaces are concurrently dirty, so their named
  owners must use targeted edits and stop on overlap.

## Archive Notes - Inactive

The former main-guard-only boundary and every competing active inventory are
superseded. The three sourced-module expansions are part of the atomic repair.

The RED tied to test SHA-256
`c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`
is historical reproduction evidence after physical test drift. It is not
active source-edit authorization or GREEN provenance.

<!--
## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` runs with `set -euo pipefail`,
discovers scopes and reports into indexed arrays, and sources two guard modules
into the same shell process. Stock macOS Bash 3.2 aborts when an initialized
empty indexed array is expanded as `"${array[@]}"`.

The current physical inventory contains 40 accepted sites in the main guard,
one positive-count control in the main guard, one accepted site in
`bubbles/scripts/guards/planning-checks.sh`, and two accepted sites in
`bubbles/scripts/guards/control-plane-checks.sh`. The prior design contained
competing active maps and authorized only the main guard, so it could not safely
authorize implementation.

### Target State

The accepted repair is one atomic 43-site transformation across the main guard
and its two sourced modules. Every accepted site uses the Bash-3.2-safe
conditional expansion `${array[@]+"${array[@]}"}` while every count-guarded or
fixed-nonempty control retains its current bytes.

The guard keeps strict mode, array initialization, append logic, ordering,
deduplication, diagnostics, result fields, failure counts, blocking codes, and
process exits. Empty collections supply zero arguments or zero loop iterations
and serialize as `[]`; no sentinel or empty-string placeholder is introduced.

### Patterns to Follow

- Treat the two sourced modules as inline parts of the guard execution surface.
- Match every site by file, array, ordinal, and local operation before editing.
- Change only the raw array token at the 43 accepted sites.
- Preserve the main guard's positive-count `scope_files` control and all other
  proven nonempty/count-only controls byte-for-byte.
- Use the current physical `test_29` only after `bubbles.test` establishes a
  new exact-byte RED identity for those bytes.

### Patterns to Avoid

- No 40-site main-guard-only repair.
- No `set +u`, shell-version branch, sentinel, default value, `eval`, nameref,
  associative array, helper accepting an already-expanded array, or reparsing.
- No broad replacement of every `[@]` expansion.
- No production edit before planner synchronization and test-owned RED recapture.
- No edit to tests, planner artifacts, report evidence, release identity,
  registries, sibling bugs, installers, or downstream managed copies by design.

### Resolved Decisions

- The three sourced-module sites are part of the accepted BUG-022 production
  inventory because they execute inline, consume the same global arrays, and
  can observe the same valid zero-cardinality states.
- The production inventory is exactly 43 accepted sites: 40 main, one planning
  module, and two control-plane module sites.
- Main-guard line 575 remains the raw positive-count control.
- Main-guard line 141 is accepted, not a nonempty control: pre-resolution
  `block_contract` can call the result formatter before applicable classes are
  populated.
- Implementation and rollback are atomic across all three production files.
- The drifted regression hash remains exclusively `bubbles.test` owned.

### Open Questions

None. Planning synchronization and test-owned RED recapture are required next,
but the technical source boundary is closed.

## Purpose And Scope

BUG-022 repairs one existing capability: the state-transition guard's handling
of zero, one, and multiple indexed-array elements under the supported stock
macOS Bash 3.2 runtime. It does not add a command, result field, workflow mode,
configuration key, dependency, storage model, public API, or alternate guard.

The production change is limited to conditional expansion at 43 accepted call
boundaries. It changes how an existing in-memory list becomes an argument
vector; it does not change what any guard check decides.

## Current Physical Baseline

The design reconciliation inspected the current bytes before authoring this
contract. These identities are collision detectors, not RED or GREEN evidence:

| Surface | SHA-256 observed at design reconciliation |
| --- | --- |
| `bubbles/scripts/state-transition-guard.sh` | `09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a` |
| `bubbles/scripts/guards/planning-checks.sh` | `a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583` |
| `bubbles/scripts/guards/control-plane-checks.sh` | `1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22` |
| Physical `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17` |

The prior report associates valid RED with test hash
`c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`.
That is not the current physical test identity. Design neither repairs nor
re-records this evidence. After planning is synchronized, `bubbles.test` must
decide the final test bytes and execute a fresh RED against unchanged 43-site
production bytes.

Every delivery owner must re-read hashes and local context immediately before
its edit. A mismatch is a collision requiring owner reconciliation, never a
reason to reset, checkout, normalize, or overwrite current work.

## Architecture And Execution Surface

### Main Guard Flow

```text
state-transition-guard.sh
  -> set -euo pipefail
  -> initialize result, scope, report, and evidence arrays
  -> discover scope_files[] and report_files[]
  -> execute inline checks
  -> source guards/control-plane-checks.sh in the same shell
  -> execute more inline checks
  -> source guards/planning-checks.sh in the same shell
  -> classify the result and emit TRANSITION_GUARD_RESULT_V1
```

Both module headers explicitly declare that they are sourced fragments whose
variables and pass/fail functions come from `state-transition-guard.sh`. There
is no subprocess boundary, serialization boundary, copied array, or separate
error contract between the main file and either module.

### Sourced-Module Inclusion Decision

The three module sites belong to BUG-022 for these concrete reasons:

1. The main guard sources `control-plane-checks.sh` at its current line 943 and
   `planning-checks.sh` at its current line 2208 using `source`, so Bash executes
   their expansions under the main guard's active `set -u`.
2. `control-plane-checks.sh` passes global `scope_files` and `report_files`
   directly to `detect_red_green_ordering`. Parameter expansion happens before
   that function starts. A selected per-scope layout can validly discover zero
   scopes, and a layout with scopes can discover zero reports.
3. `planning-checks.sh` iterates the same global `scope_files` during Check 8D.
   The guard records the missing-scope finding and continues, so the empty list
   remains reachable when the fragment is sourced.
4. Repairing only the main file leaves those same valid malformed-packet paths
   able to abort before the guard emits its complete failure result.

This decision is falsifiable. A module site would be excluded if the live bytes
showed a subprocess boundary, a local independently initialized list, or a
positive cardinality guard dominating expansion. None is present. A future
change introducing one of those conditions changes the inventory and must stop
implementation for design reconciliation; implementation must not guess.

### Pre-Resolution Formatter Reclassification

`transition_applicable_check_classes` is nonempty after successful contract
resolution, but that invariant does not dominate every call to
`emit_transition_result`. Usage and contract errors call `block_contract`
before profile fields are populated. The formatter at current main-guard line
141 therefore has a real zero state and is included in the 40 main sites. This
also matches the blocked-result contract requiring
`applicableCheckClasses: []`.

## Selected Compatibility Contract

At every accepted site, replace only:

```bash
"${items[@]}"
```

with:

```bash
${items[@]+"${items[@]}"}
```

For an unset or initialized-empty Bash 3.2 indexed array, the outer `+`
expansion omits its word, so a loop performs zero iterations, an array copy has
zero elements, and a function receives zero arguments. When elements exist,
the inner quoted expansion preserves one argument per element, including an
empty-string element, whitespace, duplicates, and order.

Use the same expression in each existing context:

```bash
for item in ${items[@]+"${items[@]}"}; do
  consume "$item"
done

copy=(${items[@]+"${items[@]}"})

consume_many ${items[@]+"${items[@]}"}
```

No append, loop body, branch, function signature, diagnostic, or formatter
statement changes.

## Accepted Production Inventory

Line numbers are current-byte anchors only. File, array, ordinal, and operation
together identify a site. If any tuple no longer resolves exactly once,
implementation stops without making a partial edit.

### Main Guard: 40 Accepted Sites

Path: `bubbles/scripts/state-transition-guard.sh`

| Site ID | Current line | Array | Operation |
| --- | ---: | --- | --- |
| `ACC-PASS` | 72 | `passed_gate_ids` | first passed-gate membership |
| `ACC-FAILED-GATE` | 77 | `failed_gate_ids` | first failed-gate membership |
| `ACC-FAILED-CHECK` | 82 | `failed_check_ids` | first failed-check membership |
| `RESULT-REQUIRED-LOOP` | 124 | `transition_required_gate_ids` | PASS required-gate loop |
| `RESULT-PASSED-LOOP` | 128 | `passed_gate_ids` | effective passed-gate loop |
| `RESULT-FAILED-FILTER` | 129 | `failed_gate_ids` | failed-gate exclusion membership |
| `RESULT-APPLICABLE-FORMAT` | 141 | `transition_applicable_check_classes` | blocked/pre-resolution formatter |
| `RESULT-NOT-APPLICABLE-FORMAT` | 142 | `transition_not_applicable_checks` | result formatter |
| `RESULT-PASSED-FORMAT` | 143 | `effective_passed_gate_ids` | result formatter |
| `RESULT-FAILED-GATE-FORMAT` | 144 | `failed_gate_ids` | result formatter |
| `RESULT-FAILED-CHECK-FORMAT` | 145 | `failed_check_ids` | result formatter |
| `SCOPE-BUILD-UNITS` | 558 | `scope_files` | build analysis units |
| `SCOPE-COPY` | 563 | `scope_files` | zero-length analysis copy |
| `SCOPE-LABELS` | 564 | `scope_files` | fallback analysis labels |
| `SCOPE-GHERKIN` | 594 | `scope_files` | scenario counting |
| `SCOPE-REPORT-CHECK` | 637 | `scope_files` | per-scope report check |
| `SCOPE-DOD-COUNT` | 1004 | `scope_files` | DoD aggregation |
| `SCOPE-DOD-DIAGNOSTICS` | 1022 | `scope_files` | unchecked-DoD diagnostics |
| `SCOPE-DOD-FORMAT` | 1056 | `scope_files` | format-manipulation scan |
| `SCOPE-STATUS-VOCAB` | 1115 | `scope_files` | status vocabulary scan |
| `SCOPE-STATUS-AGGREGATE` | 1167 | `scope_files` | scope status aggregation |
| `SCOPE-PLANNING-HONESTY` | 1186 | `scope_files` | planning status honesty |
| `SCOPE-INDEX-PARITY` | 1245 | `scope_files` | index/status parity |
| `SCOPE-PHANTOM-CHECK` | 1313 | `scope_files` | phantom completion scan |
| `SCOPE-SLA-SCAN` | 1363 | `scope_files` | SLA scan |
| `SCOPE-CHECK8-PATHS` | 2142 | `scope_files` | Check 8 test-path collection |
| `SCOPE-DOD-EVIDENCE` | 2351 | `scope_files` | DoD evidence scan |
| `SCOPE-TEMPLATE-SCAN` | 2454 | `scope_files` | scope template scan |
| `REPORT-TEMPLATE-SCAN` | 2464 | `report_files` | report template scan |
| `REPORT-REQUIRED-SECTIONS` | 2510 | `report_files` | report section/evidence scan |
| `SCOPE-DUPLICATE-EVIDENCE` | 2627 | `scope_files` | scope evidence traversal |
| `EVIDENCE-FIRST-COMPARE` | 2642 | `evidence_hashes` | compare first real hash with zero predecessors |
| `REPORT-DELTA-EVIDENCE` | 2712 | `report_files` | implementation-delta scan |
| `SCOPE-IMPLEMENTATION-PATHS` | 2750 | `scope_files` | implementation path discovery |
| `SCOPE-DEFERRAL-SCAN` | 2974 | `scope_files` | scope completion-language scan |
| `REPORT-DEFERRAL-SCAN` | 3002 | `report_files` | report completion-language scan |
| `REPORT-ENV-FAILURE-SCAN` | 3041 | `report_files` | report environment-failure scan |
| `SCOPE-ENV-FAILURE-SCAN` | 3055 | `scope_files` | scope environment-failure scan |
| `SCOPE-EVIDENCE-SIMILARITY` | 3079 | `scope_files` | evidence similarity collection |
| `FINAL-GATE-LOOKUP` | 3458 | `failed_gate_ids` | final `G073` classification lookup |

### Sourced Modules: 3 Accepted Sites

| Site ID | Exact path | Current line | Array | Operation |
| --- | --- | ---: | --- | --- |
| `PLANNING-CHANGE-BOUNDARY-SCOPE` | `bubbles/scripts/guards/planning-checks.sh` | 201 | `scope_files` | Check 8D change-boundary loop |
| `CONTROL-PLANE-TDD-SCOPES` | `bubbles/scripts/guards/control-plane-checks.sh` | 311 | `scope_files` | first list argument to `detect_red_green_ordering` |
| `CONTROL-PLANE-TDD-REPORTS` | `bubbles/scripts/guards/control-plane-checks.sh` | 311 | `report_files` | second list argument to `detect_red_green_ordering` |

The two line-311 expansions are independent sites. A packet can have nonempty
scopes and zero reports, so repairing only the first argument is insufficient.

### Controls That Must Remain Unchanged

The raw `scope_files` expansion at current main-guard line 575 is dominated by
positive cardinality checks and is the inventory's explicit raw control. It
must remain raw so the regression proves it distinguishes accepted sites from
safe uses instead of performing a blind replacement.

Count-only uses and expansions of arrays with a positive-count or fixed-
nonempty invariant also remain unchanged, including:

- `transition_resolver_args`
- `scope_section_tmp_files`
- `required_files`
- `required_specialists`
- `planning_required_agents`
- `timestamps`
- `intervals`
- `block_words`
- `test_files_in_plan`
- `required_headers`
- `impl_files`
- `evidence_blocks`

Any newly discovered raw expansion is a design finding. It is not silently
added to or excluded from this inventory during implementation.

## Preserved Behavioral Contracts

### Zero Elements

- Membership helpers inspect zero candidates and return their existing
  not-found status, allowing the real first value to append once.
- Empty loops perform zero iterations and empty copies remain empty.
- `format_result_list` receives zero arguments and emits exactly `[]`.
- Empty scope/report discovery reaches the existing structural diagnostics.
- The first evidence hash compares with zero prior hashes, then appends.
- An untagged failure retains `failedGateIds: []` and
  `blockingCode: PLANNING_GATE_FAILED`.

### One And Multiple Elements

- One empty-string element remains one argument.
- Whitespace and argument boundaries are preserved.
- Existing append order and first-seen deduplication remain authoritative.
- Multiple gate/check values retain current attribution and blocking behavior.
- `G073` still selects `SOURCE_EDIT_LOCKOUT`.

### Complete Result And Exit Contract

Pass, fail, and blocked paths each emit exactly one ordered
`TRANSITION_GUARD_RESULT_V1` block with unchanged field names and grammar.
Genuine findings remain nonzero. The compatibility change cannot suppress a
finding, convert failure to success, or replace the guard result with Bash's
`unbound variable` diagnostic.

## Data, API, UI, Configuration, And Migration Impact

No data model, storage schema, migration, endpoint, public API, UI, role,
authorization rule, feature flag, environment variable, deployment topology,
or external dependency changes. No data rollback or configuration conversion
exists for this repair.

## Security And Failure Handling

- `set -euo pipefail` remains active for the entire production process.
- No required input receives a default or fallback.
- No user-controlled string becomes code or a variable name.
- No stderr, check, gate, failure count, or nonzero exit is suppressed.
- No bypass flag or test-only production branch is introduced.
- A path, ordinal, hash, or protected-byte mismatch stops the active phase.

## Source Containment And Ownership

### Design Invocation Boundary

This design reconciliation may change only:

- `improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md`;
- design execution/routing fields and one appended design execution-history
  record in the packet's `state.json`.

Top-level status and every `certification.*` byte remain unchanged.

### Authorized Delivery Surfaces

| Owner | Exact surface | Authorized responsibility |
| --- | --- | --- |
| `bubbles.design` | `design.md` | Maintain this single technical truth. |
| `bubbles.plan` | `scopes.md`, `test-plan.json`, and planning-owned manifest fields if synchronization requires them | Synchronize the atomic three-file/43-site boundary, commands, Test Plan, DoD, and owner route. |
| `bubbles.test` | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Own final bytes, exact hash, fresh RED, identical-byte GREEN, behavior fixtures, and 43 site mutants. |
| `bubbles.implement` | `bubbles/scripts/state-transition-guard.sh` | Apply only the 40 mapped token substitutions. |
| `bubbles.implement` | `bubbles/scripts/guards/planning-checks.sh` | Apply only the one mapped token substitution. |
| `bubbles.implement` | `bubbles/scripts/guards/control-plane-checks.sh` | Apply only the two mapped token substitutions. |
| `bubbles.test` | `bubbles/scripts/state-transition-guard-selftest.sh` | Add focused managed canaries only when required by the synchronized plan. |
| `bubbles.test` | `bubbles/scripts/framework-validate.sh` | Own the nonoverlapping source-only regression registration while preserving BUG-021 bytes. |
| `bubbles.test` | `bubbles/scripts/install-provenance-selftest.sh` | Own managed/source-only provenance assertions. |
| `bubbles.releases` | `bubbles/release-manifest.json` | Reconcile generated identity only after canonical inputs settle. |
| `bubbles.validate` | `state.json::certification.*` and terminal status | Independently certify only after complete delivery evidence exists. |

Implementation authorization is atomic: `bubbles.implement` receives all
three production paths together after planning and RED gates, or receives none.
No comment, formatting change, cleanup, or neighboring refactor is required or
authorized in those files.

### Protected Bytes

The following remain byte-protected from BUG-022 implementation:

- every nonmapped byte in the three production files;
- the BUG-019 Check 8 marker-bounded region and all `test_26` bytes;
- BUG-012 tail-gate bytes in the main guard;
- BUG-020 `fun-mode.sh`, packet, and test bytes;
- BUG-021 timeout, `framework-validate.sh`, packet, and `test_28` bytes except
  for the later test-owned collision-safe registration authorized by plan;
- the current physical `test_29` until `bubbles.test` acts;
- `BUGS.md`, installer bytes, generated release metadata, release generator,
  train/flag config, every sibling packet, and every downstream repository;
- all planner-owned artifacts during implementation;
- top-level and certification state during design, plan, test, and implement.

## Required Planning Reconciliation

`bubbles.plan` must synchronize all of the following before routing to test:

1. Replace every main-guard-only implementation boundary with the exact three
   production paths and counts `40 + 1 + 2 = 43`.
2. State that implementation is atomic and that a 40-site partial repair or
   partial rollback is forbidden.
3. Add the three module site IDs and their valid zero-state rationale to the
   implementation plan, change boundary, protected-byte inventory, and
   source-containment DoD.
4. Preserve main-guard line 575 as the raw positive-count control and classify
   main-guard line 141 as a zero-reachable blocked-result formatter.
5. Update the strict-mode/syntax test row to parse all three production files
   and scan the three-file repair surface for nounset suppression, unsafe
   indirection, or bypasses while requiring strict mode in the main guard.
6. Update the protected-byte/inventory row and matching DoD to assert 43 mapped
   sites, three exact production paths, one raw positive-count control, and
   unchanged nonmapped bytes.
7. Correct `T-BUG-022-09` in both `scopes.md` and `test-plan.json` to invoke
   `regression-quality-guard.sh --bugfix` with the physical `test_29` path,
   not the feature directory.
8. Keep all 21 Markdown/JSON Test Plan rows, 21 test-related DoD items, three
   scenarios, and manifest links in parity unless a planner-owned validation
   proves an exact synchronized change is required.
9. Route next to `bubbles.test`, not implementation, because the physical
   `test_29` hash differs from the recorded RED identity.

Planning must not copy the prior RED claim onto the current test hash.

## Test And Validation Obligations

### Fresh Final-Byte RED

After planning synchronization and before any production edit,
`bubbles.test` must select the final physical `test_29` bytes, record their
SHA-256, and execute the exact planned command against unchanged production.
A valid RED must prove:

- canonical inventory is 40 raw main sites and three raw module sites;
- all 11 production fixtures execute with zero harness/control/unrelated-abort
  failures;
- each valid zero family reaches its named production discriminator;
- all 43 independently staged site mutants are rejected;
- failure is caused by the mapped production defect, not fixture, parser,
  syntax, or protected-byte drift; and
- the test exits nonzero without a RED mode, bailout, inverted assertion, or
  canonical source mutation.

The earlier RED hash is historical evidence only and cannot authorize current
test bytes.

### Atomic Implementation Gate

Only after fresh RED may `bubbles.implement` transform all 43 accepted sites.
Before editing it records current hashes for all three source files and the
protected regions. After editing it proves:

- each accepted tuple changed exactly once to the selected expression;
- the main inventory is 40 guarded plus one raw control;
- the module inventory is three guarded;
- no accepted raw site remains;
- no control or nonmapped byte changed; and
- all three files parse under stock Bash 3.2.

Any failure leaves the implementation incomplete and blocks test routing.

### Identical-Byte GREEN And Runtime Matrix

`bubbles.test` reruns the exact RED test hash after implementation. GREEN must
cover zero, one, one-empty-string, and multiple values; pass, fail, and blocked
results; empty scope/report discovery; first and duplicate evidence hashes;
untagged and `G073` failures; ten behavior-family mutants; all 43 one-site
inventory mutants; and protected-byte containment.

The same exact test bytes run under:

| Lane | Required identity and proof |
| --- | --- |
| Stock macOS | `/bin/bash` reports 3.2.x; full regression and BUG-019 compatibility execute. |
| Newer macOS | Explicit Homebrew or MacPorts Bash reports its version and runs the identical regression. |
| Linux/WSL | Supported Bash reports platform/version and runs the identical regression plus managed/broad checks. |

No lane substitutes for another. An unavailable required lane remains a
blocking result rather than an inferred pass.

### Focused And Broad Checks

The owner-recorded sequence is:

1. exact inventory and targeted three-file diff;
2. Bash 3.2 syntax for all three production files;
3. physical-path regression-quality guard;
4. BUG-022 production regression;
5. unchanged BUG-019 `test_26`;
6. managed guard and structured-result consumer canaries;
7. portability, artifact lint, freshness, capability, and traceability checks;
8. install-provenance assertions;
9. full framework validation;
10. release-owner identity reconciliation and release check;
11. supported downstream upgrade provenance; and
12. independent validation/certification.

Design-phase artifact checks prove only design coherence. They do not prove
RED, GREEN, runtime behavior, release readiness, downstream propagation, or
certification.

## Observability And Consumer Impact

This shell guard has no service telemetry plane. Its observable contract is
stdout/stderr check labels, structured result fields, failure counts, blocking
codes, and process exit. Regression output must identify interpreter, fixture,
child exit, result delimiters, array field, inventory totals, mutant identity,
source/test hashes, and verdict.

No consumer command or schema changes. `bubbles/scripts/cli.sh`, validate/audit
flows, MCP wrappers, state-transition selftests, and structured-result linters
continue to consume the same command shape and ordered result grammar.

## Rollout And Rollback

Rollout is atomic across the three production files and one exact regression
identity: synchronized plan, fresh final-byte RED, 43-site implementation,
identical-byte GREEN, runtime matrix, focused canaries, framework validation,
release-owner identity, then supported downstream upgrade.

Before implementation, record a three-file base-hash set and a patch containing
only the 43 token substitutions. Before release, rollback reverses that exact
BUG-022 patch across all three files against the recorded post-edit hashes. If
any hash no longer matches, stop and reconcile with the current owner; never
restore a file from `HEAD` or rewrite the whole file.

After release, rollback selects the previous validated canonical release and
uses canonical release/install tooling. It never hand-edits an installed copy.
A rollback that restores only the main guard, only a module, or fewer than 43
sites is invalid because it creates a mixed execution surface.

## Alternatives And Tradeoffs

| Alternative | Rejection reason |
| --- | --- |
| Repair only the 40 main sites | Leaves three inline sourced expansions nounset-unsafe and violates complete finding accounting. |
| Wrap each use in a count branch | Duplicates control flow around 43 sites and risks skipping existing behavior. |
| Helper accepting expanded values | Expansion aborts before helper entry. |
| Helper accepting an array name | Bash 3.2 lacks nameref; `eval` or reparsing adds risk. |
| Sentinel element | Fabricates data and changes counts and formatting. |
| Disable nounset | Hides unrelated unset-variable defects and violates the strict-mode requirement. |
| Require newer Bash | Violates the supported stock macOS runtime. |
| Blindly rewrite every array expansion | Changes safe controls and expands ownership beyond the diagnosed defect. |

## Complexity Tracking

None - simplest viable approach used. One existing Bash expression is applied
at the exact expansion boundary in three files that already form one sourced
execution surface. The 43-site validation matrix reflects masked blast radius;
it does not add a production abstraction.

### Single-Implementation Justification

This is a narrow bug fix inside one existing guard capability. The sourced
files are fragments of that implementation, not providers or variants. A new
foundation, adapter, list API, or shell-version strategy would add indirection
without removing the expansion-before-call failure.

## Risks And Open Questions

No blocking design question remains.

Bounded risks are exact and owner-controlled:

- a site tuple can drift under concurrent work, which blocks rather than
  broadens implementation;
- the current test hash lacks valid RED identity, which requires test-owned
  execution after planning;
- a broad replacement can alter the raw control or foreign bytes, which exact
  inventory and three-file hashes reject;
- modern Bash can conceal the runtime defect, so actual Bash 3.2 is mandatory;
- registration and release surfaces are concurrently dirty, so their named
  owners must use targeted edits and stop on overlap.

## Archive Notes - Inactive

The bytes below preserve concurrent superseded design blocks for collision
safety. They are not active design authority and must not be used by planning
or implementation.

# Bug Fix Design: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` enables `set -euo pipefail`, owns
the guard's indexed arrays, and sources two production check modules into the
same shell. Stock macOS Bash 3.2 aborts when a raw `"${array[@]}"` expansion
observes an initialized empty indexed array.

The accepted source inventory contains 40 main-guard occurrences plus three
occurrences in the sourced modules. The prior design authorized only the main
guard, so implementation correctly refused a partial repair. The physical
`test_29` bytes also drifted after the recorded RED run, making that historical
RED non-authoritative for implementation.

### Target State

One all-or-nothing production repair changes exactly 43 accepted occurrences
across three files to `${array[@]+"${array[@]}"}`. Empty arrays produce zero
arguments or iterations; one and multiple elements retain exact boundaries,
order, duplication input, and existing consumer semantics.

Strict mode, result fields, diagnostics, gate/check attribution, failure
counts, and exit classes remain unchanged. A valid empty discovery list reaches
the guard's existing findings and complete result envelope instead of a shell
abort.

### Patterns to Follow

- Preserve the same-shell source architecture in
  `bubbles/scripts/state-transition-guard.sh`.
- Apply the exact guarded expansion at every accepted occurrence in the three
  production files listed by this design.
- Keep loop bodies, callees, append operations, result formatting, and
  diagnostics unchanged.
- Re-resolve every site by path, array, and local context before editing because
  the worktree is concurrent and line numbers are only review anchors.
- Capture a new exact-byte RED after planning is synchronized and before any
  production edit.

### Patterns to Avoid

- Do not disable nounset, add sentinels, fabricate empty-string values, or
  suppress a nonzero result.
- Do not add `eval`, namerefs, associative arrays, a shell-version branch, or a
  second list abstraction.
- Do not repair only the main guard or only the earliest observed aborts.
- Do not rewrite count-guarded controls merely for visual uniformity.
- Do not edit BUG-019/020/021, release metadata, downstream installed copies,
  or foreign-owned planning and evidence artifacts from this design phase.

### Resolved Decisions

- The production unit is exactly three files and 43 accepted occurrences.
- The two module files are production code owned by `bubbles.implement`, not
  independent scripts or test fixtures.
- The repair is indivisible: no partial source state may be treated as GREEN or
  released.
- The old RED transcript remains historical evidence only after test hash
  drift; `bubbles.test` must establish a new final-byte RED.
- The immediate next owner is `bubbles.plan`, which must synchronize the
  executable boundary before test or implementation resumes.

### Open Questions

None.

## Purpose And Scope

BUG-022 restores the existing state-transition contract on the supported stock
macOS Bash 3.2 runtime. It implements `BR-022-001` through `BR-022-010` without
changing what any transition check decides.

The only production behavior change is at list expansion boundaries. A valid
zero-cardinality indexed array no longer terminates the guard before normal
diagnostics and `TRANSITION_GUARD_RESULT_V1` emission. The repair introduces no
new command, option, environment variable, dependency, configuration key,
workflow mode, result field, persisted state, or public API.

## Architecture And Root Cause

### Same-Shell Sourced-Module Architecture

The controlling path is one Bash process:

```text
bubbles/scripts/state-transition-guard.sh
  -> set -euo pipefail
  -> initialize result, scope, report, and evidence arrays
  -> source guards/control-plane-checks.sh
       -> detect_red_green_ordering receives scope_files and report_files
  -> run inline checks and Check 8
  -> source guards/planning-checks.sh
       -> Check 8D traverses scope_files
  -> run remaining inline checks
  -> construct and emit TRANSITION_GUARD_RESULT_V1
```

The live guard sources `guards/control-plane-checks.sh` after scope/report
discovery and sources `guards/planning-checks.sh` after Check 8. Both module
headers explicitly declare that they execute in the guard's shell scope and
consume its global arrays and helper functions. There is no child-process or
shell-option boundary: both modules inherit the guard's active nounset setting.

The control-plane source line contains two independent expansions in one
function call. It therefore contributes two repair occurrences even though it
occupies one physical line. The planning module contributes one loop expansion.

### Falsifiable Root-Cause Model

The design predicts:

1. raw `"${array[@]}"` aborts under Bash 3.2 nounset when the indexed array is
   initialized but empty;
2. `${array[@]+"${array[@]}"}` supplies zero words for an unset or initialized
   empty array;
3. the guarded form supplies one empty word for an array containing one empty
   string;
4. the guarded form preserves each nonempty element, whitespace, order, and
   duplicates; and
5. callers and loop bodies behave identically on newer Bash when values exist.

The model is disproved if any accepted zero path still aborts, an empty array
becomes one empty argument, an empty-string element disappears, an element
splits, ordering changes, a finding is suppressed, a result field drifts, or a
partial three-file repair appears to pass.

## Selected Repair Strategy

### Exact Bash 3.2 Expansion Idiom

The exact production expression is:

```bash
${array[@]+"${array[@]}"}
```

The outer `+` expansion omits its word when there is no array element. When an
element exists, the inner quoted expansion preserves every element as a
distinct word. The form is used directly at each consumption boundary:

```bash
list_contains "$needle" ${values[@]+"${values[@]}"}

for value in ${values[@]+"${values[@]}"}; do
  consume "$value"
done

copy=(${values[@]+"${values[@]}"})

format_result_list ${values[@]+"${values[@]}"}
```

The compatibility expression is intentionally not wrapped in another pair of
quotes. The inner `"${values[@]}"` owns element quoting; the outer conditional
owns zero-word omission.

### Cardinality Contract

| Array state | Words supplied | Required semantic effect |
| --- | ---: | --- |
| Unset or initialized empty | 0 | zero loop iterations, empty copy, or zero optional function arguments |
| One empty-string element | 1 | preserve one real empty element; never conflate it with zero elements |
| One nonempty element | 1 | preserve the value byte-for-byte as one argument |
| Multiple elements | N | preserve element boundaries and existing order; existing callees retain deduplication policy |

The repair changes no append statement. Existing `array+=("$value")` operations
still own first insertion, and existing `list_contains` calls still own
first-seen deduplication.

### Why No Helper Is Added

A helper invoked with a raw array expansion cannot help because Bash aborts
before helper entry. A helper accepting an array name would require Bash-4
namerefs, `eval`, or new global temporary state. Those options either violate
the Bash 3.2 baseline or add unsafe, unnecessary indirection.

The guarded call-site form is the smallest implementation that works for
function arguments, loops, array copies, and result serialization.

### All-Or-Nothing Repair Invariant

The accepted production transformation is indivisible:

- 40 occurrences in `bubbles/scripts/state-transition-guard.sh`;
- one occurrence in `bubbles/scripts/guards/planning-checks.sh`; and
- two occurrences in `bubbles/scripts/guards/control-plane-checks.sh`.

Implementation may edit these three files only after a valid new final-byte
RED. It must apply and review all 43 substitutions before running GREEN. If any
site cannot be matched exactly or any foreign hunk collides, implementation
must leave or restore all three files to their recorded pre-repair BUG-022
state and route the conflict. A 40-site main-guard repair, a one-module repair,
or any other subset is neither an intermediate deliverable nor a valid test
target.

## Complete Expansion Inventory

Line numbers below identify the live source observed during design
reconciliation. They are non-authoritative anchors; path, array name, ordinal,
and surrounding operation are the durable identity.

The accepted main-guard map has 40 occurrences. Thirty-nine have a valid
zero-cardinality path. The `transition_applicable_check_classes` formatter is
currently contract-nonempty, but it remains the fortieth accepted occurrence so
all five adjacent result-list fields use one serialization contract and the
existing regression inventory stays exact. It is not represented as an
observed zero-state defect.

### Main Guard: Result State And Serialization

| Current line | Array | Operation | Zero-state status |
| ---: | --- | --- | --- |
| 72 | `passed_gate_ids` | first passed-gate membership check | valid before first gate-tagged pass |
| 77 | `failed_gate_ids` | first failed-gate membership check | valid before first gate-tagged failure |
| 82 | `failed_check_ids` | first failed-check membership check | valid before first failed check |
| 124 | `transition_required_gate_ids` | PASS required-gate traversal | valid for a zero-required-gate contract |
| 128 | `passed_gate_ids` | effective passed-gate traversal | valid before any gate-tagged pass |
| 129 | `failed_gate_ids` | passed-gate exclusion membership | valid when no gate-tagged failure exists |
| 141 | `transition_applicable_check_classes` | `applicableCheckClasses` formatter | contract-nonempty consistency site |
| 142 | `transition_not_applicable_checks` | `notApplicableChecks` formatter | valid when every check applies |
| 143 | `effective_passed_gate_ids` | `passedGateIds` formatter | valid before an effective pass is retained |
| 144 | `failed_gate_ids` | `failedGateIds` formatter | valid on success and untagged failure paths |
| 145 | `failed_check_ids` | `failedChecks` formatter | valid on successful paths |
| 3458 | `failed_gate_ids` | final `G073` blocking-code lookup | valid for an untagged planning failure |

### Main Guard: Per-Scope Discovery And Analysis

In `per-scope-directory` layout, `scope_files=()` is valid discovery evidence
when no `scopes/NN-name/scope.md` exists. Each accepted occurrence must use the
guarded form so the guard reaches its existing missing-scope diagnostics.

| Current line | Operation |
| ---: | --- |
| 558 | build analysis units from discovered scopes |
| 563 | copy zero-or-more scopes to `scope_analysis_files` |
| 564 | populate fallback analysis labels |
| 594 | count Gherkin scenarios |
| 637 | verify per-scope reports |
| 1004 | count checked and unchecked DoD items |
| 1022 | print bounded unchecked-DoD diagnostics |
| 1056 | detect DoD format manipulation |
| 1115 | validate scope status vocabulary |
| 1167 | aggregate scope statuses |
| 1186 | check planning-status honesty |
| 1245 | compare `_index.md` and scope status |
| 1313 | detect phantom completed scopes |
| 1363 | detect SLA-sensitive scopes |
| 2142 | collect Check 8 test paths |
| 2351 | check DoD evidence presence |
| 2454 | scan scope template placeholders |
| 2627 | scan duplicate evidence |
| 2750 | discover referenced implementation files |
| 2974 | scan scope deferral-language violations |
| 3055 | scan scope environment-failure evidence |
| 3079 | collect evidence-similarity blocks |

All 22 rows transform `"${scope_files[@]}"` to
`${scope_files[@]+"${scope_files[@]}"}`. The raw loop currently near line 575
remains an explicit control because a positive `${#scope_files[@]}` check
dominates it.

### Main Guard: Per-Scope Report Discovery

When scope files exist but no per-scope `report.md` files exist,
`report_files=()` is valid. These five loops must perform zero iterations and
allow the existing zero-report diagnostic to execute.

| Current line | Operation |
| ---: | --- |
| 2464 | scan report template placeholders |
| 2510 | validate required report sections and evidence |
| 2712 | collect implementation-delta evidence |
| 3002 | scan report deferral-language violations |
| 3041 | scan report environment-failure evidence |

All five rows transform `"${report_files[@]}"` to
`${report_files[@]+"${report_files[@]}"}`.

### Main Guard: First Evidence Comparison

| Current line | Array | Operation |
| ---: | --- | --- |
| 2642 | `evidence_hashes` | compare the first real evidence hash with zero prior hashes |

The first block performs zero comparisons and then appends its real hash. No
sentinel or fabricated predecessor is permitted. Later hashes retain the
existing insertion order and duplicate comparison behavior.

### Sourced Production Modules

| Current path and line | Array occurrence | Same-shell consumer | Required transformation |
| --- | --- | --- | --- |
| `bubbles/scripts/guards/planning-checks.sh:201` | `scope_files` | Check 8D change-boundary loop | `${scope_files[@]+"${scope_files[@]}"}` |
| `bubbles/scripts/guards/control-plane-checks.sh:311` | `scope_files` | first argument group to `detect_red_green_ordering` | `${scope_files[@]+"${scope_files[@]}"}` |
| `bubbles/scripts/guards/control-plane-checks.sh:311` | `report_files` | second argument group to `detect_red_green_ordering` | `${report_files[@]+"${report_files[@]}"}` |

For an empty per-scope layout, the planning loop performs zero iterations. For
G060 ordering detection, the callee already accepts a variadic file list and
iterates `"$@"`; zero scope or report arguments therefore retain its existing
not-found result. The repair changes only the argument vector reaching the
callee.

### Explicit Raw Controls

The design-time generic scan found 52 raw array-expansion lines in the main
guard. The 40 accepted occurrences above are transformed. These remaining raw
uses are protected by positive counts or fixed nonempty invariants and remain
unchanged:

- `transition_resolver_args` at the contract resolver call;
- `scope_section_tmp_files` inside its positive-count cleanup branch;
- the positive-count `scope_files` loop near current line 575;
- fixed `required_files` and `required_headers` arrays;
- count-guarded `required_specialists`, `planning_required_agents`,
  `timestamps`, `intervals`, `test_files_in_plan`, and `impl_files` uses.

The production patch is targeted, not a repository-wide replacement. If
implementation discovers another genuinely zero-reachable raw expansion, it
must route that finding to `bubbles.design`; it may not silently broaden the
accepted set.

## Preserved Behavioral Contracts

### Zero Elements

- Empty membership inputs make `list_contains` inspect zero candidates and
  return its existing not-found status.
- Empty loops execute zero iterations.
- Empty copies create a zero-length destination array.
- `format_result_list` receives zero arguments and emits exactly `[]`.
- Missing scopes and reports produce the guard's existing findings and complete
  nonzero result, not a shell-generated `unbound variable` termination.
- An untagged planning failure retains `failedGateIds: []` and
  `blockingCode: PLANNING_GATE_FAILED`.

### One Element

- The first gate/check ID crosses the empty accumulator boundary once and is
  appended exactly once.
- One empty-string element remains one element.
- One scope, report, or evidence hash remains one argument with exact quoting.
- A `G073` gate remains sufficient to select the existing
  `SOURCE_EDIT_LOCKOUT` classification.

### Multiple Elements

- Existing encounter order is preserved.
- Existing `list_contains` behavior retains first-seen deduplication.
- Whitespace and empty strings remain within their original element boundary.
- Discovery order remains the order produced by existing sorted input.
- Existing failure count, gate attribution, check attribution, diagnostics,
  result vocabulary, and exit status remain unchanged.

## Data, API, UI, And Configuration Impact

There is no data model, storage, migration, HTTP endpoint, UI, authorization,
feature flag, configuration, or environment-variable change. The guard's CLI,
15-field ordered result block, and exit classes remain its public contract.

## Security And Failure Handling

- `set -euo pipefail` remains active throughout the production process.
- No missing required value receives a default or fallback.
- No source finding, failed check, failed gate, stderr diagnostic, or nonzero
  exit is suppressed.
- The repair performs no dynamic evaluation, variable-name lookup, subprocess
  parsing, or execution of artifact content.
- No bypass flag, compatibility switch, test-only branch, or alternate success
  path is introduced.

The existing stdout/stderr diagnostics, structured result, failure count, and
process exit remain the observability surface. There is no service telemetry or
new monitoring plane.

## Historical RED And Freshness Contract

The report preserves a historical stock-Bash-3.2 RED produced by test SHA-256
`c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`.
Implementation preflight later observed physical `test_29` SHA-256
`4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`.

The historical transcript remains useful evidence that the pre-repair defect
was executable and that a 40-plus-three inventory was once exercised. It is
not current final-byte RED, does not authorize a source edit, and cannot be
reused as GREEN provenance. No claim in this design upgrades that evidence.

After planning reconciliation, `bubbles.test` must freeze the then-current
complete regression bytes, record their SHA-256, and execute those exact bytes
against unchanged production. Valid RED requires all planned canonical,
control, family-mutant, and site-mutant runs to execute; the nonzero outcome
must be caused only by accepted raw empty-array sites. Any later test-byte drift
invalidates that RED and repeats the same gate.

## Testing And Validation Strategy

### Production Fixture Matrix

| Behavior family | Required executable proof |
| --- | --- |
| empty result lists | complete PASS, FAIL, and BLOCKED envelopes use exact `[]` fields without nounset abort |
| first accumulator element | first pass gate, failed gate, and failed check append exactly once |
| multiple accumulator elements | first-seen order, deduplication, counts, attribution, and exits remain exact |
| zero scopes | existing missing-scope finding and complete failure envelope are emitted |
| zero reports | existing missing-report and zero-report findings are emitted |
| first evidence hash | first hash appends after zero comparisons; only a later identical hash is rejected |
| untagged versus `G073` failure | `PLANNING_GATE_FAILED` and `SOURCE_EDIT_LOCKOUT` remain distinct |
| sourced planning loop | zero scopes perform zero Check 8D iterations without abort |
| sourced G060 call | zero scope/report argument groups reach the existing detector contract without abort |

### Inventory And Mutation Proof

The persistent regression must:

1. require exactly 40 guarded accepted occurrences in the main guard, one raw
   positive-count `scope_files` control, and zero inventory errors;
2. require exactly three guarded module occurrences and zero module inventory
   errors;
3. restore one raw site at a time in disposable copies and prove the intended
   behavior family rejects each mutant;
4. include independent mutants for planning `scope_files`, control-plane
   `scope_files`, and control-plane `report_files`; and
5. prove each mutation made exactly one intended substitution.

Static inventory is necessary but cannot replace production-path behavior.
Family fixtures are necessary but cannot replace per-site inventory mutants.

### Runtime And Canary Order

Required validation order after the new RED is:

1. all 43 production substitutions in one bounded implementation phase;
2. identical-byte stock macOS `/bin/bash` 3.2 GREEN;
3. newer macOS Bash and Linux Bash runs using the same test and production
   bytes;
4. unchanged BUG-019 `test_26` compatibility run;
5. managed state-transition selftest and structured-result consumer canary;
6. regression quality, syntax, portability, artifact, freshness, G094, and
   traceability checks;
7. install-provenance validation for all three managed production files and
   source-only `test_29`;
8. full framework validation; and
9. release-owner manifest generation and release check.

No modern-Bash run substitutes for actual Bash 3.2 evidence. Design-phase
checks prove planning coherence only; they are not RED, GREEN, release, or
certification evidence.

### Test Isolation

All regression fixtures and mutants live under a unique temporary parent and
are removed on normal exit and signals. Tests invoke the real production guard
and sourced modules, not copied helper logic. They do not mutate downstream
repositories, shared baseline state, monitoring, backup paths, train config,
deployment manifests, secret stores, or generated release files.

## Consumer And Provenance Impact

| Consumer or surface | Required effect |
| --- | --- |
| direct guard callers | unchanged command, diagnostics, result schema, and exit vocabulary; valid empty paths no longer abort |
| `bubbles/scripts/cli.sh`, audit flows, and MCP wrappers | receive one complete normal result envelope instead of truncated shell output |
| `guards/control-plane-checks.sh` and `guards/planning-checks.sh` | remain sourced production fragments in the same shell; no new API or invocation mode |
| `detect_red_green_ordering` | receives the same ordered files when present and zero optional files when absent; its implementation is unchanged |
| BUG-019 | Check 8 parser and `test_26` bytes remain unchanged and can advance beyond the BUG-022 boundary |
| per-scope packet authors | malformed empty layouts receive intended governance findings rather than an interpreter abort |
| downstream installations | receive byte-identical canonical guard and module files through supported install/upgrade tooling only |

All three production files are install-managed. The current release manifest
already records both module paths, and `install.sh` copies the managed
`bubbles/scripts/guards/` directory. The installer algorithm does not change.

`bubbles.test` must extend install-provenance coverage so the main guard,
`guards/planning-checks.sh`, and `guards/control-plane-checks.sh` are each
verified byte-identical after installation, while `test_29` remains source-only
and release-recorded. After source, tests, registration, and provenance settle,
only `bubbles.releases` regenerates `bubbles/release-manifest.json` and runs the
release check. No implementation or test owner hand-edits generated identity.

Downstream repositories are read-only during canonical work. They receive the
coherent release through the supported installer/upgrade path; direct edits to
installed `.github/bubbles/**` files are forbidden.

## Rollout And Rollback

Before implementation, record current hashes for all three production files,
the protected BUG-019 Check 8 region, BUG-019 `test_26`, and concurrent foreign
hunks. Apply a path-scoped BUG-022 patch only after valid RED, then verify that
the diff contains exactly the 43 accepted substitutions and no excluded bytes.

Pre-release rollback reverses the complete BUG-022 patch across all three
production files against the recorded base. It must not restore any file from
`HEAD`, because the worktree contains concurrent ownership. If a base hash or
hunk no longer matches, stop and route the collision rather than guessing.

Release rollback selects the prior coherent validated release, regenerates or
selects its release identity through release-owned tooling, runs release
validation, and has downstream consumers install that release through the
supported path. Source, module, regression registration, provenance assertions,
and manifest identity must move together. Rolling back only one expansion or
one source file is forbidden and reintroduces an unsupported mixed state.

There is no data or configuration migration and no state-conversion rollback.

## Exact Ownership And Handoff

### Design-Owned Change Boundary

This invocation changes only:

- `improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md`.

It does not change `state.json`, `scopes.md`, `test-plan.json`,
`scenario-manifest.json`, `report.md`, production code, tests, release metadata,
BUG-019/020/021, or downstream repositories.

### Delivery Ownership

| Surface | Accepted responsibility | Owner |
| --- | --- | --- |
| `bubbles/scripts/state-transition-guard.sh` | exactly 40 accepted substitutions | `bubbles.implement` after valid new RED |
| `bubbles/scripts/guards/planning-checks.sh` | exactly one accepted substitution | `bubbles.implement` after valid new RED |
| `bubbles/scripts/guards/control-plane-checks.sh` | exactly two accepted substitutions | `bubbles.implement` after valid new RED |
| `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | final-byte RED/GREEN, 43-site inventory, fixtures, and mutants | `bubbles.test` |
| managed selftest, framework registration, and install-provenance selftest | focused canaries and managed/source-only assertions | `bubbles.test` |
| `scopes.md`, `test-plan.json`, and related planning handoff | synchronized executable boundary and DoD | `bubbles.plan` |
| `report.md` evidence | current evidence written only by the executing owner | execution owner |
| `bubbles/release-manifest.json` | generated identity after settled inputs | `bubbles.releases` |
| certification and terminal status | independent completion decision | `bubbles.validate` |

### Exact Next-Owner Planning Handoff

`nextRequiredOwner` is `bubbles.plan`.

Planning must reconcile the active scope and machine-readable Test Plan so they:

1. authorize `bubbles.implement` for exactly the three production files and 43
   all-or-nothing substitutions defined here;
2. add the three sourced-module sites to the change boundary, implementation
   sequence, protected inventory, adversarial mutations, install provenance,
   rollback, and DoD;
3. retain the 40-main-plus-three-module distinction and the single
   contract-nonempty serializer consistency classification;
4. correct the open regression-quality command to target the physical
   `test_29` path rather than the feature directory;
5. preserve the blocked nonterminal state and make no RED, GREEN, or completion
   claim; and
6. route next to `bubbles.test` for a new exact-byte RED, after which
   `bubbles.implement` may resume only if that RED is valid and unchanged.

No direct design-to-implementation route is authorized.

## Alternatives And Tradeoffs

| Alternative | Decision | Reason |
| --- | --- | --- |
| guarded call-site expansion in all three files | selected | preserves true zero arguments and quoted nonempty elements on Bash 3.2 without new abstraction |
| main-guard-only repair | rejected | leaves three same-shell production consumers able to abort and violates full finding closure |
| count guard around every call | rejected | duplicates control flow and handles loops, copies, and variadic calls inconsistently |
| helper accepting expanded values | rejected | nounset abort occurs before helper entry |
| helper accepting an array name | rejected | requires Bash-4 nameref, `eval`, or new global state |
| `${array[@]:-}` or `${array[@]-}` | rejected | can conflate zero elements with one empty element |
| sentinel value | rejected | fabricates list content and changes counts, formatting, and attribution |
| `set +u` around affected code | rejected | weakens strict mode and hides unrelated defects |
| require Bash 4+ | rejected | violates the supported stock macOS runtime |
| transform every raw array expansion | rejected | expands the patch into proven count-guarded or fixed-nonempty controls |

## Complexity Tracking

None - simplest viable approach used. One Bash 3.2 expression is applied at
the exact same-shell consumption boundaries; the broader validation matrix is
required by the guard's high fan-out and masked zero-state paths, not by a new
production abstraction.

### Single-Implementation Justification

This is one compatibility bug inside the existing state-transition guard
capability. There is no second provider, adapter, strategy, screen, service, or
result implementation. A compatibility library would duplicate authority and
cannot repair expansion-before-call behavior more safely than the selected
form.

## Risks And Open Questions

Open questions: none.

Bounded risks are:

- a mapped site can move during concurrent work; owners match path, array,
  ordinal, and local operation rather than trusting a line number;
- an edit can accidentally touch a protected or count-guarded control; exact
  inventory, path-scoped diff, and protected hashes reject that change;
- one empty-string element can be collapsed into zero values; the cardinality
  fixture rejects that mutation;
- modern Bash can conceal the defect; stock Bash 3.2 remains non-substitutable;
- test bytes can drift again; any drift invalidates RED before source work; and
- release generation can absorb unsettled concurrent bytes; release ownership
  waits for stable source, test, registration, and provenance inputs.

The following older duplicate is also preserved only as inactive collision
history.

The former main-guard-only production boundary is superseded. The two sourced
modules execute under the same nounset shell and are part of the accepted
repair unit.

The RED tied to test SHA-256
`c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`
is retained only as historical reproduction context after physical test-byte
drift. It is not active source-edit authorization.

# Bug Fix Design: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` starts in strict mode and stores
gate IDs, check IDs, discovered scopes, discovered reports, and evidence hashes
in indexed arrays. Several valid paths expand those arrays while they are still
empty. Stock macOS Bash 3.2 treats quoted `${array[@]}` on that state as an
unbound variable under `set -u`, while newer Bash expands it to zero arguments.

BUG-019's parser-aware reproduction proves the failure occurs after Check 8
has accepted complete compound MJS paths. BUG-020's earlier failure occurred
while sourcing `fun-mode.sh`, before Check 8. The two defects therefore have
different controlling paths and different source boundaries.

### Target State

Every semantically valid empty list in the production guard expands to zero
arguments under Bash 3.2 and newer Bash. One element, an empty-string element,
multiple elements, ordering, deduplication, diagnostics, counters, structured
result fields, and process exits remain unchanged.

The guard keeps `set -euo pipefail`. It emits exactly one complete ordered
`TRANSITION_GUARD_RESULT_V1` for pass, fail, and blocked outcomes. Empty list
fields remain exactly `[]`; no sentinel, shell-option suppression, alternate
result formatter, or shell-version branch is introduced.

### Patterns to Follow

- Keep the repair inside the existing indexed-array consumers in
  `bubbles/scripts/state-transition-guard.sh`.
- Use the Bash-3.2-safe guarded expansion
  `${array[@]+"${array[@]}"}` wherever zero elements are valid.
- Preserve the existing `list_contains`, `format_result_list`, record helpers,
  scope/report discovery, Check 8 parser, and result schema as authorities.
- Exercise the real production guard in unique disposable repositories.
- Preserve managed-source and source-only-test provenance through the existing
  installer and release machinery.

### Patterns to Avoid

- Do not disable nounset globally, locally, or in a subshell.
- Do not add dummy values, sentinels, default IDs, or empty string arguments.
- Do not use `eval`, namerefs, associative arrays, indirect variable expansion,
  or a second list abstraction to centralize array access.
- Do not convert failures to success with `|| true`, hidden stderr, or a
  test-only guard path.
- Do not edit BUG-019 Check 8 parsing, BUG-020 fun mode, BUG-021 timeout work,
  generated release metadata, or downstream installed copies in this repair.

### Resolved Decisions

- Select one mechanically consistent guarded-expansion pattern at each
  zero-reachable call site.
- Keep count-guarded and fixed-nonempty array expansions as explicit controls.
- Protect all five structured list fields even when one field currently has a
  nonempty profile invariant, preserving one serialization rule.
- Require a final-byte production-path RED before any source edit.
- Require independent mutations for result state, scope discovery, report
  discovery, evidence comparison, and final failed-gate classification.
- Keep the persistent regression source-only and the guard/selftest managed.

### Open Questions

None. Planning owns the final row structure and test handoff; the technical
repair strategy and behavior boundary are closed by this design.

## Purpose And Scope

BUG-022 repairs Bash portability at the state-transition guard's existing list
boundary. The behavior applies whenever the guard has zero, one, or multiple
values in an indexed array and must continue normal control flow or serialize
the result.

The production change is a surgical compatibility rewrite of zero-reachable
array expansions. It introduces no new capability, public option, environment
variable, workflow mode, configuration key, dependency, result field, or
persisted state. It does not change what any transition check decides.

## Root Cause And Non-Collision Model

### Controlling Production Path

The affected path is:

```text
state-transition-guard.sh
  -> set -euo pipefail
  -> resolve contract and initialize indexed arrays
  -> run numbered checks
  -> record first gate/check ID OR traverse discovered artifacts
  -> expand a valid zero-element indexed array
  -> Bash 3.2 nounset aborts before normal result emission
```

The direct reproductions are the first membership checks in
`record_passed_gate` and `record_failed_check`. The same shell rule applies to
the masked result-format, discovery, evidence, and final-classification sites.

### Falsifiable Root-Cause Model

The root-cause model predicts all of the following:

1. Raw `"${array[@]}"` aborts under Bash 3.2 nounset when the array is empty.
2. `${array[@]+"${array[@]}"}` supplies zero arguments for unset or initialized
   empty arrays.
3. The guarded form supplies one argument for one empty-string element.
4. The guarded form preserves all multi-element values and order.
5. The guarded form behaves identically on Bash 4+.

A design-time probe on the current host exercised function arguments, loops,
array copies, empty-string elements, and list formatting under Bash 3.2.57 and
Bash 5.3.15. Both interpreters produced zero arguments for empty/unset arrays,
one argument for one empty string, and the same ordered three-element result.

The model is falsified if a final production-path fixture reaches one of the
accepted zero states and still aborts, if an empty string is dropped from a
nonempty array, or if Bash 4+ output differs after the source change.

### Separation From BUG-019

BUG-019 owns Check 8 candidate parsing. Its corrected reproduction reaches
Check 8 and accepts `.spec.mjs`, `.test.mjs`, ordinary suffixes, and the
all-invalid branch before BUG-022 aborts. BUG-022 must leave the Check 8 helper,
suffix allowlist, Test Plan extraction, diagnostics, and `test_26` bytes
unchanged. A post-repair BUG-019 system-Bash run must return `38/38` without an
expectation change.

### Separation From BUG-020 And BUG-021

BUG-020's reporter aborts in `fun-mode.sh` before the guard banner and before
Check 8. BUG-022 begins only after source initialization succeeds and an empty
result/discovery array is expanded. `fun-mode.sh` is therefore excluded.

BUG-021 owns two raw timeout registrations in `framework-validate.sh` and the
planned `test_28` source-only regression. BUG-022 may add only a nonoverlapping
regression registration after ownership coordination; it may not alter either
timeout call or BUG-021's planned behavior.

## Selected Compatibility Architecture

### Guarded Expansion Contract

At every accepted zero-reachable site, replace the raw expansion with:

```bash
"${items[@]+"${items[@]}"}"
```

The outer `+` expansion emits its word only when the array has at least one
element. The inner quoted expansion then preserves each element as a distinct
argument. The contract works in each production context:

```bash
for item in "${items[@]+"${items[@]}"}"; do
  consume "$item"
done

target=("${items[@]+"${items[@]}"}")

consume_many "${items[@]+"${items[@]}"}"
```

An empty array therefore creates zero loop iterations, a zero-length copy, and
zero function arguments. It does not create one empty argument. A nonempty
array preserves empty-string elements, whitespace, order, and duplicates.

### Why The Pattern Stays At Call Sites

Bash 3.2 has no nameref. A generic helper that accepts an array name would need
`eval`, indirect code generation, or global temporary state. Those mechanisms
increase security and correctness risk and violate the single-authority
boundary. A helper that accepts expanded values cannot protect the expansion
that occurs before the helper is called.

The guarded call-site form is therefore the smallest strategy that handles
loops, copies, membership calls, and serialization without changing any
consumer API. A short source comment may document the Bash 3.2 rule once near
the result arrays; duplicated explanatory comments at every call are not
required.

## Complete Repair Inventory

Line references below describe the current shared dirty source identified at
SHA-256 `09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a`.
Implementation must re-resolve the local context before editing and preserve
all concurrent non-BUG-022 bytes.

### Result Accumulation And Serialization

| Current sites | Array | Valid zero state | Required behavior |
| --- | --- | --- | --- |
| 72 | `passed_gate_ids` | before the first gate-tagged pass | membership receives zero prior IDs; first ID appends once |
| 77 | `failed_gate_ids` | before the first gate-tagged failure | membership receives zero prior IDs; first ID appends once |
| 82 | `failed_check_ids` | before the first recorded failed check | membership receives zero prior IDs; first ID appends once |
| 124 | `transition_required_gate_ids` | a schema-valid contract can require zero gates | PASS records zero required IDs without abort |
| 128 | `passed_gate_ids` | no gate-tagged pass has occurred | effective pass filtering performs zero iterations |
| 129 | `failed_gate_ids` | passes exist and no gate-tagged failure exists | each passed gate survives the zero-item exclusion set |
| 141-145 | all five result list arrays | one or more list fields may be empty | formatter receives zero or more exact values and emits bracket lists |

The five result fields are `applicableCheckClasses`, `notApplicableChecks`,
`passedGateIds`, `failedGateIds`, and `failedChecks`. Applying the guarded form
uniformly to all five keeps one serialization contract even though
`transition_applicable_check_classes` is nonempty for every valid profile.

### Per-Scope Discovery

In `per-scope-directory` layout, `scope_files=()` is valid input evidence when
no `scopes/NN-name/scope.md` exists. The following unguarded sites can observe
that state and must use the guarded expansion:

```text
558, 563, 564, 594, 637, 1004, 1022, 1056, 1115, 1167, 1186,
1245, 1313, 1363, 2142, 2351, 2454, 2627, 2750, 2974, 3055, 3079
```

Line 563 is an array copy; the other sites are loops. The existing count checks
and diagnostics remain unchanged. The single-file layout continues to add the
literal `scopes.md` path even when that file is absent, so it does not create
the same zero-cardinality state.

### Per-Scope Report Discovery

When scope files exist but no per-scope `report.md` exists, `report_files=()`
is valid discovery evidence. The loops currently at 2464, 2510, 2712, 3002,
and 3041 must perform zero iterations. The existing explicit Check 11 branch
must then record `Check-11-structure` and print
`No report.md files were resolved for this feature`.

### First Evidence Comparison

The duplicate-evidence scan initializes `evidence_hashes=()`. At the first
nonempty evidence block, the loop currently at 2642 must compare against zero
prior hashes, append the first hash, and continue. A second identical hash must
retain the existing duplicate finding; a distinct hash must append in order.

### Final Failed-Gate Lookup

On a planning-maturity failure with no gate-tagged failure,
`failed_gate_ids=()` is valid. The lookup currently at 3458 must call
`list_contains G073` with zero list arguments, return false, and leave
`blockingCode: PLANNING_GATE_FAILED`. When `G073` is present, the existing
`SOURCE_EDIT_LOCKOUT` classification remains unchanged.

### Count-Guarded And Nonempty Controls

These arrays do not require compatibility edits because a positive count guard
dominates element expansion or the valid contract requires at least one value:

- `transition_resolver_args`
- `scope_section_tmp_files`
- `required_files`
- `required_specialists`
- `planning_required_agents`
- `timestamps`
# Bug Fix Design: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` runs with `set -euo pipefail` and
uses quoted indexed-array expansions for accumulators, discovery lists, result
formatting, evidence comparison, and final failure classification. Stock macOS
Bash 3.2 aborts when any of those arrays is initialized but empty and expanded
as `"${array[@]}"`.

The current dirty guard already contains concurrent BUG-019 Check 8 parser
bytes and BUG-012 tail-gate bytes. At design time the full file has SHA-256
`09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a`;
the marker-bounded BUG-019 Check 8 region is 6,534 bytes with SHA-256
`31804b803b8aad2b7889667dcf69de7c740988ae5cab4924ceac63444ac2711f`.

### Target State

Every inventoried zero-sensitive indexed-array expansion uses the Bash
3.2-compatible conditional expansion `${array[@]+"${array[@]}"}`. It produces
zero arguments for an empty array and preserves one or multiple quoted element
boundaries and ordering when values exist.

The guard retains strict mode, its result schema, diagnostics, failure counts,
deduplication, gate attribution, and exit behavior. Missing scope/report
artifacts reach their existing diagnostics, the first evidence hash is appended
without a fictional predecessor, and an untagged failure emits a normal result
with `failedGateIds: []`.

### Patterns to Follow

- Apply one mechanical conditional-expansion form at every site listed in
  [Complete Expansion Map](#complete-expansion-map).
- Keep `list_contains`, `format_result_list`, array initialization, append
  operations, loop bodies, result field order, and diagnostic text unchanged.
- Use complete disposable packets and the real production guard, following the
  process-fixture approach in
  `tests/regression/test_26_state_transition_spec_mjs_path.sh`.
- Prove source containment with exact inventory checks and the protected Check 8
  hash before and after the repair.
- Keep the persistent regression source-only and propagate managed bytes through
  canonical install and release provenance.

### Patterns to Avoid

- Do not use `set +u`, a subshell with weaker options, `|| true`, stderr
  suppression, or a global shell-option change.
- Do not add sentinels, dummy gate IDs, fabricated prior hashes, or placeholder
  scope/report paths.
- Do not use `eval`, namerefs, associative arrays, indirect variable-name
  expansion, or a second result/list abstraction.
- Do not require Homebrew Bash or select behavior by `uname` or Bash version.
- Do not edit the BUG-019 Check 8 parser, BUG-012 tail gates, BUG-020 fun mode,
  BUG-021 timeout work, shared registry, generated release metadata, or
  downstream installed copies outside their owning phases.

### Resolved Decisions

- Select the local conditional-expansion idiom, not a helper API.
- Transform every zero-sensitive site, including currently masked paths.
- Pair behavioral zero/one/multiple fixtures with an exact raw-expansion
  inventory check.
- Require independent temporary-worktree mutants for each behavior family.
- Require actual Bash 3.2, newer macOS Bash, and Linux Bash execution lanes.
- Preserve the BUG-019 parser region byte-for-byte and route planning next.

### Open Questions

None. `bubbles.plan` owns the synchronized executable scope, final test
numbering, Test Plan, DoD, and machine-readable handoff.

## Purpose and Scope

This repair implements `BR-022-001` through `BR-022-010` without broadening the
state-transition guard or changing its governance policy. The user-observable
capability is unchanged: the guard evaluates one feature packet, prints its
normal diagnostics and `TRANSITION_GUARD_RESULT_V1` envelope, and exits with the
truthful result.

The only production behavior change is that a semantically valid empty indexed
array no longer terminates stock Bash 3.2 before that contract can execute. The
repair covers all zero-sensitive sites inventoried in `bug.md`, not just the
two lines reached by the BUG-019 reproduction.

No data model, API, UI, authorization, configuration key, feature flag,
dependency, or deployment topology changes.

## Root Cause and Falsifiable Boundary

### Controlling Shell Behavior

The guard initializes arrays with `array=()` and later expands them as
`"${array[@]}"`. With nounset enabled, Bash 3.2 treats that empty indexed-array
element expansion as an unbound variable. Newer Bash produces zero arguments,
which is the behavior the current control flow assumes.

The earliest observed failures are:

```text
record_passed_gate
  -> list_contains "$gate_id" "${passed_gate_ids[@]}"
  -> Bash 3.2 nounset abort before first append

record_failed_check
  -> list_contains "$check_id" "${failed_check_ids[@]}"
  -> Bash 3.2 nounset abort before first append
```

Those failures mask later valid-empty paths in result formatting, per-scope and
per-report discovery, first evidence comparison, and final planning-failure
classification. The affected values are lists, so zero elements must mean zero
arguments or zero loop iterations, not one empty string.

### Falsifiable Design Hypothesis

If every inventoried zero-sensitive expansion is changed from
`"${array[@]}"` to `${array[@]+"${array[@]}"}`, then stock Bash 3.2 will:

1. pass no arguments and execute no loop body for an empty array;
2. preserve each nonempty element as one quoted argument, including whitespace;
3. preserve array order and duplicates before existing deduplication logic;
4. allow the existing formatter to emit `[]`; and
5. reach the existing diagnostics and result envelope without changing their
   policy semantics.

The hypothesis is disproved if any valid empty path still aborts, an empty list
becomes one empty argument, an element splits, ordering changes, a duplicate is
handled differently, a missing artifact no longer blocks, an untagged failure
does not emit `failedGateIds: []`, or the BUG-019 Check 8 hash changes.

The selected syntax was executed under `/bin/bash` 3.2.57 with strict mode:
zero arguments, a single `alpha beta` element, and ordered duplicate values all
retained their required semantics. That discriminator validates the language
primitive only; it is not production GREEN evidence.

## Selected Repair Strategy

### Conditional Expansion Contract

The exact production form is:

```bash
${array[@]+"${array[@]}"}
```

For an empty Bash 3.2 indexed array, the outer `+` parameter operation omits its
word entirely, so the caller receives zero arguments. When the array has
elements, the word is the inner quoted `"${array[@]}"`, so each element remains
one argument in original order.

Use the same form in each syntactic context:

```bash
list_contains "$needle" ${values[@]+"${values[@]}"}
for value in ${values[@]+"${values[@]}"}; do
  consume "$value"
done
copy=(${values[@]+"${values[@]}"})
printf '%s\n' "$(format_result_list ${values[@]+"${values[@]}"})"
```

No append statement changes. Existing `array+=("$value")` operations continue
to own first insertion. Existing `list_contains` continues to own
deduplication; the compatibility form only controls the argument vector passed
to it.

### Why No Central Helper

A value helper cannot repair the call boundary because invoking it as
`helper "${array[@]}"` triggers the Bash 3.2 abort before the helper starts.
Passing an array variable name would require a Bash-4 nameref, `eval`, or a new
indirection protocol, all forbidden or disproportionate here. A helper that
prints values would also lose safe argument boundaries or require command
substitution and reparsing.

The conditional form is therefore the smallest single strategy that preserves
true zero-argument behavior at the expansion site. Mechanical consistency and
an exact source inventory prevent per-call semantic drift.

### Single-Implementation Justification

This is a narrow compatibility repair inside the existing state-transition
guard. One Bash expression supports the declared Bash 3.2 baseline and newer
Bash without a provider, adapter, alternate formatter, or version-selected
implementation. A new list capability would add indirection while failing to
solve the expansion-before-call boundary.

## Complete Expansion Map

Line numbers identify the current dirty source at design time. They are review
anchors, not durable identifiers; implementation must match array and context
as well as line number and must stop if the surrounding bytes have changed.

### Result State, Construction, and Final Classification

| Current line | Current affected expansion | Context | Required transformation |
| ---: | --- | --- | --- |
| 72 | `"${passed_gate_ids[@]}"` | first passed-gate membership check | `${passed_gate_ids[@]+"${passed_gate_ids[@]}"}` |
| 77 | `"${failed_gate_ids[@]}"` | first failed-gate membership check | `${failed_gate_ids[@]+"${failed_gate_ids[@]}"}` |
| 82 | `"${failed_check_ids[@]}"` | first failed-check membership check | `${failed_check_ids[@]+"${failed_check_ids[@]}"}` |
| 124 | `"${transition_required_gate_ids[@]}"` | PASS required-gate loop | `${transition_required_gate_ids[@]+"${transition_required_gate_ids[@]}"}` |
| 128 | `"${passed_gate_ids[@]}"` | effective passed-gate loop | `${passed_gate_ids[@]+"${passed_gate_ids[@]}"}` |
| 129 | `"${failed_gate_ids[@]}"` | failed-gate filter membership | `${failed_gate_ids[@]+"${failed_gate_ids[@]}"}` |
| 142 | `"${transition_not_applicable_checks[@]}"` | `notApplicableChecks` formatter | `${transition_not_applicable_checks[@]+"${transition_not_applicable_checks[@]}"}` |
| 143 | `"${effective_passed_gate_ids[@]}"` | `passedGateIds` formatter | `${effective_passed_gate_ids[@]+"${effective_passed_gate_ids[@]}"}` |
| 144 | `"${failed_gate_ids[@]}"` | `failedGateIds` formatter | `${failed_gate_ids[@]+"${failed_gate_ids[@]}"}` |
| 145 | `"${failed_check_ids[@]}"` | `failedChecks` formatter | `${failed_check_ids[@]+"${failed_check_ids[@]}"}` |
| 3458 | `"${failed_gate_ids[@]}"` | planning `G073`/`SOURCE_EDIT_LOCKOUT` lookup | `${failed_gate_ids[@]+"${failed_gate_ids[@]}"}` |

`transition_applicable_check_classes` at current line 141 remains a deliberate
control. Contract resolution populates it for every valid audit profile, so it
is not a valid zero-state site. Count-only checks at current lines 3452 and
elsewhere are Bash 3.2-safe and remain unchanged.

### Per-Scope Discovery and Analysis

Every row below receives the same conditional expansion. Loop bodies and the
fallback condition around the current line 563 copy remain unchanged.

| Current line | Operation | Required expansion |
| ---: | --- | --- |
| 558 | build analysis units from discovered scopes | `${scope_files[@]+"${scope_files[@]}"}` |
| 563 | copy zero-or-more scopes to `scope_analysis_files` | `${scope_files[@]+"${scope_files[@]}"}` |
| 564 | populate fallback analysis labels | `${scope_files[@]+"${scope_files[@]}"}` |
| 594 | count Gherkin scenarios | `${scope_files[@]+"${scope_files[@]}"}` |
| 637 | verify per-scope reports | `${scope_files[@]+"${scope_files[@]}"}` |
| 1004 | count checked and unchecked DoD items | `${scope_files[@]+"${scope_files[@]}"}` |
| 1022 | print bounded unchecked-DoD diagnostics | `${scope_files[@]+"${scope_files[@]}"}` |
| 1056 | detect DoD format manipulation | `${scope_files[@]+"${scope_files[@]}"}` |
| 1115 | validate scope status vocabulary | `${scope_files[@]+"${scope_files[@]}"}` |
| 1167 | aggregate scope statuses | `${scope_files[@]+"${scope_files[@]}"}` |
| 1186 | check planning status honesty | `${scope_files[@]+"${scope_files[@]}"}` |
| 1245 | compare `_index.md` and scope status | `${scope_files[@]+"${scope_files[@]}"}` |
| 1313 | detect phantom completed scopes | `${scope_files[@]+"${scope_files[@]}"}` |
| 1363 | detect SLA-sensitive scopes | `${scope_files[@]+"${scope_files[@]}"}` |
| 2142 | collect Check 8 test paths | `${scope_files[@]+"${scope_files[@]}"}` |
| 2351 | check DoD evidence presence | `${scope_files[@]+"${scope_files[@]}"}` |
| 2454 | scan scope template placeholders | `${scope_files[@]+"${scope_files[@]}"}` |
| 2627 | scan duplicate evidence | `${scope_files[@]+"${scope_files[@]}"}` |
| 2750 | discover referenced implementation files | `${scope_files[@]+"${scope_files[@]}"}` |
| 2974 | scan scope deferral language | `${scope_files[@]+"${scope_files[@]}"}` |
| 3055 | scan scope environment-failure evidence | `${scope_files[@]+"${scope_files[@]}"}` |
| 3079 | collect evidence-similarity blocks | `${scope_files[@]+"${scope_files[@]}"}` |

The positive-count-protected loop at current line 575 and count-only uses at
570-571, 630-631, and 647 remain controls. They must not be rewritten merely
for visual uniformity.

### Per-Scope Report Discovery

| Current line | Operation | Required expansion |
| ---: | --- | --- |
| 2464 | scan report template placeholders | `${report_files[@]+"${report_files[@]}"}` |
| 2510 | validate required report sections and evidence | `${report_files[@]+"${report_files[@]}"}` |
| 2712 | collect implementation-delta evidence | `${report_files[@]+"${report_files[@]}"}` |
| 3002 | scan report deferral language | `${report_files[@]+"${report_files[@]}"}` |
| 3041 | scan report environment-failure evidence | `${report_files[@]+"${report_files[@]}"}` |

The count-only zero-report diagnostic at current line 2479 remains unchanged.
After the loop repair, an empty report list reaches that diagnostic instead of
aborting before it.

### First Evidence Comparison

| Current line | Operation | Required expansion |
| ---: | --- | --- |
| 2642 | compare a completed evidence block with prior hashes | `${evidence_hashes[@]+"${evidence_hashes[@]}"}` |

On the first evidence block, the loop executes zero times and then appends the
real hash. No empty hash, sentinel hash, copied fixture hash, or pre-seeded
comparison value is allowed. The second and later blocks compare against real
previous hashes in insertion order.

### Inventory Completion Rule

The persistent regression must assert both sides of the inventory:

1. every row above contains the selected conditional expansion; and
2. no raw `"${name[@]}"` expansion remains for
   `passed_gate_ids`, `failed_gate_ids`, `failed_check_ids`,
   `transition_required_gate_ids`, `transition_not_applicable_checks`,
   `effective_passed_gate_ids`, `scope_files`, `report_files`, or
   `evidence_hashes` outside a proven positive-count/nonempty control.

The checker must report array name and source line for any mismatch. It may not
silently accept a changed inventory count. A new zero-sensitive site discovered
during implementation is a design finding and requires owner reconciliation,
not an unplanned broad rewrite.

## Preserved Behavioral Contracts

### Zero Elements

- Empty membership inputs make `list_contains` inspect zero candidates and
  return its existing not-found status, allowing the first append.
- Empty loops execute zero iterations.
- Empty copies create an empty destination array.
- `format_result_list` receives zero arguments and emits exactly `[]`.
- No fabricated element appears in counts, messages, or structured fields.

### One and Multiple Elements

- A value containing whitespace remains one argument.
- Existing append order is preserved.
- Existing `list_contains` logic continues to suppress repeated gate/check IDs
  while preserving first-seen order.
- Discovery arrays continue to retain the order produced by their existing
  sorted input.
- Evidence hashes retain encounter order and duplicate comparison behavior.

### Missing Scope and Report Diagnostics

For a selected `per-scope-directory` layout with no
`scopes/NN-name/scope.md`, every scope loop and the fallback copy perform zero
work. Check 1 then emits the existing
`Per-scope layout requires at least one scopes/NN-name/scope.md file` finding;
later structural checks may add their normal findings, and the guard emits one
complete failure envelope.

When scope files exist but per-scope reports do not, scope-driven Check 1 emits
the existing `Missing scope report` findings. Report loops perform zero work,
the existing zero-report check records `Check-11-structure`, and final result
emission remains normal. The compatibility repair must not create report paths
or skip either diagnostic.

### First Evidence Hash

One real evidence block produces one hash append after zero comparisons. Two
identical real blocks compare the second hash with the first and preserve the
existing duplicate-evidence failure. Two distinct blocks produce two stored
hashes and no duplicate finding.

### Zero Gate IDs and Failure Envelopes

An untagged planning failure may have nonempty `failed_check_ids` and empty
`failed_gate_ids`. The final `G073` lookup inspects zero gate IDs, leaves
`transition_blocking_code=PLANNING_GATE_FAILED`, and emits:

```text
failedGateIds: []
failedChecks: [<existing-check-id>]
blockingCode: PLANNING_GATE_FAILED
exitStatus: 1
verdict: FAIL
```

Gate-tagged failures still select their existing gate-aware result, and a
`G073` failure still selects `SOURCE_EDIT_LOCKOUT`. The repair changes neither
classification branch.

## BUG-019 and Concurrent-Byte Preservation

The marker-bounded region beginning at
`# CHECK 8: Test file existence` and ending immediately before `# CHECK 9:` is
foreign BUG-019 authority. Its design-time SHA-256 is
`31804b803b8aad2b7889667dcf69de7c740988ae5cab4924ceac63444ac2711f`.
No BUG-022 expansion site lies inside that region.

Before production editing, test ownership must recapture:

- the full pre-repair guard SHA-256;
- the marker-bounded Check 8 SHA-256 and byte length;
- the current BUG-019 `test_26` SHA-256; and
- the targeted `git status` for BUG-012/019 and all shared registration files.

After every BUG-022 source edit and at GREEN, Check 8 and `test_26` hashes must
match their pre-edit values exactly. BUG-012 tail-gate hunks remain visible in
the shared-file diff and must be byte-preserved. A mismatch blocks the repair;
the owner must not normalize, revert, or re-create the foreign hunk.

## Failing-First Regression Architecture

### Persistent Surface

The planned source-only regression is
`tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`,
subject to planner confirmation that `test_29` remains collision-free. It
invokes the canonical production guard against unique disposable packet roots
and removes them on `EXIT`, `INT`, and `TERM`.

Fixtures copy the minimum canonical managed surfaces needed by the real guard.
They do not copy the list functions, result formatter, affected loops, or
Check 8 parser into the test. Required `jq`/`yq` resolution fails loud. No
fixture writes to a downstream repository, monitoring plane, backup path,
release-train config, or shared manifest.

### Final-Byte RED

`bubbles.test` must finish the complete post-repair regression first and record
its SHA-256. Before any production edit, the exact final bytes run against the
current protected source. RED is valid only when:

- the test invokes all planned production fixtures and reports planned run and
  assertion totals;
- each zero-sensitive family reaches its named Bash 3.2 nounset discriminator;
- BUG-019 Check 8 parser assertions still pass before any later abort;
- failure is caused by raw production expansions, not missing parsers, fixture
  construction, unsupported syntax in the test, or a changed protected hash;
- the test exits nonzero because post-repair assertions fail; and
- the production source still has the complete pre-edit inventory.

There is no RED mode, inverted expectation, early success return, or alternate
pre-fix fixture. The RED evidence records the test hash, guard hash, Check 8
hash, actual Bash version, full command, and actual nonzero exit.

### Identical-Byte GREEN

After only the authorized production transformations, the identical test file
and command run again. GREEN requires:

- the test SHA-256 equals the RED hash;
- every zero/one/multiple fixture reaches a complete structured result;
- no `unbound variable` diagnostic appears;
- empty fields are exactly `[]` and no sentinel appears;
- one and multiple values preserve first-seen order and deduplication;
- missing scope/report fixtures emit their intended findings and exit nonzero;
- first evidence comparison and duplicate detection retain their contracts;
- zero-gate failure emits the normal failure envelope;
- all independent mutants are rejected; and
- Check 8 and `test_26` hashes remain unchanged.

The same exact-hash test must then pass under every required Bash matrix lane.

### Behavioral Fixture Matrix

| Fixture | Cardinality/outcome | Required observable proof |
| --- | --- | --- |
| passing delivery packet | zero failed gates/checks; zero not-applicable only where profile permits | complete PASS envelope; all empty fields `[]`; exit `0` |
| first pass gate | empty to one, then duplicate pass | one gate ID, first-seen position, no duplicate |
| first failed gate/check | empty to one, then duplicate failure | one gate/check ID, unchanged failure count and attribution |
| multiple gate/check values | one to many with repeated values | existing order and deduplication; complete FAIL envelope |
| empty per-scope layout | zero `scope_files` | intended missing-scope finding; complete nonzero result |
| scopes without reports | zero `report_files` | missing-report and zero-report findings; complete nonzero result |
| one evidence block | zero prior hashes | no comparison candidate; one real append; no duplicate finding |
| two identical evidence blocks | one prior hash | existing duplicate-evidence finding and nonzero result |
| untagged planning failure | zero failed gate IDs | `failedGateIds: []`, normal blocking code, exit `1` |
| `G073` planning failure | one failed gate ID | unchanged `SOURCE_EDIT_LOCKOUT` classification |

### Independent Adversarial Mutants

Mutants are created only in unique temporary copies of the current GREEN guard.
Each mutant restores one raw expansion while every other repaired site remains
GREEN. The canonical worktree is never mutated by the test.

| Mutant | Restored raw site | Target fixture | Required rejection |
| --- | --- | --- | --- |
| `M-ACC-PASS` | first `passed_gate_ids` membership | first pass gate | nounset/incomplete-result discriminator |
| `M-ACC-FAILED-GATE` | first `failed_gate_ids` membership | first gate-tagged failure | nounset/incomplete-result discriminator |
| `M-ACC-FAILED-CHECK` | first `failed_check_ids` membership | first untagged check failure | nounset/incomplete-result discriminator |
| `M-RESULT-LOOP` | empty result-construction loop | profile fixture with zero source list | nounset/incomplete-result discriminator |
| `M-RESULT-FORMAT` | empty result formatter argument | delivery `notApplicableChecks` or empty failed gates | missing `[]`/incomplete-result discriminator |
| `M-SCOPE-LOOP` | first empty `scope_files` loop | empty per-scope layout | intended diagnostic absent and nounset present |
| `M-SCOPE-COPY` | empty `scope_analysis_files` copy | empty per-scope layout | intended diagnostic absent and nounset present |
| `M-REPORT-LOOP` | first empty `report_files` loop | scopes without reports | zero-report diagnostic absent and nounset present |
| `M-EVIDENCE-FIRST` | empty `evidence_hashes` comparison | one real evidence block | first-hash path aborts before append |
| `M-FINAL-GATE-LOOKUP` | final empty `failed_gate_ids` lookup | untagged planning failure | normal failure envelope absent |

Each mutant has a unique expected failure label and is run independently. The
test must also mutate one representative site per remaining source-map row into
the raw form and require the inventory checker to reject it, so every mapped
site is protected even when one family-level behavioral fixture is shared.
A mutant that fails only because its replacement was not applied is invalid;
the test must prove exactly one intended source substitution occurred.

## Bash Runtime Matrix

| Lane | Interpreter contract | Required execution |
| --- | --- | --- |
| macOS baseline | `/bin/bash`; assert `3.2.x` and print full `BASH_VERSION` | syntax, primitive discriminator, full final regression, mutants, BUG-019 `test_26` |
| newer macOS Bash | explicit `/opt/homebrew/bin/bash` or `/opt/local/bin/bash`; current design host has 5.3.15 | syntax, full final regression, direct zero/one/multiple contract |
| Linux/WSL Bash | CI or supported Linux `bash`; print full version and platform | syntax, full final regression, framework selftest and broader validation |

No lane silently substitutes another interpreter. If actual macOS Bash 3.2 is
unavailable, that row is `not-run` and completion remains blocked. A modern
Bash pass is compatibility evidence, never Bash 3.2 evidence. All lanes use the
same canonical source and test SHA-256.

## Testing and Validation Strategy

| Requirement family | Focused proof | Compatibility proof | Broad/provenance proof |
| --- | --- | --- | --- |
| strict mode and zero arguments | Bash 3.2 primitive plus production zero fixtures | syntax and no `set +u`/sentinel/eval inventory | managed guard selftest |
| first and multiple values | pass/fail/check production fixtures | newer Bash and Linux lanes | BUG-019 38/38 regression |
| structured empties | exact field assertions for all empty result lists | PASS and FAIL profiles | state-transition selftest |
| missing scopes/reports | empty per-scope and no-report packets | family mutants | artifact/traceability controls |
| first evidence hash | one-block and duplicate-block packets | evidence mutant | existing duplicate-evidence contract |
| zero failed gate IDs | untagged failure packet | final-lookup mutant and `G073` control | normal result-envelope consumer checks |
| byte containment | full inventory, Check 8/test_26 hashes, targeted diff | BUG-012/019 dirty baseline | install provenance and release check |

Required delivery order is:

1. planning reconciliation;
2. final regression authoring and exact-byte RED;
3. surgical production transformation only after valid RED;
4. identical-byte Bash 3.2 GREEN and mutant matrix;
5. newer macOS Bash and Linux matrix;
6. unchanged BUG-019 `test_26` and managed guard selftest;
7. regression-quality, syntax, portability, artifact, freshness, G094, and
   traceability checks;
8. full framework validation after focused checks are green;
9. owner-controlled install provenance and generated release reconciliation;
10. supported downstream upgrade evidence; and
11. independent validation and certification.

Design-phase checks establish planning coherence only. They are not RED,
GREEN, implementation, release, downstream, or certification evidence.

## Consumer and Provenance Impact

| Consumer/surface | Required effect |
| --- | --- |
| direct `state-transition-guard.sh` callers | unchanged CLI, diagnostics, result schema, and exit vocabulary; Bash 3.2 valid-empty paths no longer abort |
| `bubbles/scripts/cli.sh` transition commands | consume the repaired managed guard without command changes |
| MCP `validate_dod` / status-transition wrappers | receive a complete normal envelope instead of truncated output |
| BUG-019 | unchanged parser and `test_26` bytes can complete their 38/38 compatibility run after BUG-022 GREEN |
| BUG-020 | registry/parser startup failures can record the first failed check and emit their normal structured contract; BUG-020 source remains independently owned |
| per-scope packet authors | malformed empty scope/report layouts receive intended diagnostics rather than shell termination |
| downstream installed `.github/bubbles/scripts/state-transition-guard.sh` | receives byte-identical canonical managed source through supported install/upgrade tooling |
| source-only `test_29` | registered for canonical framework validation and release inventory but never installed as managed runtime code |
| release consumers | consume one coherent source/test/provenance release unit; no direct downstream patch |

`state-transition-guard.sh` and its managed selftest remain install-managed.
`test_29` remains source-only. `install-provenance-selftest.sh` must assert the
managed/source-only classifications, and `bubbles/release-manifest.json` must
be regenerated by the release owner only after source, test, registration, and
provenance bytes settle. `release-check` must verify that generated identity.

Downstream evidence uses the supported installer/upgrade path and verifies the
installed guard checksum against the selected canonical release. Editing
`.github/bubbles/scripts/state-transition-guard.sh` in Research Lab or any
other downstream repository is forbidden.

## Exact Change and Ownership Boundary

### This Design Invocation

Only these files may change:

- `improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md`;
- `improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json`,
  limited to `execution.*`, `executionHistory`, and the normal update timestamp.

No production, test, planner-owned, report, user-validation, registry, release,
downstream, status, or certification field is writable by this invocation.

### Authorized Delivery Surfaces by Owner

- `bubbles/scripts/state-transition-guard.sh`: only the mapped conditional
  expansions, preserving all other bytes;
- `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`:
  one source-only final-byte RED/GREEN and mutant regression;
- `bubbles/scripts/state-transition-guard-selftest.sh`: focused zero-state
  managed canaries only;
- `bubbles/scripts/framework-validate.sh`: one source-only regression
  registration, applied around BUG-021 dirty bytes without rewriting them;
- `bubbles/scripts/install-provenance-selftest.sh`: exact managed/source-only
  provenance assertions;
- `bubbles/release-manifest.json`: generated output written only by the release
  owner after all input bytes settle; and
- BUG-022 packet artifacts, each only by its canonical artifact owner.

### Explicitly Excluded

- the marker-bounded BUG-019 Check 8 parser and all BUG-019 `test_26` bytes;
- BUG-012 tail-gate bytes in the shared guard;
- `bubbles/scripts/fun-mode.sh` and BUG-020 packet/test bytes;
- BUG-021 timeout implementation and packet/test bytes;
- `BUGS.md` and shared bug registration;
- release generator logic, train config, feature-flag bundles, deployment,
  monitoring, backups, manifests, secrets, product repositories, and docs not
  named above;
- every downstream `.github/bubbles/**` installed copy;
- commits, pushes, terminal status fields, `certification.*`, scope progress,
  completion claims, and DoD checkboxes during design.

Owners must use targeted diffs and hashes before and after each shared-file
edit. A collision or unexpected changed byte stops the phase and routes to the
owning artifact; it is not resolved by checkout, reset, normalization, or a
whole-file replacement.

## Security, Integrity, and Failure Handling

The selected form performs no dynamic evaluation, variable-name lookup,
subprocess parsing, or external input execution. It changes only how an already
owned indexed array becomes an argument vector.

Strict mode remains the first production invariant. Missing required inputs,
parsers, files, or contracts still fail through their existing branches. The
repair adds no bypass flag, environment switch, default, fallback result,
suppressed diagnostic, or alternate success path.

This guard has no service telemetry plane. Its observability contract is the
existing stdout/stderr diagnostics, check labels, structured result fields,
failure count, and process exit. Focused regression output must include the
interpreter version, fixture name, child exit, result delimiters, relevant
array field, run/assertion totals, mutant identity, source/test hashes, and
final verdict.

## Rollout and Rollback

Rollout is release-atomic: planned final test, valid RED, surgical source edit,
identical-byte GREEN, runtime matrix, managed selftest, framework registration,
install-provenance assertion, broad validation, owner-generated release
manifest, release check, and supported downstream upgrade.

Before the source edit, implementation records the current full guard hash,
protected-region hashes, and an exact BUG-022 patch. If rollback is required
before release, reverse only that BUG-022 patch against the same recorded base.
Do not restore the shared guard from `HEAD`, because that would erase concurrent
BUG-019 and BUG-012 bytes. If the base hash no longer matches, stop and
reconcile the patch with the current owners.

After release, rollback selects the previous validated canonical release,
regenerates or selects its coherent manifest through release tooling, runs
release validation, and has downstream consumers reinstall that release through
the supported path. Never leave new test/provenance metadata paired with old
source, remove only one mapped expansion, or patch an installed downstream
copy. Rollback reopens BUG-022 because the Bash 3.2 defect returns.

There is no data or configuration migration and therefore no state-conversion
rollback step.

## Alternatives and Tradeoffs

| Alternative | Benefit | Rejection reason |
| --- | --- | --- |
| `if (( ${#array[@]} > 0 ))` around every use | explicit control flow | duplicates branches around dozens of sites and risks skipping existing diagnostics/result statements |
| helper accepting expanded values | central name | empty expansion aborts before helper entry on Bash 3.2 |
| helper accepting an array name | central implementation | requires nameref or `eval`, adds indirection, and is not Bash 3.2-safe without unsafe parsing |
| sentinel element | avoids empty arrays | fabricates list data, changes counts/formatting, and can leak into gate/check results |
| `set +u` around affected regions | tiny textual change | weakens strict mode and can hide unrelated unset-variable defects |
| require newer/Homebrew Bash | avoids compatibility syntax | violates the supported stock macOS runtime contract |
| change only lines 72 and 82 | fixes observed crashes | leaves every masked valid-empty family broken |
| replace arrays with newline strings | portable scalar | loses exact element boundaries and introduces delimiter/ordering risks |

## Complexity Tracking

None - simplest viable approach used. One mechanical Bash expression repairs
all valid-empty call boundaries. The larger test matrix is required by the
number of masked consumers and protects behavior without adding production
abstraction.

## Risks and Open Questions

No blocking design question remains.

Bounded risks are:

- a mechanical edit may miss one mapped site; the exact inventory and
  site-reintroduction checks are mandatory;
- a broad replacement may alter count-guarded controls or foreign parser/tail
  bytes; targeted diff and protected hashes are mandatory;
- modern Bash can conceal the defect; actual `/bin/bash` 3.2 execution is a
  non-substitutable completion row;
- full guard fixtures are expensive, so family-level behavior mutants and
  site-level inventory mutants must remain distinct rather than weakening one
  into a static-only or behavior-only proxy; and
- shared registration and release files are concurrently dirty; their owners
  must preserve existing bytes and stop on collisions.
fields, diagnostics, counts, and exits as Bash 3.2 for equivalent fixtures.
No OS-name branch or alternate implementation exists.

## Data, API, UI, And Configuration Impact

No data model, storage schema, migration, HTTP endpoint, public API, UI,
authorization matrix, feature flag, configuration key, or environment variable
is added or changed.

The command-line result block and exit status are the only public interface.
There is no browser or accessibility surface. The design changes no display
text except preventing the shell's `unbound variable` diagnostic from replacing
the existing guard diagnostics and result.

## Security, Integrity, No-Default, And No-Bypass Contract

- `set -euo pipefail` remains active for the entire production process.
- Required inputs remain required; no missing contract, parser, scope, report,
  gate, check, or evidence value receives a default.
- Empty cardinality is represented by zero arguments, not by a sentinel or
  empty-string element.
- No `eval`, nameref, associative array, dynamic code, sourced user input, or
  shell-version-selected branch is introduced.
- No source error, finding, failed check, failed gate, stderr line, or nonzero
  exit is suppressed.
- No `--skip`, `--force`, `--ignore`, `--no-nounset`, compatibility switch, or
  test-only success path is added.
- Markdown, state, and evidence data remain inert input; the repair changes only
  how existing in-memory values are traversed.

## macOS And Linux Portability

The production source and regression must parse and execute under stock macOS
Bash 3.2 and newer Bash/Linux. Implementation forms are limited to Bash-3.2
parameter expansion, indexed arrays, loops, `case`, and current portable
userland commands.

The exact compatibility idiom must be checked under a real Bash 3.2 runtime.
The existing 13-class portability scanner remains required but is not
sufficient on its own because this defect is a runtime semantic difference in
otherwise valid Bash syntax.

Tests must retain parser availability without selecting a newer Bash on macOS:
system directories stay first in `PATH`, with fail-loud `jq` and `yq`
directories appended. A Linux run records its actual Bash version and provides
newer-shell compatibility evidence; it must not be labeled Bash 3.2 evidence.

## Scenario-First RED/GREEN Architecture

### Persistent Source-Only Regression

The collision-free source-only regression is
`tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`.
Slots 26 and 27 are occupied by BUG-019 and BUG-020, while slot 28 is reserved
by BUG-021. Planning must confirm this ownership before dispatching test work.

The regression resolves the canonical production guard and required parsers,
creates one unique temporary repository, writes complete isolated packets, and
invokes the real guard under `/bin/bash`. It contains no copy of
`list_contains`, `format_result_list`, result emission, Check 8 parsing, scope
discovery, report discovery, evidence comparison, or final blocking-code logic.

### Final-Byte RED Gate

Before any BUG-022 production source edit, `bubbles.test` authors the complete
final regression bytes, records their SHA-256, captures protected source/test
hashes, and runs the exact command planned for GREEN. RED is valid only when:

- every required fixture process executes;
- the guard reaches the behavior family being asserted;
- post-repair assertions fail on one or more inventoried raw empty-array
  expansions;
- the observed abort includes the corresponding array name under Bash 3.2
  nounset; and
- fixture construction, parser resolution, BUG-019 parsing, and unrelated
  checks are not the controlling failure.

There is no broken-mode flag, inverted assertion set, early success return, or
source mutation in the RED phase. If the final regression bytes change after
RED, those changed bytes must produce a new valid RED while production remains
unchanged.

### Production Fixture Matrix

| Family | Production fixture | Required post-repair assertion |
| --- | --- | --- |
| pass result | complete delivery packet with zero failed gates/checks | one PASS result, empty failure lists, exit `0` |
| first result element | first gate-tagged pass and first check/gate failure | each first value records exactly once |
| multiple result elements | repeated and distinct gate/check IDs | first-seen order and deduplication remain exact |
| zero scopes | per-scope layout with no `scope.md` | intended structure diagnostic and complete exit-1 result |
| zero reports | per-scope layout with scope files and no reports | existing missing-report and Check-11 diagnostics plus complete exit-1 result |
| first evidence hash | one block, two distinct blocks, and two identical blocks | first append works; only identical later content is rejected |
| final gate lookup | planning failure with no failed gate and a G073 control | `PLANNING_GATE_FAILED` versus `SOURCE_EDIT_LOCKOUT` stays exact |
| contract blocked | invalid transition contract input | complete BLOCKED result, exit `2`, empty lists serialized |
| BUG-019 compatibility | unchanged parser-aware `test_26` command | `38/38`, unchanged test and parser bytes |
| newer Bash control | equivalent cardinality/result fixtures | output and exits equal the Bash 3.2 contract |

### Adversarial Mutation Matrix

Mutation tests copy the complete current production guard and its dependencies
into the owned temporary repository, then restore one raw expansion in that
staged copy. They never edit the canonical worktree. Independently named
mutants cover:

1. direct result accumulation;
2. structured result list formatting;
3. zero-scope traversal or copy;
4. zero-report traversal;
5. first evidence-hash comparison; and
6. final empty failed-gate lookup.

Each mutant must fail a behavior assertion through the staged production guard.
A static source search is an additional inventory check, not a substitute for
these executions. The test must print complete child output on failure and
require exact run/assertion totals so a missing mutant cannot silently pass.

### GREEN And Non-Vacuity

After the source edit, `bubbles.test` verifies the regression SHA-256 matches
RED and reruns the identical command. GREEN requires every fixture and mutant
assertion to pass, every child to reach its expected result boundary, and zero
`unbound variable` output.

The pass, genuine-failure, and blocked fixtures prevent a vacuous repair that
returns early or forces one exit. The one-empty-string control prevents an
incorrect `${array[@]:-}` or `${array[@]-}` rewrite that would conflate zero
elements with one empty element.

### Managed And Broad Validation

The managed `state-transition-guard-selftest.sh` receives focused Bash 3.2
zero-result and genuine-failure twins without changing BUG-019 assertions.
`framework-validate.sh` registers `test_29` once through
`run_check_self_only`, after coordination with BUG-021's shared dirty hunk.
`install-provenance-selftest.sh` asserts that the production guard and managed
selftest install byte-identically while `test_29` remains source-only and
release-recorded.

Focused regression, managed selftest, regression quality, Bash syntax,
portability, packet gates, install provenance, and BUG-019 compatibility run
before full framework validation. No focused result substitutes for the broad
framework or release result.

## Test Isolation And Pollution Controls

- Every test owns one unique `mktemp` parent and removes it on `EXIT`, `INT`,
  and `TERM`.
- Every staged packet, guard copy, dependency, mutation, and log remains under
  that parent.
- Tests invoke no network service and mutate no downstream repository, shared
  baseline, monitoring plane, backup destination, release-train config,
  deployment manifest, secret store, or generated release file.
- Required parsers are resolved fail loud; parser absence is a prerequisite
  failure, not a skip or alternate passing path.
- Tests assert values emitted by the production guard, not values copied from
  their own fixture declarations.

## Consumer Impact

### Direct Consumers

The public guard command remains consumed by:

- `bubbles/scripts/cli.sh` guard dispatch;
- `bubbles/scripts/done-spec-audit.sh`;
- `bubbles.validate` and `bubbles.audit` agent flows;
- `bubbles/scripts/state-transition-guard-selftest.sh`;
- workflow planning provenance and persistent regression fixtures; and
- MCP `validate_dod` / `verify_status_transition` wrappers.

Every consumer retains the same command, result markers, field order, field
grammar, and exit classes. No compatibility shim or consumer edit is required
for the production behavior change.

### Structured Result Consumers

`bubbles/scripts/audit-result-contract-lint.sh` and the managed guard selftest
require exactly the 15 ordered fields and accept list fields matching bracketed
comma-separated tokens, including `[]`. BUG-022 changes no schema parser and
must pass those existing consumers unchanged.

### High-Fan-Out Canaries

Because `state-transition-guard.sh` is installer-managed and high fan-out, the
independent canary order is:

1. BUG-022 zero/one/multiple production regression;
2. unchanged BUG-019 `38/38` parser regression;
3. managed state-transition selftest;
4. audit-result contract lint/selftest;
5. install provenance;
6. full framework validation; and
7. release readiness.

Rollback and release identity are part of the same shared-infrastructure
contract; broad validation cannot precede focused canaries.

## Release, Installation, And Downstream Provenance

The canonical guard and managed selftest remain installer-managed. The
persistent `test_29` remains source-only: it is registered in source framework
validation and recorded in `sourceOnlyFileChecksums`, but it is absent from a
downstream `.manifest`, `.checksums`, and installed scripts tree.

After all source, test, registration, and provenance bytes settle,
`bubbles.releases` regenerates `bubbles/release-manifest.json` through canonical
tooling and runs `release-check`. Planning, implementation, and test owners do
not hand-edit manifest hashes.

Downstream repositories receive the canonical managed guard only through the
supported install/upgrade command. Required downstream proof is installed
provenance, managed-byte integrity, a complete structured Bash 3.2 result, and
the original blocked BUG-019 system-Bash row advancing past the BUG-022
boundary. No Research Lab or other downstream `.github/bubbles/**` path is
patched directly.

## Rollout And Rollback

Rollout order is final-byte RED, surgical production edit, identical-byte
GREEN, focused canaries, install provenance, full framework validation,
release-owner manifest generation, release readiness, then supported downstream
upgrade.

Rollback is release-atomic. Revert the complete BUG-022 canonical source,
regression, managed-selftest, framework-registration, and provenance changes;
have `bubbles.releases` regenerate identity from that reverted source; validate
the selected prior release; then install that prior validated release through
the supported downstream path. Do not hand-copy an old guard, leave the new
regression registered against old source, rewrite downstream state, or alter
BUG-019 expectations. A rollback honestly restores the Bash 3.2 defect.

## Exact Change And Ownership Boundary

### Design-Owner Slice

This invocation may change only:

- `improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md`;
- `state.json::execution.*` routing and execution-history metadata for the
  design run.

It may not change certification, scope status, DoD, report evidence, source,
tests, generated metadata, registry entries, sibling packets, or downstream
files.

### Authorized Delivery Surfaces By Owner

| Surface | Exact permitted change | Owner |
| --- | --- | --- |
| `bubbles/scripts/state-transition-guard.sh` | guarded expansions at the accepted inventory plus one concise compatibility comment | `bubbles.implement` after valid RED |
| `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | final source-only production RED/GREEN and mutation matrix | `bubbles.test` |
| `bubbles/scripts/state-transition-guard-selftest.sh` | focused BUG-022 zero-result and genuine-failure twins only | `bubbles.test` |
| `bubbles/scripts/framework-validate.sh` | one nonoverlapping `run_check_self_only` BUG-022 registration | `bubbles.test`, coordinated with BUG-021 |
| `bubbles/scripts/install-provenance-selftest.sh` | exact BUG-022 managed/source-only assertions | `bubbles.test` |
| `bubbles/release-manifest.json` | generator-owned output from settled source | `bubbles.releases` |
| direct BUG-022 index/release documentation | truthful executed behavior only | `bubbles.bug` / `bubbles.docs` |
| `report.md` evidence sections | owner-tagged current execution evidence only | each execution owner |
| `state.json::certification.*`, completed scope, terminal status | independent completion certification | `bubbles.validate` |

Shared files are already dirty. Every owner must preserve foreign hunks, use a
path-scoped diff, and stop on a real overlap instead of resetting, normalizing,
or absorbing concurrent work.

### Excluded Surfaces

- BUG-019 Check 8 helpers and `tests/regression/test_26_state_transition_spec_mjs_path.sh`;
- BUG-020 `fun-mode.sh`, packet, and `test_27` work;
- BUG-021 timeout call sites, packet, and planned `test_28` work;
- BUG-012, BUG-013, BUG-018, IMP-020, and their artifacts or source/test bytes;
- `guard-lib.sh`, the result schema, transition resolver, workflow registries,
  gate registry, release-train config, deployment, monitoring, backup, secrets,
  and product repositories;
- downstream installed `.github/bubbles/**` files;
- hand-edited generated metadata, DoD checkboxes, scope status, certification,
  commits, staging, pushes, and unrelated cleanup.

## Alternatives And Tradeoffs

| Alternative | Decision | Reason |
| --- | --- | --- |
| Guarded `${array[@]+"${array[@]}"}` at zero-reachable call sites | Selected | Preserves zero arguments and every nonempty element on Bash 3.2 and newer Bash without another abstraction |
| Count guard around every loop/call | Rejected | Repeats larger control blocks, is easy to apply inconsistently, and does not naturally cover function arguments or array copies |
| Generic array-name helper | Rejected | Bash 3.2 requires `eval`, dynamic indirection, or global state before the helper can access the array |
| `${array[@]:-}` or `${array[@]-}` | Rejected | Can produce one empty argument and loses the distinction between zero elements and one empty element |
| Disable nounset around expansions | Rejected | Weakens strict-mode enforcement and hides unrelated unset-variable defects |
| Sentinel values | Rejected | Pollutes result schema, discovery, deduplication, and failure attribution |
| Replace every array expansion mechanically | Rejected | Expands the diff into count-guarded/nonempty controls without additional behavior coverage |
| Require Bash 4+ on macOS | Rejected | Violates the declared stock macOS Bash baseline and downstream portability contract |

## Complexity Tracking

None - simplest viable approach used. The production repair is a mechanical
guarded expansion at known zero-reachable consumers; complexity resides in the
required regression matrix because silent result corruption is higher risk than
the source change itself.

### Single-Implementation Justification

This is one bug fix inside the existing state-transition guard's indexed-array
and result-construction authority. There is no second provider, adapter,
strategy, screen, service, or result implementation. A compatibility library or
new list capability would duplicate the guard's authority and add more risk
than the guarded call-site pattern removes.

## Risks And Open Questions

Open questions: none.

Residual risks are bounded and testable:

- A zero-reachable site may be missed in the large guard. The accepted inventory
  plus static source audit and independent behavior-family mutations address
  this risk.
- A careless rewrite may collapse one empty-string element into zero elements.
  The dedicated cardinality control rejects that change.
- Concurrent BUG-019/020/021 edits may change line numbers or shared
  registration context. Owners must resolve by symbol and exact hunk, not by
  stale line number.
- A modern-shell-only test can hide the defect. Completion requires actual
  Bash 3.2 execution and separately named newer-Bash compatibility evidence.
- Release generation against unsettled shared files can absorb unrelated bytes.
  Release ownership waits for stable inputs and validates the whole generated
  identity before downstream upgrade.
-->
