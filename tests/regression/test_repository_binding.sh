#!/usr/bin/env bash
set -u
set -o pipefail

# Persistent IMP-103 regression entry point. Every subset delegates to the
# hermetic selftest, which invokes the real production owners. Resolver and
# propagation behavior are never duplicated in this regression wrapper.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
CLI="$REPO_ROOT/bubbles/scripts/cli.sh"
TMP_ROOT="$(mktemp -d)" || {
  echo "test_repository_binding: unable to create hermetic wrapper root" >&2
  exit 2
}
trap 'rm -rf "$TMP_ROOT"' EXIT INT TERM
CLI_TEST_ROOT="$TMP_ROOT/cli-bookkeeping"
CANONICAL_RUNTIME_DIR="$REPO_ROOT/.specify/runtime"
RUN_STATE_BASELINE="$TMP_ROOT/workflow-runs.baseline"
EVENT_LOG_BASELINE="$TMP_ROOT/framework-events.baseline"
RUN_STATE_EXISTED=false
EVENT_LOG_EXISTED=false

front_doors_goal_nodes_case_inventory() {
  printf '%s\n' \
    RB-SENTINEL-PATH-SEGMENT-REFUSAL \
    RB-FRONTDOOR-CONCRETE-TARGET-ESTABLISHES \
    RB-SUPER-NATURAL-LANGUAGE-ESTABLISHES \
    RB-FRONTDOOR-WORKFLOW-PREFLIGHT-DISCOVERY \
    RB-FRONTDOOR-ITERATE-WORK-ENVELOPE \
    RB-FRONTDOOR-SUPER-RESOLUTION-ENVELOPE \
    RB-SUPER-NATURAL-LANGUAGE-DISCOVERY \
    RB-FRAMEWORK-ENVELOPE-EXACT-BINDING \
    RB-DISPATCH-RESULT-EXACT-BINDING \
    RB-CONTINUATION-RECAP-STATUS-HANDOFF \
    RB-CONTINUATION-COMPACTION-RESUME \
    RB-DIRECT-RUNNER-REGISTRY-INVENTORY \
    RB-GOAL-SCENARIO-REPOSITORY-ROOTS \
    RB-GOAL-NODE-FORGED-ALIAS-REFUSAL \
    RB-GOAL-NODE-SCOPED-ORDER-INVARIANCE \
    RB-GOAL-NODE-UNRESOLVED-REFUSAL \
    RB-OWNERSHIP-DOWNSTREAM-FRAMEWORK-REFUSAL
}

capture_canonical_runtime_baseline() {
  if [[ -f "$CANONICAL_RUNTIME_DIR/workflow-runs.json" ]]; then
    cp "$CANONICAL_RUNTIME_DIR/workflow-runs.json" "$RUN_STATE_BASELINE" || return 2
    RUN_STATE_EXISTED=true
  fi
  if [[ -f "$CANONICAL_RUNTIME_DIR/framework-events.jsonl" ]]; then
    cp "$CANONICAL_RUNTIME_DIR/framework-events.jsonl" "$EVENT_LOG_BASELINE" || return 2
    EVENT_LOG_EXISTED=true
  fi
}

