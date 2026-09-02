# BUG-033 Scopes

## Execution Outline

### Phase Order

1. **Scope 1 — Receipt target grouping and wrapper normalization:** preserve honest repeated receipts while refusing genuine cross-command collisions.
2. **Scope 2 — Timeout grammar and session-lock boundary:** constrain trusted timeout normalization and prove the exact Git ignore boundary.

### New Types And Signatures

- No public API, schema, or persisted-data change.
- Check 43 retains its existing receipt input and diagnostic output contract.
- Timeout normalization accepts only the exact trusted wrapper grammar defined by the bug specification.

### Validation Checkpoints

- Scope 1 stops on focused receipt-identity or whole-guard functional regression failure.
- Scope 2 stops on focused timeout, whole-guard, or hermetic Git-classification regression failure.
- Independent `bubbles.test` re-verifies the final planning-to-test mapping before `bubbles.validate` may certify either scope.

## Test Plan

| ID | Scope | Test | Type | File/Surface |
| --- | --- | --- | --- | --- |
| T1 | Scope 1 | SCN-B033-001 facet 1 acceptance (9 re-runs, 2 targets) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T2 | Scope 1 | SCN-B033-002 facet 1 adversarial bound (2 identities, 1 target) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T3 | Scope 1 | SCN-B033-003 family probe over 6 spellings | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T4 | Scope 1 | Focused acceptance fixture over 5 equivalent recursively stripped wrapper spellings | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T5 | Scope 1 | SCN-B033-004 adversarial bound (cargo vs npm behind wrappers) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T6 | Scope 1 | BUG-007 + BUG-032 pins survive the relaxation | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T7 | Scope 1 | Whole-guard functional regression accepts re-runs and wrappers while refusing both adversarial shapes | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T8 | Scope 2 | SCN-B033-005 bare child, valid bare timeout, and valid bare gtimeout spellings normalize to one identity | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T9 | Scope 2 | SCN-B033-006 `timeout -v` normalizes to the child identity | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T10 | Scope 2 | SCN-B033-007 unknown, malformed, attached, clustered, incomplete, near-miss, path-qualified system, and attacker-controlled forms stay opaque | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T11 | Scope 2 | SCN-B033-008 different timeout-wrapped children sharing output still refuse | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T12 | Scope 2 | Whole-guard functional regression exercises accepted and opaque timeout forms | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T13 | Scope 2 | SCN-B033-009 regression — a hermetic Git fixture proves only the exact persistent flock path is ignored and rejects wildcard broadening | functional | `bubbles/scripts/state-snapshot-selftest.sh` |

## Scope 1 — Receipt Target Grouping And Wrapper Normalization

**Status:** In Progress

### Gherkin Scenarios

```gherkin
Scenario: SCN-B033-001 Repeated honest re-runs are not cloned evidence
  Given a tool-call log with 5 receipts of one validator over specs/alpha
    And 4 receipts of the same validator over specs/beta
    And all 9 receipts share one stdout hash because the validator never
        prints its subject
    And all 9 receipts carry distinct sessionId and ts pairs
  When Check 43 classifies the collision
  Then the group is accepted as deterministic siblings
    And no evidence receipt CLONE is reported

Scenario: SCN-B033-002 Two identities over one target are still refused
  Given a tool-call log with `npm run lint` and `npm run test`
    And both name specs/alpha as their target
    And both share one substantive stdout hash
  When Check 43 classifies the collision
  Then an evidence receipt CLONE is reported

Scenario: SCN-B033-003 Wrapper spellings resolve to one command family
  Given receipts spelled `node X`, `env P=1 node X`, `zsh -c node X`,
        `P=1 node X` and `bash -c node X`
  When Check 43 computes each command family
  Then every spelling resolves to command_family=node
    And no evidence receipt CLONE is reported for the group

Scenario: SCN-B033-004 Wrappers do not hide a genuine identity difference
  Given a receipt `zsh -c cargo test` and a receipt `env CI=1 npm run lint`
    And both share one substantive stdout hash
  When Check 43 classifies the collision
  Then an evidence receipt CLONE is reported
    And the diagnostic names family=cargo and family=npm
```

### Implementation Files

- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/receipt-identity-selftest.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`

### Implementation Plan

- `bubbles/scripts/state-transition-guard.sh` — Check 43 jq program:
  - group `$targets` by `cmd_identity` before the distinctness test (facet 1)
  - replace the single-token `bash`/`sh` strip with a recursive
    `strip_wrappers` covering shells with `-c`, `env`, and leading `VAR=value`
    assignments (facet 2)
- No other file changes behavior.

### Definition of Done

- [x] T1 / SCN-B033-001 proves that nine independently proven repeated receipts across two targets are accepted as deterministic siblings rather than clone evidence
      → Evidence: [report.md](report.md#facet-1)
- [x] T2 / SCN-B033-002 proves that two command identities sharing one target and one substantive stdout hash still produce an evidence receipt CLONE finding
      → Evidence: [report.md](report.md#bounds)
- [x] T3 / SCN-B033-003 proves that `node`, `env`, assignment, `zsh -c`, and `bash -c` spellings resolve to the `node` command family
  → Evidence: [report.md](report.md#facet-2)
- [x] T4 proves that the equivalent recursively stripped wrapper-spelling acceptance fixture completes without a clone finding
  → Evidence: [report.md](report.md#green)
- [x] T5 / SCN-B033-004 proves that wrapped cargo and npm identities sharing substantive stdout remain distinct and produce a clone finding naming both families
  → Evidence: [report.md](report.md#bounds)
- [x] T6 proves that the BUG-007 and BUG-032 regression pins continue to refuse their previously fixed clone-evidence shapes
  → Evidence: [report.md](report.md#regression)
- [x] T7 provides persistent whole-guard regression coverage for accepted sibling re-runs, recursive wrapper normalization, and both adversarial refusal shapes
      → Evidence: [report.md](report.md#regression)

## Scope 2 — Timeout Wrapper Grammar And Session Lock Boundary

**Status:** In Progress

### Gherkin Scenarios

```gherkin
Scenario: SCN-B033-005 Valid bare timeout and gtimeout wrappers are transparent
  Given a bare validator receipt and equivalent receipts behind bare canonical timeout and gtimeout wrappers
  When Check 43 computes their command identities
  Then every receipt resolves to the validator child identity

