# BUG-053 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Valid Empty Capture Formatting

**Status:** In Progress
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B053-001 Empty successful output is formatted cleanly
  Given a child writes zero output bytes and exits zero
  When evidence capture formats the result
  Then exactly one numeric lines field reports zero
  And the SHA-256 empty digest is present
  And no arithmetic diagnostic is present
  And the wrapper returns zero

Scenario: SCN-B053-002 Empty failing output preserves the child exit
  Given a child writes zero output bytes and exits seven
  When evidence capture formats the result
  Then exactly one numeric lines field reports zero
  And the SHA-256 empty digest is present
  And no arithmetic diagnostic is present
  And the wrapper returns seven

Scenario: SCN-B053-003 Non-empty counting remains compatible
  Given a child writes one line and exits zero
  When evidence capture formats the result
  Then exactly one lines field reports one
  And the short output remains visible

Scenario: SCN-B053-004 Missing capture output remains a distinct failure
  Given the capture output file disappears while the child runs
  When evidence capture checks capture integrity
  Then it exits two with the disappearance diagnostic
  And it emits no blank evidence hash
```

### Implementation Plan

1. Add both empty-output cases to the existing selftest.
2. Run the focused selftest before production changes.
3. Capture failures caused by duplicate line-count data or arithmetic diagnostics.
4. Replace the grep-status-dependent count with one portable scalar counter.
5. Run the focused cases and every existing evidence-capture case.
6. Run syntax, shell quality, and portability checks on both changed scripts.
7. Run full canonical framework validation.
8. Regenerate the release manifest after validated source changes.

### Implementation Files

- `bubbles/scripts/evidence-capture.sh`
- `bubbles/scripts/evidence-capture-selftest.sh`

### Change Boundary

**Allowed paths:**

- `bubbles/scripts/evidence-capture.sh`
- `bubbles/scripts/evidence-capture-selftest.sh`
- `bubbles/release-manifest.json`
- this bug packet and `BUGS.md`

**Excluded paths:** process-group handling, hash helpers, receipt schemas,
unrelated guards, downstream installations, BUG-035, BUG-051, and other bug
packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B053-001 | Regression E2E: empty successful child emits one clean zero count | functional | `bubbles/scripts/evidence-capture-selftest.sh` | `bash bubbles/scripts/evidence-capture-selftest.sh` | No |
| T2 | SCN-B053-002 | Adversarial empty failing child preserves exit seven and clean metadata | functional | `bubbles/scripts/evidence-capture-selftest.sh` | `bash bubbles/scripts/evidence-capture-selftest.sh` | No |
| T3 | SCN-B053-003 | One-line child retains one-line count and short rendering | functional | `bubbles/scripts/evidence-capture-selftest.sh` | `bash bubbles/scripts/evidence-capture-selftest.sh` | No |
| T4 | SCN-B053-004 | BUG-035 D14 missing capture path still fails loud | regression | `bubbles/scripts/evidence-capture-selftest.sh` | `bash bubbles/scripts/evidence-capture-selftest.sh` | No |
| T5 | Aggregate | Shell syntax and portability checks cover both changed scripts | regression | `bubbles/scripts/macos-portability-guard.sh` | canonical source shell validation commands | No |
| T6 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

### Definition of Done

- [x] The persistent SCN-B053-001 case fails before production changes for the expected formatter defect. -> Evidence: [BUG-053 empty-output RED reproduction](report.md#bug-053-empty-output-red-reproduction) (**Phase:** implement; **Claim Source:** executed)
- [x] The persistent SCN-B053-002 case fails before production changes for the expected formatter defect. -> Evidence: [BUG-053 empty-output RED reproduction](report.md#bug-053-empty-output-red-reproduction) (**Phase:** implement; **Claim Source:** executed)
- [x] Root cause is confirmed by the RED cases and source path. -> Evidence: [BUG-053 empty-output RED reproduction](report.md#bug-053-empty-output-red-reproduction) (**Phase:** implement; **Claim Source:** executed)
- [x] Line counting produces one scalar without relying on grep's empty-match exit status. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B053-001 emits exactly one numeric `lines: 0` and returns zero. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
  - Independent evidence: [BUG-053 independent focused test verification](report.md#bug-053-independent-focused-test-verification) (**Phase:** test; **Claim Source:** executed)
- [x] SCN-B053-002 emits exactly one numeric `lines: 0` and returns seven. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
  - Independent evidence: [BUG-053 independent focused test verification](report.md#bug-053-independent-focused-test-verification) (**Phase:** test; **Claim Source:** executed)
- [x] Both empty-output cases emit the exact SHA-256 empty digest. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Both empty-output cases emit no arithmetic syntax or error-token diagnostic. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B053-003 preserves non-empty short-output behavior. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
  - Independent evidence: [BUG-053 independent focused test verification](report.md#bug-053-independent-focused-test-verification) (**Phase:** test; **Claim Source:** executed)
- [x] SCN-B053-004 preserves BUG-035 D14 missing-file failure behavior. -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
  - Independent evidence: [BUG-053 independent focused test verification](report.md#bug-053-independent-focused-test-verification) (**Phase:** test; **Claim Source:** executed)
- [x] The adversarial regression fails if the grep-plus-fallback expression returns. -> Evidence: [BUG-053 empty-output RED reproduction](report.md#bug-053-empty-output-red-reproduction) (**Phase:** implement; **Claim Source:** executed)
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: [BUG-053 focused GREEN](report.md#bug-053-focused-green) (**Phase:** implement; **Claim Source:** executed)
  - Independent evidence: [BUG-053 independent contract and quality verification](report.md#bug-053-independent-contract-and-quality-verification) (**Phase:** test; **Claim Source:** executed)
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** Independent T1-T5 verification ran against the current production and test bytes. T6 was not executed under the focused scenario-node boundary.
  > **What was observed:** The focused selftest passed 20/20 checks; syntax, ShellCheck, portability, scenario, mechanism, regression-quality, reality, and manifest checks exited zero.
  > **Why this is uncertain:** The active scenario reserves one full framework T6 execution for the combined validation node after all dependent focused nodes complete.
  > **What would resolve this:** Scenario node `integrate-publish-bubbles-main` executes the one batched T6 command and records its current-session result.
- [x] Change Boundary is respected and zero excluded file families were changed -> Evidence: [Change boundary and neighboring-byte preservation](report.md#change-boundary-and-neighboring-byte-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] Release manifest is regenerated from the validated source tree. -> Evidence: [Release manifest integrity](report.md#release-manifest-integrity) (**Phase:** implement; **Claim Source:** executed)
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No validate-owned certification command was run by the implementation owner.
  > **What was observed:** The bug and certification scope remain `in_progress`.
  > **Why this is uncertain:** Certification belongs to `bubbles.validate` and this invocation is limited to focused implementation.
  > **What would resolve this:** `bubbles.validate` evaluates the packet after the reserved test pass.
