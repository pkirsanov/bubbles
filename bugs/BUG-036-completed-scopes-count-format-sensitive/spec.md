# BUG-036 Expected Behavior - Structured Completed-Scope Counting

## Outcome Contract

- **Intent:** Make Check 5 count completed scopes from parsed JSON.
- **Success Signal:** Equivalent JSON arrays always produce the same count.
- **Hard Constraints:** Phantom-scope validation and certification ownership
  remain unchanged. Invalid JSON still fails through existing integrity checks.
- **Failure Condition:** Whitespace or line breaks alter a valid string-ID
  completed-scope count, or an invalid ordinal loses its type-specific refusal.

## Actors

- **Delivery agent:** records completed scope claims.
- **Validation agent:** certifies completed scope claims.
- **Transition guard:** compares certification state with scope artifacts.

## User Scenarios

### Scenario 1 - Compact string entries count individually

```gherkin
Given state.json records three quoted completed scope IDs on one physical line
And three corresponding scope artifacts are Done
When the transition guard evaluates Check 5
Then it counts three completed scopes
```

### Scenario 2 - Ordinal entries retain a type-specific refusal

```gherkin
Given state.json records completed scopes as integer ordinals
When the transition guard evaluates Check 5
Then it reports that entries are not string scope IDs
And it does not report the populated array empty
```

### Scenario 3 - Certification array has precedence

```gherkin
Given certification.completedScopes is an array
And a legacy top-level completedScopes array also exists
When the transition guard evaluates Check 5
Then it uses certification.completedScopes
```

### Scenario 4 - Phantom identifiers still fail

```gherkin
Given completedScopes names an identifier with no matching scope artifact
When the transition guard evaluates scope integrity
Then the guard reports the phantom scope
```

## Functional Requirements

- **FR-B035-001:** Check 5 must parse `state.json` through a structured JSON
  interface.
- **FR-B035-002:** The count must equal the selected array length.
- **FR-B035-003:** `certification.completedScopes` must take precedence when it
  is an array.
- **FR-B035-004:** A legacy top-level array must remain readable when the
  certification array is absent.
- **FR-B035-005:** Missing arrays must count as zero.
- **FR-B035-006:** Check 5C must continue to reject phantom identifiers.
- **FR-B035-007:** Non-string entries must retain a wrong-element-type refusal.

## Success Criteria

- Compact `["SCOPE-1","SCOPE-2","SCOPE-3"]` produces count three.
- Integer ordinals remain refused as non-string identifiers.
- Existing positive and phantom-scope fixtures retain their verdicts.
- Full framework validation and release readiness pass.