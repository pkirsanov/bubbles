# IMP-026 — Interaction Discipline And Context-Efficient Planning

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** comparative review of Matt Pocock's MIT-licensed `mattpocock/skills` workflow, its published tutorial transcript, and the current Bubbles agent, skill, review, planning, handoff, and compaction contracts
**Verified gaps addressed:** ID1 facts-versus-decisions interaction gap; ID2 wide-refactor sequencing gap; ID3 handoff duplication/redaction gap; ID4 review-axis masking risk; ID5 skill invocation/context-load gap; ID6 context-fit sizing gap; ID7 tracker projection gap; ID8 runnable design-question gap
**External-source posture:** ideas may be adapted under the upstream MIT license; implementation should use Bubbles terminology and contracts rather than copying upstream prose. Any substantial copied portion must preserve the upstream copyright and license notice.

## External design inputs

- Repository and tutorial source: <https://github.com/mattpocock/skills>
- Upstream license: <https://github.com/mattpocock/skills/blob/main/LICENSE> (MIT, Copyright 2026 Matt Pocock)
- Interaction discipline: upstream `skills/productivity/grilling/SKILL.md`
- Context-sized vertical slices and wide-refactor exception: upstream `skills/engineering/to-tickets/SKILL.md`
- Independent review axes: upstream `skills/engineering/code-review/SKILL.md`
- Reference-first redacted session transfer: upstream `skills/productivity/handoff/SKILL.md`
- Invocation/context-load authoring model: upstream `skills/productivity/writing-great-skills/SKILL.md`

These are design references, not completion evidence. Every Bubbles gap and proposed change below was independently checked against the canonical Bubbles source paths named in this proposal.

## Problem (verified against source)

- **ID1 — facts and decisions are not separated in interactive grilling:** `agents/bubbles.grill.agent.md` supports `mode: interactive`, bounded questions, and sharp recommendations, but it does not require the agent to research answerable facts itself, reserve operator judgment for decisions, ask one dependency-ordered decision at a time, or wait for an explicit shared-understanding confirmation before routing the result.
- **ID2 — vertical slicing has no wide-refactor exception:** `agents/bubbles_shared/planning-core.md` and `agents/bubbles.plan.agent.md` correctly reject horizontal plans, require consumer tracing, and protect risky refactors with change boundaries. Neither defines how to keep a broad mechanical rename/retype/migration green when no ordinary vertical slice can land independently.
- **ID3 — handoff can restate durable truth and has no explicit redaction contract:** `agents/bubbles.handoff.agent.md` requests a large copied packet containing active files, test state, evidence references, baseline health, continuation state, and code context. It does not explicitly prohibit duplicating detail already held in specs, reports, commits, diffs, and run-state, and it does not require secret or PII redaction.
- **ID4 — review normalization can mask an orthogonal failure:** `agents/bubbles.code-review.agent.md` dispatches independent specialist lenses, then deduplicates overlapping findings and merges them into one prioritized action list. `bubbles/code-review.yaml` has no top-level independent verdicts for requirement/spec fidelity and engineering standards, so a clean result on one dimension can soften presentation of a failure on the other.
- **ID5 — skill authoring omits the invocation-cost decision:** `skills/bubbles-skill-authoring/SKILL.md` already requires progressive disclosure and concise activation triggers, but it does not require authors to decide whether a skill must be automatically discoverable, account for the aggregate context cost of model-facing descriptions, or keep one distinct trigger per behavior branch.
- **ID6 — scope size is time-bounded but not context-bounded:** Gate G037 and the `maxScopeMinutes` / `maxDodMinutes` tags keep work small by outcome and estimated effort. They do not assert that a fresh specialist can execute one scope from durable artifacts without replaying the planning conversation or loading unrelated scopes.
- **ID7 — backlog exports stop before tracker projection:** `bubbles.plan` can emit `backlogExport: tasks|issues`, but the output remains copy-ready Markdown. There is no optional provider contract that projects scope IDs, blocking edges, and acceptance criteria into GitHub, GitLab, Jira, Linear, or another configured tracker while keeping `specs/**` authoritative.
- **ID8 — no isolated runnable design-question path exists:** the active agent, skill, and workflow registries contain no contract for a disposable logic/UI experiment whose sole purpose is to answer one unresolved design question, return that answer to the owning design artifact, and leave no product-code or completion-evidence residue.

## Proposal

### SCOPE-1 — Decision-aware interactive grilling (ID1)

- Keep the current autonomous grill behavior as the default. Strengthen only explicitly interactive or guarded runs.
- Classify each unresolved node as either a **fact** or a **decision**. The agent researches facts from code, tools, primary sources, and existing artifacts; it never asks the operator for information it can directly verify.
- Present decisions to the operator one at a time in dependency order, with a recommended answer and the consequence of choosing differently.
- Do not route or enact the resulting plan until the operator explicitly confirms that shared understanding has been reached.
- Preserve Bubbles artifact ownership: the grill records findings and routing packets; analyst, UX, design, and plan owners write their canonical artifacts.

