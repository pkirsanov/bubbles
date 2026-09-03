# BUG-050 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Filed the repository-global receipt-adjudication defect.
- Grounded freshness, semantic admission, clone identity, RED, and mutation paths.
- Defined six positive and adversarial scenarios.
- Wired Check 43 freshness to the transition-local admitted projection.
- Preserved clone identity analysis on the same projection.

## Completion Statement

The filing packet remains complete as planning work. The bug remains
`in_progress`. This slice records focused RED and GREEN evidence for Check 43.
It does not claim broad validation, audit, certification, or Scope 1 completion.

## Test Evidence

### Filing posture

**Executed:** NO
**Phase:** bug
**Command:** not run by explicit filing-only instruction
**Exit Code:** not applicable
**Claim Source:** not-run

The implementation owner must capture all four transition admission RED cases
before modifying evidence selection or receipt identity code.

### Downstream diagnostic boundary

**Claim Source:** interpreted

The operator reports active Ozhiva receipts 319 through 329 as fresh, with no
active clone group. Older and unrelated history still blocks the transition.
Those counts guide the fixtures but are not current-session execution evidence.

## Scope 1 Implementation Evidence

### Check 43 admitted-view RED

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 /opt/homebrew/bin/bash bubbles/scripts/evidence-receipt-check-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Capture SHA-256:** `5c62df6db40724c3a466cf38fc0958e45e4594fd99cea42a2a220e5a58a1a302`

```text
Running evidence-receipt-check selftest...
PASS: T1 unchanged inputs → valid=1 stale=0 (exit 0)
PASS: T2 changed input (hash differs) → stale=1 (exit 0 non-strict)
PASS: T2b --strict with stale → exit 1
PASS: T3 --changed names the input → stale=1 (targeted invalidation)
PASS: T3b unrelated --changed file → valid=1 stale=0 (no over-invalidation)
PASS: T4 receipt without inputClosure → unknown=1 (conservative)
PASS: T5 missing --log → exit 2
PASS: T6 log not found → exit 2
PASS: T7 tool-log.sh records inputClosure with a 64-hex sha256
PASS: T7b tool-log receipt is valid against unchanged input
PASS: T8 --strict all-valid → exit 0
PASS: T9 fresh rerun supersedes stale receipt with the same evidence identity
PASS: T10 fresh receipt in another scope does not supersede stale evidence
PASS: SCN-B050-002 admitted stale receipt remains blocking under strict freshness
PASS: SCN-B050-005 ordinary full-log freshness still reports the stale RED closure
PASS: SCN-B050-005 admitted historical RED survives current-byte drift after matching IMPLEMENT
FAIL: SCN-B050-001 Check 43 must pass one transition-admitted projection to freshness and clone consumers

evidence-receipt-check-selftest FAILED with 1 issue(s).
```

### Check 43 admitted-view GREEN

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 /opt/homebrew/bin/bash bubbles/scripts/evidence-receipt-check-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Capture SHA-256:** `3ac93fed4736fc0f424265557746dc3699dc1cb2673e714bad57239ee14a588d`

```text
Running evidence-receipt-check selftest...
PASS: T1 unchanged inputs → valid=1 stale=0 (exit 0)
PASS: T2 changed input (hash differs) → stale=1 (exit 0 non-strict)
PASS: T2b --strict with stale → exit 1
PASS: T3 --changed names the input → stale=1 (targeted invalidation)
PASS: T3b unrelated --changed file → valid=1 stale=0 (no over-invalidation)
PASS: T4 receipt without inputClosure → unknown=1 (conservative)
PASS: T5 missing --log → exit 2
PASS: T6 log not found → exit 2
PASS: T7 tool-log.sh records inputClosure with a 64-hex sha256
PASS: T7b tool-log receipt is valid against unchanged input
PASS: T8 --strict all-valid → exit 0
PASS: T9 fresh rerun supersedes stale receipt with the same evidence identity
PASS: T10 fresh receipt in another scope does not supersede stale evidence
PASS: SCN-B050-002 admitted stale receipt remains blocking under strict freshness
PASS: SCN-B050-005 ordinary full-log freshness still reports the stale RED closure
PASS: SCN-B050-005 admitted historical RED survives current-byte drift after matching IMPLEMENT
PASS: SCN-B050-001 Check 43 shares transition-admitted receipts across freshness and clone consumers

evidence-receipt-check-selftest: all cases passed.
```

### Admission bridge canary

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 /opt/homebrew/bin/bash bubbles/scripts/evidence-tool-log-bridge-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Capture SHA-256:** `bc1e6c4949e022105c671fe4b23c1298caf1e99588f509357491081c83d9cf32`

