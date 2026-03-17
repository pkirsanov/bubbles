# Recipe: Plan Only (No Implementation)

> *"Jim, you need a plan."*

---

## The Situation

You want to think through a feature — requirements, design, scope breakdown — without writing code yet.

## The Command

```
/bubbles.workflow  feature-bootstrap for my-new-feature
```

**Phases:** analyze → design → plan

## Or Step by Step

### 1. Requirements

```
/bubbles.analyst  describe the feature: <your idea>
```

### 2. Design

```
/bubbles.design  create design for <feature>
```

### 3. Scope Breakdown

```
/bubbles.plan  create scopes for <feature>
```

## What You Get

A complete `specs/NNN-feature/` folder with:
- `spec.md` — requirements and acceptance criteria
- `design.md` — architecture and data models
- `scopes.md` — implementable scopes with DoD

Ready to implement whenever you are.
