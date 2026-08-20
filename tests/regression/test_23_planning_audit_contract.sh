#!/usr/bin/env bash
set -euo pipefail

# BUG-009 planning audit and validate/finalize contract.
#
# This persistent regression stages an honest product-to-planning packet and
# executes the canonical transition guard through both its direct boundary and
# the Audit 0-pre/A1 contract. Before the production fix, the script exits 1
# only when the observed discriminator is the unconditional completion behavior
# in Checks 4, 5, 8, and 11 while planning gates remain clean.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/state-transition-guard.sh"
GUARD_LIB="$REPO_ROOT/bubbles/scripts/guard-lib.sh"
ARTIFACT_LINT="$REPO_ROOT/bubbles/scripts/artifact-lint.sh"
MODE_RESOLVER="$REPO_ROOT/bubbles/scripts/mode-resolver.sh"
TRANSITION_RESOLVER="$REPO_ROOT/bubbles/scripts/transition-contract-resolver.sh"
AUDIT_RESULT_LINT="$REPO_ROOT/bubbles/scripts/audit-result-contract-lint.sh"
AUDIT_AGENT="$REPO_ROOT/agents/bubbles.audit.agent.md"
VALIDATE_AGENT="$REPO_ROOT/agents/bubbles.validate.agent.md"
VALIDATION_PROFILES="$REPO_ROOT/agents/bubbles_shared/validation-profiles.md"
SCOPE_WORKFLOW="$REPO_ROOT/agents/bubbles_shared/scope-workflow.md"
PHASE_ENGINE="$REPO_ROOT/agents/bubbles_shared/workflow-phase-engine.md"
FEATURE_TEMPLATES="$REPO_ROOT/agents/bubbles_shared/feature-templates.md"
SCOPE_TEMPLATES="$REPO_ROOT/agents/bubbles_shared/scope-templates.md"

for required_file in "$GUARD" "$GUARD_LIB" "$ARTIFACT_LINT" "$MODE_RESOLVER" "$TRANSITION_RESOLVER" "$AUDIT_RESULT_LINT" "$AUDIT_AGENT" "$VALIDATE_AGENT" "$VALIDATION_PROFILES" "$SCOPE_WORKFLOW" "$PHASE_ENGINE" "$FEATURE_TEMPLATES" "$SCOPE_TEMPLATES"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'test_23_planning_audit_contract: required canonical surface missing: %s\n' "$required_file" >&2
    exit 2
  fi
done

# shellcheck source=/dev/null
source "$GUARD_LIB"

selftest_tmp_base="${TMPDIR:-$HOME/.cache}"
mkdir -p "$selftest_tmp_base"
WORKSPACE="$(mktemp -d "$selftest_tmp_base/bubbles-bug009-s03-XXXXXXXX")"
FIXTURE_REPO="$WORKSPACE/repo"
FIXTURE_ROOT="$FIXTURE_REPO/tests/fixtures"
mkdir -p "$FIXTURE_ROOT"
# shellcheck disable=SC2329
cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

