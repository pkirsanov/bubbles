# Report: BUG-023 Planning Transition Applicability And Baseline

## Summary

BUG-023 now has a final five-scope, 17-scenario planning contract: a shared
baseline/equality/mutation foundation, fail-closed G073 provenance and legacy
semantics, profile-bound G060 applicability, finite accepted G040 contexts,
and blocking-precedence plus compatibility closure. This report preserves the
intake provenance and provides execution-owner evidence anchors only. No source
fix, RED/GREEN result, test pass, framework validation, release, propagation,
downstream upgrade, QF certification, or terminal completion is claimed.

Planning sources: [scopes.md](scopes.md),
[scenario-manifest.json](scenario-manifest.json),
[test-plan.json](test-plan.json), and
[uservalidation.md](uservalidation.md).

## Completion Statement

PLANNING HANDOFF ONLY. Analyst, UX, and design are operator-confirmed final;
`bubbles.plan` has reconciled its owned artifacts. All five scopes remain
`Not Started`, every DoD item remains unchecked, and the mandatory next owner
is `bubbles.test` for final-byte RED. This statement is not delivery evidence.

## Test Evidence

### Canonical Repository Intake

**Phase:** select
**Command:** `cd /Users/pkirsanov/Projects/bubbles && git status --short && git rev-parse --show-toplevel && git rev-parse HEAD`
**Exit Code:** 0
**Claim Source:** executed

```text
/Users/pkirsanov/Projects/bubbles
cd286d15b9de010dd40f43b747fe02dab8771b19
```

**Interpretation:** The canonical root and revision are directly observed. The
empty `git status --short` portion shows no canonical dirty path at intake, but
the short output is not delivery evidence and does not satisfy a DoD item.

### Artifact Packet Lint

**Phase:** bootstrap
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh lint improvements/BUG-023-planning-transition-applicability-and-baseline`
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
All checklist bullet items use checkbox syntax
Detected state.json status: in_progress
Detected state.json workflowMode: bugfix-fastlane
state.json v3 has required field: status
state.json v3 has required field: execution
state.json v3 has required field: certification
state.json v3 has required field: policySnapshot
state.json v3 has recommended field: transitionRequests
state.json v3 has recommended field: reworkQueue
state.json v3 has recommended field: executionHistory
Top-level status matches certification.status
Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
report.md contains Summary section
report.md contains Completion Statement section
report.md contains Test Evidence section
All checked DoD items in scopes.md have evidence blocks
No unfilled evidence template placeholders in scopes.md
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
```

The first lint run found only a level mismatch on the DoD heading. Intake
changed that heading to the canonical `### Definition of Done` form and the
same command then passed as shown above.

### Downstream Reproduction Supplied At Intake

**Phase:** select
**Claim Source:** interpreted

The reporter supplied these current facts:

```text
workflowMode=product-to-planning
auditProfile=planning-maturity-v1
targetStatus=specs_hardened
planningOnly=true
scopeCount=19
scenarioCount=39
testCount=125
failedGates=[G073,G060,G040]
blockingCode=SOURCE_EDIT_LOCKOUT
transitionExit=1
canonicalVersion=7.20.0
downstreamVersion=7.20.0
```

**Interpretation:** These values define the downstream discriminator and are not
represented as canonical command execution. `bubbles.test` must reproduce each
class hermetically before source implementation.

