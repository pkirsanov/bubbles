#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for Gate G097 - requirement_mechanism_correspondence_gate.
# Stages minimal disposable spec fixtures and asserts the guard BLOCKs a
# requirement that names a concrete mechanism with no matching code evidence
# and no justification (the smackerel PKCE-fake shape), while passing both a
# real implementation (synonym evidence) and a disclosed naming difference.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/requirement-mechanism-guard.sh"

if [[ ! -x "$GUARD" ]]; then
  echo "test_19_requirement_mechanism: guard not executable: $GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-g097-regression-XXXXXXXX)"
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

# Stage a fake repo root with specs/097-fixture so the guard resolves repo_root
# via the */specs/* fallback (mktemp is not a git repo). Emits the spec dir.
stage() {
  local name="$1" created="$2"
  local root="$WORKSPACE/$name"
  local spec="$root/specs/097-fixture"
  mkdir -p "$spec" "$root/src"
  cat > "$spec/state.json" <<EOF
{
  "version": 3,
  "status": "in_progress",
  "createdAt": "$created"
}
EOF
  printf '%s' "$spec"
}

echo "=== Regression: Gate G097 requirement_mechanism_correspondence_gate ==="

# --- Adversarial: named mechanism absent from code, new spec, no justification ---
bad_spec="$(stage requirement-mechanism-fake 2026-06-09)"
bad_root="$WORKSPACE/requirement-mechanism-fake"
cat > "$bad_spec/spec.md" <<'EOF'
# OAuth Connector

## Requirements

- NC-1: The connector MUST authenticate using OAuth2 with PKCE (code_verifier).
EOF
cat > "$bad_spec/scopes.md" <<'EOF'
# Scopes

### Implementation Files

- `src/connector.go`
EOF
cat > "$bad_root/src/connector.go" <<'EOF'
package connector

// Authenticate attaches a static bearer token — no PKCE, no OAuth2 exchange.
func Authenticate(token string) error {
	return doRequest("Authorization", "Bearer "+token)
}
EOF
set +e
bash "$GUARD" "$bad_spec" > "$bad_spec/stdout.log" 2> "$bad_spec/stderr.log"
bad_rc=$?
set -e
assert_exit "named-mechanism-absent plan is blocked" 1 "$bad_rc"
if grep -qF "G097 BLOCK" "$bad_spec/stdout.log" && grep -qF "PKCE" "$bad_spec/stdout.log"; then
  pass_count=$((pass_count + 1))
  printf '  PASS: fake diagnostics name the missing mechanism (PKCE)\n'
else
  fail_count=$((fail_count + 1))
  printf '  FAIL: fake diagnostics missing expected BLOCK/PKCE tokens\n'
  cat "$bad_spec/stdout.log" >&2
fi

# --- Real implementation: synonym evidence clears it ---
good_spec="$(stage requirement-mechanism-real 2026-06-09)"
good_root="$WORKSPACE/requirement-mechanism-real"
cat > "$good_spec/spec.md" <<'EOF'
# OAuth Connector

## Requirements

- NC-1: The connector MUST authenticate using PKCE.
EOF
cat > "$good_spec/scopes.md" <<'EOF'
# Scopes

### Implementation Files

- `src/connector.go`
EOF
cat > "$good_root/src/connector.go" <<'EOF'
package connector

// buildAuthURL performs the PKCE code_verifier / code_challenge exchange.
func buildAuthURL(codeVerifier string) string {
	return "code_challenge=" + sha256B64(codeVerifier)
}
EOF
set +e
bash "$GUARD" "$good_spec" > "$good_spec/stdout.log" 2>&1
good_rc=$?
set -e
assert_exit "real PKCE implementation passes" 0 "$good_rc"

# --- Disclosed naming difference: justification clears it ---
just_spec="$(stage requirement-mechanism-justified 2026-06-09)"
just_root="$WORKSPACE/requirement-mechanism-justified"
cat > "$just_spec/spec.md" <<'EOF'
# OAuth Connector

## Requirements

- NC-1: The connector MUST authenticate using PKCE.

## Requirement-Mechanism Justifications

- PKCE: the upstream IdP rejects PKCE for confidential clients; we use the
  authorization_code grant with a server-side secret instead. Reviewed.
EOF
cat > "$just_spec/scopes.md" <<'EOF'
# Scopes

### Implementation Files

- `src/connector.go`
EOF
cat > "$just_root/src/connector.go" <<'EOF'
package connector

func exchange(code, secret string) error { return postForm("authorization_code", code, secret) }
EOF
set +e
bash "$GUARD" "$just_spec" > "$just_spec/stdout.log" 2>&1
just_rc=$?
set -e
assert_exit "disclosed naming difference passes" 0 "$just_rc"

# --- Grandfather: same gap as the fake, but pre-cutoff createdAt ---
old_spec="$(stage requirement-mechanism-grandfathered 2026-05-01)"
old_root="$WORKSPACE/requirement-mechanism-grandfathered"
cat > "$old_spec/spec.md" <<'EOF'
# OAuth Connector

## Requirements

- NC-1: The connector MUST authenticate using PKCE.
EOF
cat > "$old_spec/scopes.md" <<'EOF'
# Scopes

### Implementation Files

- `src/connector.go`
EOF
cat > "$old_root/src/connector.go" <<'EOF'
package connector
func Authenticate(token string) error { return nil }
EOF
set +e
bash "$GUARD" "$old_spec" > "$old_spec/stdout.log" 2>&1
old_rc=$?
set -e
assert_exit "pre-cutoff spec is grandfathered (warn, not block)" 0 "$old_rc"

echo
echo "=== test_19_requirement_mechanism: $pass_count passed, $fail_count failed ==="
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
exit 0
