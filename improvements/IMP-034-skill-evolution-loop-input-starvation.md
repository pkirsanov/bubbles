# IMP-034 — Skill Evolution Loop: close the input-starvation and paraphrase-blindness holes

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** An external proposal ("dreaming" — nightly cross-session transcript distillation into agent memory, per the Karpathy/Anthropic framing) was evaluated for adoption. The evaluation found Bubbles already implements the proposal's hard parts (proposal-first improvement archive under G125, cross-run analysis via `retro-framework-health.sh`, a distill-to-artifact loop via `skillEvolution`, and staleness handling via recency tiers + G127). It also found that Bubbles' own learning loop is **structurally unable to fire**: its input file has no writer and no owner, and its pattern detector cannot match paraphrase. The valuable delta is therefore not a new subsystem — it is repairing the loop already declared in `bubbles/workflows.yaml`.
**Verified gaps addressed:** LRN-1 (learning-loop input has no owner or writer), LRN-2 (pattern detector cannot match paraphrase), DOC-5 (`skillEvolution` publishes a closed-loop claim the implementation cannot satisfy)

## Problem (verified against source)

- **LRN-1 — the learning loop's input file has no writer and no owner.** `bubbles/workflows.yaml` declares `skillEvolution.sourceFile: .specify/memory/lessons.md` as the source of the closed loop. Across `bubbles/`, `agents/`, and `skills/`, the **only** instruction that populates it is one permissive sentence — `agents/bubbles_shared/execution-ops.md` line 7: *"When the repository maintains a lessons-learned memory, agents **may** append concise entries…"*. No agent is required to write it. It is absent from the ownership table in `agents/bubbles_shared/artifact-ownership.md` (which lists only `.specify/memory/retros/*.md` at line 23, owned by `bubbles.retro`). And `cmd_lessons()` in `bubbles/scripts/cli.sh` exposes **no write path** — its subcommands are `compact`, `--all`, and bare (`tail -50`); everything else hits `die`. The framework provides no supported way to add a lesson.

- **LRN-2 — the pattern detector cannot match paraphrase, so the threshold is effectively unreachable.** `normalize_lessons()` in `bubbles/scripts/skill-evolution.sh` strips list markers, collapses whitespace, lowercases, drops lines under 20 characters, then increments `counts[line]++` keyed on the **whole normalized line**, emitting only where `counts[line] >= threshold` (default `3`, from `skillEvolution.triggerThreshold`). Detection is therefore exact-string equality over full lines. Two agents recording the same root cause in different words each score `1`; they never reach `2`, let alone `3`. Because lessons are authored by language models in free prose, the natural-language case the loop exists to serve is the case it cannot detect. Only verbatim-duplicated lines trip it.

- **DOC-5 — the published claim outruns the implementation.** The `skillEvolution` block in `bubbles/workflows.yaml` describes itself as turning "the passive lessons.md log into a closed-loop skill improvement system," with the flow `workflow execution → lessons captured → pattern frequency detected (≥3) → skill proposal generated`. Given LRN-1 and LRN-2, the first arrow has no required actor and the third has no reachable trigger for paraphrased input. `docs/recipes/framework-health.md` repeats the same flow. The claim is not currently supported by the code beneath it.

- **Out of scope but recorded:** no framework surface consumes host session-transcript data. That is correct as a default and MUST remain so (see SCOPE-4, which proposes it strictly as an optional, `none`-default adapter).

## Proposal

### SCOPE-1 — Similarity-based lesson clustering (LRN-2)

- Replace whole-line exact-equality counting in `normalize_lessons()` with deterministic **token-overlap clustering**: normalize to a token set, drop stopwords, and group two lessons when their overlap ratio meets a configured threshold. Keep the existing `triggerThreshold` (cluster **size** still gates a proposal) and add `skillEvolution.similarityThreshold` (recommended default `0.6`) so both knobs are SST-declared in `bubbles/workflows.yaml`.
- **Deterministic, no model call.** The detector stays pure shell/awk. A clustering step that invoked a model would make proposal generation non-reproducible and would import model judgment into a governance input — both unacceptable here.
- `docs/issues/G068-word-overlap-threshold.md` documents an existing word-overlap threshold mechanism in the framework. **Recommendation:** reuse that mechanism rather than introduce a second, differently-tuned similarity notion. Confirm its exact shape at implementation time and align naming; if it proves unsuitable, state why in the implementing commit rather than silently forking a parallel approach.
- Emit the cluster's **representative line plus its variants** in the proposal body, so a human reviewing `skill-proposals.md` can see what was grouped and reject a bad merge.

### SCOPE-2 — Give the input an owner and a supported write path (LRN-1)

