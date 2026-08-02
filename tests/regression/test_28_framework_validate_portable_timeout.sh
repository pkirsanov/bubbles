#!/usr/bin/env bash
set -uo pipefail

# BUG-021 persistent production-path regression for portable framework
# validation deadlines. Canonical assertions always describe the repaired
# contract. A repaired-reference copy proves the harness and all mutants before
# production changes; all staged mutations stay under the owned workspace and
# the canonical worktree is never mutated by this test.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_VALIDATOR="$REPO_ROOT/bubbles/scripts/framework-validate.sh"
SOURCE_HELPER="$REPO_ROOT/bubbles/scripts/guard-lib.sh"
SOURCE_PORTABILITY_GUARD="$REPO_ROOT/bubbles/scripts/macos-portability-guard.sh"
SOURCE_PROVENANCE="$REPO_ROOT/bubbles/scripts/install-provenance-selftest.sh"
SOURCE_MANIFEST="$REPO_ROOT/bubbles/release-manifest.json"
TEST_FILE="$SCRIPT_DIR/test_28_framework_validate_portable_timeout.sh"
SYSTEM_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# framework-validate.sh refuses bash < 4, and macOS /bin/bash is 3.2, so resolve
# a conforming interpreter instead of hardcoding a path that only works on Linux.
VALIDATOR_BASH="${BASH:-}"
if [[ -z "$VALIDATOR_BASH" ]] || ! "$VALIDATOR_BASH" -c '(( ${BASH_VERSINFO[0]:-0} >= 4 ))' 2>/dev/null; then
  VALIDATOR_BASH="$(command -v bash 2>/dev/null || true)"
fi
if [[ -z "$VALIDATOR_BASH" ]] || ! "$VALIDATOR_BASH" -c '(( ${BASH_VERSINFO[0]:-0} >= 4 ))' 2>/dev/null; then
  echo "test_28: no bash >= 4 available to run the staged validator" >&2
  exit 2
fi

MAC_LABEL='macOS portability guard selftest (bubbles-cross-platform-shell)'
PLAN_LABEL='Workflow planning provenance selftest'
SCRIPT_DIR_ASSIGNMENT='SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"'
HELPER_SOURCE_LINE='source "$SCRIPT_DIR/guard-lib.sh"'
# portable-ok: exact inert mutation literal for raw-timeout regression coverage
RAW_MAC_LINE='run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"'
HELPER_MAC_LINE='run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" bubbles_run_with_timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"'
DIRECT_MAC_LINE='run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"'
# portable-ok: exact inert mutation literal for raw-timeout regression coverage
RAW_PLAN_LINE='run_check "Workflow planning provenance selftest" timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"'
HELPER_PLAN_LINE='run_check "Workflow planning provenance selftest" bubbles_run_with_timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"'
DIRECT_PLAN_LINE='run_check "Workflow planning provenance selftest" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"'
MAC_DEFAULT_LINE='macos_portability_guard_timeout_seconds="${BUBBLES_MACOS_PORTABILITY_GUARD_SELFTEST_TIMEOUT_SECONDS:-120}"'
PLAN_DEFAULT_LINE='planning_provenance_timeout_seconds="${BUBBLES_WORKFLOW_PLANNING_PROVENANCE_SELFTEST_TIMEOUT_SECONDS:-120}"'

for required_file in \
  "$SOURCE_VALIDATOR" \
  "$SOURCE_HELPER" \
  "$SOURCE_PORTABILITY_GUARD" \
  "$SOURCE_PROVENANCE" \
  "$SOURCE_MANIFEST" \
  "$TEST_FILE"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'test_28_framework_validate_portable_timeout: required file missing: %s\n' "$required_file" >&2
    exit 2
  fi
done

for required_command in awk basename bash cat chmod cp dirname env grep ln mkdir mktemp mv rm sed sleep sort; do
  if ! PATH="$SYSTEM_PATH" command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_28_framework_validate_portable_timeout: required command missing from system PATH: %s\n' "$required_command" >&2
    exit 2
  fi
done
if ! PATH="$SYSTEM_PATH" command -v sha256sum >/dev/null 2>&1 \
  && ! PATH="$SYSTEM_PATH" command -v shasum >/dev/null 2>&1; then
  printf '%s\n' 'test_28_framework_validate_portable_timeout: SHA-256 provider missing from system PATH' >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug021-XXXXXXXX")"
NO_PROVIDER_BIN="$WORKSPACE/no-provider-bin"
PROVIDER_BOTH_BIN="$WORKSPACE/provider-both-bin"
PROVIDER_GTIMEOUT_BIN="$WORKSPACE/provider-gtimeout-bin"
CANDIDATE_SOURCE="$WORKSPACE/framework-validate.repaired.sh"
PASS_COUNT=0
CONTRACT_FAILURES=0
HARNESS_FAILURES=0
VALIDATOR_RUNS=0
HELPER_RUNS=0
MUTANT_RUNS=0
RUN_STATUS=0
RUN_OUTPUT_FILE=""
RUN_MARKER_DIR=""
HELPER_STATUS=0
HELPER_OUTPUT_FILE=""
PORTABILITY_STATUS=0
PORTABILITY_OUTPUT_FILE="$WORKSPACE/portability-scan.log"
SOURCE_SHAPE="unexpected"
CANONICAL_EXIT=0
CANONICAL_MAC_STARTED=no
CANONICAL_PLAN_STARTED=no
CANONICAL_SENTINEL=no

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
  printf 'FAIL-CONTRACT: %s\n' "$1" >&2
}

harness_fail() {
  HARNESS_FAILURES=$((HARNESS_FAILURES + 1))
  printf 'FAIL-HARNESS: %s\n' "$1" >&2
}

harness_die() {
  harness_fail "$1"
  printf '%s\n' 'BUG-021 regression cannot continue because fixture construction failed.' >&2
  exit 2
}

file_digest() {
  local digest_output
  if PATH="$SYSTEM_PATH" command -v sha256sum >/dev/null 2>&1; then
    digest_output="$(PATH="$SYSTEM_PATH" sha256sum "$1")"
  else
    digest_output="$(PATH="$SYSTEM_PATH" shasum -a 256 "$1")"
  fi
  set -- $digest_output
  printf '%s\n' "$1"
}

exact_line_count() {
  local file="$1"
  local expected="$2"
  local line
  local count=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$expected" ]]; then
      count=$((count + 1))
    fi
  done <"$file"
  printf '%s\n' "$count"
}

