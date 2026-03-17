#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────
# bubbles — Lightweight CLI for Bubbles governance queries and script dispatch
# ────────────────────────────────────────────────────────────────────
# Project-agnostic. Works in any repo with specs/ and .github/scripts/.
#
# Usage:
#   bash .github/bubbles/scripts/cli.sh <command> [args...]
#
# Commands:
#   status                        Show all specs with status, mode, scope counts
#   specs [--range M-N] [--cat X] List/filter specs (categories: business, infra, all)
#   blocked                       Show only blocked specs with reasons
#   dod <spec>                    Show unchecked DoD items for a spec
#   session                       Show current session state
#   lint <spec>                   Run artifact lint on a spec
#   guard <spec>                  Run state transition guard on a spec
#   scan <spec>                   Run implementation reality scan on a spec
#   audit-done [--fix]            Audit all specs marked done
#   autofix <spec>                Scaffold missing report sections
#   sunnyvale <alias>             Resolve a Sunnyvale alias (agent or mode)
#   aliases                       List all Sunnyvale aliases
#   help                          Show this help message
#
# Spec argument formats:
#   027                           Resolves to specs/027-* (first match)
#   specs/027-feature-name        Full path
#   027-feature-name              Folder name
# ────────────────────────────────────────────────────────────────────

set -uo pipefail

# Source fun mode support
source "$(dirname "${BASH_SOURCE[0]}")/fun-mode.sh"

# Source alias resolution
source "$(dirname "${BASH_SOURCE[0]}")/aliases.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPECS_DIR="$REPO_ROOT/specs"
SESSION_FILE="$REPO_ROOT/.specify/memory/bubbles.session.json"

# ── Colors ──────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'
  DIM='\033[2m'; NC='\033[0m'
else
  GREEN='' YELLOW='' RED='' BLUE='' CYAN='' BOLD='' DIM='' NC=''
fi

# ── Helpers ─────────────────────────────────────────────────────────

die() { echo -e "${RED}Error:${NC} $*" >&2; exit 1; }

# Resolve a spec identifier to a directory path
resolve_spec() {
  local input="$1"

  # Already a valid path
  if [[ -d "$input" ]]; then echo "$input"; return 0; fi

  # Try specs/<input>
  if [[ -d "$SPECS_DIR/$input" ]]; then echo "$SPECS_DIR/$input"; return 0; fi

  # Try numeric prefix match: 027 → specs/027-*
  if [[ "$input" =~ ^[0-9]+$ ]]; then
    local padded
    padded=$(printf "%03d" "$input")
    local match
    match=$(find "$SPECS_DIR" -maxdepth 1 -type d -name "${padded}-*" 2>/dev/null | head -1)
    if [[ -n "$match" ]]; then echo "$match"; return 0; fi
  fi

  die "Cannot resolve spec: $input\nTry: number (027), name (027-feature), or path (specs/027-feature)"
}

# Extract a JSON string field value (simple grep-based, no jq dependency)
json_field() {
  local file="$1" field="$2"
  grep -oE "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]+\"" "$file" 2>/dev/null \
    | head -1 | sed -E 's/.*"([^"]+)"$/\1/' || true
}

# Classify a spec as business or infra by reading spec.md title/first lines
classify_spec() {
  local spec_dir="$1"
  local spec_file="$spec_dir/spec.md"
  if [[ ! -f "$spec_file" ]]; then echo "unknown"; return; fi

  local header
  header="$(head -15 "$spec_file" | tr '[:upper:]' '[:lower:]')"

  # Infrastructure keywords
  if echo "$header" | grep -qE 'docker|deploy|ci.?cd|monitoring|observability|migration.?tool|platform.?setup|config.?management|devops|infra|kubernetes|helm|terraform|github.?action|pipeline|setup|tooling|framework'; then
    echo "infra"
  else
    echo "business"
  fi
}

# ── Commands ────────────────────────────────────────────────────────

cmd_help() {
  cat << 'HELPEOF'
Usage: bubbles <command> [args...]

Commands:
  status                        Show all specs with status, mode, scope counts
  specs [--range M-N] [--cat X] List/filter specs
  blocked                       Show only blocked specs with reasons
  dod <spec>                    Show unchecked DoD items for a spec
  session                       Show current session state
  lint <spec>                   Run artifact lint on a spec
  guard <spec>                  Run state transition guard on a spec
  scan <spec>                   Run implementation reality scan on a spec
  audit-done [--fix]            Audit all specs marked done
  autofix <spec>                Scaffold missing report sections
  dag <spec>                    Show scope dependency graph (Mermaid)
  doctor [--heal]               Check project health, optionally auto-fix
  hooks <subcommand>            Manage git hooks (catalog|list|install|add|remove|run|status)
  project [gates <subcmd>]      Manage project extensions (bubbles-project.yaml)
  metrics <subcommand>          Manage metrics (enable|disable|status|summary)
  lessons [--all|compact]       View or compact lessons-learned memory
  upgrade [version] [--dry-run] Upgrade Bubbles to latest or specific version
  sunnyvale <alias>             Resolve a Sunnyvale alias
  aliases                       List all Sunnyvale aliases
  help                          Show this help message
HELPEOF
}

