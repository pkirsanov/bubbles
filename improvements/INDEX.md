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

## Proposals

| IMP | Title | Status | Surface | Gap codes | Date |
|---|---|---|---|---|---|
| [IMP-027](IMP-027-enforcement-integrity-and-cost-audit.md) | Enforcement Integrity, Ungoverned Surfaces, and Context-Cost Audit | IN PROGRESS | framework-health (G125) | EV-3; COST-1 (measurement shipped, reduction blocked on a routing eval) | 2026-07-28 |

> **Numbering note:** IMP-001…IMP-026 and IMP-100…IMP-107 are already referenced
> across `bubbles/scripts/**`, `docs/**`, and `CHANGELOG.md` as historical
> delivery identifiers. New proposals continue from **IMP-027** in the primary
> band. Verify with:
> `grep -rhoE 'IMP-[0-9]{3}' --include='*.sh' --include='*.md' --include='*.yaml' --include='*.json' . | sort -u`
