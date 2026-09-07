# BUG-047 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Recovered the resultless implementation dispatch for `F-B001-HARDEN-010`.
- The guard now classifies complete registry-authorized skip decisions once and
  reuses that classification in Check 6 and Check 7A.
- The pre-production RED, focused GREEN, and phase-relevance regression captures
  remain hash-identical to the durable report evidence.
- Independent test ownership, full framework validation, and validate-owned
  certification are not claimed by this implementation handoff.

## Completion Statement

The implementation-owned change and current-byte focused verification are
recorded. The bug and scope remain `in_progress` because full framework
validation and validate-owned certification have not run. The next required
owner is `bubbles.test` for independent verification.

## Test Evidence

### Filing posture

**Executed:** NO
**Phase:** bug
**Command:** not run by explicit filing-only instruction
**Exit Code:** not applicable
**Claim Source:** not-run

No defect reproduction or regression suite ran during this invocation. The next
implementation owner must capture the RED result before changing production
code.

## Pre-Production RED Evidence

### Composed Check 6 and Check 7A regression

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `BUBBLES_STATE_TRANSITION_GUARD_BUG047_ONLY=1 /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-047 pre-production composed RED" -- /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Result:** EXPECTED FAIL

<!-- markdownlint-disable MD010 -->
```text
# BUG-047 pre-production composed RED
$ /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 1
lines: 194
sha256: c6df6d17829bcabf4256c2caa48909461001ccc909a55b2bb84241fb35448a52
--- first 20 ---
Running BUG-047 canonical reasoned-skip accounting selftest...
FAIL: BUG-047 SCN-B047-001: a registry-authorized reasoned skip satisfies Check 6 without a completion claim
--- log excerpt: /var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T//bubbles-transition-guard-selftest.boIQS9/bug047-canonical-reasoned-skip.log ---
============================================================
	BUBBLES STATE TRANSITION GUARD
	Feature: /var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T//bubbles-transition-guard-selftest.boIQS9/specs/953-bug047-canonical-reasoned-skip
	Timestamp: 2026-09-01T08:37:27Z
============================================================

--- Check 1: Required Artifacts ---
✅ PASS: Required artifact exists: spec.md
✅ PASS: Required artifact exists: design.md
✅ PASS: Required artifact exists: uservalidation.md
✅ PASS: Required artifact exists: state.json
✅ PASS: Required artifact exists: scopes.md
✅ PASS: Required artifact exists: report.md

