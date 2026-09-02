#!/usr/bin/env bash
set -uo pipefail

# BUG-045 persistent complete-tree regression for the framework-validation tier
# selftest lifecycle. The primary case runs the real source selftest under the
# validator's descriptor-9 lock and a CI-shaped FIFO plus tee capture. The
# control case reinstates the former asynchronous holder lifecycle around that
# same real selftest, so a repaired implementation must stay sensitive to the
# exact orphan-and-pipe deadlock instead of merely matching source text.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_SELFTEST="$REPO_ROOT/bubbles/scripts/framework-validate-tier-selftest.sh"
FRAMEWORK_VALIDATE="$REPO_ROOT/bubbles/scripts/framework-validate.sh"
REPO_DRIFT_REPORT="$REPO_ROOT/bubbles/scripts/repo-drift-report.sh"
GUARD_LIB="$REPO_ROOT/bubbles/scripts/guard-lib.sh"
TEST_FILE="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
CASE_DEADLINE_SECONDS=45

RUN_BASH="${BASH:-}"
# shellcheck disable=SC2016 # The candidate Bash, not this shell, expands BASH_VERSINFO.
if [[ -z "$RUN_BASH" ]] || ! "$RUN_BASH" -c '(( ${BASH_VERSINFO[0]:-0} >= 4 ))' 2>/dev/null; then
  RUN_BASH="$(command -v bash 2>/dev/null || true)"
fi
# shellcheck disable=SC2016 # The candidate Bash, not this shell, expands BASH_VERSINFO.
if [[ -z "$RUN_BASH" ]] || ! "$RUN_BASH" -c '(( ${BASH_VERSINFO[0]:-0} >= 4 ))' 2>/dev/null; then
  printf '%s\n' 'test_36_framework_validate_tier_lock_lifecycle: Bash 4+ is required' >&2
  exit 2
fi

for required_path in "$SOURCE_SELFTEST" "$FRAMEWORK_VALIDATE" "$REPO_DRIFT_REPORT" "$GUARD_LIB" "$TEST_FILE"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_36_framework_validate_tier_lock_lifecycle: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done

# shellcheck source=/dev/null
source "$GUARD_LIB"

missing_optional_observers=()
for optional_observer in flock lsof; do
  command -v "$optional_observer" >/dev/null 2>&1 \
    || missing_optional_observers+=("$optional_observer")
done
if [[ "${1:-}" != --reg-fv-observer-01 \
  && "${1:-}" != --sec-fv-lsof-authority-01 \
  && "${1:-}" != --sec-precommit-lock-01 \
  && "${1:-}" != --sec-precommit-pid-01 \
  && "${#missing_optional_observers[@]}" -gt 0 ]]; then
  printf 'test_36_framework_validate_tier_lock_lifecycle: SKIP (optional lifecycle observer(s) unavailable: %s)\n' \
    "$(
      IFS=,
      printf '%s' "${missing_optional_observers[*]}"
    )"
  exit 0
fi
LSOF="$(command -v lsof)"

for required_command in awk basename bash cat dirname find grep kill ln mkdir mkfifo mktemp ps rm sleep tee wc; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_36_framework_validate_tier_lock_lifecycle: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done

pid_alive() {
  kill -0 "$1" 2>/dev/null
}

process_group_alive() {
  kill -0 -- "-$1" 2>/dev/null || kill -0 "$1" 2>/dev/null
}

signal_process_group() {
  local signal_name="$1"
  local group_pid="$2"
  kill -s "$signal_name" -- "-$group_pid" 2>/dev/null \
    || kill -s "$signal_name" "$group_pid" 2>/dev/null || true
}

trim_number() {
  local value="$1"
  value="${value//[[:space:]]/}"
  printf '%s\n' "$value"
}

process_command() {
  ps -p "$1" -o command= 2>/dev/null || true
}

process_parent() {
  local value
  value="$(ps -p "$1" -o ppid= 2>/dev/null || true)"
  trim_number "$value"
}

# Classify a lock holder whose original parent has exited and whose ownership
# has transferred to any different live parent. PID 1 is one valid destination,
# not the definition: subreapers and test supervisors can adopt the process at
# another PID. Both the real lifecycle probe and the synthetic adversarial
# control below call this one helper so the predicate cannot drift by copy.
parent_transfer_detected() {
  local original_holder_pid="${1:-}"
  local original_holder_alive="${2:-}"
  local observed_parent_pid="${3:-}"

  [[ "$original_holder_pid" =~ ^[1-9][0-9]*$ ]] || return 1
  [[ "$original_holder_alive" == "no" ]] || return 1
  [[ -n "$observed_parent_pid" ]] || return 1
  [[ "$observed_parent_pid" != "$original_holder_pid" ]]
}

process_state() {
  local value
  value="$(ps -p "$1" -o state= 2>/dev/null || true)"
  value="${value//[[:space:]]/}"
  printf '%s\n' "$value"
}

descriptor_facts() {
  local process_pid="$1"
  local descriptor="$2"
  local output=""
  local line=""
  local identity=""
  local descriptor_type=""
  local descriptor_name=""

  output="$("$LSOF" -a -p "$process_pid" -d "$descriptor" -FfDint 2>/dev/null || true)"
  while IFS= read -r line; do
    case "$line" in
      D* | i*) identity="${identity}${line}|" ;;
      t*) descriptor_type="${line#t}" ;;
      n*) descriptor_name="${line#n}" ;;
    esac
  done <<<"$output"
  printf '%s\t%s\t%s\n' "$identity" "$descriptor_type" "$descriptor_name"
}

find_blocked_flock_pids() {
  local lock_file="$1"
  local holders=""
  local candidate_pid=""
  local candidate_command=""

  holders="$("$LSOF" -t "$lock_file" 2>/dev/null || true)"
  while IFS= read -r candidate_pid; do
    [[ -n "$candidate_pid" ]] || continue
    candidate_command="$(process_command "$candidate_pid")"
    case "$candidate_command" in
      *"flock 9"*) printf '%s\n' "$candidate_pid" ;;
    esac
  done <<<"$holders"
}

