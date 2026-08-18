# IMP-048 — In-Session Review Loop, Execution Receipts, and Bounded Session Lifecycle

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved
**Motivation:** A single VS Code session ran 2026-08-13 → 2026-08-17 on knb `BUG-014` scope `S5B`. It began as a read-only question ("what is the deploy host and its RAID array doing?"), silently became a multi-day safety-critical delivery, accumulated 93,367 transcript records (>50 MB), re-ran broad validation repeatedly, retried subagents that returned no envelope, and ended by discovering that several green suites never proved the behavior they claimed. Every framework control that could have bounded it was either default-off, bound to a mode this session never entered, or reading a store nothing wrote.
**Verified gaps addressed:** LRN-8, HO-4, PERF-9, EV-11, EV-12, COST-9, WIP-5, GF-15
**Relationship to IMP-047:** ADJACENT, not overlapping. IMP-047 (IN PROGRESS) owns telemetry truth, the single scenario contract, the RED→GREEN outcome engine, proportionate proof, and declared input closure. This proposal owns the EXECUTION and SESSION layer beneath those: how a dispatch result is admitted, how an individual test leaf resumes, whether a declared mutation actually ran, and how a session bounds and reviews itself. Its scopes MUST be reconciled against IMP-047 S-C (outcome engine) and S-D (proportionate proof) before SCOPE-3 and SCOPE-4 land, because those two pairs touch neighbouring surfaces.

## Provenance

Every claim below was verified by reading the named artifact during the audit. Paths are repository-relative to the repo named in the row.

| Input source | Repo(s) | Observation used |
|---|---|---|
| Host chat transcript store (VS Code Copilot debug-log session records) | workspace-local, not committed | One session spanning 2026-08-13 → 2026-08-17 holding 93,367 records (>50 MB); 19 indexed turns; repeated `continue` and `Try Again` turns; two dispatches returning no envelope |
| `.specify/memory/bubbles.session.json` | knb | Newest `turnSnapshots[]` entry `2026-07-29T20:23:14Z` — the August session appended nothing |
| `.specify/memory/lessons.md` | all 8 workspace repos | Header-only (3 lines) in every repo |
| `.specify/memory/skill-proposals.md` | all 8 workspace repos | Absent in every repo — `skill-evolution.sh` has never produced a proposal |
| `.github/bubbles-project.yaml` | all 8 workspace repos | No `mutationExecution:` block in any repo |
| `specs/_ops/OPS-001-home-lab-platform-services/bugs/BUG-014-<deploy-host>-maintenance-findings/scenario-manifest.json` | knb | 28 scenarios declaring `negativeControlMechanism: mutation` with `riskTier: high` |
| `specs/_ops/OPS-001-home-lab-platform-services/bugs/BUG-014-<deploy-host>-maintenance-findings/scopes.md` | knb | Implementation-plan step mandating a full 13-row + baseline re-run after every GREEN step |
| `specs/_ops/OPS-001-home-lab-platform-services/bugs/BUG-014-<deploy-host>-maintenance-findings/state.json` | knb | Scope recorded `not_started` while its test phase was actively executing |
| `bubbles/scripts/phase-coordinator.sh` | bubbles | Occurrence identity, no-replay, and resume exist for phases only |
| `bubbles/scripts/result-envelope-validate.sh` | bubbles | Missing envelopes warn by default; the validator scans agent definitions, not runtime responses |
| `bubbles/scripts/session-cap-guard.sh` | bubbles | Seven `sessionBudget` dimensions; no-op when unset; hard stop is the only outcome |
| `bubbles/scripts/convergence-materiality.sh` | bubbles | Materiality brake present and correct, reachable only through goal-contract runs |
| `bubbles/scripts/mutation-resolve.sh` | bubbles | Adapter defaults to `none`; a configured-but-broken adapter fails loud |
| `bubbles/scripts/test-mechanism-lint.sh` | bubbles | Enforces that a control is DECLARED at the required strength; nothing checks it RAN |
| `bubbles/workflows/modes.yaml` | bubbles | `sessionBudget` declared on `rapid-tool-delivery` only |
| `bubbles/workflows.yaml` | bubbles | `retryPolicy.maxIdenticalFailures: 2` keyed on error context, not failure class |
| `agents/bubbles_shared/workflow-orchestration-core.md` | bubbles | HOST-101 dispatch-failure checkpointing stated in prose with no enforcing script |
| `agents/bubbles_shared/operating-baseline.md` | bubbles | Turn snapshots and periodic trajectory health are `SHOULD`, with no consequence for silence |
| `bubbles/scripts/skill-evolution.sh` | bubbles | `triggerThreshold` 3, `similarityThreshold` 0.6, dismissal file suppresses re-proposal |

