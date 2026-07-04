# IMP-005 — Framework Housekeeping: Skills, Prompt-Shims, Learning-Loop Seed

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** 4-pass agent-ecosystem audit (2026-07)
**Verified gaps addressed:** INVENTORY drift (S1), Skills-First-Pointers coverage (S2), learning-loop cold-start + user-blindness (S3), prompt-shim parity (D2), improvements/ surface (D3).

## Problem (verified against source)

- **S1 — INVENTORY drift:** `skills/INVENTORY.md` states "37 skills" but there are **41 skill directories** on disk; `bubbles-long-running-commands` is absent from INVENTORY. NOTE: partly explained by in-flight isolation-doctrine skills (`bubbles-datastore-isolation`, `bubbles-isolated-ml-sidecar`) uncommitted on the current feature branch — so the drift is partly work-in-progress, but the count + the `bubbles-long-running-commands` omission must be reconciled when that branch lands.
- **S2 — Skills-First-Pointers coverage:** only **11/40 agents** have a `## Skills-First Pointers` section (27.5%). 29 lack it (including `implement`, `plan`, `analyst`, `design`, `docs`, `devops`, `train`, `upkeep`, `propagate`, `releases`). Inconsistent.
- **S3 — learning-loop cold-start + user-blindness:** `skillEvolution.sourceFile` (`.specify/memory/lessons.md`) is created lazily, not seeded at install — the loop starts empty; and it ingests only agent-execution patterns (git diffs, taste decisions), not user experiential signal.
- **D2 — prompt-shim parity:** 37/40 agents have a `bubbles.X.prompt.md` shim; `train`, `upkeep`, `propagate` have **none** — not directly slash-invokable.
- **D3 — improvements/ surface:** gate descriptions (G098-G100, G125) reference `improvements/IMP-NNN-*.md`, but the directory did not exist until this review created it.

## Proposal

### SCOPE-1 — INVENTORY reconciliation (S1)

**Status: ✅ IMPLEMENTED.** `skills/INVENTORY.md` reconciled to the true **40**-skill count (the 41 dirs on disk minus the gitignored `__manifest_leak_probe/` selftest probe): added the missing `bubbles-long-running-commands` row and corrected the count/LOC summary. A lightweight parity guard `bubbles/scripts/inventory-parity-check.sh` (+ hermetic `-selftest.sh`, both wired into `framework-validate.sh`) now fails loud on any future drift, so the count cannot silently diverge again.

- When the isolation-doctrine branch lands, update `skills/INVENTORY.md` to the true count and add rows for `bubbles-long-running-commands` + any other uninventoried skills. Add a lightweight inventory-parity check (script or selftest) so the count cannot drift silently.

### SCOPE-2 — Skills-First-Pointers standard (S2)

- Decide: (a) require a `## Skills-First Pointers` section in every agent (backfill the 29 via a consistent template), OR (b) formally mark it optional in the agent-authoring skill. Recommendation: (a) for discoverability.

### SCOPE-3 — learning-loop seed + user-signal input (S3)

- Seed `.specify/memory/lessons.md` at install (empty + a header comment) so the `skillEvolution` loop can start.
- Add a user-feedback lessons source fed by `bubbles.journey` (see IMP-001) so the loop learns from experiential signal, not only agent-execution patterns.

### SCOPE-4 — prompt-shim parity (D2)

- Add `prompts/bubbles.train.prompt.md`, `prompts/bubbles.upkeep.prompt.md`, `prompts/bubbles.propagate.prompt.md` shims — OR formally document that the ops agents are intentionally mode-only. Recommendation: add them for uniformity.

### SCOPE-5 — improvements/ surface (D3)

- DONE by this review: `improvements/` now exists (this IMP set). Add an `improvements/INDEX.md` + a proposal template so future framework-health proposals are consistent. Reconcile the dangling `improvements/IMP-NNN-*` references in the G098-G100 / G125 gate descriptions (either the referenced docs should exist, or the refs should be updated).

## Migration / rollout

- All additive/housekeeping. SCOPE-1 is sequenced AFTER the isolation-doctrine branch lands to avoid conflict.

## Risks & mitigations

- **R1** INVENTORY conflict with the in-flight branch → sequence after it lands.
- **R2** backfilling 29 Skills-First sections is churn → template-driven, one batch, low risk.

## Acceptance criteria (when implemented)

- INVENTORY count matches the filesystem + a parity check is added.
- Skills-First-Pointers standard decided and applied (or formally optional).
- `.specify/memory/lessons.md` seeded at install; journey user-feedback source wired (with IMP-001).
- `train`/`upkeep`/`propagate` prompt shims added (or mode-only documented).
- `improvements/INDEX.md` + template added; dangling IMP references reconciled.

## Files to touch (on approval)

`skills/INVENTORY.md` (+ parity check script/selftest), the 29 agent `.md` files (Skills-First backfill), `install.sh` (lessons.md seed), `prompts/bubbles.train.prompt.md` + `prompts/bubbles.upkeep.prompt.md` + `prompts/bubbles.propagate.prompt.md` (new), `improvements/INDEX.md` (+ template), the gate descriptions referencing `improvements/` (reconcile).
