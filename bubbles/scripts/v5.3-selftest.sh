#!/usr/bin/env bash
#
# bubbles/scripts/v5.3-selftest.sh
#
# Selftest for v5.3 / G1: framework-validate runs cleanly from a downstream
# install tree.
#
# Asserts:
#   T1. framework-validate detects install-mode=downstream when run from a
#       synthesized `.github/`-style tree (no `install.sh` / `VERSION` at
#       the repo root).
#   T2. framework-validate detects install-mode=source when run from the
#       framework source repo (the tree we're in).
#   T3. The 9 framework-source-only selftests SKIP cleanly (do not FAIL)
#       under install-mode=downstream. Names checked: capability-ledger,
#       capability-freshness, competitive-docs, interop-apply,
#       release-manifest-freshness, release-manifest-selftest,
#       release-manifest-purity, install-provenance, trust-doctor.
#   T4. spec-review-handoff-selftest runs and passes under a synthesized
#       downstream tree (proves the per-selftest dual-resolve path).
#   T5. workflow-delegation-selftest runs and passes under a synthesized
#       downstream tree (proves the per-selftest dual-resolve path).
#
# Exit 0 = all assertions pass. Exit 1 = at least one failed.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=guard-lib.sh
source "$SCRIPT_DIR/guard-lib.sh"

# Progress and absolute bounds for the nested downstream framework-validate run
# (T3). A fixed wall deadline confuses slow progress with a hang. The idle bound
# catches a silent stall; the absolute bound catches an endlessly chatty run.
# Do not tighten either to police performance: they are reliability ceilings.
#
# Calibrated against measurement, not guesswork. At the previous 1200s the
# nested run was still making normal forward progress when it was cut off (6,526
# log lines, log mtime current, real CPU) -- 1200s was inside the healthy
# duration, so it failed healthy runs. Downstream mode skips the
# framework-source-only selftests and so runs shorter than the source-mode run
# (which needs ~22 minutes just to REACH this section), but it is still on the
# order of 25-35 minutes on an idle developer host and exceeded 60 minutes while
# still producing output on a contended shared host. Fifteen idle minutes catches
# a real stall; two hours keeps active progress bounded.
downstream_validate_idle_timeout_seconds="${BUBBLES_V53_DOWNSTREAM_VALIDATE_IDLE_TIMEOUT_SECONDS:-900}"
downstream_validate_absolute_timeout_seconds="${BUBBLES_V53_DOWNSTREAM_VALIDATE_ABSOLUTE_TIMEOUT_SECONDS:-7200}"

failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; failures=$((failures + 1)); }

downstream_check_detail() {
  local label="$1"
  awk -v heading="==> $label" '
    $0 == heading { capture=1; print; next }
    capture && /^==> / { exit }
    capture { print }
  ' "$ds_log" | tail -80
}

downstream_result_contract_passes() {
  local child_rc="$1"
  local known_count="$2"
  local unexpected_count="$3"
  local fixed_count="$4"

  [[ "$unexpected_count" -eq 0 && "$fixed_count" -eq 0 ]] || return 1
  if [[ "$known_count" -eq 0 ]]; then
    [[ "$child_rc" -eq 0 ]]
  else
    [[ "$child_rc" -ne 0 ]]
  fi
}

if downstream_result_contract_passes 0 0 0 0; then
  pass "T3c contract: zero known failures requires child exit 0"
else
  fail "T3c contract rejected a clean child exit"
fi
if downstream_result_contract_passes 7 0 0 0; then
  fail "T3c contract accepted an unexplained nonzero child exit"
else
  pass "T3c contract: unexplained nonzero child exit fails closed"
fi
if downstream_result_contract_passes 1 1 0 0; then
  pass "T3c contract: one exactly enumerated known failure accepts a nonzero child exit"
else
  fail "T3c contract rejected an exactly enumerated known failure"
fi

