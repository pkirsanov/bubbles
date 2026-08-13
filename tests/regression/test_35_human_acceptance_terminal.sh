#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G136 - human_acceptance_terminal_gate.
#
# BUG-029. artifact-lint.sh requires uservalidation.md to carry at least ONE
# checked `[x]` entry and never rejects an unchecked one, so a checklist of one
# checked item and five unchecked passes lint and the spec reaches a terminal
# status with five behaviors no human ever accepted.
#
# This regression pins the DETECTION RULE the guard's Check 43 applies, at the
# level the bug actually occurred: the section reader plus the unchecked scan.
# It asserts the mixed shape is detected, a fully accepted list is not, and a
# `[ ]` outside the `## Checklist` section is ignored — that last one is what
# stops the rule from over-reaching into prose and being switched off.
#
# The parser here is byte-identical to the one in guards/tail-delegated-gates.sh
# and artifact-lint.sh ON PURPOSE. If a future edit desyncs them, this test
# still encodes the contract all three are supposed to share.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD_FRAGMENT="$REPO_ROOT/bubbles/scripts/guards/tail-delegated-gates.sh"

if [[ ! -f "$GUARD_FRAGMENT" ]]; then
  echo "test_35_human_acceptance_terminal: guard fragment missing: $GUARD_FRAGMENT" >&2
  exit 2
fi

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
  awk '
    /^## Checklist/ {in_checklist=1; next}
    /^## / {if (in_checklist) exit}
    in_checklist {print}
  ' "$1" | grep -cE '^- \[ \] ' || true
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

# --- The guard fragment must actually carry the gate ------------------------
if grep -q 'Gate G136' "$GUARD_FRAGMENT"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: guard fragment declares Gate G136\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: guard fragment no longer declares Gate G136\n'
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
if grep -nE '^\s*(sed -i|>+\s*"?\$uservalidation_terminal_file)' "$GUARD_FRAGMENT" | grep -q .; then
  fail_count=$((fail_count + 1))
  printf '  FAIL: the guard writes to uservalidation.md — it must only report\n'
else
  pass_count=$((pass_count + 1))
  printf '  PASS: the guard never writes to uservalidation.md\n'
fi

printf 'test_35_human_acceptance_terminal: %s passed, %s failed\n' "$pass_count" "$fail_count"
[[ "$fail_count" -eq 0 ]] || exit 1
exit 0