assert_contains() {
  local file="$1"
  local expected="$2"
  local label="$3"

  if grep -Fq -- "$expected" "$file"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_not_contains() {
  local file="$1"
  local forbidden="$2"
  local label="$3"

  if grep -Fq -- "$forbidden" "$file"; then
    fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

write_honest_planning_fixture() {
  local feature_dir="$1"
  local future_test="$feature_dir/tests/regression/planning_contract_future_test.sh"

  mkdir -p "$feature_dir"

  cat <<'EOF' > "$feature_dir/spec.md"
# BUG-009 Planning Audit Contract Fixture

## Problem

A planning-only workflow must be able to certify planning maturity without
claiming that implementation work, delivery tests, or execution evidence exist.

## Release Train

This framework-source fixture targets the canonical planning workflow and does
not introduce a product release-train flag.

## User Scenarios & Testing

### SCN-009-S01-001 — Honest planning maturity

```gherkin
Scenario: Honest planning maturity
Given a product-to-planning packet at specs_hardened
And its implementation scope and delivery evidence are honestly incomplete
When the canonical planning audit evaluates the packet
Then planning maturity is evaluated without a delivery-completion claim
```

## Requirements

- **FR-009-001:** The planning contract must retain honest incomplete delivery state.
- **FR-009-002:** The real transition guard must remain the audit preflight boundary.
EOF

  cat <<'EOF' > "$feature_dir/design.md"
# BUG-009 Planning Audit Contract Design Fixture

## Approach

Use one temporary downstream-like packet and invoke the canonical source guard.
The fixture records planning truth only and contains no implementation artifact.

## Change Boundary

The planned implementation is represented by one concrete absent regression
path. No production framework or downstream product file belongs to this fixture.

## Consumer Impact Sweep

The contract changes no route, identifier, command, or downstream consumer.

## Shared Infrastructure Impact Sweep

No shared service, persistent store, deployment adapter, or telemetry endpoint
is introduced or changed.
EOF

  cat <<'EOF' > "$feature_dir/uservalidation.md"
# User Validation

## Checklist

- [x] The planning packet distinguishes planning maturity from delivery completion.
- [x] The operator-visible target is exactly specs_hardened.
EOF

  cat <<'EOF' > "$feature_dir/scopes.md"
# Scope 01: Honest Planning Contract

**Status:** Not Started

## Goal

Plan the future implementation contract without claiming implementation or test execution.

## Gherkin Scenarios

### SCN-009-S01-001 — Honest planning maturity

```gherkin
Scenario: Honest planning maturity
Given a product-to-planning packet at specs_hardened
And its implementation scope and delivery evidence are honestly incomplete
When the canonical planning audit evaluates the packet
Then planning maturity is evaluated without a delivery-completion claim
```

## Implementation Plan

1. Implement the registry-bound planning audit behavior in its separately owned scope.
2. Execute the persistent regression after the production behavior exists.

## Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e` | `__FUTURE_TEST__` | Regression: exercise SCN-009-S01-001 through the canonical guard and audit contract. | `bash __FUTURE_TEST__` | No |
| Broader regression | `regression` | `__FUTURE_TEST__` | Keep the planning/delivery distinction persistent in canonical validation. | `bash __FUTURE_TEST__` | No |

### Definition of Done

- [ ] Honest planning maturity is evaluated without a delivery-completion claim for SCN-009-S01-001.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior protect SCN-009-S01-001.
- [ ] Broader E2E regression suite passes with the planning contract enabled.
EOF
  bubbles_sed_inplace "s|__FUTURE_TEST__|$future_test|g" "$feature_dir/scopes.md"

  cat <<'EOF' > "$feature_dir/report.md"
# Report

### Summary

This is the report for a canonical Not Started implementation scope.

### Completion Statement

No delivery completion is claimed at the specs_hardened planning ceiling.

### Test Evidence

Execution-evidence code blocks: zero. This is the declared honesty state for
the unimplemented scope.

### Code Diff Evidence

No delivery implementation delta is claimed by this planning-only fixture.

### Scope Evidence

Scope 01 remains Not Started with every implementation DoD item unchecked.

### Validation Evidence

Validation records planning maturity only and records no delivery audit claim.

### Audit Evidence

No positive audit or delivery certification is claimed.
EOF

  cat <<'EOF' > "$feature_dir/scenario-manifest.json"
{
  "version": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-009-S01-001",
      "title": "Honest planning maturity",
      "status": "planned",
      "scope": "Scope 01",
      "requirements": ["FR-009-001", "FR-009-002"],
      "requiredTestType": "e2e",
      "linkedTests": ["__FUTURE_TEST__"],
      "evidenceRefs": []
    }
  ]
}
EOF
  bubbles_sed_inplace "s|__FUTURE_TEST__|$future_test|g" "$feature_dir/scenario-manifest.json"

  cat <<'EOF' > "$feature_dir/state.json"
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "product-to-planning",
  "planningOnly": true,
  "planMaturityOnly": true,
  "planningOnlyJustification": "The fixture certifies planning maturity without implementation or delivery claims.",
  "execution": {
    "currentScope": null,
    "currentPhase": "bootstrap",
    "completedPhaseClaims": ["analyze", "bootstrap"],
    "pendingTransitionRequests": [],
    "audit": {
      "schemaVersion": "audit-run/v1",
      "runId": null,
      "currentAttemptId": null,
      "attempts": []
    }
  },
  "certification": {
    "status": "in_progress",
    "certifiedCompletedPhases": ["analyze", "bootstrap"],
    "completedScopes": [],
    "scopeProgress": [
      {
        "scopeId": "S01",
        "scopeName": "Honest Planning Contract",
        "status": "not_started"
      }
    ],
    "lockdownState": {
      "mode": "off",
      "lockedScenarioIds": []
    }
  },
  "policySnapshot": {
    "grill": { "mode": "off", "source": "repo-default" },
    "tdd": { "mode": "off", "source": "repo-default" },
    "autoCommit": { "mode": "off", "source": "repo-default" },
    "lockdown": { "mode": "off", "source": "repo-default" },
    "regression": { "mode": "protect-existing-scenarios", "source": "repo-default" },
    "validation": { "mode": "required", "source": "workflow-forced" },
    "workflowMode": "product-to-planning"
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": [
    {
      "phase": "analyze",
      "agent": "bubbles.analyst",
      "phasesExecuted": ["analyze"],
      "outcome": "completed_diagnostic",
      "startedAt": "2026-07-10T10:00:00Z",
      "completedAt": "2026-07-10T10:01:13Z"
    },
    {
      "phase": "analyze",
      "agent": "bubbles.ux",
      "phasesExecuted": ["analyze"],
      "outcome": "completed_diagnostic",
      "startedAt": "2026-07-10T10:02:01Z",
      "completedAt": "2026-07-10T10:04:29Z"
    },
    {
      "phase": "bootstrap",
      "agent": "bubbles.design",
      "phasesExecuted": ["bootstrap"],
      "outcome": "completed_diagnostic",
      "startedAt": "2026-07-10T10:05:17Z",
      "completedAt": "2026-07-10T10:08:52Z"
    },
    {
      "phase": "bootstrap",
      "agent": "bubbles.plan",
      "phasesExecuted": ["bootstrap"],
      "outcome": "completed_diagnostic",
      "startedAt": "2026-07-10T10:09:31Z",
      "completedAt": "2026-07-10T10:14:47Z"
    }
  ],
  "lastUpdatedAt": "2026-07-10T10:15:03Z"
}
EOF
}

fixture_is_honest() {
  local feature_dir="$1"
  local future_test="$feature_dir/tests/regression/planning_contract_future_test.sh"
  local scope_file="$feature_dir/scopes.md"
  local report_file="$feature_dir/report.md"

  [[ ! -e "$future_test" ]] || return 1
  grep -Fq '**Status:** Not Started' "$scope_file" || return 1
  grep -Eq '^- \[ \] ' "$scope_file" || return 1
  if grep -Eq '^- \[[xX]\] ' "$scope_file"; then
    return 1
  fi
  grep -Fq '### Summary' "$report_file" || return 1
  grep -Fq '### Completion Statement' "$report_file" || return 1
  grep -Fq '### Test Evidence' "$report_file" || return 1
  if grep -Eq '^```' "$report_file"; then
    return 1
  fi
}

assert_integrity_adversary_rejected() {
  local name="$1"
  local mutation="$2"
  local honest_fixture="$3"
  local adversary="$WORKSPACE/adversary-$name"
  local future_test="$adversary/tests/regression/planning_contract_future_test.sh"

  cp -R "$honest_fixture" "$adversary"
  case "$mutation" in
    fake-test)
      mkdir -p "$(dirname "$future_test")"
      printf '%s\n' '# synthetic completion artifact forbidden by BUG-009 S01' > "$future_test"
      ;;
    fake-evidence)
      cat <<'EOF' >> "$adversary/report.md"

```text
synthetic execution evidence forbidden by BUG-009 S01
```
EOF
      ;;
    done-status)
      bubbles_sed_inplace 's/\*\*Status:\*\* Not Started/**Status:** Done/' "$adversary/scopes.md"
      ;;
    checked-dod)
      bubbles_sed_inplace 's/^- \[ \] /- [x] /' "$adversary/scopes.md"
      ;;
    *)
      fail "unknown integrity adversary: $mutation"
      return
      ;;
  esac

  if fixture_is_honest "$adversary"; then
    fail "integrity adversary '$name' was accepted"
  else
    pass "integrity adversary '$name' is rejected"
  fi
}

