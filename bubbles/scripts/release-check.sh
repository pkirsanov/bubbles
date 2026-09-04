#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$(dirname "$SCRIPT_DIR")")" == "bubbles" && "$(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")" == ".github" ]]; then
  echo "release-check is for the Bubbles source repo, not an installed downstream framework layer." >&2
  exit 1
fi
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Shared helpers. Needed for bubbles_ci_annotate_failure (OW-002), which turns
# each FAIL below into a check-run annotation when running under GitHub Actions.
# shellcheck source=guard-lib.sh
source "$SCRIPT_DIR/guard-lib.sh"
# IMP-049 SCOPE-2: the run-receipt predicate. Absence simply means the receipt
# path is unavailable and the suite runs, which is the same behaviour as before.
# The API is confirmed present BEFORE sourcing: `source` runs in this shell, so
# a stubbed or truncated sibling that merely exits would end release-check with
# whatever status it chose — including a silent 0 that certified nothing.
if [[ -f "$SCRIPT_DIR/validation-receipt.sh" ]]; then
  _rc_receipt_src="$(<"$SCRIPT_DIR/validation-receipt.sh")"
  if [[ "$_rc_receipt_src" == *"validation_receipt_accept()"* ]]; then
    # shellcheck source=bubbles/scripts/validation-receipt.sh
    source "$SCRIPT_DIR/validation-receipt.sh"
  fi
  unset _rc_receipt_src
fi

# Optional --fix: regenerate stale derived artifacts (in dependency order) BEFORE
# running the freshness gates, so a VERSION/gate bump that staled framework-stats
# / cheatsheet / capability-ledger-docs / release-manifest is remediated in one
# command instead of the operator hand-running four generators in the right order.
RELEASE_CHECK_FIX=0
case "${1:-}" in
  --fix) RELEASE_CHECK_FIX=1 ;;
  -h | --help)
    echo "Usage: release-check.sh [--fix]"
    echo "  (no args)  run framework-validate + the derived-artifact freshness gates (check only)"
    echo "  --fix      regenerate stale derived artifacts (regen-derived.sh) BEFORE checking"
    echo
    echo "Environment:"
    echo "  BUBBLES_RELEASE_CHECK_ACCEPT_RECEIPT=1"
    echo "      OPT IN to reusing a framework-validate run receipt instead of re-running"
    echo "      the suite. Off by default. Reuse requires a pass verdict at tier=full"
    echo "      whose recorded tree digest and toolchain fingerprint both still match."
    echo "  BUBBLES_RELEASE_CHECK_RECEIPT_MAX_AGE_SECONDS=86400"
    echo "      receipt expiry (default 24h)"
    exit 0
    ;;
  "") ;;
  *)
    echo "release-check: unknown argument '$1' (expected --fix or no args)." >&2
    exit 2
    ;;
esac

failures=0

run_check() {
  local label="$1"
  shift

  echo "==> $label"
  if "$@"; then
    echo "PASS: $label"
  else
    echo "FAIL: $label"
    # Additive, GitHub-gated (OW-002): raw job logs need admin (403), but
    # check-run annotations are readable unauthenticated. Local output is
    # unchanged.
    bubbles_ci_annotate_failure "FAIL: $label"
    failures=$((failures + 1))
  fi
  echo
}

check_required_files() {
  local missing=0
  local required_files=(
    "$REPO_ROOT/README.md"
    "$REPO_ROOT/CHANGELOG.md"
    "$REPO_ROOT/docs/CHEATSHEET.md"
    "$REPO_ROOT/docs/its-not-rocket-appliances.html"
    "$REPO_ROOT/docs/generated/competitive-capabilities.md"
    "$REPO_ROOT/docs/generated/issue-status.md"
    "$REPO_ROOT/docs/guides/AGENT_MANUAL.md"
    "$REPO_ROOT/docs/guides/INSTALLATION.md"
    "$REPO_ROOT/docs/guides/CONTROL_PLANE_DESIGN.md"
    "$REPO_ROOT/docs/guides/CONTROL_PLANE_SCHEMAS.md"
    "$REPO_ROOT/docs/recipes/framework-ops.md"
    "$REPO_ROOT/bubbles/capability-ledger.yaml"
    "$REPO_ROOT/bubbles/release-manifest.json"
    "$REPO_ROOT/bubbles/action-risk-registry.yaml"
    "$REPO_ROOT/bubbles/scripts/repo-readiness.sh"
    "$REPO_ROOT/install.sh"
    "$REPO_ROOT/VERSION"
  )

  for required_file in "${required_files[@]}"; do
    if [[ ! -f "$required_file" ]]; then
      echo "Missing required release file: $required_file" >&2
      missing=1
    fi
  done

  return "$missing"
}

