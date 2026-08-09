#!/usr/bin/env bash
# Hermetic selftest for goal-contract.sh (IMP-038 SCOPE-1 / GF-1).
#
# Every case is adversarial: it fails if the guarantee it names regresses.
# In particular T3 (re-freeze refused), T7/T8 (substituted digest / revision
# rejected), and T9 (unapproved revision refused) are the three defects this
# script exists to prevent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GC="$SCRIPT_DIR/goal-contract.sh"
BOUNDARY_RESOLVER="$SCRIPT_DIR/work-boundary-resolve.sh"
SCHEMA="$REPO_ROOT/bubbles/schemas/goal-contract.schema.json"

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT INT TERM
FAILURES=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }
skip() { echo "SKIP: $1"; }

if ! command -v jq >/dev/null 2>&1; then
  echo "goal-contract-selftest: SKIP (jq not installed)"
  exit 0
fi
[[ -f "$GC" ]] || { echo "FAIL: $GC not found" >&2; exit 1; }

# new_case <name> — a fresh workspace; echoes its directory.
new_case() {
  local d="$TMP_ROOT/$1"
  mkdir -p "$d"
  printf 'Freeze the operator outcome before planning begins.\n' > "$d/request.txt"
  echo "$d"
}

# freeze_default <dir> [extra goal-contract.sh args...]
freeze_default() {
  local d="$1"; shift
  bash "$GC" freeze \
    --session-file "$d/session.json" \
    --source-request-file "$d/request.txt" \
    --intent "Freeze one immutable Goal Contract per mutable run" \
    --success-signal "goal-contract-selftest exits 0" \
    --hard-constraint "no new gate id in SCOPE-1" \
    --non-goal "phase-relevance resolver" \
    --target "repository=bubbles" \
    --target "spec=specs/038-goal-fidelity" \
    --repository-root bubbles \
    --spec-target specs/038-goal-fidelity \
    --allowed-path 'bubbles/scripts/**' \
    --runner bubbles.goal \
    --session-id vscode-abc123 \
    --repository-alias bubbles \
    ${1+"$@"}
}

# expect_rc <label> <expected-rc> <command...>
expect_rc() {
  local label="$1" want="$2"; shift 2
  local rc=0
  "$@" >/dev/null 2>&1 || rc=$?
  if [[ "$rc" -eq "$want" ]]; then
    pass "$label"
  else
    fail "$label (expected exit $want, got $rc)"
  fi
}

# expect_field <label> <session-file> <jq-path> <expected>
expect_field() {
  local label="$1" session="$2" path="$3" want="$4"
  local got rc=0
  got="$(bash "$GC" read --session-file "$session" --field "$path" 2>&1)" || rc=$?
  if [[ "$rc" -eq 0 && "$got" == "$want" ]]; then
    pass "$label"
  else
    fail "$label (rc=$rc, observed '$got', expected '$want')"
  fi
}

echo "Running goal-contract selftest..."

# ── T1 freeze produces a valid revision-1 auto-frozen contract ─────────────
d="$(new_case t1)"
if freeze_default "$d" >"$d/out.json" 2>"$d/err.txt"; then
  if [[ "$(jq -r '.revision' "$d/out.json")" == "1" ]] \
     && [[ "$(jq -r '.approval.state' "$d/out.json")" == "auto-frozen" ]] \
     && [[ "$(jq -r '.supersedes' "$d/out.json")" == "null" ]] \
     && [[ "$(jq -r '.goalId' "$d/out.json")" == "gc:vscode-abc123:1" ]] \
     && [[ "$(jq -r '.schemaVersion' "$d/out.json")" == "goal-contract/v1" ]]; then
    pass "T1 freeze -> revision 1, auto-frozen, supersedes=null, gc:<session>:1"
  else
    fail "T1 freeze produced the wrong shape: $(jq -c '{revision,approval,supersedes,goalId}' "$d/out.json")"
  fi
else
  fail "T1 freeze exited non-zero: $(cat "$d/err.txt")"
