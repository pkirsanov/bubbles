# <img src="../icons/bubbles-glasses.svg" width="28"> Bubbles Recipe Catalog

> *"Alright boys, here's the full menu."*

Every recipe solves a specific problem. Find yours, follow the steps.

---

## At A Glance

| # | Recipe | Mode/Agent | One-Liner |
|---|--------|-----------|-----------|
| 1 | [Just Tell Bubbles](recipes/just-tell-bubbles.md) | `bubbles.workflow` | Describe what you want in plain English |
| 2 | [Ask the Super First](recipes/ask-the-super-first.md) | `bubbles.super` | Get command recommendations before acting |
| 3 | [New Feature](recipes/new-feature.md) | `product-to-delivery` | Idea → shipped code |
| 4 | [Fix a Bug](recipes/fix-a-bug.md) | `bugfix-fastlane` | Reproduce → fix → verify → ship |
| 5 | [Resume Work](recipes/resume-work.md) | `resume-only` | Pick up where you left off |
| 6 | [Set Up a New Project](recipes/setup-project.md) | `bubbles.setup` | Bootstrap Bubbles in a new repo |
| 7 | [Plan Only](recipes/plan-only.md) | `spec-scope-hardening` | Plan and scope without implementing |
| 8 | [Brainstorm an Idea](recipes/brainstorm-idea.md) | `brainstorm` | Explore before building — like YC office hours |
| 9 | [Explore an Idea](recipes/explore-idea.md) | `product-discovery` | Flesh out a vague product idea |
| 10 | [Grill an Idea](recipes/grill-an-idea.md) | `bubbles.grill` | Hard questions before commitment |
| 11 | [TDD First Execution](recipes/tdd-first-execution.md) | `tdd: true` tag | Red-green-first inner loop |
| 12 | [Reconcile/Redesign](recipes/reconcile-redesign-existing-feature.md) | `redesign-existing` | Stale specs → fresh design → delivery |
| 13 | [Choose The Right Review](recipes/choose-review-path.md) | Decision tree | code-review vs system-review vs workflow |
| 14 | [Code Review Directly](recipes/review-code-directly.md) | `bubbles.code-review` | Engineering-only review, no gates |
| 15 | [Review A Feature/System](recipes/system-review.md) | `bubbles.system-review` | Holistic product/UX/runtime review |
| 16 | [Review Then Improve](recipes/review-then-improve.md) | Review → workflow | Assess first, choose follow-through |
| 17 | [Quality Sweep](recipes/quality-sweep.md) | `delivery-lockdown` | Keep looping until green |
| 18 | [Post-Impl Hardening](recipes/post-impl-hardening.md) | Hardening sequence | Clean up before shipping |
| 19 | [Simplify Existing Code](recipes/simplify-existing-code.md) | `simplify-to-doc` | Reduce complexity safely |
| 20 | [Code Health Analysis](recipes/code-health-analysis.md) | `bubbles.retro hotspots` | Bug magnets, coupling, bus factor |
| 21 | [Data-Driven Simplify](recipes/retro-driven-simplify.md) | `retro-to-simplify` | Retro finds targets → simplify fixes them |
| 22 | [Data-Driven Harden](recipes/retro-driven-harden.md) | `retro-to-harden` | Retro finds targets → harden fixes them |
| 23 | [Data-Driven Review](recipes/retro-driven-review.md) | `retro-to-review` | Retro finds targets → review diagnoses them |
| 24 | [Retrospective](recipes/retro.md) | `bubbles.retro` | Velocity, gate health, shipping patterns |
| 25 | [Regression Check](recipes/regression-check.md) | `bubbles.regression` | Verify changes didn't break things |
| 26 | [Chaos Testing](recipes/chaos-testing.md) | `chaos-hardening` | Break things to find weaknesses |
| 27 | [Security Review](recipes/security-review.md) | `bubbles.security` | Vulnerability scanning |
| 28 | [Spec Freshness Review](recipes/spec-freshness-review.md) | `spec-review-to-doc` | Check if specs are still valid |
| 29 | [DevOps Work](recipes/devops-work.md) | `devops-to-doc` | CI/CD, deployment, monitoring |
| 30 | [Ops Packet Work](recipes/ops-packet-work.md) | OPS packets | Cross-cutting infra work |
| 31 | [Parallel Scopes](recipes/parallel-scopes.md) | `parallelScopes: dag` | Run independent scopes concurrently |
| 32 | [Cross-Model Review](recipes/cross-model-review.md) | `crossModelReview` | Second AI opinion |
| 33 | [Structured Commits](recipes/structured-commits.md) | `autoCommit: scope` | Clean git history |
| 34 | [Custom Gates](recipes/custom-gates.md) | CLI | Project-specific quality checks |
| 35 | [Framework Ops](recipes/framework-ops.md) | CLI / `bubbles.super` | Hooks, gates, upgrades, metrics |
| 36 | [Check Status](recipes/check-status.md) | `bubbles.status` | Current work state |
| 37 | [End of Day](recipes/end-of-day.md) | `bubbles.handoff` | Session handoff |
| 38 | [Update Docs](recipes/update-docs.md) | `docs-only` | Publish managed docs |

---

## By Workflow Category

### 🚀 Getting Started
1 → 2 → 6 → 3

### 🧠 Planning & Exploration
8 → 9 → 10 → 7 → 11

### 🔨 Building & Delivering
3 → 4 → 5 → 12

### 🔍 Review & Assessment
13 → 14 → 15 → 16 → 28

### 📊 Data-Driven Workflows
20 → 21 → 22 → 23 → 24

### 🛡️ Quality & Hardening
17 → 18 → 19 → 25 → 26 → 27

### ⚙️ Operations & Framework
29 → 30 → 31 → 32 → 33 → 34 → 35

### 📋 Day-to-Day
36 → 37 → 38

---

## Decision Tree: "Which Recipe Do I Need?"

```
START
  │
  ├─ Don't know where to start?
  │     → Recipe 1 (Just Tell Bubbles) or Recipe 2 (Ask the Super)
  │
  ├─ New feature from scratch?
  │     → Recipe 3 (New Feature)
  │
  ├─ Bug to fix?
  │     → Recipe 4 (Fix a Bug)
  │
  ├─ Continue yesterday's work?
  │     → Recipe 5 (Resume Work)
  │
  ├─ Want to improve existing code?
  │     ├─ Know where the problems are?
  │     │     → Recipe 19 (Simplify) or Recipe 18 (Harden)
  │     │
  │     └─ Need data first?
  │           → Recipe 20 (Code Health) then Recipe 21/22/23
  │
  ├─ Want a code review?
  │     ├─ Know what to review?
  │     │     → Recipe 14 (Code Review Directly)
  │     │
  │     └─ Need data to target it?
  │           → Recipe 23 (Data-Driven Review)
  │
  ├─ Pre-release quality check?
  │     → Recipe 17 (Quality Sweep)
  │
  └─ Something else?
        → Recipe 2 (Ask the Super)
```

---

<p align="center">
  <em>"It ain't rocket appliances. Just pick a recipe."</em>
</p>
