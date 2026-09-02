# BUG-041 — `artifact-lint.sh` demands the full artifact set from every packet, including the compact form it cannot see

**Status:** Confirmed, reproduced, not fixed
**Severity:** High
**Reported:** 2026-08-24
**Workflow mode:** bugfix-fastlane
**Packet form:** full (escalated automatically, see Admission below)

---

## Summary

`bubbles/registry/bug-packet.yaml` declares three packet forms and the artifacts
each one requires. The `compact` form requires exactly three artifacts. The
`compact` form is the DEFAULT route since IMP-047 S-D.

`bubbles/scripts/artifact-lint.sh` does not read that registry. It carries a
hard-coded list of the `full` form's artifacts and applies it to every packet.
A packet that takes the declared default route therefore cannot pass lint.

The same hard-coded list exists a second time in
`bubbles/scripts/state-transition-guard.sh`, so two enforcement surfaces
disagree with the one registry that owns the answer.

---

## Reproduction

`bugs/BUG-038-progress-timeout-bsd-wc-padding/` is a real compact packet. The
admission script admits it. The lint rejects it.

### Step 1 — admission ADMITS the packet

```
$ bash bubbles/scripts/micro-fix-admission.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
[micro-fix-admission] bugs/BUG-038-progress-timeout-bsd-wc-padding declares packet: micro. Checking admission.
[micro-fix-admission] admitted: compact packet is proportionate for this defect.
MICRO_FIX_ADMISSION_EXIT=0
```