output_contains() {
  grep -Fq -- "$2" "$1"
}

output_occurrences() {
  local file="$1"
  local needle="$2"
  local line
  local count=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      *"$needle"*) count=$((count + 1)) ;;
    esac
  done <"$file"
  printf '%s\n' "$count"
}

exact_output_line_count() {
  exact_line_count "$1" "$2"
}

assert_contract_equal() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    contract_fail "$label (expected=$expected actual=$actual)"
  fi
}

assert_contract_contains() {
  local file="$1"
  local expected="$2"
  local label="$3"
  if output_contains "$file" "$expected"; then
    pass "$label"
  else
    contract_fail "$label (missing: $expected)"
  fi
}

assert_contract_not_contains() {
  local file="$1"
  local forbidden="$2"
  local label="$3"
  if output_contains "$file" "$forbidden"; then
    contract_fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

assert_contract_file_exists() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    pass "$label"
  else
    contract_fail "$label (missing file: $file)"
  fi
}

assert_harness_equal() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    harness_fail "$label (expected=$expected actual=$actual)"
  fi
}

assert_harness_contains() {
  local file="$1"
  local expected="$2"
  local label="$3"
  if output_contains "$file" "$expected"; then
    pass "$label"
  else
    harness_fail "$label (missing: $expected)"
  fi
}

assert_harness_not_contains() {
  local file="$1"
  local forbidden="$2"
  local label="$3"
  if output_contains "$file" "$forbidden"; then
    harness_fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

assert_harness_file_exists() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    pass "$label"
  else
    harness_fail "$label (missing file: $file)"
  fi
}

assert_harness_file_absent() {
  local file="$1"
  local label="$2"
  if [[ ! -e "$file" ]]; then
    pass "$label"
  else
    harness_fail "$label (unexpected file: $file)"
  fi
}

link_system_tool() {
  local tool="$1"
  local resolved
  resolved="$(PATH="$SYSTEM_PATH" command -v "$tool" 2>/dev/null)"
  if [[ -z "$resolved" || ! -x "$resolved" ]]; then
    harness_die "cannot resolve required fixture tool: $tool"
  fi
  ln -s "$resolved" "$NO_PROVIDER_BIN/$tool" || harness_die "cannot link fixture tool: $tool"
}

mkdir -p "$NO_PROVIDER_BIN" "$PROVIDER_BOTH_BIN" "$PROVIDER_GTIMEOUT_BIN"
for fixture_tool in bash basename dirname env mktemp rm sed sleep; do
  link_system_tool "$fixture_tool"
done

if /usr/bin/env -i PATH="$NO_PROVIDER_BIN" /bin/bash -c 'command -v timeout >/dev/null 2>&1 || command -v gtimeout >/dev/null 2>&1'; then
  harness_die 'owned watchdog PATH unexpectedly resolves timeout or gtimeout'
else
  pass 'owned watchdog PATH resolves neither timeout nor gtimeout'
fi

write_provider() {
  local file="$1"
  local provider_name="$2"
  cat >"$file" <<PROVIDER
#!/bin/bash
printf '%s|%s\n' '$provider_name' "\$*" >>"\${BUG021_PROVIDER_LOG:?}"
shift
"\$@"
PROVIDER
  chmod +x "$file"
}

write_provider "$PROVIDER_BOTH_BIN/timeout" timeout
write_provider "$PROVIDER_BOTH_BIN/gtimeout" gtimeout
write_provider "$PROVIDER_GTIMEOUT_BIN/gtimeout" gtimeout

write_pass_script() {
  local file="$1"
  cat >"$file" <<'PASS_SCRIPT'
#!/bin/bash
exit 0
PASS_SCRIPT
  chmod +x "$file"
}

write_target_scripts() {
  local scripts_dir="$1"
  cat >"$scripts_dir/macos-portability-guard-selftest.sh" <<'MAC_TARGET'
#!/bin/bash
set -u
marker_dir="${BUG021_MARKER_DIR:?}"
sleep_seconds="${BUG021_MAC_SLEEP_SECONDS:?}"
exit_status="${BUG021_MAC_EXIT_STATUS:?}"
printf '%s\n' started >"$marker_dir/mac.started"
printf 'BUG021_TARGET mac started sleep=%s exit=%s\n' "$sleep_seconds" "$exit_status"
sleep "$sleep_seconds"
printf '%s\n' finished >"$marker_dir/mac.finished"
printf 'BUG021_TARGET mac finished exit=%s\n' "$exit_status"
exit "$exit_status"
MAC_TARGET
  cat >"$scripts_dir/workflow-planning-provenance-selftest.sh" <<'PLAN_TARGET'
#!/bin/bash
set -u
marker_dir="${BUG021_MARKER_DIR:?}"
sleep_seconds="${BUG021_PLAN_SLEEP_SECONDS:?}"
exit_status="${BUG021_PLAN_EXIT_STATUS:?}"
printf '%s\n' started >"$marker_dir/plan.started"
printf 'BUG021_TARGET plan started sleep=%s exit=%s\n' "$sleep_seconds" "$exit_status"
sleep "$sleep_seconds"
printf '%s\n' finished >"$marker_dir/plan.finished"
printf 'BUG021_TARGET plan finished exit=%s\n' "$exit_status"
exit "$exit_status"
PLAN_TARGET
  cat >"$scripts_dir/state-transition-guard-selftest.sh" <<'SENTINEL_TARGET'
#!/bin/bash
set -u
printf '%s\n' reached >"${BUG021_MARKER_DIR:?}/sentinel.reached"
printf '%s\n' 'BUG021_SENTINEL reached after both deadline registrations'
SENTINEL_TARGET
  chmod +x \
    "$scripts_dir/macos-portability-guard-selftest.sh" \
    "$scripts_dir/workflow-planning-provenance-selftest.sh" \
    "$scripts_dir/state-transition-guard-selftest.sh"
}

