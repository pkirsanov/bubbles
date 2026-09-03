# BUG-061 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Made the three research `CDPATH` assignments and the migration fixture's
  `XDG_RUNTIME_DIR` assignment explicitly empty without changing their commands.
- Removed only the unread `EMPTY_DIGEST` assignment from the usage reference
  adapter.
- Passed the combined five-file ShellCheck command, T1-T8, and T10 on the final
  source bytes. Environment-sensitive T7/T8 attempts are retained below.
- Ran T9 and observed exactly four SC2034 findings in the two excluded owner
  files. No assigned BUG-061 finding remains in the canonical gate output.
- Regenerated and checked the release manifest after the source checks.
- Allocated BUG-061 after a canonical-path scan of every local ref, live remote
  ref, registered worktree, source bug directory, and `BUGS.md` heading.
- Reproduced exactly four SC1007 findings and one SC2034 finding on the five
  assigned tracked files.
- Grounded the five source constructs and the two excluded ownership artifacts.
- Created planning and scenario contracts without modifying source or tests.
- Passed canonical artifact, scenario-obligation, test-mechanism,
  scenario-reference, and planning-traceability checks.
- Kept top-level and certification status `in_progress`.

## Completion Statement

The implementation phase owns the five bounded source repairs and the evidence
recorded below. The bug and scope remain `in_progress`: T9 exits 1 on the four
excluded-owner warnings, and independent test execution, T11
`framework-validate`, audit, and validate-owned certification are not claimed.

## Test Evidence

### Global bug ID allocation

**Executed:** YES
**Phase:** bug
**Command:** isolated `origin` mirror plus canonical bug-path and `BUGS.md` heading scan across every local ref, live remote ref, and registered worktree
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `2e5e17166e4b6eccd1b95730f680d36565e09c835d11042831e4b8d5c84b52d3`

```text
CANONICAL_BUG_ALLOCATION_SCAN_BEGIN
LOCAL_REFS_SCANNED=275
UNIQUE_LOCAL_REF_OBJECTS_SCANNED=119
LIVE_REMOTE_REFS_SCANNED=247
UNIQUE_REMOTE_REF_OBJECTS_SCANNED=116
REGISTERED_WORKTREES_SCANNED=16
LIVE_CANONICAL_BUG_DIRS_SCANNED=146
LIVE_BUGS_MD_HEADINGS_SCANNED=476
BUG-053
BUG-054
BUG-055
BUG-056
BUG-057
BUG-058
BUG-059
BUG-060
MAX_ALLOCATED_BUG_ID=BUG-060
NEXT_GLOBALLY_FREE_BUG_ID=BUG-061
CANONICAL_BUG_ALLOCATION_SCAN_END
```

**Result:** PASS. The allocation check distinguishes canonical bug artifacts
from example identifiers in unrelated source or fixtures.

### Exact five-warning before fix

**Executed:** YES
**Phase:** bug
**Command:** `shellcheck -S warning -f gcc bubbles/adapters/research/disabled.sh bubbles/adapters/research/local-command.sh bubbles/adapters/usage/reference-test.sh bubbles/scripts/research-run.sh bubbles/scripts/scenario-manifest-migrate-selftest.sh`
**Capture:** The command ran inside the bounded `BUG-061 exact five-warning pre-fix reproduction` evidence-capture invocation with a 120-second process limit.
**Exit Code:** 1
**Claim Source:** executed
**Output SHA-256:** `c7f1dc6cd8750450fbd8d4ca3410e2e3f45da28163207641f4940e715dab9261`

```text
BUG061_SHELLCHECK_REPRO_BEGIN
SHELLCHECK_BIN=/opt/homebrew/bin/shellcheck
ShellCheck - shell script analysis tool
version: 0.11.0
license: GNU General Public License, version 3
website: https://www.shellcheck.net
BUG061_FOCUSED_SURFACES_BEGIN
bubbles/adapters/research/disabled.sh
bubbles/adapters/research/local-command.sh
bubbles/adapters/usage/reference-test.sh
bubbles/scripts/research-run.sh
bubbles/scripts/scenario-manifest-migrate-selftest.sh
BUG061_FOCUSED_SURFACES_END
bubbles/adapters/research/disabled.sh:4:21: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
bubbles/adapters/research/local-command.sh:4:21: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
bubbles/adapters/usage/reference-test.sh:14:1: warning: EMPTY_DIGEST appears unused. Verify use (or export if used externally). [SC2034]
bubbles/scripts/research-run.sh:4:21: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
bubbles/scripts/scenario-manifest-migrate-selftest.sh:619:45: warning: Remove space after = if trying to assign a value (for empty string, use var='' ... ). [SC1007]
BUG061_SHELLCHECK_EXIT=1
BUG061_SHELLCHECK_REPRO_END
```

