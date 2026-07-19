fs and filal brief, commit, push# IMP-100 — Master Systematic Improvement Plan (Uber Doc)

**Status:** PROPOSED (not yet applied) — awaiting owner review · authored 2026-07-18
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved.
**Supersedes / absorbs (with full executable detail preserved below):** IMP-001, IMP-002, IMP-003, IMP-004, IMP-005, IMP-020, IMP-021, IMP-022, IMP-024, IMP-026, and the BUG-012…BUG-026 defect packets. The individual files are consolidated here; their verbatim originals remain in git history.
**Provenance (all re-checked against local source; external material is design input, not execution evidence):** (1) the 4-pass agent-ecosystem audit (2026-07) → IMP-001..005; (2) multi-session convergence observations (Research-Lab Feature 010) → IMP-021/022/024 + IMP-020; (3) the MIT-licensed `mattpocock/skills` comparative review → IMP-026; (4) the delivery-weight / pre-push / terminal-state review (R1–R12).

---

## 1. The spine (why every item belongs to ONE program)

Bubbles' philosophy is fixed and correct: **anti-fabrication, evidence-based completion, ownership boundaries, build-once-deploy-many, reuse-first, honest-derived state.** Every problem below is the *same* deviation — rigor applied uniformly instead of proportionally to risk, progress invisible until the end, work unbounded (context, repo, evidence).

> **Thesis: make assurance PROPORTIONAL to risk, make progress HONEST and VISIBLE, make work BOUNDED — without ever weakening integrity.**

Every change satisfies the §7 coherence guardrails or is rejected. This is one arc delivered in dependency order, not a bag of patches.

---

## 2. Reconciliation ledger (nothing orphaned)

| Source | Prior status | Phase | Pillar |
|---|---|---|---|
| IMP-021 risk-tiered rapid delivery | resolver primitive only | 1 | Proportional |
| IMP-003 autonomy dial + session budgets | proposed (G128 gate ✅) | 1 (budgets) + 4 (dry-run/rollback) | Bounded |
| IMP-024 evidence receipts + progress substates | terminal rule only | 2 | Honest |
| Terminal states `done`/`delivered_fast`/`delivered_prototype` (R4) | new | 2 + 3 | Proportional/Honest |
| Assurance-gated deploy (R5) | new | 3 | Proportional |
| IMP-022 vertical-delivery plan guard | advisory core only | 4 | Bounded |
| IMP-026 interaction discipline + context-efficient planning | proposed | 2 + 4 + 5 | Bounded/Honest |
| IMP-004 verification boundaries + coverage gaps | proposed | 4 | Bounded |
| Work-boundary / anti-wander (R6) | new | 4 | Bounded |
| Pre-push validation cost (R7/R8/R9) | new | 5 | Proportional (dogfooded) |
| IMP-002 readiness-review + diagnostic-agent overlap (R10) | proposed | 5 | Proportional |
| Gate consolidation (R11) | ongoing (8 done) | 5 | Reuse-first |
| IMP-020 agentic evaluation + trust hardening | S1–S3 done, S4–S7 pending | 6 | Honest |
| IMP-001 journey agent (voice-of-user) | proposed | 6 | Honest |
| IMP-005 framework housekeeping | SCOPE-1 done; rest proposed | 6 | Reuse-first |
| BUG-012…BUG-026 | ✅ all 11 done | 0 | Honest (state machine) |

### Reconciliation 2026-07-19 (verified against source — the plan understated completion)

A source audit (grep the defining identifier of each SCOPE; done ⇔ present + green selftest) shows the true remaining surface is smaller than the phase structure implies:

- **✅ DONE (verified):** Phase 0 (all 11 defects). Phase 1 COMPLETE — SCOPE-1 `risk-tier-resolve` (`riskClass`/`minimumAssurance`), SCOPE-2/3 `rapid-tool-delivery` mode + per-mode G128 budget, SCOPE-4 risk-adjusted scope budget (low-risk tier ≤5 scopes/≤3 increments in `vertical-delivery-plan-guard.sh`), SCOPE-5 NL routing, SCOPE-6 advisory→mechanical wording. Phase 4 SCOPE-7 vertical-delivery-plan-guard **blocking mode** (`verticalPlanGuard: block` opt-in already works). Phase 5 SCOPE-1/2 `readiness-review` mode + validate-owned `readinessVerdict`. Phase 6 IMP-001 `journey` phase/agent + `guidedJourney` + `experientialFriction`.
- **⛔ GENUINELY REMAINING (absent in source):** Phase 2 execution substates (`implemented`/`independently_verified`/`needs_reverification`) + evidence receipts; R4 terminal states `delivered_fast`/`delivered_prototype`. Phase 3 assurance-gated deploy (`minimumAssurance` in release reconciliation + adapter preflight prototype-refusal). Phase 4 R6 `workBoundary`. Phase 6 IMP-020 S4–S7 (held-out eval / effective-bundle) + IMP-005 SCOPE-2–5.
- **Method:** each remaining item is a multi-file vertical (schema/field + mechanical guard + hermetic selftest wired into `framework-validate` + agent contract) per the §10 guardrails; verify-before-implement to avoid re-doing shipped work.


---

## 3. Phase 0 — Stabilize the state machine (foundation; unblocks everything) ✅ COMPLETE

**Reconciliation 2026-07-19 (verified against source + green tests): all 11 Phase-0 defects are DONE.** Already fixed before this session: BUG-012 (`test_04`), BUG-013 (`test_24`), BUG-018 (`test_25`), BUG-019 (`test_26`), BUG-020 (`test_27`), BUG-021 (`test_28`), BUG-022 (`test_29`). Fixed + pushed this session: BUG-025 (`test_32`, `de4ba40`), BUG-024 (`test_31`, `7f35de1`), BUG-023 (`test_30`, `e2c7536`), and **BUG-026** (below).

**BUG-026** traceability sequential-scope + tiered-DoD — DONE (`a620393` + predecessors). Root cause: the guard analyzed a per-scope-dir packet as one all-scope universe even when validated v3 state named one current sequential scope, and it rejected plan-owned tiered DoD that artifact-lint accepts. Fix (shipped): new stdlib fail-closed `scope-universe-resolver.py` + shared bash-3.2-safe `dod-section-lib.sh` consumed by traceability G068 / transition Check 4A/22; `traceability-guard.sh --current-scope` filters to the applicable universe, omitting only exact `not_started` transitive descendants. Regression: `dod-section-lib-selftest` 10/10, `scope-universe-resolver-selftest` 16/16, `test_33` 9/9.

**Done:** BUG-026 terminal; `framework-validate` green on the committed tree (`FRAMEWORK_VALIDATE_EXIT=0`, 2026-07-19).

---

## 4. Phase 1 — Risk-proportional delivery (the churn fix) · absorbs IMP-021 + IMP-003 (budgets) ✅ COMPLETE