extract_audit_guard_path() {
  awk '
    /^### 0-pre\. State Transition Guard/ { in_section=1; next }
    in_section && /^```bash$/ { in_code=1; next }
    in_code && /^```$/ { exit }
    in_code && /state-transition-guard\.sh/ { print $2; exit }
  ' "$AUDIT_AGENT"
}

assert_a1_contract_uses_guard_verdict() {
  awk -F '|' '
    $2 ~ /^[[:space:]]*A1[[:space:]]*$/ &&
    $3 ~ /Profile-scoped state transition guard passes/ &&
    $4 ~ /registry-resolved profile/ { found=1 }
    END { exit(found ? 0 : 1) }
  ' "$VALIDATION_PROFILES"
}

assert_planning_mode_does_not_require_tdd() {
  local resolved_mode="$WORKSPACE/product-to-planning.resolved.yaml"
  local status_ceiling=""
  local force_tdd_mode=""

  if ! BUBBLES_MODE_GRANDFATHER=1 bash "$MODE_RESOLVER" product-to-planning > "$resolved_mode" 2>/dev/null; then
    return 1
  fi
  status_ceiling="$(yq eval -r '.statusCeiling // ""' "$resolved_mode")"
  force_tdd_mode="$(yq eval -r '.constraints.forceTddMode // ""' "$resolved_mode")"
  [[ "$status_ceiling" == "specs_hardened" ]] || return 1
  [[ "$force_tdd_mode" != "scenario-first" ]] || return 1
  if yq eval -r '.requiredGates[]' "$resolved_mode" 2>/dev/null | grep -Fxq 'G060'; then
    return 1
  fi
}

run_guard_surface() {
  local label="$1"
  local guard_path="$2"
  local feature_dir="$3"
  local output_file="$4"
  local invocation_log="$5"
  local exit_code

  printf '%s|%s|%s\n' "$label" "$guard_path" "$feature_dir" >> "$invocation_log"
  set +e
  bash "$guard_path" "$feature_dir" > "$output_file" 2>&1
  exit_code=$?
  set -e
  printf '%s' "$exit_code"
}

run_asserted_audit_guard_surface() {
  local guard_path="$1"
  local feature_dir="$2"
  local contract_file="$3"
  local output_file="$4"
  local invocation_log="$5"
  local workflow_mode
  local target_status
  local contract_digest
  local exit_code

  workflow_mode="$(jq -r '.workflowMode' "$contract_file")"
  target_status="$(jq -r '.targetStatus' "$contract_file")"
  contract_digest="$(jq -r '.contractDigest' "$contract_file")"
  printf '%s|%s|%s|--target-status|%s|--expect-workflow-mode|%s|--expect-contract-digest|%s\n' \
    audit-0-pre-a1 "$guard_path" "$feature_dir" "$target_status" "$workflow_mode" "$contract_digest" >> "$invocation_log"
  set +e
  bash "$guard_path" "$feature_dir" \
    --target-status "$target_status" \
    --expect-workflow-mode "$workflow_mode" \
    --expect-contract-digest "$contract_digest" > "$output_file" 2>&1
  exit_code=$?
  set -e
  printf '%s' "$exit_code"
}

transition_result_field() {
  local result_file="$1"
  local field="$2"
  awk -v prefix="$field: " '
    $0 == "BEGIN TRANSITION_GUARD_RESULT_V1" { active=1; next }
    $0 == "END TRANSITION_GUARD_RESULT_V1" { exit }
    active && index($0, prefix) == 1 { print substr($0, length(prefix) + 1); exit }
  ' "$result_file"
}

write_real_audit_projection() {
  local feature_dir="$1"
  local contract_file="$2"
  local guard_log="$3"
  local transcript="$4"
  local state_file="$feature_dir/state.json"
  local state_tmp="$WORKSPACE/state-with-audit.json"
  local workflow_mode
  local target_status
  local contract_digest
  local target_revision
  local applicable_classes
  local not_applicable_checks
  local passed_gate_ids
  local failed_gate_ids
  local failed_checks
  local contract_ref
  local mode_class

  workflow_mode="$(transition_result_field "$guard_log" workflowMode)"
  target_status="$(transition_result_field "$guard_log" targetStatus)"
  contract_digest="$(transition_result_field "$guard_log" contractDigest)"
  target_revision="$(transition_result_field "$guard_log" targetRevision)"
  applicable_classes="$(transition_result_field "$guard_log" applicableCheckClasses)"
  not_applicable_checks="$(transition_result_field "$guard_log" notApplicableChecks)"
  passed_gate_ids="$(transition_result_field "$guard_log" passedGateIds)"
  failed_gate_ids="$(transition_result_field "$guard_log" failedGateIds)"
  failed_checks="$(transition_result_field "$guard_log" failedChecks)"
  contract_ref="$(jq -r '.contractRef' "$contract_file")"
  mode_class="$(jq -r '.modeClass // "none"' "$contract_file")"

  jq \
    --arg revision "$target_revision" \
    --arg digest "$contract_digest" \
    '.execution.audit = {
      schemaVersion: "audit-run/v1",
      runId: "run-regression",
      currentAttemptId: "attempt-regression",
      attempts: [{
        attemptId: "attempt-regression",
        resultState: "ACTIVE",
        targetRevision: $revision,
        contractDigest: $digest,
        auditProfile: "planning-maturity-v1",
        targetStatus: "specs_hardened",
        auditVerdict: "PLANNING_AUDIT_CLEAN",
        outcome: "completed_diagnostic",
        evidenceRef: "report.md#audit-attempt-regression",
        addressedFindings: [],
        unresolvedFindings: []
      }]
    }' "$state_file" > "$state_tmp"
  mv "$state_tmp" "$state_file"

  awk '/^BEGIN TRANSITION_GUARD_RESULT_V1$/,/^END TRANSITION_GUARD_RESULT_V1$/' "$guard_log" > "$transcript"
  cat >> "$transcript" <<EOF
AUDIT RESULT
target: $feature_dir
mode: $workflow_mode
audit class: planning-maturity
ceiling: $target_status
verdict: PLANNING_AUDIT_CLEAN

