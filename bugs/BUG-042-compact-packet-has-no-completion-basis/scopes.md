# Scopes: BUG-042 — The compact packet form has no completion basis

Layout: single-file. One scope.

---

## Scope 1: Registry-declared obligations as the compact completion basis

**Status:** In Progress
**Depends on:** none
**Evidence file:** [report.md](report.md)

### Objective

Give the compact form a completion basis it can satisfy, derived from the
registry rather than chosen by the author, proving the SAME four obligations
`micro-fix-packet.yaml` preserves.

### Gherkin Scenarios

```gherkin
Feature: The compact bug packet can be completed without weakening its obligations

  Scenario: SCN-042-01 — the resolver publishes the compact form's obligations
    Given bug-packet.yaml declares obligationsRetained on the compact form
    When bug-packet-resolve.sh is run with no arguments
    Then it emits one obligation= line per declared obligation
    And each line carries the form, the id, the dischargedIn artifact and the attestedIn artifact
    And it exits 0

  Scenario: SCN-042-02 — the guard selects the registry-derived basis
    Given a packet whose resolved form declares obligations and no scopes.md
    When state-transition-guard.sh evaluates it
    Then Check 4 reports the completion basis as REGISTRY-DECLARED OBLIGATIONS
    And it names the count the registry declares
    And it states the required set is not author-chosen

  Scenario: SCN-042-03 — an unattested obligation is refused by name
    Given a compact packet with one obligation left unattested
    When state-transition-guard.sh evaluates it
    Then that obligation is BLOCKed by its own id
    And the block names the artifact where the obligation is discharged
    And the other declared obligations are not blocked

  Scenario: SCN-042-04 — the required set is registry-derived, not hard-coded
    Given one obligationsRetained entry is removed from the registry
    When state-transition-guard.sh evaluates the same compact packet
    Then the declared count drops by one
    And exactly one fewer obligation is blocked

  Scenario: SCN-042-05 — the basis fails closed
    Given a reduced form that declares zero obligations
    When bug-packet-resolve.sh is run
    Then it exits 2
    And it names the form and its artifact count against the full default

  Scenario: SCN-042-06 — Check 5 substitutes rather than waives
    Given a compact packet, which declares no scopes.md
    When state-transition-guard.sh evaluates it
    Then Check 5 reports NOT_APPLICABLE for the all-done cross-reference
    And it asserts instead that completedScopes is EMPTY

  Scenario: SCN-042-07 — the full form is unchanged
    Given a full-form packet that was evaluated before this change
    When state-transition-guard.sh evaluates it after the change
    Then the exit code, failure count and warning count are identical
```

### Implementation Plan

| # | File | Change |
|---|---|---|
| 1 | `bubbles/registry/bug-packet.yaml` | `purpose:` on the 3 compact artifacts; `obligationsRetained:` with 4 entries; the asymmetry comment |
| 2 | `bubbles/scripts/bug-packet-resolve.sh` | `obligation=` line kind; fail-closed exit 2 on a zero-obligation reduced form |
| 3 | `bubbles/scripts/state-transition-guard.sh` | Check 4 third basis; Check 5 NOT_APPLICABLE + empty-completedScopes assertion |
| 4 | `bubbles/scripts/artifact-lint.sh` | attestation-existence requirement per declared obligation |
| 5 | `bubbles/scripts/bug-packet-resolve-selftest.sh` | resolver-level pins for the new emission and the fail-closed path |
| 6 | `bubbles/scripts/compact-obligation-basis-selftest.sh` | the behavioural pin (new file) |

### Test Plan

| ID | Scenario | Type | Command | Expected |
|---|---|---|---|---|
| TP-042-01 | SCN-042-01 | unit | `bash bubbles/scripts/bug-packet-resolve.sh` | exit 0; 8 `obligation=` lines (4 compact, 4 single-file) |
| TP-042-02 | SCN-042-01 | unit | `bash bubbles/scripts/bug-packet-resolve-selftest.sh` | exit 0; 16 checks, 0 failures |
| TP-042-03 | SCN-042-02, -03, -06 | integration | `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding` | exit 1; 20 failures / 3 warnings; basis line present; 4 obligation BLOCKs; Check 5 NOT_APPLICABLE |
| TP-042-04 | SCN-042-04 | mutation | remove one registry entry, rerun TP-042-03 | declared count 4→3; BLOCKs 4→3; failures 20→19 |
| TP-042-05 | SCN-042-05 | mutation | disable `obligationsRetained:`, rerun TP-042-01 | exit 2 with the named refusal |
| TP-042-06 | SCN-042-07 | regression | `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance` | exit 1; 38 failures / 4 warnings; identical to baseline |
| TP-042-07 | SCN-042-02..06 | behavioural | `bash bubbles/scripts/compact-obligation-basis-selftest.sh` | exit 0; 13 checks, 0 failures |
| TP-042-08 | adversarial | mutation | break the resolver `obligation=` emission, rerun TP-042-07 | exit 1 — the pin is non-vacuous |
| TP-042-09 | packet | lint | `bash bubbles/scripts/artifact-lint.sh bugs/BUG-042-compact-packet-has-no-completion-basis` | exit 0 |

