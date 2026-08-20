#!/usr/bin/env bash
set -uo pipefail

# BUG-022 persistent production-path regression for Bash 3.2 empty indexed
# arrays under nounset. Canonical cases always run the unmodified source guard.
# Repaired-reference copies exist only to prove each adversarial mutant.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_GUARD="$REPO_ROOT/bubbles/scripts/state-transition-guard.sh"
SOURCE_PLANNING_CHECKS="$REPO_ROOT/bubbles/scripts/guards/planning-checks.sh"
SOURCE_CONTROL_PLANE_CHECKS="$REPO_ROOT/bubbles/scripts/guards/control-plane-checks.sh"
SOURCE_GUARD_SELFTEST="$REPO_ROOT/bubbles/scripts/state-transition-guard-selftest.sh"
SOURCE_INSTALL_PROVENANCE="$REPO_ROOT/bubbles/scripts/install-provenance-selftest.sh"
SOURCE_TEST_26="$REPO_ROOT/tests/regression/test_26_state_transition_spec_mjs_path.sh"
SOURCE_TEST_27="$REPO_ROOT/tests/regression/test_27_state_transition_bash32_startup.sh"
SOURCE_TEST_28="$REPO_ROOT/tests/regression/test_28_framework_validate_portable_timeout.sh"
SOURCE_FUN_MODE="$REPO_ROOT/bubbles/scripts/fun-mode.sh"
SOURCE_FRAMEWORK_VALIDATE="$REPO_ROOT/bubbles/scripts/framework-validate.sh"
SOURCE_RELEASE_MANIFEST="$REPO_ROOT/bubbles/release-manifest.json"
SOURCE_BUGS_INDEX="$REPO_ROOT/BUGS.md"
SOURCE_INSTALLER="$REPO_ROOT/install.sh"
TEST_FILE="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
TEST_RELATIVE_PATH="tests/regression/$(basename "${BASH_SOURCE[0]}")"
RUN_SHELL="$BASH"

for required_path in \
  "$SOURCE_GUARD" \
  "$SOURCE_PLANNING_CHECKS" \
  "$SOURCE_CONTROL_PLANE_CHECKS" \
  "$SOURCE_GUARD_SELFTEST" \
  "$SOURCE_INSTALL_PROVENANCE" \
  "$SOURCE_TEST_26" \
  "$SOURCE_TEST_27" \
  "$SOURCE_TEST_28" \
  "$SOURCE_FUN_MODE" \
  "$SOURCE_FRAMEWORK_VALIDATE" \
  "$SOURCE_RELEASE_MANIFEST" \
  "$SOURCE_BUGS_INDEX" \
  "$SOURCE_INSTALLER" \
  "$TEST_FILE"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_29_state_transition_bash32_empty_array_nounset: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done
if [[ ! -d "$REPO_ROOT/bubbles" || ! -d "$REPO_ROOT/agents" ]]; then
  printf '%s\n' 'test_29_state_transition_bash32_empty_array_nounset: canonical framework surfaces are missing' >&2
  exit 2
fi
if [[ -z "$RUN_SHELL" || ! -x "$RUN_SHELL" ]]; then
  printf 'test_29_state_transition_bash32_empty_array_nounset: active Bash is not executable: %s\n' "$RUN_SHELL" >&2
  exit 2
fi

for required_command in awk cat chmod cp cut dirname env find git grep jq mkdir mktemp mv rm sed sort tr uname wc yq; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_29_state_transition_bash32_empty_array_nounset: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done
if ! command -v sha256sum >/dev/null 2>&1 && ! command -v shasum >/dev/null 2>&1; then
  printf '%s\n' 'test_29_state_transition_bash32_empty_array_nounset: SHA-256 provider unavailable' >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug022-XXXXXXXX")"
REPAIRED_REFERENCE_ROOT="$WORKSPACE/repaired-reference"
RUN_OUTPUT_FILE=""
RUN_STATUS=0
RUN_NAME=""
PASS_COUNT=0
CONTRACT_FAILURES=0
PRIMARY_CONTRACT_FAILURES=0
CONTROL_FAILURES=0
HARNESS_FAILURES=0
ASSERTION_CONTEXT="control"
GUARD_RUNS=0
PRIMARY_RUNS=0
REFERENCE_CONTROL_RUNS=0
PRIMARY_INTENDED_NOUNSET_ABORTS=0
PRIMARY_UNRELATED_ABORTS=0
FAMILY_MUTANT_RUNS=0
SITE_MUTANT_RUNS=0
SITE_MUTANT_REJECTIONS=0
INVENTORY_MAPPED_GUARDED=0
INVENTORY_MAPPED_RAW=0
INVENTORY_ERRORS=0
RAW_EMPTY_ARRAY_ABORTS=""
MODULE_INVENTORY_MAPPED_GUARDED=0
MODULE_INVENTORY_MAPPED_RAW=0
MODULE_INVENTORY_ERRORS=0

cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

contract_fail() {
  CONTRACT_FAILURES=$((CONTRACT_FAILURES + 1))
  if [[ "$ASSERTION_CONTEXT" == "primary" ]]; then
    PRIMARY_CONTRACT_FAILURES=$((PRIMARY_CONTRACT_FAILURES + 1))
  else
    CONTROL_FAILURES=$((CONTROL_FAILURES + 1))
  fi
  printf 'FAIL-CONTRACT: %s\n' "$1" >&2
}

harness_fail() {
  HARNESS_FAILURES=$((HARNESS_FAILURES + 1))
  printf 'FAIL-HARNESS: %s\n' "$1" >&2
}

harness_die() {
  harness_fail "$1"
  printf '%s\n' 'BUG-022 regression cannot continue because fixture integrity failed.' >&2
  exit 2
}

file_digest() {
  local digest_output
  if command -v sha256sum >/dev/null 2>&1; then
    digest_output="$(sha256sum "$1")"
  else
    digest_output="$(shasum -a 256 "$1")"
  fi
  set -- $digest_output
  printf '%s\n' "$1"
}

file_bytes() {
  local byte_output
  byte_output="$(wc -c "$1")"
  set -- $byte_output
  printf '%s\n' "$1"
}

extract_check8_region() {
  local source_file="$1"
  local output_file="$2"
  awk '
    /^# CHECK 8: Test file existence/ { active=1 }
    /^# CHECK 9:/ { active=0; found_end=1 }
    active { print }
    END { if (!found_end) exit 3 }
  ' "$source_file" >"$output_file" || return $?
  [[ -s "$output_file" ]]
}

extract_bug012_tail_comment_region() {
  local source_file="$1"
  local output_file="$2"
  awk '
    /^# The guard is source-aware\. In the Bubbles source repository, persistent/ { active=1 }
    /^if \[\[ "\$\{BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST:-0\}" == "1" \]\]; then/ {
      active=0
      found_end=1
    }
    active { print }
    END { if (!found_end) exit 3 }
  ' "$source_file" >"$output_file" || return $?
  [[ -s "$output_file" ]]
}

emit_mapped_sites() {
  cat <<'SITES'
ACC-PASS|passed_gate_ids|1|result-accumulation
RESULT-PASSED-LOOP|passed_gate_ids|2|result-construction
RESULT-PASSED-FILTER|passed_gate_ids|3|result-construction
ACC-FAILED-GATE|failed_gate_ids|1|result-accumulation
RESULT-FAILED-FILTER|failed_gate_ids|2|result-construction
RESULT-FAILED-GATE-FORMAT|failed_gate_ids|3|result-serialization
TELEMETRY-PASSED-FILTER|failed_gate_ids|4|telemetry
TELEMETRY-FAILED-LOOP|failed_gate_ids|5|telemetry
FINAL-GATE-LOOKUP|failed_gate_ids|6|final-classification
ACC-FAILED-CHECK|failed_check_ids|1|result-accumulation
RESULT-FAILED-CHECK-FORMAT|failed_check_ids|2|result-serialization
RESULT-REQUIRED-LOOP|transition_required_gate_ids|1|result-construction
RESULT-APPLICABLE-FORMAT|transition_applicable_check_classes|1|result-serialization
RESULT-NOT-APPLICABLE-FORMAT|transition_not_applicable_checks|1|result-serialization
NOT-APPLICABLE-LOOKUP|transition_not_applicable_checks|2|applicability
RESULT-PASSED-FORMAT|effective_passed_gate_ids|1|result-serialization
SCOPE-BUILD-UNITS|scope_files|1|scope-discovery
SCOPE-COPY|scope_files|2|scope-discovery
SCOPE-LABELS|scope_files|3|scope-discovery
SCOPE-GHERKIN|scope_files|5|scope-discovery
SCOPE-REPORT-CHECK|scope_files|6|scope-discovery
SCOPE-DOD-COUNT|scope_files|7|scope-discovery
SCOPE-DOD-DIAGNOSTICS|scope_files|8|scope-discovery
SCOPE-DOD-FORMAT|scope_files|9|scope-discovery
SCOPE-STATUS-VOCAB|scope_files|10|scope-discovery
SCOPE-STATUS-AGGREGATE|scope_files|11|scope-discovery
SCOPE-PLANNING-HONESTY|scope_files|12|scope-discovery
SCOPE-INDEX-PARITY|scope_files|13|scope-discovery
SCOPE-PHANTOM-CHECK|scope_files|14|scope-discovery
SCOPE-SLA-SCAN|scope_files|15|scope-discovery
SCOPE-CHECK8-PATHS|scope_files|16|scope-discovery
SCOPE-DOD-EVIDENCE|scope_files|17|scope-discovery
SCOPE-TEMPLATE-SCAN|scope_files|18|scope-discovery
SCOPE-DUPLICATE-EVIDENCE|scope_files|19|scope-discovery
SCOPE-IMPLEMENTATION-PATHS|scope_files|20|scope-discovery
SCOPE-DEFERRAL-SCAN|scope_files|21|scope-discovery
SCOPE-ENV-FAILURE-SCAN|scope_files|22|scope-discovery
SCOPE-EVIDENCE-SIMILARITY|scope_files|23|scope-discovery
REPORT-TEMPLATE-SCAN|report_files|1|report-discovery
REPORT-REQUIRED-SECTIONS|report_files|2|report-discovery
REPORT-DUPLICATE-EVIDENCE|report_files|3|report-discovery
REPORT-DELTA-EVIDENCE|report_files|4|report-discovery
REPORT-DEFERRAL-SCAN|report_files|5|report-discovery
REPORT-ENV-FAILURE-SCAN|report_files|6|report-discovery
SITES
}

emit_module_mapped_sites() {
  cat <<'SITES'
PLANNING-CHANGE-BOUNDARY-SCOPE|guards/planning-checks.sh|scope_files|1|scope-discovery
CONTROL-PLANE-TDD-SCOPES|guards/control-plane-checks.sh|scope_files|1|control-plane
CONTROL-PLANE-TDD-REPORTS|guards/control-plane-checks.sh|report_files|1|control-plane
SITES
}

site_metadata() {
  local wanted_array="$1"
  local wanted_ordinal="$2"
  local site_id=""
  local array_name=""
  local ordinal=""
  local family=""

  SITE_ID=""
  SITE_FAMILY=""
  while IFS='|' read -r site_id array_name ordinal family; do
    if [[ "$array_name" == "$wanted_array" && "$ordinal" -eq "$wanted_ordinal" ]]; then
      SITE_ID="$site_id"
      SITE_FAMILY="$family"
      return 0
    fi
  done < <(emit_mapped_sites)

  if [[ "$wanted_array" == "scope_files" && "$wanted_ordinal" -eq 4 ]]; then
    SITE_ID="CONTROL-SCOPE-POSITIVE-COUNT"
    SITE_FAMILY="control"
    return 0
  fi
  return 1
}

