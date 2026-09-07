# BUG-037 Scopes

<!-- markdownlint-disable MD024 -->

## Execution Outline

### Phase Order

1. **Scope 1: Authority-Safe State And Session Policy** establishes authority-first state access, safe locks, and exact-session policy history.
2. **Scope 2: Immutable G128 Event Evaluation** evaluates one immutable state revision with complete policy, timestamp, and diagnostic validation.
3. **Scope 3: Exact Receipt And Usage Evaluation** validates receipt bytes and one stable usage artifact without partial measurements.
4. **Scope 4: Authoritative G082 And Blocking Callers** binds G082, Check 40, and framework validation to one actionable host session.
5. **Scope 5: Concurrency, Portability, And Release Epoch** proves every integrated path and freezes fresh release metadata after final edits.

Each scope depends on the preceding scope. Implementation must stop when a
scope gate fails. A failed gate cannot be carried into the next scope.

### New Types And Signatures

| Surface | Planned signature or shape |
| --- | --- |
| Safe state helper | `session-state-io.py <operation> ...` where operation is `capture`, `flock-run`, `mkdir-run`, or `parse-usage` |
| Session policy history | `sessionBudgetHistory[]` with exact `hostSessionId` and an append-only revision chain |
| Policy write | `state-snapshot.sh ... --session-budget-json <object> --expected-session-budget-revision <n>` |
| Direct G128 | `session-cap-guard.sh --session-id <opaque-id> [--quiet]` |
| Direct G082 | `convergence-cap-guard.sh <specDir> --session-id <opaque-id> [--quiet]` |
| Blocking authority | Validated packet session transported with its external control file and private packet file |
| Final guard status | One closed status record whose declared exit equals the child process exit |
| Usage proof | Exact `sessionId`, `identityMatch: exact`, `artifactCount: 1`, request count, and token totals |
| Immutable revision | `sha256:<hex>` over one no-follow captured state or receipt prefix |

The plan adds no admission, permit, reservation, epoch, broker, retry, cost,
or tool-call producer surface. `maxToolCalls` remains unmeasurable.

### Validation Checkpoints

| Checkpoint | Required proof before continuing |
| --- | --- |
| Scope 1 | Invalid authority creates no repository entry. Both lock strategies reject unsafe targets. Exact policy chains remain independent. |
| Scope 2 | One captured state revision backs each verdict. Matching timestamp and schema defects fail without a subset result. |
| Scope 3 | Receipt and usage readers reject unsafe, unstable, malformed, and incomplete exact inputs. Honest ambiguity remains unmeasurable. |
| Scope 4 | G082 and both blocking callers validate packet authority and enforce one closed status and exit pair. |
| Scope 5 | Row-level concurrency, actual child interpreters, metadata freshness, framework validation, and release readiness share one final epoch. |

## Overview

This bug uses five sequential scopes in one [scopes.md](scopes.md) file. The
plan follows [spec.md](spec.md) and [design.md](design.md). Execution evidence
belongs in [report.md](report.md). Human acceptance remains in
[uservalidation.md](uservalidation.md).

The repository config declares no `testImpact` or `traceContracts` block.
The plan therefore names each required source path, test path, and command.

## Execution Inventory

| # | Scope | Depends On | Surfaces | Test Rows | Status |
| --- | --- | --- | --- | ---: | --- |
| 1 | Authority-Safe State And Session Policy | — | Safe I/O helper, state producer, policy consumers | 3 | Not Started |
| 2 | Immutable G128 Event Evaluation | 1 | G128 state reader, policy projection, diagnostics | 3 | Implemented (awaiting independent test) |
| 3 | Exact Receipt And Usage Evaluation | 2 | Tool receipts, usage adapter, G128 token and byte projection | 3 | Independently Verified |
| 4 | Authoritative G082 And Blocking Callers | 3 | G082, Check 23, Check 40, live framework validation | 3 | Not Started |
| 5 | Concurrency, Portability, And Release Epoch | 4 | Persistent regression, concurrency harnesses, contracts, generated metadata | 8 | Not Started |

## Root Finding Coverage

| Root finding | Owning scope | Planned proof |
| --- | ---: | --- |
| RF-B037-01 | 1 | Authority precedes repository side effects. Flock and mkdir targets are no-follow and identity checked. |
| RF-B037-02 | 4 | Check 40 and framework validation require actionable authority, installed guards, and a closed child result. |
| RF-B037-03 | 1 | Exact-session policy chains preserve different values and independent default-off posture. |
| RF-B037-04 | 2 | One immutable revision backs complete policy, timestamp, and byte-shape validation. |
| RF-B037-05 | 3 | Exact usage discovery is complete, contained, no-follow, stable, and lossless. |
| RF-B037-06 | 2 | Shared JSON-string escaping keeps each untrusted value on one physical line. |
| RF-B037-07 | 4 | G082 filters the authoritative session while retaining its target-spec maximum. |
| RF-B037-08 | 5 | Persistent and concurrent proof checks rows, mappings, both locks, callers, G082, and child interpreters. |
| RF-B037-09 | 5 | Release metadata is generated after final managed edits and checked on an unchanged candidate. |

