# Bug Fix Design: [BUG-042]

## Root Cause Analysis

### Investigation Summary

The adjudication was performed in BUG-041 and is carried forward here rather than
re-derived. The authority is
`bugs/BUG-041-artifact-lint-ignores-compact-packet-form/design.md` § 8, together
with the `F-041-03` finding entry in that packet's `state.json`, whose
`adjudication.boundaryCall` names this packet by slug and by form.

This design does not reopen that adjudication. It records the decision, states
what the delivered code does, and pins where each decision is discharged.

### Root Cause

See [bug.md](bug.md) § Root Cause. In one sentence: the compact form's four
preserved obligations were expressed only in registry prose with no consumer,
while both completion bases Check 4 knew were scoped to artifacts the form does
not declare — one absent (`scopes.md`), one definitionally unreachable
(scenarios, excluded by the `no-new-behavior` admission condition).

### Impact Analysis

| Surface | Impact |
|---|---|
| `state-transition-guard.sh` Check 4 | Every compact packet blocked at "ZERO DoD checkbox items" |
| `state-transition-guard.sh` Check 5 | Reports a scope cross-reference for a form with no scope decomposition |
| `artifact-lint.sh` | No attestation requirement, so the obligations had no lint-side existence check |
| `bug-packet-resolve.sh` | Emitted 22 facts, none of them an obligation fact |
| Live packets | `bugs/BUG-038-progress-timeout-bsd-wc-padding` uncertifiable |

## Fix Design

### Solution Approach

**Option E from BUG-041 § 8.3, adopted verbatim:** declare the obligations per
form in the registry, with carriers, and make Check 4's compact basis the
registry-derived obligation set.

Four coordinated changes:

1. **`bubbles/registry/bug-packet.yaml`** — the compact form gains
   `obligationsRetained:` with four entries, each `{id, dischargedIn, attestedIn}`.
   Its three artifacts gain `purpose:` (BUG-041 § 8.2 Correction 3: `full` and
   `single-file` gave every artifact a purpose; `compact` listed its three bare).
   A comment records why the compact entries deliberately omit `requirement:`.

2. **`bubbles/scripts/bug-packet-resolve.sh`** — a new output line kind
   `obligation=<form>|<id>|<dischargedIn>|<attestedIn>`. Per BUG-041 § 8.2
   Correction 2 this is a new LINE KIND, not a new verb: the resolver accepts only
   `--registry FILE`, its contract is one stable fact per line, and every existing
   consumer ignores an unrecognised kind for free. It also fails closed (exit 2)
   when a reduced form declares zero obligations.

3. **`bubbles/scripts/state-transition-guard.sh`** — Check 4 gains a THIRD
   completion basis, selected when the resolved form declares obligations and no
   `scopes.md`. Check 5 reports `NOT_APPLICABLE` for such a form and instead
   asserts `completedScopes` is EMPTY.

4. **`bubbles/scripts/artifact-lint.sh`** — requires an attestation line per
   declared obligation to EXIST in the `attestedIn` artifact. Existence is lint's
   question; whether it is ticked and names its `dischargedIn` site is the guard's.

### Decision 1 — which artifact carries the obligation (BUG-041 § 8.4)

Two distinct questions, deliberately kept apart:

| id | `dischargedIn` | `attestedIn` |
|---|---|---|
| `reproduce-before-fix` | `report.md` | `report.md` |
| `adversarial-regression` | `report.md` | `report.md` |
| `root-cause-stated` | **`bug.md`** | `report.md` |
| `evidence-is-execution` | `report.md` | `report.md` |

`dischargedIn` is taken from `micro-fix-packet.yaml`'s own requirement text and is
NOT uniform — `root-cause-stated` says "**bug.md** names the root cause, not the
symptom". `attestedIn` is uniformly `report.md`, because a completion claim is an
evidence claim and `report.md` is the declared evidence artifact.

`state.json` was considered and REJECTED as attestation site: it is the control
plane, and an agent-writable JSON field that grants completion is exactly the
self-certification shape `escalation.overrideFlag: none` exists to prevent.

An attestation that names its discharge site is checkable; a bare tick is not.
This is pinned behaviourally as B5.

### Decision 2 — reuse `obligationsRetained:`, add two per-entry keys (BUG-041 § 8.5)

The field is REUSED rather than replaced. Inventing `dodObligations:` would put a
second word for one idea inside the file whose stated reason for existing is that
the framework had four words for one thing.

The compact entries deliberately carry NO `requirement:` text, unlike the
`single-file` entries. The asymmetry has a reason and that reason is recorded in
the registry so a later reader does not tidy it away:

- `single-file`'s obligations have no upstream authority, so that form must state
  them in full.
- `compact`'s obligations ARE owned by `micro-fix-packet.yaml`, which
  `bug-packet.yaml` already points at via `admissionAuthority:`. Copying the text
  in would fork one authority into two copies drifting at their own pace — the
  exact defect this registry was created to end.

### Alternative Approaches Considered

Carried forward from BUG-041 § 8.3 with their recorded costs.

| # | Option | Disposition |
|---|---|---|
| A | Add `scopes.md` to the compact form | REJECTED. Four artifacts is not a reduced packet; it erases the form's reason to exist. Also forbidden by this packet's constraints. |
| B | Waive Check 4 when the form declares no `scopes.md` | REJECTED. A form that certifies by proving nothing is worse than a form that cannot certify. |
| C | Use `scenario-manifest.json` as the compact basis | REJECTED on impossibility. `no-new-behavior` means a compact bug has no scenarios by construction. |
| D | Free-authored DoD checkbox list in `report.md` | REJECTED. The author writes their own list, so the guard can only count unchecked items and never knows the list is COMPLETE. Reproduces `full`'s weakness in a form that need not inherit it. |
| E | Registry-declared obligations with carriers | **CHOSEN.** Buys a CLOSED required set the author cannot shorten. |

