#!/usr/bin/env bash
# python-env-selftest.sh — hermetic selftest for python-env.sh.
#
# Proves the RESOLUTION CONTRACT without touching the operator's real managed
# environment: every case points BUBBLES_PYTHON_HOME at a mktemp dir, and the
# "satisfying" interpreters are tiny fake python3 shims, so no network, no pip,
# and no dependency on whether this machine happens to have PyYAML installed.
#
# ADVERSARIAL CASES (each would pass if the logic regressed the obvious way):
#   A1  an interpreter satisfying only ONE of the two modules must NOT count as
#       satisfying. A resolver that stops at the first successful import passes
#       every other case here.
#   A2  activate() must NOT prepend when PATH's python3 already satisfies —
#       otherwise it silently hijacks an operator who provisioned their own way.
#   A3  the module list must stay in lockstep with dependency-posture.sh's
#       BUBBLES_REQUIRED_DEPS, so the documented duplication cannot drift.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_SH="$SCRIPT_DIR/python-env.sh"
SELFTEST_SCRIPT="$SCRIPT_DIR/python-env-selftest.sh"
POSTURE_SH="$SCRIPT_DIR/dependency-posture.sh"
GUARD_LIB="$SCRIPT_DIR/guard-lib.sh"

if [[ ! -f "$ENV_SH" || ! -f "$GUARD_LIB" ]]; then
  echo "python-env-selftest: required surface missing (python-env.sh or guard-lib.sh)" >&2
  exit 2
fi

# Probe execution must use the same bounded watchdog API as production callers.
# shellcheck source=/dev/null
source "$GUARD_LIB"
# shellcheck source=/dev/null
source "$ENV_SH"

pass=0
fail=0
TMP_ROOT="$(cd "$(mktemp -d)" && pwd -P)"
SELFTEST_COMPLETED=0
SELFTEST_LIFECYCLE_PID=''
SELFTEST_ACTIVE_CHILD=''
SELFTEST_WATCHDOG_PID=''
SELFTEST_WINDOW_RELEASE_OPEN=0
SELFTEST_MUTANT_PRIVATE_ROOT_RECORD=''

selftest_stop_exact_child() {
  if [[ "$SELFTEST_LIFECYCLE_PID" =~ ^[1-9][0-9]*$ ]]; then
    builtin kill -TERM "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
    builtin kill -KILL "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
    builtin wait "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
  fi
  SELFTEST_LIFECYCLE_PID=''
}

selftest_stop_watchdog() {
  if [[ "$SELFTEST_WATCHDOG_PID" =~ ^[1-9][0-9]*$ ]]; then
    builtin kill -TERM "$SELFTEST_WATCHDOG_PID" 2>/dev/null || true
    builtin wait "$SELFTEST_WATCHDOG_PID" 2>/dev/null || true
  fi
  SELFTEST_WATCHDOG_PID=''
}

selftest_release_mutant_window() {
  if [[ "$SELFTEST_WINDOW_RELEASE_OPEN" -eq 1 ]]; then
    printf '%s\n' RELEASE >&6 2>/dev/null || true
    exec 6>&-
    SELFTEST_WINDOW_RELEASE_OPEN=0
  fi
}

selftest_wait_runner_bounded() {
  local runner_pid="$1"
  local term_after="$2"
  local kill_after="$3"
  local runner_status=0

  (
    /bin/sleep "$term_after"
    builtin kill -TERM "$runner_pid" 2>/dev/null || true
    /bin/sleep "$kill_after"
    builtin kill -KILL "$runner_pid" 2>/dev/null || true
  ) &
  SELFTEST_WATCHDOG_PID=$!
  if builtin wait "$runner_pid" 2>/dev/null; then
    runner_status=0
  else
    runner_status=$?
  fi
  SELFTEST_ACTIVE_CHILD=''
  selftest_stop_watchdog
  return "$runner_status"
}

selftest_stop_active_child() {
  selftest_release_mutant_window
  if [[ "$SELFTEST_ACTIVE_CHILD" =~ ^[1-9][0-9]*$ ]]; then
    selftest_wait_runner_bounded "$SELFTEST_ACTIVE_CHILD" 2 1 || true
  fi
  SELFTEST_ACTIVE_CHILD=''
  return 0
}

selftest_remove_recorded_private_root() {
  local recorded_root=""
  if [[ -n "$SELFTEST_MUTANT_PRIVATE_ROOT_RECORD" &&
    -f "$SELFTEST_MUTANT_PRIVATE_ROOT_RECORD" ]]; then
    recorded_root="$(/bin/cat "$SELFTEST_MUTANT_PRIVATE_ROOT_RECORD" 2>/dev/null || true)"
    case "$recorded_root" in
      "$TMP_ROOT"/neg-b039-*/bubbles-python-security.*) /bin/rm -rf "$recorded_root" ;;
    esac
  fi
  SELFTEST_MUTANT_PRIVATE_ROOT_RECORD=''
}

selftest_cleanup() {
  local status=$?
  builtin trap - EXIT HUP INT TERM
  bubbles_python_security_cleanup || true
  selftest_stop_watchdog
  selftest_release_mutant_window
  selftest_stop_active_child
  selftest_stop_exact_child
  selftest_remove_recorded_private_root
  /bin/rm -rf "$TMP_ROOT"
  if [[ "$SELFTEST_COMPLETED" -ne 1 && "$status" -eq 0 ]]; then
    echo "FAIL: python-env selftest exited before its completion summary" >&2
    status=1
  fi
  exit "$status"
}

selftest_signal() {
  local status="$1"
  trap - HUP INT TERM
  exit "$status"
}

trap selftest_cleanup EXIT
trap 'selftest_signal 129' HUP
trap 'selftest_signal 130' INT
trap 'selftest_signal 143' TERM

if [[ -n "${BUBBLES_PYTHON_SELFTEST_CHILD_MODE:-}" ]]; then
  if [[ -z "${BUBBLES_PYTHON_SELFTEST_READY_FILE:-}" ]]; then
    echo "python-env selftest child mode requires a ready file" >&2
    exit 2
  fi
  case "$BUBBLES_PYTHON_SELFTEST_CHILD_MODE" in
    premature-exit)
      printf '%s\n' "$TMP_ROOT" >"$BUBBLES_PYTHON_SELFTEST_READY_FILE"
      exit 0
      ;;
    timeout-exit)
      printf '%s\n' "$TMP_ROOT" >"$BUBBLES_PYTHON_SELFTEST_READY_FILE"
      exit 124
      ;;
    interrupt-hold)
      /usr/bin/mkfifo "$TMP_ROOT/interrupt-hold.fifo"
      exec 9<>"$TMP_ROOT/interrupt-hold.fifo"
      printf '%s\n' "$TMP_ROOT" >"$BUBBLES_PYTHON_SELFTEST_READY_FILE"
      builtin read -r -t 300 _selftest_hold <&9
      ;;
    *)
      echo "python-env selftest child mode is invalid" >&2
      exit 2
      ;;
  esac
fi

ok() {
  echo "PASS: $1"
  pass=$((pass + 1))
}
bad() {
  echo "FAIL: $1"
  fail=$((fail + 1))
}

runner_launch_registration_is_adjacent() {
  /usr/bin/awk '
    /\) >"\$BUBBLES_PYTHON_SECURITY_STDOUT_PATH".*&$/ { launch=NR; next }
    launch && NR == launch + 1 && /BUBBLES_PYTHON_SECURITY_ACTIVE_PID=\$!/ { pid=NR; next }
    pid && NR == pid + 1 && /BUBBLES_PYTHON_SECURITY_STATE='\''REGISTERED'\''/ { registered=NR }
    END { exit (launch && pid == launch + 1 && registered == pid + 1) ? 0 : 1 }
  ' "$1"
}

make_runner_mutation() {
  local mode="$1"
  local destination="$2"
  local private_prefix="${3:-}"
  local source_mode=""
  /usr/bin/awk -v mode="$mode" -v private_prefix="$private_prefix" '
    BEGIN {
      launch_mode = (mode == "launch-window" || mode == "launch-window-no-wait" || mode == "launch-readiness")
      scope2_completion_mode = (mode == "scope2-forged-control" || mode == "scope2-early-eof" || mode == "scope2-descriptor-descendant")
      sq = sprintf("%c", 39)
    }
    /local wall_seconds=30/ && mode == "timeout" { sub(/30/, "1") }
    /local wall_seconds=30/ && launch_mode { sub(/30/, "3") }
    /local wall_seconds=30/ && scope2_completion_mode {
      sub(/30/, "1")
      scope2_wall=scope2_wall + 1
    }
    /command_args=\(\/usr\/bin\/env -i LC_ALL=C "\$runtime" -I -S -B -c "\$runtime_program"\)/ {
      if (mode == "child73") { print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import sys; sys.exit(73)\")"; next }
      if (mode == "child143") { print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import sys; sys.exit(143)\")"; next }
      if (mode == "timeout") { print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import time; time.sleep(300)\")"; next }
      if (mode == "signal-hup") { print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import os, signal, time; os.kill(os.getppid(), signal.SIGHUP); time.sleep(300)\")"; next }
      if (mode == "signal-int") { print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import os, signal, time; os.kill(os.getppid(), signal.SIGINT); time.sleep(300)\")"; next }
      if (mode == "signal-term") { print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import os, signal, time; os.kill(os.getppid(), signal.SIGTERM); time.sleep(300)\")"; next }
      if (mode == "scope2-forged-control") {
        print "      # B039-SCOPE2-scope2-forged-control"
        print "      runtime_program=" sq "import os"
        print "import time"
        print "try:"
        print "    os.write(9, (\"COMPLETE\" + chr(9) + \"BPS1\" + chr(9) + \"runtime-probe\" + chr(10)).encode())"
        print "except OSError:"
        print "    pass"
        print "time.sleep(3)" sq
        print
        scope2_runtime=scope2_runtime + 1
        next
      }
      if (mode == "scope2-early-eof") {
        print "      # B039-SCOPE2-scope2-early-eof"
        print "      runtime_program=" sq "import os"
        print "import time"
        print "try:"
        print "    os.close(9)"
        print "except OSError:"
        print "    pass"
        print "time.sleep(3)" sq
        print
        scope2_runtime=scope2_runtime + 1
        next
      }
      if (mode == "scope2-descriptor-descendant") {
        print "      # B039-SCOPE2-scope2-descriptor-descendant"
        print "      runtime_program=" sq "import os"
        print "import time"
        print "child = os.fork()"
        print "if child == 0:"
        print "    time.sleep(2)"
        print "    os._exit(0)"
        print "os._exit(0)" sq
        print
        scope2_runtime=scope2_runtime + 1
        next
      }
      if (launch_mode) {
        print "      # B039-MUTATION-LAUNCH"
        print "      command_args=(/usr/bin/env -i LC_ALL=C \"$runtime\" -I -S -B -c \"import time; time.sleep(2)\")"
        launch_runtime=launch_runtime + 1
        next
      }
    }
    /printf '\''READY\\tBPY1\\t%s\\n'\''/ && mode == "control125" {
      sub(/READY/, "MALFORMED")
    }
    /\/usr\/bin\/mkfifo "\$BUBBLES_PYTHON_SECURITY_FIFO_PATH"/ && mode == "setup125" {
      sub(/\/usr\/bin\/mkfifo/, "/definitely/missing/mkfifo")
    }
    index($0, "/tmp/bubbles-python-security.*) /bin/rm -rf") && mode == "cleanup-omit-root" {
      gsub("/tmp/bubbles-python-security", private_prefix)
      sub(/\/bin\/rm -rf "\$private_root" \|\| cleanup_status=1/, ":")
      cleanup_omission=cleanup_omission + 1
      private_rewrites=private_rewrites + 1
      print
      next
    }
    private_prefix != "" && index($0, "/tmp/bubbles-python-security.") {
      gsub("/tmp/bubbles-python-security", private_prefix)
      private_rewrites=private_rewrites + 1
      print
      next
    }
    /_bubbles_python_security_stop_active_child\(\) \{/ { in_stop=1 }
    in_stop && launch_mode && /if builtin wait "\$BUBBLES_PYTHON_SECURITY_ACTIVE_PID" 2>\/dev\/null; then/ {
      print "    _bubbles_python_mutant_waited_pid=\"$BUBBLES_PYTHON_SECURITY_ACTIVE_PID\""
      if (mode == "launch-window-no-wait") {
        print "    # B039-MUTATION-WAIT-BYPASS"
        print "    if false; then"
        wait_bypass=wait_bypass + 1
      } else {
        print "    # B039-MUTATION-WAIT-INSTRUMENTATION"
        print "    if builtin wait \"$_bubbles_python_mutant_waited_pid\" 2>/dev/null; then"
        wait_instrumentation=wait_instrumentation + 1
      }
      in_wait_block=1
      next
    }
    in_stop && in_wait_block && /^[[:space:]]*fi$/ {
      print
      if (mode == "launch-window-no-wait") {
        print "    printf \"WAIT_BYPASSED|%s|%s\\n\" \"$_bubbles_python_mutant_waited_pid\" \"$child_status\" >>\"${BUBBLES_PYTHON_MUTANT_TRACE:?trace required}\""
      } else {
        print "    printf \"WAIT|%s|%s\\n\" \"$_bubbles_python_mutant_waited_pid\" \"$child_status\" >>\"${BUBBLES_PYTHON_MUTANT_TRACE:?trace required}\""
      }
      wait_block_end=wait_block_end + 1
      in_wait_block=0
      next
    }
    in_stop && /^[[:space:]]*BUBBLES_PYTHON_SECURITY_ACTIVE_PID=/ && launch_mode {
      print
      print "    printf \"PID_CLEARED\\n\" >>\"${BUBBLES_PYTHON_MUTANT_TRACE:?trace required}\""
      pid_clear=pid_clear + 1
      next
    }
    in_stop && /^}/ { in_stop=0 }
    /\) >"\$BUBBLES_PYTHON_SECURITY_STDOUT_PATH".*&$/ && launch_mode {
      print
      print "  # B039-MUTATION-REGISTRATION-WINDOW"
      print "  printf \"%s\\n\" \"$BUBBLES_PYTHON_SECURITY_PRIVATE_ROOT\" >\"${BUBBLES_PYTHON_MUTANT_ROOT_RECORD:?root record required}\""
      if (mode == "launch-readiness") {
        print "  printf \"%s\\n\" MALFORMED >\"${BUBBLES_PYTHON_MUTANT_WINDOW_READY:?window ready required}\""
      } else {
        print "  printf \"%s\\n\" READY >\"${BUBBLES_PYTHON_MUTANT_WINDOW_READY:?window ready required}\""
      }
      print "  builtin read -r -t 10 _bubbles_python_mutant_release <\"${BUBBLES_PYTHON_MUTANT_WINDOW_RELEASE:?window release required}\""
      launch_window=launch_window + 1
      next
    }
    /BUBBLES_PYTHON_SECURITY_ACTIVE_PID=\$!/ && launch_mode {
      print
      print "  # B039-MUTATION-PID-PUBLICATION"
      print "  printf \"PUBLISHED|%s\\n\" \"$BUBBLES_PYTHON_SECURITY_ACTIVE_PID\" >>\"${BUBBLES_PYTHON_MUTANT_TRACE:?trace required}\""
      launch_publication=launch_publication + 1
      next
    }
    /BUBBLES_PYTHON_SECURITY_STATE='\''REGISTERED'\''/ && launch_mode {
      print
      print "  # B039-MUTATION-REGISTRATION-TRACE"
      print "  printf \"REGISTERED|%s\\n\" \"$BUBBLES_PYTHON_SECURITY_PENDING_SIGNAL\" >>\"${BUBBLES_PYTHON_MUTANT_TRACE:?trace required}\""
      launch_registered=launch_registered + 1
      next
    }
    { print }
    END {
      if (launch_mode &&
        (launch_runtime != 1 || launch_window != 1 || launch_publication != 1 ||
          launch_registered != 1 || wait_block_end != 1 || pid_clear != 1 || private_rewrites != 2)) exit 42
      if (launch_mode && mode != "launch-window-no-wait" &&
        (wait_instrumentation != 1 || wait_bypass != 0)) exit 42
      if (mode == "launch-window-no-wait" &&
        (wait_instrumentation != 0 || wait_bypass != 1)) exit 42
      if (mode == "cleanup-omit-root" &&
        (cleanup_omission != 1 || private_rewrites != 2)) exit 42
      if (scope2_completion_mode &&
        (scope2_runtime != 1 || scope2_wall != 1)) exit 42
    }
  ' "$ENV_SH" >"$destination"
  if source_mode="$(/usr/bin/stat -f '%Lp' "$ENV_SH" 2>/dev/null)"; then
    :
  elif source_mode="$(/usr/bin/stat -c '%a' "$ENV_SH" 2>/dev/null)"; then
    :
  else
    return 42
  fi
  /bin/chmod "$source_mode" "$destination"
}

