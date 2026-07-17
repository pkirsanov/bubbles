# Expected Behavior: BUG-012 G085 First-Adoption Bootstrap

## Problem Contract

G085 must prove downstream framework dogfooding without preventing a downstream repository from completing the first Bubbles-managed feature that creates the proof.

## Outcome Contract

**Author Intent:** Allow a genuinely first-adopted downstream repository to progress its first Bubbles-managed feature toward certification without turning zero current done states into a general exemption or changing the canonical source-repository evidence model.

**Success Signal:** G085 grants a distinct first-adoption pass only when a downstream repository has at least one valid current numbered feature state, no current or reachable historical numbered top-level done state, and complete, unambiguous repository-local lifecycle evidence; established repositories continue to pass only with current done evidence, while lost historical completion or indeterminate evidence produces a specific refusal.

**Hard Constraints:** Zero current done states alone never prove first adoption; missing, malformed, contradictory, incomplete, or indeterminate lifecycle evidence never grants the exception; any reachable historical numbered top-level done state keeps the repository subject to established-repository enforcement; canonical source-repository rules, read-only evaluation, and upstream-only framework propagation remain unchanged.

**Failure Condition:** The repair fails even if its process checks pass if G085 still blocks a proven first adoption, admits an established or ambiguous zero-done repository, overlooks reachable prior done evidence after the current state is changed or deleted, weakens the canonical source-repository evidence model, or mutates downstream framework-managed state.

## Actors

- A newly adopted downstream repository with no historical Bubbles completion.
- An established downstream repository with prior Bubbles lifecycle history.
- The canonical Bubbles source repository, whose separate no-`specs/` evidence model remains unchanged.

## Requirements

### BR-001 First-Adoption Recognition

The guard must recognize a genuinely first adopted downstream repository using explicit, repository-local framework adoption evidence rather than inferring first adoption solely from `doneCount=0` or from the number/status of current specs.

### BR-002 Bootstrap Passage

When explicit evidence proves the repository is in its first adoption cycle and no historical done spec exists, G085 must pass so the first feature can progress toward certification.

### BR-003 Established-Repository Enforcement

When the repository has historical adoption evidence beyond the first-adoption condition, G085 must continue requiring at least one numbered `specs/NNN-*/state.json` with top-level `status: done`.

### BR-004 Fail Closed

Missing, malformed, contradictory, or manually ambiguous adoption evidence must not silently grant the first-adoption exception. The guard must emit a specific diagnostic and preserve its existing malformed-input exit semantics.

### BR-005 Source Repository Invariance

The canonical Bubbles source repository must continue forbidding persistent `specs/` and proving G085 through framework validation, selftests, and release evidence.

### BR-006 Upgrade-Only Propagation

The fix must land only in the canonical Bubbles repository. Research Lab must receive it through the standard framework upgrade/install path after an upstream release or explicitly identified canonical revision; no direct edit or manual copy into `.github/bubbles/**` is permitted.

## Acceptance Scenarios

```gherkin
Feature: G085 downstream dogfood evidence during adoption

  Scenario: First adopted repository can complete its first feature
    Given a downstream repository has explicit framework evidence proving first adoption
    And it has numbered feature states but no historical done state
    When Gate G085 evaluates the repository
    Then Gate G085 passes with a first-adoption diagnostic
    And no downstream framework-managed file is mutated

  Scenario: Established repository cannot lose done-spec enforcement
    Given a downstream repository has evidence that adoption is already established
    And no numbered feature state has top-level status done
    When Gate G085 evaluates the repository
    Then Gate G085 fails with its dogfood-evidence diagnostic

  Scenario: Established repository with done history passes
    Given a downstream repository is established
    And at least one numbered feature state has top-level status done
    When Gate G085 evaluates the repository
    Then Gate G085 passes

  Scenario: Ambiguous bootstrap evidence fails closed
    Given a downstream repository has no done spec
    And its first-adoption evidence is absent, malformed, or contradictory
    When Gate G085 evaluates the repository
    Then the guard does not grant the bootstrap exception
    And the diagnostic identifies the required adoption evidence
```

## Non-Goals

- Exempting every repository with zero done specs.
- Treating `not_started`, `in_progress`, or a low numbered spec ID as proof of first adoption.
- Weakening the canonical source-repository no-`specs/` rule.
- Editing Research Lab's installed framework files directly.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
