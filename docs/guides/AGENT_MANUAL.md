# <img src="../../icons/bubbles-glasses.svg" width="28"> Bubbles Agent Manual

This manual is a concise directory of agent ownership, primary use-cases, and source-of-truth module references.

Authoritative operating policy lives under `agents/bubbles_shared/`. This manual is derivative and intentionally brief.

## Start Here First

### bubbles.super

Use when you do not know which agent, mode, or sequence fits the task.

Primary references:
- `bubbles/workflows.yaml`
- `agents/bubbles_shared/agent-common.md`

Framework evolution packet:
- [Control Plane Design](CONTROL_PLANE_DESIGN.md)
- [Control Plane Rollout](CONTROL_PLANE_ROLLOUT.md)
- [Control Plane Schemas](CONTROL_PLANE_SCHEMAS.md)

## Ownership And Shared References

Artifact ownership:
- business requirements in `spec.md`: `bubbles.analyst`
- UX sections in `spec.md`: `bubbles.ux`
- `design.md`: `bubbles.design`
- planning structure in scopes/report/uservalidation/scenario manifest: `bubbles.plan`
- certification state in `state.json`: `bubbles.validate`
- managed docs declared in the effective managed-doc registry: `bubbles.docs`

Classified work packets:
- feature work lives under `specs/NNN-feature-name/`
- feature-bound bugs live under `specs/**/bugs/BUG-...`
- cross-cutting ops work lives under `specs/_ops/OPS-.../`
- ops packets use `objective.md` and `runbook.md` alongside `design.md`, `scopes.md`, `report.md`, and `state.json`

Shared governance index:
- `agents/bubbles_shared/agent-common.md`

Common source modules:
- `artifact-ownership.md`
- `completion-governance.md`
- `quality-gates.md`
- `artifact-lifecycle.md`
- `operating-baseline.md`
- `validation-core.md`
- `validation-profiles.md`
- `scope-workflow.md`
- `scope-templates.md`

## Orchestrators

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.workflow` | run end-to-end spec delivery or resume a workflow | `bubbles/workflows.yaml`, `scope-workflow.md`, `state-gates.md` |
| `bubbles.iterate` | pick the highest-priority next work slice inside an existing spec and drive one iteration through the right specialists | `scope-workflow.md`, `completion-governance.md`, `quality-gates.md` |
| `bubbles.bug` | investigate a bug, create bug artifacts, and dispatch the required fix workflow | `artifact-lifecycle.md`, `completion-governance.md`, `quality-gates.md` |

Orchestrator rule:
- orchestrators pick work and dispatch specialists or child workflows
- orchestrators do not implement fixes directly
- only orchestrators may invoke child workflows

## Owners And Executors

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.analyst` | define or improve business requirements and scenarios | `analysis-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.ux` | define wireframes, flows, and UX-specific spec content | `ux-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.design` | create or repair technical design | `design-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.plan` | break work into scopes, tests, DoD, and scenario contracts | `plan-bootstrap.md`, `planning-core.md`, `artifact-lifecycle.md`, `scope-templates.md` |
| `bubbles.implement` | implement a planned scope | `implement-bootstrap.md`, `execution-core.md`, `completion-governance.md`, `quality-gates.md` |
| `bubbles.test` | execute tests, close test gaps, and prove changed behavior | `test-bootstrap.md`, `test-core.md`, `quality-gates.md`, `test-fidelity.md` |
| `bubbles.docs` | publish managed docs for changed behavior and close out published truth | `docs-bootstrap.md`, `artifact-lifecycle.md`, `managed-docs.md` |
| `bubbles.chaos` | run resilience and breakage probes | `test-bootstrap.md`, `quality-gates.md` |
| `bubbles.simplify` | reduce over-engineering and simplify changed code | `implement-bootstrap.md`, `operating-baseline.md` |
| `bubbles.devops` | execute CI/CD, build, deployment, monitoring, and observability changes | `execution-ops.md`, `artifact-ownership.md`, `quality-gates.md` |

Owner/executor rule:
- only owners and execution specialists may modify their owned surfaces
- a finished run must leave behind owned artifact/code/test/evidence deltas or an explicit blocked state

## Diagnostic And Certification Routing

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.validate` | run validation, certify state transitions, reopen work with packets, and gate completion | `audit-bootstrap.md`, `quality-gates.md`, `state-gates.md` |
| `bubbles.audit` | run final compliance and evidence review and emit rework routing when needed | `audit-bootstrap.md`, `audit-core.md`, `quality-gates.md`, `completion-governance.md` |
| `bubbles.grill` | pressure-test ideas, plans, and workflow choices before committing effort | `artifact-ownership.md`, `planning-core.md`, `quality-gates.md` |
| `bubbles.clarify` | classify ambiguity, identify contradictions, and route artifact changes to the owning specialist | `clarify-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.gaps` | find missing behavior, tests, or scope coverage and emit owner-targeted packets | `quality-gates.md`, `artifact-lifecycle.md` |
| `bubbles.harden` | detect hardening issues and route stronger follow-up work | `quality-gates.md`, `artifact-lifecycle.md` |
| `bubbles.stabilize` | detect flakiness, environment instability, or reliability issues and route the correct owner | `quality-gates.md`, `execution-ops.md` |
| `bubbles.security` | run security-oriented findings and route secure follow-up work | `quality-gates.md`, `artifact-lifecycle.md` |
| `bubbles.regression` | detect cross-spec conflicts, test baseline regressions, coverage decreases, and design contradictions | `e2e-regression.md`, `quality-gates.md` |
| `bubbles.code-review` | run an engineering-only code review before deciding what to fix | `bubbles/code-review.yaml`, `artifact-ownership.md`, `quality-gates.md` |
| `bubbles.system-review` | run a holistic feature/component/system review before deciding what to spec, fix, or streamline | `bubbles/system-review.yaml`, `artifact-ownership.md`, `quality-gates.md` |
| `bubbles.spec-review` | audit specs for freshness and trust level without changing foreign-owned artifacts | read-only audit, trust classification |

Diagnostic/certification rule:
- these agents do not implement fixes directly
- they finish with `completed_diagnostic`, `route_required`, or `blocked`
- tiny fixes stay fast by going through orchestrator dispatch, not inline diagnostic edits

## Quality And Operations

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.setup` | set up or refresh framework-owned `.github` assets and project config guidance | `scope-templates.md`, `artifact-lifecycle.md` |
| `bubbles.cinematic-designer` | implement premium, high-polish UI output in real frontend code | prompt-specific guidance plus shared governance index |

## Utilities

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.status` | inspect spec/scope status without changing work | `state-gates.md`, `artifact-lifecycle.md` |
| `bubbles.handoff` | package session context for the next run | prompt-specific handoff format plus shared governance index |
| `bubbles.commands` | maintain command inventories and related framework command references | project-config and command docs |
| `bubbles.create-skill` | scaffold or update repo-local skills | skills guidance plus shared governance index |
| `bubbles.recap` | summarize current work, active state, and likely next steps without changing artifacts | prompt-specific recap guidance |

## Natural Language Input

All agents accept natural language descriptions. If the right agent or mode is unclear, start with `bubbles.super`.

## Workflow And Evidence

Workflow sequencing lives in `bubbles/workflows.yaml`.

Completion and evidence rules live in:
- `completion-governance.md`
- `quality-gates.md`
- `evidence-rules.md`

This manual should stay focused on ownership, use-cases, and where the real rules live.
