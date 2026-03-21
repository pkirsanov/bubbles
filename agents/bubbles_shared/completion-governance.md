# Completion Governance

Use this file for the authoritative completion chain and completion-state rules.

## Absolute Completion Hierarchy

Completion flows bottom-up only:

1. A DoD item is implemented.
2. The item is validated with a real command or tool run.
3. Raw evidence is recorded inline.
4. Only then may the item be marked `[x]`.
5. A scope is `Done` only when every DoD item is `[x]` with real evidence.
6. A spec is `done` only when every scope is `Done`.

If any link in that chain is false, completion state must be lowered immediately.

## Per-DoD Validation Rules

- Each DoD item requires its own validation and its own evidence.
- Batch-checking multiple items from one generic run is invalid.
- Evidence must be current-session raw output with recognizable terminal or tool signals.
- If execution fails, the item remains `[ ]` until fixed and re-run.

## Scope Completion Rules

A scope cannot be `Done` when any of these are true:

- any DoD item is unchecked
- any checked DoD item lacks inline evidence
- required test types have not run
- evidence shows failure
- the scope contains deferral language
- the scope claims behavior that the tests do not prove

## Spec Completion Rules

A spec cannot be `done` when any scope is:

- `Not Started`
- `In Progress`
- `Blocked`

`state.json` must reflect the lower truth immediately when artifacts and status disagree.

## Deferral Is Incomplete Work

The following are blocking completion signals in scope artifacts:

- `deferred`
- `future work`
- `follow-up`
- `out of scope`
- `address later`
- `separate ticket`
- `placeholder`
- `temporary workaround`

If deferred work is still required, the scope stays in progress.

## Red-Green Traceability

For new or changed behavior:

1. show the failing or missing state first when applicable
2. implement the fix or behavior
3. show the passing targeted proof
4. run the broader impacted regression coverage

Tests and fixes must trace back to planned behavior in `spec.md`, `design.md`, `scopes.md`, and DoD.

## Consumer Trace Requirement

When work renames, removes, moves, replaces, or deprecates any public or internal interface, completion also requires:

- inventory of producers and consumers
- updates to all first-party consumers
- stale-reference search for old identifiers or paths
- regression coverage for the affected consumer flows

If consumer trace is incomplete, the work stays `in_progress`.

## Scope Size Discipline

Scopes are small by default:

- one primary outcome per scope
- one coherent validation story per scope
- DoD items small enough to validate individually

Split scopes when they mix unrelated journeys, unrelated validation paths, or more than one independent outcome.

## Micro-Fix Containment

When a failure is narrow, the repair loop must stay narrow:

1. start with the smallest failing unit
2. fix the exact failure
3. rerun the narrowest relevant check first
4. widen only after the local fix is proven

## Live-Stack Authenticity

Tests labeled `integration`, `e2e-api`, or `e2e-ui` must use the real stack.

If a test uses interception or canned backend behavior, it is mocked and must be reclassified. A mocked test cannot satisfy live-stack DoD items.

## Execution Depth Requirement

Handlers, routes, endpoints, or workflow steps are incomplete if they only return shaped placeholder success.

Real implementation requires real delegation, query, command, or upstream execution. Literal placeholder payloads are blocking implementation-reality failures.

## State Claim Integrity

`state.json` is derived state, never aspirational state.

- `status` must match artifact reality
- `completedScopes` must match actual done scopes
- `completedPhases` must not get ahead of actual completed work

If state is stale, lower it immediately.