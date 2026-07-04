# IMP-001 — bubbles.journey: Guided Post-Implementation Journey & Scenario Refinement

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** 4-pass agent-ecosystem audit (2026-07)
**Verified gaps addressed:** voice-of-user void (P3), learning-loop blind to user signal (S3), reactive priorityScoring, static uservalidation.md

## Problem (verified against source)

Bubbles has strong process integrity but three verified blind spots at the human edge:

1. **No first-class capture path for user experiential feedback from the LIVE product.** `uservalidation.md` is a static human checklist — its template (`agents/bubbles_shared/feature-templates.md`) is a minimal `- [x]` list; G010 only checks it EXISTS and is updated; G057 keeps it a human-only surface that must NOT mirror automation. Nothing *drives* it.
2. **`priorityScoring.userImpact` (weight 30, the top weight) is regression-REACTIVE, not friction-PROACTIVE.** Its guidance is "user-facing regression / core journey break / workflow degradation / operator inconvenience." Nothing scores "a user tried it and it was confusing."
3. **The learning loop is blind to user signal.** `skillEvolution` (`.specify/memory/lessons.md`), `developerProfile` (git diffs + taste decisions), and `lessonsMemory` learn only from agent-execution patterns.

Consequently, "the user walked the live product and it felt wrong" becomes work ONLY via manual bug/spec filing. No agent walks the user through the running product toward a goal, captures friction, and routes it.

No existing agent covers this: `chaos` = stochastic/random journeys (no user, no goal); `redteam` = adversarial attack on the "done" claim (no user); `grill` = pre-build artifact pressure-test (no runtime); `ux`/`analyst` = design-time scenario authoring (not runtime-with-user); `uservalidation.md` = static human checklist. `bubbles.redteam` itself frames the split: "grill pressure-tests ideas pre-build, redteam attacks finished results." journey is the missing THIRD stance: **cooperative-guided on finished results, WITH the user.**

## Proposal

Add `bubbles.journey`: a guided, collaborative, goal-driven walkthrough of the LIVE running product WITH the user. It drives the real UI (Playwright), validates internal APIs, reads telemetry/traces, captures friction, refines scenarios collaboratively, then routes concerns into planning/implementation. It is the cooperative-guided complement to `chaos` (random) and `redteam` (adversarial).

### SCOPE-1 — The agent (`agents/bubbles.journey.agent.md` + `prompts/bubbles.journey.prompt.md`)

- **Role:** Guided post-implementation journey & scenario refinement.
- **Always requires an explicit user GOAL** (e.g. "rebalance my portfolio"; "see this month's expenses in QuickBooks"). Every session has a goal + a success signal.
- **Session shape:** (1) resolve goal + success signal; (2) drive the live product step-by-step toward the goal via Playwright/API; (3) at each step capture what the user expected, what happened, telemetry/API evidence, and a friction verdict `{works | unclear | inconvenient | missing | broken}`; (4) collaboratively refine the scenario with the user; (5) classify each finding `{usability-gap | missing-feature | actual-bug | works}` and route via the discovered-issue disposition (G095).
- **Artifact ownership:** OWNS/activates `uservalidation.md` (the human acceptance surface). May append to `report.md` `## Discovered Issues`. Does NOT edit `spec.md`/`design.md`/`scopes.md` — routes to owners.
- **Tools:** Playwright (drive UI), the trace-capture skills (telemetry/SLO), API validation. Read-mostly on the system; mutates only `uservalidation.md` + emits route packets.
- **Handoffs:** → `bubbles.grill` (pressure-test a proposed refinement before speccing) → `bubbles.analyst`/`bubbles.ux`/`bubbles.design`/`bubbles.plan` (spec a refinement) → `bubbles.bug` (a real defect) → `bubbles.redteam` (adversarial follow-up on a suspicious path).
- **RESULT-ENVELOPE:** `completed_diagnostic` (friction captured + routed) | `route_required` (refinement needs a specialist) | `blocked` (goal unreachable in the live product).
- **Skills-First Pointers:** bubbles-evidence-capture, bubbles-result-envelope, bubbles-artifact-ownership-routing, bubbles-anti-fabrication, plus the project trace-capture skill.

