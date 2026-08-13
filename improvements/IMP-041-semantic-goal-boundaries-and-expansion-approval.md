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

### SCOPE-1 — Goal Contract v2 semantic boundary (GF-8)

Extend the Goal Contract with a versioned `semanticBoundary` object. New mutable goals must declare it before planning starts.

Use a closed execution-shape enum:

- `one-off` for a bounded evaluation, migration, repair, or operator utility.
- `existing-capability-change` for work inside an established foundation.
- `reusable-capability` for an approved new shared foundation.

Use a closed change-class enum. The first version must include:

- `existing-config`.
- `existing-test`.
- `new-product-code`.
- `new-shared-library`.
- `new-workflow`.
- `new-runner`.
- `new-virtual-machine`.
- `new-daemon`.
- `new-init-unit`.
- `new-datastore`.
- `new-cache`.
- `new-approval-authority`.
- `new-network-topology`.
- `new-deployment-target`.

The boundary declares `allowedChangeClasses` and `approvalRequiredChangeClasses`. The two arrays must not overlap.

The boundary also declares a `deltaBudget`. It records non-negative maxima for new scopes, files, workflows, services, runners, and virtual machines.

`goal-contract.sh freeze` accepts the new fields and writes contract version 2. `verify`, `ref`, `verify-ref`, `mirror`, and `sync-boundary` preserve them.

`goal-contract.sh revise --approval-note` remains the only widening path. A semantic widening increments the revision and invalidates prior references.

Legacy version 1 contracts remain readable. Any revised mutable goal adopts version 2 before more work starts.

#### SCOPE-1 tests

- Freeze and verify every execution shape.
- Refuse unknown change classes and negative budgets.
- Refuse overlap between allowed and approval-required classes.
- Accept semantic narrowing without approval.
- Refuse semantic widening without an approval note.
- Invalidate prior references after an approved semantic revision.
- Preserve version 1 read compatibility.

### SCOPE-2 — Scenario contribution and planned-delta contract (GF-9)

Extend each mutable scenario node with `contributesTo`, `ownershipFit`, and `plannedDelta`.

`contributesTo` contains stable identifiers for the root success signal or hard constraints. Every node must name at least one identifier.

`ownershipFit` records why the selected spec, OPS packet, mode, or agent is the narrowest valid owner. It names the exact existing requirement, scenario, or command surface.

`plannedDelta` records:

- Change classes.
- New and modified paths when known.
- Maximum new scopes and files.
- Maximum new workflows, services, runners, and virtual machines.
- Whether the node changes shared infrastructure.

Planning nodes may use bounded estimates before detailed planning. Post-planning validation replaces estimates with exact planned paths and counts before delivery.

`scenario-compile-lint.sh` must refuse these conditions:

- A node has no outcome contribution.
- A node has no ownership-fit record.
- A change class is absent from the frozen semantic boundary.
- A planned count exceeds the frozen delta budget.
- A node claims an existing mechanism but plans a new provider or topology.
- A node carries a stale or substituted Goal Contract reference.

The scenario plan stores one canonical Goal Contract reference. Node packets derive their reference from it.

#### SCOPE-2 tests

- Accept a compact existing-config evaluation plan.
- Refuse a shape-valid node with no outcome contribution.
- Refuse an unrelated infrastructure node inside an allowed path.
- Refuse a stale Goal Contract revision.
- Refuse an exceeded scope or file budget.
- Refuse an ownership-fit record that names no declared target.

### SCOPE-3 — Mandatory G134 boundary receipts (GF-7)

Make every mutable top-level runner call the existing G134 boundaries. A prose instruction is not sufficient.

Add a canonical boundary-receipt producer. It calls `goal-fidelity-guard.sh` and emits a canonical receipt only after success.

The receipt binds:

- Goal identifier and revision.
- Source-request digest.
- Semantic-boundary digest.
- Scenario digest when applicable.
- Boundary name.
- Candidate repository, spec, and path reach.
- Planned-delta digest when applicable.

Require receipts at these points:

- `pre-planning` before scenario compilation or a planning specialist dispatch.
- `post-planning` before a delivery node becomes eligible.
- `pre-dispatch` before every mutable specialist dispatch.
- `post-finding` before the parent accepts changed paths or a DAG amendment.
- `post-compaction` before mutable work resumes.
- `pre-certification` before validation can certify completion.

Update `bubbles.goal`, `bubbles.sprint`, `bubbles.iterate`, and `bubbles.workflow`. Each runner must use the same receipt contract.