# --- T2: source-mode detection on the framework repo itself ---
if [[ -f "$ROOT_DIR/install.sh" && -f "$ROOT_DIR/VERSION" ]]; then
  # The list path reports install mode but executes zero checks. Starting a full
  # validator and truncating it with `head` can leave descendants alive after
  # SIGPIPE; they then overlap T3 and corrupt its shared validation fixtures.
  src_out="$(bash "$SCRIPT_DIR/framework-validate.sh" --list-tier=core </dev/null 2>&1)"
  if grep -q "Install mode: source" <<<"$src_out"; then
    pass "T2: framework-validate reports install-mode=source from framework repo"
  else
    fail "T2: framework-validate did NOT report install-mode=source from framework repo (head: ${src_out:0:200})"
  fi
else
  echo "SKIP: T2 (this selftest is not running from a framework source tree)"
fi

# Build the downstream tree with the REAL installer.
#
# This used to be a hand-synthesized partial copy: ~15 named scripts, two
# registries, and seven agent files. A tree that small can never satisfy a
# complete framework-validate run, so the downstream exit code had to be
# discarded to keep the selftest green -- which meant the test proved the SKIP
# lines were printed and nothing else. Installing for real is the only fixture
# that can support asserting the downstream exit code, and it exercises the
# installer on the same path a downstream repository uses.
tmp_root="$(mktemp -d -t bubbles-v5.3-selftest.XXXXXX)"
trap 'rm -rf "$tmp_root"' EXIT INT TERM

run_in_downstream_root() {
  (cd "$tmp_root" && "$@")
}

git -C "$tmp_root" init --quiet
git -C "$tmp_root" config user.email "selftest@example.invalid"
git -C "$tmp_root" config user.name "v5.3 selftest"
printf '# downstream fixture\n' >"$tmp_root/README.md"
git -C "$tmp_root" add README.md
git -C "$tmp_root" commit --quiet -m "fixture base"

install_rc=0
install_log="$(cd "$tmp_root" && bash "$ROOT_DIR/install.sh" --local-source "$ROOT_DIR" 2>&1)" || install_rc=$?
if [[ $install_rc -eq 0 ]]; then
  pass "T0: install.sh --local-source produced a downstream tree"
else
  fail "T0: install.sh --local-source failed (rc=$install_rc; tail: $(tail -5 <<<"$install_log"))"
fi

# The installer must NOT place install.sh / VERSION at the downstream root --
# that is what makes the tree downstream rather than a source checkout.
if [[ -f "$tmp_root/install.sh" || -f "$tmp_root/VERSION" ]]; then
  fail "T0b: installer leaked source-tree markers (install.sh / VERSION) into the downstream root"
else
  pass "T0b: downstream root carries no source-tree markers"
fi

expected_downstream_root="$(cd "$tmp_root" && pwd -P)"
actual_downstream_root="$(run_in_downstream_root pwd -P)"
if [[ "$actual_downstream_root" == "$expected_downstream_root" ]]; then
  pass "T0c: downstream command wrapper executes from the installed repository root"
else
  fail "T0c: downstream command wrapper leaked ambient CWD (expected=$expected_downstream_root actual=$actual_downstream_root)"
fi

# The managed-doc existence lint (correctly) fails a repository that declares
# required managed docs and has not written them. In this fixture that is an
# adoption gap, not a defect in the install, so give the fixture the documents
# its own resolved registry says it must have. The list is ASKED FOR rather
# than hardcoded so it cannot drift away from the registry.
while IFS= read -r managed_doc_path; do
  [[ -n "$managed_doc_path" ]] || continue
  mkdir -p "$tmp_root/$(dirname "$managed_doc_path")"
  printf '# %s\n\nDownstream install fixture placeholder.\n' \
    "$(basename "$managed_doc_path")" >"$tmp_root/$managed_doc_path"
done < <(
  cd "$tmp_root" && bash .github/bubbles/scripts/docs-registry-resolve.sh --effective 2>/dev/null | awk '
    /^    path:[[:space:]]/ { doc_path = $2; next }
    /^    required:[[:space:]]/ { if ($2 == "true" && doc_path != "") print doc_path; doc_path = ""; next }
  '
)