--- Check 2: state.json Integrity ---
ℹ️  INFO: Current state.json status: in_progress
ℹ️  INFO: Current workflowMode: bugfix-fastlane
--- failure-shaped lines from the omitted region ---
FAIL: BUG-047 SCN-B047-001: Check 6 no longer reports the canonical skip missing
FAIL: BUG-047 SCN-B047-002: Check 7A does not adjudicate the zero-duration skip decision as executed work
--- omitted 154 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: BUG-047 SCN-B047-004: a reasonless skip remains missing in Check 6
PASS: BUG-047 SCN-B047-004: a reasonless skip gains no Check 7A duration exemption
Running BUG-047 malformed-skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: a non-list changedSurface keeps the skip invalid in Check 6
PASS: BUG-047 SCN-B047-004: a malformed skip gains no Check 7A duration exemption
Running BUG-047 incomplete re-evaluation adversarial selftest...
PASS: BUG-047 SCN-B047-004: a re-evaluated skip without a trigger remains invalid
PASS: BUG-047 SCN-B047-004: an incomplete re-evaluation gains no Check 7A exemption
Running BUG-047 unknown-phase skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: an unknown skip phase cannot account for the required stabilize phase
PASS: BUG-047 SCN-B047-004: an unknown skip phase gains no Check 7A exemption
Running BUG-047 never-skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: a registry neverSkip phase cannot be accounted as skipped
PASS: BUG-047 SCN-B047-004: a neverSkip record gains no Check 7A exemption
Running BUG-047 executed zero-duration control selftest...
PASS: BUG-047 SCN-B047-003: the executed control remains a completion claim for Check 6
PASS: BUG-047 SCN-B047-003: genuine zero-duration stabilize execution remains blocked by Check 7A
----------------------------------------
state-transition-guard BUG-047 selftest failed with 3 issue(s).
Preserving selftest workspace: /var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T//bubbles-transition-guard-selftest.boIQS9
```
<!-- markdownlint-enable MD010 -->

The canonical record failed both required consumers before production changed:
Check 6 reported `stabilize` missing, and Check 7A treated its zero-duration
decision as executed work. All malformed and executed controls remained blocked.

## Focused GREEN Evidence

### Canonical and adversarial reasoned-skip fixtures

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `BUBBLES_STATE_TRANSITION_GUARD_BUG047_ONLY=1 /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-047 runner-bound focused GREEN" -- /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
# BUG-047 runner-bound focused GREEN
$ /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 25
sha256: ba836636cfcd57d8859a41880ac2fc233f68798b949e2ae24fd732861ac7c4f2
--- output ---
Running BUG-047 canonical reasoned-skip accounting selftest...
PASS: BUG-047 SCN-B047-001: a registry-authorized reasoned skip satisfies Check 6 without a completion claim
PASS: BUG-047 SCN-B047-001: Check 6 no longer reports the canonical skip missing
PASS: BUG-047 SCN-B047-002: Check 7A does not adjudicate the zero-duration skip decision as executed work
PASS: BUG-047 SCN-B047-001: the canonical skipped phase is absent from completedPhaseClaims
Running BUG-047 reasonless-skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: a reasonless skip remains missing in Check 6
PASS: BUG-047 SCN-B047-004: a reasonless skip gains no Check 7A duration exemption
Running BUG-047 malformed-skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: a non-list changedSurface keeps the skip invalid in Check 6
PASS: BUG-047 SCN-B047-004: a malformed skip gains no Check 7A duration exemption
Running BUG-047 incomplete re-evaluation adversarial selftest...
PASS: BUG-047 SCN-B047-004: a re-evaluated skip without a trigger remains invalid
PASS: BUG-047 SCN-B047-004: an incomplete re-evaluation gains no Check 7A exemption
Running BUG-047 unknown-phase skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: an unknown skip phase cannot account for the required stabilize phase
PASS: BUG-047 SCN-B047-004: an unknown skip phase gains no Check 7A exemption
Running BUG-047 never-skip adversarial selftest...
PASS: BUG-047 SCN-B047-004: a registry neverSkip phase cannot be accounted as skipped
PASS: BUG-047 SCN-B047-004: a neverSkip record gains no Check 7A exemption
Running BUG-047 executed zero-duration control selftest...
PASS: BUG-047 SCN-B047-003: the executed control remains a completion claim for Check 6
PASS: BUG-047 SCN-B047-003: genuine zero-duration stabilize execution remains blocked by Check 7A
----------------------------------------
state-transition-guard BUG-047 selftest passed.
```

The real guard accepted only the complete registry-authorized skip. Reasonless,
malformed, incomplete re-evaluation, unknown-phase, and `neverSkip` records
remained missing and remained subject to zero-duration adjudication. The
executed `stabilize` control remained blocking.

## Phase-Relevance Regression Evidence

### Registry resolver and no-bypass controls

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-047 phase relevance regression" -- /opt/homebrew/bin/bash bubbles/scripts/phase-relevance-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
# BUG-047 phase relevance regression
$ /opt/homebrew/bin/bash bubbles/scripts/phase-relevance-resolve-selftest.sh
exit: 0
lines: 53
sha256: e81405945f4de19909dde7688529dbd4e30346790d77704628980125cf8cf820
--- first 20 ---
Running phase-relevance-resolve selftest...
PASS: T1 every registry neverSkip phase (8) resolves to run
PASS: T2 an undeclared phase resolves to run
PASS: T2b an undeclared phase reports no-rule
PASS: T3 a skipWhen token with no evaluator resolves to run
PASS: T3b an unimplemented token resolves to run, not skip
PASS: T3c the unimplemented token is named in the rule field
PASS: T4 simplify with no --changed-lines resolves to run
PASS: T4b the unevaluated rule is named, not silently dropped
PASS: T4c chaos with no changed surface resolves to run
PASS: T4d stabilize with no --spec-dir resolves to run
PASS: T4e security with no changed surface resolves to run
PASS: T4f regression with no --spec-dir resolves to run
PASS: T5 simplify skips below the 50-line threshold
PASS: T5b simplify runs at exactly the threshold
PASS: T5c simplify runs above the threshold
PASS: T5d simplify runs at zero changed lines only via the rule, not by accident
PASS: T5e a non-numeric --changed-lines is a usage error
PASS: T6 chaos skips for a docs/config-only surface
PASS: T6b chaos runs as soon as one source file changed
--- omitted 13 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: T8 goal, sprint, iterate, and workflow receive identical verdicts for the same scope
PASS: T8b the deciding runner is recorded in the reason for audit
PASS: T8c every runner the guide names can actually reach the resolver mandate
PASS: T9 a disabled registry makes every phase run
PASS: T9b a rule reassigned to another phase follows the registry
PASS: T9c the phase that lost the rule now runs
PASS: T9d the registry's own reason text is returned, not a restated one
PASS: T10 neverSkip beats a rule that would otherwise fire
PASS: T10b the winning rule is reported as neverSkip
PASS: T11 missing --phase is a usage error
PASS: T11b an unreadable registry is a usage error
PASS: T11c --help exits 0
PASS: T11d '--force' is not accepted (no bypass exists)
PASS: T11d '--skip' is not accepted (no bypass exists)
PASS: T11d '--ignore' is not accepted (no bypass exists)
PASS: T11d '--no-verify' is not accepted (no bypass exists)
PASS: T11d '--skip-phase' is not accepted (no bypass exists)
PASS: T11e the resolver declares no bypass-shaped flag

phase-relevance-resolve-selftest: all cases passed.
```

