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

for required_path in "$SOURCE_SELFTEST" "$TEST_FILE"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_36_framework_validate_tier_lock_lifecycle: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done

missing_optional_observers=()
for optional_observer in flock lsof; do
  command -v "$optional_observer" >/dev/null 2>&1 \
    || missing_optional_observers+=("$optional_observer")
done
if [[ "${#missing_optional_observers[@]}" -gt 0 ]]; then
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
