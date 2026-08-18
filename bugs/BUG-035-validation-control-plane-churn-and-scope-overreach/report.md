# BUG-035 Report

Historical evidence labels below use provisional BUG-034 identifiers from
commands executed before `origin/main` allocated BUG-034 to another defect.
They remain verbatim evidence. This packet's canonical identity is BUG-035.

## Summary

- Filed a fourteen-defect framework packet.
- Recorded one current-session coordination sample.
- Implemented and focused-tested D8 payload-closure stability.
- Implemented and focused-tested D9 exact-HEAD fixture baselining.
- D1-D7 remain filed and unimplemented.
- Implemented D10 stable captured-output assertions and D11 contention
  confirmation. Every focused owner passes.
- Implemented and focused-tested D12 deterministic core-tier pattern matching.
- Implemented and focused-tested D13 progress-aware downstream validation
  bounds and fail-closed child-result handling.
- Implemented and focused-tested D14 namespaced, fail-closed evidence capture.

### Validation-runner defect reproduction

**Executed:** YES

**Commands:** `bash bubbles/scripts/payload-closure-guard.sh` and
`bash bubbles/scripts/framework-validate-changed-only-selftest.sh`.

**Observed exits:** payload closure returned `1`, then returned `0` on unchanged
bytes. Changed-only returned `1` from a detached worktree.

```text
[payload-closure-guard][ERROR] managed file references unshipped dependency:
bubbles/scripts/framework-validate.sh ->
bubbles/scripts/experience-recall-eval-selftest.sh
[payload-closure-guard][ERROR] found 1 payload closure violation(s)
PAYLOAD_CLOSURE_EXIT=1
[payload-closure-guard] OK — 509 managed shell script(s) scanned against 110
source-only entry(ies), payload is dependency-closed
PAYLOAD_CLOSURE_EXIT=0
Running framework-validate --changed-only selftest...
error: patch failed: bubbles/release-manifest.json:1
error: bubbles/release-manifest.json: patch does not apply
error: patch failed: bubbles/scripts/state-transition-guard.sh:1326
error: bubbles/scripts/state-transition-guard.sh: patch does not apply
CHANGED_ONLY_EXIT=1
```

## Completion Statement

The bug packet remains `in_progress`. D8 passes its focused adversarial selftest
and the real repository scan. D9 passes from the rebased detached worktree.
D10-D12 pass focused post-fix tests; D10's release-discovered consumers also
pass 20 repeated runs each. D1-D7, final full validation, release
readiness, audit, human acceptance, and validate-owned certification remain
incomplete. The earlier combined full suite predates D10-D11 and is retained as
prior-candidate evidence only.

## Test Evidence

### Pre-fix session coordination sample

**Executed:** YES

**Command:** Set `DB` to the local Copilot session store under `$HOME`, then run
the read-only SQLite query below with a 30-second timeout.

