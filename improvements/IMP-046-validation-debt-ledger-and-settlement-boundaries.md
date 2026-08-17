# IMP-046 — Validation Debt Ledger And Settlement Boundaries

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed. NO auto-mutation of `bubbles/*` until approved
**Motivation:** Operator request for fast delivery lanes, change-scoped test selection, and batched heavy validation, audited against merge commit `16ff8bd` on 2026-08-16.
**Verified gaps addressed:** PERF-6, PERF-7, PERF-8, EV-10, COV-19.

| Gap | Statement |
|---|---|
| PERF-6 | Deferral is an intention, not a mechanism |
| PERF-7 | Reuse and skip infer ownership from a basename |
| PERF-8 | Heavy validation is paid per change and never batched |
| EV-10 | A reused result is reported as a fresh pass |
| COV-19 | Nothing forces a deferred obligation to be settled |

## Provenance

Every claim below was opened in the audited tree during this session. Nothing is
relayed from an earlier report.

### Repository evidence

- Reviewed repository root: `/Users/pkirsanov/Projects/bubbles`.
- Reviewed commit: `16ff8bd`, a merge of local `4dccefe` and remote `127a8ce`.
- `git status --porcelain` printed nothing before the audit started.
- Framework version at audit time: v7.28.0.

### Files opened

- `bubbles/scripts/framework-validate.sh`
- `bubbles/scripts/validate-cache.sh`
- `bubbles/scripts/hooks/pre-push.sh`
- `bubbles/scripts/test-impact-plan.sh`
- `bubbles/scripts/test-impact-shadow.sh`
- `bubbles/scripts/phase-relevance-resolve.sh`
- `bubbles/scripts/assurance-resolve.sh`
- `bubbles/scripts/risk-tier-resolve.sh`
- `bubbles/scripts/release-assurance-gate.sh`
- `bubbles/scripts/deploy-manifest-assurance-lint.sh`
- `bubbles/scripts/batch-promotion-lint.sh`
- `bubbles/scripts/tool-log.sh`
- `bubbles/scripts/evidence-receipt-check.sh`
- `bubbles/scripts/goal-boundary-receipt.sh`
- `bubbles/scripts/framework-health-evidence-lint.sh`
- `bubbles/scripts/skill-evolution.sh`
- `bubbles/schemas/tool-call.schema.json`
- `bubbles/registry/micro-fix-packet.yaml`
- `bubbles/registry/gates.yaml`
- `bubbles/workflows/modes.yaml`
- `bubbles/workflows.yaml`
- `BUGS.md` (BUG-033)
- `.specify/memory/open-work.md`
- `improvements/IMP-042`, `IMP-043`, `IMP-044`, `IMP-045`, `INDEX.md`, `TEMPLATE.md`

### Executed measurements

- `grep -cE '^[[:space:]]*run_check[[:space:]]' bubbles/scripts/framework-validate.sh` returned **215**.
- `grep -cE '^[[:space:]]*run_check_self_only[[:space:]]' bubbles/scripts/framework-validate.sh` returned **89**.
- `grep -ln 'registry/gates.yaml' bubbles/scripts/*-selftest.sh | wc -l` returned **13**.
- `grep -ln 'guard-lib.sh' bubbles/scripts/*-selftest.sh | wc -l` returned **23**.
- `grep -ln 'workflows.yaml' bubbles/scripts/*-selftest.sh | wc -l` returned **36**.
- `ls bubbles/scripts | grep -E 'defer|obligation'` returned three guards and their selftests. All three refuse deferral. None records one.
- `grep -n 'inputClosure' bubbles/schemas/tool-call.schema.json` returned nothing. The schema sets `"additionalProperties": false`.

### Mechanisms that already exist

Do not propose building these. The proposal below extends them.

