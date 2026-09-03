# Specification: BUG-037 — Opt-Out User Acceptance

Expected behavior for `uservalidation.md` acceptance, stated independently of
the current implementation. This is the contract the fix must satisfy.

---

## 1. Problem statement

The framework's human-acceptance surface currently implements **opt-in**
acceptance: the artifact ships with every acceptance item unchecked, and a
terminal (`done`) transition requires the user to check every item AND author a
separate `## Human Acceptance Record`.

The repository owner's standing requirement is **opt-out** acceptance:

> "uservalidation must be create checked by default, only if user chooses to
> uncheck, then agent must fix, then user validates and checks; if user does not
> uncheck anything, it must be takes as user acceptance"

Under opt-out, a satisfied user performs **no** action. Under the shipped
implementation, a satisfied user cannot reach terminal at all. The two models
are incompatible, and the shipped one is wrong.

Separately, four governance surfaces describe the acceptance contract as it
existed *before* commit `9e41da4` and are false at HEAD regardless of which
model is chosen.

---

## 2. Acceptance model — normative

### AC-1 — The artifact ships CHECKED

The `## Checklist` section of a newly authored `uservalidation.md` ships with
every acceptance item **checked** (`- [x]`). Automation authors that initial
checked state as part of normal artifact creation.

### AC-2 — Unchecking is the user's only required act

The user reviews the delivered behavior. If a behavior does not meet their
expectation, the user **unchecks** that item. Unchecking is the sole mechanism
by which a user rejects delivered behavior.

### AC-3 — Silence is acceptance

If the user unchecks nothing, that is acceptance. No further artifact, record,
signature, timestamp, or affirmative act is required for a terminal transition.

### AC-4 — An unchecked item BLOCKS a terminal transition

An unchecked acceptance item at a terminal transition is a **user-reported
regression**. Gate G136 refuses the transition and names the unchecked item.
This preserves the BUG-029 closure: one checked plus five unchecked is still
refused.

### AC-5 — The guard never edits the artifact

The terminal gate prints each unchecked item and stops. It MUST NOT check a box.
Checking on the author's behalf would erase the only signal the user has for
rejecting work.

### AC-6 — The USER re-checks after a fix

When an unchecked item is fixed, the **user** re-checks it. No agent, guard,
lint, or automation re-checks an item the user unchecked. An agent that
re-checks a user-unchecked item has erased a rejection.

### AC-7 — The human acceptance record is OPTIONAL

`## Human Acceptance Record` MUST NOT be required at a terminal transition,
because AC-3 makes no-uncheck the acceptance. The section remains **available**
for external UAT, explicit sign-off, or compliance contexts where a named
acceptor is wanted.

### AC-8 — Record validation still applies WHEN present

If a `## Human Acceptance Record` is authored, its existing shape rules
continue to hold in full: required fields (`acceptedBy`, `acceptedAt`,
`method`), the closed `method` vocabulary, method-conditional fields, and the
prohibition on `acceptedBy` matching `^bubbles\.`. An agent still cannot accept
on a human's behalf; it simply is no longer forced to try.

### AC-9 — Automation readiness stays, and grants nothing

`## Automation Readiness` remains an **OPTIONAL** section, written and checked
by automation, recording that the behavior was verified far enough to be worth
the user's time. A fully checked readiness block satisfies **no** acceptance
obligation. It MUST NOT be deleted.

---

## 3. Governance-consistency requirements — normative

### GC-1 — No surface may describe a deleted lint rule

No surface may assert that `artifact-lint.sh` requires the checklist to carry at
least one checked `[x]` entry unless that requirement is actually present in
`artifact-lint.sh` at the same commit.

### GC-2 — G136's description matches G136's behavior

`bubbles/registry/gates.yaml` `G136.description` must describe the refusal codes
Check 43 actually emits, the sections it actually reads, and the terminal
condition it actually applies.

### GC-3 — Prose restatements agree with the registry

`agents/bubbles_shared/quality-gates.md`,
`agents/bubbles_shared/test-core.md`, and
`skills/bubbles-quality-gates-catalog/SKILL.md` must agree with
`gates.yaml` and with `bubbles/registry/acceptance-authority.yaml`.

### GC-4 — Downstream-visible contract changes are changelogged

