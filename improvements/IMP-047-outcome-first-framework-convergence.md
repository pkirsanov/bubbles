# IMP-047 - Outcome-First Framework Convergence: Spec-to-Live Delivery, Smart Validation, and System Truth

**Status:** IN PROGRESS - operator approved delivery on 2026-08-16 and directed full delivery; slices are landing. See `Delivery Log`.
**Surface:** framework-health (G125) - proposal-first and human-reviewed.
**Resolved mode:** `framework-health action:proposal-first`.
**Date:** 2026-08-16.
**Repository:** canonical Bubbles source repository.
**Auto-mutation:** NONE outside this proposal consolidation.
**Motivation:** Consolidate IMP-042 through IMP-046 after two audits, source rechecks, and operator-directed outcome-first redesign.
**Verified gaps addressed:** All retained PERF, WIP, COV, REG, COST, DOC, EV, HO, LRN, and GF findings from IMP-042 through IMP-046.
**Revision:** Restructured after an adversarial audit found the previous draft added roughly 14 persistent surfaces, removed 3, and named zero deletions. This revision must net-reduce burden.

## Delivery Log

Landed slices, newest last. Each entry records the commit and the evidence that
closed it.

- **S-A + PD-11** - commit `82675b8`. Gate telemetry made truthful by recording
  `fired` and `prevented` as separate facts; framework health repointed to
  `gate-hits.jsonl`; `enforcedBy` and blocking status generated; the telemetry
  reader map generated; INDEX status derived from receipts; the
  `gates-block-reader` apparatus retired; `orphaned-scaffolding-guard.sh` added.
  PD-11 resolved with the declared `framework-proposal-v1` no-certification
  audit contract. 7 focused selftests exit 0.
- **S-B + PD-04** - landing now (uncommitted at the time this entry was
  written). PD-04: `scenario-test-resolve.sh` category comparison false-cleaned
  when GNU `timeout` was absent; the A6 selftest moved from exit 1 to exit 0.
  `report-sections.yaml` and `bug-packet.yaml` created as single authorities;
  `report-section-autofix.sh` (185 lines) deleted; the report template is now
  generated, so it satisfies its own lint, and the four previously-absent
  required sections are present.

## What This Removes

Read this before the additions. A proposal that only adds is the disease, not
the cure.

| Removal | Unit | Grounding |
| --- | --- | --- |
| The `gates-block-reader` apparatus: lint, selftest, `gates-block-readers.txt`, two `framework-validate.sh` registrations, and stale `workflows.yaml` prose | 442 lines, 16,140 bytes, 2 scheduled checks, 1 registry file | The guarded `gates:` block is already absent and the lint's own executed output states its removal precondition is met. |
| `report-section-autofix.sh` | 185 lines, 5,218 bytes | Its only function is injecting headings the canonical template omits. Fixing the template removes its reason to exist. |
| Seven prerequisite defects reclassified from blocking packets to inline work | roughly 60 artifacts of pre-work | Each defect lives inside a file a scope already opens. A separate packet buys sequencing overhead, not assurance. |
| Two prerequisite defects rejected outright | 2 packets, roughly 12 artifacts | Old PD-09 is a feature request. Old PD-10 is a policy preference whose fix multiplies framework-bug artifacts sixfold. |
| Seven scopes | 12 scopes reduced to 5 | Three deferred out of this proposal, four merged into surviving slices. |
| 23 mandatory report and artifact template sections with no script reader | downgraded to optional, not deleted | Human readership is unproven in either direction, so removal is not yet justified. Mandatory status is. |
| Old SCOPE-12 as a standalone scope | 1 scope | Its single irreducible requirement, one cold exact-tree gate on the release candidate, already exists as policy and now attaches to each slice. |

Net effect on persistent surfaces: this revision creates 4 and removes 9. The
tally appears in `Net Burden Accounting`.

One removal is explicitly refused. The 86 never-observed gates are **not**
deletable today, and this proposal does not pretend otherwise. See
`Delete List`.

## Credit Where Earned

An audit that only finds fault is not measuring, it is complaining. These are
measured successes and they should not be undone by this proposal.

- The always-on instruction surface is **one file of 4,516 bytes**,
  `instructions/bubbles-kernel.instructions.md`. It is the only file whose
  frontmatter carries `applyTo: "**"`. Every other instruction is conditioned on
  a file surface. This is the correct design and it is already in place.
- README and prompt-shim counts are generated and currently accurate. The
  earlier count conflict was repaired.
- `bubbles/registry/required-specialists.yaml` is already de-duplicated into one
  authority.
- `bubbles/scripts/evidence-capture.sh` supplies a hash-verified bounded record
  as the default above 40 lines. It is stronger than a paste, because
  `--verify` re-derives the digest.
- The `gates:` block was already removed. Only its guard apparatus outlived it.

## Executive Decision

Bubbles should optimize for delivered outcomes, not for gate activity.

The delivery target is the specified user or consumer outcome. Stable scenarios
represent that target and its obligations.

Gates are policy constraints and evidence guards. They can block unsafe
delivery. They are never the goal or the progress metric.

Progress is measured through this closed scenario-state sequence:

```text
PLANNED
  -> RED_VERIFIED
  -> IMPLEMENTED
  -> GREEN_TARGETED
  -> GREEN_LIVE        when applicable
  -> REGRESSION_GREEN
  -> OBSERVED          when applicable
  -> CERTIFIED
```

A gate pass cannot substitute for a scenario outcome. Gate counts cannot
measure delivery progress.

A live, Playwright, API, or telemetry test cannot be forced when the behavior
does not need one. Applicability comes from declared behavior traits. The
scenario record must state the decision and its rationale.

The final system should execute basic affected validation and the smallest
affected proof first. `basic` names the immediate validation floor inside
`fast`. It is not another assurance level.

The system should record every deferred heavy obligation. It should settle
that debt in batches. One cold, complete gate must still run against the exact
release candidate.

### The Retirement Rule

This rule governs the framework permanently, not only this proposal.

> The framework MUST NOT increase any of these four counts without retiring an
> equivalent unit in the same change:
>
> 1. blocking gates;
> 2. required artifacts per feature and per bug;
> 3. mechanically-required sections per artifact;
> 4. hand-maintained registries, where a generated registry does not count.
>
> Counts are emitted by `generate-framework-stats.sh` and checked by one lint.
> Every new obligation names the obligation it retires, before approval.

**Corollary, the orphaned-scaffolding rule.** Scaffolding built to make a
migration safe MUST name its own deletion trigger at creation time. A lint that
reports its own removal precondition is met MUST fail until it is removed.

The corollary is not hypothetical. `gates-block-reader-lint.sh` prints
`the inventory is empty; SCOPE-13 removal precondition is met` and exits 0. It
has announced its own obsolescence on every run and nothing acted on it.

#### Opening Baseline

These counts are the baseline the rule is measured against. Each was measured
during this invocation.

| Count | Opening value |
| --- | --- |
| Gates in `bubbles/registry/gates.yaml` | 118 |
| Required artifacts per feature | 6 |
| Required artifacts per bug | 6 by `bug-templates.md` |
| Mechanically-required `report.md` sections | 5 enforced by `artifact-lint.sh` |
| Hand-maintained registry files | 7 |
| Distinct CHECK labels in `state-transition-guard.sh` | 47 across 72 comment-banner sites |
| Scheduled checks in `framework-validate.sh` | 306 registrations |
| Distinct scripts referenced by `framework-validate.sh` | 316, of which 234 are selftests |

## Approval Boundary

This proposal is not accepted merely because the operator requested it.
`PROPOSED` remains the correct status until the owner reviews it.

Approval authorizes planning only. It does not authorize direct framework
implementation. Each confirmed implementation defect must first enter the bug
workflow defined below.

No scope may weaken anti-fabrication, repository binding, status ceilings,
validate-owned certification, or human authority.

## Repository And Review Provenance

Repository binding committed request class `FRAMEWORK` to the explicit
canonical root before repository-local reads. The host adapter re-observed
control revision 9. Preflight committed decision revision 10.

The source review used the current canonical worktree. The worktree was clean
before proposal authoring.

### Review Coverage Statement

- Every line of IMP-042 through IMP-046 was semantically reviewed.
- Every line of `improvements/INDEX.md` and `improvements/TEMPLATE.md` was semantically reviewed.
- Every line of the BUG-032 packet was semantically reviewed.
- Every line of BUG-033 was semantically reviewed.
- Every complete OW-012, OW-014, OW-015, and OW-016 row was semantically reviewed.
- Every file in selected framework families was inventoried and machine-scanned.
- The inventory covered 92 agent Markdown files and 484 script or Python files.
- It covered 20 schema, registry, and workflow files.
- It covered seven pre-consolidation improvement files and eight BUG-032 files.
- It covered 89 guide and recipe files.
- Controlling abstractions and relevant failure paths were read semantically.
- Generated and historical broad surfaces were checked through generators, scans, and targeted sampling.
- This review does not claim manual semantic review of every generated line.

### Evidence Classification

Source facts below come from files opened during this invocation. Git
dispositions come from commits inspected during this invocation.

The operator-supplied selftest result remains a diagnostic lead. This
invocation did not execute that selftest.

The supplied result used GNU Bash 5.3.15 on macOS. Neither `timeout` nor
`gtimeout` was present. The run exited 1 with SHA-256
`e967e75f8a20bbf2a09641b05bf9f417c6a91d61930aee6a6a97c191d7899381`.
It reported 18 checks and one failure. A6 returned `rc=0` after inventory
fallback instead of refusing unit coverage as E2E.

Source inspection independently confirmed the controlling mechanism.
`scenario-test-resolve.sh` invokes bare `timeout`. Failure changes the adapter
to `none` and falls back to a literal scan. Literal scanning cannot enforce the
runner category.

## Findings From Source

### F-047-01 - Scenario Authority Has Four Conflicting Shapes

`bubbles/schemas/scenario-manifest.schema.json` requires `schemaVersion`.
It requires scenario `id`, string-valued `linkedTests`, and object-valued
`lockdown`.

`agents/bubbles_shared/feature-templates.md` produces `version`. It produces
`scenarioId`, object-valued `linkedTests`, and boolean `lockdown`.

`bubbles/scripts/scenario-test-resolve.sh` tolerates both ID spellings. It also
tolerates four linked-test shapes. Compatibility has become the de facto
contract because the canonical producer and schema disagree.

### F-047-02 - Test Policy Confuses Universal Regression With Universal E2E

`agents/bubbles_shared/critical-requirements.md` and
`agents/bubbles_shared/e2e-regression.md` require scenario-specific E2E for
every change.

`agents/bubbles_shared/test-core.md` contains the stronger rule. It derives
proof from behavior traits. A pure calculation owes a production-unit
assertion. UI, API, state, dependency, accessibility, and SLA traits owe the
stronger applicable proofs.

The trait matrix should become authoritative. Persistent regression remains
universal. The physical test category remains proportionate.

### F-047-03 - Category Enforcement Can Fall Back To False-Clean

The scenario resolver treats an inventory failure as unavailable inventory.
It then uses literal title scanning. That path cannot compare the required
category with the runner category.

The selftest's A6 case depends on category comparison. The operator-supplied
run demonstrates the failure shape when no timeout implementation exists.

### F-047-04 - Automation And Human Acceptance Share One Checkbox Meaning

`feature-templates.md` creates checked `[x]` acceptance entries.
`artifact-lint.sh` requires at least one checked-by-default entry.

G136 blocks only unchecked entries at a `done` transition. Its implementation
also says automation must never check acceptance for a human.

A checked template entry therefore changes meaning over time. It begins as a
planned item and ends as accepted human behavior without a separate human act.
Automation evidence and human acceptance need separate authorities.

### F-047-05 - Observability Planning Exceeds Mechanical Certification

`planning-core.md` requires trace and SLO rows for wired instrumented scopes.
The state transition tail delegates G100. No transition caller invokes
`trace-contract-guard.sh` for G080.

`observability-slo-guard.sh` says provenance lives in `tool-calls.jsonl`.
Its decision reads the SLO JSON directly. It validates shape, workflow, and
numbers without binding a receipt, source revision, environment, or sample
window.

Telemetry must complement behavior proof. It cannot replace it.

