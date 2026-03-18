# Recipe: Set Up a New Project

> *"Smokes, let's go."*

First time using Bubbles? Here's how to go from zero to a working project.

## Step 1: Install Bubbles

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap
```

This installs agents, scripts, prompts, and scaffolds your project config.

## Step 2: Check Health

```
/bubbles.super  check my project health
```

Or:
```bash
bash .github/bubbles/scripts/cli.sh doctor
```

Fix any issues:
```
/bubbles.super  doctor --heal
```

## Step 3: Fill In Your Config

The bootstrap created files with `TODO` markers. Update them:

1. **`.specify/memory/agents.md`** — Add your CLI commands (build, test, lint, etc.)
2. **`.github/copilot-instructions.md`** — Add project policies, testing requirements
3. **`.specify/memory/constitution.md`** — Add project principles

## Step 4: Generate Command Registry

```
/bubbles.commands
```

This auto-detects your project and fills in the command registry.

## Step 5: Install Git Hooks

```
/bubbles.super  install hooks
```

## Step 6: Start Your First Feature

```
/bubbles.analyst  <describe your feature>
```

Then follow the [New Feature recipe](new-feature.md).