```sql
WITH active(id) AS (
  VALUES
    ('e7afb402-3902-4310-b18d-ccbf5aa0efef'),
    ('dc018530-a25f-47bb-b766-75b160173f74'),
    ('aa96050d-f77e-4b32-a8c5-809b483173a6'),
    ('c45b7788-90b5-4726-b212-90a75f3eea34'),
    ('f0439331-233a-4573-9bd3-6ae4d54e7d41'),
    ('9addfd03-dc8e-46bf-b09c-df081d71cca3'),
    ('cfde3022-ade2-4f42-bd39-41af2194d50c'),
    ('a48888bd-45f1-4d64-9aa4-d097ea0cdd6f'),
    ('5e195936-0b0b-456d-aef4-8ed5266db3fa'),
    ('9ecace1d-4b2f-4e59-b821-11bba6050c3f')
),
active_turns AS (
  SELECT turns.* FROM turns JOIN active ON active.id = turns.session_id
),
writes AS (
  SELECT session_files.file_path
  FROM session_files JOIN active ON active.id = session_files.session_id
  WHERE session_files.tool_name IN (
    'create_file', 'replace_string_in_file',
    'multi_replace_string_in_file', 'apply_patch'
  )
),
categorized AS (
  SELECT CASE
    WHEN file_path LIKE '%/specs/%' THEN 'product_specs_reports'
    WHEN file_path LIKE '%/docs/%' OR file_path LIKE '%.md' THEN 'product_docs'
    WHEN file_path LIKE '%/tests/%' OR file_path LIKE '%_test.%'
      OR file_path LIKE '%test_%' THEN 'product_tests'
    ELSE 'product_code_config_ops'
  END AS category
  FROM writes
)
SELECT 'sessions', 10
UNION ALL SELECT 'turns', COUNT(*) FROM active_turns
UNION ALL SELECT 'handoff_requests', SUM(
  CASE WHEN trim(user_message) = '/bubbles.handoff' THEN 1 ELSE 0 END
) FROM active_turns
UNION ALL SELECT 'continue_or_retry_requests', SUM(
  CASE WHEN lower(trim(user_message)) IN ('continue', 'try again')
    THEN 1 ELSE 0 END
) FROM active_turns
UNION ALL SELECT 'sessions_over_40_turns', COUNT(*)
FROM (
  SELECT session_id FROM active_turns
  GROUP BY session_id HAVING COUNT(*) > 40
)
UNION ALL SELECT category, COUNT(*) FROM categorized GROUP BY category
UNION ALL SELECT 'total_writes', COUNT(*) FROM writes;
```

**Exit Code:** 0

**Output:**

```text
sessions|10
turns|406
handoff_requests|7
continue_or_retry_requests|119
sessions_over_40_turns|4
bubbles_framework|7
product_code_config_ops|213
product_docs|11
product_specs_reports|113
product_tests|69
total_writes|413
```

The output proves coordination churn in the sampled sessions. It does not prove
that every continuation was unnecessary or measure wall-clock cost.

### D7 canonical scenario-manifest reader

**Executed:** YES

**Command:** `bash bubbles/scripts/traceability-guard-selftest.sh`

**Exit Code:** 0

**Output:**

```text
[selftest traceability-guard] Case 1: clean feature -> exit 0
PASS: clean feature exits 0 (got 0)
PASS: output reports scenario->row mapping
PASS: Case 1 reports inferred edge confidence (no trace id)
[selftest traceability-guard] canonical manifest id and string linked test (exit 0)
PASS: canonical scenario-manifest envelope exits 0
PASS: canonical id is counted as a scenario contract
PASS: canonical string linkedTests path is validated
PASS: canonical evidenceRefs array is recognized
[selftest traceability-guard] canonical manifest missing linked test (exit 1)
PASS: canonical missing linked test exits nonzero
PASS: canonical missing string linkedTests path is named
[selftest traceability-guard] PASS
```

This closes the canonical-reader portion of D7. The broader source packet-form
authority remains unimplemented and keeps SCN-B035-007 incomplete.

### D8 payload-closure green stage

**Executed:** YES

**Commands:** `bash bubbles/scripts/payload-closure-guard-selftest.sh`, then
`bash bubbles/scripts/payload-closure-guard.sh`.

**Exit Code:** 0

**Output:**

```text
[payload-closure-guard-selftest] PASS T1 unguarded $SCRIPT_DIR reference to a source-only script fails (exit 1)
[payload-closure-guard-selftest] PASS T2 unguarded $REPO_ROOT reference to a source-only regression test fails (exit 1)
[payload-closure-guard-selftest] PASS T3 existence-guarded reference passes (exit 0)
[payload-closure-guard-selftest] PASS T4 run_check_self_only scheduling passes (exit 0)
[payload-closure-guard-selftest] PASS T4b large self-only scheduler is stable across 20 runs
[payload-closure-guard-selftest] PASS T5 literal registry entry is not a dependency (exit 0)
[payload-closure-guard-selftest] PASS T6 comment mentioning the script is not a dependency (exit 0)
[payload-closure-guard-selftest] PASS T7 writing a fixture file is not a dependency (exit 0)
[payload-closure-guard-selftest] PASS T7b one materialized path does not excuse a separate source dependency (exit 1)
[payload-closure-guard-selftest] PASS T9 a reasoned payload-closure-allow marker exempts the reference (exit 0)
[payload-closure-guard-selftest] PASS T8 missing manifest exits 2 rather than reporting closure
[payload-closure-guard-selftest] 11 passed, 0 failed
[payload-closure-guard] OK — 509 managed shell script(s) scanned against 110 source-only entry(ies), payload is dependency-closed
```