run_launch_window_negative_control() {
  local mode="${1:-launch-window}"
  local mutation_dir="$TMP_ROOT/neg-b039-$mode"
  local mutant="$mutation_dir/python-env.sh"
  local private_prefix="$mutation_dir/bubbles-python-security"
  local ready_fifo="$mutation_dir/window.ready.fifo"
  local release_fifo="$mutation_dir/window.release.fifo"
  local root_record="$mutation_dir/private-root.record"
  local trace_file="$mutation_dir/lifecycle.trace"
  local runner_output="$mutation_dir/runner.output"
  local runtime=""
  local runner_pid=""
  local ready_record=""
  local ready_status=0
  local runner_status=0
  local signal_status=0
  local recorded_root=""
  local published_pid=""
  local waited_pid=""
  local wait_status=""
  local bypassed_pid=""
  local published_count=0
  local waited_count=0
  local bypassed_count=0
  local cleared_count=0
  local registered_count=0
  local launch_count=0
  local publication_count=0
  local wait_construction_count=0
  local registration_window_count=0

  mkdir -p "$mutation_dir"
  /usr/bin/mkfifo "$ready_fifo" "$release_fifo"
  make_runner_mutation "$mode" "$mutant" "$private_prefix" || {
    printf 'NEG-B039-LAUNCH setup failed: copied %s mutation did not match exactly\n' "$mode" >&2
    return 2
  }
  launch_count="$(/usr/bin/grep -cF 'B039-MUTATION-LAUNCH' "$mutant" || true)"
  publication_count="$(/usr/bin/grep -cF 'B039-MUTATION-PID-PUBLICATION' "$mutant" || true)"
  registration_window_count="$(/usr/bin/grep -cF 'B039-MUTATION-REGISTRATION-WINDOW' "$mutant" || true)"
  if [[ "$mode" == launch-window-no-wait ]]; then
    wait_construction_count="$(/usr/bin/grep -cF 'B039-MUTATION-WAIT-BYPASS' "$mutant" || true)"
  else
    wait_construction_count="$(/usr/bin/grep -cF 'B039-MUTATION-WAIT-INSTRUMENTATION' "$mutant" || true)"
  fi
  printf 'MUTATION_COUNTS mode=%s launch=%s pid_publication=%s wait=%s registration_window=%s\n' \
    "$mode" "$launch_count" "$publication_count" "$wait_construction_count" "$registration_window_count"
  if [[ "$launch_count" -ne 1 || "$publication_count" -ne 1 ||
    "$wait_construction_count" -ne 1 || "$registration_window_count" -ne 1 ]]; then
    printf 'NEG-B039-LAUNCH setup failed: %s construction counts are not exact\n' "$mode" >&2
    return 2
  fi
  if DEVELOPER_DIR=/Library/Developer/CommandLineTools bubbles_python_resolve_security_runtime; then
    runtime="$BUBBLES_PYTHON_SECURITY_RUNTIME"
  else
    printf 'NEG-B039-LAUNCH setup failed: authenticated runtime status=%s diagnostic=%s\n' \
      "$BUBBLES_PYTHON_SECURITY_STATUS" "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" >&2
    return 2
  fi

  SELFTEST_MUTANT_PRIVATE_ROOT_RECORD="$root_record"
  exec 5<>"$ready_fifo"
  exec 6<>"$release_fifo"
  SELFTEST_WINDOW_RELEASE_OPEN=1
  env \
    BUBBLES_PYTHON_MUTANT_WINDOW_READY="$ready_fifo" \
    BUBBLES_PYTHON_MUTANT_WINDOW_RELEASE="$release_fifo" \
    BUBBLES_PYTHON_MUTANT_ROOT_RECORD="$root_record" \
    BUBBLES_PYTHON_MUTANT_TRACE="$trace_file" \
    "$BASH" -c '
      . "$1"
      BUBBLES_PYTHON_SECURITY_RUNTIME="$2"
      BUBBLES_PYTHON_SECURITY_STATUS=0
      BUBBLES_PYTHON_SECURITY_DIAGNOSTIC=OK
      BUBBLES_PYTHON_SECURITY_PROVENANCE=root-protected-path
      BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL=PYSEC1
      BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL=PYMOD1
      operation_status=0
      bubbles_python_run_security_operation runtime-probe || operation_status=$?
      printf "RESULT|%s|%s|%s\n" "$operation_status" \
        "$BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC" "$BUBBLES_PYTHON_SECURITY_RUN_TIMED_OUT"
      cleanup_status=0
      bubbles_python_security_cleanup || cleanup_status=$?
      if [[ "$operation_status" -eq 0 && "$cleanup_status" -ne 0 ]]; then
        exit "$cleanup_status"
      fi
      exit "$operation_status"
    ' _ "$mutant" "$runtime" >"$runner_output" 2>&1 &
  runner_pid=$!
  SELFTEST_ACTIVE_CHILD="$runner_pid"

  if builtin read -r -t 10 ready_record <&5; then
    ready_status=0
  else
    ready_status=$?
  fi
  exec 5>&-
  if [[ "$ready_status" -ne 0 ]]; then
    selftest_release_mutant_window
    if selftest_wait_runner_bounded "$runner_pid" 6 1; then runner_status=0; else runner_status=$?; fi
    /bin/cat "$runner_output"
    printf 'NEG-B039-LAUNCH setup failed: %s copied runner did not reach its window (read=%s wait=%s)\n' \
      "$mode" "$ready_status" "$runner_status" >&2
    return 2
  fi
  if [[ "$ready_record" != READY ]]; then
    selftest_release_mutant_window
    if selftest_wait_runner_bounded "$runner_pid" 6 1; then runner_status=0; else runner_status=$?; fi
    /bin/cat "$runner_output"
    recorded_root="$(/bin/cat "$root_record" 2>/dev/null || true)"
    if [[ "$mode" == launch-readiness && "$ready_record" == MALFORMED &&
      "$runner_status" -eq 0 && "$recorded_root" == "$private_prefix".* &&
      ! -e "$recorded_root" ]]; then
      SELFTEST_MUTANT_PRIVATE_ROOT_RECORD=''
      printf 'RED: NEG-B039-LAUNCH-READINESS abnormal_ready=%s runner_exit=%s private_root_absent=yes\n' \
        "$ready_record" "$runner_status"
      printf '%s\n' 'FAIL: NEG-B039-LAUNCH-READINESS: abnormal readiness terminates within the watchdog and leaves no private runner root' >&2
      return 1
    fi
    printf 'NEG-B039-LAUNCH setup failed: mode=%s ready=%s wait=%s root=%s\n' \
      "$mode" "$ready_record" "$runner_status" "${recorded_root:-missing}" >&2
    return 2
  fi

  if builtin kill -HUP "$runner_pid" 2>/dev/null; then
    signal_status=0
  else
    signal_status=$?
  fi
  selftest_release_mutant_window
  if selftest_wait_runner_bounded "$runner_pid" 6 1; then
    runner_status=0
  else
    runner_status=$?
  fi
  /bin/cat "$runner_output"
  recorded_root="$(/bin/cat "$root_record" 2>/dev/null || true)"

  if [[ -f "$trace_file" ]]; then
    while IFS='|' read -r trace_kind trace_value trace_status _trace_extra; do
      case "$trace_kind" in
        PUBLISHED)
          published_pid="$trace_value"
          published_count=$((published_count + 1))
          ;;
        WAIT)
          waited_pid="$trace_value"
          wait_status="$trace_status"
          waited_count=$((waited_count + 1))
          ;;
        WAIT_BYPASSED)
          bypassed_pid="$trace_value"
          bypassed_count=$((bypassed_count + 1))
          ;;
        PID_CLEARED)
          cleared_count=$((cleared_count + 1))
          ;;
        REGISTERED)
          [[ "$trace_value" == HUP ]] && registered_count=$((registered_count + 1))
          ;;
      esac
    done <"$trace_file"
  fi

  if [[ "$mode" == launch-window-no-wait && "$signal_status" -eq 0 &&
    "$runner_status" -eq 129 && "$published_pid" =~ ^[1-9][0-9]*$ &&
    "$bypassed_pid" == "$published_pid" && "$published_count" -eq 1 &&
    "$waited_count" -eq 0 && "$bypassed_count" -eq 1 && "$cleared_count" -eq 1 &&
    "$registered_count" -eq 1 && "$recorded_root" == "$private_prefix".* &&
    ! -e "$recorded_root" ]] &&
    /usr/bin/grep -Fq 'RESULT|129|SIGNAL_HUP|0' "$runner_output" &&
    ! runner_launch_registration_is_adjacent "$mutant"; then
    SELFTEST_MUTANT_PRIVATE_ROOT_RECORD=''
    printf 'RED: NEG-B039-EXACT-WAIT published_pid=%s wait_bypassed_pid=%s pid_clear=1 wait_records=0\n' \
      "$published_pid" "$bypassed_pid"
    printf '%s\n' 'FAIL: NEG-B039-EXACT-WAIT: copied wait bypass retains PID clear but cannot satisfy the exact-wait assertion' >&2
    return 1
  fi

  if [[ "$mode" == launch-window && "$signal_status" -eq 0 && "$runner_status" -eq 129 &&
    "$published_pid" =~ ^[1-9][0-9]*$ && "$waited_pid" == "$published_pid" &&
    "$wait_status" =~ ^(137|143)$ && "$published_count" -eq 1 && "$waited_count" -eq 1 &&
    "$bypassed_count" -eq 0 && "$cleared_count" -eq 1 && "$registered_count" -eq 1 &&
    "$recorded_root" == "$private_prefix".* && ! -e "$recorded_root" ]] &&
    /usr/bin/grep -Fq 'RESULT|129|SIGNAL_HUP|0' "$runner_output" &&
    ! runner_launch_registration_is_adjacent "$mutant"; then
    SELFTEST_MUTANT_PRIVATE_ROOT_RECORD=''
    printf 'CONTROL: NEG-B039-LAUNCH-WINDOW published_pid=%s waited_pid=%s actual_wait_status=%s private_root_absent=yes\n' \
      "$published_pid" "$waited_pid" "$wait_status"
    printf '%s\n' 'FAIL: NEG-B039-LAUNCH-WINDOW: synchronized command exists between child launch and active-PID publication' >&2
    return 1
  fi

  printf 'NEG-B039-LAUNCH control failed unexpectedly: mode=%s signal=%s wait=%s published=%s waited=%s waitStatus=%s bypassed=%s cleared=%s registered=%s root=%s\n' \
    "$mode" "$signal_status" "$runner_status" "${published_pid:-missing}" \
    "${waited_pid:-missing}" "${wait_status:-missing}" "${bypassed_pid:-missing}" \
    "$cleared_count" "$registered_count" "${recorded_root:-missing}" >&2
  return 2
}

