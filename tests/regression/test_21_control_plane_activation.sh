#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for the control-plane policy-activation fix
# (gates G055-G060). Stages disposable spec fixtures with NO policySnapshot and a
# repo SST config (.specify/memory/bubbles.config.json) declaring
# tdd.mode=scenario-first, then runs the REAL state-transition-guard.sh and
# asserts on its Check 3A / Check 3E output:
#
#   * Check 3A (G055) no longer HARD-FAILS on a missing policySnapshot — it
#     resolves provenance from the SST config and PASSES.
#   * Check 3E (G060) ACTIVATES from the SST default (scenario-first) instead of
#     silently skipping, and enforces a REAL red->green ordering:
#       - a report whose only TDD content is the word 'tdd' FAILS (the old
#         keyword grep would have rubber-stamped it);
#       - a report with a red-stage marker before a green-stage marker PASSES;
#       - a pre-cutoff snapshot-less spec is GRANDFATHERED (not retro-broken).
#
# Assertions are on guard OUTPUT LINES (not exit code): the minimal fixtures fail
# other unrelated checks, so the overall exit code is not a clean signal — the
# specific Check 3A/3E lines are. This mirrors state-transition-guard-selftest.sh.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/state-transition-guard.sh"

if [[ ! -f "$GUARD" ]]; then
  echo "test_21_control_plane_activation: guard not found: $GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-cp-activation-regression-XXXXXXXX)"
trap 'rm -rf "$WORKSPACE"' EXIT INT TERM

pass_count=0
fail_count=0

assert_log_contains() {
  local log="$1" needle="$2" description="$3"
  if grep -qF -- "$needle" "$log"; then
    pass_count=$((pass_count + 1))
    printf '  PASS: %s\n' "$description"
  else
    fail_count=$((fail_count + 1))
    printf '  FAIL: %s (missing: %s)\n' "$description" "$needle"
  fi
}

assert_log_not_contains() {
  local log="$1" needle="$2" description="$3"
  if grep -qF -- "$needle" "$log"; then
    fail_count=$((fail_count + 1))
    printf '  FAIL: %s (unexpected: %s)\n' "$description" "$needle"
  else
    pass_count=$((pass_count + 1))
    printf '  PASS: %s\n' "$description"
  fi
}

# Repo SST config: activates the control-plane default tdd.mode=scenario-first.
mkdir -p "$WORKSPACE/.specify/memory"
cat > "$WORKSPACE/.specify/memory/bubbles.config.json" <<'EOF'
{
  "version": 2,
  "defaults": {
    "grill": { "mode": "off", "source": "repo-default" },
    "tdd": { "mode": "scenario-first", "source": "repo-default" },
    "lockdown": { "default": false, "source": "repo-default" },
    "regression": { "immutability": "protected-scenarios", "source": "repo-default" },
    "validation": { "certificationRequired": true, "source": "repo-default" }
  }
}
EOF

# Stage the shared artifact skeleton for a fixture spec (NO policySnapshot).
# $1 = spec dir, $2 = createdAt timestamp.
stage_spec() {
  local dir="$1" created_at="$2"
  mkdir -p "$dir"
  cat > "$dir/state.json" <<EOF
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "full-delivery",
  "createdAt": "$created_at"
}
EOF
  cat > "$dir/spec.md" <<'EOF'
# Control-Plane Activation Fixture Spec

## Summary

A minimal coherent fixture used to exercise the real transition guard's
control-plane Check 3A/3E behavior without a per-spec policySnapshot.
EOF
  cat > "$dir/design.md" <<'EOF'
# Design

Resolve effective TDD mode from the repo SST config and enforce real ordering.
EOF
  cat > "$dir/uservalidation.md" <<'EOF'
# User Validation

## Checklist

- [x] Baseline control-plane activation fixture is available for the regression.
EOF
  cat > "$dir/scopes.md" <<'EOF'
# Scope 01: Control-Plane Activation Fixture

**Status:** In Progress

### Goal

Keep the fixture small while exercising the real transition guard's
control-plane checks.

