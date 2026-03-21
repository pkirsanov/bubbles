# Quality Gates

Use this file for test taxonomy, evidence, anti-fabrication, and completion-gate expectations.

## Canonical Test Taxonomy

Use these categories based on execution reality:

- `unit`
- `functional`
- `integration`
- `ui-unit`
- `e2e-api`
- `e2e-ui`
- `stress`
- `load`

Do not label mocked tests as live-stack categories.

## Real Implementation And No-Mock Reality

- production code must not rely on stubs, fake data, or placeholder responses
- tests must not mock internal business logic or internal repositories for live-system categories
- real test storage must be used where the category requires it

## Execution Evidence Standard

Pass/fail claims require actual executed evidence.

Minimum bar:

- current-session execution
- raw output
- real exit status or tool result
- enough output to verify what actually happened

Summaries are not evidence.

## Anti-Fabrication Rules

Block completion when any of these occur:

- claims without execution
- fabricated files, commands, or results
- placeholder or template evidence
- fake green status from skipped or noop tests
- stale state claiming more completion than artifacts support

## Test Execution Gate

Before claiming completion for implementation work:

- all required test categories must run
- failures must be fixed, not deferred
- regression coverage must exist for changed behavior
- skipped or proxy tests must be treated as failures for required behavior

## Sequential Completion

Specs and scopes complete in order. Do not advance later required work while earlier required work remains incomplete.

## Cross-Agent Output Verification

When one agent depends on another agent’s result, the downstream agent must verify the result rather than trust an unverified claim.

## Live-State Fixture Ownership

- Any agent that writes to a live stack must provision or identify dedicated owned fixtures before mutation.
- Listing existing entities and mutating the first result is a blocking shared-state violation for write paths.
- Shared defaults, inherited configs, host/global settings, and other baseline records must be treated as protected state.
- Protected-state mutations require baseline capture plus verified restore or explicit isolated fixture scoping.

## Mutation Remediation Gate

- Exploratory or stochastic runs cannot stop at report-only while the runtime state they mutated remains broken.
- If an agent-created or agent-mutated state exposes a blocking failure, the agent must either restore the pre-run baseline or route the issue into the required fix cycle and leave status in progress.
- Cleanup or restore failures are blocking validation failures, not informational notes.

## Specialist Completion Chain

Modes that require specialist phases are not complete until all required specialist phases have actually executed and their outputs satisfy the required gates.

## Phase-Scope Coherence

`completedPhases` and `completedScopes` must agree with the actual scope files and the actual work performed.

## Implementation Reality Scan

Implemented artifacts must show real execution depth and real consumers where applicable. Placeholder handlers, dead libraries, or unwired surfaces are blocking failures.

## Integration Completeness

Every implemented artifact must be wired into the running system with at least one real consumer or an explicit documented external-only contract.

## Vertical Slice Completeness

For cross-layer work, frontend calls, gateway routing, backend handlers, and persistent behavior must line up end-to-end. Partial cross-layer delivery is not complete.

## Design Readiness Before Implementation

Implementation cannot outrun missing or contradictory design intent. If required business or design artifacts are absent or inconsistent, route to the owning specialist first.

## Findings Artifact Update Protocol

When hardening, gaps, security, or audit work discovers missing work, scope artifacts must be updated so downstream agents have executable follow-up items.

## Cross-Artifact Coherence

`spec.md`, `design.md`, `scopes.md`, `report.md`, `uservalidation.md`, and `state.json` must not contradict each other.

## Quality Work Standards

- no stubs
- no TODO completion claims
- no deferred mandatory work
- no warnings treated as success
- no fake or shallow testing for required behavior

## Fabrication Termination Protocol

When fabrication or equivalent invalid completion behavior is detected:

1. fail the current gate
2. lower completion state immediately
3. record the violation
4. re-run only after real remediation

## Mandatory Completion Checkpoint

Before any final completion claim, confirm:

- artifact state is coherent
- test and evidence gates are satisfied
- no required live-stack gaps remain
- no fabricated, deferred, or contradictory claims remain