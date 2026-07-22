#!/usr/bin/env bash
# Literal jq programs intentionally keep JSON Schema keys such as "$defs" unexpanded.
# shellcheck disable=SC2016
set -u
set -o pipefail

# Hermetic behavior contract for IMP-022 S1 (Repository Binding Foundation).
#
# This test intentionally invokes the planned production owner
# (repository-binding.sh) rather than implementing repository selection here.
# Until that owner and its schema land, every affected case reports a named RED
# contract failure instead of terminating with an opaque file-not-found error.

umask 077
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
RESOLVER="$SCRIPT_DIR/repository-binding.sh"
SCHEMA="$SCRIPT_DIR/../schemas/repository-binding.schema.json"
PROMPT_CONTRACT="$SCRIPT_DIR/../../agents/bubbles_shared/repository-binding-preflight.md"
suite="foundation"
for arg in "$@"; do
  case "$arg" in
    --suite=foundation) suite="foundation" ;;
    -h|--help)
      cat <<'EOF'
Usage: repository-binding-selftest.sh --suite=<suite>

Suites:
  foundation                    IMP-022 S1 repository binding foundation
EOF
      exit 0
      ;;
    *)
      printf 'repository-binding-selftest: unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done
if [[ "${BUBBLES_REPOSITORY_BINDING_REQUIRE_CLI-}" == "1" && \
  "${BUBBLES_REPOSITORY_BINDING_CLI_BOUNDARY-}" != "1" ]]; then
  echo "repository-binding-selftest: required CLI boundary was not executed" >&2
  exit 2
fi
if [[ "${BUBBLES_REPOSITORY_BINDING_CLI_BOUNDARY-}" == "1" ]]; then
  echo "repository-binding-selftest: CLI boundary=executed"
fi

for required_command in git jq mktemp; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'repository-binding-selftest: required command not found: %s\n' "$required_command" >&2
    exit 2
  fi
done

TMP_ROOT="$(mktemp -d)" || {
  echo "repository-binding-selftest: could not create hermetic fixture root" >&2
  exit 2
}
trap 'rm -rf "$TMP_ROOT"' EXIT INT TERM

assertions_passed=0
assertions_failed=0
assertions_skipped=0
cases_passed=0
cases_red=0
cases_run=0
case_failure_baseline=0

LAST_OUTPUT=""
LAST_RC=0
LAST_INTERFACE_AVAILABLE=0
DIAGNOSTIC_CHAT_CWD=""
DIAGNOSTIC_HOST_REPOSITORY=""
DIAGNOSTIC_ACTIVE_EDITOR=""
DIAGNOSTIC_TOOL_CWD=""

CASE_DIR=""
WORKSPACE_DIR=""
CONTROL_DIR=""
CONTROL_FILE=""
SESSION_ID=""

SCHEMA_VALIDATOR_AVAILABLE=0
if command -v python3 >/dev/null 2>&1 && \
  python3 -c 'import jsonschema' >/dev/null 2>&1; then
  SCHEMA_VALIDATOR_AVAILABLE=1
fi

fatal_fixture() {
  local case_id="$1"
  local message="$2"
  printf 'FATAL FIXTURE case=%s contract=hermetic-real-git-repositories detail=%s\n' \
    "$case_id" "$message" >&2
  exit 2
}

physical_path() {
  (cd -P -- "$1" 2>/dev/null && pwd -P)
}

create_eligible_repo() {
  local case_id="$1"
  local root="$2"

  mkdir -p "$root/bubbles/scripts" "$root/agents" || \
    fatal_fixture "$case_id" "cannot create repository marker directories"
  printf 'fixture-version\n' >"$root/VERSION"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$root/install.sh"
  printf '#!/usr/bin/env bash\nexit 0\n' >"$root/bubbles/scripts/cli.sh"
  printf '%s\n' '---' 'name: fixture-workflow' '---' >"$root/agents/bubbles.workflow.agent.md"
  chmod +x "$root/install.sh" "$root/bubbles/scripts/cli.sh" || \
    fatal_fixture "$case_id" "cannot mark fixture scripts executable"

  git init -q "$root" || fatal_fixture "$case_id" "git init failed"
  git -C "$root" config user.name "Bubbles Fixture" || \
    fatal_fixture "$case_id" "git fixture user.name failed"
  git -C "$root" config user.email "fixture@example.invalid" || \
    fatal_fixture "$case_id" "git fixture user.email failed"
  git -C "$root" add VERSION install.sh bubbles/scripts/cli.sh agents/bubbles.workflow.agent.md || \
    fatal_fixture "$case_id" "git add fixture markers failed"
  git -C "$root" commit -q -m "fixture repository" || \
    fatal_fixture "$case_id" "git commit fixture markers failed"
  physical_path "$root" || fatal_fixture "$case_id" "cannot physicalize fixture repository"
}

add_sentinel_spec() {
  local case_id="$1"
  local root="$2"
  local sentinel="$3"
  local spec_dir="$root/specs/$sentinel"

  mkdir -p "$spec_dir" || fatal_fixture "$case_id" "cannot create sentinel spec directory"
  printf '# %s\n\nHermetic repository-binding discovery sentinel.\n' "$sentinel" >"$spec_dir/spec.md" || \
    fatal_fixture "$case_id" "cannot write sentinel spec"
  git -C "$root" add "specs/$sentinel/spec.md" || \
    fatal_fixture "$case_id" "cannot stage sentinel spec"
  git -C "$root" commit -q -m "add $sentinel" || \
    fatal_fixture "$case_id" "cannot commit sentinel spec"
  printf '%s\n' "$spec_dir"
}

create_ineligible_repo() {
  local case_id="$1"
  local root="$2"

  mkdir -p "$root" || fatal_fixture "$case_id" "cannot create ineligible repository"
  printf 'not a Bubbles repository\n' >"$root/README.md"
  git init -q "$root" || fatal_fixture "$case_id" "git init failed for ineligible repository"
  git -C "$root" config user.name "Bubbles Fixture" || \
    fatal_fixture "$case_id" "git fixture user.name failed"
  git -C "$root" config user.email "fixture@example.invalid" || \
    fatal_fixture "$case_id" "git fixture user.email failed"
  git -C "$root" add README.md || fatal_fixture "$case_id" "git add ineligible fixture failed"
  git -C "$root" commit -q -m "ineligible fixture repository" || \
    fatal_fixture "$case_id" "git commit ineligible fixture failed"
  physical_path "$root" || fatal_fixture "$case_id" "cannot physicalize ineligible repository"
}

begin_case() {
  local case_id="$1"
  local description="$2"

  cases_run=$((cases_run + 1))
  case_failure_baseline="$assertions_failed"
  CASE_DIR="$TMP_ROOT/$case_id"
  WORKSPACE_DIR="$CASE_DIR/workspace"
  CONTROL_DIR="$CASE_DIR/control-plane"
  CONTROL_FILE="$CONTROL_DIR/repository-binding.json"
  SESSION_ID="session-$case_id"
  mkdir -p "$WORKSPACE_DIR" "$CONTROL_DIR" || \
    fatal_fixture "$case_id" "cannot create workspace/control-plane directories"
  chmod 700 "$CONTROL_DIR" || fatal_fixture "$case_id" "cannot make control-plane directory private"

  printf '\nCASE START %s\n' "$case_id"
  printf 'CONTRACT %s\n' "$description"
  printf 'FIXTURE workspace=%s control=%s externalControl=true\n' \
    "$WORKSPACE_DIR" "$CONTROL_FILE"
}

