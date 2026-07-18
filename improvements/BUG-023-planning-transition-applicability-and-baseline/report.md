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

## Current-Byte Identity Reconciliation - 2026-07-18

### Classification And Boundary

`bubbles.test` executed the exact frozen full matrix against one stable source
snapshot. That snapshot is GREEN, not causal RED, invalid RED, or partial
implementation: all 575 controls passed; G040, G060, and G073 each recorded
zero causal failures; control and harness failures were zero; and all 66 guard
runs plus 65 baseline runs completed. The frozen test remained SHA-256
`3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81`.

The GREEN claim is bound only to
`bubbles/scripts/state-transition-guard.sh` SHA-256
`426ecb1806370220b8bd9d72f7f67dc0731d81c68141f1bdd89ecca9d469f96c`.
That identity matched the pre-run and immediate post-matrix fences. Before
canonical framework validation could start, the protected producer moved to
SHA-256
`c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857`.
The current tree is therefore `UNVERIFIED_AFTER_PROTECTED_PRODUCER_DRIFT`.
No RED or GREEN result is attributed to the later producer bytes.

### Pre-Run And Tested Source Fence

**Phase:** test
**Command:** double SHA-256 observation around `git status --porcelain=v2 --untracked-files=all`, staged/unstaged name-status, and a targeted BUG-023 process scan
**Exit Code:** 0
**Claim Source:** executed

```text
OBSERVED_AT=2026-07-18T03:37:54Z
HEAD=1afb02c98c156e7daf1811f0fe94d6133d9bf5fb
HASH_A test_30=3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
HASH_A state_transition_guard=426ecb1806370220b8bd9d72f7f67dc0731d81c68141f1bdd89ecca9d469f96c
HASH_A control_plane_checks=f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b
HASH_A g040_classifier=28f8f81ea0c3dc752207efefee2e3de05295e0fecd810f4915c1315e1ac530be
HASH_A g073_source_state=edc097d224c953d0a2349f9cffeb50bdcd6d8e43ace1060515f066a52da69baa
HASH_A planning_source_baseline=e2eabd0093d8de3b8adc81cf45aa8e98804f45839c1fabaf21fa5f8ebc24890b
HASH_B test_30=3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
HASH_B state_transition_guard=426ecb1806370220b8bd9d72f7f67dc0731d81c68141f1bdd89ecca9d469f96c
HASH_B control_plane_checks=f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b
HASH_B g040_classifier=28f8f81ea0c3dc752207efefee2e3de05295e0fecd810f4915c1315e1ac530be
HASH_B g073_source_state=edc097d224c953d0a2349f9cffeb50bdcd6d8e43ace1060515f066a52da69baa
HASH_B planning_source_baseline=e2eabd0093d8de3b8adc81cf45aa8e98804f45839c1fabaf21fa5f8ebc24890b
FENCE_HASH_MISMATCHES=0
FROZEN_TEST_IDENTITY=MATCH
```

One independently started `test_30` process was active in a different
disposable workspace at the initial fence. It changed no canonical byte. The
targeted process scan was clear at the immediate post-matrix fence.

### Exact Full Matrix Result

**Phase:** test
**Command:** `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh; matrix_exit=$?; printf 'FULL_MATRIX_EXIT=%s\n' "$matrix_exit"; if [[ "$matrix_exit" -eq 1 ]]; then exit 0; else exit "$matrix_exit"; fi`
**Exit Code:** 0
**Claim Source:** executed

The complete output contains 1,024 lines and has SHA-256
`d288af109b4bf027b36d1d5b8332f7dcb2a60171b5495c0246d8d190c7a0df0e`.
The opening V2 controls and terminal outcome were:

```text
BUG-023 planning transition applicability and baseline matrix
canonical-root: /Users/pkirsanov/Projects/bubbles
canonical-version: 7.20.0
test-sha256: 3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
selection: all-17-scenarios
PASS-CONTROL[SCN-BUG-023-001]: planning fixture reaches canonical G060
PASS-CONTROL[SCN-BUG-023-001]: planning-maturity-v1 emits the fixed G060 NOT_APPLICABLE human block
PASS-CONTROL[SCN-BUG-023-001]: planning_g060_not_applicable emits one canonical digest-bound V2 transition result
PASS-CONTROL[SCN-BUG-023-001]: planning_g060_not_applicable has exactly one G060 NOT_APPLICABLE/PROFILE_PLANNING_MATURITY result
PASS-CONTROL[SCN-BUG-023-001]: planning_g060_not_applicable records G060 as N/A without pass/fail attribution
PASS_CONTROLS=575
CAUSAL_FAILURES=0
G040_CAUSAL_FAILURES=0
G060_CAUSAL_FAILURES=0
G073_CAUSAL_FAILURES=0
CONTROL_FAILURES=0
HARNESS_FAILURES=0
GUARD_RUNS=66
BASELINE_RUNS=65
GREEN_REGRESSION_VERDICT=BUG_023_CONTRACT_SATISFIED
FULL_MATRIX_EXIT=0
```

