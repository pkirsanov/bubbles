# Bug: [BUG-042] The compact packet form has no completion basis

## Summary

`compact` has been the DEFAULT bug route since IMP-047 S-D: a bug that clears all
eight admission conditions in `micro-fix-packet.yaml` takes it without opting in.
The form declares three artifacts — `bug.md`, `report.md`, `state.json` — and
`scopes.md` is deliberately not one of them.

Check 4 of `state-transition-guard.sh` derives its completion basis by counting
`- [x]` / `- [ ]` lines across the resolved scope files. On a compact packet the
resolved scope set is empty, so the DoD total is 0 and the guard reaches
`record_failed_check Check-4-structure` with "Resolved scope artifacts have ZERO
DoD checkbox items — cannot verify completion".

The framework's default bug route therefore produces packets that can be
evaluated and can never be certified. That is not a lint nuisance; it is a route
that cannot terminate.

## Severity

**High.** It is not a crash and it corrupts nothing, so it is not Critical. It is
above Medium because it is unconditional on the framework's DEFAULT route, it has
no author-side workaround that does not violate the contract, and its two
available workarounds are both forbidden: adding `scopes.md` erases the form's
reason to exist, and waiving Check 4 converts proportionality into exactly the
loophole `preservedObligations` was written to forbid.

## Status

- **Discovered:** during BUG-041, recorded as finding **F-041-03**
- **Route:** ADJUDICATED and routed OUT of BUG-041 into this packet
- **Adjudicating authority:** `bugs/BUG-041-artifact-lint-ignores-compact-packet-form/design.md` § 8
- **Current:** `in_progress` — code verified present, packet under construction
- **Packet form:** `full` (this bug changes enforcement semantics on two guards
  and a registry; it does not clear `no-new-behavior` and is not itself compact)

## Reproduction Steps

1. `bash bubbles/scripts/bug-packet-resolve.sh` — observe the compact form's
   artifact set contains no `scopes.md`.
2. `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding`
3. Read the Check 4 block.

## Expected Behavior

Check 4 selects a completion basis that the compact form can actually satisfy,
and that basis proves the SAME four obligations `micro-fix-packet.yaml` preserves
— no fewer, no author-chosen subset.

## Actual Behavior (before the fix)

Check 4 finds 0 DoD items and blocks with "Resolved scope artifacts have ZERO DoD
checkbox items — cannot verify completion". There is no third basis. The packet
is unfalsifiably incomplete.

This exact behaviour is reproduced on demand in the M2 mutation recorded in
[report.md](report.md): breaking the resolver's `obligation=` emission returns the
guard to precisely this line.

## Environment

- Repo: `bubbles` framework source, macOS (Darwin), bash 3.2 baseline
- HEAD at investigation: `ce2c5ed`
- Working interpreter: `/Library/Developer/CommandLineTools/usr/bin/python3` (3.9)
- Live compact instance used as fixture: `bugs/BUG-038-progress-timeout-bsd-wc-padding`

## Error Output

```
--- Check 4: DoD Completion (Zero Unchecked) ---
ℹ️  INFO: DoD items total: 0 (checked: 0, unchecked: 0)
🔴 BLOCK: Resolved scope artifacts have ZERO DoD checkbox items — cannot verify completion
```

## Root Cause

Two registry facts, both true, are jointly unsatisfiable.

1. `bug-packet.yaml` declares `form: compact` with three artifacts and no
   `scopes.md`, and makes that form the default route.
2. `state-transition-guard.sh` Check 4 knows exactly two completion bases —
   a DoD-checkbox basis read out of `scopes.md`, and a scenario basis. The first
   requires an artifact the form does not have. The second is definitionally
   unreachable: admission condition `no-new-behavior` means a compact bug has, by
   construction, no observable behaviour change and therefore no scenarios.

So the root cause is not "the guard is wrong" and not "the form is wrong". It is
that the compact form's obligations were expressed only in registry PROSE
(`note:`), which has no consumer, while every basis the guard can read was scoped
to artifacts the form does not declare. The obligations were real and preserved;
they were simply written where no enforcing surface could see them.

`obligationsRetained:` existed on the `single-file` form before this change and
looked structural, but `bug-packet-resolve.sh` — its sole reader — sets its
artifact-parsing flag true only for the literal key `artifacts:`, so
`obligationsRetained:` entries were skipped and never emitted. It was
documentation with a tidy shape and zero consumers.

## Second defect: Gate G027 is form-blind (found while fixing the first)

Giving the compact form a completion basis made a SECOND contradiction
reachable, in the same file this packet owns.

- **Check 5** was taught the compact form by this packet. On a form declaring no
  `scopes.md` it substitutes the assertion that IS meaningful: `completedScopes`
  MUST be EMPTY, because a packet with no scope decomposition cannot have
  completed one.
- **Check 15 / Gate G027** was NOT taught the form. If `implement` or `test` is
  claimed it requires `completedScopes` to be NON-EMPTY and `done_scopes` to be
  non-zero, on pain of "FABRICATION".

Under `bugfix-fastlane` both checks are live, so on a compact packet that
genuinely did implement and test, NO value of `completedScopes` satisfies both:
record the phases and G027 fires; omit them and G022 fires for the missing
phases. `bugs/BUG-038-progress-timeout-bsd-wc-padding` is the live instance —
G027 is absent from its earlier 20-failure run and present in its 7-failure run,
appearing only once its phases were recorded truthfully.

The root cause is a PROXY, not an intent. G027's intent — phases must not be
recorded without evidence that work happened — is correct and is preserved in
full. What is wrong is that it measures work through "scopes completed", a
signal a scopeless form cannot produce by construction. Check 5 is the correct
check here; G027 is the one asking a question this form is structurally barred
from answering.

## Related

- **BUG-041** — `bugs/BUG-041-artifact-lint-ignores-compact-packet-form`. Parent
  investigation. Recorded this defect as F-041-03 and adjudicated it in its
  `design.md` § 8. Its `state.json` records the boundary call: NEW PACKET, ruled
  against widening.
- **BUG-038** — `bugs/BUG-038-progress-timeout-bsd-wc-padding`. The live compact
  instance this defect strands. Read-only apart from ONE authorised edit: its
  discovered-issue `DI-038-04` recorded the G027 contradiction above and is
  moved to `resolved` by this packet's repair. `bug.md` and `state.json` are
  proven byte-identical.
- `bubbles/registry/micro-fix-packet.yaml` — owns `preservedObligations`, the
  upstream authority for the four obligation ids. NOT modified.
- **F-041-04** — the sibling finding that the guard's form-awareness had no
  behavioural committed pin. Disposition recorded in [report.md](report.md).
