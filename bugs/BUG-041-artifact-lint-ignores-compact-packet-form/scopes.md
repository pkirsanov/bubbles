# Scopes: BUG-041 — packet-form-aware artifact resolution

## Scope 1: Registry-driven artifact resolution with fail-closed form detection

**Status:** [~] In progress — implementation landed and measured, 8 of 13 DoD
items evidenced. Two findings are open against the fix (F-041-01, F-041-02) and
four items have no evidence because `framework-validate` was forbidden to the
implementation session.

**Owner:** `bubbles.implement`

**Blocked until:** `state-transition-guard-selftest.sh` and `framework-validate`
are idle. Both enforcement surfaces are read by the suite that was executing
during this packet's investigation.

### Gherkin Scenarios (Regression Tests)

```gherkin
Feature: Artifact requirements follow the declared packet form

  Scenario: An admitted compact packet passes the artifact check
    Given a bug packet whose state.json declares the compact form
    And the packet carries bug.md, report.md and state.json
    And every admission condition in bug.md is answered admissibly
    When artifact-lint runs against the packet
    Then no missing-artifact failure is reported

  Scenario: A packet with no form declaration is linted as full
    Given a bug packet whose state.json carries no form declaration
    And the packet is missing design.md
    When artifact-lint runs against the packet
    Then a missing-artifact failure names design.md

  Scenario: Declaring the compact form does not bypass admission
    Given a bug packet whose state.json declares the compact form
    And bug.md answers no-payment-surface inadmissibly
    When artifact-lint runs against the packet
    Then the full artifact set is required
    And a missing-artifact failure is reported

  Scenario: An unreadable registry refuses rather than degrades
    Given bug-packet.yaml is absent
    When artifact-lint runs against any packet
    Then it exits non-zero and names the registry
    And it reports no artifact check as passed

  Scenario: A form declaring zero artifacts is refused
    Given bug-packet.yaml declares the compact form with an empty artifact list
    When the resolver runs
    Then it exits non-zero and prints nothing
```

### Implementation Plan

1. Write `bubbles/scripts/bug-packet-resolve.sh` as the sole reader of
   `bubbles/registry/bug-packet.yaml`, modelled on `report-sections-resolve.sh`.
2. Add the `declaration:` block to `bubbles/registry/bug-packet.yaml`.
3. Add `--resolve-form` to `bubbles/scripts/micro-fix-admission.sh` as a
   side-effect-free single-line verdict channel.
4. Capture the current lint verdict for all seven bug packets. This is the M6
   baseline and must be taken BEFORE any edit.
5. Replace the literal artifact checks in `bubbles/scripts/artifact-lint.sh`
   at lines 401-406, 447 and 453 with resolver-driven requirements.
6. Replace the identical literal checks in
   `bubbles/scripts/state-transition-guard.sh` at lines 759, 799 and 805.
7. Write `bubbles/scripts/bug-packet-resolve-selftest.sh`.
8. Add the non-selftest-reader assertion to
   `bubbles/scripts/bug-packet-selftest.sh`.
9. Extend `bubbles/scripts/micro-fix-admission-selftest.sh` for `--resolve-form`.
10. Run the six mutations in `design.md` §5 and record each exit code.

### Test Plan

| Test type | What it covers | Mechanism |
|---|---|---|
| Functional | Resolver output shape for all three forms | `bug-packet-resolve-selftest.sh` |
| Functional | `--resolve-form` verdict for admitted and escalated packets | `micro-fix-admission-selftest.sh` |
| Regression E2E | All seven bug packets, verdict diffed before and after | captured lint output |
| Adversarial regression | M2 forged compact declaration that fails admission | synthetic fixture |
| Adversarial regression | M1 full packet missing design.md, no declaration | synthetic fixture |
| Negative control | M3 absent registry, M4 empty artifact set | synthetic fixture |
| Integration | `state-transition-guard.sh` agrees with `artifact-lint.sh` | both surfaces on one packet |

### Definition of Done — 3-Part Validation

