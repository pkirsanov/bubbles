#!/usr/bin/env bash
set -uo pipefail

# BUG-020 persistent production-path regression for macOS Bash 3.2 startup.
#
# Parser-free public API cases run first under Bash 3.2 and newer Bash. A
# system-only Bash 3.2 guard case then proves the normal parser refusal without
# Check 8 credit. Parser-aware guard cases use only the real jq/yq providers.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SOURCE_GUARD="$REPO_ROOT/bubbles/scripts/state-transition-guard.sh"
SOURCE_FUN_MODE="$REPO_ROOT/bubbles/scripts/fun-mode.sh"
TEST_FILE="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
SYSTEM_PATH="/usr/bin:/bin:/usr/sbin:/sbin"
BASH32="/bin/bash"

for required_path in "$SOURCE_GUARD" "$SOURCE_FUN_MODE" "$TEST_FILE"; do
  if [[ ! -f "$required_path" ]]; then
    printf 'test_27_state_transition_bash32_startup: required file missing: %s\n' "$required_path" >&2
    exit 2
  fi
done
if [[ ! -d "$REPO_ROOT/bubbles" || ! -d "$REPO_ROOT/agents" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: canonical framework surfaces are missing' >&2
  exit 2
fi

version_tuple() {
  "$1" -c 'printf "%s %s %s\n" "$BASH_VERSION" "${BASH_VERSINFO[0]}" "${BASH_VERSINFO[1]}"'
}

bash32_tuple="$(version_tuple "$BASH32")"
set -- $bash32_tuple
BASH32_VERSION="$1"
BASH32_MAJOR="$2"
BASH32_MINOR="$3"
if [[ "$BASH32_MAJOR" -ne 3 || "$BASH32_MINOR" -ne 2 ]]; then
  printf 'test_27_state_transition_bash32_startup: /bin/bash must be macOS Bash 3.2, observed %s\n' "$BASH32_VERSION" >&2
  exit 2
fi

NEWER_BASH=""
for bash_candidate in /opt/homebrew/bin/bash /usr/local/bin/bash "$(command -v bash 2>/dev/null || true)"; do
  [[ -n "$bash_candidate" && -x "$bash_candidate" ]] || continue
  bash_candidate_tuple="$(version_tuple "$bash_candidate")"
  set -- $bash_candidate_tuple
  if [[ "$2" -ge 4 ]]; then
    NEWER_BASH="$bash_candidate"
    NEWER_BASH_VERSION="$1"
    break
  fi
done
if [[ -z "$NEWER_BASH" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: a Bash 4+ control interpreter is required' >&2
  exit 2
fi

resolve_physical_executable() {
  local candidate="$1"
  local link_target=""
  local physical_dir=""

  while [[ -L "$candidate" ]]; do
    link_target="$(readlink "$candidate")" || return 1
    case "$link_target" in
      /*) candidate="$link_target" ;;
      *) candidate="$(dirname "$candidate")/$link_target" ;;
    esac
  done
  physical_dir="$(cd "$(dirname "$candidate")" && pwd -P)" || return 1
  printf '%s/%s\n' "$physical_dir" "$(basename "$candidate")"
}

JQ_COMMAND="$(command -v jq 2>/dev/null || true)"
YQ_COMMAND="$(command -v yq 2>/dev/null || true)"
if [[ -z "$JQ_COMMAND" || ! -x "$JQ_COMMAND" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: a real jq executable is required' >&2
  exit 2
fi
if [[ -z "$YQ_COMMAND" || ! -x "$YQ_COMMAND" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: a real yq executable is required' >&2
  exit 2
fi
JQ_REAL="$(resolve_physical_executable "$JQ_COMMAND")" || exit 2
YQ_REAL="$(resolve_physical_executable "$YQ_COMMAND")" || exit 2
NEWER_BASH_REAL="$(resolve_physical_executable "$NEWER_BASH")" || exit 2
JQ_DIR="$(dirname "$JQ_REAL")"
YQ_DIR="$(dirname "$YQ_REAL")"
NEWER_BASH_DIR="$(dirname "$NEWER_BASH_REAL")"
PARSER_AWARE_PATH="$SYSTEM_PATH"

append_parser_dir() {
  local parser_dir="$1"
  case ":$PARSER_AWARE_PATH:" in
    *":$parser_dir:"*) ;;
    *) PARSER_AWARE_PATH="$PARSER_AWARE_PATH:$parser_dir" ;;
  esac
}

append_parser_dir "$JQ_DIR"
append_parser_dir "$YQ_DIR"

NEWER_PARSER_PATH="$NEWER_BASH_DIR:$SYSTEM_PATH"
for parser_dir in "$JQ_DIR" "$YQ_DIR"; do
  case ":$NEWER_PARSER_PATH:" in
    *":$parser_dir:"*) ;;
    *) NEWER_PARSER_PATH="$NEWER_PARSER_PATH:$parser_dir" ;;
  esac
done

for parser_dir in "$JQ_DIR" "$YQ_DIR"; do
  case ":$SYSTEM_PATH:" in
    *":$parser_dir:"*) continue ;;
  esac
  for forbidden_provider in bash timeout gtimeout; do
    if [[ -x "$parser_dir/$forbidden_provider" ]]; then
      printf 'test_27_state_transition_bash32_startup: parser directory exposes forbidden provider: %s\n' \
        "$parser_dir/$forbidden_provider" >&2
      exit 2
    fi
  done
done

PARSER_BASH_PATH="$(/usr/bin/env -i PATH="$PARSER_AWARE_PATH" "$BASH32" -c 'command -v bash')"
PARSER_JQ_PATH="$(/usr/bin/env -i PATH="$PARSER_AWARE_PATH" "$BASH32" -c 'command -v jq')"
PARSER_YQ_PATH="$(/usr/bin/env -i PATH="$PARSER_AWARE_PATH" "$BASH32" -c 'command -v yq')"
case "$PARSER_BASH_PATH" in
  /bin/bash|/usr/bin/bash) ;;
  *)
    printf 'test_27_state_transition_bash32_startup: parser-aware PATH resolves a non-system bash: %s\n' \
      "$PARSER_BASH_PATH" >&2
    exit 2
    ;;
esac
if [[ "$(resolve_physical_executable "$PARSER_JQ_PATH")" != "$JQ_REAL" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: parser-aware PATH did not resolve the selected jq' >&2
  exit 2
fi
if [[ "$(resolve_physical_executable "$PARSER_YQ_PATH")" != "$YQ_REAL" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: parser-aware PATH did not resolve the selected yq' >&2
  exit 2
fi
NEWER_PATH_BASH="$(/usr/bin/env -i PATH="$NEWER_PARSER_PATH" "$NEWER_BASH" -c 'command -v bash')"
NEWER_PATH_JQ="$(/usr/bin/env -i PATH="$NEWER_PARSER_PATH" "$NEWER_BASH" -c 'command -v jq')"
NEWER_PATH_YQ="$(/usr/bin/env -i PATH="$NEWER_PARSER_PATH" "$NEWER_BASH" -c 'command -v yq')"
if [[ "$(resolve_physical_executable "$NEWER_PATH_BASH")" != "$NEWER_BASH_REAL" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: newer control PATH did not resolve the selected Bash' >&2
  exit 2
fi
if [[ "$(resolve_physical_executable "$NEWER_PATH_JQ")" != "$JQ_REAL" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: newer control PATH did not resolve the selected jq' >&2
  exit 2
fi
if [[ "$(resolve_physical_executable "$NEWER_PATH_YQ")" != "$YQ_REAL" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: newer control PATH did not resolve the selected yq' >&2
  exit 2
fi

if /usr/bin/env -i PATH="$SYSTEM_PATH" "$BASH32" -c 'command -v timeout || command -v gtimeout' >/dev/null 2>&1; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: Bash 3.2 control PATH unexpectedly exposes timeout/gtimeout' >&2
  exit 2
fi
if /usr/bin/env -i PATH="$PARSER_AWARE_PATH" "$BASH32" -c 'command -v timeout || command -v gtimeout' >/dev/null 2>&1; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: parser-aware PATH unexpectedly exposes timeout/gtimeout' >&2
  exit 2
fi
if /usr/bin/env -i PATH="$NEWER_PARSER_PATH" "$NEWER_BASH" -c 'command -v timeout || command -v gtimeout' >/dev/null 2>&1; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: newer control PATH unexpectedly exposes timeout/gtimeout' >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug020-XXXXXXXX")"
FIXTURE_REPO="$WORKSPACE/repo"
API_PROBE="$WORKSPACE/fun-api-probe.sh"
RUN_OUTPUT=""
RUN_STATUS=0
GUARD_RUN_COUNT=0
SYSTEM_GUARD_RUN_COUNT=0
PARSER_GUARD_RUN_COUNT=0
API_RUN_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0
BASH32_API_STARTUP_ABORTS=0
BASH32_GUARD_STARTUP_ABORTS=0
BASH32_RESOLVER_REFUSALS=0
BASH32_BUG022_OBSERVATIONS=0
BASH32_FOREIGN_PRE_CHECK8_ABORTS=0
BASH32_OTHER_PRE_CHECK8_ABORTS=0
ROOT_CAUSE_CONSTRUCTS=0
EXPECTED_RED_ASSERTION_FAILURES=0
UNRELATED_ASSERTION_FAILURES=0
HARNESS_FAILURES=0
ASSERTION_CONTEXT="normal"
RUN_EXPECTED_RED=0

cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  if [[ "$ASSERTION_CONTEXT" == "expected-red" ]]; then
    EXPECTED_RED_ASSERTION_FAILURES=$((EXPECTED_RED_ASSERTION_FAILURES + 1))
  else
    UNRELATED_ASSERTION_FAILURES=$((UNRELATED_ASSERTION_FAILURES + 1))
  fi
  printf 'FAIL: %s\n' "$1" >&2
}

assert_status() {
  local expected="$1"
  local label="$2"
  if [[ "$RUN_STATUS" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected exit $expected, got $RUN_STATUS)"
  fi
}

assert_nonzero_status() {
  local label="$1"
  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass "$label"
  else
    fail "$label (expected nonzero exit, got 0)"
  fi
}

assert_contains() {
  local expected="$1"
  local label="$2"
  if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$expected"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_not_contains() {
  local forbidden="$1"
  local label="$2"
  if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$forbidden"; then
    fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

assert_occurrences() {
  local expected="$1"
  local needle="$2"
  local label="$3"
  local actual
  actual="$(printf '%s\n' "$RUN_OUTPUT" | awk -v needle="$needle" '
    index($0, needle) { count++ }
    END { print count + 0 }
  ')"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected $expected occurrence(s), got $actual: $needle)"
  fi
}

assert_line_matches() {
  local pattern="$1"
  local label="$2"
  if printf '%s\n' "$RUN_OUTPUT" | grep -Eq -- "$pattern"; then
    pass "$label"
  else
    fail "$label (no line matched: $pattern)"
  fi
}

assert_no_startup_error() {
  local label="$1"
  local startup_pattern
  for startup_pattern in \
    'gate_passed: unbound variable' \
    'unbound variable' \
    'invalid option' \
    'bad option' \
    'local: -n' \
    'declare: -A' \
    'declare: -n' \
    'invalid variable name for name reference'; do
    assert_not_contains "$startup_pattern" "$label has no startup diagnostic: $startup_pattern"
  done
}

assert_no_fun_startup_error() {
  local label="$1"
  local startup_pattern
  for startup_pattern in \
    'gate_passed: unbound variable' \
    'local: -n' \
    'declare: -A' \
    'declare: -n' \
    'invalid variable name for name reference'; do
    assert_not_contains "$startup_pattern" "$label has no fun-mode startup diagnostic: $startup_pattern"
  done
}

file_digest() {
  shasum -a 256 "$1" | awk '{print $1}'
}

GUARD_BEFORE="$(file_digest "$SOURCE_GUARD")"
FUN_MODE_BEFORE="$(file_digest "$SOURCE_FUN_MODE")"
TEST_BEFORE="$(file_digest "$TEST_FILE")"

mkdir -p "$FIXTURE_REPO"
cp -R "$REPO_ROOT/bubbles" "$FIXTURE_REPO/bubbles"
cp -R "$REPO_ROOT/agents" "$FIXTURE_REPO/agents"
git -C "$FIXTURE_REPO" init -q
mkdir -p "$FIXTURE_REPO/specs" "$FIXTURE_REPO/tests"

cat >"$FIXTURE_REPO/tests/example.sh" <<'SHELL'
#!/usr/bin/env bash
printf '%s\n' 'BUG-020 existing test control'
SHELL
chmod +x "$FIXTURE_REPO/tests/example.sh"

write_delivery_packet() {
  local feature_dir="$1"
  local scenario_path="$2"
  local scenario_command="$3"

  mkdir -p "$feature_dir"
  cat >"$feature_dir/spec.md" <<'MARKDOWN'
# BUG-020 Guard Startup Fixture Spec

## Purpose

Exercise the production state-transition guard through a complete packet.
MARKDOWN
  cat >"$feature_dir/design.md" <<'MARKDOWN'
# BUG-020 Guard Startup Fixture Design

## Approach

Keep every unrelated transition condition on the known-positive contract while
the Test Plan selects either an existing file or a genuine missing file.
MARKDOWN
  cat >"$feature_dir/uservalidation.md" <<'MARKDOWN'
# User Validation

## Checklist

- [x] The fixture invokes the real production state-transition guard.
MARKDOWN
  cat >"$feature_dir/report.md" <<'MARKDOWN'
# Report

### Summary

Disposable BUG-020 production-guard fixture.

### Completion Statement

The fixture supplies complete evidence solely to isolate startup and Check 8.

### Test Evidence

```text
$ bash tests/example.sh
BUG-020 fixture setup complete
production guard invoked
Check 8 reached
structured result reached
scenario regression recorded
broader regression recorded
fixture remains disposable
fixture cleanup registered
guard truth remains authoritative
```
MARKDOWN
  cat >"$feature_dir/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "autonomous-goal",
  "execution": {
    "completedPhaseClaims": ["test", "validate", "audit", "docs"]
  },
  "certification": {
    "certifiedCompletedPhases": ["test", "validate", "audit", "docs"],
    "completedScopes": ["01-bug020-fixture"],
    "scopeProgress": [],
    "lockdownState": {
      "mode": "off",
      "lockedScenarioIds": []
    },
    "status": "in_progress"
  },
  "policySnapshot": {
    "grill": { "mode": "off", "source": "repo-default" },
    "tdd": { "mode": "off", "source": "repo-default" },
    "autoCommit": { "mode": "off", "source": "repo-default" },
    "lockdown": { "mode": "off", "source": "repo-default" },
    "regression": { "mode": "protect-existing-scenarios", "source": "repo-default" },
    "validation": { "mode": "required", "source": "workflow-forced" },
    "workflowMode": "autonomous-goal"
  },
  "transitionRequests": [],
  "reworkQueue": [],
  "executionHistory": [
    {
      "phase": "test",
      "agent": "bubbles.test",
      "phasesExecuted": ["test"],
      "runStartedAt": "2026-03-27T10:00:00Z",
      "runCompletedAt": "2026-03-27T10:00:47Z",
      "completedAt": "2026-03-27T10:00:47Z"
    },
    {
      "phase": "validate",
      "agent": "bubbles.validate",
      "phasesExecuted": ["validate"],
      "runStartedAt": "2026-03-27T10:01:13Z",
      "runCompletedAt": "2026-03-27T10:02:31Z",
      "completedAt": "2026-03-27T10:02:31Z"
    },
    {
      "phase": "audit",
      "agent": "bubbles.audit",
      "phasesExecuted": ["audit"],
      "runStartedAt": "2026-03-27T10:03:02Z",
      "runCompletedAt": "2026-03-27T10:06:08Z",
      "completedAt": "2026-03-27T10:06:08Z"
    },
    {
      "phase": "docs",
      "agent": "bubbles.docs",
      "phasesExecuted": ["docs"],
      "runStartedAt": "2026-03-27T10:07:19Z",
      "runCompletedAt": "2026-03-27T10:11:44Z",
      "completedAt": "2026-03-27T10:11:44Z"
    }
  ],
  "lastUpdatedAt": "2026-03-27T10:11:45Z"
}
JSON
  cat >"$feature_dir/scopes.md" <<MARKDOWN
# Scope 01: BUG-020 Guard Startup Fixture

**Status:** Done

### Goal

Exercise startup and Check 8 through the production transition guard.

### Test Plan

| Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- |
| Regression E2E | \`e2e-api\` | \`$scenario_path\` | Scenario-specific startup regression. | \`$scenario_command\` | Yes |
| Regression E2E | \`e2e-api\` | \`tests/example.sh\` | Broader production-guard control. | \`bash tests/example.sh\` | Yes |

### Definition of Done

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior -> Evidence: report.md#test-evidence
- [x] Broader E2E regression suite passes -> Evidence: report.md#test-evidence
- [x] Documentation route metadata is recorded consistently across artifacts -> Evidence: report.md#summary
MARKDOWN
}

PASS_FEATURE="$FIXTURE_REPO/specs/920-bug020-pass"
FINDING_FEATURE="$FIXTURE_REPO/specs/921-bug020-finding"
write_delivery_packet "$PASS_FEATURE" 'tests/example.sh' 'bash tests/example.sh'
write_delivery_packet "$FINDING_FEATURE" 'tests/genuinely-missing.spec.ts' 'tests/genuinely-missing.spec.ts'
if [[ -e "$FIXTURE_REPO/tests/genuinely-missing.spec.ts" ]]; then
  printf '%s\n' 'test_27_state_transition_bash32_startup: missing-file precondition failed' >&2
  exit 2
fi

run_guard() {
  local shell_path="$1"
  local child_path="$2"
  local shell_role="$3"
  local lane="$4"
  local fun_mode="$5"
  local fixture_kind="$6"
  local feature_dir="$7"
  local output_file

  GUARD_RUN_COUNT=$((GUARD_RUN_COUNT + 1))
  if [[ "$lane" == "system-only" ]]; then
    SYSTEM_GUARD_RUN_COUNT=$((SYSTEM_GUARD_RUN_COUNT + 1))
  else
    PARSER_GUARD_RUN_COUNT=$((PARSER_GUARD_RUN_COUNT + 1))
  fi
  output_file="$WORKSPACE/guard-${GUARD_RUN_COUNT}.log"
  RUN_STATUS=0
  if (
    cd "$FIXTURE_REPO"
    /usr/bin/env -i \
      HOME="$HOME" \
      PATH="$child_path" \
      BUBBLES_FUN_MODE="$fun_mode" \
      BUBBLES_REPO_ROOT="$FIXTURE_REPO" \
      BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1 \
      "$shell_path" "$FIXTURE_REPO/bubbles/scripts/state-transition-guard.sh" "$feature_dir"
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "=== GUARD CASE $GUARD_RUN_COUNT: shell=$shell_role lane=$lane fun=$fun_mode fixture=$fixture_kind ==="
  printf '%s\n' "$RUN_OUTPUT"
  printf 'GUARD_CASE_RESULT shell=%s lane=%s fun=%s fixture=%s exit=%s\n' \
    "$shell_role" "$lane" "$fun_mode" "$fixture_kind" "$RUN_STATUS"

  RUN_EXPECTED_RED=0
  if [[ "$shell_role" == "bash-3.2" ]] \
    && printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- 'failed_check_ids[@]: unbound variable'; then
    BASH32_BUG022_OBSERVATIONS=$((BASH32_BUG022_OBSERVATIONS + 1))
    printf 'BUG022_OWNED_OBSERVATION lane=%s fixture=%s\n' "$lane" "$fixture_kind"
  fi
  if [[ "$shell_role" == "bash-3.2" ]] \
    && ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- '--- Check 8: Test File Existence ---'; then
    if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- 'gate_passed: unbound variable'; then
      BASH32_GUARD_STARTUP_ABORTS=$((BASH32_GUARD_STARTUP_ABORTS + 1))
      RUN_EXPECTED_RED=1
    elif printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- 'E009-REGISTRY-MISSING: required registry parser is unavailable'; then
      BASH32_RESOLVER_REFUSALS=$((BASH32_RESOLVER_REFUSALS + 1))
    elif printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- 'failed_check_ids[@]: unbound variable'; then
      BASH32_FOREIGN_PRE_CHECK8_ABORTS=$((BASH32_FOREIGN_PRE_CHECK8_ABORTS + 1))
    else
      BASH32_OTHER_PRE_CHECK8_ABORTS=$((BASH32_OTHER_PRE_CHECK8_ABORTS + 1))
    fi
  fi
}

assert_parser_guard_contract() {
  local shell_role="$1"
  local fun_mode="$2"
  local fixture_kind="$3"
  local label="$shell_role $fun_mode $fixture_kind"

  if [[ "$RUN_EXPECTED_RED" -eq 1 ]]; then
    ASSERTION_CONTEXT="expected-red"
  fi
  assert_occurrences 1 '--- Check 8: Test File Existence ---' "$label reaches Check 8 exactly once"
  assert_occurrences 1 'BEGIN TRANSITION_GUARD_RESULT_V1' "$label emits one structured result start"
  assert_occurrences 1 'END TRANSITION_GUARD_RESULT_V1' "$label emits one structured result end"
  assert_no_startup_error "$label"

  if [[ "$fixture_kind" == "pass" ]]; then
    assert_status 0 "$label preserves the passing guard exit"
    assert_contains 'Test file exists: tests/example.sh' "$label exercises the existing-file branch"
    assert_contains 'failedChecks: []' "$label has no failed check"
    assert_contains 'exitStatus: 0' "$label reports structured exit zero"
    assert_contains 'verdict: PASS' "$label reports PASS"
  else
    assert_status 1 "$label preserves the genuine finding exit"
    assert_contains 'Test Plan references non-existent file: tests/genuinely-missing.spec.ts' "$label reports the genuine missing file"
    assert_contains 'failedChecks: [Check-8-file-existence]' "$label attributes failure only to Check 8"
    assert_contains 'exitStatus: 1' "$label reports structured exit one"
    assert_contains 'verdict: FAIL' "$label reports FAIL"
  fi

  if [[ "$fun_mode" == "false" ]]; then
    assert_not_contains '🫧' "$label emits no fun prefix"
  else
    assert_contains 'BUBBLES FUN MODE: ON' "$label emits the fun banner"
    assert_contains "Alright boys, here's what we're gonna do." "$label emits the guard-start message"
    if [[ "$fixture_kind" == "pass" ]]; then
      assert_contains 'Way she goes, boys. Way she goes.' "$label emits the passing summary"
    else
      assert_line_matches "^   🫧 (Something's fucky\\.|Holy f\\*\\*\\*, boys\\.|Boys, we're in the eye of a shiticane\\.|The shit winds are coming, Randy\\.)$" "$label emits a canonical failure message"
    fi
  fi
  ASSERTION_CONTEXT="normal"
}

assert_system_only_contract() {
  local label='bash-3.2 system-only false resolver-precondition'

  if [[ "$RUN_EXPECTED_RED" -eq 1 ]]; then
    ASSERTION_CONTEXT="expected-red"
  fi
  assert_nonzero_status "$label exits nonzero"
  assert_occurrences 1 'E009-REGISTRY-MISSING: required registry parser is unavailable' \
    "$label reports the exact resolver refusal once"
  assert_occurrences 0 '--- Check 8: Test File Existence ---' "$label receives zero Check 8 credit"
  assert_not_contains 'Check-8-file-existence' "$label has no Check 8 result attribution"
  assert_not_contains '🫧' "$label emits no fun prefix"
  assert_no_fun_startup_error "$label"
  ASSERTION_CONTEXT="normal"
}

printf '%s\n' '=== BUG-020 interpreter controls ==='
printf 'BASH32_PATH=%s\n' "$BASH32"
printf 'BASH32_VERSION=%s\n' "$BASH32_VERSION"
printf 'BASH32_PATH_ENV=%s\n' "$SYSTEM_PATH"
printf '%s\n' 'BASH32_TIMEOUT_TOOLS=absent'
printf 'NEWER_BASH_PATH=%s\n' "$NEWER_BASH"
printf 'NEWER_BASH_VERSION=%s\n' "$NEWER_BASH_VERSION"
printf 'NEWER_BASH_PATH_ENV=%s\n' "$NEWER_PARSER_PATH"
printf 'NEWER_PATH_BASH=%s\n' "$NEWER_PATH_BASH"
printf 'NEWER_PATH_JQ=%s\n' "$NEWER_PATH_JQ"
printf 'NEWER_PATH_YQ=%s\n' "$NEWER_PATH_YQ"
printf '%s\n' 'NEWER_PATH_TIMEOUT_TOOLS=absent'
printf 'PARSER_AWARE_PATH=%s\n' "$PARSER_AWARE_PATH"
printf 'PARSER_PATH_BASH=%s\n' "$PARSER_BASH_PATH"
printf 'PARSER_PATH_JQ=%s\n' "$PARSER_JQ_PATH"
printf 'PARSER_PATH_YQ=%s\n' "$PARSER_YQ_PATH"
printf '%s\n' 'PARSER_PATH_TIMEOUT_TOOLS=absent'
printf 'SOURCE_GUARD_SHA256=%s\n' "$GUARD_BEFORE"
printf 'SOURCE_FUN_MODE_SHA256=%s\n' "$FUN_MODE_BEFORE"
printf 'TEST_FILE_SHA256=%s\n' "$TEST_BEFORE"

cat >"$API_PROBE" <<'PROBE'
#!/usr/bin/env bash
set -uo pipefail

FUN_MODE_FILE="$1"
MODE="$2"
API_ASSERTIONS=0
API_FAILURES=0

api_pass() {
  API_ASSERTIONS=$((API_ASSERTIONS + 1))
  printf 'API_PASS: %s\n' "$1"
}

api_fail() {
  API_ASSERTIONS=$((API_ASSERTIONS + 1))
  API_FAILURES=$((API_FAILURES + 1))
  printf 'API_FAIL: %s\n' "$1" >&2
}

assert_call() {
  local expected_status="$1"
  local expected_output="$2"
  local label="$3"
  shift 3
  local observed_output
  local observed_status

  observed_output="$("$@" 2>&1)"
  observed_status=$?
  printf 'API_OBSERVED label=%s status=%s output=[%s]\n' "$label" "$observed_status" "$observed_output"
  if [[ "$observed_status" -eq "$expected_status" && "$observed_output" == "$expected_output" ]]; then
    api_pass "$label"
  else
    api_fail "$label expected_status=$expected_status expected_output=[$expected_output]"
  fi
}

assert_pool_call() {
  local label="$1"
  shift
  local observed_output
  local observed_status

  observed_output="$("$@" 2>&1)"
  observed_status=$?
  printf 'API_OBSERVED label=%s status=%s output=[%s]\n' "$label" "$observed_status" "$observed_output"
  if [[ "$observed_status" -ne 0 ]]; then
    api_fail "$label exits zero"
    return
  fi
  case "$label:$observed_output" in
    fun_pass:'   🫧 Decent!'|fun_pass:'   🫧 Looks good, boys.'|fun_pass:'   🫧 Way she goes.'|fun_pass:'   🫧 Not bad. Not bad at all.'|fun_pass:'   🫧 Passed with flying carpets!') api_pass "$label returns one pass-pool member" ;;
    fun_fail:"   🫧 Something's fucky."|fun_fail:'   🫧 Holy f***, boys.'|fun_fail:'   🫧 Boys, we'"'"'re in the eye of a shiticane.'|fun_fail:'   🫧 The shit winds are coming, Randy.') api_pass "$label returns one fail-pool member" ;;
    fun_warn:'   🫧 The shit winds are coming, Randy.'|fun_warn:'   🫧 Worst case Ontario...'|fun_warn:"   🫧 That's a bit greasy, boys.") api_pass "$label returns one warn-pool member" ;;
    *) api_fail "$label returns only a declared pool member" ;;
  esac
}

source "$FUN_MODE_FILE"

if [[ "$MODE" == "true" ]]; then
  assert_call 0 '' fun_mode_active fun_mode_active
else
  assert_call 1 '' fun_mode_active fun_mode_active
fi

while IFS='|' read -r event expected_message; do
  [[ -n "$event" ]] || continue
  if [[ "$MODE" == "true" ]]; then
    assert_call 0 "   🫧 $expected_message" "fun_message:$event" fun_message "$event"
  else
    assert_call 0 '' "fun_message:$event" fun_message "$event"
  fi
done <<'EVENTS'
gate_passed|Decent!
scope_ready|Looks good, boys.
gate_failed|Something's fucky.
fabrication_detected|That's GREASY, boys. Real greasy.
missing_evidence|Where's your evidence? Shit hawk circling.
all_gates_pass|Way she goes, boys. Way she goes.
build_failed|Holy f***, boys.
spec_completed|DEEEE-CENT!
warnings_found|The shit winds are coming, Randy.
chaos_clean|Worst case Ontario... nothing broke.
regression_clean|Steve French is purrin'. No regressions, boys.
regression_found|Something's prowlin' around in the code, boys.
spec_conflict|Steve French found another cougar's territory. Two specs, same route.
recap|So basically what happened was...
security_vuln|Safety... always ON.
docs_updated|Know what I'm sayin'? It's published.
deferral_detected|You can't just NOT do things, Corey!
deferral_blocks_done|That's NOT gettin' two birds stoned — that's just sayin' you WILL.
manipulation_detected|That's GREASY, boys. You can't just cross things out and say they're done!
format_bypass|You can't just erase the checkboxes and call it a day, Ricky!
invented_status|'Deferred — Planned Improvement'?! That's not even a real thing, Julian!
handoff_complete|Have a good one, boys.
gap_found|This is f***ed. BAAAAM!
bug_located|That's a nice f***ing kitty right there.
build_succeeds|Knock knock. Who's there? A passing build.
milestone_reached|Freedom 35, boys!
guard_start|Alright boys, here's what we're gonna do.
guard_blocked|Boys, we're in the eye of a shiticane.
guard_clear|Passed with flying carpets!
lint_start|Let's see if this thing's got its grade 10.
lint_clean|Not bad. Not bad at all.
lint_dirty|It's like a tropical earthquake blew through here.
dashboard_start|Let me check on the boys.
scan_start|I got work to do.
scan_clean|It's not rocket appliances — and it's clean.
scan_dirty|Gorilla see, gorilla do. Found copied garbage.
audit_start|Mr. Lahey, I got a confession to make.
audit_clean|The liquor figured it out, Randy.
audit_dirty|I am the liquor, and the liquor says NO.
EVENTS

assert_call 0 '' 'fun_message:unknown-event' fun_message unknown_event
if [[ "$MODE" == "true" ]]; then
  assert_pool_call fun_pass fun_pass
  assert_pool_call fun_fail fun_fail
  assert_pool_call fun_warn fun_warn
  expected_banner='   🫧 ────────────────────────────────────────
   🫧  BUBBLES FUN MODE: ON
   🫧  "It ain'"'"'t rocket appliances."
   🫧 ────────────────────────────────────────'
  assert_call 0 "$expected_banner" fun_banner fun_banner
  assert_call 0 '   🫧 Way she goes, boys. Way she goes.' 'fun_summary:pass' fun_summary pass
  assert_call 0 '   🫧 Boys, we'"'"'re in the eye of a shiticane.' 'fun_summary:blocked' fun_summary fail 5
  assert_call 0 "   🫧 Something's fucky." 'fun_summary:failed' fun_summary fail 1
else
  assert_call 0 '' fun_pass fun_pass
  assert_call 0 '' fun_fail fun_fail
  assert_call 0 '' fun_warn fun_warn
  assert_call 0 '' fun_banner fun_banner
  assert_call 0 '' 'fun_summary:pass' fun_summary pass
  assert_call 0 '' 'fun_summary:blocked' fun_summary fail 5
  assert_call 0 '' 'fun_summary:failed' fun_summary fail 1
fi

printf 'API_ASSERTIONS=%s\n' "$API_ASSERTIONS"
printf 'API_FAILURES=%s\n' "$API_FAILURES"
if [[ "$API_FAILURES" -ne 0 ]]; then
  exit 1
fi
printf 'API_PROBE_RESULT=PASS mode=%s\n' "$MODE"
PROBE
chmod +x "$API_PROBE"

run_api_probe() {
  local shell_path="$1"
  local child_path="$2"
  local shell_role="$3"
  local fun_mode="$4"
  local output_file

  API_RUN_COUNT=$((API_RUN_COUNT + 1))
  output_file="$WORKSPACE/api-${API_RUN_COUNT}.log"
  RUN_STATUS=0
  if /usr/bin/env -i \
    HOME="$HOME" \
    PATH="$child_path" \
    BUBBLES_FUN_MODE="$fun_mode" \
    "$shell_path" "$API_PROBE" "$SOURCE_FUN_MODE" "$fun_mode" >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "=== API CASE $API_RUN_COUNT: shell=$shell_role fun=$fun_mode ==="
  printf '%s\n' "$RUN_OUTPUT"
  printf 'API_CASE_RESULT shell=%s fun=%s exit=%s\n' "$shell_role" "$fun_mode" "$RUN_STATUS"
  RUN_EXPECTED_RED=0
  if [[ "$shell_role" == "bash-3.2" ]] \
    && printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- 'gate_passed: unbound variable'; then
    BASH32_API_STARTUP_ABORTS=$((BASH32_API_STARTUP_ABORTS + 1))
    RUN_EXPECTED_RED=1
    ASSERTION_CONTEXT="expected-red"
  fi
  assert_status 0 "$shell_role $fun_mode direct public API exits zero"
  assert_contains 'API_ASSERTIONS=48' "$shell_role $fun_mode executes all 48 API assertions"
  assert_contains 'API_FAILURES=0' "$shell_role $fun_mode has no API assertion failure"
  assert_contains "API_PROBE_RESULT=PASS mode=$fun_mode" "$shell_role $fun_mode reports direct API PASS"
  assert_no_startup_error "$shell_role $fun_mode direct API"
  ASSERTION_CONTEXT="normal"
}

printf '%s\n' '=== SCN-BUG-020-001: parser-free public API under actual macOS Bash 3.2 first ==='
run_api_probe "$BASH32" "$SYSTEM_PATH" 'bash-3.2' false
run_api_probe "$BASH32" "$SYSTEM_PATH" 'bash-3.2' true
printf '%s\n' '=== SCN-BUG-020-001: parser-free public API under newer Bash controls ==='
run_api_probe "$NEWER_BASH" "$SYSTEM_PATH" 'bash-newer' false
run_api_probe "$NEWER_BASH" "$SYSTEM_PATH" 'bash-newer' true

printf '%s\n' '=== SCN-BUG-020-002: system-only Bash 3.2 resolver refusal without Check 8 credit ==='
run_guard "$BASH32" "$SYSTEM_PATH" 'bash-3.2' system-only false resolver-precondition "$PASS_FEATURE"
assert_system_only_contract

printf '%s\n' '=== SCN-BUG-020-003: parser-aware macOS Bash 3.2 guard cases ==='
run_guard "$BASH32" "$PARSER_AWARE_PATH" 'bash-3.2' parser-aware false pass "$PASS_FEATURE"
assert_parser_guard_contract 'bash-3.2' false pass
run_guard "$BASH32" "$PARSER_AWARE_PATH" 'bash-3.2' parser-aware true pass "$PASS_FEATURE"
assert_parser_guard_contract 'bash-3.2' true pass
run_guard "$BASH32" "$PARSER_AWARE_PATH" 'bash-3.2' parser-aware false finding "$FINDING_FEATURE"
assert_parser_guard_contract 'bash-3.2' false finding
run_guard "$BASH32" "$PARSER_AWARE_PATH" 'bash-3.2' parser-aware true finding "$FINDING_FEATURE"
assert_parser_guard_contract 'bash-3.2' true finding

printf '%s\n' '=== SCN-BUG-020-003: parser-aware newer Bash guard controls ==='
run_guard "$NEWER_BASH" "$NEWER_PARSER_PATH" 'bash-newer' parser-aware false pass "$PASS_FEATURE"
assert_parser_guard_contract 'bash-newer' false pass
run_guard "$NEWER_BASH" "$NEWER_PARSER_PATH" 'bash-newer' parser-aware true pass "$PASS_FEATURE"
assert_parser_guard_contract 'bash-newer' true pass
run_guard "$NEWER_BASH" "$NEWER_PARSER_PATH" 'bash-newer' parser-aware false finding "$FINDING_FEATURE"
assert_parser_guard_contract 'bash-newer' false finding
run_guard "$NEWER_BASH" "$NEWER_PARSER_PATH" 'bash-newer' parser-aware true finding "$FINDING_FEATURE"
assert_parser_guard_contract 'bash-newer' true finding

printf '%s\n' '=== T-BUG-020-13: known Bash 3.2 root-cause constructs remain forbidden ==='
if grep -Eq '(^|[[:space:]])declare[[:space:]]+-A([[:space:]]|$)' "$SOURCE_FUN_MODE"; then
  ROOT_CAUSE_CONSTRUCTS=$((ROOT_CAUSE_CONSTRUCTS + 1))
  ASSERTION_CONTEXT="expected-red"
  fail 'canonical fun-mode source contains forbidden declare -A'
  ASSERTION_CONTEXT="normal"
else
  pass 'canonical fun-mode source rejects declare -A'
fi
if grep -Eq '(^|[[:space:]])local[[:space:]]+-n([[:space:]]|$)' "$SOURCE_FUN_MODE"; then
  ROOT_CAUSE_CONSTRUCTS=$((ROOT_CAUSE_CONSTRUCTS + 1))
  ASSERTION_CONTEXT="expected-red"
  fail 'canonical fun-mode source contains forbidden local -n'
  ASSERTION_CONTEXT="normal"
else
  pass 'canonical fun-mode source rejects local -n'
fi
if grep -Eq '(^|[[:space:]])declare[[:space:]]+-n([[:space:]]|$)' "$SOURCE_FUN_MODE"; then
  ROOT_CAUSE_CONSTRUCTS=$((ROOT_CAUSE_CONSTRUCTS + 1))
  ASSERTION_CONTEXT="expected-red"
  fail 'canonical fun-mode source contains forbidden declare -n'
  ASSERTION_CONTEXT="normal"
else
  pass 'canonical fun-mode source rejects declare -n'
fi

printf '%s\n' '=== BUG-020 containment checks ==='
GUARD_AFTER="$(file_digest "$SOURCE_GUARD")"
FUN_MODE_AFTER="$(file_digest "$SOURCE_FUN_MODE")"
TEST_AFTER="$(file_digest "$TEST_FILE")"
if [[ "$GUARD_AFTER" == "$GUARD_BEFORE" ]]; then
  pass "state-transition guard stayed byte-identical at $GUARD_AFTER"
else
  fail "state-transition guard changed during regression: $GUARD_BEFORE -> $GUARD_AFTER"
fi
if [[ "$FUN_MODE_AFTER" == "$FUN_MODE_BEFORE" ]]; then
  pass "fun-mode source stayed byte-identical at $FUN_MODE_AFTER"
else
  fail "fun-mode source changed during regression: $FUN_MODE_BEFORE -> $FUN_MODE_AFTER"
fi
if [[ "$TEST_AFTER" == "$TEST_BEFORE" ]]; then
  pass "regression file stayed byte-identical at $TEST_AFTER"
else
  fail "regression file changed during execution: $TEST_BEFORE -> $TEST_AFTER"
fi

EXPECTED_GUARD_RUNS=9
EXPECTED_SYSTEM_GUARD_RUNS=1
EXPECTED_PARSER_GUARD_RUNS=8
EXPECTED_API_RUNS=4
if [[ "$GUARD_RUN_COUNT" -eq "$EXPECTED_GUARD_RUNS" ]]; then
  pass "all $EXPECTED_GUARD_RUNS production-guard cases executed"
else
  fail "expected $EXPECTED_GUARD_RUNS production-guard cases, executed $GUARD_RUN_COUNT"
fi
if [[ "$SYSTEM_GUARD_RUN_COUNT" -eq "$EXPECTED_SYSTEM_GUARD_RUNS" ]]; then
  pass "all $EXPECTED_SYSTEM_GUARD_RUNS system-only guard cases executed"
else
  fail "expected $EXPECTED_SYSTEM_GUARD_RUNS system-only guard cases, executed $SYSTEM_GUARD_RUN_COUNT"
fi
if [[ "$PARSER_GUARD_RUN_COUNT" -eq "$EXPECTED_PARSER_GUARD_RUNS" ]]; then
  pass "all $EXPECTED_PARSER_GUARD_RUNS parser-aware guard cases executed"
else
  fail "expected $EXPECTED_PARSER_GUARD_RUNS parser-aware guard cases, executed $PARSER_GUARD_RUN_COUNT"
fi
if [[ "$API_RUN_COUNT" -eq "$EXPECTED_API_RUNS" ]]; then
  pass "all $EXPECTED_API_RUNS direct-API cases executed"
else
  fail "expected $EXPECTED_API_RUNS direct-API cases, executed $API_RUN_COUNT"
fi

cleanup
trap - EXIT INT TERM
if [[ ! -e "$WORKSPACE" ]]; then
  pass 'temporary regression workspace was removed'
else
  fail "temporary regression workspace remains: $WORKSPACE"
fi

printf '%s\n' '=== BUG-020 regression summary ==='
printf 'GUARD_RUNS=%s\n' "$GUARD_RUN_COUNT"
printf 'SYSTEM_GUARD_RUNS=%s\n' "$SYSTEM_GUARD_RUN_COUNT"
printf 'PARSER_GUARD_RUNS=%s\n' "$PARSER_GUARD_RUN_COUNT"
printf 'API_RUNS=%s\n' "$API_RUN_COUNT"
printf 'ASSERTIONS=%s\n' "$((PASS_COUNT + FAIL_COUNT))"
printf 'PASSED=%s\n' "$PASS_COUNT"
printf 'FAILED=%s\n' "$FAIL_COUNT"
printf 'BASH32_API_STARTUP_ABORTS=%s\n' "$BASH32_API_STARTUP_ABORTS"
printf 'BASH32_GUARD_STARTUP_ABORTS=%s\n' "$BASH32_GUARD_STARTUP_ABORTS"
printf 'BASH32_RESOLVER_REFUSALS=%s\n' "$BASH32_RESOLVER_REFUSALS"
printf 'BASH32_BUG022_OBSERVATIONS=%s\n' "$BASH32_BUG022_OBSERVATIONS"
printf 'BASH32_FOREIGN_PRE_CHECK8_ABORTS=%s\n' "$BASH32_FOREIGN_PRE_CHECK8_ABORTS"
printf 'BASH32_OTHER_PRE_CHECK8_ABORTS=%s\n' "$BASH32_OTHER_PRE_CHECK8_ABORTS"
printf 'ROOT_CAUSE_CONSTRUCTS=%s\n' "$ROOT_CAUSE_CONSTRUCTS"
printf 'EXPECTED_RED_ASSERTION_FAILURES=%s\n' "$EXPECTED_RED_ASSERTION_FAILURES"
printf 'UNRELATED_ASSERTION_FAILURES=%s\n' "$UNRELATED_ASSERTION_FAILURES"
printf 'CONTROL_FAILURES=%s\n' "$UNRELATED_ASSERTION_FAILURES"
printf 'HARNESS_FAILURES=%s\n' "$HARNESS_FAILURES"
printf 'FINAL_SOURCE_GUARD_SHA256=%s\n' "$GUARD_AFTER"
printf 'FINAL_SOURCE_FUN_MODE_SHA256=%s\n' "$FUN_MODE_AFTER"
printf 'FINAL_TEST_FILE_SHA256=%s\n' "$TEST_AFTER"

if [[ "$FAIL_COUNT" -eq 0 ]]; then
  printf '%s\n' 'BUG020_RED_DISPOSITION=RED_INVALID_CURRENT_SOURCE_GREEN'
elif [[ "$BASH32_API_STARTUP_ABORTS" -eq 2 \
  && "$BASH32_GUARD_STARTUP_ABORTS" -eq 5 \
  && "$BASH32_RESOLVER_REFUSALS" -eq 0 \
  && "$BASH32_BUG022_OBSERVATIONS" -eq 0 \
  && "$BASH32_FOREIGN_PRE_CHECK8_ABORTS" -eq 0 \
  && "$ROOT_CAUSE_CONSTRUCTS" -eq 2 \
  && "$EXPECTED_RED_ASSERTION_FAILURES" -gt 0 \
  && "$UNRELATED_ASSERTION_FAILURES" -eq 0 \
  && "$HARNESS_FAILURES" -eq 0 \
  && "$BASH32_OTHER_PRE_CHECK8_ABORTS" -eq 0 ]]; then
  printf '%s\n' 'BUG020_RED_DISPOSITION=VALID_PRE_FIX_RED'
elif [[ "$BASH32_API_STARTUP_ABORTS" -eq 0 \
  && "$BASH32_GUARD_STARTUP_ABORTS" -eq 0 \
  && "$BASH32_RESOLVER_REFUSALS" -eq 1 \
  && "$BASH32_FOREIGN_PRE_CHECK8_ABORTS" -eq 4 \
  && "$BASH32_OTHER_PRE_CHECK8_ABORTS" -eq 0 ]]; then
  printf '%s\n' 'BUG020_RED_DISPOSITION=RED_INVALID_FOREIGN_DEPENDENCY_BLOCKED'
else
  printf '%s\n' 'BUG020_RED_DISPOSITION=RED_INVALID_UNRELATED_OR_MIXED_FAILURE'
fi

if [[ "$FAIL_COUNT" -ne 0 ]]; then
  printf '%s\n' 'BUG-020 state-transition Bash 3.2 startup regression FAILED' >&2
  exit 1
fi

printf '%s\n' 'BUG-020 state-transition Bash 3.2 startup regression passed.'

