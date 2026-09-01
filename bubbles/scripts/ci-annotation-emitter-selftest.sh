#!/usr/bin/env bash
# ci-annotation-emitter-selftest.sh — hermetic selftest for the GitHub Actions
# `::error::` annotation emitter (OW-002).
#
# WHY THIS EXISTS
# ---------------
# A red macOS `release-hygiene-macos` job could not be attributed to a specific
# failing check from an unprivileged machine: `GET /actions/jobs/<id>/logs`
# requires repo ADMIN and answers 403. Check-run ANNOTATIONS have no such
# requirement — `GET /repos/<owner>/<repo>/check-runs/<id>/annotations` answered
# UNAUTHENTICATED on 2026-08-07. So `bubbles_ci_annotate_failure` emits one
# annotation per failing check, making every future failure attributable with
# ZERO credentials.
#
# The emitter is ADDITIVE (the plain `FAIL: <label>` line other tooling parses
# is untouched) and GATED on GITHUB_ACTIONS, so local runs are unchanged.
#
# HOW THIS AVOIDS BEING TAUTOLOGICAL
# ----------------------------------
# Cases A-E do NOT re-implement run_check. They EXTRACT the real `run_check`
# body from the shipped release-check.sh and eval it against the real
# guard-lib.sh, so deleting the emitter CALL from release-check.sh, or the
# emitter FUNCTION from guard-lib.sh, makes them fail.
#
# Case B (no GITHUB_ACTIONS => no annotation) and Case E (a PASSING check emits
# no annotation) are the assertions that stop this from passing no matter what:
# an emitter that fired unconditionally would satisfy A, C and D but fail B and E.
#
# Case F generalizes: EVERY `echo "FAIL: ` site in the two production scripts
# must be annotated, so a NEW unannotated FAIL site added later is also caught.
#
# NOTE ON OUTPUT: this selftest never prints a raw `::error::` line. Doing so
# would make GitHub attach a bogus annotation to a PASSING run. Diagnostics are
# emitted with the `::` masked.
# shellcheck disable=SC2016 # Single-quoted printf/grep text intentionally emits or matches literal shell source.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD_LIB="$SCRIPT_DIR/guard-lib.sh"
RELEASE_CHECK="$SCRIPT_DIR/release-check.sh"
FRAMEWORK_VALIDATE="$SCRIPT_DIR/framework-validate.sh"

failures=0
pass() { printf '  PASS  %s\n' "$1"; }
fail() {
  printf '  FAIL  %s\n' "$1"
  failures=$((failures + 1))
}

# Mask `::` so diagnostics can quote captured output without GitHub parsing it
# as a real workflow command.
masked() { printf '%s' "$1" | sed 's/::/;;/g'; }

for required in "$GUARD_LIB" "$RELEASE_CHECK" "$FRAMEWORK_VALIDATE"; do
  if [[ ! -f "$required" ]]; then
    printf 'ci-annotation-emitter-selftest: FAIL: required file missing: %s\n' "$required" >&2
    exit 1
  fi
done

# shellcheck source=/dev/null
source "$GUARD_LIB"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

# --- Build a harness around the REAL run_check from release-check.sh ---------
# Extracting the shipped function (rather than restating it) is what gives the
# cases below teeth: remove `bubbles_ci_annotate_failure` from release-check.sh
# and A/C/D stop observing an annotation.
sed -n '/^run_check() {/,/^}/p' "$RELEASE_CHECK" >"$TMP/run_check.body"

if [[ ! -s "$TMP/run_check.body" ]] || ! grep -q 'echo "FAIL: \$label"' "$TMP/run_check.body"; then
  fail "could not extract run_check() from release-check.sh (shape changed?)"
  printf 'ci-annotation-emitter-selftest: %d failure(s)\n' "$failures"
  exit 1
fi

{
  printf '#!/usr/bin/env bash\n'
  printf 'set -uo pipefail\n'
  printf 'source "%s"\n' "$GUARD_LIB"
  printf 'failures=0\n'
  cat "$TMP/run_check.body"
  printf 'run_check "$1" bash -c "exit $2"\n'
  printf 'exit 0\n'
} >"$TMP/harness.sh"

OUT="$TMP/out.txt"

# run_harness <ci|local> <label> <exit-code>
run_harness() {
  local mode="$1" label="$2" rc="$3"
  if [[ "$mode" == "ci" ]]; then
    GITHUB_ACTIONS=true bash "$TMP/harness.sh" "$label" "$rc" >"$OUT" 2>&1
  else
    # Explicitly REMOVE the variable. This selftest itself runs inside GitHub
    # Actions, where GITHUB_ACTIONS is already true, so inheriting it would
    # silently invert Case B.
    env -u GITHUB_ACTIONS bash "$TMP/harness.sh" "$label" "$rc" >"$OUT" 2>&1
  fi
}

annotation_count() { grep -c '^::error::' "$OUT" 2>/dev/null || true; }
annotation_line() { grep '^::error::' "$OUT" 2>/dev/null | head -n1 || true; }

LABEL='Release manifest freshness'

# --- Case A: failing check under GITHUB_ACTIONS=true emits a naming annotation
run_harness ci "$LABEL" 1
count="$(annotation_count)"
line="$(annotation_line)"
if [[ "$count" == "1" ]] && printf '%s' "$line" | grep -Fq "$LABEL"; then
  pass "GITHUB_ACTIONS=true: failing check emits 1 annotation naming the check"
