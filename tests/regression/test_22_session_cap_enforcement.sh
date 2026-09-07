#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G128 — session_cap_enforcement_gate
# (IMP-003 SCOPE-2, the AGGREGATE sibling of Gate G082).
# Regression: bugs/BUG-037-session-cap-cross-session-attribution
#
# Stages minimal disposable session fixtures and asserts the guard:
#   * no-ops (exit 0) when no sessionBudget is recorded (the default),
#   * evaluates only records with the exact requested host-session identity,
#   * keeps maxToolCalls unmeasurable without an exact producer, and
#   * preserves strict greater-than, byte, token, diagnostic, and no-bypass
#     behavior for measurable dimensions.

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
  shift
  set +e
  BUBBLES_REPO_ROOT="$root" bash "$GUARD" --quiet "$@" >"$WORKSPACE/last.out" 2>&1
  local rc=$?
  set -e
  printf '%s' "$rc"
}

assert_output() {
  local description="$1"
  local needle="$2"
  if grep -Fq -- "$needle" "$WORKSPACE/last.out"; then
    pass "$description"
  else
    fail "$description (missing: $needle)"
  fi
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

# --- Case 2: old over-cap events are excluded from current -> exit 0 ------
root2="$(stage_root case2)"
write_session "$root2" '{
  "sessionBudget": { "maxTotalConvergenceIterations": 10, "maxWallClockMinutes": null, "maxToolCalls": null },
  "convergenceLoops": [
    { "hostSessionId": "host-old", "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 500 },
    { "hostSessionId": "host-current", "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 9 }
  ]
}'
cp "$root2/.specify/memory/bubbles.session.json" "$root2/session.before"
rc2="$(run_guard "$root2" --session-id host-current)"
assert_exit "exact current convergence 9 <= cap 10 passes despite old over-cap row" 0 "$rc2"
assert_output "event projection reports the exact current observation" "dimension=maxTotalConvergenceIterations cap=10 state=MEASURED observed=9"
if cmp -s "$root2/session.before" "$root2/.specify/memory/bubbles.session.json"; then
  pass "event projection preserves retained history byte-identical"
else
  fail "event projection modified retained session history"
fi

# --- Case 3: one-unit-over current convergence -> exit 1 ------------------
root3="$(stage_root case3)"
write_session "$root3" '{
  "sessionBudget": { "maxTotalConvergenceIterations": 10, "maxWallClockMinutes": null, "maxToolCalls": null },
  "convergenceLoops": [
    { "hostSessionId": "host-current", "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 11 }
  ]
}'
rc3="$(run_guard "$root3" --session-id host-current)"
assert_exit "exact current convergence 11 > cap 10 blocks" 1 "$rc3"
assert_output "one-unit-over breach names the exact session" "G128 BREACH session=host-current"

# --- Case 4: old oversized byte rows are excluded -------------------------
root4="$(stage_root case4)"
write_session "$root4" '{
  "sessionBudget": {
    "maxTotalConvergenceIterations": 100,
    "maxWallClockMinutes": null,
    "maxToolCalls": 500,
    "maxSingleToolResultBytes": 50000,
    "maxCumulativeToolResultBytes": 250000
  },
  "toolCallCount": 999999,
  "convergenceLoops": [ { "hostSessionId": "host-current", "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 2 } ]
}'
mkdir -p "$root4/.specify/runtime"
{
  printf '%s\n' '{"sessionId":"host-old","cmd":"a","stdoutBytes":120000,"stderrBytes":0}'
  printf '%s\n' '{"sessionId":"host-old","cmd":"b","stdoutBytes":200000,"stderrBytes":0}'
  printf '%s\n' '{"sessionId":"host-current","cmd":"c","stdoutBytes":200,"stderrBytes":5}'
  printf '%s\n' '{"cmd":"legacy","stdoutBytes":999999,"stderrBytes":0}'
} > "$root4/.specify/runtime/tool-calls.jsonl"
cp "$root4/.specify/runtime/tool-calls.jsonl" "$root4/tool-log.before"
rc4="$(run_guard "$root4" --session-id host-current)"
assert_exit "old oversized tool bytes and legacy scalar do not block current session" 0 "$rc4"
assert_output "single-result bytes are exact-session scoped" "dimension=maxSingleToolResultBytes cap=50000 state=MEASURED observed=205"
assert_output "maxToolCalls remains honestly unmeasurable" "dimension=maxToolCalls cap=500 state=UNMEASURABLE observed=- reason=no-exact-producer"
assert_output "mismatched and unattributed tool rows remain visibly excluded" "records source=tool-results matching=1 mismatched=2 unattributed=1 excluded=3 eligible=1"
if cmp -s "$root4/tool-log.before" "$root4/.specify/runtime/tool-calls.jsonl"; then
  pass "byte projection preserves retained tool history byte-identical"
else
  fail "byte projection modified retained tool history"
fi

# --- Case 5: current oversized bytes still breach -------------------------
root5="$(stage_root case5)"
write_session "$root5" '{
  "sessionBudget": {
    "maxSingleToolResultBytes": 50000,
    "maxCumulativeToolResultBytes": 250000
  }
}'
mkdir -p "$root5/.specify/runtime"
{
  printf '%s\n' '{"sessionId":"host-current","cmd":"a","stdoutBytes":120000,"stderrBytes":0}'
  printf '%s\n' '{"sessionId":"host-current","cmd":"b","stdoutBytes":200000,"stderrBytes":0}'
} > "$root5/.specify/runtime/tool-calls.jsonl"
rc5="$(run_guard "$root5" --session-id host-current)"
assert_exit "current oversized retained bytes block their owning session" 1 "$rc5"
assert_output "current byte breach names the exact session" "G128 BREACH session=host-current"

# --- Case 6: active budget with no exact identity -> exit 2 --------------
root6="$(stage_root case6)"
write_session "$root6" '{ "sessionBudget": { "maxToolCalls": 1 }, "toolCallCount": 999 }'
rc6="$(run_guard "$root6")"
assert_exit "active budget without exact session identity is an input error" 2 "$rc6"
assert_output "missing identity is not reported as a pass or breach" "G128 INPUT-ERROR reason=missing-session-id"

# --- Case 7: one exact usage artifact measures; prefix ambiguity abstains --
root7="$(stage_root case7)"
mkdir -p "$root7/.github" "$root7/usage/ws-a/chatSessions" "$root7/usage/ws-b/chatSessions"
printf 'usage:\n  adapter: vscode-copilot\n' > "$root7/.github/bubbles-project.yaml"
printf '%s\n' '{"requestId":"a","promptTokens":70,"completionTokens":1}' > "$root7/usage/ws-a/chatSessions/host-current.jsonl"
printf '%s\n' '{"requestId":"b","promptTokens":9999,"completionTokens":1}' > "$root7/usage/ws-b/chatSessions/host-current-old.jsonl"
write_session "$root7" '{ "sessionBudget": { "maxPromptTokensPerRequest": 70, "maxCumulativePromptTokens": 70 } }'
set +e
BUBBLES_USAGE_VSCODE_ROOT="$root7/usage" BUBBLES_REPO_ROOT="$root7" bash "$GUARD" --quiet --session-id host-current >"$WORKSPACE/last.out" 2>&1
rc7=$?
set -e
assert_exit "one exact usage artifact is selected instead of its prefix sibling" 0 "$rc7"
assert_output "exact token equality remains non-breaching" "dimension=maxPromptTokensPerRequest cap=70 state=MEASURED observed=70"

# --- Case 8: seven dimensions and record classes remain visible in quiet --
root8="$(stage_root case8)"
write_session "$root8" '{ "sessionBudget": { "maxToolCalls": 1 } }'
rc8="$(run_guard "$root8" --session-id host-current)"
assert_exit "quiet diagnostic evaluation without exact tool-call producer passes" 0 "$rc8"
dimension_count="$(grep -c '^dimension=' "$WORKSPACE/last.out" 2>/dev/null || true)"
if [[ "$dimension_count" == "7" ]]; then
  pass "quiet output lists all seven dimensions"
else
  fail "quiet output expected seven dimensions, got ${dimension_count:-0}"
fi
assert_output "quiet output retains record-class counts" "matching=0 mismatched=0 unattributed=0 excluded=0 eligible=0"
assert_output "quiet output retains state and verdict" "G128 PASS session=host-current"

# --- Case 9: wall-clock history is isolated and equality stays allowed ----
root9="$(stage_root case9)"
write_session "$root9" '{
  "sessionBudget": { "maxWallClockMinutes": 10 },
  "turnSnapshots": [
    { "hostSessionId": "host-old", "timestamp": "2026-08-01T00:00:00Z" },
    { "hostSessionId": "host-old", "timestamp": "2026-08-01T04:00:00Z" },
    { "hostSessionId": "host-current", "timestamp": "2026-09-01T00:00:00Z" },
    { "hostSessionId": "host-current", "timestamp": "2026-09-01T00:10:00Z" }
  ]
}'
rc9="$(run_guard "$root9" --session-id host-current)"
assert_exit "old elapsed time is excluded and current equality remains non-breaching" 0 "$rc9"
assert_output "wall-clock projection measures only exact current turns" "dimension=maxWallClockMinutes cap=10 state=MEASURED observed=10"
write_session "$root9" '{
  "sessionBudget": { "maxWallClockMinutes": 10 },
  "turnSnapshots": [
    { "hostSessionId": "host-current", "timestamp": "2026-09-01T00:00:00Z" },
    { "hostSessionId": "host-current", "timestamp": "2026-09-01T00:11:00Z" }
  ]
}'
rc9_over="$(run_guard "$root9" --session-id host-current)"
assert_exit "current wall-clock usage one minute over cap breaches" 1 "$rc9_over"
assert_output "wall-clock breach names the exact measured dimension" "breach dimension=maxWallClockMinutes observed=11 cap=10"

