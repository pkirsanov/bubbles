# IMP-038 - Goal Fidelity and Bounded Autonomous Delivery

**Status:** PROPOSED (not yet applied) - awaiting owner review
**Surface:** framework-health (G125) - human-reviewed. NO auto-mutation of bubbles/* until approved
**Motivation:** A source review of the goal-oriented runners found that autonomous delivery can preserve process completion while losing fidelity to the operator's original outcome. The review traced goal intake, planning, dispatch, finding closure, compaction, phase relevance, and final validation. Focused selftests passed, which shows a contract gap rather than a broken resolver. A second review pass falsified part of the first pass and is recorded below.
**Verified gaps addressed:** GF-1 - ordinary goals have no durable immutable goal contract. GF-2 - work boundaries are optional and absent from new feature state. GF-3 - the finding-closure modules disagree with each other and none is boundary-aware. GF-4 - phase relevance excludes goal-family runners while documentation describes it as general runner behavior. GF-5 - current selftests do not exercise end-to-end goal fidelity. GF-6 - the outcome-contract gate declares an enforcer that does not exist.

## Problem (verified against source)

- **GF-1 - ordinary goals do not retain the original outcome as immutable authority.** `agents/bubbles.goal.agent.md` accepts free-form goal text. It creates a `rootOutcome` only for a compiled cross-repository or multi-phase scenario. Ordinary single-spec goals proceed through mutable planning artifacts. `bubbles/scripts/state-snapshot.sh` stores phase, scope, agent, and iteration metadata, but no goal identity or goal digest. `bubbles.validate` Gate G070 then compares implementation evidence with the current `spec.md` Outcome Contract. It does not compare that contract with the original operator outcome.
- **GF-2 - the anti-wandering boundary is opt-in.** `agents/bubbles_shared/feature-templates.md` omits `workBoundary` from the version 3 `state.json` template. `bubbles/scripts/work-boundary-resolve.sh` returns `in-boundary` when `state.json` or `workBoundary` is absent. Its focused selftest explicitly accepts that permissive behavior for compatibility. A newly planned autonomous goal can therefore enter mutable execution without a declared repository, spec, or path boundary.
- **GF-3 - the finding-closure modules disagree and none is boundary-aware.** `agents/bubbles_shared/completion-governance.md` permits a finding to close as fixed, routed to the correct owner, or blocked. `agents/bubbles_shared/workflow-phase-engine.md` and `agents/bubbles_shared/workflow-fix-cycle-protocol.md` are stricter: they require every finding to complete the planning and delivery chain before the parent may advance, and they classify a finding-only result as malformed. `agents/bubbles_shared/workflow-delegation-core.md` requires the opposite for unrelated same-repository work, which is route-only. A runner reading the strict pair expands the active delivery effort. A runner reading the permissive pair routes. None of the four modules asks whether the finding is inside the work boundary or whether it affects the declared outcome, so the decision is left to interpretation at the exact moment scope grows.
- **GF-4 - smart phase routing does not cover the goal family.** `bubbles/workflows/modes.yaml` says phase relevance applies only to `bubbles.workflow`. `agents/bubbles.goal.agent.md`, `agents/bubbles.sprint.agent.md`, and `agents/bubbles.iterate.agent.md` contain no phase-relevance contract. No phase-relevance executor or behavioral selftest exists. `docs/guides/WORKFLOW_MODES.md` instead says the active authorized runner checks relevance and describes `full-delivery` as the balanced default.
- **GF-5 - current tests prove structure, not goal fidelity.** `bubbles/scripts/workflow-delegation-selftest.sh` checks runner roles, frontmatter, and direct authorized execution. `bubbles/scripts/work-boundary-resolve-selftest.sh` checks boundary dispositions and preserves the no-boundary permissive case. Neither test passes a goal through planning, finding expansion, compaction, resume, and final validation to prove that the delivered result still matches the initial outcome.
- **GF-6 - the outcome-contract gate names an enforcer that does not exist.** `bubbles/registry/gates.yaml` declares `G070` with `enforcedBy: [ unbound ]` while its own description states it is "Enforced by artifact-lint.sh (presence check) and bubbles.validate Step 0 (substance check)". `bubbles/scripts/artifact-lint.sh` contains no reference to the Outcome Contract, Intent, Hard Constraints, or Failure Condition. A repository-wide search for `G070` across `bubbles/scripts/` returns exactly one hit, in `bubbles/scripts/scenario-compile-lint.sh`, which validates a compiled scenario `rootOutcome` rather than a feature `spec.md`. For the ordinary feature path the Outcome Contract therefore has no mechanical presence check and no mechanical substance check. The one gate written to catch correct process with the wrong outcome is agent-behavioral only. The `unbound` value itself is deliberate and is not the defect. The defect is the description asserting an enforcer that is absent, which makes the gate read as mechanically covered.

## Confirmed non-findings

- The boundary resolver behaves correctly when a valid boundary exists.
- Nested workflow-runner dispatch is not the cause. The delegation selftest confirms direct authorized execution.
- The scenario compiler already defines and verifies `rootOutcome`. This proposal reuses that foundation.
- The review found no planner rule that automatically promotes analyst Improvement Proposals into executable scopes.

## Second-pass corrections

A second review pass re-checked every first-pass claim against source. Two claims were wrong or overstated and are corrected here rather than silently rewritten.

| First-pass claim | Verified position |
| --- | --- |
| Every discovered finding must be fixed inline, so the framework mandates expansion | Overstated. `completion-governance.md` already accepts routing to the owner as valid closure, and Gate `G095` already defines a closed six-value disposition set with a working enforcer. The real defect is that the strict and permissive modules disagree and none consults the work boundary or the declared outcome |
| A new four-value finding disposition vocabulary is required | Withdrawn. The disposition vocabulary already exists. SCOPE-4 now reuses `G095` and the `observations[]` schema and adds only the missing goal-impact dimension |

The second pass also produced one new verified gap, GF-6, which strengthens rather than weakens the proposal.

The methodology correction recorded in `.specify/memory/open-work.md` OW-012 was applied deliberately. That entry documents a prior false claim produced by grepping `bubbles/scripts/` instead of reading the registry's `enforcedBy` field. GF-4 was therefore re-verified against `bubbles/registry/gates.yaml` rather than by script search. No gate in the registry covers phase relevance under any name, so GF-4 stands.

## Existing partial mitigations (verified, not duplicated)

These mechanisms already exist and this proposal composes with them instead of rebuilding them.

| Mechanism | What it already bounds | What it does not bound |
| --- | --- | --- |
| Gate `G095` discovered-issue disposition with `discovered-issue-disposition-guard.sh` | Every observed issue must be filed the same turn under one of six dispositions, and report-and-wait is forbidden | Whether the finding is inside the work boundary, and whether fixing it inline serves or displaces the requested outcome |
| Gate `G128` session budgets with `session-cap-guard.sh` | Aggregate convergence iterations, wall-clock minutes, and tool calls across a session | Scope. A run can stay inside budget while delivering work the operator never requested |
| `observations[]` in `completion-governance.md` | A non-blocking low or medium note with a concrete owner and follow-up action | A required boundary decision. Observations explicitly must not launder a gate failure or a required repair |
| `bubbles/scripts/risk-tier-resolve.sh` | Fail-closed proportionality between `rapid-tool-delivery` and `full-delivery`, re-evaluatable at intake, post-plan, and pre-certification | Per-phase relevance inside the selected mode, and it deliberately adds no budget mechanism |
| `.specify/memory/open-work.md` residue register | Durable storage for work that was noticed and never filed | Nothing routes goal-displacing findings into it automatically |

## Provenance

This proposal uses current source inspection and current-session command output. It does not infer behavior from agent or script names.

| Source | Established fact |
| --- | --- |
| `agents/bubbles.goal.agent.md` | Ordinary goal routing, scenario-only `rootOutcome`, exhaustive verification, and remediation loops |
| `agents/bubbles_shared/workflow-phase-engine.md` | Every trigger-phase finding must complete planning and delivery before phase advancement |
| `agents/bubbles_shared/workflow-fix-cycle-protocol.md` | A mapped mode returning findings without the planning and delivery chain is a malformed result |
| `agents/bubbles_shared/completion-governance.md` | Finding closure already accepts fixed, routed to owner, or blocked, and defines the `observations[]` schema and severity rules |
| `agents/bubbles_shared/operating-baseline.md` | Gate `G095` defines six discovered-issue dispositions and the file-on-discovery rule |
| `bubbles/registry/gates.yaml` | `G070` is `enforcedBy: [ unbound ]` while its description claims enforcement by `artifact-lint.sh`. `G095` and `G128` are script-enforced |
| `bubbles/scripts/artifact-lint.sh` | Contains no Outcome Contract, Intent, Hard Constraint, or Failure Condition check |
| `bubbles/scripts/scenario-compile-lint.sh` | The only script naming `G070`, and it validates a compiled scenario `rootOutcome` rather than a feature spec |
| `bubbles/scripts/risk-tier-resolve.sh` | Fail-closed proportionality already exists and deliberately adds no budget mechanism |
| `.specify/memory/open-work.md` | The residue register exists, and OW-012 records the script-grep methodology error this review avoided |
| `agents/bubbles_shared/workflow-delegation-core.md` | Out-of-boundary work is route-only and must not be fixed inline |
| `agents/bubbles_shared/feature-templates.md` | The current version 3 state template has no goal contract or work boundary |
| `bubbles/scripts/state-snapshot.sh` | Session snapshots persist phase, scope, agent, and iteration data without a goal digest |
| `bubbles/scripts/work-boundary-resolve.sh` | Missing state or boundary resolves permissively to `in-boundary` |
| `bubbles/workflows/modes.yaml` | `full-delivery` requires broad quality phases and closes all discovered bugs in-run. Phase relevance is limited to `bubbles.workflow` |
| `agents/bubbles.validate.agent.md` | G070 verifies the mutable spec Outcome Contract against implementation evidence |
| `docs/guides/WORKFLOW_MODES.md` | Published guidance describes phase relevance as active-authorized-runner behavior and calls `full-delivery` balanced |
| `bubbles/scripts/workflow-delegation-selftest.sh` | Existing coverage checks runner structure but not outcome retention |
| `bubbles/scripts/work-boundary-resolve-selftest.sh` | Existing coverage deliberately accepts a missing boundary |
| Current-session focused validation | `workflow-delegation-selftest.sh`, `work-boundary-resolve-selftest.sh`, and `mode-family-inventory-selftest.sh` all passed before this proposal was written |
| Git commit `180a3f2` | The boundary foundation landed with planning-time boundary creation recorded as remaining adoption work |

## Target outcome

An autonomous runner must deliver the operator-approved outcome and must not absorb unrelated work. It must preserve all quality and finding-accounting requirements inside that outcome. It must route valid collateral findings without losing them. It must block when collateral work prevents the declared success signal or violates a hard constraint.

## Proposal

### SCOPE-4 - Reconcile finding closure with bounded delivery (GF-3)

Do not introduce a new disposition vocabulary. Gate `G095` already defines the closed set `fixed-in-session`, `bug-filed`, `spec-filed`, `ops-filed`, `routed`, and `status-adjusted`, and `discovered-issue-disposition-guard.sh` already enforces same-turn filing. Reuse both unchanged.

Add the one dimension that is missing. Every finding raised during a goal run must also carry a `goalImpact` classification:

| `goalImpact` | Meaning | Parent goal behavior |
| --- | --- | --- |
| `required` | Inside the work boundary, and the Goal Contract cannot be satisfied while it is open | Complete the existing finding-owned planning and delivery chain before advancing |
| `blocking-external` | Outside the work boundary, but it prevents the success signal or violates a hard constraint | Block the parent and request the operator-approved expansion or an external repair |
| `independent` | Valid work that does not affect the success signal or any hard constraint | Discharge it through its existing `G095` disposition under a separate scoped packet, then continue the parent without inline implementation |

`goalImpact` is orthogonal to the `G095` disposition. A finding always has both. The disposition records what was filed. The classification records what it means for the requested outcome.

Resolve the module disagreement in one change. `workflow-phase-engine.md` and `workflow-fix-cycle-protocol.md` must state that their mandatory planning and delivery chain applies to `required` findings, and that an `independent` finding is discharged by filing plus routing rather than by inline delivery. `completion-governance.md` keeps routing as valid closure and gains the boundary condition. `workflow-delegation-core.md` keeps route-only handling for out-of-boundary work. None of these changes weakens the existing prohibition on cherry-picking easy in-boundary findings.

Routing remains distinct from resolution. Extend result accounting so a routed finding cannot be reported as addressed, and record its filed artifact path. An `independent` finding that has no filed artifact is not discharged.

Final validation must confirm that every `independent` classification is genuinely independent of the success signal and hard constraints. If independence cannot be demonstrated, the finding is `blocking-external` and the parent blocks. `observations[]` remains available for low and medium non-blocking notes under its existing severity rules and must not be used to reclassify a `required` finding.

### SCOPE-6 - Enforce Goal Fidelity at planning and completion boundaries (GF-1, GF-2, GF-3, GF-6)

Add a planned goal-fidelity guard. Assign its gate identifier only when the enforcement script is registered. Do not reserve or document an unenforced gate id in this proposal.

The guard must check these boundaries:

1. Before planning, the Goal Contract is complete, frozen, and bound to a repository decision.
2. After planning, every active requirement and scope traces to the Goal Contract.
3. Before dispatch, the candidate work is inside the boundary and carries the current digest.
4. After finding handling, no out-of-boundary path changed inside the parent packet.
5. After compaction or resume, the contract digest and boundary are unchanged.
6. Before final certification, evidence demonstrates the original success signal and preserves every hard constraint.

Repair `G070` in the same scope. Its declared enforcement is currently absent, so the goal-to-spec link and the spec-to-implementation link are both unenforced for ordinary feature work. Two corrections are required. First, correct the registry description so it states the true enforcement surface instead of naming `artifact-lint.sh`. Second, give the ordinary feature path a real presence check for the Outcome Contract, either by adding it to `artifact-lint.sh` and updating `enforcedBy`, or by folding it into the new goal-fidelity guard. Leaving `enforcedBy: [ unbound ]` is acceptable only while the description matches that reality, because the `unbound` value exists to keep an unenforced gate visible.

`bubbles.validate` must independently verify both links before certification. Substance verification of the success signal stays with validate. Presence and traceability become mechanical.

A changed Goal Contract revision invalidates stale planning and certification claims that depended on the prior digest. The active runner must route those artifacts back to their owners before mutable work resumes.

### SCOPE-7 - Add adversarial goal-fidelity coverage and telemetry (GF-5)

Add focused selftests and evaluation fixtures for these cases:

- A narrow goal whose planner adds an unrelated adjacent capability is refused as an unapproved expansion.
- A broad quality phase discovers an unrelated same-repository bug. The bug is filed separately and the parent files remain unchanged.
- An out-of-boundary finding invalidates the success signal. The parent blocks instead of routing it as independent.
- Compaction and resume preserve the exact goal id, revision, digest, and boundary.
- A specialist returns a substituted goal digest or a path outside the boundary. The runner refuses the result.
- An operator-approved expansion increments the revision, updates the digest, and reopens affected planning.
- Goal, sprint, iterate, and workflow receive identical phase-relevance verdicts for the same scope.
- A historical read-only target without `workBoundary` remains readable. Its first new mutable run creates and freezes a boundary before editing.
- Existing compiled scenarios continue to validate after `rootOutcome` adopts the common schema.
- A feature `spec.md` with a missing or empty Outcome Contract is refused by a real executed check rather than by agent judgement alone.
- An `independent` finding without a filed `G095` artifact is refused as undischarged.
- The existing `G095` disposition set and the `observations[]` severity rules keep their current behavior after the `goalImpact` field is added.

Record bounded framework telemetry for contract revisions, expansion requests, rejected expansions, routed findings, goal-blocking findings, boundary refusals, and phase-relevance decisions by runner. Telemetry must not store raw operator prompts.

Add a regression that fails if published workflow guidance claims broader phase-relevance support than the executable runner set provides.

## Migration / rollout

1. Land the schema and additive session fields first. Existing sessions remain readable.
2. Thread goal identity through dispatch, results, snapshots, compaction, and resume before enforcing it.
3. Add strict boundary derivation for new mutable runs. Preserve legacy read-only access.
4. Land the `goalImpact` classification and the module reconciliation together. Do not change closure semantics in only one document, and do not alter the existing `G095` disposition set.
5. Land the shared phase-relevance resolver and wire all four runners before updating documentation claims.
6. Land final goal-fidelity enforcement after the adversarial selftests pass.
7. Run full framework validation and release checks only after all accepted source scopes land.
8. Upgrade downstream repositories only after the canonical source commit is pushed. Each downstream upgrade uses its own repository-bound invocation.

The canonical source repository must not create a persistent `specs/` tree for this work. The accepted IMP, focused selftests, framework validation, and release checks provide the source evidence under existing G085 policy.

## Explicitly rejected designs

- **Treat the mutable spec as the original goal.** Planning can change the spec, so this does not detect planning drift.
- **Use a digest without a human-readable contract.** A stable hash proves identity but not semantic fidelity.
- **Silently revise the goal when a specialist needs more scope.** This recreates the defect under a different field name.
- **Fix every discovered issue inside the parent goal.** This defeats the work boundary and causes the observed spread.
- **Drop or hide unrelated findings.** Every finding still requires a recorded disposition and owner.
- **Allow severity alone to bypass the boundary.** A severe finding blocks only when it affects the success signal or hard constraints. Otherwise it routes separately.
- **Keep phase relevance as prompt prose.** Documentation cannot substitute for an executable resolver and adversarial tests.
- **Reduce assurance by skipping relevant phases.** Unknown relevance remains fail-closed and runs the phase.
- **Invent a second finding-disposition vocabulary.** Rejected after the second pass. `G095` already owns the disposition set and has a working enforcer. This proposal adds only the orthogonal `goalImpact` classification.
- **Add another session budget or risk tier.** Rejected. `G128` already bounds aggregate session cost and `risk-tier-resolve.sh` already resolves proportionality fail-closed. Neither bounds scope, which is what this proposal addresses.
- **Delete the `unbound` marker on `G070` to make the registry look consistent.** Rejected. The marker keeps an unenforced gate visible. Repair the false description and add real enforcement instead.

## Risks & mitigations

- **R1 - an initial contract misinterprets the operator.** -> Show the normalized contract before planning in the runner's first status update. Require approval only when ambiguity or later expansion appears.
- **R2 - a narrow boundary omits a real transitive dependency.** -> Let planning propose a traced expansion. Require operator approval before widening the frozen contract.
- **R3 - routed findings become a hiding place for blockers.** -> Require final validation to prove independence from the success signal and hard constraints. Unproven independence becomes `blocking-external`.
- **R4 - semantic trace checks become model-only assertions.** -> Enforce ids, digests, boundary paths, and scope contribution fields mechanically. Keep substantive outcome verification with independent validate and audit phases.
- **R5 - contract fields inflate every prompt.** -> Pass the stable id, digest, and bounded normalized contract. Keep raw prompts out of telemetry and compact records.
- **R6 - phase relevance skips a newly relevant check.** -> Treat unknown as `run` and re-evaluate after every artifact, boundary, finding, or gate change.
- **R7 - legacy sessions cannot satisfy the new contract.** -> Preserve read-only compatibility. Require synthesis and freeze before the first new mutable action.
- **R8 - separate filing creates depth-two dispatch.** -> The active top-level runner dispatches the filing owner directly under a new scoped packet. A specialist only returns `route_required` upward.
- **R9 - the new classification duplicates the existing disposition set.** -> `goalImpact` is orthogonal and additive. The `G095` vocabulary, its guard, and the `observations[]` severity rules are reused unchanged, and a selftest asserts their behavior is preserved.

## Acceptance criteria (when implemented)

- Every new mutable top-level run has one frozen Goal Contract before planning begins.
- Goal id, revision, digest, and boundary survive planning, dispatch, result aggregation, compaction, resume, and final validation unchanged.
- Every active requirement and scope maps to the Goal Contract or an operator-approved revision.
- Every new mutable goal has a strict work boundary. Missing boundaries refuse before source mutation.
- No specialist may mutate a repository, spec, or path outside the parent boundary.
- Every finding receives one closed disposition. Routed findings remain visible and are never labeled addressed.
- Every finding raised during a goal run carries both a `G095` disposition and a `goalImpact` classification.
- The existing `G095` disposition set, its guard behavior, and the `observations[]` severity rules are unchanged by this work.
- An unrelated finding can be filed under a separate packet without expanding the parent goal.
- A finding that prevents the success signal or violates a hard constraint blocks the parent regardless of repository boundary.
- Goal, sprint, iterate, and workflow apply the same executable phase-relevance rules.
- Unknown phase relevance runs the phase. Every skip has a reason and is re-evaluated after relevant changes.
- Final validation proves both goal-to-spec fidelity and spec-to-implementation fidelity.
- Adversarial fixtures cover unauthorized expansion, digest substitution, boundary escape, collateral findings, blocking external findings, compaction, resume, approved revision, and runner parity.
- Published documentation matches the executable phase-relevance and goal-fidelity surfaces.
- `G070` no longer names an enforcer that does not exist. Its registry description matches its real enforcement surface, and an ordinary feature `spec.md` receives a real executed Outcome Contract presence check.
- `bubbles/scripts/framework-health-evidence-lint.sh` reports no G125 findings while IMP-038 remains active.

## Files to touch (on approval)

Goal-contract and orchestration surfaces route through `bubbles.super` and the authorized top-level runners: planned new `bubbles/schemas/goal-contract.schema.json`, planned new `bubbles/scripts/goal-contract-*.sh`, planned new `bubbles/scripts/goal-fidelity-guard.sh`, planned new `bubbles/scripts/phase-relevance-resolve.sh`, `bubbles/scripts/work-boundary-resolve.sh`, `bubbles/scripts/state-snapshot.sh`, `bubbles/scripts/context-compactor.sh`, `bubbles/schemas/result-envelope.schema.json`, `bubbles/workflows/modes.yaml`, `agents/bubbles.goal.agent.md`, `agents/bubbles.sprint.agent.md`, `agents/bubbles.iterate.agent.md`, and `agents/bubbles.workflow.agent.md`.

Planning and state-template traceability route through `bubbles.analyst` and `bubbles.plan`: `agents/bubbles_shared/feature-templates.md`, `agents/bubbles_shared/workflow-orchestration-core.md`, and the relevant planning agent contracts.

Finding policy and result accounting route through the orchestration owner and `bubbles.validate`: `agents/bubbles_shared/critical-requirements.md`, `agents/bubbles_shared/workflow-phase-engine.md`, `agents/bubbles_shared/workflow-fix-cycle-protocol.md`, `agents/bubbles_shared/workflow-delegation-core.md`, `agents/bubbles_shared/workflow-orchestration-core.md`, `agents/bubbles_shared/completion-governance.md`, `agents/bubbles_shared/operating-baseline.md`, `skills/bubbles-result-envelope/SKILL.md`, and result validation scripts. `bubbles/scripts/discovered-issue-disposition-guard.sh` is reused and must keep its current behavior.

Enforcement and certification route through `bubbles.validate`: `bubbles/scripts/artifact-lint.sh`, `bubbles/scripts/state-transition-guard.sh`, `bubbles/registry/gates.yaml`, `bubbles/workflows.yaml`, and focused guard selftests. Register a gate id only after its enforcing script exists.

Adversarial fixtures and focused selftests route through `bubbles.test`: planned goal-contract, goal-fidelity, phase-relevance, compaction, resume, and boundary selftests under `bubbles/scripts/` and labeled fixtures under `bubbles/eval/`.

Managed documentation routes through `bubbles.docs`: `docs/guides/WORKFLOW_MODES.md`, `docs/CHEATSHEET.md`, `CHANGELOG.md`, and generated catalogs. Packaging lands last through `bubbles/scripts/generate-release-manifest.sh` and `bubbles/release-manifest.json`.
