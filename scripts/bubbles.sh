#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────
# bubbles — Lightweight CLI for Bubbles governance queries and script dispatch
# ────────────────────────────────────────────────────────────────────
# Project-agnostic. Works in any repo with specs/ and .github/scripts/.
#
# Usage:
#   bash .github/scripts/bubbles.sh <command> [args...]
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
#   help                          Show this help message
#
# Spec argument formats:
#   027                           Resolves to specs/027-* (first match)
#   specs/027-feature-name        Full path
#   027-feature-name              Folder name
# ────────────────────────────────────────────────────────────────────

set -uo pipefail

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
  sed -n '/^# Usage:/,/^# ─/p' "${BASH_SOURCE[0]}" | head -n -1 | sed 's/^# \?//'
}

cmd_status() {
  bash "$SCRIPT_DIR/bubbles-spec-dashboard.sh" "$SPECS_DIR"
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
  bash "$SCRIPT_DIR/bubbles-artifact-lint.sh" "$spec_dir"
}

cmd_guard() {
  [[ $# -lt 1 ]] && die "Usage: bubbles guard <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  bash "$SCRIPT_DIR/bubbles-state-transition-guard.sh" "$spec_dir"
}

cmd_scan() {
  [[ $# -lt 1 ]] && die "Usage: bubbles scan <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  local verbose=""
  [[ "${2:-}" == "--verbose" || "${2:-}" == "-v" ]] && verbose="--verbose"
  bash "$SCRIPT_DIR/bubbles-implementation-reality-scan.sh" "$spec_dir" $verbose
}

cmd_audit_done() {
  local fix_flag=""
  [[ "${1:-}" == "--fix" ]] && fix_flag="--fix"
  bash "$SCRIPT_DIR/bubbles-done-spec-audit.sh" $fix_flag
}

cmd_autofix() {
  [[ $# -lt 1 ]] && die "Usage: bubbles autofix <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  bash "$SCRIPT_DIR/bubbles-report-section-autofix.sh" "$spec_dir" --write
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
    help|-h|--help)     cmd_help ;;
    *)                  die "Unknown command: $command\nRun 'bubbles help' for usage." ;;
  esac
}

main "$@"