# --- Case 10: measured-only soft boundary remains exactly 70 percent ------
root10="$(stage_root case10)"
write_session "$root10" '{
  "sessionBudget": { "maxTotalConvergenceIterations": 10, "maxToolCalls": 1 },
  "convergenceLoops": [
    { "hostSessionId": "host-current", "specDir": "specs/900-a", "agent": "bubbles.workflow", "iterationCount": 7 }
  ],
  "toolCallCount": 999999
}'
rc10="$(run_guard "$root10" --session-id host-current)"
assert_exit "measured convergence at 70 percent remains a non-breaching soft boundary" 0 "$rc10"
assert_output "soft boundary uses the measured dimension and exact threshold" "softBoundary=crossed dimension=maxTotalConvergenceIterations observed=7 cap=10 consumedPct=70 threshold=70"
assert_output "unmeasurable tool calls do not enter soft-boundary selection" "dimension=maxToolCalls cap=1 state=UNMEASURABLE observed=- reason=no-exact-producer"

# --- Case 11: all-null policy is identity-free and bypass flags fail ------
root11="$(stage_root case11)"
write_session "$root11" '{
  "sessionBudget": {
    "maxTotalConvergenceIterations": null,
    "maxWallClockMinutes": null,
    "maxToolCalls": null,
    "maxSingleToolResultBytes": null,
    "maxCumulativeToolResultBytes": null,
    "maxPromptTokensPerRequest": null,
    "maxCumulativePromptTokens": null
  }
}'
rc11="$(run_guard "$root11")"
assert_exit "all seven null caps remain an identity-free no-op" 0 "$rc11"
assert_output "all-null policy makes no measurement claim" "G128 NO-ACTIVE-BUDGET reason=all-caps-null"
rc11_bypass="$(run_guard "$root11" --skip)"
assert_exit "bypass-shaped flags remain rejected in the default-off posture" 2 "$rc11_bypass"
assert_output "bypass refusal names the unknown flag" "unknown flag: --skip"

# --- Verdict -------------------------------------------------------------
echo ""
printf 'test_22_session_cap_enforcement: %d passed, %d failed\n' "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
echo "OK: test_22_session_cap_enforcement"
exit 0
