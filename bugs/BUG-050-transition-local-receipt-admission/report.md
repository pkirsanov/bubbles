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

## Independent Test Evidence - Convergence Iteration 2

All executions in this section ran on source revision
`bb77d66ce5758d0c37827b250f1f7d4ebeeebc15`. T3, T4, and T8 intentionally
share one execution of `receipt-identity-selftest.sh`, as allowed by the Test
Plan. T9 did not run in this phase.

### Iteration 2 T1 SCN-B050-001

**Executed:** YES
**Phase:** test
**Command:** `/usr/bin/env BUBBLES_STATE_TRANSITION_GUARD_BUG050_ONLY=1 /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Output Lines:** 8
**Capture SHA-256:** `9e36cc1dad55a8adfafc6f5a31c8026757f15d8145b06a1c99e08f23c9963d12`
**Tool-Log Receipt:** row 402, stdout SHA-256 `3c22c455eb637a7c55ee4e97e9a63abead5902cd8c120805d0d4e03cc0508cbf`
**Input Closure:** 7 paths, 0 missing
**Claim Source:** executed

```text
PASS: TRANSITION_GUARD_RESULT_V1 emitter field order matches this suite's expectation
Running BUG-050 Check 43 transition-local stale-history admission...
PASS: SCN-B050-001 unrelated stale history does not block the active transition
PASS: SCN-B050-001 Check 43 evaluates the admitted fresh receipt
PASS: SCN-B050-001 Check 43 does not adjudicate unrelated stale history
PASS: SCN-B050-001 raw append-only history remains present and byte-identical
----------------------------------------
state-transition-guard BUG-050 selftest passed.
```

### Iteration 2 T2 SCN-B050-002

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 240 /opt/homebrew/bin/bash bubbles/scripts/evidence-receipt-check-selftest.sh`
**Exit Code:** 0
**Output Lines:** 20
**Capture SHA-256:** `3ac93fed4736fc0f424265557746dc3699dc1cb2673e714bad57239ee14a588d`
**Tool-Log Receipt:** row 403, stdout SHA-256 `cc30e91cf7591ce954c2badb202da185e5ee30ce993e326893e0b3543239697a`
**Input Closure:** 6 paths, 0 missing
**Claim Source:** executed

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

### Iteration 2 T3 T4 T8 Receipt Identity

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 360 /opt/homebrew/bin/bash bubbles/scripts/receipt-identity-selftest.sh`
**Exit Code:** 0
**Output Lines:** 77
**Capture SHA-256:** `70821dc1e5b7caf1c048c5688d18345fe70bc190545e3e2aef3d12e82e3dfb19`
**Tool-Log Receipt:** row 404, stdout SHA-256 `ba6ba7111d278fca77eb871dd4b4411784d832a8e538a2ca950dfa7528879c8a`
**Receipt Mapping Tags:** `test:T3`, `test:T4`, `test:T8`, `scenario:SCN-B050-003`, `scenario:SCN-B050-004`, `scenario:Aggregate`
**Input Closure:** 6 paths, 0 missing
**Claim Source:** executed

```text
PASS: SCN-B050-003 unrelated incompatible clone history is excluded from the admitted projection
PASS: SCN-B050-004 admitted incompatible clone remains refused by the BUG-033 identity program
PASS: SCN-B050-004 clone diagnostic preserves BUG-033 program and category identity detail
PASS: facet 1: 9 honest re-runs of one validator over 2 targets are not reported as cloned evidence
PASS: facet 1 bound: two identities sharing ONE target and one stdout are still refused
PASS: facet 2 bound: two different programs behind identical wrappers are still refused
PASS: BUG-007 pin: empty stdout stays exempt after the BUG-033 relaxation
PASS: BUG-032 pin: a collision with no independent execution provenance is still refused
PASS: BUG-032 pin: incompatible command families sharing one stdout are still refused
PASS: BUG-028 bound: a group mixing two specs on one stdout is still refused
PASS: BUG-028 canonical: the three-subject group is accepted through the deterministic-sibling path

receipt-identity-selftest: 75 passed, 0 failed
```

The displayed lines are the BUG-050 and inherited identity verdicts from the
77-line bounded capture. The capture hash authenticates the complete stream.

### Iteration 2 T5 SCN-B050-005

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 360 /opt/homebrew/bin/bash bubbles/scripts/scenario-state-resolve-selftest.sh`
**Exit Code:** 0
**Output Lines:** 42
**Capture SHA-256:** `32dfc23273cb0ab12e8003be67be26499b0302a9a4f8786a9153652658b871f4`
**Tool-Log Receipt:** row 405, stdout SHA-256 `eb9b89493224728481422e913c8f7554359b963dd690e3a1a8f017ecb55b28ee`
**Input Closure:** 6 paths, 0 missing
**Claim Source:** executed