## Requirement Coverage

Each requirement has one owning scope and one or more exact Test Plan rows.
Supporting scopes may consume the same contract without becoming a second owner.

| Requirement | Owning scope | Test Plan rows |
| --- | ---: | --- |
| FR-B037-001 | 2 | TP-02-03 |
| FR-B037-002 | 2 | TP-02-01 |
| FR-B037-003 | 1 | TP-01-02 |
| FR-B037-004 | 2 | TP-02-03 |
| FR-B037-005 | 3 | TP-03-01, TP-03-03 |
| FR-B037-006 | 3 | TP-03-02, TP-03-03 |
| FR-B037-007 | 2 | TP-02-01 |
| FR-B037-008 | 2 | TP-02-03 |
| FR-B037-009 | 2 | TP-02-02 |
| FR-B037-010 | 1 | TP-01-02 |
| FR-B037-011 | 4 | TP-04-02, TP-04-03 |
| FR-B037-012 | 5 | TP-05-01, TP-05-04, TP-05-05 |
| FR-B037-013 | 5 | TP-05-06, TP-05-07, TP-05-08 |
| FR-B037-014 | 2 | TP-02-03 |
| FR-B037-015 | 2 | TP-02-03 |
| FR-B037-016 | 5 | TP-05-04, TP-05-06 |
| FR-B037-017 | 4 | TP-04-02, TP-04-03 |
| FR-B037-018 | 1 | TP-01-02, TP-01-03 |
| FR-B037-019 | 3 | TP-03-02, TP-03-03 |
| FR-B037-020 | 3 | TP-03-02 |
| FR-B037-021 | 4 | TP-04-02, TP-04-03 |
| FR-B037-022 | 4 | TP-04-02, TP-04-03 |
| FR-B037-023 | 2 | TP-02-01 |
| FR-B037-024 | 1 | TP-01-01, TP-01-02 |
| FR-B037-025 | 2 | TP-02-01, TP-02-03 |
| FR-B037-026 | 2 | TP-02-03 |
| FR-B037-027 | 2 | TP-02-03 |
| FR-B037-028 | 4 | TP-04-01, TP-04-02 |
| FR-B037-029 | 3 | TP-03-01, TP-03-03 |
| FR-B037-030 | 5 | TP-05-03, TP-05-04, TP-05-05 |
| FR-B037-031 | 5 | TP-05-01, TP-05-04, TP-05-05 |
| FR-B037-032 | 5 | TP-05-01, TP-05-02, TP-05-03 |
| FR-B037-033 | 5 | TP-05-04, TP-05-05 |

## Related Artifacts

- Expected behavior: [spec.md](spec.md).
- Root-cause design: [design.md](design.md).
- Evidence record: [report.md](report.md).
- Acceptance checklist: [uservalidation.md](uservalidation.md).
- Scenario registry: [scenario-manifest.json](scenario-manifest.json).
- Structured test handoff: [test-plan.json](test-plan.json).

## Immutable Change Boundary

### Allowed Production And Contract Paths

- `bubbles/scripts/session-state-io.py`
- `bubbles/scripts/state-snapshot.sh`
- `bubbles/scripts/session-cap-guard.sh`
- `bubbles/scripts/convergence-cap-guard.sh`
- `bubbles/scripts/autonomy-resolve.sh`
- `bubbles/adapters/usage/vscode-copilot.sh`
- `bubbles/scripts/guards/tail-convergence-gates.sh`
- `bubbles/scripts/framework-validate.sh`
- `bubbles/workflows.yaml`
- `bubbles/registry/gates.yaml`
- `agents/bubbles_shared/quality-gates.md`
- `skills/bubbles-quality-gates-catalog/SKILL.md`
- `agents/bubbles.goal.agent.md`
- `agents/bubbles.workflow.agent.md`
- `agents/bubbles.iterate.agent.md`
- `agents/bubbles.sprint.agent.md`
- `bubbles/release-manifest.json`

### Allowed Test Paths

- `bubbles/scripts/state-snapshot-selftest.sh`
- `bubbles/scripts/session-cap-guard-selftest.sh`
- `bubbles/scripts/convergence-cap-guard-selftest.sh`
- `bubbles/scripts/autonomy-resolve-selftest.sh`
- `bubbles/scripts/usage-adapter-contract-selftest.sh`
- `bubbles/scripts/runtime-concurrency-selftest.sh`
- `bubbles/scripts/tool-log-selftest.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/framework-validate-tier-selftest.sh`
- `tests/regression/test_22_session_cap_enforcement.sh`

### Allowed Planning Artifacts

- `bugs/BUG-037-session-cap-cross-session-attribution/scopes.md`
- `bugs/BUG-037-session-cap-cross-session-attribution/test-plan.json`
- `bugs/BUG-037-session-cap-cross-session-attribution/scenario-manifest.json`
- Plan-owned routing and `workBoundary` fields in `bugs/BUG-037-session-cap-cross-session-attribution/state.json`

### Excluded Paths And Concepts