# --- T1: downstream-mode detection ---
ds_out="$(run_in_downstream_root bash .github/bubbles/scripts/framework-validate.sh --list-tier=core </dev/null 2>&1)"
if grep -q "Install mode: downstream" <<<"$ds_out"; then
  pass "T1: framework-validate reports install-mode=downstream from a real installed tree"
else
  fail "T1: framework-validate did NOT report install-mode=downstream (head: ${ds_out:0:200})"
fi

# --- T3: framework-source-only selftests SKIP under downstream mode ---
#
# `|| true` inside the command substitution used to swallow the exit code, so
# this asserted only that the SKIP lines were printed. A downstream install
# whose validation FAILED would still have satisfied it. Capture the real code
# and require zero: an install that cannot validate itself is not installed.
#
# The capture MUST NOT be a command substitution. `$(...)` reads its pipe until
# EOF, and EOF does not arrive while ANY descendant of the nested run still
# holds the write end -- so a single lingering child wedged the whole suite
# forever with no output and no CPU. T1/T2 above survive only because `head`
# SIGPIPEs the run early; T3 captures everything and had nothing to cap it.
# A temp file has no reader to starve, and `</dev/null` removes the second
# blocking surface (a nested command waiting on input that never comes).
# bubbles_run_with_progress_timeout is the backstop: a future silent or chatty
# hang FAILS LOUD at the correct bound instead of truncating healthy progress.
ds_rc=0
ds_log="$(mktemp "${TMPDIR:-/tmp}/bubbles-v5.3-downstream.XXXXXX")"
trap 'rm -rf "$tmp_root"; rm -f "$ds_log"' EXIT INT TERM
bubbles_run_with_progress_timeout \
  "$downstream_validate_idle_timeout_seconds" \
  "$downstream_validate_absolute_timeout_seconds" \
  "$ds_log" \
  run_in_downstream_root bash .github/bubbles/scripts/framework-validate.sh || ds_rc=$?
ds_full="$(cat "$ds_log")"
# 2, 124 and 125 all originate in the PROGRESS RUNNER, not in framework-validate:
# each means the run was cut short, so the captured log is INCOMPLETE and cannot
# support any verdict about downstream behaviour. Naming that once, here, keeps
# every assertion below gated on the same condition; the previous form repeated
# `-ne 124 && -ne 125` at five sites, and rc=2 was absent from all five, so a
# runner abort was read as a dozen independent skip-logic regressions.
ds_run_incomplete=false
if [[ $ds_rc -eq 124 ]]; then
  ds_run_incomplete=true
  fail "T3: downstream framework-validate made no log progress for ${downstream_validate_idle_timeout_seconds}s (idle timeout; treated as a failure, not a skip)"
elif [[ $ds_rc -eq 125 ]]; then
  ds_run_incomplete=true
  fail "T3: downstream framework-validate exceeded the ${downstream_validate_absolute_timeout_seconds}s absolute ceiling while still producing output (treated as a failure, not a skip)"
elif [[ $ds_rc -eq 2 ]]; then
  ds_run_incomplete=true
  fail "T3: the progress runner ABORTED the downstream framework-validate (rc=2) because it could not read the progress log; the run was cut short after $(wc -l <"$ds_log" | tr -d '[:space:]') line(s), so its verdicts are incomplete. This is a RUNNER failure, not a skip-logic regression."
fi

