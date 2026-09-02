# Scopes: BUG-046 Traceability Linked-Test Path Containment

Planning sources: [spec.md](spec.md), [design.md](design.md), [report.md](report.md), and [uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Scope 01: Atomic linked-test path validation** implements one shared acceptance decision for all nine scenarios.
2. The scope preserves repository-first and feature-second candidate resolution.
3. The scope validates lexical safety before any filesystem query.
4. The scope resolves symlinks before applying component-boundary containment.
5. The scope retains the final regular-file predicate after containment succeeds.
6. The scope emits classed diagnostics that disclose no external filesystem state.
7. The scope preserves string, object, fragment, envelope, and scope-mode compatibility.
8. The scope adds persistent functional cases before changing the guard.
9. The scope proves non-vacuity with a mutation that disables containment only.
10. The scope completes only after focused and framework regression checks pass.

### New Types And Signatures

- Public CLI remains `bash bubbles/scripts/traceability-guard.sh <feature-dir> [--all-scopes|--current-scope]`.
- Projection emits JSON Lines records shaped as `{ordinal, field, form, path}`.
- Lexical classification returns one closed acceptance or rejection class.
- Canonical resolution accepts a canonical base and one lexically safe relative path.
- Canonical resolution returns a safe status and a canonical target only on success.
- Failure diagnostics expose the ordinal, rejection class, and permitted relative display text.
- No persistent schema, configuration key, dependency, or public argument changes.

### Validation Checkpoints

- Checkpoint A runs each scenario-first case against the unchanged guard and records expected failures.
- Checkpoint B runs the focused selftest after the shared validator is implemented.
- Checkpoint C runs the containment-disabled mutation while preserving regular-file checks.
- Checkpoint D runs system-Bash portability cases for cross-host classifications.
- Checkpoint E runs artifact, scenario, traceability, reference, prose, and diff checks.
- Checkpoint F runs the complete framework validation before implementation handoff closes.

## Overview And Ordering Rationale

This plan uses one scope because all nine scenarios govern one atomic trust decision.
Splitting projection, lexical checks, containment, and diagnostics would create intermediate acceptance paths without complete security proof.
The scope stays small through a strict two-file implementation boundary and one focused selftest owner.

| Scope | Name | Surfaces | Planned Tests | DoD Summary | Status |
| --- | --- | --- | --- | --- | --- |
| 01 | Atomic linked-test path validation | Guard CLI, hermetic shell regression suite | 9 scenario cases, disclosure case, containment mutation, portability, framework regression | One contained regular-file decision with compatibility and non-disclosure proof | In Progress |

## Scope 01: Atomic Linked-Test Path Validation

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends On:** None
**Finding:** `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` remains unresolved.
**Next Owner:** `bubbles.test`

### Intent Trace

This scope implements the Outcome Contract in [spec.md](spec.md#outcome-contract).
It satisfies `FR-B046-001` through `FR-B046-015` and `NFR-B046-001` through `NFR-B046-005`.

### Gherkin Scenarios

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

### Change Boundary

#### Allowed Implementation Files

- `bubbles/scripts/traceability-guard.sh`.
- `bubbles/scripts/traceability-guard-selftest.sh`.

#### Excluded Surfaces

- Every other source file and test file.
- Other bug directories and shared indexes.
- Git state, repository history, generated release metadata, and host state.
- Scenario matching, evidence cardinality, scope selection, and report validation behavior.

The implementation must report any required change outside this boundary before editing that surface.

### Shared Infrastructure Impact Sweep

The guard is a shared framework validation surface with existing all-scope and current-scope consumers.
Preserve its CLI arguments, exit meanings, count reporting, projection selection, and valid reference forms.
Use the existing clean and current-scope selftest fixtures as independent compatibility canaries.
Run the complete framework validation after focused cases pass.
Rollback must revert the guard and BUG-046 selftest additions together.
Rollback restores the inherited High finding to an unresolved vulnerable state.

### Consumer Impact Sweep

No route, path, contract identifier, command name, or UI target is renamed or removed.
Compatibility checks still cover repository-relative, feature-relative, string, object, fragment, object-envelope, and legacy-envelope consumers.

### Implementation Plan

1. Add failing scenario-first cases to `bubbles/scripts/traceability-guard-selftest.sh` for every `SCN-B046-*` contract.
2. Add paired present and absent external targets for diagnostic non-disclosure checks.
3. Add a bounded mutation that removes containment while leaving final regular-file checks intact.
4. Canonicalize the selected repository root and require the feature directory to remain inside it.
5. Project supported references as JSON Lines records without decoding unsafe text into shell variables.
6. Apply the specified lexical precedence before joining the path to either candidate base.
7. Resolve symlinks with portable shell primitives and enforce the 40-hop bound.
8. Check component-boundary containment before the final regular-file predicate.
9. Repeat canonical resolution immediately before counting an accepted linked-test edge.
10. Emit fixed rejection classes without external paths, metadata, contents, or existence-sensitive distinctions.
11. Run focused, portability, mutation, planning, traceability, and framework validation checkpoints.

### Test Plan

`Live System: No` denotes hermetic child-process execution with no deployed service or host.
Each row still executes the production guard through its public CLI.

| ID | DoD Ref | Scenario ID | Type | Category | File | Expected Test Title | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TP-B046-001 | `DOD-B046-T01` | `SCN-B046-001` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 accepts repository-relative and feature-relative regular files without rewrites` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-002 | `DOD-B046-T02` | `SCN-B046-002` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 rejects present and absent parent traversal with one non-disclosing class` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-003 | `DOD-B046-T03` | `SCN-B046-003` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 rejects POSIX drive-qualified and UNC absolute forms under both Bash paths` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-004 | `DOD-B046-T04` | `SCN-B046-004` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 rejects present and absent external symlink targets without target disclosure` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-005 | `DOD-B046-T05` | `SCN-B046-005` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 accepts a contained regular-file symlink and rejects an internal directory link` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-006 | `DOD-B046-T06` | `SCN-B046-006` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 rejects empty whitespace and control-bearing references without terminal control output` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-007 | `DOD-B046-T07` | `SCN-B046-007` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 rejects missing directory FIFO and Unix-socket targets` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-008 | `DOD-B046-T08` | `SCN-B046-008` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 keeps substitution backtick variable wildcard and separator text inert` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-009 | `DOD-B046-T09` | `SCN-B046-009` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 preserves candidate-root form fragment envelope and scope-mode compatibility` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-010 | `DOD-B046-T10` | `SCN-B046-002`, `SCN-B046-004`, `SCN-B046-006` | functional | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 diagnostics disclose no external existence path metadata contents or control bytes` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |
| TP-B046-011 | `DOD-B046-T11` | `SCN-B046-002`, `SCN-B046-004` | mutation | functional | `bubbles/scripts/traceability-guard-selftest.sh` | `BUG-046 containment-disabled regular-file-preserving mutation is killed` | `bash bubbles/scripts/traceability-guard-selftest.sh` | No |

### Scenario Obligation Summary

| Scenario | Behavior Traits | Required Proof | Planned Mechanism |
| --- | --- | --- | --- |
| `SCN-B046-001` | `dependency-path` | Real candidate resolution and accepted result | Production CLI, ephemeral repository, returned verdict |
| `SCN-B046-002` | `degraded-state`, `dependency-path` | Named rejection plus paired filesystem states | Production CLI, ephemeral repository, returned verdict and diagnostic |
| `SCN-B046-003` | `degraded-state`, `pure-calculation` | Host-independent lexical rejection | Production CLI, synthetic path forms, returned verdict |
| `SCN-B046-004` | `degraded-state`, `dependency-path` | Physical symlink boundary rejection | Production CLI, ephemeral repository, returned verdict and diagnostic |
| `SCN-B046-005` | `dependency-path` | Contained symlink success and non-regular refusal | Production CLI, ephemeral repository, returned verdict |
| `SCN-B046-006` | `degraded-state`, `pure-calculation` | Escaped lexical rejection with inert output | Production CLI, synthetic JSON references, returned verdict and bytes |
| `SCN-B046-007` | `degraded-state`, `dependency-path` | Missing and non-regular target refusal | Production CLI, ephemeral repository, returned verdict |
| `SCN-B046-008` | `degraded-state` | No execution and no named side effect | Production CLI, adversarial path text, returned verdict and sentinel state |
| `SCN-B046-009` | `dependency-path` | Equivalent validation across current supported forms | Production CLI, ephemeral repository, returned verdict and projection counts |

### Definition of Done — Tiered Validation

#### Core Items

- [x] `DOD-B046-001` One shared acceptance decision validates every projected linked-test reference. → Evidence: [focused RED and GREEN evidence](report.md#focused-red-and-green-evidence)
- [x] `DOD-B046-002` The canonical repository and feature roots remain physically contained before manifest evaluation. → Evidence: [focused RED and GREEN evidence](report.md#focused-red-and-green-evidence)
- [x] `DOD-B046-003` Lexical failures occur before any filesystem query for the submitted reference. → Evidence: [focused RED and GREEN evidence](report.md#focused-red-and-green-evidence)
- [x] `DOD-B046-004` Symlink resolution enforces component boundaries, a 40-hop limit, and final stability. → Evidence: [focused RED and GREEN evidence](report.md#focused-red-and-green-evidence)
- [x] `DOD-B046-005` Rejection diagnostics disclose no external path, state, metadata, contents, or active control bytes. → Evidence: [focused RED and GREEN evidence](report.md#focused-red-and-green-evidence)
- [x] `DOD-B046-006` The implementation changes only the two allowed files and preserves every excluded surface. -> Evidence: [final bookkeeping and boundary evidence](report.md#final-bookkeeping-and-boundary-evidence)
- [x] `DOD-B046-007` The parent finding remains unresolved until implementation and independent verification complete. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)

#### Test Evidence Items

- [x] `DOD-B046-T01` `TP-B046-001` proves `SCN-B046-001` through the expected scenario-first case. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T02` `TP-B046-002` proves `SCN-B046-002` through paired traversal states. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T03` `TP-B046-003` proves `SCN-B046-003` across POSIX, drive-qualified, and UNC forms. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T04` `TP-B046-004` proves `SCN-B046-004` through present and absent external symlink targets. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T05` `TP-B046-005` proves `SCN-B046-005` through regular-file and directory symlink controls. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T06` `TP-B046-006` proves `SCN-B046-006` without reproducing active control output. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T07` `TP-B046-007` proves `SCN-B046-007` across missing and creatable non-regular targets. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T08` `TP-B046-008` proves `SCN-B046-008` through a named side-effect sentinel. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T09` `TP-B046-009` proves `SCN-B046-009` across both candidate roots and projection modes. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T10` `TP-B046-010` proves diagnostic non-disclosure across paired invalid-reference classes. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)
- [x] `DOD-B046-T11` `TP-B046-011` kills the containment-disabled mutation while regular-file checks remain active. -> Evidence: [independent test verification](report.md#independent-test-verification---2026-09-02)

#### Build Quality Gate

- [ ] `DOD-B046-BQ1` Shell syntax, portability, focused regression, framework regression, artifact, scenario, traceability, reference, prose, and diff checks pass with current-session evidence.
  > **Uncertainty Declaration**
  > **What was attempted:** Both Bash selftests, syntax, warning-level ShellCheck, portability, mutation, scenario, artifact, traceability, reference, prose, diff, and boundary checks were selected. Broad `framework-validate` and `release-check` were not run because the operator prohibited them for this invocation.
  > **What was observed:** Every permitted focused check passed against the implementation final epoch. The independent test evidence is in [report.md](report.md#independent-test-verification---2026-09-02).
  > **Why this is uncertain:** This DoD item explicitly includes framework regression, and this test phase has no permitted current-session execution of that broader command.
  > **What would resolve this:** `bubbles.regression` records a successful framework-regression receipt for the current final artifact bytes.

### Completion And Routing

Scope 01 stays `In Progress` until the remaining build-quality evidence is recorded.
Top-level status and certification stay `in_progress` throughout planning.
The inherited parent finding is `verified-ready-for-parent-consumption` inside BUG-046.
BUG-045's parent ledger remains unchanged.
The next required owner is `bubbles.regression`.
The next required target is Scope `01-atomic-linked-test-path-validation`.