**Result:** Expected pre-fix failure. The output contains exactly five warning
records on the assigned files and preserves the nonzero ShellCheck exit.

### Source occurrence inventory

**Executed:** YES
**Phase:** bug
**Command:** bounded `git grep` over exactly the five assigned files plus direct ownership artifact lookup
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** The clean inventory maps every reproduced warning to one
source construct. The separately located IMP-056 and BUG-038 artifacts provide
the exclusion anchors required by the operator boundary.

```text
OWNERSHIP_PATHS_BEGIN
improvements/IMP-056-fail-closed-cross-repository-dispatch-authorization.md
bugs/BUG-038-train-metadata-assignment-mode-gap
OWNERSHIP_PATHS_END
EXACT_FIVE_SOURCE_PATTERNS_BEGIN
bubbles/adapters/research/disabled.sh:4:script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
bubbles/adapters/research/local-command.sh:4:script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
bubbles/adapters/usage/reference-test.sh:14:EMPTY_DIGEST="sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
bubbles/scripts/research-run.sh:4:script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
bubbles/scripts/scenario-manifest-migrate-selftest.sh:619:TMPDIR="$WORK/hostile-temp" XDG_RUNTIME_DIR= python3 "$MIGRATOR" --check "$WORK/v1.json"
EXACT_FIVE_SOURCE_PATTERNS_END
```

**Result:** The five-instance packet boundary is source-grounded. No warning
from the two existing ownership groups is included.

## Code Diff Evidence

**Executed:** YES
**Phase:** bug
**Command:** `git diff --cached --name-only; git diff --cached --check; git diff --quiet HEAD -- <five source paths>; git diff --quiet HEAD -- <two excluded owner paths>; git diff --quiet HEAD -- bubbles/release-manifest.json; git status --short --branch`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG061_STAGED_PATHS_BEGIN
BUGS.md
bugs/BUG-061-shellcheck-zero-warning-gate/bug.md
bugs/BUG-061-shellcheck-zero-warning-gate/design.md
bugs/BUG-061-shellcheck-zero-warning-gate/report.md
bugs/BUG-061-shellcheck-zero-warning-gate/scenario-manifest.json
bugs/BUG-061-shellcheck-zero-warning-gate/scopes.md
bugs/BUG-061-shellcheck-zero-warning-gate/spec.md
bugs/BUG-061-shellcheck-zero-warning-gate/state.json
bugs/BUG-061-shellcheck-zero-warning-gate/test-plan.json
bugs/BUG-061-shellcheck-zero-warning-gate/uservalidation.md
BUG061_STAGED_PATHS_END
BUG061_STAGED_PATH_COUNT=10
BUG061_CACHED_DIFF_CHECK_EXIT=0
BUG061_FIVE_SOURCE_DIFF_EXIT=0
BUG061_EXCLUDED_OWNER_DIFF_EXIT=0
BUG061_RELEASE_MANIFEST_DIFF_EXIT=0
?? .specify/memory/bubbles.session.json
BUG061_STAGING_BOUNDARY_EXIT=0
```

**Result:** PASS. Filing changes only `BUGS.md` and the nine BUG-061 artifacts.
The only other worktree path is the pre-existing untracked runtime session
file, which is not staged. Production, test, excluded-owner, and release
manifest bytes remain unchanged.

## Scenario Contract Evidence

Five stable scenario IDs map one-to-one to F-B061-001 through F-B061-005.
`scenario-manifest.json` records a mutation negative control for each warning
shape, and `test-plan.json` records focused, behavior-preservation, aggregate,
portability, and broad regression commands.

## Artifact Validation Evidence

**Executed:** YES
**Phase:** bug
**Command:** `bash bubbles/scripts/artifact-lint.sh bugs/BUG-061-shellcheck-zero-warning-gate 'SCN-B061-[0-9]{3}'`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`

```text
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
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
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
```

**Result:** PASS. The linter accepted every required source-packet artifact,
the v3 state shape, non-terminal status, report sections, and checked-DoD
evidence links.

