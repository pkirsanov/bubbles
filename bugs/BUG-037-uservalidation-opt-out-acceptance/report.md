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

## Scope: implement — canonical validation registry reconciliation - 2026-08-31

### Scope and finding

**Phase:** implement

**Claim Source:** executed

This node addressed origin finding `F-B033-DIAG-VALIDATION-CHECKS-DRIFT`.
The work regenerated owned artifacts only. It changed no generator source or
input source.

Scope 4 remains nonterminal. `S4-T5` and `S4-T6` remain unchecked. This phase
did not run `framework-validate` or `release-check`.

### RED — stale validation closure reproduced

**Executed:** YES (in this invocation)

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 240 /opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks.sh --check`

**Exit Code:** 1

**Output:**

```text
# BUG-037 RED validation closure freshness
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 240 /opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks.sh --check
exit: 1
lines: 1099
sha256: 38ac9d21b94e26a38a9e89d647cddb6633844437e47466e383c7364f1e2a337a
--- first 20 ---
generate-validation-checks: DRIFT — bubbles/registry/validation-checks.yaml does not match the derivation.
generate-validation-checks: this file is GENERATED. A hand edit is refused; regenerate it instead:
generate-validation-checks:   bash bubbles/scripts/generate-validation-checks.sh
193a194
>     - bubbles/scripts/bug-packet-resolve.sh
194a196,197
>     - bubbles/scripts/micro-fix-admission.sh
>     - bubbles/scripts/micro-fix-outcome-log.sh
198a202,203
>     - bubbles/registry/bug-packet.yaml
>     - bubbles/registry/micro-fix-packet.yaml
294a300
>     - bubbles/scripts/bug-packet-resolve.sh
317a324
>     - bubbles/scripts/compact-obligation-basis-selftest.sh
--- omitted 1059 line(s); sha256 above covers the full output ---
--- last 20 ---
>     label: "Discovered selftest: bug-packet-resolve-selftest.sh"
>     closureComplete: true
>     inputs:
>     - bubbles/scripts/bug-packet-resolve-selftest.sh
>     - bubbles/scripts/bug-packet-resolve.sh
>     - bubbles/registry/bug-packet.yaml
>     commands:
>     - python3
61749a62646
>     - bubbles/scripts/bug-packet-resolve.sh
61772a62670
>     - bubbles/scripts/compact-obligation-basis-selftest.sh
62463a63362
>     - bubbles/scripts/bug-packet-resolve.sh
62486a63386
>     - bubbles/scripts/compact-obligation-basis-selftest.sh
63192a64093
>     - bubbles/scripts/bug-packet-resolve.sh
63215a64117
>     - bubbles/scripts/compact-obligation-basis-selftest.sh
```

**Result:** PASS. The required pre-regeneration failure was reproduced.

### GREEN — canonical registry generation and focused selftest

**Executed:** YES (in this invocation)

**Commands:**

- `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks.sh`
- `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks.sh --check`
- `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks-selftest.sh`
- A second canonical generation followed by a SHA-256 equality assertion and final `--check`.

**Exit Code:** 0

**Output:**

```text
BUG037_VALIDATION_GENERATOR_GREEN_BEGIN
generate-validation-checks: OK — the committed closure map matches the derivation.
VALIDATION_CHECK_EXIT=0
  ok   P1 the generator writes a closure map (rc=0)
  ok   P2 a sourced lib and a read registry both land in the traced closure
  ok   P3 a tree-walking check is recorded closureComplete: false
  ok   P4 --check accepts the file the generator just wrote
  ok   A1 a hand edit inside the generated file is refused as DRIFT
  ok   A2 two derivations of an unchanged tree are byte-identical
  ok   A3 the compared derivation is non-empty and names both derived checks
  ok   A4 adding a real reference changes the derivation and appears in it
  ok   A5 --check refuses when the closure map is absent
  ok   A6 an unsupported bypass-shaped flag is refused with exit 2
generate-validation-checks-selftest: 10 check(s), 0 failure(s)
VALIDATION_SELFTEST_EXIT=0
VALIDATION_REGISTRY_BEFORE_SECOND_GENERATION_SHA256=6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862
generate-validation-checks: wrote /Users/pkirsanov/Projects/bubbles/bubbles/registry/validation-checks.yaml
SECOND_VALIDATION_GENERATION_EXIT=0
VALIDATION_REGISTRY_AFTER_SECOND_GENERATION_SHA256=6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862
SECOND_VALIDATION_GENERATION_BYTE_IDENTICAL=PASS
generate-validation-checks: OK — the committed closure map matches the derivation.
FINAL_VALIDATION_CHECK_EXIT=0
BUG037_VALIDATION_GENERATOR_GREEN_END
```

**Result:** PASS. Canonical generation, focused adversarial checks, freshness,
and byte identity all passed.

### Release-manifest freshness and attribution

**Claim Source:** executed

The release manifest was current immediately before registry generation. Its
pre-existing working-tree delta was therefore fresh for the prior registry
bytes.

Registry generation changed the registry SHA-256 from
`51b3334faa0811c2b4bb9482212495f8a7ac81d312c21c6b1a0f4e2691fde607` to
`6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862`.
The unchanged manifest row still carried the first digest. The next freshness
check therefore failed with exit 1.

The canonical release generator reconciled that checksum. A second generation
left the manifest byte-identical.

**Executed:** YES (in this invocation)

**Commands:** `generate-release-manifest.sh --check`, canonical generation,
another `--check`, a second generation, and a final `--check`.

**Exit Code:** 0 after the required stale intermediate result.

**Output:**

```text
BUG037_PRE_REGISTRY_RELEASE_MANIFEST_CHECK_BEGIN
Release manifest is current: 7.28.0 (930 managed files)
BUG037_PRE_REGISTRY_RELEASE_MANIFEST_CHECK_EXIT=0
BUG037_PRE_REGISTRY_RELEASE_MANIFEST_CHECK_END
BUG037_POST_REGISTRY_RELEASE_MANIFEST_CHECK_BEGIN
CURRENT_VALIDATION_REGISTRY_SHA256=6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862
MANIFEST_VALIDATION_REGISTRY_SHA256=51b3334faa0811c2b4bb9482212495f8a7ac81d312c21c6b1a0f4e2691fde607
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
POST_REGISTRY_RELEASE_MANIFEST_CHECK_EXIT=1
REGISTRY_CHECKSUM_DELTA=DETECTED
BUG037_POST_REGISTRY_RELEASE_MANIFEST_CHECK_END
BUG037_RELEASE_MANIFEST_RECONCILIATION_BEGIN
RELEASE_MANIFEST_BEFORE_RECONCILIATION_SHA256=f4dce3071ab6179940b97d7d1cf0d83a06a87c82dd774da9f57fb8ab75e4eac1
Updated release manifest: 7.28.0 (930 managed files)
RELEASE_MANIFEST_GENERATION_EXIT=0
Release manifest is current: 7.28.0 (930 managed files)
RELEASE_MANIFEST_CHECK_EXIT=0
CURRENT_VALIDATION_REGISTRY_SHA256=6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862
RECONCILED_MANIFEST_REGISTRY_SHA256=6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862
RELEASE_MANIFEST_BEFORE_SECOND_GENERATION_SHA256=21db8754191b7d750c9cdf8df360ead5e87db27e06782b34e8ba182a6a69e154
Updated release manifest: 7.28.0 (930 managed files)
SECOND_RELEASE_MANIFEST_GENERATION_EXIT=0
RELEASE_MANIFEST_AFTER_SECOND_GENERATION_SHA256=21db8754191b7d750c9cdf8df360ead5e87db27e06782b34e8ba182a6a69e154
SECOND_RELEASE_MANIFEST_GENERATION_BYTE_IDENTICAL=PASS
Release manifest is current: 7.28.0 (930 managed files)
FINAL_RELEASE_MANIFEST_CHECK_EXIT=0
BUG037_RELEASE_MANIFEST_RECONCILIATION_END
```

**Result:** PASS. The observed freshness transition isolates this invocation's
registry checksum as the follow-on manifest change. Existing deltas against
`HEAD` remain pre-existing and are not attributed to BUG-037.

### Focused boundary checks

**Executed:** YES (in this invocation)

**Exit Code:** 0

**Output:**

```text
BUG037_FOCUSED_BOUNDARY_CHECKS_BEGIN
[framework-health-evidence-lint] OK — 2 proposal(s) satisfy G125
FRAMEWORK_HEALTH_EVIDENCE_LINT_EXIT=0
generate-validation-checks: OK — the committed closure map matches the derivation.
VALIDATION_GENERATOR_CHECK_EXIT=0
Release manifest is current: 7.28.0 (930 managed files)
RELEASE_MANIFEST_CHECK_EXIT=0
GENERATED_TARGET_DIFF_CHECK_EXIT=0
BUG037_POST_REGEN_SOURCE_IDENTITIES_BEGIN
4ecd3ccacd1b01a6fa8db6ada604b09ccf68e3fe73e2a6b235d704955c662f0f  bubbles/scripts/generate-validation-checks.sh
53b85386357d4761ab6cbc11afeabe76d9e19449b7a10e10abc4cab4dd11f92d  bubbles/scripts/generate-validation-checks-selftest.sh
4ecd2e1c28cade403d12b087e1384e701f33b792650c7494cf575c690d038766  bubbles/scripts/generate-release-manifest.sh
923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f  bubbles/scripts/bug-packet-resolve.sh
0746fc6e158143b89affb72572c2bd133a5e6ce33258456cc740cf0167240b27  bubbles/scripts/micro-fix-admission.sh
84e9cba83ea68b89a1626489f207f871f02b35aee7085a796eb350fc49d5397e  bubbles/scripts/micro-fix-outcome-log.sh
e9f234b99fc79f997eb95b5230b4f187b920fcd74f7a81f7e9b6b4d7b05accde  bubbles/registry/bug-packet.yaml
ce7eccf0b00fb2de41ed87bb5a0ac59c2cab1561ae016cdf129ba31a977bbb24  bubbles/registry/micro-fix-packet.yaml
94fe726ed71f0f7b0c34ec15937d2f88536ca3c8ffb9f1e5dff42f73a0fabdd4  bubbles/scripts/compact-obligation-basis-selftest.sh
SOURCE_HASH_EXIT=0
BUG037_POST_REGEN_TARGET_IDENTITIES_BEGIN
6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862  bubbles/registry/validation-checks.yaml
21db8754191b7d750c9cdf8df360ead5e87db27e06782b34e8ba182a6a69e154  bubbles/release-manifest.json
TARGET_HASH_EXIT=0
3643    1536    bubbles/registry/validation-checks.yaml
47      44      bubbles/release-manifest.json
TARGET_NUMSTAT_EXIT=0
BUG037_GENERATED_CLOSURE_MEMBER_COUNTS_BEGIN
94
94
94
95
95
89
CLOSURE_MEMBER_COUNTS_EXIT=0
BUG037_FOCUSED_BOUNDARY_CHECKS_END
```

The post-generation source digests equal the pre-generation digests. This
invocation changed no generator or generator-input source bytes.

The pre-edit status already contained concurrent BUG-033 and BUG-042 work. This
phase did not edit those artifacts. It also did not absorb the independent
empty-output evidence-capture finding `F-B033-DIAG-EMPTY-OUTPUT-CAPTURE`.

### Finding accounting and routing

- **Addressed:** `F-B033-DIAG-VALIDATION-CHECKS-DRIFT`. The RED check exited 1.
  Canonical regeneration made both freshness checks exit 0.
- **Unresolved owned findings:** none.
- **Preserved external finding:** `BLOCKED-ON-REPO-WIDE-RED` remains unchanged.
  It still prevents BUG-037 terminal completion.

The next owner is `bubbles.test`. That phase owns focused and canonical test
verification. This IMPLEMENT phase records no certification claim.

## Scope: test — linked-test resolution refused execution - 2026-08-31

### Generated-chain freshness

**Phase:** test

**Claim Source:** executed

**Command:** current canonical `generate-validation-checks.sh --check`,
`generate-release-manifest.sh --check`, and SHA-256 identity checks.

**Exit Code:** 0

```text
BUG037_FRESHNESS_EVIDENCE_BEGIN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-validation-checks.sh --check
generate-validation-checks: OK — the committed closure map matches the derivation.
VALIDATION_CHECKS_FRESHNESS_EXIT=0
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-release-manifest.sh --check
Release manifest is current: 7.28.0 (930 managed files)
RELEASE_MANIFEST_FRESHNESS_EXIT=0
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 /usr/bin/shasum -a 256 bubbles/registry/validation-checks.yaml bubbles/release-manifest.json
6cd898e97227aa49d97ad5c3f9b61f56e765aef7cca258286f4938f93f602862  bubbles/registry/validation-checks.yaml
21db8754191b7d750c9cdf8df360ead5e87db27e06782b34e8ba182a6a69e154  bubbles/release-manifest.json
BUG037_FRESHNESS_EVIDENCE_END
```

**Result:** PASS. Both generated targets match their current derivations.

### Linked-test resolution

**Phase:** test

**Claim Source:** executed

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300
/opt/homebrew/bin/bash bubbles/scripts/scenario-test-resolve.sh
bugs/BUG-037-uservalidation-opt-out-acceptance --repo-root
/Users/pkirsanov/Projects/bubbles`

**Exit Code:** 1

```text
BUG037_LINK_RESOLUTION_EVIDENCE_BEGIN
scenario-test-resolve: FAIL — linked tests that do not resolve (Gate G057)
  MISSING-TITLE: SCN-B037-015 -> bubbles/scripts/generate-gate-coverage-map-selftest.sh#unimplemented
    the referenced file contains no test with this exact title
  MISSING-TITLE: SCN-B037-015 -> bubbles/scripts/generate-validation-checks-selftest.sh#unimplemented
    the referenced file contains no test with this exact title

scenario-test-resolve: 2 unresolved reference(s) of 16 checked.
SCENARIO_TEST_RESOLVE_EXIT=1
SCENARIO_TEST_RESOLVE_EXPECTED=0
SCENARIO_TEST_RESOLVE_OBSERVED=BLOCKED
BUG037_LINK_RESOLUTION_EVIDENCE_END
```

**Result:** FAIL. The resolver found two planning-owned `linkedTests.testId`
values that name no test title.

### Test-phase disposition

- `F-B037-TEST-LINK-001` remains unresolved. `SCN-B037-015` names
  `generate-gate-coverage-map-selftest.sh#unimplemented`.
- `F-B037-TEST-LINK-002` remains unresolved. `SCN-B037-015` names
  `generate-validation-checks-selftest.sh#unimplemented`.
- `F-B037-TEST-SKIP-003` remains unresolved. The existing S4-T3 evidence says
  `generate-gate-coverage-map-selftest.sh` skipped because PyYAML was absent.
  This TEST phase does not count that skip as a pass.
- The TEST phase did not execute focused tests after the mandatory linked-test
  resolver failed.
- `framework-validate` was not run. Its exit is `not-run`.
- `release-check` was not run. Its exit is `not-run`.
- `S4-T5` and `S4-T6` remain unchecked. Scope 4 remains blocked.
- No certification field, user-acceptance item, BUG-033 artifact, or BUG-042
  artifact changed.

The planning owner must replace both non-resolving titles with real test
identities. The TEST phase can then restart from linked-test resolution.

<a name="bug037-scope4-test-closeout"></a>

