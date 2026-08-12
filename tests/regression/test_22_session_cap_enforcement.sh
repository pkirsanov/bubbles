#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G128 — session_cap_enforcement_gate
# (IMP-003 SCOPE-2, the AGGREGATE sibling of Gate G082).
#
# Stages minimal disposable session fixtures and asserts the guard:
#   * no-ops (exit 0) when no sessionBudget is recorded (the default),
#   * PASSES (exit 0) when the aggregate is under the cap, and
#   * BLOCKS (exit 1) when the AGGREGATE across TWO specs exceeds the cap
#     even though no single spec exceeds the per-spec G082 cap — the core
#     distinction from G082.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/session-cap-guard.sh"

if [[ ! -x "$GUARD" ]]; then
  echo "test_22_session_cap_enforcement: guard not executable: $GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-g128-regression-XXXXXXXX)"
trap 'rm -rf "$WORKSPACE"' EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0

pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf '  PASS: %s\n' "$*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf '  FAIL: %s\n' "$*"; }

# Stage a fake repo root with .specify/memory and emit its path.
stage_root() {
  local name="$1"
  local root="$WORKSPACE/$name"
  rm -rf "$root"
  mkdir -p "$root/.specify/memory"
  printf '%s' "$root"
}

write_session() {
  local root="$1"
  local payload="$2"
  printf '%s\n' "$payload" > "$root/.specify/memory/bubbles.session.json"
}

run_guard() {
  local root="$1"
  set +e
  BUBBLES_REPO_ROOT="$root" bash "$GUARD" --quiet >/dev/null 2>&1
  local rc=$?
  set -e
  printf '%s' "$rc"
}

assert_exit() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$description (exit=$actual)"
  else
    fail "$description (expected=$expected actual=$actual)"
  fi
}

# --- Case 1: no sessionBudget -> no-op exit 0 ----------------------------
root1="$(stage_root case1)"
write_session "$root1" '{
  "convergenceLoops": [ { "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 42 } ]
}'
rc1="$(run_guard "$root1")"
assert_exit "no sessionBudget is a no-op" 0 "$rc1"

# --- Case 2: aggregate under cap -> exit 0 -------------------------------
root2="$(stage_root case2)"
write_session "$root2" '{
  "sessionBudget": { "maxTotalConvergenceIterations": 10, "maxWallClockMinutes": null, "maxToolCalls": null },
  "convergenceLoops": [
    { "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 4 },
    { "specDir": "specs/901-b", "agent": "bubbles.workflow", "iterationCount": 5 }
  ]
}'
rc2="$(run_guard "$root2")"
assert_exit "aggregate 9 <= cap 10 passes" 0 "$rc2"

# --- Case 3: aggregate over cap across TWO specs -> exit 1 ---------------
# 6 + 7 = 13 > 10, yet neither single spec exceeds the per-spec G082 cap.
root3="$(stage_root case3)"
write_session "$root3" '{
  "sessionBudget": { "maxTotalConvergenceIterations": 10, "maxWallClockMinutes": null, "maxToolCalls": null },
  "convergenceLoops": [
    { "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 6 },
    { "specDir": "specs/901-b", "agent": "bubbles.workflow", "iterationCount": 7 }
  ]
}'
rc3="$(run_guard "$root3")"
assert_exit "aggregate 13 > cap 10 blocks" 1 "$rc3"

# --- Case 4: context volume over cap while every EVENT cap holds ---------
# The regression this dimension exists for (IMP-039 SCOPE-3): a session well
# inside the iteration, wall-clock, and tool-call caps still carrying enough
# retained tool output to dominate every later request. Without the byte
# dimension this session passes.
root4="$(stage_root case4)"
write_session "$root4" '{
  "sessionBudget": {
    "maxTotalConvergenceIterations": 100,
    "maxWallClockMinutes": null,
    "maxToolCalls": 500,
    "maxSingleToolResultBytes": 50000,
    "maxCumulativeToolResultBytes": 250000
  },
  "toolCallCount": 12,
  "convergenceLoops": [ { "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 2 } ]
}'
mkdir -p "$root4/.specify/runtime"
{
  printf '%s\n' '{"cmd":"a","stdoutBytes":120000,"stderrBytes":0}'
  printf '%s\n' '{"cmd":"b","stdoutBytes":200000,"stderrBytes":0}'
} > "$root4/.specify/runtime/tool-calls.jsonl"
rc4="$(run_guard "$root4")"
assert_exit "retained tool bytes over cap blocks while event caps hold" 1 "$rc4"

# --- Case 5: the same volume with the byte caps unset stays a no-op ------
# Proves case 4 is caused by the cap, not by the presence of a tool-call log.
root5="$(stage_root case5)"
write_session "$root5" '{
  "sessionBudget": {
    "maxTotalConvergenceIterations": 100,
    "maxWallClockMinutes": null,
    "maxToolCalls": 500,
    "maxSingleToolResultBytes": null,
    "maxCumulativeToolResultBytes": null
  },
  "toolCallCount": 12,
  "convergenceLoops": [ { "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 2 } ]
}'
mkdir -p "$root5/.specify/runtime"
{
  printf '%s\n' '{"cmd":"a","stdoutBytes":120000,"stderrBytes":0}'
  printf '%s\n' '{"cmd":"b","stdoutBytes":200000,"stderrBytes":0}'
} > "$root5/.specify/runtime/tool-calls.jsonl"
rc5="$(run_guard "$root5")"
assert_exit "identical volume with byte caps unset is a no-op" 0 "$rc5"

# --- Verdict -------------------------------------------------------------
echo ""
printf 'test_22_session_cap_enforcement: %d passed, %d failed\n' "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
echo "OK: test_22_session_cap_enforcement"
exit 0