| Mechanism | File | What it already does |
|---|---|---|
| Validation tiers | `framework-validate.sh` | `--tier=core`, `--tier=full`, `--list-tier=` |
| Change-scoped selection | `framework-validate.sh` | `--changed-only` |
| Result cache | `validate-cache.sh` | Opt-in, hermetic selftests only, disabled when `CI` is set |
| Cheap push, heavy CI | `hooks/pre-push.sh` line 42 | `PREPUSH_TIER` defaults to `core` |
| Test-impact planning | `test-impact-plan.sh` | Emits `matchedComponents`, `testCategories`, `alwaysRun`, `fullSuiteRequired` |
| Advisory impact shadow | `test-impact-shadow.sh` | Reports a would-skip set and forbids automatic skipping |
| Phase relevance | `phase-relevance-resolve.sh` | Resolves run or skip per phase from the registry |
| Assurance decision | `assurance-resolve.sh` | Levels `full`, `fast`, `prototype`, with a floor |
| Risk decision | `risk-tier-resolve.sh` | Emits `riskClass` and `minimumAssurance` |
| Fast delivery lane | `modes.yaml` line 287 | `rapid-tool-delivery`, terminal alias `delivered_fast` |
| Micro-fix admission | `micro-fix-admission.sh` + `micro-fix-packet.yaml` | Closed admission conditions, no override flag |
| Evidence input closure | `tool-log.sh` + `evidence-receipt-check.sh` | Hashes declared inputs and reports valid, stale, or unknown |
| Promotion assurance gate | `release-assurance-gate.sh` | Refuses an under-assured spec on a train |
| Deploy assurance lint | `deploy-manifest-assurance-lint.sh` | Requires an assurance level and an evidence digest |

## Problem (verified against source)

### PERF-6 — deferral is an intention, not a mechanism

Every existing mechanism reduces work at the moment of the run. None of them
writes anything down.

- `framework-validate.sh` line 341 prints `SKIP: <label> (tier=core)` and
  increments `skipped_tier`.
- Line 358 prints `SKIP: <label> (--changed-only; …)` and increments
  `skipped_changed_only`.
- Both counters live in the run summary. Neither survives the process.

Three scripts match `defer` or `obligation`. All three refuse deferral rather
than record it:

- `pre-existing-deferral-guard.sh`
- `stale-deferral-lint.sh`
- `scenario-obligation-lint.sh`

No script records a deferred validation obligation. No script forces one to be
settled later. "We will test it eventually" is therefore a sentence, not a
control. That is the gap this proposal closes.

### PERF-7 — reuse and skip infer ownership from a basename

`changed_surface_touches()` at `framework-validate.sh` line 191 derives
ownership as `X-selftest.sh` to `X.sh`, and matches only those two paths.

`validate_cache_key()` in `validate-cache.sh` hashes exactly the same two files
plus the framework version. Registries, schemas, shared libraries, fixtures,
the toolchain, and the platform are all absent from the key.

The blind spot is measurable in the shipped tree:

| Undeclared input | Selftests that read it |
|---|---|
| `bubbles/registry/gates.yaml` | 13 |
| `bubbles/scripts/guard-lib.sh` | 23 |
| `bubbles/workflows.yaml` | 36 |

Edit `bubbles/registry/gates.yaml` today and run with `--changed-only`. All 13
selftests that read it are skipped, because neither the selftest file nor its
same-named subject changed. Run with `--cache` and their stale results are
served as passes.

This is a correctness hole, and it is narrow only because the two mechanisms are
opt-in. Broadening reuse before fixing this converts a narrow hole into the
primary execution path.

### PERF-8 — heavy validation is paid per change, never batched

The cheap-push and heavy-CI cadence is already partly implemented.
`hooks/pre-push.sh` line 42 defaults `PREPUSH_TIER` to `core`, and line 69 tells
the operator that the full release gate runs in CI.

What is missing is the accumulation step. CI runs the full tier per push, so the
heavy pass is still paid per change rather than per batch. There is no executor
that drains accumulated obligations across many changes in one pass. There is
nothing to drain, because nothing is accumulated.

### EV-10 — a reused result is reported as a fresh pass

`framework-validate.sh` line 374 prints:

```
PASS: <label> (cached — script unchanged since it last passed)
```

A cache hit and a real execution both report `PASS`. The parenthetical is prose.
A machine reading the run cannot separate the two. A reused result and a fresh
result are different claims, and the framework's own anti-fabrication posture
says a claim must map to an execution.

The same problem exists in reverse for deferral. A deferred check has no status
word at all, because it is only counted.

### COV-19 — nothing forces a deferred obligation to be settled

There is no boundary at which unfinished validation blocks progress.

- `release-assurance-gate.sh` checks the achieved assurance level against a
  train floor. It never asks whether that level left work unfinished.
- `deploy-manifest-assurance-lint.sh` line 180 reads
  `attestations.assurance.evidenceDigest`, and line 197 refuses only when the
  value is empty. It never binds that digest to a source SHA, an artifact digest,
  or a receipt root. Any non-empty string passes.

