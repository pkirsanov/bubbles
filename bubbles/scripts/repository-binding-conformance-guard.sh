#!/usr/bin/env bash
set -u
set -o pipefail

usage() {
  cat <<'USAGE'
Usage: repository-binding-conformance-guard.sh --root <source-root>

Validate active S3+S4 repository-binding classification, ordering, discovery,
front-door, packet-field, direct-runner, scenario, goal-node, and authority
contracts. Unknown options fail closed.
USAGE
}

root=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      [[ $# -ge 2 ]] || {
        echo "RB-CONFORMANCE-ARGUMENT-INVALID missingValue=--root" >&2
        exit 64
      }
      root="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "RB-CONFORMANCE-ARGUMENT-INVALID unknownOption=$1" >&2
      exit 64
      ;;
  esac
done

[[ -n "$root" ]] || {
  echo "RB-CONFORMANCE-ARGUMENT-INVALID required=--root" >&2
  exit 64
}
[[ -d "$root" ]] || {
  echo "RB-CONFORMANCE-ROOT-MISSING root=$root" >&2
  exit 1
}
root="$(cd "$root" && pwd -P)" || {
  echo "RB-CONFORMANCE-ROOT-INVALID root=$root" >&2
  exit 1
}

failures=0

report_failure() {
  local code="$1"
  local path="$2"
  local detail="$3"
  failures=$((failures + 1))
  printf '%s path=%s detail=%s\n' "$code" "$path" "$detail" >&2
}

require_file() {
  local relative_path="$1"
  if [[ ! -f "$root/$relative_path" ]]; then
    report_failure "RB-CONFORMANCE-SURFACE-MISSING" "$relative_path" "required-file-absent"
    return 1
  fi
  return 0
}

markdown_section() {
  local file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    $0 == heading { active = 1; print; next }
    active && /^#{1,6}[[:space:]]/ { exit }
    active { print }
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
      active = 1
      level = heading_level($0)
      print
      next
    }
    active && /^#{1,6}[[:space:]]/ && heading_level($0) <= level { exit }
    active { print }
  ' "$file"
}

repository_binding_section() {
  local file="$1"
  awk '
    function heading_level(line, copy) {
      copy = line
      sub(/[^#].*$/, "", copy)
      return length(copy)
    }
    /^#{2,6} Repository Binding/ {
      active = 1
      level = heading_level($0)
      print
      next
    }
    active && /^#{1,6}[[:space:]]/ && heading_level($0) <= level { exit }
    active { print }
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
    /^#{1,6}[[:space:]].*Repository Binding/ {
      active = 1
      level = heading_level($0)
      print
      next
    }
    active && /^#{1,6}[[:space:]]/ && heading_level($0) <= level {
      active = 0
    }
    active { print }
  ' "$file"
}

binding_field_contract() {
  printf '%s\n' \
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
    repositoryResolution.actionable
}

