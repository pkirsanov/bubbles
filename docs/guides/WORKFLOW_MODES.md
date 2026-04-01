# <img src="../../icons/bubbles-glasses.svg" width="28"> Bubbles Workflow Modes

> *"Julian's got a plan. A good plan this time."*

Workflow modes define **which phases run** and **in what order** for a given piece of work.

## Workflow Is The Universal Entry Point

**`/bubbles.workflow` is the recommended entry point for all Bubbles work.** You don't need to know the mode, the spec target, or the exact parameters — just describe what you want:

```
/bubbles.workflow  improve the booking feature to be competitive
/bubbles.workflow  continue
/bubbles.workflow  fix the calendar bug
/bubbles.workflow  spend 2 hours on whatever needs attention
/bubbles.workflow  doctor
```

**How it works:**
- **Structured input** (has `mode:` + spec target) → executes phases directly (existing behavior)
- **Plain English** → delegates to `super` for intent resolution → gets mode + spec + tags → executes
- **"Continue" / "next" / empty** → delegates to `iterate` for work-picking → gets next priority item → executes
- **Framework ops** ("doctor", "hooks", "upgrade") → delegates to `super` for framework operations

Direct agent calls (`/bubbles.super`, `/bubbles.iterate`, `/bubbles.implement`, etc.) still work for users who know exactly what they want.

## Review Is Not A Workflow Mode

`bubbles.code-review` and `bubbles.system-review` are intentionally agents, not workflow modes.

Use them when you want diagnosis, prioritization, or assessment without entering the gated delivery lifecycle.

Use workflow modes after review when you already know you want follow-through work such as planning, implementation, testing, validation, audit, or docs synchronization.

Current assessment: review still does not need its own separate workflow family, but existing-feature work now splits more clearly: use `improve-existing` for evolutionary improvements, `reconcile-to-doc` for stale state cleanup, and `product-to-delivery` (with existing impl) when requirements, UX, design, and scopes all need reconciliation before a major rewrite.

Optional execution tags apply across modes when you need more control without changing the default autonomous behavior:
- `grillMode: on-demand|required-on-ambiguity|required-for-lockdown` inserts or requires `bubbles.grill` before analysis, selection, bootstrap, or locked-behavior invalidation so weak assumptions get challenged early.
- `tdd: true` forces a red-green-first implementation loop for changed behavior after the normal planning and scenario gates are already satisfied.
- `backlogExport: tasks|issues` forwards backlog-ready task or issue output preferences to `bubbles.plan`.
- `socratic: true` with `socraticQuestions: <1-5>` enables a bounded clarification loop before discovery/bootstrap work.
- `gitIsolation: true` opts into isolated branch/worktree setup when repo policy allows it.
- `autoCommit: scope|dod` opts into atomic commits after fully validated milestones (`off` is default).
- `maxScopeMinutes` and `maxDodMinutes` tighten scope sizing (recommended: scope 60-120, DoD 15-45).
- `microFixes: false` is the opt-out switch if you explicitly do not want narrow repair loops.
- `specReview: once-before-implement` runs a one-shot `bubbles.spec-review` pass before legacy improvement or implementation-capable work begins. If the mode includes `analyze`, that review runs after analysis so it sees the refreshed intent. It does not repeat on retries or later rounds.
- `crossModelReview: codex|terminal` requests an independent cross-model review during code-review or audit phases (requires model registry configuration in `.specify/memory/bubbles.config.json`).
- `parallelScopes: dag|dag-dry` executes DAG-independent scopes in parallel via git worktrees. Off by default. `dag-dry` shows the plan without executing.
- `maxParallelScopes: 2-4` controls maximum concurrent scope executions when `parallelScopes: dag`.

### Smart Phase Routing

Workflow modes now support **phase relevance evaluation** — before invoking each phase, `bubbles.workflow` checks whether the phase is relevant to the current scope's changed surface. Irrelevant phases are skipped with a recorded justification.

