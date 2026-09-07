# BUG-047 Expected Behavior - Reasoned Skip Phase Accounting

## Outcome Contract

- **Intent:** Make canonical reasoned skips valid phase outcomes without calling them completed work.
- **Success Signal:** One canonical skip clears required-phase accounting and zero-duration plausibility checks.
- **Hard Constraints:** Executed nontrivial zero-duration phases remain blocked. Skips never enter `completedPhaseClaims`.
- **Failure Condition:** A valid skip is missing, completed, or fabricated according to any transition check.

## Actors

- **Workflow runner:** obtains a phase relevance verdict and records the decision.
- **Transition guard:** verifies required phase outcomes and execution plausibility.
- **Validation agent:** certifies only after the guard accepts the complete record.

## User Scenarios

### Scenario 1 - A canonical skip satisfies required-phase accounting

```gherkin
Given a required phase has a canonical executionHistory skip record
And the record names its reason and evaluated changed surface
When Check 6 evaluates required phase outcomes
Then the phase is accounted for
And no completed phase claim is required
```

### Scenario 2 - A skip decision may be instantaneous

```gherkin
Given an authorized skip record has equal start and completion instants
And the record satisfies the canonical skip schema
When Check 7A evaluates timestamp plausibility
Then the record is not classified as executed zero-duration work
And the transition emits no fabrication finding for that record
```

### Scenario 3 - An executed nontrivial phase remains protected

```gherkin
Given a nontrivial phase records an executed outcome
And its start and completion instants are equal
When Check 7A evaluates timestamp plausibility
Then the guard reports the zero-duration execution
```

### Scenario 4 - An incomplete skip never satisfies accounting

```gherkin
Given a phase history record says skipped without a substantive reason
When the transition guard evaluates the required phase
Then the phase remains missing or invalid
And the malformed record gains no exemption
```

## Functional Requirements

- **FR-B047-001:** Required-phase accounting must consume canonical skipped history.
- **FR-B047-002:** A skip must satisfy the registry's complete decision-record schema.
- **FR-B047-003:** A skip must never become a completed or certified phase claim.
- **FR-B047-004:** Check 7A must distinguish a decision record from executed work.
- **FR-B047-005:** Equal timestamps are valid only for a complete authorized skip decision.
- **FR-B047-006:** Executed nontrivial zero-duration phases must remain blocking.
- **FR-B047-007:** Re-evaluated skips must retain the trigger required by the registry.
- **FR-B047-008:** Malformed, reasonless, or unknown skip records must fail closed.

## Acceptance Criteria

- SCN-B047-001 passes with a skip only in `executionHistory`.
- SCN-B047-002 passes with an intentional zero-duration skip decision.
- SCN-B047-003 blocks an executed zero-duration `stabilize` phase.
- SCN-B047-004 blocks a reasonless skip.
- Existing Check 6 and Check 7A regressions retain their verdicts.
