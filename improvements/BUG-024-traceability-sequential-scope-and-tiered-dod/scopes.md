# Scopes: BUG-024 Traceability Sequential Scope And Tiered DoD

<!-- markdownlint-disable MD024 -->

## Planning Status

This is the active two-scope execution plan reconciled from [spec.md](spec.md)
and [design.md](design.md). Both scopes remain `Not Started`, every delivery
DoD item remains unchecked, and no source, test, release, installed byte,
downstream, or certification result is claimed.

Related artifacts: [report.md](report.md), [uservalidation.md](uservalidation.md),
[test-plan.json](test-plan.json), and
[scenario-manifest.json](scenario-manifest.json).

## Execution Outline

### Phase Order

1. **Scope 1 - Applicable-universe and DoD-extraction foundation:** freeze the
  final persistent regression bytes and causal RED, then implement the shared
  `ApplicableUniverse`, `ScopeRecord`, and selected-depth `DoDExtraction`
  contracts with focused foundation cases.
2. **Scope 2 - Guard integration, parity, and canonical delivery:** wire the
  Scope 1 foundation through every traceability pass, align state-transition
  G041/G068 semantics, complete managed regressions, and prove canonical
  registration, provenance, release, install, and downstream replay.

### New Types And Signatures

- Default and `--all-scopes` contexts analyze every scope.
- `--current-scope` derives its identity from validated state and accepts no
  caller scope value.
- Internal scope records carry identity, path, label, report, status,
  dependencies, and applicability for both layouts.
- DoD extraction returns `0` found, `3` missing, `4` ambiguous, or another
  nonzero parser/read failure.
- Public guard exits remain `0` pass, `1` findings, and `2` usage/contract
  refusal.

### Validation Checkpoints

1. Frozen final-byte source-only regression records causal RED against one
  unchanged producer snapshot.
2. Applicable-universe and DoD-extraction foundation cases discriminate the
  omission, registry, graph, path, phase, layout, and heading contracts.
3. Production integration proves one projection feeds every traceability pass.
4. Managed traceability and state-transition selftests pass without deleting
  or weakening existing cases.
5. BUG-018 `test_25` and every BUG-018 packet byte remain unchanged.
6. State-transition Check 4A/22 parity passes while G068 thresholds remain
  unchanged and terminal invocations remain all-scope.
7. Done-spec and direct default/`--all-scopes` consumers retain every gap.
8. Packet lint, freshness, G094, and traceability gates run after the physical
  regression exists.
9. Full framework validation runs after exact source-only registration.
10. Install provenance verifies managed and source-only classifications.
11. `bubbles.docs` updates capability projections and managed documentation.
12. `bubbles.releases` generates and validates release identity.
13. Supported downstream delivery precedes Research Lab installed replay;
   canonical-source current-scope replay is followed by canonical all-scope
   proof, then installed current-scope replay and installed all-scope proof.

## Scope Inventory

| # | Scope | Depends On | Scope Kind | Test Rows | Status |
| --- | --- | --- | --- | ---: | --- |
| 1 | Applicable-Universe And DoD-Extraction Foundation | None | runtime-behavior | 17 | Not Started |
| 2 | Guard Integration, Terminal Parity, And Canonical Delivery | Scope 1 | runtime-behavior | 24 | Not Started |

## Owner-Separated Execution Route

| Order | Owner | Exclusive responsibility |
| ---: | --- | --- |
| 1 | `bubbles.test` | Create final physical `test_31` bytes, freeze their identity, and capture causal RED against unchanged production. |
| 2 | `bubbles.implement` | Change only BUG-024-owned production regions plus exact framework and capability-ledger registration. |
| 3 | `bubbles.test` | Own managed selftest additions, direct provenance assertions, independent GREEN, portability, BUG-018, and broad regressions. |
| 4 | `bubbles.docs` | Update managed invocation/compatibility docs and regenerate capability-ledger projections. |
| 5 | `bubbles.releases` | Generate canonical release metadata after source, tests, registration, provenance, and docs are stable. |
| 6 | `bubbles.devops` | Perform the supported downstream upgrade without manual managed-byte copying. |
| 7 | `bubbles.validate` and `bubbles.audit` | Independently validate and certify after all delivery checks have execution evidence. |

## Shared Change Boundary

### Allowed Surfaces And Exact Ownership

