# Scopes: BUG-045 - Traceability accepts empty evidence reference arrays

Layout: single-file. One implementation scope.

## Scope 1: Reject empty evidence reference arrays

**Status:** In Progress
**Depends on:** none
**Evidence file:** [report.md](report.md)

### Objective

Make the production traceability guard distinguish an empty `evidenceRefs` array
from a non-empty array, with a focused adversarial selftest and no change outside
the guard, its owning selftest, and this packet.

### Gherkin Scenarios

```gherkin
Feature: Scenario evidence-reference cardinality

  Scenario: SCN-B045-001 Empty evidence reference array is rejected
    Given a valid one-scenario feature with every other traceability edge present
    And its scenario manifest records evidenceRefs as an empty array
    When traceability-guard.sh evaluates the feature
    Then the guard exits non-zero
    And it reports evidenceRefs for only 0 of 1 scenario contracts

  Scenario: SCN-B045-002 Non-empty evidence reference array remains accepted
    Given the canonical clean one-scenario fixture
    And its scenario manifest records one report evidence reference
    When traceability-guard.sh evaluates the feature
    Then the evidence-reference cross-check passes
    And the full focused selftest remains green

  Scenario: SCN-B045-003 Mixed manifest reports the exact covered count
    Given a valid two-scenario feature
    And exactly one scenario records a non-empty evidenceRefs array
    When traceability-guard.sh evaluates the feature
    Then the guard exits non-zero
    And it reports evidenceRefs for only 1 of 2 scenario contracts
```

### Implementation Plan

1. Extend the existing jq selector in `traceability-guard.sh` with a positive
   array-length condition.
2. Add one empty-array adversarial case to
   `traceability-guard-selftest.sh` using the existing clean fixture builder.
3. Add a mixed two-scenario exact-count case to the same selftest.
4. Keep the existing non-empty-array case as the positive control.
5. Run the focused selftest, a type-only mutation, and artifact lint.
6. Verify only the three allowed path groups changed.

### Test Plan

| ID | Scenario | Type | Category | File/Location | Command | Expected | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| B045-T1 | SCN-B045-001 | Functional regression | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `bash bubbles/scripts/traceability-guard-selftest.sh` | Empty-array case expects non-zero guard result and exact `only 0 of 1` diagnostic | No |
| B045-T2 | SCN-B045-002 | Unit control | unit | `bubbles/scripts/traceability-guard-selftest.sh` | `bash bubbles/scripts/traceability-guard-selftest.sh` | Existing non-empty-array case remains green | No |
| B045-T3 | SCN-B045-003 | Regression E2E (CLI) | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `bash bubbles/scripts/traceability-guard-selftest.sh` | Public CLI path rejects the mixed manifest and reports `only 1 of 2` | No |
| B045-T4 | Mutation control | Mutation | functional | `bubbles/scripts/traceability-guard-selftest.sh` | Restore the type-only predicate, then run `bash bubbles/scripts/traceability-guard-selftest.sh` | New assertions fail; positive control remains green; mutation is reverted by edit | No |
| B045-T5 | Packet | Artifact lint | unit | `bubbles/scripts/artifact-lint.sh` | `bash bubbles/scripts/artifact-lint.sh bugs/BUG-045-traceability-empty-evidence-refs` | Exit 0 | No |

No integration service, HTTP API, rendered UI, mutable store, latency contract,
or deploy path exists for this CLI parser. The full public CLI invocation in
B045-T3 is the end-to-end regression for this behavior; inventing a live stack
would not exercise a different production dependency.

### Implementation Progress

**Phase:** implement
**Claim Source:** executed

The one-line production predicate, empty-array regression, mixed-array exact
count regression, and non-empty control are implemented. Focused RED, GREEN,
type-only mutation, direct-fixture, artifact, scenario-obligation, and
test-mechanism evidence is recorded in `report.md`.

The scope remains `In Progress`. Current packet traceability passes G068 with
all 3 scenario IDs mapped to current DoD items. Existing test-owned evidence
supports the 9 checked items below. The 2 lifecycle and terminal-validation
items remain unchecked. The required `implement` phase claim is still missing
and is routed to `bubbles.implement`; no checkbox or scope status advances in
this planning reconciliation.

### Definition of Done

- [x] Root cause confirmed and documented → Evidence: [Independent predicate and provenance](report.md#independent-predicate-and-provenance)
- [x] Fix implemented in `bubbles/scripts/traceability-guard.sh` → Evidence: [Independent predicate and provenance](report.md#independent-predicate-and-provenance)
- [x] `SCN-B045-001`: the production guard rejects a valid one-scenario manifest with `evidenceRefs: []`, exits non-zero, and reports `only 0 of 1` → Evidence: [Independent direct scenario matrix](report.md#independent-direct-scenario-matrix)
- [x] `SCN-B045-002`: the same valid one-scenario fixture with one report evidence reference passes the evidence-reference cross-check and preserves the remaining traceability verdict → Evidence: [Independent direct scenario matrix](report.md#independent-direct-scenario-matrix)
- [x] `SCN-B045-003`: the production guard rejects a valid two-scenario mixed manifest, exits non-zero, and reports `only 1 of 2` → Evidence: [Independent direct scenario matrix](report.md#independent-direct-scenario-matrix)
- [x] Mutation and non-vacuity proof restores the type-only predicate, makes the empty-array and mixed-array assertions fail while the non-empty positive control remains green, then restores the current guard bytes → Evidence: [Independent mutation non-vacuity](report.md#independent-mutation-non-vacuity)
- [x] The focused selftest passes with zero failed assertions and no skip, bailout, or silent-pass path → Evidence: [Independent focused suite and test quality](report.md#independent-focused-suite-and-test-quality)
- [x] Bug-packet artifact lint passes → Evidence: [Independent packet gates](report.md#independent-packet-gates)
- [x] The change boundary contains only this packet, `bubbles/scripts/traceability-guard.sh`, and `bubbles/scripts/traceability-guard-selftest.sh`; every excluded path remains unchanged → Evidence: [Independent change boundary](report.md#independent-change-boundary)
- [ ] Bug marked Fixed only after source repair and post-fix evidence
  > **Uncertainty Declaration**
  > **What was attempted:** Read the current bug lifecycle after source repair and independent test execution.
  > **What was observed:** `bug.md` remains Confirmed; this test invocation did not alter the bug-owned lifecycle checklist.
  > **Why this is uncertain:** The lifecycle marker is not a test-owned surface, so test evidence cannot perform that artifact write.
  > **What would resolve this:** The owning lifecycle phase marks Fixed using the source and independent regression evidence recorded in `report.md`.
- [ ] `bubbles.validate` owns any terminal certification
  > **Uncertainty Declaration**
  > **What was attempted:** No certification command was run, as required by the packet boundary.
  > **What was observed:** Top-level and certification statuses remain `in_progress`, with no completed certified scope.
  > **Why this is uncertain:** Only `bubbles.validate` may write or establish terminal certification.
  > **What would resolve this:** Validate-owned certification runs after the required regression phase and evaluates the unchanged terminal fields.

G068 maps all 3 scenarios to current DoD items. Existing test-owned evidence
supports 9 checked items, while the 2 remaining lifecycle and terminal-
validation items stay unchecked. The `implement` phase claim remains absent and
is routed to `bubbles.implement` before any scope-status or certification
transition.