### V2 Schema Health

The same execution directly proved these consumer-facing V2 contracts:

- planning G060 is exactly one `NOT_APPLICABLE` /
  `PROFILE_PLANNING_MATURITY` result and is absent from pass/fail attribution;
- both delivery modes preserve missing, GREEN-before-RED, and ordered outcomes;
- G040 emits canonical digest-bound V2 details for accepted, blocked,
  structural, no-match, precedence, and content-withholding vectors;
- G073 emits canonical digest-bound V2 details for equality, mutation,
  invalid provenance, retry, races, and legacy lockout;
- the audit-result consumer selftest passed and covered reordered V2 fields,
  noncanonical JSON, digest mismatch, planning G060 false pass, delivery G060
  false N/A, actionable audited G073, and wrong failed-G073 outer code.

### Focused Integrity And Packet Checks

**Phase:** test
**Claim Source:** executed

| Check | Result |
| --- | --- |
| Frozen identity | Test SHA-256 remained `3db995...e2bd81`. |
| Bash 3.2 syntax | Test and five protected producer/helper files parsed; zero failures. |
| Regression quality | One adversarial file; zero violations and zero warnings. |
| Skip/only/todo scan | Zero matches. |
| Live mock/interception scan | Zero matches. |
| Focused portability | Six BUG-023 files passed all 13 WSL/macOS classes. |
| Artifact lint | Exit 0; only the existing deprecated `certification.scopeProgress` warning. |
| Artifact freshness | Exit 0; zero failures and warnings. |
| G094 | Exit 0; foundation tag and overlay dependency ordering accepted. |
| Traceability | Exit 0; 17 scenarios, 44 rows, and 17/17 DoD mappings. |
| Strict parity | 44 Markdown rows, 44 JSON rows, 44 unchecked test DoD items, 44 report anchors, 17 scenarios, zero field mismatches. |

The exact planned portability command scanning all `bubbles/scripts` was also
executed. It scanned 267 files and reported all 13 violation classes, including
the portability guard's own adversarial fixtures and unrelated pre-existing
framework files. The six-file BUG-023 discriminator then passed all 13 classes.
Because the 267-file command cannot isolate this packet's shell boundary,
`BUG-023-T040-OVERBROAD-PORTABILITY-SURFACE` is retained for `bubbles.plan`.

### Protected Producer Drift

**Phase:** test
**Command:** `shasum -a 256 bubbles/scripts/state-transition-guard.sh tests/regression/test_30_planning_transition_applicability_and_baseline.sh bubbles/scripts/guards/control-plane-checks.sh bubbles/scripts/guards/g040-deferral-classifier.sh bubbles/scripts/guards/g073-source-state.sh bubbles/scripts/planning-source-baseline.sh` plus targeted process and diff-size checks
**Exit Code:** 0
**Claim Source:** executed

```text
OBSERVED_AT=2026-07-18T03:52:08Z
TESTED_STATE_TRANSITION_GUARD_SHA256=426ecb1806370220b8bd9d72f7f67dc0731d81c68141f1bdd89ecca9d469f96c
CURRENT_STATE_TRANSITION_GUARD_SHA256=c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857
TEST_SHA256=3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
CONTROL_PLANE_SHA256=f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b
G040_CLASSIFIER_SHA256=28f8f81ea0c3dc752207efefee2e3de05295e0fecd810f4915c1315e1ac530be
G073_SOURCE_STATE_SHA256=edc097d224c953d0a2349f9cffeb50bdcd6d8e43ace1060515f066a52da69baa
PLANNING_BASELINE_SHA256=e2eabd0093d8de3b8adc81cf45aa8e98804f45839c1fabaf21fa5f8ebc24890b
STATE_TRANSITION_GUARD_NUMSTAT=411 additions,69 deletions
TARGETED_PROCESS_SCAN=ACTIVE
FRAMEWORK_VALIDATE=NOT_RUN_PROTECTED_PRODUCER_MOVED
```

