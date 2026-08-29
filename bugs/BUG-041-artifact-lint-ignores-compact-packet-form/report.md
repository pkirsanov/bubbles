# Report: BUG-041 — `artifact-lint.sh` demands the full artifact set from every packet

### Summary

`bubbles/registry/bug-packet.yaml` is the declared single authority for bug
artifacts. It records three forms and the artifact set each requires. It has no
production reader.

`bubbles/scripts/artifact-lint.sh` carries a hard-coded copy of the `full`
form's set and applies it to every packet.
`bubbles/scripts/state-transition-guard.sh` carries the same list a second time.
A packet taking the `compact` form, which IMP-047 S-D made the default route,
therefore cannot pass either surface.

This packet reproduced the defect, root-caused it, and designed the repair. It
made NO change to any framework script, because `framework-validate` was
executing throughout the session.

---

### Completion Statement

**The fix has landed and is measured. It is NOT certified.**

This statement was written by the design session and read "documented and
designed, NOT fixed". A later session landed the eight-file implementation, and
the implementation session recorded below ran the design's own non-vacuity plan
against it. The statement is updated to match what is now measurable, not to
claim more.

Delivered by the design session:

- The defect reproduced on a real, admitted packet, with real exit codes.
- The root cause located precisely, at named file and line.
- A second affected enforcement surface discovered, which the dispatching brief
  did not mention.
- Two corrections to the dispatching brief, both measured.
- A design that follows the framework's own established registry-plus-one-reader
  pattern, with a six-mutation non-vacuity plan.

Delivered by the implementation session, evidenced in E-I1 through E-I9:

- All eight files in `design.md` §6 exist and carry the change.
- Mutations M1, M2, M3, M4 and M5 behave exactly as `design.md` §5 predicts.
- M6 does NOT. It is recorded as a finding against the fix, not adjusted.
- Four neighbour packets lint clean, and three selftests pass.

NOT delivered, and the reason each is open:

- DoD items 7, 10, 11, 12 and 13 stay unchecked. E-I9 states which and why.
- `framework-validate` and `release-check` were forbidden to the session, so
  "all existing tests pass" has no evidence and is not claimed.
- The guard surface does not yet agree with the linter on a compact packet.
  F-041-02 records the site the design's §3.5 list missed.

Status stays `in_progress`. No terminal `certification.status` is written.
`nextRequiredOwner` is `bubbles.validate`.

---

### Test Evidence

Every block below is real output from a command executed in this session, with
its real exit code. No command output is filtered or truncated.

#### E-1 — the registry declares three artifacts for the compact form

```
$ grep -n "requiredArtifacts" -A 10 bubbles/registry/micro-fix-packet.yaml
75:requiredArtifacts:
76-  - bug.md
77-  - report.md
78-  - state.json
79-
80-# Obligations the compact packet may NEVER drop. These are the assurance floor.
81-# Dropping any of them converts proportionality into a loophole.
82-preservedObligations:
83-  - id: reproduce-before-fix
84-    requirement: report.md records the failing reproduction, with real output, BEFORE the fix.
85-  - id: adversarial-regression
```

The same file delegates the artifact question:
`artifactAuthority: bubbles/registry/bug-packet.yaml`.

#### E-2 — the linter has zero awareness of the compact form

```
$ grep -ic "micro" bubbles/scripts/artifact-lint.sh
0
```

Exit 1, because `grep -c` returns 1 when the count is zero.

#### E-3 — the packet under test is admitted

```
$ bash bubbles/scripts/micro-fix-admission.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
[micro-fix-admission] bugs/BUG-038-progress-timeout-bsd-wc-padding declares packet: micro. Checking admission.
[micro-fix-admission] admitted: compact packet is proportionate for this defect.
MICRO_FIX_ADMISSION_EXIT=0
```

All eight conditions are answered in `bug.md`:

```
$ grep -n "micro-fix-admission:" bugs/BUG-038-progress-timeout-bsd-wc-padding/bug.md
106:- micro-fix-admission: no-new-behavior = no
110:- micro-fix-admission: no-schema-change = no
113:- micro-fix-admission: no-auth-surface = no
115:- micro-fix-admission: no-payment-surface = no
117:- micro-fix-admission: no-secret-surface = no
120:- micro-fix-admission: no-deployment-surface = no
122:- micro-fix-admission: no-cross-product-effect = no
127:- micro-fix-admission: contract-preserving = yes
```

#### E-4 — RED. The same admitted packet fails lint

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/spec.md
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/design.md
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/uservalidation.md
✅ Required artifact exists: state.json
❌ Missing required artifact: bugs/BUG-038-progress-timeout-bsd-wc-padding/scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
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
❌ report.md missing required section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
❌ report.md missing required section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint FAILED with 6 issue(s).
ARTIFACT_LINT_EXIT=1
```

This confirms the dispatching brief's reproduction exactly: exit 1, six issues,
the same six lines.

#### E-5 — the packet is correctly formed against its own contract

```
$ ls -la bugs/BUG-038-progress-timeout-bsd-wc-padding/
total 64
drwxr-xr-x@ 5 pkirsanov  staff    160 Aug 23 16:02 .
drwxr-xr-x@ 9 pkirsanov  staff    288 Aug 24 22:46 ..
-rw-r--r--@ 1 pkirsanov  staff   5663 Aug 23 16:12 bug.md
-rw-r--r--@ 1 pkirsanov  staff  14406 Aug 23 16:12 report.md
-rw-r--r--@ 1 pkirsanov  staff   4257 Aug 23 16:12 state.json
```

Three artifacts, matching `form: compact` exactly, with nothing extra.

#### E-6 — the registry has no production reader

```
$ grep -rn "bug-packet.yaml" --include="*.sh" bubbles/scripts/
bubbles/scripts/bug-packet-selftest.sh:7:# returned FOUR answers across four surfaces. `bubbles/registry/bug-packet.yaml`
bubbles/scripts/bug-packet-selftest.sh:32:REGISTRY="$REPO_ROOT/bubbles/registry/bug-packet.yaml"
bubbles/scripts/bug-packet-selftest.sh:42:  ok "P1 bug-packet.yaml declares the full, compact and single-file forms"
bubbles/scripts/bug-packet-selftest.sh:112:  bad "P3 surfaces point at registry" "only $pointing of 3 point at bug-packet.yaml"
bubbles/scripts/acceptance-authority-selftest.sh:34:BUG_PACKET_REGISTRY="$SCRIPT_DIR/../registry/bug-packet.yaml"
bubbles/scripts/acceptance-authority-selftest.sh:652:# --- S2-T7: bug-packet.yaml agrees with the registry -------------------------
bubbles/scripts/acceptance-authority-selftest.sh:661:    bad "S2-T7 bug-packet.yaml declares a uservalidation.md artifact" "no entry found"
bubbles/scripts/acceptance-authority-selftest.sh:663:    bad "S2-T7 bug-packet.yaml purpose agrees with the registry" \
bubbles/scripts/acceptance-authority-selftest.sh:664:      "registry shippedState=$s2t7_shipped but bug-packet.yaml still says shipped UNCHECKED"
bubbles/scripts/acceptance-authority-selftest.sh:666:    ok "S2-T7 bug-packet.yaml's uservalidation purpose agrees with acceptance-authority.yaml (shipped $s2t7_shipped)"
bubbles/scripts/acceptance-authority-selftest.sh:668:    bad "S2-T7 bug-packet.yaml purpose names the shipped state" "$s2t7_purpose"
bubbles/scripts/acceptance-authority-selftest.sh:671:    bad "S2-T7 bug-packet.yaml is readable" "not found: $BUG_PACKET_REGISTRY"
```

Every hit is a selftest. Both selftests read the registry to assert the
registry's own shape. No enforcement surface consumes it.

#### E-7 — the defect exists on a SECOND surface, undiscovered by the brief

```
$ sed -n '759p;799p;805p' bubbles/scripts/state-transition-guard.sh
required_files=("spec.md" "design.md" "uservalidation.md" "state.json")
    fail "Missing required artifact: $feature_dir/scopes.md"
    fail "Missing required artifact: $feature_dir/report.md"
```

Compare with `artifact-lint.sh` lines 401-406, 447, 453. The lists are
byte-identical. Two hand-kept copies, one inert contract.

#### E-8 — the declaration field exists, contradicting the brief

The brief states BUG-038 has no machine-readable declaration.

```
$ jq "{status, workflowMode, packetKind, microFix, nextRequiredOwner}" bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json
{
  "status": "in_progress",
  "workflowMode": "bugfix-fastlane",
  "packetKind": null,
  "microFix": null,
  "nextRequiredOwner": null
}
```

Those two field names indeed do not exist. The field that does exist is
`packet`:

```
$ jq ".packet" bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json
"micro"

$ jq ".artifacts" bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json
{
  "bug": "bug.md",
  "report": "report.md",
  "state": "state.json"
}
```

It is consumed:

```
$ grep -n '"packet"' bubbles/scripts/micro-fix-admission.sh
124:# The compact route used to require an explicit `"packet": "micro"` opt-in,
131:#   1. state.json says "packet": "full"  -> full, no enforcement here.
132:#   2. state.json says "packet": "micro" -> compact, enforced.
144:  if grep -q '"packet"[[:space:]]*:[[:space:]]*"micro"' "$STATE" 2>/dev/null; then
146:  elif grep -q '"packet"[[:space:]]*:[[:space:]]*"full"' "$STATE" 2>/dev/null; then
```

It is declared by no registry:

```
$ grep -rn "^packet:\|\"packet\"" bubbles/registry/*.yaml
(no output)
grep_exit=1
```

And the stored word is outside the declared vocabulary. `bug-packet.yaml`
declares `full`, `compact`, `single-file` and states "there are no synonyms and
no fifth form". The stored word is `micro`.

#### E-9 — only one packet declares anything at all

```
$ for f in bugs/*/state.json; do printf "%-52s packet=%s\n" "$(dirname $f)" "$(jq -r ".packet // \"<absent>\"" $f)"; done
bugs/BUG-032-planning-maturity-guard-false-positives packet=<absent>
bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization packet=<absent>
bugs/BUG-035-validation-control-plane-churn-and-scope-overreach packet=<absent>
bugs/BUG-036-completed-scopes-count-format-sensitive packet=<absent>
bugs/BUG-037-uservalidation-opt-out-acceptance       packet=<absent>
bugs/BUG-038-progress-timeout-bsd-wc-padding         packet=micro
bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure packet=<absent>
```

This measurement is the load-bearing fact behind the fail-closed design. Six of
seven packets carry no declaration, so a design that requires an explicit
declaration before relaxing anything cannot change their verdict.

#### E-10 — the two report-section failures are a different defect

```
$ bash bubbles/scripts/report-sections-resolve.sh | grep "^always="
always=Summary|yes
always=Completion Statement|yes
always=Test Evidence|yes
resolver_exit=0

