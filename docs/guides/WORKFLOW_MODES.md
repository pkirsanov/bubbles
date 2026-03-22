# <img src="../../icons/bubbles-glasses.svg" width="28"> Bubbles Workflow Modes

> *"Julian's got a plan. A good plan this time."*

Workflow modes define **which phases run** and **in what order** for a given piece of work. Choose the mode that matches what you're doing.

## Review Is Not A Workflow Mode

`bubbles.code-review` and `bubbles.system-review` are intentionally agents, not workflow modes.

Use them when you want diagnosis, prioritization, or assessment without entering the gated delivery lifecycle.

Use workflow modes after review when you already know you want follow-through work such as planning, implementation, testing, validation, audit, or docs synchronization.

Current assessment: **no dedicated new review workflow modes are needed yet**. Existing modes such as `improve-existing`, `stabilize-to-doc`, `harden-gaps-to-doc`, and `product-to-delivery` already cover the execution side once review findings are clear.

Optional execution tags apply across modes when you need more control without changing the default autonomous behavior:
- `socratic: true` with `socraticQuestions: <1-5>` enables a bounded clarification loop before discovery/bootstrap work.
- `gitIsolation: true` opts into isolated branch/worktree setup when repo policy allows it.
- `autoCommit: scope|dod` opts into atomic commits after fully validated milestones (`off` is default).
- `maxScopeMinutes` and `maxDodMinutes` tighten scope sizing (recommended: scope 60-120, DoD 15-45).
- `microFixes: false` is the opt-out switch if you explicitly do not want narrow repair loops.

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
select → bootstrap → implement → test → security → docs → validate → audit → chaos → finalize
```

**Use when:** New features, standard development work.

```
/bubbles.workflow  full-delivery for 042-catalog-assistant
```

### <img src="../../icons/julian-glass.svg" width="20"> full-delivery-strict

Same as `full-delivery` but with **stricter gates** — chaos testing included, tighter evidence requirements.

**Use when:** Critical features, production-facing changes.

### <img src="../../icons/bubbles-glasses.svg" width="20"> value-first-e2e-batch

Prioritized delivery. Scores work items by business value, implements in priority order, runs E2E tests in batches.

```
discover → select → bootstrap → implement → test → security → docs → validate → audit → chaos → finalize
```

**Use when:** Multiple features competing for time. Large backlogs.

```
/bubbles.workflow  value-first-e2e-batch for all pending specs
```

### <img src="../../icons/bubbles-glasses.svg" width="20"> product-to-delivery

Full product discovery → delivery pipeline.

```
analyze → select → bootstrap → implement → test → security → docs → validate → audit → chaos → finalize
```

**Use when:** Starting from a product idea, not a technical spec.

---

## Fast-Track Modes

Skip phases you don't need. Move fast without cutting safety.

### <img src="../../icons/ricky-dynamite.svg" width="20"> bugfix-fastlane

Fast bug resolution with proper evidence.

```
select → implement → test → validate → audit → finalize
```

**Use when:** Bug fixes. Get in, fix it, prove it, get out.

```
/bubbles.workflow  bugfix-fastlane for BUG-015
```

### <img src="../../icons/cory-trevor-smokes.svg" width="20"> feature-bootstrap

Just the planning phases. Sets up artifacts without implementing.

```
select → bootstrap → finalize
```

**Use when:** You want to plan but not implement yet.

**Ownership behavior:** bootstrap and downstream specialists must respect artifact ownership. Missing business requirements route to `bubbles.analyst`, missing design routes to `bubbles.design`, and missing planning artifacts route to `bubbles.plan`.

### <img src="../../icons/julian-glass.svg" width="20"> iterate

Continue scope-by-scope implementation within an existing spec.

```
[priority pick] → [auto-selected mode] → specialist phases → finalize
```

**Use when:** Picking up where you left off.

If the next executable action is ambiguous, `bubbles.iterate` may run `bubbles.code-review` or `bubbles.system-review` as a narrow diagnostic precursor, then continue into planning or execution. Review is not part of the normal iterate phase chain.

```
/bubbles.workflow  iterate for 042-catalog-assistant
```

---

## Quality & Hardening Modes

Focus on quality without new implementation.

### <img src="../../icons/conky-puppet.svg" width="20"> harden-gaps-to-doc

Hardening → gap analysis → test → documentation. The quality sandwich.

```
select → bootstrap → validate → harden → gaps → implement → test → security → chaos → validate → audit → docs → finalize
```

**Use when:** Post-implementation quality sweep.

### <img src="../../icons/ricky-dynamite.svg" width="20"> chaos-hardening

Chaos testing followed by hardening fixes.

```
select → bootstrap → chaos → implement → test → validate → audit → finalize
```

**Use when:** Resilience testing and fixing.

### <img src="../../icons/conky-puppet.svg" width="20"> spec-scope-hardening

Tighten specs and scope definitions. No code changes.

```
select → bootstrap → harden → docs → validate → audit → finalize
```

**Use when:** Specs are vague, scopes need tightening.

### <img src="../../icons/ricky-dynamite.svg" width="20"> stochastic-quality-sweep

Random quality checks across the codebase. Like bottle kids — you never know where they'll hit.

```
[N randomized rounds: random spec + random trigger + trigger-specific fix cycle] → docs → finalize
```

**Use when:** Periodic maintenance. Trust but verify.

---

## Focused Modes

Do one thing well.

### <img src="../../icons/trinity-notebook.svg" width="20"> test-to-doc

Run tests, fix failures, update docs.

```
test → validate → docs
```

**Use when:** Tests need running and docs need updating.

### <img src="../../icons/jroc-mic.svg" width="20"> docs-only

Documentation updates only. No code changes.

```
docs
```

**Use when:** Pure documentation work.

### <img src="../../icons/randy-cheeseburger.svg" width="20"> validate-only

Run validation gates only.

```
validate
```

**Use when:** Quick gate check without full audit.

### <img src="../../icons/lahey-badge.svg" width="20"> audit-only

Run the audit phase only.

```
audit
```

**Use when:** Compliance check on existing work.

### <img src="../../icons/bill-wrench.svg" width="20"> stabilize-to-doc

Stability fixes → test → docs.

```
stabilize → test → validate → docs
```

**Use when:** Infrastructure/stability work.

### <img src="../../icons/cyrus-sunglasses.svg" width="20"> improve-existing

Improve existing code quality.

```
harden → simplify → test → validate → docs
```

**Use when:** Refactoring, simplification, code quality work.

### <img src="../../icons/conky-puppet.svg" width="20"> harden-to-doc

Harden specs, then fix and test the issues found.

```
bootstrap → validate → harden → implement → test → chaos → validate → audit → docs
```

**Use when:** Code has weak spots that need tightening before shipping.

### <img src="../../icons/phil-collins-baam.svg" width="20"> gaps-to-doc

Find implementation gaps, then fix and test.

```
bootstrap → validate → gaps → implement → test → chaos → validate → audit → docs
```

**Use when:** Implementation may be incomplete or missing edge cases.

### <img src="../../icons/ricky-dynamite.svg" width="20"> chaos-to-doc

Run chaos probes, then document findings.

```
chaos → validate → audit → docs
```

**Use when:** Chaos testing without implementation fixes.

### <img src="../../icons/randy-cheeseburger.svg" width="20"> reconcile-to-doc

Reconcile stale artifact state with implementation reality.

```
bootstrap → validate → implement → test → validate → audit → chaos → docs
```

**Use when:** Specs claim "done" but implementation has drifted or is incomplete.

### <img src="../../icons/randy-cheeseburger.svg" width="20"> validate-to-doc

Validate + audit + docs without implementation.

```
validate → audit → docs
```

**Use when:** Quick check that everything passes gates, then update docs.

### <img src="../../icons/conky-puppet.svg" width="20"> spec-scope-hardening

Tighten spec and scope artifacts only — no code changes.

```
select → bootstrap → harden → docs → validate → audit
```

**Use when:** Specs need better Gherkin scenarios, stronger DoD, or clearer design. Status ceiling: `specs_hardened`.

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
| `full-delivery-strict` | All phases + strict chaos | Critical features |
| `value-first-e2e-batch` | Prioritized + batched | Large backlogs |
| `product-to-delivery` | Discovery → delivery | Product ideas |
| `product-discovery` | Analysis only | Early exploration |
| `bugfix-fastlane` | Bug → fix → test | Bug fixes |
| `feature-bootstrap` | Select → bootstrap → finalize | Create required artifacts without implementation |
| `iterate` | Implement → test loop | Continuing work |
| `harden-to-doc` | Harden → fix → test → docs | Code quality |
| `gaps-to-doc` | Gaps → fix → test → docs | Gap closure |
| `harden-gaps-to-doc` | Quality sweep | Post-implementation |
| `stabilize-to-doc` | Stability → test → docs | Infrastructure |
| `chaos-hardening` | Chaos → fix | Resilience |
| `chaos-to-doc` | Chaos → validate → docs | Chaos auditing |
| `reconcile-to-doc` | Reconcile → test → docs | Stale state cleanup |
| `improve-existing` | Analyze → harden → gaps → fix | Code improvement |
| `stochastic-quality-sweep` | Random quality | Maintenance |
| `test-to-doc` | Test → docs | Test/doc focus |
| `validate-to-doc` | Validate → audit → docs | Validation + docs |
| `spec-scope-hardening` | Harden specs only | Spec quality |
| `docs-only` | Docs only | Pure docs |
| `validate-only` | Validate only | Quick gate check |
| `audit-only` | Audit only | Compliance |
| `resume-only` | Resume state | Picking up work |

---

<p align="center">
  <em>"Way she goes, boys. Way she goes."</em>
</p>
