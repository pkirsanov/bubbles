<!-- markdownlint-disable MD024 -->

# Scopes: BUG-026 Traceability Sequential Scope And Tiered DoD

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Planning Ownership Notice

This two-scope plan is intake-provisional and reconstructed without the lost
transient packet bytes. `bubbles.plan` must reconcile scenario, Test Plan, DoD,
dependency, and machine-readable parity after `bubbles.design` resolves the
design. No delivery item is complete.

## Scope Inventory

| # | Scope | Depends On | Foundation | Status |
| --- | --- | --- | --- | --- |
| 1 | Applicable Universe And Tiered DoD Foundation | None | true | In Progress |
| 2 | Guard Integration And Delivery Closure | Scope 1 foundation | false | Not Started |

## Scope 1: Applicable Universe And Tiered DoD Foundation

**Status:** In Progress
**Depends On:** None
**Foundation:** true
**Capability Tag:** foundation:true
**Scope-Kind:** framework-traceability-foundation

### Gherkin Scenarios

#### SCN-BUG-026-001: Current scope omits only exact unstarted descendants

```gherkin
Scenario: SCN-BUG-026-001 Current scope omits only exact unstarted descendants
  Given valid v3 state with one current scope and a mixed dependency graph
  When traceability runs with the valueless current-scope context
  Then only exact not_started transitive descendants are omitted
  And current, prerequisite, independent, active, blocked, and done scopes remain visible
```

#### SCN-BUG-026-002: Invalid current-scope context fails closed

```gherkin
Scenario: SCN-BUG-026-002 Invalid current-scope context fails closed
  Given malformed, contradictory, unsafe, cyclic, terminal, or unmappable state
  When current-scope context is requested
  Then traceability refuses before any pass runs
  And no all-scope fallback or caller override is accepted
```

#### SCN-BUG-026-003: Tiered DoD rows survive nested headings

```gherkin
Scenario: SCN-BUG-026-003 Tiered DoD rows survive nested headings
  Given accepted DoD starts at depths one through four with nested tiers through depth six
  When the DoD section contract parses headings, comments, fences, boundaries, and checkboxes
  Then every real checkbox row remains available to G041 and G068
  And missing, rowless, ambiguous, read, and parser failures remain distinct
```

### Current Invocation Change Boundary

This invocation creates only the nine packet files under this BUG-026
directory. It does not edit production, tests, release metadata, documentation,
sibling packets, `improvements/INDEX.md`, Git history, or Research Lab.

### Authorized Delivery Boundary By Owner

| Owner | Surface | Exact permission |
| --- | --- | --- |
| `bubbles.design` | `design.md` | Reconcile strict state, applicable-universe, parser, CLI, and parity semantics. |
| `bubbles.plan` | Planning-owned packet artifacts | Reconcile this scope, scenarios, test rows, and DoD. |
| `bubbles.test` | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Create final regression bytes and causal RED before runtime edits. |
| `bubbles.implement` | Design-approved traceability foundation surface | Implement only after causal RED. |

### Implementation Plan

1. Freeze complete final regression bytes for both root causes before runtime
   edits.
2. Prove causal RED for the omission matrix and tiered DoD matrix.
3. Implement strict v3 state validation and one immutable applicable universe.
4. Implement depth-aware DoD section extraction with explicit outcomes.
5. Preserve all-scope defaults, matching thresholds, diagnostic integrity, and
   portable Bash behavior.

### Test Plan

The machine-readable twin is [test-plan.json](test-plan.json).