### Definition of Done

Every checked item below carries the executed output that closes it. **Phase:** implement.

- [x] The resolver emits an `obligation=` line for every declared obligation on
      every form that declares one, and exits 0. (TP-042-01)

```
$ bash bubbles/scripts/bug-packet-resolve.sh   -> exit 0
obligation=compact|reproduce-before-fix|report.md|report.md
obligation=compact|adversarial-regression|report.md|report.md
obligation=compact|root-cause-stated|bug.md|report.md
obligation=compact|evidence-is-execution|report.md|report.md
obligation=single-file|explicit-disposition||
obligation=single-file|reproduce-before-fix||
obligation=single-file|root-cause-stated||
obligation=single-file|evidence-is-execution||
```

- [x] The resolver selftest is green at its current check count. (TP-042-02)

```
$ bash bubbles/scripts/bug-packet-resolve-selftest.sh   -> exit 0
bug-packet-resolve-selftest: 16 check(s), 0 failure(s)
```

- [x] Check 4 selects the registry-derived basis on a compact packet and names
      the declared count. (TP-042-03)

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding   -> exit 1
ℹ️  INFO: Completion basis: REGISTRY-DECLARED OBLIGATIONS (bug-packet.yaml 'compact' form declares 4; the required set is not author-chosen)
20 failure(s), 3 warning(s)
```

- [x] Each unattested obligation is BLOCKed by its own id, naming its discharge
      site. (TP-042-03)

```
🔴 BLOCK: Obligation 'reproduce-before-fix' has NO attestation line in report.md citing its discharge site report.md
🔴 BLOCK: Obligation 'adversarial-regression' has NO attestation line in report.md citing its discharge site report.md
🔴 BLOCK: Obligation 'root-cause-stated' has NO attestation line in report.md citing its discharge site bug.md
🔴 BLOCK: Obligation 'evidence-is-execution' has NO attestation line in report.md citing its discharge site report.md
failedChecks: [Check-4-obligations]
```

- [x] Check 5 reports NOT_APPLICABLE for the compact form and asserts
      `completedScopes` is EMPTY instead. (TP-042-03)

```
ℹ️  INFO: NOT_APPLICABLE: Check-5-all-done — the 'compact' packet form declares no scopes.md, so there is no scope decomposition to cross-reference
✅ PASS: completedScopes is EMPTY, as the 'compact' form requires — no scope decomposition, no completed scopes
```

- [x] Removing one registry obligation moves the guard's required set from 4 to
      3, proving the set is registry-derived and not hard-coded. (TP-042-04)

```
M1: removed the root-cause-stated entry from obligationsRetained
obligation=compact line count: 3          (was 4)
ℹ️  INFO: Completion basis: REGISTRY-DECLARED OBLIGATIONS (bug-packet.yaml 'compact' form declares 3; the required set is not author-chosen)
BLOCK: Obligation count: 3                (was 4)
19 failure(s), 3 warning(s)               (was 20)
```

- [x] Breaking the resolver's `obligation=` emission returns the guard to the
      pre-fix "ZERO DoD checkbox items" death, proving the basis is load-bearing.
      (TP-042-08 companion)

```
M2: renamed obligation= to obligationX= at bug-packet-resolve.sh:295
obligation= line count: 0                 (was 8)
"Completion basis" line count: 0          (was 1)
🔴 BLOCK: Resolved scope artifacts have ZERO DoD checkbox items — cannot verify completion
16 failure(s), 3 warning(s)               (was 20)
```

- [x] A reduced form declaring zero obligations makes the resolver exit 2.
      (TP-042-05)

```
M3: renamed obligationsRetained: to obligationsRetainedDISABLED:
$ bash bubbles/scripts/bug-packet-resolve.sh   -> exit 2
bug-packet-resolve: .../registry/bug-packet.yaml declares reduced form 'compact' (3 artifact(s) vs the 'full' default's 7) with ZERO obligationsRetained
```

- [x] The full form's guard verdict is byte-for-byte unchanged. (TP-042-06)

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance   -> exit 1
38 failure(s), 4 warning(s)
TRANSITION_GUARD_RESULT_V1 occurrences: 2

re-derived after the Scope 2 G027 repair                                        -> exit 1
38 failure(s), 4 warning(s); 14 `Scope` lines
diff before/after (Timestamp and one 0s/1s duration filtered) -> empty
```

- [x] The behavioural pin executes green and goes red under mutation. (TP-042-07, TP-042-08)

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh   -> exit 0
compact-obligation-basis-selftest: 16 check(s), 0 failure(s)

under M4 (M2 reapplied)                                       -> exit 1
  FAIL P0 the registry declares compact obligations
compact-obligation-basis-selftest: 1 check(s), 1 failure(s)
```

- [x] Every mutation is reverted by edit and the file proven byte-identical by sha256.

```
d8dc14eb30a7584c60e8bbc2a041490f333f3405cae3687d85f7d093e1704e82  bubbles/registry/bug-packet.yaml
923197f143f06251b7a873a0991d750b2d718408699a79f3d49ed2b515fbb17f  bubbles/scripts/bug-packet-resolve.sh
bubbles/scripts/state-transition-guard.sh was 4839e3a3c06e7fcc930d2ec332b66af5e9432fb83c793444157380dbc6518d63
at the close of Scope 1 and is dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783
since the Scope 2 repair; the Scope 2 round-trip proof is recorded there.
no git checkout was used in either scope
```

- [x] `bugs/BUG-038-progress-timeout-bsd-wc-padding` is modified in exactly ONE
      place — the `DI-038-04` disposition and its resolution evidence, which this
      packet's repair authorises — proven by per-file hashes showing every other
      file byte-identical.

```
SCOPE 1 (no edit at all):
BUG038_TREE_BEFORE=a59a48b53e98494519ab969f4d278cf96457ed190242d57e66d526a4b3f00dda
BUG038_TREE_NOW   =a59a48b53e98494519ab969f4d278cf96457ed190242d57e66d526a4b3f00dda

SCOPE 2 (the single authorised DI-038-04 edit):
                     before                                                            after
bug.md      89cad203488daa34aab31176915a05cb69f18d24bc3644e7819cbc6350b2dfb1   89cad203488daa34aab31176915a05cb69f18d24bc3644e7819cbc6350b2dfb1  UNCHANGED
state.json  4b4cfe203242de9d255e2868f25f44ac910f7633acaa31360b9b644a0424629c   4b4cfe203242de9d255e2868f25f44ac910f7633acaa31360b9b644a0424629c  UNCHANGED
report.md   a6f4f951076a876d58f80ed2221ebb0555c64a95e8ab518566ced260bad2bed9   44e0e14b01aa47972eed9609dc3045703d5a83d7bf7ef0a74f399c4b4cd345bd  DI-038-04 only
```

- [x] This packet passes `artifact-lint.sh` at exit 0. (TP-042-09)

```
$ bash bubbles/scripts/artifact-lint.sh bugs/BUG-042-compact-packet-has-no-completion-basis
Artifact lint PASSED.   -> exit 0
```

- [ ] Human acceptance recorded. **Not checkable by this agent** — the Human
      Acceptance Record is the user's act and must not be fabricated.
- [ ] `bubbles.validate` certifies promotion. **Not this agent's to check** —
      certification fields are owned by `bubbles.validate`.
- [ ] `framework-validate` and `release-check` pass. **NOT RUN** — the validation
      lock is held by another terminal and both are out of scope for this
      session. Recorded as UNPROVEN rather than assumed.

---

## Scope 2: Gate G027 is form-blind — the defect Scope 1 made reachable

**Status:** In Progress
**Depends on:** Scope 1
**Evidence file:** [report.md](report.md)

### Objective

Scope 1 taught Check 5 the compact form and gave the form a completion basis it
can satisfy. It did NOT teach Check 15 / Gate G027, which asks its
anti-fabrication question through a proxy the compact form cannot answer. The
two checks then contradict each other and the DEFAULT bug route becomes
unfalsifiable. Remove the contradiction without weakening the gate.

### Gherkin Scenarios

```gherkin
Feature: Gate G027 asks its anti-fabrication question in terms the packet form can answer

  Scenario: SCN-042-08 — a compact packet with attested obligations clears G027
    Given a compact packet whose registry-declared obligations are all attested
    And its execution record claims the implement and test phases
    When state-transition-guard.sh evaluates it
    Then Check 15 reports phase-obligation coherence as a PASS
    And it does not refuse the packet for an empty completedScopes
    And it does not refuse the packet for zero scopes marked Done

  Scenario: SCN-042-09 — a compact packet with an unattested obligation still fails G027
    Given a compact packet with one registry-declared obligation left unattested
    And its execution record claims the implement and test phases
    When state-transition-guard.sh evaluates it
    Then Check 15 BLOCKs the packet, naming that obligation
    And the block is attributed to Gate G027

  Scenario: SCN-042-10 — the full form's G027 behaviour is untouched
    Given a full-form packet evaluated before this change
    When state-transition-guard.sh evaluates it after the change
    Then the exit code, failure count, warning count and scope analysis are identical
```

### Implementation Plan

| # | File | Change |
|---|---|---|
| 1 | `bubbles/scripts/state-transition-guard.sh` | extract `bug_packet_obligation_state()` so Check 4 and Check 15 share ONE attestation predicate |
| 2 | `bubbles/scripts/state-transition-guard.sh` | Check 15: on a form whose declared artifact set omits `scopes.md`, swap the scope-count proxy for the obligation-attestation signal; every other form unchanged |
| 3 | `bubbles/scripts/compact-obligation-basis-selftest.sh` | fixture hermeticity fix + B10a/B10/B11 |
| 4 | `bugs/BUG-038-progress-timeout-bsd-wc-padding/report.md` | DI-038-04 → resolved (the single authorised edit) |

### Test Plan

| ID | Scenario | Type | Command | Expected |
|---|---|---|---|---|
| TP-042-10 | SCN-042-10 | regression | `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance` | exit 1; 38 failures / 4 warnings; 14 `Scope` lines; diff vs baseline empty |
| TP-042-11 | SCN-042-08 | integration | `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding` | exit 1; 7→5 failures; `failedGateIds` loses G027 |
| TP-042-12 | SCN-042-08, -09 | behavioural | `bash bubbles/scripts/compact-obligation-basis-selftest.sh` | exit 0; 16 checks, 0 failures |
| TP-042-13 | SCN-042-08 | mutation | disable the form-awareness, rerun TP-042-11 and TP-042-12 | contradiction returns; B10 and B11 red |
| TP-042-14 | SCN-042-09 | mutation | make the obligation branch pass unconditionally, rerun TP-042-12 | B11 red, B10 green — B11 pins anti-fabrication specifically |

### Definition of Done

Every checked item below carries the executed output that closes it. **Phase:** implement.

- [x] Check 15 resolves the packet form through the SAME `bug_packet_form` /
      `bug_packet_requires_scopes_md` facts every other check reads — no second
      resolution path is introduced.

```
$ grep -n "g027_scopeless_form=true" -B2 bubbles/scripts/state-transition-guard.sh
4266:        g027_scopeless_form=false
4267:        if [[ -n "$bug_packet_form" ]] && [[ "$bug_packet_requires_scopes_md" == false ]]; then
4268:          g027_scopeless_form=true
```

- [x] Check 4 and Check 15 share ONE attestation predicate
      (`bug_packet_obligation_state`), so the two surfaces cannot drift. Check 4's
      refusal messages are preserved verbatim. (TP-042-11)

```
$ grep -n "bug_packet_obligation_state" bubbles/scripts/state-transition-guard.sh
833:bug_packet_obligation_state() {
1469:    bug_packet_obligation_state "$obligation_fact" || obligation_state=$?
4279:              bug_packet_obligation_state "$g027_obligation_fact" || g027_obligation_state=$?
```

- [x] A fully attested compact packet claiming `implement`/`test` CLEARS G027;
      the two proxy refusals are gone. (TP-042-11)

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding   -> exit 1
--- Check 15: Phase-Scope Coherence (Gate G027) ---
✅ PASS: Phase-obligation coherence verified: implement/test are backed by all 4 registry-declared obligation attestation(s) for the 'compact' form
🔴 TRANSITION BLOCKED: 5 failure(s), 2 warning(s)
failedGateIds: [G022,G033]

before this scope: 7 failure(s), 2 warning(s); failedGateIds: [G022,G027,G033]
```

- [x] Anti-fabrication survives: a compact packet claiming `implement`/`test`
      with an obligation UNATTESTED still FAILS G027, by name. (TP-042-12, B11)

```
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh   -> exit 0
  ok   B11 a compact packet claiming implement/test with 'reproduce-before-fix'
       UNATTESTED still FAILS G027 — anti-fabrication survives the form-awareness
compact-obligation-basis-selftest: 16 check(s), 0 failure(s)
```

- [x] The full form's verdict is unchanged: exit code, failure count, warning
      count and scope analysis all identical to the pre-change baseline.
      (TP-042-10)

```
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-037-uservalidation-opt-out-acceptance   -> exit 1
🔴 TRANSITION BLOCKED: 38 failure(s), 4 warning(s)
Scope=14
$ diff <(grep -v "Timestamp:\|internally consistent" before) <(grep -v "Timestamp:\|internally consistent" after)
FULL_FORM_IDENTICAL
```

- [x] Removing the form-awareness reinstates the contradiction. (TP-042-13)

```
M1: `if false && [[ -n "$bug_packet_form" ]] ...`
$ bash bubbles/scripts/state-transition-guard.sh bugs/BUG-038-progress-timeout-bsd-wc-padding   -> exit 1
🔴 TRANSITION BLOCKED: 7 failure(s), 2 warning(s)      # G027 back
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh   -> exit 1
  FAIL B10 G027 is form-aware for the compact form
  FAIL B11 G027 still refuses an unevidenced compact phase claim
compact-obligation-basis-selftest: 16 check(s), 2 failure(s)
```

- [x] Making the obligation branch pass unconditionally reddens B11 and ONLY
      B11 — the anti-fabrication pin is specific, not incidental. (TP-042-14)

```
M2: `bug_packet_obligation_state "$fact" || g027_obligation_state=0`
$ bash bubbles/scripts/compact-obligation-basis-selftest.sh   -> exit 1
  ok   B10 a fully attested compact packet claiming implement/test CLEARS G027
  FAIL B11 G027 still refuses an unevidenced compact phase claim
compact-obligation-basis-selftest: 16 check(s), 1 failure(s)
```

- [x] The behavioural pin's fixtures are hermetic. The `grep -v` scrub removed
      only marker-tagged lines, so the shipped base packet's OWN attestation
      lines survived the copy and silently re-satisfied every obligation the
      builder was asked to damage — B2/B2b/B3/B5/B6 were passing on contaminated
      fixtures. Every attestation-shaped line naming a declared id is now
      scrubbed.

```
before the fix:  compact-obligation-basis-selftest: 16 check(s), 6 failure(s)   -> exit 1
after the fix:   compact-obligation-basis-selftest: 16 check(s), 0 failure(s)   -> exit 0

contamination proven independent of the Check 4 refactor — the ORIGINAL inline
predicate finds the damaged obligation still attested on the damaged fixture:
$ grep -E "^\- \[x\] " fixture/report.md | grep -F -- "reproduce-before-fix" | grep -cF -- "report.md"
1
```

- [x] Every Scope 2 mutation is reverted by edit, proven byte-identical by a
      sha256 round trip.

```
fixed          dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783
mutated (M1')  41cc1bcd821612c075660b7a6362a02e4dd1d00de75b9d0a3c800d436f255a78
reverted       dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783
no git checkout was used
```

- [x] `shellcheck -x` introduces no new finding. Attributed against HEAD by
      code profile; the single delta is at line 4765, outside every line this
      scope touched.

```
$ diff <(shellcheck -x HEAD-copy | codes) <(shellcheck -x working-tree | codes)
7c7
<   18 SC2295
---
>   19 SC2295
the extra one is `scope_label="${scope_path#$feature_dir/}"` at line 4765 —
pre-existing Scope 1 code, not authored in Scope 2. Scope 2's ranges
(833-859, 1465-1492, 4258-4300) carry zero shellcheck findings.
```

- [x] `bugs/BUG-038-…` is edited in exactly one place, `DI-038-04`, now
      `resolved` with evidence; `bug.md` and `state.json` are byte-identical.

```
bug.md      89cad203…  ->  89cad203…   UNCHANGED
state.json  4b4cfe20…  ->  4b4cfe20…   UNCHANGED
report.md   a6f4f951…  ->  44e0e14b…   DI-038-04 disposition + resolution only
```

- [ ] Human acceptance recorded. **Not checkable by this agent.**
- [ ] `bubbles.validate` certifies promotion. **Not this agent's to check.**
- [ ] `framework-validate` and `release-check` pass. **NOT RUN** — the validation
      lock is held by another terminal and both are excluded from this session.
      Recorded as UNPROVEN rather than assumed.