## Scope: test — Scope 4 durable-receipt closeout - 2026-09-01

This section appends the current TEST evidence. It does not erase the earlier
timeouts, refusals, or repository-wide red verdict. Those runs remain historical
facts. The current green receipts supersede them only for operative routing.

### Current receipt verification

**Phase:** test

**Claim Source:** executed

**Command:** bounded direct assertions over the three matching rows in
`.specify/runtime/tool-calls.jsonl` and the linked-reference count in
`scenario-manifest.json`.

**Exit Code:** 0

```text
BUG037_CURRENT_RECEIPT_VERIFICATION_BEGIN
SESSION=vscode-890b012efcd4029f1bbec9142330177b
SPEC=BUG-037-uservalidation-opt-out-acceptance
SCOPE=SCOPE-04
FOCUSED_TS=2026-09-01T05:30:17Z
FOCUSED_EXIT=0
FOCUSED_CHECK_COUNT=9
LINKED_REFERENCE_COUNT=16
FOCUSED_STDOUT_HASH=bd32b26244f096cc87ffacc8d5119a534e35ae7aaff0e85aa3825e824fbef3bc
FRAMEWORK_TS=2026-09-01T07:40:23Z
FRAMEWORK_EXIT=0
FRAMEWORK_DURATION_MS=7754651
FRAMEWORK_STDOUT_HASH=4d165462bbc85b63fc1efa82c17f61c0dde20d067deefbca6685021a8cd65185
FRAMEWORK_COMMAND_CANONICAL=true
RELEASE_TS=2026-09-01T09:40:09Z
RELEASE_EXIT=0
RELEASE_DURATION_MS=7142337
RELEASE_STDOUT_HASH=e3afcd00cacd8ef7d1738c65136b48341c410dc0abf0d4cdeac75b4068bfed71
RELEASE_COMMAND_CANONICAL=true
RECEIPT_ASSERTION_FAILURES=0
BUG037_CURRENT_RECEIPT_VERIFICATION_END
```

The focused row invokes nine checks and ends with an aggregate zero-failure
assertion. The structured row exits zero. Its capture contains 105 underlying
lines with SHA-256
`138dad28ee2610277f0cc9d3c612d43ab3f4a22d7123a907c40b750e30e8f277`.
It records `BUG037_FOCUSED_FAILURE_COUNT=0`. Linked references resolve 16 of 16.
All three freshness checks are green. The framework-health check is green.
Both generator selftests execute. The gate-map selftest does not skip.
Acceptance-authority and human-acceptance regression checks are green.

### S4-T5 current canonical framework validation

**Phase:** test

**Claim Source:** executed

**Structured evidence:** `.specify/runtime/tool-calls.jsonl`, timestamp
`2026-09-01T07:40:23Z`, current session, BUG-037, SCOPE-04.

**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label
BUG-037 Scope 4 canonical framework validation -- /opt/local/bin/gtimeout
--signal=TERM --kill-after=60s 21600 /opt/homebrew/bin/bash
bubbles/scripts/cli.sh framework-validate`

**Exit Code:** 0

```text
FRAMEWORK_RECEIPT_TS=2026-09-01T07:40:23Z
FRAMEWORK_RECEIPT_SESSION=vscode-890b012efcd4029f1bbec9142330177b
FRAMEWORK_RECEIPT_SPEC=BUG-037-uservalidation-opt-out-acceptance
FRAMEWORK_RECEIPT_SCOPE=SCOPE-04
FRAMEWORK_RECEIPT_EXIT=0
FRAMEWORK_RECEIPT_DURATION_MS=7754651
FRAMEWORK_RECEIPT_STDOUT_HASH=4d165462bbc85b63fc1efa82c17f61c0dde20d067deefbca6685021a8cd65185
FRAMEWORK_RECEIPT_STDERR_HASH=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
FRAMEWORK_RECEIPT_TAG=current-session
FRAMEWORK_RECEIPT_TAG=binding-revision-14
FRAMEWORK_RECEIPT_TAG=canonical-source-root
FRAMEWORK_RECEIPT_TAG=single-run
FRAMEWORK_CAPTURE_EXIT=0
FRAMEWORK_CAPTURE_LINES=19091
FRAMEWORK_CAPTURE_SHA256=81b4012dec8862a08f329f3627aaa85874a36a95baaaab82199d1837c27a96c5
FRAMEWORK_EXECUTED_CHECKS=348
FRAMEWORK_POLICY_DENYLISTED_SKIPS=2
FRAMEWORK_OWNED_TEST_SKIPS=0
FRAMEWORK_SIGNAL=Framework validation passed (2 skipped: 2 denylisted)
FRAMEWORK_FINAL_SIGNAL=Framework validation passed.
```

The two skips are policy-denylisted checks. They are not owned test skips.
The owned test skip count is zero. This distinction preserves the exact result.

### S4-T6 current canonical release check

**Phase:** test

**Claim Source:** executed

**Structured evidence:** `.specify/runtime/tool-calls.jsonl`, timestamp
`2026-09-01T09:40:09Z`, current session, BUG-037, SCOPE-04.

**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label
BUG-037 Scope 4 canonical release check -- /opt/local/bin/gtimeout
--signal=TERM --kill-after=60s 28800 /opt/homebrew/bin/bash
bubbles/scripts/cli.sh release-check`

**Exit Code:** 0

```text
RELEASE_RECEIPT_TS=2026-09-01T09:40:09Z
RELEASE_RECEIPT_SESSION=vscode-890b012efcd4029f1bbec9142330177b
RELEASE_RECEIPT_SPEC=BUG-037-uservalidation-opt-out-acceptance
RELEASE_RECEIPT_SCOPE=SCOPE-04
RELEASE_RECEIPT_CWD=/Users/pkirsanov/Projects/bubbles
RELEASE_RECEIPT_EXIT=0
RELEASE_RECEIPT_DURATION_MS=7142337
RELEASE_RECEIPT_STDOUT_HASH=e3afcd00cacd8ef7d1738c65136b48341c410dc0abf0d4cdeac75b4068bfed71
RELEASE_RECEIPT_STDERR_HASH=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
RELEASE_RECEIPT_TAG=current-session
RELEASE_RECEIPT_TAG=binding-revision-19
RELEASE_RECEIPT_TAG=canonical-source-root
RELEASE_RECEIPT_TAG=single-run
RELEASE_RECEIPT_FRAMEWORK=bubbles
RELEASE_RECEIPT_FRAMEWORK_VERSION=7.28.0
RELEASE_RECEIPT_COMMAND_CANONICAL=true
```

This row proves the canonical source command completed with exit zero. It also
proves the duration, hashes, tags, and working directory shown above. This
section attributes no additional output line to the release run.

### TEST finding accounting and routing

- `F-B037-TEST-LINK-001` is resolved. The current linked-test check exits zero.
- `F-B037-TEST-LINK-002` is resolved by the same 16-of-16 resolution.
- `F-B037-TEST-SKIP-003` is resolved. The gate-map selftest executed without a
  skip, and the focused matrix reports zero owned test skips.
- `BLOCKED-ON-REPO-WIDE-RED` is resolved as an operative blocker. The current
  framework and release receipts both exit zero. Its original red evidence and
  text remain preserved in this report and in `state.json`.
- No finding discovered by this TEST closeout remains unresolved.

The persisted `bugfix-fastlane` order routes next to `bubbles.regression`.
This TEST phase makes no node-completion, bug-completion, or certification claim.

<a name="bug037-regression-phase"></a>

## Scope: regression — current-session compatibility review - 2026-09-01

This section records the completed regression phase from existing receipts.
It does not rerun any regression, framework-validation, or release command.

### Receipt interval and source integrity

**Phase:** regression

**Claim Source:** executed

**Structured evidence:** `.specify/runtime/tool-calls.jsonl` rows 257 through
270, inclusive.

**Exit Code:** 0 for every row.

```text
RECEIPT_INTERVAL=257-270
RECEIPT_COUNT=14
STARTED_AT=2026-09-01T16:03:14Z
COMPLETED_AT=2026-09-01T16:14:14Z
ALL_EXIT_ZERO=true
IDENTITY_MATCH=true
INPUT_CLOSURES_PRESENT=true
NON_BOOKKEEPING_CLOSURE_PATH_COUNT=43
NON_BOOKKEEPING_CLOSURE_MISSING_COUNT=0
NON_BOOKKEEPING_CLOSURE_HASH_MISMATCH_COUNT=0
SOURCE_EDIT_SHAPED_COMMAND_COUNT=0
```

All rows name the current session, `bubbles.regression`, BUG-037, and SCOPE-04.
The closure check compared current bytes with each path's last recorded hash.
It found no missing path or changed non-bookkeeping input.
The command audit found no source-edit-shaped command.

### Exhaustive finding accounting

| Row | Regression check | Exit | stdout SHA-256 | New findings |
|---:|---|---:|---|---:|
| 257 | Acceptance-authority full compatibility | 0 | `27f87059ec871d59131ef498b8463be837ddd7f8444c9e4306b103a540abf53b` | 0 |
| 258 | Persistent G136 and BUG-029 regression | 0 | `c94fa20efc5715e56ee9cb35d1cc04f33731c6704e0c6bdc8974d7fb5cac152e` | 0 |
| 259 | Regression-quality and adversarial guard | 0 | `74d100cb4e0bc546e0e71ad4c1bda759f500d76f9a36ee97a67c6b10c793e17d` | 0 |
| 260 | Linked scenario resolution | 0 | `4d26dafd1918cc5fe7937e452c8b49afbb24e38a8e44f4b2b0b08c5dc6deb1b8` | 0 |
| 261 | Validation-registry freshness | 0 | `604971ec9fbadec89c4d9385bbc0ff887c85cbf6408c47a0b239edb00f844174` | 0 |
| 262 | Gate-coverage-map freshness | 0 | `1701e230e9c240983a0f1c2a8c4b3005b1d886bfe596afb6b7e2c41e4256a7d1` | 0 |
| 263 | Release-manifest freshness | 0 | `a4f2ebb5300a18c88ff2f8fe0f5907114a23720507c1a76a79a52e7e6147e7ef` | 0 |
| 264 | Canonical G044 baseline guard | 0 | `2d0c70fbf984a2dbcb8b575fcf2e4f20edb167e692822e623a26bc10b4d700a9` | 0 |
| 265 | Domain-model consistency | 0 | `3e256f55afe63dbd06ccb9baf6d664e1dc21da41a90c2e72ec1458670c54100c` | 0 |
| 266 | Expand-migrate-contract applicability | 0 | `9c39deba1df59f4047a606c34bd955df345dc40afdf1a4c3ed4fb68b759dbbed` | 0 |
| 267 | Actual BUG-032 compatibility and read-only proof | 0 | `73635d0e5d9020229a466220433f957d08de8128dd1c191ab97ae43a3944a8ed` | 0 |
| 268 | Pre-bookkeeping state invariants | 0 | `76cd59ad7c2da760d7838d5a51e72d349c1727400df133429615b4c3dd2ac0d4` | 0 |
| 269 | Technical-prose baseline | 0 | `77b7b671e74996619abece2dd34ac7185a32370931c11dfee3a05b0da4f2f5d1` | 0 |
| 270 | BUG-032 G101 cross-spec compatibility | 0 | `01155aa4c04e9cf7c8048cafb963e7a7ca25fb91aab935dd31ecb3f04ef21dee` | 0 |

Every executed regression check produced zero new findings. Therefore,
`addressedFindings` and `unresolvedFindings` are both empty for this phase.

### Regression disposition

The regression phase is execution-complete. All four scopes remain
execution-done and uncertified. Top-level status and certification remain
`in_progress`, and `certifiedAt` remains null. The bug and scenario node remain
incomplete. The next required owner is `bubbles.simplify`.

<a name="bug037-simplify-phase"></a>

## Scope: simplify — no-change review - 2026-09-01

### Decision

**Phase:** simplify

**Claim Source:** interpreted

**Interpretation:** Three focused review passes found no safe, useful reduction
in the BUG-037 implementation. This phase changed no source, test, generated,
human-acceptance, BUG-029, or BUG-032 file. It changed only this report section
and BUG-037 execution bookkeeping in `state.json`.

### Three-pass review

| Pass | Findings | Decision |
| --- | ---: | --- |
| Code reuse | 0 | The only checklist section-parser definitions found in the reviewed files are the two shared readers in `acceptance-authority-lib.sh`. The regression test continues to source that library. |
| Code quality | 0 | The registry-gated `requiredAtTerminal` branch is not dead compatibility code. S1-T8 proves the downstream override path, while the shipped registry keeps the record optional. The unreferenced readiness-section helper already exists at `HEAD`; deleting a sourceable downstream API without a consumer inventory is outside this delta. |
| Efficiency | 0 | The repeated assertions are distinct negative controls for BUG-029 closure, optional-record validation, template-to-registry agreement, and guard read-only behavior. Removing them would reduce diagnostic coverage rather than implementation complexity. |

Generated outputs were not edited. The governance restatements remain because
the packet requires those public surfaces to agree with the registry and guard.

### Current-byte review evidence

**Phase:** simplify

**Claim Source:** executed

**Structured evidence:** `.specify/runtime/tool-calls.jsonl` row 272.

**Exit Code:** 0

```text
BUG037_SIMPLIFY_REVIEW_BEGIN
PASS_1_REUSE_BEGIN
PARSER_DEFINITION_SEARCH_EXIT=0
PARSER_DEFINITION_COUNT=2
PASS_1_REUSE_END
PASS_2_QUALITY_BEGIN
QUALITY_CONTRACT_SEARCH_EXIT=0
PREEXISTING_UNUSED_CANDIDATE_SEARCH_EXIT=0
PASS_2_QUALITY_END
PASS_3_EFFICIENCY_BEGIN
LOAD_BEARING_BRANCH_COVERAGE_SEARCH_EXIT=0
PASS_3_EFFICIENCY_END
FOREIGN_BOUNDARY_STATUS_EXIT=0
FOREIGN_BOUNDARY_CHANGED_LINE_COUNT=0
IMPLEMENTATION_MANIFEST_SHA256=08c6e448d4fe61ca3242d3809be3ac8574830cf08073b3cddbf50b6658f9c6ce
SIMPLIFY_REVIEW_FAILURES=0
BUG037_SIMPLIFY_REVIEW_END
```

The first capture attempt, row 271, exited 1 because its in-memory manifest
separator was malformed. It changed no repository file. Row 272 corrected the
command and completed the same review. This execution issue is fixed in this
phase and is not a BUG-037 implementation finding.

### Receipt preservation and routing

The current TEST receipts are rows 254 through 256. The current regression
receipts are rows 257 through 270. This phase read those rows and made no
implementation or generated mutation, so it did not invalidate their input
bytes. It did not rerun framework validation or release checks.

No simplify finding remains open. Top-level status and certification remain
`in_progress`. All certified flags remain false. Human acceptance is unchanged.
The bug and scenario node remain incomplete. The next required owner is
`bubbles.gaps`.

<a name="bug037-gaps-phase"></a>

## Scope: gaps — implementation fidelity review - 2026-09-01

This phase compared every BUG-037 acceptance requirement, scenario, design
decision, scope DoD item, linked test, generated target, and migration claim
against the current implementation. It changed no source, test, generated,
human-acceptance, BUG-029, or BUG-032 file.

### Current implementation checks

**Phase:** gaps