### Frozen Test Byte Identity

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && shasum -a 256 tests/regression/test_30_planning_transition_applicability_and_baseline.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31  tests/regression/test_30_planning_transition_applicability_and_baseline.sh
```

This is the authoritative pre-implementation frozen identity. The full RED,
syntax, regression-quality, and portability executions below all observed the
same digest. No production byte changed before this identity and RED were
captured.

### T-BUG-023-001

Final-byte RED covered SCN-BUG-023-001. No GREEN or completion is claimed; the
linked DoD item remains unchecked. See [Bug Reproduction - Before Fix](#bug-reproduction---before-fix).

### T-BUG-023-002

Final-byte RED covered SCN-BUG-023-002, including missing, GREEN-before-RED,
and ordered delivery controls. The linked DoD item remains unchecked.

### T-BUG-023-003

Final-byte RED covered SCN-BUG-023-003, including missing, GREEN-before-RED,
and ordered delivery controls. The linked DoD item remains unchecked.

### T-BUG-023-004

Final-byte RED covered the exact title/domain-label variants for
SCN-BUG-023-004. The linked DoD item remains unchecked.

### T-BUG-023-005

Final-byte RED covered the exact noun-compound variants for SCN-BUG-023-005.
The linked DoD item remains unchecked.

### T-BUG-023-006

Final-byte RED covered heading, table-cell, field-label, and structural
variants for SCN-BUG-023-006. The linked DoD item remains unchecked.

### T-BUG-023-007

Final-byte RED covered both present-surface sentences and their variants for
SCN-BUG-023-007. The linked DoD item remains unchecked.

### T-BUG-023-008

Final-byte RED covered every work-disposition phrase and variant for
SCN-BUG-023-008. The linked DoD item remains unchecked.

### T-BUG-023-009

Final-byte RED covered future-work/scope and next-cycle variants for
SCN-BUG-023-009. The linked DoD item remains unchecked.

### T-BUG-023-010

Final-byte RED covered every fix/address phrase, token-window boundary, and
segment boundary for SCN-BUG-023-010. The linked DoD item remains unchecked.

### T-BUG-023-011

Final-byte RED covered same-line blocking precedence, content withholding, and
stable-digest requirements for SCN-BUG-023-011. The linked DoD item remains
unchecked.

### T-BUG-023-012

Final-byte RED proved the authoritative baseline helper/result contract is
absent for SCN-BUG-023-012. The linked DoD item remains unchecked.

### T-BUG-023-013

Final-byte RED exercised staged, unstaged, mixed, untracked, rename, and delete
fixtures for SCN-BUG-023-013. The linked DoD item remains unchecked.

### T-BUG-023-014

Final-byte RED exercised appeared, index, worktree, type, mode, clean, rename,
delete, commit, symlink, and compare-race cases for SCN-BUG-023-014. The linked
DoD item remains unchecked.

### T-BUG-023-015

Final-byte RED exercised the complete malformed, missing, unsafe, unsupported,
digest, binding, divergent-HEAD, and capture-race matrix for SCN-BUG-023-015.
The linked DoD item remains unchecked.

### T-BUG-023-016

Final-byte RED covered immutable original-baseline reuse and post-capture dirt
for SCN-BUG-023-016. The linked DoD item remains unchecked.

### T-BUG-023-017

Final-byte RED proved current legacy whole-worktree lockout still blocks and
does not synthesize a baseline for SCN-BUG-023-017. The linked DoD item remains
unchecked.

### T-BUG-023-018

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-019

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-020

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-021

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-022

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-023

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-024

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-025

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-026

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-027

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-028

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-029

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-030

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-031

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-032

The full frozen matrix produced causal RED with zero harness/control failures.
This is pre-fix evidence only; the linked DoD item remains unchecked.

### T-BUG-023-033

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-034

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-035

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-036

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-037

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-038

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-039

The RED-stage regression-quality guard passed with zero violations and zero
warnings. Production remains RED; the linked DoD item remains unchecked.

### T-BUG-023-040

The test-owned shell surface passed all 13 macOS/Linux portability classes.
Production remains RED; the linked DoD item remains unchecked.

### T-BUG-023-041

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-042

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-043

Planning anchor only; the linked DoD item remains unchecked.

### T-BUG-023-044

Planning anchor only; the linked DoD item remains unchecked.

## Bug Reproduction - Before Fix

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && shasum -a 256 tests/regression/test_30_planning_transition_applicability_and_baseline.sh; bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh; red_exit=$?; printf 'FULL_MATRIX_EXIT=%s\n' "$red_exit"; exit "$red_exit"`
**Exit Code:** 1
**Claim Source:** executed

The complete unfiltered command output was captured in the current execution
session (42 KB). The causal beginning and terminal summary are preserved below;
the middle consists of the per-vector exact G040 and G073 assertions emitted by
the same command.