assert_canonical_runtime_unchanged() {
  local failed=0

  if [[ "$RUN_STATE_EXISTED" == "true" ]]; then
    if [[ -f "$CANONICAL_RUNTIME_DIR/workflow-runs.json" ]] && \
      cmp -s "$RUN_STATE_BASELINE" "$CANONICAL_RUNTIME_DIR/workflow-runs.json"; then
      echo "RUNTIME IMMUTABILITY PASS: workflow-runs.json byte-identical"
    else
      echo "RUNTIME IMMUTABILITY RED: workflow-runs.json changed or disappeared" >&2
      failed=1
    fi
  elif [[ ! -e "$CANONICAL_RUNTIME_DIR/workflow-runs.json" ]]; then
    echo "RUNTIME IMMUTABILITY PASS: workflow-runs.json remains absent"
  else
    echo "RUNTIME IMMUTABILITY RED: workflow-runs.json was created" >&2
    failed=1
  fi

  if [[ "$EVENT_LOG_EXISTED" == "true" ]]; then
    if [[ -f "$CANONICAL_RUNTIME_DIR/framework-events.jsonl" ]] && \
      cmp -s "$EVENT_LOG_BASELINE" "$CANONICAL_RUNTIME_DIR/framework-events.jsonl"; then
      echo "RUNTIME IMMUTABILITY PASS: framework-events.jsonl byte-identical"
    else
      echo "RUNTIME IMMUTABILITY RED: framework-events.jsonl changed or disappeared" >&2
      failed=1
    fi
  elif [[ ! -e "$CANONICAL_RUNTIME_DIR/framework-events.jsonl" ]]; then
    echo "RUNTIME IMMUTABILITY PASS: framework-events.jsonl remains absent"
  else
    echo "RUNTIME IMMUTABILITY RED: framework-events.jsonl was created" >&2
    failed=1
  fi

  return "$failed"
}

case_starts_from_transcript() {
  local transcript="$1"
  local line=""
  local case_ids=""

  while IFS= read -r line; do
    case "$line" in
      "CASE START "*)
        if [[ -n "$case_ids" ]]; then
          case_ids="$case_ids
${line#CASE START }"
        else
          case_ids="${line#CASE START }"
        fi
        ;;
    esac
  done <<< "$transcript"
  printf '%s\n' "$case_ids"
}

line_count() {
  local lines="$1"
  local line=""
  local count=0

  while IFS= read -r line; do
    [[ -n "$line" ]] && count=$((count + 1))
  done <<< "$lines"
  printf '%s\n' "$count"
}

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
Usage: test_repository_binding.sh --suite=<suite>

Suites:
  foundation                    IMP-103 S1 repository binding foundation
  state-propagation             IMP-103 S2 mirror and provenance propagation
  classification-discovery      IMP-103 S3 classification and scoped discovery
  front-doors-goal-nodes        IMP-103 S4 front doors, packets, and scoped goal nodes
  shared-infrastructure-canary  Legacy state/compactor/result contracts
  conformance                   IMP-103 S3 source conformance fixtures
  all                           All suites in deterministic dependency order

Default: foundation
EOF
      exit 0
      ;;
    *)
      printf 'test_repository_binding: unknown argument: %s\n' "$arg" >&2
      exit 2
      ;;
  esac
done

