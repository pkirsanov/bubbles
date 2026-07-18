# Scopes: BUG-024 Create-Skill Placeholder Stubs

## Scope Inventory

| # | Scope | Depends On | Status |
| --- | --- | --- | --- |
| 1 | Complete Skill Scaffold Contract | None | In Progress |

## Scope 1: Complete Skill Scaffold Contract

**Status:** In Progress
**Depends On:** None
**Foundation:** false
**Scope-Kind:** framework-authoring-contract

### Gherkin Scenarios

#### SCN-BUG-024-001: Applicable optional guidance is concrete and inapplicable guidance is omitted

```gherkin
Scenario: SCN-BUG-024-001 Applicable optional guidance is concrete and inapplicable guidance is omitted
  Given complete skill intent, triggers, outputs, and verified repository context
  When create-skill renders SKILL.md
  Then each applicable optional section contains concrete routing content
  And each inapplicable optional section is absent
  And no incomplete marker or generic filler is emitted
```

#### SCN-BUG-024-002: Materially missing boundary information prevents incomplete scaffolding

```gherkin
Scenario: SCN-BUG-024-002 Materially missing boundary information prevents incomplete scaffolding
  Given sufficient core interview answers but an unknown safety-critical negative trigger or composition dependency
  When create-skill evaluates write readiness
  Then it asks only for the material missing information or refuses the write
  And it does not create SKILL.md with empty or incomplete optional sections
  And restoring the current stub fallback fails the adversarial regression
```

### Current Invocation Change Boundary

This invocation creates only the nine packet files under
`improvements/BUG-024-create-skill-placeholder-stubs/`. It does not edit agent
source, tests, generated manifests, `BUGS.md`, `improvements/INDEX.md`, Git
history, or downstream repositories.

### Authorized Delivery Boundary By Owner

| Owner | Surface | Exact permission |
| --- | --- | --- |
| `bubbles.design` | `design.md` | Reconcile include/omit/continue/refuse materiality rules. |
| `bubbles.plan` | Planning-owned packet artifacts | Reconcile executable scenario, test, and DoD contracts. |
| `bubbles.test` | `tests/regression/test_31_create_skill_placeholder_stubs.sh` | Final-byte RED/GREEN and structural adversaries. |
| `bubbles.implement` | `agents/bubbles.create-skill.agent.md` | Repair only readiness and scaffolding instructions. |
| `bubbles.test` | Registration/provenance checks | Register source-only regression after GREEN. |
| `bubbles.releases` | Generated release identity | Reconcile stable final bytes. |
| `bubbles.validate` | Certification and terminal state | Independent certification only. |

### Implementation Plan

1. Freeze final regression bytes and prove current agent guidance fails the
   no-incomplete-content contract.
2. Replace the fixed optional-section template with the four-way readiness
   decision model.
3. Preserve the three core interview questions, dedup gate, quality bar,
   output location, and single-file default.
4. Run identical regression bytes over concrete, omitted, mixed, material-
   unknown, and independently mutated fixtures.
5. Complete provenance, broad framework, release, and validate-owned checks in
   owner order.

### Test Plan

The machine-readable twin is [test-plan.json](test-plan.json).