```text
test-sha256: a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31
selection: all-17-scenarios
PASS-CONTROL[SCN-BUG-023-001]: planning fixture reaches canonical G060
FAIL-CAUSAL[G060][SCN-BUG-023-001]: planning-maturity-v1 incorrectly evaluates and blocks absent runtime RED-to-GREEN evidence
FAIL-CAUSAL[G060][SCN-BUG-023-001]: planning_g060_not_applicable lacks exactly one TRANSITION_GUARD_RESULT_V2 block (begin=0 end=0)
PASS-CONTROL[SCN-BUG-023-002]: full-delivery missing remains blocking at G060
PASS-CONTROL[SCN-BUG-023-002]: full-delivery green-before-red remains blocking at G060
PASS-CONTROL[SCN-BUG-023-002]: full-delivery ordered RED-before-GREEN remains a positive G060 control
PASS-CONTROL[SCN-BUG-023-003]: bugfix-fastlane missing remains blocking at G060
PASS-CONTROL[SCN-BUG-023-003]: bugfix-fastlane green-before-red remains blocking at G060
PASS-CONTROL[SCN-BUG-023-003]: bugfix-fastlane ordered RED-before-GREEN remains a positive G060 control
FAIL-CAUSAL[G040][SCN-BUG-023-004]: g040-title expected-safe-only phrase matrix is misclassified as deferral by canonical G040
FAIL-CAUSAL[G040][SCN-BUG-023-004]: g040-title cannot prove exact line=18 reason=TITLE_OR_DOMAIN_LABEL statement='Authorized Outcome Follow-Up' because V2 gate details are unavailable
FAIL-CAUSAL[G040][SCN-BUG-023-005]: g040-noun expected-safe-only phrase matrix is misclassified as deferral by canonical G040
FAIL-CAUSAL[G040][SCN-BUG-023-006]: g040-structured expected-safe-only phrase matrix is misclassified as deferral by canonical G040
FAIL-CAUSAL[G040][SCN-BUG-023-007]: g040-present expected-safe-only phrase matrix is misclassified as deferral by canonical G040
PASS-CONTROL[SCN-BUG-023-008]: g040-work blocking matrix is rejected by canonical G040
FAIL-CAUSAL[G040][SCN-BUG-023-010]: g040-later cannot prove exact line=31 reason=NO_CONTRACT_MATCH statement='Fix a b c d e f g h in follow-up.' because V2 gate details are unavailable
FAIL-CAUSAL[G040][SCN-BUG-023-011]: same-line G040 precedence digest is absent or unstable (first=NONE second=NONE)
FAIL-CAUSAL[G073][SCN-BUG-023-012]: canonical authoritative helper is absent: bubbles/scripts/planning-source-baseline.sh
FAIL-CAUSAL[G073][SCN-BUG-023-013]: equal-staged cannot prove audited equality for STAGED_ONLY because capture failed
FAIL-CAUSAL[G073][SCN-BUG-023-013]: equal-unstaged cannot prove audited equality for UNSTAGED_ONLY because capture failed
FAIL-CAUSAL[G073][SCN-BUG-023-013]: equal-mixed cannot prove audited equality for MIXED_STAGED_UNSTAGED because capture failed
FAIL-CAUSAL[G073][SCN-BUG-023-013]: equal-untracked cannot prove audited equality for UNTRACKED because capture failed
FAIL-CAUSAL[G073][SCN-BUG-023-013]: equal-rename cannot prove audited equality for RENAME because capture failed
FAIL-CAUSAL[G073][SCN-BUG-023-013]: equal-delete cannot prove audited equality for DELETE because capture failed
PASS-CONTROL[SCN-BUG-023-017]: legacy whole-worktree lockout remains blocking under current semantics
PASS-CONTROL[SCN-BUG-023-017]: legacy guard synthesizes no baseline declaration
PASS_CONTROLS=46
CAUSAL_FAILURES=256
G040_CAUSAL_FAILURES=79
G060_CAUSAL_FAILURES=15
G073_CAUSAL_FAILURES=162
CONTROL_FAILURES=0
HARNESS_FAILURES=0
GUARD_RUNS=17
BASELINE_RUNS=51
RED_CLASSIFICATION=CAUSAL_BUG_CONTRACT_FAILURE
RED_CAUSAL_PROVEN=1
FULL_MATRIX_EXIT=1
```

The expected bug-specific assertions failed while fixture, delivery-ordering,
legacy lockout, read-only, and cleanup controls ran. Because both
`CONTROL_FAILURES` and `HARNESS_FAILURES` are zero and all three gate-family
causal counters are nonzero, this is causal RED rather than a harness error.

### RED-Stage Syntax And Quality Checks

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && /bin/bash -n tests/regression/test_30_planning_transition_applicability_and_baseline.sh && printf '%s\n' 'BASH_SYNTAX_EXIT=0'`
**Exit Code:** 0
**Claim Source:** executed

```text
BASH_SYNTAX_EXIT=0
```

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && digest_line="$(shasum -a 256 tests/regression/test_30_planning_transition_applicability_and_baseline.sh)"; observed_digest="${digest_line%% *}"; printf 'FROZEN_SHA256=%s\n' "$observed_digest"; if [[ "$observed_digest" != 'a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31' ]]; then printf '%s\n' 'FROZEN_DIGEST_MISMATCH'; exit 2; fi; bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_30_planning_transition_applicability_and_baseline.sh; check_exit=$?; printf 'REGRESSION_QUALITY_EXIT=%s\n' "$check_exit"; exit "$check_exit"`
**Exit Code:** 0
**Claim Source:** executed

