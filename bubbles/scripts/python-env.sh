#!/usr/bin/env bash
# python-env.sh — managed Python interpreter resolution and dependency
# provisioning for Bubbles.
#
# WHY THIS EXISTS
# ---------------
# dependency-posture.sh declares python3 + PyYAML + jsonschema REQUIRED and
# refuses to let a guard skip silently ("a guard that skips is a guard that
# lies"). But the framework shipped no supported way to OBTAIN those modules, so
# the declaration had no reachable remedy. Observed consequences on a real
# operator machine:
#
#   * `pip install --user --break-system-packages` — forces past PEP 668 on a
#     Homebrew interpreter, and lands in whichever python3 PATH resolved that
#     day.
#   * a virtualenv under /tmp, referenced by nothing in the repo, wiped on
#     reboot.
#
# Both are shortcuts, and both are silently undone by the next PATH change. A
# machine can carry several python3 installs (Homebrew, python.org, Xcode,
# conda); `command -v python3` is therefore NOT a stable identity, and a
# successful install can stop applying without anything being edited.
#
# THE CONTRACT
#   The managed virtualenv owns its own interpreter, so once provisioned it
#   keeps satisfying regardless of later PATH or conda changes. Resolution is
#   explicit and ordered, never ambient:
#
#     1. $BUBBLES_PYTHON            — operator override, honored only if it satisfies
#     2. the managed venv           — bubbles_python_home()
#     3. python3 from PATH          — honored only if it already satisfies
#
#   Nothing is auto-installed. Provisioning is an explicit operator act:
#     bash bubbles/scripts/python-env.sh --provision
#
# SOURCEABLE. Sourcing defines functions and changes nothing else — it does NOT
# set shell options, because callers source this from scripts with their own
# `set` posture.
#
# Usage (executed):
#   python-env.sh --check       posture report; exit 0 satisfied, 1 not
#   python-env.sh --provision   create/repair the managed venv from requirements.txt
#   python-env.sh --path        print the resolved interpreter; exit 1 if none
#   python-env.sh --help
#
# Exit codes: 0 ok · 1 unsatisfied · 2 usage or provisioning error.

# The python modules Bubbles requires. Kept in lockstep with the
# `python-module:` entries of BUBBLES_REQUIRED_DEPS in dependency-posture.sh;
# python-env-selftest.sh asserts the two agree, so the duplication cannot drift.
BUBBLES_PYTHON_MODULES=(yaml jsonschema)

# bubbles_python_home — durable root of the managed virtualenv.
# NOT under /tmp: a temp-dir venv is erased on reboot, which is exactly the
# shortcut this module replaces.
#
# Every locator is expanded GUARDED, and "there is no locator" is returned as a
# condition rather than printed as a path. An unguarded $HOME inside a `:-`
# default still aborts under `set -u`; because resolution reads this through a
# command substitution, that abort arrived at the caller as an EMPTY candidate
# and was reported as "no interpreter satisfies the required modules" — a
# sentence about interpreters, when the actual subject was an absent locator.
# Naming the two apart is the whole point of returning 1 here.
BUBBLES_PYTHON_LOCATOR_VARS='BUBBLES_PYTHON_HOME, XDG_CACHE_HOME, or HOME'

bubbles_python_home() {
  if [[ -n "${BUBBLES_PYTHON_HOME:-}" ]]; then
    printf '%s\n' "${BUBBLES_PYTHON_HOME%/}"
    return 0
  fi
  if [[ -n "${XDG_CACHE_HOME:-}" ]]; then
    printf '%s\n' "${XDG_CACHE_HOME%/}/bubbles/python"
    return 0
  fi
  if [[ -n "${HOME:-}" ]]; then
    printf '%s\n' "${HOME%/}/.cache/bubbles/python"
    return 0
  fi
  return 1
}

bubbles_python_venv_python() {
  local home
  home="$(bubbles_python_home)" || return 1
  printf '%s\n' "$home/bin/python3"
}

# bubbles_python_satisfies <interpreter> — true when it imports every required module.
bubbles_python_satisfies() {
  local py="${1:-}" module
  [[ -n "$py" && -x "$py" ]] || return 1
  for module in "${BUBBLES_PYTHON_MODULES[@]}"; do
    "$py" -c "import $module" >/dev/null 2>&1 || return 1
  done
  return 0
}