next_array_ordinal() {
  case "$1" in
    passed_gate_ids) COUNT_PASSED=$((COUNT_PASSED + 1)); CURRENT_ORDINAL="$COUNT_PASSED" ;;
    failed_gate_ids) COUNT_FAILED_GATE=$((COUNT_FAILED_GATE + 1)); CURRENT_ORDINAL="$COUNT_FAILED_GATE" ;;
    failed_check_ids) COUNT_FAILED_CHECK=$((COUNT_FAILED_CHECK + 1)); CURRENT_ORDINAL="$COUNT_FAILED_CHECK" ;;
    transition_required_gate_ids) COUNT_REQUIRED=$((COUNT_REQUIRED + 1)); CURRENT_ORDINAL="$COUNT_REQUIRED" ;;
    transition_applicable_check_classes) COUNT_APPLICABLE=$((COUNT_APPLICABLE + 1)); CURRENT_ORDINAL="$COUNT_APPLICABLE" ;;
    transition_not_applicable_checks) COUNT_NOT_APPLICABLE=$((COUNT_NOT_APPLICABLE + 1)); CURRENT_ORDINAL="$COUNT_NOT_APPLICABLE" ;;
    effective_passed_gate_ids) COUNT_EFFECTIVE=$((COUNT_EFFECTIVE + 1)); CURRENT_ORDINAL="$COUNT_EFFECTIVE" ;;
    scope_files) COUNT_SCOPE=$((COUNT_SCOPE + 1)); CURRENT_ORDINAL="$COUNT_SCOPE" ;;
    report_files) COUNT_REPORT=$((COUNT_REPORT + 1)); CURRENT_ORDINAL="$COUNT_REPORT" ;;
    evidence_hashes) COUNT_EVIDENCE=$((COUNT_EVIDENCE + 1)); CURRENT_ORDINAL="$COUNT_EVIDENCE" ;;
    *) return 1 ;;
  esac
}

scan_inventory() {
  local source_file="$1"
  local output_file="$2"
  local line=""
  local line_number=0
  local array_name=""
  local raw_token=""
  local guarded_token=""
  local observed=""
  local mapped_guarded=0
  local mapped_raw=0
  local control_raw=0
  local control_guarded=0
  local errors=0

  COUNT_PASSED=0
  COUNT_FAILED_GATE=0
  COUNT_FAILED_CHECK=0
  COUNT_REQUIRED=0
  COUNT_APPLICABLE=0
  COUNT_NOT_APPLICABLE=0
  COUNT_EFFECTIVE=0
  COUNT_SCOPE=0
  COUNT_REPORT=0
  COUNT_EVIDENCE=0
  : >"$output_file"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_number=$((line_number + 1))
    while IFS= read -r array_name; do
      raw_token='${'"$array_name"'[@]}'
      guarded_token='${'"$array_name"'[@]+"${'"$array_name"'[@]}"}'
      observed=""
      if [[ "$line" == *"$guarded_token"* ]]; then
        observed="guarded"
      elif [[ "$line" == *"$raw_token"* ]]; then
        observed="raw"
      fi
      [[ -n "$observed" ]] || continue

      next_array_ordinal "$array_name" || {
        printf 'INVENTORY_ERROR line=%s unknown_array=%s\n' "$line_number" "$array_name" >>"$output_file"
        errors=$((errors + 1))
        continue
      }
      if ! site_metadata "$array_name" "$CURRENT_ORDINAL"; then
        printf 'INVENTORY_ERROR line=%s array=%s ordinal=%s unexpected_site\n' \
          "$line_number" "$array_name" "$CURRENT_ORDINAL" >>"$output_file"
        errors=$((errors + 1))
        continue
      fi

      if [[ "$SITE_FAMILY" == "control" ]]; then
        if [[ "$observed" == "raw" ]]; then
          control_raw=$((control_raw + 1))
        else
          control_guarded=$((control_guarded + 1))
          errors=$((errors + 1))
        fi
        printf 'INVENTORY_CONTROL site=%s line=%s array=%s ordinal=%s expected=raw observed=%s\n' \
          "$SITE_ID" "$line_number" "$array_name" "$CURRENT_ORDINAL" "$observed" >>"$output_file"
      else
        if [[ "$observed" == "guarded" ]]; then
          mapped_guarded=$((mapped_guarded + 1))
        else
          mapped_raw=$((mapped_raw + 1))
        fi
        printf 'INVENTORY_SITE site=%s family=%s line=%s array=%s ordinal=%s expected=guarded observed=%s\n' \
          "$SITE_ID" "$SITE_FAMILY" "$line_number" "$array_name" "$CURRENT_ORDINAL" "$observed" >>"$output_file"
      fi
    done <<'ARRAYS'
passed_gate_ids
failed_gate_ids
failed_check_ids
transition_required_gate_ids
transition_applicable_check_classes
transition_not_applicable_checks
effective_passed_gate_ids
scope_files
report_files
evidence_hashes
ARRAYS
  done <"$source_file"

  if [[ "$COUNT_PASSED" -ne 3 \
    || "$COUNT_FAILED_GATE" -ne 6 \
    || "$COUNT_FAILED_CHECK" -ne 2 \
    || "$COUNT_REQUIRED" -ne 1 \
    || "$COUNT_APPLICABLE" -ne 1 \
    || "$COUNT_NOT_APPLICABLE" -ne 2 \
    || "$COUNT_EFFECTIVE" -ne 1 \
    || "$COUNT_SCOPE" -ne 23 \
    || "$COUNT_REPORT" -ne 6 \
    || "$COUNT_EVIDENCE" -ne 0 ]]; then
    printf 'INVENTORY_ERROR unexpected_counts passed=%s failedGate=%s failedCheck=%s required=%s applicable=%s notApplicable=%s effective=%s scope=%s report=%s evidence=%s\n' \
      "$COUNT_PASSED" "$COUNT_FAILED_GATE" "$COUNT_FAILED_CHECK" "$COUNT_REQUIRED" \
      "$COUNT_APPLICABLE" "$COUNT_NOT_APPLICABLE" "$COUNT_EFFECTIVE" "$COUNT_SCOPE" \
      "$COUNT_REPORT" "$COUNT_EVIDENCE" >>"$output_file"
    errors=$((errors + 1))
  fi
  if [[ $((mapped_guarded + mapped_raw)) -ne 44 ]]; then
    printf 'INVENTORY_ERROR mapped_total=%s expected=44\n' "$((mapped_guarded + mapped_raw))" >>"$output_file"
    errors=$((errors + 1))
  fi

  printf 'INVENTORY_SUMMARY mappedGuarded=%s mappedRaw=%s controlRaw=%s controlGuarded=%s errors=%s\n' \
    "$mapped_guarded" "$mapped_raw" "$control_raw" "$control_guarded" "$errors" >>"$output_file"
  INVENTORY_MAPPED_GUARDED="$mapped_guarded"
  INVENTORY_MAPPED_RAW="$mapped_raw"
  INVENTORY_ERRORS="$errors"

  [[ "$mapped_guarded" -eq 44 \
    && "$mapped_raw" -eq 0 \
    && "$control_raw" -eq 1 \
    && "$control_guarded" -eq 0 \
    && "$errors" -eq 0 ]]
}

observed_site_kind() {
  local source_file="$1"
  local array_name="$2"
  local wanted_ordinal="$3"
  local raw_token='${'"$array_name"'[@]}'
  local guarded_token='${'"$array_name"'[@]+"${'"$array_name"'[@]}"}'
  awk -v raw="$raw_token" -v guarded="$guarded_token" -v wanted="$wanted_ordinal" '
    {
      kind=""
      if (index($0, guarded) > 0) kind="guarded"
      else if (index($0, raw) > 0) kind="raw"
      if (kind != "") {
        count++
        if (count == wanted) {
          print kind
          found=1
          exit
        }
      }
    }
    END { if (!found) exit 3 }
  ' "$source_file"
}

rewrite_site() {
  local source_file="$1"
  local array_name="$2"
  local wanted_ordinal="$3"
  local from_kind="$4"
  local to_kind="$5"
  local temporary="$source_file.bug022-rewrite"
  local raw_token='${'"$array_name"'[@]}'
  local guarded_token='${'"$array_name"'[@]+"${'"$array_name"'[@]}"}'
  local old_token=""
  local new_token=""
  local rewrite_status=0

  if [[ "$from_kind" == "raw" && "$to_kind" == "guarded" ]]; then
    old_token="$raw_token"
    new_token="$guarded_token"
  elif [[ "$from_kind" == "guarded" && "$to_kind" == "raw" ]]; then
    old_token="$guarded_token"
    new_token="$raw_token"
  else
    harness_die "unsupported site rewrite: $from_kind -> $to_kind"
  fi

  awk -v raw="$raw_token" -v guarded="$guarded_token" -v old="$old_token" -v new="$new_token" \
    -v wanted="$wanted_ordinal" -v required_kind="$from_kind" '
    {
      kind=""
      if (index($0, guarded) > 0) kind="guarded"
      else if (index($0, raw) > 0) kind="raw"
      if (kind != "") count++
      if (count == wanted && kind != "" && !done) {
        if (kind != required_kind) exit 41
        position=index($0, old)
        if (position == 0) exit 42
        $0=substr($0, 1, position - 1) new substr($0, position + length(old))
        replacements++
        done=1
      }
      print
    }
    END { if (replacements != 1) exit 43 }
  ' "$source_file" >"$temporary" || rewrite_status=$?
  if [[ "$rewrite_status" -ne 0 ]]; then
    rm -f "$temporary"
    harness_die "site rewrite failed for array=$array_name ordinal=$wanted_ordinal status=$rewrite_status"
  fi
  mv "$temporary" "$source_file"
}

normalize_repaired_reference() {
  local source_file="$1"
  local site_id=""
  local array_name=""
  local ordinal=""
  local family=""
  local observed=""

  while IFS='|' read -r site_id array_name ordinal family; do
    observed="$(observed_site_kind "$source_file" "$array_name" "$ordinal")" || \
      harness_die "cannot resolve mapped site $site_id"
    if [[ "$observed" == "raw" ]]; then
      rewrite_site "$source_file" "$array_name" "$ordinal" raw guarded
    elif [[ "$observed" != "guarded" ]]; then
      harness_die "mapped site $site_id has unknown kind: $observed"
    fi
  done < <(emit_mapped_sites)
}

normalize_repaired_modules() {
  local scripts_root="$1"
  local site_id=""
  local relative_path=""
  local array_name=""
  local ordinal=""
  local family=""
  local source_file=""
  local observed=""

  while IFS='|' read -r site_id relative_path array_name ordinal family; do
    source_file="$scripts_root/$relative_path"
    observed="$(observed_site_kind "$source_file" "$array_name" "$ordinal")" || \
      harness_die "cannot resolve sourced-module site $site_id"
    if [[ "$observed" == "raw" ]]; then
      rewrite_site "$source_file" "$array_name" "$ordinal" raw guarded
    elif [[ "$observed" != "guarded" ]]; then
      harness_die "sourced-module site $site_id has unknown kind: $observed"
    fi
  done < <(emit_module_mapped_sites)
}