| Surface | Allowed BUG-024 region | Owner |
| --- | --- | --- |
| `bubbles/scripts/traceability-guard.sh` | Closed CLI parsing; `ApplicableUniverse`/`ScopeRecord`; one projection; `DoDExtraction`; no unrelated matching rewrite | `bubbles.implement` |
| `bubbles/scripts/traceability-guard-selftest.sh` | Additive BUG-024 applicability/DoD block; every existing case retained | `bubbles.test` |
| `bubbles/scripts/state-transition-guard.sh` | Check 4A G041 and Check 22 G068 DoD semantics only; no reduced context and no threshold change | `bubbles.implement` |
| `bubbles/scripts/state-transition-guard-selftest.sh` | Additive BUG-024 Check 4A/22 parity block; every existing case retained | `bubbles.test` |
| `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Complete final source-only regression; no copied helper or internal mock | `bubbles.test` |
| `bubbles/scripts/framework-validate.sh` | Exactly one adjacent `run_check_self_only` registration | `bubbles.implement` |
| `bubbles/scripts/install-provenance-selftest.sh` | Direct managed/source-only assertions | `bubbles.test` |
| `bubbles/capability-ledger.yaml` | One source-backed capability with actual traceability/state-transition consumers | `bubbles.implement` |
| generated capability projections and managed docs | Generator-owned projections plus invocation/compatibility text | `bubbles.docs` |
| `bubbles/release-manifest.json` and release identity | Owner-generated output after every input is stable | `bubbles.releases` |

### Protected Concurrent Bytes

- Every file under `improvements/BUG-018*`, `improvements/BUG-022*`, and
  `improvements/BUG-023*` remains byte-identical.
- `tests/regression/test_23_planning_audit_contract.sh`,
  `tests/regression/test_25_traceability_test_plan_heading_depth.sh`,
  `tests/regression/test_26_state_transition_spec_mjs_path.sh`, and
  `tests/regression/test_30_planning_transition_applicability_and_baseline.sh`
  remain byte-identical.
- Existing unrelated G040/G073 hunks and every non-BUG-024 marker/function
  region in `state-transition-guard.sh` and
  `state-transition-guard-selftest.sh` remain untouched.
- `bubbles/release-manifest.json` remains untouched by plan, RED, implement,
  and test owners; only `bubbles.releases` may regenerate it.
- Every Research Lab byte remains untouched until the supported upgrade owner
  runs the declared delivery command; canonical-source replays are read-only.
- Every source/test/framework path not named in the allowed table is excluded.

### Surgical Merge And Rollback Rule

Before shared-file mutation, the owner records current hashes and zero-context
diffs. BUG-024 edits stay inside named functions/checks or explicit BUG-024
marker blocks. Rollback restores only those regions and the coherent release
unit; it must not replace a whole shared file or revert concurrent G040/G073
bytes.

## Scope 1: Applicable-Universe And DoD-Extraction Foundation

**Status:** Not Started
**Depends On:** None
**Scope-Kind:** runtime-behavior
**Planning Tags:** `foundation:true`

### Outcome

One internal applicability universe and one explicit selected-depth DoD
extraction contract are regression-frozen and implemented before any consumer
integration proceeds.

### Gherkin Scenarios

#### SCN-BUG-024-001: exact descendant omission preserves current and prerequisites

```gherkin
Scenario: SCN-BUG-024-001 exact descendant omission preserves current and prerequisites
  Given a valid per-directory v3 packet has one blocked or in-progress current scope
  And every prerequisite is certified done while transitive descendants are exactly not_started
  When the real guard runs with valueless --current-scope
  Then the current scope and completed prerequisites remain applicable
  And only exact not_started transitive descendants are omitted with reason not-started-descendant
```

#### SCN-BUG-024-002: completed prerequisite gaps remain blocking

```gherkin
Scenario: SCN-BUG-024-002 completed prerequisite gaps remain blocking
  Given the current scope depends on a scope consistently recorded as completed
  And that prerequisite has a concrete scenario test path report or DoD gap
  When current-scope traceability runs
  Then the completed prerequisite gap reaches the normal aggregate summary and exits 1
```

#### SCN-BUG-024-003: independent and non-not-started descendants stay visible

```gherkin
Scenario: SCN-BUG-024-003 independent and non-not-started descendants stay visible
  Given one independent scope is not_started and descendant variants are in_progress blocked and done
  And each variant contains the same seeded traceability gap
  When current-scope default and explicit all-scope contexts run
  Then every independent active blocked done or all-scope gap remains applicable and blocking
```

#### SCN-BUG-024-004: canonical certification registry resolves exact aliases

```gherkin
Scenario: SCN-BUG-024-004 canonical certification registry resolves exact aliases
  Given execution.scopeProgress is absent and certification.scopeProgress is complete
  And execution.currentScope uses a numeric digit-string or exact scopeId alias
  When current-scope state is normalized
  Then every alias maps one-to-one to the same ordered ScopeRecord graph
  And certification.completedScopes exactly matches both certified and operational done sets
```

#### SCN-BUG-024-005: execution registry precedence cross-checks certification

```gherkin
Scenario: SCN-BUG-024-005 execution registry precedence cross-checks certification
  Given execution.scopeProgress is present as the operational registry
  And certification.scopeProgress and completedScopes provide certification authority
  When identities dependencies paths and completion are normalized
  Then a matching pair produces the same universe as the canonical registry shape
  And an empty invalid or contradictory present execution registry refuses without fallthrough
```

#### SCN-BUG-024-006: malformed identities types dependencies and cycles refuse

```gherkin
Scenario: SCN-BUG-024-006 malformed identities types dependencies and cycles refuse
  Given current-scope state has malformed JSON wrong JSON types duplicate or ambiguous aliases
  Or it has an unknown status unknown dependency duplicate edge self-edge or dependency cycle
  When applicability resolution starts
  Then one state-qualified diagnostic exits 2 before any partial universe or traceability pass is printed
```

#### SCN-BUG-024-007: unsafe paths filesystem drift and completion mismatch refuse

```gherkin
Scenario: SCN-BUG-024-007 unsafe paths filesystem drift and completion mismatch refuse
  Given a registry path is absolute traversing escaped missing duplicated or inconsistent with discovered units
  Or operational done certified done and completedScopes sets disagree
  When current-scope state is validated
  Then resolution exits 2 without all-scope one-scope or empty-set fallback
```

#### SCN-BUG-024-008: terminal and final contexts refuse reduced evaluation

```gherkin
Scenario: SCN-BUG-024-008 terminal and final contexts refuse reduced evaluation
  Given top-level and certification status disagree or identify a terminal state
  Or currentPhase is validate audit or finalize or completed phase claims contain validate or audit
  When --current-scope is requested
  Then the guard exits 2 before analysis and does not silently switch to all-scope