echo "=== Regression: IMP-103 repository binding suite=$suite ==="
case "$suite" in
  foundation)
    echo "CASE INVENTORY: RB-CLI-BOUNDARY-EXECUTED"
    echo "CASE INVENTORY: RB-SHARED-PREFLIGHT-CONTRACT"
    echo "CASE INVENTORY: RB-CANONICAL-IDENTITY"
    echo "CASE INVENTORY: RB-TARGET-PHYSICAL-CONTAINMENT"
    echo "CASE INVENTORY: RB-AUTH-INCIDENTAL-ACCESS-EXCLUDED"
    echo "CASE INVENTORY: RB-AUTH-BOUNDARY-OUTRANKS-AMBIENT"
    echo "CASE INVENTORY: RB-AUTH-DIAGNOSTICS-EXPLICIT-ONLY"
    echo "CASE INVENTORY: RB-AUTH-NO-FIRST-ROOT-FALLBACK"
    echo "CASE INVENTORY: RB-AUTH-SOLE-ELIGIBLE-COMPATIBILITY"
    echo "CASE INVENTORY: RB-TRANSITION-FIRST-ESTABLISHMENT-EXPECTS-ZERO"
    echo "CASE INVENTORY: RB-TRANSITION-EXISTING-BOUNDARY-REQUIRES-REVISION"
    echo "CASE INVENTORY: RB-TRANSITION-VALID-SWITCH-PERSISTS"
    echo "CASE INVENTORY: RB-TRANSITION-FAILED-SWITCH-PRESERVES"
    echo "CASE INVENTORY: RB-AUTH-CONFLICT-REFUSES"
    echo "CASE INVENTORY: RB-AUTH-STALE-BOUNDARY-REFUSES"
    echo "CASE INVENTORY: RB-AUTH-BOUND-ROOT-MUST-REMAIN-DECLARED"
    echo "CASE INVENTORY: RB-AUTH-EXPLICIT-REPAIR-PRECEDENCE"
    echo "CASE INVENTORY: RB-CONTROL-PATH-EXTERNAL-CANONICAL"
    echo "CASE INVENTORY: RB-CONTROL-PARENT-OWNER-MODE-SYMLINK"
    echo "CASE INVENTORY: RB-SESSION-ISOLATION-NO-MIRROR-INHERITANCE"
    echo "CASE INVENTORY: RB-SCHEMA-CONTROL-POSITIVE"
    echo "CASE INVENTORY: RB-SCHEMA-CONTROL-NEGATIVE"
    echo "CASE INVENTORY: RB-SCHEMA-MALFORMED-EXPLICIT-REPAIR"
    echo "CASE INVENTORY: RB-SCHEMA-DEFINITIONS-AND-CONSTRAINTS"
    echo "CASE INVENTORY: RB-SCHEMA-DRAFT202012-VALIDATION"
    echo "CASE INVENTORY: RB-SCHEMA-CONTROL-CLOSED-ENUMS"
    echo "CASE INVENTORY: RB-SCHEMA-ACTIONABLE-PACKET-POSITIVE"
    echo "CASE INVENTORY: RB-SCHEMA-PACKET-CLOSED-CONTRACT"
    echo "CASE INVENTORY: RB-PACKET-EXACT-COMMAND-PROVENANCE"
    echo "CASE INVENTORY: RB-PACKET-ONE-READ-NORMALIZED-CONSUMPTION"
    echo "CASE INVENTORY: RB-PROJECTION-REDACTED-NONACTIONABLE"
    echo "CASE INVENTORY: RB-FOUR-SUBCOMMAND-CONTRACT"
    echo "CASE INVENTORY: RB-SUBCOMMAND-ARGUMENT-REFUSALS"
    echo "CASE INVENTORY: RB-CONTROL-LOCK-BUSY-PRESERVES"
    echo "CASE INVENTORY: RB-TRANSITION-CONCURRENT-ESTABLISHMENT-CAS"
    echo "CASE INVENTORY: RB-TRANSITION-CONCURRENT-SWITCH-CAS"
    ;;
  state-propagation)
    echo "CASE INVENTORY: RB-PROPAGATION-SHARED-INFRASTRUCTURE-CANARY"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-ABSENT-ACTIONABLE-ONLY"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-SYMLINK-PATH-REFUSAL"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-UPDATE-PRESERVES-STATE"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-OTHER-SESSION-CONTROL-WINS"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-SAME-SESSION-DRIFT"
    echo "CASE INVENTORY: RB-PROPAGATION-STATE-SNAPSHOT-BINDING-REQUIRED"
    echo "CASE INVENTORY: RB-PROPAGATION-LOCAL-MUTATORS-REQUIRE-ACTIONABLE-BINDING"
    echo "CASE INVENTORY: RB-PROPAGATION-CONSUMERS-REFUSE-NONCURRENT"
    echo "CASE INVENTORY: RB-PROPAGATION-HANDOFF-COMPACTION"
    echo "CASE INVENTORY: RB-PROPAGATION-RESULT-ENVELOPE-PROVENANCE"
    ;;
  shared-infrastructure-canary)
    echo "CASE INVENTORY: RB-CANARY-LEGACY-STATE-SNAPSHOT"
    echo "CASE INVENTORY: RB-CANARY-LEGACY-CONTEXT-COMPACTOR"
    echo "CASE INVENTORY: RB-CANARY-LEGACY-RESULT-ENVELOPE"
    echo "CASE INVENTORY: RB-CANARY-ADDITIVE-MIRROR-OLDER-READERS"
    ;;
  classification-discovery)
    echo "CASE INVENTORY: RB-CLASSIFICATION-MODE-CONCRETE-TARGET"
    echo "CASE INVENTORY: RB-CLASSIFICATION-MODE-ROOT-TARGETLESS"
    echo "CASE INVENTORY: RB-CLASSIFICATION-MODE-ONLY-TARGETLESS"
    echo "CASE INVENTORY: RB-CLASSIFICATION-NO-MODE-PRESERVES-DELEGATION"
    echo "CASE INVENTORY: RB-INCIDENT-80331F88-BOUNDARY"
    echo "CASE INVENTORY: RB-INCIDENT-80331F88-UNBOUND-REFUSAL"
    echo "CASE INVENTORY: RB-EXPLICIT-REPOSITORY-ROOT-QF"
    echo "CASE INVENTORY: RB-DISCOVERY-REFUSES-NONCURRENT-DECISIONS"
    echo "CASE INVENTORY: RB-REGISTRY-ROOT-SCOPED-AUTO-DISCOVERY"
    ;;
  front-doors-goal-nodes)
    while IFS= read -r case_id; do
      echo "CASE INVENTORY: $case_id"
    done < <(front_doors_goal_nodes_case_inventory)
    ;;
  conformance)
    echo "CASE INVENTORY: RB-CONFORMANCE-GUARD-FIXTURES"
    echo "CASE INVENTORY: RB-CONFORMANCE-DUAL-ROLE-BUG-PACKET-VALIDATION-MISSING"
    echo "CASE INVENTORY: RB-CONFORMANCE-SCENARIO-REPOSITORY-ALIAS-DROPPED"
    ;;
  all)
    echo "SUITE INVENTORY: foundation"
    echo "SUITE INVENTORY: shared-infrastructure-canary"
    echo "SUITE INVENTORY: state-propagation"
    echo "SUITE INVENTORY: classification-discovery"
    echo "SUITE INVENTORY: front-doors-goal-nodes"
    echo "SUITE INVENTORY: conformance"
    ;;