## Planning and Traceability Evidence

**Executed:** YES
**Phase:** bug
**Command:** bounded sequential execution of `scenario-obligation-lint.sh`, `test-mechanism-lint.sh`, `scenario-test-resolve.sh`, and `traceability-guard.sh --all-scopes --coverage-policy=planning` against BUG-061
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `9c064600327b587c15830926297409cf3ed85214579fbef1ecd881e03f21fa0c`

```text
BUG061_SCENARIO_OBLIGATION_BEGIN
[scenario-obligation-lint] OK — 5 scenario(s) with a coherent derived obligation matrix
BUG061_SCENARIO_OBLIGATION_EXIT=0
BUG061_TEST_MECHANISM_BEGIN
[test-mechanism-lint] OK — 5 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
BUG061_TEST_MECHANISM_EXIT=0
BUG061_SCENARIO_TEST_RESOLVE_BEGIN
[scenario-test-resolve] OK — 10 reference(s) resolved via literal-scan
BUG061_SCENARIO_TEST_RESOLVE_EXIT=0
BUG061_TRACEABILITY_BEGIN
============================================================
  BUBBLES TRACEABILITY GUARD
  Feature: /private/tmp/bubbles-ozhiva-transition-unblock-ca550392/bugs/BUG-061-shellcheck-zero-warning-gate
  Timestamp: 2026-09-03T05:18:05Z
============================================================

--- Scenario Manifest Cross-Check (G057/G059) ---
✅ scenario-manifest.json covers 5 scenario contract(s)
✅ scenario-manifest.json linked test exists: bubbles/scripts/shellcheck-lint.sh
--- omitted 40 line(s); sha256 above covers the full output ---
✅ scopes.md scenario maps to DoD item: SCN-B061-003 Usage reference adapter is warning-clean
ℹ️  scopes.md scenario→DoD match confidence: declared
✅ scopes.md scenario maps to DoD item: SCN-B061-004 Research runner is warning-clean
ℹ️  scopes.md scenario→DoD match confidence: declared
✅ scopes.md scenario maps to DoD item: SCN-B061-005 Migration fallback fixture is warning-clean
ℹ️  scopes.md scenario→DoD match confidence: declared
ℹ️  DoD fidelity: 5 scenarios checked, 5 mapped to DoD, 0 unmapped

--- Traceability Summary ---
ℹ️  Scenarios checked: 5
ℹ️  Test rows checked: 11
ℹ️  Scenario-to-row mappings: 5
ℹ️  Concrete test file references: 5
ℹ️  Report evidence references: 5
ℹ️  DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=10 inferred=0 ambiguous=0

RESULT: PASSED (0 warnings)
BUG061_TRACEABILITY_EXIT=0
BUG061_PLANNING_CHECKS_EXIT=0
```

The bounded capture retained the first and last 20 lines and hashed all 80
produced lines. The initial planning attempt is not treated as a pass: it exited
1 because two mechanism values were outside the closed vocabulary and each
scenario had two primary Test Plan bindings. The packet now uses accepted
mechanism vocabulary and one primary Test Plan row per scenario.

**Result:** PASS. Planning-level traceability is coherent. This does not prove
the source repair or any GREEN behavior.

### Focused ShellCheck GREEN

**Executed:** YES (current session)
**Phase:** implement
**Commands:** the exact combined five-file command followed by T1-T5 in packet order
**Exit Codes:** 0 for the combined command and 0 for each T1-T5 command
**Claim Source:** executed