A `fast` assurance level is therefore admissible today with no record of what
`fast` skipped. That is exactly the state a debt ledger must replace.

### Blocking prerequisites

Two defects must be fixed before the work below can rest on receipts.

**BUG-033, both facets.** `BUGS.md` line 2067 records that
`deterministic_siblings` in `state-transition-guard.sh` binds `$targets` per
receipt, so an honest re-run over one subject is refused as cloned evidence. The
second facet is that `cmd_parts` unwraps only a bare leading `bash` or `sh`, so
`env VAR=1 node …` and `zsh -c …` resolve to different command families. Any
receipt-identity work inherits a false-accusation failure mode until both are
fixed. The bug is open at this commit.

**Unbound assurance digest.** `deploy-manifest-assurance-lint.sh` accepts any
non-empty `evidenceDigest`. A design that promotes on `fast` assurance must not
rest on a digest bound to nothing.

## Design spine

The three operator asks are safe only when they are paired. Each ask removes
work now. Each pairing forces that work to be done later.

| Operator ask | Mechanism that removes work | Mechanism that forces settlement |
|---|---|---|
| Ship fast with basic validation | Assurance level `fast` through the existing mode machinery | A debt entry naming its settlement boundary |
| Re-run only affected tests | Declared input closure and affected selection | An `alwaysRun` floor plus a debt entry for what was not run |
| Batch heavy validation | Deferral of integration, e2e, stress, load, and security work | A batch executor and blocking boundaries |

Removing the second column without the third is a skip. Removing both is the
current state. The whole proposal is the third column.

## Proposal

### SCOPE-1 — Validation receipts keyed by a declared input closure (PERF-7, EV-10)

Record what was executed. Key the record by a declared, dependency-complete
input closure.

- Declare, per check, the script, the selftest, shared libraries, registries,
  schemas, fixtures, the toolchain version, the platform, and the framework
  version.
- Compute the receipt key over that whole closure, not over two same-named
  files.
- Store the check identity, the command, the exit code, the duration, the output
  digest, and the closure digest.
- Treat an undeclared or unknown input as run-required and reuse-forbidden.
- Replace the derivation in `changed_surface_touches()` with the declared
  closure.
- Replace the derivation in `validate_cache_key()` with the same closure.

Reuse the vocabulary `tool-log.sh` and `evidence-receipt-check.sh` already
established for evidence. Do not reuse their store. A validation receipt and a
DoD evidence receipt answer different questions, and one store answering both
would let a spec claim cite a validator run.

`tool-call.schema.json` sets `"additionalProperties": false` and does not declare
`inputClosure`, so the evidence schema already cannot carry the validation
domain. Fix that schema gap under IMP-044 if it is fixed at all. It is not this
proposal's surface.

### SCOPE-2 — Append-only validation debt ledger (PERF-6, COV-19)

Add one append-only ledger. Every deliberate deferral writes exactly one entry.

Each entry names:

- what was not run, by check identity
- the obligation class, drawn from a closed set: `integration`, `e2e`, `stress`,
  `load`, `security`, `full-suite`
- the change it belongs to, as a source SHA plus a spec or scope reference
- why it was deferred, as a token from a closed set, not free prose
- the settlement boundary that must discharge it

A skip that writes no entry is forbidden. A run that skips work and cannot write
the ledger must run the work instead.

The ledger is append-only. A settled obligation is closed by a new entry that
cites the settling receipt. Rewriting a prior entry is forbidden, for the same
reason `.specify/memory/open-work.md` keeps git history as its audit trail.

### SCOPE-3 — Distinct status vocabulary (EV-10)

Extend the run vocabulary so a reader can separate three different claims.

| Status | Meaning | Today |
|---|---|---|
| `PASS` | The check ran in this session and exited 0 | Also printed for cache hits |
| `REUSED` | A receipt with an unchanged closure was reused, cited by receipt id | Printed as `PASS` |
| `DEFERRED` | The check was not run, and a ledger entry records the obligation | Counted, never named |

Never report `DEFERRED` as `PASS`. Never report `REUSED` without the receipt id.
The existing tier and install-mode `SKIP` lines stay as they are, because a
tier skip in a non-final gate is not a claim about the tree.

### SCOPE-4 — Settlement boundaries where open debt blocks (COV-19)

Open debt is blocking at four boundaries. No override flag exists at any of
them.

