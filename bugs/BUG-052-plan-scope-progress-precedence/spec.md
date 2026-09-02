# BUG-052 Expected Behavior - Canonical Scope Progress Precedence

## Outcome Contract

- **Intent:** Evaluate plan depth from the strict version 3 scope progress authority.
- **Success Signal:** Canonical certification data controls the verdict when legacy fields coexist.
- **Hard Constraints:** Top-level scope progress remains an absent-canonical fallback. Execution data never becomes authority.
- **Failure Condition:** A deprecated or execution field shadows canonical certification data.

## Actors

- **Plan author:** records a per-scope dependency graph.
- **Certification control plane:** owns canonical `certification.scopeProgress`.
- **Plan dependency-depth guard:** evaluates the canonical graph under project posture.

## User Scenarios

### Scenario 1 - Empty legacy field cannot shadow canonical depth

```gherkin
Given top-level scopeProgress is an empty array
And certification.scopeProgress contains an over-depth consumer graph
When the plan dependency-depth guard runs under block posture
Then it blocks the horizontal plan
```

### Scenario 2 - Canonical shallow graph wins over legacy deep graph

```gherkin
Given certification.scopeProgress contains an early usable consumer
And deprecated top-level scopeProgress contains an over-depth graph
When the plan dependency-depth guard runs
Then it evaluates the canonical graph and passes
```

### Scenario 3 - Legacy top-level graph remains a compatibility fallback

```gherkin
Given certification.scopeProgress is absent
And top-level scopeProgress contains an over-depth consumer graph
When the plan dependency-depth guard runs under block posture
Then it blocks using the legacy fallback
```

### Scenario 4 - Execution scope progress is not authority

```gherkin
Given certification.scopeProgress contains an early usable consumer
And execution.scopeProgress contains a conflicting over-depth graph
When the plan dependency-depth guard selects its graph
Then it evaluates certification.scopeProgress without substituting execution data
```

## Functional Requirements

- **FR-B052-001:** `certification.scopeProgress` must be the first authority for strict version 3 state.
- **FR-B052-002:** Top-level `scopeProgress` must be read only when the canonical field is absent or null.
- **FR-B052-003:** An empty top-level array must not shadow a present canonical array.
- **FR-B052-004:** A present canonical empty array must remain authoritative over deprecated data.
- **FR-B052-005:** `execution.scopeProgress` must not enter the authority selection chain.
- **FR-B052-006:** A legacy top-level-only per-scope array must retain compatibility behavior.
- **FR-B052-007:** Object and malformed-array no-op protections must retain their current behavior.

## Acceptance Criteria

- SCN-B052-001 exits 1 under block posture.
- SCN-B052-002 exits 0 from the canonical shallow graph.
- SCN-B052-003 exits 1 through the legacy fallback.
- SCN-B052-004 proves execution data cannot replace certification data.
- Existing dependency graph depth and type-safety cases retain their verdicts.