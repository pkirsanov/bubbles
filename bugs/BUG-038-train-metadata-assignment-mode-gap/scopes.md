# BUG-038 Scopes

## Execution Outline

### Phase Order

1. **Scope 1: Direct-Only Train Metadata Assignment** — retain wildcard-aware mode admission while allowing mutation only when the authenticated active top-level runner is exactly `bubbles.train` and the ownership and owned-field authorities agree.

Scope 1 is the only active scope. It begins with focused failing regressions for the direct-only authorization boundary. Production changes follow only after those regressions demonstrate the stale behavior. Focused authorization, helper, alias, syntax, and portability checks gate implementation. Aggregate source-repository validation is not part of this planning reconciliation.

### New Types and Signatures

- Workflow mode: `release-train-assign-metadata`.
- V7 tuple: `ship action:assign target:train-metadata`.
- Runner admission: existing exact, wildcard, default-deny, and exclusion-aware `workflowModeGrants` semantics.
- Apply authority: authenticated active top-level runner is exactly `bubbles.train`; `BUBBLES_AGENT_NAME` is not authentication or ownership proof.
- Mutation authority: `bubbles.train` remains the exclusive `release-train-state` owner and each requested field must appear in the mode's `ownedStateFields`.
- Helper: `bubbles/scripts/release-train-metadata-assign.sh <spec-dir|state.json> --train <train-id> [--flags-json <json-array>] [--dry-run|--apply]`.
- State mutation: existing top-level `releaseTrain` and explicitly supplied `flagsIntroduced` only.
- Schema, `releaseTrainRef`, HTTP, protobuf, database, UI, deployment, and release-lifecycle changes: none.

### Validation Checkpoints

1. **Red checkpoint:** focused regressions fail on at least one stale authorization expectation before production changes.
2. **Admission checkpoint:** exact grants, wildcard grants, default deny, and exclusion precedence match the existing evaluator.
3. **Ownership checkpoint:** apply succeeds only for the authenticated top-level `bubbles.train` runner and refuses ownership or owned-field mismatches without mutation.
4. **Mutation checkpoint:** helper tests prove train validation, field isolation, flags semantics, dry-run non-mutation, and idempotence.
5. **Compatibility checkpoint:** the assignment tuple and existing train aliases remain resolvable.
6. **Portability checkpoint:** focused shell syntax and GNU/BSD-safe selftests pass.

## Overview and Ordering Rationale

Effective mode admission and mutation ownership are independent decisions. The existing exact, wildcard, default-deny, and exclusion-aware grant semantics decide admission. The current runtime cannot dispatch `bubbles.train` from a wildcard top-level runner, so wildcard admission is recognized while wildcard mutation is refused. One vertical contract-only scope keeps admission, ownership, mutation, and compatibility evidence together without implying a runtime capability that does not exist.

## Active Scope Inventory

| # | Scope | Depends On | Surfaces | Scenario Coverage | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Direct-Only Train Metadata Assignment | — | workflow admission, ownership registry, metadata helper, focused selftests, aliases | SCN-B038-001 through SCN-B038-013 | In Progress |

## Scope 1: Direct-Only Train Metadata Assignment

**Status:** In Progress

**Depends On:** None

**Scope-Kind:** contract-only

### Outcome

The mode recognizes existing exact, wildcard, and exclusion-aware runner grants. Dry-run may report admission and ownership findings without mutation. Apply changes only `releaseTrain` and an explicitly supplied `flagsIntroduced`, and succeeds only when the authenticated active top-level runner is exactly `bubbles.train`, the ownership registry names `bubbles.train` as the sole `release-train-state` owner, and the mode owns every requested field.

### Gherkin Scenarios

#### SCN-B038-001 — Direct bubbles.train apply succeeds

```gherkin
Scenario: Direct bubbles.train apply succeeds
Given the authenticated active top-level runner is exactly bubbles.train
And the assignment mode grants bubbles.train admission
And bubbles.train owns release-train-state and the mode owns the requested fields
When apply assigns an existing train
Then state.json records that train in releaseTrain
And only releaseTrain and an explicitly supplied flagsIntroduced may change
```

#### SCN-B038-002 — Wildcard admission does not grant mutation

```gherkin
Scenario: Wildcard admission does not grant mutation
Given a top-level runner is admitted to the assignment mode by a wildcard grant
And that runner is not bubbles.train
When authorization evaluates the request
Then mode admission is recognized
But apply is refused without changing state.json
```

#### SCN-B038-003 — Explicit exclusion wins over wildcard

