# IMP-024 — Evidence Receipts, Targeted Revalidation, and Execution-Progress Truth

**Status:** IMPLEMENTED (core rule, reuse-first, 2026-07-17) — the terminal same-session re-verification rule ships as in-window EXACT-duplicate-evidence detection in `artifact-lint.sh` (Check 3), reusing the EXISTING `<!-- bubbles:certifying-window-begin -->` marker (no new evidence store). Targeted invalidation (ER2, full) + execution-progress substates (ER3) remain deferred.
**Surface:** framework-health (G125) — reuse-first (extends the existing certifying-window infrastructure; no new store)
**Motivation:** Multi-session convergence observations (2026-07, Research Lab Feature 010) — Scope 01's `report.md` exceeded 2,000 lines and grew during review through repeated owner/test reconciliation. A green independent replay was invalidated because an untracked validator changed afterward and the earlier evidence lacked its identity, so the framework conservatively restarted the implement/test handoff. Meanwhile the implementation and focused tests were green while the scope and feature still displayed `not_started`, hiding real progress without permitting certification.
**Verified gaps addressed:** unbounded report growth despite evidence-by-reference (ER1), all-or-nothing revalidation on any byte change (ER2), no truthful execution-progress substate distinct from certification (ER3).

## Problem (verified against source)

- **ER1 — evidence-by-reference exists but the report still grew unbounded.** The framework already supports evidence-by-reference, a tool-call JSONL store (`bubbles/scripts/tool-log.sh`), certifying-window markers, and report-compaction guidance. Yet Feature 010's report accreted 2,000+ lines of re-pasted raw output and "concurrent reconciliation" sections. The primitives are present; nothing *binds* the report to bounded receipts + concise summaries. (ER1)
- **ER2 — any change invalidates everything.** A green replay was discarded because an unrelated/untracked validator changed afterward and the prior evidence carried no input identity to scope the invalidation. Revalidation is all-or-nothing: there is no per-receipt input closure to decide WHICH evidence a change actually invalidates. (ER2)
- **ER3 — execution progress collapses into terminal/certification status.** Real delivery progress (implemented + focused-tests-green) had no honest representation distinct from validate-owned certification, so the scope showed `not_started` even though work existed — the user saw no progress, and the framework could not represent "done-but-not-yet-certified" without either overclaiming or hiding truth. (ER3)

## Proposal

Three compatible, **independently landable** scopes. All preserve anti-fabrication (G005/G009/G021), the ≥10-line raw-proof bar (G083), and validate-owned certification (G056/G057) — none is weakened without an equivalent machine-verifiable receipt.

### SCOPE-1 — structured evidence receipts (ER1)

- Raw command output lives ONCE in the existing tool-call/evidence store as an immutable **receipt**: receipt ID, command, exit code, start/end timestamps, tool versions, repo/worktree/commit identity, target scope, and an input fingerprint. `report.md` **cites receipts** and keeps a bounded active **certifying window** plus concise historical summaries. The ≥10-line proof bar is satisfied by the receipt (machine-verifiable) — anti-fabrication and evidence availability are preserved, not relaxed. Do NOT build a competing evidence store; reuse `tool-log.sh` + evidence-by-reference.

### SCOPE-2 — targeted invalidation (ER2)

- Each Test Plan row DECLARES or captures its relevant input closure (the files/tools whose change would invalidate its result). A changed file invalidates ONLY receipts whose declared inputs intersect the change. A parser-supported **semantic digest** MAY distinguish a formatter-only change from a behavior change, but any unknown/unparseable change stays **conservative** (invalidates). Never accept a vague "semantic hash" as a pass without reproducible tooling behind it.

### SCOPE-3 — truthful execution-progress substates (ER3)

- Represent `implemented`, `independently_verified`, `needs_reverification` (and similar) as EXECUTION substates, separate from validate-owned certification. `implement`/`test` MUST NOT write `certification.*`; they update the execution substate. A user sees real delivery progress while the feature remains honestly non-certified until validate acts. Do NOT overload the top-level terminal status.

### SCOPE-4 — append-only correction + retention + compatibility

- Define append-only correction semantics (a wrong receipt is superseded by a new one, never edited), evidence retention + archival links, migration for existing oversized reports (compact-to-receipts without losing evidence), state-schema backward compatibility (new substate fields are additive/optional), and a guard-performance budget (reuse the existing state-transition performance tests).

### SCOPE-5 — test matrix

- Hermetic tests for: unchanged-receipt reuse; unrelated-file change (receipt survives); formatter-only supported change (survives); behavior-changing validator change (invalidates); missing input identity (conservative invalidate); concurrent change during test (composes with IMP-023 writer lease); report compaction to receipts; and anti-fabrication rejection when raw evidence is missing.

### SCOPE-6 — root-cause reconciliation (ER1)

- Explicitly document WHY the existing context-compaction + evidence-by-reference capabilities did not prevent the Feature 010 report loop (no binding between report and bounded receipts; no input-scoped invalidation; no progress substate), so the fix extends those capabilities rather than replacing them.

## Migration / rollout (additive + backward-compatible)

- SCOPE-1 (receipts) and SCOPE-3 (substates) are additive schema extensions (optional fields default to today's behavior). SCOPE-2 (targeted invalidation) is opt-in per Test Plan row; a row with no declared input closure stays conservative (today's all-invalidate behavior). Existing large reports migrate lazily. Land order: SCOPE-1 → SCOPE-3 → SCOPE-2 → SCOPE-4/5/6. Does NOT compact or rewrite any existing report in the proposal session.

## Risks & mitigations

- **R1** receipts weakening the raw-proof bar → the receipt IS the machine-verifiable proof; G083 still requires it and anti-fabrication rejection is tested (SCOPE-5).
- **R2** targeted invalidation letting a real regression pass → unknown/unparseable changes stay conservative; semantic digests require reproducible tooling, never a vague hash.
- **R3** execution substates being mistaken for certification → substates are namespaced separately; `implement`/`test` are mechanically forbidden from writing `certification.*` (G056/G057 unchanged).

## Acceptance criteria (when implemented)

- A `report.md` cites bounded receipts + a certifying window instead of re-pasting raw output; total size stays bounded across review rounds.
- An unrelated/formatter-only change reuses prior green receipts; a behavior-changing validator change invalidates exactly the intersecting receipts.
- A scope with green implementation + focused tests shows an honest execution substate (`implemented`/`independently_verified`) while certification remains validate-owned and non-`done`.
- `framework-validate.sh` + the state-transition performance tests pass; anti-fabrication still rejects missing raw evidence.

## Files to touch (on approval)

`bubbles/scripts/tool-log.sh` (receipt fields + input fingerprint), `bubbles/scripts/state-transition-guard.sh` + selftest (receipt citation + execution substate + targeted-invalidation checks; G083 preserved), `agents/bubbles_shared/critical-requirements.md` + evidence/compaction modules (receipt + certifying-window contract), `agents/bubbles.test.agent.md` + `agents/bubbles.implement.agent.md` (write execution substate, never `certification.*`), `agents/bubbles.validate.agent.md` (certification stays validate-owned), state.json schema doc (additive substate fields) — name the owning agent/gate for each surface. Composes with IMP-023 (concurrent-change case) and IMP-004 (coverage ownership).
