#!/usr/bin/env bash
set -uo pipefail

# BUG-023 final-byte production-path regression.
#
# This file is intentionally self-contained and hermetic. Every behavioral
# case creates a disposable Git repository and invokes the canonical Bubbles
# guard/helper paths as black boxes. A valid pre-fix RED has all fixture and
# delivery controls green, at least one causal failure in each of G040/G060/
# G073, and zero harness/control failures.

LC_ALL=C
export LC_ALL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_FILE="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
GUARD="$REPO_ROOT/bubbles/scripts/state-transition-guard.sh"
TRANSITION_RESOLVER="$REPO_ROOT/bubbles/scripts/transition-contract-resolver.sh"
BASELINE_HELPER="$REPO_ROOT/bubbles/scripts/planning-source-baseline.sh"
AUDIT_RESULT_SELFTEST="$REPO_ROOT/bubbles/scripts/audit-result-contract-lint-selftest.sh"

usage() {
  cat <<'USAGE'
Usage: test_30_planning_transition_applicability_and_baseline.sh [--scenario SCN-BUG-023-NNN]

No arguments run the complete ordered 17-scenario matrix.
  --scenario SCN-BUG-023-NNN   Run exactly one scenario (001 through 017)
  -h, --help                   Show this help without creating fixtures
USAGE
}

SELECTED_SCENARIO=""
case "$#" in
  0)
    ;;
  1)
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'test_30_planning_transition_applicability_and_baseline: usage error: unknown argument: %s\n' "$1" >&2
        usage >&2
        exit 64
        ;;
    esac
    ;;
  2)
    if [[ "$1" != "--scenario" ]]; then
      printf 'test_30_planning_transition_applicability_and_baseline: usage error: unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 64
    fi
    case "$2" in
      SCN-BUG-023-001|SCN-BUG-023-002|SCN-BUG-023-003|SCN-BUG-023-004|SCN-BUG-023-005|SCN-BUG-023-006|SCN-BUG-023-007|SCN-BUG-023-008|SCN-BUG-023-009|SCN-BUG-023-010|SCN-BUG-023-011|SCN-BUG-023-012|SCN-BUG-023-013|SCN-BUG-023-014|SCN-BUG-023-015|SCN-BUG-023-016|SCN-BUG-023-017)
        SELECTED_SCENARIO="$2"
        ;;
      *)
        printf 'test_30_planning_transition_applicability_and_baseline: usage error: unknown scenario: %s\n' "$2" >&2
        usage >&2
        exit 64
        ;;
    esac
    ;;
  *)
    printf '%s\n' 'test_30_planning_transition_applicability_and_baseline: usage error: expected no arguments or --scenario SCN-BUG-023-NNN' >&2
    usage >&2
    exit 64
    ;;
esac

for required_file in "$TEST_FILE" "$GUARD" "$TRANSITION_RESOLVER" "$AUDIT_RESULT_SELFTEST"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'FAIL-HARNESS[bootstrap]: required canonical surface missing: %s\n' "$required_file" >&2
    exit 2
  fi
done

for required_command in awk bash cat chmod cmp cp cut dirname find git grep jq ln mkdir mktemp mv printf python3 readlink rm sort tr wc yq; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'FAIL-HARNESS[bootstrap]: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done
if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
  printf '%s\n' 'FAIL-HARNESS[bootstrap]: no SHA-256 provider is available' >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug023-test30-XXXXXXXX")"
cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

PASS_CONTROLS=0
CAUSAL_FAILURES=0
HARNESS_FAILURES=0
CONTROL_FAILURES=0
G040_CAUSAL_FAILURES=0
G060_CAUSAL_FAILURES=0
G073_CAUSAL_FAILURES=0
GUARD_RUNS=0
BASELINE_RUNS=0
BASELINE_HELPER_ABSENCE_REPORTED=0
CURRENT_SCENARIO="bootstrap"
RUN_LOG=""
RUN_STATUS=0
V2_GATE_RESULTS=""
V2_AVAILABLE="false"

pass_control() {
  PASS_CONTROLS=$((PASS_CONTROLS + 1))
  printf 'PASS-CONTROL[%s]: %s\n' "$CURRENT_SCENARIO" "$1"
}

control_fail() {
  CONTROL_FAILURES=$((CONTROL_FAILURES + 1))
  printf 'FAIL-CONTROL[%s]: %s\n' "$CURRENT_SCENARIO" "$1" >&2
}

harness_fail() {
  HARNESS_FAILURES=$((HARNESS_FAILURES + 1))
  printf 'FAIL-HARNESS[%s]: %s\n' "$CURRENT_SCENARIO" "$1" >&2
}

harness_die() {
  harness_fail "$1"
  printf '%s\n' 'HARNESS_ABORT: fixture integrity is not sufficient to classify behavioral RED.' >&2
  exit 2
}

causal_fail() {
  local family="$1"
  shift
  CAUSAL_FAILURES=$((CAUSAL_FAILURES + 1))
  case "$family" in
    G040) G040_CAUSAL_FAILURES=$((G040_CAUSAL_FAILURES + 1)) ;;
    G060) G060_CAUSAL_FAILURES=$((G060_CAUSAL_FAILURES + 1)) ;;
    G073) G073_CAUSAL_FAILURES=$((G073_CAUSAL_FAILURES + 1)) ;;
    *) harness_die "unknown causal family: $family" ;;
  esac
  printf 'FAIL-CAUSAL[%s][%s]: %s\n' "$family" "$CURRENT_SCENARIO" "$*" >&2
}

sha256_file() {
  local digest_line=""
  if command -v sha256sum >/dev/null 2>&1; then
    digest_line="$(sha256sum "$1")"
  else
    digest_line="$(shasum -a 256 "$1")"
  fi
  set -- $digest_line
  printf '%s\n' "$1"
}

sha256_stdin() {
  local digest_line=""
  if command -v sha256sum >/dev/null 2>&1; then
    digest_line="$(sha256sum)"
  else
    digest_line="$(shasum -a 256)"
  fi
  set -- $digest_line
  printf '%s\n' "$1"
}

assert_file_unchanged() {
  local file="$1"
  local before="$2"
  local label="$3"
  local after=""
  if [[ ! -f "$file" ]]; then
    harness_fail "$label (file disappeared: $file)"
    return 1
  fi
  after="$(sha256_file "$file")"
  if [[ "$after" == "$before" ]]; then
    pass_control "$label"
    return 0
  fi
  harness_fail "$label (before=$before after=$after)"
  return 1
}

assert_log_contains_control() {
  local log_file="$1"
  local expected="$2"
  local label="$3"
  if grep -Fq -- "$expected" "$log_file"; then
    pass_control "$label"
  else
    control_fail "$label (missing: $expected)"
  fi
}

assert_log_not_contains_control() {
  local log_file="$1"
  local forbidden="$2"
  local label="$3"
  if grep -Fq -- "$forbidden" "$log_file"; then
    control_fail "$label (unexpected: $forbidden)"
  else
    pass_control "$label"
  fi
}

count_exact_line() {
  local file="$1"
  local exact="$2"
  awk -v exact="$exact" '$0 == exact { count++ } END { print count + 0 }' "$file"
}

extract_result_field() {
  local log_file="$1"
  local field="$2"
  awk -v prefix="$field: " '
    $0 == "BEGIN TRANSITION_GUARD_RESULT_V2" { active=1; next }
    $0 == "END TRANSITION_GUARD_RESULT_V2" { exit }
    active && index($0, prefix) == 1 { print substr($0, length(prefix) + 1); exit }
  ' "$log_file"
}

extract_check_section() {
  local log_file="$1"
  local check_prefix="$2"
  local output_file="$3"
  awk -v wanted="$check_prefix" '
    /^--- Check / {
      if (active) exit
      active = index($0, wanted) == 1
    }
    active { print }
  ' "$log_file" > "$output_file"
}

load_v2_result() {
  local log_file="$1"
  local family="$2"
  local label="$3"
  local begin_count=""
  local end_count=""
  local schema=""
  local gate_schema=""
  local gate_digest=""
  local expected_digest=""
  local canonical_json=""

  V2_AVAILABLE="false"
  V2_GATE_RESULTS=""
  begin_count="$(count_exact_line "$log_file" 'BEGIN TRANSITION_GUARD_RESULT_V2')"
  end_count="$(count_exact_line "$log_file" 'END TRANSITION_GUARD_RESULT_V2')"
  if [[ "$begin_count" -ne 1 || "$end_count" -ne 1 ]]; then
    causal_fail "$family" "$label lacks exactly one TRANSITION_GUARD_RESULT_V2 block (begin=$begin_count end=$end_count)"
    return 1
  fi

  schema="$(extract_result_field "$log_file" schemaVersion)"
  gate_schema="$(extract_result_field "$log_file" gateResultsSchema)"
  V2_GATE_RESULTS="$(extract_result_field "$log_file" gateResults)"
  gate_digest="$(extract_result_field "$log_file" gateResultsDigest)"
  if [[ "$schema" != "transition-guard-result/v2" ]]; then
    causal_fail "$family" "$label has schemaVersion=$schema instead of transition-guard-result/v2"
    return 1
  fi
  if [[ "$gate_schema" != "transition-gate-results/v1" ]]; then
    causal_fail "$family" "$label has gateResultsSchema=$gate_schema instead of transition-gate-results/v1"
    return 1
  fi
  if ! printf '%s' "$V2_GATE_RESULTS" | jq -e 'type == "array"' >/dev/null 2>&1; then
    causal_fail "$family" "$label gateResults is not a JSON array"
    return 1
  fi
  canonical_json="$(printf '%s' "$V2_GATE_RESULTS" | jq -cS '.')"
  if [[ "$canonical_json" != "$V2_GATE_RESULTS" ]]; then
    causal_fail "$family" "$label gateResults is not canonical jq -cS JSON"
    return 1
  fi
  expected_digest="sha256:$(printf '%s' "$V2_GATE_RESULTS" | sha256_stdin)"
  if [[ "$gate_digest" != "$expected_digest" ]]; then
    causal_fail "$family" "$label gateResultsDigest mismatch (observed=$gate_digest expected=$expected_digest)"
    return 1
  fi
  if [[ "$(extract_result_field "$log_file" exitStatus)" != "$RUN_STATUS" ]]; then
    causal_fail "$family" "$label structured exitStatus does not equal process exit $RUN_STATUS"
    return 1
  fi
  V2_AVAILABLE="true"
  pass_control "$label emits one canonical digest-bound V2 transition result"
  return 0
}

v2_top_gate_count() {
  local gate_id="$1"
  local status="$2"
  local applicability="$3"
  local reason="$4"
  printf '%s' "$V2_GATE_RESULTS" | jq -r \
    --arg gate "$gate_id" \
    --arg status "$status" \
    --arg applicability "$applicability" \
    --arg reason "$reason" \
    '[.[] | select(.gateId == $gate and .status == $status and .applicability == $applicability and .reasonCode == $reason)] | length'
}