make_async_lock_source_mutant() {
  local source_selftest="$1"
  local mutant_selftest="$2"
  local source_script_dir

  source_script_dir="$(cd "$(dirname "$source_selftest")" && pwd)" || return 1

  /usr/bin/awk -v source_script_dir="$source_script_dir" '
    {
      if ($0 ~ /^SCRIPT_DIR="\$\(cd "\$\(dirname /) {
        script_dir_count++
        print "SCRIPT_DIR=\"" source_script_dir "\""
        next
      }
      if ($0 == "  ( flock 9; sleep 20 ) 9>\"$lock_file\" &") {
        production_already_async++
      }
      print
      if ($0 == "if command -v flock >/dev/null 2>&1; then") {
        branch_count++
        print "  legacy_lock_file=\"${TMPDIR:-/tmp}/bubbles-framework-validate.lock\""
        print "  : >\"$legacy_lock_file\""
        print "  ( flock 9; sleep 20 ) 9>\"$legacy_lock_file\" &"
        print "  legacy_lock_holder=$!"
        print "  echo \"$legacy_lock_holder\" >\"$BUG045_LEGACY_HOLDER_RECORD\""
        print "  sleep 2"
      }
      if ($0 == "  cleanup_tier_selftest") {
        cleanup_count++
        print "  kill \"$legacy_lock_holder\" 2>/dev/null || true"
        print "  wait \"$legacy_lock_holder\" 2>/dev/null || true"
      }
    }
    END {
      if (production_already_async != 0 || script_dir_count != 1 ||
          branch_count != 1 || cleanup_count != 1) exit 42
    }
  ' "$source_selftest" >"$mutant_selftest"
}

make_term_cleanup_probe() {
  local source_selftest="$1"
  local probe_selftest="$2"
  local cleanup_mode="$3"
  local source_script_dir

  source_script_dir="$(cd "$(dirname "$source_selftest")" && pwd)" || return 1

  /usr/bin/awk -v source_script_dir="$source_script_dir" -v cleanup_mode="$cleanup_mode" '
    {
      if ($0 ~ /^SCRIPT_DIR="\$\(cd "\$\(dirname /) {
        script_dir_count++
        print "SCRIPT_DIR=\"" source_script_dir "\""
        next
      }
      if ($0 == "trap cleanup_tier_selftest EXIT") {
        exit_trap_count++
        if (cleanup_mode == "removed") {
          print "trap - EXIT"
          next
        }
      }
      print
      if ($0 == "  if flock -n 8; then") {
        lock_branch_count++
        print "    echo READY >\"$BUG045_TERM_READY_FILE\""
        print "    sleep 30"
      }
    }
    END {
      if (script_dir_count != 1 || exit_trap_count != 1 ||
          lock_branch_count != 1) exit 42
    }
  ' "$source_selftest" >"$probe_selftest"
}

make_security_lock_source_fixture() {
  local source_script="$1"
  local fixture_script="$2"
  local source_script_dir=""

  source_script_dir="$(cd "$(dirname "$source_script")" && pwd)" || return 1
  /usr/bin/awk -v source_script_dir="$source_script_dir" '
    {
      if ($0 ~ /^SCRIPT_DIR="\$\(cd "\$\(dirname /) {
        script_dir_count++
        print "SCRIPT_DIR=\"" source_script_dir "\""
        next
      }
      if ($0 ~ /\/usr\/bin\/stat/) {
        stat_call_count++
        sub(/\/usr\/bin\/stat/, "\"${BUG045_LOCK_STAT_OBSERVER:-/usr/bin/stat}\"")
      }
      if ($0 ~ /^# macOS portability shim\./) {
        post_lock_anchor_count++
        print "if [[ -n \"${BUG045_LOCK_POST_ACQUIRE_MARKER:-}\" ]]; then"
        print "  : >\"$BUG045_LOCK_POST_ACQUIRE_MARKER\""
        print "  exit 86"
        print "fi"
      }
      print
    }
    END {
      if (script_dir_count != 1 || stat_call_count < 2 ||
          post_lock_anchor_count != 1) exit 42
    }
  ' "$source_script" >"$fixture_script"
}

make_security_pid_source_fixture() {
  local source_script="$1"
  local fixture_script="$2"
  local source_script_dir=""

  source_script_dir="$(cd "$(dirname "$source_script")" && pwd)" || return 1
  /usr/bin/awk -v source_script_dir="$source_script_dir" '
    {
      if ($0 == "_fv_resolve_lsof_path() {") {
        lsof_resolver_count++
        print
        print "  if [[ -n \"${BUG045_PID_OBSERVER:-}\" ]]; then"
        print "    [[ -x \"$BUG045_PID_OBSERVER\" ]] || return 1"
        print "    printf \"%s\\n\" \"$BUG045_PID_OBSERVER\""
        print "    return 0"
        print "  fi"
        next
      }
      if ($0 ~ /^SCRIPT_DIR="\$\(cd "\$\(dirname /) {
        script_dir_count++
        print "SCRIPT_DIR=\"" source_script_dir "\""
        next
      }
      if ($0 ~ /^# Wrapper for selftests that only make sense/) {
        run_check_anchor_count++
        print "if [[ -n \"${BUG045_PID_FIXTURE_COMMAND:-}\" ]]; then"
        print "  set +e"
        print "  run_check \"SEC-PRECOMMIT-PID-01 fixture\" \"$BASH\" \"$BUG045_PID_FIXTURE_COMMAND\""
        print "  _bug045_pid_fixture_status=$?"
        print "  set -e"
        print "  exit \"$_bug045_pid_fixture_status\""
        print "fi"
      }
      print
    }
    END {
      if (script_dir_count != 1 || lsof_resolver_count != 1 ||
          run_check_anchor_count != 1) exit 42
    }
  ' "$source_script" >"$fixture_script"
}

run_case_child() {
  local mode="$1"
  local case_root="$2"
  local source_selftest="$3"
  local lock_file="$case_root/bubbles-framework-validate.lock"
  local capture_fifo="$case_root/ci-capture.pipe"
  local capture_log="$case_root/ci-capture.log"
  local holder_record="$case_root/legacy-holder.pid"
  local reader_pid=""
  local producer_pid=""
  local reader_status="not-waited"
  local producer_status=0
  local blocked_flock_pids=""
  local blocked_flock_pid=""
  local blocked_flock_count=0
  local qualifying_flock_count=0
  local parent_transferred_flock_count=0
  local original_holder_pid=""
  local original_holder_alive_after_selftest="not-recorded"
  local reader_alive="no"
  local producer_alive="no"
  local reader_holds_lock="no"
  local reader_lock_identity=""
  local reader_lock_type=""
  local reader_lock_name=""
  local reader_pipe_identity=""
  local reader_pipe_type=""
  local reader_pipe_name=""
  local fifo_holder_count=0
  local ok_marker_count=0
  local direct_exit_marker_count=0
  local defect_signature="no"
  local clean_contract="no"
  local cleanup_failure=0
  local cleanup_started="no"

  cleanup_case_child() {
    local cleanup_pid=""
    local waited=0

    [[ "$cleanup_started" == "no" ]] || return 0
    cleanup_started="yes"

    blocked_flock_pids="$(find_blocked_flock_pids "$lock_file")"
    while IFS= read -r cleanup_pid; do
      [[ -n "$cleanup_pid" ]] || continue
      kill -TERM "$cleanup_pid" 2>/dev/null || true
    done <<<"$blocked_flock_pids"

    if [[ -n "$producer_pid" ]] && pid_alive "$producer_pid"; then
      kill -TERM "$producer_pid" 2>/dev/null || true
    fi
    waited=0
    while [[ "$waited" -lt 5 ]]; do
      blocked_flock_pids="$(find_blocked_flock_pids "$lock_file")"
      [[ -z "$blocked_flock_pids" ]] && break
      sleep 1
      waited=$((waited + 1))
    done
    blocked_flock_pids="$(find_blocked_flock_pids "$lock_file")"
    while IFS= read -r cleanup_pid; do
      [[ -n "$cleanup_pid" ]] || continue
      kill -KILL "$cleanup_pid" 2>/dev/null || true
    done <<<"$blocked_flock_pids"

    if [[ -n "$reader_pid" ]]; then
      waited=0
      while pid_alive "$reader_pid" && [[ "$waited" -lt 5 ]]; do
        sleep 1
        waited=$((waited + 1))
      done
      if pid_alive "$reader_pid"; then
        kill -KILL "$reader_pid" 2>/dev/null || true
      fi
      wait "$reader_pid" 2>/dev/null || true
    fi
    if [[ -n "$producer_pid" ]]; then
      wait "$producer_pid" 2>/dev/null || true
    fi
    exec 9>&-
    rm -rf "$case_root"
  }

  trap cleanup_case_child EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM

  mkdir -p "$case_root" || exit 2
  mkfifo "$capture_fifo" || exit 2
  : >"$lock_file" || exit 2
  exec 9>"$lock_file"
  flock -n 9 || exit 2

  printf 'CASE_BEGIN mode=%s\n' "$mode"
  printf 'CASE_ROOT=%s\n' "$case_root"
  printf 'SOURCE_SELFTEST=%s\n' "$source_selftest"
  printf 'OUTER_LOCK=%s\n' "$lock_file"
  printf 'CAPTURE_FIFO=%s\n' "$capture_fifo"

  tee "$capture_log" <"$capture_fifo" &
  reader_pid=$!

  (
    TMPDIR="$case_root" \
      GITHUB_ACTIONS=true \
      BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
      BUG045_LEGACY_HOLDER_RECORD="$holder_record" \
      "$RUN_BASH" "$source_selftest"
    direct_status=$?
    printf 'SELFTEST_DIRECT_EXIT=%s\n' "$direct_status"
    exit "$direct_status"
  ) >"$capture_fifo" 2>&1 &
  producer_pid=$!

  wait "$producer_pid"
  producer_status=$?
  for _probe in 1 2 3; do
    pid_alive "$reader_pid" || break
    sleep 1
  done

  pid_alive "$producer_pid" && producer_alive="yes"
  if pid_alive "$reader_pid"; then
    reader_alive="yes"
  else
    wait "$reader_pid" 2>/dev/null
    reader_status=$?
  fi

  ok_marker_count="$(grep -Fc '[framework-validate-tier-selftest] OK' "$capture_log" 2>/dev/null || true)"
  direct_exit_marker_count="$(grep -Fc 'SELFTEST_DIRECT_EXIT=0' "$capture_log" 2>/dev/null || true)"
  if [[ -f "$holder_record" ]]; then
    original_holder_pid="$(trim_number "$(cat "$holder_record" 2>/dev/null || true)")"
    if [[ "$original_holder_pid" =~ ^[1-9][0-9]*$ ]]; then
      if pid_alive "$original_holder_pid"; then
        original_holder_alive_after_selftest="yes"
      else
        original_holder_alive_after_selftest="no"
      fi
    else
      original_holder_alive_after_selftest="invalid-record"
    fi
  fi
  IFS=$'\t' read -r reader_lock_identity reader_lock_type reader_lock_name <<<"$(descriptor_facts "$reader_pid" 9)"
  if [[ "$reader_lock_type" == "REG" && "$reader_lock_name" == "$lock_file" ]]; then
    reader_holds_lock="yes"
  fi
  IFS=$'\t' read -r reader_pipe_identity reader_pipe_type reader_pipe_name <<<"$(descriptor_facts "$reader_pid" 0)"
  if [[ "$reader_pipe_type" == "FIFO" && "$reader_pipe_name" == "$capture_fifo" ]]; then
    fifo_holder_count=$((fifo_holder_count + 1))
  fi

  blocked_flock_pids="$(find_blocked_flock_pids "$lock_file")"
  while IFS= read -r blocked_flock_pid; do
    local flock_parent=""
    local flock_state=""
    local flock_command=""
    local flock_holds_lock="no"
    local flock_lock_identity=""
    local flock_lock_type=""
    local flock_lock_name=""
    local flock_pipe_identity=""
    local flock_pipe_type=""
    local flock_pipe_name=""
    local same_lock="no"
    local same_pipe="no"
    local parent_transferred="no"
    local qualifying="no"

    [[ -n "$blocked_flock_pid" ]] || continue
    blocked_flock_count=$((blocked_flock_count + 1))
    flock_parent="$(process_parent "$blocked_flock_pid")"
    flock_state="$(process_state "$blocked_flock_pid")"
    flock_command="$(process_command "$blocked_flock_pid")"
    IFS=$'\t' read -r flock_lock_identity flock_lock_type flock_lock_name <<<"$(descriptor_facts "$blocked_flock_pid" 9)"
    if [[ "$flock_lock_type" == "REG" && "$flock_lock_name" == "$lock_file" ]]; then
      flock_holds_lock="yes"
    fi
    if [[ -n "$reader_lock_identity" ]] \
      && [[ "$flock_lock_identity" == "$reader_lock_identity" ]] \
      && [[ "$flock_lock_type" == "REG" ]] \
      && [[ "$reader_lock_type" == "REG" ]] \
      && [[ "$flock_lock_name" == "$lock_file" ]] \
      && [[ "$reader_lock_name" == "$lock_file" ]]; then
      same_lock="yes"
    fi
    IFS=$'\t' read -r flock_pipe_identity flock_pipe_type flock_pipe_name <<<"$(descriptor_facts "$blocked_flock_pid" 1)"
    if [[ "$flock_pipe_type" == "FIFO" && "$flock_pipe_name" == "$capture_fifo" ]]; then
      fifo_holder_count=$((fifo_holder_count + 1))
    fi
    if [[ -n "$reader_pipe_identity" ]] \
      && [[ "$flock_pipe_identity" == "$reader_pipe_identity" ]] \
      && [[ "$flock_pipe_type" == "FIFO" ]] \
      && [[ "$reader_pipe_type" == "FIFO" ]] \
      && [[ "$flock_pipe_name" == "$capture_fifo" ]] \
      && [[ "$reader_pipe_name" == "$capture_fifo" ]]; then
      same_pipe="yes"
    fi
    if parent_transfer_detected \
      "$original_holder_pid" \
      "$original_holder_alive_after_selftest" \
      "$flock_parent"; then
      parent_transferred="yes"
      parent_transferred_flock_count=$((parent_transferred_flock_count + 1))
    fi
    if [[ "$parent_transferred" == "yes" ]] \
      && [[ "$flock_holds_lock" == "yes" ]] \
      && [[ "$same_lock" == "yes" ]] \
      && [[ "$same_pipe" == "yes" ]]; then
      qualifying="yes"
      qualifying_flock_count=$((qualifying_flock_count + 1))
    fi
    printf 'BLOCKED_FLOCK pid=%s ppid=%s state=%s holdsLock=%s sameOuterLock=%s sameCapturePipe=%s parentTransferred=%s qualifying=%s command=%q\n' \
      "$blocked_flock_pid" "${flock_parent:-missing}" "${flock_state:-missing}" \
      "$flock_holds_lock" "$same_lock" "$same_pipe" "$parent_transferred" \
      "$qualifying" "${flock_command:-missing}"
    printf 'BLOCKED_FLOCK_LOCK pid=%s identity=%q type=%s name=%q\n' \
      "$blocked_flock_pid" "${flock_lock_identity:-missing}" \
      "${flock_lock_type:-missing}" "${flock_lock_name:-missing}"
    printf 'BLOCKED_FLOCK_PIPE pid=%s identity=%q type=%s name=%q\n' \
      "$blocked_flock_pid" "${flock_pipe_identity:-missing}" \
      "${flock_pipe_type:-missing}" "${flock_pipe_name:-missing}"
  done <<<"$blocked_flock_pids"

  printf 'SELFTEST_WAIT_EXIT=%s\n' "$producer_status"
  printf 'SELFTEST_PROCESS_ALIVE_AFTER_WAIT=%s\n' "$producer_alive"
  printf 'OK_MARKER_COUNT=%s\n' "$ok_marker_count"
  printf 'DIRECT_EXIT_ZERO_MARKER_COUNT=%s\n' "$direct_exit_marker_count"
  printf 'CAPTURE_READER_ALIVE_AFTER_SELFTEST=%s\n' "$reader_alive"
  printf 'CAPTURE_READER_EXIT=%s\n' "$reader_status"
  printf 'CAPTURE_READER_HOLDS_OUTER_LOCK_FD=%s\n' "$reader_holds_lock"
  printf 'CAPTURE_READER_LOCK identity=%q type=%s name=%q\n' \
    "${reader_lock_identity:-missing}" "${reader_lock_type:-missing}" "${reader_lock_name:-missing}"
  printf 'CAPTURE_READER_PIPE identity=%q type=%s name=%q\n' \
    "${reader_pipe_identity:-missing}" "${reader_pipe_type:-missing}" "${reader_pipe_name:-missing}"
  printf 'ORIGINAL_HOLDER_PID=%s\n' "${original_holder_pid:-not-recorded}"
  printf 'ORIGINAL_HOLDER_ALIVE_AFTER_SELFTEST=%s\n' "$original_holder_alive_after_selftest"
  printf 'BLOCKED_FLOCK_COUNT=%s\n' "$blocked_flock_count"
  printf 'PARENT_TRANSFERRED_FLOCK_COUNT=%s\n' "$parent_transferred_flock_count"
  printf 'QUALIFYING_FLOCK_COUNT=%s\n' "$qualifying_flock_count"
  printf 'CAPTURE_FIFO_HOLDER_COUNT=%s\n' "$fifo_holder_count"

  if [[ "$producer_status" -eq 0 ]] \
    && [[ "$producer_alive" == "no" ]] \
    && [[ "$ok_marker_count" -eq 1 ]] \
    && [[ "$direct_exit_marker_count" -eq 1 ]] \
    && [[ "$reader_alive" == "yes" ]] \
    && [[ "$reader_holds_lock" == "yes" ]] \
    && [[ "$original_holder_pid" =~ ^[1-9][0-9]*$ ]] \
    && [[ "$original_holder_alive_after_selftest" == "no" ]] \
    && [[ "$blocked_flock_count" -ge 1 ]] \
    && [[ "$parent_transferred_flock_count" -eq "$blocked_flock_count" ]] \
    && [[ "$qualifying_flock_count" -eq "$blocked_flock_count" ]]; then
    defect_signature="yes"
  fi

  if [[ "$producer_status" -eq 0 ]] \
    && [[ "$producer_alive" == "no" ]] \
    && [[ "$ok_marker_count" -eq 1 ]] \
    && [[ "$direct_exit_marker_count" -eq 1 ]] \
    && [[ "$reader_alive" == "no" ]] \
    && [[ "$reader_status" -eq 0 ]] \
    && [[ "$blocked_flock_count" -eq 0 ]] \
    && [[ "$fifo_holder_count" -eq 0 ]]; then
    clean_contract="yes"
  fi

  printf 'BUG045_DEFECT_SIGNATURE=%s\n' "$defect_signature"
  printf 'BUG045_CLEAN_CONTRACT=%s\n' "$clean_contract"

  cleanup_case_child
  [[ ! -e "$case_root" && ! -L "$case_root" ]] || cleanup_failure=1
  printf 'CASE_FIXTURE_ABSENT_AFTER_CLEANUP=%s\n' "$([[ "$cleanup_failure" -eq 0 ]] && printf yes || printf no)"
  printf 'CASE_END mode=%s\n' "$mode"
  trap - EXIT INT TERM

  [[ "$cleanup_failure" -eq 0 ]] || return 2
  if [[ "$mode" == "primary" ]]; then
    [[ "$clean_contract" == "yes" ]] && return 0
    [[ "$defect_signature" == "yes" ]] && return 1
    return 2
  fi
  [[ "$defect_signature" == "yes" ]] && return 0
  return 2
}

if [[ "${1:-}" == "--case-child" ]]; then
  [[ $# -eq 4 ]] || exit 2
  run_case_child "$2" "$3" "$4"
  exit $?
fi

run_pre_fv_01_control() {
  local control_root=""
  local lock_file=""
  local unrelated_file=""
  local output_file=""
  local marker_file=""
  local marker_absent_status=0
  local marker_absent_contended="no"
  local marker_only_status=0
  local unrelated_descriptor_status=0
  local inherited_status=0
  local marker_only_executed="no"
  local unrelated_descriptor_executed="no"
  local inherited_executed="no"

  control_root="$(mktemp -d "${TMPDIR:-/tmp}/pre-fv-01.XXXXXXXX")" || return 2
  lock_file="$control_root/bubbles-framework-validate.lock"
  unrelated_file="$control_root/unrelated-descriptor"
  output_file="$control_root/output"
  marker_file="$control_root/check-executed"
  : >"$lock_file" || return 2
  : >"$unrelated_file" || return 2
  exec 8>"$lock_file"
  flock -n 8 || return 2

  # framework-validate calls `sed --version` only after its lock decision. A
  # child-local exported sentinel therefore distinguishes refusal-before-checks
  # from bypass-and-execute without copying or modifying production source.
  sed() {
    printf '%s\n' EXECUTED >"$BUG045_PRE_FV_01_MARKER"
    exit 86
  }
  export -f sed

  set +e
  TMPDIR="$control_root" env -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD \
    "$RUN_BASH" "$FRAMEWORK_VALIDATE" --tier=core --changed-only \
    >"$output_file" 2>&1
  marker_absent_status=$?
  if grep -Fq 'another framework-validate run is already in progress' "$output_file"; then
    marker_absent_contended=yes
  fi

  TMPDIR="$control_root" BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_PRE_FV_01_MARKER="$marker_file" \
    "$RUN_BASH" "$FRAMEWORK_VALIDATE" --tier=core --changed-only \
    >>"$output_file" 2>&1
  marker_only_status=$?
  [[ -f "$marker_file" ]] && marker_only_executed=yes
  rm -f "$marker_file"

  TMPDIR="$control_root" BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_PRE_FV_01_MARKER="$marker_file" \
    "$RUN_BASH" -c '
      exec 9>"$1"
      exec "$BASH" "$2" --tier=core --changed-only
    ' _ "$unrelated_file" "$FRAMEWORK_VALIDATE" \
    >>"$output_file" 2>&1
  unrelated_descriptor_status=$?
  [[ -f "$marker_file" ]] && unrelated_descriptor_executed=yes
  rm -f "$marker_file"

  TMPDIR="$control_root" BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_PRE_FV_01_MARKER="$marker_file" \
    "$RUN_BASH" "$FRAMEWORK_VALIDATE" --tier=core --changed-only \
    9>&8 >>"$output_file" 2>&1
  inherited_status=$?
  [[ -f "$marker_file" ]] && inherited_executed=yes
  set -e
  unset -f sed

  cat "$output_file"
  printf 'PRE_FV_01_CONTROL markerAbsentStatus=%s markerAbsentContended=%s markerOnlyStatus=%s markerOnlyExecuted=%s unrelatedDescriptorStatus=%s unrelatedDescriptorExecuted=%s inheritedStatus=%s inheritedExecuted=%s\n' \
    "$marker_absent_status" "$marker_absent_contended" \
    "$marker_only_status" "$marker_only_executed" \
    "$unrelated_descriptor_status" "$unrelated_descriptor_executed" \
    "$inherited_status" "$inherited_executed"

  exec 8>&-
  rm -rf "$control_root"
  if [[ "$marker_absent_status" -eq 1 && "$marker_absent_contended" == yes \
    && "$marker_only_status" -ne 0 && "$marker_only_executed" == no \
    && "$unrelated_descriptor_status" -ne 0 && "$unrelated_descriptor_executed" == no \
    && "$inherited_status" -eq 86 && "$inherited_executed" == yes ]]; then
    printf '%s\n' 'PASS: PRE-FV-01 binds reentrancy to the inherited validator lock descriptor'
    return 0
  fi
  printf '%s\n' 'RED-CONTROL: PRE-FV-01 unauthenticated marker or unrelated descriptor bypassed lock ownership'
  return 1
}

run_pre_fv_02_control() {
  local control_root=""
  local lock_file=""
  local capture_file=""
  local escaped_file=""
  local same_group_file=""
  local same_group_ready_file=""
  local same_group_terminated_file=""
  local escaped_observed_file=""
  local direct_group_file=""
  local unrelated_file=""
  local claim_file=""
  local validator_pid=""
  local escaped_pid=""
  local same_group_pid=""
  local unrelated_pid=""
  local unrelated_launcher_pid=""
  local validator_status=0
  local waited=0
  local escaped_alive="no"
  local escaped_lock="no"
  local escaped_capture="no"
  local escaped_lock_identity=""
  local escaped_lock_type=""
  local escaped_lock_name=""
  local escaped_capture_identity=""
  local escaped_capture_type=""
  local escaped_capture_name=""
  local escaped_observed_same_group="no"
  local same_group_alive="no"
  local same_group_shared="no"
  local direct_group=""
  local same_group=""
  local unrelated_alive_before="no"
  local unrelated_alive_after="no"
  local pass_observed="no"
  local false_pass="no"
  local lock_holders=""
  local lock_holder_pid=""
  local lock_holder_kind=""
  local lock_holder_count=0
  local reacquired="no"
  local cleanup_reacquired="no"
  local cleanup_pid=""
  local cleanup_pending="no"

  control_root="$(mktemp -d "${TMPDIR:-/tmp}/pre-fv-02.XXXXXXXX")" || return 2
  control_root="$(cd "$control_root" && pwd -P)" || return 2
  lock_file="$control_root/bubbles-framework-validate.lock"
  capture_file="$control_root/framework.capture"
  escaped_file="$control_root/escaped.pid"
  same_group_file="$control_root/same-group.record"
  same_group_ready_file="$control_root/same-group.ready"
  same_group_terminated_file="$control_root/same-group.terminated"
  escaped_observed_file="$control_root/escaped-observed-same-group"
  direct_group_file="$control_root/direct-group"
  unrelated_file="$control_root/unrelated.pid"
  claim_file="$control_root/spawn.claim"

  # This process starts before the validator opens descriptor 9. It is the
  # negative control for an over-broad cleanup that kills by name or host-wide
  # process scan rather than by validator ownership.
  /usr/bin/perl -MPOSIX=setsid -e '
    my ($record) = @ARGV;
    my $child = fork();
    die "fork failed" if !defined $child;
    exit 0 if $child;
    setsid() >= 0 or die "setsid failed";
    open my $fh, ">", $record or die "record failed";
    print {$fh} "$$\n";
    close $fh;
    $SIG{TERM} = sub { exit 0 };
    sleep 20;
  ' "$unrelated_file" &
  unrelated_launcher_pid=$!
  wait "$unrelated_launcher_pid" 2>/dev/null || true
  waited=0
  while [[ ! -f "$unrelated_file" && "$waited" -lt 50 ]]; do
    sleep 0.02
    waited=$((waited + 1))
  done
  unrelated_pid="$(tr -cd '0-9' <"$unrelated_file" 2>/dev/null || true)"
  if [[ "$unrelated_pid" =~ ^[1-9][0-9]*$ ]] && pid_alive "$unrelated_pid" \
    && [[ "$(process_state "$unrelated_pid")" != Z* ]]; then
    unrelated_alive_before=yes
  fi

  (
    export TMPDIR="$control_root"
    export GITHUB_ACTIONS=true
    export BUBBLES_FRAMEWORK_VALIDATE_MODE=source
    export PRE_FV_02_CLAIM="$claim_file"
    export PRE_FV_02_ESCAPED_RECORD="$escaped_file"
    export PRE_FV_02_SAME_GROUP_RECORD="$same_group_file"
    export PRE_FV_02_SAME_GROUP_READY="$same_group_ready_file"
    export PRE_FV_02_SAME_GROUP_TERMINATED="$same_group_terminated_file"
    export PRE_FV_02_ESCAPED_OBSERVED="$escaped_observed_file"
    export PRE_FV_02_DIRECT_GROUP_RECORD="$direct_group_file"
    export PRE_FV_02_FRAMEWORK_PID=$BASHPID
    export PRE_FV_02_REAL_BASH="$RUN_BASH"
    export PRE_FV_02_TRIGGER_PATH="$REPO_DRIFT_REPORT"
    bash() {
      if [[ "${1:-}" != "$PRE_FV_02_TRIGGER_PATH" ]]; then
        "$PRE_FV_02_REAL_BASH" "$@"
        return $?
      fi
      if mkdir "$PRE_FV_02_CLAIM" 2>/dev/null; then
        local direct_group=""
        local fixture_waited=0
        direct_group="$(/bin/ps -p "$BASHPID" -o pgid= 2>/dev/null || true)"
        direct_group="${direct_group//[[:space:]]/}"
        printf '%s\n' "$direct_group" >"$PRE_FV_02_DIRECT_GROUP_RECORD"
        set +m
        /bin/bash -c '
          trap '\''/usr/bin/touch "$PRE_FV_02_SAME_GROUP_TERMINATED"; exit 0'\'' TERM
          /usr/bin/touch "$PRE_FV_02_SAME_GROUP_READY"
          /bin/sleep 20
        ' &
        same_group_pid=$!
        while [[ ! -f "$PRE_FV_02_SAME_GROUP_READY" && "$fixture_waited" -lt 50 ]]; do
          sleep 0.02
          fixture_waited=$((fixture_waited + 1))
        done
        same_group="$(/bin/ps -p "$same_group_pid" -o pgid= 2>/dev/null || true)"
        same_group="${same_group//[[:space:]]/}"
        printf '%s|%s\n' "$same_group_pid" "$same_group" >"$PRE_FV_02_SAME_GROUP_RECORD"
        /usr/bin/perl -MPOSIX=setsid -e '
          my ($parent, $record, $terminated, $observed) = @ARGV;
          my $child = fork();
          die "fork failed" if !defined $child;
          exit 0 if $child;
          setsid() >= 0 or die "setsid failed";
          open my $fh, ">", $record or die "record failed";
          print {$fh} "$$\n";
          close $fh;
          $SIG{TERM} = sub { exit 0 };
          my $saw_termination = 0;
          for (1 .. 100) {
            if (-e $terminated) { $saw_termination = 1; last; }
            select undef, undef, undef, 0.05;
          }
          if ($saw_termination) {
            open my $ofh, ">", $observed or die "observed record failed";
            print {$ofh} "yes\n";
            close $ofh;
          }
          # framework-validate allows up to three seconds after TERM and three
          # more after KILL before it prints the check verdict. Wait beyond
          # that owned-group window so this escaped holder can expose a false
          # PASS before interrupting the outer validator.
          select undef, undef, undef, 7.00;
          kill "TERM", $parent;
          sleep 20;
        ' "$PRE_FV_02_FRAMEWORK_PID" "$PRE_FV_02_ESCAPED_RECORD" \
          "$PRE_FV_02_SAME_GROUP_TERMINATED" "$PRE_FV_02_ESCAPED_OBSERVED" 9>&9 &
        while [[ ! -f "$PRE_FV_02_ESCAPED_RECORD" && "$fixture_waited" -lt 100 ]]; do
          sleep 0.02
          fixture_waited=$((fixture_waited + 1))
        done
      fi
      printf '%s\n' PRE_FV_02_INJECTED_CHECK_COMPLETED
      return 0
    }
    export -f bash
    exec "$RUN_BASH" "$FRAMEWORK_VALIDATE" --tier=core --changed-only
  ) >"$capture_file" 2>&1 &
  validator_pid=$!
  set +e
  wait "$validator_pid"
  validator_status=$?
  set -e
  cat "$capture_file"
  escaped_pid="$(tr -cd '0-9' <"$escaped_file" 2>/dev/null || true)"
  if [[ "$escaped_pid" =~ ^[1-9][0-9]*$ ]] && pid_alive "$escaped_pid" \
    && [[ "$(process_state "$escaped_pid")" != Z* ]]; then
    escaped_alive=yes
    IFS=$'\t' read -r escaped_lock_identity escaped_lock_type escaped_lock_name \
      <<<"$(descriptor_facts "$escaped_pid" 9)"
    IFS=$'\t' read -r escaped_capture_identity escaped_capture_type escaped_capture_name \
      <<<"$(descriptor_facts "$escaped_pid" 1)"
    [[ "$escaped_lock_type" == REG && "$escaped_lock_name" == "$lock_file" ]] && escaped_lock=yes
    [[ "$escaped_capture_type" == REG && "$escaped_capture_name" == "$control_root"/bubbles-framework-validate-capture.* ]] \
      && escaped_capture=yes
  fi

  if [[ -f "$same_group_file" ]]; then
    IFS='|' read -r same_group_pid same_group <"$same_group_file"
  fi
  [[ -f "$escaped_observed_file" ]] && escaped_observed_same_group=yes
  direct_group="$(tr -cd '0-9' <"$direct_group_file" 2>/dev/null || true)"
  if [[ "$direct_group" =~ ^[1-9][0-9]*$ && "$same_group" == "$direct_group" ]]; then
    same_group_shared=yes
  fi
  if [[ "$same_group_pid" =~ ^[1-9][0-9]*$ ]] && pid_alive "$same_group_pid" \
    && [[ "$(process_state "$same_group_pid")" != Z* ]]; then
    same_group_alive=yes
  fi
  if [[ "$unrelated_pid" =~ ^[1-9][0-9]*$ ]] && pid_alive "$unrelated_pid" \
    && [[ "$(process_state "$unrelated_pid")" != Z* ]]; then
    unrelated_alive_after=yes
  fi
  if grep -Fq PRE_FV_02_INJECTED_CHECK_COMPLETED "$capture_file" \
    && grep -q '^PASS:' "$capture_file"; then
    pass_observed=yes
  fi

  lock_holders="$($LSOF -t "$lock_file" 2>/dev/null || true)"
  while IFS= read -r lock_holder_pid; do
    [[ "$lock_holder_pid" =~ ^[1-9][0-9]*$ ]] || continue
    lock_holder_count=$((lock_holder_count + 1))
    lock_holder_kind=validator-descendant
    [[ "$lock_holder_pid" == "$escaped_pid" ]] && lock_holder_kind=escaped-setsid
    printf 'PRE_FV_02_LOCK_HOLDER pid=%s state=%s kind=%s\n' \
      "$lock_holder_pid" "$(process_state "$lock_holder_pid")" "$lock_holder_kind"
  done <<<"$lock_holders"
  [[ "$pass_observed" == yes && "$lock_holder_count" -gt 0 ]] && false_pass=yes

  exec 8>"$lock_file"
  if flock -n 8; then
    reacquired=yes
  fi
  exec 8>&-
  printf 'PRE_FV_02_CONTROL validatorStatus=%s escapedPid=%s escapedAlive=%s escapedLockFd9=%s escapedCaptureFd1=%s escapedObservedSameGroupTermination=%s lockHolders=%s passObserved=%s falsePass=%s immediateLockReacquired=%s sameGroupPid=%s sameGroupShared=%s sameGroupAlive=%s unrelatedPid=%s unrelatedAliveBefore=%s unrelatedAliveAfter=%s\n' \
    "$validator_status" "${escaped_pid:-missing}" "$escaped_alive" \
    "$escaped_lock" "$escaped_capture" "$escaped_observed_same_group" "$lock_holder_count" \
    "$pass_observed" "$false_pass" "$reacquired" \
    "${same_group_pid:-missing}" "$same_group_shared" "$same_group_alive" \
    "${unrelated_pid:-missing}" "$unrelated_alive_before" "$unrelated_alive_after"
  printf 'PRE_FV_02_ESCAPED_LOCK identity=%q type=%s name=%q\n' \
    "${escaped_lock_identity:-missing}" "${escaped_lock_type:-missing}" "${escaped_lock_name:-missing}"
  printf 'PRE_FV_02_ESCAPED_CAPTURE identity=%q type=%s name=%q\n' \
    "${escaped_capture_identity:-missing}" "${escaped_capture_type:-missing}" "${escaped_capture_name:-missing}"

  for cleanup_pid in "$escaped_pid" "$same_group_pid" "$unrelated_pid"; do
    [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] || continue
    if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
      kill -TERM "$cleanup_pid" 2>/dev/null || true
    fi
  done
  while IFS= read -r cleanup_pid; do
    [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] || continue
    if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
      kill -TERM "$cleanup_pid" 2>/dev/null || true
    fi
  done <<<"$lock_holders"
  waited=0
  while [[ "$waited" -lt 50 ]]; do
    cleanup_pending=no
    for cleanup_pid in "$escaped_pid" "$same_group_pid" "$unrelated_pid"; do
      [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] || continue
      if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
        cleanup_pending=yes
      fi
    done
    while IFS= read -r cleanup_pid; do
      [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] || continue
      if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
        cleanup_pending=yes
      fi
    done <<<"$lock_holders"
    [[ "$cleanup_pending" == no ]] && break
    sleep 0.1
    waited=$((waited + 1))
  done
  for cleanup_pid in "$escaped_pid" "$same_group_pid" "$unrelated_pid"; do
    [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] || continue
    if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
      kill -KILL "$cleanup_pid" 2>/dev/null || true
    fi
  done
  while IFS= read -r cleanup_pid; do
    [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] || continue
    if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
      kill -KILL "$cleanup_pid" 2>/dev/null || true
    fi
  done <<<"$lock_holders"
  exec 8>"$lock_file"
  if flock -n 8; then
    cleanup_reacquired=yes
  fi
  exec 8>&-
  printf 'PRE_FV_02_CLEANUP finalLockReacquired=%s waitedTenths=%s\n' \
    "$cleanup_reacquired" "$waited"

  rm -rf "$control_root"
  if [[ "$validator_status" -ne 0 && "$escaped_pid" =~ ^[1-9][0-9]*$ \
    && "$lock_holder_count" -eq 0 && "$escaped_lock" == no \
    && "$false_pass" == no && "$reacquired" == yes \
    && "$same_group_pid" =~ ^[1-9][0-9]*$ && "$same_group_shared" == yes \
    && "$same_group_alive" == no && "$escaped_observed_same_group" == yes \
    && "$unrelated_pid" =~ ^[1-9][0-9]*$ \
    && "$unrelated_alive_before" == yes && "$unrelated_alive_after" == yes \
    && "$cleanup_reacquired" == yes ]]; then
    printf '%s\n' 'PASS: PRE-FV-02 validation returns with no escaped lock holder, preserves same-group cleanup, and leaves unrelated processes untouched'
    return 0
  fi
  printf '%s\n' 'RED-CONTROL: PRE-FV-02 escaped descendant retained descriptor 9 or produced a false PASS after validation returned'
  return 1
}

run_sec_precommit_lock_01_authority_case() (
  local fixture_script="$1"
  local trusted_flock="$2"
  local shadow_dir="$3"
  local case_root="$4"
  local mode="$5"
  local contention="$6"
  local lock_file="$case_root/bubbles-framework-validate.lock"
  local post_marker="$case_root/post-lock.marker"
  local shadow_record="$case_root/shadow.record"
  local output=""
  local validator_status=0
  local shadow_calls=0
  local post_lock_reached="no"
  local expected_result="no"
  local execution_path="$PATH"

  mkdir -p "$case_root"
  : >"$lock_file"
  : >"$shadow_record"
  if [[ "$contention" == held ]]; then
    exec 8>"$lock_file"
    "$trusted_flock" -n 8 || return 2
  fi
  if [[ "$mode" == path || "$mode" == combined ]]; then
    execution_path="$shadow_dir:$PATH"
  fi

  set +e
  output="$(PATH="$execution_path" TMPDIR="$case_root" \
    BUG045_LOCK_AUTHORITY_MODE="$mode" \
    BUG045_LOCK_SHADOW_RECORD="$shadow_record" \
    BUG045_LOCK_POST_ACQUIRE_MARKER="$post_marker" \
    "$RUN_BASH" -c '
      if [[ "$BUG045_LOCK_AUTHORITY_MODE" == function \
        || "$BUG045_LOCK_AUTHORITY_MODE" == combined ]]; then
        flock() {
          printf "%s\n" imported-function >>"$BUG045_LOCK_SHADOW_RECORD"
          return 0
        }
        export -f flock
      fi
      exec "$1" "$2" --tier=core --changed-only
    ' _ "$RUN_BASH" "$fixture_script" 8>&- 2>&1)"
  validator_status=$?
  set -e
  [[ "$contention" == held ]] && exec 8>&-

  shadow_calls="$(wc -l <"$shadow_record" | tr -d '[:space:]')"
  [[ -f "$post_marker" ]] && post_lock_reached=yes
  if [[ "$contention" == open && "$validator_status" -eq 86 \
    && "$post_lock_reached" == yes && "$shadow_calls" -eq 0 ]]; then
    expected_result=yes
  elif [[ "$contention" == held && "$validator_status" -eq 1 \
    && "$post_lock_reached" == no && "$shadow_calls" -eq 0 ]] \
    && printf '%s\n' "$output" \
      | grep -Fq 'another framework-validate run is already in progress'; then
    expected_result=yes
  fi

  printf 'SEC_PRECOMMIT_LOCK_01_AUTHORITY mode=%s contention=%s validatorExit=%s postLockReached=%s shadowCalls=%s trustedExternal=%s expectedResult=%s\n' \
    "$mode" "$contention" "$validator_status" "$post_lock_reached" \
    "$shadow_calls" "$trusted_flock" "$expected_result"
  if [[ "$expected_result" == yes ]]; then
    return 0
  fi
  printf 'SEC_PRECOMMIT_LOCK_01_AUTHORITY_OUTPUT mode=%s contention=%s output=%s\n' \
    "$mode" "$contention" "$(printf '%s' "$output" | tr '\n' '|')"
  return 1
)

run_sec_precommit_lock_01_control() (
  local control_root=""
  local fixture_script=""
  local stat_observer=""
  local stat_record=""
  local sentinel=""
  local sentinel_before="unrelated-sentinel-content"
  local sentinel_after=""
  local symlink_tmp=""
  local symlink_lock=""
  local symlink_marker=""
  local symlink_output=""
  local symlink_status=0
  local symlink_target_unchanged="no"
  local symlink_check_executed="no"
  local identity_tmp=""
  local identity_lock=""
  local identity_unrelated=""
  local mismatch_marker=""
  local mismatch_output=""
  local mismatch_status=0
  local mismatch_check_executed="no"
  local mismatch_full_identity_observed="no"
  local positive_marker=""
  local positive_output=""
  local positive_status=0
  local positive_check_executed="no"
  local positive_full_identity_observed="no"
  local linux_mismatch_marker=""
  local linux_mismatch_output=""
  local linux_mismatch_status=0
  local linux_mismatch_check_executed="no"
  local linux_mismatch_full_identity_observed="no"
  local linux_positive_marker=""
  local linux_positive_output=""
  local linux_positive_status=0
  local linux_positive_check_executed="no"
  local linux_positive_full_identity_observed="no"
  local trusted_flock=""
  local flock_shadow_dir=""
  local flock_shadow_script=""
  local authority_failed_cases=0
  local authority_mode=""
  local authority_contention=""

  control_root="$(mktemp -d "${TMPDIR:-/tmp}/sec-precommit-lock-01.XXXXXXXX")" || return 2
  control_root="$(cd "$control_root" && pwd -P)" || return 2
  trap 'rm -rf "$control_root"' EXIT
  fixture_script="$control_root/framework-validate.lock-fixture.sh"
  stat_observer="$control_root/stat-observer.sh"
  stat_record="$control_root/stat-observations"
  sentinel="$control_root/unrelated-target"
  symlink_tmp="$control_root/symlink-tmp"
  symlink_lock="$symlink_tmp/bubbles-framework-validate.lock"
  symlink_marker="$control_root/symlink-check-executed"
  identity_tmp="$control_root/identity-tmp"
  identity_lock="$identity_tmp/bubbles-framework-validate.lock"
  identity_unrelated="$identity_tmp/unrelated-descriptor"
  mismatch_marker="$control_root/mismatch-check-executed"
  positive_marker="$control_root/positive-check-executed"
  linux_mismatch_marker="$control_root/linux-mismatch-check-executed"
  linux_positive_marker="$control_root/linux-positive-check-executed"
  flock_shadow_dir="$control_root/flock-shadow-bin"
  flock_shadow_script="$flock_shadow_dir/flock"

  trusted_flock="$(type -P flock || true)"
  if [[ -z "$trusted_flock" || "$trusted_flock" != /* \
    || ! -x "$trusted_flock" ]]; then
    printf '%s\n' 'FAIL-HARNESS: SEC-PRECOMMIT-LOCK-01 trusted external flock unavailable' >&2
    return 2
  fi

  make_security_lock_source_fixture "$FRAMEWORK_VALIDATE" "$fixture_script" || return 2
  chmod 700 "$fixture_script"
  mkdir -p "$flock_shadow_dir"
  cat >"$flock_shadow_script" <<'FLOCK_SHADOW'
#!/usr/bin/env bash
printf '%s\n' path-shadow >>"$BUG045_LOCK_SHADOW_RECORD"
exit 0
FLOCK_SHADOW
  chmod 700 "$flock_shadow_script"
  cat >"$stat_observer" <<'STAT_OBSERVER'
#!/usr/bin/env bash
set -u
option="${1:-}"
format="${2:-}"
observed_path="${3:-}"
path_class=path
[[ "$observed_path" == */fd/9 ]] && path_class=descriptor
printf 'mode=%s option=%s format=%s pathClass=%s\n' \
  "${BUG045_LOCK_STAT_MODE:-missing}" "$option" "$format" "$path_class" \
  >>"$BUG045_LOCK_STAT_RECORD"
case "$option|$format" in
  '-Lc|%d:%i')
    if [[ "${BUG045_LOCK_STAT_MODE:-}" == linux-same ]]; then
      printf '%s\n' '101:424242'
    elif [[ "${BUG045_LOCK_STAT_MODE:-}" == linux-mismatch ]]; then
      if [[ "$path_class" == path ]]; then
        printf '%s\n' '101:424242'
      else
        printf '%s\n' '202:424242'
      fi
    else
      exit 1
    fi
    ;;
  '-f|%i')
    printf '%s\n' 424242
    ;;
  '-f|%d:%i')
    if [[ "${BUG045_LOCK_STAT_MODE:-}" == same || "$path_class" == path ]]; then
      printf '%s\n' '101:424242'
    else
      printf '%s\n' '202:424242'
    fi
    ;;
  *)
    exit 64
    ;;
esac
STAT_OBSERVER
  chmod 700 "$stat_observer"

  mkdir -p "$symlink_tmp" "$identity_tmp"
  printf '%s' "$sentinel_before" >"$sentinel"
  ln -s "$sentinel" "$symlink_lock" || return 2
  set +e
  symlink_output="$(TMPDIR="$symlink_tmp" \
    BUG045_LOCK_POST_ACQUIRE_MARKER="$symlink_marker" \
    "$RUN_BASH" "$fixture_script" --tier=core --changed-only 2>&1)"
  symlink_status=$?
  set -e
  sentinel_after="$(cat "$sentinel" 2>/dev/null || true)"
  [[ "$sentinel_after" == "$sentinel_before" ]] && symlink_target_unchanged=yes
  [[ -f "$symlink_marker" ]] && symlink_check_executed=yes
  printf 'SEC_PRECOMMIT_LOCK_01_SYMLINK captureExit=%s checkExecuted=%s sentinelUnchanged=%s lockPathStillSymlink=%s\n' \
    "$symlink_status" "$symlink_check_executed" "$symlink_target_unchanged" \
    "$([[ -L "$symlink_lock" ]] && printf yes || printf no)"

  : >"$identity_lock"
  : >"$identity_unrelated"
  : >"$stat_record"
  set +e
  mismatch_output="$(TMPDIR="$identity_tmp" \
    BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_LOCK_POST_ACQUIRE_MARKER="$mismatch_marker" \
    BUG045_LOCK_STAT_OBSERVER="$stat_observer" \
    BUG045_LOCK_STAT_RECORD="$stat_record" BUG045_LOCK_STAT_MODE=mismatch \
    "$RUN_BASH" -c '
      exec 9>"$1"
      exec "$2" "$3" --tier=core --changed-only
    ' _ "$identity_unrelated" "$RUN_BASH" "$fixture_script" 2>&1)"
  mismatch_status=$?
  set -e
  [[ -f "$mismatch_marker" ]] && mismatch_check_executed=yes
  if grep -Fq 'mode=mismatch option=-f format=%d:%i' "$stat_record"; then
    mismatch_full_identity_observed=yes
  fi

  : >"$stat_record"
  set +e
  positive_output="$(TMPDIR="$identity_tmp" \
    BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_LOCK_POST_ACQUIRE_MARKER="$positive_marker" \
    BUG045_LOCK_STAT_OBSERVER="$stat_observer" \
    BUG045_LOCK_STAT_RECORD="$stat_record" BUG045_LOCK_STAT_MODE=same \
    "$RUN_BASH" -c '
      exec 9>"$1"
      exec "$2" "$3" --tier=core --changed-only
    ' _ "$identity_lock" "$RUN_BASH" "$fixture_script" 2>&1)"
  positive_status=$?
  set -e
  [[ -f "$positive_marker" ]] && positive_check_executed=yes
  if grep -Fq 'mode=same option=-f format=%d:%i' "$stat_record"; then
    positive_full_identity_observed=yes
  fi
  printf 'SEC_PRECOMMIT_LOCK_01_IDENTITY mismatchExit=%s mismatchCheckExecuted=%s mismatchFullIdentityObserved=%s positiveExit=%s positiveCheckExecuted=%s positiveFullIdentityObserved=%s\n' \
    "$mismatch_status" "$mismatch_check_executed" \
    "$mismatch_full_identity_observed" "$positive_status" \
    "$positive_check_executed" "$positive_full_identity_observed"

  : >"$stat_record"
  set +e
  linux_mismatch_output="$(TMPDIR="$identity_tmp" \
    BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_LOCK_POST_ACQUIRE_MARKER="$linux_mismatch_marker" \
    BUG045_LOCK_STAT_OBSERVER="$stat_observer" \
    BUG045_LOCK_STAT_RECORD="$stat_record" BUG045_LOCK_STAT_MODE=linux-mismatch \
    "$RUN_BASH" -c '
      exec 9>"$1"
      exec "$2" "$3" --tier=core --changed-only
    ' _ "$identity_unrelated" "$RUN_BASH" "$fixture_script" 2>&1)"
  linux_mismatch_status=$?
  set -e
  [[ -f "$linux_mismatch_marker" ]] && linux_mismatch_check_executed=yes
  if grep -Fq 'mode=linux-mismatch option=-Lc format=%d:%i' "$stat_record"; then
    linux_mismatch_full_identity_observed=yes
  fi

  : >"$stat_record"
  set +e
  linux_positive_output="$(TMPDIR="$identity_tmp" \
    BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUG045_LOCK_POST_ACQUIRE_MARKER="$linux_positive_marker" \
    BUG045_LOCK_STAT_OBSERVER="$stat_observer" \
    BUG045_LOCK_STAT_RECORD="$stat_record" BUG045_LOCK_STAT_MODE=linux-same \
    "$RUN_BASH" -c '
      exec 9>"$1"
      exec "$2" "$3" --tier=core --changed-only
    ' _ "$identity_lock" "$RUN_BASH" "$fixture_script" 2>&1)"
  linux_positive_status=$?
  set -e
  [[ -f "$linux_positive_marker" ]] && linux_positive_check_executed=yes
  if grep -Fq 'mode=linux-same option=-Lc format=%d:%i' "$stat_record"; then
    linux_positive_full_identity_observed=yes
  fi
  printf 'SEC_PRECOMMIT_LOCK_01_LINUX mismatchExit=%s mismatchCheckExecuted=%s mismatchFullIdentityObserved=%s positiveExit=%s positiveCheckExecuted=%s positiveFullIdentityObserved=%s\n' \
    "$linux_mismatch_status" "$linux_mismatch_check_executed" \
    "$linux_mismatch_full_identity_observed" "$linux_positive_status" \
    "$linux_positive_check_executed" "$linux_positive_full_identity_observed"

  for authority_mode in function path combined; do
    for authority_contention in open held; do
      if ! run_sec_precommit_lock_01_authority_case \
        "$fixture_script" "$trusted_flock" "$flock_shadow_dir" \
        "$control_root/authority-$authority_mode-$authority_contention" \
        "$authority_mode" "$authority_contention"; then
        authority_failed_cases=$((authority_failed_cases + 1))
      fi
    done
  done

  if [[ "$positive_status" -ne 86 || "$positive_check_executed" != yes ]]; then
    printf 'FAIL-HARNESS: SEC-PRECOMMIT-LOCK-01 genuine inherited descriptor control did not reach the post-lock seam\n' >&2
    printf 'SEC_PRECOMMIT_LOCK_01_POSITIVE_OUTPUT=%s\n' \
      "$(printf '%s' "$positive_output" | tr '\n' '|')"
    return 2
  fi
  if [[ "$linux_positive_status" -ne 86 || "$linux_positive_check_executed" != yes ]]; then
    printf 'FAIL-HARNESS: SEC-PRECOMMIT-LOCK-01 genuine Linux inherited descriptor control did not reach the post-lock seam\n' >&2
    printf 'SEC_PRECOMMIT_LOCK_01_LINUX_POSITIVE_OUTPUT=%s\n' \
      "$(printf '%s' "$linux_positive_output" | tr '\n' '|')"
    return 2
  fi
  if [[ "$symlink_status" -ne 0 && "$symlink_check_executed" == no \
    && "$symlink_target_unchanged" == yes \
    && "$mismatch_status" -ne 0 && "$mismatch_check_executed" == no \
    && "$mismatch_full_identity_observed" == yes \
    && "$positive_full_identity_observed" == yes \
    && "$linux_mismatch_status" -ne 0 && "$linux_mismatch_check_executed" == no \
    && "$linux_mismatch_full_identity_observed" == yes \
    && "$linux_positive_full_identity_observed" == yes \
    && "$authority_failed_cases" -eq 0 ]]; then
    printf '%s\n' 'PASS: SEC-PRECOMMIT-LOCK-01 authenticates lock objects and trusted external flock acquisition under real contention'
    return 0
  fi
  printf 'RED-CONTROL: SEC-PRECOMMIT-LOCK-01 accepted unsafe lock identity or ambient flock authority in %s acquisition case(s)\n' \
    "$authority_failed_cases"
  printf 'SEC_PRECOMMIT_LOCK_01_SYMLINK_OUTPUT=%s\n' \
    "$(printf '%s' "$symlink_output" | tr '\n' '|')"
  printf 'SEC_PRECOMMIT_LOCK_01_MISMATCH_OUTPUT=%s\n' \
    "$(printf '%s' "$mismatch_output" | tr '\n' '|')"
  printf 'SEC_PRECOMMIT_LOCK_01_LINUX_MISMATCH_OUTPUT=%s\n' \
    "$(printf '%s' "$linux_mismatch_output" | tr '\n' '|')"
  return 1
)

run_sec_precommit_pid_01_case() (
    local phase="$1"
    local substitution_target_count="$2"
    local control_root=""
    local fixture_script=""
    local check_command=""
    local observer=""
    local signal_oracle=""
    local candidate_record=""
    local candidate_term_record=""
    local candidate_pid=""
    local candidate_launcher_pid=""
    local identity_file=""
    local last_observed_identity=""
    local observer_state=""
    local observer_count=""
    local observer_record=""
    local signal_record=""
    local output=""
    local validation_status=0
    local waited=0
    local candidate_alive_before="no"
    local candidate_alive_after="no"
    local candidate_received_os_term="no"
    local substitution_armed="no"
    local term_attempts=0
    local kill_attempts=0
    local substituted_attempts=0

    control_root="$(mktemp -d "${TMPDIR:-/tmp}/sec-precommit-pid-01-$phase.XXXXXXXX")" || return 2
    control_root="$(cd "$control_root" && pwd -P)" || return 2
    fixture_script="$control_root/framework-validate.pid-fixture.sh"
    check_command="$control_root/check-command.sh"
    observer="$control_root/lsof-observer.sh"
    signal_oracle="$control_root/signal-oracle.sh"
    candidate_record="$control_root/candidate.pid"
    candidate_term_record="$control_root/candidate.term"
    identity_file="$control_root/current.identity"
    last_observed_identity="$control_root/last-observed.identity"
    observer_state="$control_root/observer.state"
    observer_count="$control_root/observer.count"
    observer_record="$control_root/observer.record"
    signal_record="$control_root/signal.record"
    trap '
      if [[ "$candidate_pid" =~ ^[1-9][0-9]*$ ]] && pid_alive "$candidate_pid"; then
        /bin/kill -KILL "$candidate_pid" 2>/dev/null || true
      fi
      rm -rf "$control_root"
    ' EXIT

    make_security_pid_source_fixture "$FRAMEWORK_VALIDATE" "$fixture_script" || return 2
    chmod 700 "$fixture_script"
    printf '%s\n' '#!/usr/bin/env bash' \
      "printf '%s\\n' 'SEC-PRECOMMIT-PID-01 direct check completed'" \
      >"$check_command"
    chmod 700 "$check_command"
    cat >"$observer" <<'PID_OBSERVER'
  #!/usr/bin/env bash
  set -u
  targeted=no
  candidate_argument=""
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -p && $# -gt 1 ]]; then
      targeted=yes
      candidate_argument="$2"
      shift
    fi
    shift
  done
  state="$(cat "$BUG045_PID_OBSERVER_STATE")"
  if [[ "$state" == substituted ]]; then
    exit 1
  fi
  if [[ "$targeted" == yes && "$candidate_argument" != "$BUG045_PID_CANDIDATE" ]]; then
    exit 1
  fi
  if [[ "$targeted" == yes ]]; then
    count="$(cat "$BUG045_PID_OBSERVER_COUNT")"
    count=$((count + 1))
    printf '%s\n' "$count" >"$BUG045_PID_OBSERVER_COUNT"
    observed_identity="$(cat "$BUG045_PID_IDENTITY_FILE")"
    printf '%s\n' "$observed_identity" >"$BUG045_PID_LAST_OBSERVED_IDENTITY"
    printf 'phase=%s targetedCount=%s observedIdentity=%s\n' \
      "$BUG045_PID_PHASE" "$count" "$observed_identity" \
      >>"$BUG045_PID_OBSERVER_RECORD"
    printf '%s\n' "$BUG045_PID_CANDIDATE"
    if [[ "$count" -eq "$BUG045_PID_SUBSTITUTE_AT" ]]; then
      printf '%s\n' identity-B >"$BUG045_PID_IDENTITY_FILE"
      printf '%s\n' substituted >"$BUG045_PID_OBSERVER_STATE"
      printf 'phase=%s substitutionAfterObservation=%s newIdentity=identity-B\n' \
        "$BUG045_PID_PHASE" "$count" >>"$BUG045_PID_OBSERVER_RECORD"
    fi
    exit 0
  fi
  printf '%s\n' "$BUG045_PID_CANDIDATE"
PID_OBSERVER
    chmod 700 "$observer"
    cat >"$signal_oracle" <<'PID_SIGNAL_ORACLE'
  #!/usr/bin/env bash
  set -u
  signal_name="$1"
  target_pid="$2"
  observed_identity="$(cat "$BUG045_PID_LAST_OBSERVED_IDENTITY")"
  current_identity="$(cat "$BUG045_PID_IDENTITY_FILE")"
  identity_changed=no
  [[ "$observed_identity" != "$current_identity" ]] && identity_changed=yes
  printf 'phase=%s signal=%s target=%s observedIdentity=%s currentIdentity=%s identityChanged=%s\n' \
    "$BUG045_PID_PHASE" "$signal_name" "$target_pid" "$observed_identity" \
    "$current_identity" "$identity_changed" >>"$BUG045_PID_SIGNAL_RECORD"
  exit 0
PID_SIGNAL_ORACLE
    chmod 700 "$signal_oracle"
    printf '%s\n' identity-A >"$identity_file"
    printf '%s\n' stable >"$observer_state"
    printf '%s\n' 0 >"$observer_count"
    : >"$observer_record"
    : >"$signal_record"

    /usr/bin/perl -MPOSIX=setsid -e '
      my ($pid_record, $term_record) = @ARGV;
      my $child = fork();
      die "fork failed" if !defined $child;
      exit 0 if $child;
      setsid() >= 0 or die "setsid failed";
      open my $pid_fh, ">", $pid_record or die "pid record failed";
      print {$pid_fh} "$$\n";
      close $pid_fh;
      $SIG{TERM} = sub {
        open my $term_fh, ">", $term_record or die "term record failed";
        print {$term_fh} "received\n";
        close $term_fh;
      };
      sleep 30;
    ' "$candidate_record" "$candidate_term_record" &
    candidate_launcher_pid=$!
    wait "$candidate_launcher_pid" 2>/dev/null || true
    while [[ ! -f "$candidate_record" && "$waited" -lt 100 ]]; do
      sleep 0.02
      waited=$((waited + 1))
    done
    candidate_pid="$(tr -cd '0-9' <"$candidate_record" 2>/dev/null || true)"
    if [[ "$candidate_pid" =~ ^[1-9][0-9]*$ ]] && pid_alive "$candidate_pid" \
      && [[ "$(process_state "$candidate_pid")" != Z* ]]; then
      candidate_alive_before=yes
    else
      return 2
    fi

    set +e
    output="$(TMPDIR="$control_root" GITHUB_ACTIONS=true \
      BUBBLES_FRAMEWORK_VALIDATE_MODE=source \
      BUG045_PID_FIXTURE_COMMAND="$check_command" \
      BUG045_PID_PHASE="$phase" BUG045_PID_CANDIDATE="$candidate_pid" \
      BUG045_PID_SUBSTITUTE_AT="$substitution_target_count" \
      BUG045_PID_OBSERVER="$observer" BUG045_PID_SIGNAL_ORACLE="$signal_oracle" \
      BUG045_PID_IDENTITY_FILE="$identity_file" \
      BUG045_PID_LAST_OBSERVED_IDENTITY="$last_observed_identity" \
      BUG045_PID_OBSERVER_STATE="$observer_state" \
      BUG045_PID_OBSERVER_COUNT="$observer_count" \
      BUG045_PID_OBSERVER_RECORD="$observer_record" \
      BUG045_PID_SIGNAL_RECORD="$signal_record" \
      BUG045_PID_REAL_BASH="$RUN_BASH" \
      "$RUN_BASH" -c '
        lsof() { "$BUG045_PID_REAL_BASH" "$BUG045_PID_OBSERVER" "$@"; }
        kill() {
          if [[ ( "${1:-}" == -TERM || "${1:-}" == -KILL ) \
            && "${2:-}" == "$BUG045_PID_CANDIDATE" ]]; then
            "$BUG045_PID_REAL_BASH" "$BUG045_PID_SIGNAL_ORACLE" "${1#-}" "$2"
            return $?
          fi
          builtin kill "$@"
        }
        export -f lsof kill
        exec "$1" "$2" --tier=full --changed-only
      ' _ "$RUN_BASH" "$fixture_script" 2>&1)"
    validation_status=$?
    set -e

    if pid_alive "$candidate_pid" && [[ "$(process_state "$candidate_pid")" != Z* ]]; then
      candidate_alive_after=yes
    fi
    [[ -f "$candidate_term_record" ]] && candidate_received_os_term=yes
    [[ "$(cat "$observer_state")" == substituted ]] && substitution_armed=yes
    term_attempts="$(grep -c ' signal=TERM ' "$signal_record" || true)"
    kill_attempts="$(grep -c ' signal=KILL ' "$signal_record" || true)"
    substituted_attempts="$(grep -c ' identityChanged=yes$' "$signal_record" || true)"
    printf 'SEC_PRECOMMIT_PID_01_CASE phase=%s validationExit=%s candidatePid=%s aliveBefore=%s aliveAfter=%s osTermReceived=%s substitutionAtTargetedObservation=%s substitutionArmed=%s termAttempts=%s killAttempts=%s substitutedSignalAttempts=%s\n' \
      "$phase" "$validation_status" "$candidate_pid" "$candidate_alive_before" \
      "$candidate_alive_after" "$candidate_received_os_term" \
      "$substitution_target_count" "$substitution_armed" "$term_attempts" \
      "$kill_attempts" "$substituted_attempts"
    cat "$observer_record"
    cat "$signal_record"

    if [[ "$validation_status" -ne 0 && "$candidate_alive_before" == yes \
      && "$candidate_alive_after" == yes && "$candidate_received_os_term" == no \
      && "$substitution_armed" == yes && "$substituted_attempts" -eq 0 ]]; then
      return 0
    fi
    printf 'SEC_PRECOMMIT_PID_01_OUTPUT phase=%s output=%s\n' \
      "$phase" "$(printf '%s' "$output" | tr '\n' '|')"
    return 1
  )

run_sec_precommit_pid_01_control() {
    local failed_cases=0
    local stable_cleanup_status=0

    if ! run_sec_precommit_pid_01_case TERM 1; then
      failed_cases=$((failed_cases + 1))
    fi
    if ! run_sec_precommit_pid_01_case KILL 32; then
      failed_cases=$((failed_cases + 1))
    fi

    printf '%s\n' 'SEC_PRECOMMIT_PID_01_STABLE_CLEANUP_BEGIN'
    run_pre_fv_02_control
    stable_cleanup_status=$?
    printf 'SEC_PRECOMMIT_PID_01_STABLE_CLEANUP_EXIT=%s\n' "$stable_cleanup_status"
    printf '%s\n' 'SEC_PRECOMMIT_PID_01_STABLE_CLEANUP_END'
    if [[ "$stable_cleanup_status" -ne 0 ]]; then
      printf '%s\n' 'FAIL-HARNESS: SEC-PRECOMMIT-PID-01 stable-holder cleanup control regressed' >&2
      return 2
    fi
    if [[ "$failed_cases" -eq 0 ]]; then
      printf '%s\n' 'PASS: SEC-PRECOMMIT-PID-01 refuses identity substitution before TERM and KILL'
      return 0
    fi
    printf 'RED-CONTROL: SEC-PRECOMMIT-PID-01 attempted to signal a substituted process identity in %s phase(s)\n' \
      "$failed_cases"
    return 1
}

run_reg_fv_observer_case() (
  local mode="$1"
  local case_root=""
  local function_body=""
  local harness=""
  local probe=""
  local output_file=""
  local observer_record=""
  local observer_fixture=""
  local holder_record=""
  local holder_pid=""
  local holder_created="no"
  local holder_alive_after_validation="no"
  local holder_alive_after_cleanup="no"
  local case_status=0
  local timed_out="no"
  local probe_count=0
  local observer_count=0
  local pass_count=0
  local fail_count=0
  local harness_failures=""
  local waited=0

  case_root="$(mktemp -d "${TMPDIR:-/tmp}/reg-fv-observer-01-$mode.XXXXXXXX")" || exit 2
  function_body="$case_root/run-check.body"
  harness="$case_root/harness.sh"
  probe="$case_root/probe.sh"
  output_file="$case_root/output"
  observer_record="$case_root/observer.record"
  observer_fixture="$case_root/lsof-observer.sh"
  holder_record="$case_root/holder.pid"
  : >"$observer_record"
  : >"$holder_record"

  cleanup_observer_case() {
    local cleanup_pid=""
    cleanup_pid="$(tr -cd '0-9' <"$holder_record" 2>/dev/null || true)"
    if [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] \
      && pid_alive "$cleanup_pid" \
      && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
      kill -TERM "$cleanup_pid" 2>/dev/null || true
      waited=0
      while pid_alive "$cleanup_pid" \
        && [[ "$(process_state "$cleanup_pid")" != Z* ]] \
        && [[ "$waited" -lt 30 ]]; do
        sleep 0.1
        waited=$((waited + 1))
      done
      if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
        kill -KILL "$cleanup_pid" 2>/dev/null || true
      fi
    fi
  }
  trap 'cleanup_observer_case; rm -rf "$case_root"' EXIT INT TERM

  sed -n '/^run_check() {/,/^}/p' "$FRAMEWORK_VALIDATE" >"$function_body"
  if [[ ! -s "$function_body" ]]; then
    printf 'REG_FV_OBSERVER_01_CASE mode=%s harness=invalid reason=run-check-extraction\n' "$mode"
    exit 2
  fi

  if [[ "$mode" == empty ]]; then
    cat >"$probe" <<'EMPTY_PROBE'
#!/usr/bin/env bash
printf '%s\n' REG_FV_OBSERVER_PROBE_EXECUTED
exit 0
EMPTY_PROBE
  else
    cat >"$probe" <<'ESCAPED_PROBE'
#!/usr/bin/env bash
holder_record="$1"
/usr/bin/perl -MPOSIX=setsid -e '
  my ($record) = @ARGV;
  my $child = fork();
  die "fork failed" if !defined $child;
  exit 0 if $child;
  setsid() >= 0 or die "setsid failed";
  open my $fh, ">", $record or die "record failed";
  print {$fh} "$$\n";
  close $fh;
  $SIG{TERM} = sub { exit 0 };
  sleep 30;
' "$holder_record"
waited=0
while [[ ! -f "$holder_record" && "$waited" -lt 50 ]]; do
  /bin/sleep 0.02
  waited=$((waited + 1))
done
printf '%s\n' REG_FV_OBSERVER_PROBE_EXECUTED
exit 0
ESCAPED_PROBE
  fi
  chmod 700 "$probe"

  case "$mode" in
    failed)
      cat >"$observer_fixture" <<'FAILED_OBSERVER'
#!/usr/bin/env bash
printf 'LSOF_FAILED status=73 argv=%q\n' "$*" >>"$REG_FV_OBSERVER_RECORD"
exit 73
FAILED_OBSERVER
      chmod 700 "$observer_fixture"
      ;;
    empty)
      cat >"$observer_fixture" <<'EMPTY_OBSERVER'
#!/usr/bin/env bash
printf 'LSOF_EMPTY status=0 argv=%q\n' "$*" >>"$REG_FV_OBSERVER_RECORD"
exit 0
EMPTY_OBSERVER
      chmod 700 "$observer_fixture"
      ;;
  esac

  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -euo pipefail\n'
    printf 'source "%s"\n' "$GUARD_LIB"
    printf 'VALIDATE_TIER=full\n'
    printf 'LIST_TIER_ONLY=false\n'
    printf 'CHANGED_ONLY=false\n'
    printf 'CACHE_ENABLED=false\n'
    printf 'RECORD_DEBT=false\n'
    printf 'failures=0\n'
    printf 'declare -a failed_check_labels=()\n'
    printf 'declare -a check_durations=()\n'
    cat "$function_body"
    cat <<'OBSERVER_HARNESS'
observer_mode="$1"
observer_record="$2"
probe="$3"
holder_record="$4"
observer_fixture="$5"
export REG_FV_OBSERVER_RECORD="$observer_record"
case "$observer_mode" in
  unavailable)
    _fv_resolve_lsof_path() {
      printf '%s\n' TRUSTED_LSOF_UNAVAILABLE >>"$observer_record"
      return 1
    }
    ;;
  failed)
    _fv_resolve_lsof_path() {
      printf '%s\n' "$observer_fixture"
    }
    ;;
  empty)
    _fv_resolve_lsof_path() {
      printf '%s\n' "$observer_fixture"
    }
    ;;
  *) exit 2 ;;
