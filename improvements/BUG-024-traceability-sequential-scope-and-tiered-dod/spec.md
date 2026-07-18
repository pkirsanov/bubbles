# Expected Behavior: BUG-024 Traceability Sequential Scope And Tiered DoD

## Problem Contract

Traceability must distinguish an active sequential scope closure from a final
feature-wide audit, and its DoD parser must honor nested heading depth. A scope
that has completed its own traceability obligations must not be blocked by
honestly not-started descendants, while no final or otherwise applicable scope
gap may disappear.

This artifact specifies behavior only. It makes no implementation, test,
release, installed-byte, downstream, or certification claim.

## Actors

| Actor | Goal | Authority boundary |
| --- | --- | --- |
| Scope implementation owner | Close the current sequential scope using only applicable traceability obligations. | Cannot choose arbitrary ignored scopes or rewrite state. |
| Planning owner | Define scope identity, dependencies, scenarios, Test Plan rows, and tiered DoD. | Owns planning artifacts; does not produce execution evidence. |
| Feature validator | Prove the complete feature is traceable before promotion. | Must run all-scope semantics and cannot use active-scope filtering. |
| Done-spec auditor | Recheck completed packets without execution-state shortcuts. | Uses existing all-scope behavior. |
| Canonical release owner | Deliver validated framework bytes to consumers. | Cannot edit downstream managed copies directly. |

## Use Cases

### UC-024-001 Close One Sequential Scope

- **Preconditions:** A valid state names one current scope with status
  `in_progress` or `blocked`; every declared prerequisite is completed; one or
  more exact `not_started` scopes transitively depend on the current scope.
- **Main flow:** The caller requests state-bound active-scope traceability. The
  guard validates state and the filesystem scope registry, checks the current
  scope, completed prerequisites, and other presently applicable scopes, and
  records which not-started descendants were outside this closure context.
- **Postcondition:** Gaps in omitted descendants do not affect this scope's
  exit, but no gap in the applicable set is hidden.

### UC-024-002 Validate The Complete Feature

- **Preconditions:** A validator, auditor, done-spec audit, or direct operator
  invokes the existing one-argument guard or explicit all-scope context.
- **Main flow:** Every resolved scope participates in G057/G059, delivery
  traceability, and G068.
- **Postcondition:** Any scope gap produces the existing nonzero aggregate
  verdict, regardless of active execution state.

### UC-024-003 Parse A Tiered Definition Of Done

- **Preconditions:** A scope has an accepted level-2 or level-3 DoD heading,
  one or more deeper tier headings, and checkbox items beneath those tiers.
- **Main flow:** The parser remembers the selected heading depth, retains
  deeper headings and their checkboxes, and stops at the next heading of the
  same or a shallower depth.
- **Postcondition:** G068 receives the complete in-section checkbox set and no
  checkbox from a later sibling section.

## Requirements

### BR-024-001 Preserve Default All-Scope Semantics

`bash bubbles/scripts/traceability-guard.sh <feature-dir>` must remain an
all-scope invocation. The default must not infer active-scope filtering from a
dirty, stale, or partially populated state file.

### BR-024-002 Explicit State-Bound Active-Scope Context

The guard may add one closed context such as `--current-scope`, but it must
derive the selected scope from `state.json.execution.currentScope`. The caller
must not supply a scope ID, scope path, status, dependency list, ignored path,
or allowlist.

### BR-024-003 Closed State Validation

Active-scope context must require a readable valid JSON state with:

- one unambiguous current scope;
- a complete scope registry whose paths exactly match resolved scope units;
- statuses from the closed scope set `not_started`, `in_progress`, `blocked`,
  and `done`;
- dependency references that resolve to unique scope entries;
- no dependency cycle;
- current status `in_progress` or `blocked`; and
- completed-prerequisite state consistent with completion metadata.

Missing, malformed, duplicate, unknown, cyclic, contradictory, or
filesystem-divergent state must exit nonzero with a state-qualified diagnostic.
It must not fall back to all scopes, one scope, or zero scopes.

### BR-024-004 Narrow Descendant Omission

During active-scope closure, a scope may be omitted only when all of these are
true:

1. its status is exactly `not_started`;
2. it is a transitive dependency descendant of the current scope; and
3. it is not listed as completed, active, or otherwise applicable.

`not_started` alone is insufficient. An independent or already eligible scope
is not silently removed.

### BR-024-005 Applicable Scope Set

The active-scope set must contain:

- the current scope;
- every completed scope;
- every prerequisite of the current scope; and
- every resolved scope that does not satisfy BR-024-004.

A gap in any member of this set remains blocking.

### BR-024-006 Final Promotion Remains All-Scope

Validation, audit, finalize, done-spec audit, and terminal promotion must use
all-scope semantics. A request for active-scope context while state identifies
a final validation/audit phase or a terminal certification state must refuse
rather than reduce the scope set.

### BR-024-007 One Applicability Universe For Every Pass

The same validated scope set must feed:

- scope-defined scenario counting;
- G057/G059 scenario-manifest linkage for applicable scenario IDs;
- scenario-to-Test-Plan mapping;
- concrete test-path and report-evidence checks; and
- G068 scenario-to-DoD fidelity.

No pass may independently rediscover all filesystem scopes after applicability
has been resolved.

### BR-024-008 Manifest Subset Integrity

Active-scope context must validate every applicable scenario against its exact
manifest entry, linked test, and evidence references. Extra manifest entries
for omitted descendants may remain present but cannot substitute for a missing
applicable entry. All-scope context validates the complete manifest as today.

### BR-024-009 Heading-Aware DoD Extraction

The accepted DoD starts are level 2 and level 3 headings whose title is the
canonical `Definition of Done` or `DoD` form, including established suffixes
such as `- Tiered Validation`. A selected heading at depth `D` ends at the next
valid ATX heading with depth less than or equal to `D`.

### BR-024-010 Nested Tier Preservation

Headings deeper than the selected DoD heading remain inside the section. For a
level-2 DoD, level-3 through level-6 tiers remain eligible. For a level-3 DoD,
level-4 through level-6 tiers remain eligible.

### BR-024-011 Checkbox And Boundary Integrity

The extractor must preserve current checked and unchecked checkbox text for
G068 matching. It must exclude checkbox examples inside fenced code or HTML
comments and must exclude checkboxes under the next sibling or ancestor
section.

### BR-024-012 Missing And Ambiguous DoD Fail Loud

A scope with Gherkin scenarios and no accepted DoD, no in-section checkbox, or
ambiguous accepted DoD sections must produce one scope-qualified failure and
reach the normal final summary. Parser failure must not be represented as an
empty successful section.

### BR-024-013 Single-File Compatibility

Existing single-file `scopes.md` packets retain all-scope behavior. If
active-scope context is supported for single-file layout, the guard must map
the state scope identity to exactly one split analysis unit; ambiguity or
missing identity fails loud. A single-file packet cannot be partially filtered
by line-number guesswork.

### BR-024-014 No-Scenario Integrity

An applicable scope with no Gherkin scenario continues to emit the existing
no-scenario failure. A correctly omitted not-started descendant does not create
a no-scenario failure during active-scope closure. All-scope execution checks
that descendant and retains the existing failure.

### BR-024-015 No Bypass Surface

The repair must add no skip, ignore, force, allow-once, arbitrary scope, path
pattern, status override, permissive fallback, or environment-variable escape.
Unknown arguments and unknown status values fail.

### BR-024-016 Cross-Platform Contract

Production and regression behavior must run under macOS system Bash 3.2 and
supported Linux Bash. Structured state parsing must use a real JSON parser.
Shell must avoid associative arrays, namerefs, `mapfile`, raw GNU-only forms,
and three-argument `awk match`.

### BR-024-017 Canonical Delivery Only

Source and tests land only in the canonical Bubbles repository. Research Lab
receives changed managed bytes only through supported release/install/upgrade
ownership after canonical validation.

## Acceptance Scenarios

