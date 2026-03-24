# <img src="../../icons/bubbles-glasses.svg" width="28"> Recipes Index

> *"Alright boys, here's what we're gonna do."*

Each recipe solves a specific problem — the situation you're in, and exactly what to type.

Optional execution tags you can append to many workflow commands:
- `grillFirst: true` to pressure-test the direction before planning or implementation starts
- `tdd: true` to force a red-green-first execution loop inside the already-approved implement/test path
- `backlogExport: tasks|issues` to make `bubbles.plan` emit copy-ready backlog outputs per scope
- `socratic: true` for bounded clarification before discovery/bootstrap
- `gitIsolation: true` for isolated branch/worktree setup when allowed
- `autoCommit: scope` or `autoCommit: dod` for validated milestone commits
- `maxScopeMinutes` and `maxDodMinutes` to keep scopes aggressively small
- `microFixes: true` to keep failures in narrow repair loops

Baseline workflow law already requires spec/design/plan coherence, explicit Gherkin scenarios, and scenario-specific test planning before implementation starts.

---

## Start Here

| Recipe | Problem → Solution |
|--------|-------------------|
| [Ask the Super First](ask-the-super-first.md) | "I don't know the right command, agent, workflow mode, or recovery step" |

> **💡 Tip:** The super is the help desk for Bubbles itself: prompts, workflow choices, troubleshooting, and framework guidance in plain English.

## Getting Started

| Recipe | Problem → Solution |
|--------|-------------------|
| [Set Up a New Project](setup-project.md) | "I just installed Bubbles and need to get my project ready" |
| [New Feature](new-feature.md) | "I have a feature idea and need to take it from concept to shipped code" |
| [Fix a Bug](fix-a-bug.md) | "Something's broken and I need to fix it properly" |
| [Resume Work](resume-work.md) | "I was working on something yesterday, need to pick up where I left off" |

> **💡 Tip:** Not sure which recipe? Ask the super first: `/bubbles.super  help me <describe what you want to do>` — the super agent will recommend the right agent, mode, and steps.

## Quality & Maintenance

| Recipe | Problem → Solution |
|--------|-------------------|
| [Choose The Right Review](choose-review-path.md) | "I know I need review, but I don't know whether it should be code-review, system-review, or a workflow" |
| [Code Review Directly](review-code-directly.md) | "I want an engineering-only review before deciding what to fix" |
| [Review A Feature Or System](system-review.md) | "I want a holistic review before deciding what to fix, streamline, or spec" |
| [Review First, Then Improve](review-then-improve.md) | "I want to assess an existing area before choosing the right improvement workflow" |
| [Quality Sweep](quality-sweep.md) | "I want to improve code quality across a feature" |
| [Regression Check](regression-check.md) | "I need to make sure new changes didn't break existing features" |
| [Post-Implementation Hardening](post-impl-hardening.md) | "I want code cleaned up, stable, secure, and regression-free before shipping" |
| [Chaos Testing](chaos-testing.md) | "I need to break things to find weaknesses" |
| [Security Review](security-review.md) | "I need to check for security vulnerabilities" |

## Planning & Design

| Recipe | Problem → Solution |
|--------|-------------------|
| [Plan Only](plan-only.md) | "I want to plan and scope a feature without implementing" |
| [Explore an Idea](explore-idea.md) | "I have a vague product idea and need to flesh it out" |
| [Grill an Idea](grill-an-idea.md) | "I want hard questions before we commit to this direction" |
| [TDD First Execution](tdd-first-execution.md) | "I want the workflow to stay red-green-first instead of drifting into implementation-first" |

## Refactoring & Simplification

| Recipe | Problem → Solution |
|--------|-------------------|
| [Simplify Existing Code](simplify-existing-code.md) | "This works, but it's too complicated and I want to reduce the noise safely" |

## Day-to-Day

| Recipe | Problem → Solution |
|--------|-------------------|
| [Check Status](check-status.md) | "What's the state of my current work?" |
| [End of Day](end-of-day.md) | "I'm done for today, need to hand off context" |
| [Update Docs](update-docs.md) | "Code changed, docs need updating" |
| [Framework Ops](framework-ops.md) | "I need to manage Bubbles itself — hooks, gates, upgrades, metrics" |
| [Structured Commits](structured-commits.md) | "I want clean, scope-by-scope git history" |
| [Custom Gates](custom-gates.md) | "I need project-specific quality checks beyond the built-in framework gates" |