<!-- markdownlint-disable MD010 -->

```text
FROZEN_SHA256=a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31
============================================================
	BUBBLES REGRESSION QUALITY GUARD
	Repo: /Users/pkirsanov/Projects/bubbles
	Timestamp: 2026-07-17T21:20:02Z
	Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_30_planning_transition_applicability_and_baseline.sh
✅ Adversarial signal detected in tests/regression/test_30_planning_transition_applicability_and_baseline.sh

============================================================
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
============================================================
REGRESSION_QUALITY_EXIT=0
```

<!-- markdownlint-enable MD010 -->

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && digest_line="$(shasum -a 256 tests/regression/test_30_planning_transition_applicability_and_baseline.sh)"; observed_digest="${digest_line%% *}"; printf 'FROZEN_SHA256=%s\n' "$observed_digest"; if [[ "$observed_digest" != 'a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31' ]]; then printf '%s\n' 'FROZEN_DIGEST_MISMATCH'; exit 2; fi; bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_30_planning_transition_applicability_and_baseline.sh; check_exit=$?; printf 'PORTABILITY_EXIT=%s\n' "$check_exit"; exit "$check_exit"`
**Exit Code:** 0
**Claim Source:** executed

```text
FROZEN_SHA256=a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31
== macOS portability guard -- scanning 1 file(s) ==
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
PORTABILITY_EXIT=0
```

Skip-marker and live-test mock/intercept scans returned zero matches. Editor
diagnostics returned no errors for the frozen test file. These static passes do
not satisfy any unchecked implementation or GREEN DoD item.

## Production Change Containment

No production file changed during intake. Reserved for `bubbles.implement`
after final-byte RED and owner-reconciled design/planning.

## Post-Fix Regression

Not run. Must reuse the exact pre-fix regression bytes.

## Framework Validation

Not run. The canonical command is
`bash bubbles/scripts/cli.sh framework-validate` after focused checks pass.

## Release And Propagation

Not run. Release readiness, canonical release identity, supported downstream
upgrade, and the fresh QF Spec 097 transition are separate owner-recorded
evidence sections. No downstream managed file may be edited directly.

## Invocation Audit

### Historical Intake Invocation

The original `bubbles.bug` invocation remains a valid historical
`route_required` event. In that invocation, the specialist-dispatch capability
was unavailable, zero specialist calls were made, and the packet recorded
`RUNSUBAGENT_CAPABILITY_UNAVAILABLE` with next owner `bubbles.analyst`. That
observation is not rewritten or represented as a successful dispatch.

### Blocker Resolution

The historical blocker is superseded for the current packet because the
operator explicitly confirms that analyst, UX, and design dispatches completed
and their owned artifacts are final, then directly invoked `bubbles.plan` for
this reconciliation. The active cloud session index and current VS Code debug
log contain no recoverable dispatch IDs or timestamps for those earlier owner
runs. This report therefore records their existence and artifact outcome with
`operator-confirmed` provenance and intentionally records no invented runtime
identifier or execution time.

### Planning Owner Dispatch Ledger

| Order | Owner | Invocation provenance | Owned result | Outcome |
| --- | --- | --- | --- | --- |
| 1 | `bubbles.analyst` | operator-confirmed prior owner dispatch | Final 17-scenario requirements in `spec.md` | `completed_owned` |
| 2 | `bubbles.ux` | operator-confirmed prior owner dispatch | Final terminal UX contract inline in `spec.md` | `completed_owned` |
| 3 | `bubbles.design` | operator-confirmed prior owner dispatch; design profile check supplied with exit 0 | Final baseline/result/classifier design in `design.md` | `completed_owned` |
| 4 | `bubbles.plan` | current direct specialist invocation | `scopes.md`, `scenario-manifest.json`, `test-plan.json`, report/uservalidation templates, execution-owned state | `route_required` to `bubbles.test` |

No owner role was emulated inline, no foreign-owned artifact was edited, and
no certification field/status was changed. The next required owner after the
planning gates pass is `bubbles.test` for final-byte causal RED.

## Test Integrity Remediation

### Contract Comparison And Active Freeze

**Phase:** test
**Claim Source:** executed

The exact original bytes were recovered from VS Code Local History entry
`pfKm.sh`; that snapshot hashes to
`a5e693adda580bf561c4d3700bdabaa103993e2f61dc523e71fb3efd98ba2b31`.
A complete byte diff against the current file found exactly one change: the
current file has a trailing newline after the final `exit 0`; the recovered
snapshot does not. The 17 scenario IDs, fixtures, assertions, controls, and
expected outcomes are byte-identical. The current test therefore neither
weakens, alters, nor expands the frozen behavioral contract.

The approved `apply_patch` surface rejected the no-final-newline marker. No
shell file write was used. `bubbles.test` explicitly supersedes the old byte
identity while preserving it as audit history and freezes the semantically
identical current file at:

```text
sha256:3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
```

### Active Freeze Integrity Checks

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && shasum -a 256 tests/regression/test_30_planning_transition_applicability_and_baseline.sh && bash -n tests/regression/test_30_planning_transition_applicability_and_baseline.sh && printf '%s\n' 'BUG023_SYNTAX=PASS' && bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_30_planning_transition_applicability_and_baseline.sh && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_30_planning_transition_applicability_and_baseline.sh && if grep -nE 't\.Skip|\.skip\(|xit\(|xdescribe\(|\.only\(|test\.todo|it\.todo|pending\(' tests/regression/test_30_planning_transition_applicability_and_baseline.sh; then printf '%s\n' 'BUG023_SKIP_MARKERS=FAIL'; exit 1; else printf '%s\n' 'BUG023_SKIP_MARKERS=PASS matches=0'; fi && if grep -nE 'page\.route\(|context\.route\(|msw|nock|intercept\(|jest\.fn|sinon\.stub|mock\(' tests/regression/test_30_planning_transition_applicability_and_baseline.sh; then printf '%s\n' 'BUG023_LIVE_MOCKS=FAIL'; exit 1; else printf '%s\n' 'BUG023_LIVE_MOCKS=PASS matches=0'; fi`
**Exit Code:** 0
**Claim Source:** executed

