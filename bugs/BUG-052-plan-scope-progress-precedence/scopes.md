# BUG-052 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Certification-First Scope Progress Resolution

**Status:** In Progress
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B052-001 Empty legacy array cannot shadow canonical depth
  Given top-level scopeProgress is empty
  And certification.scopeProgress contains an over-depth consumer graph
  When the guard runs under block posture
  Then it blocks the horizontal plan

Scenario: SCN-B052-002 Canonical shallow graph wins over legacy deep graph
  Given certification.scopeProgress has an early usable consumer
  And top-level scopeProgress has an over-depth graph
  When the guard runs under block posture
  Then it passes from the canonical graph

Scenario: SCN-B052-003 Legacy top-level graph remains supported
  Given certification.scopeProgress is absent
  And top-level scopeProgress has an over-depth graph
  When the guard runs under block posture
  Then it blocks through the compatibility fallback

Scenario: SCN-B052-004 Execution scope progress cannot replace authority
  Given certification.scopeProgress has an early usable consumer
  And execution.scopeProgress has a conflicting over-depth graph
  When the guard selects scope progress
  Then it evaluates the certification-owned graph
```

### Implementation Plan

1. Add the simultaneous top-level-empty and canonical-deep RED fixture.
2. Run the selftest before production changes and capture the false no-op.
3. Reverse the jq selection order to certification first.
4. Preserve top-level compatibility only when certification data is absent.
5. Add canonical-versus-legacy and canonical-versus-execution adversaries.
6. Re-run all existing depth, shape, and no-op fixtures.
7. Run full canonical framework validation.
8. Regenerate the release manifest after validated source changes.

### Implementation Files

- `bubbles/scripts/plan-dependency-depth-guard.sh`
- `bubbles/scripts/plan-dependency-depth-guard-selftest.sh`

### Change Boundary

**Allowed paths:**

- `bubbles/scripts/plan-dependency-depth-guard.sh`
- `bubbles/scripts/plan-dependency-depth-guard-selftest.sh`
- `bubbles/release-manifest.json`
- this bug packet and `BUGS.md`

**Excluded paths:** state schemas, other state readers, dependency-depth algorithms, downstream artifacts, and other bug packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B052-001 | Regression E2E: empty top-level field cannot shadow canonical depth | functional | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T2 | SCN-B052-002 | Adversarial canonical shallow graph wins over legacy deep graph | functional | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T3 | SCN-B052-003 | Legacy top-level-only graph remains blocking | functional | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T4 | SCN-B052-004 | Execution graph does not become authority | functional | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T5 | Aggregate | Existing graph depth, type, and no-op cases remain green | regression | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T6 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

### Definition of Done

- [x] Root cause is confirmed by the simultaneous-field RED result. → Evidence: [SCN-B052-001 RED reproduction](report.md#scn-b052-001-red-reproduction) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-001 canonical over-depth data blocks despite top-level `[]`. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-002 canonical shallow data wins over deprecated deep data. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-003 top-level-only compatibility remains blocking. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-004 execution scope progress never selects the enforcement graph. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Existing object, malformed-array, edge, and missing-body behavior remains unchanged. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] The pre-fix regression test fails for the expected precedence reason. → Evidence: [SCN-B052-001 RED reproduction](report.md#scn-b052-001-red-reproduction) (**Phase:** implement; **Claim Source:** executed)
- [x] The adversarial regressions fail if legacy or execution data gains authority. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** Test Plan T1-T5, linked-test resolution, scenario obligations, test-mechanism lint, regression quality, shell checks, portability, implementation reality, artifact lint, manifest freshness, and neighboring-byte verification were executed independently. T6 was not run by explicit operator instruction.
  > **What was observed:** T1-T5 and every focused execution check except test-mechanism lint passed. Test-mechanism lint rejected SCN-B052-002 because `riskTier: high` declares `perturbed-input` instead of `mutation` or a named fallback. Manifest freshness passed on the final independent rerun after BUG-053 regenerated the shared manifest. See [Independent focused test verification](report.md#independent-focused-test-verification) (**Phase:** test; **Claim Source:** executed).
  > **Why this is uncertain:** The full framework T6 remains reserved for the combined stage after BUG-053, and the plan-owned mechanism declaration blocks a clean test-phase result.
  > **What would resolve this:** `bubbles.plan` corrects the SCN-B052-002 negative-control declaration, then `bubbles.test` reruns the failed mechanism check and executes the combined T6 after BUG-053.
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Change boundary and prior-bug preservation](report.md#change-boundary-and-prior-bug-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] Release manifest is regenerated from the validated source tree. → Evidence: [Release manifest integrity](report.md#release-manifest-integrity) (**Phase:** implement; **Claim Source:** executed)
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No validate-owned certification command was run during independent focused test verification.
  > **What was observed:** `state.json.certification` remains unchanged. The current test phase found the plan-owned SCN-B052-002 negative-control mismatch, and T6 was not run by instruction.
  > **Why this is uncertain:** Certification belongs to `bubbles.validate` and cannot run cleanly while test verification is routed back to planning.
  > **What would resolve this:** `bubbles.plan` repairs the mechanism declaration, `bubbles.test` completes the combined post-BUG-053 verification, and `bubbles.validate` evaluates the packet.
