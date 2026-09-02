#!/usr/bin/env bash
# bubbles/scripts/evidence-capture-selftest.sh
#
# Hermetic selftest for evidence-capture.sh (IMP-036 SCOPE-6).
#
# The load-bearing property is case 5: --verify must FAIL when the command's
# output changes. If a recorded hash cannot detect drift, the compact form is
# weaker than the transcript it replaces and must not ship.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$SCRIPT_DIR/evidence-capture.sh"
NAME="evidence-capture-selftest"
FOCUSED_CONTROL="${1:-}"

case "$FOCUSED_CONTROL" in
  '' | --reg-ec-status-01 | --sec-precommit-helper-01 | --sec-precommit-label-01) ;;
  *)
    printf '%s: unsupported focused control: %s\n' "$NAME" "$FOCUSED_CONTROL" >&2
    exit 2
    ;;
esac
[[ $# -le 1 ]] || {
  printf '%s: focused controls accept no additional arguments\n' "$NAME" >&2
  exit 2
}

failures=0
checks=0
ok() { checks=$((checks + 1)); printf '  ok   %s\n' "$1"; }
bad() {
  checks=$((checks + 1)); failures=$((failures + 1))
  printf '  FAIL %s\n' "$1"; [[ $# -gt 1 ]] && printf '       %s\n' "$2"
}

SELFTEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-evidence-capture-selftest.XXXXXXXX")" || exit 2
cleanup_selftest() {
  rm -rf "$SELFTEST_TMP"
}
trap cleanup_selftest EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

run_reg_ec_status_01_control() {
  local child="$SELFTEST_TMP/reg-ec-status-01-child.sh"
  local failing_marker="$SELFTEST_TMP/reg-ec-status-01-failing-child-ran"
  local positive_marker="$SELFTEST_TMP/reg-ec-status-01-positive-child-ran"
  local failing_out=""
  local positive_out=""
  local failing_rc=0
  local positive_rc=0
  local failing_receipt_fields=0
  local failing_verify_hints=0
  local positive_exit_fields=0
  local positive_line_fields=0
  local positive_verify_hints=0

  cat >"$child" <<'RECEIPT_CHILD'
#!/usr/bin/env bash
printf '%s\n' shadow-counter-child
/usr/bin/touch "$1"
RECEIPT_CHILD
  chmod 700 "$child"

  set +e
  failing_out="$(SHADOW_COUNTER_STATUS=47 "$BASH" -c '
    grep() {
      if [[ "$#" -eq 2 && "$1" == "-c" && -z "$2" ]]; then
        printf "%s\n" 1
        return "$SHADOW_COUNTER_STATUS"
      fi
      command grep "$@"
    }
    export -f grep
    exec "$1" "$2" -- "$3" "$4"
  ' _ "$BASH" "$TARGET" "$child" "$failing_marker" 2>&1)"
  failing_rc=$?
  positive_out="$(SHADOW_COUNTER_STATUS=0 "$BASH" -c '
    grep() {
      if [[ "$#" -eq 2 && "$1" == "-c" && -z "$2" ]]; then
        printf "%s\n" 1
        return "$SHADOW_COUNTER_STATUS"
      fi
      command grep "$@"
    }
    export -f grep
    exec "$1" "$2" -- "$3" "$4"
  ' _ "$BASH" "$TARGET" "$child" "$positive_marker" 2>&1)"
  positive_rc=$?
  set -e

  failing_receipt_fields="$(printf '%s\n' "$failing_out" | grep -Ec '^(exit|lines|sha256):' || true)"
  failing_verify_hints="$(printf '%s\n' "$failing_out" | grep -c '^<!-- verify:' || true)"
  positive_exit_fields="$(printf '%s\n' "$positive_out" | grep -c '^exit: 0$' || true)"
  positive_line_fields="$(printf '%s\n' "$positive_out" | grep -c '^lines: 1$' || true)"
  positive_verify_hints="$(printf '%s\n' "$positive_out" | grep -c '^<!-- verify:' || true)"
  printf 'REG_EC_STATUS_01_CONTROL failingCounterStatus=47 failingCaptureExit=%s failingReceiptFields=%s failingVerifyHints=%s positiveCounterStatus=0 positiveCaptureExit=%s positiveExitFields=%s positiveLineFields=%s positiveVerifyHints=%s\n' \
    "$failing_rc" "$failing_receipt_fields" "$failing_verify_hints" \
    "$positive_rc" "$positive_exit_fields" "$positive_line_fields" \
    "$positive_verify_hints"

  if [[ -f "$failing_marker" ]] \
    && [[ "$failing_rc" -ne 0 ]] \
    && [[ "$failing_receipt_fields" -eq 0 ]] \
    && [[ "$failing_verify_hints" -eq 0 ]] \
    && [[ -f "$positive_marker" ]] \
    && [[ "$positive_rc" -eq 0 ]] \
    && [[ "$positive_exit_fields" -eq 1 ]] \
    && [[ "$positive_line_fields" -eq 1 ]] \
    && [[ "$positive_verify_hints" -eq 1 ]] \
    && printf '%s\n' "$positive_out" | grep -qx shadow-counter-child; then
    ok "REG-EC-STATUS-01 rejects failed numeric counter output and accepts the same successful count"
  else
    bad "REG-EC-STATUS-01 rejects failed numeric counter output and accepts the same successful count" \
      "failingChild=$([[ -f "$failing_marker" ]] && printf yes || printf no) positiveChild=$([[ -f "$positive_marker" ]] && printf yes || printf no) failingOutput=$(printf '%s' "$failing_out" | tr '\n' '|') positiveOutput=$(printf '%s' "$positive_out" | tr '\n' '|')"
  fi
}

run_sec_precommit_helper_01_case() {
  local mode="$1"
  local expected_digest="$2"
  local child="$3"
  local shadow_marker="$SELFTEST_TMP/sec-precommit-helper-01-$mode-shadow-ran"
  local child_marker="$SELFTEST_TMP/sec-precommit-helper-01-$mode-child-ran"
  local output=""
  local capture_status=0
  local receipt_fields=0
  local verify_hints=0
  local shadow_ran="no"
  local fail_closed="no"
  local trusted_receipt="no"

  set +e
  output="$(SHADOW_MODE="$mode" SHADOW_MARKER="$shadow_marker" \
    SHADOW_FORGED_DIGEST=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
    "$BASH" -c '
      shadow_counter() {
        if [[ "$#" -eq 2 && "$1" == "-c" && -z "$2" ]]; then
          /usr/bin/touch "$SHADOW_MARKER"
          printf "%s\n" 41
          return 0
        fi
        command grep "$@"
      }
      shadow_sha256sum() {
        /usr/bin/touch "$SHADOW_MARKER"
        /bin/cat >/dev/null
        printf "%s  -\n" "$SHADOW_FORGED_DIGEST"
        return 0
      }
      shadow_shasum() {
        /usr/bin/touch "$SHADOW_MARKER"
        /bin/cat >/dev/null
        printf "%s  -\n" "$SHADOW_FORGED_DIGEST"
        return 0
      }
      shadow_awk() {
        /usr/bin/touch "$SHADOW_MARKER"
        /bin/cat >/dev/null
        printf "%s\n" "$SHADOW_FORGED_DIGEST"
        return 0
      }
      case "$SHADOW_MODE" in
        counter)
          eval "grep() { shadow_counter \"\$@\"; }"
          export -f shadow_counter grep
          ;;
        hash)
          eval "sha256sum() { shadow_sha256sum \"\$@\"; }"
          eval "shasum() { shadow_shasum \"\$@\"; }"
          eval "awk() { shadow_awk \"\$@\"; }"
          export -f shadow_sha256sum shadow_shasum shadow_awk sha256sum shasum awk
          ;;
        combined)
          eval "grep() { shadow_counter \"\$@\"; }"
          eval "sha256sum() { shadow_sha256sum \"\$@\"; }"
          eval "shasum() { shadow_shasum \"\$@\"; }"
          eval "awk() { shadow_awk \"\$@\"; }"
          export -f shadow_counter shadow_sha256sum shadow_shasum shadow_awk \
            grep sha256sum shasum awk
          ;;
        *) exit 2 ;;
      esac
      exec "$1" "$2" -- "$3" "$4"
    ' _ "$BASH" "$TARGET" "$child" "$child_marker" 2>&1)"
  capture_status=$?
  set -e

  [[ -f "$shadow_marker" ]] && shadow_ran="yes"
  receipt_fields="$(printf '%s\n' "$output" | grep -Ec '^(exit|lines|sha256):' || true)"
  verify_hints="$(printf '%s\n' "$output" | grep -c '^<!-- verify:' || true)"
  if [[ "$capture_status" -ne 0 && "$receipt_fields" -eq 0 && "$verify_hints" -eq 0 ]]; then
    fail_closed="yes"
  fi
  if [[ "$capture_status" -eq 0 && "$shadow_ran" == no \
    && "$receipt_fields" -eq 3 && "$verify_hints" -eq 1 ]] \
    && printf '%s\n' "$output" | grep -q '^exit: 0$' \
    && printf '%s\n' "$output" | grep -q '^lines: 2$' \
    && printf '%s\n' "$output" | grep -q "^sha256: $expected_digest$" \
    && printf '%s\n' "$output" | grep -qx 'helper-shadow-alpha' \
    && printf '%s\n' "$output" | grep -qx 'helper-shadow-beta'; then
    trusted_receipt="yes"
  fi

  printf 'SEC_PRECOMMIT_HELPER_01_CASE mode=%s captureExit=%s childRan=%s shadowRan=%s receiptFields=%s verifyHints=%s failClosed=%s trustedReceipt=%s\n' \
    "$mode" "$capture_status" \
    "$([[ -f "$child_marker" ]] && printf yes || printf no)" \
    "$shadow_ran" "$receipt_fields" "$verify_hints" "$fail_closed" \
    "$trusted_receipt"
  if [[ -f "$child_marker" ]] \
    && [[ "$fail_closed" == yes || "$trusted_receipt" == yes ]]; then
    return 0
  fi
  printf 'SEC_PRECOMMIT_HELPER_01_OUTPUT mode=%s output=%s\n' \
    "$mode" "$(printf '%s' "$output" | tr '\n' '|')"
  return 1
}

