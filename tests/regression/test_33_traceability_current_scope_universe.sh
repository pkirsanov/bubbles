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
# gate). The shared reader normalizes accepted v1 integer scopeRef values to
# decimal strings; traceability resolves that string only through the aliases
# emitted by scope-universe-resolver.py. The default --all-scopes mode is
# unchanged and analyzes every scope.
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

# ── Case 8: symbolic canonical identity maps to a distinct directory name ────
SYMBOLIC_FEATURE="$WORKSPACE/specs/034-symbolic"
build_feature "$SYMBOLIC_FEATURE" yes
python3 - "$SYMBOLIC_FEATURE/state.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    state = json.load(handle)
for registry in (state["certification"]["scopeProgress"],):
    registry[1]["scopeId"] = "payments-core"
state["execution"]["currentScope"] = "payments-core"
with open(path, "w", encoding="utf-8") as handle:
    json.dump(state, handle, indent=2)
    handle.write("\n")
PY
out_symbolic="$(bash "$GUARD" "$SYMBOLIC_FEATURE" --current-scope 2>&1)"
if [[ "$out_symbolic" == *"$CURRENT_MARK"* ]]; then
  pass "symbolic scopeId resolves to the unique physical directory named by scopeDir"
else
  fail "symbolic scopeId did not map to scopes/02-current"
fi

# ── Cases 9-10: reader-projected v1 integer and migrated string are equal ─────
MANIFEST_FEATURE="$WORKSPACE/specs/035-manifest-aliases"
build_feature "$MANIFEST_FEATURE" yes
cat >"$MANIFEST_FEATURE/scopes/02-current/scope.md" <<'SCOPE'
# Scope 02: Current

**Status:** In Progress

## Gherkin

### SCN-035-001

Scenario: Current scope alias
  Given the current scope registry
  When the manifest names a resolver-owned alias
  Then traceability maps it to one physical scope

## Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| E2E | e2e-ui | tests/current.spec.ts | SCN-035-001 current scope alias | selftest:current | Yes |

## Definition of Done

- [ ] SCN-035-001 current scope alias -> Evidence: report.md#test-evidence
SCOPE
cat >"$MANIFEST_FEATURE/scenario-manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-035-001",
      "scopeRef": 2,
      "title": "Current scope alias",
      "plannedTests": [{"path": "tests/current.spec.ts", "title": "current", "type": "e2e-ui"}],
      "evidenceRefs": []
    }
  ]
}
JSON
out_integer="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
if [[ "$out_integer" != *"scope reference resolves to 0 physical scopes"* ]]; then
  pass "v1 integer scopeRef is reader-normalized and accepted via resolver decimal alias"
else
  fail "v1 integer scopeRef did not resolve through resolver aliases"
fi
python3 - "$MANIFEST_FEATURE/scenario-manifest.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    document = json.load(handle)
document["scenarios"][0]["scopeRef"] = "2"
with open(path, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2)
    handle.write("\n")
PY
out_string="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
if [[ "$out_string" != *"scope reference resolves to 0 physical scopes"* ]]; then
  pass "migrated decimal string scopeRef resolves through the same alias"
else
  fail "migrated decimal string scopeRef did not resolve"
fi

# ── Cases 11-13: exact projected scenario reconciliation is fail-closed ──────
python3 - "$MANIFEST_FEATURE/scenario-manifest.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    document = json.load(handle)
document["scenarios"][0]["scenarioId"] = "SCN-035-999"
with open(path, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2)
    handle.write("\n")
PY
out_substituted="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
rc_substituted=$?
if [[ "$rc_substituted" -eq 1 ]]; then
  pass "equal scenario counts with a substituted stable id exit 1"
else
  fail "substituted stable id exit $rc_substituted (expected 1)"
fi
if [[ "$out_substituted" == *"identified-subset exact matching failed for known stable scenario id: SCN-035-001 expected=1 actual=0"* ]]; then
  pass "equal scenario counts with a substituted stable id are refused by identified-subset reconciliation"
else
  fail "substituted stable id did not produce the identified-subset refusal"
  printf '%s\n' "$out_substituted"
fi

python3 - "$MANIFEST_FEATURE/scenario-manifest.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    document = json.load(handle)
document["scenarios"][0]["scenarioId"] = "SCN-035-001"
extra = dict(document["scenarios"][0])
extra["scenarioId"] = "SCN-035-002"
document["scenarios"].append(extra)
with open(path, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2)
    handle.write("\n")
