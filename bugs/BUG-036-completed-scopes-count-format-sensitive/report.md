# BUG-036 Report

Historical evidence labels below use provisional BUG-034 and BUG-035
identifiers from commands executed before `origin/main` allocated BUG-034 to
another defect. They remain verbatim evidence. This packet's canonical identity
is BUG-036 and its umbrella packet is BUG-035.

## Summary

- Filed the completed-scope counting defect.
- Replaced the line-oriented count with structured string-array analysis.
- Added compact-array and precedence regressions.
- Preserved remote BUG-011 ordinal-type and phantom-scope regressions.

## Completion Statement

The parser fix is rebased onto current `main`. The post-rebase focused suite
passes. The recorded full framework run passed before BUG-035 D10-D11 changed
the candidate, so final full validation must run again. The packet remains
`in_progress`; release readiness, human acceptance, audit, and validate-owned
certification are incomplete.

## Test Evidence

### Red stage

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-035 red transition guard selftest" -- bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 1

**Output:**

```text
# BUG-035 red transition guard selftest
$ bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 1
lines: 706
sha256: dfa433dc06119b2ff80a5860917f3685c3026fea66669131e92b0918787c00f9
--- first 20 ---
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- failure-shaped lines from the omitted region ---
FAIL: Bare-integer completedScopes should pass the transition guard (observed 1)
FAIL: Numeric completedScopes is counted as one
FAIL: Numeric completedScopes is not misreported as empty
FAIL: Compact three-entry completedScopes should pass the transition guard (observed 1)
FAIL: Compact completedScopes counts every entry
--- omitted 666 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: Check 7A: the surfaced detail names which span was reconstructed (never silent)
Running Check 7C phase-claim execution backing (A-017-08)...
PASS: Check 7C: analyzer block located in guard source (no test/source drift)
PASS: Check 7C: a claimed phase with no executionHistory entry is reported UNBACKED
PASS: Check 7C adversarial: a properly backed claim is NOT reported (detector discriminates)
PASS: Check 7C: more claims than runs is reported as EXCESS, with its counts
PASS: Check 7C adversarial: a matched claim/run count is NOT reported as EXCESS
PASS: Check 7C: reads a TOP-level executionHistory (BUG-012 container fallback honored)
PASS: Check 7C: an unbacked PLAIN-STRING claim is reported (the shape real packets write)
PASS: Check 7C: string-shape claims are normalised, not discarded as NO_CLAIMS
PASS: Check 7C: abstains when executionHistory is absent entirely (planning-only packets are not false-blocked)
PASS: Check 7C adversarial: an absent executionHistory yields no UNBACKED finding
PASS: Check 43: one checked plus one unchecked item is detected as unaccepted (BUG-029 shape)
PASS: Check 43 adversarial: a fully checked checklist reports no unchecked item, and a '[ ]' outside the Checklist section is ignored
PASS: Check 43 (PD-12): a fully checked list with no human acceptance record is refused at a terminal transition
PASS: Check 43 (PD-12): checked items plus an authored human record satisfy terminal acceptance
----------------------------------------
state-transition-guard selftest failed with 5 issue(s).
```

**Result:** FAIL. The compact-array failures reproduce the surviving defect.
The three numeric-acceptance assertions encode a premise superseded by remote
BUG-011 and are not part of the final contract. The post-rebase suite must keep
BUG-011's ordinal type refusal green.

### Pre-rebase intermediate green stage

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-035 green transition guard selftest after fixture repair" -- bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Output:**

```text
# BUG-035 green transition guard selftest after fixture repair
$ bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 378
sha256: 41729fc6f69785009297b4a8cb22feb0dd7ef6345a6d74f7e58339124286e49c
--- first 20 ---
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- omitted 338 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: Check 7A adversarial: a perfunctory reason does NOT buy the exemption
PASS: Check 7A: the surfaced detail names which span was reconstructed (never silent)
Running Check 7C phase-claim execution backing (A-017-08)...
PASS: Check 7C: analyzer block located in guard source (no test/source drift)
PASS: Check 7C: a claimed phase with no executionHistory entry is reported UNBACKED
PASS: Check 7C adversarial: a properly backed claim is NOT reported (detector discriminates)
PASS: Check 7C: more claims than runs is reported as EXCESS, with its counts
PASS: Check 7C adversarial: a matched claim/run count is NOT reported as EXCESS
PASS: Check 7C: reads a TOP-level executionHistory (BUG-012 container fallback honored)
PASS: Check 7C: an unbacked PLAIN-STRING claim is reported (the shape real packets write)
PASS: Check 7C: string-shape claims are normalised, not discarded as NO_CLAIMS
PASS: Check 7C: abstains when executionHistory is absent entirely (planning-only packets are not false-blocked)
PASS: Check 7C adversarial: an absent executionHistory yields no UNBACKED finding
PASS: Check 43: one checked plus one unchecked item is detected as unaccepted (BUG-029 shape)
PASS: Check 43 adversarial: a fully checked checklist reports no unchecked item, and a '[ ]' outside the Checklist section is ignored
PASS: Check 43 (PD-12): a fully checked list with no human acceptance record is refused at a terminal transition
PASS: Check 43 (PD-12): checked items plus an authored human record satisfy terminal acceptance
----------------------------------------
state-transition-guard selftest passed.
```

