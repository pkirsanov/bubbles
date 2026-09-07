# BUG-043 Report

## Summary

- Created a complete source bug packet for `F-B019002-REG-B05`.
- Preserved the operator-supplied interpreter mismatch as diagnostic input.
- Confirmed the parser origin and selected the two-character repair design.
- Reconciled the scope, structured test plan, scenario manifest, and DoD.
- Preserved the exact minimal delivery and propagation boundaries.
- Left implementation, testing, audit, and certification unclaimed.

Related planning: [scopes.md](scopes.md). Human acceptance remains in
[uservalidation.md](uservalidation.md).

## Completion Statement

BUG-043 remains `in_progress`. The root cause and repair design are confirmed.
Planning now encodes the exact quote-restoration mutant and source-derived
sentinel matrix.

This invocation edits planning-owned artifacts and execution bookkeeping only.
It does not edit production source, tests, registries, generated files, docs,
other bugs, downstream repositories, or live state.

The packet routes to `bubbles.test` for scenario-first RED evidence before any
production mutation.

## Test Evidence

### Operator-Supplied Reproduction

**Claim Source:** not-run
**Command:** `/bin/bash -n bubbles/scripts/state-transition-guard.sh`
**Exit Code:** 2, as supplied by the operator

The operator reported a parser error at line 4016 on the frozen baseline. The
packet author did not execute this behavior command.

**Claim Source:** not-run
**Command:** `/opt/homebrew/bin/bash -n bubbles/scripts/state-transition-guard.sh`
**Exit Code:** 0, as supplied by the operator

The operator reported successful Bash 5 syntax validation on the same baseline.
The packet author did not execute this behavior command.

The exact Bash 3 stderr was not included in the request. No message text has
been reconstructed or inferred.

### Filing-Phase Source Inspection

**Claim Source:** interpreted

**Interpretation:** Filing-phase reads showed that line 4016 was a quoted Check
16 heading. That filing observation supported reduction work but did not
identify the root cause. The later design evidence does identify it.

No test or behavior command was run by this filing.

## Code Diff Evidence

The initial filing authorized packet files only. The reconciled delivery
boundary now permits the exact paths listed in [scopes.md](scopes.md).

This planning invocation changes only packet artifacts and execution
bookkeeping. It changes no production, test, registry, generated,
documentation, downstream, or live-state path.

## Validation Evidence

No terminal transition is requested. Packet-shape validation does not certify
the reported behavior or satisfy any delivery DoD item.

### Design-Phase Artifact Validation

**Claim Source:** executed

The reconciled design tree passed nine checks before this receipt was appended.
This result validates planning artifacts only and does not certify delivery.

```text
# BUG-043 corrected design-phase validation
exit: 0
lines: 104
sha256: ca6c543e96ccfcfe2182e20696cba84e2516d2eab3a75eb15c87535c4b289587
CHECK_RESULT=state-json exit=0
CHECK_RESULT=scenario-json exit=0
CHECK_RESULT=artifact-lint exit=0
CHECK_RESULT=artifact-freshness exit=0
CHECK_RESULT=capability-foundation exit=0
CHECK_RESULT=reference-existence exit=0
CHECK_RESULT=technical-prose exit=0
CHECK_RESULT=claim-source exit=0
CHECK_RESULT=tracked-diff-check exit=0
DESIGN_VALIDATION_CHECKS=9
DESIGN_VALIDATION_FAILURES=0
```

## Audit Evidence

No delivery audit is claimed. The packet remains open for scenario-first test
execution and the minimal source repair.

## Chaos Evidence

No chaos result is claimed. The parser defect has no chaos execution in this
filing.

## Invocation Audit

No subagent result is claimed by this planning invocation. The packet routes
the next owned action to `bubbles.test`.

## Design Root-Cause Investigation - 2026-08-31

This section records diagnostic design evidence only.
It does not satisfy a delivery DoD item or claim a source repair.

### Origin-Matching Parser Reproduction

**Claim Source:** executed

The command compared both real interpreters against one origin-matching file.