### SCOPE-2 — Wide-refactor expand/migrate/contract planning (ID2)

- Add a planning exception for a broad mechanical contract change whose callers cannot be migrated through ordinary independently green vertical slices.
- Require three ordered stages: **expand** the new form beside the old; **migrate** consumer batches sized by blast radius while both forms remain valid; **contract** the old form only after consumer tracing proves zero callers remain.
- Make every migrate batch depend on expand and make contract depend on every migrate batch. Retain G043 consumer inventory, G044 regression protection, G067 blast-radius planning, and G069 change-boundary containment.
- Do not import an integration-branch escape hatch. Bubbles' trunk/release-train and repository-specific branch policy remains authoritative.

### SCOPE-3 — Reference-first handoff packets (ID3)

- Reduce the handoff packet to the live thread: current goal, active phase/scope, unresolved decisions/findings, latest executable evidence result, exact continuation envelope, and pointers to durable artifacts.
- Reference specs, designs, scopes, reports, run-state, commits, and diffs by path or identifier instead of copying their settled content.
- Redact secrets, credentials, tokens, private keys, personal identifiers, and deployment-specific sensitive values before presenting the packet.
- Retain the latest evidence/routing references needed for anti-fabrication and resume; compaction must not erase blockers or owner routing.

### SCOPE-4 — Orthogonal review verdicts (ID4)

- Add two mandatory top-level code-review axes:
  - **Contract/Spec Fidelity:** whether the diff implements the originating requirement without omission or scope injection.
  - **Engineering Standards/Quality:** whether the diff follows repository policy and sound engineering practice.
- Run the axes in separate specialist contexts and report a verdict plus findings for each. Deduplicate within an axis; when one finding belongs to both, retain it under both with a shared fingerprint.
- Keep optional security, stability, tests, docs, and simplification lenses. They enrich the engineering axis or remain named supporting sections; they do not collapse the two top-level verdicts into one score.
- A failure on either axis remains visible and independently routeable. No aggregate priority list may convert one failed axis into an overall clean result.

### SCOPE-5 — Skill invocation and context-load classification (ID5)

- Add an authoring decision for every skill: **automatic discovery required** or **explicit invocation sufficient**. Use harness-supported metadata only; do not invent unsupported VS Code frontmatter.
- Require automatic-discovery descriptions to lead with the behavior verb and carry one trigger per genuinely different branch. Synonym lists that restate one branch are removed.
- Record invocation class and description size in `skills/INVENTORY.md`, then extend the instruction-budget report to show aggregate skill-description load. Begin as report-only until outcome evidence supports a blocking threshold.
- Retain `bubbles-skills-first-discovery` as the human/model router; invocation classification supplements rather than replaces semantic skill discovery.

### SCOPE-6 — Single-specialist-context fit (ID6)

- Add a planning assertion such as `contextFit: single-specialist-context` to each executable scope.
- A scope satisfies the assertion only when a fresh specialist can determine the outcome, owned files/surfaces, dependencies, behavior scenarios, validation commands, and completion evidence from durable artifacts without replaying earlier chat.
- Extend G037 to reject scopes that require unrelated scope bodies or undocumented conversation state. Do not use a hardcoded token count: model windows and host compaction behavior vary.
- Keep `maxScopeMinutes` and `maxDodMinutes` as optional effort heuristics; context fit is an independent correctness property.

### SCOPE-7 — Optional work-tracker projection adapter (ID7)

- Add a project-configured provider contract for external work tracking. No provider is assumed when the config is absent.
- Project each selected Bubbles scope as an external item carrying the canonical spec path, scope ID, artifact revision, acceptance criteria, and native/fallback blocking edges.
- Persist returned external IDs and projection status in a project-owned mapping artifact. External comments and status never overwrite `spec.md`, `design.md`, `scopes.md`, certification state, or evidence.
- Require idempotent create/update behavior, dry-run preview, stale-revision detection, and explicit provider authentication through repository-approved tools. Secret values never enter artifacts or logs.

### SCOPE-8 — Isolated design experiment contract (ID8)

- Define a model-invoked design-experiment skill owned by the design path, not a delivery mode. It answers exactly one runnable design question through a bounded logic or UI experiment.
- Run in an isolated temporary worktree or equivalent disposable workspace. The experiment cannot satisfy implementation DoD, test evidence, integration evidence, or certification.
- Capture only the observed answer, assumptions, and decision-relevant interface/state shape into the design-owner routing packet. Delete the disposable workspace after capture and prove no experiment files remain in the product tree.
- Refuse an experiment when the question can be answered from existing code, primary documentation, or a cheaper static model. Refuse product-facing claims that lack real delivery evidence.