### SCOPE-2 — `journey` phase + `journey-refinement` mode

- New phase `journey` in `bubbles/workflows.yaml` `phases:` — owner `bubbles.journey`, `requiredGates: [ G010 ]`.
- New mode `journey-refinement` in `bubbles/workflows/modes.yaml`: `statusCeiling: docs_updated` (read-only on code), `phaseOrder: [ select, journey, docs, finalize ]`. Runs against a live stack; produces refined `uservalidation.md` + route packets.
- Optional post-`finalize` hook: append `journey` to `full-delivery` `phaseOrder` gated on a new `guidedJourney: true` executionOptions tag (default off) so autonomous runs skip it and human-in-the-loop runs get the walkthrough.

### SCOPE-3 — `experientialFriction` scoring dimension

- Add `experientialFriction` to `priorityScoring.dimensions` (proactive). Rebalance weights so the total stays 100 (e.g. `userImpact 25` + `experientialFriction 10`; keep userImpact dominant). Guidance 0-5: `5` = user-reported core-journey friction blocking goal completion; `3` = repeated confusion on a high-value flow; `1` = minor polish. Sourced from journey findings.
- Add tie-breaker `highest_experientialFriction` after `highest_userImpact`.

### SCOPE-4 — `uservalidation.md` activation (G057 boundary preserved)

- `uservalidation.md` remains the HUMAN acceptance surface — journey MUST NOT auto-check human acceptance items (G057). journey STRUCTURES it: goal, steps attempted, per-step friction verdict + evidence link, open refinements. G010 unchanged. Template updated additively in `feature-templates.md`.

### SCOPE-5 — intent routing

- Add `bubbles/intent-routes.yaml` entries: "walk me through X", "help me use X", "refine the <goal> journey", "let's try the product" → `bubbles.journey` (or the `journey-refinement` mode).

## Observability synergy

journey consumes the SAME validate-plane telemetry the framework already gates (G098-G100 + trace-capture skills). On a `wired` repo, a journey session can attach captured SLO/trace evidence to each friction finding — strengthening both the finding and the observability posture.

## Migration / rollout (fully additive, default-off)

- New agent + prompt shim + phase + mode + optional tag. No existing mode changes behavior unless `guidedJourney: true`.
- The priorityScoring weight rebalance is the only change to existing config; keep the total at 100 and document it.
- No gate becomes blocking; G010 is unchanged.

## Risks & mitigations

- **R1** journey overlaps chaos/ux → crisp Non-goals (cooperative-guided vs stochastic vs design-time).
- **R2** live-product access needed → journey requires a running stack (dev/validate plane); document the prerequisite; degrade to API-only if no UI.
- **R3** uservalidation automation-mirroring (G057) → journey records observations; the human accepts. journey never toggles acceptance items.
- **R4** scoring rebalance disturbs prioritization → keep userImpact dominant; experientialFriction additive and modest.

## Acceptance criteria (when implemented)

- `agents/bubbles.journey.agent.md` + `prompts/bubbles.journey.prompt.md` exist with uniform structure incl. Skills-First Pointers.
- `bubbles/workflows.yaml`: `journey` phase (owner + G010); priorityScoring has `experientialFriction`; executionOptions has `guidedJourney`.
- `bubbles/workflows/modes.yaml`: `journey-refinement` mode; optional guidedJourney-gated `journey` in `full-delivery`.
- `bubbles/intent-routes.yaml`: journey routes.
- `framework-validate.sh` passes; mode-resolver resolves `journey-refinement`; no gate-registry drift.

## Files to touch (on approval)

`agents/bubbles.journey.agent.md` (new), `prompts/bubbles.journey.prompt.md` (new), `bubbles/workflows.yaml` (phases, priorityScoring, executionOptions), `bubbles/workflows/modes.yaml` (journey-refinement + optional hook), `bubbles/intent-routes.yaml`, `agents/bubbles_shared/feature-templates.md` (uservalidation template), `skills/INVENTORY.md` (if a journey skill is added).
