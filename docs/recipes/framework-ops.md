# Recipe: Framework Operations

> *"I'm the park supervisor."*

Use `bubbles.ops` for framework management AND as your interactive command assistant.

## Check Project Health

```
/bubbles.ops  check my project health and fix any issues
```

Or via CLI:
```bash
bash .github/bubbles/scripts/cli.sh doctor --heal
```

## Install Git Hooks

```
/bubbles.ops  install all git hooks
```

This installs:
- **pre-commit:** Fast artifact lint on staged spec files
- **pre-push:** State transition guard on specs claiming "done"

## Add a Custom Quality Gate

```
/bubbles.ops  add a pre-push gate that checks for license compliance using scripts/license-check.sh
```

This creates the entry in `.github/bubbles-project.yaml` and registers the hook.

## Upgrade Bubbles

```
/bubbles.ops  upgrade bubbles to latest
```

Or preview first:
```
/bubbles.ops  upgrade --dry-run
```

## Scope Dependency Visualization

```
/bubbles.ops  show the dependency graph for spec 042
```

Outputs a Mermaid diagram showing scope dependencies with completion status.

## Enable Metrics

```
/bubbles.ops  enable metrics tracking
```

After enabling, governance scripts log events to `.specify/metrics/events.jsonl`. View with:
```
/bubbles.ops  show metrics summary
```

## View Lessons Learned

```
/bubbles.ops  show recent lessons
```

Lessons are auto-compacted when the file exceeds 150 lines.

---

## Command & Prompt Assistant (NEW)

Use `bubbles.ops` when you're not sure which agent, mode, or command to use. Just describe your goal in plain English.

### Get a Single Command

```
/bubbles.ops  I want to improve the booking feature
→ Responds with: /bubbles.workflow  specs/008-booking mode: improve-existing

/bubbles.ops  generate a command for chaos testing everything
→ Responds with: /bubbles.workflow  mode: stochastic-quality-sweep

/bubbles.ops  how do I harden specs 11 through 37?
→ Responds with: /bubbles.workflow  011-037 mode: harden-to-doc
```

### Get a Multi-Step Plan

```
/bubbles.ops  I have a new feature idea for notifications, plan the steps
→ Responds with:
  1. /bubbles.analyst  Build a notification system with email and push support
  2. /bubbles.ux  specs/NNN-notification-system
  3. /bubbles.workflow  specs/NNN-notification-system mode: product-to-delivery

/bubbles.ops  what should I do before shipping?
→ Responds with:
  1. /bubbles.workflow  <feature> mode: harden-gaps-to-doc
  2. /bubbles.security  <feature>
  3. /bubbles.audit  <feature>
```

### Get Workflow Mode Advice

```
/bubbles.ops  which mode should I use for improving an existing feature?
→ Responds with: improve-existing — runs analysis, gap detection, implementation, and full quality chain

/bubbles.ops  what's the difference between harden-to-doc and gaps-to-doc?
→ Explains each mode and recommends based on your situation
```
