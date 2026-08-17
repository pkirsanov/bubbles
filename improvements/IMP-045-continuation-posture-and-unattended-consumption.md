# IMP-045 — Continuation posture: make `unattended` real, then give it one honest entrypoint

**Status:** IN PROGRESS 2026-08-16 — owner approved 2026-08-14. SCOPE-1, SCOPE-2, SCOPE-3 and SCOPE-8 landed (`38b875f`, `32a1825`, `8bd1325`, `242d4cb`, `4dccefe`). SCOPE-4, SCOPE-5, SCOPE-6, SCOPE-7, SCOPE-9 and SCOPE-10 remain open
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** An operator asked for a universal continuation command carrying a specific directive set — unblock yourself honestly, work systematically on the defined scope, always pick the option best for the long term with no shortcuts, execute end to end without asking questions, deliver 100%, review periodically against the plan, reach the intended final state fully tested, never fabricate, and do not stop for review or commit. Reviewing that request against source found that the framework already declares the posture such a command would need (`autonomy: unattended`), but no agent consumes it, and that four of the directives have no enforcement mechanism anywhere. The command is therefore not the gap. The unconsumed posture and the unenforced directives are.
**Verified gaps addressed:** DOC-6 (a declared posture no runner implements), COV-14 (G135 cannot see an agent-side omission), REG-9 (two authorities count prompt shims), REG-10 (the decision policy has no long-term or no-shortcut principle and contradicts the posture), COV-15 ("deliver 100%" has no bound completion predicate), GF-14 (no per-iteration plan-fidelity reconciliation)

## Provenance

Every claim below was re-read from source in the authoring session. Inputs audited:

- `bubbles/workflows.yaml` lines 1826-1835 — the `autonomy` enum and the `unattended` contract text.
- `bubbles/scripts/autonomy-resolve.sh` line 33 — `VALID_AUTONOMY="full guarded interactive unattended"`.
- `bubbles/scripts/autonomy-posture-guard.sh` lines 96-160 — the four G135 checks.
- `agents/bubbles.goal.agent.md` line 343, `agents/bubbles.workflow.agent.md` line 692, `agents/bubbles.iterate.agent.md` line 335, `agents/bubbles.sprint.agent.md` line 146 — the autonomy bullet in each runner.
- `bubbles/agent-capabilities.yaml` lines 45-70 — `workflowModeGrants`, including `bubbles.goal` `excludedModes`.
- `bubbles/scripts/management-truth-lint.sh` lines 93-101 — the live prompt-shim count.
- `bubbles/scripts/generate-framework-stats.sh` lines 139-330 — README counts derived from `agent_count`.
- `bubbles/scripts/orchestrator-persistence-lint.sh` lines 25-30 — the G086 target list.
- `bubbles/workflows/modes.yaml` lines 570-582 — the `resume-only` mode.
- `bubbles/mcp/server.py` lines 551-616 — the prompt catalog loader.
- Commits `091e565`, `82b0c9f`, `500438b`, `af43752`, `5d14b1f`, `b175ae3` (2026-08-10) — the delivered autonomy-posture surface.
- `bubbles/workflows.yaml` lines 2059-2096 — `decisionPolicy`, its seven `mechanicalPrinciples`, and `tasteDecisionHandling`.
- `bubbles/workflows.yaml` lines 1236-1252 — `terminalStopConditions` and the eleven `neverStopFor` conditions.
- `agents/bubbles.goal.agent.md` lines 178-196 (`phase_7_convergence`) and lines 300-330 (`Never-Stop Rules`, `on_obstacle`, `stop_only_when`).
- `bubbles/scripts/goal-fidelity-guard.sh` lines 11-35 — the six selectable drift boundaries, including `post-planning` and `pre-certification`.
- `bubbles/scripts/convergence-materiality.sh` lines 1-12 — the convergence materiality brake.
- Gate runs at authoring time: `autonomy-posture-guard.sh` exit 0, `framework-health-evidence-lint.sh` exit 0, `management-truth-lint.sh` exit 0.

## Problem (verified against source)

