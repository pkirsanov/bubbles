# Specification: BUG-045 - Non-empty scenario evidence references

## Problem

The scenario-manifest traceability cross-check distinguishes arrays from
non-arrays but does not distinguish an empty array from an array containing an
evidence reference. It can therefore claim complete evidence-reference coverage
when one or more scenario contracts name no evidence at all.

## Expected Behavior

### AC-1 - Evidence coverage requires positive cardinality

A scenario counts as carrying evidence references only when `evidenceRefs` is a
JSON array and its length is greater than zero.

### AC-2 - Empty arrays fail the manifest cross-check

If any in-scope scenario carries `evidenceRefs: []`, the guard must return a
non-zero exit and report that fewer than all scenario contracts carry evidence
references.

### AC-3 - Covered-count diagnostics are exact

For a manifest with two valid scenarios where one has a non-empty array and one
has an empty array, the diagnostic must report `only 1 of 2`. The check must not
collapse an empty reference into an absent scenario.

### AC-4 - Existing non-empty arrays remain accepted

A valid scenario whose `evidenceRefs` array contains at least one member must
continue to satisfy this cross-check. Existing linked-test, Test Plan, report,
and DoD traceability behavior must remain unchanged.

### AC-5 - Envelope compatibility remains unchanged

The guard must retain support for the canonical `object.scenarios[]` envelope
and the already-supported legacy top-level array. This bug does not authorize an
envelope migration.

## Non-Goals

- Validating whether a referenced report anchor exists.
- Defining whether a blank string inside a non-empty array is admissible.
- Changing the scenario-manifest JSON schema.
- Editing BUG-037 to manufacture a live failing instance.
- Changing traceability matching, linked-test projection, G068 DoD fidelity, or
  any release artifact.

Those are separate contracts. This bug closes only the zero-cardinality false
pass reported by `F-B037-GAPS-TRACEABILITY-EMPTY-REF-018`.

## Gherkin Scenarios

```gherkin
Feature: Scenario evidence-reference cardinality

  Scenario: SCN-B045-001 Empty evidence reference array is rejected
    Given a valid one-scenario feature with a linked test, Test Plan row, report evidence, and DoD mapping
    And the scenario manifest records evidenceRefs as an empty array
    When the production traceability guard evaluates the feature
    Then the guard exits non-zero
    And it reports evidenceRefs for only 0 of 1 scenario contracts

  Scenario: SCN-B045-002 Non-empty evidence reference array remains accepted
    Given the same valid one-scenario feature
    And the scenario manifest records one report evidence reference
    When the production traceability guard evaluates the feature
    Then the evidence-reference cross-check passes
    And the remaining traceability verdict is unchanged

  Scenario: SCN-B045-003 Mixed manifest reports the exact covered count
    Given a valid two-scenario feature
    And one scenario records one evidence reference
    And the other scenario records an empty evidence reference array
    When the production traceability guard evaluates the feature
    Then the guard exits non-zero
    And it reports evidenceRefs for only 1 of 2 scenario contracts
```

## Acceptance Criteria

- The pre-fix focused regression fails because the production guard returns 0
  for `SCN-B045-001`.
- The fixed guard returns non-zero for `SCN-B045-001` and `SCN-B045-003`.
- The existing non-empty-array control remains green.
- A mutation restoring the type-only predicate makes the new adversarial cases
  fail again.
- The focused selftest and bug-packet artifact lint pass.
- No file outside the declared work boundary changes.

## Workflow Contract

New operator input is `fix target:bug action:fastlane`. The registry resolves it
to `bugfix-fastlane`; `state.json.workflowMode` persists that compatibility key
for existing guards and transition readers.
