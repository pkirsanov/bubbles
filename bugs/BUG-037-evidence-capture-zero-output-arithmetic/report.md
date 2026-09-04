# BUG-037 Report

## Summary

The implementation phase reproduced the zero-output arithmetic defect, added focused adversarial coverage, and replaced the two-producer count with one canonical line counter. The test phase independently validated all four scenarios. Bash syntax passed, all 20 focused selftest checks passed, 11 explicit silent-child and verify assertions passed, and both regression-quality guard modes reported zero violations. Framework validation, release readiness, generators, manifests, and certification were explicitly excluded from this test packet and have `Claim Source: not-run`.

## Completion Statement

The bug remains `in_progress` for validation ownership. Test evidence is independently complete for the focused helper surface and is routed to `bubbles.validate`. No framework-wide, release, manifest, certification, staging, commit, or push claim is made.

## Outcome Contract Alignment

**Claim Source:** planned

The declared Success Signal is not yet globally demonstrated. Focused evidence below addresses silent success, silent failure, empty-output verification, and non-empty regression behavior. The broader framework, release-readiness, human-acceptance, and certification checks remain outstanding and must not be inferred from focused results.

## Code Diff Evidence

**Executed:** NO
**Command:** Not run for the final planning packet.
**Exit Code:** Not applicable.
**Phase Agent:** bubbles.validate
**Phase:** validate
**Claim Source:** not-run

No git-backed Code Diff Evidence is recorded for the validation phase. The validation owner must run an authorized diff inspection and record the real command, exit status, and reviewed implementation and focused-test paths before checking the corresponding Definition of Done item. This section is a required evidence location, not execution evidence.

## Test Evidence

### Source inspection

**Phase:** bug
**Claim Source:** interpreted
**Command:** Not run. The source was read through the editor.
**Exit Code:** Not applicable.
**Interpretation:** The empty-file count expression has two output producers. `grep -c` can print `0` before its nonzero no-match status invokes the fallback, which appends another `0`.

Controlling expression:

```text
total="$(grep -c '' <"$tmp" 2>/dev/null || printf '0')"
```

### Reported diagnostic

**Phase:** bug
**Claim Source:** not-run

The operator reported an arithmetic diagnostic during a zero-line capture. The exact output was not preserved in a durable artifact available to this invocation. This report does not restate expected text as executed evidence.

