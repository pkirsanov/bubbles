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
- Each scenario must receive a stable `SCN-...` contract entry in `scenario-manifest.json`

### UI Scenario Matrix (Required when UI changes exist)
| Scenario | Preconditions | Steps | Expected | Test Type | Evidence |
|----------|---------------|-------|----------|-----------|----------|
| [Flow] | [Setup] | [Steps] | [Visible result] | e2e-ui | report.md#... |

### Implementation Plan
- Files/surfaces to modify

### Test Plan
Use the Test Plan table from scope-workflow.md and map each Gherkin scenario to a test entry that validates the exact use case behavior.

**E2E rows MUST be scenario-specific:** list the actual test file, actual `test()` title, and specific scenario ID. Generic E2E placeholders are FORBIDDEN — see agent-common.md → "ACTUAL E2E TEST SPECIFICITY".

**Every feature/fix/change MUST include explicit regression E2E planning:** for every new/changed/fixed behavior, add at least one persistent `Regression:` E2E row tied to the exact scenario or bug behavior it protects. A broad "existing E2E suite" row does not satisfy this requirement by itself.

**Renames/removals MUST include a Consumer Impact Sweep:** when a scope renames/removes any route, path, contract, identifier, or UI target, add a subsection enumerating affected navigation links, breadcrumbs, redirects, API clients, generated clients, deep links, docs, config, and tests, plus explicit regression rows for those consumer flows and a stale-reference-scan row for the old identifier/path.

Regression tests are previously missed tests: add them to feature/component-specific test files (no generic cross-feature regression files).

If the scope declares latency/performance SLAs, add explicit `stress` rows to the Test Plan.

### Definition of Done
Use the Tiered DoD template from scope-workflow.md:
- Core Items: scope-specific implementation and scenario validation items
- Build Quality Gate: zero warnings, zero deferrals, lint/format clean, artifact lint clean, docs aligned

The Core Items MUST include both:
- scenario-specific E2E regression coverage for each changed behavior
- broader E2E regression suite confirmation

If the scope renames/removes any route, path, contract, identifier, or UI target, the Core Items MUST also include a consumer impact sweep item proving zero stale first-party references remain.

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

### Code Diff Evidence
- Record executed git-backed evidence for implementation-bearing work.
- Include the exact git command used, relevant output, and at least one non-artifact runtime/source/config/contract file path.
- Artifact-only paths such as `spec.md`, `design.md`, docs, or `.github/` files are insufficient when claiming delivered implementation.

### Test Evidence
Use the test evidence sections from scope-workflow.md and include raw terminal output.

When `policySnapshot.tdd.mode` is `scenario-first`, include explicit red-stage and green-stage evidence for the changed scenario contracts.

All required tests must pass with zero skipped required tests.

Claims of completion/success must be evidence-linked; if any required evidence is missing or unknowns remain unresolved, status must be `blocked`.
```

## uservalidation.md Template

```markdown
# User Validation Checklist

## Checklist

- [x] Baseline checklist initialized for this feature
- [x] [Scenario or flow validated]
- [x] [Another validated flow]

Unchecked items indicate a user-reported regression.
```

Rules:
- Checklist items MUST use markdown checkbox syntax.
- Entries created by agents after validation/audit MUST default to checked `[x]`.
- Empty checklist or non-checkbox bullets are template violations.
- The canonical checklist section heading is `## Checklist`. Legacy files that omit it should be upgraded before completion claims.

## scenario-manifest.json Template

```json
{
  "version": 1,
  "featureDir": "specs/NNN-feature-name",
  "generatedAt": "YYYY-MM-DDTHH:MM:SSZ",
  "scenarios": [
    {
      "scenarioId": "SCN-NNN-001",
      "scope": "01-scope-name",
      "title": "User-visible or externally observable behavior",
      "gherkin": {
        "given": "precondition",
        "when": "action",
        "then": "result"
      },
      "gherkinHash": "sha256:...",
      "behaviorClass": "ui | api",
      "changeType": "new | changed | regression | bugfix | replacement",
      "requiredTestType": "e2e-ui | e2e-api",
      "regressionRequired": true,
      "lockdown": false,
      "linkedTests": [
        {
          "file": "path/to/live-system-test.spec.ts",
          "testId": "exact-test-name"
        }
      ],
      "evidenceRefs": [
        "report.md#scenario-scn-nnn-001"
      ],
      "replacedBy": null,
      "invalidatedBy": null
    }
  ]
}
```

