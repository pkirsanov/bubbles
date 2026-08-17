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