```text
3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81  tests/regression/test_30_planning_transition_applicability_and_baseline.sh
BUG023_SYNTAX=PASS
== macOS portability guard -- scanning 1 file(s) ==
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
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
BUG023_SKIP_MARKERS=PASS matches=0
BUG023_LIVE_MOCKS=PASS matches=0
```

### Active Pre-Fix Causal RED

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh; matrix_exit=$?; printf 'FULL_MATRIX_EXIT=%s\n' "$matrix_exit"; if [[ "$matrix_exit" -eq 1 ]]; then exit 0; else exit "$matrix_exit"; fi`
**Exit Code:** 0 (evidence wrapper); matrix exit `1`
**Claim Source:** executed

The full unfiltered output contains 961 lines and hashes to
`sha256:5c83a226f015df52e61212364d0949d63fce8febf5e10278dff7f39e42292da9`.
The terminal summary below is lines 943-961 of that output.

```text
PASS-CONTROL[SCN-BUG-023-017]: legacy guard synthesizes no baseline declaration
PASS-CONTROL[SCN-BUG-023-017]: legacy lockout does not mutate protected dirt
============================================================
PASS_CONTROLS=270
CAUSAL_FAILURES=202
G040_CAUSAL_FAILURES=79
G060_CAUSAL_FAILURES=15
G073_CAUSAL_FAILURES=108
CONTROL_FAILURES=0
HARNESS_FAILURES=0
GUARD_RUNS=66
BASELINE_RUNS=65
============================================================
RED_CLASSIFICATION=CAUSAL_BUG_CONTRACT_FAILURE
RED_CAUSAL_PROVEN=1
FULL_MATRIX_EXIT=1
```

This is a valid current pre-fix RED: every gate family has causal failures,
while unrelated controls and the harness remain green. The current G073 count
is lower than the historical count because the pre-existing untracked helper
candidates execute part of the G073 contract; canonical guard integration and
V2 serialization remain causally RED. No implementation credit is assigned.

### Production Containment And Packet Audit

**Phase:** test
**Claim Source:** executed

Production-source SHA-256 values were captured before and after the matrix and
were identical. This test pass changed no production guard/helper source. The
three helper candidates were already untracked before this remediation:

```text
28f8f81ea0c3dc752207efefee2e3de05295e0fecd810f4915c1315e1ac530be  bubbles/scripts/guards/g040-deferral-classifier.sh
edc097d224c953d0a2349f9cffeb50bdcd6d8e43ace1060515f066a52da69baa  bubbles/scripts/guards/g073-source-state.sh
e2eabd0093d8de3b8adc81cf45aa8e98804f45839c1fabaf21fa5f8ebc24890b  bubbles/scripts/planning-source-baseline.sh
a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538  bubbles/scripts/state-transition-guard.sh
08f09b51c0733b796e9a4a750cd1536a7b709934019f9df4e123706991566f4c  bubbles/scripts/guards/control-plane-checks.sh
```

The packet visibly contained only `bug.md`, `scenario-manifest.json`,
`state.json`, and `uservalidation.md` before this report was restored from its
authenticated Local History snapshot. `spec.md`, `design.md`, `scopes.md`, and
`test-plan.json` remain absent on disk. Substantive owner-authored snapshots are
recoverable, but `bubbles.test` does not own those files and did not restore
them. Implementation is not authorized until the planning owners restore and
verify the packet.

### Current Packet Lint And Scenario Linkage

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh lint improvements/BUG-023-planning-transition-applicability-and-baseline; lint_exit=$?; printf 'BUG023_ARTIFACT_LINT_EXIT=%s\n' "$lint_exit"; exit "$lint_exit"`
**Exit Code:** 1
**Claim Source:** executed

