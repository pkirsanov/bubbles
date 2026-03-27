#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD_SCRIPT="$SCRIPT_DIR/state-transition-guard.sh"
OWNERSHIP_LINT_SCRIPT="$SCRIPT_DIR/agent-ownership-lint.sh"

tmp_root="$(mktemp -d)"
failures=0

cleanup() {
  if [[ "$failures" -eq 0 ]] && [[ "${KEEP_SELFTEST_TMP:-0}" != "1" ]]; then
    rm -rf "$tmp_root"
  else
    echo "Preserving selftest workspace: $tmp_root"
  fi
}

trap cleanup EXIT

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

run_capture() {
  local log_file="$1"
  shift

  set +e
  "$@" >"$log_file" 2>&1
  local status=$?
  set -e

  echo "$status"
}

clone_framework_surface() {
  local destination_root="$1"

  mkdir -p "$destination_root"
  cp -R "$SCRIPT_DIR/.." "$destination_root/bubbles"
  cp -R "$SCRIPT_DIR/../../agents" "$destination_root/agents"
}

inject_illegal_child_workflow_caller() {
  local capabilities_file="$1"
  local tmp_file
  tmp_file="$(mktemp)"

  awk '
    BEGIN { inserted=0 }
    /^  bubbles\.implement:$/ {
      print
      in_block=1
      next
    }
    in_block && /^    class: execution-owner$/ {
      print
      print "    canInvokeChildWorkflows: true"
      inserted=1
      in_block=0
      next
    }
    { print }
    END {
      if (inserted == 0) {
        exit 1
      }
    }
  ' "$capabilities_file" > "$tmp_file"

  mv "$tmp_file" "$capabilities_file"
}

assert_log_contains() {
  local log_file="$1"
  local needle="$2"
  local label="$3"

  if grep -Fq "$needle" "$log_file"; then
    pass "$label"
  else
    fail "$label"
    echo "--- log excerpt: $log_file ---"
    sed -n '1,160p' "$log_file"
    echo "--- end log excerpt ---"
  fi
}

