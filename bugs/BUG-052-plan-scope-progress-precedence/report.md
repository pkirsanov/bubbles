# BUG-052 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Reproduced the deprecated top-level empty-array shadow as the sole failing
  focused selftest case before changing production code.
- Made `certification.scopeProgress` authoritative and retained top-level
  `scopeProgress` only as the absent-or-null compatibility fallback.
- Added canonical-versus-legacy, legacy-only, canonical-versus-execution, and
  canonical-empty adversarial fixtures in the nearest selftest.
- Regenerated and verified the shared release manifest.
- Added the exact two-file implementation inventory and re-ran implementation
  reality and artifact checks on the current planning bytes.
- Closed implementation ownership against current source and packet bytes, then
  routed independent verification to `bubbles.test` without changing certification.

## Completion Statement

The source repair and focused implementation checks are recorded below. The
planning-owned implementation inventory names both implementation files, and
the current implementation reality, artifact, execution-substate, diff,
release-manifest, and neighboring-byte checks exit 0. Implementation ownership
is recorded as `completed_owned` and routed to `bubbles.test`. The bug remains
`in_progress`; the combined full framework suite was not run in this closeout,
and validate-owned certification remains unchanged.

## Test Evidence

### SCN-B052-001 RED reproduction

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Output SHA-256:** `ffb1d428ec63e2ee2cc71a6c14470e1b5f4177723d3ee61933c9a366e50ee603`

```text
Running plan-dependency-depth-guard selftest...
PASS: T1 no state.json → exit 0
PASS: T2 no dependsOn edges → no-op (exit 0)
PASS: T3 scopeDir bodies missing → no-op (exit 0)
PASS: T4 early-numbered DAG-deep consumer, block → exit 1
PASS: T5 DAG-deep consumer, advisory → exit 0
PASS: T6 transitive-chain deep consumer, block → exit 1
PASS: T7 early usable consumer exists (min 1 foundation), block → exit 0
PASS: T8 no consumer scope → no-op (exit 0)
PASS: T9 consumer needs 2 foundations (below threshold), block → exit 0
PASS: T10 missing feature dir → exit 2
PASS: T11 malformed state.json → exit 2
PASS: T12 counts-summary object scopeProgress, block → no-op (exit 0)
PASS: T13 counts-summary under certification, block → no-op (exit 0)
PASS: T14 non-object scopeProgress entries, block → no-op (exit 0)
PASS: T15 real horizontal chain still BLOCKS under block posture (exit 1)
FAIL: T16 SCN-B052-001 legacy empty array cannot shadow canonical deep graph (exit 1) (expected exit 1, got 0)

plan-dependency-depth-guard-selftest FAILED with 1 issue(s).
```

**Result:** Expected RED. The simultaneous-field fixture alone exposed the
top-level-first false no-op before the production edit.

### BUG-052 focused GREEN

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `d28e1c7b15737b645af2027ea311da27a3fb7b8b128247f552a7c1e6206d84ec`

```text
Running plan-dependency-depth-guard selftest...
PASS: T1 no state.json → exit 0
PASS: T2 no dependsOn edges → no-op (exit 0)
PASS: T3 scopeDir bodies missing → no-op (exit 0)
PASS: T4 early-numbered DAG-deep consumer, block → exit 1
PASS: T5 DAG-deep consumer, advisory → exit 0
PASS: T6 transitive-chain deep consumer, block → exit 1
PASS: T7 early usable consumer exists (min 1 foundation), block → exit 0
PASS: T8 no consumer scope → no-op (exit 0)
PASS: T9 consumer needs 2 foundations (below threshold), block → exit 0
PASS: T10 missing feature dir → exit 2
PASS: T11 malformed state.json → exit 2
PASS: T12 counts-summary object scopeProgress, block → no-op (exit 0)
PASS: T13 counts-summary under certification, block → no-op (exit 0)
PASS: T14 non-object scopeProgress entries, block → no-op (exit 0)
PASS: T15 real horizontal chain still BLOCKS under block posture (exit 1)
PASS: T16 SCN-B052-001 legacy empty array cannot shadow canonical deep graph (exit 1)
PASS: T17 SCN-B052-002 canonical shallow graph wins over legacy deep graph (exit 0)
PASS: T18 SCN-B052-003 legacy-only deep graph remains blocking (exit 1)
PASS: T19 SCN-B052-004 canonical graph wins over execution deep graph (exit 0)
PASS: T20 canonical empty array remains authoritative over legacy deep graph (exit 0)

plan-dependency-depth-guard-selftest: all cases passed.
```