v2_detail_count() {
  local gate_id="$1"
  local status="$2"
  local phrase="$3"
  local outcome="$4"
  local reason="$5"
  local artifact_path="$6"
  local line_number="$7"
  local statement_digest="$8"
  local protected_path="$9"
  local state_class="${10}"
  local actionability="${11}"
  printf '%s' "$V2_GATE_RESULTS" | jq -r \
    --arg gate "$gate_id" \
    --arg status "$status" \
    --arg phrase "$phrase" \
    --arg outcome "$outcome" \
    --arg reason "$reason" \
    --arg artifactPath "$artifact_path" \
    --argjson lineNumber "$line_number" \
    --arg statementDigest "$statement_digest" \
    --arg protectedPath "$protected_path" \
    --arg stateClass "$state_class" \
    --arg actionability "$actionability" '
      [.. | objects | select(
        .gateId? == $gate
        and .status? == $status
        and ($phrase == "ANY" or .phraseDisposition? == $phrase)
        and ($outcome == "ANY" or .outcome? == $outcome)
        and .reasonCode? == $reason
        and .actionability? == $actionability
        and ($artifactPath == "ANY" or .evidenceIdentity.artifactPath? == $artifactPath)
        and ($lineNumber == 0 or .evidenceIdentity.lineNumber? == $lineNumber)
        and ($statementDigest == "ANY" or .evidenceIdentity.statementDigest? == $statementDigest)
        and ($protectedPath == "ANY" or .evidenceIdentity.protectedPath? == $protectedPath)
        and ($stateClass == "ANY" or .evidenceIdentity.stateClass? == $stateClass)
      )] | length'
}

run_guard() {
  local feature_dir="$1"
  local label="$2"
  RUN_LOG="$WORKSPACE/${label}.guard.log"
  set +e
  bash "$GUARD" "$feature_dir" > "$RUN_LOG" 2>&1
  RUN_STATUS=$?
  set -e
  GUARD_RUNS=$((GUARD_RUNS + 1))
}

write_fixture_packet() {
  local feature_dir="$1"
  local workflow_mode="$2"
  local tdd_mode="$3"
  mkdir -p "$feature_dir"

  cat > "$feature_dir/spec.md" <<'MARKDOWN'
# BUG-023 Hermetic Fixture

## Problem

The target-aware transition contract is exercised in a disposable repository.

## Outcome Contract

- **Intent:** Exercise the canonical transition decision path.
- **Success Signal:** The selected gate emits its machine result.
- **Hard Constraints:** The repository remains disposable and offline.
- **Failure Condition:** The selected gate cannot be observed.
MARKDOWN

  cat > "$feature_dir/design.md" <<'MARKDOWN'
# Fixture Design

## Approach

Invoke the canonical transition scripts against one disposable Git repository.

## Consumer Impact Sweep

The fixture changes no route, identifier, or external consumer.

## Shared Infrastructure Impact Sweep

The fixture uses no shared service or persistent store.
MARKDOWN

  cat > "$feature_dir/scopes.md" <<'MARKDOWN'
# Scope 01: Transition Fixture

**Status:** Not Started
**Scope-Kind:** contract-only

### Goal

Observe one selected transition contract without a delivery claim.

### Definition of Done

- [ ] The selected transition contract is observed.
MARKDOWN

  cat > "$feature_dir/report.md" <<'MARKDOWN'
# Report

### Summary

Disposable transition fixture.

### Completion Statement

No completion claim is recorded by this fixture.

### Test Evidence

The regression selects the evidence shape for this case.

### Code Diff Evidence

The fixture has no canonical source delta.
MARKDOWN

  cat > "$feature_dir/uservalidation.md" <<'MARKDOWN'
# User Validation

## Checklist

- [x] The fixture is isolated from product repositories.
MARKDOWN

  cat > "$feature_dir/state.json" <<EOF
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "$workflow_mode",
  "planningOnly": true,
  "planMaturityOnly": true,
  "createdAt": "2026-07-17T00:00:00Z",
  "execution": {
    "currentScope": null,
    "currentPhase": "test",
    "completedPhaseClaims": [],
    "planningSourceBaselineHistory": []
  },
  "certification": {
    "status": "in_progress",
    "certifiedCompletedPhases": [],
    "completedScopes": [],
    "scopeProgress": [],
    "lockdownState": {"mode": "off", "lockedScenarioIds": []}
  },
  "policySnapshot": {
    "workflowMode": "$workflow_mode",
    "grill": {"mode": "off", "source": "repo-default"},
    "tdd": {"mode": "$tdd_mode", "source": "user-request"},
    "autoCommit": {"mode": "off", "source": "repo-default"},
    "lockdown": {"mode": "off", "source": "repo-default"},
    "regression": {"mode": "protect-existing-scenarios", "source": "repo-default"},
    "validation": {"mode": "required", "source": "workflow-forced"}
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": []
}
EOF
}

new_fixture_repo() {
  local case_name="$1"
  local workflow_mode="$2"
  local tdd_mode="$3"
  local repo="$WORKSPACE/repo-$case_name"
  local feature_dir="$repo/specs/900-$case_name"

  mkdir -p "$repo/src" "$repo/.specify/memory"
  git -C "$repo" init -q || harness_die "cannot initialize fixture repo $case_name"
  git -C "$repo" config user.name 'Bubbles Regression' || harness_die "cannot set fixture Git user.name"
  git -C "$repo" config user.email 'bubbles-regression@example.invalid' || harness_die "cannot set fixture Git user.email"

  cat > "$repo/.gitignore" <<'IGNORE'
.specify/runtime/
IGNORE
  cat > "$repo/.specify/memory/bubbles.config.json" <<'JSON'
{
  "version": 2,
  "defaults": {
    "grill": {"mode": "off", "source": "repo-default"},
    "tdd": {"mode": "scenario-first", "source": "repo-default"},
    "lockdown": {"default": false, "source": "repo-default"},
    "regression": {"immutability": "protected-scenarios", "source": "repo-default"},
    "validation": {"certificationRequired": true, "source": "workflow-forced"}
  }
}
JSON

  printf '%s\n' 'seed staged' > "$repo/src/staged file.rs"
  printf '%s\n' 'seed unstaged' > "$repo/src/unstaged.rs"
  printf '%s\n' 'seed mixed' > "$repo/src/mixed.rs"
  printf '%s\n' 'seed rename' > "$repo/src/rename old.rs"
  printf '%s\n' 'seed delete' > "$repo/src/delete.rs"
  printf '%s\n' 'seed mode' > "$repo/src/mode.rs"
  printf '%s\n' 'seed type' > "$repo/src/type.rs"
  printf '%s\n' 'symlink target a' > "$repo/src/target-a.txt"
  printf '%s\n' 'symlink target b' > "$repo/src/target-b.txt"
  ln -s 'target-a.txt' "$repo/src/link.rs" || harness_die "cannot create fixture symlink"
  write_fixture_packet "$feature_dir" "$workflow_mode" "$tdd_mode"

  git -C "$repo" add -A || harness_die "cannot stage fixture repo $case_name"
  git -C "$repo" commit -q -m 'test: seed BUG-023 fixture' || harness_die "cannot commit fixture repo $case_name"
  printf '%s\t%s\n' "$repo" "$feature_dir"
}

append_report_line() {
  local feature_dir="$1"
  local line="$2"
  printf '%s\n' "$line" >> "$feature_dir/report.md"
}

exact_line_number() {
  local file="$1"
  local exact="$2"
  awk -v exact="$exact" '$0 == exact { print NR; exit }' "$file"
}

path_state_digest() {
  local repo="$1"
  shift
  local snapshot="$WORKSPACE/path-state-$RANDOM.bin"
  local path=""
  : > "$snapshot"
  git -C "$repo" status --porcelain=v2 -z --untracked-files=all -- "$@" >> "$snapshot" 2>/dev/null || true
  git -C "$repo" ls-files --stage -z -- "$@" >> "$snapshot" 2>/dev/null || true
  for path in "$@"; do
    printf '\nPATH:%s\n' "$path" >> "$snapshot"
    if [[ -L "$repo/$path" ]]; then
      printf '%s\n' 'TYPE:SYMLINK' >> "$snapshot"
      readlink "$repo/$path" >> "$snapshot"
    elif [[ -f "$repo/$path" ]]; then
      printf '%s\n' 'TYPE:REGULAR' >> "$snapshot"
      if [[ -x "$repo/$path" ]]; then
        printf '%s\n' 'MODE:EXECUTABLE' >> "$snapshot"
      else
        printf '%s\n' 'MODE:NONEXECUTABLE' >> "$snapshot"
      fi
      sha256_file "$repo/$path" >> "$snapshot"
    else
      printf '%s\n' 'TYPE:ABSENT' >> "$snapshot"
    fi
  done
  sha256_file "$snapshot"
}

assert_path_state_unchanged() {
  local repo="$1"
  local before="$2"
  local label="$3"
  shift 3
  local after=""
  after="$(path_state_digest "$repo" "$@")"
  if [[ "$after" == "$before" ]]; then
    pass_control "$label"
  else
    harness_fail "$label (before=$before after=$after)"
  fi
}

assert_guard_reached() {
  local log_file="$1"
  local check_text="$2"
  local label="$3"
  if grep -Fq -- "$check_text" "$log_file"; then
    pass_control "$label"
  else
    harness_fail "$label (canonical guard did not reach: $check_text)"
  fi
}

assert_g060_v2() {
  local log_file="$1"
  local expected_status="$2"
  local expected_applicability="$3"
  local expected_reason="$4"
  local label="$5"
  local family="G060"
  local count="0"

  if ! load_v2_result "$log_file" "$family" "$label"; then
    causal_fail "$family" "$label cannot prove status=$expected_status applicability=$expected_applicability reason=$expected_reason without V2"
    return
  fi
  count="$(v2_top_gate_count G060 "$expected_status" "$expected_applicability" "$expected_reason")"
  if [[ "$count" -eq 1 ]]; then
    pass_control "$label has exactly one G060 $expected_status/$expected_reason result"
  else
    causal_fail "$family" "$label expected exactly one G060 $expected_status/$expected_reason result, observed $count"
  fi

  if [[ "$expected_applicability" == "NOT_APPLICABLE" ]]; then
    if [[ "$(extract_result_field "$log_file" notApplicableChecks)" == *"Check-3E-G060-red-green-evidence"* ]] \
      && [[ "$(extract_result_field "$log_file" passedGateIds)" != *"G060"* ]] \
      && [[ "$(extract_result_field "$log_file" failedGateIds)" != *"G060"* ]]; then
      pass_control "$label records G060 as N/A without pass/fail attribution"
    else
      causal_fail "$family" "$label did not preserve the planning N/A outer-result invariants"
    fi
  else
    if [[ "$(extract_result_field "$log_file" notApplicableChecks)" != *"Check-3E-G060-red-green-evidence"* ]]; then
      pass_control "$label keeps delivery G060 applicable"
    else
      causal_fail "$family" "$label incorrectly marked delivery G060 not applicable"
    fi
  fi
}