cmd_status() {
  bash "$SCRIPT_DIR/spec-dashboard.sh" "$SPECS_DIR"
}

cmd_specs() {
  local range_start="" range_end="" category="all"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --range)
        shift
        if [[ "$1" =~ ^([0-9]+)-([0-9]+)$ ]]; then
          range_start="${BASH_REMATCH[1]}"
          range_end="${BASH_REMATCH[2]}"
        else
          die "Invalid range format. Use: --range 4-49"
        fi
        ;;
      --cat|--category)
        shift
        category="$1"
        if [[ "$category" != "business" && "$category" != "infra" && "$category" != "all" ]]; then
          die "Invalid category. Use: business, infra, or all"
        fi
        ;;
      *) die "Unknown option: $1" ;;
    esac
    shift
  done

  printf "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"
  printf "${BLUE}  Bubbles Spec Inventory${NC}"
  [[ "$category" != "all" ]] && printf " ${DIM}(filter: %s)${NC}" "$category"
  [[ -n "$range_start" ]] && printf " ${DIM}(range: %03d-%03d)${NC}" "$range_start" "$range_end"
  printf "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n\n"

  printf "%-6s %-38s %-14s %-10s\n" "ID" "NAME" "STATUS" "CATEGORY"
  printf "%-6s %-38s %-14s %-10s\n" "──" "────" "──────" "────────"

  local count=0
  local shown=0

  for spec_dir in $(find "$SPECS_DIR" -maxdepth 1 -mindepth 1 -type d | sort); do
    local name
    name="$(basename "$spec_dir")"

    # Extract numeric ID
    local num_str="${name%%-*}"
    if [[ ! "$num_str" =~ ^[0-9]+$ ]]; then continue; fi
    local num=$((10#$num_str))

    # Range filter
    if [[ -n "$range_start" ]]; then
      if (( num < 10#$range_start || num > 10#$range_end )); then continue; fi
    fi

    # Category filter
    local cat
    cat="$(classify_spec "$spec_dir")"
    if [[ "$category" != "all" && "$cat" != "$category" ]]; then continue; fi

    # Status
    local status="-"
    if [[ -f "$spec_dir/state.json" ]]; then
      status="$(json_field "$spec_dir/state.json" "status")"
      [[ -z "$status" ]] && status="-"
    fi

    # Color status
    local status_display
    case "$status" in
      done) status_display="${GREEN}done${NC}" ;;
      in_progress) status_display="${YELLOW}in_progress${NC}" ;;
      blocked) status_display="${RED}blocked${NC}" ;;
      *) status_display="$status" ;;
    esac

    # Color category
    local cat_display
    case "$cat" in
      business) cat_display="${CYAN}business${NC}" ;;
      infra) cat_display="${DIM}infra${NC}" ;;
      *) cat_display="$cat" ;;
    esac

    printf "%-6s %-38s %-14b %-10b\n" "$num_str" "${name#*-}" "$status_display" "$cat_display"
    ((shown++))
    ((count++))
  done

  printf "\n${DIM}Showing %d specs${NC}\n\n" "$shown"
}

