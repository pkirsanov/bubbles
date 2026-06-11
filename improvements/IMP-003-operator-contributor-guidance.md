# IMP-003 — Operator & Contributor Guidance (Effective Prompting + MCP Graduation Rubric)

> **Type:** Framework self-improvement execution plan
> **Owner surface:** Bubbles framework docs (`docs/`, `docs/guides/`, `docs/MCP.md`) + optional first-touch surfacing (`agents/bubbles.super.agent.md`)
> **Status:** SHIPPED — both scopes delivered & verified; shipped with framework v7.10.0 to `origin/main` (commit `1baa796`, 2026-06-11)
> **Authoring agent:** general agent (grounded review of the agency workshop vs the shipped v7.8.0 framework)
> **Created:** 2026-06-11

> ⚠️ **Why this lives in `improvements/` and not `specs/`:** the Bubbles source
> repo MUST NOT keep persistent `specs/` execution packets — Gate **G085**
> (`framework_dogfood_evidence_gate`) fails if `specs/` exists in the canonical
> checkout (regression: `tests/regression/test_04_framework_dogfooding.sh`).
> This portable execution plan is the Bubbles-native equivalent (mirrors
> `IMP-001` / `IMP-002`).

> 📌 **Provenance:** both policies below were surfaced by reviewing the
> Microsoft "agency workshop" (`EngOps-Agency-Training/agencyworkshop`) against
> the shipped framework. They are the two **non-observability** workshop ideas
> that turned out to be genuine (if modest) gaps — split out of the
> observability feature (`IMP-001` R2-G item 10) so that feature stays coherent.
> Everything else from the workshop was either already shipped (Test Impact Map
> = G079, vertical slice = G035, spec-first = G091, escalation = G038/G082,
> secretless = Infisical/sops/no-defaults) or captured in `IMP-001`
> (trace-driven validation, 3 AM heuristic, adversarial observability, Loopy-AI
> framing, WHEEL/Trace Topology).

---

## Outcome Contract

- **Intent:** Close two small, verified guidance gaps:
  - **Policy A — Effective Prompting (operator-facing):** Bubbles ships rich
    *agent* prompts but **zero** guidance for the human/operator on how to write
    an effective request. The workshop README's "Why the Prompts Are Structured
    the Way They Are" table is a clean, portable model.
  - **Policy B — MCP Graduation Rubric (contributor-facing):** `docs/MCP.md`
    documents the MCP *architecture* (every tool is a thin wrapper over a
    `bubbles/scripts/*.sh` bash twin; the server never duplicates logic) but
    gives **no criteria** for *when* a capability should graduate from
    "shell + file + reasoning" into a registered MCP tool. Now that the MCP
    server has shipped (10 tools, v7.8.0), this absence invites tool sprawl.
- **Success Signal:**
  1. A `docs/guides/EFFECTIVE_PROMPTING.md` operator guide exists, passes
     agnosticity + link-integrity checks, and is referenced from the docs
     catalog (and optionally surfaced by `bubbles.super`).
  2. `docs/MCP.md` carries a "When to graduate a script to an MCP tool"
     decision section consistent with the bash-twin-canonical rule.
  3. `framework-validate` stays green; any new file is enumerated in the
     release manifest; framework-stats / cheatsheet regenerated if their counts
     change.
- **Hard Constraints:**
  - Docs-only. **No new gate, no new guard, no schema change, no behavioral
    agent rule that could block a transition.** These are guidance surfaces, not
    enforcement surfaces.
  - Agnosticity-clean: no project-specific names, no `/home/` paths, no real
    URLs/tokens, no operator PII.
  - The MCP rubric MUST NOT contradict the shipped invariant
    (`docs/MCP.md` line ~9): the **bash twin is always the canonical logic**;
    "graduate to a tool" means *add a thin MCP wrapper over a bash twin*, never
    *move business logic into the server*.
  - Any file copied into downstream `.github/` trees (none expected here — these
    are source-repo `docs/`) stays byte-identical + lockstep if it ever is.
- **Failure Condition:** The guidance becomes a parallel/contradictory authority
  (e.g. a prompting "rule" that fights the autonomous-orchestrator model, or an
  MCP rubric that encourages logic in the server), OR it adds enforcement that
  blocks real work.

---

## Design Invariants

