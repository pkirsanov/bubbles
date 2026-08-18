# BUG-036 Scopes

## Scope 1 - Structured Completed-Scope Count

**Status:** Not Started

### Gherkin Scenarios

```gherkin
Scenario: SCN-B036-001 Compact string array counts every entry
  Given three Done scopes and a compact three-string completedScopes array
  When Check 5 runs
  Then the guard reports a matching count of three

Scenario: SCN-B036-002 Ordinal arrays remain a type error
  Given completedScopes contains integer ordinals
  When Check 5 runs
  Then the guard reports entries are not string scope IDs
    And it does not report the populated array empty

Scenario: SCN-B036-003 Certification state takes precedence
  Given both certification and legacy completedScopes arrays
  When Check 5 runs
  Then it counts the certification array

Scenario: SCN-B036-004 Phantom scope protection remains active
  Given a completed scope identifier with no matching artifact
  When the scope integrity checks run
  Then the transition remains refused as a phantom scope
```

### Implementation Plan

- Add the compact string-array fixture before changing production code.
- Capture the failing red output.
- Replace the line-oriented count with a structured array-length query.
- Re-run the same fixture and existing phantom-scope fixture.
- Run the broad guard selftest and full framework validation.
- Regenerate the release manifest through the canonical generator.

### Test Plan

| ID | Test | Type | Surface |
| --- | --- | --- | --- |
| T1 | Compact three-string array fails before and passes after the fix | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T2 | Ordinal array remains a distinct wrong-element-type failure | regression | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T3 | Certification array takes precedence over legacy state | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T4 | Phantom-scope negative remains refused | regression | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T5 | Regression E2E - full framework suite preserves all guard behavior | functional | `bubbles/scripts/cli.sh framework-validate` |

### Definition of Done

- [ ] Failing compact-array reproduction is captured before the production fix.
- [ ] Structured count returns the selected JSON array length.
- [ ] Compact-array and ordinal-type scenarios pass after the fix.
- [ ] Certification-first and legacy compatibility scenarios pass.
- [ ] Phantom-scope adversarial protection remains active.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
- [ ] Broader E2E regression suite passes
- [ ] Release manifest is regenerated from the validated source tree.
- [ ] bubbles.validate certifies the packet transition.