**Result:** PASS. All four BUG-052 scenarios and every pre-existing depth,
shape, malformed-array, edge, and missing-body case passed.

### Targeted shell and portability validation

**Executed:** YES
**Phase:** implement
**Claim Source:** executed

- `bash -n bubbles/scripts/plan-dependency-depth-guard.sh bubbles/scripts/plan-dependency-depth-guard-selftest.sh` -> exit 0, structured tool-log tag `shell-syntax`.
- `shellcheck -x bubbles/scripts/plan-dependency-depth-guard.sh bubbles/scripts/plan-dependency-depth-guard-selftest.sh` -> exit 0, structured tool-log tag `shellcheck`.
- `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/plan-dependency-depth-guard.sh bubbles/scripts/plan-dependency-depth-guard-selftest.sh` -> exit 0; all 16 portability classes reported `none` and the guard reported `PASS`.

### Release manifest integrity

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/release-manifest-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `f475d294f78256f27f11797df1f03ad755db104de9f55dd84ebf2a5928780210`

```text
Running release-manifest selftest...
Scenario: release hygiene generates one complete trust manifest for downstream installs.
PASS: Committed release manifest is current
PASS: Release manifest exists
PASS: Manifest records release version
PASS: Manifest records source git SHA
PASS: Manifest records trust docs digest
PASS: Manifest records framework-managed file count (927)
PASS: Managed checksum inventory includes framework agents
PASS: Managed checksum inventory includes shared CLI surface
PASS: Unstaged new file stays outside the payload until it is tracked
PASS: A tracked managed file is admitted to the payload
PASS: Ignored scratch file stays outside payload
PASS: Manifest records source-only file count (111)
PASS: Source-only checksum inventory includes G094 regression test
PASS: Managed checksum inventory includes IMP-020 S2 aggregator
PASS: Managed checksum inventory includes IMP-020 S2 aggregator selftest
PASS: Managed checksum inventory includes IMP-020 S2 sample schema (BUG015-F2)
PASS: IMP-020 S2 sample schema is no longer source-only (BUG015-F2)
PASS: Source-only inventory retains eval-harness schema: bubbles/eval/schemas/task-v2.schema.json
PASS: eval-harness schema stays out of managed set: bubbles/eval/schemas/task-v2.schema.json
PASS: Source-only inventory retains eval-harness schema: bubbles/eval/schemas/evaluator-result.schema.json
PASS: eval-harness schema stays out of managed set: bubbles/eval/schemas/evaluator-result.schema.json
PASS: Manifest exposes foundation as a supported profile
PASS: Manifest exposes delivery as a supported profile
PASS: Manifest exposes Claude Code as a supported interop source
PASS: Manifest exposes Roo Code as a supported interop source
PASS: Manifest exposes Cursor as a supported interop source
PASS: Manifest exposes Cline as a supported interop source
release-manifest selftest passed.
```

`generate-release-manifest.sh` and its subsequent `--check` each exited 0;
the check reported release `7.28.0` current with 927 managed files.

### Change boundary and prior-bug preservation

**Executed:** YES
**Phase:** implement
**Command:** Structured tool-log entry tagged `change-boundary,byte-preservation` containing the complete pre-edit hash and status comparison command.
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `17306d9eb1eca3ff0ce4c066ee98523aaca15c34c1920932c467c9ca71010276`
**Output:** 66 lines captured in full; the bounded evidence retained the first and
last 20 lines plus the hash over every line.