A change to a downstream-shipped artifact template or its lint contract requires
a `CHANGELOG.md` entry. The PD-12 change has none; this fix supplies one, and
corrects the existing BUG-029 entry that now states a superseded contract as
current.

### GC-5 — Generated artifacts are regenerated, never hand-edited

`docs/generated/gate-coverage-map.md`,
`bubbles/registry/validation-checks.yaml`, and
`bubbles/release-manifest.json` are generated. They are refreshed by running
their generators.

---

## 4. Explicit non-goals

| Not in scope | Why |
|---|---|
| Reopening BUG-029 | AC-4 preserves its closure exactly. |
| Deleting `## Automation Readiness` | AC-9 keeps it. |
| Deleting `## Human Acceptance Record` | AC-7 keeps it, optional. |
| Weakening the `^bubbles\.` acceptor prohibition | AC-8 keeps it in force when a record is present. |
| Letting the guard edit `uservalidation.md` | AC-5 forbids it. |
| Retrofitting existing `bugs/` and `specs/` artifacts | Out of scope; migration posture is a design decision, recorded in `design.md`. |

---

## 5. What mechanism can and cannot prove

Recorded so the trade is deliberate rather than discovered later.

Under opt-out, no file check can distinguish *"the user reviewed this and was
satisfied"* from *"the user never opened the file"*. Both look identical: a
checked box that automation wrote.

PD-12 existed to close exactly that gap, by demanding a separately authored
record that an agent could only produce by writing a deliberate lie rather than
by using the template. The owner has decided that the cost of that proof — a
satisfied user must perform two positive acts before work can be called done —
exceeds its value in this repository's operating model.

This specification records that decision as a **deliberate trade**, not as an
oversight. The fix must not later be read as an accident to be "corrected" back.
The BUG-029 protection (AC-4) is retained precisely because it is the part of
the protection that costs a satisfied user nothing.

---

## 6. Gherkin scenarios

```gherkin
Feature: Opt-out user acceptance of delivered behavior

  Scenario: A satisfied user who unchecks nothing reaches terminal
    Given a uservalidation.md authored from the current framework template
      And every acceptance item under "## Checklist" is checked
      And no "## Human Acceptance Record" section is present
    When a terminal transition to "done" is evaluated
    Then the acceptance verdict returns success
      And no PD12-NO-RECORD finding is emitted

  Scenario: A user-reported regression blocks terminal
    Given a uservalidation.md whose "## Checklist" has five checked items
      And one item the user has unchecked
    When a terminal transition to "done" is evaluated
    Then the acceptance verdict fails
      And the unchecked item is named in the refusal
      And the file is not modified by the guard

  Scenario: BUG-029 stays closed
    Given a uservalidation.md whose "## Checklist" has one checked item
      And five unchecked items
    When a terminal transition to "done" is evaluated
    Then the acceptance verdict fails
      And every one of the five unchecked items is named

  Scenario: An optional acceptance record is still validated when present
    Given a uservalidation.md with every acceptance item checked
      And a "## Human Acceptance Record" whose acceptedBy is "bubbles.validate"
    When the acceptance shape verdict is evaluated
    Then the verdict fails with an automation-acceptor finding

  Scenario: A checked automation readiness block grants no acceptance
    Given a uservalidation.md whose "## Automation Readiness" items are all checked
      And whose "## Checklist" carries one unchecked item
    When a terminal transition to "done" is evaluated
    Then the acceptance verdict fails on the unchecked checklist item

  Scenario: No governance surface describes a lint rule that does not exist
    Given the repository at the delivering commit
    When every surface describing Gate G136 is compared to artifact-lint.sh
    Then no surface asserts a lint requirement absent from artifact-lint.sh
```

---

## 7. Product Principle Alignment

The `bubbles` source repository has no `docs/Product-Principles.md`. The
governing authority is the anti-fabrication and evidence-integrity posture in
`.github/instructions/bubbles-kernel.instructions.md` and
`agents/bubbles_shared/critical-requirements.md`.

This specification is in tension with that posture on exactly one axis, and the
tension is declared rather than hidden: opt-out acceptance means a checked box
is no longer proof of a human act. Section 5 records that as an owner decision
with its cost stated. Every other anti-fabrication property is preserved: the
guard still never edits the artifact (AC-5), an agent still cannot name itself
as acceptor (AC-8), and an unchecked item still blocks (AC-4).