### D9 detached changed-only green stage

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-034 D9 detached changed-only selftest" -- bash bubbles/scripts/framework-validate-changed-only-selftest.sh`

**Exit Code:** 0

**Output:**

```text
# BUG-034 D9 detached changed-only selftest
$ bash bubbles/scripts/framework-validate-changed-only-selftest.sh
exit: 0
lines: 11
sha256: d6079ddad7d5bf46ac0f3d21ae0f804e65d099edd803db62ca8da446bd164ddb
--- output ---
Running framework-validate --changed-only selftest...
PASS: fixture baseline matches the exact source HEAD
PASS: a modified subject script keeps its own selftest in the run set
PASS: an unrelated selftest is skipped when its surface is untouched
PASS: fixture working tree is clean after committing
PASS: a committed, not-yet-pushed change still selects its selftest
PASS: a clean tree still narrows the run set instead of running everything
PASS: an undeterminable change set runs everything rather than skipping
PASS: the previously-skipped check runs once the change set is undeterminable

framework-validate changed-only selftest passed.
```

### D10 stable large-output assertions

**Executed:** YES

**Commands:** `bash bubbles/scripts/implementation-reality-scan-selftest.sh`
and `bash tests/regression/test_24_g028_sensitive_client_storage.sh`, each
through `evidence-capture.sh`.

**Exit Codes:** 0 and 0

```text
# final rebased D10 implementation reality assertions
$ bash bubbles/scripts/implementation-reality-scan-selftest.sh
exit: 0
lines: 790
sha256: 4fe21f63f12040b425f1f528a276b42e391e3916644152f0003fd096aaba2ca6
PASS: Parser-unavailable configured approval fails closed
Scenario: portable watchdog preserves exit 124 without GNU coreutils.
PORTABLE_WATCHDOG_FALLBACK=124
PASS: Portable watchdog preserves exit 124
implementation-reality-scan selftest passed.

# final rebased D10 system PATH regression
$ bash tests/regression/test_24_g028_sensitive_client_storage.sh
exit: 0
lines: 2093
sha256: f1c75615f8eec4bf93c84229448ad12ec048afe933f3abbcb144e57fd08515c1
PASS: managed selftest runs with the system-only PATH
PASS: managed selftest preserves watchdog exit 124
=== BUG-013 regression summary ===
test_24_g028_sensitive_client_storage: 57 passed, 0 failed
BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED
```

The first final release-readiness run exposed the same quiet-terminal-pipeline
defect in three additional captured-output consumers. Each focused suite passed
after switching to direct here-string reads. The three suites then passed 20
consecutive runs each on unchanged bytes.

**Executed:** YES

**Commands:** Run `bubbles/scripts/adversarial-resolve-selftest.sh`,
`bubbles/scripts/evidence-tool-log-bridge-selftest.sh`, and
`bubbles/scripts/rapid-tool-delivery-mode-selftest.sh` once for complete output,
then run all three in a 20-iteration fail-fast loop.

**Exit Codes:** 0, 0, 0, and 0