### Step 2 — lint REJECTS the same packet

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/spec.md
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/design.md
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/uservalidation.md
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/scopes.md
❌ report.md missing required section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
❌ report.md missing required section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
Artifact lint FAILED with 6 issue(s).
ARTIFACT_LINT_EXIT=1
```

Full unfiltered output is recorded in `report.md`.

### Step 3 — the packet is correctly formed against its own contract

```
$ ls bugs/BUG-038-progress-timeout-bsd-wc-padding/
bug.md   report.md   state.json
```

`bug-packet.yaml` `form: compact` lists exactly `bug.md`, `report.md`,
`state.json`. The packet carries all three and nothing extra.

---

## Expected versus actual

**Expected.** `artifact-lint.sh` resolves the packet form, then requires the
artifact set that `bug-packet.yaml` declares for that form. A compact packet
carrying its three declared artifacts passes the artifact check.

**Actual.** `artifact-lint.sh` requires `spec.md`, `design.md`,
`uservalidation.md`, `state.json`, `scopes.md`, and `report.md` from every
packet, with no knowledge that any other form exists.

---

## Root cause

`artifact-lint.sh` never reads `bubbles/registry/bug-packet.yaml`.

The required set is a literal array at `bubbles/scripts/artifact-lint.sh:401`,
followed by two more literal checks for `scopes.md` and `report.md` at lines 447
and 453. Packet form is not an input to any of them.

```
$ grep -ic "micro" bubbles/scripts/artifact-lint.sh
0
$ grep -c "bug-packet.yaml" bubbles/scripts/artifact-lint.sh
0
```

The registry exists, is well-formed, and has NO production reader. Only
`bubbles/scripts/bug-packet-selftest.sh` opens it, and only to assert the
registry's own shape. A contract nobody reads cannot govern anything.

This is the same defect shape IMP-047 S-B already repaired once. Three surfaces
each kept a private copy of the report-section list, drifted apart, and were
collapsed onto one reader, `report-sections-resolve.sh`. The artifact list is
that defect in its unrepaired state, with two copies instead of three.

---

## Blast radius

| Surface | Line | Carries the hard-coded full-form list |
|---|---|---|
| `bubbles/scripts/artifact-lint.sh` | 401, 447, 453 | yes |
| `bubbles/scripts/state-transition-guard.sh` | 759, 799, 805 | yes, byte-identical |

`artifact-lint.sh` ships to every downstream consumer repository as
`.github/bubbles/scripts/artifact-lint.sh`, so the defect is not local to the
framework source repository.

---

## Why this matters

IMP-047 S-D made the compact packet the default route. Every author who takes
that default now meets a lint that cannot pass. The author has two exits.

The first exit abandons the compact route and pays full ceremony for a one-line
fix. That discards the proportionality IMP-042 SCOPE-9 was written to buy.

The second exit fabricates `spec.md`, `design.md`, `scopes.md`, and
`uservalidation.md` for a defect whose contract deliberately does not require
them. That is writing artifacts to satisfy a checker rather than a reader, which
is the failure mode this repository keeps finding and naming.

The defect therefore does not merely block work. It applies steady pressure
toward fabrication, and it does so on the route the framework tells authors to
take by default.

---

## Two secondary findings

### F-1 — declared vocabulary and stored vocabulary disagree

`bug-packet.yaml` states its form vocabulary is closed. The recorded words are
`full`, `compact`, and `single-file`, with the note "there are no synonyms and
no fifth form".

`BUG-038/state.json` stores `"packet": "micro"`. `micro-fix-admission.sh:144`
greps for exactly that string. `micro` is a synonym for `compact`, and it is the
only word the sole reader accepts.

The disagreement is already visible in one line of admission output, which reads
the word `micro` and prints the word `compact`:

```
[micro-fix-admission] bugs/... declares packet: micro. Checking admission.
[micro-fix-admission] admitted: compact packet is proportionate for this defect.
```

No registry declares the `packet` field at all:

```
$ grep -rn "^packet:\|\"packet\"" bubbles/registry/*.yaml
(no output, exit 1)
```

So the field is real, is consumed, and is undeclared. Any second reader must
either guess the vocabulary or copy the grep, which starts the drift again.

### F-2 — two of the six failures are NOT this defect

The dispatch that opened this bug framed all six lint failures as one defect.
Four of them are. Two are not, and recording them as one would overstate the
repair.

`report.md missing required section: ### Completion Statement` and
`### Test Evidence` come from `report-sections.yaml`, whose `alwaysRequired`
list carries no form dimension. BUG-038's `report.md` holds its evidence under
`## Reproduction BEFORE fix`, `## Reproduction AFTER fix`, and `## Lint`.

The compact form's own contract says "Fewer artifacts, never fewer obligations".
Its preserved obligations require reproduction before fix, adversarial
regression with both runs shown, and evidence that is execution. That is exactly
what a `### Test Evidence` section holds.

My determination is that these two failures are a genuine authoring gap in
BUG-038, not a linter defect. No registry grants the compact form a section
exemption, and inventing one would drop an obligation the contract preserves.

I did not repair BUG-038, because this session is forbidden to edit it. The
finding is routed rather than fixed. An owner may reasonably disagree and add a
form dimension to `report-sections.yaml` instead, so the decision is recorded as
open in `design.md` rather than settled here.

---

## Micro-fix admission

Answered against the FIX this packet proposes, not against the defect.

- micro-fix-admission: no-new-behavior = yes
  The fix changes an observable verdict. `artifact-lint.sh` moves from exit 1 to
  exit 0 on a compact packet. Callers observe that.
- micro-fix-admission: no-schema-change = yes
  The fix declares a `packet` field contract in the registry and fixes its
  vocabulary. That is a persisted artifact shape.
- micro-fix-admission: no-auth-surface = no
- micro-fix-admission: no-payment-surface = no
- micro-fix-admission: no-secret-surface = no
- micro-fix-admission: no-deployment-surface = no
- micro-fix-admission: no-cross-product-effect = yes
  `artifact-lint.sh` ships to every consumer repository under
  `.github/bubbles/scripts/`. The consuming side changes with it.
- micro-fix-admission: contract-preserving = yes
  No existing assertion is weakened. Verified statically only. No selftest
  currently asserts the string `Missing required artifact`, so no test encodes
  the behaviour being changed. The dynamic confirmation belongs to the
  implementer, because this session must not run the selftest suite.

Three conditions fail admission, so the route escalates to `full` mechanically.
The recorded verdict is in `report.md`.

---

## Environment

- Repository: `bubbles` framework source, `/Users/pkirsanov/Projects/bubbles`
- Platform: macOS, BSD userland
- Observed: 2026-08-24
