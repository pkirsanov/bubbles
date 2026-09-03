# BUG-061 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Allocated BUG-061 after a canonical-path scan of every local ref, live remote
  ref, registered worktree, source bug directory, and `BUGS.md` heading.
- Reproduced exactly four SC1007 findings and one SC2034 finding on the five
  assigned tracked files.
- Grounded the five source constructs and the two excluded ownership artifacts.
- Created planning and scenario contracts without modifying source or tests.
- Passed canonical artifact, scenario-obligation, test-mechanism,
  scenario-reference, and planning-traceability checks.
- Kept top-level and certification status `in_progress`.

## Completion Statement

This report records bug identification, current-session reproduction, root-cause
localization, and planning artifacts only. It makes no source repair, GREEN
test, framework-validation, release-readiness, audit, or certification claim.

## Test Evidence

### Global bug ID allocation

**Executed:** YES
**Phase:** bug
**Command:** isolated `origin` mirror plus canonical bug-path and `BUGS.md` heading scan across every local ref, live remote ref, and registered worktree
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `2e5e17166e4b6eccd1b95730f680d36565e09c835d11042831e4b8d5c84b52d3`

```text
CANONICAL_BUG_ALLOCATION_SCAN_BEGIN
LOCAL_REFS_SCANNED=275
UNIQUE_LOCAL_REF_OBJECTS_SCANNED=119
LIVE_REMOTE_REFS_SCANNED=247
UNIQUE_REMOTE_REF_OBJECTS_SCANNED=116
REGISTERED_WORKTREES_SCANNED=16
LIVE_CANONICAL_BUG_DIRS_SCANNED=146
LIVE_BUGS_MD_HEADINGS_SCANNED=476
BUG-053
BUG-054
BUG-055
BUG-056
BUG-057
BUG-058
BUG-059
BUG-060
MAX_ALLOCATED_BUG_ID=BUG-060
NEXT_GLOBALLY_FREE_BUG_ID=BUG-061
CANONICAL_BUG_ALLOCATION_SCAN_END
```

**Result:** PASS. The allocation check distinguishes canonical bug artifacts
from example identifiers in unrelated source or fixtures.

### Exact five-warning before fix

**Executed:** YES
**Phase:** bug
**Command:** `shellcheck -S warning -f gcc bubbles/adapters/research/disabled.sh bubbles/adapters/research/local-command.sh bubbles/adapters/usage/reference-test.sh bubbles/scripts/research-run.sh bubbles/scripts/scenario-manifest-migrate-selftest.sh`
**Capture:** The command ran inside the bounded `BUG-061 exact five-warning pre-fix reproduction` evidence-capture invocation with a 120-second process limit.
**Exit Code:** 1
**Claim Source:** executed
**Output SHA-256:** `c7f1dc6cd8750450fbd8d4ca3410e2e3f45da28163207641f4940e715dab9261`

```text
BUG061_SHELLCHECK_REPRO_BEGIN
SHELLCHECK_BIN=/opt/homebrew/bin/shellcheck
ShellCheck - shell script analysis tool
version: 0.11.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net
BUG061_FOCUSED_SURFACES_BEGIN
bubbles/adapters/research/disabled.sh
bubbles/adapters/research/local-command.sh
bubbles/adapters/usage/reference-test.sh
bubbles/scripts/research-run.sh
bubbles/scripts/scenario-manifest-migrate-selftest.sh
BUG061_FOCUSED_SURFACES_END
bubbles/adapters/research/disabled.sh:4:21: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
bubbles/adapters/research/local-command.sh:4:21: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
bubbles/adapters/usage/reference-test.sh:14:1: warning: EMPTY_DIGEST appears unused. Verify use (or export if used externally). [SC2034]
bubbles/scripts/research-run.sh:4:21: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
bubbles/scripts/scenario-manifest-migrate-selftest.sh:619:45: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
BUG061_SHELLCHECK_EXIT=1
BUG061_SHELLCHECK_REPRO_END
```

**Result:** Expected pre-fix failure. The output contains exactly five warning
records on the assigned files and preserves the nonzero ShellCheck exit.

### Source occurrence inventory

**Executed:** YES
**Phase:** bug
**Command:** bounded `git grep` over exactly the five assigned files plus direct ownership artifact lookup
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** The clean inventory maps every reproduced warning to one
source construct. The separately located IMP-056 and BUG-038 artifacts provide
the exclusion anchors required by the operator boundary.

```text
OWNERSHIP_PATHS_BEGIN
improvements/IMP-056-fail-closed-cross-repository-dispatch-authorization.md
bugs/BUG-038-train-metadata-assignment-mode-gap
OWNERSHIP_PATHS_END
EXACT_FIVE_SOURCE_PATTERNS_BEGIN
bubbles/adapters/research/disabled.sh:4:script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
bubbles/adapters/research/local-command.sh:4:script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
bubbles/adapters/usage/reference-test.sh:14:EMPTY_DIGEST="sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
bubbles/scripts/research-run.sh:4:script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
bubbles/scripts/scenario-manifest-migrate-selftest.sh:619:TMPDIR="$WORK/hostile-temp" XDG_RUNTIME_DIR= python3 "$MIGRATOR" --check "$WORK/v1.json"
EXACT_FIVE_SOURCE_PATTERNS_END
```

**Result:** The five-instance packet boundary is source-grounded. No warning
from the two existing ownership groups is included.

## Code Diff Evidence

