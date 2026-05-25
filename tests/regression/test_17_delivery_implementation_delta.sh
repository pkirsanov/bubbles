#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-17 / Gate G093.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/delivery-implementation-delta-guard.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/delivery-implementation-delta-guard.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/delivery-implementation-delta-guard-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/delivery-implementation-delta-guard.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/delivery-implementation-delta-guard.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/delivery-implementation-delta-guard-selftest.sh"
else
  echo "test_17_delivery_implementation_delta: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

WORKSPACE="$(mktemp -d -t bubbles-g093-regression-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "PASS: $*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "FAIL: $*"; }

display_path() {
  local path="$1"
  if [[ -n "${HOME:-}" && "$path" == "$HOME"/* ]]; then
    printf '~/%s' "${path#$HOME/}"
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

stage_delivery_delta_fixture() {
  local repo="$1"
  rm -rf "$repo"
  mkdir -p "$repo/specs/900-fixture-delivery-delta" "$repo/bubbles"
  cat > "$repo/bubbles/workflows.yaml" <<'YAML'
version: 1
modes:
  full-delivery:
    statusCeiling: done
YAML
  cat > "$repo/specs/900-fixture-delivery-delta/state.json" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/900-fixture-delivery-delta",
  "featureName": "Delivery Delta Fixture",
  "status": "done",
  "workflowMode": "full-delivery",
  "planningOnly": false,
  "planningOnlyJustification": null,
  "certification": { "status": "done" },
  "executionHistory": []
}
JSON
  cat > "$repo/specs/900-fixture-delivery-delta/report.md" <<'EOF'
# Report

### Code Diff Evidence

**Command:** git diff --name-only BASE HEAD
**Exit Code:** 0
**Claim Source:** executed
M src/delivery_delta.ts
M tests/regression/test_delivery_delta.sh
EOF
}

echo "=== test_17_delivery_implementation_delta (Gate G093 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Guard: $(display_path "$GUARD")"
echo "Selftest: $(display_path "$SELFTEST")"

echo ""
echo "--- R1: SCOPE-17 hermetic G093 delivery implementation delta matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: staged fixture delivery implementation delta guard pass ---"
fixture_repo="$WORKSPACE/g093-source-free-fixture"
stage_delivery_delta_fixture "$fixture_repo"
run_check "R2 staged fixture" env BUBBLES_REPO_ROOT="$fixture_repo" bash "$GUARD" "$fixture_repo/specs/900-fixture-delivery-delta"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_17_delivery_implementation_delta: FAILED" >&2
  exit 1
fi

echo "test_17_delivery_implementation_delta: PASSED"
exit 0