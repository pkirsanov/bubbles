# Scopes: BUG-023 Result-Envelope Outcome Contract Drift

## Scope Inventory

| # | Scope | Depends On | Status |
| --- | --- | --- | --- |
| 1 | Canonical Outcome And Legacy-Read Parity | None | In Progress |

## Scope 1: Canonical Outcome And Legacy-Read Parity

**Status:** In Progress
**Depends On:** None
**Foundation:** false
**Scope-Kind:** framework-contract

### Gherkin Scenarios

#### SCN-BUG-023-001: Active outcome guidance has exact canonical parity

```gherkin
Scenario: SCN-BUG-023-001 Active outcome guidance has exact canonical parity
  Given the authoritative active outcomes in validation-core.md
  And the framework-shipped result and status skills
  When the deterministic parity regression parses active semantics
  Then completed_owned, completed_diagnostic, route_required, and blocked are present exactly once
  And no additional active outcome is accepted
  And every related skill uses current observation and status semantics
```

#### SCN-BUG-023-002: Legacy status prose cannot authorize a new write

```gherkin
Scenario: SCN-BUG-023-002 Legacy status prose cannot authorize a new write
  Given explicitly marked legacy read-only compatibility prose
  When the deterministic parity regression classifies that prose
  Then the prose is accepted as historical compatibility guidance
  But moving done_with_concerns into an active table or write instruction fails the regression
```

### Current Invocation Change Boundary

This invocation creates only the nine packet files under
`improvements/BUG-023-result-envelope-outcome-contract-drift/`. It does not
edit source, tests, generated manifests, `BUGS.md`, `improvements/INDEX.md`,
release identity, Git history, or downstream repositories.

### Authorized Delivery Boundary By Owner

| Owner | Surface | Exact permission |
| --- | --- | --- |
| `bubbles.design` | `design.md` | Reconcile active versus legacy-read parsing semantics. |
| `bubbles.plan` | Planning-owned packet artifacts | Reconcile scenarios, rows, DoD, and owner routing. |
| `bubbles.test` | `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | Final RED/GREEN regression and adversarial fixtures. |
| `bubbles.implement` | Four named skill files | Atomic guidance repair after valid RED. |
| `bubbles.test` | Framework registration/provenance assertions | Focused registration only after GREEN. |
| `bubbles.releases` | Generated release identity | Reconcile after stable source/test bytes. |
| `bubbles.validate` | `state.json::certification.*` and terminal status | Independent certification only. |

### Implementation Plan

1. Freeze the final regression bytes and demonstrate pre-fix failure caused by
   the missing diagnostic outcome and active legacy semantics.
2. Align the result-envelope skill's active set and diagnostic definition.
3. Align feature-template, fix-cycle, and status-transition guidance with
   `done` plus `observations[]` and explicit legacy-read-only compatibility.
4. Rerun identical regression bytes against canonical source and every
   isolated adversarial fixture.
5. Run focused provenance, framework validation, and release checks in owner
   order before validate-owned certification.

### Test Plan

The machine-readable twin is [test-plan.json](test-plan.json).

| Test Type | Test ID | Scenarios | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mandatory pre-fix RED | T-BUG-023-01 | SCN-BUG-023-001, SCN-BUG-023-002 | functional | `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | Final test bytes reject the current missing/extra active outcome contract. | `bash tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | No |
| Canonical set parity | T-BUG-023-02 | SCN-BUG-023-001 | functional | `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | Authority and active result-envelope table have equal sets and cardinality. | `bash tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | No |
| Related-skill parity | T-BUG-023-03 | SCN-BUG-023-001 | functional | `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | Feature, fix-cycle, and status skills use current observation/status semantics. | `bash tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | No |
| Legacy-read adversary | T-BUG-023-04 | SCN-BUG-023-002 | functional | `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | Marked read-only prose passes; active/unmarked legacy mutations fail. | `bash tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | No |
| Regression quality | T-BUG-023-05 | SCN-BUG-023-001, SCN-BUG-023-002 | functional | `bubbles/scripts/regression-quality-guard.sh` | Regression contains a real adversarial mutation and no bailout path. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | No |
| Install provenance | T-BUG-023-06 | SCN-BUG-023-001, SCN-BUG-023-002 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Managed skills and source-only regression retain canonical provenance. | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| Framework regression | T-BUG-023-07 | SCN-BUG-023-001, SCN-BUG-023-002 | integration | `bubbles/scripts/cli.sh` | Full framework validation accepts the aligned contract. | `bash bubbles/scripts/cli.sh framework-validate` | No |
| Release readiness | T-BUG-023-08 | SCN-BUG-023-001, SCN-BUG-023-002 | integration | `bubbles/scripts/cli.sh` | Generated release identity matches final managed/source-only bytes. | `bash bubbles/scripts/cli.sh release-check` | No |

### Definition of Done - Core Outcomes

- [ ] The four affected skills expose current active outcome/status semantics
  and preserve only explicitly marked legacy-read-only compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** No source edit is permitted in this intake;
    `bubbles.implement` must act after final-byte RED.
- [ ] `SCN-BUG-023-001` passes with exact set and per-token cardinality parity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The regression does not exist in this intake;
    `bubbles.test` must create and execute it.
- [ ] `SCN-BUG-023-002` accepts marked read-only prose and rejects every active
  or unmarked legacy-status mutation.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Adversarial fixtures are test-owned and have
    not been authored or executed.
- [ ] The change remains confined to the four skills, one source-only
  regression, focused registration/provenance, and generated release identity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Delivery containment can be proven only from
    the eventual owner-scoped diff.
- [ ] Validate-owned certification agrees with artifact and test reality.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Certification is intentionally untouched and
    remains with `bubbles.validate`.

### Definition of Done - Test Plan Parity

- [ ] `T-BUG-023-01` records a causal pre-fix RED using final regression bytes.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** No test command was run during packet creation.
- [ ] `T-BUG-023-02` proves exact canonical-set parity and cardinality.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires the test-owned parser and GREEN run.
- [ ] `T-BUG-023-03` proves all three adjacent skills use current semantics.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires repaired source and focused execution.
- [ ] `T-BUG-023-04` proves marked legacy-read acceptance and active-leak rejection.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires isolated valid and mutated fixtures.
- [ ] `T-BUG-023-05` proves adversarial quality and zero bailout paths.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires the physical regression file.
- [ ] `T-BUG-023-06` proves managed versus source-only install provenance.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires stable source and registration bytes.
- [ ] `T-BUG-023-07` proves broad framework compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Full framework validation was not run.
- [ ] `T-BUG-023-08` proves final release readiness and identity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Release checks belong after stable canonical inputs.

The eight Test Plan rows have exactly eight test-related DoD items. Both
scenarios map to concrete rows in this file, [scenario-manifest.json](scenario-manifest.json),
and [test-plan.json](test-plan.json).

### Owner Route

`bubbles.design` is the immediate owner for design confirmation, followed by
`bubbles.plan`, `bubbles.test`, `bubbles.implement`, `bubbles.test`,
`bubbles.releases`, and `bubbles.validate` in that order.