```text
# BUG-061 focused five-file ShellCheck GREEN
$ shellcheck -S warning -f gcc bubbles/adapters/research/disabled.sh bubbles/adapters/research/local-command.sh bubbles/adapters/usage/reference-test.sh bubbles/scripts/research-run.sh bubbles/scripts/scenario-manifest-migrate-selftest.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
--- output ---
# BUG-061 T1 disabled adapter ShellCheck
$ shellcheck -S warning -f gcc bubbles/adapters/research/disabled.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
# BUG-061 T2 local-command adapter ShellCheck
$ shellcheck -S warning -f gcc bubbles/adapters/research/local-command.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
# BUG-061 T3 usage reference adapter ShellCheck
$ shellcheck -S warning -f gcc bubbles/adapters/usage/reference-test.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
# BUG-061 T4 research runner ShellCheck
$ shellcheck -S warning -f gcc bubbles/scripts/research-run.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
# BUG-061 T5 migration fixture ShellCheck
$ shellcheck -S warning -f gcc bubbles/scripts/scenario-manifest-migrate-selftest.sh
exit: 0
lines: 0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

**Result:** PASS. All five assigned files are warning-clean individually and
together at the unchanged `warning` severity floor.

### Behavior Preservation

**Executed:** YES (current session)
**Phase:** implement
**Commands:** T6 research admission, T7 usage adapter v2, and T8 scenario-manifest migration selftests
**Final Exit Codes:** 0, 0, 0
**Claim Source:** executed

```text
# BUG-061 T6 research admission behavior preservation
$ bash bubbles/scripts/research-admission-cli-selftest.sh
exit: 0
lines: 49
sha256: 105bf8196416b890f33e7de5927799542da0cfbef74a9169efaf0b72af67e93b
research-admission-cli-selftest: PASS=48 FAIL=0
# BUG-061 T7 initial default-macOS-temp attempt
exit: 4
lines: 7
sha256: 25bec14db2bab42e0af50b3dfc45389786af3a53bc957fedcaac0786f6ac974b
security-authority: usage-receipt authority path cannot contain symlinks and must be readable
# BUG-061 T7 usage adapter v2 behavior preservation with physical TMPDIR
$ bash bubbles/scripts/usage-adapter-v2-selftest.sh
exit: 0
lines: 10
sha256: aa32006dcd2b633db64d3b7b16c83c335dfb73e329f4ad0d42471ed4ecdc4516
usage-adapter-v2-selftest: PASS (9 checks)
# BUG-061 T8 optional-dependency attempt
exit: 0
lines: 1
sha256: 8135e5d5f90ce5b98b41e20976aae69b1a4b341aa2adec635e7fcad526278c05
scenario-manifest-migrate-selftest: SKIP (jsonschema not installed)
# BUG-061 T8 jsonschema-only compatibility attempt
exit: 1
lines: 124
sha256: 35aed29ebad2772cfaa452c28a14ad1816f4404e575b707652f5dcf21b840bbb
PASS: precreated fallback lock directory with hostile mode refuses
# BUG-061 T8 scenario-manifest migration behavior preservation with provisioned compatibility tools
$ bash bubbles/scripts/scenario-manifest-migrate-selftest.sh
exit: 0
lines: 117
sha256: ac0c5d5c923cced5dbf31fdf66e8efc4c757980593720ad207aeaeffc4ba60f2
PASS: precreated fallback lock directory with hostile mode refuses
scenario-manifest-migrate-selftest: PASS
```

The T7 rerun used the existing physical repository runtime directory because
the authority contract rejects macOS's symlinked default temp path. The final T8
rerun used the installed `jsonschema` interpreter and GNU `mktemp` compatibility
path so every assertion executed. No tracked test or runtime file changed for
either rerun.

**Result:** PASS on the final provisioned execution environment. Research
admission, usage adapter v2, and scenario-manifest migration behavior remain
unchanged.

### Full Tracked Shell Gate Classification

**Executed:** YES (current session)
**Phase:** implement
**Command:** `bash bubbles/scripts/shellcheck-lint.sh`
**Exit Code:** 1
**Output SHA-256:** `bc970170aeb59a6715e92a1c3495f153de0190ab67583fe9819471a4d30d5262`
**Claim Source:** executed

```text
/private/tmp/bubbles-ozhiva-transition-unblock-ca550392/bubbles/adapters/dispatch/reference-broker.sh:76:3: warning: argv appears unused. Verify use (or export if used externally). [SC2034]
/private/tmp/bubbles-ozhiva-transition-unblock-ca550392/bubbles/scripts/release-train-metadata-assign-selftest.sh:11:1: warning: ALIASES_FILE appears unused. Verify use (or export if used externally). [SC2034]
/private/tmp/bubbles-ozhiva-transition-unblock-ca550392/bubbles/scripts/release-train-metadata-assign-selftest.sh:14:1: warning: OWNERSHIP_FILE appears unused. Verify use (or export if used externally). [SC2034]
/private/tmp/bubbles-ozhiva-transition-unblock-ca550392/bubbles/scripts/release-train-metadata-assign-selftest.sh:413:3: warning: drift_before appears unused. Verify use (or export if used externally). [SC2034]
shellcheck-lint: FAIL — 4 finding(s) at -S warning across 605 script(s)
```

**Interpretation:** The full gate is not a zero-warning pass. Its four findings
are exactly the one IMP-056 and three BUG-038 warnings excluded by this packet;
none is in a BUG-061 implementation file.

### Portability GREEN

**Executed:** YES (current session)
**Phase:** implement
**Command:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/adapters/research/disabled.sh bubbles/adapters/research/local-command.sh bubbles/adapters/usage/reference-test.sh bubbles/scripts/research-run.sh bubbles/scripts/scenario-manifest-migrate-selftest.sh`
**Exit Code:** 0
**Output SHA-256:** `bb7ff668e143da447782c30a36c945f2c447ca41635b703b80811323b492d3ae`
**Claim Source:** executed