normalize_repaired_reference() {
  local validator="$1"
  local temporary="$validator.bug021-normalized"
  local source_count
  local inserted_source=0
  local line

  source_count="$(exact_line_count "$validator" "$HELPER_SOURCE_LINE")"
  if [[ "$source_count" -gt 1 ]]; then
    harness_die "repaired reference found duplicate helper source lines: $source_count"
  fi

  : >"$temporary"
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      "$RAW_MAC_LINE" | "$HELPER_MAC_LINE") printf '%s\n' "$HELPER_MAC_LINE" >>"$temporary" ;;
      "$RAW_PLAN_LINE" | "$HELPER_PLAN_LINE") printf '%s\n' "$HELPER_PLAN_LINE" >>"$temporary" ;;
      *) printf '%s\n' "$line" >>"$temporary" ;;
    esac
    if [[ "$source_count" -eq 0 && "$line" == "$SCRIPT_DIR_ASSIGNMENT" ]]; then
      printf '%s\n' "$HELPER_SOURCE_LINE" >>"$temporary"
      inserted_source=1
    fi
  done <"$validator"
  mv "$temporary" "$validator"

  if [[ "$source_count" -eq 0 && "$inserted_source" -ne 1 ]]; then
    harness_die 'repaired reference could not place the sibling helper source'
  fi
  if [[ "$(exact_line_count "$validator" "$HELPER_SOURCE_LINE")" -ne 1 \
    || "$(exact_line_count "$validator" "$HELPER_MAC_LINE")" -ne 1 \
    || "$(exact_line_count "$validator" "$HELPER_PLAN_LINE")" -ne 1 ]]; then
    harness_die 'repaired reference did not produce the exact helper registration contract'
  fi
}

prepare_stage() {
  local stage_root="$1"
  local validator_source="$2"
  local include_helper="$3"
  local scripts_dir="$stage_root/bubbles/scripts"
  local raw_refs="$stage_root/script-refs.raw"
  local refs="$stage_root/script-refs.txt"
  local ref
  local script_name

  mkdir -p "$scripts_dir"
  cp "$validator_source" "$scripts_dir/framework-validate.sh"
  if [[ "$include_helper" == yes ]]; then
    cp "$SOURCE_HELPER" "$scripts_dir/guard-lib.sh"
  fi
  chmod +x "$scripts_dir/framework-validate.sh"

  if grep -Eo '\$SCRIPT_DIR/[A-Za-z0-9._-]+\.sh' "$scripts_dir/framework-validate.sh" >"$raw_refs"; then
    :
  else
    : >"$raw_refs"
  fi
  LC_ALL=C sort -u "$raw_refs" >"$refs"
  while IFS= read -r ref || [[ -n "$ref" ]]; do
    [[ -n "$ref" ]] || continue
    script_name="${ref##*/}"
    case "$script_name" in
      guard-lib.sh | macos-portability-guard-selftest.sh | workflow-planning-provenance-selftest.sh | state-transition-guard-selftest.sh)
        continue
        ;;
    esac
    if [[ ! -e "$scripts_dir/$script_name" ]]; then
      write_pass_script "$scripts_dir/$script_name"
    fi
  done <"$refs"
  write_target_scripts "$scripts_dir"
}

rewrite_exact_line() {
  local file="$1"
  local old_line="$2"
  local new_line="$3"
  local temporary="$file.bug021-rewrite"
  local line
  local replacements=0
  : >"$temporary"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$old_line" ]]; then
      printf '%s\n' "$new_line" >>"$temporary"
      replacements=$((replacements + 1))
    else
      printf '%s\n' "$line" >>"$temporary"
    fi
  done <"$file"
  mv "$temporary" "$file"
  if [[ "$replacements" -ne 1 ]]; then
    harness_die "expected one exact replacement in $(basename "$file"), observed $replacements"
  fi
}

insert_124_remap_function() {
  local file="$1"
  local temporary="$file.bug021-remap"
  local line
  local insertions=0
  : >"$temporary"
  while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "$line" >>"$temporary"
    if [[ "$line" == "$HELPER_SOURCE_LINE" ]]; then
      cat >>"$temporary" <<'REMAP_FUNCTION'

bug021_swallow_timeout() {
  local helper_status=0
  bubbles_run_with_timeout "$@" || helper_status=$?
  if [[ "$helper_status" -eq 124 ]]; then
    return 0
  fi
  return "$helper_status"
}
REMAP_FUNCTION
      insertions=$((insertions + 1))
    fi
  done <"$file"
  mv "$temporary" "$file"
  if [[ "$insertions" -ne 1 ]]; then
    harness_die "124-remap mutation expected one helper source, observed $insertions"
  fi
}

show_validator_signals() {
  local file="$1"
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      *"$MAC_LABEL"* | *"$PLAN_LABEL"* | *BUG021_TARGET* | *BUG021_SENTINEL* | \
        *'command not found'* | 'Framework validation failed'* | 'Framework validation passed'* | \
        'Failed checks:' | '  - macOS portability guard selftest (bubbles-cross-platform-shell)' | \
        '  - Workflow planning provenance selftest')
        printf '  %s\n' "$line"
        ;;
    esac
  done <"$file"
}

run_validator() {
  local stage_root="$1"
  local case_name="$2"
  local mac_sleep="$3"
  local mac_exit="$4"
  local plan_sleep="$5"
  local plan_exit="$6"
  local mac_deadline="$7"
  local plan_deadline="$8"
  local validator="$stage_root/bubbles/scripts/framework-validate.sh"

  VALIDATOR_RUNS=$((VALIDATOR_RUNS + 1))
  RUN_MARKER_DIR="$WORKSPACE/markers-$VALIDATOR_RUNS-$case_name"
  RUN_OUTPUT_FILE="$WORKSPACE/validator-$VALIDATOR_RUNS-$case_name.log"
  mkdir -p "$RUN_MARKER_DIR"
  RUN_STATUS=0
  if /usr/bin/env -i \
    HOME="${HOME:?HOME is required}" \
    PATH="$NO_PROVIDER_BIN" \
    BUBBLES_FRAMEWORK_VALIDATE_MODE=downstream \
    BUBBLES_MACOS_PORTABILITY_GUARD_SELFTEST_TIMEOUT_SECONDS="$mac_deadline" \
    BUBBLES_WORKFLOW_PLANNING_PROVENANCE_SELFTEST_TIMEOUT_SECONDS="$plan_deadline" \
    BUG021_MARKER_DIR="$RUN_MARKER_DIR" \
    BUG021_MAC_SLEEP_SECONDS="$mac_sleep" \
    BUG021_MAC_EXIT_STATUS="$mac_exit" \
    BUG021_PLAN_SLEEP_SECONDS="$plan_sleep" \
    BUG021_PLAN_EXIT_STATUS="$plan_exit" \
    "$VALIDATOR_BASH" "$validator" >"$RUN_OUTPUT_FILE" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  printf 'VALIDATOR_CASE name=%s exit=%s macDeadline=%s planDeadline=%s\n' \
    "$case_name" "$RUN_STATUS" "$mac_deadline" "$plan_deadline"
  show_validator_signals "$RUN_OUTPUT_FILE"
}

