#!/usr/bin/env bash
set -euo pipefail

# BUG-019 persistent production-path regression for Check 8 test-file parsing.
#
# Every case invokes the canonical state-transition guard against a disposable
# repository. The regression contains no copy of Check 8's parser or suffix
# allowlist; assertions cover only the production guard's observable contract.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/state-transition-guard.sh"

if [[ ! -f "$GUARD" ]]; then
  printf 'test_26_state_transition_spec_mjs_path: required guard missing: %s\n' "$GUARD" >&2
  exit 2
fi
if [[ ! -d "$REPO_ROOT/bubbles" || ! -d "$REPO_ROOT/agents" ]]; then
  printf '%s\n' 'test_26_state_transition_spec_mjs_path: canonical fixture support surfaces are missing' >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug019-XXXXXXXX")"
FIXTURE_REPO="$WORKSPACE/repo"
RUN_OUTPUT=""
RUN_STATUS=0
RUN_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT INT TERM

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

assert_status() {
  local expected="$1"
  local label="$2"

  if [[ "$RUN_STATUS" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected exit $expected, got $RUN_STATUS)"
  fi
}

assert_nonzero_status() {
  local label="$1"

  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass "$label"
  else
    fail "$label (expected nonzero exit, got 0)"
  fi
}

assert_contains() {
  local expected="$1"
  local label="$2"

  if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$expected"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_not_contains() {
  local forbidden="$1"
  local label="$2"

  if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$forbidden"; then
    fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

assert_occurrences() {
  local expected="$1"
  local needle="$2"
  local label="$3"
  local actual

  actual="$(printf '%s\n' "$RUN_OUTPUT" | awk -v needle="$needle" '
    index($0, needle) { count++ }
    END { print count + 0 }
  ')"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected $expected occurrence(s), got $actual: $needle)"
  fi
}

run_guard() {
  local feature_dir="$1"
  local label="$2"
  local output_file

  RUN_COUNT=$((RUN_COUNT + 1))
  output_file="$WORKSPACE/run-${RUN_COUNT}.log"
  RUN_STATUS=0
  if (
    cd "$FIXTURE_REPO"
    BUBBLES_REPO_ROOT="$FIXTURE_REPO" \
      BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1 \
      bash "$GUARD" "$feature_dir"
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "--- $label production output ---"
  printf '%s\n' "$RUN_OUTPUT"
  printf '%s\n' "--- $label exit=$RUN_STATUS ---"
}

write_delivery_packet() {
  local feature_dir="$1"
  local case_name="$2"

  mkdir -p "$feature_dir"

  cat >"$feature_dir/spec.md" <<'MARKDOWN'
# BUG-019 Check 8 Fixture Spec

## Purpose

Exercise the canonical production guard against a complete delivery packet.
MARKDOWN

  cat >"$feature_dir/design.md" <<'MARKDOWN'
# BUG-019 Check 8 Fixture Design

## Approach

Vary only Test Plan path contexts while every unrelated delivery check remains
on the known-positive state-transition selftest contract.
MARKDOWN

  cat >"$feature_dir/uservalidation.md" <<'MARKDOWN'
# User Validation

## Checklist

- [x] The fixture exercises the real production state-transition guard.
MARKDOWN

  cat >"$feature_dir/report.md" <<'MARKDOWN'
# Report

### Summary

Disposable BUG-019 production-guard regression fixture.

### Completion Statement

The fixture supplies complete delivery evidence solely to isolate Check 8.

### Test Evidence

```text
$ bash bubbles/scripts/agent-ownership-lint.sh
Agent ownership lint passed.
$ bash tests/regression/check8-fixture.sh
fixture setup complete
production guard invoked
Check 8 reached
structured result reached
scenario regression recorded
broader regression recorded
fixture remains disposable
fixture cleanup registered
```
MARKDOWN

  cat >"$feature_dir/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "autonomous-goal",
  "execution": {
    "completedPhaseClaims": ["test", "validate", "audit", "docs"]
  },
  "certification": {
    "certifiedCompletedPhases": ["test", "validate", "audit", "docs"],
    "completedScopes": ["01-check8-fixture"],
    "scopeProgress": [],
    "lockdownState": {
      "mode": "off",
      "lockedScenarioIds": []
    },
    "status": "in_progress"
  },
  "policySnapshot": {
    "grill": { "mode": "off", "source": "repo-default" },
    "tdd": { "mode": "off", "source": "repo-default" },
    "autoCommit": { "mode": "off", "source": "repo-default" },
    "lockdown": { "mode": "off", "source": "repo-default" },
    "regression": { "mode": "protect-existing-scenarios", "source": "repo-default" },
    "validation": { "mode": "required", "source": "workflow-forced" },
    "workflowMode": "autonomous-goal"
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": [
    {
      "phase": "test",
      "agent": "bubbles.test",
      "phasesExecuted": ["test"],
      "runStartedAt": "2026-03-27T10:00:00Z",
      "runCompletedAt": "2026-03-27T10:00:47Z",
      "completedAt": "2026-03-27T10:00:47Z"
    },
    {
      "phase": "validate",
      "agent": "bubbles.validate",
      "phasesExecuted": ["validate"],
      "runStartedAt": "2026-03-27T10:01:13Z",
      "runCompletedAt": "2026-03-27T10:02:31Z",
      "completedAt": "2026-03-27T10:02:31Z"
    },
    {
      "phase": "audit",
      "agent": "bubbles.audit",
      "phasesExecuted": ["audit"],
      "runStartedAt": "2026-03-27T10:03:02Z",
      "runCompletedAt": "2026-03-27T10:06:08Z",
      "completedAt": "2026-03-27T10:06:08Z"
    },
    {
      "phase": "docs",
      "agent": "bubbles.docs",
      "phasesExecuted": ["docs"],
      "runStartedAt": "2026-03-27T10:07:19Z",
      "runCompletedAt": "2026-03-27T10:11:44Z",
      "completedAt": "2026-03-27T10:11:44Z"
    }
  ],
  "lastUpdatedAt": "2026-03-27T10:11:45Z"
}
JSON

  case "$case_name" in
    baseline)
      cat >"$feature_dir/scopes.md" <<'MARKDOWN'
# Scope 01: Check 8 Baseline

**Status:** Done

### Goal

Prove the disposable packet reaches Check 8 and a normal structured result.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-ui` | `tests/example.sh` | Scenario-specific regression control. | `bash tests/example.sh` | Yes |
| Regression E2E | `e2e-ui` | `tests/example.sh` | Broader regression control. | `bash tests/example.sh` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is recorded consistently across artifacts -> Evidence: report.md#summary
MARKDOWN
      ;;
    matrix)
      cat >"$feature_dir/scopes.md" <<'MARKDOWN'
# Scope 01: Check 8 Compound And Compatibility Matrix

**Status:** Done

### Goal

Preserve complete compound paths and every planned command-context control.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-api` | `tests/palm-springs-rental-market-lab.spec.mjs` | Scenario-specific reporter compound path. | `tests/palm-springs-rental-market-lab.spec.mjs` | Yes |
| Regression E2E | `e2e-api` | `tests/example.test.mjs` | Scenario-specific compound test path. | `tests/example.test.mjs` | Yes |
| Regression E2E | `e2e-api` | `tests/example.spec.ts` | Ordinary spec control. | `tests/example.spec.ts` | Yes |
| Regression E2E | `e2e-api` | `tests/example.test.js` | Ordinary test control. | `tests/example.test.js` | Yes |
| Regression E2E | `e2e-api` | `tests/marker-only.spec` | Marker-only spec control. | `tests/marker-only.spec` | Yes |
| Regression E2E | `e2e-api` | `tests/marker-only.test` | Marker-only test control. | `tests/marker-only.test` | Yes |
| Regression E2E | `e2e-api` | `tests/example.sh` | Bare shell-path control. | `tests/example.sh` | Yes |
| Regression E2E | `e2e-api` | `bash tests/example.sh` | Bash wrapper control. | `bash tests/example.sh` | Yes |
| Regression E2E | `e2e-api` | `sh tests/example.sh` | Sh wrapper control. | `sh tests/example.sh` | Yes |
| Regression E2E | `e2e-api` | `bash -n tests/example.sh && shellcheck -x tests/example.sh` | Shellcheck continuation selects the first accepted path. | `bash -n tests/example.sh && shellcheck -x tests/example.sh` | Yes |
| Regression E2E | `e2e-api` | `./tests/example.sh check` | Direct script command control. | `./tests/example.sh check` | Yes |
| Regression E2E | `e2e-api` | `tests/example.spec.mjs.backup` then `tests/example.sh` | Invalid first backtick block is skipped before the later valid path. | `tests/example.sh` | Yes |
| Regression E2E | `e2e-api` | `tests/example.sh` | Broader regression control for the complete matrix. | `bash tests/example.sh` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is recorded consistently across artifacts -> Evidence: report.md#summary
MARKDOWN
      ;;
    adversarial)
      cat >"$feature_dir/scopes.md" <<'MARKDOWN'
# Scope 01: Check 8 Adversarial Matrix

**Status:** Done

### Goal

Reject nonterminal suffixes, prose, malformed wrappers, and unrecognized commands.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Adversarial Regression E2E | `e2e-api` | `tests/example.spec.mjs.backup` | Scenario-specific extension-prefix adversary. | `tests/example.spec.mjs.backup` | Yes |
| Adversarial Regression E2E | `e2e-api` | `the prose token example.spec.mjs is illustrative` | Extension-shaped prose is inert. | `the prose token example.spec.mjs is illustrative` | Yes |
| Adversarial Regression E2E | `e2e-api` | `node --test tests/example.spec.mjs` | Unrecognized command wrapper is inert. | `node --test tests/example.spec.mjs` | Yes |
| Adversarial Regression E2E | `e2e-api` | `bash -c tests/example.spec.mjs` | Bash command-string syntax is not interpreted. | `bash -c tests/example.spec.mjs` | Yes |
| Adversarial Regression E2E | `e2e-api` | `bash "tests/example.sh"` | Quoted shell syntax is not interpreted. | `bash "tests/example.sh"` | Yes |
| Adversarial Regression E2E | `e2e-api` | tests/example.spec.mjs | Unbackticked prose is not a path declaration. | node --test tests/example.spec.mjs | Yes |
| Adversarial Regression E2E | `e2e-api` | `node --test tests/example.test.mjs` | Broader adversarial regression control. | `node --test tests/example.test.mjs` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is recorded consistently across artifacts -> Evidence: report.md#summary
MARKDOWN
      ;;
    missing)
      cat >"$feature_dir/scopes.md" <<'MARKDOWN'
