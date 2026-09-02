# Report: BUG-046 Traceability Linked-Test Path Containment

## Summary

**Claim Source:** interpreted

This intake records the existing High security finding as a separate shared guard containment defect.

The source finding is `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` in [`BUG-045 report.md`](../BUG-045-traceability-empty-evidence-refs/report.md#security-defensive-review---2026-09-02t150152z).

This intake creates only `bug.md`, `report.md`, and `state.json`. It changes no guard source, tests, other bug packet, index, generated file, Git state, or host state.

No scenario was validated during intake.

## Completion Statement

**Claim Source:** not-run

No completion is claimed. The packet remains `in_progress`.

The finding remains unresolved. The next required owner is `bubbles.analyst`, which must complete the specification artifacts before implementation.

## Test Evidence

**Executed:** NO
**Command:** Not run during intake.
**Exit Code:** Not available.
**Claim Source:** not-run

This invocation did not reproduce the defect or run a test. The prior execution remains evidence owned by the cited BUG-045 report and is not restated as current-session evidence.

## Inherited Finding

**Claim Source:** interpreted

- Finding: `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001`
- Severity: High
- Source phase: security
- Source tool-log row: 579
- Source full-output SHA-256: `130672ed8b1baf561ce11515fc79e1cbd666b40ea1477bffaa1680f8c8e9096c`
- Current disposition: `bug-filed`
- Current state: unresolved

The source report states that linked test path validation lacks canonical containment. It also records a false passing result against an external regular file.

## Code Diff Evidence

**Claim Source:** not-run

No implementation-bearing file changed. The allowed guard and selftest paths remain read-only during this intake.

## Finding Accounting

- `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` is unresolved in this packet.
- The finding is routed to `bubbles.analyst` for specification completion.
- No finding is marked addressed.
- No validation or certification claim exists.

## Work Boundary

- `bugs/BUG-046-traceability-linked-test-path-containment/**`
- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`
- `crossRepoPolicy: forbidden`

## Invocation Audit

No subagent was invoked during this intake.

## Planning Artifact Validation 2026-09-02

**Claim Source:** executed

This planning pass created `scopes.md`, `scenario-manifest.json`, `test-plan.json`, and `uservalidation.md`.
It changed no guard source, test source, other bug packet, shared index, Git state, or host state.
Every implementation DoD item remains unchecked.
No implementation behavior or regression test result is claimed.

Current-session planning output:

```text
REPOSITORY PACKET VALID actionable=true repository=bubbles root=/Users/pkirsanov/Projects/bubbles decision=rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:6 revision=6
Artifact lint PASSED.
[scenario-obligation-lint] OK — 9 scenario(s) with a coherent derived obligation matrix
[test-mechanism-lint] OK — 9 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
[scenario-test-resolve] OK — 9 reference(s) resolved via literal-scan
BUG046_FOCUSED_PLAN_CHECKS obligation=0 mechanism=0 linked=0
RESULT: PASSED (0 warnings)
[reference-existence-lint] OK — 3 markdown file(s) scanned, every relative link target resolves
[technical-prose] report-only, exit 0.
scope prose findings: 0
inherited intake report observations: 1
```

The report-only prose observation belongs to the unchanged intake section.
This planning pass does not rewrite prior report evidence.

The High parent finding `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` remains unresolved.
The packet stays `in_progress` and routes Scope 01 to `bubbles.implement`.

## Implementation Evidence 2026-09-02

### Exact Repository Binding

**Phase:** implement
**Claim Source:** executed
**Command:** `bash bubbles/scripts/repository-binding.sh validate-packet --session-id vscode-d6173f50fde08e4fc6fdf133dac19e92 --session-control-file <session-control-file> --packet-file <exact-revision-6-packet>`
**Exit Code:** 0

```text
REPOSITORY PACKET VALID actionable=true repository=bubbles root=/Users/pkirsanov/Projects/bubbles decision=rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:6 revision=6
```

The validated packet retained `controlRevision: 6`, `authority: explicit-repository-root`, `transition: confirmed`, and `actionable: true`.

### Focused RED And GREEN Evidence

**Phase:** implement
**Claim Source:** executed

The corrected pre-fix fixture run is tool-log row 589.
The final focused run is tool-log row 612.

```text
# BUG-046 Scope 01 focused scenario-first RED fixture-corrected
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=15s 2400 /opt/homebrew/bin/bash bubbles/scripts/traceability-guard-selftest.sh
exit: 1
lines: 730
sha256: 9000f8fded317c41ec8888c819f39ca6d00ab05de7124410a82655034ab1d634
FAIL: BUG-046 traversal present: an external regular file cannot satisfy the edge (expected exit 1, got 0)
FAIL: BUG-046 traversal present: the lexical rejection class is stable (missing: parent-traversal)
FAIL: BUG-046 traversal present: the unsafe raw reference is not disclosed
FAIL: BUG-046 absolute forms: every host-independent absolute class fails (expected exit 1, got 0)
FAIL: BUG-046 portability: system Bash rejects every absolute form (expected exit 1, got 0)
FAIL: BUG-046 mutation: common acceptance function seam was not found exactly once
[selftest traceability-guard] FAIL: 17 assertion(s)

# BUG-046 Scope 01 final compatibility-boundary GREEN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=15s 2400 /opt/homebrew/bin/bash bubbles/scripts/traceability-guard-selftest.sh
exit: 0
lines: 196
sha256: dcd1a0a99a870872cc25f344957b97a1eeede57bc00605dbf49d4827733067e3
PASS: BUG-046 external symlinks: present absent and prefix-sibling targets share one rejection class
PASS: BUG-046 internal symlinks: a cycle fails at the bounded symlink walk
PASS: BUG-046 controls: captured diagnostics contain no active control byte
PASS: BUG-046 projection: current-scope mode retains its applicable scenario universe
PASS: BUG-046 mutation: disabling containment restores the present traversal false pass
PASS: BUG-046 mutation: disabling containment restores the external-symlink false pass
PASS: BUG-046 mutation: the missing target still fails because the regular-file check remains active
[selftest traceability-guard] PASS
```

### Final Source Validation

**Phase:** implement
**Claim Source:** executed

Tool-log rows 613 through 617 bind these checks to the same final source and selftest bytes as row 612.

```text
row=613 command=/opt/homebrew/bin/bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh exit=0 stdoutBytes=0 stderrBytes=0
row=614 command=/bin/bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh exit=0 stdoutBytes=0 stderrBytes=0
row=615 command=/opt/homebrew/bin/shellcheck -S warning -x bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh exit=0 stdoutBytes=0 stderrBytes=0
row=616 label=BUG-046 final-epoch changed-shell portability exit=0 lines=19
ok class-1 raw-timeout: none
ok class-2 in-place-sed: none
ok class-5 readlink-f-absolutize: none
ok class-16 awk-3arg-match: none
PASS: the scanned surface is WSL+macOS portable.
row=617 label=BUG-046 final-epoch bugfix regression quality exit=0 lines=15
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
```

### Implementation Finding Accounting

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The implementation closes the vulnerable code path, while independent test ownership still controls global finding closure.

- Finding: `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001`
- Severity: High
- Implementation state: `implemented-awaiting-independent-test`
- Global state: unresolved
- Implementation files: `bubbles/scripts/traceability-guard.sh` and `bubbles/scripts/traceability-guard-selftest.sh`
- Pre-fix receipt: tool-log row 589, exit 1
- Post-fix receipt: tool-log row 612, exit 0
- Mutation receipt: included in row 612
- Certification state: unchanged
- Top-level status: unchanged at `in_progress`
- Required independent owner: `bubbles.test`

## Interrupted Implementation Finalization 2026-09-02

### Receipt Accounting

**Phase:** implement
**Claim Source:** executed

Rows 588 through 620 were inspected against their recorded commands, exits, hashes, retained output, and input closures.

| Row | Exit | Classification |
| --- | ---: | --- |
| 588 | 1 | Initial RED fixture run. Its fixture was corrected before the accepted reproduction, so this row is retained as a superseded attempt and is not the RED proof. |
| 589 | 1 | Corrected expected RED. The output reproduced traversal, absolute-path, disclosure, and missing shared-validator failures. This is the accepted pre-fix proof. |
| 590 | 1 | Real intermediate implementation failure. Repository fixtures were rejected as outside the repository root, and the control-byte assertion also failed. |
| 591 | 1 | Real intermediate implementation failure. System Bash exposed an unbound empty-array expansion, and control and whitespace assertions still failed. |
| 592 | 1 | Real intermediate implementation failure. The remaining whitespace reference produced an invalid projection record instead of the `empty-reference` class. |
| 593 | 1 | Real intermediate implementation failure. The same final whitespace projection assertion remained red. |
| 594 | 0 | Focused GREEN after the empty projection repair. |
| 595 | 0 | Focused GREEN after diagnostic hardening. |
| 596-597 | 0 | Both Bash syntax commands passed. The evidence wrapper emitted its own zero-line arithmetic diagnostic, so clean direct syntax receipts replaced these captures. |
| 598 | 1 | Real ShellCheck failure, `SC2034`, for an unused resolved-path assignment. |
| 599 | 0 | Warning-level ShellCheck passed after the local repair. |
| 600-601 | 0 | Direct Homebrew Bash and system Bash syntax checks passed with empty stdout and stderr. |
| 602-605 | 0 | Scenario obligation, test mechanism, scenario resolution, and regression-quality checks passed. |
| 606 | 1 | The macOS portability guard rejected the new selftest epoch. The follow-up changed the selftest input hash and retained the source hash. |
| 607 | 0 | The macOS portability guard passed after the local selftest repair. |
| 608 | 0 | The focused portable selftest passed. |
| 609-611 | 0 | Artifact lint, traceability, and reference-existence baselines passed. |
| 612 | 0 | Final compatibility-boundary selftest passed. Its source and selftest hashes define the final implementation epoch. |
| 613-617 | 0 | Final-epoch Bash syntax, ShellCheck, portability, and regression-quality checks passed. |
| 618 | 1 | Pre-execution lock refusal, not a suite failure. The exact three-line refusal reconstructs both recorded stdout hash `3313fa551cb7571bad7bdc5bd7184842933511580b5f173e5b2ef087af51a93c` and recorded byte count `783`. |
| 619-620 | 0 | Provisional artifact lint and traceability checks passed before final bookkeeping. |

Row 618 captured this complete command output:

```text
ERROR: another framework-validate run is already in progress on this machine.
       Concurrent runs corrupt each other's shared scratch fixtures and produce
       false failures. Wait for the other run to finish, then re-run.
```

The framework event ledger records an earlier run starting at `2026-09-02T16:39:46Z`.
It records row 618 starting and failing at `2026-09-02T16:50:50Z` with zero execution duration.
The earlier run succeeded at `2026-09-02T16:51:05Z`.
The full framework suite did not execute for row 618.
No full framework validation was rerun during this finalization.

### Current-Byte Verification

**Phase:** implement
**Claim Source:** executed

- Current `bubbles/scripts/traceability-guard.sh` SHA-256: `12e42109f902d153f04ff25a3f69200593dd30dcebe8704cd78fc16e16acc1e8`.
- Current `bubbles/scripts/traceability-guard-selftest.sh` SHA-256: `905ba0d469c752f8547454b22482d5f71c1fee22bd5b9d29b8e28e03f9be0c40`.
- Both hashes match row 612 and rows 613 through 617.
- Row 621 reran the focused selftest against those hashes and exited 0. Its 196-line command-output SHA-256 is `dcd1a0a99a870872cc25f344957b97a1eeede57bc00605dbf49d4827733067e3`, equal to row 612's command-output hash.
- Row 622 scanned both implementation files for skip and bypass-shaped controls and exited 0 with `BUG046_NO_BYPASS_OK`.

### Implementation Handoff

**Phase:** implement
**Claim Source:** interpreted

The implementation phase claim is complete with outcome `route_required`.
The finding `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` remains unresolved with status `implemented-awaiting-independent-test`.
No independent-test or validation DoD item is closed by this implementation claim.
Top-level status and certification remain `in_progress`.
The next required owner is `bubbles.test` for Scope `01-atomic-linked-test-path-validation`.

## Independent Test Verification - 2026-09-02

### Repository Binding And Final Epoch

**Phase:** test
**Claim Source:** executed
**Command:** Exact revision-6 packet validation and the checksum check at tool-log row 636.
**Exit Code:** 0

```text
REPOSITORY PACKET VALID actionable=true repository=bubbles root=/Users/pkirsanov/Projects/bubbles decision=rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:6 revision=6
bubbles/scripts/traceability-guard.sh: OK
bubbles/scripts/traceability-guard-selftest.sh: OK
tool-log row 636 exit=0
guard sha256=12e42109f902d153f04ff25a3f69200593dd30dcebe8704cd78fc16e16acc1e8
selftest sha256=905ba0d469c752f8547454b22482d5f71c1fee22bd5b9d29b8e28e03f9be0c40
binding authority=explicit-repository-root
binding transition=confirmed
binding controlRevision=6
binding actionable=true
```

The current guard and selftest bytes match the implementation final epoch exactly.

### Independent Functional And Mutation Evidence

**Phase:** test
**Claim Source:** executed
**Command:** The stock and Homebrew Bash focused selftests shown below.
**Exit Code:** 0 for stock Bash, 0 for Homebrew Bash

```text
/bin/bash bubbles/scripts/traceability-guard-selftest.sh
/opt/homebrew/bin/bash bubbles/scripts/traceability-guard-selftest.sh
```

Tool-log rows 640 and 641 each carry all eleven `TP-B046-*` tags.
Both runs produced 196 lines with complete-output SHA-256 `dcd1a0a99a870872cc25f344957b97a1eeede57bc00605dbf49d4827733067e3`.

```text
PASS: BUG-046 valid roots: repository-relative and feature-relative references both remain accepted
PASS: BUG-046 traversal present: an external regular file cannot satisfy the edge
PASS: BUG-046 traversal absent: the rejection does not depend on existence
PASS: BUG-046 absolute forms: POSIX drive-qualified and UNC records share the lexical class
PASS: BUG-046 external symlinks: present absent and prefix-sibling targets share one rejection class
PASS: BUG-046 internal symlinks: a contained regular-file target remains accepted
PASS: BUG-046 internal symlinks: the contained directory target is classified as non-regular
PASS: BUG-046 internal symlinks: a cycle fails at the bounded symlink walk
PASS: BUG-046 controls: captured diagnostics contain no active control byte
PASS: BUG-046 non-regular targets: the missing target retains its distinct class
PASS: BUG-046 inert text: b046-command-sentinel was not created
PASS: BUG-046 projection: legacy envelope remains accepted
PASS: BUG-046 projection: current-scope mode retains its applicable scenario universe
PASS: BUG-046 mutation: disabling containment restores the present traversal false pass
PASS: BUG-046 mutation: disabling containment restores the external-symlink false pass
PASS: BUG-046 mutation: the missing target still fails because the regular-file check remains active
[selftest traceability-guard] PASS
```

| Test Plan Row | Scenario Coverage | Stock Bash | Homebrew Bash | Evidence |
| --- | --- | --- | --- | --- |
| `TP-B046-001` | Valid repository and feature candidates | Passed | Passed | Rows 640-641 |
| `TP-B046-002` | Present and absent traversal | Passed | Passed | Rows 640-641 |
| `TP-B046-003` | POSIX, drive, and UNC absolute forms | Passed | Passed | Rows 640-641 |
| `TP-B046-004` | External symlink escape and disclosure | Passed | Passed | Rows 640-641 |
| `TP-B046-005` | Internal file, directory, and cycle policy | Passed | Passed | Rows 640-641 |
| `TP-B046-006` | Empty, whitespace, and control text | Passed | Passed | Rows 640-641 |
| `TP-B046-007` | Missing, directory, FIFO, and socket targets | Passed | Passed | Rows 640-641 |
| `TP-B046-008` | Inert instruction-like path text | Passed | Passed | Rows 640-641 |
| `TP-B046-009` | Candidate roots, forms, fragments, and scope modes | Passed | Passed | Rows 640-641 |
| `TP-B046-010` | Diagnostic non-disclosure | Passed | Passed | Rows 640-641 |
| `TP-B046-011` | Containment-disabled mutation | Passed | Passed | Rows 640-641 |

No test was skipped. The selected harness contains no skip, focus, mock, or request-interception pattern.

### Independent Contract And Shell Quality Evidence

**Phase:** test
**Claim Source:** executed
**Command:** The focused BUG-046 checks listed below.
**Exit Code:** 0 for every accepted check

```text
row=637 scenario-test-resolve exit=0 references=9
row=638 scenario-obligation-lint exit=0 scenarios=9
row=639 test-mechanism-lint exit=0 mechanisms=9
row=642 Homebrew-Bash syntax exit=0 stdoutBytes=0 stderrBytes=0
row=643 stock-Bash syntax exit=0 stdoutBytes=0 stderrBytes=0
row=644 ShellCheck warning-level exit=0 stdoutBytes=0 stderrBytes=0
row=645 macOS portability exit=0 classes=16
row=646 regression-quality --bugfix exit=0 violations=0 warnings=0 adversarialFiles=1
row=647 artifact-lint exit=0 result=PASSED
row=648 traceability-guard exit=0 scenarios=9 mappings=9 warnings=0
row=649 reference-existence-lint exit=0 markdownFiles=6
rows=650-654 work-boundary-resolve exit=0 disposition=in-boundary
BUG046_PRE_EDIT_DIFF_CHECK_EXIT=0
BUG046_SKIP_MARKER_SCAN=PASS matches=0
BUG046_MOCK_REPLACEMENT_SCAN=PASS matches=0
BUG046_PRE_EDIT_BOUNDARY_BATCH_EXIT=0
```

The functional tests observe production-CLI exits, diagnostics, accepted-edge output, and named sentinel state.
The mutation changes only a temporary copy of the production guard.
It restores traversal and external-symlink false acceptance while preserving missing-file rejection.
The tests therefore fail when containment is removed and do not validate their own fixtures.

### Harness Issue Accounting

**Phase:** test
**Claim Source:** executed

| Issue | Actual Result | Disposition |
| --- | --- | --- |
| First stock-Bash PATH placed `/usr/bin` before Homebrew | Exit 69, 175 lines, output SHA-256 `01ff8f311a849e4107773266736b299794330f75cfe0db86c7a26511678b16af`; Apple Python refused because the local Xcode license is not accepted | Harness-invalid attempt. PATH was corrected to keep `/bin/bash` first and select Homebrew Python. Row 640 is the accepted rerun. |
| Interactive shell initialization emitted an Anaconda `anaconda-cloud-auth` import warning on two command batches | The explicitly addressed commands still executed and returned their recorded exit codes | Non-blocking terminal-startup noise. It did not enter either captured selftest output. |

The first failed stock-Bash attempt did not produce a structured tool-log row.
Its bounded capture is retained as harness evidence only and supports no behavior claim.
No source or test assertion repair was required.

### Independent Finding Disposition

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** The two current-byte Bash runs, selective containment mutation, and focused guards independently verify the child repair. The broader framework regression remains a separate build-quality obligation for the next phase.

- `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` is `verified-ready-for-parent-consumption` inside BUG-046.
- BUG-045's parent ledger was not edited.
- Scope, certification, and top-level status remain `in_progress`.
- `DOD-B046-BQ1` remains unchecked because this invocation was explicitly prohibited from running `framework-validate` or `release-check`.
- The next required owner is `bubbles.regression`.

### Final Bookkeeping And Boundary Evidence

**Phase:** test
**Claim Source:** executed
**Command:** The post-bookkeeping checks listed below.
**Exit Code:** 0 for every listed command

```text
row=655 artifact-lint exit=0 result=PASSED
row=656 traceability-guard exit=0 scenarios=9 mappings=9 warnings=0
row=657 reference-existence-lint exit=0 markdownFiles=6
row=659 execution-substate-guard exit=0
row=660 technical-prose-lint exit=0 new-section-findings=0 inherited-findings=3
row=661 source-epoch checksum exit=0 guard=OK selftest=OK
row=662 state-invariant assertion exit=0 result=true
rows=663-667 work-boundary-resolve exit=0 disposition=in-boundary
row=668 git-diff-check exit=0 stdoutBytes=0 stderrBytes=0
BUG046_FINAL_GIT_STATUS_EXIT=0
BUG046_FINAL_DIFF_NAMES_EXIT=0
BUG046_FINAL_UNTRACKED_WHITESPACE=PASS matches=0
BUG046_FINAL_ARTIFACT_HASHES_EXIT=0
BUG046_FINAL_BOUNDARY_BATCH_EXIT=0
```

The three test-owned edits are `report.md`, `scopes.md`, and `state.json` in BUG-046.
The implementation guard and selftest stayed at their recorded final-epoch hashes.
No excluded source, test, bug packet, generated file, Git history, remote, or deploy surface was changed.