```text
adversarial-resolve-selftest: 1139 passed, 0 failed
PASS
evidence-tool-log-bridge-selftest: PASS
rapid-tool-delivery-mode-selftest: all cases passed.
D10_STABILITY_PASS run=1 scripts=3
D10_STABILITY_PASS run=2 scripts=3
D10_STABILITY_PASS run=3 scripts=3
D10_STABILITY_PASS run=4 scripts=3
D10_STABILITY_PASS run=5 scripts=3
D10_STABILITY_PASS run=6 scripts=3
D10_STABILITY_PASS run=7 scripts=3
D10_STABILITY_PASS run=8 scripts=3
D10_STABILITY_PASS run=9 scripts=3
D10_STABILITY_PASS run=10 scripts=3
D10_STABILITY_PASS run=11 scripts=3
D10_STABILITY_PASS run=12 scripts=3
D10_STABILITY_PASS run=13 scripts=3
D10_STABILITY_PASS run=14 scripts=3
D10_STABILITY_PASS run=15 scripts=3
D10_STABILITY_PASS run=16 scripts=3
D10_STABILITY_PASS run=17 scripts=3
D10_STABILITY_PASS run=18 scripts=3
D10_STABILITY_PASS run=19 scripts=3
D10_STABILITY_PASS run=20 scripts=3
D10_STABILITY_SUMMARY completed=20 expected=20 status=0
```

The final aggregate exposed one more D10 occurrence: the autonomy posture
selftest piped captured guard output into `grep -q` under `pipefail`. Its target
diagnostic was present, but the aggregate reported the assertion failed. The
aggregate evidence wrapper preserved the complete 18,403-line output hash and
named this as the only failing check.

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-035 and BUG-036 framework validation on final candidate" -- bash bubbles/scripts/cli.sh framework-validate`

**Exit Code:** 1

```text
# BUG-035 and BUG-036 framework validation on final candidate
$ bash bubbles/scripts/cli.sh framework-validate
exit: 1
lines: 18403
sha256: 0b664e3a9f8cea3db6733c2e8c7968537c5562d0e238354808f98d2a66cb4485
--- failure-shaped lines from the omitted region ---
FAIL: drift finding should name both the enum and the resolver
FAIL: Autonomy posture consistency selftest (G135 / IMP-039 SCOPE-7)
Framework validation failed with 1 failing check(s) (2 skipped: 2 denylisted).
Failed checks:
  - Autonomy posture consistency selftest (G135 / IMP-039 SCOPE-7)
```

The assertion now uses the same in-memory shell pattern matching as the
neighboring posture/runner diagnostic. The focused owner suite passes on the
repaired bytes.

**Executed:** YES

**Command:** `bash bubbles/scripts/autonomy-posture-guard-selftest.sh`

**Exit Code:** 0

```text
Running autonomy-posture-guard selftest...
Scenario: the posture surface stays internally consistent, and drift is refused.
PASS: a conformant posture surface passes (exit 0)
PASS: a deleted Autonomy Floor heading is refused
PASS: a hollowed-out floor (heading kept, items removed) is refused
PASS: an enum value the resolver does not accept is refused
PASS: a posture named by three runners but not the fourth is refused
PASS: the refusal names both the posture and the runner that omits it
PASS: a resolver value the enum does not declare is refused
PASS: drift is reported as drift, naming both sides
PASS: a resolver that stops refusing an unbounded unattended is refused
PASS: an unbounded refusal that drops its named code is refused
PASS: a resolver that accepts a bypass flag is refused
PASS: the guard refuses bypass flag --skip (exit 2)
PASS: the guard refuses bypass flag --force (exit 2)
PASS: the guard refuses bypass flag --ignore (exit 2)
PASS: the guard refuses bypass flag --no-verify (exit 2)
PASS: --help exits 0
PASS: an unknown flag is a usage error (exit 2)
autonomy-posture-guard selftest passed.
```

The next aggregate confirmed the autonomy repair and exposed the same D10
mechanism in two more selftests. Both captured their guard output, piped it into
multiple quiet `grep` consumers under `pipefail`, and passed when run focused.
The aggregate wrapper again preserved a complete verifiable hash and named only
those two checks.

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-035 and BUG-036 framework validation after D10 aggregate repair" -- bash bubbles/scripts/cli.sh framework-validate`

**Exit Code:** 1