The active process was another canonical guard invocation in a disposable
fixture. No attempt was made to normalize, revert, edit, or retest the moving
producer. The exact owner is `bubbles.implement`.

### Finding Accounting And Routing

| Finding | Disposition | Owner |
| --- | --- | --- |
| `BUG-023-RECOVERY-CONTAINMENT-BASELINE-STALE` | Addressed for the tested snapshot: all six identities were double-observed and the exact full matrix completed. | `bubbles.test` |
| `BUG-023-RED-G060` | Satisfied at tested guard `426ecb...f96c`: zero G060 causal failures and all planning/delivery controls passed. | `bubbles.test` evidence |
| `BUG-023-RED-G040` | Satisfied at tested guard `426ecb...f96c`: zero G040 causal failures and all finite classifier vectors passed. | `bubbles.test` evidence |
| `BUG-023-RED-G073` | Satisfied at tested guard `426ecb...f96c`: zero G073 causal failures across lifecycle, equality, mutation, provenance, retry, race, and legacy vectors. | `bubbles.test` evidence |
| `BUG-023-PROTECTED-PRODUCER-MOVED-DURING-TEST` | Open: current guard `c00c9c...2857` has no matrix verdict; framework validation was not run. | `bubbles.implement` |
| `BUG-023-T040-OVERBROAD-PORTABILITY-SURFACE` | Open: the exact 267-file command reports unrelated and selftest-fixture classes while the six BUG-023 files pass. | `bubbles.plan` |
| `BUG-023-RECOVERY-STATE-SCOPEPROGRESS-DEPRECATED` | Preserved warning; certification ownership was not crossed. | `bubbles.validate` |

Outcome is `route_required` to `bubbles.implement` for the protected producer
drift. `implementationAuthorized` remains false because no stable current-byte
RED exists and the current guard bytes were not tested. No DoD checkbox,
scope status, top-level status, certification field, release surface,
downstream packet, BUG-022 packet, or Feature 007 packet was changed.

### Final Non-Executing Fence

**Phase:** test
**Command:** final SHA-256 and targeted process/status fence without behavior execution
**Exit Code:** 0
**Claim Source:** executed

```text
OBSERVED_AT=2026-07-18T03:56:03Z
HEAD=1afb02c98c156e7daf1811f0fe94d6133d9bf5fb
TEST_SHA256=3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
CURRENT_STATE_TRANSITION_GUARD_SHA256=c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857
CONTROL_PLANE_SHA256=f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b
G040_CLASSIFIER_SHA256=28f8f81ea0c3dc752207efefee2e3de05295e0fecd810f4915c1315e1ac530be
G073_SOURCE_STATE_SHA256=edc097d224c953d0a2349f9cffeb50bdcd6d8e43ace1060515f066a52da69baa
PLANNING_BASELINE_SHA256=e2eabd0093d8de3b8adc81cf45aa8e98804f45839c1fabaf21fa5f8ebc24890b
TARGETED_PROCESS_SCAN=CLEAR
CURRENT_TREE_CLASSIFICATION=UNVERIFIED_AFTER_PROTECTED_PRODUCER_DRIFT
```

## Implementation-Owner Producer Reconciliation - 2026-07-18

### Classification

**Phase:** implement
**Claim Source:** executed and interpreted

The current tree is classified as
`PARTIAL_IMPLEMENTATION_WITH_FOREIGN_OVERLAP_AND_CONCURRENT_DRIFT`.
The exact tested guard snapshot was recovered from VS Code Local History entry
`WANz.sh`; its SHA-256 is the previously recorded
`426ecb1806370220b8bd9d72f7f67dc0731d81c68141f1bdd89ecca9d469f96c`.
Entry `QgeF.sh` is byte-identical to the current guard at
`c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857`.
The complete delta is two G040 human-message substitutions. No gate-result
JSON, classifier, count, digest, applicability, actionability, or verdict byte
changed.

The current V2 producer/consumer slice is source-coherent under the checks
executed here: all eight shell files parse under `/bin/bash -n`, and the strict
audit-result consumer selftest passes 30/30 mutation cases. The suspected
missing `list_contains` helper is present, and malformed/noncanonical
`gateResults` plus digest and cross-field mutations are rejected without
weakening validation. No source edit was applied by this invocation.

