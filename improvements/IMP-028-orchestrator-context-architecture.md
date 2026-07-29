# IMP-028 — Orchestrator Context Architecture (COST-1 remainder)

**Status:** PROPOSED
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved
**Motivation:** IMP-027 SCOPE-6 shipped context-cost MEASUREMENT and was then blocked on reduction. Re-measured against `5e6fa0d`, the reduction target is unreachable by the work IMP-027 had left, so that remainder is rebooted here with honest scoping.
**Supersedes:** IMP-027 SCOPE-6 (COST-1 reduction only). Everything else in IMP-027 landed.
**Verified gaps addressed:** COST-1

---

## Provenance

Measured on `5e6fa0d` with the tool named in the IMP-027 acceptance criterion:

```
bash bubbles/scripts/effective-bundle-measure.sh agents/bubbles.workflow.agent.md

TOTAL CLOSURE: 505847 bytes across 42 files
TARGET:        160000 bytes
MUST REMOVE:   345847 bytes (68% of the bundle)
```

Cross-checked against `effective-bundle-budget` in the same `framework-validate`
run, which independently reported `bubbles.workflow.agent.md: effective bundle
505847 bytes`.

Eval infrastructure verified separately against `93f3910`, because the first
draft of SCOPE-1 asserted a gap that does not exist:

```
bubbles/scripts/eval-harness-selftest.sh
  'weighted judge passes only with valid behavioral result'  -> exit 0
  'missing weighted judge fails closed'                      -> exit 1, judge-adapter-missing
  'non-JSON (/bin/echo) hollow judge output fails closed'    -> exit 1, judge-malformed-json
  'successful judge provenance is present'                   -> judge.provenance.adapter

bubbles/scripts/eval-heldout-guard.sh — held-out isolation invariant, shipped
grep '"judgeWeight"' bubbles/eval/tasks/*.json — 13 tasks, all judgeWeight: 0
ls bubbles/adapters/ — codeindex, observability (no judge adapter: operator-supplied)
```

Gate-detection contract checked against `d8bba8a`, which produced SCOPE-1a:

```
allowed check types in eval-harness.sh (L109-113)
  file-exists | contains | not-contains | executable-oracle      <- no routing type

task schema fields across bubbles/eval/tasks/*.json
  allowedRoot argv bugfix checks contains feature id judgeWeight oracles
  passThreshold path pattern rationale required schemaVersion taskId
  timeoutSeconds title type weight                                <- no gate field

judge result contract, run_judge() (L781-812)
  required weight status score verdict rubricFindings provenance error
                                                                  <- no gate channel

grep -rl 'gate' bubbles/eval/
  README.md, fixtures/positive/bugfix-output/report.md            <- prose only
```

---

## Why IMP-027 SCOPE-6 could not close