run_cleanup_omission_negative_control() {
  local mutation_dir="$TMP_ROOT/neg-b039-cleanup-omission"
  local mutant="$mutation_dir/python-env.sh"
  local private_prefix="$mutation_dir/bubbles-python-security"
  local root_record="$mutation_dir/private-root.record"
  local runner_output="$mutation_dir/runner.output"
  local runtime=""
  local runner_status=0
  local recorded_root=""
  local leak_removed=0

  mkdir -p "$mutation_dir"
  make_runner_mutation cleanup-omit-root "$mutant" "$private_prefix" || {
    printf '%s\n' 'NEG-B039-CLEANUP-OMISSION setup failed: copied mutation did not match exactly' >&2
    return 2
  }
  if DEVELOPER_DIR=/Library/Developer/CommandLineTools bubbles_python_resolve_security_runtime; then
    runtime="$BUBBLES_PYTHON_SECURITY_RUNTIME"
  else
    printf 'NEG-B039-CLEANUP-OMISSION setup failed: authenticated runtime status=%s diagnostic=%s\n' \
      "$BUBBLES_PYTHON_SECURITY_STATUS" "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" >&2
    return 2
  fi

  SELFTEST_MUTANT_PRIVATE_ROOT_RECORD="$root_record"
  if env BUBBLES_PYTHON_MUTANT_ROOT_RECORD="$root_record" "$BASH" -c '
    . "$1"
    BUBBLES_PYTHON_SECURITY_RUNTIME="$2"
    BUBBLES_PYTHON_SECURITY_STATUS=0
    BUBBLES_PYTHON_SECURITY_DIAGNOSTIC=OK
    BUBBLES_PYTHON_SECURITY_PROVENANCE=root-protected-path
    BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL=PYSEC1
    BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL=PYMOD1
    operation_status=0
    bubbles_python_run_security_operation runtime-probe || operation_status=$?
    [[ "$operation_status" -eq 0 ]] || exit 2
    private_root="$BUBBLES_PYTHON_SECURITY_PRIVATE_ROOT"
    printf "%s\n" "$private_root" >"${BUBBLES_PYTHON_MUTANT_ROOT_RECORD:?root record required}"
    cleanup_status=0
    bubbles_python_security_cleanup || cleanup_status=$?
    if [[ "$cleanup_status" -eq 0 && -n "$private_root" && -e "$private_root" ]]; then
      printf "%s\n" "FAIL: NEG-B039-CLEANUP-OMISSION: private execution root remains after real mutated cleanup" >&2
      exit 1
    fi
    printf "NEG-B039-CLEANUP-OMISSION control failed unexpectedly: cleanup=%s root=%s\n" \
      "$cleanup_status" "$private_root" >&2
    exit 2
  ' _ "$mutant" "$runtime" >"$runner_output" 2>&1; then
    runner_status=0
  else
    runner_status=$?
  fi
  /bin/cat "$runner_output"
  recorded_root="$(/bin/cat "$root_record" 2>/dev/null || true)"
  if [[ "$runner_status" -eq 1 && "$recorded_root" == "$private_prefix".* &&
    -e "$recorded_root" ]] &&
    /usr/bin/grep -Fq 'FAIL: NEG-B039-CLEANUP-OMISSION: private execution root remains after real mutated cleanup' "$runner_output"; then
    /bin/rm -rf "$recorded_root"
    if [[ ! -e "$recorded_root" ]]; then
      leak_removed=1
    fi
  fi
  if [[ "$leak_removed" -eq 1 ]]; then
    SELFTEST_MUTANT_PRIVATE_ROOT_RECORD=''
    printf '%s\n' 'CONTROL: NEG-B039-CLEANUP-OMISSION leaked private root was observed and removed safely'
    return 1
  fi

  printf 'NEG-B039-CLEANUP-OMISSION control failed unexpectedly: wait=%s root=%s\n' \
    "$runner_status" "${recorded_root:-missing}" >&2
  return 2
}

assert_python_negative_control() {
  local control_id="$1"
  local mode="$2"
  local exact_assertion="$3"
  local output_file="$TMP_ROOT/$mode-negative-control.output"
  local control_status=0

  if bubbles_run_with_timeout 30 env \
    BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL="$mode" \
    "$BASH" "$SELFTEST_SCRIPT" >"$output_file" 2>&1 </dev/null; then
    control_status=0
  else
    control_status=$?
  fi
  /bin/cat "$output_file"
  if [[ "$control_status" -eq 1 ]] && /usr/bin/grep -Fq "$exact_assertion" "$output_file"; then
    printf 'RED: %s mutant_exit=%s exact_assertion=%s\n' "$control_id" "$control_status" "$exact_assertion"
    ok "$control_id copied mutation turns its canonical invariant RED"
  else
    bad "$control_id expected copied mutant exit 1 with '$exact_assertion', got exit $control_status"
  fi
}

if [[ -n "${BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL:-}" ]]; then
  negative_control_status=0
  case "$BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL" in
    launch-window)
      if run_launch_window_negative_control launch-window; then negative_control_status=0; else negative_control_status=$?; fi
      ;;
    exact-wait-bypass)
      if run_launch_window_negative_control launch-window-no-wait; then negative_control_status=0; else negative_control_status=$?; fi
      ;;
    launch-readiness)
      if run_launch_window_negative_control launch-readiness; then negative_control_status=0; else negative_control_status=$?; fi
      ;;
    cleanup-omission)
      if run_cleanup_omission_negative_control; then negative_control_status=0; else negative_control_status=$?; fi
      ;;
    *)
      printf 'python-env selftest negative control is invalid: %s\n' \
        "$BUBBLES_PYTHON_SELFTEST_NEGATIVE_CONTROL" >&2
      negative_control_status=2
      ;;
  esac
  exit "$negative_control_status"
fi

echo "Scenario: BUG-039 copied lifecycle and cleanup mutations must turn RED."
assert_python_negative_control \
  NEG-B039-LAUNCH-WINDOW \
  launch-window \
  'FAIL: NEG-B039-LAUNCH-WINDOW: synchronized command exists between child launch and active-PID publication'
assert_python_negative_control \
  NEG-B039-EXACT-WAIT \
  exact-wait-bypass \
  'FAIL: NEG-B039-EXACT-WAIT: copied wait bypass retains PID clear but cannot satisfy the exact-wait assertion'
assert_python_negative_control \
  NEG-B039-LAUNCH-READINESS \
  launch-readiness \
  'FAIL: NEG-B039-LAUNCH-READINESS: abnormal readiness terminates within the watchdog and leaves no private runner root'
assert_python_negative_control \
  NEG-B039-CLEANUP-OMISSION \
  cleanup-omission \
  'FAIL: NEG-B039-CLEANUP-OMISSION: private execution root remains after real mutated cleanup'

assert_selftest_lifecycle_fails_closed() {
  local mode="$1"
  local signal_name="$2"
  local expected_status="$3"
  local label="$4"
  local ready_fifo="$TMP_ROOT/lifecycle-$mode-$signal_name.ready.fifo"
  local output_file="$TMP_ROOT/lifecycle-$mode-$signal_name.log"
  local child_pid=""
  local child_tmp=""
  local child_status=0
  local read_status=0

  /usr/bin/mkfifo "$ready_fifo"
  BUBBLES_PYTHON_SELFTEST_CHILD_MODE="$mode" \
    BUBBLES_PYTHON_SELFTEST_READY_FILE="$ready_fifo" \
    /bin/bash "$SELFTEST_SCRIPT" >"$output_file" 2>&1 </dev/null &
  child_pid=$!
  SELFTEST_LIFECYCLE_PID="$child_pid"
  exec 6<"$ready_fifo"
  if builtin read -r -t 10 child_tmp <&6; then
    read_status=0
  else
    read_status=$?
  fi
  exec 6>&-
  if [[ "$read_status" -ne 0 || -z "$child_tmp" ]]; then
    selftest_stop_exact_child
    bad "$label reaches its bounded ready point"
    return
  fi

  if [[ ! "$SELFTEST_LIFECYCLE_PID" =~ ^[1-9][0-9]*$ ||
    "$SELFTEST_LIFECYCLE_PID" != "$child_pid" ]]; then
    bad "$label exact direct-child registration is invalid before builtin wait"
    SELFTEST_LIFECYCLE_PID="$child_pid"
    selftest_stop_exact_child
    return
  fi
  if [[ "$signal_name" != "NONE" ]]; then
    builtin kill -"$signal_name" "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
  fi
  if builtin wait "$SELFTEST_LIFECYCLE_PID" 2>/dev/null; then child_status=0; else child_status=$?; fi
  SELFTEST_LIFECYCLE_PID=''
  if [[ "$child_status" -eq "$expected_status" ]]; then
    ok "$label preserves fatal exit $expected_status"
  else
    bad "$label expected exit $expected_status, got wait=$child_status"
  fi
  if [[ -n "$child_tmp" && ! -e "$child_tmp" ]]; then
    ok "$label removes its temporary tree"
  else
    bad "$label removes its temporary tree (still present: $child_tmp)"
    [[ -z "$child_tmp" ]] || rm -rf "$child_tmp"
  fi
  if /usr/bin/grep -Fq 'python-env selftest:' "$output_file"; then
    bad "$label must not emit a success summary"
  else
    ok "$label emits no success summary"
  fi
}

echo "Scenario: premature and interrupted python-env selftests fail closed while cleaning up."
assert_selftest_lifecycle_fails_closed premature-exit NONE 1 "Premature EXIT"
assert_selftest_lifecycle_fails_closed timeout-exit NONE 124 "Timeout exit"
assert_selftest_lifecycle_fails_closed interrupt-hold HUP 129 "HUP interruption"
assert_selftest_lifecycle_fails_closed interrupt-hold TERM 143 "TERM interruption"

assert_exit() {
  local expected="$1" label="$2"
  shift 2
  local actual=0
  "$@" >/dev/null 2>&1 || actual=$?
  if [[ "$actual" -eq "$expected" ]]; then
    ok "$label (exit $actual)"
  else
    bad "$label (expected exit $expected, got $actual)"
  fi
}

# make_fake_python <path> <module>... — a shim that imports ONLY the named modules.
# NOTE: fixture subdirectories are deliberately named "venvroot", never "home" —
# a literal Linux home-directory path in a portable surface trips the agnosticity lint.
make_fake_python() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  {
    echo '#!/usr/bin/env bash'
    echo '# fake python3 shim for python-env-selftest'
    echo 'if [[ "${1:-}" == "-c" ]]; then'
    echo '  case "${2:-}" in'
    local module
    for module in "$@"; do
      echo "    *\"import $module\"*) exit 0 ;;"
    done
    echo '    *) exit 1 ;;'
    echo '  esac'
    echo 'fi'
    echo 'exit 1'
  } >"$path"
  chmod +x "$path"
}

# ── Case 1: no managed venv, PATH python3 lacks the modules → unsatisfied ──
c1="$TMP_ROOT/c1"
mkdir -p "$c1/venvroot" "$c1/bin"
make_fake_python "$c1/bin/python3" nothingatall
assert_exit 1 "Case 1: nothing satisfies is exit 1" \
  env BUBBLES_PYTHON_HOME="$c1/venvroot" PATH="$c1/bin:/usr/bin:/bin" bash "$ENV_SH" --check

# ── Case 2: a managed venv that satisfies resolves ─────────────────────────
c2="$TMP_ROOT/c2"
mkdir -p "$c2/venvroot/bin" "$c2/bin"
make_fake_python "$c2/venvroot/bin/python3" yaml jsonschema
make_fake_python "$c2/bin/python3" nothingatall
assert_exit 0 "Case 2: satisfying managed venv is exit 0" \
  env BUBBLES_PYTHON_HOME="$c2/venvroot" PATH="$c2/bin:/usr/bin:/bin" bash "$ENV_SH" --check

resolved="$(env BUBBLES_PYTHON_HOME="$c2/venvroot" PATH="$c2/bin:/usr/bin:/bin" bash "$ENV_SH" --path 2>/dev/null || true)"
if [[ "$resolved" == "$c2/venvroot/bin/python3" ]]; then
  ok "Case 2b: --path prints the managed interpreter"
else
  bad "Case 2b: --path printed '$resolved', expected '$c2/venvroot/bin/python3'"
fi

# ── Case 3: PATH python3 that satisfies is accepted when no venv exists ────
c3="$TMP_ROOT/c3"
mkdir -p "$c3/venvroot" "$c3/bin"
make_fake_python "$c3/bin/python3" yaml jsonschema
assert_exit 0 "Case 3: satisfying PATH python3 is accepted" \
  env BUBBLES_PYTHON_HOME="$c3/venvroot" PATH="$c3/bin:/usr/bin:/bin" bash "$ENV_SH" --check

# ── Case 4: $BUBBLES_PYTHON override wins ─────────────────────────────────
c4="$TMP_ROOT/c4"
mkdir -p "$c4/venvroot/bin" "$c4/bin" "$c4/override"
make_fake_python "$c4/venvroot/bin/python3" yaml jsonschema
make_fake_python "$c4/bin/python3" nothingatall
make_fake_python "$c4/override/python3" yaml jsonschema
resolved="$(env BUBBLES_PYTHON_HOME="$c4/venvroot" BUBBLES_PYTHON="$c4/override/python3" \
  PATH="$c4/bin:/usr/bin:/bin" bash "$ENV_SH" --path 2>/dev/null || true)"
if [[ "$resolved" == "$c4/override/python3" ]]; then
  ok "Case 4: BUBBLES_PYTHON override takes precedence"
