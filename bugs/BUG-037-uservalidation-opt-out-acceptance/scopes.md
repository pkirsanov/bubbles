# BUG-037 Scopes

Four sequential scopes. Scope 1 changes the single authority every later scope
reads, so it lands first. Each scope is independently testable and carries its
own adversarial bound.

Every DoD item ships **unchecked**. An item is checked only when the executed
evidence backing it exists in [report.md](report.md).

---

## Scope 1 — Invert the acceptance contract and the shared reader

**Status:** [x] Done
**Depends on:** nothing
**Delivers:** AC-1, AC-3, AC-4, AC-5, AC-7, AC-8, AC-9

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-001 A satisfied user who unchecks nothing reaches terminal
  Given a uservalidation.md whose "## Checklist" items are all checked
    And which carries no "## Human Acceptance Record" section
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns 0
    And it emits no PD12-NO-RECORD finding

Scenario: SCN-B037-002 A user-reported regression still blocks terminal
  Given a uservalidation.md whose "## Checklist" has five checked items
    And one item the user has unchecked
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns non-zero
    And the unchecked item is named in a PD12-UNCHECKED-ITEM finding

Scenario: SCN-B037-003 BUG-029 stays closed
  Given a uservalidation.md whose "## Checklist" has one checked item
    And five unchecked items
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns non-zero
    And every one of the five unchecked items is named

Scenario: SCN-B037-004 An optional record is still validated when present
  Given a uservalidation.md whose "## Checklist" items are all checked
    And a "## Human Acceptance Record" whose acceptedBy is "bubbles.validate"
  When bubbles_acceptance_shape_verdict is evaluated
  Then it returns non-zero
    And it emits PD12-AUTOMATION-ACCEPTOR

Scenario: SCN-B037-005 Checked automation readiness grants no acceptance
  Given a uservalidation.md whose "## Automation Readiness" items are all checked
    And whose "## Checklist" carries one unchecked item
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns non-zero on the unchecked checklist item
```

### Implementation Plan

1. `bubbles/registry/acceptance-authority.yaml`
   - `acceptance-checklist.shippedState` → `checked`
   - `acceptance-record.requiredAtTerminal` → `false`
   - Rewrite the file-header rationale. It currently argues the opt-in position
     at length; leaving it in place would make the registry disagree with its
     own data.
   - Apply **D-5** concretely: remove `PD12-NO-RECORD` from `failureCodes`
     (nothing can emit it any more), RETAIN the other six codes with their
     names and meanings unchanged, and add a header note recording that the
     `PD12-*` prefix is historical and that `PD12-NO-RECORD` is retired — so a
     reader who greps that code in an archived evidence block can find out what
     happened to it.
2. `bubbles/scripts/acceptance-authority-lib.sh`
   - `bubbles_acceptance_terminal_verdict` no longer emits `PD12-NO-RECORD`.
   - Everything else is unchanged. `bubbles_acceptance_shape_verdict` already
     validates the record only when authored, so AC-8 needs no code change —
     confirm this by test rather than by reading.
3. `bubbles/scripts/acceptance-authority-selftest.sh`
   - Add the five scenarios above plus the adversarial bounds.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S1-T1 | Fully checked, no record → terminal verdict returns 0 | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T2 | One unchecked among five checked → refused, item named | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T3 | BUG-029 shape (1 checked, 5 unchecked) → refused, all five named | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T4 | Present record with `bubbles.` acceptor → shape verdict refuses | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T5 | Present record missing `acceptedAt` → `PD12-RECORD-INCOMPLETE` | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T6 | Present record with `method: external-record` and no `record` → `PD12-METHOD-FIELD-MISSING` | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T7 | Readiness all checked + one checklist unchecked → refused | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T8 | Registry values are READ, not hardcoded: flipping `requiredAtTerminal` back in a fixture registry restores the refusal | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T9 | `[ ]` under `## Notes` is still ignored | unit | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S1-T10 | **D-5 code-set closure:** the set of `PD12-*` codes the library can emit equals the set `failureCodes` declares — `PD12-NO-RECORD` appears in neither | unit (adversarial) | `bubbles/scripts/acceptance-authority-selftest.sh` |

