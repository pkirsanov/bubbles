#!/usr/bin/env bash
# =============================================================================
# state-transition-guard.sh
# =============================================================================
# MANDATORY guard script that MUST be executed BEFORE any state.json status
# transition to "done". This is the mechanical enforcement layer that prevents
# agents from fabricating completion status.
#
# Usage:
#   bash .github/bubbles/scripts/state-transition-guard.sh <feature-dir> [--revert-on-fail]
#
# Exit codes:
#   0 = All checks pass, transition to "done" is permitted
#   1 = One or more checks failed, transition BLOCKED
#   2 = Usage error / missing arguments
#
# When --revert-on-fail is specified and checks fail, the script automatically
# reverts state.json status to "in_progress" and clears completedScopes/completedPhases.
# =============================================================================
set -euo pipefail

# Source fun mode support
source "$(dirname "${BASH_SOURCE[0]}")/fun-mode.sh"

feature_dir="${1:-}"
revert_on_fail="false"

for arg in "$@"; do
  if [[ "$arg" == "--revert-on-fail" ]]; then
    revert_on_fail="true"
  fi
done

if [[ -z "$feature_dir" ]]; then
  echo "ERROR: missing feature directory argument"
  echo "Usage: bash .github/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature-name> [--revert-on-fail]"
  exit 2
fi

if [[ ! -d "$feature_dir" ]]; then
  echo "ERROR: feature directory not found: $feature_dir"
  exit 2
fi

failures=0
warnings=0

fail() {
  local message="$1"
  echo "🔴 BLOCK: $message"
  fun_fail
  failures=$((failures + 1))
}

warn() {
  local message="$1"
  echo "⚠️  WARN: $message"
  fun_warn
  warnings=$((warnings + 1))
}

pass() {
  local message="$1"
  echo "✅ PASS: $message"
}

info() {
  local message="$1"
  echo "ℹ️  INFO: $message"
}

json_first_string() {
  local key="$1"
  local file="$2"
  if [[ ! -f "$file" ]]; then
    return 0
  fi

  grep -Eo '"'"$key"'"[[:space:]]*:[[:space:]]*"[^"]+"' "$file" \
    | head -n 1 \
    | sed -E 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/'
}

detect_scope_layout() {
  local state_layout=""
  state_layout="$(json_first_string "scopeLayout" "$feature_dir/state.json" || true)"
  if [[ "$state_layout" == "per-scope-directory" ]] || [[ -f "$feature_dir/scopes/_index.md" ]]; then
    echo "per-scope-directory"
  else
    echo "single-file"
  fi
}

scope_layout="$(detect_scope_layout)"
scope_index_file="$feature_dir/scopes/_index.md"
scope_files=()
report_files=()

if [[ "$scope_layout" == "per-scope-directory" ]]; then
  while IFS= read -r scope_path; do
    scope_files+=("$scope_path")
  done < <(find "$feature_dir/scopes" -mindepth 2 -maxdepth 2 -type f -name 'scope.md' | sort)

  while IFS= read -r scope_report_path; do
    report_files+=("$scope_report_path")
  done < <(find "$feature_dir/scopes" -mindepth 2 -maxdepth 2 -type f -name 'report.md' | sort)
else
  scope_files+=("$feature_dir/scopes.md")
  report_files+=("$feature_dir/report.md")
fi

scopes_file="${scope_files[0]:-}"
report_file=""
if [[ ${#report_files[@]} -gt 0 ]]; then
  report_file="${report_files[0]}"
fi

echo "============================================================"
echo "  BUBBLES STATE TRANSITION GUARD"
echo "  Feature: $feature_dir"
echo "  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "============================================================"
fun_banner
fun_message guard_start
echo ""

# =============================================================================
# CHECK 1: Required artifacts exist
# =============================================================================
echo "--- Check 1: Required Artifacts ---"
required_files=("spec.md" "design.md" "uservalidation.md" "state.json")
for required_file in "${required_files[@]}"; do
  if [[ -f "$feature_dir/$required_file" ]]; then
    pass "Required artifact exists: $required_file"
  else
    fail "Missing required artifact: $feature_dir/$required_file"
  fi
done

if [[ "$scope_layout" == "per-scope-directory" ]]; then
  if [[ -f "$scope_index_file" ]]; then
    pass "Required artifact exists: scopes/_index.md"
  else
    fail "Missing required artifact: $scope_index_file"
  fi

  if [[ ${#scope_files[@]} -gt 0 ]]; then
    pass "Per-scope layout contains ${#scope_files[@]} scope file(s)"
  else
    fail "Per-scope layout requires at least one scopes/NN-name/scope.md file"
  fi

  missing_scope_reports=0
  for scope_path in "${scope_files[@]}"; do
    scope_report_path="$(dirname "$scope_path")/report.md"
    if [[ -f "$scope_report_path" ]]; then
      pass "Scope report exists: ${scope_report_path#$feature_dir/}"
    else
      fail "Missing scope report for ${scope_path#$feature_dir/}: ${scope_report_path#$feature_dir/}"
      missing_scope_reports=$((missing_scope_reports + 1))
    fi
  done

  if [[ "$missing_scope_reports" -eq 0 ]] && [[ ${#scope_files[@]} -gt 0 ]]; then
    pass "Every per-scope directory has a report.md file"
  fi
else
  if [[ -f "$feature_dir/scopes.md" ]]; then
    pass "Required artifact exists: scopes.md"
  else
    fail "Missing required artifact: $feature_dir/scopes.md"
  fi

  if [[ -f "$feature_dir/report.md" ]]; then
    pass "Required artifact exists: report.md"
  else
    fail "Missing required artifact: $feature_dir/report.md"
  fi
fi
echo ""

# =============================================================================
# CHECK 2: state.json structural integrity
# =============================================================================
echo "--- Check 2: state.json Integrity ---"
state_file="$feature_dir/state.json"
if [[ ! -f "$state_file" ]]; then
  fail "state.json does not exist"
  # Can't do remaining checks without state.json
  echo ""
  echo "RESULT: BLOCKED ($failures failures)"
  exit 1
fi

state_status="$({ grep -Eo '"status"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" | head -n 1 | sed -E 's/.*"([^"]+)"/\1/'; } || true)"
state_workflow_mode="$({ grep -Eo '"workflowMode"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" | head -n 1 | sed -E 's/.*"([^"]+)"/\1/'; } || true)"
wi_canonical_count="$({ grep -Eo '"canonicalCount"[[:space:]]*:[[:space:]]*[0-9]+' "$state_file" | head -n 1 | sed -E 's/.*:[[:space:]]*([0-9]+)/\1/'; } || true)"
wi_provisional_count="$({ grep -Eo '"provisionalIntakeCount"[[:space:]]*:[[:space:]]*[0-9]+' "$state_file" | head -n 1 | sed -E 's/.*:[[:space:]]*([0-9]+)/\1/'; } || true)"
wi_post_migration_target="$({ grep -Eo '"postMigrationTargetCount"[[:space:]]*:[[:space:]]*[0-9]+' "$state_file" | head -n 1 | sed -E 's/.*:[[:space:]]*([0-9]+)/\1/'; } || true)"
wi_migration_status="$({ grep -Eo '"migrationStatus"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" | head -n 1 | sed -E 's/.*"migrationStatus"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/'; } || true)"
wi_migration_source="$({ grep -Eo '"migrationSource"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" | head -n 1 | sed -E 's/.*"migrationSource"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/'; } || true)"
wi_trace_matrix="$({ grep -Eo '"traceMatrix"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" | head -n 1 | sed -E 's/.*"traceMatrix"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/'; } || true)"