```text
PASS: lifecycle: a failing red receipt derives RED_VERIFIED
PASS: lifecycle: an implement receipt after red derives IMPLEMENTED
PASS: lifecycle: a same-scenario same-control green derives GREEN_TARGETED
PASS: source-revision drift is reported but does not block
PASS: drift-only evidence still fails certification via unsatisfied
PASS: SCN-B050-005 historical RED plus current implement/GREEN derives the ordered proof chain
PASS: SCN-B050-005 stale post-fix GREEN stays excluded while historical RED remains valid
PASS: certifiability is refused while a required scenario state does not hold
PASS: certifiability holds when every required scenario state is receipt-derived
PASS: rollback: advancement stops, and all 6 receipts are preserved and still counted

scenario-state-resolve-selftest: 40 passed, 0 failed
```

The displayed lines are the ordering and fail-closed verdicts from the 42-line
bounded capture. The capture hash authenticates the complete stream.

### Iteration 2 T6 SCN-B050-006

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 420 /opt/homebrew/bin/bash bubbles/scripts/mutation-receipt-selftest.sh`
**Exit Code:** 0
**Output Lines:** 63
**Capture SHA-256:** `eabed31186a75fdca4661fb61f4df17b84d9737122c8b881be048db208ca52d3`
**Tool-Log Receipt:** row 406, stdout SHA-256 `8b8bf4138963788103523bb1cc1afc336779f98a1c402eed8a5bebe37414c483`
**Input Closure:** 5 paths, 0 missing
**Claim Source:** executed

```text
PASS: P1 a killed mutant exits 0
PASS: P1 the mutant digest differs from the source
PASS: P1 the observed failure carries the expectation
PASS: P2 ISOLATION: the repository source is byte-identical after the run
PASS: P2 the receipt's restoredDigest equals its sourceDigest
PASS: SCN-B050-006 later production bytes are distinct from the captured mutation source
PASS: SCN-B050-006 earned historical kill survives a later production edit
PASS: SCN-B050-006/A4 a receipt whose restoredDigest != sourceDigest is refused
PASS: SCN-B050-006/A4 the left-behind mutant is named
PASS: A7 the source was never touched
PASS: U1 a bypass flag is rejected by name on check

mutation-receipt-selftest: 61 passed, 0 failed
```

The displayed lines are the restoration and historical-proof verdicts from the
63-line bounded capture. The capture hash authenticates the complete stream.

### Iteration 2 T7 Admission Bridge Canary

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 240 /opt/homebrew/bin/bash bubbles/scripts/evidence-tool-log-bridge-selftest.sh`
**Exit Code:** 0
**Output Lines:** 9
**Capture SHA-256:** `bc1e6c4949e022105c671fe4b23c1298caf1e99588f509357491081c83d9cf32`
**Tool-Log Receipt:** row 407, stdout SHA-256 `93622bdfede2332952098f70f171d77f9c9e913c66414c02bc0018315349abb8`
**Input Closure:** 6 paths, 0 missing
**Claim Source:** executed

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

### Iteration 2 Test Integrity And Planning Checks

**Executed:** YES
**Phase:** test
**Claim Source:** executed