## HOST-101 Current-Byte Reconciliation

The isolated worktree had no local `tool-calls.jsonl` before this retry. The
durable report captures therefore remained the only local RED/GREEN record.
The retry did not rerun RED. It created current-session structured receipts for
the current source and test bytes, and the focused GREEN and phase-relevance
captures reproduced their durable hashes exactly.

### Registry-consumption interpretation

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The inspected production diff sets the classifier registry
path to `bubbles/workflows/modes.yaml`, reads `.modes.phaseRelevance`, and applies
its schema, rules, `neverSkip`, and re-evaluation triggers. The current-byte
focused receipt includes that registry and both changed scripts in its hashed
input closure. Its canonical, malformed, unknown-phase, and `neverSkip`
assertions all passed. This combination supports the registry-read claim, but
the conclusion still joins source inspection with executed behavior and is
therefore classified conservatively for independent review.

### Current-byte receipt inventory

| Receipt | Exit | Input or output identity |
| --- | ---: | --- |
| Focused BUG-047 GREEN | 0 | guard `1a64b3a1944132bff026e8eb3fa1b8b0c4831372e9b6bf9ab21a9eae4f03959f`; selftest `16291be9cdbb6cc26abd056d7eb357f624fdd6760c9dfb4b64db8a3e917d7138`; capture `ba836636cfcd57d8859a41880ac2fc233f68798b949e2ae24fd732861ac7c4f2` |
| Phase-relevance regression | 0 | same guard/selftest input closure; capture `e81405945f4de19909dde7688529dbd4e30346790d77704628980125cf8cf820` |
| Guard shell syntax | 0 | input closure `1a64b3a1944132bff026e8eb3fa1b8b0c4831372e9b6bf9ab21a9eae4f03959f` |
| Selftest shell syntax | 0 | input closure `16291be9cdbb6cc26abd056d7eb357f624fdd6760c9dfb4b64db8a3e917d7138` |
| Release-manifest generation | 0 | stdout hash `4815d540e941642607988ec417f5b86c003e9bbfb8f02ab8bdcbdc3caf61449a` |
| Release-manifest `--check` | 0 | stdout hash `229c480c967b4984a879ab6b9c6442cf009bffecec8f15483ed4fec3ab097a73` |
| Boundary and protected-byte integrity | 0 | capture `5f3489db1e33a1e3a50de4509f4830454ed394367cbdd81eba097af87bddfecc` |
| Canonical packet artifact lint | 0 | capture `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567` |
| Implementation reality scan | 0 | capture `a0033397f6c850fb3c330ed3cca69325a237225c3ad2d139dd43213602814673`; zero violations and one design-fallback discovery warning |
| Execution-substate guard | 0 | `implemented` is valid and remains distinct from certification |
| Implement Tier 1/Tier 2 reconciliation | 0 | capture `ed198ce9dfaeb3295211c8e89f44bb269d802aac933afb5d37d465291d67f1ca`; 9 checked, 2 uncertainty declarations, no local full-framework receipt |

