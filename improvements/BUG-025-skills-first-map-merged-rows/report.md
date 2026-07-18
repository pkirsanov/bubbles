# Report: BUG-025 Skills-First Map Merged Rows

## Summary

This artifact-only invocation created the complete BUG-025 intake packet and
recorded two malformed source lines through editor-based source inspection. It
did not edit the discovery skill, create a regression, run a parser, validate
the framework, reconcile release identity, commit, push, or touch downstream
repositories.

## Completion Statement

BUG DELIVERY REMAINS IN PROGRESS. The open source defect and planned parser
contract are documented; no implementation, RED/GREEN, validation, release,
certification, commit, or push completion is claimed. All implementation,
test, and DoD items remain unchecked.

## Source Inspection Evidence

**Phase:** discovery
**Claim Source:** interpreted

**Interpretation:** The current source table was read with an editor file tool.
The two lines shown below are current textual evidence, not parser execution.

```text
| Author or revise `scopes.md` / `scopes/*/scope.md` | `bubbles-scope-workflow-runtime` || Creating or refreshing a feature folder | `bubbles-feature-template` |
| Running a fix-cycle round; finding-set closure | `bubbles-fix-cycle-protocol` || Write or extend a Bubbles skill | `bubbles-skill-authoring` |
```

**Interpretation:** Each physical line carries two logical mappings and exceeds
the declared two-column table schema. The four target skill files exist in the
canonical skills tree, so the defect is row structure rather than a missing
target in these specific mappings.

## Test Evidence

**Claim Source:** not-run

No structural parser, behavior regression, lint, artifact guard, framework
validation, release check, or state-transition guard was run. A read-only Git
revision/date/status boundary audit was executed after packet creation; it did
not parse the skills-first map. No delivery-test exit code or runtime verdict
is asserted.

## Planned Regression Contract

**Claim Source:** not-run

The planned path is
`tests/regression/test_32_skills_first_map_merged_rows.sh`. It must parse row
cardinality, normalized situation uniqueness, target existence, target
duplicates, separator integrity, exact merged-row fixtures, and a valid
multi-target control. Final bytes and execution evidence belong to
`bubbles.test`.

## Finding Accounting

| Finding | Current disposition | Next owner |
| --- | --- | --- |
| `BUG025-F001-SCOPE-FEATURE-MERGE` | Confirmed by interpreted source inspection; unresolved. | `bubbles.implement` after RED |
| `BUG025-F002-FIX-SKILL-MERGE` | Confirmed by interpreted source inspection; unresolved. | `bubbles.implement` after RED |
| `BUG025-F003-STRUCTURAL-REGRESSION-MISSING` | Complete parser contract planned but not authored or executed. | `bubbles.test` |
| `BUG025-F004-CERTIFICATION-OPEN` | No delivery evidence exists. | `bubbles.validate` after delivery |

## Created Artifact Record

**Claim Source:** interpreted

This directory contains the requested nine packet artifacts and no delivery
claim. Shared indexes and implementation surfaces remain outside the boundary.
