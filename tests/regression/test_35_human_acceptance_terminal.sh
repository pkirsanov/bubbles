#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G136 - human_acceptance_terminal_gate.
#
# BUG-029. artifact-lint.sh required uservalidation.md to carry at least ONE
# checked `[x]` entry and never rejected an unchecked one, so a checklist of one
# checked item and five unchecked passed lint and the spec reached a terminal
# status with five behaviors no user had accepted. That closure is what this
# regression pins, and BUG-037 leaves it exactly intact.
#
# BUG-037 inverted the CONTRACT. Acceptance is OPT-OUT: the checklist ships
# CHECKED, a user's only required act is to UNCHECK an item they reject, and an
# authored `## Human Acceptance Record` is no longer demanded at a terminal
# transition. So the fully-checked record-less fixture, which PD-12 refused, now
# returns zero findings - and the adversarial partner below proves the inversion
# did not widen into "terminal never checks acceptance".
#
# This regression pins the DETECTION RULE the guard's Check 43 applies, through
# the SHARED reader the guard itself uses. The parser used to be duplicated here
# on purpose; it is now sourced, so a desync is impossible rather than merely
# noticed late.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SELF="${BASH_SOURCE[0]}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD_FRAGMENT="$REPO_ROOT/bubbles/scripts/guards/tail-delegated-gates.sh"
ACCEPTANCE_LIB="$REPO_ROOT/bubbles/scripts/acceptance-authority-lib.sh"

if [[ ! -f "$GUARD_FRAGMENT" ]]; then
  echo "test_35_human_acceptance_terminal: guard fragment missing: $GUARD_FRAGMENT" >&2
  exit 2
fi
if [[ ! -f "$ACCEPTANCE_LIB" ]]; then
  echo "test_35_human_acceptance_terminal: acceptance library missing: $ACCEPTANCE_LIB" >&2
  exit 2
fi

# shellcheck source=../../bubbles/scripts/acceptance-authority-lib.sh
source "$ACCEPTANCE_LIB"

WORKSPACE="$(mktemp -d -t bubbles-g136-regression-XXXXXXXX)"
trap 'rm -rf "$WORKSPACE"' EXIT INT TERM

pass_count=0
fail_count=0

assert_eq() {
  local description="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass_count=$((pass_count + 1))
    printf '  PASS: %s (%s)\n' "$description" "$actual"
  else
    fail_count=$((fail_count + 1))
    printf '  FAIL: %s (expected=%s actual=%s)\n' "$description" "$expected" "$actual"
  fi
}

count_unchecked() {
  local items
  items="$(bubbles_acceptance_unchecked_items "$1")"
  if [[ -z "$items" ]]; then
    printf '0\n'
  else
    printf '%s\n' "$items" | grep -c . || true
  fi
}

terminal_verdict_codes() {
  bubbles_acceptance_terminal_verdict "$1" 2>&1 | sed -E 's/:.*//' | sort -u | tr '\n' ' ' | sed -E 's/ $//'
}

# --- Fixture 1: the BUG-029 shape ------------------------------------------
cat > "$WORKSPACE/mixed.md" <<'EOF'
# User Validation

## Checklist

- [x] The list renders on the dashboard route.
- [ ] Deleting an item removes it from the list.
- [ ] An empty list shows the empty state.

## Notes

- [ ] This bullet is outside the Checklist section.
EOF

# --- Fixture 2: fully accepted ---------------------------------------------
cat > "$WORKSPACE/accepted.md" <<'EOF'
# User Validation

## Checklist

- [x] The list renders on the dashboard route.
- [x] Deleting an item removes it from the list.

## Notes

- [ ] This bullet is outside the Checklist section.
EOF

# --- Fixture 3: the lint-passing minimum (one checked, nothing else) --------
cat > "$WORKSPACE/single.md" <<'EOF'
# User Validation

## Checklist

- [x] Baseline validation path.
EOF

echo "test_35_human_acceptance_terminal (Gate G136)"

assert_eq "BUG-029 shape: two unchecked items are detected" \
  "2" "$(count_unchecked "$WORKSPACE/mixed.md")"

assert_eq "adversarial: a fully accepted checklist reports zero" \
  "0" "$(count_unchecked "$WORKSPACE/accepted.md")"

assert_eq "adversarial: a '[ ]' under '## Notes' is not counted" \
  "0" "$(count_unchecked "$WORKSPACE/single.md")"

# --- BUG-037: unchecking nothing IS acceptance ------------------------------
# S3-T7. Fixture 2 is fully checked and carries no acceptance record. Under
# PD-12 it was refused with PD12-NO-RECORD, which made the owner's normal case -
# a satisfied user who objects to nothing - unreachable. It now returns zero
# findings.
assert_eq "BUG-037: a fully checked list with no acceptance record now returns zero findings" \
  "" "$(terminal_verdict_codes "$WORKSPACE/accepted.md")"

