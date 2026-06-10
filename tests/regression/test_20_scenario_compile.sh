#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for the Goal Scenario Compiler lint
# (bubbles/scripts/scenario-compile-lint.sh). Asserts the lint BLOCKS the
# load-bearing violations (a node resolving to a requiresTopLevelRuntime fan-out
# mode — the Gate G064 depth violation — and an ungated action node) while
# PASSING a clean cross-repo DAG. This is a second line of defense beyond the
# framework-validate-wired hermetic selftest.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LINT="$REPO_ROOT/bubbles/scripts/scenario-compile-lint.sh"

if [[ ! -x "$LINT" ]]; then
  echo "test_20_scenario_compile: lint not executable: $LINT" >&2
  exit 2
fi
command -v jq >/dev/null 2>&1 || { echo "test_20_scenario_compile: jq required" >&2; exit 2; }

WORKSPACE="$(mktemp -d -t bubbles-scenario-regression-XXXXXXXX)"
trap 'rm -rf "$WORKSPACE"' EXIT INT TERM
F="$WORKSPACE/scenario.json"

pass_count=0
fail_count=0

assert_exit() {
  local description="$1" expected="$2" actual="$3"
  if [[ "$actual" -eq "$expected" ]]; then
    pass_count=$((pass_count + 1))
    printf '  PASS: %s (exit=%s)\n' "$description" "$actual"
  else
    fail_count=$((fail_count + 1))
    printf '  FAIL: %s (expected=%s actual=%s)\n' "$description" "$expected" "$actual"
  fi
}

run_lint() {
  local rc=0
  "$LINT" "$F" "$REPO_ROOT" >/dev/null 2>&1 || rc=$?
  echo "$rc"
}

write_clean() {
  cat > "$F" <<'JSON'
{
  "version": 1,
  "scenarioId": "regression-mvp-target-readiness",
  "rootOutcome": {
    "intent": "Product is live and operable on the target environment",
    "successSignal": "Service health endpoint green on the target after deploy",
    "hardConstraints": ["local-target build, not cloud"],
    "failureCondition": "Any node blocked or health check red after deploy"
  },
  "repos": [
    {"id": "product", "role": "product"},
    {"id": "adapter", "role": "deployment-adapter"}
  ],
  "nodes": [
    {"id": "readiness", "type": "diagnostic", "repo": "product", "agent": "bubbles.system-review"},
    {"id": "plan", "type": "planning", "repo": "product", "mode": "product-to-planning", "dependsOn": ["readiness"]},
    {"id": "deliver", "type": "delivery", "repo": "product", "mode": "full-delivery", "dependsOn": ["plan"]},
    {"id": "verify", "type": "verification", "repo": "product", "mode": "validate-only", "dependsOn": ["deliver"]},
    {"id": "deploy", "type": "action", "repo": "adapter", "mode": "devops-to-doc", "opsPacket": "specs/_ops/OPS-deploy", "approvalRequired": true, "riskClass": "external_side_effect", "dependsOn": ["verify"]}
  ]
}
JSON
}

echo "=== Regression: Goal Scenario Compiler lint (Gate G064 depth + action gating) ==="

# Clean DAG passes.
write_clean
assert_exit "clean cross-repo scenario DAG passes" 0 "$(run_lint)"

# Fan-out mode as a node is blocked (depth violation).
write_clean
jq '(.nodes[] | select(.id=="deliver") | .mode) = "autonomous-goal"' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
assert_exit "fan-out node (autonomous-goal) blocked" 1 "$(run_lint)"

write_clean
jq '(.nodes[] | select(.id=="deliver") | .mode) = "iterate"' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
assert_exit "fan-out node (iterate) blocked" 1 "$(run_lint)"

# Ungated action node is blocked.
write_clean
jq '(.nodes[] | select(.id=="deploy")) |= del(.approvalRequired)' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
assert_exit "ungated action node (no approval) blocked" 1 "$(run_lint)"

# Cyclic dependsOn is blocked.
write_clean
jq '(.nodes[] | select(.id=="plan") | .dependsOn) = ["deliver"]' "$F" > "$F.tmp" && mv "$F.tmp" "$F"
assert_exit "cyclic dependsOn blocked" 1 "$(run_lint)"

echo "--- $pass_count passed, $fail_count failed ---"
[[ "$fail_count" -eq 0 ]] || exit 1
echo "test_20_scenario_compile: OK"