```text
PASS: BUG-047 through BUG-051 bytes match the pre-edit 45-file baseline
Current worktree status:
 M BUGS.md
 M bubbles/release-manifest.json
 M bubbles/scripts/install-provenance-selftest.sh
 M bubbles/scripts/plan-dependency-depth-guard-selftest.sh
 M bubbles/scripts/plan-dependency-depth-guard.sh
 M bubbles/scripts/state-transition-guard-selftest.sh
 M bubbles/scripts/state-transition-guard.sh
 M bubbles/scripts/yaml-schema-validate.sh
 M improvements/INDEX.md
?? .specify/memory/bubbles.session.json.flock
?? bugs/BUG-047-reasoned-skip-phase-accounting/
?? bugs/BUG-048-test-plan-owner-label-path/
?? bugs/BUG-049-separate-process-g040-prefix/
?? bugs/BUG-050-transition-local-receipt-admission/
?? bugs/BUG-051-yaml-validator-downstream-root/
?? bugs/BUG-052-plan-scope-progress-precedence/
PASS: worktree status adds only the two BUG-052 script paths to the pre-edit inventory
PASS: touched tracked files pass git diff --check
```

### Implementation reality route

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-052-plan-scope-progress-precedence --verbose`
**Exit Code:** 1
**Claim Source:** executed
**Output SHA-256:** `d7c5a6c92cbe94c3695342f3e5e388ba31ca588d1ef60528fd63505c0782f388`

```text
ℹ️  INFO: Scopes yielded 0 files — falling back to design.md for file discovery
ℹ️  INFO: No Implementation Files in scopes.md/design.md — falling back to filesystem search for slug 'BUG-052-plan-scope-progress-precedence'
🔴 VIOLATION [ZERO_FILES_RESOLVED] No implementation file paths resolved from scope files

This means scopes.md / scope.md files either:
  1. Do not reference implementation files in backtick-wrapped paths, or
  2. Reference files that do not exist on disk

Scanning nothing = no assurance. This is a blocking failure.
Fix: Ensure scopes.md lists implementation files as `path/to/file.ext`

============================================================
  REALITY SCAN RESULT: 1 violation(s), 0 warning(s)
  Files scanned: 0
============================================================
```

**Result:** ROUTE REQUIRED. Finding `FP-B052-IMPLEMENTATION-FILES` belongs to
`bubbles.plan`; implement ownership did not add or rewrite planning content.

### Planner-owned inventory reconciliation

The initial implementation reality finding above remains historical evidence.
`bubbles.plan` added the exact two-file inventory to `scopes.md` and executed
the current checks below. This reconciliation changes no production code,
selftest, release manifest, certification field, or neighboring bug packet.

#### Current-byte implementation reality

**Executed:** YES
**Phase:** plan
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-052-plan-scope-progress-precedence --verbose`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
ℹ️  INFO: Resolved 2 implementation file(s) to scan

--- Scan 1: Gateway/Backend Stub Patterns ---

--- Scan 1B: Handler / Endpoint Execution Depth ---

--- Scan 1C: Endpoint Not-Implemented / Placeholder Responses ---

--- Scan 1D: External Integration Authenticity ---

--- Scan 2: Frontend Hardcoded Data Patterns ---

--- Scan 2B: Sensitive Client Storage ---

--- Scan 3: Frontend API Call Absence ---

--- Scan 4: Prohibited Simulation Helpers in Production ---

--- Scan 5: Default/Fallback Value Patterns ---

--- Scan 6: Live-System Test Interception ---
ℹ️  INFO: No live-system test files referenced in scope artifacts for interception scan

--- Scan 7: IDOR / Auth Bypass Detection (Gate G047) ---

--- Scan 8: Silent Decode Failure Detection (Gate G048) ---

============================================================
  IMPLEMENTATION REALITY SCAN RESULT
============================================================

  Files scanned:  2
  Violations:     0
  Warnings:       0

🟢 PASSED: No source code reality violations detected
```

#### Current artifact structure

**Executed:** YES
**Phase:** plan
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/artifact-lint.sh bugs/BUG-052-plan-scope-progress-precedence`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

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

**Result:** Finding `FP-B052-IMPLEMENTATION-FILES` is addressed. This planner
invocation makes no implementation, test, audit, or certification completion
claim; implementation closeout returns to `bubbles.implement`.