Every receipt above is in `.specify/runtime/tool-calls.jsonl` with session ID
`vscode-ca550392296c4e9fbb4b44ea5a0e4b60`, agent `bubbles.implement`, spec
`BUG-047-reasoned-skip-phase-accounting`, and scope
`01-canonical-reasoned-skip-accounting`.

### Source, manifest, boundary, and protected-packet proof

**Executed:** YES (in current session)
**Phase:** implement
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-047 HOST-101 integrity boundary and protected packets" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 /opt/homebrew/bin/bash /private/tmp/bug047-recovery-integrity-ca550392.sh /private/tmp/bubbles-ozhiva-transition-unblock-ca550392`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
# BUG-047 HOST-101 integrity boundary and protected packets
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 /opt/homebrew/bin/bash /private/tmp/bug047-recovery-integrity-ca550392.sh /private/tmp/bubbles-ozhiva-transition-unblock-ca550392
exit: 0
lines: 49
sha256: 5f3489db1e33a1e3a50de4509f4830454ed394367cbdd81eba097af87bddfecc
--- first 20 ---
BUG047_RECOVERY_INTEGRITY_BEGIN
IDENTITY_OK path=bubbles/scripts/state-transition-guard.sh sha256=1a64b3a1944132bff026e8eb3fa1b8b0c4831372e9b6bf9ab21a9eae4f03959f object=fcd5a4046d462ec7bf4c8dcffadf88b1673cf9de
IDENTITY_OK path=bubbles/scripts/state-transition-guard-selftest.sh sha256=16291be9cdbb6cc26abd056d7eb357f624fdd6760c9dfb4b64db8a3e917d7138 object=dc2154d545739449ef3f54c82a357773125a21d0
MANIFEST_ENTRY path=bubbles/scripts/state-transition-guard.sh sha256=1a64b3a1944132bff026e8eb3fa1b8b0c4831372e9b6bf9ab21a9eae4f03959f
MANIFEST_ENTRY path=bubbles/scripts/state-transition-guard-selftest.sh sha256=16291be9cdbb6cc26abd056d7eb357f624fdd6760c9dfb4b64db8a3e917d7138
BOUNDARY path=BUGS.md disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
BOUNDARY path=bubbles/release-manifest.json disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
BOUNDARY path=bubbles/scripts/state-transition-guard.sh disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
BOUNDARY path=bubbles/scripts/state-transition-guard-selftest.sh disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
BOUNDARY path=bugs/BUG-047-reasoned-skip-phase-accounting/report.md disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
BOUNDARY path=bugs/BUG-047-reasoned-skip-phase-accounting/scopes.md disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
BOUNDARY path=bugs/BUG-047-reasoned-skip-phase-accounting/state.json disposition=in-boundary; repoMatch=true; reason=candidate repo 'bubbles' is within repositoryRoots and within any declared spec/path scope
TRACKED_DELTA_BEGIN
BUGS.md
bubbles/release-manifest.json
bubbles/scripts/state-transition-guard-selftest.sh
bubbles/scripts/state-transition-guard.sh
TRACKED_DELTA_END
PROTECTED_PACKET_IDENTITIES_BEGIN
IDENTITY_OK path=bugs/BUG-048-test-plan-owner-label-path/bug.md sha256=b090b8e899f3155ed1e3ee1fd8b36ca4cefb119107aec605c1c95d56dda423f1 object=4deaed2f97d2b0b3ca2fd131d69172bc71cf87af
--- omitted 9 line(s); sha256 above covers the full output ---
--- last 20 ---
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/design.md sha256=898269e7282b98c4dcdb4e982d3297ee108754acc6682b2496c5f27d368aacde object=eb0630db4d4513a091fd6b12dae76ea87e28f8c7
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/report.md sha256=6214da6e4b7776226d16878860e4f9110039f586002b5bdc530f38eb08dea213 object=131c4efd3d39c4ff830bd0cc08efef4c881207ef
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/scenario-manifest.json sha256=51423ffb0ca0a6b158b9d1c1c3f1f3842a2bea8c228264a3cef07af54d3a7215 object=8c9a8a99af099a3540581d6a3dc241fa3712042f
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/scopes.md sha256=be0a2fa0c93fb7afdf48ff8b2a8a1bc665eb9dc9f85c0219b5df40b577d0ae8e object=cfa587c8b7d9abb3b2213fd3c0faa11117fd0ca1
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/spec.md sha256=dd08524fbe70b9968c1c29cdf2a6251fb5f2964ca6759cdd13876ba23554ab73 object=b19f8899f20b5bac632fa3fbcf1e8d2ad11a8014
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/state.json sha256=8839d87c1cf2d9cef7bd662e69d29d3542b23f53364349ad163bba2b383467bd object=08731d68e1c54ef0808fd75b623a34114ba13f0b
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/test-plan.json sha256=4dedc9fa817e5344401022a25e1252a08d666d7a8eb1753f2d5786eea78e7fe5 object=59d756eba8afa3dbcccaf38dc460c6fedb16dc11
IDENTITY_OK path=bugs/BUG-049-separate-process-g040-prefix/uservalidation.md sha256=7eac8bb7f5feea1534ef4265e74c4533d2e5995a4e046d11360ed5f7456241e6 object=15901f5ce4d315aceb18c685224e5bcccfbb181e
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/bug.md sha256=d14f994fb7fd280a1ed27d8efa62632d7d2e047c24d9d885200722f94e16aef1 object=540ef4517646f78572a98687c15eaa37701dbc58
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/design.md sha256=6e3a6f10d37a20f47ce08798c174a4243e5b4acba3d8c0d31215e7abd55a208d object=7a55cf52548f3717141cbaedfe8bdc2a44679e64
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/report.md sha256=ba6b26820544c2ce5e83d8bcaf1707e7a78e29b32311b9f943c519bbc914a8a9 object=c2660956b1f31464ee8a591de6cd62749b8a6e71
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/scenario-manifest.json sha256=ceb3d0f1f34281df3874a80d3f6fdefa83fa93a4f547039fe81716716d0448a8 object=9879e3fa1245eda27c4c46742867374f5ee67ad0
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/scopes.md sha256=0b857d3e379f19426fdbd6ff37424b0e507229b3d0ded4b7d815feef6deb610f object=5d313d9d01575d9169710de1179172fbf23b12a2
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/spec.md sha256=642a750762454aebeabd8576734ba7da4e6935965bcaa742792b364fef282c9d object=82934a23980b0c5470f982413f7e848d0cb97847
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/state.json sha256=1931a02b4a33c7d2d5f094767a513cb666477dc5a760d7ff5492533d7fe0fc33 object=2bd46a9554b065c596a710d32d996c4aa89e9483
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/test-plan.json sha256=dfb9e64e311374c54c58429555cd2e955586344ce380cff9f8cb75c8d8038ec4 object=998890135be96a9c382c3f238312d084c766816d
IDENTITY_OK path=bugs/BUG-050-transition-local-receipt-admission/uservalidation.md sha256=2c1292a339b88461813ea49cc6982cbe6c16b4ad62b4b685282d537250c2b4e9 object=915379aab661fe1688320dab05d2c2bccf72fca9
PROTECTED_PACKET_IDENTITIES_END
DIFF_CHECK_OK
BUG047_RECOVERY_INTEGRITY_OK
```

## Code Diff Evidence

The exact production and selftest diff was inspected before reconciliation.
The tracked delta contains only `BUGS.md`, the generated release manifest, the
guard, and its selftest. The retry changed only the BUG-047 report, scopes,
state, and the stale generated manifest. The protected BUG-048, BUG-049, and
BUG-050 packet identities match their pre-reconciliation SHA-256 and Git object
IDs. No protected packet file changed.

## Validation Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run.

## Chaos Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.chaos
**Claim Source:** not-run

Chaos validation is not part of filing and has not run.

## Independent Test Verification And Aggregate Failure Isolation

### Test Verdict

**Phase:** test
**Claim Source:** executed

The independent scenario and guard receipts cover Test Plan rows T1 through T5.
The complete T6 command exited 1. T6 remains uncredited.

| Test Plan row | Result | Structured receipt |
| --- | --- | --- |
| T1-T4 | PASS | `.specify/runtime/tool-calls.jsonl` row 18, exit 0, plus row 28 for the complete transition-guard selftest |
| T5 | PASS | `.specify/runtime/tool-calls.jsonl` row 19, exit 0 |
| T6 | FAIL | `.specify/runtime/tool-calls.jsonl` row 29, exit 1, duration 3,965,696 ms |
| T6 core diagnostic | PASS | row 30, exit 0, 16 checks executed and 332 skips reported |
| Guard-consumer closure | PASS | row 31, exit 0, eight adjacent regressions |
| Live-check isolation | FAIL | rows 35-36 identify the live G125 check |
| Baseline and boundary classification | PASS | row 37, exit 0 |

The tested source identities remain:

- `bubbles/scripts/state-transition-guard.sh`: `1a64b3a1944132bff026e8eb3fa1b8b0c4831372e9b6bf9ab21a9eae4f03959f`
- `bubbles/scripts/state-transition-guard-selftest.sh`: `16291be9cdbb6cc26abd056d7eb357f624fdd6760c9dfb4b64db8a3e917d7138`

### Canonical Core-Tier Diagnostic

**Executed:** YES (in current session)
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=30s 2100 /opt/homebrew/bin/bash bubbles/scripts/cli.sh framework-validate --tier=core`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
# BUG-047 canonical core-tier framework validation diagnosis
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=30s 2100 /opt/homebrew/bin/bash bubbles/scripts/cli.sh framework-validate --tier=core
exit: 0
lines: 1164
sha256: cb11ff6d9654824bcc6ea7ad6f3c0d2456b64ca52acb308bec81d953b9eabc00
--- first 20 ---
Bubbles Framework Validation
Repository: /private/tmp/bubbles-ozhiva-transition-unblock-ca550392
Install mode: source

