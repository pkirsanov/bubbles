# Design: BUG-041 — packet-form-aware artifact resolution

**Status:** designed, NOT implemented
**Owner of implementation:** `bubbles.implement`

---

## 1. Root cause, stated precisely

The defect is NOT that `artifact-lint.sh` has the wrong list. The list is
correct for the `full` form. The defect is that the list is a CONSTANT where the
contract is a FUNCTION of packet form.

`bubbles/registry/bug-packet.yaml` is the declared single artifact authority. It
records three forms and the artifact set each one requires. It has no production
reader. `bubbles/scripts/bug-packet-selftest.sh` opens it only to assert the
registry's own shape.

Two enforcement surfaces each carry a private, hard-coded copy of the `full`
form's set:

| Surface | Lines | Content |
|---|---|---|
| `bubbles/scripts/artifact-lint.sh` | 401-406, 447, 453 | `spec.md design.md uservalidation.md state.json` plus `scopes.md` plus `report.md` |
| `bubbles/scripts/state-transition-guard.sh` | 759, 799, 805 | byte-identical |

So the answer to "how many artifacts does a bug need" comes from two copies that
no contract governs, while the contract that owns the answer is inert.

This is the defect IMP-047 S-B already diagnosed and repaired once, for a
different list. Three surfaces each kept a private copy of the report-section
list. The repair was not to synchronise the copies. It was to delete them and
build one reader, `report-sections-resolve.sh`, that every surface calls. That
repair is documented in `artifact-lint.sh:1207-1212` and is the precedent this
design follows.

**Where the defect lives:** in the absence of a reader, not in the registry and
not in the packet. `bug-packet.yaml` is well-formed.
`bugs/BUG-038-progress-timeout-bsd-wc-padding/` is well-formed against it.

---

## 2. Correcting the dispatching brief on two points

### 2.1 A machine-readable declaration already exists

The brief states that BUG-038 has `packetKind = None` and `microFix = None`, and
concludes there is "no machine-readable declaration for a linter to read".

That conclusion is wrong. The brief probed two field names that do not exist in
this schema. The field that does exist is `packet`:

```
$ jq -r '.packet' bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json
micro
```

It is already consumed, by `micro-fix-admission.sh:144`. So this is not a
missing-declaration problem. It is an UNDECLARED and MISSPELLED declaration
problem, which is a narrower and cheaper fix.

Two real faults remain in that field.

**Fault A — no registry declares it.**

```
$ grep -rn "^packet:\|\"packet\"" bubbles/registry/*.yaml
(no output, exit 1)
```

The field is real and consumed but has no contract. A second reader must guess
the vocabulary or copy the grep, which restarts the drift.

**Fault B — the stored word is not in the declared vocabulary.**

`bug-packet.yaml` declares `full`, `compact`, `single-file` and states "there are
no synonyms and no fifth form". The stored word is `micro`. The single reader
accepts only `micro` and `full`, so `compact` — the canonical word — is
currently REJECTED by the only code that reads the field.

The contradiction is visible in two consecutive lines of real output, which read
`micro` and print `compact`:

```
[micro-fix-admission] bugs/BUG-038-... declares packet: micro. Checking admission.
[micro-fix-admission] admitted: compact packet is proportionate for this defect.
```

### 2.2 Two of the six lint failures are a different defect

The brief presents all six failures as one defect. Four are. Two are not.

`### Completion Statement` and `### Test Evidence` come from
`report-sections.yaml`, whose `alwaysRequired` set has no form dimension.
BUG-038's `report.md` carries its evidence under `## Reproduction BEFORE fix`,
`## Reproduction AFTER fix`, and `## Lint`.

The compact contract says "Fewer artifacts, never fewer obligations", and its
preserved obligations require reproduction before fix, adversarial regression
with both runs shown, and evidence that is execution. A `### Test Evidence`
section is where those live.

**Determination.** These two failures are an authoring gap in BUG-038, not a
linter defect. No registry grants the compact form a section exemption.
Inventing one would drop a preserved obligation, which converts proportionality
into the loophole `micro-fix-packet.yaml` was written to prevent.

**Consequence for this design.** The fix MUST NOT touch them. After the fix,
BUG-038 must still fail lint with exactly those two issues. See §6, M5.

**Open decision for the owner.** A defensible alternative exists: give
`report-sections.yaml` a form dimension so the compact form declares its own
sections. I did not take it, because it relaxes an evidence contract to
accommodate one packet. Recorded as open rather than settled.

---

## 3. Chosen design

Follow the established registry-plus-one-reader pattern. Reject a hard-coded
branch on packet kind, because a branch inside `artifact-lint.sh` would be a
third private copy of the contract, which is the defect in a new location.

### 3.1 New — `bubbles/scripts/bug-packet-resolve.sh`

The ONE reader of `bubbles/registry/bug-packet.yaml`. Modelled line for line on
`report-sections-resolve.sh`.

Flat, greppable output, one fact per line:

```
form=<form>                       one line per declared form
default=<form>                    the form applied when no declaration is present
field=<name>                      the state.json field carrying the declaration
vocab=<word>|<form>               an accepted declaration word and its canonical form
artifact=<form>|<id>|<conditional>  an artifact that form requires
```

Non-negotiable properties, inherited from the precedent:

- **No fallback list.** A missing or unparseable registry exits non-zero and
  prints nothing. A caller cannot degrade to an empty requirement set, because
  an empty requirement set is a false PASS.
- **Refuses an empty set.** If a declared form resolves to zero artifacts, the
  resolver exits non-zero. Same reason.
- **Invoked as a subprocess.** `artifact-lint.sh` deliberately sources no
  sibling library, so the resolver is called, never sourced.
- **`python3`, not `awk`.** The registry needs nested-block parsing, and the
  portable `awk` form needs three-argument `match()`, which BSD `awk` lacks.
- **No bypass flag.** `--skip`, `--force`, `--ignore` are rejected as usage
  errors, exactly as the precedent rejects them.

### 3.2 Extended — `micro-fix-admission.sh --resolve-form <dir>`

`artifact-lint.sh` must not re-implement admission, and must not trigger the
outcome logger as a side effect of linting.