cmd_blocked() {
  printf "\n${RED}${BOLD}Blocked Specs${NC}\n"
  printf "%-40s %-60s\n" "SPEC" "REASON"
  printf "%-40s %-60s\n" "────" "──────"

  local found=0

  for state_file in $(find "$SPECS_DIR" -maxdepth 2 -name "state.json" -not -path "*/bugs/*" | sort); do
    local status
    status="$(json_field "$state_file" "status")"
    if [[ "$status" != "blocked" ]]; then continue; fi

    local spec_dir spec_name
    spec_dir="$(dirname "$state_file")"
    spec_name="$(basename "$spec_dir")"

    # Try to extract block reason from failures array or blockedReason field
    local reason
    reason="$(json_field "$state_file" "blockedReason")"
    if [[ -z "$reason" ]]; then
      reason="$(grep -oE '"reason"[[:space:]]*:[[:space:]]*"[^"]+"' "$state_file" 2>/dev/null | tail -1 | sed -E 's/.*"([^"]+)"$/\1/' || echo "-")"
    fi

    # Truncate reason
    if [[ ${#reason} -gt 58 ]]; then
      reason="${reason:0:55}..."
    fi

    printf "%-40s %-60s\n" "$spec_name" "$reason"
    ((found++))
  done

  if [[ "$found" -eq 0 ]]; then
    printf "${GREEN}  No blocked specs!${NC}\n"
  fi
  echo
}

cmd_dod() {
  [[ $# -lt 1 ]] && die "Usage: bubbles dod <spec>"

  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  local spec_name
  spec_name="$(basename "$spec_dir")"

  printf "\n${BOLD}Unchecked DoD items for ${CYAN}%s${NC}\n\n" "$spec_name"

  local found_unchecked=0

  # Check scopes.md
  if [[ -f "$spec_dir/scopes.md" ]]; then
    local unchecked
    unchecked="$(grep -n '^\- \[ \]' "$spec_dir/scopes.md" 2>/dev/null || true)"
    if [[ -n "$unchecked" ]]; then
      printf "${DIM}From scopes.md:${NC}\n"
      echo "$unchecked" | while IFS= read -r line; do
        local linenum="${line%%:*}"
        local content="${line#*:}"
        printf "  ${YELLOW}L%-4s${NC} %s\n" "$linenum" "$content"
      done
      found_unchecked=1
    fi
  fi

  # Check per-scope directories
  if [[ -d "$spec_dir/scopes" ]]; then
    for scope_file in $(find "$spec_dir/scopes" -name "scope.md" | sort); do
      local scope_rel="${scope_file#$spec_dir/}"
      local unchecked
      unchecked="$(grep -n '^\- \[ \]' "$scope_file" 2>/dev/null || true)"
      if [[ -n "$unchecked" ]]; then
        printf "${DIM}From %s:${NC}\n" "$scope_rel"
        echo "$unchecked" | while IFS= read -r line; do
          local linenum="${line%%:*}"
          local content="${line#*:}"
          printf "  ${YELLOW}L%-4s${NC} %s\n" "$linenum" "$content"
        done
        found_unchecked=1
      fi
    done
  fi

  # Check bug scopes
  if [[ -d "$spec_dir/bugs" ]]; then
    for bug_scope in $(find "$spec_dir/bugs" -name "scopes.md" | sort); do
      local bug_rel="${bug_scope#$spec_dir/}"
      local unchecked
      unchecked="$(grep -n '^\- \[ \]' "$bug_scope" 2>/dev/null || true)"
      if [[ -n "$unchecked" ]]; then
        printf "${DIM}From %s:${NC}\n" "$bug_rel"
        echo "$unchecked" | while IFS= read -r line; do
          local linenum="${line%%:*}"
          local content="${line#*:}"
          printf "  ${YELLOW}L%-4s${NC} %s\n" "$linenum" "$content"
        done
        found_unchecked=1
      fi
    done
  fi

  if [[ "$found_unchecked" -eq 0 ]]; then
    printf "${GREEN}  All DoD items are checked!${NC}\n"
  fi

  # Summary counts
  local total checked unchecked_count
  total=0; checked=0; unchecked_count=0
  for f in $(find "$spec_dir" -name "scopes.md" -o -name "scope.md" | grep -v node_modules); do
    local t c u
    t="$(grep -c '^\- \[' "$f" 2>/dev/null || echo 0)"
    c="$(grep -c '^\- \[x\]' "$f" 2>/dev/null || echo 0)"
    u="$(grep -c '^\- \[ \]' "$f" 2>/dev/null || echo 0)"
    total=$((total + t))
    checked=$((checked + c))
    unchecked_count=$((unchecked_count + u))
  done

  printf "\n${DIM}Total: %d items | ${GREEN}%d checked${NC}${DIM} | ${YELLOW}%d unchecked${NC}\n\n" "$total" "$checked" "$unchecked_count"
}

cmd_session() {
  if [[ ! -f "$SESSION_FILE" ]]; then
    printf "${DIM}No active session found at %s${NC}\n" "$SESSION_FILE"
    return 0
  fi

  printf "\n${BLUE}${BOLD}Bubbles Session State${NC}\n"
  printf "${BLUE}───────────────────────────────────────${NC}\n"

  local session_id agent feature status phase last_updated
  session_id="$(json_field "$SESSION_FILE" "sessionId")"
  agent="$(json_field "$SESSION_FILE" "agent")"
  feature="$(json_field "$SESSION_FILE" "featureDir")"
  status="$(json_field "$SESSION_FILE" "status")"
  phase="$(json_field "$SESSION_FILE" "currentPhase")"
  last_updated="$(json_field "$SESSION_FILE" "lastUpdatedAt")"

  # Color status
  local status_display
  case "$status" in
    done) status_display="${GREEN}$status${NC}" ;;
    blocked) status_display="${RED}$status${NC}" ;;
    *) status_display="${YELLOW}$status${NC}" ;;
  esac

  printf "  %-16s %s\n" "Session:" "$session_id"
  printf "  %-16s %s\n" "Agent:" "$agent"
  printf "  %-16s %s\n" "Feature:" "$feature"
  printf "  %-16s %b\n" "Status:" "$status_display"
  printf "  %-16s %s\n" "Phase:" "$phase"
  printf "  %-16s %s\n" "Last Updated:" "$last_updated"

  # Show resume info if available
  local resume_agent resume_note
  resume_agent="$(json_field "$SESSION_FILE" "recommendedAgent")"
  resume_note="$(grep -oE '"note"[[:space:]]*:[[:space:]]*"[^"]+"' "$SESSION_FILE" 2>/dev/null | tail -1 | sed -E 's/.*"([^"]+)"$/\1/' || true)"

  if [[ -n "$resume_agent" ]]; then
    printf "\n  ${BOLD}Resume:${NC}\n"
    printf "  %-16s %s\n" "Agent:" "$resume_agent"
    [[ -n "$resume_note" ]] && printf "  %-16s %s\n" "Note:" "$resume_note"
  fi

  # Show failure count
  local failure_count
  failure_count="$(grep -c '"phase"' "$SESSION_FILE" 2>/dev/null || echo "0")"
  if [[ "$failure_count" -gt 0 ]]; then
    printf "\n  ${DIM}Recorded failures: %d${NC}\n" "$failure_count"
  fi

  echo
}