$ grep -inE "form|packet|compact|micro" bubbles/registry/report-sections.yaml
82:# Sections required only when the packet is being PROMOTED. Enforcement is the
169:# One evidence-location contract (IMP-047 S-B, old PD-16). Three forms are
177:# forms.
179:  forms:
200:    - a claim with no executed command in any of the three forms
```

The `alwaysRequired` set has no form dimension. BUG-038's evidence exists, under
different headings:

```
$ grep -nE "^#{1,4} " bugs/BUG-038-progress-timeout-bsd-wc-padding/report.md
1:# Report: BUG-038 — `bubbles_run_with_progress_timeout` BSD `wc` padding
8:## Summary
17:## Root cause isolation
34:## Attribution — pre-existing at HEAD, not a regression
50:## Reproduction BEFORE fix — fails without the fix (RED)
55:# BUG-wc-padding RED baseline guard-lib-timeout-selftest
85:## The fix
115:### Portability of the fix
134:## Reproduction AFTER fix — passes with the fix (GREEN)
139:# BUG-038 GREEN guard-lib-timeout-selftest after wc normalization
173:## Second-order impact on the other caller
215:## Lint
263:## Sweep
284:### Fixed
290:### Safe — verified, not assumed
321:### Out of boundary — not inspected for fixing
332:## Boundary compliance
347:## Unresolved
```

So four of the six failures are the linter defect, and two are an authoring gap
in BUG-038. `design.md` §2.2 records the determination and the alternative.

#### E-11 — this packet's own admission verdict

Answered against the FIX, not the defect. The fix changes an observable lint
verdict, changes a persisted artifact declaration contract, and ships to every
consumer repository.

```
$ bash bubbles/scripts/micro-fix-admission.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form
[micro-fix-admission] bugs/BUG-041-artifact-lint-ignores-compact-packet-form fails admission (no-new-behavior no-schema-change no-cross-product-effect) - it escalates automatically to the full bug packet.
[micro-fix-admission] Escalation is mechanical. There is no reviewer discretion and no override flag.
MICRO_FIX_ADMISSION_EXIT=0
```

**Route taken: `full`.** The escalation is mechanical, and it is the honest
outcome rather than a preference.

The dispatching brief anticipated an irony, that a packet documenting this
defect would itself be blocked by it. That irony does not occur. Because the fix
alters observable behaviour, changes an artifact contract, and crosses the
repository boundary, admission escalates on three conditions and this packet
takes the `full` route, which the linter already handles correctly.

#### E-12 — the sequencing constraint is real

```
$ ps -eo pid,etime,comm,args | grep -E "state-transition-guard-selftest|framework-validate|cli.sh" | grep -v grep
15112       01:05 bash             bash bubbles/scripts/evidence-capture.sh --label FINAL framework-validate (post BUG-038/039, attempt 1) -- /usr/bin/perl -e a
15125       01:05 bash             bash bubbles/scripts/cli.sh framework-validate
15503       01:05 bash             bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh

$ grep -c "artifact-lint" bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/state-transition-guard.sh
bubbles/scripts/state-transition-guard-selftest.sh:53
bubbles/scripts/state-transition-guard.sh:8
```

`framework-validate` was running for the duration of this investigation. The 53
and 8 reference counts are confirmed. No framework script was edited.

---

## Implementation session evidence

Everything from E-I1 down was executed by the implementation session, after the
eight-file change had landed in the working tree. Every exit code is real. No
command output is filtered.

**One method note, stated up front.** `design.md` §5 requires the M6 baseline to
be captured before the first edit, and says it cannot be reconstructed
afterwards. That capture happened in the session that landed the change and its
output was not carried forward. This session therefore did NOT capture a
pre-edit baseline. It reconstructed one from `HEAD` instead, because `HEAD`
predates the change and other sessions were editing the working tree, which
makes reverting it unsafe and reverting it partially worse than not reverting it
at all. The reconstruction is a `git archive HEAD bubbles bugs` extraction into
`/tmp/bug041-head-tree`, run read-only. It is weaker than a true pre-edit
capture in one specific way, named in E-I6: it can only compare the two LINTERS
against today's packets, so a packet whose own content changed since `HEAD`
would confound the result. E-I6 shows this did not happen for any undeclared
packet.

#### E-I1 — the eight files in design.md §6 all carry the change

```
$ ls -l bubbles/scripts/bug-packet-resolve.sh
-rw-r--r--@ 1 pkirsanov  staff  7863 Aug 25 06:59 bubbles/scripts/bug-packet-resolve.sh
$ grep -c -E "compact|bug-packet-resolve" bubbles/scripts/artifact-lint.sh
11
$ grep -n "^declaration:" bubbles/registry/bug-packet.yaml
175:declaration:
$ git status --porcelain -- <the eight paths>
 M bubbles/registry/bug-packet.yaml
 M bubbles/scripts/artifact-lint.sh
 M bubbles/scripts/bug-packet-selftest.sh
 M bubbles/scripts/micro-fix-admission.sh
 M bubbles/scripts/state-transition-guard.sh
?? bubbles/scripts/bug-packet-resolve.sh
$ grep -c -- "--resolve-form" bubbles/scripts/micro-fix-admission.sh bubbles/scripts/micro-fix-admission-selftest.sh
bubbles/scripts/micro-fix-admission.sh:8
bubbles/scripts/micro-fix-admission-selftest.sh:18
$ ls -l bubbles/scripts/bug-packet-resolve-selftest.sh
-rw-r--r--@ 1 pkirsanov  staff  7293 Aug 25 06:59 bubbles/scripts/bug-packet-resolve-selftest.sh
```

**Claim Source:** executed.

#### E-I2 — M1: an undeclared full packet missing design.md still fails

Fixture: `bugs/BUG-037-uservalidation-opt-out-acceptance` copied to
`/tmp/bug041-m1/BUG-901-m1-full-missing-design`, `.packet` absent, `design.md`
deleted.

```
$ bash bubbles/scripts/artifact-lint.sh /tmp/bug041-m1/BUG-901-m1-full-missing-design
M1_EXIT=1
ℹ️  Bug packet form: full (no state.json .packet declaration; registry absent-default)
❌ Missing required artifact: /tmp/bug041-m1/BUG-901-m1-full-missing-design/design.md
```

The default path is not blinded. Silence resolves to `full`, and the missing
artifact is named. **Claim Source:** executed.

#### E-I3 — M2: declaring `compact` is a request, not a grant

Fixture: `bugs/BUG-038-progress-timeout-bsd-wc-padding` copied to
`/tmp/bug041-m2/BUG-902-m2-forged-compact`, `state.json` `.packet` forged to the
canonical word `compact`, and `bug.md`'s `no-payment-surface` answer flipped
from `no` to `yes` so admission must refuse it.

```
$ bash bubbles/scripts/micro-fix-admission.sh --resolve-form /tmp/bug041-m2/BUG-902-m2-forged-compact
form=full
RESOLVE_FORM_EXIT=0

$ bash bubbles/scripts/artifact-lint.sh /tmp/bug041-m2/BUG-902-m2-forged-compact
M2_EXIT=1
ℹ️  Bug packet form: compact (state.json .packet="compact")
❌ state.json declares the 'compact' packet but micro-fix admission resolves 'full'; the 'full' artifact set is required
❌ Missing required artifact: /tmp/bug041-m2/BUG-902-m2-forged-compact/design.md
❌ Missing required artifact: /tmp/bug041-m2/BUG-902-m2-forged-compact/uservalidation.md
❌ Missing required artifact: /tmp/bug041-m2/BUG-902-m2-forged-compact/scopes.md
```

The declaration was READ, then OVERRIDDEN by admission, and the full set was
applied. `.packet` is not an override flag. **Claim Source:** executed.

#### E-I4 — M3 and M4: the registry cannot degrade silently

M3 copies `bubbles/scripts` and `bubbles/registry` to `/tmp/bug041-m3` and
deletes the registry there. The shipped registry was never touched.

```
$ bash /tmp/bug041-m3/bubbles/scripts/artifact-lint.sh <a real full packet>
M3_EXIT=2
ERROR: cannot read bubbles/registry/bug-packet.yaml
   -> bug-packet-resolve: registry not found: /tmp/bug041-m3/bubbles/scripts/../registry/bug-packet.yaml
   -> usage: bug-packet-resolve.sh [--registry FILE]
```

Exit 2, the registry is named, and the output carries no `✅` line, so no
artifact check was reported as passed.

M4 copies the shipped registry to `/tmp/bug041-m4.yaml` and deletes the three
`artifacts:` entries under `form: compact`, leaving the key with an empty body.

```
$ bash bubbles/scripts/bug-packet-resolve.sh --registry /tmp/bug041-m4.yaml
M4_EXIT=2
bug-packet-resolve: /tmp/bug041-m4.yaml declares form 'compact' with zero artifacts

$ bash bubbles/scripts/bug-packet-resolve.sh --registry /tmp/bug041-m4.yaml 2>/dev/null | wc -l
0
```

Non-zero exit, and stdout is empty, so a caller cannot read a partial fact set
and proceed. **Claim Source:** executed.

#### E-I5 — M5: six issues become exactly two, not zero

This is the anti-over-reach control and it needed a reconstruction, for a reason
worth stating plainly.

`design.md` §2.2 determined that two of BUG-038's six issues were an authoring
gap in that packet, not a linter defect, and routed them to its owner. That
owner has since authored both sections in. `bugs/BUG-038-...` therefore lints
exit 0 today, and the live packet can no longer exhibit the 6-issue
pre-condition the control is defined against.

Rather than weaken the control to what the live packet can still show, the
pre-condition was reconstructed: BUG-038 was copied to `/tmp/bug041-m5` and the
two headings `## Completion Statement` and `## Test Evidence` were renamed in
the COPY. `bugs/BUG-038-...` itself was not touched, as `design.md` §6 requires.

```
$ bash /tmp/bug041-head-tree/bubbles/scripts/artifact-lint.sh /tmp/bug041-m5/BUG-038-progress-timeout-bsd-wc-padding
HEAD_EXIT=1
HEAD_ISSUES=6
❌ Missing required artifact: .../spec.md
❌ Missing required artifact: .../design.md
❌ Missing required artifact: .../uservalidation.md
❌ Missing required artifact: .../scopes.md
❌ report.md missing required section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
❌ report.md missing required section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence

$ bash bubbles/scripts/artifact-lint.sh /tmp/bug041-m5/BUG-038-progress-timeout-bsd-wc-padding
WORK_EXIT=1
WORK_ISSUES=2
❌ report.md missing required section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
❌ report.md missing required section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
```