else
  fail "expected 1 annotation naming '$LABEL', got count=$count line=[$(masked "$line")]"
fi

# --- Case C1: the plain FAIL line survives in CI mode (additive, not replacing)
if grep -Fq "FAIL: $LABEL" "$OUT"; then
  pass "GITHUB_ACTIONS=true: plain 'FAIL: <label>' line still emitted"
else
  fail "plain 'FAIL: $LABEL' line missing under GITHUB_ACTIONS=true"
fi

# --- Case B: NO GITHUB_ACTIONS => NO annotation (local output unchanged) ------
run_harness local "$LABEL" 1
count="$(annotation_count)"
if [[ "$count" == "0" ]]; then
  pass "GITHUB_ACTIONS unset: no annotation emitted (local output unchanged)"
else
  fail "expected 0 annotations without GITHUB_ACTIONS, got $count: [$(masked "$(annotation_line)")]"
fi

# --- Case C2: the plain FAIL line is still emitted locally --------------------
if grep -Fq "FAIL: $LABEL" "$OUT"; then
  pass "GITHUB_ACTIONS unset: plain 'FAIL: <label>' line still emitted"
else
  fail "plain 'FAIL: $LABEL' line missing with GITHUB_ACTIONS unset"
fi

# --- Case E (adversarial): a PASSING check emits NO annotation, even in CI ----
# Without this, an emitter that fired on every check would still pass A/C/D.
run_harness ci "$LABEL" 0
count="$(annotation_count)"
if [[ "$count" == "0" ]] && grep -Fq "PASS: $LABEL" "$OUT"; then
  pass "GITHUB_ACTIONS=true: passing check emits no annotation"
else
  fail "passing check emitted $count annotation(s) or lost its PASS line"
fi

# --- Case D (adversarial): '%' and newline are escaped, raw form absent -------
# A raw newline would split the workflow command across two lines (truncating
# it and allowing a forged second command); a raw '%' corrupts the payload.
ADV_LABEL='pct-100%-done
second-line'
run_harness ci "$ADV_LABEL" 1
count="$(annotation_count)"
line="$(annotation_line)"

if [[ "$count" == "1" ]]; then
  pass "escaping: embedded newline did not split the annotation (exactly 1 line)"
else
  fail "expected exactly 1 annotation line for a multi-line label, got $count"
fi

if printf '%s' "$line" | grep -Fq 'pct-100%25-done%0Asecond-line'; then
  pass "escaping: '%' -> %25 and LF -> %0A both applied"
else
  fail "expected escaped 'pct-100%25-done%0Asecond-line', got [$(masked "$line")]"
fi

# The raw, unescaped percent sequence must NOT survive into the annotation.
if printf '%s' "$line" | grep -Fq 'pct-100%-done'; then
  fail "raw unescaped '%' leaked into the annotation: [$(masked "$line")]"
else
  pass "escaping: raw unescaped '%' form absent from the annotation"
fi

# Double-escaping regression: '%' must be substituted BEFORE %0D/%0A, otherwise
# the '%' those introduce is itself re-escaped into %250A.
if printf '%s' "$line" | grep -Fq '%250'; then
  fail "double-escaped sequence '%250' found; '%' was substituted after CR/LF"
else
  pass "escaping: no double-escaped '%250' sequence (substitution order correct)"
fi

# The plain FAIL line keeps the label VERBATIM (escaping is annotation-only).
if grep -Fq 'FAIL: pct-100%-done' "$OUT"; then
  pass "escaping: plain FAIL line keeps the label verbatim (unescaped)"
else
  fail "plain FAIL line lost the verbatim label"
fi

# --- Case F: every FAIL site in the production scripts is annotated -----------
# Generalizing guard: catches a NEW `echo "FAIL: ` added later without an
# annotation, and catches removal of any existing emitter call.
assert_fail_sites_annotated() {
  local script="$1" name="$2" missing=0 total=0 lineno
  while IFS= read -r lineno; do
    [[ -n "$lineno" ]] || continue
    total=$((total + 1))
    if ! sed -n "$((lineno + 1)),$((lineno + 6))p" "$script" | grep -q 'bubbles_ci_annotate_failure'; then
      missing=$((missing + 1))
      printf '        unannotated FAIL site: %s:%s\n' "$name" "$lineno"
    fi
  done < <(grep -n 'echo "FAIL: ' "$script" | cut -d: -f1)

  if [[ "$total" -eq 0 ]]; then
    fail "$name: found no 'echo \"FAIL: ' site to check (shape changed?)"
    return
  fi
  if [[ "$missing" -eq 0 ]]; then
    pass "$name: all $total FAIL site(s) emit an annotation"
  else
    fail "$name: $missing of $total FAIL site(s) emit no annotation"
  fi
}

assert_fail_sites_annotated "$FRAMEWORK_VALIDATE" "framework-validate.sh"
assert_fail_sites_annotated "$RELEASE_CHECK" "release-check.sh"

# --- Case G: release-check.sh actually sources the lib providing the emitter --
if grep -q 'source "\$SCRIPT_DIR/guard-lib.sh"' "$RELEASE_CHECK"; then
  pass "release-check.sh sources guard-lib.sh (emitter is in scope)"
