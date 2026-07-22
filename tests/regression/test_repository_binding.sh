#!/usr/bin/env bash
set -u
set -o pipefail

# Persistent IMP-103 regression entry point. Every subset delegates to the
# hermetic selftest, which invokes the real production owners. Resolver and
# propagation behavior are never duplicated in this regression wrapper.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
CLI="$REPO_ROOT/bubbles/scripts/cli.sh"

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
    echo "CASE INVENTORY: RB-AUTH-NO-FIRST-ROOT-FALLBACK"
    echo "CASE INVENTORY: RB-AUTH-SOLE-ELIGIBLE-COMPATIBILITY"
    echo "CASE INVENTORY: RB-TRANSITION-VALID-SWITCH-PERSISTS"
    echo "CASE INVENTORY: RB-TRANSITION-FAILED-SWITCH-PRESERVES"
    echo "CASE INVENTORY: RB-AUTH-CONFLICT-REFUSES"
    echo "CASE INVENTORY: RB-AUTH-STALE-BOUNDARY-REFUSES"
    echo "CASE INVENTORY: RB-AUTH-BOUND-ROOT-MUST-REMAIN-DECLARED"
    echo "CASE INVENTORY: RB-AUTH-EXPLICIT-REPAIR-PRECEDENCE"
    echo "CASE INVENTORY: RB-CONTROL-PATH-EXTERNAL-CANONICAL"
    echo "CASE INVENTORY: RB-SESSION-ISOLATION-NO-MIRROR-INHERITANCE"
    echo "CASE INVENTORY: RB-SCHEMA-CONTROL-POSITIVE"
    echo "CASE INVENTORY: RB-SCHEMA-CONTROL-NEGATIVE"
    echo "CASE INVENTORY: RB-SCHEMA-MALFORMED-EXPLICIT-REPAIR"
    echo "CASE INVENTORY: RB-SCHEMA-DEFINITIONS-AND-CONSTRAINTS"
    echo "CASE INVENTORY: RB-SCHEMA-DRAFT202012-VALIDATION"
    echo "CASE INVENTORY: RB-SCHEMA-CONTROL-CLOSED-ENUMS"
    echo "CASE INVENTORY: RB-SCHEMA-ACTIONABLE-PACKET-POSITIVE"
    echo "CASE INVENTORY: RB-SCHEMA-PACKET-CLOSED-CONTRACT"
    echo "CASE INVENTORY: RB-PROJECTION-REDACTED-NONACTIONABLE"
    echo "CASE INVENTORY: RB-FOUR-SUBCOMMAND-CONTRACT"
    echo "CASE INVENTORY: RB-SUBCOMMAND-ARGUMENT-REFUSALS"
    echo "CASE INVENTORY: RB-CONTROL-LOCK-BUSY-PRESERVES"
    echo "CASE INVENTORY: RB-TRANSITION-CONCURRENT-SWITCH-CAS"
    ;;
  state-propagation)
    echo "CASE INVENTORY: RB-PROPAGATION-SHARED-INFRASTRUCTURE-CANARY"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-ABSENT-ACTIONABLE-ONLY"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-UPDATE-PRESERVES-STATE"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-OTHER-SESSION-CONTROL-WINS"
    echo "CASE INVENTORY: RB-PROPAGATION-MIRROR-SAME-SESSION-DRIFT"
    echo "CASE INVENTORY: RB-PROPAGATION-STATE-SNAPSHOT-BINDING-REQUIRED"
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
    echo "CASE INVENTORY: RB-FRONTDOOR-WORKFLOW-PREFLIGHT-DISCOVERY"
    echo "CASE INVENTORY: RB-FRONTDOOR-ITERATE-WORK-ENVELOPE"
    echo "CASE INVENTORY: RB-FRONTDOOR-SUPER-RESOLUTION-ENVELOPE"
    echo "CASE INVENTORY: RB-DISPATCH-RESULT-EXACT-BINDING"
    echo "CASE INVENTORY: RB-CONTINUATION-RECAP-STATUS-HANDOFF"
    echo "CASE INVENTORY: RB-DIRECT-RUNNER-REGISTRY-INVENTORY"
    echo "CASE INVENTORY: RB-GOAL-SCENARIO-REPOSITORY-ROOTS"
    echo "CASE INVENTORY: RB-GOAL-NODE-SCOPED-ORDER-INVARIANCE"
    echo "CASE INVENTORY: RB-GOAL-NODE-UNRESOLVED-REFUSAL"
    echo "CASE INVENTORY: RB-OWNERSHIP-DOWNSTREAM-FRAMEWORK-REFUSAL"
    ;;
  conformance)
    echo "CASE INVENTORY: RB-CONFORMANCE-GUARD-FIXTURES"
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

BUBBLES_REPOSITORY_BINDING_REQUIRE_CLI=1 \
  bash "$CLI" repository-binding-selftest --suite="$suite"
rc=$?
if [[ "$rc" -ne 0 ]]; then
  printf 'test_repository_binding: RED %s suite exit=%s\n' "$suite" "$rc" >&2
  exit "$rc"
fi

printf 'test_repository_binding: PASS %s suite\n' "$suite"
