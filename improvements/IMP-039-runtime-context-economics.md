# IMP-039 — Runtime context economics: measure the real prompt cost, bound what re-enters context, and resolve the output-policy contradiction

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A live VS Code agent session in a downstream repo consumed 2,606,430 prompt tokens and 732.468 Copilot credits across 13 requests while producing 8,931 output tokens and 12 patches. The session was audited against the host's own per-request billing records. Half the spend was replayed tool output, and the framework's own always-on instruction told the agent to keep producing it.
**Verified gaps addressed:** COST-4 (runtime prompt cost unmeasured), COST-5 (session caps have no context-volume dimension), COST-6 (per-request always-on and tool-definition overhead unbounded), COST-7 (compaction governs the ledger, not the live transcript), EV-7 (output policy contradicts the evidence path and defaults to the expensive branch)

## Provenance

Measured input: the host's per-request records for one live agent session, read from
`~/Library/Application Support/Code/User/workspaceStorage/<workspace-id>/chatSessions/<session-id>.jsonl`.
Each completed request carries `promptTokens`, `completionTokens`, `copilotCredits`, `modelId`, and a
`promptTokenDetails` breakdown. Framework source verified at `365d6d9` (VERSION 7.25.0), clean tree.

Measured session totals (13 requests; 8 metered, 5 without usage fields at capture time):

| Measure | Value |
|---|---|
| Prompt tokens | 2,606,430 |
| Completion tokens | 8,931 |
| Completion share of all tokens | 0.34% |
| Copilot credits | 732.468 |
| Largest single request | 513,145 prompt tokens |
| Most expensive single request | 201.545 credits (467,209 prompt tokens) |

Prompt composition across the 8 metered requests, derived from `promptTokenDetails` percentage
buckets (integer percentages, so category totals are approximate and sum to within 0.1% of the
prompt total):

| Category | Tokens | Share |
|---|---|---|
| Tool results | 1,295,690 | 49.7% |
| System instructions | 543,000 | 20.8% |
| Messages | 422,665 | 16.2% |
| Tool definitions | 327,877 | 12.6% |
| Files | 17,755 | 0.7% |

Retained tool records in the same session: 321 unique tool calls totalling 1,980,555 serialized
bytes; 144 were terminal calls (1,771,924 bytes); 18 terminal calls of 50 KB or larger accounted
for 1,130,328 bytes. One background terminal notification entered the conversation as a single
42,080-character user turn.

Caveat carried deliberately: "System instructions" is the host's own bucket. It contains the host
base prompt together with every `applyTo` instruction file. The measurement does NOT separate the
framework's share from the host's, and this proposal does not claim it does.

## Problem (verified against source)

- **EV-7 — the output policy contradicts the evidence path, and the expensive branch is the always-on one.**
  `templates/terminal-discipline.instructions.md.tmpl` ships with `applyTo: "**"` and states
  "Always capture and display the FULL unfiltered output". `agents/bubbles_shared/evidence-rules.md`
  states the opposite for evidence: "When a script's output is >100 lines, capture only the relevant
  10-30 line window". `bubbles/scripts/evidence-capture.sh` already implements a compact form whose
  own header argues it is STRONGER than a transcript, because a sha256 can be re-derived and a paste
  cannot. The strong, cheap path exists and is shipped. The always-on instruction still mandates the
  weak, expensive one, and nothing refuses the contradiction.

- **COST-4 — the only cost surface the framework reports is a reachability proxy, and it is labelled as cost.**
  `bubbles/scripts/effective-bundle-measure.sh` opens by warning that it measures documentation
  linkage, not loaded context, and that the figure "MUST NOT be budgeted as one".
  `bubbles/scripts/bundle-cost-report.sh` multiplies that same closure by dispatch count and calls
  the result `costProxy`, and `agents/bubbles.retro.agent.md` renders it under a heading named
  "Context Cost". `bubbles/workflows.yaml` excludes `tokenCount` with the reason "Not exposed by
  VS Code Copilot API". That exclusion is correct about the API and incomplete about the host: the
  numbers above were read from a host-written artifact on disk. No adapter reads it.

- **COST-5 — the aggregate session cap cannot see context volume.**
  `bubbles/scripts/session-cap-guard.sh` (Gate G128) enforces exactly three dimensions:
  `maxTotalConvergenceIterations`, `maxWallClockMinutes`, `maxToolCalls`. A session can hold every
  one of them and still carry 1.77 MB of terminal records into every later request. The measured
  session did precisely that.

