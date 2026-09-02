# BUG-033 Scopes

## Scope 1 — Receipt Target Grouping And Wrapper Normalization

**Status:** Complete

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

### Implementation Plan

- `bubbles/scripts/state-transition-guard.sh` — Check 43 jq program:
  - group `$targets` by `cmd_identity` before the distinctness test (facet 1)
  - replace the single-token `bash`/`sh` strip with a recursive
    `strip_wrappers` covering shells with `-c`, `env`, and leading `VAR=value`
    assignments (facet 2)
- No other file changes behavior.

### Test Plan

| ID | Test | Type | Surface |
| --- | --- | --- | --- |
| T1 | facet 1 acceptance (9 re-runs, 2 targets) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T2 | facet 1 adversarial bound (2 identities, 1 target) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T3 | facet 2 family probe over 6 spellings | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T4 | facet 2 acceptance (5 wrapper spellings) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T5 | facet 2 adversarial bound (cargo vs npm behind wrappers) | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T6 | BUG-007 + BUG-032 pins survive the relaxation | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T7 | Regression E2E — whole guard accepts re-runs and wrappers, still refuses both adversarial shapes | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |

### Definition of Done

- [x] Facet 1 fixed: target distinctness is measured per command identity
      → Evidence: [report.md](report.md#facet-1)
- [x] Facet 2 fixed: shell, `env` and assignment wrappers are stripped recursively
      → Evidence: [report.md](report.md#facet-2)
- [x] Failing reproduction captured BEFORE the fix, with its real exit code
      → Evidence: [report.md](report.md#red)
- [x] Both facets pass AFTER the fix, with real exit codes
      → Evidence: [report.md](report.md#green)
- [x] Adversarial bounds still REFUSE for both facets
      → Evidence: [report.md](report.md#bounds)
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
      → Evidence: [report.md](report.md#regression)
- [x] Broader E2E regression suite passes
      → Evidence: [report.md](report.md#regression)

## Scope 2 — Timeout Wrapper Grammar And Session Lock Boundary

**Status:** In Progress

### Gherkin Scenarios

```gherkin
Scenario: SCN-B033-005 Valid timeout and gtimeout wrappers are transparent
  Given a bare validator receipt and equivalent receipts behind exact-basename timeout and gtimeout wrappers
  When Check 43 computes their command identities
  Then every receipt resolves to the validator child identity

Scenario: SCN-B033-006 The short verbose option is transparent
  Given a receipt spelled `timeout -v 150 cargo test`
  When Check 43 computes its command identity
  Then it resolves to family cargo

Scenario: SCN-B033-007 Unknown and malformed timeout syntax remains opaque
  Given an unknown option, malformed option value, missing duration, missing child, attached short value, unsupported short cluster, or near-miss basename
  When Check 43 computes the command identity
  Then the timeout invocation is not attributed to its apparent child

Scenario: SCN-B033-008 Timeout wrappers preserve distinct child programs
  Given timeout-wrapped cargo and npm receipts share substantive stdout
  When Check 43 classifies the collision
  Then an evidence receipt CLONE is reported
    And the diagnostic names both child families

Scenario: SCN-B033-009 Only the persistent session lock path is ignored
  Given `.specify/memory/.gitignore` contains the persistent lock entry
  When repository state is inspected
  Then `bubbles.session.json.flock` is ignored
    And `bubbles.session.json` remains visible
```

### Implementation Plan

- Narrow the dirty timeout parser in `bubbles/scripts/state-transition-guard.sh` to the exact grammar in `spec.md`.
- Narrow focused and whole-guard fixtures so they do not certify attached short values or unsupported clusters.
- Preserve the existing Scope 1 implementation and evidence.
- Keep the exact `.specify/memory/bubbles.session.json.flock` ignore entry without broadening it.

### Test Plan

| ID | Test | Type | Surface |
| --- | --- | --- | --- |
| T8 | Bare, valid timeout, and valid gtimeout spellings normalize to one identity | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T9 | `timeout -v` normalizes to the child identity | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T10 | Unknown, malformed, attached, clustered, incomplete, and near-miss forms stay opaque | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T11 | Different timeout-wrapped children sharing output still refuse | unit | `bubbles/scripts/receipt-identity-selftest.sh` |
| T12 | Regression E2E — whole guard exercises accepted and opaque timeout forms | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| T13 | Exact lock file is ignored while session JSON remains visible | functional | repository ignore check |

### Definition of Done

- [ ] Timeout and gtimeout accept only the closed option grammar in `spec.md`.
- [ ] The short `-v` option is covered by focused and whole-guard acceptance tests.
- [ ] Unknown, malformed, attached short, unsupported clustered, incomplete, and near-miss forms remain opaque.
- [ ] Different timeout-wrapped children sharing substantive output remain a clone finding.
- [ ] The exact persistent flock path is ignored without hiding session JSON.
- [ ] Pre-fix timeout regression test fails with current-session evidence.
  > **Uncertainty Declaration**
  > **What was attempted:** Artifact reconciliation inspected the dirty parser and fixtures without executing them.
  > **What was observed:** The dirty tests certify forms outside the required grammar.
  > **Why this is uncertain:** Source inspection is not a red-stage execution.
  > **What would resolve this:** Run the corrected focused regression against the over-broad parser before narrowing it.
- [ ] Post-fix timeout regression test passes with current-session evidence.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
- [ ] Broader E2E regression suite passes
- [ ] `bubbles.validate` certifies both scopes on the final source revision.
