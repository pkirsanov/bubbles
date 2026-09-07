#!/usr/bin/env bash
# File: framework-validate-tier-selftest.sh
#
# Hermetic-ish selftest for the IMP-012 framework-validate tiering. Uses the
# `--list-tier` DRY-LIST mode (no checks execute) so it is fast and non-circular.
# Proves: a known core check is WOULD-RUN under --list-tier=core; a known
# non-core check is WOULD-SKIP under core but WOULD-RUN under full; both exit 0;
# and an unknown flag exits 2.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FV="$SCRIPT_DIR/framework-validate.sh"
BASH_BIN="$(command -v bash)"
ENV_BIN="/usr/bin/env"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/guard-lib.sh"

failures=0
pass() { echo "PASS: $1"; }
fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

process_identity() {
  local pid="$1" stat_line="" stat_tail="" started=""
  if [[ -r "/proc/$pid/stat" ]]; then
    stat_line="$(cat "/proc/$pid/stat")"
    stat_tail="${stat_line##*) }"
    read -r -a identity_fields <<<"$stat_tail"
    printf 'proc:%s\n' "${identity_fields[19]}"
    return 0
  fi
  started="$(ps -o lstart= -p "$pid")"
  started="${started#${started%%[![:space:]]*}}"
  started="${started%${started##*[![:space:]]}}"
  started="${started//[[:space:]]/_}"
  printf 'ps:%s\n' "$started"
}

# Force source mode so the self-only checks list rather than emit their
# install-mode SKIP, keeping the listing deterministic.
export BUBBLES_FRAMEWORK_VALIDATE_MODE=source

set +e
core_list="$("$BASH_BIN" "$FV" --list-tier=core 2>&1)"
core_rc=$?
full_list="$("$BASH_BIN" "$FV" --list-tier=full 2>&1)"
full_rc=$?
set -e

# --- core tier: a known fast check runs, a known heavy check is skipped --------
if [[ "$core_rc" -eq 0 ]]; then
  pass "--list-tier=core exits 0 without executing checks"
else
  fail "--list-tier=core should exit 0 (got $core_rc)"
  echo "$core_list" | tail -5
fi
if grep -qE '^WOULD-RUN:.*Registry consistency' <<<"$core_list"; then
  pass "core tier WOULD-RUN a fast structural check (Registry consistency)"
else
  fail "core tier should run the Registry consistency check"
fi
if grep -qE '^WOULD-RUN:.*Scan-lib' <<<"$core_list"; then
  pass "core tier WOULD-RUN the scan-lib selftest"
else
  fail "core tier should run the scan-lib selftest"
fi
if grep -qE '^WOULD-SKIP \(non-core\):.*Finding closure selftest' <<<"$core_list"; then
  pass "core tier WOULD-SKIP a non-core check (Finding closure selftest)"
else
  fail "core tier should skip the non-core Finding closure selftest"
fi

# --- full tier: everything runs (the previously-skipped check now runs) --------
if [[ "$full_rc" -eq 0 ]] \
  && grep -qE '^WOULD-RUN:.*Finding closure selftest' <<<"$full_list" \
  && ! grep -qE '^WOULD-SKIP' <<<"$full_list"; then
  pass "full tier WOULD-RUN every check (no WOULD-SKIP lines)"
else
  fail "full tier should run every check with no skips (got rc=$full_rc)"
  grep -E '^WOULD-SKIP' <<<"$full_list" | head -3
fi

# --- unknown flag → exit 2 ----------------------------------------------------
set +e
"$BASH_BIN" "$FV" --bogus-flag >/dev/null 2>&1
bad_rc=$?
set -e
[[ "$bad_rc" -eq 2 ]] \
  && pass "an unknown framework-validate flag exits 2" \
  || fail "unknown flag should exit 2 (got $bad_rc)"