The complete planned implementation is not structurally closed. The MCP
descriptor, workflow capture reference, capability registration, dedicated
baseline selftest, and framework-validation wiring each have an observed count
of zero. The workflow/agent and test portions have foreign owners; no foreign
artifact was edited. During this reconciliation the managed
`state-transition-guard-selftest.sh` changed from SHA-256
`eb3f309f612cc2f1a94e903afc7dd6b18fc626d46287119f2c4b0c1601e622c9`
to `5bfd966c00e76cd7c363e6476f48bcd896f8b57d87cd89aab40edeec374b1e63`
while another managed selftest/guard process was active. Source work stopped
at that fence. The frozen `test_30` matrix and broad framework validation were
not run in this implementation phase.

### Exact Tested-To-Current Producer Delta

**Phase:** implement
**Command:** `git --no-pager diff --no-index --unified=8 "$HOME/Library/Application Support/Code/User/History/-489e6a65/WANz.sh" bubbles/scripts/state-transition-guard.sh`
**Exit Code:** 1 (expected: exact snapshots differ)
**Claim Source:** executed

```text
BUG023_TESTED_TO_CURRENT_DIFF_BEGIN
@@ -3291,21 +3291,21 @@
 print(json.dumps(details, sort_keys=True, separators=(",", ":")))
 PY
  g040_details_json="$(cat "$g040_details_file")"

  if [[ "$g040_blocking_scope_count" -gt 0 ]]; then
-    fail "Scope artifact contains $g040_blocking_scope_count classified deferral line(s) — SPEC CANNOT BE DONE WITH DEFERRED WORK (Gate G040)"
+    fail "Scope artifact contains $g040_blocking_scope_count deferral language hit(s) from classified line(s) — SPEC CANNOT BE DONE WITH DEFERRED WORK (Gate G040)"
    fun_message deferral_blocks_done
  fi
  if [[ "$g040_blocking_report_count" -gt 0 ]]; then
-    fail "Report artifact contains $g040_blocking_report_count classified deferral line(s) — evidence of deferred work (Gate G040)"
+    fail "Report artifact contains $g040_blocking_report_count deferral language hit(s) from classified line(s) — evidence of deferred work (Gate G040)"
  fi

  g040_result_json="$(jq -cS -n \
BUG023_TESTED_TO_CURRENT_DIFF_EXIT=1
BUG023_TESTED_TO_CURRENT_DIFF_END
```

Local History metadata records `WANz.sh` before `QgeF.sh`; both snapshots and
the current file have 3,824 lines. The observed identities were:

```text
BUG023_SNAPSHOT_STATS_BEGIN
    3824 .../History/-489e6a65/WANz.sh
    3824 .../History/-489e6a65/QgeF.sh
    3824 .../bubbles/scripts/state-transition-guard.sh
   11472 total
426ecb1806370220b8bd9d72f7f67dc0731d81c68141f1bdd89ecca9d469f96c  .../History/-489e6a65/WANz.sh
c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857  .../History/-489e6a65/QgeF.sh
c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857  .../bubbles/scripts/state-transition-guard.sh
BUG023_SNAPSHOT_STATS_END
```

### Focused Source-Coherence Checks

**Phase:** implement
**Command:** `/bin/bash -n` for the eight current BUG-023 producer, helper, and consumer shell files
**Exit Code:** 0
**Claim Source:** executed

```text
BUG023_BASH_SYNTAX_BEGIN
CHECK bubbles/scripts/state-transition-guard.sh
CHECK bubbles/scripts/guards/control-plane-checks.sh
CHECK bubbles/scripts/audit-result-contract-lint.sh
CHECK bubbles/scripts/audit-result-contract-lint-selftest.sh
CHECK bubbles/scripts/state-transition-guard-selftest.sh
CHECK bubbles/scripts/guards/g040-deferral-classifier.sh
CHECK bubbles/scripts/guards/g073-source-state.sh
CHECK bubbles/scripts/planning-source-baseline.sh
BUG023_BASH_SYNTAX_EXIT=0
BUG023_BASH_SYNTAX_END
```