The scenario ledger and RESULT-ENVELOPE carry the receipt digest. Missing, stale, or mismatched receipts refuse continuation.

#### SCOPE-3 tests

- Refuse a goal runner that skips pre-planning.
- Refuse a dispatch with no pre-dispatch receipt.
- Refuse a result whose receipt names another revision.
- Refuse a resumed run with a stale post-compaction receipt.
- Accept the same receipt through compaction without normalization.
- Prove all four top-level runners use the shared contract.

### SCOPE-4 — Architecture-expansion approval (GF-10)

Add a planning approval checkpoint before any approval-required change class enters planning or delivery.

The checkpoint is distinct from host-action approval. It authorizes architecture expansion, not runtime mutation.

The preview shows:

- The new change classes.
- The reason each class contributes to the outcome.
- Planned scope and file counts.
- Planned workflows, services, runners, virtual machines, and datastores.
- Shared-infrastructure impact.
- The narrower rejected alternative.
- Rollback or withdrawal behavior.

Canonicalize the preview and calculate an `expansionDigest`. Approval binds that digest through `goal-contract.sh revise --approval-note`.

A generic `continue`, `approved`, or action approval does not approve architecture expansion. The approval must name the expansion digest.

Any later delta increase invalidates the approval. Narrowing remains valid without a new approval.

#### SCOPE-4 tests

- Refuse planning that introduces a virtual machine without expansion approval.
- Refuse delivery that adds a runner absent from the approved preview.
- Refuse a generic continuation message as expansion approval.
- Refuse approval for an older expansion digest.
- Accept the exact approved digest once the Goal Contract revision changes.
- Accept a narrower post-approval plan.

### SCOPE-5 — Bidirectional proportionality enforcement (GF-11)

Make G094 enforce both missing abstraction and premature abstraction.

Use the frozen `executionShape` as the primary applicability signal. Keep keyword detection as a mismatch warning and legacy fallback.

Apply these rules:

- `one-off` requires a non-empty single-implementation justification when trigger words appear.
- `one-off` refuses `foundation:true` scopes and new extension-point frameworks.
- `existing-capability-change` may extend the named foundation but cannot create a parallel foundation.
- `reusable-capability` requires the current capability-foundation sections and foundation-first ordering.
- A planner cannot change the execution shape. Only a Goal Contract revision can change it.

The guard must inspect planning artifacts and the active Goal Contract reference. It must identify the conflicting scope or section.

#### SCOPE-5 tests

- Accept one-off work with a concrete justification.
- Refuse a foundation scope under a one-off goal.
- Refuse a second foundation under an existing-capability change.
- Require foundation sections for an approved reusable capability.
- Refuse keyword-only promotion from one-off to reusable capability.

### SCOPE-6 — Finding-to-scenario admission control (GF-12)

Require every finding-driven DAG amendment to carry `goalImpact` and `contributesTo`.

Apply the existing impact vocabulary:

- `required` may enter the current DAG when it maps to the frozen outcome.
- `blocking-external` may block the goal but cannot authorize implementation.
- `independent` routes to a separate proposal, spec, bug, or backlog record.

A specialist cannot promote its own finding from `independent` to `required`. The parent must verify the mapping against the Goal Contract.

The parent reruns pre-dispatch validation after every accepted amendment. The scenario ledger records the finding identifier and contribution mapping.

#### SCOPE-6 tests

- Accept a required finding that maps to a hard constraint.
- Refuse an independent finding inserted into the current DAG.
- Preserve a blocking-external finding without creating implementation work.
- Refuse a finding reported as addressed when it was only routed.
- Refuse a specialist-authored impact upgrade without a parent decision.

### SCOPE-7 — Convergence materiality brake (GF-13)

Add a materiality check before every autonomous convergence iteration.

Compare the current scenario and planned delta with the last approved digests. Stop when either grows.

Classify undeclared expansion as a new goal. Do not classify it as a fixable obstacle.

Update autonomous-mode rules:

- `neverStopForFixableObstacles` does not apply to goal expansion.
- Solution search may find narrower implementations inside the boundary.
- Solution search cannot add a change class or target.
- A generic continuation resumes only the approved graph.
- Session budgets limit runtime cost but never grant more scope.

The refusal names the exact added class, target, path, or count. It offers narrowing or an approved Goal Contract revision.

#### SCOPE-7 tests

- Refuse a second iteration that adds a workflow.
- Refuse a resumed run that adds another repository.
- Refuse a generic continuation after a material delta increase.
- Accept a second iteration that narrows paths and keeps the same classes.
- Prove solution search cannot bypass the semantic boundary.

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
