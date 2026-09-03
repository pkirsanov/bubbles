# Report: BUG-042 — The compact packet form has no completion basis

## Summary

The compact bug packet form — the framework's DEFAULT bug route since IMP-047 S-D
— declared three artifacts, none of them `scopes.md`, while `state-transition-guard.sh`
Check 4 knew only two completion bases, both scoped to artifacts that form does
not have. The default route therefore produced packets that could be evaluated
and never certified.

The repair, adjudicated in BUG-041 § 8 as Option E, gives the registry a
machine-readable per-form obligation declaration with carriers, teaches the
resolver to publish it, and gives Check 4 a third basis derived from it. The
obligations are unchanged in strength: compact proves the same four things
`micro-fix-packet.yaml` preserves, merely declared where enforcing surfaces can
read them.

**Scope 2 repairs a defect Scope 1 made reachable.** Teaching Check 5 the
compact form left Check 15 / Gate G027 form-blind, and the two then contradicted
each other: Check 5 requires `completedScopes` EMPTY on a scopeless form, G027
required it NON-EMPTY whenever `implement`/`test` is claimed. No value satisfied
both, so the DEFAULT bug route was unfalsifiable. G027's anti-fabrication INTENT
is preserved in full; only its PROXY changes, from "scopes completed" to the
registry-declared obligation attestations — the one work-evidence signal a
scopeless form carries. An unattested obligation still fails G027 by name.

### Provenance of the code — read this before crediting anything

**This agent did not author the Scope 1 code changes.** A previous
`bubbles.implement` dispatch produced them and was killed by jetsam mid-task;
its edits landed in the working tree. That session's work was to VERIFY the
landed code by independent execution, prove it non-vacuous by mutation, and
build the packet around it.

**Scope 2's code changes WERE authored in this session** and are attributable to
it: the `bug_packet_obligation_state()` extraction, the Check 15 form-awareness
branch, the selftest fixture hermeticity fix, and assertions B10a/B10/B11.

Every figure below was re-derived by running the command shown. Nothing is cited
from a dispatching brief. Where a re-derived figure differs from a brief's
description, the re-derived figure is recorded and the difference is noted.

## Completion Statement

Scope 1 and Scope 2 are implemented and verified. 24 of 30 DoD items are
checked, each with executed evidence inline in [scopes.md](scopes.md). The six
unchecked items are the two scopes' copies of `Human acceptance recorded`,
`bubbles.validate certifies promotion`, and `framework-validate and
release-check pass`. None is this agent's to check, and none was fabricated.
`framework-validate`, `release-check` and `state-transition-guard-selftest.sh`
were explicitly excluded from this session and are recorded as UNPROVEN.

`status` remains `in_progress` and no terminal `certification.status` was
written. This agent does not certify.

## Test Evidence

### E-1 — the four scripts are syntactically valid

**Executed:** YES
**Command:** `bash -n` on each of the four scripts
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
bubbles/scripts/bug-packet-resolve.sh                bash-n=ok
bubbles/scripts/state-transition-guard.sh            bash-n=ok
bubbles/scripts/artifact-lint.sh                     bash-n=ok
bubbles/scripts/bug-packet-resolve-selftest.sh       bash-n=ok
```

### E-2 — the resolver publishes the obligations (TP-042-01, SCN-042-01)

**Executed:** YES
**Command:** `bash bubbles/scripts/bug-packet-resolve.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Exit 0. Eight `obligation=` lines — four compact, four single-file:

```
obligation=compact|reproduce-before-fix|report.md|report.md
obligation=compact|adversarial-regression|report.md|report.md
obligation=compact|root-cause-stated|bug.md|report.md
obligation=compact|evidence-is-execution|report.md|report.md
obligation=single-file|explicit-disposition||
obligation=single-file|reproduce-before-fix||
obligation=single-file|root-cause-stated||
obligation=single-file|evidence-is-execution||
```

`root-cause-stated` carries `bug.md` as its `dischargedIn` while the other three
carry `report.md` — the non-uniformity BUG-041 § 8.4 derived from
`micro-fix-packet.yaml`'s own requirement text, present in the emission.

Note against the dispatching brief: the brief described the resolver as having
8 `obligation=` occurrences. Re-derived, the SOURCE has 3 occurrences (a doc
line, a comment, and one emission site at line 295); the OUTPUT has 8 lines. The
output figure is the load-bearing one and it holds.

### E-3 — the resolver selftest is green (TP-042-02)

**Executed:** YES
**Command:** `bash bubbles/scripts/bug-packet-resolve-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
selftest exit=0
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)
```