**Progress 2026-07-19 (shipped + framework-validate green):** SCOPE-1 `risk-tier-resolve.sh` ✅ (extended to return `riskClass` + `minimumAssurance`, high-risk triggers hard-escalate to `full-delivery`, `22ee85c`). SCOPE-2 `rapid-tool-delivery` mode ✅ REGISTERED in `modes.yaml` (inherits the full delivery integrity contract — every universal gate + anti-fabrication + per-DoD raw evidence + tests-for-all-scenarios + reality scan — and relaxes ONLY `requireCanonicalPlanningChain`; shorter `select→implement→test→validate→docs→finalize` phase order), aliased (`implement action:rapid-tool-delivery target:tool`), intent-routed (`bubbles.goal`, auto-granted via `"*"`), advertised in `bubbles.workflow`, with a dedicated 23-assertion selftest wired into `framework-validate`. SCOPE-3 non-null per-mode `sessionBudget` ✅ (`maxTotalConvergenceIterations:2`, `maxWallClockMinutes:90`, `maxToolCalls:250`) with `bubbles.goal` seeding it into the G128-enforced session file. SCOPE-5 deterministic NL routing ✅ (`intent-routes.yaml` route + `bubbles.super` intent-map row for `rapid-tool-delivery`, resolver-confirmed). SCOPE-6 advisory→mechanical wording ✅ (the `sessionBudget` field meanings + `bubbles.goal` now state the caps are opt-in but MECHANICALLY enforced by G128 when set, matching the G128 gate description). SCOPE-4 risk-adjusted scope budget ✅ (`vertical-delivery-plan-guard.sh` now enforces a low-risk-tier scope budget: when the feature `state.json` carries `workflowMode: rapid-tool-delivery`, active scopes are capped at ≤5 / ≤3 increments — advisory by default, blocking under `verticalPlanGuard: block`; every other mode stays unbounded; 5 new selftest cases T7–T11 prove over-budget-advisory, at-budget-clean, over-budget-block, other-mode-unbounded, absent-state-conservative). **Phase 1 COMPLETE.**

**IMP-021 scopes:** SCOPE-1 mechanical low-risk resolver (`risk-tier-resolve.sh`, fail-closed) ✅ primitive shipped; SCOPE-2 register `rapid-tool-delivery` mode (`select→implement→test→validate→docs→finalize`, preserving every universal integrity gate); SCOPE-3 non-null `sessionBudget` defaults via G128 (initial `maxTotalConvergenceIterations:2`, `maxWallClockMinutes:90`, `maxToolCalls:250`); SCOPE-4 vertical-slice planning envelope (composes IMP-022); SCOPE-5 deterministic NL routing via `intent-routes.yaml` + `bubbles.super`; SCOPE-6 reconcile IMP-003/G128 "advisory→mechanical" wording.
**IMP-003 scopes (this phase):** SCOPE-2 session-level budget caps (A1) — **G128 `session-cap-guard.sh` + selftest ✅ IMPLEMENTED**; ship the non-null per-mode defaults now.
**Extend the resolver:** return `riskClass` + `minimumAssurance` (not just a mode), re-evaluated at intake / post-plan / pre-cert. High-risk triggers (auth, payments, secrets, PII, DB-migration, deploy, prod, host-singleton, cross-product) force `full-delivery`.
**Files:** `bubbles/workflows.yaml` (mode + budgets + routing), `bubbles/workflows/modes.yaml`, `bubbles/scripts/risk-tier-resolve.sh` (+selftest), `bubbles/intent-routes.yaml`, `agents/bubbles.super.agent.md`, `agents/bubbles.goal.agent.md`.
**Acceptance:** a low-risk build-free fixture reaches a validated increment through `rapid-tool-delivery` with materially fewer phases/tool-calls; every high-risk fixture still selects `full-delivery`; G128 stops an over-budget run with a truthful `blocked` (no auto-restart); `full-delivery` unbounded behavior unchanged; `framework-validate` passes.
**Risks:** low-risk misclassification → resolver fail-closed + hard high-risk escalation; too-tight budget → per-mode config, breach re-dispatches under `full-delivery`; two modes drifting → reuse the SAME gate/budget/ownership primitives, only assurance breadth differs.

---

## 5. Phase 2 — Honest, visible progress + quality tiers · absorbs IMP-024 + terminal states + IMP-026 handoff