==> Repository drift report (informational)
# Repository Drift Report

Generated: 2026-09-01T15:46:15Z
Repo root: /private/tmp/bubbles-ozhiva-transition-unblock-ca550392
--- omitted 1124 line(s); sha256 above covers the full output ---
--- last 20 ---
==> Release manifest freshness
Release manifest is current: 7.28.0 (927 managed files)
PASS: Release manifest freshness

Wall clock: 133s across 16 executed check(s).
Framework validation passed (332 skipped: 330 tier=core, 2 denylisted).
Framework validation passed.
```

The core tier proves structural registry, shell-lint, and manifest checks. It
does not replace T6 because the command registry requires the full default tier.

### Full-Tier Failure Receipt

**Executed:** YES (in current session)
**Phase:** test
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label BUG-047 independent full framework validation isolated scratch -- /opt/homebrew/bin/bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 1
**Claim Source:** executed
**Result:** FAIL

The append-only receipt is row 29 in `.specify/runtime/tool-calls.jsonl`.
It records timestamp `2026-09-01T10:33:50Z`, duration `3965696` ms,
stdout hash `48193773279a971e0a5c5d1d001f04f309d3275bf92cc3c7b43193873e3dd285`,
and `3270` stdout bytes. The retired terminal retained no output body.
This report does not infer missing failed-check labels from that absent body.

### Reproduced Blocking Check

**Executed:** YES (in current session)
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash bubbles/scripts/framework-health-evidence-lint.sh --repo-root /private/tmp/bubbles-ozhiva-transition-unblock-ca550392`
**Exit Code:** 1
**Claim Source:** executed
**Result:** FAIL