**Claim Source:** executed

**Structured evidence:** `.specify/runtime/tool-calls.jsonl` rows 283 through
288.

The focused matrix ran eleven checks. Ten exited zero. The only failure came
from passing the packet directory to `regression-quality-guard.sh`, which
accepts test files or test directories. Row 284 corrected the invocation over
the six planned test files and exited zero with 0 violations and 0 warnings.
The matrix otherwise established these current results:

- acceptance authority and the persistent G136 regression execute cleanly;
- all sixteen scenario links resolve to real test titles;
- all three generated targets match their generators;
- both generator selftests and the release-manifest selftest execute cleanly;
- the implementation-reality scan examines 42 design-resolved files and finds
  0 violations;
- the reality scan emits one planning-shape warning because `scopes.md` lacks
  canonical `### Implementation Files` sections and requires its design
  fallback.

The initial semantic diagnostic at row 285 stopped on a malformed in-memory
newline substitution. It changed no file. Row 286 corrected the diagnostic and
completed the comparison.

### Gap findings

**Claim Source:** executed

Rows 286 through 288 establish the following ten findings. Green test exits do
not close them because the findings concern semantic coverage, fail-closed
behavior, and contract coherence rather than test-title existence.

| Finding | Class | Severity | Concrete discrepancy | Required owner |
| --- | --- | --- | --- | --- |
| F-B037-GAPS-LINK-003 | PARTIAL | high | `SCN-B037-003` requires one checked plus five unchecked items and requires all five names. Its linked regression title covers two unchecked items. The exact five-item assertion exists in `acceptance-authority-selftest.sh` but is not the linked test. | `bubbles.plan`, then `bubbles.test` |
| F-B037-GAPS-LINK-015 | UNTESTED | high | `SCN-B037-015` names three generated artifacts, including `bubbles/release-manifest.json`, but links only the gate-map and validation-check generator selftests. The executed release-manifest selftest has no scenario link. | `bubbles.plan`, then `bubbles.test` |
| F-B037-GAPS-S2T8 | PARTIAL | high | S2-T8 promises that the change modifies no foreign `uservalidation.md`. Its persistent check detects only an unchecked-to-checked item transition. Other foreign-file edits satisfy the test. | `bubbles.test` |
| F-B037-GAPS-S4T4 | PARTIAL | medium | S4-T4 requires the corrected BUG-029 changelog entry. Its check requires global BUG-037, PD-12, and migration-note text and only rejects one stale phrase. Deleting the BUG-029 entry satisfies the check. | `bubbles.test` |
| F-B037-GAPS-S4T8 | PARTIAL | medium | S4-T8 requires all three D-3 rules and their mechanical/advisory split. Its check requires only the word `advisory` and proves the enforcer does not read `uservalidation.md`. Removing any of the three rules satisfies the check. | `bubbles.test` |
| F-B037-GAPS-S4T2 | PARTIAL | medium | GC-2 requires G136 to describe its sections, refusal codes, and done-only condition. S4-T2 checks code-set membership and absence of two stale phrases, but not the three sections or terminal condition. | `bubbles.test` |
| F-B037-GAPS-D5 | DIVERGENT | high | D-5 says `PD12-NO-RECORD` is retired because no path can emit it. The library retains an emitter, S1-T8 deliberately executes it when `requiredAtTerminal` is true, and the code is absent from the registry's closed `failureCodes` set. | `bubbles.design` |
| F-B037-GAPS-FAILCLOSED | PARTIAL | high | Pointing the production reader at a missing acceptance registry returns exit 0 with no finding for a checked BUG-037 artifact. Missing authority therefore degrades to acceptance rather than refusing. | `bubbles.plan`, then `bubbles.implement` and `bubbles.test` |
| F-B037-GAPS-RECORD-AUTHORSHIP | PARTIAL | medium | `bubbles_acceptance_record_authored()` examines only required fields. A real method-conditional field in an otherwise placeholder record is treated as an untouched template, so present-record validation does not run. | `bubbles.plan`, then `bubbles.implement` and `bubbles.test` |
| F-B037-GAPS-MIGRATION | DIVERGENT | medium | The upgrade note says any pre-cutover `uservalidation.md` ships unchecked. The design inventory records BUG-032 as pre-PD-12 and checked. The note overstates the affected population and contradicts D-1's own evidence. | `bubbles.design`, then `bubbles.docs` |

The current BUG-029 and BUG-032 acceptance artifacts have zero worktree
changes. The findings above do not reopen either bug and do not authorize any
edit to their packets.

### Finding accounting and routing

- Addressed invocation findings: `F-B037-GAPS-HARNESS-001` was corrected by
  row 284. `F-B037-GAPS-HARNESS-002` was corrected by row 286.
  `F-B037-GAPS-HARNESS-003`, a shell-quoting error before the first
  post-bookkeeping matrix could execute, was corrected by row 289.
- Unresolved BUG-037 findings: the ten rows in the table above.
- Source, test, generated, user-acceptance, and certification mutations: none.
- Scope execution status remains done for all four scopes. Certification stays
  `in_progress`, `certifiedAt` stays null, and every certified flag stays false.

Row 289 then ran the required post-bookkeeping checks. Artifact lint, technical
prose lint, JSON and state invariants, 16-of-16 linked-test resolution, diff
whitespace validation, and both strict work-boundary checks all exited zero.

The first required owner is `bubbles.design`, because D-5 and the D-1 upgrade
note contain contradictory active design claims. Planning must then align the
scenario links and add the fail-closed and partial-record cases. Implementation
and TEST own the resulting code and persistent coverage. Broad TEST evidence
must be re-executed after any source, test, generated, or planning-contract
mutation.

<a name="bug037-design-remediation"></a>

## Scope: design remediation — failure-code and migration contracts - 2026-09-01

### Reconciliation basis

**Phase:** design

**Claim Source:** interpreted

**Interpretation:** The remediation compared D-1 and D-5 with the current
registry, shared reader, guard, focused selftests, persistent regression, and
changelog. It changed only `design.md`, this append-only report section, and
BUG-037 execution bookkeeping in `state.json`.

### Failure-code lifecycle decision

`PD12-NO-RECORD` is conditionally active, not retired. The shipped
`requiredAtTerminal: false` value keeps opt-out acceptance unchanged. A
downstream `true` override activates the refusal without forking the library.

The canonical `failureCodes` set must declare every supported source emission.
S1-T10 may not exempt an undeclared source literal. Missing, unreadable, or
malformed authority must fail closed with the planned bootstrap code
`PD12-AUTHORITY-UNAVAILABLE`.

This decision resolves the contradiction in D-5. It does not claim that the
current registry, source, documentation, or tests already implement the
reconciled contract.

### Legacy migration decision

D-1 now defines four classes: current opt-out, legacy pre-PD-12 checked, legacy
PD-12 unchecked, and legacy provenance unknown. The contract that scaffolded
the checklist determines its class. A cutover date or current checkbox bytes
alone cannot determine user intent.

Unknown provenance fails closed. The packet stays `in_progress`, and
automation leaves checkbox state unchanged until the artifact owner resolves
provenance with the user. No bulk migration script ships.

This decision resolves the contradiction in D-1. It does not claim that the
current changelog upgrade note already describes the four classes.

### Finding accounting and planning route

Exactly two gaps findings are resolved by this design slice:

- `F-B037-GAPS-D5`
- `F-B037-GAPS-MIGRATION`

The following eight findings remain open and unchanged:

- `F-B037-GAPS-LINK-003` — owner `bubbles.plan`, then `bubbles.test`
- `F-B037-GAPS-LINK-015` — owner `bubbles.plan`, then `bubbles.test`
- `F-B037-GAPS-S2T8` — owner `bubbles.test`
- `F-B037-GAPS-S4T4` — owner `bubbles.test`
- `F-B037-GAPS-S4T8` — owner `bubbles.test`
- `F-B037-GAPS-S4T2` — owner `bubbles.test`
- `F-B037-GAPS-FAILCLOSED` — owner `bubbles.plan`, then
  `bubbles.implement` and `bubbles.test`
- `F-B037-GAPS-RECORD-AUTHORSHIP` — owner `bubbles.plan`, then
  `bubbles.implement` and `bubbles.test`

`bubbles.plan` must make four immediate planning corrections. Link
`SCN-B037-003` to the exact five-unchecked-item assertion. Link
`SCN-B037-015` to release-manifest regeneration coverage. Add fail-closed
registry cases. Add present-record authorship cases for real
method-conditional fields.

The plan must also apply both resolved decisions. It must restore
`PD12-NO-RECORD` to the declared conditional set, replace the S1-T10 exception,
and add bootstrap authority-failure coverage. It must classify all legacy
migration cases and require the changelog to replace its one-bucket warning.

The plan must preserve the four test-owned findings for `bubbles.test`. It must
not change completed DoD checkboxes during planning. Source, registry, test,
generated, changelog, acceptance, and certification changes remain unclaimed.

<a name="bug037-planning-remediation"></a>

## Scope: planning remediation — D-1 and D-5 contract handoff - 2026-09-01

### Summary

**Phase:** plan

**Claim Source:** interpreted

**Interpretation:** This slice reconciled the planning contract only. It changed
`spec.md`, `scopes.md`, `scenario-manifest.json`, `test-plan.json`, this
append-only report, and execution routing in `state.json`.

The plan now declares `PD12-NO-RECORD` as conditional-active. It declares
`PD12-AUTHORITY-UNAVAILABLE` as bootstrap-active. It defines exact fail-closed
output and return semantics for every authority failure class.

The plan defines authored-record detection across base and method-specific
fields. Empty values and complete bracket placeholders remain inert. Any other
recognized value triggers complete present-record validation.

The migration contract now distinguishes four provenance classes. It forbids
bulk migration and preserves unknown-provenance bytes. It keeps ambiguous
packets `in_progress` until the owner resolves provenance with the user.

### Scenario and test-link reconciliation

`SCN-B037-003` now links to two existing exact identities. S1-T3 proves the
shared reader refuses one checked plus five unchecked items and names all five.
S3-T3 proves the same shape through the real Check 43 consumer.

`SCN-B037-015` now links to the existing release-manifest selftest scenario.
That link complements the existing gate-map and validation-check generator
links. The three generated targets now have explicit planned coverage.

`SCN-B037-016`, `SCN-B037-017`, and `SCN-B037-019` name tests that do not exist
yet. Their manifest entries use `testState: planned-not-authored` and the
framework's `__FUTURE_TEST__` title sentinel. Each entry also records exact
planned identities. The sentinel prevents a planning packet from pretending
that an absent title already resolved.

The linked-test resolver reported 22 resolved references. It also reported 19
category comparisons as not applicable because this repository declares no
test-discovery adapter. This result proves path and existing-title resolution.
It does not prove that planned tests ran.

### Historical execution and certification posture

All four scope execution statuses remain `done`. Every certification flag stays
false. Existing checked DoD items remain unchanged as historical receipts.

Nine amended scenario obligations are unchecked. Each carries an Uncertainty
Declaration. `state.json` remains `in_progress` with
`execution.substate: needs_reverification` and `requiresRevalidation: true`.

Prior broad framework-validation and release-check receipts remain historical.
The planned source, registry, test, changelog, and generated changes require new
focused and broad evidence.

### Finding accounting

This planning slice resolved exactly two prior findings:

- `F-B037-GAPS-LINK-003`.
- `F-B037-GAPS-LINK-015`.

Seven findings remain open:

- `F-B037-GAPS-FAILCLOSED` — `bubbles.implement`.
- `F-B037-GAPS-RECORD-AUTHORSHIP` — `bubbles.implement`.
- `F-B037-PLAN-D1-D5-SYNC` — `bubbles.implement`.
- `F-B037-GAPS-S2T8` — `bubbles.test`.
- `F-B037-GAPS-S4T2` — `bubbles.test`.
- `F-B037-GAPS-S4T4` — `bubbles.test`.
- `F-B037-GAPS-S4T8` — `bubbles.test`.

The new `F-B037-PLAN-D1-D5-SYNC` finding preserves cross-surface work exposed
by the reconciled design. It covers registry, source, changelog, gate prose,
generated projections, and focused-test synchronization.

### Focused planning validation

**Phase:** plan

**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 1200 /opt/homebrew/bin/bash /private/tmp/bug037-planning-validation.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
# BUG-037 planning remediation focused validation matrix GREEN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 1200 /opt/homebrew/bin/bash /private/tmp/bug037-planning-validation.sh
exit: 0
lines: 345
sha256: 40425d88155521f4fd2490fe148d9c03836f5d79940760e86d0a9ab52acb73a5
--- first 20 ---
CHECK_BEGIN=json-state
CHECK_EXIT json-state=0
CHECK_BEGIN=json-scenarios
CHECK_EXIT json-scenarios=0
CHECK_BEGIN=json-test-plan
CHECK_EXIT json-test-plan=0
CHECK_BEGIN=scenario-links
[scenario-test-resolve] OK — 22 reference(s) resolved via literal-scan; 19 category comparison(s) not applicable (no test-discovery adapter declared)
CHECK_EXIT scenario-links=0
CHECK_BEGIN=scenario-obligations
[scenario-obligation-lint] OK — 19 scenario(s) with a coherent derived obligation matrix
CHECK_EXIT scenario-obligations=0
CHECK_BEGIN=artifact-lint
--- omitted 305 line(s); sha256 above covers the full output ---
--- last 20 ---
CHECK_EXIT boundary:bugs/BUG-037-uservalidation-opt-out-acceptance/scenario-manifest.json=0
CHECK_BEGIN=boundary:bugs/BUG-037-uservalidation-opt-out-acceptance/report.md
disposition=in-boundary
repoMatch=true
reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
CHECK_EXIT boundary:bugs/BUG-037-uservalidation-opt-out-acceptance/report.md=0
CHECK_BEGIN=boundary:bugs/BUG-037-uservalidation-opt-out-acceptance/state.json
disposition=in-boundary
repoMatch=true
reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
CHECK_EXIT boundary:bugs/BUG-037-uservalidation-opt-out-acceptance/state.json=0
PLANNING_VALIDATION_FAILURES=0
```

Tool-log row 296 records this run with exit `0`, duration `13030ms`, stdout
hash `569f93b822b361497e42834d029c8ea97f39cf56495e57524721ef1da23d392f`,
and 15 current input-closure entries.

The report-only prose check emitted 27 over-long-sentence findings and 37
semicolon findings across `spec.md` and `scopes.md`. It exited `0` by contract.
This report does not relabel those findings as a clean prose verdict.

The first recorded matrix at tool-log row 295 exited `1`. Artifact lint found
nine scenarios without faithful DoD items. The plan added nine unchecked items
with Uncertainty Declarations and changed no completed checkbox. Row 296 then
exited `0`.

<a name="bug037-implementation-remediation"></a>

## Scope: implementation remediation — D-1 and D-5 current-byte closure - 2026-09-01

### Summary

**Phase:** implement

**Claim Source:** executed

The goal-node binding remained scoped to repository `bubbles`, node
`reconcile-bug-037-validation-registry`, session
`vscode-d6173f50fde08e4fc6fdf133dac19e92`, and control revision `1`.
Repository packet validation returned exit `0` before any local inspection.

The fail-closed authority preflight, union-field authorship predicate, failure
code declarations, and aligned gate prose were already present in the dirty
checkout when this invocation began. This invocation does not claim authorship
of those inherited bytes. It re-read them and executed their planned cases on
the current files.

This invocation changed the implementation-owned focused selftest, the BUG-037
changelog entry, and the generated release manifest. It added exact conditional
code cardinality under S1-T10 and structural S4-T10 checks for all four migration
classes. It changed the changelog heading from "No bulk migration script" to
"No migration script exists, and no bulk migration script will be shipped" so
the existing S4-T4 assertion and the stronger S4-T10 contract both apply.

No `uservalidation.md`, BUG-029 packet, BUG-032 packet, BUG-033 packet,
downstream repository, certification field, terminal status, session mirror, or
session lock was changed.

### RED — current bytes before the focused edit

**Phase:** implement

**Claim Source:** executed

**Command:** stock/Homebrew Bash matrix, stopping at its first non-zero case

**Exit Code:** 1

```text
# BUG-037 remediation pre-edit cross-shell first-failure matrix
exit: 1
lines: 58
sha256: f9ae8a7729f75067514460e5560ddb44fbeabb49b4c22566ef33f52a1f569cc5
BUG037_PREEDIT_MATRIX_BEGIN
CASE_BEGIN=stock-acceptance-authority
  ok   S1-T11 SCN-B037-016: missing authority fails closed
  ok   S1-T12 SCN-B037-016: unreadable authority fails closed
  ok   S1-T13 SCN-B037-016: malformed authority fails closed
  FAIL S4-T4 changelog records the contract change
       missing: D-1-upgrade-note
