# IMP-022 — Mechanical Vertical-Delivery Planning Guard

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** Multi-session convergence observations (2026-07, Research Lab Feature 010) — planning produced 14 sequential scopes (foundations first, UI at Scope 09, registry/consumer integration at Scope 13, real canaries at Scope 14). The plan passed every planning check while no early scope could deliver a registered, usable tool.
**Verified gaps addressed:** vertical-slice preference is behavioral not mechanical (VDP1), no time-to-first-usable-outcome check (VDP2), no risk-adjusted scope budget (VDP3), consumer-timing deferral undetected (VDP4).

## Problem (verified against source)

- **VDP1 — the rule exists but is not decisive.** `agents/bubbles.plan.agent.md` and the shared planning core already *prefer* vertical slices and name horizontal planning the primary planning failure, but the preference is prose guidance with no mechanical gate. A horizontal plan can satisfy every existing planning check. (VDP1)
- **VDP2 — no "time to first usable outcome" check.** Nothing verifies that the FIRST delivery increment is consumer-usable. Feature 010's plan deferred the UI to Scope 09, registry/consumer wiring to Scope 13, and end-to-end canaries to Scope 14 — every consumer-visible surface postponed to the tail — and still validated. (VDP2)
- **VDP3 — no risk-adjusted scope budget.** There is no ceiling on active scope count or delivery-increment count, and no link between plan size and risk tier. A build-free, low-risk single-file tool can legitimately fan out to 14 scopes with no warning. (VDP3)
- **VDP4 — consumer timing undetected.** First-party consumer work (registry, navigation, CLI, API-client registration) that is REQUIRED for the feature to be usable can be sequenced last without any mechanical objection. (VDP4)

## Proposal

Add a **mechanical vertical-delivery planning-quality contract** that raises plan quality without weakening scenario or test integrity. It composes with (and is the natural planning-time partner of) the IMP-021 `rapid-tool-delivery` risk tier.

### SCOPE-1 — time-to-first-usable-outcome check (VDP2)

- For a user-facing feature, mechanically assert that the first delivery increment includes: the route/UI (or operator surface), a minimum real data/contract path, consumer registration when required, and an end-to-end scenario. A plan that defers ALL consumer-visible behavior to late scopes **fails** unless an explicit, validated high-risk foundation rationale is present.

### SCOPE-2 — risk-adjusted scope budget (VDP3)

- Allow project profiles to declare a maximum active-scope and delivery-increment count. A low-risk, build-free tool should normally fit within **≤3 delivery increments and ≤5 active scopes**; exceeding the budget requires an explicit complexity/risk explanation and an owner-visible warning (advisory-until-configured) or block (when the profile opts in). Budgets bind to the IMP-021 risk tier so the ceiling scales with real risk.

### SCOPE-3 — horizontal-sequence detection (VDP1)

- Mechanically inspect consecutive scope *surfaces* and dependency order to detect a foundation-only chain that lacks a runnable vertical checkpoint. Detection is structural (surface + dependency graph), **not** keyword co-occurrence — it must not merely count the words database/service/UI. It flags the first sequence that ships no consumer-runnable increment.

### SCOPE-4 — consumer-timing rule (VDP4)

- Registry, navigation, CLI, API-client, or other first-party consumer work that is required for usability cannot be postponed to the end. **Preserve** the protected high-fan-out canaries and rollback boundaries (a genuinely last-mile canary is legitimate); the rule targets *required-for-usability* consumers deferred behind unrelated foundations.

### SCOPE-5 — scenario & DoD preservation (integrity guard)

- Vertical consolidation MAY remap stable scenarios across increments but MUST NOT silently drop scenario IDs, tests, DoD parity, or hard constraints. The guard verifies scenario-ID conservation and DoD parity across a restructure so plan-quality enforcement never becomes a coverage-reduction path.

### SCOPE-6 — actionable remediation + fixtures (VDP1–VDP4)

- On failure, the guard identifies the FIRST non-shippable sequence and tells `bubbles.plan` how to restructure it into vertical increments (concrete, not prose). Ship hermetic positive and negative fixtures, including a **Feature-010-shaped 14-scope horizontal negative case** and a vertical-slice positive twin.

### SCOPE-7 — placement decision (no overlapping enforcement)

- **Recommendation:** implement as a new `bubbles.plan`-owned planning gate (e.g. `vertical-delivery-plan-guard.sh`) rather than folding it into an existing gate — the existing planning checks assert artifact shape, not delivery-increment quality, so a dedicated guard avoids overloading them. It runs in the planning chain for BOTH `full-delivery` and `rapid-tool-delivery` (IMP-021). Avoid generated-source drift by registering it through the normal gate-registry + `regen-derived.sh` path.

## Migration / rollout

- SCOPE-1/3/4/5/6 land as one `bubbles.plan` gate that is **advisory-until-configured** by default (warns, does not block) so existing repos are unaffected; a project opts into blocking via its profile. SCOPE-2 budgets default to the low-risk envelope only when the IMP-021 risk tier resolves `low-risk`. Sequencing: gate + fixtures first (advisory), then per-project blocking opt-in.

## Risks & mitigations

- **R1** false-positive on a legitimate foundation-first plan → the high-risk foundation rationale escape valve + advisory-until-configured default; blocking only when a profile opts in.
- **R2** enforcement becoming a coverage-reduction path → SCOPE-5 scenario-ID + DoD-parity conservation is itself gated.
- **R3** overlap with existing planning checks → SCOPE-7 keeps it a dedicated, additively-registered guard; no existing check is modified.

## Acceptance criteria (when implemented)

- The Feature-010-shaped 14-scope negative fixture **fails** the guard with a remediation pointer to the first non-shippable sequence; the vertical positive twin passes.
- A low-risk plan exceeding ≤3 increments / ≤5 active scopes without rationale raises the configured warning/block; a within-budget plan passes.
- Scenario-ID conservation + DoD parity are verified across a restructure (dropping a scenario ID fails).
- `framework-validate.sh` passes; the guard is registered and generated surfaces regenerate consistently.

## Files to touch (on approval)

`bubbles/scripts/vertical-delivery-plan-guard.sh` + `vertical-delivery-plan-guard-selftest.sh` (new `bubbles.plan` gate + hermetic fixtures, wired into `framework-validate.sh`), `bubbles/registry/gates.yaml` + generated gate block (`regen-derived.sh`), `agents/bubbles.plan.agent.md` + `agents/bubbles_shared/scope-workflow.md` (vertical-increment contract + remediation contract), `agents/bubbles_shared/project-config-contract.md` (scope-budget profile field), `docs/guides/*` planning docs — name the owning agent/gate for each surface. Composes with IMP-021 (risk tier).