if [[ -z "$state_status" ]]; then
  fail "state.json missing 'status' field"
fi

if [[ -z "$state_workflow_mode" ]]; then
  fail "state.json missing 'workflowMode' field (required for status ceiling enforcement)"
fi

info "Current state.json status: ${state_status:-MISSING}"
info "Current workflowMode: ${state_workflow_mode:-MISSING}"
echo ""

# =============================================================================
# CHECK 2A: WI parity integrity (canonical + provisional intake mode)
# =============================================================================
echo "--- Check 2A: WI Parity Integrity ---"
if [[ -n "$wi_canonical_count$wi_provisional_count$wi_post_migration_target$wi_migration_status" ]]; then
  info "Detected wiParity metadata in state.json"

  if [[ -z "$wi_canonical_count" ]] || [[ -z "$wi_provisional_count" ]] || [[ -z "$wi_post_migration_target" ]] || [[ -z "$wi_migration_status" ]]; then
    fail "wiParity metadata is incomplete (requires canonicalCount, provisionalIntakeCount, postMigrationTargetCount, migrationStatus)"
  else
    expected_wi_total=$((wi_canonical_count + wi_provisional_count))
    if [[ "$expected_wi_total" -eq "$wi_post_migration_target" ]]; then
      pass "wiParity equation valid: canonical ($wi_canonical_count) + provisional ($wi_provisional_count) = postMigrationTarget ($wi_post_migration_target)"
    else
      fail "wiParity mismatch: canonical ($wi_canonical_count) + provisional ($wi_provisional_count) != postMigrationTarget ($wi_post_migration_target)"
    fi

    case "$wi_migration_status" in
      proposed_not_activated|activated|not_applicable)
        pass "wiParity migrationStatus is valid: $wi_migration_status"
        ;;
      *)
        fail "wiParity migrationStatus '$wi_migration_status' is invalid (allowed: proposed_not_activated, activated, not_applicable)"
        ;;
    esac

    if [[ "$wi_migration_status" == "proposed_not_activated" ]] && [[ "$wi_provisional_count" -gt 0 ]]; then
      pass "Dual-count mode recognized (canonical + provisional tracked separately)"
    fi

    if [[ "$wi_migration_status" == "activated" ]] && [[ "$wi_provisional_count" -gt 0 ]]; then
      fail "migrationStatus 'activated' requires provisionalIntakeCount=0 (found $wi_provisional_count)"
    fi
  fi

  if [[ -n "$wi_migration_source" ]]; then
    wi_migration_source_file="${wi_migration_source%%#*}"
    if [[ -f "$feature_dir/$wi_migration_source_file" ]]; then
      pass "wiParity migrationSource file exists: $wi_migration_source_file"
    else
      fail "wiParity migrationSource file missing: $feature_dir/$wi_migration_source_file"
    fi
  fi

  if [[ -n "$wi_trace_matrix" ]]; then
    if [[ -f "$feature_dir/$wi_trace_matrix" ]]; then
      pass "wiParity traceMatrix file exists: $wi_trace_matrix"
    else
      fail "wiParity traceMatrix file missing: $feature_dir/$wi_trace_matrix"
    fi
  fi
else
  info "No wiParity metadata found (dual-count checks skipped)"
fi
echo ""

# =============================================================================
# CHECK 3: Status ceiling enforcement
# =============================================================================
echo "--- Check 3: Status Ceiling Enforcement ---"
if [[ -n "$state_workflow_mode" ]]; then
  case "$state_workflow_mode" in
    full-delivery|full-delivery-strict|value-first-e2e-batch|feature-bootstrap|bugfix-fastlane|chaos-hardening|harden-to-doc|gaps-to-doc|harden-gaps-to-doc|reconcile-to-doc|test-to-doc|chaos-to-doc|batch-implement|batch-harden|batch-gaps|batch-harden-gaps|batch-improve-existing|batch-reconcile-to-doc|product-to-delivery|improve-existing)
      if [[ "$state_status" == "done" ]]; then
        pass "Workflow mode '$state_workflow_mode' allows status 'done'"
      else
        info "Workflow mode '$state_workflow_mode' allows status 'done'; current status is '$state_status'"
      fi
      ;;
    spec-scope-hardening)
      if [[ "$state_status" == "done" ]]; then
        fail "Workflow mode 'spec-scope-hardening' ceiling is 'specs_hardened', NOT 'done'"
      elif [[ "$state_status" == "specs_hardened" ]]; then
        pass "Workflow mode 'spec-scope-hardening' correctly stops at status 'specs_hardened'"
      else
        info "Workflow mode 'spec-scope-hardening' ceiling is 'specs_hardened'; current status is '$state_status'"
      fi
      ;;
    docs-only)
      if [[ "$state_status" == "done" ]]; then
        fail "Workflow mode 'docs-only' ceiling is 'docs_updated', NOT 'done'"
      elif [[ "$state_status" == "docs_updated" ]]; then
        pass "Workflow mode 'docs-only' correctly stops at status 'docs_updated'"
      else
        info "Workflow mode 'docs-only' ceiling is 'docs_updated'; current status is '$state_status'"
      fi
      ;;
    validate-only|audit-only|validate-to-doc)
      if [[ "$state_status" == "done" ]]; then
        fail "Workflow mode '$state_workflow_mode' ceiling is 'validated', NOT 'done'"
      elif [[ "$state_status" == "validated" ]]; then
        pass "Workflow mode '$state_workflow_mode' correctly stops at status 'validated'"
      else
        info "Workflow mode '$state_workflow_mode' ceiling is 'validated'; current status is '$state_status'"
      fi
      ;;
    resume-only)
      if [[ "$state_status" == "done" ]]; then
        fail "Workflow mode 'resume-only' ceiling is 'in_progress', NOT 'done'"
      elif [[ "$state_status" == "in_progress" ]]; then
        pass "Workflow mode 'resume-only' correctly stops at status 'in_progress'"
      else
        info "Workflow mode 'resume-only' ceiling is 'in_progress'; current status is '$state_status'"
      fi
      ;;
    *)
      fail "Unknown workflow mode '$state_workflow_mode' — cannot verify ceiling"
      ;;
  esac
