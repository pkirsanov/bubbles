#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G130 - domain_invariant_correspondence_gate.
# Stages minimal disposable fake-repo fixtures (each with a
# .github/bubbles-project.yaml domainModel block) and asserts the guard BLOCKs a
# declared invariant with no enforcedBy code evidence, no adversarial provedBy
# test, and no justification (the prose-only-invariant shape), while passing an
# adversarial proving test, a real code-evidence enforcement, and a disclosed
# justification, and grandfathering a pre-cutoff spec.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/domain-invariant-guard.sh"

if [[ ! -x "$GUARD" ]]; then
  echo "test_34_domain_invariant: guard not executable: $GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-g130-regression-XXXXXXXX)"
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

# Stage a fake repo root with .github/bubbles-project.yaml and a
# specs/130-fixture spec dir. Args: name, createdAt, provedBy-entry. Emits the
# SPEC DIR path (the guard walks up to find the project config).
stage() {
  local name="$1" created="$2" proved="$3"
  local root="$WORKSPACE/$name"
  local spec="$root/specs/130-fixture"
  mkdir -p "$root/.github" "$spec" "$root/src" "$root/tests" "$root/migrations"
  cat > "$root/.github/bubbles-project.yaml" <<EOF
scans: {}
domainModel:
  entities:
    Order: { states: [created, paid, shipped, refunded], terminal: [refunded] }
  invariants:
    - id: INV-ORDER-STATUS-ENUM
      rule: "Order.status in {created, paid, shipped, refunded}"
      kind: enumeration
      enforcedBy: [db-constraint, type]
      provedBy: ["$proved"]
EOF
  cat > "$spec/state.json" <<EOF
{
  "version": 3,
  "status": "in_progress",
  "createdAt": "$created"
}
EOF
  cat > "$spec/scopes.md" <<'EOF'
# Scopes

### Implementation Files

- `src/order.rs`
EOF
  cat > "$spec/spec.md" <<'EOF'
# Order Service

## Requirements

- FR-1: order status transitions through created, paid, shipped, refunded.
EOF
  # Plain-string Order impl: NO enum, NO db constraint -> no enforcedBy evidence.
  cat > "$root/src/order.rs" <<'EOF'
pub struct Order { pub status: String }

pub fn set_status(o: &mut Order, s: String) {
    o.status = s;
}
EOF
  printf '%s' "$spec"
}

echo "=== Regression: Gate G130 domain_invariant_correspondence_gate ==="

# --- Adversarial: declared invariant, no anchor, happy provedBy, new spec ---
bad_spec="$(stage domain-invariant-unanchored 2026-07-28 tests/order_status_test.rs::test_happy_path)"
bad_root="$WORKSPACE/domain-invariant-unanchored"
cat > "$bad_root/tests/order_status_test.rs" <<'EOF'
#[test]
fn test_happy_path() {
    let mut o = Order { status: String::new() };
    set_status(&mut o, "paid".into());
    assert_eq!(o.status, "paid");
}
EOF
set +e
bash "$GUARD" "$bad_spec" > "$bad_spec/stdout.log" 2> "$bad_spec/stderr.log"
bad_rc=$?
set -e
assert_exit "declared invariant with no anchor is blocked" 1 "$bad_rc"
if grep -qF "G130 BLOCK" "$bad_spec/stdout.log" && grep -qF "INV-ORDER-STATUS-ENUM" "$bad_spec/stdout.log"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: block diagnostics name the unanchored invariant (INV-ORDER-STATUS-ENUM)\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: block diagnostics missing expected BLOCK/INV-id tokens\n'
  cat "$bad_spec/stdout.log" >&2
fi

# --- Adversarial provedBy test clears it ---
good_spec="$(stage domain-invariant-adversarial 2026-07-28 tests/order_status_test.rs::rejects_unknown_status)"
good_root="$WORKSPACE/domain-invariant-adversarial"
cat > "$good_root/tests/order_status_test.rs" <<'EOF'
#[test]
fn rejects_unknown_status() {
    let mut o = Order { status: String::new() };
    let result = try_set_status(&mut o, "bogus".into());
    assert!(result.is_err(), "an unknown status must be rejected");
}
EOF
set +e
bash "$GUARD" "$good_spec" > "$good_spec/stdout.log" 2>&1
good_rc=$?
set -e
assert_exit "adversarial provedBy test anchors the invariant" 0 "$good_rc"

# --- Disclosed justification clears it ---
just_spec="$(stage domain-invariant-justified 2026-07-28 tests/order_status_test.rs::test_happy_path)"
just_root="$WORKSPACE/domain-invariant-justified"
cat > "$just_root/tests/order_status_test.rs" <<'EOF'
#[test]
fn test_happy_path() { assert_eq!(1, 1); }
EOF
cat >> "$just_spec/spec.md" <<'EOF'

## Domain-Invariant Justifications

- INV-ORDER-STATUS-ENUM: the enum is owned and enforced by the upstream payment
  gateway; this mirror service does not re-enforce it. Reviewed.
EOF
set +e
bash "$GUARD" "$just_spec" > "$just_spec/stdout.log" 2>&1
just_rc=$?
set -e
assert_exit "disclosed justification passes" 0 "$just_rc"

# --- Grandfather: same gap as the unanchored case, but pre-cutoff createdAt ---
old_spec="$(stage domain-invariant-grandfathered 2026-05-01 tests/order_status_test.rs::test_happy_path)"
old_root="$WORKSPACE/domain-invariant-grandfathered"
cat > "$old_root/tests/order_status_test.rs" <<'EOF'
#[test]
fn test_happy_path() { assert_eq!(1, 1); }
EOF
set +e
bash "$GUARD" "$old_spec" > "$old_spec/stdout.log" 2>&1
old_rc=$?
set -e
assert_exit "pre-cutoff spec is grandfathered (warn, not block)" 0 "$old_rc"

# --- No domainModel block: clean no-op ---
noop_root="$WORKSPACE/domain-invariant-noop"
noop_spec="$noop_root/specs/130-fixture"
mkdir -p "$noop_root/.github" "$noop_spec"
cat > "$noop_root/.github/bubbles-project.yaml" <<'EOF'
scans: {}
docsRegistryOverrides: {}
EOF
cat > "$noop_spec/spec.md" <<'EOF'
# Pagination
EOF
set +e
bash "$GUARD" "$noop_spec" > "$noop_spec/stdout.log" 2>&1
noop_rc=$?
set -e
assert_exit "no domainModel block is a clean no-op" 0 "$noop_rc"

echo
echo "=== test_34_domain_invariant: $pass_count passed, $fail_count failed ==="
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
exit 0