### F-047-06 - Framework Health Cannot Resolve Its Own Transition Contract

`framework-health` declares phases `select`, `audit`, `docs`, and `finalize`.
It declares no `transitionAudit`.

`transition-contract-resolver.sh` accepts only three profiles. A mode without a
profile exits with `E009-AUDIT-PROFILE-UNSUPPORTED` unless a narrower missing
profile case applies.

### F-047-07 - Framework Self-Observation Reads The Wrong Truth Surfaces

`retro-framework-health.sh` ranks failed gates from
`framework-events.jsonl`. Per-gate outcomes are written to
`gate-hits.jsonl`.

The same script queries capability `lastValidated` fields. The current
capability ledger has no such field.

### F-047-08 - Deploy Assurance Fails Open And Binds No Evidence

`deploy-manifest-assurance-lint.sh` exits 0 when `yq` is missing. That behavior
also applies when `--require-assurance` is present.

The lint accepts any non-empty `evidenceDigest`. It does not bind the value to
a receipt root, source revision, or artifact digest.

### F-047-09 - Tool-Log Admission Is Lexical

State transition Check 9 accepts an exit-zero tool call when two non-stopword
tokens overlap a checked DoD item. The check verifies neither scenario
semantics nor the claimed outcome.

Artifact lint currently prevents this match from becoming a complete
certification bypass. That correction is important. The weakness is an
evidence-coverage false positive, not a proven full bypass.

### F-047-10 - Validation Reuse Has No Declared Input Closure

`framework-validate.sh` maps `X-selftest.sh` to `X.sh` by basename.
`validate-cache.sh` hashes the same pair plus framework version.

Registries, schemas, fixtures, shared libraries, tool versions, and platforms
are absent from that ownership model.

Existing tier, cache, impact, and fast mechanisms remove work now. No debt
ledger forces later settlement.

### F-047-11 - Capability Reachability Is File-Shaped

G127 checks that declared consumer paths exist. Its companion checks that a
shell file contains the capability name.

Neither check proves executable invocation. A selftest scheduler can satisfy
both while no production coordinator consumes the capability.

`phase-relevance-resolve.sh` and `test-impact-plan.sh` have agent and prose
consumers. They have no executable coordinator.

### F-047-12 - Metrics Claims Still Exceed Producers

The metrics registry still declares per-agent, per-spec, and per-scope tracking
as true. No activity record carries those identities.

`outcomeEvals` remains enabled without a reader. `record_activity_event` still
writes the command into a field named `phase`.

IMP-044 delivered useful registry and reader changes. These residuals remain.

### F-047-13 - Learning Is Partially Wired

The result-envelope learning disposition, compaction, scaffold backfill,
doctor advisory, recall sync, loop test, and corrected docs have landed.

`skill-evolution.sh` still hardcodes three paths. It reads no registry toggle.
No config template declares `experienceRecall`. `bubbles.setup` does not offer
the opt-in.

### F-047-14 - Continuation Is Partially Wired

The four runners consume `unattended`. G135 holds that parity. Prompt-shim
counting and durable decision principles have landed.

No `/bubbles.continue` prompt exists. Completion and per-iteration fidelity
remain unbound. Operator docs and G086 wording remain incomplete.

No global session budget should be seeded. Bounded fast modes and explicit
continuation profiles should supply budgets when needed.

### F-047-15 - Improvement Status Is Self-Consistent, Not Grounded

G125 Check 4b compares the status in an IMP with its INDEX row. It does not
derive scope state or landing evidence.

The same stale status can therefore appear in both places and pass. OW-016
records the observed instance.

### F-047-16 - Canonical Source Authority Is Caller-Asserted

`repo-binding-preflight.sh --canonical-source` prints success and exits 0.
It does not bind the claim to source provenance or release identity.

The newer repository-binding preflight protects repository selection. It does
not repair this older agent-source provenance claim.

### F-047-17 - Writer Coordination Stops At Spec Or Bug Targets

The artifact writer lease requires `--target <spec-or-bug-dir>`.
Its purpose key derives from that target.

No repository-wide writer class protects simultaneous framework source,
improvement, registry, or documentation changes.

### F-047-18 - Framework Bug Intake Contradicts Universal Bug Policy

`BUGS.md` says framework defects use single-file records because source cannot
keep `specs/`.

Universal artifact policy requires complete bug packets. BUG-032 already proves
that complete canonical packets work under `bugs/BUG-NNN-*`.

The source exception should normalize to that working precedent.

## Audit Corrections

The two supplied audit ledgers disagreed on several scope dispositions. Source
and Git history resolve them as follows.

| Item | Corrected disposition | Grounding |
| --- | --- | --- |
| IMP-042 SCOPE-4 | Decision delivered, scheduler premise declined on evidence | `87831b6` measured 2,918 seconds across 316 checks. One check consumed 35 percent. Blanket bounded parallelism was declined. |
| IMP-042 SCOPE-12 | Delivered with corrected premises | The original manifest-class duplication and governance-index blocker claims were falsified. Payload closure and manifest-governed docs landed. |
| IMP-043 SCOPE-4 | Delivered | `aeeed2d` backfilled the scaffold and added the doctor advisory. It is not open. |
| IMP-043 SCOPE-5 | Partial | `aeeed2d` added recall sync. Config-template and setup opt-in work remain open. |
| IMP-044 SCOPE-2 | Partial | `eed4e53` split dimensions by producer. Tracking flags, `outcomeEvals`, and activity `phase` misuse remain. |
| IMP-045 SCOPE-3 | Delivered | `32a1825` created one prompt count authority. `8bd1325` made the generated count checkable. |
| IMP-045 SCOPE-8 | Delivered | `242d4cb` added durable and no-shortcut principles with posture-aware taste handling. |
| IMP-046 BUG-033 prerequisite | Still open in canonical source | A downstream candidate fix was described. BUGS.md still records both source facets as open. |

The adversarial burden audit that forced this revision supplied its own
measurements. Re-measurement during this invocation confirmed most of them and
corrected four. Corrections are recorded rather than quietly adopted.

| Audit claim | Re-measured value | Grounding |
| --- | --- | --- |
| 77 distinct CHECK labels across 81 header sites | 47 distinct labels across 72 comment-banner sites, 125 total mentions | `grep -oiE 'check [0-9]+[a-z]*'` over `state-transition-guard.sh`. The structural finding survives: labels carry lettered sub-variants and numeric gaps. |
| 480 shell files, 250 selftests, 52 percent | 533 shell files, 250 selftests, 46.9 percent | `find . -name '*.sh' -not -path './.git/*'`. The selftest count is confirmed exactly. |
| `framework-validate.sh` schedules 297 scripts, 229 selftests | 316 distinct scripts referenced, 234 selftests, across 306 `run_check` registrations | Distinct `*.sh` references and `run_check` registration count. The 74 percent selftest share is confirmed in shape. |
| Bug artifact set has 3 definitions across 4 authorities | Four different counts across four authorities: 1, 3, 6, and 7 | `BUGS.md` says one single-file entry. `micro-fix-packet.yaml` requires 3 and describes the full packet as 7. `bug-templates.md` enumerates 6. The drift is worse than reported. |
| Only `bubbles-kernel.instructions.md` is truly always-on | Confirmed | Frontmatter inspection of every `instructions/*.md`. Exactly one file carries `applyTo: "**"`. |
| The `gates:` block is already removed | Confirmed | `grep -cE '^gates:' bubbles/workflows.yaml` returns 0. |
| README and prompt counts are generated and accurate | Confirmed as previously recorded | No count conflict found during this invocation. |

## Historical Measurements Retained

These numbers remain historical measurements. They are not re-measured here.

| Source | Measurement retained | Interpretation |
| --- | --- | --- |
| IMP-042 | Core validation measured 109 to 111 seconds at `09a8fc87`. | This is not a current baseline. |
| IMP-042 | Full runs measured 1,883 to 2,081 seconds at that older revision. | This is not a current baseline. |
| IMP-042 SCOPE-4 | A later full run measured 2,918 seconds across 316 checks. | Top ten checks used 73 percent. One downstream-install check used 35 percent. |
| IMP-042 SCOPE-9 | Micro-fix authoring time and defect escape remain unmeasured. | OW-015 forbids default activation. |
| IMP-043 | Eight repositories had zero lessons, proposals, or recall indexes at audit time. | Wiring was missing although components passed. |
| IMP-043 | Five repositories lacked `lessons.md`. Two carried empty seeds. | Scaffold backfill later landed. |
| IMP-044 | Six of eight repositories had empty metrics directories. | The runtime plane carried richer data elsewhere. |
| IMP-044 | The only populated metrics sample had ten CLI events and no gate or phase events. | Metrics enablement did not produce delivery telemetry. |
| IMP-045 | The source had 41 agents and 41 prompt shims when the count conflict was found. | The counts were accidentally equal. |
| IMP-046 | Framework validation declared 215 ordinary checks and 89 source-only checks. | The current exact count must be re-measured before activation. |
| IMP-046 | Thirteen selftests read the gate registry, 23 sourced `guard-lib.sh`, and 36 read workflows. | Basename closure omitted shared inputs. |

## Measured Burden Baseline

Every number below was measured during this invocation against the canonical
worktree. Each is marked measured. None is estimated, inferred, or carried
forward from a predecessor proposal.

| Measurement | Value | Method | Status |
| --- | --- | --- | --- |
| Gates in the registry | 118 | `grep -cE '^  G[0-9]{3}:' bubbles/registry/gates.yaml` | measured |
| Gates never observed to fire | 86 of 118, 72.9 percent | Registry gate IDs minus gate IDs present in `.specify/runtime/gate-hits.jsonl` | measured |
| Gates observed at least once | 32 | Distinct gate IDs in the gate-hit store | measured |
| Records in `gate-hits.jsonl` | 409 | `wc -l` | measured |
| Records originating in selftest or temporary directories | 376 | Path match on the record set | measured |
| Real gate-outcome records | 33 | The complement of the above | measured |
| Distinct timestamps among real records | 1, `2026-08-15T16:08:05Z` | Distinct `ts` values | measured |
| Distinct specs among real records | 1, `bugs/BUG-032-planning-maturity-guard-false-positives` | Distinct `spec` values | measured |
| Gates carrying a `retireWhen` clause | 25 | `grep -c 'retireWhen:'` | measured |
| Distinct metrics those clauses name | 8 | Distinct `metric:` values in those clauses | measured |
| `state-transition-guard.sh` size | 4,500 lines | `wc -l` | measured |
| Distinct CHECK labels in that guard | 47 | Case-insensitive label extraction | measured |
| CHECK comment-banner sites | 72 | Banner-form match | measured |
| Required artifacts for a small feature | 6 | Feature template and artifact lint | measured |
| `report.md` sections emitted by the canonical template | 2 headings inside the template block | Template section scan of `feature-templates.md` | measured |
| `report.md` sections enforced by `artifact-lint.sh` | 5 | Required-header patterns in the lint | measured |
| Occurrences of `Completion Statement`, `Validation Evidence`, `Audit Evidence`, and `Chaos Evidence` in the canonical template | 0 | Direct grep of `feature-templates.md` | measured |
| `report-section-autofix.sh` | 185 lines, 5,218 bytes | `wc -l -c` | measured |
| Bug artifact definitions across authorities | 4 authorities giving 1, 3, 6, and 7 | Cross-read of `BUGS.md`, `micro-fix-packet.yaml`, `bug-templates.md` | measured |
| `micro-fix-packet.yaml` shape | 3 artifacts, 8 admission questions, 4 preserved obligations, `overrideFlag: none` | Full read of the registry | measured |
| Agent files | 41 | `ls agents/*.agent.md` | measured |
| Mandatory shared trio bytes | 98,527 bytes | `wc -c` over the three modules | measured |
| Shell files in the repository | 533 | `find` excluding `.git` | measured |
| Selftest shell files | 250, 46.9 percent | `find` on the selftest name pattern | measured |
| `framework-validate.sh` registrations | 306 | `run_check` and `run_check_self_only` count | measured |
| Distinct scripts it references | 316, of which 234 are selftests | Distinct `*.sh` extraction | measured |
| Always-on instruction surface | 1 file, 4,516 bytes | Frontmatter `applyTo` inspection of every instruction | measured |
| Hand-maintained registry files | 7 | `ls bubbles/registry/` | measured |
| Orphaned `gates-block-reader` apparatus | 442 lines, 16,140 bytes, 2 registrations | `wc -l -c` plus registration grep | measured |
| Presence of the guarded `gates:` block | absent | `grep -cE '^gates:' bubbles/workflows.yaml` returns 0 | measured |

