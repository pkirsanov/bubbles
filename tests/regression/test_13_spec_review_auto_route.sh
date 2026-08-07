#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-13 spec-review default + improve-existing auto-route.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/mode-resolver.sh" || -f "$REPO_ROOT/bubbles/scripts/mode-resolver.sh" ]]; then
  RESOLVER="$REPO_ROOT/bubbles/scripts/mode-resolver.sh"
  RESOLVER_SELFTEST="$REPO_ROOT/bubbles/scripts/mode-resolver-selftest.sh"
  HANDOFF_SELFTEST="$REPO_ROOT/bubbles/scripts/spec-review-handoff-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/mode-resolver.sh" || -f "$REPO_ROOT/.github/bubbles/scripts/mode-resolver.sh" ]]; then
  RESOLVER="$REPO_ROOT/.github/bubbles/scripts/mode-resolver.sh"
  RESOLVER_SELFTEST="$REPO_ROOT/.github/bubbles/scripts/mode-resolver-selftest.sh"
  HANDOFF_SELFTEST="$REPO_ROOT/.github/bubbles/scripts/spec-review-handoff-selftest.sh"
else
  echo "test_13_spec_review_auto_route: resolver not found from $REPO_ROOT" >&2
  exit 2
fi

WORKFLOWS_FILE="$REPO_ROOT/bubbles/workflows.yaml"
SPEC_REVIEW_AGENT="$REPO_ROOT/agents/bubbles.spec-review.agent.md"
WORKFLOW_AGENT="$REPO_ROOT/agents/bubbles.workflow.agent.md"
ORCHESTRATION_CORE="$REPO_ROOT/agents/bubbles_shared/workflow-orchestration-core.md"
INPUT_BOOTSTRAP="$REPO_ROOT/agents/bubbles_shared/workflow-input-bootstrap.md"

_regression_tmp_base="${TMPDIR:-$HOME/.cache}"
mkdir -p "$_regression_tmp_base"
# A template inside the base directory, not `-p`: the parent-directory flag is
# GNU-only and BSD mktemp rejects it. Every mktemp call below uses this form.
TMP_DIR="$(mktemp -d "$_regression_tmp_base/bubbles-spec-review-route.XXXXXX")"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

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

assert_yq() {
  local label="$1"
  local expr="$2"
  local file="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_resolved_yq() {
  local label="$1"
  local mode="$2"
  local expr="$3"
  local resolved_file
  resolved_file="$(mktemp "$TMP_DIR/resolved.XXXXXX")"
  set +e
  # v7 mode-collapse removed v5-name INPUT; these regression modes are persisted
  # names resolved programmatically, so grandfather them (per the resolver's own
  # remediation hint). Discard stderr (the deprecation notice) so the captured
  # file is pure resolved-mode YAML.
  BUBBLES_MODE_GRANDFATHER=1 "$RESOLVER" "$mode" > "$resolved_file" 2>/dev/null
  local rc=$?
  set -e
  if [[ "$rc" -ne 0 ]]; then
    fail "$label resolver-exit=$rc"
    rm -f "$resolved_file"
    return
  fi
  if yq -e "$expr" "$resolved_file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
  rm -f "$resolved_file"
}

assert_grep() {
  local label="$1"
  local pattern="$2"
  local file="$3"
  if grep -Eq "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

echo "=== test_13_spec_review_auto_route (SCOPE-13 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Resolver: $(display_path "$RESOLVER")"
echo "Resolver selftest: $(display_path "$RESOLVER_SELFTEST")"
echo "Handoff selftest: $(display_path "$HANDOFF_SELFTEST")"
echo "Workflows: $(display_path "$WORKFLOWS_FILE")"
echo "Spec-review agent: $(display_path "$SPEC_REVIEW_AGENT")"
echo "Workflow agent: $(display_path "$WORKFLOW_AGENT")"
echo "Orchestration core: $(display_path "$ORCHESTRATION_CORE")"
echo "Input bootstrap: $(display_path "$INPUT_BOOTSTRAP")"

echo ""
echo "--- S1/S2: resolver inheritance and explicit override semantics ---"
assert_yq "R1 delivery-quality-constraints defines specReviewDefault" '.modeTemplates."delivery-quality-constraints".constraints.specReviewDefault == "once-before-implement"' "$WORKFLOWS_FILE"
assert_yq "R2 delivery-quality-constraints records opt-out reason requirement" '.modeTemplates."delivery-quality-constraints".constraints.specReviewOptOutRequiresReason == true' "$WORKFLOWS_FILE"
assert_resolved_yq "R3 inherited delivery mode resolves specReviewDefault" "bugfix-fastlane" '.constraints.specReviewDefault == "once-before-implement"'
assert_resolved_yq "R4 explicit mode default on full-delivery remains once-before-implement" "full-delivery" '.constraints.specReviewDefault == "once-before-implement"'
assert_resolved_yq "R5 docs-only explicit non-delivery opt-out is machine-readable" "docs-only" '.constraints.specReviewDefault == "off" and .constraints.modeClass == "docs-only" and .constraints.planningTruthMutation == false'
assert_resolved_yq "R6 spec-review-to-doc remains read-only spec-review-only" "spec-review-to-doc" '.constraints.specReviewDefault == "off" and .constraints.modeClass == "spec-review-only" and .constraints.readOnlyAudit == true and .constraints.noCodeChanges == true'

echo ""
echo "--- S3/S4/S5: severe done-spec drift routes to improve-existing automatically ---"
run_check "R7 spec-review handoff selftest" bash "$HANDOFF_SELFTEST"
assert_grep "R8 spec-review agent maps MAJOR_DRIFT to improve-existing" 'MAJOR_DRIFT.*improve-existing|improve-existing.*MAJOR_DRIFT' "$SPEC_REVIEW_AGENT"
assert_grep "R9 spec-review agent maps OBSOLETE to improve-existing" 'OBSOLETE.*improve-existing|improve-existing.*OBSOLETE' "$SPEC_REVIEW_AGENT"
assert_grep "R10 workflow core auto-escalates like G033" 'G033|design_readiness' "$ORCHESTRATION_CORE"
assert_grep "R11 workflow core honors improve-existing dispatch" 'improve-existing' "$ORCHESTRATION_CORE"
assert_grep "R12 workflow agent honors spec-review improve-existing route" 'spec-review.*improve-existing|improve-existing.*spec-review' "$WORKFLOW_AGENT"
assert_grep "R13 input bootstrap owns severe drift route" 'MAJOR_DRIFT.*OBSOLETE.*improve-existing|improve-existing.*MAJOR_DRIFT.*OBSOLETE' "$INPUT_BOOTSTRAP"

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_13_spec_review_auto_route: FAILED" >&2
  exit 1
fi

echo "test_13_spec_review_auto_route: PASSED"
exit 0