run_sec_precommit_helper_01_bash_env_case() {
  local mode="$1"
  local expected_digest="$2"
  local bash_env="$3"
  local child="$4"
  local startup_record="$SELFTEST_TMP/sec-precommit-helper-01-$mode-startups"
  local shadow_record="$SELFTEST_TMP/sec-precommit-helper-01-$mode-shadow-calls"
  local output=""
  local capture_status=0
  local startup_count=0
  local shadow_count=0
  local child_semantics="no"
  local trusted_receipt="no"

  : >"$startup_record"
  : >"$shadow_record"
  set +e
  output="$(BASH_ENV="$bash_env" SEC_HELPER_ATTACK_MODE="$mode" \
    SEC_HELPER_STARTUP_RECORD="$startup_record" \
    SEC_HELPER_SHADOW_RECORD="$shadow_record" \
    SEC_HELPER_FORGED_DIGEST=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa \
    "$BASH" "$TARGET" -- "$BASH" "$child" 2>&1)"
  capture_status=$?
  set -e

  startup_count="$(wc -l <"$startup_record" | tr -d '[:space:]')"
  shadow_count="$(wc -l <"$shadow_record" | tr -d '[:space:]')"
  if printf '%s\n' "$output" | grep -qx 'helper-child-bash-env=intended'; then
    child_semantics="yes"
  fi
  if [[ "$capture_status" -eq 23 && "$shadow_count" -eq 0 ]] \
    && printf '%s\n' "$output" | grep -q '^exit: 23$' \
    && printf '%s\n' "$output" | grep -q '^lines: 2$' \
    && printf '%s\n' "$output" | grep -q "^sha256: $expected_digest$" \
    && printf '%s\n' "$output" | grep -qx 'helper-child-exit=23'; then
    trusted_receipt="yes"
  fi

  printf 'SEC_PRECOMMIT_HELPER_01_BASH_ENV mode=%s captureExit=%s startupCount=%s childSemantics=%s shadowCalls=%s trustedReceipt=%s\n' \
    "$mode" "$capture_status" "$startup_count" "$child_semantics" \
    "$shadow_count" "$trusted_receipt"
  if [[ "$startup_count" -ge 2 && "$child_semantics" == yes \
    && "$trusted_receipt" == yes ]]; then
    return 0
  fi
  printf 'SEC_PRECOMMIT_HELPER_01_BASH_ENV_OUTPUT mode=%s output=%s\n' \
    "$mode" "$(printf '%s' "$output" | tr '\n' '|')"
  return 1
}

