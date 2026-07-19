#!/usr/bin/env bash
set -uo pipefail

# BUG-024 persistent regression: agents/bubbles.create-skill.agent.md MUST NOT
# require placeholder "When NOT to use" / "Works well with" section stubs when
# the interview has no content. That instruction contradicted the agent's own
# no-stubs rule and made generated skills fail the framework's no-stubs quality
# bar. The correct contract emits those optional sections ONLY when concrete
# verified content exists and omits them cleanly otherwise.
#
# Exit codes: 0 = clean (GREEN), 1 = contract failure (RED), 2 = harness error.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_AGENT="$REPO_ROOT/agents/bubbles.create-skill.agent.md"

for required_path in "$SOURCE_AGENT" "${BASH_SOURCE[0]}"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_31_create_skill_placeholder_stubs: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done
if [[ ! -d "$REPO_ROOT/agents" || ! -d "$REPO_ROOT/skills" ]]; then
  printf '%s\n' 'test_31_create_skill_placeholder_stubs: canonical framework surfaces are missing' >&2
  exit 2
fi
for required_command in grep mktemp rm sed; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_31_create_skill_placeholder_stubs: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug024-XXXXXXXX")" || {
  printf '%s\n' 'test_31_create_skill_placeholder_stubs: cannot create workspace' >&2
  exit 2
}
cleanup() { rm -rf "$WORKSPACE"; }
trap cleanup EXIT

PASS_COUNT=0
FAIL_COUNT=0
pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS %s\n' "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL %s\n' "$1"; }

# The stub-requiring signature that BUG-024 removed. Any of these phrasings
# re-introduces the contradiction with the no-stubs rule.
STUB_REQUIRE_SIGNATURE='section stub|Leave them as clearly-marked stubs|MUST include a \*\*When NOT|stub for the author to complete'

# (1) The no-stubs rule MUST be present (it is the governing quality bar).
if grep -qE 'No TODOs, stubs' "$SOURCE_AGENT"; then
  pass "no-stubs quality rule is present"
else
  fail "no-stubs quality rule ('No TODOs, stubs, ...') is missing"
fi

# (2) The stub-REQUIRING instruction MUST be absent.
if grep -nE "$STUB_REQUIRE_SIGNATURE" "$SOURCE_AGENT" >/dev/null 2>&1; then
  fail "create-skill agent still REQUIRES placeholder stubs (contradicts no-stubs rule):"
  grep -nE "$STUB_REQUIRE_SIGNATURE" "$SOURCE_AGENT" | sed 's/^/     /'
else
  pass "no stub-requiring instruction remains"
fi

# (3) The corrected conditional-emission contract MUST be present.
if grep -qE 'ONLY when the interview or verified repository context' "$SOURCE_AGENT" \
  && grep -qE 'omit it cleanly' "$SOURCE_AGENT"; then
  pass "optional sections are content-conditional and omitted-not-stubbed"
else
  fail "conditional-emission / omit-cleanly contract for optional sections is missing"
fi

# (4) Adversarial mutant: re-introduce the stub requirement and prove detection.
MUTANT_FILE="$WORKSPACE/mutant.md"
cp "$SOURCE_AGENT" "$MUTANT_FILE"
printf '%s\n' '- The generated `SKILL.md` MUST include a **When NOT to use** section stub. Leave them as clearly-marked stubs for the author to complete when no content is known yet.' >>"$MUTANT_FILE"
if grep -nE "$STUB_REQUIRE_SIGNATURE" "$MUTANT_FILE" >/dev/null 2>&1; then
  pass "detector flags an adversarial re-introduced stub requirement (regression is catchable)"
else
  fail "detector FAILED to flag an adversarial stub requirement (test would be vacuous)"
fi

printf 'ASSERTIONS=%s PASSED=%s FAILED=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
exit 0