run_delivery_case() {
  local case_name="$1"
  local workflow_mode="$2"
  local evidence_shape="$3"
  local expected_reason="$4"
  local fixture=""
  local repo=""
  local feature_dir=""
  local section="$WORKSPACE/$case_name.g060.section"

  fixture="$(new_fixture_repo "$case_name" "$workflow_mode" scenario-first)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"

  case "$evidence_shape" in
    missing)
      append_report_line "$feature_dir" 'Runtime execution evidence is absent.'
      ;;
    green-before-red)
      append_report_line "$feature_dir" 'GREEN: targeted proof now passes.'
      append_report_line "$feature_dir" 'test result: ok. 1 passed; 0 failed'
      append_report_line "$feature_dir" 'RED: targeted proof failed before repair.'
      append_report_line "$feature_dir" 'test result: FAILED. 0 passed; 1 failed'
      ;;
    ordered)
      append_report_line "$feature_dir" 'RED: targeted proof failed before repair.'
      append_report_line "$feature_dir" 'test result: FAILED. 0 passed; 1 failed'
      append_report_line "$feature_dir" 'GREEN: targeted proof now passes.'
      append_report_line "$feature_dir" 'test result: ok. 1 passed; 0 failed'
      ;;
    *)
      harness_die "unknown delivery evidence shape: $evidence_shape"
      ;;
  esac

  run_guard "$feature_dir" "$case_name"
  assert_guard_reached "$RUN_LOG" '--- Check 3E: Scenario-first TDD Evidence (Gate G060) ---' "$case_name reaches canonical G060"
  extract_check_section "$RUN_LOG" '--- Check 3E:' "$section"

  if [[ "$evidence_shape" == "ordered" ]]; then
    if grep -Fq 'ordering is recorded in the scope/report artifacts' "$section" \
      || grep -Fq '[G060] PASS' "$section"; then
      pass_control "$workflow_mode ordered RED-before-GREEN remains a positive G060 control"
    else
      control_fail "$workflow_mode ordered RED-before-GREEN did not pass G060"
    fi
    assert_g060_v2 "$RUN_LOG" PASS APPLICABLE RED_GREEN_ORDER_VALID "$case_name"
  else
    if [[ "$RUN_STATUS" -ne 0 ]] \
      && { grep -Fq 'no RED' "$section" || grep -Fq '[G060] BLOCKED' "$section"; }; then
      pass_control "$workflow_mode $evidence_shape remains blocking at G060"
    else
      control_fail "$workflow_mode $evidence_shape no longer blocks at G060 (guard exit=$RUN_STATUS)"
    fi
    assert_g060_v2 "$RUN_LOG" BLOCKED APPLICABLE "$expected_reason" "$case_name"
  fi

  if [[ -d "$repo" ]]; then
    pass_control "$case_name used a disposable Git repository"
  else
    harness_fail "$case_name fixture repo disappeared before assertion completion"
  fi
}

scenario_001() {
  local fixture=""
  local feature_dir=""
  local section="$WORKSPACE/planning-g060-na.section"
  CURRENT_SCENARIO="SCN-BUG-023-001"
  fixture="$(new_fixture_repo planning-g060-na product-to-planning scenario-first)"
  feature_dir="${fixture#*$'\t'}"
  append_report_line "$feature_dir" 'Runtime execution evidence is absent.'
  run_guard "$feature_dir" planning-g060-na
  assert_guard_reached "$RUN_LOG" '--- Check 3E: Scenario-first TDD Evidence (Gate G060) ---' 'planning fixture reaches canonical G060'
  extract_check_section "$RUN_LOG" '--- Check 3E:' "$section"
  if grep -Fq 'no RED' "$section"; then
    causal_fail G060 'planning-maturity-v1 incorrectly evaluates and blocks absent runtime RED-to-GREEN evidence'
  elif grep -Fq '[G060] NOT_APPLICABLE' "$section"; then
    pass_control 'planning-maturity-v1 emits the fixed G060 NOT_APPLICABLE human block'
  else
    harness_fail 'planning G060 section contains neither the current missing-evidence defect nor the fixed N/A contract'
  fi
  assert_g060_v2 "$RUN_LOG" NOT_APPLICABLE NOT_APPLICABLE PROFILE_PLANNING_MATURITY 'planning_g060_not_applicable'
}

scenario_002() {
  CURRENT_SCENARIO="SCN-BUG-023-002"
  run_delivery_case full-delivery-missing full-delivery missing RED_GREEN_EVIDENCE_MISSING
  run_delivery_case full-delivery-green-first full-delivery green-before-red GREEN_PRECEDES_RED
  run_delivery_case full-delivery-ordered full-delivery ordered RED_GREEN_ORDER_VALID
}

scenario_003() {
  CURRENT_SCENARIO="SCN-BUG-023-003"
  run_delivery_case bugfix-missing bugfix-fastlane missing RED_GREEN_EVIDENCE_MISSING
  run_delivery_case bugfix-green-first bugfix-fastlane green-before-red GREEN_PRECEDES_RED
  run_delivery_case bugfix-ordered bugfix-fastlane ordered RED_GREEN_ORDER_VALID
}

new_g040_matrix() {
  local case_name="$1"
  local fixture=""
  local repo=""
  local feature_dir=""
  fixture="$(new_fixture_repo "$case_name" product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  printf '%s\t%s\n' "$repo" "$feature_dir"
}

add_g040_vector() {
  local feature_dir="$1"
  local manifest="$2"
  local expected_status="$3"
  local expected_scan="$4"
  local expected_phrase="$5"
  local expected_reason="$6"
  local statement="$7"
  local line_number=""
  local digest=""
  append_report_line "$feature_dir" "$statement"
  line_number="$(exact_line_number "$feature_dir/report.md" "$statement")"
  if [[ -z "$line_number" || ! "$line_number" =~ ^[1-9][0-9]*$ ]]; then
    harness_die "cannot resolve unique positive line number for G040 vector: $statement"
  fi
  digest="sha256:$(printf '%s' "$statement" | sha256_stdin)"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$expected_status" "$expected_scan" "$expected_phrase" "$expected_reason" "$line_number" "$digest" "$statement" >> "$manifest"
}

assert_g040_matrix() {
  local repo="$1"
  local feature_dir="$2"
  local manifest="$3"
  local case_name="$4"
  local expect_block="$5"
  local report_hash=""
  local artifact_path="${feature_dir#"$repo"/}/report.md"
  local expected_status=""
  local expected_scan=""
  local expected_phrase=""
  local expected_reason=""
  local line_number=""
  local digest=""
  local statement=""
  local count="0"
  local actionability=""
  local section="$WORKSPACE/$case_name.g040.section"

  report_hash="$(sha256_file "$feature_dir/report.md")"
  run_guard "$feature_dir" "$case_name"
  assert_guard_reached "$RUN_LOG" '--- Check 18: Deferral Language Scan (Gate G040) ---' "$case_name reaches canonical G040"
  assert_file_unchanged "$feature_dir/report.md" "$report_hash" "$case_name guard is read-only on the classified artifact"
  extract_check_section "$RUN_LOG" '--- Check 18:' "$section"

  if [[ "$expect_block" == "yes" ]]; then
    if [[ "$RUN_STATUS" -ne 0 ]] && grep -Fq 'Report artifact contains' "$section"; then
      pass_control "$case_name blocking matrix is rejected by canonical G040"
    else
      control_fail "$case_name blocking matrix was not rejected by canonical G040 (guard exit=$RUN_STATUS)"
    fi
  elif grep -Fq 'Report artifact contains' "$section"; then
    causal_fail G040 "$case_name expected-safe-only phrase matrix is misclassified as deferral by canonical G040"
  else
    pass_control "$case_name expected-safe-only phrase matrix is not blocked by canonical G040"
  fi

  load_v2_result "$RUN_LOG" G040 "$case_name" || true
  while IFS=$'\t' read -r expected_status expected_scan expected_phrase expected_reason line_number digest statement; do
    [[ -n "$expected_reason" ]] || continue
    if [[ "$expected_status" == "BLOCKED" ]]; then
      actionability="ACTION_REQUIRED"
    else
      actionability="NON_ACTIONABLE"
    fi
    if [[ "$V2_AVAILABLE" != "true" ]]; then
      causal_fail G040 "$case_name cannot prove exact line=$line_number reason=$expected_reason statement='$statement' because V2 gate details are unavailable"
      continue
    fi
    count="$(v2_detail_count G040 "$expected_status" "$expected_phrase" ANY "$expected_reason" "$artifact_path" "$line_number" "$digest" ANY ANY "$actionability")"
    if [[ "$count" -eq 1 ]]; then
      pass_control "$case_name line $line_number maps exactly to $expected_reason"
    else
      causal_fail G040 "$case_name line=$line_number expected exactly one $expected_status/$expected_scan/$expected_phrase/$expected_reason detail, observed $count"
    fi
    if grep -Fq -- "$statement" "$RUN_LOG"; then
      causal_fail G040 "$case_name disclosed classified content for line=$line_number instead of withholding it"
    else
      pass_control "$case_name withholds raw content for line $line_number"
    fi
  done < "$manifest"
}

scenario_004() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-title.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-004"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-title)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED TITLE_OR_DOMAIN_LABEL 'Authorized Outcome Follow-Up'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED TITLE_OR_DOMAIN_LABEL 'AUTHORIZED OUTCOME FOLLOW-UP'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED TITLE_OR_DOMAIN_LABEL '(Authorized Outcome Follow-Up)!'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-title no
}

scenario_005() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-noun.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-005"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-noun)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED NOUN_COMPOUND 'follow-up projection'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED NOUN_COMPOUND 'FOLLOW-UP PROJECTION'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED NOUN_COMPOUND '(follow-up projection).'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-noun no
}

scenario_006() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-structured.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-006"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-structured)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL '## Follow-Up'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL '## FOLLOW-UP'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL '## Follow-Up!'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL '| Follow-Up |'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL '| FOLLOW-UP |'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL '| Follow-Up! |'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL 'Follow-Up:'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL 'FOLLOW-UP:'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED STRUCTURED_LABEL 'Follow-Up:!'
  add_g040_vector "$feature_dir" "$manifest" PASS EXCLUDED_STRUCTURAL NONE CANONICAL_STRUCTURAL_EXCLUSION 'followUpOwner: bubbles.test'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-structured no
}