Two facts in this table carry the whole argument.

First, **gate value has effectively never been measured**. The gate-hit store
holds one real run against one bug packet at one instant. Any claim that a gate
is useful, or useless, currently rests on nothing.

Second, **the 25 `retireWhen` clauses are unretirable by construction**. They
name 8 metrics with windows of 20 to 50 observations. A store holding one run
cannot supply a window of 20. Those gates cannot retire no matter how useless
they are, which means the registry can only grow.

## Delete List

This is the section the previous draft lacked entirely. Deletion requires
safety evidence, not a preference.

| Delete | Unit | Safety evidence |
| --- | --- | --- |
| `bubbles/scripts/gates-block-reader-lint.sh`, `bubbles/scripts/gates-block-reader-lint-selftest.sh`, `bubbles/registry/gates-block-readers.txt`, the two `framework-validate.sh` registrations, and the stale present-tense prose in `bubbles/workflows.yaml` | 442 lines, 16,140 bytes, 2 of 306 registrations, 1 registry file | The guarded `gates:` block is already gone. The lint's own executed output states `the block is safe to remove` and `the inventory is empty; SCOPE-13 removal precondition is met`. Nothing can depend on an inventory that is empty by the lint's own report. |
| `bubbles/scripts/report-section-autofix.sh` | 185 lines, 5,218 bytes | Its only job is injecting the four headings the canonical template omits. Once the template is generated from the section authority, the script has no caller. Deletion is conditional on that generator landing, not before. |
| 23 mandatory template sections with zero script readers | mandatory status only | Downgrade to `(optional)`, do not hard-delete. Human readership is unproven in either direction, so removing the text is not justified. Requiring it mechanically is not justified either. |
| Old PD-09, repository-wide writer lease | 1 prerequisite packet | Not a defect. A repository-wide lease is a feature request. The absence of a capability nobody specified is not a bug. |
| Old PD-10, `BUGS.md` single-file intake | 1 prerequisite packet | Not a defect. Single-file intake is a policy preference. Its proposed fix converts each framework bug from one file into a six-artifact packet, multiplying framework-bug artifacts sixfold to satisfy a consistency argument that buys no assurance. |
| Old SCOPE-12 as a standalone scope | 1 scope | Its one irreducible requirement, a single cold exact-tree gate on the release candidate, is already framework policy. It attaches to each slice instead of forming a twelfth dependency. |
| **86 never-observed gates** | **0 deleted today** | **Explicitly NOT deletable now.** Never-observed is not never-fires when the telemetry store holds one real run against one packet. Deleting on this evidence would be exactly the unfalsifiable reasoning this proposal exists to end. This row exists so the largest available reduction is not forgotten. It is blocked on S-A and on nothing else. |

The last row is the honest one. The single largest burden reduction available
to this framework is currently unjustifiable, and it will stay unjustifiable
until gate telemetry is real. That is why S-A ships first and alone.

## Merge List

Three authorities exist in multiple copies. Each collapses to one.

| Merge | Into | Removes |
| --- | --- | --- |
| Report-section authorities currently split across `artifact-lint.sh`, `report-section-autofix.sh`, and the prose template | one `bubbles/registry/report-sections.yaml` read by the guard, the lint, and the template generator | The template-versus-guard divergence that `report-section-autofix.sh` exists to paper over. A section is required in one place or it is not required. |
| Scenario schema and the template that is supposed to emit it | the schema as single source, with the template generated from it | The four conflicting scenario shapes in F-047-01, and the compatibility tolerance that became the de facto contract. |
| Four prose restatements of the bug artifact set giving 1, 3, 6, and 7 | one `bubbles/registry/bug-packet.yaml`, a sibling of `micro-fix-packet.yaml` | Three of the four answers. A question with four answers has none. |

A merge that leaves the old copy in place is not a merge. Each merge deletes
its predecessors in the same change, per the Retirement Rule.

## Automate List

Every item below is currently hand-authored and currently drifts. Each names
its generator. **Hand-authoring any of these is forbidden once its generator
exists.** A generated file is not a hand-maintained registry and does not
count against the Retirement Rule.

| Value | Generator | Emitted form | Evidence it drifts today |
| --- | --- | --- | --- |
| per-gate `enforcedBy` | `gate-id-grep.sh` | `GENERATED:` block | G070 carries `enforcedBy: [ unbound ]` at line 481 while its own description at line 474 says the field was REPAIRED and names `goal-fidelity-guard.sh`. The field and the prose describing the field disagree inside one entry. |
| blocking versus advisory per gate | derived from the enforcing script's exit behavior | `GENERATED:` block | No mechanical source exists today. Blocking status is asserted in prose. |
| validation-check input closures | **derived empirically** by tracing `source` and `bash` references, using the technique `gates-block-reader-lint.sh` already proved | generated closure map | Do NOT hand-author `validation-checks.yaml`. A hand-written closure is a fourth guess about dependencies, and the reason closure is broken today is that basename pairing was a guess. |
| `improvements/INDEX.md` status | derived from acceptance-criteria receipts plus landing commits | generated table rows | **Do NOT create `improvements/IMP-NNN.state.json`.** A second hand-written status copy reproduces the exact OW-016 failure it claims to fix: two copies that agree with each other and disagree with reality. |
| report sections and the scenario template | `regen-derived.sh` | generated template output | The canonical template emits none of the four headings the guard requires. |
| producer-reader map | derived from `storageFile:` declarations and path constants | generated map | F-047-07: framework health reads stores and fields that do not hold what it claims. |
| **scenario states** | **derived from receipts, never declared** | receipt-derived state | See below. This is the single most important rule in this proposal. |

### Scenario States Are Derived, Never Declared

The previous draft already contained the correct rule and applied it to exactly
one state: planning may define the RED discriminator but must not claim
`RED_VERIFIED`, because only an executed receipt advances that state.

That rule now applies to **all eight states with no exception.** No state is
ever written by a human or an agent into `scenario-manifest.json`. Every state
is computed from receipts at read time.

State this plainly, because the failure mode is severe: if any state is ever
hand-written into `scenario-manifest.json`, this becomes the largest new
bookkeeping tax in the framework's history. Eight states, per scenario, per
scope, per spec, hand-maintained and drifting, is strictly worse than the
checkbox accounting it replaces. The outcome model is only a reduction if the
states are derived.

## Net Burden Accounting

| Direction | Item | Count |
| --- | --- | --- |
| adds | `report-sections.yaml` | 1 registry, generated readers |
| adds | `bug-packet.yaml` | 1 registry |
| adds | scenario-state receipt resolver | 1 script |
| adds | validation debt store | 1 append-only store |
| removes | `gates-block-reader-lint.sh` | 1 script |
| removes | `gates-block-reader-lint-selftest.sh` | 1 selftest |
| removes | `gates-block-readers.txt` | 1 registry |
| removes | 2 `framework-validate.sh` registrations | 2 scheduled checks |
| removes | stale `workflows.yaml` prose | 1 documentation defect |
| removes | `report-section-autofix.sh` | 1 script |
| removes | 3 duplicate report-section authorities collapsed into 1 | 2 authorities |
| removes | 3 duplicate bug-artifact authorities collapsed into 1 | 3 authorities |
| removes | 7 scopes | 7 planning units |
| removes | 12 prerequisite packets | roughly 72 artifacts of pre-work |

Adds: 4 persistent surfaces. Removes: 9 persistent surfaces plus 7 scopes and
12 prerequisite packets. Every add names the obligation it retires inside its
owning scope, per the Retirement Rule.

`validation-checks.yaml` does not appear in the adds column because it is
generated, not hand-maintained. If it ever becomes hand-authored it becomes an
add and must retire something.


## Prerequisite Defect Ledger

The previous draft listed 16 prerequisite defects, each requiring its own
canonical bug packet before dependent work could begin. At roughly six
artifacts per packet that is close to 96 artifacts of pre-work standing between
approval and the first delivered outcome. That is the bureaucracy this
proposal exists to remove, reproduced inside the proposal itself.

Four defects remain true blockers. Two existing packets remain. Ten are
reclassified or rejected.

A defect is a blocker only when it satisfies one of two tests: it causes a
silent false-PASS, or it prevents the work from running at all. Everything else
is inline work inside the scope that already opens that file.

### True Blockers

Packet IDs are proposal-local dependency IDs. They are not bug numbers.
`/bubbles.bug` assigns the next real BUG number. Each packet must pass artifact
lint before its dependent slice begins.

| Dependency | Confirmed defect | Why it blocks | Required packet outcome | Blocks |
| --- | --- | --- | --- | --- |
| PD-04 | Missing `timeout` support makes an applicable test category fall back to literal scanning and report clean | **Highest priority. A silent false-PASS.** The category comparison does not merely fail, it reports success. No proof built on top of it can be trusted. | Use the portable timeout helper. Fail loud when an applicable category cannot execute. | S-B, S-D |
| PD-07 | `deploy-manifest-assurance-lint.sh` exits 0 when `yq` is absent, including under `--require-assurance` | A mandatory assurance check that passes when its tool is missing is a false-PASS wearing the word `require`. | Fail closed when assurance is mandatory. Bind `evidenceDigest` to source, artifact, and receipt root. | S-E |
| PD-11 | `framework-health` declares no `transitionAudit` profile, so `transition-contract-resolver.sh` exits `E009-AUDIT-PROFILE-UNSUPPORTED` | Blocks running the mode at all. Framework health cannot audit itself, which makes S-A unrunnable. | Add an explicit proposal audit contract or an explicit supported no-certification contract. | S-A |
| PD-12 | The acceptance template ships checked `[x]` entries that later read as terminal human acceptance | **A fabrication vector.** A planning checkbox silently becomes a human sign-off without any human act. This converts planning into acceptance, which is the exact failure anti-fabrication policy exists to prevent. | Split automation readiness from human acceptance authority, with separate fields and separate writers. | S-D |

### Existing Packets Retained

| Dependency | State | Required outcome | Blocks |
| --- | --- | --- | --- |
| BUG-032 | Packet exists, incomplete | Finish Scope 2 reconciliation, Scope 3 ordering, Scope 4 contracts, phase chain, and cold certification. | S-B |
| BUG-033 | No packet, both receipt facets open | Create the full packet. Fix target grouping and shell or environment wrapper normalization. | S-C, S-E |

### Reclassified To Inline Work

These ten are real. None of them blocks. Each is repaired inside the scope
that already opens the file, in the same change, with the same evidence
standard. **They are inline work, not prerequisite packets.** Removing their
packets removes roughly 60 artifacts of pre-work without removing a single
repair.

| Old ID | Defect | Repaired inline by | File that scope already opens |
| --- | --- | --- | --- |
| PD-01 | BUG-032 incompleteness beyond the packet itself | S-B | the packet is retained above; only the derived scope work moves inline |
| PD-02 | Receipt target grouping and wrapper normalization | S-C | packet retained above as BUG-033 |
| PD-03 | Scenario schema, template, writer, and readers disagree | S-B | `scenario-manifest.schema.json` and `feature-templates.md` are the two files S-B rewrites. Repairing the disagreement is S-B's entire purpose. A separate packet would fix the file S-B then rewrites. |
| PD-05 | Framework health reads wrong stores and absent fields | S-A | `retro-framework-health.sh` is S-A's central surface |
| PD-06 | Check 9 tool-log admission is lexical | S-C | `state-transition-guard.sh` Check 9 is inside the receipt engine S-C builds |
| PD-08 | `--canonical-source` is self-asserted | S-A | `repo-binding-preflight.sh`, opened by S-A's provenance work |
| PD-13 | G080 is not called by terminal transition machinery | S-A | the transition tail S-A already repairs for PD-11 |
| PD-14 | SLO evidence is not bound to its execution receipt | S-C | receipt binding is the definition of S-C |
| PD-15 | Activity records write a command into `phase` | S-A | the producer-reader map S-A generates |
| PD-16 | Evidence-location rules disagree about inline-only evidence | S-B | `evidence-rules.md` and `scope-workflow.md`, both opened by S-B |

