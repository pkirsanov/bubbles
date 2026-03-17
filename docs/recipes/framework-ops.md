# Recipe: Framework Operations

> *"I'm the park supervisor."*

Use `bubbles.ops` or the CLI for framework management tasks.

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