EVALUATION
planning: planning ceiling certified
delivery: delivery not evaluated
not applicable: $not_applicable_checks

BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: run-regression
attemptId: attempt-regression
target: $feature_dir
targetRevision: $target_revision
workflowMode: $workflow_mode
modeClass: $mode_class
auditClass: planning-maturity
statusCeiling: $target_status
requestedStatus: $target_status
auditVerdict: PLANNING_AUDIT_CLEAN
outcome: completed_diagnostic
resultState: ACTIVE
certifiedStatus: $target_status
planningEvaluation: CERTIFIED
deliveryEvaluation: NOT_EVALUATED
sourceEditLockout: PASS
applicableCheckClasses: $applicable_classes
notApplicableChecks: $not_applicable_checks
passedGateIds: $passed_gate_ids
failedGateIds: $failed_gate_ids
failedChecks: $failed_checks
blockingCode: none
unresolvedFields: []
contradictions: []
contractRef: $contract_ref
contractDigest: $contract_digest
evidenceRefs: [report.md#audit-attempt-regression]
addressedFindings: []
unresolvedFindings: []
nextRequiredOwner: none
supersedesAttemptId: none
resumeFromPhase: none
END AUDIT_RESULT_V1
EOF
}

assert_lint_rejects() {
  local result_file="$1"
  local expected="$2"
  local label="$3"
  local output_file="$WORKSPACE/audit-lint-negative-$RANDOM.log"
  local exit_code

  set +e
  bash "$AUDIT_RESULT_LINT" --result "$result_file" > "$output_file" 2>&1
  exit_code=$?
  set -e
  if [[ "$exit_code" -ne 0 ]] && grep -Fq -- "$expected" "$output_file"; then
    pass "$label"
  else
    fail "$label (exit=$exit_code expected=$expected)"
    cat "$output_file" >&2
  fi
}

prepare_audit_adversary() {
  local case_name="$1"
  local case_dir="$WORKSPACE/$case_name"

  cp -R "$HONEST_FIXTURE" "$case_dir"
  cp "$AUDIT_TRANSCRIPT" "$case_dir/result.txt"
  bubbles_sed_inplace "s|$HONEST_FIXTURE|$case_dir|g" "$case_dir/result.txt"
  printf '%s\n' "$case_dir"
}

assert_invocation_count() {
  local invocation_log="$1"
  local expected="$2"
  local actual=0

  if [[ -f "$invocation_log" ]]; then
    actual="$(wc -l < "$invocation_log" | tr -d '[:space:]')"
  fi
  [[ "$actual" -eq "$expected" ]]
}

assert_section_contains() {
  local log_file="$1"
  local section="$2"
  local expected="$3"
  local label="$4"
  local section_file="$WORKSPACE/section-$RANDOM.txt"

  awk -v wanted="$section" '
    /^--- Check / {
      if (active) exit
      active = index($0, wanted) == 1
    }
    active { print }
  ' "$log_file" > "$section_file"

  if grep -Fq -- "$expected" "$section_file"; then
    pass "$label"
  else
    fail "$label (section=$section missing=$expected)"
  fi
}

assert_no_unexpected_blockers() {
  local log_file="$1"
  local unexpected_file="$WORKSPACE/unexpected-blockers.txt"

  awk '
    /^--- Check / { section=$0 }
    /BLOCK:/ {
      allowed = (section ~ /^--- Check 4:/ ||
                 section ~ /^--- Check 5:/ ||
                 section ~ /^--- Check 8:/ ||
                 section ~ /^--- Check 11:/)
      if (!allowed && $0 !~ /TRANSITION BLOCKED/) {
        print section " :: " $0
      }
    }
  ' "$log_file" > "$unexpected_file"

  if [[ -s "$unexpected_file" ]]; then
    fail "guard emitted blockers outside Check 4/5/8/11"
    cat "$unexpected_file" >&2
  else
    pass "guard blockers are confined to Check 4/5/8/11"
  fi
}

assert_planning_gates_clean() {
  local log_file="$1"

  assert_contains "$log_file" 'Zero deferral language found in scope and report artifacts' 'G040 planning integrity is clean'
  assert_contains "$log_file" 'certification block records scopeProgress (any value type)' 'G056 certification scopeProgress is structurally complete'
  assert_contains "$log_file" "Effective TDD mode is 'off' — scenario-first evidence check not required" 'G060 correctly follows the planning-only TDD policy without fabricated evidence'
  assert_contains "$log_file" 'Scope DoD includes scenario-specific regression E2E requirement' 'Check 8A scenario-specific regression DoD is planned'
  assert_contains "$log_file" 'Scope DoD includes broader E2E regression suite requirement' 'Check 8A broader regression DoD is planned'
  assert_contains "$log_file" 'Scope Test Plan includes explicit regression E2E row(s)' 'Check 8A regression Test Plan row is planned'
  assert_contains "$log_file" 'Gherkin scenarios have faithful DoD items' 'G068 planning traceability is clean'
  assert_contains "$log_file" 'Fixture target under tests/fixtures; planning workflow chain enforcement (Gate G091) is not evaluated for artifact-state fixture acceptance' 'G091 uses the canonical hermetic-fixture posture'
  assert_contains "$log_file" 'Fixture target under tests/fixtures; planning packet implementation linkage (Gate G087) is not evaluated for artifact-state fixture acceptance' 'G087 uses the canonical hermetic-fixture posture'
  assert_contains "$log_file" 'Fixture target under tests/fixtures; delivery implementation delta (Gate G093) is not evaluated for artifact-state fixture acceptance' 'G093 uses the canonical hermetic-fixture posture'
  assert_contains "$log_file" 'Fixture target under tests/fixtures; convergence cap enforcement (Gate G082) is not evaluated for artifact-state fixture acceptance' 'G082 uses the canonical hermetic-fixture posture'
  assert_contains "$log_file" 'Fixture target under tests/fixtures; retro convergence health evidence (Gate G090) is not evaluated for artifact-state fixture acceptance' 'G090 uses the canonical hermetic-fixture posture'
  assert_contains "$log_file" 'Artifact lint passes (exit 0)' 'artifact lint is clean for the fixture'
  assert_contains "$log_file" 'Capability foundation requirements are satisfied, not applicable, or grandfathered' 'G094 capability foundation is clean'
  assert_contains "$log_file" 'Discovered-issue disposition clean' 'G095 disposition is clean'
  assert_contains "$log_file" 'Requirement-mechanism correspondence satisfied, disclosed, not applicable, or grandfathered' 'G097 mechanism correspondence is clean'
}