## state.json Template

```json
{
  "version": 3,
  "featureDir": "specs/NNN-feature-name",
  "featureName": "Feature Name",
  "status": "not_started",
  "workflowMode": "full-delivery | spec-scope-hardening | docs-only | validate-only | audit-only | resume-only",
  "execution": {
    "activeAgent": "bubbles.workflow",
    "currentPhase": "context | discover | bootstrap | implement | test | regression | docs | validate | audit | chaos | finalize",
    "currentScope": null,
    "runStartedAt": "YYYY-MM-DDTHH:MM:SSZ",
    "completedPhaseClaims": [],
    "pendingTransitionRequests": []
  },
  "certification": {
    "status": "not_started",
    "completedScopes": [],
    "certifiedCompletedPhases": [],
    "scopeProgress": [
      {
        "scope": 1,
        "name": "Scope Name",
        "status": "not_started",
        "dependsOn": [],
        "scopeDir": "scopes/01-scope-name",
        "evidenceFile": "scopes/01-scope-name/report.md",
        "certifiedAt": null
      }
    ],
    "lockdownState": {
      "active": false,
      "lockedScenarioIds": []
    }
  },
  "policySnapshot": {
    "grill": {
      "mode": "off",
      "source": "repo-default"
    },
    "tdd": {
      "mode": "scenario-first",
      "source": "repo-default"
    },
    "autoCommit": {
      "mode": "off",
      "source": "repo-default"
    },
    "lockdown": {
      "mode": "off",
      "source": "repo-default"
    },
    "regression": {
      "mode": "protected-scenarios",
      "source": "repo-default"
    },
    "validation": {
      "mode": "certification-required",
      "source": "repo-default"
    }
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": [],
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
    "uservalidation": "uservalidation.md",
    "scenarioManifest": "scenario-manifest.json",
    "lockdownApprovals": "lockdown-approvals.json",
    "invalidationLedger": "invalidation-ledger.json",
    "transitionRequests": "transition-requests.json",
    "reworkQueue": "rework-queue.json"
  },
  "statusDiscipline": {
    "validStatuses": ["not_started", "in_progress", "blocked", "specs_hardened", "docs_updated", "validated", "done"],
    "scopePickupRule": "All dependsOn scopes must be Done. Pick the lowest-numbered eligible scope.",
    "scopeDoneGates": ["G020", "G021", "G022", "G023", "G024", "G025", "G055", "G056", "G057", "G058", "G059", "G060", "G061"],
    "specDoneRequires": "All scopes done. certification.completedScopes contains all scope IDs and bubbles.validate has certified promotion."
  },
  "notes": "Initialized."
}
```

**Status values:** `not_started`, `in_progress`, `blocked`, `specs_hardened`, `docs_updated`, `validated`, `done`.  
**`workflowMode`:** Records which workflow mode last set the status.  
Only modes with `statusCeiling: done` (in `bubbles/workflows.yaml`) may set `status: "done"`.
Artifact-only modes set their ceiling status (e.g., `specs_hardened` for `spec-scope-hardening`).
**`execution` vs `certification`:** execution records runtime claims; certification is the validate-owned authoritative state that must match top-level `status` before promotion.
**`policySnapshot`:** records the effective grill/TDD/auto-commit/lockdown/regression/validation settings together with provenance.
**`scopeLayout`:** `single-file` uses `scopes.md` + `report.md`; `per-scope-directory` uses `scopes/_index.md` plus `scopes/NN-name/scope.md` and `scopes/NN-name/report.md`.  
**`certification.scopeProgress`:** Machine-readable scope registry for dependency pickup, status sync, and evidence location.
```