### Implementation closeout current-byte checks

**Executed:** YES
**Phase:** implement
**Claim Source:** executed

The implementation owner re-read the current report, state, scopes, production
guard, and focused selftest bytes. The production selector remains
`(.certification.scopeProgress // .scopeProgress // [])`; T16-T20 remain the
focused precedence cases, and `execution.scopeProgress` is not in the authority
chain. No RED or focused GREEN command was rerun.

The following commands were recorded in `.specify/runtime/tool-calls.jsonl`:

```text
bash bubbles/scripts/mode-resolver.sh --grandfather bugfix-fastlane
  exit 0; resolved statusCeiling: done
bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-052-plan-scope-progress-precedence --verbose
  exit 0; 2 files scanned; 0 violations; 0 warnings
bash bubbles/scripts/artifact-lint.sh bugs/BUG-052-plan-scope-progress-precedence
  exit 0; artifact lint passed
bash bubbles/scripts/generate-release-manifest.sh --check
  exit 0; release 7.28.0 current with 927 managed files
bash bubbles/scripts/execution-substate-guard.sh bugs/BUG-052-plan-scope-progress-precedence
  exit 0; execution substate is valid and distinct from certification
/opt/local/bin/git diff --check
  exit 0; tracked diff hygiene passed
bash bubbles/scripts/evidence-capture.sh --verify b0ee1ef84a47ef96c0ee47b9bb9399eeac6f40fee1be238e9106553f62f7fbcd -- /usr/bin/shasum -a 256 <45 BUG-047..BUG-051 files>
  exit 0; all 45 neighboring files match the pre-closeout byte snapshot
```

The first diff-hygiene attempt used `/usr/bin/git` and exited 69 because the
machine's Xcode license is not accepted. That attempt produced no hygiene
verdict. The same check was rerun with the installed MacPorts Git binary and
exited 0, as recorded above.

`state.json.execution.substate` is `implemented`,
`completedPhaseClaims` contains `implement`, and the execution-history entry
keeps both top-level and certification status at `in_progress`. The next owner
is `bubbles.test`, which owns the combined BUG-047 through BUG-052 full framework
T6 run. This section makes no independent-verification or certification claim.

<!-- bubbles:certifying-window-begin -->

## Code Diff Evidence

The implementation delta changes the jq authority chain from deprecated
top-level-first to certification-first, adds T16-T20 to the existing hermetic
selftest, and refreshes `bubbles/release-manifest.json`. No execution authority
was added to the selection chain.

## Validation Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run.

## Chaos Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.chaos
**Claim Source:** not-run

Chaos validation was not run during this implementation phase.

## Independent Focused Test Verification

**Executed:** YES
**Phase:** test
**Claim Source:** executed
**Repository binding:** scenario node `complete-bubbles-bug052`, decision
`rb:vscode-495a6380e8e00ef101b07d78b21f9341:3:node:complete-bubbles-bug052`,
control revision `3`.

### Focused T1-T5 execution

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh`
**Exit Code:** 0
**Output SHA-256:** `d28e1c7b15737b645af2027ea311da27a3fb7b8b128247f552a7c1e6206d84ec`

```text
Running plan-dependency-depth-guard selftest...
PASS: T1 no state.json -> exit 0
PASS: T2 no dependsOn edges -> no-op (exit 0)
PASS: T3 scopeDir bodies missing -> no-op (exit 0)
PASS: T4 early-numbered DAG-deep consumer, block -> exit 1
PASS: T5 DAG-deep consumer, advisory -> exit 0
PASS: T6 transitive-chain deep consumer, block -> exit 1
PASS: T7 early usable consumer exists (min 1 foundation), block -> exit 0
PASS: T8 no consumer scope -> no-op (exit 0)
PASS: T9 consumer needs 2 foundations (below threshold), block -> exit 0
PASS: T10 missing feature dir -> exit 2
PASS: T11 malformed state.json -> exit 2
PASS: T12 counts-summary object scopeProgress, block -> no-op (exit 0)
PASS: T13 counts-summary under certification, block -> no-op (exit 0)
PASS: T14 non-object scopeProgress entries, block -> no-op (exit 0)
PASS: T15 real horizontal chain still BLOCKS under block posture (exit 1)
PASS: T16 SCN-B052-001 legacy empty array cannot shadow canonical deep graph (exit 1)
PASS: T17 SCN-B052-002 canonical shallow graph wins over legacy deep graph (exit 0)
PASS: T18 SCN-B052-003 legacy-only deep graph remains blocking (exit 1)
PASS: T19 SCN-B052-004 canonical graph wins over execution deep graph (exit 0)
PASS: T20 canonical empty array remains authoritative over legacy deep graph (exit 0)