end_case() {
  local case_id="$1"
  if [[ "$assertions_failed" -eq "$case_failure_baseline" ]]; then
    cases_passed=$((cases_passed + 1))
    printf 'CASE PASS %s\n' "$case_id"
  else
    cases_red=$((cases_red + 1))
    printf 'CASE RED %s newFailures=%s\n' \
      "$case_id" "$((assertions_failed - case_failure_baseline))"
  fi
}

pass_assertion() {
  local case_id="$1"
  local description="$2"
  assertions_passed=$((assertions_passed + 1))
  printf '  PASS [%s] %s\n' "$case_id" "$description"
}

fail_assertion() {
  local case_id="$1"
  local description="$2"
  local detail="$3"
  assertions_failed=$((assertions_failed + 1))
  printf '  FAIL [%s] behavioralContract=%s detail=%s\n' \
    "$case_id" "$description" "$detail"
}

assert_rc_zero() {
  local case_id="$1"
  local description="$2"
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true"
  elif [[ "$LAST_RC" -eq 0 ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "expectedExit=0 actualExit=$LAST_RC"
  fi
}

assert_rc_nonzero() {
  local case_id="$1"
  local description="$2"
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true"
  elif [[ "$LAST_RC" -ne 0 ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "expectedNonzero actualExit=0"
  fi
}

assert_contains() {
  local case_id="$1"
  local description="$2"
  local expected="$3"
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true expectedOutput=$expected"
    return
  fi
  case "$LAST_OUTPUT" in
    *"$expected"*) pass_assertion "$case_id" "$description" ;;
    *) fail_assertion "$case_id" "$description" "missingOutput=$expected" ;;
  esac
}

assert_excludes() {
  local case_id="$1"
  local description="$2"
  local forbidden="$3"
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true forbiddenOutput=$forbidden"
    return
  fi
  case "$LAST_OUTPUT" in
    *"$forbidden"*) fail_assertion "$case_id" "$description" "forbiddenOutput=$forbidden" ;;
    *) pass_assertion "$case_id" "$description" ;;
  esac
}

control_value() {
  local query="$1"
  if [[ ! -f "$CONTROL_FILE" ]]; then
    return 1
  fi
  jq -r "$query" "$CONTROL_FILE" 2>/dev/null
}

assert_control() {
  local case_id="$1"
  local expected_root="$2"
  local expected_revision="$3"
  local actual_root=""
  local actual_revision=""

  if [[ ! -f "$CONTROL_FILE" ]]; then
    fail_assertion "$case_id" "durable control record exists" "missingControl=$CONTROL_FILE"
    return
  fi
  actual_root="$(control_value '.currentBinding.repositoryRoot')"
  actual_revision="$(control_value '.revision')"
  if [[ "$actual_root" == "$expected_root" && "$actual_revision" == "$expected_revision" ]]; then
    pass_assertion "$case_id" "durable root/revision are $expected_root@$expected_revision"
  else
    fail_assertion "$case_id" "durable root/revision match expected state" \
      "expected=$expected_root@$expected_revision actual=$actual_root@$actual_revision"
  fi
}

assert_no_control() {
  local case_id="$1"
  if [[ ! -e "$CONTROL_FILE" ]]; then
    pass_assertion "$case_id" "refusal leaves external control record absent"
  else
    fail_assertion "$case_id" "refusal leaves external control record absent" \
      "unexpectedControl=$CONTROL_FILE"
  fi
}

control_fingerprint() {
  if [[ -f "$CONTROL_FILE" ]]; then
    cksum "$CONTROL_FILE"
  else
    printf '%s\n' "missing"
  fi
}