binding_fields_in_text() {
  local text="$1"
  printf '%s\n' "$text" | awk '
    function remember(name) { found[name] = 1 }
    {
      line = $0
      while (match(line, /repositoryResolution\.[A-Za-z][A-Za-z]*/)) {
        remember(substr(line, RSTART, RLENGTH))
        line = substr(line, RSTART + RLENGTH)
      }
      if ($0 ~ /(^|[^A-Za-z])repositoryRoot([^A-Za-z]|$)/) {
        remember("repositoryRoot")
      }
      if ($0 ~ /(^|[^A-Za-z])repositoryAlias([^A-Za-z]|$)/) {
        remember("repositoryAlias")
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
  '
}

check_exact_binding_text() {
  local relative_path="$1"
  local text="$2"
  local contract="$3"
  local expected=""
  local actual=""

  expected="$(binding_field_contract)"
  actual="$(binding_fields_in_text "$text")"
  if [[ "$actual" != "$expected" ]]; then
    report_failure "RB-CONFORMANCE-BINDING-FIELDS-DROPPED" "$relative_path" \
      "$contract expected=$(printf '%s' "$expected" | tr '\n' ',') actual=$(printf '%s' "$actual" | tr '\n' ',')"
  fi
}

check_exact_binding_section() {
  local relative_path="$1"
  local heading="$2"
  local file="$root/$relative_path"
  local section=""

  require_file "$relative_path" || return
  section="$(markdown_subtree "$file" "$heading")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-BINDING-FIELDS-DROPPED" "$relative_path" \
      "binding-section-absent heading=$heading"
    return
  fi
  check_exact_binding_text "$relative_path" "$section" "heading=$heading"
}

check_result_binding_contract() {
  local relative_path="skills/bubbles-result-envelope/SKILL.md"
  local file="$root/$relative_path"
  local section=""

  require_file "$relative_path" || return
  section="$(repository_binding_section "$file")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-BINDING-FIELDS-DROPPED" "$relative_path" \
      "result-binding-section-absent"
    return
  fi
  check_exact_binding_text "$relative_path" "$section" "result-envelope-binding"
}

yaml_mode_section() {
  local file="$1"
  local mode="$2"
  awk -v key="  ${mode}:" '
    $0 == key { active = 1; print; next }
    active && /^  [^ #][^:]*:[[:space:]]*$/ { exit }
    active { print }
  ' "$file"
}

first_position() {
  local file="$1"
  local needle="$2"
  awk -v needle="$needle" '
    {
      column = index($0, needle)
      if (column > 0) {
        print NR ":" column
        exit
      }
    }
  ' "$file"
}

text_position() {
  local text="$1"
  local needle="$2"
  printf '%s\n' "$text" | awk -v needle="$needle" '
    {
      column = index($0, needle)
      if (column > 0) {
        print NR ":" column
        exit
      }
    }
  '
}

check_text_order() {
  local relative_path="$1"
  local text="$2"
  local first="$3"
  local second="$4"
  local detail="$5"
  local first_position=""
  local second_position=""
  local first_line=0
  local first_column=0
  local second_line=0
  local second_column=0

  first_position="$(text_position "$text" "$first")"
  second_position="$(text_position "$text" "$second")"
  if [[ -z "$first_position" || -z "$second_position" ]]; then
    report_failure "RB-CONFORMANCE-FRONT-DOOR-ORDER" "$relative_path" \
      "$detail first=${first_position:-missing} second=${second_position:-missing}"
    return
  fi

  first_line="${first_position%%:*}"
  first_column="${first_position#*:}"
  second_line="${second_position%%:*}"
  second_column="${second_position#*:}"
  if [[ "$first_line" -gt "$second_line" ]] || \
    { [[ "$first_line" -eq "$second_line" ]] && [[ "$first_column" -ge "$second_column" ]]; }; then
    report_failure "RB-CONFORMANCE-FRONT-DOOR-ORDER" "$relative_path" \
      "$detail first=$first_position second=$second_position"
  fi
}

check_front_door_order() {
  local relative_path="$1"
  local heading="$2"
  local file="$root/$relative_path"
  local section=""

  require_file "$relative_path" || return
  section="$(markdown_subtree "$file" "$heading")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-FRONT-DOOR-ORDER" "$relative_path" \
      "execution-section-absent heading=$heading"
    return
  fi

  check_text_order "$relative_path" "$section" \
    "repository-binding.sh preflight" "PREFLIGHT_COMMITTED" \
    "preflight-must-precede-commit"
  check_text_order "$relative_path" "$section" \
    "PREFLIGHT_COMMITTED" "repository-binding.sh discover-specs" \
    "commit-must-precede-discovery"
  check_text_order "$relative_path" "$section" \
    "PREFLIGHT_COMMITTED" "state.json" \
    "commit-must-precede-state"
}

check_super_prebinding_input() {
  local relative_path="agents/bubbles.super.agent.md"
  local iterate_path="agents/bubbles.iterate.agent.md"
  local file="$root/$relative_path"
  local section=""
  local candidate_path=""

  require_file "$relative_path" || return
  require_file "$iterate_path" || return
  for candidate_path in "$relative_path" "$iterate_path"; do
    if grep -Fq 'Available specs: {specs/ listing}' "$root/$candidate_path"; then
      report_failure "RB-CONFORMANCE-SUPER-PREBINDING-SPECS" "$candidate_path" \
        "pre-binding-specs-listing-forwarded-to-super"
    fi
  done

  section="$(awk '
    /^Resolution is two-stage\./ { active = 1 }
    active { print }
  ' "$file")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-SUPER-PREBINDING-SPECS" "$relative_path" \
      "two-stage-resolution-contract-absent"
    return
  fi
  case "$section" in
    *'do not receive a cross-repository specs listing'*) ;;
    *)
      report_failure "RB-CONFORMANCE-SUPER-PREBINDING-SPECS" "$relative_path" \
        "pre-binding-specs-prohibition-absent"
      ;;
  esac
  check_text_order "$relative_path" "$section" \
    "PREFLIGHT_COMMITTED" "resolvedRepositoryRoot/specs" \
    "preflight-must-precede-bound-spec-resolution"
}

workflow_mode_grant_agents() {
  local file="$1"
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
  ' "$file"
}

check_direct_runners() {
  local relative_path="bubbles/agent-capabilities.yaml"
  local file="$root/$relative_path"
  local runners=""
  local runner=""
  local runner_path=""
  local runner_section=""
  local runner_count=0

  require_file "$relative_path" || return
  runners="$(workflow_mode_grant_agents "$file")"
  if [[ -z "$runners" ]]; then
    report_failure "RB-CONFORMANCE-DIRECT-RUNNER-UNPORTED" "$relative_path" \
      "workflowModeGrants-derived-inventory-empty"
    return
  fi

  while IFS= read -r runner; do
    [[ -n "$runner" ]] || continue
    runner_count=$((runner_count + 1))
    runner_path="agents/$runner.agent.md"
    if [[ ! -f "$root/$runner_path" ]]; then
      report_failure "RB-CONFORMANCE-DIRECT-RUNNER-UNPORTED" "$runner_path" \
        "registry-derived-runner-file-absent"
      continue
    fi
    runner_section="$(repository_binding_sections "$root/$runner_path")"
    if [[ "$runner_section" == *'repository-binding.sh preflight'* && \
          "$runner_section" == *'PREFLIGHT_COMMITTED'* ]]; then
      continue
    fi
    if [[ "$runner_section" == *'repository-binding.sh validate-packet'* && \
          "$runner_section" == *'repositoryResolution'* ]]; then
      continue
    fi
    report_failure "RB-CONFORMANCE-DIRECT-RUNNER-UNPORTED" "$runner_path" \
      "runner=$runner missing-top-level-preflight-or-inherited-packet-contract"
  done <<< "$runners"

  if [[ "$runner_count" -eq 0 ]]; then
    report_failure "RB-CONFORMANCE-DIRECT-RUNNER-UNPORTED" "$relative_path" \
      "workflowModeGrants-derived-inventory-empty"
  fi
}

check_scenario_repository_roots() {
  local relative_path="agents/bubbles_shared/scenario-compile.md"
  local file="$root/$relative_path"
  local section=""

  require_file "$relative_path" || return
  section="$(markdown_subtree "$file" "## Scenario DAG Schema")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-SCENARIO-REPOSITORY-ROOT-DROPPED" "$relative_path" \
      "scenario-dag-section-absent"
    return
  fi
  case "$section" in
    *'repositoryRoot: <canonical-absolute-git-root>'*) ;;
    *)
      report_failure "RB-CONFORMANCE-SCENARIO-REPOSITORY-ROOT-DROPPED" "$relative_path" \
        "canonical-repositoryRoot-contract-absent"
      ;;
  esac
}