run_sec_precommit_helper_01_control() {
  local child="$SELFTEST_TMP/sec-precommit-helper-01-child.sh"
  local known_output="$SELFTEST_TMP/sec-precommit-helper-01-known-output"
  local expected_digest=""
  local mode=""
  local failed_cases=0
  local bash_env="$SELFTEST_TMP/sec-precommit-helper-01.bash-env"
  local bash_env_child="$SELFTEST_TMP/sec-precommit-helper-01-bash-env-child.sh"
  local bash_env_known_output="$SELFTEST_TMP/sec-precommit-helper-01-bash-env-known-output"
  local bash_env_expected_digest=""
  local positive_marker="$SELFTEST_TMP/sec-precommit-helper-01-positive-child-ran"
  local positive_output=""
  local positive_status=0

  cat >"$child" <<'HELPER_CHILD'
#!/usr/bin/env bash
printf '%s\n' helper-shadow-alpha helper-shadow-beta
/usr/bin/touch "$1"
HELPER_CHILD
  chmod 700 "$child"
  printf '%s\n' helper-shadow-alpha helper-shadow-beta >"$known_output"
  if [[ -x /usr/bin/sha256sum ]]; then
    read -r expected_digest _ < <(/usr/bin/sha256sum "$known_output")
  elif [[ -x /usr/bin/shasum ]]; then
    read -r expected_digest _ < <(/usr/bin/shasum -a 256 "$known_output")
  else
    printf '%s\n' 'SEC_PRECOMMIT_HELPER_01_HARNESS trusted SHA-256 utility unavailable'
    return 2
  fi
  [[ "$expected_digest" =~ ^[0-9a-f]{64}$ ]] || return 2

  for mode in counter hash combined; do
    if ! run_sec_precommit_helper_01_case "$mode" "$expected_digest" "$child"; then
      failed_cases=$((failed_cases + 1))
    fi
  done

  cat >"$bash_env" <<'HOSTILE_BASH_ENV'
#!/usr/bin/env bash
printf 'startup=%s mode=%s\n' "$$" "${SEC_HELPER_ATTACK_MODE:-missing}" \
  >>"$SEC_HELPER_STARTUP_RECORD"
helper_shadow_mark() {
  printf 'helper=%s mode=%s\n' "$1" "$SEC_HELPER_ATTACK_MODE" \
    >>"$SEC_HELPER_SHADOW_RECORD"
}
helper_count_shadow() {
  local helper_name="$1"
  shift
  if [[ "$SEC_HELPER_ATTACK_MODE" == metadata \
    || "$SEC_HELPER_ATTACK_MODE" == combined ]]; then
    helper_shadow_mark "$helper_name"
    printf '%s\n' 41
    return 0
  fi
  command "$helper_name" "$@"
}
helper_hash_shadow() {
  local helper_name="$1"
  shift
  if [[ "$SEC_HELPER_ATTACK_MODE" == metadata \
    || "$SEC_HELPER_ATTACK_MODE" == combined ]]; then
    helper_shadow_mark "$helper_name"
    /bin/cat >/dev/null
    printf '%s  -\n' "$SEC_HELPER_FORGED_DIGEST"
    return 0
  fi
  command "$helper_name" "$@"
}
function /usr/bin/grep { helper_count_shadow /usr/bin/grep "$@"; }
function /bin/grep { helper_count_shadow /bin/grep "$@"; }
function /usr/bin/sha256sum { helper_hash_shadow /usr/bin/sha256sum "$@"; }
function /bin/sha256sum { helper_hash_shadow /bin/sha256sum "$@"; }
function /usr/bin/shasum { helper_hash_shadow /usr/bin/shasum "$@"; }
grep() { helper_count_shadow /usr/bin/grep "$@"; }
sha256sum() { helper_hash_shadow /usr/bin/sha256sum "$@"; }
shasum() { helper_hash_shadow /usr/bin/shasum "$@"; }
wait() {
  local observed_status=0
  if [[ "$SEC_HELPER_ATTACK_MODE" == lifecycle \
    || "$SEC_HELPER_ATTACK_MODE" == combined ]]; then
    builtin wait "$@"
    observed_status=$?
    helper_shadow_mark "wait:$observed_status"
    return 0
  fi
  builtin wait "$@"
}
kill() {
  if [[ "$SEC_HELPER_ATTACK_MODE" == lifecycle \
    || "$SEC_HELPER_ATTACK_MODE" == combined ]]; then
    helper_shadow_mark "kill:${1:-missing}"
    [[ "${1:-}" == -0 ]] && return 1
    return 0
  fi
  builtin kill "$@"
}
export SEC_HELPER_CHILD_SEMANTIC=intended
export -f helper_shadow_mark helper_count_shadow helper_hash_shadow
export -f grep sha256sum shasum wait kill
HOSTILE_BASH_ENV
  chmod 700 "$bash_env"
  cat >"$bash_env_child" <<'BASH_ENV_CHILD'
#!/usr/bin/env bash
[[ "${SEC_HELPER_CHILD_SEMANTIC:-}" == intended ]] || exit 97
printf '%s\n' 'helper-child-bash-env=intended' 'helper-child-exit=23'
exit 23
BASH_ENV_CHILD
  chmod 700 "$bash_env_child"
  printf '%s\n' 'helper-child-bash-env=intended' 'helper-child-exit=23' \
    >"$bash_env_known_output"
  if [[ -x /usr/bin/sha256sum ]]; then
    read -r bash_env_expected_digest _ < <(/usr/bin/sha256sum "$bash_env_known_output")
  elif [[ -x /usr/bin/shasum ]]; then
    read -r bash_env_expected_digest _ < <(/usr/bin/shasum -a 256 "$bash_env_known_output")
  else
    printf '%s\n' 'SEC_PRECOMMIT_HELPER_01_HARNESS trusted SHA-256 utility unavailable'
    return 2
  fi
  [[ "$bash_env_expected_digest" =~ ^[0-9a-f]{64}$ ]] || return 2

  for mode in metadata lifecycle combined; do
    if ! run_sec_precommit_helper_01_bash_env_case \
      "$mode" "$bash_env_expected_digest" "$bash_env" "$bash_env_child"; then
      failed_cases=$((failed_cases + 1))
    fi
  done

  set +e
  positive_output="$("$BASH" "$TARGET" -- "$child" "$positive_marker" 2>&1)"
  positive_status=$?
  set -e
  printf 'SEC_PRECOMMIT_HELPER_01_POSITIVE captureExit=%s childRan=%s\n' \
    "$positive_status" "$([[ -f "$positive_marker" ]] && printf yes || printf no)"
  if [[ "$positive_status" -ne 0 || ! -f "$positive_marker" ]] \
    || ! printf '%s\n' "$positive_output" | grep -q '^exit: 0$' \
    || ! printf '%s\n' "$positive_output" | grep -q '^lines: 2$' \
    || ! printf '%s\n' "$positive_output" | grep -q "^sha256: $expected_digest$"; then
    printf 'SEC_PRECOMMIT_HELPER_01_POSITIVE_OUTPUT=%s\n' \
      "$(printf '%s' "$positive_output" | tr '\n' '|')"
    return 2
  fi
  if [[ "$failed_cases" -eq 0 ]]; then
    ok "SEC-PRECOMMIT-HELPER-01 preserves trusted parent receipts across hostile startup while retaining child BASH_ENV semantics"
    return 0
  fi
  bad "SEC-PRECOMMIT-HELPER-01 preserves trusted parent receipts across hostile startup while retaining child BASH_ENV semantics" \
    "failedCases=$failed_cases"
  return 1
}

