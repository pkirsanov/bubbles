#!/usr/bin/env bash
# Literal jq programs intentionally keep JSON Schema keys such as "$defs" unexpanded.
# shellcheck disable=SC2016
set -u
set -o pipefail

# Hermetic behavior contract for IMP-103 S1 (Repository Binding Foundation).
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
STATE_SNAPSHOT="$SCRIPT_DIR/state-snapshot.sh"
STATE_SNAPSHOT_SELFTEST="$SCRIPT_DIR/state-snapshot-selftest.sh"
CONTEXT_COMPACTOR="$SCRIPT_DIR/context-compactor.sh"
CONTEXT_COMPACTOR_SELFTEST="$SCRIPT_DIR/context-compactor-selftest.sh"
RESULT_VALIDATOR="$SCRIPT_DIR/result-envelope-validate.sh"
RESULT_VALIDATOR_SELFTEST="$SCRIPT_DIR/result-envelope-validate-selftest.sh"
RESULT_SCHEMA="$SCRIPT_DIR/../schemas/result-envelope.schema.json"
DELEGATION_CORE="$SCRIPT_DIR/../../agents/bubbles_shared/workflow-delegation-core.md"
WORKFLOW_AGENT="$SCRIPT_DIR/../../agents/bubbles.workflow.agent.md"
SUPER_AGENT="$SCRIPT_DIR/../../agents/bubbles.super.agent.md"
ITERATE_AGENT="$SCRIPT_DIR/../../agents/bubbles.iterate.agent.md"
GOAL_AGENT="$SCRIPT_DIR/../../agents/bubbles.goal.agent.md"
SPRINT_AGENT="$SCRIPT_DIR/../../agents/bubbles.sprint.agent.md"
RECAP_AGENT="$SCRIPT_DIR/../../agents/bubbles.recap.agent.md"
STATUS_AGENT="$SCRIPT_DIR/../../agents/bubbles.status.agent.md"
HANDOFF_AGENT="$SCRIPT_DIR/../../agents/bubbles.handoff.agent.md"
AGENT_COMMON="$SCRIPT_DIR/../../agents/bubbles_shared/agent-common.md"
SCENARIO_CONTRACT="$SCRIPT_DIR/../../agents/bubbles_shared/scenario-compile.md"
SCENARIO_LINT="$SCRIPT_DIR/scenario-compile-lint.sh"
RESULT_SKILL="$SCRIPT_DIR/../../skills/bubbles-result-envelope/SKILL.md"
CAPABILITY_REGISTRY="$SCRIPT_DIR/../agent-capabilities.yaml"
SOURCE_BINDING_PREFLIGHT="$SCRIPT_DIR/repo-binding-preflight.sh"
EXECUTION_LOOPS="$SCRIPT_DIR/../../agents/bubbles_shared/workflow-execution-loops.md"
MODE_REGISTRY="$SCRIPT_DIR/../workflows/modes.yaml"
CONFORMANCE_GUARD="$SCRIPT_DIR/repository-binding-conformance-guard.sh"
CONFORMANCE_SELFTEST="$SCRIPT_DIR/repository-binding-conformance-guard-selftest.sh"

suite="foundation"
for arg in "$@"; do
  case "$arg" in
    --suite=foundation) suite="foundation" ;;
    --suite=state-propagation) suite="state-propagation" ;;
    --suite=classification-discovery) suite="classification-discovery" ;;
    --suite=front-doors-goal-nodes) suite="front-doors-goal-nodes" ;;
    --suite=shared-infrastructure-canary) suite="shared-infrastructure-canary" ;;
    --suite=conformance) suite="conformance" ;;
    --suite=all) suite="all" ;;
    -h|--help)
      cat <<'EOF'
Usage: repository-binding-selftest.sh --suite=<suite>

Suites:
  foundation                    IMP-103 S1 repository binding foundation
  state-propagation             IMP-103 S2 mirror and provenance propagation
  classification-discovery      IMP-103 S3 classification and scoped discovery
  front-doors-goal-nodes        IMP-103 S4 front doors, packets, and scoped goal nodes
  shared-infrastructure-canary  Legacy state/compactor/result contracts
  conformance                   IMP-103 S3-S4 source conformance fixtures
  all                           All suites in deterministic dependency order
EOF
      exit 0
      ;;
    *)
      printf 'repository-binding-selftest: unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

if [[ "$suite" != "foundation" && "$suite" != "state-propagation" && \
  "$suite" != "classification-discovery" && \
  "$suite" != "front-doors-goal-nodes" && \
  "$suite" != "shared-infrastructure-canary" && "$suite" != "conformance" && \
  "$suite" != "all" ]]; then
  printf 'repository-binding-selftest: unsupported suite: %s\n' "$suite" >&2
  exit 2
fi

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

invoke_real_script() {
  local case_id="$1"
  local behavior="$2"
  local invocation_cwd="$3"
  local script="$4"
  shift 4

  printf 'COMMAND [%s] cwd=%s bash %s' "$case_id" "$invocation_cwd" "$script"
  printf ' %s' "$@"
  printf '\n'

  if [[ ! -f "$script" ]]; then
    LAST_INTERFACE_AVAILABLE=0
    LAST_RC=127
    LAST_OUTPUT="missingProductionInterface=$script"
  else
    LAST_INTERFACE_AVAILABLE=1
    LAST_OUTPUT="$({
      cd -P -- "$invocation_cwd" || exit 125
      BUBBLES_REPO_ROOT="$invocation_cwd" \
      BUBBLES_AGENT_NAME="bubbles.test" \
        bash "$script" "$@"
    } 2>&1)"
    LAST_RC=$?
  fi

  if [[ -n "$LAST_OUTPUT" ]]; then
    printf '%s\n' "$LAST_OUTPUT"
  else
    printf '<no production output>\n'
  fi
  printf 'EXIT [%s] %s behavior=%s\n' "$case_id" "$LAST_RC" "$behavior"
}

