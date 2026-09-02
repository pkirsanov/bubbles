# IMP-054 - Hybrid Evidence Research Runtime

**Status:** IN PROGRESS - ECF-01 shared execution-control foundation landed; research-runtime scopes remain pending.

**Surface:** framework-health (G125) - human-reviewed. NO auto-mutation of bubbles/* until approved.

**Motivation:** A current-session source review found strong orchestration, receipt, usage, budget, compaction, model-floor, and gate primitives, but no reusable research-run capability. Sources include `bubbles/capability-ledger.yaml`, `bubbles/workflows.yaml`, and the contract files named in Provenance.

**Verified gaps addressed:**

- `EV-15` - no claim/evidence research ledger.
- `HO-5` - no staged resumable research-run contract.
- `COST-11` - no research-wide resource budget.
- `SEC-7` - no unified research data-routing and prompt-isolation contract.

## Design Brief

### Current State

Bubbles resolves workflow modes, assigns phase owners, applies model floors, and enforces deterministic gates. It also records content-addressed execution receipts and compacts result envelopes.

The usage adapter reports measured host usage without estimation. The session budget guard enforces configured, measurable session dimensions.

These capabilities do not define a research question, source, claim, citation, conflict, synthesis, or immutable research publication contract.

### Target State

Add an opt-in research runtime that turns one explicit question contract into an immutable, evidence-backed artifact. The runtime composes deterministic stages with policy-selected model stages.

Every stage receives exact inputs, emits a typed receipt, and starts with fresh context. Provider identity remains an adapter concern rather than framework policy.

The runtime publishes evidence artifacts only. It cannot deploy, transact, message users, change infrastructure, or perform another consequential action.

### Patterns to Follow

- Follow the optional adapter resolution in [`usage-resolve.sh`](../bubbles/scripts/usage-resolve.sh). Absence remains explicit and configured failures remain loud.
- Follow the measured-versus-unmeasured distinction in [`adapters/usage/none.sh`](../bubbles/adapters/usage/none.sh). Unknown usage never becomes zero.
- Follow exact input closure and source revision binding in [`tool-call.schema.json`](../bubbles/schemas/tool-call.schema.json).
- Follow earned, append-only occurrence receipts in [`dispatch-receipt.sh`](../bubbles/scripts/dispatch-receipt.sh).
- Follow receipt-derived state in [`scenario-states.yaml`](../bubbles/registry/scenario-states.yaml). Models and operators do not declare earned states.
- Follow deterministic inheritance and canonical resolution in [`mode-resolver.sh`](../bubbles/scripts/mode-resolver.sh).
- Follow bounded context projection in [`context-compactor.sh`](../bubbles/scripts/context-compactor.sh).
- Follow the registry-backed gate model in [`gates.yaml`](../bubbles/registry/gates.yaml).

### Patterns to Avoid

- Do not turn a Research Lab publication script into the foundation. That would bind framework policy to one downstream product.
- Do not extend a judge adapter into a research orchestrator. [`adapters/judge/ollama.sh`](../bubbles/adapters/judge/ollama.sh) owns evaluator scoring, not source and claim lifecycles.
- Do not copy the judge adapter's model fallback into routing policy. Research routes require explicit policy and measurable budget capabilities.
- Do not use one large prompt as the run record. A transcript cannot provide stage identity, exact resumption, or selective invalidation.
- Do not treat [`tool-log.sh`](../bubbles/scripts/tool-log.sh) as the domain ledger. It records command execution, not claim support or source conflicts.
- Do not choose a provider because another route failed. An unavailable selected route produces a typed refusal unless policy is explicitly revised.
- Do not place source text, prompts, credentials, or model responses in telemetry.

### Resolved Decisions

- The capability is provider-neutral and opt-in.
- The question contract and deterministic plan precede acquisition or model dispatch.
- Every configured budget is hard and checked before dispatch.
- Configured monetary or token limits require measurable adapters.
- Unconfigured usage remains `unmeasured`, never zero.
- All accepted stage outputs are content-addressed and immutable.
- Exact input fingerprints control reuse, resume, and invalidation.
- Model stages use fresh context and bounded input manifests.
- Materiality and data classification govern model-route eligibility.
- Frontier synthesis is optional unless policy requires escalation.
- Missing, stale, unsupported, and conflicting evidence remain distinct outcomes.
- Publication emits an artifact and result envelope only.
- Bubbles workflows and downstream research products integrate through optional bridges.
- No provider or model name is a required default.

### Open Questions

- The owner must select the first hosted native protocol adapter after approval. This choice does not change the foundation contract.
- The owner must select the implementation language after measuring portability and dependency cost.
- The first shadow corpus must define domain-specific materiality examples before promotion from advisory use.

These questions do not block contract review. They affect implementation ordering and evaluation fixtures.

## Provenance

| Source inspected | Verified observation used by this proposal |
| --- | --- |
| [`bubbles/workflows.yaml`](../bubbles/workflows.yaml) | Registers workflow policy, phase owners, required gates, and model-floor defaults. |
| [`bubbles/workflows/modes.yaml`](../bubbles/workflows/modes.yaml) | Declares mode phase order and bounded session budgets. |
| [`bubbles/scripts/mode-resolver.sh`](../bubbles/scripts/mode-resolver.sh) | Canonicalizes inherited mode policy and rejects unknown or cyclic inheritance. |
| [`bubbles/scripts/tool-log.sh`](../bubbles/scripts/tool-log.sh) | Records command outcome, hashes, byte counts, input closure, and scenario binding. |
| [`bubbles/schemas/tool-call.schema.json`](../bubbles/schemas/tool-call.schema.json) | Defines the deterministic execution-receipt schema and exact source-revision binding. |
| [`bubbles/scripts/dispatch-receipt.sh`](../bubbles/scripts/dispatch-receipt.sh) | Uses append-only earned receipts and preserves occurrence identity across retries. |
| [`bubbles/registry/scenario-states.yaml`](../bubbles/registry/scenario-states.yaml) | Derives scenario state from receipts instead of declarations. |
| [`bubbles/scripts/usage-resolve.sh`](../bubbles/scripts/usage-resolve.sh) | Resolves an optional provider and fails loud when a configured adapter is broken. |
| [`bubbles/adapters/usage/none.sh`](../bubbles/adapters/usage/none.sh) | Represents absent measurement as `unmeasured`, not zero. |
| [`bubbles/adapters/usage/vscode-copilot.sh`](../bubbles/adapters/usage/vscode-copilot.sh) | Normalizes host-owned usage records without estimating unavailable fields. |
| [`bubbles/scripts/session-cap-guard.sh`](../bubbles/scripts/session-cap-guard.sh) | Enforces configured measurable session caps, including token and retained-output dimensions. |
| [`bubbles/scripts/context-compactor.sh`](../bubbles/scripts/context-compactor.sh) | Produces deterministic bounded projections while preserving a raw evidence pointer. |
| [`bubbles/scripts/model-tier-advisory.sh`](../bubbles/scripts/model-tier-advisory.sh) | Applies phase model floors but does not route research work among providers. |
| [`bubbles/registry/gates.yaml`](../bubbles/registry/gates.yaml) | Provides one registry for deterministic framework gate identity and enforcement. |
| [`bubbles/capability-ledger.yaml`](../bubbles/capability-ledger.yaml) | Records shipped framework capabilities and their consumers. It has no research-run capability entry. |

A current-source search under `bubbles/**` found no `ResearchRun`, `ResearchQuestion`, `ClaimRecord`, `ConflictSet`, `ResearchArtifact`, or `ResearchRunManifest` contract. The only `EvidenceLink`-shaped match was an unrelated artifact-ownership field.

## Problem (verified against source)

- **EV-15 - Research evidence has no domain ledger:** Existing receipts prove executions and scenario claims. They do not model source spans, claim support, rebuttal, conflicts, or publication coverage.
- **HO-5 - Research work has no staged run identity:** Existing workflows sequence agent phases. They do not define a deterministic question-to-publication research graph with selective resume.
- **COST-11 - Research resource use has no complete hard budget:** G128 covers session activity and context volume. It does not reserve model requests, provider cost, web calls, acquired bytes, retries, or stage concurrency for one research run.
- **SEC-7 - Research routing lacks one trust contract:** Existing adapters each define a narrow boundary. No shared contract combines data classification, egress policy, source provenance, citation validation, and prompt-injection isolation.
- The missing capability cannot be filled by a downstream brief generator. Bubbles needs a reusable foundation that downstream products may consume without becoming framework dependencies.

## Proposal

### SCOPE-1 - Research contracts and deterministic kernel (EV-15, HO-5)

- Define the eleven immutable records in this proposal and their canonical identities.
- Define the closed stage graph from question contract through immutable publication.
- Add deterministic validation, content addressing, exact input fingerprints, and selective resume.
- Keep the capability disabled when no project-owned research configuration exists.

### SCOPE-2 - Provider routing and hard budgets (COST-11, SEC-7)

- Define provider capabilities, route decisions, usage receipts, and pre-dispatch reservations.
- Ship local OpenAI-compatible and hosted API adapters as swappable examples.
- Require explicit route policy by data classification, materiality, and stage class.
- Refuse configured monetary or token caps when the selected adapter cannot measure them.

### SCOPE-3 - Evidence quality, privacy, and safe synthesis (EV-15, SEC-7)

- Admit model output only through deterministic schemas and evidence-link validation.
- Preserve missing, stale, conflicting, unsupported, and unavailable states separately.
- Isolate untrusted source text from instructions, tools, routes, budgets, and consequential actions.
- Gate material claims before optional frontier synthesis and again before publication.

### SCOPE-4 - Optional integrations, observability, and promotion controls (HO-5, COST-11)

- Add an optional Bubbles workflow bridge without creating a mandatory workflow phase.
- Define a downstream bridge contract that Research Lab and other products can implement.
- Emit sanitized stage, quality, cache, and cost telemetry without source or secret content.
- Evaluate the runtime in shadow mode before any workflow can rely on its output.

## Shared Framework Consumption Boundary

The product-neutral execution-control foundation lives in this Bubbles repository. Its canonical core is `bubbles/scripts/execution-control-store.py`, `bubbles/scripts/execution-control-lib.sh`, and `bubbles/schemas/execution-control-event.schema.json`. Bubbles owns the shared canonical JSON identity, content-addressed object storage, append-only event chain, secure local persistence, recovery, and sanitized integrity projection.

The foundation sits in Bubbles because Bubbles is the shared framework rather than a product consumer. Research Lab and other products consume it through later bridges; no downstream product becomes the hidden owner of the others.

On approval this proposal consumes rather than defines the shared run, stage, route, budget, measurement, materiality, occurrence, evidence-projection, and shadow-evaluation contracts. The closed budget dimension set, the reserve and debit and release lifecycle, and the four measurement states come from that framework.

This proposal keeps its own domain ownership. The research question contract and the claim and evidence and conflict ledger stay here. The ten-stage research graph, coverage and citation validation, and the immutable publication contract also stay here.

As later scopes land, duplicated definitions named in the framework consumer binding table are replaced by references to the Bubbles-local foundation. ECF-01 establishes storage and identity only; no research consumer bridge is bound by this slice.

## Capability Foundation

### Foundation Contract

| Contract | Responsibility | Consumers |
| --- | --- | --- |
| `ResearchRuntime` | Resolves policy, executes the stage graph, and seals the run manifest. | Standalone CLI and optional workflow bridges. |
| `QuestionPlanner` | Converts a valid question contract into one deterministic stage plan. | `ResearchRuntime`. |
| `SourceAcquisitionAdapter` | Acquires bounded bytes with provenance and freshness metadata. | Acquisition stage. |
| `SourceNormalizer` | Produces canonical text, metadata, and citation selectors. | Extraction and evidence stages. |
| `ModelProviderAdapter` | Declares capabilities, preflights measurement, invokes one route, and returns usage. | Model-enabled stages. |
| `ClaimLedger` | Stores immutable claims, evidence links, conflicts, and derived coverage. | Analysis, validation, and publication stages. |
| `BudgetLedger` | Reserves, debits, and reports every configured resource dimension. | Every I/O or model stage. |
| `ArtifactStore` | Writes content-addressed records and immutable manifests. | Cache, resume, validation, and publication. |
| `ResearchValidator` | Checks schema, identity, citations, coverage, conflicts, budgets, and publication eligibility. | Validation and publication stages. |
| `ResearchBridge` | Maps external workflow inputs and outputs without changing the foundation. | Bubbles and downstream products. |

### Extension Points

- A source adapter implements `capabilities`, `preflight`, `acquire`, and `provenance`.
- A model adapter implements `capabilities`, `preflight`, `quote`, `invoke`, `usage`, and `cancel`.
- A storage adapter implements immutable `put`, digest `get`, existence `has`, and atomic manifest sealing.
- A policy adapter resolves stage eligibility from classification, materiality, budget, and provider capabilities.
- A bridge maps a host question into `ResearchQuestion` and consumes a sealed `ResearchArtifact`.
- An evaluator scores artifacts in shadow mode without changing run or publication state.

### Foundation-Owned Behavior

- Validate the question before any network, filesystem acquisition, or model call.
- Produce one canonical plan for one exact question and policy fingerprint.
- Reserve every configured hard budget before dispatch.
- Record every attempt, refusal, cache hit, accepted output, and invalidation.
- Preserve input and occurrence identity across retries.
- Admit claims only when their evidence selectors resolve against immutable source records.
- Derive support, conflict, coverage, and publication eligibility from records.
- Start each stage with a fresh context built from its bounded input manifest.
- Reuse accepted outputs only when every identity and freshness predicate still holds.
- Publish immutable artifacts through an atomic manifest seal.
- Emit no consequential command or provider-selected tool invocation.

### Canonical Serialization And Identity

Canonical records use UTF-8 JSON with lexicographically sorted object keys. They omit insignificant whitespace and normalize line endings to LF.

Counts, token values, byte values, durations, and money use integers. Money uses an explicit currency and minor-unit scale.

Arrays are ordered when order carries meaning. Set-valued arrays are sorted by canonical member identity before hashing.

Each identity has a type prefix and SHA-256 digest. Secrets, credential handles, transient paths, and wall-clock process identifiers never enter identity material.

### Core Record Contracts

| Record | Required fields | Lifecycle | Canonical identity |
| --- | --- | --- | --- |
| `ResearchRun` | `runId`, `questionId`, `policyDigest`, `planDigest`, `budgetId`, `state`, `createdAt`, `manifestId` | `planned -> running -> completed \| blocked \| cancelled`. Resume appends events without rewriting prior facts. | `rr:sha256(questionId, policyDigest, planDigest, budgetId, runtimeVersion)` |
| `ResearchQuestion` | `questionId`, `question`, `decisionContext`, `scope`, `exclusions`, `materiality`, `coveragePolicy`, `sourcePolicy`, `dataClassification`, `publicationPolicy`, `consequenceBoundary` | Immutable. A changed contract creates a new identity and may supersede the old question. | `rq:sha256(canonical question contract)` |
| `SourceRecord` | `sourceId`, `locator`, `publisher`, `retrievedAt`, `transport`, `mediaType`, `contentDigest`, `normalizedDigest`, `freshness`, `classification`, `acquisitionReceiptId` | `acquired -> normalized -> extracted`. Freshness is derived at evaluation time. | `src:sha256(locator, retrievedAt, contentDigest, acquisition policy digest)` |
| `ClaimRecord` | `claimId`, `statement`, `subject`, `qualifiers`, `materiality`, `originStageId`, `statusBasis` | `proposed -> admitted -> supported \| contested \| unsupported \| superseded`. Status is derived from links and conflicts. | `clm:sha256(statement, subject, qualifiers, questionId)` |
| `EvidenceLink` | `linkId`, `claimId`, `sourceId`, `relation`, `selector`, `excerptDigest`, `extractionMethod`, `confidenceBasis` | Immutable after admission. Invalid selectors create rejected records, not repaired links. | `evl:sha256(claimId, sourceId, relation, selector, excerptDigest)` |
| `ConflictSet` | `conflictId`, `claimIds`, `evidenceLinkIds`, `conflictType`, `materiality`, `resolutionBasis` | `open -> resolved \| disclosed`. Resolution appends a decision and preserves the original conflict. | `cfs:sha256(sorted claimIds, sorted evidenceLinkIds, conflictType)` |
| `StageReceipt` | `stageReceiptId`, `runId`, `stageId`, `attempt`, `inputFingerprint`, `routeDecisionId`, `status`, `outputDigests`, `usageReceiptIds`, `startedAt`, `finishedAt`, `error` | `attempted -> accepted \| failed \| unresolved \| stale`. Receipts are append-only and earned from actual inputs. | `str:sha256(runId, stageId, attempt, inputFingerprint, routeDecisionId, outputDigests)` |
| `ModelRouteDecision` | `routeDecisionId`, `runId`, `stageId`, `policyDigest`, `classification`, `materiality`, `eligibleRoutes`, `selectedRoute`, `capabilityDigest`, `budgetSnapshotId`, `decision` | `evaluated -> selected \| refused`. A revised policy creates a new decision. | `mrd:sha256(runId, stageId, inputFingerprint, policyDigest, capabilityDigest, budgetSnapshotId)` |
| `UsageReceipt` | `usageReceiptId`, `runId`, `stageId`, `requestOccurrenceId`, `adapterId`, `measurementStatus`, `requestCount`, `tokens`, `credits`, `money`, `webCalls`, `bytes`, `durationMs` | `measured \| unmeasured \| invalid`. Corrections append a superseding receipt. | `usr:sha256(requestOccurrenceId, adapterId, providerReceiptDigest, normalized usage)` |
| `ResearchArtifact` | `artifactId`, `runId`, `questionId`, `claimIds`, `conflictIds`, `sourceIds`, `citationIndex`, `coverage`, `limitations`, `bodyDigest`, `validationReceiptId` | `candidate -> validated -> published \| rejected`. Published bytes never change. | `art:sha256(bodyDigest, citationIndexDigest, validationReceiptId)` |
| `ResearchRunManifest` | `manifestId`, `runId`, `recordDigests`, `stageReceiptIds`, `policyDigest`, `budgetSummary`, `artifactId`, `predecessorManifestId`, `sealedAt` | Immutable snapshots form a chain. A terminal manifest is sealed once. | `rrm:sha256(canonical manifest without manifestId)` |

`statusBasis`, support status, coverage, and eligibility are derived outputs. Producers cannot assert them without the referenced records.

### Research Question Contract

A valid question contract contains these explicit decisions:

- The question and decision context.
- Included subjects, time range, jurisdictions, and source classes.
- Excluded subjects and prohibited source classes.
- Materiality and consequence level.
- Required claim coverage and contradiction treatment.
- Maximum source age by source class.
- Data classification and allowed egress classes.
- Publication audience, retention, and citation policy.
- The output shape, including whether a ledger-only artifact is acceptable.
- A fixed `no-direct-consequential-action` boundary.

Missing decisions refuse planning. The planner does not infer a convenient default from the question text.

### Provider-Neutral Staged Run

| Stage | Class | Inputs | Output and admission rule |
| --- | --- | --- | --- |
| 1. Question contract | Deterministic | Caller input and project policy | Validated `ResearchQuestion`. Invalid or incomplete contracts refuse before I/O. |
| 2. Deterministic plan | Deterministic | Question, source policy, route policy, and budgets | Ordered stage DAG, acquisition intents, coverage targets, and exact input manifests. |
| 3. Bounded acquisition | Deterministic I/O | Acquisition intents and source budgets | Immutable `SourceRecord` values. Calls and streamed bytes stop at hard limits. |
| 4. Normalization and extraction | Deterministic first, model optional | Source records and extraction schema | Canonical text, metadata, selectors, and structured facts. Model output remains candidate data. |
| 5. Claim and evidence ledger | Hybrid admission | Structured facts and candidate claims | `ClaimRecord` and `EvidenceLink` values whose selectors resolve to immutable source bytes. |
| 6. Contradiction and coverage analysis | Deterministic first, model optional | Claims, links, source policy, and coverage targets | `ConflictSet`, coverage gaps, stale-source findings, and unsupported-claim findings. |
| 7. Materiality and risk gate | Deterministic | Coverage, conflicts, classification, consequence, and route policy | `proceed`, `require-frontier`, `require-human-review`, or `refuse`. No model can override this result. |
| 8. Optional frontier synthesis | Frontier or high-stakes model | Bounded ledger projection and explicit route decision | Candidate narrative with claim references. Required escalation refuses when unavailable. |
| 9. Deterministic validation | Deterministic | Candidate artifact and complete manifest | Schema, identity, citation, coverage, conflict, privacy, and budget verdicts. |
| 10. Immutable publication | Deterministic | Validated artifact and accepted stage receipts | Sealed `ResearchArtifact`, `ResearchRunManifest`, and host result envelope. |

### Stage Class And Routing Policy

| Stage class | Intended work | Egress posture | Selection rule |
| --- | --- | --- | --- |
| Deterministic | Planning, hashing, normalization, admission, coverage, gates, validation, publication | No model egress | Always preferred when the operation has deterministic semantics. |
| Local model | Restricted extraction, claim candidates, summarization, and low-risk semantic grouping | No hosted egress | Eligible only when a configured local adapter satisfies capability and budget policy. |
| Low-cost hosted | Public or permitted internal extraction, broad comparison, and routine synthesis | Hosted egress allowed by classification | Eligible only through an explicit route with measurable configured caps. |
| Frontier or high-stakes | Material conflict analysis, complex synthesis, or policy-required escalation | Hosted egress requires explicit approval policy | Selected only after the materiality gate and only for the bounded ledger projection. |

Routing policy names capabilities and route identifiers. It never names a required provider or model default.

An adapter records its actual provider and model in `ModelRouteDecision`. That runtime fact does not become framework policy.

This permits local Qwen-class models, low-cost DeepSeek-class, Kimi-class, or GLM-class APIs, and frontier Claude-class models. These names are compatibility examples only.

If a selected route is unavailable, the stage emits `RER-ROUTE-UNAVAILABLE`. The runtime does not silently select a cheaper, weaker, or more permissive route.

### Hard Budget Contract

Every run contains a budget ledger. Each dimension has an explicit `configured` or `unconfigured` state.

| Dimension | Required accounting | Hard enforcement |
| --- | --- | --- |
| Model requests | Aggregate and per-stage request occurrences | Reserve one occurrence before dispatch. Refuse when no request remains. |
| Input tokens | Prompt tokens after canonical stage projection | Count or quote before dispatch. Refuse if the selected adapter cannot measure a configured cap. |
| Output tokens | Declared maximum and provider-reported completion tokens | Reserve the declared maximum. Reject output that violates the provider contract. |
| Cache tokens | Read and write tokens as separate counters | Debit provider-native cache counters when measurable. Preserve `unmeasured` otherwise. |
| Provider-native credits | Native request credits by adapter and aggregate | Require a quote or bounded native unit before dispatch when configured. |
| Monetary cost | Currency, minor-unit scale, price-policy digest, reservation, and debit | Refuse without a measurable quote and usage mapping when configured. |
| Web calls | Acquisition attempts, redirects, and browser operations | Reserve each counted call before dispatch. Redirect counting is adapter-declared. |
| Source bytes | Raw, decoded, normalized, and retained bytes | Enforce streaming limits before complete buffering. Record each byte class separately. |
| Wall time | Run deadline and stage deadlines | Cancel at the earliest active deadline and record unresolved work. |
| Retries | Per-stage and aggregate retries by failure class | Retry only eligible transport failures with the same occurrence identity. |
| Concurrency | Aggregate workers plus per-adapter limits | Acquire deterministic leases before work starts. Refuse or wait within the wall-time budget. |

Operational dimensions require configured bounds before their related stage can run. Token, credit, and monetary measurement may remain explicitly unconfigured.

A configured monetary or token cap requires adapter support during preflight. An unsupported or unverifiable cap refuses before dispatch with `RER-BUDGET-UNMEASURABLE`.

An unconfigured dimension produces `measurementStatus: unmeasured`. It never emits zero, `within-budget`, or an inferred estimate.

Budget reservations use the worst allowed request size and declared provider price. Final usage receipts debit measured usage and release unused reservation.

### Content Addressing, Reuse, And Resume

- Compute each stage input fingerprint from canonical input record digests, policy digest, adapter capability digest, schema version, and implementation version.
- Exclude secrets, credential values, transient paths, timestamps without semantic meaning, and process identifiers from fingerprints.
- Reuse only an accepted `StageReceipt` whose input fingerprint and freshness predicates still match.
- Start no provider request when an accepted exact-fingerprint output already exists.
- Use the same request occurrence identity for a bounded retry. Append one receipt per attempt.
- Use provider idempotency keys when supported. Use a local occurrence lock when the provider lacks that feature.
- Treat timeout without a terminal provider receipt as unresolved. Resume the same occurrence rather than authoring a second logical result.
- Invalidate only the changed record and descendant stages in the deterministic DAG.
- Preserve old manifests and outputs after invalidation. Mark them stale through new records.
- Apply source freshness policy before reusing acquired content. A matching content hash does not prove currentness.
- Seal publication through an atomic manifest write after deterministic validation succeeds.

### Fresh-Context Stage Boundaries

Each stage receives a new context containing only its input manifest, required records, policy excerpt, schema, and remaining budget.

No stage inherits a chat transcript or prior provider conversation. The stage receipt stores a context-manifest digest and bounded byte count.

Large source bodies remain in the artifact store. Model stages receive bounded excerpts with source and selector identities.

Compaction may shorten a stage projection, but it cannot remove material claims, conflicts, citations, policy, or budget state.

### Evidence Admission And Coverage

- A claim starts as `proposed` and cannot become supported from model confidence alone.
- A supporting link must resolve its selector against immutable normalized source bytes.
- The excerpt digest must match the selected bytes.
- Citation support must cover the claim's subject, qualifier, time range, and material assertion.
- A source's authority class and freshness remain visible in the evidence link.
- Missing evidence creates a coverage gap. It does not create a negative claim.
- Stale evidence remains citable only when publication policy permits an explicit stale label.
- Conflicting evidence creates a `ConflictSet`. Synthesis must disclose every material open conflict.
- Unsupported material claims block publication.
- Non-material unsupported statements must be removed or labeled as interpretation under publication policy.
- Coverage is computed from required question dimensions and material claims. It is not a model-authored percentage.

### Privacy, Security, And Consequence Boundary

- Require every question and source to carry `public`, `internal`, `confidential`, or `restricted` classification.
- Require project policy to map each classification to allowed acquisition and model routes.
- Refuse a missing classification or missing route-policy mapping.
- Keep provider credentials in host-owned secret storage or process injection. Store only credential reference identifiers and config digests.
- Pass prompts and source content through protected input files or standard input. Do not place them in command arguments or telemetry.
- Treat every acquired byte as untrusted data, including text that resembles instructions, tool calls, or policy.
- Separate system policy, task instructions, source excerpts, and output schema in the adapter request.
- Never allow source text to alter the plan, route, budget, tool set, publication target, or consequence boundary.
- Parse model output against a closed schema. Reject unknown executable fields and malformed citations.
- Deny model-originated URLs, shell commands, tool requests, and provider switches.
- Apply retention and cache policy by classification. Restricted content may require encrypted storage or no retained body.
- Record source provenance, acquisition method, publisher, time, content digest, and freshness policy.
- Emit artifacts for human or host consumption. Do not execute trades, deployments, messages, purchases, approvals, or account changes.

### Publication And Result Contract

Publication requires all mandatory stages to have accepted receipts. It also requires a deterministic validation receipt bound to the exact artifact digest.

The published artifact contains:

- The normalized research question and declared scope.
- A synthesis or ledger-only body allowed by the question contract.
- A citation index that resolves every published claim.
- Source provenance and freshness labels.
- Material conflicts and unresolved coverage gaps.
- Method, policy, route-class, and budget summaries.
- Limitations and an explicit no-direct-action statement.
- The sealed run-manifest identity.

The host bridge emits a standard Bubbles result envelope with artifact and manifest evidence references. It cannot certify a spec or mutate `state.json`.

## Concrete Implementations

### Deterministic Filesystem Runtime

- Store records by digest under a run-owned content-addressed root.
- Use atomic creation and immutable permissions for accepted objects.
- Maintain append-only event and receipt ledgers.
- Use a sealed manifest as the only publication pointer.
- Keep the storage contract replaceable by another immutable artifact store.

### Local OpenAI-Compatible Provider Adapter

- Read endpoint and model identifiers from explicit project-owned configuration.
- Require no credential when the configured endpoint contract declares none.
- Declare token counting, cache-token reporting, cancellation, idempotency, and context limits through `capabilities`.
- Return typed `unavailable` when the endpoint or required measurement cannot be established.
- Permit restricted data only when the route policy explicitly identifies the endpoint as local and approved.

### Hosted API Provider Adapter

- Resolve credentials through an external credential reference.
- Declare provider-native usage, credit, price, retention, region, and context capabilities.
- Preflight every configured monetary and token cap before transmitting source-derived content.
- Normalize provider responses into candidate records and `UsageReceipt` values.
- Preserve provider request identity in the private manifest while telemetry uses a sanitized correlation value.

Hosted native protocols may use separate adapters behind the same contract. The foundation does not require a single wire format.

### Bubbles Workflow Bridge

- Expose the runtime as an optional command and capability from existing `analyze` or `discover` work.
- Keep the current phase registry unchanged unless a later approved design proves a distinct phase is necessary.
- Map Bubbles goal, work-boundary, repository-binding, and session-budget facts into the question and run policy.
- Record the command through the existing tool receipt path when it supports a scenario claim.
- Return artifact references through the standard result envelope.
- Leave every current workflow unchanged when research runtime configuration is absent.

### Downstream Research Consumer Bridge

- Allow Research Lab to map its own question, source, and publication formats into the foundation contracts.
- Keep its schedulers, UI, domain scoring, and publication locations downstream-owned.
- Allow other products to implement the same bridge without importing Research Lab concepts.
- Require downstream bridges to consume sealed artifacts rather than private stage transcripts.

### Variation Axes

| Axis | Options | Foundation ownership |
| --- | --- | --- |
| Model execution | Deterministic only, local model, low-cost hosted, frontier hosted | Foundation resolves eligibility. Adapters own protocol details. |
| Provider protocol | Local OpenAI-compatible, hosted OpenAI-compatible, hosted native API | Adapter-owned. |
| Source acquisition | Repository, local file, bounded HTTP, browser-assisted, project adapter | Foundation owns provenance and budgets. Adapters own transport. |
| Data classification | Public, internal, confidential, restricted | Foundation owns required classification and policy checks. |
| Materiality | Routine, material, high-stakes, consequentially prohibited | Foundation owns risk-gate outcomes. Projects define domain thresholds. |
| Storage | Local content-addressed files, immutable object store, host artifact service | Foundation owns identity and immutability. Adapter owns storage protocol. |
| Synthesis policy | Ledger-only, local synthesis, hosted synthesis, frontier escalation | Question and route policy own selection. |
| Publication | Standalone artifact, Bubbles envelope reference, downstream product import | Bridges own destination mapping. |
| Usage accounting | Native measured, derived from trusted provider receipt, explicitly unmeasured | Foundation owns truth labels and hard-cap admission. |
| Retention | No body retention, bounded cache, policy-retained immutable source | Project policy owns duration. Foundation enforces the decision. |

## Configuration Contract

Project configuration gains one optional top-level `researchRuntime` block. Absence means the capability is disabled and changes no existing command or workflow.

The block declares:

- Schema version and enabled command surface.
- Source adapters and allowed source classes.
- Model route identifiers and adapter references.
- Route capability declarations and data-classification eligibility.
- Materiality escalation rules.
- Explicit budget state for every dimension.
- Artifact-store adapter and retention policy.
- Publication profiles and allowed bridge identifiers.
- Telemetry posture and redaction policy.

Configuration stores environment variable names or host credential references. It stores no endpoint secret, token, password, or decrypted value.

No route is selected by list order alone. Policy conditions must resolve exactly one eligible route or emit `RER-ROUTE-AMBIGUOUS`.

## Observability And Sanitized Receipts

### Metrics

- Runs started, completed, blocked, cancelled, and resumed.
- Stage duration and status by stage class.
- Acquisition calls and byte classes.
- Model request counts and measured token classes.
- Measured provider credits and monetary minor units by configured currency.
- Cache hits, misses, reused bytes, and avoided provider requests.
- Claims proposed, admitted, supported, contested, and unsupported.
- Evidence-link admission failures and citation-validation failures.
- Conflict sets opened, resolved, and disclosed.
- Coverage gaps and materiality-gate outcomes.
- Budget reservations, refusals, exhaustion, and unmeasured dimensions.

### Trace And Log Fields

Receipts may expose opaque run correlation, stage identifier, adapter class, route class, status, duration, counts, digests, and error code.

Telemetry must not contain:

- Question text or decision context.
- Source text, excerpts, titles, URLs, or query strings.
- Claim text or synthesis text.
- Prompts, completions, embeddings, or provider response bodies.
- Headers, cookies, credentials, credential references, or endpoint values.
- Private artifact paths or downstream publication destinations.

Private manifests may retain required provenance under classification policy. Their telemetry projection uses opaque correlation identifiers.

## Failure Taxonomy And Recovery

| Code | Condition | Recovery rule |
| --- | --- | --- |
| `RER-QUESTION-INVALID` | Required question field or boundary is missing. | Correct the question contract and create a new question identity. |
| `RER-PLAN-NONDETERMINISTIC` | The same inputs produce a different plan digest. | Refuse and treat the planner as defective. |
| `RER-ROUTE-NONE` | No route satisfies classification, materiality, capability, and budget policy. | Revise explicit policy or provide an eligible adapter. |
| `RER-ROUTE-AMBIGUOUS` | More than one route remains without a deterministic tie rule. | Correct route policy. Do not pick by order. |
| `RER-ROUTE-UNAVAILABLE` | The selected adapter cannot preflight or dispatch. | Record the refusal. Resume after the same route becomes available or policy changes. |
| `RER-BUDGET-UNMEASURABLE` | A configured token, credit, or monetary cap cannot be measured. | Refuse before dispatch. Configure measurable accounting or mark the dimension unconfigured. |
| `RER-BUDGET-EXHAUSTED` | A reservation would exceed a hard limit. | Stop the affected stage and preserve resumable state. |
| `RER-ACQUISITION-FAILED` | A bounded source operation fails. | Retry only eligible transport failures within the same occurrence and retry budget. |
| `RER-SOURCE-LIMIT` | Calls, redirects, bytes, or deadline exceed policy. | Cancel acquisition and retain a failed receipt without partial admission. |
| `RER-SOURCE-UNTRUSTED` | Provenance, classification, or source policy rejects the source. | Exclude the source and recompute coverage. |
| `RER-EXTRACTION-INVALID` | Extraction output fails schema or selector validation. | Reject the candidate output. A bounded same-route retry may run when policy permits. |
| `RER-CLAIM-UNSUPPORTED` | A material claim has no admitted supporting evidence. | Block publication until evidence changes or the claim is removed. |
| `RER-EVIDENCE-CONFLICT` | Material evidence remains contradictory. | Require disclosure, frontier review, human review, or refusal according to materiality policy. |
| `RER-COVERAGE-INCOMPLETE` | Required question dimensions lack admissible evidence. | Publish only if the question explicitly permits a labeled incomplete artifact. |
| `RER-ESCALATION-REQUIRED` | Materiality policy requires a stronger route or human review. | Refuse weaker synthesis. Resume after the required route or review is available. |
| `RER-MODEL-OUTPUT-INVALID` | Model output violates the closed schema or instruction boundary. | Reject output and debit actual usage. Never repair it silently into acceptance. |
| `RER-VALIDATION-FAILED` | Identity, citation, privacy, coverage, conflict, or budget validation fails. | Preserve the candidate and findings. Do not seal publication. |
| `RER-PUBLICATION-CONFLICT` | The target identity already points at different bytes. | Refuse overwrite and preserve both manifest identities for diagnosis. |
| `RER-RESUME-INPUT-DRIFT` | Resume inputs differ from the stored fingerprint. | Create a new descendant plan and invalidate only affected stages. |
| `RER-INTERNAL` | The runtime violates its own contract. | Stop the run, preserve sanitized diagnostics, and route a framework defect. |

Only transport and schema-repair classes may consume retries. Evidence gaps, policy refusals, budget exhaustion, and material conflicts are not retry loops.

## Testing And Validation Strategy

### Contract Tests

- Validate every record schema and canonical identity with key-order and line-ending variations.
- Prove that set-valued order changes do not alter identity.
- Prove that semantic field changes do alter identity.
- Reject secret-bearing fields in manifests, receipts, telemetry, and cache keys.
- Reject producer-declared support, coverage, and publication eligibility without derived records.

### Adapter Contract Tests

- Run the same capability, preflight, quote, invocation, usage, cancellation, and error corpus against each provider adapter.
- Prove that a configured unmeasurable token or monetary cap refuses before provider dispatch.
- Prove that absent measurement produces `unmeasured`, not zero.
- Prove that endpoint and credential values never enter output or telemetry.
- Prove local and hosted adapters produce the same normalized candidate and usage shapes.

### Determinism And Resume Tests

- Run the same question and policy twice and assert one plan digest.
- Resume after every stage boundary and compare the final manifest bytes with an uninterrupted run.
- Repeat an accepted exact-fingerprint run and assert zero new web or model calls.
- Change one source, route policy, schema, or freshness predicate and assert exact descendant invalidation.
- Kill a provider attempt before its terminal receipt and assert one unresolved occurrence with no duplicate accepted output.
- Run concurrent identical invocations and assert one authoring occurrence plus deterministic reuse.

### Evidence Quality Tests

- Mutate a citation selector and assert deterministic validation fails.
- Add an unsupported material sentence and assert publication fails.
- Supply supporting and rebutting sources and assert one disclosed `ConflictSet`.
- Supply only stale evidence and assert the configured stale behavior.
- Supply missing evidence and assert an incomplete coverage outcome rather than a negative claim.
- Inject source text that requests tools, route changes, or policy changes and assert it remains inert data.

### Budget And Fault Tests

- Exercise every budget at one unit below, exactly at, and one unit above its limit.
- Verify reservation and debit behavior after provider errors, cancellation, timeout, and malformed usage.
- Verify retries retain occurrence identity and stop at per-stage and aggregate caps.
- Verify concurrency leases cannot exceed the configured aggregate.
- Verify streamed acquisition stops before retaining bytes beyond its limit.
- Verify provider over-reporting cannot convert an exceeded cap into success.

### Integration Tests

- Invoke the standalone runtime with no configuration and assert an explicit disabled result.
- Invoke the Bubbles bridge and assert existing workflows remain byte-identical when the capability is absent.
- Map a sealed artifact into a Bubbles result envelope without changing certification state.
- Run a downstream bridge fixture with no Research Lab concepts in foundation records.
- Validate release-manifest, capability-ledger, CLI-risk, and generated-check registration after implementation.

## Shadow Evaluation And Acceptance Metrics

Shadow mode runs beside current research work. Its output cannot replace the current publication path during evaluation.

| Metric | Acceptance threshold | Proof shape |
| --- | --- | --- |
| Material claim citation coverage | 100 percent | Every material published claim resolves at least one admitted supporting `EvidenceLink`. |
| Broken citation publication | 0 | Mutation corpus changes selectors, source bytes, and excerpt digests. Every mutation blocks publication. |
| Unsupported material claims | 0 | Deterministic validator rejects injected unsupported claims. |
| Material conflict disclosure | 100 percent on the approved conflict corpus | Every corpus conflict produces a disclosed open or resolved `ConflictSet`. |
| Missing and stale state honesty | 100 percent on state matrix | No missing or stale case renders as current, supported, or zero. |
| Exact replay provider calls | 0 new calls | A completed identical run reuses accepted receipts and emits a reuse record. |
| Resume equivalence | Byte-identical terminal manifest | Every stage-boundary interruption resumes to the uninterrupted manifest. |
| Hard-budget overrun acceptance | 0 accepted overruns | Boundary and provider-overreport tests reject every exceeded configured cap. |
| Unmeasurable configured dispatch | 0 dispatches | Adapter spies observe no call after `RER-BUDGET-UNMEASURABLE`. |
| Telemetry content leakage | 0 source, prompt, claim, endpoint, or secret matches | Canary corpus scans every emitted metric, trace, log, and receipt projection. |
| Consequential action attempts | 0 | Capability and command tests reject every action-bearing model field or bridge request. |
| Provider portability | One local and one hosted adapter pass the same contract suite | Shared adapter corpus and normalized output comparison. |

The owner records domain-specific quality thresholds before shadow promotion. Cost and quality reports remain separate so lower cost cannot hide weaker evidence.

## Migration / rollout

- Publish this proposal and its companion proposal through one owner-controlled index update. This invocation intentionally leaves [`INDEX.md`](INDEX.md) unchanged.
- Land SCOPE-1 as schemas, deterministic planning, identity, storage, validation, and hermetic tests. No provider call is available at this point.
- Land SCOPE-2 with one local and one hosted adapter behind explicit project configuration. The command remains disabled by absence.
- Land SCOPE-3 with security, evidence-quality, budget-boundary, resume, and prompt-injection tests.
- Land SCOPE-4 with the standalone CLI, optional Bubbles bridge, downstream bridge contract, sanitized observability, and documentation.
- Run shadow evaluation against an approved corpus. Store artifacts separately from current publication outputs.
- Promote only after every acceptance metric has a current execution receipt and owner review.
- Keep existing workflows, adapters, usage measurement, model floors, and G128 behavior unchanged throughout migration.
- Register the shipped capability in the capability ledger only when a real consumer exists.

## Alternatives & tradeoffs

### A1 - Build a Research Lab-specific brief generator

Rejected. It would solve one publication flow and make the downstream product the framework's hidden foundation.

### A2 - Extend the existing judge adapter

Rejected. Judge output is one score and verdict. Research requires source, claim, evidence, conflict, budget, resume, and publication lifecycles.

### A3 - Extend only the tool-call receipt schema

Rejected. Command receipts should remain evidence about execution. Adding domain claims and sources would mix two different authorities.

### A4 - Use one frontier model for every stage

Rejected. This removes deterministic controls, increases egress and cost, and weakens selective resume.

### A5 - Use local models for every semantic stage

Rejected as a universal policy. Local execution may satisfy privacy but cannot prove adequate capability for every material question.

### A6 - Let adapters retry through alternate providers

Rejected. A silent provider switch changes privacy, quality, price, and evidence provenance after policy resolution.

### A7 - Store only the final narrative

Rejected. It prevents exact citation validation, contradiction disclosure, cost attribution, and selective invalidation.

### A8 - Add a mandatory `research` workflow phase

Rejected for the foundation. Existing `analyze` and `discover` phases can consume an optional bridge without changing every mode.

## Risks & mitigations

- **R1** The record graph adds substantial implementation surface -> Keep each record immutable, schema-bound, and independently testable.
- **R2** Content addressing may reuse stale research -> Apply freshness policy before cache admission and include freshness predicates in stage fingerprints.
- **R3** Provider usage fields differ -> Normalize only measured native fields and preserve unsupported dimensions as `unmeasured`.
- **R4** Monetary reservations may use stale prices -> Bind every quote to a price-policy digest and expiry. Refuse an expired configured quote.
- **R5** Model routing may become a disguised provider default -> Require exactly one policy match and reject order-based selection.
- **R6** Prompt injection may cross stage boundaries -> Pass source content only as untrusted records and reject model-originated control fields.
- **R7** Citation presence may be mistaken for citation support -> Validate selectors and material semantics separately before publication.
- **R8** Conflict detection may overstate semantic disagreement -> Preserve conflict type, evidence, and materiality. Allow deterministic disclosure without forced resolution.
- **R9** Fresh-context stages may omit necessary evidence -> Bind each context projection to a manifest and test required-field completeness.
- **R10** Concurrent runs may duplicate paid authoring -> Use deterministic run identity, occurrence locks, provider idempotency, and accepted-receipt reuse.
- **R11** Downstream bridges may bypass the validator -> Permit publication only from a sealed manifest carrying a valid deterministic validation receipt.
- **R12** Telemetry may leak sensitive content through labels -> Use closed low-cardinality fields and canary scans across every telemetry projection.
- **R13** Shadow output may be treated as authoritative -> Mark shadow artifacts in the manifest and deny current publication targets.
- **R14** New framework dependencies may reduce portability -> Select the implementation language after a dependency and macOS/Linux portability proof.

## Complexity Tracking

| Deviation from the simpler approach | Simpler alternative | Why rejected |
| --- | --- | --- |
| Eleven typed records | Save a transcript and final answer | A transcript cannot derive support, conflicts, usage, or exact resume state. |
| Deterministic stage DAG | Run one agent prompt | One prompt cannot isolate failures, reuse accepted work, or enforce stage budgets. |
| Separate execution and domain receipts | Put claims into `tool-calls.jsonl` | Execution evidence and research evidence have different identities and consumers. |
| Provider capability negotiation | Assume a common API shape | Token, cache, cost, retention, cancellation, and idempotency differ by provider. |
| Pre-dispatch budget reservations | Check totals after completion | Post-run checks cannot enforce a hard cap. |
| Content-addressed artifact storage | Overwrite a mutable run directory | Mutable output breaks citation identity, replay, and audit history. |
| Classification and materiality route policy | Select the cheapest available model | Price alone cannot decide privacy, capability, or consequence risk. |
| Optional bridges | Embed runtime logic in workflows and products | Embedding would force unrelated consumers to share one orchestration and publication model. |

## Acceptance criteria (when implemented)

- The framework defines and validates every record and canonical identity named in this proposal.
- The stage graph executes in the declared order and emits one earned receipt per attempt.
- The deterministic plan is byte-stable for identical question, policy, budget, and version inputs.
- One local OpenAI-compatible adapter and one hosted adapter pass the same provider contract suite.
- No provider or model name appears as a required routing default.
- Every configured measurable cap is reserved before dispatch and cannot be exceeded by an accepted stage.
- A configured unmeasurable token, credit, or monetary cap refuses before provider dispatch.
- An unconfigured usage dimension is reported as `unmeasured`, never zero.
- Identical accepted input produces no duplicate web acquisition or model authoring.
- Resume after each stage boundary produces the same sealed manifest as uninterrupted execution.
- Changed input invalidates only its dependent stage closure.
- Every material published claim resolves supporting immutable source evidence.
- Missing, stale, conflicting, unsupported, and unavailable evidence remain distinct in records and artifacts.
- Prompt-injection fixtures cannot alter routes, budgets, tools, publication, or consequence boundaries.
- No source text, prompt, claim text, endpoint, or secret appears in telemetry.
- The runtime emits no direct consequential action.
- Existing workflows and projects behave unchanged when `researchRuntime` is absent.
- A Bubbles workflow bridge and a downstream consumer bridge both consume the same sealed artifact contract.
- Shadow evaluation meets every quality, cost, privacy, resume, and portability threshold in this proposal.
- G125, capability-consumer freshness, release-manifest, action-risk, and generated-validation checks pass after implementation and publication.

## Files to touch (on approval)

| Surface | Approval-time change | Owner and enforcement |
| --- | --- | --- |
| `bubbles/schemas/research-run.schema.json` (new) | Define all record, budget, route, artifact, and manifest schemas. | `bubbles.implement`; schema selftests owned by `bubbles.test`. |
| `bubbles/registry/research-stages.yaml` (new) | Define the closed stage vocabulary, classes, transitions, and required receipts. | `bubbles.implement`; registry parity check owned by `bubbles.test`. |
| `bubbles/scripts/research-run.sh` (new) | Implement deterministic plan, run, resume, inspect, validate, and publish operations. | `bubbles.implement`; pre-tool risk gate applies. |
| `bubbles/scripts/research-run-selftest.sh` (new) | Exercise identity, stages, budgets, cache, resume, privacy, injection, and publication. | `bubbles.test`; registered validation check. |
| `bubbles/scripts/research-adapter-contract-selftest.sh` (new) | Run the shared provider adapter corpus. | `bubbles.test`; registered validation check. |
| `bubbles/adapters/research-model/` (new files in an existing adapter root) | Add local OpenAI-compatible, hosted API, and explicit disabled adapters. | `bubbles.implement`; adapter contract selftest. |
| [`bubbles/scripts/cli.sh`](../bubbles/scripts/cli.sh) | Add the optional `research` command family without changing existing commands. | `bubbles.implement`; CLI and risk-registry parity checks. |
| [`bubbles/action-risk-registry.yaml`](../bubbles/action-risk-registry.yaml) | Classify planning and inspection as read-only, local publication as owned mutation, and provider dispatch as external side effect. | `bubbles.implement`; pre-tool risk gate and registry lint. |
| [`agents/bubbles_shared/project-config-contract.md`](../agents/bubbles_shared/project-config-contract.md) | Document the optional `researchRuntime` project contract. | `bubbles.design` for contract reconciliation, then `bubbles.docs` for published guidance. |
| [`bubbles/workflows.yaml`](../bubbles/workflows.yaml) | Declare the optional bridge policy and keep model-floor semantics separate from route selection. | `bubbles.workflow`; workflow registry checks. |
| [`bubbles/workflows/modes.yaml`](../bubbles/workflows/modes.yaml) | Add only approved opt-in tags or mode fields. Do not add a mandatory phase. | `bubbles.workflow`; mode resolver and registry checks. |
| [`bubbles/schemas/workflows.schema.json`](../bubbles/schemas/workflows.schema.json) | Validate any approved workflow bridge fields. | `bubbles.implement`; workflow schema checks. |
| [`bubbles/registry/gates.yaml`](../bubbles/registry/gates.yaml) | Register the next available gate for research contract and publication integrity. | `bubbles.implement`; gate registry and enforcement checks. |
| [`bubbles/registry/validation-checks.yaml`](../bubbles/registry/validation-checks.yaml) | Register generated closure for new selftests and live guards. | `bubbles.implement`; generated-registry consistency checks. |
| [`bubbles/scripts/framework-validate.sh`](../bubbles/scripts/framework-validate.sh) | Invoke the selftests and live integrity guard through the standard framework suite. | `bubbles.implement`; `bubbles.test` verifies invocation reachability. |
| [`bubbles/capability-ledger.yaml`](../bubbles/capability-ledger.yaml) | Add the capability only after a real standalone or bridge consumer exists. | `bubbles.docs`; G127 capability-consumer freshness gate. |
| [`bubbles/release-manifest.json`](../bubbles/release-manifest.json) | Include every shipped runtime, schema, registry, adapter, and test artifact through the normal manifest workflow. | `bubbles.implement`; release-manifest checks. |
| `docs/guides/HYBRID_EVIDENCE_RESEARCH.md` (new) | Document operator configuration, trust boundaries, artifact inspection, and failure codes. | `bubbles.docs`; managed documentation checks. |
| [`docs/CHEATSHEET.md`](../docs/CHEATSHEET.md) | Add concise command and status guidance after the CLI exists. | `bubbles.docs`; documentation consistency checks. |
| [`CHANGELOG.md`](../CHANGELOG.md) | Record the capability only after approved implementation lands. | `bubbles.docs`; release review. |
| [`improvements/INDEX.md`](INDEX.md) | Add IMP-054 with its PROPOSED status in the coordinated publication step requested by the owner. | Publication owner; G125 framework-health evidence lint. |

No file above changes during this proposal invocation. Approval starts planning and implementation through the named owners and gates.
