# IMP-043 — Close the Learning Loop: Capture, Schedule, Consume

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) - human-reviewed. NO auto-mutation of `bubbles/*` until approved.
**Motivation:** An operator observed that `lessons.md` is empty in every repo that has one, and absent in the rest. A cross-repository audit of eight installed repositories confirmed it. Zero lessons exist anywhere, no skill proposal has ever been generated, and no recall index has ever been built.
**Verified gaps addressed:** LRN-4 unreachable capture rule. LRN-5 inert lifecycle triggers. LRN-6 no upgrade backfill. LRN-7 unreachable recall. COV-18 no end-to-end loop test. DOC-8 false compaction claim.

## Executed Measurements

- `skill-evolution-selftest.sh` passed 10 of 10 checks.
- `experience-recall-index-selftest.sh` passed 49 checks with 0 failures and 1 optional dependency skip.
- `experience-recall-cli-selftest.sh` passed 248 checks with 0 failures.
- The recall index selftest evidence block has SHA-256 `7d2b2526320dab76bfa9ae41be21bdde87235c5df0fc9ae35cfcb8e924b62a50`.
- The recall CLI selftest evidence block has SHA-256 `6abe4d7c180bbdf9d6ebbed41fbe6269582c392ec0ce01918c9851e4e753df25`.
- Eight installed repositories were audited: bubbles, QuantitativeFinance, GuestHost, WanderAide, smackerel, knb, research-lab, Ozhiva.
- Five of those eight have no `.specify/memory/lessons.md` at all.
- Two have the installer seed with zero lesson entries.
- The canonical bubbles source repository has no lessons file.
- Zero repositories have `.specify/memory/skill-proposals.md`.
- Zero repositories have `.specify/runtime/experience-recall/`.
- Zero repositories have a `lessons`, `recall`, or `skill-proposals` command in `framework-events.jsonl`.

## Direct Discriminators

- The lesson writer works. The clustering engine works. The recall index works. Every component passes its own selftest.
- No `*.agent.md` file in `agents/` references `execution-ops.md`. The only references are `agent-common.md` and `project-config-contract.md`.
- `result-envelope.schema.json` declares no learning field of any kind.
- `hooks.json` declares exactly three hook families: `pre-tool`, `pre-commit`, `pre-push`.
- `grep` for `autoCompactTrigger|reviewTrigger|workflow_start` across the whole repository returns three lines, all inside `workflows.yaml` itself.
- `grep` for `lessonsMemory|recencyTiers|deduplicationThreshold|maxLines` returns five lines, all inside `workflows.yaml` itself.
- The only agent mention of `recall sync` is a descriptive sentence in `artifact-ownership.md`.

## Adversarial Re-Review

A second pass tried to falsify this proposal against the same tree.

- The claim "the loop is broken" was tested against the component selftests and narrowed. The algorithms are correct. Only the integration is missing. The proposal was rewritten to say so.
- The claim "no lesson instruction exists" was falsified. `execution-ops.md` carries a precise instruction. The real defect is reachability, not absence.
- The claim "a gate should force a lesson per run" was rejected. `execution-ops.md` already argues that a per-run counter manufactures filler and degrades clustering. That reasoning is sound and is preserved below.
- The claim "recall is broken" was narrowed. Recall is deliberately opt-in with a neutral default. The defect is that no repository can reach the opt-in state, because nothing ever synchronizes the index.
- The claim "upgrade is broken" was tested by reading `cmd_upgrade`. Upgrade works as written. It simply never passes `--bootstrap`, and every learning scaffold lives behind that flag.

## Problem (Verified Against Source)

### Capture