check_goal_node_contract() {
  local relative_path="$1"
  local heading="$2"
  local file="$root/$relative_path"
  local section=""
  local required_text=""

  require_file "$relative_path" || return
  section="$(markdown_subtree "$file" "$heading")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-GOAL-NODE-CONTRACT-DROPPED" "$relative_path" \
      "goal-node-section-absent heading=$heading"
    return
  fi
  for required_text in 'scopeKind: goal-node' 'scopeId' 'byte-identical'; do
    case "$section" in
      *"$required_text"*) ;;
      *)
        report_failure "RB-CONFORMANCE-GOAL-NODE-CONTRACT-DROPPED" "$relative_path" \
          "missing-contract=$required_text"
        ;;
    esac
  done
}

check_discovery_order() {
  local relative_path="$1"
  local file="$root/$relative_path"
  local anchor_position=""
  local discovery_position=""
  local anchor_line=0
  local anchor_column=0
  local discovery_line=0
  local discovery_column=0

  require_file "$relative_path" || return
  anchor_position="$(first_position "$file" "PREFLIGHT_COMMITTED")"
  discovery_position="$(first_position "$file" "repository-binding.sh discover-specs")"
  if [[ -z "$discovery_position" ]]; then
    report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "discover-specs-anchor-absent"
    return
  fi
  if [[ -z "$anchor_position" ]]; then
    report_failure "RB-CONFORMANCE-PREFLIGHT-ANCHOR-MISSING" "$relative_path" "PREFLIGHT_COMMITTED-absent"
    return
  fi

  anchor_line="${anchor_position%%:*}"
  anchor_column="${anchor_position#*:}"
  discovery_line="${discovery_position%%:*}"
  discovery_column="${discovery_position#*:}"
  if [[ "$anchor_line" -gt "$discovery_line" ]] || \
    { [[ "$anchor_line" -eq "$discovery_line" ]] && [[ "$anchor_column" -ge "$discovery_column" ]]; }; then
    report_failure "RB-CONFORMANCE-PREFLIGHT-ANCHOR-MISSING" "$relative_path" "preflight-does-not-precede-discovery"
  fi
}