| Test Type | Test ID | Scenarios | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mandatory pre-fix RED | T-BUG-024-01 | SCN-BUG-024-001, SCN-BUG-024-002 | functional | `tests/regression/test_31_create_skill_placeholder_stubs.sh` | Final test bytes reject current mandatory incomplete-section guidance. | `bash tests/regression/test_31_create_skill_placeholder_stubs.sh` | No |
| Concrete and omission matrix | T-BUG-024-02 | SCN-BUG-024-001 | functional | `tests/regression/test_31_create_skill_placeholder_stubs.sh` | Both, neither, and one-section-applicable fixtures render complete files. | `bash tests/regression/test_31_create_skill_placeholder_stubs.sh` | No |
| Material unknown readiness | T-BUG-024-03 | SCN-BUG-024-002 | functional | `tests/regression/test_31_create_skill_placeholder_stubs.sh` | Safety-critical unknowns continue/refuse before any write. | `bash tests/regression/test_31_create_skill_placeholder_stubs.sh` | No |
| Adversarial scaffold mutation | T-BUG-024-04 | SCN-BUG-024-001, SCN-BUG-024-002 | functional | `tests/regression/test_31_create_skill_placeholder_stubs.sh` | Mandatory marker, empty-heading, bracketed-prompt, and generic-filler mutants fail independently. | `bash tests/regression/test_31_create_skill_placeholder_stubs.sh` | No |
| Regression quality | T-BUG-024-05 | SCN-BUG-024-001, SCN-BUG-024-002 | functional | `bubbles/scripts/regression-quality-guard.sh` | Regression has adversarial signals and no bailout behavior. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_31_create_skill_placeholder_stubs.sh` | No |
| Install provenance | T-BUG-024-06 | SCN-BUG-024-001, SCN-BUG-024-002 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Managed agent and source-only regression classification remain correct. | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| Framework regression | T-BUG-024-07 | SCN-BUG-024-001, SCN-BUG-024-002 | integration | `bubbles/scripts/cli.sh` | Full framework validation preserves authoring and unrelated agent contracts. | `bash bubbles/scripts/cli.sh framework-validate` | No |
| Release readiness | T-BUG-024-08 | SCN-BUG-024-001, SCN-BUG-024-002 | integration | `bubbles/scripts/cli.sh` | Generated release identity matches final agent and test bytes. | `bash bubbles/scripts/cli.sh release-check` | No |

### Definition of Done - Core Outcomes

- [ ] The create-skill agent emits applicable optional sections only with
  concrete verified content and omits inapplicable sections cleanly.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Agent source is outside this intake boundary;
    implementation requires final-byte RED and `bubbles.implement`.
- [ ] `SCN-BUG-024-001` passes across both/neither/one applicable matrices
  without empty headings, author prompts, or generic filler.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The physical regression is not yet authored.
- [ ] `SCN-BUG-024-002` keeps material unknowns in interview/refusal state and
  performs no incomplete write.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Readiness fixtures and execution are test-owned.
- [ ] The delivery diff remains limited to the named agent, focused source-only
  regression, registration/provenance, and generated release identity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Containment requires the eventual owner-scoped diff.
- [ ] Validate-owned certification agrees with packet, test, and release evidence.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Certification remains intentionally open.

### Definition of Done - Test Plan Parity

- [ ] `T-BUG-024-01` records causal pre-fix RED using final regression bytes.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** No test command was run during packet creation.
- [ ] `T-BUG-024-02` proves concrete inclusion and clean omission matrices.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires final fixtures and GREEN execution.
- [ ] `T-BUG-024-03` proves material unknowns prevent writes.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires readiness-state fixture execution.
- [ ] `T-BUG-024-04` rejects each incomplete-content mutation independently.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Adversarial mutants have not been authored.
- [ ] `T-BUG-024-05` proves regression quality and zero bailout paths.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires the physical regression file.
- [ ] `T-BUG-024-06` proves install provenance.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires stable final source/test bytes.
- [ ] `T-BUG-024-07` proves broad framework compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Framework validation was not run.
- [ ] `T-BUG-024-08` proves release readiness and generated identity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Release validation follows stable canonical inputs.

The eight Test Plan rows have exactly eight matching test-related DoD items.
Both scenarios map to concrete rows in this file,
[scenario-manifest.json](scenario-manifest.json), and [test-plan.json](test-plan.json).

### Owner Route

`bubbles.design` is the immediate owner, followed by `bubbles.plan`,
`bubbles.test`, `bubbles.implement`, `bubbles.test`, `bubbles.releases`, and
`bubbles.validate`.
