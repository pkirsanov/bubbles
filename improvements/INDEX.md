# Framework Improvement Proposals (IMP) — Index

Improvement proposals are human-reviewed framework-health artifacts governed by
**Gate G125** (`framework_health_evidence_gate`). An IMP records a verified gap
and a proposed remedy; it does **NOT** auto-mutate `bubbles/*`, `agents/*`, or
`bubbles/workflows.yaml`. Implementation flows through the owning agents/gates
named in each proposal's "Files to touch" section.

To add one: copy [`TEMPLATE.md`](TEMPLATE.md) to `improvements/IMP-NNN-<slug>.md`,
fill every `<...>` placeholder, add a row below, and leave **Status: PROPOSED**
until the repo owner approves.

## Status legend

| Status | Meaning |
|---|---|
| `PROPOSED` | Authored, awaiting owner review. No framework files changed. |
| `ACCEPTED` | Owner approved. Implementation may route to the named owners. |
| `IN PROGRESS` | One or more scopes landing. |
| `APPLIED` | All scopes landed and acceptance criteria met. |
| `REJECTED` | Owner declined. Retain the file for audit history. |
| `SUPERSEDED` | Replaced by a later IMP (name it). |

## Gap-code legend

Gap codes group findings by the surface they compromise. Reuse existing codes
where a new proposal addresses the same surface.

| Code | Surface |
|---|---|
| `EV-*` | Evidence integrity — what counts as proof of work |
| `HO-*` | Handoff / dispatch governance — agent-to-agent routing, subagent depth, platform control fields |
| `SEC-*` | Security and supply chain — installer, dependency, scan gates |
| `COV-*` | Coverage measurement — which gates and selftests actually run |
| `COST-*` | Context and token economics — prompt bundle size, cost visibility |
| `PERF-*` | Validation performance — wall-clock cost of the gate chain |
| `REG-*` | Registry consistency — gate bands, generated blocks, surface parity |
| `DOC-*` | Documentation truth — published claims matching implementation |
| `WIP-*` | Work-in-progress durability — unfinished work crossing the session boundary |
| `LRN-*` | Framework self-learning — whether the lessons/skill-evolution loop can actually close |

## Proposals