scan_module_inventory() {
  local scripts_root="$1"
  local output_file="$2"
  local site_id=""
  local relative_path=""
  local array_name=""
  local ordinal=""
  local family=""
  local source_file=""
  local observed=""
  local mapped_guarded=0
  local mapped_raw=0
  local errors=0

  : >"$output_file"
  while IFS='|' read -r site_id relative_path array_name ordinal family; do
    source_file="$scripts_root/$relative_path"
    if [[ ! -f "$source_file" ]]; then
      printf 'MODULE_INVENTORY_ERROR site=%s missing=%s\n' "$site_id" "$relative_path" >>"$output_file"
      errors=$((errors + 1))
      continue
    fi
    observed="$(observed_site_kind "$source_file" "$array_name" "$ordinal")" || observed="missing"
    case "$observed" in
      guarded) mapped_guarded=$((mapped_guarded + 1)) ;;
      raw) mapped_raw=$((mapped_raw + 1)) ;;
      *) errors=$((errors + 1)) ;;
    esac
    printf 'MODULE_INVENTORY_SITE site=%s family=%s file=%s array=%s ordinal=%s expected=guarded observed=%s\n' \
      "$site_id" "$family" "$relative_path" "$array_name" "$ordinal" "$observed" >>"$output_file"
  done < <(emit_module_mapped_sites)

  if [[ $((mapped_guarded + mapped_raw)) -ne 3 ]]; then
    printf 'MODULE_INVENTORY_ERROR mapped_total=%s expected=3\n' "$((mapped_guarded + mapped_raw))" >>"$output_file"
    errors=$((errors + 1))
  fi
  printf 'MODULE_INVENTORY_SUMMARY mappedGuarded=%s mappedRaw=%s errors=%s\n' \
    "$mapped_guarded" "$mapped_raw" "$errors" >>"$output_file"
  MODULE_INVENTORY_MAPPED_GUARDED="$mapped_guarded"
  MODULE_INVENTORY_MAPPED_RAW="$mapped_raw"
  MODULE_INVENTORY_ERRORS="$errors"

  [[ "$mapped_guarded" -eq 3 && "$mapped_raw" -eq 0 && "$errors" -eq 0 ]]
}

replace_literal_all() {
  local source_file="$1"
  local old_text="$2"
  local new_text="$3"
  local temporary="$source_file.bug022-literal"
  awk -v old="$old_text" -v new="$new_text" '
    {
      line=$0
      while ((position=index(line, old)) > 0) {
        line=substr(line, 1, position - 1) new substr(line, position + length(old))
        replacements++
      }
      print line
    }
    END { if (replacements == 0) exit 3 }
  ' "$source_file" >"$temporary" || {
    rm -f "$temporary"
    harness_die "fixture replacement did not match: $old_text"
  }
  mv "$temporary" "$source_file"
}

write_test_control() {
  local repo_root="$1"
  mkdir -p "$repo_root/tests"
  cat >"$repo_root/tests/example.sh" <<'SHELL'
#!/usr/bin/env bash
printf '%s\n' 'BUG-022 fixture test control'
SHELL
  chmod +x "$repo_root/tests/example.sh"
}

write_delivery_packet() {
  local feature_dir="$1"
  mkdir -p "$feature_dir"

  cat >"$feature_dir/spec.md" <<'MARKDOWN'
# BUG-022 Delivery Fixture Spec

## Purpose

Exercise zero, one, and multiple result cardinalities through the production guard.
MARKDOWN
  cat >"$feature_dir/design.md" <<'MARKDOWN'
# BUG-022 Delivery Fixture Design

## Approach

Use one complete disposable delivery packet and the real state-transition guard.
MARKDOWN
  cat >"$feature_dir/uservalidation.md" <<'MARKDOWN'
# User Validation

## Checklist

- [x] The production guard is exercised through a disposable packet.
MARKDOWN
  cat >"$feature_dir/report.md" <<'MARKDOWN'
# Report

### Summary

Disposable BUG-022 delivery fixture.

### Completion Statement

The packet supplies complete fixture evidence for result serialization.

### Test Evidence

```text
$ bash tests/example.sh
BUG-022 fixture setup complete
production guard invoked
structured result reached
scenario regression recorded
broader regression recorded
fixture remains disposable
fixture cleanup registered
guard output remains authoritative
exit code: 0
```
MARKDOWN
  cat >"$feature_dir/scopes.md" <<'MARKDOWN'
# Scope 01: BUG-022 Delivery Fixture

**Status:** Done

### Goal

Exercise the complete production result contract.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-api` | `tests/example.sh` | Scenario-specific result regression. | `bash tests/example.sh` | Yes |
| Regression E2E | `e2e-api` | `tests/example.sh` | Broader result regression. | `bash tests/example.sh` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for every new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes with result contract coverage -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is internally consistent -> Evidence: report.md#summary
MARKDOWN
  cat >"$feature_dir/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "autonomous-goal",
  "execution": {
    "completedPhaseClaims": ["test", "validate", "audit", "docs"]
  },
  "certification": {
    "status": "in_progress",
    "certifiedCompletedPhases": ["test", "validate", "audit", "docs"],
    "completedScopes": ["01-bug022-delivery-fixture"],
    "scopeProgress": [],
    "lockdownState": { "mode": "off", "lockedScenarioIds": [] }
  },
  "policySnapshot": {
    "grill": { "mode": "off", "source": "repo-default" },
    "tdd": { "mode": "off", "source": "repo-default" },
    "autoCommit": { "mode": "off", "source": "repo-default" },
    "lockdown": { "mode": "off", "source": "repo-default" },
    "regression": { "mode": "protect-existing-scenarios", "source": "repo-default" },
    "validation": { "mode": "required", "source": "workflow-forced" },
    "workflowMode": "autonomous-goal"
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": [
    { "phase": "test", "agent": "bubbles.test", "phasesExecuted": ["test"], "runStartedAt": "2026-03-27T10:00:00Z", "runCompletedAt": "2026-03-27T10:00:47Z" },
    { "phase": "validate", "agent": "bubbles.validate", "phasesExecuted": ["validate"], "runStartedAt": "2026-03-27T10:01:13Z", "runCompletedAt": "2026-03-27T10:02:31Z" },
    { "phase": "audit", "agent": "bubbles.audit", "phasesExecuted": ["audit"], "runStartedAt": "2026-03-27T10:03:02Z", "runCompletedAt": "2026-03-27T10:06:08Z" },
    { "phase": "docs", "agent": "bubbles.docs", "phasesExecuted": ["docs"], "runStartedAt": "2026-03-27T10:07:19Z", "runCompletedAt": "2026-03-27T10:11:44Z" }
  ]
}
JSON
}

write_planning_packet() {
  local feature_dir="$1"
  local variant="$2"
  local scope_file="$feature_dir/scopes.md"
  local report_file="$feature_dir/report.md"
  mkdir -p "$feature_dir"

  cat >"$feature_dir/spec.md" <<'MARKDOWN'
# BUG-022 Planning Fixture Spec

## Problem

A planning workflow must preserve honest incomplete delivery while the production guard evaluates planning maturity.

## User Scenarios & Testing

### SCN-BUG-022-FIXTURE-001 - Preserve planning maturity

```gherkin
Scenario: Planning maturity preserves honest incomplete delivery
Given a registry-bound planning packet
When the transition guard evaluates planning maturity
Then incomplete delivery remains honest and non-terminal
```

## Requirements

- **FR-BUG-022-FIXTURE-001:** Planning maturity preserves honest incomplete delivery.
MARKDOWN
  cat >"$feature_dir/design.md" <<'MARKDOWN'
# BUG-022 Planning Fixture Design

## Approach

Resolve the registry planning profile and exercise the real guard.

## Change Boundary

Only this disposable planning packet is evaluated.

## Consumer Impact Sweep

No public consumer changes in this fixture.

## Shared Infrastructure Impact Sweep

No persistent shared state is changed.
MARKDOWN
  cat >"$feature_dir/uservalidation.md" <<'MARKDOWN'
# User Validation

## Checklist

- [x] Planning and delivery outcomes remain visibly distinct.
MARKDOWN
  cat >"$report_file" <<'MARKDOWN'
# Report

### Summary

This report belongs to an honestly unimplemented planning scope.

### Completion Statement

No delivery completion is claimed at the planning ceiling.

### Test Evidence

Execution-evidence code blocks: zero. The implementation scope remains Not Started.

### Code Diff Evidence

No delivery implementation delta is claimed by this planning fixture.

### Scope Evidence

Scope 01 remains Not Started with implementation DoD unchecked.

### Validation Evidence

Validation evaluates planning maturity only.

### Audit Evidence

No delivery certification is claimed.
MARKDOWN
  cat >"$scope_file" <<'MARKDOWN'
# Scope 01: BUG-022 Planning Fixture

**Status:** Not Started

## Goal

Preserve honest incomplete delivery at the planning ceiling.

## Gherkin Scenarios

### SCN-BUG-022-FIXTURE-001 - Preserve planning maturity

```gherkin
Scenario: Planning maturity preserves honest incomplete delivery
Given a registry-bound planning packet
When the transition guard evaluates planning maturity
Then incomplete delivery remains honest and non-terminal
```

## Implementation Plan

1. Activate the registry planning profile.
2. Preserve structural and planning integrity checks.

## Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-api` | `tests/example.sh` | Scenario-specific planning regression. | `bash tests/example.sh` | Yes |
| Broader regression | `e2e-api` | `tests/example.sh` | Preserve planning and delivery profile isolation. | `bash tests/example.sh` | Yes |

### Definition of Done

- [ ] Planning maturity preserves honest incomplete delivery for SCN-BUG-022-FIXTURE-001.
- [ ] Scenario-specific E2E regression tests for every new/changed/fixed behavior.
- [ ] Broader E2E regression suite passes with profile isolation active.
MARKDOWN
  cat >"$feature_dir/scenario-manifest.json" <<'JSON'
{
  "version": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-BUG-022-FIXTURE-001",
      "title": "Planning maturity preserves honest incomplete delivery",
      "status": "planned",
      "scope": "Scope 01",
      "requirements": ["FR-BUG-022-FIXTURE-001"],
      "requiredTestType": "e2e-api",
      "linkedTests": ["tests/example.sh"],
      "evidenceRefs": []
    }
  ]
}
JSON
  cat >"$feature_dir/state.json" <<'JSON'
{
  "version": 3,
  "status": "specs_hardened",
  "workflowMode": "product-to-planning",
  "planningOnly": true,
  "planMaturityOnly": true,
  "planningOnlyJustification": "This fixture evaluates planning maturity without delivery claims.",
  "execution": {
    "currentScope": null,
    "currentPhase": "bootstrap",
    "completedPhaseClaims": ["analyze", "bootstrap"]
  },
  "certification": {
    "status": "specs_hardened",
    "certifiedCompletedPhases": ["analyze", "bootstrap"],
    "completedScopes": [],
    "scopeProgress": [
      { "scopeId": "S01", "scopeName": "Honest Planning Maturity", "status": "not_started" }
    ],
    "lockdownState": { "mode": "off", "lockedScenarioIds": [] }
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
    { "phase": "analyze", "agent": "bubbles.analyst", "phasesExecuted": ["analyze"], "outcome": "completed_diagnostic", "runStartedAt": "2026-07-10T10:00:00Z", "runCompletedAt": "2026-07-10T10:01:13Z" },
    { "phase": "analyze", "agent": "bubbles.ux", "phasesExecuted": ["analyze"], "outcome": "completed_diagnostic", "runStartedAt": "2026-07-10T10:02:01Z", "runCompletedAt": "2026-07-10T10:04:29Z" },
    { "phase": "bootstrap", "agent": "bubbles.design", "phasesExecuted": ["bootstrap"], "outcome": "completed_diagnostic", "runStartedAt": "2026-07-10T10:05:17Z", "runCompletedAt": "2026-07-10T10:08:52Z" },
    { "phase": "bootstrap", "agent": "bubbles.plan", "phasesExecuted": ["bootstrap"], "outcome": "completed_diagnostic", "runStartedAt": "2026-07-10T10:09:31Z", "runCompletedAt": "2026-07-10T10:14:03Z" }
  ]
}
JSON

  case "$variant" in
    pass|g073)
      ;;
    untagged)
      replace_literal_all "$scope_file" '- [ ] Planning maturity preserves honest incomplete delivery for SCN-BUG-022-FIXTURE-001.' '- [x] Planning maturity preserves honest incomplete delivery for SCN-BUG-022-FIXTURE-001.'
      replace_literal_all "$scope_file" '- [ ] Scenario-specific E2E regression tests for every new/changed/fixed behavior.' '- [x] Scenario-specific E2E regression tests for every new/changed/fixed behavior.'
      ;;
    multiple-gates)
      replace_literal_all "$scope_file" '- [ ] Planning maturity preserves honest incomplete delivery for SCN-BUG-022-FIXTURE-001.' '- malformed required planning item'
      ;;
    evidence-one|evidence-distinct|evidence-duplicate)
      cat >>"$scope_file" <<'MARKDOWN'

    ```text
    $ bash tests/example.sh
    BUG-022 first evidence block
    PASS: production path observed
    exit code: 0
    ```
