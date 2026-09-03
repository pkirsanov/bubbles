# Execution Reports

Single-file mode: top-level `report.md`.

Links: [uservalidation.md](uservalidation.md)

## Scope: bug-discovery - 2026-08-23 17:36

### Summary

- What changed (files/surfaces): no repository surface was changed. This phase
  authored the BUG-037 packet only: `bug.md`, `spec.md`, `design.md`,
  `scopes.md`, `report.md`, `uservalidation.md`, `scenario-manifest.json`,
  `state.json`.
- Scenarios validated: none. Scenario contracts SCN-B037-001 through
  SCN-B037-015 are declared in
  [scenario-manifest.json](scenario-manifest.json) and are **unimplemented**.
- Defect reproduced: yes. See [Bug Reproduction](#bug-reproduction--before-fix).

### Code Diff Evidence

**Executed:** NO
**Claim Source:** not-run

No implementation-bearing work was performed in this phase, so no git-backed
code diff evidence is owed. The only files created are packet artifacts under
`bugs/BUG-037-uservalidation-opt-out-acceptance/`. A completion claim requiring
non-artifact source paths is NOT made anywhere in this packet.

### Completion Statement

**Delivered outcome:** the BUG-037 bug packet is authored and the defect is
mechanically reproduced against the shipped shared reader.

**NOT delivered:** the fix. No surface named in
[design.md](design.md) § 2 was modified. `state.json` is `in_progress`,
`certification.status` is `in_progress`, and every DoD item in
[scopes.md](scopes.md) is unchecked.

**Evidence that proves the reproduction:** the executed command block below,
exit code 1, emitted from `bubbles/scripts/acceptance-authority-lib.sh` — the
same reader `bubbles/scripts/guards/tail-delegated-gates.sh` Check 43 sources.

---

## Bug Reproduction — Before Fix

### Repository binding

**Executed:** YES
**Command:** `bash bubbles/scripts/repository-binding.sh preflight --session-id vscode-b0dbac204a2903e3dbf3e4d765d8be38 --session-control-file /Users/pkirsanov/.local/state/bubbles/repository-binding/vscode-b0dbac204a2903e3dbf3e4d765d8be38/repository-binding.json --expected-control-revision 1 --request-class FRAMEWORK --repository-root /Users/pkirsanov/Projects/bubbles --workspace-root ... (8 roots)`
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
REPOSITORY PREFLIGHT CONFIRMED repository=bubbles root=/Users/pkirsanov/Projects/bubbles source=explicit-repositoryRoot affinity=confirmed
PREFLIGHT_COMMITTED decision=rb:vscode-b0dbac204a2903e3dbf3e4d765d8be38:2 revision=2 repository=bubbles root=/Users/pkirsanov/Projects/bubbles
{"repositoryRoot":"/Users/pkirsanov/Projects/bubbles","repositoryAlias":"bubbles","repositoryResolution":{"sessionId":"vscode-b0dbac204a2903e3dbf3e4d765d8be38","decisionId":"rb:vscode-b0dbac204a2903e3dbf3e4d765d8be38:2","controlRevision":2,"controlPathDigest":"sha256:9d1976269254326599093965d798b0524694607b0ec40a8c3fa4d0826466fe88","authority":"explicit-repository-root","transition":"confirmed","scopeKind":"command","scopeId":null,"targetKind":"repository-root","pathVisibility":"local","actionable":true}}
PREFLIGHT_EXIT=0
```

### Fixture

Written to `/tmp/bug037-repro/uservalidation.md`, materialized from the CURRENT
template at `agents/bubbles_shared/feature-templates.md` lines 282-311.
Placeholder slots were replaced with real behavior text so no finding can be
attributed to an unfilled template stub. No `## Human Acceptance Record` section
is present, which is the shape an authored-but-not-signed-off artifact has.

```markdown
# User Validation Checklist

## Automation Readiness

Written by automation. Records that the delivered behavior was verified far enough to be worth a human's time. Grants no acceptance.

- [x] Search returns results for a plain keyword query
- [x] Empty query renders the guidance state instead of an error

## Checklist

Human acceptance. Ships UNCHECKED. A human checks an item after exercising that behavior.

- [ ] Search returns results for a plain keyword query
- [ ] Empty query renders the guidance state instead of an error

An item still unchecked at a terminal transition is either unaccepted work or a user-reported regression.

## Goal

- Goal: find a record by keyword without learning a query syntax
- Success signal: the record appears in the first page of results
```

### Failing state

**Executed:** YES
**Command:**
```
bash -c 'source bubbles/scripts/acceptance-authority-lib.sh; \
  echo "--- shape verdict (planning-time) ---"; \
  bubbles_acceptance_shape_verdict /tmp/bug037-repro/uservalidation.md; echo "SHAPE_EXIT=$?"; \
  echo "--- terminal verdict (done transition, Gate G136 / Check 43) ---"; \
  bubbles_acceptance_terminal_verdict /tmp/bug037-repro/uservalidation.md; echo "TERMINAL_EXIT=$?"'
```
**Exit Code:** 0 for the wrapper; the terminal verdict itself returned **1**
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
--- shape verdict (planning-time) ---
SHAPE_EXIT=0
--- terminal verdict (done transition, Gate G136 / Check 43) ---
PD12-UNCHECKED-ITEM: - [ ] Search returns results for a plain keyword query
PD12-UNCHECKED-ITEM: - [ ] Empty query renders the guidance state instead of an error
PD12-NO-RECORD: no authored "## Human Acceptance Record"; checked boxes alone are not human acceptance, because a template used to ship them checked
TERMINAL_EXIT=1
```

**Reading.** `SHAPE_EXIT=0` proves the fixture is structurally valid — the
failure is not a malformed artifact. `TERMINAL_EXIT=1` with three findings is
the defect: a user who reviewed the delivered behavior and objected to nothing
cannot reach terminal. Under the owner's standing requirement, no-objection is
acceptance.

### Provenance of the historical claims

**Executed:** YES
**Command:** `git log -1 --format='%H %ad %s' --date=short 9e41da4`
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
9e41da42be80ce013390ebbb0fb1077d94e9fade 2026-08-17 IMP-047 S-D: proportionate proof, micro-fix activated, PD-12 repair
```

**Executed:** YES
**Command:** `git show 9e41da4^:agents/bubbles_shared/feature-templates.md | awk '/^## uservalidation.md Template/{f=1} f&&/^## scenario-manifest/{exit} f'`
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
## uservalidation.md Template

# User Validation Checklist

## Checklist

- [x] Baseline checklist initialized for this feature
- [x] [Scenario or flow validated]
- [x] [Another validated flow]

Unchecked items indicate a user-reported regression.
...
Rules:

- Checklist items MUST use markdown checkbox syntax.
- Entries created by agents after validation/audit MUST default to checked `[x]`.
- Empty checklist or non-checkbox bullets are template violations.
```

**Executed:** YES
**Command:** `git show 9e41da4^:bubbles/scripts/artifact-lint.sh` (uservalidation block)
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
557:     baseline_checked_lines="$({ echo "$checklist_section_content" | grep -E '^- \[x\] '; } || true)"
558:     if [[ -z "$baseline_checked_lines" ]]; then
559:       fail "uservalidation checklist has no checked-by-default [x] entry"
560:     else
561:       pass "uservalidation checklist has checked-by-default entries"
562:     fi
```

This is the requirement that four surfaces still describe and that
`artifact-lint.sh` at HEAD no longer carries.

### The defect reproduces end to end through the real guard

The library-level reproduction above is confirmed at the enforcement layer. This
packet's own `uservalidation.md` — authored from the CURRENT template, with the
fix deliberately NOT pre-applied — is refused by the real Check 43.

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
--- Check 43: Human Acceptance Terminal Gate (Gate G136) ---
🔴 BLOCK: uservalidation.md does not establish human acceptance; a terminal transition claims it for every behavior (Gate G136)
ℹ️  INFO:   PD12-UNCHECKED-ITEM: - [ ] A user who reviews the delivered behavior and unchecks nothing reaches a terminal status without any further act
ℹ️  INFO:   PD12-UNCHECKED-ITEM: - [ ] An item the user unchecks blocks the terminal transition and is named in the refusal
ℹ️  INFO:   PD12-UNCHECKED-ITEM: - [ ] The BUG-029 shape is still refused: one checked item plus five unchecked never reaches terminal
ℹ️  INFO:   PD12-UNCHECKED-ITEM: - [ ] No agent, guard, or lint ever re-checks an item the user unchecked
ℹ️  INFO:   PD12-UNCHECKED-ITEM: - [ ] The optional acceptance record is still validated when a human chooses to author one
ℹ️  INFO:   PD12-UNCHECKED-ITEM: - [ ] Every governance surface describing Gate G136 matches what the guard and lint actually do
ℹ️  INFO:   PD12-NO-RECORD: no authored "## Human Acceptance Record"; checked boxes alone are not human acceptance, because a template used to ship them checked
ℹ️  INFO: The guard does not check these for you — checking a box on the author's behalf would fabricate the acceptance this gate requires
```

```
BEGIN TRANSITION_GUARD_RESULT_V1
workflowMode: bugfix-fastlane
targetStatus: done
failedGateIds: [G055,G057,G060,G041,G022,G053,G068,G136]
failedChecks: [Check-4-completion,Check-5-structure]
blockingCode: DELIVERY_COMPLETION_FAILED
failureCount: 32
exitStatus: 1
verdict: FAIL
END TRANSITION_GUARD_RESULT_V1
```

**Reading.** The `FAIL` verdict is the CORRECT and intended state for this
packet: no fix exists, every scope is `not_started`, and the guard evaluates
against `targetStatus: done`. The relevant fact is `G136` in `failedGateIds`
with its six `PD12-UNCHECKED-ITEM` findings plus `PD12-NO-RECORD`. That is the
defect at the enforcement layer, not merely at the library layer.

### Artifact lint on this packet

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Exit Code:** 0
**Phase Agent:** bubbles.bug
**Claim Source:** executed

```
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
```

Note the composition this proves: lint PASSES a packet whose acceptance
checklist is entirely unchecked and which carries no acceptance record. Lint at
HEAD carries no checked requirement of any kind — which is exactly what four
governance surfaces still claim it does.

### Stale-surface confirmation

**Executed:** YES
**Command:** `grep -rn "at least ONE checked|checked-by-default template is legitimate|carry at least one checked" .`
**Phase Agent:** bubbles.bug
**Claim Source:** executed

Matches at HEAD, excluding the historical BUGS.md narrative and the
`acceptance-authority.yaml` header that describes the change in past tense:

```
agents/bubbles_shared/quality-gates.md:272
agents/bubbles_shared/test-core.md:304
agents/bubbles_shared/test-core.md:309
bubbles/registry/gates.yaml:1081
skills/bubbles-quality-gates-catalog/SKILL.md:57
CHANGELOG.md:1320
```

`skills/bubbles-quality-gates-catalog/SKILL.md:57` and `CHANGELOG.md:1320` were
NOT in the originally reported stale set. Both carry the same false assertion.

---

### Test Evidence

**Executed:** NO
**Claim Source:** not-run

No fix exists, so no red-stage/green-stage pair for any scope exists.
`policySnapshot.tdd.mode` is `scenario-first`; the red stage for Scope 1 is the
reproduction block above, and the green stage is owed by the `implement` phase.

Required test surfaces, all currently unimplemented for this bug:

| Surface | State |
|---|---|
| `bubbles/scripts/acceptance-authority-selftest.sh` | not extended |
| `bubbles/scripts/state-transition-guard-selftest.sh` | not extended |
| `tests/regression/test_35_human_acceptance_terminal.sh` | not updated |
| `bubbles/scripts/artifact-lint.sh` fixture cases | not authored |

### Validation Evidence

**Executed:** NO
**Command:** not applicable
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validation is not owed at the `bug` phase. `certification.status` is
`in_progress` and no certification claim is made.

### Audit Evidence

**Executed:** NO
**Command:** not applicable
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

### Chaos Evidence

**Executed:** NO
**Command:** not applicable
**Phase Agent:** bubbles.chaos
**Claim Source:** not-run

---

## Uncertainty Declaration

1. **Root cause is preliminary.** [design.md](design.md) § 1 records a reading of
   why `9e41da4` landed as it did. It is inference from the commit's own
   rationale text, not from a conversation with its author. `bubbles.design`
   owns confirming or refuting it.
2. **The affected-surface inventory is search-derived, not exhaustive.**
   [design.md](design.md) § 2.5 lists ~20 files that mention `uservalidation`
   and have not been individually read for an acceptance-model claim. Each is
   listed as unruled-out, not as affected.
3. **D-1 through D-5 are open.** Five design decisions in
   [design.md](design.md) § 3 carry recommendations, not rulings. Implementation
   cannot be dispatched until they are closed.
4. **The downstream blast radius is not measured.** Every consuming repository
   holds `uservalidation.md` artifacts authored under the opt-in model. Their
   count and their post-inversion state are unknown and were not surveyed.

> Items 1, 2 and 3 above were closed by the `design` phase and are retained as
> the record of what was open at the `bug` phase. Item 4 is still open and is
> restated in the `implement` phase Uncertainty Declaration below.

---

## Scope: implement — Scopes 1-4 - 2026-08-23

### Summary

- **What changed (files/surfaces):** the acceptance contract
  (`bubbles/registry/acceptance-authority.yaml`), its shared reader
  (`bubbles/scripts/acceptance-authority-lib.sh`), its selftest, the shipped
  template (`agents/bubbles_shared/feature-templates.md`), the lint comment
  block in `bubbles/scripts/artifact-lint.sh`, `bubbles/registry/bug-packet.yaml`,
  Check 43 in `bubbles/scripts/guards/tail-delegated-gates.sh`, the guard
  selftest, `tests/regression/test_35_human_acceptance_terminal.sh`,
  `bubbles/registry/gates.yaml` (`G136` and `G057`),
  `agents/bubbles_shared/quality-gates.md`,
  `agents/bubbles_shared/test-core.md`,
  `skills/bubbles-quality-gates-catalog/SKILL.md`, `CHANGELOG.md`, `BUGS.md`,
  `improvements/INDEX.md`, and the three generated artifacts.
- **Scenarios validated:** SCN-B037-001 through SCN-B037-015. Every
  `linkedTests[].testId` in
  [scenario-manifest.json](scenario-manifest.json) that read `unimplemented`
  now names the real case that implements it.
- **Phase:** implement. Certification is NOT claimed here; `certification.*`
  is untouched by this agent.

### Code Diff Evidence

**Executed:** YES
**Command:** `git status --porcelain` and `git --no-pager diff --stat -- <BUG-037 allowedPaths>`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
 BUGS.md                                            |  105 +-
 CHANGELOG.md                                       |   92 +-
 agents/bubbles_shared/feature-templates.md         |   23 +-
 agents/bubbles_shared/quality-gates.md             |    4 +-
 agents/bubbles_shared/test-core.md                 |   51 +-
 bubbles/registry/acceptance-authority.yaml         |  112 +-
 bubbles/registry/bug-packet.yaml                   |    8 +-
 bubbles/registry/gates.yaml                        |    4 +-
 bubbles/registry/validation-checks.yaml            | 1207 +++++++++++++++++++-
 bubbles/release-manifest.json                      |   38 +-
 bubbles/scripts/acceptance-authority-lib.sh        |   89 +-
 bubbles/scripts/acceptance-authority-selftest.sh   |  852 +++++++++++---
 bubbles/scripts/artifact-lint.sh                   |   35 +-
 bubbles/scripts/guards/tail-delegated-gates.sh     |   57 +-
 bubbles/scripts/state-transition-guard-selftest.sh |  483 +++++++-
 docs/generated/gate-coverage-map.md                |    2 +-
 improvements/INDEX.md                              |    2 +-
 skills/bubbles-quality-gates-catalog/SKILL.md      |    2 +-
 .../test_35_human_acceptance_terminal.sh           |   71 +-
 19 files changed, 2864 insertions(+), 373 deletions(-)
```

Every path in that list is inside `state.json` `workBoundary.allowedPaths`.
The working tree also carries unrelated in-flight BUG-033 work
(`bugs/BUG-033-*`, `bubbles/scripts/receipt-identity-selftest.sh`,
`bubbles/scripts/state-transition-guard.sh`); none of it was touched, staged,
reverted or discarded by this phase.

### RED Scope 1

**Executed:** YES — at the `bug` phase, in this packet, against the shipped
reader Gate G136 itself sources.
**Claim Source:** executed
**Phase Agent:** bubbles.bug

The failing reproduction and its real exit code are recorded above under
[Bug Reproduction — Before Fix](#bug-reproduction--before-fix): the terminal
verdict returned **1** on a fixture whose only defect was that a satisfied user
had objected to nothing, emitting two `PD12-UNCHECKED-ITEM` findings and
`PD12-NO-RECORD`. The same failing state was confirmed end to end through the
real guard: `state-transition-guard.sh` reported `G136` in `failedGateIds` with
six `PD12-UNCHECKED-ITEM` findings plus `PD12-NO-RECORD`, `verdict: FAIL`.

That RED is not re-executable at this commit by construction — the fix deletes
the code path that produced `PD12-NO-RECORD`. Its re-executable substitute is
the S1-T8 adversarial case, which restores `requiredAtTerminal: true` in a
fixture registry and watches the refusal come back. S1-T8's pass is recorded
under [Bounds Scope 1](#bounds-scope-1).

### Scope 1

**Executed:** YES
**Command:** `grep -n -E 'shippedState|requiredAtTerminal|^failureCodes|^  - id: PD12' bubbles/registry/acceptance-authority.yaml`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
22:# state now comes from THIS CONTRACT — `acceptance-checklist.shippedState`, a
56:# FAILURE-CODE PREFIX (BUG-037 D-5). The `PD12-*` prefix is HISTORICAL and is
63:# accurate. `PD12-NO-RECORD` is RETIRED: it demanded the separately authored
65:# `failureCodes` and unreachable while `acceptance-record.requiredAtTerminal` is
93:    shippedState: checked
108:    requiredAtTerminal: false
150:# a reader can grep the code rather than the prose. `PD12-NO-RECORD` was retired
155:failureCodes:
156:  - id: PD12-RECORD-INCOMPLETE
158:  - id: PD12-METHOD-UNKNOWN
160:  - id: PD12-METHOD-FIELD-MISSING
162:  - id: PD12-AUTOMATION-ACCEPTOR
164:  - id: PD12-UNCHECKED-ITEM
166:  - id: PD12-READINESS-NOT-CHECKBOX
```

**Reading.** `shippedState: checked` and `requiredAtTerminal: false` are the
inversion. Six failure codes remain, `PD12-NO-RECORD` is absent from the set,
and lines 56-65 and 150 carry the D-5 retirement note so a reader who greps the
retired code in an archived evidence block finds out what happened to it. The
file-header rationale was rewritten in the same change — the diff is 112 lines
against a registry whose data change is two keys.

`acceptance-authority-lib.sh` no longer emits `PD12-NO-RECORD`
unconditionally. The emission is now gated on
`bubbles_acceptance_record_required_at_terminal`, which READS
`acceptance-record.requiredAtTerminal` through the same
`bubbles_acceptance_section_field` accessor every other registry value uses.
That is what makes S1-T8 possible: the value is data, not a hardcoded branch.
`bubbles_acceptance_shape_verdict` was not changed, which is why AC-8 holds
without a code edit — proven by S1-T4 rather than by reading.

**No conditional early-return that silently passes.** The selftest's own
S1-T10/S1-T10b/S1-T10c cases close the failure-code set in both directions:
every declared code must be emittable and every emitted code must be declared.
A test that returned early would leave a declared code unobserved and fail
S1-T10.

### GREEN Scope 1

**Executed:** YES
**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-037 S1/S2/S4 acceptance-authority-selftest" -- bash bubbles/scripts/acceptance-authority-selftest.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
# BUG-037 S1/S2/S4 acceptance-authority-selftest
$ bash bubbles/scripts/acceptance-authority-selftest.sh
exit: 0
lines: 44
sha256: efb20e66fd611d04c864fe82bb11d101c17ef7e1b064d4b806c60692a62898a6
--- first 20 ---
acceptance-authority-selftest: /Users/pkirsanov/Projects/bubbles/bubbles/scripts/../registry/acceptance-authority.yaml
  ok   S1-T1 SCN-B037-001: a fully checked checklist with no record reaches terminal
  ok   S1-T1b SCN-B037-001: no PD12-NO-RECORD finding is emitted
  ok   S1-T1c the shipped (checked) shape also passes shape lint
  ok   S1-T2 SCN-B037-002 ADVERSARIAL: one unchecked item refuses terminal and is NAMED
  ok   S1-T2b exactly the rejected item is reported, not the five accepted ones
  ok   S1-T3 SCN-B037-003 ADVERSARIAL: the BUG-029 shape is refused and all five unchecked items are named
  ok   S1-T4 SCN-B037-004 ADVERSARIAL: an agent id as acceptedBy still refuses the shape verdict
  ok   S1-T5 a present record missing acceptedAt is PD12-RECORD-INCOMPLETE
  ok   S1-T6 external-record acceptance without its record pointer is refused
  ok   S1-T6b external-record acceptance WITH its record pointer is accepted
  ok   S1-T6c an acceptance method outside the closed vocabulary is refused
  ok   S1-T7 SCN-B037-005 ADVERSARIAL: a fully checked readiness block discharges no acceptance obligation
  ok   S1-T7b a non-checkbox automation-readiness bullet is refused
  ok   S1-T8 ADVERSARIAL: flipping requiredAtTerminal back in a fixture registry restores the refusal (the value is READ, not hardcoded)
  ok   S1-T8b renaming the heading in the registry changes the reader (single source, not a copy)
  ok   S1-T9 an unchecked bullet outside the acceptance checklist is ignored
  ok   S1-T10 ADVERSARIAL: every declared failure code is emittable and every emitted code is declared
  ok   S1-T10b D-5: PD12-NO-RECORD appears in neither the declared nor the observed code set
  ok   S1-T10c the only undeclared code literal in the library is the retired PD12-NO-RECORD, and it is registry-gated
--- omitted 4 line(s); sha256 above covers the full output ---
--- last 20 ---
  ok   S2-T3b lint still runs the acceptance-authority shape check
  ok   S2-T4 ADVERSARIAL: lint still fails on a non-checkbox checklist bullet
  ok   S2-T5 ADVERSARIAL: lint still fails on a checklist with zero checkbox entries
  ok   S2-T6 no agents/** surface asserts that acceptance items ship unchecked
  ok   S2-T7 bug-packet.yaml's uservalidation purpose agrees with acceptance-authority.yaml (shipped checked)
  ok   S2-T8a ADVERSARIAL: the auto-check detector fires on a fixture whose '[ ]' became '[x]'
  ok   S2-T8 D-1 bound: no uservalidation.md outside bugs/BUG-037-* had an item checked by this change (4 scanned against HEAD)
  ok   S2-T8b D-1: no acceptance/uservalidation migration script was authored
  ok   S4-T1 SCN-B037-013: no governance surface asserts the checked-entry lint rule artifact-lint.sh does not carry
  ok   S4-T1b no governance surface carries the stale 'checked-by-default template is legitimate' framing
  ok   S4-T2 GC-2: G136's description names only refusal codes acceptance-authority.yaml declares
  ok   S4-T2b G136's description states the opt-out terminal condition, not the superseded record demand
  ok   S4-T8 D-3 bound: G057's description declares the advisory status of the rules its enforcer does not verify
  ok   S3-T9 Check 43's pass/fail text no longer asserts a required human acceptance record
  ok   S4-T4 SCN-B037-014: CHANGELOG.md carries the BUG-037 entry, the PD-12 entry and the D-1 upgrade note
  ok   S4-T4b the BUG-029 changelog entry no longer states the superseded lint contract as current
  ok   S4-T9 D-4 bound: no path under bugs/BUG-032- was modified

acceptance-authority-selftest: 40/40 checks passed
acceptance-authority-selftest: OK
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify efb20e66fd611d04c864fe82bb11d101c17ef7e1b064d4b806c60692a62898a6 -- bash bubbles/scripts/acceptance-authority-selftest.sh -->

**Reading.** 40 of 40, zero skipped, exit 0. SCN-B037-001 is S1-T1 plus S1-T1b:
the fully checked record-less fixture reaches terminal AND no `PD12-NO-RECORD`
is emitted. The four omitted lines are S1-T10c through S2-T3, covered by the
sha256 and individually named in the `--- last 20 ---` block or the case index.

### Bounds Scope 1

**Executed:** YES — the adversarial cases are inside the same 40/40 run above.
**Claim Source:** executed
**Phase Agent:** bubbles.implement

| Bound | Case | Result |
|---|---|---|
| SCN-B037-002 — a user-reported regression still blocks, by name | S1-T2, S1-T2b | REFUSES as designed |
| SCN-B037-003 — the BUG-029 pin | S1-T3 | REFUSES, all five named |
| SCN-B037-004 — record validation survives the optionality | S1-T4 | REFUSES with `PD12-AUTOMATION-ACCEPTOR` |
| SCN-B037-005 — readiness grants nothing | S1-T7, S1-T7b | REFUSES on the unchecked checklist item |
| S1-T8 — the registry value is READ, not hardcoded | S1-T8 | restoring `requiredAtTerminal: true` in a fixture registry restores the refusal |
| S1-T10 — the failure-code set is closed both ways | S1-T10, S1-T10b, S1-T10c | declared set equals emittable set; `PD12-NO-RECORD` in neither |

S1-T8 is the load-bearing one: it is the only case that would still pass if the
implementation had deleted the record check outright while claiming to read the
registry. It passes because the deletion was not a deletion — the emission is
gated on a registry read.

### Scope 2

**Executed:** YES
**Command:** `git --no-pager diff -- agents/bubbles_shared/feature-templates.md bubbles/registry/bug-packet.yaml bubbles/scripts/artifact-lint.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Template `## Checklist`, verbatim at this commit:

```
Human acceptance, opt-out. Ships CHECKED. The user's only required act is to UNCHECK an item whose behavior does not meet their expectation.

- [x] [Scenario or flow the user accepts]
- [x] [Another flow the user accepts]

An item the user has unchecked blocks a terminal transition until the behavior is fixed and the USER re-checks it. Unchecking nothing is acceptance.
```

The rules block was rewritten. The deleted rule was
`**Acceptance entries ship UNCHECKED (IMP-047 PD-12).** Automation MUST NOT
check one.` No surviving rule asserts unchecked shipping — proven mechanically
by S2-T6 in the run above, which scans all of `agents/**`.

**D-3 in the template, as ruled.** The three-way split is stated as its own
rule: automation MAY author the initial checked state (that permission named to
`bubbles.plan`), automation MUST NOT re-check a user's uncheck, automation MUST
NOT toggle to mirror a test outcome; and it records that only the first is
mechanically checkable because rows two and three produce a byte-identical
`- [x]`. The `bubbles.journey` rule is restated as
`Its prohibition is ABSOLUTE and carries no authoring exception` — no
auto-check exception was carved into it.

**D-2 in the lint, as ruled.** `artifact-lint.sh` re-acquires no checked-entry
rule. The diff against that file is 35 lines and every one of them is comment
or message text: the stale comment block at lines ~555-563 now states that the
checked shipped state comes from `acceptance-authority.yaml`, that restoring
the rule would refuse a user who legitimately unchecks everything, and that the
one assurance the deleted rule bought moved to the template-versus-registry
agreement check. The only non-comment change is a `fail` message string
(`IMP-047 PD-12` → `BUG-037 opt-out acceptance`). The executable checklist
rules — checkbox syntax, non-empty, shape verdict — are byte-identical.

`bug-packet.yaml`'s `uservalidation.md` purpose was inverted from
`Acceptance checklist shipped UNCHECKED` to
`Acceptance checklist shipped CHECKED under the BUG-037 opt-out contract`, and
S2-T7 asserts that text agrees with the registry rather than merely being
plausible.

**The `agents/**` sweep re-run at this commit.** Executed as part of the same
40/40 run (S2-T6) and independently as the design.md § 2.5 pattern sweep
recorded under [Scope 4](#scope-4). Result matches design.md § 2.5: no agent
file required a change and no `allowedPaths` expansion was taken.

### GREEN Scope 2

**Executed:** YES
**Claim Source:** executed
**Phase Agent:** bubbles.implement

SCN-B037-006 is case S2-T1 in the 40/40 run above:
`S2-T1 SCN-B037-006: a uservalidation.md materialized from the shipped template
reaches terminal with no human act`. It materializes the fixture from the
SHIPPED template block rather than from a hand-written copy, so a template that
regressed to unchecked shipping would fail it.

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
```

### Bounds Scope 2

**Executed:** YES — inside the same 40/40 run.
**Claim Source:** executed
**Phase Agent:** bubbles.implement

| Bound | Case | Result |
|---|---|---|
| Lint did not go blind — a non-checkbox bullet still fails | S2-T4 | FAILS as designed |
| Lint did not go blind — a checkbox-less checklist still fails | S2-T5 | FAILS as designed |
| The backstop D-2 declined to restore actually exists | S2-T2 | template agrees with the registry on headings AND `shippedState` |
| That backstop can actually refuse | S2-T9 | a fixture template block shipping `- [ ]` FAILS the agreement check |
| D-1 — the auto-check detector is not inert | S2-T8a | fires on a fixture whose `[ ]` became `[x]` |
| D-1 — no foreign `uservalidation.md` was modified | S2-T8 | 4 files scanned against `HEAD`, none had an item checked |
| D-1 — no migration script was authored | S2-T8b | none found |

S2-T9 and S2-T8a are the cases that prove S2-T2 and S2-T8 are not vacuous. A
check that can never fail is not a backstop, and D-2's whole justification for
declining to restore the lint rule rests on S2-T2 replacing it.

---

## Scope: implement — Scope 1 closeout re-verification - 2026-08-23

### Summary

Scope 1 was implemented and its evidence appended, but the `scopes.md` DoD boxes
and `state.json` were never updated. This phase re-executed every Scope 1
verification against the on-disk tree, confirmed each result matches the
evidence already recorded above, and recorded the scope. No source file was
modified by this phase — only `scopes.md` DoD checkboxes, this report, and
`state.json` execution/scope-progress fields.

### Scope 1 re-verification — commands and real exit codes

| # | Command | Exit | Result |
|---|---|---|---|
| 1 | `bash bubbles/scripts/acceptance-authority-selftest.sh` | **0** | 40/40 passed, 0 skipped |
| 2 | `bash tests/regression/test_35_human_acceptance_terminal.sh` | **0** | 13 passed, 0 failed |
| 3 | `shellcheck -x bubbles/scripts/acceptance-authority-lib.sh` | **1** | one SC2016 **info** at line 211 (`sed -E 's/^\`//; s/\`$//'` — single quotes are intentional for a sed script); not a Scope 1 DoD item |
| 4 | `shfmt -d -i 2 -ci -bn bubbles/scripts/acceptance-authority-lib.sh` | **1** | style diff only (`-bn` wants leading `\|` / `&&`); not a Scope 1 DoD item, and `-bn` is not a convention this repository encodes anywhere |

**Executed:** YES
**Claim Source:** executed
**Phase Agent:** bubbles.implement

Command 1, re-run now, reproduced the byte-identical output already recorded
under [GREEN Scope 1](#green-scope-1) — `sha256:
efb20e66fd611d04c864fe82bb11d101c17ef7e1b064d4b806c60692a62898a6`, exit 0.

```
# BUG-037 S1 regression test_35_human_acceptance_terminal
$ bash tests/regression/test_35_human_acceptance_terminal.sh
exit: 0
lines: 15
sha256: 69234542da1069b46a42bc93f1951887ff68cd2606437c272702d9756f730593
--- output ---
test_35_human_acceptance_terminal (Gate G136)
  PASS: BUG-029 shape: two unchecked items are detected (2)
  PASS: adversarial: a fully accepted checklist reports zero (0)
  PASS: adversarial: a '[ ]' under '## Notes' is not counted (0)
  PASS: BUG-037: a fully checked list with no acceptance record now returns zero findings ()
  PASS: adversarial: an unchecked item still yields PD12-UNCHECKED-ITEM at terminal (PD12-UNCHECKED-ITEM)
  PASS: adversarial: the refusal NAMES the unchecked item
  PASS: PD12-NO-RECORD is retired and unreachable against the shipped registry
  PASS: a human-owned acceptance record with every box checked is accepted ()
  PASS: adversarial: an agent id as acceptedBy cannot grant acceptance (PD12-AUTOMATION-ACCEPTOR)
  PASS: guard fragment declares Gate G136
  PASS: the regression sources the shared reader and re-implements no section parser
  PASS: the gate is scoped to a terminal (done) transition
  PASS: the guard never writes to uservalidation.md
test_35_human_acceptance_terminal: 13 passed, 0 failed
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify 69234542da1069b46a42bc93f1951887ff68cd2606437c272702d9756f730593 -- bash tests/regression/test_35_human_acceptance_terminal.sh -->

**Reading on commands 3 and 4.** Neither `shellcheck` nor `shfmt` appears in any
Scope 1 DoD item, and neither is wired into this repository's validation
surface with a fixed flag set — `generate-validation-checks.sh` lists both as
merely *known* command names. SC2016 is `info` severity on a `sed` program that
must not expand, and the `shfmt -bn` diff is a leading-vs-trailing operator
style the file does not follow. Both are reported here as executed non-zero
results rather than silently passed over; neither is claimed as a DoD closure,
and neither was "fixed" by this phase, which would have modified a source file
outside a verify-and-record assignment.

### Scope 1 DoD item 12 — mechanical re-check

**Executed:** YES
**Command:** `bash bubbles/scripts/evidence-capture.sh --lines 14 --label "BUG-037 S1 DoD-12 no conditional early-return that silently passes" -- bash -c '…'`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
# BUG-037 S1 DoD-12 no conditional early-return that silently passes
exit: 0
lines: 14
sha256: f75390c1c223bf0001249b1844270cfec211bfc8867ea983b1f9c7189d95af55
--- output ---
### tests/regression/test_35_human_acceptance_terminal.sh
  skip/early-exit keywords (SKIP|skipped|not available|command -v .*|| exit 0|return 0 #): 0
    bare-zero-exit: 246:exit 0
  guard-clause zero-exits inside an if/&& (potential silent pass): 0
### bubbles/scripts/acceptance-authority-selftest.sh
  skip/early-exit keywords (SKIP|skipped|not available|command -v .*|| exit 0|return 0 #): 0
    bare-zero-exit: 491:      return 0
    bare-zero-exit: 888:exit 0
  guard-clause zero-exits inside an if/&& (potential silent pass): 0
### assertion counters are compared, not merely printed
787:      g && /^# GENERATED:/ {exit}
812:      g && /^  G[0-9]+:/ {exit}
885:  exit 1
888:exit 0
```
<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify f75390c1c223bf0001249b1844270cfec211bfc8867ea983b1f9c7189d95af55 -->

**Reading.** Zero skip keywords and zero conditional zero-exits in either file.
The three bare zero-exits are terminal success paths, each gated on a real
count: `test_35` line 246 is preceded by `[[ "$fail_count" -eq 0 ]] || exit 1`,
and the selftest's line 888 is preceded by `exit 1` at line 885 on the failure
branch. The selftest's line 491 `return 0` is the `*)` arm of a registry
`shippedState` case that **first prints** a `TEMPLATE-SHIPPED-STATE-UNKNOWN`
finding and then returns — a reported finding, not a silent pass.

### Scope 1 DoD items 2, 3 and 9 — file-state re-check

**Executed:** YES
**Command:** `grep -cE '^[[:space:]]*- id: PD12-' bubbles/registry/acceptance-authority.yaml; grep -n 'PD12-NO-RECORD' bubbles/registry/acceptance-authority.yaml bubbles/scripts/acceptance-authority-lib.sh; grep -n -A6 'bubbles_acceptance_record_required_at_terminal()' bubbles/scripts/acceptance-authority-lib.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
declared PD12 code count:
6
PD12-NO-RECORD in registry (grep -n, empty = absent):
63:# accurate. `PD12-NO-RECORD` is RETIRED: it demanded the separately authored
150:# a reader can grep the code rather than the prose. `PD12-NO-RECORD` was retired
---
PD12-NO-RECORD emitters in lib:
333:    printf 'PD12-NO-RECORD: no authored "%s"; this registry sets acceptance-record.requiredAtTerminal to true\n' \
---
record_required_at_terminal reader:
92:bubbles_acceptance_record_required_at_terminal() {
93-  local value
94-  value="$(bubbles_acceptance_section_field acceptance-record requiredAtTerminal)"
95-  [[ "$value" == "true" ]]
96-}
```

Registry values re-confirmed on disk: `shippedState: checked` (line 93) and
`requiredAtTerminal: false` (line 108).

**Reading.** Item 2 holds: the two data keys are inverted and the file header
carries the rewritten opt-out rationale. Item 9 holds: exactly six `PD12-*` ids
are declared, `PD12-NO-RECORD` is absent from `failureCodes` and survives only
as the retirement note at lines 63-67 and 150, which is precisely what D-5
asked for. Item 3 holds with a stated nuance — the `PD12-NO-RECORD` string
literal still exists at library line 333, but it is unreachable against the
shipped registry because its branch is gated on
`bubbles_acceptance_record_required_at_terminal`, which reads
`requiredAtTerminal` through the ordinary registry accessor. That is the design
D-5 chose, and the selftest pins it in both directions: S1-T1b observes no
`PD12-NO-RECORD` finding, S1-T10c asserts the literal is the *only* undeclared
code and that it is registry-gated, and S1-T8 restores the refusal by flipping
the value in a fixture registry. A hardcoded deletion would fail S1-T8.

### Scope 1 DoD item 1 — RED provenance

**Executed:** NO — not re-executed by this phase.
**Claim Source:** interpreted
**Phase Agent:** bubbles.implement

The RED reproduction was captured at the `bug` phase, before the change, and is
recorded above under [Failing state](#failing-state): terminal verdict exit
**1** on a fixture whose only defect was that a satisfied user objected to
nothing, emitting two `PD12-UNCHECKED-ITEM` findings plus `PD12-NO-RECORD`. This
phase did not and could not re-run it — the fix is already on disk, and
reproducing the pre-change failure would require reverting the tree, which this
assignment forbids. The item is checked on the strength of the pre-existing
executed evidence, not on anything this phase ran. Its re-executable substitute
is S1-T8, which passed in command 1 above.

### Scope 1 closeout

12 of 12 Scope 1 DoD items are checked. Eleven rest on commands executed in this
phase; item 1 rests on the `bug`-phase RED recorded earlier in this same report.
Scopes 2-4 were not touched: their DoD boxes remain unchecked and their
`scopeProgress` entries remain `not_started`, even though the selftest run
happens to exercise S2 and S4 cases.

---

## Scope: implement — Scope 2 closeout verification - 2026-08-23

### Summary

Scope 2 ("Template, lint, and authoring agents") is closed out here. The
implementation edits — the template's checked `## Checklist` and rewritten rules
block, the D-2 comment-only edit to `artifact-lint.sh`, the inverted
`bug-packet.yaml` purpose text, and the S2-T1..S2-T9 selftest cases — were
authored in an earlier session and recorded under [Scope 2](#scope-2) but were
never verified with executed evidence at a recorded exit code. This phase
re-inspected each Scope 2 target as it stands on disk and re-ran every
verification the Scope 2 DoD names. Nothing was found missing, so this phase
authored no new implementation; it produced the missing execution evidence.

Every DoD claim below rests on a command run in THIS phase. Nothing is carried
forward on the strength of the earlier session's narrative.

### Scope 2 verification — commands and real exit codes

**Command 1.**

**Executed:** YES
**Command:** `bash bubbles/scripts/evidence-capture.sh --lines 24 --label "BUG-037 S2 acceptance-authority-selftest (full window)" -- bash bubbles/scripts/acceptance-authority-selftest.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
# BUG-037 S2 acceptance-authority-selftest (full window)
$ bash bubbles/scripts/acceptance-authority-selftest.sh
exit: 0
lines: 44
sha256: efb20e66fd611d04c864fe82bb11d101c17ef7e1b064d4b806c60692a62898a6
--- output ---
acceptance-authority-selftest: <repo>/bubbles/scripts/../registry/acceptance-authority.yaml
  ok   S1-T1 SCN-B037-001: a fully checked checklist with no record reaches terminal
  ok   S1-T1b SCN-B037-001: no PD12-NO-RECORD finding is emitted
  ok   S1-T1c the shipped (checked) shape also passes shape lint
  ok   S1-T2 SCN-B037-002 ADVERSARIAL: one unchecked item refuses terminal and is NAMED
  ok   S1-T2b exactly the rejected item is reported, not the five accepted ones
  ok   S1-T3 SCN-B037-003 ADVERSARIAL: the BUG-029 shape is refused and all five unchecked items are named
  ok   S1-T4 SCN-B037-004 ADVERSARIAL: an agent id as acceptedBy still refuses the shape verdict
  ok   S1-T5 a present record missing acceptedAt is PD12-RECORD-INCOMPLETE
  ok   S1-T6 external-record acceptance without its record pointer is refused
  ok   S1-T6b external-record acceptance WITH its record pointer is accepted
  ok   S1-T6c an acceptance method outside the closed vocabulary is refused
  ok   S1-T7 SCN-B037-005 ADVERSARIAL: a fully checked readiness block discharges no acceptance obligation
  ok   S1-T7b a non-checkbox automation-readiness bullet is refused
  ok   S1-T8 ADVERSARIAL: flipping requiredAtTerminal back in a fixture registry restores the refusal (the value is READ, not hardcoded)
  ok   S1-T8b renaming the heading in the registry changes the reader (single source, not a copy)
  ok   S1-T9 an unchecked bullet outside the acceptance checklist is ignored
  ok   S1-T10 ADVERSARIAL: every declared failure code is emittable and every emitted code is declared
  ok   S1-T10b D-5: PD12-NO-RECORD appears in neither the declared nor the observed code set
  ok   S1-T10c the only undeclared code literal in the library is the retired PD12-NO-RECORD, and it is registry-gated
  ok   S2-T1 SCN-B037-006: a uservalidation.md materialized from the shipped template reaches terminal with no human act
  ok   S2-T2 the uservalidation template agrees with acceptance-authority.yaml on section headings AND shippedState
  ok   S2-T9 ADVERSARIAL: a fixture template block shipping '- [ ]' FAILS the agreement check
  ok   S2-T3 SCN-B037-007: lint accepts a fully unchecked checklist and demands no checked entry
  ok   S2-T3b lint still runs the acceptance-authority shape check
  ok   S2-T4 ADVERSARIAL: lint still fails on a non-checkbox checklist bullet
  ok   S2-T5 ADVERSARIAL: lint still fails on a checklist with zero checkbox entries
  ok   S2-T6 no agents/** surface asserts that acceptance items ship unchecked
  ok   S2-T7 bug-packet.yaml's uservalidation purpose agrees with acceptance-authority.yaml (shipped checked)
  ok   S2-T8a ADVERSARIAL: the auto-check detector fires on a fixture whose '[ ]' became '[x]'
  ok   S2-T8 D-1 bound: no uservalidation.md outside bugs/BUG-037-* had an item checked by this change (4 scanned against HEAD)
  ok   S2-T8b D-1: no acceptance/uservalidation migration script was authored
  ok   S4-T1 SCN-B037-013: no governance surface asserts the checked-entry lint rule artifact-lint.sh does not carry
  ok   S4-T1b no governance surface carries the stale 'checked-by-default template is legitimate' framing
  ok   S4-T2 GC-2: G136's description names only refusal codes acceptance-authority.yaml declares
  ok   S4-T2b G136's description states the opt-out terminal condition, not the superseded record demand
  ok   S4-T8 D-3 bound: G057's description declares the advisory status of the rules its enforcer does not verify
  ok   S3-T9 Check 43's pass/fail text no longer asserts a required human acceptance record
  ok   S4-T4 SCN-B037-014: CHANGELOG.md carries the BUG-037 entry, the PD-12 entry and the D-1 upgrade note
  ok   S4-T4b the BUG-029 changelog entry no longer states the superseded lint contract as current
  ok   S4-T9 D-4 bound: no path under bugs/BUG-032- was modified

acceptance-authority-selftest: 40/40 checks passed
acceptance-authority-selftest: OK
```

`--lines 24` was used so the whole 44-line output is inside the window and no
Scope 2 case is elided. The hash covers every line produced and is re-derivable
with `bash bubbles/scripts/evidence-capture.sh --verify efb20e66fd611d04c864fe82bb11d101c17ef7e1b064d4b806c60692a62898a6 -- bash bubbles/scripts/acceptance-authority-selftest.sh`.

All nine Scope 2 cases are present and passing: S2-T1, S2-T2, S2-T3, S2-T4,
S2-T5, S2-T6, S2-T7, S2-T8, S2-T9 (plus the S2-T3b, S2-T8a and S2-T8b
sub-cases). Zero skipped.

**Command 2.**

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
```

This run was taken BEFORE the Scope 2 DoD boxes were checked. It is re-run after
the checkbox edit under [Scope 2 closeout](#scope-2-closeout), because the
anti-fabrication check "All checked DoD items in scopes.md have evidence blocks"
only becomes load-bearing once the boxes are checked.

### Scope 2 file-state re-check — the DoD items that are not selftest cases

**Executed:** YES
**Command:** `awk '/^## Checklist$/{f=1} f&&/^## Human Acceptance Record$/{exit} f' agents/bubbles_shared/feature-templates.md; grep -rniE 'ship(s|ped)? unchecked' agents/; grep -n "three-way rule\|ABSOLUTE and carries no authoring exception" agents/bubbles_shared/feature-templates.md; grep -nE 'at least (one|ONE) checked|checked \[x\] entry' bubbles/scripts/artifact-lint.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
=== T1: template Checklist ships [x] ===
## Checklist

Human acceptance, opt-out. Ships CHECKED. The user's only required act is to UNCHECK an item whose behavior does not meet their expectation.

- [x] [Scenario or flow the user accepts]
- [x] [Another flow the user accepts]

An item the user has unchecked blocks a terminal transition until the behavior is fixed and the USER re-checks it. Unchecking nothing is acceptance.

=== T2: no rule asserts unchecked shipping (agents/) ===
GREP_EXIT=1 (1 = zero hits = clean)
=== T3: D-3 three-way split + absolute journey rule ===
338:- **The three-way rule on who may write a `[x]` (G057, G136).** Automation MAY author the INITIAL checked state at artifact creation — that permission belongs to `bubbles.plan`, which owns creation. Automation MUST NOT re-check an item a user unchecked. Automation MUST NOT toggle an item either way to mirror a test outcome. Only the first is mechanically checkable: a template-authored `[x]` and an agent's overwrite of a user's uncheck are byte-identical, so rows two and three are agent-instruction obligations rather than guard-enforced rules.
339:- `bubbles.journey` structures the `## Goal`, `## Journey Steps`, and `## Open Refinements` sections against the live product. Its prohibition is ABSOLUTE and carries no authoring exception: it runs later, against a file that already exists, so it NEVER auto-checks a `## Checklist` item and NEVER writes `## Human Acceptance Record` (G057, G136) — it records observations; the user accepts.
=== T4: lint has no checked-entry rule ===
556:    # BUG-037 D-2. There is deliberately NO "must carry a checked [x] entry"
GREP_EXIT=0 (1 = zero hits = clean)
```

T1 shows the template ships `- [x]` on disk, not merely that a test says so.
T2 returns zero hits across all of `agents/`, so no surviving rule asserts
unchecked shipping — the deleted rule was
`**Acceptance entries ship UNCHECKED (IMP-047 PD-12).** Automation MUST NOT
check one.` T3 shows the D-3 three-way split at line 338 and the `bubbles.journey`
prohibition at line 339 stated as ABSOLUTE with the words "carries no authoring
exception"; no exception was carved. T4's single hit is the D-2 comment
asserting the ABSENCE of the rule — the negation, not the rule.

### Bounds Scope 2

**Executed:** YES — every row is a case inside the 40/40 run in command 1.
**Claim Source:** executed
**Phase Agent:** bubbles.implement

| Bound | Case | Result in this phase |
|---|---|---|
| Lint did not go blind — a non-checkbox bullet still fails | S2-T4 | FAILS as designed |
| Lint did not go blind — a checkbox-less checklist still fails | S2-T5 | FAILS as designed |
| The backstop D-2 declined to restore actually exists | S2-T2 | template agrees with the registry on headings AND `shippedState` |
| That backstop can actually refuse | S2-T9 | a fixture template block shipping `- [ ]` FAILS the agreement check |
| D-1 — the auto-check detector is not inert | S2-T8a | fires on a fixture whose `[ ]` became `[x]` |
| D-1 — no foreign `uservalidation.md` had an item checked | S2-T8 | 4 files scanned against `HEAD`, zero findings |
| D-1 — no migration script was authored | S2-T8b | none found |

S2-T9 and S2-T8a are what keep S2-T2 and S2-T8 from being vacuous. D-2's whole
justification for declining to restore the lint rule rests on S2-T2 replacing
it, so a S2-T2 that could never fail would leave D-2 unsupported.

**A disclosure about S2-T8's exact claim.** S2-T8 asserts the AC-6 invariant —
no item that was `[ ]` at the base ref is `[x]` now — over every
`uservalidation.md` outside `bugs/BUG-037-*`. It is deliberately NOT a
"no foreign file was touched at all" check, and the distinction matters here
because `bugs/BUG-033-…/uservalidation.md` IS modified in the working tree by
unrelated in-flight BUG-033 work that this phase did not author and was
instructed not to touch. S2-T8 scanned it and returned zero findings, so no
`[ ]`→`[x]` flip occurred there. The narrower "BUG-037 changed no foreign
`uservalidation.md`" claim is supported by ownership rather than by this test:
this phase wrote only `report.md`, `scopes.md` and `state.json` inside
`bugs/BUG-037-uservalidation-opt-out-acceptance/`, and `git status --short` on
that path reports the whole packet as untracked (`??`), so it contains no
tracked file this phase could have modified. `git --no-pager diff --name-only
HEAD` over the rest of the tree shows no `uservalidation.md` outside
`bugs/BUG-033-*`.

### D-2 proof — the artifact-lint.sh diff is comment-and-message only

**Executed:** YES
**Command:** `git --no-pager diff HEAD -- bubbles/scripts/artifact-lint.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

The diff carries exactly three hunks and NO control-flow change:

1. **Lines 6-13, header comment.** `IMP-047 PD-12.` attribution dropped; the
   sourcing rationale is unchanged and a pointer to
   `bubbles/registry/acceptance-authority.yaml` is added.
2. **Lines ~553-575, the stale comment block the DoD names.** Rewritten from the
   PD-12 rationale ("Acceptance items now ship UNCHECKED … terminal acceptance
   additionally requires a human-owned record") to the D-2 statement: there is
   deliberately no checked-entry rule and there will not be one; the checked
   shipped state comes from `acceptance-checklist.shippedState` in the registry
   rather than from a lint refusal; restoring the rule would refuse a user
   mid-review who legitimately unchecks everything; the one assurance the
   deleted rule bought moved to the template↔registry agreement check.
3. **Line ~585, one `fail` message string.** `uservalidation acceptance
   authority is malformed (IMP-047 PD-12)` → `… (BUG-037 opt-out acceptance)`.

Hunk 3 is beyond the DoD's literal "only the ~555-563 comment block", and is
recorded here rather than glossed. It is a refusal LABEL, not a rule: it changes
which bug id a reader is pointed at, not what input the lint accepts. The
executable checklist rules — the checkbox-syntax check, the non-empty check, and
the `bubbles_acceptance_shape_verdict` call — are byte-identical to HEAD, and
`git diff` shows no added, removed or reordered conditional anywhere in the
file. The DoD's substantive claim, "checklist RULES unchanged", holds exactly.

### The agents/** sweep, re-run at this commit

**Executed:** YES
**Command:** `grep -rniE 'ship(s|ped)? (un)?checked|defaults to checked|auto-check|acceptance record|at least one checked|checked-by-default|human acceptance' agents/ skills/ templates/ docs/ -l` and `git --no-pager diff --name-only HEAD -- agents/`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
=== plan/journey agent hits (must be unchanged) ===
agents/bubbles.plan.agent.md:230:  - `uservalidation.md` — Create with checked-by-default baseline template (`- [x]` items).
agents/bubbles.journey.agent.md:72:- It MUST NOT auto-check human acceptance items (G057) — journey records observations; the HUMAN accepts.
agents/bubbles.journey.agent.md:89:… WITHOUT auto-checking any human acceptance item (G057 preserved: journey records observations; the HUMAN accepts).
=== are plan/journey modified? ===
(empty above means unmodified)
=== agents/ files changed vs HEAD ===
agents/bubbles_shared/feature-templates.md
agents/bubbles_shared/quality-gates.md
agents/bubbles_shared/test-core.md
```

The result matches design.md § 2.5 exactly. The three hits outside the known
stale surfaces are `bubbles.plan.agent.md:230` and `bubbles.journey.agent.md:72,89`,
and all three already agree with the opt-out model: `bubbles.plan` is told to
author checked, which is the AC-1 permission D-3 assigns to it, and the two
journey lines are the absolute no-auto-check rule D-3 keeps verbatim. Both files
are unmodified against `HEAD`, so no agent file required a change.

`state.json`'s `workBoundary.allowedPaths` lists 23 entries and neither
`agents/bubbles.plan.agent.md` nor `agents/bubbles.journey.agent.md` is among
them — no expansion was taken, which is what the DoD asks. Of the three changed
`agents/` files, `feature-templates.md` is Scope 2's own target and is already
in `allowedPaths`; `quality-gates.md` and `test-core.md` are the GC-3
known-stale surfaces that design.md § 2.2 assigns to **Scope 4**. They carry
edits from the earlier session. This phase did not author them and does not
claim them — they are verified when Scope 4 is closed out, and Scope 4's
`scopeProgress` entry stays `not_started`.

### Scope 2 closeout

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance` (re-run AFTER the DoD boxes were checked)
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

See the raw output under [Scope 2 closeout re-lint](#scope-2-closeout-re-lint)
below.

11 of 11 Scope 2 DoD items are checked, each on a command executed in this
phase. This phase authored no implementation change: every Scope 2 target was
already on disk in its delivered shape, and the work done here was inspection,
verification and evidence capture. Scopes 3 and 4 were not touched — their DoD
boxes remain unchecked and their `scopeProgress` entries remain `not_started`,
even though the command-1 run happens to exercise S3-T9 and several S4 cases.

Two items are recorded with an explicit narrowing rather than a clean claim:
the D-2 item (hunk 3 of the lint diff is a message string beyond the DoD's
literal wording) and the D-1 item (S2-T8 proves no `[ ]`→`[x]` flip, not
untouched-ness, while `bugs/BUG-033-…/uservalidation.md` carries unrelated
in-flight edits). Both narrowings are stated above rather than absorbed.

### Scope 2 closeout re-lint

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Run AFTER the eleven Scope 2 DoD boxes were checked, the scope status was set to
`[x] Done`, and `state.json` was updated. This is the run that makes
"All checked DoD items in scopes.md have evidence blocks" load-bearing for
Scope 2 — the earlier run in command 2 could not exercise it, because the boxes
were still unchecked.

```
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
```

---

## Scope: implement — Scope 3 closeout verification - 2026-08-23

### Summary

Scope 3 ("Guard Check 43 and the regression surfaces") delivers AC-4 and AC-5.
All three surfaces named in the Scope 3 implementation plan already carried the
opt-out contract when this closeout began; this section is the verification that
they do, run against the shipped files, plus the box-checking that closes the
nine Scope 3 DoD items.

The three surfaces:

1. `bubbles/scripts/guards/tail-delegated-gates.sh` Check 43 — header comment,
   `fail`, `info` and `pass` text all carry the opt-out contract; the
   `transition_target_status != "done"` scope rule is unchanged.
2. `bubbles/scripts/state-transition-guard-selftest.sh` — S3-T0 through S3-T5
   drive the REAL guard (`BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=0`), and
   the BUG-029 case is retained as S3-T3.
3. `tests/regression/test_35_human_acceptance_terminal.sh` — fixtures 1, 2 and 3
   retained, the PD-12 assertion inverted, and an adversarial
   `PD12-UNCHECKED-ITEM` partner added.

### Scope 3

**Check 43 runtime text — S3-T9 grep conformance**

**Executed:** YES
**Command:** `awk '/^echo "--- Check 43: Human Acceptance Terminal Gate/ {inside=1} inside && /^(  )*(fail|pass|info) / {...}' bubbles/scripts/guards/tail-delegated-gates.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Every line Check 43 can emit at runtime, extracted from the shipped fragment and
searched case-insensitively for a surviving acceptance-record demand:

```
EMITTED|   info "No uservalidation.md at $uservalidation_terminal_file; skipping (Gate G136)"
EMITTED|   pass "Target status '$transition_target_status' is not 'done'; user acceptance is not yet claimed (Gate G136)"
EMITTED|     fail "uservalidation.md carries a user-reported regression; a terminal transition claims every behavior is accepted (Gate G136)"
EMITTED|       info "  $uv_line"
EMITTED|     info "An unchecked item is the user's rejection of that behavior — the only act the opt-out contract asks of them"
EMITTED|     info "The guard does not check these for you; checking a box on the author's behalf would erase that rejection"
EMITTED|     info "Fix the behavior, then the USER re-checks the item. No agent, guard or lint may re-check it for them"
EMITTED|     info "Contract: bubbles/registry/acceptance-authority.yaml; template: agents/bubbles_shared/feature-templates.md"
EMITTED|     pass "No uservalidation.md acceptance item is unchecked; no user objection is recorded (Gate G136)"
S3-T9: emitted-lines=9 stale-acceptance-record-demands=0
S3-T9: PASS - no stale acceptance-record demand in Check 43 runtime text
AWK_EXIT=0
```

The `pass` line reads "No uservalidation.md acceptance item is unchecked; no user
objection is recorded" — the "and a human acceptance record is present" clause the
implementation plan named is gone. The registry pointer
(`bubbles/registry/acceptance-authority.yaml`) is retained as planned.

**Check 43 reads through the SHARED library — no re-implemented parser**

**Executed:** YES
**Command:** `grep -n 'source "$SCRIPT_DIR/acceptance-authority-lib.sh"' bubbles/scripts/guards/tail-delegated-gates.sh` and `grep -cE '^[a-z_]*(section_body|parse_checklist|extract_checklist|checklist_items)\(\)' bubbles/scripts/guards/tail-delegated-gates.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
--- shared-reader / no-local-parser conformance ---
543:  source "$SCRIPT_DIR/acceptance-authority-lib.sh"
0
```

Check 43 sources the shared reader at line 543 and defines zero local section
parsers, so the shape check and the terminal check cannot desync.

**`test_35` sources the shared reader — S3-T8**

Proven by the regression's own assertion, in the GREEN block below:
`PASS: the regression sources the shared reader and re-implements no section parser`.
That assertion greps its own source for `acceptance-authority-lib.sh` plus
`bubbles_acceptance_terminal_verdict` AND for the ABSENCE of a locally defined
section parser, so a private copy would fail it rather than pass unnoticed.

**Shellcheck resolution detail.** `shellcheck -x tail-delegated-gates.sh` must be
run FROM the `guards/` directory. The fragment's
`# shellcheck source=../acceptance-authority-lib.sh` directive is a RELATIVE
path, and `-x` resolves it against the current working directory, not against the
file being linted. Run from the repo root it cannot find the library; run from
`guards/` it resolves and the lint is clean.

**Executed:** YES
**Command:** `cd bubbles/scripts/guards && shellcheck -x tail-delegated-gates.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
SHELLCHECK_EXIT=0
```

### GREEN Scope 3

**`state-transition-guard-selftest.sh` — bounded capture**

**Executed:** YES
**Command:** `bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

527 lines produced, all hashed. Re-derive with:
`bash bubbles/scripts/evidence-capture.sh --verify 8e05bed1b4288dcb86705280dcc22cce19721a706627a13569d7b427df67b114 -- bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard-selftest.sh`

```
# BUG-037 Scope 3: state-transition-guard-selftest
$ bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 527
sha256: 8e05bed1b4288dcb86705280dcc22cce19721a706627a13569d7b427df67b114
--- last 4 ---
PASS: BUG-013: claimedAtUnreconciled with a sub-threshold reason still fails the transition guard
PASS: BUG-013: a claim declared unreconciled on a short reason stays IN the analysed set (count is still 10)
PASS: BUG-013: a sub-threshold reason does not register as a declared unreconciled claim
----------------------------------------
state-transition-guard selftest passed.
```

The selftest's terminal line is `state-transition-guard selftest passed.`, which
that script emits only when its failure counter is zero.

**`tests/regression/test_35_human_acceptance_terminal.sh`**

**Executed:** YES
**Command:** `bash tests/regression/test_35_human_acceptance_terminal.sh`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
test_35_human_acceptance_terminal (Gate G136)
  PASS: BUG-029 shape: two unchecked items are detected (2)
  PASS: adversarial: a fully accepted checklist reports zero (0)
  PASS: adversarial: a '[ ]' under '## Notes' is not counted (0)
  PASS: BUG-037: a fully checked list with no acceptance record now returns zero findings ()
  PASS: adversarial: an unchecked item still yields PD12-UNCHECKED-ITEM at terminal (PD12-UNCHECKED-ITEM)
  PASS: adversarial: the refusal NAMES the unchecked item
  PASS: PD12-NO-RECORD is retired and unreachable against the shipped registry
  PASS: a human-owned acceptance record with every box checked is accepted ()
  PASS: adversarial: an agent id as acceptedBy cannot grant acceptance (PD12-AUTOMATION-ACCEPTOR)
  PASS: guard fragment declares Gate G136
  PASS: the regression sources the shared reader and re-implements no section parser
  PASS: the gate is scoped to a terminal (done) transition
  PASS: the guard never writes to uservalidation.md
test_35_human_acceptance_terminal: 13 passed, 0 failed
EXIT=0
```

13 passed, 0 failed. Fixtures 1, 2 and 3 and their BUG-029 assertions are the
first three lines; the inverted PD-12 assertion is line 4; its adversarial
partner is line 5.

### Bounds Scope 3

The scenario proofs below all run through the REAL guard. The selftest disables
the fast path per case (`env BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=0`),
because that fast path skips sourcing `guards/tail-delegated-gates.sh` — the
fragment Check 43 lives in. Left at the file's default of 1, every one of these
cases would read an EMPTY Check 43 section and the negative assertions would pass
on ABSENCE rather than on behavior. `c43_assert_block_present` (S3-T0) refuses an
empty block outright, so that regression cannot land silently.

| Case | Scenario | Assertion, as the selftest states it |
|------|----------|--------------------------------------|
| S3-T0 | — | the REAL guard reached Check 43; the section under test is present |
| S3-T1 | SCN-B037-009 | the REAL guard passes a fully checked, record-less packet at a `done` target |
| S3-T1b | D-5 | the guard emits no `PD12-NO-RECORD` finding (the code is retired) |
| S3-T2 | SCN-B037-010 | the REAL guard refuses an unchecked item and NAMES it |
| S3-T2b | AC-4 | the refusal describes the opt-out contract, not an acceptance record |
| S3-T3 | BUG-029 pin | the BUG-029 shape is refused end to end through the real guard, all five items named |
| S3-T4 | SCN-B037-011 | `uservalidation.md` sha256 unchanged across a REFUSING guard run |
| S3-T5 | SCN-B037-012 | a ceiling-bound target status is still exempt; acceptance is not evaluated |

**S3-T4 is the AC-5 proof and is load-bearing.** A guard that "helpfully" checked
the box would satisfy S3-T1, S3-T2, S3-T3 and S3-T5 — it would simply see a
checked list on the next read. Only the byte comparison catches it. The case
hashes `uservalidation.md` before the run, runs the guard against the REFUSING
mixed fixture, hashes again, and compares.

The same invariant is pinned independently by `test_35`, which greps the shipped
fragment for an in-place write (`sed -i`, or a redirect onto
`$uservalidation_terminal_file`) and fails if one appears:

```
--- terminal-scoping + no-write conformance ---
536:elif [[ "$transition_target_status" != "done" ]]; then
0
```

Line 536 is the terminal-scoping guard clause (SCN-B037-012 / S3-T5); the `0` is
the count of in-place writes to `uservalidation.md` in the fragment.

**Narrowing — "zero skipped".** The DoD item asks for the selftest to pass with
zero skipped. The harness emits no per-case skip tally, and it has no `skip`
helper to emit one, so this is asserted from the harness's structure plus its
zero-failure terminal line, not from a counter this run printed. The item is
checked on that basis and the narrowing is stated here rather than absorbed.

### Scope 3 closeout

Nine of nine Scope 3 DoD items checked. Scope 3 status set to `[x] Done`.
`certification.scopeProgress[2].status` set to `done` with `certified: false`
(certification is `bubbles.validate`-owned and is not written here).
`execution.currentScope` advanced to `4`.

Scopes 1, 2 and 4 were not touched. `bubbles/scripts/state-transition-guard.sh`
and `bubbles/scripts/receipt-identity-selftest.sh` carry unrelated in-flight
BUG-033 edits, are outside this bug's `allowedPaths`, and were neither edited,
reverted, nor staged.

### Scope 3 closeout re-lint

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Exit Code:** 0
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Run AFTER the nine Scope 3 DoD boxes were checked, the scope status was set to
`[x] Done`, and `state.json` was updated. As with Scope 2, this is the run that
makes "All checked DoD items in scopes.md have evidence blocks" load-bearing for
Scope 3 — an earlier run could not exercise it, because the boxes were still
unchecked.

```
JSON_OK currentScope= 4
1 done False
2 done False
3 done False
4 not_started False
--- artifact lint ---
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
```

The first five lines are the `state.json` read-back that preceded the lint:
`execution.currentScope` is `4`, scopes 1-3 are `done` with `certified: false`,
and scope 4 remains `not_started`.

---

## Scope: implement — Scope 4 closeout verification - 2026-08-23

### Summary

Scope 4's eleven content items are verified and closed with executed evidence.
Its two gate items — S4-T5 `framework-validate` and S4-T6 `release-check` — are
**NOT** closed and are recorded below as **Blocked**. They are blocked on a
pre-existing failure in `bubbles/scripts/guard-lib-timeout-selftest.sh` that is
unmodified from HEAD and outside this packet's `workBoundary`, and on a wall
clock bound: both runs were cut at 1500s by `SIGALRM` and returned 142, so
neither produced a pass or a fail — they produced no verdict at all.

Scope 4 DoD: **11 of 13 checked.** Scope 4 status is therefore `blocked`, not
`done`, and the packet `status` stays `in_progress` with no terminal
`certification.status` written.

Every command below was run from `/Users/pkirsanov/Projects/bubbles`, wrapped as
`bash -c 'cd /Users/pkirsanov/Projects/bubbles && …'` so the working directory
could not be stripped. That wrapper matters here: the parent runner's two gate
attempts resolved against a different workspace folder, which is why their
`Installer manifest check (v6.0 / B9)` line is an artifact and is explicitly NOT
recorded as a finding — see **Blocked** below.

### Scope 4

**Repository binding, committed before any local read or write.**

```
$ bash bubbles/scripts/repository-binding.sh preflight \
    --session-id vscode-b0dbac204a2903e3dbf3e4d765d8be38 \
    --session-control-file /Users/pkirsanov/.local/state/bubbles/repository-binding/vscode-b0dbac204a2903e3dbf3e4d765d8be38/repository-binding.json \
    --request-class STRUCTURED --repository-root /Users/pkirsanov/Projects/bubbles \
    --expected-control-revision 6 --workspace-root … (9 host-declared roots)
REPOSITORY PREFLIGHT CONFIRMED repository=bubbles root=/Users/pkirsanov/Projects/bubbles source=explicit-repositoryRoot affinity=confirmed
PREFLIGHT_COMMITTED decision=rb:vscode-b0dbac204a2903e3dbf3e4d765d8be38:7 revision=7 repository=bubbles root=/Users/pkirsanov/Projects/bubbles
PREFLIGHT_EXIT=0
```

**Claim Source:** executed.

**DoD 1 — `G136.description` rewritten; both false assertions removed.**

Both assertions were searched for inside the `G136` registry block itself, not
across the file, so a hit elsewhere could not mask a miss here.

```
$ python3  # scan the G136 block of bubbles/registry/gates.yaml
['PD12-AUTOMATION-ACCEPTOR', 'PD12-METHOD-FIELD-MISSING', 'PD12-METHOD-UNKNOWN',
 'PD12-READINESS-NOT-CHECKBOX', 'PD12-RECORD-INCOMPLETE', 'PD12-UNCHECKED-ITEM']
false assertion A (lint requires >=1 checked): False
false assertion B (template ships unchecked): False
```

The rewritten description states that acceptance is OPT-OUT, that the
`## Checklist` ships CHECKED, that the gate is a rejection channel and not proof
a human acted, and that `## Human Acceptance Record` is OPTIONAL and not
required at terminal. **Claim Source:** executed.

**DoD 1 corollary — S4-T2, the description names only codes the guard emits.**

```
$ grep -n "PD12-" bubbles/registry/acceptance-authority.yaml
156:  - id: PD12-RECORD-INCOMPLETE
158:  - id: PD12-METHOD-UNKNOWN
160:  - id: PD12-METHOD-FIELD-MISSING
162:  - id: PD12-AUTOMATION-ACCEPTOR
164:  - id: PD12-UNCHECKED-ITEM
166:  - id: PD12-READINESS-NOT-CHECKBOX
```

Six declared codes; the same six named in `G136.description`; set equality, no
extras in either direction. `PD12-NO-RECORD` appears in neither list — the
description refers to its retirement in prose without naming it as emittable,
which is what D-5 required. **Claim Source:** executed.

**DoD 2, 3, 4 — the three stale prose surfaces replaced.**

```
$ sed -n "272p" agents/bubbles_shared/quality-gates.md
- **G136** … Acceptance is OPT-OUT (BUG-037): the `## Checklist` ships CHECKED,
  automation authors that initial state … **What it proves, stated honestly:**
  exactly one thing — that no user recorded an objection … `PD12-NO-RECORD` is
  retired.

$ sed -n "57p" skills/bubbles-quality-gates-catalog/SKILL.md
| G136 | `human_acceptance_terminal_gate` … Acceptance is OPT-OUT (BUG-037) …
  it is a rejection channel, not proof a human acted … `PD12-NO-RECORD` is
  retired. | `guards/tail-delegated-gates.sh` (Check 43) |

$ sed -n "296,330p" agents/bubbles_shared/test-core.md
## User Acceptance Is Terminal (IMP-040 SCOPE-10 / EV-8, BUG-037, Gate G136)
Acceptance is **opt-out**. The `## Checklist` ships CHECKED and automation
authors that initial state. … `## Human Acceptance Record` is OPTIONAL and is
NOT required at terminal.
```

All three now describe the opt-out contract and none asserts the deleted lint
rule. **Claim Source:** executed.

**DoD 5, 6, 7 — `CHANGELOG.md`.**

```
$ grep -n "BUG-037\|BUG-029" CHANGELOG.md
34:### User Acceptance Is Opt-Out Again (BUG-037)
57:the BUG-029 closure, the guard's refusal to edit the artifact, the `^bubbles\.`
106:stands; the inversion is superseded by BUG-037 above. Four governance surfaces
108:current until BUG-037 corrected them.
1396:**Gate G136 — a terminal transition checks user acceptance (EV-8, BUG-029).**
1402:part by BUG-037** — this entry's original wording described a lint rule
1405:restored; see the BUG-037 entry above for the contract that is current.
```

- Line 34 is the **BUG-037 entry**. It carries the D-1 **UPGRADE NOTE** in full:
  the delivering commit is named as the cutover; files authored before it ship
  UNCHECKED and now read as rejections; each packet owner re-authors that
  packet's checklist into the checked shape **before** the user reviews it; once
  a user has unchecked an item nothing may re-check it but the user; and
  "**No migration script exists and none will be shipped**" with the reason —
  a script cannot distinguish a template-authored `[ ]` from a deliberate
  uncheck.
- The heading at line ~93, "The Acceptance-Authority Change Had No Changelog
  Entry (IMP-047 PD-12)", is the **backfilled PD-12 entry**.
- Line 1396 is the **corrected BUG-029 entry**. It now says "Superseded in part
  by BUG-037" and states the old lint rule as deleted-and-not-restored rather
  than as current.

One fidelity defect was found and fixed during this closeout: line 1405 said
"see the BUG-037 entry **below**", but BUG-037 sits at line 34 and the BUG-029
entry at line 1396, so the pointer was inverted. Corrected to "above".
**Claim Source:** executed.

**DoD 8 — D-3 applied to `G057.description`; S4-T8.**

`G057.description` now carries the three-way split verbatim: (1) automation MAY
author the INITIAL checked state, owned by `bubbles.plan`, and this leg IS
mechanically checkable through the template-versus-registry agreement case in
`acceptance-authority-selftest.sh`; (2) automation MUST NOT re-check a user's
uncheck; (3) automation MUST NOT toggle either way to mirror a test outcome. It
declares rows 2 and 3 **ADVISORY** and states why.

```
$ grep -c "uservalidation" bubbles/scripts/guards/control-plane-checks.sh
0
```

Zero. G057's own enforcer never reads `uservalidation.md`, so the previous
wording claimed enforcement this gate has never performed. The description now
says that plainly. That is the S4-T8 assertion and it holds. **Claim Source:**
executed.

**DoD 13 — the design.md § 2.5 sweep, re-run at this commit.**

Per-entry re-run, not a single aggregate grep, so a newly-introduced claim in
any ruled-out file would surface:

```
bubbles/scripts/bug-packet-selftest.sh                         matches=0
bubbles/scripts/transition-contract-resolver.sh                matches=0
bubbles/scripts/transition-contract-resolver-selftest.sh       matches=0
bubbles/scripts/repo-drift-report.sh                           matches=0
bubbles/agent-ownership.yaml                                   matches=0
docs/guides/AGENT_MANUAL.md                                    matches=0
docs/recipes/guided-journey.md                                 matches=0
docs/recipes/new-feature.md                                    matches=0
docs/recipes/plan-only.md                                      matches=0
docs/examples/rest-api-endpoint.example.md                     matches=0
skills/bubbles-feature-template/SKILL.md                       matches=0
skills/bubbles-artifact-ownership-routing/SKILL.md             matches=0
templates/copilot-instructions.md.tmpl                         matches=0
```

Thirteen ruled-out entries, still zero matches each. The remaining table rows,
read verbatim and unchanged:

```
agents/bubbles.plan.agent.md:230   - `uservalidation.md` — Create with checked-by-default baseline template (`- [x]` items).
docs/guides/FRAMEWORK_CONCEPTS.md:59  | Human acceptance checklist — users uncheck items to report regressions | Planner |
docs/CHEATSHEET.md:268             | `human acceptance` | `uservalidation.md` is human-owned acceptance input. Automation findings do not toggle it. |
bubbles/cheatsheet/vocabulary.json:35   "term": "human acceptance",
bubbles/scripts/framework-validate.sh:1084  run_check_self_only "BUG-029 human acceptance terminal regression (G136)" …
```

Two carry a claim that is already correct under the opt-out model
(`bubbles.plan.agent.md:230`, `FRAMEWORK_CONCEPTS.md:59`), two carry a neutral
mirroring prohibition that survives D-3 verbatim (`CHEATSHEET.md:268`,
`vocabulary.json`), and one is a registration label rather than a model claim
(`framework-validate.sh:1084`). **16 of 16 entries need no change — the recorded
result is unchanged.** The `bubbles.journey` prohibition D-3 keeps in force is
also intact:

```
$ sed -n "72p" agents/bubbles.journey.agent.md
- It MUST NOT auto-check human acceptance items (G057) — journey records observations; the HUMAN accepts.
```

**Claim Source:** executed.

**Repository-wide stale-text sweep — zero hits.**

```
$ grep -rn "ships UNCHECKED\|at least ONE checked\|at least one checked\|checked-by-default template is legitimate" agents/ skills/ bubbles/registry/ docs/
SWEEP_EXIT=1 (grep exit 1 == zero matching lines)
```

That is the S4-T1 assertion: no repository surface asserts the deleted lint
requirement. **Claim Source:** executed.

**Supporting run — S4-T7 `agnosticity`.**

```
$ /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/cli.sh agnosticity
ℹ️  Scanning 744 portable file(s) for agnosticity drift
✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
AGNOSTICITY_EXIT=0
```

S4-T7 is a Test Plan row, not a DoD item; it is recorded here as supporting
evidence and is not used to close any box. **Claim Source:** executed.

### Bounds Scope 4

**DoD 9 — D-4 applied, and S4-T9 proves `bugs/BUG-032-` was not touched.**

The IMP-047 row now carries the design § 3 D-4 replacement text verbatim:

```
BUG-032 stays `in_progress`, now for its own reasons only: its remaining work is
the operator-approved G043/G101 documentation surfaces owned by `bubbles.docs`
(`nextRequiredOwner: bubbles.docs`). The G136 acceptance-record requirement that
PD-12 added, and that this row previously named as the blocker, was removed by
BUG-037 when opt-out acceptance was restored. BUG-032's checklist was authored
2026-08-16 under the pre-PD-12 checked-by-default template, so its checked state
is legacy-shaped and MUST NOT be read as a fresh human acceptance.
```

The superseded sentence is gone, counted rather than eyeballed:

```
$ grep -c "closing it needs a human G136 acceptance record" improvements/INDEX.md
0
```

One fidelity defect fixed during this closeout: the sentence had lost its
terminal period against the design text when it was written into a table cell.
Restored, so the replacement is verbatim.

S4-T9, the D-4 bound — nothing under `bugs/BUG-032-` was modified, staged, or
added:

```
$ git status --porcelain -- 'bugs/BUG-032-*'
STATUS_EXIT=0            # zero output lines
$ git diff HEAD --stat -- 'bugs/BUG-032-*'
DIFF_EXIT=0              # zero output lines
```

Both commands emitted nothing. BUG-032 was not closed, advanced, or otherwise
touched as a side effect of removing its stated blocker. **Claim Source:**
executed.

**DoD 10 — generated artifacts REGENERATED, regeneration diff empty.**

Each generator was re-run and the artifacts hashed before and after a second
re-run. A hand-edited generated file passes a text grep and fails this:

```
$ shasum -a 256 docs/generated/gate-coverage-map.md bubbles/registry/validation-checks.yaml bubbles/release-manifest.json
e2885c6212456226959b2e5097a5b2cd5a4b599cb5f4259c4ecc48bac8591d8e  docs/generated/gate-coverage-map.md
51b3334faa0811c2b4bb9482212495f8a7ac81d312c21c6b1a0f4e2691fde607  bubbles/registry/validation-checks.yaml
9a397c5295ed69e8ef7ead41744035b58655ea7216a780f57c2fbc5a5200448e  bubbles/release-manifest.json

$ bash bubbles/scripts/generate-gate-coverage-map.sh
generate-gate-coverage-map: no change (121 gates mapped)      exit=0
$ bash bubbles/scripts/generate-validation-checks.sh
generate-validation-checks: wrote …/bubbles/registry/validation-checks.yaml  exit=0
$ bash bubbles/scripts/generate-release-manifest.sh
Updated release manifest: 7.28.0 (927 managed files)          exit=0

$ shasum -a 256 docs/generated/gate-coverage-map.md bubbles/registry/validation-checks.yaml bubbles/release-manifest.json
e2885c6212456226959b2e5097a5b2cd5a4b599cb5f4259c4ecc48bac8591d8e  docs/generated/gate-coverage-map.md
51b3334faa0811c2b4bb9482212495f8a7ac81d312c21c6b1a0f4e2691fde607  bubbles/registry/validation-checks.yaml
9a397c5295ed69e8ef7ead41744035b58655ea7216a780f57c2fbc5a5200448e  bubbles/release-manifest.json
```

All three digests are byte-identical across the regeneration. The regeneration
diff is empty.

The two CHANGELOG/INDEX fidelity corrections recorded above were made BEFORE
this regeneration, so `bubbles/release-manifest.json` reflects the current tree
rather than a pre-edit tree.

S4-T3's two selftests:

```
$ bash bubbles/scripts/generate-validation-checks-selftest.sh
  ok   A2 two derivations of an unchanged tree are byte-identical
  ok   A1 a hand edit inside the generated file is refused as DRIFT
generate-validation-checks-selftest: 10 check(s), 0 failure(s)      exit=0

$ bash bubbles/scripts/generate-gate-coverage-map-selftest.sh
generate-gate-coverage-map-selftest: SKIP (PyYAML not installed)    exit=0
```

**Narrowing, stated rather than hidden:** the gate-coverage-map selftest
**SKIPPED** on this host because PyYAML is absent. Its exit code 0 is a skip,
not a pass, and it is not counted as one. The idempotency claim for
`gate-coverage-map.md` rests instead on the hash comparison above and on the
generator's own `no change (121 gates mapped)` report, both of which did run
here. **Claim Source:** executed, with the skip declared.

### GREEN Scope 4 — BLOCKED

**The two gate DoD items are NOT satisfied and are NOT checked.**

**S4-T5 — `framework-validate` — no verdict. Real exit code 142.**

```
$ /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 1500 bash bubbles/scripts/cli.sh framework-validate
exit: 142
lines: 9021
sha256: 8f506c771ee408be9260bac37ba6ef477d6dd63fbdf2b5e0c4ed1ba42e8621ae
```

**S4-T6 — `release-check` — no verdict. Real exit code 142.**

```
exit: 142
lines: 9021
sha256: e21fb3d505ebca304e5ea8b8134980d1daab2a322e073d02fc9d1ad519f1b975
```

142 is `128 + 14`, `SIGALRM`. Both runs were killed by the 1500s bound before
completing. **Neither run passed and neither run failed — neither produced a
verdict.** The DoD wording, "passes end to end with a real exit code", is not
met and has not been weakened. **Claim Source:** executed, with the outcome
recorded as no-verdict.

**Two things in those runs must NOT be read as findings.**

1. Both parent runs also executed from a working directory other than
   `/Users/pkirsanov/Projects/bubbles`. Their
   `Installer manifest check (v6.0 / B9)` failure —
   `/Users/pkirsanov/Projects/EmailAnalyzer/bubbles/scripts/generate-installer.sh: No such file or directory`
   — is an artifact of that stripped working directory, not a defect in this
   repository. It is recorded here so it cannot be mistaken for a real finding,
   and it is deliberately NOT routed. Every command in this closeout was wrapped
   as `bash -c 'cd /Users/pkirsanov/Projects/bubbles && …'` for exactly this
   reason.
2. The blocker below is real, and is not ours.

**The real blocker — OW-009, pre-existing, outside this packet's workBoundary.**

Isolated on this host, in this repository, in this session:

```
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 1
lines: 11
sha256: 489b2ef0a79c0d3379d5c5b0bd3b191608fab9ccee1f7c550751197fe44d7e4a
  PASS  instant command in $( ) returns promptly (0s, output intact)
  PASS  timeout fires and normalizes to 124 (3s)
  PASS  command exit code preserved (rc=7, 0s)
  PASS  fallback child can trap SIGINT (rc=130, 0s)
  FAIL  progress-aware command returned rc=2 after 2s
  FAIL  idle timeout returned rc=2 reason=none after 2s
  FAIL  absolute timeout returned rc=2 reason=none after 2s
  PASS  progress runner preserves command exit code (rc=9)
  FAIL  timed-out validator leaked or blocked: pid=67870 rc=2 reason=none elapsed=7s
  PASS  lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: 4 failure(s)
```

Four failures, all in the progress-aware timeout runner, all returning `rc=2`
with `reason=none` — a macOS portability defect in that runner, not a logic
error in the cases.

**Attribution — proven, not asserted.** Neither owning file is modified by this
packet:

```
$ git status --short -- bubbles/scripts/guard-lib.sh bubbles/scripts/guard-lib-timeout-selftest.sh
STATUS_EXIT=0            # zero output lines — both files are at HEAD
$ git diff HEAD --stat -- bubbles/scripts/guard-lib.sh bubbles/scripts/guard-lib-timeout-selftest.sh
DIFF_EXIT=0              # zero output lines
```

And neither is inside this packet's boundary:

```
bubbles/scripts/guard-lib.sh                  -> in allowedPaths: False
bubbles/scripts/guard-lib-timeout-selftest.sh -> in allowedPaths: False
```

This is a **pre-existing** defect, **not a BUG-037 regression**, and it is
**out of scope for BUG-037** — it was NOT fixed here, and fixing it here would
have been an out-of-boundary edit. It is routed as finding **OW-009** in
`state.json.reworkQueue` so it cannot be lost.

**What Scope 4 needs before its last two boxes can be checked.**

1. OW-009 resolved in its own packet, or an explicit ruling that
   `framework-validate` may be certified with it outstanding.
2. A wall-clock bound above 1500s on this host, since the 1500s cut is what
   turned both runs into no-verdicts rather than results.

Neither is available inside this packet's boundary, so Scope 4 is recorded
`blocked` and the two items stay `[ ]`.

### Scope 4 closeout

- Scope 4 DoD: **11 of 13 checked.**
- Packet DoD: **43 of 45 checked** (32 from Scopes 1-3, plus 11 here).
- Scope 4 status: `blocked`. Packet `status`: `in_progress`, unchanged.
- No terminal `certification.status` was written. `certified` remains `false`.
- Files this closeout changed: `CHANGELOG.md` (one inverted cross-reference),
  `improvements/INDEX.md` (one restored terminal period),
  `bubbles/registry/validation-checks.yaml` and `bubbles/release-manifest.json`
  (regenerated, never hand-edited), plus this packet's own artifacts. Nothing
  under `bugs/BUG-032-` or `bugs/BUG-033-` was touched, and
  `state-transition-guard.sh`, `receipt-identity-selftest.sh`, `guard-lib.sh`
  and `guard-lib-timeout-selftest.sh` were not edited, reverted, or staged.

## Uncertainty Declaration — Scope 4

- `framework-validate` and `release-check` have **no verdict** on this host. I
  am not claiming they would pass; I am claiming only that they were cut at
  1500s and returned 142. Both DoD items remain unchecked.
- `generate-gate-coverage-map-selftest.sh` **skipped** (PyYAML absent). Its
  exit 0 is not counted as a pass. The gate-coverage-map idempotency claim rests
  on the hash comparison and the generator's own no-change report.
- The parent runs' `Installer manifest check (v6.0 / B9)` failure is a
  working-directory artifact and is deliberately not routed as a finding.
- OW-009's failure mode is characterized only as far as the selftest output
  shows (`rc=2`, `reason=none`, one leaked pid). I did not diagnose the
  underlying macOS portability cause, because that work is outside this packet.

## Scope: implement — uservalidation.md legacy-shape re-authoring - 2026-08-23

**Phase:** implement
**Claim Source:** executed

### What Changed

This packet's own `uservalidation.md` was authored under the pre-BUG-037 opt-in
template and was never re-authored by the packet that delivered opt-out. It is
the D-1 grandfather clause case: legacy-shaped, not a rejection. Re-authored
into the shipped opt-out shape:

1. `## Checklist` preamble replaced with the opt-out wording.
2. All six acceptance items flipped `- [ ]` → `- [x]`, text unchanged.
3. Trailing note replaced with the opt-out wording.
4. Optionality preamble added under `## Human Acceptance Record`.
5. `## Automation Readiness` and `## Goal` left untouched.

### No User Uncheck Was Overwritten

The re-author is permitted only before a user review. Confirmed mechanically —
the packet folder is untracked, so no committed revision of the file exists and
no user has ever reviewed it. All six items were uniformly `- [ ]` under the
OLD opt-in preamble, which is the legacy-ships-unchecked signature, not a
partial deliberate uncheck.

```text
$ git log --oneline -- bugs/BUG-037-uservalidation-opt-out-acceptance/uservalidation.md
(no output — no commits touch this path)
$ git status --porcelain -- bugs/BUG-037-uservalidation-opt-out-acceptance/
?? bugs/BUG-037-uservalidation-opt-out-acceptance/
```

### Evidence — artifact-lint

```text
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-037-uservalidation-opt-out-acceptance
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
```

### Evidence — acceptance terminal verdict

Exit 0 with zero emitted findings. The verdict function prints one line per
finding, so an empty body plus exit 0 is the clean verdict, not a silent
skip — the same reader Gate G136 sources.

```text
$ source bubbles/scripts/acceptance-authority-lib.sh && \
  bubbles_acceptance_terminal_verdict bugs/BUG-037-uservalidation-opt-out-acceptance/uservalidation.md
TERMINAL_VERDICT_EXIT=0
```

### Boundary

Only `uservalidation.md` and `report.md` inside this packet were modified. No
other `uservalidation.md` anywhere in the repo was touched, and
`state-transition-guard.sh`, `receipt-identity-selftest.sh`, `guard-lib.sh`,
`bugs/BUG-032-*`, and `bugs/BUG-033-*` were not edited. No packet `status` or
`certification.status` was changed. No git command that discards changes was
run.

## Scope: implement — OW-009 resolved by BUG-038 (state correction) - 2026-08-23

### What Changed

Finding `OW-009` was still recorded `open` in `reworkQueue`, and
`execution.nextRequiredAction` still named it as the blocker for Scope 4's two
gate DoD items. That was stale. `OW-009` has since been root-caused and fixed
under its own packet, `bugs/BUG-038-progress-timeout-bsd-wc-padding/`.

Root cause: BSD `wc` right-pads its count in a fixed-width field, so
`current_size="$(wc -c < "$log_file")"` in `bubbles_run_with_progress_timeout`
(`bubbles/scripts/guard-lib.sh`) failed the `^[0-9]+$` test on the very first
poll of every BSD host, and the runner returned `rc=2` before either deadline
was evaluated. Fix: normalize the padding away with
`current_size="${current_size//[[:space:]]/}"` before the numeric test —
fork-free, and with no macOS special-case.

The fix is present in this checkout:

```text
$ grep -n "current_size" bubbles/scripts/guard-lib.sh
122:  local current_size=0
131:    current_size="$(wc -c 2>/dev/null < "$log_file")" || current_size=""
137:    current_size="${current_size//[[:space:]]/}"
138:    if [[ ! "$current_size" =~ ^[0-9]+$ ]]; then
143:    if [[ "$current_size" -ne "$last_size" ]]; then
144:      last_size="$current_size"
```

### GREEN — reported by the parent runner

**Claim Source:** interpreted. The selftest was executed by the parent runner,
not in this session; the result below is quoted from that run.

```text
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 0
lines: 11
sha256: 06054735b7d1ade85254102451e6ef7406693818baeb32d1b3c972efd6c7f102
guard-lib timeout selftest: OK (10 cases)
```

That is up from the RED run recorded in the `GREEN Scope 4 — BLOCKED` section
above, which returned exit 1 with 4 failures, all of them `rc=2 reason=none`.

### What This Does NOT Change

`S4-T5` (`framework-validate`) and `S4-T6` (`release-check`) remain
**UNCHECKED and unverified**. Removing their blocker is not the same as
producing a verdict. No `framework-validate` and no `release-check` has yet run
to completion in this checkout: the machine-wide validation lock is currently
held by a concurrent BUG-033 validation run, and the earlier attempts bounded at
1500s returned exit 142 (SIGALRM), which is no verdict at all.

`certification.scopeProgress[3].status` therefore stays `blocked`, and
`execution.nextRequiredOwner` stays `bubbles.validate`. The next action is to
execute `framework-validate` and then `release-check` to completion and record
their real exit codes.

### Boundary

Only `state.json` and `report.md` inside this packet were modified.
`bubbles/scripts/guard-lib.sh` was READ ONLY and not edited here — its fix
belongs to `bugs/BUG-038-progress-timeout-bsd-wc-padding/`.
`bugs/BUG-033-*`, `bugs/BUG-032-*`, `state-transition-guard.sh`, and
`receipt-identity-selftest.sh` were not touched. `framework-validate` and
`release-check` were NOT run. No DoD box was checked. No packet `status` and no
`certification.status` was written. No git command that discards changes was
run.

## Scope: implement — the real Scope 4 blocker is BUG-033, not lock contention - 2026-08-23

### What Changed

The blocker recorded for `S4-T5` and `S4-T6` was *machine-wide lock contention
plus insufficient timeout bounds*. That was **incomplete**. A
`framework-validate` run **did** acquire the lock and **did** execute.

### The run

**Claim Source:** interpreted. The run was executed by the parent runner, not in
this session; the result below is quoted from that run verbatim.

```text
$ /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 3600 bash bubbles/scripts/cli.sh framework-validate
exit: 142                 # SIGALRM at 3600s — still no completion verdict
lines: 2942
sha256: e6b763dd9aadcff3abd38351e48031c33034419eed059e5d0d352cd81e51c1b7
```

Exit 142 is a bound overrun, so the run still produced **no completion
verdict** — neither `S4-T5` nor `S4-T6` may be checked on it. But before the
alarm fired the run emitted **real failures**:

```text
FAIL: CHECK 43 (clone): one stdout hash cited by TWO DIFFERENT commands BLOCKS — blocked but WITHOUT the expected Check-9 reason: 'Evidence receipt CLONE'
FAIL: Evidence-admission hardening selftest (IMP-102 / SCOPE-1)
  FAIL: bugfix behavioral positive passes (expected exit 0, observed 1)
  FAIL: bugfix positive reports passed (field evaluationStatus did not equal "passed")
  FAIL: bugfix positive is certifying v2 output (field certified did not equal true)
  FAIL: bugfix required executable oracle passes (check bugfix-end-state was not passed/)
  FAIL: feature behavioral positive passes (expected exit 0, observed 1)
  FAIL: feature positive reports passed (field evaluationStatus did not equal "passed")
  FAIL: feature positive is certifying v2 output (field certified did not equal true)
```

### Attribution — by command, not by inference

**Claim Source:** executed (this session).

```text
$ git --no-pager status --short -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/receipt-identity-selftest.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/evidence-admission-hardening-selftest.sh
 M bubbles/scripts/receipt-identity-selftest.sh
 M bubbles/scripts/state-transition-guard-selftest.sh
 M bubbles/scripts/state-transition-guard.sh

$ git --no-pager diff --stat HEAD -- <same four paths>
 bubbles/scripts/receipt-identity-selftest.sh       | 118 +++++
 bubbles/scripts/state-transition-guard-selftest.sh | 518 +++++++++++++++++++--
 bubbles/scripts/state-transition-guard.sh          | 298 +++++++++++-
 3 files changed, 862 insertions(+), 72 deletions(-)
```

`bubbles/scripts/evidence-admission-hardening-selftest.sh` is **absent from both
listings**, i.e. CLEAN at HEAD. The failing selftest is therefore itself
unmodified — it fails because the guard it exercises is mid-edit.

Boundary membership, checked against this packet's `workBoundary.allowedPaths`:

```text
   bubbles/scripts/state-transition-guard.sh -> NOT IN
   bubbles/scripts/receipt-identity-selftest.sh -> NOT IN
   bubbles/scripts/state-transition-guard-selftest.sh -> IN
   bubbles/scripts/evidence-admission-hardening-selftest.sh -> NOT IN
```

> **Correction to the assertion this task was given.** It is **not** true that
> none of the four paths is in `allowedPaths`.
> `state-transition-guard-selftest.sh` **is** listed, because BUG-037 Scope 3
> legitimately edits it — so its dirty state is not attributable to BUG-033
> alone. The conclusion is unaffected: the two surfaces that actually **fail**
> (`state-transition-guard.sh` Check 43, and the clean
> `evidence-admission-hardening-selftest.sh` that exercises it) are both
> outside this boundary.

```text
$ head -1 bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/bug.md
# BUG-033 — Check 43 accuses honest re-runs of evidence forgery
```

BUG-033's `bug.md` names `bubbles/scripts/state-transition-guard.sh` Check 43
(`deterministic_siblings`) as the affected surface — precisely the failing
check.

### Conclusion

BUG-037's two gate DoD items **cannot** be satisfied in this working tree while
BUG-033 is mid-flight. This is a **cross-packet sequencing dependency**, not a
BUG-037 defect, and not the already-resolved `OW-009`. Recorded as finding
`BLOCKED-ON-BUG-033` in `reworkQueue` (severity `blocking`, disposition
`out-of-boundary`, owner `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization`).

Re-run both gates once BUG-033 reaches a terminal state and the shared guard is
no longer mid-edit. Exit 142 at a **3600s** bound also proves the run exceeds
one hour under concurrent load, so the re-run needs a bound **above 3600s**.

### Boundary

Only `state.json` and `report.md` inside this packet were modified. `S4-T5` and
`S4-T6` remain **UNCHECKED** and unweakened.
`certification.scopeProgress[3].status` stays `blocked`,
`execution.nextRequiredOwner` stays `bubbles.validate`, packet `status` stays
`in_progress`, `certification.status` stays `in_progress`.
`state-transition-guard.sh`, `receipt-identity-selftest.sh` and
`evidence-admission-hardening-selftest.sh` were READ ONLY — they belong to
BUG-033. Nothing under `bugs/BUG-033-` or `bugs/BUG-032-` was modified.
`framework-validate` and `release-check` were NOT run here. No git command that
discards changes was run.

---

## Scope: implement — BUG-037's own gate cases are GREEN; the blocker is now environmental - 2026-08-24

### What Changed

State correction only. No code, gate, test or DoD change. The recorded blocker
for Scope 4's two gate DoD items — *BUG-033 landing* — is **superseded by better
evidence**. `S4-T5` and `S4-T6` remain **UNCHECKED**.

### BUG-037's own gate behavior is PROVEN GREEN inside framework-validate

The most recent `framework-validate` run reached and passed all three Check 43
acceptance cases, verbatim:

```text
PASS: Check 43: one checked plus one unchecked item is detected as unaccepted (BUG-029 shape)
PASS: Check 43 adversarial: a fully checked checklist reports no unchecked item, and a '[ ]' outside the Checklist section is ignored
PASS: Check 43 (BUG-037): an OPTIONAL authored human record is still accepted at terminal
```

The evidence-admission / receipt-clone failure that blocked the prior run —
`FAIL: CHECK 43 (clone)` plus `FAIL: Evidence-admission hardening selftest
(IMP-102 / SCOPE-1)` with its 7 sub-failures — is **GONE**. BUG-033's selftest
migration resolved it. The `BLOCKED-ON-BUG-033` finding is therefore moved to
`resolved` in `reworkQueue`, and **retained** rather than deleted so the finding
trail survives.

### framework-validate still cannot produce a verdict

Four consecutive bounded attempts, all `exit 142` (SIGALRM) and therefore **no
verdict at all** — neither a pass nor a fail:

| Bound | Exit | Lines | sha256 |
|---|---|---|---|
| 1500s | 142 | 9021 | `8f506c771ee408be9260bac37ba6ef477d6dd63fbdf2b5e0c4ed1ba42e8621ae` |
| 3600s | 142 | 2942 | `e6b763dd9aadcff3abd38351e48031c33034419eed059e5d0d352cd81e51c1b7` |
| 5400s | 142 | 8984 | `0e93db45398fdad509ff2c61ada5f9ef928771f1cdf94ebed2d454c7ac4355f7` |

Runtime now exceeds **90 minutes**, materially because BUG-033 added ~518 lines
to `bubbles/scripts/state-transition-guard-selftest.sh`, which alone takes
roughly 25 minutes.

### The tree is being concurrently mutated, so each run validates a moving target

The 5400s run reported:

```text
FAIL: Committed release manifest is current
FAIL: Release manifest selftest
FAIL: Interop apply/import selftest
FAIL: Install provenance selftest
FAIL: Trust doctor selftest
Framework-managed file drift detected: agents/bubbles.workflow.agent.md
```

Decisive detail: `git diff --stat -- agents/bubbles.workflow.agent.md` is
**EMPTY** — that file is unmodified. The drift is therefore measured against
`bubbles/release-manifest.json`, which went stale mid-run because **another
session** concurrently modified `agents/bubbles.plan.agent.md`,
`agents/bubbles_shared/critical-requirements.md`,
`bubbles/agent-bundle-budgets.json`, `bubbles/workflows.yaml` and
`skills/bubbles-claim-grounding/SKILL.md`. None of those five paths is a BUG-037
edit. The manifest, interop, provenance and trust-doctor failures are all
downstream of that same stale-manifest condition.

### Conclusion

The remaining obstacle is **ENVIRONMENTAL**, not a BUG-037 defect. Recorded as
finding `BLOCKED-ON-VALIDATION-ENVIRONMENT` in `reworkQueue` (severity
`blocking`, disposition `environmental`, owner `bubbles.validate`).

Next action, owned by `bubbles.validate`: run `framework-validate` against a
**quiescent** tree — no other session editing framework-managed paths, release
manifest current for the tree under test — with a bound of **at least 10800s**,
then run `release-check`, and record their **real exit codes** as the evidence
for `S4-T5` and `S4-T6`. A timed-out run is not a pass.

`bubbles/release-manifest.json` was deliberately **NOT** regenerated: the tree is
being concurrently edited, so a regenerated manifest would be stale again
immediately and could conflict with the other session's in-flight work.

### Boundary

Only `state.json` and `report.md` inside this packet were modified. `S4-T5` and
`S4-T6` remain **UNCHECKED** and unweakened.
`certification.scopeProgress[3].status` stays `blocked`,
`execution.nextRequiredOwner` stays `bubbles.validate`, packet `status` stays
`in_progress`, `certification.status` stays `in_progress`.
`framework-validate` and `release-check` were NOT run here. Nothing under
`bugs/BUG-033-`, `bugs/BUG-032-`, or any path another session is editing was
touched. No git command that discards changes was run.

## Scope: implement — a run COMPLETED; the blocker is a repo-wide red, not an unobtainable verdict - 2026-08-24

### What Changed

State correction only. No code, gate, test or DoD change, and neither gate DoD
item was checked.

The previously recorded blocker, `BLOCKED-ON-VALIDATION-ENVIRONMENT`, said
`framework-validate` **cannot reach a verdict** — more than 90 minutes of
runtime, four consecutive exit-142 timeouts, and a concurrently mutated tree.
That is no longer the accurate characterization, because a run has since
**completed**. The blocker is not that a verdict is unobtainable; it is that the
obtainable verdict is **red for reasons outside this packet**.

### Provenance, stated before the figures

**The completed run was executed by a CONCURRENT SESSION, not by this one.**
Its figures are read from a log file this session did not produce. They are
recorded below as **diagnostic input** and are tagged as such. This session did
**not** run `framework-validate` or `release-check`, and does not claim to have.

### The completed run

**Claim Source: interpreted (concurrent session's run, not executed here).**

| Observation | Value |
|---|---|
| Log | `/tmp/fv-full.log`, 18568 lines |
| Recorded exit | `/tmp/fv-full.exit` = **1** |
| Tally | **5107 PASS / 31 FAIL** |

A completed run that exits 1 is a **real verdict**. It is not a pass, so it does
not satisfy `S4-T5` or `S4-T6`, whose DoD wording requires a **passing** run.

### The 31 failures fall into four families, none of them acceptance

**Claim Source: executed** (the enumeration below is this session's `grep` over
that log; the log's contents are the concurrent session's).

1. **16 × downstream install-mode.** Fifteen lines of the shape
   `FAIL: T3: '<check>' was not SKIPPED under install-mode=downstream`
   (capability ledger, capability freshness, competitive docs, interop apply,
   release-manifest freshness / selftest / purity, install provenance, trust
   doctor, installer manifest check and selftest, bug-packet contract selftest,
   validation-run-receipt selftest, generated gate-enforcement block), plus
   `FAIL: T3c: downstream framework-validate exited 2 without a trailing Failed
   checks block`, plus the parent `FAIL: v5.3 downstream-install selftest (G1)`.
2. **12 × client credential / durable storage**, reported under the parent line
   `FAIL: BUG-013 sensitive client storage regression` — `DURABLE_CREDENTIAL_STORAGE`,
   `SESSION_PROVIDER_UNKNOWN`, `FORBIDDEN_SECRET_CLASS`, and IndexedDB /
   SharedPreferences / AsyncStorage read and persist coverage.
3. **1 ×** `FAIL: Mode-family inventory selftest (v6.1 / R5)`.
4. **2 ×** `FAIL: managed selftest runs with the system-only PATH (expected exit
   0, got 1)` and `FAIL: guard-lib timeout fallback selftest (OW-009)`.

### Attribution — by command, in this session

**Claim Source: executed.**

```
bubbles/scripts/v5.3-selftest.sh                         clean at HEAD
bubbles/scripts/mode-family-inventory-selftest.sh        clean at HEAD
bubbles/scripts/guard-lib-timeout-selftest.sh            clean at HEAD
bubbles/scripts/guard-lib.sh                             DIRTY:  M bubbles/scripts/guard-lib.sh
```

The three surfaces that own families 1, 3 and 4 are **clean at HEAD**, so those
failures are **pre-existing** and were not introduced by in-flight work. The only
dirty failing surface is `bubbles/scripts/guard-lib.sh`, which carries **this
session's BUG-038 fix**.

Membership tested against this packet's own `workBoundary.allowedPaths`:

```
bubbles/scripts/v5.3-selftest.sh                         NOT in allowedPaths
bubbles/scripts/mode-family-inventory-selftest.sh        NOT in allowedPaths
bubbles/scripts/guard-lib-timeout-selftest.sh            NOT in allowedPaths
bubbles/scripts/guard-lib.sh                             NOT in allowedPaths
```

**None of the 31 is a BUG-037 defect, and none of them lies in this packet's
`allowedPaths`.** Repairing any of them would be an out-of-boundary edit.

### BUG-037's own behavior is GREEN in that same run

**Claim Source: executed** (this session's `grep` over the concurrent session's log).

```
$ grep -c "PASS: Check 43" /tmp/fv-full.log
9

$ grep -nE "FAIL.*[Cc]heck 43|FAIL.*acceptance|FAIL.*uservalidation|FAIL.*G136" /tmp/fv-full.log
(no output — zero matches)
```

Across 18568 lines there is not one acceptance-related, `uservalidation`-related
or `G136`-related failure, while the acceptance checks this packet owns pass nine
times.

### The OW-009 entry in that run is stale — re-verified here

**Claim Source: executed.**

```
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 0
lines: 11
sha256: 06054735b7d1ade85254102451e6ef7406693818baeb32d1b3c972efd6c7f102
guard-lib timeout selftest: OK (10 cases)
```

The selftest is green on this working tree right now, so that run's OW-009 entry
does not describe a live defect.

**A load-sensitivity explanation was considered and is recorded as NOT supported,
rather than repeated.** The selftest does assert wall-clock bounds (`elapsed -le
3`, `-le 5`, `-ge 3 -le 7`, `-le 8`, `-le 12`), so it is timing-sensitive in
principle. But none of the four observed failures is an elapsed-bound miss — all
four report `rc=2 reason=none`:

```
FAIL  progress-aware command returned rc=2 after 2s
FAIL  idle timeout returned rc=2 reason=none after 2s
FAIL  absolute timeout returned rc=2 reason=none after 2s
FAIL  timed-out validator leaked or blocked: pid=72074 rc=2 reason=none elapsed=6s
```

That is the runner failing, not a bound being exceeded, and it is the exact
signature of the pre-fix BSD `wc` defect. A better-supported explanation is that
the run exercised a `guard-lib.sh` **without** the BUG-038 fix: `git show
HEAD:bubbles/scripts/guard-lib.sh` carries **no** `current_size` normalization at
all, and the normalization exists only in the dirty working tree.

**This is an OBSERVATION, not a proven root cause.** Confirming it would require
instrumenting the failing run, which this session neither executed nor
instrumented.

### Conclusion

Scopes 1, 2 and 3 are complete. Scope 4's **content** is complete — 11 of its 13
DoD items are met and closed with executed evidence. `S4-T5` and `S4-T6` remain
**UNCHECKED** because the DoD requires a **passing** end-to-end run and the
completed run exited **1**. The residual failures are **pre-existing repo-wide
defects outside this packet**, and BUG-037's own behavior is demonstrated green.

The next action, owned by `bubbles.validate`, is to drive the repository to a
green `framework-validate` as a **separate concern** — routing each of the four
families to its own owner or packet — and then re-run both gates and record their
real exit codes. Recorded as `BLOCKED-ON-REPO-WIDE-RED` in `reworkQueue`
(severity `blocking`, disposition `out-of-boundary`, owner `bubbles.validate`).
`BLOCKED-ON-VALIDATION-ENVIRONMENT` is marked **superseded** and **retained**, not
deleted.

### Boundary

Only `state.json` and `report.md` inside this packet were modified. `S4-T5` and
`S4-T6` remain **UNCHECKED** and unweakened.
`certification.scopeProgress[3].status` stays `blocked`,
`execution.nextRequiredOwner` stays `bubbles.validate`, packet `status` stays
`in_progress`, `certification.status` stays `in_progress`.
`framework-validate` and `release-check` were **NOT** run here, and no attempt was
made to fix any of the 31 failures. Nothing under `bugs/BUG-033-`,
`bugs/BUG-032-`, or any path another session is editing was touched. No git
command that discards changes was run.




