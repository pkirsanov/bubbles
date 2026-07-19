#!/usr/bin/env bash
set -uo pipefail

# BUG-023 persistent regression: the bubbles-result-envelope skill MUST expose
# exactly the four canonical RESULT-ENVELOPE outcomes
# (completed_owned, completed_diagnostic, route_required, blocked) and MUST NOT
# present done_with_concerns as a current outcome. The skill previously omitted
# completed_diagnostic and listed done_with_concerns in the pipe-enum + table,
# conflicting with agents/bubbles_shared/validation-core.md, evidence-rules.md,
# completion-governance.md (G092), and bubbles/scripts/audit-result-contract-lint.sh.
#
# Exit codes: 0 = clean (GREEN), 1 = contract failure (RED), 2 = harness error.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_SKILL="$REPO_ROOT/skills/bubbles-result-envelope/SKILL.md"
SOURCE_VALIDATION_CORE="$REPO_ROOT/agents/bubbles_shared/validation-core.md"
SOURCE_VALIDATOR="$REPO_ROOT/bubbles/scripts/audit-result-contract-lint.sh"

for required_path in "$SOURCE_SKILL" "$SOURCE_VALIDATION_CORE" "$SOURCE_VALIDATOR" "${BASH_SOURCE[0]}"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_30_result_envelope_outcome_contract: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done
for required_command in grep mktemp rm sed; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_30_result_envelope_outcome_contract: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug023-XXXXXXXX")" || {
  printf '%s\n' 'test_30_result_envelope_outcome_contract: cannot create workspace' >&2
  exit 2
}
cleanup() { rm -rf "$WORKSPACE"; }
trap cleanup EXIT

PASS_COUNT=0
FAIL_COUNT=0
pass() { PASS_COUNT=$((PASS_COUNT + 1)); printf 'PASS %s\n' "$1"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); printf 'FAIL %s\n' "$1"; }

# (1) The template pipe-enum MUST be exactly the canonical four outcomes.
if grep -qxE 'outcome: completed_owned \| completed_diagnostic \| route_required \| blocked' "$SOURCE_SKILL"; then
  pass "template outcome enum is the canonical four"
else
  fail "template outcome enum is not the canonical 'completed_owned | completed_diagnostic | route_required | blocked'"
fi

# (2) completed_diagnostic MUST be documented in the outcome vocabulary.
if grep -qE '\| `completed_diagnostic` \|' "$SOURCE_SKILL"; then
  pass "completed_diagnostic is documented in the outcome vocabulary table"
else
  fail "completed_diagnostic is missing from the outcome vocabulary table"
fi

# (3) done_with_concerns MUST NOT appear as a current pipe-enum outcome.
if grep -qE 'outcome: .*done_with_concerns|done_with_concerns \| ' "$SOURCE_SKILL"; then
  fail "done_with_concerns still appears as a current pipe-enum outcome:"
  grep -nE 'outcome: .*done_with_concerns|done_with_concerns \| ' "$SOURCE_SKILL" | sed 's/^/     /'
else
  pass "done_with_concerns is not presented as a current pipe-enum outcome"
fi

# (4) done_with_concerns MUST be explicitly reframed as legacy read-only.
if grep -qE 'legacy read-only compatibility' "$SOURCE_SKILL"; then
  pass "done_with_concerns is reframed as legacy read-only compatibility"
else
  fail "done_with_concerns legacy-read-only reframing is missing"
fi

# (5) The skill's four outcomes MUST match the authoritative shared module.
if grep -qE 'completed_owned.*completed_diagnostic.*route_required.*blocked' "$SOURCE_VALIDATION_CORE"; then
  pass "authoritative validation-core.md lists the same canonical four outcomes"
else
  fail "validation-core.md canonical outcome list drifted from expectation"
fi

# (6) Adversarial mutant: re-add done_with_concerns to the pipe-enum; prove detection.
MUTANT_FILE="$WORKSPACE/mutant.md"
sed 's/^outcome: completed_owned | completed_diagnostic | route_required | blocked$/outcome: completed_owned | route_required | blocked | done_with_concerns/' "$SOURCE_SKILL" >"$MUTANT_FILE"
if grep -qE 'outcome: .*done_with_concerns' "$MUTANT_FILE"; then
  pass "detector flags an adversarial done_with_concerns re-add (regression is catchable)"
else
  fail "detector FAILED to flag an adversarial done_with_concerns re-add (test would be vacuous)"
fi

printf 'ASSERTIONS=%s PASSED=%s FAILED=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
exit 0
