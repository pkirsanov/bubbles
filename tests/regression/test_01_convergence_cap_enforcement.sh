#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-1 convergence cap enforcement (Gate G082).

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/convergence-cap-guard.sh"

if [[ ! -f "$GUARD" ]]; then
  echo "test_01_convergence_cap_enforcement: missing $GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-regression-scope1-convergence-cap-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0
SPEC_DIR="specs/900-fixture-convergence-cap"

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf '  PASS: %s\n' "$*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  FAIL: %s\n' "$*"; }

stage_repo() {
  local name="$1"
  local staged_repo="$WORKSPACE/$name"
  rm -rf "$staged_repo"
  mkdir -p "$staged_repo/.specify/memory" "$staged_repo/bubbles"
  cat > "$staged_repo/bubbles/workflows.yaml" <<'YAML'
workflowModes:
  autonomous-goal:
    constraints:
      maxConvergenceIterations: 10
YAML
  printf '%s' "$staged_repo"
}

write_session() {
  local staged_repo="$1"
  local mode="$2"
  case "$mode" in
    cap-exceeded)
      cat > "$staged_repo/.specify/memory/bubbles.session.json" <<'JSON'
{
  "convergenceLoops": [
    {
      "specDir": "specs/900-fixture-convergence-cap",
      "agent": "bubbles.workflow",
      "iterationCount": 11,
      "lastIterationAt": "2026-05-24T10:00:00Z"
    }
  ]
}
JSON
      ;;
    cap-respected)
      cat > "$staged_repo/.specify/memory/bubbles.session.json" <<'JSON'
{
  "convergenceLoops": [
    {
      "specDir": "specs/900-fixture-convergence-cap",
      "agent": "bubbles.workflow",
      "iterationCount": 10,
      "lastIterationAt": "2026-05-24T10:00:00Z"
    }
  ]
}
JSON
      ;;
    malformed)
      printf '{"convergenceLoops": [' > "$staged_repo/.specify/memory/bubbles.session.json"
      ;;
    *)
      echo "unknown session mode: $mode" >&2
      exit 2
      ;;
  esac
}

run_guard() {
  local staged_repo="$1"
  set +e
  BUBBLES_REPO_ROOT="$staged_repo" bash "$GUARD" "$SPEC_DIR" > "$WORKSPACE/stdout.last" 2> "$WORKSPACE/stderr.last"
  local exit_code=$?
  set -e
  printf '%s\n' "$exit_code" > "$WORKSPACE/exit.last"
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

assert_stderr_contains() {
  local label="$1"
  local needle="$2"
  if grep -qF -- "$needle" "$WORKSPACE/stderr.last"; then
    pass "$label stderr contains '$needle'"
  else
    fail "$label stderr missing '$needle'"
    cat "$WORKSPACE/stderr.last"
  fi
}

echo "=== test_01_convergence_cap_enforcement (Gate G082 regression) ==="

echo ""
echo "--- scope-01-s1: cap exceeded exits 1 and names G082 ---"
repo="$(stage_repo scope-01-s1)"
write_session "$repo" cap-exceeded
run_guard "$repo"
assert_exit "scope-01-s1" 1
assert_stderr_contains "scope-01-s1" "G082"
assert_stderr_contains "scope-01-s1" "convergence_cap_enforcement_gate"
assert_stderr_contains "scope-01-s1" "maxConvergenceIterations"

echo ""
echo "--- scope-01-s2: cap respected exits 0 and prints PASS ---"
repo="$(stage_repo scope-01-s2)"
write_session "$repo" cap-respected
run_guard "$repo"
assert_exit "scope-01-s2" 0
assert_stdout_contains "scope-01-s2" "PASS Gate G082"
assert_stdout_contains "scope-01-s2" "observed=10"

echo ""
echo "--- scope-01-s3: malformed JSON exits 2 with diagnostic ---"
repo="$(stage_repo scope-01-s3)"
write_session "$repo" malformed
run_guard "$repo"
assert_exit "scope-01-s3" 2
assert_stderr_contains "scope-01-s3" "convergence-cap-guard"
assert_stderr_contains "scope-01-s3" "not valid JSON"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:           %d\n' "$PASS_COUNT"
printf '  Failed:           %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_01_convergence_cap_enforcement: FAILED" >&2
  exit 1
fi

echo "test_01_convergence_cap_enforcement: PASSED"
exit 0