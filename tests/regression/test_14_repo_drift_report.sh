#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-14 repo drift report visibility.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -f "$REPO_ROOT/bubbles/scripts/repo-drift-report.sh" ]]; then
  REPORT="$REPO_ROOT/bubbles/scripts/repo-drift-report.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/repo-drift-report-selftest.sh"
elif [[ -f "$REPO_ROOT/.github/bubbles/scripts/repo-drift-report.sh" ]]; then
  REPORT="$REPO_ROOT/.github/bubbles/scripts/repo-drift-report.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/repo-drift-report-selftest.sh"
else
  echo "test_14_repo_drift_report: report script not found from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "PASS: $*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "FAIL: $*"; }

display_path() {
  local path="$1"
  if [[ -n "${HOME:-}" && "$path" == "$HOME"/* ]]; then
    # shellcheck disable=SC2088  # literal ~/ is intentional display text, not a path to expand
    printf '~/%s' "${path#"$HOME"/}"
  else
    printf '%s' "$path"
  fi
}

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

echo "=== test_14_repo_drift_report (SCOPE-14 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Report: $(display_path "$REPORT")"
echo "Selftest: $(display_path "$SELFTEST")"

echo ""
echo "--- R1: SCOPE-14 hermetic report matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: live repository drift report renders markdown and remains informational ---"
run_check "R2 live report" bash "$REPORT" --repo-root "$REPO_ROOT"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_14_repo_drift_report: FAILED" >&2
  exit 1
fi

echo "test_14_repo_drift_report: PASSED"
exit 0