#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-16 / Gate G092.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/strict-terminal-status-guard.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/strict-terminal-status-guard.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/strict-terminal-status-guard-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/strict-terminal-status-guard.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/strict-terminal-status-guard.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/strict-terminal-status-guard-selftest.sh"
else
  echo "test_16_strict_terminal_status: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

WORKSPACE="$(mktemp -d -t bubbles-g092-regression-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

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

stage_strict_terminal_fixture() {
  local repo="$1"
  rm -rf "$repo"
  mkdir -p "$repo/specs/900-fixture-strict-terminal-status" "$repo/bubbles" "$repo/agents/bubbles_shared"
  cat > "$repo/bubbles/workflows.yaml" <<'YAML'
version: 1
outcomeStates:
  done:
    description: Done with optional non-status observations.
  blocked:
    description: Required work remains.
legacyOutcomeStates:
  done_with_concerns:
    description: Legacy read-only compatibility state; migration writes done plus observations or blocked.
    readOnlyCompatibility: true
YAML
  cat > "$repo/agents/bubbles_shared/completion-governance.md" <<'EOF'
# Completion Governance Fixture

New terminal certification writes use `done` or `blocked` only. Legacy `done_with_concerns` is read-only compatibility metadata until migration.
EOF
  cat > "$repo/specs/900-fixture-strict-terminal-status/state.json" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/900-fixture-strict-terminal-status",
  "featureName": "Strict Terminal Fixture",
  "status": "done",
  "workflowMode": "full-delivery",
  "observations": [{"severity":"low","summary":"Monitor fixture."}],
  "certification": {
    "status": "done",
    "observations": [{"severity":"low","summary":"Monitor fixture."}]
  },
  "specDependsOn": [],
  "requiresRevalidation": false,
  "executionHistory": []
}
JSON
}

echo "=== test_16_strict_terminal_status (Gate G092 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Guard: $(display_path "$GUARD")"
echo "Selftest: $(display_path "$SELFTEST")"

echo ""
echo "--- R1: SCOPE-16 hermetic G092 strict terminal status matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: staged fixture strict terminal status guard pass ---"
fixture_repo="$WORKSPACE/g092-source-free-fixture"
stage_strict_terminal_fixture "$fixture_repo"
run_check "R2 staged fixture" bash "$GUARD" "$fixture_repo/specs/900-fixture-strict-terminal-status" --repo-root "$fixture_repo"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_16_strict_terminal_status: FAILED" >&2
  exit 1
fi

echo "test_16_strict_terminal_status: PASSED"
exit 0