**Result:** PASS on the pre-rebase contract. This run is not final post-rebase
evidence because current `main` added BUG-011 ordinal type safety afterward.

### Post-rebase green stage

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-035 post-rebase transition guard selftest" -- bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Output:**

```text
# BUG-035 post-rebase transition guard selftest
$ bash bubbles/scripts/state-transition-guard-selftest.sh
exit: 0
lines: 424
sha256: 14c0fd04b227f0227c584d78797dec2e7ff47180782afd8f53d1c0e49b923069
--- first 20 ---
PASS: G061 same-repo case reaches Check 3F
PASS: G061 allows bubbles.validate routing to the currently guarded spec
PASS: G061 does not classify a same-spec specialist route as external
PASS: G061 blocks an external/upstream route without crossRepoFollowUp
PASS: G061 does not admit the incomplete external route
PASS: G061 allows a complete external route with crossRepoFollowUp
PASS: G061 keeps the complete external route non-blocking
PASS: G061 requires crossRepoFollowUp for a commit route
PASS: G061 requires crossRepoFollowUp for a ticket route
PASS: G061 requires crossRepoFollowUp for an explicit external routing class
PASS: G061 requires crossRepoFollowUp for an explicit upstream routing class
PASS: G061 rejects a string crossRepoFollowUp value with a type-specific reason
PASS: G061 does not treat a string crossRepoFollowUp value as true
PASS: G061 rejects an ambiguous traversal alias of the guarded spec
PASS: G061 rejects a duplicate-separator alias of the guarded spec
PASS: G061 rejects a backslash alias of the guarded spec
PASS: G061 rejects a surrounding-whitespace alias of the guarded spec
PASS: G061 rejects a parent-traversal alias of the guarded spec
PASS: G061 rejects an absolute alias of the guarded spec
PASS: G061 does not resolve a symlink alias as the guarded spec
--- omitted 384 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: BUG-011 control: an empty array is NOT reported as a wrong-element-type failure
PASS: BUG-011 adversarial: a quoted string scope ID is NOT reported as a wrong element type
PASS: BUG-011 adversarial: a populated string array is NOT reported as EMPTY
PASS: BUG-011 adversarial: one quoted scope ID against one Done scope artifact passes Check 5
Running Check 7A completedPhaseClaims timestamp selftest (BUG-013)...
PASS: BUG-013: completedPhaseClaims on an exact 600s grid fails the transition guard
PASS: BUG-013: uniformly spaced claimedAt values are named a FABRICATION INDICATOR
PASS: BUG-013: completedPhaseClaims whose claimedAt runs backwards fails the transition guard
PASS: BUG-013: a claim recorded before the claim ahead of it is reported as backwards ordering
PASS: BUG-013 adversarial: irregular forward-moving claimedAt values are reported plausible
PASS: BUG-013 adversarial: irregular spacing is NOT reported as a uniform interval
PASS: BUG-013 adversarial: forward-moving claims are NOT reported as backwards
PASS: BUG-013: an absent completedPhaseClaims abstains instead of adjudicating
PASS: BUG-013: an absent completedPhaseClaims yields no uniform-interval finding
PASS: BUG-013: an absent completedPhaseClaims yields no backwards-ordering finding
PASS: BUG-013: claimedAtUnreconciled with a sub-threshold reason still fails the transition guard
PASS: BUG-013: a claim declared unreconciled on a short reason stays IN the analysed set (count is still 10)
PASS: BUG-013: a sub-threshold reason does not register as a declared unreconciled claim
----------------------------------------
state-transition-guard selftest passed.
```

**Result:** PASS. Compact string arrays now count structurally. Remote BUG-011
ordinal type safety and every existing transition-guard regression remain green.