- **DOC-6 — a declared posture no runner implements.** `bubbles/workflows.yaml` declares four `autonomy` values and `autonomy-resolve.sh` accepts four. All four runner agents document only three. `unattended` appears in ZERO files under `agents/`, `docs/`, `prompts/`, and `bubbles/cheatsheet/`. The only runtime caller of the resolver is `bubbles/scripts/state-snapshot.sh` line 279, which RECORDS the posture and does not act on it. Requesting `autonomy:unattended` today therefore changes budget enforcement only. Its four behavioral deltas — no interactive questions, taste-overflow auto-resolve, `autoCommit scope`, and a recorded remediation attempt before an agent-solvable `blocked` — have no consumer. This is the AUT-2 shape (a declaration describing behavior the implementation does not have) that G135 was built to prevent, surviving one layer above where G135 looks.

- **COV-14 — G135 cannot see an agent-side omission.** `autonomy-posture-guard.sh` check 2 compares the `workflows.yaml` enum against the resolver's `VALID_AUTONOMY` in both directions. It never inspects an agent file. A posture can therefore be declared, implemented in the resolver, gated by G135, and still be absent from every agent that would have to perform it — which is the exact state today.

- **REG-9 — two authorities count prompt shims.** `management-truth-lint.sh` counts `prompts/*.prompt.md` by glob and enforces that count against `docs/guides/INSTALLATION.md` and `docs/MCP.md`. `generate-framework-stats.sh` writes README's two prompt-shim lines from `agent_count`. Both agree today only because the repo happens to have 41 agents and 41 prompts. Adding one prompt makes management-truth-lint demand 42 in two files while the stats generator rewrites README to 41. The contradiction is latent, not theoretical, and it blocks any work that adds a prompt.

- **REG-10 — the decision policy has no long-term principle, and it contradicts the posture.** `decisionPolicy.mechanicalPrinciples` names seven principles: `prefer_completeness`, `match_existing_patterns`, `prefer_reversible`, `defer_ambiguous`, `escalate_security`, `use_prior_preferences`, and `respect_spec_constraints`. NONE of them says choose the option that is best for the long term, and none forbids a shortcut. `prefer_completeness` is bounded to a 30% effort difference, and `prefer_reversible` optimizes for undo, not durability. Separately, `tasteDecisionHandling.overflowAction` is `route_to_clarify` and `defer_ambiguous` converts any sub-60%-confidence call into a taste decision. Both route toward a human. The `unattended` enum text says taste-decision overflow auto-resolves and is logged. Nothing reconciles the two, because `decisionPolicy` has no posture awareness at all. Under the posture as written, the registry both requires and forbids stopping.

- **COV-15 — "deliver 100%" has no bound completion predicate.** `agents/bubbles.goal.agent.md` `phase_7_convergence` does define exit conditions (`all_gates_pass AND all_tests_pass AND zero_findings AND artifact_lint_clean AND all_scopes_done`), and `goal-fidelity-guard.sh --boundary pre-certification` can verify the success signal and hard constraints. Neither is tied to the posture, and neither is named as the definition of complete. An operator instruction to "deliver 100%" therefore has no mechanical referent, which is precisely the pressure that produces a fabricated terminal state.

- **GF-14 — no per-iteration plan-fidelity reconciliation.** `goal-fidelity-guard.sh` ships six drift boundaries and `post-planning` already checks that every active requirement and scope traces to the contract. The boundary is caller-selected, so nothing requires a long autonomous run to re-run it as it iterates. A run can drift from the plan for many convergence iterations and only discover it at certification, if at all. The operator directive "do periodic review against plan" has real machinery behind it and no trigger.

- **Scoping fact that constrains any fix (not itself a defect).** `bubbles/agent-capabilities.yaml` grants `bubbles.goal` `modes: ["*"]` with `excludedModes: [autonomous-sprint, iterate]`, and sets `nestedWorkflowRunnerDispatch: forbidden`. A VS Code prompt shim binds exactly one agent. No single prompt can therefore continue every active run: a shim bound to `bubbles.goal` covers every mode except `iterate` and `autonomous-sprint`.