scenario_007() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-present.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-007"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-present)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED PRESENT_SURFACE 'The active MVP surface includes the Authorized Outcome Follow-Up.'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED PRESENT_SURFACE 'THE ACTIVE MVP SURFACE INCLUDES THE AUTHORIZED OUTCOME FOLLOW-UP.'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED PRESENT_SURFACE '(The active MVP surface includes the Authorized Outcome Follow-Up)!'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED PRESENT_SURFACE 'The current planning surface implements the follow-up projection.'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED PRESENT_SURFACE 'THE CURRENT PLANNING SURFACE IMPLEMENTS THE FOLLOW-UP PROJECTION.'
  add_g040_vector "$feature_dir" "$manifest" PASS CLASSIFIED ACCEPTED PRESENT_SURFACE '(The current planning surface implements the follow-up projection)!'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-present no
}

scenario_008() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-work.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-008"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-work)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'Defer this work.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'DEFER THIS WORK.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION '(Defer this work)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'Postpone this work.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'POSTPONE THIS WORK.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION '(Postpone this work)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'Skip this work.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'SKIP THIS WORK.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION '(Skip this work)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'Punt this work.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION 'PUNT THIS WORK.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING WORK_DISPOSITION '(Punt this work)!'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-work yes
}

scenario_009() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-schedule.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-009"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-schedule)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FUTURE_WORK_OR_SCOPE 'This is future work.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FUTURE_WORK_OR_SCOPE 'THIS IS FUTURE WORK.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FUTURE_WORK_OR_SCOPE '(This is future work)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FUTURE_WORK_OR_SCOPE 'This is future scope.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FUTURE_WORK_OR_SCOPE 'THIS IS FUTURE SCOPE.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FUTURE_WORK_OR_SCOPE '(This is future scope)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING NEXT_SPRINT_OR_ITERATION 'Move this to the next sprint.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING NEXT_SPRINT_OR_ITERATION 'MOVE THIS TO THE NEXT SPRINT.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING NEXT_SPRINT_OR_ITERATION '(Move this to the next sprint)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING NEXT_SPRINT_OR_ITERATION 'Move this to the next iteration.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING NEXT_SPRINT_OR_ITERATION 'MOVE THIS TO THE NEXT ITERATION.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING NEXT_SPRINT_OR_ITERATION '(Move this to the next iteration)!'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-schedule yes
}

scenario_010() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-later.tsv"
  CURRENT_SCENARIO="SCN-BUG-023-010"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-later)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP 'Fix this in a follow-up.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP 'FIX THIS IN A FOLLOW-UP.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP '(Fix this in a follow-up)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP 'Address this in a later follow-up.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP 'ADDRESS THIS IN A LATER FOLLOW-UP.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP '(Address this in a later follow-up)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'Fix this later.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'FIX THIS LATER.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER '(Fix this later)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'Address this later.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'ADDRESS THIS LATER.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER '(Address this later)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_IN_FOLLOW_UP 'Fix a b c d e f g in a b c d e follow-up.'
  add_g040_vector "$feature_dir" "$manifest" PASS NO_MATCH NONE NO_CONTRACT_MATCH 'Fix a b c d e f g h in follow-up.'
  add_g040_vector "$feature_dir" "$manifest" PASS NO_MATCH NONE NO_CONTRACT_MATCH 'Address this in a b c d e f follow-up.'
  add_g040_vector "$feature_dir" "$manifest" PASS NO_MATCH NONE NO_CONTRACT_MATCH 'Fix this; later.'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-later yes
}

scenario_011() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local manifest="$WORKSPACE/g040-precedence.tsv"
  local first_log=""
  local first_digest=""
  local second_digest=""
  CURRENT_SCENARIO="SCN-BUG-023-011"
  : > "$manifest"
  fixture="$(new_g040_matrix g040-precedence)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'Fix this later in the Authorized Outcome Follow-Up.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'FIX THIS LATER IN THE AUTHORIZED OUTCOME FOLLOW-UP.'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER '(Fix this later in the Authorized Outcome Follow-Up)!'
  add_g040_vector "$feature_dir" "$manifest" BLOCKED CLASSIFIED BLOCKING FIX_OR_ADDRESS_LATER 'followUpOwner: bubbles.test; Fix this later.'
  assert_g040_matrix "$repo" "$feature_dir" "$manifest" g040-precedence yes
  first_log="$RUN_LOG"
  first_digest="$(extract_result_field "$first_log" gateResultsDigest)"
  run_guard "$feature_dir" g040-precedence-repeat
  second_digest="$(extract_result_field "$RUN_LOG" gateResultsDigest)"
  if [[ -n "$first_digest" && "$first_digest" == "$second_digest" && "$first_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    pass_control 'same-line G040 precedence result has a stable complete-evidence digest'
  else
    causal_fail G040 "same-line G040 precedence digest is absent or unstable (first=${first_digest:-NONE} second=${second_digest:-NONE})"
  fi
}

baseline_result_field() {
  local log_file="$1"
  local field="$2"
  awk -v prefix="$field: " '
    $0 == "BEGIN PLANNING_SOURCE_BASELINE_RESULT_V1" { active=1; next }
    $0 == "END PLANNING_SOURCE_BASELINE_RESULT_V1" { exit }
    active && index($0, prefix) == 1 { print substr($0, length(prefix) + 1); exit }
  ' "$log_file"
}

run_baseline_capture() {
  local feature_dir="$1"
  local label="$2"
  shift 2
  RUN_LOG="$WORKSPACE/${label}.baseline.log"
  set +e
  bash "$BASELINE_HELPER" capture "$feature_dir" "$@" > "$RUN_LOG" 2>&1
  RUN_STATUS=$?
  set -e
  BASELINE_RUNS=$((BASELINE_RUNS + 1))
}

assert_baseline_result() {
  local log_file="$1"
  local process_status="$2"
  local expected_status="$3"
  local expected_reason="$4"
  local label="$5"
  local begin_count=""
  local end_count=""
  local observed_status=""
  local observed_reason=""
  local observed_exit=""
  begin_count="$(count_exact_line "$log_file" 'BEGIN PLANNING_SOURCE_BASELINE_RESULT_V1')"
  end_count="$(count_exact_line "$log_file" 'END PLANNING_SOURCE_BASELINE_RESULT_V1')"
  if [[ "$begin_count" -ne 1 || "$end_count" -ne 1 ]]; then
    causal_fail G073 "$label lacks exactly one PLANNING_SOURCE_BASELINE_RESULT_V1 block (begin=$begin_count end=$end_count process=$process_status)"
    return 1
  fi
  observed_status="$(baseline_result_field "$log_file" status)"
  observed_reason="$(baseline_result_field "$log_file" reasonCode)"
  observed_exit="$(baseline_result_field "$log_file" exitStatus)"
  if [[ "$observed_status" == "$expected_status" && "$observed_reason" == "$expected_reason" && "$observed_exit" == "$process_status" ]]; then
    pass_control "$label emits $expected_status/$expected_reason with matching exit status"
    return 0
  fi
  causal_fail G073 "$label expected $expected_status/$expected_reason/exit=$process_status, observed ${observed_status:-NONE}/${observed_reason:-NONE}/exit=${observed_exit:-NONE}"
  return 1
}

capture_must_succeed() {
  local feature_dir="$1"
  local label="$2"
  if [[ ! -f "$BASELINE_HELPER" && "$BASELINE_HELPER_ABSENCE_REPORTED" -eq 0 ]]; then
    causal_fail G073 'canonical authoritative helper is absent: bubbles/scripts/planning-source-baseline.sh'
    BASELINE_HELPER_ABSENCE_REPORTED=1
  fi
  run_baseline_capture "$feature_dir" "$label"
  if [[ "$RUN_STATUS" -ne 0 ]]; then
    assert_baseline_result "$RUN_LOG" "$RUN_STATUS" BASELINE_CAPTURED BASELINE_CAPTURED "$label" || true
    causal_fail G073 "$label authoritative capture did not succeed (process exit=$RUN_STATUS)"
    return 1
  fi
  assert_baseline_result "$RUN_LOG" "$RUN_STATUS" BASELINE_CAPTURED BASELINE_CAPTURED "$label" || return 1
  return 0
}

baseline_ref_field() {
  local state_file="$1"
  local field="$2"
  jq -r --arg field "$field" '.execution.planningSourceBaseline[$field] // ""' "$state_file"
}

baseline_sidecar_path() {
  local repo="$1"
  local state_file="$2"
  local artifact_ref=""
  artifact_ref="$(baseline_ref_field "$state_file" artifactRef)"
  printf '%s/%s\n' "$repo" "$artifact_ref"
}

validate_capture_contract() {
  local repo="$1"
  local feature_dir="$2"
  local capture_log="$3"
  local label="$4"
  local state_file="$feature_dir/state.json"
  local sidecar=""
  local payload=""
  local computed_digest=""
  local ref_digest=""
  local sidecar_digest=""
  local start_head=""
  local result_count=""
  local payload_count=""

  if ! jq -e '
    .execution.planningSourceBaseline.schemaVersion == "planning-source-baseline-ref/v1"
    and .execution.planningSourceBaseline.lifecycle == "ACTIVE"
    and (.execution.planningSourceBaseline.runId | test("^psb-[0-9a-f]{64}$"))
    and (.execution.planningSourceBaseline.payloadDigest | test("^sha256:[0-9a-f]{64}$"))
    and .execution.planningSourceBaseline.workflowMode == "product-to-planning"
    and .execution.planningSourceBaseline.auditProfile == "planning-maturity-v1"
  ' "$state_file" >/dev/null 2>&1; then
    causal_fail G073 "$label state.json lacks the complete ACTIVE planning-source-baseline-ref/v1 binding"
    return 1
  fi
  sidecar="$(baseline_sidecar_path "$repo" "$state_file")"
  if [[ ! -f "$sidecar" ]]; then
    causal_fail G073 "$label declared sidecar does not exist: ${sidecar#"$repo"/}"
    return 1
  fi
  if ! jq -e '.schemaVersion == "planning-source-baseline/v1" and (.payload.entries | type == "array")' "$sidecar" >/dev/null 2>&1; then
    causal_fail G073 "$label sidecar is not a planning-source-baseline/v1 payload"
    return 1
  fi
  payload="$(jq -cS '.payload' "$sidecar")"
  computed_digest="sha256:$(printf '%s' "$payload" | sha256_stdin)"
  ref_digest="$(baseline_ref_field "$state_file" payloadDigest)"
  sidecar_digest="$(jq -r '.payloadDigest // ""' "$sidecar")"
  if [[ "$computed_digest" == "$ref_digest" && "$computed_digest" == "$sidecar_digest" ]]; then
    pass_control "$label state reference and sidecar share the recomputed canonical payload digest"
  else
    causal_fail G073 "$label digest mismatch (computed=$computed_digest ref=$ref_digest sidecar=$sidecar_digest)"
  fi
  start_head="$(git -C "$repo" rev-parse --verify 'HEAD^{commit}')"
  if [[ "$(baseline_ref_field "$state_file" startHead)" == "$start_head" && "$(jq -r '.payload.startHead' "$sidecar")" == "$start_head" ]]; then
    pass_control "$label binds the full framework-resolved start HEAD"
  else
    causal_fail G073 "$label does not bind the capture-time HEAD"
  fi
  result_count="$(baseline_result_field "$capture_log" protectedEntryCount)"
  payload_count="$(jq -r '.payload.entries | length' "$sidecar")"
  if [[ "$result_count" == "$payload_count" ]]; then
    pass_control "$label result count equals the immutable payload entry count ($payload_count)"
  else
    causal_fail G073 "$label result count=$result_count differs from payload count=$payload_count"
  fi
  if grep -Fq -- "$repo" "$capture_log"; then
    causal_fail G073 "$label disclosed an absolute fixture repository path"
  else
    pass_control "$label capture result withholds absolute repository paths"
  fi
  return 0
}

assert_capture_argument_rejected() {
  local repo="$1"
  local feature_dir="$2"
  local label="$3"
  shift 3
  local state_hash=""
  local sidecar=""
  local sidecar_hash=""
  state_hash="$(sha256_file "$feature_dir/state.json")"
  sidecar="$(baseline_sidecar_path "$repo" "$feature_dir/state.json")"
  sidecar_hash="$(sha256_file "$sidecar")"
  run_baseline_capture "$feature_dir" "arg-$label" "$@"
  if [[ "$RUN_STATUS" -eq 2 ]]; then
    pass_control "caller-controlled baseline input '$label' is rejected with usage exit 2"
  else
    causal_fail G073 "caller-controlled baseline input '$label' was not rejected with exit 2 (exit=$RUN_STATUS)"
  fi
  assert_file_unchanged "$feature_dir/state.json" "$state_hash" "rejected '$label' input cannot mutate state"
  assert_file_unchanged "$sidecar" "$sidecar_hash" "rejected '$label' input cannot mutate sidecar"
}

scenario_012() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local first_log=""
  local state_file=""
  local sidecar=""
  local first_state_hash=""
  local first_sidecar_hash=""
  local first_run=""
  local first_digest=""
  local before_source=""
  CURRENT_SCENARIO="SCN-BUG-023-012"
  fixture="$(new_fixture_repo baseline-capture product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  before_source="$(path_state_digest "$repo" 'src/staged file.rs' 'src/link.rs')"

  if ! capture_must_succeed "$feature_dir" baseline-capture-first; then
    causal_fail G073 'baseline_capture_precedes_writes cannot exercise payload/ref/reuse controls until the canonical helper exists and captures successfully'
    return
  fi
  first_log="$RUN_LOG"
  validate_capture_contract "$repo" "$feature_dir" "$first_log" baseline-capture-first || true
  state_file="$feature_dir/state.json"
  sidecar="$(baseline_sidecar_path "$repo" "$state_file")"
  first_state_hash="$(sha256_file "$state_file")"
  first_sidecar_hash="$(sha256_file "$sidecar")"
  first_run="$(baseline_ref_field "$state_file" runId)"
  first_digest="$(baseline_ref_field "$state_file" payloadDigest)"

  run_baseline_capture "$feature_dir" baseline-capture-reuse
  if [[ "$RUN_STATUS" -eq 0 ]]; then
    assert_baseline_result "$RUN_LOG" "$RUN_STATUS" BASELINE_REUSED BASELINE_REUSED baseline-capture-reuse || true
  else
    causal_fail G073 "baseline-capture-reuse returned exit=$RUN_STATUS"
  fi
  if [[ "$(baseline_ref_field "$state_file" runId)" == "$first_run" \
    && "$(baseline_ref_field "$state_file" payloadDigest)" == "$first_digest" ]]; then
    pass_control 'repeated capture reuses the original run and payload digest'
  else
    causal_fail G073 'repeated capture replaced the original run or payload digest'
  fi
  assert_file_unchanged "$state_file" "$first_state_hash" 'BASELINE_REUSED preserves exact state reference bytes'
  assert_file_unchanged "$sidecar" "$first_sidecar_hash" 'BASELINE_REUSED preserves exact sidecar bytes'
  assert_path_state_unchanged "$repo" "$before_source" 'capture and reuse do not mutate protected source paths' 'src/staged file.rs' 'src/link.rs'

  assert_capture_argument_rejected "$repo" "$feature_dir" run-id --run-id attacker
  assert_capture_argument_rejected "$repo" "$feature_dir" head --head HEAD
  assert_capture_argument_rejected "$repo" "$feature_dir" observed-path --observed-path src/owned.rs
  assert_capture_argument_rejected "$repo" "$feature_dir" unsafe-path --observed-path ../escape.rs
  assert_capture_argument_rejected "$repo" "$feature_dir" absolute-path --observed-path /tmp/escape.rs
  assert_capture_argument_rejected "$repo" "$feature_dir" include --include 'src/**'
  assert_capture_argument_rejected "$repo" "$feature_dir" exclude --exclude 'src/.*'
  assert_capture_argument_rejected "$repo" "$feature_dir" path-list --paths src/
  assert_capture_argument_rejected "$repo" "$feature_dir" recapture --recapture
  assert_capture_argument_rejected "$repo" "$feature_dir" skip --skip
  assert_capture_argument_rejected "$repo" "$feature_dir" force --force
  assert_capture_argument_rejected "$repo" "$feature_dir" ignore --ignore
}

