#!/usr/bin/env bash
# tests/regression/test_04_framework_dogfooding.sh
#
# Persistent production-guard regression for Gate G085.
#
# This regression is intentionally smaller than the exhaustive in-tree
# selftest. It preserves source behavior and the current-done fast path, then
# proves the bug with an adversarial pair whose current states are identical:
# clean full history passes first adoption, while reachable prior done history
# fails. An effective shallow clone proves incomplete history never passes.
#
# Exit codes asserted:
#   0 → source-clean, current-done, or proven first-adoption evidence
#   1 → source specs/ violation or reachable historical done evidence
#   2 → incomplete history or untrusted current state input
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
WORKSPACE="$(mktemp -d -t bubbles-g085-regression-XXXXXXXX)"

cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
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

assert_stdout_contains() {
  local description="$1"
  local stdout_file="$2"
  local needle="$3"
  if grep -qF "$needle" "$stdout_file"; then
    pass_count=$((pass_count + 1))
    printf '  ✅ PASS: %s\n' "$description"
  else
    fail_count=$((fail_count + 1))
    printf '  ❌ FAIL: %s (stdout missing %q)\n' "$description" "$needle"
    sed 's/^/      /' "$stdout_file" >&2
  fi
}

assert_files_equal() {
  local description="$1"
  local first_file="$2"
  local second_file="$3"
  if cmp -s "$first_file" "$second_file"; then
    pass_count=$((pass_count + 1))
    printf '  ✅ PASS: %s\n' "$description"
  else
    fail_count=$((fail_count + 1))
    printf '  ❌ FAIL: %s\n' "$description"
  fi
}

# Stage a hermetic mktemp downstream/fixture repo root.
stage_repo() {
  local workspace
  workspace="$(mktemp -d "$WORKSPACE/repo-XXXXXXXX")"
  mkdir -p "$workspace/.specify/memory"
  mkdir -p "$workspace/specs"
  printf '%s' "$workspace"
}

stage_source_repo() {
  local workspace
  workspace="$(mktemp -d "$WORKSPACE/source-XXXXXXXX")"
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
  printf '%s' "$workspace"
}

init_git_repo() {
  local repo="$1"
  git -C "$repo" init -q
  git -C "$repo" config user.name "Bubbles G085 Regression"
  git -C "$repo" config user.email "g085-regression@example.invalid"
}

