# 🫧 Installing Bubbles in Your Repo

> *"Smokes, let's go."*

---

## Prerequisites

- A git repository
- `curl` and `bash` (available on macOS, Linux, WSL)
- VS Code with GitHub Copilot Chat extension

---

## Step 1: Install Bubbles

From your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash
```

This installs:
- 25 agent definitions → `.github/agents/bubbles.*.agent.md`
- 25 prompt shims → `.github/prompts/bubbles.*.prompt.md`
- Shared governance docs → `.github/agents/_shared/`
- Workflow config → `.github/bubbles/workflows.yaml`
- Governance scripts → `.github/scripts/bubbles*.sh`

---

## Step 2: Add Project-Specific Configuration

Bubbles agents are project-agnostic. They need **your project's context** to work. Create or update these files:

### `.github/copilot-instructions.md`

This is the main file VS Code Copilot reads. Include:

```markdown
# My Project Development Guidelines

## Commands
| Action | Command |
|--------|---------|
| Build | `./myproject.sh build` |
| Test  | `./myproject.sh test` |
| Lint  | `./myproject.sh lint` |

## Testing Requirements
| Test Type | Command |
|-----------|---------|
| Unit | `./myproject.sh test unit` |
| Integration | `./myproject.sh test integration` |
| E2E | `./myproject.sh test e2e` |

## Bubbles Artifacts & Workflow (MANDATORY for ALL work)
- Follow the scope workflow, report evidence, and artifact templates in
  [agents/_shared/scope-workflow.md](agents/_shared/scope-workflow.md)
- Record test execution evidence in report.md as required by the shared workflow

## Key Locations
- Source: `src/`
- Tests: `tests/`
- Specs: `specs/`
```

### `.github/instructions/terminal-discipline.instructions.md`

Define your repo's CLI rules:

```markdown
---
applyTo: "**"
---
# Terminal Discipline
- Always use `./myproject.sh` for build/test/lint
- No direct `npm`, `cargo`, `go` commands
```

---

## Step 3: Create the Specs Directory

```bash
mkdir -p specs
```

Bubbles organizes work under `specs/`:
```
specs/
├── 001-user-auth/
│   ├── spec.md
│   ├── design.md
│   ├── scopes.md
│   ├── report.md
│   ├── uservalidation.md
│   └── state.json
└── bugs/
    └── BUG-001-login-failure/
        ├── bug.md
        ├── spec.md
        ├── design.md
        ├── scopes.md
        ├── report.md
        └── state.json
```

---

## Step 4: Commit and Test

```bash
git add .github/ specs/
git commit -m "chore: install Bubbles agent system"
```

Open VS Code, start a Copilot Chat, and try:

```
/bubbles.status
```

If you see the status agent respond, you're good.

---

## Updating Bubbles

Same command as installation. It overwrites shared files, leaves your project config alone:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash
```

Pin to a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/v1.2.0/install.sh | bash
```

---

## What's Shared vs. Project-Specific

| Category | Location | Managed By |
|----------|----------|:----------:|
| Agent definitions | `.github/agents/bubbles.*.agent.md` | Bubbles |
| Shared governance | `.github/agents/_shared/*.md` | Bubbles |
| Prompt shims | `.github/prompts/bubbles.*.prompt.md` | Bubbles |
| Workflow config | `.github/bubbles/workflows.yaml` | Bubbles |
| Governance scripts | `.github/scripts/bubbles*.sh` | Bubbles |
| Project instructions | `.github/copilot-instructions.md` | **You** |
| Terminal discipline | `.github/instructions/terminal-discipline.instructions.md` | **You** |
| Repo-specific skills | `.github/skills/your-skill/SKILL.md` | **You** |
| Spec artifacts | `specs/` | **You** (via agents) |

---

## Troubleshooting

**Agents don't appear in Copilot Chat:**
- Restart VS Code
- Check that `.github/agents/bubbles.*.agent.md` files exist
- Ensure GitHub Copilot Chat extension is up to date

**"Something's fucky" — agents can't find project commands:**
- Add your commands to `.github/copilot-instructions.md`
- Ensure your repo has a runner script (`./yourproject.sh`)

---

<p align="center">
  <em>"Looks good, boys."</em>
</p>