else
  fail "release-check.sh does not source guard-lib.sh; the emitter would be unbound"
fi

# --- Case H: the emitter is gated on GITHUB_ACTIONS, not on an ad-hoc flag ----
if grep -q 'GITHUB_ACTIONS' "$GUARD_LIB"; then
  pass "emitter gates on GitHub's own GITHUB_ACTIONS signal"
else
  fail "guard-lib.sh does not reference GITHUB_ACTIONS"
fi

# --- Case I: bubbles_ci_failure_detail (OW-002 phase 2) ----------------------
# Naming WHICH check failed is not enough to diagnose a macOS-only failure when
# the raw job log is 403 admin-only. The annotation must also carry WHY, so
# run_check captures the check's output under CI and feeds the failure-shaped
# lines to the annotation.
#
# The harness runs under `set -euo pipefail` — the SAME regime as
# framework-validate.sh — not under this selftest's laxer `set -uo pipefail`.
# That is what gives I5/I6 teeth: a helper whose pipeline returns 1 when grep
# matches nothing aborts its caller on exactly the "fall back to the bare
# label" path the helper documents, and an inline call here would not notice.
{
  printf '#!/usr/bin/env bash\n'
  printf 'set -euo pipefail\n'
  printf 'source "%s"\n' "$GUARD_LIB"
  printf 'bubbles_ci_failure_detail "$1"\n'
  printf 'printf "HARNESS-SURVIVED\\n"\n'
} >"$TMP/detail-harness.sh"

# run_detail <fixture-path>  -> stdout+stderr in $OUT, exit status in $DETAIL_RC
run_detail() {
  bash "$TMP/detail-harness.sh" "$1" >"$OUT" 2>&1
  DETAIL_RC=$?
}

# detail_lines: emitted lines EXCLUDING the harness survival marker.
detail_lines() { grep -cv '^HARNESS-SURVIVED$' "$OUT" 2>/dev/null || true; }

# Fixture 1: a real-shaped log interleaving passing and failing lines.
{
  printf 'PASS: sentinel-should-not-appear\n'
  printf 'FAIL: sentinel-assertion-mismatch\n'
  printf 'PASS: another-green-line\n'
  printf 'ERROR: connection refused\n'
} >"$TMP/mixed.log"

run_detail "$TMP/mixed.log"

# --- I1: the FAIL line is surfaced -------------------------------------------
if grep -Fq 'FAIL: sentinel-assertion-mismatch' "$OUT"; then
  pass "failure_detail: surfaces the failing assertion line from a mixed log"
else
  fail "failure_detail: expected the FAIL line, got [$(masked "$(cat "$OUT")")]"
fi

# --- I2 (adversarial): PASS noise is NOT surfaced ----------------------------
# Without this, a helper that simply `cat`ed the whole log would satisfy I1.
if grep -Fq 'PASS: sentinel-should-not-appear' "$OUT"; then
  fail "failure_detail: leaked a PASS line into the detail body"
else
  pass "failure_detail: passing lines absent from the detail body"
fi

# --- I3: output is capped at 10 lines ----------------------------------------
# An uncapped body would blow past GitHub's annotation size limit and could
# push the useful first line out of view.
: >"$TMP/many.log"
for i in {1..25}; do
  printf 'FAIL: assertion number %s\n' "$i" >>"$TMP/many.log"
done
run_detail "$TMP/many.log"
lines="$(detail_lines)"
if [[ "$lines" == "10" ]]; then
  pass "failure_detail: caps output at 10 lines given 25 failure lines"
else
  fail "failure_detail: expected 10 lines from a 25-line failure log, got $lines"
fi

# --- I4: a log with no failure-shaped line yields NO detail -------------------
# The caller keys off empty output to fall back to the bare label.
{
  printf 'PASS: everything is fine\n'
  printf 'ok 1 - nothing to see here\n'
} >"$TMP/clean.log"
run_detail "$TMP/clean.log"
lines="$(detail_lines)"
if [[ "$lines" == "0" ]]; then
  pass "failure_detail: emits nothing when the log has no failure-shaped line"
else
  fail "failure_detail: expected no detail for a clean log, got [$(masked "$(cat "$OUT")")]"
fi

# --- I5 (adversarial): the clean-log path must not abort a set -e caller ------
# This is the regression that makes I4 meaningful. `grep | head | cut` returns 1
# under pipefail when grep matches nothing; framework-validate.sh assigns the
# result as the final command of an `&&` list, which `set -e` does NOT exempt.
# Without a guaranteed 0 return, framework-validate would die mid-run on the
# fallback path instead of annotating the bare label.
if [[ "$DETAIL_RC" -eq 0 ]] && grep -Fq 'HARNESS-SURVIVED' "$OUT"; then
  pass "failure_detail: clean log returns 0 and does not abort a set -euo pipefail caller"
else
  fail "failure_detail: clean log aborted the set -e caller (rc=$DETAIL_RC, survived=$(grep -Fc 'HARNESS-SURVIVED' "$OUT" 2>/dev/null || true))"
fi

# --- I6: a non-existent path is silent and non-fatal under set -e -------------
run_detail "$TMP/definitely-not-a-real-file.log"
lines="$(detail_lines)"
if [[ "$DETAIL_RC" -eq 0 ]] && [[ "$lines" == "0" ]] && grep -Fq 'HARNESS-SURVIVED' "$OUT"; then
  pass "failure_detail: missing file emits nothing and does not error under set -e"