### Rejected

Two items were category errors. They are not defects and no packet should be
created for either.

| Old ID | Claim | Why it is rejected |
| --- | --- | --- |
| PD-09 | Writer leases have no repository-wide framework target | **A feature request, not a defect.** Nothing specified a repository-wide lease, nothing depends on one, and no observed failure is attributed to its absence. Calling a missing unspecified capability a defect is how backlogs become blockers. |
| PD-10 | `BUGS.md` single-file intake conflicts with complete packet policy | **A policy preference whose fix increases burden sixfold.** Converting each framework bug from one file into a six-artifact packet multiplies framework-bug artifacts by six to satisfy a consistency argument. It buys no assurance. Under the Retirement Rule it would have to retire an equivalent obligation, and it retires nothing. The single-file form is retained and the inconsistency is resolved in the opposite direction: `bug-packet.yaml` records that framework source bugs use the single-file form deliberately. |

The master proposal tracks dependencies and expected behavior. It does not
replace the two retained bug packets.


## Outcome-First Delivery Contract

### Scenario State Authority

| State | Required fact | Owning proof |
| --- | --- | --- |
| `PLANNED` | Stable scenario ID, traits, obligations, implementation refs, and test plan exist. | Planning artifacts only. No execution claim. |
| `RED_VERIFIED` | The planned discriminator executed before implementation and failed for the expected behavior. | Receipt bound to scenario, test, negative control, and source revision. |
| `IMPLEMENTED` | Production or contract surfaces changed within the declared boundary. | Git-backed implementation refs and change receipt. |
| `GREEN_TARGETED` | The same scenario and negative control now pass through the targeted path. | Same-scenario receipt after implementation. |
| `GREEN_LIVE` | Applicable current production route or boundary proves the outcome. | Playwright, API, state round trip, provider boundary, or equivalent live proof. |
| `REGRESSION_GREEN` | Affected scenarios and required broader regression remain green. | Affected plan plus regression receipts. |
| `OBSERVED` | Applicable trace, SLO, or metric contract is met for the same execution window. | Receipt-bound telemetry artifact. |
| `CERTIFIED` | All required scenario states, DoD, scopes, specialists, debt, and certification predicates hold. | Validate-owned transition evidence. |

Planning may define the RED discriminator. Planning must not claim
`RED_VERIFIED`. Only an executed receipt can advance that state.

Implementation may claim `IMPLEMENTED`. It cannot claim certification.

The same scenario must advance from RED to targeted GREEN. Replacing the test,
scenario, or negative control requires a planning revision and a new RED state.

### Applicability Contract

| Behavior trait | Minimum proof | Live or observed state |
| --- | --- | --- |
| Pure calculation or validation | Production-unit assertion over transformed output | `GREEN_LIVE` and `OBSERVED` are not applicable unless another trait requires them. |
| User-visible UI | Visible or accessibility-tree assertion on the current route | Playwright or equivalent current-route proof is required. |
| API or wire contract | Real request and externally observable response | API proof is required. |
| Mutable state | Write, read, and persistence round trip | Real ephemeral state proof is required. |
| Degraded or unavailable state | Named negative path without a plausible default | Real boundary behavior is required when the boundary exists. |
| Shared consumer or adapter | Producer-consumer parity and current consumer proof | The real consumer path is required. |
| Cache, provider, queue, or transport | Declared dependency state and boundary assertion | A live or controlled-real boundary is required. |
| Responsive or accessible UI | Required viewport and accessibility behavior | Playwright or equivalent accessibility proof is required. |
| SLA-sensitive behavior | Stress or load proof against the threshold | `OBSERVED` is required with receipt-bound telemetry. |
| Documentation or static metadata | Structural and reference proof | Runtime proof is not applicable. |
| Runtime configuration | Startup or runtime behavior under the resolved config | A documentation exemption is forbidden. |

Every not-applicable result must name the absent behavior trait. A blanket
`not applicable` string is insufficient.

### Gate Relationship

Gates can refuse a state transition. They cannot advance a scenario state by
themselves.

Gate utility is measured by prevented invalid transitions and defect escape.
It is not measured by the number of green gates.

## Scope Graph

Twelve scopes collapse into five. Each surviving slice is independently
shippable and ends with one cold exact-tree gate on its own candidate.

| Scope | Depends On | Delivered value |
| --- | --- | --- |
| S-A Truthful telemetry and gate accounting | PD-11 | Every gate records whether it fired and whether it prevented anything, so all 118 can finally be justified or retired. |
| S-B One scenario contract | S-A, PD-04, BUG-032 | One schema generates the template, so a spec authored from the canonical template is valid on first write. |
| S-C RED to GREEN outcome engine | S-B, BUG-033 | A scope is done when its named scenario went red then green on the same test, not when its checkboxes are full. |
| S-D Proportionate proof | S-B, PD-04, PD-12 | Pure calculations stop paying for fake E2E and one-line fixes stop paying seven artifacts, while UI, API, state and SLA work pays more. |
| S-E Declared input closure and validation debt | S-A, PD-07, BUG-033 | Validation runs only what the change can affect, records what it skipped, and settles it before release. |

### Old-To-New Scope Mapping

Predecessor records and INDEX rows reference the old twelve-scope identifiers.
This table keeps those references resolvable.

| Old scope | Disposition |
| --- | --- |
| SCOPE-1 | merged into S-A |
| SCOPE-2 | **deferred out of IMP-047.** Only "generate INDEX status from delivery evidence" is retained, folded into S-A. The improvement state model, repository-wide lease, and bug intake migration do not proceed. |
| SCOPE-3 | merged into S-B |
| SCOPE-4 | merged into S-C |
| SCOPE-5 | merged into S-D |
| SCOPE-6 | merged into S-E |
| SCOPE-7 | merged into S-E |
| SCOPE-8 | merged into S-C |
| SCOPE-9 | merged into S-A |
| SCOPE-10 | **deferred out of IMP-047.** `/bubbles.continue` and the learning residuals do not proceed in this proposal. |
| SCOPE-11 | split: evidence and template coherence into S-B, registry and reachability into S-E |
| SCOPE-12 | **deferred out of IMP-047 as a standalone scope.** Its one irreducible requirement, a single cold exact-tree gate on the release candidate, folds into every slice. |


## Proposal

<!-- markdownlint-disable MD024 -->

### S-A - Truthful Telemetry And Gate Accounting

**Delivered value:** Every gate records whether it fired and whether it
prevented anything, so all 118 can finally be justified or retired.

**Merged from:** old SCOPE-1 and SCOPE-9, old PD-05 and PD-11, plus the single
retained fragment of old SCOPE-2. Adds derived blocking-versus-advisory status
and derived `enforcedBy`.

**Depends On:** PD-11 only.

**Retires, per the Retirement Rule:** the `gates-block-reader` apparatus, 442
lines and 16,140 bytes across 1 script, 1 selftest, 1 registry file, and 2
scheduled registrations, plus the stale `workflows.yaml` prose. Hand-authored
`enforcedBy` and hand-asserted blocking status are replaced by generated
blocks, so no hand-maintained registry is added.

**Owners:** Framework health owner, `bubbles.retro`, and `bubbles.validate` for
transition certification.

#### Problem / Retained Predecessor Inputs

IMP-042 retained gate telemetry and workflow truth work. IMP-044 retained the
one-plane measurement decision. IMP-045 retained outcome completion needs.

The measured state is worse than those predecessors assumed. The gate-hit store
holds 409 records, of which 376 originate in selftest temporary directories.
The 33 real gate-outcome records share one timestamp and one spec. 86 of 118
gates have never been observed to fire. 25 gates carry `retireWhen` clauses
naming 8 metrics with windows of 20 to 50 observations, which a one-run store
can never supply, so those gates are unretirable by construction.

Framework health also reads the wrong stores and absent fields, and its mode
has no resolvable transition audit contract.

#### Intended Behavior

Define the scenario-state vocabulary as framework policy. State explicitly
that gates constrain delivery and never measure progress.

Give framework health one truthful reader registry, generated from
`storageFile:` declarations and path constants rather than hand-authored. Read
gate outcomes, workflow runs, capability evidence, outcome state, and debt from
their actual stores.

Record per gate, on every evaluation, whether it fired and whether it refused a
transition that would otherwise have proceeded. A gate that fires and permits
is not the same as a gate that never fires, and today the store cannot tell
them apart.

Derive `enforcedBy` from `gate-id-grep.sh` and emit it as a `GENERATED:` block.
Derive blocking versus advisory from the enforcing script's exit behavior and
emit it the same way. Both fields are currently hand-written and G070 already
proves they drift: the field says `enforcedBy: [ unbound ]` while the
description in the same entry says the binding was repaired.

Generate `improvements/INDEX.md` status from acceptance-criteria receipts and
landing commits. **Do not create `improvements/IMP-NNN.state.json`.** A second
hand-written status copy reproduces the OW-016 failure it claims to fix.

Retire the `gates-block-reader` apparatus in this scope, and make the
orphaned-scaffolding corollary mechanical: a lint reporting its own removal
precondition must fail rather than pass.

#### Exact Candidate Surfaces

- `bubbles/workflows/modes.yaml`
- `bubbles/scripts/transition-contract-resolver.sh`
- `bubbles/scripts/retro-framework-health.sh`
- `bubbles/scripts/gate-hit-log.sh`
- `bubbles/scripts/gate-id-grep.sh`
- `bubbles/scripts/repo-binding-preflight.sh`
- `bubbles/scripts/trace-contract-guard.sh`
- `bubbles/capability-ledger.yaml`
- `bubbles/registry/gates.yaml`
- `bubbles/workflows.yaml`
- `agents/bubbles.retro.agent.md`
- `bubbles/scripts/framework-health-evidence-lint.sh`
- `improvements/INDEX.md`
- Deleted in this scope: `bubbles/scripts/gates-block-reader-lint.sh`, `bubbles/scripts/gates-block-reader-lint-selftest.sh`, `bubbles/registry/gates-block-readers.txt`, and their two `framework-validate.sh` registrations

#### RED Discriminator

A framework-health transition fixture without `transitionAudit` must currently
exit with `E009-AUDIT-PROFILE-UNSUPPORTED`.

A health fixture with gate hits only in `gate-hits.jsonl` must currently report
no gate failures. A capability fixture using the current ledger shape must not
produce a valid age decision.

A gate that fires and permits must currently be indistinguishable in the store
from a gate that never fired.

A fixture asserting `enforcedBy` for G070 must currently disagree with the same
entry's own description.

#### Implementation Responsibilities

PD-11 repairs the transition contract first. Old PD-05, PD-08, PD-13, and PD-15
are repaired inline here, in the files this scope already opens, not through
separate packets.

This scope then defines one generated producer-reader registry and one
scenario-state authority. The registry must distinguish direct, derived, and
unmeasured values.

Firing and prevention are recorded as separate facts. Prevention is the only
basis on which a gate may later be retired.

#### GREEN Proof

The same fixtures must resolve the framework-health transition, rank gate
failures from the gate store, and report capability freshness honestly.

A gate that fires and permits must be distinguishable from a gate that never
fired. Changing `enforcedBy` by hand must fail against the generated block.

#### Applicable Live Or Telemetry Proof

Product Playwright and API proof are **not applicable**. The absent behavior
trait is user-visible UI: this scope governs a framework analysis path with no
product runtime and no user-visible route.

Real append-only framework runtime fixtures are applicable. The reader must
consume their actual schemas without synthetic field aliases.

#### Migration And Rollback

Shadow old and new readers for one release. Keep old fields read-only during
that window. Roll back by selecting the old reader registry without rewriting
events.

The `gates-block-reader` deletion has no rollback requirement beyond git
revert, because its inventory is empty by its own report.

#### Measurable Outcome

Track the fraction of reported fields backed by a real producer. Target 100
percent. Report unmeasured fields explicitly.

Track distinct gates observed, distinct specs represented, and distinct days
represented in the gate store. The opening values are 32, 1, and 1.

#### Executable Acceptance Criteria