esac
if [[ "$observer_mode" == empty ]]; then
  run_check "REG-FV-OBSERVER-01 $observer_mode observer probe" "$probe"
else
  run_check "REG-FV-OBSERVER-01 $observer_mode observer probe" "$probe" "$holder_record"
fi
printf 'OBSERVER_HARNESS_FAILURES=%s\n' "$failures"
exit 0
OBSERVER_HARNESS
  } >"$harness"
  chmod 700 "$harness"

  set +e
  bubbles_run_with_timeout 15 /usr/bin/env GITHUB_ACTIONS=true TMPDIR="$case_root" \
    "$RUN_BASH" "$harness" "$mode" "$observer_record" "$probe" "$holder_record" \
    "$observer_fixture" \
    >"$output_file" 2>&1
  case_status=$?
  set -e
  [[ "$case_status" -eq 124 || "$case_status" -eq 137 || "$case_status" -eq 143 ]] && timed_out=yes
  cat "$output_file"

  probe_count="$(grep -Fc REG_FV_OBSERVER_PROBE_EXECUTED "$output_file" 2>/dev/null || true)"
  observer_count="$(wc -l <"$observer_record" 2>/dev/null | tr -d '[:space:]' || true)"
  pass_count="$(grep -c "^PASS: REG-FV-OBSERVER-01 $mode observer probe$" "$output_file" 2>/dev/null || true)"
  fail_count="$(grep -c "^FAIL: REG-FV-OBSERVER-01 $mode observer probe$" "$output_file" 2>/dev/null || true)"
  harness_failures="$(awk -F= '/^OBSERVER_HARNESS_FAILURES=/{value=$2} END{print value}' "$output_file")"
  holder_pid="$(tr -cd '0-9' <"$holder_record" 2>/dev/null || true)"
  if [[ "$holder_pid" =~ ^[1-9][0-9]*$ ]]; then
    holder_created=yes
    if pid_alive "$holder_pid" && [[ "$(process_state "$holder_pid")" != Z* ]]; then
      holder_alive_after_validation=yes
    fi
  fi

  cleanup_observer_case
  if [[ "$holder_pid" =~ ^[1-9][0-9]*$ ]] \
    && pid_alive "$holder_pid" \
    && [[ "$(process_state "$holder_pid")" != Z* ]]; then
    holder_alive_after_cleanup=yes
  fi
  printf 'REG_FV_OBSERVER_01_CASE mode=%s harnessExit=%s timedOut=%s probeCount=%s observerCount=%s passCount=%s failCount=%s harnessFailures=%s holderCreated=%s holderAliveAfterValidation=%s holderAliveAfterCleanup=%s\n' \
    "$mode" "$case_status" "$timed_out" "$probe_count" "$observer_count" \
    "$pass_count" "$fail_count" "${harness_failures:-missing}" "$holder_created" \
    "$holder_alive_after_validation" "$holder_alive_after_cleanup"
  trap - EXIT INT TERM
  rm -rf "$case_root"

  [[ "$case_status" -eq 0 && "$timed_out" == no && "$probe_count" -eq 1 \
    && "$observer_count" -eq 1 && "$holder_alive_after_cleanup" == no ]] || exit 2
  if [[ "$mode" == empty ]]; then
    [[ "$holder_created" == no && "$pass_count" -eq 1 && "$fail_count" -eq 0 \
      && "$harness_failures" -eq 0 ]] || exit 2
    exit 0
  fi
  [[ "$holder_created" == yes ]] || exit 2
  [[ "$pass_count" -eq 0 && "$fail_count" -eq 1 && "$harness_failures" -eq 1 ]] \
    && exit 0
  exit 1
)