**Phase:** implement
**Command:** `bash bubbles/scripts/audit-result-contract-lint-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
Running BUG-009 S04 audit result contract selftest...
PASS: planning clean view is exact and profile-bound
PASS: planning rework view names a concrete owner
PASS: delivery refusal preserves DO_NOT_SHIP semantics
PASS: metadata uncertainty is BLOCKED without fallback semantics
PASS: source-edit lockout is BLOCKED on G073
PASS: interruption leaves no current pointer or active verdict
PASS: rework supersedes prior result and preserves the finding one-to-one
PASS: duplicate AUDIT_RESULT_V1 block is rejected
PASS: missing frozen field is rejected
PASS: reordered frozen fields are rejected
PASS: malformed collection is rejected
PASS: planning shipment language is rejected
PASS: planning PASS claim for non-applicable delivery check is rejected
PASS: stale contract digest is rejected against guard provenance
PASS: stale target revision is rejected against guard provenance
PASS: transition-guard-result/v2 schema mismatch is rejected
PASS: reordered V2 field is rejected
PASS: noncanonical gateResults is rejected
PASS: gateResultsDigest mismatch is rejected
PASS: planning G060 pass rejected
PASS: delivery G060 N/A rejected
PASS: audited G073 actionable rejected
PASS: failed G073 blockingCode rejected
PASS: delivery verdict drift is rejected
PASS: ANSI/color output is rejected
PASS: multiple ACTIVE attempts are rejected
PASS: dangling currentAttemptId is rejected
PASS: disappearing prior finding is rejected
PASS: canonical audit agent passes structural contract lint
PASS: Audit A1 wording is profile-scoped and registry-resolved
audit-result-contract-lint-selftest: 30 passed, 0 failed
BUG023_AUDIT_CONTRACT_SELFTEST_EXIT=0
```

### Concurrent Movement Fence

**Phase:** implement
**Command:** SHA-256 fence over the protected producer/consumer set plus a targeted process scan
**Exit Code:** 0
**Claim Source:** executed

```text
FENCE_A state-transition-guard.sh=c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857
FENCE_A control-plane-checks.sh=f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b
FENCE_A test_30=3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
FENCE_A audit-result-contract-lint.sh=e4583cd29ebc258552b618ffa5316d599f700faf87eabbea7f797ee218201365
FENCE_A audit-result-contract-lint-selftest.sh=cf46803a6923e1f6db073be15a797ff43c174828d9972a33bdb0d03aaa2a2d41
FENCE_A state-transition-guard-selftest.sh=eb3f309f612cc2f1a94e903afc7dd6b18fc626d46287119f2c4b0c1601e622c9
FENCE_B state-transition-guard.sh=c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857
FENCE_B control-plane-checks.sh=f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b
FENCE_B test_30=3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81
FENCE_B audit-result-contract-lint.sh=e4583cd29ebc258552b618ffa5316d599f700faf87eabbea7f797ee218201365
FENCE_B audit-result-contract-lint-selftest.sh=cf46803a6923e1f6db073be15a797ff43c174828d9972a33bdb0d03aaa2a2d41
FENCE_B state-transition-guard-selftest.sh=5bfd966c00e76cd7c363e6476f48bcd896f8b57d87cd89aab40edeec374b1e63
TARGETED_PROCESS pid=14558 command=bash bubbles/scripts/state-transition-guard-selftest.sh
TARGETED_PROCESS pid=19931 command=bash .../bubbles/scripts/state-transition-guard.sh .../specs/925-g040-positive-skip-marker-outside
CONCURRENT_MOVEMENT=state-transition-guard-selftest.sh
SOURCE_EDITS_BY_THIS_INVOCATION=0
```

### Finding Accounting And Route

| Finding | Disposition | Owner |
| --- | --- | --- |
| `BUG-023-PROTECTED-PRODUCER-MOVED-DURING-TEST` | Addressed for implementation reconciliation: the exact `426ecb...` to `c00c9c...` delta was recovered and the current guard stayed stable across both implementation fences. This is not a matrix verdict. | `bubbles.implement` |
| `BUG-023-V2-CONSUMER-HELPER-AND-JSON-VALIDATION` | Addressed: `list_contains` exists and 30/30 strict V2 consumer mutations passed, including malformed/noncanonical JSON and digest rejection. | `bubbles.implement` |
| `BUG-023-MANAGED-SELFTEST-MOVED-DURING-IMPLEMENTATION-RECONCILIATION` | Open: the managed selftest changed identity during this phase while a foreign test process was active. | `bubbles.test` via `bubbles.workflow` serialization |
| `BUG-023-IMPLEMENTATION-LIFECYCLE-INTEGRATION-INCOMPLETE` | Open: five design-required registration/orchestration/selftest wiring counts are zero; mixed ownership prevents an implementation-only completion claim. | `bubbles.workflow` |
| `BUG-023-T040-OVERBROAD-PORTABILITY-SURFACE` | Preserved unchanged as plan-owned. No source edit absorbed it. | `bubbles.plan` |
| `BUG-023-RECOVERY-STATE-SCOPEPROGRESS-DEPRECATED` | Preserved unchanged; no certification field was edited. | `bubbles.validate` |

