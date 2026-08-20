<p align="center">
  <img src="icons/bubbles-glasses.svg" width="120" height="120" alt="Bubbles">
</p>

<h1 align="center"><img src="icons/bubbles-glasses.svg" width="32" height="32"> Bubbles</h1>

<p align="center">
  <strong>AI Agent Orchestration System for VS Code Copilot</strong><br>
  <em>"It ain't rocket appliances, but it works."</em>
</p>

<p align="center">
  <!-- GENERATED:FRAMEWORK_STATS_BADGES_START -->
  <img src="https://img.shields.io/badge/agents-41-58a6ff?style=flat-square" alt="41 agents">
  <img src="https://img.shields.io/badge/gates-120-3fb950?style=flat-square" alt="120 gates">
  <img src="https://img.shields.io/badge/workflow_modes-15_primitives_%2B_46_aliases-bc8cff?style=flat-square" alt="15 primitive modes (+46 v5 aliases)">
  <!-- GENERATED:FRAMEWORK_STATS_BADGES_END -->
  <img src="https://img.shields.io/badge/fabrication_tolerance-zero-f85149?style=flat-square" alt="zero fabrication">
  <img src="https://img.shields.io/badge/license-MIT-d29922?style=flat-square" alt="MIT">
</p>

<p align="center">
  <a href="https://pkirsanov.github.io/bubbles/docs/its-not-rocket-appliances.html"><strong>Visual Cheatsheet</strong></a> · <a href="docs/CHEATSHEET.md">Markdown Cheatsheet</a> · <a href="docs/guides/EFFECTIVE_PROMPTING.md">Effective Prompting</a> · <a href="docs/guides/AGENT_MANUAL.md">Agent Manual</a> · <a href="docs/CATALOG.md">Recipe Catalog</a> · <a href="docs/recipes/">Recipes</a>
</p>

---

## What Is This?

**AI coding agents lie. They mark work "done" that's broken, paste test output that never ran, and ship stubs as features — and you find out in production.**

Bubbles is the supervisor that won't let them. One command turns a plain request into a full delivery pipeline — analyze → build → test → audit — where **nothing is marked done without real, captured evidence.** No fabricated results. No half-finished work. No "trust me."

You describe the outcome. Bubbles drives a crew of specialized agents to it, gates every step against proof, and stops only when the work genuinely holds up.

```
/bubbles.goal  ship the booking feature — competitive, tested, and done for real
```

Stop babysitting your AI. Put it on the clock.

## Why It's Different: Mechanical Certification Integrity

Plenty of tools *ask* an AI to "be thorough." Bubbles is different because "done" is a **mechanically enforced verdict, not a claim.** The moat is a guard chain that treats fabricated progress as the default failure mode and refuses to let it through:

- **Evidence gates** — a Definition-of-Done item that asserts an execution outcome must carry raw, captured command output (real exit codes, real test counts). A narrative "all tests pass" with no terminal output is rejected as fabrication, not accepted as proof. Items that assert something other than an execution outcome — a design decision, a documentation change — are held to the same ≥10-line evidence standard but may satisfy it in prose.
- **Adversarial fixtures** — a bug fix's regression test must include a case that *fails if the bug comes back*. Tautological tests, silent-pass early-returns, and mock-swapped "live" tests are caught and refused.
- **The anti-fabrication guard chain** — heuristics scan for the tells of invented evidence (sub-10-line blocks, verbatim templates, batch-checked items, copy-pasted output) and revert the work to `in_progress` when they fire.
- **The state-transition guard** — the single mechanical gate between `in_progress` and `done`. It re-derives DoD completeness, scope status, and evidence provenance from the artifacts themselves; if the proof doesn't hold, the transition is refused — there is no override flag.

That is the genuine differentiator: not that Bubbles *tells* your AI to do good work, but that it **cannot mark work done until the proof mechanically holds up.**

## How It Works

Bubbles is a **spec-driven AI agent orchestration system** for VS Code Copilot Chat. It turns your `/` slash commands into a full software delivery pipeline — from business analysis to implementation to testing to audit — with zero tolerance for fabricated work, plus a control plane that tracks certification authority, scenario contracts, workflow run-state, typed framework events, runtime lease safety, and framework-level validation.

**One outcome endpoint. Just describe what you want:**

```
/bubbles.goal  improve the booking feature to be competitive
/bubbles.goal  fix the calendar bug
/bubbles.goal  continue
/bubbles.sprint  minutes: 120 goals: fix calendar; improve booking; validate release
```

Goal resolves the outcome and may execute zero, one, or several workflows plus direct specialist work. Use `/bubbles.workflow` when you want exactly one explicit or super-resolved mode, and `/bubbles.sprint` for several goals under a time budget.

Think of it as a trailer park supervisor for your codebase. Except this one actually works.

<table>
<!-- GENERATED:FRAMEWORK_STATS_CALLOUTS_START -->
<tr><td width="64"><img src="icons/bubbles-glasses.svg" width="48"></td><td><strong>41 specialized agents</strong> — each with a defined role, from implementation to framework ops</td></tr>
<tr><td width="64"><img src="icons/lahey-badge.svg" width="48"></td><td><strong>120 quality gates</strong> — nothing ships without evidence. Nothing.</td></tr>
<tr><td width="64"><img src="icons/julian-glass.svg" width="48"></td><td><strong>15 primitive workflow modes</strong> — plus 46 v5 aliases retained as registry keys — from full delivery to quick bugfixes to chaos sweeps</td></tr>
<!-- GENERATED:FRAMEWORK_STATS_CALLOUTS_END -->
<tr><td width="64"><img src="icons/barb-keys.svg" width="48"></td><td><strong>Optional execution tags</strong> — opt into grilling, inner-loop TDD, backlog export, Socratic discovery, git isolation, atomic commits, scope sizing, and micro-fix loops without weakening baseline planning gates</td></tr>
<tr><td width="64"><img src="icons/lahey-badge.svg" width="48"></td><td><strong>Framework ops surface</strong> — health checks, framework validation, release hygiene, runtime coordination, and optional repo-readiness guidance live behind `bubbles.super` and the CLI</td></tr>
</table>

