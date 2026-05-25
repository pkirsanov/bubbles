#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-12 / Gate G089.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/inter-spec-dependency-guard.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/inter-spec-dependency-guard.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/inter-spec-dependency-guard-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/inter-spec-dependency-guard.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/inter-spec-dependency-guard.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/inter-spec-dependency-guard-selftest.sh"
else
  echo "test_12_inter_spec_dependency: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

WORKSPACE="$(mktemp -d -t bubbles-g089-regression-XXXXXXXX)"
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

stage_dependency_fixture() {
  local repo="$1"
  rm -rf "$repo"
  mkdir -p "$repo/specs/900-fixture-inter-spec-dependency" "$repo/specs/901-fixture-dependency-done"
  cat > "$repo/specs/900-fixture-inter-spec-dependency/state.json" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/900-fixture-inter-spec-dependency",
  "featureName": "Inter-Spec Dependency Fixture",
  "status": "in_progress",
  "workflowMode": "full-delivery",
  "linkedImplementationSpec": null,
  "linkedPlanningPacket": null,
  "planningOnly": false,
  "planningOnlyJustification": null,
  "specDependsOn": ["specs/901-fixture-dependency-done"],
  "certifiedAt": null,
  "requiresRevalidation": false,
  "executionHistory": []
}
JSON
  cat > "$repo/specs/901-fixture-dependency-done/state.json" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/901-fixture-dependency-done",
  "featureName": "Done Dependency Fixture",
  "status": "done",
  "workflowMode": "full-delivery",
  "linkedImplementationSpec": null,
  "linkedPlanningPacket": null,
  "planningOnly": false,
  "planningOnlyJustification": null,
  "specDependsOn": [],
  "certifiedAt": "2026-05-01T00:00:00Z",
  "requiresRevalidation": false,
  "executionHistory": []
}
JSON
}

echo "=== test_12_inter_spec_dependency (Gate G089 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Guard: $(display_path "$GUARD")"
echo "Selftest: $(display_path "$SELFTEST")"

echo ""
echo "--- R1: SCOPE-12 hermetic G089 dependency matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: staged fixture dependency guard pass with G092 legacy-read-only boundary ---"
fixture_repo="$WORKSPACE/g089-source-free-fixture"
stage_dependency_fixture "$fixture_repo"
run_check "R2 staged fixture" bash "$GUARD" "$fixture_repo/specs/900-fixture-inter-spec-dependency" --repo-root "$fixture_repo"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_12_inter_spec_dependency: FAILED" >&2
  exit 1
fi

echo "test_12_inter_spec_dependency: PASSED"
exit 0