MARKDOWN
      if [[ "$variant" == "evidence-distinct" ]]; then
        cat >>"$scope_file" <<'MARKDOWN'

    ```text
    $ bash tests/example.sh --second
    BUG-022 distinct evidence block
    PASS: second production path observed
    exit code: 0
    ```
MARKDOWN
      elif [[ "$variant" == "evidence-duplicate" ]]; then
        cat >>"$scope_file" <<'MARKDOWN'

    ```text
    $ bash tests/example.sh
    BUG-022 first evidence block
    PASS: production path observed
    exit code: 0
    ```
MARKDOWN
      fi
      ;;
    empty-scopes)
      rm -f "$scope_file" "$report_file"
      mkdir -p "$feature_dir/scopes"
      cat >"$feature_dir/scopes/_index.md" <<'MARKDOWN'
# BUG-022 Empty Scope Index

| Scope | Status |
| --- | --- |
MARKDOWN
      ;;
    no-reports)
      rm -f "$scope_file" "$report_file"
      mkdir -p "$feature_dir/scopes/01-no-report"
      cat >"$feature_dir/scopes/_index.md" <<'MARKDOWN'
# BUG-022 No-Report Scope Index

| Scope | Status |
| --- | --- |
| [01-no-report](01-no-report/scope.md) | Not Started |
MARKDOWN
      cat >"$feature_dir/scopes/01-no-report/scope.md" <<'MARKDOWN'
# Scope 01: BUG-022 No-Report Fixture

**Status:** Not Started

## Goal

Exercise report discovery with one real scope and zero reports.

## Gherkin Scenarios

```gherkin
Scenario: Missing report remains a blocking structure finding
Given one per-scope planning artifact
When no per-scope report exists
Then the production guard reports the missing report
```

## Implementation Plan

1. Invoke the real state-transition guard.

## Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | `e2e-api` | `tests/example.sh` | Missing-report regression. | `bash tests/example.sh` | Yes |

### Definition of Done

- [ ] Missing reports remain blocking.
MARKDOWN
      ;;
    *)
      harness_die "unknown planning fixture variant: $variant"
      ;;
  esac
}

prepare_case_repo() {
  local case_name="$1"
  local framework_root="$2"
  local packet_kind="$3"
  local variant="$4"
  local repo_root="$WORKSPACE/cases/$case_name"
  local feature_dir=""

  rm -rf "$repo_root"
  mkdir -p "$repo_root"
  cp -R "$framework_root/bubbles" "$repo_root/bubbles"
  cp -R "$framework_root/agents" "$repo_root/agents"
  write_test_control "$repo_root"
  feature_dir="$repo_root/specs/900-$case_name"

  if [[ "$packet_kind" == "delivery" ]]; then
    write_delivery_packet "$feature_dir"
  elif [[ "$packet_kind" == "planning" ]]; then
    write_planning_packet "$feature_dir" "$variant"
  else
    harness_die "unknown packet kind: $packet_kind"
  fi

  git -C "$repo_root" init -q
  git -C "$repo_root" add -f bubbles agents specs tests
  git -C "$repo_root" -c user.name='Bubbles Regression' -c user.email='bubbles-regression@example.invalid' \
    commit -q -m "test: seed $case_name"

  if [[ "$variant" == "g073" || "$variant" == "multiple-gates" ]]; then
    mkdir -p "$repo_root/runtime"
    printf '%s\n' 'print("BUG-022 undeclared source edit")' >"$repo_root/runtime/undeclared.py"
    git -C "$repo_root" add -f runtime/undeclared.py
  fi

  CASE_REPO="$repo_root"
  CASE_FEATURE="$feature_dir"
  CASE_GUARD="$repo_root/bubbles/scripts/state-transition-guard.sh"
}

show_run_signals() {
  local output_file="$1"
  local line=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      *'BUBBLES STATE TRANSITION GUARD'* | \
      '--- Check 1:'* | \
      '--- Check 3B:'* | \
      '--- Check 4A:'* | \
      '--- Check 9:'* | \
      '--- Check 11:'* | \
      '--- Check 12:'* | \
      *'🔴 BLOCK:'* | \
      *'FAIL:'* | \
      *'E009-'* | \
      *'unbound variable'* | \
      *'Per-scope layout requires at least one'* | \
      *'Missing scope report for'* | \
      *'No report.md files were resolved'* | \
      *'Duplicate evidence blocks detected'* | \
      *'DoD item [x] has NO evidence block'* | \
      *'forbids source code edits'* | \
      *'format manipulation'* | \
      'BEGIN TRANSITION_GUARD_RESULT_V1' | \
      'workflowMode:'* | \
      'auditProfile:'* | \
      'targetStatus:'* | \
      'applicableCheckClasses:'* | \
      'notApplicableChecks:'* | \
      'passedGateIds:'* | \
      'failedGateIds:'* | \
      'failedChecks:'* | \
      'blockingCode:'* | \
      'failureCount:'* | \
      'exitStatus:'* | \
      'verdict:'* | \
      'END TRANSITION_GUARD_RESULT_V1')
        printf '  %s\n' "$line"
        ;;
    esac
  done <"$output_file"
}

run_guard_case() {
  local case_name="$1"
  local repo_root="$2"
  local guard="$3"
  local feature_dir="$4"

  GUARD_RUNS=$((GUARD_RUNS + 1))
  RUN_NAME="$case_name"
  RUN_OUTPUT_FILE="$WORKSPACE/run-$GUARD_RUNS-$case_name.log"
  RUN_STATUS=0
  if (
    cd "$repo_root"
    /usr/bin/env -i \
      HOME="$HOME" \
      PATH="$PATH" \
      BUBBLES_FUN_MODE=false \
      BUBBLES_REPO_ROOT="$repo_root" \
      BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1 \
      "$RUN_SHELL" "$guard" "$feature_dir"
  ) >"$RUN_OUTPUT_FILE" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  printf 'GUARD_CASE name=%s shell=%s bash=%s exit=%s\n' "$case_name" "$RUN_SHELL" "$BASH_VERSION" "$RUN_STATUS"
  show_run_signals "$RUN_OUTPUT_FILE"
}

output_contains() {
  grep -Fq -- "$2" "$1"
}

output_occurrences() {
  local output_file="$1"
  local needle="$2"
  local line=""
  local count=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *"$needle"* ]]; then
      count=$((count + 1))
    fi
  done <"$output_file"
  printf '%s\n' "$count"
}

assert_status() {
  local expected="$1"
  local label="$2"
  if [[ "$RUN_STATUS" -eq "$expected" ]]; then
    pass "$label"
  else
    contract_fail "$label (expected exit $expected, got $RUN_STATUS)"
  fi
}

assert_nonzero_status() {
  local label="$1"
  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass "$label"
  else
    contract_fail "$label (expected nonzero exit, got 0)"
  fi
}

assert_output_contains() {
  local expected="$1"
  local label="$2"
  if output_contains "$RUN_OUTPUT_FILE" "$expected"; then
    pass "$label"
  else
    contract_fail "$label (missing: $expected)"
  fi
}

