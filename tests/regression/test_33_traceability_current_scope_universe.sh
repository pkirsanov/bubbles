#!/usr/bin/env bash
set -uo pipefail

# BUG-026 C2 persistent regression: traceability-guard.sh MUST honor the
# scope-universe contract when invoked with the valueless --current-scope token.
#
# In --current-scope mode the guard resolves the immutable applicable universe
# from state.json via scope-universe-resolver.py and analyzes ONLY the applicable
# scope directories: the current scope, its transitive prerequisites, and
# applicable siblings. A not_started DESCENDANT of the current scope MUST be
# omitted (it is not yet in play, so its incomplete artifacts must not fail the
# gate). The default --all-scopes mode is unchanged and analyzes every scope.
#
# The two-mode diff on ONE fixture is the adversarial proof: the not_started
# descendant `scopes/03-later` appears under --all-scopes but MUST NOT appear
# under --current-scope. If the universe filter is ever removed or bypassed, the
# descendant reappears and this test goes RED. The test also proves the CLI is
# fail-closed: unknown/valued/surplus tokens and an un-mappable state (records
# without scopeDir) are hard refusals (exit 2), never a silent full-scan.
#
# Exit codes: 0 = clean (GREEN), 1 = contract failure (RED), 2 = harness error.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/traceability-guard.sh"
RESOLVER="$REPO_ROOT/bubbles/scripts/scope-universe-resolver.py"

for required_path in "$GUARD" "$RESOLVER" "${BASH_SOURCE[0]}"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_33_traceability_current_scope_universe: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done
if [[ ! -d "$REPO_ROOT/bubbles" ]]; then
  printf '%s\n' 'test_33_traceability_current_scope_universe: canonical framework surface is missing' >&2
  exit 2
fi
for required_command in awk grep mktemp rm python3 find basename dirname; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'test_33_traceability_current_scope_universe: required command unavailable: %s\n' "$required_command" >&2
    exit 2
  fi
done

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug026c2-XXXXXXXX")" || {
  printf '%s\n' 'test_33_traceability_current_scope_universe: cannot create workspace' >&2
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

# write_scope <dir> — minimal scope.md; the guard only needs the file to exist
# to emit "Checking traceability for <label>". Content-level traceability
# failures do not suppress that line, so the presence/absence assertion holds.
write_scope() {
  local dir="$1"
  mkdir -p "$dir"
  cat >"$dir/scope.md" <<'SCOPE'
# Scope

## Definition of Done

- [ ] placeholder item
SCOPE
}

# build_feature <dir> <with_scopedir:yes|no>
build_feature() {
  local feature="$1"
  local with_scopedir="$2"
  mkdir -p "$feature/scopes"
  printf '%s\n' '# scopes index' >"$feature/scopes/_index.md"
  write_scope "$feature/scopes/01-foundation"
  write_scope "$feature/scopes/02-current"
  write_scope "$feature/scopes/03-later"
  if [[ "$with_scopedir" == "yes" ]]; then
    cat >"$feature/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "scopeLayout": "per-scope-directory",
  "certification": {
    "status": "in_progress",
    "scopeProgress": [
      {"scope": 1, "status": "done", "dependsOn": [], "scopeDir": "scopes/01-foundation"},
      {"scope": 2, "status": "in_progress", "dependsOn": ["1"], "scopeDir": "scopes/02-current"},
      {"scope": 3, "status": "not_started", "dependsOn": ["2"], "scopeDir": "scopes/03-later"}
    ]
  },
  "execution": {"currentScope": 2, "currentPhase": "implement"}
}
JSON
  else
    cat >"$feature/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "scopeLayout": "per-scope-directory",
  "certification": {
    "status": "in_progress",
    "scopeProgress": [
      {"scope": 1, "status": "done", "dependsOn": []},
      {"scope": 2, "status": "in_progress", "dependsOn": ["1"]},
      {"scope": 3, "status": "not_started", "dependsOn": ["2"]}
    ]
  },
  "execution": {"currentScope": 2, "currentPhase": "implement"}
}
JSON
  fi
}

