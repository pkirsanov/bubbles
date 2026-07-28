# Normalized Record Submission

## Outcome Contract

Intent: Let a caller submit a raw record without knowing storage details.
Success Signal: The normalized record is persisted and returned to the caller.
Hard Constraints: Invalid records never mutate the persisted collection.
Failure Condition: A valid record disappears or an invalid record is stored.

## Scenarios

```gherkin
Scenario: Persist a valid normalized record
Given a caller supplies a valid raw record
When the caller submits the record for normalization
Then the normalized record is persisted and returned
```