prepare_baseline_state() {
  local repo="$1"
  local state_class="$2"
  case "$state_class" in
    STAGED_ONLY)
      printf '%s\n' 'staged before capture' > "$repo/src/staged file.rs"
      chmod +x "$repo/src/staged file.rs"
      git -C "$repo" add -- 'src/staged file.rs' || harness_die 'cannot stage STAGED_ONLY fixture'
      printf '%s\n' 'src/staged file.rs'
      ;;
    UNSTAGED_ONLY)
      printf '%s\n' 'unstaged before capture' > "$repo/src/unstaged.rs"
      printf '%s\n' 'src/unstaged.rs'
      ;;
    MIXED_STAGED_UNSTAGED)
      printf '%s\n' 'mixed index before capture' > "$repo/src/mixed.rs"
      git -C "$repo" add -- src/mixed.rs || harness_die 'cannot stage mixed fixture'
      printf '%s\n' 'mixed worktree before capture' > "$repo/src/mixed.rs"
      printf '%s\n' 'src/mixed.rs'
      ;;
    UNTRACKED)
      printf '%s\n' 'untracked before capture' > "$repo/src/untracked.rs"
      printf '%s\n' 'src/untracked.rs'
      ;;
    RENAME)
      git -C "$repo" mv -- 'src/rename old.rs' 'src/rename new.rs' || harness_die 'cannot stage rename fixture'
      printf '%s\n' 'src/rename new.rs'
      ;;
    DELETE)
      git -C "$repo" rm -q -- src/delete.rs || harness_die 'cannot stage delete fixture'
      printf '%s\n' 'src/delete.rs'
      ;;
    *)
      harness_die "unknown baseline state class: $state_class"
      ;;
  esac
}

assert_g073_detail() {
  local log_file="$1"
  local expected_status="$2"
  local expected_outcome="$3"
  local expected_reason="$4"
  local protected_path="$5"
  local state_class="$6"
  local actionability="$7"
  local label="$8"
  local count="0"
  if ! load_v2_result "$log_file" G073 "$label"; then
    causal_fail G073 "$label cannot prove outcome=$expected_outcome reason=$expected_reason path=$protected_path"
    return
  fi
  count="$(v2_detail_count G073 "$expected_status" ANY "$expected_outcome" "$expected_reason" ANY 0 ANY "$protected_path" "$state_class" "$actionability")"
  if [[ "$count" -ge 1 ]]; then
    pass_control "$label emits G073 $expected_outcome/$expected_reason for $protected_path"
  else
    causal_fail G073 "$label expected G073 $expected_status/$expected_outcome/$expected_reason path=$protected_path state=$state_class"
  fi
}

run_equal_state_case() {
  local state_class="$1"
  local case_name="$2"
  local fixture=""
  local repo=""
  local feature_dir=""
  local protected_path=""
  local before=""
  fixture="$(new_fixture_repo "$case_name" product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  protected_path="$(prepare_baseline_state "$repo" "$state_class")"
  if [[ "$state_class" == "RENAME" ]]; then
    before="$(path_state_digest "$repo" 'src/rename old.rs' 'src/rename new.rs')"
  else
    before="$(path_state_digest "$repo" "$protected_path")"
  fi
  if ! capture_must_succeed "$feature_dir" "$case_name-capture"; then
    causal_fail G073 "$case_name cannot prove audited equality for $state_class because capture failed"
    return
  fi
  run_guard "$feature_dir" "$case_name-guard"
  assert_guard_reached "$RUN_LOG" '--- Check 3B: Source Code Edit Lockout (Gate G073) ---' "$case_name reaches canonical G073"
  assert_g073_detail "$RUN_LOG" PASS AUDITED_PREEXISTING PATH_AUDITED_EQUAL "$protected_path" "$state_class" NON_ACTIONABLE "$case_name"
  if [[ "$state_class" == "RENAME" ]]; then
    assert_path_state_unchanged "$repo" "$before" "$case_name preserves both rename endpoints" 'src/rename old.rs' 'src/rename new.rs'
  else
    assert_path_state_unchanged "$repo" "$before" "$case_name preserves exact protected state" "$protected_path"
  fi
}

scenario_013() {
  CURRENT_SCENARIO="SCN-BUG-023-013"
  run_equal_state_case STAGED_ONLY equal-staged
  run_equal_state_case UNSTAGED_ONLY equal-unstaged
  run_equal_state_case MIXED_STAGED_UNSTAGED equal-mixed
  run_equal_state_case UNTRACKED equal-untracked
  run_equal_state_case RENAME equal-rename
  run_equal_state_case DELETE equal-delete
}

prepare_mutation_baseline() {
  local repo="$1"
  local mutation="$2"
  case "$mutation" in
    appeared|committed)
      printf '%s\n' 'src/appeared.rs'
      ;;
    index)
      printf '%s\n' 'index baseline' > "$repo/src/staged file.rs"
      git -C "$repo" add -- 'src/staged file.rs' || harness_die 'cannot stage index baseline'
      printf '%s\n' 'src/staged file.rs'
      ;;
    worktree)
      printf '%s\n' 'worktree baseline' > "$repo/src/unstaged.rs"
      printf '%s\n' 'src/unstaged.rs'
      ;;
    mode)
      chmod +x "$repo/src/mode.rs"
      printf '%s\n' 'src/mode.rs'
      ;;
    type)
      printf '%s\n' 'regular untracked baseline' > "$repo/src/type-transition.rs"
      printf '%s\n' 'src/type-transition.rs'
      ;;
    clean)
      printf '%s\n' 'dirty before capture' > "$repo/src/unstaged.rs"
      printf '%s\n' 'src/unstaged.rs'
      ;;
    rename)
      git -C "$repo" mv -- 'src/rename old.rs' 'src/rename middle.rs' || harness_die 'cannot prepare rename baseline'
      printf '%s\n' 'src/rename middle.rs'
      ;;
    delete)
      git -C "$repo" rm -q -- src/delete.rs || harness_die 'cannot prepare deletion baseline'
      printf '%s\n' 'src/delete.rs'
      ;;
    symlink)
      rm -f "$repo/src/link.rs"
      ln -s 'target-b.txt' "$repo/src/link.rs" || harness_die 'cannot prepare symlink baseline'
      printf '%s\n' 'src/link.rs'
      ;;
    *)
      harness_die "unknown mutation baseline: $mutation"
      ;;
  esac
}

