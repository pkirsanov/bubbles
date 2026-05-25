#!/usr/bin/env bash
# tests/regression/test_02_context_compaction_discipline.sh
#
# Persistent regression for SCOPE-2 (Gate G083 — context_compaction_discipline_gate).
#
# This regression test is INTENTIONALLY separate from the in-tree selftest
# at bubbles/scripts/compaction-discipline-guard-selftest.sh. The selftest
# is exhaustive and proves the guard's full behavior matrix during dev work.
# This regression test is the MINIMAL, persistent, suite-runnable assertion
# that re-stages the three canonical scenarios (count breach, size breach,
# compliant) and re-asserts the guard's exit codes. If a future change to
# bubbles/scripts/compaction-discipline-guard.sh accidentally relaxes the
# Gate G083 contract, this regression fails and blocks the suite.
#
# Contract under test (from operating-baseline.md → "Context Compaction
# Discipline"):
#   - Eligible slice = all envelopesReceived[] for the spec EXCEPT the
#     latest 2 (kept raw by policy).
#   - The eligible slice MUST satisfy BOTH:
#       count <= 3
#       cumulative rawSizeBytes <= 8192
#     UNLESS each over-budget envelope has a `compactedAt` timestamp.
#   - Thresholds are framework constants (NOT workflows.yaml-configurable).
#
# Exit codes asserted:
#   0 → PASS / no-op
#   1 → violation (count threshold OR size threshold)
#   2 → malformed state
#
# Hermetic: uses a throwaway $BUBBLES_REPO_ROOT workspace so it can NEVER
# mutate the real repo session file.

set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "test_02_context_compaction_discipline: jq is required but not found in PATH." >&2
  echo "  Install jq before running this regression." >&2
  exit 2
fi

# Resolve the guard script. Prefer the same-tree script under bubbles/scripts
# (works for both source repo and downstream-installed layouts).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/compaction-discipline-guard.sh"
if [[ ! -x "$GUARD" ]]; then
  # Try downstream-installed location.
  GUARD_ALT="$REPO_ROOT/.github/bubbles/scripts/compaction-discipline-guard.sh"
  if [[ -x "$GUARD_ALT" ]]; then
    GUARD="$GUARD_ALT"
  else
    echo "test_02_context_compaction_discipline: compaction-discipline-guard.sh not found." >&2
    echo "  Tried: $GUARD" >&2
    echo "  Tried: $GUARD_ALT" >&2
    exit 2
  fi
fi

pass_count=0
fail_count=0

assert_exit() {
  local description="$1"
  local expected_code="$2"
  local actual_code="$3"
  if [[ "$expected_code" -eq "$actual_code" ]]; then
    pass_count=$((pass_count + 1))
    printf '  ✅ PASS: %s (exit=%s)\n' "$description" "$actual_code"
  else
    fail_count=$((fail_count + 1))
    printf '  ❌ FAIL: %s (expected exit=%s, actual=%s)\n' "$description" "$expected_code" "$actual_code"
  fi
}

# Stage a hermetic throwaway workspace per scenario.
stage_workspace() {
  local label="$1"
  local fixture_json="$2"
  local workspace
  workspace="$(mktemp -d -t bubbles-g083-regression-XXXXXX)"
  mkdir -p "$workspace/.specify/memory" "$workspace/specs/regression-spec"
  printf '%s\n' "$fixture_json" > "$workspace/.specify/memory/bubbles.session.json"
  printf '%s\n' "$label" > "$workspace/specs/regression-spec/spec.md"
  printf '%s' "$workspace"
}

cleanup() {
  if [[ -n "${ALL_WORKSPACES:-}" ]]; then
    # shellcheck disable=SC2086
    rm -rf $ALL_WORKSPACES 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM
ALL_WORKSPACES=""

echo "=== Regression: SCOPE-2 (Gate G083 — context_compaction_discipline_gate) ==="
echo ""

# ---------------------------------------------------------------------------
# Scenario 1: COMPLIANT — eligible slice (after keeping latest 2 raw) has
# count == 3 and cumulative rawSizeBytes == 6000 (3 * 2000). MUST PASS.
# Total: 5 envelopes. Latest 2 kept raw → eligible = first 3.
# ---------------------------------------------------------------------------
compliant_fixture="$(jq -nc '{
  envelopesReceived: [
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:00:00Z", rawSizeBytes: 2000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:01:00Z", rawSizeBytes: 2000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:02:00Z", rawSizeBytes: 2000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:03:00Z", rawSizeBytes: 9999},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:04:00Z", rawSizeBytes: 9999}
  ]
}')"
ws_compliant="$(stage_workspace "compliant" "$compliant_fixture")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_compliant"
set +e
BUBBLES_REPO_ROOT="$ws_compliant" bash "$GUARD" "$ws_compliant/specs/regression-spec" --quiet > /dev/null 2>&1
rc_compliant=$?
set -e
assert_exit "Compliant fixture (3 eligible, 6000 bytes) — PASS" 0 "$rc_compliant"