cmd_lint() {
  [[ $# -lt 1 ]] && die "Usage: bubbles lint <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  bash "$SCRIPT_DIR/artifact-lint.sh" "$spec_dir"
}

cmd_guard() {
  [[ $# -lt 1 ]] && die "Usage: bubbles guard <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  bash "$SCRIPT_DIR/state-transition-guard.sh" "$spec_dir"
}

cmd_scan() {
  [[ $# -lt 1 ]] && die "Usage: bubbles scan <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  local verbose=""
  [[ "${2:-}" == "--verbose" || "${2:-}" == "-v" ]] && verbose="--verbose"
  bash "$SCRIPT_DIR/implementation-reality-scan.sh" "$spec_dir" $verbose
}

cmd_audit_done() {
  local fix_flag=""
  [[ "${1:-}" == "--fix" ]] && fix_flag="--fix"
  bash "$SCRIPT_DIR/done-spec-audit.sh" $fix_flag
}

cmd_autofix() {
  [[ $# -lt 1 ]] && die "Usage: bubbles autofix <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  bash "$SCRIPT_DIR/report-section-autofix.sh" "$spec_dir" --write
}

cmd_sunnyvale() {
  [[ $# -lt 1 ]] && { list_all_aliases; return 0; }
  local alias="$1"
  if ! sunnyvale_lookup "$alias"; then
    die "Unknown Sunnyvale alias: $alias\nRun 'bubbles aliases' to see all aliases."
  fi
}

cmd_aliases() {
  list_all_aliases
}

# ── New v2 commands ─────────────────────────────────────────────────

cmd_dag() {
  local spec_dir
  spec_dir=$(resolve_spec "${1:?Usage: bubbles dag <spec>}")

  echo '```mermaid'
  echo 'graph TD'

  local scope_files=()
  if [[ -f "$spec_dir/scopes.md" ]]; then
    scope_files=("$spec_dir/scopes.md")
  elif [[ -d "$spec_dir/scopes" ]]; then
    for sf in "$spec_dir"/scopes/*/scope.md; do
      [[ -f "$sf" ]] && scope_files+=("$sf")
    done
  fi

  for sf in "${scope_files[@]}"; do
    local scope_id scope_name scope_status depends_on status_icon
    scope_id=$(grep -oE '^## (Scope [0-9]+|[0-9]+-[a-z][-a-z0-9]*)' "$sf" | head -1 | sed 's/## //')
    scope_name=$(grep -E '^## ' "$sf" | head -1 | sed 's/^## //' | sed 's/ *(.*//')
    scope_status=$(grep -oE 'Status: (Done|In Progress|Not Started|Blocked)' "$sf" | head -1 | sed 's/Status: //')
    depends_on=$(grep -oE 'Depends On:.*' "$sf" | head -1 | sed 's/Depends On: *//')

    case "$scope_status" in
      Done)         status_icon="✅" ;;
      "In Progress") status_icon="🔄" ;;
      Blocked)      status_icon="🚫" ;;
      *)            status_icon="⏳" ;;
    esac

    local node_id
    node_id=$(echo "$scope_id" | tr -cd '[:alnum:]')
    echo "  ${node_id}[${scope_id} ${status_icon}]"

    if [[ -n "$depends_on" && "$depends_on" != "None" && "$depends_on" != "none" ]]; then
      for dep in $(echo "$depends_on" | tr ',' ' '); do
        local dep_id
        dep_id=$(echo "$dep" | tr -cd '[:alnum:]')
        echo "  ${dep_id} --> ${node_id}"
      done
    fi
  done

  echo '```'
}

cmd_doctor() {
  local heal=false
  for arg in "$@"; do
    [[ "$arg" == "--heal" ]] && heal=true
  done

  local passed=0 failed=0 healed=0

  echo ""
  echo -e "${BLUE}🫧 Bubbles Doctor — Project Health Check${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════${NC}"
  echo ""

  # Check 1: Core agents
  local agent_count
  agent_count=$(ls "$REPO_ROOT/.github/agents/bubbles."*.agent.md 2>/dev/null | wc -l)
  if [[ "$agent_count" -ge 25 ]]; then
    echo -e "  ${GREEN}✅${NC} Core agents installed (${agent_count})"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} Core agents: expected ≥25, found ${agent_count}"
    failed=$((failed + 1))
  fi

  # Check 2: Governance scripts
  local script_count
  script_count=$(ls "$REPO_ROOT/.github/bubbles/scripts/"*.sh 2>/dev/null | wc -l)
  if [[ "$script_count" -ge 10 ]]; then
    echo -e "  ${GREEN}✅${NC} Governance scripts installed (${script_count})"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} Scripts: expected ≥10, found ${script_count}"
    failed=$((failed + 1))
  fi

  # Check 3: workflows.yaml
  if [[ -f "$REPO_ROOT/.github/bubbles/workflows.yaml" ]]; then
    echo -e "  ${GREEN}✅${NC} Workflow config present"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} workflows.yaml missing"
    failed=$((failed + 1))
  fi

  # Check 4: Project config files
  local config_ok=true
  for cfg in .github/copilot-instructions.md .specify/memory/constitution.md .specify/memory/agents.md; do
    if [[ ! -f "$REPO_ROOT/$cfg" ]]; then
      echo -e "  ${RED}❌${NC} Missing: $cfg"
      config_ok=false
      failed=$((failed + 1))
    fi
  done
  if [[ "$config_ok" == "true" ]]; then
    echo -e "  ${GREEN}✅${NC} Project config files exist"
    passed=$((passed + 1))
  fi

  # Check 5: TODO markers
  local todo_count=0
  for cfg in .github/copilot-instructions.md .specify/memory/agents.md; do
    if [[ -f "$REPO_ROOT/$cfg" ]]; then
      local c
      c=$(grep -c 'TODO' "$REPO_ROOT/$cfg" 2>/dev/null || echo 0)
      todo_count=$((todo_count + c))
    fi
  done
  if [[ "$todo_count" -eq 0 ]]; then
    echo -e "  ${GREEN}✅${NC} No unfilled TODO markers"
    passed=$((passed + 1))
  else
    echo -e "  ${YELLOW}⚠️${NC}  $todo_count unfilled TODO items in project config"
  fi

  # Check 6: Script permissions
  local unexec=0
  for s in "$REPO_ROOT/.github/bubbles/scripts/"*.sh; do
    [[ -f "$s" && ! -x "$s" ]] && unexec=$((unexec + 1))
  done
  if [[ "$unexec" -eq 0 ]]; then
    echo -e "  ${GREEN}✅${NC} All scripts executable"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} $unexec scripts not executable"
    if [[ "$heal" == "true" ]]; then
      chmod +x "$REPO_ROOT/.github/bubbles/scripts/"*.sh
      echo -e "  ${GREEN}🔧${NC} Fixed: chmod +x on all scripts"
      healed=$((healed + 1))
    fi
    failed=$((failed + 1))
  fi

  # Check 7: Specs directory
  if [[ -d "$SPECS_DIR" ]]; then
    echo -e "  ${GREEN}✅${NC} specs/ directory exists"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} specs/ directory missing"
    if [[ "$heal" == "true" ]]; then
      mkdir -p "$SPECS_DIR"
      echo -e "  ${GREEN}🔧${NC} Created specs/"
      healed=$((healed + 1))
    fi
    failed=$((failed + 1))
  fi

  # Check 8: Version stamp
  if [[ -f "$REPO_ROOT/.github/bubbles/.version" ]]; then
    local ver
    ver=$(cat "$REPO_ROOT/.github/bubbles/.version")
    echo -e "  ${GREEN}✅${NC} Bubbles version: $ver"
    passed=$((passed + 1))
  else
    echo -e "  ${YELLOW}⚠️${NC}  No version stamp found"
  fi

  # Check 9: Custom gate scripts
  local project_config="$REPO_ROOT/.github/bubbles-project.yaml"
  if [[ -f "$project_config" ]]; then
    local gate_ok=true
    while IFS= read -r line; do
      local spath
      spath=$(echo "$line" | sed 's/.*script:\s*//' | tr -d '[:space:]')
      [[ -z "$spath" ]] && continue
      if [[ ! -x "$REPO_ROOT/.github/$spath" ]]; then
        echo -e "  ${RED}❌${NC} Custom gate script missing/not executable: .github/$spath"
        gate_ok=false
        failed=$((failed + 1))
      fi
    done < <(grep "script:" "$project_config")
    if [[ "$gate_ok" == "true" ]]; then
      echo -e "  ${GREEN}✅${NC} Custom gate scripts present"
      passed=$((passed + 1))
    fi
  fi

  echo ""
  echo -e "${BOLD}Result: $passed passed, $failed failed"
  if [[ "$healed" -gt 0 ]]; then
    echo -e "  🔧 Auto-healed $healed issue(s)${NC}"
  fi
  echo ""

  [[ "$failed" -eq 0 ]]
}

cmd_hooks() {
  local subcmd="${1:-status}"
  shift 2>/dev/null || true

  local hooks_json="$REPO_ROOT/.github/bubbles/hooks.json"
  local git_hooks_dir
  git_hooks_dir="$(cd "$REPO_ROOT" && git rev-parse --git-dir 2>/dev/null)/hooks"

  case "$subcmd" in
    catalog)
      echo "Built-in hooks available:"
      echo "  artifact-lint       pre-commit   Fast artifact lint on staged spec files"
      echo "  guard-done-specs    pre-push     State transition guard on done specs"
      echo "  reality-scan        pre-push     Implementation reality scan on changed specs"
      ;;

    list)
      if [[ -f "$hooks_json" ]]; then
        echo "Installed hooks (from hooks.json):"
        cat "$hooks_json"
      else
        echo "No hooks installed. Run: bubbles hooks install --all"
      fi
      ;;

    install)
      mkdir -p "$(dirname "$hooks_json")"
      local hook_name="${1:-}"

      if [[ "$hook_name" == "--all" || -z "$hook_name" ]]; then
        # Install all built-in hooks
        cat > "$hooks_json" << 'HJEOF'
{
  "pre-commit": [
    {"name": "artifact-lint", "type": "builtin"}
  ],
  "pre-push": [
    {"name": "guard-done-specs", "type": "builtin"},
    {"name": "reality-scan", "type": "builtin"}
  ]
}
HJEOF
        _regenerate_hooks "$hooks_json" "$git_hooks_dir"
        echo "✅ All built-in hooks installed"
      else
        echo "Installing single hook: $hook_name (add to hooks.json manually for now)"
      fi
      ;;

    add)
      local hook_type="${1:?Usage: bubbles hooks add <pre-commit|pre-push> <script> --name <name>}"
      local script="${2:?Missing script path}"
      local name=""
      shift 2
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --name) name="$2"; shift 2 ;;
          *) shift ;;
        esac
      done
      [[ -z "$name" ]] && name=$(basename "$script" .sh)
      echo "Added custom hook: $name ($hook_type → $script)"
      echo "Note: Manually add to $hooks_json and run: bubbles hooks install"
      ;;

    remove)
      echo "Remove hook: $1 (manually edit $hooks_json and run: bubbles hooks install)"
      ;;

    run)
      local hook_type="${1:-pre-push}"
      if [[ -x "$git_hooks_dir/$hook_type" ]]; then
        echo "Running $hook_type hook..."
        bash "$git_hooks_dir/$hook_type"
      else
        echo "No $hook_type hook installed."
      fi
      ;;

    status)
      echo "Git hooks directory: $git_hooks_dir"
      for ht in pre-commit pre-push; do
        if [[ -x "$git_hooks_dir/$ht" ]] && grep -q 'Generated by.*bubbles' "$git_hooks_dir/$ht" 2>/dev/null; then
          echo "  $ht: ✅ installed (Bubbles-managed)"
        elif [[ -x "$git_hooks_dir/$ht" ]]; then
          echo "  $ht: ⚠️  installed (NOT Bubbles-managed)"
        else
          echo "  $ht: ❌ not installed"
        fi
      done
      ;;

    *) die "Unknown hooks subcommand: $subcmd. Try: catalog, list, install, add, remove, run, status" ;;
  esac
}