apply_post_capture_mutation() {
  local repo="$1"
  local mutation="$2"
  case "$mutation" in
    appeared)
      printf '%s\n' 'appeared after capture' > "$repo/src/appeared.rs"
      ;;
    index)
      printf '%s\n' 'index changed after capture' > "$repo/src/staged file.rs"
      git -C "$repo" add -- 'src/staged file.rs' || harness_die 'cannot mutate index identity'
      ;;
    worktree)
      printf '%s\n' 'worktree changed after capture' > "$repo/src/unstaged.rs"
      ;;
    mode)
      chmod -x "$repo/src/mode.rs"
      ;;
    type)
      rm -f "$repo/src/type-transition.rs"
      ln -s 'target-a.txt' "$repo/src/type-transition.rs" || harness_die 'cannot mutate file to symlink'
      ;;
    clean)
      printf '%s\n' 'seed unstaged' > "$repo/src/unstaged.rs"
      ;;
    rename)
      git -C "$repo" mv -- 'src/rename middle.rs' 'src/rename final.rs' || harness_die 'cannot mutate rename endpoint'
      ;;
    delete)
      printf '%s\n' 'recreated after captured deletion' > "$repo/src/delete.rs"
      ;;
    committed)
      printf '%s\n' 'committed after capture' > "$repo/src/appeared.rs"
      git -C "$repo" add -- src/appeared.rs || harness_die 'cannot stage committed mutation'
      git -C "$repo" commit -q -m 'test: protected post-start commit' || harness_die 'cannot commit post-start mutation'
      ;;
    symlink)
      rm -f "$repo/src/link.rs"
      ln -s 'target-a.txt' "$repo/src/link.rs" || harness_die 'cannot mutate symlink target'
      ;;
    *)
      harness_die "unknown post-capture mutation: $mutation"
      ;;
  esac
}

run_mutation_case() {
  local mutation="$1"
  local expected_reason="$2"
  local expected_state="$3"
  local case_name="mutation-$mutation"
  local fixture=""
  local repo=""
  local feature_dir=""
  local protected_path=""
  local before_guard=""
  fixture="$(new_fixture_repo "$case_name" product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  protected_path="$(prepare_mutation_baseline "$repo" "$mutation")"
  if ! capture_must_succeed "$feature_dir" "$case_name-capture"; then
    causal_fail G073 "$case_name cannot prove $expected_reason because capture failed"
    return
  fi
  apply_post_capture_mutation "$repo" "$mutation"
  case "$mutation" in
    rename)
      before_guard="$(path_state_digest "$repo" 'src/rename old.rs' 'src/rename middle.rs' 'src/rename final.rs')"
      protected_path='src/rename final.rs'
      ;;
    *)
      before_guard="$(path_state_digest "$repo" "$protected_path")"
      ;;
  esac
  run_guard "$feature_dir" "$case_name-guard"
  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass_control "$case_name remains blocking"
  else
    control_fail "$case_name unexpectedly returned zero"
  fi
  assert_g073_detail "$RUN_LOG" BLOCKED NEW_OR_CHANGED "$expected_reason" "$protected_path" "$expected_state" ACTION_REQUIRED "$case_name"
  case "$mutation" in
    rename)
      assert_path_state_unchanged "$repo" "$before_guard" "$case_name guard preserves rename mutation" 'src/rename old.rs' 'src/rename middle.rs' 'src/rename final.rs'
      ;;
    *)
      assert_path_state_unchanged "$repo" "$before_guard" "$case_name guard preserves protected mutation" "$protected_path"
      ;;
  esac
}

scenario_014() {
  CURRENT_SCENARIO="SCN-BUG-023-014"
  run_mutation_case appeared PATH_APPEARED_AFTER_CAPTURE UNTRACKED
  run_mutation_case index PATH_INDEX_IDENTITY_CHANGED STAGED_ONLY
  run_mutation_case worktree PATH_CONTENT_DIGEST_CHANGED UNSTAGED_ONLY
  run_mutation_case mode PATH_MODE_CHANGED UNSTAGED_ONLY
  run_mutation_case type PATH_TYPE_CHANGED UNTRACKED
  run_mutation_case clean PATH_BECAME_CLEAN UNSTAGED_ONLY
  run_mutation_case rename PATH_RENAME_ENDPOINT_CHANGED RENAME
  run_mutation_case delete PATH_DELETION_STATE_CHANGED DELETE
  run_mutation_case committed PATH_COMMITTED_AFTER_START_HEAD UNTRACKED
  run_mutation_case symlink PATH_CONTENT_DIGEST_CHANGED UNSTAGED_ONLY
  run_compare_race_case
}

jq_replace_file() {
  local file="$1"
  local filter="$2"
  shift 2
  local temporary="$file.bug023-tmp"
  if ! jq "$@" "$filter" "$file" > "$temporary"; then
    rm -f "$temporary"
    harness_die "jq mutation failed for ${file#"$WORKSPACE"/}: $filter"
  fi
  mv "$temporary" "$file"
}

refresh_payload_digest() {
  local feature_dir="$1"
  local sidecar="$2"
  local payload=""
  local digest=""
  payload="$(jq -cS '.payload' "$sidecar")"
  digest="sha256:$(printf '%s' "$payload" | sha256_stdin)"
  jq_replace_file "$sidecar" '.payloadDigest = $digest' --arg digest "$digest"
  jq_replace_file "$feature_dir/state.json" '.execution.planningSourceBaseline.payloadDigest = $digest' --arg digest "$digest"
}

mutate_binding_both() {
  local feature_dir="$1"
  local sidecar="$2"
  local field="$3"
  local value="$4"
  jq_replace_file "$sidecar" '.payload[$field] = $value' --arg field "$field" --arg value "$value"
  jq_replace_file "$feature_dir/state.json" '.execution.planningSourceBaseline[$field] = $value' --arg field "$field" --arg value "$value"
  refresh_payload_digest "$feature_dir" "$sidecar"
}

apply_invalid_mutation() {
  local repo="$1"
  local feature_dir="$2"
  local sidecar="$3"
  local mutation="$4"
  local long_path=""
  case "$mutation" in
    unreadable)
      chmod 000 "$sidecar"
      ;;
    malformed-json)
      printf '%s\n' '{not-json' > "$sidecar"
      ;;
    unsupported-schema)
      jq_replace_file "$sidecar" '.schemaVersion = "planning-source-baseline/v999"'
      ;;
    missing-field)
      jq_replace_file "$sidecar" 'del(.payload.capturedAt)'
      ;;
    duplicate-path)
      jq_replace_file "$sidecar" '.payload.entries += [.payload.entries[0]]'
      ;;
    unsafe-absolute)
      jq_replace_file "$sidecar" '.payload.entries[0].path = "/absolute.rs"'
      ;;
    unsafe-traversal)
      jq_replace_file "$sidecar" '.payload.entries[0].path = "../traversal.rs"'
      ;;
    unsafe-control)
      jq_replace_file "$sidecar" '.payload.entries[0].path = $path' --arg path $'src/control\t.rs'
      ;;
    unsafe-glob)
      jq_replace_file "$sidecar" '.payload.entries[0].path = "src/*.rs"'
      ;;
    unsafe-regex)
      jq_replace_file "$sidecar" '.payload.entries[0].path = "src/[x].rs"'
      ;;
    unsafe-prefix)
      jq_replace_file "$sidecar" '.payload.entries[0].path = "src/"'
      ;;
    unsafe-overlong)
      long_path="src/$(awk 'BEGIN { for (i=0; i<4100; i++) printf "a" }').rs"
      jq_replace_file "$sidecar" '.payload.entries[0].path = $path' --arg path "$long_path"
      ;;
    unsupported-status)
      jq_replace_file "$sidecar" '.payload.entries[0].indexStatus = "Z"'
      ;;
    unsupported-type)
      jq_replace_file "$sidecar" '.payload.entries[0].worktree.kind = "FIFO"'
      ;;
    invalid-identity)
      jq_replace_file "$sidecar" 'del(.payload.entries[0].worktree.contentDigest)'
      ;;
    missing-digest)
      jq_replace_file "$sidecar" 'del(.payloadDigest)'
      ;;
    malformed-digest)
      jq_replace_file "$sidecar" '.payloadDigest = "sha256:bad"'
      jq_replace_file "$feature_dir/state.json" '.execution.planningSourceBaseline.payloadDigest = "sha256:bad"'
      ;;
    digest-mismatch)
      jq_replace_file "$sidecar" '.payload.captureTargetRevision = "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"'
      ;;
    missing-sidecar)
      rm -f "$sidecar"
      ;;
    spec-binding)
      mutate_binding_both "$feature_dir" "$sidecar" featureDir 'specs/999-other'
      ;;
    mode-binding)
      mutate_binding_both "$feature_dir" "$sidecar" workflowMode full-delivery
      ;;
    profile-binding)
      mutate_binding_both "$feature_dir" "$sidecar" auditProfile delivery-completion-v1
      ;;
    repository-binding)
      mutate_binding_both "$feature_dir" "$sidecar" repositoryId 'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      ;;
    run-binding)
      mutate_binding_both "$feature_dir" "$sidecar" runId 'psb-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      ;;
    head-binding)
      mutate_binding_both "$feature_dir" "$sidecar" startHead "$(git -C "$repo" rev-parse HEAD~1)"
      ;;
    transition-binding)
      mutate_binding_both "$feature_dir" "$sidecar" transitionContractDigest 'sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
      ;;
    unresolved-head)
      mutate_binding_both "$feature_dir" "$sidecar" startHead 'ffffffffffffffffffffffffffffffffffffffff'
      ;;
    ref-null)
      jq_replace_file "$feature_dir/state.json" '.execution.planningSourceBaseline = null'
      ;;
    ref-empty)
      jq_replace_file "$feature_dir/state.json" '.execution.planningSourceBaseline = ""'
      ;;
    ref-partial)
      jq_replace_file "$feature_dir/state.json" '.execution.planningSourceBaseline = {"schemaVersion":"planning-source-baseline-ref/v1"}'
      ;;
    *)
      harness_die "unknown invalid provenance mutation: $mutation"
      ;;
  esac
}