# A downstream run that never EXECUTED its checks cannot answer T3 at all. Its
# log carries no SKIP line for any label, so the per-label loop below would read
# every one of them as a skip-logic regression and emit 16 separate failures --
# 16 symptoms of a run that never started, with the single real cause absent from
# the output. The dominant instance is the concurrent-run guard in
# framework-validate: when another run holds the lock, the nested validate exits
# 1 after three lines, which is neither 124 nor 125 and so fell straight through.
# Detect "produced no verdicts" once, name the cause, and suppress assertions the
# captured log cannot support.
ds_executed_checks=true
if ! grep -Fq 'SKIP: ' <<<"$ds_full"; then
  ds_executed_checks=false
  ds_log_lines="$(wc -l <"$ds_log" | tr -d '[:space:]')"
  if grep -Fq 'another framework-validate run is already in progress' <<<"$ds_full"; then
    fail "T3: the downstream framework-validate was REFUSED by the concurrent-run guard (rc=$ds_rc); another framework-validate already holds the lock. This is an environment condition, NOT a skip-logic regression -- wait for that run to finish, then re-run."
  elif [[ "$ds_run_incomplete" == "false" ]]; then
    fail "T3: the downstream framework-validate emitted no SKIP verdict for any label (rc=$ds_rc, ${ds_log_lines} log lines), so it did not execute its checks. Last output: $(tail -2 "$ds_log" | tr '\n' ' ')"
  fi
fi

self_only_labels=(
  "Capability ledger selftest"
  "Capability freshness selftest"
  "Competitive docs selftest"
  "Interop apply selftest"
  "Release manifest freshness"
  "Release manifest selftest"
  "Release manifest purity selftest"
  "Install provenance selftest"
  "Trust doctor selftest"
  "Portable surface agnosticity"
  "Cheatsheet generator selftest (v6.0 / B7)"
  "Installer manifest check (v6.0 / B9)"
  "Installer manifest selftest (v6.0 / B9)"
  "Bug-packet contract selftest (IMP-047 / S-B)"
  "Validation run receipt selftest (IMP-049 SCOPE-2)"
  "Generated gate-enforcement block current"
)
if [[ "$ds_executed_checks" == "true" && "$ds_run_incomplete" == "false" ]]; then
  t3_failures=0
  for label in "${self_only_labels[@]}"; do
    if grep -Fq "SKIP: $label (framework-source-only" <<<"$ds_full"; then
      :
    else
      fail "T3: '$label' was not SKIPPED under install-mode=downstream"
      t3_failures=$((t3_failures + 1))
    fi
  done
  if [[ $t3_failures -eq 0 ]]; then
    pass "T3: all ${#self_only_labels[@]} framework-source-only selftests SKIPPED under install-mode=downstream"
  fi

  # Also assert no FAIL line for those same labels (defense against silent regression).
  for label in "${self_only_labels[@]}"; do
    if grep -Fq "FAIL: $label" <<<"$ds_full"; then
      fail "T3b: '$label' FAILED instead of SKIPPING under install-mode=downstream"
    fi
  done
fi

# --- T3c: the downstream validation run as a whole must succeed -------------
#
# `|| true` used to swallow this exit code entirely, so nothing noticed that a
# downstream install cannot validate itself. Enabling the check surfaced a set
# of pre-existing failures, each a selftest that asserts a framework-source-repo
# property while being scheduled as portable.
#
# They are enumerated rather than ignored. Any check that fails and is NOT on
# this list fails the selftest immediately, so new downstream breakage is caught
# from now on. A listed check that STARTS passing also fails the selftest, which
# forces the list to shrink as each one is fixed instead of quietly rotting.
# The list must reach empty.
known_downstream_failures=()