| IMP | Title | Status | Surface | Gap codes | Date |
|---|---|---|---|---|---|
| IMP-028 | Orchestrator Context Architecture (COST-1 remainder) | CLOSED 2026-07-29 — findings folded into `agents/bubbles_shared/operating-baseline.md` (R3); target unreachable by the proposed reduction, dedup premise measured false | framework-health (G125) | COST-1 (reduction; supersedes IMP-027 SCOPE-6) | 2026-07-28 |
| IMP-030 | Controlled Technical Prose: term registry enforcement + prose-form governance | APPLIED 2026-08-01 — SCOPE-1/2/3/4 landed; SCOPE-5 (Gate G132) DEFERRED under its own entry condition, no gate registered | framework-health (G125) | REG-3, DOC-2 | 2026-08-01 |
| IMP-031 | Feature Reachability: close the orphaned-implementation hole | APPLIED 2026-08-01 — SCOPE-1/2/3/4/5/6/8/9 landed; SCOPE-7 (gate registration) DEFERRED under its own entry condition, no gate registered | framework-health (G125) | COV-3, REG-4, DOC-3 | 2026-08-01 |
| IMP-032 | Status-mirror invariant: name it, explain it at failure time, and give it a legal repair path | APPLIED 2026-08-03 — SCOPE-2a/2b/3/4a/4b/5 landed; SCOPE-1 WITHDRAWN (premise falsified against source — no `E009` precondition is a gate). SCOPE-2b's recorded blocker was false: `state-transition-guard.sh` already passes the resolver's `E009-*` code through to the existing `blockingCode` field, so `E009-STATUS-MIRROR` needed no new field, no schema change, and no downstream parser migration. SCOPE-4b landed as `bubbles/scripts/state-certification-reconcile.sh`, which never writes the mirror on request — it re-runs the transition guard against a candidate whose mirrors agree and writes `certification.status` only on a PASS verdict. EV-4 acceptance criterion NOT met: all six `research-lab` specs were measured through the tool and all six were refused at exit 3, because their statuses are genuinely ahead of their evidence; the divergence now yields a specific blocking code instead of a dead end, which was the ergonomics failure the proposal targeted | framework-health (G125) | EV-4 (not met), COV-4, DOC-4, ~~REG-5~~ | 2026-08-03 |
| IMP-033 | Session closeout and open-work durability: stop losing work at the session boundary | APPLIED 2026-08-02 — SCOPE-1/2/3/4/6/7 landed; SCOPE-5 WITHDRAWN (`bubbles.upkeep` sets `disable-model-invocation: true`, so the mode's only consumer is an operator typing it, making its whole delta over the shipped `cli.sh closeout` a second way to type the same thing — not worth a carve-out in a NON-NEGOTIABLE policy file); the incidental G125 index-row finding is carried as OW-001 in `.specify/memory/open-work.md` | framework-health (G125) | WIP-1, WIP-2, WIP-3, COV-5, EV-5 | 2026-08-02 |
| IMP-036 | Delivery efficiency: close the dispatch hole, instrument the gates, and cut the ceremony that buys nothing | APPLIED 2026-08-06 — all 8 scopes landed. SCOPE-5 always-on context 850→545 lines; SCOPE-4 gate-hit telemetry (first sample: 29 gates observed, 20 rejecting nothing); SCOPE-7 agent field is an enum with a per-repo ratchet; SCOPE-3 gate G133 refuses evidence that proves nothing; SCOPE-2 parent-expansion rate now counted; SCOPE-8 all 114 gates carry a git-derived `since`/`sinceDate` plus an advisory vintage guard; SCOPE-6 compact hash-verifiable evidence and a no-op-state-write prohibition; SCOPE-1 single-orchestrator routing. THREE scopes falsified part of their own proposal and were corrected rather than forced: SCOPE-5's "delete the propagation instruction" (the capability is fully wired and degrades correctly — only the `applyTo: "**"` header was the cost) and its agent-retirement bullet (all 7 candidates are registered and wired, WITHDRAWN); SCOPE-2's enforcement half (already built — the guard already required a registered orchestrator, a ≥20-char reason naming the missing capability, and a resolvable evidence ref, so only visibility was missing). SCOPE-1's second-hop diagnosis was CONFIRMED empirically before the contract was rewritten: a dispatched subagent has no dispatch tool at all. Two self-inflicted defects were caught by the repo's own gates and fixed (a hardcoded product name in a portable surface, and a ratchet baseline placed where downstream repos are forbidden to write). Outcome metrics are unmeasured by design and carried as OW-014; gate retirement deferred as OW-012; the enum baseline shrink as OW-013 | framework-health (G125) | HO-1, HO-2, EV-6, COV-6, COST-2, COST-3, REG-6, REG-7 | 2026-08-06 |
| IMP-034 | Skill Evolution Loop: close the input-starvation and paraphrase-blindness holes | APPLIED 2026-08-03 — SCOPE-1/2/3 landed; SCOPE-4 (session-store adapter for LRN-3) DEFERRED per the proposal's own recommendation, no adapter registered. R6 discharged deliberately: the G068 word-overlap mechanism was evaluated and NOT reused, because `stg_scenario_matches_dod()` freezes its behavior for adopted `SCN-*` IDs, its stopword policy intentionally keeps `user`/`system`/`should`/`must` significant (precisely what over-merges lesson prose), and it is guard-internal, so sourcing it would pull the transition guard's exit paths into the detector. Jaccard was measured insufficient on a realistic paraphrase pair (4 shared, 10 union = 0.40, below the 0.60 threshold, so the loop would stay broken); the overlap coefficient scores the same pair 4/6 = 0.67, so grouping divides shared tokens by the smaller token set with a 3-shared-token floor guarding R1. The selftest proves the knob is live: at `similarityThreshold: 1.0` the same paraphrase set produces no proposal | framework-health (G125) | LRN-1, LRN-2, DOC-5 | 2026-08-03 |
| IMP-037 | Evidence-Backed Experience Recall | IN PROGRESS 2026-08-06 — SCOPE-1 and SCOPE-2 landed/pending commit. SCOPE-2 local lexical provider/index and anchored lesson admission complete; independent final validation: index 50 passed/0 failed, resolver 22/0, schema 67/0, adapter 20/0, skill-evolution PASS; portability, syntax, shellcheck warning/error floor, no-network scan, LF/modes, G125, diff, and diagnostics clean. Fixed S2-F1..S2-F4: exact packet ID coherence, explicit Markdown/YAML unsupported accounting, status/index reconciliation, and structured invalid UTF-8 refusal. SCOPE-3 through SCOPE-7 remain. Commit identity is carried by Git history; no hash is recorded in this row | framework-health (G125) | LRN-4, EV-7, REG-8 | 2026-08-06 |

> **Numbering note:** IMP-001…IMP-036 and IMP-100…IMP-107 are already referenced
> across `bubbles/scripts/**`, `docs/**`, and `CHANGELOG.md` as historical
> delivery identifiers. IMP-035 was allocated outside this index, so IMP-036 is
> the first entry above it here. New proposals continue from **IMP-037** in the
> primary band. Verify with:
> `grep -rhoE 'IMP-[0-9]{3}' --include='*.sh' --include='*.md' --include='*.yaml' --include='*.json' . | sort -u`