1. A framework-health transition contract resolves without an unsupported profile.
2. Gate ranking changes when only `gate-hits.jsonl` changes.
3. Capability freshness uses fields present in the current ledger schema.
4. Scenario progress reports state counts and never gate-pass counts as progress.
5. Every reader names its producer and store.
6. Each gate evaluation records fired-or-not and prevented-or-not as separate facts.
7. `enforcedBy` and blocking status are generated, and a hand edit fails.
8. INDEX status derives from receipts and commits, with no sibling state file created.
9. The `gates-block-reader` apparatus is absent and `framework-validate.sh` schedules two fewer checks.
10. A lint that reports its own removal precondition is met exits non-zero.
11. One cold exact-tree gate passes on this slice's own candidate.

### S-B - One Scenario Contract

**Delivered value:** One schema generates the template, so a spec authored from
the canonical template is valid on first write.

**Merged from:** old SCOPE-3, the evidence half of old SCOPE-11, old PD-03 and
PD-04.

**Depends On:** S-A, PD-04, and the BUG-032 packet.

**Retires, per the Retirement Rule:** `report-section-autofix.sh`, 185 lines
and 5,218 bytes. Three report-section authorities collapse into one generated
`report-sections.yaml`. Three of the four bug-artifact authorities collapse
into one `bug-packet.yaml`. 23 mandatory template sections with no script
reader are downgraded to optional. Two registries are added and five
authorities plus one script are removed.

**Owners:** `bubbles.plan`, schema owner, test inventory owner, and
`bubbles.test` for executable resolution.

#### Problem / Retained Predecessor Inputs

IMP-040 delivered useful scenario traits, obligations, mechanisms, and
implementation refs. The canonical producer and schema still disagree.

The measured shape of the problem is a template that cannot satisfy its own
guards. `feature-templates.md` contains zero occurrences of `Completion
Statement`, `Validation Evidence`, `Audit Evidence`, or `Chaos Evidence`, while
`artifact-lint.sh` requires five sections including all four. A separate
script, `report-section-autofix.sh`, exists solely to inject the missing empty
headings. The framework ships a template that fails its own lint, then ships a
tool to paper over the failure.

The bug artifact set has four answers across four authorities: `BUGS.md` says
one file, `micro-fix-packet.yaml` requires three and describes the full packet
as seven, and `bug-templates.md` enumerates six.

Category resolution can also false-clean when timeout support is absent.

#### Intended Behavior

Define one scenario-manifest envelope and one scenario object shape. Keep
stable scenario IDs across wording changes. **Generate the template from the
schema.** A template that is generated cannot disagree with its schema.

Record traits, obligations, implementation refs, negative control, linked
tests, and Test Plan parity. Resolve project commands through the inventory
adapter. Fail loud when an applicable category has no runnable command.

Create `bubbles/registry/report-sections.yaml` as the single authority read by
the guard, the lint, and the template generator. Delete
`report-section-autofix.sh` in the same change, because a generated template
emits every required section and nothing needs injecting.

Create `bubbles/registry/bug-packet.yaml` as the single bug-artifact authority,
a sibling of `micro-fix-packet.yaml`. It records the full packet, the compact
packet, and the deliberate single-file form for framework source bugs. The
three prose restatements are deleted in the same change.

Downgrade the 23 mandatory template sections with zero script readers to
`(optional)`. Do not delete their text: human readership is unproven in either
direction, so the text stays and only the mechanical requirement goes.

Define one evidence-location contract across rules, templates, and gates,
resolving the inline-only contradiction inherited from old PD-16.

#### Exact Candidate Surfaces

- `bubbles/schemas/scenario-manifest.schema.json`
- `agents/bubbles_shared/feature-templates.md`
- `agents/bubbles_shared/planning-core.md`
- `agents/bubbles_shared/test-core.md`
- `agents/bubbles_shared/evidence-rules.md`
- `agents/bubbles_shared/scope-workflow.md`
- `agents/bubbles_shared/bug-templates.md`
- `BUGS.md`
- `bubbles/scripts/scenario-test-resolve.sh`
- `bubbles/scripts/scenario-test-resolve-selftest.sh`
- `bubbles/scripts/test-inventory-resolve.sh`
- `bubbles/scripts/test-mechanism-lint.sh`
- `bubbles/scripts/scenario-obligation-lint.sh`
- `bubbles/scripts/artifact-lint.sh`
- `bubbles/scripts/regen-derived.sh`
- `bubbles/scripts/guards/control-plane-checks.sh`
- New generated registry: `bubbles/registry/report-sections.yaml`
- New registry: `bubbles/registry/bug-packet.yaml`
- Deleted in this scope: `bubbles/scripts/report-section-autofix.sh`

#### RED Discriminator

Validate the shipped template output against the canonical schema. It must fail
on version, ID, linked-test, or lockdown shape before the repair.

Author a `report.md` from the canonical template and run `artifact-lint.sh`
against it. It must currently fail on missing required sections, proving the
template cannot satisfy its own guard.

Run A6 with no timeout implementation. It must expose the category false-clean
before the repair.

Ask the four bug-artifact authorities how many artifacts a bug needs. They must
currently return four different answers.

#### Implementation Responsibilities

PD-04 repairs the timeout path first. Old PD-03 and PD-16 are repaired inline
here, in the files this scope already rewrites. A separate packet for PD-03
would repair the very file this scope then regenerates.

Writers produce only the canonical shape. Readers dual-read declared legacy
shapes during the migration window.

#### GREEN Proof

Template output validates without compatibility rewriting. A `report.md`
authored from the canonical template passes `artifact-lint.sh` on first write,
with no autofix step.

A6 refuses a unit test offered as E2E on macOS and Linux. Every Markdown Test
Plan row and JSON row resolves to the same scenario, command, and category.

All four bug-artifact authorities resolve to `bug-packet.yaml` and return one
answer.

#### Applicable Live Or Telemetry Proof

Product live proof is **not applicable**. The absent behavior trait is
user-visible UI: this scope governs schema and template shape with no product
route. Real command resolution through a project inventory fixture is
applicable and required.

#### Migration And Rollback

Provide an idempotent manifest migration. Preserve legacy readers for one
declared release window. Roll back by retaining dual read while stopping new
writes.

`report-section-autofix.sh` is deleted only after the generated template is
proven to emit every required section. Deletion order is generator first,
script second.

#### Measurable Outcome

Track migrated manifests, unresolved categories, compatibility reads, and Test
Plan divergence. Target zero new legacy writes.

Track first-write lint pass rate for `report.md` authored from the canonical
template. The opening value is zero, because the required sections are absent.

#### Executable Acceptance Criteria

1. One schema validates every new manifest.
2. The template is generated from that schema and emits it exactly.
3. A `report.md` authored from the canonical template passes artifact lint with no autofix.
4. `report-section-autofix.sh` is absent and has no caller.
5. Legacy manifests remain readable during the declared window.
6. Every linked test resolves to a real file and exact test when declared.
7. Applicable category comparison fails loud when no command can run.
8. Test Plan Markdown and JSON remain in parity.
9. One `bug-packet.yaml` answers the artifact question, and the three prose restatements are gone.
10. The 23 reader-less sections are optional, and their text is retained.
11. One evidence-location contract governs all surfaces.
12. One cold exact-tree gate passes on this slice's own candidate.

### S-C - RED To GREEN Outcome Engine

**Delivered value:** A scope is done when its named scenario went red then
green on the same test, not when its checkboxes are full.

**Merged from:** old SCOPE-4 and SCOPE-8, old PD-02 and PD-06.

**Depends On:** S-B and the BUG-033 packet.

**Retires, per the Retirement Rule:** checkbox-count completion as a
certification basis, and the lexical tool-log admission path in Check 9. One
resolver script is added. The DoD-checkbox accounting it replaces is removed in
the same change rather than left alongside it.

**Owners:** `bubbles.plan`, `bubbles.implement`, `bubbles.test`, and
`bubbles.validate` within their existing authority.

#### Problem / Retained Predecessor Inputs

IMP-040 introduced scenario TDD and impact refs. IMP-045 retained a completion
predicate. IMP-046 retained receipt identity and closure needs. IMP-042
SCOPE-6 and IMP-045 SCOPE-9 and SCOPE-10 remain open.

No single engine binds RED, implementation, same-scenario GREEN, regression,
live proof, observation, and certification. Phase relevance and test impact
have no executable coordinator, and the current resume state cannot distinguish
repeated phase occurrences.

Check 9 admits an exit-zero tool call when two non-stopword tokens overlap a
checked DoD item. That is lexical coincidence presented as evidence.

#### Intended Behavior

Planning defines an executable discriminator without claiming execution.
Implementation starts only after expected behavioral RED.

Each receipt binds scenario ID, test identity, source revision, negative
control, and implementation refs. The same scenario and control must turn GREEN
after implementation.

**Every scenario state is derived from receipts and never declared.** No state
is written by a human or an agent into `scenario-manifest.json`. The previous
draft applied this rule to `RED_VERIFIED` alone. It now applies to all eight
states with no exception. If any state is ever hand-written, this becomes the
largest new bookkeeping tax in the framework's history, and the outcome model
stops being a reduction.

Consume phase relevance, test impact, receipts, debt, and scenario state in one
executable coordinator. Persist an occurrence-aware cursor. Resume from the
first unresolved occurrence and never replay an accepted phase.

Represent prerequisite DAG failures as `BLOCKED_NOT_RUN` while preserving
independent diagnostics. Run plan-fidelity reconciliation each iteration.

Define completion from specs, scopes, scenario states, specialists, debt, and
certification. Reconcile G086 wording with the actual agent-file enforcement.

Bind tool-log evidence to scenario, claim, command, source revision, and
outcome semantics, replacing the lexical match.

#### Exact Candidate Surfaces