else
  fail "failure_detail: missing file misbehaved (rc=$DETAIL_RC, lines=$lines)"
fi

# --- Case J1-J7: run_check capture and complete-process-group semantics --------
# I1-I6 prove the detail helper in isolation. J1-J7 execute the REAL shipped
# run_check body instead of matching an implementation token or replacing it
# with a test double. The probe deliberately does NOT call setpgid or enable job
# control. The shipped runner must create the distinct process group, then own
# the direct probe and its TERM-resistant descendant through bounded KILL.
#
# The contract is strict on both axes: run_check must return promptly without
# waiting for the descendant-held output descriptor, AND it must terminate that
# descendant before returning. The selftest cleans a surviving descendant only
# after recording a contract failure, solely to prevent test residue.
# The probe's numeric exit marker is fixture output used to show that replay is
# ordered and complete. The production runner's durable public result is the
# PASS/FAIL classification and aggregate failure count; it does not expose the
# direct command's numeric status as a separate contract.
sed -n '/^run_check() {/,/^}/p' "$FRAMEWORK_VALIDATE" >"$TMP/fv_run_check.body"

if [[ ! -s "$TMP/fv_run_check.body" ]]; then
  fail "could not extract run_check() from framework-validate.sh (shape changed?)"
else
  fv_capture_tmp="$TMP/fv-capture"
  fv_descendant_pid_file="$TMP/fv-capture-descendant.pid"
  fv_process_group_file="$TMP/fv-capture-process-group.txt"
  fv_harness_pgid_file="$TMP/fv-capture-harness.pgid"
  fv_descendant_ready_file="$TMP/fv-capture-descendant.ready"
  fv_descendant_term_file="$TMP/fv-capture-descendant.term"
  fv_descendant_hold_fifo="$TMP/fv-capture-descendant.hold"
  mkdir -p "$fv_capture_tmp"
  cat >"$TMP/fv-capture-probe.sh" <<'PROBE'
#!/usr/bin/env bash
set -uo pipefail
descendant_pid_file="$1"
process_group_file="$2"
descendant_ready_file="$3"
descendant_term_file="$4"
descendant_hold_fifo="$5"
mkfifo "$descendant_hold_fifo"
(
  exec 7<>"$descendant_hold_fifo"
  trap 'printf "TERM_RECEIVED\n" >"$descendant_term_file"' TERM
  printf '%s\n' 'READY' >"$descendant_ready_file"
  while :; do
    read -r _hold <&7 || true
  done
) &
descendant_pid=$!
ready_wait=0
while [[ ! -f "$descendant_ready_file" && "$ready_wait" -lt 50 ]]; do
  sleep 0.1
  ready_wait=$((ready_wait + 1))
done
probe_pgid="$(/bin/ps -o pgid= -p "$$")"
probe_pgid="${probe_pgid//[[:space:]]/}"
descendant_pgid="$(/bin/ps -o pgid= -p "$descendant_pid")"
descendant_pgid="${descendant_pgid//[[:space:]]/}"
printf '%s\n' "$descendant_pid" >"$descendant_pid_file"
printf '%s|%s|%s|%s\n' "$$" "$probe_pgid" "$descendant_pid" "$descendant_pgid" >"$process_group_file"
printf 'CAPTURE_STDOUT_SENTINEL\n'
printf 'CAPTURE_STDERR_SENTINEL\n' >&2
printf 'ERROR: CAPTURE_DETAIL_SENTINEL\n' >&2
if [[ -f /dev/fd/1 ]]; then
  printf 'CAPTURE_STDOUT_IS_REGULAR=yes\n'
else
  printf 'CAPTURE_STDOUT_IS_REGULAR=no\n'