FEATURE="$WORKSPACE/specs/033-universe"
build_feature "$FEATURE" yes

NO_DIR_FEATURE="$WORKSPACE/specs/033-nodir"
build_feature "$NO_DIR_FEATURE" no

DESCENDANT_MARK="Checking traceability for scopes/03-later/scope.md"
CURRENT_MARK="Checking traceability for scopes/02-current/scope.md"
PREREQ_MARK="Checking traceability for scopes/01-foundation/scope.md"

# ── Case 1: default (--all-scopes) analyzes every scope, descendant included ──
out_default="$(bash "$GUARD" "$FEATURE" 2>&1)"
if printf '%s\n' "$out_default" | grep -qF "$DESCENDANT_MARK"; then
  pass "default mode analyzes the not_started descendant (scopes/03-later)"
else
  fail "default mode did not analyze scopes/03-later (fixture/guard drift)"
fi

# ── Case 2: explicit --all-scopes matches the default ─────────────────────────
out_all="$(bash "$GUARD" "$FEATURE" --all-scopes 2>&1)"
if printf '%s\n' "$out_all" | grep -qF "$DESCENDANT_MARK"; then
  pass "explicit --all-scopes analyzes the not_started descendant"
else
  fail "explicit --all-scopes omitted scopes/03-later"
fi

# ── Case 3: --current-scope omits the not_started descendant, keeps the rest ──
out_current="$(bash "$GUARD" "$FEATURE" --current-scope 2>&1)"
if printf '%s\n' "$out_current" | grep -qF "$CURRENT_MARK"; then
  pass "--current-scope analyzes the current scope (scopes/02-current)"
else
  fail "--current-scope did not analyze the current scope"
fi
if printf '%s\n' "$out_current" | grep -qF "$PREREQ_MARK"; then
  pass "--current-scope analyzes the transitive prerequisite (scopes/01-foundation)"
else
  fail "--current-scope omitted the done prerequisite"
fi
if printf '%s\n' "$out_current" | grep -qF "$DESCENDANT_MARK"; then
  fail "--current-scope leaked the not_started descendant (universe filter bypassed)"
else
  pass "--current-scope omits the not_started descendant (scopes/03-later)"
fi

# ── Case 4: unknown second token is a hard refusal (exit 2) ───────────────────
bash "$GUARD" "$FEATURE" --bogus >/dev/null 2>&1
rc_bogus=$?
if [[ "$rc_bogus" -eq 2 ]]; then
  pass "unknown second token refused with exit 2"
else
  fail "unknown second token exit $rc_bogus (expected 2)"
fi

# ── Case 5: valued form of the token is a hard refusal (valueless only) ───────
bash "$GUARD" "$FEATURE" --current-scope=02-current >/dev/null 2>&1
rc_valued=$?
if [[ "$rc_valued" -eq 2 ]]; then
  pass "valued --current-scope=... refused with exit 2 (token is valueless)"
else
  fail "valued token exit $rc_valued (expected 2)"
fi

# ── Case 6: surplus third argument is a hard refusal (mutually exclusive) ──────
bash "$GUARD" "$FEATURE" --all-scopes --current-scope >/dev/null 2>&1
rc_surplus=$?
if [[ "$rc_surplus" -eq 2 ]]; then
  pass "surplus third argument refused with exit 2 (modes are mutually exclusive)"
else
  fail "surplus argument exit $rc_surplus (expected 2)"
fi

# ── Case 7: fail-closed when the state cannot be mapped (no scopeDir) ──────────
bash "$GUARD" "$NO_DIR_FEATURE" --current-scope >/dev/null 2>&1
rc_nodir=$?
if [[ "$rc_nodir" -eq 2 ]]; then
  pass "--current-scope on an un-mappable state (no scopeDir) refused with exit 2"
else
  fail "un-mappable state exit $rc_nodir (expected 2 fail-closed)"
fi

printf 'ASSERTIONS=%s PASSED=%s FAILED=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
exit 0
