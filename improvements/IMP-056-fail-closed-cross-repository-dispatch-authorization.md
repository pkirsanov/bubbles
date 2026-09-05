# IMP-056 — Fail-Closed Repository Mutable-Dispatch Authorization

**Status:** IN PROGRESS — SCOPE-1 (planning) and SCOPE-2 (broker snapshot/executable hardening) landed prior to 2026-09-05. SCOPE-3 (signed mutable-dispatch authorization) landed 2026-09-05: `mutable-dispatch-authorization.sh` mint/verify, reusing `security-authority.py` under purpose `mutable-dispatch-authorization`; 17/17 selftest, mutation-verified, all 11 named negative-coverage cases present. Investigation ahead of SCOPE-3 found SCOPE-2 is less complete than its landed commits suggest: the `launch-pending`/`launch-confirmed`/`launch-denied`/`launch-ambiguous` ledger vocabulary SCOPE-2 itself specifies, and SCOPE-2's own required adversarial broker selftest, do not exist anywhere in the tree yet (confirmed by a repo-wide search) — real, open gaps in SCOPE-2, not introduced by SCOPE-3, and not blocking for SCOPE-3's standalone contract surface. SCOPE-4 (canonical final-edge gateway) is next and will need SCOPE-2's launch-state ledger to exist to wire `verify` in before `launch-pending` as designed.
**Owner approval:** 2026-09-02. The owner approved the corrected repository-enforceable scope and incremental delivery.
**Workflow mode:** `implement action:full-delivery target:spec`
**Status ceiling:** `done` for the bounded repository-reference enforcement contract only. This status does not claim native host interception or IMP-057 completion.
**Surface:** framework-health (G125)
**Verified gaps addressed:** GF-16 — resolver success is not mutation authorization; GF-17 — repository ownership is conflated with dispatch authority; HO-7 — mutable runners lack one mandatory authorization edge; EV-17 — post-execution evidence is conflated with pre-execution authority; COV-22 — denied and ambiguous launches lack adversarial coverage

## Design Brief

### Current State

The repository can validate an actionable repository packet, classify a goal boundary, emit and verify `goal-boundary-receipt/v1`, issue a one-use IMP-055 permit, and route reference-enforced commands through `bubbles/adapters/dispatch/reference-broker.sh`. These mechanisms remain separate. The broker rereads caller-controlled action data and launches an executable through a mutable pathname after consuming the permit.

The phase coordinator also retains command paths that bypass the reference broker. Result-envelope fields describe completed work, so they arrive too late to authorize process creation.

### Target State

Every repository-mediated mutable child launch passes one final authorization edge that composes current repository authority, exact `in-boundary` classification, the unchanged G134 receipt, a signed `mutable-dispatch-authorization/v1`, immutable launch identities, and the current one-use IMP-055 permit. The reference broker records launch intent before permit consumption and treats unresolved process creation as ambiguous rather than safe to retry.

This improvement proves repository-reference enforcement only. IMP-057 owns native host interception and activation.

### Patterns to Follow

- Preserve `bubbles/scripts/repository-binding.sh` as the host-authoritative repository decision.
- Preserve `bubbles/scripts/goal-boundary-receipt.sh` and `goal-boundary-receipt/v1` unchanged.
- Reuse `bubbles/scripts/security-authority.py` with purpose `mutable-dispatch-authorization`.
- Reuse the IMP-055 permit, event ledger, reservation, usage, and settlement model.
- Reuse `dispatchAdmission.adapter`; absence remains equivalent to `none`, and `reference-broker` remains repository-only.

### Patterns to Avoid

- Do not treat resolver exit 0, repository ownership, route destination, workspace membership, or an envelope claim as authorization.
- Do not build a gateway over the current broker before removing action-file, executable-path, and interpreter-path time-of-check/time-of-use gaps.
- Do not prescribe `/proc`, `/dev/fd`, `fexecve`, or another launch primitive until a capability probe proves its contract.
- Do not add a second activation key, compatibility bypass, automatic retry after ambiguity, or native-host claim.

### Resolved Decisions