# bubbles_python_resolve — print the first interpreter that satisfies, in the
# documented order. Prints nothing and returns 1 when none does.
bubbles_python_resolve() {
  local candidate
  if [[ -n "${BUBBLES_PYTHON:-}" ]] && bubbles_python_satisfies "$BUBBLES_PYTHON"; then
    printf '%s\n' "$BUBBLES_PYTHON"
    return 0
  fi
  if candidate="$(bubbles_python_venv_python)" && bubbles_python_satisfies "$candidate"; then
    printf '%s\n' "$candidate"
    return 0
  fi
  candidate="$(command -v python3 2>/dev/null || true)"
  if bubbles_python_satisfies "$candidate"; then
    printf '%s\n' "$candidate"
    return 0
  fi
  return 1
}

# bubbles_python_runs <interpreter> — true only when the interpreter EXECUTES.
#
# `command -v python3` answers "is there a file on PATH", which is a different
# question. On macOS /usr/bin/python3 is a shim that dispatches through the
# active developer directory: with an unaccepted Xcode licence it resolves, is
# executable, and then exits 69 without running a line. A payload is demanded
# back rather than an exit code alone, so a wrapper that exits 0 while printing
# a warning cannot pass as healthy either. The process is always bounded through
# a fixed-wall timeout. Arbitrary process output stays
# in a private temporary capture and is never replayed; callers receive only the
# numeric status and one closed diagnostic enum. The probe emits one payload at
# completion, so output-idle is not a liveness signal. A fixed 30-second wall
# bound replaces the disproven 5/10-second bounds that intermittently killed
# healthy probes under load, while still terminating a probe that never returns.
# The runner names every external utility by an absolute system path. Ambient
# PATH and the retired BUBBLES_PYTHON_ISOLATION_PATH override cannot supply a
# helper inside this interpreter trust boundary.
BUBBLES_PYTHON_RUN_SENTINEL='bubbles-python-runs'
BUBBLES_PYTHON_PROBE_TIMEOUT_SECONDS="${BUBBLES_PYTHON_PROBE_TIMEOUT_SECONDS:-30}"
BUBBLES_PYTHON_PROBE_FILE_BLOCKS=1
BUBBLES_PYTHON_RUN_STATUS=127
BUBBLES_PYTHON_RUN_DIAGNOSTIC='NOT_RUN'
BUBBLES_PYTHON_ACTIVE_PROCESS_GROUP=''
BUBBLES_PYTHON_ACTIVE_PROCESS_PID=''
BUBBLES_PYTHON_ACTIVE_COMPLETION_FILE=''

# bubbles_python_terminate_process_group <pgid> <leader-pid>
#
# The bounded runner launches one process group per command. Termination always
# addresses that group first, then the leader as a fail-safe. This catches a
# helper that forks and waits as well as a helper whose leader exits while a
# descendant retains the capture file. Every wait is finite and every external
# utility is an explicit absolute path available on both Linux and macOS.
bubbles_python_terminate_process_group() {
  local process_group="${1:-}"
  local leader_pid="${2:-}"

  [[ "$process_group" =~ ^[1-9][0-9]*$ ]] || return 2
  [[ "$leader_pid" =~ ^[1-9][0-9]*$ ]] || return 2

  kill -TERM -- "-$process_group" 2>/dev/null || kill -TERM "$leader_pid" 2>/dev/null || true
  kill -KILL -- "-$process_group" 2>/dev/null || true
  kill -KILL "$leader_pid" 2>/dev/null || true
}

# Public cleanup hook for a caller's EXIT/signal trap. It is normally a no-op;
# while bubbles_python_run_bounded owns a command, it terminates and reaps that
# exact process tree. Selftests and the production scanner call this before
# removing their temporary captures so an interrupted run cannot orphan work.
bubbles_python_terminate_active_tree() {
  local process_group="$BUBBLES_PYTHON_ACTIVE_PROCESS_GROUP"
  local leader_pid="$BUBBLES_PYTHON_ACTIVE_PROCESS_PID"
  local completion_file="$BUBBLES_PYTHON_ACTIVE_COMPLETION_FILE"

  if [[ "$process_group" =~ ^[1-9][0-9]*$ ]] &&
    [[ "$leader_pid" =~ ^[1-9][0-9]*$ ]]; then
    bubbles_python_terminate_process_group "$process_group" "$leader_pid" || true
    wait "$leader_pid" 2>/dev/null || true
  fi
  if [[ -n "$completion_file" ]]; then
    /bin/rm -f "$completion_file"
  fi
  BUBBLES_PYTHON_ACTIVE_PROCESS_GROUP=''
  BUBBLES_PYTHON_ACTIVE_PROCESS_PID=''
  BUBBLES_PYTHON_ACTIVE_COMPLETION_FILE=''
}