assert_output_not_contains() {
  local forbidden="$1"
  local label="$2"
  if output_contains "$RUN_OUTPUT_FILE" "$forbidden"; then
    contract_fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

assert_output_occurrences() {
  local expected="$1"
  local needle="$2"
  local label="$3"
  local actual
  actual="$(output_occurrences "$RUN_OUTPUT_FILE" "$needle")"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label"
  else
    contract_fail "$label (expected $expected occurrence(s), got $actual: $needle)"
  fi
}

assert_complete_result() {
  local expected_status="$1"
  local expected_verdict="$2"
  local expected_blocking_code="$3"
  local label="$4"
  assert_status "$expected_status" "$label preserves process exit"
  assert_output_occurrences 1 'BEGIN TRANSITION_GUARD_RESULT_V1' "$label emits one result start"
  assert_output_occurrences 1 'END TRANSITION_GUARD_RESULT_V1' "$label emits one result end"
  assert_output_contains "blockingCode: $expected_blocking_code" "$label preserves blocking code"
  assert_output_contains "exitStatus: $expected_status" "$label preserves structured exit"
  assert_output_contains "verdict: $expected_verdict" "$label preserves verdict"
  assert_output_not_contains 'unbound variable' "$label has no nounset abort"
}

classify_primary_abort() {
  local output_file="$1"
  local site_id=""
  local relative_path=""
  local array_name=""
  local ordinal=""
  local family=""
  local recognized_abort="false"

  if output_contains "$output_file" 'unbound variable'; then
    while IFS='|' read -r site_id array_name ordinal family; do
      if output_contains "$output_file" "${array_name}[@]"; then
        recognized_abort="true"
        break
      fi
    done < <(emit_mapped_sites)
    if [[ "$recognized_abort" == "false" ]]; then
      while IFS='|' read -r site_id relative_path array_name ordinal family; do
        if output_contains "$output_file" "${array_name}[@]"; then
          recognized_abort="true"
          break
        fi
      done < <(emit_module_mapped_sites)
    fi
  fi

  if [[ "$recognized_abort" == "true" ]]; then
    PRIMARY_INTENDED_NOUNSET_ABORTS=$((PRIMARY_INTENDED_NOUNSET_ABORTS + 1))
  elif output_contains "$output_file" 'END TRANSITION_GUARD_RESULT_V1' \
    && output_contains "$output_file" "exitStatus: $RUN_STATUS"; then
    return 0
  elif [[ "$RUN_STATUS" -ne 0 ]]; then
    PRIMARY_UNRELATED_ABORTS=$((PRIMARY_UNRELATED_ABORTS + 1))
  fi
}

run_blocked_contract_case() {
  local framework_root="$1"
  local run_class="$2"
  local case_name="$3"
  local guard="$framework_root/bubbles/scripts/state-transition-guard.sh"

  if [[ "$run_class" == "primary" ]]; then
    PRIMARY_RUNS=$((PRIMARY_RUNS + 1))
  elif [[ "$run_class" == "reference-control" ]]; then
    REFERENCE_CONTROL_RUNS=$((REFERENCE_CONTROL_RUNS + 1))
  else
    harness_die "unknown blocked-contract run class: $run_class"
  fi

  GUARD_RUNS=$((GUARD_RUNS + 1))
  RUN_NAME="$run_class-$case_name"
  RUN_OUTPUT_FILE="$WORKSPACE/run-$GUARD_RUNS-$RUN_NAME.log"
  RUN_STATUS=0
  if (
    cd "$framework_root"
    /usr/bin/env -i \
      HOME="$HOME" \
      PATH="$PATH" \
      BUBBLES_FUN_MODE=false \
      BUBBLES_REPO_ROOT="$framework_root" \
      BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1 \
      "$RUN_SHELL" "$guard"
  ) >"$RUN_OUTPUT_FILE" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  printf 'GUARD_CASE name=%s shell=%s bash=%s exit=%s\n' "$RUN_NAME" "$RUN_SHELL" "$BASH_VERSION" "$RUN_STATUS"
  show_run_signals "$RUN_OUTPUT_FILE"
  if [[ "$run_class" == "primary" ]]; then
    classify_primary_abort "$RUN_OUTPUT_FILE"
  fi
}

run_primary_case() {
  local framework_root="$1"
  local run_class="$2"
  local case_name="$3"
  local packet_kind="$4"
  local variant="$5"

  if [[ "$run_class" == "primary" ]]; then
    PRIMARY_RUNS=$((PRIMARY_RUNS + 1))
  elif [[ "$run_class" == "reference-control" ]]; then
    REFERENCE_CONTROL_RUNS=$((REFERENCE_CONTROL_RUNS + 1))
  else
    harness_die "unknown primary contract run class: $run_class"
  fi

  prepare_case_repo "$run_class-$case_name" "$framework_root" "$packet_kind" "$variant"
  run_guard_case "$run_class-$case_name" "$CASE_REPO" "$CASE_GUARD" "$CASE_FEATURE"
  if [[ "$run_class" == "primary" ]]; then
    classify_primary_abort "$RUN_OUTPUT_FILE"
  fi
}

assert_primary_contracts() {
  local framework_root="$1"
  local run_class="$2"
  local assertion_prefix="$3"

  printf '=== %s SCN-BUG-022-001: zero-element production paths remain observable ===\n' "$assertion_prefix"

  run_primary_case "$framework_root" "$run_class" delivery-pass delivery pass
  assert_complete_result 0 PASS none "$assertion_prefix delivery pass"
  assert_output_contains 'notApplicableChecks: []' "$assertion_prefix delivery pass serializes empty not-applicable checks exactly"
  assert_output_contains 'failedGateIds: []' "$assertion_prefix delivery pass serializes empty failed gates exactly"
  assert_output_contains 'failedChecks: []' "$assertion_prefix delivery pass serializes empty failed checks exactly"

  run_primary_case "$framework_root" "$run_class" planning-pass planning pass
  assert_complete_result 0 PASS none "$assertion_prefix planning pass"
  assert_output_contains 'notApplicableChecks: [Check-4-completion,Check-5-all-done,Check-8-file-existence,Check-11-execution-evidence]' "$assertion_prefix planning pass preserves ordered non-applicable checks"
  assert_output_contains 'failedGateIds: []' "$assertion_prefix planning pass serializes empty failed gates exactly"
  assert_output_contains 'failedChecks: []' "$assertion_prefix planning pass serializes empty failed checks exactly"

  printf '=== %s SCN-BUG-022-002: first gate and check values append once ===\n' "$assertion_prefix"
  run_primary_case "$framework_root" "$run_class" planning-untagged planning untagged
  assert_complete_result 1 FAIL PLANNING_GATE_FAILED "$assertion_prefix untagged planning failure"
  assert_output_contains 'failedGateIds: []' "$assertion_prefix untagged planning failure preserves zero gate IDs"
  assert_output_contains 'failedChecks: [Check-9-evidence,Check-11-execution-honesty]' "$assertion_prefix failed checks preserve first-seen order"
  assert_output_occurrences 1 'failedChecks: [Check-9-evidence,Check-11-execution-honesty]' "$assertion_prefix failed check result appears exactly once"

  run_primary_case "$framework_root" "$run_class" planning-g073 planning g073
  assert_complete_result 1 FAIL SOURCE_EDIT_LOCKOUT "$assertion_prefix G073 planning failure"
  assert_output_contains 'failedGateIds: [G073]' "$assertion_prefix first failed gate appears exactly once"
  assert_output_occurrences 1 'failedGateIds: [G073]' "$assertion_prefix first failed gate result appears exactly once"

  printf '=== %s SCN-BUG-022-003: multiple values preserve order and blocking semantics ===\n' "$assertion_prefix"
  run_primary_case "$framework_root" "$run_class" planning-multiple planning multiple-gates
  assert_complete_result 1 FAIL SOURCE_EDIT_LOCKOUT "$assertion_prefix multiple planning failures"
  assert_output_contains 'failedGateIds: [G073,G041,G068]' "$assertion_prefix multiple failed gates preserve first-seen order"
  assert_output_occurrences 1 'failedGateIds: [G073,G041,G068]' "$assertion_prefix multiple failed gate result appears exactly once"

  run_primary_case "$framework_root" "$run_class" empty-scopes planning empty-scopes
  assert_complete_result 1 FAIL PLANNING_GATE_FAILED "$assertion_prefix empty scope discovery"
  assert_output_contains 'Per-scope layout requires at least one scopes/NN-name/scope.md file' "$assertion_prefix zero scopes reach the existing missing-scope diagnostic"
  assert_output_contains 'failedGateIds: []' "$assertion_prefix zero-scope failure preserves empty gate list"

  run_primary_case "$framework_root" "$run_class" no-reports planning no-reports
  assert_complete_result 1 FAIL PLANNING_GATE_FAILED "$assertion_prefix empty report discovery"
  assert_output_contains 'Missing scope report for scopes/01-no-report/scope.md' "$assertion_prefix zero reports retain the scope-level missing-report diagnostic"
  assert_output_contains 'No report.md files were resolved for this feature' "$assertion_prefix zero reports reach Check 11 structure diagnostic"
  assert_output_contains 'failedChecks: [Check-11-structure]' "$assertion_prefix zero reports retain Check 11 attribution"

  run_primary_case "$framework_root" "$run_class" evidence-one planning evidence-one
  assert_complete_result 0 PASS none "$assertion_prefix first evidence hash"
  assert_output_contains 'No duplicate evidence blocks in scopes.md' "$assertion_prefix first real evidence hash appends after zero comparisons"

  run_primary_case "$framework_root" "$run_class" evidence-distinct planning evidence-distinct
  assert_complete_result 0 PASS none "$assertion_prefix distinct evidence hashes"
  assert_output_contains 'No duplicate evidence blocks in scopes.md' "$assertion_prefix two distinct evidence hashes preserve insertion behavior"

  run_primary_case "$framework_root" "$run_class" evidence-duplicate planning evidence-duplicate
  assert_complete_result 1 FAIL PLANNING_GATE_FAILED "$assertion_prefix duplicate evidence hashes"
  assert_output_contains 'Duplicate evidence blocks detected in scopes.md' "$assertion_prefix only the repeated evidence hash triggers duplicate detection"

  printf '=== %s SCN-BUG-022-001: unresolved contract emits a complete blocked result ===\n' "$assertion_prefix"
  run_blocked_contract_case "$framework_root" "$run_class" contract-blocked
  assert_complete_result 2 BLOCKED E009-USAGE "$assertion_prefix blocked contract"
  assert_output_contains 'applicableCheckClasses: []' "$assertion_prefix blocked contract serializes empty applicable classes exactly"
  assert_output_contains 'failedGateIds: []' "$assertion_prefix blocked contract preserves empty failed gates"
  assert_output_contains 'failedChecks: [contract-resolution]' "$assertion_prefix blocked contract preserves contract attribution"
}

assert_runtime_lane() {
  ACTIVE_PLATFORM="$(uname -s)"
  if "$RUN_SHELL" -c 'set -u; values=(); printf "%s" "${values[@]}"' >/dev/null 2>&1; then
    RAW_EMPTY_ARRAY_ABORTS="false"
  else
    RAW_EMPTY_ARRAY_ABORTS="true"
  fi
  case "$ACTIVE_PLATFORM" in
    Darwin)
      if [[ "$RUN_SHELL" == "/bin/bash" ]]; then
        ACTIVE_BASH_LANE="macos-stock-bash32"
        if [[ "$BASH_VERSION" == 3.2.* ]]; then
          pass 'stock macOS /bin/bash lane is actual Bash 3.2'
          if [[ "$RAW_EMPTY_ARRAY_ABORTS" == "true" ]]; then
            pass 'stock macOS Bash lane reproduces raw empty-array nounset failure'
          else
            contract_fail 'stock macOS Bash lane does not reproduce raw empty-array nounset failure'
          fi
        else
          contract_fail "stock macOS /bin/bash lane must be Bash 3.2 (got $BASH_VERSION)"
        fi
      else
        ACTIVE_BASH_LANE="macos-explicit-newer-bash"
        if [[ "$BASH_VERSION" != 3.2.* ]]; then
          pass 'explicit newer macOS Bash lane does not substitute stock Bash 3.2'
          if [[ "$RAW_EMPTY_ARRAY_ABORTS" == "false" ]]; then
            pass 'explicit newer macOS Bash lane records raw empty-array tolerance'
          else
            contract_fail 'explicit newer macOS Bash lane unexpectedly aborts on raw empty arrays'
          fi
        else
          contract_fail "explicit newer macOS Bash lane unexpectedly resolved Bash 3.2 at $RUN_SHELL"
        fi
      fi
      ;;
    Linux)
      ACTIVE_BASH_LANE="linux-bash"
      pass 'Linux Bash lane is explicit and independently identified'
      printf 'LINUX_RAW_EMPTY_ARRAY_ABORTS=%s\n' "$RAW_EMPTY_ARRAY_ABORTS"
      ;;
    *)
      ACTIVE_BASH_LANE="unsupported-platform"
      contract_fail "unsupported BUG-022 runtime platform: $ACTIVE_PLATFORM"
      ;;
  esac
}

run_cardinality_probe() {
  local probe_output="$WORKSPACE/cardinality-probe.log"
  local probe_status=0
  if "$RUN_SHELL" -c '
    set -euo pipefail
    emit_args() {
      printf "COUNT=%s\n" "$#"
      for value in "$@"; do
        if [[ -z "$value" ]]; then
          printf "%s\n" "VALUE=<EMPTY>"
        else
          printf "VALUE=%s\n" "$value"
        fi
      done
    }
    values=()
    emit_args ${values[@]+"${values[@]}"}
    values=("")
    emit_args ${values[@]+"${values[@]}"}
    values=("alpha beta" gamma "alpha beta")
    emit_args ${values[@]+"${values[@]}"}
    case "$-" in *u*) printf "%s\n" "NOUNSET_ACTIVE=yes" ;; *) exit 9 ;; esac
  ' >"$probe_output" 2>&1; then
    probe_status=0
  else
    probe_status=$?
  fi
  printf '%s\n' '=== BUG-022 guarded-expansion cardinality control ==='
  cat "$probe_output"
  if [[ "$probe_status" -eq 0 ]]; then
    pass 'guarded-expansion primitive exits zero under active nounset'
  else
    contract_fail "guarded-expansion primitive exits zero (got $probe_status)"
  fi
  if [[ "$(output_occurrences "$probe_output" 'COUNT=0')" -eq 1 ]]; then
    pass 'empty array supplies exactly zero arguments'
  else
    contract_fail 'empty array must supply exactly zero arguments'
  fi
  if [[ "$(output_occurrences "$probe_output" 'COUNT=1')" -eq 1 \
    && "$(output_occurrences "$probe_output" 'VALUE=<EMPTY>')" -eq 1 ]]; then
    pass 'one empty-string element remains one exact argument'
  else
    contract_fail 'one empty-string element must remain one exact argument'
  fi
  if [[ "$(output_occurrences "$probe_output" 'COUNT=3')" -eq 1 \
    && "$(output_occurrences "$probe_output" 'VALUE=alpha beta')" -eq 2 \
    && "$(output_occurrences "$probe_output" 'VALUE=gamma')" -eq 1 ]]; then
    pass 'multiple values preserve whitespace, duplicates, and order cardinality'
  else
    contract_fail 'multiple values must preserve whitespace, duplicates, and order cardinality'
  fi
  if output_contains "$probe_output" 'NOUNSET_ACTIVE=yes'; then
    pass 'strict nounset remains active throughout the cardinality control'
  else
    contract_fail 'strict nounset is not active in the cardinality control'
  fi
}