- Broker snapshot and launch-state hardening precede gateway migration.
- The authorization contract is `mutable-dispatch-authorization/v1` and uses purpose `mutable-dispatch-authorization`.
- Authorization binds the action, executable, and interpreter identities used at launch.
- The broker uses a capability-proven immutable launch strategy and fails closed for unsupported combinations.
- `launch-ambiguous` holds the full reservation and prohibits automatic retry.
- Result-envelope authorization fields are post-execution audit evidence only.
- Native host interception is outside IMP-056 and independently tracked by IMP-057.
- Completing IMP-056 does not claim native VS Code, MCP, browser, ambient shell, or host coverage.

### Open Questions

- None for this planning slice. The runtime capability probe determines which immutable launch strategies are admitted during implementation.

## Authorization Invariants

A repository-mediated mutable child may reach process creation only when all of these hold at the final edge:

1. The current repository packet validates against authoritative session control at the expected control revision.
2. Boundary resolution contains exactly one recognized disposition and it is exactly `in-boundary`.
3. The existing `goal-boundary-receipt/v1` verifies unchanged against current goal, source request, semantic boundary, repository, and control state.
4. A `mutable-dispatch-authorization/v1` verifies through `security-authority.py` with purpose `mutable-dispatch-authorization`.
5. The authorization binds the canonical action bytes and immutable executable and interpreter identities selected by the broker.
6. A current IMP-055 one-use permit binds the same action digest, repository, occurrence, reservation, and enforcement kind.
7. `dispatchAdmission.adapter` resolves to `reference-broker`. Absence or `none` admits no mutable child dispatch.
8. A capability probe supports the platform, executable type, interpreter combination, and immutable launch strategy. Unknown combinations fail closed.

No one invariant substitutes for another. Cross-repository routing produces a packet for a destination session; it never grants source-session mutation authority.

## Launch State And Settlement

The existing chained event ledger gains a closed launch-state vocabulary:

- `launch-pending`: durable intent recorded before permit consumption;
- `launch-confirmed`: process creation is durably confirmed under the admitted strategy;
- `launch-denied`: authorization or launch preparation failed before process creation;
- `launch-ambiguous`: recovery cannot prove whether process creation occurred.

The broker records `launch-pending`, consumes the permit immediately before process creation, and then records a terminal launch state. Recovery converts unresolved pending records to `launch-ambiguous` unless durable evidence proves a terminal outcome. Ambiguity holds the full reservation, emits no automatic release, and prohibits automatic retry. Normal settlement retains the existing `debit`, `release`, and `hold` vocabulary.

## Problem (verified against source)

- **GF-16 — resolver success is not mutation authorization:** `bubbles/scripts/work-boundary-resolve.sh` returns exit 0 after printing any normal disposition, including routing and refusal dispositions. A consumer that checks only process success can therefore continue after a result other than exact `in-boundary`.
- **GF-17 — repository ownership is not mutation authority:** `bubbles/scripts/repository-binding.sh` validates the actionable repository packet and treats external host control as authoritative over the local session mirror. That establishes which repository is actionable. It does not authorize a particular mutable dispatch, and a routed owner match must not be treated as that authorization.
- **HO-7 — no mandatory final repository edge:** the phase coordinator can route through the reference broker, but it also retains direct mutable command execution. The four orchestrator definitions do not establish one mechanically mandatory final edge.
- **EV-17 — audit evidence is not launch authority:** result-envelope fields are produced after execution. They can record the authorization, permit, launch state, and settlement used, but cannot authorize an action that has already run.
- **COV-22 — launch identity and ambiguity are unproved:** focused tests cover resolver, receipt, and permit mechanics. They do not prove that changed action, executable, or interpreter bytes cannot run, or that a post-consumption broker interruption holds reservation and suppresses retry.
- **Broker TOCTOU:** the reference broker validates an action file, consumes a permit, rereads `.argv[]`, and launches through a mutable pathname. The action, executable, shebang interpreter, or explicit interpreter can change between validation and process creation.
- **Crash ambiguity:** filesystem records, permit consumption, and process creation cannot be literally atomic. A broker failure after consumption cannot safely be classified as either launched or not launched without strategy-specific durable proof.

