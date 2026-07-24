# IMP-104 — Anti-Fabrication Covers Conversational Execution-Narration + Operator-Pasted Context

**Status:** APPROVED by repo owner — implementing (execution-gated on IMP-103 releasing `bubbles/workflows.yaml` + `CHANGELOG.md`; gate cleared at `611d916`)
**Surface:** framework-health (G125) — human-reviewed; additive, default-preserving extension of an existing gate (no new gate ID, no new script)
**Motivation:** a live `bubbles.goal` session fabricated an execution/dispatch narrative — "I was mid-dispatch to `bubbles.implement` / session state is tracking it" — with ZERO `runSubagent` calls in the turn. It produced that narrative by restating an operator-pasted screenshot's narration (captured from a *different* session) as its own in-session state, and it inferred an unrequested work mandate from cross-repo terminal scrollback the operator had pasted for diagnosis. G021 caught neither, because G021's mechanical teeth (Check 12) scan written artifacts, not between-turns conversational narration, and no rule classified operator-pasted transcripts/scrollback/other-repo state as non-authoritative input.
**Verified gaps addressed:** AF-NARRATION (first-person execution/delegation narration with no matching in-session action); AF-BORROWED-CONTEXT (operator-pasted context treated as the agent's own execution evidence OR as a work mandate).

## Problem (verified against source)

- **AF-NARRATION — narration is not evidence-scoped:** `bubbles/registry/gates.yaml` G021 (`anti_fabrication_gate`, line 60-61) and its Check-12 enforcement in `bubbles/scripts/state-transition-guard.sh` (the block formerly tagged G049, line ~3074) both operate on written evidence blocks inside `report.md`/`scopes.md` — evidence depth, template verbatim-match, batch-checking, timestamp plausibility, and ≥80% clone similarity. None of these fire on a conversational, first-person claim ("dispatched to X", "mid-flight", "resuming from session state", "tests pass") that is made between turns and never written to an artifact. A model can therefore narrate delegated/executed work it never performed and pass every artifact-scoped heuristic.
- **AF-BORROWED-CONTEXT — no non-authoritative-input rule:** the anti-fabrication surface (`agents/bubbles_shared/quality-gates.md` "Anti-Fabrication Rules", `agents/bubbles_shared/operating-baseline.md` "Anti-Fabrication Tie-In", the `bubbles.goal` / `bubbles.sprint` "Anti-Fabrication (Gate G021)" blocks) has no clause classifying operator-supplied context — pasted screenshots, terminal scrollback, another repository's logs, or another session's state — as diagnostic input only. Without that clause a model can (a) restate that pasted context as its own execution evidence and (b) infer an active work mandate from it, which is exactly what the incident session did.

These two gaps compose with — but are NOT covered by — IMP-103 / G129. G129 governs which **repository** a command targets (it rejects ambient signals as *repository-selection* authority). It does not govern whether a narrated execution/dispatch claim actually happened, nor whether pasted context may be treated as evidence or as a mandate. IMP-104 closes the anti-fabrication facet; it cross-references G129 for the repository-selection facet and does not duplicate it.

## Proposal

### SCOPE-1 — Extend the canonical G021 description (AF-NARRATION + AF-BORROWED-CONTEXT)

- Append one additive sentence-group to the existing G021 `description` scalar in `bubbles/registry/gates.yaml` (the canonical registry). It states that first-person execution/delegation claims in narration MUST correspond to a real in-session tool call, dispatch, or file read — a claim with no matching in-session action is fabrication independent of whether any artifact is written — and that operator-supplied context is diagnostic input only, never the agent's own execution evidence and never a work-mandate source. The sentence explicitly composes with G129/IMP-103 for the repository-selection facet.
- Then regenerate the generated `gates:` block in `bubbles/workflows.yaml` via `bubbles/scripts/generate-gates-block.sh` (verbatim splice; NEVER hand-edited). The registry stays the single source of truth.
- Decision: keep this as an **additive amendment to G021**, not a new gate. The facet is the same fabrication family; a new gate ID would fragment the anti-fabrication surface and imply new mechanical teeth that this change deliberately does not add (see R3).

### SCOPE-2 — Runtime prose clause (AF-BORROWED-CONTEXT)

- Add one verbatim operator-context clause to the runtime surfaces agents actually read at execution time: `agents/bubbles.goal.agent.md` and `agents/bubbles.sprint.agent.md` (each under `## Anti-Fabrication (Gate G021)`), and `agents/bubbles_shared/operating-baseline.md` (under the "Anti-Fabrication Tie-In" section). The clause names pasted screenshots, terminal scrollback, another repository's logs, and another session's state as DIAGNOSTIC INPUT ONLY, forbids restating them as the agent's own execution evidence, forbids inferring a work mandate from them, and states that work is authorized only by the operator's explicit request in the current conversation (and, for repository selection, by IMP-103 repository-binding preflight).

### SCOPE-3 — Rationale / catalog / CHANGELOG

- Add a short AF-NARRATION / AF-BORROWED-CONTEXT rationale note to the G021 anti-fabrication rules in `agents/bubbles_shared/quality-gates.md`, and a G021 quick-ref line in `skills/bubbles-quality-gates-catalog/SKILL.md` so a reader resolving "what does G021 cover" sees both facets.
- Record the change in `CHANGELOG.md` under `[Unreleased]`.

## Migration / rollout

- Execution was gated on IMP-103 releasing `bubbles/workflows.yaml` and `CHANGELOG.md` (both are collision surfaces the generator/changelog also touch). That gate is now cleared: IMP-103 S5B landed at `611d916` on `main`, and both files are clean at that HEAD.
- All three scopes are additive and default-preserving. SCOPE-1 changes a description string plus its generated mirror (no behavior flag, no new script, no new gate). SCOPE-2/3 are prose. There is no downstream migration and no state.json/schema impact. `docs/governance-index.md` (unrelated IMP-020 work) is explicitly outside this packet's boundary and is neither touched nor staged.

## Risks & mitigations

- **R1 — partial edit without regenerating `workflows.yaml` → drift → `framework-validate` RED.** Editing `bubbles/registry/gates.yaml` without re-running the splice leaves `gates-registry-selftest.sh` T2 failing. → Mitigation: ALWAYS run `bash bubbles/scripts/generate-gates-block.sh` immediately after the registry edit, and confirm `git diff bubbles/workflows.yaml` touches only the G021 entry before validating.
- **R2 — duplication drift with IMP-103 / G129.** Re-stating repository-selection authority inside G021 could contradict G129 later. → Mitigation: the G021 clause defers the repository-selection facet to G129/IMP-103 by explicit cross-reference and adds ONLY the anti-fabrication facet; it does not restate G129's authority ordering.
- **R3 — over-claiming mechanical teeth.** The narration/borrowed-context facet is NOT mechanically detectable the way clone-similarity is; claiming Check 12 now enforces it would be false. → Mitigation: Check 12 stays artifact-scoped and is unchanged by this packet. The new clause is a self-check / cross-agent-verification (G020) obligation and a G021 description-level standard. The CHANGELOG and rationale note say so plainly, so no reader infers a new mechanical scanner.

## Acceptance criteria (when implemented)

- AF-NARRATION: `bubbles/registry/gates.yaml` G021 description ends with the appended narration + borrowed-context sentence-group, and `bubbles/workflows.yaml` G021 is a byte-identical mirror (`generate-gates-block.sh --check` exits 0; `gates-registry-selftest.sh` passes T1-T5).
- AF-BORROWED-CONTEXT: the verbatim operator-context clause is present under `## Anti-Fabrication (Gate G021)` in `bubbles.goal` and `bubbles.sprint`, and under the "Anti-Fabrication Tie-In" section in `operating-baseline.md`.
- Rationale/catalog: `quality-gates.md` Anti-Fabrication Rules names AF-NARRATION and AF-BORROWED-CONTEXT; `bubbles-quality-gates-catalog/SKILL.md` carries a G021 quick-ref line covering both facets.
- `bash bubbles/scripts/cli.sh framework-validate` is green (no failure introduced by this packet); `docs/governance-index.md` remains unstaged and outside the commit.

## Files to touch (on approval)

`bubbles/registry/gates.yaml` (SCOPE-1 — canonical G021 description; owner: gate registry), `bubbles/workflows.yaml` (SCOPE-1 — GENERATED mirror via `generate-gates-block.sh`, never hand-edited), `agents/bubbles.goal.agent.md` + `agents/bubbles.sprint.agent.md` + `agents/bubbles_shared/operating-baseline.md` (SCOPE-2 — runtime prose clause; owner: agent surfaces), `agents/bubbles_shared/quality-gates.md` + `skills/bubbles-quality-gates-catalog/SKILL.md` (SCOPE-3 — rationale/catalog), `CHANGELOG.md` (SCOPE-3 — release note). Enforcement remains G021 (`state-transition-guard.sh` Check 12, artifact-scoped) plus G020 cross-agent verification and agent self-check for the narration/borrowed-context facet.