**Safety guarantees:** Skipped phases are never silent. They're recorded in `executionHistory`. If artifacts change after a skip (e.g., a prior phase adds security-relevant code), the skip decision is re-evaluated and the phase is included if now relevant. Core phases (`implement`, `test`, `validate`, `docs`, `audit`, `finalize`) never skip.

### Decision Policy (Orchestrated Workflows)

When `bubbles.plan` or `bubbles.design` are invoked by the orchestrator (not directly by the user), decisions are classified as **mechanical** or **taste**:

- **Mechanical** (auto-resolved): match existing patterns, prefer completeness, prefer reversible, respect spec constraints
- **Taste** (surfaced to user): ambiguous choices below 60% confidence, security-affecting decisions, creative direction

Taste decisions are batched at phase boundaries (max 5 per phase). When `grillMode` is active, taste decisions are pressure-tested by `bubbles.grill` first. When `socratic: true`, taste decisions become the Socratic questions (within the `socraticQuestions` limit).

Baseline workflow law already requires spec/design/plan coherence, explicit Gherkin scenarios, scenario-specific test planning, and scenario-driven E2E/integration proof before implementation is allowed to proceed. The **Outcome Contract** (G070) additionally requires every spec to declare Intent, Success Signal, Hard Constraints, and Failure Condition before bootstrap completes — and validation verifies the outcome was actually achieved, not just that the process was followed. Those are not optional tags.

### Planning Alignment Checkpoints (v3.4)

Two short, human-reviewable alignment artifacts are now mandatory:

- **Design Brief** — A ~30-50 line section at the top of `design.md` showing current state, target state, patterns to follow, patterns to avoid, resolved decisions, and open questions. Review this for steering (5 min) instead of reading the full design doc.
- **Execution Outline** — A ~30-50 line preamble at the top of `scopes.md` showing phase order, new types/signatures being introduced, and validation checkpoints. Like C header files for the plan.

### Brownfield Research (Phase 0.55)

For brownfield modes (`improve-existing`, `redesign-existing`, `delivery-lockdown`, `bugfix-fastlane`, `reconcile-to-doc`), the workflow now runs an **Objective Research Pass** before design:
1. Questions are generated while knowing the solution intent
2. Codebase research is done in a **fresh, solution-blind context** — it never sees the spec or ticket
3. Results are recorded as a `## Current Truth` section in design.md

This prevents confirmation bias where the model finds patterns that support its intended design instead of reporting what actually exists.

### Horizontal Plan Detection

`bubbles.plan` Phase 4 now mechanically detects horizontal scope sequences (3+ consecutive single-layer scopes like all-DB → all-service → all-API → all-UI) and restructures them into vertical slices. Horizontal plans are the #1 quality failure in AI-generated scope sequences.

### Slop Tax Tracking

`bubbles.retro` now tracks rework metrics: scope reopens, phase retries, post-validate reversions, design reversals, fix-on-fix chains, and a **net forward progress** score. Target: < 15% slop tax.

---

## Choosing a Mode

```
/bubbles.workflow  <mode-name> for <feature/bug>
```

If you don't specify a mode, `full-delivery` is the default.

**Natural language works too** — just describe what you want:

```
/bubbles.workflow  improve the booking feature to be competitive
/bubbles.workflow  fix the calendar bug
/bubbles.workflow  spend 2 hours working on whatever needs attention
/bubbles.workflow  harden specs 11 through 37
```

The workflow agent infers the correct mode and parameters from your description. See the **Natural Language Mode Resolution** section in the workflow agent for the complete intent-to-mode mapping.

**Not sure which mode?** Ask the super: `/bubbles.super  which mode should I use for <your situation>`

---

## Full Delivery Modes

These run the complete pipeline. Use for new features.

### <img src="../../icons/julian-glass.svg" width="20"> full-delivery

**The standard.** All phases, strict gates, complete coverage.

```
select → bootstrap → implement → test → regression → simplify → stabilize → devops → security → docs → validate → audit → chaos → finalize
```

