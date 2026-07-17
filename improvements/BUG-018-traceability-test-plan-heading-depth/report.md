# Report: BUG-018 Traceability Test Plan Heading Depth

> **Planning reconciliation notice (2026-07-15):** The active contract now has
> 20 synchronized Test Plan rows and routes corrected implementation checks to
> `bubbles.implement`; see [Planning Reconciliation](#planning-reconciliation---2026-07-15).
> The implementation-era Summary, Completion Statement, Finding Accounting,
> and raw evidence below remain unchanged as historical handoff context.

## Summary

Scope 1 now has a failing-first production-path regression and a focused
canonical repair. The persistent regression passes 48 assertions under both the
default shell and sanitized macOS system Bash 3.2. The expanded managed
selftest, regression-quality guard, scoped portability scan, BUG-012/BUG-013
canaries, environment-pollution scan, and editor diagnostics are green.

Implementation is not complete. The exact planned portability command scans
two pre-existing raw `timeout` calls outside BUG-018's registration-only
boundary; the canonical cross-repo Research Lab command exposes an existing
product-root path-resolution limitation; the installed Research Lab guard is
correctly unchanged and still reproduces the pre-upgrade silent exit; and a
foreign framework-validation process occupies the shared release lane while
the new source-only regression remains untracked. No release metadata was
regenerated or edited.

## Completion Statement

Focused implementation behavior is green, but Scope 1 and top-level status
remain incomplete. No implementation phase completion claim is recorded.
Certification remains validate-owned and unmodified. Planning ownership must
reconcile the two boundary-conflicting commands before independent test can
execute the exact 17-row contract; release ownership must run only after the
foreign validator exits and the source-only regression is tracked through the
normal repository workflow.

## Decision Record

- **Scope shape:** one `runtime-behavior` scope. Splitting parser, callers,
  consumers, and release provenance would allow a partial repair to appear
  green before the production byte reaches framework and install consumers.
- **Scenario shape:** retain the four acceptance scenarios from [spec.md](spec.md)
  exactly; design-only boundary cases map to those stable scenario IDs through
  multiple concrete Test Plan rows.
- **Test handoff:** the persistent regression invokes the real production guard
  and contains no copied section extractor. RED and GREEN use the same command.
- **Certification boundary:** execution routing may name the next owner, but
  `certification.*`, completed scope state, and terminal status are untouched.

## Bug Reproduction - Before Fix

**Claim Source:** interpreted

**Source:** current Research Lab Scope 01 report at
`specs/007-technical-analysis-decision-lab/scopes/01-capability-foundation/report.md`

**Recorded downstream command:**
`bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab`

**Recorded downstream exit:** `1`

The following output is quoted from the current downstream report; it was not
re-executed by this artifact-only invocation:

```text
--- Scenario Manifest Cross-Check (G057/G059) ---
scenario-manifest.json covers 32 scenario contract(s)
scenario-manifest.json linked test exists: tests/technical-analysis-decision-lab.spec.mjs
scenario-manifest.json records evidenceRefs
All linked tests from scenario-manifest.json exist

Checking traceability for scopes/01-capability-foundation/scope.md
FEATURE007_TRACEABILITY_EXIT=1

Command exited with code 1
```

The output contains no missing-heading finding, no empty-row finding, and no
final traceability summary after the scope announcement.

## Canonical Source Inspection

**Claim Source:** interpreted

Current canonical source was read before packet creation. The controlling path
is:

```bash
extract_test_rows() {
  local scope_path="$1"
  local section
  section="$(extract_section "$scope_path" '^### Test Plan')"
  printf '%s\n' "$section" \
    | grep -E '^\|' \
    | grep -Ev '^\|[-:[:space:]|]+\|$' \
    | grep -Evi '^\|[[:space:]]*test type[[:space:]]*\|'
}
```

The caller assigns `test_rows="$(extract_test_rows "$scope_path")"` before its
existing `[[ -z "$test_rows" ]]` diagnostic. This supports the documented root
cause: level 2 is not selected, and no-match status escapes the helper before
the empty-row branch runs.

## Deduplication Record

### F007-S01-004

**Disposition:** existing canonical owner; no duplicate created.

**Canonical packet:**
`improvements/BUG-013-g028-sensitive-client-storage-classification`

**Current state read in this invocation:** `status: blocked`,
`execution.currentPhase: implement`,
`execution.nextRequiredOwner: bubbles.implement`.

**Current blocker:** broad framework/release validation is waiting on active
overlapping processes and foreign IMP-020 release-manifest input identity. The
BUG-013 implementation and regression are present according to its state, but
this invocation did not execute or certify them.

### F007-S01-005

**Disposition:** no matching canonical improvement/spec packet found by exact
search for `extract_test_rows`, heading-depth variants, silent `set -e`, and the
two Test Plan heading forms. BUG-018 is the canonical intake packet.

## Test Evidence

The planning baseline above remains historical. The blocks below are from the
current direct-authorized `bubbles.implement` session and bind claims to the
current canonical source and
`tests/regression/test_25_traceability_test_plan_heading_depth.sh`.

### RED Production-Path Regression

**Phase:** implement
**Command:** `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Exit Code:** 1
**Claim Source:** executed
**Output (level-2 and missing-heading windows from the complete pre-edit run):**

```text
=== T-BUG-018-01 Regression: level-2 Test Plan maps every scenario ===
--- T-BUG-018-01 level-2 production output ---
--- Scenario Manifest Cross-Check (G057/G059) ---
scenario-manifest.json covers 2 scenario contract(s)
scenario-manifest.json linked test exists: scopes/01-heading/tests/traceability-heading.e2e.sh
scenario-manifest.json linked test exists: scopes/01-heading/tests/traceability-heading.e2e.sh
scenario-manifest.json records evidenceRefs
All linked tests from scenario-manifest.json exist
Checking traceability for scopes/01-heading/scope.md
--- T-BUG-018-01 level-2 exit=1 ---
FAIL: level-2 packet exits zero (expected exit 0, got 1)
FAIL: level-2 maps alpha (missing: scenario mapped to Test Plan row: SCN-BUG018-LEVEL-A alpha heading maps normally)
FAIL: level-2 maps beta (missing: scenario mapped to Test Plan row: SCN-BUG018-LEVEL-B beta heading maps normally)
FAIL: level-2 reaches successful final summary (missing: RESULT: PASSED (0 warnings))
PASS: level-2 is not reported missing
--- T-BUG-018-03 missing heading exit=1 ---
PASS: missing heading exits nonzero
FAIL: missing heading reports the exact diagnostic once (expected 1 occurrence(s), got 0: has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan))
FAIL: missing heading reaches traceability summary (missing: --- Traceability Summary ---)
FAIL: missing heading reaches final failed summary (missing: RESULT: FAILED ()
test_25_traceability_test_plan_heading_depth: 17 passed, 26 failed
```

**Result:** PASS for the RED contract. The level-3 control passed in the same
run, while level 2 and expected no-match inputs stopped after the scope
announcement without the required diagnostic or final summary. Production
source was unchanged when this command executed.

### GREEN Production-Path Regression

**Phase:** implement
**Command:** `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (success assertions and terminal verdict from the complete post-edit run):**

```text
PASS: level-2 packet exits zero
PASS: level-2 maps alpha
PASS: level-2 maps beta
PASS: level-2 reaches successful final summary
PASS: level-2 is not reported missing
=== T-BUG-018-02 Regression: level-3 Test Plan preserves the level-2 mapping set ===
PASS: level-3 packet exits zero
PASS: level-3 reaches successful final summary
PASS: level-2 and level-3 mapping sets are equal
PASS: equivalent mapping set contains both scenarios
PASS: system Bash runs the production guard successfully
PASS: system Bash reaches the normal final summary
PASS: system Bash does not load unsupported optional fun-mode state
PASS: system Bash has no optional fun-mode startup failure
=== BUG-018 regression summary ===
test_25_traceability_test_plan_heading_depth: 48 passed, 0 failed
BUG018_GREEN_REGRESSION=HEADING_AWARE_TRACEABILITY_SATISFIED
```

**Result:** PASS. `T-BUG-018-01` and `T-BUG-018-02` map both scenarios and
produce equal mapping sets through the real repaired guard.

### Diagnostic And Caller Survival

**Phase:** implement
**Command:** `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: missing heading exits nonzero
PASS: missing heading reports the exact diagnostic once
PASS: missing heading is not misreported as rowless
PASS: missing heading reaches traceability summary
PASS: missing heading reaches final failed summary
PASS: unsupported heading packet exits nonzero
PASS: depth-four, Test Planning, fenced, and commented headings remain unrecognized
PASS: unsupported heading packet reaches final failed summary
PASS: empty recognized section exits nonzero
PASS: empty recognized section reports rowless once
PASS: empty recognized section is not reported missing
PASS: empty recognized section reaches final summary
PASS: separator-only recognized section exits nonzero
PASS: separator-only section reports rowless once
PASS: separator-only section reaches final summary
PASS: header-only recognized section exits nonzero
PASS: header-only section reports rowless once
PASS: header-only section reaches final summary
PASS: extractor failure exits nonzero
PASS: extractor failure reports its distinct diagnostic once
PASS: extractor failure is not reported missing
PASS: extractor failure is not reported rowless
PASS: extractor failure reaches final summary
PASS: no-scenario packet exits nonzero
PASS: no-scenario packet reports its explicit diagnostic once
PASS: no-scenario packet reaches traceability summary
PASS: no-scenario packet reaches final failed summary
```

**Result:** PASS. Missing, recognized-rowless, and no-scenario states each
reach one applicable finding and the normal aggregate summary.

### Boundary And Adversarial Regression

**Phase:** implement
**Command:** `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== T-BUG-018-05 Regression: heading-depth boundaries retain nested rows and exclude later siblings ===
PASS: level-2 boundary packet exits zero
PASS: level-2 nested row remains eligible
PASS: level-2 later same-depth sibling row is excluded
PASS: level-2 sibling path never reaches a diagnostic
PASS: level-3 boundary packet exits zero
PASS: level-3 nested row remains eligible
PASS: level-3 later same-depth sibling row is excluded
PASS: level-3 sibling path never reaches a diagnostic
summary: scenarios=1 test_rows=1
Scenario-to-row mappings: 1
Concrete test file references: 1
Report evidence references: 1
RESULT: PASSED (0 warnings)
```

**Result:** PASS. Both accepted heading depths retain one nested row and stop
before the adversarial same-depth sibling row.

### Managed Selftest And Regression Integrity

**Phase:** implement
**Commands:** `bash bubbles/scripts/traceability-guard-selftest.sh`; `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Exit Codes:** 0, 0
**Claim Source:** executed
**Output:**

```text
PASS: clean feature exits 0 (got 0)
PASS: untraceable scenario exits non-zero (got 1)
PASS: declared-edge feature exits 0 (got 0)
PASS: ambiguous-edge feature exits 0 (got 0)
PASS: Case 5 level-2 mapping set equals the existing level-3 mapping set
PASS: Case 6 missing heading reports once
PASS: Case 6 depth-four, Test Planning, fenced, and commented headings remain unrecognized
PASS: Case 7 header-only section reports rowless once
PASS: Case 8 level-2 same-depth sibling is excluded
PASS: Case 8 level-3 same-depth sibling is excluded
PASS: Case 9 no-scenario diagnostic appears once
PASS: Case 10 system Bash reaches final summary
[selftest traceability-guard] PASS
BUBBLES REGRESSION QUALITY GUARD
Scanning tests/regression/test_25_traceability_test_plan_heading_depth.sh
Adversarial signal detected in tests/regression/test_25_traceability_test_plan_heading_depth.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
```

**Result:** PASS. Existing selftest behavior remains green, the new managed
matrix is green, and the persistent bugfix regression has adversarial signal
with no quality finding.

### Portability And Bash 3.2

**Phase:** implement
**Commands:** `/usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`; exact `T-BUG-018-10` command from [scopes.md](scopes.md#test-plan); scoped portability scan excluding `framework-validate.sh`
**Exit Codes:** 0, 1, 0
**Claim Source:** interpreted
**Interpretation:** The complete regression and all new BUG-018 shell logic are
portable. The exact planned aggregate cannot pass without editing two
pre-existing raw `timeout` lines in `framework-validate.sh`, which is outside
the approved registration-only hunk.
**Output:**

```text
SYSTEM_BASH_VERSION=3.2.57(1)-release
PASS: system Bash runs the production guard successfully
PASS: system Bash reaches the normal final summary
PASS: system Bash does not load unsupported optional fun-mode state
PASS: system Bash has no optional fun-mode startup failure
test_25_traceability_test_plan_heading_depth: 48 passed, 0 failed
BUG018_GREEN_REGRESSION=HEADING_AWARE_TRACEABILITY_SATISFIED
== macOS portability guard -- scanning 5 file(s) ==
FAIL macOS-portability violation -- class-1 raw-timeout
bubbles/scripts/framework-validate.sh:190:run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"
bubbles/scripts/framework-validate.sh:292:run_check "Workflow planning provenance selftest" timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"
FAIL: 1 macOS-portability construct class(es) found in the scanned surface.
== macOS portability guard -- scanning 4 file(s) ==
ok   class-1 raw-timeout: none
ok   class-6 grep-pcre: none
ok   class-8 mapfile-readarray: none
ok   class-13 date-nanoseconds: none
PASS: the scanned surface is WSL+macOS portable.
```

**Result:** `T-BUG-018-07` passes. `T-BUG-018-10` remains unchecked pending a
planning-owner correction to the command or an explicitly authorized owner for
the pre-existing framework lines.

### Consumer Regression

**Phase:** implement
**Commands:** exact `T-BUG-018-11`; exact combined `T-BUG-018-12`; installed Research Lab command with explicit exit capture
**Exit Codes:** 0, 1, 1
**Claim Source:** interpreted
**Interpretation:** BUG-012 and BUG-013 preserve their level-3 behavior. The
canonical cross-repo invocation cannot resolve product-root test paths from the
Bubbles checkout, so the combined command stops before its installed half. The
separate installed command reaches the original scope announcement and exits
silently because Research Lab has not been upgraded.
**Output:**

```text
Feature: /Users/pkirsanov/Projects/bubbles/improvements/BUG-012-g085-first-adoption-deadlock
Scenarios checked: 5
Test rows checked: 13
Scenario-to-row mappings: 5
DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
RESULT: PASSED (0 warnings)
Feature: /Users/pkirsanov/Projects/bubbles/improvements/BUG-013-g028-sensitive-client-storage-classification
Scenarios checked: 6
Test rows checked: 10
Scenario-to-row mappings: 6
DoD fidelity scenarios: 6 (mapped: 6, unmapped: 0)
RESULT: PASSED (0 warnings)
Feature: /Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab
scenario-manifest.json covers 32 scenario contract(s)
All linked tests from scenario-manifest.json exist
Checking traceability for scopes/01-capability-foundation/scope.md
BUG018_INSTALLED_FEATURE007_EXIT=1
Command exited with code 1
```

**Result:** `T-BUG-018-11` passes. `T-BUG-018-12` remains unchecked and needs
planning/release ownership; no downstream workaround or managed-copy edit was
made.

### Packet Governance

**Phase:** implement
**Command:** exact `T-BUG-018-13` chain from [scopes.md](scopes.md#test-plan)
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
scenario-manifest.json covers 4 scenario contract(s)
All linked tests from scenario-manifest.json exist
Scenarios checked: 4
Test rows checked: 17
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 0
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: FAILED (4 failures, 0 warnings)
```

**Result:** FAIL before this evidence append because the planning-only report
did not yet mention the now-created regression path. The exact chain must be
rerun after this report update; no pass is inferred.

### Independent Framework Validation Result

**Phase:** implement
**Claim Source:** not-run
**Reason:** A foreign process tree was active before broad execution:

```text
13383 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/install-provenance-selftest.sh
30820 bash bubbles/scripts/tool-log.sh bash bubbles/scripts/cli.sh release-check
30838 bash bubbles/scripts/cli.sh release-check
30949 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/release-check.sh
30962 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh
53627 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/install-provenance-selftest.sh
```

Starting another full validator would make timing-sensitive and
install-provenance evidence ambiguous. `T-BUG-018-14` remains unchecked.

### Release And Install Provenance

**Phase:** implement
**Claim Source:** not-run
**Reason:** The shared validation lane is occupied, both changed managed hashes
differ from the current release manifest, and the source-only regression is
untracked, so the canonical generator is required to exclude it.

```text
BUG018_MANAGED_IDENTITY path=bubbles/scripts/traceability-guard.sh actual=ae826c244b9efa126e64b6dfe6f309a6675199ae1e31e28f4e4beeb5c9fb61b2 expected=dd9784a195c6832a696024406cd73b3aeb9dbc603bed3b53065b44e7eec9f668
BUG018_MANAGED_IDENTITY path=bubbles/scripts/traceability-guard-selftest.sh actual=6523fa45aa42be7f76045962cb471d4bff90addaba7a15a1d2fa79b544e6bf6d expected=4c138b753f2a338141efb0a79e2725bece5e26854ab6efc36de1e6cb42bf2a38
BUG018_SOURCE_ONLY_TRACKED=no
BUG018_SOURCE_ONLY_MANIFEST_SHA=missing
BUG018_RELEASE_IDENTITY_FAILURES=2
13383 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/install-provenance-selftest.sh
30820 bash bubbles/scripts/tool-log.sh bash bubbles/scripts/cli.sh release-check
30838 bash bubbles/scripts/cli.sh release-check
30949 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/release-check.sh
30962 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh
53627 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/install-provenance-selftest.sh
```

No manifest, index, installer, downstream copy, or generated release file was
modified. `T-BUG-018-15` and `T-BUG-018-16` remain unchecked.

## Artifact Validation

**Phase:** documentation
**Command:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-018-traceability-test-plan-heading-depth`
**Exit Code:** 0
**Claim Source:** executed

```text
Required artifact exists: spec.md
Required artifact exists: design.md
Required artifact exists: uservalidation.md
Required artifact exists: state.json
Required artifact exists: scopes.md
Required artifact exists: report.md
No forbidden sidecar artifacts present
Found DoD section in scopes.md
scopes.md DoD contains checkbox items
All DoD bullet items use checkbox syntax in scopes.md
Found Checklist section in uservalidation.md
uservalidation checklist contains checkbox entries
uservalidation checklist has checked-by-default entries
state.json v3 has recommended field: executionHistory
Top-level status matches certification.status
report.md contains section matching: Summary
report.md contains section matching: Completion Statement
report.md contains section matching: Test Evidence
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
```

The linter also emitted its existing nonblocking compatibility advisory for
`certification.scopeProgress`. The field is retained because the installed bug
template still requires certification scope progress; this artifact-only
invocation does not rewrite validate-owned schema compatibility.

## Finding Accounting

- `F007-S01-004`: deduplicated to BUG-013; it is not part of BUG-018's change
  boundary. The direct BUG-013 traceability canary passes; no BUG-013 byte was
  changed by this implementation.
- `F007-S01-005`: addressed at the focused implementation surface. RED proves
  the original level-2/silent-exit behavior; the current production regression
  passes 48 assertions and the managed selftest passes its original and
  expanded matrix.
- `PLAN-018-001`: invalid scope-kind and backward design routing corrected.
- `PLAN-018-002`: coarse eight-row test handoff replaced by the complete
  17-row production-path, consumer, governance, framework, and release matrix.
- `PLAN-018-003`: generic evidence links replaced by claim-specific report
  anchors and matching user-validation references.
- `BUG018-IMPLEMENT-001`: unresolved planning-boundary conflict. The exact
  `T-BUG-018-10` command scans two pre-existing raw `timeout` lines in
  `framework-validate.sh`; changing them exceeds the approved registration
  hunk. Required owner: `bubbles.plan` to narrow the row or route that separate
  portability work.
- `BUG018-IMPLEMENT-002`: unresolved consumer-contract conflict. The canonical
  external Feature 007 command resolves paths relative to the Bubbles checkout,
  while the installed command still carries pre-upgrade bytes. Required owner:
  `bubbles.plan` for the canonical command contract, followed by release/install
  ownership and independent replay.
- `BUG018-IMPLEMENT-003`: unresolved release prerequisite. The new regression
  is untracked, both managed hashes are stale in the release manifest, and a
  foreign framework-validation process owns the shared lane. Required owner:
  normal repository/release ownership after planning reconciliation; no manual
  manifest or index mutation occurred here.

## State And Containment

**Phase:** implement
**Commands:** structured `state.json` route assertion; certification-object
SHA-256 comparison before and after the execution-state edit; scoped status,
diff-integrity, editor diagnostics, source hashes, environment-pollution scan,
and residual-fixture scan
**Exit Codes:** 0 for every completed check
**Claim Source:** interpreted
**Interpretation:** Execution metadata and Scope 1 progress changed only within
implementation ownership. Top-level and certification status remain blocked,
the certification object is byte-identical, no implementation phase completion
claim exists, BUG-018 changes stay in allowed file families, and test execution
left no protected-surface write or fixture residue. Absolute byte identity for
every unrelated concurrently dirty path is not claimed.
**Output:**

```text
BUG018_STATE_ROUTE=PASS
BUG018_STATE_ASSERTIONS_EXIT=0
BUG018_CERTIFICATION_HASH_BEFORE=a1850838a694513e86dd75d753b5dec222631fe239c6fcf9acebcd1c93c6cabf
BUG018_CERTIFICATION_HASH_AFTER=a1850838a694513e86dd75d753b5dec222631fe239c6fcf9acebcd1c93c6cabf
BUG018_CERTIFICATION_HASH_EXPECTED=a1850838a694513e86dd75d753b5dec222631fe239c6fcf9acebcd1c93c6cabf
M bubbles/scripts/framework-validate.sh
M bubbles/scripts/install-provenance-selftest.sh
M bubbles/scripts/traceability-guard-selftest.sh
M bubbles/scripts/traceability-guard.sh
?? improvements/BUG-018-traceability-test-plan-heading-depth/state.json
?? improvements/BUG-018-traceability-test-plan-heading-depth/scopes.md
?? improvements/BUG-018-traceability-test-plan-heading-depth/report.md
?? tests/regression/test_25_traceability_test_plan_heading_depth.sh
env-pollution-scan PASSED (no test-to-prod-surface writes detected)
BUG018_RESIDUAL_FIXTURE_COUNT=0
Editor diagnostics: no errors found in all five changed shell files
Scoped git diff --check: exit 0
```

**Result:** PASS with the interpretation above. Certification, terminal status,
completed scopes, completed phase claims, downstream managed copies, and
generated release metadata remain unclaimed and unmodified.

## Planning Boundary

This planning invocation writes only `scopes.md`, `scenario-manifest.json`,
`test-plan.json`, report template structure, `uservalidation.md`, and
`state.json.execution` routing/history metadata. It does not write source,
tests, spec/design business content, checked delivery DoD, completion claims,
or certification.

## Invocation Audit

No orchestrator or specialist was invoked. This is the direct `bubbles.plan`
phase requested after the verified `bubbles.design` handoff.

## Planning Reconciliation - 2026-07-15

This planner-owned addendum changes no implementation evidence above. The
historical `T-BUG-018-10` and combined `T-BUG-018-12` outputs remain intact as
the evidence that exposed invalid planning commands; they are not pass or fail
evidence for the corrected contracts.

### Reconciled Finding Accounting

| Finding | Planning disposition | Current execution owner |
| --- | --- | --- |
| `BUG018-IMPLEMENT-001` | Addressed in planning: `T-BUG-018-10` now separates all-file Bash syntax from four-surface portability, while `T-BUG-018-19` validates the exact registration hunk without claiming unrelated `framework-validate.sh` portability. `T-BUG-018-07` remains the production Bash 3.2 proof. | `bubbles.implement` executes the corrected rows. |
| `BUG018-IMPLEMENT-002` | Addressed in planning: `T-BUG-018-12` owns a disposable Research-Lab-shaped canonical fixture; `T-BUG-018-17` proves source compatibility from the Research Lab root without requiring the foreign packet's own findings to close; and `T-BUG-018-18` is gated on supported release/install/upgrade delivery. | `bubbles.implement` owns the corrected `T-BUG-018-17` evidence assertion; Feature 007 Scope 09 independently owns full Feature 007 traceability; release/install ownership must satisfy `T-BUG-018-18` prerequisites before installed replay. |
| `BUG018-IMPLEMENT-003` | Retained honestly: framework validation, install provenance, and release validation remain distinct `T-BUG-018-14`, `T-BUG-018-15`, and `T-BUG-018-16` rows. The source-only regression is still untracked, so no release-ready claim exists. | Repository/release ownership after corrected implementation checks and a settled source set. |

### Corrected Test Contract Index

| Test ID | Corrected contract | Existing evidence treatment |
| --- | --- | --- |
| `T-BUG-018-10` | Bash syntax covers all five changed BUG-018 shell files; macOS portability covers only the four BUG-018-authored implementation/test surfaces. | The prior exit `1` whole-file scan remains historical; the prior four-surface exit `0` is supporting context, not proof of the newly combined command. |
| `T-BUG-018-12` | The persistent regression must include a disposable Research-Lab-shaped packet whose linked paths resolve within the owned fixture. | No dedicated case is identified in the current 48-assertion output; the row remains unchecked. |
| `T-BUG-018-17` | From the owning Research Lab root, prove that canonical source resolves Feature 007, recognizes all 32 manifest-linked tests, traverses all nine scopes, reaches the normal final summary, emits no path-resolution or extractor failure, and does not stop after a scope announcement. Exit `1` is accepted only as the foreign packet's nonterminal verdict; its 37 Feature-007-owned findings are not asserted passed or resolved. | Preserve the prior wrong-root failure and the existing raw own-root run unchanged. The row remains unchecked until `bubbles.implement` records the corrected compatibility assertion against that captured output. |
| `T-BUG-018-18` | Run installed Research Lab replay only after canonical release validation and supported install/upgrade delivery. | The pre-upgrade silent exit proves stale installed bytes only and cannot fail the implementation. |
| `T-BUG-018-19` | Assert one exact added `run_check_self_only` registration line in the current diff and run `git diff --check` on that file. | Registration exists in the current diff, but the corrected hunk command remains unchecked until its owner executes it. |

### T-17 Source Compatibility Planning Contract

`T-BUG-018-17` answers one BUG-018 question: can the repaired canonical guard
consume a real downstream packet from that packet's owning repository root
without the heading-depth repair failing before normal traceability accounting?

Acceptance requires all of these signals in the already captured own-root run:

- the resolved feature path is inside the Research Lab checkout;
- the manifest reports 32 scenario contracts and every linked test is
  recognized;
- all nine Feature 007 scope files are traversed;
- the normal final traceability summary is printed;
- no linked-path resolution failure or Test Plan extraction failure appears;
  and
- execution does not stop immediately after any scope announcement.

The guard may exit `1` with the 37 currently observed Feature-007-owned
traceability findings. That nonzero verdict is expected product-delivery data,
not a BUG-018 source-compatibility failure, and this planning correction does
not mark any of those findings passed or resolved. Full Feature 007 traceability belongs to Feature 007 Scope 09 and is not a prerequisite for BUG-018 completion.

The existing raw command/output block under
[Research Lab Source Consumer](#research-lab-source-consumer) remains
byte-for-byte implementation evidence. `bubbles.implement` must append its own
corrected assertion/evidence treatment; this planning section neither rewrites
that output nor checks the T-17 DoD item.

All four scenarios retain their existing primary persistent regression links and
evidence anchors. Markdown Test Plan, `test-plan.json`, and Test Plan DoD now
contain the same 20 unique IDs. Certification, completed scope state, terminal
status, source, tests, release metadata, `install.sh`, and downstream files are
unchanged by this reconciliation.

## Resumed Implementation Evidence - 2026-07-15

This section binds the reconciled 20-row plan to the current implementation
bytes. It supersedes only the historical uncertainty for corrected rows
`T-BUG-018-10`, `T-BUG-018-12`, `T-BUG-018-17`, and `T-BUG-018-19`.
Certification, terminal status, downstream managed bytes, generated release
metadata, Git index state, and commits remain unchanged.

### Corrected Shell And Registration Contracts

**Phase:** implement
**Command:** `/bin/bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh tests/regression/test_25_traceability_test_plan_heading_depth.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh tests/regression/test_25_traceability_test_plan_heading_depth.sh bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
== macOS portability guard -- scanning 4 file(s) ==
ok   class-1 raw-timeout: none
ok   class-2 in-place-sed: none
ok   class-3 date-d-parse: none
ok   class-4 stat-c-mtime: none
ok   class-5 readlink-f-absolutize: none
ok   class-6 grep-pcre: none
ok   class-7 bracket-v-isset: none
ok   class-8 mapfile-readarray: none
ok   class-9 mktemp-suffix: none
ok   class-10 df-output: none
ok   class-11 bin-true-false: none
ok   class-12 paste-no-stdin-operand: none
ok   class-13 date-nanoseconds: none
PASS: the scanned surface is WSL+macOS portable.
T_BUG_018_10_POST_EDIT_EXIT=0
BASH_SYNTAX_SURFACES=5
PORTABILITY_SURFACES=4
FRAMEWORK_VALIDATE_PORTABILITY_CLAIM=excluded
```

**Command:** `git diff HEAD --check -- bubbles/scripts/framework-validate.sh && registration_hunk="$(git diff HEAD --unified=0 -- bubbles/scripts/framework-validate.sh)" && registration_count="$(grep -Fxc '+run_check_self_only "BUG-018 traceability Test Plan heading-depth regression" bash "$REPO_ROOT/tests/regression/test_25_traceability_test_plan_heading_depth.sh"' <<< "$registration_hunk")" && [[ "$registration_count" -eq 1 ]]`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
REGISTRATION_HUNK_BEGIN
@@ -290,0 +295,3 @@ run_check_self_only "BUG-009 planning audit contract regression"
+run_check_self_only "BUG-013 sensitive client storage regression" bash "$REPO_ROOT/tests/regression/test_24_g028_sensitive_client_storage.sh"
+run_check_self_only "BUG-018 traceability Test Plan heading-depth regression" bash "$REPO_ROOT/tests/regression/test_25_traceability_test_plan_heading_depth.sh"
+run_check_self_only "BUG-019 state-transition compound MJS test-path regression" bash "$REPO_ROOT/tests/regression/test_26_state_transition_spec_mjs_path.sh"
REGISTRATION_HUNK_END
REGISTRATION_COUNT=1
T_BUG_018_19_POST_EDIT_EXIT=0
EXPECTED_REGISTRATION_COUNT=1
WHOLE_FILE_PORTABILITY_CLAIM=none
BUG018_T19_POST_EDIT_END
```

**Result:** PASS. `T-BUG-018-10` proves syntax across all five changed shell
files and portability across only the four authorized implementation/test
surfaces. `T-BUG-018-19` proves exactly one BUG-018 registration line without
claiming ownership of the concurrent BUG-013, BUG-019, or IMP-020 hunks.

### Canonical Research-Lab-Shaped Fixture

**Phase:** implement
**Command:** `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== T-BUG-018-12 Canonical production behavior: disposable Research-Lab-shaped packet resolves inside its owned fixture ===
--- T-BUG-018-12 Research Lab fixture production output ---
scenario-manifest.json covers 1 scenario contract(s)
scenario-manifest.json linked test exists: tests/technical-analysis-decision-lab.spec.mjs
All linked tests from scenario-manifest.json exist
scopes/01-capability-foundation/scope.md scenario mapped to Test Plan row: SCN-BUG018-RESEARCH-LAB canonical source resolves owner-root linked test
scopes/01-capability-foundation/scope.md scenario maps to concrete test file: tests/technical-analysis-decision-lab.spec.mjs
scopes/01-capability-foundation/scope.md report references concrete test evidence: tests/technical-analysis-decision-lab.spec.mjs
RESULT: PASSED (0 warnings)
--- T-BUG-018-12 Research Lab fixture exit=0 ---
PASS: Research-Lab-shaped packet exits zero
PASS: relative feature path resolves inside the fixture owner root
PASS: Research Lab scenario maps through canonical source
PASS: owner-root linked test resolves inside the fixture
PASS: fixture report binds owner-root test evidence
PASS: Research-Lab-shaped packet reaches successful final summary
PASS: Research-Lab-shaped packet has no cross-root path failure
test_25_traceability_test_plan_heading_depth: 55 passed, 0 failed
BUG018_GREEN_REGRESSION=HEADING_AWARE_TRACEABILITY_SATISFIED
T_BUG_018_12_POST_REPAIR_EXIT=0
```

**Result:** PASS. The persistent production-path regression now owns a
disposable Research-Lab-shaped repository, invokes the real canonical guard
from that repository root, and resolves its root-level linked test entirely
inside the unique trapped fixture.

### Current Focused Regression And Governance

**Phase:** implement
**Commands:** managed selftest; bugfix regression-quality guard; sanitized
system Bash regression; direct BUG-012/BUG-013 canaries; exact packet-governance
chain
**Exit Codes:** 0, 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
[selftest traceability-guard] Case 5: exact level-2 Test Plan (exit 0)
PASS: Case 5 level-2 mapping set equals the existing level-3 mapping set
PASS: Case 6 missing heading reports once
PASS: Case 7 extractor failure reports distinctly once
PASS: Case 8 level-2 same-depth sibling is excluded
PASS: Case 8 level-3 same-depth sibling is excluded
PASS: Case 9 no-scenario diagnostic appears once
PASS: Case 10 system Bash reaches final summary
[selftest traceability-guard] PASS
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
test_25_traceability_test_plan_heading_depth: 55 passed, 0 failed
T_BUG_018_07_EXIT=0
T_BUG_018_11_EXIT=0
BUG012_MUTATION=none
BUG013_MUTATION=none
Scenarios checked: 4
Test rows checked: 20
Scenario-to-row mappings: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
T_BUG_018_13_EXIT=0
```

**Result:** PASS. Current guard and regression bytes preserve the managed
matrix, adversarial integrity, macOS Bash 3.2, direct level-3 canaries, and the
reconciled four-scenario/twenty-row packet contract.

### Research Lab Source Consumer

**Phase:** implement
**Command:** `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab`
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
Feature: /Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab
scenario-manifest.json covers 32 scenario contract(s)
scenario-manifest.json linked test exists: tests/technical-analysis-decision-lab.spec.mjs
All linked tests from scenario-manifest.json exist
Checking traceability for scopes/01-capability-foundation/scope.md
scopes/01-capability-foundation/scope.md summary: scenarios=4 test_rows=10
Checking traceability for scopes/09-regression-closure/scope.md
scopes/09-regression-closure/scope.md summary: scenarios=1 test_rows=17
Scenarios checked: 32
Test rows checked: 90
Scenario-to-row mappings: 22
Concrete test file references: 22
Report evidence references: 4
DoD fidelity scenarios: 0 (mapped: 0, unmapped: 0)
RESULT: FAILED (37 failures, 0 warnings)
T_BUG_018_17_POST_EDIT_EXIT=1
SOURCE_GUARD=../bubbles/bubbles/scripts/traceability-guard.sh
OWNING_ROOT=research-lab
DOWNSTREAM_WRITES=none
```

**Result:** FAIL for `T-BUG-018-17`, but the original BUG-018 cross-root defect
is repaired: canonical source resolves the correct Feature 007 directory, all
32 linked tests, all nine scopes, and the final summary. The 37 remaining
findings belong to the current Feature 007 packet: missing report references,
unmapped Test Plan rows, and absent recognized DoD sections. Feature 007's
current `state.json` names `bubbles.bug` as `nextRequiredOwner`; no Research Lab
file was modified.

### Containment Isolation And Diagnostics

**Phase:** implement
**Commands:** scoped `git diff --check`; `env-pollution-scan.sh`; zsh-safe
residual-fixture count; VS Code diagnostics
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG018_DIFF_CHECK_EXIT=0
STAGED_BY_THIS_INVOCATION=none
COMMITTED_BY_THIS_INVOCATION=none
env-pollution-scan PASSED (no test-to-prod-surface writes detected)
ENV_POLLUTION_EXIT=0
BUG018_RESIDUAL_FIXTURE_COUNT=0
BUG018_ISOLATION_EXIT=0
DOWNSTREAM_MANAGED_WRITES=none
RELEASE_METADATA_WRITES=none
Editor diagnostics: no errors found in traceability-guard.sh
Editor diagnostics: no errors found in traceability-guard-selftest.sh
Editor diagnostics: no errors found in framework-validate.sh
Editor diagnostics: no errors found in install-provenance-selftest.sh
Editor diagnostics: no errors found in test_25_traceability_test_plan_heading_depth.sh
```

**Result:** PASS. The resumed implementation touched only the canonical guard,
the source-only regression, implementation evidence/progress, and execution
routing. No downstream managed file, release metadata, Git index, or commit was
written.

### Shared Lane And Release Prerequisites

**Phase:** implement
**Claim Source:** not-run
**Reason:** The required preflight found an active foreign framework validator
and concurrently dirty release inputs. No duplicate framework validator,
install-provenance run, release generation, release-check, or installed replay
was started.

```text
ACTIVE_PROCESS_SCAN_BEGIN
2725 bash bubbles/scripts/cli.sh framework-validate
2810 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh
ACTIVE_PROCESS_SCAN_EXIT=0
SHARED_LANE_CLEAR_NO
SOURCE_ONLY_REGRESSION_TRACKED=no
canonical traceability-guard.sh sha256=dfc4e00a73d8018884a2ae2df1401cc24acca53014b587778c250cc6e9dcd3d9
release-manifest traceability-guard.sh sha256=dd9784a195c6832a696024406cd73b3aeb9dbc603bed3b53065b44e7eec9f668
installed Research Lab traceability-guard.sh sha256=dd9784a195c6832a696024406cd73b3aeb9dbc603bed3b53065b44e7eec9f668
SOURCE_ONLY_MANIFEST_LOOKUP_EXIT=1
T_BUG_018_15_RUN=no
T_BUG_018_16_RUN=no
T_BUG_018_18_RUN=no
RELEASE_MANIFEST_MUTATION=none
BROAD_COMMAND_STARTED=no
```

The exact provenance consequence is that canonical managed bytes are newer
than generated release metadata, the source-only regression is untracked and
therefore absent from generated source-only inventory, and Research Lab still
has the pre-upgrade guard. Release readiness and installed replay are not
claimed.

### Resumed Finding Accounting

- `BUG018-LOCAL-001`: addressed. Relative feature paths that exist beneath the
  caller's repository root now bind `repo_root` to that caller root before
  feature and linked-test resolution.
- `BUG018-LOCAL-002`: addressed. The persistent regression now contains the
  dedicated `T-BUG-018-12` Research-Lab-shaped fixture and passes 55 assertions.
- `BUG018-PLAN-001`: addressed. Corrected `T-BUG-018-10` passes with five syntax
  surfaces and four portability surfaces.
- `BUG018-PLAN-002`: addressed. Corrected `T-BUG-018-19` finds exactly one
  direct BUG-018 registration line.
- `RESEARCH-LAB-007-TRACEABILITY`: unresolved and routed to `bubbles.bug`, the
  exact next owner in Feature 007 state. The canonical command reaches the
  normal summary but reports 37 foreign packet findings.
- `BUG018-RELEASE-PREREQ`: unresolved. Independent test plus release/install
  ownership must wait for a clear stable lane, tracked source-only regression,
  canonical generated metadata, and supported downstream upgrade.

## Current-Session Corrected T-BUG-018-17 Compatibility Assertion

**Executed:** YES (in current session)
**Phase:** implement
**Canonical Command:** `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab`
**Exit Code:** 1 (accepted only by the compatibility assertion below)
**Assertion Command:** exact current-session shell wrapper around the canonical
command:

```bash
cd ../research-lab && trace_output="$(bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab 2>&1)"; guard_exit=$?; printf '%s\n' "$trace_output"; assertion_failures=0; assert_contains() { assertion_label="$1"; assertion_needle="$2"; if grep -Fq -- "$assertion_needle" <<< "$trace_output"; then printf 'PASS: %s\n' "$assertion_label"; else printf 'FAIL: %s\n' "$assertion_label"; assertion_failures=$((assertion_failures + 1)); fi; }; assert_not_matches() { assertion_label="$1"; assertion_pattern="$2"; if grep -Eq -- "$assertion_pattern" <<< "$trace_output"; then printf 'FAIL: %s\n' "$assertion_label"; assertion_failures=$((assertion_failures + 1)); else printf 'PASS: %s\n' "$assertion_label"; fi; }; if [[ "$guard_exit" -eq 1 ]]; then printf '%s\n' 'PASS: canonical guard retains the expected nonterminal exit 1'; else printf 'FAIL: canonical guard exit must be 1 for the current 37-finding packet, observed=%s\n' "$guard_exit"; assertion_failures=$((assertion_failures + 1)); fi; assert_contains 'Feature 007 resolves inside the owning Research Lab root' 'Feature: /Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab'; assert_contains 'scenario manifest reports all 32 scenario contracts' 'scenario-manifest.json covers 32 scenario contract(s)'; assert_contains 'every scenario-manifest linked test is recognized' 'All linked tests from scenario-manifest.json exist'; linked_test_recognitions="$(grep -Fc 'scenario-manifest.json linked test exists:' <<< "$trace_output")"; if [[ "$linked_test_recognitions" -ge 32 ]]; then printf 'PASS: linked-test recognition lines cover the 32-contract manifest (observed=%s)\n' "$linked_test_recognitions"; else printf 'FAIL: fewer than 32 linked-test recognition lines (observed=%s)\n' "$linked_test_recognitions"; assertion_failures=$((assertion_failures + 1)); fi; for scope_path in scopes/01-capability-foundation/scope.md scopes/02-technique-engine/scope.md scopes/03-setup-lifecycle/scope.md scopes/04-five-gate-synthesis/scope.md scopes/05-owner-publication/scope.md scopes/06-comparison-optional-evidence/scope.md scopes/07-validation-risk-process/scope.md scopes/08-experience-publication/scope.md scopes/09-regression-closure/scope.md; do assert_contains "$scope_path is announced" "Checking traceability for $scope_path"; assert_contains "$scope_path reaches its scope summary" "$scope_path summary:"; done; scope_announcement_count="$(grep -Fc 'Checking traceability for scopes/' <<< "$trace_output")"; scope_summary_count="$(grep -Ec 'scopes/[0-9][0-9]-[^ ]+/scope\.md summary:' <<< "$trace_output")"; if [[ "$scope_announcement_count" -eq 9 && "$scope_summary_count" -eq 9 ]]; then printf 'PASS: all nine scopes are announced and summarized (announcements=%s summaries=%s)\n' "$scope_announcement_count" "$scope_summary_count"; else printf 'FAIL: scope traversal mismatch (announcements=%s summaries=%s)\n' "$scope_announcement_count" "$scope_summary_count"; assertion_failures=$((assertion_failures + 1)); fi; assert_contains 'normal traceability summary is reached' '--- Traceability Summary ---'; assert_contains 'normal summary retains 32 checked scenarios' 'Scenarios checked: 32'; assert_contains 'foreign packet verdict remains 37 unresolved findings' 'RESULT: FAILED (37 failures, 0 warnings)'; assert_not_matches 'no feature path-resolution failure is emitted' 'ERROR: feature directory not found:|No such file or directory'; assert_not_matches 'no linked-test path-resolution failure is emitted' 'scenario-manifest\.json references missing linked test file:'; assert_not_matches 'no Test Plan extraction failure is emitted' 'Test Plan extraction failed'; printf 'T_BUG_018_17_GUARD_EXIT=%s\n' "$guard_exit"; printf 'T_BUG_018_17_LINKED_TEST_RECOGNITIONS=%s\n' "$linked_test_recognitions"; printf 'T_BUG_018_17_SCOPE_ANNOUNCEMENTS=%s\n' "$scope_announcement_count"; printf 'T_BUG_018_17_SCOPE_SUMMARIES=%s\n' "$scope_summary_count"; printf 'T_BUG_018_17_FORBIDDEN_SIGNAL_COUNT=%s\n' "$(grep -Ec 'ERROR: feature directory not found:|No such file or directory|scenario-manifest\.json references missing linked test file:|Test Plan extraction failed' <<< "$trace_output" || true)"; printf 'FEATURE_007_TRACEABILITY_FINDINGS=37\n'; printf 'FEATURE_007_FINDINGS_RESOLVED=no\n'; printf 'T_BUG_018_17_ASSERTION_FAILURES=%s\n' "$assertion_failures"; if [[ "$assertion_failures" -eq 0 ]]; then printf 'T_BUG_018_17_COMPATIBILITY_ASSERTION=PASS\n'; exit 0; fi; printf 'T_BUG_018_17_COMPATIBILITY_ASSERTION=FAIL\n'; exit 1
```

**Assertion Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
--- Current-session canonical guard output (contract-bearing lines copied verbatim) ---
============================================================
  BUBBLES TRACEABILITY GUARD
  Feature: /Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab
============================================================
--- Scenario Manifest Cross-Check (G057/G059) ---
✅ scenario-manifest.json covers 32 scenario contract(s)
✅ scenario-manifest.json linked test exists: tests/technical-analysis-decision-lab.spec.mjs
✅ scenario-manifest.json records evidenceRefs
✅ All linked tests from scenario-manifest.json exist
ℹ️  Checking traceability for scopes/01-capability-foundation/scope.md
ℹ️  scopes/01-capability-foundation/scope.md summary: scenarios=4 test_rows=10
ℹ️  Checking traceability for scopes/02-technique-engine/scope.md
ℹ️  scopes/02-technique-engine/scope.md summary: scenarios=4 test_rows=8
ℹ️  Checking traceability for scopes/03-setup-lifecycle/scope.md
ℹ️  scopes/03-setup-lifecycle/scope.md summary: scenarios=5 test_rows=9
ℹ️  Checking traceability for scopes/04-five-gate-synthesis/scope.md
ℹ️  scopes/04-five-gate-synthesis/scope.md summary: scenarios=6 test_rows=10
ℹ️  Checking traceability for scopes/05-owner-publication/scope.md
ℹ️  scopes/05-owner-publication/scope.md summary: scenarios=4 test_rows=10
ℹ️  Checking traceability for scopes/06-comparison-optional-evidence/scope.md
ℹ️  scopes/06-comparison-optional-evidence/scope.md summary: scenarios=2 test_rows=6
ℹ️  Checking traceability for scopes/07-validation-risk-process/scope.md
ℹ️  scopes/07-validation-risk-process/scope.md summary: scenarios=4 test_rows=8
ℹ️  Checking traceability for scopes/08-experience-publication/scope.md
ℹ️  scopes/08-experience-publication/scope.md summary: scenarios=2 test_rows=12
ℹ️  Checking traceability for scopes/09-regression-closure/scope.md
ℹ️  scopes/09-regression-closure/scope.md summary: scenarios=1 test_rows=17
--- Traceability Summary ---
ℹ️  Scenarios checked: 32
ℹ️  Test rows checked: 90
ℹ️  Scenario-to-row mappings: 22
ℹ️  Concrete test file references: 22
ℹ️  Report evidence references: 4
ℹ️  DoD fidelity scenarios: 0 (mapped: 0, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=0 inferred=13 ambiguous=9
RESULT: FAILED (37 failures, 0 warnings)
--- Corrected compatibility assertion tail ---
PASS: canonical guard retains the expected nonterminal exit 1
PASS: Feature 007 resolves inside the owning Research Lab root
PASS: scenario manifest reports all 32 scenario contracts
PASS: every scenario-manifest linked test is recognized
PASS: linked-test recognition lines cover the 32-contract manifest (observed=36)
PASS: scopes/01-capability-foundation/scope.md is announced
PASS: scopes/01-capability-foundation/scope.md reaches its scope summary
PASS: scopes/02-technique-engine/scope.md is announced
PASS: scopes/02-technique-engine/scope.md reaches its scope summary
PASS: scopes/03-setup-lifecycle/scope.md is announced
PASS: scopes/03-setup-lifecycle/scope.md reaches its scope summary
PASS: scopes/04-five-gate-synthesis/scope.md is announced
PASS: scopes/04-five-gate-synthesis/scope.md reaches its scope summary
PASS: scopes/05-owner-publication/scope.md is announced
PASS: scopes/05-owner-publication/scope.md reaches its scope summary
PASS: scopes/06-comparison-optional-evidence/scope.md is announced
PASS: scopes/06-comparison-optional-evidence/scope.md reaches its scope summary
PASS: scopes/07-validation-risk-process/scope.md is announced
PASS: scopes/07-validation-risk-process/scope.md reaches its scope summary
PASS: scopes/08-experience-publication/scope.md is announced
PASS: scopes/08-experience-publication/scope.md reaches its scope summary
PASS: scopes/09-regression-closure/scope.md is announced
PASS: scopes/09-regression-closure/scope.md reaches its scope summary
PASS: all nine scopes are announced and summarized (announcements=9 summaries=9)
PASS: normal traceability summary is reached
PASS: normal summary retains 32 checked scenarios
PASS: foreign packet verdict remains 37 unresolved findings
PASS: no feature path-resolution failure is emitted
PASS: no linked-test path-resolution failure is emitted
PASS: no Test Plan extraction failure is emitted
T_BUG_018_17_GUARD_EXIT=1
T_BUG_018_17_LINKED_TEST_RECOGNITIONS=36
T_BUG_018_17_SCOPE_ANNOUNCEMENTS=9
T_BUG_018_17_SCOPE_SUMMARIES=9
T_BUG_018_17_FORBIDDEN_SIGNAL_COUNT=0
FEATURE_007_TRACEABILITY_FINDINGS=37
FEATURE_007_FINDINGS_RESOLVED=no
T_BUG_018_17_ASSERTION_FAILURES=0
T_BUG_018_17_COMPATIBILITY_ASSERTION=PASS
```

**Result:** PASS for the corrected `T-BUG-018-17` BUG-018 compatibility
contract only. The canonical source guard resolves the Research Lab feature,
recognizes every manifest-linked test, announces and summarizes all nine
scopes, and reaches the normal final summary without a path-resolution,
extractor, or post-announcement silent-exit failure. The inner guard's exit `1`
and all 37 findings remain the nonterminal Feature-007-owned traceability
verdict; none is represented as fixed, passing, or resolved.

### Current Execution Routing After T-BUG-018-17

The shared validation/release process scan currently has no matching process
(`SHARED_LANE_MATCH_EXIT=1`, `SHARED_VALIDATION_RELEASE_LANE_CLEAR=yes`), so the
next legitimate `bugfix-fastlane` owner is `bubbles.test` for one independent,
serial `T-BUG-018-14` framework validation. `T-BUG-018-14`,
`T-BUG-018-15`, `T-BUG-018-16`, and `T-BUG-018-18` remain unchecked.

Release/install work is not ready: the source-only BUG-018 regression remains
untracked, the release manifest and managed source inputs are concurrently
dirty, and no supported downstream install/upgrade has occurred. Therefore no
install-provenance, release-check, installed-replay, release-readiness,
certification, completed-scope, or terminal-status claim is made.

### Current Finding Accounting

- `BUG018-T17-COMPATIBILITY`: addressed. Current-session raw output and the
  zero-exit assertion above prove every corrected T-BUG-018-17 compatibility
  signal while preserving the foreign nonterminal verdict.
- `RESEARCH-LAB-007-TRACEABILITY`: unresolved under Feature 007 Scope 09. The
  exact 37-finding partition is 18 missing report-evidence references (Scopes
  02-09: 2, 3, 4, 4, 2, 1, 1, 1), 10 scenarios without traceable Test Plan
  rows (Scopes 02, 03, 04, 07, 08: 2, 2, 2, 3, 1), and 9 scope files without
  recognized DoD items (Scopes 01-09: one each). None is a BUG-018
  compatibility failure, and none is resolved or passing in this invocation.
- `BUG018-T14-INDEPENDENT-VALIDATION`: unresolved. `bubbles.test` owns one
  serial canonical framework validation now that the shared lane is clear.
- `BUG018-RELEASE-PREREQ`: unresolved. Release/install ownership must wait for
  a tracked, settled source set before T-BUG-018-15/T-BUG-018-16, then perform
  the supported downstream upgrade before T-BUG-018-18.

## Independent T-BUG-018-14 Framework Validation - 2026-07-15

This direct-authorized `bubbles.test` slice executed exactly one current-tree
framework validator. It did not execute install provenance, release readiness,
or installed downstream replay, and it did not mutate source, tests, generated
release metadata, downstream managed bytes, the Git index, commits,
certification, scope status, or terminal status.

### Shared-Lane Preflight

**Executed:** YES (current session)
**Phase:** test
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG018_T14_SHARED_LANE_SCAN_BEGIN' && lane_exit=0; pgrep -fl '[f]ramework-validate|[r]elease-check|[i]nstall-provenance|[g]enerate-release-manifest' || lane_exit=$?; printf 'BUG018_T14_SHARED_LANE_MATCH_EXIT=%s\n' "$lane_exit"; if [[ "$lane_exit" -eq 1 ]]; then printf '%s\n' 'BUG018_T14_SHARED_LANE_CLEAR=yes'; printf '%s\n' 'BUG018_T14_SHARED_LANE_SCAN_END'; exit 0; fi; printf '%s\n' 'BUG018_T14_SHARED_LANE_CLEAR=no'; printf '%s\n' 'BUG018_T14_SHARED_LANE_SCAN_END'; exit "$lane_exit"
```

**Exit Code:** 0 for the framing command; inner `pgrep` exit `1`
**Claim Source:** executed
**Output:**

```text
BUG018_T14_SHARED_LANE_SCAN_BEGIN
BUG018_T14_SHARED_LANE_MATCH_EXIT=1
BUG018_T14_SHARED_LANE_CLEAR=yes
BUG018_T14_SHARED_LANE_SCAN_END
```

No matching process owned the shared framework/release/install-provenance lane,
so starting one serial broad validator did not duplicate another owner.

### Framework Validation

**Executed:** YES (current session)
**Phase:** test
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 1
**Exit capture:** `printf 'BUG018_T14_ACTUAL_EXIT=%s\n' "$?"` executed as the
next command in the same persistent shell and printed
`BUG018_T14_ACTUAL_EXIT=1`.
**Claim Source:** executed
**Output preservation limitation:** The command ran once with no pipe,
redirect, or output filter. VS Code preserved the terminal tail but explicitly
reported that its scrollback dropped the beginning after the run exceeded the
capture limit. The missing prefix is not reconstructed or represented as full
evidence. The verbatim retained terminal tail is:

```text
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation failed with 2 failing check(s).
Failed checks:
  - Release manifest freshness
  - Release manifest selftest
(base) pkirsanov@Philippes-MacBook-Pro bubbles %

Output exceeded terminal scrollback; beginning of output was lost
```

**Result:** FAIL. `T-BUG-018-14` remains unchecked. The final validator
accounting names exactly two failed checks and does not name the registered
BUG-018 regression. That absence does not convert the aggregate row to a pass,
and the lost terminal prefix prevents a complete raw-output claim.

### Current Release-Manifest Drift Audit

**Executed:** YES (current session)
**Phase:** test
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG018_T14_MANIFEST_AUDIT_BEGIN' && mismatch_count=0 && missing_count=0 && while IFS=$'\t' read -r manifest_section manifest_path expected_hash; do if [[ ! -f "$manifest_path" ]]; then printf 'MANIFEST_MISSING section=%s path=%s expected=%s\n' "$manifest_section" "$manifest_path" "$expected_hash"; missing_count=$((missing_count + 1)); mismatch_count=$((mismatch_count + 1)); continue; fi; hash_line="$(shasum -a 256 "$manifest_path")"; actual_hash="${hash_line%% *}"; if [[ "$actual_hash" != "$expected_hash" ]]; then printf 'MANIFEST_MISMATCH section=%s path=%s expected=%s actual=%s\n' "$manifest_section" "$manifest_path" "$expected_hash" "$actual_hash"; mismatch_count=$((mismatch_count + 1)); fi; done < <(jq -r '(.managedFileChecksums[] | ["managed", .path, .sha256] | @tsv), (.sourceOnlyFileChecksums[] | ["source-only", .path, .sha256] | @tsv)' bubbles/release-manifest.json) && printf 'BUG018_T14_MANIFEST_MISMATCH_COUNT=%s\n' "$mismatch_count" && printf 'BUG018_T14_MANIFEST_MISSING_COUNT=%s\n' "$missing_count" && for source_only_path in tests/regression/test_25_traceability_test_plan_heading_depth.sh tests/regression/test_26_state_transition_spec_mjs_path.sh; do if git ls-files --error-unmatch "$source_only_path" >/dev/null 2>&1; then printf 'SOURCE_ONLY_TRACKING path=%s tracked=yes\n' "$source_only_path"; else printf 'SOURCE_ONLY_TRACKING path=%s tracked=no\n' "$source_only_path"; fi; if jq -e --arg source_only_path "$source_only_path" '.sourceOnlyFileChecksums[] | select(.path == $source_only_path)' bubbles/release-manifest.json >/dev/null; then printf 'SOURCE_ONLY_MANIFEST path=%s present=yes\n' "$source_only_path"; else printf 'SOURCE_ONLY_MANIFEST path=%s present=no\n' "$source_only_path"; fi; done && printf '%s\n' 'BUG018_T14_MANIFEST_AUDIT_END'
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG018_T14_MANIFEST_AUDIT_BEGIN
MANIFEST_MISMATCH section=managed path=bubbles/scripts/adversarial-aggregate-selftest.sh expected=00419d6913fa0cd6e261fb3d7098be5a8f7926ab5f0b86fe588061ad00a5d8f7 actual=f039df5029f0c21299dedd5ce7bae5378ec595228d91b41d9bd3c7dfab0f19eb
MANIFEST_MISMATCH section=managed path=bubbles/scripts/adversarial-resolve-selftest.sh expected=4a26c8dbc30b39aa8d6de2f3631b8e95c59394ffeb521af76d2a90bbdf83d0cd actual=f07819cfe4528dc178e32e7c0892ec93df0217bf90fd81ac2aff61daafff9e8d
MANIFEST_MISMATCH section=managed path=bubbles/scripts/framework-validate.sh expected=1354085b22169309b636b4db574bf499979000d587159c624d407b6f15e6636b actual=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
MANIFEST_MISMATCH section=managed path=bubbles/scripts/fun-mode.sh expected=00bc5aa96744aaa0a3ac784b2577728a9318fe9f95f4b3b91f422eb8c078b386 actual=edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e
MANIFEST_MISMATCH section=managed path=bubbles/scripts/install-provenance-selftest.sh expected=640e89e11d765cb57c0200d835e3a50b9478145f3062e3cb5f4475f701a631f1 actual=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_MISMATCH section=managed path=bubbles/scripts/state-transition-guard-selftest.sh expected=20593a047f006cde0eb3db51f1c50b27c3230a46344d35aeea27e1da83dfd3ea actual=1388ab43a01c067ac3abac0dc13c6f62f73fe6af0f1483de5287a25326e7d64d
MANIFEST_MISMATCH section=managed path=bubbles/scripts/state-transition-guard.sh expected=1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b actual=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
MANIFEST_MISMATCH section=managed path=bubbles/scripts/traceability-guard-selftest.sh expected=4c138b753f2a338141efb0a79e2725bece5e26854ab6efc36de1e6cb42bf2a38 actual=691b022fe8a7c4018844c7c74484d108fc3472ce6f0ea917b72e68882306d12f
MANIFEST_MISMATCH section=managed path=bubbles/scripts/traceability-guard.sh expected=dd9784a195c6832a696024406cd73b3aeb9dbc603bed3b53065b44e7eec9f668 actual=dfc4e00a73d8018884a2ae2df1401cc24acca53014b587778c250cc6e9dcd3d9
BUG018_T14_MANIFEST_MISMATCH_COUNT=9
BUG018_T14_MANIFEST_MISSING_COUNT=0
SOURCE_ONLY_TRACKING path=tests/regression/test_25_traceability_test_plan_heading_depth.sh tracked=no
SOURCE_ONLY_MANIFEST path=tests/regression/test_25_traceability_test_plan_heading_depth.sh present=no
SOURCE_ONLY_TRACKING path=tests/regression/test_26_state_transition_spec_mjs_path.sh tracked=no
SOURCE_ONLY_MANIFEST path=tests/regression/test_26_state_transition_spec_mjs_path.sh present=no
BUG018_T14_MANIFEST_AUDIT_END
```

The nine stale rows partition without erasing concurrent ownership:

- IMP-020 S2 owns the two adversarial selftest source inputs;
- the framework-validation and install-provenance rows are shared registration
  inputs changed by concurrent packets;
- BUG-020 owns the current `fun-mode.sh` input;
- BUG-019/BUG-020 own the two state-transition inputs; and
- BUG-018 owns the two traceability inputs.

`bubbles.releases` owns generated manifest reconciliation after those source
and test inputs are settled and tracked. This test slice did not regenerate or
hand-edit the manifest.

### One-To-One Failure And Finding Accounting

| Finding | Disposition | Owner |
| --- | --- | --- |
| `BUG018-T14-LANE` | Addressed: current-session preflight found no competing framework/release/install-provenance process, and exactly one serial validator was started. | none |
| `BUG018-T14-001` | Unresolved: `Release manifest freshness` failed against nine current managed checksum mismatches. | `bubbles.releases` after source/test stabilization |
| `BUG018-T14-002` | Unresolved: `Release manifest selftest` is the dependent second failed check; its first assertion invokes the same manifest freshness contract. No separate release-ready claim is inferred. | `bubbles.releases` after source/test stabilization |
| `BUG018-T14-RAW-OUTPUT` | Unresolved evidence limitation: the command was unfiltered, but VS Code dropped the terminal prefix after execution. Only the retained raw tail and actual exit are claimed. | `bubbles.test` on the eventual post-reconciliation rerun |
| `RESEARCH-LAB-007-TRACEABILITY` | Preserved unresolved under Feature 007 Scope 09: 18 missing report references, 10 unmapped scenarios, and 9 missing recognized DoD sections, totaling 37. None is a BUG-018 framework-validation failure. | Feature 007 owner (`bubbles.bug` in its current state) |
| `BUG018-T15-INSTALL-PROVENANCE` | Unresolved and not run: BUG-018 `test_25` is untracked and absent from source-only inventory. | `bubbles.releases` after the tracked source set settles |
| `BUG018-T16-RELEASE-INTEGRATION` | Unresolved and not run: generated metadata is not current, so release readiness has no satisfied prerequisite. | `bubbles.releases` |
| `BUG018-T18-INSTALLED-REPLAY` | Unresolved and not run: no validated release or supported downstream upgrade exists. | release/install ownership, then `bubbles.test` |

**Test verdict:** `NOT_TESTED`. The only owned broad row executed, but it exits
`1`; no test phase completion claim is valid. The immediate controlling owner
is `bubbles.releases` for canonical generated-manifest reconciliation after the
concurrent source/test set is stable and tracked.
