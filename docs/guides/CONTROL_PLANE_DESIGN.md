# Bubbles Control Plane Design

This document proposes the next-step architecture for Bubbles so delegation, state transitions, behavior contracts, and workflow modes are enforced by a machine-readable control plane instead of being scattered across prompt prose.

Related documents:
- [Control Plane Rollout](CONTROL_PLANE_ROLLOUT.md)
- [Control Plane Schemas](CONTROL_PLANE_SCHEMAS.md)
- [Workflow Modes](WORKFLOW_MODES.md)
- [Agent Manual](AGENT_MANUAL.md)

## Why This Change Exists

Bubbles already has strong specialist-agent boundaries, gate-driven workflows, state-transition checks, and optional tags such as `grillMode`, `tdd`, and `autoCommit`. The current framework still has four systemic weaknesses:

1. Delegation is described in prose more often than enforced through a registry.
2. State authority is fragmented across workflow, specialists, and guard scripts.
3. User-visible behavior contracts are tracked as prose Gherkin instead of stable machine-readable scenario identities.
4. Optional execution tags are not yet a first-class repo-level policy surface with default provenance.

The requested changes all point to the same architectural direction: Bubbles needs a real control plane.

## Design Goals

The target architecture must satisfy all of the following:

1. Every agent delegates work to the correct specialist whenever ownership crosses a specialist boundary.
2. Subagent execution returns durable work packets, not vague handoff prose.
3. Runtime defaults such as TDD, grill, auto-commit, and lockdown come from one mutable central policy source.
4. Completion state transitions are certified only by `bubbles.validate` after gates pass.
5. `bubbles.grill` can act as a bounded interactive interrogation gate when ambiguity matters.
6. Gherkin scenarios become strict, live-system, BDD-aligned acceptance contracts.
7. Lockdown behavior protects approved UI and behavior contracts from silent drift.
8. TDD becomes scenario-first by default where it materially reduces risk.
9. Bug and chaos follow-up flows default to TDD and persistent regression coverage.
10. Regression tests become protected behavior contracts that cannot drift without spec invalidation.
11. Every user-visible or externally observable behavior change must have explicit Gherkin and passing live-system BDD evidence.

## Non-Goals

This design does not propose:

- replacing specialist agents with a single super-agent
- moving product-code implementation into the workflow agent
- making `bubbles.validate` responsible for every transient execution field in `state.json`
- weakening existing ownership boundaries in `bubbles/agent-ownership.yaml`

## Architecture Overview

The new control plane has seven cooperating parts.

### 1. Agent Capability Registry

Bubbles already has a narrow ownership manifest in [bubbles/agent-ownership.yaml](../../bubbles/agent-ownership.yaml). That should evolve into a generated capability registry that answers four runtime questions:

1. Which agent owns this artifact or workflow phase?
2. Which state fields may this agent claim versus certify?
3. Which user interactions may this agent perform directly?
4. Which specialist must be invoked when work crosses ownership?

The registry should be generated from:
- agent frontmatter in `agents/bubbles.*.agent.md`
- `bubbles/agent-ownership.yaml`
- workflow phase definitions in `bubbles/workflows.yaml`

The registry is not just documentation. It becomes the runtime source for:
- workflow delegation
- illegal cross-owner write detection
- super-agent routing recommendations
- handoff-cycle validation

### 2. Execution Policy Registry

Bubbles already uses `.specify/memory/bubbles.config.json` for metrics toggles. That file should become the central mutable execution policy store for repo-local defaults.

`bubbles/workflows.yaml` remains the framework capability catalog and policy schema. The mutable repo-local defaults belong in `.specify/memory/bubbles.config.json` and must be managed by:
- `bubbles/scripts/cli.sh`
- `bubbles.super`

Policy examples:
- default TDD mode
- default grill mode
- default auto-commit mode
- lockdown defaults
- regression strictness
- whether validate certification is mandatory before any promotion
- whether bug and chaos flows force scenario-first red to green

Every workflow run must record a policy snapshot plus provenance for each active mode:
- `user-request`
- `repo-default`
- `workflow-forced`
- `spec-lockdown`

### 3. Validate-Owned Certification State

Current Bubbles guidance allows specialists to append their own phase completion metadata. That is useful for execution traceability but not strong enough for the stricter model requested here.

The control plane should split state into two layers:

- `execution`: transient claims and in-flight status written by the running workflow or specialist
- `certification`: authoritative promotion state written only by `bubbles.validate`

Examples:

Execution-owned fields:
- `currentPhase`
- `currentScope`
- `activeAgent`
- `runStartedAt`
- `pendingTransitionRequests`

Validate-certified fields:
- `status`
- `completedScopes`
- `certifiedCompletedPhases`
- `scopeProgress[*].status`
- `lockdownState`
- `invalidationLedger`

This preserves execution velocity while making promotion authority explicit.

### 4. Scenario Contract Manifest

Gherkin is the true behavior contract, but today it mostly lives in markdown. The framework needs a generated scenario manifest with stable scenario IDs.

Each scenario record should include:
- stable `scenarioId`
- owning spec and scope
- normalized Gherkin text hash
- whether it is new, changed, regression, bugfix, or lockdown-protected
- required live test type: `e2e-api` or `e2e-ui`
- linked test files and test identifiers
- last passing evidence references
- invalidation and replacement history

This makes the following enforceable:
- exact scenario-to-test mapping
- exact changed-behavior regression coverage
- immutable regression tests for non-invalidated scenarios
- lockdown protection at scenario granularity