assert_real_selftest_green() {
  local case_id="$1"
  local description="$2"
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true"
  elif [[ "$LAST_OUTPUT" == *"SKIP ("* ]]; then
    fail_assertion "$case_id" "$description" "commandSkipped=true"
  elif [[ "$LAST_RC" -eq 0 ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "expectedExit=0 actualExit=$LAST_RC"
  fi
}

assert_json_scalar() {
  local case_id="$1"
  local description="$2"
  local file="$3"
  local query="$4"
  local expected="$5"
  local actual=""
  if [[ ! -f "$file" ]]; then
    fail_assertion "$case_id" "$description" "missingJson=$file"
    return
  fi
  actual="$(jq -r "$query" "$file" 2>/dev/null)"
  if [[ "$actual" == "$expected" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "expected=$expected actual=$actual"
  fi
}

assert_json_compact() {
  local case_id="$1"
  local description="$2"
  local file="$3"
  local query="$4"
  local expected="$5"
  local actual=""
  if [[ ! -f "$file" ]]; then
    fail_assertion "$case_id" "$description" "missingJson=$file"
    return
  fi
  actual="$(jq -c "$query" "$file" 2>/dev/null)"
  if [[ "$actual" == "$expected" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "expected=$expected actual=$actual"
  fi
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

assert_file_absent() {
  local case_id="$1"
  local description="$2"
  local file="$3"
  if [[ ! -e "$file" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "unexpectedFile=$file"
  fi
}

assert_files_equal() {
  local case_id="$1"
  local description="$2"
  local expected_file="$3"
  local actual_file="$4"
  if [[ ! -f "$expected_file" || ! -f "$actual_file" ]]; then
    fail_assertion "$case_id" "$description" \
      "missingComparisonFile expected=$expected_file actual=$actual_file"
  elif cmp -s "$expected_file" "$actual_file"; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "filesDiffer=true"
  fi
}

assert_output_regex() {
  local case_id="$1"
  local description="$2"
  local pattern="$3"
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true"
  elif printf '%s\n' "$LAST_OUTPUT" | grep -Eqi "$pattern"; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "missingOutputPattern=$pattern"
  fi
}

assert_output_json_scalar() {
  local case_id="$1"
  local description="$2"
  local query="$3"
  local expected="$4"
  local actual=""
  if [[ "$LAST_INTERFACE_AVAILABLE" -ne 1 ]]; then
    fail_assertion "$case_id" "$description" "productionInterfaceUnavailable=true"
    return
  fi
  actual="$(printf '%s\n' "$LAST_OUTPUT" | jq -r "$query" 2>/dev/null)"
  if [[ "$actual" == "$expected" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "expected=$expected actual=$actual"
  fi
}

capture_packet_from_last_output() {
  local packet_file="$1"
  local line=""
  local packet=""

  while IFS= read -r line; do
    case "$line" in
      \{*)
        if printf '%s\n' "$line" | jq -e \
          'type == "object" and has("repositoryRoot") and has("repositoryResolution")' \
          >/dev/null 2>&1; then
          packet="$line"
        fi
        ;;
    esac
  done <<< "$LAST_OUTPUT"
  [[ -n "$packet" ]] || return 1
  printf '%s\n' "$packet" >"$packet_file"
}

markdown_section() {
  local file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    $0 == heading { capture=1; next }
    capture && /^#/ { exit }
    capture { print }
  ' "$file"
}

markdown_subtree() {
  local file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    function heading_level(line, copy) {
      copy = line
      sub(/[^#].*$/, "", copy)
      return length(copy)
    }
    $0 == heading {
      capture = 1
      level = heading_level($0)
      next
    }
    capture && /^#+[[:space:]]/ && heading_level($0) <= level { exit }
    capture { print }
  ' "$file"
}

markdown_last_heading_tail() {
  local file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    $0 == heading {
      capture = 1
      text = ""
      next
    }
    capture { text = text $0 ORS }
    END { printf "%s", text }
  ' "$file"
}

repository_binding_sections() {
  local file="$1"
  awk '
    function heading_level(line, copy) {
      copy = line
      sub(/[^#].*$/, "", copy)
      return length(copy)
    }
    /^#+[[:space:]].*Repository Binding/ {
      capture = 1
      level = heading_level($0)
      print
      next
    }
    capture && /^#+[[:space:]]/ && heading_level($0) <= level {
      capture = 0
    }
    capture { print }
  ' "$file"
}

yaml_mode_section() {
  local file="$1"
  local mode="$2"
  local heading="  $mode:"
  awk -v heading="$heading" '
    $0 == heading { capture=1 }
    capture && $0 != heading && /^  [A-Za-z0-9_-]+:$/ { exit }
    capture { print }
  ' "$file"
}

assert_text_contains() {
  local case_id="$1"
  local description="$2"
  local text="$3"
  local expected="$4"
  case "$text" in
    *"$expected"*) pass_assertion "$case_id" "$description" ;;
    *) fail_assertion "$case_id" "$description" "missingText=$expected" ;;
  esac
}

assert_text_excludes() {
  local case_id="$1"
  local description="$2"
  local text="$3"
  local forbidden="$4"
  case "$text" in
    *"$forbidden"*) fail_assertion "$case_id" "$description" "forbiddenText=$forbidden" ;;
    *) pass_assertion "$case_id" "$description" ;;
  esac
}

assert_text_regex() {
  local case_id="$1"
  local description="$2"
  local text="$3"
  local pattern="$4"
  if printf '%s\n' "$text" | grep -Eq "$pattern"; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" "missingTextPattern=$pattern"
  fi
}

assert_text_before() {
  local case_id="$1"
  local description="$2"
  local text="$3"
  local first="$4"
  local second="$5"
  local first_position=""
  local second_position=""
  local first_line=0
  local first_column=0
  local second_line=0
  local second_column=0

  first_position="$(printf '%s\n' "$text" | awk -v needle="$first" \
    'index($0, needle) { print NR ":" index($0, needle); exit }')"
  second_position="$(printf '%s\n' "$text" | awk -v needle="$second" \
    'index($0, needle) { print NR ":" index($0, needle); exit }')"
  if [[ -z "$first_position" || -z "$second_position" ]]; then
    fail_assertion "$case_id" "$description" \
      "missingOrderAnchor first=${first_position:-missing} second=${second_position:-missing}"
    return
  fi
  first_line="${first_position%%:*}"
  first_column="${first_position#*:}"
  second_line="${second_position%%:*}"
  second_column="${second_position#*:}"
  if [[ "$first_line" -lt "$second_line" ]] || \
    { [[ "$first_line" -eq "$second_line" ]] && [[ "$first_column" -lt "$second_column" ]]; }; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" \
      "expectedOrder=$first>$second actual=$first_position>$second_position"
  fi
}

assert_binding_field_contract() {
  local case_id="$1"
  local description="$2"
  local text="$3"
  local expected=""
  local actual=""

  expected="$(printf '%s\n' \
    repositoryRoot \
    repositoryAlias \
    repositoryResolution.sessionId \
    repositoryResolution.decisionId \
    repositoryResolution.controlRevision \
    repositoryResolution.authority \
    repositoryResolution.transition \
    repositoryResolution.scopeKind \
    repositoryResolution.scopeId \
    repositoryResolution.targetKind \
    repositoryResolution.pathVisibility \
    repositoryResolution.actionable)"
  actual="$(printf '%s\n' "$text" | awk '
    function remember_exact(name) { found[name] = 1 }
    {
      line = $0
      while (match(line, /repositoryResolution\.[A-Za-z][A-Za-z]*/)) {
        remember_exact(substr(line, RSTART, RLENGTH))
        line = substr(line, RSTART + RLENGTH)
      }
      if ($0 ~ /(^|[^A-Za-z])repositoryRoot([^A-Za-z]|$)/) {
        remember_exact("repositoryRoot")
      }
      if ($0 ~ /(^|[^A-Za-z])repositoryAlias([^A-Za-z]|$)/) {
        remember_exact("repositoryAlias")
      }
    }
    END {
      expected[1] = "repositoryRoot"
      expected[2] = "repositoryAlias"
      expected[3] = "repositoryResolution.sessionId"
      expected[4] = "repositoryResolution.decisionId"
      expected[5] = "repositoryResolution.controlRevision"
      expected[6] = "repositoryResolution.authority"
      expected[7] = "repositoryResolution.transition"
      expected[8] = "repositoryResolution.scopeKind"
      expected[9] = "repositoryResolution.scopeId"
      expected[10] = "repositoryResolution.targetKind"
      expected[11] = "repositoryResolution.pathVisibility"
      expected[12] = "repositoryResolution.actionable"
      for (field_index = 1; field_index <= 12; field_index++) {
        if (found[expected[field_index]]) print expected[field_index]
      }
      for (name in found) {
        known = 0
        for (field_index = 1; field_index <= 12; field_index++) {
          if (name == expected[field_index]) known = 1
        }
        if (!known) print "UNEXPECTED:" name
      }
    }
  ')"
  if [[ "$actual" == "$expected" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" \
      "exactBindingFieldSetMismatch expected=$(printf '%s' "$expected" | tr '\n' ',') actual=$(printf '%s' "$actual" | tr '\n' ',')"
  fi
}

assert_result_schema_exact_binding() {
  local case_id="$1"
  local description="$2"
  local query='
    (.properties.repositoryRoot.type == "string") and
    (.properties.repositoryAlias.type == "string") and
    (
      (.properties.repositoryResolution."$ref" | type == "string" and contains("repository-binding.schema.json"))
      or
      (
        .properties.repositoryResolution.additionalProperties == false
        and ((.properties.repositoryResolution.required | sort) ==
          (["sessionId", "decisionId", "controlRevision", "authority", "transition",
            "scopeKind", "scopeId", "targetKind", "pathVisibility", "actionable"] | sort))
      )
    )'

  assert_schema_contract "$case_id" "$description" "$query" "$RESULT_SCHEMA"
}

workflow_mode_grant_agents() {
  awk '
    $0 == "workflowModeGrants:" { in_grants = 1; next }
    in_grants && $0 == "  agents:" { in_agents = 1; next }
    in_agents && /^[^[:space:]]/ { exit }
    in_agents && /^    [A-Za-z0-9_.-]+:[[:space:]]*$/ {
      value = $0
      sub(/^[[:space:]]+/, "", value)
      sub(/:[[:space:]]*$/, "", value)
      print value
    }
  ' "$CAPABILITY_REGISTRY"
}

assert_output_order() {
  local case_id="$1"
  local description="$2"
  local first="$3"
  local second="$4"
  local third="$5"
  local first_line=""
  local second_line=""
  local third_line=""

  first_line="$(printf '%s\n' "$LAST_OUTPUT" | awk -v needle="$first" 'index($0, needle) { print NR; exit }')"
  second_line="$(printf '%s\n' "$LAST_OUTPUT" | awk -v needle="$second" 'index($0, needle) { print NR; exit }')"
  third_line="$(printf '%s\n' "$LAST_OUTPUT" | awk -v needle="$third" 'index($0, needle) { print NR; exit }')"
  if [[ -n "$first_line" && -n "$second_line" && -n "$third_line" && \
        "$first_line" -lt "$second_line" && "$second_line" -lt "$third_line" ]]; then
    pass_assertion "$case_id" "$description"
  else
    fail_assertion "$case_id" "$description" \
      "expectedOrder=$first>$second>$third actualLines=${first_line:-missing},${second_line:-missing},${third_line:-missing}"
  fi
}

create_result_validator_fixture() {
  local case_id="$1"
  local label="$2"
  local packet_file="$3"
  local result_repo="$CASE_DIR/result-$label"
  local agent_file="$result_repo/agents/bubbles.fixture.agent.md"

  mkdir -p "$result_repo/agents" "$result_repo/bubbles/scripts" "$result_repo/bubbles/schemas" || \
    fatal_fixture "$case_id" "cannot create result validator fixture"
  ln -s "$RESULT_VALIDATOR" "$result_repo/bubbles/scripts/result-envelope-validate.sh" || \
    fatal_fixture "$case_id" "cannot link real result validator"
  ln -s "$RESULT_SCHEMA" "$result_repo/bubbles/schemas/result-envelope.schema.json" || \
    fatal_fixture "$case_id" "cannot link real result schema"
  ln -s "$SCHEMA" "$result_repo/bubbles/schemas/repository-binding.schema.json" || \
    fatal_fixture "$case_id" "cannot link reusable repository binding schema"

  {
    printf '%s\n' '# Fixture Agent' '' '## RESULT-ENVELOPE' '' '```json'
    if [[ "$packet_file" == "missing" ]]; then
      jq -n '{
        agent: "bubbles.fixture",
        outcome: "completed_owned",
        summary: "repository-sensitive fixture result"
      }'
    else
      jq -n --slurpfile binding "$packet_file" \
        '$binding[0] + {
          agent: "bubbles.fixture",
          outcome: "completed_owned",
          summary: "repository-sensitive fixture result"
        }'
    fi
    printf '%s\n' '```'
  } >"$agent_file" || fatal_fixture "$case_id" "cannot write result fixture agent"

  git init -q "$result_repo" || fatal_fixture "$case_id" "git init failed for result fixture"
  git -C "$result_repo" config user.name "Bubbles Fixture" || \
    fatal_fixture "$case_id" "result fixture user.name failed"
  git -C "$result_repo" config user.email "fixture@example.invalid" || \
    fatal_fixture "$case_id" "result fixture user.email failed"
  git -C "$result_repo" add agents bubbles || fatal_fixture "$case_id" "result fixture git add failed"
  git -C "$result_repo" commit -q -m "result validator fixture" || \
    fatal_fixture "$case_id" "result fixture commit failed"
  printf '%s\n' "$result_repo"
}

write_handoff_envelope() {
  local target="$1"
  local packet_file="$2"
  local root=""
  local alias=""
  local session_id=""
  local decision_id=""
  local revision=""
  local authority=""
  local transition=""
  local scope_kind=""
  local scope_id=""
  local target_kind=""
  local visibility=""
  local actionable=""

  root="$(jq -r '.repositoryRoot' "$packet_file")"
  alias="$(jq -r '.repositoryAlias' "$packet_file")"
  session_id="$(jq -r '.repositoryResolution.sessionId' "$packet_file")"
  decision_id="$(jq -r '.repositoryResolution.decisionId' "$packet_file")"
  revision="$(jq -r '.repositoryResolution.controlRevision' "$packet_file")"
  authority="$(jq -r '.repositoryResolution.authority' "$packet_file")"
  transition="$(jq -r '.repositoryResolution.transition' "$packet_file")"
  scope_kind="$(jq -r '.repositoryResolution.scopeKind' "$packet_file")"
  scope_id="$(jq -r '.repositoryResolution.scopeId' "$packet_file")"
  target_kind="$(jq -r '.repositoryResolution.targetKind' "$packet_file")"
  visibility="$(jq -r '.repositoryResolution.pathVisibility' "$packet_file")"
  actionable="$(jq -r '.repositoryResolution.actionable' "$packet_file")"

  printf '%s\n' \
    '## RESULT-ENVELOPE' \
    'agent: bubbles.test' \
    'outcome: completed_owned' \
    'featureDir: improvements/IMP-103-session-repository-affinity.md' \
    "repositoryRoot: $root" \
    "repositoryAlias: $alias" \
    'repositoryResolution:' \
    "  sessionId: $session_id" \
    "  decisionId: $decision_id" \
    "  controlRevision: $revision" \
    "  authority: $authority" \
    "  transition: $transition" \
    "  scopeKind: $scope_kind" \
    "  scopeId: $scope_id" \
    "  targetKind: $target_kind" \
    "  pathVisibility: $visibility" \
    "  actionable: $actionable" \
    'evidenceRefs:' \
    '- state-propagation-evidence' >"$target"
}

write_goal_node_packet() {
  local packet_file="$1"
  local session_id="$2"
  local revision="$3"
  local repository_root="$4"
  local repository_alias="$5"
  local scope_id="$6"

  jq -n \
    --arg root "$repository_root" \
    --arg alias "$repository_alias" \
    --arg session "$session_id" \
    --arg decision "rb:$session_id:$revision:node:$scope_id" \
    --arg scope "$scope_id" \
    --argjson revision "$revision" \
    '{
      repositoryRoot: $root,
      repositoryAlias: $alias,
      repositoryResolution: {
        sessionId: $session,
        decisionId: $decision,
        controlRevision: $revision,
        authority: "scoped-scenario-node",
        transition: "scoped-override",
        scopeKind: "goal-node",
        scopeId: $scope,
        targetKind: "goal-node",
        pathVisibility: "local",
        actionable: true
      }
    }' >"$packet_file" || return 1
}

finish_named_suite() {
  local suite_name="$1"
  printf '\n=== %s summary ===\n' "$suite_name"
  printf 'casesRun=%s casesPass=%s casesRed=%s\n' "$cases_run" "$cases_passed" "$cases_red"
  printf 'assertionsPass=%s assertionsFail=%s assertionsSkip=%s\n' \
    "$assertions_passed" "$assertions_failed" "$assertions_skipped"
  if [[ "$assertions_failed" -ne 0 ]]; then
    printf 'repository-binding %s verdict=RED unresolvedBehavioralContracts=%s\n' \
      "$suite_name" "$assertions_failed"
    return 1
  fi
  printf 'repository-binding %s verdict=PASS\n' "$suite_name"
}

run_shared_infrastructure_canary_suite() {
  local case_id=""
  local repo_a=""
  local packet_file=""
  local session_file=""
  local raw_file=""
  local mirror_before=""
  local history_before=""

  echo "=== IMP-103 S2 shared-infrastructure canary ==="
  echo "SUITE shared-infrastructure-canary"

  case_id="RB-CANARY-LEGACY-STATE-SNAPSHOT"
  begin_case "$case_id" "The existing state snapshot contract executes and remains green."
  invoke_real_script "$case_id" "legacy state snapshot selftest executes" \
    "$WORKSPACE_DIR" "$STATE_SNAPSHOT_SELFTEST"
  assert_real_selftest_green "$case_id" "legacy state snapshot selftest ran and passed without SKIP"
  end_case "$case_id"

  case_id="RB-CANARY-LEGACY-CONTEXT-COMPACTOR"
  begin_case "$case_id" "The existing context compactor contract executes and remains green."
  invoke_real_script "$case_id" "legacy context compactor selftest executes" \
    "$WORKSPACE_DIR" "$CONTEXT_COMPACTOR_SELFTEST"
  assert_real_selftest_green "$case_id" "legacy context compactor selftest ran and passed without SKIP"
  end_case "$case_id"

  case_id="RB-CANARY-LEGACY-RESULT-ENVELOPE"
  begin_case "$case_id" "The existing result envelope validator contract executes and remains green."
  invoke_real_script "$case_id" "legacy result envelope validator selftest executes" \
    "$WORKSPACE_DIR" "$RESULT_VALIDATOR_SELFTEST"
  assert_real_selftest_green "$case_id" "legacy result envelope selftest ran and passed without SKIP"
  end_case "$case_id"

  case_id="RB-CANARY-ADDITIVE-MIRROR-OLDER-READERS"
  begin_case "$case_id" "Legacy snapshot and compactor readers ignore an additive repositoryBindingMirror while preserving unrelated state."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/canary-repo")"
  packet_file="$CASE_DIR/actionable-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "canary-repo" || \
    fatal_fixture "$case_id" "cannot write canary binding packet"
  mkdir -p "$repo_a/.specify/memory" || fatal_fixture "$case_id" "cannot create canary session directory"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  jq -n --slurpfile binding "$packet_file" '{
    legacyField: "preserve-me",
    turnSnapshots: [{turnNumber: 1, phase: "legacy", mode: "start"}],
    compactedHistory: [{agent: "bubbles.plan", outcome: "completed_owned"}],
    repositoryBindingMirror: ($binding[0] + {
      mirroredControlRevision: 1,
      mirroredAt: "2026-01-01T00:00:00Z"
    })
  }' >"$session_file" || fatal_fixture "$case_id" "cannot seed additive mirror fixture"
  mirror_before="$(jq -c '.repositoryBindingMirror' "$session_file")"
  history_before="$(jq -c '.compactedHistory' "$session_file")"

  invoke_real_script "$case_id" "legacy unrelated snapshot ignores additive mirror" \
    "$repo_a" "$STATE_SNAPSHOT" --phase canary_unrelated --mode end
  assert_rc_zero "$case_id" "legacy unrelated state snapshot still appends normally"
  assert_json_scalar "$case_id" "legacy unrelated field survives snapshot append" \
    "$session_file" '.legacyField' "preserve-me"
  assert_json_scalar "$case_id" "legacy turnSnapshots behavior appends one record" \
    "$session_file" '.turnSnapshots | length' "2"
  assert_json_compact "$case_id" "additive repositoryBindingMirror is ignored and preserved byte-for-JSON" \
    "$session_file" '.repositoryBindingMirror' "$mirror_before"
  assert_json_compact "$case_id" "existing compactedHistory survives legacy snapshot append" \
    "$session_file" '.compactedHistory' "$history_before"

  raw_file="$CASE_DIR/legacy-result.md"
  printf '%s\n' \
    'agent: bubbles.test' \
    'outcome: completed_owned' \
    'featureDir: improvements/IMP-103-session-repository-affinity.md' \
    'evidenceRefs:' \
    '- canary-evidence' >"$raw_file"
  invoke_real_script "$case_id" "legacy compactor ignores additive session mirror" \
    "$repo_a" "$CONTEXT_COMPACTOR" "$raw_file"
  assert_rc_zero "$case_id" "legacy context compactor still emits a compact record"
  assert_contains "$case_id" "legacy compact record still carries agent" '"agent":"bubbles.test"'
  assert_contains "$case_id" "legacy compact record still carries outcome" '"outcome":"completed_owned"'
  assert_json_compact "$case_id" "legacy compactor leaves additive repositoryBindingMirror unchanged" \
    "$session_file" '.repositoryBindingMirror' "$mirror_before"
  end_case "$case_id"

  finish_named_suite "shared-infrastructure-canary"
}

run_state_propagation_suite() {
  local case_id=""
  local repo_a=""
  local repo_b=""
  local packet_file=""
  local stale_packet=""
  local substituted_packet=""
  local redacted_packet=""
  local leaky_redacted_packet=""
  local other_packet=""
  local session_file=""
  local session_baseline=""
  local raw_file=""
  local result_repo=""
  local result_agent=""
  local prior_turns=""
  local prior_history=""
  local variant=""
  local variant_file=""

  echo "=== IMP-103 S2 repository-binding state propagation selftest ==="
  echo "SUITE state-propagation"
  echo "PRODUCTION resolver=$RESOLVER snapshot=$STATE_SNAPSHOT compactor=$CONTEXT_COMPACTOR resultValidator=$RESULT_VALIDATOR"

  case_id="RB-PROPAGATION-SHARED-INFRASTRUCTURE-CANARY"
  begin_case "$case_id" "The independent shared-infrastructure canary executes before propagation assertions."
  invoke_real_script "$case_id" "shared infrastructure canary executes first" \
    "$WORKSPACE_DIR" "$SCRIPT_DIR/repository-binding-selftest.sh" \
    --suite=shared-infrastructure-canary
  assert_real_selftest_green "$case_id" "shared-infrastructure canary ran and passed before propagation"
  end_case "$case_id"

  case_id="RB-PROPAGATION-MIRROR-ABSENT-ACTIONABLE-ONLY"
  begin_case "$case_id" "An absent mirror is created only after an exact current actionable packet validates."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
  packet_file="$CASE_DIR/current-packet.json"
  redacted_packet="$CASE_DIR/redacted-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  jq '.repositoryRoot = "<redacted-local-root>"
      | .repositoryResolution.pathVisibility = "redacted"
      | .repositoryResolution.actionable = false' \
    "$packet_file" >"$redacted_packet" || fatal_fixture "$case_id" "cannot write redacted packet"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  invoke_binding "$case_id" "redacted packet cannot create a repository-local mirror" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$redacted_packet"
  assert_rc_nonzero "$case_id" "redacted packet is refused before mirror creation"
  assert_file_absent "$case_id" "refused redacted packet leaves mirror file absent" "$session_file"
  invoke_binding "$case_id" "exact current actionable packet validates before mirroring" \
    "$WORKSPACE_DIR" validate-packet --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "exact current actionable packet validates"
  invoke_binding "$case_id" "validated current packet creates the absent mirror" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "validated current packet creates mirror"
  assert_file_exists "$case_id" "mirror file exists only after current packet validation" "$session_file"
  assert_json_scalar "$case_id" "created mirror names selected canonical root" \
    "$session_file" '.repositoryBindingMirror.repositoryRoot' "$repo_a"
  assert_json_scalar "$case_id" "created mirror records current control revision" \
    "$session_file" '.repositoryBindingMirror.mirroredControlRevision' "1"
  end_case "$case_id"

  case_id="RB-PROPAGATION-MIRROR-UPDATE-PRESERVES-STATE"
  begin_case "$case_id" "An old mirror updates from control while unrelated fields and append-only arrays remain intact."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
  packet_file="$CASE_DIR/current-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  mkdir -p "$repo_a/.specify/memory" || fatal_fixture "$case_id" "cannot create session directory"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  jq -n --arg root "$repo_a" --arg session "$SESSION_ID" '{
    unrelated: {keep: true, label: "independent-seed"},
    turnSnapshots: [{turnNumber: 7, phase: "prior", mode: "end"}],
    compactedHistory: [{agent: "bubbles.plan", outcome: "completed_owned"}],
    repositoryBindingMirror: {
      repositoryRoot: $root,
      repositoryAlias: "selected-repo",
      repositoryResolution: {
        sessionId: $session,
        decisionId: ("rb:" + $session + ":0"),
        controlRevision: 0,
        authority: "durable-work-boundary",
        transition: "continued",
        scopeKind: "command",
        scopeId: null,
        targetKind: "inherited-boundary",
        pathVisibility: "local",
        actionable: true
      },
      mirroredControlRevision: 0,
      mirroredAt: "2026-01-01T00:00:00Z"
    }
  }' >"$session_file" || fatal_fixture "$case_id" "cannot seed old mirror"
  prior_turns="$(jq -c '.turnSnapshots' "$session_file")"
  prior_history="$(jq -c '.compactedHistory' "$session_file")"
  invoke_binding "$case_id" "current control decision repairs an older same-root mirror" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "old mirror is repaired from exact current control"
  assert_json_scalar "$case_id" "unrelated nested session field is preserved" \
    "$session_file" '.unrelated.label' "independent-seed"
  assert_json_compact "$case_id" "turnSnapshots array is preserved exactly" \
    "$session_file" '.turnSnapshots' "$prior_turns"
  assert_json_compact "$case_id" "compactedHistory array is preserved exactly" \
    "$session_file" '.compactedHistory' "$prior_history"
  assert_json_scalar "$case_id" "mirror advances to current revision" \
    "$session_file" '.repositoryBindingMirror.mirroredControlRevision' "1"
  end_case "$case_id"

  case_id="RB-PROPAGATION-MIRROR-OTHER-SESSION-CONTROL-WINS"
  begin_case "$case_id" "An other-session mirror is never authority and is replaced only by the current external control decision."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/other-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  packet_file="$CASE_DIR/current-packet.json"
  other_packet="$CASE_DIR/other-session-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  write_actionable_packet "$other_packet" "other-$SESSION_ID" 1 "$repo_b" "other-repo" || \
    fatal_fixture "$case_id" "cannot write other-session packet"
  mkdir -p "$repo_a/.specify/memory" || fatal_fixture "$case_id" "cannot create session directory"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  jq -n --slurpfile binding "$other_packet" '{
    unrelated: "keep-other-session-seed",
    repositoryBindingMirror: ($binding[0] + {
      mirroredControlRevision: 1,
      mirroredAt: "2026-01-01T00:00:00Z"
    })
  }' >"$session_file" || fatal_fixture "$case_id" "cannot seed other-session mirror"
  session_baseline="$CASE_DIR/other-session-baseline.json"
  cp "$session_file" "$session_baseline" || fatal_fixture "$case_id" "cannot copy other-session baseline"
  invoke_binding "$case_id" "other-session packet cannot use its mirror as authority" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$other_packet"
  assert_rc_nonzero "$case_id" "other-session packet is refused against current external control"
  assert_files_equal "$case_id" "other-session refusal does not mutate the mirror" \
    "$session_baseline" "$session_file"
  invoke_binding "$case_id" "current external decision replaces the other-session mirror" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "current external decision repairs other-session mirror"
  assert_json_scalar "$case_id" "repaired mirror carries current session" \
    "$session_file" '.repositoryBindingMirror.repositoryResolution.sessionId' "$SESSION_ID"
  assert_json_scalar "$case_id" "repaired mirror carries control-selected root" \
    "$session_file" '.repositoryBindingMirror.repositoryRoot' "$repo_a"
  assert_json_scalar "$case_id" "unrelated state survives other-session repair" \
    "$session_file" '.unrelated' "keep-other-session-seed"
  assert_control "$case_id" "$repo_a" "1"
  end_case "$case_id"

  case_id="RB-PROPAGATION-MIRROR-SAME-SESSION-DRIFT"
  begin_case "$case_id" "A same-session mirror naming another root is reported and repaired from control without overriding it."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/drift-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  packet_file="$CASE_DIR/current-packet.json"
  substituted_packet="$CASE_DIR/drift-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  write_actionable_packet "$substituted_packet" "$SESSION_ID" 1 "$repo_b" "drift-repo" || \
    fatal_fixture "$case_id" "cannot write drift packet"
  mkdir -p "$repo_a/.specify/memory" || fatal_fixture "$case_id" "cannot create session directory"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  jq -n --slurpfile binding "$substituted_packet" '{
    unrelated: "keep-same-session-seed",
    repositoryBindingMirror: ($binding[0] + {
      mirroredControlRevision: 1,
      mirroredAt: "2026-01-01T00:00:00Z"
    })
  }' >"$session_file" || fatal_fixture "$case_id" "cannot seed same-session drift mirror"
  invoke_binding "$case_id" "control reports and repairs same-session mirror root drift" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "same-session drift is repaired from control"
  assert_output_regex "$case_id" "same-session root mismatch is reported as drift" \
    'REPOSITORY MIRROR DRIFT authority=external-control repair=overwrite'
  assert_json_scalar "$case_id" "drift repair restores control-selected root" \
    "$session_file" '.repositoryBindingMirror.repositoryRoot' "$repo_a"
  assert_json_scalar "$case_id" "drift repair preserves unrelated session state" \
    "$session_file" '.unrelated' "keep-same-session-seed"
  assert_control "$case_id" "$repo_a" "1"
  end_case "$case_id"

  case_id="RB-PROPAGATION-STATE-SNAPSHOT-BINDING-REQUIRED"
  begin_case "$case_id" "Repository-sensitive snapshots require all binding inputs, validate the exact packet, and preserve normal snapshot behavior."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
  packet_file="$CASE_DIR/current-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  mkdir -p "$repo_a/.specify/memory" || fatal_fixture "$case_id" "cannot create session directory"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  jq -n '{
    unrelated: {keep: "snapshot-seed"},
    turnSnapshots: [{turnNumber: 1, phase: "prior", mode: "start"}],
    compactedHistory: [{agent: "bubbles.plan", outcome: "completed_owned"}]
  }' >"$session_file" || fatal_fixture "$case_id" "cannot seed snapshot session"
  session_baseline="$CASE_DIR/snapshot-baseline.json"
  cp "$session_file" "$session_baseline" || fatal_fixture "$case_id" "cannot copy snapshot baseline"
  prior_history="$(jq -c '.compactedHistory' "$session_file")"

  invoke_real_script "$case_id" "snapshot refuses missing session id" "$repo_a" "$STATE_SNAPSHOT" \
    --session-control-file "$CONTROL_FILE" --binding-packet-file "$packet_file" \
    --phase repository_sensitive --scope-id S2
  assert_rc_nonzero "$case_id" "repository-sensitive snapshot refuses missing --session-id"
  assert_output_regex "$case_id" "missing session id reports the required argument" \
    'session-id.*required|requires.*session-id'
  assert_files_equal "$case_id" "missing session id refuses before session write" \
    "$session_baseline" "$session_file"

  cp "$session_baseline" "$session_file" || fatal_fixture "$case_id" "cannot restore snapshot baseline"
  invoke_real_script "$case_id" "snapshot refuses missing session control file" "$repo_a" "$STATE_SNAPSHOT" \
    --session-id "$SESSION_ID" --binding-packet-file "$packet_file" \
    --phase repository_sensitive --scope-id S2
  assert_rc_nonzero "$case_id" "repository-sensitive snapshot refuses missing --session-control-file"
  assert_output_regex "$case_id" "missing control file reports the required argument" \
    'session-control-file.*required|requires.*session-control-file'
  assert_files_equal "$case_id" "missing control file refuses before session write" \
    "$session_baseline" "$session_file"

  cp "$session_baseline" "$session_file" || fatal_fixture "$case_id" "cannot restore snapshot baseline"
  invoke_real_script "$case_id" "snapshot refuses missing binding packet file" "$repo_a" "$STATE_SNAPSHOT" \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
    --phase repository_sensitive --scope-id S2
  assert_rc_nonzero "$case_id" "repository-sensitive snapshot refuses missing --binding-packet-file"
  assert_output_regex "$case_id" "missing binding packet reports the required argument" \
    'binding-packet-file.*required|requires.*binding-packet-file'
  assert_files_equal "$case_id" "missing binding packet refuses before session write" \
    "$session_baseline" "$session_file"

  cp "$session_baseline" "$session_file" || fatal_fixture "$case_id" "cannot restore snapshot baseline"
  invoke_real_script "$case_id" "snapshot consumes exact current actionable packet" "$repo_a" "$STATE_SNAPSHOT" \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
    --binding-packet-file "$packet_file" --phase repository_sensitive --scope-id S2 \
    --mode end --note "binding-preserving snapshot"
  assert_rc_zero "$case_id" "exact current binding permits repository-sensitive snapshot"
  assert_json_scalar "$case_id" "normal snapshot append increments turnSnapshots" \
    "$session_file" '.turnSnapshots | length' "2"
  assert_json_scalar "$case_id" "normal snapshot fields are still added" \
    "$session_file" '.turnSnapshots[1].phase' "repository_sensitive"
  assert_json_scalar "$case_id" "unrelated snapshot state is preserved" \
    "$session_file" '.unrelated.keep' "snapshot-seed"
  assert_json_compact "$case_id" "compactedHistory survives bound snapshot" \
    "$session_file" '.compactedHistory' "$prior_history"
  assert_json_scalar "$case_id" "bound snapshot creates the post-selection mirror with selected root" \
    "$session_file" '.repositoryBindingMirror.repositoryRoot' "$repo_a"
  assert_json_scalar "$case_id" "bound snapshot mirror carries the current session" \
    "$session_file" '.repositoryBindingMirror.repositoryResolution.sessionId' "$SESSION_ID"
  assert_json_scalar "$case_id" "bound snapshot mirror carries the current control revision" \
    "$session_file" '.repositoryBindingMirror.repositoryResolution.controlRevision' "1"
  end_case "$case_id"

  case_id="RB-PROPAGATION-CONSUMERS-REFUSE-NONCURRENT"
  begin_case "$case_id" "Snapshot, result, and compactor consumers refuse stale, substituted, and redacted packets before writes."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/substituted-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  invoke_binding "$case_id" "second current decision creates a genuinely stale prior packet" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  assert_rc_zero "$case_id" "current control advances to revision 2"
  assert_control "$case_id" "$repo_a" "2"
  packet_file="$CASE_DIR/current-packet.json"
  stale_packet="$CASE_DIR/stale-packet.json"
  substituted_packet="$CASE_DIR/substituted-packet.json"
  redacted_packet="$CASE_DIR/redacted-packet.json"
  leaky_redacted_packet="$CASE_DIR/leaky-redacted-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 2 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  write_actionable_packet "$stale_packet" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write stale packet"
  write_actionable_packet "$substituted_packet" "$SESSION_ID" 2 "$repo_b" "substituted-repo" || \
    fatal_fixture "$case_id" "cannot write substituted packet"
  jq '.repositoryRoot = "<redacted-local-root>"
      | .repositoryResolution.pathVisibility = "redacted"
      | .repositoryResolution.actionable = false' \
    "$packet_file" >"$redacted_packet" || fatal_fixture "$case_id" "cannot write redacted packet"
  invoke_binding "$case_id" "matrix setup proves exact current packet is actionable" \
    "$WORKSPACE_DIR" validate-packet --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "matrix current packet validates exactly"

  mkdir -p "$repo_a/.specify/memory" || fatal_fixture "$case_id" "cannot create matrix session directory"
  session_file="$repo_a/.specify/memory/bubbles.session.json"
  raw_file="$CASE_DIR/current-result.md"
  write_handoff_envelope "$raw_file" "$packet_file"
  jq -n --arg raw "$raw_file" '{
    sentinel: "must-not-change",
    turnSnapshots: [{turnNumber: 1, phase: "prior", mode: "start"}],
    compactedHistory: [{agent: "bubbles.plan", outcome: "completed_owned"}],
    envelopesReceived: [{rawPointer: $raw}]
  }' >"$session_file" || fatal_fixture "$case_id" "cannot seed matrix session"
  invoke_binding "$case_id" "current matrix packet creates authoritative mirror baseline" \
    "$WORKSPACE_DIR" mirror-session --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file"
  assert_rc_zero "$case_id" "current matrix packet mirrors before consumer checks"
  session_baseline="$CASE_DIR/consumer-baseline.json"
  cp "$session_file" "$session_baseline" || fatal_fixture "$case_id" "cannot copy consumer baseline"
  result_repo="$(create_result_validator_fixture "$case_id" current-result "$packet_file")"
  result_agent="$result_repo/agents/bubbles.fixture.agent.md"

  for variant in stale substituted redacted; do
    case "$variant" in
      stale) variant_file="$stale_packet" ;;
      substituted) variant_file="$substituted_packet" ;;
      redacted) variant_file="$redacted_packet" ;;
    esac

    cp "$session_baseline" "$session_file" || fatal_fixture "$case_id" "cannot restore $variant snapshot baseline"
    invoke_real_script "$case_id" "$variant snapshot packet refuses before write" \
      "$repo_a" "$STATE_SNAPSHOT" --session-id "$SESSION_ID" \
      --session-control-file "$CONTROL_FILE" --binding-packet-file "$variant_file" \
      --phase repository_sensitive --scope-id S2
    assert_rc_nonzero "$case_id" "$variant packet is refused by snapshot consumer"
    assert_output_regex "$case_id" "$variant snapshot refusal is binding-specific" \
      'REPOSITORY PACKET REFUSED|BOUNDARY_CONFLICT|PACKET_NONACTIONABLE'
    assert_files_equal "$case_id" "$variant snapshot refusal occurs before session write" \
      "$session_baseline" "$session_file"

    cp "$session_baseline" "$session_file" || fatal_fixture "$case_id" "cannot restore $variant compactor baseline"
    invoke_real_script "$case_id" "$variant compactor packet refuses before write" \
      "$repo_a" "$CONTEXT_COMPACTOR" --session-id "$SESSION_ID" \
      --session-control-file "$CONTROL_FILE" --binding-packet-file "$variant_file" "$raw_file"
    assert_rc_nonzero "$case_id" "$variant packet is refused by compactor consumer"
    assert_output_regex "$case_id" "$variant compactor refusal is binding-specific" \
      'REPOSITORY PACKET REFUSED|BOUNDARY_CONFLICT|PACKET_NONACTIONABLE'
    assert_files_equal "$case_id" "$variant compactor refusal occurs before session write" \
      "$session_baseline" "$session_file"

    session_baseline="$CASE_DIR/result-agent-$variant.baseline"
    cp "$result_agent" "$session_baseline" || fatal_fixture "$case_id" "cannot copy $variant result baseline"
    invoke_real_script "$case_id" "$variant result packet refuses before validation side effects" \
      "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
      --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
      --binding-packet-file "$variant_file"
    assert_rc_nonzero "$case_id" "$variant packet is refused by result consumer"
    assert_output_regex "$case_id" "$variant result refusal is binding-specific" \
      'REPOSITORY PACKET REFUSED|BOUNDARY_CONFLICT|PACKET_NONACTIONABLE'
    assert_excludes "$case_id" "$variant result refusal reached binding validation, not an unknown-option path" \
      'unknown arg'
    assert_files_equal "$case_id" "$variant result refusal leaves source envelope unchanged" \
      "$session_baseline" "$result_agent"
    session_baseline="$CASE_DIR/consumer-baseline.json"
  done
  end_case "$case_id"

  case_id="RB-PROPAGATION-HANDOFF-COMPACTION"
  begin_case "$case_id" "Context compaction preserves every non-droppable repository binding field."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
  packet_file="$CASE_DIR/current-packet.json"
  raw_file="$CASE_DIR/actionable-result.md"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current packet"
  write_handoff_envelope "$raw_file" "$packet_file"
  invoke_real_script "$case_id" "actionable compaction refuses when caller omits all binding inputs" \
    "$repo_a" "$CONTEXT_COMPACTOR" "$raw_file"
  assert_rc_nonzero "$case_id" "actionable compaction requires caller-supplied current binding"
  assert_output_regex "$case_id" "unbound actionable compaction names the missing binding contract" \
    'repository binding|session-id|binding-packet-file'
  invoke_real_script "$case_id" "compactor validates and preserves actionable binding" \
    "$repo_a" "$CONTEXT_COMPACTOR" --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --binding-packet-file "$packet_file" "$raw_file"
  assert_rc_zero "$case_id" "exact current packet permits handoff compaction"
  assert_output_json_scalar "$case_id" "compaction preserves repositoryRoot" '.repositoryRoot' "$repo_a"
  assert_output_json_scalar "$case_id" "compaction preserves repositoryAlias" '.repositoryAlias' "selected-repo"
  assert_output_json_scalar "$case_id" "compaction preserves sessionId" '.sessionId' "$SESSION_ID"
  assert_output_json_scalar "$case_id" "compaction preserves decisionId" '.decisionId' "rb:$SESSION_ID:1"
  assert_output_json_scalar "$case_id" "compaction preserves controlRevision" '.controlRevision' "1"
  assert_output_json_scalar "$case_id" "compaction preserves authority" '.authority' "durable-work-boundary"
  assert_output_json_scalar "$case_id" "compaction preserves transition" '.transition' "continued"
  assert_output_json_scalar "$case_id" "compaction preserves scopeKind" '.scopeKind' "command"
  assert_output_json_scalar "$case_id" "compaction preserves scopeId" '.scopeId' "null"
  assert_output_json_scalar "$case_id" "compaction preserves targetKind" '.targetKind' "inherited-boundary"
  assert_output_json_scalar "$case_id" "compaction preserves pathVisibility" '.pathVisibility' "local"
  assert_output_json_scalar "$case_id" "compaction preserves actionable" '.actionable' "true"
  end_case "$case_id"

  case_id="RB-PROPAGATION-RESULT-ENVELOPE-PROVENANCE"
  begin_case "$case_id" "Result schema and validator accept matching local actionable provenance and reject missing, stale, substituted, or redacted provenance."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/substituted-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  invoke_binding "$case_id" "second result decision creates stale provenance fixture" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  assert_rc_zero "$case_id" "result control advances to revision 2"
  assert_control "$case_id" "$repo_a" "2"
  packet_file="$CASE_DIR/current-packet.json"
  stale_packet="$CASE_DIR/stale-packet.json"
  substituted_packet="$CASE_DIR/substituted-packet.json"
  redacted_packet="$CASE_DIR/redacted-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 2 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write result current packet"
  write_actionable_packet "$stale_packet" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write result stale packet"
  write_actionable_packet "$substituted_packet" "$SESSION_ID" 2 "$repo_b" "substituted-repo" || \
    fatal_fixture "$case_id" "cannot write result substituted packet"
  jq '.repositoryRoot = "<redacted-local-root>"
      | .repositoryResolution.pathVisibility = "redacted"
      | .repositoryResolution.actionable = false' \
    "$packet_file" >"$redacted_packet" || fatal_fixture "$case_id" "cannot write result redacted packet"
  jq --arg root "$repo_a" '.repositoryRoot = $root' \
    "$redacted_packet" >"$leaky_redacted_packet" || \
    fatal_fixture "$case_id" "cannot write leaky redacted result packet"

  result_repo="$(create_result_validator_fixture "$case_id" public-redacted "$redacted_packet")"
  invoke_real_script "$case_id" "correct public redaction remains schema-readable and non-actionable" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict
  assert_rc_zero "$case_id" "correctly redacted public result is accepted by additive schema readers"
  assert_excludes "$case_id" "correct public result validation does not skip" 'SKIP'

  result_repo="$(create_result_validator_fixture "$case_id" public-redacted-leak "$leaky_redacted_packet")"
  invoke_real_script "$case_id" "redacted public result cannot retain a canonical local root" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --advisory
  assert_rc_nonzero "$case_id" "non-actionable public result with local root is rejected"
  assert_output_regex "$case_id" "public root leak is rejected by schema" \
    'MALFORMED|Schema error|redacted-local-root'
  assert_excludes "$case_id" "public root-leak validation does not skip" 'SKIP'

  result_repo="$(create_result_validator_fixture "$case_id" matching "$packet_file")"
  invoke_real_script "$case_id" "local actionable result refuses when caller omits all binding inputs" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --advisory
  assert_rc_nonzero "$case_id" "local actionable result requires caller-supplied current binding"
  assert_output_regex "$case_id" "unbound actionable result names the missing binding contract" \
    'MALFORMED|Repository provenance error|binding.*required'
  assert_excludes "$case_id" "unbound actionable result validation does not skip" 'SKIP'
  invoke_real_script "$case_id" "matching actionable result validates" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
    --binding-packet-file "$packet_file"
  assert_rc_zero "$case_id" "matching local actionable result is accepted"
  assert_excludes "$case_id" "matching result validation actually executes" 'SKIP'

  for variant in missing stale substituted redacted; do
    case "$variant" in
      missing) variant_file="missing" ;;
      stale) variant_file="$stale_packet" ;;
      substituted) variant_file="$substituted_packet" ;;
      redacted) variant_file="$redacted_packet" ;;
    esac
    result_repo="$(create_result_validator_fixture "$case_id" "$variant" "$variant_file")"
    invoke_real_script "$case_id" "$variant repository provenance is rejected" \
      "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
      --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
      --binding-packet-file "$packet_file"
    assert_rc_nonzero "$case_id" "$variant repository provenance is rejected"
    assert_output_regex "$case_id" "$variant rejection is a schema or binding-provenance decision" \
      'MALFORMED|REPOSITORY PACKET REFUSED|BOUNDARY_CONFLICT|PACKET_NONACTIONABLE'
    assert_excludes "$case_id" "$variant rejection reached provenance validation, not unknown-option handling" \
      'unknown arg'
    assert_excludes "$case_id" "$variant result validation does not skip" 'SKIP'
  done
  end_case "$case_id"

  finish_named_suite "state-propagation"
}

