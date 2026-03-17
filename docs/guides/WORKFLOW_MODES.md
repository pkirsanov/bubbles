# 🫧 Bubbles Workflow Modes

> *"Julian's got a plan. A good plan this time."*

Workflow modes define **which phases run** and **in what order** for a given piece of work. Choose the mode that matches what you're doing.

---

## Choosing a Mode

```
/bubbles.workflow  <mode-name> for <feature/bug>
```

If you don't specify a mode, `full-delivery` is the default.

---

## Full Delivery Modes

These run the complete pipeline. Use for new features.

### <img src="../../icons/julian-glass.svg" width="20"> full-delivery

**The standard.** All phases, strict gates, complete coverage.

```
analyze → design → plan → implement → test → validate → audit → docs
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
select (by value) → plan → implement → test → validate → audit → docs
```

**Use when:** Multiple features competing for time. Large backlogs.

```
/bubbles.workflow  value-first-e2e-batch for all pending specs
```

### <img src="../../icons/bubbles-glasses.svg" width="20"> product-to-delivery

Full product discovery → delivery pipeline.

```
analyze → ux → design → plan → implement → test → validate → audit → docs
```

**Use when:** Starting from a product idea, not a technical spec.

---

## Fast-Track Modes

Skip phases you don't need. Move fast without cutting safety.

### <img src="../../icons/ricky-dynamite.svg" width="20"> bugfix-fastlane

Fast bug resolution with proper evidence.

```
bug-reproduce → implement-fix → test → validate
```

**Use when:** Bug fixes. Get in, fix it, prove it, get out.

```
/bubbles.workflow  bugfix-fastlane for BUG-015
```

### <img src="../../icons/cory-trevor-smokes.svg" width="20"> feature-bootstrap

Just the planning phases. Sets up artifacts without implementing.

```
analyze → design → plan
```

**Use when:** You want to plan but not implement yet.

### <img src="../../icons/julian-glass.svg" width="20"> iterate

Continue scope-by-scope implementation within an existing spec.

```
implement → test → validate (repeat per scope)
```

**Use when:** Picking up where you left off.

```
/bubbles.workflow  iterate for 042-catalog-assistant
```

---

## Quality & Hardening Modes

Focus on quality without new implementation.

### <img src="../../icons/conky-puppet.svg" width="20"> harden-gaps-to-doc

Hardening → gap analysis → test → documentation. The quality sandwich.

```
harden → gaps → test → validate → docs
```

**Use when:** Post-implementation quality sweep.

### <img src="../../icons/ricky-dynamite.svg" width="20"> chaos-hardening

Chaos testing followed by hardening fixes.

```
chaos → harden → test → validate
```

**Use when:** Resilience testing and fixing.

### <img src="../../icons/conky-puppet.svg" width="20"> spec-scope-hardening

Tighten specs and scope definitions. No code changes.

```
clarify → plan → harden
```

**Use when:** Specs are vague, scopes need tightening.

### <img src="../../icons/ricky-dynamite.svg" width="20"> stochastic-quality-sweep

Random quality checks across the codebase. Like bottle kids — you never know where they'll hit.

```
random(harden, gaps, chaos, security, test) → validate → docs
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

### <img src="../../icons/lahey-bottle.svg" width="20"> audit-only

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
| `full-delivery` | All 8 | Standard features |
| `full-delivery-strict` | All 8 + chaos | Critical features |
| `value-first-e2e-batch` | Prioritized + batched | Large backlogs |
| `product-to-delivery` | Discovery → delivery | Product ideas |
| `bugfix-fastlane` | Bug → fix → test | Bug fixes |
| `feature-bootstrap` | Analyze → design → plan | Planning only |
| `iterate` | Implement → test loop | Continuing work |
| `harden-gaps-to-doc` | Quality sweep | Post-implementation |
| `chaos-hardening` | Chaos → fix | Resilience |
| `stochastic-quality-sweep` | Random quality | Maintenance |
| `test-to-doc` | Test → docs | Test/doc focus |
| `docs-only` | Docs only | Pure docs |
| `validate-only` | Validate only | Quick gate check |
| `audit-only` | Audit only | Compliance |
| `resume-only` | Resume state | Picking up work |
| `product-discovery` | Analysis only | Early exploration |

---

<p align="center">
  <em>"Way she goes, boys. Way she goes."</em>
</p>