# --- IMP-049 SCOPE-3 / STAB-002: portable lock behavior -----------------------
# The lock exists to stop two runs corrupting each other's shared scratch
# fixtures. An invocation that executes no check builds none, so it must not
# wait. Before SCOPE-3 both assertions below returned exit 1 with a lock error.
# The third assertion is the safety property and matters more than the first
# three: an EXECUTING run must still contend, or the bypass has been widened into
# a hole. The fixture uses only mkdir/PID metadata, exactly like stock macOS.
lock_tmp="$(mktemp -d)"
lock_dir="$lock_tmp/bubbles-framework-validate.lock.d"
selftest_pid="$BASHPID"
cleanup_lock_fixture() {
  [[ "$BASH_SUBSHELL" -eq 0 && "$BASHPID" == "$selftest_pid" ]] || return 0
  rm -rf "$lock_tmp"
}
trap cleanup_lock_fixture EXIT INT TERM
mkdir "$lock_dir"
lock_token="tier-selftest-owner"
lock_identity="$(process_identity "$$")"
printf '%s %s %s\n' "$$" "$lock_token" "$lock_identity" >"$lock_dir/owner"
[[ -d "$lock_dir" && -f "$lock_dir/owner" ]] || {
  fail "portable lock fixture disappeared before contention tests"
  exit 1
}

# Controlled capability probes run immediately after lock acquisition. A
# failing `sed --version` plus an available `gsed` reaches `mktemp`; its rc=77
# is a deterministic post-lock sentinel without launching validation checks.
sentinel_bin="$lock_tmp/sentinel-bin"
mkdir "$sentinel_bin"
printf '%s\n' '#!/usr/bin/env bash' 'exit 1' >"$sentinel_bin/sed"
printf '%s\n' '#!/usr/bin/env bash' 'exit 0' >"$sentinel_bin/gsed"
printf '%s\n' '#!/usr/bin/env bash' 'exit 77' >"$sentinel_bin/mktemp"
chmod +x "$sentinel_bin/sed" "$sentinel_bin/gsed" "$sentinel_bin/mktemp"

set +e
held_help_out="$(TMPDIR="$lock_tmp" "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD "$BASH_BIN" "$FV" --help 2>&1)"
held_help_rc=$?
held_list_out="$(TMPDIR="$lock_tmp" "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD "$BASH_BIN" "$FV" --list-tier=core 2>&1)"
held_list_rc=$?
held_bad_out="$(TMPDIR="$lock_tmp" "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD "$BASH_BIN" "$FV" --bogus-flag 2>&1)"
held_bad_rc=$?
TMPDIR="$lock_tmp" "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD "$BASH_BIN" "$FV" --tier=core >/dev/null 2>&1
held_exec_rc=$?
TMPDIR="$lock_tmp" BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=forged "$BASH_BIN" "$FV" --tier=core >/dev/null 2>&1
forged_rc=$?
set -e

[[ "$held_help_rc" -eq 0 && "$held_help_out" == *"Usage: framework-validate.sh"* ]] \
  && pass "--help answers while another run holds the portable lock" \
  || fail "--help should not block on the portable lock (got $held_help_rc; output=[$held_help_out])"
[[ "$held_list_rc" -eq 0 && "$held_list_out" == *"WOULD-"* ]] \
  && pass "--list-tier dry-lists while another run holds the portable lock" \
  || fail "--list-tier should not block on the portable lock (got $held_list_rc; output=[$held_list_out])"
[[ "$held_bad_rc" -eq 2 && "$held_bad_out" == *"unknown argument"* ]] \
  && pass "invalid arguments retain their usage error while the lock is held" \
  || fail "invalid argument should bypass locking and exit 2 (got $held_bad_rc; output=[$held_bad_out])"
[[ "$held_exec_rc" -eq 1 ]] \
  && pass "an independent executing run contends for the portable lock" \
  || fail "executing run must be refused while the portable lock is held (got $held_exec_rc)"
[[ "$forged_rc" -eq 1 ]] \
  && pass "a forged inherited marker cannot bypass the portable lock" \
  || fail "forged marker must be refused (got $forged_rc)"

# A live PID with a different kernel start identity is a stale incarnation, not
# the original owner. Control `cat` through PATH so this is deterministic and
# does not depend on racing real PID reuse or wall-clock timing.
fake_bin="$lock_tmp/fake-bin"
mkdir "$fake_bin"
ln -s "$sentinel_bin/sed" "$fake_bin/sed"
ln -s "$sentinel_bin/gsed" "$fake_bin/gsed"
ln -s "$sentinel_bin/mktemp" "$fake_bin/mktemp"
real_cat="$(command -v cat)"
printf '%s\n' '#!/usr/bin/env bash' \
  'if [[ "$1" == "/proc/'"$$"'/stat" ]]; then' \
  '  printf '\''%s (reused) S 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 424242\n'\'' '"$$" \
  'else' \
  '  exec '"$real_cat"' "$@"' \
  'fi' >"$fake_bin/cat"
