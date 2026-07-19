#!/usr/bin/env bash
set -uo pipefail

# BUG-025 persistent regression: the bubbles-skills-first-discovery
# "Situation -> Skill map" MUST expose one independent Markdown table row per
# situation. Two rows were previously merged with a mid-row `||`, collapsing
# scope-workflow-runtime with feature-template and fix-cycle-protocol with
# skill-authoring. This test proves (1) the canonical source map is clean and
# (2) the merged-row detector actually catches the regression on an adversarial
# mutant, so a re-merge can never pass silently.
#
# Exit codes: 0 = clean (GREEN), 1 = contract failure (RED), 2 = harness error.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_SKILL="$REPO_ROOT/skills/bubbles-skills-first-discovery/SKILL.md"

for required_path in "$SOURCE_SKILL" "${BASH_SOURCE[0]}"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_32_skills_first_map_merged_rows: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done
if [[ ! -d "$REPO_ROOT/bubbles" || ! -d "$REPO_ROOT/skills" ]]; then
  printf '%s\n' 'test_32_skills_first_map_merged_rows: canonical framework surfaces are missing' >&2
  exit 2
fi
for required_command in awk grep mktemp rm sed; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_32_skills_first_map_merged_rows: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug025-XXXXXXXX")" || {
  printf '%s\n' 'test_32_skills_first_map_merged_rows: cannot create workspace' >&2
  exit 2
}
cleanup() { rm -rf "$WORKSPACE"; }
trap cleanup EXIT

PASS_COUNT=0
FAIL_COUNT=0
pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS %s\n' "$1"
}
fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL %s\n' "$1"
}

# Extract only the "Situation -> Skill map" table body (lines beginning with a
# pipe, between the map heading and the next heading). This is the exact surface
# consumers read.
extract_map_table() {
  awk '
    /^## Situation/ { in_map = 1; next }
    in_map && /^#/ { in_map = 0 }
    in_map && /^\|/ { print }
  ' "$1"
}

MAP_TABLE_FILE="$WORKSPACE/map-table.txt"
extract_map_table "$SOURCE_SKILL" >"$MAP_TABLE_FILE"

if [[ ! -s "$MAP_TABLE_FILE" ]]; then
  fail "Situation -> Skill map table is empty or unlocatable"
  printf 'ASSERTIONS=%s PASSED=%s FAILED=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$PASS_COUNT" "$FAIL_COUNT"
  exit 1
fi
pass "located non-empty Situation -> Skill map table"

# The merged-row signature: a closing backtick (end of a skill name) followed by
# optional spaces and a mid-row `||`, which fuses a second situation onto the
# same physical row.
MERGE_SIGNATURE='`[[:space:]]*\|\|'

# (1) Canonical map MUST be clean.
if grep -nE "$MERGE_SIGNATURE" "$MAP_TABLE_FILE" >/dev/null 2>&1; then
  fail "canonical map contains a merged (|| ) row:"
  grep -nE "$MERGE_SIGNATURE" "$MAP_TABLE_FILE" | sed 's/^/     /'
else
  pass "canonical map has no merged (|| ) rows"
fi

# (2) The four previously-merged mappings MUST each exist as an independent row.
assert_independent_row() {
  local skill="$1"
  local matches
  matches="$(grep -cE "\`$skill\`[[:space:]]*\|[[:space:]]*$" "$MAP_TABLE_FILE" 2>/dev/null || true)"
  if [[ "$matches" -ge 1 ]]; then
    pass "independent row present: $skill"
  else
    fail "missing independent row (row must end right after \`$skill\`): $skill"
  fi
}
assert_independent_row "bubbles-scope-workflow-runtime"
assert_independent_row "bubbles-feature-template"
assert_independent_row "bubbles-fix-cycle-protocol"
assert_independent_row "bubbles-skill-authoring"

# (3) Adversarial mutant: re-merge two rows and prove the detector flags it.
MUTANT_FILE="$WORKSPACE/mutant.txt"
sed 's#`bubbles-scope-workflow-runtime` |#`bubbles-scope-workflow-runtime` || Creating or refreshing a feature folder | `bubbles-feature-template` |#' "$MAP_TABLE_FILE" >"$MUTANT_FILE"
if grep -nE "$MERGE_SIGNATURE" "$MUTANT_FILE" >/dev/null 2>&1; then
  pass "detector flags an adversarial re-merged row (regression is catchable)"
else
  fail "detector FAILED to flag an adversarial re-merged row (test would be vacuous)"
fi

printf 'ASSERTIONS=%s PASSED=%s FAILED=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
exit 0