**Sanitized incident reproduction:** Current-session execution against a boundary declaring one downstream repository and `crossRepoPolicy: forbidden` emitted `disposition=refuse-cross-repo`, `repoMatch=false`, and a reason that another repository must not be touched unless authorized, while the resolver exited 0.

## Proposal

### SCOPE-1 — Proposal And Contract Correction

- Reconcile IMP-056 and the improvement index to the approved repository-only design.
- Record the done-capable full-delivery workflow, bounded `done` ceiling, six-scope order, and independent IMP-057 native-host proposal.
- State that IMP-056 completion covers repository-reference mutable command-vector enforcement only and does not claim native coverage.
- Preserve all runtime, schema, gate, generated, and release surfaces unchanged in this slice.

### SCOPE-2 — Broker Action/Executable Snapshot And Crash-State Hardening

- Add a capability probe and closed support matrix for immutable launch strategies.
- Parse caller action bytes once, canonicalize once, and retain a broker-owned snapshot through launch.
- Bind executable bytes and every interpreter involved. Fail closed when the platform or executable form cannot launch bound identities without reopening mutable paths.
- Add `launch-pending`, `launch-confirmed`, `launch-denied`, and `launch-ambiguous` events to the existing ledger and recovery path.
- Preserve one-use permit semantics. On unresolved post-consumption state, hold the full reservation and prohibit automatic retry.
- Add adversarial tests that mutate action files, executable paths, shebang interpreters, and explicit interpreters after validation and prove the changed bytes cannot execute.

### SCOPE-3 — Signed Mutable-Dispatch Authorization — **DONE**

New `bubbles/scripts/mutable-dispatch-authorization.sh` (`mint`/`verify`) plus `mutable-dispatch-authorization-selftest.sh` (17/17, mutation-verified). Built after reading SCOPE-2's actual landed state first, not assuming it: `reference-broker-snapshot.py`'s `snapshot-metadata.json` shape (`actionDigest`, `executable.sha256`, `launchForm`) and `measured-budget-runtime.py`'s `permit_issue()` record shape (`permitId`, `reservationId`, `occurrenceId`, `actionDigest`, `enforcementKind`, closed to `repository-reference`) are the two real, stable inputs this binds to — both confirmed by reading the source, not by trusting the design brief's field names.

- ~~Define the closed canonical schema for `mutable-dispatch-authorization/v1`.~~ **DONE.** 18 closed fields (19 with `authenticator`): `contractType`, `schemaVersion`, `repositoryAlias`, `controlRevision`, `controlDecisionId`, `boundary`, `receiptDigest`, `actionDigest`, `executableDigest`, `interpreterDigest` (`sha256:absent` when the launch form has no separate interpreter — currently true for every admitted SCOPE-2 launch strategy), `permitId`, `reservationId`, `occurrenceId`, `enforcementKind`, `authorityId`, `trustRootId`, `issuedAt`, `expiresAt`, `authenticator`. Verify refuses any authorization whose field set is not exactly this set.
- ~~Reuse `security-authority.py` with purpose `mutable-dispatch-authorization`...~~ **DONE.** No second signing implementation; both mint and verify shell out to `security-authority.py sign`/`verify`, mirroring `execution-control-store.py`'s own checkpoint mint/verify pattern (build the unsigned body, sign it, merge `authenticator`; on verify, pop `authenticator` and recompute).
- ~~Mint only after current repository authority, exact boundary classification, and unchanged G134 receipt verification succeed.~~ **DONE.** `mint` runs `repository-binding.sh validate-packet`, then `work-boundary-resolve.sh` (parsing `disposition=in-boundary` explicitly — checking exit 0 alone is the GF-16 mistake this whole proposal exists to close), then `goal-boundary-receipt.sh verify --expect-boundary pre-dispatch`, in that order, aborting with nothing printed and that check's own exit code on the first failure — the same "prerequisite runs first" discipline `goal-boundary-receipt.sh emit` itself uses. Proven with a real end-to-end fixture (a genuine repository packet, control file, frozen goal contract, and pre-dispatch receipt — not stubs), plus three refusal cases each breaking exactly one of the three checks.
- ~~Verify immediately before `launch-pending` and bind the broker snapshot, receipt, permit, repository control revision, and expiry.~~ **DONE, scoped correctly.** Verify binds all of these; wiring the CALL to happen immediately before `launch-pending` is SCOPE-4's canonical-gateway integration, per this proposal's own Files-To-Touch table — SCOPE-3's surface is the standalone contract, not the broker. Also found and documented, not hidden: SCOPE-2's own `launch-pending`/`launch-confirmed`/`launch-denied`/`launch-ambiguous` ledger vocabulary and its adversarial broker selftest do not exist yet anywhere in the tree (confirmed by repo-wide search) — SCOPE-3 does not depend on them and was scoped to not need them, but SCOPE-4 will.
- ~~Add negative coverage for altered, stale, substituted, wrong-purpose, wrong-repository, wrong-revision, wrong-receipt, wrong-action, wrong-executable, wrong-interpreter, and expired authorizations.~~ **DONE, all 11.** Each is its own selftest case (`V1`-`V11`, plus `V12` for the closed-schema shape). Two were caught and fixed by the selftest's own mutation-testing pass before being trusted: `V7` (wrong-action) initially passed for the wrong reason because its fixture builder generated a fresh random executable digest on every call, incidentally also tripping the wrong-executable check; `V1` (altered) initially passed because it mutated `controlRevision`, which is independently cross-checked (redundant with `V5`) rather than exercising the authenticator alone. Both fixtures were corrected and re-mutation-tested to confirm they now fail for the intended reason and pass once restored.

