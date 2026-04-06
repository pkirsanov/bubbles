#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

failures=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

check_pattern() {
  local file_path="$1"
  local pattern="$2"
  local label="$3"

  if grep -Eq "$pattern" "$file_path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

echo "Running competitive-docs selftest..."
echo "Scenario: README and generated evaluator docs expose the same competitive truth path."

bash "$SCRIPT_DIR/generate-capability-ledger-docs.sh" --check >/dev/null
pass "Capability ledger docs are current before evaluator-path assertions"

check_pattern "$ROOT_DIR/README.md" 'Competitive Capabilities\]\(docs/generated/competitive-capabilities.md\) \| Ledger-backed competitive posture guide — 3 shipped, 1 partial, 2 proposed' "README links to the generated competitive guide with current ledger counts"
check_pattern "$ROOT_DIR/README.md" 'Issue Status\]\(docs/generated/issue-status.md\) \| Ledger-backed status for 2 tracked framework gaps and proposals' "README links to the generated issue status guide with current tracked-gap count"
check_pattern "$ROOT_DIR/docs/generated/competitive-capabilities.md" '^State summary: 3 shipped, 1 partial, 2 proposed\.$' "Generated competitive guide exposes the same state summary the README advertises"
check_pattern "$ROOT_DIR/docs/generated/issue-status.md" '^Tracked gaps: 2 issue-backed capabilities\.$' "Generated issue-status guide exposes the tracked-gap count referenced from README"
check_pattern "$ROOT_DIR/docs/generated/competitive-capabilities.md" '\[docs/issues/session-aware-runtime-coordination.md\]\(../issues/session-aware-runtime-coordination.md\)' "Generated competitive guide links evaluators to issue-backed proposal detail"

if [[ "$failures" -gt 0 ]]; then
  echo "competitive-docs selftest failed with $failures issue(s)."
  exit 1
fi

echo "competitive-docs selftest passed."