**S1-T8 is the load-bearing adversarial case.** Without it, the implementation
could satisfy every other test by deleting the record check outright while
claiming to read the registry.

**S1-T10 exists because D-5 removes exactly one code from a closed set.** It
catches both halves of the likely mistake: deleting the emission but leaving the
code declared, and deleting the declaration while an emitter survives.

### Definition of Done

- [x] Failing reproduction captured BEFORE the change, with its real exit code
      → Evidence: [report.md](report.md#red-scope-1)
- [x] `acceptance-authority.yaml` inverted, header rationale rewritten to match
      → Evidence: [report.md](report.md#scope-1)
- [x] `acceptance-authority-lib.sh` terminal verdict no longer requires a record
      → Evidence: [report.md](report.md#scope-1)
- [x] SCN-B037-001 passes with a real exit code
      → Evidence: [report.md](report.md#green-scope-1)
- [x] SCN-B037-002 and SCN-B037-003 still REFUSE — BUG-029 pin proven intact
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] SCN-B037-004 still REFUSES — record validation survives the optionality
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] SCN-B037-005 still REFUSES — readiness grants nothing
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] S1-T8 adversarial case fails when the registry value is reverted
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] D-5 applied: `PD12-NO-RECORD` removed from `failureCodes`, six codes
      retained verbatim, retirement recorded in the header note
      → Evidence: [design.md](design.md), [report.md](report.md#scope-1)
- [x] S1-T10 proves the emittable code set equals the declared code set
      → Evidence: [report.md](report.md#bounds-scope-1)
- [x] `acceptance-authority-selftest.sh` passes end to end, zero skipped
      → Evidence: [report.md](report.md#green-scope-1)
- [x] No regression test contains a conditional early-return that silently passes
      → Evidence: [report.md](report.md#scope-1)

---

## Scope 2 — Template, lint, and authoring agents

**Status:** [x] Done
**Depends on:** Scope 1
**Delivers:** AC-1, AC-6, AC-9, and design decisions D-1, D-2, D-3

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-006 A uservalidation.md authored from the template reaches terminal unaided
  Given a uservalidation.md materialized verbatim from the current
        feature-templates.md uservalidation template
    And the placeholder text has been replaced with real behavior descriptions
  When bubbles_acceptance_terminal_verdict is evaluated
  Then it returns 0

Scenario: SCN-B037-007 Lint accepts a fully unchecked checklist
  Given a uservalidation.md whose "## Checklist" items are all unchecked
  When artifact-lint.sh runs over the containing packet
  Then the uservalidation shape checks pass
    And no failure demands a checked entry

Scenario: SCN-B037-008 Lint still rejects a malformed checklist
  Given a uservalidation.md whose "## Checklist" carries a non-checkbox bullet
  When artifact-lint.sh runs over the containing packet
  Then it fails on the non-checkbox bullet
```

### Implementation Plan

1. `agents/bubbles_shared/feature-templates.md`
   - `## Checklist` ships `- [x]`.
   - Rewrite the rules block. Remove the "Acceptance entries ship UNCHECKED
     (IMP-047 PD-12)" rule and its rationale paragraph.
   - Replace the terminal rule with the opt-out contract.
   - Apply **D-3**: restate the `bubbles.journey` rule so it names the three-way
     split — automation MAY author the initial checked state, automation MUST
     NOT re-check a user's uncheck, automation MUST NOT toggle to mirror test
     outcomes — and record that only the first is mechanically checkable, since
     rows two and three produce a byte-identical `- [x]`. **Do NOT carve an
     auto-check exception into the journey rule.** The authoring permission
     belongs to `bubbles.plan`, which creates the artifact; `bubbles.journey`
     runs later against an existing file and never has a legitimate reason to
     write a `[x]`, so its prohibition stays absolute and unqualified.
2. `bubbles/scripts/artifact-lint.sh` — **D-2 ruled NO restoration.** The
   checklist rules are UNCHANGED: no `[x]` requirement is reintroduced. The only
   edit is the stale comment block at lines ~555-563, which explains a PD-12
   rationale that no longer holds; rewrite it to state that the checked shipped
   state now comes from `acceptance-authority.yaml`'s contract rather than from
   a lint refusal, and that lint deliberately keeps only the shape questions.
3. `bubbles/registry/bug-packet.yaml` — invert the `uservalidation.md` purpose
   text at line ~47, which currently says "shipped UNCHECKED".
4. Sweep `agents/bubbles.*.agent.md` and `agents/bubbles_shared/*.md` for
   acceptance-model claims. **Already performed by `bubbles.design`** — see
   [design.md](design.md) § 2.5. The sweep returned three hits outside the known
   stale surfaces, and **all three already agree with the new model**:
   `bubbles.plan.agent.md:230` ("Create with checked-by-default baseline
   template") and `bubbles.journey.agent.md:72,89` (the absolute no-auto-check
   rule D-3 keeps). **No agent file requires a change, and no `allowedPaths`
   expansion is needed.** Re-run the sweep at the delivering commit to confirm
   the result is unchanged.
5. Apply **D-1**: dated grandfather, documented not automated. Concretely —
   author **no** migration script, perform **no** bulk auto-check, and modify
   **no** `uservalidation.md` outside this packet. The cutover note ships as
   `CHANGELOG.md` content in Scope 4. The four legacy PD-12-shaped files
   (`BUG-033`, `BUG-035`, `BUG-036`, and this packet's own) are re-authored into
   the checked shape by each packet's own owner as ordinary work on that packet,
   before that packet's own terminal transition — not here.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S2-T1 | Template materialization reaches terminal with no human act | integration | `bubbles/scripts/acceptance-authority-selftest.sh` |
| S2-T2 | **Template↔registry agreement:** the uservalidation template block in `feature-templates.md` agrees with `acceptance-authority.yaml` on both section headings AND `acceptance-checklist.shippedState` | unit | new or extended selftest |
| S2-T3 | Lint passes on a fully unchecked checklist | unit | `bubbles/scripts/artifact-lint.sh` over a fixture packet |
| S2-T4 | Lint still fails on a non-checkbox bullet | unit (adversarial) | `bubbles/scripts/artifact-lint.sh` over a fixture packet |
| S2-T5 | Lint still fails on a checklist with zero checkbox entries | unit (adversarial) | `bubbles/scripts/artifact-lint.sh` over a fixture packet |
| S2-T6 | No `agents/**` file asserts acceptance items ship unchecked | unit | grep-based conformance check |
| S2-T7 | `bug-packet.yaml` uservalidation purpose agrees with `acceptance-authority.yaml` | unit | `bubbles/scripts/bug-packet-selftest.sh` |
| S2-T8 | **D-1 bound:** the delivering commit modifies no `uservalidation.md` outside `bugs/BUG-037-*` | unit (adversarial) | conformance check over the commit's changed-file set |
| S2-T9 | **S2-T2's adversarial partner:** a fixture template block shipping `- [ ]` FAILS the agreement check | unit (adversarial) | same surface as S2-T2 |

**S2-T4 and S2-T5 are the lint-relaxation bounds.** They prove the D-2 ruling
did not widen into "lint no longer reads the checklist at all".

**S2-T2 is load-bearing, not incidental.** D-2 declines to restore the
≥1-checked lint rule, which removes the only mechanical detector of a template
authored in the wrong shipped state. S2-T2 replaces exactly that assurance and
nothing more, and S2-T9 proves S2-T2 can actually fail.

**S2-T8 is the D-1 bound.** It proves the migration posture was documented
rather than executed — a bulk auto-check would pass every other test in this
table.

### Definition of Done

- [x] Template `## Checklist` ships `- [x]`
      → Evidence: [report.md](report.md#scope-2-file-state-re-check--the-dod-items-that-are-not-selftest-cases) (T1: the block read off disk)
- [x] Template rules block rewritten; no rule asserts unchecked shipping
      → Evidence: [report.md](report.md#scope-2-file-state-re-check--the-dod-items-that-are-not-selftest-cases) (T2: zero hits across `agents/`; S2-T6 in command 1)
- [x] D-3 three-way split stated in the template; the `bubbles.journey`
      prohibition remains absolute with NO auto-check exception carved into it
      → Evidence: [design.md](design.md), [report.md](report.md#scope-2-file-state-re-check--the-dod-items-that-are-not-selftest-cases) (T3: lines 338-339)
- [x] D-2 applied: `artifact-lint.sh` checklist RULES unchanged; only the stale
      lines ~555-563 comment block rewritten
      → Evidence: [design.md](design.md), [report.md](report.md#d-2-proof--the-artifact-lintsh-diff-is-comment-and-message-only) — narrowed: three hunks, zero control-flow change; hunk 3 is a refusal-label string beyond the literal wording and is disclosed there
- [x] SCN-B037-006 passes: a template materialization reaches terminal unaided
      → Evidence: [report.md](report.md#scope-2-verification--commands-and-real-exit-codes) (S2-T1, exit 0)
- [x] S2-T4 and S2-T5 still FAIL as designed — lint did not go blind
      → Evidence: [report.md](report.md#bounds-scope-2)
- [x] S2-T2 passes and S2-T9 FAILS as designed — the template↔registry check
      replaces the backstop D-2 declined to restore, and can actually refuse
      → Evidence: [report.md](report.md#bounds-scope-2)
- [x] `bug-packet.yaml` purpose text inverted
      → Evidence: [report.md](report.md#scope-2-verification--commands-and-real-exit-codes) (S2-T7: purpose agrees with the registry, shipped checked)
- [x] `agents/**` sweep re-run at the delivering commit; result matches
      [design.md](design.md) § 2.5 — no agent file changed, no `allowedPaths`
      expansion taken
      → Evidence: [report.md](report.md#the-agents-sweep-re-run-at-this-commit)
- [x] D-1 applied: no migration script authored, no bulk auto-check performed,
      and S2-T8 proves no foreign `uservalidation.md` was modified
      → Evidence: [report.md](report.md#bounds-scope-2) — narrowed: S2-T8 proves no `[ ]`→`[x]` flip (the AC-6 invariant), not untouched-ness; the disclosure names the unrelated in-flight `BUG-033` edit
- [x] `artifact-lint.sh` passes on this bug packet itself
      → Evidence: [report.md](report.md#scope-2-closeout-re-lint) (exit 0, re-run after the boxes were checked)

---

## Scope 3 — Guard Check 43 and the regression surfaces

**Status:** [x] Done
**Depends on:** Scope 1
**Delivers:** AC-4, AC-5

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-009 Check 43 passes a fully checked checklist with no record
  Given a spec packet whose resolved target status is "done"
    And whose uservalidation.md has every acceptance item checked
    And which carries no "## Human Acceptance Record"
  When the state transition guard runs Check 43
  Then Check 43 passes

Scenario: SCN-B037-010 Check 43 refuses an unchecked item and names it
  Given a spec packet whose resolved target status is "done"
    And whose uservalidation.md carries one unchecked acceptance item
  When the state transition guard runs Check 43
  Then Check 43 fails
    And the refusal names the unchecked item
    And the refusal text describes the opt-out contract, not an acceptance record

Scenario: SCN-B037-011 The guard never edits uservalidation.md
  Given a spec packet that Check 43 will refuse
  When the state transition guard runs Check 43
  Then the sha256 of uservalidation.md is unchanged

Scenario: SCN-B037-012 A ceiling-bound mode is still exempt
  Given a spec packet whose resolved target status is not "done"
    And whose uservalidation.md carries unchecked acceptance items
  When the state transition guard runs Check 43
  Then Check 43 passes without evaluating acceptance
```

### Implementation Plan

1. `bubbles/scripts/guards/tail-delegated-gates.sh` Check 43
   - The header comment block (lines ~496-522) explains the PD-12 rationale and
     must be rewritten to the opt-out contract.
   - The `fail` message and the `info` lines that follow it currently point the
     reader at the acceptance record and at
     `bubbles/registry/acceptance-authority.yaml`; the registry pointer stays,
     the record narrative changes.
   - The `pass` message asserts "and a human acceptance record is present" —
     that clause must go.
   - Check 43's scope rule (runs only when target status is `done`) is unchanged
     and must be proven still intact by SCN-B037-012.
2. `bubbles/scripts/state-transition-guard-selftest.sh` (Check 43 cases, ~line 5104)
   - Update the cases to the new terminal contract. **Keep the BUG-029 case.**
3. `tests/regression/test_35_human_acceptance_terminal.sh`
   - Keep fixtures 1, 2 and 3 and their BUG-029 assertions.
   - Invert the PD-12 assertion at line ~122: a fully checked list with no
     acceptance record now returns zero findings.
   - Add an adversarial case asserting an unchecked item still yields
     `PD12-UNCHECKED-ITEM`.
   - Update the file header comment, which narrates the PD-12 rationale.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S3-T1 | Check 43 passes a fully checked, record-less packet at `done` | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T2 | Check 43 refuses one unchecked item and names it | functional (adversarial) | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T3 | BUG-029 shape still refused end to end through the real guard | functional (adversarial) | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T4 | `uservalidation.md` sha256 unchanged across a refusing guard run | functional (adversarial) | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T5 | Ceiling-bound target status still exempt | functional | `bubbles/scripts/state-transition-guard-selftest.sh` |
| S3-T6 | `test_35` BUG-029 fixtures still detect their unchecked items | unit | `tests/regression/test_35_human_acceptance_terminal.sh` |
| S3-T7 | `test_35` fully-checked record-less fixture now returns zero findings | unit | `tests/regression/test_35_human_acceptance_terminal.sh` |
| S3-T8 | `test_35` still sources the shared library rather than re-parsing | unit (adversarial) | `tests/regression/test_35_human_acceptance_terminal.sh` |
| S3-T9 | Check 43 refusal text contains no stale acceptance-record demand | unit | grep-based conformance check |

**S3-T4 is the AC-5 proof.** A guard that "helpfully" checked the box would pass
every other test in this table.

### Definition of Done

- [x] Check 43 header comment, `fail`, `info` and `pass` text all rewritten
      → Evidence: [report.md](report.md#scope-3) (S3-T9 grep conformance: 9 emitted
      lines, 0 stale acceptance-record demands; the `pass` clause "and a human
      acceptance record is present" is gone; registry pointer retained)
- [x] SCN-B037-009 passes through the REAL guard, not through the library alone
      → Evidence: [report.md](report.md#green-scope-3) (S3-T1 via
      `BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=0`; S3-T0 refuses an empty
      Check 43 section so the pass cannot rest on absence)
- [x] SCN-B037-010 refuses and names the item
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T2 asserts
      `BLOCK:.*Gate G136` plus `PD12-UNCHECKED-ITEM: - [ ] Deleting an item…`;
      S3-T2b asserts the refusal names no acceptance record)
- [x] SCN-B037-011 proven by sha256 comparison before and after
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T4, the AC-5 proof:
      hash before, REFUSING guard run, hash after, compared)
- [x] SCN-B037-012 proven: ceiling-bound exemption intact
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T5 on the docs-only
      base fixture; guard fragment line 536 carries the scope rule)
- [x] BUG-029 pin proven intact end to end through the guard
      → Evidence: [report.md](report.md#bounds-scope-3) (S3-T3: refused through
      the real guard with all five items named)
- [x] `test_35` still sources the shared reader — no re-implemented parser
      → Evidence: [report.md](report.md#scope-3) (S3-T8 self-assertion passes;
      Check 43 likewise sources the library at fragment line 543 and defines zero
      local section parsers)
- [x] `state-transition-guard-selftest.sh` passes, zero skipped
      → Evidence: [report.md](report.md#green-scope-3) (exit 0, 527 lines,
      sha256 8e05bed1…f67b114; the harness has no skip channel — narrowing stated
      in the report)
- [x] `tests/regression/test_35_human_acceptance_terminal.sh` passes
      → Evidence: [report.md](report.md#green-scope-3) (exit 0, 13 passed,
      0 failed)

---

## Scope 4 — Governance documentation and generated artifacts

**Status:** [ ] Blocked — 11 of 13 DoD items met; S4-T5 `framework-validate` and
S4-T6 `release-check` are unmet. Their original blocker, the pre-existing OW-009
`guard-lib-timeout-selftest.sh` failure, is RESOLVED by
`bugs/BUG-038-progress-timeout-bsd-wc-padding/` (selftest now exit 0, sha256
`06054735b7d1ade85254102451e6ef7406693818baeb32d1b3c972efd6c7f102`).

The earlier bounded attempts recorded below did return exit 142 with no verdict,
and those records stay accurate for the attempts they describe. They are no
longer the operative blocker. A `framework-validate` run has since COMPLETED
with a real verdict: **exit 1, 5107 PASS / 31 FAIL**. That run was executed by a
CONCURRENT SESSION, not by this packet's session — **Claim Source: interpreted
(diagnostic input, not this packet's own execution evidence)**; see
[report.md](report.md) → "a run COMPLETED; the blocker is a repo-wide red".

The operative blocker is therefore a repository-wide RED verdict, not an
unobtainable one. NONE of the 31 failures is a BUG-037 defect and none lies in
this packet's `workBoundary.allowedPaths`; the failing surfaces
`v5.3-selftest.sh`, `mode-family-inventory-selftest.sh` and
`guard-lib-timeout-selftest.sh` are all clean at HEAD, i.e. pre-existing.
BUG-037's own behavior is GREEN in that completed run: 9 × `PASS: Check 43` with
zero failures matching Check 43 / acceptance / uservalidation / G136. S4-T5 and
S4-T6 stay unchecked because their DoD wording requires a **passing** run.
**Depends on:** Scopes 1, 2, 3
**Delivers:** GC-1 through GC-5

### Gherkin Scenarios

```gherkin
Scenario: SCN-B037-013 No surface describes a lint rule that does not exist
  Given the repository at the delivering commit
  When every surface describing Gate G136 is compared to artifact-lint.sh
  Then no surface asserts a lint requirement that artifact-lint.sh does not carry

Scenario: SCN-B037-014 The changelog records the contract change
  Given the repository at the delivering commit
  When CHANGELOG.md is read
  Then it carries an entry for the PD-12 acceptance-model change
    And it carries an entry for the BUG-037 inversion
    And the BUG-029 entry no longer states the superseded lint contract as current

Scenario: SCN-B037-015 Generated artifacts were regenerated, not hand-edited
  Given the repository at the delivering commit
  When each generator is re-run
  Then its output is byte-identical to the committed artifact
```

### Implementation Plan

1. `bubbles/registry/gates.yaml` `G136.description` — rewrite to describe the
   codes Check 43 actually emits, the sections it reads, and the opt-out
   terminal condition. Remove both false assertions.
2. `bubbles/registry/gates.yaml` `G057.description` — **amend; D-3 ruled this
   REQUIRED, not conditional.** Replace the single clause "uservalidation.md
   remains a human acceptance surface and MUST NOT be toggled to mirror
   automation outcomes" with the three-way split: automation MAY author the
   initial checked state; automation MUST NOT re-check a user's uncheck;
   automation MUST NOT toggle either way to mirror a test outcome. State
   plainly that only the first is mechanically checkable and that the other two
   are agent-instruction obligations this gate's enforcer does not verify —
   `guards/control-plane-checks.sh` never reads `uservalidation.md` at all, so
   the current wording already overstates what G057 does.
3. `agents/bubbles_shared/quality-gates.md` (line ~272) — replace stale text.
4. `agents/bubbles_shared/test-core.md` (lines ~300-310, "Human Acceptance Is
   Terminal") — replace stale text.
5. `skills/bubbles-quality-gates-catalog/SKILL.md` (G136 row, line ~57) —
   replace stale text. **This surface is stale today and was not in the
   originally reported set.**
6. `CHANGELOG.md` — add the BUG-037 entry; add the missing PD-12 entry; correct
   the BUG-029 entry at line ~1320, which states the pre-PD-12 contract as
   current. The BUG-037 entry MUST carry the **D-1 upgrade note**: it names the
   delivering commit as the cutover, warns that `uservalidation.md` files
   authored before it ship unchecked and will now read as user rejections,
   instructs each packet owner to re-author their checklist into the checked
   shape **before** the user reviews it, and states that once a user has
   unchecked an item nothing may re-check it. It also states that no migration
   script exists or will be shipped.
7. `BUGS.md` — index entry for BUG-037.
8. `improvements/INDEX.md` — **D-4 ruled: correct the sentence, touch nothing
   under `bugs/BUG-032-*`.** In the IMP-047 row, replace the sentence beginning
   "BUG-032 stays `in_progress`: closing it needs a human G136 acceptance
   record…" with the verbatim replacement text recorded in
   [design.md](design.md) § 3 D-4 — which keeps BUG-032 `in_progress` on its own
   `bubbles.docs` work, records that the G136 record requirement was removed by
   BUG-037, and states that BUG-032's checked state is legacy-shaped and must
   not be read as a fresh human acceptance.
9. Regenerate, do not hand-edit:
   - `docs/generated/gate-coverage-map.md` via `generate-gate-coverage-map.sh`
   - `bubbles/registry/validation-checks.yaml` via `generate-validation-checks.sh`
   - `bubbles/release-manifest.json` via `generate-release-manifest.sh`
10. Re-run the [design.md](design.md) § 2.5 verification sweep at the delivering
    commit and confirm the result is unchanged. **The sweep itself is already
    complete** — `bubbles.design` read every entry and recorded each as affected
    or ruled out; 16 of 16 need no change. This step is the confirmation, not
    the sweep, and it is mechanized as S4-T1.

### Test Plan

| ID | Test | Type | Surface |
|----|------|------|---------|
| S4-T1 | No repository surface asserts the deleted lint requirement | unit | grep-based conformance check |
| S4-T2 | `G136.description` names only refusal codes the guard emits | unit | conformance check against `acceptance-authority.yaml` `failureCodes` |
| S4-T3 | Each generator re-run produces byte-identical committed output | unit (adversarial) | `generate-gate-coverage-map-selftest.sh`, `generate-validation-checks-selftest.sh`, `generate-release-manifest.sh` |
| S4-T4 | `CHANGELOG.md` carries both new entries and the corrected BUG-029 entry | unit | grep-based conformance check |
| S4-T5 | `framework-validate.sh` passes end to end | functional | `bubbles/scripts/cli.sh framework-validate` |
| S4-T6 | `release-check` passes | functional | `bubbles/scripts/cli.sh release-check` |
| S4-T7 | `agnosticity` lint passes | functional | `bubbles/scripts/cli.sh agnosticity` |
| S4-T8 | **D-3 bound:** `G057.description` declares which of its three rules are mechanical and which are advisory, and asserts no enforcement its enforcer does not perform | unit | conformance check against `guards/control-plane-checks.sh` |
| S4-T9 | **D-4 bound:** the delivering commit modifies no path under `bugs/BUG-032-` | unit (adversarial) | conformance check over the commit's changed-file set |

**S4-T3 is the GC-5 proof.** A hand-edited generated file passes a text grep and
fails a regeneration diff.

**S4-T9 is the D-4 bound.** It proves BUG-032 was not closed, advanced, or
otherwise touched as a side effect of removing its stated blocker.

### Definition of Done

- [x] `G136.description` rewritten; both false assertions removed
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — the
      G136 block scanned in isolation: `false assertion A (lint requires >=1
      checked): False`, `false assertion B (template ships unchecked): False`)
- [x] `quality-gates.md` stale text replaced
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line 272
      now carries the OPT-OUT contract, the honest "what it proves" clause, and
      `PD12-NO-RECORD` recorded as retired)
- [x] `test-core.md` stale text replaced
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — the
      section is now "User Acceptance Is Terminal (… BUG-037, Gate G136)";
      acceptance is opt-out and the record is OPTIONAL and not required at
      terminal)
- [x] `skills/bubbles-quality-gates-catalog/SKILL.md` G136 row replaced
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line 57
      rewritten to the opt-out contract; rejection-channel framing retained)
- [x] `CHANGELOG.md` carries the BUG-037 entry AND the missing PD-12 entry
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line 34
      "User Acceptance Is Opt-Out Again (BUG-037)"; the backfilled entry "The
      Acceptance-Authority Change Had No Changelog Entry (IMP-047 PD-12)")
- [x] The BUG-037 changelog entry carries the D-1 upgrade note: cutover commit,
      legacy-file warning, re-author-before-review instruction, and the
      statement that no migration script ships
      → Evidence: [design.md](design.md), [report.md](report.md#scope-4)
      (**Phase:** implement — all four elements quoted from the UPGRADE NOTE,
      including "No migration script exists and none will be shipped" with its
      reason)
- [x] `CHANGELOG.md` BUG-029 entry corrected; it no longer states a superseded contract as current
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — line
      1396 now reads "Superseded in part by BUG-037" and states the lint rule as
      deleted-and-not-restored; one inverted "below"/"above" cross-reference was
      found and fixed during this closeout)
- [x] D-3 applied: `G057.description` carries the three-way split and declares
      rows 2 and 3 advisory; S4-T8 passes
      → Evidence: [design.md](design.md), [report.md](report.md#scope-4)
      (**Phase:** implement — S4-T8:
      `grep -c "uservalidation" bubbles/scripts/guards/control-plane-checks.sh`
      → `0`, so the advisory declaration is accurate)
- [x] D-4 applied: the `improvements/INDEX.md` IMP-047 sentence replaced with
      the verbatim design.md § 3 D-4 text, and S4-T9 proves nothing under
      `bugs/BUG-032-` was modified
      → Evidence: [report.md](report.md#bounds-scope-4) (**Phase:** implement —
      superseded sentence count `0`; S4-T9: `git status --porcelain` and
      `git diff HEAD --stat` over `bugs/BUG-032-*` both emitted zero lines)
- [x] Generated artifacts REGENERATED; regeneration diff is empty
      → Evidence: [report.md](report.md#bounds-scope-4) (**Phase:** implement —
      all three sha256 digests byte-identical across a second regeneration;
      `generate-validation-checks-selftest.sh` 10 checks / 0 failures;
      `generate-gate-coverage-map-selftest.sh` SKIPPED for absent PyYAML and
      declared as a skip, not counted as a pass)
- [ ] `framework-validate` passes end to end with a real exit code
      → Evidence: [report.md](report.md#green-scope-4) — **BLOCKED, NOT MET.**
      The run was cut at 1500s by SIGALRM and returned **exit 142** (9021 lines,
      sha256 8f506c77…8621ae). It neither passed nor failed; it produced no
      verdict. Blocked on the pre-existing OW-009 failure in
      `bubbles/scripts/guard-lib-timeout-selftest.sh` (4 failures, exit 1) — a
      file `git status`/`git diff HEAD` prove is unmodified from HEAD and that is
      absent from this packet's `workBoundary.allowedPaths`. Routed as finding
      OW-009; deliberately NOT fixed here. Also needs a wall-clock bound above
      1500s on this host.
- [ ] `release-check` passes with a real exit code
      → Evidence: [report.md](report.md#green-scope-4) — **BLOCKED, NOT MET.**
      Cut at 1500s by SIGALRM, **exit 142** (9021 lines, sha256 e21fb3d5…19b975).
      No verdict. Same OW-009 blocker and same wall-clock bound as the item
      above. The `Installer manifest check (v6.0 / B9)` failure in that run is a
      stripped-working-directory artifact, not a finding, and is not routed.
- [x] The design.md § 2.5 sweep re-run at the delivering commit returns the
      recorded result: 16 of 16 entries need no change
      → Evidence: [report.md](report.md#scope-4) (**Phase:** implement — 13
      ruled-out entries re-checked individually, all still `matches=0`; the 5
      claim-carrying/neutral entries quoted verbatim and unchanged; the
      repository-wide stale-text sweep returned grep exit 1, zero hits)