run_classification_discovery_suite() {
  local case_id=""
  local repo_a=""
  local repo_b=""
  local repo_c=""
  local sentinel_a=""
  local sentinel_b=""
  local sentinel_c=""
  local packet_file=""
  local stale_packet=""
  local substituted_packet=""
  local preflight_output=""
  local discovery_output=""
  local delegation_section=""
  local literal_gate_section=""
  local stochastic_section=""
  local iterate_section=""
  local sweep_pool_section=""
  local variant=""
  local variant_file=""
  local stale_revision=""

  echo "=== IMP-103 S3 classification and repository-scoped discovery selftest ==="
  echo "SUITE classification-discovery"
  echo "PRODUCTION resolver=$RESOLVER classifierContract=$DELEGATION_CORE modeRegistry=$MODE_REGISTRY"

  delegation_section="$(markdown_section "$DELEGATION_CORE" "### Input Classification Contract")"
  literal_gate_section="$(markdown_section "$DELEGATION_CORE" "### ⛔ Literal \`mode:\` Gate (MANDATORY — NON-NEGOTIABLE)")"

  case_id="RB-CLASSIFICATION-MODE-CONCRETE-TARGET"
  begin_case "$case_id" "Literal mode plus one concrete spec target is STRUCTURED and concrete target authority binds its repository."
  assert_text_contains "$case_id" "active classifier retains STRUCTURED" \
    "$delegation_section" '`STRUCTURED`'
  assert_text_contains "$case_id" "STRUCTURED requires an explicit mode token" \
    "$delegation_section" 'explicit `mode:` keyword'
  assert_text_contains "$case_id" "STRUCTURED requires concrete spec targets" \
    "$delegation_section" 'WITH concrete spec targets'
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
  sentinel_a="$(add_sentinel_spec "$case_id" "$repo_a" "901-prior-work-sentinel")"
  sentinel_b="$(add_sentinel_spec "$case_id" "$repo_b" "902-chat-cwd-sentinel")"
  invoke_binding "$case_id" "concrete target supplies STRUCTURED repository authority" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class STRUCTURED \
    --workspace-root "$repo_a" --workspace-root "$repo_b" \
    --target "specs/$(basename "$sentinel_b")"
  assert_rc_zero "$case_id" "STRUCTURED concrete-target preflight succeeds"
  assert_contains "$case_id" "concrete target selects its repository" "root=$repo_b"
  assert_contains "$case_id" "concrete target authority is visible" "source=concrete-target"
  assert_excludes "$case_id" "other repository sentinel is not consulted" "$sentinel_a"
  assert_control "$case_id" "$repo_b" 1
  end_case "$case_id"

  case_id="RB-CLASSIFICATION-MODE-ROOT-TARGETLESS"
  begin_case "$case_id" "Literal mode plus repositoryRoot but no concrete work target is TARGETLESS_MODE."
  assert_text_regex "$case_id" "active classifier names mode plus repositoryRoot as TARGETLESS_MODE" \
    "$delegation_section" '(`mode:`.*repositoryRoot.*`TARGETLESS_MODE`|`TARGETLESS_MODE`.*repositoryRoot)'
  assert_text_excludes "$case_id" "active classifier never treats repositoryRoot alone as a concrete work target" \
    "$delegation_section" 'repositoryRoot alone is `STRUCTURED`'
  end_case "$case_id"

  case_id="RB-CLASSIFICATION-MODE-ONLY-TARGETLESS"
  begin_case "$case_id" "Literal mode without a concrete target is TARGETLESS_MODE and never STRUCTURED."
  assert_text_regex "$case_id" "active classifier defines mode-only TARGETLESS_MODE" \
    "$delegation_section" '(`mode:`.*without concrete.*`TARGETLESS_MODE`|`TARGETLESS_MODE`.*mode-only)'
  assert_text_excludes "$case_id" "active classifier does not describe mode-only input as STRUCTURED" \
    "$delegation_section" '`STRUCTURED` — explicit `mode:` keyword is present.'
  end_case "$case_id"

  case_id="RB-CLASSIFICATION-NO-MODE-PRESERVES-DELEGATION"
  begin_case "$case_id" "No-mode VAGUE and CONTINUATION semantics remain after repository preflight."
  assert_text_contains "$case_id" "active classifier retains CONTINUATION" \
    "$delegation_section" '`CONTINUATION`'
  assert_text_contains "$case_id" "active classifier retains VAGUE" \
    "$delegation_section" '`VAGUE`'
  assert_text_contains "$case_id" "literal mode gate preserves no-mode continuation handling" \
    "$literal_gate_section" 'CONTINUATION'
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
  sentinel_b="$(add_sentinel_spec "$case_id" "$repo_b" "902-chat-cwd-sentinel")"
  invoke_binding "$case_id" "VAGUE concrete target preflights before intent resolution" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class VAGUE \
    --workspace-root "$repo_a" --workspace-root "$repo_b" \
    --target "specs/$(basename "$sentinel_b")"
  assert_rc_zero "$case_id" "VAGUE targeted request binds before repository-local resolution"
  assert_contains "$case_id" "VAGUE target selects the target repository" "root=$repo_b"
  invoke_binding "$case_id" "CONTINUATION reuses the committed boundary before local reads" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class CONTINUATION \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  assert_rc_zero "$case_id" "CONTINUATION preflight succeeds"
  assert_contains "$case_id" "CONTINUATION preserves the active repository" "root=$repo_b"
  assert_contains "$case_id" "CONTINUATION reports durable-boundary continuation" "affinity=continued"
  assert_control "$case_id" "$repo_b" 2
  end_case "$case_id"

  case_id="RB-INCIDENT-80331F88-BOUNDARY"
  begin_case "$case_id" "A persisted Smackerel-role boundary outranks QF chat CWD and EmailAnalyzer host metadata for targetless stochastic discovery."
  SESSION_ID="80331f88-4cab-4248-964c-2837994bb35b"
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
  repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
  sentinel_a="$(add_sentinel_spec "$case_id" "$repo_a" "901-prior-work-sentinel")"
  sentinel_b="$(add_sentinel_spec "$case_id" "$repo_b" "902-chat-cwd-sentinel")"
  sentinel_c="$(add_sentinel_spec "$case_id" "$repo_c" "903-host-metadata-sentinel")"
  invoke_binding "$case_id" "prior targeted work establishes Smackerel-role affinity" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class STRUCTURED \
    --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c" \
    --repository-root "$repo_a"
  assert_rc_zero "$case_id" "prior targeted work establishes the role boundary"
  DIAGNOSTIC_CHAT_CWD="$repo_b"
  DIAGNOSTIC_HOST_REPOSITORY="$repo_c"
  DIAGNOSTIC_ACTIVE_EDITOR="$repo_b/specs/902-chat-cwd-sentinel/spec.md"
  DIAGNOSTIC_TOOL_CWD="$repo_b"
  invoke_binding "$case_id" "targetless stochastic preflight continues the durable role boundary" \
    "$repo_b" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
  assert_rc_zero "$case_id" "targetless multi-root preflight continues the valid boundary"
  assert_contains "$case_id" "continued boundary is the Smackerel-role root" "root=$repo_a"
  assert_contains "$case_id" "continued boundary reports session authority" "source=session-work-boundary"
  assert_contains "$case_id" "continued boundary reports continued affinity" "affinity=continued"
  assert_excludes "$case_id" "QF-role diagnostic root does not become selected" "root=$repo_b"
  assert_excludes "$case_id" "EmailAnalyzer-role diagnostic root does not become selected" "root=$repo_c"
  assert_control "$case_id" "$repo_a" 2
  preflight_output="$LAST_OUTPUT"
  packet_file="$CASE_DIR/actionable-packet.json"
  capture_packet_from_last_output "$packet_file" || \
    fatal_fixture "$case_id" "cannot capture continued actionable packet"
  invoke_binding "$case_id" "stochastic discovery consumes the current Smackerel-role decision" \
    "$repo_b" discover-specs --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file" \
    --mode stochastic-quality-sweep
  assert_rc_zero "$case_id" "stochastic discover-specs accepts the current decision"
  assert_contains "$case_id" "discovery scope is exactly the Smackerel-role specs root" \
    "DISCOVERY SCOPE mode=stochastic-quality-sweep root=$repo_a/specs"
  assert_contains "$case_id" "Smackerel-role sentinel is discovered" "$sentinel_a"
  assert_excludes "$case_id" "QF-role sentinel is never discovered" "$sentinel_b"
  assert_excludes "$case_id" "EmailAnalyzer-role sentinel is never discovered" "$sentinel_c"
  discovery_output="$LAST_OUTPUT"
  LAST_OUTPUT="$preflight_output"$'\n'"$discovery_output"
  assert_output_order "$case_id" "preflight success precedes discovery scope and first repository read" \
    "REPOSITORY PREFLIGHT BOUND" "DISCOVERY SCOPE" "$sentinel_a"
  reset_diagnostics
  end_case "$case_id"

  case_id="RB-INCIDENT-80331F88-UNBOUND-REFUSAL"
  begin_case "$case_id" "The same three candidates without a boundary refuse before every sentinel or discovery event."
  SESSION_ID="80331f88-4cab-4248-964c-2837994bb35b-unbound"
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
  repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
  sentinel_a="$(add_sentinel_spec "$case_id" "$repo_a" "901-prior-work-sentinel")"
  sentinel_b="$(add_sentinel_spec "$case_id" "$repo_b" "902-chat-cwd-sentinel")"
  sentinel_c="$(add_sentinel_spec "$case_id" "$repo_c" "903-host-metadata-sentinel")"
  DIAGNOSTIC_CHAT_CWD="$repo_b"
  DIAGNOSTIC_HOST_REPOSITORY="$repo_c"
  DIAGNOSTIC_ACTIVE_EDITOR="$repo_b/specs/902-chat-cwd-sentinel/spec.md"
  DIAGNOSTIC_TOOL_CWD="$repo_b"
  invoke_binding "$case_id" "targetless multi-root request has no authority" \
    "$repo_b" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
  assert_rc_nonzero "$case_id" "unbound targetless multi-root request refuses"
  assert_contains "$case_id" "refusal names the stable unbound reason" "TARGETLESS_MULTI_ROOT_UNBOUND"
  assert_contains "$case_id" "refusal reports zero repository-local side effects" "repoLocalSideEffects: zero"
  assert_excludes "$case_id" "refusal emits no discovery scope" "DISCOVERY SCOPE"
  assert_excludes "$case_id" "refusal emits no Smackerel-role sentinel" "$sentinel_a"
  assert_excludes "$case_id" "refusal emits no QF-role sentinel" "$sentinel_b"
  assert_excludes "$case_id" "refusal emits no EmailAnalyzer-role sentinel" "$sentinel_c"
  assert_no_control "$case_id"
  reset_diagnostics
  end_case "$case_id"

  case_id="RB-EXPLICIT-REPOSITORY-ROOT-QF"
  begin_case "$case_id" "Explicit QF-role repositoryRoot commits before targetless iterate discovery and scopes the pool to QF only."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
  repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/host-metadata-repo")"
  sentinel_a="$(add_sentinel_spec "$case_id" "$repo_a" "901-prior-work-sentinel")"
  sentinel_b="$(add_sentinel_spec "$case_id" "$repo_b" "902-chat-cwd-sentinel")"
  sentinel_c="$(add_sentinel_spec "$case_id" "$repo_c" "903-host-metadata-sentinel")"
  invoke_binding "$case_id" "explicit repositoryRoot binds before targetless iterate discovery" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c" \
    --repository-root "$repo_b"
  assert_rc_zero "$case_id" "explicit QF-role repositoryRoot preflight succeeds"
  assert_contains "$case_id" "explicit root reports QF-role selection" "root=$repo_b"
  assert_contains "$case_id" "explicit root authority is visible" "source=explicit-repositoryRoot"
  assert_control "$case_id" "$repo_b" 1
  preflight_output="$LAST_OUTPUT"
  packet_file="$CASE_DIR/actionable-packet.json"
  capture_packet_from_last_output "$packet_file" || \
    fatal_fixture "$case_id" "cannot capture explicit-root actionable packet"
  invoke_binding "$case_id" "iterate discovery consumes the explicit QF-role decision" \
    "$WORKSPACE_DIR" discover-specs --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file" --mode iterate
  assert_rc_zero "$case_id" "iterate discover-specs accepts the current QF-role decision"
  assert_contains "$case_id" "iterate discovery scope is exactly the QF-role specs root" \
    "DISCOVERY SCOPE mode=iterate root=$repo_b/specs"
  assert_contains "$case_id" "QF-role sentinel is discovered" "$sentinel_b"
  assert_excludes "$case_id" "Smackerel-role sentinel is excluded" "$sentinel_a"
  assert_excludes "$case_id" "EmailAnalyzer-role sentinel is excluded" "$sentinel_c"
  discovery_output="$LAST_OUTPUT"
  LAST_OUTPUT="$preflight_output"$'\n'"$discovery_output"
  assert_output_order "$case_id" "explicit-root commit precedes iterate discovery and repository read" \
    "REPOSITORY PREFLIGHT BOUND" "DISCOVERY SCOPE" "$sentinel_b"
  end_case "$case_id"

  case_id="RB-DISCOVERY-REFUSES-NONCURRENT-DECISIONS"
  begin_case "$case_id" "Stale and root-substituted decisions cannot cross discover-specs validation or emit discovery events."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/prior-work-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/chat-cwd-repo")"
  sentinel_a="$(add_sentinel_spec "$case_id" "$repo_a" "901-prior-work-sentinel")"
  sentinel_b="$(add_sentinel_spec "$case_id" "$repo_b" "902-chat-cwd-sentinel")"
  invoke_binding "$case_id" "establish current discovery decision" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b" --repository-root "$repo_b"
  assert_rc_zero "$case_id" "current decision setup succeeds"
  packet_file="$CASE_DIR/actionable-packet.json"
  capture_packet_from_last_output "$packet_file" || \
    fatal_fixture "$case_id" "cannot capture current discovery packet"
  stale_packet="$CASE_DIR/stale-packet.json"
  stale_revision="$(( $(jq -r '.repositoryResolution.controlRevision' "$packet_file") + 1 ))"
  jq --argjson revision "$stale_revision" \
    --arg decision "rb:$SESSION_ID:$stale_revision" \
    '.repositoryResolution.controlRevision = $revision | .repositoryResolution.decisionId = $decision' \
    "$packet_file" >"$stale_packet" || fatal_fixture "$case_id" "cannot write stale packet"
  substituted_packet="$CASE_DIR/substituted-packet.json"
  jq --arg root "$repo_a" --arg alias "prior-work-repo" \
    '.repositoryRoot = $root | .repositoryAlias = $alias' \
    "$packet_file" >"$substituted_packet" || fatal_fixture "$case_id" "cannot write substituted packet"
  for variant in stale substituted; do
    case "$variant" in
      stale) variant_file="$stale_packet" ;;
      substituted) variant_file="$substituted_packet" ;;
    esac
    invoke_binding "$case_id" "$variant decision must not reach repository enumeration" \
      "$WORKSPACE_DIR" discover-specs --session-id "$SESSION_ID" \
      --session-control-file "$CONTROL_FILE" --packet-file "$variant_file" \
      --mode stochastic-quality-sweep
    assert_rc_nonzero "$case_id" "$variant decision is rejected"
    assert_contains "$case_id" "$variant decision fails as a binding conflict" "BOUNDARY_CONFLICT"
    assert_excludes "$case_id" "$variant decision emits no discovery scope" "DISCOVERY SCOPE"
    assert_excludes "$case_id" "$variant decision emits no selected-root sentinel" "$sentinel_b"
    assert_excludes "$case_id" "$variant decision emits no substituted-root sentinel" "$sentinel_a"
  done
  end_case "$case_id"

  case_id="RB-REGISTRY-ROOT-SCOPED-AUTO-DISCOVERY"
  begin_case "$case_id" "Stochastic and iterate registry contracts require preflight and resolvedRepositoryRoot/specs; active loop text cannot execute raw specs discovery."
  stochastic_section="$(yaml_mode_section "$MODE_REGISTRY" "stochastic-quality-sweep")"
  iterate_section="$(yaml_mode_section "$MODE_REGISTRY" "iterate")"
  sweep_pool_section="$(markdown_section "$EXECUTION_LOOPS" "#### Step 0: Pool Resolution")"
  assert_text_contains "$case_id" "stochastic registry requires repository preflight" \
    "$stochastic_section" 'repositoryPreflightRequired: true'
  assert_text_contains "$case_id" "stochastic registry scopes discovery to resolved root" \
    "$stochastic_section" 'discoveryScope: resolvedRepositoryRoot/specs'
  assert_text_contains "$case_id" "iterate registry requires repository preflight" \
    "$iterate_section" 'repositoryPreflightRequired: true'
  assert_text_contains "$case_id" "iterate registry scopes discovery to resolved root" \
    "$iterate_section" 'discoveryScope: resolvedRepositoryRoot/specs'
  assert_text_contains "$case_id" "active sweep pool calls production discover-specs" \
    "$sweep_pool_section" 'repository-binding.sh discover-specs'
  assert_text_contains "$case_id" "active sweep pool names resolvedRepositoryRoot/specs" \
    "$sweep_pool_section" 'resolvedRepositoryRoot/specs'
  assert_text_excludes "$case_id" "active sweep pool has no raw executable specs root" \
    "$sweep_pool_section" 'under `specs/`'
  end_case "$case_id"

  finish_named_suite "classification-discovery"
}