Add one side-effect-free subcommand that prints exactly one line and exits 0:

```
form=compact
form=full
```

It reuses the existing evaluator at `micro-fix-admission.sh:163-176`. It writes
no log, mutates nothing, and prints no prose.

The plain exit code cannot serve this purpose. Admission exits 0 for BOTH
outcomes, measured this session: BUG-038 admitted at exit 0, BUG-041 escalated
at exit 0. A verdict channel is therefore required.

### 3.3 Changed — `bug-packet.yaml` gains a `declaration:` block

```yaml
declaration:
  field: packet
  location: state.json
  absent: full
  vocabulary:
    - word: full
      form: full
    - word: compact
      form: compact
    - word: single-file
      form: single-file
  deprecatedAliases:
    - word: micro
      form: compact
      reason: >-
        Shipped before this block existed. micro-fix-admission.sh:144 reads it
        and bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json stores it.
      retireWhen: >-
        Every in-repo state.json stores `compact` and micro-fix-admission.sh
        reads `compact`. Retirement is a separate change owned by whoever may
        edit BUG-038.
```

An alias contradicts the file's own sentence "there are no synonyms". It is
admitted anyway, because the same file already reasons that "A declared
exception with a stated precondition is a contract; an undeclared one is a
contradiction." Today `micro` is the undeclared kind. This converts it to the
declared kind and names the condition under which it disappears.

The alternative — migrate `micro` to `compact` now — is the correct END state
and is NOT chosen for this change, because it requires editing
`bugs/BUG-038-.../state.json`, which is out of this packet's boundary.

### 3.4 Changed — `artifact-lint.sh`

Replace the literal array at line 401 and the two literal checks at 447 and 453
with resolver-driven requirements. The control flow, in order:

1. Resolve the declaration field name from `bug-packet-resolve.sh`.
2. Read that field from `state.json`.
3. Map the stored word through `vocab=` and `deprecatedAliases` to a canonical
   form. An unrecognised word is a FAILURE, never a silent `full` and never a
   silent `compact`.
4. If the field is absent, apply `default=full`. Fail closed.
5. If the resolved form is `compact`, call
   `micro-fix-admission.sh --resolve-form`. Apply the reduced set ONLY when it
   answers `form=compact`. A declared `compact` that fails admission is linted
   as `full`.
6. Require exactly the `artifact=` set for the resolved form.

Steps 4 and 5 are the whole safety argument and are re-stated in §5.

### 3.5 Changed — `state-transition-guard.sh`

Apply the identical replacement at lines 759, 799, and 805. Leaving the
duplicate in place would repair one surface and leave the other rejecting the
same admitted packet, which is the drift this design exists to end.

**This change is BLOCKED for the current session.**
`state-transition-guard-selftest.sh` was executing during this investigation and
references `artifact-lint` 53 times. Both edits belong to a session where the
suite is idle.

#### 3.5.1 AMENDMENT — the three-site list above is INCOMPLETE. There is a fourth.

**Status:** amendment, recorded from finding `F-041-02`. The three-site list is
preserved above rather than rewritten, because the gap in it is the point.

**The fourth site:** `bubbles/scripts/state-transition-guard.sh`, function
`build_scope_analysis_units`, defined at **line 582** and invoked at **line 704**.
It reads `scopes.md` **unconditionally**. The `compact` form does not require
`scopes.md`, so on a compact packet the guard dies with a shell redirection error
at that site **before producing any verdict** — it never reaches lines 759, 799,
or 805, so repairing only those three leaves §3.5's stated objective unmet.

**Attribution:** PRE-EXISTING at HEAD. The HEAD guard fails identically at the
same line. This is not a regression introduced by BUG-041; it is a site the
three-site enumeration did not find. Verified by reading the function at
`state-transition-guard.sh:582-590`.

**Why §3.5's list missed it:** the enumeration searched for *literal artifact
existence checks* — the shape at 759/799/805. Line 582 is not an existence check;
it is a **consumer** that assumes existence. A form-aware artifact set has to be
honoured by every reader of a form-optional artifact, not only by the readers
that test for it. That is the class of site to sweep for, not the single line.

**Deferred, and why:** `bubbles/scripts/state-transition-guard.sh` is being
edited concurrently by another session (BUG-033) and is dirty in the working
tree. Editing it here would collide with in-flight work in a file this design
already flagged as contended. The fix is deferred on cross-session file
contention, not on doubt about the diagnosis.

**For whoever picks this up — no rediscovery required:**

| Field | Value |
| --- | --- |
| File | `bubbles/scripts/state-transition-guard.sh` |
| Function | `build_scope_analysis_units` |
| Definition | line 582 |
| Call site | line 704 |
| Defect | reads `scopes.md` unconditionally; compact form does not require it |
| Symptom | shell redirection error, no verdict produced, before reaching 759/799/805 |
| Attribution | pre-existing at HEAD, not a BUG-041 regression |
| Blocker | file contended by the BUG-033 session |
| Consequence while open | the Test Plan row "`state-transition-guard.sh` agrees with `artifact-lint.sh`" cannot be satisfied |
| Sweep guidance | fix the class (consumers of form-optional artifacts), not only this line |

#### 3.5.2 AMENDMENT — `F-041-02` is RESOLVED. The fourth site is repaired.

**Status:** amendment. §3.5.1's deferral text above is preserved verbatim and is
NOT deleted — the deferral was a correct decision on the information available
then, and the record of *why* a site stayed open is part of what this packet is
for. This subsection records that the blocker cleared and the site was fixed.

**Blocker cleared.** The deferral reason was cross-session contention on
`bubbles/scripts/state-transition-guard.sh` with the BUG-033 session. That file
is inside this packet's `workBoundary.allowedPaths`, and the contention has
since cleared, so the repair was carried out. BUG-033's uncommitted changes in
the file were not reverted, not staged and not restructured; all edits are
additive.

