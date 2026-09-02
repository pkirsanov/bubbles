# BUG-047 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Canonical Reasoned Skip Accounting

**Status:** In Progress
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B047-001 Canonical skip satisfies required phase accounting
  Given stabilize is required and absent from completed phase claims
    And executionHistory contains its complete reasoned skip decision
  When the transition guard runs
  Then Check 6 accounts for stabilize without a completion claim

Scenario: SCN-B047-002 Authorized skip decision may have zero duration
  Given the canonical stabilize skip records equal start and completion instants
  When Check 7A evaluates execution history
  Then no zero-duration execution finding names that skip

Scenario: SCN-B047-003 Executed zero-duration phase remains blocked
  Given stabilize records an executed outcome with equal instants
  When Check 7A evaluates execution history
  Then the guard reports nontrivial zero-duration execution

Scenario: SCN-B047-004 Malformed skip gains no exemption
  Given stabilize records outcome skipped without a substantive reason
  When required-phase accounting and timestamp plausibility run
  Then the phase does not satisfy the skip contract
```

### Implementation Plan

1. Add the composed RED fixture before production changes.
2. Capture its Check 6 and Check 7A failures.
3. Implement one registry-bound skip classifier.
4. Consume that classifier in both checks.
5. Add malformed, never-skip, and executed zero-duration adversaries.
6. Run focused and broad framework validation through the canonical CLI.
7. Regenerate the release manifest after validated source changes.

### Change Boundary

**Allowed paths:**

- `bubbles/workflows/modes.yaml` only if the current schema needs clarification
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/phase-relevance-resolve.sh` only if resolver output changes
- `bubbles/scripts/phase-relevance-resolve-selftest.sh` only with its owner
- `bubbles/release-manifest.json`
- this bug packet and `BUGS.md`

**Excluded paths:** downstream installs, unrelated guards, product files, and other bug packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B047-001 | Regression E2E: required reasoned skip is accounted without a completed claim | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T2 | SCN-B047-002 | Canonical zero-duration decision record is not executed work | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T3 | SCN-B047-003 | Adversarial executed zero-duration phase still blocks | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T4 | SCN-B047-004 | Adversarial reasonless and never-skip records gain no exemption | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No |
| T5 | Aggregate | Broader phase-relevance and transition regressions remain green | regression | `bubbles/scripts/phase-relevance-resolve-selftest.sh` | `bash bubbles/scripts/phase-relevance-resolve-selftest.sh` | No |
| T6 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

### Definition of Done

- [x] SCN-B047-001 pre-fix composed regression fails for the expected Check 6 reason. → Evidence: [Pre-Production RED Evidence](report.md#pre-production-red-evidence) (**Phase:** implement; capture `c6df6d17829bcabf4256c2caa48909461001ccc909a55b2bb84241fb35448a52`).
- [x] SCN-B047-001 canonical skip classification reads the registry contract. → Evidence: [HOST-101 Current-Byte Reconciliation](report.md#host-101-current-byte-reconciliation) (**Phase:** implement; **Claim Source:** interpreted; the report records the source-path interpretation and current-byte receipt).
- [x] SCN-B047-001 a validated skip satisfies phase accounting without a completion claim. → Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; current-byte capture `ba836636cfcd57d8859a41880ac2fc233f68798b949e2ae24fd732861ac7c4f2`).
- [x] SCN-B047-002 authorized skip decisions are excluded from executed-duration adjudication. → Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; the Check 7A assertion passed against the current source and test identities).
- [x] SCN-B047-004 reasonless, malformed, and never-skip records remain invalid. → Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; all fail-closed adversarial assertions passed).
- [x] SCN-B047-003 executed nontrivial zero-duration phases remain blocked. → Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; the executed `stabilize` control remained blocking).
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior → Evidence: [Focused GREEN Evidence](report.md#focused-green-evidence) (**Phase:** implement; SCN-B047-001 through SCN-B047-004 have persistent assertions in the canonical selftest).
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** Independent `bubbles.test` ran the complete `bash bubbles/scripts/cli.sh framework-validate` command, the core tier, and the guard-consumer regression closure. See [Independent Test Verification And Aggregate Failure Isolation](report.md#independent-test-verification-and-aggregate-failure-isolation).
  > **What was observed:** The full command exited 1 after 346 checks. The core tier and eight guard-consumer regressions exited 0. The live G125 lint exits 1 because IMP-054 and IMP-055 have no index rows.
  > **Why this is uncertain:** Test Plan row T6 requires an exit-zero complete source framework regression. `bugfix-fastlane` does not waive a pre-existing failing check.
  > **What would resolve this:** `bubbles.retro` must restore both proposal rows in `improvements/INDEX.md`. `bubbles.test` must then run `bash bubbles/scripts/cli.sh framework-validate` on the unchanged BUG-047 source identities.
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [HOST-101 Current-Byte Reconciliation](report.md#host-101-current-byte-reconciliation) (**Phase:** implement; strict path decisions and protected BUG-048–050 identity checks passed).
- [x] Release manifest is regenerated from the validated source tree. → Evidence: [HOST-101 Current-Byte Reconciliation](report.md#host-101-current-byte-reconciliation) (**Phase:** implement; generator and `--check` receipts both exited 0).
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No certification command was invoked because certification is owned by `bubbles.validate`.
  > **What was observed:** `certification.status` remains `in_progress`, with no completed scopes or certified phase claims.
  > **Why this is uncertain:** No validate-owned execution has adjudicated this packet after independent testing.
  > **What would resolve this:** Validate-owned certification after `bubbles.test` records independent verification.