```text
== macOS portability guard -- scanning 5 file(s) ==
ok   class-1 raw-timeout: none
ok   class-2 in-place-sed: none
ok   class-3 date-d-parse: none
ok   class-4 stat-c-mtime: none
ok   class-5 readlink-f-absolutize: none
ok   class-6 grep-pcre: none
ok   class-7 bracket-v-isset: none
ok   class-8 mapfile-readarray: none
ok   class-9 mktemp-suffix: none
ok   class-10 df-output: none
ok   class-11 bin-true-false: none
ok   class-12 paste-no-stdin-operand: none
ok   class-13 date-nanoseconds: none
ok   class-14 mktemp-parent-dir: none
ok   class-15 mktemp-nontrailing-x: none
ok   class-16 awk-3arg-match: none

PASS: the scanned surface is WSL+macOS portable.
```

### Implementation Source Boundary

**Executed:** YES (current session)
**Phase:** implement
**Command:** bounded source-path inventory, `git diff --check`, exact construct checks, excluded-owner blob comparison, and full five-file diff
**Exit Code:** 0
**Claim Source:** executed

```text
SOURCE_BOUNDARY_PATHS_BEGIN
bubbles/adapters/research/disabled.sh
bubbles/adapters/research/local-command.sh
bubbles/adapters/usage/reference-test.sh
bubbles/scripts/research-run.sh
bubbles/scripts/scenario-manifest-migrate-selftest.sh
SOURCE_BOUNDARY_PATHS_END
EXCLUDED_OWNER_BEFORE_BEGIN
c13ab195a7e3d67f011c4e327192abdfafa0c0f0 bubbles/adapters/dispatch/reference-broker.sh
bb30e0bb8fe03e56a2ba82eea87111b1bf615b88 bubbles/scripts/release-train-metadata-assign-selftest.sh
EXCLUDED_OWNER_BEFORE_END
EXCLUDED_OWNER_AFTER_BEGIN
c13ab195a7e3d67f011c4e327192abdfafa0c0f0 bubbles/adapters/dispatch/reference-broker.sh
bb30e0bb8fe03e56a2ba82eea87111b1bf615b88 bubbles/scripts/release-train-metadata-assign-selftest.sh
EXCLUDED_OWNER_AFTER_END
SOURCE_BOUNDARY_CHECK=PASS
```

**Result:** PASS. The source delta contains only the five planned edits, and
both excluded ownership blobs are byte-identical.

### Release Manifest

**Executed:** YES (current session)
**Phase:** implement
**Commands:** `bash bubbles/scripts/generate-release-manifest.sh`, `bash bubbles/scripts/generate-release-manifest.sh --check`, release-manifest selftest, and purity selftest
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed

```text
# BUG-061 regenerate release manifest from validated source bytes
exit: 0
lines: 1
sha256: 9dba3ba137c0c0a6ad997d8dc69483ae6a2ed8fea003e3a934a02bba19728899
Updated release manifest: 7.29.0 (980 managed files)
# BUG-061 check regenerated release manifest
exit: 0
lines: 1
sha256: 3107222d9960d0b8e46679a81e1503f39d2f87de4b0abd2998fdd55aad7a221b
Release manifest is current: 7.29.0 (980 managed files)
# BUG-061 release manifest focused selftest
exit: 0
lines: 42
sha256: dccd9228ddb8abdbe983c704cf626b56d04b9a9eb9b8fbf0e1937b6058d0eb28
release-manifest selftest passed.
# BUG-061 release manifest purity selftest
exit: 0
lines: 7
sha256: 57d8bb32b6247af62d10f1c656311336c3bc00594930600ac580a62f70e2b36d
release-manifest-purity-selftest: PASS
```

