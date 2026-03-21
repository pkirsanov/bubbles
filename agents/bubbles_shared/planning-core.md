# Planning Core

Purpose: mandatory planning-time rules for `bubbles.plan` and other planning-oriented agents.

## Load By Default
- `critical-requirements.md`
- `planning-core.md`
- `scope-workflow.md`
- Feature artifacts: `spec.md`, `design.md`, scope entrypoint

## Planning Responsibilities
- `scopes.md` and per-scope planning artifacts are owned by `bubbles.plan`.
- Planning is spec-first: derive scopes, tests, and DoD from `spec.md` and `design.md`, not from current implementation.
- Scope plans must stay sequential and small; split mixed-purpose scopes.
- Planning may update `report.md` and `uservalidation.md` templates but does not implement runtime code.

## Required Planning Checks
- Test plans must encode user-perspective scenarios.
- State-changing behavior must include round-trip verification rows.
- Rename/removal work must include a Consumer Impact Sweep.
- UI work must include a UI scenario matrix.

## Load Discipline
- Prefer feature artifacts first.
- Load project commands or repo policy only when the plan needs command resolution or a project-specific rule.
- Do not pull testing, audit, or state-gate detail beyond what is needed to write valid scope artifacts.

## References
- `test-fidelity.md`
- `consumer-trace.md`
- `e2e-regression.md`
- `evidence-rules.md`