**Progress 2026-07-19 (R4 terminal-state foundation + fast-lane bug fix, framework-validate green):** (R4a) `transition-contract-resolver.sh` now accepts a mode's declared `terminalAliases[]` as legal terminal current-statuses (previously it only accepted the nominal `statusCeiling`, silently rejecting any alias — a latent gap vs `is-terminal-for-mode.sh`); a mode may now honestly terminate at an alias (e.g. `delivered_fast`) instead of `done`. (R4b) **Fixed a confirmed latent Phase-1 bug**: `rapid-tool-delivery` declared `transitionAudit.profile: delivery-completion-v1` but its phase order intentionally omits `audit`, which that profile requires — so a real fast-lane spec would fail `E009-AUDIT-PROFILE-CONTRADICTION` at its `done` transition (reproduced: exit 72; `framework-validate` missed it because the resolver selftest only enumerated *audit-bearing* done modes). Added the `delivery-completion-fast-v1` audit profile (ceiling `done`, requires `validate`+`implement`+`test`, `audit` NOT required) to the schema enum + resolver, and pointed `rapid-tool-delivery` at it. Resolver selftest +5 (declared/undeclared alias; rapid resolves via the fast profile; fast profile still enforces `test`; enum now the closed 3-set) → 61/0. Remaining R4: give `rapid-tool-delivery` `terminalAliases: [delivered_fast]` + the validate-owned `assurance{…}` metadata block + define which validate outcome emits `delivered_fast` vs `done` (agent-contract) — coupled to Phase 3 deploy-eligibility; execution substates + IMP-024 receipts.


