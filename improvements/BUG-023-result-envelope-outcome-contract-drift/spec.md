# Expected Behavior: BUG-023 Result-Envelope Outcome Contract Drift

## Problem Contract

Skills-first guidance must expose the same active RESULT-ENVELOPE outcomes and
completion-status semantics as the authoritative validation and completion
modules. Legacy compatibility prose may remain readable, but it must never be
interpretable as permission for a new write.

## Actors

- A state-modifying agent returning control to an orchestrator.
- A diagnostic agent completing owned analysis without delivering a fix.
- A workflow runner classifying a terminal envelope.
- A validator certifying current state and rejecting legacy new writes.

## Requirements

### BR-023-001 Canonical Active Outcome Set

The active RESULT-ENVELOPE outcome vocabulary must be exactly:

- `completed_owned`
- `completed_diagnostic`
- `route_required`
- `blocked`

No active skill table, envelope shape, example, or instruction may add or omit
an outcome.

### BR-023-002 Diagnostic Outcome Definition

`completed_diagnostic` must be defined as successful completion of the
diagnostic agent's owned analysis with honest finding accounting, without an
implementation, delivery, or certification claim.

### BR-023-003 Current Observation Semantics

Non-blocking notes associated with successful owned work must use
`completed_owned` with `observations[]`. Current certification must use `done`
with `observations[]` when all gates pass, or `blocked` when required work
remains.

### BR-023-004 Legacy Read-Only Isolation

Any `done_with_concerns` mention retained in a framework skill must appear only
inside an explicitly marked legacy-read-only section and must state that new
RESULT-ENVELOPE, top-level status, certification, and recertification writes
are forbidden.

### BR-023-005 Stale Skill Reconciliation

The result-envelope, feature-template, fix-cycle-protocol, and
status-transition skills must all use the current contract. No stale active
`followUps[] under done_with_concerns` or ordinary transition instruction may
remain.

### BR-023-006 Deterministic Parity Regression

A source-only regression must parse the authoritative set and active skill
surfaces deterministically. It must detect missing outcomes, extra outcomes,
active legacy semantics, duplicate outcome rows, and an unmarked legacy token.

### BR-023-007 Adversarial Legacy Fixture

The regression must include both:

- a valid fixture where legacy status text is explicitly read-only and passes;
- a mutated fixture where the same token appears in an active outcome table or
  write instruction and fails.

### BR-023-008 Consumer And Provenance Integrity

Existing envelope field ordering, finding-accounting requirements,
continuation-envelope behavior, install provenance, and release identity must
remain intact. No downstream managed copy may be hand-edited.

## Acceptance Scenarios

```gherkin
Feature: Keep result-envelope guidance aligned with authoritative governance

  Scenario: Active outcome guidance has exact canonical parity
    Given the authoritative active outcomes in validation-core.md
    And the framework-shipped result and status skills
    When the deterministic parity regression parses active semantics
    Then completed_owned, completed_diagnostic, route_required, and blocked are present exactly once
    And no additional active outcome is accepted
    And every related skill uses current observation and status semantics

  Scenario: Legacy status prose is readable but cannot authorize a new write
    Given explicitly marked legacy read-only compatibility prose
    When the deterministic parity regression classifies that prose
    Then the prose is accepted as historical compatibility guidance
    But moving done_with_concerns into an active table or write instruction fails the regression
```

## Outcome Contract

- **Intent:** Align all active skills-first outcome/status guidance with the
  authoritative framework contract.
- **Success Signal:** One deterministic regression proves exact active-set
  parity and rejects active legacy-status mutations while allowing only
  explicitly marked read-only prose.
- **Failure Condition:** Any skill omits `completed_diagnostic`, advertises an
  extra active outcome, teaches a new `done_with_concerns` write, or evades the
  parser through malformed Markdown.

## Single-Capability Justification

This bug repairs one framework capability: trustworthy result-envelope and
completion-state guidance. The four skill edits and one parser regression are
one contract surface, not independent features.

## Release Train

Target train: `framework-next`. No feature flag is introduced.

## Non-Goals

- Changing the authoritative active outcome set.
- Removing read compatibility for legitimately grandfathered packets.
- Changing workflow mode ceilings or certification ownership.
- Editing downstream framework copies directly.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