| Test Type | Test ID | Scenarios | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mandatory pre-fix Regression E2E RED | T-BUG-026-01 | SCN-BUG-026-001, SCN-BUG-026-003 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Final unchanged test bytes reproduce both current causes and the 28/9 consumer-shaped split before implementation. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Applicable-universe omission matrix | T-BUG-026-02 | SCN-BUG-026-001 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Exact unstarted transitive descendants omit; current, completed prerequisites, independent not_started, and active/blocked/done descendants remain. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| V3 registry shape and contradiction matrix | T-BUG-026-03 | SCN-BUG-026-002 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Both registry shapes pass when valid and fail on malformed JSON, types, duplicates, and cross-registry contradictions. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Alias and dependency graph adversaries | T-BUG-026-04 | SCN-BUG-026-001, SCN-BUG-026-002 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Accepted aliases resolve once; unknown dependencies, self-edges, cycles, duplicate aliases, and impossible statuses refuse. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Path, layout, filesystem, and completion matrix | T-BUG-026-05 | SCN-BUG-026-002 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Safe paths and both layouts map one-to-one; traversal, missing/extra files, report mismatch, and completion mismatch refuse. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Closed CLI and final-context refusal | T-BUG-026-06 | SCN-BUG-026-002 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Default/all/current forms are closed; valued, duplicate, override, bypass, terminal, validation, audit, and final forms refuse as specified. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| DoD depth, nesting, boundary, fence, and comment matrix | T-BUG-026-07 | SCN-BUG-026-003 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Depths 1-4 start, nested tiers through 6 remain, depths 5-6 do not start, same/shallower headings stop, and inert regions stay inert. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| DoD diagnostics, no-scenario, and threshold invariance | T-BUG-026-08 | SCN-BUG-026-003 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Rows, rowless, missing, ambiguous, read/parser failures are distinct; no-scenario behavior and G068 thresholds remain exact. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Portable Bash foundation | T-BUG-026-09 | SCN-BUG-026-001, SCN-BUG-026-002, SCN-BUG-026-003 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Foundation regression runs under macOS Bash 3.2 and Linux-compatible shell semantics without GNU-only forms. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |

### Definition of Done

#### Core Items

- [ ] The design-approved `ApplicableUniverse` validates v3 state and omits
  only exact `not_started` transitive descendants in current-scope context.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Runtime implementation is not authorized until design/plan reconciliation and causal RED.
- [ ] The depth-aware DoD contract preserves nested tiers through depth 6,
  ignores fences/comments, and returns distinct diagnostic states.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** No parser implementation or regression execution occurred during intake.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** `bubbles.test` must create `test_33` and prove causal RED before implementation.
- [ ] Broader E2E regression suite passes
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Broad framework execution is prohibited during artifact-only intake.
- [ ] Change Boundary is respected and zero excluded file families were changed
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Delivery containment requires the eventual owner-scoped diff.

#### Test Plan Evidence - Exact Parity With 9 Scope 1 Rows

- [ ] `T-BUG-026-01` records causal final-byte RED for both current root causes.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The reserved regression file does not exist yet.
- [ ] `T-BUG-026-02` proves the exact omission and visibility matrix.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Applicable-universe fixtures remain test-owned.
- [ ] `T-BUG-026-03` proves both valid v3 registry shapes and every contradiction refusal.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Structured-state fixtures remain test-owned.
- [ ] `T-BUG-026-04` proves alias and dependency graph fail-closed behavior.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Graph adversaries have not been authored or executed.
- [ ] `T-BUG-026-05` proves safe path, layout, filesystem, and completion mapping.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Both-layout mapping fixtures remain unexecuted.
- [ ] `T-BUG-026-06` proves the closed CLI and terminal/final-context refusals.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The current CLI has no context option and no final bytes exist.
- [ ] `T-BUG-026-07` proves every DoD depth, nested tier, boundary, fence, and comment case.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** DoD lexical fixtures remain test-owned.
- [ ] `T-BUG-026-08` proves diagnostic distinctions, no-scenario behavior, and unchanged thresholds.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** No regression command was run.
- [ ] `T-BUG-026-09` proves macOS Bash 3.2 and Linux-compatible foundation behavior.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Portability execution follows stable final test bytes.

#### Build Quality Gate

- [ ] Scope 1 focused regression, source selftests, syntax, diagnostics,
  packet checks, and design/plan ownership reconciliation are clean.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Intake checks cannot certify runtime delivery.

## Scope 2: Guard Integration And Delivery Closure

**Status:** Not Started
**Depends On:** Scope 1 foundation
**Foundation:** false
**Scope-Kind:** framework-guard-integration

### Gherkin Scenarios

#### SCN-BUG-026-004: All-scope and BUG-018 behavior remain compatible