run_helper() {
  local case_name="$1"
  local helper_path="$2"
  local seconds="$3"
  shift 3
  HELPER_RUNS=$((HELPER_RUNS + 1))
  HELPER_OUTPUT_FILE="$WORKSPACE/helper-$HELPER_RUNS-$case_name.log"
  HELPER_STATUS=0
  if (
    unset _BUBBLES_GUARD_LIB_SOURCED
    PATH="$helper_path"
    export PATH
    # shellcheck source=/dev/null
    source "$SOURCE_HELPER"
    bubbles_run_with_timeout "$seconds" "$@"
  ) >"$HELPER_OUTPUT_FILE" 2>&1; then
    HELPER_STATUS=0
  else
    HELPER_STATUS=$?
  fi
  printf 'HELPER_CASE name=%s exit=%s seconds=%s\n' "$case_name" "$HELPER_STATUS" "$seconds"
  cat "$HELPER_OUTPUT_FILE"
}

success_contract_holds() {
  local status="$1"
  local output="$2"
  local markers="$3"
  [[ "$status" -eq 0 ]] \
    && [[ -f "$markers/mac.started" && -f "$markers/mac.finished" ]] \
    && [[ -f "$markers/plan.started" && -f "$markers/plan.finished" ]] \
    && [[ -f "$markers/sentinel.reached" ]] \
    && output_contains "$output" "PASS: $MAC_LABEL" \
    && output_contains "$output" "PASS: $PLAN_LABEL" \
    && output_contains "$output" 'Framework validation passed.' \
    && ! output_contains "$output" 'command not found'
}

timeout_contract_holds() {
  local target="$1"
  local status="$2"
  local output="$3"
  local markers="$4"
  local target_label="$MAC_LABEL"
  local other_label="$PLAN_LABEL"
  local target_marker=mac
  local other_marker=plan
  if [[ "$target" == plan ]]; then
    target_label="$PLAN_LABEL"
    other_label="$MAC_LABEL"
    target_marker=plan
    other_marker=mac
  fi
  [[ "$status" -eq 1 ]] \
    && [[ -f "$markers/$target_marker.started" && ! -e "$markers/$target_marker.finished" ]] \
    && [[ -f "$markers/$other_marker.started" && -f "$markers/$other_marker.finished" ]] \
    && [[ -f "$markers/sentinel.reached" ]] \
    && [[ "$(exact_output_line_count "$output" "FAIL: $target_label")" -eq 1 ]] \
    && [[ "$(exact_output_line_count "$output" "  - $target_label")" -eq 1 ]] \
    && output_contains "$output" "PASS: $other_label" \
    && output_contains "$output" 'Framework validation failed with 1 failing check' \
    && ! output_contains "$output" 'command not found'
}

registration_contract_holds() {
  local validator="$1"
  [[ "$(exact_line_count "$validator" "$HELPER_SOURCE_LINE")" -eq 1 ]] \
    && [[ "$(exact_line_count "$validator" "$HELPER_MAC_LINE")" -eq 1 ]] \
    && [[ "$(exact_line_count "$validator" "$HELPER_PLAN_LINE")" -eq 1 ]] \
    && [[ "$(exact_line_count "$validator" "$RAW_MAC_LINE")" -eq 0 ]] \
    && [[ "$(exact_line_count "$validator" "$RAW_PLAN_LINE")" -eq 0 ]] \
    && [[ "$(exact_line_count "$validator" "$DIRECT_MAC_LINE")" -eq 0 ]] \
    && [[ "$(exact_line_count "$validator" "$DIRECT_PLAN_LINE")" -eq 0 ]] \
    && [[ "$(exact_line_count "$validator" "$MAC_DEFAULT_LINE")" -eq 1 ]] \
    && [[ "$(exact_line_count "$validator" "$PLAN_DEFAULT_LINE")" -eq 1 ]]
}

assert_candidate_success() {
  assert_harness_equal 0 "$RUN_STATUS" 'repaired-reference success preserves validator exit 0'
  assert_harness_file_exists "$RUN_MARKER_DIR/mac.started" 'repaired-reference success executes mac target'
  assert_harness_file_exists "$RUN_MARKER_DIR/mac.finished" 'repaired-reference success completes mac target'
  assert_harness_file_exists "$RUN_MARKER_DIR/plan.started" 'repaired-reference success executes planning target'
  assert_harness_file_exists "$RUN_MARKER_DIR/plan.finished" 'repaired-reference success completes planning target'
  assert_harness_file_exists "$RUN_MARKER_DIR/sentinel.reached" 'repaired-reference success reaches later sentinel'
  assert_harness_contains "$RUN_OUTPUT_FILE" "PASS: $MAC_LABEL" 'repaired-reference success reports mac PASS'
  assert_harness_contains "$RUN_OUTPUT_FILE" "PASS: $PLAN_LABEL" 'repaired-reference success reports planning PASS'
  assert_harness_not_contains "$RUN_OUTPUT_FILE" 'command not found' 'repaired-reference success needs no optional deadline provider'
  assert_harness_contains "$RUN_OUTPUT_FILE" 'Framework validation passed.' 'repaired-reference success preserves aggregate PASS'
}

assert_candidate_timeout() {
  local target="$1"
  local target_label="$MAC_LABEL"
  local other_label="$PLAN_LABEL"
  local target_marker=mac
  local other_marker=plan
  if [[ "$target" == plan ]]; then
    target_label="$PLAN_LABEL"
    other_label="$MAC_LABEL"
    target_marker=plan
    other_marker=mac
  fi
  assert_harness_equal 1 "$RUN_STATUS" "$target deadline preserves aggregate validator exit 1"
  assert_harness_file_exists "$RUN_MARKER_DIR/$target_marker.started" "$target deadline executes bounded target"
  assert_harness_file_absent "$RUN_MARKER_DIR/$target_marker.finished" "$target deadline stops overdue target"
  assert_harness_file_exists "$RUN_MARKER_DIR/$other_marker.started" "$target deadline executes other target"
  assert_harness_file_exists "$RUN_MARKER_DIR/$other_marker.finished" "$target deadline completes other target"
  assert_harness_file_exists "$RUN_MARKER_DIR/sentinel.reached" "$target deadline reaches later sentinel"
  assert_harness_equal 1 "$(exact_output_line_count "$RUN_OUTPUT_FILE" "FAIL: $target_label")" "$target deadline records one failed check result"
  assert_harness_equal 1 "$(exact_output_line_count "$RUN_OUTPUT_FILE" "  - $target_label")" "$target deadline records one failed-label entry"
  assert_harness_contains "$RUN_OUTPUT_FILE" "PASS: $other_label" "$target deadline preserves other target PASS"
  assert_harness_contains "$RUN_OUTPUT_FILE" 'Framework validation failed with 1 failing check' "$target deadline contributes one aggregate failure"
  assert_harness_not_contains "$RUN_OUTPUT_FILE" 'command not found' "$target deadline selects the real watchdog path"
}

