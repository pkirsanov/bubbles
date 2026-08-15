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

failures=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1" >&2; failures=$((failures + 1)); }

# --- T2: source-mode detection on the framework repo itself ---
if [[ -f "$ROOT_DIR/install.sh" && -f "$ROOT_DIR/VERSION" ]]; then
  # Window must clear any stderr preamble (macOS emits a 3-line flock-absent NOTE
  # before the banner); head still SIGPIPEs the run early so this stays cheap.
  src_out="$(bash "$SCRIPT_DIR/framework-validate.sh" 2>&1 | head -30 || true)"
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

# --- T1: downstream-mode detection ---
ds_out="$(bash "$tmp_root/.github/bubbles/scripts/framework-validate.sh" 2>&1 | head -30 || true)"
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
ds_rc=0
ds_full="$(bash "$tmp_root/.github/bubbles/scripts/framework-validate.sh" 2>&1)" || ds_rc=$?
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
)
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
known_downstream_failures=(
  "Run-state abandoned-run reaper selftest"
  "Gate-vintage selftest (IMP-036)"
  "Open-work register selftest (IMP-033 / SCOPE-3 — WIP-1, WIP-2)"
  "Scenario compile lint selftest"
  "Discovered selftest: repository-binding-selftest.sh (IMP-027 SCOPE-2b)"
)

observed_failures=()
# Read ONLY the trailing "Failed checks:" block. Matching "  - " anywhere in the
# output instead swept up every guard's remediation hint list and reported 125
# phantom failures.
while IFS= read -r line; do
  [[ -n "$line" ]] && observed_failures+=("$line")
done < <(printf '%s\n' "$ds_full" | awk '/^Failed checks:/{f=1;next} f&&/^  - /{sub(/^  - /,"");print;next} f{exit}')

unexpected=0
for observed in ${observed_failures[@]+"${observed_failures[@]}"}; do
  listed=0
  for known in "${known_downstream_failures[@]}"; do
    [[ "$observed" == "$known" ]] && listed=1 && break
  done
  if [[ $listed -eq 0 ]]; then
    fail "T3c: NEW downstream failure not on the known list: '$observed'"
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

if [[ $unexpected -eq 0 && $fixed -eq 0 ]]; then
  if [[ ${#known_downstream_failures[@]} -eq 0 && $ds_rc -eq 0 ]]; then
    pass "T3c: downstream framework-validate exited 0"
  else
    pass "T3c: downstream failures match the ${#known_downstream_failures[@]} enumerated known defects (rc=$ds_rc)"
  fi
fi

# --- T4: spec-review-handoff-selftest passes under downstream tree ---
# `sr_rc=$?` after a `|| true` inside the substitution read the exit status of
# the ASSIGNMENT, which is always 0, so the rc half of the condition below was
# inert. Same for T5.
sr_rc=0
sr_out="$(bash "$tmp_root/.github/bubbles/scripts/spec-review-handoff-selftest.sh" 2>&1)" || sr_rc=$?
if [[ $sr_rc -eq 0 ]] && grep -q "spec-review-handoff-selftest: PASSED" <<<"$sr_out"; then
  pass "T4: spec-review-handoff-selftest passes under synthesized downstream tree"
else
  fail "T4: spec-review-handoff-selftest FAILED under downstream tree (rc=$sr_rc; tail: $(tail -3 <<<"$sr_out"))"
fi

# --- T5: workflow-delegation-selftest passes under downstream tree ---
wd_rc=0
wd_out="$(bash "$tmp_root/.github/bubbles/scripts/workflow-delegation-selftest.sh" 2>&1)" || wd_rc=$?
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
