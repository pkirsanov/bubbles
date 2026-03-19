# <img src="../../icons/bubbles-glasses.svg" width="28"> Installing Bubbles in Your Repo

> *"Smokes, let's go."*

---

## Prerequisites

- A git repository
- `curl` and `bash` (available on macOS, Linux, WSL)
- VS Code with GitHub Copilot Chat extension

---

## Step 1: Install Bubbles (With Bootstrap)

From your project root:

```bash
# Recommended: install + scaffold everything
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap

# With explicit project name and CLI
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap --cli ./myproject.sh --name "My Project"
```

This installs:
- 25 agent definitions → `.github/agents/bubbles.*.agent.md`
- 25 prompt shims → `.github/prompts/bubbles.*.prompt.md`
- Shared governance docs → `.github/agents/bubbles_shared/`
- Shared portable instructions → `.github/instructions/*.instructions.md`
- Shared portable governance skills → `.github/skills/*/SKILL.md`
- Workflow config → `.github/bubbles/workflows.yaml`
- Governance scripts → `.github/bubbles/scripts/*.sh`

And with `--bootstrap`, also creates:
- `.github/copilot-instructions.md` — project policies and commands
- `.github/instructions/terminal-discipline.instructions.md` — CLI discipline rules
- `.specify/memory/constitution.md` — project governance principles
- `.specify/memory/agents.md` — command registry for agent resolution
- `.github/bubbles/docs/CROSS_PROJECT_SETUP.md` — setup checklist
- `.github/bubbles/docs/SETUP_SOURCES.md` — bootstrap source registry
- `specs/` — directory for feature/bug specs

The bootstrap auto-detects your project name and CLI entrypoint. Use `--cli` and `--name` to override.

> **Note:** Bootstrap never overwrites existing files. Safe to re-run.

Without `--bootstrap`, you can install the shared Bubbles framework files and set up project config manually:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash
```

If you want to skip the portable instructions and governance skills, use:

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --agents-only
```

---

## Step 2: Customize the Generated Files

The bootstrapped files contain `TODO` markers where you need to fill in project-specific details:

### `.github/copilot-instructions.md`
- Update the command table with your actual build/test/lint commands
- Add project-specific test types
- Fill in Docker configuration (if applicable)
- Add key file locations

### `.specify/memory/agents.md`
- Update all `*_COMMAND` entries to match your actual CLI
- Add code pattern conventions
- Add documentation paths

### `.specify/memory/constitution.md`
- Add project-specific principles (architecture, language discipline, etc.)

### `.github/instructions/terminal-discipline.instructions.md`
- Add project-specific forbidden commands
- Add project-specific required patterns

Tip: Use the generated `BUBBLES_CROSS_PROJECT_SETUP.md` checklist to track what's been customized.

---

## Step 3: Commit and Test

```bash
git add .github/ .specify/ specs/
git commit -m "chore: install Bubbles agent system"
```

Open VS Code, start a Copilot Chat, and try:

```
/bubbles.status
```

If you see the status agent respond, you're good.

---

## Step 3b: Let Agents Refine the Setup (Recommended)

After committing, open VS Code and run these agents in order:

```
/bubbles.commands
```

This scans your project — detects tech stack, test frameworks, CLI entrypoint, linters — and regenerates `.specify/memory/agents.md` with real commands instead of placeholders. It also creates missing ignore files (`.gitignore`, `.dockerignore`, etc.).

Then verify the full setup:

```
/bubbles.bootstrap mode: refresh
```

This compares your config files against the latest Bubbles requirements and proposes any fixes.

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
| Shared governance | `.github/agents/bubbles_shared/*.md` | Bubbles |
| Prompt shims | `.github/prompts/bubbles.*.prompt.md` | Bubbles |
| Shared instructions | `.github/instructions/*.instructions.md` | Bubbles |
| Shared governance skills | `.github/skills/<skill>/SKILL.md` | Bubbles |
| Workflow config | `.github/bubbles/workflows.yaml` | Bubbles |
| Governance scripts | `.github/bubbles/scripts/*.sh` | Bubbles |
| Project instructions | `.github/copilot-instructions.md` | **You** (bootstrapped) |
| Terminal discipline | `.github/instructions/terminal-discipline.instructions.md` | **You** (bootstrapped) |
| Command registry | `.specify/memory/agents.md` | **You** (bootstrapped) |
| Constitution | `.specify/memory/constitution.md` | **You** (bootstrapped) |
| Repo-specific skills | `.github/skills/your-skill/SKILL.md` | **You** |
| Spec artifacts | `specs/` | **You** (via agents) |

---

## Troubleshooting

**Agents don't appear in Copilot Chat:**
- Restart VS Code
- Check that `.github/agents/bubbles.*.agent.md` files exist
- Ensure GitHub Copilot Chat extension is up to date

**"Something's fucky" — agents can't find project commands:**
- Run with `--bootstrap` if you haven't: `bash install.sh --bootstrap`
- Check `.specify/memory/agents.md` has your CLI commands
- Ensure your repo has a runner script (`./yourproject.sh`)

---

<p align="center">
  <em>"Looks good, boys."</em>
</p>