else
  bad "Case 4: --path printed '$resolved', expected the override"
fi

# ── Case 5: a NON-satisfying override is ignored, not trusted ─────────────
c5="$TMP_ROOT/c5"
mkdir -p "$c5/venvroot/bin" "$c5/bin" "$c5/override"
make_fake_python "$c5/venvroot/bin/python3" yaml jsonschema
make_fake_python "$c5/bin/python3" nothingatall
make_fake_python "$c5/override/python3" yaml
resolved="$(env BUBBLES_PYTHON_HOME="$c5/venvroot" BUBBLES_PYTHON="$c5/override/python3" \
  PATH="$c5/bin:/usr/bin:/bin" bash "$ENV_SH" --path 2>/dev/null || true)"
if [[ "$resolved" == "$c5/venvroot/bin/python3" ]]; then
  ok "Case 5: unsatisfying override falls through to the managed venv"
else
  bad "Case 5: --path printed '$resolved', expected the managed venv"
fi

# ── Case 6: usage errors ──────────────────────────────────────────────────
assert_exit 2 "Case 6: unknown mode is a usage error" bash "$ENV_SH" --bogus
assert_exit 2 "Case 6b: extra argument is a usage error" bash "$ENV_SH" --check extra
assert_exit 0 "Case 6c: --help exits 0" bash "$ENV_SH" --help

# ── Case 7: no bypass flag exists ─────────────────────────────────────────
for flag in --skip --force --ignore; do
  assert_exit 2 "Case 7: $flag is rejected (no bypass)" bash "$ENV_SH" "$flag"
done

# ── Case 8: provisioning refuses a missing requirements file ──────────────
assert_exit 2 "Case 8: missing requirements file is exit 2" \
  env BUBBLES_PYTHON_HOME="$TMP_ROOT/c8home" bash -c \
  '. "$1"; bubbles_python_provision "$2"' _ "$ENV_SH" "$TMP_ROOT/definitely-absent.txt"

# ── ADVERSARIAL A1: partial module satisfaction must NOT count ─────────────
a1="$TMP_ROOT/a1"
mkdir -p "$a1/venvroot/bin" "$a1/bin"
make_fake_python "$a1/venvroot/bin/python3" yaml
make_fake_python "$a1/bin/python3" nothingatall
assert_exit 1 "A1: interpreter with only ONE required module is unsatisfied" \
  env BUBBLES_PYTHON_HOME="$a1/venvroot" PATH="$a1/bin:/usr/bin:/bin" bash "$ENV_SH" --check

# ── ADVERSARIAL A2: activate must not hijack a satisfying PATH python3 ─────
a2="$TMP_ROOT/a2"
mkdir -p "$a2/venvroot/bin" "$a2/bin"
make_fake_python "$a2/venvroot/bin/python3" yaml jsonschema
make_fake_python "$a2/bin/python3" yaml jsonschema
a2_path="$(env BUBBLES_PYTHON_HOME="$a2/venvroot" PATH="$a2/bin:/usr/bin:/bin" bash -c \
  '. "$1"; bubbles_python_activate >/dev/null 2>&1; printf "%s" "$PATH"' _ "$ENV_SH")"
case "$a2_path" in
  "$a2/venvroot/bin":*) bad "A2: activate hijacked a PATH python3 that already satisfies" ;;
  *) ok "A2: activate leaves a satisfying PATH python3 alone" ;;
esac

# ── A2b: activate DOES prepend when PATH python3 does not satisfy ──────────
a2b_path="$(env BUBBLES_PYTHON_HOME="$a1/venvroot" PATH="$a1/bin:/usr/bin:/bin" bash -c \
  '. "$1"; bubbles_python_activate >/dev/null 2>&1; printf "%s" "$PATH"' _ "$ENV_SH")"
case "$a2b_path" in
  *"$a1/venvroot/bin"*) bad "A2b: activate prepended an UNSATISFYING managed venv" ;;
  *) ok "A2b: activate does not prepend an unsatisfying managed venv" ;;
esac

a2c="$TMP_ROOT/a2c"
mkdir -p "$a2c/venvroot/bin" "$a2c/bin"
make_fake_python "$a2c/venvroot/bin/python3" yaml jsonschema
make_fake_python "$a2c/bin/python3" nothingatall
a2c_path="$(env BUBBLES_PYTHON_HOME="$a2c/venvroot" PATH="$a2c/bin:/usr/bin:/bin" bash -c \
  '. "$1"; bubbles_python_activate >/dev/null 2>&1; printf "%s" "$PATH"' _ "$ENV_SH")"
case "$a2c_path" in
  "$a2c/venvroot/bin":*) ok "A2c: activate prepends the managed venv when PATH does not satisfy" ;;
  *) bad "A2c: activate failed to prepend; PATH=$a2c_path" ;;
esac

# ── ADVERSARIAL A3: module list must match dependency-posture.sh ───────────
if [[ -f "$POSTURE_SH" ]]; then
  declared="$(grep -oE '"python-module:[a-zA-Z0-9_]+:' "$POSTURE_SH" |
    sed 's/"python-module://; s/:$//' | LC_ALL=C sort | tr '\n' ' ')"
  owned="$(bash -c '. "$1"; printf "%s\n" "${BUBBLES_PYTHON_MODULES[@]}"' _ "$ENV_SH" |
    LC_ALL=C sort | tr '\n' ' ')"
  if [[ -n "$declared" && "$declared" == "$owned" ]]; then
    ok "A3: BUBBLES_PYTHON_MODULES matches dependency-posture.sh ($owned)"
  else
    bad "A3: module lists drifted — posture='$declared' python-env='$owned'"
  fi
else
  bad "A3: dependency-posture.sh not found at $POSTURE_SH"
fi

# ── Case 9: requirements.txt is pinned and single-index ───────────────────
# Directives only: a comment that NAMES --extra-index-url (the file documents
# why it has none) must not be mistaken for one being declared.
REQ="$SCRIPT_DIR/../requirements.txt"
if [[ -f "$REQ" ]]; then
  directives="$(grep -vE '^[[:space:]]*#' "$REQ" || true)"
  if [[ "$(printf '%s\n' "$directives" | grep -c -- '--extra-index-url' || true)" -eq 0 ]]; then
    ok "Case 9: requirements.txt declares no --extra-index-url"
  else
    bad "Case 9: requirements.txt declares an --extra-index-url"
  fi
  if [[ "$(printf '%s\n' "$directives" | grep -c -- '--index-url' || true)" -eq 1 ]]; then
    ok "Case 9b: requirements.txt pins exactly one index"
  else
    bad "Case 9b: requirements.txt must declare exactly one --index-url"
  fi
  unpinned="$(grep -vE '^[[:space:]]*(#|$|--)' "$REQ" | grep -vE '==' | tr -d ' ' || true)"
  if [[ -z "$unpinned" ]]; then
    ok "Case 9c: every requirement is == pinned"
  else
    bad "Case 9c: unpinned requirement(s): $unpinned"
  fi
else
  bad "Case 9: requirements.txt not found at $REQ"
fi

# ---------------------------------------------------------------------------
# Case 10 (adversarial A4): cli.sh MUST activate the managed interpreter early.
#
# This is the seam that covers the ~15 selftests which call `python3 -c "import
# yaml"` directly without sourcing dependency-posture.sh. If someone deletes it,
# those selftests silently regress to SKIP/empty-value failures instead of
# failing loudly here. Guard it structurally.
# ---------------------------------------------------------------------------
CLI="$SCRIPT_DIR/cli.sh"
if [[ -f "$CLI" ]]; then
  if grep -q 'bubbles_python_activate' "$CLI"; then
    ok "Case 10: cli.sh activates the managed interpreter"
  else
    bad "Case 10: cli.sh no longer calls bubbles_python_activate — every child selftest loses the managed interpreter"
  fi

  # It must activate BEFORE the command dispatch, otherwise children spawned by
  # earlier subcommand handling would miss the exported PATH.
  # NOTE: `|| true` is required — this script runs under `set -euo pipefail`, so
  # a non-matching grep inside a pipeline would abort the whole selftest.
  activate_line="$(grep -n 'bubbles_python_activate' "$CLI" | head -1 | cut -d: -f1 || true)"
  dispatch_line="$(grep -nE '^[[:space:]]*case "\$(command_name|first_word|COMMAND|1|\{1:-\})' "$CLI" | head -1 | cut -d: -f1 || true)"
  if [[ -n "$activate_line" && -n "$dispatch_line" ]]; then
    if [[ "$activate_line" -lt "$dispatch_line" ]]; then
      ok "Case 10b: activation (line $activate_line) precedes command dispatch (line $dispatch_line)"
    else
      bad "Case 10b: activation at line $activate_line runs AFTER dispatch at line $dispatch_line"
    fi
  else
    ok "Case 10b: dispatch marker not matched; Case 10 already guards presence"
  fi
else
  bad "Case 10: cli.sh not found at $CLI"
fi

# ---------------------------------------------------------------------------
# Case 11 (adversarial A5): the pinned closure must cover every required module.
# A requirements.txt that installs PyYAML but forgets jsonschema would provision
# "successfully" and then fail at first use.
# ---------------------------------------------------------------------------
if [[ -f "$REQ" ]]; then
  missing_mod=""
  for _m in "${BUBBLES_PYTHON_MODULES[@]}"; do
    case "$_m" in
      yaml) _pkg='PyYAML' ;;
      jsonschema) _pkg='jsonschema' ;;
      *) _pkg="$_m" ;;
    esac
    grep -qiE "^[[:space:]]*${_pkg}==" "$REQ" || missing_mod="$missing_mod $_m"
  done
  if [[ -z "$missing_mod" ]]; then
    ok "Case 11: requirements.txt pins a distribution for every required module"
  else
    bad "Case 11: no pinned distribution for required module(s):$missing_mod"
  fi
fi

# ---------------------------------------------------------------------------
# BUG-039 additions (Cases 12-15). python-env.sh is the module the framework
# designates to answer "which interpreter", and this packet added new API to it:
# bubbles_python_runs, bubbles_python_resolve_runnable, and a locator contract
# that can now DECLINE instead of always printing.
#
# These exist because of what the file did NOT cover. Every case above passed
# throughout, while the module published /bin/python3 — a path that does not
# exist — as a resolved interpreter whenever no locator was set:
# "${XDG_CACHE_HOME:-$HOME/.cache}" aborted inside a command substitution under
# set -u, the empty result was concatenated with "/bin/python3", and the caller
# then reported "no interpreter satisfies the required modules" — a sentence
# about interpreters, when nothing had been able to name one.
#
# ADVERSARIAL A6 is that exact defect: it goes red against the historical
# unguarded expansion and green against the guarded one.
# ---------------------------------------------------------------------------

# no_locator <command...> — run with every locator variable REMOVED (not
# emptied): this is the state in which the module used to fabricate a path.
no_locator() {
  env -u BUBBLES_PYTHON_HOME -u XDG_CACHE_HOME -u HOME "$@"
}

# Pinned here as a LITERAL rather than read back from python-env.sh. Sourcing
# the module for its own expected value would make the assertion agree with
# whatever the module currently says, which is the opposite of pinning it.
LOCATOR_VARS_EXPECTED='BUBBLES_PYTHON_HOME, XDG_CACHE_HOME, or HOME'

# make_probe_python <path> <mode> — a shim for the EXECUTION probe, which is a
# different question from make_fake_python's module imports. Modes mirror the
# ways a real interpreter can be present and still unusable.
make_probe_python() {
  local path="$1" mode="$2"
  mkdir -p "$(dirname "$path")"
  {
    echo '#!/bin/bash'
    echo '# probe shim for python-env-selftest'
    case "$mode" in
      healthy) echo "printf %s 'bubbles-python-runs'" ;;
      # exits 0 and emits nothing: the wrapper an exit-code-only check accepts.
      silent) echo 'exit 0' ;;
      # emits the payload but on a polluted stdout.
      noisy)
        echo "echo 'warning: deprecated interpreter'"
        echo "printf %s 'bubbles-python-runs'"
        ;;
      # the macOS Xcode-licence shape: resolves, is executable, exits 69.
      dead)
        echo "printf %s 'bubbles-python-runs'"
        echo 'exit 69'
        ;;
      xcode)
        echo "echo 'You have not agreed to the Xcode license agreements.' >&2"
        echo 'exit 69'
        ;;
      hang) echo 'exec /bin/sleep 300' ;;
      malformed) echo "printf %s 'not-the-probe-protocol'" ;;
    esac
  } >"$path"
  chmod +x "$path"
}

# ── SCN-B039-005 RED: caller-owned executables cannot grant security authority ──
# This case intentionally calls the production security resolver. The fake can
# forge every public protocol token used by the historical implementation, but
# a root-protected resolver must neither execute it nor publish it as authority.
scope2_forged_root="$TMP_ROOT/scope2-forged-runtime"
scope2_forged_python="$scope2_forged_root/bin/python3"
scope2_forged_marker="$scope2_forged_root/executed.marker"
mkdir -p "$(dirname "$scope2_forged_python")"
cat >"$scope2_forged_python" <<'EOF'
#!/bin/bash
printf '%s\n' 'caller-owned runtime executed' >"${BUBBLES_SCOPE2_FORGED_MARKER:?marker required}"
printf '%s' 'bubbles-python-runs'
printf '\nRUNTIME\tPYSEC1\t3\t9\n'
printf 'COMPLETE\tPYMOD1\t9\n'
printf 'COMPLETE\tSCS1\t1\n'
exit 0
EOF
chmod +x "$scope2_forged_python"