chmod +x "$fake_bin/cat"
printf '%s %s %s\n' "$$" "reused-owner" "proc:111111" >"$lock_dir/owner"
set +e
reused_out="$(PATH="$fake_bin:$PATH" TMPDIR="$lock_tmp" "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD \
  "$BASH_BIN" "$FV" --tier=core 2>&1)"
reused_rc=$?
set -e
[[ "$reused_rc" -eq 77 ]] \
  && pass "a reused live PID with a stale incarnation is reclaimed atomically" \
  || fail "stale process incarnation should reach the post-lock sentinel (got $reused_rc; output=[$reused_out])"

# A matching token is accepted only because this selftest shell is the recorded
# owner and a real ancestor of the nested validator. The sentinel rc proves it
# progressed past the lock without launching any validation checks.
rm -rf "$lock_dir"
mkdir "$lock_dir"
printf '%s %s %s\n' "$$" "$lock_token" "$lock_identity" >"$lock_dir/owner"
set +e
descendant_out="$(PATH="$sentinel_bin:$PATH" TMPDIR="$lock_tmp" \
  BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD="$lock_token" "$BASH_BIN" "$FV" --tier=core 2>&1)"
descendant_rc=$?
set -e
[[ "$descendant_rc" -eq 77 ]] \
  && pass "a genuine descendant re-enters the portable lock" \
  || fail "genuine descendant should reach the post-lock sentinel (got $descendant_rc; output=[$descendant_out])"

# Dead owners are reclaimed, while malformed ownership fails closed.
printf '%s %s %s\n' "99999999" "dead-owner" "proc:1" >"$lock_dir/owner"
set +e
stale_out="$(PATH="$sentinel_bin:$PATH" TMPDIR="$lock_tmp" \
  "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD "$BASH_BIN" "$FV" --tier=core 2>&1)"
stale_rc=$?
set -e
[[ "$stale_rc" -eq 77 ]] \
  && pass "a dead portable-lock owner is reclaimed atomically" \
  || fail "dead owner should reach the post-lock sentinel (got $stale_rc; output=[$stale_out])"

rm -rf "$lock_dir"
mkdir "$lock_dir"
printf '%s\n' "malformed-owner" >"$lock_dir/owner"
set +e
TMPDIR="$lock_tmp" "$ENV_BIN" -u BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD "$BASH_BIN" "$FV" --tier=core >/dev/null 2>&1
malformed_rc=$?
set -e
[[ "$malformed_rc" -eq 1 ]] \
  && pass "malformed portable-lock ownership fails closed" \
  || fail "malformed owner must fail closed (got $malformed_rc)"
rm -rf "$lock_tmp"
trap - EXIT INT TERM

# --- IMP-049 SCOPE-3: the lock pre-scan must not drift from the parser --------
# The pre-scan names the flags that execute checks; the parser below it names
# every flag it accepts. If someone adds an executing flag to the parser and
# forgets the pre-scan, that flag silently stops taking the lock and two real
# runs can corrupt each other's fixtures. Deriving both sets from the file keeps
# the duplication honest instead of trusting a comment.
prescan_exec="$(awk '/^_fv_executes_checks=true$/,/^fi$/' "$FV" \
  | grep -E '^[[:space:]]+--tier=core \|' \
  | sed 's/).*//' \
  | grep -oE '\-\-[a-z-]+(=[a-z]+)?' | sort -u)"
# Read only the case-arm LABELS (text before the closing paren). Taking whole
# lines also swallows `${_arg#--tier=}` from an arm's body, which looks like a
# bare `--tier` flag that no arm actually accepts.
parser_exec="$(awk '/^for _arg in "\$@"; do$/,/^done$/' "$FV" \
  | grep -E '^[[:space:]]+--' \
  | sed 's/).*//' \
  | grep -oE '\-\-[a-z-]+(=[a-z]+)?' \
  | grep -vE '^--(help|list-tier)' | sort -u)"