SCOPE-6 named three remaining items. Their combined size does not reach the
target, and the IMP itself conceded this ("the 3-module split is only ~123 KB —
so even once unblocked this alone does not reach target"). The measured
arithmetic:

| Quantity | Bytes | Share of bundle |
|---|---|---|
| Total closure | 505,847 | 100% |
| Target | 160,000 | 32% |
| **Must remove** | **345,847** | **68%** |
| The three named modules combined | 130,972 | 26% |
| Residual after removing all three | 374,875 | 234% of target |

The decisive constraint is not in the shared modules at all:

- `bubbles.workflow.agent.md` **by itself** is 72,882 B — 46% of the entire
  160,000 B target, before a single shared module is loaded.
- The shared closure is therefore 432,965 B and must fit in 87,118 B.
  **That is an 80% reduction of the shared closure**, across 41 files.

A target that requires deleting four fifths of the shared closure is not a
refactor. It is an architecture change: the orchestrator must stop loading a
fixed closure and start resolving context on demand.

---

## Hard prerequisite — the routing eval (R3)

`operating-baseline.md` R3 requires a held-out eval proving the orchestrator
still **detects and routes** every gate before any module leaves the closure.

The IMP-027 golden-task corpus **cannot** satisfy this, and assuming otherwise
was the specific error IMP-027 recorded as a correction. The corpus scores
static artifacts with deterministic check types (`contains`, `not-contains`,
`file-exists`, `executable-oracle`) and never invokes a model, so it cannot
observe routing behaviour at all.

This prerequisite binds **every** reduction item below, including the ones
IMP-027 labelled "not blocked". Any byte removed from the closure can change
what the orchestrator detects; only a routing eval can show it did not.

The machinery to *run* such an eval already exists (see SCOPE-1). Three things
are still missing, and only two of them are operator-supplied:

1. a held-out routing task set (operator),
2. a configured judge adapter (operator, needs credentials),
3. **a gate-detection convention so the eval can report which gate was lost
   (framework — see SCOPE-1a).** Without this the first two cannot be authored
   conformantly, because there is no field in which to declare an expected gate.

Until all three are in place and the eval is green twice consecutively, SCOPE-2
and SCOPE-3 MUST NOT land.

---

## Scopes

### SCOPE-1 — Supply the routing eval (unblocks everything else)

A held-out eval that invokes a model against the orchestrator bundle and asserts
gate detection and routing are unchanged. Must report per-gate detection so a
regression names the gate it lost.

**Corrected after measurement — the framework side is already delivered.** An
earlier draft of this scope claimed it "requires model-invocation infrastructure
the framework does not yet have." That is false, and building against it would
have re-created a working seam. Verified against `93f3910`:

| Capability | Where | State |
|---|---|---|
| Weighted model judge | `eval-harness.sh` `run_judge()`, `judgeWeight`, `judgeTimeoutSeconds` | delivered |
| Judge adapter seam | `BUBBLES_EVAL_JUDGE` -> adapter invoked with `[out_dir, task_path]` | delivered |
| Judge provenance | `judge.provenance` carries `provider`, `model`, `invocationId` | delivered |
| Fail-closed on missing judge | selftest: exit 1, `judge-adapter-missing` | delivered + adversarially tested |
| Fail-closed on hollow judge | selftest: exit 1, `judge-malformed-json` | delivered + adversarially tested |
| Held-out isolation invariant | `eval-heldout-guard.sh` (IMP-100 Phase 6 / IMP-020 S4) | delivered |

What remains is therefore **operator configuration, not framework work**, and the
held-out guard says so explicitly: *"The held-out tasks themselves are
operator-supplied and kept out of the development corpus (like the semantic/judge
adapters, which are operator configuration). This repo ships only the CONVENTION
+ this guard."*

Two operator-supplied inputs are needed:

1. **A held-out routing task set** with `judgeWeight > 0`, one task per gate the
   orchestrator must still detect and route. These MUST NOT be committed to this
   repo — `eval-heldout-guard.sh` hard-fails when a held-out `taskId` also
   appears in `bubbles/eval/tasks` or `bubbles/eval/fixtures`, because a visible
   held-out task is an overfit score. All 13 shipped corpus tasks carry
   `judgeWeight: 0`, so the corpus cannot serve this purpose.
2. **A judge adapter** pointed at by `BUBBLES_EVAL_JUDGE`. **DELIVERED** as
   `bubbles/adapters/judge/ollama.sh` with
   `bubbles/scripts/judge-adapter-contract-selftest.sh` (hermetic 8/8, live
   10/10). Note it ships WITHOUT a `none.sh` sibling, deliberately: the
   observability/codeindex `none` default returns a neutral empty value so
   consumers skip gracefully, but a judge is *required scoring* whenever
   `judgeWeight > 0`, so a neutral default would silently downgrade required
   scoring to a skip. Absence must stay `judge-adapter-missing`. The endpoint is
   operator configuration (`BUBBLES_EVAL_JUDGE_URL`, required and fail-loud), so
   no topology enters this repo.

**RETRACTED — SCOPE-1 is NOT complete. The surrogate-model eval is an invalid
instrument for R3, and no context budget would have fixed it.**

Bubbles runs *inside* a coding agent. When R3 says "the **orchestrator** still
detects and routes every gate correctly," the orchestrator is the coding agent
executing `bubbles.workflow.agent.md`. The eval built here instead asked a
separate model, over HTTP, to read the bundle and list gate ids. That measures
whether *that* model can find gate ids in text — a different model, context
window, system prompt, and tool surface. It is not evidence about the
orchestrator's routing, so its result cannot satisfy R3 no matter how green.

The earlier "green twice consecutively" run is withdrawn as a baseline. Two
identical results proved the surrogate was stable, not that it was measuring the
right subject — the same error as the retracted `b2724bd`, one level up.

Considerable effort went into enlarging the surrogate's context window to fit the
505,847-byte closure. That work was moot: the instrument was invalid at any size.

`bubbles/adapters/judge/routing-ollama.sh` is DELETED. It existed only to serve
this premise, and leaving it would invite a future reader to believe it certifies
R3. The general-purpose `judge/ollama.sh` REMAINS — grading artifact quality with
an optional, fail-closed, operator-configured judge is a legitimate and different
purpose, and nothing in the framework requires it.

**Revised SCOPE-1 acceptance.** R3 has two halves, and only one needs a model:

1. *Module safety* (deterministic, available now) — no reduction may orphan a
   gate. `bubbles/scripts/gate-attribution.sh` decides this exactly, with no
   model and no context ceiling. **DONE.**
2. *Routing behaviour* (needs the real orchestrator) — the actual coding agent
   runs held-out scenarios against the reduced closure and the gates it raises
   are recorded and compared. This is executed **in-session by the orchestrator
   itself**, with the transcript as evidence. No daemon, no adapter, no HTTP.

Half 2 has no automated harness and may not warrant one: a fixture that drives a
coding agent would itself need certification. Recording real in-session runs is
the cheaper and more honest path.

### SCOPE-1a — Ship the gate-detection convention (blocks SCOPE-1)

SCOPE-1 requires the eval to "report per-gate detection so a regression names the
gate it lost." **No mechanism for this exists.** Verified against `d8bba8a`:

| Surface | Observed | Consequence |
|---|---|---|
| Check types in `eval-harness.sh` | `file-exists`, `contains`, `not-contains`, `executable-oracle` | all deterministic text/file assertions; none observes routing |
| Task schema fields | `allowedRoot, argv, bugfix, checks, contains, feature, id, judgeWeight, oracles, passThreshold, path, pattern, rationale, required, schemaVersion, taskId, timeoutSeconds, title, type, weight` | **no `gate` / `expectedGates` field** — an operator cannot even express "expect G021 raised" |
| Judge result contract (`run_judge`) | `required, weight, status, score, verdict, rubricFindings, provenance, error` | **no gate channel**; `rubricFindings` is the only free-form slot |
| Gate convention in `bubbles/eval/` | none (only incidental prose in `README.md` and one fixture `report.md`) | nothing to conform to |

This is framework work, not operator configuration, and it matches the division
of labour the held-out guard states: this repo ships the CONVENTION, the operator
supplies tasks and adapters. The convention for gate detection is missing, so the
operator is currently blocked from authoring a conformant routing task at all.

**Deliberately not implemented in this pass — the contract shape needs an owner
decision first.** Closing it means inventing a *two-sided* interface: a task-side
declaration of expected gates, and a judge-side convention for reporting the
gates actually raised. No adapter exists to validate either half against, so the
only available "proof" would be a fixture written from the same assumption as the
convention. Two artifacts derived from one assumption agreeing is not independent
confirmation — it is the tautological-test failure mode this framework already
gates against elsewhere. Building it blind risks shipping an interface the first
real judge adapter cannot satisfy.

**Owner decision needed before implementation:** does the gate channel ride on
`rubricFindings` (no schema change, weaker typing), or become a first-class
`gatesDetected` field on the judge result (schema change, stronger typing and a
clearer failure message)? Also: is per-gate reporting required for *every* gate,
or only the subset a given held-out scenario targets?

**Acceptance:** a task can declare expected gates; a judge adapter can report
gates raised; the harness reports per-gate pass/fail naming any gate lost; and an
adversarial selftest proves a task fails, naming the specific gate, when a gate
that should be raised is not.

### SCOPE-2 — On-demand module resolution for the orchestrator

Replace the fixed closure with on-demand lookup through the existing MCP
surface, starting with `project-config-contract.md` (59,685 B),
`scope-workflow.md` (48,886 B), and `feature-templates.md` (22,401 B).

This is the only item with enough mass to matter, and it is the one that changes
the loading model rather than shrinking text.

**RETRACTED — the earlier "SCOPE-2 is UNSAFE" measurement was invalid.**

Commit `b2724bd` recorded that dropping `project-config-contract.md` loses 7 of 8
gates. **That conclusion is not supported by its evidence.** Three compounding
defects, found by re-checking the measurement rather than the result:

1. **Bundle truncation.** The adapter capped the prompt at 120,000 bytes, so the
   "baseline" was the agent file plus a *partially truncated*
   `project-config-contract.md` — **2 of 42 modules**. The other 40 never reached
   the model.
2. **BFS backfill.** Excluding a 59,685 B module freed space that pulled in
   `agent-common.md`, `workflow-orchestration-core.md` and
   `completion-governance.md`, which previously did not fit. The two runs
   differed by **four** modules, not one, so the gate delta measured nothing
   attributable to the exclusion.
3. **Silent server truncation.** The loaded model reports `ctx=32768`, not the
   262,144 the model advertises. Ollama clips an over-long prompt from the FRONT,
   which silently removed the output-schema instruction.

The earlier baseline was reproducible (identical twice) but measured the wrong
thing. Determinism proved stability, never validity.

**Newly discovered blocker — R3 is not satisfiable on this hardware today.**

```
full closure          505,879 chars ~= 114,476 tokens
server context        32,768 tokens        (qwen3:30b-a3b, vram 31.7 GB)
over budget by        ~3.5x
harness ceiling       judgeTimeoutSeconds max 300s; a full-closure call exceeds it
```

A single direct call with `num_ctx=131072` did process all 114,476 tokens and
routed `G021 G025 G040 G095`, so it is possible in principle — but two subsequent
900 s attempts timed out, so it is not reliably reproducible here.

**Consequence:** a whole-bundle routing eval cannot certify this agent's closure
until either a larger usable context is available, or the eval is redesigned to
probe per-module rather than loading the closure at once. Until then no reduction
claim about `bubbles.workflow.agent.md` is defensible in either direction.

**SCOPE-2 MEASURED — the proposal is reachability-safe. 130,284 B freed, 0 gates lost.**

The earlier analysis asked the wrong question. SCOPE-2 does not DELETE these
modules; it moves them to on-demand loading. So the hazard is not "is a gate
orphaned" but "is a gate still REACHABLE" — either a carrier stays always-loaded,
or an always-loaded file still points at the on-demand carrier. That is
deterministic, and `gate-attribution.sh --ondemand` now decides it:

```
$ gate-attribution.sh agents/bubbles.workflow.agent.md \
    --ondemand project-config-contract.md,scope-workflow.md,feature-templates.md

bytes freed    : 130284
UNREACHABLE    : 0
REACHABLE VIA POINTER ONLY (7 gates):
  G005 G047 G048 G051 G199 G900  in project-config-contract.md
    <- pointed to by bubbles.workflow.agent.md, docker-lifecycle-governance.md,
       operating-baseline.md
  G037                            in scope-workflow.md
    <- pointed to by agent-common.md, bubbles.workflow.agent.md, and 5 others
VERDICT: every gate stays reachable.
```

Note the number 7 recurs from the retracted `b2724bd` ("loses 7 of 8 gates") but
now means the opposite: seven gates become pointer-reachable, none are lost. The
coincidence is worth naming so a future reader does not conflate the two.

`scope-workflow.md` already has an on-demand twin at
`skills/bubbles-scope-workflow-runtime`, and `bubbles.workflow.agent.md` already
carries a Skills-First Pointers section, so the loading mechanism this scope needs
is present and in use — this is not new machinery.

**What this does and does not establish.** Reachable is NOT the same as followed.
The check proves the agent CAN still get to every gate; it cannot prove the agent
WILL choose to load the module at the right moment. That remains the routing
question, and it still needs the real orchestrator (SCOPE-1 half 2). Treat the
7 pointer-only gates as the eval's highest-priority cases — they are exactly where
a silent regression would hide.

**Arithmetic.** 505,847 - 130,284 = 375,563 B, still above the 160,000 B target.
Combined with the 236,194 B of no-sole-gate candidates the two analyses overlap,
so the totals are not additive; the remaining gap must come from the agent file
itself. The target is not reachable by moving these three modules alone.

The whole-bundle eval cannot run here (114,476 tokens vs a 32,768 window), but
the specific failure R3 guards against — removing a module that carries a gate's
only reference — is decidable **without a model**.
`bubbles/scripts/gate-attribution.sh` computes it exactly:

```
closure modules      42
gate ids referenced  100
sole-carried gates   54

NOT REMOVABLE (sole carrier of a gate reference)
   59401B   6 sole-gates  project-config-contract.md
   48534B   1 sole-gate   scope-workflow.md
   19758B  32 sole-gates  quality-gates.md
   13890B   7 sole-gates  state-gates.md
   ... 8 modules total

CANDIDATES (no sole gate) — 33 modules, 236,194 bytes
   31533B  operating-baseline.md
   23881B  workflow-execution-loops.md
   22839B  critical-requirements.md
   22349B  feature-templates.md
   ...
```

This settles SCOPE-2's three original targets on evidence: **two are
load-bearing** (`project-config-contract.md` solely carries 6 gates,
`scope-workflow.md` 1) and only **`feature-templates.md` is a candidate**.
Sizing by file size was the wrong instinct; the largest file is among the least
removable.

236,194 candidate bytes exist against the 345,847 B that must go, so the target
is not reachable by safe removals alone — the remainder must come from the agent
file itself or from genuine on-demand loading.

**Limits, stated plainly.** This counts gate-id REFERENCES, not semantic
definitions. Zero sole-gates proves no gate id is orphaned; it does NOT prove
routing is unchanged, since cross-module context can still matter. The tool
NARROWS candidates conclusively in the negative direction (a sole carrier is a
hard no) and only narrows them in the positive direction.

**Acceptance (revised):** a module is removable only when (a) `gate-attribution.sh`
reports zero sole-gates for it, AND (b) the routing eval reproduces the baseline
gate set with it excluded and no truncation guard fires. (a) is available today;
(b) awaits adequate context.

### SCOPE-3 — Deduplicate the anti-fabrication doctrine

The doctrine is restated across `critical-requirements.md` (22,883 B),
`agent-common.md` (20,274 B), `quality-gates.md` (19,932 B), and
`evidence-rules.md` (13,046 B) — 76,135 B combined. Collapse to one normative
source plus role deltas.

**Preserve the Honesty Incentive verbatim.** This is the framework's most
safety-critical text; the reduction is secondary to keeping it exact.

**Acceptance:** no normative statement is lost (diff-reviewed clause by clause),
the Honesty Incentive is byte-identical, and the SCOPE-1 eval is green.

---

## Target — decided, and now derived rather than inherited

160,000 B was inherited from IMP-027 and never re-derived. Measuring the whole
fleet rather than one agent shows it is defensible after all:

```
41 agents measured (effective-bundle-budget.sh)
  median            127,513 B
  exceed 160,000 B  13 of 41
  largest           bubbles.workflow 505,847 B (4x median)
  median x 1.25   = 159,391 B  ~= the inherited 160,000 B
```

So the target reads as **"no agent carries more than ~25% above what the median
agent needs"** — a rule with a defensible basis, not an arbitrary number. It is
also not the near-impossible bar IMP-028 first framed: **28 of 41 agents already
comply**. The real shape is 13 outliers, not a fleet-wide rewrite.

**Decision: keep 160,000 B, adopt it incrementally.**

1. The per-agent ratchet (`agent-bundle-budgets.json`) stays BLOCKING, so nothing
   grows while the outliers are worked.
2. 160,000 B stays ADVISORY fleet-wide (`effectiveBundleMaxBytes` unset), exactly
   as `operating-baseline.md` requires: *"Start advisory, reduce via the
   phase-local seam, run the held-out eval, and only then consider making the
   budget blocking."*
3. An agent flips to blocking INDIVIDUALLY once its reduction passes the SCOPE-1
   routing eval with zero gate-detection regression.

This turns one 13-agent big-bang into 13 independently reversible steps. A
regression is then attributable to one agent and revertible on its own, instead
of arriving as a fleet-wide change nobody can bisect.

Rejected alternatives, with reasons:

- **Re-derive from what an orchestrator "demonstrably needs."** Circular —
  demonstrating need requires the routing eval this target is meant to gate.
- **Ratchet only.** Zero risk but never converges; the outliers stay large and
  the cost problem is never actually solved.
- **Tiered targets by role.** An "orchestrators get headroom" exception is the
  loophole that eventually swallows the rule.

---

## Risks

- **R1 — Reduction degrades gate detection.** Inherited from IMP-027 R2 and
  unchanged. Mitigated only by SCOPE-1; there is no deterministic substitute.
- **R2 — Dedup silently drops a normative clause.** `critical-requirements.md`
  and `agent-common.md` are load-bearing for anti-fabrication. Mitigate with a
  clause-by-clause diff review, not a summary read.
- **R3 — Target is wrong.** RETIRED. The target is now derived from the fleet
  distribution (median x 1.25) rather than inherited, and it is advisory until a
  routing eval clears each agent individually, so a wrong target cannot silently
  force an over-cut.