- Keep `bubbles/scripts/tool-log.sh` unchanged.
- Keep `bubbles/scripts/state-transition-guard.sh` unchanged.
- Keep `bubbles/scripts/repository-binding.sh` unchanged.
- Keep `bubbles/scripts/repository-binding-selftest.sh` unchanged.
- Keep `bubbles/scripts/cli.sh` unchanged.
- Keep `bubbles/scripts/release-check.sh` unchanged.
- Keep `bubbles/workflows/modes.yaml` unchanged.
- Keep every configured cap name, numeric value, and null unchanged.
- Keep G085 behavior unchanged.
- Keep downstream installed framework copies unchanged.
- Add no IMP-055 admission, reservation, permit, goal budget, session epoch, host broker, provider-cost, retry, or tool-call producer concept.
- Add no receipt-count proxy for `maxToolCalls`.
- Add no source-repository `specs/` directory.

The plan does not authorize repository-binding source changes. The existing
`validate-packet` contract is consumed through state and caller tests.

## Shared Infrastructure Impact Sweep

- Preserve turn ordering, goal references, binding mirrors, and unrelated state fields.
- Preserve append-only tool receipts and keep the tool-log producer byte-identical.
- Preserve legacy `sessionBudget` bytes without assigning them to a host session.
- Preserve convergence latest-value behavior inside the exact session, spec, and agent key.
- Preserve usage-adapter verb shapes outside the exact `session` projection.
- Preserve G082 target-spec maximum semantics and G128 session-wide sum semantics.
- Run independent state, usage, caller, concurrency, and persistent canaries before broad validation.
- Restore code by reverting the owning scope. Do not rewrite retained state during rollback.

## Consumer Impact Sweep

The session-policy change affects the four orchestrator agent contracts,
`autonomy-resolve.sh`, `state-snapshot.sh`, and `session-cap-guard.sh`.

The authority and status change affects Check 23, Check 40, framework
validation, direct G082, and direct G128. `release-check.sh` remains an
unchanged consumer of framework validation.

Implementation must search agent text, scripts, tests, registries, generated
metadata, and release checks for the legacy shared-budget and ambient-authority
contracts. Zero stale first-party references may remain inside the allowed
boundary.

## Scope 1: Authority-Safe State And Session Policy

**Status:** Implemented (awaiting independent test)

**Depends On:** —

**Scope-Kind:** runtime-behavior

**Root Findings:** RF-B037-01, RF-B037-03