```text
BUG043_DUAL_PARSER_REPRO_BEGIN
1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0  bubbles/scripts/state-transition-guard.sh
GNU bash, version 3.2.57(1)-release (arm64-apple-darwin25)
Copyright (C) 2007 Free Software Foundation, Inc.
bubbles/scripts/state-transition-guard.sh: line 4016: syntax error near unexpected token `('
bubbles/scripts/state-transition-guard.sh: line 4016: `echo "--- Check 16: Implementation Reality Scan (Gate G028) ---"'
BASH3_PARSE_EXIT=2
GNU bash, version 5.3.15(1)-release (aarch64-apple-darwin25.4.0)
Copyright (C) 2025 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
BASH5_PARSE_EXIT=0
BUG043_DUAL_PARSER_REPRO_END
```

### Earliest Complete-Unit Failure

**Claim Source:** executed

The cumulative matrix stopped only at complete top-level check boundaries.

```text
PREFIX_RESULT end=2259 bash3=0 bash5=0
PREFIX_RESULT end=2326 bash3=0 bash5=0
PREFIX_RESULT end=2642 bash3=0 bash5=0
PREFIX_RESULT end=2714 bash3=0 bash5=0
/bin/bash: line 2832: unexpected EOF while looking for matching `''
/bin/bash: line 2833: syntax error: unexpected end of file
PREFIX_RESULT end=2831 bash3=2 bash5=0
/bin/bash: line 3018: unexpected EOF while looking for matching `''
/bin/bash: line 3019: syntax error: unexpected end of file
PREFIX_RESULT end=3017 bash3=2 bash5=0
/bin/bash: line 3025: unexpected EOF while looking for matching `''
/bin/bash: line 3026: syntax error: unexpected end of file
PREFIX_RESULT end=3024 bash3=2 bash5=0
BUG043_EARLY_COMPLETE_PREFIX_MATRIX_END
```

Check 7C is the first complete region added between the passing and failing prefixes.
It also fails as an independent complete shell unit under Bash 3.2.

### Earliest Token Isolation

**Claim Source:** executed

The heredoc-body prefix passed through baseline line 2755.
Adding baseline line 2756 introduced the unmatched-quote result.

```text
BODY_PREFIX_RESULT cutoff=2753 bash3=0
BODY_PREFIX_RESULT cutoff=2754 bash3=0
BODY_PREFIX_RESULT cutoff=2755 bash3=0
/bin/bash: line 56: unexpected EOF while looking for matching `''
/bin/bash: line 71: syntax error: unexpected end of file
BODY_PREFIX_RESULT cutoff=2756 bash3=2
/bin/bash: line 57: unexpected EOF while looking for matching `''
/bin/bash: line 72: syntax error: unexpected end of file
BODY_PREFIX_RESULT cutoff=2757 bash3=2
BUG043_HEREDOC_FIRST_FAILURE_SCAN_END
```

The isolated line contains the apostrophe in `Check 6B's _phase_name`.
Removing only that apostrophe makes the complete isolated unit parse.

```text
BUG043_LINE2756_APOSTROPHE_PROOF_BEGIN
/bin/bash: line 29: unexpected EOF while looking for matching `''
/bin/bash: line 44: syntax error: unexpected end of file
APOSTROPHE_PROOF_RESULT variant=exact bash3=2 bash5=0
APOSTROPHE_PROOF_RESULT variant=apostrophe-removed bash3=0 bash5=0
BUG043_LINE2756_APOSTROPHE_PROOF_END
```

### Selected Two-Character Repair Probe

**Claim Source:** executed

The candidate removed only the outer quotes around the assignment command substitution.
The in-memory full-source stream retained every heredoc byte.

```text
BUG043_OUTER_QUOTE_FIX_PROOF_BEGIN
OUTER_QUOTE_FIX_RESULT bash3=0 bash5=0
BUG043_OUTER_QUOTE_FIX_PROOF_END
```

The Bash 5.3 assignment output remained byte-identical.

```text
BUG043_ASSIGNMENT_EQUIVALENCE_BEGIN
ORIGINAL_OUTPUT=ASSIGNMENT_VALUE=NO_CLAIMS=1
CANDIDATE_OUTPUT=ASSIGNMENT_VALUE=NO_CLAIMS=1
ASSIGNMENT_EQUIVALENCE_RESULT originalExit=0 candidateExit=0 outputsEqual=true
BUG043_ASSIGNMENT_EQUIVALENCE_END
```

### Introducing Revision Matrix

**Claim Source:** executed

Git blame resolves the offending line to
`5ea651a6dfdf519761a0a938d4e5d6fbf7a21fdc`.

```text
BUG043_INTRODUCING_REVISION_PARSE_MATRIX_BEGIN
REVISION_PARSE_RESULT revision=52317c2c1a62bdff9c4af1b5bbe62cdb0a1ae23d bash3=0 bash5=0
/bin/bash: line 3426: syntax error near unexpected token `('
/bin/bash: line 3426: `echo "--- Check 16: Implementation Reality Scan (Gate G028) ---"'
REVISION_PARSE_RESULT revision=5ea651a6dfdf519761a0a938d4e5d6fbf7a21fdc bash3=2 bash5=0
BUG043_INTRODUCING_REVISION_PARSE_MATRIX_END
```

### Sentinel Regression Prototype

**Claim Source:** executed

The candidate fixture uses the source-derived Check 7C assignment.
It places the sentinel after the exact former Check 16 recovery line.

```text
BUG043_SELECTED_FIX_SENTINEL_PROTOTYPE_BEGIN
SELECTED_FIX_OUTPUT_BEGIN mode=candidate interpreter=/bin/bash
--- Check 16: Implementation Reality Scan (Gate G028) ---
BUG043_SENTINEL_AFTER_FORMER_LINE_4016
SELECTED_FIX_OUTPUT_END mode=candidate interpreter=/bin/bash
SELECTED_FIX_RESULT mode=candidate interpreter=/bin/bash exit=0 sentinelCount=1
SELECTED_FIX_OUTPUT_BEGIN mode=candidate interpreter=/opt/homebrew/bin/bash
--- Check 16: Implementation Reality Scan (Gate G028) ---
BUG043_SENTINEL_AFTER_FORMER_LINE_4016
SELECTED_FIX_OUTPUT_END mode=candidate interpreter=/opt/homebrew/bin/bash
SELECTED_FIX_RESULT mode=candidate interpreter=/opt/homebrew/bin/bash exit=0 sentinelCount=1
SELECTED_FIX_OUTPUT_BEGIN mode=exact-mutant interpreter=/bin/bash
/bin/bash: line 83: unexpected EOF while looking for matching `''
/bin/bash: line 84: syntax error: unexpected end of file
SELECTED_FIX_OUTPUT_END mode=exact-mutant interpreter=/bin/bash
SELECTED_FIX_RESULT mode=exact-mutant interpreter=/bin/bash exit=2 sentinelCount=0
SELECTED_FIX_OUTPUT_BEGIN mode=exact-mutant interpreter=/opt/homebrew/bin/bash
--- Check 16: Implementation Reality Scan (Gate G028) ---
BUG043_SENTINEL_AFTER_FORMER_LINE_4016
SELECTED_FIX_OUTPUT_END mode=exact-mutant interpreter=/opt/homebrew/bin/bash
SELECTED_FIX_RESULT mode=exact-mutant interpreter=/opt/homebrew/bin/bash exit=0 sentinelCount=1
SELECTED_FIX_SENTINEL_FAILURES=0
BUG043_SELECTED_FIX_SENTINEL_PROTOTYPE_END
```

### Design Disposition

The root cause is confirmed.
The two-character quote-boundary repair is the selected implementation design.

The persistent regression remains unauthored.
Production source and tests remain unchanged in this phase.

The planning reconciliation is recorded below.

## Planning Reconciliation - 2026-08-31

This planning pass resolves `F-B043-PLAN-001` within planning-owned artifacts.
It changes no production source or test.

### Exact Defect and Mutation Contract

The defect is the redundant outer quoting around the Check 7C assignment
command substitution. The selected repair removes its opening and closing quote
characters. It preserves every Python heredoc byte and executable Check 7C
branch.

The adversarial mutant restores only those two quote characters. The mutation
must occur exactly once at each boundary. The mutant must preserve the
apostrophe in `Check 6B's _phase_name` and every executable heredoc byte.

### Source-Derived Sentinel Contract

The regression fixture must extract the complete Check 7C assignment and the
exact Check 16 heading from unique current-source anchors. It must append
`BUG043_SENTINEL_AFTER_FORMER_LINE_4016` after the heading.

The repaired fixture matrix requires parse exits `0/0` and sentinel counts
`1/1` for Bash 3.2 and Bash 5.3. The quote-restoration matrix requires parse
exits `2/0` and sentinel counts `0/1`.

### Structured Test Handoff

The plan now defines six test rows and six matching test-related DoD items.
`TP-01` is the first execution step. It must preserve the scenario-first RED
before production source changes.

`test-plan.json` mirrors the Markdown rows. `scenario-manifest.json` maps every
scenario to its planned tests, exact negative controls, live expectations, and
trait-derived obligations.

### Boundary and Routing

The delivery boundary permits only the transition guard, the two named
selftests, generator-produced release-manifest bytes, and this bug packet.
All registries, unrelated source, downstream working trees, and
`.bubbles-worktree` remain protected.

All delivery DoD items remain unchecked. Certification remains unchanged.
The current route is `bubbles.test` for the `TP-01` scenario-first RED.

## Scenario-First Test Phase - 2026-08-31

The persistent `TP-01` through `TP-03` regression now runs from the planned
Bash baseline selftest. Production source stayed on the frozen defect bytes.

The focused run produced one failure. `TP-01` observed production parser exits
`2/0` instead of the required `0/0`. The source-derived repaired fixture
produced parser exits `0/0`, execution exits `0/0`, and sentinel counts `1/1`.
The exact quote-restoration mutant produced parser exits `2/0`, execution exits
`2/0`, and sentinel counts `0/1`. The before and after production SHA-256 values
were identical.

### TP-01 Through TP-03 RED Receipt

**Phase:** test
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label 'BUG-043 final-test-bytes TP-01 through TP-03 scenario-first RED' -- /opt/homebrew/bin/bash bubbles/scripts/bash-baseline-guard-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
# BUG-043 final-test-bytes TP-01 through TP-03 scenario-first RED
$ /opt/homebrew/bin/bash bubbles/scripts/bash-baseline-guard-selftest.sh
exit: 1
lines: 79
sha256: 54484636f3fd18e5be374df2d14e58e91301ed16cb4b5aa6e64b9e97d07f1298
BUG043_INTERPRETER role=bash3 path=/bin/bash version=3.2.57(1)-release
BUG043_INTERPRETER role=bash5 path=/opt/homebrew/bin/bash version=5.3.15(1)-release
BUG043_PRODUCTION_SOURCE path=state-transition-guard.sh sha256=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0
BUG043_PARSE_RESULT mode=production interpreter=/bin/bash sourceSha256=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0 exit=2
/bin/bash: line 4016: syntax error near unexpected token `('
BUG043_PARSE_RESULT mode=production interpreter=/opt/homebrew/bin/bash sourceSha256=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0 exit=0
	FAIL: Regression: SCN-B043-001 repaired guard parses under real Bash 3 and Bash 5 on identical bytes: expected parse exits 0/0, observed 2/0
BUG043_FIXTURE_SOURCE_FORM=quoted
BUG043_FIXTURE_OPENING_ANCHOR_COUNT=1
BUG043_FIXTURE_CLOSING_ANCHOR_COUNT=1
BUG043_FIXTURE_HEADING_ANCHOR_COUNT=1
	PASS: Mutation: SCN-B043-002 exact outer-quote restoration recreates the parser divergence
BUG043_PRODUCTION_SOURCE_AFTER sha256=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0
	PASS: BUG-043 parser fixtures left canonical production source bytes unchanged
BUG043_MATRIX_SUMMARY productionParse=2/0 repairedParse=0/0 repairedExecution=0/0 repairedSentinel=1/1 mutantParse=2/0 mutantExecution=2/0 mutantSentinel=0/1
BUG043_SOURCE_INVARIANT before=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0 after=1f42f6d5a96a464fd622c2d39b341eed07967499a9fb4869b6752d13d75367b0 unchanged=true
bash-baseline-guard-selftest: 11 passed / 1 failed
```

No DoD checkbox or certification field changed. The discriminating RED and
passing harness controls route the two-character production repair to
`bubbles.implement`.

## Implementation Phase - 2026-08-31

The Check 7C assignment now omits only the redundant opening and closing outer
quotes. The source size changed from 243429 bytes to 243427 bytes. The exact
diff contains only the two planned assignment-line replacements. The heredoc
body and command substitution remain unchanged.

The persistent parser test, semantic selftest, generated release manifest, and
worktree marker retained their pre-edit SHA-256 values. This invocation did not
edit those paths.

### Dual-Parser Syntax and Static Boundary

**Phase:** implement
**Executed:** YES (current session)
**Commands:**

```bash
source_file=bubbles/scripts/state-transition-guard.sh
/bin/bash -n "$source_file"
/opt/homebrew/bin/bash -n "$source_file"
/opt/local/bin/git diff --check -- "$source_file"
/opt/local/bin/git diff --numstat -- "$source_file"
/usr/bin/shasum -a 256 "$source_file"
/opt/local/bin/git hash-object --no-filters -- "$source_file"
/usr/bin/stat -f %z "$source_file"
/opt/local/bin/git --no-pager diff --no-ext-diff --no-color --unified=0 -- "$source_file"
```

**Exit Code:** 0
**Claim Source:** executed

```text
BUG043_STATIC_RECEIPT_BEGIN
BASH3_SOURCE_SYNTAX_EXIT=0
BASH5_SOURCE_SYNTAX_EXIT=0
GIT_DIFF_CHECK_EXIT=0
SOURCE_NUMSTAT=2        2       bubbles/scripts/state-transition-guard.sh
SOURCE_SHA256=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d  bubbles/scripts/state-transition-guard.sh
SOURCE_GIT_OBJECT=8705e64df1356dcd1fd39af3251271dbeb2c0468
SOURCE_BYTES=243427
PERSISTENT_TEST_SHA256=8637fb1082df4b3ee0690d847656fc696dabdf1046479314a3c2b3bcb21a8fe5  bubbles/scripts/bash-baseline-guard-selftest.sh
SEMANTIC_TEST_SHA256=44d400b334144c842a2530fbdcb4597d630db4c15536ca90008e01c8ef159e07  bubbles/scripts/state-transition-guard-selftest.sh
RELEASE_MANIFEST_SHA256=ad0816e16d6bfa9699a0a13a79fb1f99dccec02ce55ef3cf7bdb762411fe730d  bubbles/release-manifest.json
WORKTREE_MARKER_SHA256=e474d67c038c44418ad63e242e9f32e47b4d799b66273697a7a80f89f38ada6d  .bubbles-worktree
SOURCE_EXACT_DIFF_BEGIN
diff --git a/bubbles/scripts/state-transition-guard.sh b/bubbles/scripts/state-transition-guard.sh
index 2665c6e..8705e64 100755
--- a/bubbles/scripts/state-transition-guard.sh
+++ b/bubbles/scripts/state-transition-guard.sh
@@ -2728 +2728 @@ echo "--- Check 7C: Phase-Claim Execution Backing ---"
-claim_backing_analysis="$(python3 - "$state_file" <<'PY'
+claim_backing_analysis=$(python3 - "$state_file" <<'PY'
@@ -2806 +2806 @@ PY
-)"
+)
SOURCE_EXACT_DIFF_END
STATIC_RECEIPT_FAILURES=0
BUG043_STATIC_RECEIPT_RESULT=PASS
BUG043_STATIC_RECEIPT_END
```

### TP-01 Through TP-03 GREEN Receipt

**Phase:** implement
**Executed:** YES (current session)
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=30s 1860 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label 'BUG-043 TP-01 through TP-03 repaired-source GREEN' -- /opt/local/bin/gtimeout --signal=TERM --kill-after=30s 1800 /opt/homebrew/bin/bash bubbles/scripts/bash-baseline-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-043 TP-01 through TP-03 repaired-source GREEN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=30s 1800 /opt/homebrew/bin/bash bubbles/scripts/bash-baseline-guard-selftest.sh
exit: 0
lines: 78
sha256: dae5b27b698994e904a820858cbc30f2a830377c13e6aeed48c9394890eeaea2
--- first 20 ---
=== bash baseline guard selftest (IMP-102 / SCOPE-5) ===
cli.sh:               cli.sh
framework-validate.sh: framework-validate.sh

BUG043_INTERPRETER role=bash3 path=/bin/bash version=3.2.57(1)-release
BUG043_INTERPRETER role=bash5 path=/opt/homebrew/bin/bash version=5.3.15(1)-release
BUG043_PRODUCTION_SOURCE path=state-transition-guard.sh sha256=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d
BUG043_PARSE_RESULT mode=production interpreter=/bin/bash sourceSha256=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d exit=0
BUG043_PARSE_STDERR_BEGIN mode=production interpreter=/bin/bash
BUG043_PARSE_STDERR_END mode=production interpreter=/bin/bash
BUG043_PARSE_RESULT mode=production interpreter=/opt/homebrew/bin/bash sourceSha256=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d exit=0
BUG043_PARSE_STDERR_BEGIN mode=production interpreter=/opt/homebrew/bin/bash
BUG043_PARSE_STDERR_END mode=production interpreter=/opt/homebrew/bin/bash
	PASS: Regression: SCN-B043-001 repaired guard parses under real Bash 3 and Bash 5 on identical bytes
BUG043_FIXTURE_SOURCE_FORM=repaired
BUG043_FIXTURE_OPENING_ANCHOR_COUNT=1
BUG043_FIXTURE_CLOSING_ANCHOR_COUNT=1
BUG043_FIXTURE_HEADING_ANCHOR_COUNT=1
BUG043_FIXTURE_SOURCE_REPAIR_DELETION_COUNT=0
BUG043_FIXTURE_QUOTE_BOUNDARY_MUTATION_COUNT=2
--- failure-shaped lines from the omitted region ---
/bin/bash: line 85: syntax error: unexpected end of file
/bin/bash: line 85: syntax error: unexpected end of file
--- omitted 38 line(s); sha256 above covers the full output ---
--- last 20 ---
BUG043_EXEC_OUTPUT_END mode=exact-mutant interpreter=/opt/homebrew/bin/bash
BUG043_EXEC_RESULT mode=exact-mutant interpreter=/opt/homebrew/bin/bash exit=0 sentinelCount=1 headingCount=1
	PASS: Mutation: SCN-B043-002 exact outer-quote restoration recreates the parser divergence
BUG043_PRODUCTION_SOURCE_AFTER sha256=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d
	PASS: BUG-043 parser fixtures left canonical production source bytes unchanged

	PASS: cli.sh guard at L65 precedes aliases.sh source at L74
	PASS: framework-validate.sh guard at L12 precedes first source at L18
	PASS: framework-validate.sh guard is near the top (L12 <= 30)
	PASS: simulated v=3 triggers guard (exit 1)
	PASS: simulated v=4 passes guard (exit 0)
	PASS: simulated v=5 passes guard (exit 0)
	PASS: empty/unset BASH_VERSINFO branch triggers guard (exit 1)
	PASS: static check passes on real cli.sh and FAILS on guard-removed copy (has teeth)

BUG043_MATRIX_SUMMARY productionParse=0/0 repairedParse=0/0 repairedExecution=0/0 repairedSentinel=1/1 mutantParse=2/0 mutantExecution=2/0 mutantSentinel=0/1
BUG043_SOURCE_INVARIANT before=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d after=e2aacaf3627164114c54454c914267a35d5ce4aa87574edd00d3f81ef8b6bc2d unchanged=true

bash-baseline-guard-selftest: 12 passed / 0 failed
PASS
```

The two parser-error lines are the expected Bash 3.2 diagnostics from the exact
quote-restoration negative control. The closed matrix proves the repaired source
crosses the former parser boundary while the mutant remains discriminating.
**Claim Source:** interpreted from the executed receipt above.

### Implementation Routing

`TP-04` through `TP-06` were not executed in this invocation. No DoD checkbox,
scope status, top-level status, completed phase claim, or certification field was
changed. The packet remains `in_progress` and routes to `bubbles.test` for
independent current-byte verification.