assert_candidate_ordinary_failure() {
  assert_harness_equal 1 "$RUN_STATUS" 'ordinary child exit 3 preserves aggregate validator exit 1'
  assert_harness_file_exists "$RUN_MARKER_DIR/mac.finished" 'ordinary failure leaves mac target complete'
  assert_harness_file_exists "$RUN_MARKER_DIR/plan.finished" 'ordinary failure completes planning child before exit 3'
  assert_harness_file_exists "$RUN_MARKER_DIR/sentinel.reached" 'ordinary failure reaches later sentinel'
  assert_harness_contains "$RUN_OUTPUT_FILE" "PASS: $MAC_LABEL" 'ordinary failure preserves mac PASS'
  assert_harness_equal 1 "$(exact_output_line_count "$RUN_OUTPUT_FILE" "FAIL: $PLAN_LABEL")" 'ordinary failure records one planning FAIL'
  assert_harness_equal 1 "$(exact_output_line_count "$RUN_OUTPUT_FILE" "  - $PLAN_LABEL")" 'ordinary failure records one planning failed-label entry'
  assert_harness_contains "$RUN_OUTPUT_FILE" 'Framework validation failed with 1 failing check' 'ordinary failure contributes one aggregate failure'
  assert_harness_not_contains "$RUN_OUTPUT_FILE" 'command not found' 'ordinary failure needs no optional deadline provider'
}

assert_mutant_rejected() {
  local mutant_name="$1"
  local validator="$2"
  local runtime_contract="$3"
  MUTANT_RUNS=$((MUTANT_RUNS + 1))
  if registration_contract_holds "$validator"; then
    harness_fail "$mutant_name escapes the exact registration contract"
  else
    pass "$mutant_name is rejected by the exact registration contract"
  fi
  case "$runtime_contract" in
    success)
      if success_contract_holds "$RUN_STATUS" "$RUN_OUTPUT_FILE" "$RUN_MARKER_DIR"; then
        harness_fail "$mutant_name escapes the staged production success contract"
      else
        pass "$mutant_name is rejected by the staged production success contract"
      fi
      ;;
    mac-timeout)
      if timeout_contract_holds mac "$RUN_STATUS" "$RUN_OUTPUT_FILE" "$RUN_MARKER_DIR"; then
        harness_fail "$mutant_name escapes the staged mac-timeout contract"
      else
        pass "$mutant_name is rejected by the staged mac-timeout contract"
      fi
      ;;
    plan-timeout)
      if timeout_contract_holds plan "$RUN_STATUS" "$RUN_OUTPUT_FILE" "$RUN_MARKER_DIR"; then
        harness_fail "$mutant_name escapes the staged planning-timeout contract"
      else
        pass "$mutant_name is rejected by the staged planning-timeout contract"
      fi
      ;;
    *) harness_die "unknown mutant runtime contract: $runtime_contract" ;;
  esac
}

PRODUCTION_SHA256_BEFORE="$(file_digest "$SOURCE_VALIDATOR")"
HELPER_SHA256_BEFORE="$(file_digest "$SOURCE_HELPER")"
SCANNER_SHA256_BEFORE="$(file_digest "$SOURCE_PORTABILITY_GUARD")"
PROVENANCE_SHA256_BEFORE="$(file_digest "$SOURCE_PROVENANCE")"
MANIFEST_SHA256_BEFORE="$(file_digest "$SOURCE_MANIFEST")"
TEST_SHA256_BEFORE="$(file_digest "$TEST_FILE")"

printf '%s\n' '=== BUG-021 immutable pre-run byte controls ==='
printf 'PRODUCTION_SHA256_BEFORE=%s\n' "$PRODUCTION_SHA256_BEFORE"
printf 'HELPER_SHA256_BEFORE=%s\n' "$HELPER_SHA256_BEFORE"
printf 'SCANNER_SHA256_BEFORE=%s\n' "$SCANNER_SHA256_BEFORE"
printf 'PROVENANCE_SHA256_BEFORE=%s\n' "$PROVENANCE_SHA256_BEFORE"
printf 'MANIFEST_SHA256_BEFORE=%s\n' "$MANIFEST_SHA256_BEFORE"
printf 'TEST_SHA256_BEFORE=%s\n' "$TEST_SHA256_BEFORE"
printf 'GREEN_MUST_USE_TEST_SHA256=%s\n' "$TEST_SHA256_BEFORE"

RAW_MAC_COUNT="$(exact_line_count "$SOURCE_VALIDATOR" "$RAW_MAC_LINE")"
RAW_PLAN_COUNT="$(exact_line_count "$SOURCE_VALIDATOR" "$RAW_PLAN_LINE")"
HELPER_SOURCE_COUNT="$(exact_line_count "$SOURCE_VALIDATOR" "$HELPER_SOURCE_LINE")"
HELPER_MAC_COUNT="$(exact_line_count "$SOURCE_VALIDATOR" "$HELPER_MAC_LINE")"
HELPER_PLAN_COUNT="$(exact_line_count "$SOURCE_VALIDATOR" "$HELPER_PLAN_LINE")"
if [[ "$RAW_MAC_COUNT" -eq 1 && "$RAW_PLAN_COUNT" -eq 1 \
  && "$HELPER_SOURCE_COUNT" -eq 0 && "$HELPER_MAC_COUNT" -eq 0 && "$HELPER_PLAN_COUNT" -eq 0 ]]; then
  SOURCE_SHAPE=pre-fix
  pass 'canonical source has exactly the two planned raw-timeout registrations'
elif [[ "$RAW_MAC_COUNT" -eq 0 && "$RAW_PLAN_COUNT" -eq 0 \
  && "$HELPER_SOURCE_COUNT" -eq 1 && "$HELPER_MAC_COUNT" -eq 1 && "$HELPER_PLAN_COUNT" -eq 1 ]]; then
  SOURCE_SHAPE=repaired
  pass 'canonical source has exactly the repaired helper registration shape'