- Add a `lessons add` subcommand to `cmd_lessons()` in `bubbles/scripts/cli.sh`, writing one structured entry (problem / root cause / fix / applies-when — the four fields `execution-ops.md` already names). This is the missing supported surface; today the only way to populate the file is an unguided freehand edit.
- Register `.specify/memory/lessons.md` in `agents/bubbles_shared/artifact-ownership.md` as an **append-only, multi-writer** artifact, so it stops being an unowned file that every agent may touch and none is accountable for.
- Change `execution-ops.md` from "agents **may** append" to a **single defined capture point**: agents record a lesson **at result-envelope close**, when a failure was diagnosed and fixed during the run. One structured write at a known boundary — explicitly **not** continuous in-band memory maintenance, which is the split-focus cost this proposal exists to avoid re-creating.
- Scope the obligation honestly: capture applies where a non-obvious failure was actually diagnosed and resolved. A run with nothing to teach writes nothing. Do **not** add a gate that requires a lesson per run — that manufactures filler and poisons the very corpus SCOPE-1 clusters.

### SCOPE-3 — Prove the loop closes, and keep the published claim honest (DOC-5)

- Extend `bubbles/scripts/skill-evolution-selftest.sh` with an **end-to-end reachability case**: seed `lessons.md` with three *paraphrased* statements of one root cause (not verbatim duplicates) and assert a proposal block is emitted. This is the case that fails today and is the regression guard that keeps the loop from silently re-breaking.
- Add an adversarial **near-miss** case: three lessons about genuinely different root causes that share vocabulary MUST NOT cluster. Without it, SCOPE-1 could pass by over-merging.
- Reconcile the closed-loop wording in `bubbles/workflows.yaml` and `docs/recipes/framework-health.md` with whatever actually lands. If a scope is deferred, the prose says so.

### SCOPE-4 — Optional session-store adapter (LRN-3) — RECOMMEND DEFER

- The richer input the "dreaming" proposal is really about is host session data (in VS Code, the Copilot session store the `chronicle` skill queries). That is a **host capability, not a framework one**, so it MUST follow the established optional-adapter pattern: a `sessionStore.adapter` seam with **`none` as the default**, exactly as `codeIndex.adapter` does. The framework never depends on an external session store.
- Adapter output is **proposal-only**, and inherits two non-negotiable constraints: (a) it MUST NOT be citable as execution evidence — transcript text is a record of what a model *said*, not proof a command ran, so admitting it into DoD evidence would launder fabrication past the Execution Evidence Standard; (b) it MUST pass secret redaction before anything derived from a transcript is written to a committed file, because session transcripts are non-retractable and may contain values that leaked into them.
- **Recommendation: defer** until SCOPE-1..3 land and the loop is demonstrably closing on the cheap input. Building a richer intake on top of a detector that cannot cluster and an input nobody writes would add cost without changing the outcome.

### Explicitly rejected (not deferred)

- **Auto-applying distilled changes without human approval.** `skillEvolution` sets `autoCreate: false` / `autoUpdate: false`, and G125 keeps framework mutation proposal-first. Both stay. The external proposal's "auto-apply small fixes unattended" is a doctrine violation, not a tunable setting.
- **A scheduled unattended (e.g. 3am) run.** It adds no capability the on-demand path lacks, and puts an unattended model job on a host whose failure mode under memory pressure is already documented. If a non-interactive trigger is wanted later, prefer an idle/on-demand hook over a wall-clock daemon.

## Migration / rollout

- SCOPE-1, SCOPE-2, and SCOPE-3 are independently landable; recommended order is **1 → 3 → 2** so the detector and its regression guard exist before the corpus starts growing.
- SCOPE-1 is behavior-changing but strictly widening: any cluster the current exact-match detector finds is also found by token-overlap at any threshold ≤ 1.0. No previously-emitted proposal disappears.
- SCOPE-2 is additive at the CLI (new subcommand, existing ones byte-unchanged) and is a policy edit in `execution-ops.md` / `artifact-ownership.md`. No gate is added.
- SCOPE-4 is additive and inert by default (`none`), consistent with `codeIndex.adapter`.
- Downstream repos are unaffected until they populate `lessons.md`; `install.sh` already seeds the file, so no install change is required.

## Risks & mitigations

- **R1 — Over-merging: token-overlap collapses genuinely distinct lessons into one proposal.** → `similarityThreshold` is configurable; the proposal body prints every variant in the cluster; `autoCreate: false` keeps a human between the cluster and any SKILL.md; SCOPE-3's adversarial near-miss case fails the build if shared vocabulary alone is enough to merge.
- **R2 — SCOPE-2 re-creates the split-focus cost it aims to remove.** → Capture is one structured write at a single defined boundary (result-envelope close), not ongoing memory curation, and only when a real diagnosis occurred.
- **R3 — Mandatory capture produces filler that degrades clustering.** → No per-run gate is added; the obligation is conditional on an actual diagnosed failure. Stated explicitly in SCOPE-2 so a later author does not "strengthen" it into a counter.
- **R4 — Transcript-derived content laundered into evidence (SCOPE-4).** → Adapter output is proposal-only and explicitly barred from DoD evidence; the Execution Evidence Standard is unchanged.
- **R5 — Secret leakage from transcript mining (SCOPE-4).** → `none` default, opt-in only, redaction required before any derived text reaches a committed file.
- **R6 — Reusing the G068 word-overlap mechanism proves unsuitable.** → Fall back to a local token-set implementation, and record the reason in the implementing commit so the divergence is deliberate and auditable.

