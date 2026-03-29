# Operating Baseline

Use this file for shared operating behavior instead of duplicating the same session/loading/loop prose in prompts.

## Project-Agnostic Indirection

Agents MUST resolve project-specific commands, ports, paths, and policy details through `.specify/memory/agents.md`, `.specify/memory/constitution.md`, and `.github/copilot-instructions.md`. Do not hardcode project-specific values into portable prompts.

## Framework File Immutability (NON-NEGOTIABLE)

**Agents MUST NEVER create, modify, or delete files inside the Bubbles framework-managed directories.** These directories are owned exclusively by the Bubbles framework and updated only through `install.sh` upgrades.

### Framework-Managed Paths (READ-ONLY for agents)

| Path | Owner | Update Mechanism |
|------|-------|------------------|
| `.github/agents/bubbles.*.agent.md` | Bubbles framework | `install.sh` |
| `.github/agents/bubbles_shared/*.md` | Bubbles framework | `install.sh` |
| `.github/bubbles/scripts/*.sh` | Bubbles framework | `install.sh` |
| `.github/bubbles/workflows.yaml` | Bubbles framework | `install.sh` |
| `.github/bubbles/hooks.json` | Bubbles framework | `install.sh` |
| `.github/bubbles/agnosticity-allowlist.txt` | Bubbles framework | `install.sh` |
| `.github/bubbles/*.yaml` (except `bubbles-project.yaml`) | Bubbles framework | `install.sh` |
| `.github/prompts/bubbles.*.prompt.md` | Bubbles framework | `install.sh` |
| `.github/instructions/bubbles-*.instructions.md` | Bubbles framework | `install.sh` |
| `.github/skills/bubbles-*/SKILL.md` | Bubbles framework | `install.sh` |

### Project-Owned Paths (agents MAY modify)

| Path | Owner | Purpose |
|------|-------|---------|
| `.github/bubbles-project.yaml` | Project | Custom quality gates and scan patterns |
| `.github/copilot-instructions.md` | Project | Project-specific policies |
| `.specify/memory/agents.md` | Project | CLI entrypoint, commands, naming |
| `.specify/memory/constitution.md` | Project | Project governance principles |
| `specs/**` | Project | Classified work artifacts (feature, bug, ops) |

### What To Do Instead

| Need | Action |
|------|--------|
| Fix a framework script bug | Propose the change upstream to the Bubbles repository |
| Add a project-specific quality check | Add to `scripts/` or `.github/bubbles-project.yaml` custom gates |
| Add project-specific scan patterns | Edit `.github/bubbles-project.yaml` `scans:` section |
| Extend allowlist for agnosticity lint | Edit `.github/bubbles/agnosticity-allowlist.txt` (project-owned data file) |

### Violation Detection

The `agnosticity-lint.sh --staged` pre-commit check detects project-specific content in framework files. Additionally, `install.sh` upgrades will overwrite local modifications, causing silent regression if agents modify framework files locally.

## Loop Guard

1. Start with the smallest role bootstrap that fits the job.
2. Take one real action after the minimum initial context set is loaded.
3. No redundant rereads without a new reason.
4. One feature-resolution attempt before failing fast on an ambiguous or missing target.
5. Read only the files needed for the current phase, gate, or claim.

## Context Loading Profiles

- `planner`: `plan-bootstrap.md`
- `implementer`: `implement-bootstrap.md`
- `tester`: `test-bootstrap.md`
- `analyst`: `analysis-bootstrap.md`
- `designer`: `design-bootstrap.md`
- `docs`: `docs-bootstrap.md`
- `clarifier`: `clarify-bootstrap.md`
- `ux`: `ux-bootstrap.md`
- `validator`: `audit-bootstrap.md` plus project command sources as needed
- `auditor`: `audit-bootstrap.md`
- `orchestrator`: `bubbles/workflows.yaml`, `state.json`, the scope entrypoint, and only the dispatch metadata required for the active step
- `simplifier`: `implement-bootstrap.md`
- `chaos`: `test-bootstrap.md`

## Autonomous Operation

- Non-interactive by default unless the prompt explicitly opts into bounded questioning.
- Fix the smallest blocked unit first, then re-run the narrowest relevant verification.
- Route foreign-artifact changes to the owning specialist instead of editing them inline.

## Auto-Approval And Timeouts

- Avoid shell wrapper patterns that trigger approval prompts unless explicitly required.
- Every long-running operation must have an explicit timeout or bounded polling rule.

## Classified Work Resolution

- Work only inside classified `specs/...` feature, bug, or ops targets.
- If the target is not found after one resolution attempt, fail fast and report the valid alternatives.