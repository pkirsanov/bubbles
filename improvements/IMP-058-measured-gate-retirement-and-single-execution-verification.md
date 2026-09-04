# IMP-058 — Measured Gate Retirement and Single-Execution Verification

**Status:** IN PROGRESS — SCOPE-1 landed. `model-tier-advisory.sh retirement` now binds to `bubbles/registry/gates.yaml` (was silently reading `workflows.yaml`, which has no top-level `gates:` key, and always reported zero). Fixed, verified with a mutation test that reproduces the original defect and confirms the new regression pin catches it, and closed the loop with a cross-tool count check in `gate-retirement.sh lint` so the two readers of the registry cannot drift apart again undetected. `model-tier-advisory-selftest.sh` 22/22 passing (was 21, +1 regression pin), `gate-retirement-selftest.sh` 46/46 passing, shellcheck clean. SCOPE-2 through SCOPE-7 remain PROPOSED.
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A review of delivery cost across a downstream consumer (`execution-ledger` spec 001, five scopes, 4 days, ~40 recorded phase hand-offs, Scope 01 still uncertified) traced the dominant cost to re-execution rather than to verification. The audit that followed found that the framework's own bureaucracy-reduction mechanism has never executed a single evaluation, that its retirement criteria are written in a currency no producer emits, and that machinery already built to prevent duplicate execution is consumed by zero agents. Every claim below is re-checked against `origin/main` at `accc442d`.
**Verified gaps addressed:** ~~REG-22~~ (SCOPE-1, applied) — the retirement reader is bound to the wrong registry; COV-24 — retirement criteria are denominated in evidence no producer emits, while usable evidence already exists; PERF-13 — hermetic selftests are re-executed on unchanged inputs; PERF-14 — required specialist phases re-execute identical suites on byte-identical trees; REG-23 — declared and derived gate enforcement disagree for 59% of gates; COST-14 — a single gate is restated across many agent bundles

## Problem (verified against source)

- **REG-22 — the retirement reader is bound to the wrong registry.** `bubbles/scripts/model-tier-advisory.sh:41` resolves `WORKFLOWS="${BUBBLES_WORKFLOWS_FILE:-$REPO_ROOT/bubbles/workflows.yaml}"` and its `retirement` operation selects gates with `data.get('gates')` (same file, line 165). `bubbles/workflows.yaml` has no top-level `gates:` key — `grep -c '^gates:'` returns 0 — so the selector always resolves to the empty dict and the report prints `modelCompensation gates: 0`. The 121 gates live in `bubbles/registry/gates.yaml`, which the sibling tool `bubbles/scripts/gate-retirement.sh:90` reads correctly via `GATES="${BUBBLES_GATES_FILE:-$REPO_ROOT/bubbles/registry/gates.yaml}"`. Two tools govern one registry; one of them is pointed at the wrong file. Redirecting the reader proves the defect and nothing else changes:

  ```
  $ bash bubbles/scripts/model-tier-advisory.sh retirement --tier opus-class
    modelCompensation gates: 0
    tier precondition MET (0): none

  $ BUBBLES_WORKFLOWS_FILE=$PWD/bubbles/registry/gates.yaml \
      bash bubbles/scripts/model-tier-advisory.sh retirement --tier opus-class
    modelCompensation gates: 25
    tier precondition MET (25): G005, G020, G021, G025, G026, G027, G040, G041,
      G061, G063, G066, G068, G071, G072, G074, G075, G076, G078, G084, G085,
      G090, G092, G125, G128, G132
  ```

  All 25 model-compensation gates are tier-eligible today and the only surface that could say so reports an empty set. `gate-retirement.sh` does not cover the gap: it asserts that a criterion is *declared*, and reports `OK — all 25 modelCompensation gate(s) declare a retirement criterion` without evaluating one. This is a silent zero inside the framework whose stated purpose is refusing silent zeros, and it is invisible because an empty result is rendered as a clean pass.