- **Related wording defect (low severity).** `bubbles/workflows.yaml` gate G086 and its registry entry describe `orchestrator-persistence-lint.sh` as scanning "orchestrator prompt files". The script's `TARGET_FILES` array lists four `agents/*.agent.md` files. No prompt file is scanned.

## Proposal

### SCOPE-1 — Consume `unattended` in the four runner agents (DOC-6)

Add the fourth value to the autonomy bullet in `agents/bubbles.goal.agent.md`, `agents/bubbles.workflow.agent.md`, `agents/bubbles.iterate.agent.md`, and `agents/bubbles.sprint.agent.md`. Each runner MUST state the four deltas it performs when the resolved posture is `unattended`:

1. Interactive questions are forbidden. Do not call the ask-user tool. Do not open a Socratic loop even if `socratic: true` is also present; the posture wins and the override is logged.
2. Taste-decision overflow auto-resolves and is recorded, instead of routing to `bubbles.clarify` at the `maxPerPhase` threshold.
3. `autoCommit` resolves to `scope`. Commits land only after a scope reaches validated Done.
4. A `blocked` outcome whose cause is agent-solvable requires a recorded remediation attempt first. An operator-only blocker (absent credential, absent external access) remains a truthful terminal state and MUST NOT be suppressed.

Each runner MUST also restate that the posture governs interaction only, and that the Autonomy Floor in `agents/bubbles_shared/critical-requirements.md` is never waived. Decision taken: put the deltas in the four runner files rather than a new shared module, because `operating-baseline.md` line 361 already directs posture differences to the existing dial and a fifth always-on module would add context cost that IMP-039 SCOPE-6 just removed.

### SCOPE-2 — Extend G135 so an unconsumed posture cannot ship (COV-14)

Add a fifth check to `bubbles/scripts/autonomy-posture-guard.sh`: every value in the `workflows.yaml` `autonomy` enum MUST appear in each of the four runner agent files. Reuse the existing enum parser so the check cannot drift from check 2. Emit one finding per missing (posture, agent) pair, naming both.

Extend `bubbles/scripts/autonomy-posture-guard-selftest.sh` with a paired adversarial fixture: a tree in which one runner omits one enum value MUST exit 1, and the green tree MUST still exit 0. Without the adversarial half the check cannot prove it can fail. Keep the no-bypass rule: no `--skip`, `--force`, or `--ignore`.

### SCOPE-4 — Add the `/bubbles.continue` prompt shim

Add `prompts/bubbles.continue.prompt.md` as a thin shim targeting `bubbles.goal`. It MUST NOT restate policy; it supplies existing `executionOptions` only:

- `autonomy: unattended`
- a non-null `sessionBudget` — required, because `autonomy-resolve.sh` exits 3 with `E039-UNATTENDED-UNBOUNDED` when every cap is null
- preserve the repository binding, work boundary, active workflow mode, policy snapshot, findings ledger, and current scope

Do NOT set `autoCommit` in the shim; SCOPE-1 already folds `autoCommit scope` into the posture, and a second declaration is drift waiting to happen. The shim MUST state that `iterate` and `autonomous-sprint` are outside this runner's grants and route to `/bubbles.iterate` or `/bubbles.sprint` instead of silently downshifting.

Name decision: `/bubbles.continue`. It matches the vocabulary already used in `agents/bubbles.workflow.agent.md` line 413 ("outcome-level continuation"). Rejected alternatives: `/bubbles.force`, `/bubbles.finish`, and `/bubbles.100`, each of which promises bypass or guaranteed completion that the Autonomy Floor forbids.

**Directive-to-enforcement map (NORMATIVE).** The shim is only honest if every directive it implies resolves to a named mechanism. Each row below MUST hold before SCOPE-4 may land. A directive with no mechanism is a promise the framework cannot keep and MUST NOT be implied by the prompt text.

