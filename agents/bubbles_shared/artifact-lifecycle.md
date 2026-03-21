# Artifact Lifecycle Governance

Use this file for work classification, required artifacts, scope structure, and lifecycle expectations for spec folders.

## Work Classification Gate

All work must be classified as either:

- feature work under `specs/NNN-feature-name/`
- bug work under `specs/.../bugs/BUG-NNN-description/`

Ad-hoc implementation outside that structure is not valid completion work.

## Required Feature Artifacts

Feature directories require:

- `spec.md`
- `design.md`
- `scopes.md` or `scopes/_index.md` plus per-scope files
- `report.md` or per-scope reports
- `uservalidation.md`
- `state.json`

## Required Bug Artifacts

Bug directories require:

- `bug.md`
- `spec.md`
- `design.md`
- `scopes.md`
- `report.md`
- `state.json`

## User Validation Gate

Unchecked items in `uservalidation.md` represent user-reported regressions and block unrelated forward progress until addressed or explicitly reclassified by the owning workflow.

## Scope Structure

Each scope must contain:

- status
- dependency declaration when applicable
- Gherkin scenarios
- implementation plan
- Test Plan
- DoD checkboxes

When UI behavior changes, add a UI scenario matrix.

## Tiered DoD Expectations

Every scope must include checks that prove:

- implementation behavior is complete
- scenario-specific tests pass
- regression coverage exists for changed behavior
- grouped build quality gate passes

Project-specific additions may extend this, but cannot weaken it.

## Scope Isolation And Pickup

Implement and iterate agents work from the next eligible scope only:

- respect declared dependencies
- do not start later scopes before earlier required scopes are done
- when six or more scopes exist, prefer per-scope directory mode

## Bug Awareness

Before starting new feature work, review unresolved bug folders under the same feature area and surface those to the user or orchestrator instead of silently ignoring them.

## Artifact Cross-Linking

Artifacts must cross-reference each other so a reviewer can move between:

- spec
- design
- scopes
- report
- user validation
- state

Use the templates in `scope-templates.md` as the single source of truth for artifact shapes.

## Documentation Ownership Boundary

Artifact ownership remains defined in `artifact-ownership.md`. Diagnostic agents may identify required changes, but they do not directly rewrite foreign-owned planning or design artifacts except through the execution-only exception.