run_reg_fv_observer_control() {
  local unavailable_status=0
  local failed_status=0
  local empty_status=0

  printf '%s\n' 'REG_FV_OBSERVER_01_BEGIN'
  run_reg_fv_observer_case unavailable || unavailable_status=$?
  run_reg_fv_observer_case failed || failed_status=$?
  run_reg_fv_observer_case empty || empty_status=$?
  printf 'REG_FV_OBSERVER_01_CONTROL unavailableStatus=%s failedStatus=%s emptyStatus=%s\n' \
    "$unavailable_status" "$failed_status" "$empty_status"
  if [[ "$unavailable_status" -eq 0 && "$failed_status" -eq 0 && "$empty_status" -eq 0 ]]; then
    printf '%s\n' 'PASS: REG-FV-OBSERVER-01 fails closed for unavailable and failed observers while accepting a successful empty observation'
    return 0
  fi
  if [[ "$unavailable_status" -eq 2 || "$failed_status" -eq 2 || "$empty_status" -eq 2 ]]; then
    printf '%s\n' 'FAIL-HARNESS: REG-FV-OBSERVER-01 observer fixture was not definitive or left process residue'
    return 2
  fi
  printf '%s\n' 'RED-CONTROL: REG-FV-OBSERVER-01 validation treated an unavailable or failed descriptor observer as an empty holder set'
  return 1
}

