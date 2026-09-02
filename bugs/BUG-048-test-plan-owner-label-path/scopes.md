# BUG-048 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Semantic Test Plan Path Extraction

**Status:** In Progress
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B048-001 Finding Accounting owner labels are inert
  Given one valid Test Plan file and five bubbles.test owner labels in another table
  When Check 8 extracts paths
  Then only the Test Plan file is checked

Scenario: SCN-B048-002 Legitimate basename-only dot-test file resolves
  Given a Test Plan path cell names smoke.test
    And exactly one matching file exists
  When Check 8 runs
  Then it resolves the basename without a missing-path failure

Scenario: SCN-B048-003 Missing actual Test Plan path remains blocking
  Given a Test Plan path cell names missing.test
    And no matching file exists
  When Check 8 runs
  Then the transition is refused for that path

Scenario: SCN-B048-004 File-shaped metadata outside Test Plan is inert
  Given another Markdown table contains a supported suffix in backticks
  When Check 8 scans the scope
  Then that metadata value is not extracted
```

### Implementation Plan

1. Add the Finding Accounting RED fixture before production changes.
2. Capture the nonexistent `bubbles.test` path failure.
3. Add heading, header, and table-boundary extraction.
4. Reuse existing path token validation inside the selected cells.
5. Add basename-positive, missing-path, and unrelated-table adversaries.
6. Run focused and broad canonical validation.
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

**Excluded paths:** Finding Accounting schema, downstream scopes, unrelated guard checks, and other packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B048-001 | Regression E2E: owner labels outside Test Plan never become paths | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T2 | SCN-B048-002 | Positive basename-only smoke.test resolves uniquely | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T3 | SCN-B048-003 | Adversarial missing.test in a real path cell remains blocking | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T4 | SCN-B048-004 | Adversarial supported suffix in another table stays inert | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T5 | Aggregate | Existing shell, command-wrapped, MJS, and placeholder Check 8 cases remain green | regression | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T6 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

### Definition of Done

- [x] SCN-B048-001 pre-fix owner-label fixture fails through Check 8 for the expected reason. -> Evidence: [Pre-Production RED Evidence](report.md#pre-production-red-evidence) (**Phase:** implement; capture `00a4bd331bfffbcf5368c0f61b124fbdfb8e6132dacbf23577cd334274dfb3be`).
- [x] SCN-B048-001 extraction is limited to actual Test Plan sections and path columns. -> Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; the real Test Plan file passed and five owner labels stayed inert).
- [x] SCN-B048-004 file-shaped metadata in other tables remains inert. -> Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; `unrelated-metadata.test` never entered path handling).
- [x] SCN-B048-002 legitimate basename-only `.test` files still resolve. -> Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; unique `smoke.test` resolution passed).
- [x] SCN-B048-003 missing files in actual Test Plan path cells still block. -> Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; the `missing.test` fixture retained the named refusal).
- [x] Existing shell, command-wrapped, MJS, and placeholder regressions pass. -> Evidence: [Complete Guard Regression Evidence](report.md#complete-guard-regression-evidence) (**Phase:** implement; 507-line capture `6c6f71d9c8b2260c66ef5a1f148e8c3a2f564407d6c8506ce5632a2cfc41f049`).
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; SCN-B048-001 through SCN-B048-004 execute through the canonical guard selftest).
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** `bubbles.test` independently executed Test Plan rows T1-T4 through the BUG-048-only scenario matrix and T5 through the complete state-transition-guard selftest on unchanged source bytes. T6 was not invoked because the operator reserved one combined full framework run after BUG-049 and BUG-050.
  > **What was observed:** T1-T4 exited 0 with capture `f2c3a226bc28de5f3b666bfb325e25bb434226c3ef552fcaf4a08ebe1a83baaa`. T5 exited 0 with 507-line capture `6c6f71d9c8b2260c66ef5a1f148e8c3a2f564407d6c8506ce5632a2cfc41f049`. Pre-test and post-test source identity captures both equal `dc06f69fe48c2c4b0e2ccecd1546f4fd83466e8d09f061ae945a4ca00ad62fee`. See [Independent Test Verification T1-T5](report.md#independent-test-verification-t1-t5) (**Phase:** test; **Claim Source:** executed). No current-session exit result exists for `bash bubbles/scripts/cli.sh framework-validate`.
  > **Why this is uncertain:** The independently passing focused and complete guard selftests do not replace the registered full framework T6 command.
  > **What would resolve this:** The operator-reserved combined `bash bubbles/scripts/cli.sh framework-validate` exits 0 after BUG-049 and BUG-050 on the final shared source identities.
- [x] Change Boundary is respected and zero excluded file families were changed -> Evidence: [Implementation Validation Receipts](report.md#implementation-validation-receipts) (**Phase:** implement; strict production, selftest, manifest, and packet classifications each resolved `in-boundary`).
- [x] Release manifest is regenerated from the validated source tree. -> Evidence: [Implementation Validation Receipts](report.md#implementation-validation-receipts) (**Phase:** implement; generation, freshness, and manifest selftest exited 0).
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** Independent T1-T5 verification completed. No certification command ran because `bubbles.validate` owns certification fields and verdicts.
  > **What was observed:** `execution.substate` records independent verification while `certification.status` remains `in_progress`, with no completed scopes or certified phases. T6 has no execution receipt.
  > **Why this is uncertain:** No validate-owned execution has adjudicated BUG-048 with the operator-reserved combined T6 evidence.
  > **What would resolve this:** `bubbles.validate` certifies the packet after the combined T6 receipt exists.