commit_all() {
  local repo="$1"
  local message="$2"
  git -C "$repo" add .
  git -C "$repo" commit -q -m "$message"
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
# Scenario S3: CURRENT DONE FAST PATH — no Git metadata is required.
# ---------------------------------------------------------------------------
ws_done="$(stage_repo)"
write_state "$ws_done/specs/001-foo/state.json" "done"
stdout_done="$ws_done/stdout.log"
set +e
bash "$GUARD" --repo-root "$ws_done" --quiet > "$stdout_done" 2>&1
rc_done=$?
set -e
assert_exit "S3 exactly one downstream done numbered spec — PASS" 0 "$rc_done"
assert_stdout_contains "S3 current-done decision code" "$stdout_done" "decisionCode=G085-CURRENT-DONE"

# ---------------------------------------------------------------------------
# Scenario S3B: EXTERNAL DONE SYMLINK — a numbered state.json symlink cannot
# import current-done evidence from outside the repository. MUST FAIL exit 2.
# ---------------------------------------------------------------------------
ws_symlink="$(stage_repo)"
external_done="$WORKSPACE/external-done.json"
write_state "$external_done" "done"
mkdir -p "$ws_symlink/specs/001-linked"
ln -s "$external_done" "$ws_symlink/specs/001-linked/state.json"
stderr_symlink="$ws_symlink/stderr.log"
set +e
bash "$GUARD" --repo-root "$ws_symlink" --quiet > /dev/null 2> "$stderr_symlink"
rc_symlink=$?
set -e
assert_exit "S3B external current-state symlink — INTEGRITY FAILURE" 2 "$rc_symlink"
assert_stderr_contains "S3B current-state integrity failure code" "$stderr_symlink" "failureCode=E085-CURRENT-STATE-MALFORMED"
assert_stderr_contains "S3B symlink diagnostic" "$stderr_symlink" "current numbered state.json files must be regular non-symbolic-link files"

# ---------------------------------------------------------------------------
# Scenario S4: GENUINE FIRST ADOPTION — full history contains only a current
# nonterminal numbered state. MUST PASS exit 0 with complete-history evidence.
# ---------------------------------------------------------------------------
ws_first_adoption="$(stage_repo)"
init_git_repo "$ws_first_adoption"
write_state "$ws_first_adoption/specs/001-foo/state.json" "in_progress"
commit_all "$ws_first_adoption" "first feature in progress"
stdout_first_adoption="$ws_first_adoption/stdout.log"
set +e
bash "$GUARD" --repo-root "$ws_first_adoption" --quiet > "$stdout_first_adoption" 2>&1
rc_first_adoption=$?
set -e
assert_exit "S4 genuine first adoption — PASS" 0 "$rc_first_adoption"
assert_stdout_contains "S4 first-adoption decision code" "$stdout_first_adoption" "decisionCode=G085-FIRST-ADOPTION"
assert_stdout_contains "S4 proves complete history" "$stdout_first_adoption" "historyIntegrity=complete"

# ---------------------------------------------------------------------------
# Scenario S5: IDENTICAL CURRENT STATE, REACHABLE PRIOR DONE — current state is
# byte-identical to S4, but history first committed status done. MUST FAIL 1.
# ---------------------------------------------------------------------------
ws_historical_done="$(stage_repo)"
init_git_repo "$ws_historical_done"
write_state "$ws_historical_done/specs/001-foo/state.json" "done"
commit_all "$ws_historical_done" "historical done feature"
write_state "$ws_historical_done/specs/001-foo/state.json" "in_progress"
commit_all "$ws_historical_done" "same current nonterminal state"
assert_files_equal "S5 adversarial repositories have identical current states" \
  "$ws_first_adoption/specs/001-foo/state.json" \
  "$ws_historical_done/specs/001-foo/state.json"
stderr_historical_done="$ws_historical_done/stderr.log"
set +e
bash "$GUARD" --repo-root "$ws_historical_done" --quiet > /dev/null 2> "$stderr_historical_done"
rc_historical_done=$?
set -e
assert_exit "S5 reachable historical done — VIOLATION" 1 "$rc_historical_done"
assert_stderr_contains "S5 historical-done failure code" "$stderr_historical_done" "failureCode=E085-ESTABLISHED-DONE-REMOVED"
assert_stderr_contains "S5 historical state path" "$stderr_historical_done" "historyPath=specs/001-foo/state.json"

# ---------------------------------------------------------------------------
# Scenario S6: EFFECTIVE SHALLOW HISTORY — depth-1 file:// clone hides the
# earlier done commit. The fixture must be genuinely shallow and MUST FAIL 2.
# ---------------------------------------------------------------------------
ws_shallow_source="$(stage_repo)"
init_git_repo "$ws_shallow_source"
write_state "$ws_shallow_source/specs/001-foo/state.json" "done"
commit_all "$ws_shallow_source" "historical done feature"
write_state "$ws_shallow_source/specs/001-foo/state.json" "in_progress"
commit_all "$ws_shallow_source" "current nonterminal feature"
ws_shallow="$WORKSPACE/shallow"
git clone -q --depth 1 "file://$ws_shallow_source" "$ws_shallow"
shallow_state="$(git -C "$ws_shallow" rev-parse --is-shallow-repository)"
if [[ "$shallow_state" == "true" ]]; then
  pass_count=$((pass_count + 1))
  printf '  ✅ PASS: S6 shallow fixture setup is effective\n'
else
  fail_count=$((fail_count + 1))
  printf '  ❌ FAIL: S6 shallow fixture setup expected true, actual=%s\n' "$shallow_state"
fi
stderr_shallow="$ws_shallow/stderr.log"
set +e
bash "$GUARD" --repo-root "$ws_shallow" --quiet > /dev/null 2> "$stderr_shallow"
rc_shallow=$?
set -e
assert_exit "S6 shallow history — INTEGRITY FAILURE" 2 "$rc_shallow"
assert_stderr_contains "S6 shallow-history failure code" "$stderr_shallow" "failureCode=E085-HISTORY-SHALLOW"

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