fi
(exit 37)
direct_rc=$?
printf 'CAPTURE_DIRECT_EXIT=%s\n' "$direct_rc"
exit "$direct_rc"
PROBE
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
    cat "$TMP/fv_run_check.body"
    printf 'fv_harness_pgid="$(/bin/ps -o pgid= -p "$$")"\n'
    printf 'fv_harness_pgid="${fv_harness_pgid//[[:space:]]/}"\n'
    printf 'printf "%%s\\n" "$fv_harness_pgid" >"%s"\n' "$fv_harness_pgid_file"
    printf 'run_check "Framework capture probe" bash "%s" "%s" "%s" "%s" "%s" "%s"\n' \
      "$TMP/fv-capture-probe.sh" "$fv_descendant_pid_file" \
      "$fv_process_group_file" "$fv_descendant_ready_file" "$fv_descendant_term_file" \
      "$fv_descendant_hold_fifo"
    printf 'printf "HARNESS_FAILURES=%%s\\n" "$failures"\n'
    printf 'printf "HARNESS_FAILED_LABELS=%%s\\n" "${failed_check_labels[*]-}"\n'
    printf 'exit 0\n'
  } >"$TMP/fv-capture-harness.sh"

  fv_capture_started=$SECONDS
  if bubbles_run_with_timeout 20 env GITHUB_ACTIONS=true TMPDIR="$fv_capture_tmp" \
    bash "$TMP/fv-capture-harness.sh" >"$OUT" 2>&1; then
    fv_capture_rc=0
  else
    fv_capture_rc=$?
  fi
  fv_capture_elapsed=$((SECONDS - fv_capture_started))
  fv_descendant_pid="$(cat "$fv_descendant_pid_file" 2>/dev/null || true)"
  fv_harness_pgid="$(cat "$fv_harness_pgid_file" 2>/dev/null || true)"
  fv_probe_pid=""
  fv_probe_pgid=""
  fv_recorded_descendant_pid=""
  fv_descendant_pgid=""
  if [[ -f "$fv_process_group_file" ]]; then
    IFS='|' read -r fv_probe_pid fv_probe_pgid fv_recorded_descendant_pid fv_descendant_pgid <"$fv_process_group_file"
  fi
  fv_process_group_integrity="no"
  if [[ "$fv_harness_pgid" =~ ^[0-9]+$ ]] \
    && [[ "$fv_probe_pid" =~ ^[0-9]+$ ]] \
    && [[ "$fv_probe_pgid" =~ ^[0-9]+$ ]] \
    && [[ "$fv_descendant_pid" =~ ^[0-9]+$ ]] \
    && [[ "$fv_recorded_descendant_pid" == "$fv_descendant_pid" ]] \
    && [[ "$fv_descendant_pgid" =~ ^[0-9]+$ ]] \
    && [[ "$fv_probe_pid" == "$fv_probe_pgid" ]] \
    && [[ "$fv_descendant_pgid" == "$fv_probe_pgid" ]] \
    && [[ "$fv_harness_pgid" != "$fv_probe_pgid" ]]; then
    fv_process_group_integrity="yes"
  fi
  if [[ "$fv_process_group_integrity" == "yes" ]]; then
    pass "framework capture probe and descendant share one distinct, runner-ownable process group"
  else
    fail "framework capture probe did not establish an ownable process group (harness=$fv_harness_pgid probe=$fv_probe_pid probeGroup=$fv_probe_pgid descendant=$fv_descendant_pid recordedDescendant=$fv_recorded_descendant_pid descendantGroup=$fv_descendant_pgid)"
  fi

  fv_descendant_alive_after_run_check="no"
  if [[ "$fv_descendant_pid" =~ ^[0-9]+$ ]] && kill -0 "$fv_descendant_pid" 2>/dev/null; then
    fv_descendant_alive_after_run_check="yes"
  fi
  fv_stdout_count="$(grep -Fc 'CAPTURE_STDOUT_SENTINEL' "$OUT" 2>/dev/null || true)"
  fv_stderr_count="$(grep -Fc 'CAPTURE_STDERR_SENTINEL' "$OUT" 2>/dev/null || true)"
  fv_probe_exit_marker_count="$(grep -Fc 'CAPTURE_DIRECT_EXIT=37' "$OUT" 2>/dev/null || true)"
  fv_expected_failure_output="$(
    cat <<'EXPECTED_FAILURE_TRANSCRIPT'
==> Framework capture probe
CAPTURE_STDOUT_SENTINEL
CAPTURE_STDERR_SENTINEL
ERROR: CAPTURE_DETAIL_SENTINEL
CAPTURE_STDOUT_IS_REGULAR=yes
CAPTURE_DIRECT_EXIT=37
FAIL: Framework capture probe
::error::FAIL: Framework capture probe%0AERROR: CAPTURE_DETAIL_SENTINEL

HARNESS_FAILURES=1
HARNESS_FAILED_LABELS=Framework capture probe
EXPECTED_FAILURE_TRANSCRIPT
  )"
  fv_actual_failure_output="$(cat "$OUT")"
  if [[ "$fv_capture_rc" -eq 0 ]] \
    && [[ "$fv_capture_elapsed" -lt 10 ]] \
    && [[ "$fv_stdout_count" -eq 1 ]] \
    && [[ "$fv_stderr_count" -eq 1 ]] \
    && [[ "$fv_probe_exit_marker_count" -eq 1 ]] \
    && [[ "$fv_actual_failure_output" == "$fv_expected_failure_output" ]]; then
    pass "framework-validate.sh run_check preserves ordered probe output and classifies its nonzero direct exit as FAIL"
  else
    fail "framework-validate.sh run_check failure transcript drifted (rc=$fv_capture_rc elapsed=$fv_capture_elapsed stdout=$fv_stdout_count stderr=$fv_stderr_count probeExitMarker=$fv_probe_exit_marker_count actual=$(printf '%q' "$(masked "$fv_actual_failure_output")"))"
  fi

  fv_annotation_count="$(annotation_count)"
  fv_annotation_line="$(annotation_line)"
  if [[ "$fv_annotation_count" -eq 1 ]] \
    && printf '%s' "$fv_annotation_line" | grep -Fq 'Framework capture probe' \
    && printf '%s' "$fv_annotation_line" | grep -Fq 'ERROR: CAPTURE_DETAIL_SENTINEL'; then
    pass "framework-validate.sh run_check annotates with failure detail from the captured output"
  else
    fail "framework-validate.sh capture annotation lost its label or failure detail"
  fi

  fv_term_observed="$(cat "$fv_descendant_term_file" 2>/dev/null || true)"
  if [[ "$fv_term_observed" == "TERM_RECEIVED" ]] \
    && [[ "$fv_capture_elapsed" -ge 3 ]] \
    && [[ "$fv_capture_elapsed" -lt 10 ]]; then
    pass "framework-validate.sh run_check exhausts bounded TERM grace before KILL removes a TERM-resistant descendant"
  else
    fail "framework-validate.sh run_check did not exercise TERM-to-KILL escalation (term=$fv_term_observed elapsed=$fv_capture_elapsed)"
  fi

  fv_selftest_cleanup_required="no"
  if [[ "$fv_descendant_alive_after_run_check" == "no" ]]; then
    pass "framework-validate.sh run_check terminates the adversarial descendant before returning"
  else
    fv_selftest_cleanup_required="yes"
    fail "framework-validate.sh run_check returned while the adversarial descendant was alive; selftest cleanup required"
  fi

  if [[ "$fv_selftest_cleanup_required" == "yes" ]]; then
    if [[ "$fv_process_group_integrity" == "yes" ]]; then
      kill -KILL -- "-$fv_probe_pgid" 2>/dev/null || true
    else
      kill -KILL "$fv_descendant_pid" 2>/dev/null || true
    fi
  fi

  fv_success_output="$TMP/fv-success.output"
  cat >"$TMP/fv-success-probe.sh" <<'SUCCESS_PROBE'
