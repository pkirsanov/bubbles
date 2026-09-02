# BUG-052 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Execution Outline

**Outcome:** Preserve certification-first scope-progress selection while making every fallback and coexistence branch independently testable.

**Authority decision:** A non-null `certification.scopeProgress` value is authoritative. Deprecated top-level data is consulted only when the canonical field is absent or null. `execution.scopeProgress` is never an authority source.

### Phase Order

1. **Scope 1 - Certification-First Scope Progress Resolution:** Reconcile the guard and its focused selftest against all canonical, compatibility, and migration-copy cases, then run the framework regression checkpoint.

### New Types & Signatures

- No public type, schema, or command signature is introduced.
- Authority selector contract: `certification.scopeProgress` when non-null, otherwise top-level `scopeProgress`, otherwise `[]`.
- Diagnostic contract for SCN-B052-001: exit `1`, `[plan-dependency-depth-guard] DEPENDENCY-GRAPH HORIZONTAL PLAN` present, `deprecated top-level scopeProgress conflicts with certification.scopeProgress` absent.
- Scenario manifest contract: schema version 2 with object-valued authored `linkedTests` and separate unauthored `plannedTests`.

### Validation Checkpoints

- Planning checkpoint: artifact lint plus JSON, scenario-obligation, test-mechanism, and traceability checks must accept the reconciled handoff.
- Focused RED checkpoint: the SCN-B052-001 diagnostic assertions must reject exit `1` produced for the wrong reason.
- Focused GREEN checkpoint: T16 through T20 plus canonical-null and semantic-equality cases must satisfy their exact verdict and diagnostic contracts.
- Regression checkpoint: all existing graph-depth, shape, and no-op cases must remain green.
- Framework checkpoint: `bash bubbles/scripts/cli.sh framework-validate` must pass before certification is requested.

### Reconciliation Constraints

- Preserve SCN-B052-002 / checkpoint T17 as canonical-precedence exit `0`.
- Preserve legacy-only, execution-non-authority, canonical-empty, and semantically equal migration-copy behavior.
- Reject the parallel-branch conflict rule in which deprecated divergence vetoes canonical evaluation.
- Leave all new behavior and validation DoD items unchecked until their named commands produce current execution evidence.

### Scope Inventory

| Scope | Surfaces | Tests | DoD Summary | Status |
| --- | --- | --- | --- | --- |
| 1. Certification-First Scope Progress Resolution | Guard, focused selftest, planning handoff | Functional adversaries and framework regression | Exact authority, verdict, diagnostic, compatibility, and boundary proof | In Progress |

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
  Then it exits 1 with `[plan-dependency-depth-guard] DEPENDENCY-GRAPH HORIZONTAL PLAN`
  And it does not emit `deprecated top-level scopeProgress conflicts with certification.scopeProgress`

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

Scenario: SCN-B052-005 Null canonical scope progress uses the legacy fallback
  Given certification.scopeProgress is null
  And top-level scopeProgress contains an over-depth consumer graph
  When the guard runs under block posture
  Then it blocks through the top-level compatibility fallback
  And it emits `[plan-dependency-depth-guard] DEPENDENCY-GRAPH HORIZONTAL PLAN`

Scenario: SCN-B052-006 Present canonical empty scope progress remains authoritative
  Given certification.scopeProgress is an empty array
  And top-level scopeProgress contains an over-depth consumer graph
  When the guard runs under block posture
  Then it evaluates the canonical empty array and exits 0

Scenario: SCN-B052-007 Semantically equal migration copies can coexist
  Given certification.scopeProgress and top-level scopeProgress describe the same graph
  And object keys, records, and dependency aliases appear in different orders
  When the guard runs during compatibility migration
  Then it evaluates the canonical graph without a conflict refusal and exits 0