# ---------------------------------------------------------------------------
# Scenario 2: COUNT BREACH — eligible slice has count == 4 (> 3 threshold)
# with each envelope at 1000 bytes (cumulative 4000 < 8192). MUST FAIL exit 1.
# Total: 6 envelopes. Latest 2 kept raw → eligible = first 4.
# ---------------------------------------------------------------------------
count_breach_fixture="$(jq -nc '{
  envelopesReceived: [
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:00:00Z", rawSizeBytes: 1000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:01:00Z", rawSizeBytes: 1000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:02:00Z", rawSizeBytes: 1000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:03:00Z", rawSizeBytes: 1000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:04:00Z", rawSizeBytes: 9999},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:05:00Z", rawSizeBytes: 9999}
  ]
}')"
ws_count="$(stage_workspace "count_breach" "$count_breach_fixture")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_count"
set +e
BUBBLES_REPO_ROOT="$ws_count" bash "$GUARD" "$ws_count/specs/regression-spec" --quiet > /dev/null 2>&1
rc_count=$?
set -e
assert_exit "Count-breach fixture (4 eligible, no compactedAt) — VIOLATION" 1 "$rc_count"

# ---------------------------------------------------------------------------
# Scenario 3: SIZE BREACH — eligible slice has count == 3 (within count
# budget) but cumulative rawSizeBytes == 10500 (> 8192 threshold). MUST
# FAIL exit 1. Total: 5 envelopes. Latest 2 kept raw → eligible = first 3.
# ---------------------------------------------------------------------------
size_breach_fixture="$(jq -nc '{
  envelopesReceived: [
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:00:00Z", rawSizeBytes: 3500},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:01:00Z", rawSizeBytes: 3500},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:02:00Z", rawSizeBytes: 3500},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:03:00Z", rawSizeBytes: 1000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:04:00Z", rawSizeBytes: 1000}
  ]
}')"
ws_size="$(stage_workspace "size_breach" "$size_breach_fixture")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_size"
set +e
BUBBLES_REPO_ROOT="$ws_size" bash "$GUARD" "$ws_size/specs/regression-spec" --quiet > /dev/null 2>&1
rc_size=$?
set -e
assert_exit "Size-breach fixture (3 eligible, 10500 bytes, no compactedAt) — VIOLATION" 1 "$rc_size"

# ---------------------------------------------------------------------------
# Scenario 4: SIZE BREACH WITH compactedAt — same shape as Scenario 3,
# but every over-budget envelope carries a `compactedAt` timestamp.
# MUST PASS exit 0 (the timestamp clears the over-budget entry).
# ---------------------------------------------------------------------------
size_breach_compacted_fixture="$(jq -nc '{
  envelopesReceived: [
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:00:00Z", rawSizeBytes: 3500, compactedAt: "2025-01-01T00:00:30Z"},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:01:00Z", rawSizeBytes: 3500, compactedAt: "2025-01-01T00:01:30Z"},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:02:00Z", rawSizeBytes: 3500, compactedAt: "2025-01-01T00:02:30Z"},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:03:00Z", rawSizeBytes: 1000},
    {specDir: "specs/regression-spec", agent: "a", receivedAt: "2025-01-01T00:04:00Z", rawSizeBytes: 1000}
  ]
}')"
ws_compacted="$(stage_workspace "size_breach_compacted" "$size_breach_compacted_fixture")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_compacted"
set +e
BUBBLES_REPO_ROOT="$ws_compacted" bash "$GUARD" "$ws_compacted/specs/regression-spec" --quiet > /dev/null 2>&1
rc_compacted=$?
set -e
assert_exit "Size-breach fixture WITH compactedAt — PASS (cleared by stamp)" 0 "$rc_compacted"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((pass_count + fail_count))"
printf '  Passed:           %d\n' "$pass_count"
printf '  Failed:           %d\n' "$fail_count"
echo ""

if [[ "$fail_count" -gt 0 ]]; then
  echo "🔴 test_02_context_compaction_discipline: REGRESSION FAILED" >&2
  echo "  Gate G083 contract has regressed. Inspect bubbles/scripts/compaction-discipline-guard.sh." >&2
  exit 1
fi

echo "🟢 test_02_context_compaction_discipline: ALL SCENARIOS PASS"
exit 0