### Implement Profile Checks

**Executed:** YES (current session)
**Phase:** implement
**Commands:** scenario obligation lint, test mechanism lint, scenario test resolution, traceability guard, and implementation reality scan
**Exit Codes:** 0, 0, 0, 0, 0
**Claim Source:** executed

```text
# BUG-061 scenario obligation lint after implementation
exit: 0
lines: 1
sha256: 65e1b9b55671e52df5fed6a395b47468d622b2bb17d21810f7249b8748d81a93
[scenario-obligation-lint] OK — 5 scenario(s) with a coherent derived obligation matrix
# BUG-061 test mechanism lint after implementation
exit: 0
lines: 2
sha256: 370b60628b444d257236d9a3e0e601fcf14a74e2f94a1923e0a5475c66555cb3
[test-mechanism-lint] OK — 5 declared mechanism(s) coherent with their scenario traits
# BUG-061 scenario test resolution after implementation
exit: 0
lines: 1
sha256: e0daf01726a62f3aef3f58a3620e3700e3fe0fd1ecb3d5bba7c3bd2a7039f5ec
[scenario-test-resolve] OK — 10 reference(s) resolved via literal-scan
# BUG-061 delivery traceability after implementation
exit: 0
lines: 67
sha256: bbf305bdf187bae50d20e4c0ad139aa2fb6f2cce26fc44fc15a471a834e4f046
RESULT: PASSED (0 warnings)
# BUG-061 implementation reality scan
exit: 0
lines: 36
sha256: 2061bb11dd26ecdf2ca2c0522622100a6202ca8ff6639cb15dea9ce24bb65b77
Files scanned: 5
Violations: 0
Warnings: 0
```

## Validation Evidence

**Executed:** NO
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run.

## Uncertainty Declarations