- **COST-6 — per-request overhead is unbounded and partly avoidable.**
  Tool definitions averaged roughly 40,985 tokens per metered request.
  `agents/bubbles.workflow.agent.md` grants nine tool families
  (`read, search, edit, agent, todo, web, execute, bubbles, playwright`) to an agent whose body
  describes routing. Two shipped instructions carry `applyTo: "**"`:
  `instructions/bubbles-agents.instructions.md` (15,754 bytes) and
  `instructions/bubbles-env-pollution-isolation.instructions.md` (4,933 bytes). The first is
  authoring guidance for `*.agent.md` files and is paid on every unrelated request.
  `instruction-budget-lint.sh` counts directive density per agent file; nothing bounds the
  always-on instruction surface or the granted tool surface.

- **COST-7 — compaction discipline governs the repository ledger, not the model transcript.**
  `bubbles/scripts/context-compactor.sh` compacts a RESULT-ENVELOPE into a JSON record in
  `.specify/memory/bubbles.session.json`. Gate G083 then checks that those records carry a
  `compactedAt`. Neither touches the host conversation. G083 can pass on every envelope while the
  live prompt grows monotonically, which is what the measured session shows: request 1 at 162,455
  prompt tokens, request 13 at 513,145, with zero host compaction checkpoints.

- **Incidental, verification required before action.** `instructions/wsl-macos-compatibility.instructions.md`
  carries `applyTo: "**"`, exists byte-identical in six downstream repositories, and has no entry in
  `bubbles/release-manifest.json` and no template. It is therefore distributed but outside
  managed-file integrity. This proposal does NOT assume that is a defect; the owner should confirm
  whether the file is framework-managed or project-owned before any scope touches it.

## Proposal

### SCOPE-1 — Make bounded retention the single default and refuse the contradiction (EV-7)

- Rewrite section 2 of `templates/terminal-discipline.instructions.md.tmpl` and the source-repo
  `.github/instructions/terminal-discipline.instructions.md` to separate two things the current text
  conflates: what a command must PRODUCE, and what re-enters the model context. Full output must
  still be produced and captured in full. The anti-truncation rule keeps its target, which is the
  agent silently discarding a failure line it did not want to see.
- State the replacement rule directly. Above 40 lines, route the command through
  `bubbles/scripts/evidence-capture.sh`. The block carries the command, the exit code, the line
  count, a sha256 over the FULL output, and the first and last 20 lines. Retain failure-shaped lines
  preferentially; `bubbles/scripts/guard-lib.sh` already provides that helper.
- Add `bubbles/scripts/output-policy-coherence-guard.sh` plus a hermetic selftest. It fails when a
  canonical instruction reasserts an unbounded-display mandate while `evidence-rules.md` mandates
  windowing. This exists so the contradiction cannot silently return; it is the same
  regression-shape argument the evidence-capture selftest already makes for `--verify`.
- Wire the selftest into `framework-validate.sh` next to the existing evidence-capture check.

### SCOPE-2 — Optional host-usage adapter, and stop calling the proxy a cost (COST-4)

- Add `bubbles/adapters/usage/` with the framework's existing adapter shape and `none` as the
  default, matching `bubbles/adapters/codeindex/` and the observability adapter. Default `none`
  means no behavior change for any repo.
- A configured adapter normalizes one record per request: `promptTokens`, `completionTokens`,
  `model`, `credits`, `toolResultBytes`, `compactionCheckpoints`. A reference adapter reads the
  VS Code host artifact named in Provenance.
- Refuse to estimate. With no adapter, every consumer reports `unmeasured`. Deriving a token count
  or a dollar figure from anything other than a host record is fabrication, and the existing
  exclusion list in `workflows.yaml` stays correct for that reason. Amend only the stated reason,
  from "not exposed" to "not exposed by the API; readable only through a configured usage adapter".
- Rename the reachability surface so it stops reading as spend. `bundle-cost-report.sh` keeps its
  measurement and renames `costProxy` to `referenceClosureProxy`; `bubbles.retro` renames the
  "Context Cost" heading to "Reference Closure". This is the direct lesson of IMP-028, which was
  closed after its reduction premise measured false.

### SCOPE-3 — Extend `sessionBudget` with context dimensions (COST-5)

- Add four optional caps, each defaulting to `null`, which preserves G128's current no-op posture
  for every existing repository: `maxSingleToolResultBytes`, `maxCumulativeToolResultBytes`,
  `maxPromptTokensPerRequest`, `maxCumulativePromptTokens`.
- Enforce them in `session-cap-guard.sh` under the rule the script already applies: a cap that is
  null is not enforced, and a cap whose dimension is unmeasurable is skipped rather than guessed.
  Byte dimensions are measurable without an adapter. Token dimensions require SCOPE-2.