acceptance-authority-selftest: 47/48 checks passed
acceptance-authority-selftest: FAILED
CASE_EXIT name=stock-acceptance-authority exit=1
FIRST_FAILURE=stock-acceptance-authority
BUG037_PREEDIT_MATRIX_END
```

Tool-log row 303 records the command at exit `1`. The exact first failure was
S4-T4 in the stock-Bash authority selftest. The failure was reproduced rather
than inferred from inherited evidence.

### Current-byte implementation proof

**Phase:** implement

**Claim Source:** executed

The narrow stock-Bash rerun completed after two test-helper micro-fixes. The
first exposed line-wrap sensitivity in S4-T10. The second exposed a current-class
selector whose negative control did not mutate the intended paragraph. Both
were corrected before broader execution.

```text
# BUG-037 remediation narrow stock Bash authority selftest after selector fix
exit: 0
lines: 57
sha256: ff6a840c53c6efbb5cb4ef4171093a179a7d29784eb3ddc77eb53e4f7ac2a86b
  ok   S1-T11 SCN-B037-016: missing authority fails closed
  ok   S1-T12 SCN-B037-016: unreadable authority fails closed
  ok   S1-T13 SCN-B037-016: malformed authority fails closed
  ok   S4-T10 SCN-B037-019: the changelog distinguishes all four migration classes
  ok   S4-T10a SCN-B037-019: unknown provenance preserves bytes and remains in progress
  ok   S4-T10b SCN-B037-019: no bulk acceptance migration script exists
  ok   S4-T10c ADVERSARIAL: deleting any migration-class paragraph is detected