Six to exactly two, and both survivors are report-section issues. The fix
cleared every missing-artifact issue and NO evidence-contract issue. A result of
0 would have meant `report-sections.yaml` was relaxed; it was not.
**Claim Source:** executed.

#### E-I6 — M6: the prediction is FALSE, recorded as F-041-01

M6 is the design's acceptance gate and it says: capture every packet's full lint
output, diff, and treat any difference on a packet with `.packet` absent as a
defect in the fix. Both linters were run against the same working-tree packets,
so the only variable is the linter.

```
packet                                      head  work  difflines
BUG-032-planning-maturity-guard-false-...      0     0      5
BUG-033-receipt-target-grouping-and-...        0     0      5
BUG-035-validation-control-plane-churn-...     0     0      5
BUG-036-completed-scopes-count-format-...      0     0      5
BUG-037-uservalidation-opt-out-acceptance      0     0      5
BUG-038-progress-timeout-bsd-wc-padding        1     0     14
BUG-039-interpreter-unusable-misreported...    0     0      5
BUG-041-artifact-lint-ignores-compact-...      0     0      5
```

BUG-038 is the packet the fix targets, so its change is the intended effect. The
other seven are the control, and they are NOT byte-identical. The diff is the
same on all seven:

```
$ diff .../BUG-032-....head .../BUG-032-....work
1c1,2
< ✅ Required artifact exists: spec.md
---
> ℹ️  Bug packet form: full (no state.json .packet declaration; registry absent-default)
> ✅ Required artifact exists: bug.md
```

Two changes. The added `ℹ️` line is cosmetic. The second is not: the required
set for a FULL bug packet moved from `spec.md` to `bug.md`.

```
$ bash bubbles/scripts/bug-packet-resolve.sh | grep "^artifact=full"
artifact=full|bug.md|no
artifact=full|design.md|no
artifact=full|scopes.md|no
artifact=full|report.md|no
artifact=full|uservalidation.md|no
artifact=full|scenario-manifest.json|yes
artifact=full|state.json|no
```

**F-041-01.** The registry's full form names `bug.md`; the list `artifact-lint.sh`
carried at `HEAD` named `spec.md`. Routing bug packets through the registry
therefore stopped requiring `spec.md` of them. No verdict moved, because every
full packet in the repository carries both files, so the widening is currently
unobservable in outcomes:

```
packet                                      spec.md  bug.md
BUG-032 / 033 / 035 / 036 / 037 / 039 / 041    Y        Y
BUG-038                                        N        Y
```

That is a real widening of what a full bug packet may omit, arrived at
correctly — the registry is the declared authority and it says `bug.md` — but
NOT named anywhere in `design.md`, and it is exactly the class of change M6
exists to catch. The design's expectation is left as written and the measurement
is recorded against it. DoD item 7 stays unchecked.

**What the reconstruction cannot rule out.** Because both linters ran against
today's packets, a packet whose own content changed since `HEAD` could produce a
diff that is not the linter's doing. That did not occur here: the diff is
byte-for-byte the same two lines on all seven control packets, including
`BUG-033`, which another session has dirty. A content-driven diff would vary by
packet. **Claim Source:** executed.

#### E-I7 — neighbours and selftests

```
$ bash bubbles/scripts/artifact-lint.sh bugs/<packet>
BUG-037-uservalidation-opt-out-acceptance                            exit=0
BUG-038-progress-timeout-bsd-wc-padding                              exit=0
BUG-039-interpreter-unusable-misreported-as-classification-failure   exit=0
BUG-041-artifact-lint-ignores-compact-packet-form                    exit=0

$ bash bubbles/scripts/bug-packet-selftest.sh
  ok   A5 1 non-selftest surface(s) consume the bug-artifact contract
bug-packet-selftest: 9 check(s), 0 failure(s)
BUG_PACKET_SELFTEST_EXIT=0

$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
  ok   A1 a form declaring zero artifacts is refused (exit 2)
  ok   A2 an absent registry exits non-zero and emits no facts (exit 2)
  ok   A3 the absent-default is 'full', so silence cannot reduce a requirement
  ok   A4 every bypass-shaped flag is rejected as a usage error
  ok   P5 1 non-selftest surface(s) call bug-packet-resolve.sh
bug-packet-resolve-selftest: 10 check(s), 0 failure(s)
RESOLVE_SELFTEST_EXIT=0

$ bash bubbles/scripts/micro-fix-admission-selftest.sh
  ok   --resolve-form writes no outcome-log entry, while the plain run writes 1
micro-fix-admission-selftest: 23/23 checks passed
MFA_SELFTEST_EXIT=0
```

Independent probes, re-derived rather than inherited. `ctl` is
`bugs/BUG-037-...` copied intact; A and B declare `packet: full` explicitly; C
leaves the declaration absent; D is a copy with `bugId` removed and a
feature-shaped directory name.

```
probe  setup                                   exit  resolved form
ctl    full packet intact                        0   full (absent-default)
A      declared full, design.md removed          1   full (.packet="full")
B      declared full, 3 artifacts removed        1   full (.packet="full")
C      absent declaration, design.md removed     1   full (absent-default)
D      non-bug dir, complete                     0   none emitted
```

D exits 0 rather than 1 because the directory copied for it is a COMPLETE
packet; the earlier session's D was an incomplete one. The load-bearing property
holds either way: no packet-form line is emitted, and the feature literal list
(`spec.md`, `design.md`, `uservalidation.md`, `state.json`, `scopes.md`,
`report.md`) is applied unchanged, so `bug-packet.yaml` claims no authority over
non-bug directories. **Claim Source:** executed.

#### E-I8 — F-041-02: the guard still does not agree with the linter

`design.md` §3.5 says replacing the literal checks at `state-transition-guard.sh`
lines 759, 799 and 805 makes the guard stop rejecting a packet the linter
admits. That change landed. The objective is still unmet.

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
STG_EXIT=1
bubbles/scripts/state-transition-guard.sh: line 582: bugs/BUG-038-progress-timeout-bsd-wc-padding/scopes.md: No such file or directory
```

One line of output, and no verdict. `build_scope_analysis_units` reads
`scopes.md` unconditionally, and the compact form does not require it, so the
guard dies before it can evaluate anything.

Attributed against `HEAD` before being claimed:

```
$ bash /tmp/bug041-head-tree/bubbles/scripts/state-transition-guard.sh <same packet>
HEAD_STG_EXIT=1
.../state-transition-guard.sh: line 582: .../scopes.md: No such file or directory
```

Identical, at the same line. **This is NOT a regression from BUG-041.** It is a
fourth site the design's three-site list did not find. The Test Plan row
"`state-transition-guard.sh` agrees with `artifact-lint.sh`" cannot be marked
satisfied. **Claim Source:** executed.

#### E-I9 — shellcheck, attributed, and the unchecked DoD items

`bug-packet-resolve.sh` produces zero findings. Every finding is in
`artifact-lint.sh`, so each was attributed against `HEAD` before being claimed:

```
              HEAD  working
SC1091 (info)    2        2
SC2001 (style)   6        7   <- +1
SC2016 (info)    1        1
SC2094 (info)    6        6
SC2129 (style)   1        1
SC2295 (info)    6        6
total           22       23
```

One new finding, `SC2001` at line 439, on
`echo "$bug_packet_facts" | sed 's/^/   -> /'`. It is style-level, and it is the
seventh instance of a form the file already used six times at `HEAD`, including
on the neighbouring `report_sections_facts` line the new code was modelled on.
Attributable to this change; consistent with the file's existing style.

**The five unchecked DoD items and why each is unchecked** (as recorded by the
implementation session; item 7 has since been superseded by E-I9, leaving four).

| DoD item | Why it is not checked |
|---|---|
| 7 — M6 byte-identical for undeclared packets | **SUPERSEDED — now checked.** `bubbles.design` amended the expectation (`design.md` §5.1); the amended wording was re-measured in a later session and met on all six undeclared packets. See E-I9. |
| 10 — all existing tests pass | `framework-validate` and `release-check` were forbidden to this session. Four packets and three selftests are not the suite, and no evidence supports the broader claim. |
| 11 — scenario-specific E2E regression tests for every changed behaviour | Gherkin scenarios 4 and 5 are covered by `bug-packet-resolve-selftest.sh` A1 and A2. Scenarios 1, 2 and 3 are covered only by the `/tmp` fixtures in E-I2 and E-I3, which do not survive the session. `artifact-lint-selftest.sh` is unmodified at `HEAD` and its `compact` references concern compact evidence blocks, an unrelated feature. |
| 12 — broader E2E regression suite passes | Same as 10. |
| 13 — bug marked as Fixed in `bug.md` | Two findings are open (F-041-01, F-041-02) and items 7, 10, 11 and 12 are unevidenced. A `Fixed` marking would assert a completeness this session did not measure. |

**Claim Source:** executed for every row above except the reasoning, which is
`interpreted` from the results in E-I1 through E-I8.

---

### Verification of the dispatching brief

| Brief claim | Verdict | Evidence |
|---|---|---|
| `micro-fix-packet.yaml` requires 3 artifacts at line ~75 | CONFIRMED, line 75 | E-1 |
| `grep -ic "micro" artifact-lint.sh` returns 0 | CONFIRMED | E-2 |
| `micro-fix-admission.sh` admits BUG-038 | CONFIRMED, exit 0 | E-3 |
| Lint fails BUG-038 with exit 1 and 6 issues | CONFIRMED, all six lines match | E-4 |
| The packet carries exactly its 3 contract artifacts | CONFIRMED | E-5 |
| `state.json` has `packetKind` and `microFix` null | CONFIRMED, both absent from the schema | E-8 |
| "no machine-readable declaration for a linter to read" | **INCORRECT.** `.packet` exists, is `"micro"`, and is consumed | E-8 |
| All six failures are the same defect | **INCORRECT.** Four are the linter defect, two are an authoring gap in BUG-038 | E-10 |
| The defect is in `artifact-lint.sh` | CONFIRMED, and also in `state-transition-guard.sh`, which the brief did not mention | E-7 |

---

### Boundary compliance

This session created files only under
`bugs/BUG-041-artifact-lint-ignores-compact-packet-form/`. Modification times
prove that no forbidden file was written.

```
$ date "+%Y-%m-%d %H:%M:%S"
2026-08-25 00:09:15

