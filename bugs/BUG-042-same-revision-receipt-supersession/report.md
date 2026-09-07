# Report: BUG-042 Same-Revision Receipt Supersession

### Summary

This packet records the repaired same-revision receipt selection defect in
`scenario-state-resolve.sh`. The resolver now snapshots one regular-file prefix,
derives physical append ordinals and raw-row digests, selects the latest complete
same-group chain, and classifies historical and current diagnostics separately.

The operator supplied a downstream observation with 34 blockers. This report
does not treat that observation as execution evidence. A smaller hermetic
counterexample provides the current-session reproduction below. The scope
contract remains in [scopes.md](scopes.md), and human acceptance remains in
[uservalidation.md](uservalidation.md).

### Completion Statement

Scope 1 implementation and implementation-owned checks have executed. The bug
remains `in_progress`; only the external-base prerequisite DoD item is checked,
and validation has not certified any scope. No human-acceptance or certification
field changed.

The execution substate is `implemented`. All six resolver findings remain
independently verified, and the imported current bytes route to
`bubbles.regression` under the recorded phase order.

### Test Evidence

#### E-B042-LINT - First focused artifact lint

**Phase:** bug
**Command:** `bash bubbles/scripts/evidence-capture.sh --lines 40 --label 'BUG-042 first focused artifact lint' -- gtimeout 240 bash bubbles/scripts/cli.sh lint bugs/BUG-042-same-revision-receipt-supersession`
**Exit Code:** 0
**Claim Source:** executed

The capture reported `lines: 40` and SHA-256
`182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`.
Its terminal line reports `Artifact lint PASSED.` The command exited 0.

## Bug Reproduction - Before Fix

<a name="e-b042-repro"></a>

#### E-B042-REPRO - Before-fix hermetic discriminator

**Phase:** bug
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve.sh --spec-dir "$fixture" --log "$fixture/historical-receipts.jsonl" --source-revision rev-b042 --require RED_VERIFIED --require IMPLEMENTED --require GREEN_TARGETED --certifiable --format text`, followed by the identical command with `clean-receipts.jsonl`
**Exit Code:** historical 1, clean 0
**Claim Source:** executed
**Result:** FAIL before fix, with a passing clean control

```text
BUG042_HISTORICAL_ROW_CASE_BEGIN
scenario-state-resolve: /private/tmp/bubbles-bug042-hermetic-counterexample
	source revision: rev-b042
	SCN-B042-REPRO  state=GREEN_TARGETED  derived=[PLANNED RED_VERIFIED IMPLEMENTED GREEN_TARGETED]
	REFUSED SCS-TEST-SUBSTITUTED [SCN-B042-REPRO]: green receipt cites test 'resolver-test-B', red cited 'resolver-test-A' — replacing the test requires a planning revision and a new red
	certifiable: no
BUG042_HISTORICAL_ROW_CASE_EXIT=1
BUG042_CLEAN_CONTROL_CASE_BEGIN
scenario-state-resolve: /private/tmp/bubbles-bug042-hermetic-counterexample
	source revision: rev-b042
	SCN-B042-REPRO  state=GREEN_TARGETED  derived=[PLANNED RED_VERIFIED IMPLEMENTED GREEN_TARGETED]
	certifiable: yes