## Acceptance criteria (when implemented)

- **SCOPE-1:** three paraphrased lessons describing one root cause (zero identical lines) produce exactly one proposal block in `.specify/memory/skill-proposals.md`; the block lists the representative line and its variants. Verbatim-duplicate detection continues to work at the same `triggerThreshold`.
- **SCOPE-2:** `bash bubbles/scripts/cli.sh lessons add …` appends one structured entry and exits 0; `lessons`, `lessons --all`, and `lessons compact` behave byte-identically to today; `.specify/memory/lessons.md` appears in the `artifact-ownership.md` table with a named owner and append-only semantics; `execution-ops.md` names one capture point instead of an optional permission.
- **SCOPE-3:** `bash bubbles/scripts/skill-evolution-selftest.sh` passes with both the paraphrase-positive and the near-miss-negative case, and fails if `normalize_lessons()` is reverted to exact-line equality. `bash bubbles/scripts/cli.sh framework-validate` stays green.
- **SCOPE-4 (if undeferred):** with no adapter configured, every code path is a no-op and no session store is contacted; documentation states the evidence-inadmissibility and redaction constraints.
- **Cross-cutting:** `bash bubbles/scripts/framework-health-evidence-lint.sh` reports no findings for this IMP.

## Provenance

Evidence for this proposal is **direct source inspection**, not runtime telemetry. No claim here rests on `.specify/runtime/framework-events.jsonl`, `workflow-runs.json`, or `bubbles/capability-ledger.yaml`; that data was not analyzed, and nothing below is inferred from it.

Files re-checked against source while authoring:

| Source | What it established |
|---|---|
| `bubbles/workflows.yaml` (`lessonsMemory`, `skillEvolution` blocks) | `sourceFile`, `triggerThreshold: 3`, `autoCreate/autoUpdate: false`, `reviewTrigger: workflow_start`, the published closed-loop claim |
| `bubbles/scripts/skill-evolution.sh` (`normalize_lessons()`) | Detection is exact-string equality over whole normalized lines, gated on `counts[line] >= threshold` |
| `agents/bubbles_shared/execution-ops.md` line 7 | The sole, permissive ("may append") population instruction in the framework |
| `agents/bubbles_shared/artifact-ownership.md` line 23 | `lessons.md` is absent from the ownership table; only `retros/*.md` is listed |
| `bubbles/scripts/cli.sh` (`cmd_lessons()`) | Subcommands are `compact` / `--all` / bare; no write or append path exists |
| `bubbles/scripts/framework-health-evidence-lint.sh` | G125's six checks, including the `sources-cited` requirement this section satisfies |
| `improvements/INDEX.md` | Status legend, gap-code legend, and the IMP-034 numbering continuation |
| `docs/issues/G068-word-overlap-threshold.md` | Existence of a prior word-overlap threshold mechanism — cited as a reuse candidate to confirm, not as a verified fit |

## Files to touch (on approval)

`bubbles/scripts/skill-evolution.sh` (SCOPE-1: replace exact-match clustering in `normalize_lessons()`; emit cluster variants) — owner `bubbles.super` / framework-health surface · `bubbles/workflows.yaml` (SCOPE-1: add `skillEvolution.similarityThreshold`; SCOPE-3: reconcile closed-loop wording) — owner `bubbles.super`, registry consistency enforced by `bubbles/scripts/workflow-registry-consistency.sh` · `bubbles/scripts/cli.sh` (SCOPE-2: add `lessons add`) — owner `bubbles.super`, surface parity enforced by `workflow-registry-consistency.sh` + `docs/CHEATSHEET.md` · `agents/bubbles_shared/artifact-ownership.md` (SCOPE-2: register `lessons.md` ownership) — owner `bubbles.super` · `agents/bubbles_shared/execution-ops.md` (SCOPE-2: single defined capture point) — owner `bubbles.super` · `bubbles/scripts/skill-evolution-selftest.sh` (SCOPE-3: paraphrase-positive + near-miss-negative cases) — run by `bubbles/scripts/framework-validate.sh` · `docs/recipes/framework-health.md` (SCOPE-3: align documented flow) — owner `bubbles.docs` · `improvements/INDEX.md` (add the IMP-034 row and the `LRN-*` gap-code legend entry) — required by G125 check 4.
