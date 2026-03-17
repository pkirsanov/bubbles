<p align="center">
  <img src="icons/bubbles-glasses.svg" width="120" height="120" alt="Bubbles">
</p>

<h1 align="center"><img src="icons/bubbles-glasses.svg" width="32" height="32"> Bubbles</h1>

<p align="center">
  <strong>AI Agent Orchestration System for VS Code Copilot</strong><br>
  <em>"It ain't rocket appliances, but it works."</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/agents-26-58a6ff?style=flat-square" alt="26 agents">
  <img src="https://img.shields.io/badge/gates-39-3fb950?style=flat-square" alt="39 gates">
  <img src="https://img.shields.io/badge/workflow_modes-23-bc8cff?style=flat-square" alt="23 modes">
  <img src="https://img.shields.io/badge/fabrication_tolerance-zero-f85149?style=flat-square" alt="zero fabrication">
  <img src="https://img.shields.io/badge/license-MIT-d29922?style=flat-square" alt="MIT">
</p>

<p align="center">
  <a href="https://pkirsanov.github.io/bubbles/docs/its-not-rocket-appliances.html"><strong>Visual Cheatsheet</strong></a> · <a href="docs/CHEATSHEET.md">Markdown Cheatsheet</a> · <a href="docs/guides/AGENT_MANUAL.md">Agent Manual</a> · <a href="docs/recipes/">Recipes</a>
</p>

---

## What Is This?

Bubbles is a **spec-driven AI agent orchestration system** for VS Code Copilot Chat. It turns your `/` slash commands into a full software delivery pipeline — from business analysis to implementation to testing to audit — with zero tolerance for fabricated work.

Think of it as a trailer park supervisor for your codebase. Except this one actually works.

<table>
<tr><td width="64"><img src="icons/bubbles-glasses.svg" width="48"></td><td><strong>26 specialized agents</strong> — each with a defined role, from implementation to framework ops</td></tr>
<tr><td width="64"><img src="icons/lahey-bottle.svg" width="48"></td><td><strong>39 quality gates</strong> — nothing ships without evidence. Nothing.</td></tr>
<tr><td width="64"><img src="icons/trinity-notebook.svg" width="48"></td><td><strong>Zero-fabrication policy</strong> — "tests pass" without terminal output? That's greasy, boys.</td></tr>
<tr><td width="64"><img src="icons/julian-glass.svg" width="48"></td><td><strong>23 workflow modes</strong> — from full delivery to quick bugfixes to chaos sweeps</td></tr>
<tr><td width="64"><img src="icons/barb-keys.svg" width="48"></td><td><strong>Optional execution tags</strong> — opt into Socratic discovery, git isolation, atomic commits, scope sizing, and micro-fix loops without losing autonomous defaults</td></tr>
</table>

---

## Install

One command. No dependencies beyond `curl` and `bash`.

**Supported platforms:** VS Code + GitHub Copilot Chat (required). Works on macOS, Linux, and WSL2. No Windows CMD/PowerShell support.

```bash
# Install agents only
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash

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

With `--bootstrap`, the installer goes beyond agents — it scaffolds a fully working project setup:

1. **Auto-detects** your project name (from git/directory) and CLI entrypoint (`*.sh` in root)
2. **Creates** all required project-specific config files (if they don't already exist):
   - `.github/copilot-instructions.md` — project policies, commands, testing config
   - `.github/instructions/terminal-discipline.instructions.md` — CLI discipline rules
   - `.specify/memory/constitution.md` — project governance principles
   - `.specify/memory/agents.md` — command registry (agents resolve all commands from here)
   - `.github/docs/BUBBLES_CROSS_PROJECT_SETUP.md` — setup checklist
   - `.github/docs/BUBBLES_SETUP_SOURCES.md` — source registry for bootstrap refresh
3. **Creates** the `specs/` directory for feature/bug specs
4. **Never overwrites** existing files — safe to re-run

After bootstrap, update the `TODO` items in the generated files, then start using agents.

### What Gets Installed (agents only)

```
.github/
├── agents/
│   ├── bubbles.workflow.agent.md    # 26 agent definitions
│   ├── bubbles.implement.agent.md
│   ├── bubbles.ops.agent.md         # NEW: framework operations
│   ├── ...
│   └── bubbles_shared/              # Shared governance docs
│       ├── agent-common.md
│       ├── scope-workflow.md
│       └── ...
├── prompts/
│   └── bubbles.*.prompt.md          # 26 prompt shims
├── bubbles/
│   ├── workflows.yaml               # 23 workflow mode definitions
│   ├── scripts/                     # Governance scripts
│   │   ├── cli.sh                   # Main CLI
│   │   ├── artifact-lint.sh
│   │   ├── state-transition-guard.sh
│   │   └── ...
│   └── docs/                        # Generated docs
└── scripts/
    └── bubbles.sh                   # CLI shim (dispatches to bubbles/scripts/cli.sh)