```text
Missing required artifact: improvements/BUG-023-planning-transition-applicability-and-baseline/spec.md
Missing required artifact: improvements/BUG-023-planning-transition-applicability-and-baseline/design.md
Required artifact exists: uservalidation.md
Required artifact exists: state.json
Missing required artifact: improvements/BUG-023-planning-transition-applicability-and-baseline/scopes.md
Required artifact exists: report.md
No forbidden sidecar artifacts present
Detected state.json status: in_progress
Detected state.json workflowMode: bugfix-fastlane
Top-level status matches certification.status
report.md contains section matching: Summary
report.md contains section matching: Completion Statement
report.md contains section matching: Test Evidence
No unfilled evidence template placeholders in report.md
Artifact lint FAILED with 3 issue(s).
BUG023_ARTIFACT_LINT_EXIT=1
```

**Phase:** test
**Command:** `cd /Users/pkirsanov/Projects/bubbles && manifest='improvements/BUG-023-planning-transition-applicability-and-baseline/scenario-manifest.json'; test_file='tests/regression/test_30_planning_transition_applicability_and_baseline.sh'; scenario_count=$(jq -r '.scenarios | length' "$manifest"); printf 'SCENARIO_MANIFEST_COUNT=%s\n' "$scenario_count"; mapping_failures=0; for scenario_id in $(jq -r '.scenarios[].scenarioId' "$manifest"); do if grep -Fq "$scenario_id" "$test_file"; then printf 'SCENARIO_MAPPING_PASS=%s\n' "$scenario_id"; else printf 'SCENARIO_MAPPING_FAIL=%s\n' "$scenario_id"; mapping_failures=$((mapping_failures + 1)); fi; done; printf 'SCENARIO_MAPPING_FAILURES=%s\n' "$mapping_failures"; if [[ "$scenario_count" -eq 17 && "$mapping_failures" -eq 0 ]]; then exit 0; else exit 1; fi`
**Exit Code:** 0
**Claim Source:** executed

```text
SCENARIO_MANIFEST_COUNT=17
SCENARIO_MAPPING_PASS=SCN-BUG-023-001
SCENARIO_MAPPING_PASS=SCN-BUG-023-002
SCENARIO_MAPPING_PASS=SCN-BUG-023-003
SCENARIO_MAPPING_PASS=SCN-BUG-023-004
SCENARIO_MAPPING_PASS=SCN-BUG-023-005
SCENARIO_MAPPING_PASS=SCN-BUG-023-006
SCENARIO_MAPPING_PASS=SCN-BUG-023-007
SCENARIO_MAPPING_PASS=SCN-BUG-023-008
SCENARIO_MAPPING_PASS=SCN-BUG-023-009
SCENARIO_MAPPING_PASS=SCN-BUG-023-010
SCENARIO_MAPPING_PASS=SCN-BUG-023-011
SCENARIO_MAPPING_PASS=SCN-BUG-023-012
SCENARIO_MAPPING_PASS=SCN-BUG-023-013
SCENARIO_MAPPING_PASS=SCN-BUG-023-014
SCENARIO_MAPPING_PASS=SCN-BUG-023-015
SCENARIO_MAPPING_PASS=SCN-BUG-023-016
SCENARIO_MAPPING_PASS=SCN-BUG-023-017
SCENARIO_MAPPING_FAILURES=0
```
