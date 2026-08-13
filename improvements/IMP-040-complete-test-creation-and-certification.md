# IMP-040 — Complete Test Creation And Certification

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed. NO auto-mutation of bubbles/* until approved
**Motivation:** A certified downstream feature had a green browser suite while three scenario-linked tests did not exist, visible behavior differed from hidden legacy DOM, one integration test bypassed the production renderer, and one data-path test bypassed its declared stale-cache delta.
**Verified gaps addressed:** COV-8 exact test-reference integrity, COV-9 complete scenario obligations, COV-10 production-path fidelity, COV-11 non-vacuous tests, REG-8 source-impact revalidation, EV-8 human acceptance enforcement, and COV-12 downstream enforcement

## Problem (verified against source)

- **COV-8 — Test references are not targets:** G057 counts `linkedTests` fields. It does not resolve each file and exact test title. BUG-030 records the false pass.
- **COV-9 — Scenario coverage is row-based, not behavior-complete:** A scenario can have a unit row while its user-visible path has no live-system test. Three downstream scenarios had this shape.
- **COV-10 — Test category does not prove path fidelity:** An E2E test can inspect hidden legacy DOM or invoke a renderer manually. Both shapes bypass the current user path while retaining an `e2e-ui` label.
- **COV-10 — Synthetic input can overclaim dependency coverage:** Seeded cache data is valid for deterministic model behavior. It cannot prove provider, stale-cache, delta-fetch, persistence, or transport behavior by itself.
- **COV-11 — Green does not prove sensitivity:** Current policy asks whether a test can fail, but plans do not require a machine-readable negative control. A pass-through or inert assertion can survive.
- **REG-8 — Later source changes do not reopen owning scenarios:** G088 tracks planning-file edits. It does not connect a changed shared consumer surface to the certified scenarios that surface implements.
- **EV-8 — Human acceptance is prose-enforced only:** G010 is required, but terminal guards do not reject unchecked human acceptance. BUG-029 records the gap.
- **COV-12 — Downstream guards lack an execution path:** Installed guards are not invoked by a supported downstream hook or reusable CI workflow. BUG-031 records the gap.

## Provenance

- Framework source revision audited: `099bd5784b55eb6cd1e1bfcf790eb2f0e1aebb15`.
- Downstream consumer revision audited before repair: `87b02e5b153af3a9aa1323d0ec17984af03e3996`.
- `BUGS.md` BUG-028 records the receipt-clone reproduction and source predicate.
- `BUGS.md` BUG-029 records the unchecked human-validation false pass.
- `BUGS.md` BUG-030 records three unresolved scenario test titles that passed G057.
- `BUGS.md` BUG-031 records the missing downstream changed-spec enforcement path.
- The repair run added three missing live-system tests and strengthened current-surface, stale-delta, renderer, and disclosure assertions before this proposal was authored.

## Design principles

1. Keep Bubbles language-agnostic.
2. Let projects own test commands and runner discovery.
3. Treat declared metadata as a claim that guards must corroborate.
4. Separate model determinism from dependency-path coverage.
5. Require current externally observable behavior for live categories.
6. Scale negative controls and mutation checks by risk.
7. Preserve stable scenario IDs across refactors.
8. Fail closed when terminal certification cannot resolve a required test.

## Proposal

### SCOPE-13 — Evaluation and rollout (all gaps)

Build a held-out corpus across repository shapes:

- static browser tools.
- service API projects.
- command-line tools.
- strongly typed compiled projects.
- Python data projects.
- projects with custom runners.
- projects with no UI.
- projects with no test-title inventory.

Measure false acceptance, false rejection, planning expansion, and runtime cost.

## Migration / rollout

1. Land the inventory schema and adapter validator as additive surfaces.
2. Run exact target resolution in advisory mode on downstream fixtures.
3. Fix existing stale links before enabling blocking mode.
4. Enable G057 exact resolution for newly changed scenario manifests.
5. Add mechanism declarations to newly changed Test Plan rows.
6. Enable fidelity and negative-control blocking per project after shadow results are clean.
7. Ship the downstream CI command before documentation claims automatic enforcement.
8. Apply source-impact revalidation only when `implementationRefs`, code-index facts, or project mappings exist.

Legacy untouched done specs remain grandfathered. A changed or recertified spec adopts the current contract.

## Risks & mitigations

- **R1 — Runner diversity:** A built-in parser cannot cover every ecosystem. Use a versioned project adapter and validate its JSON output.
- **R2 — Metadata theater:** Agents could declare strong mechanisms without real proof. Corroborate metadata against discovered tests, source patterns, and execution receipts.
- **R3 — False positives on mixed tests:** A valid test may inspect internal and external state. Reject only when internal state is the sole proof for an external scenario.
- **R4 — Mutation cost:** Full mutation testing can be expensive. Scale it by risk and retain adversarial input for lower tiers.
- **R5 — Source ownership drift:** Explicit `implementationRefs` can stale. Compare them with code-index facts when available and require review on shared-surface changes.
- **R6 — CI latency:** Run changed and impacted scenarios first. Keep whole-suite regression as the final completion gate.
- **R7 — External dependency instability:** Use ephemeral validate-plane dependencies and declared degradation contracts. Never point tests at production.

## Acceptance criteria (when implemented)

- A real test file with a missing linked title fails G057.
- An ambiguous duplicate title fails with both candidates named.
- A unit test cannot satisfy a scenario that requires `e2e-ui` or `e2e-api`.
- A hidden attached-node assertion alone cannot satisfy a visible UI scenario.
- A detached renderer call alone cannot satisfy a route-rendering scenario.
- A seeded cache test cannot satisfy a declared live acquisition or stale-delta scenario.
- A stale-cache test proves cached paint precedes delta completion and that completion changes the owning result.
- A formula test proves a transformed result and fails under an adversarial input.
- A shared adapter test proves owner parity and the current consumer surface.
- A mapped shared-source change marks affected certified scenarios for revalidation.
- An unchecked human-validation item blocks terminal completion without being modified.
- The downstream changed-spec command rejects a post-certification planning edit.
- A non-JavaScript fixture passes through a custom inventory adapter.
- Legacy untouched specs remain grandfathered.
- Framework selftests include red controls for every new acceptance path.

## Files to touch (on approval)

`bubbles/schemas/scenario-manifest.schema.json` (extend linked-test and implementation references), `agents/bubbles_shared/test-core.md` (obligation matrix), `agents/bubbles_shared/test-fidelity.md` (mechanism and path rules), `agents/bubbles_shared/scope-workflow.md` (planning and revalidation), `agents/bubbles_shared/project-config-contract.md` (test inventory adapter), `agents/bubbles.plan.agent.md` (complete plan generation), `agents/bubbles.test.agent.md` (target resolution and negative controls), `agents/bubbles.validate.agent.md` (current-surface replay and G010), `agents/bubbles.audit.agent.md` (sampled path proof), `bubbles/scripts/traceability-guard.sh` (G057 exact resolution), `bubbles/scripts/guards/control-plane-checks.sh` (G057 integration), `bubbles/scripts/regression-quality-guard.sh` (fidelity checks), `bubbles/scripts/test-impact-plan.sh` (source-to-scenario impact), and planned new scripts `bubbles/scripts/test-inventory-resolve.sh`, `bubbles/scripts/test-fidelity-guard.sh`, `bubbles/scripts/user-validation-guard.sh`, plus hermetic selftests and a reusable downstream CI entrypoint. Owners: `bubbles.plan`, `bubbles.test`, `bubbles.validate`, `bubbles.audit`, and framework implementation under G057, G010, G079, G095, and G125.