check_classifier() {
  local relative_path="agents/bubbles_shared/workflow-delegation-core.md"
  local file="$root/$relative_path"
  local section=""
  local line=""
  local found_targetless=0

  require_file "$relative_path" || return
  section="$(markdown_section "$file" "### Input Classification Contract")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-CLASSIFIER-MISSING" "$relative_path" "active-classification-section-absent"
    return
  fi

  while IFS= read -r line; do
    case "$line" in
      *"\`TARGETLESS_MODE\`"*) found_targetless=1 ;;
    esac
    if [[ "$line" == *"\`mode:\`"* && "$line" == *"\`STRUCTURED\`"* ]]; then
      case "$line" in
        *"not \`STRUCTURED\`"*|*"never \`STRUCTURED\`"*) ;;
        *without*concrete*target*|*'no concrete'*target*)
          report_failure "RB-CONFORMANCE-MODE-ONLY-STRUCTURED" "$relative_path" "active-mode-line-lacks-concrete-target"
          ;;
        *concrete*target*) ;;
        *)
          report_failure "RB-CONFORMANCE-MODE-ONLY-STRUCTURED" "$relative_path" "active-mode-line-lacks-concrete-target"
          ;;
      esac
    fi
  done <<< "$section"

  if [[ "$found_targetless" -ne 1 ]]; then
    report_failure "RB-CONFORMANCE-CLASSIFIER-MISSING" "$relative_path" "TARGETLESS_MODE-contract-absent"
  fi
}

check_scoped_discovery() {
  local relative_path="agents/bubbles_shared/workflow-execution-loops.md"
  local file="$root/$relative_path"
  local section=""
  local line=""

  require_file "$relative_path" || return
  section="$(markdown_section "$file" "#### Step 0: Pool Resolution")"
  if [[ -z "$section" ]]; then
    section="$(markdown_section "$file" "### Stochastic And Iterate Discovery")"
  fi
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "active-discovery-section-absent"
    return
  fi
  case "$section" in
    *'PREFLIGHT_COMMITTED'*) ;;
    *) report_failure "RB-CONFORMANCE-PREFLIGHT-ANCHOR-MISSING" "$relative_path" "PREFLIGHT_COMMITTED-absent" ;;
  esac
  case "$section" in
    *'repository-binding.sh discover-specs'*) ;;
    *) report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "discover-specs-anchor-absent" ;;
  esac
  case "$section" in
    *'resolvedRepositoryRoot/specs'*) ;;
    *) report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "resolved-root-scope-absent" ;;
  esac

  while IFS= read -r line; do
    if printf '%s\n' "$line" | grep -Eiq "(discover|scan|enumerate|pool).*(under|from|inside|across)?[[:space:]]*\`?specs/\`?"; then
      if ! printf '%s\n' "$line" | grep -Eiq 'resolvedRepositoryRoot|forbidden|never|must not|no raw|unqualified.*forbidden'; then
        report_failure "RB-CONFORMANCE-RAW-SPECS-DISCOVERY" "$relative_path" "active-unqualified-specs-discovery"
      fi
    fi
  done <<< "$section"
}