BUG042_CLEAN_CONTROL_CASE_EXIT=0
BUG042_DISCRIMINATOR historical=1 clean=0 expected=1,0
```

The logs differ by one historical substituted-test GREEN. Both outputs derive
the same terminal state. The extra row alone changes certification and exit
status. This directly confirms historical veto retention.

<a name="e-b042-planned"></a>

#### E-B042-PLANNED - Persistent scenario evidence status

**Phase:** bug
**Claim Source:** not-run
**Reason:** This is the preserved pre-implementation planning record. Current
implementation evidence is recorded below.

- `SCN-B042-001` has a temporary reproduction but no persistent test.
- `SCN-B042-002` has a declared mechanism and no execution.
- `SCN-B042-003` has a declared mechanism and no execution.
- `SCN-B042-004` has a declared mechanism and no execution.
- `SCN-B042-005` has a declared mechanism and no execution.
- Concrete persistent test target: `bubbles/scripts/scenario-state-resolve-selftest.sh`.
- Every implementation reference names the production resolver.
- This list describes the state before the implementation phase.
- Current evidence supersedes this planning-only snapshot without rewriting it.
- Human acceptance remains entirely unchecked.

These declarations support traceability only. They do not satisfy any test or
acceptance claim.

## Implementation Evidence

<a name="e-b042-implement-red"></a>

#### E-B042-IMPLEMENT-RED - Persistent pre-fix matrix

**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 1080 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 2

```text
# BUG-042 Scope 1 persistent B042-T01-T18 RED and current protection
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 1080 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh
exit: 1
lines: 58
sha256: b5c8efe52ddeae59cc8447769a411ebf3d75ec48ea0911f54c44a394e8b9e395
PASS: lifecycle: repeated resolution over an unchanged log is byte-identical (stable, auditable)
PASS: source-revision drift is reported but does not block
PASS: drift-only evidence still fails certification via unsatisfied
FAIL: B042-T01 substituted-test replacement (corrected exit 1, negative exit 1)
FAIL: B042-T05 later substituted-test remains unresolved (exit 0)
FAIL: B042-T15 duplicate model ordinal refuses order (mutation exit 3, resolver exit 2)
PASS: B042-T17 bypass arguments remain rejected
scenario-state-resolve-selftest: 39 passed, 17 failed
```

This run occurred after all 18 persistent cases were added and before the first
production source edit. The intended replacement, identity, partial-chain, and
order-conflict paths were red while the pre-existing lifecycle, revision-drift,
and bypass protections continued to execute.

<a name="e-b042-implement-green"></a>

#### E-B042-IMPLEMENT-GREEN - Final focused matrix and consumers

**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1680 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 8

```text
# BUG-042 Scope 1 final focused B042-T01-T18 and production consumers isolated current bytes
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1680 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh
exit: 0
lines: 64
sha256: 82ece1117dfe23e6bc6cd79bd6fc241e0d8d560e5c375c3c40f678b9f5b9180b
PASS: B042-T01 substituted-test replacement
PASS: B042-T02 substituted-control replacement
PASS: B042-T03 exit-zero RED replacement
PASS: B042-T04 equal timestamps use append ordinal
PASS: B042-T05 later substituted-test remains unresolved
PASS: B042-T10 still-later coherent chain closes conflict
PASS: B042-T11 duplicate rows retain distinct ordinals
PASS: B042-T13 BUG-034 revision isolation
PASS: B042-T15 duplicate model ordinal refuses order
PASS: B042-T16 legacy receipts derive local identities
PASS: B042-T17 bypass arguments remain rejected
PASS: B042-T18 rollback preserves current ledger identities
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 61 passed, 0 failed
```

<a name="e-b042-implement-validation"></a>

#### E-B042-IMPLEMENT-VALIDATION - Syntax, gates, boundary, and registry

**Phase:** implement
**Command:** Exact validation batch and every embedded argv are recorded in `.specify/runtime/tool-calls.jsonl` row 10.
**Exit Code:** 0
**Claim Source:** executed

```text
exit: 0
lines: 158
sha256: 0420431fc5de734c133b2cc06607eb533bc1ff4f36656f2dd0f2a2f39ac968e3
BEGIN_BASH_SYNTAX
END_BASH_SYNTAX_EXIT=0
BEGIN_SHELLCHECK_WARNINGS
END_SHELLCHECK_WARNINGS_EXIT=0
END_ARTIFACT_EXIT=0
END_TRACEABILITY_EXIT=0
END_REGRESSION_QUALITY_EXIT=0
disposition=in-boundary
disposition=in-boundary
disposition=in-boundary
registry-consistency-selftest: PASS
Agent ownership lint passed.
SCS-CHAIN-PARTIAL count=1
SCS-APPEND-ORDER-CONFLICT count=1
INCOMPLETE_MARKER_SCAN_EXIT=1 expected=1
BUG042_IMPLEMENT_VALIDATION_PASS
```

<a name="e-b042-implement-reality"></a>

#### E-B042-IMPLEMENT-REALITY - Reality and coherence checks

**Phase:** implement
**Command:** Exact reality/coherence batch and every embedded argv are recorded in `.specify/runtime/tool-calls.jsonl` row 11.
**Exit Code:** 0
**Claim Source:** executed

```text
exit: 0
lines: 48
sha256: 4f1b74a284db3206e2b4c05c77769563de9e16c0c1b66779b0f7d2be22958776
BEGIN_IMPLEMENTATION_REALITY
INFO: Resolved 5 implementation file(s) to scan
IMPLEMENTATION REALITY SCAN RESULT
Files scanned:  5
Violations:     0
Warnings:       1
PASSED with 1 warning(s) - manual review advised
END_IMPLEMENTATION_REALITY_EXIT=0
BEGIN_DIFF_CHECK
END_DIFF_CHECK_EXIT=0
COMPLETION_LANGUAGE_SCAN_EXIT=1 expected=1
END_COMPLETION_LANGUAGE_EXIT=0
OBSERVABILITY_WORKFLOW_SCAN_EXIT=1 expected=1
END_OBSERVABILITY_APPLICABILITY_EXIT=0
BUG042_REALITY_COHERENCE_PASS
```

The advisory warning says scope-path discovery found zero files and used the
design fallback. The scan still resolved five files, found zero violations, and
exited 0. Planning content was not changed by the implementation owner.

## Root Cause Evidence

Before this implementation, the code path sorted receipts by `ts`, emitted
substitution refusals while scanning oldest-first, and later accepted a matching
GREEN. The replacement pipeline derives physical row identity, selects the
latest complete chain first, and then decides whether an eligible diagnostic is
`SUPERSEDED` or remains `UNRESOLVED` and blocking.

## Findings

### F-B042-01 - Historical same-revision refusals retain veto power

- Severity: high.
- Status: addressed by the implementation candidate.
- Owner: `bubbles.implement`.
- Evidence status: current-session production-resolver execution at `E-B042-REPRO`.
- Scope: resolver chain selection and refusal classification.
- Verification: `E-B042-IMPLEMENT-GREEN`, tool-log row 8.

### F-B042-02 - Timestamp ordering cannot resolve ties authoritatively

- Severity: high.
- Status: addressed by the implementation candidate.
- Owner: `bubbles.implement`.
- Evidence status: `B042-T04`, `B042-T11`, and `B042-T15` pass in
	`E-B042-IMPLEMENT-GREEN`.
- Scope: deterministic identity and ordering contract.

## Artifact Bootstrap

The packet contains `bug.md`, `spec.md`, `design.md`, `scopes.md`, `report.md`,
`uservalidation.md`, `state.json`, `scenario-manifest.json`, and
`test-plan.json`. All implementation and human acceptance obligations remain
unchecked.

## Invocation Audit

No subagents or workflow runners were invoked. No commit, push, fetch, merge,
cleanup, deployment, action node, acceptance edit, or certification edit was
performed. The inherited repository packet remained bound to scenario node
`bubbles-file-scenario-receipt-supersession-bug` at control revision 1.

<a name="e-b042-test-independent"></a>

## Independent Test Phase - 2026-09-02

### Repository And Input Identity

**Phase:** test
**Command:** `/usr/bin/shasum -a 256 bubbles/scripts/scenario-state-resolve.sh bubbles/scripts/scenario-state-resolve-selftest.sh bubbles/registry/scenario-states.yaml bugs/BUG-042-same-revision-receipt-supersession/spec.md bugs/BUG-042-same-revision-receipt-supersession/design.md bugs/BUG-042-same-revision-receipt-supersession/scopes.md bugs/BUG-042-same-revision-receipt-supersession/test-plan.json bugs/BUG-042-same-revision-receipt-supersession/scenario-manifest.json bubbles/scripts/phase-coordinator.sh bubbles/scripts/state-transition-guard.sh bubbles/schemas/tool-call.schema.json bubbles/release-manifest.json`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 16

```text
d0a530d8211ff34028424170d0fb43677a59ec67da8c888360f61a68b297ab88  bubbles/scripts/scenario-state-resolve.sh
23d62e80b4717d93d2c23ea1a90467847d50b086ce4d95a23de918320027ae3d  bubbles/scripts/scenario-state-resolve-selftest.sh
4afe5618424dfe6a327a366c388e2cb9bcc72ea951390ca49dafd80b67a76df5  bubbles/registry/scenario-states.yaml
3dcb36cb19c88ab28dc655e8f16968856432f3bc4d7a9b3b2978dbded1b818fb  bugs/BUG-042-same-revision-receipt-supersession/spec.md
f25a5f450e2bf36997726064c4b11df67f928007282f143a3b3148ff787665c4  bugs/BUG-042-same-revision-receipt-supersession/design.md
8a907f41d0ea2b401fbedfa9028a9e2d39f0118017a8c8f3ad07f27a9e35131e  bugs/BUG-042-same-revision-receipt-supersession/scopes.md
cc9df06e1f1eba4fd3284d0fcde7e0b7ad4db7c23614cc1011ee10747ec7462b  bugs/BUG-042-same-revision-receipt-supersession/test-plan.json
1628da74c036976a937d302265efa86134d8a8386b65a08299e574b108cada37  bugs/BUG-042-same-revision-receipt-supersession/scenario-manifest.json
af3466cd0e169154be87e167993238c32c17608f978f81f52f347fcca7ff77a3  bubbles/scripts/phase-coordinator.sh
1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0  bubbles/scripts/state-transition-guard.sh
3e561bf62016cb8b0d5e66e64203d8f11603bfcee7a3fcf984c3291d25d7eab3  bubbles/schemas/tool-call.schema.json
bfc9642ffacfdf4d28c46f9e79a180c1269f814d4443290d24f0b14ff074e2c3  bubbles/release-manifest.json
```

The three implementation-owned source hashes equal the input closure on
implementation row 8. The test phase did not use that row as behavioral proof.
It reran the current bytes independently at row 17.

### E-B042-TEST-PLAN-PARITY - Eighteen Planned Cases

**Phase:** test
**Command:** bounded one-to-one comparison of `test-plan.json` matrix IDs,
labels, commands, and persistent targets against `design.md` and
`scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG042_MATRIX_PARITY_HEADER plan=18 uniqueMatrix=18 uniqueLabels=18 exactCommands=18
B042-T01 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T01 substituted-test replacement
B042-T02 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T02 substituted-control replacement
B042-T03 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T03 exit-zero RED replacement
B042-T04 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T04 equal timestamps use append ordinal
B042-T05 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T05 later substituted-test remains unresolved
B042-T06 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T06 later substituted-control remains unresolved
B042-T07 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T07 later exit-zero RED remains unresolved
B042-T08 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T08 later RED-only campaign is partial
B042-T09 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T09 later RED-IMPLEMENT campaign is partial
B042-T10 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T10 still-later coherent chain closes conflict
B042-T11 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T11 duplicate rows retain distinct ordinals
B042-T12 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T12 cross-scenario isolation
B042-T13 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T13 BUG-034 revision isolation
B042-T14 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T14 proof identity cannot borrow phases
B042-T15 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T15 duplicate model ordinal refuses order
B042-T16 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T16 legacy receipts derive local identities
B042-T17 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T17 bypass arguments remain rejected
B042-T18 designRows=1 persistentPassTitles=1 targetExact=1 label=B042-T18 rollback preserves current ledger identities
BUG042_MATRIX_PARITY_RESULT rows=18 failures=0
```

The mandatory linked-test resolver also passed at tool-log row 15 with five
references resolved from the current scenario manifest.

### E-B042-TEST-FOCUSED - Independent Matrix And Consumer Canaries

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1680 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 17
**Tool-Log Output Hash:** `560ea7ee545fb87b928fa678d7ad430c0fa83a69ab40fe4f8d8c308d066e8439`
**Complete Test Output Hash:** `ec3c30135091d2b3c0a45215734e7877941ca3c25dbcad4afcee6cf340285dfa`

```text
# BUG-042 independent focused B042-T01-T18 and production consumer canaries dedicated retry 2
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1680 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh
exit: 0
lines: 64
sha256: ec3c30135091d2b3c0a45215734e7877941ca3c25dbcad4afcee6cf340285dfa
PASS: lifecycle: a manifest with no receipts derives PLANNED and nothing further
PASS: lifecycle: traits make GREEN_LIVE and OBSERVED applicable for this fixture
PASS: lifecycle: implementation cannot start without an expected behavioral RED
PASS: lifecycle: a failing red receipt derives RED_VERIFIED
PASS: lifecycle: an implement receipt after red derives IMPLEMENTED
PASS: lifecycle: a same-scenario same-control green derives GREEN_TARGETED
PASS: lifecycle: one fixture reached EVERY applicable state, each computed from a receipt
PASS: lifecycle: the resolver never emits CERTIFIED - certification stays validate-owned
PASS: lifecycle: repeated resolution over an unchanged log is byte-identical (stable, auditable)
PASS: declared state: a hand-written `state` is refused with SCS-DECLARED-STATE
PASS: declared state: a hand-written `scenarioState` is refused with SCS-DECLARED-STATE
PASS: declared state: a hand-written `derivedState` is refused with SCS-DECLARED-STATE
PASS: declared state: a hand-written `currentState` is refused with SCS-DECLARED-STATE
PASS: declared state: a hand-written `certified` is refused with SCS-DECLARED-STATE
PASS: declared state: `lockdown.state` is not mistaken for a scenario state
PASS: cross-scenario green refused with SCS-CROSS-SCENARIO
PASS: green from a DIFFERENT test refused with SCS-TEST-SUBSTITUTED
PASS: green from a DIFFERENT negative control refused with SCS-CONTROL-SUBSTITUTED
PASS: source-revision drift is reported but does not block
PASS: drift-only evidence still fails certification via unsatisfied
PASS: a blocking refusal alongside drift refused with SCS-NO-NEGATIVE-CONTROL
PASS: receipt with no negative control refused with SCS-NO-NEGATIVE-CONTROL
PASS: green with no prior red refused with SCS-GREEN-WITHOUT-RED
PASS: a red-phase receipt that exited 0 refused with SCS-RED-NOT-FAILING
PASS: a changed implementation ref marks the scenario AFFECTED
PASS: an affected scenario's GREEN is demoted rather than silently retained
PASS: an unrelated changed file does not mark the scenario affected
PASS: a passing gate receipt does not advance any scenario state
PASS: certifiability is refused while a required scenario state does not hold
PASS: certifiability holds when every required scenario state is receipt-derived
PASS: migration: a spec with no manifest resolves cleanly and keeps the legacy basis
PASS: migration: checked boxes never infer a later state
PASS: rollback: advancement stops, and all 6 receipts are preserved and still counted
PASS: no bypass: `--skip-red` is rejected by name
PASS: no bypass: `--force` is rejected by name
PASS: no bypass: `--ignore-drift` is rejected by name
PASS: no bypass: `--assume-green` is rejected by name
PASS: no bypass: `--allow-declared` is rejected by name
PASS: B042-T01 substituted-test replacement
PASS: B042-T02 substituted-control replacement
PASS: B042-T03 exit-zero RED replacement
PASS: B042-T04 equal timestamps use append ordinal
PASS: B042-T05 later substituted-test remains unresolved
PASS: B042-T06 later substituted-control remains unresolved
PASS: B042-T07 later exit-zero RED remains unresolved
PASS: B042-T08 later RED-only campaign is partial
PASS: B042-T09 later RED-IMPLEMENT campaign is partial
PASS: B042-T10 still-later coherent chain closes conflict
PASS: B042-T11 duplicate rows retain distinct ordinals
PASS: B042-T12 cross-scenario isolation
PASS: B042-T13 BUG-034 revision isolation
PROTECTION: B042-T13 drift-output-sha256=485bdbfb9b6a76cf60673b2a219c1224cf0689a2ff6fb530b2016bc21278708a required-output-sha256=7c2710c1be6af1e443aa672fbf1140d6aa8d359559fdf967e458dd39abcb96fa
PASS: B042-T14 proof identity cannot borrow phases
PASS: B042-T15 duplicate model ordinal refuses order
PASS: B042-T16 legacy receipts derive local identities
PASS: B042-T17 bypass arguments remain rejected
PASS: B042-T18 rollback preserves current ledger identities
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 61 passed, 0 failed
```

The first shared-terminal attempt received an external `SIGINT` and produced
exit 130 over 292 lines with output SHA-256
`637587546d1bb9425d113535f14c51bd52d5414271fac33a2e201d3216f6d4a9`.
Its temporary fixture had already been removed, so its cascading file errors
were not used as an implementation verdict. A detached retry produced no
receipt and was also excluded. Row 17 is the dedicated-terminal execution that
controls this test-phase result.

### Per-Item Current Evidence

| Test Plan ID | Current independent signal |
| --- | --- |
| `TP-B042-T01` | Row 17 prints `PASS: B042-T01 substituted-test replacement` and both consumer success lines. |
| `TP-B042-T02` | Row 17 prints `PASS: B042-T02 substituted-control replacement`. |
| `TP-B042-T03` | Row 17 prints `PASS: B042-T03 exit-zero RED replacement`. |
| `TP-B042-T04` | Row 17 prints `PASS: B042-T04 equal timestamps use append ordinal`. |
| `TP-B042-T05` | Row 17 prints `PASS: B042-T05 later substituted-test remains unresolved` and both unresolved-consumer lines. |
| `TP-B042-T06` | Row 17 prints `PASS: B042-T06 later substituted-control remains unresolved`. |
| `TP-B042-T07` | Row 17 prints `PASS: B042-T07 later exit-zero RED remains unresolved`. |
| `TP-B042-T08` | Row 17 prints `PASS: B042-T08 later RED-only campaign is partial`. |
| `TP-B042-T09` | Row 17 prints `PASS: B042-T09 later RED-IMPLEMENT campaign is partial`. |
| `TP-B042-T10` | Row 17 prints `PASS: B042-T10 still-later coherent chain closes conflict`. |
| `TP-B042-T11` | Row 17 prints `PASS: B042-T11 duplicate rows retain distinct ordinals`. |
| `TP-B042-T12` | Row 17 prints `PASS: B042-T12 cross-scenario isolation`. |
| `TP-B042-T13` | Row 17 prints the PASS plus both exact BUG-034 output hashes. |
| `TP-B042-T14` | Row 17 prints `PASS: B042-T14 proof identity cannot borrow phases`. |
| `TP-B042-T15` | Row 17 prints `PASS: B042-T15 duplicate model ordinal refuses order`. |
| `TP-B042-T16` | Row 17 prints `PASS: B042-T16 legacy receipts derive local identities`. |
| `TP-B042-T17` | Row 17 prints `PASS: B042-T17 bypass arguments remain rejected` after the five individual usage refusals. |
| `TP-B042-T18` | Row 17 prints `PASS: B042-T18 rollback preserves current ledger identities`. |

### E-B042-TEST-GUARDS - Independent Pre-Edit Matrix

**Phase:** test
**Command:** exact syntax, shellcheck, artifact, traceability, scenario,
test-integrity, registry, ownership, boundary, excluded-surface, diff, marker,
and worktree-pointer argv are recorded in `.specify/runtime/tool-calls.jsonl`
row 19
**Exit Code:** 0
**Claim Source:** executed
**Tool-Log Output Hash:** `2c97aa5301e1cb26d20dd799d0afb5e5829da0de6f6a7fd8b1bc581a2d4b44ac`
**Complete Validation Output Hash:** `9d517d970d581d41f6e544bf2df80c19afe3a0405978789e73d9854c4c5d3c37`

```text
BEGIN_BASH_SYNTAX
END_BASH_SYNTAX_EXIT=0
BEGIN_SHELLCHECK_WARNINGS
END_SHELLCHECK_WARNINGS_EXIT=0
BEGIN_ARTIFACT
Artifact lint PASSED.
END_ARTIFACT_EXIT=0
BEGIN_TRACEABILITY
TRACEABILITY CHECK PASSED
END_TRACEABILITY_EXIT=0
BEGIN_SCENARIO_LINKED_TEST
[scenario-test-resolve] OK - 5 reference(s) resolved via literal-scan
END_SCENARIO_LINKED_TEST_EXIT=0
BEGIN_SCENARIO_OBLIGATION
END_SCENARIO_OBLIGATION_EXIT=0
BEGIN_TEST_MECHANISM
END_TEST_MECHANISM_EXIT=0
BEGIN_EXECUTION_SUBSTATE
[execution-substate-guard] OK - execution substate (if any) is valid and distinct from certification in bugs/BUG-042-same-revision-receipt-supersession.
END_EXECUTION_SUBSTATE_EXIT=0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
SKIP_MARKER_SCAN_EXIT=1 expected=1
LIVE_MOCK_SCAN_EXIT=1 expected=1
registry-consistency-selftest: PASS
Agent ownership lint passed.
SCS-CHAIN-PARTIAL count=1
SCS-APPEND-ORDER-CONFLICT count=1
EXCLUDED_WORKTREE_DIFF_EXIT=0
EXCLUDED_CACHED_DIFF_EXIT=0
INCOMPLETE_MARKER_SCAN_EXIT=1 expected=1
MAIN_HEAD=a8e870039573a4a9c84da5a039446d1139a1b968 MAIN_BRANCH=main
TARGET_HEAD=a8e870039573a4a9c84da5a039446d1139a1b968 TARGET_BRANCH=fix/scenario-receipt-supersession
WORKTREE_LIST_EXIT=0
BUG042_PRE_EDIT_VALIDATION_PASS
```

The preceding row 18 validation attempt exited 1 because its loose `xit(` scan
matched Python `SystemExit(3)`. The corrected boundary-aware expression on row
19 reran the complete matrix and passed. No test or production file changed to
resolve that command defect.

### Test Integrity Audits

- **Mock audit:** Row 19 scanned the focused selftest for request interception
  and mock patterns. The no-match exit was 1 as expected.
- **Regression quality:** Row 19 found zero violations, zero warnings, and one
  adversarial-signal file.
- **Self-validating test audit:** **Claim Source:** interpreted.
  **Interpretation:** T01 through T03 execute paired fixtures without the
  correcting row, T05 through T09 require current conflicts to remain blocking,
  and T15 mutates the production resolver copy to force the order-refusal
  branch. Replacing the resolver with an identity function cannot satisfy the
  selected-chain, disposition, exit-code, digest, rollback, or consumer
  assertions. No self-validating required case was identified.
- **Skip audit:** Row 19 used a token-boundary scan so Python `SystemExit` is not
  confused with the JavaScript `xit` marker. It found no skip, only, todo,
  pending, or disabled-test marker.

### Test Phase Verdict And Routing

| Test Type | Planned Cases | Passed | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| integration | 2 | 2 | 0 | 0 |
| functional | 16 | 16 | 0 | 0 |
| focused suite assertions | 61 | 61 | 0 | 0 |

The structured test plan names the focused resolver selftest as the exact
command for all 18 rows. It declares API, UI, stress, and load categories not
applicable. It declares no `observabilityWorkflow`, and the project config
declares neither `testImpact` nor `traceContracts`.

`framework-validate` and `release-check` were not executed by this test phase.
The registered `bugfix-fastlane` order places `regression` immediately after
`test`; repository-wide execution therefore belongs to the routed regression
phase and remains unclaimed here.

The independent test phase addressed both inherited findings:

- `F-B042-01`: row 17 independently verifies corrected same-revision selection
  and both production-consumer boundaries.
- `F-B042-02`: row 17 independently verifies append-order ties, duplicate rows,
  and fail-closed model-order conflict.

No unresolved finding was discovered. Scope and certification status remain
`in_progress`; this phase does not check planning-owned DoD items or write
validate-owned certification.

## E-B042 Regression Findings

### Focused Baseline Comparison

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1680 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 23

```text
exit: 0
lines: 64
sha256: e203a047242c4c6024f71ddf283eb73fd3a03ad4802bdac6a6f0af9e8465a493
PASS: lifecycle: a manifest with no receipts derives PLANNED and nothing further
PASS: lifecycle: traits make GREEN_LIVE and OBSERVED applicable for this fixture
PASS: lifecycle: implementation cannot start without an expected behavioral RED
PASS: lifecycle: a failing red receipt derives RED_VERIFIED
PASS: lifecycle: an implement receipt after red derives IMPLEMENTED
PASS: lifecycle: a same-scenario same-control green derives GREEN_TARGETED
PASS: B042-T18 rollback preserves current ledger identities
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 61 passed, 0 failed
```

| Signal | Before | Current | Delta |
| --- | ---: | ---: | ---: |
| Focused assertions | 61 passed, 0 failed | 61 passed, 0 failed | 0 |
| Stable scenario contracts | 5 | 5 | 0 |
| Integration matrix rows | 2 passed | 2 passed | 0 |
| Functional matrix rows | 16 passed | 16 passed | 0 |

The before value comes from the independently executed test-phase baseline at
tool-log row 17. The current value comes from the fresh regression execution at
row 23. The source command registry defines no line-coverage command.

### Coverage And Traceability

**Phase:** regression
**Command:** bounded `selftest-coverage-lint.sh`, regression-quality,
traceability, linked-test, obligation, mechanism, and baseline guard batch
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` rows 26 and 30

```text
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
TRACEABILITY CHECK PASSED
[scenario-test-resolve] OK — 5 reference(s) resolved via literal-scan
[scenario-obligation-lint] OK — 5 scenario(s) with a coherent derived obligation matrix
[test-mechanism-lint] OK — 5 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
Regression baseline guard: PASSED
[selftest-coverage-lint] OK — 272 selftest(s): 249 enumerated, 21 discovered, 2 denied
FOCUSED_ASSERTION_DELTA=0
SCENARIO_DELTA=0
TEST_FILE_DIFF_ADDITIONS=527
TEST_FILE_DIFF_DELETIONS=3
DELETED_ASSERTION_LINES=0
LINE_COVERAGE_COMMAND=N/A-source-registry-declares-no-coverage-command
```

The changed-path scan at tool-log row 25 found only the resolver, its focused
selftest, and the scenario-state registry. It found the two production callers
already exercised by the focused suite. No deployment surface changed.

### Text And State Consistency Discriminator

**Phase:** regression
**Command:** production `scenario-state-resolve.sh` text-mode execution over a
four-receipt same-revision replacement fixture
**Exit Code:** 1
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 28

```text
BUG042_TEXT_SUMMARY_PROBE_BEGIN
RESOLVER_EXIT=0
RESOLVER_TEXT_BEGIN
scenario-state-resolve: /private/tmp/bug042-regression-text-probe
  source revision: 000000000000
  SCN-B042-TEXT  state=GREEN_TARGETED  derived=[PLANNED RED_VERIFIED IMPLEMENTED GREEN_TARGETED]
      BLOCKED_NOT_RUN: IMPLEMENTED
  SUPERSEDED SCS-TEST-SUBSTITUTED [SCN-B042-TEXT] receipt=3 supersededBy=sha256:aa0f6e226590d5f0516e45c21c83dcca526fc5d8a93440d1462b28a30e3c848e: green receipt cites test 'tests/resolver::identity-B', red cited 'tests/resolver::identity-A' — replacing the test requires a planning revision and a new red
  (all 1 refusals are SCS-REVISION-DRIFT: superseded receipts, excluded from derivation, not blocking)
  certifiable: yes
RESOLVER_TEXT_END
SUPERSEDED_TEST_DIAGNOSTIC_PRESENT=true
FALSE_DRIFT_ONLY_SUMMARY_PRESENT=true
EXPECTED_FALSE_DRIFT_ONLY_SUMMARY_PRESENT=false
BUG042_TEXT_SUMMARY_PROBE_END
```

The production resolver exited 0 and selected the intended chain. Its emitted
state is internally contradictory because `IMPLEMENTED` appears in both
`derived` and `BLOCKED_NOT_RUN`. Its summary also identifies a visible
`SCS-TEST-SUBSTITUTED` diagnostic as if every refusal were
`SCS-REVISION-DRIFT`.

<a name="e-b042-regression-bug034-mutation"></a>

### BUG-034 Frozen-Byte Mutation Discriminator

**Phase:** regression
**Command:** exact disposable mutation argv is recorded in
`.specify/runtime/tool-calls.jsonl` row 39. The command copied the current
resolver and selftest, changed only `receipt cites source revision %s but the
resolved revision is %s` to `MUTATED receipt cites source revision %s but the
resolved revision is %s`, and executed the copied persistent suite.
**Exit Code:** 1
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 39
**Tool-Log Output Hash:**
`003c1736b8974275d092975b212e95b0c920028508431180a869dd6a56f2966f`

```text
# BUG-042 regression BUG-034 byte-compatibility mutation discriminator corrected interpreter
exit: 1
lines: 68
sha256: 3dacd9227994809e47ab269296c38cbd21f6965e2cb5aa964e68193d7dde69f3
--- first 12 ---
MUTATION_SETUP_EXIT=0
PASS: lifecycle: a manifest with no receipts derives PLANNED and nothing further
PASS: lifecycle: traits make GREEN_LIVE and OBSERVED applicable for this fixture
PASS: lifecycle: implementation cannot start without an expected behavioral RED
PASS: lifecycle: a failing red receipt derives RED_VERIFIED
PASS: lifecycle: an implement receipt after red derives IMPLEMENTED
PASS: lifecycle: a same-scenario same-control green derives GREEN_TARGETED
--- omitted 44 line(s); sha256 above covers the full output ---
--- last 12 ---
PASS: B042-T17 bypass arguments remain rejected
PASS: B042-T18 rollback preserves current ledger identities
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 61 passed, 0 failed
MUTATED_SUITE_EXIT=0
T13_STILL_PASSES_AFTER_BYTE_CHANGE=true
EXPECTED_T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
```

The current B042-T13 block performs nine structural and exit checks. It prints
hashes computed from the current output but compares neither hash with frozen
BUG-034 bytes. The mutation therefore changed the promised compatibility bytes
while B042-T13 and the complete persistent suite still passed.

### Regression Findings

#### F-B042-RG-01 - Selected implementation is also reported as blocked

- Severity: high.
- Status: unresolved.
- Owner: `bubbles.implement`.
- Evidence: `E-B042-REGRESSION-FINDINGS`, tool-log row 28.
- Required correction: keep `IMPLEMENTED` out of `blockedNotRun` when a complete
  selected chain already derives it.

#### F-B042-RG-02 - Superseded same-revision history is labeled drift-only

- Severity: high.
- Status: unresolved.
- Owner: `bubbles.implement`.
- Evidence: `E-B042-REGRESSION-FINDINGS`, tool-log row 28.
- Required correction: preserve the exact BUG-034 drift-only bytes while
  avoiding the drift-only summary for non-drift superseded diagnostics.

#### F-B042-RG-03 - Persistent coverage omits both emitted-output invariants

- Severity: high.
- Status: unresolved.
- Owner: `bubbles.test`.
- Evidence: the focused suite passed 61 assertions at row 23 while the direct
  production probe failed at row 28.
- Required correction: add adversarial persistent assertions that a selected
  chain never lists a derived state in `blockedNotRun`, and that text output
  never labels same-revision superseded diagnostics as drift-only.

#### F-B042-RG-04 - BUG-034 frozen-byte compatibility check is non-discriminating

- Severity: high.
- Status: unresolved.
- Classification: in-boundary BUG-042 test defect under `bugfix-fastlane`.
- Owner: `bubbles.implement`.
- Evidence: `E-B042-REGRESSION-BUG034-MUTATION`, tool-log row 39.
- Current-source cause: B042-T13 compares repeated current output and selected
  structural fields, then only prints the two current output hashes.
- Required correction: make B042-T13 compare all three BUG-034 outputs and exit
  codes with frozen baseline values so the recorded one-string byte mutation
  makes B042-T13 and the persistent suite fail.

The inherited findings remain independently verified:

- `F-B042-01` is addressed and independently verified by rows 17 and 23.
- `F-B042-02` is addressed and independently verified by rows 17 and 23.

Regression cannot record a completed phase claim while
`F-B042-RG-01` through `F-B042-RG-04` remain unresolved. The current
bugfix-fastlane registry sets `restartLoopAtPhase: implement`, so the next owner
is `bubbles.implement`. Certification and planning state remain unchanged.

<a name="e-b042-implement-remediation"></a>

## Implement Remediation - 2026-09-02

### Persistent RED

**Phase:** implement
**Command:** bounded `scenario-state-resolve-selftest.sh` through
`tool-log.sh` and `evidence-capture.sh`
**Exit Code:** 1
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 41
**Complete Output Hash:**
`eb0290f577d22730f6f4da846741ea3af026f8376ff8b73109fc76fc686cccda`

```text
# BUG-042 remediation focused RED for emitted-output invariants
exit: 1
lines: 73
sha256: eb0290f577d22730f6f4da846741ea3af026f8376ff8b73109fc76fc686cccda
PASS: B042-T01 substituted-test replacement
FAIL: B042-T01 selected IMPLEMENTED is not also blocked-not-run
FAIL: B042-T01 superseded same-revision text is not labeled drift-only (exit 0)
PASS: B042-T13 BUG-034 revision isolation
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 61 passed, 2 failed
```

The two added persistent assertions failed against the pre-remediation
resolver while every prior assertion passed. Row 42 separately froze all three
path-normalized BUG-034 outputs before the production edit.

### Focused GREEN

**Phase:** implement
**Command:** the identical bounded focused selftest after the resolver and T13
changes
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 43
**Complete Output Hash:**
`e4c00e19b459eed20b80cdccd1c96974bb72b3cbc583d1538a804ca93b202a5c`

```text
# BUG-042 remediation focused GREEN and frozen-byte checks
exit: 0
lines: 66
sha256: e4c00e19b459eed20b80cdccd1c96974bb72b3cbc583d1538a804ca93b202a5c
PASS: B042-T01 substituted-test replacement
PASS: B042-T01 selected IMPLEMENTED is not also blocked-not-run
PASS: B042-T01 superseded same-revision text is not labeled drift-only
PASS: B042-T13 BUG-034 revision isolation
PROTECTION: B042-T13 drift-output-sha256=7a505dd15e59cb94eece826408a55e2eabdea33aed8b143a23dea24da33254c3 required-output-sha256=4d90f6a135ffe8abd8b9e6724e77a057e5acd095ca716d85b37fe877336d11fb mixed-output-sha256=59e94858ceb7b79e2b1ee6f0c41f7c1a81a243ee91a0d4b9775355e365f8bd00
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 63 passed, 0 failed
```

### Frozen-Byte Mutation Discriminator

**Phase:** implement
**Command:** bounded disposable copy of the resolver and focused selftest with
only the BUG-034 revision-drift detail string mutated
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 46
**Complete Output Hash:**
`2db97fd7e9779e74bcb63724f51ce244594ae8189c0a0f0c982cc4686f3b5fb3`

```text
# BUG-042 remediation T13 isolated one-string mutation discriminator
exit: 0
lines: 74
sha256: 2db97fd7e9779e74bcb63724f51ce244594ae8189c0a0f0c982cc4686f3b5fb3
MUTATION_SETUP_EXIT=0
FAIL: B042-T13 BUG-034 revision isolation (12/15 checks; exits 0/1/1)
scenario-state-resolve-selftest: 62 passed, 1 failed
MUTATED_SUITE_EXIT=1
T13_FROZEN_BYTE_DISCRIMINATOR_FAILED=true
T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
T13_IS_SOLE_FAILURE=true
EXPECTED_MUTATED_SUITE_NONZERO=true
EXPECTED_T13_FROZEN_BYTE_DISCRIMINATOR_FAILED=true
EXPECTED_T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
EXPECTED_T13_IS_SOLE_FAILURE=true
```

The first mutation setup at row 44 was invalid because its path rewrite was
over-escaped. Row 45 proved T13 failed but also exposed fixture-only consumer
path failures. Neither is used as the controlling mutation result. Row 46 uses
absolute production-consumer paths and leaves T13 as the sole failure.

### Finding Accounting And Routing

- `F-B042-RG-01` is addressed in production: a selected chain no longer adds
  `IMPLEMENTED` to `blockedNotRun`; row 43 executes the persistent assertion.
- `F-B042-RG-02` is addressed in production: the legacy drift-only summary is
  emitted only when every nonblocking refusal is `SCS-REVISION-DRIFT`; row 43
  proves same-revision superseded text does not receive that label.
- `F-B042-RG-03` is addressed in the persistent focused suite by the two T01
  emitted-output assertions that produced row 41 RED and row 43 GREEN.
- `F-B042-RG-04` is addressed by comparing all three normalized BUG-034 output
  hashes and all three exit codes with frozen values; row 46 proves a one-string
  output mutation makes T13 the sole failing assertion.

Row 48 records `bash -n` exit 0 and warning-threshold ShellCheck exit 0 for both
changed scripts. The default ShellCheck attempt at row 47 returned only
pre-existing info/style findings and is retained as non-controlling evidence.

Implementation is routed to `bubbles.test` for independent verification under
the persisted `bugfix-fastlane` phase order. Scope status and validate-owned
certification remain `in_progress`. No framework-wide validation or release
check is claimed by this implement slice.

<a name="e-b042-test-remediation-independent"></a>

## Independent Remediation Test - 2026-09-02

### Current-Byte Closure

**Phase:** test
**Command:** bounded current-byte status and SHA-256 capture
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 55
**Complete Output Hash:**
`9ab211349681483710bc0715e75d6525f4b36fde65f20eb8221871a43d331906`

```text
BUG042_TARGET_BASELINE_BEGIN
a8e870039573a4a9c84da5a039446d1139a1b968
fix/scenario-receipt-supersession
## fix/scenario-receipt-supersession
 M bubbles/registry/scenario-states.yaml
 M bubbles/scripts/scenario-state-resolve-selftest.sh
 M bubbles/scripts/scenario-state-resolve.sh
?? .specify/memory/bubbles.session.json.flock
?? bugs/BUG-042-same-revision-receipt-supersession/
DIFF_NAMES
M       bubbles/registry/scenario-states.yaml
M       bubbles/scripts/scenario-state-resolve-selftest.sh
M       bubbles/scripts/scenario-state-resolve.sh
CACHED_DIFF_NAMES
42ed92f6927ce5f4af327caa338652ee33e2c6d3f04f29da28e34435410173fe  bubbles/scripts/scenario-state-resolve.sh
91c36d663a15413a17cb7ee8acc92a7317ed4200da936b0390337091c0e7ab23  bubbles/scripts/scenario-state-resolve-selftest.sh
4afe5618424dfe6a327a366c388e2cb9bcc72ea951390ca49dafd80b67a76df5  bubbles/registry/scenario-states.yaml
af3466cd0e169154be87e167993238c32c17608f978f81f52f347fcca7ff77a3  bubbles/scripts/phase-coordinator.sh
1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0  bubbles/scripts/state-transition-guard.sh
bfc9642ffacfdf4d28c46f9e79a180c1269f814d4443290d24f0b14ff074e2c3  bubbles/release-manifest.json
BUG042_TARGET_BASELINE_END
```

Rows 55 and 56 also recorded the complete protected-file hashes, canonical
main pointer, and worktree inventory before test execution.

### Focused Resolver And Consumer Matrix

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 360 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 64
**Complete Test Output Hash:**
`e4c00e19b459eed20b80cdccd1c96974bb72b3cbc583d1538a804ca93b202a5c`

```text
PASS: B042-T01 substituted-test replacement
PASS: B042-T01 selected IMPLEMENTED is not also blocked-not-run
PASS: B042-T01 superseded same-revision text is not labeled drift-only
PASS: B042-T02 substituted-control replacement
PASS: B042-T03 exit-zero RED replacement
PASS: B042-T04 equal timestamps use append ordinal
PASS: B042-T05 later substituted-test remains unresolved
PASS: B042-T06 later substituted-control remains unresolved
PASS: B042-T07 later exit-zero RED remains unresolved
PASS: B042-T08 later RED-only campaign is partial
PASS: B042-T09 later RED-IMPLEMENT campaign is partial
PASS: B042-T10 still-later coherent chain closes conflict
PASS: B042-T11 duplicate rows retain distinct ordinals
PASS: B042-T12 cross-scenario isolation
PASS: B042-T13 BUG-034 revision isolation
PROTECTION: B042-T13 drift-output-sha256=7a505dd15e59cb94eece826408a55e2eabdea33aed8b143a23dea24da33254c3 required-output-sha256=4d90f6a135ffe8abd8b9e6724e77a057e5acd095ca716d85b37fe877336d11fb mixed-output-sha256=59e94858ceb7b79e2b1ee6f0c41f7c1a81a243ee91a0d4b9775355e365f8bd00
PASS: B042-T14 proof identity cannot borrow phases
PASS: B042-T15 duplicate model ordinal refuses order
PASS: B042-T16 legacy receipts derive local identities
PASS: B042-T17 bypass arguments remain rejected
PASS: B042-T18 rollback preserves current ledger identities
PASS: consumer: phase coordinator preserves the corrected additive scenario-state payload
PASS: consumer: transition guard accepts corrected same-revision scenario evidence at Check 4
PASS: consumer: phase coordinator preserves its null boundary for unresolved resolver output
PASS: consumer: transition guard relays and blocks the current unresolved receipt
PASS: consumer: production coordinator and transition guard source bytes remain unchanged
scenario-state-resolve-selftest: 63 passed, 0 failed
```

The suite exercised all 18 planned rows. It also executed both unchanged
production consumers through success and unresolved-conflict fixtures.

### T13 Mutation Discriminator

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 420 /opt/homebrew/bin/bash /private/tmp/bug042-independent-t13-mutation.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 66
**Tool-Log Output Hash:**
`2db97fd7e9779e74bcb63724f51ce244594ae8189c0a0f0c982cc4686f3b5fb3`

```text
MUTATION_SETUP_EXIT=0
FAIL: B042-T13 BUG-034 revision isolation (12/15 checks; exits 0/1/1)
scenario-state-resolve-selftest: 62 passed, 1 failed
MUTATED_SUITE_EXIT=1
T13_FROZEN_BYTE_DISCRIMINATOR_FAILED=true
T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
T13_IS_SOLE_FAILURE=true
EXPECTED_MUTATED_SUITE_NONZERO=true
EXPECTED_T13_FROZEN_BYTE_DISCRIMINATOR_FAILED=true
EXPECTED_T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
EXPECTED_T13_IS_SOLE_FAILURE=true
```

The helper changed one revision-drift detail string in a disposable resolver
copy. The repository resolver and consumer bytes were never mutation targets.

### Test-Owned Integrity Checks

**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash /private/tmp/bug042-independent-test-guards.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 65
**Complete Validation Output:** 263 lines
**Complete Validation Output Hash:**
`817e15b3e750cde0c9adb2417e002d618dae62eee621852f55bcfd3eea1f23be`

```text
BEGIN_BASH_SYNTAX
END_BASH_SYNTAX_EXIT=0
BEGIN_SHELLCHECK_WARNINGS
END_SHELLCHECK_WARNINGS_EXIT=0
BEGIN_MATRIX_PARITY
BUG042_MATRIX_PARITY_HEADER plan=18 uniqueMatrix=18 uniqueLabels=18 exactCommands=18
B042-T01 designRows=1 persistentPassTitles=1 targetExact=1 idExact=1 label=B042-T01 substituted-test replacement
B042-T13 designRows=1 persistentPassTitles=1 targetExact=1 idExact=1 label=B042-T13 BUG-034 revision isolation
B042-T18 designRows=1 persistentPassTitles=1 targetExact=1 idExact=1 label=B042-T18 rollback preserves current ledger identities
BUG042_MATRIX_PARITY_RESULT rows=18 failures=0
END_MATRIX_PARITY_EXIT=0
BEGIN_REGISTRY_CODES
SCS-CHAIN-PARTIAL count=1
SCS-APPEND-ORDER-CONFLICT count=1
END_REGISTRY_CODES_EXIT=0
BEGIN_EXCLUDED_SURFACES
EXCLUDED_WORKTREE_DIFF_EXIT=0
EXCLUDED_CACHED_DIFF_EXIT=0
PROTECTED_HASH_RESULT=0
END_EXCLUDED_SURFACES_EXIT=0
BEGIN_DIFF_CHECK
END_DIFF_CHECK_EXIT=0
INCOMPLETE_MARKER_SCAN_EXIT=1 expected=1
TARGET_HEAD=a8e870039573a4a9c84da5a039446d1139a1b968
TARGET_BRANCH=fix/scenario-receipt-supersession
CANONICAL_HEAD=9aad46687658e5e605c83ef30e0b0070bd0164e6
CANONICAL_BRANCH=main
BUG042_INDEPENDENT_TEST_GUARDS_PASS
```

The fail-fast batch also passed artifact lint, traceability, linked-test
resolution, scenario obligations, test mechanisms, execution substate,
regression quality, skip and live-mock scans, registry consistency, ownership,
and every declared boundary path.

Tool-log row 62 records that the project has no `testImpact` or
`traceContracts` block. It also records zero `observabilityWorkflow` entries
in this bug's test plan. Trace and SLO capture are therefore not applicable.

### Test Integrity Audit

- The skip-marker scan returned the expected no-match exit 1.
- The live-mock scan returned the expected no-match exit 1.
- The regression-quality guard reported zero violations.
- The integration rows invoked production consumers with hermetic fixtures.
- The mutation check changed production behavior and made only T13 fail.
- No required assertion validates a fixture without a production decision.

The last item has **Claim Source:** interpreted.
**Interpretation:** T01 through T18 assert resolver-selected states, diagnostics,
ordinals, hashes, exits, rollback behavior, or consumer outcomes. The one-string
mutation proves that the frozen-byte assertion changes when production output
changes.

### Independent Finding Accounting

| Finding | Independent result | Evidence |
| --- | --- | --- |
| `F-B042-RG-01` | Independently verified. Selected `IMPLEMENTED` is absent from `blockedNotRun`. | Row 64 |
| `F-B042-RG-02` | Independently verified. Same-revision superseded text has no drift-only summary. | Row 64 |
| `F-B042-RG-03` | Independently verified. Both output invariants execute in the persistent suite. | Rows 64 and 65 |
| `F-B042-RG-04` | Independently verified. Three frozen hashes pass, and one string mutation fails only T13. | Rows 64 and 66 |

No inherited remediation finding remains unresolved. The independent test
phase routes to `bubbles.regression`, which follows test in the delivery phase
order. Planning-owned DoD checkboxes and validate-owned certification remain
unchanged.

### Test Verdict

| Test type | Planned cases | Passed | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| integration | 2 | 2 | 0 | 0 |
| functional | 16 | 16 | 0 | 0 |
| focused suite assertions | 63 | 63 | 0 | 0 |
| mutation discriminator | 1 | 1 | 0 | 0 |

`bubbles.test` completed its assigned independent phase. Framework-wide
validation and release readiness remain owned by later workflow phases.

## E-B042 Regression Closeout Retry

### Verdict

**Verdict:** `REGRESSION_DETECTED`

The BUG-042 candidate itself passed its focused resolver, consumer, mutation,
traceability, coverage-delta, and boundary checks. The required core-tier
discriminator did not pass on this checkout. The regression phase therefore
remains incomplete and is not routed to `bubbles.simplify`.

### Current-Byte Focused Evidence

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 420 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Structured Tool-Log Output SHA-256:**
`9fbf7c8f92b3424dae4527616948f138e7ed0224a28878a29b302958009d177a`

The structured input closure records these current candidate hashes:

- Resolver: `42ed92f6927ce5f4af327caa338652ee33e2c6d3f04f29da28e34435410173fe`.
- Focused selftest: `91c36d663a15413a17cb7ee8acc92a7317ed4200da936b0390337091c0e7ab23`.
- State registry: `4afe5618424dfe6a327a366c388e2cb9bcc72ea951390ca49dafd80b67a76df5`.
- Phase coordinator: `af3466cd0e169154be87e167993238c32c17608f978f81f52f347fcca7ff77a3`.
- Transition guard: `1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0`.

The command returned zero on the unchanged 63-assertion focused suite. The
preceding independent test baseline recorded 63 passed and zero failed on the
same source, selftest, registry, and consumer hashes.

### Four Original Regression Discriminators

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 /opt/homebrew/bin/bash /private/tmp/bug042-regression-current-text-probe.sh`
**Exit Code:** 0
**Claim Source:** executed
**Complete Output SHA-256:**
`4e0581765517a28ae3981ee71ac724069add672ba0cf210ceb7d5489ab483065`

The direct production probe returned these unambiguous signals:

```text
JSON_RESOLVER_EXIT=0
TEXT_RESOLVER_EXIT=0
DERIVED_IMPLEMENTED=true expected=true
BLOCKED_IMPLEMENTED=false expected=false
SUPERSEDED_TEST_DIAGNOSTIC_COUNT=1 expected=1
FALSE_DRIFT_ONLY_SUMMARY_PRESENT=false expected=false
BUG042_DIRECT_TEXT_JSON_PROBE_END
```

These signals replay the original RG-01 and RG-02 failures. The focused suite
also executed both T01 output assertions, which closes the RG-03 persistence
discriminator.

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 420 /opt/homebrew/bin/bash /private/tmp/bug042-regression-current-t13-probe.sh`
**Exit Code:** 0
**Claim Source:** executed
**Complete Output SHA-256:**
`2db97fd7e9779e74bcb63724f51ce244594ae8189c0a0f0c982cc4686f3b5fb3`

```text
MUTATION_SETUP_EXIT=0
FAIL: B042-T13 BUG-034 revision isolation (12/15 checks; exits 0/1/1)
scenario-state-resolve-selftest: 62 passed, 1 failed
MUTATED_SUITE_EXIT=1
T13_FROZEN_BYTE_DISCRIMINATOR_FAILED=true
T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
T13_IS_SOLE_FAILURE=true
EXPECTED_MUTATED_SUITE_NONZERO=true
EXPECTED_T13_FROZEN_BYTE_DISCRIMINATOR_FAILED=true
EXPECTED_T13_STILL_PASSES_AFTER_BYTE_CHANGE=false
EXPECTED_T13_IS_SOLE_FAILURE=true
```

The mutation changed only one revision-drift detail string in disposable
copies. T13 became the sole failure, which replays RG-04 without modifying the
repository resolver, consumers, or BUG-034 artifacts.

### Regression Integrity And Coverage Delta

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 1140 /opt/homebrew/bin/bash /private/tmp/bug042-regression-repository-checks.sh`
**Exit Code:** 0
**Claim Source:** executed
**Complete Output SHA-256:**
`03a07f19111f8a4dcd367cbeac6c89e6d0c64661d14590c69f8e1d31970a10e1`

The batch reported zero failures across regression quality, traceability,
linked tests, scenario obligations, test mechanisms, baseline integrity,
selftest inventory, registry consistency, execution substate, artifact lint,
implementation reality, discovered-issue disposition, skip/mock scans, and the
declared work boundary. It also verified unchanged hashes for both production
consumers, the tool-call schema, and the release manifest. No deployment
surface changed.

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 360 /opt/homebrew/bin/bash /private/tmp/bug042-regression-coverage-delta.sh`
**Exit Code:** 0
**Claim Source:** executed
**Complete Output SHA-256:**
`f1532c176a83ed543be1caae13e70a8720e1d6f981aa565e1a2739aa894cca2c`

| Signal | Independent test baseline | Regression retry | Delta |
| --- | ---: | ---: | ---: |
| Focused assertions | 63 passed | 63 passed | 0 |
| Stable scenarios | 5 | 5 | 0 |
| Test-plan rows | 18 | 18 | 0 |

The source command registry declares no line-coverage operation. The
repository selftest inventory passed with 272 tests: 249 enumerated, 21
discovered, and 2 denied.

### Blocking Core-Tier Discriminator

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 180 /opt/homebrew/bin/bash bubbles/scripts/guard-lib-timeout-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Complete Output SHA-256:**
`1f405b58ff6c35d2ce50104ec7b547e7dd9804f10d510bc5893901d8ef0ff0d5`

```text
  PASS  instant command in $( ) returns promptly (0s, output intact)
  PASS  timeout fires and normalizes to 124 (3s)
  PASS  command exit code preserved (rc=7, 0s)
  PASS  fallback child can trap SIGINT (rc=130, 0s)
  FAIL  progress-aware command returned rc=2 after 2s
  FAIL  idle timeout returned rc=2 reason=none after 2s
  FAIL  absolute timeout returned rc=2 reason=none after 2s
  PASS  progress runner preserves command exit code (rc=9)
  FAIL  timed-out validator leaked or blocked: pid=74075 rc=2 reason=none elapsed=6s
  PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: 4 failure(s)
```

**Phase:** regression
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 90 /opt/homebrew/bin/bash /private/tmp/bug042-regression-core-failure-provenance.sh`
**Exit Code:** 0
**Claim Source:** executed
**Complete Output SHA-256:**
`6b2fb328ca2e8051b753fd247b03da42d41b9ae496f72fb433d518c52c1ee0be`

The provenance check found that commit
`130691932e815c622ab9601195c8eba0c41c6b90` contains the progress-log size
normalization and is present on the local `origin/main` ref but absent from this
worktree HEAD. It also verified that `guard-lib.sh` and
`bubbles/release-manifest.json` have no worktree diff. Both files are excluded
from BUG-042's allowed paths, so this regression phase did not modify them.

The 30-minute full framework validation was not repeated. Its targeted failing
selftest reproduced on current bytes, which is sufficient to reject a clean
regression verdict without spending the broader suite cost.

### Six-Finding Accounting And Blocked Routing

| Finding | Regression result |
| --- | --- |
| `F-B042-01` | Verified by the zero-exit focused resolver and consumer suite. |
| `F-B042-02` | Verified by deterministic T04, T11, and T15 coverage in the zero-exit focused suite. |
| `F-B042-RG-01` | Verified by `DERIVED_IMPLEMENTED=true` with `BLOCKED_IMPLEMENTED=false`. |
| `F-B042-RG-02` | Verified by one visible superseded diagnostic with no drift-only summary. |
| `F-B042-RG-03` | Verified by the two persistent T01 output assertions and clean regression-quality checks. |
| `F-B042-RG-04` | Verified by frozen current hashes and the sole-failure one-string mutation. |

All six BUG-042 findings are regression-verified. The separate core-tier
failure prevents phase completion. The next owner is `bubbles.goal`, which can
resolve the current goal-node worktree's missing already-existing guard-lib
fix without violating BUG-042's boundary. Certification, DoD, human
acceptance, canonical Bubbles, release metadata, and unrelated worktrees remain
unchanged.

## E-B042 External Base Prerequisite Import

### Closed Authorization And Byte Identity

**Phase:** implement
**Claim Source:** executed
**Result:** PASS

The inherited packet validated for goal node `bubbles-close-bug-042` at control
revision 8. The current planning authorization is
`scopes.md#external-base-prerequisite-import`; it adds only the exact two-path
exception to the older `state.json` path list.

Commit `130691932e815c622ab9601195c8eba0c41c6b90` has parent
`863243ca236fab4c640e3ce08a1b4263ca67f597`. Before the edit,
`guard-lib.sh` matched parent blob
`fd037b38afd892dfe642aca4a859189900bd5609`, while the clean branch manifest
matched `429bb7ab75c636ccd94923264f2b5daa84d2f081` and carried the authorized old
entry. Post-edit verification produced:

```text
GUARD_LIB_WORKTREE_BLOB=e8e404a5c157c94e822a07dcee1076d1239d7a8b
GUARD_LIB_EXPECTED_BLOB=e8e404a5c157c94e822a07dcee1076d1239d7a8b
MANIFEST_NUMSTAT_ADDITIONS=1
MANIFEST_NUMSTAT_DELETIONS=1
MANIFEST_OLD_SHA256=0c5f9cfb8d61eb59e37f0d98de02cce8936a59800b9fc6e6a3fb01e9d7c0750c
MANIFEST_NEW_SHA256=c27cad8f23ec9dafb3049fe21b9be3b95c9f973fd70e094293752b2d99ae787c
GUARD_LIB_INDEX_BLOB=fd037b38afd892dfe642aca4a859189900bd5609
MANIFEST_INDEX_BLOB=429bb7ab75c636ccd94923264f2b5daa84d2f081
STAGED_PREREQUISITE_DIFF=none
PREREQUISITE_DIFF_CHECK_EXIT=0
```

No cherry-pick, merge, checkout, manifest regeneration, prerequisite commit,
installation, or downstream copy occurred.

### Focused Ten-Case Proof

**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash bubbles/scripts/guard-lib-timeout-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
PASS  instant command in $( ) returns promptly (0s, output intact)
PASS  timeout fires and normalizes to 124 (3s)
PASS  command exit code preserved (rc=7, 0s)
PASS  fallback child can trap SIGINT (rc=130, 0s)
PASS  progress extends the idle window without exceeding the absolute ceiling (5s)
PASS  silent command stops at the idle deadline with rc=124 (3s)
PASS  chatty command stops at the absolute deadline with rc=125 (5s)
PASS  progress runner preserves command exit code (rc=9)
PASS  absolute timeout force-terminates a TERM-resistant validator process group (9s)
PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: OK (10 cases)
```

The command printed ten PASS case lines, zero FAIL case lines, and the required
final sentinel. It proves only the imported timeout normalization.

### Resolver Preservation And Boundary Routing

**Phase:** implement
**Claim Source:** executed

Post-import hashes preserve the independently verified BUG-042 candidate:

```text
42ed92f6927ce5f4af327caa338652ee33e2c6d3f04f29da28e34435410173fe  bubbles/scripts/scenario-state-resolve.sh
91c36d663a15413a17cb7ee8acc92a7317ed4200da936b0390337091c0e7ab23  bubbles/scripts/scenario-state-resolve-selftest.sh
4afe5618424dfe6a327a366c388e2cb9bcc72ea951390ca49dafd80b67a76df5  bubbles/registry/scenario-states.yaml
```

Those hashes equal the pre-import baseline in
`E-B042-TEST-REMEDIATION-INDEPENDENT`. The imported edit did not change either
excluded production consumer, BUG-034, canonical Bubbles, or another worktree.

The mechanical work-boundary resolver returned exit `0` with
`route-same-repo` for both `bubbles/scripts/guard-lib.sh` and
`bubbles/release-manifest.json`. It follows the older `state.json` path list and
does not recognize the later closed planning exception. This result is not
treated as an in-boundary pass. `F-B042-BOUNDARY-METADATA-01` routes the metadata
mismatch to `bubbles.plan`: reconcile the state boundary with only the two
already-authorized closed deltas, without widening source authorship.

All six resolver findings retain their `regression_verified` accounting. The
current bytes route back to `bubbles.regression`; no framework-wide validation,
release-readiness, certification, or human-acceptance result is claimed here.