- [x] Root cause confirmed and documented
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      $ bash /tmp/bug041-head-tree/bubbles/scripts/artifact-lint.sh \
          /tmp/bug041-m5/BUG-038-progress-timeout-bsd-wc-padding
      HEAD_EXIT=1
      ❌ Missing required artifact: .../spec.md
      ❌ Missing required artifact: .../design.md
      ❌ Missing required artifact: .../uservalidation.md
      ❌ Missing required artifact: .../scopes.md

      The HEAD linter applies the full-form literal list to a packet whose
      declared form is compact. That is the root cause restated as a
      measurement: a constant where the contract is a function of packet form.
      ```
- [x] `bug-packet-resolve.sh` exists and is the only production reader
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      $ ls -l bubbles/scripts/bug-packet-resolve.sh
      -rw-r--r--@ 1 pkirsanov  staff  7863 Aug 25 06:59 bubbles/scripts/bug-packet-resolve.sh

      $ bash bubbles/scripts/bug-packet-resolve-selftest.sh
        ok   P5 1 non-selftest surface(s) call bug-packet-resolve.sh
      bug-packet-resolve-selftest: 10 check(s), 0 failure(s)
      RESOLVE_SELFTEST_EXIT=0

      $ bash bubbles/scripts/bug-packet-selftest.sh
        ok   A5 1 non-selftest surface(s) consume the bug-artifact contract
      bug-packet-selftest: 9 check(s), 0 failure(s)
      BUG_PACKET_SELFTEST_EXIT=0

      Exactly one non-selftest surface, counted by the selftests themselves.
      ```
- [x] Pre-fix regression test FAILS
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      $ bash /tmp/bug041-head-tree/bubbles/scripts/artifact-lint.sh \
          /tmp/bug041-m5/BUG-038-progress-timeout-bsd-wc-padding
      HEAD_EXIT=1
      HEAD_ISSUES=6

      RED. The pre-fix linter, extracted read-only from HEAD via
      `git archive`, fails the admitted compact packet with 6 issues, 4 of
      them the missing-artifact issues this fix targets.
      ```
- [x] Adversarial regression case exists and would fail if the bug returned
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      $ bash bubbles/scripts/artifact-lint.sh /tmp/bug041-m2/BUG-902-m2-forged-compact
      M2_EXIT=1
      ℹ️  Bug packet form: compact (state.json .packet="compact")
      ❌ state.json declares the 'compact' packet but micro-fix admission
         resolves 'full'; the 'full' artifact set is required
      ❌ Missing required artifact: .../design.md
      ❌ Missing required artifact: .../uservalidation.md
      ❌ Missing required artifact: .../scopes.md

      $ bash bubbles/scripts/bug-packet-resolve-selftest.sh
        ok   A1 a form declaring zero artifacts is refused (exit 2)
        ok   A2 an absent registry exits non-zero and emits no facts (exit 2)
        ok   A3 the absent-default is 'full', so silence cannot reduce a requirement
        ok   A4 every bypass-shaped flag is rejected as a usage error
      RESOLVE_SELFTEST_EXIT=0

      If `.packet` ever became an override, M2 would pass and A3 would fail.
      A1-A4 are committed and survive the session; M2 is a /tmp fixture and
      does not. See DoD item 11, left unchecked for that reason.
      ```
- [x] Post-fix regression test PASSES
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      $ bash bubbles/scripts/artifact-lint.sh \
          bugs/BUG-038-progress-timeout-bsd-wc-padding
      exit=0

      $ bash bubbles/scripts/artifact-lint.sh \
          /tmp/bug041-m5/BUG-038-progress-timeout-bsd-wc-padding
      WORK_EXIT=1  WORK_ISSUES=2
      ❌ report.md missing required section matching: ... Completion Statement
      ❌ report.md missing required section matching: ... Test Evidence

      GREEN. On the live packet the compact form now lints clean. On the
      reconstructed pre-condition all 4 missing-artifact issues clear and only
      the 2 report-section issues remain, which is the designed result.
      ```
- [x] M1 through M6 each recorded with a real exit code
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      M1 undeclared full, design.md removed      M1_EXIT=1  names design.md
      M2 forged compact failing admission        M2_EXIT=1  applies full set
      M3 registry absent (copied tree)           M3_EXIT=2  names the registry
      M4 compact declares zero artifacts         M4_EXIT=2  stdout 0 lines
      M5 BUG-038 pre-condition reconstructed     HEAD_EXIT=1/6 -> WORK_EXIT=1/2
      M6 all 8 packets, HEAD linter vs working   see the next DoD item

      Six mutations, six real exit codes. M6's PREDICTION failed; the
      mutation itself ran and is recorded. That is why the next item is
      unchecked rather than this one.
      ```