_regenerate_hooks() {
  local hooks_json="$1" git_hooks_dir="$2"
  mkdir -p "$git_hooks_dir"

  # Generate pre-commit hook
  cat > "$git_hooks_dir/pre-commit" << 'PCHOOK'
#!/usr/bin/env bash
# Generated by: bubbles.sh hooks install
set -uo pipefail
failed=0
if git diff --cached --name-only | grep -q '^specs/'; then
  echo "🫧 Bubbles pre-commit: artifact lint on staged specs..."
  for spec_dir in $(git diff --cached --name-only | grep '^specs/' | sed 's|/[^/]*$||' | sort -u); do
    if [[ -d "$spec_dir" && -f "$spec_dir/state.json" ]]; then
      bash .github/bubbles/scripts/artifact-lint.sh "$spec_dir" --quick || failed=1
    fi
  done
fi
exit $failed
PCHOOK
  chmod +x "$git_hooks_dir/pre-commit"

  # Generate pre-push hook
  cat > "$git_hooks_dir/pre-push" << 'PPHOOK'
#!/usr/bin/env bash
# Generated by: bubbles.sh hooks install
set -uo pipefail
cat >/dev/null || true
echo "🫧 Bubbles pre-push: validating done specs..."
failed=0
for state_file in $(find specs -maxdepth 2 -name "state.json" -not -path "*/bugs/*" 2>/dev/null); do
  status=$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  if [[ "$status" == "done" ]]; then
    spec_dir=$(dirname "$state_file")
    bash .github/bubbles/scripts/state-transition-guard.sh "$spec_dir" || failed=1
  fi
done
[[ $failed -ne 0 ]] && { echo "❌ Pre-push blocked."; exit 1; }
echo "✅ All done specs validated."
PPHOOK
  chmod +x "$git_hooks_dir/pre-push"
}