| Boundary | Existing host | What it must refuse |
|---|---|---|
| Spec or bug transition to a terminal certified status | `state-transition-guard.sh` | A terminal status while debt for that spec is open |
| Release-train promotion | `release-assurance-gate.sh` | Promotion of a spec with open debt below the train floor |
| Deploy | `deploy-manifest-assurance-lint.sh` | A manifest whose assurance digest does not bind a receipt root |
| Periodic batch boundary | New, see SCOPE-5 | Nothing. It drains debt rather than refusing |

The first three boundaries already exist and already refuse. This scope adds one
predicate to each. It does not add a gate chain.

Bind the deploy digest while doing so. An `evidenceDigest` that binds nothing
proves nothing. A debt design that promotes on `fast` must not rest on it.

### SCOPE-5 — Batch executor (PERF-8)

Add one executor that drains accumulated debt.

- Read every open ledger entry.
- Group entries by obligation class and by affected closure.
- Run each group once, not once per contributing change.
- Write a settling receipt per entry.
- Close each entry with an append that cites its receipt.
- Refuse to close an entry whose receipt is absent, stale, or for another
  closure.

This is the mechanism that replaces per-change heavy runs. It is also the
mechanism that makes "everything still gets tested eventually" checkable, because
an entry that never settles stays visible in the ledger.

### SCOPE-6 — Assurance binding (COV-19)

Bind the ledger to the existing assurance decision. Do not invent a parallel
vocabulary.

| Achieved level | Debt rule |
|---|---|
| `full` | Zero open debt for the scope |
| `fast` | Open debt permitted, and every entry names its settlement boundary |
| `prototype` | Never deployable, unchanged |

`assurance-resolve.sh` and `risk-tier-resolve.sh` keep sole authority over the
level and the floor. This scope adds a debt predicate beside their decision. It
does not re-derive risk, and it does not add a second assurance ordering.

A high or unknown `riskClass` already forces the floor to `full` in
`assurance-resolve.sh`. That escalation therefore already forbids open debt on
high-risk work, with no new rule.

### SCOPE-7 — Express the fast lane through existing modes (PERF-6)

The fast lane already exists. `modes.yaml` line 287 defines
`rapid-tool-delivery` with `terminalAliases: [ delivered_fast ]`, a
`sessionBudget`, and `forceFullDeliveryOnHighRisk: true`.

Extend that lane. Do not add a bypass.

Copy the micro-fix discipline in `micro-fix-packet.yaml` verbatim:

- opt-in per change, never a default
- closed admission conditions, where an unanswered condition is a refusal
- a named set of obligations proportionality may never trade away
- measured before it becomes any default
- `overrideFlag: none`

`rapid-tool-delivery` currently sets `requireNoSkippedTests: true`. Keep that
literal meaning. Under this proposal a deferred obligation is not a skipped
test, because it carries a ledger entry and a settlement boundary. State that
distinction in the mode constraints so the two cannot be conflated later.

## Invariants this proposal must not weaken

State each of these in the implementation, and do not weaken any of them.

1. `test` is in `phaseRelevance.neverSkip` in `modes.yaml` line 79, alongside
   `select`, `bootstrap`, `implement`, `validate`, `finalize`, `docs`, and
   `audit`. This work changes when tests run. It never changes whether they run.
2. One cold, complete gate runs on the exact release candidate. The cache stays
   disabled in CI, as `validate-cache.sh` line 47 already enforces.
3. Nothing is skipped silently. No deferral is reported as a pass.
   Anti-fabrication is unchanged.
4. G127 requires a shipped capability to name real consumers. A selftest
   scheduler is not a production consumer. Ship each capability with the
   consumer that calls it, or do not ship it. `phase-relevance-resolve.sh` and
   `test-impact-plan.sh` are the standing example of the failure mode.
5. Fix the input-closure derivation before broadening any reuse.
6. Fix BUG-033 before any receipt-identity work.

## Sequencing (dependency-ordered)

Land in this order. Each step is a precondition for the next.

| Step | Work | Why it is first |
|---|---|---|
| 0 | Fix BUG-033, both facets | Receipt identity is unusable while honest re-runs are refused as clones |
| 1 | SCOPE-1 declared input closure | Every later step keys on it |
| 2 | SCOPE-3 status vocabulary | `REUSED` must exist before anything reuses |
| 3 | SCOPE-2 ledger | `DEFERRED` must have somewhere to write |
| 4 | SCOPE-4 boundaries | Debt must block before deferral is permitted |
| 5 | SCOPE-5 batch executor | Debt must be drainable before it accumulates |
| 6 | SCOPE-6 assurance binding | Binds the level to the now-working ledger |
| 7 | SCOPE-7 fast-lane extension | Only safe once every step above holds |

