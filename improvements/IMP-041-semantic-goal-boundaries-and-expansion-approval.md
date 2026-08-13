# IMP-041 — Semantic Goal Boundaries And Expansion Approval

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed. NO auto-mutation of bubbles/* until approved
**Motivation:** An audited autonomous model-evaluation run expanded a bounded existing-runtime test into a reusable virtualization, runner, cache, and certification program.
**Verified gaps addressed:** GF-7 runtime boundary enforcement, GF-8 semantic work boundaries, GF-9 scenario contribution traceability, GF-10 expansion approval, GF-11 proportionality direction, GF-12 finding admission, GF-13 convergence materiality, and COV-13 incident regression coverage

## Problem (verified against source)

- **GF-7 — Goal-fidelity capabilities are not load-bearing in the goal runner:** `bubbles/scripts/goal-fidelity-guard.sh` defines six selectable boundaries. Repository search finds the direct pre-certification invocation in `agents/bubbles.validate.agent.md`. It finds no direct invocation in `agents/bubbles.goal.agent.md` or `bubbles/scripts/scenario-compile-lint.sh`.
- **GF-7 — Registry membership does not prove execution:** `bubbles/workflows.yaml` lists G134 as a universal static gate. `bubbles/scripts/state-transition-guard.sh` does not invoke G134. A mutable goal can therefore reach planning and dispatch without a mechanical boundary receipt.
- **GF-8 — The frozen boundary is path-shaped only:** `bubbles/scripts/goal-contract.sh` permits four `workBoundary` keys: `repositoryRoots`, `specTargets`, `allowedPaths`, and `crossRepoPolicy`. It cannot declare whether the operator allowed a new virtual machine, runner, workflow, daemon, cache, approval authority, or network topology.
- **GF-8 — In-directory expansion remains in-boundary:** `goal-fidelity-guard.sh --boundary pre-dispatch` and `post-finding` resolve repository, spec, and path reach. They cannot distinguish a narrow test from a platform build when both use an allowed directory.
- **GF-9 — A compiled scenario proves shape, not contribution:** `bubbles/scripts/scenario-compile-lint.sh` checks the root outcome shape, node types, repositories, modes, action approval, and graph validity. It does not require a `goalRef`, a success-signal mapping, an ownership-fit record, or a planned change delta.
- **GF-10 — Action approval starts too late:** `agents/bubbles_shared/scenario-compile.md` requires approval for a host-mutating action node. It does not require approval when planning or delivery adds high-impact infrastructure before that action.
- **GF-11 — G094 enforces foundation presence but not foundation restraint:** `bubbles/scripts/capability-foundation-guard.sh` activates from trigger words or two concrete implementation entries. It accepts either a capability foundation or a justification. It does not reject a reusable foundation when the frozen goal describes one-off work.
- **GF-12 — Findings lack scenario-admission enforcement:** Goal-fidelity telemetry recognizes `required`, `blocking-external`, and `independent` impacts. The scenario schema and linter do not require that classification before a finding becomes a new current-goal node.
- **GF-13 — Persistence can amplify an expansion:** `autonomous-goal` enables solution search and `neverStopForFixableObstacles`. The mode does not state that undeclared scope expansion is a new goal rather than a fixable obstacle.
- **COV-13 — No incident-shaped regression protects the boundary:** Current goal-fidelity selftests cover path widening, stale references, and missing outcome evidence. They do not test a semantically unrelated infrastructure expansion that stays inside allowed paths.

## Provenance

- Framework source revision audited: `7ffe753bc8eb76e63879140bee20e9295502d184`.
- Source claims rechecked after integration onto `fd4f575814671d82bde55665935c7595d4932a5a`.
- Incident source audited: local Copilot session `20cc5db4-5487-4d33-a1b3-02d3526d4268`.
- The review re-read the Goal Contract, G134 guard, scenario compiler, capability-foundation guard, autonomous mode, and their current selftests.
- The incident review verified the first infrastructure-expansion dispatch and compared its requested work with the operator's original evaluation outcome.

## Design decisions

1. Extend G134 instead of registering another goal-fidelity gate.
2. Preserve the current path boundary as the first enforcement layer.
3. Add a closed semantic boundary as a second enforcement layer.
4. Require operator approval before high-impact planning or delivery expansion.
5. Treat a generic `continue` instruction as resume authority only.
6. Keep one-off work concrete unless the operator approves a reusable capability.
7. Require every scenario node to contribute to the frozen outcome.
8. Keep legacy frozen contracts readable until the owning goal is revised.

## Proposal

### SCOPE-8 — Incident corpus, shadow rollout, and downstream adoption (COV-13)

Add a held-out goal-fidelity corpus. Include repository-neutral incident shapes.

The minimum corpus contains:

1. Evaluate an already-installed model through existing settings and tests.
2. Expand the same evaluation into virtual machines, runners, caches, and certification authorities.
3. Repair one bug inside an existing adapter without creating another foundation.
4. Add a genuine second provider that requires a reusable foundation.
5. Route an independent infrastructure finding without expanding the current goal.
6. Resume a compacted goal without changing its approved delta.

Each case includes one accepted plan and at least one adversarial rejected plan. The overbuilt evaluation must fail before its first planning dispatch.

Roll out in stages:

1. Land version 2 parsing and receipts without changing version 1 behavior.
2. Emit shadow telemetry for semantic mismatches and planned-delta growth.
3. Measure false acceptance, false rejection, planning expansion, and boundary-check cost.
4. Enable blocking for new Goal Contracts after the held-out corpus is clean.
5. Require version 2 when a legacy goal is revised.
6. Refresh downstream installs only after source `framework-validate` and `release-check` pass.

#### SCOPE-8 tests

- Run every corpus case on macOS and Linux shell baselines.
- Prove each adversarial case fails for its intended reason.
- Prove telemetry contains no raw operator prompt.
- Prove version 1 contracts remain readable during migration.
- Prove a downstream installed copy enforces the same receipts and enums.

## Migration / rollout

1. Land SCOPE-1 and SCOPE-2 as additive versioned contracts.
2. Land SCOPE-3 before any blocking claim about G134 runner coverage.
3. Run SCOPE-4 through SCOPE-7 in shadow mode against the incident corpus.
4. Fix false classifications before enabling blocking mode.
5. Enable blocking for newly frozen mutable goals.
6. Adopt version 2 for a legacy goal only when that goal is revised.
7. Update installer assets and release metadata after all acceptance criteria pass.

No scope changes an existing Goal Contract silently. No scope interprets a historical generic approval as expansion approval.

## Risks & mitigations

- **R1 — Semantic metadata theater:** A planner could understate its change classes. Corroborate declarations against planned paths, node types, and the final diff.
- **R2 — False expansion findings:** A filename cannot prove architecture. Use closed path signals as corroboration, then print the exact conflicting declaration for review.
- **R3 — Budget guesswork:** Early estimates can be wrong. Use estimates before planning and exact paths before delivery. Growth requires review rather than silent adjustment.
- **R4 — Legitimate platform work blocked:** Record an approved Goal Contract revision. The mechanism delays undeclared work but does not prohibit declared work.
- **R5 — Prompt and context growth:** Carry hashes, enums, identifiers, and counts across transitions. Do not repeat raw operator requests.
- **R6 — Legacy disruption:** Keep version 1 readable. Require version 2 only for new or revised mutable goals.
- **R7 — Agent-only enforcement:** Require canonical receipts in scenario and result schemas. Do not rely only on agent prose.
- **R8 — Gate duplication:** Extend G134 and G094. Do not register a second semantic-fidelity gate unless measurement proves the existing gate cannot own it.

## Acceptance criteria (when implemented)

- Every new mutable autonomous run freezes a version 2 Goal Contract before planning.
- Every mutable top-level runner produces all applicable G134 boundary receipts.
- A compiled scenario carries the exact Goal Contract reference.
- Every scenario node maps to a success signal or hard constraint.
- Every scenario node records ownership fit and a planned delta.
- An undeclared change class fails before planning dispatch.
- An in-directory virtual-machine expansion fails despite a valid path boundary.
- An expansion approval binds the exact canonical delta digest.
- A generic continuation cannot approve expansion.
- Post-planning growth invalidates the prior expansion approval.
- One-off work cannot create a reusable foundation without Goal Contract revision.
- An independent finding cannot enter the current goal DAG.
- `neverStopForFixableObstacles` cannot override an expansion refusal.
- Version 1 contracts remain readable until revised.
- The incident-shaped overbuilt evaluation fails before its first planning dispatch.
- Framework selftests include a red control for every new acceptance path.
- `framework-validate` and `release-check` pass before downstream propagation.

## Files to touch (on approval)

`bubbles/scripts/goal-contract.sh` and `goal-contract-selftest.sh` (version 2 semantic boundary and revision rules), `bubbles/scripts/goal-fidelity-guard.sh` and `goal-fidelity-guard-selftest.sh` (semantic boundaries and receipts), planned `bubbles/scripts/goal-boundary-receipt.sh` plus selftest (canonical receipt producer), `bubbles/scripts/scenario-compile-lint.sh` plus selftest (Goal Contract reference, contribution, ownership fit, and planned delta), `bubbles/scripts/capability-foundation-guard.sh` plus selftest (bidirectional proportionality), `bubbles/scripts/goal-fidelity-telemetry.sh` plus selftest (shadow expansion events), `agents/bubbles_shared/operating-baseline.md` (shared boundary procedure), `agents/bubbles_shared/scenario-compile.md` (scenario schema and expansion approval), `agents/bubbles_shared/capability-foundation.md` (execution-shape precedence), `agents/bubbles.goal.agent.md`, `agents/bubbles.sprint.agent.md`, `agents/bubbles.iterate.agent.md`, and `agents/bubbles.workflow.agent.md` (mandatory receipts and convergence brake), `agents/bubbles.validate.agent.md` (receipt verification), `bubbles/workflows.yaml` and registry-generated mirrors (G134 and mode policy), framework selftests, installer manifests, and release documentation. Owners: framework implementation, `bubbles.goal`, `bubbles.sprint`, `bubbles.iterate`, `bubbles.workflow`, `bubbles.plan`, and `bubbles.validate` under G094, G125, and G134.
