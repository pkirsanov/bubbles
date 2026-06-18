# IMP-015 — IMP-014 follow-ons: MCP `graph_neighbors` verb + traceability edge-confidence tags

> **Type:** Framework self-improvement execution plan (BLUEPRINT — design only)
> **Owner surface:** Bubbles framework (`bubbles/mcp/`, `bubbles/scripts/traceability-guard.sh`)
> **Status:** PLANNED — blueprint only; no load-bearing code written yet. Scoped 2026-06-18.
> **Created:** 2026-06-18

> ⚠️ Lives in `improvements/` not `specs/` per Gate **G085**. This is the turn-key
> design for the two **optional follow-ons** that v7.13.0 deferred when it shipped
> the IMP-014 core ([`bubbles/scripts/bubbles-hub-report.sh`](../bubbles/scripts/bubbles-hub-report.sh)).
> Implementation is intentionally NOT done here — see "Why blueprint-only".

## Problem

IMP-014's core shipped in v7.13.0: the read-only governance hub report
([`bubbles-hub-report.sh`](../bubbles/scripts/bubbles-hub-report.sh) + selftest +
`framework-validate` wiring + a `cli.sh doctor` advisory). Two follow-ons were
named in the CHANGELOG but deliberately deferred:

1. **An MCP `graph_neighbors` verb** so agents query the hub graph through the MCP
   tool surface instead of grepping or shelling out.
2. **Edge-confidence tags in [`traceability-guard.sh`](../bubbles/scripts/traceability-guard.sh)**
   (`declared` / `inferred` / `ambiguous`) so the guard's scenario→row→file
   mappings are honest about what was explicitly cross-referenced vs heuristically
   matched.

Both are real value, but both touch **load-bearing, high-blast-radius** surfaces
(the MCP server; a guard vendored byte-identical into the 5 downstream repos and
run at pre-push). This blueprint specifies them precisely so an implementer can
execute cleanly, and records the sequencing + safety constraints.

## Grounding (real interfaces, verified 2026-06-18)

- **Hub-report `--node` payload** (the exact JSON the verb will serve):
  ```json
  {
    "node": "state-transition-guard.sh",
    "kind": "script",
    "inDegree": 36,
    "dependents": [
      { "source": "agents/bubbles.audit.agent.md", "provenance": "script-call", "line": 41 }
    ]
  }
  ```
- **MCP server** lives in [`bubbles/mcp/`](../bubbles/mcp). Tools are surfaced via a
  JSON-RPC `tools/list` reply; [`bubbles/scripts/mcp-server-selftest.sh`](../bubbles/scripts/mcp-server-selftest.sh)
  asserts a `required_tools=(…)` array (e.g. `check_observability`). Verbs back onto
  a shell script — the precedent is `check_observability` →
  [`observability-check.sh`](../bubbles/scripts/observability-check.sh).
- **Traceability guard** ([`traceability-guard.sh`](../bubbles/scripts/traceability-guard.sh),
  616 lines) consumes a `specs/<feature>` dir and already computes `scenario_total`,
  `row_total`, `mapped_total`, `file_reference_total` — the per-mapping decision
  points where a confidence tag attaches.

## Scope A — MCP `graph_neighbors` verb (lower blast radius; do first)

**Contract:**
- Tool name: `graph_neighbors`.
- Inputs: `node` (required string — a script basename, `bubbles_shared/<x>.md`, or a
  `Gxxx`); `format` (optional, default `json`).
- Output: the **unchanged** `bubbles-hub-report.sh --node <node> --format json`
  payload above — `{ node, kind, inDegree, dependents[] }`, each dependent
  provenance-tagged with `source` + `line`.
- Backing: thin wrapper shelling to
  `bash bubbles/scripts/bubbles-hub-report.sh --node "$node" --format json`
  (mirrors the `check_observability` → `observability-check.sh` pattern). The verb
  adds NO new graph logic — it reuses the shipped, selftested composer.