**IMP-024 scopes:** SCOPE-1 structured evidence receipts (raw output stored ONCE in the `tool-log.sh` store with input fingerprint; `report.md` cites receipts + a bounded certifying window) — preserves G083/G005/G009/G083; SCOPE-2 targeted invalidation (a change invalidates ONLY receipts whose declared input closure intersects; unknown stays conservative); SCOPE-3 execution substates `implemented` / `independently_verified` / `needs_reverification` distinct from validate-owned certification (`implement`/`test` MUST NOT write `certification.*`); SCOPE-4 append-only correction + retention + back-compat; SCOPE-5 hermetic test matrix; SCOPE-6 root-cause note (why compaction+evidence-by-reference didn't stop the Feature-010 report loop). Terminal same-session dup-evidence rule ✅ shipped.
**Terminal-state model (R4):** keep `done` (full) unchanged; add terminal-for-mode `delivered_fast` + `delivered_prototype` reusing `statusCeiling`/`terminalAliases`/`is-terminal-for-mode.sh` (the proven `delivered_pending_activation` mechanism); attach validate-owned `assurance{ level, profile, riskClass, minimumAssurance, missingForFull[], assuranceHistory[] }`. Use DISTINCT tokens (not a `done`-suffix) so existing exact-`== "done"` guards (inter-spec-dependency, post-cert, done-audit, regression) never misread them. Display label may read "Done — fast".
**IMP-026 SCOPE-3:** reference-first handoff packets — reduce to the live thread (goal, active phase/scope, unresolved findings, latest evidence result, continuation envelope, pointers), reference durable artifacts instead of restating them, redact secrets/PII, never erase blockers/owner routing.
**Files:** `bubbles/scripts/tool-log.sh` (receipt fields), `bubbles/scripts/state-transition-guard.sh` (+selftest: receipt citation + substates + targeted invalidation; G083 preserved), `agents/bubbles.test.agent.md` + `agents/bubbles.implement.agent.md` (write substates, never `certification.*`), `agents/bubbles.validate.agent.md` (certification stays validate-owned), `agents/bubbles.handoff.agent.md`, state schema doc, `is-terminal-for-mode.sh`.
**Acceptance:** a scope shows honest `implemented` before certification; a `report.md` cites bounded receipts instead of re-pasting and stays bounded across review rounds; an unrelated/formatter-only change reuses prior green receipts while a behavior change invalidates exactly the intersecting receipts; the three tiers resolve through `is-terminal-for-mode.sh` with no consumer breakage.
**Risks:** receipts weakening the raw-proof bar → the receipt IS the machine-verifiable proof; substates mistaken for certification → namespaced separately, `implement`/`test` mechanically forbidden from `certification.*`.

---

## 6. Phase 3 — Assurance-gated deployment (`delivered_prototype` can never ship) · R5

Enforce assurance at the five existing choke points: (1) certification derives assurance + deploy-eligibility; (2) G101 release-delivery reconciliation accepts a required feature only at the train's minimum assurance; (3) release cut/promote checks every included required feature; (4) the signed build-manifest carries assurance level/profile/evidence digest; (5) the deployment adapter preflight verifies it and ALWAYS refuses `prototype`. `delivered_fast` deploys only when `riskClass` ≤ target/train policy. Extends build-once-deploy-many with an assurance dimension.
**Files:** `bubbles/scripts/release-delivery-reconciliation-guard.sh`, `release-train-guard.sh`, deployment-target skill/instruction (adapter preflight + build-manifest schema), certification path in `state-transition-guard.sh`.
**Acceptance:** a prototype-tier spec is mechanically refused at every deploy choke point; a fast-tier spec deploys only within declared risk policy; high-risk work always requires `full`.

---

## 7. Phase 4 — Bounded work (stop sprawl + wandering) · absorbs IMP-022 + IMP-026 (core) + IMP-004 + work-boundary + IMP-003 (dry-run)

**IMP-022 scopes:** SCOPE-1 time-to-first-usable-outcome check; SCOPE-2 risk-adjusted scope budget (≤3 increments / ≤5 active scopes low-risk, bound to the Phase-1 tier); SCOPE-3 horizontal-sequence detection (structural, surface+dependency graph, not keyword co-occurrence); SCOPE-4 consumer-timing rule (required-for-usability consumers can't be deferred behind unrelated foundations; genuine last-mile canaries preserved); SCOPE-5 scenario-ID + DoD parity conservation across a restructure; SCOPE-6 actionable remediation + a Feature-010-shaped 14-scope negative fixture + vertical positive twin; SCOPE-7 dedicated `bubbles.plan` gate `vertical-delivery-plan-guard.sh` (advisory core ✅ shipped; make the budget blocking behind project opt-in).
**IMP-026 scopes (this phase):** SCOPE-6 `contextFit: single-specialist-context` (a fresh specialist can execute a scope from durable artifacts without replaying chat; extend G037; no hardcoded token count); SCOPE-2 wide-refactor **expand→migrate→contract** planning (migrate batches depend on expand, contract depends on all migrates; retain G043/G044/G067/G069; no integration-branch escape hatch); SCOPE-7 optional work-tracker projection adapter (provider-neutral, `specs/**` stays authoritative, idempotent, dry-run, secrets via approved tools); SCOPE-8 isolated design-experiment contract (disposable worktree, cannot satisfy DoD/test/integration/certification, deleted after capture).
**IMP-004 scopes:** SCOPE-1 tighten agent Non-goals (audit/security/harden/gaps/regression/test — doc-only, mutually consistent); SCOPE-2 parallel-scope shared-state isolation contract (documented in `scope-workflow.md` / `workflow-execution-loops.md`); SCOPE-3 named owners for a11y/i18n + migration/backward-compat + longitudinal perf (advisory-until-configured).
**Work-boundary (R6):** immutable `workBoundary{ repositoryRoots, specTargets, allowedPaths, crossRepoPolicy }` in the resolution envelope, propagated to every specialist dispatch; `repo-binding-preflight` invoked at initial mutable start, not only on resume. Unrelated same-repo findings are filed/routed; different-repo findings are route-only unless the user authorized a cross-repo scenario.
**IMP-003 SCOPE-3:** dry-run / propose-only + whole-run rollback.
**Files:** `bubbles/scripts/vertical-delivery-plan-guard.sh` (+selftest, budget + fixtures), `bubbles/registry/gates.yaml`, `agents/bubbles.plan.agent.md` + `agents/bubbles_shared/{scope-workflow,workflow-orchestration-core,workflow-execution-loops,project-config-contract}.md`, the six diagnostic agents' Non-goals, `agents/bubbles.ux.agent.md`, `agents/bubbles.super.agent.md` (workBoundary), `repo-binding-preflight.sh` wiring.
**Acceptance:** the Feature-010-shaped 14-scope horizontal plan FAILS the guard with a remediation pointer while the vertical twin passes; a low-risk plan over ≤3/≤5 without rationale warns/blocks; scenario-ID + DoD parity verified across a restructure; a QF-scoped session cannot mutate the Bubbles source; parallel-scope isolation documented.
**Risks:** false-positive foundation-first plan → high-risk rationale escape valve + advisory-until-configured; enforcement becoming coverage-reduction → SCOPE-5 conservation gated; over-gating coverage owners → advisory-until-configured.

---

## 8. Phase 5 — Proportional validation (dogfood the thesis) · R7/R8/R9 + IMP-002 + IMP-026 review + R11

**Pre-push cost (R7/R8/R9):** parallelize the ~120 hermetic `framework-validate` selftests with a bounded pool (they are `mktemp`-isolated); share ONE install fixture across `install-provenance`/`trust-doctor`/`v5.3` instead of 13+ `install.sh` runs; wire `--tier=core` (the built-but-unused ~16-check tier) as the blocking pre-push gate with the full tier on release/CI; drop `release-check`'s duplicate `generate-release-manifest --check`; point fixture `mktemp` at a Spotlight-excluded dir.
**IMP-002 scopes:** SCOPE-1 `readiness-review` mode (`select, spec-review, code-review, system-review, security, regression, redteam, validate, finalize`, read-only, ceiling `validated`); SCOPE-2 persisted validate-owned `certification.readinessVerdict` (respects G056; advisory-to-release, NOT a `done` transition); SCOPE-3 give `system-review` a first-class home; SCOPE-4 intent routes. This consolidates the read-only diagnostic lenses (addresses the R10 13-agent overlap).
**IMP-026 scopes (this phase):** SCOPE-4 two mandatory orthogonal top-level review verdicts (Contract/Spec Fidelity vs Engineering Standards; a failure on either stays independently visible, no aggregate score hides it); SCOPE-5 skill invocation-cost + one-trigger-per-branch authoring, recorded in `skills/INVENTORY.md` + the instruction-budget report (report-only first).
**Gate consolidation (R11):** continue the "Consolidates former GNNN" practice on the evidence cluster (G021/G025/G072/G083) and the reality cluster (G028/G029/G035/G093).
**Files:** `bubbles/scripts/framework-validate.sh` (parallel pool + shared fixture + tier wiring), `release-check.sh`, `bubbles/workflows/modes.yaml` (`readiness-review`), `agents/bubbles.validate.agent.md` + `agents/bubbles.system-review.agent.md`, `bubbles/code-review.yaml` + `agents/bubbles.code-review.agent.md`, `bubbles/intent-routes.yaml`, `skills/bubbles-skill-authoring/SKILL.md`, `bubbles/registry/gates.yaml`.
**Acceptance:** routine framework pre-push runs seconds-to-minutes at `--tier=core`, full assurance on release/CI; `readiness-review` resolves and persists a validate-owned verdict; the review surface reports two independent verdicts; consolidated gates keep identical coverage.
**Risks:** overlap readiness-review vs audit → cross-system synthesis vs per-spec final gate (documented); parallelism nondeterminism → hermetic isolation + stable ordering for checksummed output.

---

## 9. Phase 6 — Complete the trust/evidence long tail · absorbs IMP-020 (S4–S7) + IMP-001 + IMP-005 (S2–S5)

**IMP-020 remaining (S1–S3 ✅ delivered incl. 53085ce untrusted-content/tool-trust/fail-closed-event AF-005):** S4 held-out executable outcome/cost/provenance benchmark (AF-004); S5 measure the effective loaded prompt/tool bundle (AF-006); S6 product-agnostic forecast-eval profile (FIN-001, generic temporal/scoring/leakage only); S7 reconcile/release all public + generated surfaces. Risk controls R1–R9 apply (executable oracles primary over semantic judges; schema-validated argv; host-native approval callback; ordered source provenance with `complete:false` on gaps; held-out isolation; compatible-strata cost comparison; stratified tasks; generic forecast core; measured effective-bundle).
**IMP-001 scopes:** SCOPE-1 `bubbles.journey.agent.md` + `prompts/bubbles.journey.prompt.md`; SCOPE-2 `journey` phase + `journey-refinement` mode; SCOPE-3 `experientialFriction` priorityScoring dimension (keep total 100, userImpact dominant); SCOPE-4 `uservalidation.md` activation (G057 boundary preserved — journey records observations, human accepts, never toggles acceptance); SCOPE-5 intent routing. Additive, default-off (`guidedJourney`).
**IMP-005 remaining (SCOPE-1 INVENTORY ✅ via `inventory-parity-check.sh`):** SCOPE-2 Skills-First-Pointers standard (backfill the 29 agent files, template-driven); SCOPE-3 learning-loop seed (`.specify/memory/lessons.md` at install) + user-signal input (with IMP-001); SCOPE-4 `train`/`upkeep`/`propagate` prompt-shim parity; SCOPE-5 `improvements/` surface hygiene.
**Files:** IMP-020 eval harness + trust registry + prompt-compiler + forecast profile scripts (+selftests); `agents/bubbles.journey.agent.md` (new) + prompt (new) + `bubbles/workflows.yaml` + `modes.yaml` + `intent-routes.yaml` + `feature-templates.md`; `skills/INVENTORY.md` + 29 agent files + `install.sh` (lessons seed) + three prompt shims.
**Acceptance:** eval fails closed on held-out tasks with per-stratum results; the journey surface routes hidden UI-passed/backend-failed defects; the learning loop ingests real user signal; INVENTORY parity holds; Skills-First-Pointers applied or formally optional.
**Risks:** journey overlaps chaos/ux → crisp Non-goals; journey needs a live stack → degrade to API-only; scoring rebalance → additive/modest; INVENTORY conflict with in-flight branch → sequence after it lands.

---

## 10. Coherence guardrails (how this stays systematic)

Every change in every phase MUST satisfy all five or it is rejected:
1. **Reuse-first** — extend an existing primitive (8 gate consolidations already prove the practice); never fork.
2. **Additive + default-preserving** — `full-delivery` and `done` semantics never change for existing specs.
3. **Gate-backed** — each new rule ships with a mechanical guard + hermetic selftest wired into `framework-validate`.
4. **Evidence-tested** — green + red fixtures; no capability marked done on a shipped primitive alone (the anti-pattern that left IMP-021/022/024 half-done).
5. **Boundary-respecting** — authored upstream in bubbles, propagated by `install.sh`; never hand-edited downstream.

---

## 11. Program definition of done

Low-risk work reaches a validated increment via `rapid-tool-delivery` with materially fewer phases; a scope shows honest `implemented` progress before certification; `delivered_prototype` is mechanically undeployable and `delivered_fast` deploys only within risk policy; every feature carries a `workBoundary` and cannot wander cross-repo; `framework-validate` runs in minutes at `--tier=core`; and the evidence/trust surface is benchmarked on held-out tasks — **with zero reduction in anti-fabrication, ownership, or integrity gates.**

## 12. Recommended execution order

Phase 0 (✅ complete) → **Phase 1 (highest-leverage, lowest-risk: register `rapid-tool-delivery`)** → 2 → 3 → 4 → 5 → 6. Deliver each phase as a real vertical increment (a registered mode, a wired guard, a passing selftest), never as another parked primitive.