- **LRN-4 — The capture obligation is two optional hops from any agent that finishes work.** `agents/bubbles_shared/execution-ops.md` lines 5 to 55 hold the only statement of the rule. It says to record a lesson at result-envelope close. Nothing in `agents/` reaches that file. A repository-wide grep for `execution-ops` across `agents/**` returns matches only in `agent-common.md` lines 31, 77, 78, 197 and `project-config-contract.md` line 912.
- **LRN-4 — The index entry hides the rule behind an unrelated trigger.** `agent-common.md` line 197 describes the module as covering "bounded retries, timeout expectations, lessons-learned memory, and optional atomic commit behavior". An agent closing a scope has no reason to open a retry and timeout module. Line 5 of the same file instructs readers to treat it as an index rather than a full-context load.
- **LRN-4 — No context profile loads the module.** The Context Loading Profiles in `operating-baseline.md` name thirteen roles. None of them includes `execution-ops.md`.
- **LRN-4 — The result envelope has no place to record the decision.** `bubbles/schemas/result-envelope.schema.json` requires `agent` and `outcome`. It defines no learning field, so an agent that correctly decided a run produced no lesson leaves no trace of having decided.
- **LRN-4 — The ownership table asserts a write path that nothing exercises.** `artifact-ownership.md` line 24 records `lessons.md` as written by "all execution agents" at result-envelope close. Across eight repositories that write has occurred zero times.

### Scheduling

- **LRN-5 — Three declared lifecycle triggers have no execution mechanism.** `workflows.yaml` line 1272 declares `autoCompactTrigger: workflow_start`. Line 1312 declares `reviewTrigger: workflow_start`. Line 1355 declares a third under the developer profile. `bubbles/hooks.json` defines only `pre-tool`, `pre-commit`, and `pre-push`. No `workflow_start` or `workflow_finalize` family exists anywhere.
- **LRN-5 — The whole `lessonsMemory` block is inert.** `workflows.yaml` lines 1268 to 1277 declare `file`, `archiveFile`, `maxLines`, `autoCompactTrigger`, `recencyTiers`, and `deduplicationThreshold`. No code reads any of them. `cli.sh` lines 3895 to 3902 hardcode the value 150 twice and ignore `maxLines` entirely.
- **LRN-5 — Skill evolution reads two keys and ignores the rest.** `skill-evolution.sh` lines 19 to 36 read `triggerThreshold` and `similarityThreshold`. It hardcodes both file paths at lines 14 to 17, and never reads `enabled`, `sourceFile`, `proposalFile`, `reviewAgent`, or `reviewTrigger`.
- **LRN-5 — Proposal generation only ever runs when a human types the command.** `cli.sh` lines 3927 to 3929 expose `skill-proposals`. Nothing else invokes `skill-evolution.sh`.

### Distribution

- **LRN-6 — Upgrade never backfills a learning scaffold.** `install.sh` line 1153 creates `lessons.md` inside the block guarded by `DO_BOOTSTRAP` at line 980. `cli.sh` line 4164 invokes `install.sh` without `--bootstrap`. Every repository upgraded rather than freshly bootstrapped therefore never receives the file. Five of the eight audited repositories are in exactly that state.
- **LRN-6 — Nothing reports the missing scaffold.** `cmd_doctor` at `cli.sh` line 2255 and `cmd_repo_readiness` at line 2045 make no check for lessons, proposals, or recall state. An operator has no signal that the loop cannot run.

### Consumption

- **LRN-7 — Recall cannot be reached from a default install.** `experience-recall-resolve.sh` line 81 defaults the adapter to `none`. None of the eight audited project configs declares an `experienceRecall` block, so all eight resolve to the neutral adapter.
- **LRN-7 — Nothing ever synchronizes the index.** A grep for `recall sync` across `agents/**` returns one descriptive sentence in `artifact-ownership.md` line 67. No agent, hook, or script invokes it. `experience-recall-index.py` line 266 refuses a query against an unsynchronized index. Enabling the adapter alone would therefore still return nothing.

### Verification And Documentation

- **COV-18 — No test covers the loop as a loop.** Each stage has a strong selftest. Nothing asserts that finishing work produces a lesson, that lessons reach the threshold, or that a proposal or recall hit results. The integration is exactly where the failure lives, and it is the one place with no coverage.
- **DOC-8 — The operator recipe states a behavior that does not exist.** `docs/recipes/framework-ops.md` line 318 reads "Lessons are auto-compacted when the file exceeds 150 lines." Compaction runs only when an operator types `lessons compact`.
- **DOC-8 — The installer seed repeats the same claim.** `install.sh` line 1157 tells every new repository that the file "auto-compacts past ~150 lines". Both surviving seed files in the audit carry that sentence.

