# Expected Behavior: BUG-025 Skills-First Map Merged Rows

## Problem Contract

The skills-first situation map must be a structurally valid Markdown table in
which each physical data row represents one situation and one or more explicit,
resolvable skill targets. A malformed row must fail deterministic validation,
not degrade silently.

## Actors

- An agent selecting governance through skills-first discovery.
- A maintainer adding or editing situation-to-skill mappings.
- A Markdown or semantic-index consumer parsing the map.
- A validator checking framework source integrity.

## Requirements

### BR-025-001 Split Scope And Feature Mappings

The scope-authoring situation and feature-folder situation must be separate
two-column Markdown rows targeting `bubbles-scope-workflow-runtime` and
`bubbles-feature-template` respectively.

### BR-025-002 Split Fix-Cycle And Skill-Authoring Mappings

The fix-cycle situation and skill-authoring situation must be separate
two-column Markdown rows targeting `bubbles-fix-cycle-protocol` and
`bubbles-skill-authoring` respectively.

### BR-025-003 Row Cardinality

Every physical data row in the map must parse to exactly two top-level cells:
one nonempty situation cell and one nonempty skill-target cell. The parser must
not accept trailing cells, doubled row boundaries, or an unterminated row.

### BR-025-004 Unique Situations

After trimming and collapsing whitespace, each situation must be unique.
Duplicate normalized situations must fail with both row identities reported.

### BR-025-005 Resolvable Skill Targets

Every backticked `bubbles-*` target in the target cell must resolve to exactly
one existing `skills/<target>/SKILL.md`. Multiple comma-separated targets are
allowed only when each target resolves independently. Unknown, empty, or
duplicate targets in one row must fail.

### BR-025-006 Separator Integrity

Within the map section, any nonblank, nonheading, non-table-separator line that
looks like a mapping must use the canonical leading/trailing pipe row form.
Missing separators and data spilling across physical lines must fail closed.

### BR-025-007 Merged-Row Fixture

The regression must include the exact `| ||` merged-row pattern as an
adversarial fixture and prove it fails row-cardinality validation.

### BR-025-008 Deterministic Structural Regression

A source-only regression must parse the current canonical table and isolated
fixtures without relying on rendered HTML, network access, or editor behavior.
It must report row count and the specific invariant violated.

### BR-025-009 Preserve Map Semantics

All other situation mappings, target order, section boundaries, skills-first
rationale, grandfather guidance, install provenance, and release identity must
remain unchanged.

## Acceptance Scenarios

```gherkin
Feature: Keep the skills-first situation map structurally valid

  Scenario: Four independent situations resolve to four valid map rows
    Given the canonical skills-first discovery map
    When the structural parser reads every physical data row
    Then scope authoring, feature-folder creation, fix-cycle work, and skill authoring are four independent situations
    And each row has exactly two nonempty cells
    And every referenced skill target resolves to an existing skill

  Scenario: Malformed or ambiguous map entries fail closed
    Given fixtures with a merged row, duplicate situation, unknown target, or missing separator
    When the structural parser validates each fixture independently
    Then each invalid fixture fails with its specific invariant
    And the canonical valid control passes without dropping any mapping
```

## Outcome Contract

- **Intent:** Restore four independent discovery mappings and prevent
  structural table drift.
- **Success Signal:** The canonical map passes a deterministic parser while
  merged-row, duplicate, unknown-target, and separator fixtures fail.
- **Failure Condition:** A malformed row is accepted, a valid mapping is lost,
  or target resolution can silently ignore an unknown skill.

## Single-Capability Justification

This bug repairs one capability: reliable skills-first routing through one
canonical situation map. The four split rows and parser regression form one
vertical contract.

## Release Train

Target train: `framework-next`. No feature flag is introduced.

## Non-Goals

- Rewording or reorganizing unrelated situation mappings.
- Renaming any skill.
- Changing semantic auto-load behavior outside this map.
- Adding a general-purpose Markdown framework dependency.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