**The repair.** The guard now reads a bug packet's artifact set through
`bubbles/scripts/bug-packet-resolve.sh` — the sole production reader of
`bubbles/registry/bug-packet.yaml` — so the guard and `artifact-lint.sh` answer
the artifact question from one authority instead of two private lists. No list
is restated inside the guard, so §4's rejected "third private copy of the
contract" is not created. Two elements carry the fix: the **form resolution**,
and a **defensive read guard** `[[ -f "$scope_path" ]] || return 0` inside
`build_scope_analysis_units`. Reduction happens only on a positive, admitted
declaration; a non-bug directory, a missing resolver, an unreadable registry, an
absent declaration, a word outside the declared vocabulary, an admission refusal
or a form resolving to zero artifacts all keep the unreduced behaviour.

**One correction to §3.5.1's own table, established by execution.** §3.5.1 names
**line 582** as the failing site. 582 is the `build_scope_analysis_units() {`
header; the failing read is the `done < "$scope_path"` redirection later in the
function. Bash names the *compound command's opening line* in a redirection
diagnostic, which is why the error text says 582. The table's other fields stand.

**The lesson, recorded.** §3.5 named three sites and there were four. The
enumeration searched for *literal artifact existence checks* and the fourth site
was a *consumer* that assumes existence. The rule this packet leaves behind is
§3.5.1's own sweep guidance, now demonstrated rather than asserted: **sweep the
class of `scopes.md` consumers, not the enumerated lines.** An enumeration of
line numbers is evidence of where someone looked, never evidence of where the
class ends.

**Measured outcome — every number from a command executed against this tree.**

| Check | Result |
| --- | --- |
| compact-aware markers in the guard | 26 lines |
| `"No such file or directory"` in guard output, either form | 0 |
| compact packet (BUG-038) | exit 1, 333 lines, `TRANSITION BLOCKED: 17 failure(s), 3 warning(s)`, `BEGIN/END TRANSITION_GUARD_RESULT_V1` |
| full packet (BUG-037) | exit 1, 579 lines, `TRANSITION BLOCKED: 38 failure(s), 4 warning(s)`, 14 `Scope` lines incl. 4 per-scope analysis units |
| `bug-packet-resolve-selftest.sh` | exit 0, 12/12, incl. `P5` and the new `P6` |
| `shellcheck -x` on the guard, attributed against HEAD | identical code profile both sides; **0** new findings |

The 17 and 38 failures are genuine gate findings — stale evidence receipts and
similar. The point of the repair is that **both forms now produce a verdict**
instead of one dying silently.

**Non-vacuity, by mutation.** Three mutations, each reverted by edit and each
leaving the guard byte-identical at
`sha256:7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3` with
zero `MUTATION` residue:

| Mutation | What it removes | Full packet BUG-037 | Compact packet BUG-038 |
| --- | --- | --- | --- |
| **X** — force `compact` for every packet | correct form resolution | **verdict UNCHANGED** at 38/4; scope analysis intact; only the required-artifact set moves | n/a |
| **Y** — X, plus drop the `\|\| [[ -f scopes.md ]]` enrolment fallback | the no-regression safety net | 38 → **18** failures, 4 → 2 warnings, 579 → 359 lines; Check 5 flips from BLOCK to a **false PASS**; three regression-DoD BLOCKs vanish | n/a |
| **Z** — both compact-aware elements | the whole fix | n/a | reproduces the original death **exactly**: 1 line, **0** verdict lines, 1 `No such file or directory` naming line 582 |

Mutation **X is the no-regression proof**, and it is a *negative* result reported
as measured: forcing the form to `compact` does **not** cost a full packet its
scope analysis or its verdict. That is not inertness — mutation **Y** shows the
enrolment branch is emphatically live, silently dropping 20 failures and
manufacturing a false PASS when its fallback is removed. A full packet's scope
analysis is gated on `scopes.md` **existing on disk**, not on form resolution
succeeding. That is precisely the property that makes the fix safe, and it is
why X had to be run before Y rather than instead of it.

### 3.6 New — `bug-packet-resolve-selftest.sh`, and one added assertion

A new selftest for the resolver, matching `report-sections-selftest.sh`.

`bug-packet-selftest.sh` gains one assertion: `bug-packet.yaml` has at least one
NON-selftest reader. Its absence is precisely what let this defect survive, and
nothing currently detects it.

#### 3.6.1 AMENDMENT — `P5` counts readers, so it cannot see one reader regress

**Status:** amendment, recorded from finding `F-041-04`.

`P5` asserts `readers >= 1`. Once `artifact-lint.sh` and
`state-transition-guard.sh` both read the resolver, `P5` stays green if **either
one** reverts to a private list — and a single surviving reader is exactly the
two-surface disagreement this design exists to end. `P6` therefore names both
consumers individually.

Proven non-vacuous by mutation, not by inspection: with the guard's resolver
reference renamed away, `P5` still reported `ok  P5 1 non-selftest surface(s)`
while `P6` reported `FAIL P6 state-transition-guard.sh reads bug-packet-resolve.sh`
and the selftest exited 1. Reverted by edit; the guard is byte-identical at
`sha256:7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3` and the
selftest is 12/12 at exit 0.

`P6` pins the **wiring**, not the **behaviour**. The behavioural pin — that a
compact packet produces a verdict and a full packet keeps its scope analysis —
belongs in `state-transition-guard-selftest.sh`, which is deliberately out of
boundary. That residual gap is finding `F-041-04`, recorded rather than closed.

---

## 4. Alternatives considered and rejected

| Alternative | Rejected because |
|---|---|
| Hard-code an `if packet == micro` branch in `artifact-lint.sh` | Creates a third private copy of the contract. The defect, relocated. |
| Relax the required set for every packet under `bugs/` | Blinds the linter for the six existing full packets under `bugs/`. Directory location is not packet form. |
| Have `artifact-lint.sh` read `micro-fix-packet.yaml` directly | That registry states `artifactAuthority: bug-packet.yaml`. Reading it for artifacts contradicts its own delegation. |
| Make `micro-fix-admission.sh` WRITE `.packet` into `state.json` | An admission check that mutates state can race the transition guard. The authoring path should write the declaration at packet creation. Kept as a documented fallback if authoring proves unreliable. |
| Give `report-sections.yaml` a form dimension so BUG-038 passes fully | Relaxes an evidence contract to accommodate one packet. Recorded as an open owner decision in §2.2, not taken here. |

---