# Scope 01: Check 8 Missing-File Enforcement

**Status:** Done

### Goal

Prove a genuinely missing allowed test path still blocks delivery.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-api` | `tests/genuinely-missing.spec.ts` | Scenario-specific missing-file enforcement control. | `tests/genuinely-missing.spec.ts` | Yes |
| Regression E2E | `e2e-api` | `tests/example.sh` | Broader regression control remains physically present. | `bash tests/example.sh` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is recorded consistently across artifacts -> Evidence: report.md#summary
MARKDOWN
      ;;
    *)
      printf 'test_26_state_transition_spec_mjs_path: unknown fixture case: %s\n' "$case_name" >&2
      exit 2
      ;;
  esac
}

mkdir -p "$FIXTURE_REPO"
cp -R "$REPO_ROOT/bubbles" "$FIXTURE_REPO/bubbles"
cp -R "$REPO_ROOT/agents" "$FIXTURE_REPO/agents"
git -C "$FIXTURE_REPO" init -q
mkdir -p "$FIXTURE_REPO/specs" "$FIXTURE_REPO/tests"

cat >"$FIXTURE_REPO/tests/palm-springs-rental-market-lab.spec.mjs" <<'JAVASCRIPT'
export const reporterCompoundPath = true;
JAVASCRIPT
cat >"$FIXTURE_REPO/tests/example.test.mjs" <<'JAVASCRIPT'
export const compoundTestPath = true;
JAVASCRIPT
cat >"$FIXTURE_REPO/tests/example.spec.ts" <<'TYPESCRIPT'
export const ordinarySpecControl = true;
TYPESCRIPT
cat >"$FIXTURE_REPO/tests/example.test.js" <<'JAVASCRIPT'
export const ordinaryTestControl = true;
JAVASCRIPT
cat >"$FIXTURE_REPO/tests/marker-only.spec" <<'TEXT'
marker-only spec control
TEXT
cat >"$FIXTURE_REPO/tests/marker-only.test" <<'TEXT'
marker-only test control
TEXT
cat >"$FIXTURE_REPO/tests/example.sh" <<'SHELL'
#!/usr/bin/env bash
printf '%s\n' 'example shell control'
SHELL
chmod +x "$FIXTURE_REPO/tests/example.sh"

if [[ -e "$FIXTURE_REPO/tests/palm-springs-rental-market-lab.spec" \
  || -e "$FIXTURE_REPO/tests/example.test" \
  || -e "$FIXTURE_REPO/tests/genuinely-missing.spec.ts" ]]; then
  printf '%s\n' 'test_26_state_transition_spec_mjs_path: adversarial absent-path precondition failed' >&2
  exit 2
fi

BASELINE_FEATURE="$FIXTURE_REPO/specs/900-bug019-baseline"
MATRIX_FEATURE="$FIXTURE_REPO/specs/901-bug019-matrix"
ADVERSARIAL_FEATURE="$FIXTURE_REPO/specs/902-bug019-adversarial"
MISSING_FEATURE="$FIXTURE_REPO/specs/903-bug019-missing"
write_delivery_packet "$BASELINE_FEATURE" baseline
write_delivery_packet "$MATRIX_FEATURE" matrix
write_delivery_packet "$ADVERSARIAL_FEATURE" adversarial
write_delivery_packet "$MISSING_FEATURE" missing

printf '%s\n' '=== BUG-019 harness control: real guard reaches Check 8 cleanly ==='
run_guard "$BASELINE_FEATURE" 'BUG-019 baseline'
assert_status 0 'baseline packet exits zero'
assert_contains '--- Check 8: Test File Existence ---' 'baseline reaches production Check 8'
assert_contains 'Test file exists: tests/example.sh' 'baseline exercises the existing-file branch'
assert_contains 'BEGIN TRANSITION_GUARD_RESULT_V1' 'baseline reaches structured result start'
assert_contains 'failedChecks: []' 'baseline has no unrelated failed check'
assert_contains 'verdict: PASS' 'baseline reaches the normal passing verdict'

printf '%s\n' '=== T-BUG-019-01 Regression: compound MJS paths remain complete through production Check 8 ==='
printf '%s\n' '=== T-BUG-019-02 Regression: ordinary suffix, backtick, and command-wrapper controls remain compatible ==='
run_guard "$MATRIX_FEATURE" 'BUG-019 compound and compatibility matrix'
assert_contains '--- Check 8: Test File Existence ---' 'compound matrix reaches production Check 8'
assert_contains 'END TRANSITION_GUARD_RESULT_V1' 'compound matrix reaches a normal structured result'
assert_status 0 'compound and compatibility matrix exits zero'
assert_contains 'Test file exists: tests/palm-springs-rental-market-lab.spec.mjs' 'reporter compound path reaches the complete existing-file branch'
assert_contains 'Test file exists: tests/example.test.mjs' 'compound test path reaches the complete existing-file branch'
assert_contains 'Test file exists: tests/example.spec.ts' 'ordinary .spec.ts control remains complete'
assert_contains 'Test file exists: tests/example.test.js' 'ordinary .test.js control remains complete'
assert_contains 'Test file exists: tests/marker-only.spec' 'marker-only .spec control remains accepted'
assert_contains 'Test file exists: tests/marker-only.test' 'marker-only .test control remains accepted'
assert_occurrences 6 'Test file exists: tests/example.sh' 'bare, wrapped, continued, later-block, and broader shell contexts select the complete path'
assert_contains 'Test file exists: ./tests/example.sh' 'direct script command selects its first token'
assert_not_contains 'Test Plan references non-existent file: tests/palm-springs-rental-market-lab.spec' 'reporter marker prefix is never checked as a missing file'
assert_not_contains 'Test Plan references non-existent file: tests/example.test' 'compound-test marker prefix is never checked as a missing file'
assert_not_contains 'test files from Test Plan DO NOT EXIST' 'compound matrix has no aggregate missing-file failure'

printf '%s\n' '=== T-BUG-019-03 Regression: extension-prefix and prose candidates never reach Check 8 filesystem validation ==='
run_guard "$ADVERSARIAL_FEATURE" 'BUG-019 adversarial matrix'
assert_contains '--- Check 8: Test File Existence ---' 'adversarial matrix reaches production Check 8'
assert_status 0 'adversarial-only packet exits zero'
assert_contains 'No concrete test file paths found in Test Plan across resolved scope files' 'all-invalid contexts reach the no-concrete-path branch'
assert_not_contains 'Test file exists:' 'invalid contexts never reach the existing-file branch'
assert_not_contains 'Test Plan references non-existent' 'invalid contexts never reach the missing-file branch'
assert_not_contains "Test Plan uses basename-only path 'example.spec'" 'prose never triggers shorter basename resolution'
assert_not_contains "Test Plan uses basename-only path 'example.spec.mjs'" 'prose never triggers complete basename resolution'
assert_contains 'failedChecks: []' 'adversarial rejection introduces no failed check'
assert_contains 'verdict: PASS' 'adversarial rejection reaches the normal passing verdict'

printf '%s\n' '=== BUG-019 non-vacuity control: a genuinely missing allowed test file still blocks ==='
run_guard "$MISSING_FEATURE" 'BUG-019 missing-file enforcement'
assert_contains '--- Check 8: Test File Existence ---' 'missing-file control reaches production Check 8'
assert_nonzero_status 'genuinely missing allowed test path exits nonzero'
assert_contains 'Test Plan references non-existent file: tests/genuinely-missing.spec.ts' 'missing allowed path reaches the existing Check 8 failure branch'
assert_contains '1 of 2 test files from Test Plan DO NOT EXIST' 'missing allowed path contributes to the aggregate failure'
assert_contains 'failedChecks: [Check-8-file-existence]' 'structured result attributes the block to Check 8 file existence'
assert_contains 'verdict: FAIL' 'missing-file control reaches the normal failing verdict'
assert_not_contains 'No concrete test file paths found in Test Plan' 'missing allowed path is not misclassified as no concrete path'

ASSERTIONS_BEFORE_TOTALS=$((PASS_COUNT + FAIL_COUNT))
EXPECTED_RUN_COUNT=4
EXPECTED_ASSERTIONS_BEFORE_TOTALS=36
if [[ "$RUN_COUNT" -eq "$EXPECTED_RUN_COUNT" ]]; then
  pass "all $EXPECTED_RUN_COUNT production-guard fixtures executed"
else
  fail "expected $EXPECTED_RUN_COUNT production-guard fixtures, executed $RUN_COUNT"
fi
if [[ "$ASSERTIONS_BEFORE_TOTALS" -eq "$EXPECTED_ASSERTIONS_BEFORE_TOTALS" ]]; then
  pass "all $EXPECTED_ASSERTIONS_BEFORE_TOTALS planned assertions executed"
else
  fail "expected $EXPECTED_ASSERTIONS_BEFORE_TOTALS planned assertions, executed $ASSERTIONS_BEFORE_TOTALS"
fi

printf '%s\n' '=== BUG-019 regression summary ==='
printf 'GUARD_RUNS=%s\n' "$RUN_COUNT"
printf 'ASSERTIONS=%s\n' "$((PASS_COUNT + FAIL_COUNT))"
printf 'PASSED=%s\n' "$PASS_COUNT"
printf 'FAILED=%s\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -ne 0 ]]; then
  printf '%s\n' 'BUG-019 state-transition Check 8 regression FAILED' >&2
  exit 1
fi

printf '%s\n' 'BUG-019 state-transition Check 8 regression passed.'