## Problem (verified against source)

- **LRN-8 — no in-session review; the learning loop starves.** `bubbles.retro` is post-hoc, `retro-framework-health.sh` writes a proposal after the fact, and `execution-ops.md` records ONE lesson at result-envelope close. There is no surface that reviews a run WHILE it is running. Measured across all eight workspace repos: `lessons.md` is header-only (3 lines) in each, `.specify/memory/skill-proposals.md` does not exist in any, so `skill-evolution.sh` (`triggerThreshold: 3`, `similarityThreshold: 0.6`) has never had input to cluster. Five days of real diagnosis produced zero durable learning.
- **HO-4 — a resultless dispatch is indistinguishable from a failed one.** `workflow-orchestration-core.md` → "Dispatch-Failure Checkpointing (HOST-101)" states in prose that a dispatch which never returned a result must never be counted as a passed phase, but no script, schema, or selftest enforces it. `result-envelope-validate.sh` scans `agents/*.agent.md` for authored envelope blocks; it never inspects an actual `runSubagent` response. `retryPolicy.maxIdenticalFailures: 2` in `bubbles/workflows.yaml` keys retries on error context, so a transport termination and a genuine test failure consume the same budget and receive the same treatment.
- **PERF-9 — accepted test work is re-executed; resume is phase-granular only.** `phase-coordinator.sh` guarantees occurrence identity, no-replay, and resume at the first unresolved occurrence — but only for PHASES. Below a phase, an individual test command has no identity, no recorded outcome, and no content addressing, so a timeout in one leaf forces re-running siblings that already passed on identical bytes.
- **EV-11 — declared mutation controls never execute.** `test-mechanism-lint.sh` requires `riskTier: high` to declare `negativeControlMechanism: mutation`, and `mutation-resolve.sh` resolves the runner from a project-owned `mutationExecution:` block defaulting to `none`. Measured: **zero** of the eight workspace repos declare that block. Every high-risk mutation control in the estate is therefore a declaration whose execution is unproven. The knb `BUG-014` manifest alone declares `negativeControlMechanism: mutation` on 28 scenarios.
- **EV-12 — return-time contracts are proved by post-hoc polling.** A scenario asserting "no success returns before finality" is satisfiable by a test that calls production, sleeps, then polls until the condition becomes true. That test passes whether or not production honored the ordering, because the property is sampled after the window in which it could be violated. This is the concrete shape behind the `S5B` false-green finding.
- **COST-9 — delivery modes are unbounded and cannot roll over.** `sessionBudget` supports seven dimensions and G128 enforces them, but only `rapid-tool-delivery` declares one in `bubbles/workflows/modes.yaml`. Every full delivery mode is unbounded by default. G128's only outcome is a hard `blocked` stop; there is no graceful boundary that preserves work.
- **WIP-5 — long sessions write no session state, so the session controls are inert.** G083 (compaction discipline), G128 (session caps), and `trajectory-inspector.sh --health` all read `.specify/memory/bubbles.session.json`. knb's newest `turnSnapshots[]` entry is `2026-07-29T20:23:14Z`; the 5-day August session appended nothing. Snapshotting is documented in `operating-baseline.md` as what orchestrators "SHOULD" do, with no mechanical consequence for silence.
- **GF-15 — the materiality brake is bound to one mode.** `convergence-materiality.sh` exists precisely to refuse undeclared expansion, stating that a larger plan is a NEW GOAL rather than a fixable obstacle. It is wired into `autonomous-goal`. An ad-hoc session that grows from a read-only question into a delivery scope never encounters it.

