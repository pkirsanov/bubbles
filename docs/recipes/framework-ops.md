# Recipe: Framework Operations

> *"Ask Bubbles first. We'll figure out the right move before we make a mess of this."*

Use `bubbles.super` as the front door to Bubbles. It handles framework management, but more importantly it tells you the right command, agent, workflow mode, or sequence when you do not already know the system.

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

## Platform Assistant (Primary Entry Point)

Use `bubbles.super` when you're not sure which agent, mode, or command to use. Just describe your goal in plain English.

### Get a Single Command

```
/bubbles.super  I want to improve the booking feature
→ Responds with: /bubbles.workflow  specs/008-booking mode: improve-existing

/bubbles.super  generate a command for chaos testing everything
→ Responds with: /bubbles.workflow  mode: stochastic-quality-sweep

/bubbles.super  how do I harden specs 11 through 37?
→ Responds with: /bubbles.workflow  011-037 mode: harden-to-doc
```

### Get a Multi-Step Plan

```
/bubbles.super  I have a new feature idea for notifications, plan the steps
→ Responds with:
  1. /bubbles.analyst  Build a notification system with email and push support
  2. /bubbles.ux  specs/NNN-notification-system
  3. /bubbles.workflow  specs/NNN-notification-system mode: product-to-delivery

/bubbles.super  what should I do before shipping?
→ Responds with:
  1. /bubbles.workflow  <feature> mode: harden-gaps-to-doc
  2. /bubbles.security  <feature>
  3. /bubbles.audit  <feature>
```

### Get Workflow Mode Advice

```
/bubbles.super  which mode should I use for improving an existing feature?
→ Responds with: improve-existing — runs analysis, gap detection, implementation, and full quality chain

/bubbles.super  what's the difference between harden-to-doc and gaps-to-doc?
→ Explains each mode and recommends based on your situation
```