$ stat -f "%Sm  %N" -t "%Y-%m-%d %H:%M:%S" <forbidden files> <my packet>
2026-08-23 11:42:59  bubbles/scripts/artifact-lint.sh
2026-08-23 18:15:37  bubbles/scripts/state-transition-guard.sh
2026-08-24 07:54:11  bubbles/scripts/state-transition-guard-selftest.sh
2026-08-23 11:42:59  bubbles/registry/bug-packet.yaml
2026-08-23 16:12:17  bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json
2026-08-25 00:02:27  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/bug.md
2026-08-25 00:05:04  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/design.md
2026-08-25 00:07:14  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/report.md
2026-08-25 00:08:04  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/scenario-manifest.json
2026-08-25 00:05:53  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/scopes.md
2026-08-25 00:05:23  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/spec.md
2026-08-25 00:08:38  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/state.json
2026-08-25 00:07:38  bugs/BUG-041-artifact-lint-ignores-compact-packet-form/uservalidation.md
```

Every forbidden path was last written one or two days before this session. Every
packet file was written during it.

```
$ git status --porcelain bugs/BUG-041-artifact-lint-ignores-compact-packet-form
?? bugs/BUG-041-artifact-lint-ignores-compact-packet-form/
```

`git status` also reports modifications to `artifact-lint.sh`,
`state-transition-guard.sh`, `bug-packet.yaml` and other paths. Those are
uncommitted changes from earlier sessions, which the mtimes above date to
2026-08-23 and 2026-08-24. They are not this session's work.

**Caveat for the implementer.** Every line number and every registry quotation in
this packet was read from the WORKING TREE, not from `HEAD`, because that is what
the enforcement surfaces execute. `bubbles/registry/bug-packet.yaml` and
`bubbles/scripts/artifact-lint.sh` both carry uncommitted changes. Re-confirm the
line numbers in §6 of `design.md` before editing.

#### Self-lint of this packet

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form
Artifact lint PASSED.
SELF_ARTIFACT_LINT_EXIT=0
```

The full unfiltered output is 33 lines, all green. This packet took the `full`
route, which the linter already handles correctly, so it passes the check that
BUG-038 cannot.

---

### Remaining Work

Owned by `bubbles.validate`.

The implementation has landed and `design.md` §5's mutation plan has been run
against it. Five of the six mutations behave as designed. What remains is
everything the implementation session could not evidence.

**Open DoD items, with the reason each is open.** DoD 7, 10, 11, 12 and 13 stay
unchecked. E-I9 states each reason. The two that need another owner's decision:

- DoD 11 has no persistent test for Gherkin scenarios 1, 2 and 3. M1 and M2
  proved those behaviours on throwaway `/tmp` fixtures, which do not survive the
  session. `artifact-lint-selftest.sh` is unmodified at HEAD and its six
  `compact` references are about compact EVIDENCE BLOCKS, an unrelated feature.
  Someone must decide whether the packet-form path gets cases in that selftest
  or a new one.
- DoD 10 and 12 need `framework-validate`, which was forbidden to the
  implementation session.

**Two findings against the fix.** Neither is repaired here, because both change
what the fix means rather than how it is recorded.

- F-041-01 — M6's byte-identical prediction is false. The required-artifact set
  for a full BUG packet moved from `spec.md` to `bug.md`, which is the
  registry's declared contract but is a widening the design did not name.
  Detail in E-I6.
- F-041-02 — `state-transition-guard.sh:582` still hard-fails on a compact
  packet, so the guard does not yet agree with the linter. The design's §3.5
  named three sites and there are four. Pre-existing at HEAD, so not a
  regression, but it leaves the §3.5 objective unmet. Detail in E-I8.

**One finding routed elsewhere and now resolved.** The design routed
`bugs/BUG-038-.../report.md`'s two missing report sections to that packet's
owner. That owner has since authored both sections in, so BUG-038 lints exit 0
today. E-I5 explains why the M5 control was therefore measured on a
reconstruction rather than on the live packet.

---

#### E-I9 — M6 re-measured against the AMENDED expectation: met

E-I6 measured M6 against its original "byte-identical" wording and reported it
FALSE, raising `F-041-01`. `bubbles.design` has since adjudicated that finding in
`design.md` §5.1, preserving the original wording verbatim and replacing the
expectation. This section re-measures against the amended wording. It does not
re-use E-I6's numbers; every figure below comes from commands run in this
session.

**The baseline is still HEAD, and HEAD is still pre-fix.**

```
$ git status --porcelain -- bubbles/scripts/artifact-lint.sh \
    bubbles/registry/bug-packet.yaml bubbles/scripts/bug-packet-resolve.sh
 M bubbles/registry/bug-packet.yaml
 M bubbles/scripts/artifact-lint.sh
?? bubbles/scripts/bug-packet-resolve.sh
$ git log --oneline -1
ce2c5ed (HEAD -> main) chore(manifest): refresh after final integration
```

All three fix files are uncommitted, so `HEAD` carries none of the fix. The
baseline was reconstructed without touching the working tree — other sessions
are editing it — by extracting `HEAD` into a scratch directory:

```
$ git archive HEAD bubbles | tar -x -C /tmp/al41head
$ ls /tmp/al41head/bubbles/scripts/artifact-lint.sh
/tmp/al41head/bubbles/scripts/artifact-lint.sh
```

This works because `artifact-lint.sh` resolves `script_repo_root` and
`artifact_repo_root` separately (lines 65-95). The extracted copy sources its
own `HEAD` siblings from its own `SCRIPT_DIR`, while the packet under test is
resolved from the packet path. Both linters were therefore pointed at the SAME
working-tree packet, by the SAME absolute path, so the linter is the only
variable — the constraint E-I6 named.

**The population is six, not seven.** E-I6 called seven packets "undeclared".
`design.md` §5.1's RETRACTION establishes why that was wrong: the declaration
lives in `state.json`, not in a `.packet` file. Re-probed correctly:

```
BUG-032-planning-maturity-guard-false-positives                     packet=[]
BUG-033-receipt-target-grouping-and-wrapper-normalization           packet=[]
BUG-035-validation-control-plane-churn-and-scope-overreach          packet=[]
BUG-036-completed-scopes-count-format-sensitive                     packet=[]
BUG-037-uservalidation-opt-out-acceptance                           packet=[]
BUG-039-interpreter-unusable-misreported-as-classification-failure  packet=[]
BUG-038-progress-timeout-bsd-wc-padding                             packet=["packet": "micro"]
BUG-041-artifact-lint-ignores-compact-packet-form                   packet=["packet": "full"]
```

BUG-041 declares `full` and BUG-038 declares `micro`. Both are DECLARED and both
sit outside M6's population. Six packets are undeclared. Correcting the
population makes the test narrower, not easier: it removes a packet that had
agreed with the expectation.

**Clause 1 — verdict unchanged. Six of six.**

```
BUG-032-planning-maturity-guard-false-positives                     head=0 work=0 difflines=5
BUG-033-receipt-target-grouping-and-wrapper-normalization           head=0 work=0 difflines=5
BUG-035-validation-control-plane-churn-and-scope-overreach          head=0 work=0 difflines=5
BUG-036-completed-scopes-count-format-sensitive                     head=0 work=0 difflines=5
BUG-037-uservalidation-opt-out-acceptance                           head=0 work=0 difflines=5
BUG-039-interpreter-unusable-misreported-as-classification-failure  head=0 work=0 difflines=5
```

No exit code moved, in either direction. This is the non-blinding proof M6 exists
to provide, and it survives the amendment unchanged: the amendment relaxed the
OUTPUT clause and left the VERDICT clause exactly as strict as it was.

**Clause 2 — output differs in exactly the one permitted respect.** The diff is
identical in content on all six packets. BUG-032 is shown; the other five
produce the same three content lines:

```
$ diff <(bash /tmp/al41head/bubbles/scripts/artifact-lint.sh "$PWD/bugs/BUG-032-...") \
       <(bash bubbles/scripts/artifact-lint.sh "$PWD/bugs/BUG-032-...")
1c1,2
< ✅ Required artifact exists: spec.md
---
> ℹ️  Bug packet form: full (no state.json .packet declaration; registry absent-default)
> ✅ Required artifact exists: bug.md
```

Mapped clause by clause to the amended wording:

| Amended clause | Observed |
|---|---|
| "`spec.md` ceases to be required" | the one removed line |
| "`bug.md` becomes required" | one of the two added lines |
| "one informational line naming the resolved form" | the `ℹ️` line |
| "any other output difference … is a defect" | none. `difflines=5` is those 3 content lines plus `diff`'s own `1c1,2` and `---` markers |

There is no residue. The five diff lines are fully accounted for, so the
amendment's "exactly one respect" is satisfied literally rather than
approximately.

**DoD item 7 is therefore checked.** It is checked because every clause of the
amended expectation was measured true by commands run in this session — not
because an expectation was bent to fit a result. The distinction matters here
specifically: E-I6 declined to check this item under the original wording and
raised `F-041-01` instead, and that refusal is what caused the expectation to be
adjudicated by its owner rather than quietly edited by its implementer. The
amendment carries no obligation to check the box; the measurement does.

`F-041-01` is now resolved: adjudicated by `design.md` §5.1 and verified here.
It no longer blocks anything. `F-041-02` remains open and deferred.

**Packet lint after the edit.** The first run of `artifact-lint.sh` against this
packet after checking item 7 exited **1**, on one issue: `DoD item marked [x] has
no evidence block`. That is a true finding about layout, not about the claim. The
check reads the 15 lines following a `[x]` for an evidence marker
(`artifact-lint.sh:1544-1545`), and the adjudication narrative had been placed
between the checkbox and its fenced block, pushing the block out of that window.
The narrative was moved below the evidence rather than the check being worked
around. Re-run:

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form
ℹ️  Bug packet form: full (state.json .packet="full")
✅ Required artifact exists: bug.md
…
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
```

**DoD now 9 of 13.** The four that remain unchecked were each re-checked in this
session rather than carried forward on assumption:

| DoD item | Re-checked reason |
|---|---|
| 10 — all existing tests pass | `framework-validate` and `release-check` are forbidden to this session too. Nothing measured here supports a suite-wide claim. |
| 11 — scenario-specific E2E for every changed behaviour | Still uncovered. `git status --porcelain -- bubbles/scripts/artifact-lint-selftest.sh` is empty, and the only selftests referencing `bug-packet-resolve` are `bug-packet-resolve-selftest.sh` and `bug-packet-selftest.sh`. No committed test exercises `artifact-lint.sh`'s packet-form path, so Gherkin scenarios 1, 2 and 3 remain proven only on `/tmp` fixtures. |
| 12 — broader E2E regression suite | Same forbidden command as 10. |
| 13 — bug marked Fixed in `bug.md` | `F-041-01` closing removes one blocker, not the others. `F-041-02` is still open and deferred, and items 10, 11 and 12 remain unevidenced. |

**Claim Source:** executed.

---

## Coverage session evidence — DoD item 11 closed

Session scope: close DoD item 11 by giving the packet-form branch committed
coverage in its owning selftest. `framework-validate` and `release-check` were
forbidden and were not run. `state-transition-guard.sh` was not edited;
`F-041-02` stays deferred per design.md §3.5.1.

### 1. Boundary widening, verified bounded

`bubbles/scripts/artifact-lint-selftest.sh` was not in
`workBoundary.allowedPaths`. It is the owning selftest of `artifact-lint.sh`,
the file this packet changed, and item 11 demands coverage of that change. The
path was added to `allowedPaths` and the rationale recorded in design.md
`## Change Boundary`, including a clause forbidding unrelated
`artifact-lint-selftest.sh` edits from joining by analogy.