Scenario: SCN-B033-006 The short verbose option is transparent
  Given a receipt spelled `timeout -v 150 cargo test`
  When Check 43 computes its command identity
  Then it resolves to family cargo

Scenario: SCN-B033-007 Unknown, malformed, and unverified timeout syntax remains opaque
  Given an unknown option, malformed option value, missing duration, missing child, attached short value, unsupported short cluster, near-miss name, path-qualified system wrapper, or attacker-controlled timeout path
  When Check 43 computes the command identity
  Then the timeout invocation is not attributed to its apparent child

Scenario: SCN-B033-008 Timeout wrappers preserve distinct child programs
  Given timeout-wrapped cargo and npm receipts share substantive stdout
  When Check 43 classifies the collision
  Then an evidence receipt CLONE is reported
    And the diagnostic names both child families

Scenario: SCN-B033-009 Only the persistent session lock path is ignored
  Given a hermetic Git fixture applies the project memory-state ignore rule
  When the fixture checks the exact session lock and neighboring memory-state paths
  Then `.specify/memory/bubbles.session.json.flock` is ignored
    And `.specify/memory/bubbles.session.json` remains visible
    And neighboring memory-state files remain visible
    And a wildcard-broadened ignore rule fails the negative control
```

### Implementation Files

- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/receipt-identity-selftest.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/state-snapshot-selftest.sh`
- `.specify/memory/.gitignore`
- `bubbles/scripts/state-snapshot.sh`

### Implementation Plan

- Narrow the dirty timeout parser in `bubbles/scripts/state-transition-guard.sh` to the exact grammar and bare-token trust rule in `spec.md`.
- Narrow focused and whole-guard fixtures so they do not certify attached short values or unsupported clusters.
- Preserve the existing Scope 1 implementation and evidence.
- Keep the exact `.specify/memory/bubbles.session.json.flock` ignore entry without broadening it.
- Extend `bubbles/scripts/state-snapshot-selftest.sh` with a hermetic Git fixture that applies the project ignore rule and proves the exact flock path is ignored, the session JSON and neighboring files remain visible, and a wildcard-broadened rule fails an adversarial negative control.

### Definition of Done

- [x] T8 / SCN-B033-005 proves that bare validator, valid bare `timeout`, and valid bare `gtimeout` receipts normalize to the same child command identity.
  → Evidence: [report.md](report.md#timeout-green)
- [x] T9 / SCN-B033-006 proves that the accepted short verbose form `timeout -v 150 cargo test` resolves to the cargo child family.
  → Evidence: [report.md](report.md#timeout-green), [report.md](report.md#timeout-whole-guard)
- [x] T10 / SCN-B033-007 proves that unknown, malformed, attached-short, clustered, incomplete, near-miss, path-qualified system, and attacker-controlled timeout forms remain opaque rather than being attributed to an apparent child.
  → Evidence: [report.md](report.md#timeout-green), [report.md](report.md#timeout-whole-guard)
- [x] T11 / SCN-B033-008 proves that timeout-wrapped cargo and npm receipts sharing substantive stdout remain distinct and produce a clone finding naming both child families.
  → Evidence: [report.md](report.md#timeout-green), [report.md](report.md#timeout-whole-guard)
- [x] T12 provides persistent whole-guard regression coverage across accepted, opaque, and clone-refusal timeout behaviors.
  → Evidence: [report.md](report.md#timeout-whole-guard)
- [x] T13 / SCN-B033-009 proves in a hermetic Git fixture that only `.specify/memory/bubbles.session.json.flock` is ignored, while the session JSON and neighboring memory-state files remain visible and wildcard broadening fails its negative control.
  → Evidence: [report.md](report.md#scn-b033-009-green)
- [ ] Code Diff Evidence records the final reviewed implementation and focused-test changes without substituting for execution evidence.
  > **Phase:** validate
  > **Claim Source:** planned
  > **Evidence required:** `report.md#code-diff-evidence` must identify the authorized diff command, its real exit status, and the implementation and focused-test paths covered. This item remains unchecked until that evidence exists.
- [ ] `bubbles.validate` certifies both scopes on the final source revision.
  > **Uncertainty Declaration**
  > **What was attempted:** `bubbles.test` independently reran the exact BUG-033 test, metadata, regression-quality, artifact-lint, and scoped-diff matrix. No certification command was executed because certification is validate-owned.
  > **What was observed:** `state.json` certification remains `in_progress` with no certified scopes or phases.
  > **Why this is uncertain:** Passing test-phase evidence does not establish independent validation or certification.
  > **What would resolve this:** `bubbles.validate` evaluates the final source revision and writes the validate-owned certification fields.
