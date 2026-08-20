# IMP-052 — G022 synthesises a phantom phase owner, so an honest packet has no satisfiable path

**Status:** IN PROGRESS 2026-08-19 — SCOPE-1 and SCOPE-2 delivered; SCOPE-3 not started
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A downstream bug packet recorded three phases truthfully — `discovery`, `documentation`, `analysis`, all executed by `bubbles.bug`, which is the agent the framework's own bug-agent definition instructs to execute them — and Gate G022 Check 6B refused all three. It refused them because it derived their owners by string concatenation, demanding `bubbles.discovery`, `bubbles.documentation`, and `bubbles.analysis`, none of which have ever existed as agents. Every route to a green gate from that state requires writing something false: a fabricated expansion reason, a fabricated executor, or the deletion of a true record. An anti-fabrication gate whose only satisfiable path is a false record is teaching agents to lie to it, and that is a worse outcome than the gate not existing.
**Verified gaps addressed:** EV-15 (a provenance gate can reach a state where no truthful record satisfies it, so its incentive inverts from honesty to fabrication); REG-17 (`executionHistory[].agent` is enum-constrained against a registry while the phase-name fields beside it are unconstrained free text, and the two shipped surfaces that name phases disagree)

## Provenance

Authored from direct source reading rather than a runtime telemetry export, and
independently re-verified against the committed baseline before delivery.

| Input | What it established |
|---|---|
| `bubbles/scripts/state-transition-guard.sh` at the committed baseline (4830 lines) | `phase_owner_agent()` is defined at lines 1970-1993; line 1976 special-cases `analyze) legacy='bubbles.analyst'`; line 1977 is the unguarded general rule `*) legacy="bubbles.$phase"` |
| A downstream bug packet recording `discovery`, `documentation`, `analysis`, all executed by `bubbles.bug` | Gate G022 Check 6B refused all three, demanding `bubbles.discovery`, `bubbles.documentation`, `bubbles.analysis` — none of which exist as agents |
| `bubbles/workflows.yaml` phase registry vs the bug-agent definition | the two shipped surfaces that name phases disagree, so a truthful packet can name a phase the registry never declares |
| Independent re-verification via `git show HEAD` | the concatenation rule reproduces exactly at the committed baseline, and is NOT reachable in the delivered resolver, where `resolve_phase_owner()` returns `owner-missing` before any derivation is attempted |
| `state-transition-guard-selftest.sh` after the change | passes with 0 failures; adds 53 lines of new coverage and introduces no new shellcheck findings (92 at baseline, 92 after) |

Claims carried in from the reporting brief are marked CONFIRMED where they
reproduced exactly and CORRECTED where they did not; two required correction,
and one of those corrections materially changed which remedies were viable.

## Problem (verified against source)

Every line citation below was produced by reading the named file in this
repository during this session. `bubbles/scripts/state-transition-guard.sh` is
4830 lines. Claims carried in from the reporting brief are marked CONFIRMED where
they reproduced exactly and CORRECTED where they did not; two required
correction, and one of the corrections materially changes which remedies are
viable.

- **EV-15 — the owner is derived by concatenation, and the derivation is
  unguarded (CONFIRMED).** `phase_owner_agent()` is defined at lines 1970-1993 of
  `bubbles/scripts/state-transition-guard.sh`. Line 1976 special-cases
  `analyze) legacy='bubbles.analyst'`. Line 1977 is the general rule:
  `*) legacy="bubbles.$phase"`. Line 1982 reads the declared owner from the
  registry with `.phases[strenv(_pa_phase)].owner // ""`. The dispatch at line
  1985 then treats an empty `declared` as "use the synthesised legacy name". So
  when the registry does not answer, the guard invents an agent identity from the
  phase string and requires provenance from it.

- **EV-15 — the synthesis is applied to arbitrary strings, not merely to three
  known ones (NEW — the reporting brief scoped this too narrowly).** Extracting
  lines 1970-1993 verbatim and running them against `bubbles/workflows.yaml`
  produces:

  | claimed phase | owner set the guard will accept |
  |---|---|
  | `discovery` | `bubbles.discovery` |
  | `documentation` | `bubbles.documentation` |
  | `analysis` | `bubbles.analysis` |
  | `simplify` | `bubbles.simplify` |
  | `audit` | `bubbles.audit` |
  | `bug-discovery` | `bubbles.bug bubbles.bug-discovery` |
  | `docs` | `bubbles.docs` |
  | `analyze` | `bubbles.workflow bubbles.goal bubbles.sprint bubbles.iterate bubbles.analyst` |
  | `totally-made-up-phase` | `bubbles.totally-made-up-phase` |

  The final row is the finding. There is no registry-membership check and no
  agent-existence check anywhere on this path. Any string that reaches
  `completedPhaseClaims` becomes a demand for an agent named after it. The three
  names in the live packet are instances of a general defect, not the defect
  itself.

