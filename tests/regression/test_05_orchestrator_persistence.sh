#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-5 / Gate G086.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/orchestrator-persistence-lint.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/orchestrator-persistence-lint.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/orchestrator-persistence-lint.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/orchestrator-persistence-lint.sh"
else
  echo "test_05_orchestrator_persistence: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

TARGET_FILES=(
  "agents/bubbles.goal.agent.md"
  "agents/bubbles.workflow.agent.md"
  "agents/bubbles.iterate.agent.md"
  "agents/bubbles.sprint.agent.md"
)

WORKSPACE="$(mktemp -d -t bubbles-g086-regression-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "PASS: $*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "FAIL: $*"; }

stage_repo() {
  local sid="$1"
  local repo="$WORKSPACE/$sid"
  rm -rf "$repo"
  mkdir -p "$repo/.specify/memory"
  printf '%s' "$repo"
}

write_prompt() {
  local path="$1"
  local extra="$2"
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<EOF
# Regression fixture

## Orchestrator Persistence Default (Gate G086)

Gate G086 enforces the orchestrator persistence default: after any non-terminal phase, this orchestrator MUST automatically continue to the next phase. It may stop only for convergence achieved, max iterations reached, user requests stop, or fundamental impossibility.

$extra
EOF
}

write_all_clean() {
  local repo="$1"
  local rel
  for rel in "${TARGET_FILES[@]}"; do
    write_prompt "$repo/$rel" "Clean persistence-default regression fixture for $rel."
  done
}

run_guard() {
  local repo="$1"
  set +e
  bash "$GUARD" --root "$repo" > "$WORKSPACE/stdout.last" 2> "$WORKSPACE/stderr.last"
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

assert_output_contains() {
  local label="$1"
  local stream="$2"
  local needle="$3"
  if grep -qF "$needle" "$WORKSPACE/$stream.last"; then
    pass "$label $stream contains '$needle'"
  else
    fail "$label $stream missing '$needle'"
    cat "$WORKSPACE/$stream.last"
  fi
}

echo "=== test_05_orchestrator_persistence (Gate G086 regression) ==="

echo ""
echo "--- R1: clean persistence-default prompts pass ---"
repo="$(stage_repo r1-clean)"
write_all_clean "$repo"
run_guard "$repo"
assert_exit "R1 clean" 0
assert_output_contains "R1" "stdout" "PASS Gate G086"

echo ""
echo "--- R2: active forbidden continuation prompt fails ---"
repo="$(stage_repo r2-forbidden)"
write_all_clean "$repo"
write_prompt "$repo/agents/bubbles.iterate.agent.md" "Active prompt text: shall I proceed before the next phase?"
run_guard "$repo"
assert_exit "R2 forbidden" 1
assert_output_contains "R2" "stderr" "G086"
assert_output_contains "R2" "stderr" "shall i proceed"

echo ""
echo "--- R3: explicit FORBIDDEN example remains allowed ---"
repo="$(stage_repo r3-forbidden-example)"
write_all_clean "$repo"
write_prompt "$repo/agents/bubbles.sprint.agent.md" "FORBIDDEN example:\n\`\`\`text\nshall I proceed\n\`\`\`"
run_guard "$repo"
assert_exit "R3 forbidden example" 0
assert_output_contains "R3" "stdout" "PASS Gate G086"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:           %d\n' "$PASS_COUNT"
printf '  Failed:           %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_05_orchestrator_persistence: FAILED" >&2
  exit 1
fi

echo "test_05_orchestrator_persistence: PASSED"
exit 0