## 5. Non-vacuity — the critical risk

The risk is that relaxing the artifact set for the wrong packet kind blinds the
linter. Three structural properties make that impossible, and six mutations
prove it rather than assert it.

### Structural property 1 — fail closed on absence

An absent declaration resolves to `full`. Every one of the six other bug packets
in this repository has `.packet` absent, measured this session. Their verdict is
therefore unchanged by construction, not by inspection.

### Structural property 2 — declaring is not sufficient

A packet may declare `compact` and still be linted as `full`, because the
declaration must ALSO survive admission. Declaring the compact form is a
request, never a grant. Without this, `"packet": "compact"` would become the
override flag that `micro-fix-packet.yaml` sets to `none` on purpose.

### Structural property 3 — no fallback set

A missing, unparseable, or empty-for-this-form registry exits non-zero. The lint
cannot proceed with zero requirements, which is the only way a resolver-driven
check can silently pass everything.

### Six mutations, every one required to go RED

| # | Mutation | Required outcome |
|---|---|---|
| M1 | Fixture: full packet, `.packet` absent, `design.md` deleted | lint FAILS. Proves no blinding of the default path. |
| M2 | Fixture: `.packet` declares `compact`, `bug.md` answers `no-payment-surface = yes` | lint applies `full` and FAILS. Proves declaring is not a bypass. |
| M3 | Rename `bug-packet.yaml` away | lint exits 2 and names the registry. Proves no silent degradation. |
| M4 | Mutate the registry so `compact` declares zero artifacts | resolver exits non-zero. Proves an empty set is refused. |
| M5 | Real packet `bugs/BUG-038-progress-timeout-bsd-wc-padding` | lint exit 1 with EXACTLY 2 issues, both report-section. Proves the fix is scoped and the evidence contract was not relaxed. |
| M6 | All six existing bug packets, verdict captured before and after | **AMENDED — see §5.1.** Verdict (exit code) byte-identical for every undeclared packet; lint OUTPUT changes by the corrected required-artifact identity. |

M6 is the acceptance gate. Capture each packet's full lint output before the
edit, capture it after, and diff. Any **verdict** difference on a packet with
`.packet` absent is a defect in the fix. Output differences are admissible only
in the exact shape §5.1 fixes.

M5 deserves emphasis. The fix is deliberately NOT expected to make BUG-038 pass.
Passing it would mean the two report-section obligations were dropped, which §2.2
determined is wrong. A fix that turns 6 issues into 0 has over-reached. The
correct result is 6 into 2.

### 5.1 AMENDMENT — M6's original "byte-identical" wording was too strict

**Status:** amendment. The original wording is preserved verbatim in this
section so the change is auditable; it is not silently rewritten.

**Original wording:** "All six existing bug packets, verdict captured before and
after → byte-identical. The strongest single proof of non-blinding."

**Measured:** exit codes identical for all seven control packets; output differs
by five diff lines on each. The required artifact moved `spec.md` → `bug.md`,
plus one added informational form line. No verdict moved. Recorded as finding
`F-041-01`.

**Adjudication: the fix is correct and the expectation was wrong.** This is not
a widening BUG-041 introduced. It is the correction of a pre-existing defect in
`artifact-lint.sh`, on four independent pieces of evidence:

1. **The registry never required `spec.md` of a bug.**
   `bubbles/registry/bug-packet.yaml`, `forms: → form: full → artifacts:`,
   declares exactly `bug.md`, `design.md`, `scopes.md`, `report.md`,
   `uservalidation.md`, `scenario-manifest.json` (conditional), `state.json`.
   `spec.md` is absent from that list; `bug.md` is in it. The pre-BUG-041 lint
   applied a literal feature-shaped list that demanded an artifact the contract
   never required and did not demand one it did. Requiring `spec.md` was the
   defect; dropping it is the repair.

2. **The prose restatements agree.** `agents/bubbles_shared/bug-templates.md`
   mentions `spec.md` zero times. `micro-fix-packet.yaml` delegates artifacts to
   `bug-packet.yaml` and names no `spec.md`. There is no second authority
   pointing the other way.

3. **Nothing mechanically consumes `spec.md` from a bug packet.** The only hit
   across `bubbles/scripts/**` is a prose comment at
   `guards/tail-delegated-gates.sh:522` citing BUG-037's file by path. No guard,
   lint, or resolver reads it. Dropping the requirement orphans no consumer.

4. **The corrected requirement refuses nothing, in either direction.** All eight
   packets under `bugs/` carry `bug.md`, so requiring `bug.md` refuses nothing
   that exists. All seven packets that resolve to `full` carry `spec.md`, so
   dropping that requirement refuses nothing either. No verdict moves either
   way. The choice between the two sets is therefore settled purely by **which
   one is the contract** — and that is the registry.

**The decisive argument is contract authority, and it is this design's own.**
§4 rejects "hard-code an `if packet == micro` branch in `artifact-lint.sh`"
because it "creates a third private copy of the contract. The defect, relocated."
The hard-coded `spec.md` requirement WAS such a private copy — a literal,
feature-shaped artifact list living inside the lint and disagreeing with the
registry that IMP-047 S-B made the single bug-artifact authority. Reading the set
through `bug-packet-resolve.sh` is not a side effect of this fix; it is the fix.
The required-artifact identity changing is that principle taking effect.

**RETRACTION — an argument used in an earlier draft of this amendment was wrong.**
That draft asserted that M6-as-written contradicted M5, on the ground that all
eight packets were undeclared and BUG-038 therefore sat inside M6's population.
That is **false**. The `.packet` declaration lives in `state.json`, not in a
`.packet` file, and the earlier probe tested for the file. Re-probed correctly:
`BUG-038` declares `"packet": "micro"` and `BUG-041` declares `"packet": "full"`;
the other six are undeclared. BUG-038 is a DECLARED packet, so it is outside
M6's undeclared population and **M5 and M6 do not contradict each other**. The
retraction is recorded rather than deleted because the claim reached a written
draft. The adjudication does not depend on it and stands on points 1-4 above.