fi
expect_rc "T1b freeze result passes verify" 0 \
  bash "$GC" verify --session-file "$d/session.json"

# T1c the frozen contract validates against the real JSON Schema.
# jsonschema is OPTIONAL tooling: SKIP the assertion rather than hard-fail.
if python3 -c 'import jsonschema' >/dev/null 2>&1; then
  if python3 -c '
import json, sys, jsonschema
schema = json.load(open(sys.argv[1]))
doc = json.load(open(sys.argv[2]))
jsonschema.Draft202012Validator(schema).validate(doc)
' "$SCHEMA" "$d/out.json" >"$d/schema.err" 2>&1; then
    pass "T1c frozen contract validates against goal-contract.schema.json"
  else
    fail "T1c frozen contract failed schema validation: $(cat "$d/schema.err")"
  fi
else
  skip "T1c schema validation (python3 jsonschema not installed)"
fi

# T1d the emitted workBoundary is accepted by the REAL boundary resolver.
# This proves the schema mirrors work-boundary-resolve.sh rather than asserting it.
if [[ -f "$BOUNDARY_RESOLVER" ]]; then
  mkdir -p "$d/feature"
  jq '{ version: 3, status: "in_progress", workBoundary: .workBoundary }' "$d/out.json" \
    > "$d/feature/state.json"
  if bash "$BOUNDARY_RESOLVER" --feature-dir "$d/feature" --candidate-repo bubbles \
       --candidate-spec specs/038-goal-fidelity --candidate-path bubbles/scripts/x.sh \
       2>"$d/wb.err" | grep -qx 'disposition=in-boundary'; then
    pass "T1d frozen workBoundary is accepted in-boundary by work-boundary-resolve.sh"
  else
    fail "T1d work-boundary-resolve.sh rejected the frozen boundary: $(cat "$d/wb.err")"
  fi
else
  skip "T1d boundary cross-check (work-boundary-resolve.sh not found)"
fi

# ── T2 the digest is a deterministic function of the source-request bytes ──
d2="$(new_case t2)"
freeze_default "$d2" >"$d2/out.json" 2>/dev/null
digest_1="$(jq -r '.sourceRequestDigest' "$d/out.json")"
digest_2="$(jq -r '.sourceRequestDigest' "$d2/out.json")"
if [[ "$digest_1" == "$digest_2" && -n "$digest_1" ]]; then
  pass "T2 identical source-request bytes -> identical sourceRequestDigest"
else
  fail "T2 digest is not deterministic ('$digest_1' vs '$digest_2')"
fi

d2b="$(new_case t2b)"
printf 'A different operator request.\n' > "$d2b/request.txt"
freeze_default "$d2b" >"$d2b/out.json" 2>/dev/null
if [[ "$(jq -r '.sourceRequestDigest' "$d2b/out.json")" != "$digest_1" ]]; then
  pass "T2b different source-request bytes -> different digest"
else
  fail "T2b different bytes produced the same digest — the digest is not bound to the request"
fi

# ── T3 freezing twice is REFUSED (the silent-revision defect) ──────────────
expect_rc "T3 second freeze on an existing contract -> exit 3 (refused)" 3 \
  freeze_default "$d"
if [[ "$(jq -r '.goalContract.intent' "$d/session.json")" == "Freeze one immutable Goal Contract per mutable run" ]]; then
  pass "T3b the refused re-freeze left the stored contract untouched"
else
  fail "T3b the refused re-freeze mutated the stored contract"
fi

# ── T4 read (whole contract, and one field) ────────────────────────────────
if bash "$GC" read --session-file "$d/session.json" 2>/dev/null | jq -e '.goalId == "gc:vscode-abc123:1"' >/dev/null; then
  pass "T4 read returns the stored contract"
else
  fail "T4 read did not return the stored contract"
fi
expect_field "T4b read --field .intent returns just the intent" \
  "$d/session.json" ".intent" "Freeze one immutable Goal Contract per mutable run"