run_sec_fv_lsof_authority_01_control() (
  local case_root=""
  local resolver_body=""
  local function_body=""
  local harness=""
  local probe=""
  local fake_dir=""
  local fake_lsof=""
  local fake_marker=""
  local holder_record=""
  local output_file=""
  local holder_pid=""
  local case_status=0
  local timed_out="no"
  local fake_count=0
  local fail_count=0
  local harness_failures=""
  local holder_created="no"
  local holder_alive_after_validation="no"
  local holder_alive_after_cleanup="no"
  local waited=0

  case_root="$(mktemp -d "${TMPDIR:-/tmp}/sec-fv-lsof-authority-01.XXXXXXXX")" || exit 2
  resolver_body="$case_root/lsof-resolver.body"
  function_body="$case_root/run-check.body"
  harness="$case_root/harness.sh"
  probe="$case_root/probe.sh"
  fake_dir="$case_root/path-shadow"
  fake_lsof="$fake_dir/lsof"
  fake_marker="$case_root/fake-lsof.marker"
  holder_record="$case_root/holder.pid"
  output_file="$case_root/output"
  mkdir -p "$fake_dir"
  : >"$fake_marker"
  : >"$holder_record"

  cleanup_lsof_authority_case() {
    local cleanup_pid=""
    cleanup_pid="$(tr -cd '0-9' <"$holder_record" 2>/dev/null || true)"
    if [[ "$cleanup_pid" =~ ^[1-9][0-9]*$ ]] \
      && pid_alive "$cleanup_pid" \
      && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
      kill -TERM "$cleanup_pid" 2>/dev/null || true
      waited=0
      while pid_alive "$cleanup_pid" \
        && [[ "$(process_state "$cleanup_pid")" != Z* ]] \
        && [[ "$waited" -lt 30 ]]; do
        sleep 0.1
        waited=$((waited + 1))
      done
      if pid_alive "$cleanup_pid" && [[ "$(process_state "$cleanup_pid")" != Z* ]]; then
        kill -KILL "$cleanup_pid" 2>/dev/null || true
      fi
    fi
  }
  trap 'cleanup_lsof_authority_case; rm -rf "$case_root"' EXIT INT TERM

  sed -n '/^_fv_resolve_lsof_path() {/,/^}/p' "$FRAMEWORK_VALIDATE" >"$resolver_body"
  sed -n '/^run_check() {/,/^}/p' "$FRAMEWORK_VALIDATE" >"$function_body"
  if [[ ! -s "$function_body" ]]; then
    printf '%s\n' 'SEC_FV_LSOF_AUTHORITY_01 harness=invalid reason=run-check-extraction'
    exit 2
  fi

  cat >"$probe" <<'AUTHORITY_PROBE'
#!/usr/bin/env bash
holder_record="$1"
/usr/bin/perl -MPOSIX=setsid -e '
  my ($record) = @ARGV;
  my $child = fork();
  die "fork failed" if !defined $child;
  exit 0 if $child;
  setsid() >= 0 or die "setsid failed";
  open my $fh, ">", $record or die "record failed";
  print {$fh} "$$\n";
  close $fh;
  $SIG{TERM} = sub { exit 0 };
  sleep 30;
' "$holder_record"
waited=0
while [[ ! -s "$holder_record" && "$waited" -lt 50 ]]; do
  /bin/sleep 0.02
  waited=$((waited + 1))
done
printf '%s\n' SEC_FV_LSOF_AUTHORITY_PROBE_EXECUTED
exit 0
AUTHORITY_PROBE
  chmod 700 "$probe"

  cat >"$fake_lsof" <<'FAKE_LSOF'
#!/usr/bin/env bash
printf '%s\n' FAKE_LSOF_EXECUTED >>"$SEC_FV_LSOF_MARKER"
if [[ -s "$SEC_FV_LSOF_HOLDER_RECORD" ]]; then
  cat "$SEC_FV_LSOF_HOLDER_RECORD"
fi
exit 0
FAKE_LSOF
  chmod 700 "$fake_lsof"

  {
    printf '#!/usr/bin/env bash\n'
    printf 'set -euo pipefail\n'
    printf 'source "%s"\n' "$GUARD_LIB"
    printf 'VALIDATE_TIER=full\n'
    printf 'LIST_TIER_ONLY=false\n'
    printf 'CHANGED_ONLY=false\n'
    printf 'CACHE_ENABLED=false\n'
    printf 'RECORD_DEBT=false\n'
    printf 'failures=0\n'
    printf 'declare -a failed_check_labels=()\n'
    printf 'declare -a check_durations=()\n'
    cat "$resolver_body"
    cat "$function_body"
    cat <<'AUTHORITY_HARNESS'
fake_dir="$1"
fake_marker="$2"
probe="$3"
holder_record="$4"
export SEC_FV_LSOF_MARKER="$fake_marker"
export SEC_FV_LSOF_HOLDER_RECORD="$holder_record"
PATH="$fake_dir:$PATH"
export PATH
set +e
run_check "SEC-FV-LSOF-AUTHORITY-01 path shadow probe" "$probe" "$holder_record"
run_check_status=$?
set -e
printf 'AUTHORITY_HARNESS_RUN_CHECK_STATUS=%s\n' "$run_check_status"
printf 'AUTHORITY_HARNESS_FAILURES=%s\n' "$failures"
exit 0
AUTHORITY_HARNESS
  } >"$harness"
  chmod 700 "$harness"

  set +e
  bubbles_run_with_timeout 15 /usr/bin/env GITHUB_ACTIONS=true TMPDIR="$case_root" \
    "$RUN_BASH" "$harness" "$fake_dir" "$fake_marker" "$probe" "$holder_record" \
    >"$output_file" 2>&1
  case_status=$?
  set -e
  [[ "$case_status" -eq 124 || "$case_status" -eq 137 || "$case_status" -eq 143 ]] && timed_out=yes
  cat "$output_file"

  fake_count="$(grep -Fc FAKE_LSOF_EXECUTED "$fake_marker" 2>/dev/null || true)"
  fail_count="$(grep -c '^FAIL: SEC-FV-LSOF-AUTHORITY-01 path shadow probe$' "$output_file" 2>/dev/null || true)"
  harness_failures="$(awk -F= '/^AUTHORITY_HARNESS_FAILURES=/{value=$2} END{print value}' "$output_file")"
  holder_pid="$(tr -cd '0-9' <"$holder_record" 2>/dev/null || true)"
  if [[ "$holder_pid" =~ ^[1-9][0-9]*$ ]]; then
    holder_created=yes
    if pid_alive "$holder_pid" && [[ "$(process_state "$holder_pid")" != Z* ]]; then
      holder_alive_after_validation=yes
    fi
  fi

  cleanup_lsof_authority_case
  if [[ "$holder_pid" =~ ^[1-9][0-9]*$ ]] \
    && pid_alive "$holder_pid" \
    && [[ "$(process_state "$holder_pid")" != Z* ]]; then
    holder_alive_after_cleanup=yes
  fi
  printf 'SEC_FV_LSOF_AUTHORITY_01 harnessExit=%s timedOut=%s fakeCount=%s failCount=%s harnessFailures=%s holderCreated=%s holderAliveAfterValidation=%s holderAliveAfterCleanup=%s\n' \
    "$case_status" "$timed_out" "$fake_count" "$fail_count" "${harness_failures:-missing}" \
    "$holder_created" "$holder_alive_after_validation" "$holder_alive_after_cleanup"
  trap - EXIT INT TERM
  rm -rf "$case_root"

  if [[ "$case_status" -ne 0 || "$timed_out" != no \
    || "$holder_created" != yes || "$holder_alive_after_validation" != no \
    || "$holder_alive_after_cleanup" != no || "$fail_count" -ne 1 \
    || "$harness_failures" -ne 1 ]]; then
    printf '%s\n' 'FAIL-HARNESS: SEC-FV-LSOF-AUTHORITY-01 did not exercise detached-holder cleanup safely'
    exit 2
  fi
  if [[ "$fake_count" -eq 0 ]]; then
    printf '%s\n' 'PASS: SEC-FV-LSOF-AUTHORITY-01 ignores PATH-shadowed lsof and cleans the test-owned holder with the trusted observer'
    exit 0
  fi
  printf 'RED-CONTROL: SEC-FV-LSOF-AUTHORITY-01 executed PATH-shadowed lsof %s time(s)\n' "$fake_count"
  exit 1
)

