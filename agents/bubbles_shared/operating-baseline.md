# Operating Baseline

Use this file for shared operating behavior instead of duplicating the same session/loading/loop prose in prompts.

## Project-Agnostic Indirection

Agents MUST resolve project-specific commands, ports, paths, and policy details through `.specify/memory/agents.md`, `.specify/memory/constitution.md`, and `.github/copilot-instructions.md`. Do not hardcode project-specific values into portable prompts.

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

## Feature/Bug Resolution

- Work only inside classified `specs/...` feature or bug targets.
- If the target is not found after one resolution attempt, fail fast and report the valid alternatives.