Outcome is `route_required` to `bubbles.workflow` to serialize the moving
test-owned consumer and the remaining mixed-owner lifecycle integration. A
direct route to `bubbles.test` is not emitted because all implementation-owned
source contracts are not yet structurally present. No test verdict, scope
completion, DoD completion, release identity, propagation, or downstream
claim is made.

## Implementation-Owned Lifecycle Integration - 2026-07-18

### Scope And Classification

**Phase:** implement
**Claim Source:** executed and interpreted

The two implementation-owned lifecycle surfaces are now structurally present:

| Surface | SHA-256 | Result |
| --- | --- | --- |
| `bubbles/mcp/tools/capture_planning_source_baseline.json` | `b92569f2683bd73f45f736d924d7e3b5f66ffeb89f1e2209e45b5c890ad20b29` | Catalog wrapper loads once, accepts no observed identity input, and renders the authoritative Bash twin argv for capture and close. |
| `bubbles/scripts/framework-validate.sh` | `afb89b189d6e37367eb5ccd2a3f91eeb773817c0a02ad3b2dfdb8a31e9b260d9` | Registers the dedicated baseline selftest under the established file-presence contract and registers persistent `test_30` once in bug-number order. |

The catalog wrapper accepts only lifecycle action, feature directory, the
schema-closed `--outcome` transport token required by the generic MCP argv
renderer, and the `completed|aborted` outcome enum. Repository identity, HEAD,
workflow mode, audit profile, transition-contract digest, protected paths, and
observed identities remain resolved exclusively by
`planning-source-baseline.sh`.

The dedicated baseline selftest is still absent and owned by `bubbles.test`.
Its registration uses the existing `if [[ -f ... ]]; then run_check ... fi`
contract: framework validation remains usable before that owner lands the
file, and a present selftest executes through `run_check` without `|| true`,
skip, or failure suppression. The persistent regression is registered through
`run_check_self_only`, matching the source-repository regression convention.
Neither the frozen regression nor framework validation was run as a GREEN
claim in this phase.

### Descriptor, Catalog, And Registration Static Evidence