plan-dependency-depth-guard-selftest: all cases passed.
```

T1-T5 map to the one canonical focused command. T6 in the bug Test Plan means
`bash bubbles/scripts/cli.sh framework-validate`; it was deliberately not run
because the operator reserved it for the combined stage after BUG-053.

### Scenario contract checks

**Claim Source:** executed

```text
scenario-test-resolve.sh: exit 0
[scenario-test-resolve] OK - 4 reference(s) resolved via literal-scan

scenario-obligation-lint.sh: exit 0
[scenario-obligation-lint] OK - 4 scenario(s) with a coherent derived obligation matrix

test-mechanism-lint.sh: exit 1
test-mechanism-lint: FAIL - declared mechanism does not support the claim (COV-10)
  NON-VACUITY: SCN-B052-002
    riskTier 'high' needs at least 'mutation' but the control is 'perturbed-input'.
    Strengthen it, or state a negativeControlFallbackReason naming why it cannot be.
```

Finding `B052-TEST-MECHANISM-HIGH-RISK-CONTROL` is planning-owned. The test
phase did not edit `scenario-manifest.json`.

### Regression, shell, and portability checks

**Claim Source:** executed

```text
regression-quality-guard.sh --bugfix --verbose: exit 0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1

bash -n plan-dependency-depth-guard.sh plan-dependency-depth-guard-selftest.sh: exit 0
shellcheck -x plan-dependency-depth-guard.sh plan-dependency-depth-guard-selftest.sh: exit 0
macos-portability-guard.sh: exit 0
PASS: the scanned surface is WSL+macOS portable.

skip-marker grep: exit 1
PASS interpretation: grep exit 1 with empty output means zero forbidden markers matched.
```

The self-validating-test audit traced T16-T20 through the `run` helper into the
production guard. Each case writes conflicting graph inputs and asserts the
guard-produced exit code. Replacing the guard with input passthrough would not
satisfy those paired blocking and passing expectations.

### Reality, manifest, and neighboring-byte checks

**Claim Source:** executed

```text
implementation-reality-scan.sh --verbose: exit 0
Files scanned: 2; violations: 0; warnings: 0

artifact-lint.sh: exit 0
Artifact lint PASSED.

generate-release-manifest.sh --check: exit 1
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh

generate-release-manifest.sh --check (final independent rerun): exit 0
Release manifest is current: 7.28.0 (927 managed files)

neighbor-byte evidence-capture verification: exit 0
[evidence-capture] VERIFIED - output still hashes to b0ee1ef84a47ef96c0ee47b9bb9399eeac6f40fee1be238e9106553f62f7fbcd
```

The stale-manifest result occurred after BUG-053 changed the managed
`evidence-capture.sh` pair in the shared checkout. The BUG-053 owner then
regenerated the manifest. This test phase's first retry was interrupted and
produced no verdict; the final independent rerun completed with exit 0 and
confirmed the current 927-file manifest.
The 45 BUG-047 through BUG-051 artifact files remain byte-identical to their
recorded baseline.

### Independent verdict

`NOT_TESTED`: focused behavior T1-T5 is green, but test-mechanism lint has one
planning-owned blocking finding, and full framework T6 was not run by
instruction. Route first to `bubbles.plan`
for `B052-TEST-MECHANISM-HIGH-RISK-CONTROL`; return to `bubbles.test` for the
failed-check reruns and the combined post-BUG-053 full validation stage.

### Test-owned artifact closeout

**Phase:** test
**Claim Source:** executed

```text
final artifact-lint.sh: exit 0
Artifact lint PASSED.

