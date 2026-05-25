#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-9 state linkage schema/backfill scaffold.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -f "$REPO_ROOT/bubbles/scripts/state-linkage-backfill.sh" ]]; then
  BACKFILL="$REPO_ROOT/bubbles/scripts/state-linkage-backfill.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/state-linkage-backfill-selftest.sh"
elif [[ -f "$REPO_ROOT/.github/bubbles/scripts/state-linkage-backfill.sh" ]]; then
  BACKFILL="$REPO_ROOT/.github/bubbles/scripts/state-linkage-backfill.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/state-linkage-backfill-selftest.sh"
else
  echo "test_09_state_linkage_backfill: backfill script missing from $REPO_ROOT" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-scope9-regression-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

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

stage_backfill_state_fixture() {
  local spec_dir="$WORKSPACE/specs/900-fixture-state-linkage"
  local state="$spec_dir/state.json"
  rm -rf "$WORKSPACE/specs"
  mkdir -p "$spec_dir"
  cat > "$state" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/900-fixture-state-linkage",
  "featureName": "State Linkage Fixture",
  "status": "in_progress",
  "workflowMode": "full-delivery",
  "certification": {
    "status": "in_progress",
    "scopeProgress": [
      { "scope": 1, "name": "one", "status": "Done", "certifiedAt": "2026-05-24T01:00:00Z" },
      { "scope": 2, "name": "two", "status": "Done", "certifiedCompletedAt": "2026-05-24T03:00:00Z" }
    ]
  },
  "executionHistory": []
}
JSON
  printf '%s' "$state"
}

run_fixture_dry_run() {
  local state
  state="$(stage_backfill_state_fixture)"

  set +e
  bash "$BACKFILL" "$state" > "$WORKSPACE/fixture-dry-run.json" 2> "$WORKSPACE/fixture-dry-run.stderr"
  local rc=$?
  set -e
  if [[ "$rc" -ne 0 ]]; then
    cat "$WORKSPACE/fixture-dry-run.stderr"
    return "$rc"
  fi

  jq -e '
    has("linkedImplementationSpec") and
    has("linkedPlanningPacket") and
    has("planningOnly") and
    has("planningOnlyJustification") and
    has("specDependsOn") and
    has("certifiedAt") and
    has("requiresRevalidation") and
    (.linkedImplementationSpec == null) and
    (.linkedPlanningPacket == null) and
    (.planningOnly == false) and
    (.planningOnlyJustification == null) and
    ((.specDependsOn | type) == "array") and
    (.requiresRevalidation == false) and
    (.certifiedAt == "2026-05-24T03:00:00Z")
  ' "$WORKSPACE/fixture-dry-run.json" >/dev/null
}

echo "=== test_09_state_linkage_backfill (SCOPE-9 regression) ==="
echo "Repository: $REPO_ROOT"
echo "Backfill: $BACKFILL"
echo "Selftest: $SELFTEST"

echo ""
echo "--- R1: SCOPE-9 hermetic S1-S4/S5/S6 matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: staged fixture dry-run exposes additive schema fields ---"
run_check "R2 staged fixture dry-run" run_fixture_dry_run

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_09_state_linkage_backfill: FAILED" >&2
  exit 1
fi

echo "test_09_state_linkage_backfill: PASSED"
exit 0