# ── T5 read on a session with no contract -> exit 4 ────────────────────────
d5="$(new_case t5)"
printf '{ "turnSnapshots": [] }\n' > "$d5/session.json"
expect_rc "T5 read with no .goalContract -> exit 4" 4 \
  bash "$GC" read --session-file "$d5/session.json"
expect_rc "T5b verify with no .goalContract -> exit 4" 4 \
  bash "$GC" verify --session-file "$d5/session.json"
expect_rc "T5c revise with no .goalContract -> exit 4" 4 \
  bash "$GC" revise --session-file "$d5/session.json" --approval-note "x"

# ── T6 verify passes for a matching goalId / revision / digest ─────────────
expect_rc "T6 verify with matching goalId+revision+digest -> exit 0" 0 \
  bash "$GC" verify --session-file "$d/session.json" \
    --expect-goal-id "gc:vscode-abc123:1" --expect-revision 1 --expect-digest "$digest_1"

# ── T7 verify FAILS on a substituted digest (adversarial) ──────────────────
expect_rc "T7 verify with a substituted --expect-digest -> exit 1" 1 \
  bash "$GC" verify --session-file "$d/session.json" \
    --expect-digest "sha256:$(printf '0%.0s' $(seq 1 64))"

d7="$(new_case t7)"
freeze_default "$d7" >/dev/null 2>&1
jq '.goalContract.sourceRequestDigest = "sha256:'"$(printf 'a%.0s' $(seq 1 64))"'"' \
  "$d7/session.json" > "$d7/session.tmp" && mv "$d7/session.tmp" "$d7/session.json"
expect_rc "T7b a digest substituted IN THE SESSION FILE fails verify -> exit 1" 1 \
  bash "$GC" verify --session-file "$d7/session.json" --expect-digest "$digest_1"

# ── T8 verify fails on a substituted revision ─────────────────────────────
d8="$(new_case t8)"
freeze_default "$d8" >/dev/null 2>&1
jq '.goalContract.revision = 7' "$d8/session.json" > "$d8/session.tmp" \
  && mv "$d8/session.tmp" "$d8/session.json"
expect_rc "T8 a revision substituted in the session file fails verify -> exit 1" 1 \
  bash "$GC" verify --session-file "$d8/session.json" --expect-revision 1
expect_rc "T8b the same substitution fails verify even with NO expectation flags" 1 \
  bash "$GC" verify --session-file "$d8/session.json"

# ── T9 revise without an approval note is REFUSED ─────────────────────────
d9="$(new_case t9)"
freeze_default "$d9" >/dev/null 2>&1
expect_rc "T9 revise without --approval-note -> exit 3 (refused)" 3 \
  bash "$GC" revise --session-file "$d9/session.json" --intent "a wider intent"
expect_field "T9b the refused revise did not change the intent" \
  "$d9/session.json" ".intent" "Freeze one immutable Goal Contract per mutable run"
expect_field "T9c the refused revise did not change the revision" \
  "$d9/session.json" ".revision" "1"

# ── T10 an approved revise increments, supersedes, and records approval ────
if bash "$GC" revise --session-file "$d9/session.json" \
     --approval-note "operator approved the wider intent" \
     --intent "a wider intent" >"$d9/rev.json" 2>"$d9/rev.err"; then
  if [[ "$(jq -r '.revision' "$d9/rev.json")" == "2" ]] \
     && [[ "$(jq -r '.goalId' "$d9/rev.json")" == "gc:vscode-abc123:2" ]] \
     && [[ "$(jq -r '.supersedes' "$d9/rev.json")" == "gc:vscode-abc123:1" ]] \
     && [[ "$(jq -r '.approval.state' "$d9/rev.json")" == "operator-approved" ]] \
     && [[ "$(jq -r '.approval.approvedAt' "$d9/rev.json")" != "null" ]] \
     && [[ "$(jq -r '.intent' "$d9/rev.json")" == "a wider intent" ]]; then
    pass "T10 revise -> revision 2, supersedes prior goalId, operator-approved"
  else
    fail "T10 revise produced the wrong shape: $(jq -c '{revision,goalId,supersedes,approval}' "$d9/rev.json")"
  fi