case "${1:-}" in
  --pre-fv-01)
    [[ $# -eq 1 ]] || exit 2
    run_pre_fv_01_control
    exit $?
    ;;
  --pre-fv-02)
    [[ $# -eq 1 ]] || exit 2
    run_pre_fv_02_control
    exit $?
    ;;
  --reg-fv-observer-01)
    [[ $# -eq 1 ]] || exit 2
    run_reg_fv_observer_control
    exit $?
    ;;
  --sec-fv-lsof-authority-01)
    [[ $# -eq 1 ]] || exit 2
    run_sec_fv_lsof_authority_01_control
    exit $?
    ;;
  --sec-precommit-lock-01)
    [[ $# -eq 1 ]] || exit 2
    run_sec_precommit_lock_01_control
    exit $?
    ;;
  --sec-precommit-pid-01)
    [[ $# -eq 1 ]] || exit 2
    run_sec_precommit_pid_01_control
    exit $?
    ;;
esac

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug045-regression.XXXXXXXX")" || exit 2
WORKSPACE="$(cd "$WORKSPACE" && pwd -P)" || exit 2
ACTIVE_CASE_PID=""

# shellcheck disable=SC2329 # Invoked by EXIT, INT, and TERM traps.
cleanup_test() {
  if [[ -n "$ACTIVE_CASE_PID" ]] && process_group_alive "$ACTIVE_CASE_PID"; then
    signal_process_group KILL "$ACTIVE_CASE_PID"
  fi
  rm -rf "$WORKSPACE"
}
trap cleanup_test EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

run_supervised_case() {
  local mode="$1"
  local source_selftest="$2"
  local output_file="$WORKSPACE/$mode.output"
  local case_root="$WORKSPACE/$mode.fixture"
  local monitor_was_enabled=0
  local elapsed=0
  local timed_out="no"
  local case_status=0
  local group_residue="no"
  local waited=0

  [[ "$-" == *m* ]] && monitor_was_enabled=1
  set -m
  "$RUN_BASH" "$TEST_FILE" --case-child "$mode" "$case_root" "$source_selftest" >"$output_file" 2>&1 &
  ACTIVE_CASE_PID=$!
  [[ "$monitor_was_enabled" -eq 1 ]] || set +m

  while pid_alive "$ACTIVE_CASE_PID" && [[ "$elapsed" -lt "$CASE_DEADLINE_SECONDS" ]]; do
    sleep 1
    elapsed=$((elapsed + 1))
  done
  if pid_alive "$ACTIVE_CASE_PID"; then
    timed_out="yes"
    signal_process_group TERM "$ACTIVE_CASE_PID"
    waited=0
    while process_group_alive "$ACTIVE_CASE_PID" && [[ "$waited" -lt 5 ]]; do
      sleep 1
      waited=$((waited + 1))
    done
    process_group_alive "$ACTIVE_CASE_PID" && signal_process_group KILL "$ACTIVE_CASE_PID"
  fi

  wait "$ACTIVE_CASE_PID" 2>/dev/null
  case_status=$?
  if process_group_alive "$ACTIVE_CASE_PID"; then
    group_residue="yes"
    signal_process_group KILL "$ACTIVE_CASE_PID"
  fi

  cat "$output_file"
  printf 'SUPERVISOR_CASE mode=%s exit=%s timedOut=%s elapsedSeconds=%s groupResidue=%s deadlineSeconds=%s\n' \
    "$mode" "$case_status" "$timed_out" "$elapsed" "$group_residue" "$CASE_DEADLINE_SECONDS"
  rm -f "$output_file"
  ACTIVE_CASE_PID=""

  if [[ "$timed_out" == "yes" || "$group_residue" == "yes" ]]; then
    return 2
  fi
  return "$case_status"
}

run_term_cleanup_control() {
  local mode="$1"
  local source_selftest="$2"
  local term_tmp="$WORKSPACE/$mode.term-tmp"
  local ready_file="$term_tmp/tier-lock-ready"
  local output_file="$WORKSPACE/$mode.term-output"
  local monitor_was_enabled=0
  local elapsed=0
  local waited=0
  local term_status=0
  local ready_observed="no"
  local group_residue="no"
  local tier_residue_count=0
  local residue_path=""

  mkdir -p "$term_tmp"
  [[ "$-" == *m* ]] && monitor_was_enabled=1
  set -m
  TMPDIR="$term_tmp" BUG045_TERM_READY_FILE="$ready_file" \
    "$RUN_BASH" "$source_selftest" >"$output_file" 2>&1 &
  ACTIVE_CASE_PID=$!
  [[ "$monitor_was_enabled" -eq 1 ]] || set +m

  while [[ ! -f "$ready_file" ]] \
    && pid_alive "$ACTIVE_CASE_PID" \
    && [[ "$elapsed" -lt 30 ]]; do
    sleep 1
    elapsed=$((elapsed + 1))
  done
  if [[ -f "$ready_file" ]]; then
    ready_observed="yes"
    signal_process_group TERM "$ACTIVE_CASE_PID"
  elif pid_alive "$ACTIVE_CASE_PID"; then
    signal_process_group KILL "$ACTIVE_CASE_PID"
  fi

  waited=0
  while pid_alive "$ACTIVE_CASE_PID" \
    && [[ "$(process_state "$ACTIVE_CASE_PID")" != Z* ]] \
    && [[ "$waited" -lt 5 ]]; do
    sleep 1
    waited=$((waited + 1))
  done
  if pid_alive "$ACTIVE_CASE_PID" \
    && [[ "$(process_state "$ACTIVE_CASE_PID")" != Z* ]]; then
    signal_process_group KILL "$ACTIVE_CASE_PID"
  fi
  wait "$ACTIVE_CASE_PID" 2>/dev/null
  term_status=$?

  waited=0
  while process_group_alive "$ACTIVE_CASE_PID" && [[ "$waited" -lt 5 ]]; do
    sleep 1
    waited=$((waited + 1))
  done
  if process_group_alive "$ACTIVE_CASE_PID"; then
    group_residue="yes"
    signal_process_group KILL "$ACTIVE_CASE_PID"
  fi

  cat "$output_file"
  while IFS= read -r residue_path; do
    [[ -n "$residue_path" ]] || continue
    tier_residue_count=$((tier_residue_count + 1))
    printf 'TERM_TIER_RESIDUE mode=%s path=%s\n' "$mode" "$residue_path"
  done < <(find "$term_tmp" -type d -name 'bubbles-framework-validate-tier.*' -print)
  printf 'TERM_CONTROL mode=%s exit=%s ready=%s elapsedSeconds=%s groupResidue=%s tierResidueBeforeOuterCleanup=%s\n' \
    "$mode" "$term_status" "$ready_observed" "$elapsed" "$group_residue" "$tier_residue_count"

  rm -rf "$term_tmp"
  rm -f "$output_file"
  ACTIVE_CASE_PID=""

  [[ "$ready_observed" == "yes" ]] || return 2
  [[ "$term_status" -ne 0 ]] || return 2
  [[ "$group_residue" == "no" ]] || return 2
  if [[ "$mode" == "source-cleanup" ]]; then
    [[ "$tier_residue_count" -eq 0 ]] && return 0
    return 2
  fi
  [[ "$tier_residue_count" -ge 1 ]] && return 0
  return 2
}

pass_count=0
contract_failures=0
harness_failures=0

pass() {
  pass_count=$((pass_count + 1))
  printf 'PASS: %s\n' "$1"
}

contract_fail() {
  contract_failures=$((contract_failures + 1))
  printf 'FAIL-CONTRACT: %s\n' "$1" >&2
}

harness_fail() {
  harness_failures=$((harness_failures + 1))
  printf 'FAIL-HARNESS: %s\n' "$1" >&2
}

# B045-RC-004 adversarial classifier control. The transferred parent is
# deliberately neither PID 1 nor the original holder. A regression to the
# literal `PPID == 1` predicate fails this control deterministically, without
# asking the host to provide a particular subreaper topology. The two negative
# cases prevent an unconditional-true replacement from satisfying the check.
synthetic_original_holder_pid=42000
synthetic_transferred_parent_pid=42001
synthetic_transfer_detected="no"
synthetic_same_parent_rejected="no"
synthetic_live_holder_rejected="no"
if parent_transfer_detected "$synthetic_original_holder_pid" no "$synthetic_transferred_parent_pid"; then
  synthetic_transfer_detected="yes"
fi
if ! parent_transfer_detected "$synthetic_original_holder_pid" no "$synthetic_original_holder_pid"; then
  synthetic_same_parent_rejected="yes"
fi
if ! parent_transfer_detected "$synthetic_original_holder_pid" yes "$synthetic_transferred_parent_pid"; then
  synthetic_live_holder_rejected="yes"
fi
printf 'PARENT_TRANSFER_CLASSIFIER_CONTROL original=%s transferredParent=%s transferredDetected=%s sameParentRejected=%s liveHolderRejected=%s\n' \
  "$synthetic_original_holder_pid" "$synthetic_transferred_parent_pid" \
  "$synthetic_transfer_detected" "$synthetic_same_parent_rejected" \
  "$synthetic_live_holder_rejected"
if [[ "$synthetic_transfer_detected" == "yes" ]] \
  && [[ "$synthetic_same_parent_rejected" == "yes" ]] \
  && [[ "$synthetic_live_holder_rejected" == "yes" ]]; then
  pass 'the shared parent-transfer classifier accepts a synthetic non-PID-1 adopter and rejects false transfers'
else
  harness_fail 'the shared parent-transfer classifier regressed to a host-specific or vacuous predicate'
fi

printf '%s\n' 'REG_FV_OBSERVER_01_AGGREGATE_BEGIN'
run_reg_fv_observer_control
reg_fv_observer_status=$?
printf 'REG_FV_OBSERVER_01_AGGREGATE_EXIT=%s\n' "$reg_fv_observer_status"
case "$reg_fv_observer_status" in
  0) pass 'descriptor cleanup fails closed when its observer is unavailable or fails' ;;
  1) contract_fail 'descriptor cleanup treated an unavailable or failed observer as an empty holder set' ;;
  *) harness_fail 'descriptor-observer control was not definitive or did not clean its detached process' ;;
esac

printf '%s\n' 'SEC_FV_LSOF_AUTHORITY_01_AGGREGATE_BEGIN'
run_sec_fv_lsof_authority_01_control
sec_fv_lsof_authority_status=$?
printf 'SEC_FV_LSOF_AUTHORITY_01_AGGREGATE_EXIT=%s\n' "$sec_fv_lsof_authority_status"
case "$sec_fv_lsof_authority_status" in
  0) pass 'descriptor cleanup ignores a PATH-shadowed lsof and retains trusted holder observation' ;;
  1) contract_fail 'descriptor cleanup accepted security authority from a PATH-shadowed lsof' ;;
  *) harness_fail 'PATH-shadowed lsof control was not definitive or did not clean its test-owned holder' ;;
esac

OPTIONAL_SKIP_PATH="$WORKSPACE/optional-skip-path"
OPTIONAL_SKIP_OUTPUT="$WORKSPACE/optional-skip.output"
mkdir -p "$OPTIONAL_SKIP_PATH"
for optional_probe_command in basename dirname; do
  ln -s "$(command -v "$optional_probe_command")" "$OPTIONAL_SKIP_PATH/$optional_probe_command"
done
PATH="$OPTIONAL_SKIP_PATH" "$RUN_BASH" "$TEST_FILE" >"$OPTIONAL_SKIP_OUTPUT" 2>&1
optional_skip_status=$?
cat "$OPTIONAL_SKIP_OUTPUT"
if [[ "$optional_skip_status" -eq 0 ]] \
  && grep -Fq 'SKIP (optional lifecycle observer(s) unavailable: flock,lsof)' "$OPTIONAL_SKIP_OUTPUT"; then
  pass 'missing optional flock/lsof observers produce a truthful zero-exit skip'
else
  harness_fail "optional-observer absence did not use the skip contract (exit=$optional_skip_status)"
fi
rm -rf "$OPTIONAL_SKIP_PATH"
rm -f "$OPTIONAL_SKIP_OUTPUT"

ASYNC_SOURCE_MUTANT="$WORKSPACE/framework-validate-tier-selftest.async-mutant.sh"
ASYNC_SOURCE_MUTANT_READY=no
if make_async_lock_source_mutant "$SOURCE_SELFTEST" "$ASYNC_SOURCE_MUTANT"; then
  ASYNC_SOURCE_MUTANT_READY=yes
  pass 'the production tier-selftest boundary admits exactly one executable former-lifecycle mutation'
else
  harness_fail 'the production tier-selftest lock boundary drifted or already contains the former asynchronous lifecycle'
fi

TERM_SOURCE_PROBE="$WORKSPACE/framework-validate-tier-selftest.term-probe.sh"
TERM_NO_CLEANUP_MUTANT="$WORKSPACE/framework-validate-tier-selftest.term-no-cleanup-mutant.sh"
TERM_SOURCE_PROBE_READY=no
TERM_NO_CLEANUP_MUTANT_READY=no
if make_term_cleanup_probe "$SOURCE_SELFTEST" "$TERM_SOURCE_PROBE" retained; then
  TERM_SOURCE_PROBE_READY=yes
  pass 'the source tier-selftest exposes one bounded TERM interception point with EXIT cleanup retained'
else
  harness_fail 'the source tier-selftest TERM cleanup boundary could not be instrumented'
fi
if make_term_cleanup_probe "$SOURCE_SELFTEST" "$TERM_NO_CLEANUP_MUTANT" removed; then
  TERM_NO_CLEANUP_MUTANT_READY=yes
  pass 'the source tier-selftest admits one executable EXIT-cleanup removal mutation'
else
  harness_fail 'the source tier-selftest EXIT cleanup boundary could not be mutated'
fi

printf '%s\n' 'test_36_framework_validate_tier_lock_lifecycle'
printf 'RUN_BASH=%s\n' "$RUN_BASH"
printf 'CASE_DEADLINE_SECONDS=%s\n' "$CASE_DEADLINE_SECONDS"
printf '%s\n' 'PRIMARY_COMPLETE_TREE_BEGIN'
run_supervised_case primary "$SOURCE_SELFTEST"
primary_status=$?
printf 'PRIMARY_COMPLETE_TREE_EXIT=%s\n' "$primary_status"
printf '%s\n' 'PRIMARY_COMPLETE_TREE_END'
case "$primary_status" in
  0) pass 'the real tier selftest closes its CI capture tree with no lock-holding descendant' ;;
  1) contract_fail 'the real tier selftest printed OK and exited 0 while a blocked orphan flock kept the capture reader alive' ;;
  *) harness_fail "the primary complete-tree probe could not classify the lifecycle (exit=$primary_status)" ;;