[[ -n "$prescan_exec" && "$prescan_exec" == "$parser_exec" ]] \
  && pass "lock pre-scan lists exactly the parser's executing flags" \
  || fail "lock pre-scan drifted from the parser (prescan=[${prescan_exec//$'\n'/,}] parser=[${parser_exec//$'\n'/,}])"

# --- BUG-037: live G128 caller preserves exact identity and child status ------
# Run a copied production framework-validate entrypoint. A PATH shim returns
# success for unrelated bash checks, but executes the copied production
# session-cap-guard.sh for the live G128 row. This keeps the assertion on the
# real caller path without recursively running the complete framework suite.
fv_g128_root="$(cd "$(mktemp -d)" && pwd -P)"
fv_g128_real_bash="$(command -v bash)"
fv_g128_real_env="$(command -v env)"
fv_g128_shim="$fv_g128_root/shim"
fv_g128_binding_root="$(cd "$(mktemp -d)" && pwd -P)"
fv_g128_control_file="$fv_g128_binding_root/repository-binding.json"
fv_g128_packet_file="$fv_g128_binding_root/actionable-packet.json"
mkdir -p "$fv_g128_root/bubbles" "$fv_g128_root/.specify/memory" "$fv_g128_root/agents" "$fv_g128_shim"
cp -R "$SCRIPT_DIR/../." "$fv_g128_root/bubbles/"
cp "$SCRIPT_DIR/../../VERSION" "$fv_g128_root/VERSION"
cp "$SCRIPT_DIR/../../install.sh" "$fv_g128_root/install.sh"
cp "$SCRIPT_DIR/../../agents/bubbles.workflow.agent.md" "$fv_g128_root/agents/bubbles.workflow.agent.md"
chmod 700 "$fv_g128_root/install.sh" "$fv_g128_root/bubbles/scripts/cli.sh"
git -C "$fv_g128_root" init -q
git -C "$fv_g128_root" config user.name "Bubbles Fixture"
git -C "$fv_g128_root" config user.email "fixture@example.invalid"
git -C "$fv_g128_root" add VERSION install.sh bubbles/scripts/cli.sh agents/bubbles.workflow.agent.md
git -C "$fv_g128_root" commit -q -m "fixture repository"
fv_g128_entry="$fv_g128_root/bubbles/scripts/framework-validate.sh"
fv_g128_guard="$fv_g128_root/bubbles/scripts/session-cap-guard.sh"
fv_g128_guard_baseline="$fv_g128_root/session-cap-guard.baseline.sh"
cp "$fv_g128_guard" "$fv_g128_guard_baseline"

set +e
fv_g128_preflight_output="$(bash "$fv_g128_root/bubbles/scripts/repository-binding.sh" preflight \
  --session-id host-current \
  --session-control-file "$fv_g128_control_file" \
  --expected-control-revision 0 \
  --request-class TARGETLESS_MODE \
  --workspace-root "$fv_g128_root" \
  --repository-root "$fv_g128_root" 2>&1)"
fv_g128_preflight_rc=$?
set -e
if [[ "$fv_g128_preflight_rc" -ne 0 ]]; then
  printf 'framework-validate-tier-selftest: BUG-037 binding preflight failed (exit=%s)\n%s\n' \
    "$fv_g128_preflight_rc" "$fv_g128_preflight_output" >&2
  exit 2
fi
fv_g128_packet_json=""
while IFS= read -r fv_g128_preflight_line; do
  case "$fv_g128_preflight_line" in
    \{*) fv_g128_packet_json="$fv_g128_preflight_line" ;;
  esac
done <<<"$fv_g128_preflight_output"
if [[ -z "$fv_g128_packet_json" ]]; then
  printf 'framework-validate-tier-selftest: BUG-037 preflight emitted no actionable packet\n' >&2
  exit 2
fi
printf '%s\n' "$fv_g128_packet_json" >"$fv_g128_packet_file"
chmod 600 "$fv_g128_packet_file"

cat > "$fv_g128_shim/bash" <<EOF
#!$fv_g128_real_bash
set -euo pipefail
if [[ "\${1:-}" == "$fv_g128_guard" ]]; then
  exec "$fv_g128_real_bash" "\$@"
