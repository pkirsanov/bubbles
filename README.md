<p align="center">
  <img src="icons/bubbles-glasses.svg" width="120" height="120" alt="Bubbles">
</p>

<h1 align="center">🫧 Bubbles</h1>

<p align="center">
  <strong>AI Agent Orchestration System for VS Code Copilot</strong><br>
  <em>"It ain't rocket appliances, but it works."</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/agents-25-58a6ff?style=flat-square" alt="25 agents">
  <img src="https://img.shields.io/badge/gates-33-3fb950?style=flat-square" alt="33 gates">
  <img src="https://img.shields.io/badge/workflow_modes-23-bc8cff?style=flat-square" alt="23 modes">
  <img src="https://img.shields.io/badge/fabrication_tolerance-zero-f85149?style=flat-square" alt="zero fabrication">
  <img src="https://img.shields.io/badge/license-MIT-d29922?style=flat-square" alt="MIT">
</p>

---

## What Is This?

Bubbles is a **spec-driven AI agent orchestration system** for VS Code Copilot Chat. It turns your `/` slash commands into a full software delivery pipeline — from business analysis to implementation to testing to audit — with zero tolerance for fabricated work.

Think of it as a trailer park supervisor for your codebase. Except this one actually works.

<table>
<tr><td width="64"><img src="icons/bubbles-glasses.svg" width="48"></td><td><strong>25 specialized agents</strong> — each with a defined role, from implementation to chaos testing</td></tr>
<tr><td width="64"><img src="icons/lahey-bottle.svg" width="48"></td><td><strong>33 quality gates</strong> — nothing ships without evidence. Nothing.</td></tr>
<tr><td width="64"><img src="icons/trinity-notebook.svg" width="48"></td><td><strong>Zero-fabrication policy</strong> — "tests pass" without terminal output? That's greasy, boys.</td></tr>
<tr><td width="64"><img src="icons/julian-glass.svg" width="48"></td><td><strong>23 workflow modes</strong> — from full delivery to quick bugfixes to chaos sweeps</td></tr>
</table>

---

## Install

One command. No dependencies beyond `curl` and `bash`.

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash
```

Pin to a version:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/v1.0.0/install.sh | bash
```

Update:

```bash
# Same command. It overwrites the shared files, leaves your project config alone.
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash
```

### What Gets Installed

```
.github/
├── agents/
│   ├── bubbles.workflow.agent.md    # 25 agent definitions
│   ├── bubbles.implement.agent.md
│   ├── ...
│   └── _shared/                     # Shared governance docs
│       ├── agent-common.md
│       ├── scope-workflow.md
│       └── ...
├── prompts/
│   └── bubbles.*.prompt.md          # 25 prompt shims
├── bubbles/
│   └── workflows.yaml               # 23 workflow mode definitions
└── scripts/
    ├── bubbles.sh                   # CLI for governance queries
    └── bubbles-*.sh                 # Lint, audit, guard scripts
```

### What You Add (Project-Specific)

Bubbles installs the orchestration engine. Your project provides the context:

| File | Purpose | Bubbles Touches It? |
|------|---------|:---:|
| `.github/copilot-instructions.md` | Project commands, ports, tech stack | No |
| `.github/instructions/terminal-discipline.instructions.md` | Your repo's `./yourproject.sh` CLI rules | No |
| `.specify/memory/constitution.md` | Project principles and policies | No |

---

## The Crew

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

---

## Quick Start

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

Bubbles supports 23 workflow modes. Here are the most common:

| Mode | What It Does | Use When |
|------|-------------|----------|
| `full-delivery` | All phases: analyze → design → plan → implement → test → validate → audit → docs | New features |
| `bugfix-fastlane` | Fast: reproduce → fix → test → validate | Bug fixes |
| `value-first-e2e-batch` | Prioritized: plan → implement batches → test → validate | Large features |
| `chaos-hardening` | Chaos → harden → test → validate | Resilience work |
| `harden-gaps-to-doc` | Harden → gaps → test → docs | Quality sweeps |
| `stochastic-quality-sweep` | Random quality checks across the codebase | Periodic maintenance |

See [docs/guides/WORKFLOW_MODES.md](docs/guides/WORKFLOW_MODES.md) for all 23 modes.

---

## The Rules

Bubbles enforces a strict quality system. This isn't optional.

### Zero-Fabrication Policy
Every piece of evidence must come from **actual terminal execution**. Writing "tests pass" without running tests is fabrication. Fabrication is detected and rejected.

### 33 Quality Gates
Every scope must pass all applicable gates before completion. Gates check everything from test coverage to evidence integrity to DoD completeness.

### Zero Deferral
Every issue found is fixed **now**. "We'll fix it later" is not a valid state. If a gate fails, work stops until it's resolved.

### Zero Warnings
Build, lint, and test output must produce zero warnings. Warnings are errors.

---

## Docs

| Document | What's Inside |
|----------|--------------|
| [It's Not Rocket Appliances](docs/its-not-rocket-appliances.html) | Visual agent reference card with icons |
| [Cheatsheet](docs/CHEATSHEET.md) | Markdown quick-reference |
| [Agent Manual](docs/guides/AGENT_MANUAL.md) | Detailed guide for every agent |
| [Workflow Modes](docs/guides/WORKFLOW_MODES.md) | All 23 workflow modes explained |
| [Recipes](docs/recipes/) | Common problems → solutions |
| [Installing in Your Repo](docs/guides/INSTALLATION.md) | Step-by-step setup guide |

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

See [docs/recipes/](docs/recipes/) for detailed step-by-step guides.

---

## Project Structure

```
bubbles/
├── agents/                    # 25 agent definitions
│   ├── _shared/               # Shared governance docs
│   ├── bubbles.workflow.agent.md
│   ├── bubbles.implement.agent.md
│   └── ...
├── prompts/                   # 25 prompt shims
├── bubbles/                   # Workflow configuration
│   └── workflows.yaml
├── scripts/                   # Governance scripts
│   ├── bubbles.sh
│   └── bubbles-*.sh
├── icons/                     # SVG icons for all agents
├── docs/
│   ├── its-not-rocket-appliances.html  # Visual reference card ("It's not rocket appliances")
│   ├── guides/                # Detailed documentation
│   └── recipes/               # Problem → solution guides
├── install.sh                 # One-line installer
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