- **EV-15 — the demanded agents do not exist (CONFIRMED).** `ls agents/ | grep
  -iE 'discovery|documentation|analysis'` returns nothing.
  `grep -rlnE 'bubbles\.discovery|bubbles\.documentation|bubbles\.analysis'` over
  `agents/`, `prompts/`, and `bubbles/` returns nothing. The gate demands
  provenance from identities the framework has never defined, so the demand
  cannot be met by dispatching anything.

- **EV-15 — the code already knows this failure mode and fixed only half of it
  (CONFIRMED, and it sharpens the finding).** The comment at lines 1957-1968 states
  that deriving the owner blindly "made Check 6B demand agents that have never
  existed", and names `bubbles.bug-discovery`, `bubbles.certify-state`,
  `bubbles.interrogate`, `bubbles.select`, and the removed `bubbles.bootstrap`.
  BUG-020's repair was to read `phases.<phase>.owner` from the registry. That
  correctly rescues every phase the registry *knows*. It leaves the synthesis
  fully intact as the fallback for every phase the registry does *not* know, which
  is precisely the population the comment is describing. The lesson was recorded
  and the mechanism that produces it was retained.

- **EV-15 — the `bubbles.bug` delegation shortcut covers two phases only
  (CONFIRMED).** Line 2015 reads
  `elif [[ "$claimed_phase" == "implement" || "$claimed_phase" == "test" ]] && … $1=="bubbles.bug"`.
  The comment above it at line 2014 is `# bubbles.bug delegation shortcut for
  implement/test`. Discovery, documentation, and analysis are outside it, even
  though they are the phases `bubbles.bug` most obviously owns.

- **EV-15 — Pass 2 cannot be used truthfully here (CONFIRMED).** The
  parent-expansion path requires `expandedBy` to be a registered orchestrator, an
  `expansionReason` of at least 20 characters, an `expansionEvidenceRef` that
  resolves to a real file, and — at line 2049 — that the reason match
  `runSubagent|tool unavailable|nested runtime|capability missing|parent-expand|nested workflow`
  (the regex is defined at line 1932). Every one of those tokens asserts that a
  capability was missing. In the live packet no capability was missing:
  `bubbles.bug` was available, was dispatched, and did the work. Using Pass 2
  would require asserting a cause that did not occur. The gate's only unlocked
  door opens onto a lie.

- **REG-17 — the three names are not phases with a missing owner; they are not
  phases at all (CORRECTED — this is the material correction).** The reporting
  brief described `discovery`, `documentation`, and `analysis` as phases that
  "have NO declared owner". The `yq` probe it prescribed does return
  `<undeclared>` for all three, so the symptom reproduces — but the cause is
  different. `.phases` holds 30 keys:

  ```
  analyze discover select bootstrap harden gaps bug implement test docs validate
  audit chaos redteam journey regression simplify stabilize devops security
  spec-review retro code-review system-review releases bug-discovery
  certify-state interrogate clarify finalize
  ```

  `.phases | has("discovery")`, `has("documentation")`, and `has("analysis")` all
  return `false`. And
  `yq '.phases | to_entries[] | select((.value.owner // "") == "") | .key'`
  returns **empty** — every registered phase declares an owner. There are zero
  orphaned registered phases in `bubbles/workflows.yaml`. The three names are
  unregistered vocabulary. This changes the remedy set: "declare owners for the
  three phases" is not adding an `owner:` key to three existing entries, it is
  adding three new entries to the phase registry.

- **REG-17 — the nearest registered phases already exist and are already owned
  correctly (NEW).** `bug-discovery` is owned by `bubbles.bug`, `docs` by
  `bubbles.docs`, and `analyze` by `activeWorkflowRunner`. The framework has
  already applied the spirit of "declare the real owner" — to a different
  spelling of the same three concepts.

