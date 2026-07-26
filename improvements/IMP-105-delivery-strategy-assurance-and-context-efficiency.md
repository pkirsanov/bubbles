# IMP-105 — Delivery-Strategy Exposure, Assurance-Terminal Completion, and Context/Churn Efficiency

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*`, `agents/*`, or `bubbles/workflows.yaml` until approved
**Author:** analyst review pass (bubbles.analyst → framework-health proposal), driven from a live line-by-line source audit
**Motivation:** A four-lens review request — (1) preserve delivery quality (anti-fabrication / gates / workflows / validation / certification), (2) reduce spec-doc churn, (3) reduce bureaucracy / non-delivery time, (4) reduce token/credit cost — all at *same-or-better* quality; plus an operator request to lean harder on the existing full/fast/POC delivery model; plus an external conference talk on agents + ontologies + neuro-symbolic AI (Frank Coyle, Berkeley) whose thesis — *wrap the probabilistic model in a symbolic guardrail; "typed contract at the door, constraint model at the ledger"; derive relationships from one shared conceptualization; bound the loop* — was checked against Bubbles rather than adopted as a slogan.

**Verified gaps addressed:** `ASSUR-TERM`, `STRAT-EXPOSE`, `SPEC-DERIVE`, `EVID-DUP`, `CTX-BUNDLE`, `SWEEP-PROP`, `ONT-UNIFY`, `META-CHURN` (legend at the end of this file).

---

## Executive summary

Bubbles is already a strong neuro-symbolic system: 110 deterministic gates (`bubbles/registry/gates.yaml`) wrapping probabilistic agents, a canonical→generated pattern (`generate-gates-block.sh`, `generate-modes-block.sh`), cross-registry linters (`workflow-registry-consistency.sh`, `agent-ownership-lint.sh`, `intent-routes-lint.sh`), and a fully-wired three-level **assurance derivation** (`full` / `fast` / `prototype`). The conference talk validates this architecture rather than proposing anything foreign to it.

The four review goals are therefore **not** in tension with quality. The cost centres are *not* the gates (cheap, high-value, must stay). They are:

- an **unfinished** assurance-to-terminal-status vertical that makes the shipped three-level model invisible to users;
- **hand-maintained registry relationships** (one of which is a latent correctness hole, not just duplication);
- **evidence and policy prose loaded and duplicated** far beyond where they are needed.

Every proposed change **extends a lever Bubbles already ships** (assurance scripts, `record_evidence`, `effective-bundle-budget.sh`, `risk-tier-resolve.sh`, the generate-from-canonical pattern) and is additive + default-preserving, so the universal quality floor in `agents/bubbles_shared/critical-requirements.md` and `modeTemplates.delivery-quality-constraints` never drops.

### Corrected mental model (two axes, not one slider)

The intuitive "full / fast / POC quality slider" is **not** how the shipped mechanics work, and conflating them would be dishonest. There are **two orthogonal axes**:

1. **Delivery strategy** = how much scope-appropriate process runs. Real lanes today: `full-delivery` (default; every phase incl. `audit`) and `rapid-tool-delivery` (short phase list, no `audit`, **low-risk-only**, drops regression/security/harden/gaps/stabilize/chaos/redteam). There is **no** medium lane that runs the full chain but stops at `fast`.
2. **Achieved assurance** = the DERIVED, evidence-based result: `full` (implementation + full coverage + all tests pass + independent audit), `fast` (same minus the independent audit), `prototype` (verification incomplete/failing — **never deployable**). This is derived by `bubbles/scripts/assurance-derive.sh`, is fail-closed (derives *down*), and is user-**requestable but never user-declarable**.

`risk-tier-resolve.sh` is the safety hinge: any auth/payment/secret/PII/DB-migration/deploy/prod/host-singleton/cross-product trigger fail-closed-escalates the fast lane to `full-delivery`. That single resolver is what makes "go faster" safe; it must be protected above all else.

**POC / prototype is an INTENT, not the bottom of a quality slider.** The `.design-experiment` throwaway worktree (`agents/bubbles_shared/scope-workflow.md`, `bubbles/scripts/design-experiment-guard.sh`) produces learning that can *never* satisfy DoD/tests/certification. It must stay a separate intent, not a selectable "low quality" tier.

---

## Problem (verified against source)

Each bullet was re-checked against a real file; byte counts and enumerations come from commands executed during the audit (`effective-bundle-budget.sh`, `skill-description-load.sh`, `yq '.modes | length'`, `yq '.gates | length'`, `grep -l`).

- **`ASSUR-TERM` — assurance-to-terminal-status vertical is unfinished.** `agents/bubbles.validate.agent.md` (Step "Record the achieved assurance assessment") already runs `assurance-derive.sh` and records `certification.assurance = { level, missingForFull }`, verified by `assurance-certification-check.sh`, and it is **binding at deploy** (`release-assurance-gate.sh` refuses an under-assured spec on its train). BUT the same section states verbatim that this is *"ADDITIVE and INFORMATIONAL — it never alters the terminal status,"* that a spec with no assurance block *"remains valid (backward-compatible),"* and that *"driving a DISTINCT terminal status (`delivered_fast` / `delivered_prototype`) from the level, and the guard-side consistency enforcement, are the remaining Phase-3 steps."* The distinct terminal statuses are declared as `terminalAliases` for `rapid-tool-delivery` (`bubbles/workflows/modes.yaml`) and recognized by `is-terminal-for-mode.sh`, but validate does not yet DRIVE them. Net: the three-level model is real at derivation + deploy-gating but **collapses to `done` at the terminal-status layer users see**.
- **`STRAT-EXPOSE` — the shipped fast lane and assurance model are effectively undocumented, and no strategy selector exists.** `rapid-tool-delivery` is registered (`bubbles/workflows/modes.yaml`, `bubbles/workflows/aliases.yaml`, `bubbles/intent-routes.yaml`) and passes its hermetic selftest, but a repo-wide search finds it in `docs/**` only inside the AUTO-GENERATED `docs/generated/gate-coverage-map.md` (as a selftest filename) — it is absent from `README.md`, `docs/guides/WORKFLOW_MODES.md`, `docs/recipes/**`, and the generated cheat sheet. There is **no** user-facing `highest` / `fast` strategy verb (a search for `deliveryStrategy|highest|balanced` finds only incidental "highest-value work" / "Balanced review" prose). Adoption profiles (`foundation` / `delivery` / `production` / `assured` in `bubbles/adoption-profiles.yaml`) are onboarding posture, **not** quality tiers — every one carries `governanceInvariant: full-certification` and `certificationRequired: true`.
- **`SPEC-DERIVE` — the specialist-completion requirement is hand-maintained AND has a fail-open default.** `bubbles/scripts/state-transition-guard.sh` (Check 6) builds `required_specialists` from a ~30-arm `case "$state_workflow_mode"` initialized to an empty array and guarded by `if [[ ${#required_specialists[@]} -gt 0 ]]`. **A mode absent from that `case` receives ZERO specialist-completion enforcement.** The inline comment on the `rapid-tool-delivery)` arm documents that this was a real bug: the mode "was absent from the table, so Check 6 imposed no specialist-completion requirement on it." Each mode's required specialists are *already* derivable from its `phaseOrder` in `bubbles/workflows/modes.yaml` (minus the `select`/`finalize` bookends), so the hardcoded table is duplicated registry knowledge that is also a latent correctness hole.
- **`EVID-DUP` — raw evidence is inlined and duplicated.** `agents/bubbles_shared/critical-requirements.md` + `bubbles/registry/gates.yaml` (G025) require ≥10 lines of raw terminal output pasted INLINE beneath every `[x]` DoD item in `scopes.md`, while `report.md` is a separate append-only evidence log — the same output is carried on two growing surfaces. The ≥10-line rule text itself appears in 17 agent files; `anti-fabrication` in 42; `critical-requirements` is referenced by 29 agent files.
- **`CTX-BUNDLE` — orchestrators load authoring reference they do not route on.** Measured with the framework's own `bubbles/scripts/effective-bundle-budget.sh`: the `bubbles.workflow` effective bundle is **483,894 bytes across 42 files / 6,879 lines**; `bubbles.security` 363,965; `bubbles.setup` 352,550; `bubbles.simplify` 348,441; `bubbles.validate` 213,566. The router's single largest dependency after its own file is `agents/bubbles_shared/project-config-contract.md` at **54,949 bytes / 926 lines** — whose headings are downstream project-onboarding reference (SST pipeline, `agents.md` command registry, `bubbles-project.yaml` sections, portability checklist). `scope-workflow.md` (47,621) and `feature-templates.md` (19,811 — pure template text) are likewise authoring reference. Always-loaded skill descriptions are NOT the problem (`skill-description-load.sh` = 8,714 bytes).
- **`SWEEP-PROP` — mandatory scope sweeps apply uniformly regardless of risk.** `agents/bubbles_shared/feature-templates.md` mandates, per scope, a Shared-Infra Impact Sweep + Change Boundary + Consumer Impact Sweep + Canary rows + adversarial regression rows. Many are unconditional even when the scope surface cannot trigger them.
- **`ONT-UNIFY` — the ontology exists but is fragmented, and some relationships are hand-maintained instead of derived.** Modes, gates, ownership, risk, tool trust, capability, intent routing, and assurance live across `bubbles/workflows/modes.yaml`, `registry/gates.yaml`, `agent-capabilities.yaml`, `agent-ownership.yaml`, `action-risk-registry.yaml`, `tool-trust-registry.yaml`, `capability-ledger.yaml`, `intent-routes.yaml` + 9 JSON schemas, tied together by several consistency linters. `SPEC-DERIVE` is the concrete symptom: a relationship (mode → required specialists) that *is* derivable is instead re-encoded imperatively.
- **`META-CHURN` — framework self-improvement forces steady downstream re-sync.** The pre-commit hook auto-bumps PATCH every commit (CHANGELOG "Versioning Scheme"), and the `IMP-001…IMP-104` cadence means many small policy/prose deltas each become a downstream upgrade event.

---

## Proposal

Every scope below is **additive** and **default-preserving** unless explicitly noted; none removes a gate or lowers the universal quality floor. Scopes are ordered by leverage and are independently landable.

### SCOPE-2 — Expose delivery strategy + assurance in the user surface (`STRAT-EXPOSE`)

- Add a front-door strategy verb over the EXISTING modes: `fast` → `rapid-tool-delivery` (always through `risk-tier-resolve.sh`, so it self-escalates on any high-risk trigger) and `highest` → `full-delivery` with optional phases forced on and the adversarial `samples` dial raised. **Do NOT add a `balanced` mode** — `full-delivery` already IS the balanced default (phase-relevance auto-skips irrelevant phases with recorded reasons); a third synonym would add bureaucracy (goal #3) for no behavior change. Optionally brand the existing default `standard` for symmetry.
- Document the assurance model (`full`/`fast`/`prototype`, "requestable not declarable", `prototype` never ships) and the fast lane in `README.md`, `docs/guides/WORKFLOW_MODES.md`, a new `docs/recipes/rapid-tool-delivery.md`, and the generated cheat sheet (via `bubbles/cheatsheet/modes.json` + `generate-cheatsheet.sh`).
- **Why:** the operator asked to lean on the model; today it is unreachable because it is undocumented. **Quality:** unchanged — `fast` remains risk-gated and inherits the full integrity contract (proven by `rapid-tool-delivery-mode-selftest.sh`).

### SCOPE-3 — Derive `required_specialists` from `phaseOrder` (`SPEC-DERIVE`, `ONT-UNIFY`)

- Replace the hardcoded `case` in `state-transition-guard.sh` Check 6 with a derivation: read the resolved mode's `phaseOrder` (via `mode-resolver.sh`) and require every phase except the `select`/`finalize` bookends and declared read-only phases. Add a hermetic selftest asserting an unlisted-but-valid mode now gets a non-empty requirement (closing the fail-open default).
- **Why:** removes duplicated registry knowledge AND closes the latent hole where a new mode silently escapes specialist enforcement. **Quality:** strictly improves it — the check now fires for every delivery mode, not only the ~30 someone remembered to list.

### SCOPE-4 — Evidence by reference, not by paste (`EVID-DUP`)

- Extend the EXISTING evidence infrastructure (`bubbles/mcp/tools/record_evidence.json` → `.specify/runtime/tool-calls.jsonl`, the `rawPointer` convention in `context-compactor.sh`, and the `evidence://` URI already used in adversarial samples) so a DoD item may cite an evidence ID/pointer instead of inlining ≥10 raw lines twice. `agents/bubbles_shared/evidence-rules.md` and the G025 checks in `state-transition-guard.sh` accept a resolvable evidence reference as equivalent to inline output, preserving the `**Claim Source:**` provenance tag.
- **Default-preserving:** inline ≥10-line evidence remains fully valid; reference is an OPT-IN that reduces duplication. **Why:** cuts the double-carry of evidence across `scopes.md` + `report.md`. **Quality:** provenance strengthens (one content-addressed source of truth), anti-fabrication is unchanged — the referenced record must still be real executed output.

### SCOPE-5 — Phase-local lazy context loading + measured budgets (`CTX-BUNDLE`)

- Give the orchestrator a compact policy kernel plus registry-read access, and LAZY-LOAD the heavy authoring reference (`project-config-contract.md`, `feature-templates.md`, `scope-workflow.md`) only when the active phase is planning/authoring. The bootstrap-profile tiering in `agents/bubbles_shared/operating-baseline.md` ("Context Loading Profiles") is the existing seam.
- Gate the result with the ALREADY-SHIPPED `bubbles/scripts/effective-bundle-budget.sh` (`effectiveBundleMaxBytes` in `.github/bubbles-project.yaml`), set only AFTER a held-out task evaluation confirms no quality regression. Target a measured 40–60% reduction in the orchestrator effective bundle.
- **Why:** the router loads ~55 KB of downstream-onboarding reference (plus template text) it does not need to route a phase. **Quality:** identical rules, loaded on demand; the budget is evidence-gated so it can never silently drop a required contract.

### SCOPE-6 — Risk-proportional mandatory sweeps (`SWEEP-PROP`)

- Apply the Shared-Infra / Change-Boundary / Consumer-Impact / Canary sweep requirements CONDITIONALLY, keyed to `risk-tier-resolve.sh` and the scope's declared changed surface, instead of unconditionally on every scope.
- **Why:** cuts non-delivery ceremony on trivial surfaces (goal #3). **Quality:** unchanged — the sweeps still fire on exactly the high-fan-out / consumer-facing / shared-infra surfaces that need them; a low-risk build-free scope simply stops carrying inapplicable subsections.

### SCOPE-7 — Unify the registry ontology + generate derived tables (`ONT-UNIFY`)

- Introduce (or grow an existing registry into) one typed `delivery-policy` model whose primitives are `Intent`, `DeliveryStrategy`, `WorkflowMode`, `RiskClass`, `Phase`, `Gate`, `Artifact`, `AgentOwner`, `EvidenceClaim`, `AchievedAssurance`, `ReleaseAssuranceFloor`, `TerminalState`, with machine-checkable invariants expressed declaratively (the OWL-style constraints the talk highlights, WITHOUT RDF or a graph DB): `prototype` disjoint from `deployable`; exactly one owner per artifact section; only `bubbles.validate` writes certification; `fast` may be missing only `independent-audit`; high/unknown risk requires `full`; required specialists = `phaseOrder` minus control phases; a mode has exactly one transition profile. GENERATE the currently-hand-maintained tables (the gates block already is; extend to mode→specialist and docs/cheatsheet) and shadow-compare generated output against current source before any cutover.
- **Why:** the talk's real lesson — derive relationships from one shared conceptualization. **Quality:** fewer hand-rolled encodings = fewer latent guard bugs (see the `env-pollution-scan` self-match class in repo history); every generated artifact is `--check`-verified as today.

### SCOPE-8 — Batch framework meta-churn (`META-CHURN`)

- Group compatible policy/prose/doc improvements into periodic framework release trains rather than PATCH-per-commit deltas that each become a downstream upgrade event. Keep the auto-bump for correctness-critical single-gate fixes.
- **Why:** reduces downstream re-sync overhead. **Quality:** unchanged — the same improvements land, batched.

---

## Migration / rollout

- **Order:** SCOPE-3 (self-contained, high value) → SCOPE-2 → SCOPE-4 → SCOPE-5 → SCOPE-6 → SCOPE-7 → SCOPE-8. Each is independently landable; SCOPE-2's only dependency (SCOPE-1) has landed, so it now has no unmet dependency.
- **Posture:** SCOPE-1/3 are behavior-completing (additive, backward-compatible). SCOPE-2 is docs + one intent-route/alias addition. SCOPE-4/5/6 are opt-in / advisory-until-configured (they ship inert and are activated per repo). SCOPE-7 is a canonical-source refactor validated by shadow-compare + existing `--check` generators. SCOPE-8 is a process change.
- All framework edits are authored HERE (upstream-first per `operating-baseline.md` → Framework File Immutability) and reach downstream repos only via `install.sh` / upgrade.

## Risks & mitigations

- **R1** Driving distinct terminal statuses (SCOPE-1) could surprise downstream tooling that only expects `done`. → `is-terminal-for-mode.sh` already treats `delivered_fast`/`delivered_prototype` as terminal-for-mode; keep the no-block-status behavior backward-compatible (a missing assurance block still yields `done`), and land guard consistency (`assurance-certification-check.sh`) in the same change.
- **R2** Deriving `required_specialists` (SCOPE-3) could change enforcement for a mode that currently relies on the empty default. → That "reliance" is the bug; add a hermetic selftest + persistent regression so the derived set is proven for every registered delivery mode before cutover.
- **R3** Lazy context loading (SCOPE-5) could drop a contract an orchestrator silently depended on. → Evidence-gate with a held-out eval and the existing `effective-bundle-budget.sh`; never set a blocking budget until the eval shows zero gate-detection regression.
- **R4** Evidence-by-reference (SCOPE-4) could weaken anti-fabrication if a reference is unresolvable. → Fail-closed: an unresolvable or empty reference is treated as `not-run` (DoD stays `[ ]`); the referenced record must be real executed output with a `**Claim Source:**` tag.
- **R5** Conditional sweeps (SCOPE-6) could skip a sweep that was actually needed. → Key the condition to `risk-tier-resolve.sh` (fail-closed to full on unknown), so ambiguity keeps the sweep.

## Acceptance criteria (when implemented)

- SCOPE-2: `rapid-tool-delivery` and the assurance model appear in `README.md`, `WORKFLOW_MODES.md`, a recipe, and the generated cheat sheet; a `fast` request on a high-risk surface demonstrably routes to `full-delivery`.
- SCOPE-3: `state-transition-guard.sh` imposes a non-empty specialist requirement for EVERY registered delivery mode, proven by a selftest that adds a synthetic mode and asserts it is covered.
- SCOPE-4: a DoD item closed by evidence reference passes G025 with no inline paste, and an unresolvable reference fails closed.
- SCOPE-5: measured orchestrator effective bundle drops materially (target 40–60%) with the held-out eval showing no gate-detection regression.
- SCOPE-6: a low-risk build-free scope carries no inapplicable sweep subsections while a shared-infra scope still requires them.
- SCOPE-7: mode→specialist and the gates/cheatsheet tables are generated from one canonical model and pass `--check`; shadow-compare shows byte-identical or reviewed diffs.
- SCOPE-8: a documented framework release-train cadence exists.

## Files to touch (on approval)

- **SCOPE-2:** `README.md`, `docs/guides/WORKFLOW_MODES.md`, `docs/recipes/rapid-tool-delivery.md` (new), `bubbles/cheatsheet/modes.json` + `bubbles/scripts/generate-cheatsheet.sh`, `bubbles/intent-routes.yaml`, `bubbles/workflows/aliases.yaml` — owners: `bubbles.docs` + `bubbles.commands`.
- **SCOPE-3:** `bubbles/scripts/state-transition-guard.sh` + new `state-transition-required-specialists-selftest.sh` + `tests/regression/` entry — owner: framework guard.
- **SCOPE-4:** `agents/bubbles_shared/evidence-rules.md`, `bubbles/scripts/state-transition-guard.sh` (G025 evidence checks), `agents/bubbles_shared/feature-templates.md`, `bubbles/mcp/tools/record_evidence.json` (already exists) — owner: `bubbles.validate` + evidence-rules.
- **SCOPE-5:** `agents/bubbles.workflow.agent.md`, `agents/bubbles_shared/operating-baseline.md` (Context Loading Profiles), the phase `*-bootstrap.md` modules, `bubbles/scripts/effective-bundle-budget.sh` (already measures) — owner: framework.
- **SCOPE-6:** `agents/bubbles_shared/feature-templates.md`, `agents/bubbles_shared/scope-workflow.md`, `bubbles/scripts/risk-tier-resolve.sh` — owners: `bubbles.plan` + framework.
- **SCOPE-7:** new `bubbles/registry/delivery-policy.yaml` (or an extension of an existing registry), `bubbles/scripts/generate-*.sh`, `bubbles/scripts/workflow-registry-consistency.sh` — owner: framework.
- **SCOPE-8:** `CHANGELOG.md` (Versioning Scheme), a maintainer release-cadence note — owner: maintainer.

---

## Data sources analyzed (G125)

- Registries: `bubbles/workflows.yaml`, `bubbles/workflows/modes.yaml`, `bubbles/workflows/aliases.yaml`, `bubbles/registry/gates.yaml`, `bubbles/agent-capabilities.yaml`, `bubbles/agent-ownership.yaml`, `bubbles/action-risk-registry.yaml`, `bubbles/tool-trust-registry.yaml`, `bubbles/adoption-profiles.yaml`, `bubbles/intent-routes.yaml`, `bubbles/schemas/workflows.schema.json`.
- Scripts (read + several EXECUTED): `assurance-derive.sh`, `assurance-resolve.sh`, `assurance-certification-check.sh`, `release-assurance-gate.sh`, `risk-tier-resolve.sh`, `rapid-tool-delivery-mode-selftest.sh`, `transition-contract-resolver.sh` (+ selftest), `state-transition-guard.sh`, `is-terminal-for-mode.sh`, `effective-bundle-budget.sh`, `effective-bundle-measure.sh`, `skill-description-load.sh`.
- Agents / shared: `agents/bubbles.validate.agent.md`, `agents/bubbles_shared/{critical-requirements,analytical-rigor,operating-baseline,validation-core,validation-profiles,artifact-ownership,feature-templates,project-config-contract}.md`.
- Measurements executed: `effective-bundle-budget.sh` (41 agent bundles), `skill-description-load.sh --summary`, `yq '.modes | length'` = 62, `yq '.gates | length'` = 110, `grep -l` duplication counts.

## Verification posture / honesty disclosure

Findings are grounded in files actually opened and commands actually run in-session; five selftests were executed and passed (`rapid-tool-delivery`, `assurance-derive`, `assurance-resolve`, `transition-contract-resolver`, `effective-bundle-budget`). This proposal did NOT read every line of all 41 agents, 49 shared modules, 110 gate descriptions, and ~200 scripts — it read the load-bearing mechanisms end-to-end. No `bubbles/*`, `agents/*`, or `bubbles/workflows.yaml` file is mutated by this proposal (G125 proposal-first). Confidence: `ASSUR-TERM`, `STRAT-EXPOSE`, `SPEC-DERIVE`, `CTX-BUNDLE`, `EVID-DUP` are HIGH (direct source + measurement); `SWEEP-PROP`, `ONT-UNIFY`, `META-CHURN` are MEDIUM (design-level, effort-dependent).

## Non-goals (explicit — do NOT do these)

- Do NOT reduce gate COUNT or weaken anti-fabrication (G020/G021), per-DoD raw evidence (G025), or provenance tags (G072) — these are the quality floor; reduce duplication/imperativeness, never coverage.
- Do NOT add a `balanced` mode equal to the `full-delivery` default.
- Do NOT let a user DECLARE an assurance level; keep it validate-derived from evidence.
- Do NOT collapse the 6-artifact model globally; only route genuinely small, risk-gated work to the lean lane.

## Legend (gap codes)

| Code | Name |
|------|------|
| `STRAT-EXPOSE` | Fast lane + assurance model undocumented; no `highest`/`fast` strategy verb |
| `SPEC-DERIVE` | `required_specialists` hardcoded; unlisted modes get zero specialist enforcement |
| `EVID-DUP` | ≥10-line raw evidence inlined and duplicated across `scopes.md` + `report.md` |
| `CTX-BUNDLE` | Orchestrator bundle loads planning/authoring reference it does not route on |
| `SWEEP-PROP` | Mandatory scope sweeps applied uniformly regardless of risk surface |
| `ONT-UNIFY` | Registry relationships fragmented; some hand-maintained rather than derived |
| `META-CHURN` | PATCH-per-commit + steady IMP cadence forces downstream re-sync churn |