run_sec_precommit_label_01_case() {
  local mode="$1"
  local label="$2"
  local child="$3"
  local child_marker="$SELFTEST_TMP/sec-precommit-label-01-$mode-child-ran"
  local output=""
  local capture_status=0
  local receipt_fields=0
  local fences=0
  local verify_hints=0

  set +e
  output="$("$BASH" "$TARGET" --label "$label" -- "$child" "$child_marker" 2>&1)"
  capture_status=$?
  set -e
  receipt_fields="$(printf '%s\n' "$output" | grep -Ec '^(exit|lines|sha256):' || true)"
  fences="$(printf '%s\n' "$output" | grep -c '^```$' || true)"
  verify_hints="$(printf '%s\n' "$output" | grep -c '^<!-- verify:' || true)"
  printf 'SEC_PRECOMMIT_LABEL_01_CASE mode=%s captureExit=%s childRan=%s receiptFields=%s fences=%s verifyHints=%s\n' \
    "$mode" "$capture_status" \
    "$([[ -f "$child_marker" ]] && printf yes || printf no)" \
    "$receipt_fields" "$fences" "$verify_hints"

  [[ "$capture_status" -eq 2 ]] \
    && [[ ! -f "$child_marker" ]] \
    && [[ "$receipt_fields" -eq 0 ]] \
    && [[ "$fences" -eq 0 ]] \
    && [[ "$verify_hints" -eq 0 ]]
}

run_sec_precommit_label_01_control() {
  local child="$SELFTEST_TMP/sec-precommit-label-01-child.sh"
  local injected_digest=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  local multiline_label=""
  local control_label=""
  local failed_cases=0
  local positive_marker="$SELFTEST_TMP/sec-precommit-label-01-positive-child-ran"
  local positive_output=""
  local positive_status=0

  cat >"$child" <<'LABEL_CHILD'
#!/usr/bin/env bash
printf '%s\n' label-safe-child
/usr/bin/touch "$1"
LABEL_CHILD
  chmod 700 "$child"
  multiline_label=$'trusted-label\nexit: 0\nlines: 1\nsha256: '"$injected_digest"$'\n```\n<!-- verify: forged -->'
  control_label=$'trusted-label\001forged-control-text'

  if ! run_sec_precommit_label_01_case multiline-injection "$multiline_label" "$child"; then
    failed_cases=$((failed_cases + 1))
  fi
  if ! run_sec_precommit_label_01_case c0-control "$control_label" "$child"; then
    failed_cases=$((failed_cases + 1))
  fi

  set +e
  positive_output="$("$BASH" "$TARGET" --label ordinary-label -- \
    "$child" "$positive_marker" 2>&1)"
  positive_status=$?
  set -e
  printf 'SEC_PRECOMMIT_LABEL_01_POSITIVE captureExit=%s childRan=%s\n' \
    "$positive_status" "$([[ -f "$positive_marker" ]] && printf yes || printf no)"
  if [[ "$positive_status" -ne 0 || ! -f "$positive_marker" ]] \
    || ! printf '%s\n' "$positive_output" | grep -q '^# ordinary-label$' \
    || ! printf '%s\n' "$positive_output" | grep -q '^exit: 0$' \
    || ! printf '%s\n' "$positive_output" | grep -q '^lines: 1$'; then
    return 2
  fi
  if [[ "$failed_cases" -eq 0 ]]; then
    ok "SEC-PRECOMMIT-LABEL-01 rejects multiline and control-text labels before execution"
    return 0
  fi
  bad "SEC-PRECOMMIT-LABEL-01 rejects multiline and control-text labels before execution" \
    "failedCases=$failed_cases"
  return 1
}