- **REG-17 — the unregistered names come from a shipped framework agent, not from
  a careless packet (NEW, and it is the root of the contradiction).**
  `agents/bubbles.bug.agent.md` instructs the agent to write exactly these
  strings: line 291 `execution.currentPhase: "discovery"`, line 339
  `execution.currentPhase: "documentation"`, line 386
  `execution.currentPhase: "analysis"`. Line 399 then writes `"implement"`, which
  *is* registered — so the file straddles both vocabularies. A packet that
  recorded `discovery`, `documentation`, and `analysis` obeyed its agent. Two
  shipped framework surfaces name phases and they disagree, and the guard
  validates against one of them while the agent writes the other.

- **REG-17 — the sibling field is enum-constrained; the phase fields are not
  (NEW).** `bubbles/scripts/agent-id-enum-lint.sh` exists precisely to stop
  free-text drift in this record. Its header states the contract: "agent MUST be a
  registered id from bubbles/agent-capabilities.yaml", motivated by a measured 163
  distinct `agent` values across 15,685 invocations. No equivalent constraint
  exists for phase names. Of the eight scripts under `bubbles/scripts/` that
  reference `phasesExecuted`, none compares a phase name against the `.phases`
  keys. The control plane guards the agent column of the same record and leaves
  the phase column open, which is how a vocabulary fork survived to reach a gate.

### Downstream evidence (measured in the `smackerel` consumer, not in this repository)

Measured against
`specs/061-conversational-assistant/bugs/BUG-061-011-eval-gate-runs-in-no-automated-lane/`
in the `smackerel` consumer during this session. This repository holds no
persistent `specs/` execution packets (Gate G085), so the population does not
exist here to re-measure.

The packet's recorded execution history is internally consistent and truthful:

| agent | phasesExecuted | provenanceMode |
|---|---|---|
| `bubbles.bug` | discovery, documentation, analysis | specialist |
| `bubbles.implement` | implement | specialist |
| `bubbles.test` | test | specialist |
| `bubbles.validate` | validate | specialist |
| `bubbles.regression` | regression | specialist |
| `bubbles.goal` | simplify, stabilize, security, audit | specialist |
| `bubbles.simplify` | simplify | specialist |
| `bubbles.stabilize` | stabilize | specialist |
| `bubbles.security` | security | specialist |
| `bubbles.audit` | audit | specialist |

Running the installed transition guard against the packet yields
`failureCount: 10`, `failedGateIds: [G022, G027, G136]`, `verdict: FAIL`. The
Check 6B section reports:

```
✅ PASS: Phase 'simplify' has specialist provenance from bubbles.simplify
✅ PASS: Phase 'security' has specialist provenance from bubbles.security
✅ PASS: Phase 'audit' has specialist provenance from bubbles.audit
✅ PASS: Phase 'stabilize' has specialist provenance from bubbles.stabilize
🔴 BLOCK: Phase 'analysis' is in completedPhaseClaims but no specialist or parent-expanded provenance found (Gate G022)
🔴 BLOCK: Phase 'discovery' is in completedPhaseClaims but no specialist or parent-expanded provenance found (Gate G022)
🔴 BLOCK: Phase 'documentation' is in completedPhaseClaims but no specialist or parent-expanded provenance found (Gate G022)
🔴 BLOCK: 3 phase claim(s) lack proper agent provenance — phase impersonation detected
```

Two properties of that output matter more than the count.

First, the gate is working correctly on the registered phases. `simplify`,
`stabilize`, `security`, and `audit` were each blocked earlier and were each
cleared by dispatching the real declared specialist — the packet's git history
carries one commit per phase doing exactly that (`198a8313`, `a9ac3e21`,
`5e5f5da7`, `aec892de`). That is the behaviour the gate exists to produce, and it
produced it. The proposal is not that G022 is too strict.

Second, the remaining three have no such move available, because the agent the
gate demands cannot be dispatched. The packet's `report.md` records the guard's
`failureCount` falling 52 → 26 → 14 as genuine work landed, and the live run now
reports 10. The reporting brief described this as "26 to 10 this session"; the
recorded trajectory is 52 → 26 → 14 and the current live value is 10, so the
direction and the endpoint reproduce and the starting point was higher than
stated. The residual is not shrinking further, because the three G022 blocks are
structurally unreachable rather than unfinished.

The installed registry in the consumer is byte-equivalent on this surface: its
`.phases` key set is identical to the source repository's (`diff` of the two key
lists is empty), and `has("discovery")`, `has("documentation")`, `has("analysis")`
are all `false` there too. The defect is in the shipped framework, not in a
consumer's local edit.

## Proposal

