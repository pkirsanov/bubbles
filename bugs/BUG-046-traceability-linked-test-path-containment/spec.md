# Specification: BUG-046 Traceability Linked-Test Path Containment

## Problem Statement

The traceability guard accepts manifest-controlled linked-test references as
filesystem candidates. It checks candidate paths for regular-file existence
without first proving canonical repository containment.

The BUG-045 security review demonstrated a terminal false pass with
`../../../../etc/hosts`. An external regular file satisfied a required test
edge. The pass or fail result also disclosed whether the selected host path
existed.

## Parent Finding Trace

| Field | Value |
| --- | --- |
| Finding | `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` |
| Severity | High |
| Source | [BUG-045 security defensive review](../BUG-045-traceability-empty-evidence-refs/report.md#security-defensive-review---2026-09-02t150152z) |
| Source evidence | Tool-log row 579, full-output SHA-256 `130672ed8b1baf561ce11515fc79e1cbd666b40ea1477bffaa1680f8c8e9096c` |
| Observed result | An external regular file satisfied a linked-test edge and the guard returned `RESULT: PASSED`. |
| Current disposition | Unresolved until implementation and independent verification satisfy this specification. |

This specification inherits the finding without restating its prior execution
as current-session evidence.

## Outcome Contract

**Intent:** Every linked-test edge must identify a regular test file contained
within the repository. Repository-controlled text must never use host files to
satisfy traceability.

**Success Signal:** The guard accepts existing valid relative references. It
rejects every unsafe reference class without revealing external file state or
contents.

**Hard Constraints:**

- Only a canonical target inside the canonical repository root may count.
- The canonical target must be a regular file.
- Parent traversal, absolute paths, symlink escapes, empty references, and
  control-bearing references must fail closed.
- Recorded reference text remains inert data.
- Invalid-reference diagnostics reveal no external contents, metadata, or
  existence result.
- Existing valid relative reference forms keep their current meaning.

**Failure Condition:** The feature fails if any external target satisfies a
linked-test edge. It also fails if valid relative references regress or an
invalid reference exposes external state.

## Goals

- Define one deterministic acceptance contract for every projected linked-test
  reference.
- Close lexical traversal and canonical symlink escape paths.
- Remove the external file-existence oracle from invalid-reference diagnostics.
- Preserve accepted repository-relative and feature-relative references.
- Produce stable behavior on supported macOS and Linux environments.

### Single-Capability Justification

BUG-046 tightens one existing linked-test validation capability. It adds no
provider, adapter, strategy, screen, service, or reusable domain surface.

## Actors And Use Cases

### Actor: Repository Maintainer

The maintainer records scenario-to-test links and expects valid relative paths
to remain portable across repository locations.

### Actor: Traceability Consumer

The consumer relies on the guard verdict before accepting scenario evidence.
The consumer must not receive a false pass from unrelated host state.

### UC-B046-001: Record A Valid Linked Test

- **Precondition:** The repository contains the referenced regular test file.
- **Main flow:** The maintainer records an accepted relative reference form.
- **Outcome:** The guard counts the linked-test edge without rewriting the
  recorded path.

### UC-B046-002: Reject An Unsafe Reference

- **Precondition:** A manifest records a prohibited or escaping reference.
- **Main flow:** The consumer evaluates the packet through the traceability
  guard.
- **Outcome:** The guard returns a failing verdict and does not count the edge.

### UC-B046-003: Diagnose Without External Disclosure

- **Precondition:** An invalid reference could name an external host target.
- **Main flow:** The consumer compares the guard result for present and absent
  external targets.
- **Outcome:** Both results use the same rejection class and reveal no external
  contents or existence state.

## Linked-Test Reference Contract

### Accepted References

A linked-test reference counts only when every condition below holds:

1. The extracted path is a non-empty relative path.
2. No path component is exactly `..`.
3. The path contains no control character.
4. Resolution starts from an existing repository or feature reference base.
5. The canonical target remains inside the canonical repository root.
6. The canonical target is a regular file.

A symlink may count only when its canonical target satisfies the same
containment and regular-file rules.

### Rejected References

The guard must reject a prohibited reference before counting its linked-test
edge. The prohibited classes appear below.

- Reject an empty or whitespace-only extracted path.
- Reject a value containing `U+0000` through `U+001F`, or `U+007F`.
- Reject a path with any parent component.
- Reject a POSIX-rooted path.
- Reject a drive-qualified or UNC-style absolute path.
- Reject a symlink whose canonical target leaves the repository.
- Reject a missing target.
- Reject a directory, device, socket, pipe, or other non-regular target.

## Requirements

### Functional Requirements

- **FR-B046-001:** The guard must treat each manifest reference as inert data.
- **FR-B046-002:** The guard must retain accepted string references and object
  references that use the existing file or path member.
- **FR-B046-003:** The guard must retain the existing fragment-suffix behavior
  before validating the extracted path.
- **FR-B046-004:** The guard must reject empty, whitespace-only, control-bearing,
  parent-traversing, and absolute references.
- **FR-B046-005:** Absolute-path detection must cover POSIX, drive-qualified,
  and UNC-style forms on every supported host.
- **FR-B046-006:** The guard must compare canonical targets against the
  canonical repository root.
- **FR-B046-007:** A textual prefix match must not establish containment.
- **FR-B046-008:** A symlink escape must fail even when its target is an
  existing regular file.
- **FR-B046-009:** An in-repository symlink to an in-repository regular file
  may retain its existing accepted behavior.
- **FR-B046-010:** A missing or non-regular target must not satisfy a linked-test
  edge.
- **FR-B046-011:** Any rejected linked-test reference must make the traceability
  verdict fail.
- **FR-B046-012:** Invalid-reference diagnostics must identify the rejection
  class without exposing an external target's state, metadata, or contents.
- **FR-B046-013:** Present and absent external targets must not produce an
  existence-sensitive distinction.
- **FR-B046-014:** Repository-relative and feature-relative references that
  satisfy this contract must remain accepted as recorded.
- **FR-B046-015:** All-scope and current-scope evaluation must enforce the same
  reference contract.

### Non-Functional Requirements

- **NFR-B046-001 Security:** Repository data must not expand the guard's trust
  boundary beyond the repository root.
- **NFR-B046-002 Portability:** Supported macOS and Linux hosts must classify
  the same reference text identically.
- **NFR-B046-003 Determinism:** Invalid-reference results must not depend on
  unrelated host filesystem contents.
- **NFR-B046-004 Compatibility:** The repair must preserve valid reference
  forms, resolution bases, and fragment handling.
- **NFR-B046-005 Privacy:** Diagnostics must not read or print external file
  contents.

## User Scenarios (Gherkin)

```gherkin
Feature: Contained linked-test references

  Scenario: SCN-B046-001 Valid relative references remain accepted
    Given a scenario links an existing in-repository regular test file
    And the reference uses an accepted repository-relative or feature-relative form
    When the traceability guard evaluates the packet
    Then the linked-test edge counts as present
    And the recorded relative path does not require rewriting

  Scenario: SCN-B046-002 Parent traversal is rejected without an existence oracle
    Given two references contain a parent path component
    And one resolves to an existing external regular file while the other does not
    When the traceability guard evaluates each packet
    Then both linked-test edges are rejected
    And neither diagnostic reveals whether the external target exists

  Scenario: SCN-B046-003 Absolute path forms are rejected on every supported host
    Given references use POSIX, drive-qualified, or UNC-style absolute forms
    When the traceability guard evaluates each reference
    Then every linked-test edge is rejected
    And no absolute target is inspected for acceptance

  Scenario: SCN-B046-004 A symlink escape cannot satisfy a linked-test edge
    Given an in-repository reference names a symlink to an external regular file
    When the traceability guard evaluates the packet
    Then the linked-test edge is rejected
    And the external target contributes no successful traceability result

  Scenario: SCN-B046-005 An internal symlink retains contained behavior
    Given an in-repository reference names a symlink to an in-repository regular test file
    When the traceability guard evaluates the packet
    Then the canonical target remains contained
    And the linked-test edge may count as present

  Scenario: SCN-B046-006 Empty and control-bearing references fail closed
    Given linked-test references are empty, whitespace-only, or contain control characters
    When the traceability guard evaluates each packet
    Then every linked-test edge is rejected
    And control-bearing text is not reproduced as an active terminal sequence

  Scenario: SCN-B046-007 Non-regular and missing targets do not count
    Given relative references name a missing target and each non-regular target class
    When the traceability guard evaluates each packet
    Then every linked-test edge is rejected
    And the packet receives a failing traceability verdict

  Scenario: SCN-B046-008 Command-shaped reference text remains inert
    Given a linked-test reference contains command-shaped or substitution-shaped text
    When the traceability guard evaluates the packet
    Then no recorded text executes
    And no side effect named by that text occurs

  Scenario: SCN-B046-009 Existing projection modes retain one path contract
    Given valid string and object references use the existing fragment behavior
    When all-scope and current-scope evaluation inspect those references
    Then both modes apply the same containment and regular-file rules
    And each valid relative reference keeps its existing accepted meaning
```

## Acceptance Criteria

- **AC-B046-001 / SCN-B046-001:** Accepted repository-relative and
  feature-relative references still count without manifest rewrites.
- **AC-B046-002 / SCN-B046-002:** Parent traversal fails for both present and
  absent external targets with no existence-sensitive result.
- **AC-B046-003 / SCN-B046-003:** POSIX, drive-qualified, and UNC-style absolute
  references fail on macOS and Linux.
- **AC-B046-004 / SCN-B046-004:** An external symlink target never counts as a
  linked-test edge.
- **AC-B046-005 / SCN-B046-005:** A contained symlink target remains eligible
  when it resolves to an in-repository regular test file.
- **AC-B046-006 / SCN-B046-006:** Empty, whitespace-only, and control-bearing
  references fail without active terminal control output.
- **AC-B046-007 / SCN-B046-007:** Missing and non-regular targets produce a
  failing verdict.
- **AC-B046-008 / SCN-B046-008:** Command-shaped text causes no execution or
  named side effect.
- **AC-B046-009 / SCN-B046-009:** String, object, fragment, all-scope, and
  current-scope compatibility remains intact.
- **AC-B046-010:** Rejection diagnostics expose no external file contents,
  metadata, canonical external location, or existence result.
- **AC-B046-011:** Persistent regression coverage must kill a mutation that
  restores regular-file existence checks without canonical containment.
- **AC-B046-012:** The repair must stay within the declared BUG-046 work
  boundary.

## Compatibility

- Existing repository-relative and feature-relative resolution bases remain
  valid.
- Existing string and object reference forms remain valid.
- Existing fragment suffixes retain their extraction behavior.
- Existing valid in-repository regular files remain accepted.
- Invalid references now fail where they could previously pass.
- Evidence-reference cardinality and scenario-envelope behavior do not change.

## Portability

- Reference classification must match on supported macOS and Linux hosts.
- Cross-platform absolute forms must fail regardless of native host syntax.
- Canonical containment must follow filesystem links before acceptance.
- The result must not depend on whether a known external host file exists.

## Non-Goals

- This bug does not change `evidenceRefs` cardinality validation.
- This bug does not change scenario-manifest envelope support.
- This bug does not change scenario-to-scope projection policy.
- This bug does not determine whether file contents constitute a useful test.
- This bug does not execute, parse, or disclose referenced file contents.
- This analyst phase does not modify guard source or regression tests.

## Exposure Contract

| Capability | Surface class | Surface id | Status | Plan |
| --- | --- | --- | --- | --- |
| traceability linked-test validation | cliCommand | `bash bubbles/scripts/traceability-guard.sh <feature-dir>` | delivered | BUG-046 tightens the existing surface contract. |

## Plan-Owned Acceptance Template Requirements

`bubbles.plan` owns `uservalidation.md`. The initial checklist must ship checked
under the opt-out acceptance contract. The baseline outcomes appear below.

- Valid relative linked-test references retain their accepted behavior.
- Unsafe or escaping references never satisfy traceability.
- Recorded reference text remains inert.
- Diagnostics reveal no external contents or existence state.

The template must separate automation readiness from the optional human
acceptance record.

## Artifact Routing

- `bubbles.design` must define the technical containment and diagnostic design.
- `bubbles.plan` must author scopes, scenario contracts, tests, and the checked
  `uservalidation.md` template.
- The inherited High finding remains unresolved through these planning phases.
