# Scopes: BUG-025 Skills-First Map Merged Rows

## Scope Inventory

| # | Scope | Depends On | Status |
| --- | --- | --- | --- |
| 1 | Skills-First Map Structural Integrity | None | In Progress |

## Scope 1: Skills-First Map Structural Integrity

**Status:** In Progress
**Depends On:** None
**Foundation:** false
**Scope-Kind:** framework-discovery-contract

### Gherkin Scenarios

#### SCN-BUG-025-001: Four independent situations resolve to four valid map rows

```gherkin
Scenario: SCN-BUG-025-001 Four independent situations resolve to four valid map rows
  Given the canonical skills-first discovery map
  When the structural parser reads every physical data row
  Then scope authoring, feature-folder creation, fix-cycle work, and skill authoring are four independent situations
  And each row has exactly two nonempty cells
  And every referenced skill target resolves to an existing skill
```

#### SCN-BUG-025-002: Malformed or ambiguous map entries fail closed

```gherkin
Scenario: SCN-BUG-025-002 Malformed or ambiguous map entries fail closed
  Given fixtures with a merged row, duplicate situation, unknown target, or missing separator
  When the structural parser validates each fixture independently
  Then each invalid fixture fails with its specific invariant
  And the canonical valid control passes without dropping any mapping
```

### Current Invocation Change Boundary

This invocation creates only the nine packet files under
`improvements/BUG-025-skills-first-map-merged-rows/`. It does not edit the
skills-first source, tests, generated manifests, `BUGS.md`,
`improvements/INDEX.md`, Git history, or downstream repositories.

### Authorized Delivery Boundary By Owner

| Owner | Surface | Exact permission |
| --- | --- | --- |
| `bubbles.design` | `design.md` | Reconcile parser boundaries and multi-target syntax. |
| `bubbles.plan` | Planning-owned packet artifacts | Reconcile scenario, test, and DoD contracts. |
| `bubbles.test` | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Final-byte RED/GREEN and complete structural fixture matrix. |
| `bubbles.implement` | `skills/bubbles-skills-first-discovery/SKILL.md` | Split exactly two malformed lines into four rows. |
| `bubbles.test` | Registration/provenance surfaces | Register source-only regression after GREEN. |
| `bubbles.releases` | Generated release identity | Reconcile stable final bytes. |
| `bubbles.validate` | Certification and terminal state | Independent certification only. |

### Implementation Plan

1. Freeze final parser-regression bytes and prove both current merged lines
   fail row cardinality before source edits.
2. Split only the two malformed physical lines into four canonical rows.
3. Prove all other mappings and target order remain byte-equivalent.
4. Run identical parser bytes over canonical source and every independent
   cardinality, duplicate, unknown-target, separator, and multi-target fixture.
5. Complete provenance, framework, release, and validate-owned checks in owner
   order.

### Test Plan

The machine-readable twin is [test-plan.json](test-plan.json).

| Test Type | Test ID | Scenarios | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mandatory pre-fix RED | T-BUG-025-01 | SCN-BUG-025-001, SCN-BUG-025-002 | functional | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Final test bytes reject both current merged physical rows. | `bash tests/regression/test_32_skills_first_map_merged_rows.sh` | No |
| Canonical row and target parity | T-BUG-025-02 | SCN-BUG-025-001 | functional | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Canonical source has exact two-cell rows, four independent named situations, and resolvable targets. | `bash tests/regression/test_32_skills_first_map_merged_rows.sh` | No |
| Cardinality and separator fixtures | T-BUG-025-03 | SCN-BUG-025-002 | functional | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Merged, extra-cell, and missing-separator fixtures fail specifically. | `bash tests/regression/test_32_skills_first_map_merged_rows.sh` | No |
| Duplicate and target fixtures | T-BUG-025-04 | SCN-BUG-025-002 | functional | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Duplicate situations, unknown targets, and duplicate row targets fail; valid multi-target row passes. | `bash tests/regression/test_32_skills_first_map_merged_rows.sh` | No |
| Adversarial source mutations | T-BUG-025-05 | SCN-BUG-025-001, SCN-BUG-025-002 | functional | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Each repaired line is re-merged independently and rejected without canonical mutation. | `bash tests/regression/test_32_skills_first_map_merged_rows.sh` | No |
| Regression quality | T-BUG-025-06 | SCN-BUG-025-001, SCN-BUG-025-002 | functional | `bubbles/scripts/regression-quality-guard.sh` | Regression has adversarial signals and no bailout paths. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_32_skills_first_map_merged_rows.sh` | No |
| Install provenance | T-BUG-025-07 | SCN-BUG-025-001, SCN-BUG-025-002 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Managed discovery skill and source-only regression retain correct provenance. | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| Framework regression | T-BUG-025-08 | SCN-BUG-025-001, SCN-BUG-025-002 | integration | `bubbles/scripts/cli.sh` | Full framework validation preserves skills-first and unrelated contracts. | `bash bubbles/scripts/cli.sh framework-validate` | No |
| Release readiness | T-BUG-025-09 | SCN-BUG-025-001, SCN-BUG-025-002 | integration | `bubbles/scripts/cli.sh` | Generated release identity matches final skill and regression bytes. | `bash bubbles/scripts/cli.sh release-check` | No |

### Definition of Done - Core Outcomes

- [ ] The two malformed source lines are split into exactly four independent
  two-column rows with all wording, targets, order, and unrelated bytes preserved.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Source changes are outside this intake and
    require final-byte RED plus `bubbles.implement`.
- [ ] `SCN-BUG-025-001` passes with exact row cardinality, four independent
  named situations, and resolution of every target skill.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The parser regression has not been authored.
- [ ] `SCN-BUG-025-002` rejects merged rows, duplicate situations, unknown or
  duplicate targets, extra cells, and missing separators while accepting a
  valid multi-target row.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Fixture execution remains test-owned.
- [ ] Delivery containment is limited to the one skill, one source-only
  regression, focused registration/provenance, and generated release identity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Containment requires the eventual owner-scoped diff.
- [ ] Validate-owned certification agrees with packet, test, and release evidence.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Certification remains intentionally open.

### Definition of Done - Test Plan Parity

- [ ] `T-BUG-025-01` records causal pre-fix RED using final regression bytes.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** No test command was run during packet creation.
- [ ] `T-BUG-025-02` proves canonical row, situation, and target parity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires repaired source and GREEN execution.
- [ ] `T-BUG-025-03` rejects row-cardinality and separator defects.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Structural fixtures have not been executed.
- [ ] `T-BUG-025-04` rejects duplicate/unknown targets and duplicate situations.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Target-resolution fixtures are not yet authored.
- [ ] `T-BUG-025-05` rejects independent re-merging of both repaired rows.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Adversarial source mutations remain test-owned.
- [ ] `T-BUG-025-06` proves regression quality and zero bailout paths.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires the physical regression file.
- [ ] `T-BUG-025-07` proves install provenance.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires stable final source/test bytes.
- [ ] `T-BUG-025-08` proves broad framework compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Framework validation was not run.
- [ ] `T-BUG-025-09` proves release readiness and generated identity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Release validation follows stable canonical inputs.

The nine Test Plan rows have exactly nine matching test-related DoD items. Both
scenarios map to concrete rows in this file,
[scenario-manifest.json](scenario-manifest.json), and [test-plan.json](test-plan.json).

### Owner Route

`bubbles.design` is the immediate owner, followed by `bubbles.plan`,
`bubbles.test`, `bubbles.implement`, `bubbles.test`, `bubbles.releases`, and
`bubbles.validate`.
