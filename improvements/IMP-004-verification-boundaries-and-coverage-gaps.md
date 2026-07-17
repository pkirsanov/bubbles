# IMP-004 — Verification-Surface Boundaries + Coverage Gaps

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** 4-pass agent-ecosystem audit (2026-07)
**Verified gaps addressed:** fuzzy verification boundaries (P4), parallel-scope shared-state contract (A3), unowned verification concerns (P5).

## Problem (verified against source)

### Fuzzy verification boundaries (P4)

- `bubbles.audit` description claims "security review" while `bubbles.security` owns threat-modeling and disclaims code-quality/spec (→ audit) — but audit does NOT reciprocally disclaim security. Overlap.
- `bubbles.harden` and `bubbles.gaps` both say "fix ALL … route to `bubbles.plan`" with **no ordering rule** between them.
- `bubbles.regression` and `bubbles.test` both touch coverage (regression: "coverage regression detection"; test: "coverage analysis") with no crisp split.
- Only `code-review ↔ system-review` is crisply separated (explicit Non-goals via `review-core.md`).

### Parallel-scope shared-state contract undocumented (A3)

- `parallelScopes=dag` uses git worktrees; the phase-level isolation rule ("both read-only OR both idempotent writes", `workflow-execution-loops.md`) does NOT cover scope-level writes to shared `state.json` / `spec.md` / `scenario-manifest.json`. No merge/conflict strategy is documented.

### Unowned / thin verification concerns (P5)

- No dedicated owner or gate for: **accessibility/i18n** (only passing mentions in ux/system-review), **data-migration safety & API backward-compat**, and **longitudinal performance regression** (regression checks vs the PREVIOUS baseline, not a trend over time).

## Proposal

### SCOPE-1 — tighten Non-goals (P4; doc-only)

- **audit:** disclaim PRIMARY security review — audit READS `bubbles.security` findings from `report.md` and checks compliance gates; security owns threat modeling. Add the reciprocal Non-goal to `bubbles.audit`.
- **harden vs gaps ordering:** document "gaps runs before harden — gaps audits spec/design↔impl fidelity; harden then verifies DoD/tests/policy." Add to both agents + `workflow-orchestration-core.md`.
- **regression vs test coverage:** assign coverage-ADEQUACY to `test` (is coverage sufficient?) and coverage-DELTA to `regression` (did coverage drop vs baseline?). Add crisp one-liners to both Non-goals.

### SCOPE-2 — parallel-scope isolation contract (A3)

- Document (and optionally gate later) the shared-artifact rule for `parallelScopes=dag`: shared `state.json`/`spec.md`/`design.md`/`scenario-manifest.json` are ORCHESTRATOR-owned and written only by the parent between scope merges; worktree scopes may write only their own `scope.md`/`report.md` + code. Add a merge/conflict-resolution step + cleanup-on-abandon.
- **Amendment (2026-07-17, IMP-023):** this documented contract is now MECHANIZED by the IMP-023 artifact-writer lease + `runtime writer-guard` (`bubbles/scripts/runtime-leases.sh`). IMP-004 SCOPE-2 keeps ownership of the *documented contract*; IMP-023 owns the *mechanism*. A child scope's write to shared `state.json`/`scenario-manifest.json`/`spec.md`/`design.md` (or another scope's report) is refused with a structured `blocked` envelope naming the parent owner — see `docs/recipes/runtime-coordination.md` (writer-guard) and IMP-023 SCOPE-3/5.

### SCOPE-3 — coverage-gap owners (P5; advisory-until-configured)

- **a11y/i18n:** assign to `bubbles.ux` (or a new lens) as an explicit verification responsibility, with a project-configurable gate (advisory-until-configured, like G079/G080).
- **migration/backward-compat:** assign to `bubbles.regression` (contract axis) or `bubbles.stabilize`; add an advisory gate for schema-migration rollback + API backward-compat when a project declares it.
- **longitudinal perf:** extend the observability posture (G098-G100) with an optional trend check, or record as out-of-scope with rationale.

## Migration / rollout

- SCOPE-1 is doc-only (Non-goals wording) — safe. SCOPE-2 is doc-first, gate later. SCOPE-3 is advisory-until-configured (no blocking by default).

## Risks & mitigations

- **R1** over-gating → keep P5 gates advisory-until-configured; do not block existing repos.
- **R2** boundary churn → wording-only changes; no behavior change.

## Acceptance criteria (when implemented)

- audit/security/harden/gaps/regression/test Non-goals updated and mutually consistent.
- parallel-scope shared-state contract documented in `scope-workflow.md` / `workflow-execution-loops.md`.
- a11y/i18n + migration/backward-compat owners named; advisory gates specced.

## Files to touch (on approval)

`agents/bubbles.audit.agent.md`, `agents/bubbles.security.agent.md`, `agents/bubbles.harden.agent.md`, `agents/bubbles.gaps.agent.md`, `agents/bubbles.regression.agent.md`, `agents/bubbles.test.agent.md` (Non-goals); `agents/bubbles_shared/workflow-orchestration-core.md` + `scope-workflow.md` + `workflow-execution-loops.md` (ordering + parallel isolation); `agents/bubbles.ux.agent.md` (a11y/i18n); `bubbles/registry/gates.yaml` + generated block (new advisory gates, if pursued).