else
  harness_fail "canonical source has a partial deadline shape (rawMac=$RAW_MAC_COUNT rawPlan=$RAW_PLAN_COUNT source=$HELPER_SOURCE_COUNT helperMac=$HELPER_MAC_COUNT helperPlan=$HELPER_PLAN_COUNT)"
fi

printf '%s\n' '=== RED: unchanged production rejects both raw deadline registrations ==='
if PATH="$SYSTEM_PATH" /bin/bash "$SOURCE_PORTABILITY_GUARD" "$SOURCE_VALIDATOR" >"$PORTABILITY_OUTPUT_FILE" 2>&1; then
  PORTABILITY_STATUS=0
else
  PORTABILITY_STATUS=$?
fi
cat "$PORTABILITY_OUTPUT_FILE"
printf 'RED_OBSERVED_PORTABILITY_EXIT=%s\n' "$PORTABILITY_STATUS"
printf 'RED_OBSERVED_RAW_MAC_CALLS=%s\n' "$RAW_MAC_COUNT"
printf 'RED_OBSERVED_RAW_PLAN_CALLS=%s\n' "$RAW_PLAN_COUNT"
assert_contract_equal 0 "$PORTABILITY_STATUS" 'canonical framework validator passes direct portability scan'
assert_contract_contains "$PORTABILITY_OUTPUT_FILE" 'ok   class-1 raw-timeout: none' 'direct portability scan reports the clean raw-timeout class result'
assert_contract_not_contains "$PORTABILITY_OUTPUT_FILE" 'FAIL macOS-portability violation -- class-1 raw-timeout' 'direct portability scan reports no class-1 raw-timeout violation'
assert_contract_equal 1 "$HELPER_SOURCE_COUNT" 'canonical validator sources the managed sibling helper exactly once'
assert_contract_equal 1 "$HELPER_MAC_COUNT" 'canonical mac registration invokes the portable helper exactly once'
assert_contract_equal 1 "$HELPER_PLAN_COUNT" 'canonical planning registration invokes the portable helper exactly once'
assert_contract_equal 0 "$RAW_MAC_COUNT" 'canonical mac registration has no raw deadline call'
assert_contract_equal 0 "$RAW_PLAN_COUNT" 'canonical planning registration has no raw deadline call'
assert_contract_equal 1 "$(exact_line_count "$SOURCE_VALIDATOR" "$MAC_DEFAULT_LINE")" 'mac deadline retains its environment key and 120-second default'
assert_contract_equal 1 "$(exact_line_count "$SOURCE_VALIDATOR" "$PLAN_DEFAULT_LINE")" 'planning deadline retains its environment key and 120-second default'

CANONICAL_STAGE="$WORKSPACE/stage-canonical-success"
prepare_stage "$CANONICAL_STAGE" "$SOURCE_VALIDATOR" yes
run_validator "$CANONICAL_STAGE" canonical-success 0 0 0 0 4 5
CANONICAL_EXIT="$RUN_STATUS"
[[ -f "$RUN_MARKER_DIR/mac.started" ]] && CANONICAL_MAC_STARTED=yes
[[ -f "$RUN_MARKER_DIR/plan.started" ]] && CANONICAL_PLAN_STARTED=yes
[[ -f "$RUN_MARKER_DIR/sentinel.reached" ]] && CANONICAL_SENTINEL=yes
assert_contract_equal 0 "$RUN_STATUS" 'canonical success case preserves validator exit 0'
assert_contract_file_exists "$RUN_MARKER_DIR/mac.started" 'canonical success case executes mac target'
assert_contract_file_exists "$RUN_MARKER_DIR/mac.finished" 'canonical success case completes mac target'
assert_contract_file_exists "$RUN_MARKER_DIR/plan.started" 'canonical success case executes planning target'
assert_contract_file_exists "$RUN_MARKER_DIR/plan.finished" 'canonical success case completes planning target'
assert_contract_file_exists "$RUN_MARKER_DIR/sentinel.reached" 'canonical success case reaches later sentinel'
assert_contract_contains "$RUN_OUTPUT_FILE" "PASS: $MAC_LABEL" 'canonical success case reports mac PASS'
assert_contract_contains "$RUN_OUTPUT_FILE" "PASS: $PLAN_LABEL" 'canonical success case reports planning PASS'
assert_contract_not_contains "$RUN_OUTPUT_FILE" 'command not found' 'canonical success case needs no optional deadline provider'
assert_contract_contains "$RUN_OUTPUT_FILE" 'Framework validation passed.' 'canonical success case preserves aggregate PASS'

printf '%s\n' '=== BUG-021 repaired-reference non-vacuity controls ==='
cp "$SOURCE_VALIDATOR" "$CANDIDATE_SOURCE"
normalize_repaired_reference "$CANDIDATE_SOURCE"
if registration_contract_holds "$CANDIDATE_SOURCE"; then
  pass 'repaired-reference registration contract is exact'
else
  harness_fail 'repaired-reference registration contract is incomplete'
fi

CANDIDATE_STAGE="$WORKSPACE/stage-candidate-success"
prepare_stage "$CANDIDATE_STAGE" "$CANDIDATE_SOURCE" yes
run_validator "$CANDIDATE_STAGE" candidate-success 0 0 0 0 4 5
assert_candidate_success

printf '%s\n' '=== SCN-BUG-021-001: system-only PATH runs both deadline-bearing checks via watchdog ==='
printf '%s\n' '=== SCN-BUG-021-002: helper outcomes remain distinct through run_check aggregation ==='
MAC_TIMEOUT_STAGE="$WORKSPACE/stage-candidate-mac-timeout"
prepare_stage "$MAC_TIMEOUT_STAGE" "$CANDIDATE_SOURCE" yes
run_validator "$MAC_TIMEOUT_STAGE" candidate-mac-timeout 2 0 0 0 1 4
assert_candidate_timeout mac

PLAN_TIMEOUT_STAGE="$WORKSPACE/stage-candidate-plan-timeout"
prepare_stage "$PLAN_TIMEOUT_STAGE" "$CANDIDATE_SOURCE" yes
run_validator "$PLAN_TIMEOUT_STAGE" candidate-plan-timeout 0 0 2 0 4 1
assert_candidate_timeout plan