```

### Implementation Plan

1. Add the simultaneous top-level-empty and canonical-deep RED fixture.
2. Run the selftest before production changes and capture the false no-op.
3. Reverse the jq selection order to certification first.
4. Preserve top-level compatibility only when certification data is absent.
5. Add canonical-versus-legacy and canonical-versus-execution adversaries.
6. Add a canonical-null plus legacy over-depth graph fixture that proves the FR-B052-002 fallback.
7. Make SCN-B052-001 assert the horizontal-plan diagnostic and reject the incomplete-DAG conflict diagnostic, not merely assert exit 1.
8. Preserve canonical-empty authority and semantically equal migration-copy acceptance fixtures.
9. Re-run all existing depth, shape, and no-op fixtures.
10. Run full canonical framework validation.
11. Regenerate the release manifest after validated source changes.

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

**Planning reconciliation boundary:** This invocation may change only this
`scopes.md`, `scenario-manifest.json`, `test-plan.json`, and `state.json.execution`.
It must not change the guard, its selftest, release-manifest bytes, report
evidence, `state.json.certification`, BUG-049, or BUG-050.

### Test Plan

| Test ID | Scenario ID | Description | Test Type | Category | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B052-001 | Regression: `T16 SCN-B052-001 legacy empty array cannot shadow canonical deep graph`; exits 1 with `DEPENDENCY-GRAPH HORIZONTAL PLAN` and without `deprecated top-level scopeProgress conflicts with certification.scopeProgress` | functional | regression | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T2 | SCN-B052-002 | `T17 SCN-B052-002 canonical shallow graph wins over legacy deep graph (exit 0)` | functional | adversarial | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T3 | SCN-B052-003 | `T18 SCN-B052-003 legacy-only deep graph remains blocking (exit 1)` | functional | compatibility | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T4 | SCN-B052-004 | `T19 SCN-B052-004 canonical graph wins over execution deep graph (exit 0)` | functional | adversarial | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T5 | — | Regression: existing dependency depth, type, and no-op cases remain green | functional | regression | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T6 | — | Regression: full source framework validation; do not run in this planning invocation | functional | regression | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |
| T7 | SCN-B052-005 | `T20B SCN-B052-005 canonical null falls back to legacy deep graph`; exits 1 with `DEPENDENCY-GRAPH HORIZONTAL PLAN` and without the authority-conflict diagnostic | functional | compatibility | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T8 | SCN-B052-006 | Regression: `T20 canonical empty array remains authoritative over legacy deep graph (exit 0)` | functional | regression | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |
| T9 | SCN-B052-007 | `T50 semantically equal scopeProgress authorities remain valid` despite object, record, and dependency order differences (exit 0) | functional | compatibility | `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | `bash bubbles/scripts/plan-dependency-depth-guard-selftest.sh` | No |

### Definition of Done

- [x] Root cause is confirmed by the simultaneous-field RED result. → Evidence: [RED reproduction](report.md) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-001 canonical over-depth data exits 1 with `DEPENDENCY-GRAPH HORIZONTAL PLAN` despite top-level `[]`, and the output does not contain `deprecated top-level scopeProgress conflicts with certification.scopeProgress`. → Evidence: [Origin/main reconciliation focused GREEN](report.md#originmain-reconciliation-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-002 canonical shallow data wins over deprecated deep data. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-003 top-level-only compatibility remains blocking. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-004 execution scope progress never selects the enforcement graph. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-005 canonical `null` falls back to the legacy over-depth graph and emits `DEPENDENCY-GRAPH HORIZONTAL PLAN`. → Evidence: [Origin/main reconciliation focused GREEN](report.md#originmain-reconciliation-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-006 canonical empty scope progress remains authoritative over a deprecated deep graph and exits 0. → Evidence: [Origin/main reconciliation focused GREEN](report.md#originmain-reconciliation-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B052-007 semantically equal canonical and deprecated migration copies remain valid despite representation-order differences and exit 0. → Evidence: [Origin/main reconciliation focused GREEN](report.md#originmain-reconciliation-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Existing object, malformed-array, edge, and missing-body behavior remains unchanged. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] The pre-fix regression test fails for the expected precedence reason. → Evidence: [Pre-fix RED reproduction](report.md) (**Phase:** implement; **Claim Source:** executed)
- [x] The adversarial regressions fail if legacy or execution data gains authority. → Evidence: [BUG-052 focused GREEN](report.md#bug-052-focused-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior → Evidence: [Origin/main reconciliation focused GREEN](report.md#originmain-reconciliation-focused-green) (**Phase:** implement; **Claim Source:** executed)
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