#!/usr/bin/env bash
set -uo pipefail
printf 'SUCCESS_STDOUT_SENTINEL\n'
printf 'SUCCESS_STDERR_SENTINEL\n' >&2
exit 0
SUCCESS_PROBE
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
    cat "$TMP/fv_run_check.body"
    printf 'run_check "Framework success probe" bash "%s"\n' "$TMP/fv-success-probe.sh"
    printf 'printf "SUCCESS_HARNESS_FAILURES=%%s\\n" "$failures"\n'
    printf 'printf "SUCCESS_HARNESS_FAILED_LABELS=%%s\\n" "${failed_check_labels[*]-}"\n'
    printf 'exit 0\n'
  } >"$TMP/fv-success-harness.sh"

  if bubbles_run_with_timeout 10 env GITHUB_ACTIONS=true TMPDIR="$fv_capture_tmp" \
    bash "$TMP/fv-success-harness.sh" >"$fv_success_output" 2>&1; then
    fv_success_rc=0
  else
    fv_success_rc=$?
  fi
  fv_expected_success_output="$(
    cat <<'EXPECTED_SUCCESS_TRANSCRIPT'
==> Framework success probe
SUCCESS_STDOUT_SENTINEL
SUCCESS_STDERR_SENTINEL
PASS: Framework success probe

SUCCESS_HARNESS_FAILURES=0
SUCCESS_HARNESS_FAILED_LABELS=
EXPECTED_SUCCESS_TRANSCRIPT
  )"
  fv_actual_success_output="$(cat "$fv_success_output")"
  fv_success_annotation_count="$(grep -c '^::error::' "$fv_success_output" 2>/dev/null || true)"
  if [[ "$fv_success_rc" -eq 0 ]] \
    && [[ "$fv_success_annotation_count" -eq 0 ]] \
    && [[ "$fv_actual_success_output" == "$fv_expected_success_output" ]]; then
    pass "framework-validate.sh run_check preserves the exact ordered success transcript and emits no annotation"
  else
    fail "framework-validate.sh run_check success transcript drifted (rc=$fv_success_rc annotations=$fv_success_annotation_count actual=[$(masked "$fv_actual_success_output")])"
  fi

  # A direct command may exit zero while the CI runner fails to replay or
  # clean up its owned tree. Force the replay command itself to return nonzero
  # after emitting the captured bytes. The real run_check body must classify
  # that independent tree status as FAIL; removing `_ci_tree_rc` from the PASS
  # predicate makes this control go red while the direct probe remains green.
  fv_tree_status_output="$TMP/fv-tree-status.output"
  cat >"$TMP/fv-tree-status-probe.sh" <<'TREE_STATUS_PROBE'