| # | Invariant | Rationale |
|---|-----------|-----------|
| INV-1 | **Guidance, not enforcement.** Both deliverables are docs; neither adds a gate, guard, or blocking agent rule. | The gap is missing *help*, not missing *control*. Enforcement here would be over-reach. |
| INV-2 | **Bash-twin-canonical is preserved.** The MCP rubric frames graduation as "wrap an existing bash twin in a thin tool," never "put logic in the server." | Matches the shipped MCP design (`docs/MCP.md`); a rubric that violated it would rot the architecture. |
| INV-3 | **Operator guide complements autonomy, not fights it.** The prompting guide explains how to write a good *intent* for `bubbles.goal`/`bubbles.workflow`; it does NOT push 47-step runbooks (the workshop's own anti-pattern). | Bubbles' value is autonomous orchestration; the guide should make intent crisp, not re-introduce manual step-listing. |
| INV-4 | **Agnostic + PII-clean.** Generic examples only. | Source-repo docs ship to every consumer. |

---

## SCOPE-1 — Effective-prompting operator guide

**Intent:** Give operators a short, durable reference for writing effective
Bubbles requests — adapted from the workshop's prompt-structure table, but
reframed around Bubbles' autonomous-orchestrator model.

**Gherkin**
- Given a new operator unsure how to phrase a request, when they open `docs/guides/EFFECTIVE_PROMPTING.md`, then they find a concise "good request" checklist (state the goal/outcome first; name constraints; name the surface/repo when relevant; request verification; specify output shape when it matters) plus an anti-pattern list (too vague; over-prescriptive step-dumps; missing context; multiple unrelated tasks in one turn).
- Given the guide, when an operator reads the "Bubbles-specific" section, then it explains that for autonomous modes (`bubbles.goal "<intent>"`, `bubbles.workflow`) a crisp *outcome* beats a step list, and points to the workflow-mode resolution + recipes.
- Given the docs catalog, when it is regenerated, then the new guide appears.

**Tasks**
- T1.1 — Author `docs/guides/EFFECTIVE_PROMPTING.md`: (a) the "good request" checklist, (b) the anti-pattern list, (c) a "Bubbles-specific: intent over runbook" section tying it to `bubbles.goal`/`bubbles.workflow` + `bubbles-workflow-mode-resolution`, (d) 2–3 generic worked before/after examples (agnostic — no project names).
- T1.2 — Link the guide from the docs catalog (`docs/CATALOG.md`) and from `README.md` "getting started" if appropriate.
- T1.3 — (OPTIONAL) Surface it from `agents/bubbles.super.agent.md` as the first-touch answer to "how do I ask Bubbles for X?" — a one-line pointer, not a behavioral rule.
- T1.4 — Regenerate any doc-count-derived artifacts (framework-stats / cheatsheet) if the new file changes a count; run their `--check`.

**Test plan**
| Test | Category | Proof |
|------|----------|-------|
| guide exists + sections present | functional | file + heading grep |
| agnosticity lint | unit | `agnosticity` check clean on the new doc |
| catalog/link integrity | unit | catalog references resolve; no broken links |
| framework-validate green | functional | full run after the add |

**DoD**
- [x] `docs/guides/EFFECTIVE_PROMPTING.md` ships with the checklist, anti-patterns, and the "intent over runbook" Bubbles section — agnosticity-lint clean (raw output recorded).
  **Claim Source:** executed (2026-06-11).
  ```text
  $ grep -nE "^#{1,3} |good request|Anti-pattern|intent over runbook|Worked examples" docs/guides/EFFECTIVE_PROMPTING.md
  1:# <img src="../../icons/bubbles-glasses.svg" width="28"> Effective Prompting
  17:## The good-request checklist
  42:## Anti-patterns to avoid
  53:## Bubbles-specific: intent over runbook
  93:## Worked examples: vague → crisp
  98:### Example 1 — feature work
  110:### Example 2 — outcome instead of a runbook
  124:### Example 3 — one focused ask instead of a pile
  142:## See also

  $ bash bubbles/scripts/cli.sh agnosticity
  ℹ️  Scanning 395 portable file(s) for agnosticity drift
  ✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
  AGNOSTICITY_EXIT=0

  # guides/ is not in the lint's default portable-surface set, so the lint's three
  # rules were run directly against the new guide — zero hits on each:
  -- PROJECT_NAME --   NO_PROJECT_NAME_HITS
  -- ABSOLUTE_PATH --  NO_ABSOLUTE_PATH_HITS
  -- CONCRETE_TOOL --  NO_CONCRETE_TOOL_HITS
  ```
- [x] Guide linked from the docs catalog; link-integrity check clean (raw output recorded).
  **Claim Source:** executed (2026-06-11). Linked from `docs/CATALOG.md` (+ README nav); all targets resolve.
  ```text
  $ grep -n "EFFECTIVE_PROMPTING" docs/CATALOG.md README.md
  docs/CATALOG.md:7:> **New here?** Before picking a recipe, the [Effective Prompting](guides/EFFECTIVE_PROMPTING.md)
  README.md:23:  ... <a href="docs/guides/EFFECTIVE_PROMPTING.md">Effective Prompting</a> · <a href="docs/guides/AGENT_MANUAL.md">Agent Manual</a> ...

  $ ls -la docs/guides/EFFECTIVE_PROMPTING.md docs/guides/AGENT_MANUAL.md docs/guides/WORKFLOW_MODES.md docs/CATALOG.md docs/MCP.md skills/bubbles-workflow-mode-resolution/SKILL.md docs/recipes/just-tell-bubbles.md docs/recipes/autonomous-goal.md docs/recipes/ask-the-super-first.md
  # every link target above exists (rw-r--r-- lines returned for all 9 paths)
  # link integrity also confirmed by the green framework-validate run (item 5).
  ```
- [x] `bubbles.super` carries a one-line pointer; handoff/ownership + instruction-budget lints clean.
  **Claim Source:** executed (2026-06-11). One discovery-table row added (a pointer, not a behavioral rule).
  ```text
  $ grep -n "EFFECTIVE_PROMPTING" agents/bubbles.super.agent.md
  75:| **Effective prompting** | `docs/guides/EFFECTIVE_PROMPTING.md` | How to phrase an effective request/intent — first-touch answer to "how do I ask Bubbles for X?" |

  # from the framework-validate run (FRAMEWORK_VALIDATE_EXIT=0):
  ==> Instruction budget lint
  --- Summary ---
  Agent files scanned: 40
  Over warn: 0
  Over hard: 0
  PASS: Instruction budget lint
  ==> Agent ownership lint
  Agent ownership lint passed.
  PASS: Agent ownership lint
  ==> Super surface selftest
  PASS: Super surface selftest
  ```
- [x] Release manifest + framework-stats/cheatsheet regenerated if counts changed; `--check` green (raw output recorded).
  **Claim Source:** executed (2026-06-11). Guide staged (so it is git-tracked) and enumerated; counts otherwise unchanged.
  ```text
  $ bash bubbles/scripts/generate-release-manifest.sh
  Updated release manifest: 7.9.0 (541 managed files)
  $ grep -n "docs/guides/EFFECTIVE_PROMPTING.md" bubbles/release-manifest.json
  295:    {"path": "docs/guides/EFFECTIVE_PROMPTING.md", "sha256": "3834888cad41a8cb1a3bff1ec913f06f75cf3a52ba3df268ee141474d4f60d8f"},
  $ bash bubbles/scripts/generate-release-manifest.sh --check
  Release manifest is current: 7.9.0 (541 managed files)   # exit 0

  $ bash bubbles/scripts/generate-framework-stats.sh --check
  Framework stats are current: 40 Agents · 103 Gates · 55 Workflow Modes · 26 Phases (v7.9.0)   # exit 0 — no doc-count drift
  $ bash bubbles/scripts/generate-cheatsheet.sh --check
  # exit 0 — cheatsheet current (registry-derived; adding a guide changes no embedded count)
  ```
- [x] Build Quality Gate passes as a block.
  **Claim Source:** executed (2026-06-11). Full `framework-validate` suite green.
  ```text
  $ bash bubbles/scripts/cli.sh framework-validate
  Bubbles Framework Validation
  Install mode: source
  ... (every check PASS — agnosticity, cheatsheet selftest, gates/modes drift, MCP server
      selftest "every declared tool references an existing bash twin", release-manifest
      freshness+selftest+purity, install-provenance "Installed manifest reports 541 managed
      files", super-surface, instruction-budget, agent-ownership, governance-index-lint
      selftest, stale-deferral live) ...
  ==> Stale-deferral lint (live)
  [stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.9.0)
  PASS: Stale-deferral lint (live)

  Framework validation passed.
  FRAMEWORK_VALIDATE_EXIT=0
  ```

---

## SCOPE-2 — MCP "when to graduate a script to a tool" rubric

**Intent:** Add the missing decision criteria to `docs/MCP.md` so contributors
know when a capability should become a registered MCP tool vs stay a plain bash
script invoked directly — without ever moving logic into the server.

**Gherkin**
- Given a contributor with a new `bubbles/scripts/*.sh` capability, when they read the new "When to graduate to an MCP tool" section in `docs/MCP.md`, then they find a clear frame: stay a directly-invoked script for one-off / low-frequency / human-run work; add a thin MCP tool wrapper when there is (a) high-frequency agent/CI use, (b) multi-agent reuse, or (c) a need for the tool-call to be captured as structured evidence/provenance.
- Given that section, when a contributor considers adding a tool, then it explicitly restates INV-2: the bash twin remains the canonical logic; the tool is a thin wrapper; the server never duplicates or hides logic.
- Given the MCP selftest, when a tool is added later under this rubric, then the existing 19-invariant selftest (`mcp-server-selftest.sh`, "every declared tool has a bash twin") already enforces the wrapper discipline — the rubric just tells you *when* to reach for it.

**Tasks**
- T2.1 — Add a "When to graduate a script to an MCP tool" subsection to `docs/MCP.md`: the stay-a-script vs add-a-tool decision frame (one-off/low-freq → script; high-freq CI, multi-agent reuse, evidence/provenance capture → tool), the explicit bash-twin-canonical restatement (INV-2), and a pointer to the bash-twin invariant the selftest already enforces.
- T2.2 — Cross-link the rubric from `docs/v6-mcp-design.md` and `docs/guides/AGENT_MANUAL.md` (MCP section) if present.
- T2.3 — Regenerate any doc-count-derived artifacts if a count changes; `--check`.

**Test plan**
| Test | Category | Proof |
|------|----------|-------|
| rubric section present | functional | heading grep in `docs/MCP.md` |
| no contradiction of bash-twin rule | unit | section restates INV-2 (grep for the canonical-logic statement) |
| link integrity | unit | cross-links resolve |
| framework-validate green | functional | full run after the add |

**DoD**
- [x] `docs/MCP.md` carries the graduation rubric; it restates the bash-twin-canonical invariant (INV-2) and contradicts nothing in the shipped MCP design — raw grep/output recorded.
  **Claim Source:** executed (2026-06-11). New section `## When to graduate a script to an MCP tool` (heading at L134); restates INV-2 explicitly.
  ```text
  $ grep -nE "stays canonical|always.*canonical implementation|thin wrapper over that twin|never .*duplicate|every declared tool has a bash twin" docs/MCP.md
  159:### The bash twin stays canonical (non-negotiable)
  162:in `bubbles/scripts/*.sh` is **always** the canonical implementation; an MCP
  167:tool" therefore means *add a thin wrapper over a bash twin* — never *duplicate
  173:invariants — that **every declared tool has a bash twin**. So this rubric only
  # The rubric frames graduation as "add a thin MCP wrapper over a bash twin" and
  # explicitly forbids moving/duplicating logic into the server — consistent with
  # the shipped MCP design's opening invariant. No contradiction introduced.
  ```
- [x] Cross-links from `v6-mcp-design.md` / `AGENT_MANUAL.md` resolve; link-integrity clean.
  **Claim Source:** executed (2026-06-11). Both cross-links point at the live anchor; targets resolve.
  ```text
  $ grep -n "when-to-graduate-a-script-to-an-mcp-tool" docs/v6-mcp-design.md docs/guides/AGENT_MANUAL.md
  docs/v6-mcp-design.md:73:> [When to graduate a script to an MCP tool](MCP.md#when-to-graduate-a-script-to-an-mcp-tool).
  docs/guides/AGENT_MANUAL.md:90:> **Adding a framework MCP tool?** See [When to graduate a script to an MCP tool](../MCP.md#when-to-graduate-a-script-to-an-mcp-tool) ...

  $ grep -n "## When to graduate a script to an MCP tool" docs/MCP.md
  134:## When to graduate a script to an MCP tool   # anchor target exists
  # docs/MCP.md exists (ls confirmed); both relative links resolve. framework-validate green (item below).
  ```
- [x] Release manifest + stats/cheatsheet regenerated if counts changed; `--check` green.
  **Claim Source:** executed (2026-06-11). Same regeneration as SCOPE-1 item 4 (the edited `docs/` files share the manifest docs-digest).
  ```text
  $ bash bubbles/scripts/generate-release-manifest.sh --check
  Release manifest is current: 7.9.0 (541 managed files)   # exit 0
  $ bash bubbles/scripts/generate-framework-stats.sh --check
  Framework stats are current: 40 Agents · 103 Gates · 55 Workflow Modes · 26 Phases (v7.9.0)   # exit 0
  $ bash bubbles/scripts/generate-cheatsheet.sh --check    # exit 0 — no drift
  ```
- [x] Build Quality Gate passes as a block.
  **Claim Source:** executed (2026-06-11). Same green `framework-validate` run as SCOPE-1 item 5 (`FRAMEWORK_VALIDATE_EXIT=0`); the MCP server selftest's "every declared tool references an existing bash twin" (T4) passed, corroborating the rubric's INV-2 framing.
  ```text
  ==> v6 MCP server selftest (A5)
  PASS: T4: every declared tool references an existing bash twin
  ... (T1–T19 PASS) ...
  mcp-server-selftest passed: MCP server boots, dispatches, and surfaces verbatim script output.
  PASS: v6 MCP server selftest (A5)
  Framework validation passed.
  FRAMEWORK_VALIDATE_EXIT=0
  ```

---

## Risk register

| Risk | Severity | Mitigation |
|------|----------|------------|
| Guidance drifts into enforcement (a "prompting rule" or MCP gate) | Med | INV-1 — docs-only; explicitly no gate/guard/blocking rule |
| MCP rubric encourages logic-in-server | High | INV-2 — rubric restates bash-twin-canonical; existing selftest enforces every tool has a bash twin |
| Prompting guide fights the autonomous model (re-introduces runbooks) | Med | INV-3 — guide frames "intent over runbook"; mirrors the workshop's own anti-pattern warning |
| Doc-count drift blocks a later push (stats/cheatsheet/manifest stale) | Low | T1.4 / T2.3 regenerate + `--check`; same discipline as the gate-authoring checklist |
| PII / project-name leak in examples | Low | INV-4 agnosticity lint; generic before/after examples only |

## Feature-level Definition of Done

- [x] Both scopes `Done` with per-item raw evidence. (SCOPE-1: 5/5 DoD `[x]`; SCOPE-2: 4/4 DoD `[x]` — all with inline executed evidence above.)
- [x] `docs/guides/EFFECTIVE_PROMPTING.md` + the `docs/MCP.md` graduation rubric ship; agnosticity + link-integrity clean. (`cli.sh agnosticity` exit 0; all added link targets resolve; `framework-validate` green.)
- [x] No new gate/guard/schema introduced (verified — docs-only). Changeset = `docs/guides/EFFECTIVE_PROMPTING.md` (new), `docs/MCP.md`, `docs/v6-mcp-design.md`, `docs/guides/AGENT_MANUAL.md`, `docs/CATALOG.md`, `README.md`, `agents/bubbles.super.agent.md`, `bubbles/release-manifest.json` (regenerated). No `bubbles/scripts/*`, `bubbles/registry/*`, `bubbles/workflows*`, or schema files touched. INV-1 honored.
- [x] `framework-validate` green; release manifest + stats/cheatsheet regenerated if counts changed; CHANGELOG + capability-ledger + version bump intentionally deferred to the orchestrator's central step (this docs-only change warrants no capability-ledger row; `VERSION`/`CHANGELOG` must NOT be edited by this agent per the task contract).
  **Claim Source:** executed (2026-06-11).
  ```text
  $ bash bubbles/scripts/cli.sh framework-validate
  ... Framework validation passed.
  FRAMEWORK_VALIDATE_EXIT=0
  $ bash bubbles/scripts/generate-release-manifest.sh --check
  Release manifest is current: 7.9.0 (541 managed files)   # exit 0
  ```

## Notes for the orchestrator

- **Working tree only — NOT committed.** This agent did not run `git commit`/`git push` and did not edit `VERSION` or `CHANGELOG.md`.
- **One file is staged on purpose:** `docs/guides/EFFECTIVE_PROMPTING.md` was `git add`-ed (not committed) so the release manifest's git-tracked enumeration includes it (`541` managed files). All other edits are unstaged modifications. The orchestrator's normal `git add -A` + commit will sweep them together.
- **Pre-existing, unrelated finding (not introduced here):** the *live* `governance-index-lint.sh` reports 10 orphan docs (8 recipes incl. `framework-health.md`, `incident-response.md`, `observe-production.md`, `propagate-changes.md`, …; 2 instructions) not linked from `docs/governance-index.md`. None is in this changeset. `framework-validate` runs only the *hermetic* `governance-index-lint-selftest` (which passed), and neither `release-check` nor the git hooks invoke the live lint, so this does not block the gate or the push. Left untouched per the "do not fix unrelated areas" instruction.

---

## Handoff

This plan is the analyst/architecture artifact. Next steps:
1. **Approve** the docs-only scope (no gate churn) for IMP-003.
2. Drive **SCOPE-1** then **SCOPE-2** through `bubbles.plan` → `bubbles.implement`
   (hermetic/source-repo docs work; no `specs/` packet per G085).
3. Lowest priority of the three improvements — `IMP-001` (observability) and the
   `IMP-001` consumer-completeness systemic note carry the high-value work; this
   is modest operator/contributor polish.