Do not reorder steps 4 and 5 ahead of step 3. A boundary that reads an absent
ledger refuses nothing and reports success, which is the fail-open shape this
framework has corrected twice already.

## Risks and mitigations

- **R1 — The ledger becomes a queue nobody drains.** Mitigate with SCOPE-4. Open
  debt blocks certification, promotion, and deploy. An undrained ledger stops
  delivery rather than accumulating quietly.
- **R2 — Deferral becomes the default path.** Mitigate with the micro-fix
  discipline in SCOPE-7. Opt-in per change, closed admission, measured before any
  default. Record the measurement obligation rather than assuming the answer.
- **R3 — A declared closure is incomplete, so reuse serves a stale pass.**
  Mitigate with SCOPE-1's unknown-input rule. An undeclared input forces
  execution. Add a shadow phase that reports proposed reuse before any reuse is
  permitted, matching the posture `test-impact-shadow.sh` already holds.
- **R4 — Receipt identity produces false clone accusations.** Mitigate by
  fixing BUG-033 first. Its verified fix groups targets by command identity
  rather than by receipt.
- **R5 — Two receipt domains merge.** Mitigate by keeping the validation store
  separate from the evidence store. A DoD claim must never cite a validator
  receipt as its own execution.
- **R6 — The batch executor hides a failure inside a large run.** Mitigate by
  requiring one settling receipt per entry. A group that fails settles nothing,
  and every contributing entry stays open.
- **R7 — A new capability ships with only a selftest calling it.** Mitigate with
  invariant 4. G127 already refuses this, and two capabilities in the tree are
  already in that state.

## Acceptance criteria (when implemented)

Each criterion is executable. None asserts a speedup.

1. Editing `bubbles/registry/gates.yaml` and running `--changed-only` executes
   all 13 selftests that read it. Today all 13 are skipped.
2. Editing `bubbles/scripts/guard-lib.sh` and running `--cache` serves zero
   cached results for the 23 selftests that source it.
3. A check whose closure declaration is absent runs, and it is never reused.
4. A cache hit prints `REUSED` with a receipt id. Grep for
   `PASS: .* (cached` returns nothing.
5. A deferral prints `DEFERRED` and appends exactly one ledger entry. Deleting
   the ledger write makes the run execute the check instead.
6. A spec with open debt is refused a terminal certified status, with the
   blocking entry named in the refusal.
7. `release-assurance-gate.sh` refuses promotion of a spec whose open debt sits
   below the train floor.
8. `deploy-manifest-assurance-lint.sh` refuses an `evidenceDigest` that binds no
   receipt root, and a selftest proves the refusal by supplying an unbound
   digest.
9. The batch executor drains N entries in one pass and writes N settling
   receipts. An entry whose receipt is missing stays open.
10. No boundary accepts a flag named `--skip`, `--force`, `--no-verify`, or any
    equivalent. A selftest asserts the absence.
11. Every capability added by this proposal names a non-selftest consumer in
    `bubbles/capability-ledger.yaml`, and G127 passes.

## Measurement requirement

Serial wall-clock for the full suite at this commit is **UNMEASURED** in this
session. The full suite takes a machine-wide lock and roughly thirty minutes,
and it was not run.

IMP-042 recorded three full runs at 1,883 to 2,081 seconds and five core runs at
109 to 111 seconds. Those numbers were measured at commit `09a8fc87`, not at
`16ff8bd`, and the scheduled-invocation count has changed since. Do not reuse
them as this proposal's baseline.

Before any scope here lands, measure and record:

- full-tier wall clock at the landing commit, from at least three runs
- core-tier wall clock at the same commit
- the executed-check set, so the post-change set can be proven identical

After landing, measure and record:

- deferral rate per obligation class
- median time from a debt entry opening to settling
- count of entries that reached a settlement boundary unsettled
- defect escape rate for changes that shipped at `fast` with open debt

Do not assert a speedup anywhere until the first pair exists. Asserting an
improvement without its denominator is the failure OW-014 already records.

## Consolidation with IMP-042

IMP-042 diagnosed part of this problem and is still open on several scopes. The
table below states which of its scopes IMP-046 takes over.