- **COV-24 — retirement criteria are denominated in evidence no producer emits, while usable evidence already exists.** Every `retireWhen` in `bubbles/registry/gates.yaml` names a rate — `fabricated-evidence-rate`, `false-completion-claim-rate`, `format-bypass-rate`, `routing-omission-rate`, `coverage-omission-rate`, `phantom-reference-rate`, `process-violation-rate`, `framework-evidence-omission-rate`. `model-tier-advisory.sh` states the consequence itself: "the EVIDENCE half is UNMET for every gate without exception … no harness produces those rates yet." That is correct for a fabrication rate, which requires driving a model at a declared tier. It is not the only question a retirement decision can rest on. `bubbles/scripts/gate-hit-log.sh report` already answers a narrower and sufficient one — *has this gate ever refused anything?* — from 9,417 `sourceClass=product` records:

  ```
  gates with any record: 34 / 121
  gates that PREVENTED at least once: 14
  gates that FIRED but never prevented: 20
  ```

  Cross-referencing the 34 observed gates against the 25 model-compensation gates partitions them into three classes with different correct actions:

  | Class | Gates | Evidence | Correct action |
  |---|---|---|---|
  | Prevented at least once | G027, G040, G041, G061, G068, G084 | Refused real work | **Keep.** Cost is earned. |
  | Fired on every one of 348 runs, prevented nothing | G085, G090, G092, G128 | ~348 evaluations, 0 refusals each | Retirement candidate **on measurement** |
  | No telemetry in 9,417 records | G005, G020, G021, G025, G026, G063, G066, G071, G072, G074, G075, G076, G078, G125, G132 | None | **Instrument.** Silence is not evidence. |

  The criterion vocabulary cannot express the middle column, so a gate with 348 recorded no-op evaluations is indistinguishable from a gate with no record at all. IMP-047 correctly refused to delete 86 never-observed gates on the grounds that one telemetry sample does not prove a gate never fires; that refusal is preserved here and is the reason the third class routes to instrumentation rather than deletion.

- **PERF-13 — hermetic selftests are re-executed on unchanged inputs.** `bubbles/registry/validation-checks.yaml` on `origin/main` declares 360 checks, of which 285 are `*-selftest.sh` and 75 are live checks against the repository. The default tier is the full suite (`bubbles/scripts/framework-validate.sh:392`, `VALIDATE_TIER="${BUBBLES_VALIDATE_TIER:-full}"`); the core tier that pre-push uses runs 16. IMP-051 measured the full suite at `Wall clock: 3743s across 338 executed check(s)`. Cacheability is inverted relative to where reuse is safest:

  ```
  selftest checks: 285 total — 156 marked closureComplete: false
  live checks:      75 total —  66 marked closureComplete: false
  ```

  A selftest is a hermetic unit test of one guard script; its closure is enumerable in principle (the guard, its libraries, its fixtures). 156 of them are nevertheless declared closure-incomplete, which the generator header defines as "always executed and never reused." The framework therefore re-runs the majority of its own unit tests on every validation when nothing they test has changed. No assertion is gained by the repetition.

- **PERF-14 — required specialist phases re-execute identical suites on byte-identical trees.** `bubbles/registry/required-specialists.yaml:32` requires twelve phases for `full-delivery`: `implement, test, regression, simplify, gaps, harden, stabilize, security, validate, audit, chaos, docs`. The downstream evidence shows what the sequence costs when the tree does not change between phases. From `execution-ledger` `specs/001-execution-ledger-foundation/state.json`, consecutive `executionHistory` entries on unchanged bytes:

  - `regression` — "Re-executed every Scope 01-applicable suite and quality check on **byte-identical inputs**, retained 4,409 of 4,409 coverage"
  - `simplify` — "passed focused unit, format, lint, all-target, and exact 4,409-of-4,409 coverage checks"
  - `gaps` — "Re-executed the Scope 01 product, test, exact coverage, artifact, reality, parity, and integrity checks"
  - `harden` — "builds, checks, contracts, applicable suites, all targets, exact 4,801-of-4,801 coverage"
  - `stabilize` — "current-session unit, integration, functional, concurrency-target, crash-target … evidence"

  Five re-executions of one suite, each re-deriving a number the previous phase already derived. The machinery to prevent exactly this exists and is unwired: `bubbles/scripts/test-leaf-receipt.sh` was delivered by IMP-048 SCOPE-3 with the contract "an accepted leaf is not replayed" and 70 assertions. On `origin/main`, `git grep -l test-leaf-receipt -- agents/ instructions/ skills/` returns **zero** files. The only consumers are `phase-coordinator.sh`, `framework-validate.sh`, its own selftest, and the two generated registries. Occurrence-level reuse was built for *phases* (`workflow-phase-engine.md`: "An occurrence already accepted is reported `ACCEPTED` and is NOT re-executed") and never extended to the *checks inside* a phase, so no agent instruction anywhere tells a specialist it may cite a prior phase's receipt instead of re-running the suite.