prepare_repaired_reference() {
  local inventory_output="$WORKSPACE/repaired-inventory.log"
  local module_inventory_output="$WORKSPACE/repaired-module-inventory.log"
  mkdir -p "$REPAIRED_REFERENCE_ROOT"
  cp -R "$REPO_ROOT/bubbles" "$REPAIRED_REFERENCE_ROOT/bubbles"
  cp -R "$REPO_ROOT/agents" "$REPAIRED_REFERENCE_ROOT/agents"
  normalize_repaired_reference "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/state-transition-guard.sh"
  normalize_repaired_modules "$REPAIRED_REFERENCE_ROOT/bubbles/scripts"
  if "$RUN_SHELL" -n "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/state-transition-guard.sh"; then
    pass 'temporary repaired-reference guard parses under the active Bash'
  else
    harness_die 'temporary repaired-reference guard does not parse'
  fi
  if "$RUN_SHELL" -n "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/guards/planning-checks.sh" \
    && "$RUN_SHELL" -n "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/guards/control-plane-checks.sh"; then
    pass 'temporary repaired-reference sourced guard modules parse under the active Bash'
  else
    harness_die 'temporary repaired-reference sourced guard module does not parse'
  fi
  if scan_inventory "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/state-transition-guard.sh" "$inventory_output"; then
    pass 'temporary repaired-reference contains all 44 guarded sites and one raw control'
  else
    cat "$inventory_output"
    harness_die 'temporary repaired-reference inventory is not green'
  fi
  if scan_module_inventory "$REPAIRED_REFERENCE_ROOT/bubbles/scripts" "$module_inventory_output"; then
    pass 'temporary repaired-reference contains all three guarded sourced-module sites'
  else
    cat "$module_inventory_output"
    harness_die 'temporary repaired-reference sourced-module inventory is not green'
  fi
}

prepare_family_mutant() {
  local mutant_name="$1"
  local site_id="$2"
  local mutant_root="$WORKSPACE/family-mutants/$mutant_name"
  local source_file="$mutant_root/bubbles/scripts/state-transition-guard.sh"
  local mapped_site=""
  local array_name=""
  local ordinal=""
  local family=""
  local matched=0
  local inventory_output="$WORKSPACE/family-mutant-$mutant_name-inventory.log"
  local inventory_status=0

  mkdir -p "$mutant_root"
  cp -R "$REPAIRED_REFERENCE_ROOT/bubbles" "$mutant_root/bubbles"
  cp -R "$REPAIRED_REFERENCE_ROOT/agents" "$mutant_root/agents"
  while IFS='|' read -r mapped_site array_name ordinal family; do
    if [[ "$mapped_site" == "$site_id" ]]; then
      rewrite_site "$source_file" "$array_name" "$ordinal" guarded raw
      MUTANT_ARRAY="$array_name"
      matched=$((matched + 1))
    fi
  done < <(emit_mapped_sites)
  if [[ "$matched" -ne 1 ]]; then
    harness_die "family mutant $mutant_name matched $matched mapped sites"
  fi

  inventory_status=0
  scan_inventory "$source_file" "$inventory_output" || inventory_status=$?
  if [[ "$inventory_status" -ne 0 \
    && "$INVENTORY_MAPPED_GUARDED" -eq 43 \
    && "$INVENTORY_MAPPED_RAW" -eq 1 \
    && "$INVENTORY_ERRORS" -eq 0 \
    && "$(grep -Fc "site=$site_id" "$inventory_output")" -eq 1 ]]; then
    pass "$mutant_name applies exactly one raw site: $site_id"
  else
    cat "$inventory_output"
    harness_die "$mutant_name did not produce the exact one-site inventory"
  fi
  MUTANT_FRAMEWORK_ROOT="$mutant_root"
}

run_family_mutant() {
  local mutant_name="$1"
  local site_id="$2"
  local packet_kind="$3"
  local variant="$4"
  FAMILY_MUTANT_RUNS=$((FAMILY_MUTANT_RUNS + 1))
  prepare_family_mutant "$mutant_name" "$site_id"
  prepare_case_repo "mutant-$mutant_name" "$MUTANT_FRAMEWORK_ROOT" "$packet_kind" "$variant"
  run_guard_case "mutant-$mutant_name" "$CASE_REPO" "$CASE_GUARD" "$CASE_FEATURE"

  if [[ "$RAW_EMPTY_ARRAY_ABORTS" == "false" \
    && "$(output_occurrences "$RUN_OUTPUT_FILE" 'unbound variable')" -eq 0 \
    && "$(output_occurrences "$RUN_OUTPUT_FILE" 'END TRANSITION_GUARD_RESULT_V1')" -eq 1 ]]; then
    pass "$mutant_name is runtime-tolerated on this Bash lane and rejected by its exact one-site inventory"
  elif [[ "$mutant_name" == "M-RESULT-FORMAT" \
    && "$(output_occurrences "$RUN_OUTPUT_FILE" "${MUTANT_ARRAY}[@]: unbound variable")" -eq 1 \
    && "$(output_occurrences "$RUN_OUTPUT_FILE" 'END TRANSITION_GUARD_RESULT_V1')" -eq 1 \
    && "$(grep -Fxc 'failedGateIds: ' "$RUN_OUTPUT_FILE")" -eq 1 ]]; then
    pass "$mutant_name is rejected by its malformed empty-list result (guard exit=$RUN_STATUS)"
  elif [[ "$mutant_name" != "M-RESULT-FORMAT" \
    && "$(output_occurrences "$RUN_OUTPUT_FILE" "${MUTANT_ARRAY}[@]: unbound variable")" -eq 1 \
    && "$(output_occurrences "$RUN_OUTPUT_FILE" 'END TRANSITION_GUARD_RESULT_V1')" -eq 0 ]]; then
    pass "$mutant_name is rejected by its named production behavior (guard exit=$RUN_STATUS)"
  else
    cat "$RUN_OUTPUT_FILE"
    contract_fail "$mutant_name escaped its named production behavior"
  fi
}

run_family_mutants() {
  printf '%s\n' '=== T-BUG-022-05: independent behavior-family mutants ==='
  run_family_mutant M-ACC-PASS ACC-PASS delivery pass
  run_family_mutant M-ACC-FAILED-GATE ACC-FAILED-GATE planning g073
  run_family_mutant M-ACC-FAILED-CHECK ACC-FAILED-CHECK planning untagged
  run_family_mutant M-RESULT-LOOP RESULT-FAILED-FILTER planning pass
  run_family_mutant M-RESULT-FORMAT RESULT-FAILED-GATE-FORMAT planning untagged
  run_family_mutant M-SCOPE-LOOP SCOPE-BUILD-UNITS planning empty-scopes
  run_family_mutant M-SCOPE-COPY SCOPE-COPY planning empty-scopes
  run_family_mutant M-REPORT-LOOP REPORT-TEMPLATE-SCAN planning no-reports
  run_family_mutant M-REPORT-DUPLICATE-EVIDENCE REPORT-DUPLICATE-EVIDENCE planning no-reports
  run_family_mutant M-FINAL-GATE-LOOKUP FINAL-GATE-LOOKUP planning untagged
}

run_site_inventory_mutants() {
  local site_id=""
  local array_name=""
  local ordinal=""
  local family=""
  local mutant_file=""
  local inventory_output=""
  local inventory_status=0
  local relative_path=""
  local mutant_root=""
  local module_source_file=""

  printf '%s\n' '=== T-BUG-022-21: every mapped one-site inventory mutant ==='
  while IFS='|' read -r site_id array_name ordinal family; do
    SITE_MUTANT_RUNS=$((SITE_MUTANT_RUNS + 1))
    mutant_file="$WORKSPACE/site-mutants/$SITE_MUTANT_RUNS-$site_id.sh"
    inventory_output="$WORKSPACE/site-mutants/$SITE_MUTANT_RUNS-$site_id.log"
    mkdir -p "$(dirname "$mutant_file")"
    cp "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/state-transition-guard.sh" "$mutant_file"
    rewrite_site "$mutant_file" "$array_name" "$ordinal" guarded raw
    inventory_status=0
    scan_inventory "$mutant_file" "$inventory_output" || inventory_status=$?
    if [[ "$inventory_status" -ne 0 \
      && "$INVENTORY_MAPPED_GUARDED" -eq 43 \
      && "$INVENTORY_MAPPED_RAW" -eq 1 \
      && "$INVENTORY_ERRORS" -eq 0 \
      && "$(grep -Fc "site=$site_id" "$inventory_output")" -eq 1 ]]; then
      SITE_MUTANT_REJECTIONS=$((SITE_MUTANT_REJECTIONS + 1))
      pass "inventory rejects one-site mutant $site_id ($array_name ordinal $ordinal)"
    else
      cat "$inventory_output"
      harness_fail "inventory mutant $site_id was not rejected exactly once"
    fi
  done < <(emit_mapped_sites)

  while IFS='|' read -r site_id relative_path array_name ordinal family; do
    SITE_MUTANT_RUNS=$((SITE_MUTANT_RUNS + 1))
    mutant_root="$WORKSPACE/module-site-mutants/$SITE_MUTANT_RUNS-$site_id"
    inventory_output="$WORKSPACE/module-site-mutants/$SITE_MUTANT_RUNS-$site_id.log"
    mkdir -p "$mutant_root/scripts/guards"
    cp "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/guards/planning-checks.sh" "$mutant_root/scripts/guards/planning-checks.sh"
    cp "$REPAIRED_REFERENCE_ROOT/bubbles/scripts/guards/control-plane-checks.sh" "$mutant_root/scripts/guards/control-plane-checks.sh"
    module_source_file="$mutant_root/scripts/$relative_path"
    rewrite_site "$module_source_file" "$array_name" "$ordinal" guarded raw
    inventory_status=0
    scan_module_inventory "$mutant_root/scripts" "$inventory_output" || inventory_status=$?
    if [[ "$inventory_status" -ne 0 \
      && "$MODULE_INVENTORY_MAPPED_GUARDED" -eq 2 \
      && "$MODULE_INVENTORY_MAPPED_RAW" -eq 1 \
      && "$MODULE_INVENTORY_ERRORS" -eq 0 \
      && "$(grep -Fc "site=$site_id" "$inventory_output")" -eq 1 ]]; then
      SITE_MUTANT_REJECTIONS=$((SITE_MUTANT_REJECTIONS + 1))
      pass "inventory rejects one-site sourced-module mutant $site_id ($relative_path $array_name ordinal $ordinal)"
    else
      cat "$inventory_output"
      harness_fail "sourced-module inventory mutant $site_id was not rejected exactly once"
    fi
  done < <(emit_module_mapped_sites)
}

assert_source_strictness() {
  local strict_count
  strict_count="$(grep -c '^set -euo pipefail$' "$SOURCE_GUARD")"
  if [[ "$strict_count" -eq 1 ]]; then
    pass 'production guard retains exactly one strict-mode declaration'
  else
    contract_fail "production guard strict-mode declaration count is $strict_count"
  fi
  if grep -Eq 'set[[:space:]]+\+u' "$SOURCE_GUARD"; then
    contract_fail 'production guard contains forbidden nounset suppression'
  else
    pass 'production guard contains no nounset suppression'
  fi
  if grep -Eq '(^|[[:space:]])eval[[:space:]]' "$SOURCE_GUARD"; then
    contract_fail 'production guard contains forbidden eval indirection'
  else
    pass 'production guard contains no eval indirection'
  fi
  if "$RUN_SHELL" -n "$SOURCE_GUARD"; then
    pass 'production guard parses under the active Bash'
  else
    contract_fail 'production guard fails active-Bash syntax validation'
  fi
}