## Proposal

### SCOPE-1 — In-Session Review Loop (LRN-8)

A periodic self-review that runs DURING a session, adjusts behavior immediately, and writes almost nothing.

**Core principle: adjustment is free, artifacts are expensive.** Churn control is the default posture, not a later mitigation.

**Trigger** — evaluated at phase boundaries only, never mid-tool. First to fire wins:

| Dimension | Default |
|---|---|
| Turns since last review | 8 |
| Elapsed wall clock since last review | 45 min |
| Retained tool-result bytes since last review | 150 KB |
| Repeated identical failure signature | 2 |
| Dispatch returning no envelope | 1 |
| Budget consumption crossing 50% / 70% / 90% | once each |

Signature and dispatch triggers carry the diagnostic value; turn and time triggers exist so a quiet-but-stuck session still surfaces.

**Three output classes:**

- **Class A — adjust now.** No artifact, no approval, no threshold. The agent changes its own behavior for the remainder of the session and states the change in one line. This is the intended common case.
- **Class B — improvement candidate.** Buffered to `.specify/runtime/session-review.jsonl`. Never written to policy, agent, or gate files. Promoted to `lessons.md` only at session close, only if it recurred at least twice, and only if no Class A adjustment already resolved it. Existing `skill-evolution.sh` clustering then applies unchanged.
- **Class C — user-only action.** Emitted when the remedy is outside agent authority: hand off to a fresh session, approve a scope widening, supply a credential, authorize a destructive step, reduce concurrent sessions, accept a budget rollover. Deduplicated; re-emitted only when the underlying metric worsens by 25%.

**Churn control (explicit, mechanical):**

1. Class A is unlimited and costs nothing.
2. Class B requires in-session recurrence ≥ 2 before it is even a candidate.
3. At most 3 lessons promoted per session; the excess is dropped with a recorded count, never persisted.
4. The review NEVER mutates `bubbles/*`, `agents/*`, or `workflows.yaml` — the same proposal-first boundary `retro-framework-health.sh` already honors.
5. A pattern recorded in `skill-proposals-dismissed.md` is suppressed permanently.
6. A review that finds nothing writes exactly `netEffect: no-adjustment`. Empty is valid and expected.
7. The review is itself budgeted; it must not become the cost it measures.

**Record shape** (`.specify/runtime/session-review.jsonl`, one object per review):

```json
{
  "reviewId": "rev-004",
  "at": "2026-08-17T14:02:11Z",
  "trigger": "repeat-failure-signature",
  "observed": {
    "turnsSinceLastReview": 6,
    "retainedBytesSinceLastReview": 184320,
    "repeatedFailureSignatures": ["aggregate-timeout-240s"],
    "dispatchNoResultCount": 1,
    "budgetConsumedPct": 62
  },
  "classA": [{"change": "focused-row-only-until-frozen-bytes", "appliedAt": "2026-08-17T14:02:11Z"}],
  "classB": [{"pattern": "outer-timeout-below-child-budget", "occurrences": 2, "promoted": false}],
  "classC": [{"action": "handoff-to-fresh-session", "reason": "retained bytes at 62% of cap", "emitted": true}],
  "netEffect": "adjusted"
}
```

**Agent consumption — the half that makes it real.** A review no agent reads is a scoreboard, which is the exact failure `workflow-execution-loops.md` already prohibits for sweeps:

- The orchestrator reads the latest review before selecting the next phase and MUST honor active Class A adjustments.
- Dispatch packets carry `activeAdjustments[]`, so a subagent inherits the correction instead of rediscovering it.
- `RESULT-ENVELOPE` gains an OPTIONAL `reviewCompliance` field naming which adjustments were honored, or why one did not apply.
- An adjustment contradicted twice becomes an automatic Class B candidate.
- Review records compact under G083 like envelopes; only the two most recent stay raw.

Default-off per repo, consistent with G128. `enabled: false` yields a no-op with zero records.

### SCOPE-2 — Dispatch receipts and failure classification (HO-4)

