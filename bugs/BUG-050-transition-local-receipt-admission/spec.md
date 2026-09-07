# BUG-050 Expected Behavior - Transition-Local Receipt Admission

## Outcome Contract

- **Intent:** Let only actively admitted evidence vote on one transition.
- **Success Signal:** Unrelated history is inert, while stale or cloned admitted evidence still blocks.
- **Hard Constraints:** Logs remain append-only. RED and mutation proof retain historical semantics. BUG-033 protections remain active.
- **Failure Condition:** Unrelated history blocks, admitted bad evidence passes, or historical proof is invalidated by current source bytes.

## Actors

- **Evidence producer:** appends tool and mutation receipts.
- **Scenario resolver:** derives scenario states from semantically bound receipts.
- **Transition guard:** validates only evidence admitted for the target transition.
- **Validation agent:** certifies after active evidence passes every applicable check.

## User Scenarios

### Scenario 1 - Unrelated stale history is inert

```gherkin
Given the active transition admits only fresh receipts
And the repository log contains stale receipts for unrelated packets
When Check 43 evaluates staleness
Then the active transition is not blocked by those unrelated receipts
And the historical rows remain in the append-only log
```

### Scenario 2 - An actively admitted stale receipt blocks

```gherkin
Given the active transition admits a receipt whose current input closure changed
When Check 43 evaluates staleness
Then it blocks the transition and names that admitted receipt
```

### Scenario 3 - Unrelated clone groups are inert

```gherkin
Given the active transition admits no incompatible clone group
And unrelated history contains incompatible command identities with one output hash
When Check 43 evaluates clone reuse
Then the unrelated group does not block this transition
```

### Scenario 4 - An actively admitted incompatible clone blocks

```gherkin
Given two receipts admitted for the active transition reuse one substantive output across incompatible identities
When Check 43 evaluates clone reuse
Then the transition is blocked
And the diagnostic preserves BUG-033 identity detail
```

### Scenario 5 - Historical RED proof remains valid

```gherkin
Given a bound RED receipt failed before implementation
And implementation later changed its owning production source
When scenario state is derived for the same test and negative control
Then the RED receipt remains valid historical ordering proof
And current GREEN evidence still requires current source compatibility
```

### Scenario 6 - Historical mutation proof remains valid

```gherkin
Given a mutation receipt proves a killed mutant and restored source bytes
And production source later changes for the fix
When mutation proof is checked for the scenario
Then the killed-mutant receipt remains valid historical sensitivity proof
And restoration integrity is still enforced
```

## Functional Requirements

- **FR-B050-001:** Transition admission must be resolved before staleness or clone adjudication.
- **FR-B050-002:** The admitted set must derive from explicit scenario, claim, command, outcome, and phase bindings.
- **FR-B050-003:** Check 43 must pass only admitted receipts to freshness analysis.
- **FR-B050-004:** Check 43 must pass only admitted receipts to clone analysis.
- **FR-B050-005:** Unrelated append-only history must remain queryable and non-blocking.
- **FR-B050-006:** An admitted stale input closure must remain blocking.
- **FR-B050-007:** An admitted incompatible clone must remain blocking.
- **FR-B050-008:** RED evidence must preserve before-implementation historical semantics.
- **FR-B050-009:** GREEN, live, regression, and observed evidence must retain current compatibility requirements.
- **FR-B050-010:** Mutation proof must validate the mutant, failure signature, isolation, and restoration against its captured source.
- **FR-B050-011:** Mutation proof must not require captured source bytes to equal current production bytes.
- **FR-B050-012:** BUG-033 wrapper, target, program, and execution-provenance protections must remain active.
- **FR-B050-013:** No tool-log deletion, bypass, ignore, or unsafe fallback is permitted.

## Acceptance Criteria

- SCN-B050-001 passes with unrelated stale history still present.
- SCN-B050-002 blocks one stale receipt admitted by the transition.
- SCN-B050-003 passes with unrelated clone history still present.
- SCN-B050-004 blocks one admitted incompatible clone group.
- SCN-B050-005 derives RED without current-source equality and requires current GREEN proof.
- SCN-B050-006 accepts a valid historical killed-mutant receipt and rejects failed restoration.
- Every BUG-033 receipt-identity regression retains its verdict.