cmd_project() {
  local subcmd="${1:-}"
  shift 2>/dev/null || true

  local project_yaml="$REPO_ROOT/.github/bubbles-project.yaml"

  case "$subcmd" in
    ""|gates)
      local gates_subcmd="${1:-list}"
      shift 2>/dev/null || true

      case "$gates_subcmd" in
        list|"")
          if [[ -f "$project_yaml" ]]; then
            echo "Project-defined gates (from .github/bubbles-project.yaml):"
            grep -E '^\s+\S+:$|script:|blocking:|description:' "$project_yaml" 2>/dev/null || echo "  (none)"
          else
            echo "No project gates defined. Create .github/bubbles-project.yaml to add custom gates."
          fi
          ;;
        add)
          local name="${1:?Usage: bubbles project gates add <name> --script <path> [--blocking] [--description <desc>]}"
          shift
          local script="" blocking="false" description=""
          while [[ $# -gt 0 ]]; do
            case "$1" in
              --script) script="$2"; shift 2 ;;
              --blocking) blocking="true"; shift ;;
              --description) description="$2"; shift 2 ;;
              *) shift ;;
            esac
          done
          [[ -z "$script" ]] && die "Missing --script argument"

          if [[ ! -f "$project_yaml" ]]; then
            echo "gates:" > "$project_yaml"
          fi

          cat >> "$project_yaml" << GATEEOF
  $name:
    script: $script
    blocking: $blocking
    description: $description
