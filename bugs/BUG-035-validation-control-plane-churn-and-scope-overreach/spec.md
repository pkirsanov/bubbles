# BUG-035 Expected Behavior - Validation Control-Plane Convergence

## Outcome Contract

- **Intent:** Preserve Bubbles assurance while eliminating unnecessary replay,
  manual continuation, state reconciliation, and scope takeover.
- **Success Signal:** A bounded delivery reaches one evidence-backed assurance
  closure without repeated operator nudges or contradictory lifecycle state.
- **Hard Constraints:** High-risk validation remains fail closed. Independent
  certification remains validate-owned. Changed proof inputs invalidate reuse.
- **Failure Condition:** A compatible proof runs again without a reason, a
  routed finding takes over unrelated work, lifecycle facts disagree, or source
  bug files use an undeclared artifact form.

## Actors

- **Operator:** requests delivery and reviews the final assurance outcome.
- **Delivery agent:** implements and tests within the approved work boundary.
- **Validation agent:** independently certifies the resolved obligations.
- **Framework host:** persists receipts, rolls sessions over, and resumes work.

## User Scenarios

### Scenario 1 - Bounded continuation

```gherkin
Given a delivery session has accepted work and unresolved occurrences
When the session reaches its soft lifecycle boundary
Then Bubbles starts a continuation at the first unresolved occurrence
And the operator does not need to prompt it to continue
```

### Scenario 2 - Proof reuse

```gherkin
Given one proof passed for unchanged candidate, input, and environment identity
When another compatible assurance consumer needs that proof
Then the consumer reuses the accepted receipt
And it does not rerun the proof
```

### Scenario 3 - Atomic lifecycle truth

```gherkin
Given validation certifies a completed scope
When lifecycle state is persisted
Then one authoritative certification transaction is written
And every compatibility status is derived from it
```

### Scenario 4 - Boundary-aware finding routing

```gherkin
Given a check finds a defect outside the current work boundary
When the framework classifies its release impact
Then the defect routes to its owner
And it blocks the parent only when a named shared release floor applies
```

### Scenario 5 - Risk-proportional validation

```gherkin
Given a change has a resolved low risk tier
When Bubbles creates its validation plan
Then it selects focused proof and one aggregate release check
But high or unknown risk retains the full assurance chain
```

### Scenario 6 - Assurance closure

```gherkin
Given every resolved obligation passed on frozen inputs
When equivalent validation is requested again
Then Bubbles reuses the assurance closure
And it reruns work only after invalidation or for a stated reason
```

### Scenario 7 - Coherent source bug filing

```gherkin
Given the Bubbles source repository stores standalone root bug files
When the artifact contract validates a source bug
Then every required file comes from one canonical packet declaration
And the executable lint agrees with that declaration
```

### Scenario 8 - Stable payload closure

```gherkin
Given a managed scheduler invokes a source-only selftest through its self-only wrapper
When payload closure evaluates the unchanged scheduler repeatedly
Then every run accepts the guarded dependency
And a dependency materialized by the same fixture script is accepted
And an unguarded dependency remains refused
```

### Scenario 9 - Detached changed-only validation

```gherkin
Given validation runs from a detached revision newer than branch main
When the changed-only selftest creates its fixture baseline
Then the fixture starts from the exact detached revision
And committed and uncommitted closure selection still work
```

### Scenario 10 - Large-output assertions are stable

```gherkin
Given captured output contains the required diagnostic among many lines
When a selftest asserts that diagnostic under pipefail
Then the assertion passes deterministically
And a genuinely absent diagnostic still fails
```

### Scenario 11 - Performance failures distinguish contention from process work

```gherkin
Given the large-report guard check exceeds its wall-clock budget
When the selftest measures process-tree CPU time
Then sub-budget CPU reports host contention
But repeated wall-and-CPU budget breaches fail the regression
```

### Scenario 12 - Core-tier pattern matching is stable

```gherkin
Given the shipped validator has no dead core pattern
When the core-tier lint evaluates unchanged bytes repeatedly
Then every run passes
And a renamed core check still fails with the dead pattern named
```

### Scenario 13 - Downstream validation remains bounded by progress

```gherkin
Given installed-tree validation is producing output under host contention
And the caller CWD belongs to another repository
When its original fixed wall deadline passes
Then progress resets the idle deadline
And silence fails at the idle deadline
And endless output fails at the absolute deadline
And every downstream or transition gate resolves the installed or guarded repository root
And an unexplained nonzero child exit fails closed
```

### Scenario 14 - Evidence capture fails closed when output disappears

```gherkin
Given a command is running under the evidence capture wrapper
When another process removes the private capture output before finalization
Then the wrapper exits with a capture-integrity error
And it emits no blank hash or evidence-shaped success/failure block
```

## Functional Requirements

- **FR-B034-001:** The host must roll a bounded session over without changing
  the work outcome to blocked.
- **FR-B034-002:** Every assurance leaf must have a reusable execution receipt.
- **FR-B034-003:** Receipt reuse must depend on candidate, input, environment,
  and command identity.
- **FR-B034-004:** Validate must write lifecycle certification atomically.
- **FR-B034-005:** Compatibility lifecycle fields must be derived projections.
- **FR-B034-006:** Out-of-boundary findings must distinguish route-only from a
  shared release-floor refusal.
- **FR-B034-007:** Every mutable entry path must resolve risk before validation.
- **FR-B034-008:** An assurance closure must prevent equivalent replay.
- **FR-B034-009:** The bug-packet registry, template, and executable lint must
  agree on source packet forms and required files.
- **FR-B034-010:** Payload-closure classification must be deterministic on
  unchanged scheduler bytes.
- **FR-B034-011:** Changed-only fixtures must baseline from the exact revision
  under validation.
- **FR-B034-012:** Captured-output assertions must not use quiet terminal
  pipeline consumers under `pipefail`.
- **FR-B034-013:** Performance regression checks must distinguish one transient
  wall-only contention sample from reproducible wall-and-CPU slowness.
- **FR-B034-014:** Core-tier pattern matching must consume complete input under
  `pipefail`.
- **FR-B034-015:** Long nested validators must have separate idle-progress and
  absolute deadlines, suppress derivative checks on truncated output, and fail
  closed on unexplained nonzero exits.
- **FR-B034-016:** Evidence capture must use per-run namespaced storage and fail
  closed if output disappears before line counting or hashing.

## Success Criteria

- A rollover fixture completes with zero manual continuation prompts.
- A compatible second proof consumer performs zero test executions.
- A changed covering input invalidates only the affected receipts.
- Lifecycle state cannot persist contradictory authoritative facts.
- A route-only finding leaves the parent eligible to continue.
- A shared security or deployment floor still refuses promotion.
- Low-risk and high-risk fixtures resolve different validation plans.
- The source packet contract and artifact lint return the same required set.
- Repeated payload-closure runs return one verdict.
- Changed-only validation passes from branch and detached worktrees.
- Large-output assertions return one verdict for unchanged text.
- Wall-only contention passes, while repeat wall-and-CPU slowness fails.
- Repeated core-tier lint runs return one verdict on unchanged bytes.
- Active downstream progress can exceed one hour, while silence and endless
  output remain bounded and unexplained nonzero exits fail.
- Capture-file loss exits loudly and never emits an empty evidence hash.