**Requirements:** See [Requirement Coverage](#requirement-coverage), Scope 1.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-009 Authority fails before repository side effects
  Given the supplied packet is stale, malformed, non-actionable, or bound to another root
    And the target repository has no session state directory or lock entry
  When state snapshot receives the private packet and external control record
  Then packet validation fails before any repository-local path is derived or opened
    And the repository entry set and existing bytes remain unchanged

Scenario: SCN-B037-010 Safe lock targets cannot redirect or corrupt state
  Given the flock or mkdir lock name is a symlink, non-regular object, or replaced entry
  When an actionable state snapshot attempts the bounded lock acquisition
  Then the transaction fails without following or truncating the planted target
    And sentinel bytes and session bytes remain unchanged

Scenario: SCN-B037-011 Exact-session policy histories remain independent
  Given host-a has a bounded policy head and host-b has an all-null policy head
    And legacy unscoped policy remains stored
  When validated writers append, repeat, correct, or conflict on either session policy
  Then each session retains one linear append-only chain and independent default-off posture
    And a stale revision, branch, duplicate, or malformed record changes no state
```

### Implementation Plan

1. Add the descriptor-based safe state helper from the design.
2. Validate the private binding packet before deriving repository-local paths.
3. Implement no-follow flock and identity-checked mkdir transaction modes.
4. Add `sessionBudgetHistory[]` without rewriting legacy `sessionBudget`.
5. Add compare-and-append policy writes under the existing state transaction.
6. Preserve turn append behavior and exact session, spec, and agent convergence keys.
7. Make `autonomy-resolve.sh` inspect only the exact session policy head.
8. Reconcile the four orchestrator agent contracts with the exact-session writer.

### Scope Change Boundary

Allowed production paths are the helper, state snapshot, autonomy resolver,
the four orchestrator agent contracts, and existing workflow policy text.
Allowed tests are the helper, state snapshot, and autonomy resolver selftests.
All other paths in the immutable boundary remain untouched in this scope.

### Test Plan

| ID | Scenario | Type | File | Required assertion | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| TP-01-01 | SCN-B037-010 | functional | `bubbles/scripts/state-snapshot-selftest.sh` | Helper-level descriptor cases reject symlink, non-regular, replacement, and stale-identity lock targets without changing sentinel bytes. | `/bin/bash bubbles/scripts/state-snapshot-selftest.sh` | Yes, real filesystem and locks |
| TP-01-02 | SCN-B037-009 | integration | `bubbles/scripts/state-snapshot-selftest.sh` | Packet rejection precedes repository entries. Valid writes preserve exact policy chains, turns, mirrors, and convergence mappings under flock and mkdir locks. | `/bin/bash bubbles/scripts/state-snapshot-selftest.sh` | Yes, real producer, binding validator, filesystem, and locks |
| TP-01-03 | SCN-B037-011 | functional | `bubbles/scripts/autonomy-resolve-selftest.sh` | Unattended boundedness reads only the exact session head. A bounded sibling or legacy object cannot activate an absent or all-null session. | `/bin/bash bubbles/scripts/autonomy-resolve-selftest.sh` | Yes, production resolver over ephemeral state |

### Definition of Done

- [x] Packet authority is validated before repository-local directory, lock, or state access. → Evidence: [record](report.md#scope-1-final-state-and-lock-evidence)
- [x] Flock and mkdir strategies use no-follow, non-truncating, identity-checked transaction ownership. → Evidence: [record](report.md#scope-1-final-state-and-lock-evidence)
- [x] Exact-session budget records form append-only linear chains with compare-and-append corrections. → Evidence: [record](report.md#scope-1-final-state-and-lock-evidence)
- [x] Legacy policy, turns, mirrors, convergence rows, and unrelated state remain preserved. → Evidence: [record](report.md#scope-1-final-state-and-lock-evidence)
- [x] The four orchestrator contracts seed only their validated exact session policy. → Evidence: [record](report.md#scope-1-final-autonomy-evidence)
- [x] Scope 1 changes remain inside its declared path boundary. → Evidence: [record](report.md#scope-1-boundary-and-quality-evidence)
- [x] Test TP-01-01 passes inside the state snapshot selftest for SCN-B037-010 safe descriptor and lock refusal. → Evidence: [record](report.md#scope-1-final-state-and-lock-evidence)
- [x] Test TP-01-02 passes for SCN-B037-009 through SCN-B037-011 state integration. → Evidence: [record](report.md#scope-1-final-state-and-lock-evidence)
- [x] Test TP-01-03 passes for SCN-B037-011 exact policy selection and default-off isolation. → Evidence: [record](report.md#scope-1-final-autonomy-evidence)

## Scope 2: Immutable G128 Event Evaluation

**Status:** Implemented (awaiting independent test)

**Depends On:** 1

**Scope-Kind:** runtime-behavior

**Root Findings:** RF-B037-04, RF-B037-06

**Requirements:** See [Requirement Coverage](#requirement-coverage), Scope 2.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-001 Old-session event history is excluded
  Given host-old exceeds the convergence and wall-clock caps
    And host-current has an actionable identity, one policy head, and under-cap event records
  When G128 evaluates host-current from one immutable state revision
  Then only host-current turns and convergence rows affect its measurements
    And every excluded record remains stored unchanged

Scenario: SCN-B037-002 Exact measured boundaries retain both directions
  Given one active-session dimension has a complete numeric observation
  When the observation equals its existing cap
  Then the dimension does not breach and may reach the existing soft boundary
  When the observation exceeds the same cap by one
  Then G128 emits BREACH with exit 1 for that dimension

Scenario: SCN-B037-006 Legacy data and invalid active input never become usage
  Given legacy and mismatched records remain stored beside an exact session policy
  When identity, policy keys, revision data, matching timestamps, or diagnostics are invalid
  Then G128 emits one escaped INPUT-ERROR record with exit 2 before any partial verdict
    And maxToolCalls remains UNMEASURABLE with reason no-exact-producer
```

### Implementation Plan

1. Capture `bubbles.session.json` once through the safe state helper.
2. Parse every policy, turn, and convergence value from the private snapshot.
3. Select one exact-session policy head before measuring any dimension.
4. Enforce the closed policy schema and existing seven cap values.
5. Require complete valid matching timestamps and convergence values.
6. Keep `maxToolCalls` unmeasurable and reject scalar or receipt substitutes.
7. Preserve strict greater-than breaches and the whole-number 70 percent boundary.
8. Add one shared JSON-string encoder for all untrusted diagnostic values.
9. Emit all seven dimension states and one final closed G128 status.
10. Keep direct invocation diagnostic-only because its ID is caller asserted.

### Scope Change Boundary

Allowed production paths are the safe helper and `session-cap-guard.sh`.
Allowed tests are their focused selftests. Scope 1 state formats may be consumed
but must not be redesigned.

### Test Plan

| ID | Scenario | Type | File | Required assertion | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| TP-02-01 | SCN-B037-001 | functional | `bubbles/scripts/session-cap-guard-selftest.sh` | The real guard uses one immutable revision and rejects an incomplete matching event population instead of measuring a subset. | `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh` | Yes, production guard over ephemeral state |
| TP-02-02 | SCN-B037-002 | functional | `bubbles/scripts/session-cap-guard-selftest.sh` | Exact observations preserve equality, one-unit-over breach, strict greater-than, and measured-only 70 percent boundary behavior. | `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh` | Yes, production guard over ephemeral state |
| TP-02-03 | SCN-B037-006 | functional | `bubbles/scripts/session-cap-guard-selftest.sh` | Invalid identity, policy keys, revisions, timestamps, and arguments yield escaped INPUT-ERROR while default-off and all seven dimension states remain truthful. | `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh` | Yes, production guard over ephemeral state |

### Definition of Done

- [x] One safe immutable state snapshot backs each complete G128 verdict. → Evidence: [TP-02-01 immutable event evidence](report.md#scope-2-tp-02-01-immutable-event-evidence)
- [x] Exact turns and convergence rows alone affect active-session observations. → Evidence: [TP-02-01 immutable event evidence](report.md#scope-2-tp-02-01-immutable-event-evidence)
- [x] Missing or invalid active identity, policy, timestamp, and convergence input fails before a partial result. → Evidence: [TP-02-03 policy and diagnostic evidence](report.md#scope-2-tp-02-03-policy-and-diagnostic-evidence)
- [x] Every cap name, value, null, strict comparison, and 70 percent calculation remains unchanged. → Evidence: [TP-02-02 exact boundary evidence](report.md#scope-2-tp-02-02-exact-boundary-evidence)
- [x] `maxToolCalls` remains unmeasurable and no replacement producer or proxy exists. → Evidence: [TP-02-03 policy and diagnostic evidence](report.md#scope-2-tp-02-03-policy-and-diagnostic-evidence)
- [x] Normal and quiet diagnostics preserve seven dimension states, exclusion counts, escaped values, and one final record. → Evidence: [TP-02-03 policy and diagnostic evidence](report.md#scope-2-tp-02-03-policy-and-diagnostic-evidence)
- [x] Scope 2 changes remain inside its declared path boundary. → Evidence: [Scope 2 boundary and preservation evidence](report.md#scope-2-boundary-and-preservation-evidence)
- [x] Test TP-02-01 passes for SCN-B037-001 immutable event isolation and complete-population validation. → Evidence: [TP-02-01 immutable event evidence](report.md#scope-2-tp-02-01-immutable-event-evidence)
- [x] Test TP-02-02 passes for SCN-B037-002 equality, strict breach, and soft-boundary calculations. → Evidence: [TP-02-02 exact boundary evidence](report.md#scope-2-tp-02-02-exact-boundary-evidence)
- [x] Test TP-02-03 passes for SCN-B037-006 identity, schema, diagnostics, and default-off behavior. → Evidence: [TP-02-03 policy and diagnostic evidence](report.md#scope-2-tp-02-03-policy-and-diagnostic-evidence)

## Scope 3: Exact Receipt And Usage Evaluation

**Status:** Independently Verified

**Depends On:** 2

**Scope-Kind:** runtime-behavior

**Root Findings:** RF-B037-05

**Requirements:** See [Requirement Coverage](#requirement-coverage), Scope 3.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-003 Single-result bytes are session isolated
  Given host-old has an oversized receipt and host-current receipts are below the single-result cap
  When G128 evaluates host-current from one immutable tool-log prefix
  Then the old receipt remains excluded and the current dimension remains within its cap
  When one oversized receipt belongs to host-current
  Then only host-current receives the single-result breach

Scenario: SCN-B037-004 Cumulative bytes are session isolated
  Given old receipts exceed the cumulative cap and current receipts remain below it
  When another valid current receipt pushes the exact current total above the cap
  Then G128 changes only the current cumulative dimension from non-breach to BREACH
    And present null, non-integer, fractional, or negative byte members produce INPUT-ERROR

Scenario: SCN-B037-007 Prompt-token accounting requires one stable exact artifact
  Given usage roots contain exact, prefix, ambiguous, malformed, unsafe, and unreadable candidates
  When the adapter resolves the requested opaque session without glob or newline path transport
  Then one stable exact artifact produces exact token measurements
    And honest absence or ambiguity remains unmeasurable
    And traversal, containment, stability, read, parse, or request-shape failure produces INPUT-ERROR
```

### Implementation Plan

1. Capture one immutable tool-log prefix through the safe helper.
2. Validate each physical JSONL row before classifying its session.
3. Enforce non-negative integer byte fields when either pair member exists.
4. Calculate maximum and cumulative bytes from the same complete matching population.
5. Replace newline path transport with byte-preserving traversal in the usage adapter.
6. Walk configured roots without following symlinks and propagate traversal errors.
7. Open, contain, stabilize, and parse one exact artifact through one descriptor.
8. Validate every request-like token record before emitting measured totals.
9. Keep zero, prefix-only, multiple, and unscoped candidates honestly unmeasurable.
10. Make G128 verify the exact adapter proof before accepting token totals.

### Scope Change Boundary

Allowed production paths are the safe helper, G128 guard, and VS Code usage
adapter. `tool-log.sh` remains unchanged. Allowed tests are the guard, adapter,
and tool-log selftests.

### Test Plan

| ID | Scenario | Type | File | Required assertion | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| TP-03-01 | SCN-B037-003 | integration | `bubbles/scripts/tool-log-selftest.sh` | Real wrapper receipts preserve exact session IDs and valid byte members. Concurrent append deltas expose duplicate or missing physical rows. | `/bin/bash bubbles/scripts/tool-log-selftest.sh` | Yes, real wrapper and JSONL append path |
| TP-03-02 | SCN-B037-007 | integration | `bubbles/scripts/usage-adapter-contract-selftest.sh` | The real adapter proves one exact artifact. It preserves valid filename bytes and rejects traversal, symlink, containment, replacement, read, parse, and mixed-token failures. | `/bin/bash bubbles/scripts/usage-adapter-contract-selftest.sh` | Yes, real adapter over ephemeral host-shaped roots |
| TP-03-03 | SCN-B037-004 | functional | `bubbles/scripts/session-cap-guard-selftest.sh` | The real guard validates immutable receipt bytes and exact usage proof. Invalid present byte or measured token data returns INPUT-ERROR without a subset total. | `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh` | Yes, production guard and configured adapter |

### Definition of Done

- [x] Tool receipt parsing uses one immutable complete prefix and preserves every physical row. → Evidence: [Scope 3 TP-03-03 receipt consumption evidence](report.md#scope-3-tp-03-03-receipt-consumption-evidence)
- [x] Matching byte members obey the schema and absent pair members contribute zero only under the defined rule. → Evidence: [Scope 3 TP-03-03 receipt consumption evidence](report.md#scope-3-tp-03-03-receipt-consumption-evidence)
- [x] Usage discovery preserves valid filename bytes and propagates every unsafe or incomplete traversal state. → Evidence: [Scope 3 TP-03-02 exact usage evidence](report.md#scope-3-tp-03-02-exact-usage-evidence)
- [x] One descriptor proves candidate containment, identity, stability, complete read, and complete parse. → Evidence: [Scope 3 TP-03-02 exact usage evidence](report.md#scope-3-tp-03-02-exact-usage-evidence)
- [x] G128 accepts only one exact adapter proof and never reports partial token or byte totals. → Evidence: [Scope 3 TP-03-03 receipt consumption evidence](report.md#scope-3-tp-03-03-receipt-consumption-evidence)
- [x] Scope 3 changes remain inside its declared path boundary and leave `tool-log.sh` byte-identical. → Evidence: [Scope 3 boundary and quality evidence](report.md#scope-3-boundary-and-quality-evidence)
- [x] Test TP-03-01 passes for SCN-B037-003 and SCN-B037-004 receipt production. → Evidence: [Scope 3 TP-03-01 receipt evidence](report.md#scope-3-tp-03-01-receipt-evidence)
- [x] Test TP-03-02 passes for SCN-B037-007 exact usage discovery and failure semantics. → Evidence: [Scope 3 TP-03-02 exact usage evidence](report.md#scope-3-tp-03-02-exact-usage-evidence)
- [x] Test TP-03-03 passes for SCN-B037-003, SCN-B037-004, and SCN-B037-007 G128 consumption. → Evidence: [Scope 3 TP-03-03 receipt consumption evidence](report.md#scope-3-tp-03-03-receipt-consumption-evidence)

## Scope 4: Authoritative G082 And Blocking Callers

**Status:** Not Started

**Depends On:** 3

**Scope-Kind:** runtime-behavior

**Root Findings:** RF-B037-02, RF-B037-07

**Requirements:** See [Requirement Coverage](#requirement-coverage), Scope 4.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-012 G082 and G128 share authority but retain distinct aggregation
  Given host-current has two rows for one spec and one row for another spec
    And host-old has a larger row for the target spec
  When actionable callers invoke G082 and G128 with the same packet session
  Then G082 returns the current target-spec maximum and excludes host-old
    And G128 returns the current sum across specs and agents

Scenario: SCN-B037-013 Blocking callers accept only one closed child result
  Given G082 or G128 emits an empty, duplicate, contradictory, malformed, unknown, or mismatched final record
  When Check 23, Check 40, or framework validation parses the child output and process exit
  Then the caller emits its own INPUT-ERROR with exit 2
    And it never selects a valid-looking last record or treats exit zero alone as success

Scenario: SCN-B037-014 Blocking authority and guard availability fail closed
  Given packet authority is missing, stale, non-actionable, scoped differently, or mismatched to the forwarded session
    Or the registered guard is missing, a symlink, non-regular, non-executable, or replaced
  When a blocking caller reaches its authority or availability check
  Then it blocks before guard evaluation with caller-owned INPUT-ERROR
    And unavailable enforcement is never reported as a skip or pass
```

### Implementation Plan

1. Add exact `--session-id` handling to G082.
2. Capture one immutable state revision and filter by exact session and target spec.
3. Preserve G082 maximum semantics and G128 sum semantics.
4. Validate the actionable packet before Check 23, Check 40, or live guard invocation.
5. Compare the validated packet session with the forwarded guard session.
6. Require each registered guard to be a stable regular executable file.
7. Capture one child invocation and count anchored final records.
8. Enforce the complete status and process-exit matrix.
9. Preserve `BREACH` exit 1 and `INPUT-ERROR` exit 2 as distinct failures.
10. Replay required child diagnostics and append one caller-owned final record.

### Scope Change Boundary

Allowed production paths are G082, the tail convergence gate fragment, and
framework validation. The parent state-transition script and repository-binding
implementation remain unchanged. Allowed tests are the G082, transition, and
framework-tier selftests.

### Test Plan

| ID | Scenario | Type | File | Required assertion | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| TP-04-01 | SCN-B037-012 | functional | `bubbles/scripts/convergence-cap-guard-selftest.sh` | Real G082 filters exact session and target spec, retains maximum semantics, rejects malformed matching rows, and emits only PASS, BREACH, or INPUT-ERROR. | `/bin/bash bubbles/scripts/convergence-cap-guard-selftest.sh` | Yes, production G082 over ephemeral state |
| TP-04-02 | SCN-B037-013 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Check 23 and Check 40 validate actionable authority, invoke stable guards once, preserve G082 and G128 distinctions, and reject every invalid status, exit, or availability pair. | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes, real caller fragments and guards |
| TP-04-03 | SCN-B037-014 | functional | `bubbles/scripts/framework-validate-tier-selftest.sh` | The live G128 check validates authority and applies the same closed parser and guard-availability contract under core and full tier selection. | `bash bubbles/scripts/framework-validate-tier-selftest.sh` | Yes, real framework validation caller path |

### Definition of Done

- [ ] G082 consumes the authoritative session and one immutable revision while retaining its per-spec maximum.
- [ ] G128 retains its active-session sum across specs and agents.
- [ ] Check 23, Check 40, and live framework validation validate actionable authority before guard invocation.
- [ ] Blocking callers reject unavailable guards and every invalid final-record count, vocabulary, and exit pair.
- [ ] Caller diagnostics preserve BREACH and INPUT-ERROR as distinct statuses and exits.
- [ ] Scope 4 changes remain inside its declared path boundary.
- [ ] Test TP-04-01 passes for SCN-B037-012 G082 isolation and aggregation.
- [ ] Test TP-04-02 passes for SCN-B037-012 through SCN-B037-014 transition callers.
- [ ] Test TP-04-03 passes for SCN-B037-013 and SCN-B037-014 framework validation.

## Scope 5: Concurrency, Portability, And Release Epoch

**Status:** Not Started

**Depends On:** 4

**Scope-Kind:** runtime-behavior

**Root Findings:** RF-B037-08, RF-B037-09

**Requirements:** See [Requirement Coverage](#requirement-coverage), Scope 5.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-005 Concurrent sessions preserve exact rows, mappings, and verdicts
  Given two sessions use the same spec and agent with different policy heads and expected iterations
  When concurrent producers complete through flock and then mkdir locking
  Then each run adds exactly one physical receipt per expected session
    And every session maps to its expected iteration, policy revision, G082 verdict, and G128 verdict
    And no dictionary, set, or unique count can hide a duplicate row

Scenario: SCN-B037-008 Existing policy and platform contracts remain intact
  Given the final repair uses only the approved paths and existing seven cap declarations
  When persistent regressions execute every changed producer, guard, caller, reader, lock, and error path
  Then cap values, nulls, strict comparisons, soft boundary, history, no-bypass behavior, and G085 remain unchanged
    And stock macOS Bash 3 records the actual interpreter of each changed production child
    And the same contracts execute under the supported GNU and Bash environment

Scenario: SCN-B037-015 Release metadata belongs to the final unchanged candidate
  Given every managed source, test, contract, and expected-behavior edit is complete
  When the release manifest is generated and the candidate bytes are frozen
    And manifest check, framework validation, and release check run without another edit
  Then every freshness and validation verdict belongs to the same candidate epoch
```

### Implementation Plan

1. Expand concurrency fixtures to compare physical row deltas and each expected row.
2. Assert every session-to-iteration and session-to-policy revision mapping.
3. Run both G082 and G128 verdict pairs after flock and mkdir lock strategies.
4. Make persistent regression claims match the production paths they execute.
5. Add an adversarial RED case with a stable scenario identity and real negative control.
6. Keep invalid historical receipt rows immutable and excluded from positive evidence.
7. Record actual child `BASH`, `BASH_VERSION`, and source path for every changed shell child.
8. Run the same scenario contract under stock macOS Bash 3 and the supported Bash environment.
9. Reconcile workflow, gate, quality-guide, skill, and agent contract text.
10. Confirm all configured cap declarations remain byte-identical.
11. Generate `bubbles/release-manifest.json` after every final managed edit.
12. Freeze the candidate before freshness, focused, full, and release checks.
13. Restart the final sequence after any managed-byte change.

### Scope Change Boundary

All production, test, contract, agent, and generated paths in the immutable
boundary are available only for the exact reconciliation defined by the design.
Repository-binding source, the parent transition guard, tool-log production,
CLI, release-check implementation, G085, and cap declarations remain unchanged.

### Final Candidate Sequence

1. Finish source, test, contract, and planning edits.
2. Run `bash bubbles/scripts/generate-release-manifest.sh`.
3. Freeze the candidate bytes.
4. Run TP-05-06 through TP-05-08 in order.
5. Restart at step 1 after any managed-byte change.

### Test Plan

| ID | Scenario | Type | File | Required assertion | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| TP-05-01 | SCN-B037-005 | integration | `bubbles/scripts/runtime-concurrency-selftest.sh` | Real concurrent producers prove exact receipt deltas, every session mapping, both policy heads, and both G082 and G128 verdict pairs after flock and mkdir locking. | `/bin/bash bubbles/scripts/runtime-concurrency-selftest.sh` | Yes, concurrent production processes and filesystem |
| TP-05-02 | SCN-B037-005 | integration | `bubbles/scripts/tool-log-selftest.sh` | Concurrent completed wrapper calls add exactly one physical row per expected session. Duplicate rows cannot collapse behind a keyed projection. | `/bin/bash bubbles/scripts/tool-log-selftest.sh` | Yes, concurrent real wrapper calls |
| TP-05-03 | SCN-B037-008 | integration | `bubbles/scripts/state-snapshot-selftest.sh` | Final state tests prove both lock paths, exact convergence and policy mappings, invalid-authority zero-side-effect behavior, and actual child interpreter records. | `/bin/bash bubbles/scripts/state-snapshot-selftest.sh` | Yes, real producer, validator, locks, and state |
| TP-05-04 | SCN-B037-008 | functional | `tests/regression/test_22_session_cap_enforcement.sh` | Stock macOS Bash 3 executes every claimed production path with adversarial controls and verifies each changed production child's actual interpreter identity. | `/bin/bash tests/regression/test_22_session_cap_enforcement.sh` | Yes, persistent production-path regression |
| TP-05-05 | SCN-B037-008 | functional | `tests/regression/test_22_session_cap_enforcement.sh` | The supported Bash and GNU environment preserves the same statuses, exits, mappings, diagnostics, and negative controls. | `bash tests/regression/test_22_session_cap_enforcement.sh` | Yes, persistent cross-platform regression |
| TP-05-06 | SCN-B037-015 | functional | `bubbles/scripts/generate-release-manifest.sh` | The generated manifest is fresh for every final managed source, test, contract, and planning byte. | `bash bubbles/scripts/generate-release-manifest.sh --check` | No, deterministic generated-artifact check |
| TP-05-07 | SCN-B037-015 | functional | `bubbles/scripts/cli.sh` | Full framework validation executes the focused and persistent BUG-037 paths on the frozen candidate. | `bash bubbles/scripts/cli.sh framework-validate` | Yes, complete framework validation surface |
| TP-05-08 | SCN-B037-015 | functional | `bubbles/scripts/cli.sh` | Release readiness reruns full validation and derived-artifact freshness on the same unchanged candidate. | `bash bubbles/scripts/cli.sh release-check` | Yes, source release gate |

### Definition of Done

- [ ] Exact physical receipt deltas and every session mapping are proven under both lock strategies.
- [ ] Persistent regression executes every producer, guard, blocking caller, authority rejection, lock rejection, immutable-read race, status rule, and G082 path it claims.
- [ ] Each RED record has a nonzero intended assertion failure, stable scenario identity, implementation refs, and negative control.
- [ ] Stock macOS Bash 3 evidence records the actual interpreter and source path of every changed production child.
- [ ] The supported Bash and GNU environment preserves the same behavior and closed status contracts.
- [ ] Workflow, gate, guide, skill, and agent contract text matches the implemented exact-session behavior.
- [ ] SCN-B037-008 preserves every cap value, null, strict comparison, 70 percent soft boundary, retained history, no-bypass behavior, and G085 behavior.
- [ ] No IMP-055 concept, tool-call producer, receipt proxy, or source-repository `specs/` directory exists in the change.
- [ ] The release manifest is generated only after the final managed edit and no managed byte changes afterward.
- [ ] Scope 5 changes remain inside the immutable boundary with zero excluded path changes.
- [ ] Test TP-05-01 passes for SCN-B037-005 row-level concurrency and both lock verdict pairs.
- [ ] Test TP-05-02 passes for SCN-B037-005 exact concurrent receipt multiplicity.
- [ ] Test TP-05-03 passes for final state, lock, mapping, authority, and child-interpreter integration.
- [ ] Test TP-05-04 passes under stock macOS Bash 3 for persistent SCN-B037-001 through SCN-B037-015 coverage.
- [ ] Test TP-05-05 passes under the supported Bash and GNU environment for the same persistent scenarios.
- [ ] Test TP-05-06 passes after final generation and proves SCN-B037-015 metadata freshness.
- [ ] Test TP-05-07 passes on the frozen candidate and exercises the complete framework validation surface.
- [ ] Test TP-05-08 passes on the same frozen candidate and proves final release readiness.
- [ ] Scenario manifest, Markdown Test Plans, structured test handoff, requirement ownership, and DoD test items remain in one-to-one agreement.
- [ ] A human records acceptance in [uservalidation.md](uservalidation.md) after reviewing implemented behavior.
- [ ] `bubbles.validate` owns any certification or terminal status transition.

## Plan Handoff

PLAN-B037-001 is addressed by this reconciled five-scope sequence. All nine
RF-B037 roots map once to an owning scope. Execution begins with Scope 1 only.