```gherkin
Scenario: Explicit exclusion wins over wildcard
Given a runner has a wildcard mode grant
And release-train-assign-metadata is listed in its excluded modes
When authorization evaluates the assignment mode
Then admission is refused as excluded
And state.json remains unchanged
```

#### SCN-B038-004 — Environment declaration cannot impersonate the runner

```gherkin
Scenario: Environment declaration cannot impersonate the runner
Given the authenticated active top-level runner is not bubbles.train
And BUBBLES_AGENT_NAME says bubbles.train
When apply requests train metadata assignment
Then the request is refused because BUBBLES_AGENT_NAME is not authentication or ownership proof
And state.json remains unchanged
```

#### SCN-B038-005 — Missing active runner refuses

```gherkin
Scenario: Missing active runner refuses
Given no authenticated active top-level runner is available
When apply requests train metadata assignment
Then authorization refuses before mutation
And state.json remains unchanged
```

#### SCN-B038-006 — Ownership registry mismatch refuses

```gherkin
Scenario: Ownership registry mismatch refuses
Given the authenticated active top-level runner is bubbles.train
And the ownership authority does not name bubbles.train as the sole owner of release-train-state
When apply requests train metadata assignment
Then authorization refuses as an invalid ownership authority
And state.json remains unchanged
```

#### SCN-B038-007 — Mode owned-field mismatch refuses

```gherkin
Scenario: Mode owned-field mismatch refuses
Given the authenticated active top-level runner is bubbles.train
And the assignment mode omits one requested canonical field from ownedStateFields
When apply requests that field mutation
Then authorization refuses the field mismatch
And state.json remains unchanged
```

#### SCN-B038-008 — Dry-run reports without mutation

```gherkin
Scenario: Dry-run reports without mutation
Given a syntactically valid assignment request and readable authorities
When the helper runs in default or explicit dry-run mode
Then it reports the candidate and any admission or ownership finding
And it does not modify state.json or create a replacement candidate beside it
```

#### SCN-B038-009 — Train aliases remain compatible

```gherkin
Scenario: Train aliases remain compatible
Given the assignment tuple and existing train lifecycle and status aliases are registered
When each alias is resolved
Then the assignment tuple resolves to release-train-assign-metadata
And every existing train alias retains its current resolution
```

#### SCN-B038-010 — Unknown train refuses

```gherkin
Scenario: Unknown train refuses
Given the requested train is absent from config/release-trains.yaml
When bubbles.train requests assignment
Then the operation refuses and names the unknown train
And state.json remains byte-identical
```

#### SCN-B038-011 — Flags metadata remains bounded

```gherkin
Scenario: Flags metadata remains bounded
Given bubbles.train requests an existing train with optional flagsIntroduced metadata
When flags are omitted, explicitly empty, valid, malformed, or duplicated
Then omission preserves flagsIntroduced and an empty array clears it
And malformed or duplicate values refuse without mutation
```

#### SCN-B038-012 — Assignment has no lifecycle side effects

```gherkin
Scenario: Assignment has no lifecycle side effects
Given release configuration, feature-flag bundles, generated-output sentinels, and manifests have known digests
When bubbles.train applies metadata assignment
Then every sentinel digest remains unchanged
And no build, cut, tag, promote, rollback, retire, deployment, pointer, phase, or lifecycle action occurs or is claimed
```

#### SCN-B038-013 — Identical apply is an atomic no-op

```gherkin
Scenario: Identical apply is an atomic no-op
Given state.json already contains the requested canonical metadata
When bubbles.train repeats the same authorized apply
Then the operation succeeds without replacing the file
And its bytes, mode, and modification time remain unchanged
```

### Obligation Matrix

