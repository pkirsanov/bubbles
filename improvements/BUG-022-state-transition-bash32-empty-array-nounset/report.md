# Report: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Planning Reconciliation

### Planning Summary

[scopes.md](scopes.md) now defines one authoritative runtime scope with exact
zero, one, and multiple element scenario parity, an atomic three-file/43-site
production boundary, independent behavior-family and site mutants, Bash
runtime lanes, protected-byte boundaries, and source-only install/release
provenance. The physical
`tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` is
present at SHA-256
`4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`;
planning records that hash only as a collision detector and assigns it no RED
claim.

### Planning Completion Statement

PLANNING RECONCILED; DELIVERY UNCLAIMED. The packet remains `blocked`, every
delivery DoD item remains unchecked, and `bubbles.test` is the required owner
for final-byte selection plus a fresh causal pre-fix RED against unchanged
40 + 1 + 2 production bytes. Only that valid unchanged RED may authorize
`bubbles.implement` to patch all three production files atomically.

### Planning Test Evidence

Planning records no delivery evidence and does not reinterpret the historical
intake evidence below as RED, GREEN, release, downstream, or certification
proof. Execution owners append current-session raw output only in the matching
template sections.

### Planned Evidence Destinations

- **Final-Byte RED:** `bubbles.test` records the selected physical `test_29`
  SHA-256, all three unchanged production hashes, 40 main plus three module raw
  sites, fixture/mutant totals, causal Bash 3.2 failure, and zero unrelated or
  harness failures under [Final-Byte RED](#final-byte-red).
- **Production Change Containment:** after that RED, `bubbles.implement`
  records the atomic 43-site diff across the main guard,
  `guards/planning-checks.sh`, and `guards/control-plane-checks.sh`, including
  the preserved raw positive-count control and unchanged nonmapped hashes under
  [Production Change Containment](#production-change-containment).
- **GREEN And Runtime Matrix:** `bubbles.test` reruns the identical RED bytes
  under stock Bash 3.2, explicit newer macOS Bash, and supported Linux Bash,
  then records every family/site mutant and canary under
  [Bash Runtime Matrix](#bash-runtime-matrix),
  [Adversarial Mutant Matrix](#adversarial-mutant-matrix), and
  [Focused Canaries](#focused-canaries).
- **Provenance And Certification:** test/release/validation owners record
  install provenance, generated release identity, supported downstream
  upgrade, finding closure, and independent certification only in
  [Release And Install Provenance](#release-and-install-provenance) and
  [Validation And Certification](#validation-and-certification).

The historical RED below belongs to prior test bytes
`c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`.
It remains historical execution evidence and is not copied, relabeled, or
treated as proof for the current physical test hash.

## Delivery Evidence Template

### Final-Byte RED

**Phase:** test
**Executed:** YES (current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG022_PLANNED_BASH32_RED_BEGIN' && jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; test_exit=$?; printf 'BUG022_PLANNED_BASH32_RED_EXIT=%s\n' "$test_exit"; printf '%s\n' 'BUG022_PLANNED_BASH32_RED_END'; exit "$test_exit"`
**Exit Code:** 1
**Claim Source:** executed
**Result:** VALID PRE-FIX RED against unchanged production bytes.

The full 1,030-line, 54,768-byte transcript was preserved by the terminal.
Summary window (lines 988-1029):

```text
=== BUG-022 regression summary ===
ACTIVE_PLATFORM=Darwin
ACTIVE_BASH_LANE=macos-stock-bash32
ACTIVE_BASH_VERSION=3.2.57(1)-release
TEST_FILE_SHA256_FINAL=c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266
GREEN_MUST_USE_TEST_SHA256_FINAL=c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266
SOURCE_GUARD_SHA256_AFTER=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
CHECK8_SHA256_AFTER=31804b803b8aad2b7889667dcf69de7c740988ae5cab4924ceac63444ac2711f
CHECK8_BYTES_AFTER=6534
CANONICAL_MAPPED_GUARDED=0
CANONICAL_MAPPED_RAW=40
CANONICAL_MODULE_MAPPED_GUARDED=0
CANONICAL_MODULE_MAPPED_RAW=3
PRIMARY_RUNS=11
REFERENCE_CONTROL_RUNS=11
PRIMARY_INTENDED_NOUNSET_ABORTS=11
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=10
SITE_MUTANT_RUNS=43
SITE_MUTANT_REJECTIONS=43
GUARD_RUNS=32
ASSERTIONS=306
PASSED=208
CONTRACT_FAILURES=98
PRIMARY_CONTRACT_FAILURES=98
CONTROL_FAILURES=0
HARNESS_FAILURES=0
BUG022_RED_DISPOSITION=VALID_PRE_FIX_RED
BUG-022 state-transition Bash 3.2 empty-array regression FAILED.
BUG022_PLANNED_BASH32_RED_EXIT=1
BUG022_PLANNED_BASH32_RED_END
```

Protected-byte output in the same execution recorded unchanged
`test_26` SHA-256
`244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655`,
BUG-012 tail SHA-256
`a06574728d38df20524174f7c37451e477603530b28a95e951cab39d428ea354`
at 520 bytes, and byte-identical guard, sourced modules, `test_27`, `test_28`,
framework validation, release manifest, installer, and index surfaces before
and after the run.

### Production Change Containment

Owner: `bubbles.implement`. Record the exact pre-edit guard hash, targeted diff,
accepted expansion inventory, protected hashes before and after, and proof that
every excluded file family remained untouched.

#### Implementation Preflight Route - 2026-07-17T02:06:32Z

**Phase:** implement
**Executed:** YES (current session)
**Claim Source:** executed
**Outcome:** `route_required`; no production, test, planning, release, sibling,
or downstream file was modified.

The mode ceiling permits implementation, and the guard still has the exact
pre-fix RED identity. Two independent preconditions nevertheless block a
complete source repair:

1. The physical regression no longer has the final-byte RED identity recorded
  by `bubbles.test`. The required SHA-256 is
  `c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`;
  two current-session reads both observed
  `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`.
2. `design.md` and `scopes.md` each grant `bubbles.implement` an exact
  production surface of only `bubbles/scripts/state-transition-guard.sh`.
  The test-owned regression and execution routing add three raw sourced-module
  sites in `guards/planning-checks.sh` and `guards/control-plane-checks.sh`,
  but neither surface owns planning content and therefore cannot broaden the
  exact design/scope boundary. The live guard does source both modules, so a
  main-guard-only repair would be knowingly partial and was not attempted.

**Command:** `git -C /Users/pkirsanov/Projects/bubbles status --short --untracked-files=all -- improvements/BUG-022-state-transition-bash32-empty-array-nounset bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/planning-checks.sh bubbles/scripts/guards/control-plane-checks.sh tests/regression/test_26_state_transition_spec_mjs_path.sh tests/regression/test_27_state_transition_bash32_startup.sh tests/regression/test_28_framework_validate_portable_timeout.sh tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh bubbles/scripts/framework-validate.sh bubbles/scripts/fun-mode.sh bubbles/release-manifest.json install.sh BUGS.md`
**Exit Code:** 0

```text
 M BUGS.md
 M bubbles/release-manifest.json
 M bubbles/scripts/framework-validate.sh
 M bubbles/scripts/fun-mode.sh
 M bubbles/scripts/state-transition-guard.sh
 M install.sh
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/bug.md
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/report.md
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/scenario-manifest.json
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/scopes.md
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/spec.md
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/test-plan.json
?? improvements/BUG-022-state-transition-bash32-empty-array-nounset/uservalidation.md
?? tests/regression/test_26_state_transition_spec_mjs_path.sh
?? tests/regression/test_27_state_transition_bash32_startup.sh
?? tests/regression/test_28_framework_validate_portable_timeout.sh
?? tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
```

**Command:** `shasum -a 256 /Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh /Users/pkirsanov/Projects/bubbles/bubbles/scripts/guards/planning-checks.sh /Users/pkirsanov/Projects/bubbles/bubbles/scripts/guards/control-plane-checks.sh /Users/pkirsanov/Projects/bubbles/tests/regression/test_26_state_transition_spec_mjs_path.sh /Users/pkirsanov/Projects/bubbles/tests/regression/test_27_state_transition_bash32_startup.sh /Users/pkirsanov/Projects/bubbles/tests/regression/test_28_framework_validate_portable_timeout.sh /Users/pkirsanov/Projects/bubbles/tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh /Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh`
**Exit Code:** 0

```text
09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a  bubbles/scripts/state-transition-guard.sh
a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583  bubbles/scripts/guards/planning-checks.sh
1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22  bubbles/scripts/guards/control-plane-checks.sh
244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655  tests/regression/test_26_state_transition_spec_mjs_path.sh
ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  tests/regression/test_27_state_transition_bash32_startup.sh
0dca80bde264fec6ba36e6628747fc5c3821cec6ad12142eae222f66e9c8199a  tests/regression/test_28_framework_validate_portable_timeout.sh
4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17  tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20  bubbles/scripts/framework-validate.sh
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
```

**Command:** `git -C /Users/pkirsanov/Projects/bubbles --no-pager diff -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/planning-checks.sh bubbles/scripts/guards/control-plane-checks.sh tests/regression/test_26_state_transition_spec_mjs_path.sh tests/regression/test_27_state_transition_bash32_startup.sh tests/regression/test_28_framework_validate_portable_timeout.sh tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh bubbles/scripts/framework-validate.sh bubbles/scripts/fun-mode.sh`
**Exit Code:** 0
**Claim Source:** interpreted
**Result:** The full path-scoped diff retains concurrent BUG-019/BUG-012 guard
work and BUG-020/BUG-021 surfaces. Neither sourced module has a current diff,
and no BUG-022 source substitution was present or added.

**Concurrent-change observation:** A post-record validation hash read observed
`tests/regression/test_28_framework_validate_portable_timeout.sh` at SHA-256
`62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78`,
after the preflight baseline above observed
`0dca80bde264fec6ba36e6628747fc5c3821cec6ad12142eae222f66e9c8199a`.
This invocation did not edit `test_28`; the changing BUG-021 bytes remain
foreign concurrent work and are not represented as stable BUG-022 evidence.

Required owner sequence: `bubbles.design` must decide and record whether the
three sourced-module sites belong to the accepted repair inventory;
`bubbles.plan` must then synchronize the exact authorized delivery surfaces;
`bubbles.test` must reconcile the changed physical `test_29` bytes and capture
a valid final-byte RED for the resulting exact SHA-256 before implementation
can resume.

### Bash Runtime Matrix

The stock macOS row is the final-byte RED evidence above. No Linux runner was
available in this macOS-only invocation, so the Linux row remains not-run.

#### Explicit Newer macOS Bash Pre-Change Comparison

**Phase:** test
**Executed:** YES (current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG022_PLANNED_NEWER_BASH_COMPARISON_BEGIN' && if [[ -x /opt/homebrew/bin/bash ]]; then newer_bash=/opt/homebrew/bin/bash; elif [[ -x /opt/local/bin/bash ]]; then newer_bash=/opt/local/bin/bash; else printf '%s\n' 'required newer macOS Bash is unavailable'; printf '%s\n' 'BUG022_PLANNED_NEWER_BASH_COMPARISON_END'; exit 2; fi; "$newer_bash" -c 'printf "NEWER_BASH_PATH=%s\nNEWER_BASH_VERSION=%s\n" "$BASH" "$BASH_VERSION"'; "$newer_bash" tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; test_exit=$?; printf 'BUG022_PLANNED_NEWER_BASH_COMPARISON_EXIT=%s\n' "$test_exit"; printf '%s\n' 'BUG022_PLANNED_NEWER_BASH_COMPARISON_END'; exit "$test_exit"`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** Bash 5.3 tolerated the raw empty-array expansions, so all
11 canonical behavior fixtures reached normal results. The two remaining
contract failures are the intentional pre-change source-inventory assertions:
40 main-guard and three sourced-module sites are still raw. This is comparison
evidence only, not GREEN or passing-production evidence.

The full 1,030-line, 50,873-byte transcript was preserved by the terminal.
Summary window (lines 988-1029):

```text
=== BUG-022 regression summary ===
ACTIVE_PLATFORM=Darwin
ACTIVE_BASH_LANE=macos-explicit-newer-bash
ACTIVE_BASH_VERSION=5.3.15(1)-release
TEST_FILE_SHA256_FINAL=c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266
SOURCE_GUARD_SHA256_AFTER=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
CANONICAL_MAPPED_GUARDED=0
CANONICAL_MAPPED_RAW=40
CANONICAL_MODULE_MAPPED_GUARDED=0
CANONICAL_MODULE_MAPPED_RAW=3
PRIMARY_RUNS=11
REFERENCE_CONTROL_RUNS=11
PRIMARY_INTENDED_NOUNSET_ABORTS=0
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=10
SITE_MUTANT_RUNS=43
SITE_MUTANT_REJECTIONS=43
GUARD_RUNS=32
ASSERTIONS=306
PASSED=304
CONTRACT_FAILURES=2
PRIMARY_CONTRACT_FAILURES=2
CONTROL_FAILURES=0
HARNESS_FAILURES=0
BUG022_RED_DISPOSITION=RED_INVALID_MIXED_OR_UNRELATED_FAILURE
BUG-022 state-transition Bash 3.2 empty-array regression FAILED.
BUG022_PLANNED_NEWER_BASH_COMPARISON_EXIT=1
BUG022_PLANNED_NEWER_BASH_COMPARISON_END
```

### Test-Phase Finding Accounting

| Finding | Test-phase disposition | Owner |
| --- | --- | --- |
| `TEST-022-001-MISSING-REGRESSION` | Addressed: the reserved `test_29` path now contains one Bash-3.2-parseable script with no duplicate function definitions. | `bubbles.test` |
| `TEST-022-002-FINAL-BYTE-RED` | Addressed: exact test SHA-256 `c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266` produced `VALID_PRE_FIX_RED` against guard SHA-256 `09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a`. | `bubbles.test` |
| `TEST-022-003-HARNESS-INTEGRITY` | Addressed: 11 canonical fixtures, 11 repaired-reference controls, 10 family mutants, 43 site mutants, and 32 guard processes ran; control, harness, and unrelated-abort counters were zero. | `bubbles.test` |
| `TEST-022-004-NEWER-COMPARISON` | Addressed: explicit Homebrew Bash 5.3.15 ran identical test bytes and reached all canonical behavior results without nounset aborts. | `bubbles.test` |
| `PLAN-022-002-REGRESSION-QUALITY-COMMAND` | Open: the planned feature-directory argument resolves no test files at exit 2; the canonical guard passes at exit 0 when given the physical `test_29` path. | `bubbles.plan` |
| `IMPLEMENT-022-001-MAIN-GUARD-RAW-SITES` | Open: the current guard has 40 mapped raw zero-reachable expansions; production remains unchanged. | `bubbles.implement` |
| `IMPLEMENT-022-002-SOURCED-MODULE-RAW-SITES` | Open: current sourced modules add three raw zero-reachable calls required by the clean repaired-reference controls. | `bubbles.implement` |
| `TEST-022-005-IDENTICAL-BYTE-GREEN` | Open: GREEN requires implementation first and must reuse test SHA-256 `c6482fdd8985f43725b3f0be0e0a13ebca31a499ae60ecaa6187b136e0335266`. | `bubbles.test` after implementation |

### Adversarial Mutant Matrix

Owner: `bubbles.test`. Record one result per named family mutant and each mapped
inventory mutant, including proof of exactly one staged substitution and the
specific production assertion that rejected it. Canonical worktree bytes must
remain unchanged by every mutant run.

### Focused Canaries

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed

```text
TEST29_BASH32_SYNTAX_EXIT=0
TOP_LEVEL_SHEBANG=PASS
FUNCTION_DUPLICATE_COUNT=0
SUMMARY_MARKER_COUNT=1
FINAL_SUCCESS_LINE_COUNT=1
TEST29_NONDUPLICATION_EXIT=0
TEST29_SLOT_FILE_COUNT=1
TEST29_SLOT_FILE=tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
TEST29_UNIQUE_SLOT_EXIT=0
TEST29_SKIP_MARKER_MATCHES=0
TEST29_SKIP_MARKER_EXIT=0
TEST29_INTERCEPTION_MATCHES=0
TEST29_INTERCEPTION_SCAN_EXIT=0
BUG022_BLOCKED_ROUTE_INVARIANT_EXIT=0
BUG022_TEST_OWNED_DIFF_CHECK_EXIT=0
```

| Check | Exact command | Exit | Result |
| --- | --- | ---: | --- |
| Artifact shape | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Passed; retained the pre-existing deprecated `scopeProgress` notice. |
| Scenario traceability | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Passed: 3 scenarios, 21 rows, 3 concrete test references, 3 report evidence references, and 3/3 DoD mappings. |
| Artifact freshness | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Passed with zero failures and warnings. |
| Capability proportionality | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Passed Gate G094. |
| Test portability | `bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | 0 | Passed all 13 portability classes. |
| Planned regression-quality command | `bash bubbles/scripts/regression-quality-guard.sh --bugfix improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 2 | Invalid input shape: `ERROR: no test files resolved from inputs`. |
| Corrected regression-quality command | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | 0 | Passed: one file scanned, one adversarial signal, zero violations, zero warnings. |

The strict-mode, protected-byte, source-only, cardinality, run-total, and
harness-integrity assertions are also part of the two complete `test_29`
executions above. Managed selftest, BUG-019 `test_26`, framework validation,
release identity, Linux execution, install provenance, and post-repair GREEN
were not run as completion claims in this pre-implementation test phase.

### Release And Install Provenance

Owners: `bubbles.test` for install-provenance assertions and
`bubbles.releases` for generated release identity. Record that the production
guard and managed selftest install byte-identically, `test_29` remains
source-only, full framework validation precedes release-check, and supported
downstream installation consumes the selected canonical release without a
managed-file hand edit.

### Validation And Certification

Owners: `bubbles.validate` and `bubbles.audit` for their own phases. Append only
fresh guard, audit, finding-accounting, and certification evidence. Planning
does not pre-populate a verdict or terminal status.

## Intake Record

### Summary

BUG-022 is confirmed on stock macOS Bash 3.2 with required parsers available.
The corrected BUG-019 command reaches Check 8 and passes its parser-specific
assertions before the state-transition guard aborts on empty array expansion.
Static review identifies additional masked zero-state families. No production,
test, shared registry, release, or downstream bytes were changed.

### Completion Statement

INTAKE AND REPRODUCTION RECORDED; DELIVERY NOT EXECUTED. The packet remains
`blocked`, all implementation DoD items remain unchecked, certification is
blocked, and the immediate owner is `bubbles.design`.

### Test Evidence

Only the before-fix production reproduction was executed as behavior evidence.
Artifact and freshness checks are recorded after packet creation in
[Focused Intake Checks](#focused-intake-checks).

## Bug Reproduction Before Fix

**Phase:** discovery
**Executed:** YES (current invocation)
**Command:** `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed
**Result:** FAIL as expected for the isolated before-fix defect.

**Raw output, current-session contiguous excerpts:**

```text
BUG022_BEFORE_FIX_REPRODUCTION_BEGIN
CLAIM_SOURCE=executed
INTERPRETER=/bin/bash
BASH_VERSION=3.2.57(1)-release
JQ_AVAILABLE=yes
YQ_AVAILABLE=yes
EXPECTED_DISCRIMINATOR=Check 8 parser assertions pass before empty-array nounset abort
=== BUG-019 harness control: real guard reaches Check 8 cleanly ===
--- BUG-019 baseline production output ---
============================================================
  BUBBLES STATE TRANSITION GUARD
```

```text
--- Check 18: Deferral Language Scan (Gate G040) ---
PASS: Zero deferral language found in scope and report artifacts (Gate G040)
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 72: passed_gate_ids[@]: unbound variable
--- BUG-019 compound and compatibility matrix exit=0 ---
PASS: compound matrix reaches production Check 8
FAIL: compound matrix reaches a normal structured result (missing: END TRANSITION_GUARD_RESULT_V1)
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: ordinary .spec.ts control remains complete
PASS: ordinary .test.js control remains complete
PASS: marker-only .spec control remains accepted
PASS: marker-only .test control remains accepted
PASS: bare, wrapped, continued, later-block, and broader shell contexts select the complete path
PASS: direct script command selects its first token
PASS: reporter marker prefix is never checked as a missing file
PASS: compound-test marker prefix is never checked as a missing file
PASS: compound matrix has no aggregate missing-file failure
```

```text
--- Check 8: Test File Existence ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
--- BUG-019 missing-file enforcement exit=0 ---
PASS: missing-file control reaches production Check 8
FAIL: genuinely missing allowed test path exits nonzero (expected nonzero exit, got 0)
FAIL: structured result attributes the block to Check 8 file existence (missing: failedChecks: [Check-8-file-existence])
PASS: missing allowed path is not misclassified as no concrete path
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=27
FAILED=11
BUG-019 state-transition Check 8 regression FAILED
BUG022_REPRODUCTION_EXIT=1
BUG022_BEFORE_FIX_REPRODUCTION_END
```

### Reproduction Interpretation

**Claim Source:** interpreted

The parser-specific discriminator succeeds before the abort:

- the compound matrix reaches production Check 8;
- complete `.spec.mjs` and `.test.mjs` branches pass;
- extension-prefix/prose adversaries reach their intended Check 8 path; and
- the first missing-file check also reaches Check 8.

The failure is therefore not BUG-019 parser truncation and not missing
`jq`/`yq`. It is the subsequent Bash 3.2 empty-array nounset boundary. The
missing-file fixture's caller-visible exit `0` is a secondary symptom caused by
the abrupt guard termination inside the harness and must not be accepted as
normal failure semantics.

## Static Empty-Array Expansion Audit

**Claim Source:** interpreted

The complete source-level inventory and line-by-line zero-state classification
is in [bug.md](bug.md#empty-array-expansion-inventory). Distinct behavior
families are:

1. first insertion and membership checks for pass/fail/check arrays;
2. delivery and blocked structured-result formatting;
3. per-scope discovery with zero scope files;
4. per-scope report discovery with zero report files;
5. first inline evidence hash comparison; and
6. final planning-failure gate lookup with no failed gate IDs.

Count-only expansions and expansions dominated by a positive count guard are
recorded as controls, not findings. The production source was read only.

## Finding Accounting

| Finding | Intake disposition | Owner |
| --- | --- | --- |
| `TEST-019-005-BASH32-EMPTY-ARRAY` | Addressed at intake: BUG-022 packet exists with current before-fix evidence and complete source inventory. BUG-019 execution dependency remains unresolved until repair evidence returns. | BUG-022 packet |
| `BUG022-F001` | Confirmed: first empty `passed_gate_ids[@]` abort at line 72. | `bubbles.design`, then delivery owners |
| `BUG022-F002` | Confirmed: first empty `failed_check_ids[@]` abort at line 82. | `bubbles.design`, then delivery owners |
| `BUG022-F003` | Static finding: first empty `failed_gate_ids[@]` can abort at line 77. | `bubbles.design` |
| `BUG022-F004` | Static finding: empty result-format arrays at lines 124, 128-129, and 142-145 can abort; delivery `notApplicableChecks` is an expected zero state. | `bubbles.design` |
| `BUG022-F005` | Static finding: per-scope zero discovery can abort at the complete `scope_files` site set before intended diagnostics. | `bubbles.design` |
| `BUG022-F006` | Static finding: zero per-scope reports can abort at lines 2464, 2510, 2712, 3002, and 3041. | `bubbles.design` |
| `BUG022-F007` | Static finding: first inline evidence block can abort at empty `evidence_hashes[@]` line 2642. | `bubbles.design` |
| `BUG022-F008` | Static finding: planning failure with no gate ID can abort at line 3458. | `bubbles.design` |
| `PLAN-022-001` | Owner route: reconcile executable scope/test numbering and JSON/Markdown parity after design. | `bubbles.plan` |
| `TEST-022-001` | Owner route: author final persistent test and capture valid final-byte RED before source repair. | `bubbles.test` after planning |
| `IMPLEMENT-022-001` | No source change authorized by intake. | `bubbles.implement` after valid RED |
| `REGISTRY-022-001` | `BUGS.md` is shared dirty work; registration was not edited. | `bubbles.bug` after shared ownership reconciliation |
| `RELEASE-022-001` | No generated release metadata changed or release command run. | `bubbles.releases` after stable source/test inputs |
| `PROPAGATION-022-001` | Research Lab and downstream installed bytes remain unchanged; supported propagation must consume a canonical release/install path. | `bubbles.releases`, then downstream upgrade owner |
| `VALIDATE-022-001` | Certification and terminal status remain blocked and unclaimed. | `bubbles.validate` after delivery evidence |
| `SCHEMA-022-001` | Nonblocking notice retained: artifact lint reports `certification.scopeProgress` deprecated while the current neighboring BUG-019/020/021 shape and loaded bug template still require it. Intake preserves the canonical shape rather than choosing a schema migration. | `bubbles.plan` after design reconciliation |

## Ownership Separation

- BUG-019/BUG-012 dirty `state-transition-guard.sh`: preserved byte-for-byte.
- BUG-020 dirty `fun-mode.sh`: preserved byte-for-byte.
- BUG-021 dirty `framework-validate.sh`: preserved byte-for-byte.
- Existing regression tests: preserved byte-for-byte.
- `BUGS.md`: preserved byte-for-byte because concurrent ownership is unsafe.
- Release metadata and Research Lab: untouched.

## Planned Regression Contract

**Claim Source:** not-run

The provisional intake contract requires zero, one, and multiple element
production cases, plus independently named reintroduction mutations for every
distinct zero-state family. The final physical test, test number, exact fixture
architecture, RED digest, and Markdown/JSON parity belong to `bubbles.plan`
and `bubbles.test` after design reconciliation. No such execution is claimed
here.

## Focused Intake Checks

**Claim Source:** executed

| Check | Exact command | Exit | Disposition |
| --- | --- | ---: | --- |
| Artifact shape | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | PASS; required packet and nonterminal state are valid |
| Freshness | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | PASS; zero failures and warnings |
| Bash 3.2 semantics | `/bin/bash` zero/one/multiple nounset discriminator | 0 | PASS; count-only is safe, empty direct expansion aborts, one/multiple succeed |
| Initial JSON probe | `jq -e empty <three-json-files>` | 4 | Check-design false negative; `empty` emits no value under `-e` |
| Corrected JSON integrity | `jq -e 'type == "object"' <three-json-files>` plus inventory queries | 0 | PASS; 3 scenarios and 13 test rows |
| Source inventory | `node -e '<read-only exact array-site audit>'` | 0 | PASS; all inventoried current line sets found |
| Protected boundary | `git status --short --untracked-files=all -- <protected-surfaces> <BUG-022>` plus absent-`test_29` assertion | 0 | PASS; prior dirty ownership remains visible and only the packet is new for BUG-022 |
| Initial traceability | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 1 | Found expected missing test plus 3 packet-owned DoD fidelity gaps |
| Reconciled traceability | same command after exact scenario DoD repair | 1 | Expected intake refusal only: 7 missing-`test_29` findings; 3/3 DoD fidelity passes |
| Initial capability check | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 1 | Packet-owned heading mismatch found |
| Intermediate capability check | same command after split headings | 1 | Packet was incorrectly classified as foundation plus concrete split |
| Final capability check | same command after level-three single-implementation declaration | 0 | PASS; one existing implementation authority recognized |
| Editor diagnostics | `get_errors` on the BUG-022 directory after newline repair | 0 | PASS; no errors found |

### Artifact And Freshness Raw Output

```text
Required artifact exists: spec.md
Required artifact exists: design.md
Required artifact exists: uservalidation.md
Required artifact exists: state.json
Required artifact exists: scopes.md
Required artifact exists: report.md
No forbidden sidecar artifacts present
Found DoD section in scopes.md
scopes.md DoD contains checkbox items
All DoD bullet items use checkbox syntax in scopes.md
Found Checklist section in uservalidation.md
uservalidation checklist contains checkbox entries
Top-level status matches certification.status
Artifact lint PASSED.
spec.md has no superseded/suppressed sections
design.md has no superseded/suppressed sections
No spec/design freshness boundaries detected
scopes.md has no superseded scope section
No superseded scope sections detected
RESULT: PASS (0 failures, 0 warnings)
BUG022_ARTIFACT_FRESHNESS_EXIT=0
```

The artifact lint also emitted the neighboring-packet-compatible notice that
`certification.scopeProgress` is deprecated. It did not block the packet and
was not represented as a clean/no-notice result.

### Bash 3.2 Cardinality Raw Output

```text
BUG022_BASH32_ARRAY_SEMANTICS_BEGIN
BASH_VERSION=3.2.57(1)-release
OUTER_NOUNSET=off
ZERO_COUNT=0
ZERO_COUNT_EXIT=0
/bin/bash: values[@]: unbound variable
ZERO_EXPANSION_EXIT=127
ONE_COUNT=1
ONE_VALUE=G001
ONE_EXPANSION_EXIT=0
MULTI_COUNT=3
MULTI_VALUE=G001
MULTI_VALUE=G002
MULTI_VALUE=G003
MULTI_EXPANSION_EXIT=0
SEMANTICS_RESULT=PASS
BUG022_BASH32_ARRAY_SEMANTICS_END
```

Each nested discriminator enabled `set -u`; `OUTER_NOUNSET=off` describes only
the supervising shell used to capture all four child exits. Exit `127` is the
actual Bash 3.2 nounset child exit observed for the empty direct expansion.

### Source Inventory Raw Output

```text
BUG022_SOURCE_ARRAY_AUDIT_BEGIN
ARRAY=passed_gate_ids
DIRECT_LINES=72,128
ARRAY=failed_gate_ids
DIRECT_LINES=77,129,144,3458
COUNT_LINES=3452
ARRAY=failed_check_ids
DIRECT_LINES=82,145
COUNT_LINES=3452
ARRAY=transition_required_gate_ids
DIRECT_LINES=124
ARRAY=transition_applicable_check_classes
DIRECT_LINES=141
ARRAY=transition_not_applicable_checks
DIRECT_LINES=142
ARRAY=effective_passed_gate_ids
DIRECT_LINES=143
ARRAY=scope_files
DIRECT_LINES=558,563,564,575,594,637,1004,1022,1056,1115,1167,1186,1245,1313,1363,2142,2351,2454,2627,2750,2974,3055,3079
COUNT_LINES=570,571,630,631,647
ARRAY=report_files
DIRECT_LINES=2464,2510,2712,3002,3041
COUNT_LINES=2479
ARRAY=evidence_hashes
DIRECT_LINES=2642
SOURCE_BYTES_UNCHANGED_BY_AUDIT=yes
AUDIT_RESULT=PASS
BUG022_SOURCE_ARRAY_AUDIT_END
BUG022_SOURCE_ARRAY_AUDIT_EXIT=0
```

### Corrected JSON Raw Output

```text
true
true
true
BUG022_JSON_PARSE=PASS
SCENARIO_COUNT=3
SCENARIO=SCN-BUG-022-001 LINKED_TESTS=1
SCENARIO=SCN-BUG-022-002 LINKED_TESTS=1
SCENARIO=SCN-BUG-022-003 LINKED_TESTS=2
TEST_COUNT=13
TEST=T-BUG-022-00 CATEGORY=functional
TEST=T-BUG-022-01 CATEGORY=functional
TEST=T-BUG-022-02 CATEGORY=e2e-api
TEST=T-BUG-022-03 CATEGORY=e2e-api
TEST=T-BUG-022-04 CATEGORY=e2e-api
TEST=T-BUG-022-05 CATEGORY=e2e-api
TEST=T-BUG-022-06 CATEGORY=functional
TEST=T-BUG-022-07 CATEGORY=integration
TEST=T-BUG-022-08 CATEGORY=e2e-api
TEST=T-BUG-022-09 CATEGORY=functional
TEST=T-BUG-022-10 CATEGORY=integration
TEST=T-BUG-022-11 CATEGORY=e2e-api
TEST=T-BUG-022-12 CATEGORY=integration
BUG022_JSON_INTEGRITY_EXIT=0
```

The earlier `jq -e empty` exit `4` did not identify malformed JSON. The
corrected predicate produced three `true` values and exit `0`; the false
negative is retained here so the failed check does not disappear.

### Traceability Handoff Raw Output

```text
scenario-manifest.json covers 3 scenario contract(s)
scenario-manifest.json references missing linked test file: tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
scenario-manifest.json records evidenceRefs
Scope 1 scenario mapped to Test Plan row: Zero-element states remain valid and observable
Scope 1 mapped row references no existing concrete test file: Zero-element states remain valid and observable
Scope 1 scenario mapped to Test Plan row: One element crosses the empty accumulator boundary exactly once
Scope 1 mapped row references no existing concrete test file: One element crosses the empty accumulator boundary exactly once
Scope 1 scenario mapped to Test Plan row: Multiple elements preserve ordering and failure semantics
Scope 1 mapped row references no existing concrete test file: Multiple elements preserve ordering and failure semantics
Scope 1 scenario maps to DoD item: Zero-element states remain valid and observable
Scope 1 scenario maps to DoD item: One element crosses the empty accumulator boundary exactly once
Scope 1 scenario maps to DoD item: Multiple elements preserve ordering and failure semantics
DoD fidelity: 3 scenarios checked, 3 mapped to DoD, 0 unmapped
Scenarios checked: 3
Test rows checked: 13
Scenario-to-row mappings: 3
Concrete test file references: 0
DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: FAILED (7 failures, 0 warnings)
BUG022_TRACEABILITY_RERUN_EXIT=1
```

This nonzero result is the intended nonterminal handoff. Creating `test_29` to
silence it would violate the user's intake-only boundary and test ownership.

### Capability Proportionality Raw Output

```text
capability-foundation-guard: Gate G094 applies: triggerHits=5 concreteImplementationEntries=0
capability-foundation-guard: spec.md contains non-empty Single-Capability Justification
capability-foundation-guard: design.md contains non-empty Single-Implementation Justification
capability-foundation-guard: UX primitive check not applicable: screenCount=0 uiReuseHits=0
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
BUG022_CAPABILITY_FOUNDATION_FINAL_EXIT=0
```

### Intake Check Finding Closure

| Finding | Resolution |
| --- | --- |
| `INTAKE-022-001-JSON-PROBE` | Addressed: retained exit `4`, corrected `jq -e empty` misuse, and reran with an object predicate at exit `0`. |
| `INTAKE-022-002-DOD-FIDELITY` | Addressed: exact zero/one/multiple scenario claims now appear in DoD; rerun reports 3/3 mapped. |
| `INTAKE-022-003-G094-HEADING` | Addressed: level-three Single-Implementation Justification now selects the narrow implementation path; final G094 exits `0`. |
| `INTAKE-022-004-MARKDOWN-NEWLINE` | Addressed: six MD047 terminal-newline diagnostics were repaired; final editor diagnostics report no errors. |
| `TEST-022-001-MISSING-REGRESSION` | Unresolved by design at intake: seven traceability findings all derive from the absent test-owned `test_29`; owner is `bubbles.test` after design and planning. |
| `SCHEMA-022-001-SCOPE-PROGRESS` | Unresolved nonblocking compatibility notice; planner owns reconciliation against the canonical state schema after design. |

## Invocation Audit

No subagents were invoked. The available runtime exposed no `runSubagent`
surface, and the user restricted this invocation to intake/reproduction. The
packet routes design ownership to `bubbles.design` rather than impersonating
that specialist.

## Test-Owned Final-Byte RED Recapture - 2026-07-17

### Test Phase Summary

`bubbles.test` retained the complete physical regression byte-for-byte and
froze SHA-256
`4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`
as the current RED identity. The exact synchronized `T-BUG-022-01` command ran
first against unchanged production and produced a valid causal RED under stock
macOS Bash 3.2.57. No production, planning, scenario-manifest, sibling,
registration, installer, release, downstream, DoD, completion, or
certification byte changed during the round.

The frozen production identities are:

| Production surface | SHA-256 |
| --- | --- |
| `bubbles/scripts/state-transition-guard.sh` | `09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a` |
| `bubbles/scripts/guards/planning-checks.sh` | `a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583` |
| `bubbles/scripts/guards/control-plane-checks.sh` | `1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22` |

### Current Final-Byte Stock Bash RED

**Phase:** test
**Executed:** YES (current session)
**Command:** `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`
**Exit Code:** 1
**Claim Source:** executed
**Result:** `VALID_PRE_FIX_RED` against all 43 unchanged raw production sites.

Contiguous final summary window from the preserved raw transcript:

```text
=== BUG-022 regression summary ===
ACTIVE_PLATFORM=Darwin
ACTIVE_BASH_LANE=macos-stock-bash32
ACTIVE_BASH_VERSION=3.2.57(1)-release
TEST_FILE_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
GREEN_MUST_USE_TEST_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
SOURCE_GUARD_SHA256_AFTER=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
PLANNING_CHECKS_SHA256_AFTER=a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583
CONTROL_PLANE_CHECKS_SHA256_AFTER=1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22
CANONICAL_MAPPED_GUARDED=0
CANONICAL_MAPPED_RAW=40
CANONICAL_MODULE_MAPPED_GUARDED=0
CANONICAL_MODULE_MAPPED_RAW=3
PRIMARY_RUNS=11
REFERENCE_CONTROL_RUNS=11
PRIMARY_INTENDED_NOUNSET_ABORTS=11
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=10
SITE_MUTANT_RUNS=43
SITE_MUTANT_REJECTIONS=43
GUARD_RUNS=32
ASSERTIONS=306
PASSED=208
CONTRACT_FAILURES=98
PRIMARY_CONTRACT_FAILURES=98
CONTROL_FAILURES=0
HARNESS_FAILURES=0
BUG022_RED_DISPOSITION=VALID_PRE_FIX_RED
BUG-022 state-transition Bash 3.2 empty-array regression FAILED.
T_BUG_022_01_EXIT=1
```

The 98 contract failures are all canonical-production assertions downstream
of the 11 mapped Bash 3.2 nounset aborts. The repaired-reference controls
recorded zero failures, every fixture executed, every independently staged
mutant was rejected, and no unrelated abort occurred.

### Explicit Newer macOS Bash Comparison

**Phase:** test
**Executed:** YES (current session)
**Command:** `if [[ -x /opt/homebrew/bin/bash ]]; then /opt/homebrew/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; elif [[ -x /opt/local/bin/bash ]]; then /opt/local/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; else printf '%s\n' 'required newer macOS Bash is unavailable'; exit 2; fi`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** Explicit Homebrew Bash 5.3.15 tolerates the raw empty-array
expansions, so all 11 canonical fixtures reach complete results. The only two
contract failures are the truthful unchanged-source inventory assertions: 40
main and three sourced-module sites remain raw. This is comparison evidence,
not GREEN.

```text
=== BUG-022 regression summary ===
ACTIVE_PLATFORM=Darwin
ACTIVE_BASH_LANE=macos-explicit-newer-bash
ACTIVE_BASH_VERSION=5.3.15(1)-release
TEST_FILE_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
SOURCE_GUARD_SHA256_AFTER=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
CANONICAL_MAPPED_GUARDED=0
CANONICAL_MAPPED_RAW=40
CANONICAL_MODULE_MAPPED_GUARDED=0
CANONICAL_MODULE_MAPPED_RAW=3
PRIMARY_RUNS=11
REFERENCE_CONTROL_RUNS=11
PRIMARY_INTENDED_NOUNSET_ABORTS=0
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=10
SITE_MUTANT_RUNS=43
SITE_MUTANT_REJECTIONS=43
GUARD_RUNS=32
ASSERTIONS=306
PASSED=304
CONTRACT_FAILURES=2
PRIMARY_CONTRACT_FAILURES=2
CONTROL_FAILURES=0
HARNESS_FAILURES=0
BUG022_RED_DISPOSITION=RED_INVALID_MIXED_OR_UNRELATED_FAILURE
BUG-022 state-transition Bash 3.2 empty-array regression FAILED.
T_BUG_022_13_EXIT=1
```

### BUG-019 Compatibility Before Repair

**Phase:** test
**Executed:** YES (current session)
**Command:** `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed
**Result:** Expected pre-repair compatibility RED. Parser-specific Check 8
assertions still pass; the unchanged guard aborts only at the mapped line 72
and line 82 empty-array boundaries.

```text
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 72: passed_gate_ids[@]: unbound variable
PASS: compound matrix reaches production Check 8
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: ordinary .spec.ts control remains complete
PASS: ordinary .test.js control remains complete
PASS: marker-only .spec control remains accepted
PASS: marker-only .test control remains accepted
PASS: missing-file control reaches production Check 8
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=27
FAILED=11
BUG-019 state-transition Check 8 regression FAILED
T_BUG_022_08_EXIT=1
```

### Focused Test-Phase Checks

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed

| Check | Exact command | Exit | Observed result |
| --- | --- | ---: | --- |
| Regression quality | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | 0 | One file scanned; one adversarial signal; zero violations and warnings. |
| Three-file syntax and strict mode | Exact `T-BUG-022-06` command from synchronized `test-plan.json` | 0 | All three files parse under `/bin/bash`; main guard retains one `set -euo pipefail`; no suppression, indirection, sentinel, or bypass matched. |
| Physical test portability | `bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | 0 | All 13 portability classes pass. |
| Portability selftest | `bash bubbles/scripts/macos-portability-guard-selftest.sh` | 0 | Green fixture and all 13 red discriminators pass. |
| Artifact shape | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Passed; retained the existing nonblocking deprecated-`scopeProgress` notice. |
| Artifact freshness | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Passed with zero failures and warnings. |
| G094 | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Single-capability and single-implementation justification accepted. |
| Traceability | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Three scenarios, 21 rows, three concrete test references, three report references, and 3/3 DoD mappings. |
| Corrected parity discriminator | Current-session object-aware read-only Node discriminator | 0 | 21 Markdown rows, 21 JSON rows, 21 test DoD items, three scenarios, four manifest links, zero checked DoD. |
| Corrected collision discriminator | Current-session read-only SHA-256 map | 0 | All 44 packet/test/source/sibling/release identities matched; zero unexpected mutations. |

Corrected parity raw output:

```text
BUG022_PARITY_BEGIN
MARKDOWN_TEST_ROWS=21
JSON_TEST_ROWS=21
TEST_DOD_ITEMS=21
UNIQUE_MARKDOWN_TEST_IDS=21
UNIQUE_JSON_TEST_IDS=21
MARKDOWN_SCENARIOS=3
MANIFEST_SCENARIOS=3
MANIFEST_PHYSICAL_TEST_LINKS=4
CHECKED_DOD_ITEMS=0
T_BUG_022_06_SOURCE_FILES=3
T_BUG_022_09_PHYSICAL_PATH=yes
CURRENT_NEXT_REQUIRED_OWNER=bubbles.test
BUG022_PARITY_EXIT=0
BUG022_PARITY_END
```

Corrected protected-identity summary:

```text
IDENTITY_OK sha256=2368793f0627adb39a1ef0663e19a3b81443c9926c656663d40d392b0fe3b7bb path=improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md
IDENTITY_OK sha256=8c29cebfaa27da9e12e0eb41843acccf7e9abe01729147bbb90638da10534a01 path=improvements/BUG-022-state-transition-bash32-empty-array-nounset/scopes.md
IDENTITY_OK sha256=5cf9aab4927b73fabe5fa730a5450e6605e50360ea17f6c8477aee56472101cf path=improvements/BUG-022-state-transition-bash32-empty-array-nounset/test-plan.json
IDENTITY_OK sha256=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17 path=tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
IDENTITY_OK sha256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a path=bubbles/scripts/state-transition-guard.sh
IDENTITY_OK sha256=a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583 path=bubbles/scripts/guards/planning-checks.sh
IDENTITY_OK sha256=1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22 path=bubbles/scripts/guards/control-plane-checks.sh
IDENTITY_OK sha256=5fd3cc5e870d74e7b94454119e4eee8d6dd369111a2e0f5f3eed9ee9fc93fdc9 path=improvements/BUG-019-state-transition-spec-mjs-path/state.json
IDENTITY_OK sha256=9c40a1b4adeb8c0fb1b136de149f77f8b770134887c2ca02a008043d6ca1253f path=improvements/BUG-020-state-transition-bash32-startup/state.json
IDENTITY_OK sha256=808cf3da1d6714115acb83efd3827e83fbbc35e2799316e0a8a671a74542714d path=improvements/BUG-021-framework-validate-raw-timeout/state.json
IDENTITY_OK sha256=c329e52c490fbbb52a2c139c59cf2a182a6b8906f75491c1e0c24a1611efce70 path=bubbles/release-manifest.json
IDENTITIES_CHECKED=44
UNEXPECTED_MUTATIONS=0
BUG022_COLLISION_CHECK_EXIT=0
BUG022_COLLISION_CHECK_END
```

### Preserved Probe Failures

Every failed diagnostic in this round remains accounted for:

| Probe | Observed failure | Corrected disposition |
| --- | --- | --- |
| Initial protected snapshot | Guessed nonexistent `tests/regression/test_28_framework_validate_raw_timeout.sh`; `shasum` stopped before the protected portion. | Re-ran with physical `test_28_framework_validate_portable_timeout.sh` and captured all sibling identities. |
| Initial parity discriminator | `PARITY_FAIL=manifest-physical-test-link`; treated object-valued `linkedTests` as path strings. | Re-ran object-aware; exact parity output above exits 0. |
| Initial collision discriminator | Expected main-guard literal was mistyped; observed authoritative hash remained `09a735...c727a`. | Re-ran with the frozen authoritative literal; all 44 identities match. |
| Initial timestamp formatting | BSD `stat` rendered local time while the format string included `Z`. | Re-derived epoch mtime with UTC `date`; observed start is `2026-07-17T06:29:10Z`. |

### Runtime-Lane Honesty

**Phase:** test
**Claim Source:** not-run
**Reason:** No independent Linux or WSL runtime was invoked in this macOS test
round. The Bash 5.3 Homebrew run is macOS comparison evidence and is not
represented as Linux evidence.

### Input Ledger And Routing

| Finding | Current disposition | Owner |
| --- | --- | --- |
| `DESIGN-022-001-SOURCED-MODULE-SURFACE-OMITTED` | Addressed and reverified: authoritative design SHA-256 `2368793f...e3b7bb` defines one atomic three-file/43-site repair. | `bubbles.design` |
| `PLAN-022-003-SOURCED-MODULE-BOUNDARY-OMITTED` | Addressed and reverified: synchronized scopes SHA-256 `8c29cebf...534a01` carries the 40 + 1 + 2 boundary. | `bubbles.plan` |
| `PLAN-022-002-REGRESSION-QUALITY-COMMAND` | Addressed and reverified: test-plan SHA-256 `5cf9aab4...2101cf` targets the physical `test_29` path; the command exits 0. | `bubbles.plan` |
| `TEST-022-006-FINAL-BYTE-HASH-DRIFT` | Addressed: physical SHA-256 `4fba2c2f...156c17` is now frozen and has current causal stock-Bash RED identity. | `bubbles.test` |
| `IMPLEMENT-022-001-MAIN-GUARD-RAW-SITES` | Unresolved: 40 accepted main-guard sites remain raw. | `bubbles.implement` |
| `IMPLEMENT-022-002-SOURCED-MODULE-RAW-SITES` | Unresolved: one planning and two control-plane sites remain raw. | `bubbles.implement` |
| `TEST-022-005-IDENTICAL-BYTE-GREEN` | Unresolved: exact SHA-256 `4fba2c2f...156c17` must be reused after the atomic source repair. | `bubbles.test` after implementation |

**Routing disposition:** `route_required` to `bubbles.implement` for one atomic
43-site token repair using the three frozen production hashes above. Status and
certification remain `blocked`; no scope or DoD completion is claimed.

### Post-Edit Containment And Harness Audit

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed

The first post-edit byte-reconstruction probe parsed and reserialized JSON and
therefore failed to recreate the original byte stream:

```text
POST_EDIT_FAIL=state-reconstruction:45b6b09ef075df145dcd163e8c1caac4920f1cf5e36b5e1d82340485db69e9e5
```

That check changed no file. The corrected discriminator reversed the exact
textual `execution`, `executionHistory`, and `updatedAt` edits in memory. It
proved append-only report content, execution-only state content, unchanged
protected bytes, and zero completion/certification claims:

```text
BUG022_POST_EDIT_CONTAINMENT_BEGIN
REPORT_PREFIX_SHA256=073accc43b1da7c2b683dfe1ed299ccb786dd5405d8df7965a5644af0b292347
REPORT_CURRENT_SHA256=5575d9e78205e7890048cbf1c4ded3773a9231181d966d004d38e4fc226e0e36
STATE_RECONSTRUCTED_PREEDIT_SHA256=082debb4fd70b88e5b9f1fca11e64d1b96522905bc46a35c0bdf5e740f9de5bd
STATE_CURRENT_SHA256=108e72b3e2a359312b14e8c9b1207c0ba8a1f056afa0f43911fc3683fa63716c
PROTECTED_IDENTITIES_CHECKED=21
PROTECTED_IDENTITY_MISMATCHES=0
TEST_FILE_SHA256=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
MAIN_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
PLANNING_CHECKS_SHA256=a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583
CONTROL_PLANE_CHECKS_SHA256=1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22
NEXT_REQUIRED_OWNER=bubbles.implement
TOP_LEVEL_STATUS=blocked
CERTIFICATION_STATUS=blocked
COMPLETED_PHASE_CLAIMS=0
CERTIFIED_COMPLETED_PHASES=0
BUG022_POST_EDIT_CONTAINMENT_EXIT=0
BUG022_POST_EDIT_CONTAINMENT_END
```

The physical regression's final integrity audit also passed:

```text
BUG022_HARNESS_AUDIT_BEGIN
BASH32_SYNTAX=PASS
SHEBANG=usr-bin-env-bash
STRICT_OPTIONS=set-minus-u-o-pipefail
FUNCTION_DEFINITIONS=47
DUPLICATE_FUNCTIONS=0
SKIP_MARKERS=0
INTERCEPTION_MARKERS=0
RED_BYPASS_MARKERS=0
SUMMARY_MARKERS=1
FINAL_SUCCESS_MARKERS=1
REAL_PRODUCTION_GUARD_INVOCATION=yes
INDEPENDENT_REPAIRED_REFERENCE_CONTROL=yes
BUG022_HARNESS_AUDIT_EXIT=0
BUG022_HARNESS_AUDIT_END
```

## Implementation Continuation - 2026-07-17

### Implementation Summary

`bubbles.implement` resumed after the atomic source edit and reverified the
frozen test, all three edited source hashes, packet ownership, planning
artifacts, sibling states, and release manifest before behavior execution. The
implementation-owned main and sourced-module findings are addressed. The
packet remains `blocked`, every DoD item remains unchecked, completion and
certification arrays remain empty, and independent identical-byte GREEN
closure remains owned by `bubbles.test`.

### Immediate Frozen-Harness Validation

**Phase:** implement
**Executed:** YES (current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG022_IMPLEMENT_GREEN_BEGIN' && printf '%s\n' 'PRE_HARNESS_HASHES' && shasum -a 256 tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/planning-checks.sh bubbles/scripts/guards/control-plane-checks.sh && jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; test_exit=$?; printf '%s\n' 'POST_HARNESS_HASHES' && shasum -a 256 tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/planning-checks.sh bubbles/scripts/guards/control-plane-checks.sh; printf 'BUG022_IMPLEMENT_GREEN_EXIT=%s\n' "$test_exit"; printf '%s\n' 'BUG022_IMPLEMENT_GREEN_END'; exit "$test_exit"`
**Exit Code:** 0
**Claim Source:** executed
**Result:** Implementation-side immediate validation observed
`CURRENT_SOURCE_GREEN`; independent test-phase closure is not claimed.

```text
=== BUG-022 regression summary ===
ACTIVE_PLATFORM=Darwin
ACTIVE_BASH_LANE=macos-stock-bash32
ACTIVE_BASH_VERSION=3.2.57(1)-release
TEST_FILE_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
GREEN_MUST_USE_TEST_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
SOURCE_GUARD_SHA256_AFTER=a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538
PLANNING_CHECKS_SHA256_AFTER=904fa6205820351ff059741f7939b4a7fac0040d35e00f33a3b3642822eb998f
CONTROL_PLANE_CHECKS_SHA256_AFTER=08f09b51c0733b796e9a4a750cd1536a7b709934019f9df4e123706991566f4c
CANONICAL_MAPPED_GUARDED=40
CANONICAL_MAPPED_RAW=0
CANONICAL_MODULE_MAPPED_GUARDED=3
CANONICAL_MODULE_MAPPED_RAW=0
PRIMARY_RUNS=11
REFERENCE_CONTROL_RUNS=11
PRIMARY_INTENDED_NOUNSET_ABORTS=0
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=10
SITE_MUTANT_RUNS=43
SITE_MUTANT_REJECTIONS=43
GUARD_RUNS=32
ASSERTIONS=306
PASSED=306
CONTRACT_FAILURES=0
PRIMARY_CONTRACT_FAILURES=0
CONTROL_FAILURES=0
HARNESS_FAILURES=0
BUG022_RED_DISPOSITION=CURRENT_SOURCE_GREEN
BUG-022 state-transition Bash 3.2 empty-array regression passed.
BUG022_IMPLEMENT_GREEN_EXIT=0
BUG022_IMPLEMENT_GREEN_END
```

### Implementation-Owned Production Change Containment

**Phase:** implement
**Executed:** YES (current session)
**Command:** `/bin/bash -n` on all three production files, the exact
`T-BUG-022-06` strict-mode/no-bypass scan, and a read-only Node SHA-256
discriminator that replaced only each
`${array[@]+"${array[@]}"}` token in memory with the pre-edit raw expansion.
**Exit Code:** 0
**Claim Source:** executed
**Result:** Exactly 43 mapped token changes reconstruct the three accepted
pre-edit hashes; every nonmapped byte and the one raw positive-count control
are preserved.

```text
BUG022_IMPLEMENT_STATIC_BEGIN
BASH32_SYNTAX_MAIN=PASS
BASH32_SYNTAX_PLANNING=PASS
BASH32_SYNTAX_CONTROL_PLANE=PASS
26:set -euo pipefail
STRICT_MODE_NO_BYPASS=PASS
CONTAINMENT_OK path=bubbles/scripts/state-transition-guard.sh mapped=40 pre=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a post=a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538
CONTAINMENT_OK path=bubbles/scripts/guards/planning-checks.sh mapped=1 pre=a1cadf14af7a9fbeae330046829406de66e68adff1d79c6ca78b0d17d5548583 post=904fa6205820351ff059741f7939b4a7fac0040d35e00f33a3b3642822eb998f
CONTAINMENT_OK path=bubbles/scripts/guards/control-plane-checks.sh mapped=2 pre=1b335d860a02343bb5f946ab8575b4ec065ba82a40439361a330dd0181382d22 post=08f09b51c0733b796e9a4a750cd1536a7b709934019f9df4e123706991566f4c
MAPPED_TOKEN_CHANGES=43
NONMAPPED_BYTES_PRESERVED=yes
RAW_POSITIVE_COUNT_CONTROLS=1
POST_INVENTORY_MAIN_GUARDED_LINES=40
POST_INVENTORY_PLANNING_GUARDED_LINES=1
POST_INVENTORY_CONTROL_PLANE_GUARDED_LINES=1
RAW_POSITIVE_COUNT_CONTROL_LINE=575
BUG022_IMPLEMENT_STATIC_EXIT=0
BUG022_IMPLEMENT_STATIC_END
```

### Focused Implementation Checks

**Phase:** implement
**Executed:** YES (current session)
**Claim Source:** executed

| Check | Exit | Current observation |
| --- | ---: | --- |
| BUG-019 compatibility under stock Bash 3.2 | 0 | `ASSERTIONS=38`, `PASSED=38`, `FAILED=0`; frozen test and three source hashes unchanged before/after. |
| Regression quality | 0 | One file scanned, one adversarial signal, zero violations, zero warnings. |
| Physical test portability | 0 | All 13 WSL/macOS portability classes passed. |
| Portability enforcement selftest | 0 | Green fixture and all 13 red class discriminators passed. |
| Artifact lint | 0 | Packet passed; existing deprecated `scopeProgress` notice remains nonblocking. |
| Artifact freshness | 0 | Zero failures and zero warnings. |
| G094 capability proportionality | 0 | Single-capability and single-implementation justifications accepted. |
| Traceability | 0 | Three scenarios, 21 rows, four manifest links, and 3/3 DoD mappings passed. |
| Corrected object-aware parity | 0 | 21 Markdown rows, 21 JSON rows, 21 test DoD items, zero field mismatches, zero checked DoD. |

### Diagnostic Probe Accounting

| Probe | Observed result | Current disposition |
| --- | --- | --- |
| Initial persisted-mode resolution | Exit nonzero because v7 rejects a removed v5 mode name as new operator input. | Re-ran with `BUBBLES_MODE_GRANDFATHER=1`; persisted `bugfix-fastlane` resolved to `statusCeiling: done`. The short-circuited hash fence was rerun in full. |
| Initial parity discriminator | Found `T-BUG-022-06:file` and printed `T_BUG_022_09_PHYSICAL_PATH=no` because it compared the three-file Markdown cell as one path and compared the guard file rather than the command target. | Corrected the read-only discriminator to compare `sourceFiles[]` and the quality command target; all 21 rows passed with `FIELD_MISMATCHES=0`. No file changed during either probe. |
| First closeout report-prefix fence | Detected a changed accepted-prefix hash because the MD024 repair had renamed the earlier template heading rather than the appended duplicate. | Restored the template heading and renamed only the appended implementation heading; editor diagnostics and artifact lint passed. |
| Second closeout report-prefix fence | Included the newly appended blank separator in the accepted prefix because the discriminator sliced through `boundary + 1`. | Corrected the read-only boundary to slice before the appended separator; accepted prefix SHA-256 returned exactly `a64dadcd234e0649c6de76800ac23543f05f26cfcc2c2b4bc41153d61b49eb38`. |

### Finding Closure And Routing

| Finding | Implementation disposition |
| --- | --- |
| `DESIGN-022-001-SOURCED-MODULE-SURFACE-OMITTED` | Preserved addressed: design SHA-256 `2368793f0627adb39a1ef0663e19a3b81443c9926c656663d40d392b0fe3b7bb`. |
| `PLAN-022-003-SOURCED-MODULE-BOUNDARY-OMITTED` | Preserved addressed: scopes SHA-256 `8c29cebfaa27da9e12e0eb41843acccf7e9abe01729147bbb90638da10534a01`. |
| `PLAN-022-002-REGRESSION-QUALITY-COMMAND` | Preserved addressed: test-plan SHA-256 `5cf9aab4927b73fabe5fa730a5450e6605e50360ea17f6c8477aee56472101cf`; physical-path guard exits 0. |
| `TEST-022-006-FINAL-BYTE-HASH-DRIFT` | Preserved addressed: test SHA-256 remains `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`. |
| `IMPLEMENT-022-001-MAIN-GUARD-RAW-SITES` | Addressed: 40 mapped main sites guarded, zero mapped raw; exact reverse reconstruction equals pre-edit SHA-256 `09a7357b...c727a`. |
| `IMPLEMENT-022-002-SOURCED-MODULE-RAW-SITES` | Addressed: one planning and two control-plane sites guarded, zero mapped raw; exact reverse reconstruction equals both pre-edit hashes. |
| `TEST-022-005-IDENTICAL-BYTE-GREEN` | Unresolved by ownership: immediate implementation validation is green, but independent closure remains routed to `bubbles.test`. |

No framework release generation, release certification, Linux runtime claim,
DoD update, scope completion, status transition, or certification write was
performed in this implementation continuation.

## Test-Owned Independent Stock-Bash GREEN - 2026-07-17T15:03:59Z

### Test Handoff Summary

`bubbles.test` independently reused the frozen physical regression at SHA-256
`4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`.
The exact `T-BUG-022-01` command completed under stock macOS Bash 3.2.57 with
`CURRENT_SOURCE_GREEN`, 306 of 306 assertions, 43 of 43 one-site mutant
rejections, and zero primary, control, harness, or unrelated-abort failures.
The independently rerun BUG-019 compatibility matrix completed at 38 of 38.

The selected focused checks all exited zero. Three additional attempts to run
the identical bytes under explicit Homebrew Bash 5.3.15 were interrupted with
exit 130 before a final regression summary. Those interrupted attempts are not
represented as GREEN. No Linux or WSL command was executed in this test round,
and no Linux result is claimed.

`TEST-022-005-IDENTICAL-BYTE-GREEN` is addressed by the stock-Bash evidence
below. `TEST-022-007-NEWER-MACOS-LANE-INTERRUPTED` remains open with owner
`bubbles.test`; the packet therefore remains blocked in the test phase and is
not routed to regression, release, or certification.

### Independent Stock Bash 3.2 GREEN

**Phase:** test
**Executed:** YES (current session)
**Command:** `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS. This is independent identical-byte GREEN for
`TEST-022-005-IDENTICAL-BYTE-GREEN`.

Final raw summary window from the current-session transcript:

```text
PASS: test_29 remained byte-identical at 4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
PASS: all eleven canonical production fixtures executed without bailout
PASS: all eleven repaired-reference harness controls executed without bailout
PASS: all ten named family mutants executed independently
PASS: all 43 mapped one-site mutants were independently rejected
PASS: all 32 planned production-guard processes executed
PASS: unique disposable regression workspace was removed
=== BUG-022 regression summary ===
ACTIVE_PLATFORM=Darwin
ACTIVE_BASH_LANE=macos-stock-bash32
ACTIVE_BASH_VERSION=3.2.57(1)-release
TEST_FILE_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
GREEN_MUST_USE_TEST_SHA256_FINAL=4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17
SOURCE_GUARD_SHA256_AFTER=a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538
PLANNING_CHECKS_SHA256_AFTER=904fa6205820351ff059741f7939b4a7fac0040d35e00f33a3b3642822eb998f
CONTROL_PLANE_CHECKS_SHA256_AFTER=08f09b51c0733b796e9a4a750cd1536a7b709934019f9df4e123706991566f4c
CANONICAL_MAPPED_GUARDED=40
CANONICAL_MAPPED_RAW=0
CANONICAL_MODULE_MAPPED_GUARDED=3
CANONICAL_MODULE_MAPPED_RAW=0
PRIMARY_RUNS=11
REFERENCE_CONTROL_RUNS=11
PRIMARY_INTENDED_NOUNSET_ABORTS=0
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=10
SITE_MUTANT_RUNS=43
SITE_MUTANT_REJECTIONS=43
GUARD_RUNS=32
ASSERTIONS=306
PASSED=306
CONTRACT_FAILURES=0
PRIMARY_CONTRACT_FAILURES=0
CONTROL_FAILURES=0
HARNESS_FAILURES=0
BUG022_RED_DISPOSITION=CURRENT_SOURCE_GREEN
BUG-022 state-transition Bash 3.2 empty-array regression passed.
T_BUG_022_01_CURRENT_SESSION_EXIT=0
```

The same execution directly covered zero arguments, one nonempty element, one
empty-string element, and multiple values with whitespace, duplicates, and
stable order. Its canonical production fixtures also covered PASS, FAIL,
BLOCKED, zero scopes, zero reports, first/distinct/duplicate evidence hashes,
untagged failure, and `G073` failure classification.

### Independent BUG-019 Compatibility

**Phase:** test
**Executed:** YES (current session)
**Command:** `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS at 38 of 38 assertions.

```text
--- BUG-019 missing-file enforcement exit=1 ---
PASS: missing-file control reaches production Check 8
PASS: genuinely missing allowed test path exits nonzero
PASS: missing allowed path reaches the existing Check 8 failure branch
PASS: missing allowed path contributes to the aggregate failure
PASS: structured result attributes the block to Check 8 file existence
PASS: missing-file control reaches the normal failing verdict
PASS: missing allowed path is not misclassified as no concrete path
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=38
FAILED=0
BUG-019 state-transition Check 8 regression passed.
T_BUG_022_08_CURRENT_SESSION_EXIT=0
```

### Focused Test Checks

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed

| Check | Exact command | Exit | Current observation |
| --- | --- | ---: | --- |
| Regression quality | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | 0 | One file, one adversarial signal, zero violations, zero warnings. |
| Three-file Bash 3.2 syntax and strict/no-bypass | Exact `T-BUG-022-06` command from `test-plan.json` | 0 | All three files parsed; main strict mode remained at line 26; no forbidden suppression, indirection, sentinel, skip, or force pattern matched. |
| Physical test portability | `bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh` | 0 | All 13 portability classes passed. |
| Portability guard selftest | `bash bubbles/scripts/macos-portability-guard-selftest.sh` | 0 | Green fixture, all 13 red discriminators, recursion, env surface, usage, syntax, and self-portability passed. |
| Artifact lint | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Packet passed; the existing deprecated `scopeProgress` notice remains nonblocking. |
| Artifact freshness | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Zero failures and zero warnings. |
| G094 | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Single-capability and single-implementation justification accepted. |
| Traceability | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset` | 0 | Three scenarios, 21 rows, three concrete test refs, three report refs, and 3/3 DoD mappings. |
| JSON/Markdown/DoD parity | Current-session object-aware Node discriminator | 0 | 21/21/21 IDs, zero field mismatches, three scenarios, four manifest links, zero checked DoD. |
| Test integrity | Current-session Bash 3.2 syntax, skip/mock/nonduplication, and corrected dispatch discriminator | 0 | Zero skip/mock/duplicate-function markers; all four canonical/control/mutant dispatches occur exactly once. |

Regression-quality raw output:

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-17T15:10:14Z
  Bugfix mode: true
============================================================

Scanning tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
Adversarial signal detected in tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

Portability selftest raw output:

```text
== macos-portability-guard selftest ==
  PASS: GREEN fixture (portable forms + pragmas + guarded mapfile) -> exit 0
  PASS: RED class1-raw-timeout -> exit 1 + names 'class-1 raw-timeout'
  PASS: RED class2-sed-i -> exit 1 + names 'class-2 in-place-sed'
  PASS: RED class3-date-d -> exit 1 + names 'class-3 date-d-parse'
  PASS: RED class4-stat-c -> exit 1 + names 'class-4 stat-c-mtime'
  PASS: RED class5-readlink-f -> exit 1 + names 'class-5 readlink-f-absolutize'
  PASS: RED class6-grep-P -> exit 1 + names 'class-6 grep-pcre'
  PASS: RED class7-isset -> exit 1 + names 'class-7 bracket-v-isset'
  PASS: RED class8-mapfile -> exit 1 + names 'class-8 mapfile-readarray'
  PASS: RED class9-mktemp-suffix -> exit 1 + names 'class-9 mktemp-suffix'
  PASS: RED class10-df-output -> exit 1 + names 'class-10 df-output'
  PASS: RED class11-bin-true -> exit 1 + names 'class-11 bin-true-false'
  PASS: RED class12-paste -> exit 1 + names 'class-12 paste-no-stdin-operand'
  PASS: RED class13-date-ns -> exit 1 + names 'class-13 date-nanoseconds'
  PASS: directory surface recurses into *.sh (nested dirty file caught)
  PASS: PORTABILITY_SCAN_PATHS env surface is honored
  PASS: no-surface invocation exits 2 (usage)
  PASS: missing-path invocation exits 2 (usage)
  PASS: guard parses (bash -n)
  PASS: guard is self-portable (guard scans its own source -> exit 0)
  PASS: guard source (comments stripped) has no literal GNU-only form

[selftest macos-portability-guard] OK - all assertions passed.
```

Traceability and parity raw summaries:

```text
--- Traceability Summary ---
Scenarios checked: 3
Test rows checked: 21
Scenario-to-row mappings: 3
Concrete test file references: 3
Report evidence references: 3
DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
Edge confidence (IMP-015 Scope B): declared=4 inferred=0 ambiguous=2
RESULT: PASSED (0 warnings)
BUG022_PARITY_BEGIN
MARKDOWN_TEST_ROWS=21
JSON_TEST_ROWS=21
TEST_DOD_ITEMS=21
UNIQUE_MARKDOWN_TEST_IDS=21
UNIQUE_JSON_TEST_IDS=21
ID_SET_PARITY=PASS
FIELD_MISMATCHES=0
FIELD_MISMATCH_DETAILS=none
MARKDOWN_SCENARIOS=3
MANIFEST_SCENARIOS=3
MANIFEST_PHYSICAL_TEST_LINKS=4
T_BUG_022_06_SOURCE_FILES=3
T_BUG_022_09_PHYSICAL_PATH=yes
CHECKED_DOD_ITEMS=0
BUG022_PARITY_RESULT=PASS
BUG022_PARITY_END
```

Corrected test-integrity discriminator:

```text
BUG022_TEST_INTEGRITY_CORRECTED_BEGIN
CANONICAL_PRODUCTION_DISPATCH=1
REPAIRED_REFERENCE_DISPATCH=1
FAMILY_MUTANT_DISPATCH=1
SITE_MUTANT_DISPATCH=1
STOCK_EXECUTION_SUMMARY=306/306
STOCK_SITE_MUTANTS=43/43
STOCK_CONTROL_FAILURES=0
STOCK_HARNESS_FAILURES=0
BUG022_TEST_INTEGRITY_CORRECTED_RESULT=PASS
BUG022_TEST_INTEGRITY_CORRECTED_END
```

### Protected-Byte Fence

**Phase:** test
**Executed:** YES (current session, before mutation and immediately before
these report/state edits)
**Command:** `shasum -a 256` over all BUG-022 packet artifacts, the three
production files, tests 26-29, shared framework/release surfaces, and every
file in sibling BUG-019/020/021 packets
**Exit Code:** 0
**Claim Source:** executed
**Result:** All baseline identities matched at the pre-edit fence.

```text
2368793f0627adb39a1ef0663e19a3b81443c9926c656663d40d392b0fe3b7bb  improvements/BUG-022-state-transition-bash32-empty-array-nounset/design.md
8c29cebfaa27da9e12e0eb41843acccf7e9abe01729147bbb90638da10534a01  improvements/BUG-022-state-transition-bash32-empty-array-nounset/scopes.md
5cf9aab4927b73fabe5fa730a5450e6605e50360ea17f6c8477aee56472101cf  improvements/BUG-022-state-transition-bash32-empty-array-nounset/test-plan.json
4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17  tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538  bubbles/scripts/state-transition-guard.sh
904fa6205820351ff059741f7939b4a7fac0040d35e00f33a3b3642822eb998f  bubbles/scripts/guards/planning-checks.sh
08f09b51c0733b796e9a4a750cd1536a7b709934019f9df4e123706991566f4c  bubbles/scripts/guards/control-plane-checks.sh
244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655  tests/regression/test_26_state_transition_spec_mjs_path.sh
42e8a0b74587d70ccca2d9fca222a30c68f3213d770115069f4106d2adb5dab0  tests/regression/test_27_state_transition_bash32_startup.sh
62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78  tests/regression/test_28_framework_validate_portable_timeout.sh
97fdb81b1e568e79ad92169f716d05b965a4826d27f64f604016f12f1777227f  bubbles/scripts/state-transition-guard-selftest.sh
15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa  bubbles/scripts/install-provenance-selftest.sh
a493a55d5f616d44ac67c1aa24dd595ba05498b16c03fc08ec37dd5f03c5d4cd  bubbles/scripts/framework-validate.sh
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
c329e52c490fbbb52a2c139c59cf2a182a6b8906f75491c1e0c24a1611efce70  bubbles/release-manifest.json
5fd3cc5e870d74e7b94454119e4eee8d6dd369111a2e0f5f3eed9ee9fc93fdc9  improvements/BUG-019-state-transition-spec-mjs-path/state.json
9c40a1b4adeb8c0fb1b136de149f77f8b770134887c2ca02a008043d6ca1253f  improvements/BUG-020-state-transition-bash32-startup/state.json
808cf3da1d6714115acb83efd3827e83fbbc35e2799316e0a8a671a74542714d  improvements/BUG-021-framework-validate-raw-timeout/state.json
```

### Interrupted Newer macOS Bash Lane

**Phase:** test
**Executed:** YES, three attempts (current session)
**Command:** `if [[ -x /opt/homebrew/bin/bash ]]; then /opt/homebrew/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; elif [[ -x /opt/local/bin/bash ]]; then /opt/local/bin/bash tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh; else printf '%s\n' 'required newer macOS Bash is unavailable'; exit 2; fi`
**Exit Codes:** 130, 130, 130
**Claim Source:** executed
**Result:** INTERRUPTED. Each attempt reached Homebrew Bash 5.3.15 production
and mutant checks but terminated before the final summary. No GREEN claim is
made for this lane.

```text
T_BUG_022_13_CURRENT_SESSION_EXIT=130
T_BUG_022_13_RETRY_CURRENT_SESSION_EXIT=130
T_BUG_022_13_FINAL_ATTEMPT_EXIT=130
PASS: M-SCOPE-LOOP is runtime-tolerated on this Bash lane and rejected by its exact one-site inventory
PASS: M-SCOPE-COPY applies exactly one raw site: SCOPE-COPY
GUARD_CASE name=mutant-M-SCOPE-COPY shell=/opt/homebrew/bin/bash bash=5.3.15(1)-release exit=1
PASS: M-SCOPE-COPY is runtime-tolerated on this Bash lane and rejected by its exact one-site inventory
PASS: M-REPORT-LOOP applies exactly one raw site: REPORT-TEMPLATE-SCAN
GUARD_CASE name=mutant-M-REPORT-LOOP shell=/opt/homebrew/bin/bash bash=5.3.15(1)-release exit=1
4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17  tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh
a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538  bubbles/scripts/state-transition-guard.sh
904fa6205820351ff059741f7939b4a7fac0040d35e00f33a3b3642822eb998f  bubbles/scripts/guards/planning-checks.sh
08f09b51c0733b796e9a4a750cd1536a7b709934019f9df4e123706991566f4c  bubbles/scripts/guards/control-plane-checks.sh
```

> **Uncertainty Declaration**
> **What was attempted:** The exact explicit-newer-macOS-Bash command was run
> three times, including a final tool invocation with no timeout.
> **What was observed:** Every attempt exited 130 before emitting the final
> BUG-022 regression summary; the frozen test and all three production hashes
> remained unchanged after each attempt.
> **Why this is uncertain:** Partial output cannot prove the complete 306
> assertions or the final lane disposition under Bash 5.3.15.
> **What would resolve this:** A fresh `bubbles.test` session must run the same
> frozen command to a complete final summary and verify exit zero.

### Current-Session Runtime-Lane Honesty

**Phase:** test
**Claim Source:** not-run
**Reason:** No Linux or WSL runtime was invoked in this macOS session. Homebrew
Bash is a macOS runtime and is not represented as Linux evidence.

### Full Inherited Finding Ledger

| Finding | Current disposition | Owner |
| --- | --- | --- |
| `TEST-022-001-MISSING-REGRESSION` | Preserved addressed: the one physical `test_29` remains present and nonduplicated. | `bubbles.test` |
| `TEST-022-002-FINAL-BYTE-RED` | Preserved addressed by the current frozen-hash RED record. | `bubbles.test` |
| `TEST-022-003-HARNESS-INTEGRITY` | Preserved addressed and independently reverified: controls, harness, and unrelated-abort counters are zero. | `bubbles.test` |
| `TEST-022-004-NEWER-COMPARISON` | Preserved addressed as the pre-change comparison record; it is not post-change GREEN. | `bubbles.test` |
| `DESIGN-022-001-SOURCED-MODULE-SURFACE-OMITTED` | Preserved addressed by the authoritative atomic three-file design. | `bubbles.design` |
| `BUG022-RELEASE-TEMP-001` | Preserved addressed by the design-owned duplicate cleanup record. | `bubbles.design` |
| `PLAN-022-003-SOURCED-MODULE-BOUNDARY-OMITTED` | Preserved addressed by synchronized scopes and `test-plan.json`. | `bubbles.plan` |
| `PLAN-022-002-REGRESSION-QUALITY-COMMAND` | Preserved addressed and rerun against the physical `test_29` path at exit zero. | `bubbles.plan` |
| `TEST-022-006-FINAL-BYTE-HASH-DRIFT` | Preserved addressed: frozen hash matched before, during, and after stock GREEN. | `bubbles.test` |
| `IMPLEMENT-022-001-MAIN-GUARD-RAW-SITES` | Preserved addressed and independently observed at 40 guarded, zero mapped raw. | `bubbles.implement` |
| `IMPLEMENT-022-002-SOURCED-MODULE-RAW-SITES` | Preserved addressed and independently observed at three guarded, zero mapped raw. | `bubbles.implement` |
| `TEST-022-005-IDENTICAL-BYTE-GREEN` | Addressed in this session by the exact stock-Bash command, frozen hash, `CURRENT_SOURCE_GREEN`, and 306/306 result. | `bubbles.test` |
| `TEST-022-007-NEWER-MACOS-LANE-INTERRUPTED` | Open: three Bash 5.3.15 attempts ended at exit 130 without a final summary. | `bubbles.test` |

### Test-Phase Routing

The canonical persisted-mode resolver reported the exact phase order
`select, bootstrap, implement, test, regression, simplify, gaps, harden,
stabilize, devops, security, validate, audit, finalize`. Because
`TEST-022-007-NEWER-MACOS-LANE-INTERRUPTED` remains open, the next required
owner stays `bubbles.test`. No regression, simplify, release, status,
certification, scope, DoD, or `completedPhaseClaims` update is claimed.

### Post-Edit Validation And Probe Accounting

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed

The immediate post-edit artifact lint exited zero. The first containment probe
incorrectly included the append separator in the report prefix and
reserialized JSON, so both byte comparisons failed. The second probe fixed the
report slice but removed six characters from a seven-character history
separator, so only the state reconstruction failed. Neither probe modified a
file. The final discriminator used exact textual reversal, required the
reconstructed JSON to parse, and matched both pre-edit SHA-256 values.

```text
BUG022_POST_EDIT_CONTAINMENT_FINAL_BEGIN
REPORT_PREFIX_SHA256=59b22babaf6aa321f33f4bf6f9eed635c350a963f2790c149fb843eecfc23717
REPORT_APPEND_BYTES=18407
STATE_RECONSTRUCTED_PREEDIT_SHA256=2d88085e16862d4a45b5dba66efb5178e7256769afff949a970fd9bfe0746ee3
RECONSTRUCTED_JSON=VALID
TOP_LEVEL_STATUS=blocked
CERTIFICATION_STATUS=blocked
SCOPE_STATUS=blocked
COMPLETED_SCOPES=0
CERTIFIED_COMPLETED_PHASES=0
COMPLETED_PHASE_CLAIMS=0
CHECKED_DOD_ITEMS=0
LATEST_AGENT=bubbles.test
LATEST_OUTCOME=blocked
LATEST_ADDRESSED_TEST_022_005=yes
LATEST_UNRESOLVED=TEST-022-007-NEWER-MACOS-LANE-INTERRUPTED
NEXT_REQUIRED_OWNER=bubbles.test
reportPrefix=PASS
stateReconstruction=PASS
status=PASS
certStatus=PASS
scopeStatus=PASS
completedScopes=PASS
certPhases=PASS
claims=PASS
dod=PASS
history=PASS
addressed=PASS
unresolved=PASS
owner=PASS
BUG022_POST_EDIT_CONTAINMENT_FINAL_RESULT=PASS
BUG022_POST_EDIT_CONTAINMENT_FINAL_END
```

Failed diagnostic probes preserved from the same session:

```text
BUG022_POST_EDIT_CONTAINMENT_RESULT=FAIL
reportPrefix=FAIL
stateReconstruction=FAIL
BUG022_POST_EDIT_CONTAINMENT_CORRECTED_RESULT=FAIL
reportPrefix=PASS
stateReconstruction=FAIL
```