scope2_resolution="$(env \
  PATH="$(dirname "$scope2_forged_python"):/usr/bin:/bin:/usr/sbin:/sbin" \
  BUBBLES_PYTHON="$scope2_forged_python" \
  BUBBLES_PYTHON_HOME="$scope2_forged_root" \
  BUBBLES_SCOPE2_FORGED_MARKER="$scope2_forged_marker" \
  DEVELOPER_DIR=/Library/Developer/CommandLineTools \
  /bin/bash -c '
    . "$1"
    if ! declare -F bubbles_python_resolve_security_runtime >/dev/null 2>&1; then
      printf "API_MISSING"
    elif bubbles_python_resolve_security_runtime >/dev/null; then
      printf "RESOLVED|%s|%s|%s" \
        "$BUBBLES_PYTHON_SECURITY_STATUS" \
        "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" \
        "$BUBBLES_PYTHON_SECURITY_TRUST_CONTRACT"
    else
      printf "DECLINED|%s|%s|%s" \
        "$BUBBLES_PYTHON_SECURITY_STATUS" \
        "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" \
        "$BUBBLES_PYTHON_SECURITY_TRUST_CONTRACT"
    fi
  ' _ "$ENV_SH" 2>/dev/null || true)"
case "$scope2_resolution" in
  RESOLVED\|0\|OK\|root-protected-native-python-v1 | \
    DECLINED\|*\|*\|root-protected-native-python-v1)
    ok "SCN-B039-005: security resolution publishes only the root-protected trust contract"
    ;;
  *)
    bad "SCN-B039-005: security resolver contract result was '$scope2_resolution'"
    ;;
esac
if [[ ! -e "$scope2_forged_marker" ]]; then
  ok "SCN-B039-005: caller-owned override, managed, and PATH runtime is never executed"
else
  bad "SCN-B039-005: caller-owned runtime executed during security resolution"
fi
if ! declare -F bubbles_python_run_bounded >/dev/null 2>&1 &&
  ! declare -F bubbles_python_resolve_trusted_runnable >/dev/null 2>&1; then
  ok "SCN-B039-005: superseded generic runner and managed trust API are absent"
else
  bad "SCN-B039-005: superseded generic runner or managed trust API remains exposed"
fi

# ── Case 12: the locator order is ordered, not incidental ─────────────────
c12="$TMP_ROOT/c12"
mkdir -p "$c12/explicit" "$c12/xdg" "$c12/venvroot"

c12a="$(env BUBBLES_PYTHON_HOME="$c12/explicit" XDG_CACHE_HOME="$c12/xdg" HOME="$c12/venvroot" \
  bash -c '. "$1"; bubbles_python_home' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c12a" == "$c12/explicit" ]]; then
  ok "Case 12: BUBBLES_PYTHON_HOME outranks XDG_CACHE_HOME and HOME"
else
  bad "Case 12: locator printed '$c12a', expected '$c12/explicit'"
fi

c12b="$(env -u BUBBLES_PYTHON_HOME XDG_CACHE_HOME="$c12/xdg/" HOME="$c12/venvroot" \
  bash -c '. "$1"; bubbles_python_home' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c12b" == "$c12/xdg/bubbles/python" ]]; then
  ok "Case 12b: XDG_CACHE_HOME outranks HOME, with the trailing slash normalized"
else
  bad "Case 12b: locator printed '$c12b', expected '$c12/xdg/bubbles/python'"
fi

c12c="$(env -u BUBBLES_PYTHON_HOME -u XDG_CACHE_HOME HOME="$c12/venvroot" \
  bash -c '. "$1"; bubbles_python_home' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c12c" == "$c12/venvroot/.cache/bubbles/python" ]]; then
  ok "Case 12c: HOME is the last locator, under .cache"
else
  bad "Case 12c: locator printed '$c12c', expected '$c12/venvroot/.cache/bubbles/python'"
fi

# ── ADVERSARIAL A6: an absent locator is a CONDITION, never a fabricated path ──
# This is the original defect. Under the historical unguarded expansion
# bubbles_python_home returned 0 with empty output and bubbles_python_venv_python
# then published "/bin/python3". Both halves are asserted: a resolver that
# reports success while printing nothing is just as wrong as one that prints a
# path it invented.
a6_home="$(no_locator bash -c '. "$1"; out="$(bubbles_python_home)" || { printf "DECLINED|%s" "$out"; exit 0; }; printf "RESOLVED|%s" "$out"' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$a6_home" == "DECLINED|" ]]; then
  ok "A6: bubbles_python_home declines when no locator is set"
else
  bad "A6: bubbles_python_home returned '$a6_home', expected 'DECLINED|' (a fabricated or empty-but-successful home is the BUG-039 defect)"
fi

a6_venv="$(no_locator bash -c '. "$1"; out="$(bubbles_python_venv_python)" || { printf "DECLINED|%s" "$out"; exit 0; }; printf "RESOLVED|%s" "$out"' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$a6_venv" == "DECLINED|" ]]; then
  ok "A6b: bubbles_python_venv_python declines instead of publishing a path"
else
  bad "A6b: bubbles_python_venv_python returned '$a6_venv', expected 'DECLINED|' — publishing a nonexistent interpreter path (historically '/bin/python3') is the BUG-039 defect"
fi

# ── ADVERSARIAL A7: usability is proven by PAYLOAD, not by exit code ──────
a7="$TMP_ROOT/a7"
make_probe_python "$a7/healthy/python3" healthy
make_probe_python "$a7/silent/python3" silent
make_probe_python "$a7/noisy/python3" noisy
make_probe_python "$a7/dead/python3" dead

# probe_runs <interpreter> — echo yes/no for bubbles_python_runs.
probe_runs() {
  no_locator bash -c '. "$1"; . "$2"; if bubbles_python_runs "$3"; then echo yes; else echo no; fi' \
    _ "$GUARD_LIB" "$ENV_SH" "$1" 2>/dev/null || echo no
}

assert_runs() {
  local mode="$1" want="$2" why="$3" got
  got="$(probe_runs "$a7/$mode/python3")"
  if [[ "$got" == "$want" ]]; then
    ok "A7 ($mode): $why"
  else
    bad "A7 ($mode): bubbles_python_runs said '$got', expected '$want' — $why"
  fi
}

assert_runs healthy yes "an interpreter that executes and returns the payload is usable"
assert_runs silent no "an interpreter that exits 0 while producing NOTHING is not usable"
assert_runs noisy no "an interpreter that pollutes stdout cannot pass the payload check"
assert_runs dead no "an interpreter that emits the payload and then exits 69 is not usable"

# ── ADVERSARIAL A7b: isolation utilities resolve only from the closed path ──
# Each hostile wrapper preserves the real utility's behavior after recording a
# marker. Without the function-local closed PATH in bubbles_python_runs, this
# test stays behaviorally green but the marker proves the trust boundary ran an
# ambient executable. That makes the assertion non-vacuous without racing a
# timeout or depending on the host's Python installation.
a7b="$TMP_ROOT/a7b"
a7b_bin="$a7b/bin"
a7b_marker="$a7b/ambient-utility-executed"
mkdir -p "$a7b_bin"
make_hostile_passthrough() {
  local tool="$1"
  local real_tool=""
  real_tool="$(PATH=/usr/bin:/bin:/usr/sbin:/sbin command -v "$tool" 2>/dev/null || true)"
  if [[ -z "$real_tool" ]]; then
    bad "A7b fixture requires $tool in the closed system path"
    return
  fi
  cat >"$a7b_bin/$tool" <<EOF
#!/bin/bash
printf '%s\n' '$tool' >>"\${BUBBLES_PYTHON_HOSTILE_MARKER:?marker required}"
exec '$real_tool' "\$@"
EOF
  chmod +x "$a7b_bin/$tool"
}
for isolation_tool in mktemp sleep wc grep cat rm; do
  make_hostile_passthrough "$isolation_tool"
done
for isolation_tool in timeout gtimeout; do
  cat >"$a7b_bin/$isolation_tool" <<'EOF'
#!/bin/bash
printf '%s\n' 'timeout-runner' >>"${BUBBLES_PYTHON_HOSTILE_MARKER:?marker required}"
printf '%s' 'bubbles-python-runs'
exit 0
EOF
  chmod +x "$a7b_bin/$isolation_tool"
done
a7b_result="$(PATH="$a7b_bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  BUBBLES_PYTHON_HOSTILE_MARKER="$a7b_marker" /bin/bash -c \
  '. "$1"; . "$2"; if bubbles_python_runs "$3"; then printf "RUNS|%s|%s" "$BUBBLES_PYTHON_RUN_STATUS" "$BUBBLES_PYTHON_RUN_DIAGNOSTIC"; else printf "DECLINED|%s|%s" "$BUBBLES_PYTHON_RUN_STATUS" "$BUBBLES_PYTHON_RUN_DIAGNOSTIC"; fi' \
  _ "$GUARD_LIB" "$ENV_SH" "$a7/healthy/python3" 2>/dev/null || true)"
if [[ "$a7b_result" == "RUNS|0|OK" ]]; then
  ok "A7b: closed-path probe still accepts the real healthy interpreter"
else
  bad "A7b: closed-path probe returned '$a7b_result'"
fi
if [[ ! -e "$a7b_marker" ]]; then
  ok "A7b: interpreter isolation executes no ambient PATH utility"
else
  bad "A7b: interpreter isolation executed ambient utility: $(tr '\n' ' ' <"$a7b_marker")"
fi

a7b_mutant_result="$(PATH="$a7b_bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  BUBBLES_PYTHON_ISOLATION_PATH="$a7b_bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  BUBBLES_PYTHON_HOSTILE_MARKER="$a7b_marker" /bin/bash -c \
  '/bin/rm -f "$4"; . "$1"; . "$2"; if bubbles_python_runs "$3"; then result=RUNS; else result=DECLINED; fi; if [[ -e "$4" ]]; then marker=PRESENT; else marker=ABSENT; fi; printf "%s|%s|%s|%s" "$result" "$BUBBLES_PYTHON_RUN_STATUS" "$BUBBLES_PYTHON_RUN_DIAGNOSTIC" "$marker"' \
  _ "$GUARD_LIB" "$ENV_SH" "$a7/healthy/python3" "$a7b_marker" 2>/dev/null || true)"
if [[ "$a7b_mutant_result" == "RUNS|0|OK|ABSENT" ]]; then
  ok "A7b negative control: a legacy isolation-path override cannot inject a trusted helper"
else
  bad "A7b negative control: legacy isolation-path override reached a trusted helper ('$a7b_mutant_result')"
fi

# ── SCN-B039-005: authenticated native runtime and hostile environment ─────
echo "Scenario: SCN-B039-005 resolves an authenticated native runtime independently of caller Python state."
security_status=0
if DEVELOPER_DIR=/Library/Developer/CommandLineTools bubbles_python_resolve_security_runtime; then
  security_status=0
else
  security_status=$?
fi
if [[ "$security_status" -eq 0 && "$BUBBLES_PYTHON_SECURITY_STATUS" -eq 0 &&
  "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" == OK &&
  "$BUBBLES_PYTHON_SECURITY_TRUST_CONTRACT" == root-protected-native-python-v1 &&
  "$BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL" == PYSEC1 &&
  "$BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL" == PYMOD1 ]]; then
  ok "SCN-B039-005: validated CLT/xcrun path authenticates PYSEC1 and PYMOD1"
else
  bad "SCN-B039-005: authenticated positive path failed status=$security_status runtimeStatus=$BUBBLES_PYTHON_SECURITY_STATUS diagnostic=$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC rejection=$BUBBLES_PYTHON_SECURITY_REJECTION"
fi
SECURITY_RUNTIME="$BUBBLES_PYTHON_SECURITY_RUNTIME"

hostile_env_root="$TMP_ROOT/security-hostile-env"
hostile_env_marker="$hostile_env_root/marker"
mkdir -p "$hostile_env_root"
cat >"$hostile_env_root/sitecustomize.py" <<EOF
from pathlib import Path
Path("$hostile_env_marker").write_text("executed", encoding="utf-8")
EOF
hostile_resolution="$(PYTHONPATH="$hostile_env_root" PYTHONHOME="$hostile_env_root" \
  PYTHONSTARTUP="$hostile_env_root/sitecustomize.py" LD_PRELOAD="$hostile_env_root/missing.so" \
  DYLD_INSERT_LIBRARIES="$hostile_env_root/missing.dylib" \
  DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash -c '
    . "$1"
    if bubbles_python_resolve_security_runtime; then result=RESOLVED; else result=DECLINED; fi
    printf "%s|%s|%s|%s|%s" "$result" "$BUBBLES_PYTHON_SECURITY_STATUS" \
      "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" "$BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL" \
      "$BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL"
  ' _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$hostile_resolution" == "RESOLVED|0|OK|PYSEC1|PYMOD1" && ! -e "$hostile_env_marker" ]]; then
  ok "SCN-B039-005: PYTHON and loader environment cannot enter the isolated runtime"
else
  bad "SCN-B039-005: hostile environment result='$hostile_resolution' marker=$([[ -e "$hostile_env_marker" ]] && echo present || echo absent)"
fi

# ── SCN-B039-005 path predicates: ownership, modes, links, and native bytes ──
echo "Scenario: SCN-B039-005 path authentication rejects caller authority and unsafe link topology."
path_fixture="$TMP_ROOT/security-paths"
mkdir -p "$path_fixture/bin"
cat >"$path_fixture/bin/python3" <<'EOF'
#!/bin/bash
printf '%s\n' 'RUNTIME PYSEC1 forged'
EOF
chmod +x "$path_fixture/bin/python3"
if _bubbles_python_security_authenticate_path "$path_fixture/bin/python3" executable 1; then
  bad "SCN-B039-005: caller-owned text executable was authenticated"
