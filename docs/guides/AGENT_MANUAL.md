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
- planning structure in scopes/report/uservalidation: `bubbles.plan`

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
| `bubbles.code-review` | run an engineering-only code review before deciding what to fix | `bubbles/code-review.yaml`, `artifact-ownership.md`, `quality-gates.md` |
| `bubbles.system-review` | run a holistic feature/component/system review before deciding what to spec, fix, or streamline | `bubbles/system-review.yaml`, `artifact-ownership.md`, `quality-gates.md` |

## Specialists

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.implement` | implement a planned scope | `implement-bootstrap.md`, `execution-core.md`, `completion-governance.md`, `quality-gates.md` |
| `bubbles.test` | execute tests, close test gaps, and prove changed behavior | `test-bootstrap.md`, `test-core.md`, `quality-gates.md`, `test-fidelity.md` |
| `bubbles.docs` | update docs for changed behavior | `docs-bootstrap.md`, `artifact-lifecycle.md` |
| `bubbles.validate` | run validation and gate checks | `audit-bootstrap.md`, `quality-gates.md`, `state-gates.md` |
| `bubbles.audit` | run final compliance and evidence review | `audit-bootstrap.md`, `audit-core.md`, `quality-gates.md`, `completion-governance.md` |
| `bubbles.chaos` | run resilience and breakage probes | `test-bootstrap.md`, `quality-gates.md` |

## Planning And Design

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.analyst` | define or improve business requirements and scenarios | `analysis-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.ux` | define wireframes, flows, and UX-specific spec content | `ux-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.design` | create or repair technical design | `design-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.plan` | break work into scopes, tests, and DoD | `plan-bootstrap.md`, `planning-core.md`, `artifact-lifecycle.md`, `scope-templates.md` |
| `bubbles.grill` | pressure-test ideas, plans, and workflow choices before committing effort | `artifact-ownership.md`, `planning-core.md`, `quality-gates.md` |
| `bubbles.clarify` | classify ambiguity, identify contradictions, and route artifact changes to the owning specialist | `clarify-bootstrap.md`, `artifact-ownership.md` |
| `bubbles.harden` | turn findings into stronger scope/test/design follow-up | `quality-gates.md`, `artifact-lifecycle.md` |
| `bubbles.gaps` | find missing behavior, tests, or scope coverage | `quality-gates.md`, `artifact-lifecycle.md` |

## Quality And Operations

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.setup` | set up or refresh framework-owned `.github` assets and project config guidance | `scope-templates.md`, `artifact-lifecycle.md` |
| `bubbles.stabilize` | fix flakiness, environment instability, or infrastructure reliability issues | `quality-gates.md`, `execution-ops.md` |
| `bubbles.security` | run security-oriented findings and follow-up | `quality-gates.md`, `artifact-lifecycle.md` |
| `bubbles.simplify` | reduce over-engineering and simplify changed code | `implement-bootstrap.md`, `operating-baseline.md` |
| `bubbles.spec-review` | audit specs for freshness — check if artifacts still match code reality | read-only audit, trust classification |
| `bubbles.regression` | detect cross-spec conflicts, test baseline regressions, coverage decreases, and design contradictions | `e2e-regression.md`, `quality-gates.md` |
| `bubbles.cinematic-designer` | implement premium, high-polish UI output in real frontend code | prompt-specific guidance plus shared governance index |

## Utilities

| Agent | Use When | Primary References |
|------|----------|--------------------|
| `bubbles.status` | inspect spec/scope status without changing work | `state-gates.md`, `artifact-lifecycle.md` |
| `bubbles.handoff` | package session context for the next run | prompt-specific handoff format plus shared governance index |
| `bubbles.commands` | maintain command inventories and related framework command references | project-config and command docs |
| `bubbles.create-skill` | scaffold or update repo-local skills | skills guidance plus shared governance index |
| `bubbles.bug` | investigate and fix a bug through reproduction, root cause, and verification | bug artifacts, `completion-governance.md`, `quality-gates.md` |

## Natural Language Input

All agents accept natural language descriptions. If the right agent or mode is unclear, start with `bubbles.super`.

## Workflow And Evidence

Workflow sequencing lives in `bubbles/workflows.yaml`.

Completion and evidence rules live in:
- `completion-governance.md`
- `quality-gates.md`
- `evidence-rules.md`

This manual should stay focused on ownership, use-cases, and where the real rules live.