run_front_doors_goal_nodes_suite() {
  local case_id=""
  local workflow_execution=""
  local iterate_execution=""
  local iterate_vague=""
  local iterate_work=""
  local super_resolution=""
  local dispatch_section=""
  local result_skill_binding=""
  local recap_behavior=""
  local recap_continuation=""
  local status_context=""
  local status_continuation=""
  local handoff_prompt=""
  local common_continuation=""
  local repo_a=""
  local repo_b=""
  local packet_file=""
  local stale_packet=""
  local substituted_packet=""
  local redacted_packet=""
  local projected_packet=""
  local result_repo=""
  local variant=""
  local variant_file=""
  local runners=""
  local runner=""
  local runner_file=""
  local runner_contract=""
  local runner_count=0
  local unported_count=0
  local unported=""
  local contract_valid=0

  echo "=== IMP-103 S4 front-door, packet, and scoped goal-node selftest ==="
  echo "SUITE front-doors-goal-nodes"
  echo "PRODUCTION resolver=$RESOLVER resultValidator=$RESULT_VALIDATOR scenarioLint=$SCENARIO_LINT"

  case_id="RB-FRONTDOOR-WORKFLOW-PREFLIGHT-DISCOVERY"
  begin_case "$case_id" "The workflow front door commits repository preflight before Phase 0 state/spec work and uses discover-specs for a targetless sweep."
  workflow_execution="$(markdown_subtree "$WORKFLOW_AGENT" "## Execution Model")"
  assert_text_contains "$case_id" "active workflow execution calls repository preflight" \
    "$workflow_execution" 'repository-binding.sh preflight'
  assert_text_contains "$case_id" "active workflow execution requires the committed anchor" \
    "$workflow_execution" 'PREFLIGHT_COMMITTED'
  assert_text_before "$case_id" "workflow preflight precedes Phase 0 repository-local input resolution" \
    "$workflow_execution" 'repository-binding.sh preflight' '### Phase 0: Resolve Inputs'
  assert_text_before "$case_id" "workflow commit anchor precedes the first state.json read" \
    "$workflow_execution" 'PREFLIGHT_COMMITTED' 'state.json'
  assert_text_contains "$case_id" "targetless sweep invokes the production discover-specs helper" \
    "$workflow_execution" 'repository-binding.sh discover-specs'
  assert_text_before "$case_id" "workflow commit anchor precedes targetless discovery" \
    "$workflow_execution" 'PREFLIGHT_COMMITTED' 'repository-binding.sh discover-specs'
  end_case "$case_id"

  case_id="RB-FRONTDOOR-ITERATE-WORK-ENVELOPE"
  begin_case "$case_id" "Iterate preflights before work discovery, never sends an ambient specs listing, and returns the exact actionable decision in WORK-ENVELOPE."
  iterate_execution="$(markdown_subtree "$ITERATE_AGENT" "## Execution Flow")"
  iterate_vague="$(markdown_section "$ITERATE_AGENT" '### Vague Intent Delegation to `bubbles.super` (MANDATORY)')"
  iterate_work="$(markdown_subtree "$ITERATE_AGENT" "## WORK-ENVELOPE")"
  assert_text_contains "$case_id" "active iterate flow calls repository preflight" \
    "$iterate_execution" 'repository-binding.sh preflight'
  assert_text_before "$case_id" "iterate preflight precedes work identification" \
    "$iterate_execution" 'PREFLIGHT_COMMITTED' '### Phase 1: Work Identification & Mode Selection'
  assert_text_excludes "$case_id" "iterate never sends a pre-binding cross-repository specs listing to super" \
    "$iterate_vague" 'Available specs: {specs/ listing}'
  assert_text_contains "$case_id" "iterate sends only repository candidate descriptors before binding" \
    "$iterate_vague" 'candidate descriptors'
  assert_binding_field_contract "$case_id" "WORK-ENVELOPE carries the complete repository binding field set" \
    "$iterate_work"
  assert_text_contains "$case_id" "WORK-ENVELOPE requires real packet validation before work selection" \
    "$iterate_work" 'validate-packet'
  assert_text_contains "$case_id" "WORK-ENVELOPE preserves the consumed binding unchanged" \
    "$iterate_work" 'unchanged'
  end_case "$case_id"

  case_id="RB-FRONTDOOR-SUPER-RESOLUTION-ENVELOPE"
  begin_case "$case_id" "Super receives raw intent plus candidate descriptors, binds one canonical root before selected-repo discovery, and emits the full decision in RESOLUTION-ENVELOPE."
  super_resolution="$(markdown_subtree "$SUPER_AGENT" "## RESOLUTION-ENVELOPE")"
  assert_text_contains "$case_id" "super runs repository-only preflight before work resolution" \
    "$super_resolution" 'repository-binding.sh preflight'
  assert_text_contains "$case_id" "super consumes candidate descriptors rather than spec listings" \
    "$super_resolution" 'candidate descriptors'
  assert_text_excludes "$case_id" "super active resolution contract has no raw cross-repository specs scan" \
    "$super_resolution" 'Scan `specs/` folders'
  assert_text_contains "$case_id" "super scopes post-binding work discovery to the selected root" \
    "$super_resolution" 'resolvedRepositoryRoot/specs'
  assert_text_before "$case_id" "super commits preflight before selected-root specs discovery" \
    "$super_resolution" 'PREFLIGHT_COMMITTED' 'resolvedRepositoryRoot/specs'
  assert_binding_field_contract "$case_id" "RESOLUTION-ENVELOPE carries the complete canonical decision" \
    "$super_resolution"
  end_case "$case_id"

  case_id="RB-DISPATCH-RESULT-EXACT-BINDING"
  begin_case "$case_id" "Specialist dispatch requires one actionable decision and RESULT-ENVELOPE echoes it byte-for-field; stale, substituted, and redacted results fail."
  dispatch_section="$(markdown_subtree "$WORKFLOW_AGENT" "### Phase 1: Per-Spec Orchestration Loop")"
  result_skill_binding="$(repository_binding_sections "$RESULT_SKILL")"
  assert_text_contains "$case_id" "workflow dispatch validates the current binding packet" \
    "$dispatch_section" 'validate-packet'
  assert_text_contains "$case_id" "workflow dispatch requires an actionable local packet" \
    "$dispatch_section" 'actionable'
  assert_text_contains "$case_id" "workflow requires specialist results to echo binding unchanged" \
    "$dispatch_section" 'unchanged'
  assert_binding_field_contract "$case_id" "result-envelope skill active binding section carries all fields" \
    "$result_skill_binding"
  assert_result_schema_exact_binding "$case_id" \
    "result schema uses the reusable binding definition or one closed exact inline field set"

  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/selected-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/substituted-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  invoke_binding "$case_id" "advance the current command decision for stale-result discrimination" \
    "$WORKSPACE_DIR" preflight --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --request-class TARGETLESS_MODE \
    --workspace-root "$repo_a" --workspace-root "$repo_b"
  assert_rc_zero "$case_id" "current command decision advances to revision 2"
  packet_file="$CASE_DIR/current-packet.json"
  stale_packet="$CASE_DIR/stale-result-packet.json"
  substituted_packet="$CASE_DIR/substituted-result-packet.json"
  redacted_packet="$CASE_DIR/redacted-result-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 2 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write current dispatch packet"
  write_actionable_packet "$stale_packet" "$SESSION_ID" 1 "$repo_a" "selected-repo" || \
    fatal_fixture "$case_id" "cannot write stale result packet"
  write_actionable_packet "$substituted_packet" "$SESSION_ID" 2 "$repo_b" "substituted-repo" || \
    fatal_fixture "$case_id" "cannot write substituted result packet"
  jq '.repositoryRoot = "<redacted-local-root>"
      | .repositoryResolution.pathVisibility = "redacted"
      | .repositoryResolution.actionable = false' \
    "$packet_file" >"$redacted_packet" || fatal_fixture "$case_id" "cannot write redacted result packet"

  result_repo="$(create_result_validator_fixture "$case_id" exact-result "$packet_file")"
  invoke_real_script "$case_id" "exact specialist result validates against the dispatch packet" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
    --binding-packet-file "$packet_file"
  assert_rc_zero "$case_id" "exact unchanged RESULT-ENVELOPE is accepted"
  assert_excludes "$case_id" "exact result validation is executed rather than skipped" 'SKIP'

  for variant in stale substituted redacted; do
    case "$variant" in
      stale) variant_file="$stale_packet" ;;
      substituted) variant_file="$substituted_packet" ;;
      redacted) variant_file="$redacted_packet" ;;
    esac
    result_repo="$(create_result_validator_fixture "$case_id" "$variant-result" "$variant_file")"
    invoke_real_script "$case_id" "$variant specialist result is compared with the original dispatch packet" \
      "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
      --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
      --binding-packet-file "$packet_file"
    assert_rc_nonzero "$case_id" "$variant RESULT-ENVELOPE is rejected"
    assert_output_regex "$case_id" "$variant result refusal is an exact schema or provenance mismatch" \
      'MALFORMED|does not match the current binding packet|does not match current packet'
    assert_excludes "$case_id" "$variant result validation does not skip" 'SKIP'
  done
  end_case "$case_id"

  case_id="RB-CONTINUATION-RECAP-STATUS-HANDOFF"
  begin_case "$case_id" "Recap, status, and handoff preflight before repo-local state, preserve exact continuation binding, and expose only non-actionable public projection."
  recap_behavior="$(markdown_subtree "$RECAP_AGENT" "## Behavior")"
  recap_continuation="$(markdown_last_heading_tail "$RECAP_AGENT" "## CONTINUATION-ENVELOPE")"
  status_context="$(markdown_subtree "$STATUS_AGENT" "## Context Loading")"
  status_continuation="$(markdown_last_heading_tail "$STATUS_AGENT" "## CONTINUATION-ENVELOPE")"
  handoff_prompt="$(markdown_subtree "$HANDOFF_AGENT" '## Step 1: The "Handoff" Prompt')"
  common_continuation="$(markdown_subtree "$AGENT_COMMON" "## Workflow-Only Continuation Convention (NON-NEGOTIABLE)")"
  assert_text_before "$case_id" "recap commits preflight before active state scans" \
    "$recap_behavior" 'PREFLIGHT_COMMITTED' 'specs/*/state.json'
  assert_text_before "$case_id" "status commits preflight before state.json loading" \
    "$status_context" 'PREFLIGHT_COMMITTED' 'state.json'
  assert_text_before "$case_id" "handoff commits preflight before collecting active files" \
    "$handoff_prompt" 'PREFLIGHT_COMMITTED' '**Active Files:**'
  assert_binding_field_contract "$case_id" "recap continuation carries the full current decision" \
    "$recap_continuation"
  assert_binding_field_contract "$case_id" "status continuation carries the full current decision" \
    "$status_continuation"
  assert_binding_field_contract "$case_id" "handoff packet carries the full current decision" \
    "$handoff_prompt"
  assert_binding_field_contract "$case_id" "agent-common continuation contract defines the shared complete decision" \
    "$common_continuation"
  assert_text_contains "$case_id" "public continuation projection redacts the canonical root" \
    "$common_continuation" '<redacted-local-root>'
  assert_text_contains "$case_id" "public continuation projection is explicitly non-actionable" \
    "$common_continuation" 'actionable: false'

  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/continuation-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
  packet_file="$CASE_DIR/current-continuation-packet.json"
  projected_packet="$CASE_DIR/public-continuation-packet.json"
  write_actionable_packet "$packet_file" "$SESSION_ID" 1 "$repo_a" "continuation-repo" || \
    fatal_fixture "$case_id" "cannot write continuation packet"
  invoke_binding "$case_id" "real resolver emits the public projection from a current decision" \
    "$WORKSPACE_DIR" validate-packet --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$packet_file" \
    --emit-redacted-projection
  assert_rc_zero "$case_id" "current local continuation can produce a public projection"
  capture_packet_from_last_output "$projected_packet" || \
    fatal_fixture "$case_id" "cannot capture public continuation projection"
  assert_json_scalar "$case_id" "public projection redacts repositoryRoot" \
    "$projected_packet" '.repositoryRoot' '<redacted-local-root>'
  assert_json_scalar "$case_id" "public projection is not actionable" \
    "$projected_packet" '.repositoryResolution.actionable' 'false'
  invoke_binding "$case_id" "public projection cannot resume repository work" \
    "$WORKSPACE_DIR" validate-packet --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$projected_packet"
  assert_rc_nonzero "$case_id" "redacted continuation is refused for resume"
  assert_contains "$case_id" "redacted continuation refusal is explicitly non-actionable" \
    'PACKET_NONACTIONABLE'
  end_case "$case_id"

  case_id="RB-DIRECT-RUNNER-REGISTRY-INVENTORY"
  begin_case "$case_id" "Every repository-sensitive direct runner is derived from workflowModeGrants and has an active preflight or inherited-packet contract; no handwritten subset exists."
  runners="$(workflow_mode_grant_agents)"
  if [[ -n "$runners" ]]; then
    pass_assertion "$case_id" "direct-runner inventory is derived from agent-capabilities.yaml::workflowModeGrants"
  else
    fail_assertion "$case_id" "direct-runner inventory is derived from agent-capabilities.yaml::workflowModeGrants" \
      "derivedInventoryEmpty=true"
  fi
  while IFS= read -r runner; do
    [[ -n "$runner" ]] || continue
    runner_count=$((runner_count + 1))
    runner_file="$SCRIPT_DIR/../../agents/$runner.agent.md"
    runner_contract=""
    contract_valid=0
    if [[ -f "$runner_file" ]]; then
      runner_contract="$(repository_binding_sections "$runner_file")"
      if [[ "$runner_contract" == *'repository-binding.sh preflight'* && \
            "$runner_contract" == *'PREFLIGHT_COMMITTED'* ]]; then
        contract_valid=1
      elif [[ "$runner_contract" == *'repository-binding.sh validate-packet'* && \
              "$runner_contract" == *'repositoryResolution'* ]]; then
        contract_valid=1
      fi
    fi
    printf '  DERIVED RUNNER agent=%s contract=%s\n' "$runner" \
      "$([[ "$contract_valid" -eq 1 ]] && printf 'ported' || printf 'unported')"
    if [[ "$contract_valid" -ne 1 ]]; then
      unported_count=$((unported_count + 1))
      if [[ -n "$unported" ]]; then
        unported="$unported,$runner"
      else
        unported="$runner"
      fi
    fi
  done <<< "$runners"
  if [[ "$runner_count" -gt 0 && "$unported_count" -eq 0 ]]; then
    pass_assertion "$case_id" "registry-derived runner inventory has zero unported consumers"
  else
    fail_assertion "$case_id" "registry-derived runner inventory has zero unported consumers" \
      "derived=$runner_count unported=$unported_count agents=${unported:-none}"
  fi
  end_case "$case_id"

  run_front_doors_goal_nodes_goal_cases
  finish_named_suite "front-doors-goal-nodes"
}

