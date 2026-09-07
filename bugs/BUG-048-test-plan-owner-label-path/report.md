# BUG-048 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Added a stateful Test Plan table extractor to Check 8.
- Limited path candidates to recognized file and path columns.
- Reused the existing token, suffix, existence, and basename validation.
- Added focused coverage for all four BUG-048 scenarios.
- Regenerated and verified the release manifest.

## Completion Statement

The focused scenario matrix and complete T5 guard selftest pass on the final
source bytes. T6 was not run by explicit operator instruction. Certification
remains `in_progress`.

## Test Evidence

### Filing posture

**Executed:** NO
**Phase:** bug
**Command:** not run by explicit filing-only instruction
**Exit Code:** not applicable
**Claim Source:** not-run

The implementation owner must first capture the owner-label fixture failing
against unchanged production code.

### Planner readiness repair

No production or selftest source was modified or executed. These checks inspect
the current planning artifacts and the two declared implementation files.

#### Scenario obligation matrix

**Executed:** YES
**Phase:** bootstrap
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/scenario-obligation-lint.sh bugs/BUG-048-test-plan-owner-label-path`
**Exit Code:** 0
**Claim Source:** executed
**Output:** `[scenario-obligation-lint] OK — 4 scenario(s) with a coherent derived obligation matrix`

#### Test mechanism

**Executed:** YES
**Phase:** bootstrap
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/test-mechanism-lint.sh bugs/BUG-048-test-plan-owner-label-path`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
[test-mechanism-lint] OK — 4 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
```

#### Implementation reality

**Executed:** YES
**Phase:** bootstrap
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 150 /opt/homebrew/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-048-test-plan-owner-label-path --verbose`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `361d0a45a81eaddc2c5b1a35c08e531f947d68f88363b101390a2ffe06c2037a`
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

#### Artifact structure

**Executed:** YES
**Phase:** bootstrap
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 150 /opt/homebrew/bin/bash bubbles/scripts/artifact-lint.sh bugs/BUG-048-test-plan-owner-label-path 'SCN-B048-[0-9]{3}'`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`
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

#### Packet JSON

**Executed:** YES
**Phase:** bootstrap
**Command:**

```zsh
feature='bugs/BUG-048-test-plan-owner-label-path'
failures=0
for file in "$feature"/*.json; do
	printf 'JSON_VALIDATE_BEGIN file=%s\n' "$file"
	/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 30 /usr/bin/jq empty "$file"
	exit_code=$?
	printf 'JSON_VALIDATE_END file=%s exit=%s\n' "$file" "$exit_code"
	(( exit_code == 0 )) || failures=$((failures + 1))
done
printf 'JSON_VALIDATE_FAILURES=%s\n' "$failures"
(( failures == 0 ))
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
JSON_VALIDATE_BEGIN file=bugs/BUG-048-test-plan-owner-label-path/scenario-manifest.json
JSON_VALIDATE_END file=bugs/BUG-048-test-plan-owner-label-path/scenario-manifest.json exit=0
JSON_VALIDATE_BEGIN file=bugs/BUG-048-test-plan-owner-label-path/state.json
JSON_VALIDATE_END file=bugs/BUG-048-test-plan-owner-label-path/state.json exit=0
JSON_VALIDATE_BEGIN file=bugs/BUG-048-test-plan-owner-label-path/test-plan.json
JSON_VALIDATE_END file=bugs/BUG-048-test-plan-owner-label-path/test-plan.json exit=0
JSON_VALIDATE_FAILURES=0
```

## Implementation Evidence

### Pre-Production RED Evidence

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /usr/bin/env BUBBLES_STATE_TRANSITION_GUARD_BUG048_ONLY=1 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Result:** EXPECTED RED

```text
# BUG-048 Scope 01 owner-label RED
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /usr/bin/env BUBBLES_STATE_TRANSITION_GUARD_BUG048_ONLY=1 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 1
lines: 46
sha256: 00a4bd331bfffbcf5368c0f61b124fbdfb8e6132dacbf23577cd334274dfb3be
Running BUG-048 Finding Accounting owner-label path selftest...
FAIL: BUG-048 SCN-B048-001: Finding Accounting owner labels must not block Check 8
PASS: BUG-048 SCN-B048-001: Check 8 still validates the real Test Plan file
FAIL: BUG-048 SCN-B048-001: bubbles.test owner labels are never interpreted as paths
🔴 BLOCK: Test Plan references non-existent or non-resolvable file: bubbles.test
🔴 BLOCK: Test Plan references non-existent or non-resolvable file: bubbles.test
🔴 BLOCK: Test Plan references non-existent or non-resolvable file: bubbles.test
🔴 BLOCK: Test Plan references non-existent or non-resolvable file: bubbles.test
🔴 BLOCK: Test Plan references non-existent or non-resolvable file: bubbles.test
state-transition-guard BUG-048 selftest failed with 2 issue(s).
```

