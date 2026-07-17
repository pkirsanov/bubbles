# Expected Behavior: BUG-018 Traceability Test Plan Heading Depth

## Problem Contract

Traceability must consume every Test Plan heading shape accepted by the
framework's planning/artifact contract. Valid heading depth is formatting, not
behavior. Invalid or empty Test Plan input must fail with a stable diagnostic,
never through an unexplained shell exit.

## Actors

- A downstream planner authoring single-file or per-scope planning artifacts.
- An implementation owner relying on traceability findings to close a scope.
- A validator distinguishing malformed planning input from an internal guard
  crash.
- The canonical Bubbles release that distributes managed guard bytes.

## Requirements

### BR-001 Recognize Valid Test Plan Heading Depths

The production traceability guard must recognize exact `Test Plan` headings at
both level 2 (`## Test Plan`) and level 3 (`### Test Plan`). Matching must not
depend on changing an otherwise valid downstream packet.

### BR-002 Preserve Existing Level-3 Behavior

Every packet currently using `### Test Plan` must retain the same extracted
rows, scenario mapping, diagnostics, and exit semantics.

### BR-003 Heading-Aware Section Boundaries

After selecting a Test Plan heading, extraction must stop at the next heading
of the same or a shallower depth. A nested subsection may remain inside a
level-2 Test Plan section, while a later level-2 section may not leak rows into
it.

### BR-004 Expected No-Match Is Data

No heading, no concrete table row, a table separator only, or a header row only
must be handled explicitly. None of those expected input states may terminate
the shell because `grep` returned `1` under `set -e` or `pipefail`.

### BR-005 Stable Fail-Loud Diagnostics

For invalid input, the guard must emit a scope-qualified diagnostic identifying
either a missing recognized Test Plan section or a recognized section with no
concrete rows. It must continue through normal finding accounting and finish
with the standard nonzero guard summary.

### BR-006 Exact Heading Match

Prose, comments, code fences, `Test Planning`, and deeper headings not accepted
by the planning contract must not masquerade as a recognized Test Plan section.

### BR-007 Persistent Production-Path Regression

A committed regression must invoke the real
`bubbles/scripts/traceability-guard.sh` against disposable feature packets. It
must cover level 2, level 3, missing section, empty section, and section-boundary
cases without duplicating the production extraction logic.

### BR-008 Adversarial Protection

At least one pair must hold all scenario rows constant and vary only heading
depth. At least one invalid packet must prove that removing explicit no-match
handling recreates the silent exit. Regression code may not return early when
the expected diagnostic is absent.

### BR-009 Cross-Platform Shell

The repair and regression must run with macOS Bash 3.2/BSD userland and Linux
GNU userland. They must avoid raw GNU-only forms and use shipped portability
helpers where applicable.

### BR-010 Canonical-Only Delivery

The repair lands only in canonical Bubbles source and reaches Research Lab or
other consumers through supported release/install/upgrade provenance. No
downstream managed copy may be edited directly.

## Acceptance Scenarios

```gherkin
Feature: Trace valid Test Plan heading shapes without silent shell exits

  Scenario: A level-2 Test Plan maps scenarios normally
    Given a valid per-scope packet has scenarios and concrete rows under ## Test Plan
    When the production traceability guard analyzes the packet
    Then it maps every scenario to its Test Plan row
    And it does not report a missing Test Plan

  Scenario: Existing level-3 Test Plans remain compatible
    Given an equivalent valid packet has the same rows under ### Test Plan
    When the production traceability guard analyzes the packet
    Then it produces the same scenario mapping and successful verdict

  Scenario: Invalid Test Plan input fails with a diagnostic
    Given a scope has no recognized Test Plan section or no concrete rows
    When the production traceability guard analyzes the packet
    Then it emits a scope-qualified Test Plan diagnostic
    And it reaches the normal nonzero guard summary
    And it does not terminate immediately after the scope announcement

  Scenario: Section boundaries follow heading depth
    Given a level-2 Test Plan contains a nested level-3 subsection
    And a later level-2 section contains unrelated table rows
    When the production traceability guard extracts Test Plan rows
    Then nested Test Plan content remains eligible
    And rows from the later level-2 section are excluded
```

## Non-Goals

- Supporting arbitrary heading titles or arbitrary Markdown depths.
- Weakening scenario mapping, linked-test existence, evidence references, or
  Definition of Done checks.
- Replacing all Markdown parsing in the framework.
- Editing downstream planning artifacts to accommodate the current defect.
- Claiming implementation or validation from this documentation packet.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