else
  fail "T10 revise exited non-zero: $(cat "$d9/rev.err")"
fi
expect_rc "T10b the revised contract passes verify at revision 2" 0 \
  bash "$GC" verify --session-file "$d9/session.json" \
    --expect-goal-id "gc:vscode-abc123:2" --expect-revision 2

# ── T11 widening vs narrowing is classified, never silently reclassified ──
d11="$(new_case t11)"
freeze_default "$d11" >/dev/null 2>&1
bash "$GC" revise --session-file "$d11/session.json" --approval-note "add knb" \
  --repository-root bubbles --repository-root knb >/dev/null 2>&1
expect_field "T11 revise that ADDS a repositoryRoot -> 'widened: ' note prefix" \
  "$d11/session.json" ".approval.approvalNote" "widened: add knb"

d11b="$(new_case t11b)"
freeze_default "$d11b" \
  --spec-target specs/999-extra >/dev/null 2>&1
bash "$GC" revise --session-file "$d11b/session.json" --approval-note "drop the extra spec" \
  --spec-target specs/038-goal-fidelity >/dev/null 2>&1
expect_field "T11b revise that REMOVES a specTarget -> 'narrowed: ' note prefix" \
  "$d11b/session.json" ".approval.approvalNote" "narrowed: drop the extra spec"

d11c="$(new_case t11c)"
freeze_default "$d11c" >/dev/null 2>&1
bash "$GC" revise --session-file "$d11c/session.json" --approval-note "reword only" \
  --intent "same boundary, new wording" >/dev/null 2>&1
expect_field "T11c revise that leaves the boundary alone -> 'unchanged: ' prefix" \
  "$d11c/session.json" ".approval.approvalNote" "unchanged: reword only"

d11d="$(new_case t11d)"
freeze_default "$d11d" >/dev/null 2>&1
bash "$GC" revise --session-file "$d11d/session.json" --approval-note "swap roots" \
  --repository-root knb >/dev/null 2>&1
expect_field "T11d a mixed add+remove is 'widened: ' (an addition outranks a removal)" \
  "$d11d/session.json" ".approval.approvalNote" "widened: swap roots"

d11e="$(new_case t11e)"
freeze_default "$d11e" >/dev/null 2>&1
bash "$GC" revise --session-file "$d11e/session.json" --approval-note "allow cross-repo" \
  --cross-repo-policy authorized >/dev/null 2>&1
expect_field "T11e forbidden -> authorized is a boundary widening" \
  "$d11e/session.json" ".approval.approvalNote" "widened: allow cross-repo"

# ── T12 mirror writes ONLY the three ref fields and preserves .execution ───
d12="$(new_case t12)"
freeze_default "$d12" >/dev/null 2>&1
printf '%s\n' '{ "version": 3, "status": "in_progress", "execution": { "currentScope": "SCOPE-1", "currentPhase": "implement" } }' \
  > "$d12/state.json"
if bash "$GC" mirror --session-file "$d12/session.json" --state-file "$d12/state.json" >/dev/null 2>"$d12/err.txt"; then
  ref_keys="$(jq -r '.execution.goalContractRef | keys | join(",")' "$d12/state.json")"
  if [[ "$ref_keys" == "goalId,revision,sourceRequestDigest" ]]; then
    pass "T12 mirror writes exactly goalId, revision, sourceRequestDigest"
  else
    fail "T12 mirror wrote the wrong key set: '$ref_keys'"
  fi
  if [[ "$(jq -r '.execution.currentScope' "$d12/state.json")" == "SCOPE-1" ]] \
     && [[ "$(jq -r '.execution.currentPhase' "$d12/state.json")" == "implement" ]] \
     && [[ "$(jq -r '.status' "$d12/state.json")" == "in_progress" ]]; then
    pass "T12b mirror preserved pre-existing .execution keys and siblings"
  else
    fail "T12b mirror dropped pre-existing state: $(jq -c . "$d12/state.json")"
  fi
  if [[ "$(jq -r '.execution.goalContractRef | has("intent") or has("successSignal") or has("hardConstraints") or has("workBoundary")' "$d12/state.json")" == "false" ]]; then
    pass "T12c mirror leaked no intent/successSignal/constraints/boundary into state.json (R5)"
  else
    fail "T12c mirror leaked contract content into state.json"
  fi
