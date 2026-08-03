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

## Proposals

| IMP | Title | Status | Surface | Gap codes | Date |
|---|---|---|---|---|---|
| IMP-028 | Orchestrator Context Architecture (COST-1 remainder) | CLOSED 2026-07-29 — findings folded into `agents/bubbles_shared/operating-baseline.md` (R3); target unreachable by the proposed reduction, dedup premise measured false | framework-health (G125) | COST-1 (reduction; supersedes IMP-027 SCOPE-6) | 2026-07-28 |
| IMP-030 | Controlled Technical Prose: term registry enforcement + prose-form governance | APPLIED 2026-08-01 — SCOPE-1/2/3/4 landed; SCOPE-5 (Gate G132) DEFERRED under its own entry condition, no gate registered | framework-health (G125) | REG-3, DOC-2 | 2026-08-01 |
| IMP-031 | Feature Reachability: close the orphaned-implementation hole | APPLIED 2026-08-01 — SCOPE-1/2/3/4/5/6/8/9 landed; SCOPE-7 (gate registration) DEFERRED under its own entry condition, no gate registered | framework-health (G125) | COV-3, REG-4, DOC-3 | 2026-08-01 |
| [IMP-032](IMP-032-status-mirror-invariant-and-underclaim-detection.md) | Status-mirror invariant: name it, explain it at failure time, and give it a legal repair path | APPLIED 2026-08-02 — SCOPE-2a/3/4a/5 landed; SCOPE-1 WITHDRAWN (premise falsified against source — no `E009` precondition is a gate); SCOPE-2b and SCOPE-4b DEFERRED under their own entry conditions | framework-health (G125) | EV-4, COV-4, DOC-4, ~~REG-5~~ | 2026-08-02 |
| IMP-033 | Session closeout and open-work durability: stop losing work at the session boundary | APPLIED 2026-08-02 — SCOPE-1/2/3/4/6/7 landed; SCOPE-5 WITHDRAWN (`bubbles.upkeep` sets `disable-model-invocation: true`, so the mode's only consumer is an operator typing it, making its whole delta over the shipped `cli.sh closeout` a second way to type the same thing — not worth a carve-out in a NON-NEGOTIABLE policy file); the incidental G125 index-row finding is carried as OW-001 in `.specify/memory/open-work.md` | framework-health (G125) | WIP-1, WIP-2, WIP-3, COV-5, EV-5 | 2026-08-02 |

> **Numbering note:** IMP-001…IMP-033 and IMP-100…IMP-107 are already referenced
> across `bubbles/scripts/**`, `docs/**`, and `CHANGELOG.md` as historical
> delivery identifiers. New proposals continue from **IMP-034** in the primary
> band. Verify with:
> `grep -rhoE 'IMP-[0-9]{3}' --include='*.sh' --include='*.md' --include='*.yaml' --include='*.json' . | sort -u`