- Suggested starting values for an operator who opts in, derived from the measured session rather
  than chosen for roundness: 50 KB single tool result, 250 KB cumulative tool results, 220,000
  prompt tokens per request, 1,000,000 cumulative prompt tokens. The measured session exceeded three
  of these.
- Keep the existing rule that `unattended` posture requires a non-null budget. A run that will not
  stop on its own has already forfeited the right to be unbounded.

### SCOPE-4 — Bind compaction to the live transcript (COST-7)

- Require the orchestrator to reach a context boundary at each phase transition, not merely to write
  a ledger record. Acceptable boundaries: a host compaction checkpoint, or a fresh specialist
  context carrying only the persisted envelope.
- Record the boundary in `bubbles.session.json` as `contextBoundary: { kind, checkpointId, at }`.
  Extend G083 to check that the boundary exists, so the gate measures the thing it is named for.
- Where the host exposes no compaction primitive, the orchestrator declares
  `contextBoundary.kind: "unavailable"` and starts a fresh specialist context instead. Declaring
  unavailability is honest; passing a gate while the transcript grows is not.

### SCOPE-5 — Least-privilege tool grants (COST-6)

- Derive each agent's `tools:` frontmatter from the phases it owns. A pure router does not need
  `playwright`, `web`, `execute`, or `edit`.
- Add a lint that flags a granted tool family that no owned phase requires. Ship it advisory first
  and report the measured per-agent delta before anything blocks.
- Change one agent, measure, then ratchet. The dispatch-control fields are runtime-enforced, so an
  over-narrow grant silently breaks routing; this is the failure mode
  `bubbles-vscode-agent-constraints` already documents.

### SCOPE-6 — Scope the always-on instruction surface (COST-6)

- Narrow `instructions/bubbles-agents.instructions.md` from `applyTo: "**"` to the surfaces it
  governs: `**/*.agent.md`, `**/*.prompt.md`, `**/*.instructions.md`, `**/skills/**`. It is
  authoring guidance for agent files and does not need to price every unrelated request.
- Keep a compact universal kernel always on. Anti-fabrication, evidence integrity, and the
  repository-binding refusal are invariants and must not become conditional.
- Narrow `instructions/bubbles-env-pollution-isolation.instructions.md` to test, compose, monitoring,
  and backup surfaces, which is where its rules bite.
- This continues the axis IMP-036 SCOPE-5 opened. That scope reduced always-on context from 850 to
  545 lines and recorded that for one file "only the `applyTo: \"**\"` header was the cost". The
  same header is still on the two largest shipped instructions.

### SCOPE-7 — Verbosity posture: one default, no second mode (COST-4, EV-7)

- Record the measurement that settles the question. Completion tokens were 8,931 of 2,615,361 total,
  which is 0.34%. A quieter narrative mode optimizes 0.34% of spend and leaves 99.66% untouched.
- Decision: do NOT introduce a chatty/not-chatty mode. Ship one bounded default plus a per-invocation
  diagnostic escalation on the capture tool for the case where a human genuinely needs the whole
  transcript. The escalation is explicit, bounded, and logged.
- Where an attended/unattended difference genuinely matters, bind it to the autonomy posture that
  already exists in `workflows.yaml`. Do not add a second orthogonal axis that every gate, selftest,
  and agent would then have to be correct under twice.
- Record the reasoning in `agents/bubbles_shared/operating-baseline.md` so the question is settled
  with a number rather than reopened by preference.

## Migration / rollout

- SCOPE-1 first. It is the only scope that changes a NON-NEGOTIABLE policy file, and the remaining
  scopes are cheaper to argue once the contradiction is gone.
- SCOPE-2 next, because SCOPE-3's token dimensions and SCOPE-7's claim both depend on measured input.
  It is additive and inert at `none`.
- SCOPE-3 and SCOPE-4 follow. SCOPE-3 is default-null and therefore a no-op until an operator opts
  in. SCOPE-4 changes orchestrator behavior and needs its own selftest.
- SCOPE-5 and SCOPE-6 last, one surface at a time, advisory before blocking. Both narrow something
  currently broad, so both can remove a rule that was load-bearing.
- SCOPE-7 is doc-only and can land beside SCOPE-1.

## Risks & mitigations

- **R1 — bounded retention hides the line that mattered.** → The sha256 covers the full output, the
  exit code is always shown, failure-shaped lines are retained preferentially, and `--verify`
  re-derives the hash. A reviewer can re-run and detect drift, which a pasted transcript never
  allowed.
