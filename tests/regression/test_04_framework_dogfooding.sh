#!/usr/bin/env bash
# tests/regression/test_04_framework_dogfooding.sh
#
# Persistent regression for SCOPE-4 (Gate G085 —
# framework_dogfood_evidence_gate).
#
# This regression test is INTENTIONALLY separate from the in-tree selftest
# at bubbles/scripts/framework-dogfood-guard-selftest.sh. The selftest
# is exhaustive (8 scenarios) and proves the guard's full behavior matrix
# during dev work. This regression test is the MINIMAL, persistent,
# suite-runnable assertion that re-stages the canonical source-aware
# fixtures: the Bubbles source repo must not contain persistent specs/,
# while downstream/fixture repos still prove dogfood evidence through
# at least one done numbered spec.
#
# Exit codes asserted:
#   0 → Bubbles source repo with no specs/ and evidence surfaces, or downstream done spec
#   1 → Bubbles source repo contains specs/, or downstream zero done specs
#
# Hermetic: every scenario stages a throwaway `mktemp` repo root so this
# regression can NEVER mutate the real repo.

set -euo pipefail

# Resolve the guard script. Prefer the same-tree script under bubbles/scripts
# (works for both source repo and downstream-installed layouts).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/framework-dogfood-guard.sh"
if [[ ! -x "$GUARD" ]]; then
  GUARD_ALT="$REPO_ROOT/.github/bubbles/scripts/framework-dogfood-guard.sh"
  if [[ -x "$GUARD_ALT" ]]; then
    GUARD="$GUARD_ALT"
  else
    echo "test_04_framework_dogfooding: framework-dogfood-guard.sh not found." >&2
    echo "  Tried: $GUARD" >&2
    echo "  Tried: $GUARD_ALT" >&2
    exit 2
  fi
fi

pass_count=0
fail_count=0
ALL_WORKSPACES=""