# S3-T6 adversarial partner. The inversion must NOT widen into "terminal never
# checks acceptance": a user's uncheck is a reported regression and still
# refuses, naming the item.
assert_eq "adversarial: an unchecked item still yields PD12-UNCHECKED-ITEM at terminal" \
  "PD12-UNCHECKED-ITEM" "$(terminal_verdict_codes "$WORKSPACE/mixed.md")"

# The verdict returns non-zero by design, and this file runs under `pipefail`,
# so its output is captured BEFORE it is searched. Piping it straight into grep
# would report the verdict's exit status rather than whether the item was named.
mixed_refusal="$(bubbles_acceptance_terminal_verdict "$WORKSPACE/mixed.md" 2>&1 || true)"
if printf '%s' "$mixed_refusal" | grep -q 'Deleting an item removes it from the list'; then
  pass_count=$((pass_count + 1))
  printf '  PASS: adversarial: the refusal NAMES the unchecked item\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: the refusal does not name the unchecked item\n'
fi

# The conditional code must stay dormant against the shipped false registry.
# Emitting it here would refuse every satisfied user all over again.
accepted_verdict="$(bubbles_acceptance_terminal_verdict "$WORKSPACE/accepted.md" 2>&1 || true)"
if printf '%s' "$accepted_verdict" | grep -q 'PD12-NO-RECORD'; then
  fail_count=$((fail_count + 1))
  printf '  FAIL: shipped false policy emitted conditional PD12-NO-RECORD\n'
else
  pass_count=$((pass_count + 1))
  printf '  PASS: shipped false policy leaves conditional PD12-NO-RECORD dormant\n'
fi

cat > "$WORKSPACE/human-accepted.md" <<'EOF'
# User Validation

## Automation Readiness

- [x] Both behaviors verified by automation.

## Checklist

- [x] The list renders on the dashboard route.
- [x] Deleting an item removes it from the list.

## Human Acceptance Record

- acceptedBy: p.kirsanov
- acceptedAt: 2026-08-16T10:00:00Z
- method: human-interactive
EOF

assert_eq "a human-owned acceptance record with every box checked is accepted" \
  "" "$(terminal_verdict_codes "$WORKSPACE/human-accepted.md")"

cat > "$WORKSPACE/agent-accepted.md" <<'EOF'
# User Validation

## Checklist

- [x] The list renders on the dashboard route.

## Human Acceptance Record

- acceptedBy: bubbles.validate
- acceptedAt: 2026-08-16T10:00:00Z
- method: human-interactive
EOF

assert_eq "adversarial: an agent id as acceptedBy cannot grant acceptance" \
  "PD12-AUTOMATION-ACCEPTOR" "$(terminal_verdict_codes "$WORKSPACE/agent-accepted.md")"

# --- The guard fragment must actually carry the gate ------------------------
if grep -q 'Gate G136' "$GUARD_FRAGMENT"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: guard fragment declares Gate G136\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: guard fragment no longer declares Gate G136\n'
fi

# S3-T8. This file must READ the shared library, never re-implement its parse.
# A private copy here would pass while the guard applied a different rule, which
# is the exact desync the shared reader exists to make impossible. The local
# parser pattern is anchored at a function definition so this check cannot match
# its own source line.
if grep -q 'acceptance-authority-lib.sh' "$SELF" &&
  grep -q 'bubbles_acceptance_terminal_verdict' "$SELF" &&
  ! grep -qE '^[a-z_]*(section_body|parse_checklist|extract_checklist|checklist_items)\(\)' "$SELF"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: the regression sources the shared reader and re-implements no section parser\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: the regression carries a private uservalidation parser instead of sourcing the shared library\n'
fi

# The gate is only meaningful if it is scoped to a terminal transition; a
# version that ran on every mode would false-block every planning packet and
# would be reverted rather than fixed.
if grep -q 'transition_target_status" != "done"' "$GUARD_FRAGMENT"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: the gate is scoped to a terminal (done) transition\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: the gate lost its terminal-transition scoping\n'
fi

# The guard must never edit uservalidation.md. Checking a box on the author's
# behalf would fabricate the acceptance the gate exists to require.
# portable-ok: the sed -i token below is a SEARCH PATTERN asserting the ABSENCE of an in-place write in the guard fragment, not an invocation of sed
if grep -qE '^[[:space:]]*(sed -i|>+[[:space:]]*"?\$uservalidation_terminal_file)' "$GUARD_FRAGMENT"; then
  fail_count=$((fail_count + 1))
  printf '  FAIL: the guard writes to uservalidation.md — it must only report\n'
else
  pass_count=$((pass_count + 1))
  printf '  PASS: the guard never writes to uservalidation.md\n'
fi

printf 'test_35_human_acceptance_terminal: %s passed, %s failed\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]] || exit 1
exit 0