acceptance-authority-selftest: 53/53 checks passed
acceptance-authority-selftest: OK
```

Tool-log row 306 records this narrow run at exit `0`.

The final focused matrix ran the authority selftest and persistent G136
regression under both macOS stock Bash and Homebrew Bash. The command hashed 17
covered files before and after execution. All four cases returned zero, the
aggregate command returned zero, and the two hash manifests were identical.

```text
# BUG-037 stable current-byte stock and Homebrew Bash focused matrix
exit: 0
lines: 191
sha256: ed2208523031edd59008097238b82d74897f94e4ef3fc039698993648d073fc5
CASE_BEGIN=stock-acceptance-authority
CASE_EXIT name=stock-acceptance-authority exit=0
CASE_BEGIN=homebrew-acceptance-authority
CASE_EXIT name=homebrew-acceptance-authority exit=0
CASE_BEGIN=stock-human-acceptance-regression
CASE_EXIT name=stock-human-acceptance-regression exit=0
CASE_BEGIN=homebrew-human-acceptance-regression
CASE_EXIT name=homebrew-human-acceptance-regression exit=0
COVERED_BYTES_STABLE=true
BUG037_FOCUSED_MATRIX_END
```

Tool-log row 308 records the matrix at exit `0`, duration `17073ms`, and 22
current input-closure entries. Its test identities cover S1-T10 through S1-T18,
S2-T3 through S2-T5, S4-T10 through S4-T10c, and the persistent G136 regression.

### Generated projections and focused validation

**Phase:** implement

**Claim Source:** executed

The three packet-declared generators ran through their owning scripts.

```text
BUG037_GENERATION_BEGIN
GENERATOR_BEGIN=gate-coverage
generate-gate-coverage-map: no change (121 gates mapped)
GENERATOR_EXIT name=gate-coverage exit=0
GENERATOR_BEGIN=validation-checks
generate-validation-checks: wrote /Users/pkirsanov/Projects/bubbles/bubbles/registry/validation-checks.yaml
GENERATOR_EXIT name=validation-checks exit=0
GENERATOR_BEGIN=release-manifest
Updated release manifest: 7.28.0 (930 managed files)
GENERATOR_EXIT name=release-manifest exit=0
BUG037_GENERATION_END
```

Tool-log row 307 records exit `0`, duration `80838ms`, and evidence-capture
sha256 `636dfdae0766128aa41654e88a3a48ef77dd378f7e50935b3bc937076d697f2d`.
The gate map and validation registry were byte-identical before and after. The
release manifest changed to capture the current managed-file checksums.

The focused validation command then ran dual-Bash syntax checks, all three
generator `--check` modes, all three generator freshness selftests, artifact
lint for this packet, and `git diff --check` for the declared path set.

```text
# BUG-037 focused generators syntax artifact lint and diff checks
exit: 0
lines: 119
sha256: 7f7d912deac4714e77114125600d2f97d4a7d72c7645ee40f09abe9cf5005e69
CASE_BEGIN=stock-lib-syntax
CASE_EXIT name=stock-lib-syntax exit=0
CASE_BEGIN=homebrew-selftest-syntax
CASE_EXIT name=homebrew-selftest-syntax exit=0
generate-gate-coverage-map: docs/generated/gate-coverage-map.md is in sync (121 gates mapped)
generate-validation-checks: OK — the committed closure map matches the derivation.
Release manifest is current: 7.28.0 (930 managed files)
Artifact lint PASSED.
CASE_EXIT name=artifact-lint exit=0
CASE_EXIT name=diff-check exit=0
BUG037_FOCUSED_VALIDATION_END
```

Tool-log row 309 records exit `0`, duration `106500ms`, and 23 current
input-closure entries. No `framework-validate` or `release-check` command ran in
this implementation slice.

### Finding accounting and route

**Phase:** implement

**Claim Source:** executed

Addressed implementation findings:

- `F-B037-GAPS-FAILCLOSED` — S1-T11 through S1-T15 exercise both public
  verdicts across all five authority-failure classes. Each case requires exit
  `1` and exactly one `PD12-AUTHORITY-UNAVAILABLE` line.
- `F-B037-GAPS-RECORD-AUTHORSHIP` — S1-T16 through S1-T18 exercise union-field
  authorship, inert empty and complete-bracket defaults, and both method schemas.
- `F-B037-PLAN-D1-D5-SYNC` — the current authority, reader, gate prose, and
  lifecycle declarations agree; the four migration classes are published;
  S1-T10 and S4-T10 are implemented; and all three projections were regenerated.

Unresolved findings, preserved one-for-one for `bubbles.test`:

- `F-B037-GAPS-S2T8`.
- `F-B037-GAPS-S4T2`.
- `F-B037-GAPS-S4T4`.
- `F-B037-GAPS-S4T8`.

The focused selftest returning zero does not close those four assertion-fidelity
findings. Their current assertions remain weaker than the reconciled Test Plan.
The packet and certification remain `in_progress`; the next required owner is
`bubbles.test`.

### Post-bookkeeping validation

**Phase:** implement

**Claim Source:** executed

```text
# BUG-037 post-bookkeeping Tier 1 and Implement profile checks
exit: 0
lines: 98
sha256: 985c3b0709d299eaa92c531ec2e79bab3c5f53e02316c6da4f11de8edf4a3a51
CASE_BEGIN=state-json
true
CASE_EXIT name=state-json exit=0
CASE_BEGIN=artifact-lint
Artifact lint PASSED.
CASE_EXIT name=artifact-lint exit=0
SOURCE_HASH_FAILURES=0
NEIGHBOR_PACKET_STATUS_END
TARGET_STATUS_END
BUG037_POST_BOOKKEEPING_END
```

Tool-log row 310 records exit `0`, duration `83207ms`, stdout hash
`91b7126f1f76d8c4c058395312cfc7b829829212bf9b75fd7b1c14ac0c0787c0`,
and 13 input-closure entries. The state assertion required exactly four open
findings, all owned by `bubbles.test`. It required the three implementation
findings to be resolved, `execution.substate` to equal `implemented`, and every
certification flag to remain false. The same command rechecked all three
generated targets, artifact lint, diff whitespace, and the nine current source
hashes from the green matrix.

<a name="bug037-test-assertion-fidelity-remediation"></a>

## Scope: TEST assertion-fidelity remediation - 2026-09-01

### Summary

**Phase:** test

**Claim Source:** executed

The invocation validated this exact repository binding before reading the
packet or running a repository command:

- `repositoryRoot`: canonical `bubbles` source checkout
- `repositoryAlias`: `bubbles`
- `sessionId`: `vscode-d6173f50fde08e4fc6fdf133dac19e92`
- `decisionId`: `rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:1:node:reconcile-bug-037-validation-registry`
- `controlRevision`: `1`
- `controlPathDigest`: `sha256:31af946ba99c9cc0dfa9f0c87a9a2e2ef4232d504026d42c7302fffb144ec8fe`
- `authority`: `scoped-scenario-node`
- `transition`: `scoped-override`
- `scopeKind`: `goal-node`
- `scopeId`: `reconcile-bug-037-validation-registry`
- `targetKind`: `goal-node`
- `pathVisibility`: `local`
- `actionable`: `true`

The packet validator returned exit `0`. The test edit touched only
`bubbles/scripts/acceptance-authority-selftest.sh`. It strengthened S2-T8,
S4-T2, S4-T4, and S4-T8 without changing production behavior.

### RED - missing assertion mechanisms

**Phase:** test

**Claim Source:** executed

Tool-log row 311 records exit `1`. The original focused selftest passed its
existing 53 checks, but the assertion-fidelity probe found all eight required
mechanism signals absent.

```text
# BUG-037 four-finding assertion-fidelity RED
exit: 1
lines: 68
sha256: 89ce706d8b7a7948fc2ec218cf944414f92bc7ace3c89e6433ab094041dbc73e
RED_MISSING_ASSERTION=delivery_range_foreign_uservalidation_findings
RED_MISSING_ASSERTION=G136-SECTION-MISSING
RED_MISSING_ASSERTION=G136-DONE-SCOPE-MISSING
RED_MISSING_ASSERTION=G136-CODE-SET-MISMATCH
RED_MISSING_ASSERTION=CHANGELOG-BUG029-CORRECTION-MISSING
RED_MISSING_ASSERTION=G057-RULE-1-MISSING
RED_MISSING_ASSERTION=G057-ADVISORY-CLASSIFICATION-MISSING
RED_MISSING_ASSERTION=G057-ENFORCER-READS-USERVALIDATION
RED_MISSING_ASSERTION_COUNT=8
BUG037_ASSERTION_FIDELITY_RED_END
```

### GREEN - final current-byte focused matrix

**Phase:** test

**Claim Source:** executed

Tool-log row 316 records the final focused matrix at exit `0`. Both Bash
runtimes executed the 71-check authority selftest and the 13-check persistent
G136 regression. The selected tests contained no skip marker.

```text
# BUG-037 final current-byte dual-Bash acceptance matrix
exit: 0
lines: 192
sha256: 006277e8184435276c5c3228808e687b7938ef38d7b324691ad6810513a37d23
CASE_BEGIN=stock-acceptance-authority
CASE_EXIT name=stock-acceptance-authority exit=0
CASE_BEGIN=homebrew-acceptance-authority
CASE_EXIT name=homebrew-acceptance-authority exit=0
CASE_BEGIN=stock-human-acceptance-regression
CASE_EXIT name=stock-human-acceptance-regression exit=0
CASE_BEGIN=homebrew-human-acceptance-regression
test_35_human_acceptance_terminal: 13 passed, 0 failed
CASE_EXIT name=homebrew-human-acceptance-regression exit=0
SKIP_MARKER_SCAN=PASS
BUG037_FINAL_CURRENT_BYTE_MATRIX_FAILURES=0
BUG037_FINAL_CURRENT_BYTE_MATRIX_END
```

Tool-log row 315 records dual-Bash syntax checks, all 22 linked-test
references, and the bugfix regression-quality guard at exit `0`. The guard
reported zero violations and zero warnings across both selected files.

Tool-log row 318 records the selected-test audit at exit `0`. It reports zero
mock interceptions, zero live-system categories, zero skip markers, and a clean
diff whitespace check.

### One-to-one finding closure

**Phase:** test

**Claim Source:** executed

- `F-B037-GAPS-S2T8` is closed by S2-T8 and S2-T8a. The test compares explicit
  base and candidate tree revisions. A prose-only foreign
  `*uservalidation.md` change emits `FOREIGN-USERVALIDATION-CHANGE`.
- `F-B037-GAPS-S4T2` is closed by description-only parsing of G136. The test
  requires all three sections, the done-only scope, opt-out semantics, and
  exact code-set equality. Seven clause controls and one extra-code control
  prove sensitivity.
- `F-B037-GAPS-S4T4` is closed by named changelog-section parsing. The test
  requires BUG-037, PD-12, corrected BUG-029, and four distinct migration
  classes. Deleting the corrected BUG-029 entry fails its exact control.
- `F-B037-GAPS-S4T8` is closed by description-only parsing of G057. The test
  requires all three D-3 rules and their mechanical or advisory labels. A
  mutated enforcer that reads `uservalidation.md` fails its exact control.

Each closure signal appears in both authority-selftest runs in tool-log row
316. The embedded negative controls exercise the same assertion helpers as the
positive repository surfaces.

### Generator freshness and packet lint

**Phase:** test

**Claim Source:** executed

Tool-log row 317 records the final generator slice at exit `1`. Linked-test
resolution, gate-map freshness, gate-map selftest, validation-check freshness,
validation-check selftest, and packet artifact lint returned zero. The release
manifest freshness check and its linked selftest remained non-zero.

Tool-log row 319 isolates the release-manifest selftest at exit `1`:

```text
# BUG-037 isolated release-manifest freshness failure
exit: 1
lines: 31
sha256: 2715bfe54957d0c268ecb3a0ecbd6ad03e55bcdfc2a6da47c4433ce4baeb536d
Running release-manifest selftest...
Scenario: release hygiene generates one complete trust manifest for downstream installs.
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Committed release manifest is current
PASS: Release manifest exists
PASS: Manifest records release version
PASS: Manifest records source git SHA
PASS: Manifest records trust docs digest
PASS: Manifest records framework-managed file count (930)
release-manifest selftest failed with 1 issue(s).
```

The manifest records checksum
`dbc2e80e5a03a3563dccc9bf895a3506d16686418df17b3aee719df9c71ff071`
for the edited authority selftest. Its current checksum is
`944ec318aa756731cb357b3fb401684645c6c21a04f3dd9f28d338b3fcc9faf0`.
This mismatch directly explains at least one freshness difference.

The test phase did not regenerate `bubbles/release-manifest.json`. That file is
not test-owned, and the request limited edits to test and test-evidence state.
The unresolved owner is `bubbles.implement`.

### Test verdict and broad-suite boundary

**Phase:** test

**Claim Source:** executed

The four inherited test-owned findings are addressed. The selected focused
tests pass under both required Bash runtimes. Packet artifact lint passes.

The test verdict is `NOT_TESTED` for phase completion because the required
release-manifest freshness check is red. The top-level status and every
certification field remain `in_progress` or uncertified.

Broad suite status: NOT RUN. The requested slice excluded `framework-validate`
and `release-check`, so this invocation started neither command.

Tool-log row 320 records the post-bookkeeping profile checks at exit `0`.
State integrity, linked-test resolution, packet artifact lint, execution
substate integrity, technical prose, and diff whitespace all passed.

## BUG-037 release-manifest freshness remediation

**Phase:** implement

**Claim Source:** executed

### Repository binding

The goal-node packet was rebuilt in memory from the canonical scenario plan.
The packet derived repository alias `bubbles` and the canonical source root
from the scenario repository table. The packet validator returned exit `0`
before any repository read or write. It reported decision
`rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:1:node:reconcile-bug-037-validation-registry`,
control revision `1`, and scope `reconcile-bug-037-validation-registry`.

### Current-byte RED proof

Tool-log rows 321 and 322 reproduce the routed failure on the bytes present
before regeneration. The freshness check and release-manifest selftest each
returned exit `1`.

| Tool-log row | Command | Exit | Evidence-capture SHA-256 |
| --- | --- | ---: | --- |
| 321 | `bash bubbles/scripts/generate-release-manifest.sh --check` | 1 | `52f27aa0b967c3135d4550f4c8f46fd2fc97318332ea133fe49986f62dc34f9b` |
| 322 | `bash bubbles/scripts/release-manifest-selftest.sh` | 1 | `2715bfe54957d0c268ecb3a0ecbd6ad03e55bcdfc2a6da47c4433ce4baeb536d` |

The selftest reported `FAIL: Committed release manifest is current` and ended
with `release-manifest selftest failed with 1 issue(s).` The remaining 26
manifest contract assertions passed.

### Owning regeneration and exact-diff control

The canonical generator first wrote an isolated candidate. A structured
comparison against the existing manifest reported all of the following:

- metadata excluding volatile provenance fields was equal.
- managed path order was equal.
- source-only path order was equal.
- source-only checksum changes were empty.
- the only managed checksum change was
  `bubbles/scripts/acceptance-authority-selftest.sh`.
- that checksum changed from
  `dbc2e80e5a03a3563dccc9bf895a3506d16686418df17b3aee719df9c71ff071`
  to
  `944ec318aa756731cb357b3fb401684645c6c21a04f3dd9f28d338b3fcc9faf0`.

The exact unified diff contained one removed checksum line and one added
checksum line for that path. The candidate-scope assertion returned exit `0`.
This proves the generator did not absorb another uncommitted file into this
regeneration.

Tool-log row 323 records the owning generator at exit `0`, one output line, and
evidence-capture SHA-256
`bf9214e61a05121d87639384c57055f70b99e532c60572a2b34203e934d5afa6`.
The generated repository file was byte-identical to the approved candidate.

### Current-byte GREEN proof

Tool-log rows 324 and 325 record the required post-generation checks.

| Tool-log row | Command | Exit | Evidence-capture SHA-256 |
| --- | --- | ---: | --- |
| 324 | `bash bubbles/scripts/generate-release-manifest.sh --check` | 0 | `508cfb7f98ab0a368946caccccd443feec43a76507bc0160c70500c69fd5b14e` |
| 325 | `bash bubbles/scripts/release-manifest-selftest.sh` | 0 | `c58088077f5f1a80bca831122ccd9593c23cb6c07ef48acdb944a6dbbda3808e` |

The freshness check reported `Release manifest is current: 7.28.0 (930 managed
files)`. The selftest emitted 27 PASS lines and ended with
`release-manifest selftest passed.`

### Finding closure and routing

`F-B037-TEST-RELEASE-MANIFEST-FRESHNESS` is resolved by tool-log rows 323
through 325. Rows 321 and 322 preserve the pre-fix failure. No test assertion,
terminal status, certification field, neighboring bug packet, session state,
branch, worktree, remote, host, or Git history operation was part of this
remediation.

The implementation result is `route_required` to `bubbles.test` for
independent current-byte verification. The bug and certification remain
`in_progress`.

<a name="bug037-independent-final-byte-test"></a>

## Scope: TEST independent final-byte verification - 2026-09-01

### Repository binding and baseline

**Phase:** test

**Claim Source:** executed

The goal-node packet validated before any repository read or command. The
validator returned exit `0` with these unchanged fields:

- `repositoryRoot`: `/Users/pkirsanov/Projects/bubbles`
- `repositoryAlias`: `bubbles`
- `sessionId`: `vscode-d6173f50fde08e4fc6fdf133dac19e92`
- `decisionId`: `rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:1:node:reconcile-bug-037-validation-registry`
- `controlRevision`: `1`
- `controlPathDigest`: `sha256:31af946ba99c9cc0dfa9f0c87a9a2e2ef4232d504026d42c7302fffb144ec8fe`
- `authority`: `scoped-scenario-node`
- `transition`: `scoped-override`
- `scopeKind`: `goal-node`
- `scopeId`: `reconcile-bug-037-validation-registry`
- `targetKind`: `goal-node`
- `pathVisibility`: `local`
- `actionable`: `true`

Tool-log row 340 records the final-byte baseline at exit `0`. The 36 immutable
inputs had aggregate SHA-256
`2d786165a1101a31760c77a1d79bd317af366fc557d3f725cccae67ad2a13409`.
The BUG-032 and BUG-033 aggregate was
`1e5e45612f79f479e8cf0fea81d86bcd18a68da81228e0fe72cce554f82d8475`.
The certification object was
`fb84636b3c65fa9fcb9e4389a04ecf89fd84e8dbb6422284b23d014220085fd8`.

### Dual-Bash acceptance matrix

**Phase:** test

**Claim Source:** executed

Tool-log row 341 records exit `0`, stdout hash
`b5314e5fad8a6cfcbdad6f943d259a4c5143be2feb577eaabed702a6aeedfc67`,
and evidence-capture SHA-256
`dc1e41b395b2df0d78054469e00530aa07098a1873c8f0559a4ce7a9bf68fade`.

```text
BUG037_DUAL_BASH_FINAL_MATRIX_BEGIN
IMMUTABLE_PRE_SHA256=2d786165a1101a31760c77a1d79bd317af366fc557d3f725cccae67ad2a13409
CASE_BEGIN name=stock-acceptance-authority command=/bin/bash bubbles/scripts/acceptance-authority-selftest.sh
CASE_EXIT name=stock-acceptance-authority exit=0
CASE_BEGIN name=homebrew-acceptance-authority command=/opt/homebrew/bin/bash bubbles/scripts/acceptance-authority-selftest.sh
CASE_EXIT name=homebrew-acceptance-authority exit=0
CASE_BEGIN name=stock-human-acceptance-regression command=/bin/bash tests/regression/test_35_human_acceptance_terminal.sh
CASE_EXIT name=stock-human-acceptance-regression exit=0
CASE_BEGIN name=homebrew-human-acceptance-regression command=/opt/homebrew/bin/bash tests/regression/test_35_human_acceptance_terminal.sh
test_35_human_acceptance_terminal: 13 passed, 0 failed
CASE_EXIT name=homebrew-human-acceptance-regression exit=0
IMMUTABLE_POST_SHA256=2d786165a1101a31760c77a1d79bd317af366fc557d3f725cccae67ad2a13409
BUG037_DUAL_BASH_FINAL_MATRIX_FAILURES=0
BUG037_DUAL_BASH_FINAL_MATRIX_END
```

### Linked tests and regression quality

**Phase:** test

**Claim Source:** executed

Tool-log row 342 records exit `0`, stdout hash
`74bd1a6adae3b7f900a68339bea7febf1ddbac98c7939e9f39352a3501632999`,
and evidence-capture SHA-256
`37802e0cc59d85ef4a415650fe3617bc62cd7c0307e38fb83bd904c0b6c597cb`.

```text
BUG037_LINK_AND_REGRESSION_CHECKS_BEGIN
IMMUTABLE_PRE_SHA256=2d786165a1101a31760c77a1d79bd317af366fc557d3f725cccae67ad2a13409
[scenario-test-resolve] OK — 22 reference(s) resolved via literal-scan; 19 category comparison(s) not applicable (no test-discovery adapter declared)
CASE_EXIT name=scenario-test-resolve exit=0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 2
Files with adversarial signals: 2
CASE_EXIT name=regression-quality-guard exit=0
SKIP_MARKER_SCAN=PASS matches=0
CASE_EXIT name=skip-marker-scan exit=0
DECLARED_LIVE_SYSTEM_TEST_COUNT=0
MOCK_INTERCEPTION_SCAN=PASS matches=0
CASE_EXIT name=live-and-mock-classification exit=0
IMMUTABLE_POST_SHA256=2d786165a1101a31760c77a1d79bd317af366fc557d3f725cccae67ad2a13409
BUG037_LINK_AND_REGRESSION_FAILURES=0
BUG037_LINK_AND_REGRESSION_CHECKS_END
```

### Generated-artifact freshness

**Phase:** test

**Claim Source:** executed

Tool-log row 343 records the first matrix at exit `1`. Five checks returned
zero, but the gate-map selftest skipped because the selected Python lacked
PyYAML. The skip was not counted as a pass.

Row 344 found two existing interpreters with PyYAML. Nothing was installed.
Row 345 replaced the skipped gate-map run and returned zero with no skip.

Tool-log row 349 records the complete replacement matrix at exit `0`. Its
stdout hash is
`f0c539fe5d5eb42b0bbe74f793b935a466783fb04f82279947ca22d19f578237`.
Its evidence-capture SHA-256 is
`562bd6367187ad3eed1692779618aba10acb056e5005ef1beac1c7c6886e7994`.

```text
BUG037_GENERATED_FRESHNESS_FINAL_SUMMARY_BEGIN
SUMMARY name=gate-map-check exit=0 skips=0 stable=true
SUMMARY name=gate-map-selftest exit=0 skips=0 stable=true
SUMMARY name=validation-checks-check exit=0 skips=0 stable=true
SUMMARY name=validation-checks-selftest exit=0 skips=0 stable=true
SUMMARY name=release-manifest-check exit=0 skips=0 stable=true
SUMMARY name=release-manifest-selftest exit=0 skips=0 stable=true
IMMUTABLE_POST_SHA256=2d786165a1101a31760c77a1d79bd317af366fc557d3f725cccae67ad2a13409
BUG037_GENERATED_FRESHNESS_FINAL_FAILURES=0
BUG037_GENERATED_FRESHNESS_FINAL_SUMMARY_END
BUG037_GENERATED_FRESHNESS_FINAL_END
```

### Focused packet checks and remaining defect

**Phase:** test

**Claim Source:** executed

Tool-log row 346 ran dual-Bash syntax checks, artifact lint, the execution
substate guard, agnosticity, and diff whitespace. Every check except diff
whitespace returned zero. The aggregate exited `1` because `git diff --check`
returned `2`.

Tool-log row 348 isolates the result. It returns zero because the classifier
proved exactly one expected finding and no second diff finding.

```text
BUG037_DIFF_CHECK_FINDING_CLASSIFICATION_BEGIN
NON_BUGS_DIFF_CHECK_EXIT=0
NON_BUGS_DIFF_CHECK_OUTPUT=<empty>
BUGS.md:2813: new blank line at EOF.
BUGS_DIFF_CHECK_EXIT=2
BUGS_DIFF_CHECK_MATCH_COUNT=1
BUGS_DIFF_CHECK_NONBLANK_LINES=1
BUGS_SHA256=84486f5396a35fcf0c302646c9ddd035ad495dd972522d81bfcbc2059f4a0450
BUG037_DIFF_CHECK_FINDING_CLASSIFICATION_END
```

Finding `F-B037-TEST-DIFF-CHECK-EOF-001` remains open. It belongs to the
implementation owner because this test invocation cannot edit `BUGS.md`.

### Current broad-suite status

**Phase:** test

**Claim Source:** not-run

The current final-byte epoch did not run `framework-validate` or
`release-check`. The focused diff check failed before broad execution. The
earlier report receipts predate this final-byte epoch and are not claimed as
current evidence.

### Boundary incident

**Phase:** test

**Claim Source:** executed

One baseline call used the MCP evidence surface before its selected wrapper was
visible. The result showed the QuantitativeFinance installed wrapper and one
append to that repository's runtime tool log. No second MCP evidence call ran.
The request forbids downstream cleanup, so this invocation made no later access
to that repository.

Finding `F-B037-TEST-BOUNDARY-002` records this constraint breach. It is not a
BUG-037 source defect. It remains visible in the result envelope.

### Finding accounting and route

Tool-log row 350 records the post-bookkeeping profile at exit `0`. Artifact
lint, technical-prose review, execution-substate validation, and release
manifest freshness completed. The immutable, BUG-032/BUG-033, and certification
hashes matched their baselines exactly.

- Addressed findings: none.
- `F-B037-TEST-DIFF-CHECK-EOF-001` remains unresolved. Route it to
  `bubbles.implement` for the single `BUGS.md` whitespace repair.
- `F-B037-TEST-BOUNDARY-002` remains unresolved. It records the one downstream
  runtime-log append and requires no action inside this packet.

The test verdict is `NOT_TESTED` for phase completion. The packet and
certification stay `in_progress`. The persisted regression phase is not resumed
while a focused packet check remains red.

<a name="bug037-current-final-byte-test-reconciliation"></a>

## Scope: TEST current-final-byte reconciliation - 2026-09-01

### Repository binding

**Phase:** test

**Claim Source:** executed

The in-memory packet validated before repository work. The validator returned
exit `0` for this exact decision:

- Repository root: `/Users/pkirsanov/Projects/bubbles`
- Repository alias: `bubbles`
- Session: `vscode-d6173f50fde08e4fc6fdf133dac19e92`
- Decision: `rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:1:node:reconcile-bug-037-validation-registry`
- Revision: `1`
- Control digest: `sha256:31af946ba99c9cc0dfa9f0c87a9a2e2ef4232d504026d42c7302fffb144ec8fe`
- Authority: `scoped-scenario-node`
- Transition: `scoped-override`
- Scope kind and identifier: `goal-node`, `reconcile-bug-037-validation-registry`
- Target kind: `goal-node`
- Path visibility and actionability: `local`, `true`

### Canonical current-byte matrix

**Phase:** test

**Claim Source:** executed

Tool-log row 361 records the final matrix at exit `0`. It has stdout hash
`a7d9f150b1b10c3259bc0245b2b4efa591973d09645d21e7e358de5e32e5371d`.
The bounded evidence covers 427 output lines with SHA-256
`43c4d03b2a444eb47c4bd4c83b6ba044930d546e409f872b37be2d838754c995`.

```text
# BUG-037 canonical current-final-byte test matrix final
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 8400 /bin/zsh -f /private/tmp/bug037-canonical-test-matrix-d6173f50.zsh
exit: 0
lines: 427
sha256: 43c4d03b2a444eb47c4bd4c83b6ba044930d546e409f872b37be2d838754c995
SUMMARY name=stock-acceptance-authority exit=0 skips=0 stable=true
SUMMARY name=homebrew-acceptance-authority exit=0 skips=0 stable=true
SUMMARY name=stock-human-acceptance-regression exit=0 skips=0 stable=true
SUMMARY name=homebrew-human-acceptance-regression exit=0 skips=0 stable=true
SUMMARY name=scenario-test-resolve exit=0 skips=0 stable=true
SUMMARY name=regression-quality-guard exit=0 skips=0 stable=true
SUMMARY name=skip-marker-scan exit=0 skips=0 stable=true
SUMMARY name=live-classification exit=0 skips=0 stable=true
SUMMARY name=gate-map-check exit=0 skips=0 stable=true
SUMMARY name=gate-map-selftest exit=0 skips=0 stable=true
SUMMARY name=validation-checks-check exit=0 skips=0 stable=true
SUMMARY name=validation-checks-selftest exit=0 skips=0 stable=true
SUMMARY name=release-manifest-check exit=0 skips=0 stable=true
SUMMARY name=release-manifest-selftest exit=0 skips=0 stable=true
SUMMARY name=stock-bash-syntax exit=0 outputNonblank=false stable=true
SUMMARY name=homebrew-bash-syntax exit=0 outputNonblank=false stable=true
SUMMARY name=packet-artifact-lint exit=0 skips=0 stable=true
SUMMARY name=execution-substate-guard exit=0 skips=0 stable=true
SUMMARY name=agnosticity exit=0 skips=0 stable=true
SUMMARY name=bugs-raw-diff-check exit=0 outputNonblank=false stable=true
SUMMARY name=bugs-focused-diff-check exit=0 outputNonblank=false stable=true
SUMMARY name=bugs-index-diff-check exit=0 outputNonblank=false stable=true
SUMMARY name=bugs-heading-integrity exit=0 skips=0 stable=true
FINAL_RELEVANT_SHA256=d4899d5e523641b1cc6eb281456016ed910b2980d0cd4030a3e3bd567fe2a972
FINAL_FOREIGN_BUG032_033_SHA256=1e5e45612f79f479e8cf0fea81d86bcd18a68da81228e0fe72cce554f82d8475
FINAL_CERTIFICATION_SHA256=fb84636b3c65fa9fcb9e4389a04ecf89fd84e8dbb6422284b23d014220085fd8
FINAL_BUGS_SHA256=e47d93eaa158298757b821a93af5df5dc29166775b1da4f15eeb5f2a4bb63f45
FINAL_STABLE=true
BUG037_CANONICAL_MATRIX_FAILURES=0
```

The matrix used the existing Bubbles Python environment. It reported Python
`3.14.6` and PyYAML `6.0.3`. No dependency installation occurred.

The linked-test resolver resolved 22 references. The regression-quality guard
reported zero violations and zero warnings. The packet declares zero live-system
tests, so trace, SLO, and mock-interception checks were not applicable.

### BUGS.md integrity and neighboring-packet preservation

**Phase:** test

**Claim Source:** executed

Both requested BUGS.md working-tree diff checks returned exit `0` with empty
output. The index diff check also returned exit `0` with empty output.

The independent integrity assertion reported 2,812 newline-terminated lines,
zero trailing blank lines, and one terminal newline byte. It found 30 BUG
headings and zero duplicate identifiers. The final non-empty text was
`paraphrased and no exit code is inferred.`

The matrix held these identities at every checkpoint:

- BUGS.md SHA-256: `e47d93eaa158298757b821a93af5df5dc29166775b1da4f15eeb5f2a4bb63f45`
- BUG-032 and BUG-033 aggregate: `1e5e45612f79f479e8cf0fea81d86bcd18a68da81228e0fe72cce554f82d8475`
- BUG-032 acceptance SHA-256: `7f44f955c2d90e2e95889b22a283ee5a312d41ae27853e6cf62ce70ddd6856e9`
- BUG-033 acceptance SHA-256: `596d2c27c0416143faf1c75d9914fe580bdd54597d1c4b1aa34daf62d3da2e7f`
- Certification SHA-256: `fb84636b3c65fa9fcb9e4389a04ecf89fd84e8dbb6422284b23d014220085fd8`

HEAD, branch, index, status, refs, remotes, and worktrees also stayed stable.

### Finding accounting

**Phase:** test

**Claim Source:** executed

- `F-B037-TEST-DIFF-CHECK-EOF-001` is resolved. The parent recovery is fix
  provenance only. Tool-log row 361 independently proves both exact diff checks
  and the heading and EOF integrity assertion on current bytes.
- `F-B037-TEST-MATRIX-HARNESS-003` is resolved. Tool-log row 359 exited `2`
  before tests because an inline payload lost literal newline quoting. The
  IDE-created temporary harness removed that transport defect.
- `F-B037-TEST-MATRIX-HARNESS-004` is resolved. Tool-log row 360 exited `1`
  because its marker-scan success label matched its own no-skip detector. The
  temporary label changed, and row 361 reran the complete matrix at exit `0`.
- `F-B037-TEST-BOOKKEEPING-HARNESS-005` is resolved. The first post-bookkeeping
  profile was quote-corrupted at its `jq` filter. Its agent-owned process group
  was terminated, and an IDE-created temporary script replaced the inline form.
- `F-B037-TEST-BOOKKEEPING-HARNESS-006` is resolved. The first termination
  diagnostic matched its own `pgrep` process. Direct checks of the four observed
  process identifiers reported `BUG037_TERMINATED_PID_ACTIVE_COUNT=0`.
- `F-B037-TEST-BOOKKEEPING-HARNESS-007` is resolved. Tool-log row 362 preserves
  the newline-convention mismatch between baseline and current hashes. The
  temporary profile now uses the baseline's newline-inclusive digest method.
- `F-B037-TEST-BOOKKEEPING-EDIT-008` is resolved. The editor rejected one
  combined patch because it repeated the state path. The rejected edit changed
  no file, and separate state and report edits succeeded.
- `F-B037-TEST-BOUNDARY-002` remains a non-blocking routed diagnostic. It records
  a prior downstream runtime tool-log append, not a downstream source mutation.
  No downstream file was changed or cleaned during this reconciliation.
- `F-B037-TEST-BOUNDARY-009` remains a non-blocking routed diagnostic. Two
  workspace-wide searches returned downstream project-config and state-file
  matches. They caused no downstream write. This observation does not weaken
  the BUG-037 test verdict and authorizes no downstream remediation.

No current matrix failure remains unresolved. The boundary observation remains
routed. The test execution phase is independently verified. The packet and
certification remain `in_progress`. The next persisted bugfix-fastlane owner is
`bubbles.regression`.

<a name="bug037-current-final-byte-regression"></a>

## Scope: regression current-final-byte review - 2026-09-02

### Repository authority

**Phase:** regression

**Claim Source:** executed

The repository-binding validator accepted the in-memory scenario projection
before any local read. It returned exit `0` and `actionable=true`.

- Repository root: `/Users/pkirsanov/Projects/bubbles`
- Repository alias: `bubbles`
- Session: `vscode-d6173f50fde08e4fc6fdf133dac19e92`
- Decision: `rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:4:node:reconcile-bug-037-validation-registry`
- Control revision: `4`
- Control digest: `sha256:31af946ba99c9cc0dfa9f0c87a9a2e2ef4232d504026d42c7302fffb144ec8fe`
- Authority: `scoped-scenario-node`
- Transition: `scoped-override`
- Scope kind and identifier: `goal-node`, `reconcile-bug-037-validation-registry`
- Target kind: `goal-node`
- Path visibility: `local`
- Actionable: `true`

### Receipt accounting

**Phase:** regression

**Claim Source:** executed

Tool-log row 386 inspected every row from 367 through 385. All rows carried
the expected session, agent, bug, scope, working directory, and schema fields.

| Row | Check | Exit | Disposition |
| ---: | --- | ---: | --- |
| 367 | Current-byte baseline harness | 1 | Replaced by row 368 |
| 368 | Corrected current-byte baseline | 0 | Clean |
| 369 | Dual-Bash authority and persistent G136 | 0 | Clean |
| 370 | Receipt-closure harness | 1 | Replaced by row 371 |
| 371 | Corrected receipt-closure harness | 0 | Clean |
| 372 | Linked scenario resolution | 0 | Clean |
| 373 | Regression quality and silent-pass scan | 0 | Clean |
| 374 | Generated-artifact freshness matrix | 0 | Clean |
| 375 | G044 coherence matrix | 0 | Clean |
| 376 | Direct BUG-032 acceptance compatibility | 0 | Clean |
| 377 | BUG-032 G101 compatibility | 0 | Clean |
| 378 | Pre-bookkeeping mutation boundary | 0 | Clean |
| 379 | Coverage applicability harness | 1 | Replaced by row 380 |
| 380 | Corrected coverage applicability | 0 | Clean |
| 381 | Pre-bookkeeping completion profile | 0 | Clean |
| 382 | Dual-Bash BUG-029 and G136 matrix | 0 | Clean |
| 383 | Rows 367 through 382 receipt audit | 0 | Clean |
| 384 | Real linked Check 43 functional suite | 0 | Clean |

Row 385 belongs to this bookkeeping pass. It exited `2` before receipt
inspection because its `jq` expression used an unsupported split signature.
Row 386 replaced that parser and exited `0`.

### Functional and compatibility coverage

**Phase:** regression

**Claim Source:** executed

The successful receipts cover every required BUG-037 regression class.

| Requirement | Evidence | Result |
| --- | --- | --- |
| Dual-Bash acceptance authority | Rows 369 and 382 | Exit 0 with no skips |
| Persistent G136 and BUG-029 behavior | Rows 369 and 382 | Exit 0 with no skips |
| Real linked Check 43 path | Row 384 | Exit 0 after 2,033,636 ms |
| BUG-032 compatibility | Rows 376 and 377 | Both exit 0 |
| Scenario links | Row 372 | Exit 0 |
| Adversarial regression quality | Row 373 | Exit 0 with zero violations |
| Generated freshness | Row 374 | Six cases exit 0 with no skips |
| G044 design coherence | Row 375 | Three checks exit 0 |
| Coverage applicability | Row 380 | Exit 0 |
| Mutation boundary | Row 378 | Exit 0 |

The manifest contains 19 scenarios. Eighteen require regression coverage.
`SCN-B037-014`, the changelog contract scenario, is the sole non-regression
scenario. The manifest keeps 22 linked test references across 48 Test Plan
rows. The pre-phase linked-reference baseline was also 22, so the delta is
zero.

The packet declares zero live-system tests and no deployment path. The command
registry declares no percentage coverage command. Percentage coverage and the
deployment scan are therefore not applicable. This review does not present
either item as a passing executable check.

### Row 384 current-byte closure

**Phase:** regression

**Claim Source:** executed

Row 386 recomputed every row 384 input hash. All seven current files match the
receipt exactly, so the expensive suite was not rerun.

| Input | SHA-256 |
| --- | --- |
| `bubbles/scripts/state-transition-guard-selftest.sh` | `25d1e95156a83707cb39bf8a209f9a82a6e487dba7ffcee6896ff2dfbf6038a7` |
| `bubbles/scripts/state-transition-guard.sh` | `dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783` |
| `bubbles/scripts/guards/tail-delegated-gates.sh` | `6a672ee1b69a8c74485f43ae1d48c00d9df259fc8d8c7e90712556fcc2f551ee` |
| `bubbles/scripts/acceptance-authority-lib.sh` | `ca3edf2ca80faf7330cbb6c758dc3456dc04396d8e92695df3fd2551918b0a1e` |
| `bubbles/registry/acceptance-authority.yaml` | `bf34f50592074689675d8b90d6c4ddf8033fbccc974fc2f13f1eeda609dd587d` |
| `scenario-manifest.json` | `511909d2140a16177a4ebc63ced93c18ca309ab46f4529b1919161208dc4c7fc` |
| `test-plan.json` | `4f822a3de5f2865a69ce87deb18ac1e8865148d759c1143b5f46de09e6e800de` |

### Finding closure

**Phase:** regression

**Claim Source:** executed

- `F-B037-REG-BASELINE-HARNESS-001` is resolved. Row 367 exposed the malformed
  `$n` token, and row 368 replaced it with a stable manifest delimiter.
- `F-B037-REG-CLOSURE-HARNESS-002` is resolved. Row 370 used an undefined `$t`
  delimiter, and row 371 used an explicit pipe delimiter.
- `F-B037-REG-COVERAGE-HARNESS-003` is resolved. Row 379 assumed all 19
  scenarios required regression coverage. Row 380 observed the correct 18 of
  19 split and named `SCN-B037-014` as the exception.
- `F-B037-REG-RECEIPT-HARNESS-004` is resolved. Row 385 failed before receipt
  inspection, and row 386 reran the complete audit with a supported parser.
- `F-B037-REG-BOOKKEEPING-EDIT-005` is resolved. The first editor call repeated
  the state path and changed no file. The combined state patch removed that
  duplicate-path defect.
- `F-B037-REG-BOOKKEEPING-EDIT-006` is resolved. The second atomic editor call
  reported invalid report context and changed no file. Separate state and
  report edits removed that coupling.
- `F-B037-REG-POSTCHECK-HARNESS-007` is resolved. Row 388 passed every
  non-binding check but asked `gtimeout` to launch a shell function. Row 389
  executed the same binding projection directly and returned zero.
- `F-B037-REG-TERMINAL-DISCIPLINE-008` is resolved. The first row-count probe
  used a filtered pipeline. Its replacement used `wc` plus shell parameter
  expansion and reported the same 388-row count without filtering output.
- `F-B037-TEST-BOUNDARY-002` remains a low routed observation. It records one
  prior downstream runtime-log append and no downstream source mutation.
- `F-B037-TEST-BOUNDARY-009` remains a low routed observation. It records two
  downstream search results and no downstream write.

No blocking regression finding remains open. No prior blocking finding was
removed or hidden. Top-level status and certification remain `in_progress`.

### Post-bookkeeping verification

**Phase:** regression

**Claim Source:** executed

Tool-log row 388 ran the complete post-bookkeeping profile. Artifact lint,
technical prose, execution-substate, and diff-whitespace checks returned zero.
Every protected hash and Git control hash matched its pre-edit baseline.

The profile also reported 30 unique findings and zero open blocking findings.
Its aggregate exit was `1` only because the binding wrapper returned `127`.
The wrapper asked `gtimeout` to resolve a shell function as an executable.

Tool-log row 389 replaced that wrapper. The validator returned `SCOPED`,
`actionable=true`, revision `4`, and exit `0` for the exact goal node.

### Scoped verdict and route

`REGRESSION_FREE` applies to the declared BUG-037 regression surface on the
verified current-byte epoch. It is not repository certification or bug
completion. The persisted `bugfix-fastlane` route continues to
`bubbles.simplify`.




<a name="bug037-simplify-current-final-bytes"></a>

## Scope: simplify current-final-byte cleanup - 2026-09-02

### Bound decision

**Phase:** simplify

**Claim Source:** interpreted

**Interpretation:** Three review dimensions found three safe reductions in the
regression-verified implementation. Each reduction preserves the acceptance
contract. Current focused, persistent, generated, and linked functional
receipts prove the resulting bytes.

The review stayed inside the BUG-037 source, persistent-test, generated, report,
and execution-state boundary. It changed no acceptance record or certification
field. It also changed no BUG-029, BUG-032, session, Git-control, downstream, or
deployment surface.

### Three-pass findings

| Pass | Finding | Severity | Resolution |
| --- | --- | --- | --- |
| Code reuse | `F-B037-SIMPLIFY-PREFLIGHT-002` | low | Extract the shape-verdict body so terminal evaluation reuses it without a second authority preflight. |
| Code quality | `F-B037-SIMPLIFY-CHECKLIST-SCAN-003` | low | Remove the checklist-items pre-scan and iterate unchecked items directly. |
| Efficiency and portability | `F-B037-SIMPLIFY-POSIX-004` | blocking | Use POSIX whitespace classes and one Boolean grep in the persistent write detector. |

### Exact simplify delta since regression

**Phase:** simplify

**Claim Source:** interpreted

**Interpretation:** VS Code history retained exact snapshots whose SHA-256
values match the regression and simplify receipts. Two no-index diffs over
those snapshots exposed only the source hunks described below.

The regression reader hash was
`ca3edf2ca80faf7330cbb6c758dc3456dc04396d8e92695df3fd2551918b0a1e`.
The first simplify reader hash was
`a5ad36692af0143372e57e5446145c034b19c166087e209d1c00e4d20bd43068`.
The final reader hash is
`dfcb07027d683d00879468e56cf5b6020f80847ccf105f4a43a95744528902da`.

The requested generic section-field parser needs one correction. The
`bubbles_acceptance_section_field()` block is identical in the regression and
final snapshots. Simplify did not change that parser.

The first source hunk instead extracted
`bubbles_acceptance_shape_verdict_after_preflight()`. The public shape verdict
still validates authority before calling it. The terminal verdict now validates
authority once and calls the same body. Finding emission and return semantics
remain in the shared body.

The second source hunk removed this redundant sequence: parse all checklist
items, test whether any exist, then parse unchecked items. The replacement
iterates unchecked items directly. Empty output still emits nothing. Each
non-empty unchecked item still emits one `PD12-UNCHECKED-ITEM` finding.

The persistent test changed one existence predicate. Non-POSIX `\s` escapes
became `[[:space:]]`. A `grep -nE` and `grep -q` pipeline became one
`grep -qE`. The two forbidden write alternatives remain byte-for-byte equal.
No fixture, expected code, count, or acceptance assertion changed.

The owning release-manifest generator ran after each managed-file change. Its
final entries bind the reader to `dfcb0702...`, the authority selftest to
`944ec318...`, and the persistent test to `da65cee6...`.

### Simplify receipt accounting

**Phase:** simplify

**Claim Source:** executed

Tool-log row 416 audited every simplify receipt from row 392 through row 413.
It exited `0` with evidence-capture SHA-256
`ca53554ad7e7212c1a488819c5eecc7391508e2f283394b9d7269a30c2134e33`.
The tool-log stdout hash is
`83a39b2e9be2cb4acdfe8e153fb697b7816599c4825f5c9bca746f849274504d`.

| Rows | Purpose | Exits | Current-byte result |
| --- | --- | --- | --- |
| 392-395 | First reader reduction under stock and Homebrew Bash, including persistent G136 | all 0 | Green at reader hash `a5ad3669...` |
| 396 | Release-manifest freshness after the first reader edit | 1 | Expected stale generated artifact, retained as RED |
| 397, 402 | Owning regeneration and replacement freshness check | 0, 0 | First freshness finding closed |
| 398-401 | Dual-Bash focused and persistent checks after regeneration | all 0 | No source or test failure |
| 403-406 | Final reader reduction under both Bash runtimes | all 0 | Green at reader hash `dfcb0702...` |
| 407-408 | Regeneration and freshness after the final reader edit | 0, 0 | Generated projection current |
| 409-410 | Persistent portability edit under stock BSD userland and Homebrew Bash | 0, 0 | Green at test hash `da65cee6...` |
| 411-412 | Regeneration and freshness after the persistent-test edit | 0, 0 | Final manifest current |
| 413 | Linked Check 43 functional suite | 0 | Current seven-file closure, zero-skip tag |

Row 396 is the only non-zero receipt in the simplify interval. Row 397 performs
the owning regeneration. Row 402 is its exact green freshness replacement.
Rows 407-408 and 411-412 repeat that pair after later managed-file changes.

Earlier test-phase freshness failures remain preserved. Rows 317 and 319 expose
the stale selftest checksum. Rows 321 and 322 reproduce it. Rows 324 and 325
replace those failures with green checks. Rows 333 and 334 retain the final
green verification for that earlier byte epoch.

Row 283 is not a freshness failure. Its generated checks were green. That
matrix failed because the regression-quality guard received a packet directory.
Row 284 corrected that invocation.

### Row 413 closure and current identities

**Phase:** simplify

**Claim Source:** executed

Row 413 exited `0` after `2,158,690` ms. Its tool-log stdout hash is
`4767ae44bed838eca8ac8a259d654591d8a43e1ed14ac1d3eed91215f8ce6cce`.
Row 416 recomputed all seven closure hashes and matched each one.

| Row 413 input | Current SHA-256 |
| --- | --- |
| `bubbles/scripts/state-transition-guard-selftest.sh` | `25d1e95156a83707cb39bf8a209f9a82a6e487dba7ffcee6896ff2dfbf6038a7` |
| `bubbles/scripts/state-transition-guard.sh` | `dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783` |
| `bubbles/scripts/guards/tail-delegated-gates.sh` | `6a672ee1b69a8c74485f43ae1d48c00d9df259fc8d8c7e90712556fcc2f551ee` |
| `bubbles/scripts/acceptance-authority-lib.sh` | `dfcb07027d683d00879468e56cf5b6020f80847ccf105f4a43a95744528902da` |
| `bubbles/registry/acceptance-authority.yaml` | `bf34f50592074689675d8b90d6c4ddf8033fbccc974fc2f13f1eeda609dd587d` |
| `scenario-manifest.json` | `511909d2140a16177a4ebc63ced93c18ca309ab46f4529b1919161208dc4c7fc` |
| `test-plan.json` | `4f822a3de5f2865a69ce87deb18ac1e8865148d759c1143b5f46de09e6e800de` |

The expensive Check 43 suite was not rerun during finalization. Its closure
matches current bytes, including the new reader hash and both planning hashes.

Rows 403 and 405 are the current reader's stock and Homebrew Bash authority
selftests. Rows 409 and 410 are the current persistent test under both runtimes.
Row 412 is the current release-manifest freshness check. Every row exits `0`.

The authority selftest hash remains
`944ec318aa756731cb357b3fb401684645c6c21a04f3dd9f28d338b3fcc9faf0`.
The persistent test hash is
`da65cee61e5abe58ac3b74bb58505885c80d6048ab2522d2c71bc9218fde7512`.
The release-manifest hash is
`d26405837efc98e5578d464a4bb03764150d1d2e01ef1d3f72d479d7a01f49ab`.

### Test-strength review

No test was removed, renamed, skipped, or relaxed. The final source edit changes
only control flow around existing finding loops. The persistent edit strengthens
BSD grep interpretation while searching the same forbidden write forms.

The focused authority selftest remains unchanged at hash `944ec318...`. The
linked Check 43 suite runs the real guard consumer against exact scenario and
Test Plan bytes. These controls would still fail on an unchecked item, an
automation acceptor, a malformed authority, or a guard write.

### Simplify finding closure

- `F-B037-SIMPLIFY-PREFLIGHT-002` is resolved by the shared post-preflight body.
- `F-B037-SIMPLIFY-CHECKLIST-SCAN-003` is resolved by direct unchecked-item iteration.
- `F-B037-SIMPLIFY-POSIX-004` is resolved by the POSIX predicate and rows 409-410.
- `F-B037-SIMPLIFY-MANIFEST-FRESHNESS-005` is resolved by rows 397-412.
- `F-B037-SIMPLIFY-AUDIT-HARNESS-006` is resolved. Row 414 preserves the over-escaped jq failure. Row 415 replaced it.
- `F-B037-SIMPLIFY-AUDIT-HARNESS-007` is resolved. Row 415 exposed a legacy null input closure. Row 416 made that listing null-safe.
- `F-B037-SIMPLIFY-BOOKKEEPING-EDIT-008` is resolved. The editor rejected a duplicate state path before changing a file.
- `F-B037-SIMPLIFY-STATE-CHECK-HARNESS-009` is resolved. The first direct state predicate changed jq context and lacked fail-fast mode. Its corrected rerun returned true and preserved the certification hash.

`F-B037-TEST-BOUNDARY-002` remains a low routed observation. It records one
prior downstream runtime-log append and no downstream source mutation.

`F-B037-TEST-BOUNDARY-009` remains a low routed observation. It records two
downstream search results and no downstream write.

No blocking simplify finding remains open. Top-level status and certification
remain `in_progress`. The persisted `bugfix-fastlane` route continues to
`bubbles.gaps`.

### Post-bookkeeping profile

**Phase:** simplify

**Claim Source:** executed

Tool-log row 417 ran the complete post-bookkeeping profile. It exited `0` after
`19,455` ms. Its tool-log stdout hash is
`03a613bae2494a3429a3f885a8535afc5bc73a56ef0c33b4c5d668ef933a820f`.
The evidence-capture SHA-256 is
`e5174c20b74db737994b4db1ab09807c7b06350a2976fa8c01276bc70c37f871`.

Artifact lint, technical prose, execution substate, release-manifest freshness,
and diff whitespace each exited `0`. The profile ended with
`POST_BOOKKEEPING_FAILURES=0`.

The prose tool remains report-only. It reported 113 historical long sentences
and 43 historical semicolons across this 4,000-line report. A detailed scan
found no result in the newly appended line range.

Every protected hash matched its pre-edit baseline. This includes
`uservalidation.md`, certification, status, session files, Git heads, remotes,
worktrees, the index, BUG-029, and BUG-032.

All source, focused-test, persistent-test, registry, generated, scenario, and
Test Plan identities matched. Row 413 still matched every current closure byte.

The in-memory packet validator returned `SCOPED`, `actionable=true`, revision
`4`, and exit `0`. The decision remained
`rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:4:node:reconcile-bug-037-validation-registry`.

<a name="bug037-gaps-current-final-bytes"></a>

## Scope: gaps current-final-byte audit - 2026-09-02

### Bound decision

**Phase:** gaps

**Claim Source:** interpreted

**Interpretation:** Five gaps remain on the current bytes. Two belong to
BUG-037 planning. Two belong to BUG-037 implementation or tests. One is a
same-repository guard defect outside this packet's allowed paths.

The audit changed no implementation, planning, certification, acceptance,
generated, neighboring bug, downstream, Git-control, or host surface. It
records findings and execution state only.

### Coverage and current state

**Phase:** gaps

**Claim Source:** executed

Tool-log row 427 enumerated the complete mapping. The manifest contains 19
unique scenarios. The Test Plan contains 48 unique rows. The manifest contains
22 linked references. Every scenario has at least one Test Plan row.

All 54 DoD items are checked and carry evidence markers. Artifact lint exits
zero. The top-level and certification statuses both remain `in_progress`.
All four scopes remain execution-done and uncertified.

The current G022 specialist claims cover `implement`, `test`, `regression`, and
`simplify`. The registry still requires `stabilize`, `security`, `validate`,
and `audit` before terminal certification. Control phases such as `select` and
`bootstrap` are not G022 specialist requirements.

### Blocking and routed findings

| Finding | Classification | Evidence | Owner |
| --- | --- | --- | --- |
| `F-B037-GAPS-MECHANISM-VOCAB-014` | DIVERGENT | Row 423: `test-mechanism-lint.sh` exits 1 with ten vocabulary findings. Five scenarios use unsupported `production-artifact`. Five use unsupported `process-exit`. | `bubbles.plan` |
| `F-B037-GAPS-SCENARIO-LIFECYCLE-015` | PARTIAL | Row 427: `SCN-B037-016`, `017`, and `019` retain `__FUTURE_TEST__` and empty evidence refs. Their eleven planned identities now exist. The Test Plan retains 9 `planned-not-authored`, 5 `planned-amendment`, and 3 `requires-revalidation` rows. | `bubbles.plan` |
| `F-B037-GAPS-AUTHORITY-YAML-016` | DIVERGENT | Row 424: both public verdicts return 0 for contract-complete but invalid YAML. Row 425 proves the same fixture is invalid YAML. | `bubbles.implement`, then `bubbles.test` |
| `F-B037-GAPS-LIFECYCLE-LABEL-017` | UNTESTED | Row 424: every failure-code lifecycle can change to `retired` while preflight and both verdicts still return 0. The focused selftest contains no executable lifecycle-label assertion. | `bubbles.test` |
| `F-B037-GAPS-TRACEABILITY-EMPTY-REF-018` | PATH_MISMATCH | Row 426 reports evidence refs for all 19 scenarios. The guard counts array type, so three empty arrays pass. The guard path is absent from BUG-037 allowed paths. | `bubbles.bug` |

The mechanism vocabulary finding has ten manifestations under one root cause.
The scenario lifecycle finding has three manifest manifestations and seventeen
stale Test Plan states. Each table row maps to one ledger entry.

### Verified fidelity

**Phase:** gaps

**Claim Source:** executed

Tool-log row 425 exits zero across stock macOS Bash and Homebrew Bash. It runs
the focused authority suite and the persistent G136 regression under both.
It also runs syntax checks and all three generated-projection checks.

The green cases verify both public verdicts on the supported authority matrix.
They verify record authorship over base and method fields. They verify the
explicit `true` override and exact conditional refusal cardinality.

The same matrix verifies the four D-1 migration classes and D-3 labels. It
preserves BUG-029 rejection cardinality and the BUG-032 changed-path boundary.
The protected-path query finds no BUG-029, BUG-032, or BUG-037 acceptance-file
change.

Gate-map, validation-check, and release-manifest freshness all exit zero. Their
three selftests also exit zero. Row 413 remains a valid Check 43 receipt because
all seven input hashes still match. Rows 417 through 419 are present and exit
zero with the requested revision-4 binding.

### Broad phase obligations

**Phase:** gaps

**Claim Source:** interpreted

**Interpretation:** Rows 255 and 256 prove historical green broad runs. They
belong to session `vscode-890b012efcd4029f1bbec9142330177b` and contain no input
closure. Simplify later changed the reader and persistent regression bytes.

This gaps phase did not execute `framework-validate`, `release-check`, or
`agnosticity`. The request reserved the first two for a broader phase. Current
S4-T5, S4-T6, and S4-T7 proof remains required after the blocking gaps close.
This is phase work, not evidence of another implementation defect.

### Finding and observation accounting

Five execution incidents closed in this phase.

- `F-B037-GAPS-BINDING-ROOTSET-011` closed when the host adapter removed the
  non-Git workspace root and returned the canonical Git root set.
- `F-B037-GAPS-BINDING-REHYDRATION-012` closed when the scenario node received
  the supplied revision-4 resolution in memory. Packet validation then exited
  zero.
- `F-B037-GAPS-HARNESS-XCODE-013` closed when the baseline selected the installed
  Command Line Tools. The replacement Git boundary queries exited zero.
- `F-B037-GAPS-HARNESS-DIAGNOSTIC-019` closed when the terminal profile gained a
  failure-only summary. Row 431 then named the hidden mismatch exactly.
- `F-B037-GAPS-HARNESS-CERT-HASH-020` closed when the profile used the same
  sorted compact certification projection as simplify. Row 432 exited zero.

Five findings remain open and appear in the table above.
`F-B037-TEST-BOUNDARY-002` remains a low routed observation.
`F-B037-TEST-BOUNDARY-009` remains a low routed observation.

### Evidence receipts

| Row | Exit | Result |
| --- | ---: | --- |
| 421 | 3 | Initial baseline preserved the non-Git and Xcode environment failures. |
| 422 | 1 | Corrected baseline isolated `test-mechanism-lint` as the sole red check. |
| 423 | 1 | Focused mechanism lint recorded all ten exact findings. |
| 424 | 0 | Malformed-YAML and wrong-lifecycle mutation probes executed. |
| 425 | 0 | Dual-Bash fidelity and generated-projection matrix passed. |
| 426 | 0 | Traceability guard exposed its empty-array proxy result. |
| 427 | 0 | Scenario, Test Plan, DoD, phase, and broad-receipt mapping completed. |
| 430 | 1 | Initial terminal profile reported one hidden invariant mismatch. |
| 431 | 1 | Failure detail identified the certification hash projection mismatch. |
| 432 | 0 | Corrected terminal profile passed every expected invariant. |

### Scoped verdict

`CRITICAL_GAPS_DETECTED` applies to this current-byte audit. The packet cannot
advance to `bubbles.harden`. Planning owns the first repair because two current
machine-readable planning surfaces fail or bypass their canonical validators.

<a name="bug037-plan-current-final-byte-reconciliation"></a>
## Scope: plan current-final-byte reconciliation - 2026-09-02

### Current planning evidence

**Phase:** bootstrap

**Claim Source:** executed

Tool-log row 437 runs `test-mechanism-lint.sh` after the ten closed-vocabulary
repairs. It exits zero and reports all 19 declared mechanisms coherent with
their scenario traits.

Tool-log row 438 runs `acceptance-authority-selftest.sh` on the current bytes.
It exits zero with 71 of 71 checks passing. The output names S1-T10 through
S1-T18, S2-T8, S4-T2, S4-T4, S4-T8, and S4-T10 through S4-T10b. Those exact
identities replace the three future-test sentinels and support classifying the
14 corresponding Test Plan rows as `existing`.

S4-T5, S4-T6, and S4-T7 remain `requires-revalidation`. This planning phase
did not run `framework-validate`, `release-check`, or `agnosticity` after the
simplify byte changes.

### Validation and finding accounting

**Phase:** bootstrap

**Claim Source:** executed

| Tool-log row | Check | Exit | Result |
| ---: | --- | ---: | --- |
| 438 | Focused acceptance authority suite | 0 | All 71 checks pass and all 14 reconciled Test Plan identities execute. |
| 439 | Scenario test resolver | 0 | All 30 literal test references resolve. |
| 440 | Scenario obligation lint | 0 | All 19 obligation matrices are coherent. |
| 441 | Traceability and Test Plan guard | 0 | All 19 scenarios map to tests, report evidence, and DoD. |
| 442 | Artifact lint | 0 | Packet shape and anti-fabrication checks pass. |
| 443 | Structured scenario and Test Plan parity | 0 | The 19-scenario sets match; 45 rows are `existing`; only S4-T5, S4-T6, and S4-T7 require revalidation. |
| 444 | Test mechanism lint on final manifest bytes | 0 | All 19 mechanisms use coherent closed-vocabulary values. |
| 446 | Replacement diff whitespace capture | 0 | The four plan-owned changed paths have no whitespace errors. |

`F-B037-GAPS-MECHANISM-VOCAB-014` and
`F-B037-GAPS-SCENARIO-LIFECYCLE-015` are resolved by this planning phase.

The following blockers remain unchanged:

- `F-B037-GAPS-AUTHORITY-YAML-016` remains owned by `bubbles.implement`.
- `F-B037-GAPS-LIFECYCLE-LABEL-017` remains owned by `bubbles.test`.
- `F-B037-GAPS-TRACEABILITY-EMPTY-REF-018` remains owned by `bubbles.bug`.
  It requires an independent complete bug packet for the traceability guard's
  empty-array false pass. This planning phase did not edit that guard.

Low observations `F-B037-TEST-BOUNDARY-002` and
`F-B037-TEST-BOUNDARY-009` remain preserved.

### Binding and change boundary

**Phase:** bootstrap

**Claim Source:** executed

Repository packet validation exited zero for session
`vscode-d6173f50fde08e4fc6fdf133dac19e92`, decision
`rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:4:node:reconcile-bug-037-validation-registry`,
control revision 4, root `/Users/pkirsanov/Projects/bubbles`, and alias
`bubbles`.

Changed paths are limited to:

- `bugs/BUG-037-uservalidation-opt-out-acceptance/scenario-manifest.json`
- `bugs/BUG-037-uservalidation-opt-out-acceptance/test-plan.json`
- `bugs/BUG-037-uservalidation-opt-out-acceptance/report.md`
- `bugs/BUG-037-uservalidation-opt-out-acceptance/state.json`

`scopes.md` already contained the exact scenarios and test rows, so it did not
need an edit. No source, test, generated, certification, status,
uservalidation, neighboring packet, downstream repository, Git-control, or
host surface changed.

<a name="bug037-implement-authority-yaml-016"></a>
## Scope: implement authority YAML structural rejection - 2026-09-02

### RED and implementation

**Phase:** implement

**Claim Source:** executed

Tool-log row 452 reproduced the current-byte defect. The contract-complete but
syntactically invalid authority fixture made preflight and both public verdicts
return `0` with empty output. Row 453 then ran the strengthened S1-T13b test
under macOS stock Bash. It exited `1` with 71 of 72 checks passing, and the only
failure reported both public verdicts at exit `0`, zero output lines, and zero
bootstrap codes.

The shared preflight now resolves Python through `python-env.sh` and performs a
silent PyYAML `safe_load` before any fixed-shape field reader runs. A missing
managed parser or YAML parse failure follows the existing bootstrap path. It
emits exactly one `PD12-AUTHORITY-UNAVAILABLE: acceptance authority schema is
malformed` line and returns `1`. Parser diagnostics, registry contents, and the
registry path are suppressed.

S1-T13b copies the complete canonical registry and appends an unterminated YAML
sequence. Every contract token remains present, so the test distinguishes YAML
syntax validation from the existing text and cardinality checks. The existing
pair helper applies the fixture to both public verdicts and requires exit `1`,
one total output line, one bootstrap code, and no fixture path.

### Current focused evidence

**Phase:** implement

**Claim Source:** executed

| Tool-log row | Check | Exit | Result |
| ---: | --- | ---: | --- |
| 453 | Stock Bash S1-T13b RED | 1 | Exactly one new failure; both public verdicts still accepted invalid YAML. |
| 456 | Stock Bash authority GREEN | 0 | All 72 checks pass, including contract-complete invalid YAML. |
| 458 | Stock Bash persistent `test_35` | 0 | 13 passed and 0 failed. |
| 459 | Homebrew Bash persistent `test_35` | 0 | 13 passed and 0 failed. |
| 460-463 | Library and selftest syntax under both Bash runtimes | 0 | All four syntax checks pass with empty stderr. |
| 464 | Pre-regeneration release-manifest freshness | 1 | Correctly reported stale generated bytes after source and test edits. |
| 465 | Release-manifest generator | 0 | Generator refreshed `bubbles/release-manifest.json`. |
| 466 | Post-regeneration release-manifest freshness | 0 | Manifest 7.28.0 is current for 930 managed files. |
| 467 | Dual-Bash authority and persistent no-skip matrix | 0 | All four cases require exit 0 and zero skip tokens. |

The focused matrix uses `/bin/bash` and `/opt/homebrew/bin/bash` for both the
authority selftest and the persistent regression. It prints each complete test
output before counting skip tokens. Matrix exit `0` therefore means every case
returned `0` and each skip count was zero.

`framework-validate` and `release-check` were not run, as required by this
focused implementation assignment.

### Finding and route accounting

**Phase:** implement

**Claim Source:** executed

`F-B037-GAPS-AUTHORITY-YAML-016` is resolved by the source and focused test
changes above. `F-B037-GAPS-LIFECYCLE-LABEL-017` remains open and owned by
`bubbles.test`. `F-B037-GAPS-TRACEABILITY-EMPTY-REF-018` remains open and owned
by the independent `bubbles.bug` invocation. This implementation did not read
or edit the traceability guard or its packet.

Low observations `F-B037-TEST-BOUNDARY-002` and
`F-B037-TEST-BOUNDARY-009` remain preserved. Certification and top-level status
remain `in_progress`. The next required owner is `bubbles.test`.

<a name="bug037-test-revision-5-current-byte-replacement"></a>
## Scope: TEST revision-5 current-byte replacement bookkeeping - 2026-09-02

### Repository binding

**Phase:** test

**Claim Source:** executed

The goal-node packet and an in-memory re-derived scenario copy were passed as
regular `/dev/fd` inputs. The validator returned exit `0` before BUG-037
bookkeeping began.

```text
REPOSITORY PACKET SCOPED actionable=true repository=bubbles root=/Users/pkirsanov/Projects/bubbles decision=rb:vscode-d6173f50fde08e4fc6fdf133dac19e92:5:node:reconcile-bug-037-validation-registry revision=5 scopeKind=goal-node scopeId=reconcile-bug-037-validation-registry
BUG037_BINDING_VALIDATION_EXIT=0
BUG037_DERIVED_REPOSITORY_ROOT=/Users/pkirsanov/Projects/bubbles
BUG037_DERIVED_REPOSITORY_ALIAS=bubbles
```

### Replacement receipt and current-byte closure

**Phase:** test

**Claim Source:** interpreted

**Interpretation:** Tool-log row 495 records the existing revision-5 matrix at
exit `0`. Its harness increments an aggregate failure count for every non-zero
case and for every changed input digest, then returns non-zero unless that count
is zero. Reading the unchanged harness and focused tests therefore maps the
receipt to the requested cases without rerunning the matrix.

Row 495 records duration `40917ms`, stdout hash
`06c0e2a1807200473cf32938b205fa9b4a785ac0a04c033bfc03724a67fd113f`,
empty-stderr hash
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`,
and 23 input-closure entries. The focused selftest entry is exactly
`ce91dffcdf52531ef15b664f1224b8badf0bfb9b2aa6c0ac20ddef0155d749f3`.