- **REG-23 — declared and derived gate enforcement disagree for 59% of gates.** The generated `gateEnforcement.derived` block in `bubbles/registry/gates.yaml` classifies all 121 gates:

  ```
  agrees: 49    divergent: 71    contradiction: 1
  ```

  `G071` is the contradiction: `enforcedBy: [ behavioral:agents/bubbles_shared/quality-gates.md, behavioral:agents/bubbles_shared/validation-core.md, behavioral:bubbles.validate ], blocking: unknown, blockingBasis: behavioral-only-no-derivable-exit, agreement: contradiction, declaredEnforcedBy: [ unbound ]` — three surfaces claim it, it declares itself unbound, and whether it blocks cannot be derived. Beyond registry hygiene this has a behavioral cost: when "which surface actually refuses this?" has no stable answer, the defensive response is to re-verify, which is the loop PERF-14 measures.

- **COST-14 — a single gate is restated across many agent bundles.** 37 of 121 gates are behavioral-only, carrying no script enforcement at all. 18 gates are restated behaviorally in three or more places, 92 restatements in total. The heaviest fan-out is `G023` at 11 enforcement surfaces, then `G024` and `G080` at 10, `G025` at 9. Each restatement is an independent site at which the rule can drift, and the aggregate lands in the bundles: `bubbles.workflow` 647,377 B, `bubbles.security` 503,058 B, `bubbles.setup` 488,339 B, `bubbles.simplify` 484,024 B (`bubbles/agent-bundle-budgets.json`). This is **not** the IMP-028 premise. IMP-028 tested whether the shared instruction files overlap each other and measured that premise false; it is not re-litigated here. The claim is narrower and separately measured: one gate is restated in N agent bundles. The always-on surface is explicitly excluded — `always-on-instruction-budget.sh` reports `OK — 4516 B always-on, budget 8000 B`, which has held since IMP-039 and needs no change.

## Proposal

### SCOPE-2 — Add a satisfiable evidence half to `retireWhen` (COV-24)

- Add an optional second criterion form alongside the existing rate: `preventionEvidence: { minRuns: <n>, prevented: 0, sourceClass: product }`, satisfied directly from the `gate-hit-log.sh` store that already exists. The existing rate clauses are retained verbatim, not replaced — a gate may declare either or both, and a gate carrying only an unmeasurable rate keeps exactly today's behavior.
- Teach `model-tier-advisory.sh retirement` to report the three classes separately: **earning** (prevented ≥ 1), **candidate** (fired ≥ `minRuns`, prevented 0), **unmeasured** (no records). The report stays advisory and still retires nothing on its own.
- Bind `preventionEvidence` to the four measured candidates only — G085, G090, G092, G128 — with `minRuns: 348` set at the observed sample, and route each to owner review individually with its record count. No gate is retired by this proposal; the scope makes retirement *decidable* and produces the first four decisions.
- Do NOT extend candidacy to the 15 unmeasured model-compensation gates. Absence of records is absence of instrumentation, and IMP-047's refusal to read silence as evidence is preserved.

### SCOPE-3 — Instrument the unmeasured model-compensation gates (COV-24)

- Wire `gate-hit-log.sh` emission into the 15 model-compensation gates with no records: G005, G020, G021, G025, G026, G063, G066, G071, G072, G074, G075, G076, G078, G125, G132. Emission is a `fired`/`prevented` record at the point of evaluation, matching what the 34 instrumented gates already emit.
- Add a lint asserting that every `modelCompensation` gate emits telemetry, so a gate can no longer declare a retirement criterion it is structurally incapable of ever satisfying.
- This scope adds measurement only. It retires nothing and changes no enforcement outcome.

### SCOPE-4 — Make hermetic selftests provably hermetic, and reuse them (PERF-13)

- Give selftests an explicit hermeticity contract: execute under a pinned temporary fixture root, read no repository path outside the declared closure, and declare the guard and fixtures they cover. A selftest that satisfies the contract is `closureComplete: true` by construction rather than by the generator's inference from source scanning.
- Re-run `generate-validation-checks.sh` and land the resulting closure changes. Target the 156 closure-incomplete selftests; report the achieved count rather than asserting one in advance, since some genuinely read the working tree and must remain always-run.
- Change the default for a working-tree invocation to `--changed-only`, retaining `--tier=full` as the explicit default for release, pre-merge, and `release-check`. The tiering and the receipt already exist (IMP-051 SCOPE-2); only the default selection changes.
- Recommendation where two options exist: keep `--tier=full` the default for CI and any release path, and make `--changed-only` the default only for a developer/agent working-tree run. A release must not be able to inherit a reduced suite from a shell default.
- Assertion count is unchanged by every part of this scope. A byte change in a guard invalidates its receipt and re-runs its selftest.

### SCOPE-5 — Wire single-execution verification into the specialist phase chain (PERF-14)