### Definition of Done

- [ ] Implementation behavior is complete for this scope
- [ ] Scenario evidence is recorded for this scope
EOF
}

echo "=== Regression: control-plane policy activation (G055-G060) ==="

# ── Fixture 1: ACTIVATION + Check 3A fallback + Check 3E FAIL ────────────────
# No policySnapshot, post-cutoff createdAt, report WITHOUT red->green ordering.
f1="$WORKSPACE/specs/991-activation-fail"
stage_spec "$f1" "2026-07-01T00:00:00Z"
cat > "$f1/report.md" <<'EOF'
# Report

### Summary

Implemented the export feature and recorded the evidence in this report.

### Completion Statement

The fixture is shaped to reach the control-plane checks; no ordered TDD proof is
present here on purpose.
EOF
set +e
bash "$GUARD" "$f1" > "$f1/guard.log" 2>&1
set -e
assert_log_contains "$f1/guard.log" "control-plane provenance resolved from the repo SST config" \
  "Check 3A (G055) resolves provenance from the SST config instead of hard-failing on a missing snapshot"
assert_log_contains "$f1/guard.log" "the word 'tdd' alone is not evidence" \
  "Check 3E (G060) activates from the SST default and FAILS without red->green ordering"

# ── Fixture 2: ADVERSARIAL keyword-only 'tdd' MUST still fail ────────────────
f2="$WORKSPACE/specs/992-keyword-only"
stage_spec "$f2" "2026-07-01T00:00:00Z"
cat > "$f2/report.md" <<'EOF'
# Report

### Summary

We applied tdd to this change and wired the handler into the router.

### Completion Statement

The only TDD-related content here is the literal word above; there is no ordered
failing-then-fixed proof.
EOF
set +e
bash "$GUARD" "$f2" > "$f2/guard.log" 2>&1
set -e
assert_log_contains "$f2/guard.log" "the word 'tdd' alone is not evidence" \
  "Check 3E (G060) FAILS on keyword-only 'tdd' (old keyword grep would have rubber-stamped it)"
assert_log_not_contains "$f2/guard.log" "ordering is recorded in the scope/report artifacts" \
  "Check 3E (G060) does NOT pass the keyword-only report"

# ── Fixture 3: RED->GREEN ordering PASSES ───────────────────────────────────
f3="$WORKSPACE/specs/993-ordered"
stage_spec "$f3" "2026-07-01T00:00:00Z"
cat > "$f3/report.md" <<'EOF'
# Report

### TDD Evidence

RED: ran the targeted test before the fix
test result: FAILED. 0 passed; 1 failed

Applied the isolation fix.

GREEN: ran the targeted test after the fix
test result: ok. 1 passed; 0 failed
EOF
set +e
bash "$GUARD" "$f3" > "$f3/guard.log" 2>&1
set -e
assert_log_contains "$f3/guard.log" "ordering is recorded in the scope/report artifacts" \
  "Check 3E (G060) PASSES on a real red-stage-then-green-stage report"

# ── Fixture 4: GRANDFATHER (pre-cutoff, snapshot-less, no ordering) ──────────
f4="$WORKSPACE/specs/994-grandfathered"
stage_spec "$f4" "2026-05-01T00:00:00Z"
cat > "$f4/report.md" <<'EOF'
# Report

### Summary

A historical fixture created before the activation cutoff with no ordered proof.
EOF
set +e
bash "$GUARD" "$f4" > "$f4/guard.log" 2>&1
set -e
assert_log_contains "$f4/guard.log" "[G060-GRANDFATHERED]" \
  "Check 3E (G060) downgrades a pre-cutoff snapshot-less spec to grandfathered INFO"
assert_log_not_contains "$f4/guard.log" "the word 'tdd' alone is not evidence" \
  "Check 3E (G060) does NOT hard-fail a grandfathered spec"

echo ""
echo "test_21_control_plane_activation: $pass_count passed / $fail_count failed"
if [[ "$fail_count" -ne 0 ]]; then
  exit 1
fi
echo "PASS"