### SCOPE-4 — Canonical Final-Edge Gateway And Mandatory Permit Composition

- Add one final repository mutable-dispatch gateway over the hardened broker.
- Require all authorization invariants before process creation and return a closed refusal before any child launch on failure.
- Require a current IMP-055 one-use permit for every mutable repository command vector. No orchestrator, adapter, or command class receives an implicit exemption.
- Continue using `dispatchAdmission.adapter`; `none` and absence deny child dispatch, while `reference-broker` selects repository-reference enforcement.
- Keep route composition and read-only analysis outside the mutable path. A routed destination establishes its own session authority, receipt, authorization, and permit.

### SCOPE-5 — Post-Execution Result-Envelope Audit Contract

- Add conditional audit fields for mutable dispatch outcomes without presenting them as pre-execution authority.
- Populate fields only from durable broker and ledger records after execution or refusal.
- Keep read-only, advisory, route-only, and blocked-before-dispatch envelopes compatible.
- Add schema and semantic tests that reject claims inconsistent with recorded authorization, permit, launch state, or settlement while proving envelope data cannot open the gateway.

### SCOPE-6 — Phase-Coordinator Migration And Validation Wiring

- Remove direct mutable command execution from `phase-coordinator.sh`; repository-mediated mutable children must use the canonical gateway.
- Migrate the four mutable orchestrator definitions to the same final edge without duplicating authorization logic.
- Add caller-coverage checks that enumerate mutable command vectors and fail on a broker or gateway bypass.
- Wire focused selftests, framework validation, gate metadata, installer/release inventory, and downstream synchronization required by changed surfaces.
- Complete the bounded repository-reference contract only after all six repository-owned scopes, tests, and gates pass.
- Do not claim or activate native host interception. IMP-057 independently owns those surfaces.

## Migration / rollout

1. Correct planning truth without changing runtime surfaces.
2. Prove immutable launch strategies and harden broker snapshot and recovery behavior.
3. Add signed authorization over the hardened snapshot and current authority bindings.
4. Add the final-edge gateway and require the IMP-055 permit on every mutable repository vector.
5. Add post-execution envelope audit fields without using them as authority.
6. Remove coordinator bypasses, migrate orchestrators, and wire validation and release inventory.

No new feature flag or activation key is introduced. `dispatchAdmission.adapter` remains the single configuration seam. Absence or `none` denies child dispatch, `reference-broker` selects repository-reference enforcement, and unknown values fail loud.

IMP-056 may reach `done` only when its repository-reference mutable command-vector contract passes every repository-owned scope, test, and gate. Native VS Code, MCP, browser, ambient shell, and host interception remain outside this contract. IMP-057 tracks that separate proposal independently. IMP-056 sets no native activation date and makes no native coverage claim.