### E-4 — the compact packet is now completable (TP-042-03; SCN-042-02, -03, -06)

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
exit=1
20 failure(s), 3 warning(s)
TRANSITION_GUARD_RESULT_V1 occurrences: 2
```

Check 4 selects the registry-derived basis and refuses each obligation by name:

```
--- Check 4: DoD Completion (Zero Unchecked) ---
ℹ️  INFO: DoD items total: 0 (checked: 0, unchecked: 0)
ℹ️  INFO: Completion basis: REGISTRY-DECLARED OBLIGATIONS (bug-packet.yaml 'compact' form declares 4; the required set is not author-chosen)
🔴 BLOCK: Obligation 'reproduce-before-fix' has NO attestation line in report.md citing its discharge site report.md — the required set is registry-derived and cannot be s
🔴 BLOCK: Obligation 'adversarial-regression' has NO attestation line in report.md citing its discharge site report.md — the required set is registry-derived and cannot be
🔴 BLOCK: Obligation 'root-cause-stated' has NO attestation line in report.md citing its discharge site bug.md — the required set is registry-derived and cannot be shorten
🔴 BLOCK: Obligation 'evidence-is-execution' has NO attestation line in report.md citing its discharge site report.md — the required set is registry-derived and cannot be
```

Check 5 substitutes rather than waives:

```
--- Check 5: Scope Status Cross-Reference ---
ℹ️  INFO: Resolved scopes: total=0, Done=0, In Progress=0, Not Started=0, Blocked=0
ℹ️  INFO: NOT_APPLICABLE: Check-5-all-done — the 'compact' packet form declares no scopes.md, so there is no scope decomposition to cross-reference
✅ PASS: completedScopes is EMPTY, as the 'compact' form requires — no scope decomposition, no completed scopes
```

The packet still exits 1 — correctly. It has not attested its obligations. The
defect was that it COULD NOT be completed; it now can be, and is refused for a
reason its author can act on. `failedChecks: [Check-4-obligations]`.

### E-5 — the full form is unchanged (TP-042-06, SCN-042-07)

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
exit=1
38 failure(s), 4 warning(s)
TRANSITION_GUARD_RESULT_V1 occurrences: 2
```

Identical to the pre-change baseline. The third basis is additive and does not
reach a form that declares `scopes.md`.

### E-6 — M1 registry mutation: the required set is registry-derived (TP-042-04, SCN-042-04)

**Executed:** YES
**Command:** removed the `root-cause-stated` entry from `obligationsRetained`, reran E-2 and E-4
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
obligation=compact line count: 3          (was 4)
exit=1
19 failure(s), 3 warning(s)               (was 20)
ℹ️  INFO: Completion basis: REGISTRY-DECLARED OBLIGATIONS (bug-packet.yaml 'compact' form declares 3; the required set is not author-chosen)
BLOCK: Obligation count: 3                (was 4)
```

The guard's declared count and its BLOCK count both tracked the registry. A
hard-coded set could not do that. This is the proof that Option E bought a CLOSED
required set rather than another author-chosen list.

Reverted by EDIT (not `git checkout`):

```
d8dc14eb30a7584c60e8bbc2a041490f333f3405cae3687d85f7d093e1704e82  bubbles/registry/bug-packet.yaml
expect d8dc14eb30a7584c60e8bbc2a041490f333f3405cae3687d85f7d093e1704e82
selftest exit=0
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)
```

### E-7 — M2 resolver mutation: the basis is load-bearing (TP-042-08 companion)

**Executed:** YES
**Command:** renamed the emission key `obligation=` → `obligationX=` at `bug-packet-resolve.sh:295`, reran E-2, E-3 and E-4
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
obligation= line count: 0                 (was 8)
"Completion basis" line count: 0          (was 1)
exit=1
16 failure(s), 3 warning(s)               (was 20)

--- Check 4: DoD Completion (Zero Unchecked) ---
ℹ️  INFO: DoD items total: 0 (checked: 0, unchecked: 0)
🔴 BLOCK: Resolved scope artifacts have ZERO DoD checkbox items — cannot verify completion
```

That final line is the ORIGINAL DEFECT, reproduced on demand. Severing the
resolver emission returns the guard exactly to the pre-fix death recorded in
[bug.md](bug.md) § Actual Behavior. The registry declaration and the guard basis
are connected by the resolver and by nothing else.

The resolver selftest also caught it, so the pin is not vacuous either:

```
selftest-under-mutation exit=1
bug-packet-resolve-selftest: 16 check(s), 3 failure(s)
```

Reverted by EDIT:

```
923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f  bubbles/scripts/bug-packet-resolve.sh
expect 923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f
selftest exit=0
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)
```

### E-8 — M3 fail-closed: a zero-obligation reduced form is refused (TP-042-05, SCN-042-05)