run_invalid_case() {
  local mutation="$1"
  local expected_reason="$2"
  local case_name="invalid-$mutation"
  local fixture=""
  local repo=""
  local feature_dir=""
  local state_file=""
  local sidecar=""
  local state_hash=""
  local sidecar_hash="ABSENT"
  local count="0"
  fixture="$(new_fixture_repo "$case_name" product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  printf '%s\n' 'invalid provenance seed' > "$repo/src/provenance.rs"
  if ! capture_must_succeed "$feature_dir" "$case_name-capture"; then
    causal_fail G073 "$case_name cannot exercise $expected_reason because valid setup capture failed"
    return
  fi
  state_file="$feature_dir/state.json"
  sidecar="$(baseline_sidecar_path "$repo" "$state_file")"
  apply_invalid_mutation "$repo" "$feature_dir" "$sidecar" "$mutation"
  state_hash="$(sha256_file "$state_file")"
  if [[ -f "$sidecar" ]]; then
    sidecar_hash="$(sha256_file "$sidecar")"
  fi
  run_guard "$feature_dir" "$case_name-guard"
  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass_control "$case_name invalid provenance remains blocking"
  else
    control_fail "$case_name invalid provenance returned zero"
  fi
  if load_v2_result "$RUN_LOG" G073 "$case_name"; then
    count="$(printf '%s' "$V2_GATE_RESULTS" | jq -r --arg reason "$expected_reason" '[.. | objects | select(.gateId? == "G073" and .status? == "BLOCKED" and .outcome? == "INVALID_BASELINE" and .reasonCode? == $reason and .actionability? == "ACTION_REQUIRED" and ((.observed? // "") | contains("exclusionsApplied=0")))] | length')"
    if [[ "$count" -ge 1 ]]; then
      pass_control "$case_name emits INVALID_BASELINE/$expected_reason with exclusionsApplied=0"
    else
      causal_fail G073 "$case_name expected INVALID_BASELINE/$expected_reason with exclusionsApplied=0"
    fi
    if printf '%s' "$V2_GATE_RESULTS" | jq -e '[.. | objects | select(.gateId? == "G073" and .reasonCode? == "PATH_AUDITED_EQUAL")] | length == 0' >/dev/null; then
      pass_control "$case_name applies zero audited exclusions"
    else
      causal_fail G073 "$case_name emitted an audited exclusion from invalid provenance"
    fi
  else
    causal_fail G073 "$case_name cannot prove exact invalid-provenance reason $expected_reason without V2"
  fi
  assert_file_unchanged "$state_file" "$state_hash" "$case_name guard performs no provenance repair"
  if [[ "$sidecar_hash" == "ABSENT" ]]; then
    if [[ ! -e "$sidecar" ]]; then
      pass_control "$case_name guard does not synthesize a missing sidecar"
    else
      harness_fail "$case_name guard synthesized a missing sidecar"
    fi
  else
    assert_file_unchanged "$sidecar" "$sidecar_hash" "$case_name guard does not rewrite invalid sidecar bytes"
  fi
}

run_divergent_head_case() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local count="0"
  fixture="$(new_fixture_repo invalid-divergent-head product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  if ! capture_must_succeed "$feature_dir" divergent-head-capture; then
    causal_fail G073 'divergent-head control cannot run because capture failed'
    return
  fi
  git -C "$repo" checkout -q --orphan divergent || harness_die 'cannot create divergent fixture branch'
  git -C "$repo" add -A || harness_die 'cannot stage divergent fixture branch'
  git -C "$repo" commit -q -m 'test: divergent history' || harness_die 'cannot commit divergent fixture branch'
  run_guard "$feature_dir" divergent-head-guard
  if load_v2_result "$RUN_LOG" G073 divergent-head; then
    count="$(printf '%s' "$V2_GATE_RESULTS" | jq -r '[.. | objects | select(.gateId? == "G073" and .outcome? == "INVALID_BASELINE" and .reasonCode? == "BASELINE_START_HEAD_BINDING_MISMATCH")] | length')"
    if [[ "$count" -ge 1 ]]; then
      pass_control 'divergent current HEAD blocks with BASELINE_START_HEAD_BINDING_MISMATCH'
    else
      causal_fail G073 'divergent current HEAD did not emit BASELINE_START_HEAD_BINDING_MISMATCH'
    fi
  else
    causal_fail G073 'divergent current HEAD lacks V2 invalid-baseline evidence'
  fi
}

run_capture_race_case() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local flag=""
  local writer_pid=""
  local index=0
  local count=0
  fixture="$(new_fixture_repo capture-race product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  while [[ "$index" -lt 300 ]]; do
    printf 'race seed %s\n' "$index" > "$repo/src/race-$index.rs"
    index=$((index + 1))
  done
  flag="$repo/.race-active"
  printf '%s\n' active > "$flag"
  (
    local_counter=0
    while [[ -e "$flag" ]]; do
      local_counter=$((local_counter + 1))
      printf 'moving %s\n' "$local_counter" > "$repo/src/race-0.rs"
    done
  ) &
  writer_pid=$!
  run_baseline_capture "$feature_dir" capture-race-active
  rm -f "$flag"
  wait "$writer_pid" 2>/dev/null || true
  if [[ "$RUN_STATUS" -eq 1 ]] && count_exact_line "$RUN_LOG" 'BEGIN PLANNING_SOURCE_BASELINE_RESULT_V1' >/dev/null; then
    count="$(grep -Ec 'BASELINE_ENTRY_IDENTITY_INVALID|BASELINE_START_HEAD_BINDING_MISMATCH' "$RUN_LOG" || true)"
    if [[ "$count" -ge 1 ]]; then
      pass_control 'capture race blocks with a closed baseline identity/binding reason'
    else
      causal_fail G073 'capture race blocked without a closed identity/binding reason'
    fi
  else
    causal_fail G073 "capture race was not rejected as provenance instability (exit=$RUN_STATUS)"
  fi
  if jq -e '.execution | has("planningSourceBaseline")' "$feature_dir/state.json" >/dev/null 2>&1; then
    causal_fail G073 'capture race left a trusted baseline reference in state.json'
  else
    pass_control 'capture race leaves no trusted baseline reference'
  fi
}

run_compare_race_case() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local flag=""
  local writer_pid=""
  local index=0
  local count=0
  fixture="$(new_fixture_repo compare-race product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  while [[ "$index" -lt 300 ]]; do
    printf 'compare race seed %s\n' "$index" > "$repo/src/compare-race-$index.rs"
    index=$((index + 1))
  done
  if ! capture_must_succeed "$feature_dir" compare-race-capture; then
    causal_fail G073 'compare-race control cannot run because capture failed'
    return
  fi
  flag="$repo/.compare-race-active"
  printf '%s\n' active > "$flag"
  (
    local_counter=0
    while [[ -e "$flag" ]]; do
      local_counter=$((local_counter + 1))
      printf 'compare moving %s\n' "$local_counter" > "$repo/src/compare-race-0.rs"
    done
  ) &
  writer_pid=$!
  run_guard "$feature_dir" compare-race-guard
  rm -f "$flag"
  wait "$writer_pid" 2>/dev/null || true
  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass_control 'compare race remains blocking'
  else
    control_fail 'compare race unexpectedly returned zero'
  fi
  if load_v2_result "$RUN_LOG" G073 compare-race; then
    count="$(printf '%s' "$V2_GATE_RESULTS" | jq -r '[.. | objects | select(.gateId? == "G073" and .status? == "BLOCKED" and .outcome? == "INVALID_BASELINE" and (.reasonCode? == "BASELINE_ENTRY_IDENTITY_INVALID" or .reasonCode? == "BASELINE_START_HEAD_BINDING_MISMATCH") and ((.observed? // "") | contains("exclusionsApplied=0")))] | length')"
    if [[ "$count" -ge 1 ]]; then
      pass_control 'compare race fails closed as invalid provenance with zero exclusions'
    else
      causal_fail G073 'compare race did not emit INVALID_BASELINE with a closed identity/binding reason and exclusionsApplied=0'
    fi
  else
    causal_fail G073 'compare race lacks V2 invalid-baseline evidence'
  fi
}

run_consumer_mutation_canary() {
  local log_file="$WORKSPACE/audit-result-selftest.log"
  local exit_code=0
  local token=""
  set +e
  bash "$AUDIT_RESULT_SELFTEST" > "$log_file" 2>&1
  exit_code=$?
  set -e
  if [[ "$exit_code" -eq 0 ]]; then
    pass_control 'canonical audit-result consumer selftest remains green'
  else
    control_fail "canonical audit-result consumer selftest failed (exit=$exit_code)"
  fi
  for token in \
    'transition-guard-result/v2' \
    'reordered V2 field' \
    'noncanonical gateResults' \
    'gateResultsDigest mismatch' \
    'planning G060 pass rejected' \
    'delivery G060 N/A rejected' \
    'audited G073 actionable rejected' \
    'failed G073 blockingCode rejected'; do
    if grep -Fq -- "$token" "$log_file"; then
      pass_control "audit-result consumer covers: $token"
    else
      causal_fail G073 "audit-result consumer selftest lacks required mutation control: $token"
    fi
  done
}

scenario_015() {
  CURRENT_SCENARIO="SCN-BUG-023-015"
  run_invalid_case unreadable BASELINE_PAYLOAD_UNREADABLE
  run_invalid_case malformed-json BASELINE_PAYLOAD_MALFORMED
  run_invalid_case unsupported-schema BASELINE_SCHEMA_UNSUPPORTED
  run_invalid_case missing-field BASELINE_REQUIRED_FIELD_MISSING
  run_invalid_case duplicate-path BASELINE_PATH_DUPLICATE
  run_invalid_case unsafe-absolute BASELINE_PATH_UNSAFE
  run_invalid_case unsafe-traversal BASELINE_PATH_UNSAFE
  run_invalid_case unsafe-control BASELINE_PATH_UNSAFE
  run_invalid_case unsafe-glob BASELINE_PATH_UNSAFE
  run_invalid_case unsafe-regex BASELINE_PATH_UNSAFE
  run_invalid_case unsafe-prefix BASELINE_PATH_UNSAFE
  run_invalid_case unsafe-overlong BASELINE_PATH_UNSAFE
  run_invalid_case unsupported-status BASELINE_STATUS_UNSUPPORTED
  run_invalid_case unsupported-type BASELINE_TYPE_UNSUPPORTED
  run_invalid_case invalid-identity BASELINE_ENTRY_IDENTITY_INVALID
  run_invalid_case missing-digest BASELINE_DIGEST_MISSING_OR_INVALID
  run_invalid_case malformed-digest BASELINE_DIGEST_MISSING_OR_INVALID
  run_invalid_case digest-mismatch BASELINE_DIGEST_MISMATCH
  run_invalid_case missing-sidecar BASELINE_SIDECAR_MISSING
  run_invalid_case spec-binding BASELINE_SPEC_BINDING_MISMATCH
  run_invalid_case mode-binding BASELINE_MODE_BINDING_MISMATCH
  run_invalid_case profile-binding BASELINE_PROFILE_BINDING_MISMATCH
  run_invalid_case repository-binding BASELINE_REPOSITORY_BINDING_MISMATCH
  run_invalid_case run-binding BASELINE_RUN_BINDING_MISMATCH
  run_invalid_case head-binding BASELINE_START_HEAD_BINDING_MISMATCH
  run_invalid_case transition-binding BASELINE_TRANSITION_BINDING_MISMATCH
  run_invalid_case unresolved-head BASELINE_START_HEAD_UNRESOLVED
  run_invalid_case ref-null BASELINE_REQUIRED_FIELD_MISSING
  run_invalid_case ref-empty BASELINE_REQUIRED_FIELD_MISSING
  run_invalid_case ref-partial BASELINE_REQUIRED_FIELD_MISSING
  run_divergent_head_case
  run_capture_race_case
  run_consumer_mutation_canary
}

