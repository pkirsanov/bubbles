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

if [[ "$failures" -eq 0 ]]; then
  echo "[framework-validate-tier-selftest] OK"
else
  echo "[framework-validate-tier-selftest] $failures failed"
  exit 1
fi