else
  fail "T12 mirror exited non-zero: $(cat "$d12/err.txt")"
fi
expect_rc "T12d mirror with a missing state file -> exit 2" 2 \
  bash "$GC" mirror --session-file "$d12/session.json" --state-file "$d12/absent.json"
expect_rc "T12e mirror with no contract -> exit 4" 4 \
  bash "$GC" mirror --session-file "$d5/session.json" --state-file "$d12/state.json"

# ── T13 a malformed workBoundary is refused at freeze ──────────────────────
d13="$(new_case t13)"
expect_rc "T13 freeze with no --repository-root (empty repositoryRoots) -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d13/session.json" \
    --source-request-file "$d13/request.txt" \
    --intent i --success-signal s --target "repository=bubbles" \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles
if [[ -f "$d13/session.json" ]] && [[ "$(jq -r 'has("goalContract")' "$d13/session.json")" == "true" ]]; then
  fail "T13b the refused freeze still wrote a contract"
else
  pass "T13b the refused freeze wrote no contract"
fi
expect_rc "T13c freeze with an empty-string --repository-root -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d13/session2.json" \
    --source-request-file "$d13/request.txt" \
    --intent i --success-signal s --target "repository=bubbles" --repository-root "" \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles
expect_rc "T13d freeze with an invalid --cross-repo-policy -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d13/session3.json" \
    --source-request-file "$d13/request.txt" \
    --intent i --success-signal s --target "repository=bubbles" --repository-root bubbles \
    --cross-repo-policy maybe \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles

# ── T14 remaining required-input and enum refusals ────────────────────────
d14="$(new_case t14)"
expect_rc "T14 freeze with no --target -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d14/session.json" \
    --source-request-file "$d14/request.txt" \
    --intent i --success-signal s --repository-root bubbles \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles
expect_rc "T14b freeze with an out-of-enum --target kind -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d14/session.json" \
    --source-request-file "$d14/request.txt" \
    --intent i --success-signal s --target "database=main" --repository-root bubbles \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles
expect_rc "T14c freeze with no --success-signal -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d14/session.json" \
    --source-request-file "$d14/request.txt" \
    --intent i --target "repository=bubbles" --repository-root bubbles \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles
expect_rc "T14d freeze with a missing --source-request-file -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d14/session.json" \
    --source-request-file "$d14/absent.txt" \
    --intent i --success-signal s --target "repository=bubbles" --repository-root bubbles \
    --runner bubbles.goal --session-id vscode-abc123 --repository-alias bubbles
# A ':' in the session id would make gc:<sessionId>:<revision> unparseable.
expect_rc "T14e freeze with a ':' in --session-id -> exit 2" 2 \
  bash "$GC" freeze --session-file "$d14/session.json" \
    --source-request-file "$d14/request.txt" \
    --intent i --success-signal s --target "repository=bubbles" --repository-root bubbles \
    --runner bubbles.goal --session-id "vscode:abc:123" --repository-alias bubbles
expect_rc "T14f unknown subcommand -> exit 2" 2 bash "$GC" explode
expect_rc "T14g no subcommand -> exit 2" 2 bash "$GC"
expect_rc "T14h --help -> exit 0" 0 bash "$GC" --help

# ── T15 there is no bypass flag ───────────────────────────────────────────
for bypass in --force --skip --ignore --no-verify; do
  expect_rc "T15 '$bypass' is not accepted (no bypass exists)" 2 \
    bash "$GC" freeze --session-file "$TMP_ROOT/t15.json" "$bypass"
