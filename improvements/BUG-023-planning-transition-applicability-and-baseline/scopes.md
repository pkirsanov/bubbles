# Scopes: BUG-023 Planning Transition Applicability And Baseline

## Planning Status

Planning reconciliation is complete for the final analyst, UX, and design
contract. This plan authorizes execution only after `bubbles.test` writes the
complete persistent regression file once, records its SHA-256 identity, and
captures the causal RED result. Every scope remains `Not Started`; every DoD
item remains unchecked. No source, test, release, propagation, downstream, or
certification result is claimed here.

Related artifacts: [spec.md](spec.md), [design.md](design.md),
[report.md](report.md), and [uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Scope 1 - Baseline and exact-comparison foundation:** establish the shared
  source-state model, immutable run binding, V2 result foundation, lifecycle,
  six-state equality, and eight-class mutation attribution.
2. **Scope 2 - Provenance and legacy G073:** fail closed for the complete
   malformed/adversarial provenance matrix, preserve original-baseline reuse
   on retry, and retain legacy whole-worktree lockout.
3. **Scope 3 - G060 applicability overlay:** record planning runtime evidence
   as `NOT_APPLICABLE` while preserving missing, out-of-order, and ordered
   delivery behavior for both delivery modes.
4. **Scope 4 - G040 accepted-context overlay:** add the finite classifier and
   prove the exact title, noun, structured-label, and present-surface cases.
5. **Scope 5 - G040 blocking and compatibility closure:** enforce blocking
   precedence, finish all V2 consumers and managed selftests, prove portable
   behavior, validate installer/release bytes, and leave downstream
   certification to a fresh post-upgrade discriminator run.

### New Types And Signatures

- `planning-source-baseline/v1` immutable runtime payload.
- `planning-source-baseline-ref/v1` additive
  `state.json.execution.planningSourceBaseline` reference.
- `planning-source-baseline-result/v1` capture/reuse/close result.
- `transition-guard-result/v2` with canonical
  `transition-gate-results/v1` JSON and digest.
- `g040_classify_statement <raw-physical-line>` producing the closed scan,
  phrase, and reason globals from `design.md`.
- `planning-source-baseline.sh capture <feature-dir>` and
  `planning-source-baseline.sh close <feature-dir> --outcome completed|aborted`.
- `test_30_planning_transition_applicability_and_baseline.sh [--scenario <SCN-ID>]`;
  no arguments runs the complete frozen matrix and unknown arguments fail.

### Validation Checkpoints

- Before Scope 1 implementation: `bubbles.test` writes final `test_30` bytes,
  records their digest, and captures RED with those exact bytes.
- After every scope: run only that scope's named scenario selectors, its
  independent canary, and the unchanged frozen-file digest check before the
  next scope starts.
- After Scope 2: run the complete G073 malformed/adversarial and legacy matrix
  plus baseline lifecycle, state schema, result schema, and MCP twin canaries.
- After Scope 3: run the six-case delivery matrix and the BUG-009 audit
  compatibility regression.
- After Scope 5: run the full frozen `test_30`, all managed selftests,
  portability and consumer mutation checks, `framework-validate`, and
  `release-check` before release/upgrade evidence is collected.
- Canonical validation, installed-byte parity, supported downstream upgrade,
  and the fresh QuantitativeFinance discriminator are separate evidence
  boundaries; none substitutes for another.

## Scope Inventory

| # | Scope | Depends On | Status |
| --- | --- | --- | --- |
| 1 | Baseline Capture, Equality, And Mutation Foundation | None | Not Started |
| 2 | G073 Provenance, Retry, And Legacy Semantics | Scope 1 (foundation) | Not Started |
| 3 | G060 Profile Applicability Without Delivery Relaxation | Scope 1 (foundation), Scope 2 | Not Started |
| 4 | G040 Accepted Contexts | Scope 1 (foundation), Scope 3 | Not Started |
| 5 | G040 Blocking Precedence And Compatibility Closure | Scope 1 (foundation), Scope 4 | Not Started |

## Shared Change Boundary

**Allowed production/contract families:** the exact canonical files enumerated
in `design.md` under Change Boundary And Ownership: the transition guard,
control-plane and guard libraries, new G040/G073 sourced helpers, authoritative
baseline helper, V2 audit-result consumer, MCP descriptor, capability ledger,
workflow/audit/shared governance consumers, control-plane schema guide, and
owner-regenerated release manifest/projections.

**Allowed test/release families:** the managed transition, baseline, audit
contract, MCP, install-provenance, BUG-009 compatibility, frozen BUG-023
regression, framework-validation wiring, release notes, and owner-controlled
release identity named by `design.md`.

**Excluded surfaces:** `install.sh` behavior, `state-snapshot.sh`, state
templates, workflow/gate registries, protected-path-universe expansion,
unrelated transition refactors, application source, sibling packets, every
downstream managed framework copy, QuantitativeFinance Spec 097, release-train
configuration, and every skip/force/ignore/allow-once/path-pattern surface.
Collateral edits require an explicit planning revision before execution.

## Shared Infrastructure Impact Sweep

The transition guard, result schema, workflow runner, state execution metadata,
installer manifest, and MCP catalog are high-fan-out framework surfaces.
Independent canaries must prove: unchanged delivery G060 ordering; unchanged
legacy Check 3B behavior; BUG-009 audit-consumer compatibility; V2 digest and
field-order rejection; MCP/direct-bash byte-equivalent result contracts;
managed install parity; and no mutation of protected foreign dirt. The rollback
unit is one coherent canonical revision restoring V1 producer/consumers and
removing all BUG-023 integrations together; runtime sidecars remain ignored and
inert, and historical evidence is never rewritten.

## Consumer Impact Sweep

Execution must update every first-party consumer named in `design.md`:
`bubbles.audit`, `audit-result-contract-lint.sh`, transition and audit
selftests, BUG-009 regression, `done-spec-audit.sh`, CLI `guard`, the top-level
planning runner, MCP catalog/server dispatch, installer/upgrade manifests,
capability projections, governance text, and control-plane schema docs. Before
completion, exact stale-reference searches must show no fresh V1-only parser,
missing baseline-helper registration, old G060 planning-pass assumption, or
G073 current-path-only attribution path. Historical V1 report transcripts are
immutable history and are not rewritten.

## Frozen Final-Byte Regression Contract

`bubbles.test` owns
`tests/regression/test_30_planning_transition_applicability_and_baseline.sh`.
It writes the complete file once before the first RED execution and records
`shasum -a 256` at `report.md#frozen-test-byte-identity`. Every later RED,
focused, GREEN, regression, framework, and release run first proves that digest
is unchanged. Any byte change after causal RED invalidates that run and
requires a new test-owner RED cycle before implementation continues.

The script interface is closed:

- no arguments execute the ordered 17-scenario matrix and all cross-scenario
  adversarial controls;
- `--scenario SCN-BUG-023-NNN` executes exactly that scenario's complete
  vector set, including variants and negative controls;
- `-h|--help` prints usage and exits 0 without fixtures;
- every other argument or scenario ID prints one usage error and exits 64;
- no skip, force, ignore, update-golden, accept, recapture, path-list, or
  environment bypass is accepted.

Every case creates a disposable Git repository, invokes the real canonical
production helper/guard path, asserts the complete structured result and exit
status, and removes its own fixture on exit. No case edits canonical source,
reuses another case's repository, reads a downstream managed copy, or asserts
on test-injected output that bypasses production code.

### Ordered Scenario Matrix

| Order | Scenario | Frozen case name | Required vectors and production-path assertions |
| --- | --- | --- | --- |
| 01 | SCN-BUG-023-001 | `planning_g060_not_applicable` | Planning profile, no runtime evidence; exactly one G060 `NOT_APPLICABLE`, reason `PROFILE_PLANNING_MATURITY`, no G060 pass/fail attribution. |
| 02 | SCN-BUG-023-002 | `delivery_missing_evidence_blocks` | `full-delivery`, scenario-first active, evidence absent; G060 blocks with `RED_GREEN_EVIDENCE_MISSING`. |
| 03 | SCN-BUG-023-003 | `delivery_green_before_red_blocks` | `bugfix-fastlane`, GREEN before RED; G060 blocks with `GREEN_PRECEDES_RED` and never reports N/A. |
| 04 | SCN-BUG-023-004 | `g040_title_domain_label_accepts` | Exact label, uppercase, and terminal-punctuation variants; zero findings and `TITLE_OR_DOMAIN_LABEL`. |
| 05 | SCN-BUG-023-005 | `g040_followup_projection_accepts` | Exact noun phrase, uppercase, and terminal-punctuation variants; zero findings and `NOUN_COMPOUND`. |
| 06 | SCN-BUG-023-006 | `g040_structured_label_accepts` | Heading, table cell, and field-label forms, each exact/uppercase/punctuated; zero findings and `STRUCTURED_LABEL`. |
| 07 | SCN-BUG-023-007 | `g040_present_surface_accepts` | Both BR-023-004 present-surface sentences plus case/punctuation variants; zero findings and `PRESENT_SURFACE`. |
| 08 | SCN-BUG-023-008 | `g040_work_disposition_blocks` | Four work-disposition examples plus uppercase/punctuation variants; exact-line `WORK_DISPOSITION` blocks. |
| 09 | SCN-BUG-023-009 | `g040_future_schedule_blocks` | Future work/scope and next sprint/iteration examples plus variants; each line blocks with its closed scheduling reason. |
| 10 | SCN-BUG-023-010 | `g040_fix_address_later_blocks` | Four fix/address examples plus variants and token-window controls; in-window blocks with the exact reason and window+1 is `NO_MATCH`. |
| 11 | SCN-BUG-023-011 | `g040_blocking_precedence_wins` | Accepted label and blocker on one physical line; one blocking detail, positive line number, withheld content, stable digest. |
| 12 | SCN-BUG-023-012 | `baseline_capture_precedes_writes` | Stable pre-write capture; complete payload/ref, one run ID, atomic ordering, caller observations rejected, repeated capture reuses bytes. |
| 13 | SCN-BUG-023-013 | `baseline_six_states_audited` | Staged-only, unstaged-only, mixed, untracked, rename, and delete fixtures; six visible audited rows, no mutation or omission. |
| 14 | SCN-BUG-023-014 | `baseline_eight_mutations_block` | Appeared path, index, worktree, type/mode, clean, rename, delete, and post-start commit mutations; exact path/reason and block. |
| 15 | SCN-BUG-023-015 | `baseline_invalid_provenance_blocks` | Complete invalid-provenance matrix below; block before comparison, zero exclusions, no repair or recapture. |
| 16 | SCN-BUG-023-016 | `baseline_retry_reuses_original` | Post-capture mutation plus resume/retry; same run/ref/digest and sidecar bytes, `BASELINE_REUSED`, changed path blocks. |
| 17 | SCN-BUG-023-017 | `legacy_without_baseline_locks_worktree` | Baseline key absent plus protected dirt; legacy whole-worktree lockout and no synthesized baseline. |

### Cross-Scenario Adversarial Controls

1. Delivery matrix: `full-delivery` and `bugfix-fastlane`, each with missing,
   GREEN-before-RED, and ordered RED-before-GREEN evidence; the first four
   block and both ordered controls retain the existing delivery verdict.
2. G040 structural exclusions, segment boundaries, case, punctuation,
   parentheses, table cells, line numbers, same-line collisions, in-window
   matches, and window+1 no-match boundaries are deterministic under
   `LC_ALL=C`.
3. G073 covers spaces, executable mode, symlink target, file-to-symlink,
   tracked delete, every index/worktree state, rename, committed-after-start,
   divergent HEAD, capture race, and compare race.
4. Result consumers reject missing/reordered V2 fields, noncanonical gate JSON,
   incorrect digest, planning G060 marked pass, delivery G060 marked N/A,
   audited G073 marked actionable, and failed G073 with the wrong outer code.
5. Caller run/HEAD/path observations, arbitrary path lists, unsafe paths,
   globs, regexes, prefixes, recapture, skip, force, and ignore inputs fail
   closed.

### Invalid Baseline Matrix

| Vector | Required reason family |
| --- | --- |
| unreadable payload | `BASELINE_PAYLOAD_UNREADABLE` |
| malformed JSON | `BASELINE_PAYLOAD_MALFORMED` |
| unsupported schema | `BASELINE_SCHEMA_UNSUPPORTED` |
| missing required field | `BASELINE_REQUIRED_FIELD_MISSING` |
| duplicate exact path/relation | `BASELINE_PATH_DUPLICATE` |
| absolute, traversal, control, glob, regex, prefix, or overlong path | `BASELINE_PATH_UNSAFE` |
| unsupported status | `BASELINE_STATUS_UNSUPPORTED` |
| unsupported file type | `BASELINE_TYPE_UNSUPPORTED` |
| missing or invalid per-entry identity | `BASELINE_ENTRY_IDENTITY_INVALID` |
| missing or malformed digest | `BASELINE_DIGEST_MISSING_OR_INVALID` |
| recomputed payload digest mismatch | `BASELINE_DIGEST_MISMATCH` |
| declared sidecar missing | `BASELINE_SIDECAR_MISSING` |
| spec/mode/profile binding mismatch | matching closed binding reason |
| repository/run binding mismatch | matching closed binding reason |
| start-HEAD/transition binding mismatch | matching closed binding reason |
| unresolved or divergent start HEAD | start-HEAD unresolved or mismatch reason |

<!-- markdownlint-disable MD024 -->

## Scope 1: Baseline Capture, Equality, And Mutation Foundation

**Status:** Not Started
**Depends On:** None
**Foundation:** true
**Tags:** foundation:true
**Scope-Kind:** runtime-behavior

### Scope 1 Change Boundary

Allowed: shared G073 source-state helper, authoritative baseline helper, V2 gate
result recorder, additive execution reference/history, workflow capture/close,
declared-baseline exact comparison, MCP descriptor/twin dispatch, and owned
tests. Excluded: G040/G060 decisions, legacy/invalid-provenance semantics,
protected-universe changes, state templates, installer behavior, downstream
copies, and unrelated guard branches.

### Scope 1 Gherkin Scenarios

#### SCN-BUG-023-012: authoritative capture precedes planning writes

```gherkin
Scenario: SCN-BUG-023-012 authoritative capture precedes planning writes
  Given the framework has resolved the spec, mode, repository, and start HEAD
  And no planning owner has mutated the repository for this run
  When the authoritative framework runtime captures the baseline
  Then the immutable envelope is bound to that run and capture time
  And callers cannot supply or amend observed path identities
```

#### SCN-BUG-023-013: unchanged pre-run dirt is audited and excluded

```gherkin
Scenario Outline: SCN-BUG-023-013 unchanged pre-run dirt is audited and excluded
  Given a valid bound baseline contains an exact protected path in <state_class> state
  When every captured identity for that path remains equal
  Then G073 lists the path as audited pre-existing work
  And G073 does not attribute that path to the planning run
  Examples:
    | state_class                 |
    | staged-only                |
    | unstaged-only              |
    | mixed staged and unstaged  |
    | untracked                  |
    | rename                     |
    | delete                     |
```

#### SCN-BUG-023-014: new or mutated protected dirt blocks

```gherkin
Scenario Outline: SCN-BUG-023-014 new or mutated protected dirt blocks
  Given a valid bound baseline exists
  And a protected path has <change>
  When G073 compares run-start and transition identities
  Then G073 reports the exact path and blocks the transition
  Examples:
    | change                                      |
    | appeared after capture                      |
    | changed index identity                      |
    | changed worktree content digest             |
    | changed file type or executable mode        |
    | changed from dirty to clean                 |
    | changed rename endpoints                    |
    | changed deletion state                      |
    | entered a protected commit after start HEAD |
```

### Scope 1 Implementation Plan

1. Freeze/hash the complete `test_30`, then capture causal RED before source.
2. Implement one portable source-state model shared by capture/comparison.
3. Implement atomic capture/reuse/close with lock, double observation, exact
  bindings, immutable sidecar, and additive execution reference/history.
4. Establish V2 canonical gate-result recording without changing gate choices.
5. Wire workflow and MCP to the same Bash twin, dispatching only after capture.
6. Validate bound provenance, enumerate protected commits, and compare complete
  sorted baseline/current entry sets with exact identity obligations.
7. Emit visible audited rows for all six equal state classes and deterministic
  blocks for all eight mutation classes; double-check repository stability.
8. Run legacy Check 3B and BUG-009 independent canaries.

### Test Plan

| Test Type | Test ID | Scenario | Category | File/Location | Description | Command | Live System | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E | T-BUG-023-012 | SCN-BUG-023-012 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Persistent pre-write capture, immutable binding, rejected observations, and reuse regression. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-012` | Yes | `report.md#t-bug-023-012` |
| Regression E2E | T-BUG-023-013 | SCN-BUG-023-013 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Persistent six-state equality, audited visibility, and preservation regression. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-013` | Yes | `report.md#t-bug-023-013` |
| Regression E2E | T-BUG-023-014 | SCN-BUG-023-014 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Persistent eight-mutation exact-path/reason regression. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-014` | Yes | `report.md#t-bug-023-014` |
| Managed lifecycle selftest | T-BUG-023-018 | SCN-BUG-023-012 | integration | `bubbles/scripts/planning-source-baseline-selftest.sh` | Atomicity, reuse, close, schema, digest, races, and no path mutation. | `bash bubbles/scripts/planning-source-baseline-selftest.sh` | Yes | `report.md#t-bug-023-018` |
| MCP/direct twin canary | T-BUG-023-019 | SCN-BUG-023-012 | integration | `bubbles/scripts/mcp-server-selftest.sh` | Catalog load and real dispatch to the same Bash twin. | `bash bubbles/scripts/mcp-server-selftest.sh` | Yes | `report.md#t-bug-023-019` |
| Broader transition canary | T-BUG-023-020 | SCN-BUG-023-012 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Existing transition behavior remains coherent with V2/baseline foundation. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes | `report.md#t-bug-023-020` |
| Source-state canary | T-BUG-023-021 | SCN-BUG-023-013, SCN-BUG-023-014 | integration | `bubbles/scripts/planning-source-baseline-selftest.sh` | Identity, relation, commit delta, and race matrix. | `bash bubbles/scripts/planning-source-baseline-selftest.sh` | Yes | `report.md#t-bug-023-021` |
| Guard canary | T-BUG-023-022 | SCN-BUG-023-013, SCN-BUG-023-014 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | G073 detail/outer-code/sorting/overflow integration. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes | `report.md#t-bug-023-022` |
| Consumer regression | T-BUG-023-023 | SCN-BUG-023-013, SCN-BUG-023-014 | e2e-api | `tests/regression/test_23_planning_audit_contract.sh` | BUG-009 compatibility and no audited-row warning drift. | `bash tests/regression/test_23_planning_audit_contract.sh` | Yes | `report.md#t-bug-023-023` |

### Definition of Done - Scope 1 Tiered Validation

Core outcomes:

- [ ] Foundation matches exact schema/lifecycle/authority/disclosure/rollback.
- [ ] Capture/reuse/close is atomic, fail-closed, and path-preserving.
- [ ] Direct Bash and MCP invocation resolve observations internally.
- [ ] All state classes use the exact independent identity obligations.
- [ ] Equal entries remain visible/non-actionable without any mutation.
- [ ] Every post-capture mutation/commit blocks with exact path and reason.
- [ ] Scope 1 boundaries and frozen pre-RED test identity remain intact.

Test evidence:

- [ ] T-BUG-023-012 evidence proves SCN-BUG-023-012 at `report.md#t-bug-023-012`.
- [ ] T-BUG-023-013 evidence proves SCN-BUG-023-013 at `report.md#t-bug-023-013`.
- [ ] T-BUG-023-014 evidence proves SCN-BUG-023-014 at `report.md#t-bug-023-014`.
- [ ] T-BUG-023-018 evidence proves the lifecycle matrix at `report.md#t-bug-023-018`.
- [ ] T-BUG-023-019 evidence proves MCP/direct compatibility at `report.md#t-bug-023-019`.
- [ ] T-BUG-023-020 evidence proves the broader canary at `report.md#t-bug-023-020`.
- [ ] T-BUG-023-021 evidence proves source-state canaries at `report.md#t-bug-023-021`.
- [ ] T-BUG-023-022 evidence proves guard integration at `report.md#t-bug-023-022`.
- [ ] T-BUG-023-023 evidence proves BUG-009 compatibility at `report.md#t-bug-023-023`.

## Scope 2: G073 Provenance, Retry, And Legacy Semantics

**Status:** Not Started
**Depends On:** Scope 1 (foundation)
**Foundation:** false
**Scope-Kind:** runtime-behavior

### Scope 2 Change Boundary

Allowed: declared-provenance validation, active-run retry/reuse, absent-key
legacy branch, V2 G073 consumer validation, and named tests. Excluded:
provenance repair, recapture, state-template insertion, profile selection,
G040/G060, and reinterpretation of historical V1 evidence.

### Scope 2 Gherkin Scenarios

#### SCN-BUG-023-015: invalid baseline provenance blocks

```gherkin
Scenario Outline: SCN-BUG-023-015 invalid baseline provenance blocks
  Given the packet declares a baseline contract with <invalidity>
  When G073 validates the baseline before using any exclusion
  Then G073 identifies the provenance error and blocks the transition
  Examples:
    | invalidity                                  |
    | malformed payload                           |
    | missing declared payload                    |
    | duplicate or unsafe path                    |
    | missing required entry identity             |
    | digest mismatch                             |
    | spec or mode binding mismatch               |
    | repository or run binding mismatch          |
    | start HEAD or transition binding mismatch   |
```

#### SCN-BUG-023-016: retry cannot bless post-start dirt

```gherkin
Scenario: SCN-BUG-023-016 retry cannot bless post-start dirt
  Given a valid baseline was captured for the active framework run
  And a protected path changes after that capture
  When the same run resumes or retries
  Then the original baseline remains authoritative
  And the changed path blocks G073
```

#### SCN-BUG-023-017: legacy packet retains whole-worktree lockout

```gherkin
Scenario: SCN-BUG-023-017 legacy packet retains whole-worktree lockout
  Given a legacy planning packet declares no baseline field or reference
  And a protected source or config path is dirty
  When G073 validates source attribution
  Then the dirt remains unproven and blocks under existing semantics
```

### Scope 2 Implementation Plan

1. Distinguish true key absence from every declared value before comparison.
2. Validate schemas, enums, paths, identities, digest, reference equality, all
   bindings, and start-HEAD ancestry in the exact design order.
3. Reuse active valid run/ref/payload bytes on every resume/retry.
4. Preserve whole-worktree Check 3B only for complete declaration absence.
5. Make audit/result consumers reject every invalid V2 combination.
6. Prove the complete invalid, retry, legacy clean/dirty, and byte-identity
   matrix before Scope 4.

### Test Plan

| Test Type | Test ID | Scenario | Category | File/Location | Description | Command | Live System | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E | T-BUG-023-015 | SCN-BUG-023-015 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Complete invalid-provenance matrix; every reason blocks before exclusions and no repair occurs. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-015` | Yes | `report.md#t-bug-023-015` |
| Regression E2E | T-BUG-023-016 | SCN-BUG-023-016 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Original run/ref/digest/sidecar reuse and changed-path blocking. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-016` | Yes | `report.md#t-bug-023-016` |
| Regression E2E | T-BUG-023-017 | SCN-BUG-023-017 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Legacy dirty-worktree lockout with no synthesized baseline. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-017` | Yes | `report.md#t-bug-023-017` |
| Adversarial selftest | T-BUG-023-024 | SCN-BUG-023-015, SCN-BUG-023-016, SCN-BUG-023-017 | integration | `bubbles/scripts/planning-source-baseline-selftest.sh` | Invalid reason families, retry, lifecycle, path safety, races, and legacy split. | `bash bubbles/scripts/planning-source-baseline-selftest.sh` | Yes | `report.md#t-bug-023-024` |
| Result/schema selftest | T-BUG-023-025 | SCN-BUG-023-015 | functional | `bubbles/scripts/audit-result-contract-lint-selftest.sh` | V2 field order, JSON/digest, applicability/actionability, and lockout mutation rejection. | `bash bubbles/scripts/audit-result-contract-lint-selftest.sh` | No | `report.md#t-bug-023-025` |
| Legacy regression | T-BUG-023-026 | SCN-BUG-023-017 | e2e-api | `tests/regression/test_23_planning_audit_contract.sh` | Existing no-baseline planning-audit behavior remains compatible. | `bash tests/regression/test_23_planning_audit_contract.sh` | Yes | `report.md#t-bug-023-026` |

### Definition of Done - Scope 2 Tiered Validation

Core outcomes:

- [ ] Every invalid baseline maps to the closed reason inventory and applies
  zero exclusions.
- [ ] Resume/retry reuses original bound bytes; no recapture/amendment exists.
- [ ] Only complete key absence selects legacy whole-worktree semantics.
- [ ] Scope 2 boundaries and all prior contracts/frozen bytes remain intact.

Test evidence:

- [ ] T-BUG-023-015 evidence proves SCN-BUG-023-015 at `report.md#t-bug-023-015`.
- [ ] T-BUG-023-016 evidence proves SCN-BUG-023-016 at `report.md#t-bug-023-016`.
- [ ] T-BUG-023-017 evidence proves SCN-BUG-023-017 at `report.md#t-bug-023-017`.
- [ ] T-BUG-023-024 evidence proves adversarial lifecycle coverage at `report.md#t-bug-023-024`.
- [ ] T-BUG-023-025 evidence proves V2 mutation rejection at `report.md#t-bug-023-025`.
- [ ] T-BUG-023-026 evidence proves legacy consumer compatibility at `report.md#t-bug-023-026`.

## Scope 3: G060 Profile Applicability Without Delivery Relaxation

**Status:** Not Started
**Depends On:** Scope 1 (foundation), Scope 2
**Foundation:** false
**Scope-Kind:** runtime-behavior

### Scope 3 Change Boundary

Allowed: Check 3E profile-entry branch, G060 V2 details, a non-breaking
sequence classifier wrapper, and named tests/consumers. Excluded: resolver or
registry changes, delivery exemption/grandfathering/non-scenario-first policy,
G040/G073, and per-packet applicability inputs.

### Scope 3 Gherkin Scenarios

#### SCN-BUG-023-001: planning maturity records G060 as not applicable

```gherkin
Scenario: SCN-BUG-023-001 planning maturity records G060 as not applicable
  Given a product-to-planning packet targeting specs_hardened
  And the resolved profile is planning-maturity-v1
  And no runtime RED-to-GREEN evidence exists
  When the target-aware transition guard runs
  Then G060 is reported as NOT_APPLICABLE with the resolved profile reason
  And the packet is not failed for missing runtime execution evidence
```

#### SCN-BUG-023-002: delivery blocks absent RED-to-GREEN evidence

```gherkin
Scenario: SCN-BUG-023-002 delivery blocks absent RED-to-GREEN evidence
  Given a full-delivery packet resolving to delivery-completion-v1
  And scenario-first TDD is active
  And required runtime RED-to-GREEN evidence is absent
  When the target-aware transition guard runs
  Then G060 blocks the transition
```

#### SCN-BUG-023-003: delivery blocks out-of-order evidence

```gherkin
Scenario: SCN-BUG-023-003 delivery blocks out-of-order evidence
  Given a bugfix-fastlane packet resolving to delivery-completion-v1
  And GREEN evidence appears before RED evidence
  When the target-aware transition guard runs
  Then G060 blocks the transition for invalid ordering
```

### Scope 3 Implementation Plan

1. Branch on the resolved profile before policy/evidence reads.
2. Record exactly one planning N/A detail without pass/fail attribution.
3. Wrap the existing delivery decision tree unchanged.
4. Reject unknown profiles rather than selecting a default.
5. Update V2 consumers while preserving all existing policy branches.
6. Run the frozen six-case delivery matrix and BUG-009 canary.

### Test Plan

| Test Type | Test ID | Scenario | Category | File/Location | Description | Command | Live System | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E | T-BUG-023-001 | SCN-BUG-023-001 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Planning N/A with one detail and no false pass/fail. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-001` | Yes | `report.md#t-bug-023-001` |
| Regression E2E | T-BUG-023-002 | SCN-BUG-023-002 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Missing delivery evidence blocks `full-delivery`. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-002` | Yes | `report.md#t-bug-023-002` |
| Regression E2E | T-BUG-023-003 | SCN-BUG-023-003 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | GREEN-before-RED blocks `bugfix-fastlane`. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-003` | Yes | `report.md#t-bug-023-003` |
| Delivery matrix canary | T-BUG-023-027 | SCN-BUG-023-001, SCN-BUG-023-002, SCN-BUG-023-003 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Both delivery modes missing/out-of-order/ordered plus planning N/A. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes | `report.md#t-bug-023-027` |
| Audit regression | T-BUG-023-028 | SCN-BUG-023-001, SCN-BUG-023-002, SCN-BUG-023-003 | e2e-api | `tests/regression/test_23_planning_audit_contract.sh` | BUG-009 accepts planning N/A and rejects delivery N/A. | `bash tests/regression/test_23_planning_audit_contract.sh` | Yes | `report.md#t-bug-023-028` |

### Definition of Done - Scope 3 Tiered Validation

Core outcomes:

- [ ] Planning G060 is explicit N/A, profile-reasoned, and never counted pass.
- [ ] Both delivery modes retain all existing ordering/policy behavior.
- [ ] Applicability is registry-profile-bound with no caller exception.
- [ ] Scope 3 boundaries and all G073/frozen-byte contracts remain intact.

Test evidence:

- [ ] T-BUG-023-001 evidence proves SCN-BUG-023-001 at `report.md#t-bug-023-001`.
- [ ] T-BUG-023-002 evidence proves SCN-BUG-023-002 at `report.md#t-bug-023-002`.
- [ ] T-BUG-023-003 evidence proves SCN-BUG-023-003 at `report.md#t-bug-023-003`.
- [ ] T-BUG-023-027 evidence proves the complete delivery matrix at `report.md#t-bug-023-027`.
- [ ] T-BUG-023-028 evidence proves audit compatibility at `report.md#t-bug-023-028`.

## Scope 4: G040 Accepted Contexts

**Status:** Not Started
**Depends On:** Scope 1 (foundation), Scope 3
**Foundation:** false
**Scope-Kind:** runtime-behavior

### Scope 4 Change Boundary

Allowed: finite G040 classifier, Check 18 integration, metadata-only V2 rows,
and named tests. Excluded: profile-aware G040, general NLP, line-wide
exemptions, accepted path lists, broad structural-exclusion changes, and all
G060/G073 branches.

### Scope 4 Gherkin Scenarios

#### SCN-BUG-023-004: title-like domain label is accepted

```gherkin
Scenario: SCN-BUG-023-004 title-like domain label is accepted
  Given a scanned label equal to "Authorized Outcome Follow-Up"
  When G040 classifies the statement
  Then the label produces zero deferral findings
```

#### SCN-BUG-023-005: follow-up projection is a domain noun

```gherkin
Scenario: SCN-BUG-023-005 follow-up projection is a domain noun
  Given a scanned noun phrase equal to "follow-up projection"
  When G040 classifies the statement
  Then the noun phrase produces zero deferral findings
```

#### SCN-BUG-023-006: Follow-Up is an accepted structured label

```gherkin
Scenario: SCN-BUG-023-006 Follow-Up is an accepted structured label
  Given a heading, table label, or field label equal to "Follow-Up"
  When G040 classifies the statement
  Then the label produces zero deferral findings
```

#### SCN-BUG-023-007: active present-surface statement is accepted

```gherkin
Scenario: SCN-BUG-023-007 active present-surface statement is accepted
  Given a statement equal to "The active MVP surface includes the Authorized Outcome Follow-Up."
  When G040 classifies the statement
  Then the statement produces zero deferral findings
```

### Scope 4 Implementation Plan

1. Preserve physical line numbers and exact structural records.
2. Normalize only finite ASCII case/punctuation/follow-up spellings.
3. Evaluate blockers before the four accepted contexts and no-match result.
4. Record path/line/reason/digest while withholding statement content.
5. Prove exact, variant, structural, and no-match cases.
6. Run portability and BUG-009 canaries with frozen bytes unchanged.

### Test Plan

| Test Type | Test ID | Scenario | Category | File/Location | Description | Command | Live System | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E | T-BUG-023-004 | SCN-BUG-023-004 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Title/domain-label variants through real Check 18. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-004` | Yes | `report.md#t-bug-023-004` |
| Regression E2E | T-BUG-023-005 | SCN-BUG-023-005 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Noun-compound variants through real Check 18. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-005` | Yes | `report.md#t-bug-023-005` |
| Regression E2E | T-BUG-023-006 | SCN-BUG-023-006 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Heading/table/field-label variants through real Check 18. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-006` | Yes | `report.md#t-bug-023-006` |
| Regression E2E | T-BUG-023-007 | SCN-BUG-023-007 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Both present-surface contract sentences and variants. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-007` | Yes | `report.md#t-bug-023-007` |
| Classifier canary | T-BUG-023-029 | SCN-BUG-023-004, SCN-BUG-023-005, SCN-BUG-023-006, SCN-BUG-023-007 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Structural, accepted, no-match, disclosure, sorting, and overflow behavior. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes | `report.md#t-bug-023-029` |
| Portability canary | T-BUG-023-030 | SCN-BUG-023-004, SCN-BUG-023-005, SCN-BUG-023-006, SCN-BUG-023-007 | functional | BUG-023 shell surface | Bash 3.2 syntax and macOS/GNU forbidden-form scan. | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | No | `report.md#t-bug-023-030` |
| Consumer regression | T-BUG-023-031 | SCN-BUG-023-004, SCN-BUG-023-005, SCN-BUG-023-006, SCN-BUG-023-007 | e2e-api | `tests/regression/test_23_planning_audit_contract.sh` | Existing planning audit remains compatible with V2 G040. | `bash tests/regression/test_23_planning_audit_contract.sh` | Yes | `report.md#t-bug-023-031` |

### Definition of Done - Scope 4 Tiered Validation

Core outcomes:

- [ ] Classifier implements only the finite design contract.
- [ ] Every accepted case/variant yields zero blocking findings and its reason.
- [ ] Details preserve metadata and withhold sensitive/raw content.
- [ ] Scope 4 boundary and all prior/frozen-byte contracts remain intact.

Test evidence:

- [ ] T-BUG-023-004 evidence proves SCN-BUG-023-004 at `report.md#t-bug-023-004`.
- [ ] T-BUG-023-005 evidence proves SCN-BUG-023-005 at `report.md#t-bug-023-005`.
- [ ] T-BUG-023-006 evidence proves SCN-BUG-023-006 at `report.md#t-bug-023-006`.
- [ ] T-BUG-023-007 evidence proves SCN-BUG-023-007 at `report.md#t-bug-023-007`.
- [ ] T-BUG-023-029 evidence proves managed classifier coverage at `report.md#t-bug-023-029`.
- [ ] T-BUG-023-030 evidence proves portability at `report.md#t-bug-023-030`.
- [ ] T-BUG-023-031 evidence proves broader consumer regression at `report.md#t-bug-023-031`.

## Scope 5: G040 Blocking Precedence And Compatibility Closure

**Status:** Not Started
**Depends On:** Scope 1 (foundation), Scope 4
**Foundation:** false
**Scope-Kind:** runtime-behavior

### Scope 5 Change Boundary

Allowed: finite blocking families, final V2 producer/consumer wiring, managed
selftests, capability/install/release identity, owned docs/projections, and
supported downstream upgrade evidence. Excluded: general NLP, new vocabulary,
selective rollback, downstream edits/certification fields, QuantitativeFinance
packet edits, and release publication before canonical gates pass.

### Scope 5 Gherkin Scenarios

#### SCN-BUG-023-008: work-disposition verbs remain blocking

```gherkin
Scenario Outline: SCN-BUG-023-008 work-disposition verbs remain blocking
  Given a scanned statement equal to <statement>
  When G040 classifies the statement
  Then G040 reports that exact statement and blocks the transition
  Examples:
    | statement                   |
    | "Defer this work."         |
    | "Postpone this work."      |
    | "Skip this work."          |
    | "Punt this work."          |
```

#### SCN-BUG-023-009: future scheduling remains blocking

```gherkin
Scenario Outline: SCN-BUG-023-009 future scheduling remains blocking
  Given a scanned statement equal to <statement>
  When G040 classifies the statement
  Then G040 reports that exact statement and blocks the transition
  Examples:
    | statement                             |
    | "This is future work."               |
    | "This is future scope."              |
    | "Move this to the next sprint."      |
    | "Move this to the next iteration."   |
```

#### SCN-BUG-023-010: fix or address later remains blocking

```gherkin
Scenario Outline: SCN-BUG-023-010 fix or address later remains blocking
  Given a scanned statement equal to <statement>
  When G040 classifies the statement
  Then G040 reports that exact statement and blocks the transition
  Examples:
    | statement                                  |
    | "Fix this in a follow-up."                |
    | "Address this in a later follow-up."      |
    | "Fix this later."                         |
    | "Address this later."                     |
```

#### SCN-BUG-023-011: blocking intent overrides an accepted label

```gherkin
Scenario: SCN-BUG-023-011 blocking intent overrides an accepted label
  Given a statement equal to "Fix this later in the Authorized Outcome Follow-Up."
  When G040 classifies the statement
  Then G040 reports the statement and blocks the transition
```

### Scope 5 Implementation Plan

1. Implement only the exact blocking token families/windows; blocking wins.
2. Keep structural exclusions scoped to complete canonical records.
3. Complete V2 audit/CLI/done-spec/selftest/BUG-009 consumer adaptation.
4. Register capability/direct/MCP surfaces and update owned schema,
   governance, projection, changelog, validation, and release identity.
5. Run frozen regression, managed selftests, portability, framework validate,
   and release check.
6. Prove installed-byte parity, supported upgrade, and a fresh downstream
   discriminator as three separate evidence claims.

### Test Plan

| Test Type | Test ID | Scenario | Category | File/Location | Description | Command | Live System | Evidence Anchor |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Regression E2E | T-BUG-023-008 | SCN-BUG-023-008 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Work-disposition matrix through real Check 18. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-008` | Yes | `report.md#t-bug-023-008` |
| Regression E2E | T-BUG-023-009 | SCN-BUG-023-009 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Future/scheduling blocking matrix. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-009` | Yes | `report.md#t-bug-023-009` |
| Regression E2E | T-BUG-023-010 | SCN-BUG-023-010 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Fix/address token-window and window+1 matrix. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-010` | Yes | `report.md#t-bug-023-010` |
| Regression E2E | T-BUG-023-011 | SCN-BUG-023-011 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Same-line blocking precedence and metadata-only evidence. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh --scenario SCN-BUG-023-011` | Yes | `report.md#t-bug-023-011` |
| Full frozen matrix | T-BUG-023-032 | SCN-BUG-023-001 through SCN-BUG-023-017 | e2e-api | `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | All 17 scenarios and adversarial controls with unchanged pre-RED digest. | `bash tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Yes | `report.md#t-bug-023-032` |
| Transition selftest | T-BUG-023-033 | SCN-BUG-023-001 through SCN-BUG-023-017 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Complete G040/G060/G073 integration and V2 compatibility. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes | `report.md#t-bug-023-033` |
| Baseline selftest | T-BUG-023-034 | SCN-BUG-023-012 through SCN-BUG-023-017 | integration | `bubbles/scripts/planning-source-baseline-selftest.sh` | Lifecycle, identity, adversarial provenance, race, and legacy matrix. | `bash bubbles/scripts/planning-source-baseline-selftest.sh` | Yes | `report.md#t-bug-023-034` |
| Result/schema selftest | T-BUG-023-035 | SCN-BUG-023-001 through SCN-BUG-023-017 | functional | `bubbles/scripts/audit-result-contract-lint-selftest.sh` | V2 field/digest/applicability/actionability/lockout mutation rejection. | `bash bubbles/scripts/audit-result-contract-lint-selftest.sh` | No | `report.md#t-bug-023-035` |
| MCP selftest | T-BUG-023-036 | SCN-BUG-023-012, SCN-BUG-023-016 | integration | `bubbles/scripts/mcp-server-selftest.sh` | Catalog and real Bash-twin capture/reuse/close dispatch. | `bash bubbles/scripts/mcp-server-selftest.sh` | Yes | `report.md#t-bug-023-036` |
| Installer parity | T-BUG-023-037 | SCN-BUG-023-001 through SCN-BUG-023-017 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Managed bytes and descriptor match release manifest/checksums. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes | `report.md#t-bug-023-037` |
| Existing audit regression | T-BUG-023-038 | SCN-BUG-023-001, SCN-BUG-023-013, SCN-BUG-023-017 | e2e-api | `tests/regression/test_23_planning_audit_contract.sh` | BUG-009 consumer compatibility under V2. | `bash tests/regression/test_23_planning_audit_contract.sh` | Yes | `report.md#t-bug-023-038` |
| Regression quality | T-BUG-023-039 | SCN-BUG-023-001 through SCN-BUG-023-017 | functional | `bubbles/scripts/regression-quality-guard.sh` | Production-path assertions and no silent-pass bailout. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | No | `report.md#t-bug-023-039` |
| Portability | T-BUG-023-040 | SCN-BUG-023-001 through SCN-BUG-023-017 | functional | `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/guards/control-plane-checks.sh`; `bubbles/scripts/guards/g040-deferral-classifier.sh`; `bubbles/scripts/guards/g073-source-state.sh`; `bubbles/scripts/planning-source-baseline.sh`; `tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | Exact six-file BUG-023 shell boundary; macOS Bash 3.2 and Linux equivalence plus forbidden-form scan. | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/control-plane-checks.sh bubbles/scripts/guards/g040-deferral-classifier.sh bubbles/scripts/guards/g073-source-state.sh bubbles/scripts/planning-source-baseline.sh tests/regression/test_30_planning_transition_applicability_and_baseline.sh` | No | `report.md#t-bug-023-040` |
| Framework regression | T-BUG-023-041 | SCN-BUG-023-001 through SCN-BUG-023-017 | e2e-api | `bubbles/scripts/cli.sh` | Broader canonical framework suite and managed wiring. | `bash bubbles/scripts/cli.sh framework-validate` | Yes | `report.md#t-bug-023-041` |
| Release check | T-BUG-023-042 | SCN-BUG-023-001 through SCN-BUG-023-017 | integration | `bubbles/scripts/cli.sh` | Release manifest/generated/version/provenance coherence. | `bash bubbles/scripts/cli.sh release-check` | Yes | `report.md#t-bug-023-042` |
| Downstream upgrade | T-BUG-023-043 | SCN-BUG-023-001 through SCN-BUG-023-017 | e2e-api | QuantitativeFinance installed framework | Supported installed CLI upgrade after canonical release identity. | `bash .github/bubbles/scripts/cli.sh upgrade` | Yes | `report.md#t-bug-023-043` |
| Downstream discriminator | T-BUG-023-044 | SCN-BUG-023-001, SCN-BUG-023-004, SCN-BUG-023-013 | e2e-api | QuantitativeFinance `specs/097-tenant-entity-ownership-kernel` | Fresh planning transition distinguishes G060 N/A, G040 acceptance, and G073 audited equality. | `bash .github/bubbles/scripts/state-transition-guard.sh specs/097-tenant-entity-ownership-kernel` | Yes | `report.md#t-bug-023-044` |

### Definition of Done - Scope 5 Tiered Validation

Core outcomes:

- [ ] Every blocking statement/variant maps to its closed reason and blocks;
  accepted text cannot shield it.
- [ ] G040 preserves line identity, withholds content, and emits complete stable
  machine evidence with bounded human rows.
- [ ] All result/schema/runner/MCP/install/governance consumers and stale
  references are reconciled together.
- [ ] Shared-infrastructure canaries and coherent rollback prove containment.
- [ ] Approved changed-file boundaries hold; excluded/downstream files remain
  unchanged.
- [ ] Canonical release, installed parity, downstream upgrade, and downstream
  discriminator remain distinct claims with no planning-owned certification.

Test evidence:

- [ ] T-BUG-023-008 evidence proves SCN-BUG-023-008 at `report.md#t-bug-023-008`.
- [ ] T-BUG-023-009 evidence proves SCN-BUG-023-009 at `report.md#t-bug-023-009`.
- [ ] T-BUG-023-010 evidence proves SCN-BUG-023-010 at `report.md#t-bug-023-010`.
- [ ] T-BUG-023-011 evidence proves SCN-BUG-023-011 at `report.md#t-bug-023-011`.
- [ ] T-BUG-023-032 evidence proves full frozen regression at `report.md#t-bug-023-032`.
- [ ] T-BUG-023-033 evidence proves transition selftest at `report.md#t-bug-023-033`.
- [ ] T-BUG-023-034 evidence proves baseline selftest at `report.md#t-bug-023-034`.
- [ ] T-BUG-023-035 evidence proves result/schema rejection at `report.md#t-bug-023-035`.
- [ ] T-BUG-023-036 evidence proves MCP compatibility at `report.md#t-bug-023-036`.
- [ ] T-BUG-023-037 evidence proves installer parity at `report.md#t-bug-023-037`.
- [ ] T-BUG-023-038 evidence proves BUG-009 regression at `report.md#t-bug-023-038`.
- [ ] T-BUG-023-039 evidence proves regression quality at `report.md#t-bug-023-039`.
- [ ] T-BUG-023-040 evidence proves portability at `report.md#t-bug-023-040`.
- [ ] T-BUG-023-041 evidence proves framework validation at `report.md#t-bug-023-041`.
- [ ] T-BUG-023-042 evidence proves release readiness at `report.md#t-bug-023-042`.
- [ ] T-BUG-023-043 evidence proves supported upgrade at `report.md#t-bug-023-043`.
- [ ] T-BUG-023-044 evidence proves the fresh downstream discriminator at `report.md#t-bug-023-044`.

<!-- markdownlint-enable MD024 -->

## Planning Quality Gate

- [ ] All 17 scenario IDs appear exactly once in active Gherkin and once in
  primary persistent-regression rows.
- [ ] Every Test Plan row has one matching unchecked Test Evidence DoD item and
  report evidence anchor; no completion evidence is pre-populated.
- [ ] The five-scope graph is acyclic, foundation-first, and sequential.
- [ ] Structured planning artifacts match this plan exactly.
- [ ] Artifact lint, traceability, JSON/schema, Markdown/JSON parity, DAG, and
  editor diagnostics pass for the planning packet.

## Owner Route

The mandatory next owner is `bubbles.test`. That owner writes complete frozen
`test_30` bytes once, records their SHA-256 identity, and captures final-byte
causal RED before `bubbles.implement` changes production code. Planning claims
no RED, GREEN, release, upgrade, downstream, or certification result.