Before the widening:

```
$ bash bubbles/scripts/work-boundary-resolve.sh \
    --feature-dir bugs/BUG-041-artifact-lint-ignores-compact-packet-form \
    --candidate-repo bubbles \
    --candidate-path bubbles/scripts/artifact-lint-selftest.sh \
    --require-allowed-paths
disposition=route-same-repo
repoMatch=true
reason=candidate path 'bubbles/scripts/artifact-lint-selftest.sh' is in-repo but outside the declared allowedPaths — file/route a finding rather than inline-fixing unrelated work
EXIT_BEFORE=0
```

After, with three negative controls proving the widening is bounded and not
blanket:

```
JSON_OK
bubbles/scripts/artifact-lint-selftest.sh                  in-boundary exit=0
bubbles/scripts/state-transition-guard-selftest.sh         route-same-repo exit=0
bubbles/registry/report-sections.yaml                      route-same-repo exit=0
bugs/BUG-038-progress-timeout-bsd-wc-padding/state.json    route-same-repo exit=0
```

The target moved; a sibling selftest, an out-of-boundary registry and another
packet's state all still route out.

### 2. Coverage added — T18 through T22, 12 assertions

Additive only:

```
$ git diff --numstat -- bubbles/scripts/artifact-lint-selftest.sh
140     0       bubbles/scripts/artifact-lint-selftest.sh
```

140 insertions, 0 deletions. No existing assertion modified, relaxed,
renumbered or deleted.

```
$ bash bubbles/scripts/artifact-lint-selftest.sh
PASS: T18 a declared compact packet resolves to the compact form
PASS: T18 the compact form is confirmed by micro-fix admission
PASS: T18 bug.md is a required artifact of the compact form
PASS: T18 an admitted compact packet has NO missing-artifact failure
PASS: T19 a declared full packet resolves to the full form
PASS: T19 a full packet missing design.md still FAILS
PASS: T20 an undeclared packet falls back to the registry absent-default
PASS: T20 the absent-default full set still fails a missing artifact
PASS: T21 a compact declaration that fails admission is refused
PASS: T21 the refused packet is then linted as the full artifact set
PASS: T22 bug.md is required because bug-packet.yaml declares it
PASS: T22 spec.md is required of no bug packet form

artifact-lint selftest: 43/43 assertions passed
SELFTEST_EXIT=0
```

31 pre-existing assertions, 12 added, 43 total.

T22 is the sharpest of the five. The historical hard-coded list and the
registry-sourced set disagree on exactly two members, and T22 asserts both
directions: `bug.md` is required of every bug form, which the old list never
named, and `spec.md` is required of none, which the old list demanded. That is
the `F-041-01` adjudication in design.md §5.1 pinned as a test.

### 3. Non-vacuity — two mutations, all 12 assertions moved

The selftest harness exits at its first failure, so it can only ever surface one
red per run. A throwaway probe rebuilt the same five fixtures and reported all
twelve needles under one tree state, so no assertion is taken on trust.

MUTATION A restored the pre-fix behaviour by making the packet-form branch
unreachable, which leaves the hard-coded feature list in force. 9 of 12 RED:

```
=== MUTATION A: pre-fix hard-coded set ===
  T18a   RED      want=PRESENT got=ABSENT  Bug packet form: compact (state.json .packet="micro")
  T18b   RED      want=PRESENT got=ABSENT  Packet form 'compact' confirmed by micro-fix admission
  T18c   RED      want=PRESENT got=ABSENT  Required artifact exists: bug.md
  T18d   RED      want=ABSENT  got=PRESENT Missing required artifact
  T19a   RED      want=PRESENT got=ABSENT  Bug packet form: full (state.json .packet="full")
  T19b   green    want=PRESENT got=PRESENT Missing required artifact: .../BUG-902-full-missing-design/design.md
  T20a   RED      want=PRESENT got=ABSENT  Bug packet form: full (no state.json .packet declaration; registry absent-default)
  T20b   green    want=PRESENT got=PRESENT Missing required artifact: .../BUG-903-undeclared/design.md
  T21a   RED      want=PRESENT got=ABSENT  micro-fix admission resolves 'full'
  T21b   green    want=PRESENT got=PRESENT Missing required artifact: .../BUG-904-forged-compact/design.md
  T22a   RED      want=PRESENT got=ABSENT  Missing required artifact: .../BUG-905-registry-sourced-set/bug.md
  T22b   RED      want=ABSENT  got=PRESENT Missing required artifact: .../BUG-905-registry-sourced-set/spec.md
--- real selftest under mutation A ---
FAIL: T18 a declared compact packet resolves to the compact form
SELFTEST_EXIT_MUT_A=1
```

Three assertions stayed green under A. They are reported rather than hidden:
T19b, T20b and T21b are the anti-over-reach controls. They assert behaviour the
pre-fix and post-fix versions SHARE — a full packet missing `design.md` fails in
both — so mutation A structurally cannot move them. Their discriminator is the
opposite error: a fix that reduced the artifact set for every packet rather than
for the compact form only.

MUTATION B injected that opposite error, forcing `bug_packet_form=compact` for
every bug packet. Exactly those three go RED and nothing else changes:

```
=== MUTATION B: over-reach, compact forced on every bug packet ===
  T19b   RED      want=PRESENT got=ABSENT  Missing required artifact: .../BUG-902-full-missing-design/design.md
  T20b   RED      want=PRESENT got=ABSENT  Missing required artifact: .../BUG-903-undeclared/design.md
  T21b   RED      want=PRESENT got=ABSENT  Missing required artifact: .../BUG-904-forged-compact/design.md
--- real selftest under mutation B ---
FAIL: T19 a full packet missing design.md still FAILS
SELFTEST_EXIT_MUT_B=1
```

Every one of the 12 new assertions is moved by a mutation. Zero are vacuous.

Residue after reverting both mutations:

```
$ shasum -a 256 bubbles/scripts/artifact-lint.sh
cf79a4c1af36c3d7b841f864ffe5f9eb36baa99116a7f0cf2c78bb73dfb232d6
$ grep -c MUTATION bubbles/scripts/artifact-lint.sh
0
```

Byte-identical to the hash taken before mutation A was applied.

### 4. Item 11's wording, read rather than assumed

The item reads "Scenario-specific E2E regression tests for EVERY new/changed/
fixed behavior". EVERY was checked against what this packet actually changed,
not against the design's §6 plan:

| Changed behaviour | Committed coverage |
|---|---|
| `artifact-lint.sh` packet-form resolution | T18-T22, 12 assertions |
| `bug-packet-resolve.sh` (new) | `bug-packet-resolve-selftest.sh` |
| `micro-fix-admission.sh --resolve-form` (new) | `micro-fix-admission-selftest.sh`, 18 references |
| `bug-packet.yaml` `declaration:` block | read by the resolver selftest and by T18-T22 |

`state-transition-guard.sh` appears in §6 but is NOT in that table, verified
rather than assumed:

```
$ grep -n "bug-packet-resolve\|bug_packet_form" bubbles/scripts/state-transition-guard.sh
(empty)
$ grep -c "bug-packet-resolve\|packet_form" bubbles/scripts/state-transition-guard-selftest.sh
0
```

The fourth site never landed. `F-041-02` remains open and deferred per design.md
§3.5.1, and this packet changed no behaviour there, so item 11's EVERY is
satisfied over the changes that were actually made.

The five Gherkin scenarios, all now committed:

| Scenario | Was | Now |
|---|---|---|
| S1 admitted compact passes | `/tmp` only | T18 |
| S2 undeclared linted as full | `/tmp` only | T20 |
| S3 compact does not bypass admission | `/tmp` only | T21 |
| S4 unreadable registry refuses | A2, resolver selftest | unchanged |
| S5 zero-artifact form refused | A1, resolver selftest | unchanged |

Item 11 checked. DoD moves 9/13 to 10/13.

### 5. Packet still lints clean

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
PACKET_LINT_EXIT=0
$ printf "checked=%s unchecked=%s\n" ...
checked=10 unchecked=3
```

### 6. Still open after this session

Items 10, 12 and 13 stay unchecked, for the reasons already recorded above and
unchanged by this session: items 10 and 12 require `framework-validate` and
`release-check`, both forbidden here, and item 13 asserts a completeness that
`F-041-02` being open contradicts.

**Claim Source:** executed.

---

## Session — F-041-02 closed: the fourth site repaired

Phase: implement. This session repaired the fourth site
`design.md` §3.5.1 recorded and deferred. The deferral reason was cross-session
contention on `bubbles/scripts/state-transition-guard.sh`; that file's mtime was
`Aug 23 18:15:37 2026` on entry with no process holding it, so the contention had
cleared. The BUG-033 edits already in the working tree were left untouched and the
change below is additive.

### E-J1 — the defect, reproduced before any edit

The design predicted death before verdict. It is worse than a hard failure: the
guard emits ONE line and no `failureCount`, no `failedGateIds`, no gate lines at
all, so a compact packet is structurally un-evaluable.

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
GUARD_EXIT=1
--- lines: 1 ---
1:bubbles/scripts/state-transition-guard.sh: line 582: bugs/BUG-038-progress-timeout-bsd-wc-padding/scopes.md: No such file or directory
```

**Claim Source:** executed.

### E-J2 — the TRUE failing line is 619, not 582

