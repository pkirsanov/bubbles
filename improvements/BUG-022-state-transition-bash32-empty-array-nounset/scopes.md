# Scopes: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Reconciled Planning Authority

This file is the `bubbles.plan` source of truth for one sequential,
failing-first runtime-behavior scope. It defines delivery obligations but makes
no delivery claim. Every Definition of Done item remains unchecked.

The owner sequence is closed: `bubbles.test` must first author the complete
final bytes of
`tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`,
record their SHA-256, and capture a valid pre-fix RED against unchanged
production bytes. Only then may `bubbles.implement` atomically change all 43
mapped expansions across `bubbles/scripts/state-transition-guard.sh`,
`bubbles/scripts/guards/planning-checks.sh`, and
`bubbles/scripts/guards/control-plane-checks.sh`. A 40-site main-only repair
or partial rollback is forbidden.

Related authority: [spec.md](spec.md), [design.md](design.md),
[test-plan.json](test-plan.json), [scenario-manifest.json](scenario-manifest.json),
[report.md](report.md), and [uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Test reservation and final-byte RED:** `bubbles.test` owns the reserved
  `test_29` path, authors the complete production-path regression, records its
  SHA-256, and proves the unchanged guard fails for the intended Bash 3.2
  empty-array behavior.
2. **Atomic production repair:** `bubbles.implement` changes only the 40 main,
  one planning-module, and two control-plane-module accepted expansions to
  `${array[@]+"${array[@]}"}` after the valid RED gate, preserving strict mode,
  the raw positive-count control, and every foreign dirty byte across all
  three files.
3. **Identical-byte GREEN and matrix:** `bubbles.test` reruns the exact RED test
  bytes under stock Bash 3.2, newer macOS Bash, and Linux Bash, including all
  direct fixtures and independently staged mutants.
4. **Managed canaries and source-only registration:** `bubbles.test` adds only
  the focused managed selftest coverage, one collision-safe framework
  registration, and install-provenance assertions required by the design.
5. **Terminal provenance and certification:** focused packet checks precede
  full framework validation; `bubbles.releases` owns generated release
  identity and release-check; supported downstream upgrade evidence follows
  canonical release selection; `bubbles.validate` alone certifies status.

### New Types And Signatures

- No type, API, dependency, configuration key, or persisted schema is
  introduced.
- `TRANSITION_GUARD_RESULT_V1` retains its current fields, ordering, grammar,
  and exit classes.
- The existing indexed-array consumption signature becomes
  `${array[@]+"${array[@]}"}` at exactly 43 accepted sites across three sourced
  production files.
- `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`
  remains the source-only persistent regression.

### Validation Checkpoints

1. **Before production:** exact final test hash, all three production hashes,
  protected BUG-019 Check 8 hash, `test_26` hash, 43-site source inventory,
  and valid Bash 3.2 RED.
2. **After production:** a three-file targeted diff proves exactly 40 + 1 + 2
  mapped expansions changed and all nonmapped bytes stayed fixed; identical
  test hash reaches zero/one/multiple GREEN under `/bin/bash` 3.2.
3. **Before broad checks:** all family mutants fail independently; BUG-019
  remains `38/38`; strict syntax, managed selftest, contract canary,
  regression quality, portability, artifact, freshness, G094, and
  traceability checks have owner-recorded outcomes.
4. **Before release:** install provenance proves managed guard/selftest bytes
  and source-only `test_29`; full framework validation is a terminal
  prerequisite, not a planning-time pass claim.
5. **Before certification:** release-check and supported downstream upgrade
  evidence refer to one canonical release; no downstream managed copy is
  hand-edited; certification remains validate-owned.

The repository declares no `testImpact` or `traceContracts` configuration, so
this scope requires neither an impact-plan expansion nor telemetry/SLO rows.

## Scope Inventory

| # | Scope | Depends On | Status |
| --- | --- | --- | --- |
| 1 | Bash 3.2 Empty-Array Result Integrity | None | Not Started |

## Scope 1: Bash 3.2 Empty-Array Result Integrity

**Status:** Not Started
**Depends On:** None
**Foundation:** false
**Scope-Kind:** runtime-behavior

### Gherkin Scenarios

#### SCN-BUG-022-001: Zero-element states remain valid and observable

```gherkin
Scenario: SCN-BUG-022-001 Zero-element states remain valid and observable
  Given stock macOS Bash 3.2 with set -euo pipefail active
  And a production guard path with an intentionally empty result collection
  When the state-transition guard executes that path
  Then no unbound-variable abort occurs
  And the complete structured result serializes the collection as []
  And the intended pass or block exit status is preserved
```

#### SCN-BUG-022-002: One element crosses the empty accumulator boundary exactly once

```gherkin
Scenario: SCN-BUG-022-002 One element crosses the empty accumulator boundary exactly once
  Given stock macOS Bash 3.2 with set -euo pipefail active
  And an initially empty gate or check accumulator
  When the production guard records its first element
  Then the element appears exactly once in the structured result
  And existing deduplication and attribution semantics remain unchanged
```

#### SCN-BUG-022-003: Multiple elements preserve ordering and failure semantics

```gherkin
Scenario: SCN-BUG-022-003 Multiple elements preserve ordering and failure semantics
  Given stock macOS Bash 3.2 with set -euo pipefail active
  And a production guard path that records multiple distinct elements
  When the state-transition guard emits its structured result
  Then every element appears in existing order without duplication
  And genuine failures remain blocking
  And restoring any raw zero-state expansion makes the adversarial regression fail
```

### Current Invocation Change Boundary

This planning invocation may edit only files inside
`improvements/BUG-022-state-transition-bash32-empty-array-nounset/`. In
`state.json`, it may edit only `execution.*`, `executionHistory`, and
`updatedAt`. Production, regression, framework registration, generated
release, sibling packet, and downstream files are excluded from this
invocation.

Planning reconciliation observed the physical test at
`tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` with
SHA-256 `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`.
That identity is a collision detector only: it has no fresh RED claim and
remains exclusively `bubbles.test` owned.

### Authorized Delivery Boundary By Owner

| Owner | Surface | Exact permitted change |
| --- | --- | --- |
| `bubbles.test` | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Complete final-byte RED/GREEN, cardinality, family-mutant, Bash-matrix, inventory, and protected-byte regression. |
| `bubbles.implement` | `bubbles/scripts/state-transition-guard.sh` | Exactly 40 design-accepted `${array[@]+"${array[@]}"}` token substitutions after valid final-byte RED; preserve the raw positive-count `scope_files` control and every nonmapped byte. |
| `bubbles.implement` | `bubbles/scripts/guards/planning-checks.sh` | Exactly `PLANNING-CHANGE-BOUNDARY-SCOPE`: one `scope_files` substitution after the same RED; zero scopes must perform zero Check 8D iterations. |
| `bubbles.implement` | `bubbles/scripts/guards/control-plane-checks.sh` | Exactly `CONTROL-PLANE-TDD-SCOPES` and `CONTROL-PLANE-TDD-REPORTS`: two substitutions after the same RED; zero scopes or zero reports must pass zero optional arguments to `detect_red_green_ordering`. |
| `bubbles.test` | `bubbles/scripts/state-transition-guard-selftest.sh` | Focused zero-result and genuine-failure managed canaries without altering BUG-019 assertions. |
| `bubbles.test` | `bubbles/scripts/framework-validate.sh` | Exactly one nonoverlapping `run_check_self_only` registration for `test_29`, preserving BUG-021 bytes. |
| `bubbles.test` | `bubbles/scripts/install-provenance-selftest.sh` | Exact assertions that the guard/selftest are managed and `test_29` is source-only. |
| `bubbles.releases` | `bubbles/release-manifest.json` | Generator-owned identity after all canonical source/test/provenance inputs settle. |
| execution owners | `report.md` | Append current-session evidence only under the matching owner section. |
| `bubbles.validate` | `state.json::certification.*`, scope completion, terminal status | Independent certification only after every delivery gate is satisfied. |

### Explicitly Excluded Delivery Surfaces

- Any production state containing only the 40 main-guard substitutions or only
  one sourced-module repair;
- `tests/regression/test_26_state_transition_spec_mjs_path.sh`, the BUG-019
  Check 8 marker-bounded bytes, and BUG-012 tail-gate bytes;
- BUG-020 `fun-mode.sh`, BUG-021 timeout bytes, sibling packets, and their test
  bytes;
- `BUGS.md`, installer algorithms, generated release metadata, train/flag
  configuration, deployment, monitoring, backups, manifests, secrets,
  downstream managed copies, and unrelated documentation.

Unexpected overlap, a changed protected hash, or a newly occupied `test_29`
path blocks the active owner. It is not resolved by checkout, reset,
normalization, renumbering another owner's test, or whole-file replacement.

### Implementation Plan

1. `bubbles.test` creates the full final test at the reserved path, proves each
   fixture reaches the named production family, records exact source/test and
   protected-region hashes, and captures a valid pre-fix RED under stock Bash
   3.2 before any production mutation.
2. `bubbles.implement` re-resolves all 43 tuples by path, array, ordinal, and
  local operation, then applies one atomic patch: 40 accepted sites in the
  main guard, `PLANNING-CHANGE-BOUNDARY-SCOPE` in `planning-checks.sh`, and
  `CONTROL-PLANE-TDD-SCOPES` plus `CONTROL-PLANE-TDD-REPORTS` in
  `control-plane-checks.sh`.
3. The planning-module site is zero-reachable because an empty per-scope layout
  records its structural finding and continues to Check 8D with zero scope
  iterations. The two control-plane sites are independently zero-reachable
  because scope discovery and report discovery can each produce an empty
  optional argument group before `detect_red_green_ordering` starts.
4. Main `RESULT-APPLICABLE-FORMAT` (current line 141) remains in the accepted
  40 because `block_contract` can format a pre-resolution blocked result with
  zero applicable classes. The main raw `scope_files` use near current line
  575 remains byte-identical because a positive count dominates it.
5. `bubbles.test` proves zero arguments for empty arrays, one exact argument
   for one value and one empty-string value, and stable ordering plus existing
   deduplication for multiple values.
6. `bubbles.test` independently stages every mutant in a unique disposable
   copy, proves exactly one intended substitution occurred, and requires that
   mutant's named production assertion to fail.
7. Focused canaries run in the declared order before broad framework
   validation. Release generation and downstream upgrade evidence wait for
   stable canonical inputs and remain with their named owners.

### Protected-Byte Inventory And Source Containment

- The accepted production inventory is exactly 43 sites across exactly three
  paths: 40 in `state-transition-guard.sh`, one
  `PLANNING-CHANGE-BOUNDARY-SCOPE` in `planning-checks.sh`, and two independent
  `CONTROL-PLANE-TDD-SCOPES` / `CONTROL-PLANE-TDD-REPORTS` argument sites in
  `control-plane-checks.sh`.
- The module sites are part of the same source containment boundary because
  both modules are sourced under the main guard's active `set -u`; expansion
  occurs before the loop or callee can handle a zero-cardinality input.
- Main `RESULT-APPLICABLE-FORMAT` is zero-reachable on pre-resolution blocked
  results. The raw positive-count main `scope_files` control remains raw, and
  every other nonmapped byte in all three production files remains unchanged.
- The physical `test_29`, protected BUG-019/012 bytes, sibling packet states,
  release manifest, installer/registration surfaces, and downstream copies
  remain outside `bubbles.implement` ownership.

### Behavior-Family And Mutant Matrix

| Family | Required direct behavior | Independent mutant identities |
| --- | --- | --- |
| Result accumulation | First passed gate, failed gate, and failed check append once from zero prior values; repeats retain first-seen order. | `M-ACC-PASS`, `M-ACC-FAILED-GATE`, `M-ACC-FAILED-CHECK` |
| Result construction and serialization | Empty loops receive zero values and all accepted empty structured fields serialize exactly as `[]`. | `M-RESULT-LOOP`, `M-RESULT-FORMAT` |
| Scope discovery | Zero `scope_files` reaches the existing missing-scope diagnostic and complete failure result. | `M-SCOPE-LOOP`, `M-SCOPE-COPY` |
| Report discovery | Zero `report_files` reaches missing-report and Check-11 diagnostics and a complete nonzero result. | `M-REPORT-LOOP` |
| Evidence comparison | The first real hash compares against zero predecessors, distinct hashes append, and only repeated hashes retain the duplicate finding. | `M-EVIDENCE-FIRST` |
| Final failed-gate lookup | Empty `failed_gate_ids` preserves `PLANNING_GATE_FAILED`; a `G073` control preserves `SOURCE_EDIT_LOCKOUT`. | `M-FINAL-GATE-LOOKUP` |

Every remaining mapped source row also receives a one-site inventory mutant.
The inventory check must print the array name and source line and must reject a
changed inventory count; static inventory complements, but never replaces, the
family behavior mutants.

### Bash Runtime Matrix

| Lane | Required contract |
| --- | --- |
| Stock macOS | `/bin/bash` must report `3.2.x`; run syntax, primitive cardinality control, complete regression, every mutant, and unchanged BUG-019 `test_26`. |
| Newer macOS | Explicit `/opt/homebrew/bin/bash` or `/opt/local/bin/bash`; print `BASH_VERSION` and run the identical regression bytes plus zero/one/multiple assertions. |
| Linux/WSL | Supported Linux `bash`; print platform/version and run syntax, identical regression bytes, managed selftest, and broad framework prerequisite. |

No lane silently substitutes another interpreter. An unavailable required lane
remains an honest blocking result, and a newer Bash run never counts as Bash
3.2 evidence.

### Consumer Impact Sweep

No public path, identifier, result field, or command is renamed or removed.
Direct consumers that must remain byte-contract compatible are
`bubbles/scripts/cli.sh`, `done-spec-audit.sh`, validate/audit flows, the MCP
status-transition wrappers, the managed selftest, and structured-result
linters. Each retains command shape, diagnostics, field order, field grammar,
and exit vocabulary.

### Shared Infrastructure Impact Sweep

`state-transition-guard.sh` is installer-managed and high fan-out. Independent
canaries run in this order: BUG-022 production regression, unchanged BUG-019
`38/38`, managed guard selftest, audit-result contract selftest, install
provenance, full framework validation, then release readiness. Rollback
reverses the complete 43-site BUG-022 patch across all three production files
against their exact base and post-edit hashes. A 40-site main-only rollback,
single-module rollback, or any other subset is invalid; a hash mismatch blocks
rollback rather than erasing foreign dirty bytes.

### UI Scenario Matrix

Not applicable: this scope changes no UI, browser flow, display component, or
accessibility surface.

### Test Plan

The JSON twin is [test-plan.json](test-plan.json). Final row ownership belongs
to `bubbles.plan`.

| Test Type | Test ID | Scenarios | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E zero | T-BUG-022-02 | SCN-BUG-022-001 | e2e-api | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Empty result serialization, scope/report discovery, first evidence comparison, blocked result, and untagged final lookup emit complete truthful results without abort. | `/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |
| Regression E2E one | T-BUG-022-03 | SCN-BUG-022-002 | e2e-api | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | First gate/check element is recorded exactly once from an empty accumulator. | `/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |
| Regression E2E multiple | T-BUG-022-04 | SCN-BUG-022-003 | e2e-api | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Multiple values preserve order, deduplication, counts, and failure semantics. | `/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |
| Adversarial Regression E2E | T-BUG-022-05 | SCN-BUG-022-001, SCN-BUG-022-003 | e2e-api | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Ten named family mutants plus all 43 mapped one-site inventory mutants, including `PLANNING-CHANGE-BOUNDARY-SCOPE`, `CONTROL-PLANE-TDD-SCOPES`, and `CONTROL-PLANE-TDD-REPORTS`, run independently and are rejected through the staged production guard. | `/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |
| Mandatory final-byte RED | T-BUG-022-01 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | functional | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Complete final regression bytes fail against unchanged production only for inventoried zero-state families. | `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |
| Strict-mode canary | T-BUG-022-06 | SCN-BUG-022-001 | functional | `bubbles/scripts/state-transition-guard.sh`, `bubbles/scripts/guards/planning-checks.sh`, `bubbles/scripts/guards/control-plane-checks.sh` | Stock Bash 3.2 parses all three production files; the main guard retains `set -euo pipefail`; the atomic repair surface contains no nounset suppression, unsafe indirection, sentinel, fallback result, or bypass. | `/bin/bash -n bubbles/scripts/state-transition-guard.sh && /bin/bash -n bubbles/scripts/guards/planning-checks.sh && /bin/bash -n bubbles/scripts/guards/control-plane-checks.sh && grep -n '^set -euo pipefail$' bubbles/scripts/state-transition-guard.sh && for file in bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/planning-checks.sh bubbles/scripts/guards/control-plane-checks.sh; do if grep -nE 'set[[:space:]]+\+u' "$file"; then exit 1; fi; if grep -nE 'eval[[:space:]]' "$file"; then exit 1; fi; if grep -n -- '--no-nounset' "$file"; then exit 1; fi; if grep -n -- '--skip' "$file"; then exit 1; fi; if grep -n -- '--force' "$file"; then exit 1; fi; if grep -n -- 'EMPTY_ARRAY_SENTINEL' "$file"; then exit 1; fi; done` | No |
| Managed guard canary | T-BUG-022-07 | SCN-BUG-022-001, SCN-BUG-022-003 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Existing guard semantics and result contract remain intact. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes |
| BUG-019 compatibility | T-BUG-022-08 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | e2e-api | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | Unchanged BUG-019 matrix returns 38/38 under corrected parser-aware system Bash. | `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | Yes |
| Regression quality | T-BUG-022-09 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | functional | `bubbles/scripts/regression-quality-guard.sh` | The physical regression has no silent-pass bailout and contains true zero-state adversaries. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | No |
| Artifact shape | T-BUG-022-10 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | integration | `bubbles/scripts/artifact-lint.sh` | Packet structure, nonterminal honesty, report template, and checklist shape remain valid. | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | No |
| Broader E2E regression | T-BUG-022-11 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | e2e-api | `bubbles/scripts/cli.sh` | Framework validation passes after focused ownership and provenance checks settle. | `bash bubbles/scripts/cli.sh framework-validate` | Yes |
| Release identity | T-BUG-022-12 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | integration | `bubbles/scripts/cli.sh` | Release owner proves canonical source/install/release identity after stable bytes. | `bash bubbles/scripts/cli.sh release-check` | Yes |
| Newer macOS Bash lane | T-BUG-022-13 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | e2e-api | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | An explicit newer macOS Bash prints its version and produces the same zero/one/multiple result contract. | `if [[ -x /opt/homebrew/bin/bash ]]; then /opt/homebrew/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; elif [[ -x /opt/local/bin/bash ]]; then /opt/local/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; else printf '%s\n' 'required newer macOS Bash is unavailable'; exit 2; fi` | Yes |
| Linux Bash lane | T-BUG-022-14 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | e2e-api | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | A supported Linux runner prints platform/version and runs the identical regression bytes. | `bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |
| Structured-result consumer canary | T-BUG-022-15 | SCN-BUG-022-001, SCN-BUG-022-003 | integration | `bubbles/scripts/audit-result-contract-lint-selftest.sh` | Existing consumers still accept the unchanged ordered result grammar, including exact empty lists. | `bash bubbles/scripts/audit-result-contract-lint-selftest.sh` | Yes |
| Portability guard selftest | T-BUG-022-16 | SCN-BUG-022-001 | functional | `bubbles/scripts/macos-portability-guard-selftest.sh` | Canonical shell portability enforcement remains operational across macOS/BSD and Linux/GNU assumptions. | `bash bubbles/scripts/macos-portability-guard-selftest.sh` | No |
| Artifact freshness | T-BUG-022-17 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | integration | `bubbles/scripts/artifact-freshness-guard.sh` | Active spec, design, and one-scope plan contain no stale executable planning inventory. | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | No |
| Capability proportionality | T-BUG-022-18 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | integration | `bubbles/scripts/capability-foundation-guard.sh` | G094 accepts the spec/design single-capability and single-implementation justification. | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | No |
| Scenario traceability | T-BUG-022-19 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | integration | `bubbles/scripts/traceability-guard.sh` | Scenario, Markdown Test Plan, DoD, machine manifest, physical regression, and report evidence links agree. | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | No |
| Install/source-only provenance | T-BUG-022-20 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Guard and managed selftest install byte-identically while `test_29` remains source-only and release-recorded. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| Protected-byte and expansion inventory | T-BUG-022-21 | SCN-BUG-022-001, SCN-BUG-022-002, SCN-BUG-022-003 | functional | `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Exactly 43 mapped sites resolve across the three exact production paths: 40 main, `PLANNING-CHANGE-BOUNDARY-SCOPE`, `CONTROL-PLANE-TDD-SCOPES`, and `CONTROL-PLANE-TDD-REPORTS`; the one raw positive-count main control and every nonmapped/protected byte remain unchanged. | `/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | Yes |

### Definition of Done - Core Outcomes

- [ ] The atomic production diff changes exactly 43 accepted sites across all
  three production files: 40 main sites, `PLANNING-CHANGE-BOUNDARY-SCOPE`,
  `CONTROL-PLANE-TDD-SCOPES`, and `CONTROL-PLANE-TDD-REPORTS`; their valid zero
  scope/report states produce zero iterations or arguments, while the main raw
  positive-count control and every nonmapped/protected byte remain unchanged.
- [ ] `SCN-BUG-022-001` zero-element states remain valid and observable under
  nounset, every accepted empty structured list is exactly `[]`, and pass,
  failure, and blocked exits remain truthful.
- [ ] `SCN-BUG-022-002` one element crosses the empty accumulator boundary
  exactly once with unchanged attribution and deduplication, including the
  one-empty-string cardinality control.
- [ ] `SCN-BUG-022-003` multiple elements preserve first-seen order,
  formatting, counts, deduplication, gate attribution, and blocking semantics.
- [ ] Each named family mutant and every mapped one-site inventory mutant is
  independently applied exactly once in a disposable copy and rejected by a
  production behavior or inventory assertion.
- [ ] The current invocation and every delivery owner respect the declared
  change boundary; unexpected overlap blocks that owner without erasing or
  absorbing concurrent work.
- [ ] Source containment and rollback remain atomic across the three sourced
  production files: no 40-site partial repair, partial GREEN, or partial
  rollback is accepted, and each module site retains its documented
  zero-cardinality rationale.
- [ ] Canonical release selection and supported install/upgrade tooling are the
  only route to downstream managed bytes; no downstream copy is hand-edited.
- [ ] `bubbles.validate` alone writes certification fields, completed scope
  state, and terminal status after all required owner evidence exists.

### Definition of Done - Test Plan Parity

- [ ] `T-BUG-022-01` records complete final test bytes, their SHA-256, and a
  valid pre-fix RED caused only by the unchanged production empty-array defect.
- [ ] `T-BUG-022-02` proves the complete zero-element production contract.
- [ ] `T-BUG-022-03` proves the complete one-element production contract.
- [ ] `T-BUG-022-04` proves the complete multiple-element production contract.
- [ ] `T-BUG-022-05` rejects every independent family and site mutant.
- [ ] `T-BUG-022-06` parses all three production files under Bash 3.2, proves
  uninterrupted main-guard strict nounset, and finds no suppression,
  indirection, sentinel, fallback-result, or bypass pattern in the three-file
  repair surface.
- [ ] `T-BUG-022-07` proves the managed guard canaries.
- [ ] `T-BUG-022-08` proves unchanged BUG-019 compatibility at `38/38`.
- [ ] `T-BUG-022-09` runs `regression-quality-guard.sh --bugfix` against the
  physical `test_29` path and proves regression quality and zero bailout paths.
- [ ] `T-BUG-022-10` proves canonical artifact shape and nonterminal honesty.
- [ ] `T-BUG-022-11` proves the terminal full framework prerequisite after all
  focused checks are satisfied.
- [ ] `T-BUG-022-12` proves release identity under `bubbles.releases`
  ownership after canonical inputs settle.
- [ ] `T-BUG-022-13` proves identical behavior on explicit newer macOS Bash.
- [ ] `T-BUG-022-14` proves identical behavior on supported Linux Bash.
- [ ] `T-BUG-022-15` proves unchanged structured-result consumer grammar.
- [ ] `T-BUG-022-16` proves the canonical portability guard selftest.
- [ ] `T-BUG-022-17` proves artifact freshness.
- [ ] `T-BUG-022-18` proves G094 capability proportionality.
- [ ] `T-BUG-022-19` proves scenario, plan, DoD, physical test, and report
  traceability after the test owner creates `test_29`.
- [ ] `T-BUG-022-20` proves managed versus source-only install provenance.
- [ ] `T-BUG-022-21` proves the exact 40 + 1 + 2 inventory, all three sourced
  module site IDs and zero-state rationales, the preserved raw positive-count
  control, atomic three-file rollback boundary, and unchanged nonmapped bytes.

The 21 Test Plan rows above have exactly 21 test-related DoD items. The three
Gherkin scenarios map directly to `T-BUG-022-02`, `T-BUG-022-03`, and
`T-BUG-022-04`; `T-BUG-022-05` supplies the persistent adversarial protection.

### Planning Uncertainty Declaration

> **What was attempted:** Planning reconciled the authoritative spec/design,
> synchronized the atomic three-file/43-site owner boundary, and identified the
> current physical `test_29` bytes without assigning them a RED claim.
> **What was observed:** The physical `test_29` SHA-256 is
> `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`;
> no fresh causal RED exists for that identity, and all delivery DoD items
> remain unchecked.
> **Why this is uncertain:** Runtime behavior, RED/GREEN, mutation, provenance,
> broad validation, release, downstream, and certification results require
> execution by their named owners.
> **What would resolve this:** Execute the Owner Route below in order and append
> current-session evidence under each owner's report section.

### Owner Route

1. `bubbles.test` selects and freezes the complete final regression bytes,
  records the exact test hash plus all three unchanged production hashes, and
  captures valid causal RED against the complete 43-site production surface.
2. `bubbles.implement` may atomically edit only the mapped 40 + 1 + 2
  production expansions across all three authorized files after the RED
  evidence and exact regression hash exist; no partial implementation route is
  authorized.
3. `bubbles.test` owns identical-byte GREEN, Bash lanes, independent mutants,
  managed canaries, framework registration, and install-provenance assertions.
4. `bubbles.releases` owns generated release identity and release-check after
  canonical source/test/provenance inputs settle.
5. The downstream upgrade owner uses only the supported canonical
  install/upgrade route and records installed provenance without hand edits.
6. `bubbles.validate` independently verifies the complete evidence set and is
  the only owner permitted to certify scope or terminal state.