else
  case "$BUBBLES_PYTHON_SECURITY_PATH_REJECTION" in
    ANCESTOR_OWNER | ANCESTOR_MODE_WRITABLE | ANCESTOR_CALLER_WRITABLE | TARGET_OWNER | TARGET_CALLER_WRITABLE | TARGET_FORMAT)
      ok "SCN-B039-005: caller-owned path is rejected before execution ($BUBBLES_PYTHON_SECURITY_PATH_REJECTION)"
      ;;
    *) bad "SCN-B039-005: caller-owned path rejection was '$BUBBLES_PYTHON_SECURITY_PATH_REJECTION'" ;;
  esac
fi
if ! _bubbles_python_security_mode_is_writable 755 && _bubbles_python_security_mode_is_writable 775 &&
  _bubbles_python_security_mode_is_writable 757 && _bubbles_python_security_mode_is_writable 777; then
  ok "SCN-B039-005: group/other writable ancestor and target modes fail closed"
else
  bad "SCN-B039-005: writable-mode predicate accepted an unsafe mode"
fi
if _bubbles_python_security_native_format "$path_fixture/bin/python3"; then
  bad "SCN-B039-005: text wrapper passed native ELF/Mach-O identity"
else
  ok "SCN-B039-005: text wrapper is rejected by native-format identity"
fi

ln -s target "$path_fixture/cycle-a"
ln -s cycle-a "$path_fixture/target"
depth_target="$path_fixture/depth-final"
printf '%s\n' x >"$depth_target"
depth_index=34
while [[ "$depth_index" -ge 1 ]]; do
  if [[ "$depth_index" -eq 34 ]]; then depth_next='depth-final'; else depth_next="depth-$((depth_index + 1))"; fi
  ln -s "$depth_next" "$path_fixture/depth-$depth_index"
  depth_index=$((depth_index - 1))
done
link_escape="$path_fixture/link-escape"
ln -s "$path_fixture/bin/python3" "$link_escape"

synthetic_link_rejection() {
  local requested="$1"
  local expected="$2"
  local observed=""
  observed="$(/bin/bash -c '
    . "$1"
    original_definition="$(declare -f _bubbles_python_security_stat)"
    original_definition="${original_definition/_bubbles_python_security_stat/_bubbles_python_security_stat_real}"
    eval "$original_definition"
    _bubbles_python_security_validate_directory() { return 0; }
    _bubbles_python_security_stat() {
      _bubbles_python_security_stat_real "$@" || return $?
      if [[ "$BUBBLES_PYTHON_SECURITY_META_TYPE" == symlink ]]; then
        BUBBLES_PYTHON_SECURITY_META_OWNER=0
      fi
    }
    if _bubbles_python_security_authenticate_path "$2" file 0; then
      printf RESOLVED
    else
      printf "%s" "$BUBBLES_PYTHON_SECURITY_PATH_REJECTION"
    fi
  ' _ "$ENV_SH" "$requested" 2>/dev/null || true)"
  if [[ "$observed" == "$expected" ]]; then
    ok "SCN-B039-005: $expected is detected by the production link walker"
  else
    bad "SCN-B039-005: expected $expected, observed '${observed:-empty}'"
  fi
}
synthetic_link_rejection "$path_fixture/cycle-a" SYMLINK_CYCLE
synthetic_link_rejection "$path_fixture/depth-1" SYMLINK_DEPTH
synthetic_link_rejection "$link_escape" TARGET_OWNER

synthetic_final_rejection() {
  local mode="$1"
  local requested="$2"
  local expected="$3"
  local observed=""
  observed="$(/bin/bash -c '
    . "$1"
    mode="$2"
    requested="$3"
    expected_target="$4"
    original_definition="$(declare -f _bubbles_python_security_stat)"
    original_definition="${original_definition/_bubbles_python_security_stat/_bubbles_python_security_stat_real}"
    eval "$original_definition"
    _bubbles_python_security_validate_directory() { return 0; }
    _bubbles_python_security_stat() {
      _bubbles_python_security_stat_real "$@" || return $?
      if [[ "$1" == "$expected_target" ]]; then
        case "$mode" in
          root-metadata-writable-mode)
            BUBBLES_PYTHON_SECURITY_META_OWNER=0
            BUBBLES_PYTHON_SECURITY_META_MODE=777
            BUBBLES_PYTHON_SECURITY_META_TYPE=file
            ;;
          root-metadata-caller-writable)
            BUBBLES_PYTHON_SECURITY_META_OWNER=0
            BUBBLES_PYTHON_SECURITY_META_MODE=755
            BUBBLES_PYTHON_SECURITY_META_TYPE=file
            ;;
        esac
      fi
    }
    if _bubbles_python_security_authenticate_path "$requested" file 0; then
      printf RESOLVED
    else
      printf "%s" "$BUBBLES_PYTHON_SECURITY_PATH_REJECTION"
    fi
  ' _ "$ENV_SH" "$mode" "$requested" "$requested" 2>/dev/null || true)"
  if [[ "$observed" == "$expected" ]]; then
    ok "SCN-B039-005: $expected rejects $mode through the production path walker"
  else
    bad "SCN-B039-005: $mode expected $expected, observed '${observed:-empty}'"
  fi
}
synthetic_final_rejection caller-owned-target "$path_fixture/bin/python3" TARGET_OWNER
synthetic_final_rejection root-metadata-writable-mode "$path_fixture/bin/python3" TARGET_MODE_WRITABLE
synthetic_final_rejection root-metadata-caller-writable "$path_fixture/bin/python3" TARGET_CALLER_WRITABLE
synthetic_final_rejection caller-owned-symlink "$link_escape" SYMLINK_OWNER

# ── SCN-B039-005 protocol corruption and untrusted closure mutations ───────
echo "Scenario: SCN-B039-005 malformed PYSEC1/PYMOD1 and untrusted origins fail closed."
runtime_capture="$TMP_ROOT/runtime-probe.capture"
module_capture="$TMP_ROOT/module-probe.capture"
if bubbles_python_run_security_operation runtime-probe; then
  /bin/cp "$BUBBLES_PYTHON_SECURITY_STDOUT_PATH" "$runtime_capture"
  bubbles_python_security_cleanup || true
else
  bad "SCN-B039-005: authenticated runtime-probe operation failed"
  bubbles_python_security_cleanup || true
fi
if bubbles_python_run_security_operation module-probe; then
  /bin/cp "$BUBBLES_PYTHON_SECURITY_STDOUT_PATH" "$module_capture"
  bubbles_python_security_cleanup || true
else
  bad "SCN-B039-005: authenticated module-probe operation failed"
  bubbles_python_security_cleanup || true
fi

malformed_runtime="$TMP_ROOT/runtime-malformed.capture"
printf 'RUNTIME\tPYSEC1\t3\n' >"$malformed_runtime"
if _bubbles_python_security_validate_runtime_protocol "$malformed_runtime" "$SECURITY_RUNTIME"; then
  bad "SCN-B039-005: malformed PYSEC1 was accepted"
else
  ok "SCN-B039-005: malformed PYSEC1 is rejected"
fi
unsupported_runtime="$TMP_ROOT/runtime-unsupported.capture"
/usr/bin/awk 'NR == 1 { print "RUNTIME\tPYSEC1\t3\t8"; next } { print }' \
  "$runtime_capture" >"$unsupported_runtime"
BUBBLES_PYTHON_SECURITY_DIAGNOSTIC='NOT_RUN'
if _bubbles_python_security_validate_runtime_protocol "$unsupported_runtime" "$SECURITY_RUNTIME"; then
  bad "SCN-B039-005: unsupported Python 3.8 protocol was accepted"
elif [[ "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" == PYTHON_VERSION_UNSUPPORTED ]]; then
  ok "SCN-B039-005: unsupported Python version receives its closed diagnostic"
else
  bad "SCN-B039-005: unsupported-version diagnostic was '$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC'"
fi
untrusted_search_root="$TMP_ROOT/untrusted-search-root"
mkdir -p "$untrusted_search_root"
untrusted_runtime="$TMP_ROOT/runtime-untrusted-root.capture"
/usr/bin/awk -v bad="$untrusted_search_root" '
  BEGIN { changed=0 }
  /^PATH\tPYSEC1\t/ && changed == 0 { print "PATH\tPYSEC1\t" bad; changed=1; next }
  { print }
' "$runtime_capture" >"$untrusted_runtime"
BUBBLES_PYTHON_SECURITY_DIAGNOSTIC='NOT_RUN'
if _bubbles_python_security_validate_runtime_protocol "$untrusted_runtime" "$SECURITY_RUNTIME"; then
  bad "SCN-B039-005: caller-owned PYSEC1 search root was accepted"
elif [[ "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" == RUNTIME_CLOSURE_UNTRUSTED ]]; then
  ok "SCN-B039-005: caller-owned PYSEC1 search root fails closure authentication"
else
  bad "SCN-B039-005: untrusted PYSEC1 root diagnostic was '$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC'"
fi
malformed_module="$TMP_ROOT/module-malformed.capture"
printf 'COMPLETE\tPYMOD1\t8\n' >"$malformed_module"
if _bubbles_python_security_validate_module_protocol "$malformed_module"; then
  bad "SCN-B039-005: malformed PYMOD1 was accepted"
else
  ok "SCN-B039-005: malformed PYMOD1 is rejected"
fi
module_record_count="$(/usr/bin/grep -c $'^MODULE\tPYMOD1\t' "$module_capture" || true)"
module_declared_count="$(/usr/bin/awk -F '\t' '$1 == "COMPLETE" && $2 == "PYMOD1" { print $3 }' "$module_capture")"
if [[ "$module_record_count" =~ ^[0-9]+$ && "$module_declared_count" == "$module_record_count" &&
  "$module_record_count" -gt 9 ]]; then
  ok "SCN-B039-005: PYMOD1 authenticates the complete loaded-module closure ($module_record_count records)"
else
  bad "SCN-B039-005: PYMOD1 closure count records=$module_record_count declared=${module_declared_count:-missing}"
fi
untrusted_module="$TMP_ROOT/module-untrusted-origin.capture"
printf '%s\n' 'untrusted module fixture' >"$untrusted_search_root/module.py"
/usr/bin/awk -v bad="$untrusted_search_root/module.py" '
  BEGIN { changed=0 }
  /^MODULE\tPYMOD1\t/ && $4 == "file" && changed == 0 { $5=bad; OFS="\t"; print $1,$2,$3,$4,$5; changed=1; next }
  { print }
' "$module_capture" >"$untrusted_module"
BUBBLES_PYTHON_SECURITY_DIAGNOSTIC='NOT_RUN'
if _bubbles_python_security_validate_module_protocol "$untrusted_module"; then
  bad "SCN-B039-005: caller-owned PYMOD1 origin was accepted"
elif [[ "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" == MODULE_CLOSURE_UNTRUSTED ]]; then
  ok "SCN-B039-005: caller-owned PYMOD1 origin fails closure authentication"
else
  bad "SCN-B039-005: untrusted PYMOD1 origin diagnostic was '$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC'"
fi
BUBBLES_PYTHON_SECURITY_RUNTIME="$SECURITY_RUNTIME"
BUBBLES_PYTHON_SECURITY_STATUS=0
BUBBLES_PYTHON_SECURITY_DIAGNOSTIC=OK
BUBBLES_PYTHON_SECURITY_REJECTION=NONE
# Fixture input is consumed by functions sourced from python-env.sh.
# shellcheck disable=SC2034
BUBBLES_PYTHON_SECURITY_PROVENANCE=root-protected-path
BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL=PYSEC1
BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL=PYMOD1

# ── SCN-B039-007/008 exact-child status and cleanup mutations ──────────────

run_fixed_operation_case() {
  local mode="$1" expected_status="$2" expected_diagnostic="$3"
  local finding_label="${4:-SCN-B039-007/008}"
  local copy_dir="$TMP_ROOT/runner-$mode" copy="$TMP_ROOT/runner-$mode/python-env.sh"
  local result=""
  local mutation_marker_count=0
  local source_mode=""
  local copy_mode=""
  local expected_timeout=0
  mkdir -p "$copy_dir"
  if ! make_runner_mutation "$mode" "$copy"; then
    bad "$finding_label SETUP: $mode copied mutation did not match the production source exactly"
    return
  fi
  case "$mode" in
    scope2-*)
      mutation_marker_count="$(/usr/bin/grep -cF "B039-SCOPE2-$mode" "$copy" || true)"
      if source_mode="$(/usr/bin/stat -f '%Lp' "$ENV_SH" 2>/dev/null)"; then
        copy_mode="$(/usr/bin/stat -f '%Lp' "$copy" 2>/dev/null || true)"
      else
        source_mode="$(/usr/bin/stat -c '%a' "$ENV_SH" 2>/dev/null || true)"
        copy_mode="$(/usr/bin/stat -c '%a' "$copy" 2>/dev/null || true)"
      fi
      if [[ "$mutation_marker_count" -ne 1 || -z "$source_mode" || "$copy_mode" != "$source_mode" ]]; then
        bad "$finding_label SETUP: $mode fixture marker/mode verification failed (markers=$mutation_marker_count sourceMode=${source_mode:-missing} copyMode=${copy_mode:-missing})"
        return
      fi
      printf 'TP-S2-01_FIXTURE_READY mode=%s markerCount=%s sourceMode=%s copyMode=%s\n' \
        "$mode" "$mutation_marker_count" "$source_mode" "$copy_mode"
      ;;
  esac
  result="$(/bin/bash -c '
    . "$1"
    BUBBLES_PYTHON_SECURITY_RUNTIME="$2"
    BUBBLES_PYTHON_SECURITY_STATUS=0
    BUBBLES_PYTHON_SECURITY_DIAGNOSTIC=OK
    BUBBLES_PYTHON_SECURITY_PROVENANCE=root-protected-path
    BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL=PYSEC1
    BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL=PYMOD1
    operation_status=0
    bubbles_python_run_security_operation runtime-probe || operation_status=$?
    root="$BUBBLES_PYTHON_SECURITY_PRIVATE_ROOT"
    diagnostic="$BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC"
    timed_out="$BUBBLES_PYTHON_SECURITY_RUN_TIMED_OUT"
    bubbles_python_security_cleanup || cleanup_status=$?
    if [[ -z "$root" || ! -e "$root" ]]; then removed=yes; else removed=no; fi
    printf "%s|%s|%s|%s" "$operation_status" "$diagnostic" "$timed_out" "$removed"
  ' _ "$copy" "$SECURITY_RUNTIME" 2>/dev/null || true)"
  [[ "$expected_diagnostic" == CONTROL_TIMEOUT || "$expected_diagnostic" == SUPERVISOR_TIMEOUT ]] && expected_timeout=1
  if [[ "$result" == "$expected_status|$expected_diagnostic|$expected_timeout|yes" ]]; then
    ok "$finding_label: $mode preserves status $expected_status / $expected_diagnostic and removes private state"
  else
    bad "$finding_label: $mode result '$result', expected '$expected_status|$expected_diagnostic|$expected_timeout|yes'"
  fi
}