Four candidate mechanisms, then a recommendation. SCOPE-1 chooses the corrective;
SCOPE-2 states the constraint that binds whichever corrective is chosen; SCOPE-3
is the preventive and is landable independently.

### SCOPE-1 — Decide how an unregistered phase name resolves its owner (EV-15, REG-17)

**Option A — register the three names as phases owned by `bubbles.bug`.** Add
`discovery`, `documentation`, and `analysis` to `.phases` in
`bubbles/workflows.yaml` with `owner: bubbles.bug`, matching what
`agents/bubbles.bug.agent.md` already writes.

- Clears: the three live blocks immediately, and every existing packet written
  under the bug agent's current instructions.
- Cost: lowest of the correctives — three registry entries.
- Residual risk: it enlarges the phase vocabulary with near-duplicates of
  `bug-discovery`, `docs`, and `analyze`, so the registry would then contain two
  spellings for each of three concepts. That is the drift that produced this
  finding, entrenched rather than resolved.
- Leaves untouched: the synthesis mechanism. The next unregistered phase name
  reproduces the bug exactly.

**Option B — reconcile the agent to the registry vocabulary.** Change
`agents/bubbles.bug.agent.md` lines 291, 339, and 386 to write `bug-discovery`,
`docs`, and `analyze`.

- Clears: **two of three**, verified rather than assumed. `bug-discovery` is owned
  by `bubbles.bug`, so it passes Pass 1 directly. `analyze` is owned by
  `activeWorkflowRunner`, and `bubbles.bug` **is** present in
  `workflowModeGrants.agents` in `bubbles/agent-capabilities.yaml`, so it passes
  too. `docs` is owned by `bubbles.docs` and would **still** fail, because the
  executor was `bubbles.bug`.
- Cost: low in the framework, non-trivial downstream. Every packet already written
  with the old spellings keeps failing until it is edited, and editing a certified
  planning artifact has its own consequences under Gate G088 (see IMP-049).
- Residual risk: none to the registry, but it surfaces a real design question
  rather than answering it — should `bubbles.bug` be authoring bug documentation
  at all, or should the `docs` phase be dispatched to `bubbles.docs`? That
  question deserves a deliberate answer, not a rename that hides it.
- Leaves untouched: the synthesis mechanism.

**Option C — widen the `bubbles.bug` delegation shortcut.** Extend line 2015 to
accept `discovery`, `documentation`, and `analysis` alongside `implement` and
`test`.

- Clears: all three live blocks.
- Cost: smallest diff of any option — one conditional.
- Residual risk: it introduces a fourth place where phase vocabulary is written
  down, hardcoded inside a guard, disagreeing with both the registry and the
  agent. It also grants `bubbles.bug` blanket provenance over three phases with no
  registry entry recording that ownership, so the fact becomes invisible to
  everything except this one `elif`.
- Leaves untouched: the synthesis mechanism.

**Option D — make the fallback existence-aware and registry-aware.** When
`.phases.<phase>` is absent, or when the synthesised `bubbles.$phase` matches no
agent file, do not demand the phantom.

- Clears: all three live blocks, **and** the general case — the
  `totally-made-up-phase` row above stops producing an impossible demand.
- Cost: moderate. It changes the behaviour of a blocking gate.
- Residual risk: **this is the option that can go badly wrong, and the failure
  mode must be designed for explicitly.** If "no resolvable owner" degrades to a
  pass, G022 acquires a trivial bypass: invent a phase name and provenance is no
  longer checked for it. That would convert a gate that currently over-refuses
  into one that silently under-refuses, which is strictly worse. Option D is only
  viable in the form SCOPE-2 describes.

**Recommendation: Option D, bound to SCOPE-2's constraint and landed together with
SCOPE-3.**

The reasoning is that A, B, and C each repair three instances and leave the
mechanism that generated them running. The verbatim reproduction above shows the
mechanism accepts arbitrary input; the code comment at lines 1957-1968 shows it
has already produced at least five phantom demands before these three. A remedy
that does not touch the synthesis will be back. Option D is the only candidate
that addresses why the demand was impossible rather than which three demands were
impossible.

Option D alone, however, is a bypass. Bound to SCOPE-2 it is not: an unregistered
phase name stops producing a phantom demand and starts producing a *different,
specific, actionable* refusal that names the vocabulary mismatch. The packet still
fails — it should, because it is recording a phase the framework does not define
— but it fails with a message whose remedy is real work rather than a fabrication.