- [x] M6 shows unchanged verdicts for every undeclared packet, with output differing only by the corrected required-artifact set
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence from THIS session's re-measurement (inline, no references/summaries):
      ```
      $ git status --porcelain -- bubbles/scripts/artifact-lint.sh \
          bubbles/registry/bug-packet.yaml bubbles/scripts/bug-packet-resolve.sh
       M bubbles/registry/bug-packet.yaml
       M bubbles/scripts/artifact-lint.sh
      ?? bubbles/scripts/bug-packet-resolve.sh
      $ git log --oneline -1
      ce2c5ed (HEAD -> main) chore(manifest): refresh after final integration

      HEAD is therefore a valid pre-fix baseline. Reconstructed non-destructively,
      working tree untouched:
      $ git archive HEAD bubbles | tar -x -C /tmp/al41head

      Population, read from state.json (not from a .packet file):
        BUG-032 packet=[]                    undeclared -> in population
        BUG-033 packet=[]                    undeclared -> in population
        BUG-035 packet=[]                    undeclared -> in population
        BUG-036 packet=[]                    undeclared -> in population
        BUG-037 packet=[]                    undeclared -> in population
        BUG-039 packet=[]                    undeclared -> in population
        BUG-038 packet=["packet": "micro"]   DECLARED   -> outside population
        BUG-041 packet=["packet": "full"]    DECLARED   -> outside population

      Both linters run against the SAME working-tree packet, same absolute path,
      so the linter is the only variable:
      BUG-032-planning-maturity-guard-false-positives                     head=0 work=0 difflines=5
      BUG-033-receipt-target-grouping-and-wrapper-normalization           head=0 work=0 difflines=5
      BUG-035-validation-control-plane-churn-and-scope-overreach          head=0 work=0 difflines=5
      BUG-036-completed-scopes-count-format-sensitive                     head=0 work=0 difflines=5
      BUG-037-uservalidation-opt-out-acceptance                           head=0 work=0 difflines=5
      BUG-039-interpreter-unusable-misreported-as-classification-failure  head=0 work=0 difflines=5

      Clause 1 — VERDICT unchanged: 6 of 6 undeclared packets, head=0 work=0.
      No verdict moved in either direction.

      Clause 2 — OUTPUT differs in exactly one respect. The diff is byte-identical
      in shape on all six; BUG-032 shown, the other five are character-for-character
      the same three lines:
      $ diff <(bash /tmp/al41head/bubbles/scripts/artifact-lint.sh "$PWD/bugs/BUG-032-...") \
             <(bash bubbles/scripts/artifact-lint.sh "$PWD/bugs/BUG-032-...")
      1c1,2
      < ✅ Required artifact exists: spec.md
      ---
      > ℹ️  Bug packet form: full (no state.json .packet declaration; registry absent-default)
      > ✅ Required artifact exists: bug.md

      Mapped clause by clause to the amended wording:
        "spec.md ceases to be required"          -> the single removed line
        "bug.md becomes required"                -> one of the two added lines
        "one informational line naming the       -> the ℹ️ line
         resolved form"
        "any other output difference is a        -> none. difflines=5 is exactly
         defect"                                    the 3 content lines plus diff's
                                                    own "1c1,2" and "---" markers.

      Checked because every clause of the amended expectation was measured true
      in this session, not because the expectation was relaxed to fit a result.
      ```
   - **AMENDED by bubbles.design — expectation corrected; re-measured and now met.**
     The original wording read "byte-identical verdicts for every undeclared
     packet" and was measured FALSE (finding `F-041-01`). Adjudication in
     `design.md` §5.1: the original wording was too strict, not the fix. The
     required-artifact set moving `spec.md` → `bug.md` is the CORRECTION of a
     pre-existing defect — `bug-packet.yaml`'s `full` form declares `bug.md` and
     never declared `spec.md` — not a widening BUG-041 introduced. The
     hard-coded `spec.md` requirement was the "third private copy of the
     contract" that `design.md` §4 rejects by name; reading the set through
     `bug-packet-resolve.sh` IS the fix, and the identity change is that
     principle taking effect. No verdict moves in either direction.
   - **Amended expectation (authoritative):** for every packet whose `.packet` is
     absent, the lint VERDICT (exit code) is unchanged. The lint OUTPUT may differ
     in exactly one respect: the required-artifact set is corrected to the set
     `bug-packet.yaml` declares for the resolved form — `spec.md` ceases to be
     required, `bug.md` becomes required — plus one informational line naming the
     resolved form. Any other output difference, or any verdict difference, is a
     defect in the fix.
   - **Population corrected from seven to six.** The original measurement treated
     seven packets as "undeclared". `design.md` §5.1's own RETRACTION establishes
     that `.packet` lives in `state.json`, and `BUG-041` declares
     `"packet": "full"`, so BUG-041 and BUG-038 are both DECLARED and both sit
     outside M6's population. This makes the test narrower, not easier: it removes
     a packet that had agreed with the expectation.
   - Raw output evidence from the ORIGINAL measurement, retained (inline, no references/summaries):
      ```
      packet                                     head work difflines
      BUG-032 / 033 / 035 / 036 / 037 / 039 / 041   0    0    5  (each)
      BUG-038 (the targeted packet)                 1    0   14

      $ diff BUG-032.head BUG-032.work
      1c1,2
      < ✅ Required artifact exists: spec.md
      ---
      > ℹ️  Bug packet form: full (no state.json .packet declaration; registry absent-default)
      > ✅ Required artifact exists: bug.md

      Exit codes are identical for all 7 control packets. The OUTPUT is not.
      The required set for a full BUG packet moved spec.md -> bug.md, which is
      what bug-packet.yaml declares but is a widening design.md never named.
      Recorded as F-041-01 rather than accepted. See report.md E-I6.
      ```