`design.md` §3.5.1 names line 582 twice, as "Definition" and as the failing site.
Only the first is right. Line 582 is the `build_scope_analysis_units() {` header;
the read is the `done < "$scope_path"` redirection at line **619**. Bash names the
compound command's opening line in a redirection diagnostic, which is why the
message says 582 and why taking that message at face value points at a `local`
declaration instead of an I/O operation.

```
$ awk 'NR>=575 && NR<=586' bubbles/scripts/state-transition-guard.sh
582: build_scope_analysis_units() {
583:   local scope_path="$1"

$ grep -n 'done < "$scope_path"' bubbles/scripts/state-transition-guard.sh
619:  done < "$scope_path"
1612:  done < "$scope_path"
3923:  done < "$scope_path"
4328:  done < "$scope_path"

$ grep -n "^set -" bubbles/scripts/state-transition-guard.sh
29:set -euo pipefail
```

The `set -euo pipefail` at line 29 is what converts a failed redirection into
process death rather than a skipped loop. Three sibling `done < "$scope_path"`
reads exist at 1612, 3923 and 4328; all three sit inside
`for scope_path in ${scope_files[@]+"${scope_files[@]}"}` loops, so they are
reached only for paths already enrolled in `scope_files`.

**Claim Source:** executed.

### E-J3 — the fix, and why it is shaped this way

Four edits, all additive.

1. `build_scope_analysis_units` gains `[[ -f "$scope_path" ]] || return 0` before
   the loop. This is the class fix §3.5.1 asked for: no caller can turn a missing
   artifact into an un-evaluable packet. Whether a missing `scopes.md` is a
   FAILURE stays Check 1's decision, now made on a live guard.
2. A resolver-backed packet-form block reads the artifact set through
   `bubbles/scripts/bug-packet-resolve.sh`, the sole production reader of
   `bubbles/registry/bug-packet.yaml`. The list is not restated in the guard. A
   private branch here would be the fourth private copy of the contract, which is
   the alternative `design.md` §4 rejects.
3. Check 1 uses the resolver-derived required set when, and only when, a reduced
   form is positively declared AND micro-fix admission grants it.
4. The single-file `scopes.md` requirement reports the absence as the declared
   shape of the packet instead of a missing artifact, on that same condition.

Fail-closed in the strict direction. A non-bug directory, a missing resolver, an
unreadable registry, an absent declaration, a word outside the declared
vocabulary, an admission refusal, or a form resolving to zero artifacts all keep
the pre-existing unreduced behaviour. Reduction happens only on a positive,
admitted declaration, so silence, breakage and ambiguity all resolve to MORE
checking, never less. Declaring the reduced form stays a REQUEST, not a grant,
which is what `bug-packet.yaml`'s `escalation.overrideFlag: none` requires.

**Claim Source:** executed.

### E-J4 — the compact packet now produces a real verdict

```
$ bash -n bubbles/scripts/state-transition-guard.sh
BASH_N_EXIT=0
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
GUARD38_AFTER_EXIT=1
lines=333
failedGateIds: [G055,G060,G022,G053,G040,G033,G095]
failedChecks: [Check-4-structure,Check-5-structure]
failureCount: 17
```

One line became 333, and the verdict block exists. Exit 1 is correct: BUG-038 is
`in_progress` and the guard measures the bar for `done`. Check 1 resolves the
deprecated `micro` alias through the registry vocabulary:

```
--- Check 1: Required Artifacts ---
ℹ️  INFO: Bug packet: packet form 'compact' confirmed by micro-fix admission
✅ PASS: Required artifact exists: bug.md
✅ PASS: Required artifact exists: report.md
✅ PASS: Required artifact exists: state.json
ℹ️  INFO: scopes.md not required by the 'compact' packet form; scope-derived analysis has no units
✅ PASS: Required artifact exists: report.md
```

**Claim Source:** executed.

### E-J5 — no preserved obligation was silently waived

`micro-fix-packet.yaml` preserves four obligations on the compact form. This is a
reduction of ARTIFACTS, not of obligations, so each was checked against the live
run rather than assumed.

| Preserved obligation | Evaluated on the compact run? | Evidence |
|---|---|---|
| `reproduce-before-fix` | YES — and it FAILS | Check 3E reads "the scope/report artifacts"; with no scope artifacts it evaluated `report.md` and blocked: "no RED→GREEN ordering was found" |
| `adversarial-regression` | PARTLY — see below | Same Check 3E RED→GREEN block covers the failing-then-passing proof. Its other mechanical expression is `regressionExpectations`, which `bug-packet.yaml` scopes `appliesToForms: [full]` |
| `root-cause-stated` | NO mechanical check on ANY form | The guard has no root-cause check for full packets either, so this is not a compact-form reduction |
| `evidence-is-execution` | YES — and it FAILS twice | G053 blocked on the missing `### Code Diff Evidence`; G033 blocked on a stale evidence receipt |

Two scope-derived checks now report loudly rather than skipping:

```
--- Check 4: DoD Completion (Zero Unchecked) ---
ℹ️  INFO: DoD items total: 0 (checked: 0, unchecked: 0)
🔴 BLOCK: Resolved scope artifacts have ZERO DoD checkbox items — cannot verify completion

--- Check 5: Scope Status Cross-Reference ---
ℹ️  INFO: Resolved scopes: total=0, Done=0, In Progress=0, Not Started=0, Blocked=0
🔴 BLOCK: Resolved scope artifacts have no scope status markers
```

State this plainly rather than dress it up. `adversarial-regression` is preserved
by `micro-fix-packet.yaml` but its Test Plan row and DoD checkboxes are declared
`appliesToForms: [full]` by `bug-packet.yaml`, so on a compact packet the guard
has no artifact in which to look for them. This session did NOT waive that: it
reports "cannot verify completion" as a BLOCK. The consequence is that a compact
packet still cannot reach `done` through this guard, because it has no DoD
checkboxes to satisfy Check 4 and no scope markers to satisfy Check 5. That is a
CONTRACT gap, not a code gap: some obligation carrier would have to be relocated
to `report.md` for the compact form, and the registries own that decision. It is
recorded as `F-041-03` rather than repaired here.

**Claim Source:** executed.

### E-J6 — mutation proof, both directions

Mutation A removed BOTH compact-aware elements. It reproduces the original death
exactly:

```
$ bash -n bubbles/scripts/state-transition-guard.sh
MUT_A_BASH_N=0
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding
MUT_A_G38_EXIT=1
lines=1
bubbles/scripts/state-transition-guard.sh: line 582: bugs/BUG-038-progress-timeout-bsd-wc-padding/scopes.md: No such file or directory
--- verdict lines ---
0
```

Mutation B removed ONLY the form resolution and kept the defensive read guard,
which isolates the two edits. The guard survives, but Check 1 demands four
artifacts the compact form does not declare, and the count rises 17 → 21:

```
MUT_B_G38_EXIT=1
failureCount: 21
--- Check 1: Required Artifacts ---
🔴 BLOCK: Missing required artifact: .../spec.md
🔴 BLOCK: Missing required artifact: .../design.md
🔴 BLOCK: Missing required artifact: .../uservalidation.md
✅ PASS: Required artifact exists: state.json
🔴 BLOCK: Missing required artifact: .../scopes.md
✅ PASS: Required artifact exists: report.md
```

Both mutations were reverted by edit, never by a git command, and the file is
byte-identical to the fixed state after each:

```
$ shasum -a 256 bubbles/scripts/state-transition-guard.sh
7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3
expected 7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3
BASH_N_EXIT=0
```

**Claim Source:** executed.

### E-J7 — full packets: no verdict movement attributable to this change

Two full packets, before and after.

```
                 BEFORE                                        AFTER
BUG-041  exit 1  failureCount: 37                     exit 1  failureCount: 38
         [G055,G057,G061,G041,G022,G053,               [G055,G057,G061,G041,G022,G053,
          G027,G040,G068,G084]                          G027,G040,G068,G033,G084]
         [Check-4-scenario-states,Check-5-structure]  [Check-4-scenario-states,Check-5-structure]

BUG-039  exit 1  failureCount: 29                     exit 1  failureCount: 30
         [G055,G057,G060,G041,G022,G053,G068]         [G055,G057,G060,G041,G022,G053,G068,G033]
         [Check-4-scenario-states]                    [Check-4-scenario-states]
```

Both moved by exactly +1 and the diff shows the delta is one gate, G033:

```
$ diff /tmp/f2-g41-before.txt /tmp/f2-g41-after.txt
7a8
> ℹ️  INFO: Bug packet: packet form 'full' (state.json .packet="full")
329c330
< ✅ PASS: Evidence receipts consulted; no stale receipt backs this transition
---
> 🔴 BLOCK: Evidence receipt(s) are STALE — an input file changed after the evidence was captured …
    "staleReceipts": [ { "ts": "2026-08-24T14:56:55Z", "cmd": "bash bubbles/scripts/evidence-capture.sh
    --label BUG-033 SCN-B033-001 live receipt -- … bash bubbles/scripts/state-transition-guard-selftes…
477c478
< failedGateIds: [G055,G057,G061,G041,G022,G053,G027,G040,G068,G084]
---
> failedGateIds: [G055,G057,G061,G041,G022,G053,G027,G040,G068,G033,G084]
```

G033 is not attributable to the packet-form logic, and that is shown by execution
rather than argued. Under Mutation A — compact-awareness fully removed — BUG-041
still reports 38 with G033 present:

```
MUT_A_G41_EXIT=1
failedGateIds: [G055,G057,G061,G041,G022,G053,G027,G040,G068,G033,G084]
failureCount: 38
```

G033 tracks the fact that the guard FILE changed after a BUG-033 receipt was
captured at `2026-08-24T14:56:55Z`, which any edit to that file produces. The
guard's mtime on entry was `Aug 23 18:15:37 2026`, before that timestamp, which is
why the BUG-033 edits already in the tree had not made it stale and this session's
edit did. Net of that tree-state effect, BUG-041 is 37 → 37 and BUG-039 is
29 → 29 with identical gate and check sets. The only other non-timestamp
difference on either packet is one new INFO line, which does not enter the count.

**Claim Source:** executed.

### E-J8 — artifact-lint and shellcheck

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form
ARTIFACT_LINT_41_EXIT=0
=== End Anti-Fabrication Checks ===
Artifact lint PASSED.
```

`shellcheck -x` on the worktree guard reports 44 findings and exits 1. Attributed
against HEAD before claiming any of them: both revisions were fed to shellcheck on
stdin, identical methodology on both sides, so the comparison is like-for-like.

```
=== HEAD (stdin, no -x) ===        === WORKTREE (stdin, no -x) ===
  10 SC1091                          10 SC1091
   3 SC2001                           3 SC2001
   4 SC2015                           4 SC2015
   5 SC2016                           5 SC2016
   3 SC2126                           3 SC2126
   1 SC2129                           1 SC2129
  18 SC2295                          18 SC2295
   4 SC2329                           4 SC2329