#!/usr/bin/env bash
set -uo pipefail
printf 'TREE_STATUS_DIRECT_ZERO\n'
exit 0
TREE_STATUS_PROBE
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
    cat "$TMP/fv_run_check.body"
    printf 'cat() { command cat "$@"; return 41; }\n'
    printf 'run_check "Framework tree-status probe" bash "%s"\n' "$TMP/fv-tree-status-probe.sh"
    printf 'printf "TREE_STATUS_HARNESS_FAILURES=%%s\\n" "$failures"\n'
    printf 'printf "TREE_STATUS_HARNESS_FAILED_LABELS=%%s\\n" "${failed_check_labels[*]-}"\n'
    printf 'exit 0\n'
  } >"$TMP/fv-tree-status-harness.sh"

  if bubbles_run_with_timeout 10 env GITHUB_ACTIONS=true TMPDIR="$fv_capture_tmp" \
    bash "$TMP/fv-tree-status-harness.sh" >"$fv_tree_status_output" 2>&1; then
    fv_tree_status_rc=0
  else
    fv_tree_status_rc=$?
  fi
  fv_tree_direct_zero_count="$(grep -Fc 'TREE_STATUS_DIRECT_ZERO' "$fv_tree_status_output" 2>/dev/null || true)"
  fv_tree_replay_error_count="$(grep -Fc 'ERROR: could not replay the captured output for Framework tree-status probe' "$fv_tree_status_output" 2>/dev/null || true)"
  fv_tree_fail_count="$(grep -c '^FAIL: Framework tree-status probe$' "$fv_tree_status_output" 2>/dev/null || true)"
  fv_tree_pass_count="$(grep -c '^PASS: Framework tree-status probe$' "$fv_tree_status_output" 2>/dev/null || true)"
  if [[ "$fv_tree_status_rc" -eq 0 ]] \
    && [[ "$fv_tree_direct_zero_count" -eq 1 ]] \
    && [[ "$fv_tree_replay_error_count" -eq 1 ]] \
    && [[ "$fv_tree_fail_count" -eq 1 ]] \
    && [[ "$fv_tree_pass_count" -eq 0 ]] \
    && grep -Fq 'TREE_STATUS_HARNESS_FAILURES=1' "$fv_tree_status_output" \
    && grep -Fq 'TREE_STATUS_HARNESS_FAILED_LABELS=Framework tree-status probe' "$fv_tree_status_output"; then
    pass "framework-validate.sh run_check rejects replay failure independently of a zero direct exit"
  else
    fail "framework-validate.sh ignored or misclassified replay failure (rc=$fv_tree_status_rc directZero=$fv_tree_direct_zero_count replayError=$fv_tree_replay_error_count fail=$fv_tree_fail_count pass=$fv_tree_pass_count actual=[$(masked "$(cat "$fv_tree_status_output")")])"
  fi

  fv_capture_residue=0
  while IFS= read -r fv_capture_path; do
    [[ -n "$fv_capture_path" ]] || continue
    fv_capture_residue=$((fv_capture_residue + 1))
  done < <(find "$fv_capture_tmp" -mindepth 1 -print)
  fv_descendant_residue="no"
  if [[ "$fv_descendant_pid" =~ ^[0-9]+$ ]]; then
    for _ in 1 2 3 4 5; do
      kill -0 "$fv_descendant_pid" 2>/dev/null || break
      sleep 1
    done
    if kill -0 "$fv_descendant_pid" 2>/dev/null; then
      fv_descendant_residue="yes"
      if [[ "$fv_process_group_integrity" == "yes" ]]; then
        kill -KILL -- "-$fv_probe_pgid" 2>/dev/null || true
      else
        kill -KILL "$fv_descendant_pid" 2>/dev/null || true
      fi
    fi
  fi
  fv_process_group_residue="no"
  if [[ "$fv_probe_pgid" =~ ^[0-9]+$ ]] && kill -0 -- "-$fv_probe_pgid" 2>/dev/null; then
    fv_process_group_residue="yes"
  fi
  if [[ "$fv_capture_residue" -eq 0 ]] \
    && [[ "$fv_descendant_residue" == "no" ]] \
    && [[ "$fv_process_group_residue" == "no" ]]; then
    pass "framework capture leaves no private-file or process-group residue (selftestCleanupRequired=$fv_selftest_cleanup_required)"
  else
    fail "framework capture residue remained (captureFiles=$fv_capture_residue descendant=$fv_descendant_residue processGroup=$fv_process_group_residue selftestCleanupRequired=$fv_selftest_cleanup_required)"
  fi
fi

# --- Case I9-I17: TOOL/INTERPRETER errors must be surfaced, not filtered out --
# WHY (measured). A macOS check failed with
#     awk: line 27: syntax error at or near ,
# That line starts with none of FAIL/ERROR/AssertionError/Traceback/not ok, so
# the shape-1-only extractor dropped it. The annotation then carried only failed
# assertions with empty values, which made a CRASHED INTERPRETER look like code
# that runs but produces wrong content — a mis-signal that cost a long
# investigation. I9-I12 are the regression guards for that exact failure mode.
{
  printf 'PASS: green line that must not appear\n'
  printf 'awk: line 27: syntax error at or near ,\n'
  printf 'jq: error (at <stdin>:0): null (null) has no keys\n'
  printf 'bash: line 3: foo: command not found\n'
  printf '/usr/lib/thing.sh: line 9: MYVAR: unbound variable\n'
  printf 'sed: -i requires an argument\n'
  printf 'ok 2 - benign\n'
} >"$TMP/toolerr.log"
run_detail "$TMP/toolerr.log"

# --- I9: the awk parse error (the measured mis-signal) is surfaced ------------
if grep -Fq 'awk: line 27: syntax error at or near ,' "$OUT"; then
  pass "failure_detail: surfaces an awk interpreter parse error"
else
  fail "failure_detail: dropped the awk parse error, got [$(masked "$(cat "$OUT")")]"
fi

# --- I10: a jq tool error is surfaced ----------------------------------------
if grep -Fq 'jq: error (at <stdin>:0): null' "$OUT"; then
  pass "failure_detail: surfaces a jq tool error"
else
  fail "failure_detail: dropped the jq tool error"
fi

# --- I11: a shell 'command not found' is surfaced ----------------------------
if grep -Fq 'bash: line 3: foo: command not found' "$OUT"; then
  pass "failure_detail: surfaces a shell 'command not found'"
else
  fail "failure_detail: dropped the 'command not found' line"
fi