| IMP-042 scope | Disposition | Reason |
|---|---|---|
| SCOPE-2 — Typed Validation Check Registry | **SUPERSEDED by IMP-046 SCOPE-1** | Check identity is a precondition for a receipt key. IMP-046 needs the identity and the closure together, and IMP-042 SCOPE-3 already records that its own receipt work cannot start without it |
| SCOPE-3 — Dependency-Complete Receipts And Affected Execution | **SUPERSEDED by IMP-046 SCOPE-1, SCOPE-3, and SCOPE-5** | This is the same work. IMP-046 adds the ledger and the boundaries that make the reuse safe |
| SCOPE-17 — receipt-reuse bullet only | **SUPERSEDED by IMP-046 SCOPE-1** | "Reuse repo-global receipts only when their input closure is unchanged" is one closure rule, and one closure rule must have one owner |
| SCOPE-6 — Executable Workflow Cursor And Phase Coordinator | **REMAINS with IMP-042** | Resume and phase coordination are a continuation concern, not a validation-debt concern |
| SCOPE-9 — Micro-Fix Packet measurement | **REMAINS with IMP-042**, tracked as OW-015 | IMP-046 SCOPE-7 reuses the packet's discipline. It does not take over the measurement |
| SCOPE-14 — Context And Agent-Prose Cleanup remainder | **REMAINS with IMP-042** | Context economics, unrelated surface |
| SCOPE-17 — transition-check classing and prerequisite edges | **REMAINS with IMP-042** | `BLOCKED_NOT_RUN` and prerequisite edges are transition-guard diagnostics, not deferred obligations |

### Correction to a prior reading

Bounded parallelism is **not** an open IMP-042 scope, and IMP-046 does not
supersede it. The parallelism question was settled by commit `87831b6`,
"IMP-042 SCOPE-4 + SCOPE-18: measure before parallelizing". No SCOPE-4 heading
remains in the proposal file. `bubbles/scripts/parallel-fanout.sh` exists and
implements the phase fan-out DAG contract. Treating parallelism as open work
here would recreate a scope that was deliberately closed.

## Files to touch (on approval)

- `bubbles/scripts/framework-validate.sh` — replace `changed_surface_touches()`
  with the declared closure, add `REUSED` and `DEFERRED`. Owner: framework health.
- `bubbles/scripts/validate-cache.sh` — replace `validate_cache_key()` inputs.
  Owner: framework health.
- New `bubbles/registry/validation-checks.yaml` — check identity and declared
  closure. Owner: framework health.
- New `bubbles/scripts/validation-receipt.sh` — emit and verify a validation
  receipt. Owner: framework health.
- New `bubbles/scripts/validation-debt.sh` — append, read, and settle ledger
  entries. Owner: framework health.
- New `bubbles/scripts/validation-debt-batch.sh` — the batch executor.
  Owner: framework health.
- `bubbles/scripts/state-transition-guard.sh` — add the open-debt predicate at
  terminal certification. Owner: `bubbles.validate`.
- `bubbles/scripts/release-assurance-gate.sh` — add the open-debt predicate at
  promotion. Owner: `bubbles.releases`.
- `bubbles/scripts/deploy-manifest-assurance-lint.sh` — bind `evidenceDigest` to
  a receipt root. Owner: `bubbles.devops`.
- `bubbles/workflows/modes.yaml` — extend `rapid-tool-delivery` constraints.
  Owner: framework health.
- `bubbles/registry/gates.yaml` — register the settlement gates.
  Owner: gate registry owner.
- `bubbles/capability-ledger.yaml` — name a non-selftest consumer per new
  capability, per G127. Owner: framework health.
- `BUGS.md` BUG-033 — fix both facets before step 1. Owner: `bubbles.bug`.

## Assumptions (not verified in this session)

Each item below is an assumption, not a finding. Verify each before the matching
scope lands.

- **A1.** The full suite takes roughly thirty minutes at `16ff8bd`. Not measured
  here. IMP-042's 1,883 to 2,081 second range was measured at a different commit.
- **A2.** No downstream repository currently passes `--changed-only` or `--cache`
  in a blocking path. Only the source tree was inspected.
- **A3.** Adding a predicate to `state-transition-guard.sh` does not disturb its
  existing check ordering. The guard was read only at the BUG-033 region.
- **A4.** `config/release-trains.yaml` can carry a per-train debt policy without
  a schema change. The release-train schema was not opened.
- **A5.** The evidence receipt store and a validation receipt store can coexist
  without a shared reader. No consumer inventory was taken.