- Extend the accepted-leaf model from phase occurrences down to the checks inside a phase, using the delivered `test-leaf-receipt.sh` rather than a new mechanism. A receipt is keyed by `(tree-digest, check-id, phase, agent)` and carries the raw evidence the producing phase captured.
- Add a consumption contract to `agents/bubbles_shared/test-core.md` and `workflow-phase-engine.md`: a specialist that finds a valid receipt for the current tree digest MUST record `verified: receipt <id>, digest <sha>, produced by <phase> at <ts>` instead of re-executing, and MUST re-execute when the digest differs by a single byte or no receipt exists.
- Preserve independent adjudication explicitly. What is reused is the *execution*, never the *judgment*: each phase still evaluates the evidence against its own contract, still records its own claim, and still may reject evidence it considers insufficient. A phase that wants a fresh run may always demand one; the receipt removes the obligation to re-run, not the right to.
- Preserve the evidence standard. A receipt carries the original raw output, so a phase citing a receipt cites real captured terminal output with real exit codes — G005 and the anti-fabrication chain see the same bytes they see today, plus a digest binding them to a tree state.
- Add a `receipt-reuse` record to `gate-hit-log.sh` so the saving is measured rather than assumed, and so a reuse that later proves unsound is traceable to the receipt that authorized it.

### SCOPE-6 — Ratchet enforcement divergence toward zero (REG-23)

- Treat `agreement: divergent` as a backlog with a per-repository baseline that may only decrease, in the shape IMP-036 SCOPE-7 already established for the agent enum. No mass rewrite; the count cannot grow.
- Resolve `G071` first as the single `contradiction`: either bind it to the surface that actually refuses, or reclassify it as behavioral-only with `blocking` stated truthfully. `declaredEnforcedBy: [ unbound ]` against three claiming surfaces is not a state any reader can act on.

### SCOPE-7 — One normative statement per behavioral gate (COST-14)

- For the 18 gates restated in three or more bundles, designate one normative statement in one shared file and reduce the other sites to pointers. Start with the four heaviest: G023 (11 surfaces), G024 (10), G080 (10), G025 (9).
- Ratchet the affected per-agent budgets in `bubbles/agent-bundle-budgets.json` downward as restatements collapse, so the reclaimed bytes cannot silently refill.
- Measure the effect on `referenceClosureProxy` rather than claiming a token saving. Per IMP-039, token counts are not readable without a configured usage adapter, and deriving one is fabrication.

## Migration / rollout

- SCOPE-1 is a one-line binding fix plus two assertions; it is independently landable and unblocks any measurement of SCOPE-2 or SCOPE-3.
- SCOPE-2 is additive to the criterion schema. A gate that declares no `preventionEvidence` behaves exactly as today, so no repository sees a change until a criterion is bound.
- SCOPE-3 is measurement-only and can land in parallel with SCOPE-2; SCOPE-2's candidate list deliberately does not depend on it.
- SCOPE-4 splits cleanly: the hermeticity contract and regeneration land first and change no default; the default-selection change lands second and is reversible by an environment variable.
- SCOPE-5 is the largest and should land last among the execution scopes, after SCOPE-4 has demonstrated digest-keyed reuse working on the framework's own suite. Land it behind a per-repository opt-in, default off, so an unconfigured repository behaves exactly as it does today.
- SCOPE-6 and SCOPE-7 are ratchets with no behavioral change on the day they land.
- This proposal is independent of IMP-056 and IMP-057. Neither touches gate retirement, validation tiering, or the specialist phase chain, so no sequencing constraint applies against the in-flight dispatch-authorization work.

## Risks & mitigations

- **R1 — SCOPE-1 exposes 25 tier-eligible gates and invites retiring them on tier alone.** → The advisory's existing refusal text is preserved verbatim, and SCOPE-2 requires the evidence half independently. Tier eligibility alone remains insufficient; the report continues to retire nothing.
- **R2 — SCOPE-2 substitutes "never refused anything" for "is not needed."** A gate may be correctly preventive and simply never have met a violation. → Candidacy is not retirement. Each of the four candidates routes to owner review with its record count, and the `minRuns: 348` floor is set at the observed sample rather than at a convenient number. A gate the owner judges load-bearing stays regardless of its count.
- **R3 — SCOPE-5 reuse hides a real regression when a receipt is stale.** → The digest key is the mitigation: any byte change to the tree invalidates every receipt covering it. The failure mode requires a tree that is byte-identical yet behaviorally different, which for a repository-rooted digest is the same assumption the existing `--changed-only` closure already rests on.
- **R4 — SCOPE-5 is read as permission to skip verification.** → The contract states the opposite and must be written to say so: judgment is never reused, only execution. A phase always retains the right to demand a fresh run, and the reuse is recorded as a citation with a digest, not as an unattributed pass.
- **R5 — SCOPE-4's hermeticity contract mislabels a selftest that does read the tree, silently reducing coverage.** → The contract is enforced by execution under a pinned fixture root, not by declaration. A selftest that reads outside its closure fails in that sandbox and is refused `closureComplete: true`.
- **R6 — SCOPE-7 repeats IMP-028.** → It does not share IMP-028's premise. IMP-028 tested overlap *between shared files* and measured it false; this scope addresses restatement *of one gate across agent bundles*, which is separately counted at 92 instances. If measurement shows the pointer form does not reduce effective bundle bytes, the scope should be withdrawn on evidence, as IMP-051 SCOPE-1 and IMP-036's agent-retirement bullet were.