Option B remains worth doing afterwards as the vocabulary settlement, and its
two-of-three result should be taken as the useful finding it is: the `docs`
ownership question is genuine and should be answered on its merits.

### SCOPE-2 — An unresolvable owner must refuse differently, never pass (EV-15)

Whichever corrective SCOPE-1 selects, one constraint binds it. A provenance gate
that cannot resolve an owner has learned something important and must say so; it
must not fall silent.

- If the phase is absent from `.phases`, refuse with a distinct message naming the
  unregistered phase and the registry it is missing from. Do not synthesise an
  owner and do not skip the check.
- If the phase is registered but the declared owner names an agent with no
  definition file, refuse with a distinct message naming the broken registry
  entry. That is a framework defect and should be reported as one, not charged to
  the packet.
- In neither case may the outcome be `pass`. The distinction being introduced is
  between "this record is unprovable" and "this record is unprovable *and the
  framework cannot state what would prove it*". Both refuse; only the second is
  the framework's own bug.
- Record the existing `requiresRevalidation`-style unvalidated escapes elsewhere
  in the gate chain as the precedent consciously not repeated here. No new
  self-asserted exemption field is introduced by this proposal.

### SCOPE-3 — Constrain phase names at declaration time, as agent ids already are (REG-17)

`bubbles/scripts/agent-id-enum-lint.sh` already solves the identical problem for
the adjacent column of the same record, including the migration strategy. Reuse
its shape rather than inventing one.

- Constrain `executionHistory[].phasesExecuted[]` and
  `execution.completedPhaseClaims[]` to keys present in `.phases` in
  `bubbles/workflows.yaml`.
- Use the same ratchet the agent-id lint uses: freeze pre-existing unknown phase
  names in a baseline file, fail only on names that are neither registered nor
  baselined, and report a baselined name that no longer appears as stale so the
  file can only shrink. Six consuming repositories carry packets written under the
  current free-text rule; a hard cliff would make the lint unrunnable, exactly as
  the agent-id lint's own header explains.
- Add the reciprocal authoring-time check: fail when a shipped agent definition
  instructs an agent to write a `currentPhase` value that `.phases` does not
  register. That check, run today, would flag
  `agents/bubbles.bug.agent.md` lines 291, 339, and 386 — which is the point. The
  contradiction becomes a lint finding at authoring time instead of an
  unsatisfiable packet gate weeks later.
- This scope composes with every SCOPE-1 option and is the only one that prevents
  recurrence rather than repairing an instance. Under Option A the baseline starts
  empty because the three names become registered. Under Option B it holds the
  three old spellings until packets migrate. Under Option D it is what makes the
  new refusal path reachable at authoring time rather than at promotion time.

## Migration / rollout

- SCOPE-1 is a decision. Nothing lands until the owner selects an option, and this
  proposal stays `PROPOSED` until then.
- SCOPE-3 is additive and independently landable, and landing it first is
  preferable: its baseline measures how many distinct unregistered phase names
  exist across consuming repositories, which is the number that should inform the
  SCOPE-1 choice. If the population is only these three, Option A becomes more
  defensible than it looks today.
- SCOPE-2 lands with, and only with, whichever corrective SCOPE-1 selects. It has
  no standalone deliverable.
- Any change to Check 6B is a behaviour change to a blocking gate invoked inside
  `state-transition-guard.sh`. Sequence it so
  `bubbles/scripts/state-transition-guard-selftest.sh` and
  `bubbles/scripts/state-transition-required-specialists-selftest.sh` are extended
  in the same change, never after it.
- No packet that passes Check 6B today may fail it after the change. A corrective
  that newly refuses a currently-passing packet is a regression, and must be
  caught before it lands rather than discovered downstream.
- If Option B is selected, the downstream packet edits it requires interact with
  Gate G088 post-certification drift detection. Coordinate with IMP-049 rather
  than generating a fresh wave of G088 findings.

## Risks & mitigations

- **R1 Option D degrades into a silent pass and G022 acquires a trivial bypass.**
  This is the worst outcome in the proposal, because it converts an
  over-refusing gate into a quietly under-refusing one, and nobody notices a gate
  that stopped objecting. → SCOPE-2 makes "refuse differently" a precondition of
  Option D rather than a follow-up. Require an adversarial test that claims a
  fabricated phase name with no execution history and asserts the guard still
  fails. A corrective without that test must not land.
