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
check_has_match "$shared_dir/agent-common.md" '^## Artifact Ownership And Delegation Contract$' 'agent-common.md missing ownership contract section'
check_has_match "$workflows_file" 'name: agent_ownership_gate' 'workflows.yaml missing agent ownership gate'

check_no_match "$agents_dir/bubbles.design.agent.md" '^- `spec\.md` — Feature specification|create or complete it using the spec template' 'bubbles.design must not own or create spec.md'
check_no_match "$agents_dir/bubbles.validate.agent.md" '^#### 7\.2 What to Update \(Per Issue Category\)|Artifact to Update \| What to Add' 'bubbles.validate must route artifact changes instead of editing spec/design/scopes directly'
check_no_match "$agents_dir/bubbles.ux.agent.md" 'recommend running `/bubbles\.analyst` first, but proceed' 'bubbles.ux must not proceed without analyst-owned business inputs'
check_no_match "$agents_dir/bubbles.review.agent.md" 'directly or via `runSubagent`' 'bubbles.review must dispatch specialists, not emulate them directly'
check_no_match "$agents_dir/bubbles.implement.agent.md" 'Create `uservalidation\.md` if missing' 'bubbles.implement must not create uservalidation.md'
check_no_match "$agents_dir/bubbles.security.agent.md" 'Update scope artifacts with new DoD items|Add new Gherkin scenarios for security behaviors' 'bubbles.security must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.stabilize.agent.md" 'Update scope artifacts:' 'bubbles.stabilize must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.gaps.agent.md" 'Findings artifact update \(MANDATORY — Gate G031\).*update scope artifacts|Gherkin → Test Plan Sync:|Gherkin → DoD Sync:' 'bubbles.gaps must route planning changes to bubbles.plan'
check_no_match "$agents_dir/bubbles.harden.agent.md" 'Findings artifact update \(MANDATORY — Gate G031\).*update scope artifacts|Gherkin → Test Plan Sync|Gherkin → DoD Sync' 'bubbles.harden must route planning changes to bubbles.plan'

if [[ "$errors" -ne 0 ]]; then
  exit 1
fi

echo 'Agent ownership lint passed.'