emit_base_fixture() {
  local feature_dir="$1"
  local scenario_test="$feature_dir/tests/docs-scenario-regression.e2e.spec.ts"
  local broader_test="$feature_dir/tests/docs-broader-regression.e2e.spec.ts"

  mkdir -p "$feature_dir/tests"

  cat <<'EOF' > "$scenario_test"
export const docsScenarioRegression = true;
EOF

  cat <<'EOF' > "$broader_test"
export const docsBroaderRegression = true;
EOF

  cat <<'EOF' > "$feature_dir/spec.md"
# Guard Selftest Spec

## Purpose

Exercise the docs-only promotion path with a minimal but coherent artifact set.
EOF

  cat <<'EOF' > "$feature_dir/design.md"
# Guard Selftest Design

## Approach

Use a docs-only workflow mode so the transition guard still evaluates state integrity, artifact integrity, and routing contracts without requiring implementation-heavy runtime proof.
EOF

  cat <<'EOF' > "$feature_dir/uservalidation.md"
# User Validation

## Checklist

- [x] Baseline docs-only validation path is available for the selftest fixture.
EOF

  cat <<'EOF' > "$feature_dir/scopes.md"
# Scope 01: Docs-Only Guard Fixture

**Status:** Done

### Goal

Keep the fixture small while still exercising the real transition guard against a coherent docs-only feature directory.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-ui` | `__SCENARIO_TEST__` | Scenario-specific regression row required by the guard. | `selftest:scenario-regression` | Yes |
| Regression E2E | `e2e-ui` | `__BROADER_TEST__` | Broader regression row required by the guard. | `selftest:broader-regression` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is recorded consistently across artifacts -> Evidence: report.md#summary
EOF

  sed -i "s|__SCENARIO_TEST__|$scenario_test|g" "$feature_dir/scopes.md"
  sed -i "s|__BROADER_TEST__|$broader_test|g" "$feature_dir/scopes.md"

  cat <<'EOF' > "$feature_dir/report.md"
# Report

### Summary

Docs-only transition-guard selftest fixture.

### Completion Statement

The temporary fixture is shaped to satisfy the docs-only promotion ceiling while still exercising the guard's state, artifact, and routing checks.

### Test Evidence

```text
$ bash bubbles/scripts/agent-ownership-lint.sh
Agent ownership lint passed.
$ ls -la __FEATURE_DIR__/tests
total 16
drwxr-xr-x 2 selftest selftest 4096 Mar 27 00:00 .
drwxr-xr-x 3 selftest selftest 4096 Mar 27 00:00 ..
-rw-r--r-- 1 selftest selftest   41 Mar 27 00:00 docs-broader-regression.e2e.spec.ts
-rw-r--r-- 1 selftest selftest   42 Mar 27 00:00 docs-scenario-regression.e2e.spec.ts
```
EOF

  sed -i "s|__FEATURE_DIR__|$feature_dir|g" "$feature_dir/report.md"

  cat <<'EOF' > "$feature_dir/state.json"
{
  "version": 3,
  "status": "docs_updated",
  "workflowMode": "docs-only",
  "execution": {
    "completedPhaseClaims": ["docs"]
  },
  "certification": {
    "certifiedCompletedPhases": ["docs"],
    "completedScopes": ["01-docs-guard-fixture"],
    "scopeProgress": [],
    "lockdownState": {
      "mode": "off",
      "lockedScenarioIds": []
    },
    "status": "docs_updated"
  },
  "policySnapshot": {
    "grill": { "mode": "off", "source": "repo-default" },
    "tdd": { "mode": "off", "source": "repo-default" },
    "autoCommit": { "mode": "off", "source": "repo-default" },
    "lockdown": { "mode": "off", "source": "repo-default" },
    "regression": { "mode": "protect-existing-scenarios", "source": "repo-default" },
    "validation": { "mode": "required", "source": "workflow-forced" }
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": [
    {
      "phase": "docs",
      "completedAt": "2026-03-27T10:00:07Z"
    }
  ],
  "lastUpdatedAt": "2026-03-27T10:00:09Z"
}
EOF
}

positive_feature_dir="$tmp_root/specs/900-transition-guard-selftest-pass"
negative_feature_dir="$tmp_root/specs/901-transition-guard-selftest-missing-owner"
g064_framework_root="$tmp_root/framework-g064"
g064_feature_dir="$g064_framework_root/specs/902-transition-guard-selftest-illegal-child-workflow"
mkdir -p "$tmp_root/specs"

emit_base_fixture "$positive_feature_dir"
cp -R "$positive_feature_dir" "$negative_feature_dir"
clone_framework_surface "$g064_framework_root"
mkdir -p "$g064_framework_root/specs"
emit_base_fixture "$g064_feature_dir"
inject_illegal_child_workflow_caller "$g064_framework_root/bubbles/agent-capabilities.yaml"

cat <<'EOF' > "$negative_feature_dir/rework-queue.json"
[
  {
    "reworkId": "RW-901-001",
    "status": "closed",
    "reason": "Concrete packet fields must remain present even after closure.",
    "dodItems": ["DOD-01-01"]
  }
]
EOF

echo "Running agent ownership lint precheck..."
lint_log="$tmp_root/agent-ownership-lint.log"
lint_status="$(run_capture "$lint_log" bash "$OWNERSHIP_LINT_SCRIPT")"
if [[ "$lint_status" -eq 0 ]]; then
  pass "Agent ownership lint precheck passes"
else
  fail "Agent ownership lint precheck failed"
  sed -n '1,160p' "$lint_log"
fi

echo "Running positive transition-guard selftest..."
positive_log="$tmp_root/positive-guard.log"
positive_status="$(run_capture "$positive_log" bash "$GUARD_SCRIPT" "$positive_feature_dir")"
if [[ "$positive_status" -eq 0 ]]; then
  pass "Docs-only positive fixture passes the transition guard"
else
  fail "Docs-only positive fixture should pass the transition guard"
  sed -n '1,220p' "$positive_log"
  echo "--- artifact-lint output for positive fixture ---"
  set +e
  bash "$SCRIPT_DIR/artifact-lint.sh" "$positive_feature_dir"
  set -e
  echo "--- end artifact-lint output ---"
fi
assert_log_contains "$positive_log" "Framework ownership lint passed" "Positive fixture exercises guard Check 3G"
assert_log_contains "$positive_log" "TRANSITION PERMITTED" "Positive fixture reaches a permitted transition verdict"

echo "Running negative packet-field selftest..."
negative_log="$tmp_root/negative-guard.log"
negative_status="$(run_capture "$negative_log" bash "$GUARD_SCRIPT" "$negative_feature_dir")"
if [[ "$negative_status" -ne 0 ]]; then
  pass "Negative fixture fails the transition guard as expected"
else
  fail "Negative fixture should fail the transition guard"
  sed -n '1,220p' "$negative_log"
fi
assert_log_contains "$negative_log" "missing a concrete owning specialist" "Negative fixture triggers the concrete owner packet check"
assert_log_contains "$negative_log" "Gate G063" "Negative fixture reports the new concrete-result gate"

echo "Running negative child-workflow-policy selftest..."
g064_log="$tmp_root/g064-guard.log"
g064_status="$(run_capture "$g064_log" bash "$g064_framework_root/bubbles/scripts/state-transition-guard.sh" "$g064_feature_dir")"
if [[ "$g064_status" -ne 0 ]]; then
  pass "Illegal child-workflow caller fixture fails the transition guard as expected"
else
  fail "Illegal child-workflow caller fixture should fail the transition guard"
  sed -n '1,220p' "$g064_log"
fi
assert_log_contains "$g064_log" "only orchestrators may enable child workflows" "Negative fixture triggers the G064 orchestrator-only child-workflow check"
assert_log_contains "$g064_log" "G062/G063/G064 cannot be certified" "Negative fixture surfaces the framework contract failure through guard Check 3G"

echo "----------------------------------------"
if [[ "$failures" -gt 0 ]]; then
  echo "state-transition-guard selftest failed with $failures issue(s)."
  exit 1
fi

echo "state-transition-guard selftest passed."