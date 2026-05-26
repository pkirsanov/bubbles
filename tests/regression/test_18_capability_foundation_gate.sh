#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G094 - capability_foundation_gate.
# Stages minimal disposable spec fixtures and asserts the guard passes a
# capability-first notification plan while blocking a provider-first plan.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/capability-foundation-guard.sh"

if [[ ! -x "$GUARD" ]]; then
  echo "test_18_capability_foundation_gate: guard not executable: $GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-g094-regression-XXXXXXXX)"
trap 'rm -rf "$WORKSPACE"' EXIT INT TERM

pass_count=0
fail_count=0

assert_exit() {
  local description="$1"
  local expected="$2"
  local actual="$3"
  if [[ "$actual" -eq "$expected" ]]; then
    pass_count=$((pass_count + 1))
    printf '  PASS: %s (exit=%s)\n' "$description" "$actual"
  else
    fail_count=$((fail_count + 1))
    printf '  FAIL: %s (expected=%s actual=%s)\n' "$description" "$expected" "$actual"
  fi
}

stage_state() {
  local dir="$1"
  mkdir -p "$dir"
  cat > "$dir/state.json" <<'EOF'
{
  "version": 3,
  "featureDir": "specs/094-capability-foundation-fixture",
  "status": "in_progress",
  "workflowMode": "spec-scope-hardening",
  "createdAt": "2026-05-25T00:00:00Z"
}
EOF
}

echo "=== Regression: Gate G094 capability_foundation_gate ==="

bad_spec="$WORKSPACE/provider-first"
stage_state "$bad_spec"
cat > "$bad_spec/spec.md" <<'EOF'
# Provider First Notifications

## Summary

Add an ntfy provider and wire the channel directly into callers.
EOF
cat > "$bad_spec/design.md" <<'EOF'
# Design

Call ntfy from the notification path. This provider is the implementation.
EOF
set +e
bash "$GUARD" "$bad_spec" > "$bad_spec/stdout.log" 2> "$bad_spec/stderr.log"
bad_rc=$?
set -e
assert_exit "provider-first plan is blocked" 1 "$bad_rc"
if grep -qF "Domain Capability Model" "$bad_spec/stderr.log" && grep -qF "Capability Foundation" "$bad_spec/stderr.log"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: provider-first diagnostics cite missing foundation sections\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: provider-first diagnostics missing expected section names\n'
  cat "$bad_spec/stderr.log" >&2
fi

good_spec="$WORKSPACE/capability-first"
stage_state "$good_spec"
cat > "$good_spec/spec.md" <<'EOF'
# Notification Capability

## Domain Capability Model

NotificationIntent and DeliveryAttempt define provider-neutral delivery.

## UI Wireframes

### UI Primitives

| Primitive | Used By Screens | Composition Rule |
|-----------|-----------------|------------------|
| Provider badge | Provider setup, notification detail | Same state labels |

### Screen: Provider Setup

[setup]

### Screen: Notification Detail

[detail]
EOF
cat > "$good_spec/design.md" <<'EOF'
# Design

## Capability Foundation

NotificationDispatcher routes intents through provider adapters.

## Concrete Implementations

### ntfy Adapter

Uses the provider adapter contract.

### Email Adapter

Uses the provider adapter contract.

### Variation Axes

| Axis | Options |
|------|---------|
| Provider protocol | ntfy, email |
| Delivery timing | immediate, digest |
EOF
cat > "$good_spec/scopes.md" <<'EOF'
# Scopes

## Scope 1: Notification Foundation
**Status:** Not Started
**Tags:** foundation:true
**Depends On:** none

## Scope 2: ntfy Adapter
**Status:** Not Started
**Depends On:** Scope 1 - Notification Foundation

## Scope 3: Email Adapter
**Status:** Not Started
**Depends On:** Scope 1 - Notification Foundation
EOF
set +e
bash "$GUARD" "$good_spec" > "$good_spec/stdout.log" 2> "$good_spec/stderr.log"
good_rc=$?
set -e
assert_exit "capability-first plan passes" 0 "$good_rc"

old_spec="$WORKSPACE/grandfathered"
stage_state "$old_spec"
cat > "$old_spec/state.json" <<'EOF'
{
  "version": 3,
  "featureDir": "specs/old-provider-fixture",
  "status": "done",
  "workflowMode": "full-delivery",
  "createdAt": "2026-05-24T23:59:59Z"
}
EOF
cat > "$old_spec/spec.md" <<'EOF'
# Old Provider Spec

This old spec mentions a provider before G094 existed.
EOF
set +e
bash "$GUARD" "$old_spec" > "$old_spec/stdout.log" 2> "$old_spec/stderr.log"
old_rc=$?
set -e
assert_exit "pre-G094 spec is grandfathered" 0 "$old_rc"

echo ""
printf 'Assertions passed: %d\n' "$pass_count"
printf 'Assertions failed: %d\n' "$fail_count"

if [[ "$fail_count" -gt 0 ]]; then
  echo "test_18_capability_foundation_gate: REGRESSION FAILED" >&2
  exit 1
fi

echo "test_18_capability_foundation_gate: REGRESSION PASSED"
exit 0
