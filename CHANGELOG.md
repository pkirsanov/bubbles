# Changelog

## v2.0.0 — 2026-03-17

Major reorganization and new features. Prefix-based file ownership, per-scope git commits, self-healing loops, framework operations agent, and more.

### Breaking Changes

- `agents/_shared/` → `agents/bubbles_shared/` (all internal references updated)
- `scripts/bubbles*.sh` → `bubbles/scripts/*.sh` (scripts consolidated under `bubbles/` folder, `bubbles-` prefix dropped)
- `scripts/bubbles.sh` → `bubbles/scripts/cli.sh` (main CLI moved)
- Generated docs moved from `.github/docs/BUBBLES_*.md` to `.github/bubbles/docs/`
- `autoCommit` changed from boolean to enum: `off|scope|dod`

### New Features

- **`bubbles.super` agent** (26th agent) — first-touch assistant for framework operations, commands, prompts, setup, upgrades, metrics, custom gates, lessons, and diagnostics
- **Self-healing loop protocol (G039)** — bounded, non-stacking fix loops with maxDepth=1, context narrowing, retry budgets
- **Atomic git commits** — `autoCommit: scope|dod` creates structured commits after validated milestones
- **Lessons-learned memory** — `.specify/memory/lessons.md` with auto-compaction at workflow start when >150 lines
- **Git hooks system** — built-in hook catalog + custom hooks, `hooks.json` registry, `bubbles hooks install/add/remove/run/status`
- **Custom gates** — project-defined quality gates via `.github/bubbles-project.yaml`, auto-discovered by state transition guard
- **Doctor command** — `bubbles doctor [--heal]` validates installation health with 11 checks and auto-fix
- **Scope DAG visualization** — `bubbles dag <spec>` outputs Mermaid dependency diagram
- **Metrics dashboard** — optional, off by default. JSONL event logging for gate failures, phase durations, agent invocations
- **Upgrade command** — `bubbles upgrade [version]` with migration, generated doc regeneration, and staleness recommendations
- **Status --explain** — `bubbles.status --explain` for narrative progress summaries
- **Spec examples gallery** — `docs/examples/` with annotated reference specs for REST API endpoints and bug fixes

### Infrastructure

- Prefix-based file ownership model: `bubbles.` prefix = Bubbles-owned (overwritten on upgrade), everything else = project-owned (never touched)
- Install.sh migration logic for pre-v2 → v2 path transitions
- `bubbles-project.yaml` for project-local extensions (custom gates) without modifying workflows.yaml
- `hooks.json` for hook registry management
- Fun mode aliases for new super agent

## v1.0.0 — 2026-03-17

Initial release. Rebranded from the Ralph agent system.

### What's Included

- **25 agents** — bubbles.workflow through bubbles.bug
- **25 prompt shims** — routing files for VS Code Copilot Chat
- **7 shared governance docs** — agent-common, scope-workflow, templates, etc.
- **9 governance scripts** — artifact lint, state transition guard, etc.
- **1 workflow config** — 23 modes, 33 gates, complete phase definitions
- **23 SVG icons** — one per agent character
- **install.sh** — one-line installer for any repo
- **Documentation** — agent manual, workflow guide, 10 recipes, visual cheatsheet