```

#### SCN-BUG-024-009: the CLI context surface is closed

```gherkin
Scenario: SCN-BUG-024-009 the CLI context surface is closed
  Given the feature directory remains the first positional argument
  When duplicate conflicting valued additional-positional unknown or bypass-shaped options are supplied
  Then the guard exits 2 with usage and accepts no caller scope status path omission list or environment override
```

#### SCN-BUG-024-010: per-directory and single-file mapping is proof-based

```gherkin
Scenario: SCN-BUG-024-010 per-directory and single-file mapping is proof-based
  Given per-directory units map by safe scopeArtifact or scopeDir paths
  And single-file units use unique exact numbered Scope headings with equal registry number sets
  When current-scope mapping runs
  Then each valid identity maps to exactly one analysis unit
  And free-form duplicate missing or mismatched single-file identities exit 2
```

#### SCN-BUG-024-011: no-scenario findings follow applicability

```gherkin
Scenario: SCN-BUG-024-011 no-scenario findings follow applicability
  Given an applicable scope and an exact omitted not_started descendant contain no Gherkin scenario
  When current-scope and all-scope contexts run
  Then the applicable scope emits the existing no-scenario finding
  And the omitted descendant is inert only in current-scope context and fails in all-scope context
```

#### SCN-BUG-024-012: DoD starts at depths one through four retain deeper tiers

```gherkin
Scenario: SCN-BUG-024-012 DoD starts at depths one through four retain deeper tiers
  Given accepted Definition of Done or DoD headings begin at ATX depths 1 2 3 and 4
  And their tier headings extend through depth 6
  When DoDExtraction scans each real scope unit
  Then every in-section unindented checkbox is retained in order
  And depth 5 or 6 headings never become accepted starts
```

#### SCN-BUG-024-013: DoD boundaries false starts and failure states are distinct

```gherkin
Scenario: SCN-BUG-024-013 DoD boundaries false starts and failure states are distinct
  Given same-depth and shallower headings fence and HTML-comment lookalikes are present
  And fixtures independently contain rowless missing ambiguous and unreadable DoD inputs
  When DoDExtraction runs under checked caller control
  Then sibling and ancestor content plus fenced or commented examples are excluded
  And found-rowless missing ambiguous and read failure each emit exactly one scope-qualified finding and reach the summary