print_red_discriminator() {
  local log_file="$1"

  awk '
    /^--- Check 4:/ { active=1 }
    /^--- Check 4A:/ { active=0 }
    /^--- Check 5:/ { active=1 }
    /^--- Check 5B:/ { active=0 }
    /^--- Check 8:/ { active=1 }
    /^--- Check 8A:/ { active=0 }
    /^--- Check 11:/ { active=1 }
    /^--- Check 12:/ { active=0 }
    active && (/^--- Check / || /BLOCK:/ || /PASS:/) { print }
    /Planning workflow chain preserves analyst -> ux -> design -> plan/ { print }
    /Planning packet implementation linkage is coherent/ { print }
    /Delivery implementation delta is present or mode ceiling exempts it/ { print }
    /TRANSITION BLOCKED:/ { print }
  ' "$log_file"
}

HONEST_FIXTURE="$FIXTURE_ROOT/909-bug009-planning-audit-contract"
INVOCATION_LOG="$WORKSPACE/production-invocations.log"
DIRECT_LOG="$WORKSPACE/direct-guard.log"
AUDIT_LOG="$WORKSPACE/audit-0-pre-a1.log"
AUDIT_CONTRACT="$WORKSPACE/audit-transition-contract.json"
AUDIT_TRANSCRIPT="$WORKSPACE/audit-result.txt"
ARTIFACT_LINT_LOG="$WORKSPACE/artifact-lint.log"
PRE_AUDIT_STATE="$WORKSPACE/pre-audit-state.json"
PRE_AUDIT_SCOPES="$WORKSPACE/pre-audit-scopes.md"

write_honest_planning_fixture "$HONEST_FIXTURE"
cp "$HONEST_FIXTURE/state.json" "$PRE_AUDIT_STATE"
cp "$HONEST_FIXTURE/scopes.md" "$PRE_AUDIT_SCOPES"
git -C "$FIXTURE_REPO" init -q
git -C "$FIXTURE_REPO" add -f tests/fixtures
git -C "$FIXTURE_REPO" \
  -c user.name='Bubbles Regression' \
  -c user.email='bubbles-regression@example.invalid' \
  commit -q -m 'test: seed clean BUG-009 planning fixture'

if fixture_is_honest "$HONEST_FIXTURE"; then
  pass 'fixture is honestly unimplemented'
else
  fail 'fixture integrity precondition failed'
fi

assert_integrity_adversary_rejected fake-test fake-test "$HONEST_FIXTURE"
assert_integrity_adversary_rejected fake-evidence fake-evidence "$HONEST_FIXTURE"
assert_integrity_adversary_rejected done-status done-status "$HONEST_FIXTURE"
assert_integrity_adversary_rejected checked-dod checked-dod "$HONEST_FIXTURE"

set +e
BUBBLES_WORKFLOWS_FILE="$REPO_ROOT/bubbles/workflows.yaml" bash "$ARTIFACT_LINT" "$HONEST_FIXTURE" > "$ARTIFACT_LINT_LOG" 2>&1
ARTIFACT_LINT_EXIT=$?
set -e
if [[ "$ARTIFACT_LINT_EXIT" -eq 0 ]]; then
  pass 'fixture passes artifact lint with real required fields and artifacts'
else
  fail "fixture artifact lint failed (exit=$ARTIFACT_LINT_EXIT)"
  cat "$ARTIFACT_LINT_LOG" >&2
fi

if assert_invocation_count "$WORKSPACE/missing-invocation.log" 1; then
  fail 'bypassing the production invocation was accepted'
else
  pass 'bypassing the production invocation is rejected'
fi

AUDIT_GUARD_REL="$(extract_audit_guard_path)"
if [[ "$AUDIT_GUARD_REL" == 'bubbles/scripts/state-transition-guard.sh' ]]; then
  pass 'Audit 0-pre resolves the canonical transition guard path'
else
  fail "Audit 0-pre guard path is not canonical (observed: ${AUDIT_GUARD_REL:-none})"
fi

if assert_a1_contract_uses_guard_verdict; then
  pass 'Audit A1 consumes the profile-scoped state-transition guard verdict'
else
  fail 'Audit A1 no longer consumes the profile-scoped state-transition guard verdict'
fi

assert_contains "$VALIDATE_AGENT" '### Step 2.11A: Registry-Bound Audit Certification' 'validate exposes the registry-bound audit certification boundary'
assert_contains "$VALIDATE_AGENT" 'A green guard before audit does not certify the ceiling.' 'pre-audit validation cannot certify the planning ceiling'
assert_contains "$VALIDATE_AGENT" 'top-level `status` and `certification.status` become' 'validate owns the exact planning status mirror'
assert_contains "$SCOPE_WORKFLOW" '#### Finalize Transition Boundary (BUG-009)' 'scope workflow exposes the registry-bound finalize boundary'
assert_contains "$PHASE_ENGINE" '#### Registry-Bound Finalize Boundary' 'workflow phase engine independently binds finalization'
assert_contains "$PHASE_ENGINE" 'Finalize itself writes no certification or status.' 'finalize delegates the terminal write to validate alone'
assert_contains "$FEATURE_TEMPLATES" '"currentAttemptId": null' 'feature template initializes a neutral audit evidence pointer'
assert_contains "$FEATURE_TEMPLATES" '"attempts": []' 'feature template initializes no audit attempts'
assert_not_contains "$FEATURE_TEMPLATES" 'PLANNING_AUDIT_CLEAN' 'feature template does not pre-populate a positive planning result'
assert_contains "$SCOPE_TEMPLATES" '"currentAttemptId": null' 'scope template initializes a neutral audit evidence pointer'
assert_contains "$SCOPE_TEMPLATES" '"attempts": []' 'scope template initializes no audit attempts'
assert_not_contains "$SCOPE_TEMPLATES" 'PLANNING_AUDIT_CLEAN' 'scope template does not pre-populate a positive planning result'