### Focused GREEN Evidence

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /usr/bin/env BUBBLES_STATE_TRANSITION_GUARD_BUG048_ONLY=1 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
# BUG-048 Scope 01 focused scenario matrix retry
exit: 0
lines: 17
sha256: f2c3a226bc28de5f3b666bfb325e25bb434226c3ef552fcaf4a08ebe1a83baaa
Running BUG-048 Finding Accounting owner-label path selftest...
PASS: BUG-048 SCN-B048-001: Finding Accounting owner labels do not block Check 8
PASS: BUG-048 SCN-B048-001: Check 8 still validates the real Test Plan file
PASS: BUG-048 SCN-B048-001: bubbles.test owner labels are never interpreted as paths
Running BUG-048 basename-only smoke.test selftest...
PASS: BUG-048 SCN-B048-002: a unique basename-only smoke.test remains valid
PASS: BUG-048 SCN-B048-002: Check 8 resolves smoke.test through existing basename logic
PASS: BUG-048 SCN-B048-002: the resolved smoke.test is not reported missing
Running BUG-048 missing.test adversarial selftest...
PASS: BUG-048 SCN-B048-003: missing.test in a real path column remains blocking
PASS: BUG-048 SCN-B048-003: Check 8 retains existing missing-basename enforcement
Running BUG-048 unrelated-table suffix adversarial selftest...
PASS: BUG-048 SCN-B048-004: a supported suffix in another table remains inert
PASS: BUG-048 SCN-B048-004: Check 8 still validates the real Test Plan file
PASS: BUG-048 SCN-B048-004: unrelated-table metadata never enters Check 8 path handling
state-transition-guard BUG-048 selftest passed.
```

### Complete Guard Regression Evidence

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 2040 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
# BUG-048 Scope 01 complete transition guard selftest
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 2040 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 507
sha256: 6c6f71d9c8b2260c66ef5a1f148e8c3a2f564407d6c8506ce5632a2cfc41f049
--- last 20 ---
PASS: BUG-011 control: an empty array is NOT reported as a wrong-element-type failure
PASS: BUG-011 adversarial: a quoted string scope ID is NOT reported as a wrong element type
PASS: BUG-011 adversarial: a populated string array is NOT reported as EMPTY
PASS: BUG-011 adversarial: one quoted scope ID against one Done scope artifact passes Check 5
Running Check 7A completedPhaseClaims timestamp selftest (BUG-013)...
PASS: BUG-013: completedPhaseClaims on an exact 600s grid fails the transition guard
PASS: BUG-013: uniformly spaced claimedAt values are named a FABRICATION INDICATOR
PASS: BUG-013: completedPhaseClaims whose claimedAt runs backwards fails the transition guard
PASS: BUG-013: a claim recorded before the claim ahead of it is reported as backwards ordering
PASS: BUG-013 adversarial: irregular forward-moving claimedAt values are reported plausible
PASS: BUG-013 adversarial: irregular spacing is NOT reported as a uniform interval
PASS: BUG-013 adversarial: forward-moving claims are NOT reported as backwards
PASS: BUG-013: an absent completedPhaseClaims abstains instead of adjudicating
PASS: BUG-013: an absent completedPhaseClaims yields no uniform-interval finding
PASS: BUG-013: an absent completedPhaseClaims yields no backwards-ordering finding
PASS: BUG-013: claimedAtUnreconciled with a sub-threshold reason still fails the transition guard
PASS: BUG-013: a claim declared unreconciled on a short reason stays IN the analysed set (count is still 10)
PASS: BUG-013: a sub-threshold reason does not register as a declared unreconciled claim
----------------------------------------
state-transition-guard selftest passed.
```

### Implementation Validation Receipts

**Phase:** implement
**Claim Source:** executed

Every row below has a current-session entry in
`.specify/runtime/tool-calls.jsonl` under binding revision 3.

