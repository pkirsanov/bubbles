# IMP-003 — Autonomy Dial + Session Safety Caps

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** 4-pass agent-ecosystem audit (2026-07)
**Verified gaps addressed:** no session/cost cap (A1), no run-level rollback / dry-run (A2), no single autonomy level (A4), dormant grill + clarify (passes 1-2).

## Problem (verified against source)

- **No single "autonomy level."** 8+ independent flags govern autonomy: `socratic`, `grillMode`, `lockdown`, `autoCommit`, `gitIsolation`, `microFixes`, `parallelScopes`, `maxScopeMinutes`/`maxDodMinutes`. `defaultPolicyBehavior.grillDefault: off`; grill's `interrogate` phase runs in 0 modes; the `grillMode` plumbing exists in `executionOptions` but is dormant. `bubbles.clarify` is in the planning-only auto-escalation allowlist (`workflow-orchestration-core.md`) and is the `decisionPolicy` `route_to_clarify` overflow target, but is a first-class phase in 0 modes. (A4 + passes 1-2)
- **No session-level cap.** G082 (`convergence-cap-guard`) caps convergence per `(specDir, agent)` at 10 iterations. A `sprint` of N goals = N×10 with **no aggregate session ceiling**. There is **no token / $ / tool-call budget anywhere**, and `sprint`'s time budget is **advisory** (no gate enforces it). (A1)
- **No run-level rollback and no dry-run.** `autoCommit` is per-scope only; there is no atomic whole-run undo. The only preview is `parallelScopes=dag-dry` (shows the DAG, not the changes) — there is no propose-only/dry-run for `goal`/`sprint`/`iterate`. (A2)

## Proposal

### SCOPE-1 — single `autonomy:` level (`executionOptions`)

- Add `autonomy: full | guarded | interactive` (default `full` = current behavior). It is a convenience alias that sets the underlying flags; explicit flags still override.
  - `full`: `grillMode=off`, `socratic=false`, decisionPolicy auto-resolves — 100% autonomous (today's default).
  - `guarded`: `grillMode=required-on-ambiguity`, conditional `clarify` consistency gate — stop ONLY on genuine ambiguity.
  - `interactive`: `grillMode=on-demand` + `socratic=true`, taste decisions surfaced — human-in-the-loop.

### SCOPE-2 — session-level budget caps (A1)

- Add `executionOptions.sessionBudget: { maxTotalConvergenceIterations: null, maxWallClockMinutes: null, maxToolCalls: null }`, consumed by `goal`/`sprint`/`iterate`. **(Advisory config shipped earlier — see CHANGELOG [Unreleased] / IMP-003.)**
- Make `sprint`'s time budget MECHANICAL: **✅ IMPLEMENTED as Gate G128 (`session_cap_enforcement_gate`)** — a sibling `bubbles/scripts/session-cap-guard.sh` (the aggregate counterpart to G082's per-`(specDir, agent)` `convergence-cap-guard.sh`) reads the recorded `sessionBudget` from `.specify/memory/bubbles.session.json` and, when a non-null cap is present, stops the session (exit 1, finding `G128`) when the AGGREGATE usage across all specs (summed convergence iterations, earliest→latest wall-clock minutes, or `toolCallCount`) exceeds its cap, so the orchestrator emits a `blocked` RESULT-ENVELOPE. Default `null` = unbounded (today's behavior), opt-in — the guard is a NO-OP for every existing repo. Wired into `state-transition-guard.sh` (Check 40) and `framework-validate.sh` (selftest + live guard); hermetic selftest `session-cap-guard-selftest.sh`; persistent regression `tests/regression/test_22_session_cap_enforcement.sh`. No `--skip`/`--force`/`--ignore` bypass (matches G082).

### SCOPE-3 — dry-run / propose-only + run rollback (A2)

- Add `executionOptions.dryRun: false | plan`. `plan` = resolve the full plan (specs/scopes/intended changes) and REPORT without mutating code/state — extends the `parallelScopes=dag-dry` idea to the whole loop.
- Document a run-level rollback story: when `gitIsolation=true`, the whole run lives on an isolated branch/worktree; a failed run is abandoned by dropping the branch (clean rollback), versus today's per-scope commits on the working branch.

### SCOPE-4 — activate grill + conditional clarify (passes 1-2)

- Wire the `interrogate` phase into delivery modes gated on `grillMode != off` (guarded/interactive turn it on; `full` skips it — 100% autonomous preserved).
- Wire `clarify` as a conditional consistency gate in the planning chain, triggered by ambiguity / taste-decision overflow (`route_to_clarify` already exists). Dedupe from grill: `clarify` = structured consistency routing; `grill` = adversarial pressure-test.

## Migration / rollout (additive + default-preserving)

- `autonomy` defaults to `full` (today's behavior); `sessionBudget` fields default `null` (unbounded, today); `dryRun` defaults `false`. No existing run changes unless opted in.

## Risks & mitigations

- **R1** autonomy alias vs explicit flags → explicit flags win; document precedence.
- **R2** mechanical time-budget complexity → start advisory (warn), promote to blocking behind the `sessionBudget` opt-in.
- **R3** grill/clarify latency → they fire only under `guarded`/`interactive` or on detected ambiguity; `full` stays 100% autonomous.

## Acceptance criteria (when implemented)

- `executionOptions` has `autonomy`, `sessionBudget`, `dryRun` with documented precedence.
- `interrogate` phase runs under `grillMode != off`; conditional `clarify` gate wired.
- `framework-validate.sh` passes; a sibling session-cap guard added with a hermetic selftest. **✅ IMPLEMENTED — Gate G128 (`session-cap-guard.sh` + `session-cap-guard-selftest.sh`); the advisory `sessionBudget` config shipped earlier, the mechanical gate ships now.**

## Files to touch (on approval)

`bubbles/workflows.yaml` (executionOptions, decisionPolicy, phase wiring), `bubbles/workflows/modes.yaml` (interrogate/clarify conditional wiring), `agents/bubbles.goal.agent.md` + `agents/bubbles.sprint.agent.md` + `agents/bubbles.iterate.agent.md` + `agents/bubbles.workflow.agent.md` (consume autonomy + sessionBudget + dryRun), `bubbles/scripts/` (session-cap guard + selftest, wired into framework-validate.sh), `agents/bubbles_shared/operating-baseline.md` (autonomy/budget operating docs).