observed_failures=()
# A successful top-level validator has no failures regardless of any expected
# nested fixture output it printed. On failure, read only the LAST contiguous
# "Failed checks:" block; the first block can belong to a nested selftest that
# intentionally exercised a red framework-validate fixture.
if [[ $ds_rc -ne 0 && "$ds_run_incomplete" == "false" ]]; then
  while IFS= read -r line; do
    [[ -n "$line" ]] && observed_failures+=("$line")
  done < <(printf '%s\n' "$ds_full" | awk '
    /^Failed checks:$/ { block=""; capture=1; next }
    capture && /^  - / { line=$0; sub(/^  - /,"",line); block=block line ORS; next }
    capture { capture=0 }
    END { printf "%s", block }
  ')
fi

unexpected=0
if [[ $ds_rc -ne 0 && "$ds_run_incomplete" == "false" && ${#observed_failures[@]} -eq 0 ]]; then
  fail "T3c: downstream framework-validate exited $ds_rc without a trailing Failed checks block"
  unexpected=$((unexpected + 1))
fi
for observed in ${observed_failures[@]+"${observed_failures[@]}"}; do
  listed=0
  for known in "${known_downstream_failures[@]}"; do
    [[ "$observed" == "$known" ]] && listed=1 && break
  done
  if [[ $listed -eq 0 ]]; then
    fail "T3c: NEW downstream failure not on the known list: '$observed'"
    detail="$(downstream_check_detail "$observed")"
    if [[ -n "$detail" ]]; then
      printf '%s\n%s\n%s\n' \
        "--- downstream failure detail: $observed ---" \
        "$detail" \
        "--- end downstream failure detail ---" >&2
    fi
    unexpected=$((unexpected + 1))
  fi
done

fixed=0
for known in "${known_downstream_failures[@]}"; do
  still_failing=0
  for observed in ${observed_failures[@]+"${observed_failures[@]}"}; do
    [[ "$observed" == "$known" ]] && still_failing=1 && break
  done
  if [[ $still_failing -eq 0 ]]; then
    fail "T3c: '$known' now passes downstream — remove it from known_downstream_failures"
    fixed=$((fixed + 1))
  fi
done

if [[ $unexpected -eq 0 && $fixed -eq 0 && "$ds_run_incomplete" == "false" ]]; then
  if downstream_result_contract_passes \
    "$ds_rc" "${#known_downstream_failures[@]}" "$unexpected" "$fixed"; then
    if [[ ${#known_downstream_failures[@]} -eq 0 ]]; then
      pass "T3c: downstream framework-validate exited 0"
    else
      pass "T3c: downstream failures match the ${#known_downstream_failures[@]} enumerated known defects (rc=$ds_rc)"
    fi
  elif [[ ${#known_downstream_failures[@]} -eq 0 ]]; then
    fail "T3c: downstream framework-validate exited $ds_rc without a Failed checks block"
  else
    fail "T3c: downstream framework-validate exited 0 while known failures remain enumerated"
  fi
fi

# --- T4: spec-review-handoff-selftest passes under downstream tree ---
# `sr_rc=$?` after a `|| true` inside the substitution read the exit status of
# the ASSIGNMENT, which is always 0, so the rc half of the condition below was
# inert. Same for T5.
sr_rc=0
sr_out="$(run_in_downstream_root bash .github/bubbles/scripts/spec-review-handoff-selftest.sh </dev/null 2>&1)" || sr_rc=$?
if [[ $sr_rc -eq 0 ]] && grep -q "spec-review-handoff-selftest: PASSED" <<<"$sr_out"; then
  pass "T4: spec-review-handoff-selftest passes under synthesized downstream tree"
else
  fail "T4: spec-review-handoff-selftest FAILED under downstream tree (rc=$sr_rc; tail: $(tail -3 <<<"$sr_out"))"
fi

# --- T5: workflow-delegation-selftest passes under downstream tree ---
wd_rc=0
wd_out="$(run_in_downstream_root bash .github/bubbles/scripts/workflow-delegation-selftest.sh </dev/null 2>&1)" || wd_rc=$?
if [[ $wd_rc -eq 0 ]] && grep -q "workflow-delegation selftest passed" <<<"$wd_out"; then
  pass "T5: workflow-delegation-selftest passes under synthesized downstream tree"
else
  fail "T5: workflow-delegation-selftest FAILED under downstream tree (rc=$wd_rc; tail: $(tail -3 <<<"$wd_out"))"
fi

if [[ $failures -gt 0 ]]; then
  echo
  echo "v5.3-selftest FAILED with $failures issue(s)."
  exit 1
fi

echo
echo "v5.3-selftest passed: framework-validate runs cleanly from a downstream install tree."