Promote HOST-101 from prose to a mechanism. The parent records a receipt for EVERY `runSubagent` call, independent of what the child returned:

```
occurrenceId · attemptId · packetDigest · agent · startedAt · finishedAt
dispatchStatus · resultEnvelopeStatus · evidenceRefs
```

Closed failure classes with distinct handling:

| Class | Meaning | Action |
|---|---|---|
| `TRANSPORT_TERMINATED` | Host ended the call before a result | Retry ONCE with the identical packet and occurrence id |
| `NO_RESULT` | Returned empty | Record, retry once, never count as execution |
| `NARRATIVE_ONLY` | Prose without a valid envelope | Envelope-only recovery from durable evidence; do NOT re-run tests |
| `ENVELOPE_FAILURE` | Valid envelope reporting failure | Route to the fix loop; NOT a dispatch retry |
| `TIMEOUT` | Command budget exceeded | Resume at the unresolved leaf; do NOT re-run the phase |
| `REPEAT_INFRASTRUCTURE` | Second identical transport failure | Stop with a typed infrastructure `blocked` envelope |

A phase MUST NOT advance on any class other than a valid envelope. Retry budgets become per-class, so an infrastructure fault can no longer consume the budget reserved for genuine defect remediation.

Additionally: flip `result-envelope-validate.sh` missing-envelope handling from advisory to blocking (the `--strict` behavior promised for v6.1 and still opt-in), and add runtime validation of the actual child response, which no current surface inspects.

### SCOPE-3 — Test-leaf occurrence receipts (PERF-9)

Extend the `phase-coordinator.sh` guarantees one level down. Each leaf test command records:

```
testOccurrenceId · candidateDigest · inputPathDigests · environmentFingerprint
timeout · startedAt · finishedAt · exitCode · outputHash
```

Rules, mirroring the phase contract exactly:

- A passing leaf on an identical candidate digest and environment fingerprint is `ACCEPTED` and NOT replayed.
- A changed production owner invalidates only the leaves whose `implementationRefs` cover it.
- A timed-out leaf is `UNRESOLVED` — neither pass nor fail, and never valid RED evidence.
- Resume begins at the first unresolved leaf.
- One full aggregate runs after all focused leaves pass on frozen bytes. A second aggregate on the same digest requires an explicit `rerunReason`.

`rerunReason: integration-order` remains legitimate where composition genuinely exercises behavior no leaf can. The requirement is that the reason be stated, not that reruns be banned.

### SCOPE-4 — Executed mutation receipts for high-risk scenarios (EV-11)

`test-mechanism-lint.sh` today checks that a declaration EXISTS. Add a companion check that the declared mutation actually RAN:

```
scenarioId · mutantId · sourceDigest · testId
expectedFailureSignature · observedFailure · restoredDigest
```

A `riskTier: high` scenario with `negativeControlMechanism: mutation` and no receipt is a finding. `negativeControlFallbackReason` remains the honest escape when a repo has no mutation tooling — the point is that a deliberate fallback stays distinguishable from an unexecuted claim.

Mutation runs MUST occur in an isolated worktree or copied fixture. In a shared working tree the window between mutate and restore is a commit window; a concurrent session has already shipped a neutralized check that way.

### SCOPE-5 — Return-time assertion contract (EV-12)

For any scenario whose `requiredProof` contains an ordering claim ("returns only after", "cannot return before", "remains held until"), the owed proof is:

- Sample the asserted state AT production return, with no sleep and no polling before the assertion.
- Arm a delayed-mutation sentinel and prove it unchanged after a bounded observation.
- Where the contract names a precondition (for example a control written only after an observed state), record every attempt and prove each was preceded by that observation.

A test that polls until the condition becomes true proves eventual convergence, not the ordering contract. `scenario-obligation-lint.sh` already reasons about trait-specific proof obligations; this extends the same idea to ordering traits.

### SCOPE-6 — Bounded session lifecycle and graceful rollover (COST-9)