```

Identical code and count profile. This change introduces ZERO new shellcheck
findings; every finding pre-exists at HEAD.

**Claim Source:** executed.

### E-J9 — DoD count unchanged at 10/13, and why no box was checked

No DoD checkbox moved. Items 10 and 12 require `framework-validate` and
`release-check`, both forbidden to this session, so they still have no evidence.
Item 13 asserts the bug is Fixed; `F-041-02` closing removes one of its blockers
but items 10 and 12 remain unmeasured and `F-041-03` is newly open, so checking it
would assert a completeness this session did not measure. Closing a finding is not
the same act as closing a DoD item, and this session performed only the first.

```
checked=10 unchecked=3
```

**Claim Source:** executed.

### E-J10 — what this session did not do

- `framework-validate` and `release-check`: not run, forbidden to this session.
- `design.md` §3.5.1 still says the fix is deferred, and still names line 582 as
  the failing site. `design.md` is owned by `bubbles.design`, not by this agent,
  so the correction to line 619 and the status change from deferred to repaired
  are routed, not applied here.
- BUG-033's uncommitted changes in the guard: not reverted, not staged, not
  restructured. Every edit in this session is additive.

**Claim Source:** executed.

## Session — F-041-02 recorded resolved, independently re-verified

This session was dispatched with a table of expected results and an explicit
instruction to re-derive every one of them rather than cite them. It did. Every
number below is from a command executed in this session against this tree.

### E-K1 — independent re-verification of the claimed results

```
$ grep -cE "bug_packet_form|bug-packet-resolve|bug_packet_artifacts|compact" \
    bubbles/scripts/state-transition-guard.sh
26
   per-pattern: bug_packet_form 20 | bug-packet-resolve 3 |
                bug_packet_artifacts 0 | compact 4

$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-038-progress-timeout-bsd-wc-padding      # COMPACT packet
GUARD38_EXIT=1
lines=333
🔴 TRANSITION BLOCKED: 17 failure(s), 3 warning(s)
BEGIN TRANSITION_GUARD_RESULT_V1
failureCount: 17
END TRANSITION_GUARD_RESULT_V1
"No such file or directory" occurrences in output: 0

$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-037-uservalidation-opt-out-acceptance    # FULL packet
GUARD37_EXIT=1
lines=579
🔴 TRANSITION BLOCKED: 38 failure(s), 4 warning(s)
BEGIN/END TRANSITION_GUARD_RESULT_V1 present, failureCount: 38
scope-analysis lines: grep -c "Scope" = 14
"No such file or directory" occurrences in output: 0

$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
BPR_EXIT=0
  ok   P5 2 non-selftest surface(s) call bug-packet-resolve.sh
bug-packet-resolve-selftest: 10 check(s), 0 failure(s)
```

Every figure in the dispatching table reproduced exactly. Nothing was found to
be wrong. Both guard runs were confirmed read-only: BUG-038's `state.json` and
`report.md` are byte-identical before and after
(`e2aa996c13ae0501…`, `63adbedef1d736c4…`), as is BUG-037's `state.json`
(`abb12da92e323f77…`).

**Claim Source:** executed.

### E-K2 — the pre-fix defect, reproduced rather than cited

The dispatching brief described a compact packet as structurally *un-evaluable*
before the fix. That was not taken on trust. Mutation Z removed both
compact-aware elements — the form resolution and the
`[[ -f "$scope_path" ]] || return 0` read guard inside
`build_scope_analysis_units` — and reproduced the death exactly:

```
$ bash -n bubbles/scripts/state-transition-guard.sh           # under mutation Z
SYNTAX=0
$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-038-progress-timeout-bsd-wc-padding
MUTZ2_38_EXIT=1
lines=1   verdict_lines=0   "No such file or directory"=1
bubbles/scripts/state-transition-guard.sh: line 582: bugs/BUG-038-progress-timeout-bsd-wc-padding/scopes.md: No such file or directory
```

One line. Zero verdict lines. No `failureCount`, no `failedGateIds`, no
`RESULT_V1`. This is worse than a failing gate: the packet could not be
evaluated at all.

**A method correction worth recording.** A first attempt (mutation Z, one
element only — forcing `bug_packet_requires_scopes_md=true` while leaving the
defensive read guard in place) did **not** reproduce the death: 334 lines,
verdict present, zero redirection errors. The fix has **two** independent
elements and either one alone is sufficient to keep the guard alive. A
single-element mutation would have under-stated the defect and mis-attributed
the repair. Recorded because the first attempt reached a measurement.

**Claim Source:** executed.

### E-K3 — no regression to FULL packets, and the mutation that proves the branch is live

The stated critical risk was that making the guard form-aware caused it to skip
scope analysis for FULL packets. It does not, and the reason is structural.

**Mutation X — force `compact` for every packet.**

```
$ bash -n bubbles/scripts/state-transition-guard.sh
SYNTAX=0
$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-037-uservalidation-opt-out-acceptance
MUTX_37_EXIT=1
🔴 TRANSITION BLOCKED: 38 failure(s), 4 warning(s)     <- UNCHANGED
Scope-analysis units: 4                                <- UNCHANGED
lines=578 (baseline 579)

$ diff baseline mutation-X   -> 13 lines, entirely the required-artifact set:
  < ℹ️  INFO: Bug packet: no state.json .packet declaration; applying the
        registry absent-default 'full' artifact set
  < ✅ PASS: Required artifact exists: spec.md
  < ✅ PASS: Required artifact exists: design.md
  < ✅ PASS: Required artifact exists: uservalidation.md
  > ℹ️  INFO: Bug packet: MUTATION-X forced compact
  > ✅ PASS: Required artifact exists: bug.md
  > ✅ PASS: Required artifact exists: report.md
```

**This is a NEGATIVE result and it is reported as measured, not narrated away.**
Deliberately mis-resolving the form does NOT cost a full packet its scope
analysis and does NOT move its verdict. The verdict holds because every artifact
BUG-037 needs is present under either set, so narrowing the required list removes
no failure. The scope analysis holds because enrolment is gated on `scopes.md`
**existing on disk**, not on form resolution succeeding:

```
if [[ "$bug_packet_requires_scopes_md" == true ]] || [[ -f "$feature_dir/scopes.md" ]]; then
```

That `||` clause is the no-regression guarantee, in one line.

**Mutation Y — X, plus removing that fallback.** X alone cannot distinguish "the
branch is safe" from "the branch is inert", so Y was required.

```
$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-037-uservalidation-opt-out-acceptance
MUTY_37_EXIT=1
🔴 TRANSITION BLOCKED: 18 failure(s), 2 warning(s)     <- was 38 / 4
lines=359 (baseline 579)   "Scope" lines 11 (baseline 14)

Lost, and DANGEROUSLY so — a BLOCK becomes a false PASS:
  baseline: 🔴 BLOCK: Resolved scope artifacts report 3 Done scope(s) but
                     state.json completedScopes is EMPTY
  mut-Y   : ✅ PASS: completedScopes count matches artifact Done scope count (0)
Also lost, all three:
  🔴 BLOCK: Scope is missing DoD item for scenario-specific regression E2E coverage
  🔴 BLOCK: Scope is missing DoD item for broader E2E regression suite coverage
  🔴 BLOCK: Scope Test Plan is missing explicit scenario-specific regression E2E row(s)
```

The branch is **not inert**. Removing the fallback silently drops 20 failures
and manufactures a false PASS on a full packet. X and Y together establish the
claim properly: the form branch is live, and the fallback is exactly what
prevents it from harming full packets.

**Restoration, measured behaviourally as well as by hash.**

```
$ shasum -a 256 bubbles/scripts/state-transition-guard.sh
7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3
$ grep -c MUTATION bubbles/scripts/state-transition-guard.sh
0
$ bash -n bubbles/scripts/state-transition-guard.sh
SYNTAX=0

$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-037-uservalidation-opt-out-acceptance
RESTORED_37_EXIT=1
🔴 TRANSITION BLOCKED: 38 failure(s), 4 warning(s)   lines=579   "Scope"=14
$ diff <(grep -v Timestamp baseline) <(grep -v Timestamp restored)
IDENTICAL_TO_BASELINE_EXIT=0        <- empty diff

$ bash bubbles/scripts/state-transition-guard.sh \
    bugs/BUG-038-progress-timeout-bsd-wc-padding
RESTORED_38_EXIT=1
🔴 TRANSITION BLOCKED: 17 failure(s), 3 warning(s)   lines=333
```

Byte-identical AND behaviourally identical, on both packet forms. Every mutation
was reverted by editing the file, never by a `git` command that discards changes.

**Claim Source:** executed.

### E-K4 — F-041-04: the guard's form-awareness had NO owning coverage

Asked whether the new committed coverage pins the guard too, the answer measured
**no**:

```
$ grep -c "bug-packet-resolve" bubbles/scripts/state-transition-guard-selftest.sh
0
$ grep -c "bug_packet_form"   bubbles/scripts/state-transition-guard-selftest.sh
0
$ git show HEAD:bubbles/scripts/state-transition-guard-selftest.sh \
    | grep -c "bug-packet-resolve\|bug_packet_form"
0
```

That is the same "no owning coverage" gap that let the original defect survive:
`artifact-lint-selftest.sh` gained T18–T22 for the lint side, and the guard side
had nothing.

**Coverage added, in-boundary, and proven non-vacuous.**
`bug-packet-resolve-selftest.sh` is inside `workBoundary.allowedPaths` and runs
in seconds, so it was widened with `P6`. `P5` asserts `readers >= 1`, which stays
green while **either** consumer regresses — and one surviving reader is precisely
the two-surface disagreement this design exists to end.

```
$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
  ok   P5 2 non-selftest surface(s) call bug-packet-resolve.sh
  ok   P6 artifact-lint.sh reads the artifact set through bug-packet-resolve.sh
  ok   P6 state-transition-guard.sh reads the artifact set through bug-packet-resolve.sh
bug-packet-resolve-selftest: 12 check(s), 0 failure(s)
BPR2_EXIT=0

MUTATION — the guard's resolver reference renamed away:
$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
  ok   P5 1 non-selftest surface(s) call bug-packet-resolve.sh    <- STILL GREEN
  FAIL P6 state-transition-guard.sh reads bug-packet-resolve.sh   <- RED