- **R2 — a usage adapter invents numbers.** → Default `none`, no estimation path, and `unmeasured`
  as the honest output. The workflows.yaml exclusion of derived dollar figures stays.
- **R3 — this repeats IMP-028 and optimizes a proxy.** → Every threshold in SCOPE-3 is set against
  measured host records, never against closure bytes. SCOPE-2 renames the proxy specifically so it
  stops being mistaken for spend.
- **R4 — narrowing `applyTo` drops a load-bearing rule.** → A universal kernel keeps the invariants,
  rollout is advisory first, and the narrowed files are governance for surfaces the glob still
  matches.
- **R5 — narrowing tool grants breaks dispatch silently.** → Frontmatter is runtime-enforced, so the
  lint ships advisory, one agent changes at a time, and dispatch is validated before the next.
- **R6 — new caps stop legitimate long work.** → All four default to `null`. An unmeasurable
  dimension is skipped, not guessed.
- **R7 — SCOPE-4 assumes a host compaction primitive that may not exist.** → `unavailable` is an
  explicit, declarable state with a fresh-context fallback.

## Acceptance criteria (when implemented)

- No canonical instruction instructs an agent to display unbounded command output, and
  `output-policy-coherence-guard.sh` fails when that text is reintroduced. SCOPE-1.
- A command producing more than 40 lines yields a compact block whose recorded sha256 re-verifies
  against a re-run, and whose exit code is present. SCOPE-1.
- With no usage adapter configured, every cost surface reports `unmeasured` and no token or dollar
  figure appears anywhere. SCOPE-2.
- With the reference adapter configured, a retrospective reports real prompt tokens, completion
  tokens, model, and credits for the session, and the heading "Context Cost" no longer refers to
  closure bytes. SCOPE-2.
- A repository that sets `maxSingleToolResultBytes: 50000` sees G128 refuse a session that retains a
  larger single tool result, and a repository that sets nothing sees no behavior change. SCOPE-3.
- Every phase transition records a `contextBoundary`, and G083 fails when the boundary is absent.
  SCOPE-4.
- The measured re-run of a comparable session shows tool results below 25% of later prompts, no
  single request above 220,000 prompt tokens, and no gate-detection or completion-quality
  regression against the golden-task corpus. SCOPES 1, 3, 4.
- `bubbles.workflow` grants no tool family that no phase it owns requires, and dispatch still
  resolves for every mapped mode. SCOPE-5.
- The always-on shipped instruction surface is measurably smaller, and anti-fabrication, evidence,
  and repository-binding rules remain always-on. SCOPE-6.
- `operating-baseline.md` records the 0.34% measurement and the single-default decision, and no
  chatty/not-chatty mode exists in `workflows.yaml`. SCOPE-7.

## Files to touch (on approval)

`templates/terminal-discipline.instructions.md.tmpl` and `.github/instructions/terminal-discipline.instructions.md`
(bounded-retention rule; owner: repo governance),
`agents/bubbles_shared/evidence-rules.md` (state the compact form as the default evidence shape; owner: `bubbles.audit`),
`skills/bubbles-evidence-capture/SKILL.md` (promote the compact form from "above roughly 40 lines" guidance to the default; owner: repo governance),
`bubbles/scripts/output-policy-coherence-guard.sh` and its selftest (new; owner: `bubbles.validate`),
`bubbles/adapters/usage/` (new adapter contract, `none` default; owner: `bubbles.devops`),
`bubbles/scripts/bundle-cost-report.sh` and `agents/bubbles.retro.agent.md` (rename the proxy; owner: `bubbles.retro`),
`bubbles/workflows.yaml` (`sessionBudget` dimensions, amended exclusion reason, `contextBoundary` schema; owner: repo governance),
`bubbles/scripts/session-cap-guard.sh` and its selftest (G128 dimensions; owner: `bubbles.validate`),
`bubbles/scripts/compaction-discipline-guard.sh` and `bubbles/scripts/context-compactor.sh` (G083 boundary check; owner: `bubbles.validate`),
`agents/bubbles.workflow.agent.md` and sibling agent frontmatter (tool grants; owner: `bubbles.setup`),
`instructions/bubbles-agents.instructions.md` and `instructions/bubbles-env-pollution-isolation.instructions.md` (`applyTo` narrowing; owner: repo governance),
`agents/bubbles_shared/operating-baseline.md` (verbosity decision and the measurement behind it; owner: repo governance),
`bubbles/scripts/framework-validate.sh` (wire the new selftests; owner: `bubbles.validate`),
`bubbles/release-manifest.json` (regenerate for any added script; owner: release tooling).
