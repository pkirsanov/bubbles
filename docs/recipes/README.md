# <img src="../../icons/bubbles-glasses.svg" width="28"> Recipes Index

> *"Alright boys, here's what we're gonna do."*

Each recipe solves a specific problem — the situation you're in, and exactly what to type.

Optional execution tags you can append to many workflow commands:
- `socratic: true` for bounded clarification before discovery/bootstrap
- `gitIsolation: true` for isolated branch/worktree setup when allowed
- `autoCommit: scope` or `autoCommit: dod` for validated milestone commits
- `maxScopeMinutes` and `maxDodMinutes` to keep scopes aggressively small
- `microFixes: true` to keep failures in narrow repair loops

---

## Getting Started

| Recipe | Problem → Solution |
|--------|-------------------|
| [Set Up a New Project](setup-project.md) | "I just installed Bubbles and need to get my project ready" |
| [New Feature](new-feature.md) | "I have a feature idea and need to take it from concept to shipped code" |
| [Fix a Bug](fix-a-bug.md) | "Something's broken and I need to fix it properly" |
| [Resume Work](resume-work.md) | "I was working on something yesterday, need to pick up where I left off" |

> **💡 Tip:** Not sure which recipe? Just ask: `/bubbles.ops  help me <describe what you want to do>` — the ops agent will recommend the right agent, mode, and steps.

## Quality & Maintenance

| Recipe | Problem → Solution |
|--------|-------------------|
| [Quality Sweep](quality-sweep.md) | "I want to improve code quality across a feature" |
| [Chaos Testing](chaos-testing.md) | "I need to break things to find weaknesses" |
| [Security Review](security-review.md) | "I need to check for security vulnerabilities" |

## Planning & Design

| Recipe | Problem → Solution |
|--------|-------------------|
| [Plan Only](plan-only.md) | "I want to plan and scope a feature without implementing" |
| [Explore an Idea](explore-idea.md) | "I have a vague product idea and need to flesh it out" |

## Day-to-Day

| Recipe | Problem → Solution |
|--------|-------------------|
| [Check Status](check-status.md) | "What's the state of my current work?" |
| [End of Day](end-of-day.md) | "I'm done for today, need to hand off context" |
| [Update Docs](update-docs.md) | "Code changed, docs need updating" |
| [Framework Ops](framework-ops.md) | "I need to manage Bubbles itself — hooks, gates, upgrades, metrics" |
| [Structured Commits](structured-commits.md) | "I want clean, scope-by-scope git history" |
| [Custom Gates](custom-gates.md) | "I need project-specific quality checks beyond the built-in 39" |