PY
out_surplus="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
rc_surplus_manifest=$?
if [[ "$rc_surplus_manifest" -eq 1 ]]; then
  pass "surplus manifest scenario records exit 1"
else
  fail "surplus manifest scenario record exit $rc_surplus_manifest (expected 1)"
fi
if [[ "$out_surplus" == *"legacy residual cardinality differs after identified-subset exact matching: expected=0 actual=1"* ]]; then
  pass "surplus manifest scenario records are refused by legacy-residual reconciliation"
else
  fail "surplus manifest scenario record did not produce the legacy-residual refusal"
  printf '%s\n' "$out_surplus"
fi

python3 - "$MANIFEST_FEATURE/scenario-manifest.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    document = json.load(handle)
document["scenarios"][1]["scenarioId"] = "SCN-035-001"
document["scenarios"][1]["scopeRef"] = 2
with open(path, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2)
    handle.write("\n")
PY
out_physical_alias_duplicate="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
if [[ "$out_physical_alias_duplicate" == *"scenario SCN-035-001: duplicate effective scenario id"* ]]; then
  pass "physical-scope aliases cannot hide duplicate scenario records"
else
  fail "physical-scope aliases hid duplicate scenario records"
fi

# ── Case 14: traceability never invents a SCOPE-* alias ───────────────────────
python3 - "$MANIFEST_FEATURE/scenario-manifest.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    document = json.load(handle)
document["scenarios"][0]["scopeRef"] = "SCOPE-02"
document["scenarios"] = document["scenarios"][:1]
with open(path, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2)
    handle.write("\n")
PY
out_unknown="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
if [[ "$out_unknown" == *"scope reference resolves to 0 physical scopes"* ]]; then
  pass "consumer-created SCOPE-02 alias is refused"
else
  fail "traceability synthesized an alias absent from resolver output"
fi

# ── Case 15: colliding resolver aliases fail before projection ────────────────
AMBIGUOUS_FEATURE="$WORKSPACE/specs/036-ambiguous"
build_feature "$AMBIGUOUS_FEATURE" yes
python3 - "$AMBIGUOUS_FEATURE/state.json" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as handle:
    state = json.load(handle)
registry = state["certification"]["scopeProgress"]
registry[1]["scopeId"] = "current-symbolic"
registry[1]["scope"] = "shared"
registry[2]["scopeId"] = "future-symbolic"
registry[2]["scope"] = "shared"
registry[2]["dependsOn"] = ["current-symbolic"]
state["execution"]["currentScope"] = "shared"
with open(path, "w", encoding="utf-8") as handle:
    json.dump(state, handle, indent=2)
    handle.write("\n")
PY
out_ambiguous="$(bash "$GUARD" "$AMBIGUOUS_FEATURE" --current-scope 2>&1)"
if [[ "$out_ambiguous" == *"scope-universe-resolver: ambiguous scope alias 'shared' identifies canonical scopes: current-symbolic, future-symbolic"* ]]; then
  pass "colliding resolver-owned alias is refused deterministically"
else
  fail "colliding resolver alias did not fail closed"
fi

# ── Cases 16-18: bool, zero, and negative scopeRef remain reader-invalid ──────
for invalid_scope_ref in true 0 -1; do
  python3 - "$MANIFEST_FEATURE/scenario-manifest.json" "$invalid_scope_ref" <<'PY'
import json
import sys

path, token = sys.argv[1:]
value = True if token == "true" else int(token)
with open(path, encoding="utf-8") as handle:
    document = json.load(handle)
document["scenarios"][0]["scopeRef"] = value
with open(path, "w", encoding="utf-8") as handle:
    json.dump(document, handle, indent=2)
    handle.write("\n")
PY
  out_invalid="$(bash "$GUARD" "$MANIFEST_FEATURE" --current-scope 2>&1)"
  if [[ "$out_invalid" == *"must be a nonblank string or positive integer"* ]]; then
    pass "invalid scopeRef $invalid_scope_ref is refused by the shared reader"
  else
    fail "invalid scopeRef $invalid_scope_ref did not produce the reader refusal"
  fi
done

printf 'ASSERTIONS=%s PASSED=%s FAILED=%s\n' "$((PASS_COUNT + FAIL_COUNT))" "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
exit 0
