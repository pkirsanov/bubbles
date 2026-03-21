# Scope Templates

Use this file for artifact templates and examples. Keep `scope-workflow.md` focused on authoritative workflow rules.

## `scopes/_index.md` Template

```markdown
# Scopes Index

## Dependency Graph

| # | Scope | Depends On | Surfaces | Status |
|---|-------|------------|----------|--------|
| 01 | [scope-name] | — | [surfaces] | Not Started |
```

## Per-Scope `scope.md` Template

```markdown
# Scope: [scope-name]

**Status:** Not Started
**Depends On:** [scope numbers or —]

### Gherkin Scenarios

Scenario: [scenario name]
  Given [starting state]
  When [action]
  Then [outcome]

### UI Scenario Matrix (Required when UI changes exist)

| Scenario | Preconditions | Steps | Expected | Test Type |
|----------|---------------|-------|----------|-----------|

### Implementation Plan

- [implementation step]

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
|-----------|----------|---------------|-------------|---------|-------------|

### Definition of Done — Tiered Validation

- [ ] Implementation behavior is complete for this scope
- [ ] Scenario-specific tests pass for this scope
- [ ] Regression coverage exists for newly-fixed failure modes
- [ ] Build Quality Gate passes as a grouped block
```

## Single-File `scopes.md` Template

```markdown
# Scopes

## Scope: [scope-name]

**Status:** Not Started
**Depends On:** [scope numbers or —]

### Gherkin Scenarios
...

### UI Scenario Matrix (Required when UI changes exist)
...

### Implementation Plan
...

### Test Plan
...

### Definition of Done — Tiered Validation
...
```

## `report.md` Template

```markdown
# Report

## Scope: [scope-name] - [YYYY-MM-DD HH:MM]

### Summary

### Decision Record (Required for non-trivial work)

### Completion Statement (MANDATORY)

### Test Evidence (ALL TYPES REQUIRED)

### Coverage Report

### Lint/Quality

### Validation Summary

### Audit Verdict
```

## `uservalidation.md` Template

```markdown
# User Validation

- [x] [baseline validated behavior]
```

## `state.json` Shape

```json
{
  "status": "not_started",
  "currentPhase": null,
  "completedScopes": [],
  "completedPhases": [],
  "scopeProgress": []
}
```