```gherkin
Scenario: SCN-BUG-026-004 All-scope and BUG-018 behavior remain compatible
  Given a done or final-context packet and the existing BUG-018 regression
  When default and explicit all-scope validation run
  Then every physical scope remains visible in stable order
  And BUG-018 Test Plan heading-depth behavior remains green without byte edits
```

#### SCN-BUG-026-005: Source and installed guards share one contract

```gherkin
Scenario: SCN-BUG-026-005 Source and installed guards share one contract
  Given final source, test, documentation, provenance, and release bytes
  When canonical-source and installed downstream replays execute
  Then both expose the same current-scope and tiered-DoD behavior
  And state-transition Check 4A and Check 22 retain all-scope parity
```

### Authorized Delivery Boundary By Owner

| Owner | Surface | Exact permission |
| --- | --- | --- |
| `bubbles.plan` | Planning-owned packet artifacts | Reconcile Scope 2 only after the foundation contract settles. |
| `bubbles.implement` | Traceability pass integration and state-transition Check 4A/22 parity | Consume the approved foundation without changing all-scope transition context. |
| `bubbles.test` | Focused selftests, regression registration, BUG-018 compatibility, source/downstream replays | Own test bytes and execution evidence. |
| `bubbles.docs` | Managed behavior documentation | Document final approved context and diagnostics only. |
| `bubbles.releases` | Generated release identity | Reconcile stable final bytes only. |
| `bubbles.validate` | Certification and terminal state | Independent authority after every row is green. |

### Implementation Plan

1. Feed the immutable applicable universe to every traceability pass exactly
   once.
2. Apply the approved DoD section semantics to state-transition Check 4A and
   Check 22 without adding current-scope behavior there.
3. Preserve no-scenario, done-spec, all-scope, and BUG-018 contracts.
4. Register focused tests, reconcile managed docs and provenance, and run
   broad framework/release validation only after stable final bytes.
5. Prove canonical-source and supported installed downstream replay without
   modifying the consumer repository manually.

### Test Plan