**Consequent correction to the scope of point 4.** BUG-038's pre-fix
`❌ Missing required artifact: …/spec.md` is evidence of the **compact-form**
defect — the lint ignoring the declared form entirely, which is this packet's
primary target — not evidence about the `full` form's artifact set. No `full`
bug packet in this repository lacks `spec.md`. The full-form correction is
currently **unobservable in verdicts**, exactly as `F-041-01` states. It is
justified by contract authority, not by an observed refusal.

**Alternative tested and rejected:** re-adding `spec.md` to the registry's `full`
form so M6-as-written passes. Rejected. The registry is the declared single
bug-artifact authority; editing it to preserve a mis-authored test expectation
inverts that authority. It would also put the registry in conflict with
`bug-templates.md`, which names `spec.md` zero times, and with
`micro-fix-packet.yaml`, which delegates artifacts to it. Tightening the contract
to protect an expectation is the tail wagging the dog.

**Amended M6 expectation (authoritative):**

> For every packet whose `.packet` is absent, the lint **verdict** (exit code) is
> unchanged before and after the fix. The lint **output** may differ in exactly
> one respect: the required-artifact set is corrected from the hard-coded
> feature-shaped list to the set `bug-packet.yaml` declares for the resolved
> form — `spec.md` ceases to be required and `bug.md` becomes required — plus one
> informational line naming the resolved form. Any other output difference, and
> any verdict difference, is a defect in the fix.

DoD item 7 in `scopes.md` is amended to match. It is left **unchecked**: this
amendment fixes the expectation only. Verifying the measurement against the
corrected expectation belongs to the implementer.

---

## 6. Files the implementer will touch

| Path | Change |
|---|---|
| `bubbles/scripts/bug-packet-resolve.sh` | NEW |
| `bubbles/scripts/bug-packet-resolve-selftest.sh` | NEW |
| `bubbles/registry/bug-packet.yaml` | add `declaration:` block |
| `bubbles/scripts/micro-fix-admission.sh` | add `--resolve-form` |
| `bubbles/scripts/micro-fix-admission-selftest.sh` | cover `--resolve-form` |
| `bubbles/scripts/artifact-lint.sh` | replace lines 401-406, 447, 453 |
| `bubbles/scripts/state-transition-guard.sh` | replace lines 759, 799, 805 |
| `bubbles/scripts/bug-packet-selftest.sh` | assert a non-selftest reader exists |

Explicitly NOT touched:

- `bugs/BUG-038-progress-timeout-bsd-wc-padding/**` — correctly formed. Its two
  report-section issues are routed to its owner, not repaired here.
- `bubbles/registry/report-sections.yaml` — §2.2 open decision, not taken.
- `bubbles/registry/micro-fix-packet.yaml` — already delegates artifacts
  correctly. No change needed.

---

## Change Boundary

Ratified after independent verification. One path outside the originally
declared boundary was widened into it. The widening is bounded to the coverage
obligation this packet's own change created, and is not a standing licence over
the file.

### In boundary

| Path | Why it is in scope |
|---|---|
| `bugs/BUG-041-.../**` | The packet itself. |
| `bubbles/registry/bug-packet.yaml` · `bubbles/scripts/bug-packet-resolve.sh` · `bubbles/scripts/bug-packet-resolve-selftest.sh` · `bubbles/scripts/bug-packet-selftest.sh` · `bubbles/scripts/micro-fix-admission.sh` · `bubbles/scripts/micro-fix-admission-selftest.sh` · `bubbles/scripts/state-transition-guard.sh` | Originally declared. See §6. |
| `bubbles/scripts/artifact-lint.sh` | Originally declared. The hard-coded artifact list lives here. |
| `bubbles/scripts/artifact-lint-selftest.sh` | **Widened.** The owning selftest of the file this packet changed. Rationale below. |

### Recorded rationale for the widening: `artifact-lint-selftest.sh`

The admitting argument is deliberately **not** "same defect class"; that
argument is refused below and stays refused. It is narrower and it is about this
packet's own output: **a boundary must cover the change that was made, and this
packet changed `artifact-lint.sh`.** §3.4 replaced that script's hard-coded
`required_files` list with a resolved, packet-form-aware set — a new branch, a
new external reader, a new fail-closed default and a new admission
cross-check. The owning module's selftest is where that behaviour is pinned,
and this packet's own DoD item 11 demands scenario coverage for every changed
behaviour. Declaring the change and refusing the coverage its DoD requires is
not a bounded boundary; it is an unfinished one.

The measurement that makes it necessary rather than tidy: the original defect
survived **because** nothing in this file observed the artifact-presence check
at all. `artifact-lint-selftest.sh` covers only the Check-3 evidence-legitimacy
window (T1-T17); its six "compact" references are about compact *evidence
blocks*, an unrelated feature. Every one of its cases passed while a
legitimately admitted compact packet was being rejected. Scenarios 1, 2 and 3
were then proven on throwaway `/tmp` fixtures that did not survive the session,
so at the moment this rationale was written the repaired branch had **zero**
committed coverage and its regression would be silent — the exact shape that let
the filed defect reach two enforcement surfaces.

Admitted work is confined to **adding** cases that pin the behaviour this packet
introduced: the admitted-compact artifact set, the escalation of a declared
compact packet that fails admission, the absent-default resolution of an
undeclared packet, and the registry-sourced membership of the required set. No
existing case is modified, relaxed, renumbered, or deleted. Additivity is
verified mechanically by `git diff --numstat` showing zero deletions.

### Explicitly out of boundary

The following are **not** admitted by this widening, and must not join it by
analogy:

- Any `artifact-lint-selftest.sh` change that is not new coverage for the
  packet-form behaviour this packet added. Weakening, relaxing, renumbering or
  deleting an existing case is refused, and so is repairing an unrelated
  pre-existing weakness in T1-T17 or extending coverage of the Check-3
  certifying-window feature. Those are a different contract in the same file,
  and sharing a file is not an admitting argument.
- `bubbles/scripts/artifact-lint.sh` changes unrelated to packet-form-aware
  artifact resolution. The replaced region is §3.4's; the Check-3 heuristic, the
  report-section resolution and the scope-layout checks are untouched and stay
  untouched.