# bubbles_python_run_bounded <seconds> <file-blocks> <log-file> <command...>
#
# Security-sensitive Python execution cannot delegate its isolation boundary to
# an ambient `timeout`, `gtimeout`, `env`, or utility shim. The generic timeout
# fallback also enables job control, whose asynchronous status notifications can
# pollute an exact protocol capture on Bash 3.2. This runner therefore redirects
# the command before enabling monitor mode only for launch. Monitor mode gives
# the command one process group; the parent restores its prior state immediately.
# The group leader writes the command status to a private completion file, then
# remains alive until the parent records that status and terminates the group.
# This is an explicit completion handoff: `kill -0` cannot provide one because
# it remains true for an exited, unreaped child and can observe a recycled PID.
# Timeout is always 124. A command's own signal status, including 143, is
# preserved when the wall deadline did not fire.
bubbles_python_run_bounded() {
  local seconds="${1:-}"
  local file_blocks="${2:-}"
  local log_file="${3:-}"
  local command_pid=""
  local command_status=0
  local completion_file=""
  local monitor_was_enabled=0
  local started_at=0
  local timed_out=0

  shift 3 2>/dev/null || return 2
  if [[ ! "$seconds" =~ ^[1-9][0-9]*$ ]] ||
    [[ ! "$file_blocks" =~ ^[1-9][0-9]*$ ]] ||
    [[ -z "$log_file" ]] || [[ $# -eq 0 ]]; then
    return 2
  fi

  : >"$log_file" || return 2
  completion_file="$(/usr/bin/mktemp)" || return 2

  [[ "$-" == *m* ]] && monitor_was_enabled=1
  set -m
  /bin/bash -c '
    file_blocks="$1"
    completion_file="$2"
    shift 2
    command_status=0
    ulimit -f "$file_blocks" || command_status=$?
    if [[ "$command_status" -eq 0 ]]; then
      "$@" || command_status=$?
    fi
    printf "%s\n" "$command_status" >"$completion_file" || exit 125
    while :; do /bin/sleep 300; done
  ' _ "$file_blocks" "$completion_file" "$@" >"$log_file" 2>&1 </dev/null &
  command_pid=$!
  [[ "$monitor_was_enabled" -eq 1 ]] || set +m

  BUBBLES_PYTHON_ACTIVE_PROCESS_GROUP="$command_pid"
  BUBBLES_PYTHON_ACTIVE_PROCESS_PID="$command_pid"
  BUBBLES_PYTHON_ACTIVE_COMPLETION_FILE="$completion_file"
  started_at=$SECONDS
  while [[ ! -s "$completion_file" ]]; do
    if (( SECONDS - started_at >= seconds )); then
      timed_out=1
      break
    fi
    /bin/sleep 1
  done

  if [[ "$timed_out" -eq 1 ]]; then
    bubbles_python_terminate_active_tree
    return 124
  fi

  command_status="$(/bin/cat "$completion_file" 2>/dev/null || true)"
  if [[ ! "$command_status" =~ ^[0-9]+$ ]] || [[ "$command_status" -gt 255 ]]; then
    command_status=125
  fi
  bubbles_python_terminate_active_tree
  return "$command_status"
}

bubbles_python_runs() {
  local py="${1:-}" probe="" probe_log="" probe_status=0 probe_bytes=""
  BUBBLES_PYTHON_RUN_STATUS=127
  BUBBLES_PYTHON_RUN_DIAGNOSTIC='INTERPRETER_ABSENT'

  [[ -n "$py" && -x "$py" ]] || return 1
  if [[ ! "$BUBBLES_PYTHON_PROBE_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]]; then
    BUBBLES_PYTHON_RUN_STATUS=125
    BUBBLES_PYTHON_RUN_DIAGNOSTIC='TIMEOUT_CONFIG_INVALID'
    return 1
  fi
  probe_log="$(/usr/bin/mktemp)" || {
    BUBBLES_PYTHON_RUN_STATUS=125
    BUBBLES_PYTHON_RUN_DIAGNOSTIC='CAPTURE_UNAVAILABLE'
    return 1
  }

  if bubbles_python_run_bounded \
    "$BUBBLES_PYTHON_PROBE_TIMEOUT_SECONDS" \
    "$BUBBLES_PYTHON_PROBE_FILE_BLOCKS" \
    "$probe_log" \
    "$py" -c "import sys; sys.stdout.write('$BUBBLES_PYTHON_RUN_SENTINEL')"; then
    probe_status=0
  else
    probe_status=$?
  fi
  BUBBLES_PYTHON_RUN_STATUS=$probe_status

  if [[ "$probe_status" -eq 124 ]]; then
    BUBBLES_PYTHON_RUN_DIAGNOSTIC='PROBE_TIMEOUT'
  elif [[ "$probe_status" -ne 0 ]]; then
    if /usr/bin/grep -Eiq 'Xcode (license|licence)|license agreements' "$probe_log" 2>/dev/null; then
      BUBBLES_PYTHON_RUN_DIAGNOSTIC='XCODE_LICENSE_UNACCEPTED'
    else
      BUBBLES_PYTHON_RUN_DIAGNOSTIC='PROBE_EXIT_NONZERO'
    fi
  else
    probe_bytes="$(/usr/bin/wc -c <"$probe_log" 2>/dev/null || true)"
    probe_bytes="${probe_bytes//[[:space:]]/}"
    if [[ ! "$probe_bytes" =~ ^[0-9]+$ ]] || [[ "$probe_bytes" -gt 128 ]]; then
      BUBBLES_PYTHON_RUN_DIAGNOSTIC='PROBE_OUTPUT_LIMIT'
    else
      probe="$(/bin/cat "$probe_log")"
      if [[ "$probe_bytes" -eq 0 ]]; then
        BUBBLES_PYTHON_RUN_DIAGNOSTIC='PROBE_EMPTY'
      elif [[ "$probe_bytes" -eq "${#BUBBLES_PYTHON_RUN_SENTINEL}" && "$probe" == "$BUBBLES_PYTHON_RUN_SENTINEL" ]]; then
        BUBBLES_PYTHON_RUN_DIAGNOSTIC='OK'
      else
        BUBBLES_PYTHON_RUN_DIAGNOSTIC='PROBE_PROTOCOL_INVALID'
      fi
    fi
  fi
  /bin/rm -f "$probe_log"
  [[ "$BUBBLES_PYTHON_RUN_DIAGNOSTIC" == 'OK' ]]
}

# bubbles_python_resolve_runnable — the SAME ordered, non-ambient contract as
# bubbles_python_resolve, for consumers whose helper needs only a working
# stdlib interpreter.
#
# Why a second resolver rather than reusing the first: the required-module set
# (yaml, jsonschema) belongs to the guards that parse YAML, not to every python
# consumer. A helper that imports nothing outside the stdlib would be refused an
# interpreter that runs it perfectly well, which trades one wrong answer for
# another. What every consumer DOES share is the part `command -v python3` gets
# wrong: presence is not usability, and PATH is not a stable identity.
#
# On failure BUBBLES_PYTHON_RUNNABLE_REASON names each candidate and how it
# declined, so the caller can report the absent prerequisite instead of
# inventing a finding about the code it was asked to inspect. Both the reason
# and the resolved path are published as GLOBALS as well as printed: a caller
# that reads the path with `$(...)` runs this in a subshell, where an assignment
# to the reason is discarded and the diagnostic arrives empty — which is the
# same lost-cause failure this function exists to prevent. Read the globals
# after calling it directly:
#
#   if bubbles_python_resolve_runnable >/dev/null; then
#     py="$BUBBLES_PYTHON_RUNNABLE"
#   else
#     echo "unavailable: $BUBBLES_PYTHON_RUNNABLE_REASON"
#   fi
BUBBLES_PYTHON_RUNNABLE=''
BUBBLES_PYTHON_RUNNABLE_REASON=''

bubbles_python_resolve_runnable() {
  local candidate declined=''
  BUBBLES_PYTHON_RUNNABLE=''
  BUBBLES_PYTHON_RUNNABLE_REASON=''

  if [[ -n "${BUBBLES_PYTHON:-}" ]]; then
    if bubbles_python_runs "$BUBBLES_PYTHON"; then
      BUBBLES_PYTHON_RUNNABLE="$BUBBLES_PYTHON"
      printf '%s\n' "$BUBBLES_PYTHON"
      return 0
    fi
    declined="${declined}BUBBLES_PYTHON ($BUBBLES_PYTHON) does not execute; "
  fi

  if candidate="$(bubbles_python_venv_python)"; then
    if bubbles_python_runs "$candidate"; then
      BUBBLES_PYTHON_RUNNABLE="$candidate"
      printf '%s\n' "$candidate"
      return 0
    fi
    declined="${declined}the managed venv ($candidate) is absent or does not execute; "
  else
    declined="${declined}the managed venv has no locator ($BUBBLES_PYTHON_LOCATOR_VARS are all unset); "
  fi

  candidate="$(command -v python3 2>/dev/null || true)"
  if [[ -n "$candidate" ]]; then
    if bubbles_python_runs "$candidate"; then
      # shellcheck disable=SC2034  # cross-file output; read by implementation-reality-scan.sh
      BUBBLES_PYTHON_RUNNABLE="$candidate"
      printf '%s\n' "$candidate"
      return 0
    fi
    declined="${declined}python3 on PATH ($candidate) resolves but exits without running; "
  else
    declined="${declined}no python3 on PATH; "
  fi

  # shellcheck disable=SC2034  # cross-file output; read by implementation-reality-scan.sh
  BUBBLES_PYTHON_RUNNABLE_REASON="${declined%; }"
  return 1
}

# bubbles_python_resolve_trusted_runnable — security-sensitive interpreter
# resolution. Trust is rooted ONLY in the explicitly located managed venv.
#
# BUBBLES_PYTHON and PATH remain available to general consumers through
# bubbles_python_resolve_runnable, but neither is silently promoted to a trust
# root for a security classifier. BUBBLES_PYTHON_HOME / XDG_CACHE_HOME / HOME
# locate the operator-managed environment; provisioning it is an explicit act.
# This is a provenance policy, not an authenticity claim against an attacker who
# can already replace files inside the operator-controlled managed directory.
# shellcheck disable=SC2034  # cross-file contract; read by security consumers
BUBBLES_PYTHON_TRUST_CONTRACT='managed-venv-only-v1'
BUBBLES_PYTHON_TRUSTED=''
BUBBLES_PYTHON_TRUSTED_PROVENANCE='none'
BUBBLES_PYTHON_TRUSTED_STATUS=127
BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC='NOT_RUN'

bubbles_python_resolve_trusted_runnable() {
  local candidate=""
  BUBBLES_PYTHON_TRUSTED=''
  BUBBLES_PYTHON_TRUSTED_PROVENANCE='none'
  BUBBLES_PYTHON_TRUSTED_STATUS=127
  BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC='NOT_RUN'

  if ! candidate="$(bubbles_python_venv_python)"; then
    BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC='NO_LOCATOR'
    return 1
  fi
  # shellcheck disable=SC2034  # cross-file diagnostic output
  BUBBLES_PYTHON_TRUSTED_PROVENANCE='managed-venv'
  if [[ ! -x "$candidate" ]]; then
    BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC='INTERPRETER_ABSENT'
    return 1
  fi
  if ! bubbles_python_runs "$candidate"; then
    BUBBLES_PYTHON_TRUSTED_STATUS=$BUBBLES_PYTHON_RUN_STATUS
    BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC=$BUBBLES_PYTHON_RUN_DIAGNOSTIC
    return 1
  fi

  # shellcheck disable=SC2034  # cross-file resolved interpreter output
  BUBBLES_PYTHON_TRUSTED="$candidate"
  # shellcheck disable=SC2034  # cross-file diagnostic output
  BUBBLES_PYTHON_TRUSTED_STATUS=0
  # shellcheck disable=SC2034  # cross-file diagnostic output
  BUBBLES_PYTHON_TRUSTED_DIAGNOSTIC='OK'
  printf '%s\n' "$candidate"
  return 0
}

# bubbles_python_activate — make a bare `python3` call resolve to a satisfying
# interpreter, so the ~77 scripts that invoke `python3` directly need no edit.
# Only prepends when PATH's python3 does NOT already satisfy, so an operator who
# provisioned deps their own way keeps their interpreter. Idempotent.
bubbles_python_activate() {
  local venv_python bin_dir path_python
  venv_python="$(bubbles_python_venv_python)" || return 1
  bubbles_python_satisfies "$venv_python" || return 1
  path_python="$(command -v python3 2>/dev/null || true)"
  bubbles_python_satisfies "$path_python" && return 0
  bin_dir="${venv_python%/python3}"
  case ":${PATH:-}:" in
    *":$bin_dir:"*) ;;
    *)
      PATH="$bin_dir:${PATH:-}"
      export PATH
      ;;
  esac
  return 0
}

# bubbles_python_base — an interpreter able to CREATE the venv. Distinct from
# bubbles_python_resolve: the base need not have the modules yet.
bubbles_python_base() {
  local candidate resolved
  for candidate in "${BUBBLES_PYTHON_BASE:-}" python3 python3.13 python3.12 python3.11; do
    [[ -n "$candidate" ]] || continue
    resolved="$(command -v "$candidate" 2>/dev/null || true)"
    [[ -n "$resolved" ]] || continue
    if "$resolved" -c 'import sys, venv; sys.exit(0 if sys.version_info[:2] >= (3, 9) else 1)' >/dev/null 2>&1; then
      printf '%s\n' "$resolved"
      return 0
    fi
  done
  return 1
}

bubbles_python_requirements_default() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  printf '%s\n' "$here/../requirements.txt"
}

# bubbles_python_provision <requirements-file> — idempotent create-or-repair.
bubbles_python_provision() {
  local requirements="${1:-}" venv_dir venv_python base
  if ! venv_dir="$(bubbles_python_home)"; then
    echo "python-env: cannot locate the managed environment: $BUBBLES_PYTHON_LOCATOR_VARS are all unset" >&2
    echo "  set one of them, then re-run --provision." >&2
    return 2
  fi
  venv_python="$venv_dir/bin/python3"

  if [[ ! -f "$requirements" ]]; then
    echo "python-env: requirements file not found: $requirements" >&2
    return 2
  fi

  # A half-built or interpreter-less venv is repaired, not worked around.
  if [[ ! -x "$venv_python" ]]; then
    if ! base="$(bubbles_python_base)"; then
      echo "python-env: no python3 (>= 3.9, with venv) available to build the managed environment" >&2
      echo "  set BUBBLES_PYTHON_BASE to an interpreter, or install python3." >&2
      return 2
    fi
    echo "python-env: creating managed environment at $venv_dir (base: $base)"
    rm -rf "$venv_dir"
    if ! "$base" -m venv "$venv_dir"; then
      echo "python-env: failed to create the virtualenv at $venv_dir" >&2
      return 2
    fi
  else
    echo "python-env: reusing managed environment at $venv_dir"
  fi

  # Record the toolchain identity on EVERY run, pass or fail. A provisioning
  # failure that reports only "it failed" leaves the next reader guessing, and
  # WHICH interpreter ran — on WHICH platform — is the first fact any diagnosis
  # needs. Asked of the interpreter itself, never inferred from the host.
  local venv_identity pip_status=0
  venv_identity="$("$venv_python" -c 'import sys, platform; print(sys.version.split()[0], platform.system() + "/" + platform.machine())' 2>/dev/null)" ||
    venv_identity="unreported (the interpreter did not answer)"

  echo "python-env: interpreter $venv_python ($venv_identity)"
  echo "python-env: installing pinned requirements from $requirements"
  "$venv_python" -m pip install \
    --disable-pip-version-check \
    --no-input \
    --requirement "$requirements" || pip_status=$?
  if [[ "$pip_status" -ne 0 ]]; then
    # Report what was OBSERVED. The previous message asserted a cause
    # ("network unavailable, or a pin no longer resolves") that nothing here
    # measured, which is how a CI leg goes dark: the log named a diagnosis
    # instead of the data needed to reach one.
    {
      echo "python-env: dependency installation FAILED (pip rc=$pip_status)"
      echo "  interpreter  : $venv_python"
      echo "  python       : $venv_identity"
      echo "  requirements : $requirements"
      echo "  The cause is NOT determined here; pip's own output above is the record."
      echo "  Common causes: no route to the package index, an index that requires"
      echo "  auth, or a pin with no distribution for this python/platform."
    } >&2
    return 2
  fi

  if ! bubbles_python_satisfies "$venv_python"; then
    echo "python-env: environment still does not import every required module after install" >&2
    return 1
  fi
  return 0
}

bubbles_python_report() {
  local resolved module status_line satisfied=0 home
  echo "Bubbles managed Python posture"
  if home="$(bubbles_python_home)"; then
    echo "  managed venv : $home"
  else
    echo "  managed venv : NONE — no locator ($BUBBLES_PYTHON_LOCATOR_VARS are all unset)"
  fi
  if resolved="$(bubbles_python_resolve)"; then
    satisfied=1
    echo "  resolved     : $resolved"
  else
    echo "  resolved     : NONE — no interpreter imports every required module"
  fi
  for module in "${BUBBLES_PYTHON_MODULES[@]}"; do
    if [[ "$satisfied" -eq 1 ]] && "$resolved" -c "import $module" >/dev/null 2>&1; then
      status_line="ok"
    else
      status_line="MISSING"
    fi
    printf '  module %-12s %s\n' "$module" "$status_line"
  done
  [[ "$satisfied" -eq 1 ]] || return 1
  return 0
}

# ── executed (not sourced) ────────────────────────────────────────────────
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  set -euo pipefail

  bubbles_python_usage() {
    cat <<'EOF'
Usage: bash bubbles/scripts/python-env.sh [--check | --provision | --path]

  --check       Report interpreter/module posture. Exit 0 satisfied, 1 not.
  --provision   Create or repair the managed virtualenv and install the pinned
                requirements from bubbles/requirements.txt.
  --path        Print the resolved interpreter. Exit 1 when none satisfies.
  --help        This text.

Resolution order: $BUBBLES_PYTHON, then the managed venv, then python3 on PATH.
The managed venv is located from BUBBLES_PYTHON_HOME, else XDG_CACHE_HOME, else
HOME. With none of those set the venv cannot be named at all, which is reported
as an absent locator, not as an interpreter that failed its modules.
There is no --skip/--force: an unsatisfied posture is reported, never bypassed.
EOF
  }

  mode="--check"
  if [[ $# -gt 0 ]]; then
    mode="$1"
    shift
  fi
  if [[ $# -gt 0 ]]; then
    echo "python-env: unexpected argument: $1" >&2
    bubbles_python_usage >&2
    exit 2
  fi

  case "$mode" in
    --check)
      if bubbles_python_report; then
        exit 0
      fi
      echo >&2
      if bubbles_python_home >/dev/null; then
        echo "Remediate with: bash bubbles/scripts/python-env.sh --provision" >&2
      else
        echo "Remediate by setting one of $BUBBLES_PYTHON_LOCATOR_VARS, then --provision." >&2
      fi
      exit 1
      ;;
    --provision)
      requirements="$(bubbles_python_requirements_default)"
      bubbles_python_provision "$requirements"
      provision_status=$?
      if [[ "$provision_status" -ne 0 ]]; then
        exit "$provision_status"
      fi
      echo
      bubbles_python_report
      ;;
    --path)
      if resolved_path="$(bubbles_python_resolve)"; then
        printf '%s\n' "$resolved_path"
        exit 0
      fi
      # Two failures reach here and they call for different operator actions.
      # Reporting both as "no interpreter satisfies" sent the reader to inspect
      # interpreters when nothing had been able to name one.
      if bubbles_python_home >/dev/null; then
        echo "python-env: no interpreter satisfies the required modules" >&2
      else
        echo "python-env: cannot locate the managed environment: $BUBBLES_PYTHON_LOCATOR_VARS are all unset" >&2
        echo "  no interpreter was rejected for missing modules; none could be named." >&2
      fi
      exit 1
      ;;
    --help | -h)
      bubbles_python_usage
      exit 0
      ;;
    *)
      echo "python-env: unknown mode: $mode" >&2
      bubbles_python_usage >&2
      exit 2
      ;;
  esac
fi