## Design Principles

1. Keep capture conditional. A run that diagnosed nothing writes nothing.
2. Make the decision explicit even when the answer is "no lesson". An unrecorded decision is indistinguishable from a forgotten one.
3. Put the obligation where the work ends, not in a module about retries.
4. Never let a declared trigger exist without an executor.
5. Prefer wiring an existing mechanism over inventing a second one.
6. Keep recall opt-in and advisory. Fix reachability, not the default.
7. Test the loop end to end, because that is the layer that failed.

## Proposal

### SCOPE-1 — Learning disposition in the result envelope (LRN-4)

- Add an optional `learning` object to `bubbles/schemas/result-envelope.schema.json` with a required closed `disposition` enum of `captured`, `not-applicable`, and `deferred`.
- Require `lessonId` when `disposition` is `captured`, and require a `reason` of at least twenty characters when it is `deferred`.
- Teach `result-envelope-validate.sh` to refuse `captured` without a resolvable lesson identifier. Absence of the whole object stays valid, so no existing envelope breaks.
- Recommendation: keep the field optional at the schema level and make it mandatory only for mutable-run outcomes in SCOPE-2. A schema-level requirement would invalidate every advisory envelope for no benefit.

### SCOPE-2 — Put the obligation where the run ends (LRN-4)

- Move the operative rule from `execution-ops.md` into the closeout section that execution agents already read, and leave a pointer behind so the module keeps its single-source role.
- State the rule as one decision at result-envelope close with three legal answers, matching the SCOPE-1 enum.
- Preserve the existing prohibition on a per-run lesson counter verbatim. The proposal adds a recorded decision, never a quota.
- Add `execution-ops.md` to the implementer, tester, and orchestrator context profiles in `operating-baseline.md` so the module is reachable by the roles that close runs.

### SCOPE-3 — Give the declared triggers an executor (LRN-5)

- Add a `session-start` hook family to `bubbles/hooks.json` and register two builtin entries: lessons compaction and skill-proposal refresh.
- Point the compaction entry at `cli.sh lessons compact` and the refresh entry at `skill-evolution.sh refresh`.
- Make `cmd_lessons compact` read `lessonsMemory.maxLines` from `workflows.yaml` and fall back to 150 only when the key is absent.
- Make `skill-evolution.sh` read `sourceFile`, `proposalFile`, and `enabled` from the registry instead of hardcoding two paths and ignoring the toggle.
- Recommendation: reuse the existing hook mechanism rather than adding a scheduler. The hook runner, its catalog, and its installer already exist and are tested.
- Alternative considered and rejected: leaving the trigger keys as documentation. A declared trigger with no executor is what produced this defect.

### SCOPE-4 — Backfill scaffolds on upgrade and surface the gap (LRN-6)

- Extract the learning scaffold creation in `install.sh` into a function that runs on every install and every upgrade, not only under `--bootstrap`.
- Keep the write strictly non-destructive. Create the file only when it is absent, and never modify an existing one.
- Add a `doctor` advisory that reports when `lessons.md` is missing, when the recall adapter resolves to `none`, and when the metrics store is unwritable. Advisories never change the exit code.
- Recommendation: backfill on upgrade rather than asking operators to re-bootstrap. Re-running bootstrap on a live repository touches many more files than the one that is missing.

### SCOPE-5 — Make recall reachable without changing its default (LRN-7)

- Keep `none` as the shipped default. The neutral adapter is correct and stays.
- Add a `recall sync` invocation to the `session-start` hook family from SCOPE-3, guarded so it exits silently when the adapter is `none`.
- Add an `experienceRecall` block to the project config template with `adapter: none` and a comment naming `local-lexical` as the opt-in value.
- Teach `bubbles.setup` to propose the opt-in when it finds a populated lessons file, and to leave the config untouched otherwise.

### SCOPE-6 — Test the loop as a loop (COV-18)

- Add `learning-loop-selftest.sh` that builds a throwaway repository and drives the full path in one run.
- Assert the ordered chain: a lesson written through `cli.sh lessons add`, three clustered entries crossing the threshold, a generated proposal naming the pattern, a synchronized index, and a recall query returning the anchored record.
- Add an adversarial case proving a single lesson produces no proposal, so the test cannot pass by writing proposals unconditionally.
- Add an adversarial case proving an unsynchronized index refuses a query rather than returning an empty success.
- Register the selftest in `framework-validate.sh` beside the existing recall checks.