| Operator directive | Enforcement mechanism | Status |
|---|---|---|
| Unblock yourself honestly; do not report a blocker you can resolve | `neverStopFor` (11 conditions, `workflows.yaml` 1242) + `on_obstacle` map + posture delta 4 (recorded remediation attempt first) | SCOPE-1 binds |
| Authorized | The posture is opt-in; invoking the shim IS the authorization act | exists |
| Work systematically on the defined scope | `work-boundary-resolve.sh` + `goal-contract.sh verify-ref`; shim preserves the boundary | exists |
| Always pick the option best for the long term; no shortcuts | `decisionPolicy.mechanicalPrinciples` `prefer_durable` + `forbid_shortcut`, ranked above `prefer_completeness` and `prefer_reversible` | exists |
| Execute end to end, no stopping, no questions | G086 `orchestrator-persistence-lint.sh` + posture delta 1 | SCOPE-1 binds |
| Deliver 100% | `phase_7_convergence` exit conditions + `goal-fidelity-guard.sh --boundary pre-certification` — not bound today | **SCOPE-9** |
| Unblock all blocks; implement, fix, or plan whatever is needed | `on_obstacle.missing_spec` bootstraps planning through `full-delivery` | exists |
| Do periodic review against the plan | `goal-fidelity-guard.sh --boundary post-planning` — exists, never triggered per iteration | **SCOPE-10** |
| Intended final state, fully tested, holistic | SCOPE-9 predicate + `requiredSpecialists` for the resolved mode | **SCOPE-9** |
| Do not fabricate; only honest status | Autonomy Floor item 1 — never waivable by any posture | exists |
| Do not stop for user review or commit | posture delta 3 (`autoCommit scope`) after a validated milestone | SCOPE-1 binds |

The shim MUST NOT paraphrase these as new rules. It names the posture; the posture and the guards carry the behavior.

### SCOPE-5 — Publish the posture and the entrypoint

`unattended` is currently undocumented for operators. Add it to `docs/guides/AUTONOMOUS_EXECUTION.md` (a posture table naming the four deltas and the bounded-budget requirement), `docs/guides/WORKFLOW_MODES.md`, `docs/guides/AGENT_MANUAL.md`, `docs/CHEATSHEET.md`, and `docs/recipes/resume-work.md`. Update the counts in `docs/guides/INSTALLATION.md` and `docs/MCP.md` in the same change as SCOPE-4, because `management-truth-lint.sh` enforces both against the live glob. State plainly in each surface that the posture raises throughput and waives nothing.

### SCOPE-6 — Index the delivered autonomy-posture work (DOC-6 residual)

The `IMP-039` row in `improvements/INDEX.md` already records that the identifier is carried by two separate bodies of work. The autonomy-posture half still has no row of its own, and its `AUT-1`, `AUT-2`, and `AUT-5` gap codes are absent from the INDEX legend. Add a row for the delivered posture surface and either add `AUT-*` to the gap-code legend or map those findings onto existing codes. This is audit-history hygiene, not a behavior change.

### SCOPE-7 — Correct the G086 description (low severity)

Change the G086 text in `bubbles/workflows.yaml` and `bubbles/registry/gates.yaml` from "orchestrator prompt files" to the four orchestrator agent files the lint actually scans. Alternatively, extend `orchestrator-persistence-lint.sh` to scan prompt shims as well. Recommendation: correct the description. The shims carry no behavior, so scanning them would enforce nothing.

### SCOPE-9 — Bind a completion predicate to "deliver 100%" (COV-15)

Name the predicate in the four runners and in `docs/guides/AUTONOMOUS_EXECUTION.md`. A run under `unattended` may report success only when ALL hold:

1. `phase_7_convergence` conditions: all gates pass, all tests pass, zero findings, artifact lint clean, all scopes Done.
2. Every specialist in `requiredSpecialists` for the resolved mode has run, per Gate G022.
3. `goal-fidelity-guard.sh --boundary pre-certification` exits 0, so the success signal is evidenced and every hard constraint held.
4. `certification.*` is written by `bubbles.validate` only, per the existing ownership rule.

Anything short of all four is a NON-terminal state and the loop continues, or it is a truthful `blocked`. Explicitly forbid the failure mode this closes: declaring completion because the iteration cap was reached. `max_iterations_reached` is `EXIT_WITH_STATUS_REPORT`, never success.