- `bubbles/schemas/scenario-manifest.schema.json`
- `bubbles/schemas/tool-call.schema.json`
- `bubbles/scripts/tool-log.sh`
- `bubbles/scripts/evidence-receipt-check.sh`
- `bubbles/scripts/evidence-tool-log-bridge.sh`
- `bubbles/scripts/scenario-impact-resolve.sh`
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-snapshot.sh`
- `bubbles/scripts/phase-relevance-resolve.sh`
- `bubbles/scripts/test-impact-plan.sh`
- `bubbles/scripts/observability-slo-guard.sh`
- `agents/bubbles_shared/plan-bootstrap.md`
- `agents/bubbles_shared/implement-bootstrap.md`
- `agents/bubbles_shared/test-bootstrap.md`
- `agents/bubbles_shared/workflow-phase-engine.md`
- `agents/bubbles_shared/workflow-execution-loops.md`
- `agents/bubbles.workflow.agent.md`
- `agents/bubbles.goal.agent.md`
- `agents/bubbles.iterate.agent.md`
- `agents/bubbles.sprint.agent.md`
- `bubbles/registry/gates.yaml`
- New scenario-state receipt resolver and executable phase coordinator under `bubbles/scripts/`

#### RED Discriminator

A fixture must currently advance implementation without a receipt-bound RED.
Another fixture must allow GREEN from a different test or negative control.

An interrupted mode with `validate` twice must currently resume by phase name
or model choice. A missing prerequisite must currently leave later checks
without `BLOCKED_NOT_RUN` identity.

A tool-log command sharing two tokens with an unrelated DoD item must currently
be admitted as evidence for that item.

A hand-written scenario state must currently be accepted as authoritative.

#### Implementation Responsibilities

BUG-033 repairs receipt target grouping and wrapper normalization first. Old
PD-06 and PD-14 are repaired inline here, inside the receipt engine this scope
builds.

Planning owns discriminator shape. Implement owns production changes. Test owns
behavioral execution. Validate owns certification.

The coordinator must reject cross-scenario receipt substitution, source
revision drift, and missing negative controls. Build the coordinator and cursor
together: a resolver without a production consumer must not ship.

#### GREEN Proof

One scenario fixture must move through every applicable state, with every state
computed from receipts. The receipt IDs must remain stable and auditable.

Changing the test, control, or implementation ref without a planning revision
must fail. Writing a state by hand must fail.

An interrupted repeated-phase fixture resumes at the correct occurrence and
accepted phases do not replay. A failed prerequisite marks dependents
`BLOCKED_NOT_RUN` while independent checks still execute.

A tool-log command that shares tokens but not semantics with a DoD item is
refused.

#### Applicable Live Or Telemetry Proof

Applicability is scenario-derived. The engine requires live and observed states
only when traits demand them, and it must launch applicable live proof selected
by those traits.

An interrupted real process fixture is required for resume behavior.

#### Migration And Rollback

Derive `PLANNED` for existing manifests from receipts. Do not infer later
states from checked boxes. Backfill only from resolvable receipts.

Mirror legacy phase names and new occurrence IDs. Conservative migration starts
at the first unresolved occurrence. Rollback stops state advancement, uses
legacy phase state, and preserves all receipts and occurrence records.

#### Measurable Outcome

Track RED-to-GREEN lead time, scenario substitution failures, reopened
scenarios, certification defects, replayed phases, resume accuracy, convergence
iterations, and plan-fidelity drift.

#### Executable Acceptance Criteria

1. Implementation cannot start without expected behavioral RED.
2. RED and GREEN cite the same scenario and negative control.
3. Source revision drift invalidates the receipt.
4. A changed implementation ref marks the scenario affected.
5. Gate passes never advance scenario state.
6. Every scenario state is derived from receipts, and a hand-written state is refused.
7. Validate derives certification only from required scenario states, never from checkbox counts.
8. Repeated phases have distinct occurrence IDs and resume starts at the first unresolved one.
9. Accepted phase results are not replayed.
10. Phase relevance and test impact drive actual execution through a non-selftest consumer.
11. Prerequisite failures create `BLOCKED_NOT_RUN` dependents.
12. Each iteration records plan fidelity, and iteration exhaustion never reports success.
13. Tool-log admission proves semantic claim coverage, not token overlap.
14. One cold exact-tree gate passes on this slice's own candidate.

### S-D - Proportionate Proof

**Delivered value:** Pure calculations stop paying for fake E2E and one-line
fixes stop paying seven artifacts, while UI, API, state and SLA work pays more.

**Merged from:** old SCOPE-5, micro-fix packet activation, old PD-12.

**Depends On:** S-B, PD-04, and PD-12.

**Retires, per the Retirement Rule:** the universal-E2E obligation, replaced by
the trait matrix, and three of the seven required bug artifacts on the compact
route. No registry is added: `micro-fix-packet.yaml` already exists and is
switched on rather than rewritten.

**Owners:** `bubbles.plan`, `bubbles.test`, `bubbles.journey`, and the human
owner for acceptance.

#### Problem / Retained Predecessor Inputs

Universal E2E language in `critical-requirements.md` and `e2e-regression.md`
conflicts with the trait matrix in `test-core.md`. Synthetic tests can be
offered as strong proof for behavior that requires a real route or boundary.

The acceptance template ships checked entries that later read as terminal human
acceptance, so a planning checkbox becomes a human sign-off with no human act.

`bubbles/registry/micro-fix-packet.yaml` already exists and is complete: 3
required artifacts, 8 closed admission questions, 4 preserved obligations, and
`overrideFlag: none`. It is switched off pending measurement of authoring time
and defect escape.

**No producer for those measurements exists.** A precondition the system cannot
produce is a permanent veto dressed as rigour. It is the clearest single
example of the bureaucracy this proposal exists to remove.

#### Intended Behavior

Make the trait-derived obligation matrix authoritative. Persistent regression
remains universal. The physical test category becomes proportionate.

Use Playwright on the current production route for user-visible UI. Use real
request and response for API contracts. Use write and read proof for mutable
state. Use a live boundary for freshness, retry, queue, provider, and
dependency behavior. Use stress or load proof for SLA traits.

Synthetic tests may complement applicable live proof. They may never replace
it. Pure logic, docs, static metadata, and non-runtime config receive
proportionate proof. Runtime config receives no docs exemption.

Separate automation readiness from human acceptance, with separate fields and
separate writers. Automation must never check an acceptance box for a human.

**Activate the micro-fix packet as the default for any bug that passes all 8
closed admission questions.** Keep the 4 preserved obligations and
`overrideFlag: none` intact and unmodified. Record defect-escape rate **going
forward**, as an observed outcome of the activated route, rather than as a
precondition for activating it. A route that cannot be measured until it runs
cannot be gated on measurements from before it ran.

Escalation stays automatic and mechanical: any failed admission condition
escalates to the full packet, with no reviewer discretion and no override.
That is what makes activation safe.

#### Exact Candidate Surfaces

- `agents/bubbles_shared/critical-requirements.md`
- `agents/bubbles_shared/e2e-regression.md`
- `agents/bubbles_shared/test-core.md`
- `agents/bubbles_shared/test-fidelity.md`
- `agents/bubbles_shared/feature-templates.md`
- `bubbles/scripts/test-mechanism-lint.sh`
- `bubbles/scripts/regression-quality-guard.sh`
- `bubbles/scripts/artifact-lint.sh`
- `bubbles/scripts/micro-fix-admission.sh`
- `bubbles/scripts/guards/tail-delegated-gates.sh`
- `bubbles/registry/gates.yaml`
- `bubbles/registry/micro-fix-packet.yaml`, activation only, contract unchanged

#### RED Discriminator

A pure calculation fixture must currently inherit universal E2E wording. A UI
fixture with hidden DOM only must expose the missing live route proof.

A checked-by-default acceptance template must currently satisfy terminal human
acceptance without a separate human record.

A bug passing all 8 admission questions must currently be required to author
the full packet, because the compact route is not the default.

#### Implementation Responsibilities

PD-12 separates human authority first. This scope reconciles test policy and
applicability, then flips the micro-fix default.

Planning records traits and proof obligations. Test executes the owed
categories. Journey records observations without granting acceptance.

The micro-fix contract itself is not edited. Only its default-route status
changes, and the OW-015 anchor is updated in place without duplicating the row.

#### GREEN Proof

Pure calculation requires only production-unit proof. UI, API, state,
dependency, and SLA fixtures require their stronger paths.

Automation cannot set human acceptance. A human-owned action or external
acceptance record is required.

A bug passing all 8 admission questions authors 3 artifacts. A bug failing any
one of them escalates automatically to the full packet with no override
available.

#### Applicable Live Or Telemetry Proof

This scope defines applicability, so its acceptance corpus must include each
trait and at least one valid not-applicable case naming the absent trait.

Live proof is applicable to the UI, API, state, dependency, and SLA fixtures in
that corpus and is required for them.

#### Migration And Rollback

Backfill traits conservatively. Unknown traits require review and cannot earn a
live-proof exemption. Retain old E2E links as regression evidence during
migration.

Rollback restores old policy text without deleting trait data, and returns
micro-fix to opt-in without deleting any packet already authored under it.

#### Measurable Outcome

Track live-proof rate by applicability, false mandatory E2E rate, hidden-path
substitutions, and human acceptance provenance.

Track compact-route authoring time and defect-escape rate from activation
forward. These are outcomes of the change, not preconditions for it.

#### Executable Acceptance Criteria

1. Pure calculations pass with production-unit proof and no fake E2E shell.
2. UI scenarios require current-route visible or accessibility proof.
3. API scenarios require a real request and response.
4. Mutable state requires a write and read round trip.
5. SLA scenarios require stress or load plus observation.
6. Runtime config executes through startup or runtime behavior.
7. Automation evidence cannot grant human acceptance.
8. A bug passing all 8 admission questions uses the compact packet by default.
9. The 4 preserved obligations and `overrideFlag: none` are unchanged.
10. Any failed admission condition escalates automatically with no override.
11. Defect escape is recorded from activation forward and is not a precondition.
12. One cold exact-tree gate passes on this slice's own candidate.

### S-E - Declared Input Closure And Validation Debt

**Delivered value:** Validation runs only what the change can affect, records
what it skipped, and settles it before release.

**Merged from:** old SCOPE-6 and SCOPE-7, the registry half of old SCOPE-11,
old PD-07.

**Depends On:** S-A, PD-07, and the BUG-033 packet.

**Retires, per the Retirement Rule:** basename-pair ownership as the reuse key,
and the file-shaped G127 reachability check. One append-only debt store is
added. `validation-checks.yaml` is **generated**, not hand-maintained, so it
does not count as an added registry.

**Owners:** Framework validation owner, `bubbles.test`, `bubbles.releases`,
`bubbles.devops`, and `bubbles.validate` at their boundaries.

#### Problem / Retained Predecessor Inputs

IMP-042 SCOPE-2 and SCOPE-3 move here, as do IMP-046 SCOPE-1 through SCOPE-7.

Human labels and basenames decide tier, change impact, and cache reuse, so
unknown dependencies produce stale reuse. Existing tier, cache, impact, and
fast mechanisms remove work now, but no debt ledger forces later settlement.

`deploy-manifest-assurance-lint.sh` exits 0 when `yq` is missing, including
under `--require-assurance`, and accepts any non-empty `evidenceDigest`.

G127 checks that declared consumer paths exist and that a shell file contains
the capability name. Neither proves executable invocation, so a selftest
scheduler satisfies both while no production coordinator consumes the
capability.

The scale of the surrounding waste is measured: `framework-validate.sh` carries
306 registrations across 316 distinct scripts, 234 of which are selftests. The
repository holds 533 shell files, 250 of them selftests.

#### Intended Behavior

Define stable check IDs and dependency-complete input closures covering
scripts, selftests, libraries, registries, schemas, fixtures, commands, tool
versions, platform, and framework version.

**Derive those closures empirically** by tracing `source` and `bash`
references, using the technique `gates-block-reader-lint.sh` already proved.
Do not hand-author `validation-checks.yaml`. A hand-written closure is a fourth
guess about dependencies, and guessing is precisely why the current basename
model is broken.

Distinguish `PASS`, `REUSED`, and `DEFERRED`. Unknown dependencies force
execution and forbid reuse.

Add an append-only validation debt ledger. Each entry names check, obligation
class, source revision, spec or scope, reason token, and settlement boundary.
Add a batch executor that groups compatible heavy obligations across changes
and writes one settling receipt per obligation.

`basic` is the immediate affected-validation floor within `fast`. It is not
another assurance level. `fast` permits bound debt. `full` requires zero open
debt. `prototype` remains non-deployable. Keep one cold, complete, exact-release
gate.

Fail deploy assurance closed when it is mandatory, and bind `evidenceDigest` to
source, artifact, and receipt root.

Extend G127 from file shape to executable reachability, and make the gate-ID
parser consume the canonical registry. Give test impact and phase relevance
real production coordinator consumers.

#### Exact Candidate Surfaces

- `bubbles/scripts/framework-validate.sh`
- `bubbles/scripts/validate-cache.sh`
- `bubbles/scripts/test-impact-plan.sh`
- `bubbles/scripts/phase-relevance-resolve.sh`
- `bubbles/scripts/capability-consumer-freshness.sh`
- `bubbles/scripts/capability-consumer-naming.sh`
- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/release-assurance-gate.sh`
- `bubbles/scripts/deploy-manifest-assurance-lint.sh`
- `bubbles/scripts/assurance-resolve.sh`
- `bubbles/scripts/risk-tier-resolve.sh`
- `bubbles/scripts/gate-id-grep.sh`
- `bubbles/capability-ledger.yaml`
- `bubbles/registry/gates.yaml`
- `bubbles/workflows/modes.yaml`
- New generated closure map: `bubbles/registry/validation-checks.yaml`
- New validation receipt, debt, and batch helpers under `bubbles/scripts/`
- New append-only debt store under `.specify/runtime/validation-debt/`

#### RED Discriminator

Changing `bubbles/registry/gates.yaml` must currently skip selftests that read
it under changed-only selection.

Changing `guard-lib.sh` must currently allow stale cache reuse for consumers
whose basename pair did not change.

A fast run must currently skip heavy checks without a durable debt entry. A
deploy manifest with an arbitrary non-empty digest must currently pass, and the
assurance lint must currently exit 0 with `yq` absent under
`--require-assurance`.

A shipped capability whose consumer only comments its ID must currently satisfy
the naming check.

#### Implementation Responsibilities

PD-07 fixes deploy assurance first. BUG-033 repairs receipt identity. This
scope then builds the generated closure map, the ledger, the settlement
boundaries, the batch executor, and the reachability extension.

Build the registry and shadow the existing schedule. Do not change execution
until the declared plan matches the current full plan. Emit one typed result
per check.