- [x] BUG-038 fails with exactly two report-section issues, not zero
   - **Phase:** implement · **Claim Source:** executed
   - **Scope of the claim:** measured on a RECONSTRUCTED pre-condition, not the
     live packet. The live `bugs/BUG-038-...` lints exit 0 today because its
     owner authored the two sections in after this packet routed them.
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      Fixture: BUG-038 copied to /tmp/bug041-m5, the two headings renamed in
      the COPY. bugs/BUG-038-... itself was not touched.

      $ bash /tmp/bug041-head-tree/bubbles/scripts/artifact-lint.sh <fixture>
      HEAD_EXIT=1  HEAD_ISSUES=6

      $ bash bubbles/scripts/artifact-lint.sh <fixture>
      WORK_EXIT=1  WORK_ISSUES=2
      ❌ report.md missing required section matching: ... Completion Statement
      ❌ report.md missing required section matching: ... Test Evidence

      6 -> exactly 2, both report-section. Not 0. The evidence contract was
      not relaxed and report-sections.yaml was not touched.
      ```
- [x] Regression tests contain no silent-pass bailout patterns
   - **Phase:** implement · **Claim Source:** executed
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      $ grep -n "|| true\|skip\|2>/dev/null" bubbles/scripts/bug-packet-resolve-selftest.sh
      120:if [[ "$rc" -ne 0 ]] && [[ -z "$(printf '%s' "$absent_out" | grep '^form=' || true)" ]]; then
      138:for flag in --skip --force --ignore --no-verify; do
      151:readers="$(grep -l 'bug-packet-resolve\.sh' "$SCRIPT_DIR"/*.sh 2>/dev/null \

      bug-packet-resolve-selftest.sh: || true=1  skip=1  2>/dev/null-swallow=1
      bug-packet-selftest.sh:         || true=0  skip=0  2>/dev/null-swallow=2

      All three inspected. Line 120's `|| true` guards a grep INSIDE a
      negative assertion (asserting no form= line was emitted); line 138's
      `--skip` is the bypass-flag REJECTION loop; line 151 counts readers.
      None short-circuits a failing assertion into a pass. Both selftests
      report an explicit check count and a failure count.
      ```
