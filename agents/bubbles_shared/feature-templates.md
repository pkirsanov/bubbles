# Feature Artifact Templates

Use these templates when creating feature artifacts.

## spec.md Template

```markdown
# Feature: [NNN] Short Name

## Problem Statement
State the user pain, system gap, and why now. Keep it user-visible and testable.

## Goals
- Concrete outcomes that can be verified by tests.
- Each goal should map to one or more requirements below.

## Non-Goals
- Explicitly out of scope (features, roles, systems, or phases).

## Requirements
- Functional and non-functional requirements written as observable behavior.
- Avoid implementation details or tooling.

## User Scenarios (Gherkin)

```gherkin
Scenario: [Short scenario]
  Given [preconditions]
  When [user/system action]
  Then [observable result]
```

## Acceptance Criteria
- Each criterion must map to a scenario and a test.
- Include negative/error cases.
```

## design.md Template

```markdown
# Design: [NNN] Short Name

## Overview
Summarize architecture intent, supported surfaces, and key constraints.

## Architecture
Components, data flow, integrations, and ownership boundaries.

## Data Model
Entities, relationships, migrations, and lifecycle constraints.

## API/Contracts
Endpoints, request/response shapes, error model, and versioning.

## UI/UX (if applicable)
Flows, layouts, states, and user-visible validation/error handling.

## Security/Compliance
Auth, privacy, access control, and data handling constraints.

## Observability
Logs, metrics, traces, and failure visibility.

## Testing Strategy
Map test types to exact requirements and Gherkin scenarios. Require explicit coverage for unit, integration, e2e, and stress (plus other applicable taxonomy types), with live-test execution evidence and no skipped required tests.

## Risks & Open Questions
- Open decisions, risks, and how they will be resolved.
```

## Scope Template

```markdown
# Scopes

Single-file mode: use `scopes.md` with the structure below.
Per-scope mode: keep the same section structure inside each `scopes/NN-name/scope.md`, and use `scopes/_index.md` for the summary table and dependency DAG.

Links: [spec.md](spec.md) | [design.md](design.md) | [uservalidation.md](uservalidation.md)

## Scope: [scope-name]

**Status:** Not Started | In Progress | Done | Blocked
**Priority:** P0 | P1 | P2 | P3
**Depends On:** [None | scope IDs]

### Gherkin Scenarios
- Given/When/Then scenarios
- Each scenario must map to a test in the Test Plan and a DoD evidence item

### UI Scenario Matrix (Required when UI changes exist)
| Scenario | Preconditions | Steps | Expected | Test Type | Evidence |
|----------|---------------|-------|----------|-----------|----------|
| [Flow] | [Setup] | [Steps] | [Visible result] | e2e-ui | report.md#... |

### Implementation Plan
- Files/surfaces to modify

### Test Plan
Use the Test Plan table from scope-workflow.md and map each Gherkin scenario to a test entry that validates the exact use case behavior.

**E2E rows MUST be scenario-specific:** list the actual test file, actual `test()` title, and specific scenario ID. Generic E2E placeholders are FORBIDDEN — see agent-common.md → "ACTUAL E2E TEST SPECIFICITY".

Regression tests are previously missed tests: add them to feature/component-specific test files (no generic cross-feature regression files).

If the scope declares latency/performance SLAs, add explicit `stress` rows to the Test Plan.

### Definition of Done
Use the Tiered DoD template from scope-workflow.md:
- Core Items: scope-specific implementation and scenario validation items
- Build Quality Gate: zero warnings, zero deferrals, lint/format clean, artifact lint clean, docs aligned

All DoD entries MUST be markdown checkboxes (`- [ ]` or `- [x]`). Non-checkbox DoD items are invalid.
Record raw execution evidence in the matching report file:
- single-file mode: `report.md`
- per-scope mode: `scopes/NN-name/report.md`
```

## report.md Template

```markdown
# Execution Reports

Single-file mode: use top-level `report.md`.
Per-scope mode: use `scopes/NN-name/report.md` for each scope.

Links: [uservalidation.md](uservalidation.md)

## Scope: [scope-name] - [YYYY-MM-DD HH:MM]

### Summary
- What changed (files/surfaces)
- Scenarios validated

### Test Evidence
Use the test evidence sections from scope-workflow.md and include raw terminal output.

All required tests must pass with zero skipped required tests.

Claims of completion/success must be evidence-linked; if any required evidence is missing or unknowns remain unresolved, status must be `blocked`.
```

## uservalidation.md Template

```markdown
# User Validation Checklist

- [x] Baseline checklist initialized for this feature
- [x] [Scenario or flow validated]
- [x] [Another validated flow]

Unchecked items indicate a user-reported regression.
```

Rules:
- Checklist items MUST use markdown checkbox syntax.
- Entries created by agents after validation/audit MUST default to checked `[x]`.
- Empty checklist or non-checkbox bullets are template violations.

## state.json Template

```json
{
  "version": 2,
  "featureDir": "specs/NNN-feature-name",
  "featureName": "Feature Name",
  "currentScope": null,
  "status": "not_started",
  "workflowMode": "full-delivery | spec-scope-hardening | docs-only | validate-only | audit-only | resume-only",
  "currentPhase": "context | plan | implement | tests | validate | docs | audit | finalize",
  "completedScopes": [],
  "completedPhases": [],
  "activeBugs": [],
  "resolvedBugs": [],
  "failures": [],
  "lastUpdatedAt": "YYYY-MM-DDTHH:MM:SSZ",
  "scopeLayout": "single-file | per-scope-directory",
  "artifacts": {
    "spec": "spec.md",
    "design": "design.md",
    "scopes": "scopes.md | scopes/_index.md",
    "report": "report.md | scopes/NN-name/report.md",
    "uservalidation": "uservalidation.md"
  },
  "statusDiscipline": {
    "validStatuses": ["not_started", "in_progress", "blocked", "specs_hardened", "docs_updated", "validated", "done"],
    "scopePickupRule": "All dependsOn scopes must be Done. Pick the lowest-numbered eligible scope.",
    "scopeDoneGates": ["G020", "G021", "G022", "G023", "G024", "G025"],
    "specDoneRequires": "All scopes done. completedScopes contains all scope IDs."
  },
  "scopeProgress": [
    {
      "scope": 1,
      "name": "Scope Name",
      "status": "not_started",
      "dependsOn": [],
      "scopeDir": "scopes/01-scope-name",
      "evidenceFile": "scopes/01-scope-name/report.md"
    }
  ],
  "notes": "Initialized."
}
```

**Status values:** `not_started`, `in_progress`, `blocked`, `specs_hardened`, `docs_updated`, `validated`, `done`.  
**`workflowMode`:** Records which workflow mode last set the status.  
Only modes with `statusCeiling: done` (in `bubbles/workflows.yaml`) may set `status: "done"`.
Artifact-only modes set their ceiling status (e.g., `specs_hardened` for `spec-scope-hardening`).
**`scopeLayout`:** `single-file` uses `scopes.md` + `report.md`; `per-scope-directory` uses `scopes/_index.md` plus `scopes/NN-name/scope.md` and `scopes/NN-name/report.md`.  
**`scopeProgress`:** Machine-readable scope registry for dependency pickup, status sync, and evidence location.
```