if assert_planning_mode_does_not_require_tdd; then
  pass 'product-to-planning registry contract does not require G060 or force scenario-first TDD'
else
  fail 'product-to-planning unexpectedly requires G060 or forces scenario-first TDD'
fi

if bash "$TRANSITION_RESOLVER" "$HONEST_FIXTURE" > "$AUDIT_CONTRACT" 2>/dev/null && [[ -s "$AUDIT_CONTRACT" ]]; then
  pass 'Audit 0-pre independently resolves the transition contract'
else
  fail 'Audit 0-pre transition contract resolution failed'
  printf 'test_23_planning_audit_contract: resolver produced no usable production contract\n' >&2
  exit 2
fi

DIRECT_EXIT="$(run_guard_surface direct "$GUARD" "$HONEST_FIXTURE" "$DIRECT_LOG" "$INVOCATION_LOG")"
AUDIT_EXIT="$(run_asserted_audit_guard_surface "$REPO_ROOT/$AUDIT_GUARD_REL" "$HONEST_FIXTURE" "$AUDIT_CONTRACT" "$AUDIT_LOG" "$INVOCATION_LOG")"

if assert_invocation_count "$INVOCATION_LOG" 2; then
  pass 'direct and Audit 0-pre/A1 paths each executed the production guard'
else
  fail 'production guard invocation count is not exactly two'
fi

assert_contains "$INVOCATION_LOG" "direct|$GUARD|$HONEST_FIXTURE" 'direct path records the canonical production invocation'
assert_contains "$INVOCATION_LOG" "audit-0-pre-a1|$GUARD|$HONEST_FIXTURE" 'Audit path records the canonical production invocation'
assert_contains "$INVOCATION_LOG" '|--target-status|specs_hardened|--expect-workflow-mode|product-to-planning|--expect-contract-digest|sha256:' 'Audit path records target, mode, and digest assertions'

if cmp -s "$PRE_AUDIT_STATE" "$HONEST_FIXTURE/state.json" \
  && jq -e '.status == "in_progress" and .certification.status == "in_progress" and .execution.audit.currentAttemptId == null and (.execution.audit.attempts | length) == 0' "$HONEST_FIXTURE/state.json" >/dev/null; then
  pass 'pre-audit resolver and guard checks do not certify the ceiling'
else
  fail 'pre-audit resolver or guard checks mutated certification state'
fi