done
if grep -qE '^\s*--(force|skip|ignore|no-verify|unsafe)\)' "$GC"; then
  fail "T15b goal-contract.sh declares a bypass-shaped flag"
else
  pass "T15b goal-contract.sh declares no bypass-shaped flag"
fi

# ── T16 the shared outcome model ──────────────────────────────────────────
# SCOPE-1 claims a compiled scenario's `rootOutcome` and the Goal Contract now
# derive from ONE `$defs.outcomeCore` instead of two outcome models. That claim
# is only worth anything if a rootOutcome the EXISTING lint accepts also
# validates against `$defs.scenarioRootOutcome` — otherwise "unified" would
# just mean a second model was written next to the first one.
#
# The fixture is copied from scenario-compile-lint-selftest.sh's clean case, so
# it drifts loudly rather than silently if that lint's contract changes.
if python3 -c 'import jsonschema' >/dev/null 2>&1; then
  d16="$(new_case t16-shared-outcome)"
  cat > "$d16/root-outcome.json" <<'EOF'
{
  "intent": "Product is live and operable on the target environment",
  "successSignal": "Service health endpoint green on the target after deploy",
  "hardConstraints": ["local-target build, not cloud"],
  "failureCondition": "Any node blocked or health check red after deploy"
}
EOF
  # validate_as <schema-$defs-name> <doc> -> rc 0 valid, rc 1 invalid
  validate_as() {
    # shellcheck disable=SC2016  # "#/$defs/" is a literal JSON pointer, not a shell var
    python3 -c '
import json, sys, jsonschema
schema = json.load(open(sys.argv[1]))
doc = json.load(open(sys.argv[2]))
sub = dict(schema)
sub["$ref"] = "#/$defs/" + sys.argv[3]
jsonschema.Draft202012Validator(sub).validate(doc)
' "$SCHEMA" "$2" "$1" 2>/dev/null
  }

  if validate_as scenarioRootOutcome "$d16/root-outcome.json"; then
    pass "T16 a lint-accepted scenario rootOutcome validates against the shared schema"
  else
    fail "T16 a lint-accepted scenario rootOutcome was REJECTED by the shared schema"
  fi
  if validate_as outcomeCore "$d16/root-outcome.json"; then
    pass "T16b the same rootOutcome satisfies the shared outcomeCore mixin"
  else
    fail "T16b the shared outcomeCore rejected a valid scenario rootOutcome"
  fi

  # Adversarial: the two scenario-only tightenings must actually bite. Dropping
  # failureCondition is legal for a Goal Contract and illegal for a scenario, so
  # a schema that merely aliased the two models would pass both of these.
  jq 'del(.failureCondition)' "$d16/root-outcome.json" > "$d16/no-fc.json"
  if validate_as scenarioRootOutcome "$d16/no-fc.json"; then
    fail "T16c scenarioRootOutcome accepted a missing failureCondition (lint rejects it)"
  else
    pass "T16c scenarioRootOutcome rejects a missing failureCondition, matching the lint"
  fi
  if validate_as outcomeCore "$d16/no-fc.json"; then
    pass "T16d outcomeCore still allows an absent failureCondition (Goal Contract case)"
  else
    fail "T16d outcomeCore wrongly requires failureCondition, which would break freeze"
  fi

  jq '.hardConstraints = []' "$d16/root-outcome.json" > "$d16/no-hc.json"
  if validate_as scenarioRootOutcome "$d16/no-hc.json"; then
    fail "T16e scenarioRootOutcome accepted empty hardConstraints (lint rejects it)"
  else
    pass "T16e scenarioRootOutcome rejects empty hardConstraints, matching the lint"
  fi
else
  skip "T16 shared outcome model (python3 jsonschema not installed)"
fi

echo
if [[ "$FAILURES" -gt 0 ]]; then
  echo "goal-contract-selftest FAILED with $FAILURES issue(s)."
  exit 1
fi
echo "goal-contract-selftest: all cases passed."