check_stray_release_files() {
  local found=0
  while IFS= read -r stray_file; do
    [[ -n "$stray_file" ]] || continue
    echo "Unexpected temporary or backup file: $stray_file" >&2
    found=1
  done < <(find "$REPO_ROOT" \
    -path "$REPO_ROOT/.git" -prune -o \
    \( -name '*.tmp' -o -name '*.bak' -o -name '*.orig' -o -name '*~' \) -print)

  if [[ "$found" -eq 1 ]]; then
    return 1
  fi
}

# IMP-049 SCOPE-2. This check used to be an unconditional `bash
# framework-validate.sh` — 3743s across 338 checks, measured — paid again on a
# tree a validate run may have proven minutes earlier.
#
# It is still that, unless a run receipt survives EVERY precondition in
# validation_receipt_accept: opt-in enabled, receipt present and parseable,
# schema and producer known, verdict pass, tier at least `full`, neither
# --changed-only nor the result cache in play, framework version equal, receipt
# not expired, and BOTH the re-derived tree digest and the re-derived toolchain
# fingerprint equal to the recorded ones. Every other outcome — including every
# way of being uncertain — falls through to the run.
#
# The decision line is printed either way. A skip nobody can see is a skip
# nobody can audit.
check_framework_validation() {
  if declare -F validation_receipt_accept >/dev/null 2>&1; then
    local decision
    local accepted=0
    # The verdict is the EXIT CODE, never the wording. Matching on the message
    # would make a reworded refusal readable as an acceptance.
    decision="$(validation_receipt_accept "$REPO_ROOT" full)" && accepted=1
    echo "$decision"
    [[ "$accepted" -eq 1 ]] && return 0
  fi
  # IMP-058 SCOPE-4: framework-validate.sh's bare invocation now defaults to
  # --changed-only. A release gate must never inherit that default by
  # accident, so this is explicit rather than relying on flag absence.
  bash "$SCRIPT_DIR/framework-validate.sh" --no-changed-only
}

echo "Bubbles Release Check"
echo "Repository: $REPO_ROOT"
echo

if [[ "$RELEASE_CHECK_FIX" -eq 1 ]]; then
  echo "==> --fix: regenerating derived artifacts in dependency order before checking"
  if bash "$SCRIPT_DIR/regen-derived.sh"; then
    echo "PASS: derived artifacts regenerated and fresh"
  else
    echo "FAIL: regen-derived reported a still-stale artifact after regeneration"
    bubbles_ci_annotate_failure "FAIL: regen-derived reported a still-stale artifact after regeneration"
    failures=$((failures + 1))
  fi
  echo
fi

run_check "Framework validation" check_framework_validation
run_check "Capability ledger docs freshness" bash "$SCRIPT_DIR/generate-capability-ledger-docs.sh" --check
run_check "Framework stats freshness" sh "$SCRIPT_DIR/generate-framework-stats.sh" --check
run_check "Cheatsheet freshness (v6.0 / B7)" bash "$SCRIPT_DIR/generate-cheatsheet.sh" --check
# NOT a redundant repeat of framework-validate's own manifest check. That check
# now runs last inside a ~30-minute suite; this one re-asks the question after
# the suite AND after the freshness checks above, so a managed file dirtied
# during the run cannot ship as fresh. The cost is one hash pass.
run_check "Release manifest freshness" bash "$SCRIPT_DIR/generate-release-manifest.sh" --check
run_check "Required release files" check_required_files
run_check "No stray temp or backup files" check_stray_release_files

if [[ "$failures" -gt 0 ]]; then
  echo "Release check failed with $failures failing check(s)."
  exit 1
fi

echo "Release check passed."