```text
# BUG-035 and BUG-036 framework validation after D10 aggregate repair
$ bash bubbles/scripts/cli.sh framework-validate
exit: 1
lines: 18423
sha256: 21e7972e665e7c94bae11d58b343bb776dd496bd0ab2fac30ecfdc1c8fea5c96
Release manifest is current: 7.28.0 (923 managed files)
PASS: Release manifest freshness
Wall clock: 6589s across 343 executed check(s).
Framework validation failed with 2 failing check(s) (2 skipped: 2 denylisted).
Failed checks:
  - Requirement-mechanism guard selftest (G097)
  - Vertical-delivery plan guard selftest (BFW-02 / IMP-022)
```

Every captured-output assertion in those two suites now uses a complete
in-memory literal predicate. Both owner suites pass focused and then pass as a
pair for 20 consecutive runs on unchanged bytes.

**Executed:** YES

**Commands:** `bash bubbles/scripts/requirement-mechanism-guard-selftest.sh`,
`bash bubbles/scripts/vertical-delivery-plan-guard-selftest.sh`, then a
20-iteration loop running both scripts.

**Exit Codes:** 0, 0, and 0

```text
D10_PAIR_RUN=20
PASS: S1 PKCE named but absent from code BLOCKs (exit 1)
PASS: S2 PKCE with code_verifier evidence passes (exit 0)
PASS: S3 justified naming difference passes (exit 0)
PASS: S4 no mechanism named is not applicable (exit 0)
PASS: S5 pre-cutoff spec is grandfathered to warning (exit 0)
PASS: S6 satisfied mechanism with no negative assertion emits #4 nudge, non-blocking (exit 0)
PASS: S7 live-tier test backed by httptest.NewServer emits #3 nudge, non-blocking (exit 0)
PASS: S8 HMAC named but absent from code BLOCKs (exit 1)
requirement-mechanism-guard-selftest: PASSED
PASS: T12 Feature-010-shaped 14-scope horizontal plan warns with remediation (exit 0)
PASS: T13 vertical twin (same 14 scopes, early consumer) passes clean (exit 0)
PASS: T14 early-consumer plan with 4 unexposed backend scopes is flagged (exit 0)
PASS: T15 same plan with Exposure-Deferred lines naming a target passes clean (exit 0)
PASS: T16 deferral naming no target section is reported as malformed (exit 0)
PASS: T17 ASCII -> arrow accepted identically to the Unicode arrow (exit 0)
PASS: T18 unexposed increment with verticalPlanGuard: block FAILS (exit 1)
vertical-delivery-plan-guard-selftest: all cases passed.
```

### D11 confirmed performance check

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-034 D11 performance decision and workload" -- bash bubbles/scripts/state-transition-guard-perf-selftest.sh`

**Exit Code:** 0

```text
# final rebased D11 performance decision
$ bash bubbles/scripts/state-transition-guard-perf-selftest.sh
exit: 0
lines: 12
sha256: 756bab4cfc114f90c5f8e3c612fae51bacb1f2db02b2a78caaf17f09d9b2ecb6
--- output ---
  PASS: one healthy retry distinguishes transient contention (51s -> 12s)
  PASS: two over-budget samples preserve the performance failure (51s, 51s)
  PASS: timeout fires (124) on a hanging command
  PASS: fast command exit code preserved (3)
  PASS: pruned find returns only the real file (1), excludes generated-dir decoys
  PASS: no generated-directory paths leak through the prune
  PASS: pruned walk completes within budget (0s <= 10s)
  PASS: guard over 6036-line report.md completes in 13s (< 30s best confirmed sample; fork-storm was ~126s)
  PASS: Check 11 distinct-category semantics preserved (exactly 1 illegitimate block detected)

[state-transition-guard-perf-selftest] 9 passed, 0 failed
[state-transition-guard-perf-selftest] OK
```

The release aggregate later produced two 30-second wall samples while the
unchanged focused fixture remained healthy. D11 now records Bash process-tree
CPU as the discriminating signal instead of treating wall time alone as guard
work. The first post-fix live sample exercised the target condition at 34.211
seconds wall and 15.044 seconds CPU. The final suite adds a missing-retry
fail-closed adversary and passes all 11 checks.

