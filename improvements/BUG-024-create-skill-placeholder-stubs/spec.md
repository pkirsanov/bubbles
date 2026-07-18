# Expected Behavior: BUG-024 Create-Skill Placeholder Stubs

## Problem Contract

The create-skill workflow must produce a complete, verified `SKILL.md` or
refuse to write. Optional routing sections are conditional content, never
mandatory incomplete scaffold markers.

## Actors

- A user answering the three-question create-skill interview.
- The create-skill agent deciding whether context is sufficient to write.
- A future agent loading the generated skill by semantic triggers.
- A reviewer validating that generated guidance is complete and specific.

## Requirements

### BR-024-001 Concrete Optional Sections

When known and applicable, `When NOT to use` and `Works well with` must contain
concrete negative triggers and concrete sibling-skill composition pointers
grounded in interview answers or verified repository context.

### BR-024-002 Clean Omission

When either section is genuinely inapplicable, the generated `SKILL.md` must
omit it entirely. No empty heading, bracketed instruction, generic sentence,
or incomplete marker may substitute for omitted content.

### BR-024-003 Material Boundary Interview

If a missing negative trigger could cause unsafe or materially incorrect skill
activation, the agent must ask a focused additional boundary question or
refuse to scaffold until the boundary is known.

### BR-024-004 Material Composition Interview

If safe execution depends on another skill but that dependency is unknown, the
agent must ask a focused composition question or refuse to scaffold. It must
not invent a sibling skill or emit generic composition text.

### BR-024-005 Preserve Three-Question Core

The existing intent, trigger, and output interview remains the standard core.
Clarifying a material boundary is a targeted continuation of incomplete input,
not permission to generate an incomplete file.

### BR-024-006 Auto-Detect Fail-Closed

Auto-detect mode may scaffold immediately only when all material intent,
activation, output, exclusion, and composition information needed for a safe
skill is known. Otherwise it must continue the interview for only the missing
material information.

### BR-024-007 Deterministic Scaffold Regression

A source-only structural regression must validate the create-skill contract
against concrete-section, valid-omission, missing-material-boundary, and
reintroduced-incomplete-marker fixtures.

### BR-024-008 Adversarial Reintroduction

The regression must fail when any mutation restores mandatory section-stub
language, permission to leave incomplete content, an empty optional heading,
or a generic filler body that does not identify a real boundary or sibling.

### BR-024-009 Preserve Governance Boundaries

Work classification, artifact gates, deduplication, the reusable/non-trivial/
specific/verified quality bar, file location, frontmatter requirements, and
single-file default output must remain intact.

## Acceptance Scenarios

```gherkin
Feature: Scaffold only complete and verified repo-local skills

  Scenario: Known optional guidance is concrete and unknown inapplicable guidance is omitted
    Given complete skill intent, triggers, outputs, and verified repository context
    When create-skill renders SKILL.md
    Then each applicable optional section contains concrete routing content
    And each inapplicable optional section is absent
    And no incomplete marker or generic filler is emitted

  Scenario: Materially missing boundary information prevents incomplete scaffolding
    Given sufficient core interview answers but an unknown safety-critical negative trigger or composition dependency
    When create-skill evaluates write readiness
    Then it asks only for the material missing information or refuses the write
    And it does not create SKILL.md with empty or incomplete optional sections
    And restoring the current stub fallback fails the adversarial regression
```

## Outcome Contract

- **Intent:** Make create-skill output complete by construction.
- **Success Signal:** Deterministic fixtures prove concrete inclusion, clean
  omission, and fail-closed handling of material unknowns.
- **Failure Condition:** The agent can instruct a write containing incomplete
  section content or silently omit a material activation boundary.

## Single-Capability Justification

This bug repairs one capability: policy-compliant skill scaffolding. Interview
readiness and rendered optional sections are two decisions within the same
single-file generation flow.

## Release Train

Target train: `framework-next`. No feature flag is introduced.

## Non-Goals

- Making the two recommended sections mandatory for existing skills.
- Expanding create-skill into a general documentation generator.
- Inventing sibling skills or inferred safety boundaries.
- Changing work-classification or artifact-gate policy.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