**Use when:** New features, standard development work.

```
/bubbles.workflow  full-delivery for 042-catalog-assistant
```

### <img src="../../icons/julian-glass.svg" width="20"> full-delivery-strict

Same as `full-delivery` but with stricter evidence and enforcement expectations.

**Use when:** Critical features and production-facing changes.

### <img src="../../icons/lahey-badge.svg" width="20"> delivery-lockdown

Maximum-assurance delivery. The workflow loops until `bubbles.validate` can certify `done` or records a real blocker.

```
[repeat until certified done: optional analyze/ux/design/plan prelude → bootstrap → implement → test → regression → simplify → gaps → harden → stabilize → devops → security → validate → audit → chaos → docs] → finalize
```

**Use when:** Release-candidate work and difficult legacy hardening where the system must keep going until it is legitimately green.

### <img src="../../icons/bubbles-glasses.svg" width="20"> value-first-e2e-batch

Prioritized delivery. Scores work items by business value and implements in priority order.

```
discover → select → bootstrap → implement → test → regression → simplify → stabilize → devops → security → docs → validate → audit → chaos → finalize
```

**Use when:** Multiple features compete for time and you want the highest-value work first.

### <img src="../../icons/bubbles-glasses.svg" width="20"> product-to-delivery

Full product discovery through delivery.

```
analyze → select → bootstrap → implement → test → regression → simplify → stabilize → devops → security → docs → validate → audit → chaos → finalize
```

**Use when:** Starting from a product idea rather than an already-shaped technical spec.

---

## Brainstorm & Exploration Modes

Explore and refine ideas without writing code.

### <img src="../../icons/ray-lawnchair.svg" width="20"> brainstorm

Like YC office hours for your feature. Explore the idea, analyze competitors, harden scenarios — zero code.

```
analyze → bootstrap → harden → finalize
```

**Use when:** "I have an idea but want to think it through before building." Outputs spec.md + design.md + scopes.md with `statusCeiling: specs_hardened`. Socratic mode is on by default (5 questions).

```
/bubbles.workflow  brainstorm for "property search engine with competitive edge"
```

---

## Fast-Track Modes

Skip phases you do not need without dropping the governance chain.

### <img src="../../icons/ricky-dynamite.svg" width="20"> bugfix-fastlane

Fast bug resolution with reproduce-before and verify-after evidence.

```
select → implement → test → regression → simplify → stabilize → devops → security → validate → audit → finalize
```

**Use when:** Bug fixes.

### <img src="../../icons/cory-trevor-smokes.svg" width="20"> feature-bootstrap

Bootstrap missing planning artifacts, then continue through implementation and the full verification chain for that feature.

```
select → bootstrap → implement → test → regression → simplify → stabilize → devops → security → docs → validate → audit → finalize
```

**Use when:** A feature is missing spec/design/scope readiness and you want the workflow to repair that planning debt before continuing delivery.

### <img src="../../icons/julian-glass.svg" width="20"> iterate

Pick the highest-priority next slice inside an existing spec and run one iteration through the right specialists.

```
[priority pick] → [auto-selected mode] → specialist phases → finalize
```

**Use when:** Picking up where you left off.

If the next executable action is ambiguous, `bubbles.iterate` may run `bubbles.code-review` or `bubbles.system-review` as a narrow diagnostic precursor, then continue into planning or execution.

---

## Quality & Hardening Modes

Focus on quality, hardening, and operational readiness.

### <img src="../../icons/conky-puppet.svg" width="20"> harden-gaps-to-doc

```
select → bootstrap → validate → harden → gaps → implement → test → regression → simplify → stabilize → devops → security → chaos → validate → audit → docs → finalize
```

**Use when:** You want a thorough post-implementation quality sweep.

### <img src="../../icons/ricky-dynamite.svg" width="20"> chaos-hardening

```
select → bootstrap → chaos → implement → test → regression → simplify → stabilize → devops → security → validate → audit → finalize
```