**Executed:** YES
**Phase:** bug
**Command:** `git diff --cached --name-only; git diff --cached --check; git diff --quiet HEAD -- <five source paths>; git diff --quiet HEAD -- <two excluded owner paths>; git diff --quiet HEAD -- bubbles/release-manifest.json; git status --short --branch`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG061_STAGED_PATHS_BEGIN
BUGS.md
bugs/BUG-061-shellcheck-zero-warning-gate/bug.md
bugs/BUG-061-shellcheck-zero-warning-gate/design.md
bugs/BUG-061-shellcheck-zero-warning-gate/report.md
bugs/BUG-061-shellcheck-zero-warning-gate/scenario-manifest.json
bugs/BUG-061-shellcheck-zero-warning-gate/scopes.md
bugs/BUG-061-shellcheck-zero-warning-gate/spec.md
bugs/BUG-061-shellcheck-zero-warning-gate/state.json
bugs/BUG-061-shellcheck-zero-warning-gate/test-plan.json
bugs/BUG-061-shellcheck-zero-warning-gate/uservalidation.md
BUG061_STAGED_PATHS_END
BUG061_STAGED_PATH_COUNT=10
BUG061_CACHED_DIFF_CHECK_EXIT=0
BUG061_FIVE_SOURCE_DIFF_EXIT=0
BUG061_EXCLUDED_OWNER_DIFF_EXIT=0
BUG061_RELEASE_MANIFEST_DIFF_EXIT=0
?? .specify/memory/bubbles.session.json
BUG061_STAGING_BOUNDARY_EXIT=0
```

**Result:** PASS. Filing changes only `BUGS.md` and the nine BUG-061 artifacts.
The only other worktree path is the pre-existing untracked runtime session
file, which is not staged. Production, test, excluded-owner, and release
manifest bytes remain unchanged.

## Scenario Contract Evidence

Five stable scenario IDs map one-to-one to F-B061-001 through F-B061-005.
`scenario-manifest.json` records a mutation negative control for each warning
shape, and `test-plan.json` records focused, behavior-preservation, aggregate,
portability, and broad regression commands.

## Artifact Validation Evidence

**Executed:** YES
**Phase:** bug
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-061-shellcheck-zero-warning-gate 'SCN-B061-[0-9]{3}'`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`

```text
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
```

**Result:** PASS. The linter accepted every required source-packet artifact,
the v3 state shape, non-terminal status, report sections, and checked-DoD
evidence links.

## Planning and Traceability Evidence

**Executed:** YES
**Phase:** bug
**Command:** bounded sequential execution of `scenario-obligation-lint.sh`, `test-mechanism-lint.sh`, `scenario-test-resolve.sh`, and `traceability-guard.sh --all-scopes --coverage-policy=planning` against BUG-061
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `9c064600327b587c15830926297409cf3ed85214579fbef1ecd881e03f21fa0c`

```text
BUG061_SCENARIO_OBLIGATION_BEGIN
[scenario-obligation-lint] OK — 5 scenario(s) with a coherent derived obligation matrix
BUG061_SCENARIO_OBLIGATION_EXIT=0
BUG061_TEST_MECHANISM_BEGIN
[test-mechanism-lint] OK — 5 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
BUG061_TEST_MECHANISM_EXIT=0
BUG061_SCENARIO_TEST_RESOLVE_BEGIN
[scenario-test-resolve] OK — 10 reference(s) resolved via literal-scan
BUG061_SCENARIO_TEST_RESOLVE_EXIT=0
BUG061_TRACEABILITY_BEGIN
============================================================
  BUBBLES TRACEABILITY GUARD
  Feature: /private/tmp/bubbles-ozhiva-transition-unblock-ca550392/bugs/BUG-061-shellcheck-zero-warning-gate
  Timestamp: 2026-09-03T05:18:05Z
============================================================

--- Scenario Manifest Cross-Check (G057/G059) ---
✅ scenario-manifest.json covers 5 scenario contract(s)
✅ scenario-manifest.json linked test exists: bubbles/scripts/shellcheck-lint.sh
--- omitted 40 line(s); sha256 above covers the full output ---
✅ scopes.md scenario maps to DoD item: SCN-B061-003 Usage reference adapter is warning-clean
ℹ️  scopes.md scenario→DoD match confidence: declared
✅ scopes.md scenario maps to DoD item: SCN-B061-004 Research runner is warning-clean
ℹ️  scopes.md scenario→DoD match confidence: declared
✅ scopes.md scenario maps to DoD item: SCN-B061-005 Migration fallback fixture is warning-clean
ℹ️  scopes.md scenario→DoD match confidence: declared
ℹ️  DoD fidelity: 5 scenarios checked, 5 mapped to DoD, 0 unmapped

--- Traceability Summary ---
ℹ️  Scenarios checked: 5
ℹ️  Test rows checked: 11
ℹ️  Scenario-to-row mappings: 5
ℹ️  Concrete test file references: 5
ℹ️  Report evidence references: 5
ℹ️  DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=10 inferred=0 ambiguous=0

RESULT: PASSED (0 warnings)
BUG061_TRACEABILITY_EXIT=0
BUG061_PLANNING_CHECKS_EXIT=0
```

The bounded capture retained the first and last 20 lines and hashed all 80
produced lines. The initial planning attempt is not treated as a pass: it exited
1 because two mechanism values were outside the closed vocabulary and each
scenario had two primary Test Plan bindings. The packet now uses accepted
mechanism vocabulary and one primary Test Plan row per scenario.

**Result:** PASS. Planning-level traceability is coherent. This does not prove
the source repair or any GREEN behavior.

## Validation Evidence

**Executed:** NO
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run.

## Uncertainty Declarations

All unresolved implementation and verification obligations are recorded under
the corresponding unchecked items in [scopes.md](scopes.md#definition-of-done).