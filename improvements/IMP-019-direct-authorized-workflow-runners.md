# IMP-019 — Direct Authorized Workflow Runners

**Status:** APPLIED in v7.19.0; downstream doctor hardening shipped in v7.19.1-v7.19.2 on 2026-07-09
**Surface:** framework control plane, agent routing, workflow execution, documentation, and downstream installer payload
**Verified gaps addressed:** WRA1 (goal/workflow responsibility overlap), WRA2 (runner-to-runner subagent deadlock), WRA3 (no per-agent mode grants), WRA4 (public guidance named the wrong universal endpoint)

## Problem

- `bubbles.goal` and `bubbles.workflow` both accepted broad natural-language outcomes, resolved modes, dispatched specialists, remediated findings, and ran to completion. Their public boundaries were not defensible.
- `bubbles.goal` preferred `runSubagent(bubbles.workflow)`, while `bubbles.sprint` preferred `runSubagent(bubbles.goal)`. VS Code subagents cannot create another subagent, so the nested runner could not dispatch the specialists required by its mode.
- The fallback waited for that guaranteed failed hop and then asked the parent to expand the mode. Correctness depended on recognizing a missing-tool envelope after wasting a dispatch.
- `canInvokeChildWorkflows: true` was a coarse boolean. It could not express that `bubbles.bug` may run `bugfix-fastlane`, `bubbles.releases` may run `release-planning-to-doc`, or train/upkeep/propagation agents may run only their own mode families.
- README, recipes, super guidance, the Markdown cheat sheet, and the HTML cheat sheet all called `bubbles.workflow` the universal endpoint even though `bubbles.goal` already provided the broader outcome abstraction.

## Decision

### Goal

`bubbles.goal` is the universal one-outcome endpoint. It may execute zero, one, or several authorized workflow modes and invoke specialist phase owners until the requested outcome converges or reaches a real blocker.

### Workflow

`bubbles.workflow` is a deterministic single-mode runner. It accepts exactly one explicit `mode:` or one mode resolved by `bubbles.super`. It does not decompose broad goals, build timed queues, or execute meta modes owned by goal, sprint, or iterate.

### Sprint

`bubbles.sprint` is a time-bounded queue of goals. It applies the goal execution contract directly in the active sprint runtime; it never invokes `bubbles.goal` as a subagent.

### Domain runners

Domain orchestrators may execute only their declared mode families. Initial grants cover workflow, goal, sprint, iterate, bug, releases, train, upkeep, propagation, stabilize, retro, and journey.

### Runtime model

Workflow execution is top-level and default-deny. The active runner resolves the mode, checks `workflowModeGrants`, invokes specialist phase owners directly, and records `executionModel: direct-authorized-runner`. Workflow-running orchestrators never invoke one another as subagents. Envelope-only resolution (`bubbles.super`) and picker-only selection (`bubbles.iterate`) remain safe subagent operations.

## Mechanical Enforcement

- `bubbles/workflows.yaml::workflowExecutionPolicy` declares top-level direct execution, the grant source, control-phase ownership, and meta-mode owners.
- `bubbles/agent-capabilities.yaml::workflowModeGrants` is the default-deny grant registry.
- Gate G064 is renamed in place to `workflow_runner_authorization_gate`.
- `workflow-runner-grants-lint.sh` rejects unknown modes, missing grants, non-orchestrator runners, intent routes targeting ungranted modes, bad meta-mode owners, an invalid workflow root-mode limit, and positive nested-runner dispatch patterns.
- Its hermetic selftest includes clean and adversarial fixtures for every failure family.
- Framework validation and state-transition validation run the new lint.
- Historical `parent-expanded` execution-history records remain readable as legacy compatibility, but new execution cannot produce that model.

## Public Contract

- `/bubbles.goal <outcome>` — universal one-outcome endpoint
- `/bubbles.workflow <target> mode: <mode>` — exactly one workflow mode
- `/bubbles.sprint minutes: <N>` — several goals under a time budget
- `/bubbles.super <question>` — resolution and framework operations, no product-workflow execution
- `/bubbles.<domain-runner>` — only modes granted to that domain

README, agent manual, workflow-mode guide, effective-prompting guide, recipes, catalog, super knowledge, TPB vocabulary, Markdown cheat sheet, HTML cheat sheet, capability ledger, and generated competitive docs must all state this same model.

## Acceptance Criteria

- Focused delegation, grant, finding-closure, spec-review, fan-out, ownership, intent-route, and state-transition selftests pass.
- No active agent or governance module prescribes runner-to-runner `runSubagent` execution or parent-expanded fallback.
- `workflowModeGrants` is default-deny and every super intent route with a mode targets a granted runner.
- `bubbles.workflow` allows one root mode and excludes `autonomous-goal`, `autonomous-sprint`, and `iterate`.
- Domain runner grants contain no unknown modes.
- README, docs, recipes, generated Markdown/HTML cheat sheets, and TPB vocabulary contain no stale `bubbles.workflow` universal-entry or child-workflow-depth claims.
- Full `framework-validate` and `release-check` complete successfully before commit.
- The framework commit is pushed before downstream upgrades; each downstream is upgraded through its own installed Bubbles CLI without touching product-owned work.

## Files To Touch

Control plane and enforcement: `bubbles/workflows.yaml`, `bubbles/workflows/modes.yaml`, `bubbles/agent-capabilities.yaml`, `bubbles/registry/gates.yaml`, grant/ownership/state-transition scripts and selftests.

Agent contracts: workflow, goal, sprint, iterate, bug, releases, train, upkeep, propagate, stabilize, retro, journey, super, spec-review, and shared workflow modules.

Public surfaces: README, guides, recipes, catalog, cheat-sheet JSON, Markdown cheat sheet, HTML cheat sheet, capability ledger/generated docs, changelog, release manifest, and framework stats.