---

## Install

One command. Installing needs only `curl` and `bash` **4.0+**.

Running the full validation surface additionally needs `git`, `python3`, and the
Python packages `PyYAML` and `jsonschema`. These are not optional niceties: ten
guards (schema validation, the receipt bridge, the registry generators) refuse to
run without them rather than reporting a green result for a check that never
executed. `bash bubbles/scripts/cli.sh doctor` reports the dependency posture.

Provision those Python packages once, reproducibly:

```bash
bash bubbles/scripts/python-env.sh --provision   # create/repair the managed env
bash bubbles/scripts/python-env.sh --check       # report posture
```

This builds a virtualenv from the pinned `bubbles/requirements.txt` under
`~/.cache/bubbles/python` (override with `BUBBLES_PYTHON_HOME`). Because the
virtualenv owns its own interpreter, it keeps satisfying even when `PATH` later
changes — which matters on machines carrying several `python3` installs, where
`command -v python3` is not a stable identity. The guards resolve it
automatically; nothing needs to be activated by hand.

Prefer your own interpreter? Point `BUBBLES_PYTHON` at it, or just install the
packages into the `python3` already on `PATH` — a satisfying `PATH` interpreter
is used as-is and never overridden. Do **not** reach for
`pip install --break-system-packages` or a virtualenv under `/tmp`: both are
undone by the next `PATH` change or reboot and leave no reproducible record.

**Supported platforms:** VS Code + GitHub Copilot Chat (required). Works on macOS, Linux, and WSL2 (bash 4.0+ — on macOS install a newer bash with `brew install bash`, since stock `/bin/bash` is 3.2). No Windows CMD/PowerShell support.

**Source repo note:** these installer commands are for downstream project repos. Do not run `install.sh` inside the Bubbles source repository itself; maintainers should edit the framework directly and validate with `bash bubbles/scripts/cli.sh framework-validate` or `bash bubbles/scripts/cli.sh release-check`. The Bubbles source repo also does not keep persistent `specs/` packets for its own work; durable behavior belongs in docs, scripts, agents, workflows, generated manifests, and release notes.

```bash
# Install shared Bubbles framework files
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash

# Install agents only (skip shared instructions and skills)
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --agents-only

# Install + scaffold project config (recommended for new projects)
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap

# Bootstrap with explicit project name and CLI
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap --cli ./myproject.sh --name "My Project"
```

