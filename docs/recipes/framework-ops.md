# Recipe: Framework Operations

> *"Ask the super first. We'll figure out the right move before we make a mess of this."*

Use `bubbles.super` when the problem is about the Bubbles framework itself: health, hooks, gates, metrics, upgrades, or recovering from a framework-level problem. If you need broader prompt help first, use the dedicated [Ask the Super First](ask-the-super-first.md) recipe.

## Check Project Health

```
/bubbles.super  check my project health and fix any issues
```

Or via CLI:
```bash
bash .github/bubbles/scripts/cli.sh doctor --heal
```

## Install Git Hooks

```
/bubbles.super  install all git hooks
```

This installs:
- **pre-commit:** Fast artifact lint on staged spec files
- **pre-push:** State transition guard on specs claiming "done"

## Add a Custom Quality Gate

```
/bubbles.super  add a pre-push gate that checks for license compliance using scripts/license-check.sh
```

This creates the entry in `.github/bubbles-project.yaml` and registers the hook.

## Upgrade Bubbles

```
/bubbles.super  upgrade bubbles to latest
```

Or preview first:
```
/bubbles.super  upgrade --dry-run
```

## Scope Dependency Visualization

```
/bubbles.super  show the dependency graph for spec 042
```

Outputs a Mermaid diagram showing scope dependencies with completion status.

## Enable Metrics

```
/bubbles.super  enable metrics tracking
```

After enabling, governance scripts log events to `.specify/metrics/events.jsonl`. View with:
```
/bubbles.super  show metrics summary
```

## View Lessons Learned

```
/bubbles.super  show recent lessons
```

Lessons are auto-compacted when the file exceeds 150 lines.

---

## Solve Framework Problems

Use `bubbles.super` when something in the framework itself is confused, blocked, or behaving in a way you do not understand.

### Diagnose Why Something Stopped

```
/bubbles.super  why did my workflow stop after validate?
→ Responds with: a short explanation of the likely gate or status ceiling issue, plus the next recovery command

/bubbles.super  why didn't my resume command pick up where I expected?
→ Responds with: the likely state issue, what file to check, and the next command to run
```

### Turn a Framework Problem Into Commands

```
/bubbles.super  fix my hooks setup and tell me how to verify it
→ Responds with: the framework action, then the follow-up verification command

/bubbles.super  I think my custom gate is blocking the workflow, what do I do?
→ Responds with: the diagnostic step, the project-gate command, and the recommended repair sequence
```

### Recovery Sequence Examples

```
/bubbles.super  recover me from a failed upgrade
→ Responds with:
  1. /bubbles.super  upgrade --dry-run
  2. /bubbles.super  doctor
  3. /bubbles.super  install hooks

/bubbles.super  help me check whether this repo is Bubbles-ready
→ Responds with:
  1. /bubbles.super  doctor --heal
  2. /bubbles.commands
  3. /bubbles.super  install hooks
```

### Still Not Sure?

If you are not sure whether you have a framework problem, a feature problem, or just need the right prompts, go to [Ask the Super First](ask-the-super-first.md).