final execution-substate-guard.sh: exit 0
[execution-substate-guard] OK - execution substate is valid and distinct from certification.

certification pre-edit SHA-256:
8a394402801d76dc0411e51304be63950c0f0d5e2fe618f6fcf718c8c826282a
certification final SHA-256:
8a394402801d76dc0411e51304be63950c0f0d5e2fe618f6fcf718c8c826282a
BUG052_CERTIFICATION_PRESERVED=PASS

final generate-release-manifest.sh --check: exit 0
Release manifest is current: 7.28.0 (927 managed files)

current production guard SHA-256:
4ddc4750c654d995fd29e47b1f62304a7420cbb1096ce4aee05c908499766d37
current focused selftest SHA-256:
260897be02260bd0b61684b69e871cebed480e81a6bca683eafd03f7a63cb771
PASS: both match the passing T1-T5 tool-log input closure.

git diff --check -- <BUG-052 scopes/report/state>: exit 0
```

Only `scopes.md`, `report.md`, and execution-owned fields in `state.json` were
updated by this test phase. Certification stayed unchanged, and no production
code, scenario contract, test plan, release manifest, or neighboring packet was
edited by `bubbles.test`.

## Planner-owned high-risk mechanism reconciliation

**Executed:** YES
**Phase:** plan
**Claim Source:** executed
**Repository binding:** scenario node `complete-bubbles-bug052`, decision
`rb:vscode-495a6380e8e00ef101b07d78b21f9341:3:node:complete-bubbles-bug052`,
control revision `3`.

`bubbles.plan` changed only SCN-B052-002
`testMechanism.negativeControlMechanism` from `perturbed-input` to `mutation`,
the minimum supported mechanism for its existing `riskTier: high`. The
negative-control prose, linked production/selftest paths, and all previously
executed focused T1-T5 evidence above remain unchanged. T6 was not run. The
earlier independent verdict remains the test phase's historical route on its
pre-repair tree; this section records closure of its planning-owned finding.

### Planner validation

**Claim Source:** executed

```text
test-mechanism-lint.sh: exit 0
[test-mechanism-lint] OK — 4 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)

scenario-obligation-lint.sh: exit 0
structured tool-log stdout hash: 3979d4214fdb7145fa4cad82986c6a605516b95479ac3ed7f6308d0a62022a0b

artifact-lint.sh: exit 0
structured tool-log stdout hash: 182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567

jq empty scenario-manifest.json state.json: exit 0
empty stdout; structured tool-log recorded the successful parse
```

An initial `jq -e empty` invocation exited 4 because `-e` requires the filter
to emit a truthy result. It was not used as JSON evidence. The corrected
parse-only invocation above exited 0.

## Independent mechanism reconciliation

**Executed:** YES
**Phase:** test
**Claim Source:** executed
**Repository binding:** scenario node `complete-bubbles-bug052`, decision
`rb:vscode-495a6380e8e00ef101b07d78b21f9341:3:node:complete-bubbles-bug052`,
control revision `3`.

The focused 20-case T1-T5 command was not rerun. The production guard and
focused selftest match the SHA-256 identities recorded by the prior independent
test receipt, so this section preserves that receipt without representing it as
current-session execution. T6 was not run by explicit operator instruction.

### Current-byte and contract checks

```text
current-byte identity: exit 0
bubbles/scripts/plan-dependency-depth-guard.sh: OK
bubbles/scripts/plan-dependency-depth-guard-selftest.sh: OK

test-mechanism-lint.sh: exit 0
[test-mechanism-lint] OK — 4 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)

scenario-obligation-lint.sh: exit 0
[scenario-obligation-lint] OK — 4 scenario(s) with a coherent derived obligation matrix

artifact-lint.sh: exit 0
Artifact lint PASSED.

jq empty scenario-manifest.json state.json: exit 0
empty stdout; structured tool-log recorded the successful parse
```

The corrected SCN-B052-002 mutation declaration is independently coherent on
the current planning bytes. The packet remains `in_progress`; combined T6 and
certification remain owned by `bubbles.validate`.