```

### Implementation Plan

1. `bubbles.test` creates
   `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`
  with all 19 selectors, complete disposable packets, unique temporary roots,
  cleanup traps, real JSON parsing, and no copied production helper.
2. Freeze `test_31` and protected-producer hashes immediately before and after
  unchanged-production execution; require causal applicability/DoD RED with
  clean controls.
3. `bubbles.implement` adds the closed CLI parser, safe v3 state normalizer,
  exact graph/path/completion checks, deterministic layout mapping, and one
  immutable `ApplicableUniverse`/`ScopeRecord` collection.
4. Implement selected-depth `DoDExtraction` for starts 1-4, nested tiers
  through 6, fence/comment exclusion, same-or-shallower boundaries, explicit
  status, and checked caller handling.
5. Run focused foundation cases before any Scope 2 integration mutation.

### Consumer Impact Sweep

- Default direct callers retain all-scope behavior.
- Active scope owners receive one state-bound context with no scope value.
- Scope aliases, dependencies, registry paths, completion, and both layouts
  normalize once with deterministic ordering.
- No route, endpoint, API client, navigation, breadcrumb, redirect, generated
  client, deep link, or UI target exists for this local CLI change.
- Stale-reference scans cover guard calls, managed selftests, registration,
  provenance, docs, and source-only inventory.

### Shared Infrastructure Impact Sweep

The traceability guard and packet fixtures are high-fan-out infrastructure.
Downstream contracts include default/all/current invocation, manifest and Test
Plan mapping, physical path/report evidence, G068, cleanup, exits, and Bash
portability. Independent canaries are BUG-018 `test_25`, done-spec audit,
managed selftests, framework validation, provenance, and read-only Research Lab
replay. Rollback restores the prior coherent release while preserving
concurrent source regions.

### Change Boundary

Scope 1 may create only `test_31` and modify only BUG-024-owned CLI,
state-normalization, applicability, and DoD-extraction regions of
`traceability-guard.sh`. Traceability pass wiring, state-transition source,
managed selftests, registration, provenance, docs, release identity, and all
protected surfaces remain outside Scope 1.

### Test Plan

`Live System: No` is intentional: these tests execute the real production CLI
against isolated filesystem packets. They do not start or claim a browser,
HTTP API, service stack, database, or network dependency.

| Test Type | Test ID | Scenario(s) | Category | File / Location | Exact behavior | Command | Live System | Owner | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RED Regression E2E (CLI) | T-BUG-024-000 | All active contracts | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Frozen unchanged-producer matrix records causal RED with clean controls. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | No | `bubbles.test` | [T-BUG-024-000](report.md#t-bug-024-000) |
| Regression E2E (CLI) | T-BUG-024-001 | SCN-BUG-024-001 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Exact descendant omission keeps current and prerequisites applicable. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-001` | No | `bubbles.test` | [T-BUG-024-001](report.md#t-bug-024-001) |
| Adversarial Regression E2E (CLI) | T-BUG-024-002 | SCN-BUG-024-002 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | A completed prerequisite gap exits 1 through the normal summary. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-002` | No | `bubbles.test` | [T-BUG-024-002](report.md#t-bug-024-002) |
| Adversarial Regression E2E (CLI) | T-BUG-024-003 | SCN-BUG-024-003 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Independent not_started plus in_progress/blocked/done descendants and all-scope retain gaps. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-003` | No | `bubbles.test` | [T-BUG-024-003](report.md#t-bug-024-003) |
| Regression E2E (CLI) | T-BUG-024-004 | SCN-BUG-024-004 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Canonical certification registry and currentScope aliases normalize one-to-one. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-004` | No | `bubbles.test` | [T-BUG-024-004](report.md#t-bug-024-004) |
| Adversarial Regression E2E (CLI) | T-BUG-024-005 | SCN-BUG-024-005 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Execution registry precedence accepts agreement and rejects empty/invalid/contradictory presence. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-005` | No | `bubbles.test` | [T-BUG-024-005](report.md#t-bug-024-005) |
| Adversarial Regression E2E (CLI) | T-BUG-024-006 | SCN-BUG-024-006 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Malformed JSON/types/identities/status/dependencies/cycles refuse before analysis. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-006` | No | `bubbles.test` | [T-BUG-024-006](report.md#t-bug-024-006) |
| Adversarial Regression E2E (CLI) | T-BUG-024-007 | SCN-BUG-024-007 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Path escape/filesystem mismatch/completion mismatch refuse without fallback. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-007` | No | `bubbles.test` | [T-BUG-024-007](report.md#t-bug-024-007) |
| Adversarial Regression E2E (CLI) | T-BUG-024-008 | SCN-BUG-024-008 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Terminal/final status and validate/audit/finalize phase vectors refuse reduced context. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-008` | No | `bubbles.test` | [T-BUG-024-008](report.md#t-bug-024-008) |
| Adversarial Regression E2E (CLI) | T-BUG-024-009 | SCN-BUG-024-009 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Duplicate/conflicting/valued/unknown/additional/bypass CLI vectors exit 2. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-009` | No | `bubbles.test` | [T-BUG-024-009](report.md#t-bug-024-009) |
| Regression E2E (CLI) | T-BUG-024-010 | SCN-BUG-024-010 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Per-directory and proven single-file mappings pass; ambiguous mappings refuse. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-010` | No | `bubbles.test` | [T-BUG-024-010](report.md#t-bug-024-010) |
| Adversarial Regression E2E (CLI) | T-BUG-024-011 | SCN-BUG-024-011 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | No-scenario findings follow applicability in current/all contexts. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-011` | No | `bubbles.test` | [T-BUG-024-011](report.md#t-bug-024-011) |
| Regression E2E (CLI) | T-BUG-024-012 | SCN-BUG-024-012 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | DoD starts 1-4 retain nested levels through 6; depths 5/6 are not starts. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-012` | No | `bubbles.test` | [T-BUG-024-012](report.md#t-bug-024-012) |
| Adversarial Regression E2E (CLI) | T-BUG-024-013 | SCN-BUG-024-013 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Boundaries, false starts, rowless/missing/ambiguous/read failure remain distinct. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-013` | No | `bubbles.test` | [T-BUG-024-013](report.md#t-bug-024-013) |
| Foundation Unit Contract | T-BUG-024-014 | SCN-BUG-024-001 through SCN-BUG-024-010 | unit | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Focused applicability cases invoke production behavior and reject copied/self-validating resolution. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case applicable-universe-foundation` | No | `bubbles.test` | [T-BUG-024-014](report.md#t-bug-024-014) |
| Foundation Unit Contract | T-BUG-024-015 | SCN-BUG-024-012, SCN-BUG-024-013 | unit | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Focused DoD cases invoke production extraction and distinguish content/status boundaries. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case dod-extraction-foundation` | No | `bubbles.test` | [T-BUG-024-015](report.md#t-bug-024-015) |
| Regression Integrity | T-BUG-024-016 | SCN-BUG-024-001 through SCN-BUG-024-013 | functional | `bubbles/scripts/regression-quality-guard.sh` | Final regression has adversarial failure signals and no silent-pass bailout. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | No | `bubbles.test` | [T-BUG-024-016](report.md#t-bug-024-016) |

### Test Environment Isolation

The new persistent regression and managed selftest create unique parents under
`${TMPDIR:-/tmp}`, keep every packet/test/report/log beneath those parents, and
remove them on `EXIT`, `INT`, and `TERM`. They write to no downstream repo,
monitoring plane, backup path, deployment manifest, release-train config, or
shared fixed temp path.

### Definition of Done - Tiered Validation

#### Core Items

- [ ] SCN-BUG-024-001 proves exact omission and preserves current plus completed prerequisites.
- [ ] SCN-BUG-024-002 keeps every completed-prerequisite gap blocking.
- [ ] SCN-BUG-024-003 keeps independent not_started and active/blocked/done descendant gaps visible.
- [ ] SCN-BUG-024-004 normalizes canonical registry identities and currentScope aliases one-to-one.
- [ ] SCN-BUG-024-005 enforces execution-registry precedence and certification contradiction checks.
- [ ] SCN-BUG-024-006 refuses malformed JSON/types/identities/status/dependencies/cycles before analysis.
- [ ] SCN-BUG-024-007 refuses unsafe paths, filesystem drift, and completion mismatch without fallback.
- [ ] SCN-BUG-024-008 refuses terminal/final/validate/audit/finalize reduced contexts.
- [ ] SCN-BUG-024-009 exposes only the closed CLI forms and accepts no bypass surface.
- [ ] SCN-BUG-024-010 proves per-directory and one-to-one numbered single-file mapping.
- [ ] SCN-BUG-024-011 retains no-scenario behavior according to applicability.
- [ ] SCN-BUG-024-012 preserves DoD starts 1-4 and nested tiers through depth 6.
- [ ] SCN-BUG-024-013 distinguishes boundaries, false starts, rowless, missing, ambiguous, and read failure.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior use the real production CLI over isolated filesystem packets.
- [ ] Broader E2E regression suite passes without claiming live browser or API infrastructure.

#### Test Evidence Items

- [ ] T-BUG-024-000 records causal pre-fix RED before production source changes.
- [ ] T-BUG-024-001 proves exact descendant omission. ([Evidence](report.md#t-bug-024-001))
- [ ] T-BUG-024-002 proves completed-prerequisite gaps block. ([Evidence](report.md#t-bug-024-002))
- [ ] T-BUG-024-003 proves independent and non-not-started descendant gaps remain visible. ([Evidence](report.md#t-bug-024-003))
- [ ] T-BUG-024-004 proves canonical registry and currentScope aliases. ([Evidence](report.md#t-bug-024-004))
- [ ] T-BUG-024-005 proves execution registry precedence and contradiction refusal. ([Evidence](report.md#t-bug-024-005))
- [ ] T-BUG-024-006 proves malformed identity/type/graph refusal. ([Evidence](report.md#t-bug-024-006))
- [ ] T-BUG-024-007 proves path/filesystem/completion refusal. ([Evidence](report.md#t-bug-024-007))
- [ ] T-BUG-024-008 proves terminal and final-context refusal. ([Evidence](report.md#t-bug-024-008))
- [ ] T-BUG-024-009 proves the closed CLI surface. ([Evidence](report.md#t-bug-024-009))
- [ ] T-BUG-024-010 proves both layout mappings. ([Evidence](report.md#t-bug-024-010))
- [ ] T-BUG-024-011 proves no-scenario applicability behavior. ([Evidence](report.md#t-bug-024-011))
- [ ] T-BUG-024-012 proves DoD depths 1-4 and nested levels through 6. ([Evidence](report.md#t-bug-024-012))
- [ ] T-BUG-024-013 proves DoD boundary and extractor-status adversaries. ([Evidence](report.md#t-bug-024-013))
- [ ] T-BUG-024-014 passes focused applicable-universe foundation cases. ([Evidence](report.md#t-bug-024-014))
- [ ] T-BUG-024-015 passes focused DoD-extraction foundation cases. ([Evidence](report.md#t-bug-024-015))
- [ ] T-BUG-024-016 proves adversarial regression integrity. ([Evidence](report.md#t-bug-024-016))

#### Build Quality Gate

- [ ] The same frozen persistent regression bytes fail before and pass after the repair.
- [ ] Regression assertions use production output, not copied helpers, fixture echoes, internal mocks, or silent-pass bailout.
- [ ] Scope 1 mutations stay inside its surgical boundary and preserve every protected byte.

### Evidence Status

All DoD items are intentionally unchecked. This intake executed only the
read-only consumer reproduction in [report.md](report.md#bug-reproduction---before-fix).
No physical BUG-024 regression, implementation, post-fix check, formal packet
gate, framework validation, release check, upgrade, or certification run
occurred. The matching not-run anchors in [report.md](report.md#planned-test-evidence-anchors)
state the exact owner and command that can resolve each item.

### Owner Route

`bubbles.test` is the exact next required owner. It owns the complete final
bytes of the reserved persistent regression and causal RED before
`bubbles.implement` may edit production source.

## Scope 2: Guard Integration, Terminal Parity, And Canonical Delivery

**Status:** Not Started
**Depends On:** Scope 1
**Scope-Kind:** runtime-behavior

### Outcome

Every applicable traceability pass consumes the Scope 1 projection,
state-transition Check 4A and Check 22 apply matching selected-depth DoD
semantics without gaining reduced context, and the complete canonical release
reaches supported downstream consumers with all-scope integrity intact.

### Gherkin Scenarios

#### SCN-BUG-024-014: one projection feeds every traceability pass

```gherkin
Scenario: SCN-BUG-024-014 one projection feeds every traceability pass
  Given Scope 1 has produced one validated applicableKeys and scenarioIds projection
  When G057 G059 scenario-to-Test-Plan physical-path report-evidence and traceability G068 passes run
  Then every pass iterates only that projection in current-scope context
  And default or explicit all-scope context projects every discovered unit
```

#### SCN-BUG-024-015: terminal Check 4A and Check 22 share DoD semantics

```gherkin
Scenario: SCN-BUG-024-015 terminal Check 4A and Check 22 share DoD semantics
  Given the same depth-1-through-4 DoD boundary matrix is presented to traceability and state-transition guards
  When state-transition Check 4A G041 and Check 22 G068 execute in all-scope mode
  Then both retain nested tiers and distinguish rowless missing ambiguous and read failure
  And existing G068 trace-id and word-overlap thresholds remain unchanged
```

#### SCN-BUG-024-016: BUG-018 Test Plan behavior and bytes stay unchanged

```gherkin
Scenario: SCN-BUG-024-016 BUG-018 Test Plan behavior and bytes stay unchanged
  Given every BUG-018 artifact and test_25 byte matches its pre-BUG-024 identity
  When test_25 executes after BUG-024 integration
  Then level-2 and level-3 Test Plan extraction remains green with its existing diagnostics and caller survival
```

#### SCN-BUG-024-017: managed and final consumers remain all-scope

```gherkin
Scenario: SCN-BUG-024-017 managed and final consumers remain all-scope
  Given managed selftests done-spec audit validate audit finalize and direct default consumers are registered
  When they execute after production integration
  Then no consumer passes --current-scope and every descendant gap remains visible
```

#### SCN-BUG-024-018: shell behavior is portable across supported Bash runtimes

```gherkin
Scenario: SCN-BUG-024-018 shell behavior is portable across supported Bash runtimes
  Given the exact changed shell files use real JSON parsing and portable userland forms
  When syntax and the focused matrix run under macOS system Bash 3.2 and supported Linux Bash
  Then result classes counts diagnostics cleanup and public exits are equivalent
```

#### SCN-BUG-024-019: canonical release and supported downstream replay agree

```gherkin
Scenario: SCN-BUG-024-019 canonical release and supported downstream replay agree
  Given managed guards and selftests source-only test_31 docs capability projections and release identity are owner-produced
  When canonical-source current-scope then all-scope replay run before supported upgrade
  And installed current-scope then all-scope replay run after supported upgrade
  Then current Scope 01 closes only its valid universe while both all-scope runs retain descendant gaps
```

### Implementation Plan

1. Wire G057/G059, scenario-to-Test-Plan mapping, concrete test paths, report
  evidence, and traceability G068 to the one Scope 1 applicable projection;
  prohibit post-resolution `find`, raw scope arrays, or status rediscovery.
2. Apply matching selected-depth DoD semantics only within
  `state-transition-guard.sh` Check 4A and Check 22, preserving all-scope
  invocation and existing G068 thresholds.
3. `bubbles.test` adds BUG-024 blocks to both managed selftests and runs the
  same DoD matrix through traceability and terminal consumers.
4. Add exactly one source-only framework registration and direct install
  provenance assertions; register the capability and real consumers.
5. Execute unchanged BUG-018, done-spec/all-scope canaries, focused
  portability, packet gates, framework validation, provenance, docs, release,
  supported upgrade, and downstream replay in checkpoint order.

### Consumer Impact Sweep

- G057/G059 manifest checks, Test Plan mapping, physical paths, report
  evidence, and traceability G068 share one projection.
- State-transition Check 4A/22 share DoD semantics but never receive current
  context.
- Direct maintainers, plan, validate, audit, finalize, done-spec audit, and
  terminal promotion continue default/all-scope invocation.
- Registration, provenance, capability ledger, generated docs, release
  identity, and installed bytes are explicit consumers.
- Stale-reference proof covers every `traceability-guard.sh` invocation and
  rejects caller-supplied scope values or reduced final-context calls.

### Shared Infrastructure Impact Sweep

The two managed guards and managed selftests are shared infrastructure.
Independent canaries are focused production behavior, both managed suites,
unchanged BUG-018, state-transition parity, done-spec audit, framework
validation, provenance, release check, and canonical/installed downstream
replay. Rollback restores BUG-024 regions and the coherent release while
retaining concurrent G040/G073 regions.

### Change Boundary

Scope 2 is restricted to the shared allowed table. In state-transition files,
only Check 4A/22 scanner functions and an additive BUG-024 selftest block may
change. Whole-file replacement, formatting sweeps, unrelated cleanup, and
changes to G040/G073 functions or fixtures are prohibited.

### Test Environment Isolation

Managed and persistent fixtures use unique process-owned temporary roots and
cleanup traps. Downstream source replays are read-only. The supported upgrade
is owned by `bubbles.devops`; it writes only framework-managed installation
bytes through the canonical command and never patches Research Lab manually.

### Test Plan

All rows are local CLI/filesystem checks with `Live System: No`; even cross-repo
replay exercises a real guard against a real packet without a browser, API
server, database, or network service.

| Test Type | Test ID | Scenario(s) | Category | File / Location | Exact behavior | Command | Live System | Owner | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E (CLI) | T-BUG-024-017 | Projection integration contract | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | One projection feeds every traceability pass in current and all-scope contexts. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-014` | No | `bubbles.test` | [T-BUG-024-017](report.md#t-bug-024-017) |
| Adversarial Regression E2E (CLI) | T-BUG-024-018 | Terminal DoD parity contract | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Terminal Check 4A and Check 22 share DoD semantics while G068 thresholds retain their existing values. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case terminal-dod-parity` | No | `bubbles.test` | [T-BUG-024-018](report.md#t-bug-024-018) |
| Existing Regression E2E (CLI) | T-BUG-024-019 | BUG-018 compatibility contract | functional | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | BUG-018 Test Plan behavior and bytes stay unchanged while test_25 remains green. | `git diff --exit-code -- improvements/BUG-018-traceability-test-plan-heading-depth tests/regression/test_25_traceability_test_plan_heading_depth.sh && bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | No | `bubbles.test` | [T-BUG-024-019](report.md#t-bug-024-019) |
| Regression E2E (CLI) | T-BUG-024-020 | SCN-BUG-024-017 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Managed/final/default consumers remain all-scope and expose descendant gaps. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-017` | No | `bubbles.test` | [T-BUG-024-020](report.md#t-bug-024-020) |
| Regression E2E (CLI) | T-BUG-024-021 | SCN-BUG-024-018 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Focused behavior is equivalent under supported Bash runtimes. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-018` | No | `bubbles.test` | [T-BUG-024-021](report.md#t-bug-024-021) |
| Regression E2E (CLI) | T-BUG-024-022 | SCN-BUG-024-019 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Registration/provenance/release/downstream contracts remain canonical and owner-separated. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-019` | No | `bubbles.test` | [T-BUG-024-022](report.md#t-bug-024-022) |
| Managed Traceability Selftest | T-BUG-024-023 | SCN-BUG-024-014, SCN-BUG-024-017 | functional | `bubbles/scripts/traceability-guard-selftest.sh` | Existing plus additive applicability/projection/DoD cases pass through production. | `bash bubbles/scripts/traceability-guard-selftest.sh` | No | `bubbles.test` | [T-BUG-024-023](report.md#t-bug-024-023) |
| Managed State-Transition Selftest | T-BUG-024-024 | SCN-BUG-024-015, SCN-BUG-024-017 | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | Check 4A/22 parity passes while state-transition remains all-scope. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | No | `bubbles.test` | [T-BUG-024-024](report.md#t-bug-024-024) |
| Done-Spec Consumer | T-BUG-024-025 | SCN-BUG-024-017 | integration | `bubbles/scripts/done-spec-audit-selftest.sh` | Done-spec audit never selects reduced context and retains descendant findings. | `bash bubbles/scripts/done-spec-audit-selftest.sh` | No | `bubbles.test` | [T-BUG-024-025](report.md#t-bug-024-025) |
| Default/All-Scope Canary | T-BUG-024-026 | SCN-BUG-024-014, SCN-BUG-024-017 | functional | `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | One-argument and --all-scopes runs are equivalent and complete. | `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case all-scope-consumers` | No | `bubbles.test` | [T-BUG-024-026](report.md#t-bug-024-026) |
| Cross-Platform Portability | T-BUG-024-027 | SCN-BUG-024-018 | functional | `bubbles/scripts/traceability-guard.sh; bubbles/scripts/traceability-guard-selftest.sh; bubbles/scripts/state-transition-guard.sh; bubbles/scripts/state-transition-guard-selftest.sh; tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Bash syntax and portability pass over only changed shell files. | `/bin/bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | No | `bubbles.test` | [T-BUG-024-027](report.md#t-bug-024-027) |
| Packet Artifact Lint | T-BUG-024-028 | SCN-BUG-024-014 through SCN-BUG-024-019 | functional | `improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | Canonical artifact structure and planning ownership pass. | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | No | `bubbles.test` | [T-BUG-024-028](report.md#t-bug-024-028) |
| Packet Freshness | T-BUG-024-029 | SCN-BUG-024-014 through SCN-BUG-024-019 | functional | `improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | Active artifacts contain no executable stale scope. | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | No | `bubbles.test` | [T-BUG-024-029](report.md#t-bug-024-029) |
| Capability Foundation Gate | T-BUG-024-030 | SCN-BUG-024-014 | functional | `improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | G094 accepts Scope 1 foundation ordering and Scope 2 dependency. | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | No | `bubbles.test` | [T-BUG-024-030](report.md#t-bug-024-030) |
| Packet Traceability | T-BUG-024-031 | SCN-BUG-024-001 through SCN-BUG-024-019 | functional | `improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | All scenarios map to exact rows, files, anchors, and DoD after delivery bytes exist. | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod` | No | `bubbles.test` | [T-BUG-024-031](report.md#t-bug-024-031) |
| Framework Integration | T-BUG-024-032 | SCN-BUG-024-014 through SCN-BUG-024-019 | integration | `bubbles/scripts/cli.sh` | Exactly-once source-only registration and all framework checks pass. | `bash bubbles/scripts/cli.sh framework-validate` | No | `bubbles.test` | [T-BUG-024-032](report.md#t-bug-024-032) |
| Install Provenance | T-BUG-024-033 | SCN-BUG-024-019 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Changed guards/selftests are managed and test_31 is source-only. | `bash bubbles/scripts/install-provenance-selftest.sh` | No | `bubbles.test` | [T-BUG-024-033](report.md#t-bug-024-033) |
| Capability Documentation | T-BUG-024-034 | SCN-BUG-024-019 | functional | `bubbles/scripts/capability-ledger-selftest.sh` | Ledger and owner-generated projections are current and source-backed. | `bash bubbles/scripts/capability-ledger-selftest.sh` | No | `bubbles.docs` | [T-BUG-024-034](report.md#t-bug-024-034) |
| Release Integration | T-BUG-024-035 | SCN-BUG-024-019 | integration | `bubbles/scripts/generate-release-manifest.sh; bubbles/scripts/cli.sh` | Release owner generates identity, verifies it, and passes release checks. | `bash bubbles/scripts/generate-release-manifest.sh && bash bubbles/scripts/generate-release-manifest.sh --check && bash bubbles/scripts/cli.sh release-check` | No | `bubbles.releases` | [T-BUG-024-035](report.md#t-bug-024-035) |
| Downstream Source Current-Scope Replay | T-BUG-024-036 | SCN-BUG-024-019 | integration | `../research-lab/specs/007-technical-analysis-decision-lab` | Canonical guard closes only valid current Scope 01 without downstream writes. | `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab --current-scope` | No | `bubbles.test` | [T-BUG-024-036](report.md#t-bug-024-036) |
| Downstream Source All-Scope Proof | T-BUG-024-037 | SCN-BUG-024-019 | integration | `../research-lab/specs/007-technical-analysis-decision-lab` | Canonical one-argument guard still exposes descendant execution gaps. | `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab` | No | `bubbles.test` | [T-BUG-024-037](report.md#t-bug-024-037) |
| Supported Downstream Upgrade | T-BUG-024-038 | SCN-BUG-024-019 | integration | `../research-lab/.github/bubbles/scripts/cli.sh` | Canonical release is delivered without manual managed-byte edits. | `cd ../research-lab && bash .github/bubbles/scripts/cli.sh upgrade` | No | `bubbles.devops` | [T-BUG-024-038](report.md#t-bug-024-038) |
| Downstream Installed Current-Scope Replay | T-BUG-024-039 | SCN-BUG-024-019 | integration | `../research-lab/.github/bubbles/scripts/traceability-guard.sh` | Installed guard closes the same valid current Scope 01 universe. | `cd ../research-lab && bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab --current-scope` | No | `bubbles.test` | [T-BUG-024-039](report.md#t-bug-024-039) |
| Downstream Installed All-Scope Proof | T-BUG-024-040 | SCN-BUG-024-019 | integration | `../research-lab/.github/bubbles/scripts/traceability-guard.sh` | Installed one-argument guard retains descendant gaps. | `cd ../research-lab && bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab` | No | `bubbles.test` | [T-BUG-024-040](report.md#t-bug-024-040) |

### Definition of Done - Tiered Validation

#### Core Items

- [ ] SCN-BUG-024-014 proves G057/G059, Test Plan, physical path, report evidence, and traceability G068 use one projection.
- [ ] SCN-BUG-024-015 proves state-transition Check 4A/22 parity with unchanged G068 thresholds and all-scope invocation.
- [ ] SCN-BUG-024-016 preserves every BUG-018 and test_25 byte and behavior.
- [ ] SCN-BUG-024-017 keeps managed, done-spec, validate, audit, finalize, and default consumers all-scope.
- [ ] SCN-BUG-024-018 proves equivalent macOS Bash 3.2 and supported Linux behavior.
- [ ] SCN-BUG-024-019 proves owner-separated registration, provenance, docs, release, upgrade, and downstream replay.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior use the real production CLI over isolated filesystem packets.
- [ ] Broader E2E regression suite passes without claiming live browser or API infrastructure.
- [ ] Consumer impact sweep is complete and zero stale first-party traceability invocations remain.
- [ ] Shared infrastructure canaries and coherent rollback proof cover both managed guards and selftests.

#### Test Evidence Items

- [ ] T-BUG-024-017 proves one projection feeds every traceability pass. ([Evidence](report.md#t-bug-024-017))
- [ ] T-BUG-024-018 proves state-transition Check 4A/22 parity and unchanged thresholds. ([Evidence](report.md#t-bug-024-018))
- [ ] T-BUG-024-019 proves BUG-018 bytes and test_25 behavior remain unchanged. ([Evidence](report.md#t-bug-024-019))
- [ ] T-BUG-024-020 proves managed and final consumers remain all-scope. ([Evidence](report.md#t-bug-024-020))
- [ ] T-BUG-024-021 proves focused cross-platform behavior. ([Evidence](report.md#t-bug-024-021))
- [ ] T-BUG-024-022 proves canonical owner-separated delivery contracts. ([Evidence](report.md#t-bug-024-022))
- [ ] T-BUG-024-023 passes the complete managed traceability selftest. ([Evidence](report.md#t-bug-024-023))
- [ ] T-BUG-024-024 passes the complete managed state-transition selftest. ([Evidence](report.md#t-bug-024-024))
- [ ] T-BUG-024-025 proves done-spec audit remains all-scope. ([Evidence](report.md#t-bug-024-025))
- [ ] T-BUG-024-026 proves default and explicit all-scope equivalence. ([Evidence](report.md#t-bug-024-026))
- [ ] T-BUG-024-027 proves syntax and focused portability. ([Evidence](report.md#t-bug-024-027))
- [ ] T-BUG-024-028 passes artifact lint. ([Evidence](report.md#t-bug-024-028))
- [ ] T-BUG-024-029 passes artifact freshness. ([Evidence](report.md#t-bug-024-029))
- [ ] T-BUG-024-030 passes G094 foundation ordering. ([Evidence](report.md#t-bug-024-030))
- [ ] T-BUG-024-031 passes packet traceability after delivery bytes exist. ([Evidence](report.md#t-bug-024-031))
- [ ] T-BUG-024-032 passes full framework validation. ([Evidence](report.md#t-bug-024-032))
- [ ] T-BUG-024-033 proves managed/source-only install provenance. ([Evidence](report.md#t-bug-024-033))
- [ ] T-BUG-024-034 proves capability ledger and generated docs are current. ([Evidence](report.md#t-bug-024-034))
- [ ] T-BUG-024-035 proves owner-generated release identity and release checks. ([Evidence](report.md#t-bug-024-035))
- [ ] T-BUG-024-036 proves canonical-source current-scope replay without downstream writes. ([Evidence](report.md#t-bug-024-036))
- [ ] T-BUG-024-037 proves canonical-source all-scope gaps remain visible. ([Evidence](report.md#t-bug-024-037))
- [ ] T-BUG-024-038 proves supported downstream upgrade delivery. ([Evidence](report.md#t-bug-024-038))
- [ ] T-BUG-024-039 proves installed current-scope replay. ([Evidence](report.md#t-bug-024-039))
- [ ] T-BUG-024-040 proves installed all-scope gaps remain visible. ([Evidence](report.md#t-bug-024-040))

#### Build Quality Gate

- [ ] Surgical marker/function ownership preserves concurrent G040/G073 hunks and every protected file.
- [ ] Registration, provenance, capability docs, release identity, and installed bytes agree.
- [ ] No source test, release, install, downstream, certification, or terminal-status claim is made without owner-authored execution evidence.
- [ ] `bubbles.validate` alone writes certification and terminal status after independent validation and audit.

## Planning Handoff

All 19 scenario contracts, 41 Markdown Test Plan rows, 41 machine Test Plan
rows, 41 unchecked test-evidence DoD items, and 41 report anchors must remain
exactly synchronized. The next owner is `bubbles.test` for final physical
`test_31` bytes and frozen causal RED; production implementation is not
authorized before that result is recorded against a stable source identity.