### Red stage

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 30 bash bubbles/scripts/evidence-capture.sh --label 'BUG-037 red successful zero-output' -- true; success_rc=$?; printf 'successful_capture_rc=%s\n' "$success_rc"; set +e; timeout 30 bash bubbles/scripts/evidence-capture.sh --label 'BUG-037 red failing zero-output' -- sh -c 'exit 7'; failure_rc=$?; set -e; printf 'failing_capture_rc=%s\n' "$failure_rc"`
**Exit Code:** 0 for the compound reproduction command. The two helper invocations returned 0 and 7 respectively.
**Output:**

````text
```
# BUG-037 red successful zero-output
$ true
exit: 0
lines: 0
0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
bubbles/scripts/evidence-capture.sh: line 201: [[: 0
0: arithmetic syntax error in expression (error token is "0")
--- first 20 ---
bubbles/scripts/evidence-capture.sh: line 213: 0
0: arithmetic syntax error in expression (error token is "0")
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -- true -->
successful_capture_rc=0
```
# BUG-037 red failing zero-output
$ sh -c exit 7
exit: 7
lines: 0
0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
bubbles/scripts/evidence-capture.sh: line 201: [[: 0
0: arithmetic syntax error in expression (error token is "0")
--- first 20 ---
bubbles/scripts/evidence-capture.sh: line 213: 0
0: arithmetic syntax error in expression (error token is "0")
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -- sh -c exit 7 -->
failing_capture_rc=7
```
````

**Result:** FAIL. Both zero-output classes produced the duplicated scalar as two lines and emitted arithmetic diagnostics, while preserving the child exit contracts.

### Green stage

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 1200 bash bubbles/scripts/evidence-capture-selftest.sh`
**Exit Code:** 0
**Output:**

```text
	ok   successful zero-output capture emits canonical metadata without diagnostics
	ok   failing zero-output capture emits canonical metadata and propagates exit 7
	ok   empty-output --verify match and mismatch preserve exits 0 and 3
	ok   records command, exit code, line count and a sha256
	ok   short output is emitted in full, not truncated
	ok   long output is trimmed and states how many lines were omitted
	ok   failing command still emits evidence and propagates exit 7
	ok   --verify passes on identical output and FAILS (3) when it changes
	ok   stderr is interleaved into the evidence, not discarded
	ok   bypass-shaped flag refused with exit 2
	ok   no command after -- is a usage error
	ok   block carries a re-runnable verify command
	ok   a failure line in the omitted region is lifted out, not swallowed
	ok   clean output emits no failure section
	ok   --diagnostic emits the full output and stamps the escalation
	ok   a normal capture carries no escalation stamp
	ok   --diagnostic remains bounded by a stated ceiling
	ok   TERM stops the child process group and emits preserved interrupted evidence
	ok   completed commands leave no background descendant behind
	ok   capture-file loss fails loud without emitting an empty evidence hash

evidence-capture-selftest: 20/20 checks passed
evidence-capture-selftest: OK
```

**Result:** PASS. The focused suite asserts exact empty hash and line metadata, absence of arithmetic diagnostics and stray count fragments, child status propagation, verify exits 0 and 3, and all pre-existing non-empty, bounded, failure-extraction, diagnostic-ceiling, signal, descendant-cleanup, and capture-loss controls.

### Exact post-fix zero-output metadata

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 30 bash bubbles/scripts/evidence-capture.sh --label 'BUG-037 final successful zero-output' -- true; success_rc=$?; printf 'successful_capture_rc=%s\n' "$success_rc"; set +e; timeout 30 bash bubbles/scripts/evidence-capture.sh --label 'BUG-037 final failing zero-output' -- sh -c 'exit 7'; failure_rc=$?; set -e; printf 'failing_capture_rc=%s\n' "$failure_rc"`
**Exit Code:** 0 for the compound fixture command. The helper invocations returned 0 and 7 respectively.
**Output:**

````text
```
# BUG-037 final successful zero-output
$ true
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -- true -->
successful_capture_rc=0
```
# BUG-037 final failing zero-output
$ sh -c exit 7
exit: 7
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -- sh -c exit 7 -->
failing_capture_rc=7
````

**Result:** PASS. Each block has one `lines: 0` field, the canonical empty-stream digest, no stray zero line, and no arithmetic diagnostic.

### Bash syntax

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 30 bash -n bubbles/scripts/evidence-capture.sh bubbles/scripts/evidence-capture-selftest.sh; syntax_rc=$?; printf 'bash_syntax_exit=%s\n' "$syntax_rc"`
**Exit Code:** 0
**Output:** `bash_syntax_exit=0`
**Result:** PASS.

### Aggregate validation

**Phase:** validate
**Claim Source:** not-run

The operator boundary for this test phase explicitly prohibited framework validation, release readiness, generators, and manifest work. Those commands were not run.

### Test-phase repository binding

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 30 bash bubbles/scripts/repository-binding.sh validate-packet --session-id vscode-ddcadf12da845e696b1170714b10e13b --session-control-file /run/user/1000/bubbles/repository-binding/vscode-ddcadf12da845e696b1170714b10e13b/repository-binding.json --packet-file /tmp/bug-037-repository-binding-packet.json`
**Exit Code:** 0
**Output:**

```text
REPOSITORY PACKET VALID actionable=true repository=bubbles root=/home/philipk/bubbles decision=rb:vscode-ddcadf12da845e696b1170714b10e13b:4 revision=4
```

**Result:** PASS. The exact actionable packet was validated against control revision 4 before repository-local reads.

### Test-phase scenario target resolution

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 120 bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-037-evidence-capture-zero-output-arithmetic --repo-root "$PWD"`
**Exit Code:** 0
**Output:**

```text
[scenario-test-resolve] OK — 4 reference(s) resolved via literal-scan
```

**Result:** PASS. All four scenario links resolve to the persistent focused selftest.

### Test-phase Bash syntax

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 30 bash -n bubbles/scripts/evidence-capture.sh bubbles/scripts/evidence-capture-selftest.sh; syntax_rc=$?; printf 'BUG037_BASH_SYNTAX_EXIT=%s\n' "$syntax_rc"`
**Exit Code:** 0
**Output:**

```text
BUG037_BASH_SYNTAX_EXIT=0
```

**Result:** PASS. Both shell files parse successfully.

### Test-phase complete focused selftest

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 1200 bash bubbles/scripts/evidence-capture-selftest.sh`
**Exit Code:** 0
**Output:**

```text
	ok   successful zero-output capture emits canonical metadata without diagnostics
	ok   failing zero-output capture emits canonical metadata and propagates exit 7
	ok   empty-output --verify match and mismatch preserve exits 0 and 3
	ok   records command, exit code, line count and a sha256
	ok   short output is emitted in full, not truncated
	ok   long output is trimmed and states how many lines were omitted
	ok   failing command still emits evidence and propagates exit 7
	ok   --verify passes on identical output and FAILS (3) when it changes
	ok   stderr is interleaved into the evidence, not discarded
	ok   bypass-shaped flag refused with exit 2
	ok   no command after -- is a usage error
	ok   block carries a re-runnable verify command
	ok   a failure line in the omitted region is lifted out, not swallowed
	ok   clean output emits no failure section
	ok   --diagnostic emits the full output and stamps the escalation
	ok   a normal capture carries no escalation stamp
	ok   --diagnostic remains bounded by a stated ceiling
	ok   TERM stops the child process group and emits preserved interrupted evidence
	ok   completed commands leave no background descendant behind
	ok   capture-file loss fails loud without emitting an empty evidence hash

evidence-capture-selftest: 20/20 checks passed
evidence-capture-selftest: OK
```

**Result:** PASS. SCN-B037-001 through SCN-B037-004 pass, including non-empty short output and bounded output above 40 lines.

### Test-phase explicit zero-output probes

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:**

```text
cd /home/philipk/bubbles && timeout 120 bash -c '
set +e
EMPTY_SHA256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
success_out="$(bash bubbles/scripts/evidence-capture.sh -- true 2>&1)"; success_rc=$?
failure_out="$(bash bubbles/scripts/evidence-capture.sh -- sh -c "exit 7" 2>&1)"; failure_rc=$?
match_out="$(bash bubbles/scripts/evidence-capture.sh --verify "$EMPTY_SHA256" -- true 2>&1)"; match_rc=$?
mismatch_out="$(bash bubbles/scripts/evidence-capture.sh --verify 0000000000000000000000000000000000000000000000000000000000000000 -- true 2>&1)"; mismatch_rc=$?
failures=0
check_eq() { if [[ "$1" == "$2" ]]; then printf "ASSERT PASS: %s\n" "$3"; else printf "ASSERT FAIL: %s (observed=%s expected=%s)\n" "$3" "$1" "$2"; failures=$((failures + 1)); fi; }
check_contains() { if [[ "$1" == *"$2"* ]]; then printf "ASSERT PASS: %s\n" "$3"; else printf "ASSERT FAIL: %s\n" "$3"; failures=$((failures + 1)); fi; }
check_absent() { if [[ "$1" != *"$2"* ]]; then printf "ASSERT PASS: %s\n" "$3"; else printf "ASSERT FAIL: %s\n" "$3"; failures=$((failures + 1)); fi; }
printf "%s\n" "--- successful silent child capture ---" "$success_out" "successful_helper_exit=$success_rc"
printf "%s\n" "--- failing silent child capture ---" "$failure_out" "failing_child_and_helper_exit=$failure_rc"
printf "%s\n" "--- empty-output verify match ---" "$match_out" "verify_match_exit=$match_rc"
printf "%s\n" "--- empty-output verify mismatch ---" "$mismatch_out" "verify_mismatch_exit=$mismatch_rc"
check_eq "$success_rc" 0 "successful silent child/helper exits exactly 0"
check_eq "$failure_rc" 7 "failing silent child/helper exits exactly 7"
check_eq "$match_rc" 0 "matching empty-output verify exits exactly 0"
check_eq "$mismatch_rc" 3 "mismatching empty-output verify exits exactly 3"
check_contains "$success_out" $'lines: 0\nsha256: ' "successful capture reports canonical zero-line metadata"
check_contains "$failure_out" $'lines: 0\nsha256: ' "failing capture reports canonical zero-line metadata"
check_contains "$success_out" "sha256: $EMPTY_SHA256" "successful capture reports canonical empty hash"
check_contains "$failure_out" "sha256: $EMPTY_SHA256" "failing capture reports canonical empty hash"
all_out="$success_out$failure_out$match_out$mismatch_out"
check_absent "$all_out" arithmetic "all four probes contain no arithmetic diagnostic"
check_eq "$match_out" "[evidence-capture] VERIFIED - output still hashes to $EMPTY_SHA256" "verify match reports exact canonical digest"
check_contains "$mismatch_out" "  observed: $EMPTY_SHA256" "verify mismatch reports canonical observed empty digest"
printf "BUG037_EXPLICIT_PROBE_ASSERTIONS=%s failures=%s\n" "$((11 - failures))/11" "$failures"
exit "$failures"
'
```
**Exit Code:** 0
**Output:**

````text
--- successful silent child capture ---
```
$ true
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -- true -->
successful_helper_exit=0
--- failing silent child capture ---
```
$ sh -c exit 7
exit: 7
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 -- sh -c exit 7 -->
failing_child_and_helper_exit=7
--- empty-output verify match ---
[evidence-capture] VERIFIED - output still hashes to e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
verify_match_exit=0
--- empty-output verify mismatch ---
[evidence-capture] MISMATCH
	recorded: 0000000000000000000000000000000000000000000000000000000000000000
	observed: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
	The command no longer produces the recorded output. Either the
	behaviour changed or the recorded evidence never came from this command.
verify_mismatch_exit=3
ASSERT PASS: successful silent child/helper exits exactly 0
ASSERT PASS: failing silent child/helper exits exactly 7
ASSERT PASS: matching empty-output verify exits exactly 0
ASSERT PASS: mismatching empty-output verify exits exactly 3
ASSERT PASS: successful capture reports canonical zero-line metadata
ASSERT PASS: failing capture reports canonical zero-line metadata
ASSERT PASS: successful capture reports canonical empty hash
ASSERT PASS: failing capture reports canonical empty hash
ASSERT PASS: all four probes contain no arithmetic diagnostic
ASSERT PASS: verify match reports exact canonical digest
ASSERT PASS: verify mismatch reports canonical observed empty digest
BUG037_EXPLICIT_PROBE_ASSERTIONS=11/11 failures=0
````

**Result:** PASS. The successful and failing silent children report one canonical zero count and the empty-stream hash. Helper exits are exactly 0 and 7. Verify exits are exactly 0 and 3. No arithmetic diagnostic appears.

An earlier inline assertion harness invocation exited 11 because its local assertion helper invoked `test` without forwarding arguments. The displayed helper captures in that attempt were correct, but its assertion result was invalid. The corrected harness above reran all four helper invocations and is the evidence of record.

### Test-phase regression-quality guards

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/regression-quality-guard.sh bubbles/scripts/evidence-capture-selftest.sh && timeout 180 bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/evidence-capture-selftest.sh`
**Exit Code:** 0
**Output:**

```text
============================================================
	BUBBLES REGRESSION QUALITY GUARD
	Repo: /home/philipk/bubbles
	Timestamp: 2026-09-02T03:42:09Z
	Bugfix mode: false
============================================================

ℹ️  Scanning bubbles/scripts/evidence-capture-selftest.sh

============================================================
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
============================================================
============================================================
	BUBBLES REGRESSION QUALITY GUARD
	Repo: /home/philipk/bubbles
	Timestamp: 2026-09-02T03:42:09Z
	Bugfix mode: true
============================================================

ℹ️  Scanning bubbles/scripts/evidence-capture-selftest.sh
✅ Adversarial signal detected in bubbles/scripts/evidence-capture-selftest.sh

============================================================
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
============================================================
```

**Result:** PASS. Standard and bugfix modes found zero violations and zero warnings. Bugfix mode detected an adversarial signal.

### Test-phase static scans

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && set +e; timeout 30 grep -nE 't\.Skip|\.skip\(|xit\(|xdescribe\(|\.only\(|test\.todo|it\.todo|pending\(' bubbles/scripts/evidence-capture-selftest.sh; skip_rc=$?; timeout 30 grep -nE 'page\.route|context\.route|msw|nock|intercept|jest\.fn|sinon\.stub|mock\(' bubbles/scripts/evidence-capture-selftest.sh; mock_rc=$?; timeout 30 grep -nF "total=\"\$(grep -c ''" bubbles/scripts/evidence-capture.sh; legacy_counter_rc=$?; timeout 30 grep -nF "total=\"\$(awk 'END { print NR + 0 }' \"\$tmp\")\"" bubbles/scripts/evidence-capture.sh; canonical_counter_rc=$?; set -e; printf 'SKIP_MARKER_SCAN_EXIT=%s expected=1\n' "$skip_rc"; printf 'FAKE_LIVE_PATTERN_SCAN_EXIT=%s expected=1\n' "$mock_rc"; printf 'LEGACY_TWO_PRODUCER_COUNTER_SCAN_EXIT=%s expected=1\n' "$legacy_counter_rc"; printf 'CANONICAL_COUNTER_SCAN_EXIT=%s expected=0\n' "$canonical_counter_rc"; [[ "$skip_rc" -eq 1 && "$mock_rc" -eq 1 && "$legacy_counter_rc" -eq 1 && "$canonical_counter_rc" -eq 0 ]]`
**Exit Code:** 0
**Output:**

```text
166:total="$(awk 'END { print NR + 0 }' "$tmp")"
SKIP_MARKER_SCAN_EXIT=1 expected=1
FAKE_LIVE_PATTERN_SCAN_EXIT=1 expected=1
LEGACY_TWO_PRODUCER_COUNTER_SCAN_EXIT=1 expected=1
CANONICAL_COUNTER_SCAN_EXIT=0 expected=0
```

**Result:** PASS. No skip or fake-live pattern is present. The legacy two-producer counter is absent, and the canonical single counter is present.

### Test-phase BUG-037 artifact lint

**Phase:** test
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 300 bash bubbles/scripts/cli.sh lint bugs/BUG-037-evidence-capture-zero-output-arithmetic`
**Exit Code:** 0
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

**Result:** PASS. The in-progress BUG-037 packet remains structurally valid after the test-owned updates.

### BUG-037 artifact lint

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `cd /home/philipk/bubbles && timeout 300 bash bubbles/scripts/cli.sh lint bugs/BUG-037-evidence-capture-zero-output-arithmetic`
**Exit Code:** 0
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

**Result:** PASS.