cleanup() {
  if [[ -n "$ALL_WORKSPACES" ]]; then
    # shellcheck disable=SC2086
    rm -rf $ALL_WORKSPACES 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

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

assert_stderr_contains() {
  local description="$1"
  local stderr_file="$2"
  local needle="$3"
  if grep -qF "$needle" "$stderr_file"; then
    pass_count=$((pass_count + 1))
    printf '  ✅ PASS: %s\n' "$description"
  else
    fail_count=$((fail_count + 1))
    printf '  ❌ FAIL: %s (stderr missing %q)\n' "$description" "$needle"
    sed 's/^/      /' "$stderr_file" >&2
  fi
}

# Stage a hermetic mktemp downstream/fixture repo root.
stage_repo() {
  local workspace
  workspace="$(mktemp -d -t bubbles-g085-regression-XXXXXXXX)"
  mkdir -p "$workspace/.specify/memory"
  mkdir -p "$workspace/specs"
  ALL_WORKSPACES="$ALL_WORKSPACES $workspace"
  printf '%s' "$workspace"
}

stage_source_repo() {
  local workspace
  workspace="$(mktemp -d -t bubbles-g085-source-XXXXXXXX)"
  mkdir -p "$workspace/.specify/memory" "$workspace/bubbles/scripts" "$workspace/agents"
  touch "$workspace/install.sh" "$workspace/VERSION" "$workspace/bubbles/release-manifest.json"
  cat > "$workspace/bubbles/scripts/framework-validate.sh" <<'EOF'
#!/usr/bin/env bash
run_check "Framework dogfood guard selftest" bash "$SCRIPT_DIR/framework-dogfood-guard-selftest.sh"
EOF
  cat > "$workspace/bubbles/scripts/framework-dogfood-guard-selftest.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$workspace/bubbles/scripts/framework-validate.sh" "$workspace/bubbles/scripts/framework-dogfood-guard-selftest.sh"
  ALL_WORKSPACES="$ALL_WORKSPACES $workspace"
  printf '%s' "$workspace"
}

# Write a minimal valid state.json with the given status.
write_state() {
  local path="$1"
  local status="$2"
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<EOF
{
  "version": 3,
  "featureDir": "specs/$(basename "$(dirname "$path")")",
  "status": "$status"
}
EOF
}

echo "=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ==="
echo ""

# ---------------------------------------------------------------------------
# Scenario S1: SOURCE CLEAN — canonical source repo has no specs/ but has
# validation/release evidence surfaces. MUST PASS exit 0.
# ---------------------------------------------------------------------------
ws_source_clean="$(stage_source_repo)"
set +e
bash "$GUARD" --repo-root "$ws_source_clean" --quiet > /dev/null 2>&1
rc_source_clean=$?
set -e
assert_exit "S1 source repo without specs/ — PASS" 0 "$rc_source_clean"

# ---------------------------------------------------------------------------
# Scenario S2: SOURCE WITH SPECS — canonical source repo contains specs/.
# MUST FAIL exit 1, stderr cites G085 and source no-specs rule.
# ---------------------------------------------------------------------------
ws_source_specs="$(stage_source_repo)"
mkdir -p "$ws_source_specs/specs"
stderr_source_specs="$ws_source_specs/stderr.log"
set +e
bash "$GUARD" --repo-root "$ws_source_specs" --quiet > /dev/null 2> "$stderr_source_specs"
rc_source_specs=$?
set -e
assert_exit "S2 source repo with specs/ — VIOLATION" 1 "$rc_source_specs"
assert_stderr_contains "S2 stderr cites Gate G085" "$stderr_source_specs" "G085"
assert_stderr_contains "S2 stderr cites source no-specs rule" "$stderr_source_specs" "MUST NOT contain persistent specs/"

# ---------------------------------------------------------------------------
# Scenario S3: EXACTLY ONE DOWNSTREAM DONE — specs/001-foo/state.json has status: done.
# MUST PASS exit 0.
# ---------------------------------------------------------------------------
ws_done="$(stage_repo)"
write_state "$ws_done/specs/001-foo/state.json" "done"
set +e
bash "$GUARD" --repo-root "$ws_done" --quiet > /dev/null 2>&1
rc_done=$?
set -e
assert_exit "S3 exactly one downstream done numbered spec — PASS" 0 "$rc_done"

# ---------------------------------------------------------------------------
# Scenario S4: ONE IN_PROGRESS, ZERO DONE — specs/001-foo/state.json has
# status: in_progress (not done). MUST FAIL exit 1.
# ---------------------------------------------------------------------------
ws_in_progress="$(stage_repo)"
write_state "$ws_in_progress/specs/001-foo/state.json" "in_progress"
stderr_in_progress="$ws_in_progress/stderr.log"
set +e
bash "$GUARD" --repo-root "$ws_in_progress" --quiet > /dev/null 2> "$stderr_in_progress"
rc_in_progress=$?
set -e
assert_exit "S4 one in_progress numbered spec — VIOLATION (no done count)" 1 "$rc_in_progress"
assert_stderr_contains "S4 stderr cites Gate G085" "$stderr_in_progress" "G085"
assert_stderr_contains "S4 stderr lists in_progress spec" "$stderr_in_progress" "status=in_progress"

echo ""
echo "=== Regression verdict ==="
printf '  Total assertions: %d\n' "$((pass_count + fail_count))"
printf '  Passed:           %d\n' "$pass_count"
printf '  Failed:           %d\n' "$fail_count"
echo ""

if [[ "$fail_count" -gt 0 ]]; then
  echo "🔴 test_04_framework_dogfooding: REGRESSION FAILED" >&2
  echo "  Gate G085 contract has regressed. Inspect bubbles/scripts/framework-dogfood-guard.sh." >&2
  exit 1
fi

echo "🟢 test_04_framework_dogfooding: REGRESSION PASSED"
exit 0