run_front_doors_goal_nodes_goal_cases() {
  local case_id=""
  local scenario_schema=""
  local goal_scenario=""
  local sprint_scenario=""
  local cross_repo_section=""
  local source_root=""
  local repo_a=""
  local repo_b=""
  local repo_c=""
  local downstream_root=""
  local missing_plan=""
  local valid_plan=""
  local control_baseline=""
  local packet_b=""
  local packet_c=""
  local unresolved_packet=""
  local order=""
  local node_id=""
  local node_packet=""
  local result_repo=""

  source_root="$(cd "$SCRIPT_DIR/../.." && pwd -P)"

  case_id="RB-GOAL-SCENARIO-REPOSITORY-ROOTS"
  begin_case "$case_id" "Goal and sprint plans require a canonical repositoryRoot per repos entry and scoped decision/result metadata per node."
  scenario_schema="$(markdown_subtree "$SCENARIO_CONTRACT" "## Scenario DAG Schema")"
  goal_scenario="$(markdown_subtree "$GOAL_AGENT" "## Goal Scenario Compilation (Cross-Repo / Multi-Phase)")"
  sprint_scenario="$(markdown_subtree "$SPRINT_AGENT" "## Sprint Scenario Execution (Cross-Repo / Multi-Phase Missions)")"
  assert_text_contains "$case_id" "active scenario schema requires repositoryRoot on every repos entry" \
    "$scenario_schema" 'repositoryRoot'
  assert_binding_field_contract "$case_id" "active scenario schema defines the complete scoped node decision/result contract" \
    "$scenario_schema"
  assert_text_contains "$case_id" "goal executor declares goal-node scoped decisions" \
    "$goal_scenario" 'scopeKind: goal-node'
  assert_text_contains "$case_id" "goal executor verifies command root and revision after every node" \
    "$goal_scenario" 'byte-identical'
  assert_text_contains "$case_id" "sprint executor declares goal-node scoped decisions" \
    "$sprint_scenario" 'scopeKind: goal-node'
  assert_text_contains "$case_id" "sprint executor verifies command root and revision after every node" \
    "$sprint_scenario" 'byte-identical'

  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/control-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/node-b-repo")"
  repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/node-c-repo")"
  missing_plan="$CASE_DIR/missing-repository-roots.json"
  valid_plan="$CASE_DIR/canonical-repository-roots.json"
  jq -n '{
    version: 1,
    scenarioId: "missing-repository-roots",
    rootOutcome: {
      intent: "exercise two repository nodes",
      successSignal: "both node results validate",
      hardConstraints: ["top-level binding is unchanged"],
      failureCondition: "a node inherits ambient repository state"
    },
    repos: [
      {id: "node-b", role: "product"},
      {id: "node-c", role: "deployment-adapter"}
    ],
    nodes: [
      {id: "deliver-b", type: "delivery", repo: "node-b", mode: "full-delivery", dependsOn: []},
      {id: "verify-c", type: "verification", repo: "node-c", mode: "validate-only", dependsOn: ["deliver-b"]}
    ]
  }' >"$missing_plan" || fatal_fixture "$case_id" "cannot write missing-root scenario"
  invoke_real_script "$case_id" "real scenario lint rejects repos without canonical roots" \
    "$WORKSPACE_DIR" "$SCENARIO_LINT" "$missing_plan" "$source_root"
  assert_rc_nonzero "$case_id" "scenario lint rejects missing repos[].repositoryRoot"
  assert_output_regex "$case_id" "missing-root refusal identifies canonical repositoryRoot" \
    'repositoryRoot|canonical.*root'

  jq -n \
    --arg rootA "$repo_a" \
    --arg rootB "$repo_b" \
    --arg rootC "$repo_c" \
    --arg session "$SESSION_ID" \
    '{
      version: 1,
      scenarioId: "canonical-repository-roots",
      rootOutcome: {
        intent: "exercise two repository nodes",
        successSignal: "both node results validate",
        hardConstraints: ["top-level binding is unchanged"],
        failureCondition: "a node inherits ambient repository state"
      },
      repos: [
        {id: "control", role: "control", repositoryRoot: $rootA},
        {id: "node-b", role: "product", repositoryRoot: $rootB},
        {id: "node-c", role: "deployment-adapter", repositoryRoot: $rootC}
      ],
      nodes: [
        {
          id: "deliver-b", type: "delivery", repo: "node-b", mode: "full-delivery", dependsOn: [],
          repositoryResolution: {
            sessionId: $session, decisionId: ("rb:" + $session + ":1:node:deliver-b"),
            controlRevision: 1, authority: "scoped-scenario-node", transition: "scoped-override",
            scopeKind: "goal-node", scopeId: "deliver-b", targetKind: "goal-node",
            pathVisibility: "local", actionable: true
          }
        },
        {
          id: "verify-c", type: "verification", repo: "node-c", mode: "validate-only", dependsOn: ["deliver-b"],
          repositoryResolution: {
            sessionId: $session, decisionId: ("rb:" + $session + ":1:node:verify-c"),
            controlRevision: 1, authority: "scoped-scenario-node", transition: "scoped-override",
            scopeKind: "goal-node", scopeId: "verify-c", targetKind: "goal-node",
            pathVisibility: "local", actionable: true
          }
        }
      ]
    }' >"$valid_plan" || fatal_fixture "$case_id" "cannot write canonical-root scenario"
  invoke_real_script "$case_id" "real scenario lint accepts canonical roots and scoped node decisions" \
    "$WORKSPACE_DIR" "$SCENARIO_LINT" "$valid_plan" "$source_root"
  assert_rc_zero "$case_id" "scenario lint accepts the fully rooted scoped-node plan"
  end_case "$case_id"

  case_id="RB-GOAL-NODE-SCOPED-ORDER-INVARIANCE"
  begin_case "$case_id" "B and C goal nodes validate in both scheduler orders with scoped results while command-level A control bytes never change."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/control-repo")"
  repo_b="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/node-b-repo")"
  repo_c="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/node-c-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" \
    --workspace-root "$repo_a" --workspace-root "$repo_b" --workspace-root "$repo_c"
  control_baseline="$CASE_DIR/control-before-nodes.json"
  cp "$CONTROL_FILE" "$control_baseline" || fatal_fixture "$case_id" "cannot capture command control baseline"
  packet_b="$CASE_DIR/node-b-packet.json"
  packet_c="$CASE_DIR/node-c-packet.json"
  write_goal_node_packet "$packet_b" "$SESSION_ID" 1 "$repo_b" "node-b-repo" "node-b" || \
    fatal_fixture "$case_id" "cannot write node B packet"
  write_goal_node_packet "$packet_c" "$SESSION_ID" 1 "$repo_c" "node-c-repo" "node-c" || \
    fatal_fixture "$case_id" "cannot write node C packet"

  for order in "node-b node-c" "node-c node-b"; do
    printf '  SCHEDULER ORDER %s\n' "$order"
    for node_id in $order; do
      case "$node_id" in
        node-b) node_packet="$packet_b" ;;
        node-c) node_packet="$packet_c" ;;
      esac
      invoke_binding "$case_id" "$node_id scoped packet validates without command mutation" \
        "$repo_a" validate-packet --session-id "$SESSION_ID" \
        --session-control-file "$CONTROL_FILE" --packet-file "$node_packet"
      assert_rc_zero "$case_id" "$node_id validates as a scoped goal-node decision in order $order"
      assert_contains "$case_id" "$node_id validation reports scoped execution" 'SCOPED'
      assert_contains "$case_id" "$node_id validation reports its exact scopeId" "scopeId=$node_id"
      assert_files_equal "$case_id" "$node_id leaves top-level A root/revision byte-identical in order $order" \
        "$control_baseline" "$CONTROL_FILE"
    done
  done

  result_repo="$(create_result_validator_fixture "$case_id" node-b-result "$packet_b")"
  invoke_real_script "$case_id" "node B result echoes its scoped dispatch decision" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
    --binding-packet-file "$packet_b"
  assert_rc_zero "$case_id" "node B scoped RESULT-ENVELOPE validates against node B dispatch"
  result_repo="$(create_result_validator_fixture "$case_id" node-c-as-b-result "$packet_c")"
  invoke_real_script "$case_id" "node C result cannot escape into node B scope" \
    "$result_repo" "$result_repo/bubbles/scripts/result-envelope-validate.sh" --strict \
    --session-id "$SESSION_ID" --session-control-file "$CONTROL_FILE" \
    --binding-packet-file "$packet_b"
  assert_rc_nonzero "$case_id" "node C scoped result is rejected against node B dispatch"
  assert_output_regex "$case_id" "cross-scope result reaches exact result comparison" \
    'MALFORMED|does not match the current binding packet|does not match current packet'
  assert_files_equal "$case_id" "scoped result validation leaves command control byte-identical" \
    "$control_baseline" "$CONTROL_FILE"
  end_case "$case_id"

  case_id="RB-GOAL-NODE-UNRESOLVED-REFUSAL"
  begin_case "$case_id" "A node without a resolvable canonical root refuses GOAL_NODE_REPOSITORY_UNRESOLVED and never inherits command A, CWD, or prompt diagnostics."
  repo_a="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/control-repo")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$repo_a" --workspace-root "$repo_a"
  control_baseline="$CASE_DIR/control-before-unresolved-node.json"
  cp "$CONTROL_FILE" "$control_baseline" || fatal_fixture "$case_id" "cannot capture unresolved-node baseline"
  unresolved_packet="$CASE_DIR/unresolved-node-packet.json"
  write_goal_node_packet "$unresolved_packet" "$SESSION_ID" 1 \
    "$WORKSPACE_DIR/missing-node-repo" "missing-node-repo" "node-missing" || \
    fatal_fixture "$case_id" "cannot write unresolved node packet"
  DIAGNOSTIC_CHAT_CWD="$repo_a"
  DIAGNOSTIC_HOST_REPOSITORY="$repo_a"
  DIAGNOSTIC_ACTIVE_EDITOR="$repo_a/agents/bubbles.workflow.agent.md"
  DIAGNOSTIC_TOOL_CWD="$repo_a"
  invoke_binding "$case_id" "unresolved goal node cannot inherit ambient command root" \
    "$repo_a" validate-packet --session-id "$SESSION_ID" \
    --session-control-file "$CONTROL_FILE" --packet-file "$unresolved_packet"
  assert_rc_nonzero "$case_id" "unresolved goal-node packet refuses"
  assert_contains "$case_id" "unresolved node uses the dedicated refusal code" \
    'GOAL_NODE_REPOSITORY_UNRESOLVED'
  assert_excludes "$case_id" "unresolved node never reports a valid inherited command packet" \
    'REPOSITORY PACKET VALID'
  assert_excludes "$case_id" "unresolved node output never substitutes the top-level root" \
    "root=$repo_a"
  assert_files_equal "$case_id" "unresolved node leaves top-level A control byte-identical" \
    "$control_baseline" "$CONTROL_FILE"
  reset_diagnostics
  end_case "$case_id"

  case_id="RB-OWNERSHIP-DOWNSTREAM-FRAMEWORK-REFUSAL"
  begin_case "$case_id" "Selecting a downstream repository does not authorize canonical framework-source edits; upstream-first binding guard remains mandatory after selection."
  downstream_root="$(create_eligible_repo "$case_id" "$WORKSPACE_DIR/downstream-product")"
  establish_explicit_binding "$case_id" "$WORKSPACE_DIR" "$downstream_root" \
    --workspace-root "$downstream_root"
  control_baseline="$CASE_DIR/downstream-control-before-ownership-check.json"
  cp "$CONTROL_FILE" "$control_baseline" || fatal_fixture "$case_id" "cannot capture downstream control baseline"
  invoke_real_script "$case_id" "canonical framework agent cannot mutate a selected downstream root" \
    "$downstream_root" "$SOURCE_BINDING_PREFLIGHT" \
    --repo-root "$downstream_root" --agent-source bubbles
  assert_rc_nonzero "$case_id" "existing source-binding guard refuses downstream framework edits"
  assert_contains "$case_id" "ownership refusal identifies a binding mismatch" 'BINDING MISMATCH'
  assert_contains "$case_id" "ownership refusal directs work to the selected repo or canonical source" \
    'DIFFERENT workspace root'
  cross_repo_section="$(markdown_subtree "$SCENARIO_CONTRACT" "## Cross-Repo Execution Boundary (NON-NEGOTIABLE)")"
  assert_text_contains "$case_id" "scenario ownership contract keeps framework-write-guard after repository binding" \
    "$cross_repo_section" 'framework-write-guard'
  assert_text_regex "$case_id" "scenario ownership contract names the upstream-first authoring boundary" \
    "$cross_repo_section" 'upstream-first|canonical Bubbles repository'
  assert_files_equal "$case_id" "ownership refusal leaves selected downstream binding byte-identical" \
    "$control_baseline" "$CONTROL_FILE"
  end_case "$case_id"
}