**Executed:** YES
**Command:** renamed the compact form's key `obligationsRetained:` → `obligationsRetainedDISABLED:`, reran the resolver
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
resolver exit=2
bug-packet-resolve: /Users/pkirsanov/Projects/bubbles/bubbles/scripts/../registry/bug-packet.yaml declares reduced form 'compact' (3 artifact(s) vs the 'full' default's 7) with ZERO obligationsRetained
```

The refusal is structural: a form is REDUCED if it declares fewer artifacts than
the `full` default, and a reduced form that retains no obligations is a form that
certifies by proving nothing — Option B, rejected in design. The resolver will not
emit it. Fewer artifacts, never fewer obligations, enforced rather than asserted.

Reverted by EDIT; all three mutated files byte-identical to baseline:

```
d8dc14eb30a7584c60e8bbc2a041490f333f3405cae3687d85f7d093e1704e82  bubbles/registry/bug-packet.yaml
923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f  bubbles/scripts/bug-packet-resolve.sh
4839e3a3c06e7fcc930d2ec332b66af5e9432fb83c793444157380dbc6518d63  bubbles/scripts/state-transition-guard.sh
selftest exit=0
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)
```

### E-9 — the behavioural pin executes (TP-042-07)

**Executed:** YES
**Command:** `bash bubbles/scripts/compact-obligation-basis-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
bash-n=ok
exit=0
  ok   P0 the registry declares 4 obligation(s) for the compact form
  ok   P1 fixture base is the shipped compact packet BUG-038-progress-timeout-bsd-wc-padding
  ok   B4 the obligation basis is SELECTED for a compact packet (not skipped past)
  ok   B1 a compact packet with every obligation attested PASSES the obligation basis
  ok   B1b the 'ZERO DoD checkbox items' structural refusal no longer fires on a compact packet
  ok   B2 removing the 'reproduce-before-fix' attestation REFUSES the packet, naming it
  ok   B2b exactly ONE obligation is refused — the other 3 still pass
  ok   B3 an UNCHECKED attestation is refused, and is reported differently from a missing one
  ok   B5 a ticked attestation that does not name its dischargedIn artifact does NOT satisfy the obligation
  ok   B6 artifact-lint refuses a compact packet missing an obligation attestation line
  ok   B7 artifact-lint accepts an UNCHECKED attestation — existence is lint's question, ticking is the guard's
  ok   B8 a compact packet claiming a completed scope is REFUSED — Check 5 substitutes, it does not waive
  ok   B9 Check 4A scans the attestation artifact, so the G041 bypass does not reopen there
compact-obligation-basis-selftest: 13 check(s), 0 failure(s)
```

This is the assertion BUG-041 could not make. It pins the verdict CHANGING with
the packet's content in both directions — B1 passes, B2 refuses — which is what
distinguishes a behavioural pin from a wiring pin.

**Superseded count.** This run is Scope 1's, at 13 checks. Scope 2 adds B10a,
B10 and B11 and takes the file to 16 checks; E-19 also records that B2, B2b, B3,
B5 and B6 were passing on contaminated fixtures in this very run, and repairs
the fixture builder. The current figure is 16 checks / 0 failures (E-18). This
block is retained as the historical Scope 1 measurement, not as the live one.

### E-10 — M4: the behavioural pin is non-vacuous (TP-042-08)

**Executed:** YES
**Command:** reapplied the M2 resolver mutation, reran `compact-obligation-basis-selftest.sh`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
exit=1
  FAIL P0 the registry declares compact obligations
       the fixtures below would assert nothing
compact-obligation-basis-selftest: 1 check(s), 1 failure(s)
```

The pin refuses at its own precondition rather than running fixtures that would
assert nothing — the correct shape, and it goes red. Reverted by EDIT and green
again:

```
923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f  bubbles/scripts/bug-packet-resolve.sh
expect 923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f
exit=0
compact-obligation-basis-selftest: 13 check(s), 0 failure(s)
```

### E-11 — BUG-038 was read, never written

**Executed:** YES
**Command:** composite sha256 over the sorted file list of the BUG-038 tree, before and after all guard runs and mutations
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
BUG038_TREE_BEFORE=a59a48b53e98494519ab969f4d278cf96457ed190242d57e66d526a4b3f00dda
BUG038_TREE_NOW   =a59a48b53e98494519ab969f4d278cf96457ed190242d57e66d526a4b3f00dda
```

Identical. The guard was run against it without `--revert-on-fail` and wrote
nothing. `BUG-032`, `BUG-033`, `BUG-037` and `BUG-039` were not touched at all;
`BUG-037` was guarded read-only in E-5 by the same mechanism.

This holds for Scope 1. Scope 2 makes ONE authorised edit to BUG-038 — its
`DI-038-04` disposition — and proves containment per file in E-19.

---

## Scope 2 evidence — Gate G027 is form-blind

### E-14 — the contradiction, re-derived

**Executed:** YES
**Command:** `grep` over the two checks, then the guard on the live compact instance
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
$ grep -cE "bug_packet_form|compact" over state-transition-guard.sh lines 4150-4300
0
```

