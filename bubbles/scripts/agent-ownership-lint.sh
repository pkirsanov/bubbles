#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$script_dir" == *"/.github/bubbles/scripts" ]]; then
  root_dir="${script_dir%/.github/bubbles/scripts}"
  agents_dir="$root_dir/.github/agents"
  shared_dir="$agents_dir/bubbles_shared"
  workflows_file="$root_dir/.github/bubbles/workflows.yaml"
  ownership_file="$root_dir/.github/bubbles/agent-ownership.yaml"
else
  root_dir="${script_dir%/bubbles/scripts}"
  agents_dir="$root_dir/agents"
  shared_dir="$agents_dir/bubbles_shared"
  workflows_file="$root_dir/bubbles/workflows.yaml"
  ownership_file="$root_dir/bubbles/agent-ownership.yaml"
  capabilities_file="$root_dir/bubbles/agent-capabilities.yaml"
fi

errors=0

check_no_match() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if grep -nE "$pattern" "$file"; then
    echo "ERROR: $message"
    errors=1
  fi
}

check_has_match() {
  local file="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -nE "$pattern" "$file" >/dev/null; then
    echo "ERROR: $message"
    errors=1
  fi
}

check_has_match "$ownership_file" '^version:' 'agent ownership manifest missing version header'
check_has_match "$capabilities_file" '^version:' 'agent capabilities manifest missing version header'
check_has_match "$capabilities_file" '^childWorkflowPolicy:' 'agent capabilities manifest missing child workflow policy block'
check_has_match "$capabilities_file" '^resultPolicy:' 'agent capabilities manifest missing result policy block'
check_has_match "$shared_dir/agent-common.md" '^## Artifact Ownership And Delegation Contract$' 'agent-common.md missing ownership contract section'
check_has_match "$workflows_file" 'name: agent_ownership_gate' 'workflows.yaml missing agent ownership gate'
check_has_match "$workflows_file" 'name: capability_delegation_gate' 'workflows.yaml missing capability delegation gate'
check_has_match "$workflows_file" 'name: owner_only_remediation_gate' 'workflows.yaml missing G062 owner-only remediation gate'
check_has_match "$workflows_file" 'name: concrete_result_gate' 'workflows.yaml missing G063 concrete result gate'
check_has_match "$workflows_file" 'name: child_workflow_depth_gate' 'workflows.yaml missing G064 child workflow depth gate'
check_has_match "$ownership_file" '^  state\.json:' 'agent ownership manifest missing state.json ownership block'
check_has_match "$ownership_file" '^  scenario-manifest\.json:' 'agent ownership manifest missing scenario-manifest ownership block'
check_has_match "$capabilities_file" '^  bubbles\.validate:' 'agent capabilities manifest missing bubbles.validate entry'
check_has_match "$capabilities_file" 'certificationWriter: bubbles\.validate' 'agent capabilities manifest must declare bubbles.validate as certification writer'

check_no_match "$agents_dir/bubbles.design.agent.md" '^- `spec\.md` — Feature specification|create or complete it using the spec template' 'bubbles.design must not own or create spec.md'
check_no_match "$agents_dir/bubbles.validate.agent.md" '^#### 7\.2 What to Update \(Per Issue Category\)|Artifact to Update \| What to Add' 'bubbles.validate must route artifact changes instead of editing spec/design/scopes directly'
check_no_match "$agents_dir/bubbles.ux.agent.md" 'recommend running `/bubbles\.analyst` first, but proceed' 'bubbles.ux must not proceed without analyst-owned business inputs'
check_no_match "$agents_dir/bubbles.code-review.agent.md" 'directly or via `runSubagent`' 'bubbles.code-review must dispatch specialists, not emulate them directly'
check_no_match "$agents_dir/bubbles.system-review.agent.md" 'directly or via `runSubagent`' 'bubbles.system-review must dispatch specialists, not emulate them directly'
check_no_match "$agents_dir/bubbles.implement.agent.md" 'Create `uservalidation\.md` if missing' 'bubbles.implement must not create uservalidation.md'
check_no_match "$agents_dir/bubbles.security.agent.md" 'Update scope artifacts with new DoD items|Add new Gherkin scenarios for security behaviors' 'bubbles.security must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.stabilize.agent.md" 'Update scope artifacts:' 'bubbles.stabilize must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.gaps.agent.md" 'Findings artifact update \(MANDATORY — Gate G031\).*update scope artifacts|Gherkin → Test Plan Sync:|Gherkin → DoD Sync:' 'bubbles.gaps must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.harden.agent.md" 'Findings artifact update \(MANDATORY — Gate G031\).*update scope artifacts|Gherkin → Test Plan Sync|Gherkin → DoD Sync' 'bubbles.harden must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.clarify.agent.md" 'Small fixes \(≤30 lines\):.*Fix inline within this agent' 'bubbles.clarify must not perform inline remediation'
check_no_match "$agents_dir/bubbles.regression.agent.md" 'Small fixes \(≤30 lines\):.*Fix inline within this agent|All fixes:.*directly fix' 'bubbles.regression must route follow-up work instead of fixing inline'
check_no_match "$agents_dir/bubbles.validate.agent.md" 'Do NOT emit `✅ ALL VALIDATIONS PASSED` while any `ROUTE-REQUIRED` block is present' 'bubbles.validate should rely on RESULT-ENVELOPE as the primary workflow contract'

unexpected_child_callers="$({ awk '
  /^  bubbles\./ { agent=$1; sub(":", "", agent) }
  /canInvokeChildWorkflows:[[:space:]]*true/ { print agent }
' "$capabilities_file" | grep -vE '^bubbles\.(workflow|iterate|bug)$'; } || true)"

if [[ -n "$unexpected_child_callers" ]]; then
  echo "ERROR: only orchestrators may enable child workflows; found unexpected callers:"
  echo "$unexpected_child_callers"
  errors=1
fi

for result_agent in \
  bubbles.workflow \
  bubbles.validate \
  bubbles.audit \
  bubbles.plan \
  bubbles.gaps \
  bubbles.clarify \
  bubbles.stabilize \
  bubbles.chaos \
  bubbles.harden \
  bubbles.security \
  bubbles.regression \
  bubbles.implement \
  bubbles.test \
  bubbles.docs \
  bubbles.simplify
do
  check_has_match "$agents_dir/${result_agent}.agent.md" 'RESULT-ENVELOPE' "$result_agent must declare RESULT-ENVELOPE completion output"
done

if [[ "$errors" -ne 0 ]]; then
  exit 1
fi

echo 'Agent ownership lint passed.'