GATEEOF
          echo "✅ Added gate: $name → $script (blocking=$blocking)"
          ;;
        remove)
          echo "Remove gate: $1 (manually edit $project_yaml for now)"
          ;;
        test)
          local name="${1:?Usage: bubbles project gates test <name>}"
          local spath
          spath=$(grep -A2 "^  ${name}:" "$project_yaml" | grep 'script:' | sed 's/.*script:\s*//' | tr -d '[:space:]')
          if [[ -n "$spath" && -x "$REPO_ROOT/.github/$spath" ]]; then
            echo "Testing gate: $name ($spath)..."
            bash "$REPO_ROOT/.github/$spath" && echo "✅ PASSED" || echo "❌ FAILED"
          else
            die "Gate script not found or not executable: $spath"
          fi
          ;;
        *) die "Unknown gates subcommand: $gates_subcmd" ;;
      esac
      ;;
    *) die "Unknown project subcommand: $subcmd. Try: gates" ;;
  esac
}

cmd_metrics() {
  local subcmd="${1:-status}"
  local config_file="$REPO_ROOT/.specify/memory/bubbles.config.json"
  local metrics_dir="$REPO_ROOT/.specify/metrics"
  local metrics_file="$metrics_dir/events.jsonl"

  case "$subcmd" in
    enable)
      mkdir -p "$metrics_dir" "$(dirname "$config_file")"
      echo '{"metrics": true}' > "$config_file"
      echo "✅ Metrics enabled. Events will be logged to $metrics_file"
      ;;
    disable)
      if [[ -f "$config_file" ]]; then
        echo '{"metrics": false}' > "$config_file"
      fi
      echo "✅ Metrics disabled. Existing data preserved."
      ;;
    status)
      if [[ -f "$config_file" ]] && grep -q '"metrics".*true' "$config_file" 2>/dev/null; then
        local count=0
        [[ -f "$metrics_file" ]] && count=$(wc -l < "$metrics_file")
        echo "Metrics: ENABLED ($count events collected)"
      else
        echo "Metrics: DISABLED (run: bubbles metrics enable)"
      fi
      ;;
    summary)
      if [[ ! -f "$metrics_file" ]]; then
        echo "No metrics data. Enable with: bubbles metrics enable"
        return
      fi
      echo "Metrics Summary:"
      echo "  Total events: $(wc -l < "$metrics_file")"
      echo "  Gate checks: $(grep -c '"type":"gate_check"' "$metrics_file" 2>/dev/null || echo 0)"
      echo "  Phase completions: $(grep -c '"type":"phase_complete"' "$metrics_file" 2>/dev/null || echo 0)"
      ;;
    gates)
      if [[ ! -f "$metrics_file" ]]; then echo "No data."; return; fi
      echo "Gate failure frequency:"
      grep '"type":"gate_check".*"result":"fail"' "$metrics_file" 2>/dev/null \
        | grep -oE '"gate":"[^"]*"' | sort | uniq -c | sort -rn || echo "  No failures recorded"
      ;;
    agents)
      if [[ ! -f "$metrics_file" ]]; then echo "No data."; return; fi
      echo "Agent invocations:"
      grep '"type":"phase_complete"' "$metrics_file" 2>/dev/null \
        | grep -oE '"agent":"[^"]*"' | sort | uniq -c | sort -rn || echo "  No invocations recorded"
      ;;
    *) die "Unknown metrics subcommand: $subcmd. Try: enable, disable, status, summary, gates, agents" ;;
  esac
}