| Check | Exit | Evidence identity |
| --- | ---: | --- |
| Complete transition-guard selftest | 0 | capture `6c6f71d9c8b2260c66ef5a1f148e8c3a2f564407d6c8506ce5632a2cfc41f049` |
| Changed shell syntax | 0 | empty-output SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Changed shell ShellCheck | 0 | empty-output SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| macOS portability enforcement | 0 | capture `b33d27363072b9c3b2f9cc24d2f2839a1204eb6a2dc30a9376893df8359856ed` |
| Scenario obligation manifest | 0 | capture `3979d4214fdb7145fa4cad82986c6a605516b95479ac3ed7f6308d0a62022a0b` |
| Test mechanism manifest | 0 | capture `36ffdf83fc233d8197e21b38176847355aac161f635cd8a56fba0c9fa68295f6` |
| Implementation reality scan | 0 | capture `361d0a45a81eaddc2c5b1a35c08e531f947d68f88363b101390a2ffe06c2037a` |
| Release-manifest generation | 0 | capture `4815d540e941642607988ec417f5b86c003e9bbfb8f02ab8bdcbdc3caf61449a` |
| Release-manifest freshness | 0 | capture `229c480c967b4984a879ab6b9c6442cf009bffecec8f15483ed4fec3ab097a73` |
| Release-manifest selftest | 0 | capture `f475d294f78256f27f11797df1f03ad755db104de9f55dd84ebf2a5928780210` |
| Strict work-boundary classifications | 0 | production, selftest, manifest, and packet paths each resolved `in-boundary` |

Final source identities are `f655dd0f3ce7c3c0db5d8403b1597debf5c6d59a7aa1ba95e6dfd9f11e0b908b`
for the guard and `ec60141255d2838dda2ce1976e256dd2a57f4d0610d123c0966a65eb1caddb1a`
for the selftest.

## Independent Test Verification T1-T5

**Executed:** YES (in current session)
**Phase:** test
**Repository Binding:** scenario node `complete-bubbles-bug048`, decision
`rb:vscode-495a6380e8e00ef101b07d78b21f9341:4:node:complete-bubbles-bug048`,
control revision `4`
**Selected Test Plan Rows:** T1, T2, T3, T4, T5
**Unexecuted Test Plan Row:** T6, by explicit operator instruction
**Claim Source:** executed

### Selected Test Verdict

| Test Plan Rows | Type | Result | Failed | Skipped |
| --- | --- | --- | ---: | ---: |
| T1-T4 | functional | 4 scenario contracts passed | 0 | 0 |
| T5 | regression | complete 507-line guard selftest passed | 0 | 0 |
| T6 | Regression E2E | not run by explicit operator instruction | not measured | not measured |

The selected independent test phase passed T1-T5. The packet remains
`in_progress` because T6 and validate-owned certification are unresolved.

### T1-T4 Focused Scenario Matrix

**Environment:** `BUBBLES_STATE_TRANSITION_GUARD_BUG048_ONLY=1`
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `f2c3a226bc28de5f3b666bfb325e25bb434226c3ef552fcaf4a08ebe1a83baaa`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 293
**Output:**

```text
Running BUG-048 Finding Accounting owner-label path selftest...
PASS: BUG-048 SCN-B048-001: Finding Accounting owner labels do not block Check 8
PASS: BUG-048 SCN-B048-001: Check 8 still validates the real Test Plan file
PASS: BUG-048 SCN-B048-001: bubbles.test owner labels are never interpreted as paths
Running BUG-048 basename-only smoke.test selftest...
PASS: BUG-048 SCN-B048-002: a unique basename-only smoke.test remains valid
PASS: BUG-048 SCN-B048-002: Check 8 resolves smoke.test through existing basename logic
PASS: BUG-048 SCN-B048-002: the resolved smoke.test is not reported missing
Running BUG-048 missing.test adversarial selftest...
PASS: BUG-048 SCN-B048-003: missing.test in a real path column remains blocking
PASS: BUG-048 SCN-B048-003: Check 8 retains existing missing-basename enforcement
Running BUG-048 unrelated-table suffix adversarial selftest...
PASS: BUG-048 SCN-B048-004: a supported suffix in another table remains inert
PASS: BUG-048 SCN-B048-004: Check 8 still validates the real Test Plan file
PASS: BUG-048 SCN-B048-004: unrelated-table metadata never enters Check 8 path handling
----------------------------------------
state-transition-guard BUG-048 selftest passed.
```

### T5 Complete Guard Regression

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 2040 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Duration:** 820567 ms
**Claim Source:** executed
**Evidence Capture SHA-256:** `6c6f71d9c8b2260c66ef5a1f148e8c3a2f564407d6c8506ce5632a2cfc41f049`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 299
**Output Window:** first and last 20 lines of 507. The capture hash covers every line.

