# Expected Behavior: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Problem Contract

The state-transition guard must preserve nounset enforcement and its complete
structured result contract on every supported Bash runtime, including stock
macOS `/bin/bash` 3.2, when any internal indexed array contains zero, one, or
multiple elements.

## Actors

- A macOS contributor running the canonical state-transition guard.
- A Linux or newer-Bash contributor relying on unchanged guard semantics.
- A workflow runner consuming `TRANSITION_GUARD_RESULT_V1` fields and exit
  status.
- A release owner propagating canonical framework bytes downstream.

## Requirements

### BR-022-001 Preserve Strict Shell Mode

The production guard must continue to run with `set -euo pipefail`. The repair
must not disable nounset globally or locally around array operations.

### BR-022-002 Support Zero Elements

Every valid zero-element state must execute without an unbound-variable abort.
Empty structured result collections must serialize exactly as `[]`, and empty
loops must perform zero iterations.

### BR-022-003 Support The First Element

The first pass, failure, gate, check, report, scope, or evidence item must be
accepted from an initially empty accumulator without a sentinel value or
fabricated placeholder.

### BR-022-004 Preserve One And Multiple Elements

One-element and multiple-element states must preserve existing order,
deduplication, formatting, counts, gate attribution, and result vocabulary.

### BR-022-005 Preserve Blocking Semantics

A genuine guard finding must still produce a nonzero exit and a complete
structured failure result. Empty-array compatibility must not turn a failure
into success, suppress a failed check, or allow the caller to observe a false
zero exit.

### BR-022-006 Preserve Check 8 Parser Behavior

The BUG-019 compound-MJS parser behavior, exact Check 8 diagnostics, and
existing production regression bytes must remain unchanged by BUG-022.

### BR-022-007 Cover Every Zero-State Family

Regression coverage must exercise the direct result-state arrays, delivery
result formatting, per-scope discovery, per-scope report discovery, first
evidence comparison, and final failed-gate lookup identified in `bug.md`.

### BR-022-008 Reject Reintroduction

Adversarial mutations that restore a raw empty-array expansion at each distinct
behavior family must fail. A test that covers only the already observed line
72 or line 82 abort is insufficient.

### BR-022-009 Canonical-Only Delivery

Canonical source, persistent regression registration, install provenance,
release identity, and supported downstream upgrade evidence must agree before
certification. Generated release files and downstream managed copies must not
be hand-edited.

### BR-022-010 Preserve Concurrent Ownership

BUG-019/BUG-012 source changes, BUG-020 `fun-mode.sh`, BUG-021
`framework-validate.sh`, shared `BUGS.md`, and downstream Research Lab bytes
must remain outside BUG-022 intake ownership.

### Single-Capability Justification

This bug repairs one existing capability: Bash-portable state-transition result
construction and artifact scanning. It does not introduce a new list type,
parser, result schema, workflow mode, or compatibility layer. The owning
design must reconcile all affected array sites through one consistent existing
guard implementation strategy rather than add separate per-check fallbacks.

## Acceptance Scenarios

```gherkin
Feature: Preserve state-transition guard semantics with nounset on Bash 3.2

  Scenario: Zero-element states remain valid and observable
    Given stock macOS Bash 3.2 with set -euo pipefail active
    And a production guard path with an intentionally empty result collection
    When the state-transition guard executes that path
    Then no unbound-variable abort occurs
    And the complete structured result serializes the collection as []
    And the intended pass or block exit status is preserved

  Scenario: One element crosses the empty accumulator boundary exactly once
    Given stock macOS Bash 3.2 with set -euo pipefail active
    And an initially empty gate or check accumulator
    When the production guard records its first element
    Then the element appears exactly once in the structured result
    And existing deduplication and attribution semantics remain unchanged

  Scenario: Multiple elements preserve ordering and failure semantics
    Given stock macOS Bash 3.2 with set -euo pipefail active
    And a production guard path that records multiple distinct elements
    When the state-transition guard emits its structured result
    Then every element appears in existing order without duplication
    And genuine failures remain blocking
    And restoring any raw zero-state expansion makes the adversarial regression fail
```

## Outcome Contract

- **Intent:** Make all normal zero, one, and multiple indexed-array states
  executable under Bash 3.2 nounset without weakening strict mode.
- **Success Signal:** The final persistent regression runs the production guard
  under `/bin/bash` 3.2, covers every identified family, emits complete
  structured results, and detects reintroduced raw zero-state expansions.
- **Hard Constraints:** Preserve `set -euo pipefail`, current result schema,
  ordering, deduplication, Check 8 behavior, failure exits, and ownership
  boundaries.
- **Failure Condition:** Any valid empty state still aborts; a real finding is
  suppressed; result fields drift; nounset is disabled; or protected sibling,
  release, test, or downstream bytes are modified by a non-owner.

## Release Train

Target train: `framework-next`. No feature flag is introduced. Release and
downstream identity remain unchanged during intake.

## Non-Goals

- Removing or weakening nounset.
- Requiring Homebrew Bash or Bash 4+.
- Changing BUG-019 Check 8 parsing.
- Repairing BUG-020 or BUG-021 in this packet.
- Editing generated release metadata or downstream installed framework bytes.
- Broadly refactoring the state-transition guard.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