### 5. Transition Request And Rework Packet Protocol

Subagent interactions must stop being purely narrative when they surface failed DoD, missing scenarios, or invalid state transitions.

Every specialist should return one of three structured outcomes:
- `completed`
- `route_required`
- `blocked`

If `route_required`, the result must include a machine-readable packet containing:
- target scope and DoD item
- target scenario IDs
- owning specialist
- required files or artifacts to touch
- required gates before the work can re-enter validation

If `bubbles.validate` reopens work, it should never just uncheck a box and stop. It must emit a rework packet tied to concrete scenarios, tests, and scope items. The workflow then routes the packet to the right owner and keeps running.

### 6. Grill Mode As An Interactive Ambiguity Gate

`bubbles.grill` should remain distinct from `bubbles.clarify`.

- `bubbles.clarify` repairs ambiguity inside artifacts.
- `bubbles.grill` pressure-tests assumptions and, when enabled, interrogates the user before irreversible design or behavior moves.

The control plane should support these grill modes:
- `off`
- `on-demand`
- `required-on-ambiguity`
- `required-for-lockdown`

`off` remains the framework default. The repo policy registry can elevate it.

### 7. Lockdown And Invalidation Model

Lockdown must operate on scenarios, not just broad spec status.

A locked scenario means:
- its linked BDD live-system tests are immutable without invalidation
- behavior and UI changes are blocked until user approval is captured through grill
- analyst-owned spec invalidation or replacement updates must exist before replacement tests are accepted
- validate must demote or invalidate certified completion before the replacement behavior can be promoted

This gives Bubbles a safe way to protect already-approved product behavior.

## Behavioral Laws

The control plane should enforce these framework laws.

### Delegation Law

If work crosses a registered ownership boundary, the current agent must delegate to the owning specialist. It may not quietly perform the foreign-owned action itself.

### Certification Law

Only `bubbles.validate` may certify completion state transitions such as:
- DoD item completed
- scope done
- spec done
- lockdown invalidated or re-certified

### Scenario Law

Every user-visible or externally observable behavior change must:
- exist as one or more Gherkin scenarios
- map to one or more live-system BDD tests
- pass those tests before certification

### Regression Law

Regression tests attached to a non-invalidated scenario are protected artifacts. They cannot be rewritten to fit new behavior until the spec and scenario contract are invalidated and replaced.

### TDD Law

When TDD is active, the required order is:
1. scenario exists
2. targeted failing proof exists
3. implementation changes
4. targeted proof goes green
5. broader regression stays green
6. validate certifies

For bug and chaos flows, this should become the default rather than an opt-in.

## Mapping The Requested Changes To The Design

| Requested Change | Design Response |
|---|---|
| 1. Always delegate to specialists | Agent capability registry plus a new delegation gate |
| 2. Subagents must not leave unfinished work | Structured transition and rework packets routed by workflow |
| 3. Central defaults and mode reporting | Execution policy registry in `.specify/memory/bubbles.config.json` with provenance recording |
| 4. Only validate changes spec state | Split execution state from validate-certified promotion state |
| 5. Grill mode for ambiguity/user confirmation | Grill mode with `required-on-ambiguity` and `required-for-lockdown` values |
| 6. Strict Gherkin-to-E2E validation | Scenario contract manifest plus live BDD enforcement |
| 7. Lockdown mode | Scenario-level lockdown plus invalidation ledger and grill confirmation |
| 8. Default TDD for changed Gherkin | Policy default for scenario-first red to green |
| 9. TDD main mode for bug/chaos | Mode-level forced TDD defaults for `bugfix-fastlane` and chaos follow-up |
| 10. Regression tests cannot drift without spec change | Scenario-linked regression contract protection |
| 11. All behavior changes need Gherkin and BDD E2E | Scenario law plus certification guard |

## Proposed New Gates

The current gate registry ends at G053. This design would add the following framework gates:

- `G054 capability_delegation_gate` — foreign-owned work must route through the registered specialist
- `G055 policy_provenance_gate` — active modes must record value plus source
- `G056 validate_certification_gate` — only validate may certify promotion state
- `G057 scenario_manifest_gate` — every changed behavior must resolve to stable scenario IDs and live tests
- `G058 lockdown_gate` — locked scenarios cannot change without approval and invalidation
- `G059 regression_contract_gate` — protected regression tests cannot drift without scenario invalidation
- `G060 scenario_tdd_gate` — when TDD is active, targeted red evidence must exist before green certification
- `G061 rework_packet_gate` — route-required findings must produce structured packets, not narrative-only handoffs

## Tradeoffs And Guardrails

### What Gets Better

- More deterministic agent behavior
- Less hidden cross-owner work
- Stronger auditability of why a mode was active
- Better preservation of approved behavior contracts
- Stronger regression discipline

### What Gets More Expensive

- More schema and generation logic
- More state-management complexity
- More explicit invalidation workflow for approved behavior changes
- Some additional friction when teams want to intentionally change locked behavior quickly

### Required Guardrail

Do not move everything into validate. Validate should certify promotion state and invalidation decisions, not become a giant universal executor.

## Recommended End State

Bubbles should operate as a policy-driven, registry-backed workflow system with these properties:
- specialist delegation is enforced
- workflow defaults are centrally managed
- scenario contracts are durable and machine-readable
- validate certifies completion and reopening
- lockdown protects approved behavior from silent drift
- bug and chaos default to scenario-first TDD
- regression suites act as spec-backed behavior contracts

That architecture satisfies the full requested direction without collapsing the current specialist model.