check_binding_fields() {
  local relative_path="$1"
  local file="$root/$relative_path"
  local section=""
  local field=""

  require_file "$relative_path" || return
  section="$(repository_binding_section "$file")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-BINDING-FIELDS-DROPPED" "$relative_path" "repository-binding-contract-section-absent"
    return
  fi

  for field in \
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
    repositoryResolution.actionable; do
    case "$section" in
      *"$field"*) ;;
      *)
        report_failure "RB-CONFORMANCE-BINDING-FIELDS-DROPPED" "$relative_path" "missing-field=$field"
        ;;
    esac
  done
}

ambient_signal_kind() {
  local line="$1"

  if printf '%s\n' "$line" | grep -Eiq '(first[[:space:]-]+(declared[[:space:]-]+)?(workspace[[:space:]-]+)?root|workspace[[:space:]-]+first[[:space:]-]+root)'; then
    printf '%s\n' 'first-root'
  elif printf '%s\n' "$line" | grep -Eiq '(workspace([[:space:]-]+declaration)?[[:space:]-]+order|workspace[[:space:]-]+folder[[:space:]-]+order|declaration[[:space:]-]+order)'; then
    printf '%s\n' 'workspace-order'
  elif printf '%s\n' "$line" | grep -Eiq '(recent[[:space:]-]+(work|activity|files?|file[[:space:]-]+access|repository)|most[[:space:]-]+recent[[:space:]-]+repository|last[[:space:]-]+(active|used|touched)[[:space:]-]+repository)'; then
    printf '%s\n' 'recent-work'
  elif printf '%s\n' "$line" | grep -Eiq '(chat|process|terminal)[[:space:]-]+CWD'; then
    printf '%s\n' 'chat-cwd'
  elif printf '%s\n' "$line" | grep -Eiq 'prompt[[:space:]-]+source'; then
    printf '%s\n' 'prompt-source'
  elif printf '%s\n' "$line" | grep -Eiq 'active[[:space:]-]+editor'; then
    printf '%s\n' 'active-editor'
  elif printf '%s\n' "$line" | grep -Eiq 'tool[[:space:]-]+CWD'; then
    printf '%s\n' 'tool-cwd'
  elif printf '%s\n' "$line" | grep -Eiq 'host[[:space:]-]+repository[[:space:]-]+metadata'; then
    printf '%s\n' 'host-repository-metadata'
  else
    return 1
  fi
}

ambient_line_grants_authority() {
  local line="$1"

  printf '%s\n' "$line" | grep -Eiq '(repository[[:space:]-]+authority|break(s|ing)?[[:space:]-]+ties|tie[[:space:]-]+breaker|select(s|ed|ing)?[[:space:]]+(a[[:space:]]+|the[[:space:]]+)?(work[[:space:]]+)?repository|choos(e|es|ing|en)[[:space:]]+(a[[:space:]]+|the[[:space:]]+)?(work[[:space:]]+)?repository|establish(es|ed|ing)?[^.]*authority|override(s|d|ing)?[^.]*authority|infer(s|red|ring)?[[:space:]]+(a[[:space:]]+|the[[:space:]]+)?(work[[:space:]]+)?repository)'
}

ambient_line_is_non_authorizing_context() {
  local line="$1"

  printf '%s\n' "$line" | grep -Eiq '(diagnostic-only|non-authoritative|never|cannot|must not|do not|does not|forbidden|prohibited|no authority|not (repository[[:space:]-]+)?authority|historical|historically|pre[[:space:]-]+implementation|legacy (behavior|defect)|former (behavior|implementation)|previous (behavior|implementation)|used to|rejected (design|alternative)|design (discussion|option|alternative)|anti[[:space:]-]+pattern|failure mode|incident (record|history|evidence|narrative))'
}

