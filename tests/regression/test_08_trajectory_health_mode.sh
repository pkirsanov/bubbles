#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-8 trajectory-inspector --health mode.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSPECTOR="$REPO_ROOT/bubbles/scripts/trajectory-inspector.sh"
RETRO_HEALTH="$REPO_ROOT/bubbles/scripts/retro-convergence-health.sh"
OPERATING_BASELINE="$REPO_ROOT/agents/bubbles_shared/operating-baseline.md"

if [[ ! -f "$INSPECTOR" ]]; then
  echo "test_08_trajectory_health_mode: missing $INSPECTOR" >&2
  exit 2
fi

if [[ ! -f "$RETRO_HEALTH" ]]; then
  echo "test_08_trajectory_health_mode: missing $RETRO_HEALTH" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-regression-scope8-trajectory-health-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0
SPEC_DIR="specs/900-fixture-trajectory-health"

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf '  PASS: %s\n' "$*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  FAIL: %s\n' "$*"; }

stage_repo() {
  local scenario_name="$1"
  local staged_repo="$WORKSPACE/$scenario_name"
  rm -rf "$staged_repo"
  mkdir -p "$staged_repo/.specify/memory"
  printf '%s' "$staged_repo"
}

write_retro_session() {
  local staged_repo="$1"
  cat > "$staged_repo/.specify/memory/bubbles.session.json" <<'EOF'
{
  "sessionId": "scope8-retro-input",
  "convergenceLoops": [
    {"specDir": "specs/900-fixture-trajectory-health", "iterationCount": 1},
    {"specDir": "specs/900-fixture-trajectory-health", "iterationCount": 2}
  ],
  "envelopesReceived": [
    {"specDir": "specs/900-fixture-trajectory-health", "rawSizeBytes": 900, "compactedAt": "2026-05-24T10:00:00Z"}
  ],
  "turnSnapshots": [
    {"specDir": "specs/900-fixture-trajectory-health", "turnNumber": 1, "startedAt": "2026-05-24T09:00:00Z", "completedAt": "2026-05-24T09:02:00Z", "content": "implementation"},
    {"specDir": "specs/900-fixture-trajectory-health", "turnNumber": 2, "startedAt": "2026-05-24T09:03:00Z", "completedAt": "2026-05-24T09:05:00Z", "content": "validation"}
  ]
}
EOF
}

write_rederive_session() {
  local staged_repo="$1"
  cat > "$staged_repo/.specify/memory/bubbles.session.json" <<'EOF'
{
  "sessionId": "scope8-rederive",
  "featureDir": "specs/900-fixture-trajectory-health",
  "turnSnapshots": [
    {"specDir": "specs/900-fixture-trajectory-health", "turnNumber": 1, "phase": "implement", "content": "recap captured"},
    {"specDir": "specs/900-fixture-trajectory-health", "turnNumber": 2, "phase": "validate", "content": "handoff captured"},
    {"specDir": "specs/900-fixture-trajectory-health", "turnNumber": 3, "phase": "audit", "content": "steady state"}
  ],
  "envelopesReceived": [
    {"specDir": "specs/900-fixture-trajectory-health", "rawSizeBytes": 1600, "compactedAt": "2026-05-24T10:00:00Z"},
    {"specDir": "specs/900-fixture-trajectory-health", "rawSizeBytes": 800}
  ]
}
EOF
}

run_inspector() {
  set +e
  bash "$INSPECTOR" "$@" > "$WORKSPACE/stdout.last" 2> "$WORKSPACE/stderr.last"
  local exit_code=$?
  set -e
  echo "$exit_code" > "$WORKSPACE/exit.last"
}

run_retro_json() {
  local staged_repo="$1"
  local output_path="$2"
  set +e
  bash "$RETRO_HEALTH" "$SPEC_DIR" --repo-root "$staged_repo" --format json > "$output_path" 2> "$WORKSPACE/retro.stderr.last"
  local exit_code=$?
  set -e
  echo "$exit_code" > "$WORKSPACE/retro.exit.last"
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

assert_retro_exit() {
  local label="$1"
  local expected="$2"
  local actual
  actual="$(cat "$WORKSPACE/retro.exit.last")"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label retro exit=$actual"
  else
    fail "$label expected retro exit=$expected actual=$actual"
    cat "$WORKSPACE/retro.stderr.last"
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

assert_file_contains() {
  local label="$1"
  local file_path="$2"
  local needle="$3"
  if grep -qF -- "$needle" "$file_path"; then
    pass "$label contains '$needle'"
  else
    fail "$label missing '$needle'"
    cat "$file_path"
  fi
}

echo "=== test_08_trajectory_health_mode ==="

echo ""
echo "--- scope-08-s1: --health consumes retro convergence JSON ---"
repo_input="$(stage_repo scope-08-s1)"
write_retro_session "$repo_input"
health_json="$WORKSPACE/convergence-health.json"
run_retro_json "$repo_input" "$health_json"
assert_retro_exit "scope-08-s1" 0
run_inspector --health --input "$health_json"
assert_exit "scope-08-s1" 0
assert_stdout_contains "scope-08-s1" "Convergence Health:"
assert_stdout_contains "scope-08-s1" "turnCount=2"
assert_stdout_contains "scope-08-s1" "compactionInvocations="
assert_stdout_contains "scope-08-s1" "recapInvocations="
assert_stdout_contains "scope-08-s1" "handoffInvocations="
assert_stdout_contains "scope-08-s1" "blockedFindings=0"
assert_stdout_contains "scope-08-s1" "status=HEALTHY"

echo ""
echo "--- scope-08-s2: --health re-derives from session without JSON input ---"
repo_rederive="$(stage_repo scope-08-s2)"
write_rederive_session "$repo_rederive"
run_inspector --repo-root "$repo_rederive" --health --spec "$SPEC_DIR"
assert_exit "scope-08-s2" 0
assert_stdout_contains "scope-08-s2" "Convergence Health:"
assert_stdout_contains "scope-08-s2" "turnCount=3"
assert_stdout_contains "scope-08-s2" "compactionInvocations=1"
assert_stdout_contains "scope-08-s2" "recapInvocations=1"
assert_stdout_contains "scope-08-s2" "handoffInvocations=1"
assert_stdout_contains "scope-08-s2" "blockedFindings=0"
assert_stdout_contains "scope-08-s2" "status=DEGRADED"

echo ""
echo "--- scope-08-s3: operating baseline documents --health ---"
if [[ -f "$OPERATING_BASELINE" ]]; then
  pass "scope-08-s3 operating baseline exists"
else
  fail "scope-08-s3 operating baseline missing at $OPERATING_BASELINE"
fi
assert_file_contains "scope-08-s3" "$OPERATING_BASELINE" "## Trajectory Inspector Health Mode"
assert_file_contains "scope-08-s3" "$OPERATING_BASELINE" "trajectory-inspector.sh --health --spec specs/<feature>"
assert_file_contains "scope-08-s3" "$OPERATING_BASELINE" "--input /tmp/convergence-health.json"
assert_file_contains "scope-08-s3" "$OPERATING_BASELINE" "Gate G090 retro convergence health"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:           %d\n' "$PASS_COUNT"
printf '  Failed:           %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_08_trajectory_health_mode: FAILED" >&2
  exit 1
fi

echo "test_08_trajectory_health_mode: PASSED"
exit 0