| Scenario | Behavior Traits | Obligations | Implementation References |
| --- | --- | --- | --- |
| SCN-B038-001 | `mutable-state`, `runtime-config` | direct-runner positive control; read-after-write; non-owned projection equality | `bubbles/scripts/release-train-metadata-assign.sh`, `bubbles/agent-capabilities.yaml`, `bubbles/agent-ownership.yaml`, `bubbles/workflows/modes.yaml` |
| SCN-B038-002 | `runtime-config`, `degraded-state` | prove wildcard admission separately; apply refusal; byte identity | existing runner-grant evaluator surface, assignment helper |
| SCN-B038-003 | `runtime-config`, `degraded-state` | runner-grant evaluator proves wildcard exclusion precedence; integrated assignment helper proves exclusion-specific refusal and byte identity | `bubbles/scripts/workflow-runner-grants-lint.sh`, `bubbles/scripts/release-train-metadata-assign.sh`, `bubbles/agent-capabilities.yaml` |
| SCN-B038-004 | `runtime-config`, `degraded-state` | wrong authenticated runner; contradictory environment declaration; no write | assignment helper authorization boundary |
| SCN-B038-005 | `degraded-state` | absent runner context; fail-closed refusal; no write | assignment helper authorization boundary |
| SCN-B038-006 | `runtime-config`, `degraded-state` | mutated ownership fixture; sole-owner verification; no write | `bubbles/agent-ownership.yaml`, assignment authorization surface |
| SCN-B038-007 | `runtime-config`, `degraded-state` | mutated mode fixture; requested-field containment; no write | `bubbles/workflows/modes.yaml`, assignment authorization surface |
| SCN-B038-008 | `static-metadata` | default and explicit dry-run; report findings; no destination or sibling mutation | assignment helper |
| SCN-B038-009 | `static-metadata` | assignment tuple resolution; existing alias compatibility matrix | `bubbles/workflows/aliases.yaml`, alias selftest |
| SCN-B038-010 | `degraded-state` | unknown ID in refusal; byte identity; no candidate residue | assignment helper |
| SCN-B038-011 | `mutable-state` | omission/presence distinction; clear; validation refusal; projection equality | assignment helper |
| SCN-B038-012 | `static-metadata` | before/after sentinels; forbidden-command instrumentation; bounded result language | assignment helper selftest |
| SCN-B038-013 | `mutable-state` | repeated apply; byte, mode, and mtime preservation | assignment helper selftest |

### Implementation Plan

1. Add focused failing cases for SCN-B038-001 through SCN-B038-008 before changing production authorization behavior.
2. Reuse the exact, wildcard, default-deny, and exclusion precedence semantics already implemented by `bubbles/scripts/workflow-runner-grants-lint.sh`; do not enumerate a sole effective grantee set.
3. Keep `bubbles/agent-ownership.yaml` as the read-only authority that exclusively assigns `release-train-state` to `bubbles.train`.
4. Keep `bubbles/workflows/modes.yaml` as the read-only-at-runtime authority for the assignment mode's `ownedStateFields` list.
5. Update the assignment helper so dry-run never mutates and apply requires mode admission, authenticated active top-level runner exactly `bubbles.train`, and matching ownership plus owned-field authority.
6. Treat `BUBBLES_AGENT_NAME` only as non-authoritative context. It cannot turn a wrong or missing top-level runner into an authorized mutation.
7. Preserve the existing top-level `releaseTrain` and optional `flagsIntroduced` fields. Do not introduce `releaseTrainRef` or any schema migration.
8. Preserve strict train and flags validation, same-directory atomic replacement, non-owned projection equality, and idempotent no-replacement behavior.
9. Update focused helper, runner-grant, ownership, mode-policy, and alias regressions. Remove every positive wildcard-mutation expectation.
10. Run only the focused implementation checks named in this scope before returning to the workflow for broader source validation.

### Change Boundary

**Allowed production and authority files:** `bubbles/scripts/release-train-metadata-assign.sh`; `bubbles/scripts/workflow-runner-grants-lint.sh` only to extract or reuse its existing exact, wildcard, default-deny, and exclusion-aware evaluator without changing semantics; `bubbles/agent-capabilities.yaml` only for the existing exact train grant; `bubbles/agent-ownership.yaml` only as the existing `release-train-state` authority with no ownership transfer; `bubbles/workflows/modes.yaml` only for the assignment mode and canonical `ownedStateFields`; `bubbles/workflows/aliases.yaml` only for the assignment tuple and compatibility; `agents/bubbles.train.agent.md`; the bounded operator references named by the design; and `bubbles/release-manifest.json` only after validation in a later implementation workflow.

**Allowed test files:** `bubbles/scripts/release-train-metadata-assign-selftest.sh`, `bubbles/scripts/workflow-runner-grants-lint-selftest.sh`, and existing focused ownership, mode-policy, and alias selftests only where additive BUG-038 assertions are required.

**Excluded surfaces:**

- `bugs/BUG-037-*` and all BUG-037 implementation, test, planning, and evidence files.
- Receipt-identity implementation, tests, fixtures, manifests, and active edits.
- Any persistent root `specs/` directory.
- `config/release-trains.yaml`, feature-flag bundles, generated config bundles, build artifacts, deployment manifests, pointers, adapters, and target-specific files.
- Runtime changes that would dispatch `bubbles.train` from a wildcard top-level runner.
- Wildcard mutation success, caller-controlled identity flags, `releaseTrainRef`, ownership transfer, or a sole-effective-grantee rule.
- Train cut, promote, rollback, retire, status, build, signing, publishing, retrieval, and deployment behavior except additive compatibility assertions proving it is unchanged.