fi
exit 0
EOF
chmod 700 "$fv_g128_shim/bash"

cat > "$fv_g128_shim/env" <<EOF
#!$fv_g128_real_bash
set -euo pipefail
for arg in "\$@"; do
  if [[ "\$arg" == "$fv_g128_guard" ]]; then
    exec "$fv_g128_real_env" "\$@"
  fi
done
exit 0
EOF
chmod 700 "$fv_g128_shim/env"

run_fv_g128_case() {
  local case_name="$1"
  local session_id="$2"
  local tier="${3:-full}"
  local log_file="$fv_g128_root/$case_name.log"
  local rc
  set +e
  PATH="$fv_g128_shim:$PATH" \
    BUBBLES_FRAMEWORK_VALIDATE_MODE=downstream \
    BUBBLES_FRAMEWORK_VALIDATE_LOCK_HELD=1 \
    BUBBLES_FRAMEWORK_VALIDATE_DEPTH=1 \
    BUBBLES_SESSION_ID="$session_id" \
    BUBBLES_SESSION_CONTROL_FILE="$fv_g128_control_file" \
    BUBBLES_BINDING_PACKET_FILE="$fv_g128_packet_file" \
    "$fv_g128_real_bash" "$fv_g128_entry" "--tier=$tier" >"$log_file" 2>&1
  rc=$?
  set -e
  printf '%s' "$rc"
}

show_fv_g128_failure_log() {
  local case_name="$1"
  printf '%s\n' "--- BUG-037 framework live G128 $case_name log ---"
  if ! grep -n -E 'Session cap guard \(live, G128\)|G128|Framework check' "$fv_g128_root/$case_name.log"; then
    printf '%s\n' 'no live G128 diagnostics found'
  fi
  printf '%s\n' "--- end BUG-037 framework live G128 $case_name log ---"
}

cat > "$fv_g128_root/.specify/memory/bubbles.session.json" <<'JSON'
{
  "sessionBudget": { "maxTotalConvergenceIterations": 1 },
  "sessionBudgetHistory": [{
    "recordSchemaVersion": 1,
    "hostSessionId": "host-current",
    "revision": 1,
    "supersedesRevision": null,
    "recordedAt": "2026-09-01T00:00:00Z",
    "budget": { "schemaVersion": 1, "maxTotalConvergenceIterations": 2 }
  }],
  "convergenceLoops": [
    { "hostSessionId": "host-old", "specDir": "specs/old", "agent": "bubbles.goal", "iterationCount": 99 },
    { "hostSessionId": "host-current", "specDir": "specs/current", "agent": "bubbles.goal", "iterationCount": 1 }
  ]
}
JSON
for fv_g128_tier in core full; do
  fv_g128_pass_case="pass-$fv_g128_tier"
  fv_g128_pass_rc="$(run_fv_g128_case "$fv_g128_pass_case" host-current "$fv_g128_tier")"
  if [[ "$fv_g128_pass_rc" -eq 0 ]] &&
    grep -Fq 'G128 status=PASS exit=0 session="host-current"' "$fv_g128_root/$fv_g128_pass_case.log" &&
    grep -Fq 'Framework check PASS G128 status=PASS exit=0 source=guard' "$fv_g128_root/$fv_g128_pass_case.log" &&
    grep -Fq 'PASS: Session cap guard (live, G128)' "$fv_g128_root/$fv_g128_pass_case.log"; then
    pass "BUG-037 framework $fv_g128_tier tier forwards one exact host session to live G128"
  else
    fail "BUG-037 framework $fv_g128_tier tier should pass host-current only (exit=$fv_g128_pass_rc)"
    show_fv_g128_failure_log "$fv_g128_pass_case"
  fi
done