The current closure comparison returned:

```text
BUG037_ROW495_CLOSURE_BEGIN count=23
CLOSURE path=bugs/BUG-037-uservalidation-opt-out-acceptance/scenario-manifest.json status=MATCH sha256=e10c73e6e131c080ac4b321663094507e6c268c4950c5c53be4adff279566bca
CLOSURE path=bugs/BUG-037-uservalidation-opt-out-acceptance/test-plan.json status=MATCH sha256=96dfee5146df57c8a16de01107702f8548e021efd967d48823760d485610c6c5
CLOSURE path=bugs/BUG-037-uservalidation-opt-out-acceptance/scopes.md status=MATCH sha256=7a495b9a5c75b865c4c0662d39bca5ec7d8aba9e4ada5fa56442a3175853791e
CLOSURE path=bubbles/scripts/acceptance-authority-selftest.sh status=MATCH sha256=ce91dffcdf52531ef15b664f1224b8badf0bfb9b2aa6c0ac20ddef0155d749f3
CLOSURE path=bubbles/scripts/acceptance-authority-lib.sh status=MATCH sha256=676fbb3d9859691a480ded4bbfc73d3f88e98ecdafb9fde8de5dc89dfbffa4c3
CLOSURE path=bubbles/registry/acceptance-authority.yaml status=MATCH sha256=bf34f50592074689675d8b90d6c4ddf8033fbccc974fc2f13f1eeda609dd587d
CLOSURE path=tests/regression/test_35_human_acceptance_terminal.sh status=MATCH sha256=da65cee61e5abe58ac3b74bb58505885c80d6048ab2522d2c71bc9218fde7512
CLOSURE path=bubbles/scripts/state-transition-guard-selftest.sh status=MATCH sha256=25d1e95156a83707cb39bf8a209f9a82a6e487dba7ffcee6896ff2dfbf6038a7
CLOSURE path=bubbles/registry/gates.yaml status=MATCH sha256=bafb5b87664f5aad085e5d7c5e2e1de3247fea1887a6f5e68b455b1362ced38d
CLOSURE path=CHANGELOG.md status=MATCH sha256=b76e79b4952e83f141c5fc638c5035fcbecc17e97709fd0059148a148386a214
ROW495_ACCEPTANCE_HASH=ce91dffcdf52531ef15b664f1224b8badf0bfb9b2aa6c0ac20ddef0155d749f3
ROW495_MISSING=0
ROW495_MISMATCHES=0
ROW495_MATRIX_RERUN_REQUIRED=false
BUG037_ROW495_CLOSURE_END
```