Check 15 contained zero references to the packet form. Check 5, taught by
Scope 1, requires `completedScopes` EMPTY on a form declaring no `scopes.md`;
Check 15 required it NON-EMPTY whenever `implement` or `test` is claimed. Both
are live under `bugfix-fastlane`.

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
exit=1
🔴 BLOCK: Execution/certification phases claim implement/test phases but completedScopes is EMPTY — FABRICATION (Gate G027)
ℹ️  INFO: This means phases were recorded without any scope actually completing
🔴 BLOCK: Execution/certification phases claim implement/test phases but ZERO scopes are marked 'Done' — FABRICATION (Gate G027)
🔴 TRANSITION BLOCKED: 7 failure(s), 2 warning(s)
failedGateIds: [G022,G027,G033]
```

### E-15 — after the fix: the compact form clears G027 (TP-042-11, SCN-042-08)

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
exit=1
--- Check 15: Phase-Scope Coherence (Gate G027) ---
✅ PASS: Phase-obligation coherence verified: implement/test are backed by all 4 registry-declared obligation attestation(s) for the 'compact' form
🔴 TRANSITION BLOCKED: 5 failure(s), 2 warning(s)
failedGateIds: [G022,G033]
```

The full diff of the guard's output against the pre-fix run is exactly the two
G027 refusals, their INFO line, the substituted PASS, and the recomputed
counters — plus the timestamp and one nondeterministic `0s`/`1s` duration:

```
$ diff before after
175,177c175
< 🔴 BLOCK: … completedScopes is EMPTY — FABRICATION (Gate G027)
< ℹ️  INFO: This means phases were recorded without any scope actually completing
< 🔴 BLOCK: … ZERO scopes are marked 'Done' — FABRICATION (Gate G027)
---
> ✅ PASS: Phase-obligation coherence verified: … for the 'compact' form
316c314
< 🔴 TRANSITION BLOCKED: 7 failure(s), 2 warning(s)
---
> 🔴 TRANSITION BLOCKED: 5 failure(s), 2 warning(s)
333c331
< failedGateIds: [G022,G027,G033]
---
> failedGateIds: [G022,G033]
```

The 5 remaining failures are 4 G022 lines (`regression`, `validate`, `audit`
missing, plus their summary) and 1 G033 stale-receipt line owned by BUG-033.
Neither is touched by this repair.

### E-16 — the full form is byte-for-byte unchanged (TP-042-10, SCN-042-10)

**Executed:** YES
**Command:** `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance`, before and after
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
before: exit=1  38 failure(s), 4 warning(s)   Scope-lines=14
after : exit=1  38 failure(s), 4 warning(s)   Scope-lines=14

$ diff before after
4c4
<   Timestamp: 2026-08-25T19:38:34Z
---
>   Timestamp: 2026-08-25T19:42:09Z
194c194
< ✅ PASS: Framework ownership lint passed … (1s)
---
> ✅ PASS: Framework ownership lint passed … (0s)

$ diff <(grep -v "Timestamp:\|internally consistent" before) \
       <(grep -v "Timestamp:\|internally consistent" after)
FULL_FORM_IDENTICAL
```

The only two differing lines are a wall-clock timestamp and a one-second
duration on an unrelated lint. Nothing else in 177 result lines moved.

### E-17 — mutation M1: removing the form-awareness reinstates the contradiction (TP-042-13)

**Executed:** YES
**Command:** edit `if [[ -n "$bug_packet_form" ]] …` to `if false && [[ … ]]`, rerun the guard and the pin
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
exit=1
🔴 TRANSITION BLOCKED: 7 failure(s), 2 warning(s)
"Gate G027" occurrences: 3

$ bash bubbles/scripts/compact-obligation-basis-selftest.sh
exit=1
  FAIL B10 G027 is form-aware for the compact form
  FAIL B11 G027 still refuses an unevidenced compact phase claim
compact-obligation-basis-selftest: 16 check(s), 2 failure(s)
```

### E-18 — mutation M2: anti-fabrication is pinned specifically (TP-042-14)