### SCOPE-10 — Require per-iteration plan-fidelity reconciliation (GF-14)

Require each runner to execute `goal-fidelity-guard.sh --boundary post-planning` once per convergence iteration, not only at certification. On a finding, route to the owning planning agent (`bubbles.plan`, `bubbles.design`, or `bubbles.analyst`) and re-run the boundary before continuing; do not proceed on known drift.

Record each reconciliation in `.specify/memory/bubbles.session.json` alongside the existing convergence-iteration snapshot, so "the plan was reviewed" is an artifact rather than a claim. Extend `bubbles/scripts/state-snapshot-selftest.sh` to prove the record is written.

This is the mechanical form of "all specs and plans MUST be fully delivered before you stop": the run cannot quietly diverge from the plan for ten iterations and discover it at the end.

## Migration / rollout

Land in order: SCOPE-1, SCOPE-9, SCOPE-10, SCOPE-2, SCOPE-4, SCOPE-5. SCOPE-6 and SCOPE-7 are independent and may land at any time. The prompt-shim counting authority and the decision-policy scope are delivered and have been removed from this file.

SCOPE-9 and SCOPE-10 precede SCOPE-2 so the G135 extension holds a complete contract rather than a partial one. SCOPE-1 must precede SCOPE-4 because a shim that requests a posture no runner implements is the exact DOC-6 defect this proposal exists to close. The decision policy already stops routing taste-decision overflow to a human, so SCOPE-1 can now write a posture contract that is not self-contradictory.

SCOPE-4 is LAST by construction. The directive-to-enforcement map in that scope is its entry condition: the prompt may not ship while any row still reads SCOPE-9 or SCOPE-10.

Every scope is additive and default-preserving. The framework default stays `full`; `unattended` remains opt-in and refuses to run unbounded. `decisionPolicy` behavior under `full`, `guarded`, and `interactive` is byte-identical to before the delivered principles and posture override landed.

## Risks & mitigations

- **R1 — "user approves all" is read as gate-waiving.** A blanket continuation directive is direct pressure to fabricate a terminal state. Mitigation: SCOPE-1 restates the Autonomy Floor inside each runner, SCOPE-4 restates it in the shim, and no scope touches evidence rules, status ceilings, or the transition guard.
- **R2 — the shim silently fails on `iterate` or `autonomous-sprint`.** A prompt binds one agent, and `bubbles.goal` is not granted those modes. Mitigation: SCOPE-4 requires the shim to name the limitation and route, rather than downshift.
- **R3 — an unbounded unattended run.** Mitigation: already mechanical. `autonomy-resolve.sh` exits 3 with `E039-UNATTENDED-UNBOUNDED`, and SCOPE-4 requires the shim to supply a budget.
- **R4 — count drift lands as a broken build.** Mitigation: the single prompt-shim counting authority is delivered and was a no-op at equal counts; `management-truth-lint.sh` then holds both files.
- **R5 — the new G135 check hard-codes the runner list and rots.** Mitigation: derive the four runners from `bubbles/agent-capabilities.yaml` `workflowModeGrants` where practical, and pair every check with an adversarial fixture so a silent pass is impossible.
- **R6 — G125 Check 6 refuses the commit.** If the commit that ADDS this file also mutates `bubbles/` or `agents/`, its message MUST name `IMP-045`, or `framework-health-evidence-lint.sh` reports `proposal-untraceable`. Mitigation: name the IMP in the commit message, or commit the proposal separately.
- **R7 — `forbid_shortcut` becomes a rhetorical principle the resolver cannot apply.** A principle that cannot decide anything is decoration. Mitigation: state it as a prohibition over concrete, detectable moves — weakening a test, narrowing a DoD claim, deferring required behavior, relabeling incomplete work — each of which already has a gate (G040 deferral language, G025 per-item evidence, the implementation reality scan).
- **R8 — auto-resolving overflow hides a spec that is genuinely too vague.** `overflowAction: route_to_clarify` exists because more than five taste decisions in one phase is evidence the spec is unclear. Auto-resolving silently loses that signal. Mitigation: the delivered `auto_resolve_and_log` override requires the overflow to be LOGGED, and SCOPE-10's per-iteration reconciliation surfaces the resulting drift against the plan rather than letting it accumulate to certification.
- **R9 — per-iteration reconciliation slows the loop.** Mitigation: `post-planning` is a single guard invocation against artifacts already in memory, and it runs once per convergence iteration, not per dispatch. If measurement shows it is material, bound it by iteration count rather than removing it.