- [ ] All existing tests pass (no regressions)
   - **Phase:** implement · **Claim Source:** not-run
   - **Uncertainty Declaration:** `framework-validate` and `release-check` were
     explicitly forbidden to this session. Four packet lints and three selftests
     passing is not the suite, and nothing measured here supports the broader
     claim. Left unchecked rather than inferred.
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      Not run. No evidence exists for this item.

      What WAS run, and does not substitute for it:
        artifact-lint on 4 packets            all exit=0
        bug-packet-selftest.sh                exit=0, 9 checks
        bug-packet-resolve-selftest.sh        exit=0, 10 checks
        micro-fix-admission-selftest.sh       exit=0, 23/23
      ```
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
   - **Phase:** implement · **Claim Source:** executed
   - **Resolution (measured this session):** F-041-04's behavioural gap is
     CLOSED, at a different site than predicted. Mutation-proof below.
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      BASELINE
      $ shasum -a 256 bubbles/scripts/state-transition-guard.sh
      dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783
      $ bash bubbles/scripts/compact-obligation-basis-selftest.sh
      compact-obligation-basis-selftest: 16 check(s), 0 failure(s)
      BASE_EXIT=0

      MUTATION A — read guard alone removed
      (`[[ -f "$scope_path" ]] || return 0`, build_scope_analysis_units)
      $ bash bubbles/scripts/compact-obligation-basis-selftest.sh
      compact-obligation-basis-selftest: 16 check(s), 0 failure(s)
      MUTA_EXIT=0
      One element alone does NOT reproduce. Confirms the prior measurement.

      MUTATION B — read guard removed AND scopes.md enrolment forced
      unconditional (`scope_files+=("$feature_dir/scopes.md")`, i.e. the
      pre-BUG-041 shape), leaving BUG-042's obligation machinery untouched so
      the experiment isolates F-041-02's contribution.
      $ bash bubbles/scripts/compact-obligation-basis-selftest.sh
        FAIL B4  the obligation basis is selected
             the guard never reported it; every assertion below would be vacuous
        FAIL B1  fully attested packet passes the basis
        FAIL B2  one unattested obligation is refused
        FAIL B2b the refusal is specific
        FAIL B3  unchecked attestation refused distinguishably
        FAIL B5  dischargedIn is load-bearing
        FAIL B8  scopeless form cannot claim completed scopes
        FAIL B9  Check 4A follows the relocation
        FAIL B10 G027 is form-aware for the compact form
        FAIL B11 G027 still refuses an unevidenced compact phase claim
        ok   B1b the 'ZERO DoD checkbox items' structural refusal no longer
                 fires on a compact packet
      compact-obligation-basis-selftest: 16 check(s), 10 failure(s)
      MUTB_EXIT=1

      REVERT BY EDIT (never `git checkout`)
      $ shasum -a 256 bubbles/scripts/state-transition-guard.sh
      dd87eee6271e74c1f06a584cce94c708a9d5f9370042433132672ffccb76e783
      byte-identical to baseline.
      $ bash bubbles/scripts/compact-obligation-basis-selftest.sh
      compact-obligation-basis-selftest: 16 check(s), 0 failure(s)
      REVERT_EXIT=0

      WHAT THIS PROVES, AND WHAT IT DOES NOT.
      10 of 16 assertions are load-bearing on F-041-02. B4 and B8 — the two
      this item turns on — go RED, and B4 names the death mode exactly: the
      guard produces no verdict at all, so the packet becomes un-evaluable.
      That is behavioural coverage, not wiring coverage: P6 in
      bug-packet-resolve-selftest.sh would have stayed GREEN through mutation B,
      because the resolver reference is untouched by it.

      NOT proven, recorded so it is not overclaimed: B1b stayed GREEN. It is a
      NEGATIVE assertion (a refusal string must be absent), and a dead guard
      emits no strings, so it passes vacuously under this mutation. B1b is
      therefore NOT load-bearing on F-041-02; B4 and B8 carry this item.

      SITE. The coverage lives in compact-obligation-basis-selftest.sh, which
      is BUG-042-owned, auto-discovered by framework-validate's *-selftest.sh
      glob, and present in this working tree alongside the F-041-02 fix it
      covers — neither is in HEAD yet:
        $ git show HEAD:bubbles/scripts/state-transition-guard.sh | grep -c F-041-02
        0
        $ grep -c F-041-02 bubbles/scripts/state-transition-guard.sh
        4
      Fix and coverage are in identical commit state; they land together.

      A reader auditing state-transition-guard-selftest.sh still finds ZERO
      packet-form coverage there:
        $ grep -cE "bug_packet_form|bug-packet|packet form|obligation" \
            bubbles/scripts/state-transition-guard-selftest.sh
        0
      The word "compact" does appear there 19 times, but in an unrelated sense
      (compact JSON-array shape of completedScopes). See F-041-04.
      ```
   - **Superseded material below, preserved rather than rewritten** — the
     original block and the prior session's amendment are part of the record.
   - Raw output evidence (inline under this item, no references/summaries):
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
   - **AMENDMENT — measured this session, superseding the block above:**
      ```
      $ grep -cE "bug_packet_form|bug-packet-resolve|compact" \
          bubbles/scripts/state-transition-guard.sh
      26

      The superseded block asserted this grep returned 0 and concluded that
      "this packet changed no behaviour there". Both clauses are now FALSE.
      state-transition-guard.sh gained form-aware behaviour in this session,
      so it enters this item's scope of "EVERY new/changed/fixed behavior".

      Coverage ADDED this session, and proven non-vacuous:
        $ bash bubbles/scripts/bug-packet-resolve-selftest.sh
          ok   P5 2 non-selftest surface(s) call bug-packet-resolve.sh
          ok   P6 artifact-lint.sh reads the artifact set through
                  bug-packet-resolve.sh
          ok   P6 state-transition-guard.sh reads the artifact set through
                  bug-packet-resolve.sh
        bug-packet-resolve-selftest: 12 check(s), 0 failure(s)
        BPR_EXIT=0

        Mutation (guard's resolver reference renamed away):
        $ bash bubbles/scripts/bug-packet-resolve-selftest.sh
          ok   P5 1 non-selftest surface(s) call bug-packet-resolve.sh
          FAIL P6 state-transition-guard.sh reads bug-packet-resolve.sh
        bug-packet-resolve-selftest: 12 check(s), 1 failure(s)
        MUT_BPR_EXIT=1
        P5 stayed GREEN while P6 went RED, which is exactly the blind spot
        P6 closes. Reverted by edit; guard byte-identical at
        sha256 7d260122dc5107fb9fa9ce1d39f12275299c98fa6562244a711bef5adcae91b3
        with 0 MUTATION residue.

      WHY THIS ITEM STAYS UNCHECKED DESPITE THAT COVERAGE.
      P6 pins the WIRING (the guard reads the resolver). It does NOT pin the
      BEHAVIOUR (a compact packet produces a verdict; a full packet keeps its
      scope analysis). Proof that the distinction is real, not pedantic:
      mutation Z below removed both compact-aware elements while LEAVING the
      resolver reference in place, so P6 would have stayed green through it.
        $ bash bubbles/scripts/state-transition-guard.sh \
            bugs/BUG-038-progress-timeout-bsd-wc-padding      # under mutation Z
        state-transition-guard.sh: line 582: .../scopes.md: No such file or directory
        MUTZ2_38_EXIT=1   lines=1   verdict_lines=0

      The behavioural pin belongs in state-transition-guard-selftest.sh, which
      is deliberately OUT of this packet's boundary and which this session was
      forbidden to run. Recorded as finding F-041-04 rather than closed, and
      this item is left unchecked rather than checked on partial coverage.
      ```