## Acceptance criteria (when implemented)

- ~~`bash bubbles/scripts/model-tier-advisory.sh retirement --tier opus-class` reports 25 model-compensation gates with no environment override, and `model-tier-advisory-selftest.sh` fails if that count is zero.~~ **DONE (SCOPE-1).**
- ~~`gate-retirement.sh lint` fails when the gate registry and the advisory disagree on the model-compensation gate count.~~ **DONE (SCOPE-1)**, mutation-verified against the original defect.
- The retirement report partitions gates into earning / candidate / unmeasured, and names G027, G040, G041, G061, G068, G084 as earning and G085, G090, G092, G128 as candidates, each with its record count.
- All 25 model-compensation gates emit `gate-hit-log.sh` records, and a lint refuses a model-compensation gate that emits none.
- The count of `closureComplete: false` selftests is reduced from 156, with the achieved figure recorded from a regenerated `validation-checks.yaml` and the total assertion count across the suite unchanged.
- A working-tree `framework-validate.sh` run defaults to `--changed-only`; `release-check` and any release path still execute the full tier, proven by a selftest that asserts the release path cannot inherit a reduced tier from the environment.
- At least one agent instruction file references `test-leaf-receipt.sh` with a consumption contract, and a `full-delivery` run over an unchanged tree records receipt citations instead of repeat executions for at least one suite, visible as `receipt-reuse` records in the gate-hit store.
- A digest change invalidates the receipt and forces re-execution, proven by mutation: alter one byte, observe the re-run.
- `agreement: divergent` carries a recorded per-repository baseline that the registry lint refuses to let grow, and `G071` no longer reports `contradiction`.
- The 4 heaviest behavioral gates each have one normative statement and N pointers, with the affected bundle budgets ratcheted to the new measured sizes.

## Files to touch (on approval)

~~`bubbles/scripts/model-tier-advisory.sh` (gate-registry binding for the `retirement` operation) — owner `bubbles.super`, gate G125~~ **DONE.** ~~`bubbles/scripts/model-tier-advisory-selftest.sh` (zero-result assertion) — owner `bubbles.test`~~ **DONE.** ~~`bubbles/scripts/gate-retirement.sh` (cross-tool count agreement lint) — owner `bubbles.super`~~ **DONE.** `model-tier-advisory.sh` still owes SCOPE-2's three-class report. `bubbles/registry/gates.yaml` (`preventionEvidence` criterion form; `G071` enforcement reconciliation; divergence baseline — owner `bubbles.super`, gates G125/G131), `bubbles/scripts/gate-hit-log.sh` (emission for the 15 unmeasured gates; `receipt-reuse` record class — owner `bubbles.super`), `bubbles/scripts/generate-validation-checks.sh` (hermetic-selftest closure derivation — owner `bubbles.super`), `bubbles/registry/validation-checks.yaml` (regenerated; never hand-edited — generated surface), `bubbles/scripts/framework-validate.sh` (working-tree default tier; release-path tier floor — owner `bubbles.super`, gate G007), `bubbles/scripts/test-leaf-receipt.sh` and `bubbles/scripts/phase-coordinator.sh` (receipt key extended to `(tree-digest, check-id, phase, agent)` — owner `bubbles.super`, gate G022), `agents/bubbles_shared/test-core.md` and `agents/bubbles_shared/workflow-phase-engine.md` (receipt consumption contract; judgment-not-reused statement — owner `bubbles.test` / `bubbles.workflow`, gates G003/G004/G005), `agents/bubbles_shared/quality-gates.md` and `agents/bubbles_shared/validation-core.md` (single normative statement for the heaviest behavioral gates — owner `bubbles.docs`, gate G125), `bubbles/agent-bundle-budgets.json` (ratcheted budgets — owner `bubbles.super`), `improvements/INDEX.md` (proposal row — owner `bubbles.super`).