esac

printf '%s\n' 'NEGATIVE_CONTROL_BEGIN'
if [[ "$ASYNC_SOURCE_MUTANT_READY" == "yes" ]]; then
  run_supervised_case negative-control "$ASYNC_SOURCE_MUTANT"
  negative_status=$?
else
  negative_status=2
fi
printf 'NEGATIVE_CONTROL_EXIT=%s\n' "$negative_status"
printf '%s\n' 'NEGATIVE_CONTROL_END'
if [[ "$negative_status" -eq 0 ]]; then
  pass 'the executable old-lifecycle control proves holder death, parent transfer, and shared lock/FIFO identity'
else
  harness_fail "the executable old-lifecycle control was not detected (exit=$negative_status)"
fi

printf '%s\n' 'TERM_SOURCE_CLEANUP_BEGIN'
if [[ "$TERM_SOURCE_PROBE_READY" == "yes" ]]; then
  run_term_cleanup_control source-cleanup "$TERM_SOURCE_PROBE"
  term_source_status=$?
else
  term_source_status=2
fi
printf 'TERM_SOURCE_CLEANUP_EXIT=%s\n' "$term_source_status"
printf '%s\n' 'TERM_SOURCE_CLEANUP_END'
if [[ "$term_source_status" -eq 0 ]]; then
  pass 'TERM interruption leaves no tier-owned private lock directory before outer cleanup'