```text
# BUG-047 exact framework-health evidence live lint
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash bubbles/scripts/framework-health-evidence-lint.sh --repo-root /private/tmp/bubbles-ozhiva-transition-unblock-ca550392
exit: 1
lines: 3
sha256: 0d76a0f1100890e9bd916c6a2371cab48414bf5f0ec3c62e4be9d345b30cc8bb
--- output ---
FINDING: index-row-missing: improvements/IMP-054-hybrid-evidence-research-runtime.md has no row in improvements/INDEX.md
FINDING: index-row-missing: improvements/IMP-055-measured-budget-and-session-epoch-runtime.md has no row in improvements/INDEX.md
[framework-health-evidence-lint] FAIL — G125 findings: 2
```

The full validator always schedules this live check. Its nonzero result is a
current-byte blocking cause for the aggregate exit 1.

### Baseline And Work-Boundary Classification

**Executed:** YES (in current session)
**Phase:** test
**Command:** Exact `bash -c` command body retained in `.specify/runtime/tool-calls.jsonl` row 37.
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS

```text
HEAD=830883fd5639ac066cb3d40a2a40a567cc3df22f
ORIGIN_MAIN=830883fd5639ac066cb3d40a2a40a567cc3df22f
BASELINE_HEAD_EQUALS_ORIGIN_MAIN=true
BASELINE_PATH_STATUS_EXIT=0
BASELINE_PATH_DIFF_EXIT=0 expected=0
HEAD_PATH_EXISTS path=improvements/IMP-054-hybrid-evidence-research-runtime.md exit=0
HEAD_PATH_EXISTS path=improvements/IMP-055-measured-budget-and-session-epoch-runtime.md exit=0
HEAD_INDEX_SEARCH id=IMP-054 exit=1 expected=1
HEAD_INDEX_SEARCH id=IMP-055 exit=1 expected=1
disposition=route-same-repo
repoMatch=true
reason=candidate path 'improvements/INDEX.md' is in-repo but outside the declared allowedPaths — file/route a finding rather than inline-fixing unrelated work
G125_SELFTEST_EXIT=0
BUG047_G125_CLASSIFICATION_FAILURES=0
```

The two missing rows are present on the origin/main baseline and unchanged in
this worktree. BUG-047 excludes all three improvement paths. The strict boundary
resolver classifies each path as `route-same-repo`.

### Finding Accounting

| Finding | Disposition | Owner |
| --- | --- | --- |
| `F-B047-AGGREGATE-ATTRIBUTION` | Addressed. Core, guard-consumer, and live-check probes localize a reproducible blocker to the live G125 check. | `bubbles.test` |
| `G125-INDEX-ROW-MISSING-IMP-054` | Unresolved. The proposal has no row in the framework-health index. | `bubbles.retro` |
| `G125-INDEX-ROW-MISSING-IMP-055` | Unresolved. The proposal has no row in the framework-health index. | `bubbles.retro` |

No BUG-047 implementation failure was reproduced. The test phase remains open
because `bugfix-fastlane` requires no pre-existing failing tests, and T6 requires
the complete source framework command to exit 0.