check_ambient_authority() {
  local relative_path="agents/bubbles_shared/operating-baseline.md"
  local file="$root/$relative_path"
  local section=""
  local line=""
  local signal_kind=""

  require_file "$relative_path" || return
  section="$(markdown_section "$file" "## Repository Authority Baseline")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-AMBIENT-AUTHORITY" "$relative_path" "repository-authority-section-absent"
    return
  fi

  while IFS= read -r line; do
    signal_kind="$(ambient_signal_kind "$line")"
    [[ -n "$signal_kind" ]] || continue
    ambient_line_grants_authority "$line" || continue
    ambient_line_is_non_authorizing_context "$line" && continue
    report_failure "RB-CONFORMANCE-AMBIENT-AUTHORITY" "$relative_path" \
      "ambient-signal-granted-authority signal=$signal_kind"
  done <<< "$section"
}

check_mode_contract() {
  local mode="$1"
  local relative_path="bubbles/workflows/modes.yaml"
  local file="$root/$relative_path"
  local section=""

  require_file "$relative_path" || return
  section="$(yaml_mode_section "$file" "$mode")"
  if [[ -z "$section" ]]; then
    report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "mode-missing=$mode"
    return
  fi
  case "$section" in
    *'autoDiscoverAllSpecs: true'*) ;;
    *) report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "auto-discovery-missing=$mode" ;;
  esac
  case "$section" in
    *'repositoryPreflightRequired: true'*) ;;
    *) report_failure "RB-CONFORMANCE-PREFLIGHT-ANCHOR-MISSING" "$relative_path" "preflight-contract-missing=$mode" ;;
  esac
  case "$section" in
    *'discoveryScope: resolvedRepositoryRoot/specs'*) ;;
    *) report_failure "RB-CONFORMANCE-DISCOVERY-CONTRACT-MISSING" "$relative_path" "resolved-scope-missing=$mode" ;;
  esac
}

check_classifier
check_scoped_discovery
check_discovery_order "agents/bubbles_shared/workflow-input-bootstrap.md"
check_discovery_order "agents/bubbles_shared/workflow-execution-loops.md"
check_discovery_order "agents/bubbles_shared/workflow-phase-engine.md"
check_front_door_order "agents/bubbles.workflow.agent.md" "## Execution Model"
check_front_door_order "agents/bubbles.iterate.agent.md" "## Execution Flow"
check_super_prebinding_input
check_binding_fields "agents/bubbles_shared/workflow-input-bootstrap.md"
check_binding_fields "agents/bubbles_shared/workflow-phase-engine.md"
check_exact_binding_section "agents/bubbles.recap.agent.md" "## CONTINUATION-ENVELOPE"
check_exact_binding_section "agents/bubbles.status.agent.md" "## CONTINUATION-ENVELOPE"
check_exact_binding_section "agents/bubbles.handoff.agent.md" '## Step 1: The "Handoff" Prompt'
check_exact_binding_section "agents/bubbles_shared/agent-common.md" "## Workflow-Only Continuation Convention (NON-NEGOTIABLE)"
check_result_binding_contract
check_direct_runners
check_scenario_repository_roots
check_goal_node_contract "agents/bubbles.goal.agent.md" "## Goal Scenario Compilation (Cross-Repo / Multi-Phase)"
check_goal_node_contract "agents/bubbles.sprint.agent.md" "## Sprint Scenario Execution (Cross-Repo / Multi-Phase Missions)"
check_ambient_authority
check_mode_contract "stochastic-quality-sweep"
check_mode_contract "iterate"

if [[ "$failures" -ne 0 ]]; then
  printf 'repository-binding-conformance-guard: FAIL failures=%s root=%s\n' "$failures" "$root" >&2
  exit 1
fi

printf 'repository-binding-conformance-guard: PASS scope=classification-discovery-front-doors-goal-nodes root=%s\n' "$root"