```text
PASS: 1. text mode with no log reports advisory
PASS: 2. json mode with no log returns logPresent:false envelope
PASS: 3. text mode with matching log reports non-zero coverage
PASS: 4+5. json mode returns structured matches[] envelope with valid coverage stats
PASS: BUG-050 T7 admitted-jsonl exposes the two semantically admitted full receipts only
PASS: 6. unknown --format value rejected with non-zero exit
PASS: 7. missing spec dir rejected with non-zero exit
PASS: 8. MCP tool catalog query_tool_log.json wires --format=json
evidence-tool-log-bridge-selftest: PASS
```

### Admitted clone identity GREEN

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 90 /opt/homebrew/bin/bash bubbles/scripts/receipt-identity-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Capture SHA-256:** `27e082390313c29cbb9f56f94c165252fc157bf6c94e4d7d5404fbb95d5fce47`

```text
PASS: SCN-B050-003 unrelated incompatible clone history is excluded from the admitted projection
PASS: SCN-B050-004 admitted incompatible clone remains refused by the BUG-033 identity program
PASS: SCN-B050-004 clone diagnostic preserves BUG-033 program and category identity detail
PASS: facet 1: 9 honest re-runs of one validator over 2 targets are not reported as cloned evidence
PASS: facet 1: the re-run group is accepted through the deterministic-sibling path, not by an empty analysis
PASS: facet 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: facet 2: 'node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'env PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'zsh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'PAGE=alpha node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'bash -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: 'sh -c node scripts/check-page.mjs alpha' normalizes to command_family=node
PASS: facet 2: five wrapper spellings of one command over one target are not reported as cloned evidence
PASS: facet 2 bound: two different programs behind identical wrappers are still refused
PASS: facet 2 bound: the diagnostic names the unwrapped cargo and npm identities
PASS: BUG-007 pin: empty stdout stays exempt after the BUG-033 relaxation
PASS: BUG-032 pin: a collision with no independent execution provenance is still refused
PASS: BUG-032 pin: incompatible command families sharing one stdout are still refused
PASS: BUG-028 defect 1: one command tagged test and validate is not reported as cloned evidence
PASS: BUG-028 defect 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: BUG-028 bound: a group mixing two specs on one stdout is still refused
PASS: BUG-028 canonical: one validator over three subjects with differing tags is not reported as cloned evidence
PASS: BUG-028 canonical: the three-subject group is accepted through the deterministic-sibling path

receipt-identity-selftest: 23 passed, 0 failed
```

### Actionable static validation

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 60 /bin/zsh -f /dev/fd/3`
**Exit Code:** 0
**Claim Source:** executed
**Capture SHA-256:** `1bcbfccec1d8a25ecfcb8aee6cabf2fe4b71cbbb2e8fbe2f9b03ff4bdc32b7b5`

```text
BUG050_STATIC_VALIDATION_BEGIN
BASH_N_EXIT=0
TEST_SHELLCHECK_EXIT=0
GUARD_SHELLCHECK_WARNING_EXIT=0
GIT_DIFF_CHECK_EXIT=0
BUG050_STATIC_VALIDATION_END
```

The broad state-transition selftest attempt timed out before BUG-050. It exited
124 after 1,082 lines. Its capture SHA-256 is
`ad202d70d4d06d3ab601f1a24e1799a124bba113ddd65b287818a63898f183d4`.
It exposed six G057 fixture failures and provides no BUG-050 verdict.

## Code Diff Evidence

Commit `511d63efe89fcb20988f3d97a2a2fa0162f3128b` changes only the Check 43
guard path and its focused receipt selftest. The normal push updated
`origin/fix/ozhiva-transition-unblock` to the same SHA.

## Uncertainty Declarations

### T1 transition-guard regression

**Executed:** NO completed current-source result recorded
**Command:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
**Test File:** `bubbles/scripts/state-transition-guard-selftest.sh`
**Claim Source:** not-run

The recorded broad attempt exited 124 before BUG-050. The independent T1 run
has no completed result recorded in this packet.

### T5 ordered scenario-state proof

**Executed:** NO
**Command:** `bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Test File:** `bubbles/scripts/scenario-state-resolve-selftest.sh`
**Claim Source:** not-run

No completed T5 resolver result is recorded in this packet.

### T6 historical mutation proof

**Executed:** NO
**Command:** `bash bubbles/scripts/mutation-receipt-selftest.sh`
**Test File:** `bubbles/scripts/mutation-receipt-selftest.sh`
**Claim Source:** not-run

No completed T6 mutation result is recorded in this packet.

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