esac

if [[ ! -f "$CLI" ]]; then
  echo "test_repository_binding: RED behavioralContract=foundation-entrypoint missingCli=$CLI" >&2
  exit 2
fi

BUBBLES_REPOSITORY_BINDING_TEST_ROOT="$CLI_TEST_ROOT"
BUBBLES_REPOSITORY_BINDING_REQUIRE_CLI=1
export BUBBLES_REPOSITORY_BINDING_TEST_ROOT BUBBLES_REPOSITORY_BINDING_REQUIRE_CLI
capture_canonical_runtime_baseline || {
  echo "test_repository_binding: unable to capture canonical runtime baseline" >&2
  exit 2
}
suite_output="$(bash "$CLI" repository-binding-selftest --suite="$suite" 2>&1)"
rc=$?
printf '%s\n' "$suite_output"
runtime_rc=0
assert_canonical_runtime_unchanged || runtime_rc=$?
if [[ "$runtime_rc" -ne 0 ]]; then
  printf 'test_repository_binding: RED %s suite mutated canonical runtime bookkeeping\n' \
    "$suite" >&2
  exit "$runtime_rc"
fi
if [[ "$rc" -ne 0 ]]; then
  printf 'test_repository_binding: RED %s suite exit=%s\n' "$suite" "$rc" >&2
  exit "$rc"
fi

if [[ "$suite" == "front-doors-goal-nodes" ]]; then
  expected_cases="$(front_doors_goal_nodes_case_inventory)"
  actual_cases="$(case_starts_from_transcript "$suite_output")"
  if [[ "$actual_cases" != "$expected_cases" ]]; then
    printf 'test_repository_binding: RED front-doors inventory drift expected=%s actual=%s\n' \
      "$(line_count "$expected_cases")" "$(line_count "$actual_cases")" >&2
    printf 'EXPECTED CASES\n%s\nACTUAL CASES\n%s\n' "$expected_cases" "$actual_cases" >&2
    exit 1
  fi
  printf 'test_repository_binding: INVENTORY PASS suite=%s cases=%s\n' \
    "$suite" "$(line_count "$actual_cases")"
fi

printf 'test_repository_binding: PASS %s suite\n' "$suite"