**Use when:** Resilience testing and fixing what breaks.

### <img src="../../icons/conky-puppet.svg" width="20"> spec-scope-hardening

```
select → bootstrap → harden → docs → validate → audit → finalize
```

**Use when:** Specs are vague and scope quality needs tightening.

### <img src="../../icons/ricky-dynamite.svg" width="20"> stochastic-quality-sweep

```
[N randomized rounds: random spec + random trigger + trigger-specific fix cycle] → docs → finalize
```

**Use when:** Periodic adversarial maintenance across the codebase.

### <img src="../../icons/lahey-bottle.svg" width="20"> retro-quality-sweep

```
select → retro → simplify → harden → gaps → implement → test → regression → stabilize → devops → security → validate → audit → docs → finalize
```

**Use when:** You want retro to pick the hotspots, then run a deterministic quality sweep on those areas instead of random trigger rounds.

---

## Focused Modes

Do one thing well.

### <img src="../../icons/trinity-notebook.svg" width="20"> test-to-doc

```
test → validate → docs
```

**Use when:** Tests need running and docs need updating.

### <img src="../../icons/jroc-mic.svg" width="20"> docs-only

```
docs
```

**Use when:** Pure documentation work.

### <img src="../../icons/randy-cheeseburger.svg" width="20"> validate-only

```
validate
```

**Use when:** Quick gate checks without a full workflow rerun.

### <img src="../../icons/lahey-badge.svg" width="20"> audit-only

```
audit
```

**Use when:** Compliance-only review on existing work.

### <img src="../../icons/bill-wrench.svg" width="20"> stabilize-to-doc

Diagnose operational reliability issues, route delivery remediation through DevOps when needed, then run the rest of the quality chain.

```
select → bootstrap → validate → stabilize → devops → implement → test → regression → simplify → security → chaos → validate → audit → docs → finalize
```

**Use when:** Infrastructure and operational hardening starts with diagnosis.

### <img src="../../icons/tommy-rack.svg" width="20"> devops-to-doc

Focused operational delivery for an existing feature or bug.

```
select → bootstrap → devops → test → stabilize → security → validate → audit → docs → finalize
```

**Use when:** CI/CD, build, deployment, monitoring, observability, or release automation needs direct execution work.

### <img src="../../icons/cyrus-sunglasses.svg" width="20"> improve-existing

```
analyze → select → validate → harden → gaps → implement → test → regression → simplify → stabilize → devops → security → validate → audit → chaos → docs → finalize
```

**Use when:** An existing feature needs a full improvement pass.

### <img src="../../icons/lucy-mirror.svg" width="20"> redesign-existing

```
analyze → select → bootstrap → implement → test → regression → simplify → stabilize → devops → security → docs → validate → audit → chaos → finalize
```

**Use when:** An existing feature needs major artifact reconciliation and redesign before implementation can safely proceed.

### <img src="../../icons/donny-ducttape.svg" width="20"> simplify-to-doc

```
select → simplify → test → validate → audit → docs → finalize
```

**Use when:** The main goal is to reduce complexity without inventing a new product direction.

### <img src="../../icons/gary-laser-eyes.svg" width="20"> spec-review-to-doc

```
select → spec-review → docs → finalize
```

**Use when:** You need a trust and freshness audit before maintenance work relies on existing artifacts.

### <img src="../../icons/conky-puppet.svg" width="20"> harden-to-doc

```
bootstrap → validate → harden → implement → test → regression → simplify → stabilize → devops → security → chaos → validate → audit → docs
```

**Use when:** Code has weak spots that need tightening before shipping.

### <img src="../../icons/phil-collins-baam.svg" width="20"> gaps-to-doc

```
bootstrap → validate → gaps → implement → test → regression → simplify → stabilize → devops → security → chaos → validate → audit → docs
```

**Use when:** Implementation may be incomplete or missing key edge cases.

### <img src="../../icons/ricky-dynamite.svg" width="20"> chaos-to-doc

