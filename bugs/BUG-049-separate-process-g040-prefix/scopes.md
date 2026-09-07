# BUG-049 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Token-Bounded G040 PR Matching

**Status:** In Progress
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B049-001 Separate process does not trigger G040
  Given completed-work prose says the verifier runs in a separate process
  When Check 18 scans the artifact
  Then no deferral-language hit is reported for that phrase

Scenario: SCN-B049-002 Separate PR remains blocking
  Given prose says remaining work moves to a separate PR
  When Check 18 scans the artifact
  Then G040 blocks the transition

Scenario: SCN-B049-003 Separate pull request remains blocking
  Given prose says remaining work moves to a separate pull request
  When Check 18 scans the artifact
  Then G040 blocks the transition

Scenario: SCN-B049-004 Case variants preserve the token boundary
  Given technical prose uses Separate Process and SEPARATE PROCESS
  When the case-insensitive scan runs
  Then neither phrase matches the PR alternative
```

### Implementation Plan

1. Add the `separate process` RED fixture before changing the pattern.
2. Capture its false G040 hit.
3. Replace the abbreviation alternative with portable bounded forms.
4. Add complete PR and pull-request positive adversaries.
5. Re-run all existing G040 fixtures and portability checks.
6. Run full canonical framework validation.
7. Regenerate the release manifest after validated source changes.

### Implementation Files

- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`

### Change Boundary

**Allowed paths:**

- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/release-manifest.json`
- this bug packet and `BUGS.md`

**Excluded paths:** other G040 terms, downstream artifacts, unrelated guards, and other bug packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B049-001 | Regression E2E: separate process is not deferral prose | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T2 | SCN-B049-002 | Adversarial complete PR token remains blocking | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T3 | SCN-B049-003 | Positive full pull-request phrase remains blocking | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T4 | SCN-B049-004 | Case variants preserve prefix rejection | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T5 | Aggregate | Existing G040 and portability regressions remain green | regression | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T6 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

### Definition of Done

- [x] SCN-B049-001 pre-fix `separate process` regression fails for the expected prefix match. → Evidence: [Scenario-First RED](report.md#scenario-first-red)
- [x] SCN-B049-002 the PR abbreviation requires a complete token. → Evidence: [Focused GREEN](report.md#focused-green)
- [x] SCN-B049-003 the complete `pull request` phrase remains recognized. → Evidence: [Focused GREEN](report.md#focused-green)
- [x] SCN-B049-004 case-insensitive `separate process` variants remain inert. → Evidence: [Focused GREEN](report.md#focused-green)
- [x] SCN-B049-002 genuine separate-PR deferral wording remains blocking. → Evidence: [Focused GREEN](report.md#focused-green)
- [x] Existing G040 and portability regressions pass. → Evidence: [Complete T1-T5 Aggregate](report.md#complete-t1-t5-aggregate)
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior → Evidence: [Focused GREEN](report.md#focused-green)
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** No `framework-validate` command was executed in this node, per the operator's explicit combined-run constraint.
  > **What was observed:** Focused and owning-guard checks were selected for BUG-049; framework T6 remains unexecuted.
  > **Why this is uncertain:** This node cannot claim the broader framework result without the reserved combined execution.
  > **What would resolve this:** The scenario coordinator executes the single combined `bash bubbles/scripts/cli.sh framework-validate` after BUG-050 and records exit 0.
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Code Diff Evidence](report.md#code-diff-evidence)
- [x] Release manifest is regenerated from the validated source tree. → Evidence: [Release Manifest](report.md#release-manifest)
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No certification write was attempted by `bubbles.implement`.
  > **What was observed:** The packet remains `in_progress`, and certification fields remain validate-owned.
  > **Why this is uncertain:** Certification requires the validate specialist and the reserved combined framework result.
  > **What would resolve this:** `bubbles.validate` consumes the final combined evidence and records its certification verdict.