- Every bar already recorded above stands unchanged:
  `bugs/BUG-038-progress-timeout-bsd-wc-padding/**` stays routed to its owner,
  `bubbles/registry/report-sections.yaml` stays an untaken §2.2 decision, and
  `bubbles/registry/micro-fix-packet.yaml` stays unmodified.
- `bubbles/scripts/state-transition-guard.sh` remains declared but the `F-041-02`
  fourth site stays deferred per §3.5.1 on cross-session contention.

"It is the same defect class" is the argument this section exists to refuse. A
shared selftest is widened one change at a time, with the measurement that shows
what deferring it would cost.

---

## 7. Sequencing constraint

`framework-validate` was running throughout this investigation, confirmed at
pid 15125. `state-transition-guard-selftest.sh` references `artifact-lint` 53
times and `state-transition-guard.sh` references it 8 times.

Every edit in §6 must therefore land in a session where the suite is idle. This
packet performed investigation, root cause, and design only, and made no change
to any framework script.

---

## 8. Adjudication of F-041-03 — the compact form's completion basis

`bubbles.implement` recorded F-041-03 and deliberately declined to repair it,
calling it a contract question owned by `bug-packet.yaml` and
`micro-fix-packet.yaml` rather than a code question. That judgement is correct
and is upheld here. This section adjudicates the contract question, and routes
the work OUT of this packet.

### 8.1 The question

`compact` is the DEFAULT bug route since IMP-047 S-D: a bug clearing all eight
admission conditions in `micro-fix-packet.yaml` takes it without opting in. The
form declares three artifacts and `scopes.md` is not one of them. Check 4 of the
transition guard derives its completion basis by counting `- [x]` / `- [ ]`
lines across the resolved scope files, so on a compact packet `scope_files` is
empty, `total_dod` is 0, and the guard reaches
`record_failed_check Check-4-structure` with "Resolved scope artifacts have ZERO
DoD checkbox items — cannot verify completion".

The framework's default bug route therefore produces packets that can be
evaluated and can never be certified. BUG-038 is a live instance.

### 8.2 Three corrections to the dispatching framing

The brief's structural reading was checked against the files rather than
assumed. Two of its three load-bearing claims hold; three points need
correcting, and one of them changes the shape of the fix.

**Correction 1 — `obligationsRetained:` is structured but is NOT machine-read.**
The brief contrasts `single-file`, which "declares its obligations
structurally", against `compact`, which asserts them "in prose no reader can
consume". The first half overstates the difference. `bug-packet-resolve.sh` — the
sole reader — parses exactly two top-level groups, `forms:` and `declaration:`,
and inside a form it sets `in_artifacts` true only for the literal key
`artifacts:`. `obligationsRetained:` sets that flag FALSE, so its entries are
skipped. Running the resolver confirms it: the emission is 22 lines of
`form=` / `default=` / `field=` / `location=` / `vocab=` / `alias=` /
`artifact=`, and not one obligation fact. `single-file` additionally has no
`state.json` by construction, so the guard never resolves it at all.

`obligationsRetained:` is therefore documentation with a tidy shape and zero
consumers. This matters because it changes the fix: adopting the `single-file`
precedent does NOT hand the guard a working mechanism. The resolver must learn a
new emission kind either way. What the precedent supplies is the VOCABULARY, and
that is still worth reusing (§8.5).

**Correction 2 — the resolver has no `--resolve-form` verb.** The brief names
`--resolve-form` on `bug-packet-resolve.sh` as the natural seam for a new verb.
That verb lives on `micro-fix-admission.sh` (guard line ~782,
`--resolve-form "$feature_dir"`). `bug-packet-resolve.sh` accepts only
`--registry FILE`; its contract is to emit every registry fact as stable
one-fact-per-line output and let each consumer grep the kinds it needs. So the
seam is **a new output line kind, not a new verb**. That is the lower-variance
change: it adds no argument surface, and every existing consumer ignores an
unrecognised line kind for free.

**Correction 3 — the compact form declares artifact ids with no `purpose:`.**
`full` gives all seven artifacts a purpose and `single-file` gives its one
artifact a purpose. `compact` lists `bug.md`, `report.md`, `state.json` bare.
So the form does not say what its artifacts are FOR, which is why the carrier
question in §8.4 has to be answered from the sibling registry rather than from
the form itself. This is a second, smaller gap in the same block and is folded
into the same change list.

**What the brief got right.** `regressionExpectations` really is scoped
`appliesToForms: [full]`, and it really is the only mechanical expression of
`micro-fix-packet.yaml`'s preserved `adversarial-regression` obligation. The
registry therefore declares an obligation preserved and, in the same file,
scopes its only checkable expression out of the form that preserves it. That is
the sharpest statement of the defect and it is sharper than "there are no
checkboxes".

### 8.3 Options and their costs

| # | Option | Cost |
|---|---|---|
| A | Add `scopes.md` to the compact form | Erases the form's reason to exist. Four artifacts is not a reduced packet. REJECTED by constraint and on merit. |
| B | Waive Check 4 when the form declares no `scopes.md` | Converts proportionality into the loophole `preservedObligations` exists to forbid. A form that certifies by proving nothing is worse than a form that cannot certify. REJECTED. |
| C | Use `scenario-manifest.json` as the compact completion basis | Cannot apply. Admission condition `no-new-behavior` means a compact bug has, by construction, no observable behaviour change and therefore no scenarios. The scenario basis is definitionally unreachable on this form. REJECTED on impossibility, which also closes the question of whether the superior basis was overlooked. |
| D | Relocate a free-authored DoD checkbox list into `report.md` | Works, and is the implementer's hypothesis. Cost: the author writes their own list, so the guard can only count unchecked items and never knows whether the list is COMPLETE. Reproduces `full`'s weakness in a form that does not need to inherit it. |
| E | Declare the obligations per form in the registry, with carriers, and make Check 4's compact basis the registry-derived obligation set | Costs one new registry key, one new resolver emission kind, one new completion basis. Buys a CLOSED required set the author cannot shorten. **CHOSEN.** |

### 8.4 Decision 1 — which artifact carries the obligation

**Two carriers, and the distinction the hypothesis was missing.**