if [[ "$DIRECT_EXIT" -eq 0 && "$AUDIT_EXIT" -eq 0 ]]; then
  assert_not_contains "$DIRECT_LOG" 'unchecked DoD item(s) remain' 'planning guard no longer requires completed implementation DoD'
  assert_not_contains "$DIRECT_LOG" "still marked 'Not Started'" 'planning guard no longer requires Done implementation scopes'
  assert_not_contains "$DIRECT_LOG" 'Test Plan references non-existent file' 'planning guard accepts absent future implementation tests'
  assert_not_contains "$DIRECT_LOG" 'has ZERO evidence code blocks' 'planning guard accepts honest zero-evidence reports'

  write_real_audit_projection "$HONEST_FIXTURE" "$AUDIT_CONTRACT" "$AUDIT_LOG" "$AUDIT_TRANSCRIPT"
  if bash "$AUDIT_RESULT_LINT" --result "$AUDIT_TRANSCRIPT" > "$WORKSPACE/audit-result-lint.log" 2>&1; then
    pass 'real Audit 0-pre result and persisted attempt pass the S04 contract lint'
  else
    fail 'real Audit 0-pre result failed the S04 contract lint'
    cat "$WORKSPACE/audit-result-lint.log" >&2
  fi

  if jq -e '.status == "in_progress" and .certification.status == "in_progress" and .certification.completedScopes == [] and .certification.scopeProgress[0].status == "not_started"' "$HONEST_FIXTURE/state.json" >/dev/null; then
    pass 'audit evidence alone does not certify or complete planning delivery state'
  else
    fail 'audit evidence changed certification or delivery state before validate'
  fi

  PROMOTION_BEFORE="$WORKSPACE/planning-promotion-before.json"
  PROMOTION_AFTER="$WORKSPACE/planning-promotion-after.json"
  PROMOTION_BEFORE_REMAINDER="$WORKSPACE/planning-promotion-before-remainder.json"
  PROMOTION_AFTER_REMAINDER="$WORKSPACE/planning-promotion-after-remainder.json"
  cp "$HONEST_FIXTURE/state.json" "$PROMOTION_BEFORE"
  jq '.status = "specs_hardened" | .certification.status = "specs_hardened"' "$PROMOTION_BEFORE" > "$PROMOTION_AFTER"
  jq -S 'del(.status, .certification.status)' "$PROMOTION_BEFORE" > "$PROMOTION_BEFORE_REMAINDER"
  jq -S 'del(.status, .certification.status)' "$PROMOTION_AFTER" > "$PROMOTION_AFTER_REMAINDER"
  if jq -e '.status == "specs_hardened" and .certification.status == "specs_hardened" and .certification.completedScopes == [] and .certification.scopeProgress[0].status == "not_started"' "$PROMOTION_AFTER" >/dev/null \
    && cmp -s "$PROMOTION_BEFORE_REMAINDER" "$PROMOTION_AFTER_REMAINDER" \
    && cmp -s "$PRE_AUDIT_SCOPES" "$HONEST_FIXTURE/scopes.md" \
    && grep -Eq '^- \[ \] ' "$HONEST_FIXTURE/scopes.md" \
    && grep -Fq 'deliveryEvaluation: NOT_EVALUATED' "$AUDIT_TRANSCRIPT"; then
    pass 'clean planning certification changes only both status mirrors to specs_hardened'
  else
    fail 'clean planning certification changed scope, DoD, completedScopes, delivery, or non-status state'
  fi

  if grep -Eiq 'SHIP_IT|SHIP_WITH_NOTES|DO_NOT_SHIP|approved for merge|merge-ready|releasable|deployable|delivered|shipped|delivery (passed|certified|approved)' "$AUDIT_TRANSCRIPT"; then
    fail 'planning audit transcript contains delivery or shipment language'
  else
    pass 'planning audit transcript contains no delivery or shipment approval language'
  fi

  FAKE_RESULT="$WORKSPACE/fake-result-without-guard.txt"
  awk '/^BEGIN AUDIT_RESULT_V1$/,/^END AUDIT_RESULT_V1$/' "$AUDIT_TRANSCRIPT" > "$FAKE_RESULT"
  assert_lint_rejects "$FAKE_RESULT" 'exactly one TRANSITION_GUARD_RESULT_V1 begin marker' 'copied result block without real guard evidence is rejected'

  STALE_RESULT="$WORKSPACE/stale-audit-result.txt"
  awk '
    /^BEGIN AUDIT_RESULT_V1$/ { audit=1 }
    audit && /^contractDigest: / { print "contractDigest: sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"; next }
    { print }
  ' "$AUDIT_TRANSCRIPT" > "$STALE_RESULT"
  assert_lint_rejects "$STALE_RESULT" 'guard.contractDigest mismatch' 'stale audit digest is rejected against the real guard result'

  STALE_REVISION="$WORKSPACE/stale-audit-revision.txt"
  awk '
    /^BEGIN AUDIT_RESULT_V1$/ { audit=1 }
    audit && /^targetRevision: / { print "targetRevision: sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"; next }
    { print }
  ' "$AUDIT_TRANSCRIPT" > "$STALE_REVISION"
  assert_lint_rejects "$STALE_REVISION" 'guard.targetRevision mismatch' 'stale audit revision is rejected at certification'

  MODE_MISMATCH="$WORKSPACE/audit-mode-mismatch.txt"
  awk '
    /^BEGIN AUDIT_RESULT_V1$/ { audit=1 }
    audit && /^workflowMode: / { print "workflowMode: full-delivery"; next }
    { print }
  ' "$AUDIT_TRANSCRIPT" > "$MODE_MISMATCH"
  assert_lint_rejects "$MODE_MISMATCH" 'guard.workflowMode mismatch' 'audit mode mismatch is rejected at certification'

  OVER_CEILING="$WORKSPACE/audit-over-ceiling.txt"
  awk '
    /^BEGIN AUDIT_RESULT_V1$/ { audit=1 }
    audit && /^statusCeiling: / { print "statusCeiling: done"; next }
    audit && /^requestedStatus: / { print "requestedStatus: done"; next }
    audit && /^certifiedStatus: / { print "certifiedStatus: done"; next }
    { print }
  ' "$AUDIT_TRANSCRIPT" > "$OVER_CEILING"
  assert_lint_rejects "$OVER_CEILING" 'guard.targetStatus mismatch' 'over-ceiling planning certification is rejected'

  MULTI_ACTIVE_DIR="$(prepare_audit_adversary s05-multiple-active)"
  jq '(.execution.audit.attempts[0]) as $current | .execution.audit.attempts += [($current | .attemptId = "attempt-duplicate")]' "$MULTI_ACTIVE_DIR/state.json" > "$MULTI_ACTIVE_DIR/state.tmp"
  mv "$MULTI_ACTIVE_DIR/state.tmp" "$MULTI_ACTIVE_DIR/state.json"
  assert_lint_rejects "$MULTI_ACTIVE_DIR/result.txt" 'multiple ACTIVE audit attempts' 'multiple ACTIVE planning attempts block certification'

  DANGLING_DIR="$(prepare_audit_adversary s05-dangling-current)"
  jq '.execution.audit.currentAttemptId = "attempt-missing"' "$DANGLING_DIR/state.json" > "$DANGLING_DIR/state.tmp"
  mv "$DANGLING_DIR/state.tmp" "$DANGLING_DIR/state.json"
  assert_lint_rejects "$DANGLING_DIR/result.txt" 'dangling or does not point to ACTIVE' 'dangling current audit pointer blocks certification'

  INCOMPLETE_DIR="$(prepare_audit_adversary s05-incomplete-current)"
  jq '.execution.audit.currentAttemptId = null | .execution.audit.attempts[0].resultState = "INCOMPLETE"' "$INCOMPLETE_DIR/state.json" > "$INCOMPLETE_DIR/state.tmp"
  mv "$INCOMPLETE_DIR/state.tmp" "$INCOMPLETE_DIR/state.json"
  bubbles_sed_inplace 's/^resultState: ACTIVE$/resultState: INCOMPLETE/' "$INCOMPLETE_DIR/result.txt"
  assert_lint_rejects "$INCOMPLETE_DIR/result.txt" 'planning clean field combination is inconsistent' 'INCOMPLETE clean planning attempt cannot certify'

  MISSING_EVIDENCE_DIR="$(prepare_audit_adversary s05-missing-evidence)"
  jq '.execution.audit.attempts[0].evidenceRef = "none"' "$MISSING_EVIDENCE_DIR/state.json" > "$MISSING_EVIDENCE_DIR/state.tmp"
  mv "$MISSING_EVIDENCE_DIR/state.tmp" "$MISSING_EVIDENCE_DIR/state.json"
  assert_lint_rejects "$MISSING_EVIDENCE_DIR/result.txt" 'ACTIVE attempt requires an evidenceRef' 'missing audit evidence reference blocks certification'

  DISAPPEARING_DIR="$(prepare_audit_adversary s05-disappearing-finding)"
  jq '(.execution.audit.attempts[0]) as $current | .execution.audit.attempts = [($current | .attemptId = "attempt-prior" | .resultState = "SUPERSEDED" | .addressedFindings = [] | .unresolvedFindings = ["F009-DISAPPEARING"]), $current]' "$DISAPPEARING_DIR/state.json" > "$DISAPPEARING_DIR/state.tmp"
  mv "$DISAPPEARING_DIR/state.tmp" "$DISAPPEARING_DIR/state.json"
  bubbles_sed_inplace 's/^supersedesAttemptId: none$/supersedesAttemptId: attempt-prior/' "$DISAPPEARING_DIR/result.txt"
  assert_lint_rejects "$DISAPPEARING_DIR/result.txt" "prior finding 'F009-DISAPPEARING' disappeared" 'disappearing prior finding blocks certification'

  SHIPMENT_RESULT="$WORKSPACE/planning-shipment-result.txt"
  awk '/^BEGIN AUDIT_RESULT_V1$/ { print "workflow action: SHIP_IT" } { print }' "$AUDIT_TRANSCRIPT" > "$SHIPMENT_RESULT"
  assert_lint_rejects "$SHIPMENT_RESULT" 'shipment or positive delivery language' 'planning shipment verdict is rejected by the real audit contract'

  DONE_FIXTURE="$FIXTURE_ROOT/910-bug009-done-delivery-control"
  DONE_CONTRACT="$WORKSPACE/done-delivery-contract.json"
  DONE_LOG="$WORKSPACE/done-delivery-guard.log"
  cp -R "$HONEST_FIXTURE" "$DONE_FIXTURE"
  jq '
    .status = "in_progress"
    | .workflowMode = "bugfix-fastlane"
    | .planningOnly = false
    | .planMaturityOnly = false
    | .planningOnlyJustification = null
    | .policySnapshot.workflowMode = "bugfix-fastlane"
    | .certification.status = "in_progress"
    | .execution.audit = {schemaVersion:"audit-run/v1",runId:null,currentAttemptId:null,attempts:[]}
  ' "$DONE_FIXTURE/state.json" > "$DONE_FIXTURE/state.tmp"
  mv "$DONE_FIXTURE/state.tmp" "$DONE_FIXTURE/state.json"
  if bash "$TRANSITION_RESOLVER" "$DONE_FIXTURE" > "$DONE_CONTRACT" 2>/dev/null; then
    DONE_MODE="$(jq -r '.workflowMode' "$DONE_CONTRACT")"
    DONE_TARGET="$(jq -r '.targetStatus' "$DONE_CONTRACT")"
    DONE_DIGEST="$(jq -r '.contractDigest' "$DONE_CONTRACT")"
    set +e
    bash "$GUARD" "$DONE_FIXTURE" --target-status "$DONE_TARGET" --expect-workflow-mode "$DONE_MODE" --expect-contract-digest "$DONE_DIGEST" > "$DONE_LOG" 2>&1
    DONE_EXIT=$?
    set -e
    if [[ "$DONE_EXIT" -ne 0 ]] \
      && grep -Fq 'UNCHECKED DoD items' "$DONE_LOG" \
      && grep -Fq "still marked 'Not Started'" "$DONE_LOG" \
      && grep -Fq 'Test Plan references non-existent file' "$DONE_LOG" \
      && grep -Fq 'has ZERO evidence code blocks' "$DONE_LOG" \
      && grep -Fq 'auditProfile: delivery-completion-v1' "$DONE_LOG" \
      && grep -Fq 'failedChecks: [Check-4-completion,Check-5-all-done,Check-8-file-existence,Check-11-execution-evidence]' "$DONE_LOG"; then
      pass 'done-ceiling delivery path still strictly requires DoD, Done scopes, test files, and evidence'
    else
      fail "done-ceiling delivery strictness changed (guard exit=$DONE_EXIT)"
      cat "$DONE_LOG" >&2
    fi
  else
    fail 'done-ceiling delivery control contract did not resolve'
  fi

  if [[ "$FAIL_COUNT" -gt 0 ]]; then
    printf 'DISCRIMINATOR_MISMATCH: %s harness assertion(s) failed after a green guard result\n' "$FAIL_COUNT" >&2
    exit 2
  fi

  printf 'GREEN_REGRESSION_VERDICT=PLANNING_AUDIT_CONTRACT_SATISFIED\n'
  printf 'DIRECT_GUARD_EXIT=%s\n' "$DIRECT_EXIT"
  printf 'AUDIT_0_PRE_A1_EXIT=%s\n' "$AUDIT_EXIT"
  printf 'AUDIT_RESULT_LINT_EXIT=0\n'
  printf 'test_23_planning_audit_contract: %s passed, 0 failed\n' "$PASS_COUNT"
  exit 0