A failed batch settles nothing. A missing ledger write forces immediate
execution. Reachability must prove actual invocation. A scheduler selftest is
not a production capability consumer.

#### GREEN Proof

Changing any declared shared input invalidates every dependent check. Unknown
inputs execute. A cache hit prints `REUSED` with a receipt ID and never prints
`PASS`.

Every deferral creates exactly one open entry. A batch settles each entry only
with a matching receipt and closure. Certification, promotion, and deploy refuse
applicable open debt, and full assurance has zero open debt.

Assurance fails closed with `yq` absent. Removing the real invocation while
retaining path and comment makes G127 fail.

#### Applicable Live Or Telemetry Proof

Product Playwright proof is **not applicable**. The absent behavior trait is
user-visible UI: this scope governs validation scheduling with no product
route.

Real check execution is applicable and required. A scheduler selftest alone is
insufficient. Real integration or E2E commands must execute when settling those
obligation classes. Actual executable consumer invocation is applicable to the
reachability surface.

#### Migration And Rollback

Run registry plans in shadow mode. Compare executed check sets and normalized
results. Keep basename selection as a report-only fallback during migration.

Start debt report-only. Compare selected runs against cold full runs. Permit no
default deferral until miss rate is measured.

Rollback disables registry selection and deferral. It never deletes open debt,
receipts, or scope-state records.

#### Measurable Outcome

Track affected-plan miss rate, stale reuse attempts, unknown closures, check
duration, actual heavy-run frequency, debt age, settlement latency, batch
efficiency, missed failures, and unreachable capabilities.

#### Executable Acceptance Criteria

1. Every scheduled check has one stable ID and a dependency-complete closure.
2. Closures are generated by tracing real references, and a hand edit fails.
3. Shared input changes invalidate all consumers.
4. Unknown dependencies execute and cannot be reused.
5. `PASS`, `REUSED`, and `DEFERRED` remain distinct.
6. Old and new full plans contain the same check set before cutover.
7. Every deliberate deferral writes one append-only entry, and a missing write forces execution.
8. Batch grouping runs compatible heavy work once, with one settling receipt per obligation.
9. Full assurance has zero open debt, fast has only bound debt, prototype never deploys.
10. The fast path executes its basic affected-validation floor before recording heavy debt.
11. Deploy assurance fails closed when mandatory, and digests bind source, artifact, and receipt root.
12. G127 fails when only a file or comment remains, and gate IDs resolve from the canonical registry.
13. Test impact and phase relevance have real executable non-selftest consumers.
14. One cold exact-tree gate passes on this slice's own candidate.

### Deferred Out Of IMP-047

Old SCOPE-2, SCOPE-10, and SCOPE-12 do not proceed in this proposal.

**Old SCOPE-2, lossless improvement and concurrency ledger.** Only one
requirement is retained: generate `improvements/INDEX.md` status from delivery
evidence, folded into S-A. The improvement state model is dropped because
`improvements/IMP-NNN.state.json` would be a second hand-written status copy,
reproducing the exact OW-016 failure it claimed to fix. The repository-wide
writer lease is rejected as a feature request, per old PD-09. The bug intake
migration is rejected as a policy preference that multiplies framework-bug
artifacts sixfold, per old PD-10.

**Old SCOPE-10, learning and honest continuation.** `/bubbles.continue` and the
learning residuals are real but neither is on the path to the operator's
complaint. Deferring them removes one scope and one prompt surface. The
existing decisions stand unchanged: recall remains opt-in and advisory, no
universal session budget is seeded, and the continue prompt stays absent.

**Old SCOPE-12, migration and final exact-tree proof.** Its one irreducible
requirement is a single cold exact-tree gate on the release candidate. That is
already framework policy and it now attaches to each of the five slices as a
terminal acceptance criterion. A twelfth scope whose job is to wait for eleven
others is a dependency, not a deliverable. Its calibration content is dropped
because it was gated on measurement windows that a one-record telemetry store
cannot supply.

<!-- markdownlint-enable MD024 -->

## Supersession Ledger

This ledger preserves every predecessor scope before deleting IMP-042 through
IMP-046. A disposition describes the last grounded state. It does not invent
completion from commit count.

### IMP-042 - Assurance-Preserving Lightweight Execution And Framework Cleanup

| Old scope and title | Last disposition | Landing commits | Retained decision or falsified premise | IMP-047 owner | Residual reference |
| --- | --- | --- | --- | --- | --- |
| SCOPE-1 Leaf Validation Cleanup | delivered | `29d1333` | Duplicate ShellCheck work was removed. Cheap checks moved earlier. | SCOPE-6, SCOPE-12 | none |
| SCOPE-2 Typed Validation Check Registry | partial, superseded | `354a848` | Core label lint is a stopgap. Stable IDs and closure remain required. | SCOPE-6 | IMP-046 SCOPE-1 |
| SCOPE-3 Dependency-Complete Receipts And Affected Execution | superseded | none | Basename ownership is insufficient. Validation receipts stay separate from DoD receipts. | SCOPE-6, SCOPE-7 | IMP-046 SCOPE-1, SCOPE-3, SCOPE-5 |
| SCOPE-4 Batched Heavy Validation | delivered decision, declined premise, measurement-pending | `fcd8449`, `87831b6` | Blanket parallelism was declined after profiling. Debt-aware batching remains valid. | SCOPE-7, SCOPE-12 | historical 2,918 second profile |
| SCOPE-5 Validation Epochs And Final Assurance | delivered decision | `22e6ae0` | Focused loops plus one cold exact-tree final gate remain policy. | SCOPE-7, SCOPE-12 | none |
| SCOPE-6 Executable Workflow Cursor And Phase Coordinator | open | none | Resolver, cursor, and coordinator must land with real consumers. | SCOPE-8 | none |
| SCOPE-7 Atomic Context Compaction | delivered | `29e955b` | Record and stamp now move atomically. | historical-only | none |
| SCOPE-8 MCP And Mode Contract Repair | delivered | `8a4ce85` | Declared tool inputs must render. Unsafe model-invocable state rewrites stay absent. | SCOPE-11 | none |
| SCOPE-9 Proportional Micro-Fix Packet | partial, measurement-pending | `eca887f` | Closed admission landed. Default activation remains forbidden without measurements. | SCOPE-5, SCOPE-12 | OW-015 |
| SCOPE-10 Compact Durable Status Tracking | partial | `4747554`, `e4331ab` | Duplicate status prose was reduced. Scope truth still does not derive aggregate status. | SCOPE-2 | OW-016 |
| SCOPE-11 Explicit Selftest Scheduling And Semantic Reachability | delivered with residual | `0e8baa5`, `539e9d3` | Invocation scheduling and path indexing landed. Executable reachability remains incomplete. | SCOPE-11 | F-047-11 |
| SCOPE-12 Manifest-Driven Downstream Payload | delivered | `b39f899`, `1b82dc5`, `354a848`, `35c90e5`, `d696206` | Payload closure and manifest-governed docs landed. Duplicate manifest class proposal was declined. | SCOPE-11, SCOPE-12 | none |
| SCOPE-13 Canonical Registry Consolidation | delivered | `7e16b0a`, `b5522f5`, `25b0868`, `46260d0`, `3356137`, `4b45ea8`, `24a9757`, `5bd00be` | Gate and specialist authority consolidated. First removal attempt was reverted because reader inventory was incomplete. | SCOPE-11 | none |
| SCOPE-14 Context And Agent-Prose Cleanup | partial | `271497e` | Reference-closure rename landed. Blocking byte budgets were real measurements, not fake prompt cost. Context manifest remains open. | SCOPE-8, SCOPE-11 | none |
| SCOPE-15 Evidence Policy Single Source | partial | `946194b` | Two reference forms remain valid. Inline-only wording still survives in scope workflow. | SCOPE-11 | PD-16 |
| SCOPE-16 Documentation And Generated Projection Cleanup | partial | `833902c`, `e0edcbb` | Phantom modes and projection defects were reduced. MCP, G086, and lifecycle cleanup remain. | SCOPE-11 | none |
| SCOPE-17 Transition Guard Plan And Gate Telemetry | partial, partly superseded | `eca887f` | Source-class telemetry landed. Receipt reuse moved to IMP-046. Check DAG and `BLOCKED_NOT_RUN` remain. | SCOPE-6, SCOPE-8, SCOPE-9 | OW-012 |
| SCOPE-18 Compatibility Removal Train | delivered decision, declined premise | `0b44d48`, `87831b6` | v5 mode names are structural and not removable. Zero-consumer flag removals belong to a major train. | SCOPE-11, SCOPE-12 | historical-only |

### IMP-043 - Close The Learning Loop: Capture, Schedule, Consume

| Old scope and title | Last disposition | Landing commits | Retained decision or falsified premise | IMP-047 owner | Residual reference |
| --- | --- | --- | --- | --- | --- |
| SCOPE-1 Learning disposition in the result envelope | delivered | `d91b045` | Capture stays conditional. The decision is recorded without a lesson quota. | SCOPE-10 | none |
| SCOPE-2 Put the obligation where the run ends | delivered | `e3b9ce2` | Closeout surfaces now expose the learning decision. | SCOPE-10 | none |
| SCOPE-3 Retire inert triggers and make the work lazy | partial | `d91b045` | Compaction at capture landed. Registry paths and enabled toggle remain open. | SCOPE-10 | F-047-13 |
| SCOPE-4 Backfill scaffolds on upgrade and surface the gap | delivered | `aeeed2d` | Non-destructive backfill and doctor advisory landed. | SCOPE-10 | none |
| SCOPE-5 Make recall reachable without changing its default | partial | `aeeed2d` | Sync on lesson add landed. `none` stays default. Config template and setup opt-in remain. | SCOPE-10 | F-047-13 |
| SCOPE-6 Test the loop as a loop | delivered | `e3b9ce2` | End-to-end learning selftest landed with adversarial controls. | SCOPE-10 | none |
| SCOPE-7 Repair the two false documentation claims | delivered | `e3b9ce2` | Compaction docs now describe capture-time behavior. | SCOPE-10 | none |

### IMP-044 - Measurement Truth: One Populated Telemetry Plane

| Old scope and title | Last disposition | Landing commits | Retained decision or falsified premise | IMP-047 owner | Residual reference |
| --- | --- | --- | --- | --- | --- |
| SCOPE-1 Point the readers at the populated store | delivered | `aff3856` | Gate readers use gate hits. Agent readers use execution history. | SCOPE-1, SCOPE-9 | none |
| SCOPE-2 Make the registry describe what is produced | partial | `271497e`, `eed4e53` | Producer-aware blocks landed. Tracking flags, outcome evals, and activity field misuse remain. | SCOPE-9 | F-047-12 |
| SCOPE-3 Preserve unknown configuration keys | delivered | `bcad21c` | Structured merge preserves unknown operator policy. | SCOPE-10, SCOPE-11 | none |
| SCOPE-4 Correct the three published claims | open | none | Retro, status, and operator docs must name real stores and producible values. | SCOPE-9, SCOPE-11 | F-047-12 |
| SCOPE-5 Test the metrics lifecycle | open | none | Lifecycle and no-producer adversaries remain required. | SCOPE-9 | F-047-12 |
| SCOPE-6 Reconcile stale downstream configuration | open | none | Advisory only. Never auto-remove project-owned keys. | SCOPE-9, SCOPE-11 | F-047-12 |

### IMP-045 - Continuation Posture And Unattended Consumption