| Test Type | Test ID | Scenarios | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E one-projection integration | T-BUG-026-10 | SCN-BUG-026-001, SCN-BUG-026-004 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | G057/G059, mapping, paths, reports, summaries, confidence, and G068 consume one projection; all-scope remains complete. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| State-transition Check 4A and Check 22 parity | T-BUG-026-11 | SCN-BUG-026-003, SCN-BUG-026-005 | functional | `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Tiered list-format detection and DoD fidelity use equivalent boundaries while transition context stays all-scope. | `bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| BUG-018 byte and behavior compatibility | T-BUG-026-12 | SCN-BUG-026-004 | regression | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Existing test_25 hash is unchanged and its level-2/level-3 behavior remains green. | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | No |
| Regression quality and mutation strength | T-BUG-026-13 | SCN-BUG-026-001, SCN-BUG-026-002, SCN-BUG-026-003 | functional | `bubbles/scripts/regression-quality-guard.sh` | Exact filter/parser mutations fail and no silent-pass bailout exists. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Focused guard selftests and registration | T-BUG-026-14 | SCN-BUG-026-004, SCN-BUG-026-005 | integration | Focused guard selftests and framework registration | Traceability/state-transition selftests plus registered test_33 execute on final bytes. | `bash bubbles/scripts/traceability-guard-selftest.sh && bash bubbles/scripts/state-transition-guard-selftest.sh && bash tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | No |
| Managed documentation consistency | T-BUG-026-15 | SCN-BUG-026-004, SCN-BUG-026-005 | functional | Managed guard usage and diagnostic documentation selected by `bubbles.docs` | Final docs state the closed CLI, fail-closed state, all-scope defaults, parser diagnostics, and no-bypass contract. | `bash bubbles/scripts/governance-index-lint.sh` | No |
| Install provenance and source inventory | T-BUG-026-16 | SCN-BUG-026-005 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Runtime, tests, docs, and registration are represented by supported install provenance. | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| Framework regression | T-BUG-026-17 | SCN-BUG-026-004, SCN-BUG-026-005 | integration | `bubbles/scripts/cli.sh` | Full framework validation preserves all unrelated contracts. | `bash bubbles/scripts/cli.sh framework-validate` | No |
| Release readiness | T-BUG-026-18 | SCN-BUG-026-005 | integration | `bubbles/scripts/cli.sh` | Generated release identity matches stable final bytes. | `bash bubbles/scripts/cli.sh release-check` | No |
| Downstream canonical-source replay | T-BUG-026-19 | SCN-BUG-026-001, SCN-BUG-026-003, SCN-BUG-026-005 | integration | Research Lab Feature 007 through canonical source | From the owning root, source guard current-scope replay removes only the 28/9 false classes without consumer writes. | `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab --current-scope` | Yes |
| Downstream installed replay | T-BUG-026-20 | SCN-BUG-026-005 | integration | Research Lab installed managed guard after supported upgrade | Installed bytes reproduce the canonical-source verdict with zero manual managed-file edits. | `cd ../research-lab && bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab --current-scope` | Yes |

### Definition of Done

#### Core Items

- [ ] Every traceability pass consumes exactly one immutable applicable scope
  universe and all-scope order/coverage remains unchanged.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Pass integration has not been implemented.
- [ ] State-transition Check 4A and Check 22 honor tiered DoD boundaries while
  the state-transition guard remains all-scope.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Parity requires design ownership and executable regression evidence.
- [ ] BUG-018 packet and test_25 bytes remain unchanged and behavior remains green.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Compatibility must be measured against final implementation bytes.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The physical test_33 file has not been created.
- [ ] Broader E2E regression suite passes
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Framework validation is intentionally excluded from intake execution.
- [ ] Change Boundary is respected and zero excluded file families were changed
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Requires the complete delivery diff and owner accounting.
- [ ] Canonical-source and installed downstream replay agree without manual
  Research Lab managed-file edits.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Supported release/install delivery has not occurred.

#### Test Plan Evidence - Exact Parity With 11 Scope 2 Rows

- [ ] `T-BUG-026-10` proves one-projection integration and all-scope compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Integration bytes and execution evidence do not exist.
- [ ] `T-BUG-026-11` proves state-transition Check 4A/22 boundary parity.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** State-transition source is protected during intake.
- [ ] `T-BUG-026-12` proves BUG-018 byte and behavior compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Existing test_25 was inspected only as a protected boundary, not executed.
- [ ] `T-BUG-026-13` proves adversarial regression strength and zero bailout paths.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** test_33 does not exist yet.
- [ ] `T-BUG-026-14` proves focused selftests and registration on final bytes.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Focused delivery selftests were not run during intake.
- [ ] `T-BUG-026-15` proves managed documentation matches final behavior.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Documentation ownership begins after behavior stabilizes.
- [ ] `T-BUG-026-16` proves install provenance and source inventory.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Stable install-facing bytes do not exist.
- [ ] `T-BUG-026-17` proves broad framework compatibility.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Framework validation was prohibited for packet creation.
- [ ] `T-BUG-026-18` proves release readiness.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Release validation follows stable source/test/doc inputs.
- [ ] `T-BUG-026-19` proves canonical-source Feature 007 current-scope replay.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** The consumer guard was not re-executed during intake.
- [ ] `T-BUG-026-20` proves installed Feature 007 replay after supported delivery.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Installed replay requires release and supported upgrade provenance.

#### Build Quality Gate

- [ ] Scope 2 focused tests, registration, docs, provenance, framework,
  release, downstream, artifact, freshness, G094, diagnostics, and transition
  evidence are current and independently certified.
  - **Claim Source:** not-run
  - **Uncertainty Declaration:** Delivery and validate-owned certification remain intentionally open.

The 20 Test Plan rows have exactly 20 matching test-related DoD items. Every
scenario maps to concrete rows in this file, [scenario-manifest.json](scenario-manifest.json),
and [test-plan.json](test-plan.json).

### Owner Route

`bubbles.design` is the immediate owner, followed by `bubbles.plan`,
`bubbles.test`, `bubbles.implement`, `bubbles.test`, `bubbles.docs`,
`bubbles.releases`, and `bubbles.validate`.