run_fixed_operation_case child73 73 CHILD_EXIT_NONZERO
run_fixed_operation_case timeout 124 CONTROL_TIMEOUT
run_fixed_operation_case control125 125 CONTROL_MALFORMED
run_fixed_operation_case child143 143 CHILD_EXIT_NONZERO
run_fixed_operation_case setup125 125 CAPTURE_UNAVAILABLE
run_fixed_operation_case signal-hup 129 SIGNAL_HUP
run_fixed_operation_case signal-int 130 SIGNAL_INT
run_fixed_operation_case signal-term 143 SIGNAL_TERM

echo "Scenario: TP-S2-01 HAR-R2 target-controlled channels cannot authorize native completion."
run_fixed_operation_case scope2-forged-control 124 SUPERVISOR_TIMEOUT \
  "TP-S2-01 HAR-R2 worker cannot write supervisor control"
run_fixed_operation_case scope2-early-eof 124 SUPERVISOR_TIMEOUT \
  "TP-S2-01 HAR-R2 pipe EOF cannot end the independent supervisor wall"
run_fixed_operation_case scope2-descriptor-descendant 0 OK \
  "TP-S2-01 HAR-R2 descriptor-holding descendant cannot delay direct-worker completion"

success_shadow_result="$(/bin/bash -c '
  . "$1"
  BUBBLES_PYTHON_SECURITY_RUNTIME="$2"
  BUBBLES_PYTHON_SECURITY_STATUS=0
  BUBBLES_PYTHON_SECURITY_DIAGNOSTIC=OK
  BUBBLES_PYTHON_SECURITY_PROVENANCE=root-protected-path
  BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL=PYSEC1
  BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL=PYMOD1
  shadow_kill=0; shadow_wait=0
  kill() { shadow_kill=$((shadow_kill + 1)); return 99; }
  wait() { shadow_wait=$((shadow_wait + 1)); return 99; }
  trap '\''return 91'\'' HUP
  trap '\''return 92'\'' INT
  trap '\''return 93'\'' TERM
  before_hup="$(trap -p HUP)"; before_int="$(trap -p INT)"; before_term="$(trap -p TERM)"
  operation_status=0
  bubbles_python_run_security_operation runtime-probe || operation_status=$?
  root="$BUBBLES_PYTHON_SECURITY_PRIVATE_ROOT"
  bubbles_python_security_cleanup || cleanup_status=$?
  after_hup="$(trap -p HUP)"; after_int="$(trap -p INT)"; after_term="$(trap -p TERM)"
  if [[ "$before_hup" == "$after_hup" && "$before_int" == "$after_int" && "$before_term" == "$after_term" ]]; then traps=restored; else traps=changed; fi
  if [[ -n "$root" && ! -e "$root" ]]; then removed=yes; else removed=no; fi
  printf "%s|%s|%s|%s|%s|%s" "$operation_status" "$BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC" "$shadow_kill" "$shadow_wait" "$traps" "$removed"
' _ "$ENV_SH" "$SECURITY_RUNTIME" 2>/dev/null || true)"
if [[ "$success_shadow_result" == "0|OK|0|0|restored|yes" ]]; then
  ok "SCN-B039-007/008: success uses builtin kill/wait, restores traps, and removes captures"
else
  bad "SCN-B039-007/008: success/shadow result '$success_shadow_result'"
fi

# EXIT cleanup: intentionally leave a successful operation registered, then
# exit the sourcing shell. Its restored outer process verifies the private root.
exit_root_file="$TMP_ROOT/exit-cleanup-root"
exit_case_status=0
/bin/bash -c '
  . "$1"
  BUBBLES_PYTHON_SECURITY_RUNTIME="$2"
  BUBBLES_PYTHON_SECURITY_STATUS=0
  BUBBLES_PYTHON_SECURITY_DIAGNOSTIC=OK
  BUBBLES_PYTHON_SECURITY_PROVENANCE=root-protected-path
  BUBBLES_PYTHON_SECURITY_PATH_PROTOCOL=PYSEC1
  BUBBLES_PYTHON_SECURITY_MODULE_PROTOCOL=PYMOD1
  bubbles_python_run_security_operation runtime-probe
  printf "%s\n" "$BUBBLES_PYTHON_SECURITY_PRIVATE_ROOT" >"$3"
  exit 77
' _ "$ENV_SH" "$SECURITY_RUNTIME" "$exit_root_file" 2>/dev/null || exit_case_status=$?
exit_private_root="$(/bin/cat "$exit_root_file" 2>/dev/null || true)"
if [[ "$exit_case_status" -eq 77 && -n "$exit_private_root" && ! -e "$exit_private_root" ]]; then
  ok "SCN-B039-008: EXIT cleanup removes an intentionally unconsumed operation root"
else
  bad "SCN-B039-008: EXIT cleanup status=$exit_case_status root='${exit_private_root:-missing}'"
fi

# The repeated fixed-operation matrix has no retries: each of 30 named
# iterations executes once against the same authenticated runtime.
matrix_iteration=1
matrix_failures=0
while [[ "$matrix_iteration" -le 30 ]]; do
  matrix_status=0
  bubbles_python_run_security_operation runtime-probe || matrix_status=$?
  matrix_root="$BUBBLES_PYTHON_SECURITY_PRIVATE_ROOT"
  matrix_diagnostic="$BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC"
  bubbles_python_security_cleanup || matrix_status=125
  if [[ "$matrix_status" -eq 0 && "$matrix_diagnostic" == OK && -n "$matrix_root" && ! -e "$matrix_root" ]]; then
    ok "SCN-B039-007 stress iteration $matrix_iteration/30 exact-child success"
  else
    bad "SCN-B039-007 stress iteration $matrix_iteration/30 status=$matrix_status diagnostic=$matrix_diagnostic"
    matrix_failures=$((matrix_failures + 1))
  fi
  matrix_iteration=$((matrix_iteration + 1))
done
if [[ "$matrix_failures" -eq 0 ]]; then
  ok "SCN-B039-007: fixed-wall matrix completed 30/30 with no retry substitution"
else
  bad "SCN-B039-007: fixed-wall matrix had $matrix_failures failed iteration(s)"
fi

# Structural assertions are scoped to the production security module. Strings
# in this selftest's labeled negative controls do not authorize production use.
if /usr/bin/grep -Eq '^[[:space:]]*set -m|builtin kill[[:space:]].*"-\$|kill -0|BUBBLES_PYTHON_.*DESCENDANT|bubbles_python_run_bounded|bubbles_python_resolve_trusted_runnable' "$ENV_SH"; then
  bad "SCN-B039-007: forbidden process-group, polling, descendant, or removed API remains in production"
else
  ok "SCN-B039-007: production security module contains no forbidden supervision mechanism"
fi
if runner_launch_registration_is_adjacent "$ENV_SH"; then
  ok "SCN-B039-007: PID publication and REGISTERED state are structurally adjacent to launch"
else
  bad "SCN-B039-007: launch registration window contains an unrelated command"
fi

# ── Case 13: the absent-locator reason names the cause, not the interpreters ──
# The failure text is the deliverable here. "no interpreter satisfies" sends a
# reader to inspect interpreters; the honest text says none could be named.
c13_empty="$TMP_ROOT/c13/emptypath"
mkdir -p "$c13_empty"
c13_reason="$(env -i PATH="$c13_empty" /bin/bash -c \
  '. "$1"; if bubbles_python_resolve_runnable >/dev/null 2>&1; then printf "UNEXPECTED_RESOLVE"; else printf "%s" "$BUBBLES_PYTHON_RUNNABLE_REASON"; fi' \
  _ "$ENV_SH" 2>/dev/null || true)"
if [[ "$c13_reason" == *"the managed venv has no locator"* &&
  "$c13_reason" == *"$LOCATOR_VARS_EXPECTED"* ]]; then
  ok "Case 13: absent-locator reason names the locator variables"
else
  bad "Case 13: reason was '$c13_reason', expected it to name 'the managed venv has no locator' and '$LOCATOR_VARS_EXPECTED'"
fi
# Teeth: the reason must not describe a venv it never located. Under the
# historical defect this branch reported "the managed venv (/bin/python3) is
# absent or does not execute", which is a claim about a path nothing chose.
if [[ "$c13_reason" == *"the managed venv ("* ]]; then
  bad "Case 13b: reason names a concrete venv path while no locator is set: '$c13_reason'"
else
  ok "Case 13b: reason claims no venv path when none could be named"
fi

# ---------------------------------------------------------------------------
# BUG-039 Scope 2 TDD RED contract.
#
# These controls target the authoritative privileged-native-supervision-v2
# epoch while retaining root-protected-native-python-v1 for the worker. They
# intentionally fail against clean successor 72bbb987 until production adds
# privileged entry and native waitpid supervision. Fixture-construction errors
# use a distinct SETUP label and never masquerade as a contract RED.
# ---------------------------------------------------------------------------

scope2_fixed_modern_bash() {
  local candidate=""
  local major=""
  for candidate in /opt/homebrew/bin/bash /opt/local/bin/bash /usr/local/bin/bash /usr/bin/bash /bin/bash; do
    [[ -x "$candidate" ]] || continue
    major="$("$candidate" -c 'printf "%s" "${BASH_VERSINFO[0]:-0}"' 2>/dev/null || true)"
    if [[ "$major" =~ ^[0-9]+$ && "$major" -ge 4 ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

scope2_prepare_entry_fixture() {
  local fixture_root="$1"
  local framework_root=""
  local relative_path=""
  framework_root="$(cd "$SCRIPT_DIR/.." && pwd -P)"
  mkdir -p "$fixture_root/specs/001-scope2-entry" "$fixture_root/src"
  /bin/cp -Rp "$framework_root" "$fixture_root/bubbles" || return 2
  for relative_path in \
    scripts/cli.sh \
    scripts/implementation-reality-scan.sh \
    scripts/guard-lib.sh \
    scripts/python-env.sh \
    scripts/fun-mode.sh \
    scripts/aliases.sh; do
    if [[ ! -f "$fixture_root/bubbles/$relative_path" ]] ||
      ! /usr/bin/cmp -s "$framework_root/$relative_path" "$fixture_root/bubbles/$relative_path" ||
      { [[ -x "$framework_root/$relative_path" ]] && [[ ! -x "$fixture_root/bubbles/$relative_path" ]]; }; then
      printf 'TP-S2-01_ENTRY_FIXTURE_SETUP_FAILED path=%s\n' "$relative_path" >&2
      return 2
    fi
  done
  cat >"$fixture_root/specs/001-scope2-entry/scopes.md" <<'EOF'
# Scope 1: BUG-039 privileged entry fixture

### Implementation Files

- `src/scope2-entry.js`
EOF
  cat >"$fixture_root/src/scope2-entry.js" <<'EOF'
export function scope2EntryLabel(value) {
  return String(value);
}
EOF
  return 0
}

scope2_write_hostile_startup() {
  local destination="$1"
  cat >"$destination" <<'EOF'
source() {
  case "${0:-}:${1:-}" in
    */implementation-reality-scan.sh:*/guard-lib.sh)
      printf '%s\n' SCANNER_GUARD_SOURCE_INTERCEPTED >>"${BUBBLES_SCOPE2_ENTRY_MARKER:?marker required}"
      builtin source "$@"
      return 73
      ;;
  esac
  builtin source "$@"
}
kill() {
  printf '%s\n' HOSTILE_KILL_CALLED >>"${BUBBLES_SCOPE2_ENTRY_MARKER:?marker required}"
  return 73
}
wait() {
  printf '%s\n' HOSTILE_WAIT_CALLED >>"${BUBBLES_SCOPE2_ENTRY_MARKER:?marker required}"
  return 73
}
export -f source kill wait
EOF
}

scope2_assert_cli_entry_case() {
  local mode="$1"
  local modern_bash="$2"
  local fixture_root="$TMP_ROOT/scope2-entry-$mode"
  local hostile_startup="$fixture_root/hostile-startup.sh"
  local marker_file="$fixture_root/hostile.marker"
  local output_file="$fixture_root/caller.output"
  local copied_cli="$fixture_root/bubbles/scripts/cli.sh"
  local entry_status=0
  local marker_count=0
  local fixed_path="/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

  if ! scope2_prepare_entry_fixture "$fixture_root"; then
    bad "TP-S2-01 SEC-R1 SETUP: $mode copied caller fixture did not preserve every required sibling and mode"
    return
  fi
  scope2_write_hostile_startup "$hostile_startup"

  case "$mode" in
    bash-env)
      if /usr/bin/env \
        PATH="$fixed_path" \
        DEVELOPER_DIR=/Library/Developer/CommandLineTools \
        BASH_ENV="$hostile_startup" \
        BUBBLES_SCOPE2_ENTRY_MARKER="$marker_file" \
        "$modern_bash" "$copied_cli" scan specs/001-scope2-entry \
        >"$output_file" 2>&1 </dev/null; then
        entry_status=0
      else
        entry_status=$?
      fi
      ;;
    exported-functions)
      if /usr/bin/env -u BASH_ENV \
        PATH="$fixed_path" \
        DEVELOPER_DIR=/Library/Developer/CommandLineTools \
        BUBBLES_SCOPE2_ENTRY_MARKER="$marker_file" \
        /bin/bash -c '
          . "$1"
          export -f source kill wait
          exec "$2" "$3" scan specs/001-scope2-entry
        ' _ "$hostile_startup" "$modern_bash" "$copied_cli" \
        >"$output_file" 2>&1 </dev/null; then
        entry_status=0
      else
        entry_status=$?
      fi
      ;;
    *)
      bad "TP-S2-01 SEC-R1 SETUP: unknown hostile entry mode '$mode'"
      return
      ;;
  esac

  marker_count="$(/usr/bin/grep -cF SCANNER_GUARD_SOURCE_INTERCEPTED "$marker_file" 2>/dev/null || true)"
  if [[ "$entry_status" -eq 73 && "$marker_count" -eq 1 ]] &&
    ! /usr/bin/grep -Fq $'ENTRY\tBSEC1\tprivileged-bash-entry-v1\tdirect' "$output_file"; then
    printf 'RED: TP-S2-01 SEC-R1 mode=%s callerExit=%s hostileScannerSources=%s missing=BSEC1/direct\n' \
      "$mode" "$entry_status" "$marker_count"
    bad "TP-S2-01 SEC-R1: $mode crossed the canonical CLI caller before env -i /bin/bash -p"
  elif [[ "$entry_status" -eq 0 && "$marker_count" -eq 0 ]] &&
    /usr/bin/grep -Fq $'ENTRY\tBSEC1\tprivileged-bash-entry-v1\tdirect' "$output_file"; then
    ok "TP-S2-01 SEC-R1: $mode is excluded before the direct BSEC1 privileged child"
  else
    /bin/cat "$output_file"
    bad "TP-S2-01 SEC-R1 SETUP/CONTRACT: $mode unexpected caller result exit=$entry_status hostileScannerSources=$marker_count"
  fi
}