assert_control_fingerprint_unchanged() {
  local case_id="$1"
  local description="$2"
  local expected="$3"
  local actual

  actual="$(control_fingerprint)"
  if [[ "$actual" == "$expected" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "controlRecordChanged=true"
  fi
}

assert_external_control_path() {
  local case_id="$1"
  local repository_root="$2"
  case "$CONTROL_FILE" in
    "$repository_root"|"$repository_root"/*)
      fail_assertion "$case_id" "session control file is external to every fixture repository" \
        "controlInsideRepository=$repository_root"
      ;;
    *) pass_assertion "$case_id" "session control file is external to $repository_root" ;;
  esac
}

invoke_binding() {
  local case_id="$1"
  local behavior="$2"
  local invocation_cwd="$3"
  shift 3

  printf 'COMMAND [%s] cwd=%s bash %s' "$case_id" "$invocation_cwd" "$RESOLVER"
  printf ' %s' "$@"
  printf '\n'

  if [[ ! -f "$RESOLVER" ]]; then
    LAST_INTERFACE_AVAILABLE=0
    LAST_RC=127
    LAST_OUTPUT="REPOSITORY-BINDING RED case=$case_id behavioralContract=$behavior missingProductionInterface=bubbles/scripts/repository-binding.sh"
  else
    LAST_INTERFACE_AVAILABLE=1
    LAST_OUTPUT="$({
      cd -P -- "$invocation_cwd" || exit 125
      BUBBLES_DIAGNOSTIC_CHAT_CWD="$DIAGNOSTIC_CHAT_CWD" \
      BUBBLES_DIAGNOSTIC_HOST_REPOSITORY="$DIAGNOSTIC_HOST_REPOSITORY" \
      BUBBLES_DIAGNOSTIC_ACTIVE_EDITOR="$DIAGNOSTIC_ACTIVE_EDITOR" \
      BUBBLES_DIAGNOSTIC_TOOL_CWD="$DIAGNOSTIC_TOOL_CWD" \
        bash "$RESOLVER" "$@"
    } 2>&1)"
    LAST_RC=$?
  fi

  if [[ -n "$LAST_OUTPUT" ]]; then
    printf '%s\n' "$LAST_OUTPUT"
  else
    printf '<no production output>\n'
  fi
  printf 'EXIT [%s] %s\n' "$case_id" "$LAST_RC"
}

reset_diagnostics() {
  DIAGNOSTIC_CHAT_CWD=""
  DIAGNOSTIC_HOST_REPOSITORY=""
  DIAGNOSTIC_ACTIVE_EDITOR=""
  DIAGNOSTIC_TOOL_CWD=""
}

write_actionable_packet() {
  local packet_file="$1"
  local session_id="$2"
  local revision="$3"
  local repository_root="$4"
  local repository_alias="$5"
  local decision_id="rb:$session_id:$revision"

  jq -n \
    --arg root "$repository_root" \
    --arg alias "$repository_alias" \
    --arg session "$session_id" \
    --arg decision "$decision_id" \
    --argjson revision "$revision" \
    '{
      repositoryRoot: $root,
      repositoryAlias: $alias,
      repositoryResolution: {
        sessionId: $session,
        decisionId: $decision,
        controlRevision: $revision,
        authority: "durable-work-boundary",
        transition: "continued",
        scopeKind: "command",
        scopeId: null,
        targetKind: "inherited-boundary",
        pathVisibility: "local",
        actionable: true
      }
    }' >"$packet_file" || return 1
}

write_valid_control() {
  local control_file="$1"
  local session_id="$2"
  local repository_root="$3"
  local repository_alias="$4"
  local decision_id="rb:$session_id:1"

  jq -n \
    --arg session "$session_id" \
    --arg root "$repository_root" \
    --arg alias "$repository_alias" \
    --arg decision "$decision_id" \
    '{
      schemaVersion: 1,
      sessionId: $session,
      revision: 1,
      currentBinding: {
        repositoryRoot: $root,
        repositoryAlias: $alias,
        establishedDecisionId: $decision,
        establishedAuthority: "explicit-repository-root",
        establishedAt: "2026-01-01T00:00:00Z",
        lastDecisionId: $decision
      },
      transitionHistory: [{
        revision: 1,
        decisionId: $decision,
        fromRepositoryRoot: null,
        toRepositoryRoot: $root,
        fromRepositoryAlias: null,
        toRepositoryAlias: $alias,
        authority: "explicit-repository-root",
        transition: "established",
        targetKind: "repository-root",
        timestamp: "2026-01-01T00:00:00Z"
      }]
    }' >"$control_file" || return 1
}

establish_explicit_binding() {
  local case_id="$1"
  local invocation_cwd="$2"
  local repository_root="$3"
  shift 3

  invoke_binding "$case_id" "explicit repository establishes durable boundary before dispatch" \
    "$invocation_cwd" preflight \
    --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" \
    --request-class TARGETLESS_MODE \
    --repository-root "$repository_root" \
    "$@"
  assert_rc_zero "$case_id" "explicit repository preflight establishes the setup boundary"
}

assert_schema_contract() {
  local case_id="$1"
  local description="$2"
  local query="$3"
  local schema_file="${4:-$SCHEMA}"

  if [[ ! -f "$schema_file" ]]; then
    fail_assertion "$case_id" "$description" "missingSchema=$schema_file"
  elif jq -e "$query" "$schema_file" >/dev/null 2>&1; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "schemaQueryFailed=$query"
  fi
}

assert_schema_instance() {
  local case_id="$1"
  local description="$2"
  local instance_file="$3"
  local expected="$4"

  if [[ "$SCHEMA_VALIDATOR_AVAILABLE" -ne 1 ]]; then
    assertions_skipped=$((assertions_skipped + 1))
    printf '  SKIP [%s] %s (python jsonschema not installed)\n' "$case_id" "$description"
    return 0
  fi
  if python3 -c '
import json
import sys
import jsonschema

with open(sys.argv[1], encoding="utf-8") as schema_file:
    schema = json.load(schema_file)
with open(sys.argv[2], encoding="utf-8") as instance_file:
    instance = json.load(instance_file)
jsonschema.Draft202012Validator.check_schema(schema)
validator = jsonschema.Draft202012Validator(
    schema,
    format_checker=jsonschema.Draft202012Validator.FORMAT_CHECKER,
)
is_valid = not any(validator.iter_errors(instance))
expected_valid = sys.argv[3] == "valid"
raise SystemExit(0 if is_valid == expected_valid else 1)
' "$SCHEMA" "$instance_file" "$expected"; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" \
      "schemaExpectation=$expected instance=$instance_file"
  fi
}

assert_file_contains_text() {
  local case_id="$1"
  local description="$2"
  local file="$3"
  local expected="$4"

  if [[ ! -f "$file" ]]; then
    fail_assertion "$case_id" "$description" "missingFile=$file"
  elif grep -Fq -- "$expected" "$file"; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "missingText=$expected"
  fi
}

assert_file_exists() {
  local case_id="$1"
  local description="$2"
  local file="$3"
  if [[ -f "$file" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "missingFile=$file"
  fi
}

case "$suite" in
esac
echo "=== IMP-022 S1 repository-binding foundation selftest ==="
echo "SUITE foundation"
echo "PRODUCTION resolver=$RESOLVER schema=$SCHEMA"
if [[ ! -f "$RESOLVER" || ! -f "$SCHEMA" ]]; then
  echo "RED PRECONDITION: S1 production resolver/schema are not yet present; named behavioral cases must remain nonzero."
fi

# RB-CLI-BOUNDARY-EXECUTED ---------------------------------------------------
case_id="RB-CLI-BOUNDARY-EXECUTED"
begin_case "$case_id" "The foundation suite executes through bubbles/scripts/cli.sh before reaching the real resolver tests."
if [[ "${BUBBLES_REPOSITORY_BINDING_CLI_BOUNDARY-}" == "1" ]]; then
  pass_assertion "$case_id" "real CLI boundary marks the delegated foundation selftest"
else
  fail_assertion "$case_id" "real CLI boundary marks the delegated foundation selftest" \
    "cliBoundaryMarker=absent"
fi
end_case "$case_id"

# RB-SHARED-PREFLIGHT-CONTRACT ------------------------------------------------
case_id="RB-SHARED-PREFLIGHT-CONTRACT"
begin_case "$case_id" "One shared prompt contract owns repository authority, ordering, projection, and ownership preservation."
assert_file_exists "$case_id" "shared repository-binding preflight contract exists" "$PROMPT_CONTRACT"
assert_file_contains_text "$case_id" "shared contract makes preflight ordering mandatory" \
  "$PROMPT_CONTRACT" "Mandatory Ordering"
assert_file_contains_text "$case_id" "shared contract closes repository authority order" \
  "$PROMPT_CONTRACT" "Closed Authority Order"
assert_file_contains_text "$case_id" "shared contract forbids ambient fallback" \
  "$PROMPT_CONTRACT" "There is no ambient fallback and no bypass."
assert_file_contains_text "$case_id" "shared contract preserves existing ownership boundaries" \
  "$PROMPT_CONTRACT" "widen any framework, product, deployment, release"
end_case "$case_id"

# RB-CANONICAL-IDENTITY -------------------------------------------------------
case_id="RB-CANONICAL-IDENTITY"
begin_case "$case_id" "Symlink spellings deduplicate to one physical Git root; linked worktrees remain distinct identities."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
alias_one="$WORKSPACE_DIR/prior-work-repo-alias-one"
alias_two="$WORKSPACE_DIR/prior-work-repo-alias-two"
ln -s "$repo_a" "$alias_one" || fatal_fixture "$case_id" "cannot create first symlink alias"
ln -s "$repo_a" "$alias_two" || fatal_fixture "$case_id" "cannot create second symlink alias"
assert_external_control_path "$case_id" "$repo_a"
invoke_binding "$case_id" "canonical symlink aliases form one sole eligible repository" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE \
  --workspace-root "$repo_a" --workspace-root "$alias_one" --workspace-root "$alias_two"
assert_rc_zero "$case_id" "symlink aliases do not create false multi-root ambiguity"
assert_contains "$case_id" "symlink aliases use sole-repository compatibility" "source=sole-eligible-repo"
assert_control "$case_id" "$repo_a" "1"

worktree_root="$WORKSPACE_DIR/prior-work-repo-linked-worktree"
git -C "$repo_a" worktree add -q -b fixture-linked-worktree "$worktree_root" || \
  fatal_fixture "$case_id" "cannot create linked Git worktree"
worktree_root="$(physical_path "$worktree_root")"
CONTROL_FILE="$CONTROL_DIR/distinct-worktree.json"
SESSION_ID="session-$case_id-distinct-worktree"
invoke_binding "$case_id" "distinct Git worktrees sharing a common directory remain separate eligible roots" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE \
  --workspace-root "$repo_a" --workspace-root "$worktree_root"
assert_rc_nonzero "$case_id" "unbound targetless request sees two distinct worktree identities"
assert_contains "$case_id" "distinct worktrees refuse as multi-root" "TARGETLESS_MULTI_ROOT_UNBOUND"
assert_no_control "$case_id"
end_case "$case_id"

# RB-TARGET-PHYSICAL-CONTAINMENT ---------------------------------------------
case_id="RB-TARGET-PHYSICAL-CONTAINMENT"
begin_case "$case_id" "Relative exact-target probes reject parent traversal and physical symlink escape while accepting contained targets."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
outside_target="$WORKSPACE_DIR/outside-target"
mkdir -p "$outside_target" "$repo_a/specs/contained-target" || \
  fatal_fixture "$case_id" "cannot create exact-target containment fixtures"
ln -s "$outside_target" "$repo_a/specs/escaping-target" || \
  fatal_fixture "$case_id" "cannot create escaping target symlink"

CONTROL_FILE="$CONTROL_DIR/traversal.json"
SESSION_ID="session-$case_id-traversal"
invoke_binding "$case_id" "relative parent traversal is rejected by the production resolver" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class VAGUE --target "../outside-target" --workspace-root "$repo_a"
assert_rc_nonzero "$case_id" "parent traversal cannot establish repository affinity"
assert_contains "$case_id" "parent traversal uses the closed target-resolution refusal" \
  "EXPLICIT_REPOSITORY_ROOT_NOT_FOUND"
assert_no_control "$case_id"

CONTROL_FILE="$CONTROL_DIR/symlink-escape.json"
SESSION_ID="session-$case_id-symlink"
invoke_binding "$case_id" "relative symlink escape is rejected by the production resolver" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class VAGUE --target "specs/escaping-target" --workspace-root "$repo_a"
assert_rc_nonzero "$case_id" "symlink escape cannot establish repository affinity"
assert_contains "$case_id" "symlink escape uses the closed target-resolution refusal" \
  "EXPLICIT_REPOSITORY_ROOT_NOT_FOUND"
assert_no_control "$case_id"

CONTROL_FILE="$CONTROL_DIR/contained.json"
SESSION_ID="session-$case_id-contained"
invoke_binding "$case_id" "contained relative target resolves through the production resolver" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class VAGUE --target "specs/contained-target" --workspace-root "$repo_a"
assert_rc_zero "$case_id" "contained relative target establishes repository affinity"
assert_contains "$case_id" "contained target records concrete-target authority" \
  "source=concrete-target"
assert_control "$case_id" "$repo_a" "1"
end_case "$case_id"

# RB-AUTH-INCIDENTAL-ACCESS-EXCLUDED -----------------------------------------
case_id="RB-AUTH-INCIDENTAL-ACCESS-EXCLUDED"
begin_case "$case_id" "Absolute reads, process CWD, host metadata, editor state, and tool CWD are diagnostic-only and cannot establish authority."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
git -C "$repo_a" status --short >/dev/null || fatal_fixture "$case_id" "incidental read probe failed"
DIAGNOSTIC_CHAT_CWD="$repo_b"
DIAGNOSTIC_HOST_REPOSITORY="$repo_c"
DIAGNOSTIC_ACTIVE_EDITOR="$repo_b"
DIAGNOSTIC_TOOL_CWD="$repo_a"
invoke_binding "$case_id" "ambient and incidental access cannot establish a work boundary" \
  "$repo_a" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
assert_rc_nonzero "$case_id" "ambient disagreement leaves the targetless multi-root request unbound"
assert_contains "$case_id" "ambient disagreement returns the stable refusal" "TARGETLESS_MULTI_ROOT_UNBOUND"
assert_contains "$case_id" "refusal reports zero repository-local side effects" "repoLocalSideEffects=zero"
assert_no_control "$case_id"
reset_diagnostics
end_case "$case_id"

# RB-AUTH-BOUNDARY-OUTRANKS-AMBIENT ------------------------------------------
case_id="RB-AUTH-BOUNDARY-OUTRANKS-AMBIENT"
begin_case "$case_id" "One valid durable boundary outranks every ambient disagreement and continues without switching."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
DIAGNOSTIC_CHAT_CWD="$repo_b"
DIAGNOSTIC_HOST_REPOSITORY="$repo_c"
DIAGNOSTIC_ACTIVE_EDITOR="$repo_b"
DIAGNOSTIC_TOOL_CWD="$repo_c"
invoke_binding "$case_id" "durable boundary remains authoritative under four ambient disagreements" \
  "$repo_b" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
assert_rc_zero "$case_id" "targetless follow-up continues the valid durable boundary"
assert_contains "$case_id" "durable boundary is the visible source" "source=session-work-boundary"
assert_contains "$case_id" "boundary continuation is explicit" "affinity=continued"
assert_control "$case_id" "$repo_a" "2"
reset_diagnostics
end_case "$case_id"

# RB-AUTH-NO-FIRST-ROOT-FALLBACK ---------------------------------------------
case_id="RB-AUTH-NO-FIRST-ROOT-FALLBACK"
begin_case "$case_id" "An unbound targetless multi-root request refuses instead of selecting the first declared root."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
invoke_binding "$case_id" "workspace declaration order never selects a repository" \
  "$repo_a" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
assert_rc_nonzero "$case_id" "unbound multi-root targetless request refuses"
assert_contains "$case_id" "refusal names TARGETLESS_MULTI_ROOT_UNBOUND" "TARGETLESS_MULTI_ROOT_UNBOUND"
assert_contains "$case_id" "refusal requests repositoryRoot" "repositoryRoot"
assert_contains "$case_id" "refusal preserves affinity" "affinity=unchanged"
assert_contains "$case_id" "refusal emits the stable outcome field" "outcome: refused"
assert_contains "$case_id" "refusal emits the stable reasonCode field" \
  "reasonCode: TARGETLESS_MULTI_ROOT_UNBOUND"
assert_contains "$case_id" "refusal explains the accepted repositoryRoot requirement" \
  "requiredInput.requirement: one eligible canonical repository root"
assert_contains "$case_id" "refusal emits the stable affinity field" "affinity: unchanged"
assert_contains "$case_id" "refusal emits the stable side-effect field" "repoLocalSideEffects: zero"
assert_no_control "$case_id"
end_case "$case_id"

# RB-AUTH-SOLE-ELIGIBLE-COMPATIBILITY ----------------------------------------
case_id="RB-AUTH-SOLE-ELIGIBLE-COMPATIBILITY"
begin_case "$case_id" "Exactly one eligible canonical repository preserves targetless single-root compatibility."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
invoke_binding "$case_id" "sole eligible repository establishes the first durable boundary" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a"
assert_rc_zero "$case_id" "sole eligible repository preflight succeeds"
assert_contains "$case_id" "operator source is sole-eligible-repo" "source=sole-eligible-repo"
assert_contains "$case_id" "single-repository compatibility is visible" "compatibility=single-repository"
assert_control "$case_id" "$repo_a" "1"
end_case "$case_id"

# RB-TRANSITION-VALID-SWITCH-PERSISTS ----------------------------------------
case_id="RB-TRANSITION-VALID-SWITCH-PERSISTS"
begin_case "$case_id" "A valid explicit switch commits before dispatch and survives a simulated downstream failure."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
invoke_binding "$case_id" "explicit repository switch commits the new root before dispatch" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --repository-root "$repo_b" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_zero "$case_id" "valid explicit switch preflight succeeds"
assert_contains "$case_id" "switch is visible before downstream work" "REPOSITORY PREFLIGHT SWITCHED"
assert_contains "$case_id" "switch transition is durable" "affinity=switched"
assert_control "$case_id" "$repo_b" "2"
downstream_rc=0
(exit 73)
downstream_rc=$?
if [[ "$downstream_rc" -eq 73 ]]; then
  pass_assertion "$case_id" "simulated downstream phase fails after the committed switch"
else
  fail_assertion "$case_id" "simulated downstream phase fails after the committed switch" \
    "expectedExit=73 actualExit=$downstream_rc"
fi
assert_control "$case_id" "$repo_b" "2"
end_case "$case_id"

# RB-TRANSITION-FAILED-SWITCH-PRESERVES --------------------------------------
case_id="RB-TRANSITION-FAILED-SWITCH-PRESERVES"
begin_case "$case_id" "Missing, ineligible, and ambiguous switch attempts preserve the prior root and revision."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
repo_ineligible="$(create_ineligible_repo "$case_id" "$WORKSPACE_DIR/ineligible-role-repo")"
mkdir -p "$repo_b/specs/ambiguous-switch" "$repo_c/specs/ambiguous-switch" || \
  fatal_fixture "$case_id" "cannot create ambiguous exact-target fixtures"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
baseline="$(control_fingerprint)"

invoke_binding "$case_id" "missing explicit switch target refuses without mutation" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --repository-root "$WORKSPACE_DIR/missing-role-repo" \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
assert_rc_nonzero "$case_id" "missing switch target refuses"
assert_contains "$case_id" "missing switch uses stable reason" "EXPLICIT_REPOSITORY_ROOT_NOT_FOUND"
assert_contains "$case_id" "missing switch reports the prior valid boundary" \
  "trustedBoundaryState.status: valid"
assert_contains "$case_id" "missing switch reports the unchanged prior root" \
  "trustedBoundaryState.repository: $repo_a"
assert_control_fingerprint_unchanged "$case_id" \
  "missing switch leaves the control bytes unchanged" "$baseline"

invoke_binding "$case_id" "ineligible explicit switch target refuses without mutation" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --repository-root "$repo_ineligible" \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c" \
  --workspace-root "$repo_ineligible"
assert_rc_nonzero "$case_id" "ineligible switch target refuses"
assert_contains "$case_id" "ineligible switch uses stable reason" "EXPLICIT_REPOSITORY_ROOT_INELIGIBLE"
assert_contains "$case_id" "ineligible switch reports the prior valid boundary" \
  "trustedBoundaryState.status: valid"
assert_control_fingerprint_unchanged "$case_id" \
  "ineligible switch leaves the control bytes unchanged" "$baseline"

invoke_binding "$case_id" "ambiguous relative target refuses without mutation" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class VAGUE --target "specs/ambiguous-switch" \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
assert_rc_nonzero "$case_id" "ambiguous switch target refuses"
assert_contains "$case_id" "ambiguous target uses stable reason" "TARGET_ALIAS_AMBIGUOUS"
assert_contains "$case_id" "ambiguous switch reports the prior valid boundary" \
  "trustedBoundaryState.status: valid"
assert_control_fingerprint_unchanged "$case_id" \
  "ambiguous switch leaves the control bytes unchanged" "$baseline"
assert_control "$case_id" "$repo_a" "1"
end_case "$case_id"

# RB-AUTH-CONFLICT-REFUSES ----------------------------------------------------
case_id="RB-AUTH-CONFLICT-REFUSES"
begin_case "$case_id" "A same-session actionable packet that conflicts with control authority refuses without a recency winner."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
packet_file="$CASE_DIR/conflicting-packet.json"
write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_b" "chat-cwd-repo" || \
  fatal_fixture "$case_id" "cannot author conflicting packet"
baseline="$(control_fingerprint)"
invoke_binding "$case_id" "conflicting packet/control authority refuses before repository-local work" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --binding-packet-file "$packet_file" --request-class CONTINUATION \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "conflicting same-session authority refuses"
assert_contains "$case_id" "conflict returns BOUNDARY_CONFLICT" "BOUNDARY_CONFLICT"
assert_contains "$case_id" "conflict has zero repository-local side effects" "repoLocalSideEffects=zero"
assert_control_fingerprint_unchanged "$case_id" \
  "conflict leaves prior control bytes unchanged" "$baseline"
assert_control "$case_id" "$repo_a" "1"
end_case "$case_id"

# RB-AUTH-STALE-BOUNDARY-REFUSES ---------------------------------------------
case_id="RB-AUTH-STALE-BOUNDARY-REFUSES"
begin_case "$case_id" "A bound repository that loses foundation eligibility refuses without sole-root fallback."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
baseline="$(control_fingerprint)"
rm -f "$repo_a/VERSION"
invoke_binding "$case_id" "stale durable boundary refuses instead of falling through to another eligible root" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "stale durable boundary refuses"
assert_contains "$case_id" "stale boundary returns BOUNDARY_STALE" "BOUNDARY_STALE"
assert_control_fingerprint_unchanged "$case_id" \
  "stale refusal leaves prior control bytes unchanged" "$baseline"
end_case "$case_id"

# RB-AUTH-BOUND-ROOT-MUST-REMAIN-DECLARED ------------------------------------
case_id="RB-AUTH-BOUND-ROOT-MUST-REMAIN-DECLARED"
begin_case "$case_id" "A durable root omitted from the current declared eligible set is stale and cannot remain authoritative."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
baseline="$(control_fingerprint)"
invoke_binding "$case_id" "an omitted durable root refuses instead of escaping the declared workspace inventory" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "omitted durable root refuses"
assert_contains "$case_id" "omitted durable root is reported stale" "BOUNDARY_STALE"
assert_control_fingerprint_unchanged "$case_id" \
  "omitted-root refusal leaves prior control bytes unchanged" "$baseline"
end_case "$case_id"

# RB-AUTH-EXPLICIT-REPAIR-PRECEDENCE -----------------------------------------
case_id="RB-AUTH-EXPLICIT-REPAIR-PRECEDENCE"
begin_case "$case_id" "A valid explicit root outranks a conflicting invocation packet and commits an intentional repair."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
packet_file="$CASE_DIR/conflicting-packet.json"
write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_b" "chat-cwd-repo" || \
  fatal_fixture "$case_id" "cannot author explicit-repair packet"
invoke_binding "$case_id" "explicit repository intent repairs conflicting carried authority" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --binding-packet-file "$packet_file" --request-class CONTINUATION \
  --repository-root "$repo_b" --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_zero "$case_id" "valid explicit repair succeeds"
assert_contains "$case_id" "explicit repair reports a switch" "REPOSITORY PREFLIGHT SWITCHED"
assert_control "$case_id" "$repo_b" "2"
end_case "$case_id"

# RB-CONTROL-PATH-EXTERNAL-CANONICAL -----------------------------------------
case_id="RB-CONTROL-PATH-EXTERNAL-CANONICAL"
begin_case "$case_id" "The host-private control path remains external after canonicalizing every explicit candidate root."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/declared-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/explicit-repo")"
mkdir -p "$repo_b/private-control" || fatal_fixture "$case_id" "cannot create in-repository control directory"
CONTROL_FILE="$repo_b/private-control/repository-binding.json"
invoke_binding "$case_id" "an explicit root cannot hide its control record inside itself by omission from workspace roots" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --repository-root "$repo_b" --workspace-root "$repo_a"
assert_rc_nonzero "$case_id" "in-repository control path is rejected"
assert_contains "$case_id" "external-control refusal explains the required boundary" \
  "external to workspace repositories"
assert_no_control "$case_id"

CONTROL_FILE="$CONTROL_DIR/nonprivate-control.json"
printf '%s\n' '{"untrusted":"must-not-read"}' >"$CONTROL_FILE"
chmod 644 "$CONTROL_FILE" || fatal_fixture "$case_id" "cannot create non-private control fixture"
baseline="$(control_fingerprint)"
invoke_binding "$case_id" "an existing non-private authority record refuses without chmod repair" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --repository-root "$repo_b" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "existing non-private control file is rejected"
assert_contains "$case_id" "non-private control refusal names the owner-private requirement" \
  "owner-private regular file"
assert_control_fingerprint_unchanged "$case_id" \
  "non-private control bytes remain untouched" "$baseline"
nonprivate_permissions="$(ls -l "$CONTROL_FILE")"
nonprivate_permissions="${nonprivate_permissions%% *}"
case "$nonprivate_permissions" in
  -rw-r--r--*) pass_assertion "$case_id" "non-private control mode remains untouched" ;;
  *) fail_assertion "$case_id" "non-private control mode remains untouched" \
       "actualPermissions=$nonprivate_permissions" ;;
esac
end_case "$case_id"

# RB-SESSION-ISOLATION-NO-MIRROR-INHERITANCE ---------------------------------
case_id="RB-SESSION-ISOLATION-NO-MIRROR-INHERITANCE"
begin_case "$case_id" "A distinct session cannot consume another session's external control authority."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
session_a="$SESSION_ID-a"
session_b="$SESSION_ID-b"
SESSION_ID="$session_a"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b"
baseline="$(control_fingerprint)"
invoke_binding "$case_id" "new session rejects old-session authority and remains unbound" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$session_b" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "distinct session does not inherit session A"
assert_excludes "$case_id" "distinct session output does not continue session A" "source=session-work-boundary"
assert_control_fingerprint_unchanged "$case_id" \
  "session B attempt does not mutate session A control" "$baseline"
end_case "$case_id"

# RB-SCHEMA-CONTROL-POSITIVE --------------------------------------------------
case_id="RB-SCHEMA-CONTROL-POSITIVE"
begin_case "$case_id" "An independently authored schemaVersion=1 control record is accepted and continued."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
if [[ -f "$SCHEMA" ]]; then
  pass_assertion "$case_id" "production repository-binding schema exists"
else
  fail_assertion "$case_id" "production repository-binding schema exists" "missingSchema=$SCHEMA"
fi
write_valid_control "$CONTROL_FILE" "$SESSION_ID" "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author valid control record"
invoke_binding "$case_id" "valid control schema drives a durable-boundary continuation" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_zero "$case_id" "valid independent control record is accepted"
assert_contains "$case_id" "valid control record continues session boundary" "source=session-work-boundary"
assert_control "$case_id" "$repo_a" "2"
end_case "$case_id"

# RB-SCHEMA-CONTROL-NEGATIVE --------------------------------------------------
case_id="RB-SCHEMA-CONTROL-NEGATIVE"
begin_case "$case_id" "Malformed control state fails closed and is never rewritten during refusal."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
printf '%s\n' '{"schemaVersion":1,"sessionId":"malformed","revision":0,"transitionHistory":[]}' >"$CONTROL_FILE"
baseline="$(control_fingerprint)"
invoke_binding "$case_id" "invalid control schema returns BOUNDARY_MALFORMED" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "malformed control record refuses"
assert_contains "$case_id" "malformed control returns stable reason" "BOUNDARY_MALFORMED"
assert_control_fingerprint_unchanged "$case_id" \
  "malformed control is not rewritten" "$baseline"
end_case "$case_id"

# RB-SCHEMA-MALFORMED-EXPLICIT-REPAIR ----------------------------------------
case_id="RB-SCHEMA-MALFORMED-EXPLICIT-REPAIR"
begin_case "$case_id" "Explicit valid repository intent atomically repairs malformed current-session control state."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
printf '%s\n' '{"schemaVersion":1,"sessionId":"malformed","revision":0,"transitionHistory":[]}' >"$CONTROL_FILE"
invoke_binding "$case_id" "explicit valid root replaces malformed control without ambient inference" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --repository-root "$repo_a" --workspace-root "$repo_a"
assert_rc_zero "$case_id" "explicit malformed-state repair succeeds"
assert_contains "$case_id" "explicit malformed-state repair reports establishment" \
  "source=explicit-repositoryRoot affinity=established"
assert_control "$case_id" "$repo_a" "1"
end_case "$case_id"

# RB-SCHEMA-DEFINITIONS-AND-CONSTRAINTS --------------------------------------
case_id="RB-SCHEMA-DEFINITIONS-AND-CONSTRAINTS"
begin_case "$case_id" "The shared schema exposes strict control, actionable, redacted, refusal, and scoped-node contracts."
assert_schema_contract "$case_id" "schema defines an actionable packet contract" \
  'has("$defs") and (. ["$defs"] | has("actionablePacket"))'
assert_schema_contract "$case_id" "schema defines a redacted packet contract" \
  'has("$defs") and (. ["$defs"] | has("redactedPacket"))'
assert_schema_contract "$case_id" "schema defines a scoped-node packet contract" \
  'has("$defs") and (. ["$defs"] | has("scopedNodePacket"))'
assert_schema_contract "$case_id" "schema refusal contract rejects unspecified fields" \
  '.["$defs"].refusal.additionalProperties == false'
assert_schema_contract "$case_id" "schema decision contract selects actionable, redacted, or scoped-node variants" \
  'any(.oneOf[]?; .["$ref"] == "#/$defs/actionablePacket") and
   any(.oneOf[]?; .["$ref"] == "#/$defs/redactedPacket") and
   any(.oneOf[]?; .["$ref"] == "#/$defs/scopedNodePacket")'
end_case "$case_id"

# RB-SCHEMA-DRAFT202012-VALIDATION -------------------------------------------
case_id="RB-SCHEMA-DRAFT202012-VALIDATION"
begin_case "$case_id" "Draft 2020-12 validation accepts each S1 contract and rejects malformed variants."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
control_instance="$CASE_DIR/control-valid.json"
actionable_instance="$CASE_DIR/actionable-valid.json"
redacted_instance="$CASE_DIR/redacted-valid.json"
scoped_instance="$CASE_DIR/scoped-valid.json"
refusal_instance="$CASE_DIR/refusal-valid.json"
invalid_instance="$CASE_DIR/packet-invalid.json"
write_valid_control "$control_instance" "$SESSION_ID" "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author schema control instance"
write_actionable_packet "$actionable_instance" "$SESSION_ID" 1 "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author schema actionable instance"
jq '.repositoryRoot = "<redacted-local-root>"
    | .repositoryResolution.pathVisibility = "redacted"
    | .repositoryResolution.actionable = false' \
  "$actionable_instance" >"$redacted_instance" || \
  fatal_fixture "$case_id" "cannot author schema redacted instance"
jq --arg node "foundation-node" \
  '.repositoryResolution.decisionId = (.repositoryResolution.decisionId + ":node:" + $node)
   | .repositoryResolution.authority = "scoped-scenario-node"
   | .repositoryResolution.transition = "scoped-override"
   | .repositoryResolution.scopeKind = "goal-node"
   | .repositoryResolution.scopeId = $node
   | .repositoryResolution.targetKind = "goal-node"' \
  "$actionable_instance" >"$scoped_instance" || \
  fatal_fixture "$case_id" "cannot author schema scoped-node instance"
jq -n '{
  outcome: "refused",
  reasonCode: "TARGETLESS_MULTI_ROOT_UNBOUND",
  observedSignals: [],
  trustedBoundaryState: {status: "absent", repository: "none"},
  requiredInput: {
    field: "repositoryRoot",
    requirement: "one eligible canonical repository root"
  },
  remediation: {input: {repositoryRoot: "<canonical-repository-root>"}},
  affinity: "unchanged",
  repoLocalSideEffects: "zero"
}' >"$refusal_instance" || fatal_fixture "$case_id" "cannot author schema refusal instance"
jq '.repositoryResolution.authority = "ambient-cwd"' \
  "$actionable_instance" >"$invalid_instance" || \
  fatal_fixture "$case_id" "cannot author schema invalid instance"
assert_schema_instance "$case_id" "schema accepts independent control record" \
  "$control_instance" valid
assert_schema_instance "$case_id" "schema accepts local actionable command packet" \
  "$actionable_instance" valid
assert_schema_instance "$case_id" "schema accepts public redacted packet" \
  "$redacted_instance" valid
assert_schema_instance "$case_id" "schema accepts scoped goal-node packet" \
  "$scoped_instance" valid
assert_schema_instance "$case_id" "schema accepts structured refusal" \
  "$refusal_instance" valid
assert_schema_instance "$case_id" "schema rejects out-of-vocabulary authority" \
  "$invalid_instance" invalid
end_case "$case_id"

# RB-SCHEMA-CONTROL-CLOSED-ENUMS ---------------------------------------------
case_id="RB-SCHEMA-CONTROL-CLOSED-ENUMS"
begin_case "$case_id" "Control validation rejects authority and transition values outside the closed schema vocabulary."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
write_valid_control "$CONTROL_FILE" "$SESSION_ID" "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author closed-enum control fixture"
jq '.currentBinding.establishedAuthority = "ambient-cwd"
    | .transitionHistory[0].authority = "ambient-cwd"' \
  "$CONTROL_FILE" >"$CASE_DIR/invalid-control.json" || \
  fatal_fixture "$case_id" "cannot author invalid closed-enum control fixture"
mv "$CASE_DIR/invalid-control.json" "$CONTROL_FILE" || \
  fatal_fixture "$case_id" "cannot install invalid closed-enum control fixture"
baseline="$(control_fingerprint)"
invoke_binding "$case_id" "an out-of-vocabulary authority makes control state malformed" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a" --workspace-root "$repo_b"
assert_rc_nonzero "$case_id" "invalid control authority refuses"
assert_contains "$case_id" "invalid control authority reports malformed state" "BOUNDARY_MALFORMED"
assert_control_fingerprint_unchanged "$case_id" \
  "invalid control is never rewritten" "$baseline"
end_case "$case_id"

# RB-SCHEMA-ACTIONABLE-PACKET-POSITIVE ---------------------------------------
case_id="RB-SCHEMA-ACTIONABLE-PACKET-POSITIVE"
begin_case "$case_id" "A local actionable packet matching session/root/decision/revision validates exactly."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
packet_file="$CASE_DIR/actionable-packet.json"
write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author actionable packet"
invoke_binding "$case_id" "matching actionable local packet is consumable" \
  "$WORKSPACE_DIR" validate-packet \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
assert_rc_zero "$case_id" "matching actionable packet validates"
assert_contains "$case_id" "packet validation reports actionable local authority" "actionable=true"
end_case "$case_id"

# RB-SCHEMA-PACKET-CLOSED-CONTRACT -------------------------------------------
case_id="RB-SCHEMA-PACKET-CLOSED-CONTRACT"
begin_case "$case_id" "Actionable packet validation rejects invalid enums and command packets with scoped-node fields."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
packet_file="$CASE_DIR/actionable-packet.json"
write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author strict actionable packet"
for variant in invalid-authority command-with-scope-id; do
  variant_file="$CASE_DIR/$variant.json"
  case "$variant" in
    invalid-authority)
      jq '.repositoryResolution.authority = "ambient-cwd"' "$packet_file" >"$variant_file" || \
        fatal_fixture "$case_id" "cannot author invalid-authority packet"
      ;;
    command-with-scope-id)
      jq '.repositoryResolution.scopeId = "node-that-must-not-escape"' "$packet_file" >"$variant_file" || \
        fatal_fixture "$case_id" "cannot author invalid command-scope packet"
      ;;
  esac
  invoke_binding "$case_id" "$variant packet is structurally malformed" \
    "$WORKSPACE_DIR" validate-packet \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" --packet-file "$variant_file"
  assert_rc_nonzero "$case_id" "$variant packet refuses"
  assert_contains "$case_id" "$variant packet reports malformed shape" "PACKET_MALFORMED"
done
end_case "$case_id"

# RB-PROJECTION-REDACTED-NONACTIONABLE ---------------------------------------
case_id="RB-PROJECTION-REDACTED-NONACTIONABLE"
begin_case "$case_id" "A public redacted packet is structurally non-actionable and cannot authorize work."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
actionable_packet="$CASE_DIR/actionable-local-packet.json"
packet_file="$CASE_DIR/redacted-public-packet.json"
write_actionable_packet "$actionable_packet" "$SESSION_ID" 1 "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author actionable projection source"
invoke_binding "$case_id" "production validation emits a public non-actionable projection" \
  "$WORKSPACE_DIR" validate-packet \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --packet-file "$actionable_packet" --emit-redacted-projection
assert_rc_zero "$case_id" "production public projection succeeds"
assert_contains "$case_id" "production projection redacts the canonical root" \
  '"repositoryRoot":"<redacted-local-root>"'
assert_contains "$case_id" "production projection marks path visibility redacted" \
  '"pathVisibility":"redacted"'
assert_contains "$case_id" "production projection marks the packet non-actionable" \
  '"actionable":false'
assert_excludes "$case_id" "production public projection emits no local canonical path" "$repo_a"
printf '%s\n' "$LAST_OUTPUT" >"$packet_file" || \
  fatal_fixture "$case_id" "cannot preserve production redacted projection"
invoke_binding "$case_id" "public redacted projection cannot be consumed as execution authority" \
  "$WORKSPACE_DIR" validate-packet \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
assert_rc_nonzero "$case_id" "redacted public packet is rejected"
assert_contains "$case_id" "redacted packet refusal names non-actionability" "actionable"
assert_contains "$case_id" "redacted packet refusal preserves redaction semantics" "redacted"
end_case "$case_id"

# RB-FOUR-SUBCOMMAND-CONTRACT -------------------------------------------------
case_id="RB-FOUR-SUBCOMMAND-CONTRACT"
begin_case "$case_id" "All four production subcommands expose help and valid packets gate discovery and mirroring."
for subcommand in preflight validate-packet discover-specs mirror-session; do
  invoke_binding "$case_id" "$subcommand help is available" \
    "$WORKSPACE_DIR" "$subcommand" --help
  assert_rc_zero "$case_id" "$subcommand --help exits zero"
  assert_contains "$case_id" "$subcommand help names its command" "$subcommand"
done
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
mkdir -p "$repo_a/specs/001-foundation-sentinel" || \
  fatal_fixture "$case_id" "cannot create scoped discovery sentinel"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
packet_file="$CASE_DIR/actionable-packet.json"
write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "prior-work-repo" || \
  fatal_fixture "$case_id" "cannot author four-subcommand packet"
invoke_binding "$case_id" "discover-specs consumes a current actionable packet" \
  "$WORKSPACE_DIR" discover-specs --session-id "$SESSION_ID" \
  --session-control-file "$CONTROL_FILE" --packet-file "$packet_file" --mode foundation
assert_rc_zero "$case_id" "discover-specs succeeds with a current packet"
assert_contains "$case_id" "discover-specs emits the canonical repository scope" \
  "DISCOVERY SCOPE mode=foundation root=$repo_a/specs"
assert_contains "$case_id" "discover-specs returns only the selected sentinel" \
  "$repo_a/specs/001-foundation-sentinel"
invoke_binding "$case_id" "mirror-session consumes a current actionable packet" \
  "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
  --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
assert_rc_zero "$case_id" "mirror-session succeeds with a current packet"
assert_file_exists "$case_id" "mirror-session writes only the selected fixture mirror" \
  "$repo_a/.specify/memory/bubbles.session.json"
end_case "$case_id"

# RB-SUBCOMMAND-ARGUMENT-REFUSALS --------------------------------------------
case_id="RB-SUBCOMMAND-ARGUMENT-REFUSALS"
begin_case "$case_id" "Every production subcommand fails loud on missing, unknown, or out-of-vocabulary arguments."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
invoke_binding "$case_id" "preflight rejects unsupported request classes" \
  "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
  --session-control-file "$CONTROL_FILE" --request-class AMBIENT_GUESS \
  --workspace-root "$repo_a"
assert_rc_nonzero "$case_id" "preflight rejects unsupported request class"
assert_contains "$case_id" "preflight names the supported request-class requirement" \
  "supported --request-class"
assert_no_control "$case_id"

invoke_binding "$case_id" "validate-packet rejects a missing packet" \
  "$WORKSPACE_DIR" validate-packet --session-id "$SESSION_ID" \
  --session-control-file "$CONTROL_FILE"
assert_rc_nonzero "$case_id" "validate-packet rejects missing packet file"
assert_contains "$case_id" "validate-packet prints focused usage" \
  "validate-packet requires control and packet files"

invoke_binding "$case_id" "discover-specs rejects a missing mode" \
  "$WORKSPACE_DIR" discover-specs --session-id "$SESSION_ID" \
  --session-control-file "$CONTROL_FILE" --packet-file "$CASE_DIR/missing-packet.json"
assert_rc_nonzero "$case_id" "discover-specs rejects missing mode"
assert_contains "$case_id" "discover-specs prints focused usage" \
  "Usage: repository-binding.sh discover-specs"

invoke_binding "$case_id" "mirror-session rejects unknown options" \
  "$WORKSPACE_DIR" mirror-session --unknown-option
assert_rc_nonzero "$case_id" "mirror-session rejects unknown option"
assert_contains "$case_id" "mirror-session prints focused usage" \
  "Usage: repository-binding.sh mirror-session"
end_case "$case_id"

# RB-CONTROL-LOCK-BUSY-PRESERVES --------------------------------------------
case_id="RB-CONTROL-LOCK-BUSY-PRESERVES"
begin_case "$case_id" "Lock contention is a schema-valid ordinary refusal that reports and preserves the prior committed boundary."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a"
baseline="$(control_fingerprint)"
mkdir "$CONTROL_FILE.lock" || fatal_fixture "$case_id" "cannot hold the control lock fixture"
invoke_binding "$case_id" "held control lock refuses without losing prior affinity" \
  "$WORKSPACE_DIR" preflight \
  --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
  --request-class TARGETLESS_MODE --workspace-root "$repo_a"
assert_rc_nonzero "$case_id" "held control lock blocks the competing preflight"
assert_contains "$case_id" "lock contention uses the closed reason code" \
  "reasonCode: CONTROL_LOCK_BUSY"
assert_contains "$case_id" "lock contention reports the prior boundary as valid" \
  "trustedBoundaryState.status: valid"
assert_contains "$case_id" "lock contention reports the prior committed root" \
  "trustedBoundaryState.repository: $repo_a"
assert_control_fingerprint_unchanged "$case_id" \
  "lock contention leaves prior control bytes unchanged" "$baseline"
rmdir "$CONTROL_FILE.lock" || fatal_fixture "$case_id" "cannot release held control lock fixture"
assert_schema_contract "$case_id" "schema closes CONTROL_LOCK_BUSY into refusal reasons" \
  '."$defs".refusal.properties.reasonCode.enum | index("CONTROL_LOCK_BUSY") != null'
lock_refusal_instance="$CASE_DIR/control-lock-busy-refusal.json"
jq -n --arg root "$repo_a" '{
  outcome: "refused",
  reasonCode: "CONTROL_LOCK_BUSY",
  observedSignals: [],
  trustedBoundaryState: {status: "valid", repository: $root},
  requiredInput: {field: "repositoryRoot", requirement: "one eligible canonical repository root"},
  remediation: {input: {repositoryRoot: "<canonical-repository-root>"}},
  affinity: "unchanged",
  repoLocalSideEffects: "zero"
}' >"$lock_refusal_instance" || fatal_fixture "$case_id" "cannot author lock refusal schema fixture"
assert_schema_instance "$case_id" "schema accepts lock contention with prior valid affinity" \
  "$lock_refusal_instance" valid
end_case "$case_id"

# RB-TRANSITION-CONCURRENT-SWITCH-CAS ----------------------------------------
case_id="RB-TRANSITION-CONCURRENT-SWITCH-CAS"
begin_case "$case_id" "Two switches from one observed revision permit exactly one atomic commit."
repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
  --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"

if [[ ! -f "$RESOLVER" ]]; then
  LAST_INTERFACE_AVAILABLE=0
  LAST_RC=127
  LAST_OUTPUT="REPOSITORY-BINDING RED case=$case_id behavioralContract=concurrent-revision-CAS missingProductionInterface=bubbles/scripts/repository-binding.sh"
  printf '%s\n' "$LAST_OUTPUT"
  assert_rc_zero "$case_id" "one concurrent switch commits through the production CAS boundary"
else
  out_b="$CASE_DIR/switch-b.out"
  out_c="$CASE_DIR/switch-c.out"
  (
    bash "$RESOLVER" preflight \
      --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
      --expected-control-revision 1 --request-class TARGETLESS_MODE \
      --repository-root "$repo_b" \
      --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
  ) >"$out_b" 2>&1 &
  pid_b=$!
  (
    bash "$RESOLVER" preflight \
      --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
      --expected-control-revision 1 --request-class TARGETLESS_MODE \
      --repository-root "$repo_c" \
      --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
  ) >"$out_c" 2>&1 &
  pid_c=$!
  wait "$pid_b"
  rc_b=$?
  wait "$pid_c"
  rc_c=$?
  cat "$out_b"
  printf 'CONCURRENT EXIT [%s] switch-b=%s\n' "$case_id" "$rc_b"
  cat "$out_c"
  printf 'CONCURRENT EXIT [%s] switch-c=%s\n' "$case_id" "$rc_c"
  successes=0
  [[ "$rc_b" -eq 0 ]] && successes=$((successes + 1))
  [[ "$rc_c" -eq 0 ]] && successes=$((successes + 1))
  if [[ "$successes" -eq 1 ]]; then
    pass_assertion "$case_id" "exactly one concurrent switch commits"
  else
    fail_assertion "$case_id" "exactly one concurrent switch commits" \
      "switchBExit=$rc_b switchCExit=$rc_c"
  fi
  committed_root="$(control_value '.currentBinding.repositoryRoot')"
  committed_revision="$(control_value '.revision')"
  if [[ "$committed_revision" == "2" && \
        ( "$committed_root" == "$repo_b" || "$committed_root" == "$repo_c" ) ]]; then
    pass_assertion "$case_id" "CAS commit advances once to revision 2"
  else
    fail_assertion "$case_id" "CAS commit advances once to revision 2" \
      "actual=$committed_root@$committed_revision"
  fi
fi
end_case "$case_id"

printf '\n=== foundation summary ===\n'
printf 'casesRun=%s casesPass=%s casesRed=%s\n' "$cases_run" "$cases_passed" "$cases_red"
printf 'assertionsPass=%s assertionsFail=%s assertionsSkip=%s\n' \
  "$assertions_passed" "$assertions_failed" "$assertions_skipped"
if [[ "$assertions_failed" -ne 0 ]]; then
  printf 'repository-binding foundation verdict=RED unresolvedBehavioralContracts=%s\n' \
    "$assertions_failed"
  exit 1
fi

echo "repository-binding foundation verdict=PASS"