All 13 additional closure paths also matched and remain available in the raw
current-session command output. Because the mismatch count is zero, the matrix
was not rerun.

### Requested coverage disposition

**Phase:** test

**Claim Source:** interpreted

**Interpretation:** The row-495 command runs the current harness against the
exact hashes above. The harness executes scenario resolution, mechanism lint,
the authority selftest and persistent `test_35` under stock and Homebrew Bash,
four Bash syntax checks, and the bugfix regression-quality guard. Any non-zero
case or input mutation makes the aggregate command return non-zero.

- S1-T10e requires the exact lifecycle map: six `default-active` codes,
  `PD12-NO-RECORD` as `conditional-active`, and
  `PD12-AUTHORITY-UNAVAILABLE` as `bootstrap-active`.
- S1-T10f changes only the conditional lifecycle label to `default-active`.
  The lifecycle assertion must report a finding while authority preflight still
  returns `0` and the terminal verdict still reaches exactly one conditional
  `PD12-NO-RECORD` refusal. This is the mutation and non-vacuity proof.
- S1-T13b preserves every canonical contract token, adds an unterminated YAML
  sequence, and uses the pair helper that invokes both public verdicts. Each
  verdict must return `1` with one sanitized bootstrap finding.
- The matrix runs the 13-check persistent G136 regression under both Bash
  runtimes, resolves the scenario links, checks declared mechanisms, checks
  library and selftest syntax under both runtimes, and runs the bugfix
  regression-quality guard.

`F-B037-GAPS-AUTHORITY-YAML-016` is independently verified by TEST without
changing its implementation ownership. `F-B037-GAPS-LIFECYCLE-LABEL-017` is
resolved by the exact-label and mutation cases. The two low boundary
observations remain recorded.

`F-B037-GAPS-TRACEABILITY-EMPTY-REF-018` remains open. It is packeted at
`bugs/BUG-045-traceability-empty-evidence-refs`, whose current state is
`implemented` and still routes to `bubbles.test` for independent verification.
BUG-037 does not consume that dependency as complete and does not edit BUG-045.

Top-level status and every `certification.*` field remain unchanged. No source,
registry, generated, uservalidation, neighboring packet, session, Git-control,
or host surface was edited by this bookkeeping step.




