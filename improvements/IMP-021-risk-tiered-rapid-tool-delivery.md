# IMP-021 — Risk-Tiered Rapid Tool-Delivery Mode

**Status:** IMPLEMENTED (eligibility resolver primitive, reuse-first, 2026-07-17) — `risk-tier-resolve.sh` mechanizes SCOPE-1: a FAIL-CLOSED classifier that resolves `rapid-tool-delivery` ONLY on a positive low-risk signal AND no high-risk trigger (auth/payments/secrets/PII/DB-migration/deploy/prod/host-singleton/cross-product), so risky work can never be self-labeled low-risk. Reuse-first: it adds NO budget mechanism (Gate G128 already provides aggregate budgets) and does NOT itself register a mode — defaulting an existing focused mode + setting G128 budgets + wiring this router (SCOPE-2..5) is the follow-up.
**Surface:** framework-health (G125) — reuse-first (resolver only; reuses G128 budgets; fail-closed to `full-delivery`)
**Motivation:** Multi-session convergence observations (2026-07, Research Lab Feature 010) — a build-free static tool was driven through the maximum-assurance `full-delivery` chain, accumulating a roughly day-long parent session, ~1,277 unique tool calls, 14 sequential scopes, and 11k+ planning/evidence lines before a single increment was marked complete.
**Verified gaps addressed:** no risk-tiered delivery path (RTD1), maximum-assurance default for low-risk work (RTD2), no bounded rapid convergence envelope (RTD3).

## Problem (verified against source)

- **RTD1 — one delivery weight for every risk class.** `bubbles/workflows.yaml` declares `defaultMode: full-delivery`, and `full-delivery` carries the maximum-assurance chain (planning, implementation, test, regression, simplify, gaps, harden, stabilize, devops, security, validate, audit, chaos, red-team, docs, finalize). There is no lighter *sanctioned* path: a build-free/static or fully-isolated low-risk change either runs the full chain or is hand-steered ad hoc outside the mode registry. (RTD1)
- **RTD2 — low-risk work pays the maximum-assurance tax.** Feature 010 was a single-file, build-free static tool with no auth/payments/secrets/PII/DB-migration/deploy/cross-product surface, yet it consumed the full 18-phase envelope before one usable increment shipped. The cost is not a defect in `full-delivery` (its bar is correct for risky work) — it is the absence of a *risk-tiered* alternative. (RTD2)
- **RTD3 — the budget primitive exists but no mode sets it.** IMP-003 shipped `executionOptions.sessionBudget` (`maxTotalConvergenceIterations | maxWallClockMinutes | maxToolCalls`, default `null` = unbounded) and Gate **G128** (`session_cap_enforcement_gate`, `bubbles/scripts/session-cap-guard.sh`, registered `bubbles/registry/gates.yaml`) *mechanically* enforces it against the recorded `.specify/memory/bubbles.session.json`. The caps are opt-in and default-`null`; no workflow mode ships non-null defaults, so nothing bounds a low-risk run today. The mechanism is present and correct — it is simply unused by any mode. (RTD3)

## Proposal

Add a **risk-tiered `rapid-tool-delivery` mode** that reuses (never forks) the existing budget, gate, ownership, and anti-fabrication machinery. Every scope below is additive and default-preserving — `full-delivery` remains the default and is unchanged.

### SCOPE-1 — mechanical low-risk eligibility resolver (RTD1)

- Add a read-only `risk-tier-resolve.sh` (sibling to the existing mode/transition resolvers) that classifies a request as `low-risk` ONLY when ALL hold: build-free/static OR isolated application change; and NONE of the high-risk triggers are present — auth, payments, secrets, PII, database migration, deployment topology, production mutation, host-singleton change, or cross-product/contract change.
- Any high-risk trigger forces escalation to `full-delivery`. Eligibility is **mechanical and evidence-derived** (declared surface + changed-path families), NOT a self-asserted label — a user cannot tag risky work `low-risk` to shed gates. Unknown/unparseable surface fails **closed** to `full-delivery`.

### SCOPE-2 — bounded rapid phase chain (RTD1, RTD2)

- Register `rapid-tool-delivery` with the chain `select → implement → test → validate → docs → finalize`, with a `bootstrap` planning phase inserted ONLY when required artifacts are genuinely absent.
- **Preserve every universal gate**: anti-fabrication, artifact-ownership, test-integrity, implementation-reality, and the outcome/result-envelope contract all still apply. The mode removes *assurance breadth appropriate to risk* (chaos, red-team, security threat-model, stabilize, devops), NOT integrity. It carries a `statusCeiling` no higher than `full-delivery`'s and never certifies beyond what validate owns.