assert_source_only_provenance() {
  if grep -Fq -- "$TEST_RELATIVE_PATH" "$SOURCE_INSTALLER"; then
    contract_fail "source-only regression is referenced by the installer: $TEST_RELATIVE_PATH"
  else
    pass "source-only regression is absent from the installer: $TEST_RELATIVE_PATH"
  fi
  if jq -e --arg path "$TEST_RELATIVE_PATH" \
    '([.managedFileChecksums[]?.path] | index($path)) == null' \
    "$SOURCE_RELEASE_MANIFEST" >/dev/null; then
    pass "source-only regression is absent from managed release checksums: $TEST_RELATIVE_PATH"
  else
    contract_fail "source-only regression is classified as managed in the release manifest: $TEST_RELATIVE_PATH"
  fi
}

CHECK8_BEFORE_FILE="$WORKSPACE/check8-before.sh"
CHECK8_AFTER_FILE="$WORKSPACE/check8-after.sh"
BUG012_BEFORE_FILE="$WORKSPACE/bug012-before.txt"
BUG012_AFTER_FILE="$WORKSPACE/bug012-after.txt"
extract_check8_region "$SOURCE_GUARD" "$CHECK8_BEFORE_FILE" || harness_die 'cannot extract protected Check 8 region'
extract_bug012_tail_comment_region "$SOURCE_GUARD" "$BUG012_BEFORE_FILE" || harness_die 'cannot extract protected BUG-012 tail comment region'

SOURCE_GUARD_SHA256_BEFORE="$(file_digest "$SOURCE_GUARD")"
PLANNING_CHECKS_SHA256_BEFORE="$(file_digest "$SOURCE_PLANNING_CHECKS")"
CONTROL_PLANE_CHECKS_SHA256_BEFORE="$(file_digest "$SOURCE_CONTROL_PLANE_CHECKS")"
CHECK8_SHA256_BEFORE="$(file_digest "$CHECK8_BEFORE_FILE")"
CHECK8_BYTES_BEFORE="$(file_bytes "$CHECK8_BEFORE_FILE")"
BUG012_TAIL_SHA256_BEFORE="$(file_digest "$BUG012_BEFORE_FILE")"
BUG012_TAIL_BYTES_BEFORE="$(file_bytes "$BUG012_BEFORE_FILE")"
TEST_26_SHA256_BEFORE="$(file_digest "$SOURCE_TEST_26")"
GUARD_SELFTEST_SHA256_BEFORE="$(file_digest "$SOURCE_GUARD_SELFTEST")"
INSTALL_PROVENANCE_SHA256_BEFORE="$(file_digest "$SOURCE_INSTALL_PROVENANCE")"
TEST_27_SHA256_BEFORE="$(file_digest "$SOURCE_TEST_27")"
TEST_28_SHA256_BEFORE="$(file_digest "$SOURCE_TEST_28")"
FUN_MODE_SHA256_BEFORE="$(file_digest "$SOURCE_FUN_MODE")"
FRAMEWORK_VALIDATE_SHA256_BEFORE="$(file_digest "$SOURCE_FRAMEWORK_VALIDATE")"
RELEASE_MANIFEST_SHA256_BEFORE="$(file_digest "$SOURCE_RELEASE_MANIFEST")"
BUGS_INDEX_SHA256_BEFORE="$(file_digest "$SOURCE_BUGS_INDEX")"
INSTALLER_SHA256_BEFORE="$(file_digest "$SOURCE_INSTALLER")"
TEST_FILE_SHA256_BEFORE="$(file_digest "$TEST_FILE")"

printf '%s\n' '=== BUG-022 immutable byte and interpreter controls ==='
printf 'ACTIVE_BASH_PATH=%s\n' "$RUN_SHELL"
printf 'ACTIVE_BASH_VERSION=%s\n' "$BASH_VERSION"
assert_runtime_lane
printf 'ACTIVE_PLATFORM=%s\n' "$ACTIVE_PLATFORM"
printf 'ACTIVE_BASH_LANE=%s\n' "$ACTIVE_BASH_LANE"
printf 'SOURCE_GUARD_SHA256_BEFORE=%s\n' "$SOURCE_GUARD_SHA256_BEFORE"
printf 'PLANNING_CHECKS_SHA256_BEFORE=%s\n' "$PLANNING_CHECKS_SHA256_BEFORE"
printf 'CONTROL_PLANE_CHECKS_SHA256_BEFORE=%s\n' "$CONTROL_PLANE_CHECKS_SHA256_BEFORE"
printf 'CHECK8_SHA256_BEFORE=%s\n' "$CHECK8_SHA256_BEFORE"
printf 'CHECK8_BYTES_BEFORE=%s\n' "$CHECK8_BYTES_BEFORE"
printf 'BUG012_TAIL_SHA256_BEFORE=%s\n' "$BUG012_TAIL_SHA256_BEFORE"
printf 'BUG012_TAIL_BYTES_BEFORE=%s\n' "$BUG012_TAIL_BYTES_BEFORE"
printf 'TEST_26_SHA256_BEFORE=%s\n' "$TEST_26_SHA256_BEFORE"
printf 'GUARD_SELFTEST_SHA256_BEFORE=%s\n' "$GUARD_SELFTEST_SHA256_BEFORE"
printf 'INSTALL_PROVENANCE_SHA256_BEFORE=%s\n' "$INSTALL_PROVENANCE_SHA256_BEFORE"
printf 'TEST_27_SHA256_BEFORE=%s\n' "$TEST_27_SHA256_BEFORE"
printf 'TEST_28_SHA256_BEFORE=%s\n' "$TEST_28_SHA256_BEFORE"
printf 'FUN_MODE_SHA256_BEFORE=%s\n' "$FUN_MODE_SHA256_BEFORE"
printf 'FRAMEWORK_VALIDATE_SHA256_BEFORE=%s\n' "$FRAMEWORK_VALIDATE_SHA256_BEFORE"
printf 'RELEASE_MANIFEST_SHA256_BEFORE=%s\n' "$RELEASE_MANIFEST_SHA256_BEFORE"
printf 'BUGS_INDEX_SHA256_BEFORE=%s\n' "$BUGS_INDEX_SHA256_BEFORE"
printf 'INSTALLER_SHA256_BEFORE=%s\n' "$INSTALLER_SHA256_BEFORE"
printf 'TEST_FILE_SHA256=%s\n' "$TEST_FILE_SHA256_BEFORE"
printf 'GREEN_MUST_USE_TEST_SHA256=%s\n' "$TEST_FILE_SHA256_BEFORE"

assert_source_strictness
assert_source_only_provenance
run_cardinality_probe

CANONICAL_INVENTORY_OUTPUT="$WORKSPACE/canonical-inventory.log"
CANONICAL_INVENTORY_STATUS=0
ASSERTION_CONTEXT="primary"
scan_inventory "$SOURCE_GUARD" "$CANONICAL_INVENTORY_OUTPUT" || CANONICAL_INVENTORY_STATUS=$?
CANONICAL_MAPPED_GUARDED="$INVENTORY_MAPPED_GUARDED"
CANONICAL_MAPPED_RAW="$INVENTORY_MAPPED_RAW"
CANONICAL_INVENTORY_ERRORS="$INVENTORY_ERRORS"
cat "$CANONICAL_INVENTORY_OUTPUT"
if [[ "$CANONICAL_INVENTORY_STATUS" -eq 0 ]]; then
  pass 'canonical source inventory contains all guarded sites and raw controls'
else
  contract_fail "canonical source inventory is not repaired (guarded=$CANONICAL_MAPPED_GUARDED raw=$CANONICAL_MAPPED_RAW errors=$CANONICAL_INVENTORY_ERRORS)"
fi

CANONICAL_MODULE_INVENTORY_OUTPUT="$WORKSPACE/canonical-module-inventory.log"
CANONICAL_MODULE_INVENTORY_STATUS=0
scan_module_inventory "$REPO_ROOT/bubbles/scripts" "$CANONICAL_MODULE_INVENTORY_OUTPUT" || CANONICAL_MODULE_INVENTORY_STATUS=$?
CANONICAL_MODULE_MAPPED_GUARDED="$MODULE_INVENTORY_MAPPED_GUARDED"
CANONICAL_MODULE_MAPPED_RAW="$MODULE_INVENTORY_MAPPED_RAW"
CANONICAL_MODULE_INVENTORY_ERRORS="$MODULE_INVENTORY_ERRORS"
cat "$CANONICAL_MODULE_INVENTORY_OUTPUT"
if [[ "$CANONICAL_MODULE_INVENTORY_STATUS" -eq 0 ]]; then
  pass 'canonical sourced-module inventory contains all guarded sites'
else
  contract_fail "canonical sourced-module inventory is not repaired (guarded=$CANONICAL_MODULE_MAPPED_GUARDED raw=$CANONICAL_MODULE_MAPPED_RAW errors=$CANONICAL_MODULE_INVENTORY_ERRORS)"
fi
ASSERTION_CONTEXT="control"

prepare_repaired_reference
assert_primary_contracts "$REPAIRED_REFERENCE_ROOT" reference-control 'repaired-reference control'
if [[ "$CONTROL_FAILURES" -ne 0 ]]; then
  harness_die "repaired-reference fixture controls failed with $CONTROL_FAILURES contract error(s)"
fi
ASSERTION_CONTEXT="primary"
assert_primary_contracts "$REPO_ROOT" primary 'canonical production'
ASSERTION_CONTEXT="control"
run_family_mutants
run_site_inventory_mutants

extract_check8_region "$SOURCE_GUARD" "$CHECK8_AFTER_FILE" || harness_die 'cannot re-extract protected Check 8 region'
extract_bug012_tail_comment_region "$SOURCE_GUARD" "$BUG012_AFTER_FILE" || harness_die 'cannot re-extract protected BUG-012 tail comment region'
SOURCE_GUARD_SHA256_AFTER="$(file_digest "$SOURCE_GUARD")"
PLANNING_CHECKS_SHA256_AFTER="$(file_digest "$SOURCE_PLANNING_CHECKS")"
CONTROL_PLANE_CHECKS_SHA256_AFTER="$(file_digest "$SOURCE_CONTROL_PLANE_CHECKS")"
CHECK8_SHA256_AFTER="$(file_digest "$CHECK8_AFTER_FILE")"
CHECK8_BYTES_AFTER="$(file_bytes "$CHECK8_AFTER_FILE")"
BUG012_TAIL_SHA256_AFTER="$(file_digest "$BUG012_AFTER_FILE")"
BUG012_TAIL_BYTES_AFTER="$(file_bytes "$BUG012_AFTER_FILE")"
TEST_26_SHA256_AFTER="$(file_digest "$SOURCE_TEST_26")"
GUARD_SELFTEST_SHA256_AFTER="$(file_digest "$SOURCE_GUARD_SELFTEST")"
INSTALL_PROVENANCE_SHA256_AFTER="$(file_digest "$SOURCE_INSTALL_PROVENANCE")"
TEST_27_SHA256_AFTER="$(file_digest "$SOURCE_TEST_27")"
TEST_28_SHA256_AFTER="$(file_digest "$SOURCE_TEST_28")"
FUN_MODE_SHA256_AFTER="$(file_digest "$SOURCE_FUN_MODE")"
FRAMEWORK_VALIDATE_SHA256_AFTER="$(file_digest "$SOURCE_FRAMEWORK_VALIDATE")"
RELEASE_MANIFEST_SHA256_AFTER="$(file_digest "$SOURCE_RELEASE_MANIFEST")"
BUGS_INDEX_SHA256_AFTER="$(file_digest "$SOURCE_BUGS_INDEX")"
INSTALLER_SHA256_AFTER="$(file_digest "$SOURCE_INSTALLER")"
TEST_FILE_SHA256_AFTER="$(file_digest "$TEST_FILE")"

