#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-6 validation latency observability.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/validation-latency-report.sh" ]]; then
  REPORT="$REPO_ROOT/bubbles/scripts/validation-latency-report.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/validation-latency-report.sh" ]]; then
  REPORT="$REPO_ROOT/.github/bubbles/scripts/validation-latency-report.sh"
else
  echo "test_06_validation_latency_observability: report script not executable from $REPO_ROOT" >&2
  exit 2
fi

RECIPE="$REPO_ROOT/docs/recipes/validation-latency-budgets.md"

WORKSPACE="$(mktemp -d -t bubbles-scope6-latency-regression-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0
SPEC_DIR="specs/900-fixture-validation-latency"

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "PASS: $*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "FAIL: $*"; }

stage_repo() {
  local sid="$1"
  local repo="$WORKSPACE/$sid"
  rm -rf "$repo"
  mkdir -p "$repo/.specify/memory"
  printf '%s' "$repo"
}

write_session() {
  local repo="$1"
  cat > "$repo/.specify/memory/bubbles.session.json" <<'EOF'
{
  "sessionId": "scope-06-regression",
  "executionHistory": [
    {
      "agent": "bubbles.implement",
      "phasesExecuted": ["implement"],
      "featureDir": "specs/900-fixture-validation-latency",
      "runStartedAt": "2026-05-24T09:00:00Z",
      "runCompletedAt": "2026-05-24T09:12:00Z"
    },
    {
      "agent": "bubbles.test",
      "phasesExecuted": ["test"],
      "featureDir": "specs/900-fixture-validation-latency",
      "runStartedAt": "2026-05-24T09:15:00Z",
      "runCompletedAt": "2026-05-24T09:23:00Z"
    },
    {
      "agent": "bubbles.validate",
      "phasesExecuted": ["validate"],
      "featureDir": "specs/999-other-feature",
      "runStartedAt": "2026-05-24T10:00:00Z",
      "runCompletedAt": "2026-05-24T10:06:00Z"
    }
  ],
  "turnSnapshots": [
    {
      "agent": "bubbles.audit",
      "phase": "audit",
      "specDir": "specs/900-fixture-validation-latency",
      "startedAt": "2026-05-24T10:30:00Z",
      "completedAt": "2026-05-24T10:36:00Z"
    }
  ]
}
EOF
}

run_report() {
  local repo="$1"
  shift
  set +e
  bash "$REPORT" --repo-root "$repo" --now "2026-05-24T12:00:00Z" "$@" > "$WORKSPACE/stdout.last" 2> "$WORKSPACE/stderr.last"
  local rc=$?
  set -e
  echo "$rc" > "$WORKSPACE/exit.last"
}

assert_exit() {
  local label="$1"
  local expected="$2"
  local actual
  actual="$(cat "$WORKSPACE/exit.last")"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label exit=$actual"
  else
    fail "$label expected exit=$expected actual=$actual"
    cat "$WORKSPACE/stdout.last"
    cat "$WORKSPACE/stderr.last"
  fi
}

assert_stdout_contains() {
  local label="$1"
  local needle="$2"
  if grep -qF -- "$needle" "$WORKSPACE/stdout.last"; then
    pass "$label stdout contains '$needle'"
  else
    fail "$label stdout missing '$needle'"
    cat "$WORKSPACE/stdout.last"
  fi
}

assert_stdout_not_contains() {
  local label="$1"
  local needle="$2"
  if grep -qF -- "$needle" "$WORKSPACE/stdout.last"; then
    fail "$label stdout unexpectedly contains '$needle'"
    cat "$WORKSPACE/stdout.last"
  else
    pass "$label stdout omits '$needle'"
  fi
}

assert_file_contains() {
  local label="$1"
  local file="$2"
  local needle="$3"
  if grep -qF -- "$needle" "$file"; then
    pass "$label contains '$needle'"
  else
    fail "$label missing '$needle'"
    cat "$file"
  fi
}

echo "=== test_06_validation_latency_observability (SCOPE-6 regression) ==="

echo ""
echo "--- scope-06-s1: latency report renders markdown table and percentiles ---"
repo="$(stage_repo scope-06-s1)"
write_session "$repo"
run_report "$repo" --since 7
assert_exit "scope-06-s1" 0
assert_stdout_contains "scope-06-s1" "| Phase |"
assert_stdout_contains "scope-06-s1" "| implement | all | all | 1 | 12m0s | 12m0s | 12m0s | 30m0s | yes |"
assert_stdout_contains "scope-06-s1" "| audit | all | all | 1 | 6m0s | 6m0s | 6m0s | 10m0s | yes |"

echo ""
echo "--- scope-06-s2: --spec filters rows to the requested spec ---"
repo="$(stage_repo scope-06-s2)"
write_session "$repo"
run_report "$repo" --since 7 --spec "$SPEC_DIR"
assert_exit "scope-06-s2" 0
assert_stdout_contains "scope-06-s2" "Spec filter: $SPEC_DIR"
assert_stdout_contains "scope-06-s2" "| test | all | $SPEC_DIR | 1 | 8m0s | 8m0s | 8m0s | 15m0s | yes |"
assert_stdout_not_contains "scope-06-s2" "specs/999-other-feature"

echo ""
echo "--- scope-06-s3: recipe documents budgets and --latency invocation ---"
if [[ -f "$RECIPE" ]]; then
  pass "scope-06-s3 recipe exists"
else
  fail "scope-06-s3 recipe missing at $RECIPE"
fi
assert_file_contains "scope-06-s3" "$RECIPE" "## Per-Phase Budgets"
assert_file_contains "scope-06-s3" "$RECIPE" "implement"
assert_file_contains "scope-06-s3" "$RECIPE" "test"
assert_file_contains "scope-06-s3" "$RECIPE" "validate"
assert_file_contains "scope-06-s3" "$RECIPE" "audit"
assert_file_contains "scope-06-s3" "$RECIPE" "--latency"
assert_file_contains "scope-06-s3" "$RECIPE" "| Phase |"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:           %d\n' "$PASS_COUNT"
printf '  Failed:           %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_06_validation_latency_observability: FAILED" >&2
  exit 1
fi

echo "test_06_validation_latency_observability: PASSED"
exit 0