### SCOPE-3 — non-null default budgets via G128 (RTD3)

- Ship `rapid-tool-delivery` with **non-null** `sessionBudget` defaults (initial proposal: `maxTotalConvergenceIterations: 2`, `maxWallClockMinutes: 90`, `maxToolCalls: 250`), consumed by G128 unchanged. **Do not duplicate the budget mechanism and do not allocate a competing gate** — this scope only sets values the shipped gate already reads.
- Hitting a cap ends the run with a **truthful bounded status** (`blocked` result-envelope naming the exceeded cap), NEVER an automatic fresh convergence loop. `full-delivery` keeps its `null` (unbounded) defaults.

### SCOPE-4 — vertical-slice planning envelope (RTD2)

- In `rapid-tool-delivery`, cap active planning to a few vertical scopes and require an **early shippable outcome** (the first increment must be consumer-usable, composing with the vertical-plan guard proposed in IMP-022). When a feature cannot fit the risk/size envelope, the mode escalates to full planning rather than silently sprawling.

### SCOPE-5 — deterministic NL routing (RTD1)

- Wire the risk resolver into `intent-routes.yaml` / `bubbles.super` so a natural-language delivery request is routed to `rapid-tool-delivery` vs `full-delivery` by the mechanical tier, not by keyword. **Recommendation:** keep `defaultMode: full-delivery` and add a *risk resolver* that selects `rapid-tool-delivery` only on a positive low-risk classification — safer than flipping the global default, and fail-closed by construction.

### SCOPE-6 — reconcile IMP-003 / G128 wording (RTD3)

- Update the IMP-003 SCOPE-2 and any doc wording that still calls the session cap "advisory": G128 is **mechanical** today. This scope only records the reconciliation to perform on approval; it does **not** mutate IMP-003 or the gate in this proposal session (G125).

## Migration / rollout (additive + default-preserving)

- `full-delivery` remains `defaultMode` with `null` budgets — no existing run changes. `rapid-tool-delivery` is opt-in via the risk resolver; a request that fails low-risk classification is untouched. Sequencing: SCOPE-1 (resolver) → SCOPE-2/3 (mode + budgets) → SCOPE-4/5 (planning + routing) → SCOPE-6 (doc reconciliation). Composes with IMP-022 (vertical-plan guard) but does not require it.

## Risks & mitigations

- **R1** low-risk misclassification shedding needed gates → resolver is fail-closed (unknown → `full-delivery`), mechanical (not self-labeled), and high-risk triggers are hard escalations.
- **R2** budget too tight, starving legitimate work → budgets are per-mode config; a run that hits a cap ends with a truthful bounded status and can be re-dispatched under `full-delivery`, never silently continued.
- **R3** two delivery modes drifting → `rapid-tool-delivery` reuses the SAME gate/budget/ownership primitives; only breadth-of-assurance differs, and held-out eval (below) proves both tiers behave.

## Acceptance criteria (when implemented)

- A low-risk build-free fixture reaches a usable, validated increment through `rapid-tool-delivery` with **materially fewer phases and tool calls** than `full-delivery`, while every high-risk fixture still selects `full-delivery`.
- `risk-tier-resolve.sh` + hermetic selftest prove the closed low-risk set, each high-risk escalation trigger, and the fail-closed unknown case; wired into `framework-validate.sh`.
- G128 stops a `rapid-tool-delivery` run that exceeds any non-null cap with a truthful `blocked` envelope (no auto-restart); `full-delivery` unbounded behavior is unchanged.
- `framework-validate.sh` passes; generated surfaces (CATALOG, CHEATSHEET, WORKFLOW_MODES, framework-stats, HTML cheatsheet) regenerate consistently.

## Files to touch (on approval)

`bubbles/workflows.yaml` (register `rapid-tool-delivery`, phase chain, `statusCeiling`, per-mode `sessionBudget` defaults), `bubbles/scripts/risk-tier-resolve.sh` + `risk-tier-resolve-selftest.sh` (new resolver + selftest, wired into `framework-validate.sh`), `bubbles/intent-routes.yaml` + `agents/bubbles.super.agent.md` (risk-tiered routing), `agents/bubbles.goal.agent.md` (consume rapid tier as an outcome path), `improvements/IMP-003-autonomy-dial-and-safety-caps.md` (advisory→mechanical wording reconciliation), `docs/guides/WORKFLOW_MODES.md` + generated cheatsheets/stats via `regen-derived.sh` — name the owning agent/gate for each surface so implementation routes correctly. Composes with IMP-022 (`bubbles.plan` vertical-plan guard).