### SCOPE-7 — Repair the two false documentation claims (DOC-8)

- Correct `docs/recipes/framework-ops.md` line 318 to state that compaction runs at session start once SCOPE-3 lands, or on demand before then.
- Correct the installer seed comment in `install.sh` line 1157 to match.
- Sequence this scope after SCOPE-3 so the corrected sentence describes shipped behavior rather than a plan.

## Migration / Rollout

- SCOPE-1 is additive and default-absent. No existing envelope changes meaning.
- SCOPE-2 is a documentation move plus three profile lines. No script changes.
- SCOPE-3 introduces a new hook family. Existing hook families are untouched, and the family is inert until installed.
- SCOPE-4 changes installer control flow. It must land with the non-destructive guarantee proven by a test that runs the upgrade twice against a repository holding a non-empty lessons file.
- SCOPE-5 is config-template and agent-guidance only. The runtime default does not change.
- SCOPE-6 depends on SCOPE-3 for the sync step and should land immediately after it.
- SCOPE-7 lands last, because it describes what SCOPE-3 delivers.
- Suggested order: 1, 2, 4, 3, 5, 6, 7. SCOPE-4 is placed early because it unblocks the five repositories that currently have no file to write to.

## Risks And Mitigations

- **R1 — A recorded disposition becomes a quota by habit.** An agent may write filler to avoid an empty field. Mitigation: `not-applicable` is a first-class legal answer, the enum is closed, and the existing no-counter rule is preserved verbatim in SCOPE-2.
- **R2 — A session-start hook slows every session.** Mitigation: both entries are bounded and idempotent. Compaction is a line count and a tail. Refresh is a single pass over one file. The sync step exits immediately under the `none` adapter.
- **R3 — Installer backfill overwrites operator content.** Mitigation: create-if-absent only, plus the double-run test named in the rollout section.
- **R4 — Clustering quality degrades once real volume arrives.** Mitigation: `similarityThreshold` is already a live knob proven by the existing selftest at 1.0, and every proposal already prints its grouped variants for review.
- **R5 — Enabling recall raises the authority risk that IMP-037 contained.** Mitigation: no authority rule changes. Recall stays tier 4 and advisory, and the envelope validator already refuses a recall record cited as evidence.

## Files To Touch

| File | Owner | Change |
|---|---|---|
| `bubbles/schemas/result-envelope.schema.json` | framework | Add optional `learning` object |
| `bubbles/scripts/result-envelope-validate.sh` | framework | Validate `captured` against a resolvable lesson id |
| `agents/bubbles_shared/execution-ops.md` | framework | Keep the rule, add the disposition vocabulary |
| `agents/bubbles_shared/operating-baseline.md` | framework | Add the module to three context profiles |
| `bubbles/hooks.json` | framework | Add the `session-start` family |
| `bubbles/scripts/cli.sh` | framework | Read `maxLines`, add doctor advisories |
| `bubbles/scripts/skill-evolution.sh` | framework | Read registry paths and the enabled toggle |
| `install.sh` | framework | Backfill scaffolds outside `--bootstrap` |
| `bubbles/scripts/learning-loop-selftest.sh` | framework | New end-to-end test |
| `bubbles/scripts/framework-validate.sh` | framework | Register the new selftest |
| `docs/recipes/framework-ops.md` | framework | Correct the compaction claim |

## Acceptance Criteria

1. A fresh repository and an upgraded repository both contain `.specify/memory/lessons.md` after the framework is installed.
2. `learning-loop-selftest.sh` passes, including both adversarial cases.
3. `framework-validate.sh` executes the new selftest.
4. `doctor` reports a missing lessons file and a `none` recall adapter as advisories without changing its exit code.
5. `lessons compact` honors a `maxLines` value other than 150.
6. An envelope claiming `disposition: captured` with an unresolvable lesson id is refused.
7. No documentation sentence describes automatic compaction unless the hook that performs it is installed.