### Full framework validation

**Executed:** YES

**Command:** `bash bubbles/scripts/evidence-capture.sh --label "BUG-034 and BUG-035 final framework validation" -- bash bubbles/scripts/cli.sh framework-validate`

**Exit Code:** 0

**Output:**

```text
# BUG-034 and BUG-035 final framework validation
$ bash bubbles/scripts/cli.sh framework-validate
exit: 0
lines: 17765
sha256: cd6a7aa04b47c9d89b65cf6b7f96a3a8546ceac30134bb4f72e5b05bbf7e3e44
--- first 20 ---
Bubbles Framework Validation
Repository: /tmp/bubbles-bug035
Install mode: source

==> Repository drift report (informational)
# Repository Drift Report

Generated: 2026-08-18T08:36:31Z
Repo root: /tmp/bubbles-bug035

No specs directory found under repository root; no repo-local execution packets to inspect.
This is expected for the Bubbles source repository, which publishes durable framework behavior in docs, scripts, selftests, and the release manifest instead of keeping persistent source-repo specs.
PASS: Repository drift report (informational)

==> Gate-catalog freshness advisory (informational, IMP-005)
gate-catalog-freshness: curated gate catalogs are current with the registry (ceiling G137).
PASS: Gate-catalog freshness advisory (informational, IMP-005)

==> Portable surface agnosticity
PASS: Portable surface agnosticity
--- failure-shaped lines from the omitted region ---
	PASS  failure_detail: surfaces a shell 'command not found'
PASS: a scopes.md with zero Status: lines does not trigger a grep -c syntax error
❌ Framework-managed file drift detected: agents/bubbles.workflow.agent.md
❌ Framework-managed file drift detected: agents/bubbles.workflow.agent.md
❌ scopes/01-heading/scope.md has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan)
❌ scopes/01-heading/scope.md has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan)
❌ scopes/01-heading/scope.md has no concrete Test Plan rows to trace
❌ scopes/01-heading/scope.md has no concrete Test Plan rows to trace
❌ scopes/01-heading/scope.md has no concrete Test Plan rows to trace
❌ scopes/01-heading/scope.md Test Plan extraction failed
--- omitted 17725 line(s); sha256 above covers the full output ---
--- last 20 ---

==> Release manifest freshness
Release manifest is current: 7.28.0 (907 managed files)
PASS: Release manifest freshness

Wall clock: 5934s across 333 executed check(s).
Slowest checks (>=1s):
	2239s  v5.3 downstream-install selftest (G1)
	1032s  Transition guard selftest
	 299s  Install provenance selftest
	 187s  Transition contract resolver selftest (BUG-009 S02)
	 136s  Trust doctor selftest
	 132s  Runtime concurrency selftest (IMP-102 / SCOPE-8)
	 129s  Runtime lease selftest
	 124s  Evidence-admission hardening selftest (IMP-102 / SCOPE-1)
	 119s  Scenario linked-test resolution selftest (IMP-040 / COV-8)
	 115s  Shellcheck lint (v7.0.2, -S warning, zero findings)

Framework validation passed (2 skipped: 2 denylisted).
Framework validation passed.
```

**Result:** PASS. The failure-shaped lines are expected adversarial fixture
outputs inside selftests. The suite's aggregate verdict is exit `0`. This
receipt validates the candidate before BUG-035 D10-D11 and is not the final
release-readiness proof.

## Code Diff Evidence

**Executed:** YES

**Command:** `bash bubbles/scripts/generate-release-manifest.sh`, followed by
`git diff --stat`, `git diff --name-status`, `git diff --check`, and
`git status --short -- BUGS.md`.

**Exit Code:** 0

**Output:**

```text
Updated release manifest: 7.28.0 (905 managed files)
=== IMPLEMENTATION DIFF STAT ===
 bubbles/release-manifest.json                      |   8 +-
 bubbles/scripts/state-transition-guard-selftest.sh | 149 +++++++++++++++++++++
 bubbles/scripts/state-transition-guard.sh          |  28 ++--
 3 files changed, 166 insertions(+), 19 deletions(-)
=== IMPLEMENTATION PATHS ===
M       bubbles/release-manifest.json
M       bubbles/scripts/state-transition-guard-selftest.sh
M       bubbles/scripts/state-transition-guard.sh
=== DIFF CHECK ===
=== BUGS.MD STATUS ===
```

**Result:** PASS for the pre-rebase tree. The manifest and diff evidence must be
regenerated after rebase before publication. `BUGS.md` remained unchanged.

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