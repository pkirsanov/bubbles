#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-10 / Gate G087.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/planning-packet-linkage-guard.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/planning-packet-linkage-guard.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/planning-packet-linkage-guard-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/planning-packet-linkage-guard.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/planning-packet-linkage-guard.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/planning-packet-linkage-guard-selftest.sh"
else
  echo "test_10_planning_packet_linkage: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

WORKSPACE="$(mktemp -d -t bubbles-g087-regression-XXXXXXXX)"
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

stage_planning_linkage_fixture() {
  local repo="$WORKSPACE/g087-source-free-fixture"
  local spec_dir="$repo/specs/900-fixture-planning-linkage"
  rm -rf "$repo"
  mkdir -p "$spec_dir"
  cat > "$spec_dir/state.json" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/900-fixture-planning-linkage",
  "featureName": "Planning Linkage Fixture",
  "status": "specs_hardened",
  "workflowMode": "spec-scope-hardening",
  "linkedImplementationSpec": null,
  "linkedPlanningPacket": null,
  "planningOnly": true,
  "planningOnlyJustification": "Source-repo regression fixture intentionally exercises the planning-only linkage pass path.",
  "specDependsOn": [],
  "certifiedAt": null,
  "requiresRevalidation": false,
  "executionHistory": []
}
JSON
  printf '%s' "$spec_dir"
}

echo "=== test_10_planning_packet_linkage (Gate G087 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Guard: $(display_path "$GUARD")"
echo "Selftest: $(display_path "$SELFTEST")"

echo ""
echo "--- R1: SCOPE-10 hermetic G087 linkage matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: staged fixture linkage guard planning-only pass ---"
fixture_spec="$(stage_planning_linkage_fixture)"
run_check "R2 staged fixture" bash "$GUARD" "$fixture_spec"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_10_planning_packet_linkage: FAILED" >&2
  exit 1
fi

echo "test_10_planning_packet_linkage: PASSED"
exit 0