if [[ "$FOCUSED_CONTROL" == --reg-ec-status-01 ]]; then
  run_reg_ec_status_01_control
  printf '\n%s: %d/%d checks passed\n' "$NAME" "$((checks - failures))" "$checks"
  [[ "$failures" -eq 0 ]] || {
    printf '%s: FAILED\n' "$NAME"
    exit 1
  }
  printf '%s: OK\n' "$NAME"
  exit 0
fi
if [[ "$FOCUSED_CONTROL" == --sec-precommit-helper-01 ]]; then
  run_sec_precommit_helper_01_control
  printf '\n%s: %d/%d checks passed\n' "$NAME" "$((checks - failures))" "$checks"
  [[ "$failures" -eq 0 ]] || {
    printf '%s: FAILED\n' "$NAME"
    exit 1
  }
  printf '%s: OK\n' "$NAME"
  exit 0
fi
if [[ "$FOCUSED_CONTROL" == --sec-precommit-label-01 ]]; then
  run_sec_precommit_label_01_control
  printf '\n%s: %d/%d checks passed\n' "$NAME" "$((checks - failures))" "$checks"
  [[ "$failures" -eq 0 ]] || {
    printf '%s: FAILED\n' "$NAME"
    exit 1
  }
  printf '%s: OK\n' "$NAME"
  exit 0
fi

# --- 1. records command, exit code and hash ----------------------------------
out="$(bash "$TARGET" --label "demo" -- printf 'a\nb\nc\n' 2>&1)"
if printf '%s' "$out" | grep -q '^exit: 0$' &&
  printf '%s' "$out" | grep -q '^lines: 3$' &&
  printf '%s' "$out" | grep -qE '^sha256: [0-9a-f]{64}$'; then
  ok "records command, exit code, line count and a sha256"
else
  bad "records the basics" "$(printf '%s' "$out" | tr '\n' '|')"
fi

# --- 2. short output is shown in full ----------------------------------------
if printf '%s' "$out" | grep -q -- '--- output ---' &&
  printf '%s' "$out" | grep -qx 'b'; then
  ok "short output is emitted in full, not truncated"
else
  bad "short output shown in full" "$(printf '%s' "$out" | tr '\n' '|')"
fi

# --- 3. long output is head/tail trimmed with an explicit omission note -------
long="$(bash "$TARGET" --lines 2 -- seq 1 50 2>&1)"
if printf '%s' "$long" | grep -q -- '--- first 2 ---' &&
  printf '%s' "$long" | grep -q 'omitted 46 line(s)' &&
  printf '%s' "$long" | grep -q -- '--- last 2 ---'; then
  ok "long output is trimmed and states how many lines were omitted"
else
  bad "long output trimmed" "$(printf '%s' "$long" | tr '\n' '|')"
fi

# --- 4. a FAILING command still produces evidence and propagates its code -----
set +e
fail_out="$(bash "$TARGET" -- sh -c 'echo boom; exit 7' 2>&1)"
rc=$?
set -e
if [[ "$rc" -eq 7 ]] && printf '%s' "$fail_out" | grep -q '^exit: 7$' &&
  printf '%s' "$fail_out" | grep -qx 'boom'; then
  ok "failing command still emits evidence and propagates exit 7"
else
  bad "failing command evidence" "rc=$rc $(printf '%s' "$fail_out" | tr '\n' '|')"
fi

# --- 4a. BUG-046 RED: successful empty output is one canonical zero count ---
# BSD grep prints 0 and exits 1 for an empty input. The capture wrapper must
# consume the count as data rather than append a fallback zero based on grep's
# status. This assertion intentionally checks the complete receipt shape so the
# current duplicate-zero/arithmetic-diagnostic defect cannot pass.
set +e
empty_success_out="$(bash "$TARGET" -- true 2>&1)"
empty_success_rc=$?
set -e
empty_success_line_fields="$(printf '%s\n' "$empty_success_out" | grep -c '^lines: 0$' || true)"
empty_success_standalone_zeros="$(printf '%s\n' "$empty_success_out" | grep -c '^0$' || true)"
empty_success_diagnostics="$(printf '%s\n' "$empty_success_out" | grep -Ec 'arithmetic syntax error|error token is' || true)"
empty_success_output_markers="$(printf '%s\n' "$empty_success_out" | grep -c '^--- output ---$' || true)"
empty_success_fences="$(printf '%s\n' "$empty_success_out" | grep -c '^```$' || true)"
if [[ "$empty_success_rc" -eq 0 ]] \
  && [[ "$empty_success_line_fields" -eq 1 ]] \
  && [[ "$empty_success_standalone_zeros" -eq 0 ]] \
  && [[ "$empty_success_diagnostics" -eq 0 ]] \
  && [[ "$empty_success_output_markers" -eq 1 ]] \
  && [[ "$empty_success_fences" -eq 2 ]] \
  && printf '%s\n' "$empty_success_out" | grep -q '^sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855$'; then
  ok "successful zero-output capture emits one canonical empty receipt"
else
  bad "successful zero-output capture emits one canonical empty receipt" \
    "rc=$empty_success_rc lineFields=$empty_success_line_fields standaloneZeros=$empty_success_standalone_zeros arithmeticDiagnostics=$empty_success_diagnostics outputMarkers=$empty_success_output_markers fences=$empty_success_fences $(printf '%s' "$empty_success_out" | tr '\n' '|')"
fi

# --- 4b. ADVERSARIAL: empty output must not overwrite a nonzero child status -
# A repair that special-cases `true` or forces every empty capture to exit zero
# would satisfy 4a while corrupting failure evidence. Exercise the same empty
# stream with a distinct child status and require the identical receipt shape.
set +e
empty_failure_out="$(bash "$TARGET" -- bash -c 'exit 9' 2>&1)"
empty_failure_rc=$?
set -e
empty_failure_line_fields="$(printf '%s\n' "$empty_failure_out" | grep -c '^lines: 0$' || true)"
empty_failure_standalone_zeros="$(printf '%s\n' "$empty_failure_out" | grep -c '^0$' || true)"
empty_failure_diagnostics="$(printf '%s\n' "$empty_failure_out" | grep -Ec 'arithmetic syntax error|error token is' || true)"
empty_failure_output_markers="$(printf '%s\n' "$empty_failure_out" | grep -c '^--- output ---$' || true)"
if [[ "$empty_failure_rc" -eq 9 ]] \
  && printf '%s\n' "$empty_failure_out" | grep -q '^exit: 9$' \
  && [[ "$empty_failure_line_fields" -eq 1 ]] \
  && [[ "$empty_failure_standalone_zeros" -eq 0 ]] \
  && [[ "$empty_failure_diagnostics" -eq 0 ]] \
  && [[ "$empty_failure_output_markers" -eq 1 ]]; then
  ok "zero-output failure preserves the child status and canonical receipt"