All unresolved implementation and verification obligations are recorded under
the corresponding unchecked items in [scopes.md](scopes.md#definition-of-done).

## Independent Test Phase Evidence

**Executed:** YES (current session)
**Phase:** test
**Claim Source:** executed
**Tested Source:** `d7eb1f2d8c9c8eb1989bbd99ea0f9b1a3c78d26c`
**Branch:** `fix/ozhiva-transition-unblock`
**Repository Decision:** `rb:vscode-2913ac96e8446707d06d7b480573b88f:4`

The tracked/index state was clean before execution. The only worktree entry was
the untracked `.specify/memory/bubbles.session.json`, which remained uncommitted.
No active process referenced this checkout or any BUG-061 test runner.

### Independent Test T1-T5

**Executed:** YES (current session)
**Phase:** test
**Claim Source:** executed
**Severity:** `warning`
**Formatter:** `gcc`

| ID | Canonical inner command | Exit | Output SHA-256 | Tool-log row | Receipt stdoutHash | Input closure |
| --- | --- | ---: | --- | ---: | --- | ---: |
| T1 | `shellcheck -S warning -f gcc bubbles/adapters/research/disabled.sh` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 467 | `95068175ece24f88f43fdfd170630fcb5ade4dcec62205c91a38132a2feedc3b` | 6 |
| T2 | `shellcheck -S warning -f gcc bubbles/adapters/research/local-command.sh` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 468 | `315f3e15a1f9ff76a7068593a26d8525079885c64b36266c70ed7f4635dc3244` | 6 |
| T3 | `shellcheck -S warning -f gcc bubbles/adapters/usage/reference-test.sh` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 469 | `b0b5b99a7cd2b6c9b4758a559259d8a0f9aafca396df570267fa6e48aec494bc` | 6 |
| T4 | `shellcheck -S warning -f gcc bubbles/scripts/research-run.sh` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 470 | `2bc9437624be471c7650012576bc2b91d8c8a0f0195a62e04fd51c2f023a99ed` | 6 |
| T5 | `shellcheck -S warning -f gcc bubbles/scripts/scenario-manifest-migrate-selftest.sh` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 471 | `4ef3a0e104d9031365d840bc6142fe67108e4bdfd0fefb5cf2e801c387654a0b` | 6 |

Each command emitted zero lines. The empty-stream digest above is therefore the
direct zero-finding signal, not a filtered or discarded result. Every receipt
has zero unreadable input-closure entries and binds its declared mutation
control to the tested source revision.

### Independent Test T6

**Executed:** YES (current session)
**Phase:** test
**Command:** `bash bubbles/scripts/research-admission-cli-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `105bf8196416b890f33e7de5927799542da0cfbef74a9169efaf0b72af67e93b`
**Tool-log row:** 472
**Receipt stdoutHash:** `12256cf5a7fc032333d39c5555d39c52ba454437d1ab85befa857c761028dc6a`
**Input closure:** 37 files; zero unreadable entries

```text
PASS: CLI help advertises research
PASS: research status delegates to the runtime check contract
PASS: research status reports the real runtime verdict
PASS: research is default-off without project activation
PASS: research does not invent hosted routes
PASS: research activation remains parked
PASS: unsupported host-native enforcement fails loud
PASS: research local command has an external side effect
PASS: config contract documents neutral dispatch adapter
research-admission-cli-selftest: PASS=48 FAIL=0
```

### Independent Test T7

**Executed:** YES (current session)
**Phase:** test
**Command:** `bash bubbles/scripts/usage-adapter-v2-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `aa32006dcd2b633db64d3b7b16c83c335dfb73e329f4ad0d42471ed4ecdc4516`
**Tool-log row:** 473
**Receipt stdoutHash:** `821acbdfde44e20eb0f2cc39c878e441ba9ba5645e4bbcc22231d6b2eee22443`
**Input closure:** 12 files; zero unreadable entries

```text
ok 1 - none v1 bytes remain compatible
ok 2 - none v2 declares every dimension unsupported
ok 3 - default absence stays none and configured typo fails loud
ok 4 - one explicit supported host record identifies exactly
ok 5 - zero, multiple, and schema-drift identity inputs refuse
ok 6 - unmeasured remains explicit and never becomes measured zero
ok 7 - reference lifecycle is explicit, disabled by default, and adapter-originated
ok 8 - none and vscode remain enforcement-ineligible negative controls
ok 9 - v2 surfaces expose no bypass flags
usage-adapter-v2-selftest: PASS (9 checks)
```

### Independent Test T8

**Executed:** YES (current session)
**Phase:** test
**Command:** `bash bubbles/scripts/scenario-manifest-migrate-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `e004411d33db66b9cef7fefb2ac4637657541aa4cad0bfa88e53d7eb0a3edd0a`
**Tool-log row:** 474
**Receipt stdoutHash:** `ae2d8fbe113eb6cdc2697ac947c659cef3e2e4ecba8feb233c5a18e8d425f96a`
**Input closure:** 8 files; zero unreadable entries

```text
PASS: symlink XDG runtime directory is rejected in favor of secure fallback
PASS: symlink advisory lock directory refuses
PASS: precreated fallback lock directory with hostile mode refuses
PASS: symlink advisory lock refuses without touching its target
PASS: precreated advisory lock with hostile mode refuses
PASS: precreated advisory lock with foreign owner refuses where testable
PASS: advisory lock contention deterministically refuses a cooperating migrator
PASS: intermediate directory aliases share one migration lock identity
PASS: unavailable atomic exchange primitive fails closed instead of weakening write safety
scenario-manifest-migrate-selftest: PASS
```

The default Homebrew Python lacked `jsonschema`, which would make this selftest
emit a valid dependency `SKIP`. That probe was not counted as T8. The executed
T8 used the already-installed `/usr/local/bin/python3` with `jsonschema` and the
repo-approved MacPorts GNU compatibility shim for `mktemp`; all 117 output lines
ran, so T8 is a behavioral pass rather than a skip.

### Independent Test T9

**Executed:** YES (current session)
**Phase:** test
**Command:** `bash bubbles/scripts/shellcheck-lint.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `ab177e5a066145010668821ec9167f18e9e06968ccca9b42264b597add16cac9`
**Tool-log row:** 475
**Receipt stdoutHash:** `64eeb5288dc9f099fb7666f22d7f9364028f79209008cebbd3dab7c0e1eb1541`
**Input closure:** 610 files; zero unreadable entries

```text
shellcheck-lint: PASS — 605 script(s) clean at -S warning
```

The earlier implementation-phase T9 failure remains valid for its older source
epoch. At the independently tested aggregate HEAD, IMP-056 commit
`5620ac49d13447bde8c0ad41541fd36339717828` and BUG-038 commit
`16cfe0c65a728e4cf2642aa49fa42dd011dfa01e` have separately repaired their own
warnings, so the canonical gate is now clean without adding either foreign path
to BUG-061's implementation range.

### Independent Test T10

**Executed:** YES (current session)
**Phase:** test
**Command:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/adapters/research/disabled.sh bubbles/adapters/research/local-command.sh bubbles/adapters/usage/reference-test.sh bubbles/scripts/research-run.sh bubbles/scripts/scenario-manifest-migrate-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output SHA-256:** `bb7ff668e143da447782c30a36c945f2c447ca41635b703b80811323b492d3ae`
**Tool-log row:** 476
**Receipt stdoutHash:** `5a02e3fc32f21e42c23b68d43c502639035cb6e37bb75663d361cc058beb0070`
**Input closure:** 11 files; zero unreadable entries

```text
== macOS portability guard -- scanning 5 file(s) ==
ok   class-1 raw-timeout: none
ok   class-2 in-place-sed: none
ok   class-3 date-d-parse: none
ok   class-4 stat-c-mtime: none
ok   class-5 readlink-f-absolutize: none
ok   class-6 grep-pcre: none
ok   class-7 bracket-v-isset: none
ok   class-8 mapfile-readarray: none
ok   class-9 mktemp-suffix: none
ok   class-10 df-output: none
ok   class-11 bin-true-false: none
ok   class-12 paste-no-stdin-operand: none
ok   class-13 date-nanoseconds: none
ok   class-14 mktemp-parent-dir: none
ok   class-15 mktemp-nontrailing-x: none
ok   class-16 awk-3arg-match: none
PASS: the scanned surface is WSL+macOS portable.
```

### Independent Supporting Checks

**Executed:** YES (current session)
**Phase:** test
**Claim Source:** executed

| Check | Exit | Output SHA-256 | Tool-log row | Receipt stdoutHash | Input closure |
| --- | ---: | --- | ---: | --- | ---: |
| Exact combined five-file ShellCheck | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 459 | `867e0ad05949c1c8ef2ed0e148f4495c3a6961dea645211b28c4677698d85321` | 10 |
| Five-file `bash -n` syntax | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` | 460 | `f55f781f0dd1443c257e7cb6091fa36a3b05ec3e9d9be1f15ef200167a2cdb77` | 10 |
| Obligation, mechanism, linked-test, and planning traceability sequence | 0 | `458e78cfa9f41977f8c9722af508850f748677e358d6d4678291be21c319fd70` | 462 | `8c0ad3d9856f4cc2157123d4612c49b0558200eedd52f62eaae1a94e984080e0` | 17 |
| Bugfix regression-quality guard | 0 | `de9fb72a55d598d7f4a08c7006db716380af5589c3787d2d56e44d90723f2f3a` | 463 | `fffb98db10d6caaaa0b0428ebfd5750c329b3756500e99f7bb9ddb99630ebad1` | 11 |
| Changed-file, excluded-owner, and config boundary | 0 | `ae47962de686765eb5a62eb23ca38f944ed387c247217d847f95c6a824cacc03` | 464 | `1b60bd4d9247f701097f56971238014576de12c097f364f08bb092d9f3d3ada1` | 18 |

The contract sequence resolved all 10 linked tests, accepted all five declared
mechanisms and mutation controls, and ended with `RESULT: PASSED (0 warnings)`.
The regression-quality guard scanned four linked scripts and reported zero
violations and zero warnings. The BUG-061 implementation range contained only
its five source files, release manifest, and owned BUG-061 execution metadata;
the IMP-056 and BUG-038 source files had zero diff in that range. Project config
declares neither `testImpact` nor `traceContracts`, so no impact plan, trace, or
SLO capture applies to this packet.

### Carried IMP-056 Observation

**Executed:** NO
**Phase:** test
**Claim Source:** not-run

The operator supplied the observation that IMP-056 validation is Linux-only.
This invocation did not rerun IMP-056 or promote that observation into a
cross-platform pass. T10 proves portability only for BUG-061's five changed
files. The observation is preserved unchanged for `bubbles.regression`.

### Reserved T11 and Later Phases

**Executed:** NO
**Phase:** test
**Claim Source:** not-run
**Command:** `bash bubbles/scripts/cli.sh framework-validate`

T11 was not executed because the operator reserved one combined framework run
for BUG-047 through BUG-061. No exit code, output hash, or receipt is claimed.
The regression, simplify, gaps, harden, stabilize, devops, security, validate,
audit, and finalize phases remain unclaimed. Certification fields and terminal
status remain unchanged.