cat > "$fv_g128_root/.specify/memory/bubbles.session.json" <<'JSON'
{
  "sessionBudgetHistory": [{
    "recordSchemaVersion": 1,
    "hostSessionId": "host-current",
    "revision": 1,
    "supersedesRevision": null,
    "recordedAt": "2026-09-01T00:00:00Z",
    "budget": { "schemaVersion": 1, "maxTotalConvergenceIterations": 2 }
  }],
  "convergenceLoops": [
    { "hostSessionId": "host-current", "specDir": "specs/current", "agent": "bubbles.goal", "iterationCount": 3 }
  ]
}
JSON
fv_g128_breach_rc="$(run_fv_g128_case breach host-current)"
if [[ "$fv_g128_breach_rc" -eq 1 ]] &&
  grep -Fq 'G128 status=BREACH exit=1 session="host-current"' "$fv_g128_root/breach.log" &&
  grep -Fq 'Framework check FAIL G128 status=BREACH exit=1 source=guard' "$fv_g128_root/breach.log" &&
  ! grep -Fq 'G128 INPUT-ERROR' "$fv_g128_root/breach.log"; then
  pass "BUG-037 framework validation preserves child exit 1 as BREACH"
else
  fail "BUG-037 framework live G128 should preserve BREACH/1 (exit=$fv_g128_breach_rc)"
  show_fv_g128_failure_log breach
fi

cat > "$fv_g128_root/.specify/memory/bubbles.session.json" <<'JSON'
{
  "sessionBudgetHistory": [{
    "recordSchemaVersion": 1,
    "hostSessionId": "host-current",
    "revision": 1,
    "supersedesRevision": null,
    "recordedAt": "2026-09-01T00:00:00Z",
    "budget": { "schemaVersion": 1, "maxTotalConvergenceIterations": 2 }
  }],
  "convergenceLoops": [
    { "hostSessionId": "host-current", "specDir": "specs/current", "agent": "bubbles.goal", "iterationCount": 1 }
  ]
}
JSON
fv_g128_input_rc="$(run_fv_g128_case input-error '')"
if [[ "$fv_g128_input_rc" -eq 1 ]] &&
  grep -Fq 'Framework check FAIL G128 status=INPUT-ERROR exit=2 source=caller reason=invalid-authority' "$fv_g128_root/input-error.log" &&
  ! grep -Eq '^G128 status=' "$fv_g128_root/input-error.log"; then
  pass "BUG-037 framework validation rejects missing authority before G128 invocation"
else
  fail "BUG-037 framework live G128 should reject missing authority inside aggregate failure (exit=$fv_g128_input_rc)"
  show_fv_g128_failure_log input-error
fi

fv_g128_invocation_sentinel="$fv_g128_root/g128-invoked"
cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=PASS exit=0 session="host-other"'
exit 0
EOF
chmod 700 "$fv_g128_guard"
rm -f "$fv_g128_invocation_sentinel"
fv_g128_session_mismatch_rc="$(run_fv_g128_case session-mismatch host-other)"
if [[ "$fv_g128_session_mismatch_rc" -eq 1 ]] &&
  grep -Fq 'Framework check FAIL G128 status=INPUT-ERROR exit=2 source=caller reason=invalid-authority' "$fv_g128_root/session-mismatch.log" &&
  [[ ! -e "$fv_g128_invocation_sentinel" ]]; then
  pass "BUG-037 framework validation rejects packet/session mismatch before G128 invocation"
else
  fail "BUG-037 framework live G128 should reject packet/session mismatch before invocation (exit=$fv_g128_session_mismatch_rc)"
  show_fv_g128_failure_log session-mismatch
fi

stage_fv_g128_output_case() {
  local case_name="$1"
  case "$case_name" in
    empty)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'diagnostic-without-final'
exit 0
EOF
      ;;
    duplicate)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=PASS exit=0 session="host-current"'
printf '%s\n' 'G128 status=PASS exit=0 session="host-current"'
exit 0
EOF
      ;;
    contradictory)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=PASS exit=1 session="host-current"'
exit 1
EOF
      ;;
    malformed)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=PASS exit=0 session="host-current" extra=bad'
exit 0
EOF
      ;;
    unknown)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=UNKNOWN exit=0 session="host-current"'
exit 0
EOF
      ;;
    mismatched)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=PASS exit=0 session="host-other"'
exit 0
EOF
      ;;
  esac
  chmod 700 "$fv_g128_guard"
}

