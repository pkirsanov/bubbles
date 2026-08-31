# IMP-055 - Design 2: Measured Budget and Session Epoch Runtime

**Status:** PROPOSED (not yet applied) - awaiting owner review.
**Surface:** framework-health (G125) - human-reviewed. NO auto-mutation of bubbles/* until approved.
**Motivation:** A current-session source review found measured usage, session caps, risk resolution, model floors, tool-grant advice, compaction, and phase occurrence primitives. It also found that no host-enforced admission plane composes them before paid dispatch.
**Verified gaps addressed:**

- `COST-12` - configured spend is not admitted before dispatch.
- `HO-6` - native dispatch bypasses the executable phase coordinator.
- `EV-16` - usage has no exact-session versioned receipt contract.
- `REG-20` - risk, model, grant, budget, and epoch decisions have no single executable policy path.

## Design Brief

### Current State

Bubbles defaults to `full-delivery` and preserves maximum assurance for unknown work. The risk resolver can select `rapid-tool-delivery` only from positive low-risk signals.

The four top-level runners still invoke `runSubagent` directly. Their broad tool grants let the model dispatch without an external budget permit.

G128 checks recorded session totals after activity. It skips a configured dimension when that dimension cannot be measured.

The VS Code usage adapter expects one host-owned field shape. It reports `measured:false` when current artifacts carry no `promptTokens` field.

State snapshots bind turns to a host session ID. A caller may still declare `fresh-context` without a host checkpoint or new-session proof.

### Target State

Add one deterministic admission plane before every controlled model, subagent, web, browser, and tool dispatch. The host must enforce each one-time permit.

Bind all reservations, debits, releases, retries, and epochs to one exact goal budget. Preserve immutable usage and admission receipts across session rollover.

Resolve implicit delivery mode through the existing risk resolver. High and unknown risk continue to select `full-delivery` and keep every current gate.

Use abstract model classes and explicit per-agent tool grants. Do not require a provider or model name as a framework default.

### Patterns to Follow

- Follow fail-closed risk classification in [`risk-tier-resolve.sh`](../bubbles/scripts/risk-tier-resolve.sh).
- Follow ordered occurrence identity in [`phase-coordinator.sh`](../bubbles/scripts/phase-coordinator.sh).
- Follow exact host-session attribution in [`state-snapshot.sh`](../bubbles/scripts/state-snapshot.sh).
- Follow measured-versus-unmeasured truth in [`adapters/usage/none.sh`](../bubbles/adapters/usage/none.sh).
- Follow configured-adapter failure behavior in [`usage-resolve.sh`](../bubbles/scripts/usage-resolve.sh).
- Follow earned packet identity and failure-class separation in [`dispatch-receipt.sh`](../bubbles/scripts/dispatch-receipt.sh).
- Follow pre-execution denial in [`pre-tool-risk-gate.sh`](../bubbles/scripts/pre-tool-risk-gate.sh).
- Follow immutable, occurrence-aware phase state from [`workflow-phase-engine.md`](../agents/bubbles_shared/workflow-phase-engine.md).
- Follow deterministic mode composition in [`mode-resolver.sh`](../bubbles/scripts/mode-resolver.sh).

### Patterns to Avoid

- Do not extend G128 into another post-dispatch counter. A hard cap must decide before the paid action starts.
- Do not trust a model-authored budget, checkpoint, receipt, tool grant, or risk classification.
- Do not infer tokens from bytes, text length, event counts, or model context limits.
- Do not treat an unconfigured or unsupported dimension as zero, free, or within budget.
- Do not place provider selection inside workflow policy.
- Do not lower gates to reduce cost. Relevance may remove irrelevant work, never assurance.
- Do not call a declared `fresh-context` value proof of rollover.
- Do not add recursive fallback providers or recursive escalation loops.

### Resolved Decisions

- `phase-coordinator.sh` becomes the deterministic policy owner for controlled phase dispatch.
- A host dispatch broker enforces permits because a repository script cannot intercept native model dispatch alone.
- Direct `agent` dispatch leaves enforced runner grants after the broker proves parity.
- Every configured budget dimension must be measurable and reservable before dispatch.
- Every unconfigured dimension remains `unmeasured` for admission.
- One goal budget spans retries, child sessions, and all four session epochs.
- Planning, implementation, verification, and certification use verified epoch boundaries.
- A boundary requires a host checkpoint receipt or a new exact host session identity.
- Explicit modes retain their existing mode contracts and ceilings.
- Implicit delivery uses deterministic risk resolution.
- Unknown and high risk select `full-delivery`.
- Abstract model classes set capability floors without naming providers.
- Tool grants become explicit for every agent.
- Transport retries and product defects use different outcomes and counters.
- Migration starts with shadow telemetry and ends with canary-proven default enforcement.
- Rollback restores the prior signed policy bundle and never deletes receipts.
- No cost reduction percentage is claimed by this proposal.

### Open Questions

- The owner must choose the host integration that can intercept root and subagent model dispatch.
- The owner must approve cap values after the frozen-corpus report exposes distributions and measurement coverage.
- The owner must approve the first model-class capability map for each enabled host adapter.

These decisions block enforcement activation. They do not block review of the provider-neutral contracts.

## Provenance

### Repository Sources Inspected In This Run

| Source inspected | Verified observation used by this proposal |
| --- | --- |
| [`bubbles/workflows.yaml`](../bubbles/workflows.yaml) | Declares `defaultMode: full-delivery`, model floors, retry policy, session-budget fields, and the caller-declared context boundary shape. |
| [`bubbles/workflows/modes.yaml`](../bubbles/workflows/modes.yaml) | Declares phase order and mode budgets. Its own comments state that no script copies mode budgets into session state. |
| [`bubbles/scripts/session-cap-guard.sh`](../bubbles/scripts/session-cap-guard.sh) | Reads recorded aggregates after activity. It skips configured token caps when the usage adapter cannot measure them. |
| [`bubbles/adapters/usage/vscode-copilot.sh`](../bubbles/adapters/usage/vscode-copilot.sh) | Searches host-owned chat artifacts, accepts a prefix session filter, and recognizes records through `promptTokens`. |
| [`bubbles/adapters/usage/none.sh`](../bubbles/adapters/usage/none.sh) | Preserves absent measurement as `measured:false` and emits no token or credit value. |
| [`bubbles/scripts/usage-resolve.sh`](../bubbles/scripts/usage-resolve.sh) | Resolves `none` when usage is absent and fails loud when a configured adapter is invalid. |
| [`bubbles/scripts/usage-adapter-contract-selftest.sh`](../bubbles/scripts/usage-adapter-contract-selftest.sh) | Tests neutral shapes and one documented host schema. Schema drift becomes unmeasured. |
| [`bubbles/scripts/phase-coordinator.sh`](../bubbles/scripts/phase-coordinator.sh) | Owns positional occurrence identity, relevance consumption, no replay, and cursor state. It executes supplied shell commands without budget admission. |
| [`agents/bubbles_shared/workflow-phase-engine.md`](../agents/bubbles_shared/workflow-phase-engine.md) | Requires direct `runSubagent` dispatch and assigns positional occurrence IDs through the coordinator. |
| [`bubbles/scripts/risk-tier-resolve.sh`](../bubbles/scripts/risk-tier-resolve.sh) | Selects rapid delivery only with a positive low-risk signal and no high-risk trigger. Unknown work selects full delivery. |
| [`bubbles/scripts/assurance-resolve.sh`](../bubbles/scripts/assurance-resolve.sh) | Forces high or unknown risk to a full assurance floor for deployment eligibility. |
| [`bubbles/scripts/context-compactor.sh`](../bubbles/scripts/context-compactor.sh) | Persists compact records with repository binding, but does not prove that the host created a fresh model context. |
| [`bubbles/scripts/compaction-discipline-guard.sh`](../bubbles/scripts/compaction-discipline-guard.sh) | Requires an ID only for `host-checkpoint`. It accepts caller-declared `fresh-context` with a timestamp. |
| [`bubbles/scripts/state-snapshot.sh`](../bubbles/scripts/state-snapshot.sh) | Appends host-session-attributed turn snapshots and convergence counts. It does not seed budgets or increment `toolCallCount`. |
| [`bubbles/scripts/model-tier-advisory.sh`](../bubbles/scripts/model-tier-advisory.sh) | Resolves phase floors from workflow policy. Unknown model identifiers are treated as `sonnet-class`, and absent model identity does not block. |
| [`bubbles/registry/tool-grants.yaml`](../bubbles/registry/tool-grants.yaml) | Restricts only `web` and `playwright`. It explicitly leaves `agent`, `edit`, and `execute` unrestricted. |
| [`bubbles/scripts/tool-grant-lint.sh`](../bubbles/scripts/tool-grant-lint.sh) | Checks only restricted families and remains advisory unless `--strict` is selected. |
| [`bubbles/action-risk-registry.yaml`](../bubbles/action-risk-registry.yaml) | Classifies Bubbles CLI commands by action risk. It does not classify paid model dispatch. |
| [`bubbles/scripts/pre-tool-risk-gate.sh`](../bubbles/scripts/pre-tool-risk-gate.sh) | Blocks known sensitive tool actions before execution. Its source states that ambient or host-unrouted tools are not interceptable. |
| [`bubbles/scripts/dispatch-receipt.sh`](../bubbles/scripts/dispatch-receipt.sh) | Separates transport, envelope, defect, timeout, and repeated-infrastructure outcomes. The adapter is default-off. |
| [`bubbles/scripts/phase-relevance-resolve.sh`](../bubbles/scripts/phase-relevance-resolve.sh) | Resolves missing or unknown relevance evidence to `run`, never to a silent skip. |
| [`bubbles/scripts/mode-resolver.sh`](../bubbles/scripts/mode-resolver.sh) | Composes workflow and mode registries while preserving ordered phase multiplicity. |
| [`bubbles/agent-capabilities.yaml`](../bubbles/agent-capabilities.yaml) | Registers workflow-mode grants and phase ownership. It does not define tool or model requirements per agent. |
| [`agents/bubbles.goal.agent.md`](../agents/bubbles.goal.agent.md) | Grants nine tool families and directs the model to call `runSubagent`. Its mode-budget seeding rule is prose. |
| [`agents/bubbles.workflow.agent.md`](../agents/bubbles.workflow.agent.md) | Grants seven tool families and directs the model to call `runSubagent` for each phase. |
| [`agents/bubbles.sprint.agent.md`](../agents/bubbles.sprint.agent.md) | Grants nine tool families and describes session-budget enforcement as runner behavior. |
| [`agents/bubbles.iterate.agent.md`](../agents/bubbles.iterate.agent.md) | Grants nine tool families, selects work and mode in-model, and dispatches phase owners directly. |
| [`agents/bubbles.super.agent.md`](../agents/bubbles.super.agent.md) | Uses model judgment for natural-language mode selection. It invokes the risk resolver only for the recognized rapid-tool route. |
| [`bubbles/hooks.json`](../bubbles/hooks.json) | Registers one pre-tool risk hook. It declares no pre-model or pre-subagent cost hook. |
| [`bubbles/scripts/runtime-leases.sh`](../bubbles/scripts/runtime-leases.sh) | Coordinates host resource weight and reuse. It does not reserve provider usage or goal spend. |

The source scan found no top-level runner invocation of `phase-coordinator.sh`. References occur in shared contracts, state snapshots, receipts, registries, and selftests.

### Current-Session Adapter Check

This run executed the shipped VS Code usage adapter against current `workspaceStorage`.

- `status` exited 0 with `measured:false`.
- The reason was `artifact found but carries no promptTokens field`.
- `capabilities` exited 0 with checkpoint and retained-byte measurement marked unsupported.

This check confirms adapter behavior. It does not validate the host's private usage totals.

### Operator And Session-Store Diagnostic Input

The following values were supplied by the operator in this request. They are diagnostic measurements, not Bubbles repository execution evidence.

| Diagnostic | Operator-supplied value |
| --- | ---: |
| VS Code Chat sessions in 30 days | 125 |
| Input tokens | 58.4 billion |
| Output tokens | 193 million |
| Usage events | 194,296 |
| Approximate input tokens per event | 300,000 |
| Host checkpoints | 0 across all 125 sessions |
| Largest session input tokens | 7.10 billion |
| Largest session usage events | 22,851 |

These measurements motivate the proposal. They do not prove that this design reduces cost.

## Problem (verified against source)

- **COST-12 - Enforcement happens after spend:** G128 reads cumulative values after activity. It cannot prevent the next paid request from starting.
- **COST-12 - Configured unmeasurable caps pass:** G128 skips a configured token dimension when the selected usage adapter returns no measurement.
- **HO-6 - The executable coordinator is not the dispatch choke point:** Runner agents call the native subagent tool directly.
- **HO-6 - Budget seeding is not one executable rule:** Mode defaults exist, but current source gives the copy responsibility to runner prose.
- **EV-16 - Usage identity is not exact enough for enforcement:** The VS Code adapter accepts a filename prefix and can aggregate every discovered chat artifact.
- **EV-16 - The adapter contract uses one host field shape:** A host schema change produces `unmeasured`. That result cannot enforce a configured cap.
- **EV-16 - Usage and admission are separate after-the-fact records:** No immutable chain binds a quote, permit, host dispatch, provider receipt, debit, and release.
- **REG-20 - Risk, relevance, model, grant, budget, and epoch checks have different consumers:** No deterministic decision composes all six before dispatch.
- **REG-20 - Tool grants are partial and advisory:** Most families remain unrestricted, and only top-level runners currently declare explicit lists.
- **REG-20 - Model floors do not require a verified model identity:** An absent model identity passes, and an unknown identifier is assigned a capability class.
- **HO-6 - `fresh-context` is declarative:** Current state accepts the value without a host-created checkpoint or new-session proof.
- **COST-12 - Retries have no shared spend ledger:** Dispatch receipts separate failure classes, but they do not reserve from one goal-wide resource budget.

## Proposal

### SCOPE-1 - Admission and budget capability foundation (COST-12, HO-6)

- Define canonical budget, dispatch intent, reservation, permit, usage receipt, and epoch records.
- Extend the phase coordinator with a pure `admit` decision before any controlled dispatch.
- Keep policy resolution deterministic and provider-neutral.
- Require a host broker to validate the permit and perform the dispatch.
- Preserve the current workflow when the capability is absent during shadow migration.

### SCOPE-2 - Exact-session usage adapter v2 and immutable accounting (EV-16, COST-12)

- Add version negotiation and exact-session identity to the usage adapter contract.
- Add host-schema profiles instead of recursive field-name guesses.
- Require configured dimensions to support pre-dispatch bounds and post-dispatch receipts.
- Add atomic reserve, debit, release, and unresolved-reservation transitions.
- Keep v1 adapters readable for telemetry and ineligible for enforced token or money caps.

### SCOPE-3 - Risk, mode, model, and tool admission (REG-20, HO-6)

- Compose risk, relevance, budget, model class, tool grant, and epoch checks into one decision.
- Preserve every explicit mode and its current gate set.
- Route implicit implementation-capable work through deterministic risk resolution.
- Select full delivery for high or unknown risk.
- Replace broad runner grants with an enforced broker grant after canary proof.
- Select abstract model classes by phase and risk elevation.

### SCOPE-4 - Verified session epochs and bounded retries (HO-6, EV-16)

- Define planning, implementation, verification, and certification epochs.
- Require a host checkpoint receipt or a new exact host session at each epoch boundary.
- Carry one goal budget across every epoch and child session.
- Keep transport retries inside one logical occurrence.
- Route defects through planned remediation instead of automatic request replay.
- Forbid recursive escalation and alternate-provider retry.

### SCOPE-5 - Shadow, canary, default activation, and rollback (COST-12, REG-20)

- Capture shadow decisions without changing dispatch.
- Compare advisory decisions with current dispatch and gate outcomes.
- Enforce one canary cohort only after exact measurement and host interception pass.
- Activate the broker by default only after acceptance metrics pass.
- Roll back by selecting the prior signed policy bundle or prior framework release.
- Preserve all historical receipts during rollback.

### SCOPE-6 - Frozen-corpus evaluation and publication controls (COST-12, EV-16)

- Freeze a privacy-safe historical corpus manifest from exact-session usage records.
- Separate counterfactual admission savings from live causal measurements.
- Pair each cost report with quality, security, and assurance non-regression results.
- Publish a reduction percentage only from measured matched runs.
- Record measurement coverage and exclusions beside every result.

## Shared Framework Consumption Boundary

One product-neutral execution framework lives in a separate repository. Its design is at `execution-ledger/docs/DESIGN.md`. That framework owns the semantics, identity, and truth states this proposal shares with other consumers.

The framework sits outside this repository on purpose. Three separate designs each re-specified the same capability. A foundation hosted inside any one consumer would make that consumer the hidden owner of the others.

On approval this proposal consumes rather than defines the shared budget, reservation, budget-event, usage-adapter, usage-receipt, occurrence, route-capability, route-decision, frozen-corpus, and shadow-evaluation contracts. The closed dimension set, the reserve and debit and release lifecycle, and the four measurement states come from that framework.

This proposal keeps its own domain ownership. Host dispatch admission, the one-time permit boundary, and verified session epochs stay here. Rollover proof, risk resolution, abstract model classes, per-agent tool grants, and the four runner integration surfaces also stay here.

On approval the duplicated definitions named in the framework consumer binding table are replaced by references to that framework. No consumer is bound today. Until both owners approve, the text in this file stays authoritative and this file remains readable on its own.

## Capability Foundation

### Foundation Contract

| Contract | Responsibility | Consumers |
| --- | --- | --- |
| `AdmissionCoordinator` | Composes risk, relevance, budget, model, grant, epoch, and binding facts into one decision. | Phase coordinator and host dispatch broker. |
| `DispatchBrokerAdapter` | Enforces one-time permits and performs controlled host dispatch. | Root host integration and orchestrator dispatch. |
| `UsageAdapterV2` | Resolves exact host sessions, quotes bounded usage, and verifies immutable provider or host receipts. | Budget ledger and evaluation runner. |
| `GoalBudgetLedger` | Owns configured dimensions, reservations, debits, releases, and reconciliation. | Every controlled dispatch. |
| `SessionEpochAuthority` | Opens and closes verified planning, implementation, verification, and certification epochs. | Phase coordinator and state snapshot. |
| `RiskDecisionResolver` | Produces the assurance floor and implicit delivery mode from current evidence. | Admission coordinator and deployment assurance. |
| `ModelClassResolver` | Maps a phase and risk floor to an abstract model class. | Admission coordinator. |
| `ToolGrantResolver` | Resolves one exact per-agent grant plus a dispatch-scoped overlay. | Host broker and pre-tool hook. |
| `AdmissionReceiptStore` | Appends immutable decisions, permits, receipts, and corrections. | Validation, audit, telemetry, and replay. |
| `CostCorpusEvaluator` | Measures candidate behavior against a frozen historical manifest and matched canary runs. | Framework health review. |

### Extension Points

- A usage adapter implements `describe`, `identify-session`, `quote`, `snapshot`, `receipt`, and `verify-receipt`.
- A dispatch broker implements `capabilities`, `reserve-bind`, `dispatch`, `cancel`, `checkpoint`, and `verify-boundary`.
- A model-class adapter maps host model IDs to capability classes through signed host configuration.
- A policy bundle defines budget dimensions, phase classes, risk rules, grant rows, and rollout cohort.
- A receipt store implements append, read-by-identity, compare-and-append, and immutable snapshot seal.
- A corpus adapter emits sanitized event records and an immutable corpus manifest.

### Foundation-Owned Behavior

- Validate repository binding and exact host-session identity before admission.
- Resolve explicit mode intent before any implicit routing rule.
- Resolve implicit delivery through the risk resolver.
- Preserve high and unknown risk at full assurance.
- Resolve phase relevance without removing `neverSkip` phases.
- Resolve one model class and one tool grant for the target agent and phase.
- Verify every configured dimension is measurable and reservable.
- Reserve all applicable dimensions atomically before issuing a permit.
- Bind each permit to one goal, epoch, occurrence, attempt, agent, phase, and action digest.
- Let only the host broker consume the permit.
- Reconcile actual usage into immutable debit and release events.
- Hold unresolved reservations when the provider may still charge.
- Require host proof for epoch rollover.
- Preserve all gates, receipts, and unmeasured states.

### Variation Axes

| Axis | Options | Foundation ownership |
| --- | --- | --- |
| Host integration | Native host extension, MCP-backed broker, local broker daemon | Foundation owns permits. Adapter owns host invocation. |
| Usage source | Host-native event stream, provider receipt API, local measured ledger | Foundation owns normalized fields and truth states. |
| Model class | No model, economy reasoning, standard reasoning, high-assurance reasoning | Foundation owns class semantics. Host policy owns concrete mappings. |
| Session boundary | Host checkpoint, new exact host session | Foundation owns proof requirements. Host adapter owns mechanics. |
| Receipt store | Host-private append log, local content-addressed ledger, immutable service | Foundation owns identity and lifecycle. Adapter owns storage. |
| Tool surface | Local read, owned edit, local execute, web, browser, subagent dispatch | Foundation owns grant resolution and cap charging. |
| Rollout posture | Shadow, advisory, canary-enforced, default-enforced | Foundation owns state transitions and acceptance gates. |
| Cost dimension | Count, tokens, bytes, time, credits, currency minor units | Foundation owns units and independent caps. Adapter owns measurement. |

## Architecture And Trust Boundary

The model may request an action. It never authorizes or performs a controlled dispatch directly.

```text
operator request
  -> host root-admission hook
  -> repository binding
  -> mode and risk resolution
  -> phase coordinator
  -> admission coordinator
       -> relevance resolver
       -> model-class resolver
       -> tool-grant resolver
       -> usage adapter quote
       -> goal budget reservation
       -> epoch authority
  -> host-private one-time permit
  -> dispatch broker
  -> model, subagent, web, browser, or tool action
  -> host or provider usage receipt
  -> debit and release
  -> immutable admission receipt
```

The host broker is a hard boundary. A shell script can calculate policy, but it cannot prove that a native host dispatch used that policy.

An enforcement-capable host removes direct controlled tools from the model grant. The model receives only the broker tool for those actions.

If the host cannot intercept an action family, enforced policy cannot grant that family. Shadow mode may observe it without claiming enforcement.

The first root model request requires a host pre-model hook. Repository code cannot retroactively admit a request that already started.

## Canonical Serialization And Identity

All records use UTF-8 JSON with sorted object keys and LF line endings. Integers represent counts, bytes, tokens, milliseconds, credits, and money.

Money records include ISO currency and minor-unit scale. Values in different currencies never share one counter.

Set-valued arrays sort by canonical member identity. Ordered phase and attempt arrays preserve order and multiplicity.

Each record has a type prefix and SHA-256 digest. Secrets, prompt text, result text, transient paths, and process IDs never enter public identity material.

Host-private records may contain opaque provider request IDs. Telemetry exposes only salted correlation digests.

## Core Record Contracts

| Record | Required fields | Lifecycle | Canonical identity |
| --- | --- | --- | --- |
| `HostSessionIdentity` | `contractVersion`, `adapterId`, `hostInstanceId`, `workspaceIdentity`, `hostSessionId`, `artifactSessionId`, `repositoryDecisionId`, `hostSchemaId`, `proofDigest`, `startedAt` | Immutable. A new host session creates a new identity. | `hsi:sha256(adapterId, hostInstanceId, workspaceIdentity, hostSessionId, artifactSessionId, proofDigest)` |
| `GoalBudgetPolicy` | `budgetId`, `goalId`, `policyDigest`, `dimensions`, `openedAt`, `rolloutPosture` | `declared -> active -> exhausted \| closed \| superseded`. | `gbp:sha256(goalId, policyDigest, canonical dimensions)` |
| `DispatchIntent` | `intentId`, `goalId`, `epochId`, `occurrenceId`, `attemptId`, `agent`, `phase`, `actionClass`, `inputDigest`, `requestedModelClass`, `requestedToolFamily` | Immutable after creation. | `din:sha256(goalId, epochId, occurrenceId, attemptId, inputDigest, actionClass)` |
| `AdmissionDecision` | `decisionId`, `intentId`, `riskDecisionId`, `relevanceDecisionId`, `modelDecisionId`, `grantDecisionId`, `budgetSnapshotId`, `epochBoundaryId`, `verdict`, `reasonCode` | `evaluated -> allowed \| refused`. | `adm:sha256(intentId, all referenced decision ids, verdict, reasonCode)` |
| `BudgetReservation` | `reservationId`, `budgetId`, `intentId`, `quotedMaximums`, `quoteDigest`, `expiresAt`, `state` | `reserved -> consumed \| released \| unresolved \| expired`. | `res:sha256(budgetId, intentId, quoteDigest, quotedMaximums)` |
| `DispatchPermit` | `permitId`, `reservationId`, `decisionId`, `hostSessionIdentityId`, `actionDigest`, `nonce`, `expiresAt`, `consumedAt` | `issued -> consumed \| expired \| revoked`. One consumption only. | Host-private identity plus public digest. |
| `UsageReceipt` | `usageReceiptId`, `intentId`, `permitId`, `adapterId`, `adapterContractVersion`, `hostSchemaId`, `measurement`, `providerReceiptDigest`, `startedAt`, `finishedAt` | `measured \| partially-measured \| unmeasured \| invalid \| superseded`. | `usr:sha256(intentId, permitId, adapter identity, providerReceiptDigest, normalized measurement)` |
| `BudgetEvent` | `eventId`, `budgetId`, `reservationId`, `eventType`, `amounts`, `usageReceiptId`, `at`, `predecessorDigest` | Append-only `OPEN`, `RESERVE`, `DEBIT`, `RELEASE`, `HOLD`, `CORRECT`, `CLOSE`. | `bev:sha256(previous digest, canonical event)` |
| `SessionEpoch` | `epochId`, `goalId`, `epochClass`, `sequence`, `hostSessionIdentityId`, `openedByBoundaryId`, `state`, `openedAt`, `closedAt` | `prepared -> active -> closed \| refused`. | `sep:sha256(goalId, epochClass, sequence, hostSessionIdentityId, openedByBoundaryId)` |
| `EpochBoundaryReceipt` | `boundaryId`, `fromEpochId`, `toEpochClass`, `boundaryKind`, `hostProof`, `continuationDigest`, `budgetSnapshotId`, `verifiedAt` | `observed -> verified \| refused`. | `ebr:sha256(fromEpochId, toEpochClass, boundaryKind, hostProof digest, continuationDigest)` |
| `PolicyBundle` | `bundleId`, `schemaVersions`, `riskPolicyDigest`, `modelClassDigest`, `toolGrantDigest`, `budgetProfileDigest`, `rolloutPosture` | Immutable and signed. A new policy creates a new bundle. | `pbu:sha256(canonical bundle without bundleId)` |

Corrections append a new record that names the superseded identity. No process rewrites a prior receipt or budget event.

## Usage Adapter Contract Version 2

### Negotiation

The consumer requests an exact major contract version. The adapter returns its supported versions and capabilities before any usage read.

Version 1 remains telemetry-compatible. It cannot satisfy enforced token, credit, money, checkpoint, or exact-session requirements.

Unknown major versions refuse. The resolver does not silently select an older contract for enforcement.

### Verbs

| Verb | Input | Output | Enforcement requirement |
| --- | --- | --- | --- |
| `describe` | Contract major | Adapter identity, versions, host schema IDs, dimensions, quote support, receipt support | Must succeed before configuration admission. |
| `identify-session` | Repository decision, host session ID, workspace identity | Exactly one `HostSessionIdentity` or a typed refusal | Prefix and unscoped matches cannot enforce. |
| `quote` | Exact session, dispatch intent, output limit, cache policy | Per-dimension worst-case reservation and quote expiry | Required for every configured paid dimension. |
| `snapshot` | Exact session, monotonic cursor | Cumulative measured values and a new cursor | Cursor must never move backward. |
| `receipt` | Exact session, permit, provider request correlation | One normalized `UsageReceipt` | Required after every controlled dispatch. |
| `verify-receipt` | Receipt and source proof | Valid, invalid, unresolved, or unsupported | Required before debit finalization. |

### Capability Shape

Each dimension declares one of `native`, `trusted-derived`, `bounded-only`, or `unsupported`.

It also declares whether pre-dispatch bounds and post-dispatch actuals are available. A post-dispatch total alone cannot enforce a hard cap.

An adapter reports `sessionIdentity: exact`, `prefix`, or `unscoped`. Only `exact` qualifies for enforcement.

An adapter reports `hostSchemaId` and `mappingDigest`. Unknown host schema bytes produce `MBE-HOST-SCHEMA-UNSUPPORTED`.

### Host Schema Evolution

- Keep one explicit mapping profile per supported host schema ID.
- Match a profile from a host-owned schema marker or structural fingerprint.
- Reject ambiguous profile matches.
- Never search recursively for plausible token fields in enforced mode.
- Test field renames, type changes, null values, duplicate event IDs, and unit changes.
- Preserve raw source digests in the private receipt store.
- Expose no prompt, completion, source text, or private path in telemetry.

## Exact Session Identity

The repository-binding session ID and host usage artifact ID are related, but they are not interchangeable.

`identify-session` must bind both through host proof. A filename prefix, timestamp overlap, active editor, process ID, or workspace order is insufficient.

The identity proof must include one host instance, one workspace identity, one host session ID, one artifact session ID, and one schema profile.

Two artifacts matching one filter produce `MBE-SESSION-IDENTITY-AMBIGUOUS`. No aggregate is returned.

Session rollover creates a new `HostSessionIdentity`. The goal and budget identities remain unchanged.

## Goal Budget Contract

Every dimension has an explicit `configured` or `unconfigured` state. A configured row requires a non-negative integer limit and a verified measurement capability.

An unconfigured row has no limit and remains `unmeasured` for admission. It never receives an implicit zero or within-budget verdict.

### Independent Hard Caps

| Dimension | Unit | Pre-dispatch reservation | Post-dispatch debit |
| --- | --- | --- | --- |
| `modelRequestCount` | requests | Reserve one request occurrence. | Debit one consumed permit. |
| `inputTokens` | tokens | Reserve adapter-counted input tokens for exact request bytes. | Debit verified provider or host input tokens. |
| `outputTokens` | tokens | Reserve the declared maximum output tokens. | Debit verified output tokens and release unused tokens. |
| `cacheWriteTokens` | tokens | Reserve the adapter's maximum cache write for the request. | Debit verified cache write tokens. |
| `cacheReadTokens` | tokens | Reserve the adapter's maximum cache read for the request. | Debit verified cache read tokens. |
| `providerCredits` | provider minor units | Reserve a quote bound to adapter and price policy. | Debit verified native credits. |
| `monetaryMinorUnits` | currency minor units | Reserve by currency, price digest, and quote expiry. | Debit verified cost in the same currency and scale. |
| `subagentDispatches` | dispatches | Reserve one child dispatch. | Debit one consumed child permit. |
| `webCalls` | calls | Reserve one web operation and declared redirect allowance. | Debit actual host-observed operations. |
| `browserCalls` | calls | Reserve one browser action. | Debit each host-observed browser action. |
| `toolCalls` | calls | Reserve one tool invocation. | Debit one consumed tool permit. |
| `retainedResultBytes` | bytes | Reserve the maximum bounded projection entering model context. | Debit retained projection bytes and release unused bytes. |
| `wallTimeMs` | milliseconds | Verify the action deadline fits the remaining goal deadline. | Debit monotonic elapsed time. Time is never released. |
| `retries` | attempts | Reserve one eligible retry attempt. | Debit when the retry permit is consumed. |
| `concurrency` | active permits | Acquire one goal-local concurrency lease. | Release only after terminal receipt or verified cancellation. |

Each dimension is independent. Remaining money cannot authorize extra tokens, and remaining tool calls cannot authorize extra subagents.

Provider credits and money use separate counters. A provider credit is not a currency conversion.

Web redirects and browser sub-operations use adapter-declared accounting rules. The rule digest enters the quote.

Full raw tool output remains available through immutable evidence storage. Only the bounded projection counts as retained model-context bytes.

## Reserve, Debit, Release, And Reconciliation

### Atomic Reservation

The ledger evaluates every configured dimension against the same snapshot. It appends either all reservations or one refusal.

No partial reservation may survive a failed multi-dimension decision.

The reservation uses exact known counts or a trusted worst-case bound. A byte heuristic cannot substitute for a token bound.

### Permit Consumption

The host broker compares the permit's action digest with the exact dispatch. It consumes the permit before starting the action.

A consumed permit cannot be replayed. An expired or mismatched permit refuses without dispatch.

### Final Accounting

- Verified actual usage creates `DEBIT` events.
- Unused reserved amounts create `RELEASE` events.
- A confirmed no-dispatch outcome releases the full reservation.
- An unknown provider outcome creates `HOLD` and keeps the maximum reservation.
- A later provider receipt appends debit and release events against that hold.
- An erroneous receipt appends `CORRECT` and names the superseded receipt.
- Negative aggregate usage is invalid and blocks reconciliation.

## Deterministic Admission Algorithm

For every controlled action, the coordinator performs these steps in order:

1. Validate repository binding and exact host-session identity.
2. Resolve the current goal, epoch, phase occurrence, and attempt identity.
3. Resolve explicit mode or run the implicit-mode algorithm.
4. Resolve risk from current request, planned surfaces, and changed paths.
5. Resolve phase relevance. `neverSkip`, missing evidence, and unknown rules resolve to `run`.
6. Resolve the phase model class and risk elevation.
7. Resolve the exact agent tool grant and action-scoped overlay.
8. Verify the active epoch permits this phase and action class.
9. Negotiate usage and dispatch adapter capabilities.
10. Quote every configured dimension.
11. Refuse when any configured dimension is unsupported or ambiguous.
12. Reserve every dimension atomically.
13. Append the admission decision and issue one host-private permit.
14. Let the host broker consume the permit and perform the dispatch.
15. Obtain and verify the terminal usage receipt.
16. Append debit, release, or hold events.
17. Advance the occurrence only when dispatch and result receipts both permit advancement.

The model receives the verdict and reason. It cannot modify the decision inputs or issue its own permit.

## Implicit Mode And Risk Resolution

Explicit mode input remains authoritative within its current permission and ceiling rules. Admission still validates risk and minimum assurance.

Without an explicit mode, resolve in this order:

1. Recover one valid continuation mode when current session state proves a non-terminal continuation.
2. Preserve planning-only intent and its below-`done` ceiling.
3. Preserve an exact registered non-delivery intent route.
4. Classify implementation-capable or unresolved work with `risk-tier-resolve.sh`.
5. Select `rapid-tool-delivery` only for its positive low-risk eligibility result.
6. Select `full-delivery` for high or unknown risk.

Re-run risk resolution after planning and before certification. A higher risk result only raises assurance.

A lower later result cannot remove phases, gates, evidence, or model floors already owed by the active run.

An explicit rapid mode that resolves high or unknown risk is refused or elevated to full delivery. It never sheds controls.

## Model Class Contract

Model classes express capabilities, not brands. A host adapter maps a concrete model ID to one class through explicit signed configuration.

| Model class | Required capability | Intended use |
| --- | --- | --- |
| `none` | Deterministic host execution only | Admission, hashing, receipts, schema checks, gates, and ledger operations. |
| `economy-reasoning` | Structured output, bounded context, basic tool planning | Status, recap, simple docs, and deterministic-result explanation. |
| `standard-reasoning` | Cross-file reasoning, reliable structured output, tool use | Routine planning, implementation, test triage, and review. |
| `high-assurance-reasoning` | Long-context synthesis, adversarial reasoning, strict contract following | Security, certification, audit, hardening, design, and elevated-risk work. |

Unknown model identity is `unverified`. It is not assigned a class by name similarity.

No provider or concrete model is the default. Missing class mapping produces `MBE-MODEL-CLASS-UNAVAILABLE` before paid child dispatch.

### Phase Model Selection

| Phase | Base class | Elevation rule |
| --- | --- | --- |
| `discover`, `select` | `standard-reasoning` | High or unknown risk selects `high-assurance-reasoning`. |
| `analyze`, `bootstrap`, `bug`, `retro`, `releases`, `journey` | `standard-reasoning` | Material or high-risk work selects `high-assurance-reasoning`. |
| `interrogate`, `design`, `harden`, `stabilize` | `high-assurance-reasoning` | No downgrade. |
| `implement`, `test`, `regression`, `simplify`, `gaps` | `standard-reasoning` | High or unknown risk selects `high-assurance-reasoning`. |
| `devops`, `security`, `validate`, `audit`, `chaos`, `redteam` | `high-assurance-reasoning` | No downgrade. |
| `spec-review`, `code-review`, `system-review` | `high-assurance-reasoning` | No downgrade. |
| `docs`, `finalize` | `economy-reasoning` | Material claims or certification conflicts select `standard-reasoning`. |
| Admission, receipt, epoch, and gate execution | `none` | Models cannot perform these decisions. |

Unknown phase names resolve to full assurance and `high-assurance-reasoning`.

## Explicit Tool Grant Contract

### Grant Profiles

| Profile | Exact families | Purpose |
| --- | --- | --- |
| `runner-control` | `read, search, todo, bubbles-admission` | Select and dispatch through the broker. No direct native `agent`, `web`, `playwright`, `edit`, or `execute`. |
| `planning-local` | `read, search, edit, todo, execute, bubbles` | Author owned planning artifacts and run focused checks. |
| `planning-research` | `read, search, edit, todo, web, execute, bubbles` | Planning that requires external source retrieval. |
| `execution-owner` | `read, search, edit, todo, execute, bubbles` | Modify owned implementation, tests, docs, or operational surfaces. |
| `diagnostic-local` | `read, search, todo, execute, bubbles` | Inspect and execute checks without foreign writes. |
| `diagnostic-browser` | `read, search, todo, execute, bubbles, playwright` | Run approved browser scenarios. |
| `utility-read` | `read, search, todo, bubbles` | Read-only status, command discovery, recap, and handoff. |
| `utility-write` | `read, search, edit, todo, execute, bubbles` | Write one owned utility artifact. |
| `domain-control` | `read, search, edit, todo, execute, bubbles-admission` | Run a registered domain mode and route controlled child work. |

`bubbles-admission` is a planned host-broker family. It replaces direct subagent dispatch only after host enforcement proves available.

Browser and web grants may also be attached as one-action overlays. The permit records the overlay and removes it after the action.

### Per-Agent Grant And Model Matrix

| Agent | Grant profile | Base model class |
| --- | --- | --- |
| `bubbles.super` | `utility-read` | `standard-reasoning` |
| `bubbles.workflow` | `runner-control` | `standard-reasoning` |
| `bubbles.iterate` | `runner-control` | `standard-reasoning` |
| `bubbles.goal` | `runner-control` | `standard-reasoning` |
| `bubbles.sprint` | `runner-control` | `standard-reasoning` |
| `bubbles.analyst` | `planning-research` | `standard-reasoning` |
| `bubbles.ux` | `planning-local` | `standard-reasoning` |
| `bubbles.design` | `planning-local` | `high-assurance-reasoning` |
| `bubbles.plan` | `planning-local` | `high-assurance-reasoning` |
| `bubbles.clarify` | `diagnostic-local` | `standard-reasoning` |
| `bubbles.grill` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.implement` | `execution-owner` | `standard-reasoning` |
| `bubbles.test` | `execution-owner` | `standard-reasoning` |
| `bubbles.docs` | `execution-owner` | `economy-reasoning` |
| `bubbles.chaos` | `diagnostic-browser` | `high-assurance-reasoning` |
| `bubbles.validate` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.audit` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.regression` | `diagnostic-local` | `standard-reasoning` |
| `bubbles.harden` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.gaps` | `diagnostic-local` | `standard-reasoning` |
| `bubbles.stabilize` | `domain-control` | `high-assurance-reasoning` |
| `bubbles.devops` | `execution-owner` | `high-assurance-reasoning` |
| `bubbles.security` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.code-review` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.system-review` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.spec-review` | `diagnostic-local` | `high-assurance-reasoning` |
| `bubbles.redteam` | `diagnostic-browser` | `high-assurance-reasoning` |
| `bubbles.journey` | `diagnostic-browser` | `standard-reasoning` |
| `bubbles.status` | `utility-read` | `economy-reasoning` |
| `bubbles.setup` | `planning-research` | `standard-reasoning` |
| `bubbles.commands` | `utility-read` | `economy-reasoning` |
| `bubbles.create-skill` | `utility-write` | `standard-reasoning` |
| `bubbles.handoff` | `utility-read` | `economy-reasoning` |
| `bubbles.bug` | `domain-control` | `standard-reasoning` |
| `bubbles.simplify` | `execution-owner` | `standard-reasoning` |
| `bubbles.releases` | `domain-control` | `standard-reasoning` |
| `bubbles.train` | `domain-control` | `high-assurance-reasoning` |
| `bubbles.upkeep` | `domain-control` | `high-assurance-reasoning` |
| `bubbles.propagate` | `domain-control` | `high-assurance-reasoning` |
| `bubbles.recap` | `utility-read` | `economy-reasoning` |
| `bubbles.retro` | `domain-control` | `standard-reasoning` |

The registry must contain exactly one row for every installed agent. Unknown agents receive no grant and no dispatch.

Ownership checks still constrain `edit`. The host grant does not authorize foreign-artifact writes.

## Verified Session Epochs

### Epoch Classes

| Epoch | Included work | Required opening proof |
| --- | --- | --- |
| `planning` | Intent resolution, analysis, UX, design, plan, and bootstrap readiness | Exact root session identity. |
| `implementation` | Owned source, test, docs, and operational mutation work | Verified boundary from planning. |
| `verification` | Test, regression, hardening, stability, security, chaos, red-team, and audit evidence | Verified boundary from implementation. |
| `certification` | Independent validation, transition contract, status decision, and final result | Verified boundary from verification. |

The phase registry owns the exact phase-to-epoch mapping. A phase cannot choose its own epoch.

### Boundary Proof

A valid boundary uses one of two host-proven forms.

- `host-checkpoint`: The host returns a checkpoint ID, prior session identity, new context generation, continuation digest, and verification proof.
- `new-session`: The host closes the prior session and returns a different exact session identity bound to the same continuation digest.

The model's statement that context is fresh is not proof. A timestamp and empty transcript claim are also insufficient.

Current `fresh-context` and `unavailable` values remain honest telemetry during migration. They cannot satisfy an enforced epoch transition.

If neither proof form is available, admission emits `MBE-EPOCH-BOUNDARY-UNVERIFIED`. It preserves the continuation packet and stops before the next paid epoch.

### Rollover Rules

- Open a new verified epoch at each class transition.
- Rollover at a hard budget boundary before another dispatch.
- Allow a soft boundary to request rollover without changing spec status.
- Carry the same `goalId`, `budgetId`, policy bundle, and immutable receipt chain.
- Reject stale continuation digests and changed repository decisions.
- Reject a new session that inherited unverified transcript state.
- Never reset spent budget on rollover.

## Retry And Escalation Contract

One goal budget covers every attempt. A retry cannot create a new budget or hide the prior debit.

| Failure class | Retry behavior | Budget behavior |
| --- | --- | --- |
| Confirmed transport failure before provider acceptance | One identical retry may be eligible. | Release confirmed unused reservation, then reserve the retry. |
| Transport termination after provider acceptance is unknown | Do not issue another request. Reconcile first. | Hold the maximum reservation. |
| Empty or narrative-only result | Recover the envelope from durable evidence when possible. | Do not repeat paid work. |
| Timeout with a live provider request | Cancel and verify terminal state before retry. | Hold until cancellation or receipt is verified. |
| Model output schema failure | A bounded same-route retry may run only when policy permits. | Debit actual usage and reserve another attempt. |
| Product defect or failing test | Route through the planned fix cycle. | Charge each new controlled action to the same goal budget. |
| Budget, grant, model, risk, or epoch refusal | No retry. Change an explicit policy input or stop. | No dispatch debit. Preserve the refusal receipt. |

No retry may switch providers, model classes, tools, privacy posture, or epochs without a new admission decision.

No fix attempt may start another nested fix loop. New failures consume the same phase and goal retry counters.

## Failure Taxonomy

| Code | Condition | Required outcome |
| --- | --- | --- |
| `MBE-CONTRACT-UNSUPPORTED` | No common adapter contract major version exists. | Refuse before dispatch. |
| `MBE-SESSION-IDENTITY-MISSING` | The host cannot bind repository and usage session identity. | Refuse configured enforcement. |
| `MBE-SESSION-IDENTITY-AMBIGUOUS` | More than one host artifact matches the session. | Refuse without aggregation. |
| `MBE-HOST-SCHEMA-UNSUPPORTED` | No exact schema profile matches host records. | Report unmeasured in shadow and refuse configured enforcement. |
| `MBE-DIMENSION-UNMEASURABLE` | A configured cap lacks a trusted bound or actual receipt. | Refuse before paid dispatch. |
| `MBE-BUDGET-EXHAUSTED` | A reservation would exceed one hard cap. | Preserve state and stop that action. |
| `MBE-RESERVATION-CONFLICT` | Concurrent writers used different budget snapshots. | Retry the deterministic ledger transaction without dispatch. |
| `MBE-QUOTE-EXPIRED` | The provider or price quote expired before permit use. | Release reservation and obtain a new decision. |
| `MBE-PERMIT-INVALID` | Permit identity, action digest, nonce, or expiry is invalid. | Refuse at the host broker. |
| `MBE-DISPATCH-BYPASS` | A controlled action reached the host without a permit. | Block and record a security finding. |
| `MBE-USAGE-UNRESOLVED` | Provider acceptance or charge remains unknown. | Hold reservation and prohibit duplicate retry. |
| `MBE-RECEIPT-MISMATCH` | Receipt identity or normalized totals disagree with host proof. | Refuse reconciliation and preserve both records. |
| `MBE-RISK-UNRESOLVED` | Risk inputs are missing or contradictory. | Select full assurance and record unknown risk. |
| `MBE-MODE-UNRESOLVED` | No explicit or deterministic implicit mode resolves. | Refuse before phase dispatch. |
| `MBE-MODEL-CLASS-UNAVAILABLE` | No verified model mapping satisfies the phase floor. | Refuse before model dispatch. |
| `MBE-TOOL-GRANT-DENIED` | Agent, phase, or action lacks an exact grant. | Refuse before tool dispatch. |
| `MBE-EPOCH-BOUNDARY-UNVERIFIED` | No host-verifiable checkpoint or new session exists. | Preserve continuation and stop before the next epoch. |
| `MBE-ROLLOVER-REQUIRED` | Policy requires a boundary before more work. | Close the epoch and request host rollover. |
| `MBE-RETRY-INELIGIBLE` | Failure class or retry count forbids another attempt. | Route a defect or stop. |
| `MBE-CONCURRENCY-EXHAUSTED` | Active permits equal the configured cap. | Wait within wall time or refuse. |
| `MBE-DEADLINE-EXCEEDED` | Goal or action deadline expired. | Cancel, reconcile, and preserve non-terminal state. |
| `MBE-INTERNAL` | The admission plane violates its own invariant. | Stop all controlled dispatch for that goal and file a framework defect. |

Closed command exit classes are `0` allowed or reconciled, `1` policy refusal, `2` malformed input, `3` host enforcement unavailable, and `4` reconciliation outstanding.

## Security, Privacy, And Integrity

- Keep permits and host proofs in host-private storage with mode `0600` or stronger.
- Do not place prompts, completions, source bodies, credentials, cookies, or private paths in receipts.
- Bind public receipt identities to content digests, not content text.
- Salt telemetry correlation separately from durable private identity.
- Validate every adapter output against a closed schema.
- Reject duplicate event IDs with different bytes.
- Reject counters that move backward without a signed correction record.
- Keep repository binding, action risk, artifact ownership, and approval gates independent from budget admission.
- Treat a budget permit as permission to spend only. It does not authorize a destructive or consequential action.
- Require both action authorization and budget admission when both apply.
- Preserve raw evidence outside model context when projection limits apply.
- Never let source text, model output, or tool output alter grants, budgets, model mappings, or epoch proof.

## Observability

### Metrics

- Admission decisions by verdict and reason code.
- Configured, measurable, unconfigured, and unsupported dimension counts.
- Reserved, debited, released, held, and corrected amounts by dimension.
- Exact-session identity success, absence, and ambiguity counts.
- Usage adapter contract and host schema versions.
- Implicit risk-tier outcomes and later assurance elevations.
- Model class requests, satisfied mappings, and refusals.
- Tool grant requests, scoped overlays, and denials.
- Epoch opens, verified boundaries, rollover requests, and refusals.
- Transport retries, defect routes, unresolved provider requests, and prevented duplicates.
- Retained result bytes and raw evidence pointers.
- Shadow, canary, and default-enforced cohort outcomes.

### Forbidden Telemetry Fields

- Prompt or completion text.
- Source, tool, browser, or web result bodies.
- Credential values or credential references.
- Provider request IDs without salted projection.
- Private file paths or host account names.
- Repository content beyond approved opaque identities.
- Model chain-of-thought or hidden reasoning.

## Configuration Contract

Add one optional `dispatchAdmission` project block during shadow migration. Absence preserves current behavior and emits no enforcement claim.

The block declares:

- Schema version and rollout posture.
- Usage adapter and dispatch broker identifiers.
- Exact-session identity requirements.
- One explicit state for every budget dimension.
- Currency and minor-unit scale for each money cap.
- Phase-to-epoch mapping policy version.
- Phase-to-model-class mapping policy version.
- Per-agent tool-grant registry version.
- Implicit-mode risk policy version.
- Receipt store and retention policy.
- Canary cohort identity.
- Telemetry redaction policy.

Configuration stores adapter names and credential reference names. It stores no provider secret or concrete required model default.

Policy list order never selects a provider. An ambiguous eligible route refuses.

## Default-Preserving Migration And Rollout

### Stage 0 - Proposal Only

This file changes no runtime, registry, agent, index, or documentation surface.

### Stage 1 - Contracts And Shadow Telemetry

- Land schemas, registries, neutral adapters, and hermetic tests.
- Keep all existing direct dispatch and mode behavior.
- Record what admission would decide without issuing or requiring permits.
- Label every result `shadow` and prevent it from blocking work.

### Stage 2 - Advisory Decisions

- Add exact-session usage when a host adapter supports it.
- Compare coordinator decisions with actual dispatch and receipts.
- Surface configured unmeasurable dimensions as activation blockers.
- Keep direct dispatch active while parity is measured.

### Stage 3 - Canary Enforcement

- Select one owner-approved host, runner, and mode cohort.
- Remove direct controlled grants only inside that cohort.
- Require broker permits and verified epoch boundaries.
- Stop the canary if any required gate, dispatch, or receipt path regresses.

### Stage 4 - Default Activation

- Activate enforcement for delivery modes only after every acceptance threshold passes.
- Require an enforcement-capable host adapter.
- Refuse controlled dispatch on unsupported hosts instead of claiming a cap.
- Preserve explicit below-`done` and read-only mode semantics.

### Stage 5 - Legacy Cleanup

- Keep G128 as a compatibility and independent aggregate audit until the new ledger has one stable release window.
- Remove model-controlled budget seeding only after every runner uses the admission plane.
- Retain v1 usage reads for historical telemetry without enforcement authority.

### Rollback

- Before default activation, remove the canary cohort and keep shadow receipts.
- After default activation, pin the previous signed policy bundle or previous framework release.
- Regenerate grants from that pinned bundle.
- Never add a bypass flag or delete admission history.
- Reconcile every active reservation before the rollback closes.

## Frozen Historical Corpus And Cost Measurement

The operator-supplied 30-day measurements are a diagnostic baseline. They are not a frozen evaluation corpus yet.

### Corpus Manifest

Create a private, sanitized `CostCorpusManifest` after usage adapter v2 can resolve exact sessions.

The manifest records:

- Corpus schema version and source adapter versions.
- Time window and immutable source snapshot digest.
- Salted session and request identities.
- Mode, phase, epoch, risk class, model class, and tool family when proven.
- Measured usage dimensions and measurement status.
- Gate outcomes, terminal outcome, and evidence identities.
- Explicit exclusion reasons for non-evaluable records.
- No prompt, completion, source, or result body.

Seal the manifest before candidate evaluation. A changed corpus creates a new corpus identity.

### Two Measurement Tracks

**Historical replay** applies candidate admission rules to frozen event metadata. It estimates prevented or resized dispatches without claiming causal savings.

**Matched live canary** runs the same approved task corpus under baseline and candidate policies. It measures actual host and provider receipts.

Historical replay may justify canary selection. Only matched live canary data may support a proven reduction percentage.

### Metrics And Formulas

For each measured dimension `d`, report:

```text
usage_ratio_d = sum(candidate_usage_d) / sum(baseline_usage_d)
reduction_d = 1 - usage_ratio_d
measurement_coverage_d = measured_matched_dispatches_d / matched_dispatches
```

Report totals, medians, upper percentiles, and confidence intervals by mode and risk class.

Do not combine input, output, cache, credits, money, requests, or bytes into one synthetic score.

Do not publish `reduction_d` when measurement coverage is incomplete for the matched comparison.

### Quality And Assurance Pairing

Every cost result must include:

- Gate pass and refusal parity.
- Scenario and test outcome parity.
- Anti-fabrication finding rate.
- Security and action-risk refusal parity.
- Exact-resume and no-replay parity.
- Human acceptance status when the task requires it.
- Unsupported and unmeasured record counts.

A cheaper run with weaker assurance fails evaluation.

## Testing And Validation Strategy

### Schema And Identity Tests

- Validate every record against its closed schema.
- Prove key order and line ending changes preserve identity.
- Prove semantic field changes alter identity.
- Reject prompt text, secrets, and private paths in public receipt projections.
- Reject a correction that does not name an existing receipt.

### Usage Adapter Contract Tests

- Run one shared corpus against `none`, v1 compatibility, and every v2 adapter.
- Prove exact-session resolution rejects prefix collisions.
- Prove unknown host schema produces unmeasured shadow output and enforced refusal.
- Mutate token field names, types, units, and nesting.
- Prove configured dimensions cannot dispatch without quote and receipt support.
- Prove unconfigured dimensions remain unmeasured for admission.

### Budget Boundary Tests

- Exercise every independent cap one unit below, exactly at, and one unit above its limit.
- Prove atomic reservation leaves no partial event after one dimension fails.
- Prove actual usage debits and unused reservation releases.
- Prove unknown provider outcomes hold the reservation.
- Prove rollover never resets spent totals.
- Prove currency counters cannot cross-convert.
- Prove concurrency never exceeds the configured active-permit count.

### Admission And Bypass Tests

- Attempt direct native subagent dispatch from an enforced runner and assert host denial.
- Attempt direct web, browser, and tool calls without permits and assert denial.
- Replay a consumed permit and assert denial.
- Change action bytes after reservation and assert digest mismatch.
- Expire a quote before permit use and assert no dispatch.
- Remove one decision reference and assert the admission receipt is invalid.

### Risk And Mode Tests

- Verify explicit modes remain byte-identical after resolution.
- Verify low-risk positive inputs can select rapid delivery.
- Verify every high-risk trigger selects full delivery.
- Verify missing and contradictory risk inputs select full delivery.
- Verify post-plan risk elevation cannot remove owed gates.
- Verify planning-only intent cannot enter an implementation phase.

### Model And Grant Tests

- Require one registry row for every installed agent.
- Reject unknown agents and unknown tool families.
- Verify runner profiles contain no direct controlled dispatch family.
- Verify browser and web overlays expire after one action.
- Verify unknown model IDs remain unverified.
- Verify high-risk work elevates eligible phases to high assurance.
- Verify no provider or concrete model appears as a required default.

### Epoch And Rollover Tests

- Reject a model-authored `fresh-context` boundary as epoch proof.
- Accept a valid host checkpoint bound to the continuation digest.
- Accept a new exact session with a different host session identity.
- Reject a new session with stale repository binding or changed goal identity.
- Interrupt after every epoch and compare final receipt chains with uninterrupted execution.
- Verify certification cannot consume implementation context without a verified boundary.

### Retry And Fault Tests

- Confirm one transport retry reuses the logical occurrence and shared budget.
- Confirm unresolved provider acceptance blocks duplicate retry.
- Confirm schema failure debits usage before another attempt.
- Confirm a product defect routes to planning and repair rather than request replay.
- Confirm provider switching requires a new explicit policy decision.
- Confirm fix loops cannot recurse.

### Migration And Rollback Tests

- Prove shadow posture changes no dispatch verdict.
- Prove advisory posture changes no grant.
- Prove canary scope cannot expand without a signed policy bundle.
- Prove default enforcement refuses an unsupported host.
- Roll back with active reservations and prove reconciliation completes first.
- Prove rollback preserves all prior receipts and budget totals.

### Frozen Corpus Tests

- Seal the corpus and reject any later source change under the same identity.
- Verify non-evaluable rows remain in the denominator report as exclusions.
- Verify historical replay is labeled counterfactual.
- Verify only matched live runs can emit a reduction percentage.
- Verify every cost report carries its quality and assurance report.

## Acceptance Metrics

| Metric | Acceptance threshold | Proof shape |
| --- | --- | --- |
| Configured unmeasurable dispatch | 0 paid dispatches | Adapter spy and host broker receipt for every dimension. |
| Hard-cap overrun accepted | 0 | Boundary corpus across all independent dimensions. |
| Cross-session usage contamination | 0 | Prefix-collision and concurrent-session tests. |
| Permit bypass | 0 successful controlled actions | Host-level adversarial dispatch corpus. |
| Receipt reconciliation | 100 percent of terminal dispatches | Each consumed permit ends in debit and release, or a named unresolved hold. |
| High or unknown risk routed below full assurance | 0 | Risk corpus at intake, post-plan, and pre-certification. |
| Existing explicit mode drift | 0 | Byte comparison of resolved mode contracts before and after integration. |
| Required gate loss | 0 | Required-gate set comparison for every mode. |
| Agent grant coverage | 100 percent | One exact row per installed agent, with no unknown family. |
| Model identity guessing | 0 | Unknown model corpus remains unverified. |
| Unverified epoch transition | 0 accepted transitions | Fake-boundary and stale-session corpus. |
| Duplicate paid retry after unresolved acceptance | 0 | Provider termination and delayed-receipt tests. |
| Recursive escalation | 0 nested fix loops | Fault-injection run-state trace. |
| Telemetry content leakage | 0 canary matches | Canary strings across prompts, sources, results, secrets, and private paths. |
| Rollback receipt loss | 0 lost records | Pre-rollout and post-rollback ledger digest comparison. |
| Quality non-regression | No weaker required gate, scenario, security, or acceptance outcome | Matched task report beside each cost report. |
| Cost reduction | No fixed percentage in this proposal | Frozen historical replay plus matched live canary with complete measurement coverage. |

Default activation requires every non-cost threshold above. It also requires measured live usage below baseline for the approved primary dimensions.

The activation report must state the observed reduction and confidence interval. This proposal does not predict that result.

## Alternatives And Tradeoffs

### A1 - Extend G128 with more counters

Rejected. G128 reads state after activity and cannot deny the next paid dispatch.

### A2 - Ask runners to self-enforce budgets more carefully

Rejected. The current seeding and dispatch rules already rely on model behavior. A model cannot be the authority over its own spend.

### A3 - Route only provider API calls through a budget wrapper

Rejected. Native subagents, root model requests, web, browser, and tool results also consume bounded resources.

### A4 - Keep direct `agent` grants and require a permit field in prompts

Rejected. A prompt field does not prevent a direct host call that omits it.

### A5 - Use one low-cost model for every phase

Rejected. Cost does not replace capability, security review, or certification independence.

### A6 - Require one named provider and model

Rejected. It would make framework policy depend on vendor availability and pricing.

### A7 - Reduce the full-delivery gate set

Rejected. The proposal targets unnecessary dispatch and context, not assurance obligations.

### A8 - Treat transcript compaction as session rollover

Rejected. Current source can record `fresh-context` without host proof. Ledger compaction does not prove model-context reset.

### A9 - Reset budget when a new chat session starts

Rejected. Session rollover would become a spend bypass. The budget belongs to the goal.

### A10 - Retry another provider when the selected route fails

Rejected. Provider changes alter price, privacy, quality, and provenance.

### A11 - Infer token cost from the operator-supplied averages

Rejected. Aggregate averages cannot enforce one exact request and cannot distinguish cache or output classes.

### A12 - Claim savings from historical counterfactual replay

Rejected. Replay estimates prevented work. It does not measure candidate execution or quality.

## Risks And Mitigations

- **R1** The host cannot intercept native model dispatch -> Keep shadow mode non-authoritative and refuse default enforcement until a broker exists.
- **R2** Narrow grants can silently break valid work -> Canary one agent and one mode, then expand only after dispatch parity passes.
- **R3** Provider token quotes may differ from billed usage -> Reserve trusted upper bounds and reconcile against immutable actual receipts.
- **R4** Unknown charges can deadlock the budget -> Hold the reservation, expose the unresolved state, and require provider reconciliation.
- **R5** Exact-session identity may be unavailable on some hosts -> Report unmeasured and prohibit configured enforcement on those hosts.
- **R6** Host schema evolution can disable measurement -> Version mappings, fingerprint schemas, and fail loud for configured dimensions.
- **R7** Risk text matching can miss a new high-risk class -> Unknown remains full assurance, and post-plan resolution uses changed paths.
- **R8** Model classes can become vendor aliases -> Keep classes capability-based and put concrete mappings in host-owned policy.
- **R9** Epoch rollover can interrupt useful context -> Preserve a content-addressed continuation packet and test resume equivalence.
- **R10** Certification isolation can omit required evidence -> Bind the certification epoch to the complete verification manifest digest.
- **R11** Receipt storage can leak usage or provider identity -> Separate private records from sanitized telemetry projections.
- **R12** Concurrent reservations can overspend -> Use compare-and-append under one budget lock and retry only the ledger transaction.
- **R13** Rollback can become a hidden bypass -> Allow only signed policy or release rollback, never an enforcement skip flag.
- **R14** Cost optimization can reward weaker results -> Require assurance and quality non-regression beside every cost comparison.
- **R15** Historical corpus selection can bias the result -> Freeze inclusion rules, list exclusions, and report results by mode and risk class.
- **R16** Root request admission may remain outside Bubbles control -> State this limitation and require host pre-model support before full activation.

## Complexity Tracking

| Deviation from the simpler approach | Simpler alternative | Why rejected |
| --- | --- | --- |
| Host-enforced dispatch broker | Model calls existing tools directly | Direct calls can bypass every repository budget decision. |
| Fifteen independent budget dimensions | One synthetic cost score | Different units cannot safely compensate for each other. |
| Reserve, debit, release, and hold events | Compare totals after completion | Post-run comparison cannot prevent overspend or duplicate retry. |
| Exact session identity | Prefix-match host files | Prefix and unscoped matches can mix concurrent sessions. |
| Versioned host schema profiles | Recursive field-name discovery | Plausible field discovery can silently misread changed units or meanings. |
| Four verified epochs | One long transcript | One transcript couples planning, implementation, verification, and certification context. |
| Host boundary proof | Model declares fresh context | A declaration is not verifiable evidence of context reset. |
| Per-agent explicit grants | Restrict only expensive families | Partial restrictions leave native dispatch and mutation families outside policy. |
| Abstract model classes | Name one provider model | A provider default is not portable and can become unavailable. |
| Risk resolution at three boundaries | Resolve risk once at intake | Planned and changed surfaces can reveal risk absent from initial text. |
| Shared goal budget across sessions | Reset each session | Session creation would become a budget bypass. |
| Frozen replay plus matched canary | Report historical replay savings | Counterfactual replay cannot prove actual usage or quality. |

## Acceptance Criteria (when implemented)

- Every controlled dispatch has one valid admission decision, reservation, permit, and terminal accounting state.
- No configured unmeasurable dimension reaches paid dispatch.
- Every unconfigured dimension remains unmeasured for admission.
- All fifteen budget dimensions enforce independent hard caps.
- Atomic reservation never leaves a partial budget event set.
- Exact session identity prevents cross-session aggregation.
- Unknown host schema never becomes a measured zero.
- Usage adapter v1 remains readable and cannot claim enforcement authority.
- High and unknown risk select full assurance when mode is implicit.
- Explicit mode resolution and required gate sets remain unchanged.
- Phase relevance keeps all `neverSkip` and uncertain phases runnable.
- Every installed agent has one explicit minimal grant row.
- Enforced runners cannot call native subagent, web, browser, or tool paths without a permit.
- Unknown model identity never receives an inferred capability class.
- No provider or concrete model is a required default.
- Planning, implementation, verification, and certification open through verified epoch boundaries.
- Model-declared fresh context cannot satisfy rollover.
- One goal budget survives every retry and session rollover.
- Transport retries remain distinct from defect remediation.
- No recursive auto-escalation path exists.
- Rollback restores a prior signed policy and preserves every receipt.
- Shadow and advisory postures preserve current dispatch behavior.
- Canary enforcement passes all budget, bypass, quality, security, and rollback tests.
- Default activation occurs only after the acceptance metrics pass.
- The frozen-corpus report labels counterfactual and live results separately.
- No cost reduction percentage appears without complete matched measurement coverage.

## Files To Touch (on approval)

| Surface | Approval-time change | Owner and enforcement |
| --- | --- | --- |
| `bubbles/schemas/dispatch-admission.schema.json` (new) | Define intent, decision, reservation, permit projection, and receipt schemas. | `bubbles.implement`; schema tests owned by `bubbles.test`. |
| `bubbles/schemas/usage-adapter-v2.schema.json` (new) | Define version negotiation, exact session identity, capabilities, quotes, snapshots, and receipts. | `bubbles.implement`; adapter contract tests owned by `bubbles.test`. |
| `bubbles/schemas/session-epoch.schema.json` (new) | Define epoch and host boundary receipt records. | `bubbles.implement`; rollover tests owned by `bubbles.test`. |
| `bubbles/registry/admission-dimensions.yaml` (new) | Register the fifteen independent dimensions, units, and reservation rules. | `bubbles.implement`; registry parity gate. |
| `bubbles/registry/model-classes.yaml` (new) | Register capability classes and phase selection rules without provider names. | `bubbles.workflow`; model-class contract tests. |
| [`bubbles/registry/tool-grants.yaml`](../bubbles/registry/tool-grants.yaml) | Upgrade to explicit per-agent profiles and dispatch-scoped overlays. | `bubbles.workflow`; strict grant lint and host canary. |
| [`bubbles/agent-capabilities.yaml`](../bubbles/agent-capabilities.yaml) | Reference grant profile, model class, and epoch permissions for every agent. | `bubbles.workflow`; capability registry consistency. |
| `bubbles/adapters/dispatch/none.sh` (new) | Report host enforcement unavailable without claiming a permit. | `bubbles.implement`; adapter contract tests. |
| `bubbles/adapters/dispatch/host-rpc.sh` (new) | Bind coordinator decisions to a host-enforced broker RPC. | `bubbles.implement` with host integration owner; bypass tests required. |
| `bubbles/scripts/dispatch-adapter-resolve.sh` (new) | Resolve optional, configured, and broken dispatch adapters. | `bubbles.implement`; resolver selftest. |
| `bubbles/scripts/dispatch-admission.sh` (new) | Implement pure admission and immutable decision output. | `bubbles.implement`; boundary and fault tests. |
| `bubbles/scripts/goal-budget-ledger.sh` (new) | Implement atomic reserve, debit, release, hold, correction, and close operations. | `bubbles.implement`; concurrency and crash tests. |
| `bubbles/scripts/session-epoch-authority.sh` (new) | Verify host checkpoint or new-session boundaries. | `bubbles.implement`; fake-boundary tests. |
| [`bubbles/scripts/phase-coordinator.sh`](../bubbles/scripts/phase-coordinator.sh) | Call admission before dispatch and bind occurrence advancement to both receipt families. | `bubbles.workflow`; coordinator and no-replay tests. |
| [`bubbles/scripts/phase-relevance-resolve.sh`](../bubbles/scripts/phase-relevance-resolve.sh) | Emit a typed decision record consumable by admission. | `bubbles.workflow`; fail-to-run behavior remains mandatory. |
| [`bubbles/scripts/risk-tier-resolve.sh`](../bubbles/scripts/risk-tier-resolve.sh) | Emit a typed, digest-bound risk decision for intake, post-plan, and pre-certification. | `bubbles.workflow`; high and unknown risk corpus. |
| [`bubbles/scripts/model-tier-advisory.sh`](../bubbles/scripts/model-tier-advisory.sh) | Consume verified model-class mapping and refuse required unavailable classes. | `bubbles.workflow`; model identity mutation tests. |
| [`bubbles/scripts/usage-resolve.sh`](../bubbles/scripts/usage-resolve.sh) | Negotiate adapter contract versions and enforcement capabilities. | `bubbles.implement`; resolver compatibility tests. |
| [`bubbles/adapters/usage/none.sh`](../bubbles/adapters/usage/none.sh) | Add v2 neutral contract output while preserving unmeasured truth. | `bubbles.implement`; shared adapter tests. |
| [`bubbles/adapters/usage/vscode-copilot.sh`](../bubbles/adapters/usage/vscode-copilot.sh) | Add exact-session identity and explicit host-schema profiles. | `bubbles.implement`; host schema fixtures and drift tests. |
| [`bubbles/scripts/session-cap-guard.sh`](../bubbles/scripts/session-cap-guard.sh) | Read the new ledger for aggregate audit while retaining legacy session-state compatibility. | `bubbles.implement`; G128 compatibility tests. |
| [`bubbles/scripts/state-snapshot.sh`](../bubbles/scripts/state-snapshot.sh) | Record verified epoch and boundary receipt identities, never a caller-only proof. | `bubbles.implement`; session lock and rollover tests. |
| [`bubbles/scripts/context-compactor.sh`](../bubbles/scripts/context-compactor.sh) | Bind compacted continuation bytes to the epoch boundary receipt. | `bubbles.implement`; compaction identity tests. |
| [`bubbles/scripts/compaction-discipline-guard.sh`](../bubbles/scripts/compaction-discipline-guard.sh) | Distinguish honest unavailable telemetry from verified epoch proof. | `bubbles.validate`; G083 regression tests. |
| [`bubbles/scripts/dispatch-receipt.sh`](../bubbles/scripts/dispatch-receipt.sh) | Link dispatch failure classes to shared goal-budget attempts. | `bubbles.implement`; retry-class tests. |
| [`bubbles/scripts/pre-tool-risk-gate.sh`](../bubbles/scripts/pre-tool-risk-gate.sh) | Require both action authorization and budget permit for controlled host events. | `bubbles.security`; pre-tool bypass tests. |
| [`bubbles/hooks.json`](../bubbles/hooks.json) | Register host admission hooks only when the host declares enforceable support. | `bubbles.implement`; hook contract tests. |
| [`bubbles/workflows.yaml`](../bubbles/workflows.yaml) | Add admission, model class, epoch, and migration policy declarations. Keep `defaultMode` until canary activation. | `bubbles.workflow`; workflow registry checks. |
| [`bubbles/workflows/modes.yaml`](../bubbles/workflows/modes.yaml) | Add budget policy references and epoch mappings without changing required gates. | `bubbles.workflow`; resolved-mode byte comparison. |
| [`bubbles/schemas/workflows.schema.json`](../bubbles/schemas/workflows.schema.json) | Validate admission and epoch policy references. | `bubbles.implement`; schema validation. |
| [`agents/bubbles.goal.agent.md`](../agents/bubbles.goal.agent.md) | Replace model-controlled seeding and direct dispatch with broker consumption after canary proof. | `bubbles.workflow`; runner dispatch tests. |
| [`agents/bubbles.workflow.agent.md`](../agents/bubbles.workflow.agent.md) | Route every phase occurrence through admission. | `bubbles.workflow`; single-mode parity tests. |
| [`agents/bubbles.sprint.agent.md`](../agents/bubbles.sprint.agent.md) | Share one goal-set budget and broker across queued goals. | `bubbles.workflow`; sprint budget tests. |
| [`agents/bubbles.iterate.agent.md`](../agents/bubbles.iterate.agent.md) | Resolve each implicit delivery mode through deterministic risk admission. | `bubbles.workflow`; iteration routing tests. |
| [`agents/bubbles.super.agent.md`](../agents/bubbles.super.agent.md) | Return intent facts without owning the final risk or admission decision. | `bubbles.workflow`; intent-resolution tests. |
| `bubbles/scripts/admission-contract-selftest.sh` (new) | Exercise schemas, permits, budgets, risk, model, grants, epochs, and rollback. | `bubbles.test`; registered framework validation. |
| `bubbles/scripts/usage-adapter-v2-selftest.sh` (new) | Exercise exact identity, schema evolution, quotes, and receipts across adapters. | `bubbles.test`; registered framework validation. |
| `bubbles/scripts/cost-corpus-evaluate.sh` (new) | Seal and evaluate sanitized historical and matched canary manifests. | `bubbles.retro`; measurement integrity tests. |
| [`bubbles/registry/validation-checks.yaml`](../bubbles/registry/validation-checks.yaml) | Register generated closure for all new selftests and live guards. | `bubbles.implement`; generated registry consistency. |
| [`bubbles/registry/gates.yaml`](../bubbles/registry/gates.yaml) | Register admission integrity only after a live enforcement path exists. | `bubbles.implement`; gate enforcement and strength checks. |
| [`bubbles/scripts/framework-validate.sh`](../bubbles/scripts/framework-validate.sh) | Run new contract selftests and live registry checks. | `bubbles.implement`; reachability checks. |
| [`bubbles/capability-ledger.yaml`](../bubbles/capability-ledger.yaml) | Add capability only after a real host broker consumer exists. | `bubbles.docs`; capability-consumer freshness. |
| [`bubbles/release-manifest.json`](../bubbles/release-manifest.json) | Include shipped schemas, registries, adapters, scripts, and tests through generation. | `bubbles.implement`; release-manifest checks. |
| `docs/guides/MEASURED_BUDGET_AND_SESSION_EPOCHS.md` (new) | Document configuration, trust boundaries, receipts, rollout, and failure codes. | `bubbles.docs`; managed documentation checks. |
| [`docs/CHEATSHEET.md`](../docs/CHEATSHEET.md) | Add operator inspection and refusal guidance after runtime delivery. | `bubbles.docs`; documentation consistency. |
| [`CHANGELOG.md`](../CHANGELOG.md) | Record each shipped rollout stage only after its implementation lands. | `bubbles.docs`; release review. |
| [`improvements/INDEX.md`](INDEX.md) | Add IMP-055 only in the owner-approved publication step. | Publication owner; G125 framework-health evidence lint. |

### Exact Agent Frontmatter Set

`bubbles.workflow` owns grant generation for exactly these current agent files. One-row-per-agent parity and held-out dispatch evaluation enforce the change.

```text
agents/bubbles.analyst.agent.md
agents/bubbles.audit.agent.md
agents/bubbles.bug.agent.md
agents/bubbles.chaos.agent.md
agents/bubbles.clarify.agent.md
agents/bubbles.code-review.agent.md
agents/bubbles.commands.agent.md
agents/bubbles.create-skill.agent.md
agents/bubbles.design.agent.md
agents/bubbles.devops.agent.md
agents/bubbles.docs.agent.md
agents/bubbles.gaps.agent.md
agents/bubbles.goal.agent.md
agents/bubbles.grill.agent.md
agents/bubbles.handoff.agent.md
agents/bubbles.harden.agent.md
agents/bubbles.implement.agent.md
agents/bubbles.iterate.agent.md
agents/bubbles.journey.agent.md
agents/bubbles.plan.agent.md
agents/bubbles.propagate.agent.md
agents/bubbles.recap.agent.md
agents/bubbles.redteam.agent.md
agents/bubbles.regression.agent.md
agents/bubbles.releases.agent.md
agents/bubbles.retro.agent.md
agents/bubbles.security.agent.md
agents/bubbles.setup.agent.md
agents/bubbles.simplify.agent.md
agents/bubbles.spec-review.agent.md
agents/bubbles.sprint.agent.md
agents/bubbles.stabilize.agent.md
agents/bubbles.status.agent.md
agents/bubbles.super.agent.md
agents/bubbles.system-review.agent.md
agents/bubbles.test.agent.md
agents/bubbles.train.agent.md
agents/bubbles.upkeep.agent.md
agents/bubbles.ux.agent.md
agents/bubbles.validate.agent.md
agents/bubbles.workflow.agent.md
```

No file above changes during this proposal invocation. This invocation creates only `improvements/IMP-055-measured-budget-and-session-epoch-runtime.md`.