else
  bad "zero-output failure preserves the child status and canonical receipt" \
    "rc=$empty_failure_rc lineFields=$empty_failure_line_fields standaloneZeros=$empty_failure_standalone_zeros arithmeticDiagnostics=$empty_failure_diagnostics outputMarkers=$empty_failure_output_markers $(printf '%s' "$empty_failure_out" | tr '\n' '|')"
fi

# --- 4c. PRE-EC-01 RED: line-counter failure invalidates the receipt ---------
# The child can succeed while the receipt's own line counter fails. A blank
# `lines:` field plus exit 0 is evidence-shaped output with no valid cardinality.
# Export the failing command into only the target process so this selftest's
# own assertions retain a working grep.
counter_failure_child_marker="$SELFTEST_TMP/pre-ec-01-child-ran"
set +e
counter_failure_out="$($BASH -c '
  grep() { return 47; }
  export -f grep
  exec "$1" "$2" -- /usr/bin/touch "$3"
' _ "$BASH" "$TARGET" "$counter_failure_child_marker" 2>&1)"
counter_failure_rc=$?
set -e
counter_failure_blank_lines="$(printf '%s\n' "$counter_failure_out" | grep -Ec '^lines:[[:space:]]*$' || true)"
counter_failure_verify_hints="$(printf '%s\n' "$counter_failure_out" | grep -c '^<!-- verify:' || true)"
if [[ -f "$counter_failure_child_marker" ]] \
  && [[ "$counter_failure_rc" -ne 0 ]] \
  && [[ "$counter_failure_blank_lines" -eq 0 ]] \
  && [[ "$counter_failure_verify_hints" -eq 0 ]]; then
  ok "PRE-EC-01 line-counter failure fails loud without a valid-looking receipt"
else
  bad "PRE-EC-01 line-counter failure fails loud without a valid-looking receipt" \
    "childRan=$([[ -f "$counter_failure_child_marker" ]] && printf yes || printf no) rc=$counter_failure_rc blankLineFields=$counter_failure_blank_lines verifyHints=$counter_failure_verify_hints $(printf '%s' "$counter_failure_out" | tr '\n' '|')"
fi

# --- 4d. REG-EC-STATUS-01: numeric output cannot erase counter failure -------
run_reg_ec_status_01_control

# --- 4e. SECURITY RED: ambient helpers cannot forge receipt metadata ---------
run_sec_precommit_helper_01_control

# --- 4f. SECURITY RED: label text cannot enter the receipt namespace ----------
run_sec_precommit_label_01_control

# --- 5. ADVERSARIAL: --verify must DETECT changed output ---------------------
# Without this, the hash is decoration and the compact form would be weaker than
# a transcript.
digest="$(bash "$TARGET" -- printf 'stable\n' 2>&1 | awk '/^sha256: /{print $2}')"
set +e
bash "$TARGET" --verify "$digest" -- printf 'stable\n' >/dev/null 2>&1
same_rc=$?
bash "$TARGET" --verify "$digest" -- printf 'CHANGED\n' >/dev/null 2>&1
diff_rc=$?
set -e
if [[ "$same_rc" -eq 0 && "$diff_rc" -eq 3 ]]; then
  ok "--verify passes on identical output and FAILS (3) when it changes"
else
  bad "--verify detects drift" "same=$same_rc changed=$diff_rc (want 0 and 3)"
fi

# --- 6. stderr is captured, not dropped --------------------------------------
err_out="$(bash "$TARGET" -- sh -c 'echo to-stderr >&2' 2>&1)"
if printf '%s' "$err_out" | grep -qx 'to-stderr'; then
  ok "stderr is interleaved into the evidence, not discarded"
else
  bad "stderr captured" "$(printf '%s' "$err_out" | tr '\n' '|')"
fi

# --- 7. bypass-shaped flags are refused --------------------------------------
set +e
bash "$TARGET" --fake -- true >/dev/null 2>&1
rc=$?
set -e
if [[ "$rc" -eq 2 ]]; then
  ok "bypass-shaped flag refused with exit 2"
else
  bad "bypass flag refused" "exit was $rc"
fi

# --- 8. a missing command is a usage error -----------------------------------
set +e
bash "$TARGET" --label x >/dev/null 2>&1
rc=$?
set -e
if [[ "$rc" -eq 2 ]]; then
  ok "no command after -- is a usage error"
else
  bad "missing command is usage error" "exit was $rc"
fi

# --- 9. emits a re-runnable verify hint --------------------------------------
if printf '%s' "$out" | grep -q '<!-- verify: bash bubbles/scripts/evidence-capture.sh --verify'; then
  ok "block carries a re-runnable verify command"
else
  bad "verify hint emitted" "$(printf '%s' "$out" | tr '\n' '|')"
fi

# --- 9a. PRE-EC-02 RED: rendered commands preserve exact argv semantics ------
# Each case is passed safely to the target first. Replaying the displayed
# command must produce byte-identical argv output, and replaying the verify hint
# must verify that same digest without executing metacharacters. Isolating the
# cases makes empty, whitespace, quote, newline, and substitution failures
# independently observable instead of allowing one parse error to hide another.
argv_helper="$SELFTEST_TMP/pre-ec-02-argv-helper.sh"
cat >"$argv_helper" <<'ARGV_HELPER'
#!/usr/bin/env bash
set -uo pipefail
printf 'ARGC=%s\n' "$#"
argument_index=1
for argument_value in "$@"; do
  argument_hex="$(printf '%s' "$argument_value" | od -An -tx1 | tr -d ' \n')"
  printf 'ARGV_%s_HEX=%s\n' "$argument_index" "$argument_hex"
  argument_index=$((argument_index + 1))