`micro-fix-packet.yaml`'s `preservedObligations` already names carriers in its
own requirement text, for two of four:

| id | requirement names | so it is discharged in |
|---|---|---|
| `reproduce-before-fix` | "**report.md** records the failing reproduction…" | report.md |
| `root-cause-stated` | "**bug.md** names the root cause, not the symptom…" | bug.md |
| `adversarial-regression` | "…both runs **shown**" | report.md (evidence) |
| `evidence-is-execution` | "Every claim maps to a command that ran, with its real exit code" | report.md (evidence) |

So the contract already answers WHERE each obligation's substance lives, and the
answer is not uniform: three in `report.md`, one in `bug.md`. The implementer's
`report.md` hypothesis is confirmed for three quarters of the set and is wrong
for `root-cause-stated`.

That forces a distinction the hypothesis did not draw. **Where an obligation is
DISCHARGED** and **where its completion is ATTESTED** are different questions,
and collapsing them scatters the checklist across two artifacts. The decision:

- `dischargedIn:` is per obligation, taken from `micro-fix-packet.yaml`'s own
  requirement text — `bug.md` for `root-cause-stated`, `report.md` for the other
  three. An attestation that names its discharge site is checkable; a bare tick
  is not.
- `attestedIn:` is uniformly **`report.md`**, for all four. Justification from
  the contract's own logic, not convenience: in the `full` form `report.md`'s
  declared purpose is "Evidence with raw terminal output" while `bug.md`'s is
  "Reproduction, severity, status, environment, error output, root cause" —
  analysis, not attestation. A completion claim is an evidence claim. `report.md`
  is also the artifact `report-sections.yaml` already governs for
  `bugfix-fastlane`, and the artifact `stateExpectations` already pairs with
  certification on both forms. Putting the attestation anywhere else would give
  the compact form a second evidence surface.

`state.json` was considered and rejected as the attestation site: it is the
control plane, and an agent-writable JSON field that grants completion is the
self-certification shape `escalation.overrideFlag: none` exists to prevent.

### 8.5 Decision 2 — reuse `obligationsRetained:`, with one added key

**Reuse the field.** Inventing `dodObligations:` or `compactObligations:` would
put a second word for one idea inside the file whose entire stated reason for
existing is that the framework had four words for one thing. The entry shape
`{id, requirement}` already matches `micro-fix-packet.yaml`'s
`preservedObligations` entry shape, so the two registries already speak one
vocabulary and should keep doing so.

**Add `dischargedIn:` and `attestedIn:` as per-entry keys.** `single-file` needs
neither, because it has exactly one artifact and the carrier is unambiguous;
that is precisely why the precedent has no such key and why its absence is not
evidence against adding one. `compact` has three artifacts, and telling a
consumer WHERE to look is the whole purpose of the change.

**Do NOT restate the `requirement:` text on the compact form.** This is the one
place the compact entries must deliberately differ in shape from the
`single-file` entries, and the asymmetry has a reason that must be recorded in
the registry so a later reader does not "tidy" it away:

- `single-file`'s obligations have **no upstream authority** — `explicit-disposition`
  (Gate G095) exists nowhere else — so that form must state them in full.
- `compact`'s obligations **are owned by `micro-fix-packet.yaml`**, which
  `bug-packet.yaml` already points at via `admissionAuthority:`. Copying the
  requirement text in would fork a single authority into two copies drifting at
  their own pace, which is the exact defect this registry was created to end.

So compact entries carry `id` (a reference into `preservedObligations`),
`dischargedIn`, and `attestedIn` — and no `requirement`.

**`regressionExpectations` keeps `appliesToForms: [full]`.** Its content is
literal `scopes.md` checkbox text and a Test Plan row; those strings are
meaningless in a form with neither artifact, and extending the list verbatim
would demand a Test Plan that cannot exist. Instead it gains a `note:` recording
that the compact form's expression of the SAME obligation is
`obligationsRetained[adversarial-regression]`. The obligation is preserved in
both forms; only its expression is form-shaped.

### 8.6 Decision 3 — this belongs in a NEW packet, not in BUG-041

Ruled AGAINST widening, and against the brief's inclination.

The strongest argument for widening is real and is acknowledged: F-041-02 was a
declared widening of this packet, and BUG-041 already owns four of the five
surfaces the change touches. But F-041-02 and F-041-03 are not the same kind of
finding.

- **F-041-02 completed the fix.** BUG-041 taught one surface to read the registry
  and left its sibling blind. Leaving that would have made the fix internally
  contradictory: lint passes, guard dies. Not repairing it meant not having
  repaired the defect.
- **F-041-03 does not complete the fix.** BUG-041's stated defect — surfaces
  carrying private copies of the artifact list instead of reading the registry —
  is fully repaired once F-041-02 closed. What remains is that the CONTRACT is
  under-specified for a form activated by a different change (IMP-047 S-D). The
  finding's own attribution says so: "NOT introduced by this session… the gap was
  invisible rather than absent." **Exposure is not ownership.**

Two further facts settle it:

1. **Magnitude.** The change is one new registry key with a new entry shape, one
   new resolver output kind with a matching fail-closed refusal, a third
   completion basis in Check 4, a Check 5 disposition, an `artifact-lint` check,
   and non-vacuity coverage for all of it. That is the same magnitude as BUG-041's
   own change (one new registry block, one new script, one new admission verb,
   two consumers, one selftest). A second packet's worth of work is a packet.
2. **Coupling a stalled packet.** BUG-041 stands at 9/13 with items 10, 12 and 13
   blocked on `framework-validate` and `release-check`, which every session so far
   has been forbidden to run. Widening it means BUG-041 can no longer be certified
   without also certifying a brand-new Check-4 completion basis. That makes a
   stalled packet harder to close and makes a new mechanism's certification
   hostage to a command nobody may run.

**The new packet: `BUG-042-compact-packet-has-no-completion-basis`.** Filed as a
bug, not an improvement: the default bug route cannot certify, and BUG-038 is a
live instance, so there is an observable defect with a reproduction. Its lineage
is IMP-047 S-D, which activated the route without the completability half, and
that should be recorded in its root-cause section.

