#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-7 retro convergence health (Gate G090).

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RETRO_HEALTH="$REPO_ROOT/bubbles/scripts/retro-convergence-health.sh"

if [[ ! -f "$RETRO_HEALTH" ]]; then
  echo "test_07_retro_convergence_health: missing $RETRO_HEALTH" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-regression-scope7-retro-health-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0
SPEC_DIR="specs/900-fixture-retro-health"

ok() { PASS_COUNT=$((PASS_COUNT + 1)); printf '  PASS: %s\n' "$*"; }
ko() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  FAIL: %s\n' "$*"; }

stage_repo() {
  local name="$1"
  local repo="$WORKSPACE/$name"
  rm -rf "$repo"
  mkdir -p "$repo/.specify/memory"
  printf '%s' "$repo"
}

write_session() {
  local repo="$1"
  local mode="$2"
  case "$mode" in
    healthy)
      cat > "$repo/.specify/memory/bubbles.session.json" <<'EOF'
{
  "sessionId": "regression-scope7-healthy",
  "convergenceLoops": [
    {"specDir": "specs/900-fixture-retro-health", "iterationCount": 1},
    {"specDir": "specs/900-fixture-retro-health", "iterationCount": 3}
  ],
  "envelopesReceived": [
    {"specDir": "specs/900-fixture-retro-health", "rawSizeBytes": 1000, "compactedAt": "2026-05-24T10:00:00Z"},
    {"specDir": "specs/900-fixture-retro-health", "rawSizeBytes": 900, "compactedAt": "2026-05-24T10:05:00Z"}
  ],
  "turnSnapshots": [
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 1, "startedAt": "2026-05-24T09:00:00Z", "completedAt": "2026-05-24T09:02:00Z", "content": "implementation"},
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 2, "startedAt": "2026-05-24T09:03:00Z", "completedAt": "2026-05-24T09:05:00Z", "content": "validation"}
  ]
}
EOF
      ;;
    snapshot-breach)
      cat > "$repo/.specify/memory/bubbles.session.json" <<'EOF'
{
  "sessionId": "regression-scope7-snapshot-breach",
  "turnSnapshots": [
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 1, "startedAt": "2026-05-24T09:00:00Z", "completedAt": "2026-05-24T09:02:00Z"},
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 2, "startedAt": "2026-05-24T09:03:00Z"}
  ]
}
EOF
      ;;
    p0-recap-handoff)
      cat > "$repo/.specify/memory/bubbles.session.json" <<'EOF'
{
  "sessionId": "regression-scope7-p0-recap-handoff",
  "turnSnapshots": [
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 1, "startedAt": "2026-05-24T09:00:00Z", "completedAt": "2026-05-24T09:01:00Z", "content": "recap"},
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 2, "startedAt": "2026-05-24T09:02:00Z", "completedAt": "2026-05-24T09:03:00Z", "content": "handoff"},
    {"specDir": "specs/900-fixture-retro-health", "turnNumber": 3, "startedAt": "2026-05-24T09:04:00Z", "completedAt": "2026-05-24T09:05:00Z", "content": "handoff"}
  ]
}
EOF
      ;;
    *)
      echo "unknown session mode: $mode" >&2
      exit 2
      ;;
  esac
}

run_case() {
  local repo="$1"
  shift
  set +e
  bash "$RETRO_HEALTH" "$SPEC_DIR" --repo-root "$repo" "$@" > "$WORKSPACE/stdout.last" 2> "$WORKSPACE/stderr.last"
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
    ok "$label exit=$actual"
  else
    ko "$label expected exit=$expected actual=$actual"
    cat "$WORKSPACE/stdout.last"
    cat "$WORKSPACE/stderr.last"
  fi
}

assert_stdout_contains() {
  local label="$1"
  local needle="$2"
  if grep -qF -- "$needle" "$WORKSPACE/stdout.last"; then
    ok "$label stdout contains '$needle'"
  else
    ko "$label stdout missing '$needle'"
    cat "$WORKSPACE/stdout.last"
  fi
}

assert_stderr_contains() {
  local label="$1"
  local needle="$2"
  if grep -qF -- "$needle" "$WORKSPACE/stderr.last"; then
    ok "$label stderr contains '$needle'"
  else
    ko "$label stderr missing '$needle'"
    cat "$WORKSPACE/stderr.last"
  fi
}

assert_jq() {
  local label="$1"
  local expr="$2"
  if jq -e "$expr" "$WORKSPACE/stdout.last" >/dev/null 2>&1; then
    ok "$label jq '$expr'"
  else
    ko "$label jq failed '$expr'"
    cat "$WORKSPACE/stdout.last"
  fi
}

echo "=== test_07_retro_convergence_health ==="

echo ""
echo "--- scope-07-s1: metrics JSON contract remains stable ---"
repo="$(stage_repo scope-07-s1)"
write_session "$repo" healthy
run_case "$repo" --schema legacy
assert_exit "scope-07-s1" 0
assert_jq "scope-07-s1 exact legacy keys" 'keys == ["avgLoopIterations", "compactionFrequency", "maxConvergenceIterations", "preExistingDeferralCount", "snapshotCompleteness"]'
assert_jq "scope-07-s1 full pass via default schema" '.snapshotCompleteness == 1'

echo ""
echo "--- scope-07-s2: snapshotCompleteness breach fails G090 ---"
repo="$(stage_repo scope-07-s2)"
write_session "$repo" snapshot-breach
run_case "$repo"
assert_exit "scope-07-s2" 1
assert_stderr_contains "scope-07-s2" "G090"
assert_stderr_contains "scope-07-s2" "snapshotCompleteness"

echo ""
echo "--- scope-07-s2b: recap/handoff P0 threshold fails G090 ---"
repo="$(stage_repo scope-07-s2b)"
write_session "$repo" p0-recap-handoff
run_case "$repo"
assert_exit "scope-07-s2b" 1
assert_stderr_contains "scope-07-s2b" "P0 convergence regression"
assert_stderr_contains "scope-07-s2b" "recapHandoffInvocationCount=3"

echo ""
echo "--- scope-07-s3: healthy markdown renders for retro output ---"
repo="$(stage_repo scope-07-s3)"
write_session "$repo" healthy
run_case "$repo" --format markdown
assert_exit "scope-07-s3" 0
assert_stdout_contains "scope-07-s3" "## Convergence Health"
assert_stdout_contains "scope-07-s3" 'SLO: `pass`'

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:           %d\n' "$PASS_COUNT"
printf '  Failed:           %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_07_retro_convergence_health: FAILED" >&2
  exit 1
fi

echo "test_07_retro_convergence_health: PASSED"
exit 0