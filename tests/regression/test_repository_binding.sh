#!/usr/bin/env bash
set -u
set -o pipefail

# Persistent IMP-022 regression entry point. Every subset delegates to the
# hermetic selftest, which invokes the real production owners. Resolver and
# propagation behavior are never duplicated in this regression wrapper.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd -P)"
CLI="$REPO_ROOT/bubbles/scripts/cli.sh"

suite="foundation"
for arg in "$@"; do
  case "$arg" in
    --suite=foundation) suite="foundation" ;;
    -h|--help)
      cat <<'EOF'
Usage: test_repository_binding.sh --suite=<suite>

Suites:
  foundation                    IMP-022 S1 repository binding foundation

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

echo "=== Regression: IMP-022 repository binding suite=$suite ==="
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