Pin to a version:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/v1.0.0/install.sh | bash -s -- --bootstrap
```

Update:

```bash
# Same command. It overwrites the shared files, leaves your project config alone.
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash
```

### What `--bootstrap` Does

With `--bootstrap`, the installer goes beyond the shared framework files and scaffolds a fully working project setup:

1. **Auto-detects** your project name (from git/directory) and CLI entrypoint (`*.sh` in root)
2. **Creates** all required project-specific config files (if they don't already exist):
   - `.github/copilot-instructions.md` — project policies, commands, testing config
   - `.github/instructions/terminal-discipline.instructions.md` — CLI discipline rules
   - `.specify/memory/constitution.md` — project governance principles
   - `.specify/memory/agents.md` — command registry (agents resolve all commands from here)
  - `.specify/memory/bubbles.config.json` — control-plane defaults registry
  - `.specify/memory/.gitignore` + `.specify/metrics/.gitignore` + `.specify/runtime/.gitignore` — keep runtime profile/proposal/metrics/lease artifacts untracked
3. **Creates** the `specs/` directory for feature/bug specs
4. **Never overwrites** existing files — safe to re-run

Runtime-generated control-plane artifacts are created on demand and should remain untracked:
- `.specify/memory/developer-profile.md`
- `.specify/memory/skill-proposals.md`
- `.specify/memory/skill-proposals-dismissed.md`
- `.specify/metrics/*.jsonl`
- `.specify/runtime/resource-leases.json`
- `.specify/runtime/workflow-runs.json`
- `.specify/runtime/framework-events.jsonl`

After bootstrap, update the `TODO` items in the generated files, then start using agents.

### What Gets Installed (default shared install)

```
.github/
├── agents/
<!-- GENERATED:FRAMEWORK_STATS_INSTALL_TREE_START -->
│   ├── bubbles.workflow.agent.md    # 41 agent definitions
│   ├── bubbles.implement.agent.md
│   ├── bubbles.super.agent.md       # NEW: first-touch assistant + framework operations
│   ├── ...
│   └── bubbles_shared/              # Shared governance docs
│       ├── agent-common.md
│       ├── scope-workflow.md
│       └── ...
├── prompts/
│   └── bubbles.*.prompt.md          # 41 prompt shims
├── bubbles/
│   ├── workflows.yaml               # 61 workflow mode definitions
│   ├── scripts/                     # Governance scripts
│   │   ├── cli.sh                   # Main CLI
│   │   ├── artifact-lint.sh
│   │   ├── state-transition-guard.sh
│   │   └── ...
│   └── docs/                        # Generated docs
└── scripts/
    └── bubbles.sh                   # CLI shim (dispatches to bubbles/scripts/cli.sh)
<!-- GENERATED:FRAMEWORK_STATS_INSTALL_TREE_END -->
```

Use `--agents-only` if you want to skip the portable shared instructions and governance skills.

### What `--bootstrap` Adds (project-specific)

```
.github/
├── copilot-instructions.md              # Project policies & commands
├── instructions/
│   └── terminal-discipline.instructions.md  # CLI discipline
.specify/memory/
├── constitution.md                      # Project governance
└── agents.md                            # Command registry
specs/                                   # Feature/bug spec folders
```

---

## The Crew

<p align="center">
  <img src="pictures/bazaar_v5_agent_icons_presentation.svg" width="900" alt="Bubbles Agent Network Presentation Layout">
</p>

Every agent has a job. Start with `/bubbles.goal` for an outcome, `/bubbles.workflow` for one known workflow mode, `/bubbles.sprint` for timed multi-goal work, or `/bubbles.super` when you want resolution and framework advice without execution.

### Artifact Ownership

Bubbles now enforces hard artifact ownership:

- `bubbles.analyst` owns business requirements in `spec.md`
- `bubbles.ux` owns UX sections inside `spec.md`
- `bubbles.design` owns `design.md`
- `bubbles.plan` owns `scopes.md`, `report.md` structure, `uservalidation.md`, and `scenario-manifest.json`
- `bubbles.validate` owns certification state in `state.json`
- `bubbles.docs` owns the managed docs declared in the effective managed-doc registry (framework defaults plus any project-owned overrides)
- Diagnostic and certification agents like `bubbles.validate`, `bubbles.audit`, `bubbles.harden`, `bubbles.gaps`, `bubbles.stabilize`, `bubbles.security`, `bubbles.regression`, `bubbles.clarify`, `bubbles.code-review`, and `bubbles.system-review` must route foreign-artifact changes to the owning specialist instead of editing those artifacts directly

Control-plane law:
- Orchestrators dispatch work and keep it moving; they do not implement fixes directly.
- Workflow execution is default-deny: only agents listed in `workflowModeGrants` may run modes.
- An authorized top-level runner interprets the mode and invokes specialist phase owners directly. Workflow-running orchestrators never invoke one another as subagents.
- Repository-sensitive front doors commit one canonical work repository before local state, target expansion, `specs/` discovery, repository commands, or specialist dispatch. Explicit target intent outranks the same-session durable boundary; only a true single-repository inventory may auto-bind.
- A mode-only invocation is `TARGETLESS_MODE`, not repository authority. Multi-root ambiguity refuses, and local actionable packets are distinct from redacted non-actionable public projections.
- Owners and execution specialists produce concrete code, test, doc, or artifact deltas.
- Diagnostic and certification agents finish with concrete result envelopes and owner-targeted packets instead of inline remediation.

This is enforced by the artifact ownership contract in `agents/bubbles_shared/artifact-ownership.md`, the shared governance index in `agents/bubbles_shared/agent-common.md`, the ownership manifest in `bubbles/agent-ownership.yaml`, and the blocking `artifact_ownership_enforcement_gate` in `bubbles/workflows.yaml`.

### Managed Docs And Ops Packets

- Published docs owned by Bubbles are declared in the effective managed-doc registry. Framework defaults live in `bubbles/docs-registry.yaml`, and project-owned overrides may live in `.github/bubbles-project.yaml`.
- Feature and bug packets remain execution truth while work is active; managed docs are the published truth.
- Cross-cutting infrastructure and operational delivery work lives under `specs/_ops/OPS-*`.
- Ops packets use `objective.md`, `design.md`, `scopes.md`, `runbook.md`, `report.md`, and `state.json`.

### Planning Maturity Is Not Delivery

Transition audits derive their target and evidence profile from the resolved
workflow registry contract. Only `product-to-planning` and
`spec-scope-hardening` bind `planning-maturity-v1`; both stop exactly at
`specs_hardened`. A clean `PLANNING_AUDIT_CLEAN` result means the applicable
planning and universal checks passed while delivery remains
`NOT_EVALUATED`. It does not mean implemented, tested, merge-ready, releasable,
deployable, delivered, or shipped.

Done-ceiling modes use the separate `delivery-completion-v1` contract and keep
the strict completion/evidence bar. Other non-done modes do not inherit
planning semantics merely because their ceiling is below `done`; they remain
unsupported by transition audit unless the registry explicitly binds a
profile. See the [Agent Manual](docs/guides/AGENT_MANUAL.md#registry-bound-transition-audits),
[Control Plane Design](docs/guides/CONTROL_PLANE_DESIGN.md#registry-bound-transition-audit-contract),
and [Framework Operations](docs/recipes/framework-ops.md#inspect-and-operate-transition-audits).

### <img src="icons/bubbles-glasses.svg" width="24"> Start Here — Universal Goal Endpoint

| Icon | Agent | Role | When to Use |
|:----:|-------|------|-------------|
| <img src="icons/tyrone-chain.svg" width="20"> | `bubbles.goal` | **Universal goal endpoint.** Achieves one outcome through any required workflows and specialist agents, looping until convergence or a real blocker. | **Default for plain-English outcomes.** |
| <img src="icons/bubbles-glasses.svg" width="20"> | `bubbles.workflow` | **Single-mode workflow runner.** Executes exactly one explicit `mode:` or one mode resolved by `bubbles.super`. | Deterministic control over one workflow |
| <img src="icons/lahey-badge.svg" width="20"> | `bubbles.super` | **Resolver & framework concierge.** Selects the authorized runner, mode, command, or framework action; does not execute product workflows. | Framework operations and routing advice |

### <img src="icons/jacob-hardhat.svg" width="24"> Orchestrators

| Icon | Agent | Role | When to Use |
|:----:|-------|------|-------------|
| <img src="icons/erica-doublestack.svg" width="20"> | `bubbles.sprint` | **Autonomous sprint controller.** Give it multiple goals + a time budget. Prioritizes, executes each via convergence loop, manages the clock, stops gracefully. | You have a backlog and a deadline |
| <img src="icons/jacob-hardhat.svg" width="20"> | `bubbles.iterate` | **Work picker.** Selects the highest-priority next slice and runs one iteration. Also accepts plain English via `super` delegation. | Continuing existing spec work without choosing phases by hand |
| <img src="icons/cory-cap.svg" width="20"> | `bubbles.bug` | **Bug orchestrator.** Reproduces, packets, routes, and drives the fix workflow until the defect is actually closed. | Investigating and routing bug work end to end |

Granted domain runners include `bubbles.releases`, `bubbles.train`, `bubbles.upkeep`, `bubbles.propagate`, `bubbles.stabilize`, `bubbles.retro`, and `bubbles.journey`. Each may execute only its declared mode family; when invoked as a phase owner, it performs only that phase.

### <img src="icons/julian-glass.svg" width="24"> Owners And Executors

| Icon | Agent | Role | When to Use |
|:----:|-------|------|-------------|
| <img src="icons/ray-lawnchair.svg" width="20"> | `bubbles.analyst` | **Business analyst.** Figures out the *why* behind requirements. | Starting new features |
| <img src="icons/lucy-mirror.svg" width="20"> | `bubbles.ux` | **UX designer.** Cares about how things feel and look. | UI/UX design work |
| <img src="icons/sarah-clipboard.svg" width="20"> | `bubbles.design` | **Architect.** Turns loose ideas into a crisp technical shape. | System design |
| <img src="icons/barb-keys.svg" width="20"> | `bubbles.plan` | **Scope planner.** Defines the scopes, owns planning artifacts, and keeps the books. | Breaking work into scopes |
| <img src="icons/julian-glass.svg" width="20"> | `bubbles.implement` | **The implementer.** Delivers every time. | Implementing planned scopes |
| <img src="icons/trinity-notebook.svg" width="20"> | `bubbles.test` | **Test verification.** Trusts nothing. Verifies everything. | Running/fixing test suites |
| <img src="icons/jroc-mic.svg" width="20"> | `bubbles.docs` | **Managed docs publisher.** Publishes the durable truth before closeout. | Updating published docs after changes |
| <img src="icons/ricky-dynamite.svg" width="20"> | `bubbles.chaos` | **Chaos tester.** Breaks things in ways nobody could predict. | Resilience testing |
| <img src="icons/donny-ducttape.svg" width="20"> | `bubbles.simplify` | **Simplifier.** Cuts through the noise without weakening behavior or ownership boundaries. | Reducing complexity after implementation |
| <img src="icons/tommy-rack.svg" width="20"> | `bubbles.devops` | **DevOps executor.** Owns CI/CD, build, deployment, monitoring, and observability execution once operational work is identified. | Shipping operational changes and delivery plumbing |
| <img src="icons/sonny-ledger.svg" width="20"> | `bubbles.releases` | **Release packet planner.** Sonny "Iron Lung" Smith. Produces phase release packets, enforces Product Direction Surfaces trio + carry-forward, coordinates cross-product releases. | Bootstrap, refresh, extend, or coordinate release packets per phase |
| <img src="icons/dvs-mic.svg" width="20"> | `bubbles.train` | **Release-train operator.** Detroit Velvet Smooth. Cuts, promotes, rolls back, and retires release trains; owns the feature-flag lifecycle. | Release-train lifecycle and flag operations |
| <img src="icons/treena-broom.svg" width="20"> | `bubbles.upkeep` | **Operational hygiene owner.** Treena Lahey. Runs scheduled backup, restore-drill, patch, secret-rotation, and compliance sweeps. | Recurring calendar-driven upkeep |
| <img src="icons/jroc-cap.svg" width="20"> | `bubbles.propagate` | **Cross-train propagator.** J-Roc. Forward-merges and backports fixes across release trains under policy + ledger. | Moving a fix across trains |

### <img src="icons/ted-badge.svg" width="24"> Diagnostic And Certification Routing

| Icon | Agent | Role | When to Use |
|:----:|-------|------|-------------|
| <img src="icons/randy-cheeseburger.svg" width="20"> | `bubbles.validate` | **Certification owner.** Checks the gates, owns certification state, and can reopen work with concrete packets. | Pre-merge validation and promotion gating |
| <img src="icons/ted-badge.svg" width="20"> | `bubbles.audit` | **Policy enforcer.** Final compliance pass that certifies or routes rework, not implementation. | Final compliance audit |
| <img src="icons/private-dancer-lamp.svg" width="20"> | `bubbles.grill` | **Pressure tester.** Interrogates ideas, plans, and assumptions before time gets wasted. | Challenging an idea or workflow choice up front |
| <img src="icons/george-green-badge.svg" width="20"> | `bubbles.clarify` | **Ambiguity router.** Identifies what is unclear, what is contradictory, and which owning agent must update the artifacts. | Resolving planning ambiguity without crossing ownership boundaries |
| <img src="icons/conky-puppet.svg" width="20"> | `bubbles.harden` | **Hardener.** Says the uncomfortable truths. Confrontational. Necessary. | Hardening passes |
| <img src="icons/phil-collins-baam.svg" width="20"> | `bubbles.gaps` | **Gap finder.** Finds what nobody else sees. | Gap analysis |
| <img src="icons/bill-wrench.svg" width="20"> | `bubbles.stabilize` | **Stabilizer.** Quiet. Reliable. Surfaces reliability issues and routes the correct owner. | Stability issues |
| <img src="icons/steve-french-paw.svg" width="20"> | `bubbles.regression` | **Regression guardian.** Prowls the codebase catching cross-feature interference. | After implementation/bug fixes |
| <img src="icons/cyrus-sunglasses.svg" width="20"> | `bubbles.security` | **Security scanner.** Finds threats. Confrontational. | Security review |
| <img src="icons/green-bastard-outline.svg" width="20"> | `bubbles.code-review` | **Engineering-first code reviewer.** Reviews repositories, services, packages, modules, and paths strictly from a code perspective. | Reviewing code directly before deciding what to fix |
| <img src="icons/green-bastard-mask.svg" width="20"> | `bubbles.redteam` | **Adversarial verifier.** Attacks finished results to falsify "done". Off by default. | Adversarial verification |
| <img src="icons/orangie-fishbowl.svg" width="20"> | `bubbles.system-review` | **Holistic system reviewer.** Orangie sees everything from the fishbowl. Reviews the whole system. | Reviewing what the system feels like, does, and implies as a whole |
| <img src="icons/cathy-trail.svg" width="20"> | `bubbles.journey` | **Guided walkthrough.** Cathy Curtis walks the live product with you toward a goal, verifies UI/API/telemetry/data at each step, and routes refinements. No sugar-coating. | Guided post-implementation verification of the finished product |
| <img src="icons/gary-laser-eyes.svg" width="20"> | `bubbles.spec-review` | **Spec freshness auditor.** Checks whether artifacts still deserve trust before maintenance or execution. | Auditing stale or drifted specs |

### <img src="icons/camera-crew.svg" width="24"> Utilities

| Icon | Agent | Role | When to Use |
|:----:|-------|------|-------------|
| <img src="icons/camera-crew.svg" width="20"> | `bubbles.status` | **Observer.** Reports state. Never interferes. Read-only. | Checking progress |
| <img src="icons/camera-crew.svg" width="20"> | `bubbles.recap` | **Talking head.** Summarizes what happened in this session, what is in progress, and what comes next. | Quick conversation recap |
| <img src="icons/lahey-bottle.svg" width="20"> | `bubbles.retro` | **Retrospective analyst.** Velocity metrics, gate health trends, hotspot analysis, and shipping patterns across sessions and specs. | Post-session or post-sprint retrospectives |
| <img src="icons/trevor-handoff.svg" width="20"> | `bubbles.handoff` | **Session handoff.** Packages context for the next session. | End of session |
| <img src="icons/cory-trevor-smokes.svg" width="20"> | `bubbles.setup` | **Framework setup.** Sets up or refreshes Bubbles project configuration and `.github` assets. | First-time project setup and framework refresh |
| <img src="icons/t-cap.svg" width="20"> | `bubbles.commands` | **Command registry.** Manages the project command reference. | Updating command docs |
| <img src="icons/sam-binoculars.svg" width="20"> | `bubbles.create-skill` | **Skill creator.** Packages know-how into reusable tools and playbooks. | Adding new skills |

---

## Quick Start

### 0. Setup (after install)
```
/bubbles.super  doctor                — Check framework health
/bubbles.commands                     — Auto-detect project, generate command registry
/bubbles.setup mode: refresh          — Verify framework setup completeness
```

### 1. Just Tell Bubbles What You Want

**You don't need to know which agent, mode, or parameters to use. Just describe your goal.**

```
# Describe one outcome in plain English — goal composes whatever is needed:
/bubbles.goal  Build a user authentication system with JWT tokens
/bubbles.goal  improve the booking feature to be competitive
/bubbles.goal  fix the calendar bug in page builder

# Resume active work. If it is already complete, Bubbles returns a recap:
/bubbles.goal  continue

# Use workflow when you want exactly one mode:
/bubbles.workflow  specs/042 mode: full-delivery tdd: true
```

#### Autonomous Execution (Hands-Free)

**New in v3.5:** For fully autonomous delivery, use `goal` (single goal) or `sprint` (multiple goals + time budget):

```
# Single goal — agent handles EVERYTHING until done:
/bubbles.goal  Implement the security deposit hold/release feature
/bubbles.goal  Fix all broken E2E tests and make chaos scenarios pass
/bubbles.goal  Stabilize the deployment pipeline and close config drift

# Multiple goals + time budget — agent prioritizes and executes:
/bubbles.sprint  minutes: 240
1. Fix the calendar sync bug
2. Add the deposit hold/release feature
3. Improve browser E2E coverage for the page builder
```

**Goal** runs a convergence loop (plan → implement → test → validate → remediate → repeat) until zero findings remain or max iterations hit. **Sprint** wraps multiple goals in a time-managed queue, executing each via the convergence loop, managing the clock, and stopping gracefully when budget expires.

### 1.5. The Most Useful Real-World Patterns

These are the most direct ways users interact with Bubbles.

```
# Fully autonomous — give a goal, come back later
/bubbles.goal  Implement the user authentication system with JWT tokens

# Multiple goals in a time box — fully autonomous
/bubbles.sprint  minutes: 120
1. Fix broken E2E tests for theming
2. Add missing unit tests for booking service
3. Update API documentation

# Explore the idea before any code is written
/bubbles.workflow  mode: brainstorm for multi-tenant booking search with competitive differentiation

# Improve a brownfield feature — objective research runs automatically
/bubbles.workflow  improve the booking feature to be competitive

# Fix a bug in existing code — reproduce/fix/verify loop with the quality chain
/bubbles.workflow  fix the calendar bug in page builder

# Explicitly select and start the next important slice
/bubbles.iterate

# Release-candidate / no-loose-ends delivery
/bubbles.workflow  specs/042-catalog-assistant mode: full-delivery

# Measure rework and hotspot churn after a run
/bubbles.retro  week

# Framework-maintainer check for prompt bloat
bash bubbles/scripts/cli.sh lint-budget
```

| Command Pattern | What Bubbles Does For You |
|----------------|---------------------------|
| `/bubbles.goal <goal>` | Autonomous convergence loop — plan, implement, test, validate, remediate, loop until done |
| `/bubbles.sprint minutes: N` + goals | Time-managed autonomous execution of multiple goals |
| `mode: brainstorm` | Explores the idea without code and produces reviewable planning artifacts |
| `improve ...` / `mode: improve-existing` | Runs objective brownfield research, then produces/refines design and scopes before coding |
| `fix ...` / `mode: bugfix-fastlane` | Runs the focused bug loop with reproduce-before and verify-after evidence |
| `continue` | Resumes one active non-terminal workflow. If none remains, returns a completion recap and an unstarted next-priority candidate. |
| `mode: full-delivery` | Keeps looping through implementation, tests, quality sweep, validation, and audit until the feature is truly green or concretely blocked |
| `/bubbles.retro ...` | Shows slop tax and hotspot data so you can see whether you are shipping progress or just cleaning up rework |

### 2. How It Works Under The Hood

Workflow's Phase -1 classifies your input and delegates:

| Your Input | What Happens |
|-----------|-------------|
| Plain English | Delegates to `super` for NLP resolution → gets mode + spec + tags → executes |
| "Continue" / "next" | Resumes one active non-terminal workflow. If none remains, invokes recap and stops. |
| "Pick the next priority" / `/bubbles.iterate` | Selects the next priority item and starts it as explicitly requested. |
| Structured (`mode:` + spec) | Skips resolution, executes phases directly |
| Framework ops ("doctor", "hooks") | Delegates to `super` for framework operations |

### 2.5. How The Planning Improvements Show Up In Practice

You usually do not invoke these as separate commands. They show up as workflow behavior and short reviewable artifacts.

| Improvement | How Users Experience It |
|------------|--------------------------|
| **Objective Research Pass** | Brownfield modes run a two-pass research step before design so the workflow captures current truth instead of jumping straight to solution-shaped opinions |
| **Capability-First Design** | When proportionality triggers fire, planning models the reusable capability foundation before ntfy/email-style providers, connectors, variants, or shared UI overlays |
| **Design Brief** | `design.md` starts with a short alignment checkpoint you can review in a few minutes instead of reading a giant design doc |
| **Execution Outline** | `scopes.md` starts with a short plan preamble so you can steer the order and checkpoints before implementation |
| **Horizontal Plan Detection** | If planning drifts into DB → service → API → UI sequencing, Bubbles restructures toward vertical slices |
| **Slop Tax** | `bubbles.retro` reports rework signals like retries, reversions, and fix-on-fix churn |
| **Instruction Budget Lint** | Framework maintainers can audit prompt size with `bubbles lint-budget` instead of guessing when prompts got too bloated |

### 2.6. Review The Short Artifacts, Then Read The Code

The intended loop is:

1. Run a workflow.
2. Review the **Design Brief** at the top of `design.md`.
3. Review the **Execution Outline** at the top of `scopes.md`.
4. Let Bubbles implement.
5. Read the actual code and test evidence.

The short artifacts are there to help you steer early. They are not a substitute for reading the implementation.

### 3. Direct Agents (When You Know The Target)

You can still call any specialist directly when you explicitly want surgical work. Recap, status, and handoff continuation should usually go back through `/bubbles.workflow ...` instead of jumping straight to implement/test/validate.

```
/bubbles.analyst   Build a user authentication system with JWT tokens
/bubbles.implement Execute scope 1 of auth
/bubbles.test      Run all tests for the auth feature
/bubbles.code-review  profile: engineering-sweep scope: path:services/gateway
/bubbles.system-review  mode: full scope: feature:auth output: summary-doc
/bubbles.super     help me choose the right workflow mode
```

---

## Workflow Modes

<!-- GENERATED:FRAMEWORK_STATS_WORKFLOW_INTRO_START -->
Bubbles supports 61 workflow modes plus optional execution tags. Here are the most common:
<!-- GENERATED:FRAMEWORK_STATS_WORKFLOW_INTRO_END -->

| Mode | What It Does | Use When |
|------|-------------|----------|
| `full-delivery` | Convergence loop: implement → test → regression → simplify → gaps → harden → stabilize → devops → security → validate → audit → chaos → docs — repeats until certified done | All features (default) |
| `bugfix-fastlane` | Reproduce → fix → test → regression → simplify → stabilize → devops → security → validate → audit | Bug fixes |
| `rapid-tool-delivery` | Risk-proportional fast lane for one low-risk, build-free tool increment; keeps the full integrity contract, escalates to full-delivery on any high-risk trigger | Quick low-risk tool work |
| `value-first-e2e-batch` | Prioritized delivery with the full quality chain per batch | Large features |
| `chaos-hardening` | Chaos → fix → regression → hardening → validate → audit | Resilience work |
| `harden-gaps-to-doc` | Harden → gaps → test → docs | Quality sweeps |
| `devops-to-doc` | DevOps → test → stabilize → validate → docs | Operational delivery work |
| `simplify-to-doc` | Simplify → test → validate → audit → docs | Safe cleanup of existing implementations |
| `retro-quality-sweep` | Retro-guided simplify/harden quality sweep | Hotspot-driven maintenance |
| `stochastic-quality-sweep` | Random quality checks across the codebase | Periodic maintenance |

<!-- GENERATED:FRAMEWORK_STATS_WORKFLOW_OUTRO_START -->
See [docs/guides/WORKFLOW_MODES.md](docs/guides/WORKFLOW_MODES.md) for all 61 modes.
<!-- GENERATED:FRAMEWORK_STATS_WORKFLOW_OUTRO_END -->

**Delivery strategy & achieved assurance.** The `rapid-tool-delivery` fast lane ships a single low-risk, build-free tool increment with fewer phases but the full integrity contract, self-escalating to `full-delivery` on any high-risk trigger. Separately, `bubbles.validate` *derives* an achieved-assurance level from evidence — `full` (→ `done`), `fast` (→ `delivered_fast`, the audit-less fast-lane result), or `prototype` (→ `delivered_prototype`, which never ships). Assurance is requestable, never declarable. See [docs/guides/WORKFLOW_MODES.md](docs/guides/WORKFLOW_MODES.md#delivery-strategy--achieved-assurance).

For engineering-only code review work that should not enter the spec workflow, use `bubbles.code-review` with a review profile from `bubbles/code-review.yaml`.

For holistic feature, component, journey, or system review, use `bubbles.system-review` with a mode from `bubbles/system-review.yaml`.

Optional execution tags:
- `grillMode: required-on-ambiguity` pressure-tests the direction before planning or implementation starts.
- `tdd: true` forces a red-green-first execution loop inside the implement/test path after planning readiness is already satisfied.
- `backlogExport: tasks|issues` makes planning emit copy-ready backlog outputs per scope.
- `improvementPrelude: analyze-design-plan|analyze-ux-design-plan` turns on full-delivery pre-round planning passes.
- `improvementPreludeRounds: N` limits how many full-delivery rounds may run that prelude.
- `specReview: once-before-implement` runs one freshness/redundancy audit before legacy improvement or implementation work starts so stale active specs are reconciled once, not rediscovered every retry round.

Baseline workflow law already requires coherent spec/design/plan artifacts, explicit Gherkin scenarios, scenario-specific test planning, and scenario-driven E2E/integration proof before implementation begins.
- `socratic: true` turns on a bounded clarification loop before discovery/bootstrap work.
- `gitIsolation: true` opts into branch/worktree isolation when project policy allows it.
- `autoCommit: scope|dod` opts into atomic commits after validated milestones.
- `maxScopeMinutes` and `maxDodMinutes` tighten planning so scopes stay small and isolated.
- `microFixes: true` keeps failure recovery in narrow error-scoped loops.

Control-plane rules:
- Every specialist invocation ends with a concrete result envelope: `completed_owned`, `completed_diagnostic`, `route_required`, or `blocked`.
- Route-required outcomes carry owner-targeted packets with scope, scenario, or DoD references.
- Diagnostic and certification phases route foreign-owned follow-up; they do not perform inline remediation.
- Workflow modes execute only in an authorized top-level runner; nested workflow-runner dispatch is forbidden.
- `scenario-manifest.json` carries stable `SCN-*` contracts, and validate replays linked live-system scenario proof before certification.
- `uservalidation.md` remains human acceptance input; automation findings do not toggle it.

Use `/bubbles.super` for framework operations or command recommendations without product-workflow execution. It resolves the authorized runner as well as the mode.

---

## The Rules

Bubbles enforces a strict quality system. This isn't optional.

### Zero-Fabrication Policy
Every piece of evidence must come from **actual terminal execution**. Writing "tests pass" without running tests is fabrication. Fabrication is detected and rejected.

<!-- GENERATED:FRAMEWORK_STATS_GATES_HEADING_START -->
### 120 Quality Gates
<!-- GENERATED:FRAMEWORK_STATS_GATES_HEADING_END -->
Every scope must pass all applicable gates before completion. Gates check everything from test coverage to evidence integrity to DoD completeness.

### Artifact Ownership Gate (G042)
Cross-authoring is blocked. If a diagnostic or downstream specialist finds that a foreign-owned artifact must change, it must route that work to the owning specialist instead of rewriting the artifact directly.

### Downstream Framework Ownership
Consumer repos may install and refresh Bubbles, but they must not author direct edits to framework-managed Bubbles files. Record requested framework changes in `.github/bubbles-project/proposals/` with `bubbles framework-proposal <slug>`, implement the real change in the Bubbles source repo, then refresh downstream installs.

### Self-Healing Loops (G038)
When agents hit failures, they attempt bounded self-repair: narrow context, retry up to 3 times, never stack. No infinite loops.

### Zero Deferral
Every issue found is fixed **now**. "We'll fix it later" is not a valid state. If a gate fails, work stops until it's resolved.

### Zero Warnings
Build, lint, and test output must produce zero warnings. Warnings are errors.

---

## Docs

<table>
<thead>
<tr><th>Document</th><th>What's Inside</th></tr>
</thead>
<tbody>
<tr><td><a href="https://pkirsanov.github.io/bubbles/docs/its-not-rocket-appliances.html">It's Not Rocket Appliances</a></td><td>Visual agent reference card — rendered on GitHub Pages</td></tr>
<tr><td><a href="docs/CHEATSHEET.md">Cheatsheet</a></td><td>Markdown quick-reference</td></tr>
<tr><td><a href="docs/guides/AGENT_MANUAL.md">Agent Manual</a></td><td>Detailed guide for every agent</td></tr>
<!-- GENERATED:CAPABILITY_LEDGER_DOCS_ROW_START -->
<tr><td><a href="docs/generated/competitive-capabilities.md">Competitive Capabilities</a></td><td>Ledger-backed competitive posture guide — 23 shipped, 3 partial, 0 proposed</td></tr>
<tr><td><a href="docs/generated/issue-status.md">Issue Status</a></td><td>Ledger-backed status for 2 tracked framework gaps and proposals</td></tr>
<tr><td><a href="docs/generated/interop-migration-matrix.md">Interop Migration Matrix</a></td><td>Ledger + registry-backed migration matrix for Claude Code, Roo Code, Cursor, and Cline</td></tr>
<!-- GENERATED:CAPABILITY_LEDGER_DOCS_ROW_END -->
<!-- GENERATED:FRAMEWORK_STATS_DOCS_ROW_START -->
<tr><td><a href="docs/guides/WORKFLOW_MODES.md">Workflow Modes</a></td><td>All 61 workflow modes explained</td></tr>
<!-- GENERATED:FRAMEWORK_STATS_DOCS_ROW_END -->
<tr><td><a href="docs/guides/INTEROP_MIGRATION.md">Interop Migration Guide</a></td><td>Supported apply, review-only intake, and proposal-only migration paths for external rule ecosystems</td></tr>
<tr><td><a href="docs/guides/CONTROL_PLANE_DESIGN.md">Control Plane Design</a></td><td>Architecture for repository binding, registry-driven delegation, validate-owned certification, lockdown, and scenario contracts</td></tr>
<tr><td><a href="docs/guides/CONTROL_PLANE_ROLLOUT.md">Control Plane Rollout</a></td><td>Phased implementation plan for the control-plane redesign across all requested changes</td></tr>
<tr><td><a href="docs/guides/CONTROL_PLANE_SCHEMAS.md">Control Plane Schemas</a></td><td>Active and extension schemas for repository decisions, capability registry, policy defaults, scenario manifests, certification state, and rework packets</td></tr>
<tr><td><a href="docs/recipes/">Recipes</a></td><td>Common problems → solutions</td></tr>
<tr><td><a href="docs/guides/INSTALLATION.md">Installing in Your Repo</a></td><td>Step-by-step setup guide</td></tr>
<tr><td><a href="docs/examples/">Spec Examples</a></td><td>Annotated reference examples for common patterns</td></tr>
<tr><td><a href="skills/">Shared Skills</a></td><td>Portable governance skills installed to every repo — including <strong>v4.0 skills-first policy discovery layer</strong> (14 discovery skills: anti-fabrication, evidence capture, DoD validation, status transition, result envelope, ownership routing, quality gates, scope workflow, feature template, bug template, workflow execution loops, mode resolution, fix-cycle protocol, top-level discovery)</td></tr>
</tbody>
</table>

---

## Recipes (Quick Reference)

> "Boys, we need a plan." — Here's what to type.

**Start with `/bubbles.goal`; use `/bubbles.workflow` for one mode and `/bubbles.sprint` for timed multi-goal work:**

| I Want To... | Run This |
|-------------|----------|
| **Just describe what I want** | **`/bubbles.goal  <describe your outcome>`** |
| **Run exactly one workflow mode** | **`/bubbles.workflow  <target> mode: <mode>`** |
| **Multiple goals + time budget** | **`/bubbles.sprint  minutes: N` + goal list** |
| **Continue an active outcome, or recap a completed one** | **`/bubbles.goal  continue`** |
| Explore an idea before writing code | `/bubbles.workflow  mode: brainstorm for <idea>` |
| Start a new feature from scratch | `/bubbles.goal  <describe feature>` |
| Improve an existing feature | `/bubbles.goal  improve <feature>` |
| Fix a focused bug workflow | `/bubbles.bug  mode: fix <describe bug>` |
| Run the full delivery pipeline | `/bubbles.workflow implement action:full-delivery target:spec for <feature>` |
| Reconcile and redesign | `/bubbles.workflow  redesign-existing for <feature>` |
| Harden the code quality | `/bubbles.workflow  harden <feature>` |
| Break things on purpose | `/bubbles.workflow  chaos test <feature>` |
| Spend time on several goals | `/bubbles.sprint  minutes: 120` + goal list |
| Maximum assurance delivery | `/bubbles.workflow  <feature> mode: full-delivery` |
| Show rework and hotspot patterns | `/bubbles.retro  week` |

**Direct agents (when you know the target):**

| I Want To... | Run This |
|-------------|----------|
| Review code directly | `/bubbles.code-review  scope: full-repo output: summary-only` |
| Review a feature holistically | `/bubbles.system-review  mode: full scope: component:<name>` |
| Check what's going on | `/bubbles.status` |
| Something's not right, validate it | `/bubbles.workflow  <feature> mode: validate-to-doc` |
| Hand off to next session | `/bubbles.handoff` |

**Framework operations:**

| I Want To... | Run This |
|-------------|----------|
| Check project health | `/bubbles.super  doctor` |
| Install git hooks | `/bubbles.super  install hooks` |
| Upgrade bubbles | `/bubbles.super  upgrade` |
| Add a custom quality gate | `/bubbles.super  add a pre-push gate for license checking` |
| View scope dependencies | `/bubbles.super  show dag for 042` |
| Get help choosing a mode | `/bubbles.super  help me <describe goal>` |

See [docs/recipes/](docs/recipes/) for detailed step-by-step guides.

---

## Project Structure

```
bubbles/
<!-- GENERATED:FRAMEWORK_STATS_PROJECT_TREE_START -->
├── agents/                    # 41 agent definitions
│   ├── bubbles_shared/        # Shared governance docs
│   ├── bubbles.workflow.agent.md
│   ├── bubbles.implement.agent.md
│   ├── bubbles.super.agent.md # NEW: first-touch assistant + framework operations
│   └── ...
├── prompts/                   # 41 prompt shims
<!-- GENERATED:FRAMEWORK_STATS_PROJECT_TREE_END -->
├── bubbles/                   # Workflow config + scripts + generated docs
│   ├── workflows.yaml
│   ├── scripts/               # Governance scripts (artifact-lint, guard, etc.)
│   └── docs/                  # Generated docs (regenerated on upgrade)
├── templates/                 # Bootstrap templates for project setup
├── icons/                     # SVG icons for all agents
├── docs/
│   ├── its-not-rocket-appliances.html
│   ├── guides/                # Detailed documentation
│   ├── recipes/               # Problem → solution guides
│   └── examples/              # Annotated reference specs
├── install.sh                 # One-line installer (supports --bootstrap)
└── VERSION
```

---

## Contributing

1. Fork the repo
2. Make changes to agents/prompts/scripts
3. Test in at least one consumer repo
4. PR with description of what changed

Agent files are Markdown. The system is pure text. No build step. No compilation.

**Rule:** All agent files (`bubbles.*.agent.md`) must be project-agnostic. Zero repo-specific paths, commands, or tool references.

**Enforcement:** Run `bubbles agnosticity` for a full portable-surface drift check, `bubbles agnosticity --staged` for pre-commit scope, and `bubbles hooks install --all` to wire those checks into local git hooks.

<details>
<summary>Maintainer scope guard</summary>

This repository is a generic, repo-agnostic framework. Repo-specific, product-specific, machine-specific, deployment-specific, and operator-specific content belongs in downstream repos or operator-owned locations, not here. See [docs/SCOPE_POLICY.md](docs/SCOPE_POLICY.md) for the full contributor rule, self-audit checklist, and violation history.

</details>

---

## License

MIT — See [LICENSE](LICENSE).

---

<p align="center">
  <img src="icons/bubbles-glasses.svg" width="40">
  <br>
  <em>"Have a good one, boys."</em>
</p>
