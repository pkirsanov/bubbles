# IMP-002 — readiness-review: System Release-Readiness Synthesizer Mode

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** 4-pass agent-ecosystem audit (2026-07)
**Verified gaps addressed:** no readiness synthesizer (P1), audit verdict not persisted (P2), no consolidated review mode (D1); gives `bubbles.system-review` a first-class home.

## Problem (verified against source)

- `bubbles.audit` emits a real ship verdict — `SHIP_IT / SHIP_WITH_NOTES / REWORK_REQUIRED / DO_NOT_SHIP` — but is forbidden from writing `state.json`; only `bubbles.validate` certifies (G056), and validate emits gate pass/fail, not a holistic verdict; `bubbles.workflow` orchestrates phases but never synthesizes. **No agent integrates validate + audit + security + regression + chaos into one system-level "ready to release" determination.** (P1)
- The audit positive verdict lives only in report **narrative** — there is no structured `certification.readinessVerdict` field. (P2)
- `agents/bubbles_shared/review-core.md` defines a review family (`code-review` + `system-review` + `spec-review`) with a shared baseline, but **NO mode orchestrates them together**. Only `retro-to-review` (narrow: retro→code-review→docs) and `spec-review-to-doc` exist. `system-review` is invoked only by `iterate` (optional precursor) and `code-review` (escalation) — it has no first-class mode home. (D1)

## Proposal

Add a `readiness-review` mode: a read-only, cross-cutting release-readiness synthesizer that runs the review family plus the verification signals and produces ONE persisted verdict.

### SCOPE-1 — `readiness-review` mode (`bubbles/workflows/modes.yaml`)

- `statusCeiling: validated` (read-only on code; NO implementation).
- `phaseOrder: [ select, spec-review, code-review, system-review, security, regression, redteam, validate, finalize ]` — here the `validate` phase performs the SYNTHESIS + persistence (a cross-system rollup), not a per-spec certification-to-`done`.
- Consumes the latest signal from each lens and produces a single readiness report.
- Never mutates code; routes required changes via packets (bug/spec) per the Review-To-Delivery protocol in `workflow-orchestration-core.md`.

### SCOPE-2 — persisted readiness verdict (validate-owned; respects G056)

- Add `certification.readinessVerdict`, written ONLY by `bubbles.validate`: `{ verdict: ship | ship-with-notes | not-ready, byLens: { spec, code, system, security, regression, redteam }, capturedAt, evidenceRefs }`.
- audit's verdict feeds this as one input; validate synthesizes + persists. Closes P2.

### SCOPE-3 — `system-review` gets a home

- `readiness-review` becomes the first-class mode where `system-review` runs by default (not just as `iterate`'s fallback). Update `bubbles.system-review` Non-goals to reference `readiness-review`.

### SCOPE-4 — intent routing

- `bubbles/intent-routes.yaml`: "are we ready to release?", "readiness review", "system readiness", "can we ship <phase>?" → `readiness-review` mode.

## Relationship to existing gates

- Complements G101 (release-delivery-reconciliation): G101 reconciles PROMISED-vs-DELIVERED features; `readiness-review` synthesizes QUALITY / UX / security / regression readiness. Different axes.
- Does NOT replace per-spec validate certification; it is a cross-spec/system rollup.

## Migration / rollout (additive)

- New mode + one new validate-owned certification field + intent routes. No existing mode changes behavior.

## Risks & mitigations

- **R1** overlap with audit → `readiness-review` is cross-SYSTEM synthesis; audit is the per-spec final gate. Document the boundary.
- **R2** verdict authority → validate remains sole certifier (G056); the readiness verdict is advisory-to-release, NOT a `done`-transition.

## Acceptance criteria (when implemented)

- `bubbles/workflows/modes.yaml` has `readiness-review`; mode-resolver resolves it; `framework-validate.sh` passes.
- `certification.readinessVerdict` documented and written ONLY by validate.
- intent routes added.

## Files to touch (on approval)

`bubbles/workflows/modes.yaml`, `bubbles/workflows.yaml` (confirm the phases `spec-review`/`code-review`/`system-review`/`security`/`regression`/`redteam`/`validate`/`finalize` all exist — they do), `agents/bubbles.validate.agent.md` (readinessVerdict authorship), `agents/bubbles.system-review.agent.md` (home reference), `bubbles/intent-routes.yaml`, `agents/bubbles_shared/state-gates.md` (readinessVerdict field doc).