**Executed:** YES
**Command:** edit the obligation branch to `|| g027_obligation_state=0` so it can never observe a failure, rerun the pin
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh
exit=1
  ok   B10 a fully attested compact packet claiming implement/test CLEARS G027 — the scope-count proxy no longer contradicts Check 5
  FAIL B11 G027 still refuses an unevidenced compact phase claim
compact-obligation-basis-selftest: 16 check(s), 1 failure(s)
```

B10 stays green, B11 goes red. This is the discrimination that matters: B10
alone would pass a G027 that simply skipped the compact form. B11 is what keeps
the gate a gate, and it is non-vacuous.

Both mutations were reverted by EDIT. A third round trip proves byte identity:

```
fixed          dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783
mutated (M1')  41cc1bcd821612c075660b7a6362a02e4dd1d00de75b9d0a3c800d436f255a78
reverted       dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783

$ bash bubbles/scripts/compact-obligation-basis-selftest.sh   -> exit 0
compact-obligation-basis-selftest: 16 check(s), 0 failure(s)
```

No `git checkout`, `git restore`, `git stash` or `git reset` was used at any
point in either scope.

### E-19 — a defect in this packet's OWN coverage, found and fixed

**Executed:** YES
**Command:** `bash bubbles/scripts/compact-obligation-basis-selftest.sh` before and after the fixture fix
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Adding B10/B11 surfaced that five EXISTING assertions were passing on
contaminated fixtures. `build_fixture()` scrubbed only lines carrying the
literal marker `BUG-042 obligation attestation`. The shipped base packet
(`BUG-038`) carries its OWN four attestation lines, which have no marker, so
they survived the copy and re-satisfied every obligation the builder was asked
to damage:

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh
exit=1
  FAIL B2  one unattested obligation is refused
  FAIL B2b the refusal is specific        (0 obligations were refused; expected exactly 1)
  FAIL B3  unchecked attestation refused distinguishably
  FAIL B5  dischargedIn is load-bearing   (a bare tick satisfied 'reproduce-before-fix')
  FAIL B6  lint refuses a missing attestation
  FAIL B11 G027 still refuses an unevidenced compact phase claim
compact-obligation-basis-selftest: 16 check(s), 6 failure(s)
```

This is NOT caused by the Check 4 predicate extraction. The ORIGINAL inline
predicate, run verbatim against a manually rebuilt damaged fixture, also finds
the "damaged" obligation still attested:

```
$ grep -E "^\- \[x\] " fixture/report.md | grep -F -- "reproduce-before-fix" | grep -cF -- "report.md"
1
```

The scrub now removes every attestation-SHAPED line naming any declared
obligation id, which is what the builder's own comment already claimed. After
the fix:

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh
exit=0
compact-obligation-basis-selftest: 16 check(s), 0 failure(s)
```

### E-20 — BUG-038 containment: exactly one authorised edit

**Executed:** YES
**Command:** `shasum -a 256 bugs/BUG-038-progress-timeout-bsd-wc-padding/*`, before and after
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
                     before                                                              after
bug.md      89cad203488daa34aab31176915a05cb69f18d24bc3644e7819cbc6350b2dfb1   89cad203488daa34aab31176915a05cb69f18d24bc3644e7819cbc6350b2dfb1  UNCHANGED
state.json  4b4cfe203242de9d255e2868f25f44ac910f7633acaa31360b9b644a0424629c   4b4cfe203242de9d255e2868f25f44ac910f7633acaa31360b9b644a0424629c  UNCHANGED
report.md   a6f4f951076a876d58f80ed2221ebb0555c64a95e8ab518566ced260bad2bed9   44e0e14b01aa47972eed9609dc3045703d5a83d7bf7ef0a74f399c4b4cd345bd  CHANGED
```

The single `report.md` change moves `DI-038-04` from `routed` to `resolved` and
appends a `### DI-038-04 resolution` block carrying the guard output above.
`BUG-032`, `BUG-033`, `BUG-037`, `BUG-039` and `BUG-041` were not touched.

### E-21 — Scope 2 static analysis, attributed against HEAD

**Executed:** YES
**Command:** `shellcheck -x` code profile of the working tree vs a HEAD copy placed in the same directory
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
$ diff <(HEAD copy | codes) <(working tree | codes)
7c7
<   18 SC2295
---
>   19 SC2295
```

Every other code count is identical (SC1091×10, SC2001×3, SC2015×4, SC2016×5,
SC2126×3, SC2129×1, SC2329×4). The single SC2295 delta resolves to
`scope_label="${scope_path#$feature_dir/}"` at line 4765 — Scope 1 code, not
authored in Scope 2. Scope 2's edited ranges (833-859, 1465-1492, 4258-4300)
carry ZERO shellcheck findings, verified by listing every flagged line number:

```
SC2295 at: 598 879 902 968 970 1505 1550 1601 1679 1914 1916 4499 4549 4553 4561 4597 4611 4765
```

`shellcheck -x` exits 1 on this file at HEAD and continues to exit 1; the
non-zero status is pre-existing (SC1091 sourcing plus style infos), not
introduced here.

### E-12 — static analysis, attributed against HEAD

**Executed:** YES
**Command:** `shellcheck -x -f gcc` on each touched script; `git show HEAD:<f> | shellcheck -f gcc -` for the two pre-existing scripts
**Phase Agent:** bubbles.implement
**Claim Source:** executed

```
bubbles/scripts/bug-packet-resolve.sh                    findings=0
bubbles/scripts/bug-packet-resolve-selftest.sh           findings=0
bubbles/scripts/compact-obligation-basis-selftest.sh     findings=0
bubbles/scripts/state-transition-guard.sh                findings=46
bubbles/scripts/artifact-lint.sh                         findings=23

bubbles/scripts/state-transition-guard.sh      HEAD=45  worktree=46
bubbles/scripts/artifact-lint.sh               HEAD=22  worktree=23
```

The three files this change introduces are clean at zero findings. The two
pre-existing scripts each gained exactly one finding versus HEAD, both severity
`note`:

```
state-transition-guard.sh  new: SC2295 (Expansions inside ${..} need quoting separately)
artifact-lint.sh           new: SC2001 (See if you can use ${variable//search/replace})
```

Honest attribution limit: the working tree carries uncommitted changes from
several concurrent sessions, so a diff against HEAD is not a diff against this
change. The `artifact-lint.sh` SC2001 was located at line 439,
`echo "$bug_packet_facts" | sed 's/^/   -> /'`, which is inside BUG-041's
resolver-read block and is NOT BUG-042 code. The `state-transition-guard.sh`
SC2295 was not individually located and may belong to this change or to another
session's edit; it is reported rather than dismissed. Both codes already occur at
HEAD (SC2295 18 times, SC2001 6 times), and zero warnings or errors were added.

### E-13 — this packet passes artifact lint (TP-042-09)

**Executed:** YES
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-042-compact-packet-has-no-completion-basis`
**Phase Agent:** bubbles.implement
**Claim Source:** executed

Result recorded in § Verification Run below.

## Code Diff Evidence

No code was written in this session. The four script changes and one registry
change were authored by the jetsam-killed predecessor dispatch and were verified
here, as stated in § Summary. The only files this session created are the six
artifacts of this packet.

The mutations in E-6 through E-10 are the only edits this session made to
framework files, and every one of them was reverted by edit and proven
byte-identical by sha256 in the same evidence block.

Current baseline hashes of the three mutated files, as of the end of this
session:

```
d8dc14eb30a7584c60e8bbc2a041490f333f3405cae3687d85f7d093e1704e82  bubbles/registry/bug-packet.yaml
923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f  bubbles/scripts/bug-packet-resolve.sh
4839e3a3c06e7fcc930d2ec332b66af5e9432fb83c793444157380dbc6518d63  bubbles/scripts/state-transition-guard.sh
```

## Disposition of F-041-04

F-041-04 recorded that the guard's form-awareness had no BEHAVIOURAL committed
pin: `state-transition-guard-selftest.sh` contained zero references to
`bug_packet_form` or `bug-packet-resolve`. BUG-041 could only narrow this — its
P6 pins wiring, not behaviour.

Re-derived in this session:

```
wc -l bubbles/scripts/state-transition-guard-selftest.sh   ->  5953
grep -cE "bug_packet_form|bug-packet-resolve" <that file>  ->  0
```

The finding is confirmed as stated. The file has no `--only` / `--filter` verb, so
partial execution is not available; running the pin there means running 5,953
lines that drive the guard dozens of times, which no session working on this
change has been able to complete.

**Disposition: CLOSED, at a different site.** The behavioural assertion F-041-04
asked for exists and was EXECUTED in this session — E-9 and E-10 above. It lives
in `bubbles/scripts/compact-obligation-basis-selftest.sh`, bounded to three guard
invocations, and it was shown to go red under mutation, which is the only thing
that distinguishes it from an assertion nobody ran. `framework-validate.sh`'s
discovered-selftest sweep globs `bubbles/scripts/*-selftest.sh`, so the placement
costs no coverage and required no wiring step.

The residue is honest and small: `state-transition-guard-selftest.sh` itself
still has zero references, so a reader auditing THAT file will not find the pin.
The design records the siting decision and the reason. No assertion was added to
that file, because this session could not execute it, and an unexecuted assertion
is worse than an absent one.

## Verification Run

Final command sweep, all executed in this session:

| Command | Exit | Result |
|---|---|---|
| `bash -n` × 4 scripts | 0 | all ok |
| `bash bubbles/scripts/bug-packet-resolve.sh` | 0 | 8 `obligation=` lines |
| `bash bubbles/scripts/bug-packet-resolve-selftest.sh` | 0 | 16 checks, 0 failures |
| `bash bubbles/scripts/compact-obligation-basis-selftest.sh` | 0 | 13 checks, 0 failures |
| guard on `BUG-038-progress-timeout-bsd-wc-padding` | 1 | 20 failures, 3 warnings |
| guard on `BUG-037-uservalidation-opt-out-acceptance` | 1 | 38 failures, 4 warnings |
| `artifact-lint.sh` on this packet | 0 | PASSED |

`framework-validate` and `release-check` were NOT run: another terminal holds the
validation lock and both are explicitly out of scope for this session. Full
framework validation and release readiness therefore remain UNPROVEN for this
change and are listed as such.

## Obligation attestations

This packet is `full` form, so the compact form's `obligationsRetained` set does
not gate it. The four obligations are nonetheless discharged, and are recorded
here so the packet demonstrates the shape it defines.

- [x] **reproduce-before-fix** — discharged in `report.md`. E-7 reproduces the
      original failure on demand by severing the resolver emission, producing the
      verbatim pre-fix line `ZERO DoD checkbox items — cannot verify completion`.

```
🔴 BLOCK: Resolved scope artifacts have ZERO DoD checkbox items — cannot verify completion
```

- [x] **adversarial-regression** — discharged in `report.md`. E-10 shows the
      behavioural pin RED under mutation and E-9 shows it GREEN reverted; both
      runs are shown, not asserted.

```
under mutation: exit=1  compact-obligation-basis-selftest: 1 check(s), 1 failure(s)
reverted:       exit=0  compact-obligation-basis-selftest: 13 check(s), 0 failure(s)
```

- [x] **root-cause-stated** — discharged in `bug.md` § Root Cause, which names the
      cause (obligations expressed only in registry prose with no consumer, while
      every readable basis was scoped to absent or unreachable artifacts) rather
      than the symptom (zero checkboxes).

```
grep -c "^## Root Cause" bugs/BUG-042-compact-packet-has-no-completion-basis/bug.md  ->  1
```

- [x] **evidence-is-execution** — discharged in `report.md`. Every claim in E-1
      through E-13 names the command that produced it and carries its real exit
      code. Nothing in this report is cited from the dispatching brief.

```
Claim Source tags in this report: executed (13 of 13 evidence blocks)
```

---

## Session — release-manifest registration of `compact-obligation-basis-selftest.sh`

**Phase:** implement

### E-14 — the defect

The selftest this packet introduced was UNTRACKED. `bubbles/scripts/trust-metadata.sh::bubbles_manifest_entry_is_tracked()`
uses git tracking as the ONLY admission test for the release manifest, so the
file was absent from `bubbles/release-manifest.json` — the exact set `install.sh`
copies downstream — and the manifest-freshness check reported the tree stale:

```
$ bash bubbles/scripts/generate-release-manifest.sh --check
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
exit=1
```

### E-15 — the fix

Staged, then regenerated (the manifest is generated; no sha256 was hand-written):

```
$ git add -- bubbles/scripts/compact-obligation-basis-selftest.sh
$ bash bubbles/scripts/generate-release-manifest.sh
Updated release manifest: 7.28.0 (930 managed files)     gen=0
$ bash bubbles/scripts/generate-release-manifest.sh --check
Release manifest is current: 7.28.0 (930 managed files)  check=0
$ grep -c "compact-obligation-basis" bubbles/release-manifest.json
1
```

### E-16 — re-verification

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh
compact-obligation-basis-selftest: 16 check(s), 0 failure(s)   cob=0
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-042-compact-packet-has-no-completion-basis
Artifact lint PASSED.                                          al42=0
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
5 failure(s), 2 warning(s)                                     g38=1   (unchanged — no regression)
```

`framework-validate` and `release-check` were NOT run in this session (forbidden;
~2h each).

**Claim Source:** executed.

---

## Session — the registered selftest is framework-source-only, and the generated surfaces it moved

**Phase:** implement

Registering `compact-obligation-basis-selftest.sh` in the release manifest (the
section above) put it into the set `install.sh` copies downstream, and into
`framework-validate`'s DISCOVERED sweep, which has only `run_check`. Two
consequences had to be settled here.

### E-17 — the downstream defect the registration created

The selftest builds every behavioural fixture from a SHIPPED
`bugs/BUG-*/state.json` that declares the compact form. `bugs/` is a
framework-source tree and is never installed, so from a real installed repo the
selftest refuses at P1 — a verdict about a fixture the installed tree cannot
have, not about the guard behaviour under test:

```
$ cd /tmp/bb-ds && bash .github/bubbles/scripts/compact-obligation-basis-selftest.sh
  ok   P0 the registry declares 4 obligation(s) for the compact form
  FAIL P1 a shipped compact packet is available as the fixture base
       no bugs/BUG-*/state.json declares the compact form; the behavioural fixtures cannot be built
compact-obligation-basis-selftest: 2 check(s), 1 failure(s)
real    0m0.052s
EXIT=1
```

`/tmp/bb-ds` is a throwaway repo produced by the real installer
(`bash install.sh --local-source <this checkout>`), given the managed-doc
placeholders its own resolved docs registry demands — the same fixture shape
`v5.3-selftest.sh` builds.

### E-18 — the fix uses the mechanism a sibling already uses, not a new exemption

`framework-validate.sh` already carries `run_check_self_only`, and
`bug-packet-selftest.sh` is wired through it for the same class of reason (its
P3 needs the repo-root `BUGS.md`, which is not installed). The compact selftest
is wired the same way, immediately after it. Nothing was added to
`known_downstream_failures[]`, no assertion was weakened, and no timeout bound
was moved.

Scheduling it there also removes it from the discovered sweep, because
`bubbles_scheduled_selftests()` (guard-lib.sh:539) treats `run_check` and
`run_check_self_only` alike. Verified in both install modes — it runs once in
source and skips with a named reason downstream:

```
$ bash bubbles/scripts/framework-validate.sh --list-tier=full            # source
149:WOULD-RUN: Compact-packet obligation basis selftest (BUG-042)        # exactly one line

$ cd /tmp/bb-ds2 && bash .github/bubbles/scripts/framework-validate.sh --list-tier=full
226:==> Compact-packet obligation basis selftest (BUG-042)
227:SKIP: Compact-packet obligation basis selftest (BUG-042) (framework-source-only; install-mode=downstream)
```

### E-19 — the generated surfaces the new selftests moved

`docs/generated/gate-coverage-map.md` was stale because this packet's selftest
added gate references. The regenerated doc differs from HEAD by four lines, all
of them selftest-reference counts, and every one is attributable:

| Row | HEAD → fresh | Cause |
|---|---|---|
| G027 `framework-validate scripts` | 3 → 4 | `compact-obligation-basis-selftest.sh` (new, this packet) |
| G041 `framework-validate scripts` | 2 → 3 | same file |
| G041 enforcer list | +`compact-obligation-basis-selftest.sh` | same file |
| G057 `framework-validate scripts` | 4 → 5 | `acceptance-authority-selftest.sh` S4-T8, added this session (`git show HEAD:…` contains no `G057`) |

Nothing unrelated swept in: no gate gained or lost a declared enforcer, the
gate count stayed 121, and no summary figure moved.

```
$ bash bubbles/scripts/generate-gate-coverage-map.sh
generate-gate-coverage-map: wrote docs/generated/gate-coverage-map.md (121 gates mapped)   gen=0
$ bash bubbles/scripts/generate-gate-coverage-map.sh --check
generate-gate-coverage-map: docs/generated/gate-coverage-map.md is in sync (121 gates mapped)   check=0
$ bash bubbles/scripts/generate-gate-coverage-map-selftest.sh
generate-gate-coverage-map selftest passed.   self=0
```

The generator selftest SKIPs without PyYAML, which the ambient shell does not
have; it was run with the managed venv (`~/.cache/bubbles/python/bin`) on PATH,
which is how `framework-validate` runs it.

The map is a manifest-managed file, so regenerating it — and then editing
`framework-validate.sh` — made the release manifest stale twice. It was
regenerated, never hand-edited, and is current:

```
$ bash bubbles/scripts/generate-release-manifest.sh
Updated release manifest: 7.28.0 (930 managed files)      gen=0
$ bash bubbles/scripts/generate-release-manifest.sh --check
Release manifest is current: 7.28.0 (930 managed files)   check=0
```

### E-20 — no regression

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh
compact-obligation-basis-selftest: 16 check(s), 0 failure(s)                       cob=0
$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)                             bpr=0
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance
🔴 TRANSITION BLOCKED: 38 failure(s), 4 warning(s)                                 g37=1  (unchanged)
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
🔴 TRANSITION BLOCKED: 5 failure(s), 2 warning(s)                                  g38=1  (unchanged)
```

`framework-validate` and `release-check` were NOT run in this session (the
operator runs them separately).

**Claim Source:** executed.