## Migration / rollout

- Land SCOPE-1 through SCOPE-4 first because they improve existing user-facing contracts without adding project configuration schemas.
- Land SCOPE-5 and SCOPE-6 after their metadata shapes are selected and covered by source/installed-layout selftests.
- Land SCOPE-7 only as an opt-in project extension with a provider-neutral schema and at least one hermetic adapter fixture. Existing `backlogExport` output remains valid.
- Land SCOPE-8 only with isolation, cleanup, and anti-fabrication regressions proving experiments cannot become delivery evidence.
- Keep the external repository as a cited design input. Reword adopted ideas into Bubbles terminology and preserve the MIT notice for any substantial copied material.

## Risks & mitigations

- **R1 — interactive confirmation weakens Bubbles autonomy:** apply it only when the user selects interactive/guarded grilling or when policy requires a human decision; autonomous workflows retain current behavior.
- **R2 — facts are mislabeled as decisions or vice versa:** require a reason and evidence source for the classification; uncertainty routes to a single operator question rather than silent inference.
- **R3 — expand/contract becomes a compatibility fallback that never dies:** make contract a required dependent scope with consumer-trace proof; completion cannot certify while the old form remains unless the governing spec explicitly keeps both contracts.
- **R4 — shorter handoffs omit critical evidence:** preserve blockers, next owner, evidence references, and raw pointers; remove duplicated prose, not routing provenance.
- **R5 — two-axis review duplicates findings:** shared fingerprints expose cross-axis identity while each axis retains its own verdict and impact.
- **R6 — context-fit metadata becomes another unchecked label:** extend G037 and planning selftests to inspect required durable inputs rather than trusting the declaration.
- **R7 — external trackers become a second source of truth:** make projection one-way for canonical behavior and certification; stale external state is reconciled from Bubbles artifacts, never the reverse.
- **R8 — experiments evade no-stub/no-fake policy:** isolate them from product source, prohibit completion evidence, and require cleanup proof plus a design-owner decision packet.

## Acceptance criteria (when implemented)

- Interactive grill fixtures prove facts are researched, decisions are asked singly in dependency order, and no routing occurs before explicit confirmation.
- Planning fixtures distinguish ordinary vertical slices from a genuine wide refactor and produce expand/migrate/contract dependencies with zero stale consumers at contract time.
- Handoff fixtures contain no duplicated artifact body, secret-like value, or PII token while preserving blockers, evidence pointers, and exact continuation routing.
- Code-review fixtures can produce `Spec: failed / Standards: passed` and `Spec: passed / Standards: failed` without either result being merged away.
- Skill inventory and budget reports expose invocation class plus aggregate description load without unsupported host metadata or an uncalibrated blocking threshold.
- G037 rejects an execution scope whose required intent or validation exists only in prior conversation, while a self-contained scope passes from a fresh specialist context.
- A configured tracker fixture creates blockers-first items idempotently, records external IDs, detects stale projection revisions, and leaves canonical Bubbles artifacts unchanged.
- A design experiment answers one declared question, routes the answer to the design owner, leaves no product-tree residue, and cannot satisfy delivery or certification gates.
- Focused selftests, `bash bubbles/scripts/cli.sh framework-validate`, and `bash bubbles/scripts/cli.sh release-check` pass with current-session evidence before any shipped claim.

## Files to touch (on approval)

`agents/bubbles.grill.agent.md` and a shared interaction module if reuse is proven (`bubbles.grill` / framework governance owner); `agents/bubbles_shared/planning-core.md`, `agents/bubbles.plan.agent.md`, Gate G037 registry/script/selftests, and planning recipes (`bubbles.plan`, `bubbles.test`, `bubbles.docs`); `agents/bubbles.handoff.agent.md` and handoff tests/docs (`bubbles.handoff`, `bubbles.test`, `bubbles.docs`); `bubbles/code-review.yaml`, `agents/bubbles.code-review.agent.md`, and review regressions (`bubbles.code-review`, `bubbles.test`); `skills/bubbles-skill-authoring/SKILL.md`, `agents/bubbles.create-skill.agent.md`, `skills/INVENTORY.md`, and budget/inventory checks (`bubbles.create-skill`, `bubbles.test`); project-config schema/templates plus a provider-neutral tracker adapter and fixtures (`bubbles.plan`, `bubbles.devops`, `bubbles.test`); an isolated design-experiment skill and cleanup regressions (`bubbles.design`, `bubbles.test`); public docs, capability ledger, changelog, generated surfaces, and release manifest only after behavior exists (`bubbles.docs`, `bubbles.releases`).