- **R2 The fix is scoped to the three observed names and the mechanism survives.**
  → The verbatim reproduction in this proposal is the evidence that the mechanism
  is general. Require any selected option to state, before implementation, what it
  does with a phase name nobody has seen yet, and verify that answer with a test
  rather than asserting it.
- **R3 SCOPE-3's ratchet baseline becomes a dumping ground.** An unknown phase
  name added to a baseline is a deferred decision, and a baseline that only grows
  is a lint that has stopped working. → Reuse the agent-id lint's stale-entry
  reporting, which makes a shrinking baseline observable and a growing one
  visible. State in the implementation that baseline growth is itself a finding.
- **R4 Renaming under Option B strands existing packets and triggers G088.** →
  Do not select Option B as the sole corrective. If it is chosen as a follow-on
  vocabulary settlement, sequence it behind a decision on IMP-049 so the redaction
  and reconciliation classes are not conflated.
- **R5 The `docs` ownership question gets settled by accident.** Option B's
  two-of-three result exposes a real question — whether `bubbles.bug` should
  author documentation or dispatch to `bubbles.docs` — and the cheapest way to
  make it go away is to widen a delegation shortcut and never answer it. → Record
  the question explicitly as an owner decision. Do not let a provenance repair
  silently reassign artifact ownership.
- **R6 The evidence is from a single consumer packet.** One packet is not a
  population. → The framework-side claims in this proposal — the synthesis, the
  missing agents, the narrow shortcut, the Pass 2 regex, the registry contents,
  the agent's prescribed strings — were all verified in **this** repository and
  stand independently of any consumer. The consumer packet demonstrates that the
  defect is reachable in practice; it is not load-bearing for the diagnosis.
  SCOPE-3's baseline produces the multi-consumer number if one is wanted.

## Acceptance criteria (when implemented)

- The owner has recorded a SCOPE-1 selection with the rejected options and the
  reason each was rejected, so the decision survives the session that made it.
- A bug packet recording `discovery`, `documentation`, and `analysis` executed by
  `bubbles.bug` reaches a state that is either passing or refused for a reason
  whose remedy is real work. No route to green requires an `expansionReason`
  describing a capability that was not missing, an executor that did not execute,
  or the deletion of a phase that ran.
- A `completedPhaseClaims` entry naming a phase absent from `.phases` produces a
  refusal that names the phase and the registry, and does **not** produce a demand
  for an agent that does not exist.
- A `completedPhaseClaims` entry naming a fabricated phase with no supporting
  `executionHistory` still fails. This is asserted by a test that fails if the
  discrimination is inverted, and it is the test that distinguishes this proposal
  from a bypass.
- Every packet that passes Check 6B before the change passes it after.
- If SCOPE-3 landed, `agents/bubbles.bug.agent.md` lines 291, 339, and 386 either
  write registered phase names or are reported as a lint finding, and the phase
  baseline is reportable and can only shrink.
- The transition-guard selftests cover the new resolution behaviour and pass under
  `bubbles/scripts/framework-validate.sh`.

## Files to touch (on approval)

`bubbles/scripts/state-transition-guard.sh` (`phase_owner_agent()` at lines
1970-1993, the delegation shortcut at line 2015, and the Pass 1/Pass 2 dispatch at
lines 2004-2072; owning gate: **G022 specialist_completion_gate**),
`bubbles/workflows.yaml` (the `.phases` registry — touched only if Option A is
selected; owning gate: **G022**), `agents/bubbles.bug.agent.md` (the prescribed
`execution.currentPhase` strings at lines 291, 339, 386 — touched only if Option B
is selected; owning agent: **`bubbles.bug`**),
`bubbles/scripts/state-transition-guard-selftest.sh` and
`bubbles/scripts/state-transition-required-specialists-selftest.sh` (hermetic
coverage of the new resolution behaviour and of R1's adversarial case; owning
gate: **G022**), `bubbles/registry/gates.yaml` (the G022 entry at lines 145-151,
whose `enforcedBy: [ guard-check:6B ]` and description must continue to match the
implemented behaviour; owning gate: **G022**), and — only if SCOPE-3 is approved —
a phase-name enum lint plus its ratchet baseline, modelled on
`bubbles/scripts/agent-id-enum-lint.sh` and its baseline file, registered
alongside the existing registry lints. `bubbles/agent-capabilities.yaml` is
**not** touched: `workflowModeGrants.agents` already lists `bubbles.bug`, which is
what makes the `analyze` resolution work today, and that entry is correct.
