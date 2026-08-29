# BUG-037: uservalidation.md acceptance is opt-in, contradicting the owner's opt-out requirement — and four governance surfaces still describe the pre-PD-12 world

- **Status:** Reported
- **Severity:** High
- **Reported:** 2026-08-23
- **Repository:** `bubbles` (framework SOURCE repo)
- **Affected version:** every commit from `9e41da4` (2026-08-17) to HEAD
- **Workflow mode:** `bugfix-fastlane`
- **Packet form:** `full` (see [Micro-Fix Admission](#micro-fix-admission))
- **Related:** BUG-029 (the defect G136 was created to close — see [BUG-029 Must Stay Closed](#bug-029-must-stay-closed)), IMP-047 S-D / PD-12

---

## Summary

`uservalidation.md` is the framework's human-acceptance surface. Commit
`9e41da4` inverted its acceptance model from **opt-out** (ships checked; the
user unchecks what they reject) to **opt-in** (ships unchecked; the user must
check every item AND author a separate `## Human Acceptance Record` before a
terminal transition is permitted).

Two distinct defects follow, and each is independently blocking.

**Half 1 — behavior diverged from the repository owner's standing
requirement.** The owner's requirement, stated verbatim:

> "uservalidation must be create checked by default, only if user chooses to
> uncheck, then agent must fix, then user validates and checks; if user does not
> uncheck anything, it must be takes as user acceptance"

The shipped behavior is the exact inverse. A user who has reviewed the delivered
behavior and objects to nothing is currently *unable* to reach terminal: silence
is read as refusal instead of as acceptance.

**Half 2 — governance documentation contradicts the shipped code.** `9e41da4`
changed the template, the lint and the guard, but left four prose surfaces
asserting rules that the same commit deleted. These are false RIGHT NOW,
independent of which acceptance model the owner ultimately wants, so they are a
defect in either direction.

---

## Environment

| Fact | Value |
|------|-------|
| Repository root | `/Users/pkirsanov/Projects/bubbles` |
| Repository alias | `bubbles` |
| Introducing commit | `9e41da42be80ce013390ebbb0fb1077d94e9fade` |
| Commit date | 2026-08-17 |
| Commit subject | `IMP-047 S-D: proportionate proof, micro-fix activated, PD-12 repair` |
| Shared reader | `bubbles/scripts/acceptance-authority-lib.sh` |
| Terminal consumer | `bubbles/scripts/guards/tail-delegated-gates.sh` Check 43 (Gate G136) |
| Shape consumer | `bubbles/scripts/artifact-lint.sh` |
| Contract authority | `bubbles/registry/acceptance-authority.yaml` |

---

## Half 1 — Acceptance model inverted

### What `9e41da4` changed

Verified from git history, not from memory. Before `9e41da4`,
`agents/bubbles_shared/feature-templates.md` shipped:

```markdown
# User Validation Checklist

## Checklist

- [x] Baseline checklist initialized for this feature
- [x] [Scenario or flow validated]
- [x] [Another validated flow]

Unchecked items indicate a user-reported regression.
```

with the rule, verbatim from `git show 9e41da4^`:

> - Entries created by agents after validation/audit MUST default to checked `[x]`.

and `artifact-lint.sh` at `9e41da4^` enforced it:

```bash
baseline_checked_lines="$({ echo "$checklist_section_content" | grep -E '^- \[x\] '; } || true)"
if [[ -z "$baseline_checked_lines" ]]; then
  fail "uservalidation checklist has no checked-by-default [x] entry"
```

After `9e41da4`:

| Surface | Before `9e41da4` | At HEAD |
|---------|------------------|---------|
| Template `## Checklist` | ships `- [x]` | ships `- [ ]` |
| Template rule | "MUST default to checked `[x]`" | "Acceptance entries ship UNCHECKED (IMP-047 PD-12)" |
| `artifact-lint.sh` | fails when no `[x]` present | requirement removed entirely |
| `## Automation Readiness` | did not exist | new section, automation-written, grants no acceptance |
| `## Human Acceptance Record` | did not exist | new section, `requiredAtTerminal: true` in the registry |
| Gate G136 terminal test | every item checked | every item checked AND an authored acceptance record |

### Why the inversion is the defect

Under opt-in, the terminal transition demands two positive acts from the user
(check every box, then author a record). Under the owner's requirement, the
terminal transition demands **zero** acts from a satisfied user: absence of an
uncheck IS the acceptance. The current implementation therefore cannot express
the accepted state that the owner defines as the normal case.

The gap is not cosmetic. It changes what "done" costs, in every downstream
repository that consumes the framework.

---

## Half 2 — Four governance surfaces are stale

Each of these describes `artifact-lint.sh` behavior that `9e41da4` deleted, and
each reproduces the reasoning PD-12 explicitly overturned. All four are false at
HEAD.

### 2.1 `bubbles/registry/gates.yaml` — `G136.description` (line ~1078)

Asserts, verbatim:

> `artifact-lint.sh` requires the checklist to carry at least ONE checked `[x]`
> entry and never rejects an unchecked one

False since `9e41da4`. Also asserts:

> Lint also runs during planning, where a checked-by-default template is
> legitimate

That is precisely the position PD-12 overturned in the same repository. The
description never mentions `## Human Acceptance Record`, `## Automation
Readiness`, or any `PD12-*` refusal code that Check 43 actually emits today, so
a reader who trusts the gate registry will build a mental model of Check 43 that
does not match a single line of its output.

### 2.2 `agents/bubbles_shared/quality-gates.md` (line ~272)

Same stale text, same two false assertions.

### 2.3 `agents/bubbles_shared/test-core.md` (line ~300, "Human Acceptance Is Terminal")

Same stale text at lines 304 and 309:

> Artifact lint requires the checklist to carry at least one checked `[x]` and …
> a checked-by-default template is legitimate — the template records what *will* be …

### 2.4 `CHANGELOG.md` has no PD-12 entry

`9e41da4` changed a downstream-visible artifact template and its lint contract.
There is no changelog entry for it. Worse, the only G136 entry that exists
(line ~1320, from the BUG-029 delivery) now carries the same two false
assertions:

> **Gate G136 — human acceptance is terminal (EV-8, BUG-029).** `artifact-lint.sh`
> requires one checked `[x]` and never rejects an unchecked one … Lint is the
> WRONG place to repair that … where a checked-by-default template is legitimate.

So the changelog is not merely silent about PD-12; it actively documents the
pre-PD-12 contract as current.

---

## Reproduction

Mechanical, hermetic, no repository mutation. Drives the SHARED reader that
`tail-delegated-gates.sh` Check 43 (Gate G136) itself sources, so the
reproduction and the guard cannot disagree.

### Step 1 — materialize `uservalidation.md` from the CURRENT template

Fixture written to `/tmp/bug037-repro/uservalidation.md` using the template
shape at `agents/bubbles_shared/feature-templates.md` lines 282-311: acceptance
items unchecked, readiness items checked, no `## Human Acceptance Record`.
Placeholder text was replaced with real behavior descriptions so no finding can
be attributed to unfilled template slots.

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

### Step 2 — drive the shared reader

**Executed:** YES
**Claim Source:** executed

```
$ bash -c 'source bubbles/scripts/acceptance-authority-lib.sh; \
    echo "--- shape verdict (planning-time) ---"; \
    bubbles_acceptance_shape_verdict /tmp/bug037-repro/uservalidation.md; echo "SHAPE_EXIT=$?"; \
    echo "--- terminal verdict (done transition, Gate G136 / Check 43) ---"; \
    bubbles_acceptance_terminal_verdict /tmp/bug037-repro/uservalidation.md; echo "TERMINAL_EXIT=$?"'

--- shape verdict (planning-time) ---
SHAPE_EXIT=0
--- terminal verdict (done transition, Gate G136 / Check 43) ---
PD12-UNCHECKED-ITEM: - [ ] Search returns results for a plain keyword query
PD12-UNCHECKED-ITEM: - [ ] Empty query renders the guidance state instead of an error
PD12-NO-RECORD: no authored "## Human Acceptance Record"; checked boxes alone are not human acceptance, because a template used to ship them checked
TERMINAL_EXIT=1
```

### Step 3 — corroborate the git history claims

**Executed:** YES
**Claim Source:** executed

```
$ git log -1 --format='%H %ad %s' --date=short 9e41da4
9e41da42be80ce013390ebbb0fb1077d94e9fade 2026-08-17 IMP-047 S-D: proportionate proof, micro-fix activated, PD-12 repair

$ git show 9e41da4^:agents/bubbles_shared/feature-templates.md | awk '/^## uservalidation.md Template/{f=1} f&&/^## scenario-manifest/{exit} f'
## uservalidation.md Template

```markdown
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
```

### Expected vs actual

| | |
|---|---|
| **Expected** (owner's requirement) | A user who reviewed the behavior and unchecked nothing has accepted it. The terminal verdict returns 0. |
| **Actual** | `TERMINAL_EXIT=1`, with `PD12-UNCHECKED-ITEM` for every acceptance item plus `PD12-NO-RECORD`. |

The failing state is precise: **no-objection is currently indistinguishable from
no-review.** The owner's requirement is that the two be different, and that
no-objection be acceptance.

---

## BUG-029 must stay closed

This must not be read as a request to reopen BUG-029.

BUG-029 was: *one checked item plus five unchecked reached a terminal status,
because `artifact-lint.sh` required only that ONE box be checked and never
rejected an unchecked one.*

The intended end state still refuses **any** unchecked acceptance item at a
terminal transition. `PD12-UNCHECKED-ITEM` survives unchanged. One checked plus
five unchecked is still refused, so the BUG-029 shape remains closed by exactly
the assertion that closed it.

What IS being traded away, deliberately and by owner decision, is only the PD-12
*addition*: the demand for a separately authored record proving a human actively
acted. The owner has chosen opt-out acceptance over that proof, accepting that
mechanism cannot distinguish "reviewed and satisfied" from "never opened the
file". That trade must be recorded in `design.md` as an explicit, owner-attributed
decision — not smuggled in as a side effect of the template edit.

---

## Intended end state (recorded, NOT implemented here)

Authoring only. A later `implement` phase owner delivers this.

1. `## Checklist` ships **CHECKED**. Automation authors the initial checked state.
2. An **unchecked** acceptance item at a terminal transition still **BLOCKS**. It
   means a user-reported regression. Gate G136 keeps that refusal and keeps
   never editing the file.
3. `## Human Acceptance Record` **MUST NOT** be required at a terminal
   transition, because no-uncheck is itself the acceptance. It stays available
   as **OPTIONAL** (it still serves external UAT and explicit sign-off), and the
   existing rule that `acceptedBy` may not match `^bubbles\.` continues to apply
   **when the record is present**.
4. `## Automation Readiness` **stays**, OPTIONAL, granting no acceptance. Do not
   delete it.
5. After the agent fixes an unchecked item, the **USER** re-checks it. The agent
   does not re-check on the user's behalf.
6. The four stale governance surfaces are brought into agreement with whatever
   ships, and `CHANGELOG.md` gains both a PD-12 entry and a correction to the
   now-false BUG-029 entry.

---

## Micro-fix admission

The compact packet is the default route. This bug fails admission and escalates
to `full` on two conditions:

- **`no-new-behavior` fails.** A terminal transition that is currently refused
  becomes accepted. That is a behavior change at a blocking gate.
- **`no-cross-product-effect` fails.** `feature-templates.md`,
  `acceptance-authority.yaml`, `artifact-lint.sh` and the guard all ship into
  every consuming repository. Every downstream `uservalidation.md` changes shape.

Escalation is automatic, with no reviewer discretion.

---

## Root cause

To be established by `bubbles.design` during the `analyze` phase and recorded in
[design.md](design.md). The preliminary reading, which the design phase must
confirm or refute:

`9e41da4` correctly identified a real fabrication vector — a template that
shipped checked satisfied a human-acceptance gate with no human act — and
repaired it by making acceptance opt-in. The repair was sound *as engineering*
and unsound *as product direction*: it optimised for un-forgeable proof of a
human act and, in doing so, made the owner's normal case (a satisfied user who
objects to nothing) unreachable. No surface in the repository recorded the
owner's opt-out requirement at the time, so nothing contradicted the change.

The stale documentation is a second, independent cause: `9e41da4` updated the
executable surfaces and left the descriptive ones, so the repository now states
two incompatible contracts and a reader cannot tell which is enforced.