scenario_016() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local state_file=""
  local sidecar=""
  local original_run=""
  local original_ref=""
  local original_digest=""
  local original_sidecar_hash=""
  local before_guard=""
  CURRENT_SCENARIO="SCN-BUG-023-016"
  fixture="$(new_fixture_repo baseline-retry product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  printf '%s\n' 'dirty before initial capture' > "$repo/src/unstaged.rs"
  if ! capture_must_succeed "$feature_dir" baseline-retry-first; then
    causal_fail G073 'baseline_retry_reuses_original cannot run because initial capture failed'
    return
  fi
  state_file="$feature_dir/state.json"
  sidecar="$(baseline_sidecar_path "$repo" "$state_file")"
  original_run="$(baseline_ref_field "$state_file" runId)"
  original_ref="$(baseline_ref_field "$state_file" artifactRef)"
  original_digest="$(baseline_ref_field "$state_file" payloadDigest)"
  original_sidecar_hash="$(sha256_file "$sidecar")"

  printf '%s\n' 'changed after initial capture' > "$repo/src/unstaged.rs"
  run_baseline_capture "$feature_dir" baseline-retry-resume
  if [[ "$RUN_STATUS" -eq 0 ]]; then
    assert_baseline_result "$RUN_LOG" "$RUN_STATUS" BASELINE_REUSED BASELINE_REUSED baseline-retry-resume || true
  else
    causal_fail G073 "baseline retry did not reuse active run (exit=$RUN_STATUS)"
  fi
  if [[ "$(baseline_ref_field "$state_file" runId)" == "$original_run" \
    && "$(baseline_ref_field "$state_file" artifactRef)" == "$original_ref" \
    && "$(baseline_ref_field "$state_file" payloadDigest)" == "$original_digest" ]]; then
    pass_control 'resume/retry preserves the original run, reference, and payload digest'
  else
    causal_fail G073 'resume/retry replaced an original baseline binding'
  fi
  assert_file_unchanged "$sidecar" "$original_sidecar_hash" 'resume/retry preserves original sidecar bytes'
  before_guard="$(path_state_digest "$repo" src/unstaged.rs)"
  run_guard "$feature_dir" baseline-retry-guard
  assert_g073_detail "$RUN_LOG" BLOCKED NEW_OR_CHANGED PATH_CONTENT_DIGEST_CHANGED src/unstaged.rs UNSTAGED_ONLY ACTION_REQUIRED baseline-retry-guard
  assert_path_state_unchanged "$repo" "$before_guard" 'retry guard preserves post-start protected dirt' src/unstaged.rs
  assert_file_unchanged "$sidecar" "$original_sidecar_hash" 'retry guard cannot recapture or amend the original sidecar'
}

scenario_017() {
  local fixture=""
  local repo=""
  local feature_dir=""
  local before=""
  local count="0"
  CURRENT_SCENARIO="SCN-BUG-023-017"
  fixture="$(new_fixture_repo legacy-lockout product-to-planning off)"
  repo="${fixture%%$'\t'*}"
  feature_dir="${fixture#*$'\t'}"
  printf '%s\n' 'legacy dirty path' > "$repo/src/unstaged.rs"
  before="$(path_state_digest "$repo" src/unstaged.rs)"
  if jq -e '.execution | has("planningSourceBaseline")' "$feature_dir/state.json" >/dev/null 2>&1; then
    harness_fail 'legacy fixture unexpectedly declares a baseline before guard invocation'
  else
    pass_control 'legacy fixture has complete baseline-key absence'
  fi
  run_guard "$feature_dir" legacy-lockout-guard
  assert_guard_reached "$RUN_LOG" '--- Check 3B: Source Code Edit Lockout (Gate G073) ---' 'legacy fixture reaches canonical Check 3B'
  if [[ "$RUN_STATUS" -ne 0 ]] && grep -Fq "working tree file modified: src/unstaged.rs" "$RUN_LOG"; then
    pass_control 'legacy whole-worktree lockout remains blocking under current semantics'
  elif grep -Fq '[G073] LEGACY_NO_BASELINE' "$RUN_LOG"; then
    pass_control 'legacy whole-worktree lockout emits the explicit new legacy result'
  else
    control_fail "legacy whole-worktree lockout did not identify src/unstaged.rs (exit=$RUN_STATUS)"
  fi
  if load_v2_result "$RUN_LOG" G073 legacy-lockout; then
    count="$(printf '%s' "$V2_GATE_RESULTS" | jq -r '[.. | objects | select(.gateId? == "G073" and .status? == "BLOCKED" and .outcome? == "LEGACY_NO_BASELINE" and .reasonCode? == "LEGACY_DIRT_UNPROVEN" and .actionability? == "ACTION_REQUIRED" and .evidenceIdentity.protectedPath? == "src/unstaged.rs")] | length')"
    if [[ "$count" -ge 1 ]]; then
      pass_control 'legacy dirty path emits LEGACY_NO_BASELINE/LEGACY_DIRT_UNPROVEN'
    else
      causal_fail G073 'legacy dirty path lacks explicit LEGACY_DIRT_UNPROVEN detail for src/unstaged.rs'
    fi
  else
    causal_fail G073 'legacy dirty path lacks the V2 LEGACY_NO_BASELINE result'
  fi
  if jq -e '.execution | has("planningSourceBaseline")' "$feature_dir/state.json" >/dev/null 2>&1; then
    causal_fail G073 'legacy guard synthesized a baseline declaration'
  else
    pass_control 'legacy guard synthesizes no baseline declaration'
  fi
  assert_path_state_unchanged "$repo" "$before" 'legacy lockout does not mutate protected dirt' src/unstaged.rs
}

run_scenario() {
  case "$1" in
    SCN-BUG-023-001) scenario_001 ;;
    SCN-BUG-023-002) scenario_002 ;;
    SCN-BUG-023-003) scenario_003 ;;
    SCN-BUG-023-004) scenario_004 ;;
    SCN-BUG-023-005) scenario_005 ;;
    SCN-BUG-023-006) scenario_006 ;;
    SCN-BUG-023-007) scenario_007 ;;
    SCN-BUG-023-008) scenario_008 ;;
    SCN-BUG-023-009) scenario_009 ;;
    SCN-BUG-023-010) scenario_010 ;;
    SCN-BUG-023-011) scenario_011 ;;
    SCN-BUG-023-012) scenario_012 ;;
    SCN-BUG-023-013) scenario_013 ;;
    SCN-BUG-023-014) scenario_014 ;;
    SCN-BUG-023-015) scenario_015 ;;
    SCN-BUG-023-016) scenario_016 ;;
    SCN-BUG-023-017) scenario_017 ;;
    *) harness_die "internal unknown scenario dispatch: $1" ;;
  esac
}

printf '%s\n' '============================================================'
printf '%s\n' 'BUG-023 planning transition applicability and baseline matrix'
printf 'canonical-root: %s\n' "$REPO_ROOT"
printf 'canonical-version: %s\n' "$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"
printf 'test-sha256: %s\n' "$(sha256_file "$TEST_FILE")"
printf 'selection: %s\n' "${SELECTED_SCENARIO:-all-17-scenarios}"
printf '%s\n' '============================================================'

if [[ -n "$SELECTED_SCENARIO" ]]; then
  run_scenario "$SELECTED_SCENARIO"
else
  for scenario_id in \
    SCN-BUG-023-001 \
    SCN-BUG-023-002 \
    SCN-BUG-023-003 \
    SCN-BUG-023-004 \
    SCN-BUG-023-005 \
    SCN-BUG-023-006 \
    SCN-BUG-023-007 \
    SCN-BUG-023-008 \
    SCN-BUG-023-009 \
    SCN-BUG-023-010 \
    SCN-BUG-023-011 \
    SCN-BUG-023-012 \
    SCN-BUG-023-013 \
    SCN-BUG-023-014 \
    SCN-BUG-023-015 \
    SCN-BUG-023-016 \
    SCN-BUG-023-017; do
    run_scenario "$scenario_id"
  done
fi

printf '%s\n' '============================================================'
printf 'PASS_CONTROLS=%s\n' "$PASS_CONTROLS"
printf 'CAUSAL_FAILURES=%s\n' "$CAUSAL_FAILURES"
printf 'G040_CAUSAL_FAILURES=%s\n' "$G040_CAUSAL_FAILURES"
printf 'G060_CAUSAL_FAILURES=%s\n' "$G060_CAUSAL_FAILURES"
printf 'G073_CAUSAL_FAILURES=%s\n' "$G073_CAUSAL_FAILURES"
printf 'CONTROL_FAILURES=%s\n' "$CONTROL_FAILURES"
printf 'HARNESS_FAILURES=%s\n' "$HARNESS_FAILURES"
printf 'GUARD_RUNS=%s\n' "$GUARD_RUNS"
printf 'BASELINE_RUNS=%s\n' "$BASELINE_RUNS"
printf '%s\n' '============================================================'

if [[ "$HARNESS_FAILURES" -gt 0 || "$CONTROL_FAILURES" -gt 0 ]]; then
  printf '%s\n' 'RED_CLASSIFICATION=HARNESS_OR_CONTROL_ERROR' >&2
  exit 2
fi

if [[ "$CAUSAL_FAILURES" -gt 0 ]]; then
  if [[ -z "$SELECTED_SCENARIO" \
    && ( "$G040_CAUSAL_FAILURES" -eq 0 || "$G060_CAUSAL_FAILURES" -eq 0 || "$G073_CAUSAL_FAILURES" -eq 0 ) ]]; then
    printf '%s\n' 'RED_CLASSIFICATION=INCOMPLETE_CAUSAL_COVERAGE' >&2
    exit 2
  fi
  printf '%s\n' 'RED_CLASSIFICATION=CAUSAL_BUG_CONTRACT_FAILURE'
  printf '%s\n' 'RED_CAUSAL_PROVEN=1'
  exit 1
fi

printf '%s\n' 'GREEN_REGRESSION_VERDICT=BUG_023_CONTRACT_SATISFIED'
exit 0