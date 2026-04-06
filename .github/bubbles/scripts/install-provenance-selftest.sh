#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/trust-metadata.sh"

failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

assert_no_path_leak() {
  local provenance_file="$1"
  local forbidden_path="$2"
  local label="$3"

  if grep -Fq "$forbidden_path" "$provenance_file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

REMOTE_FIXTURE="$TMP_ROOT/remote-fixture"
LOCAL_FIXTURE="$TMP_ROOT/local-fixture"
DIRTY_SOURCE="$TMP_ROOT/local-source-dirty"

mkdir -p "$REMOTE_FIXTURE" "$LOCAL_FIXTURE"
git -C "$REMOTE_FIXTURE" init -q
git -C "$LOCAL_FIXTURE" init -q
cp -a "$ROOT_DIR" "$DIRTY_SOURCE"
printf '\n# install provenance selftest dirty marker\n' >> "$DIRTY_SOURCE/CHANGELOG.md"

echo "Running install-provenance selftest..."
echo "Scenario: downstream installs capture release metadata and provenance for release and local-source modes."

(
  cd "$REMOTE_FIXTURE"
  BUBBLES_SOURCE_OVERRIDE_DIR="$ROOT_DIR" bash "$ROOT_DIR/install.sh" main >/dev/null
)
remote_provenance="$REMOTE_FIXTURE/.github/bubbles/.install-source.json"
remote_manifest="$REMOTE_FIXTURE/.github/bubbles/release-manifest.json"

[[ -f "$remote_manifest" ]] && pass "Remote-ref install copies release manifest" || fail "Remote-ref install copies release manifest"
[[ -f "$remote_provenance" ]] && pass "Remote-ref install writes install provenance" || fail "Remote-ref install writes install provenance"

[[ "$(bubbles_json_string_field "$remote_provenance" installMode)" == 'remote-ref' ]] \
  && pass "Remote-ref provenance records install mode" \
  || fail "Remote-ref provenance records install mode"
[[ "$(bubbles_json_string_field "$remote_provenance" sourceRef)" == 'main' ]] \
  && pass "Remote-ref provenance records requested source ref" \
  || fail "Remote-ref provenance records requested source ref"
[[ "$(bubbles_json_bool_field "$remote_provenance" sourceDirty)" == 'false' ]] \
  && pass "Remote-ref provenance stays clean" \
  || fail "Remote-ref provenance stays clean"

(
  cd "$LOCAL_FIXTURE"
  bash "$ROOT_DIR/install.sh" --local-source "$DIRTY_SOURCE" >/dev/null
)
local_provenance="$LOCAL_FIXTURE/.github/bubbles/.install-source.json"
local_manifest="$LOCAL_FIXTURE/.github/bubbles/release-manifest.json"

[[ -f "$local_manifest" ]] && pass "Local-source install copies generated release manifest" || fail "Local-source install copies generated release manifest"
[[ -f "$local_provenance" ]] && pass "Local-source install writes install provenance" || fail "Local-source install writes install provenance"

[[ "$(bubbles_json_string_field "$local_provenance" installMode)" == 'local-source' ]] \
  && pass "Local-source provenance records install mode" \
  || fail "Local-source provenance records install mode"
[[ -n "$(bubbles_json_string_field "$local_provenance" sourceRef)" ]] \
  && pass "Local-source provenance records a symbolic source ref" \
  || fail "Local-source provenance records a symbolic source ref"
[[ "$(bubbles_json_bool_field "$local_provenance" sourceDirty)" == 'true' ]] \
  && pass "Local-source provenance records dirty working tree risk" \
  || fail "Local-source provenance records dirty working tree risk"
assert_no_path_leak "$local_provenance" "$DIRTY_SOURCE" "Local-source provenance never persists the absolute checkout path"

if [[ "$failures" -gt 0 ]]; then
  echo "install-provenance selftest failed with $failures issue(s)."
  exit 1
fi

echo "install-provenance selftest passed."