## Acceptance criteria (when implemented)

- `grep -rl "unattended" agents/*.agent.md` returns the four runner files. Today it returns nothing.
- `autonomy-posture-guard.sh` exits 1 against a fixture in which any runner omits any enum value, and exits 0 against the green tree.
- `generate-framework-stats.sh --check` fails when README's prompt-shim count disagrees with the live `prompts/` glob.
- `management-truth-lint.sh` exits 0 with 42 prompts, and `docs/guides/INSTALLATION.md`, `docs/MCP.md`, and `README.md` all report the same number.
- The MCP `prompts/list` response includes `bubbles.continue`; `bubbles/mcp/server.py` discovers it by glob, so no server change is required.
- An operator can find `unattended` in at least one guide under `docs/guides/`, including its bounded-budget requirement.
- `framework-health-evidence-lint.sh` exits 0 with this proposal present.
- The Autonomy Floor in `agents/bubbles_shared/critical-requirements.md` is unchanged, and `autonomy-posture-guard.sh` still reports the floor intact.
- `decisionPolicy.mechanicalPrinciples` contains `prefer_durable` and `forbid_shortcut`, and `tasteDecisionHandling` declares a `postureOverrides` entry for `unattended`. Under `full`, `guarded`, and `interactive` the resolved behavior is byte-identical to today.
- A security-affecting decision under `unattended` produces a truthful `blocked` naming the decision, and is never auto-resolved. A fixture proves it.
- Every row of the SCOPE-4 directive-to-enforcement map resolves to a shipped mechanism, with no row still reading SCOPE-9 or SCOPE-10.
- A run that reaches `max_iterations_reached` reports `EXIT_WITH_STATUS_REPORT`, never success. A fixture proves the distinction.
- `.specify/memory/bubbles.session.json` records one plan-fidelity reconciliation per convergence iteration, and `state-snapshot-selftest.sh` fails when the record is absent.

## Files to touch (on approval)

`agents/bubbles.goal.agent.md`, `agents/bubbles.workflow.agent.md`, `agents/bubbles.iterate.agent.md`, `agents/bubbles.sprint.agent.md` (SCOPE-1 posture consumption — owner: the framework maintainer; these are runner contracts, not specialist prompts) · `bubbles/scripts/autonomy-posture-guard.sh` and `bubbles/scripts/autonomy-posture-guard-selftest.sh` (SCOPE-2 gate G135 extension) · `prompts/bubbles.continue.prompt.md` (SCOPE-4 new shim) · `docs/guides/AUTONOMOUS_EXECUTION.md`, `docs/guides/WORKFLOW_MODES.md`, `docs/guides/AGENT_MANUAL.md`, `docs/guides/INSTALLATION.md`, `docs/MCP.md`, `docs/CHEATSHEET.md`, `docs/recipes/resume-work.md`, `README.md` (SCOPE-4/SCOPE-5 documentation and counts — owner: `bubbles.docs`) · `improvements/INDEX.md` (SCOPE-6 audit history) · `bubbles/workflows.yaml` and `bubbles/registry/gates.yaml` (SCOPE-7 G086 description) · `agents/bubbles.goal.agent.md` and the other three runners plus `docs/guides/AUTONOMOUS_EXECUTION.md` (SCOPE-9 completion predicate) · `bubbles/scripts/state-snapshot.sh` and `bubbles/scripts/state-snapshot-selftest.sh` (SCOPE-10 reconciliation record) · `bubbles/release-manifest.json` (regenerated after any managed-file change).
