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

The machinery to run such an eval already exists (see SCOPE-1). The gap is the
held-out routing task set and a configured judge adapter, both operator-supplied
by design. Until those are in place and green twice consecutively, SCOPE-2 and
SCOPE-3 MUST NOT land.

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
2. **A judge adapter** pointed at by `BUBBLES_EVAL_JUDGE`, following the same
   pattern as `bubbles/adapters/observability/` and `bubbles/adapters/codeindex/`
   (a `none` default plus a real provider). Requires model credentials, which is
   why it is operator configuration.

No framework change is expected here. If one is discovered, it belongs in its own
scope rather than being folded into this one.

**Acceptance:** the held-out routing suite runs through `eval-harness.sh` with a
configured judge, passes `eval-heldout-guard.sh` isolation, reports per-gate
detection, and is green twice consecutively against the current bundle as the
baseline.

### SCOPE-2 — On-demand module resolution for the orchestrator

Replace the fixed closure with on-demand lookup through the existing MCP
surface, starting with `project-config-contract.md` (59,685 B),
`scope-workflow.md` (48,886 B), and `feature-templates.md` (22,401 B).

This is the only item with enough mass to matter, and it is the one that changes
the loading model rather than shrinking text.

**Acceptance:** `effective-bundle-measure.sh agents/bubbles.workflow.agent.md`
falls below the agreed target with the SCOPE-1 eval green across the change.

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

## Open question for the owner

Is 160,000 B still the right target? It was inherited from IMP-027 and never
re-derived after measurement. Given the agent file alone is 72,882 B, the target
implies an 87,118 B shared closure. Either:

- **keep 160,000 B** and accept that the agent file must also shrink, or
- **re-derive the target** from what an orchestrator demonstrably needs loaded.

The second is more likely to produce a target that survives contact with the
routing eval. This proposal does not assume either; it needs the decision before
SCOPE-2 sizing is meaningful.

---

## Risks

- **R1 — Reduction degrades gate detection.** Inherited from IMP-027 R2 and
  unchanged. Mitigated only by SCOPE-1; there is no deterministic substitute.
- **R2 — Dedup silently drops a normative clause.** `critical-requirements.md`
  and `agent-common.md` are load-bearing for anti-fabrication. Mitigate with a
  clause-by-clause diff review, not a summary read.
- **R3 — Target is wrong.** See the open question. Sizing SCOPE-2 against an
  unvalidated target risks either over-cutting the closure or declaring success
  against a number nobody defends.