cmd_lessons() {
  local lessons_file="$REPO_ROOT/.specify/memory/lessons.md"
  local subcmd="${1:-}"

  case "$subcmd" in
    compact)
      if [[ ! -f "$lessons_file" ]]; then
        echo "No lessons file found."
        return
      fi
      local line_count
      line_count=$(wc -l < "$lessons_file")
      echo "Compacting lessons.md ($line_count lines)..."
      # Simple compaction: keep last 150 lines
      if [[ "$line_count" -gt 150 ]]; then
        local archive_file="$REPO_ROOT/.specify/memory/lessons-archive.md"
        local cut_at=$((line_count - 150))
        head -n "$cut_at" "$lessons_file" >> "$archive_file"
        tail -n 150 "$lessons_file" > "$lessons_file.tmp"
        mv "$lessons_file.tmp" "$lessons_file"
        echo "✅ Archived $cut_at lines to lessons-archive.md. Kept 150 lines."
      else
        echo "✅ File is under 150 lines, no compaction needed."
      fi
      ;;
    --all)
      if [[ -f "$lessons_file" ]]; then
        cat "$lessons_file"
      else
        echo "No lessons recorded yet."
      fi
      ;;
    "")
      if [[ -f "$lessons_file" ]]; then
        tail -50 "$lessons_file"
      else
        echo "No lessons recorded yet."
      fi
      ;;
    *) die "Unknown lessons subcommand: $subcmd. Try: compact, --all, or no argument for recent" ;;
  esac
}

cmd_upgrade() {
  local target_version="${1:-main}"
  local dry_run=false
  for arg in "$@"; do
    [[ "$arg" == "--dry-run" ]] && dry_run=true
  done

  local repo="pkirsanov/bubbles"
  echo "🫧 Upgrading Bubbles to ${target_version}..."

  if [[ "$dry_run" == "true" ]]; then
    echo "[Dry run] Would download and install Bubbles ${target_version}"
    echo "[Dry run] Would overwrite: agents/bubbles.*, agents/bubbles_shared/*, bubbles/scripts/*, bubbles/workflows.yaml"
    echo "[Dry run] Would NOT touch: copilot-instructions.md, constitution.md, agents.md, bubbles-project.yaml, hooks.json"
    echo "[Dry run] Would regenerate: bubbles/docs/*"
    echo "[Dry run] Would check user-owned files for staleness"
    return
  fi

  # Download and run install.sh
  echo "Downloading installer..."
  curl -fsSL "https://raw.githubusercontent.com/${repo}/${target_version}/install.sh" | bash -s -- "$target_version"

  # Run doctor to validate
  echo ""
  cmd_doctor

  # Staleness recommendations
  echo ""
  echo "📋 Checking user-owned files for staleness..."
  local recs=0
  if [[ -f "$REPO_ROOT/.github/copilot-instructions.md" ]]; then
    local t
    t=$(grep -c 'TODO' "$REPO_ROOT/.github/copilot-instructions.md" 2>/dev/null || echo 0)
    if [[ "$t" -gt 0 ]]; then
      echo "  ⚠️  copilot-instructions.md has $t unfilled TODO items"
      recs=$((recs + 1))
    fi
  fi
  if [[ -f "$REPO_ROOT/.specify/memory/agents.md" ]]; then
    local t
    t=$(grep -c 'TODO' "$REPO_ROOT/.specify/memory/agents.md" 2>/dev/null || echo 0)
    if [[ "$t" -gt 0 ]]; then
      echo "  ⚠️  agents.md has $t unfilled TODO items"
      recs=$((recs + 1))
    fi
  fi
  if [[ "$recs" -eq 0 ]]; then
    echo "  ✅ No staleness issues found."
  else
    echo ""
    echo "ℹ️  These are recommendations, not errors. Your files were NOT modified."
  fi

  echo ""
  echo "✅ Upgrade complete."
  fun_summary pass
}

# ── Main dispatch ───────────────────────────────────────────────────

main() {
  if [[ $# -eq 0 ]]; then
    cmd_status
    return 0
  fi

  local command="$1"
  shift

  case "$command" in
    status|dashboard)   cmd_status "$@" ;;
    specs|list)         cmd_specs "$@" ;;
    blocked)            cmd_blocked "$@" ;;
    dod)                cmd_dod "$@" ;;
    session)            cmd_session "$@" ;;
    lint)               cmd_lint "$@" ;;
    guard)              cmd_guard "$@" ;;
    scan)               cmd_scan "$@" ;;
    audit-done|audit)   cmd_audit_done "$@" ;;
    autofix)            cmd_autofix "$@" ;;
    dag)                cmd_dag "$@" ;;
    doctor)             cmd_doctor "$@" ;;
    hooks)              cmd_hooks "$@" ;;
    project)            cmd_project "$@" ;;
    metrics)            cmd_metrics "$@" ;;
    lessons)            cmd_lessons "$@" ;;
    upgrade)            cmd_upgrade "$@" ;;
    sunnyvale)          cmd_sunnyvale "$@" ;;
    aliases)            cmd_aliases "$@" ;;
    help|-h|--help)     cmd_help ;;
    *)                  die "Unknown command: $command\nRun 'bubbles help' for usage." ;;
  esac
}

main "$@"