ORDINARY_STAGE="$WORKSPACE/stage-candidate-plan-exit3"
prepare_stage "$ORDINARY_STAGE" "$CANDIDATE_SOURCE" yes
run_validator "$ORDINARY_STAGE" candidate-plan-exit3 0 0 0 3 4 5
assert_candidate_ordinary_failure

printf '%s\n' '=== Contract: helper load fails loud and both deadline overrides remain independent ==='
MISSING_HELPER_STAGE="$WORKSPACE/stage-candidate-missing-helper"
prepare_stage "$MISSING_HELPER_STAGE" "$CANDIDATE_SOURCE" no
run_validator "$MISSING_HELPER_STAGE" candidate-missing-helper 0 0 0 0 4 5
if [[ "$RUN_STATUS" -ne 0 ]]; then
  pass 'missing managed helper fails validator startup nonzero'
else
  harness_fail 'missing managed helper must fail validator startup nonzero'
fi
assert_harness_contains "$RUN_OUTPUT_FILE" 'guard-lib.sh' 'missing-helper diagnostic identifies the managed sibling helper'
assert_harness_file_absent "$RUN_MARKER_DIR/mac.started" 'missing helper fails before mac target execution'
assert_harness_file_absent "$RUN_MARKER_DIR/plan.started" 'missing helper fails before planning target execution'
assert_harness_file_absent "$RUN_MARKER_DIR/sentinel.reached" 'missing helper fails before later sentinel execution'

printf '%s\n' '=== Compatibility: timeout then gtimeout then watchdog provider order is unchanged ==='
run_helper helper-success "$NO_PROVIDER_BIN" 4 /bin/bash -c 'exit 0'
assert_harness_equal 0 "$HELPER_STATUS" 'canonical watchdog helper preserves child success 0'
run_helper helper-exit3 "$NO_PROVIDER_BIN" 4 /bin/bash -c 'exit 3'
assert_harness_equal 3 "$HELPER_STATUS" 'canonical watchdog helper preserves ordinary child exit 3'
run_helper helper-watchdog-124 "$NO_PROVIDER_BIN" 1 sleep 2
assert_harness_equal 124 "$HELPER_STATUS" 'canonical watchdog helper normalizes expiration to 124'

PROVIDER_LOG="$WORKSPACE/provider-both.log"
: >"$PROVIDER_LOG"
export BUG021_PROVIDER_LOG="$PROVIDER_LOG"
run_helper helper-timeout-provider "$PROVIDER_BOTH_BIN:$NO_PROVIDER_BIN" 7 /bin/bash -c 'exit 0'
assert_harness_equal 0 "$HELPER_STATUS" 'GNU provider preserves child success'
assert_harness_contains "$PROVIDER_LOG" 'timeout|7s /bin/bash -c exit 0' 'GNU provider receives seconds suffix and child argv'
assert_harness_not_contains "$PROVIDER_LOG" 'gtimeout|' 'GNU timeout binary wins when both providers are available'

PROVIDER_LOG="$WORKSPACE/provider-gtimeout.log"
: >"$PROVIDER_LOG"
export BUG021_PROVIDER_LOG="$PROVIDER_LOG"
run_helper helper-gtimeout-provider "$PROVIDER_GTIMEOUT_BIN:$NO_PROVIDER_BIN" 8 /bin/bash -c 'exit 3'
assert_harness_equal 3 "$HELPER_STATUS" 'gtimeout provider preserves ordinary child exit 3'
assert_harness_contains "$PROVIDER_LOG" 'gtimeout|8s /bin/bash -c exit 3' 'gtimeout provider receives seconds suffix and child argv when timeout is absent'
unset BUG021_PROVIDER_LOG

printf '%s\n' '=== Adversarial: each raw call, direct child, and 124 remap is rejected independently ==='
MUTANT_RAW_MAC="$WORKSPACE/mutant-raw-mac.sh"
cp "$CANDIDATE_SOURCE" "$MUTANT_RAW_MAC"
rewrite_exact_line "$MUTANT_RAW_MAC" "$HELPER_MAC_LINE" "$RAW_MAC_LINE"
MUTANT_STAGE="$WORKSPACE/stage-mutant-raw-mac"
prepare_stage "$MUTANT_STAGE" "$MUTANT_RAW_MAC" yes
run_validator "$MUTANT_STAGE" mutant-raw-mac 0 0 0 0 4 5
assert_mutant_rejected 'raw mac registration mutant' "$MUTANT_RAW_MAC" success

MUTANT_RAW_PLAN="$WORKSPACE/mutant-raw-plan.sh"
cp "$CANDIDATE_SOURCE" "$MUTANT_RAW_PLAN"
rewrite_exact_line "$MUTANT_RAW_PLAN" "$HELPER_PLAN_LINE" "$RAW_PLAN_LINE"
MUTANT_STAGE="$WORKSPACE/stage-mutant-raw-plan"
prepare_stage "$MUTANT_STAGE" "$MUTANT_RAW_PLAN" yes
run_validator "$MUTANT_STAGE" mutant-raw-plan 0 0 0 0 4 5
assert_mutant_rejected 'raw planning registration mutant' "$MUTANT_RAW_PLAN" success

MUTANT_DIRECT_MAC="$WORKSPACE/mutant-direct-mac.sh"
cp "$CANDIDATE_SOURCE" "$MUTANT_DIRECT_MAC"
rewrite_exact_line "$MUTANT_DIRECT_MAC" "$HELPER_MAC_LINE" "$DIRECT_MAC_LINE"
MUTANT_STAGE="$WORKSPACE/stage-mutant-direct-mac"
prepare_stage "$MUTANT_STAGE" "$MUTANT_DIRECT_MAC" yes
run_validator "$MUTANT_STAGE" mutant-direct-mac 2 0 0 0 1 4
assert_mutant_rejected 'direct mac child mutant' "$MUTANT_DIRECT_MAC" mac-timeout

MUTANT_DIRECT_PLAN="$WORKSPACE/mutant-direct-plan.sh"
cp "$CANDIDATE_SOURCE" "$MUTANT_DIRECT_PLAN"
rewrite_exact_line "$MUTANT_DIRECT_PLAN" "$HELPER_PLAN_LINE" "$DIRECT_PLAN_LINE"
MUTANT_STAGE="$WORKSPACE/stage-mutant-direct-plan"
prepare_stage "$MUTANT_STAGE" "$MUTANT_DIRECT_PLAN" yes
run_validator "$MUTANT_STAGE" mutant-direct-plan 0 0 2 0 4 1
assert_mutant_rejected 'direct planning child mutant' "$MUTANT_DIRECT_PLAN" plan-timeout