for fv_g128_output_case in empty duplicate contradictory malformed unknown mismatched; do
  stage_fv_g128_output_case "$fv_g128_output_case"
  rm -f "$fv_g128_invocation_sentinel"
  fv_g128_output_rc="$(run_fv_g128_case "output-$fv_g128_output_case" host-current)"
  if [[ "$fv_g128_output_rc" -eq 1 ]] &&
    grep -Fq 'Framework check FAIL G128 status=INPUT-ERROR exit=2 source=caller reason=invalid-child-result' "$fv_g128_root/output-$fv_g128_output_case.log" &&
    ! grep -Eq '^G128 status=' "$fv_g128_root/output-$fv_g128_output_case.log" &&
    [[ -f "$fv_g128_invocation_sentinel" ]] &&
    [[ "$(wc -l <"$fv_g128_invocation_sentinel")" -eq 1 ]]; then
    pass "BUG-037 framework validation rejects $fv_g128_output_case child output after one invocation"
  else
    fail "BUG-037 framework live G128 should reject $fv_g128_output_case child output (exit=$fv_g128_output_rc)"
    show_fv_g128_failure_log "output-$fv_g128_output_case"
  fi
done

cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=INPUT-ERROR exit=2 session="host-current" reason=fixture-input'
exit 2
EOF
chmod 700 "$fv_g128_guard"
rm -f "$fv_g128_invocation_sentinel"
fv_g128_valid_input_rc="$(run_fv_g128_case valid-input-error host-current)"
if [[ "$fv_g128_valid_input_rc" -eq 1 ]] &&
  grep -Fq 'G128 status=INPUT-ERROR exit=2 session="host-current" reason=fixture-input' "$fv_g128_root/valid-input-error.log" &&
  grep -Fq 'Framework check FAIL G128 status=INPUT-ERROR exit=2 source=guard' "$fv_g128_root/valid-input-error.log"; then
  pass "BUG-037 framework validation preserves a valid child INPUT-ERROR and exit 2 pair"
else
  fail "BUG-037 framework live G128 should preserve valid INPUT-ERROR/2 (exit=$fv_g128_valid_input_rc)"
  show_fv_g128_failure_log valid-input-error
fi

stage_fv_g128_availability_case() {
  local case_name="$1"
  rm -rf "$fv_g128_guard"
  case "$case_name" in
    missing) ;;
    symlink) ln -s "$fv_g128_guard_baseline" "$fv_g128_guard" ;;
    non-regular) mkdir "$fv_g128_guard" ;;
    non-executable)
      cp "$fv_g128_guard_baseline" "$fv_g128_guard"
      chmod 600 "$fv_g128_guard"
      ;;
    replaced)
      cat >"$fv_g128_guard" <<EOF
#!/usr/bin/env bash
cp "$fv_g128_guard_baseline" session-cap-guard.replacement
chmod 700 session-cap-guard.replacement
mv session-cap-guard.replacement session-cap-guard.sh
printf 'invoked\n' >>"$fv_g128_invocation_sentinel"
printf '%s\n' 'G128 status=PASS exit=0 session="host-current"'
exit 0
EOF
      chmod 700 "$fv_g128_guard"
      ;;
  esac
}

for fv_g128_availability_case in missing symlink non-regular non-executable replaced; do
  stage_fv_g128_availability_case "$fv_g128_availability_case"
  rm -f "$fv_g128_invocation_sentinel"
  fv_g128_availability_rc="$(run_fv_g128_case "availability-$fv_g128_availability_case" host-current)"
  if [[ "$fv_g128_availability_rc" -eq 1 ]] &&
    grep -Fq 'Framework check FAIL G128 status=INPUT-ERROR exit=2 source=caller reason=guard-unavailable' "$fv_g128_root/availability-$fv_g128_availability_case.log" &&
    ! grep -Eq '^G128 status=' "$fv_g128_root/availability-$fv_g128_availability_case.log"; then
    pass "BUG-037 framework validation rejects a $fv_g128_availability_case G128 guard"
  else
    fail "BUG-037 framework live G128 should reject a $fv_g128_availability_case guard (exit=$fv_g128_availability_rc)"
    show_fv_g128_failure_log "availability-$fv_g128_availability_case"
  fi
done

rm -rf "$fv_g128_root" "$fv_g128_binding_root"

if [[ "$failures" -eq 0 ]]; then
  echo "[framework-validate-tier-selftest] OK"
else
  echo "[framework-validate-tier-selftest] $failures failed"
  exit 1
fi