fi

if [[ "$DIRECT_EXIT" -ne 0 && "$AUDIT_EXIT" -ne 0 ]]; then
  assert_section_contains "$DIRECT_LOG" '--- Check 4:' "UNCHECKED DoD items — ALL must be [x] for 'done'" 'Check-4-completion is unconditionally blocking'
  assert_section_contains "$DIRECT_LOG" '--- Check 5:' "still marked 'Not Started'" 'Check-5-all-done is unconditionally blocking'
  assert_section_contains "$DIRECT_LOG" '--- Check 8:' 'Test Plan references non-existent file' 'Check-8-file-existence is unconditionally blocking'
  assert_section_contains "$DIRECT_LOG" '--- Check 11:' 'has ZERO evidence code blocks' 'Check-11-execution-evidence is unconditionally blocking'
  assert_planning_gates_clean "$DIRECT_LOG"
  assert_no_unexpected_blockers "$DIRECT_LOG"

  if [[ "$FAIL_COUNT" -gt 0 ]]; then
    printf 'DISCRIMINATOR_MISMATCH: observed guard failure differs from BUG-009 S01 hypothesis (%s harness assertion(s) failed)\n' "$FAIL_COUNT" >&2
    printf 'DIRECT_GUARD_EXIT=%s\n' "$DIRECT_EXIT" >&2
    printf 'AUDIT_0_PRE_A1_EXIT=%s\n' "$AUDIT_EXIT" >&2
    exit 2
  fi

  printf '%s\n' '--- BUG-009 S01 canonical RED discriminator ---'
  print_red_discriminator "$DIRECT_LOG"
  printf 'DIRECT_GUARD_EXIT=%s\n' "$DIRECT_EXIT"
  printf 'AUDIT_0_PRE_A1_EXIT=%s\n' "$AUDIT_EXIT"
  printf 'RED_REGRESSION_VERDICT=EXPECTED_PRE_FIX_COMPLETION_FAILURE\n'
  printf 'test_23_planning_audit_contract: %s integrity/discriminator assertions passed; intentional RED exit follows\n' "$PASS_COUNT"
  exit 1
fi

printf 'DISCRIMINATOR_MISMATCH: direct guard exit=%s audit 0-pre/A1 exit=%s\n' "$DIRECT_EXIT" "$AUDIT_EXIT" >&2
exit 2