if [[ "$SOURCE_GUARD_SHA256_AFTER" == "$SOURCE_GUARD_SHA256_BEFORE" ]]; then
  pass "canonical guard remained byte-identical at $SOURCE_GUARD_SHA256_AFTER"
else
  harness_fail "canonical guard changed during regression: $SOURCE_GUARD_SHA256_BEFORE -> $SOURCE_GUARD_SHA256_AFTER"
fi
if [[ "$CHECK8_SHA256_AFTER" == "$CHECK8_SHA256_BEFORE" && "$CHECK8_BYTES_AFTER" -eq "$CHECK8_BYTES_BEFORE" ]]; then
  pass "protected Check 8 region remained byte-identical at $CHECK8_SHA256_AFTER ($CHECK8_BYTES_AFTER bytes)"
else
  harness_fail "protected Check 8 region changed: $CHECK8_SHA256_BEFORE/$CHECK8_BYTES_BEFORE -> $CHECK8_SHA256_AFTER/$CHECK8_BYTES_AFTER"
fi
if [[ "$BUG012_TAIL_SHA256_AFTER" == "$BUG012_TAIL_SHA256_BEFORE" && "$BUG012_TAIL_BYTES_AFTER" -eq "$BUG012_TAIL_BYTES_BEFORE" ]]; then
  pass "protected BUG-012 tail comment remained byte-identical at $BUG012_TAIL_SHA256_AFTER ($BUG012_TAIL_BYTES_AFTER bytes)"
else
  harness_fail "protected BUG-012 tail comment changed: $BUG012_TAIL_SHA256_BEFORE/$BUG012_TAIL_BYTES_BEFORE -> $BUG012_TAIL_SHA256_AFTER/$BUG012_TAIL_BYTES_AFTER"
fi
for protected_pair in \
  "planning-checks|$PLANNING_CHECKS_SHA256_BEFORE|$PLANNING_CHECKS_SHA256_AFTER" \
  "control-plane-checks|$CONTROL_PLANE_CHECKS_SHA256_BEFORE|$CONTROL_PLANE_CHECKS_SHA256_AFTER" \
  "test_26|$TEST_26_SHA256_BEFORE|$TEST_26_SHA256_AFTER" \
  "state-transition-guard-selftest|$GUARD_SELFTEST_SHA256_BEFORE|$GUARD_SELFTEST_SHA256_AFTER" \
  "install-provenance-selftest|$INSTALL_PROVENANCE_SHA256_BEFORE|$INSTALL_PROVENANCE_SHA256_AFTER" \
  "test_27|$TEST_27_SHA256_BEFORE|$TEST_27_SHA256_AFTER" \
  "test_28|$TEST_28_SHA256_BEFORE|$TEST_28_SHA256_AFTER" \
  "fun-mode|$FUN_MODE_SHA256_BEFORE|$FUN_MODE_SHA256_AFTER" \
  "framework-validate|$FRAMEWORK_VALIDATE_SHA256_BEFORE|$FRAMEWORK_VALIDATE_SHA256_AFTER" \
  "release-manifest|$RELEASE_MANIFEST_SHA256_BEFORE|$RELEASE_MANIFEST_SHA256_AFTER" \
  "BUGS-index|$BUGS_INDEX_SHA256_BEFORE|$BUGS_INDEX_SHA256_AFTER" \
  "installer|$INSTALLER_SHA256_BEFORE|$INSTALLER_SHA256_AFTER" \
  "test_29|$TEST_FILE_SHA256_BEFORE|$TEST_FILE_SHA256_AFTER"; do
  IFS='|' read -r protected_name protected_before protected_after <<PROTECTED
$protected_pair
PROTECTED
  if [[ "$protected_before" == "$protected_after" ]]; then
    pass "$protected_name remained byte-identical at $protected_after"
  else
    harness_fail "$protected_name changed during regression: $protected_before -> $protected_after"
  fi
done

if [[ "$PRIMARY_RUNS" -eq 11 ]]; then
  pass 'all eleven canonical production fixtures executed without bailout'
else
  harness_fail "expected 11 canonical production fixtures, observed $PRIMARY_RUNS"
fi
if [[ "$REFERENCE_CONTROL_RUNS" -eq 11 ]]; then
  pass 'all eleven repaired-reference harness controls executed without bailout'
else
  harness_fail "expected 11 repaired-reference harness controls, observed $REFERENCE_CONTROL_RUNS"
fi
if [[ "$FAMILY_MUTANT_RUNS" -eq 10 ]]; then
  pass 'all ten named family mutants executed independently'
else
  harness_fail "expected 10 named family mutants, observed $FAMILY_MUTANT_RUNS"
fi
if [[ "$SITE_MUTANT_RUNS" -eq 47 && "$SITE_MUTANT_REJECTIONS" -eq 47 ]]; then
  pass 'all 47 mapped one-site mutants were independently rejected'
else
  harness_fail "site mutant matrix incomplete: runs=$SITE_MUTANT_RUNS rejections=$SITE_MUTANT_REJECTIONS"
fi
if [[ "$GUARD_RUNS" -eq 32 ]]; then
  pass 'all 32 planned production-guard processes executed'
else
  harness_fail "expected 32 production-guard processes, observed $GUARD_RUNS"
fi

RED_DISPOSITION="RED_INVALID_MIXED_OR_UNRELATED_FAILURE"
if [[ "$HARNESS_FAILURES" -eq 0 \
  && "$CONTROL_FAILURES" -eq 0 \
  && "$CANONICAL_INVENTORY_ERRORS" -eq 0 \
  && "$CANONICAL_MAPPED_GUARDED" -eq 0 \
  && "$CANONICAL_MAPPED_RAW" -eq 44 \
  && "$CANONICAL_MODULE_INVENTORY_ERRORS" -eq 0 \
  && "$CANONICAL_MODULE_MAPPED_GUARDED" -eq 0 \
  && "$CANONICAL_MODULE_MAPPED_RAW" -eq 3 \
  && "$PRIMARY_INTENDED_NOUNSET_ABORTS" -eq 11 \
  && "$PRIMARY_UNRELATED_ABORTS" -eq 0 \
  && "$FAMILY_MUTANT_RUNS" -eq 10 \
  && "$SITE_MUTANT_REJECTIONS" -eq 47 \
  && "$PRIMARY_CONTRACT_FAILURES" -gt 0 \
  && "$CONTRACT_FAILURES" -eq "$PRIMARY_CONTRACT_FAILURES" ]]; then
  RED_DISPOSITION="VALID_PRE_FIX_RED"
elif [[ "$HARNESS_FAILURES" -eq 0 \
  && "$CONTROL_FAILURES" -eq 0 \
  && "$CANONICAL_INVENTORY_STATUS" -eq 0 \
  && "$CANONICAL_MAPPED_GUARDED" -eq 44 \
  && "$CANONICAL_MAPPED_RAW" -eq 0 \
  && "$CANONICAL_MODULE_INVENTORY_STATUS" -eq 0 \
  && "$CANONICAL_MODULE_MAPPED_GUARDED" -eq 3 \
  && "$CANONICAL_MODULE_MAPPED_RAW" -eq 0 \
  && "$PRIMARY_UNRELATED_ABORTS" -eq 0 \
  && "$PRIMARY_CONTRACT_FAILURES" -eq 0 \
  && "$CONTRACT_FAILURES" -eq 0 ]]; then
  RED_DISPOSITION="CURRENT_SOURCE_GREEN"
fi

cleanup
trap - EXIT INT TERM
if [[ ! -e "$WORKSPACE" ]]; then
  pass 'unique disposable regression workspace was removed'
else
  harness_fail "temporary regression workspace remains: $WORKSPACE"
fi

printf '%s\n' '=== BUG-022 regression summary ==='
printf 'ACTIVE_PLATFORM=%s\n' "$ACTIVE_PLATFORM"
printf 'ACTIVE_BASH_LANE=%s\n' "$ACTIVE_BASH_LANE"
printf 'ACTIVE_BASH_VERSION=%s\n' "$BASH_VERSION"
printf 'TEST_FILE_SHA256_FINAL=%s\n' "$TEST_FILE_SHA256_AFTER"
printf 'GREEN_MUST_USE_TEST_SHA256_FINAL=%s\n' "$TEST_FILE_SHA256_BEFORE"
printf 'SOURCE_GUARD_SHA256_AFTER=%s\n' "$SOURCE_GUARD_SHA256_AFTER"
printf 'PLANNING_CHECKS_SHA256_AFTER=%s\n' "$PLANNING_CHECKS_SHA256_AFTER"
printf 'CONTROL_PLANE_CHECKS_SHA256_AFTER=%s\n' "$CONTROL_PLANE_CHECKS_SHA256_AFTER"
printf 'CHECK8_SHA256_AFTER=%s\n' "$CHECK8_SHA256_AFTER"
printf 'CHECK8_BYTES_AFTER=%s\n' "$CHECK8_BYTES_AFTER"
printf 'BUG012_TAIL_SHA256_AFTER=%s\n' "$BUG012_TAIL_SHA256_AFTER"
printf 'BUG012_TAIL_BYTES_AFTER=%s\n' "$BUG012_TAIL_BYTES_AFTER"
printf 'CANONICAL_MAPPED_GUARDED=%s\n' "$CANONICAL_MAPPED_GUARDED"
printf 'CANONICAL_MAPPED_RAW=%s\n' "$CANONICAL_MAPPED_RAW"
printf 'CANONICAL_MODULE_MAPPED_GUARDED=%s\n' "$CANONICAL_MODULE_MAPPED_GUARDED"
printf 'CANONICAL_MODULE_MAPPED_RAW=%s\n' "$CANONICAL_MODULE_MAPPED_RAW"
printf 'PRIMARY_RUNS=%s\n' "$PRIMARY_RUNS"
printf 'REFERENCE_CONTROL_RUNS=%s\n' "$REFERENCE_CONTROL_RUNS"
printf 'PRIMARY_INTENDED_NOUNSET_ABORTS=%s\n' "$PRIMARY_INTENDED_NOUNSET_ABORTS"
printf 'PRIMARY_UNRELATED_ABORTS=%s\n' "$PRIMARY_UNRELATED_ABORTS"
printf 'FAMILY_MUTANT_RUNS=%s\n' "$FAMILY_MUTANT_RUNS"
printf 'SITE_MUTANT_RUNS=%s\n' "$SITE_MUTANT_RUNS"
printf 'SITE_MUTANT_REJECTIONS=%s\n' "$SITE_MUTANT_REJECTIONS"
printf 'GUARD_RUNS=%s\n' "$GUARD_RUNS"
printf 'ASSERTIONS=%s\n' "$((PASS_COUNT + CONTRACT_FAILURES + HARNESS_FAILURES))"
printf 'PASSED=%s\n' "$PASS_COUNT"
printf 'CONTRACT_FAILURES=%s\n' "$CONTRACT_FAILURES"
printf 'PRIMARY_CONTRACT_FAILURES=%s\n' "$PRIMARY_CONTRACT_FAILURES"
printf 'CONTROL_FAILURES=%s\n' "$CONTROL_FAILURES"
printf 'HARNESS_FAILURES=%s\n' "$HARNESS_FAILURES"
printf 'BUG022_RED_DISPOSITION=%s\n' "$RED_DISPOSITION"

if [[ "$HARNESS_FAILURES" -ne 0 || "$CONTROL_FAILURES" -ne 0 ]]; then
  printf '%s\n' 'BUG-022 regression HARNESS FAILED.' >&2
  exit 2
fi
if [[ "$PRIMARY_CONTRACT_FAILURES" -ne 0 ]]; then
  printf '%s\n' 'BUG-022 state-transition Bash 3.2 empty-array regression FAILED.' >&2
  exit 1
fi

printf '%s\n' 'BUG-022 state-transition Bash 3.2 empty-array regression passed.'