run_conformance_suite() {
  local case_id="RB-CONFORMANCE-GUARD-FIXTURES"

  echo "=== IMP-103 S3 repository-binding conformance selftest ==="
  echo "SUITE conformance"
  echo "PRODUCTION guard=$CONFORMANCE_GUARD selftest=$CONFORMANCE_SELFTEST"
  begin_case "$case_id" "The S3 hermetic conformance matrix requires a clean pass and rejects every prohibited classifier or discovery bypass."
  invoke_real_script "$case_id" "repository-binding conformance fixtures execute" \
    "$WORKSPACE_DIR" "$CONFORMANCE_SELFTEST"
  assert_real_selftest_green "$case_id" "repository-binding conformance fixtures all satisfy expected pass/fail outcomes"
  end_case "$case_id"
  finish_named_suite "conformance"
}

run_all_suites() {
  local aggregate_suite=""
  local aggregate_child_rc=0
  local aggregate_passes=0
  local aggregate_failures=0
  local -a aggregate_suites=(
    foundation
    shared-infrastructure-canary
    state-propagation
    classification-discovery
    front-doors-goal-nodes
    conformance
  )

  echo "=== IMP-103 repository-binding aggregate selftest ==="
  printf 'AGGREGATE ORDER %s\n' "${aggregate_suites[*]}"
  for aggregate_suite in "${aggregate_suites[@]}"; do
    printf '\n=== AGGREGATE CHILD START suite=%s ===\n' "$aggregate_suite"
    if bash "$SCRIPT_DIR/repository-binding-selftest.sh" "--suite=$aggregate_suite"; then
      aggregate_passes=$((aggregate_passes + 1))
      printf '=== AGGREGATE CHILD PASS suite=%s ===\n' "$aggregate_suite"
    else
      aggregate_child_rc=$?
      aggregate_failures=$((aggregate_failures + 1))
      printf '=== AGGREGATE CHILD FAIL suite=%s exit=%s ===\n' \
        "$aggregate_suite" "$aggregate_child_rc"
    fi
  done

  printf '\n=== aggregate summary ===\n'
  printf 'suitesRun=%s suitesPass=%s suitesFail=%s\n' \
    "${#aggregate_suites[@]}" "$aggregate_passes" "$aggregate_failures"
  if [[ "$aggregate_failures" -ne 0 ]]; then
    printf 'repository-binding aggregate verdict=RED failedSuites=%s\n' \
      "$aggregate_failures"
    return 1
  fi
  echo "repository-binding aggregate verdict=PASS"
}

case "$suite" in
  all)
    run_all_suites
    exit $?
    ;;
  state-propagation)
    run_state_propagation_suite
    exit $?
    ;;
  shared-infrastructure-canary)
    run_shared_infrastructure_canary_suite
    exit $?
    ;;
  classification-discovery)
    run_classification_discovery_suite
    exit $?
    ;;
  front-doors-goal-nodes)
    run_front_doors_goal_nodes_suite
    exit $?
    ;;
  conformance)
    run_conformance_suite
    exit $?
    ;;
esac

echo "=== IMP-103 S1 repository-binding foundation selftest ==="
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