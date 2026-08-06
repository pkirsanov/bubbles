# IMP-036 — Delivery efficiency: close the dispatch hole, instrument the gates, and cut the ceremony that buys nothing

**Status:** ACCEPTED 2026-08-06 — owner approved. Implementation routes to the owners named under "Files to touch". SCOPE-1 remains gated on its own confirmation step.
**Surface:** framework-health (G125) — human-reviewed. NO auto-mutation of bubbles/* until approved.
**Motivation:** A portfolio-wide delivery-efficiency audit ran on 2026-08-05 across the six downstream delivery repos. It measured that roughly half of all commits touch no product code. It measured that a third of specialist agent runs never dispatched a specialist. It measured that 69% of bugs are filed against specs the gate battery had already certified `done`. The same audit measured a large improvement in convergence speed. This proposal therefore cuts ceremony without touching the mechanisms that produced that gain.
**Verified gaps addressed:** HO-1 (second-hop dispatch silently no-ops), HO-2 (`parent-expanded` accepted as a real dispatch), EV-6 (evidence can attest to a zero-test run), COV-6 (prose-only gates and no gate-hit telemetry), COST-2 (always-on context and dead policy surface), COST-3 (state and report write amplification), REG-6 (free-text `agent` field), REG-7 (gates carry no vintage)

## Problem (verified against source)

- **HO-1 — second-hop specialist dispatch silently no-ops.** `parent-expanded` appears **3,951 times** in downstream `state.json` prose, alongside `runtime lacks runSubagent` (325), `nested-runtime capability missing` (15), `no nested runtime` (10), `nested-runtime network timeout` (3) and `subagent dispatch error` (1). Share of all recorded invocations that are parent-expanded: smackerel 1530/4697 (33%), knb 234/706 (33%), guestHost 906/2808 (32%), wanderaide 892/4300 (21%), quantitativeFinance 362/2697 (13%), research-lab 27/401 (7%). This is **not** a frontmatter defect: `bubbles.workflow` declares the `agent` tool alias and `disable-model-invocation: true`, and all eight sampled specialists (`implement`, `test`, `validate`, `audit`, `design`, `plan`, `docs`, `security`) leave `disable-model-invocation` unset, so a top-level dispatch is correctly wired. The recorded failure strings name the failing route explicitly — `bubbles.workflow (parent-expanded bugfix-fastlane; runtime lacks runSubagent)` and `bubbles.devops (parent-expanded bugfix-fastlane)` — which places the failure at the **second hop**, where a specialist attempts to route to another specialist and the depth-1 runtime discards the call.
- **HO-2 — the framework accepts a dispatch that never happened.** `bubbles/scripts/state-transition-guard.sh` and `bubbles/scripts/top-level-runtime-routing-selftest.sh` both name `parent-expanded`, so the token passes the guard. The `bubbles-vscode-agent-constraints` skill states that unavailable tools are "silently ignored, not reported". Together these mean a failed dispatch is unobservable and is recorded as a completed specialist run. The specialist-ownership model, its result envelopes and its routing packets are therefore paid for on every run while collapsing into single-agent execution on roughly a third of them.
- **EV-6 — evidence can attest to a run that executed nothing.** The guestHost e2e suite executed **zero tests for 15 days** (2026-07-21 to 2026-08-05, broken by commit `188d11ce`), during which **12 spec commits** were recorded carrying passing e2e evidence. The runner exited non-zero, which reads as ordinary test failure, and the Execution Evidence Standard was satisfied because raw output from a broken runner is still raw output. Independently, **813 of 1,179 bug folders (69%)** are filed against a parent spec whose status is `done`, with 105 escaped defects still open, and the bug-to-feature ratio rose from 1.06 (Jan) to 2.87 (Jul). The gate battery is not the thing holding quality up.
- **COV-6 — a quarter of the gate catalogue cannot fail, and none of it is instrumented.** Of **134** declared gate ids, **108** are named in a script. **26 are named by no script at all.** Those 26 are G011, G012, G013, G014, G015, G016, G017, G023, G030, G032, G033, G036, G050, G054, G062, G065, G066, G071, G079, G081, G112, G113, G114, G116, G117 and G119. A gate no script names consumes agent attention and cannot reject anything. Separately, **no gate-hit telemetry exists anywhere in the framework**. No gate can therefore be retired on evidence rather than opinion.
- **COST-2 — always-on context carries dead policy.** Instruction files with `applyTo: "**"` plus `copilot-instructions.md` inject **3,148 lines** per turn in quantitativeFinance, 2,682 in wanderaide, 2,666 in guestHost, 2,361 in knb, 1,884 in smackerel and 1,092 in research-lab, before any work begins. `instructions/bubbles-propagation.instructions.md` (54 lines) is loaded on every turn in all six repos and governs a `propagation-policy.yaml` that exists in **zero** of them, for `bubbles.propagate`, which has **zero** recorded invocations. The cost is the `applyTo: "**"` header, not the capability behind it. See the SCOPE-5 pre-implementation finding. Of 41 shipped agents, 22 carry all recorded work and 14 have no recorded invocations. Six of those 14 (`status`, `recap`, `grill`, `handoff`, `create-skill`, `super`) are read-only surfaces that never write execution state, so zero is expected and is **not** evidence of disuse. The other seven (`train`, `propagate`, `releases`, `redteam`, `journey`, `clarify`, `setup`) would record and do not. `config/release-trains.yaml` exists in four of six repos while `bubbles.train` has never run, which is a declared-but-never-operated surface.
- **COST-3 — the control and evidence artifacts dominate output.** `state.json` was touched in 306 to 563 separate commits per repo per 60 days. `report.md` is the single largest artifact in every repo at 79,416 to 121,311 lines per repo per 60 days. Across the six repos, `specs/` plus governance accounts for **60% to 71%** of all changed lines and product code for 25% to 35%, and roughly **49%** of commits touch no product file at all.
- **REG-6 — the control plane's primary key is prose.** The `agent` field holds **163 distinct values across 15,685 recorded invocations, 60 of them appearing exactly once**, including values such as `bubbles.workflow gaps-to-doc (parent-expanded via stochastic-quality-sweep Round 14/20)`. Nothing downstream can aggregate the field reliably, which is why HO-1 stayed invisible for months.
- **REG-7 — gates carry no vintage, so new gates invalidate delivered work.** Unique gate ids grew from **71 on 2026-04-04 to 134 on 2026-08-05**. About **176 of 598** specs carry reopen, recertification or sweep language, concentrated in quantitativeFinance (55/106), smackerel (48/112) and knb (16/40). knb `state.json` records the mechanism verbatim: `Reopened 2026-06-20 from legacy done_with_concerns to blocked under Gate G092`. The same file records a spec held `blocked` while its real-world objective was met: `Adapter readiness complete and the WanderAide stack confirmed deployed healthy on <deploy-host> (live truth 2026-06-20)` (host name redacted to the placeholder convention). Re-litigating closed work when only the rules changed is the least defensible cost in the system.

### Counter-evidence that bounds this proposal

Two measured results argue against cutting broadly, and every scope below is shaped by them.

- **Convergence improved sharply.** Unbiased fixed-window completion rate by start cohort: 0% closed within 30 days for Dec-2025 through Feb-2026, then 2% (Mar), 7% (Apr), 20% (May), **45% (Jun)**. Ever-done rose from 17-32% (Dec/Jan) to 80-88% (Apr-Jun). Raw average days-open (173 falling to 7.6) is right-censored and must not be quoted. Whatever produced this gain must survive.
- **Test investment is real.** Tests are 39.5% (quantitativeFinance), 57.0% (smackerel), 56.0% (guestHost) and 64.5% (wanderaide) of changed product lines. Bug closure is 920 of 1,179 (78%). The tests, the execution-evidence rule, the structured refusals and the bug loop are the quality floor and are explicitly out of scope for reduction.

## Provenance

All figures were derived on 2026-08-05 from committed state, not from runtime telemetry, because no gate-hit or dispatch telemetry exists (that absence is COV-6). Inputs and methods:

- **Repos measured:** `quantitativeFinance`, `wanderaide`, `guestHost`, `smackerel`, `knb`, `research-lab`, plus the `bubbles` source repo for framework-surface counts.
- **Churn ratios and commit classification:** `git log --since=60.days --numstat` per repo, bucketing each changed path into `specs/`, governance (`.github/`, `.specify/`, `bubbles/`), docs, or product, then counting commits whose changed set contains no product path.
- **Agent invocations, statuses and transitions:** every `specs/*/state.json` and `specs/*/bugs/*/state.json` in the six repos (598 top-level spec state files; 15,685 recorded `agent` entries; 6,461 recorded `statusBefore`/`statusAfter` pairs).
- **Dispatch-failure counts:** literal occurrence counts of `parent-expanded`, `runtime lacks runSubagent`, `no nested runtime`, `nested-runtime capability missing`, `nested-runtime network timeout` and `subagent dispatch error` across the same state files.
- **Escaped-defect ratio:** for each `specs/*/bugs/*/state.json`, the parent spec's current `status`, classified as escaped when the parent reads `done`.
- **Gate counts and enforcement coverage:** unique `G[0-9]{3}` ids across `bubbles/`, `agents/`, `skills/` and `instructions/`, differenced against ids appearing anywhere under `bubbles/scripts/`. Gate growth sampled with `git log --until="N months ago"` against the `bubbles` tree.
- **Agent frontmatter:** the YAML block of `agents/bubbles.workflow.agent.md`, `agents/bubbles.goal.agent.md`, `agents/bubbles.iterate.agent.md`, `agents/bubbles.super.agent.md`, `agents/bubbles.sprint.agent.md` and eight specialist agent files.
- **Always-on context:** line counts of every `.github/instructions/*.instructions.md` carrying `applyTo: "**"` plus `.github/copilot-instructions.md`, per repo.
- **Cohort completion rates:** first and last commit date per `specs/<dir>` from `git log --name-only`, joined to the current `status`, bucketed by start month. Recent cohorts are right-censored and are reported only through the unbiased fixed-30-day-window measure.
- **e2e outage:** `guestHost` commit `188d11ce` (2026-07-21) and the remediating commit `972db8b6` (2026-08-05), with spec commits in the intervening window counted from `git log --since='2026-07-21' -- specs/`.

Three limits of this evidence base are stated here so later readers do not overread it.

- VS Code chat sessions were wiped from disk. No turn-level or token-level data exists for these repos.
- "Named in a script" is a proxy for gate enforcement and may overcount, because a script can name a gate id without acting on it.
- The HO-1 second-hop diagnosis is inferred from failure strings plus correct frontmatter, not from a traced failing call. SCOPE-1 must confirm it before the routing contract is rewritten.

## Proposal

### SCOPE-1 — Single-orchestrator routing (HO-1)

- Confirm the second-hop diagnosis first. Instrument one specialist-to-specialist route end to end (the `bugfix-fastlane` `bug` to `devops` hop is the highest-frequency observed instance) and capture whether the dispatch returns empty. Do not rewrite the contract on inference.
- On confirmation, amend `agents/bubbles_shared/workflow-delegation-core.md` with a single rule: **a specialist may never dispatch a specialist**. Every `route_required` returns to the one top-level runner, which dispatches the next specialist at depth 1.
- Update the result-envelope contract so `route_required` is explicitly an upward return to the orchestrator, never a lateral call, and reflect the same rule in the `bubbles-result-envelope` and `bubbles-fix-cycle-protocol` skills.
- Collapse the router chain. `bubbles.sprint` (0 recorded invocations) to `bubbles.goal` (135) to `bubbles.workflow` (2,280) to specialists is three levels on a two-level runtime. Recommendation: make the outer routers handoff-only surfaces rather than dispatching agents, which preserves the operator entry point without adding a dispatch level.

### SCOPE-2 — Fail loud on a dispatch that did not happen (HO-2)

- Treat an empty or absent subagent return as a hard failure of the run rather than a condition to narrate. The agent must not record a specialist invocation it did not make.
- Stop accepting `parent-expanded` as equivalent to a dispatch in `bubbles/scripts/state-transition-guard.sh`. Recommendation: keep the token legal only when accompanied by a machine-checkable reason field drawn from a closed enum, and count it separately from real dispatches so the rate stays visible.
- Emit a counter for expanded-instead-of-dispatched runs so SCOPE-1's effect is measurable rather than asserted.

### SCOPE-3 — Assert that tests actually ran (EV-6)

- Require every test-evidence block to carry a **collected-test count**, and fail the evidence when that count is zero. A suite that collects nothing must never satisfy a test DoD item.
- Register this as a new gate in `bubbles/registry/gates.yaml` with a real enforcement script, because a prose-only gate would reproduce COV-6.
- Extend `bubbles-evidence-capture` and `bubbles-test-integrity` with the collected-count requirement and the guestHost outage as the worked example.
- This is the single highest-value addition in the proposal: it closes the exact class that produced 15 days of evidence attesting to nothing.

### SCOPE-4 — Instrument gates before retiring any (COV-6)

- Add append-only gate-hit logging: gate id, spec, verdict, timestamp, one line per evaluation. No retirement decision is taken in this scope.
- After 60 days of data, retire every gate that never rejected anything, and resolve the 26 prose-only gates by either wiring each to an enforcement script or deleting it. Recommendation: default to deletion, because a gate that has never rejected anything in 60 days across six active repos is indistinguishable from documentation.
- Sequence matters. Cutting gates before the telemetry exists would repeat the mistake this proposal is trying to correct.

### SCOPE-6 — Stop write amplification (COST-3)

- Skip the state write when nothing moved. If `statusBefore` equals `statusAfter` and no scope changed state, the run must not commit a state mutation.
- Replace full evidence transcripts with **command, exit code, first and last 20 lines, and a hash of the full output**. This strengthens anti-fabrication rather than weakening it, because a reviewer can re-run and compare the hash, whereas a pasted transcript proves only that text was pasted. It also removes the recurring class where captured evidence carries paths that trip secret and PII scanners.
- Keep the requirement that evidence originates from real execution in the current session. That rule is not the cost. The transcript volume is.

### SCOPE-7 — Constrain the agent field to an enum (REG-6)

- Restrict `executionHistory[].agent` to a registered agent id validated against `bubbles/agent-capabilities.yaml`.
- Move the qualifiers that currently ride inside the value (expansion reason, mode, sweep round) into named sibling fields so they remain available and become queryable.
- Add the enum check to artifact lint. This scope is what makes SCOPE-2's counter and SCOPE-4's telemetry aggregable at all.

### SCOPE-8 — Give gates a vintage (REG-7)

- Record the introducing framework version on every gate in `bubbles/registry/gates.yaml`.
- Apply a gate only to specs opened at or after that version. Grandfather specs that were certified under an earlier catalogue.
- Provide one deliberate override for a genuine correctness defect, requiring a named owner decision recorded on the spec. The override must be the exception, not the sweep.
- Retire the pattern where a catalogue-wide sweep reopens previously certified specs. About 176 specs currently carry that history.

## Migration / rollout

Ordering is chosen so that no scope cuts a control before the replacement measurement exists.

1. **SCOPE-4** logging half first. It is purely additive and starts the 60-day clock that every later retirement decision depends on.
3. **SCOPE-7**, then **SCOPE-2**, then **SCOPE-6**. The enum must land before the dispatch counter, or the counter cannot be aggregated. The write-skip rule is safest once the enum has settled the schema.
4. **SCOPE-3** as soon as the enforcement script is written. It is additive and independently valuable.
5. **SCOPE-1** after its confirmation step. This is the structural change and carries the most risk.
6. **SCOPE-8** at any point after SCOPE-4 begins logging.
7. **SCOPE-4** retirement half only after 60 days of telemetry.

Every scope is additive or deletion-of-unreferenced-surface except SCOPE-1, SCOPE-2 and SCOPE-6, which change existing contracts and must ship behind the acceptance criteria below. Downstream repos pick the changes up through the normal installer refresh. No downstream spec requires migration, because SCOPE-8 grandfathers existing certifications by construction.

## Risks & mitigations

- **R1 — Cutting gates reduces quality.** Mitigation: no gate is retired in this proposal. SCOPE-4 only measures, and retirement is deferred behind 60 days of evidence. The measured 69% escape rate already establishes that the current gate mass is not what holds quality up, so the exposure is smaller than the count suggests.
- **R2 — SCOPE-1 rewrites routing on an inferred diagnosis.** Mitigation: SCOPE-1 opens with a confirmation step against a real dispatch and does not proceed on the inference alone.
- **R3 — Hashed evidence weakens anti-fabrication.** Mitigation: the hash is verifiable by re-running, which a transcript is not. The execution-in-session rule is unchanged, and the retained head and tail lines preserve human readability at the point of review.
- **R4 — Removing always-on policy loses a rule that mattered.** Mitigation: only policy governing surfaces that provably do not exist is deleted outright. The rest moves to on-demand skills and remains loadable, so recovery is a skill reference rather than a rewrite.
- **R5 — Retiring an agent that was about to be adopted.** Mitigation: mark experimental rather than delete, and retain the six read-only surfaces whose zero count is expected rather than diagnostic.
- **R6 — Grandfathering hides a real defect in an old spec.** Mitigation: SCOPE-8 keeps a deliberate, owner-recorded override for genuine correctness defects. What it removes is the catalogue-wide automatic sweep, not the ability to reopen a spec on cause.
- **R7 — Convergence speed regresses while cutting.** Mitigation: the 30-day completion rate is a named acceptance criterion below and acts as the guardrail. A drop means something load-bearing was cut and must be restored.

## Acceptance criteria (when implemented)

Measured against the same method recorded under Provenance, 60 days after the last scope lands.

- **SCOPE-1 / SCOPE-2 (HO-1, HO-2):** `parent-expanded` occurrences in newly written downstream state fall to **zero**, and the expanded-instead-of-dispatched counter reads zero for runs after the change. Any non-zero value is attributable to a named enum reason rather than to silence.
- **SCOPE-3 (EV-6):** a test-evidence block reporting zero collected tests is rejected, proven by an adversarial selftest that replays the guestHost `188d11ce` condition and asserts refusal. Bugs filed against already-`done` specs fall below **40%** of new bug folders, from 69%.
- **SCOPE-4 (COV-6):** every gate evaluation is logged, and the count of gates with zero recorded rejections over 60 days is published. The 26 prose-only ids are each either wired to a script or removed, leaving no declared gate that no script names.
- **SCOPE-6 (COST-3):** state-file commits per repo per 60 days fall by at least half from the 306-to-563 baseline, and product code rises above **45%** of changed lines, from 28%.
- **SCOPE-7 (REG-6):** distinct `agent` values equal the registered agent count, with zero singletons, from 163 values with 60 singletons.
- **SCOPE-8 (REG-7):** no spec is reopened by a gate introduced after its certification, and newly written reopen or sweep language appears in zero specs.
- **Guardrail, all scopes:** the fixed-30-day-window completion rate holds at or above **45%**. A decline invalidates the cut that preceded it and triggers restoration.

## Files to touch (on approval)

`agents/bubbles_shared/workflow-delegation-core.md` (single-orchestrator rule; owner `bubbles.bootstrap`), `agents/bubbles.workflow.agent.md` and `agents/bubbles.goal.agent.md` and `agents/bubbles.sprint.agent.md` (router collapse; owner `bubbles.bootstrap`), `skills/bubbles-result-envelope/SKILL.md` and `skills/bubbles-fix-cycle-protocol/SKILL.md` (upward-return routing; owner `bubbles.create-skill`), `bubbles/scripts/state-transition-guard.sh` (stop accepting `parent-expanded` as a dispatch, add the counter; owner `bubbles.validate`), `bubbles/registry/gates.yaml` (collected-test gate registration, gate vintage field; owner `bubbles.validate`), a new enforcement script plus selftest under `bubbles/scripts/` for the collected-test assertion (owner `bubbles.validate`), a new gate-hit logging path under `bubbles/scripts/` (owner `bubbles.validate`), `skills/bubbles-evidence-capture/SKILL.md` and `skills/bubbles-test-integrity/SKILL.md` (collected-count requirement, hashed-evidence form; owner `bubbles.create-skill`), `instructions/bubbles-propagation.instructions.md` (deletion; owner `bubbles.bootstrap`), `bubbles/agent-capabilities.yaml` (agent retirement and enum source; owner `bubbles.bootstrap`), `agents/bubbles_shared/feature-templates.md` (state schema: agent enum, sibling qualifier fields, evidence form; owner `bubbles.plan`), `bubbles/scripts/artifact-lint.sh` (agent enum check, evidence-form check; owner `bubbles.validate`), `templates/` installer manifest (always-on instruction set reduction; owner `bubbles.bootstrap`).

## Out of scope (routed elsewhere)

- **knb deploy orchestrator.** The audit measured 27 deploy attempts against 1 success, with 7 of the failures carrying `E019-INTERNAL`, which are orchestrator defects rather than safety refusals. Real delivery to the home lab reached the deploy host through the local build path instead. That surface is owned by the knb repo under its own spec 019 and does not belong to a framework IMP. Route to knb.
- **Host contention.** Sixty containers across four products were running concurrently with a 26-minute pre-push, two unit-test runs and a deploy on one Docker daemon. This is an operational scheduling matter for the workspace, not a framework contract.