## Risks & mitigations

- **R1 — immutable launch is unsupported for a platform or executable type** → deny through a closed capability matrix and add support only after an executable probe proves the exact contract.
- **R2 — broker interruption leaves uncertain execution** → classify as `launch-ambiguous`, hold the full reservation, and prohibit automatic retry.
- **R3 — authorization and permit identities drift** → sign and verify the same canonical snapshot and link records through occurrence and reservation identities.
- **R4 — a legacy command bypasses the gateway** → remove coordinator direct execution and enforce caller coverage with structural and mutation tests.
- **R5 — post-execution evidence is mistaken for authority** → derive envelope fields from durable broker records and prove envelope input cannot open the gateway.
- **R6 — repository enforcement is overstated as native enforcement** → retain the `repository-reference` enforcement kind and state that `done` excludes IMP-057 and native-host coverage.

## Acceptance Criteria

- [ ] The proposal and index carry the approved title, IN PROGRESS status, done-capable workflow, bounded `done` ceiling, and six-scope order.
- [ ] The broker launches only a capability-proven immutable action, executable, and interpreter snapshot and never rereads caller action bytes.
- [ ] Unsupported platform, executable, interpreter, or launch-strategy combinations fail closed before permit consumption.
- [x] `mutable-dispatch-authorization/v1` verifies under purpose `mutable-dispatch-authorization` and binds current repository, receipt, snapshot, and permit identities. **DONE (SCOPE-3).** Standalone contract verified; wiring `verify` into the broker's launch sequence is SCOPE-4.
- [ ] Every mutable repository command vector requires the current IMP-055 one-use permit at the final edge.
- [ ] A durable `launch-pending` precedes permit consumption, and every recoverable occurrence reaches one closed terminal launch state.
- [ ] Unprovable post-consumption state becomes `launch-ambiguous`, holds the full reservation, and cannot automatically retry.
- [ ] Result-envelope fields are post-execution audit evidence and cannot authorize process creation.
- [ ] `phase-coordinator.sh` and all four mutable orchestrators use the canonical gateway with no direct mutable bypass.
- [ ] All six repository-owned scopes and their focused tests, caller-coverage checks, gates, validation wiring, and release inventory pass before IMP-056 reaches `done`.
- [ ] IMP-056 `done` means only that repository-reference mutable command-vector enforcement is complete.
- [ ] No IMP-056 status, evidence, or release claim treats `done` as IMP-057 completion or native host interception coverage.

## Files To Touch By Scope

| Scope | Expected surfaces | Constraint |
|---|---|---|
| SCOPE-1 | This proposal and `improvements/INDEX.md` | Planning truth only |
| SCOPE-2 | Reference broker, measured-budget runtime/finalizer, capability probe, focused selftests | Harden before gateway work |
| SCOPE-3 | ~~Authorization schema/issuer/verifier, security-authority integration, focused selftests~~ **DONE** — `bubbles/scripts/mutable-dispatch-authorization.sh` + `-selftest.sh` | Reuse existing authority implementation |
| SCOPE-4 | Canonical final-edge gateway and integration selftests | Compose all invariants and current permit |
| SCOPE-5 | Result-envelope schema, producers, consumers, semantic tests | Audit-only fields |
| SCOPE-6 | Phase coordinator, four orchestrator definitions, caller coverage, gates, validation and release inventory | Repository contract may reach `done`; native surfaces remain excluded |

The table is an implementation map, not authorization to edit later-scope surfaces during this slice.

## Testing And Validation Strategy