| Check | Receipt | Exit | Captured Result |
| --- | ---: | ---: | --- |
| Linked test resolution | 401 | 0 | 6 references resolved; stdout `2d76bee7bca6750a272860cf32fcc52b388108b2a00c14495366559c61cc5cb1` |
| Bash syntax, bounded skip scan, live-row query | 409 | 0 | 6 scripts parse; 0 skip markers; 0 live-system rows; capture `8c6e2f0dbed6d65b7bb195e86201406c55f7e4ea705157c4b72c2ecf33954860` |
| Selected ShellCheck at warning severity | 417 | 0 | Empty stdout paired with exit 0; stdout `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| Bug-fix regression quality | 411 | 0 | 6 files, 0 violations, 0 warnings; capture `48865d05e14edd84f634a731b774ea80005217be0e28c0f5543121e4ebe92b52` |
| Test mechanism lint | 412 | 0 | 6 mechanisms coherent; capture `40ac3a256b70700d23e448ca6e828a0aaab915978b6c739b2ffacd14e4f1239c` |
| Scenario obligation lint | 413 | 0 | 6 coherent scenario matrices; capture `706c8279200ad9aa503bd258bb101880938f111815b7392fe0b67334c2c6bccc` |
| Pre-edit artifact lint | 414 | 0 | Artifact lint passed; capture `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567` |
| Post-edit authored traceability | 418 | 0 | 6 of 6 scenarios carry evidence refs; 6 scenarios map to 9 rows and 6 DoD items; capture `b347d15867a30babb1c4cc3d296f5997d82f45e80d87580e59bad89d1fa4ef7a` |
| Post-edit artifact lint | 419 | 0 | Artifact lint passed; capture `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567` |
| Post-edit linked test resolution | 420 | 0 | 6 references resolved; capture `2d76bee7bca6750a272860cf32fcc52b388108b2a00c14495366559c61cc5cb1` |

The first skip-marker scan used an overbroad `xit(` substring and matched three
embedded Python `SystemExit(` calls. Receipt 408 records that scanner false
positive. Receipt 409 is the corrected bounded scan; no source or test file was
changed between the two checks.

Pre-edit traceability receipt 415 exited 1 because all six `evidenceRefs` arrays
were empty. The test-owned manifest update added resolvable report anchors, and
receipt 418 passed the same authored traceability command with zero warnings.

**Self-Validating Test Audit:** 6 linked tests reviewed; 0 self-validating tests
identified.
**Claim Source:** interpreted
**Interpretation:** Each BUG-050 assertion observes a result produced by a
shipping script or the Check 43 program extracted from the shipping guard. The
tests assert admission, refusal, ordering, restoration, or projection behavior,
not a fixture literal passed through unchanged. T1 independently hashes the raw
fixture log before and after the guard. T6 independently hashes restored source
bytes. Receipt 409 reports zero live-system rows, so a live-category mock audit
is not applicable to this functional-only Test Plan.

### Iteration 2 Repository-Wide ShellCheck Finding

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 600 /opt/homebrew/bin/bash bubbles/scripts/shellcheck-lint.sh --severity warning`
**Exit Code:** 1
**Capture SHA-256:** `321f01e16ed1bf0a0261443d7919635800f46b941b514e3c52433585ecea5739`
**Tool-Log Receipt:** row 410
**Boundary Classification Receipt:** row 416, capture SHA-256 `9f964e4bd751b25e19b2ef8f44f638c571218e0eddfaca147161b579ffe4959c`
**Claim Source:** executed

**Path-relative finding inventory:**

| Path | Location | Code | Diagnostic |
| --- | --- | --- | --- |
| `bubbles/adapters/dispatch/reference-broker.sh` | 76:3 | SC2034 | `argv appears unused. Verify use (or export if used externally).` |
| `bubbles/adapters/research/disabled.sh` | 4:21 | SC1007 | `Remove space after = if trying to assign a value (for empty string, use var='' ... ).` |
| `bubbles/adapters/research/local-command.sh` | 4:21 | SC1007 | `Remove space after = if trying to assign a value (for empty string, use var='' ... ).` |
| `bubbles/adapters/usage/reference-test.sh` | 14:1 | SC2034 | `EMPTY_DIGEST appears unused. Verify use (or export if used externally).` |
| `bubbles/scripts/release-train-metadata-assign-selftest.sh` | 11:1 | SC2034 | `ALIASES_FILE appears unused. Verify use (or export if used externally).` |
| `bubbles/scripts/release-train-metadata-assign-selftest.sh` | 14:1 | SC2034 | `OWNERSHIP_FILE appears unused. Verify use (or export if used externally).` |
| `bubbles/scripts/release-train-metadata-assign-selftest.sh` | 413:3 | SC2034 | `drift_before appears unused. Verify use (or export if used externally).` |
| `bubbles/scripts/research-run.sh` | 4:21 | SC1007 | `Remove space after = if trying to assign a value (for empty string, use var='' ... ).` |
| `bubbles/scripts/scenario-manifest-migrate-selftest.sh` | 619:45 | SC1007 | `Remove space after = if trying to assign a value (for empty string, use var='' ... ).` |

The canonical summary was `shellcheck-lint: FAIL — 9 finding(s) at -S warning
across 605 script(s)`.

Strict work-boundary resolution classified all seven paths as
`route-same-repo`. None belongs to BUG-050's declared `allowedPaths`; no source
or test repair was made in this phase. The six BUG-050 linked tests pass direct
ShellCheck at warning severity under receipt 417.

### Iteration 2 DoD Evidence Ownership Handoff

Current execution directly supports SCN-B050-001 through SCN-B050-006, the
shared admission canary, persistent scenario-specific regression coverage, and
the inherited receipt-identity regression set. `scopes.md` checkbox changes are
not owned by `bubbles.test` in `bubbles/agent-ownership.yaml`, so this phase did
not change any checkbox or scope status. `state.json` certification fields are
validate-owned and also remain unchanged. T9, the full framework suite,
validation, audit, certification, release-manifest completion, and terminal
status remain open.

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