```
chaos → validate → audit → docs
```

**Use when:** You want chaos findings documented without an implementation pass.

### <img src="../../icons/randy-cheeseburger.svg" width="20"> reconcile-to-doc

```
bootstrap → validate → implement → test → regression → simplify → stabilize → devops → security → validate → audit → chaos → docs
```

**Use when:** Implementation reality and artifact state need to be reconciled.

### <img src="../../icons/randy-cheeseburger.svg" width="20"> validate-to-doc

```
validate → audit → docs
```

**Use when:** Quick validation plus documentation sync.

---

## Resume & Discovery

### <img src="../../icons/camera-crew.svg" width="20"> resume-only

Resume from where the last session stopped.

```
(reads state.json and continues from last known position)
```

**Use when:** Picking up interrupted work.

```
/bubbles.workflow  resume
```

### <img src="../../icons/ray-lawnchair.svg" width="20"> product-discovery

Business analysis and requirements only. No design or implementation.

```
analyze → ux
```

**Use when:** Early product exploration.

---

## Mode Quick Reference

| Mode | Phases | Best For |
|------|--------|----------|
| `full-delivery` | All phases | Standard features |
| `full-delivery` (with strict tag) | All phases + strict chaos | Critical features |
| `delivery-lockdown` | Repeated full improvement/certification rounds | Release-candidate or zero-loose-ends delivery |
| `value-first-e2e-batch` | Prioritized + batched | Large backlogs |
| `product-to-delivery` | Discovery → delivery | Product ideas |
| `spec-scope-hardening` (with analyze) | Analysis only | Early exploration |
| `bugfix-fastlane` | Fix → test → regression → hardening → validate → audit | Bug fixes that still need the full quality chain |
| `full-delivery` (with bootstrap) | Bootstrap missing artifacts, then deliver | Missing planning artifacts plus implementation |
| `iterate` | Implement → test loop | Continuing work |
| `harden-to-doc` | Harden → fix → test → docs | Code quality |
| `gaps-to-doc` | Gaps → fix → test → docs | Gap closure |
| `harden-gaps-to-doc` | Quality sweep | Post-implementation |
| `stabilize-to-doc` | Stability/devops → test → docs | Infrastructure |
| `simplify-to-doc` | Simplify → test → docs | Code simplification |
| `spec-review-to-doc` | Spec audit → docs | Spec freshness check |
| `chaos-hardening` | Chaos → fix | Resilience |
| `chaos-to-doc` | Chaos → validate → docs | Chaos auditing |
| `reconcile-to-doc` | Reconcile → test → docs | Stale state cleanup |
| `product-to-delivery` (with existing impl) | Reconcile → redesign → deliver | Major existing-feature rewrite |
| `improve-existing` | Analyze → harden → gaps → fix | Code improvement |
| `retro-quality-sweep` | Retro-targeted quality sweep | Hotspot-guided maintenance |
| `retro-to-simplify` | Retro hotspots → simplify worst | Data-driven simplification |
| `retro-to-harden` | Retro bug magnets → harden targets | Data-driven hardening |
| `retro-to-review` | Retro risks → code review | Data-driven review |
| `stochastic-quality-sweep` | Random quality | Maintenance |
| `test-to-doc` | Test → docs | Test/doc focus |
| `validate-to-doc` | Validate → audit → docs | Validation + docs |
| `spec-scope-hardening` | Harden specs only | Spec quality |
| `docs-only` | Docs only | Pure docs |
| `validate-only` | Validate only | Quick gate check |
| `audit-only` | Audit only | Compliance |
| `spec-scope-hardening` (with analyze + socratic) | Explore → bootstrap → harden → finalize | Idea exploration, no code |
| `devops-to-doc` | DevOps → test → stabilize → security → validate → audit → docs → finalize | Operational delivery |
| `resume-only` | Resume state | Picking up work |

---

<p align="center">
  <em>"Way she goes, boys. Way she goes."</em>
</p>