# --- I12: the phrase branch fires on a line whose first token is NOT a tool ---
# `/usr/lib/thing.sh:` is not in the tool alternation, so only the unanchored
# phrase branch can catch it. Without that branch this assertion goes red.
if grep -Fq '/usr/lib/thing.sh: line 9: MYVAR: unbound variable' "$OUT"; then
  pass "failure_detail: phrase branch catches an error on a non-tool-prefixed line"
else
  fail "failure_detail: dropped an 'unbound variable' line lacking a tool prefix"
fi

# --- I13 (adversarial): benign lines in the SAME log are still NOT surfaced ---
# Without this, widening the regex all the way to `cat` would satisfy I9-I12.
leaked=''
grep -Fq 'PASS: green line that must not appear' "$OUT" && leaked="$leaked [PASS line]"
grep -Fq 'ok 2 - benign' "$OUT" && leaked="$leaked [ok line]"
if [[ -z "$leaked" ]]; then
  pass "failure_detail: benign lines absent from a log full of tool errors"
else
  fail "failure_detail: widened regex leaked benign lines:$leaked"
fi

# --- I14: every pre-existing assertion shape still matches (regression guard) -
# The tool/phrase branches are ADDITIVE. If shape 1 were lost, this goes red
# while I9-I12 stay green.
{
  printf 'Traceback (most recent call last):\n'
  printf 'AssertionError: expected 1 got 0\n'
  printf 'not ok 3 - legacy tap failure\n'
  printf 'ERROR: legacy error line\n'
  printf 'FAIL: legacy fail line\n'
  printf '✗ legacy cross marker\n'
  printf '❌ legacy emoji marker\n'
  printf 'PASS: legacy green line\n'
} >"$TMP/legacy.log"
run_detail "$TMP/legacy.log"
legacy_missing=''
while IFS= read -r want; do
  grep -Fq "$want" "$OUT" || legacy_missing="$legacy_missing [$want]"
done <<'LEGACY_SHAPES'
Traceback (most recent call last):
AssertionError: expected 1 got 0
not ok 3 - legacy tap failure
ERROR: legacy error line
FAIL: legacy fail line
✗ legacy cross marker
❌ legacy emoji marker
LEGACY_SHAPES
if [[ -z "$legacy_missing" ]]; then
  pass "failure_detail: all 7 pre-existing assertion shapes still captured"
else
  fail "failure_detail: lost pre-existing shape(s):$legacy_missing"
fi

# --- I15 (adversarial): zero exit under pipefail when NOTHING matches ---------
# This is the pipefail landmine restated for the WIDENED regex. Every line below
# is a deliberate NEAR MISS: `shellcheck:`/`python-ish:`/`sorted:` prove the tool
# branch requires the colon immediately after the token, `failures:` proves shape
# 1 stayed case-sensitive, `notok` proves `not ok` still needs its space. So grep
# matches nothing, returns 1, pipefail propagates it — and only the load-bearing
# `|| true` keeps the set -euo pipefail harness alive.
{
  printf 'PASS: everything nominal\n'
  printf 'shellcheck: no issues found\n'
  printf 'python-ish: fine\n'
  printf 'sorted: yes\n'
  printf 'notok 4 - hyphenless\n'
  printf 'failures: 0\n'
} >"$TMP/nearmiss.log"
run_detail "$TMP/nearmiss.log"
lines="$(detail_lines)"
if [[ "$DETAIL_RC" -eq 0 ]] && [[ "$lines" == "0" ]] && grep -Fq 'HARNESS-SURVIVED' "$OUT"; then
  pass "failure_detail: near-miss log matches nothing AND returns 0 under set -euo pipefail"
else
  fail "failure_detail: near-miss log misbehaved (rc=$DETAIL_RC, lines=$lines, expected rc=0 lines=0)"
fi

# --- I16: the 10-line cap still holds for the widened regex -------------------
: >"$TMP/many-tool.log"
for i in {1..25}; do
  printf 'awk: line %s: syntax error at or near ,\n' "$i" >>"$TMP/many-tool.log"
done
run_detail "$TMP/many-tool.log"
lines="$(detail_lines)"
if [[ "$lines" == "10" ]]; then
  pass "failure_detail: caps output at 10 lines given 25 tool-error lines"
else
  fail "failure_detail: expected 10 lines from a 25-line tool-error log, got $lines"
fi

# --- I17: a long line is still truncated to 300 chars -------------------------
# An annotation body is size-limited; one runaway line must not consume it.
long_tail=''
while [[ "${#long_tail}" -lt 400 ]]; do
  long_tail="${long_tail}0123456789"
done
printf 'awk: syntax error %s\n' "$long_tail" >"$TMP/longline.log"
run_detail "$TMP/longline.log"
longest=0
while IFS= read -r captured; do
  [[ "$captured" == "HARNESS-SURVIVED" ]] && continue
  if [[ "${#captured}" -gt "$longest" ]]; then
    longest="${#captured}"
  fi
done <"$OUT"
if [[ "$longest" -eq 300 ]]; then
  pass "failure_detail: truncates an over-long tool-error line to 300 chars"
else
  fail "failure_detail: expected a 300-char cap, longest captured line was $longest"
fi

if [[ "$failures" -ne 0 ]]; then
  printf 'ci-annotation-emitter selftest: %d failure(s)\n' "$failures"
  exit 1
fi
printf 'ci-annotation-emitter selftest: OK (37 assertions)\n'
exit 0