else
  harness_fail "the source tier-selftest TERM cleanup contract failed (exit=$term_source_status)"
fi

printf '%s\n' 'TERM_CLEANUP_NEGATIVE_CONTROL_BEGIN'
if [[ "$TERM_NO_CLEANUP_MUTANT_READY" == "yes" ]]; then
  run_term_cleanup_control cleanup-removed-control "$TERM_NO_CLEANUP_MUTANT"
  term_negative_status=$?
else
  term_negative_status=2
fi
printf 'TERM_CLEANUP_NEGATIVE_CONTROL_EXIT=%s\n' "$term_negative_status"
printf '%s\n' 'TERM_CLEANUP_NEGATIVE_CONTROL_END'
if [[ "$term_negative_status" -eq 0 ]]; then
  pass 'the TERM control detects tier-owned residue when source EXIT cleanup is removed'
else
  harness_fail "the TERM cleanup mutation was not detected (exit=$term_negative_status)"
fi

rm -f "$ASYNC_SOURCE_MUTANT" "$TERM_SOURCE_PROBE" "$TERM_NO_CLEANUP_MUTANT"

workspace_residue=0
while IFS= read -r residue_path; do
  [[ -n "$residue_path" ]] || continue
  workspace_residue=$((workspace_residue + 1))
  printf 'WORKSPACE_RESIDUE=%s\n' "$residue_path"
done < <(find "$WORKSPACE" -mindepth 1 -print)
printf 'WORKSPACE_RESIDUE_COUNT=%s\n' "$workspace_residue"
if [[ "$workspace_residue" -eq 0 ]]; then
  pass 'both supervised cases remove their isolated lock and FIFO fixtures'
else
  harness_fail "supervised cases left $workspace_residue fixture entries"
fi

printf 'test_36_framework_validate_tier_lock_lifecycle: passes=%s contractFailures=%s harnessFailures=%s\n' \
  "$pass_count" "$contract_failures" "$harness_failures"

[[ "$harness_failures" -eq 0 ]] || exit 2
[[ "$contract_failures" -eq 0 ]] || exit 1
exit 0