```gherkin
Feature: Trace applicable sequential scopes and complete tiered DoD sections

  Scenario: SCN-BUG-024-001 active closure omits only not-started descendants
    Given a complete multi-scope packet has one blocked current scope
    And later not-started scopes transitively depend on that current scope
    When the production guard runs in state-bound active-scope context
    Then the current scope and completed prerequisites are checked
    And not-started descendants do not block that scope closure

  Scenario: SCN-BUG-024-002 completed prerequisites remain blocking when incomplete
    Given the current scope depends on a scope recorded as completed
    And that completed prerequisite has a real traceability gap
    When active-scope traceability runs
    Then the prerequisite gap blocks the result

  Scenario: SCN-BUG-024-003 all-scope and newly applicable scopes retain every gap
    Given a not-started descendant contains a traceability gap
    When all-scope traceability runs or that scope becomes active or completed
    Then the descendant gap blocks the result

  Scenario: SCN-BUG-024-004 malformed applicability state fails loud
    Given active-scope context receives missing malformed contradictory or unknown scope state
    When the production guard resolves applicability
    Then it emits a state-qualified refusal and analyzes no permissive fallback set

  Scenario: SCN-BUG-024-005 single-file and no-scenario behavior remain compatible
    Given a single-file packet or an applicable scope without scenarios
    When the production guard runs in its supported context
    Then single-file all-scope mapping remains unchanged
    And an applicable no-scenario scope reaches its existing diagnostic

  Scenario: SCN-BUG-024-006 a level-2 DoD retains nested tier headings
    Given a level-2 Definition of Done contains level-3 and level-4 tiers
    When G068 extracts checkbox items
    Then every in-section tier checkbox remains eligible
    And the next level-2 section is excluded

  Scenario: SCN-BUG-024-007 a level-3 DoD retains level-4 tiers
    Given a level-3 Definition of Done contains level-4 tier headings
    When G068 extracts checkbox items
    Then every in-section tier checkbox remains eligible
    And the next level-3 or level-2 section is excluded

  Scenario: SCN-BUG-024-008 BUG-018 Test Plan behavior remains unchanged
    Given the BUG-018 heading-depth regression remains byte-identical
    When the repaired traceability guard and existing regression execute
    Then level-2 and level-3 Test Plan behavior remains green
```

## Measurable Acceptance Criteria

| ID | Required measurement |
| --- | --- |
| MAC-024-001 | The active fixture checks current plus completed/applicable scopes and emits zero findings from exact not-started descendants. |
| MAC-024-002 | A completed-prerequisite gap and a current-scope gap each produce a nonzero verdict. |
| MAC-024-003 | Default/all-scope, active descendant, and completed descendant fixtures each expose the same seeded descendant gap. |
| MAC-024-004 | Every malformed/unknown/contradictory state vector exits nonzero before scope traceability and emits no pass. |
| MAC-024-005 | Level-2 and level-3 DoD fixtures extract identical intended checkbox IDs and zero sibling-section IDs. |
| MAC-024-006 | Applicable no-scenario fixtures fail; omitted descendant no-scenario fixtures do not affect active closure; all-scope still fails them. |
| MAC-024-007 | Existing BUG-018 regression remains unchanged and green. |
| MAC-024-008 | The focused matrix behaves equivalently under macOS Bash 3.2 and supported Linux Bash. |

## Outcome Contract

- **Intent:** Permit honest sequential scope closure without weakening final
  traceability or DoD fidelity.
- **Success Signal:** MAC-024-001 through MAC-024-008 pass using the real
  production guard and complete disposable packets.
- **Hard Constraints:** Default all-scope behavior; state-derived current scope;
  narrow descendant omission; fail-loud malformed state; heading-aware DoD;
  no bypass; no copied production helper in tests; Bash 3.2/Linux portability;
  canonical-only delivery.
- **Failure Condition:** The repair fails if any current/completed/applicable
  gap disappears, any final all-scope gap is hidden, any malformed state is
  treated permissively, any tier checkbox is lost, any sibling checkbox leaks,
  or BUG-018 behavior regresses.

## Release Train

Target train: `framework-next`. No feature flag is introduced.

## Non-Goals

- Rewriting Research Lab Feature 007 planning or evidence artifacts.
- Reopening BUG-018 or modifying its regression.
- Relaxing scenario matching, linked-file existence, report evidence, or G068
  fuzzy fidelity thresholds.
- Adding arbitrary per-scope ignore controls.
- Replacing all Markdown parsing with a new external dependency.
- Claiming delivery or validation from this intake packet.