done
ARGV_HELPER
chmod 700 "$argv_helper"

semicolon_marker="$SELFTEST_TMP/pre-ec-02-semicolon-executed"
substitution_marker="$SELFTEST_TMP/pre-ec-02-substitution-executed"
printf -v semicolon_marker_quoted '%q' "$semicolon_marker"
printf -v substitution_marker_quoted '%q' "$substitution_marker"
replay_case_names=(empty whitespace-semicolon quotes newline substitution)
replay_case_values=(
  ''
  "alpha beta;/usr/bin/touch $semicolon_marker_quoted"
  'single'\'' and "double" quotes'
  $'line one\nline two'
  "\$(/usr/bin/touch $substitution_marker_quoted)"
)
replay_case_markers=(
  ''
  "$semicolon_marker"
  ''
  ''
  "$substitution_marker"
)
replay_failures=0
replay_side_effects=0
for ((replay_index = 0; replay_index < ${#replay_case_names[@]}; replay_index++)); do
  replay_name="${replay_case_names[$replay_index]}"
  replay_value="${replay_case_values[$replay_index]}"
  replay_marker="${replay_case_markers[$replay_index]}"
  [[ -z "$replay_marker" ]] || rm -f "$replay_marker"
  expected_argv="$($BASH "$argv_helper" "$replay_value")"
  receipt="$($BASH "$TARGET" -- "$argv_helper" "$replay_value" 2>&1)"
  displayed_command="$(printf '%s\n' "$receipt" | awk '/^\$ / { sub(/^\$ /, ""); print; exit }')"
  verify_command="$(printf '%s\n' "$receipt" | awk '/^<!-- verify: / { sub(/^<!-- verify: /, ""); sub(/ -->$/, ""); print; exit }')"
  set +e
  displayed_output="$($BASH -c "$displayed_command" 2>&1)"
  displayed_status=$?
  displayed_side_effect=0
  if [[ -n "$replay_marker" && -e "$replay_marker" ]]; then
    displayed_side_effect=1
    rm -f "$replay_marker"
  fi
  verify_output="$($BASH -c "$verify_command" 2>&1)"
  verify_status=$?
  verify_side_effect=0
  if [[ -n "$replay_marker" && -e "$replay_marker" ]]; then
    verify_side_effect=1
    rm -f "$replay_marker"
  fi
  set -e
  displayed_match=no
  verify_match=no
  side_effect_count=$((displayed_side_effect + verify_side_effect))
  [[ "$displayed_status" -eq 0 && "$displayed_output" == "$expected_argv" ]] && displayed_match=yes
  if [[ "$verify_status" -eq 0 ]] \
    && printf '%s\n' "$verify_output" | grep -q '^\[evidence-capture\] VERIFIED - output still hashes to [0-9a-f]\{64\}$' \
    && ! printf '%s\n' "$verify_output" | grep -q '^\[evidence-capture\] MISMATCH$'; then
    verify_match=yes
  fi
  printf 'PRE_EC_02_CASE name=%s displayedStatus=%s displayedMatch=%s displayedSideEffect=%s verifyStatus=%s verifyMatch=%s verifySideEffect=%s sideEffects=%s\n' \
    "$replay_name" "$displayed_status" "$displayed_match" \
    "$displayed_side_effect" "$verify_status" "$verify_match" \
    "$verify_side_effect" "$side_effect_count"
  if [[ "$displayed_match" != yes || "$verify_match" != yes || "$side_effect_count" -ne 0 ]]; then
    replay_failures=$((replay_failures + 1))
  fi
  replay_side_effects=$((replay_side_effects + side_effect_count))
done
if [[ "$replay_failures" -eq 0 && "$replay_side_effects" -eq 0 ]]; then
  ok "PRE-EC-02 displayed command and verify hint preserve exact argv bytes"
else
  bad "PRE-EC-02 displayed command and verify hint preserve exact argv bytes" \
    "failedCases=$replay_failures sideEffects=$replay_side_effects totalCases=${#replay_case_names[@]}"
fi

# --- 10. ADVERSARIAL: a failure line inside the omitted region survives -------
# The whole case for preferring the bounded block over a transcript collapses if
# trimming can swallow the line that explains the exit code. Line 4 of 7 falls
# strictly inside the omitted middle at --lines 2.
mid_fail="$(bash "$TARGET" --lines 2 -- sh -c 'echo a; echo b; echo c; echo "FAIL: buried signal"; echo d; echo e; echo f' 2>&1)"
if printf '%s' "$mid_fail" | grep -q -- '--- failure-shaped lines from the omitted region ---' &&
  printf '%s' "$mid_fail" | grep -q 'FAIL: buried signal'; then
  ok "a failure line in the omitted region is lifted out, not swallowed"
else
  bad "omitted-region failure line surfaced" "$(printf '%s' "$mid_fail" | tr '\n' '|')"
fi

# --- 11. clean long output gains no failure section --------------------------
# Guards case 10 against the opposite defect: a section that always appears
# proves nothing about detection.
clean_long="$(bash "$TARGET" --lines 2 -- seq 1 20 2>&1)"
if ! printf '%s' "$clean_long" | grep -q -- 'failure-shaped lines'; then
  ok "clean output emits no failure section"
else
  bad "clean output emits no failure section" "$(printf '%s' "$clean_long" | tr '\n' '|')"
fi

# --- 12. the diagnostic escalation is explicit, stamped, and still bounded ----
# SCOPE-7's decision was one default plus a per-invocation escalation, NOT a
# second verbosity mode. These cases hold that line: opting in must be visible
# in the block, and it must not become an unbounded transcript paste.
diag="$(bash "$TARGET" --diagnostic -- seq 1 6 2>&1)"
if printf '%s' "$diag" | grep -q '^escalation: diagnostic' &&
  printf '%s' "$diag" | grep -qx '4'; then
  ok "--diagnostic emits the full output and stamps the escalation"
else
  bad "--diagnostic stamps and emits" "$(printf '%s' "$diag" | tr '\n' '|')"
fi

if ! printf '%s' "$out" | grep -q '^escalation:'; then
  ok "a normal capture carries no escalation stamp"
else
  bad "normal capture is unstamped" "$(printf '%s' "$out" | tr '\n' '|')"
fi

# --- 13. ADVERSARIAL: the escalation still has a ceiling ---------------------
# "Unbounded on request" is exactly how a bounded default erodes back into the
# paste it replaced.
big="$(bash "$TARGET" --diagnostic -- seq 1 2500 2>&1)"
big_lines="$(printf '%s' "$big" | grep -c '')"
if printf '%s' "$big" | grep -q 'diagnostic ceiling' &&
  printf '%s' "$big" | grep -q 'omitted 500 line(s) beyond the diagnostic ceiling' &&
  [[ "$big_lines" -lt 2500 ]]; then
  ok "--diagnostic remains bounded by a stated ceiling"
else
  bad "--diagnostic bounded by ceiling" "emitted $big_lines line(s)"
fi

# --- 14. ADVERSARIAL: TERM stops the child tree and preserves partial evidence -
# A timeout signals the wrapper while its child is running. The child below
# cannot exit unless the wrapper forwards TERM; the outer deadline prevents a
# broken implementation from hanging this selftest forever.
#
# The deadline is a BACKSTOP and must not rewrite the command's exit code: the
# assertions below require the 143 the child's own `kill -TERM "$PPID"`
# produces. guard-lib's bubbles_run_with_timeout is deliberately NOT used here
# because it normalizes 143 to 124 to match GNU timeout, which would mask
# exactly the signal this case exists to observe. Bare `timeout` is not an
# option either -- stock macOS ships none, and it exited 127 here.
run_with_deadline() {
  local secs="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout --kill-after=1 "$secs" "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout --kill-after=1 "$secs" "$@"
  else
    # alarm(2) survives exec, so the deadline still applies while the exec'd
    # command keeps its own exit status.
    /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' "$secs" "$@"
  fi
}
set +e
# PPID expands inside the child shell.
# shellcheck disable=SC2016
term_out="$(run_with_deadline 5 bash "$TARGET" -- bash -c 'trap '\''printf "child-terminated\n"; exit 0'\'' TERM; printf "before-signal\n"; kill -TERM "$PPID"; while :; do :; done' 2>&1)"
term_rc=$?
set -e
if [[ "$term_rc" -eq 143 ]] &&
  printf '%s' "$term_out" | grep -q '^exit: 143$' &&
  printf '%s' "$term_out" | grep -qE '^sha256: [0-9a-f]{64}$' &&
  printf '%s' "$term_out" | grep -qx 'before-signal' &&
  printf '%s' "$term_out" | grep -qx 'child-terminated' &&
  ! printf '%s' "$term_out" | grep -q 'No such file or directory'; then
  ok "TERM stops the child process group and emits preserved interrupted evidence"
else
  bad "TERM stops children and preserves interrupted evidence" "rc=$term_rc $(printf '%s' "$term_out" | tr '\n' '|')"
fi

# --- 15. ADVERSARIAL: a completed parent cannot leave a descendant behind ---
# Nested wrappers can exit before a background lock holder. Evidence capture
# owns the complete command tree, so returning to the caller must also mean the
# process group has drained.
descendant_pid_file="$(mktemp)"
set +e
# Positional parameters expand inside the child shell.
# shellcheck disable=SC2016
descendant_out="$(run_with_deadline 5 bash "$TARGET" -- bash -c 'bash -c '\''trap "exit 0" TERM; while :; do :; done'\'' & printf "%s\n" "$!" >"$1"' _ "$descendant_pid_file" 2>&1)"
descendant_rc=$?
set -e
descendant_pid="$(cat "$descendant_pid_file")"
rm -f "$descendant_pid_file"
if [[ "$descendant_rc" -eq 0 ]] &&
  printf '%s' "$descendant_out" | grep -q '^exit: 0$' &&
  [[ "$descendant_pid" =~ ^[0-9]+$ ]] &&
  ! kill -0 "$descendant_pid" 2>/dev/null; then
  ok "completed commands leave no background descendant behind"
else
  if [[ "$descendant_pid" =~ ^[0-9]+$ ]]; then
    kill -KILL "$descendant_pid" 2>/dev/null || true
  fi
  bad "completed command tree cleanup" "rc=$descendant_rc pid=$descendant_pid $(printf '%s' "$descendant_out" | tr '\n' '|')"
fi

# --- 16. ADVERSARIAL: capture-file loss fails loud, never emits an empty hash -
# A concurrent validator once removed a generic /tmp/tmp.* capture while the
# child ran. The wrapper then emitted exit 1, lines 0, and a blank sha256 — an
# evidence-shaped result that proved nothing. The child receives only the
# private path so this fixture can reproduce that deletion deterministically.
set +e
missing_out="$(bash "$TARGET" -- bash -c 'rm -f "$BUBBLES_EVIDENCE_CAPTURE_OUTPUT_PATH"' 2>&1)"
missing_rc=$?
set -e
if [[ "$missing_rc" -eq 2 ]] &&
  printf '%s' "$missing_out" | grep -q 'capture output disappeared during command execution' &&
  ! printf '%s' "$missing_out" | grep -q '^sha256:[[:space:]]*$'; then
  ok "capture-file loss fails loud without emitting an empty evidence hash"
else
  bad "capture-file loss fails loud" "rc=$missing_rc $(printf '%s' "$missing_out" | tr '\n' '|')"
fi

printf '\n%s: %d/%d checks passed\n' "$NAME" "$((checks - failures))" "$checks"
if [[ "$failures" -gt 0 ]]; then
  printf '%s: FAILED\n' "$NAME"
  exit 1
fi
printf '%s: OK\n' "$NAME"
exit 0