fi
echo ""

# =============================================================================
# CHECK 4: ALL DoD items must be checked [x] — ZERO unchecked allowed
# =============================================================================
echo "--- Check 4: DoD Completion (Zero Unchecked) ---"
total_checked=0
total_unchecked=0
for scope_path in "${scope_files[@]}"; do
  [[ -f "$scope_path" ]] || continue
  total_checked=$((total_checked + $(grep -cE '^\- \[x\] ' "$scope_path" || true)))
  total_unchecked=$((total_unchecked + $(grep -cE '^\- \[ \] ' "$scope_path" || true)))
done
total_dod=$((total_checked + total_unchecked))

info "DoD items total: $total_dod (checked: $total_checked, unchecked: $total_unchecked)"

if [[ "$total_dod" -eq 0 ]]; then
  fail "Resolved scope artifacts have ZERO DoD checkbox items — cannot verify completion"
elif [[ "$total_unchecked" -gt 0 ]]; then
  fail "Resolved scope artifacts have $total_unchecked UNCHECKED DoD items — ALL must be [x] for 'done'"
  shown_unchecked=0
  for scope_path in "${scope_files[@]}"; do
    [[ -f "$scope_path" ]] || continue
    while IFS= read -r unchecked_line; do
      [[ -n "$unchecked_line" ]] || continue
      echo "   → ${scope_path#$feature_dir/}: $unchecked_line"
      shown_unchecked=$((shown_unchecked + 1))
      if [[ "$shown_unchecked" -ge 10 ]]; then
        break 2
      fi
    done < <(grep -E '^\- \[ \] ' "$scope_path" || true)
  done
else
  pass "All $total_checked DoD items are checked [x]"
fi
echo ""

# =============================================================================
# CHECK 5: Scope status cross-reference — scopes marked "Done" in scopes.md
# must match state.json completedScopes
# =============================================================================
echo "--- Check 5: Scope Status Cross-Reference ---"
not_started_scopes=0
in_progress_scopes=0
blocked_scopes=0
done_scopes=0
for scope_path in "${scope_files[@]}"; do
  [[ -f "$scope_path" ]] || continue
  not_started_scopes=$((not_started_scopes + $(grep -cE '\*\*Status:\*\*.*Not Started' "$scope_path" || true)))
  in_progress_scopes=$((in_progress_scopes + $(grep -cE '\*\*Status:\*\*.*In Progress' "$scope_path" || true)))
  blocked_scopes=$((blocked_scopes + $(grep -cE '\*\*Status:\*\*.*Blocked' "$scope_path" || true)))
  done_scopes=$((done_scopes + $(grep -cE '\*\*Status:\*\*.*Done' "$scope_path" || true)))
done
total_scopes=$((not_started_scopes + in_progress_scopes + blocked_scopes + done_scopes))

info "Resolved scopes: total=$total_scopes, Done=$done_scopes, In Progress=$in_progress_scopes, Not Started=$not_started_scopes, Blocked=$blocked_scopes"

if [[ "$total_scopes" -eq 0 ]]; then
  fail "Resolved scope artifacts have no scope status markers"
elif [[ "$not_started_scopes" -gt 0 ]]; then
  fail "Resolved scope artifacts have $not_started_scopes scope(s) still marked 'Not Started' — ALL scopes must be Done"
elif [[ "$in_progress_scopes" -gt 0 ]]; then
  fail "Resolved scope artifacts have $in_progress_scopes scope(s) still marked 'In Progress' — ALL scopes must be Done"
elif [[ "$blocked_scopes" -gt 0 ]]; then
  fail "Resolved scope artifacts have $blocked_scopes scope(s) still marked 'Blocked' — ALL scopes must be Done"
else
  pass "All $done_scopes scope(s) are marked Done"
fi

state_completed_scopes_count="$({
  awk '/"completedScopes"[[:space:]]*:/ {capture=1} capture {print} capture && /\]/ {exit}' "$state_file" \
  | sed -E '1s/.*"completedScopes"[[:space:]]*:[[:space:]]*\[//' \
  | grep -cE '"[^"]+"' || true
} || true)"

if [[ "$done_scopes" -gt 0 ]] && [[ "$state_completed_scopes_count" -eq 0 ]]; then
  fail "Resolved scope artifacts report $done_scopes Done scope(s) but state.json completedScopes is EMPTY — state.json integrity failure"
fi
echo ""

# =============================================================================
# CHECK 5A: Stress coverage for SLA-scoped work (Gate G026)
# =============================================================================
echo "--- Check 5A: SLA Stress Coverage ---"
sla_scope_count=0
for scope_path in "${scope_files[@]}"; do
  [[ -f "$scope_path" ]] || continue

  if grep -Eiq 'latency|throughput|p95|p99|response time|sla|slo' "$scope_path"; then
    sla_scope_count=$((sla_scope_count + 1))
    if grep -Eq '^\|[[:space:]]*Stress[[:space:]]*\|' "$scope_path" || grep -Eiq 'stress' "$scope_path"; then
      pass "SLA-sensitive scope includes stress coverage: ${scope_path#$feature_dir/}"
    else
      fail "SLA-sensitive scope is missing explicit stress coverage: ${scope_path#$feature_dir/}"
    fi
  fi