- Declare a `sessionBudget` default on every delivery mode, not only `rapid-tool-delivery`. Suggested starting values, derived from the measured incident rather than chosen for roundness: `maxWallClockMinutes: 180`, `maxToolCalls: 350`, `maxSingleToolResultBytes: 50000`, `maxCumulativeToolResultBytes: 250000`.
- Add a SOFT boundary at 70%: persist state, emit a Class C handoff recommendation, and continue. The existing hard stop remains at 100%.
- A rollover produces a continuation envelope and a `bubbles.handoff` packet. It MUST NOT mark the underlying spec `blocked` — the work is not blocked, the session is full.

### SCOPE-7 — Session-state liveness (WIP-5)

Make the stores that G083, G128, and trajectory health depend on actually get written:

- Any run exceeding 3 turns MUST have appended a `turnSnapshots[]` entry; silence is a finding rather than a silent pass.
- Session state is keyed by host session id, so two concurrent sessions in one repository cannot overwrite each other's trajectory.
- `doctor` reports a session file whose newest snapshot predates the newest commit as STALE.

A gate reading an empty store must report UNMEASURED, never PASS. This is the same correction `retro-framework-health.sh` already applied to its own gate and capability sections.

### SCOPE-8 — Materiality brake for ad-hoc sessions (GF-15)

Extend `convergence-materiality.sh` beyond goal-contract runs. When a session's first mutable action lands outside the surface implied by its opening request, require an explicit boundary declaration before proceeding. The brake's existing refusal text already frames this correctly: an undeclared expansion is a new goal, and the honest options are to narrow the plan or widen the contract.

This is the control that would have caught "read two days of RAID activity" becoming "deliver S5B containment hardening" at hour one instead of day five.

## Migration / rollout

Each scope is independently landable and additive. Recommended order, dependency-first:

1. SCOPE-2 (dispatch receipts) and SCOPE-3 (leaf receipts) — they remove the largest measured waste and are prerequisites for meaningful review data.
2. SCOPE-1 (review loop) — consumes the signals the first two produce.
3. SCOPE-6 and SCOPE-7 (budgets, liveness) — make the session controls non-inert.
4. SCOPE-4 and SCOPE-5 (mutation receipts, return-time) — raise evidence quality once the execution plumbing is trustworthy.
5. SCOPE-8 (materiality) — last, because its refusal is only tolerable once resume is cheap.

Every new dimension defaults OFF per repo. An unconfigured repository behaves exactly as it does today.

## Risks & mitigations

- **R1 — the review becomes the churn it exists to prevent.** → Class A writes nothing; Class B needs recurrence ≥ 2; ≤ 3 lessons promoted per session; dismissed patterns are permanently suppressed; `no-adjustment` is a first-class outcome.
- **R2 — receipts are gamed by asserting them instead of running the work.** → A receipt carries a candidate digest, an environment fingerprint, and an output hash. `phase-coordinator.sh` already establishes the precedent: an occurrence is resolved by running it, never by asserting it.
- **R3 — leaf-level caching hides a real regression.** → Acceptance is keyed on candidate digest AND environment fingerprint AND owner-path digests. Any change to a declared production owner invalidates the covering leaves.
- **R4 — mandatory mutation blocks repos without tooling.** → `mutationExecution` stays default `none`, and `negativeControlFallbackReason` remains valid. Only an UNDECLARED absence becomes a finding.
- **R5 — strict envelopes break existing agents.** → Ship advisory-with-count for one release, publish the offending agent list, then flip. The `--strict` path already exists and is selftested.
- **R6 — soft rollover fires during legitimate long work.** → The soft boundary only RECOMMENDS; the hard stop is unchanged. A Class C recommendation is never a refusal.
- **R7 — the materiality brake refuses ordinary exploration.** → It binds at the first MUTABLE action, not at reads. A read-only investigation is never refused.

## Acceptance criteria (when implemented)