**Error semantics:** unknown node → a structured MCP error result (never a crash);
a node with no dependents → `inDegree: 0` with `dependents: []` (no fabricated edges,
mirroring the composer's contract).

**Wiring:**
1. Register `graph_neighbors` in the [`bubbles/mcp/`](../bubbles/mcp) server tool list.
2. Add `graph_neighbors` to the `required_tools=(…)` array in
   [`mcp-server-selftest.sh`](../bubbles/scripts/mcp-server-selftest.sh).
3. Add a selftest case: `tools/list` includes `graph_neighbors`; a
   `graph_neighbors{node:"state-transition-guard.sh"}` call returns a non-empty
   provenance-tagged `dependents` set with `inDegree >= 1`; an unknown node returns a
   structured error, not a crash.
4. Document the verb in [`docs/MCP.md`](../docs/MCP.md).

**Acceptance:** verb appears in `tools/list`; returns the real reverse-dep payload
for a known node; selftest green in `mcp-server-selftest.sh` and `framework-validate`.

## Scope B — traceability-guard edge-confidence tags (higher blast radius; do second, additive-only)

**Concept:** classify every mapping the guard makes:
- `declared` — the artifact explicitly cross-references the target (a Test Plan row
  that literally names the scenario / the test file path).
- `inferred` — matched by heuristic (fuzzy scenario-name ↔ test-name similarity).
- `ambiguous` — multiple candidate targets, none explicitly declared.

**Where:** at the existing `mapped_total` / `file_reference_total` decision points in
[`traceability-guard.sh`](../bubbles/scripts/traceability-guard.sh), attach the tag
to each emitted mapping; add per-tag summary counts.

**Output:** add a confidence column to the per-mapping report lines + a
`declared=N inferred=N ambiguous=N` summary. **Informational only.**

**Hard safety constraint (NON-NEGOTIABLE):** this guard is vendored byte-identical
into the 5 downstream repos (6 copies) and runs at pre-push. The change MUST be:
1. **Behavior-preserving by default** — the existing pass/fail/exit semantics are
   UNCHANGED; tags are additive informational output only. Making `ambiguous` (or
   `inferred`) a warning/failure is explicitly **out of scope** here and would be a
   separate ratified behavior change.
2. **Selftested** — a fixture with one explicitly-declared mapping (→ `declared`),
   one fuzzy match (→ `inferred`), and one multi-candidate (→ `ambiguous`), asserting
   the tags AND that the exit code is identical to pre-change for the same fixture.
3. **Re-vendored** — propagated to the 5 downstream copies via the release manifest
   in the same release (this is the 6-copy amplification IMP-014 itself flagged).

**Acceptance:** guard emits the three tags + summary; existing exit semantics
provably unchanged (selftest); selftest green in `framework-validate`; re-vendored
downstream.

## Sequencing & risk

| Order | Scope | Blast radius | Gate before starting |
|------|-------|--------------|----------------------|
| 1 | A — MCP `graph_neighbors` verb | Low (one additive tool wrapping a shipped script) | MCP server quiescent |
| 2 | B — traceability confidence tags | High (guard vendored to 6 copies, runs at pre-push) | Tree quiescent + additive-only + re-vendor planned |

Do Scope A first and independently; it cannot destabilize pre-push. Do Scope B only
when the tree is quiescent, strictly additive, behind its selftest, with the
downstream re-vendor budgeted.

## Why blueprint-only

These follow-ons were deferred by design in v7.13.0 because they touch load-bearing
surfaces. Per the IMP-014 doctrine (and the 6-copy vendoring blast radius IMP-014
exists to make visible), they should be picked up as deliberate, properly-gated work
— not folded into an unrelated change. This document is the turn-key design so that
pickup is mechanical; it makes **zero** load-bearing edits itself.

## Non-goals

- **No change to [`bubbles-hub-report.sh`](../bubbles/scripts/bubbles-hub-report.sh)** —
  the verb consumes its existing `--node --format json` output unchanged.
- **No pass/fail behavior change in `traceability-guard.sh`** — tags are
  informational; turning a tag into a gate is a separate ratified change.
- **No new graph extraction** — both follow-ons reuse already-authoritative,
  already-shipped edge data.

## Cross-references

- **IMP-014** (delivered core, v7.13.0) — [`bubbles-hub-report.sh`](../bubbles/scripts/bubbles-hub-report.sh)
  + selftest + `framework-validate` wiring + `cli.sh doctor` advisory. See CHANGELOG
  v7.13.0 for the delivered scope and the named follow-ons.
- Verb-backing precedent: `check_observability` →
  [`observability-check.sh`](../bubbles/scripts/observability-check.sh).
- MCP surface: [`bubbles/mcp/`](../bubbles/mcp), [`mcp-server-selftest.sh`](../bubbles/scripts/mcp-server-selftest.sh),
  [`docs/MCP.md`](../docs/MCP.md).