Before implementation and again before handoff, inspect the changed-file set. Any excluded path is a blocking collision and must be left untouched without absorbing unrelated active work.

### Shared Infrastructure Impact Sweep

The runner evaluator, ownership registry, and workflow mode registry are high-fan-out framework contracts. Use additive hermetic fixtures for exact, wildcard, exclusion, owner mismatch, and field mismatch cases. Run focused canaries before broader suites. If a focused canary fails, restore only BUG-038 implementation changes. Do not reorder registry keys, reformat unrelated entries, transfer ownership, or alter global grant semantics.

### WSL/macOS Portability Contract

Both shell files must support Bash 3.2 on GNU/Linux and macOS/BSD. Use quoted expansions, `LC_ALL=C` where ordering matters, shared guard helpers where available, and a same-directory portable `mktemp` template. Do not use associative arrays, `mapfile`, `readlink -f`, `realpath`, GNU-only `sed -i`, platform-specific `stat` or `date` flags, or an internal dependency on `timeout`.

### Test Plan

Every row has one matching test-related Definition of Done item with the same ID.

| ID | Scenario | Type | File / Surface | Exact Command | Expected Proof |
| --- | --- | --- | --- | --- | --- |
| TP-B038-01 | SCN-B038-001 | adversarial regression, red/green | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Pre-fix failure and post-fix success prove direct `bubbles.train` apply and non-owned field isolation. |
| TP-B038-02 | SCN-B038-002 | authorization regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Wildcard mode admission is recognized while non-train top-level apply is refused without mutation. |
| TP-B038-03 | SCN-B038-003 | composite admission and no-mutation regression | `bubbles/scripts/workflow-runner-grants-lint-selftest.sh` and `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/workflow-runner-grants-lint-selftest.sh && timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | The production admission evaluator refuses an explicit assignment-mode exclusion after matching a wildcard grant, and the production assignment path reports the exclusion while preserving `state.json` bytes. Both selftests are required. |
| TP-B038-04 | SCN-B038-004 | adversarial authorization regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | A wrong top-level runner is refused even when `BUBBLES_AGENT_NAME=bubbles.train`. |
| TP-B038-05 | SCN-B038-005 | adversarial authorization regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Missing active runner context refuses before mutation. |
| TP-B038-06 | SCN-B038-006 | ownership contract regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Missing, duplicate, or mismatched `release-train-state` ownership refuses without mutation. |
| TP-B038-07 | SCN-B038-007 | mode policy regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Requested fields absent from `ownedStateFields` refuse without mutation. |
| TP-B038-08 | SCN-B038-008 | dry-run regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Default and explicit dry-run report candidate or findings while preserving destination bytes and sibling paths. |
| TP-B038-09 | SCN-B038-009 | compatibility regression | `bubbles/scripts/mode-alias-selftest.sh` | `timeout 180 bash bubbles/scripts/mode-alias-selftest.sh` | Assignment tuple and every existing train alias resolve without drift. |
| TP-B038-10 | SCN-B038-010 | validation regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Unknown train names the ID, preserves bytes, and leaves no candidate. |
| TP-B038-11 | SCN-B038-011 | boundary and round-trip regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Omitted, empty, valid, malformed, and duplicate flags follow the canonical field contract. |
| TP-B038-12 | SCN-B038-012 | side-effect boundary regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Sentinel digests remain unchanged and no lifecycle, build, pointer, or deployment operation occurs or is claimed. |
| TP-B038-13 | SCN-B038-013 | atomicity and idempotence regression | `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 180 bash bubbles/scripts/release-train-metadata-assign-selftest.sh` | Repeated identical apply preserves bytes, mode, and modification time. |
| TP-B038-14 | Supporting portability check | syntax and portability | `bubbles/scripts/release-train-metadata-assign.sh`, `bubbles/scripts/release-train-metadata-assign-selftest.sh` | `timeout 30 bash -n bubbles/scripts/release-train-metadata-assign.sh && timeout 30 bash -n bubbles/scripts/release-train-metadata-assign-selftest.sh` | Changed shell files parse and focused portability assertions pass. |

### Definition of Done

#### Implementation and Boundary Items

- [ ] The assignment tuple and mode retain exact, wildcard, default-deny, and exclusion-aware admission semantics without requiring a sole effective grantee.
- [ ] Apply succeeds only for the authenticated active top-level runner exactly equal to `bubbles.train`; wildcard, wrong, and missing runners cannot mutate.
- [ ] `release-train-state` ownership remains exclusively assigned to `bubbles.train`, and every requested field is contained in the mode's `ownedStateFields` list.
- [ ] Only existing top-level `releaseTrain` and optional `flagsIntroduced` are written; `releaseTrainRef` is absent.
- [ ] Dry-run, train validation, flags validation, field isolation, atomicity, idempotence, and closed side-effect boundaries are implemented.
- [ ] The Change Boundary and Shared Infrastructure Impact Sweep are satisfied with zero excluded-file changes or unrelated registry churn.
- [ ] Code Diff Evidence classifies every changed path, proves that implementation stayed within the allowed production and test file families, and proves that excluded surfaces were not changed by BUG-038.

#### Test Plan Parity Items

- [ ] **TP-B038-01 / SCN-B038-001 — Direct bubbles.train apply succeeds:** the red/green regression proves authorized canonical-field mutation and unrelated-field isolation.
- [ ] **TP-B038-02 / SCN-B038-002 — Wildcard admission does not grant mutation:** wildcard admission is recognized and non-train apply refuses without mutation.
- [ ] **TP-B038-03 / SCN-B038-003 — Explicit exclusion wins over wildcard without mutation:** both persistent selftests pass; the grant evaluator proves exclusion precedence, and the integrated assignment path reports the exclusion while preserving `state.json` bytes.
- [ ] **TP-B038-04 / SCN-B038-004 — Environment declaration cannot impersonate the runner:** a wrong runner refuses despite `BUBBLES_AGENT_NAME=bubbles.train`.
- [ ] **TP-B038-05 / SCN-B038-005 — Missing active runner refuses:** absent authenticated runner context fails closed before mutation.
- [ ] **TP-B038-06 / SCN-B038-006 — Ownership registry mismatch refuses:** missing, duplicate, or mismatched sole ownership refuses without mutation.
- [ ] **TP-B038-07 / SCN-B038-007 — Mode owned-field mismatch refuses:** any requested field absent from `ownedStateFields` refuses without mutation.
- [ ] **TP-B038-08 / SCN-B038-008 — Dry-run reports without mutation:** default and explicit dry-run report candidate or findings while preserving destination bytes and sibling paths.
- [ ] **TP-B038-09 / SCN-B038-009 — Train aliases remain compatible:** the assignment tuple and existing train aliases resolve without drift.
- [ ] **TP-B038-10 / SCN-B038-010 — Unknown train refuses:** refusal names the unknown train, preserves bytes, and leaves no candidate.
- [ ] **TP-B038-11 / SCN-B038-011 — Flags metadata remains bounded:** omission, clearing, validation, duplicate rejection, and canonical-field mutation behave as specified.
- [ ] **TP-B038-12 / SCN-B038-012 — Assignment has no lifecycle side effects:** configuration, bundle, manifest, lifecycle, build, pointer, and deployment sentinels remain unchanged.
- [ ] **TP-B038-13 / SCN-B038-013 — Identical apply is an atomic no-op:** repeated identical apply preserves bytes, mode, and modification time.
- [ ] **TP-B038-14:** Active-shell syntax passes, static portability review finds no Bash 4-only or GNU/BSD-specific construct, and native Bash 3.2 execution is recorded as environment-unavailable unless it is actually executed.

#### Completion Gate

- [ ] All 13 active scenario contracts have durable evidence, all 14 Test Plan rows have one-to-one parity items, no required check is skipped, and the owning validation agent accepts the final transition.

### Test-Owned Routed Remediation Record

**Phase:** test

**Claim Source:** executed

The BUG-050 regression findings `B050-REG-SHELLCHECK-05`, `B050-REG-SHELLCHECK-06`, and `B050-REG-SHELLCHECK-07` were remediated in the allowed BUG-038 selftest. The focused warning-level ShellCheck moved from exactly three `SC2034` diagnostics to zero diagnostics. The complete assignment selftest, linked runner-grant selftest, linked alias selftest, scenario resolution, traceability, syntax, portability, regression-quality guard, and repository ShellCheck lint all passed after the final test edit. See [Routed ShellCheck Test Remediation](report.md#routed-shellcheck-test-remediation---current-session).

This record changes no Test Plan row, scenario, DoD checkbox, scope status, or certification field. It does not claim a complete independent run of all 14 Test Plan rows. Scope 1 remains `In Progress`, and complete independent Test Plan execution remains assigned to `bubbles.test`.

## Superseded Scopes (Do Not Execute)

The prior authorization plan expected a wildcard top-level runner to reach mutation by presenting `bubbles.train` as a separate actor. The current runtime cannot dispatch `bubbles.train` from that runner. That expectation is superseded and must not be implemented or tested as success. Wildcard admission remains valid, followed by direct-only mutation refusal.