**Executed:** YES

**Command:** `bash bubbles/scripts/state-transition-guard-perf-selftest.sh`

**Exit Code:** 0

```text
PASS: one CPU-healthy retry distinguishes transient contention (wall=51s CPU=51s -> wall=51s CPU=12s)
PASS: two wall-and-CPU over-budget samples preserve the performance failure (51s/51s, 51s/51s)
PASS: one CPU-healthy sample identifies host contention without an unnecessary retry
PASS: missing retry data cannot turn an over-budget sample into a pass
PASS: timeout fires (124) on a hanging command
PASS: fast command exit code preserved (3)
PASS: pruned find returns only the real file (1), excludes generated-dir decoys
PASS: no generated-directory paths leak through the prune
PASS: pruned walk completes within budget (0s <= 10s)
PASS: guard over 6036-line report.md stays within the 30s wall-or-CPU budget (first wall=25.912s CPU=14.323s; retry wall=not-run CPU=not-run; fork-storm was ~126s)
PASS: Check 11 distinct-category semantics preserved (exactly 1 illegitimate block detected)
[state-transition-guard-perf-selftest] 11 passed, 0 failed
[state-transition-guard-perf-selftest] OK
```

### D12 deterministic core-tier pattern matching

**Executed:** YES

**Commands:** `bash bubbles/scripts/core-tier-pattern-lint-selftest.sh`, then
100 direct runs of `bash bubbles/scripts/core-tier-pattern-lint.sh`.

**Exit Code:** 0

```text
# BUG-034 D12 core-tier pattern stability
$ bash bubbles/scripts/core-tier-pattern-lint-selftest.sh
exit: 0
lines: 9
sha256: 0abea546caa63fd921df7327807478f115171f2f89aa8013b4c4ac2034c2af64
--- output ---
  ok   a validator whose core patterns all match is green
  ok   renaming a core check turns the lint red and names the dead pattern
  ok   a backslash-continued run_check is counted as scheduled
  ok   an empty core tier fails loudly instead of passing vacuously
  ok   a bypass-shaped flag is rejected by name
  ok   the shipped framework-validate.sh is clean across 20 runs

core-tier-pattern-lint-selftest: 6/6 checks passed
core-tier-pattern-lint-selftest: OK
CORE_TIER_POSTFIX_PASS=100 FAIL=0
```

### D13 progress-aware downstream validation

**Executed:** YES

**Commands:** `bash bubbles/scripts/guard-lib-timeout-selftest.sh`, then run
`v5.3-selftest.sh` with a two-second idle ceiling and three-second absolute
ceiling to force its bounded-progress failure path.

**Exit Codes:** 0 and 1 (expected forced timeout)

```text
PASS instant command in $( ) returns promptly (0s, output intact)
PASS timeout fires and normalizes to 124 (3s)
PASS command exit code preserved (rc=7, 0s)
PASS fallback child can trap SIGINT (rc=130, 0s)
PASS progress extends the idle window without exceeding the absolute ceiling (4s)
PASS silent command stops at the idle deadline with rc=124 (2s)
PASS chatty command stops at the absolute deadline with rc=125 (4s)
PASS progress runner preserves command exit code (rc=9)
PASS absolute timeout force-terminates a TERM-resistant validator process group (10s)
PASS lost progress log fails loud through bounded cleanup (2s)
guard-lib timeout selftest: OK (10 cases)
PASS: T3c contract: zero known failures requires child exit 0
PASS: T3c contract: unexplained nonzero child exit fails closed
PASS: T3c contract: one exactly enumerated known failure accepts a nonzero child exit
FAIL: T3: downstream framework-validate exceeded the 3s absolute ceiling while still producing output (treated as a failure, not a skip)
v5.3-selftest FAILED with 1 issue(s).
V53_TIMEOUT_PROBE exit=1 timeout=1 derivative=0 contracts=3 falsePass=0
```