**Phase:** implement
**Executed:** YES (current session)
**Claim Source:** executed
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG023_RECORDED_STATIC_EVIDENCE_BEGIN'; PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -c 'import importlib.util,json,logging,pathlib; root=pathlib.Path("."); descriptor=json.loads((root/"bubbles/mcp/tools/capture_planning_source_baseline.json").read_text()); spec=importlib.util.spec_from_file_location("bug023_mcp",root/"bubbles/mcp/server.py"); module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module); feature="improvements/BUG-023-planning-transition-applicability-and-baseline"; assert module._render_args(descriptor["argsTemplate"],{"action":"capture","feature_dir":feature}) == ["capture",feature]; assert module._render_args(descriptor["argsTemplate"],{"action":"close","feature_dir":feature,"outcome_option":"--outcome","outcome":"completed"}) == ["close",feature,"--outcome","completed"]; assert module.ToolCatalog(root/"bubbles/mcp",root/"bubbles/scripts",logging.getLogger("bug023")).get("capture_planning_source_baseline") is not None; assert not any(token in descriptor["inputSchema"]["properties"] for token in ("observed_path","repository_id","start_head","contract_digest","payload_digest")); print("descriptor_json=PASS"); print("catalog_load=PASS"); print("capture_argv=PASS"); print("close_argv=PASS"); print("caller_observation_inputs_absent=PASS")'; descriptor_exit=$?; /bin/bash -n bubbles/scripts/framework-validate.sh; syntax_exit=$?; printf 'framework_syntax_exit=%s\n' "$syntax_exit"; baseline_count="$(/usr/bin/grep -cF 'Planning source baseline selftest (BUG-023)' bubbles/scripts/framework-validate.sh)"; regression_count="$(/usr/bin/grep -cF 'BUG-023 planning transition applicability and baseline regression' bubbles/scripts/framework-validate.sh)"; printf 'baseline_registration_count=%s\n' "$baseline_count"; printf 'regression_registration_count=%s\n' "$regression_count"; /usr/bin/git diff --check -- bubbles/scripts/framework-validate.sh; diff_exit=$?; printf 'framework_diff_check_exit=%s\n' "$diff_exit"; [[ "$descriptor_exit" -eq 0 && "$syntax_exit" -eq 0 && "$baseline_count" -eq 1 && "$regression_count" -eq 1 && "$diff_exit" -eq 0 ]]; evidence_exit=$?; printf 'recorded_static_evidence_exit=%s\n' "$evidence_exit"; printf '%s\n' 'BUG023_RECORDED_STATIC_EVIDENCE_END'; exit "$evidence_exit"
```

**Exit Code:** 0
**Output:**

```text
BUG023_RECORDED_STATIC_EVIDENCE_BEGIN
descriptor_json=PASS
catalog_load=PASS
capture_argv=PASS
close_argv=PASS
caller_observation_inputs_absent=PASS
framework_syntax_exit=0
baseline_registration_count=1
regression_registration_count=1
framework_diff_check_exit=0
recorded_static_evidence_exit=0
BUG023_RECORDED_STATIC_EVIDENCE_END
```

**Result:** PASS

The in-memory catalog check loaded the real `ToolCatalog` with bytecode writes
disabled and asserted exact rendered argv:

```text
capture improvements/BUG-023-planning-transition-applicability-and-baseline
close improvements/BUG-023-planning-transition-applicability-and-baseline --outcome completed
```

No mutating baseline dispatch was executed by this static check.

### Framework Registration And Containment Interpretation

**Phase:** implement
**Claim Source:** interpreted from the exact static command above

VS Code diagnostics reported zero errors for both changed files. No existing
producer, consumer, managed selftest, frozen regression, BUG-021 registration,
or BUG-022 guarded-array repair was edited by this lifecycle slice.

### Stable Identity Fence

**Phase:** implement
**Executed:** YES (current session)
**Claim Source:** executed
**Command:**

```bash
cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG023_RECORDED_HASH_EVIDENCE_BEGIN'; /usr/bin/shasum -a 256 bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/control-plane-checks.sh bubbles/scripts/guards/g040-deferral-classifier.sh bubbles/scripts/guards/g073-source-state.sh bubbles/scripts/planning-source-baseline.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/audit-result-contract-lint.sh bubbles/scripts/audit-result-contract-lint-selftest.sh tests/regression/test_30_planning_transition_applicability_and_baseline.sh improvements/BUG-023-planning-transition-applicability-and-baseline/design.md bubbles/mcp/tools/capture_planning_source_baseline.json bubbles/scripts/framework-validate.sh improvements/BUG-023-planning-transition-applicability-and-baseline/report.md improvements/BUG-023-planning-transition-applicability-and-baseline/state.json; hash_exit=$?; if [[ -e bubbles/scripts/planning-source-baseline-selftest.sh ]]; then printf '%s\n' 'pending_selftest=PRESENT'; pending_exit=1; else printf '%s\n' 'pending_selftest=MISSING'; pending_exit=0; fi; printf '%s\n' 'relevant_process_scan_begin'; /usr/bin/pgrep -fl 'planning-source-baseline|state-transition-guard|test_30_planning_transition|framework-validate' || true; printf 'hash_command_exit=%s\n' "$hash_exit"; printf 'pending_identity_exit=%s\n' "$pending_exit"; [[ "$hash_exit" -eq 0 && "$pending_exit" -eq 0 ]]; evidence_exit=$?; printf 'recorded_hash_evidence_exit=%s\n' "$evidence_exit"; printf '%s\n' 'BUG023_RECORDED_HASH_EVIDENCE_END'; exit "$evidence_exit"
```

**Exit Code:** 0
**Output:**

```text
BUG023_RECORDED_HASH_EVIDENCE_BEGIN
c00c9cfad5354b9ab8318428f167e72af3dd1b443608dcfd2143a66f20162857  bubbles/scripts/state-transition-guard.sh
f4061d9f41066b31f8803337752268c4e135a17eda4c3383e7b94446ef91222b  bubbles/scripts/guards/control-plane-checks.sh
28f8f81ea0c3dc752207efefee2e3de05295e0fecd810f4915c1315e1ac530be  bubbles/scripts/guards/g040-deferral-classifier.sh
edc097d224c953d0a2349f9cffeb50bdcd6d8e43ace1060515f066a52da69baa  bubbles/scripts/guards/g073-source-state.sh
e2eabd0093d8de3b8adc81cf45aa8e98804f45839c1fabaf21fa5f8ebc24890b  bubbles/scripts/planning-source-baseline.sh
5bfd966c00e76cd7c363e6476f48bcd896f8b57d87cd89aab40edeec374b1e63  bubbles/scripts/state-transition-guard-selftest.sh
e4583cd29ebc258552b618ffa5316d599f700faf87eabbea7f797ee218201365  bubbles/scripts/audit-result-contract-lint.sh
cf46803a6923e1f6db073be15a797ff43c174828d9972a33bdb0d03aaa2a2d41  bubbles/scripts/audit-result-contract-lint-selftest.sh
3db995523b1dd182c55a0dd01aa20776884a8a64a246c709da5055f358e2bd81  tests/regression/test_30_planning_transition_applicability_and_baseline.sh
ca3bda6607c789a8ebd6cb398a2ff6e91286c7690b7a4fbed8f08124ef61373e  improvements/BUG-023-planning-transition-applicability-and-baseline/design.md
b92569f2683bd73f45f736d924d7e3b5f66ffeb89f1e2209e45b5c890ad20b29  bubbles/mcp/tools/capture_planning_source_baseline.json
afb89b189d6e37367eb5ccd2a3f91eeb773817c0a02ad3b2dfdb8a31e9b260d9  bubbles/scripts/framework-validate.sh
917dc5c8cc0f0608b08278770dd59013643d1112ad8fe0f0b1d2d2d8759474cd  improvements/BUG-023-planning-transition-applicability-and-baseline/report.md
a7fba44c6a225542d4de1bee209b7a77ab3915e8c008fdce8dd91e7fe473ef80  improvements/BUG-023-planning-transition-applicability-and-baseline/state.json
pending_selftest=MISSING
relevant_process_scan_begin
hash_command_exit=0
pending_identity_exit=0
recorded_hash_evidence_exit=0
BUG023_RECORDED_HASH_EVIDENCE_END
```

**Result:** PASS

The same protected identities were observed before and after the code edits;
the final targeted process scan was clear.

### Lifecycle Finding Accounting And Route

| Finding | Disposition | Actual owner |
| --- | --- | --- |
| `BUG-023-IMPLEMENTATION-MCP-DESCRIPTOR-ABSENT` | Addressed: the descriptor is catalog-loadable, unique, closed to caller-supplied observation identities, and renders both lifecycle operations to the authoritative twin. | `bubbles.implement` |
| `BUG-023-IMPLEMENTATION-FRAMEWORK-REGISTRATIONS-ABSENT` | Addressed: dedicated selftest and persistent regression registrations are unique, ordered, syntax-clean, and preserve BUG-021/022 registration lines. | `bubbles.implement` |
| `BUG-023-MANAGED-SELFTEST-MOVED-DURING-IMPLEMENTATION-RECONCILIATION` | Open: the current `5bfd966...` identity stayed stable in this phase, but only the test owner may reconcile and verify that managed selftest. | `bubbles.test` |
| `BUG-023-TEST-OWNED-LIFECYCLE-SURFACES-OPEN` | Open: author the dedicated baseline selftest and extend MCP/install-provenance selftests for real capture, reuse, close, catalog, and installed-copy behavior. | `bubbles.test` |
| `BUG-023-WORKFLOW-BASELINE-LIFECYCLE-REFERENCE-MISSING` | Open: the workflow agent still lacks mandatory capture-before-write and close orchestration references. | framework agent/documentation owner |
| `BUG-023-CAPABILITY-REGISTRATION-MISSING` | Open: the authoritative baseline capability and direct/MCP consumers are absent from the capability ledger. | framework capability owner |
| `BUG-023-MANAGED-DOCS-AND-PROJECTION-MISSING` | Open: operating baseline, state gates, scope workflow, control-plane schema, generated capability projection, and changelog publication remain unchanged. | `bubbles.docs` |
| `BUG-023-RELEASE-MANIFEST-REGENERATION-OPEN` | Open: managed/source-only checksums have not been regenerated. | `bubbles.releases` |
| `BUG-023-RECOVERY-STATE-SCOPEPROGRESS-DEPRECATED` | Open and unchanged; no certification field was edited. | `bubbles.validate` |

Outcome is `route_required` directly to `bubbles.test`. The
implementation-owned integrations are coherent and stable, while all
owner-specific findings remain explicit. No certification field, DoD
checkbox, scope status, terminal state, test verdict, release identity,
downstream repository, or Feature 007 surface was changed or claimed.