bug-packet-resolve-selftest: 12 check(s), 1 failure(s)
MUT_BPR_EXIT=1

REVERTED by edit:
$ shasum -a 256 bubbles/scripts/state-transition-guard.sh
7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3
$ grep -c MUTAT bubbles/scripts/state-transition-guard.sh
0
$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
bug-packet-resolve-selftest: 12 check(s), 0 failure(s)   BPR4_EXIT=0

$ shellcheck -x bubbles/scripts/bug-packet-resolve-selftest.sh
SC_SELFTEST_EXIT=0   (clean; the file is untracked/new in this packet)
```

P5 green + P6 red under the same mutation is the whole justification for P6, and
it is a measurement rather than an argument.

**The gap is NARROWED, not closed.** `P6` pins the **wiring**; it does not pin
the **behaviour**. Mutation Z above removed both compact-aware elements while
leaving the resolver reference intact, so `P6` would have stayed green through
the full reintroduction of the original defect. The behavioural pin belongs in
`state-transition-guard-selftest.sh`, which is out of boundary and which this
session was forbidden to run (25+ minutes, likely to be killed). Adding an
assertion there would have been out-of-boundary *and* unexecutable, so its
non-vacuity could not have been proven — it was therefore not added. Recorded as
open finding **F-041-04**.

**Claim Source:** executed.

#### F-041-04 UPDATE (later session) — CLOSED, at a different site

The behavioural pin now exists. It is NOT in
`state-transition-guard-selftest.sh`, as this finding predicted, but in
`bubbles/scripts/compact-obligation-basis-selftest.sh` — created by BUG-042,
16 checks, auto-discovered by `framework-validate`'s `*-selftest.sh` glob, and
bounded to a few guard invocations rather than the 25+ minute suite.

Mutation B (both F-041-02 elements reverted — the `[[ -f "$scope_path" ]]`
read guard AND the conditional `scopes.md` enrolment, BUG-042's obligation
machinery deliberately left intact so the experiment isolates F-041-02):

```
compact-obligation-basis-selftest: 16 check(s), 10 failure(s)   MUTB_EXIT=1
  FAIL B4  the obligation basis is selected
       the guard never reported it; every assertion below would be vacuous
  FAIL B8  scopeless form cannot claim completed scopes
  (+ B1, B2, B2b, B3, B5, B9, B10, B11)
```

Baseline and post-revert are both `16 check(s), 0 failure(s)`, exit 0, with the
guard byte-identical at
`dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783`.

Three honest qualifications, so this closure is not overread:

1. **B1b is NOT load-bearing.** It stayed GREEN under mutation B. It is a
   negative assertion (a refusal string must be ABSENT) and a dead guard emits
   no strings, so it passes vacuously. B4 and B8 carry the behavioural claim.
2. **One element alone does not reproduce.** Mutation A (read guard removed,
   enrolment left compact-aware) was `16 check(s), 0 failure(s)`, exit 0. Both
   elements are required to reintroduce the defect, confirming the earlier
   session's measurement.
3. **The predicted site is still empty.** A reader auditing
   `state-transition-guard-selftest.sh` for this behaviour finds nothing:
   `grep -cE "bug_packet_form|bug-packet|packet form|obligation"` returns `0`.
   The word `compact` appears there 19 times in an unrelated sense (the compact
   JSON-array shape of `completedScopes`). Anyone tracing F-041-02's coverage
   from the guard's own selftest will come up empty and must be pointed here.

Coverage and fix are in identical commit state — `F-041-02` markers are `0` in
`HEAD` and `4` in the working tree — so they land together rather than the test
trailing the behaviour.

**Claim Source:** executed.

### E-K5 — shellcheck, attributed against HEAD before claiming anything

```
$ shellcheck -x bubbles/scripts/state-transition-guard.sh
SC_WORK_EXIT=1
work: 10 SC1091  3 SC2001  4 SC2015  5 SC2016  3 SC2126  1 SC2129  18 SC2295  4 SC2329

$ git show HEAD:bubbles/scripts/state-transition-guard.sh | shellcheck -s bash -
SC_HEAD_EXIT=1
head: 10 SC1091  3 SC2001  4 SC2015  5 SC2016  3 SC2126  1 SC2129  18 SC2295  4 SC2329
```

Identical code-and-count profile on both sides. **Zero** new shellcheck findings
are attributable to this change; all 48 pre-exist at HEAD.

**Claim Source:** executed.

### E-K6 — DoD goes 10/13 → 9/13, and why a count went DOWN

Item **11** ("Scenario-specific E2E regression tests for EVERY new/changed/fixed
behavior") was CHECKED by a previous session on a stated, mechanical premise:

```
      state-transition-guard.sh is NOT in this list, verified rather than
      assumed. F-041-02 is deferred per design.md 3.5.1, and the fourth site
      never landed, so this packet changed no behaviour there:
        $ grep -c "bug-packet-resolve\|bug_packet_form" \
            bubbles/scripts/state-transition-guard.sh
        0
```

That premise is now false — the same grep returns 26 — because the fourth site
was subsequently repaired. New behaviour exists in the guard, so it enters the
scope of item 11's "EVERY", and its coverage is partial (`P6` pins wiring, not
behaviour). The item is therefore **un-checked**, its original evidence preserved
verbatim, with an amendment recording the falsification.

This is a decrease, and it is reported as one. A DoD item describes the state of
the packet now, not the moment it was ticked; leaving `[x]` above evidence this
session proved false would be exactly the fabrication the policy forbids.

| Item | State | Reason |
| --- | --- | --- |
| 10 — All existing tests pass | `[ ]` | `framework-validate` remains forbidden; unchanged |
| 11 — Regression tests for EVERY changed behaviour | `[ ]` | **un-checked this session**; premise falsified, guard coverage partial |
| 12 — Broader E2E regression suite | `[ ]` | `release-check` remains forbidden; unchanged |
| 13 — Bug marked Fixed | `[ ]` | asserts a completeness strictly stronger than 10/11/12 support |

Item 13's blocker list was refreshed: `F-041-01` and `F-041-02` are struck as
CLOSED, `F-041-03` and `F-041-04` added, and the superseded `line 582` death
under it replaced with the current measurement. No item was checked.

```
$ grep -c "^- \[x\]" scopes.md   -> 9
$ grep -c "^- \[ \]" scopes.md   -> 4
$ bash bubbles/scripts/artifact-lint.sh \
    bugs/BUG-041-artifact-lint-ignores-compact-packet-form
Artifact lint PASSED.
LINT_EXIT=0
```

**Claim Source:** executed.

### E-K7 — ownership deviation, declared

`design.md` is owned by `bubbles.design`, and the previous session correctly
ROUTED the §3.5.1 correction rather than applying it. This session was directed
by the operator to apply it directly, and did: §3.5.2 records `F-041-02` as
RESOLVED and §3.6.1 records `P6`. The §3.5.1 deferral text is preserved verbatim
and nothing was deleted. The deviation is declared here rather than left
implicit, so the ownership record stays honest.

**Claim Source:** executed.

### E-K8 — what this session did not do

- `framework-validate`, `release-check`, `state-transition-guard-selftest.sh`:
  not run, forbidden to this session. DoD 10 and 12 therefore stay unevidenced.
- `status` NOT set to `done`; no terminal `certification.status` written.
- `bugs/BUG-032-`, `BUG-033-`, `BUG-037-`, `BUG-038-`, `BUG-039-`: not edited.
  BUG-037 and BUG-038 were read and had the guard run against them read-only,
  with before/after hashes proving no mutation.
- No existing guard check weakened. Every guard edit made in this session was a
  mutation that was subsequently reverted to a byte-identical file.
- No `git` command that discards changes was run. All reverts were edits.

**Claim Source:** executed.

---

## Session — release-manifest registration of the resolver

**Phase:** implement

### E-L1 — the defect

`bug-packet-resolve.sh` and `bug-packet-resolve-selftest.sh` existed on disk but
were UNTRACKED, and `bubbles/scripts/trust-metadata.sh::bubbles_manifest_entry_is_tracked()`
uses git tracking as the ONLY admission test for the release manifest. Both files
were therefore absent from `bubbles/release-manifest.json`, which is the exact set
`install.sh` copies downstream. A consuming repository received the
`artifact-lint.sh` and `state-transition-guard.sh` that call the resolver, but not
the resolver, so the downstream lint aborted with:

```
ERROR: bug-packet-resolve.sh is missing next to artifact-lint.sh
```

The precedent is `report-sections-resolve.sh`, a manifest entry since it was
introduced (`bubbles/release-manifest.json:369`).

### E-L2 — the fix, and why it is a `git add` and not a manifest edit

The manifest is generated, not hand-maintained. Both files were staged so the
generator's tracking test admits them, then the manifest was regenerated:

```
$ git add -- bubbles/scripts/bug-packet-resolve.sh bubbles/scripts/bug-packet-resolve-selftest.sh
$ bash bubbles/scripts/generate-release-manifest.sh
Updated release manifest: 7.28.0 (930 managed files)
gen=0
$ bash bubbles/scripts/generate-release-manifest.sh --check
Release manifest is current: 7.28.0 (930 managed files)
check=0
```

`managedFileCount` moved 927 → 930 (the two files above plus BUG-042's
`compact-obligation-basis-selftest.sh`). No sha256 was hand-written.

### E-L3 — downstream install proof

Installed into a throwaway git repo from this checkout and ran the resolver's
selftest from the INSTALLED copy, not the source copy:

```
$ bash /Users/pkirsanov/Projects/bubbles/install.sh --local-source /Users/pkirsanov/Projects/bubbles
install=0
$ ls -l .github/bubbles/scripts/bug-packet-resolve.sh
-rwxr-xr-x  1 pkirsanov  wheel  11155 .github/bubbles/scripts/bug-packet-resolve.sh
$ bash .github/bubbles/scripts/bug-packet-resolve-selftest.sh
  ok   P5 2 non-selftest surface(s) call bug-packet-resolve.sh
  ok   P6 artifact-lint.sh reads the artifact set through bug-packet-resolve.sh
  ok   P6 state-transition-guard.sh reads the artifact set through bug-packet-resolve.sh
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)
exit=0
```

### E-L4 — source-repo re-verification

```
$ bash bubbles/scripts/bug-packet-resolve-selftest.sh
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)   bpr=0
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-041-artifact-lint-ignores-compact-packet-form
Artifact lint PASSED.                                    al41=0
```

`framework-validate` and `release-check` were NOT run in this session (forbidden;
~2h each), so DoD items depending on them remain unevidenced.

**Claim Source:** executed.