- [ ] Broader E2E regression suite passes
   - **Phase:** implement · **Claim Source:** not-run
   - **Uncertainty Declaration:** same forbidden command as the item above.
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      Not run. No evidence exists for this item.
      ```
- [ ] Bug marked as Fixed in bug.md
   - **Phase:** implement · **Claim Source:** not-run
   - **Uncertainty Declaration:** marking the bug Fixed asserts a completeness
     this session did not measure. `F-041-01`, `F-041-02`, `F-041-03` and
     `F-041-04` are now ALL CLOSED, and DoD item 11 is checked, so the finding
     ledger no longer blocks this item. DoD items 10 and 12 remain unevidenced
     and both require commands forbidden to every session that has touched this
     packet. Deliberately not marked.
   - Raw output evidence (inline under this item, no references/summaries):
      ```
      Blocked by:
        DoD 10  "All existing tests pass (no regressions)"  — requires framework-validate
        DoD 12  "Broader E2E regression suite passes"        — requires framework-validate / release-check

      CLOSED since the previous revision of this item, and no longer blocking:
        F-041-01  adjudicated in design.md 5.1; DoD item 7 measured and checked
        F-041-02  fourth site REPAIRED; see design.md 3.5.2
        F-041-03  RESOLVED-BY-ROUTING to BUG-042, which delivered the compact
                  form's completion basis. Re-derived 2026-08-25, not relayed:
                    $ bash bubbles/scripts/bug-packet-resolve.sh \
                        --registry bubbles/registry/bug-packet.yaml
                    obligation=compact|reproduce-before-fix|report.md|report.md
                    obligation=compact|adversarial-regression|report.md|report.md
                    obligation=compact|root-cause-stated|bug.md|report.md
                    obligation=compact|evidence-is-execution|report.md|report.md
                    RESOLVE_EXIT=0
                  Where the finding recorded ZERO obligation facts.
        F-041-04  behavioural pin closed by BUG-042's guard-side coverage
        DoD 11    checked on measured evidence

      The superseded reproduction under this item recorded:
        state-transition-guard.sh: line 582: .../scopes.md: No such file or directory
        STG_EXIT=1
      That death no longer occurs. Re-measured 2026-08-25:
        $ bash bubbles/scripts/state-transition-guard.sh \
            bugs/BUG-038-progress-timeout-bsd-wc-padding
        TRANSITION BLOCKED: 5 failure(s), 2 warning(s)
        GUARD_EXIT=1
        Check 4: "Completion basis: REGISTRY-DECLARED OBLIGATIONS
                  (bug-packet.yaml 'compact' form declares 4;
                   the required set is not author-chosen)"
                 4/4 obligations PASS, attested [x] in report.md
        Check 5: "NOT_APPLICABLE: Check-5-all-done — the 'compact' packet form
                  declares no scopes.md" + PASS "completedScopes is EMPTY"
      The packet moved 20 -> 17 -> 5 failures across the three repairs, and
      Check 4 went from "cannot verify completion" to a registry-derived basis.

      This item nonetheless stays UNCHECKED. Items 10 and 12 require
      framework-validate and release-check, which remain forbidden to every
      session so far, so no session has evidence for the broader-suite claim.
      Item 13 asserts a completeness strictly stronger than what items 10 and 12
      support, so it cannot be checked while they are unchecked. Item 11 was
      additionally un-checked this session on falsified evidence.
      ```

## Routed finding — not owned by this scope

`bugs/BUG-038-progress-timeout-bsd-wc-padding/report.md` lacks the
`### Completion Statement` and `### Test Evidence` sections that
`report-sections.yaml` requires of every report. Its evidence exists under
`## Reproduction BEFORE fix`, `## Reproduction AFTER fix`, and `## Lint`.

This packet is forbidden to edit BUG-038, and `design.md` §2.2 determines the
gap is an authoring gap rather than a linter defect. Routed to the owner of
BUG-038. It must NOT be absorbed into Scope 1, because absorbing it would mean
relaxing the section contract to make one packet pass.