```

### What `--bootstrap` Adds (project-specific)

```
.github/
├── copilot-instructions.md              # Project policies & commands
├── instructions/
│   └── terminal-discipline.instructions.md  # CLI discipline
└── docs/
    ├── BUBBLES_CROSS_PROJECT_SETUP.md   # Setup checklist
    └── BUBBLES_SETUP_SOURCES.md         # Bootstrap source registry
.specify/memory/
├── constitution.md                      # Project governance
└── agents.md                            # Command registry
specs/                                   # Feature/bug spec folders
```

---

## The Crew

<p align="center">
  <img src="pictures/bazaar_v3_distributed.svg" width="900" alt="Bubbles Distributed Agent Network">
</p>

Every agent has a job. Here's who does what.

### <img src="icons/bubbles-glasses.svg" width="24"> Orchestrators

| Agent | Role | When to Use |
|-------|------|-------------|
| <img src="icons/bubbles-glasses.svg" width="20"> `bubbles.workflow` | **The orchestrator.** Runs mode-driven phases with deterministic gates, retries, and resume. | Starting any multi-phase work |
| <img src="icons/julian-glass.svg" width="20"> `bubbles.iterate` | **Scope executor.** Cool, composed. Executes one scope at a time. | Continuing scope-by-scope work |

### <img src="icons/julian-glass.svg" width="24"> Specialists

| Agent | Role | When to Use |
|-------|------|-------------|
| <img src="icons/julian-glass.svg" width="20"> `bubbles.implement` | **The implementer.** Delivers every time. | Implementing planned scopes |
| <img src="icons/trinity-notebook.svg" width="20"> `bubbles.test` | **Test verification.** Trusts nothing. Verifies everything. | Running/fixing test suites |
| <img src="icons/jroc-mic.svg" width="20"> `bubbles.docs` | **Documentation.** Makes sure everything is narrated and recorded. | Updating docs after changes |
| <img src="icons/randy-cheeseburger.svg" width="20"> `bubbles.validate` | **Gate checker.** Does the grunt work of checking every gate. | Pre-merge validation |
| <img src="icons/lahey-bottle.svg" width="20"> `bubbles.audit` | **Policy enforcer.** Obsessive, thorough. The last line of defense. | Final compliance audit |
| <img src="icons/ricky-dynamite.svg" width="20"> `bubbles.chaos` | **Chaos tester.** Breaks things in ways nobody could predict. | Resilience testing |

### <img src="icons/barb-keys.svg" width="24"> Planning & Design

| Agent | Role | When to Use |
|-------|------|-------------|
| <img src="icons/ray-lawnchair.svg" width="20"> `bubbles.analyst` | **Business analyst.** Figures out the *why* behind requirements. | Starting new features |
| <img src="icons/lucy-mirror.svg" width="20"> `bubbles.ux` | **UX designer.** Cares about how things feel and look. | UI/UX design work |
| <img src="icons/jacob-hardhat.svg" width="20"> `bubbles.design` | **Architect.** Quietly competent technical design. | System design |
| <img src="icons/barb-keys.svg" width="20"> `bubbles.plan` | **Scope planner.** Defines the scopes, keeps the books. | Breaking work into scopes |
| <img src="icons/george-green-badge.svg" width="20"> `bubbles.clarify` | **Requirements clarifier.** Asks the obvious but important questions. | Resolving ambiguity |
| <img src="icons/conky-puppet.svg" width="20"> `bubbles.harden` | **Hardener.** Says the uncomfortable truths. Confrontational. Necessary. | Hardening passes |
| <img src="icons/phil-collins-baam.svg" width="20"> `bubbles.gaps` | **Gap finder.** Finds what nobody else sees. | Gap analysis |

### <img src="icons/bill-wrench.svg" width="24"> Quality & Ops

| Agent | Role | When to Use |
|-------|------|-------------|
| <img src="icons/cory-trevor-smokes.svg" width="20"> `bubbles.bootstrap` | **Scaffolder.** Sets up workspace and artifacts. | New feature/bug setup |
| <img src="icons/bill-wrench.svg" width="20"> `bubbles.stabilize` | **Stabilizer.** Quiet. Reliable. Just fixes infrastructure. | Stability issues |
| <img src="icons/cyrus-sunglasses.svg" width="20"> `bubbles.security` | **Security scanner.** Finds threats. Confrontational. | Security review |
| <img src="icons/donny-ducttape.svg" width="20"> `bubbles.simplify` | **Simplifier.** Cuts through the noise. | Reducing complexity |
| <img src="icons/sebastian-guitar.svg" width="20"> `bubbles.cinematic-designer` | **Design system creator.** Over-the-top production value. | Premium UI/design systems |

### <img src="icons/camera-crew.svg" width="24"> Utilities

| Agent | Role | When to Use |
|-------|------|-------------|
| <img src="icons/camera-crew.svg" width="20"> `bubbles.status` | **Observer.** Reports state. Never interferes. Read-only. | Checking progress |
| <img src="icons/trevor-handoff.svg" width="20"> `bubbles.handoff` | **Session handoff.** Packages context for the next session. | End of session |
| <img src="icons/t-cap.svg" width="20"> `bubbles.commands` | **Command registry.** Manages the project command reference. | Updating command docs |
| <img src="icons/cory-trevor-smokes.svg" width="20"> `bubbles.create-skill` | **Skill creator.** Creates new repo-local skills. | Adding new skills |
| <img src="icons/ricky-dynamite.svg" width="20"> `bubbles.bug` | **Bug hunter.** Finds and fixes bugs with reproduction evidence. | Bug investigation |
| <img src="icons/bubbles-glasses.svg" width="20"> `bubbles.ops` | **Ops manager.** Health checks, hooks, upgrades, metrics, custom gates. The super. | Framework management |

---

## Quick Start

### 0. Bootstrap (after install)
```
/bubbles.commands                     — Auto-detect project, generate command registry
/bubbles.bootstrap mode: refresh      — Verify config completeness
```

### 1. Plan a Feature
```
/bubbles.analyst  Build a user authentication system with JWT tokens
```

### 2. Design It
```
/bubbles.design   Create the technical design for auth
```

### 3. Break Into Scopes
```
/bubbles.plan     Create scopes for the auth feature
```

### 4. Implement
```
/bubbles.implement  Execute scope 1 of auth
```

### 5. Test
```
/bubbles.test     Run all tests for the auth feature
```

### 6. Ship It
```
/bubbles.workflow  full-delivery for auth feature
```

---

## Workflow Modes

Bubbles supports 23 workflow modes plus optional execution tags. Here are the most common:

| Mode | What It Does | Use When |
|------|-------------|----------|
| `full-delivery` | All phases: analyze → design → plan → implement → test → validate → audit → docs | New features |
| `bugfix-fastlane` | Fast: reproduce → fix → test → validate | Bug fixes |
| `value-first-e2e-batch` | Prioritized: plan → implement batches → test → validate | Large features |
| `chaos-hardening` | Chaos → harden → test → validate | Resilience work |
| `harden-gaps-to-doc` | Harden → gaps → test → docs | Quality sweeps |
| `stochastic-quality-sweep` | Random quality checks across the codebase | Periodic maintenance |

See [docs/guides/WORKFLOW_MODES.md](docs/guides/WORKFLOW_MODES.md) for all 23 modes.

Optional execution tags:
- `socratic: true` turns on a bounded clarification loop before discovery/bootstrap work.
- `gitIsolation: true` opts into branch/worktree isolation when project policy allows it.
- `autoCommit: true` opts into atomic commits after validated milestones.
- `maxScopeMinutes` and `maxDodMinutes` tighten planning so scopes stay small and isolated.
- `microFixes: true` keeps failure recovery in narrow error-scoped loops.

---

## The Rules

Bubbles enforces a strict quality system. This isn't optional.

### Zero-Fabrication Policy
Every piece of evidence must come from **actual terminal execution**. Writing "tests pass" without running tests is fabrication. Fabrication is detected and rejected.

### 39 Quality Gates
Every scope must pass all applicable gates before completion. Gates check everything from test coverage to evidence integrity to DoD completeness.

### Self-Healing Loops (G039)
When agents hit failures, they attempt bounded self-repair: narrow context, retry up to 3 times, never stack. No infinite loops.

### Zero Deferral
Every issue found is fixed **now**. "We'll fix it later" is not a valid state. If a gate fails, work stops until it's resolved.

### Zero Warnings
Build, lint, and test output must produce zero warnings. Warnings are errors.

---

## Docs

| Document | What's Inside |
|----------|--------------|
| [It's Not Rocket Appliances](https://pkirsanov.github.io/bubbles/docs/its-not-rocket-appliances.html) | Visual agent reference card — rendered on GitHub Pages |
| [Cheatsheet](docs/CHEATSHEET.md) | Markdown quick-reference |
| [Agent Manual](docs/guides/AGENT_MANUAL.md) | Detailed guide for every agent |
| [Workflow Modes](docs/guides/WORKFLOW_MODES.md) | All 23 workflow modes explained |
| [Recipes](docs/recipes/) | Common problems → solutions |
| [Installing in Your Repo](docs/guides/INSTALLATION.md) | Step-by-step setup guide |
| [Spec Examples](docs/examples/) | Annotated reference examples for common patterns |

---

## Recipes (Quick Reference)

> "Boys, we need a plan." — Here's what to type.

| I Want To... | Run This |
|-------------|----------|
| Start a new feature from scratch | `/bubbles.analyst  <describe feature>` |
| Fix a bug | `/bubbles.bug  <describe bug>` |
| Run the full delivery pipeline | `/bubbles.workflow  full-delivery for <feature>` |
| Check what's going on | `/bubbles.status` |
| Something's not right, validate it | `/bubbles.validate` |
| Find gaps in my implementation | `/bubbles.gaps` |
| Harden the code quality | `/bubbles.harden` |
| Break things on purpose | `/bubbles.chaos` |
| Hand off to next session | `/bubbles.handoff` |
| Check project health | `/bubbles.ops  doctor` |
| Install git hooks | `/bubbles.ops  install hooks` |
| Upgrade bubbles | `/bubbles.ops  upgrade` |
| Add a custom quality gate | `/bubbles.ops  add a pre-push gate for license checking` |
| View scope dependencies | `/bubbles.ops  show dag for 042` |
| Enable metrics collection | `/bubbles.ops  enable metrics` |

See [docs/recipes/](docs/recipes/) for detailed step-by-step guides.

---

## Project Structure

```
bubbles/
├── agents/                    # 26 agent definitions
│   ├── bubbles_shared/        # Shared governance docs
│   ├── bubbles.workflow.agent.md
│   ├── bubbles.implement.agent.md
│   ├── bubbles.ops.agent.md   # NEW: framework operations
│   └── ...
├── prompts/                   # 26 prompt shims
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

---

## License

MIT — See [LICENSE](LICENSE).

---

<p align="center">
  <img src="icons/bubbles-glasses.svg" width="40">
  <br>
  <em>"Have a good one, boys."</em>
</p>