| Behavior | Test type | Required assertion |
|---|---|---|
| Proposal/index state | Framework-health lint | Title and status agree; IMP-057 is unchanged |
| Immutable snapshot | Adversarial broker selftest | Mutating action bytes cannot change launched argv |
| Executable identity | Adversarial broker selftest | Replacing a pathname cannot execute replacement bytes |
| Interpreter identity | Adversarial broker selftest | Replacing shebang or explicit interpreter bytes cannot execute changed bytes |
| Unsupported strategy | Capability-matrix selftest | Unknown combinations deny before launch |
| Authorization binding | Authority selftest | Altered purpose, revision, receipt, permit, action, or identity is rejected |
| Exact boundary | Gateway selftest | Every disposition except one exact `in-boundary` suppresses launch |
| Permit composition | Runtime integration test | Every mutable vector requires one current permit and replay is rejected |
| Crash recovery | Broker interruption test | Unresolved post-consumption launch becomes ambiguous and holds reservation |
| Retry prohibition | Runtime integration test | An ambiguous occurrence cannot automatically launch again |
| Audit-only envelope | Schema and semantic test | Envelope fields reflect records but cannot authorize gateway entry |
| Caller coverage | Structural and mutation test | Coordinator and four orchestrators cannot bypass the final edge |

Tests must use real broker processes and temporary files where process identity or crash ordering is under test. Parser-only tests cannot substantiate launch behavior. Mutation sensitivity must prove weakened identity, ambiguity, and bypass checks fail.

## Alternatives Considered

- **Envelope-gated execution:** rejected because envelopes are post-execution artifacts.
- **Gateway first over the current broker:** rejected because it preserves action and executable TOCTOU beneath a stronger-looking API.
- **Path plus stat metadata binding:** rejected because it does not bind the bytes executed after validation.
- **One launch primitive for every platform and type:** rejected until capability probes prove equivalent guarantees.
- **Release reservation on uncertain launch:** rejected because the child may already have started.
- **Automatic retry after broker interruption:** rejected because permit consumption does not prove whether process creation occurred.
- **New activation flag:** rejected because `dispatchAdmission.adapter` already owns repository dispatch admission.

## Complexity Tracking

| Deviation from simpler alternative | Simpler alternative | Why rejected |
|---|---|---|
| Signed authorization in addition to receipt and permit | Treat one artifact as sufficient | Repository authority, semantic boundary, and budget authority answer different questions |
| Immutable executable and interpreter snapshot | Validate and launch by path | Path validation does not bind later-executed bytes |
| Four launch states and recovery | Infer launch from permit consumption | Process creation and durable record writes are not atomic |
| Capability-gated launch strategies | Prescribe one OS primitive | No primitive is yet proved across supported platforms and executable forms |

## Provenance

This corrected design derives from current-session source inspection on 2026-09-02 of:

- `bubbles/adapters/dispatch/reference-broker.sh` for action parsing, permit consumption, action reread, pathname launch, and repository-reference capability claims;
- `bubbles/scripts/measured-budget-runtime.py` and `bubbles/scripts/measured-budget-broker-finalize.py` for permit, event-chain, reservation, usage, and settlement semantics;
- `bubbles/scripts/phase-coordinator.sh` for broker routing and direct mutable execution;
- `bubbles/scripts/security-authority.py` for provider-free HMAC authority and hardened authority-file handling;
- `bubbles/scripts/goal-boundary-receipt.sh` for unchanged `goal-boundary-receipt/v1` behavior;
- `agents/bubbles_shared/project-config-contract.md` for `dispatchAdmission.adapter`;
- `bubbles/workflows.yaml` for the done-capable `implement action:full-delivery target:spec` mode;
- `improvements/IMP-057-native-host-budget-interception.md` for independently tracked native host interception.

The inspection establishes design constraints and current source behavior. It does not claim that later scopes are implemented or that an immutable launch primitive has passed a capability probe.

## Non-Goals

- Runtime, schema, gate, generated artifact, release inventory, agent, or test implementation in SCOPE-1.
- Changing `goal-boundary-receipt/v1`.
- Replacing repository binding, G134, IMP-055 permits, the event ledger, or settlement with parallel systems.
- Authorizing cross-repository mutation from a source session after a route decision.
- Native VS Code, MCP, ambient shell, or host-wide interception; IMP-057 owns those surfaces.
- Treating IMP-056 `done` as evidence that IMP-057 or native interception is complete.
- Claiming literal atomicity across filesystem records, permit consumption, and process creation.
- Promising a native activation date.
- Treating Chronicle attribution, current working directory, active editor, workspace order, ownership metadata, or result-envelope claims as authority.