MUTANT_REMAP="$WORKSPACE/mutant-remap-124.sh"
cp "$CANDIDATE_SOURCE" "$MUTANT_REMAP"
insert_124_remap_function "$MUTANT_REMAP"
rewrite_exact_line \
  "$MUTANT_REMAP" \
  "$HELPER_MAC_LINE" \
  'run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" bug021_swallow_timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"'
MUTANT_STAGE="$WORKSPACE/stage-mutant-remap-124"
prepare_stage "$MUTANT_STAGE" "$MUTANT_REMAP" yes
run_validator "$MUTANT_STAGE" mutant-remap-124 2 0 0 0 1 4
assert_mutant_rejected 'helper 124 remap mutant' "$MUTANT_REMAP" mac-timeout

PRODUCTION_SHA256_AFTER="$(file_digest "$SOURCE_VALIDATOR")"
HELPER_SHA256_AFTER="$(file_digest "$SOURCE_HELPER")"
SCANNER_SHA256_AFTER="$(file_digest "$SOURCE_PORTABILITY_GUARD")"
PROVENANCE_SHA256_AFTER="$(file_digest "$SOURCE_PROVENANCE")"
MANIFEST_SHA256_AFTER="$(file_digest "$SOURCE_MANIFEST")"
TEST_SHA256_AFTER="$(file_digest "$TEST_FILE")"

assert_harness_equal "$PRODUCTION_SHA256_BEFORE" "$PRODUCTION_SHA256_AFTER" 'regression leaves canonical framework validator bytes unchanged'
assert_harness_equal "$HELPER_SHA256_BEFORE" "$HELPER_SHA256_AFTER" 'regression leaves canonical guard-lib bytes unchanged'
assert_harness_equal "$SCANNER_SHA256_BEFORE" "$SCANNER_SHA256_AFTER" 'regression leaves portability scanner bytes unchanged'
assert_harness_equal "$PROVENANCE_SHA256_BEFORE" "$PROVENANCE_SHA256_AFTER" 'regression leaves install-provenance bytes unchanged'
assert_harness_equal "$MANIFEST_SHA256_BEFORE" "$MANIFEST_SHA256_AFTER" 'regression leaves release-manifest bytes unchanged'
assert_harness_equal "$TEST_SHA256_BEFORE" "$TEST_SHA256_AFTER" 'regression test bytes remain stable during execution'
assert_harness_equal 11 "$VALIDATOR_RUNS" 'all eleven staged production-entrypoint cases execute'
assert_harness_equal 5 "$HELPER_RUNS" 'all five direct helper/provider controls execute'
assert_harness_equal 5 "$MUTANT_RUNS" 'all five adversarial mutants execute without bailout'

RED_DISPOSITION=RED_INVALID_MIXED_OR_UNRELATED_FAILURE
if [[ "$HARNESS_FAILURES" -eq 0 \
  && "$SOURCE_SHAPE" == pre-fix \
  && "$PORTABILITY_STATUS" -eq 1 \
  && "$CANONICAL_EXIT" -eq 1 \
  && "$CANONICAL_MAC_STARTED" == no \
  && "$CANONICAL_PLAN_STARTED" == no \
  && "$CANONICAL_SENTINEL" == yes \
  && "$CONTRACT_FAILURES" -gt 0 ]]; then
  RED_DISPOSITION=VALID_PRE_FIX_RED
elif [[ "$HARNESS_FAILURES" -eq 0 \
  && "$SOURCE_SHAPE" == repaired \
  && "$CONTRACT_FAILURES" -eq 0 ]]; then
  RED_DISPOSITION=CURRENT_SOURCE_GREEN
fi

cleanup
trap - EXIT INT TERM
if [[ ! -e "$WORKSPACE" ]]; then
  pass 'unique disposable regression workspace was removed'
else
  harness_fail "temporary regression workspace remains: $WORKSPACE"
fi

printf '%s\n' '=== BUG-021 regression summary ==='
printf 'PRODUCTION_SHA256_AFTER=%s\n' "$PRODUCTION_SHA256_AFTER"
printf 'HELPER_SHA256_AFTER=%s\n' "$HELPER_SHA256_AFTER"
printf 'PROVENANCE_SHA256_AFTER=%s\n' "$PROVENANCE_SHA256_AFTER"
printf 'MANIFEST_SHA256_AFTER=%s\n' "$MANIFEST_SHA256_AFTER"
printf 'TEST_SHA256_AFTER=%s\n' "$TEST_SHA256_AFTER"
printf 'GREEN_MUST_USE_TEST_SHA256_FINAL=%s\n' "$TEST_SHA256_BEFORE"
printf 'SOURCE_SHAPE=%s\n' "$SOURCE_SHAPE"
printf 'PORTABILITY_SCAN_EXIT=%s\n' "$PORTABILITY_STATUS"
printf 'CANONICAL_EXIT=%s\n' "$CANONICAL_EXIT"
printf 'CANONICAL_MAC_STARTED=%s\n' "$CANONICAL_MAC_STARTED"
printf 'CANONICAL_PLAN_STARTED=%s\n' "$CANONICAL_PLAN_STARTED"
printf 'CANONICAL_SENTINEL=%s\n' "$CANONICAL_SENTINEL"
printf 'VALIDATOR_RUNS=%s\n' "$VALIDATOR_RUNS"
printf 'HELPER_RUNS=%s\n' "$HELPER_RUNS"
printf 'MUTANT_RUNS=%s\n' "$MUTANT_RUNS"
printf 'PASSED_ASSERTIONS=%s\n' "$PASS_COUNT"
printf 'CONTRACT_FAILURES=%s\n' "$CONTRACT_FAILURES"
printf 'HARNESS_FAILURES=%s\n' "$HARNESS_FAILURES"
printf 'BUG021_RED_DISPOSITION=%s\n' "$RED_DISPOSITION"

if [[ "$HARNESS_FAILURES" -ne 0 ]]; then
  printf '%s\n' 'BUG-021 regression HARNESS FAILED.' >&2
  exit 2
fi
if [[ "$CONTRACT_FAILURES" -ne 0 ]]; then
  printf '%s\n' 'BUG-021 portable framework deadline regression FAILED.' >&2
  exit 1
fi

printf '%s\n' 'BUG-021 portable framework deadline regression passed.'