| Old scope and title | Last disposition | Landing commits | Retained decision or falsified premise | IMP-047 owner | Residual reference |
| --- | --- | --- | --- | --- | --- |
| SCOPE-1 Consume unattended in the four runner agents | delivered | `38b875f` | Interaction changes do not waive the autonomy floor. | SCOPE-10 | none |
| SCOPE-2 Extend G135 so an unconsumed posture cannot ship | delivered | `38b875f` | Every posture must appear in all authorized runners. | SCOPE-10 | none |
| SCOPE-3 One authority for the prompt-shim count | delivered | `32a1825`, `8bd1325` | Prompt and agent counts are independent and generated counts are checked. | SCOPE-11 | none |
| SCOPE-4 Add the `/bubbles.continue` prompt shim | open | none | Entry point must wait for completion and fidelity mechanics. | SCOPE-10 | F-047-14 |
| SCOPE-5 Publish the posture and entrypoint | open | none | Operator docs must state bounds and non-waivable controls. | SCOPE-10, SCOPE-11 | F-047-14 |
| SCOPE-6 Index delivered autonomy-posture work | open | none | Audit history needs one unambiguous identity and gap mapping. | SCOPE-11 | F-047-14 |
| SCOPE-7 Correct G086 description | open | none | The guard scans agent files, not prompt files. | SCOPE-8, SCOPE-11 | F-047-14 |
| SCOPE-8 Durable and no-shortcut decision policy | delivered | `242d4cb`, `4dccefe` | Durable choices outrank easy reversibility. Security remains blocked, never auto-resolved. | SCOPE-10 | none |
| SCOPE-9 Bind a completion predicate to deliver 100 percent | open | none | Iteration caps never imply success. Completion binds all outcome authorities. | SCOPE-8, SCOPE-10 | F-047-14 |
| SCOPE-10 Require per-iteration plan-fidelity reconciliation | open | none | Every convergence iteration must record plan fidelity. | SCOPE-8, SCOPE-10 | F-047-14 |

### IMP-046 - Validation Debt Ledger And Settlement Boundaries

| Old scope and title | Last disposition | Landing commits | Retained decision or falsified premise | IMP-047 owner | Residual reference |
| --- | --- | --- | --- | --- | --- |
| SCOPE-1 Validation receipts keyed by a declared input closure | open | none | Basename ownership must be replaced before reuse expands. | SCOPE-6 | PD-02 |
| SCOPE-2 Append-only validation debt ledger | open | none | Every deliberate deferral needs one settleable obligation. | SCOPE-7 | none |
| SCOPE-3 Distinct status vocabulary | open | none | `PASS`, `REUSED`, and `DEFERRED` are different claims. | SCOPE-6, SCOPE-7 | none |
| SCOPE-4 Settlement boundaries where open debt blocks | open | none | Certification, promotion, and deploy must enforce applicable debt. | SCOPE-7 | PD-07 |
| SCOPE-5 Batch executor | open | none | Group heavy work while preserving one receipt per obligation. | SCOPE-7 | none |
| SCOPE-6 Assurance binding | open | none | Full requires zero debt. Fast permits bound debt. Prototype never deploys. | SCOPE-7 | PD-07 |
| SCOPE-7 Express the fast lane through existing modes | open, measurement-pending | none | Keep opt-in admission and no override. Measure before any default. | SCOPE-7, SCOPE-12 | OW-015, OW-014 |

## Open-Work Re-Anchoring

The four existing rows remain single records. This proposal changes only their
owning references and next actions.

| Open work | IMP-047 anchor | Preserved decision |
| --- | --- | --- |
| OW-012 | S-A | Retire only gates with measured zero utility after exercise analysis. The 60-day window cannot begin until S-A makes gate telemetry real; today the store holds one run. |
| OW-014 | S-A | Re-measure the six IMP-036 outcomes. Measure completion-rate guardrail first. |
| OW-015 | S-D | **Decision changed by this revision.** Micro-fix becomes the default for bugs passing all 8 admission questions, with the 4 preserved obligations and `overrideFlag: none` unchanged. Authoring time and defect escape are recorded from activation forward, because no producer for a pre-activation measurement exists. |
| OW-016 | S-A | Derive INDEX status from acceptance-criteria receipts and landing commits. Do not infer APPLIED from commit count, and do not create a second hand-written status file. |

## Sequencing

There are no waves. Waves were how twelve scopes pretended to be shippable.
Each slice is independent and ends with one cold exact-tree gate on its own
candidate.

### Ship S-A First And Alone

S-A ships before anything else, and nothing ships beside it.

It is small. It is the root cause of the operator's complaint. Until it lands,
**every retirement argument is unfalsifiable, including this proposal's own.**
The 86 never-observed gates cannot be retired. The 25 `retireWhen` clauses
cannot fire. No claim that a gate is useful or useless can be checked. A
framework that cannot measure its own gates cannot reduce them, which is
precisely how it reached 118.

PD-11 is S-A's only prerequisite, because without a resolvable transition audit
profile the mode cannot run at all.

### Then S-B, S-D, S-C, S-E As Independent Slices

This order is deliberate.

**S-B** next, because the scenario contract and the generated template are what
every later slice writes against. It also removes the most visible daily
friction: a template that cannot pass its own lint.

**S-D** before S-C, because proportionate proof and micro-fix activation are
the largest immediate burden reduction available after S-A, and neither depends
on the receipt engine.

**S-C** next, because the receipt engine is the largest single build and it
should follow the contract it binds.

**S-E** last, because closure and debt are the least urgent relative to the
complaint and the most disruptive to validation scheduling.

### No Scope Waits On An Unproducible Window

**No scope may wait on a 60-day window that a one-record store cannot supply.**
That pattern is what turned the micro-fix packet into a permanent veto dressed
as rigour. Where a measurement is genuinely required before a default flips,
the measurement is collected by the shipped slice, going forward, not demanded
before it.

Each slice carries its own shadow, dual-read, backfill, and rollback path.
Append-only history is never rewritten.

## Risks And Mitigations

| Risk | Mitigation |
| --- | --- |
| R1 Incomplete input closure serves stale GREEN | Unknown inputs force execution and forbid reuse. |
| R2 Debt becomes a queue nobody drains | Applicable certification, promotion, and deploy boundaries block open debt. |
| R3 Batch execution hides one failed obligation | Each obligation requires its own settling receipt. |
| R4 Scenario migration breaks certified history | Writers cut over once. Readers dual-read for a declared window. |
| R5 Trait inference under-tests behavior | Unknown applicability is review-required and cannot earn an exemption. |
| R6 Universal E2E creates fake shells | Universal regression remains. Physical test category derives from traits. |
| R7 Human acceptance is fabricated by automation | Automation and human authority use separate fields and writers. |
| R8 Telemetry replaces behavior proof | `OBSERVED` requires prior applicable GREEN. It cannot create GREEN. |
| R9 Coordinator replays expensive phases | Occurrence-aware cursor and accepted-result digest prevent replay. |
| R10 Scope truth drifts from INDEX | Generate aggregate status from machine-readable scope state. |
| R11 Scenario states become hand-written bookkeeping | Every state is derived from receipts. A hand-written state is refused. This is the single largest tax this proposal could accidentally create. |
| R12 Canonical-source proof becomes host-specific | Bind to portable release or install provenance, not a machine path. |
| R13 Metrics reward gate volume | Progress uses scenario states. Gate utility uses prevented defects and escape data. |
| R14 A generated registry is quietly hand-edited and becomes a new hand-maintained surface | A hand edit to any `GENERATED:` block or generated registry fails. Generated status is checked, not asserted. |
| R15 History disappears when proposals are deleted | The 48-row supersession ledger in this proposal is the only surviving record of IMP-042 through IMP-046. It is preserved verbatim and the old-to-new scope mapping keeps its references resolvable. |
| R16 The Retirement Rule is honored in name and evaded in practice | Counts come from `generate-framework-stats.sh` and are checked by one lint. A new obligation that names no retirement does not merge. |
| R17 This revision is itself the disease it diagnoses | It removes 9 persistent surfaces, 7 scopes, and 12 prerequisite packets while adding 4 surfaces. If a future revision inverts that ratio, reject it on the same grounds this one was forced to accept. |

## Measurement Plan

Measure before changing defaults. The one exception is a measurement that only
the change itself can produce.

That exception is not a loophole. It is the repair for the failure mode that
froze the micro-fix packet: a precondition no producer can satisfy is a
permanent veto, not a standard.

| Metric | Baseline requirement | Activation use |
| --- | --- | --- |
| Gates observed, specs represented, days represented | Opening values 32, 1, and 1 | Establish whether gate telemetry is real at all. Nothing about gates is decidable before this moves. |
| Time to first value | First scenario reaches `GREEN_TARGETED` | Detect planning or gate delay. |
| RED-to-GREEN lead time | Per scenario and trait | Compare outcome delivery speed. |
| Live-proof rate | Applicable scenarios only | Detect missing real-system proof. |
| Selected-versus-full miss rate | Cold full comparison | Block unsafe selector activation. |
| Defect escape | By assurance and packet type | Bound fast and micro routes. Recorded from activation forward, never demanded before it. |
| Validation debt age | Open to settled | Detect undrained debt. |
| Batch efficiency | Heavy executions avoided and obligations settled | Test batching value. |
| Heavy-run frequency | Per change and per batch | Detect unchanged per-change cost. |
| Gate utility | Prevented invalid transitions and later escapes | Support gate retirement decisions. Currently unmeasurable. |
| Rollback and rework | Reopens, reversions, and fix chains | Detect framework-generated slop. |
| Authoring time | Compact and full packets | Recorded from micro-fix activation forward. |
| The four Retirement Rule counts | Opening values in `Opening Baseline` | Refuse any change that raises a count without retiring an equivalent unit. |
| Prompt cost | Usage adapter only | Report `unmeasured` when no adapter exists. |

## Owner Decisions Requested

1. Approve or reject the outcome-state vocabulary.
2. Approve the trait matrix as test-category authority.
3. **Approve the Retirement Rule as permanent framework policy**, together with its orphaned-scaffolding corollary.
4. **Approve the Delete List.** This includes the refusal to delete the 86 never-observed gates on current evidence.
5. **Approve shipping S-A first and alone.**
6. **Approve reducing the prerequisite ledger from 16 packets to 4 plus 2 existing.** Ten are reclassified or rejected.
7. **Approve activating the micro-fix packet as the default.** Defect escape is recorded going forward.
8. **Approve that all eight scenario states are derived from receipts and never declared.**
9. Approve validation debt and batch settlement.
10. Approve one cold exact-tree gate per slice on its own candidate.
11. Approve separate automation and human acceptance authorities.
12. Approve receipt-bound trace and SLO evidence.
13. Preserve recall as opt-in and advisory.
14. Reject a hidden universal session budget.
15. Keep `/bubbles.continue` absent, now deferred out of this proposal entirely.
16. **Confirm the rejection of old PD-09 and PD-10 as category errors rather than defects.**

## Files To Touch On Approval

The exact candidate surfaces appear within each scope. This proposal authorizes
none of those edits by itself.

Implementation routes through the named owners. Framework source, registries,
agents, workflows, scripts, and docs remain unchanged until approval and
properly planned delivery.

## Assumptions And Unresolved Decisions

### Assumption A1

> **Assumption**
> **Assumed:** The 23 mandatory template sections with zero script readers are read by humans often enough to keep their text.
> **Why unverified:** No producer measures human readership, and none is proposed. Downgrading to optional is defensible without it; deleting the text is not.
> **Blast radius:** If the sections are in fact unread, S-B under-removes and the text stays as dead weight.
> **Would confirm or refute:** An owner judgment, or an observed period during which optional sections are consistently omitted without complaint.

### Assumption A2

> **Assumption**
> **Assumed:** One release of dual-read scenario compatibility is sufficient.
> **Why unverified:** The downstream legacy manifest census was not rerun here.
> **Blast radius:** S-B migration duration and removal timing may change.
> **Would confirm or refute:** A fresh cross-repository manifest inventory.

### Assumption A3

> **Assumption**
> **Assumed:** Debt settlement thresholds can be uniform across downstream repositories.
> **Why unverified:** No downstream timing or defect-escape baseline was collected here.
> **Blast radius:** S-E default policy may need project-specific configuration.
> **Would confirm or refute:** Shadow-mode measurements from representative repositories.

### Assumption A4

> **Assumption**
> **Assumed:** Activating the micro-fix packet by default does not raise defect escape, given the 8 closed admission questions, the 4 preserved obligations, and `overrideFlag: none`.
> **Why unverified:** No defect-escape producer exists, which is exactly why the packet has been frozen. This revision accepts the risk deliberately rather than accepting a permanent veto.
> **Blast radius:** If escape rises, S-D rolls back to opt-in without deleting any packet already authored under the compact route.
> **Would confirm or refute:** Defect-escape measurement recorded from activation forward, per S-D acceptance criterion 11.

No assumption closes a prerequisite defect, scope, or acceptance criterion.