BUG-042 must itself use the **`full`** form. This is not deference to ceremony —
it is what `micro-fix-packet.yaml`'s own admission questions return:
`no-schema-change` asks whether the fix changes "a persisted schema, wire
contract, or **artifact shape**", and this change alters the compact form's
required `report.md` content; `no-new-behavior` asks whether any caller-observable
behaviour changes, and a new resolver output kind plus a new completion basis is
observable to both consumers. Two conditions fail, so `escalation` sends it to
`full` with no discretion. A change to the compact contract is not itself a
compact-admissible change.

### 8.7 Decision 4 — `micro-fix-packet.yaml` does NOT change

Only `bug-packet.yaml` changes normatively. The division is read off both files'
own self-descriptions rather than chosen:

- `micro-fix-packet.yaml` owns **which obligations survive the reduction**. Its
  header says so, and its `preservedObligations` ids are already stable and
  already referenceable. Nothing there needs to move.
- `bug-packet.yaml` owns **the artifact question** — `micro-fix-packet.yaml`
  states this explicitly: "It does NOT own the artifact question. That has one
  authority: `bubbles/registry/bug-packet.yaml`."

"Which artifact discharges and attests obligation X" is an artifact question.
It belongs in `bug-packet.yaml` and would be misfiled in `micro-fix-packet.yaml`.
The cross-pointer that makes the reference navigable already exists in both
directions: `artifactAuthority:` and `admissionAuthority:`.

`report-sections.yaml` also does not change. The attestation is a checkbox LINE
keyed by obligation id, not a new required HEADING, so the registry that governs
report headings is untouched. That choice is deliberate: `report-sections.yaml`
keys requirements on workflow MODE and has no vocabulary for packet FORM, so
requiring a heading there would mean teaching a third registry a new dimension to
gain nothing the line check does not already give.

### 8.8 Mechanical change list (for BUG-042, not for this packet)

Nothing in this list is to be applied to BUG-041.

**1. Registry — `bubbles/registry/bug-packet.yaml`**
- Add `obligationsRetained:` to the `compact` form, four entries, each
  `{id, dischargedIn, attestedIn}` and no `requirement:`:
  `reproduce-before-fix` (report.md / report.md), `adversarial-regression`
  (report.md / report.md), `root-cause-stated` (bug.md / report.md),
  `evidence-is-execution` (report.md / report.md).
- Add a comment recording WHY compact omits `requirement:` while `single-file`
  carries it, so the asymmetry is not tidied away later (§8.5).
- Add `purpose:` to compact's three artifacts, closing Correction 3.
- Add a `note:` under `regressionExpectations` pointing at
  `obligationsRetained[adversarial-regression]` as the compact expression of the
  same obligation; leave `appliesToForms: [full]` unchanged.
- Leave the prose `note:` on the compact form in place. It becomes a summary of a
  now-machine-readable block rather than the only statement of it.

**2. Resolver — `bubbles/scripts/bug-packet-resolve.sh`**
- New output line kind, documented in the header block alongside the existing
  seven: `obligation=<form>|<id>|<dischargedIn>|<attestedIn>`.
- Parse `obligationsRetained:` inside a form by extending the existing
  `in_artifacts` flag into a small block selector; `single-file` entries emit with
  empty carrier fields, which is honest and costs no schema change there.
- Fail-closed refusal mirroring the existing zero-artifact refusal: a form that
  declares fewer artifacts than the `absent:` default and declares ZERO
  obligations is refused with exit 2. An empty obligation set on a reduced form is
  a false-PASS in the same class the header already names.
- No new flag. `--registry` remains the only argument.

**3. Guard — `bubbles/scripts/state-transition-guard.sh`**
- Check 4 gains a THIRD completion basis, ranked below `scenario-states` and
  above the legacy checkbox count, selected when the resolved form emits
  `obligation=` facts: for each obligation id, require a `- [x]` line in the
  named `attestedIn` artifact whose text contains that id. Zero-unchecked is
  preserved verbatim; the required SET is now registry-derived, so the author
  cannot shorten it. This is strictly stronger than the basis `full` uses.
- Reuse the existing `bug_packet_form` / `bug_packet_facts` resolution already in
  place at guard lines ~717-790. No second resolver invocation.
- Check 4A (G041 format manipulation) and Check 22 (G068 checkbox fidelity) must
  scan the `attestedIn` artifact on a reduced form, or the relocation reopens the
  reformatting bypass those checks exist to close.
- Check 5: on a form whose artifact set omits `scopes.md`, emit
  `NOT_APPLICABLE` **and assert `certification.completedScopes` is EMPTY**. A form
  with no scope decomposition claiming completed scopes is a contradiction. This
  ADDS a check where the guard currently blocks; it waives nothing.

**4. Consumer — `bubbles/scripts/artifact-lint.sh`**
- On a reduced form, require the attestation line for every emitted obligation id
  to be PRESENT in `attestedIn` (present, not necessarily checked — checked is
  Check 4's question at `done`, and lint runs before that).

**5. Coverage**
- `bubbles/scripts/bug-packet-resolve-selftest.sh`: assert the `obligation=`
  emission for compact, assert the zero-obligation refusal on a reduced form, and
  assert `single-file` still resolves.
- `bubbles/scripts/state-transition-guard-selftest.sh`: a BEHAVIOURAL pin — a
  synthetic compact packet with all four obligations attested reaches the Check 4
  pass, and the same packet with one obligation unattested is REFUSED. This is
  the same gap F-041-04 records against the existing form-awareness: a wiring pin
  is not a behavioural pin, and a mutation that removes the basis while leaving
  the resolver reference intact must go RED.

**Non-vacuity requirement.** Every one of the mutations above must be shown to go
RED, in the manner §5 established for this packet. A new completion basis that
passes when the obligation is absent is worse than no basis, because it launders
the gap into a green verdict.

### 8.9 What this does NOT do

No obligation is weakened. A compact packet after BUG-042 must prove the same
four things `micro-fix-packet.yaml` preserves today, in the same artifacts its
own requirement text already names. What changes is that the requirement becomes
readable by the surfaces that enforce it, and the required set becomes closed
rather than author-chosen. `scopes.md` is not added to the compact form. The
`full` form is untouched.