The closedness of the set is the whole purchase, and it is what mutation M1 exists
to prove: removing one registry entry moves the guard's required set from 4 to 3,
which is only possible if the set is read from the registry rather than hard-coded.

## Complexity Tracking

| Item | Assessment |
|---|---|
| New argument surface | None. One new output line kind. |
| Backward compatibility | `full` form untouched; verified by an unchanged verdict on BUG-037. |
| Fail-closed | Yes — a reduced form declaring zero obligations exits 2 rather than silently certifying. |
| Obligation strength | Unchanged. Compact proves the same four things, declared where enforcing surfaces can read them. |
| Behavioural coverage | `compact-obligation-basis-selftest.sh`, 13 checks, bounded to three guard invocations. |

## Coverage siting decision

BUG-041 § 8.3's change list named `state-transition-guard-selftest.sh` as the site
for the behavioural pin. That file is 5,953 lines and drives the guard dozens of
times, and no session permitted to make this change has been permitted to run it
end to end. A pin nobody can execute asserts nothing, arrived at from the other
direction.

The pin therefore lives in a dedicated `bubbles/scripts/compact-obligation-basis-selftest.sh`,
where it is bounded and can be shown to go red under mutation. This costs no
coverage: `framework-validate.sh`'s discovered-selftest sweep globs
`bubbles/scripts/*-selftest.sh`, so the file is executed with no wiring step.

The consequence for F-041-04 is recorded in [report.md](report.md).

## Fix Design 2 — Gate G027's proxy, not its intent

### The contradiction

Scope 1 taught Check 5 the compact form. It did not teach Check 15 / Gate G027,
and the two then disagree in a way no packet can satisfy:

| Check | On a form declaring no `scopes.md` | Requires |
|---|---|---|
| Check 5 (taught) | substitutes an assertion it CAN make | `completedScopes` EMPTY |
| Check 15 / G027 (form-blind) | applies the scope-count proxy anyway | `completedScopes` NON-EMPTY, `done_scopes` > 0 |

Under `bugfix-fastlane` both are live. Claim the phases and G027 fires; omit
them and G022 fires. The DEFAULT bug route was unfalsifiable.

### Which check is wrong

Check 5 is right. A packet with no scope decomposition genuinely cannot have
completed a scope, and saying so ADDS an assertion where the guard previously
only blocked. Do not relax it.

G027 is wrong — but only in its PROXY. Its intent is anti-fabrication: a phase
must not be recorded without evidence that work happened. That intent is
correct, is not negotiable, and survives this change unchanged. What fails is
the measurement: G027 reads work evidence off "scopes completed", and a form
whose declared artifact set omits `scopes.md` cannot produce that signal at any
value. The gate was asking a question this form is structurally barred from
answering, then treating the impossibility as guilt.

### The substitution

For a form declaring no `scopes.md`, Scope 1 already established the work-evidence
signal that form DOES carry: the registry-declared obligation attestations, which
are not author-chosen and cannot be shortened. G027 therefore asks, on exactly
that form:

> implement/test claimed ⇒ every registry-declared obligation is attested

instead of

> implement/test claimed ⇒ scopes completed

This is a swap of measurement, not a waiver. The gate still refuses, still
attributes to G027, and still names what is missing — an unattested obligation
fails G027 by its own id. Selftest assertion B11 pins that half; without it a
G027 that simply skipped this form would pass B10 and the gate would be a
decoration.

### Decision 3 — the shared attestation predicate

Check 4 already evaluated obligation attestations inline. Copying that predicate
into Check 15 would fork one question into two implementations free to drift, and
the fork would be invisible: both would keep passing while disagreeing. The
predicate is therefore extracted once as `bug_packet_obligation_state()` and
called from both. Check 4's refusal messages are preserved verbatim, so the
extraction is observationally inert on every existing packet.

### Decision 4 — fail-closed on a form with neither signal

A form declaring no `scopes.md` AND no obligations has nothing that attests work
at all. That case FAILS G027 rather than passing quietly: the guard's defaults
(`bug_packet_requires_scopes_md=true`, empty obligations) already fail closed,
and this branch keeps the property when a future form is added carelessly.

### What is deliberately NOT done

- **Not** relaxing Check 5 to tolerate a non-empty `completedScopes` on this
  form. That would let a scopeless packet claim a scope it cannot have.
- **Not** adding `scopes.md` to the compact form. The whole point of the form is
  that it does not carry one.
- **Not** exempting any form from G027. There is no skip path; every form still
  answers the anti-fabrication question, in the terms it can answer it.
- **Not** touching the `full` form's branch. Proven by a byte-level diff of the
  BUG-037 verdict.

### Coverage

`compact-obligation-basis-selftest.sh` gains B10a (the fixture actually claims
`implement`/`test`, so the assertions cannot be vacuous), B10 (the contradiction
is gone) and B11 (anti-fabrication survives). They reuse fixtures already built,
so the file's guard-invocation budget is unchanged.

The same work exposed a defect in that file's own fixtures: the builder scrubbed
only marker-tagged attestation lines, so the shipped base packet's own
attestation lines survived the copy and re-satisfied every obligation the builder
was asked to damage. B2/B2b/B3/B5/B6 were passing on contaminated fixtures. The
scrub now removes every attestation-shaped line naming a declared obligation id,
which is what the builder's own comment already claimed it did.