echo "Scenario: TP-S2-01 SEC-R1 canonical callers exclude hostile Bash startup state."
scope2_modern_bash="$(scope2_fixed_modern_bash || true)"
if [[ -n "$scope2_modern_bash" ]]; then
  scope2_assert_cli_entry_case bash-env "$scope2_modern_bash"
  scope2_assert_cli_entry_case exported-functions "$scope2_modern_bash"
else
  bad "TP-S2-01 SEC-R1 SETUP: no fixed Bash 4+ path is available for the canonical CLI caller"
fi

scope2_scanner="$SCRIPT_DIR/implementation-reality-scan.sh"
scope2_compat_line="$(/usr/bin/grep -nF 'BUBBLES_SECURITY_ENTRY_MODE=compat-reexec' "$scope2_scanner" 2>/dev/null | /usr/bin/awk -F: 'NR == 1 { print $1 }' || true)"
scope2_first_source_line="$(/usr/bin/grep -nE '^[[:space:]]*(source|\.)[[:space:]]+' "$scope2_scanner" 2>/dev/null | /usr/bin/awk -F: 'NR == 1 { print $1 }' || true)"
if [[ "$scope2_compat_line" =~ ^[1-9][0-9]*$ && "$scope2_first_source_line" =~ ^[1-9][0-9]*$ &&
  "$scope2_compat_line" -lt "$scope2_first_source_line" ]] &&
  /usr/bin/grep -Fq '/usr/bin/env -i' "$scope2_scanner" &&
  /usr/bin/grep -Fq '/bin/bash -p' "$scope2_scanner"; then
  ok "TP-S2-01 SEC-R1: ordinary direct scanner compatibility re-execs before every framework source"
else
  printf 'RED: TP-S2-01 SEC-R1 scannerCompatLine=%s firstSourceLine=%s missing=compat-reexec/env-i/bash-p\n' \
    "${scope2_compat_line:-absent}" "${scope2_first_source_line:-absent}"
  bad "TP-S2-01 SEC-R1: scanner lacks first-executable-statement compat-reexec before framework sourcing"
fi

echo "Scenario: TP-S2-01 SEC-R2 fixed native supervisor owns one worker through waitpid and BPS1."
scope2_perl_count="$(/usr/bin/grep -cE '/usr/bin/perl[[:space:]].*-T|-T[[:space:]].*/usr/bin/perl' "$ENV_SH" || true)"
scope2_supervisor_contract_count="$(/usr/bin/grep -cF 'root-protected-perl-supervisor-v1' "$ENV_SH" || true)"
scope2_waitpid_count="$(/usr/bin/grep -cE 'waitpid[[:space:]]*\(' "$ENV_SH" || true)"
scope2_bps1_count="$(/usr/bin/grep -cF 'BPS1' "$ENV_SH" || true)"
scope2_fork_count="$(/usr/bin/grep -cE '(^|[^[:alnum:]_])fork[[:space:]]*\(' "$ENV_SH" || true)"
scope2_boundary_api_count="$(/usr/bin/grep -cE '^bubbles_python_security_require_boundary\(\)' "$ENV_SH" || true)"
scope2_waitpid_line="$(/usr/bin/grep -nE 'waitpid[[:space:]]*\(' "$ENV_SH" 2>/dev/null | /usr/bin/awk -F: 'NR == 1 { print $1 }' || true)"
scope2_bps1_complete_line="$(/usr/bin/grep -nF 'COMPLETE\tBPS1' "$ENV_SH" 2>/dev/null | /usr/bin/awk -F: 'NR == 1 { print $1 }' || true)"
scope2_unreaped_signal_guard_count="$(/usr/bin/grep -ciE 'unreaped[[:space:]_-]+(direct[[:space:]_-]+)?worker|worker[[:space:]_-]+owned' "$ENV_SH" || true)"
if [[ "$scope2_perl_count" -gt 0 && "$scope2_supervisor_contract_count" -gt 0 &&
  "$scope2_waitpid_count" -gt 0 && "$scope2_bps1_count" -gt 0 && "$scope2_fork_count" -eq 1 &&
  "$scope2_boundary_api_count" -eq 1 && "$scope2_waitpid_line" =~ ^[1-9][0-9]*$ &&
  "$scope2_bps1_complete_line" =~ ^[1-9][0-9]*$ &&
  "$scope2_waitpid_line" -lt "$scope2_bps1_complete_line" &&
  "$scope2_unreaped_signal_guard_count" -gt 0 ]]; then
  ok "TP-S2-01 SEC-R2: fixed taint-mode Perl, one direct-worker fork, waitpid, BPS1, and boundary API are present"
else
  printf 'RED: TP-S2-01 SEC-R2 perl=%s supervisorContract=%s fork=%s waitpid=%s waitpidLine=%s BPS1=%s BPS1CompleteLine=%s unreapedSignalGuard=%s boundaryApi=%s\n' \
    "$scope2_perl_count" "$scope2_supervisor_contract_count" "$scope2_fork_count" \
    "$scope2_waitpid_count" "${scope2_waitpid_line:-absent}" "$scope2_bps1_count" \
    "${scope2_bps1_complete_line:-absent}" "$scope2_unreaped_signal_guard_count" "$scope2_boundary_api_count"
  bad "TP-S2-01 SEC-R2: fixed /usr/bin/perl waitpid supervision is missing before BPS1 completion"
fi

scope2_vector_status=0
bubbles_python_run_security_operation caller-program /bin/true 1 1 >/dev/null 2>&1 || scope2_vector_status=$?
scope2_extra_status=0
bubbles_python_run_security_operation runtime-probe /bin/true 1 1 >/dev/null 2>&1 || scope2_extra_status=$?
if [[ "$scope2_vector_status" -eq 2 && "$scope2_extra_status" -eq 2 &&
  "$BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC" == ARGUMENT_INVALID ]]; then
  ok "TP-S2-01 SEC-R2: callers cannot supply a program, helper, wall, grace, or output-limit vector"
else
  bad "TP-S2-01 SEC-R2: closed operation API accepted a caller authority vector (program=$scope2_vector_status extra=$scope2_extra_status diagnostic=$BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC)"
fi
bubbles_python_security_cleanup || true

echo "Scenario: TP-S2-01 HAR-R1 Bash retains only a wait-only supervisor handle."
scope2_legacy_protocol="$(printf '%s%s' 'BP' 'Y1')"
scope2_bash_worker_authority_count="$(/usr/bin/grep -cE "BUBBLES_PYTHON_SECURITY_ACTIVE_PID|_bubbles_python_security_stop_active_child|BUBBLES_PYTHON_SECURITY_FIFO_PATH|READY\\\\t$scope2_legacy_protocol|ERROR\\\\t$scope2_legacy_protocol" "$ENV_SH" || true)"
scope2_supervisor_wait_count="$(/usr/bin/grep -cF 'BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID' "$ENV_SH" || true)"
scope2_forbidden_lifecycle_count="$(/usr/bin/grep -cE '^[[:space:]]*set -m|builtin kill[[:space:]].*"-\$|kill -0|^[[:space:]]*jobs([[:space:]]|$)|^[[:space:]]*disown([[:space:]]|$)|BUBBLES_PYTHON_.*DESCENDANT.*PID' "$ENV_SH" || true)"
scope2_supervisor_wait_line="$(/usr/bin/grep -nE 'builtin wait .*BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID' "$ENV_SH" 2>/dev/null | /usr/bin/awk -F: 'NR == 1 { print $1 }' || true)"
scope2_supervisor_clear_line="$(/usr/bin/grep -nF "BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID=''" "$ENV_SH" 2>/dev/null | /usr/bin/awk -F: -v wait_line="${scope2_supervisor_wait_line:-0}" '$1 > wait_line { print $1; exit }' || true)"
scope2_pending_after_reap_line="$(/usr/bin/awk -v clear_line="${scope2_supervisor_clear_line:-0}" '
  clear_line > 0 && NR > clear_line && /BUBBLES_PYTHON_SECURITY_PENDING_(SIGNAL|STATUS)/ { print NR; exit }
' "$ENV_SH" || true)"
scope2_bash_signals_supervisor_count="$(/usr/bin/grep -cE 'builtin kill .*BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID' "$ENV_SH" || true)"
if [[ "$scope2_bash_worker_authority_count" -eq 0 && "$scope2_supervisor_wait_count" -gt 0 &&
  "$scope2_forbidden_lifecycle_count" -eq 0 && "$scope2_bash_signals_supervisor_count" -eq 0 &&
  "$scope2_supervisor_wait_line" =~ ^[1-9][0-9]*$ && "$scope2_supervisor_clear_line" =~ ^[1-9][0-9]*$ &&
  "$scope2_pending_after_reap_line" =~ ^[1-9][0-9]*$ &&
  "$scope2_supervisor_wait_line" -lt "$scope2_supervisor_clear_line" &&
  "$scope2_supervisor_clear_line" -lt "$scope2_pending_after_reap_line" ]]; then
  ok "TP-S2-01 HAR-R1: Bash has no worker/watchdog signaling, PID probing, process-group, job-control, or descendant-cleanup authority"
else
  printf 'RED: TP-S2-01 HAR-R1 bashWorkerAuthority=%s supervisorWaitHandle=%s waitLine=%s clearLine=%s pendingAfterReapLine=%s bashSignalsSupervisor=%s forbiddenLifecycle=%s\n' \
    "$scope2_bash_worker_authority_count" "$scope2_supervisor_wait_count" \
    "${scope2_supervisor_wait_line:-absent}" "${scope2_supervisor_clear_line:-absent}" \
    "${scope2_pending_after_reap_line:-absent}" "$scope2_bash_signals_supervisor_count" \
    "$scope2_forbidden_lifecycle_count"
  bad "TP-S2-01 HAR-R1: active Bash lifecycle still stores or signals worker/FIFO authority instead of waiting only for the supervisor"
fi

echo "Scenario: TP-S2-01 HAR-R2 only supervisor waitpid decides completion."
scope2_worker_control_count="$(/usr/bin/grep -cE "exec 9>.*FIFO|BUBBLES_PYTHON_SECURITY_FIFO_PATH|READY\\\\t$scope2_legacy_protocol|ERROR\\\\t$scope2_legacy_protocol" "$ENV_SH" || true)"
if [[ "$scope2_worker_control_count" -eq 0 && "$scope2_waitpid_count" -gt 0 && "$scope2_bps1_count" -gt 0 ]]; then
  ok "TP-S2-01 HAR-R2: worker-held FIFO, EOF, and text are absent from completion authority"
else
  printf 'RED: TP-S2-01 HAR-R2 workerControl=%s waitpid=%s BPS1=%s\n' \
    "$scope2_worker_control_count" "$scope2_waitpid_count" "$scope2_bps1_count"
  bad "TP-S2-01 HAR-R2: worker-held FIFO/EOF still participates in completion and no supervisor BPS1 authority exists"
fi

printf '%s\n' 'TP-S2-01_EPOCH=privileged-native-supervision-v2'
printf '%s\n' 'TP-S2-01_RETAINED_WORKER_TRUST=root-protected-native-python-v1'

echo
echo "python-env selftest: $pass passed, $fail failed"
SELFTEST_COMPLETED=1
[[ "$fail" -eq 0 ]]