The forced timeout is the expected adversarial result: exactly one root failure,
zero missing-skip derivatives, and zero accepted-known-defect false-pass text.

The next release run exposed a second D13 boundary: the downstream Check-9
fixture reached a zero-failure transition verdict, but ambient source-checkout
tail/custom gates changed the wrapper result. The repair binds every downstream
command and transition-gate repository input explicitly. Check-9 also binds its
fast path per invocation. The focused source suite and full transition suite are
green on the final bytes.

**Executed:** YES

**Commands:** `bash bubbles/scripts/evidence-admission-hardening-selftest.sh` and
`bash bubbles/scripts/evidence-capture.sh --label "repository-root isolation transition suite final" -- bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Codes:** 0 and 0

```text
PASS: CHECK 43 (re-spelled): same command with an equivalent --repo-root value passes (passes)
PASS: CONTROL (tool-log): a VALID spec-scoped entry makes Check 9 COVER the bare item (Check 9 tool-log path COVERS the bare item)
PASS: NON-TAUTOLOGY (#1): bare-marker fixture passes the OLD guard (old guard PASSES -> new fix has teeth)
PASS: NON-TAUTOLOGY (#5): uppercase-checkbox fixture passes the OLD guard (old guard PASSES -> new fix has teeth)
evidence-admission-hardening-selftest: 19 passed / 0 failed
# repository-root isolation transition suite final
$ bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 428
sha256: 577b45e4a3dbe2920a3892b135af508c5ee958678bdc35e628b85c02cd80e989
state-transition-guard selftest passed.
```

The repository-root contract is also verified through a fresh real downstream
install. Payload integrity passed before execution, and the installed transition
suite produced the same 428-line output hash as the source suite.

**Executed:** YES

**Command:** Install the candidate with `install.sh --local-source`, then run
`bash .github/bubbles/scripts/evidence-capture.sh --label "downstream transition guard selftest final" -- bash .github/bubbles/scripts/state-transition-guard-selftest.sh`.

**Exit Code:** 0

```text
Payload integrity verified against release manifest
# downstream transition guard selftest final
$ bash .github/bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 428
sha256: 577b45e4a3dbe2920a3892b135af508c5ee958678bdc35e628b85c02cd80e989
state-transition-guard selftest passed.
```

### D14 fail-closed evidence capture storage

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture-selftest.sh`

**Exit Code:** 0

```text
ok   records command, exit code, line count and a sha256
ok   short output is emitted in full, not truncated
ok   long output is trimmed and states how many lines were omitted
ok   failing command still emits evidence and propagates exit 7
ok   --verify passes on identical output and FAILS (3) when it changes
ok   stderr is interleaved into the evidence, not discarded
ok   bypass-shaped flag refused with exit 2
ok   no command after -- is a usage error
ok   block carries a re-runnable verify command
ok   a failure line in the omitted region is lifted out, not swallowed
ok   clean output emits no failure section
ok   --diagnostic emits the full output and stamps the escalation
ok   a normal capture carries no escalation stamp
ok   --diagnostic remains bounded by a stated ceiling
ok   TERM stops the child process group and emits preserved interrupted evidence
ok   completed commands leave no background descendant behind
ok   capture-file loss fails loud without emitting an empty evidence hash
evidence-capture-selftest: 17/17 checks passed
evidence-capture-selftest: OK
```

### Remaining persistent reproduction

**Executed:** NO

D1-D7 do not yet have complete persistent red fixtures. D8 and D9 have focused
red and green evidence.

## Code Diff Evidence

**Executed:** NO

Git-backed evidence will be recorded after D9 runs and the release manifest is
regenerated for the final combined source tree.

## Validation Evidence

**Executed:** NO

**Command:** n/a

**Phase Agent:** bubbles.validate

**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO

**Command:** n/a

**Phase Agent:** bubbles.audit

**Claim Source:** not-run

Audit has not run.

## Chaos Evidence

**Executed:** NO

**Command:** n/a

**Phase Agent:** bubbles.chaos

**Claim Source:** not-run

Chaos validation is not required for filing and has not run.