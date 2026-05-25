#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-15 / Gate G091.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/planning-workflow-chain-guard.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/planning-workflow-chain-guard.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/planning-workflow-chain-guard-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/planning-workflow-chain-guard.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/planning-workflow-chain-guard.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/planning-workflow-chain-guard-selftest.sh"
else
  echo "test_15_planning_workflow_chain: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "PASS: $*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "FAIL: $*"; }

run_check() {
  local label="$1"
  shift
  set +e
  "$@"
  local rc=$?
  set -e
  if [[ "$rc" -eq 0 ]]; then
    pass "$label exit=$rc"
  else
    fail "$label exit=$rc"
  fi
}

echo "=== test_15_planning_workflow_chain (Gate G091 regression) ==="
echo "Repository: $REPO_ROOT"
echo "Guard: $GUARD"
echo "Selftest: $SELFTEST"

echo ""
echo "--- R1: SCOPE-15 hermetic S1-S7 matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: live Bubbles planning chain guard ---"
run_check "R2 live guard" bash "$GUARD" --root "$REPO_ROOT"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_15_planning_workflow_chain: FAILED" >&2
  exit 1
fi

echo "test_15_planning_workflow_chain: PASSED"
exit 0