```text
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- omitted 467 line(s); sha256 above covers the full output ---
PASS: BUG-011 control: an empty array is NOT reported as a wrong-element-type failure
PASS: BUG-011 adversarial: a quoted string scope ID is NOT reported as a wrong element type
PASS: BUG-011 adversarial: a populated string array is NOT reported as EMPTY
PASS: BUG-011 adversarial: one quoted scope ID against one Done scope artifact passes Check 5
Running Check 7A completedPhaseClaims timestamp selftest (BUG-013)...
PASS: BUG-013: completedPhaseClaims on an exact 600s grid fails the transition guard
PASS: BUG-013: uniformly spaced claimedAt values are named a FABRICATION INDICATOR
PASS: BUG-013: completedPhaseClaims whose claimedAt runs backwards fails the transition guard
PASS: BUG-013: a claim recorded before the claim ahead of it is reported as backwards ordering
PASS: BUG-013 adversarial: irregular forward-moving claimedAt values are reported plausible
PASS: BUG-013 adversarial: irregular spacing is NOT reported as a uniform interval
PASS: BUG-013 adversarial: forward-moving claims are NOT reported as backwards
PASS: BUG-013: an absent completedPhaseClaims abstains instead of adjudicating
PASS: BUG-013: an absent completedPhaseClaims yields no uniform-interval finding
PASS: BUG-013: an absent completedPhaseClaims yields no backwards-ordering finding
PASS: BUG-013: claimedAtUnreconciled with a sub-threshold reason still fails the transition guard
PASS: BUG-013: a claim declared unreconciled on a short reason stays IN the analysed set (count is still 10)
PASS: BUG-013: a sub-threshold reason does not register as a declared unreconciled claim
----------------------------------------
state-transition-guard selftest passed.
```

### Source Identity Before And After

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 30 /usr/bin/shasum -a 256 bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0 for both executions
**Claim Source:** executed
**Evidence Capture SHA-256 Before:** `dc06f69fe48c2c4b0e2ccecd1546f4fd83466e8d09f061ae945a4ca00ad62fee`
**Evidence Capture SHA-256 After:** `dc06f69fe48c2c4b0e2ccecd1546f4fd83466e8d09f061ae945a4ca00ad62fee`
**Tool Log Rows:** 292 and 300
**Output:**

```text
f655dd0f3ce7c3c0db5d8403b1597debf5c6d59a7aa1ba95e6dfd9f11e0b908b  bubbles/scripts/state-transition-guard.sh
ec60141255d2838dda2ce1976e256dd2a57f4d0610d123c0966a65eb1caddb1a  bubbles/scripts/state-transition-guard-selftest.sh
```

The source identities match before and after T1-T5. No production or test code
was edited by the independent test phase.

### Scenario And Regression Integrity

**Claim Source:** executed

```text
scenario-test-resolve.sh: exit 0
[scenario-test-resolve] OK — 4 reference(s) resolved via literal-scan

scenario-obligation-lint.sh: exit 0
[scenario-obligation-lint] OK — 4 scenario(s) with a coherent derived obligation matrix

test-mechanism-lint.sh: exit 0
[test-mechanism-lint] OK — 4 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)

regression-quality-guard.sh --bugfix --verbose: exit 0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1

exact skip-marker scan: grep exit 1
PASS: zero skip, focus-only, todo, or pending markers matched
```

The self-validating-test audit traced all four cases through the production
transition guard. Each case asserts a guard-produced exit status or log signal.
Replacing the guard with input passthrough would fail the paired positive and
negative expectations. No live-system category applies to these pure
validation scenarios, and no request interception or internal service mock is
used.

### Test Finding Accounting

- `F-B048-T6-NOT-RUN-BY-INSTRUCTION` remains unresolved. Owner:
  `bubbles.test`. The operator reserved one combined full framework T6 after
  BUG-049 and BUG-050.
- `F-B048-VALIDATE-CERTIFICATION-PENDING` remains unresolved. Owner:
  `bubbles.validate`. Certification remains `in_progress` until T6 evidence is
  available and validate-owned checks run.
- No other finding was raised by the independent T1-T5 execution or integrity
  checks.

## Code Diff Evidence

Check 8 now enters only exact level-two or level-three Test Plan sections. It
derives recognized path columns from each table header and stops at table or
section boundaries. Existing candidate parsing remains unchanged. The selftest
adds owner-label, basename, missing-path, and unrelated-table cases. The release
manifest records the final source hashes. Certification remains untouched.

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

Chaos validation is not part of filing and has not run.