done

if [[ "$sla_scope_count" -eq 0 ]]; then
  info "No SLA-sensitive scopes detected for Gate G026"
fi
echo ""

# =============================================================================
# CHECK 6: completedPhases vs required specialists
# =============================================================================
echo "--- Check 6: Specialist Phase Completion ---"
state_completed_phases_block="$({
  awk '
    /"completedPhases"[[:space:]]*:/ {capture=1}
    capture {print}
    capture && /\]/ {exit}
  ' "$state_file"
} || true)"

if [[ -n "$state_workflow_mode" ]]; then
  required_specialists=()
  case "$state_workflow_mode" in
    full-delivery|value-first-e2e-batch)
      required_specialists=("implement" "test" "docs" "validate" "audit" "chaos")
      ;;
    full-delivery-strict)
      required_specialists=("implement" "test" "docs" "validate" "audit" "chaos")
      ;;
    feature-bootstrap)
      required_specialists=("implement" "test" "docs" "validate" "audit")
      ;;
    bugfix-fastlane)
      required_specialists=("implement" "test" "validate" "audit")
      ;;
    chaos-hardening)
      required_specialists=("chaos" "implement" "test" "validate" "audit")
      ;;
    harden-to-doc)
      required_specialists=("harden" "implement" "test" "chaos" "validate" "audit" "docs")
      ;;
    gaps-to-doc)
      required_specialists=("gaps" "implement" "test" "chaos" "validate" "audit" "docs")
      ;;
    harden-gaps-to-doc)
      required_specialists=("harden" "gaps" "implement" "test" "chaos" "validate" "audit" "docs")
      ;;
    reconcile-to-doc)
      required_specialists=("validate" "implement" "test" "audit" "chaos" "docs")
      ;;
    test-to-doc)
      required_specialists=("test" "validate" "audit" "docs")
      ;;
    chaos-to-doc)
      required_specialists=("chaos" "validate" "audit" "docs")
      ;;
    batch-implement)
      required_specialists=("implement" "test" "docs" "validate" "audit" "chaos")
      ;;
    batch-harden)
      required_specialists=("validate" "harden" "implement" "test" "audit" "chaos" "docs")
      ;;
    batch-gaps)
      required_specialists=("validate" "gaps" "implement" "test" "audit" "chaos" "docs")
      ;;
    batch-harden-gaps)
      required_specialists=("validate" "harden" "gaps" "implement" "test" "audit" "chaos" "docs")
      ;;
    batch-improve-existing)
      required_specialists=("validate" "harden" "gaps" "implement" "test" "audit" "chaos" "docs")
      ;;
    batch-reconcile-to-doc)
      required_specialists=("validate" "implement" "test" "audit" "chaos" "docs")
      ;;
    product-to-delivery)
      required_specialists=("implement" "test" "docs" "validate" "audit" "chaos")
      ;;
    improve-existing)
      required_specialists=("validate" "harden" "gaps" "implement" "test" "audit" "chaos" "docs")
      ;;
    validate-to-doc)
      required_specialists=("validate" "audit" "docs")
      ;;
  esac

  if [[ ${#required_specialists[@]} -gt 0 ]]; then
    missing_phases=0
    for specialist_phase in "${required_specialists[@]}"; do
      if echo "$state_completed_phases_block" | grep -qE "\"$specialist_phase\""; then
        pass "Required phase '$specialist_phase' recorded in completedPhases"
      else
        fail "Required phase '$specialist_phase' NOT in completedPhases (Gate G022 violation)"
        missing_phases=$((missing_phases + 1))
      fi
    done
    if [[ "$missing_phases" -gt 0 ]]; then
      fail "$missing_phases specialist phase(s) missing — work was NOT executed through the full pipeline"
    fi
  fi
fi
echo ""

# =============================================================================
# CHECK 7: Timestamp plausibility — detect uniformly-spaced timestamps
# =============================================================================
echo "--- Check 7: Timestamp Plausibility ---"
timestamps=()
while IFS= read -r ts; do
  timestamps+=("$ts")
done < <(grep -oE '"completedAt"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" 2>/dev/null \
  | sed -E 's/.*"completedAt"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/' || true)

if [[ ${#timestamps[@]} -ge 3 ]]; then
  # Convert timestamps to epoch seconds and check intervals
  prev_epoch=0
  intervals=()
  all_parseable="true"
  for ts in "${timestamps[@]}"; do
    epoch="$(date -d "$ts" +%s 2>/dev/null || true)"
    if [[ -z "$epoch" ]]; then
      all_parseable="false"
      break
    fi
    if [[ "$prev_epoch" -gt 0 ]]; then
      interval=$((epoch - prev_epoch))
      intervals+=("$interval")
    fi
    prev_epoch="$epoch"
  done

  if [[ "$all_parseable" == "true" ]] && [[ ${#intervals[@]} -ge 2 ]]; then
    # Check if all intervals are identical (suspicious uniform spacing)
    all_identical="true"
    first_interval="${intervals[0]}"
    for interval in "${intervals[@]}"; do
      if [[ "$interval" -ne "$first_interval" ]]; then
        all_identical="false"
        break
      fi
    done

    if [[ "$all_identical" == "true" ]]; then
      fail "All completedPhases timestamps have identical intervals (${first_interval}s apart) — FABRICATION INDICATOR"
      info "Timestamps: ${timestamps[*]}"
    else
      pass "Timestamp intervals are variable (not uniformly fabricated)"
    fi

    # Check if all timestamps are within 1 second of each other
    min_epoch="$(date -d "${timestamps[0]}" +%s 2>/dev/null || true)"
    max_epoch="$min_epoch"
    for ts in "${timestamps[@]}"; do
      epoch="$(date -d "$ts" +%s 2>/dev/null || true)"
      [[ -n "$epoch" ]] || continue
      [[ "$epoch" -lt "$min_epoch" ]] && min_epoch="$epoch"
      [[ "$epoch" -gt "$max_epoch" ]] && max_epoch="$epoch"
    done
    spread=$((max_epoch - min_epoch))
    if [[ "$spread" -lt 5 ]] && [[ ${#timestamps[@]} -ge 3 ]]; then
      fail "All ${#timestamps[@]} phase timestamps span only ${spread}s — impossible for real sequential execution"
    fi
  fi
elif [[ ${#timestamps[@]} -eq 0 ]]; then
  warn "No completedAt timestamps found in state.json"
else
  info "Only ${#timestamps[@]} timestamp(s) found — skipping interval analysis"
fi
echo ""

# =============================================================================
# CHECK 8: Test file existence — verify Test Plan files exist on disk
# =============================================================================
echo "--- Check 8: Test File Existence ---"
if [[ -f "$scopes_file" ]]; then
  # Extract test file paths from Test Plan tables
  test_files_in_plan=()
  while IFS= read -r line; do
    # Extract paths from markdown table cells (backtick-wrapped)
    path="$(echo "$line" | grep -oE '`[^`]+\.(spec|test|rs|ts|tsx|js|jsx)\b[^`]*`' | sed 's/`//g' | head -1 || true)"
    if [[ -n "$path" ]] && [[ "$path" != "[path]" ]] && [[ ! "$path" =~ ^\[ ]]; then
      test_files_in_plan+=("$path")
    fi
  done < <(grep -E '^\|.*\|.*\|.*\|' "$scopes_file" 2>/dev/null || true)

  missing_test_files=0
  if [[ ${#test_files_in_plan[@]} -gt 0 ]]; then
    for test_path in "${test_files_in_plan[@]}"; do
      if [[ -f "$test_path" ]]; then
        pass "Test file exists: $test_path"
      else
        fail "Test Plan references non-existent file: $test_path"
        missing_test_files=$((missing_test_files + 1))
      fi
    done
    if [[ "$missing_test_files" -gt 0 ]]; then
      fail "$missing_test_files of ${#test_files_in_plan[@]} test files from Test Plan DO NOT EXIST"
    fi
  else
    warn "No concrete test file paths found in Test Plan (all may be placeholders)"
  fi
fi
echo ""

# =============================================================================
# CHECK 9: Evidence depth — DoD [x] items must have evidence blocks
# =============================================================================
echo "--- Check 9: DoD Evidence Presence ---"
if [[ -f "$scopes_file" ]]; then
  checked_without_evidence=0
  checked_with_evidence=0
  while IFS= read -r line; do
    item_line_num="$({ grep -nF -- "$line" "$scopes_file" | head -1 | cut -d: -f1; } || true)"
    if [[ -n "$item_line_num" ]]; then
      next_lines="$({ sed -n "$((item_line_num+1)),$((item_line_num+15))p" "$scopes_file"; } || true)"
        if echo "$line" | grep -qiE '(→[[:space:]]*Evidence:|Evidence:)'; then
          checked_with_evidence=$((checked_with_evidence + 1))
        elif echo "$next_lines" | grep -qE '(Executed:|Command:|Evidence|```|Exit Code:|Raw Output)'; then
        checked_with_evidence=$((checked_with_evidence + 1))
      else
        checked_without_evidence=$((checked_without_evidence + 1))
        fail "DoD item [x] has NO evidence block: $(echo "$line" | head -c 80)"
      fi
    fi
  done < <(grep -E '^\- \[x\] ' "$scopes_file" 2>/dev/null || true)

  if [[ "$checked_without_evidence" -eq 0 ]] && [[ "$checked_with_evidence" -gt 0 ]]; then
    pass "All $checked_with_evidence checked DoD items have evidence blocks"
  elif [[ "$checked_with_evidence" -eq 0 ]] && [[ "$total_checked" -gt 0 ]]; then
    fail "ALL checked DoD items lack evidence blocks — BULK FABRICATION DETECTED"
  fi
fi
echo ""

# =============================================================================
# CHECK 10: Template placeholder detection
# =============================================================================
echo "--- Check 10: Template Placeholder Detection ---"
if [[ -f "$scopes_file" ]]; then
  template_hits="$({ grep -cnE '\[ACTUAL terminal output|\[exact cmd\]|\[actual exit code\]|\[ACTUAL output|\[command \+ output|\[cmd\]|\[PASTE VERBATIM terminal output|\[PASTE VERBATIM.*output here' "$scopes_file"; } || true)"
  if [[ "$template_hits" -gt 0 ]]; then
    fail "scopes.md contains $template_hits unfilled template placeholders — FABRICATION"
  else
    pass "No template placeholders in scopes.md"
  fi
fi

if [[ ! -f "$report_file" && ${#report_files[@]} -gt 0 ]]; then
  report_file="${report_files[0]}"
fi
if [[ -f "$report_file" ]]; then
  report_template_hits="$({ grep -cnE '\[ACTUAL terminal output|\[exact cmd\]|\[actual exit code\]|\[ACTUAL output|\[command \+ output|\[PASTE VERBATIM terminal output|\[PASTE VERBATIM.*output here' "$report_file"; } || true)"
  if [[ "$report_template_hits" -gt 0 ]]; then
    fail "report.md contains $report_template_hits unfilled template placeholders — FABRICATION"
  else
    pass "No template placeholders in report.md"
  fi
fi
echo ""

# =============================================================================
# CHECK 11: Report.md required sections
# =============================================================================
echo "--- Check 11: Report.md Required Sections ---"
if [[ -f "$report_file" ]]; then
  required_headers=("### Summary" "### Completion Statement" "### Test Evidence")
  for header in "${required_headers[@]}"; do
    if grep -qE "^${header}" "$report_file"; then
      pass "report.md has section: $header"
    else
      fail "report.md missing required section: $header"
    fi
  done

  # Check evidence legitimacy in report.md (content-based, not just line count)
  # Looks for terminal output signals: test results, file paths, exit codes, timing, commands
  illegitimate_blocks=0
  total_blocks=0
  in_block=0
  block_lines=0
  block_content=""
  while IFS= read -r line; do
    if [[ "$in_block" -eq 0 ]] && echo "$line" | grep -qE '^```'; then
      in_block=1
      block_lines=0
      block_content=""
    elif [[ "$in_block" -eq 1 ]] && echo "$line" | grep -qE '^```$'; then
      in_block=0
      total_blocks=$((total_blocks + 1))

      if [[ "$block_lines" -lt 3 ]]; then
        illegitimate_blocks=$((illegitimate_blocks + 1))
      else
        # Count terminal output signals
        signals=0
        # Test runner patterns
        echo "$block_content" | grep -qiE '(passed|failed|ok$| PASS | FAIL |test result:|Tests:.*suites|✓|✗|PASSED|FAILED)' && signals=$((signals + 1))
        # Exit/compiler/log patterns
        echo "$block_content" | grep -qiE '(exit code|Exit Code:|error\[|warning\[|Compiling |Finished |error:|warning:|WARN |ERROR |INFO )' && signals=$((signals + 1))
        # File paths with extensions
        echo "$block_content" | grep -qE '([a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+\.(rs|py|ts|tsx|js|go|sh|sql|toml|yaml|json|proto|md)|\./)' && signals=$((signals + 1))
        # Timing/duration patterns
        echo "$block_content" | grep -qiE '(in [0-9]+(\.[0-9]+)?(s|ms|m)|elapsed|finished in|Duration|[0-9]+\.[0-9]+s$)' && signals=$((signals + 1))
        # Build tool / test framework names
        echo "$block_content" | grep -qiE '(cargo |npm |pytest|go test|jest |playwright|vitest|running [0-9]+ test|test result:)' && signals=$((signals + 1))
        # Count patterns
        echo "$block_content" | grep -qE '[0-9]+ (passed|failed|errors?|warnings?|skipped|ignored|tests?)' && signals=$((signals + 1))
        # HTTP/curl patterns
        echo "$block_content" | grep -qiE '(HTTP/|status.*[0-9]{3}|curl |GET /|POST /|PUT /|DELETE /|Content-Type)' && signals=$((signals + 1))
        # grep/ls/filesystem output
        echo "$block_content" | grep -qE '(^[dl-][rwx-]{9} |^[0-9]+:|^\$ |^> )' && signals=$((signals + 1))

        if [[ "$signals" -lt 2 ]]; then
          illegitimate_blocks=$((illegitimate_blocks + 1))
        fi
      fi
    elif [[ "$in_block" -eq 1 ]]; then
      block_lines=$((block_lines + 1))
      block_content="${block_content}${line}"$'\n'
    fi
  done < "$report_file"

  if [[ "$total_blocks" -eq 0 ]]; then
    fail "report.md has ZERO evidence code blocks — no execution evidence exists"
  elif [[ "$illegitimate_blocks" -gt 0 ]]; then
    warn "report.md has $illegitimate_blocks of $total_blocks evidence blocks that lack terminal output signals (potentially fabricated)"
  else
    pass "All $total_blocks evidence blocks in report.md contain legitimate terminal output"
  fi

  # Check for narrative summary phrases (fabrication indicator)
  narrative_hits="$({
    grep -ciE '(all tests pass|everything works|no issues found|verified successfully|confirmed working|tests are green|builds successfully|all checks pass)' "$report_file" || true
  } || true)"
  # Exclude matches inside code blocks
  narrative_outside_blocks="$({
    awk '
      /^```/ {in_block = !in_block; next}
      !in_block && tolower($0) ~ /(all tests pass|everything works|no issues found|verified successfully|confirmed working|tests are green|builds successfully|all checks pass)/ {count++}
      END {print count+0}
    ' "$report_file"
  } || true)"
  if [[ "$narrative_outside_blocks" -gt 0 ]]; then
    warn "report.md has $narrative_outside_blocks narrative summary phrases outside code blocks (fabrication indicator)"
  else
    pass "No narrative summary phrases detected outside code blocks"
  fi
else
  fail "report.md does not exist"
fi
echo ""

# =============================================================================
# CHECK 12: Duplicate evidence detection
# =============================================================================
echo "--- Check 12: Duplicate Evidence Detection ---"
if [[ -f "$scopes_file" ]]; then
  evidence_hashes=()
  in_evidence=0
  current_evidence=""
  duplicate_found="false"
  while IFS= read -r line; do
    if [[ "$in_evidence" -eq 0 ]] && echo "$line" | grep -qE '^    ```'; then
      in_evidence=1
      current_evidence=""
    elif [[ "$in_evidence" -eq 1 ]] && echo "$line" | grep -qE '^    ```$'; then
      in_evidence=0
      if [[ -n "$current_evidence" ]]; then
        evidence_hash="$(echo "$current_evidence" | md5sum | cut -d' ' -f1)"
        for prev_hash in "${evidence_hashes[@]}"; do
          if [[ "$evidence_hash" == "$prev_hash" ]]; then
            fail "Duplicate evidence blocks detected in scopes.md — COPY-PASTE FABRICATION"
            duplicate_found="true"
            break 2
          fi
        done
        evidence_hashes+=("$evidence_hash")
      fi
    elif [[ "$in_evidence" -eq 1 ]]; then
      current_evidence="${current_evidence}${line}"
    fi
  done < "$scopes_file"

  if [[ "$duplicate_found" == "false" ]]; then
    pass "No duplicate evidence blocks in scopes.md"
  fi
fi
echo ""

# =============================================================================
# CHECK 13: Run artifact lint as final cross-check
# =============================================================================
echo "--- Check 13: Artifact Lint ---"
lint_script=".github/bubbles/scripts/artifact-lint.sh"
if [[ -f "$lint_script" ]]; then
  if bash "$lint_script" "$feature_dir" > /dev/null 2>&1; then
    pass "Artifact lint passes (exit 0)"
  else
    fail "Artifact lint FAILED — run 'bash $lint_script $feature_dir' for details"
  fi
else
  warn "Artifact lint script not found at $lint_script"
fi
echo ""

# =============================================================================
# CHECK 14: TODO/FIXME/STUB markers in implementation files
# =============================================================================
echo "--- Check 14: Implementation Completeness ---"
if [[ -f "$scopes_file" ]]; then
  # Extract implementation file paths from implementation plan sections
  impl_files=()
  while IFS= read -r line; do
    # Look for file paths in backticks that look like source files
    path="$(echo "$line" | grep -oE '`[^`]+\.(rs|ts|tsx|js|jsx|py|go|java)\b[^`]*`' | sed 's/`//g' | head -1 || true)"
    if [[ -n "$path" ]] && [[ -f "$path" ]]; then
      impl_files+=("$path")
    fi
  done < "$scopes_file"

  if [[ ${#impl_files[@]} -gt 0 ]]; then
    todo_hits=0
    for impl_file in "${impl_files[@]}"; do
      file_todos="$({ grep -cnE 'TODO|FIXME|HACK|STUB|unimplemented!|NotImplementedError' "$impl_file"; } || true)"
      if [[ "$file_todos" -gt 0 ]]; then
        fail "Implementation file has $file_todos TODO/STUB markers: $impl_file"
        todo_hits=$((todo_hits + file_todos))
      fi
    done
    if [[ "$todo_hits" -eq 0 ]]; then
      pass "No TODO/FIXME/STUB markers in referenced implementation files"
    fi
  else
    info "No implementation file paths extracted from scopes.md (manual check advised)"
  fi
fi
echo ""

# =============================================================================
# CHECK 15: Phase-Scope Coherence (Gate G027)
# =============================================================================
# Detects fabricated completedPhases by cross-referencing against
# completedScopes. If implementation phases (implement, test) are claimed
# but completedScopes is empty or partial, it's fabrication.
# =============================================================================
echo "--- Check 15: Phase-Scope Coherence (Gate G027) ---"
if [[ -n "$state_workflow_mode" ]]; then
  # Only check modes that involve implementation
  case "$state_workflow_mode" in
    full-delivery|full-delivery-strict|value-first-e2e-batch|feature-bootstrap|bugfix-fastlane|chaos-hardening|harden-to-doc|gaps-to-doc|harden-gaps-to-doc|reconcile-to-doc|test-to-doc|chaos-to-doc|batch-implement|batch-harden|batch-gaps|batch-harden-gaps|batch-improve-existing|batch-reconcile-to-doc|product-to-delivery|improve-existing)
      # Check if implement/test phases are claimed
      has_implement="false"
      has_test="false"
      if echo "$state_completed_phases_block" | grep -qE '"implement"'; then
        has_implement="true"
      fi
      if echo "$state_completed_phases_block" | grep -qE '"test"'; then
        has_test="true"
      fi

      if [[ "$has_implement" == "true" || "$has_test" == "true" ]]; then
        # Implementation phases claimed — completedScopes MUST be non-empty
        if [[ "$state_completed_scopes_count" -eq 0 ]]; then
          fail "completedPhases claims implement/test phases but completedScopes is EMPTY — FABRICATION (Gate G027)"
          info "This means phases were recorded without any scope actually completing"
        fi

        # Implementation phases claimed — scope artifact statuses must show work done
        if [[ "$done_scopes" -eq 0 ]]; then
          fail "completedPhases claims implement/test phases but ZERO scopes are marked 'Done' — FABRICATION (Gate G027)"
        fi

        # If ALL phases claimed but scopes are partial, that's suspicious
        claimed_phase_count="$(echo "$state_completed_phases_block" | grep -cE '"(implement|test|docs|validate|audit|chaos)"' || true)"
        if [[ "$claimed_phase_count" -ge 5 ]] && [[ "$done_scopes" -lt "$total_scopes" ]] && [[ "$total_scopes" -gt 0 ]]; then
          fail "completedPhases claims $claimed_phase_count lifecycle phases but only $done_scopes of $total_scopes scopes are Done — PHASE-SCOPE INCOHERENCE (Gate G027)"
        fi

        # Cross-check: completedScopes count should match done_scopes count
        if [[ "$state_completed_scopes_count" -gt 0 ]] && [[ "$done_scopes" -gt 0 ]]; then
          if [[ "$state_completed_scopes_count" -ne "$done_scopes" ]]; then
            warn "completedScopes count ($state_completed_scopes_count) does not match artifact Done count ($done_scopes)"
          else
            pass "completedScopes ($state_completed_scopes_count) matches artifact Done scopes ($done_scopes)"
          fi
        fi
      fi

      # If completedScopes > 0 but implement phase not claimed, that's also incoherent
      if [[ "$state_completed_scopes_count" -gt 0 ]] && [[ "$has_implement" == "false" ]]; then
        warn "completedScopes has $state_completed_scopes_count entries but 'implement' phase not in completedPhases"
      fi

      if [[ "$has_implement" == "true" ]] && [[ "$done_scopes" -gt 0 ]] && [[ "$state_completed_scopes_count" -gt 0 ]]; then
        pass "Phase-Scope coherence verified: implementation phases align with completed scopes"
      fi
      ;;
    *)
      info "Workflow mode '$state_workflow_mode' does not require phase-scope coherence check"
      ;;
  esac
fi
echo ""

# =============================================================================
# CHECK 16: Implementation Reality Scan (Gate G028)
# =============================================================================
# Runs implementation-reality-scan.sh to detect stub/fake/hardcoded
# data patterns in source files referenced by scope artifacts.
# =============================================================================
echo "--- Check 16: Implementation Reality Scan (Gate G028) ---"
reality_scan_script=".github/bubbles/scripts/implementation-reality-scan.sh"
if [[ -f "$reality_scan_script" ]]; then
  # Only run for modes that involve implementation
  run_reality_scan="false"
  case "$state_workflow_mode" in
    full-delivery|full-delivery-strict|value-first-e2e-batch|feature-bootstrap|bugfix-fastlane|chaos-hardening|harden-to-doc|gaps-to-doc|harden-gaps-to-doc|reconcile-to-doc|test-to-doc|chaos-to-doc|batch-implement|batch-harden|batch-gaps|batch-harden-gaps|batch-improve-existing|batch-reconcile-to-doc|product-to-delivery|improve-existing)
      run_reality_scan="true"
      ;;
  esac

  if [[ "$run_reality_scan" == "true" ]]; then
    reality_output="$(bash "$reality_scan_script" "$feature_dir" --verbose 2>&1 || true)"
    reality_exit="$?"

    # Show condensed output
    violation_count="$(echo "$reality_output" | grep -c '🔴 VIOLATION' || true)"
    if [[ "$violation_count" -gt 0 ]]; then
      fail "Implementation reality scan found $violation_count source code violation(s) — STUB/FAKE DATA DETECTED (Gate G028)"
      # Show first 10 violations
      echo "$reality_output" | grep '🔴 VIOLATION' | head -10
      if [[ "$violation_count" -gt 10 ]]; then
        info "... and $((violation_count - 10)) more violation(s). Run 'bash $reality_scan_script $feature_dir --verbose' for full details."
      fi
    else
      pass "Implementation reality scan passed — no stub/fake/hardcoded data patterns detected"
    fi
  else
    info "Workflow mode '$state_workflow_mode' does not require implementation reality scan"
  fi
else
  warn "Implementation reality scan script not found at $reality_scan_script — cannot enforce Gate G028"
fi
echo ""

# =============================================================================
# FINAL VERDICT
# =============================================================================
echo "============================================================"
echo "  TRANSITION GUARD VERDICT"
echo "============================================================"
echo ""

if [[ "$failures" -gt 0 ]]; then
  echo "🔴 TRANSITION BLOCKED: $failures failure(s), $warnings warning(s)"
  echo ""
  echo "state.json status MUST NOT be set to 'done'."
  echo "Fix ALL blocking failures above before attempting promotion."
  echo ""

  if [[ "$revert_on_fail" == "true" ]] && [[ -f "$state_file" ]]; then
    echo "--- Auto-Reverting state.json (--revert-on-fail) ---"
    now_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    # Revert status to in_progress
    sed -i -E 's/"status"[[:space:]]*:[[:space:]]*"done"/"status": "in_progress"/' "$state_file"

    # Clear completedScopes if it contains items
    if grep -qE '"completedScopes"[[:space:]]*:[[:space:]]*\[' "$state_file"; then
      # Replace completedScopes array with empty array (single-line case)
      sed -i -E 's/"completedScopes"[[:space:]]*:[[:space:]]*\[[^]]*\]/"completedScopes": []/' "$state_file"
    fi

    # Clear completedPhases if it contains items
    if grep -qE '"completedPhases"[[:space:]]*:[[:space:]]*\[' "$state_file"; then
      # For multi-line completedPhases, use awk
      awk '
        /"completedPhases"[[:space:]]*:/ {
          print "  \"completedPhases\": [],"
          in_array = 1
          next
        }
        in_array && /\]/ {
          in_array = 0
          next
        }
        in_array { next }
        { print }
      ' "$state_file" > "${state_file}.tmp" && mv "${state_file}.tmp" "$state_file"
    fi

    # Update lastUpdatedAt
    sed -i -E 's/"lastUpdatedAt"[[:space:]]*:[[:space:]]*"[^"]+"/"lastUpdatedAt": "'"$now_utc"'"/' "$state_file"

    # Add failure record if failures array exists
    if grep -qE '"failures"[[:space:]]*:[[:space:]]*\[' "$state_file"; then
      failure_record="{\"phase\": \"transition-guard\", \"summary\": \"$failures blocking failures detected by state-transition-guard.sh\", \"detectedAt\": \"$now_utc\"}"
      # Append to failures array (simple single-line case)
      sed -i -E "s|\"failures\"[[:space:]]*:[[:space:]]*\[|\"failures\": [$failure_record, |" "$state_file"
      # Clean up empty trailing comma if array was empty
      sed -i -E 's/\[({[^}]+}), \]/[\1]/' "$state_file"
    fi

    echo "REVERTED: state.json status → 'in_progress'"
    echo "REVERTED: completedScopes → []"
    echo "REVERTED: completedPhases → []"
    echo "ADDED: failure record with timestamp $now_utc"
  fi

  # ── Run project-defined custom gates (G100+) ───────────────────────
  PROJECT_CONFIG=".github/bubbles-project.yaml"
  if [[ -f "$PROJECT_CONFIG" ]]; then
    echo ""
    echo "🔍 Running project-defined gates from $PROJECT_CONFIG..."
    while IFS= read -r line; do
      script_path=$(echo "$line" | sed 's/.*script:\s*//' | tr -d '[:space:]')
      [[ -z "$script_path" ]] && continue
      full_path=".github/$script_path"
      gate_name=$(grep -B5 "script:.*$script_path" "$PROJECT_CONFIG" | grep -oE '^\s+\S+:$' | tail -1 | tr -d '[:space:]:')
      if [[ -x "$full_path" ]]; then
        echo "  Running: $gate_name ($full_path)"
        if bash "$full_path"; then
          echo "  ✅ $gate_name passed"
        else
          blocking=$(grep -A2 "script:.*$script_path" "$PROJECT_CONFIG" | grep "blocking:" | sed 's/.*blocking:\s*//' | tr -d '[:space:]')
          if [[ "$blocking" == "true" ]]; then
            fail "Project gate BLOCKED: $gate_name ($full_path)"
          else
            warn "Project gate warning: $gate_name ($full_path)"
          fi
        fi
      else
        warn "Project gate script not found or not executable: $full_path"
      fi
    done < <(grep "script:" "$PROJECT_CONFIG")
  fi

  exit 1
else
  if [[ "$warnings" -gt 0 ]]; then
    echo "🟡 TRANSITION PERMITTED with $warnings warning(s)"
  else
    echo "🟢 TRANSITION PERMITTED: All checks pass ($failures failures, $warnings warnings)"
    fun_summary pass
  fi
  echo ""
  case "$state_workflow_mode:$state_status" in
    spec-scope-hardening:specs_hardened)
      echo "state.json is correctly set to 'specs_hardened' for workflowMode 'spec-scope-hardening'."
      ;;
    docs-only:docs_updated)
      echo "state.json is correctly set to 'docs_updated' for workflowMode 'docs-only'."
      ;;
    validate-only:validated|audit-only:validated)
      echo "state.json is correctly set to 'validated' for workflowMode '$state_workflow_mode'."
      ;;
    resume-only:in_progress)
      echo "state.json is correctly set to 'in_progress' for workflowMode 'resume-only'."
      ;;
    *)
      echo "state.json status may be set to 'done'."
      ;;
  esac
  exit 0
fi