- No phase advances on a dispatch that returned no valid envelope; each such dispatch has a typed receipt and consumed a transport-class retry only.
- No leaf test re-executes on an unchanged candidate digest and environment fingerprint without a recorded `rerunReason`.
- Every active `riskTier: high` scenario declaring `negativeControlMechanism: mutation` has an execution receipt naming a killed mutant, or a declared `negativeControlFallbackReason`.
- Every ordering-claim scenario asserts at production return with no pre-assertion polling, and carries a delayed-mutation sentinel.
- A session crossing any review trigger has a corresponding review record; each record either applies a Class A adjustment or states `no-adjustment`.
- Promoted lessons per session are ≤ 3, and at least one repository produces its first `skill-proposals.md` entry.
- Any run exceeding 3 turns has session snapshots; a gate reading an empty store reports UNMEASURED rather than PASS.
- A session reaching 70% of any budget dimension emits a handoff recommendation without marking the spec blocked.
- A mutable action outside the opening request's implied surface is refused until the boundary is declared.

## Files to touch (on approval)

`bubbles/scripts/session-review.sh` (new — emit/check/show; owner `bubbles.workflow`), `bubbles/scripts/session-review-selftest.sh` (new — adversarial cases: review that changed nothing while a repeat failure was present, Class B promoted below threshold, Class C re-emitted every turn), `bubbles/scripts/dispatch-receipt.sh` (new — HO-4 classes; owner `bubbles.workflow`), `bubbles/scripts/phase-coordinator.sh` (extend occurrence identity to leaves; owner `bubbles.test`), `bubbles/scripts/result-envelope-validate.sh` (strict missing-envelope + runtime child validation), `bubbles/scripts/test-mechanism-lint.sh` (mutation receipt companion; owner `bubbles.test`), `bubbles/scripts/scenario-obligation-lint.sh` (ordering-trait proof; owner `bubbles.plan`), `bubbles/scripts/convergence-materiality.sh` (ad-hoc binding; owner `bubbles.goal`), `bubbles/scripts/session-cap-guard.sh` (soft boundary; owner `bubbles.workflow`), `bubbles/workflows/modes.yaml` (per-mode `sessionBudget` defaults), `bubbles/workflows.yaml` (per-class retry policy, review trigger defaults), `bubbles/schemas/result-envelope.schema.json` (`reviewCompliance`), `bubbles/registry/gates.yaml` (register the review-discipline and mutation-receipt gates; owner `bubbles.setup`), `agents/bubbles_shared/workflow-orchestration-core.md` (HOST-101 becomes mechanical), `agents/bubbles_shared/operating-baseline.md` (review cadence, snapshot obligation), `agents/bubbles_shared/execution-ops.md` (per-class retry ladder), `skills/bubbles-result-envelope/SKILL.md` and `skills/bubbles-test-integrity/SKILL.md` (author-facing contracts), `improvements/INDEX.md` (row; the `EV-*`/`HO-*`/`GF-*`/`COST-*`/`PERF-*`/`WIP-*`/`LRN-*` legend surfaces already exist and are reused unchanged).

## Downstream consumption

This proposal is the DEPENDENCY ROOT for the per-repository adoption specs. Each downstream repo carries its own spec declaring `dependsOn: IMP-048`, and none of them can complete SCOPE-level work that requires a framework capability before that capability lands here:

| Repo | Spec | Depends on |
|---|---|---|
| knb | `specs/041-bug014-execution-integrity-and-review-adoption` | SCOPE-1..8 |
| quantitativeFinance | `specs/115-execution-receipts-and-session-review-adoption` | SCOPE-1, 2, 3, 4, 6, 7 |
| guestHost | `specs/163-execution-receipts-and-session-review-adoption` | SCOPE-1, 2, 3, 4, 6, 7 |
| smackerel | `specs/113-execution-receipts-and-session-review-adoption` | SCOPE-1, 2, 3, 4, 6, 7 |
| wanderaide | `specs/166-execution-receipts-and-session-review-adoption` | SCOPE-1, 2, 3, 4, 6, 7 |
| research-lab | `specs/021-execution-receipts-and-session-review-adoption` | SCOPE-1, 3, 4, 6, 7 |
| ozhiva | `specs/022-session-state-and-review-readiness` | SCOPE-1, 6, 7 |

A downstream repo MAY land its configuration-only work (declaring `mutationExecution`, recording a `sessionBudget`) before the framework scopes ship; that work is inert but harmless until the consuming gate exists.
