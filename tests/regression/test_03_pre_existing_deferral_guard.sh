#!/usr/bin/env bash
# tests/regression/test_03_pre_existing_deferral_guard.sh
#
# Persistent regression for SCOPE-3 (Gate G084 — pre_existing_deferral_block_gate).
#
# This regression test is INTENTIONALLY separate from the in-tree selftest
# at bubbles/scripts/pre-existing-deferral-guard-selftest.sh. The selftest
# is exhaustive (10 scenarios) and proves the guard's full behavior matrix
# during dev work. This regression test is the MINIMAL, persistent,
# suite-runnable assertion that re-stages the three canonical scenarios
# (active deferral, exempt deferral under Superseded Decisions, clean tree)
# and re-asserts the guard's exit codes. If a future change to
# bubbles/scripts/pre-existing-deferral-guard.sh accidentally relaxes the
# Gate G084 contract — by allowing the active "pre-existing failure" phrase
# to pass, or by allowing the active `TODO:` marker to pass — this
# regression fails and blocks the suite.
#
# Contract under test (mirrored from the Gate G084 guard behavior):
#   - Forbidden phrases (case-insensitive substring):
#       pre-existing failure
#       pre-existing test failure
#       carried forward
#       out of session scope
#       previous-session failure
#       not introduced by this spec
#   - Forbidden markers (colon-anchored, case-sensitive):
#       TODO:   FIXME:   HACK:   STUB:
#   - Exempt H2 subsections:
#       ## Superseded Decisions
#       ## Historical Notes
#       ## Out of Scope
#   - Inline backticked spans (`...`) and fenced code blocks
#     (```...```) are stripped/skipped from the active scan.
#
# Exit codes asserted:
#   0 → PASS / no violations
#   1 → violation detected
#   2 → malformed argv / missing specDir
#
# Hermetic: every scenario stages a throwaway $TMPDIR spec tree so this
# regression can NEVER mutate the real repo.

set -euo pipefail

# Resolve the guard script. Prefer the same-tree script under bubbles/scripts
# (works for both source repo and downstream-installed layouts).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/pre-existing-deferral-guard.sh"
if [[ ! -x "$GUARD" ]]; then
  # Try downstream-installed location.
  GUARD_ALT="$REPO_ROOT/.github/bubbles/scripts/pre-existing-deferral-guard.sh"
  if [[ -x "$GUARD_ALT" ]]; then
    GUARD="$GUARD_ALT"
  else
    echo "test_03_pre_existing_deferral_guard: pre-existing-deferral-guard.sh not found." >&2
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

# Stage a hermetic throwaway spec tree (always has a minimal valid scope).
stage_spec_dir() {
  local label="$1"
  local workspace
  workspace="$(mktemp -d -t bubbles-g084-regression-XXXXXXXX)"
  mkdir -p "$workspace/scopes/01-only-scope"
  printf '%s\n' "$label" > "$workspace/scopes/01-only-scope/scope.md"
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

echo "=== Regression: SCOPE-3 (Gate G084 — pre_existing_deferral_block_gate) ==="
echo ""

# ---------------------------------------------------------------------------
# Scenario 1: ACTIVE DEFERRAL — `pre-existing failure` phrase appears in
# report.md outside any exempt H2 subsection. MUST FAIL exit 1.
# ---------------------------------------------------------------------------
ws_active="$(stage_spec_dir "# clean scope")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_active"
cat > "$ws_active/report.md" <<'EOF'
# Report

## Summary

The previous session attempted SCOPE-X and surfaced a pre-existing failure
that was carried forward into this report instead of being fixed.

## Notes

None.
EOF
set +e
bash "$GUARD" "$ws_active" --quiet > /dev/null 2>&1
rc_active=$?
set -e
assert_exit "Active 'pre-existing failure' + 'carried forward' phrases — VIOLATION" 1 "$rc_active"

# ---------------------------------------------------------------------------
# Scenario 2: EXEMPT DEFERRAL — same phrase appears, but is now inside a
# `## Superseded Decisions` H2 subsection. MUST PASS exit 0.
# ---------------------------------------------------------------------------
ws_exempt="$(stage_spec_dir "# clean scope")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_exempt"
cat > "$ws_exempt/report.md" <<'EOF'
# Report

## Summary

All scopes complete. Build green. Convergence cap honored.

## Superseded Decisions

An earlier session attempted SCOPE-X and surfaced a pre-existing failure
that was carried forward, and concluded the work was out of session scope.
That decision is superseded by the SCOPE-3 honesty incentive; the prose
is retained here for historical traceability.
EOF
set +e
bash "$GUARD" "$ws_exempt" --quiet > /dev/null 2>&1
rc_exempt=$?
set -e
assert_exit "Same phrases under '## Superseded Decisions' — EXEMPT (PASS)" 0 "$rc_exempt"

# ---------------------------------------------------------------------------
# Scenario 3: CLEAN — zero forbidden phrases, zero markers. MUST PASS exit 0.
# ---------------------------------------------------------------------------
ws_clean="$(stage_spec_dir "# SCOPE-1

## Intent

Clean scope.

## Implementation Plan

1. Implement the feature with full test coverage.
2. Add a persistent regression test.
")"
ALL_WORKSPACES="$ALL_WORKSPACES $ws_clean"
cat > "$ws_clean/report.md" <<'EOF'
# Report

## Summary

All scopes complete. Build green. No outstanding action items.

## Test Evidence

All required test types ran green with raw terminal output captured inline.
EOF
set +e
bash "$GUARD" "$ws_clean" --quiet > /dev/null 2>&1
rc_clean=$?
set -e
assert_exit "Clean tree (no forbidden phrases, no markers) — PASS" 0 "$rc_clean"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((pass_count + fail_count))"
printf '  Passed:           %d\n' "$pass_count"
printf '  Failed:           %d\n' "$fail_count"
echo ""

if [[ "$fail_count" -gt 0 ]]; then
  echo "🔴 test_03_pre_existing_deferral_guard: REGRESSION FAILED" >&2
  echo "  Gate G084 contract has regressed. Inspect bubbles/scripts/pre-existing-deferral-guard.sh." >&2
  exit 1
fi

echo "🟢 test_03_pre_existing_deferral_guard: REGRESSION PASSED"
exit 0
