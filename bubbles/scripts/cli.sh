#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────
# bubbles — Lightweight CLI for Bubbles governance queries and script dispatch
# ────────────────────────────────────────────────────────────────────
# Project-agnostic. Works in any repo with specs/ and bubbles/scripts/.
#
# Usage:
#   bash bubbles/scripts/cli.sh <command> [args...]
#
# Commands:
#   status                        Show all specs with status, mode, scope counts
#   specs [--range M-N] [--cat X] List/filter specs (categories: business, infra, all)
#   blocked                       Show only blocked specs with reasons
#   dod <spec>                    Show unchecked DoD items for a spec
#   policy <subcommand>           Manage control-plane defaults and provenance
#   session                       Show current session state
#   lint <spec>                   Run artifact lint on a spec
#   agnosticity [--staged]        Check portable Bubbles surfaces for drift
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
if [[ "$(basename "$(dirname "$SCRIPT_DIR")")" == "bubbles" && "$(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")" == ".github" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
  FRAMEWORK_DIR="$REPO_ROOT/.github/bubbles"
  AGENTS_DIR="$REPO_ROOT/.github/agents"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  FRAMEWORK_DIR="$REPO_ROOT/bubbles"
  AGENTS_DIR="$REPO_ROOT/agents"
fi
SPECS_DIR="$REPO_ROOT/specs"
SESSION_FILE="$REPO_ROOT/.specify/memory/bubbles.session.json"
CONTROL_PLANE_CONFIG="$REPO_ROOT/.specify/memory/bubbles.config.json"
CONTROL_PLANE_METRICS_DIR="$REPO_ROOT/.specify/metrics"
CONTROL_PLANE_METRICS_FILE="$CONTROL_PLANE_METRICS_DIR/events.jsonl"

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

is_framework_repo() {
  [[ "$SCRIPT_DIR" != *"/.github/bubbles/scripts" ]]
}

require_framework_repo_for_hooks() {
  if ! is_framework_repo; then
    die "Bubbles git hooks may only be installed in the Bubbles framework repo. Consumer repos should use Bubbles but must not install Bubbles-managed pre-commit/pre-push hooks."
  fi
}

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

default_control_plane_config() {
  cat << 'EOF'
{
  "version": 2,
  "defaults": {
    "grill": {
      "mode": "off",
      "source": "repo-default"
    },
    "tdd": {
      "mode": "scenario-first",
      "defaultForModes": ["bugfix-fastlane", "chaos-hardening"],
      "source": "repo-default"
    },
    "autoCommit": {
      "mode": "off",
      "source": "repo-default"
    },
    "lockdown": {
      "default": false,
      "requireGrillForInvalidation": true,
      "source": "repo-default"
    },
    "regression": {
      "immutability": "protected-scenarios",
      "source": "repo-default"
    },
    "validation": {
      "certificationRequired": true,
      "source": "repo-default"
    }
  },
  "modeOverrides": {
    "bugfix-fastlane": {
      "tdd": {
        "mode": "scenario-first",
        "source": "workflow-forced"
      }
    },
    "chaos-hardening": {
      "tdd": {
        "mode": "scenario-first",
        "source": "workflow-forced"
      }
    }
  },
  "metrics": {
    "enabled": false
  }
}
EOF
}

ensure_control_plane_config() {
  mkdir -p "$(dirname "$CONTROL_PLANE_CONFIG")" "$CONTROL_PLANE_METRICS_DIR"
  if [[ ! -f "$CONTROL_PLANE_CONFIG" ]]; then
    default_control_plane_config > "$CONTROL_PLANE_CONFIG"
  fi
}

config_string_value() {
  local section="$1"
  local key="$2"
  local default_value="$3"
  local file="$4"
  local value

  value="$({
    grep -A8 "\"$section\"" "$file" 2>/dev/null \
      | grep -m1 "\"$key\"" \
      | sed -E 's/.*:[[:space:]]*"([^"]+)".*/\1/'
  } || true)"

  if [[ -n "$value" ]]; then
    printf '%s' "$value"
  else
    printf '%s' "$default_value"
  fi
}

config_bool_value() {
  local section="$1"
  local key="$2"
  local default_value="$3"
  local file="$4"
  local value

  value="$({
    grep -A8 "\"$section\"" "$file" 2>/dev/null \
      | grep -m1 "\"$key\"" \
      | sed -E 's/.*:[[:space:]]*(true|false).*/\1/'
  } || true)"

  if [[ "$value" == "true" || "$value" == "false" ]]; then
    printf '%s' "$value"
  else
    printf '%s' "$default_value"
  fi
}

config_metrics_enabled_value() {
  local file="$1"
  local legacy_value
  local value

  legacy_value="$({
    grep -m1 -E '"metrics"[[:space:]]*:[[:space:]]*(true|false)' "$file" 2>/dev/null \
      | sed -E 's/.*:[[:space:]]*(true|false).*/\1/'
  } || true)"
  if [[ "$legacy_value" == "true" || "$legacy_value" == "false" ]]; then
    printf '%s' "$legacy_value"
    return 0
  fi

  value="$({
    grep -A3 '"metrics"' "$file" 2>/dev/null \
      | grep -m1 '"enabled"' \
      | sed -E 's/.*:[[:space:]]*(true|false).*/\1/'
  } || true)"
  if [[ "$value" == "true" || "$value" == "false" ]]; then
    printf '%s' "$value"
  else
    printf '%s' 'false'
  fi
}

load_control_plane_config() {
  ensure_control_plane_config

  CFG_GRILL_MODE="$(config_string_value grill mode off "$CONTROL_PLANE_CONFIG")"
  CFG_GRILL_SOURCE="$(config_string_value grill source repo-default "$CONTROL_PLANE_CONFIG")"
  CFG_TDD_MODE="$(config_string_value tdd mode scenario-first "$CONTROL_PLANE_CONFIG")"
  CFG_TDD_SOURCE="$(config_string_value tdd source repo-default "$CONTROL_PLANE_CONFIG")"
  CFG_AUTOCOMMIT_MODE="$(config_string_value autoCommit mode off "$CONTROL_PLANE_CONFIG")"
  CFG_AUTOCOMMIT_SOURCE="$(config_string_value autoCommit source repo-default "$CONTROL_PLANE_CONFIG")"
  CFG_LOCKDOWN_DEFAULT="$(config_bool_value lockdown default false "$CONTROL_PLANE_CONFIG")"
  CFG_LOCKDOWN_REQUIRE_GRILL="$(config_bool_value lockdown requireGrillForInvalidation true "$CONTROL_PLANE_CONFIG")"
  CFG_LOCKDOWN_SOURCE="$(config_string_value lockdown source repo-default "$CONTROL_PLANE_CONFIG")"
  CFG_REGRESSION_IMMUTABILITY="$(config_string_value regression immutability protected-scenarios "$CONTROL_PLANE_CONFIG")"
  CFG_REGRESSION_SOURCE="$(config_string_value regression source repo-default "$CONTROL_PLANE_CONFIG")"
  CFG_VALIDATION_CERT_REQUIRED="$(config_bool_value validation certificationRequired true "$CONTROL_PLANE_CONFIG")"
  CFG_VALIDATION_SOURCE="$(config_string_value validation source repo-default "$CONTROL_PLANE_CONFIG")"
  CFG_METRICS_ENABLED="$(config_metrics_enabled_value "$CONTROL_PLANE_CONFIG")"
}

save_control_plane_config() {
  local tmp_file="$CONTROL_PLANE_CONFIG.tmp"

  mkdir -p "$(dirname "$CONTROL_PLANE_CONFIG")" "$CONTROL_PLANE_METRICS_DIR"
  cat > "$tmp_file" << EOF
{
  "version": 2,
  "defaults": {
    "grill": {
      "mode": "$CFG_GRILL_MODE",
      "source": "$CFG_GRILL_SOURCE"
    },
    "tdd": {
      "mode": "$CFG_TDD_MODE",
      "defaultForModes": ["bugfix-fastlane", "chaos-hardening"],
      "source": "$CFG_TDD_SOURCE"
    },
    "autoCommit": {
      "mode": "$CFG_AUTOCOMMIT_MODE",
      "source": "$CFG_AUTOCOMMIT_SOURCE"
    },
    "lockdown": {
      "default": $CFG_LOCKDOWN_DEFAULT,
      "requireGrillForInvalidation": $CFG_LOCKDOWN_REQUIRE_GRILL,
      "source": "$CFG_LOCKDOWN_SOURCE"
    },
    "regression": {
      "immutability": "$CFG_REGRESSION_IMMUTABILITY",
      "source": "$CFG_REGRESSION_SOURCE"
    },
    "validation": {
      "certificationRequired": $CFG_VALIDATION_CERT_REQUIRED,
      "source": "$CFG_VALIDATION_SOURCE"
    }
  },
  "modeOverrides": {
    "bugfix-fastlane": {
      "tdd": {
        "mode": "scenario-first",
        "source": "workflow-forced"
      }
    },
    "chaos-hardening": {
      "tdd": {
        "mode": "scenario-first",
        "source": "workflow-forced"
      }
    }
  },
  "metrics": {
    "enabled": $CFG_METRICS_ENABLED
  }
}
EOF
  mv "$tmp_file" "$CONTROL_PLANE_CONFIG"
}

default_value_for_policy_path() {
  local path="$1"

  case "$path" in
    grill.mode) printf '%s' 'off' ;;
    grill.source) printf '%s' 'repo-default' ;;
    tdd.mode) printf '%s' 'scenario-first' ;;
    tdd.source) printf '%s' 'repo-default' ;;
    autoCommit.mode) printf '%s' 'off' ;;
    autoCommit.source) printf '%s' 'repo-default' ;;
    lockdown.default) printf '%s' 'false' ;;
    lockdown.requireGrillForInvalidation) printf '%s' 'true' ;;
    lockdown.source) printf '%s' 'repo-default' ;;
    regression.immutability) printf '%s' 'protected-scenarios' ;;
    regression.source) printf '%s' 'repo-default' ;;
    validation.certificationRequired) printf '%s' 'true' ;;
    validation.source) printf '%s' 'repo-default' ;;
    metrics.enabled) printf '%s' 'false' ;;
    bugfix-fastlane.tdd.mode|chaos-hardening.tdd.mode) printf '%s' 'scenario-first' ;;
    bugfix-fastlane.tdd.source|chaos-hardening.tdd.source) printf '%s' 'workflow-forced' ;;
    *) return 1 ;;
  esac
}

read_control_plane_setting() {
  local path="$1"

  case "$path" in
    grill.mode) printf '%s' "$CFG_GRILL_MODE" ;;
    grill.source) printf '%s' "$CFG_GRILL_SOURCE" ;;
    tdd.mode) printf '%s' "$CFG_TDD_MODE" ;;
    tdd.source) printf '%s' "$CFG_TDD_SOURCE" ;;
    autoCommit.mode) printf '%s' "$CFG_AUTOCOMMIT_MODE" ;;
    autoCommit.source) printf '%s' "$CFG_AUTOCOMMIT_SOURCE" ;;
    lockdown.default) printf '%s' "$CFG_LOCKDOWN_DEFAULT" ;;
    lockdown.requireGrillForInvalidation) printf '%s' "$CFG_LOCKDOWN_REQUIRE_GRILL" ;;
    lockdown.source) printf '%s' "$CFG_LOCKDOWN_SOURCE" ;;
    regression.immutability) printf '%s' "$CFG_REGRESSION_IMMUTABILITY" ;;
    regression.source) printf '%s' "$CFG_REGRESSION_SOURCE" ;;
    validation.certificationRequired) printf '%s' "$CFG_VALIDATION_CERT_REQUIRED" ;;
    validation.source) printf '%s' "$CFG_VALIDATION_SOURCE" ;;
    metrics.enabled) printf '%s' "$CFG_METRICS_ENABLED" ;;
    bugfix-fastlane.tdd.mode|chaos-hardening.tdd.mode) printf '%s' 'scenario-first' ;;
    bugfix-fastlane.tdd.source|chaos-hardening.tdd.source) printf '%s' 'workflow-forced' ;;
    *) return 1 ;;
  esac
}

validate_policy_source() {
  local source="$1"
  case "$source" in
    user-request|repo-default|workflow-forced|spec-lockdown) return 0 ;;
    *) die "Invalid policy source: $source. Allowed: user-request, repo-default, workflow-forced, spec-lockdown" ;;
  esac
}

validate_boolean_literal() {
  local value="$1"
  case "$value" in
    true|false) return 0 ;;
    *) die "Invalid boolean value: $value. Use true or false." ;;
  esac
}

validate_policy_value() {
  local path="$1"
  local value="$2"

  case "$path" in
    grill.mode)
      case "$value" in
        off|on-demand|required-on-ambiguity|required-for-lockdown) ;;
        *) die "Invalid grill.mode: $value" ;;
      esac
      ;;
    tdd.mode)
      case "$value" in
        scenario-first|off) ;;
        *) die "Invalid tdd.mode: $value" ;;
      esac
      ;;
    autoCommit.mode)
      case "$value" in
        off|scope|dod) ;;
        *) die "Invalid autoCommit.mode: $value" ;;
      esac
      ;;
    lockdown.default|lockdown.requireGrillForInvalidation|validation.certificationRequired|metrics.enabled)
      validate_boolean_literal "$value"
      ;;
    regression.immutability)
      case "$value" in
        protected-scenarios|mutable-by-spec-change) ;;
        *) die "Invalid regression.immutability: $value" ;;
      esac
      ;;
    grill.source|tdd.source|autoCommit.source|lockdown.source|regression.source|validation.source)
      validate_policy_source "$value"
      ;;
    bugfix-fastlane.tdd.mode|chaos-hardening.tdd.mode|bugfix-fastlane.tdd.source|chaos-hardening.tdd.source)
      die "Mode overrides are workflow-forced and read-only: $path"
      ;;
    *)
      die "Unknown policy path: $path"
      ;;
  esac
}

write_control_plane_setting() {
  local path="$1"
  local value="$2"

  case "$path" in
    grill.mode) CFG_GRILL_MODE="$value" ;;
    grill.source) CFG_GRILL_SOURCE="$value" ;;
    tdd.mode) CFG_TDD_MODE="$value" ;;
    tdd.source) CFG_TDD_SOURCE="$value" ;;
    autoCommit.mode) CFG_AUTOCOMMIT_MODE="$value" ;;
    autoCommit.source) CFG_AUTOCOMMIT_SOURCE="$value" ;;
    lockdown.default) CFG_LOCKDOWN_DEFAULT="$value" ;;
    lockdown.requireGrillForInvalidation) CFG_LOCKDOWN_REQUIRE_GRILL="$value" ;;
    lockdown.source) CFG_LOCKDOWN_SOURCE="$value" ;;
    regression.immutability) CFG_REGRESSION_IMMUTABILITY="$value" ;;
    regression.source) CFG_REGRESSION_SOURCE="$value" ;;
    validation.certificationRequired) CFG_VALIDATION_CERT_REQUIRED="$value" ;;
    validation.source) CFG_VALIDATION_SOURCE="$value" ;;
    metrics.enabled) CFG_METRICS_ENABLED="$value" ;;
    *) die "Unknown policy path: $path" ;;
  esac
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
  policy <subcommand>           Manage control-plane defaults (status|get|set|reset)
  session                       Show current session state
  lint <spec>                   Run artifact lint on a spec
  agnosticity [--staged]        Check portable Bubbles surfaces for drift
  guard <spec>                  Run state transition guard on a spec
  guard-selftest                Run the transition guard selftest suite
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

cmd_agnosticity() {
  bash "$SCRIPT_DIR/agnosticity-lint.sh" "$@"
}

cmd_guard() {
  [[ $# -lt 1 ]] && die "Usage: bubbles guard <spec>"
  local spec_dir
  spec_dir="$(resolve_spec "$1")"
  bash "$SCRIPT_DIR/state-transition-guard.sh" "$spec_dir"
}

cmd_guard_selftest() {
  bash "$SCRIPT_DIR/state-transition-guard-selftest.sh"
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
  agent_count=$(ls "$AGENTS_DIR/bubbles."*.agent.md 2>/dev/null | wc -l)
  if [[ "$agent_count" -ge 25 ]]; then
    echo -e "  ${GREEN}✅${NC} Core agents installed (${agent_count})"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} Core agents: expected ≥25, found ${agent_count}"
    failed=$((failed + 1))
  fi

  # Check 2: Governance scripts
  local script_count
  script_count=$(ls "$FRAMEWORK_DIR/scripts/"*.sh 2>/dev/null | wc -l)
  if [[ "$script_count" -ge 10 ]]; then
    echo -e "  ${GREEN}✅${NC} Governance scripts installed (${script_count})"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} Scripts: expected ≥10, found ${script_count}"
    failed=$((failed + 1))
  fi

  # Check 3: workflows.yaml
  if [[ -f "$FRAMEWORK_DIR/workflows.yaml" ]]; then
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

  # Check 4b: Control-plane bootstrap registry
  if [[ -f "$CONTROL_PLANE_CONFIG" ]]; then
    echo -e "  ${GREEN}✅${NC} Control-plane policy registry present (.specify/memory/bubbles.config.json)"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} Missing control-plane policy registry: .specify/memory/bubbles.config.json"
    echo -e "     ${DIM}Bootstrap-owned artifact. Do not create it manually.${NC}"
    echo -e "     ${DIM}Remediation: rerun install.sh with --bootstrap from the Bubbles repo.${NC}"
    echo -e "     ${DIM}Use /bubbles.setup mode: refresh for .github drift after bootstrap.${NC}"
    failed=$((failed + 1))
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
  for s in "$FRAMEWORK_DIR/scripts/"*.sh; do
    [[ -f "$s" && ! -x "$s" ]] && unexec=$((unexec + 1))
  done
  if [[ "$unexec" -eq 0 ]]; then
    echo -e "  ${GREEN}✅${NC} All scripts executable"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} $unexec scripts not executable"
    if [[ "$heal" == "true" ]]; then
      chmod +x "$FRAMEWORK_DIR/scripts/"*.sh
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
  if [[ -f "$FRAMEWORK_DIR/.version" ]]; then
    local ver
    ver=$(cat "$FRAMEWORK_DIR/.version")
    echo -e "  ${GREEN}✅${NC} Bubbles version: $ver"
    passed=$((passed + 1))
  else
    echo -e "  ${YELLOW}⚠️${NC}  No version stamp found"
  fi

  # Check 9: Custom gate scripts
  local project_config
  # Resolve project root: cli.sh lives at .github/bubbles/scripts/ — go up 3 levels
  local proj_root
  proj_root="$(cd "$SCRIPT_DIR/../../.." && pwd)"
  project_config="$proj_root/.github/bubbles-project.yaml"
  if [[ -f "$project_config" ]]; then
    local gate_ok=true
    local active_gate_count=0
    while IFS= read -r line; do
      local spath
      spath=$(echo "$line" | sed 's/.*script:\s*//' | tr -d '[:space:]')
      [[ -z "$spath" ]] && continue
      active_gate_count=$((active_gate_count + 1))
      if [[ ! -x "$REPO_ROOT/.github/$spath" ]]; then
        echo -e "  ${RED}❌${NC} Custom gate script missing/not executable: .github/$spath"
        gate_ok=false
        failed=$((failed + 1))
      fi
    done < <(grep -E '^[[:space:]]*script:' "$project_config")
    if [[ "$active_gate_count" -eq 0 ]]; then
      echo -e "  ${GREEN}✅${NC} No custom gate scripts defined"
      passed=$((passed + 1))
    elif [[ "$gate_ok" == "true" ]]; then
      echo -e "  ${GREEN}✅${NC} Custom gate scripts present"
      passed=$((passed + 1))
    fi
  fi

  # Check 10: Project scan config auto-generation
  if [[ ! -f "$project_config" ]] || ! grep -q '^scans:' "$project_config" 2>/dev/null; then
    local setup_script="$SCRIPT_DIR/project-scan-setup.sh"
    if [[ -f "$setup_script" ]]; then
      echo -e "  ${YELLOW}🔧${NC} Auto-generating project scan config..."
      (cd "$proj_root" && bash "$setup_script" --quiet 2>/dev/null) || true
      if [[ -f "$project_config" ]] && grep -q '^scans:' "$project_config" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} Project scan config auto-generated (.github/bubbles-project.yaml)"
        passed=$((passed + 1))
        healed=$((healed + 1))
      else
        echo -e "  ${YELLOW}⚠️${NC}  Could not auto-generate scan config (will use generic defaults)"
        passed=$((passed + 1))
      fi
    fi
  else
    echo -e "  ${GREEN}✅${NC} Project scan config present (.github/bubbles-project.yaml)"
    passed=$((passed + 1))
  fi

  # Check 11: Portable Bubbles surfaces remain agnostic
  if bash "$SCRIPT_DIR/agnosticity-lint.sh" --quiet; then
    echo -e "  ${GREEN}✅${NC} Portable Bubbles surfaces pass agnosticity lint"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}❌${NC} Portable Bubbles surfaces contain project/tool drift"
    failed=$((failed + 1))
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

  local hooks_json="$FRAMEWORK_DIR/hooks.json"
  local git_hooks_dir
  git_hooks_dir="$(cd "$REPO_ROOT" && git rev-parse --git-dir 2>/dev/null)/hooks"

  case "$subcmd" in
    catalog)
      echo "Built-in hooks available:"
      echo "  artifact-lint       pre-commit   Fast artifact lint on staged spec files"
      echo "  agnosticity-lint    pre-commit   Portable Bubbles drift check on staged files"
      echo "  guard-done-specs    pre-push     State transition guard on done specs"
      echo "  agnosticity-full    pre-push     Full portable Bubbles drift check"
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
      require_framework_repo_for_hooks
      mkdir -p "$(dirname "$hooks_json")"
      local hook_name="${1:-}"

      if [[ "$hook_name" == "--all" || -z "$hook_name" ]]; then
        # Install all built-in hooks
        cat > "$hooks_json" << 'HJEOF'
{
  "pre-commit": [
    {"name": "artifact-lint", "type": "builtin"},
    {"name": "agnosticity-lint", "type": "builtin"}
  ],
  "pre-push": [
    {"name": "agnosticity-full", "type": "builtin"},
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

    uninstall)
      require_framework_repo_for_hooks
      local removed_any="false"
      for ht in pre-commit pre-push; do
        if [[ -x "$git_hooks_dir/$ht" ]] && grep -q 'Generated by: bubbles.sh hooks install' "$git_hooks_dir/$ht" 2>/dev/null; then
          rm -f "$git_hooks_dir/$ht"
          echo "Removed Bubbles-managed $ht hook"
          removed_any="true"
        fi
      done
      if [[ -f "$hooks_json" ]]; then
        rm -f "$hooks_json"
        echo "Removed $hooks_json"
        removed_any="true"
      fi
      if [[ "$removed_any" == "false" ]]; then
        echo "No Bubbles-managed hooks found to uninstall."
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

    *) die "Unknown hooks subcommand: $subcmd. Try: catalog, list, install, uninstall, add, remove, run, status" ;;
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
echo "🫧 Bubbles pre-commit: checking portable surfaces for drift..."
bash bubbles/scripts/agnosticity-lint.sh --staged || failed=1
if git diff --cached --name-only | grep -q '^specs/'; then
  echo "🫧 Bubbles pre-commit: artifact lint on staged specs..."
  for spec_dir in $(git diff --cached --name-only | grep '^specs/' | sed 's|/[^/]*$||' | sort -u); do
    if [[ -d "$spec_dir" && -f "$spec_dir/state.json" ]]; then
      bash bubbles/scripts/artifact-lint.sh "$spec_dir" --quick || failed=1
      status=$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$spec_dir/state.json" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
      if [[ "$status" == "done" ]]; then
        bash bubbles/scripts/state-transition-guard.sh "$spec_dir" || failed=1
      fi
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
bash bubbles/scripts/agnosticity-lint.sh || failed=1
for state_file in $(find specs -maxdepth 2 -name "state.json" -not -path "*/bugs/*" 2>/dev/null); do
  status=$(grep -o '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$state_file" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
  if [[ "$status" == "done" ]]; then
    spec_dir=$(dirname "$state_file")
    bash bubbles/scripts/state-transition-guard.sh "$spec_dir" || failed=1
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
    setup)
      # Analyze project and generate/update bubbles-project.yaml scans section
      local setup_script="$SCRIPT_DIR/project-scan-setup.sh"
      local proj_root
      proj_root="$(cd "$SCRIPT_DIR/../../.." && pwd)"
      if [[ -f "$setup_script" ]]; then
        (cd "$proj_root" && bash "$setup_script" "$@")
      else
        die "Setup script not found: $setup_script"
      fi
      ;;
    *) die "Unknown project subcommand: $subcmd. Try: gates, setup" ;;
  esac
}

cmd_policy() {
  local subcmd="${1:-status}"
  shift || true

  load_control_plane_config

  case "$subcmd" in
    status)
      echo "Control-plane policy registry: $CONTROL_PLANE_CONFIG"
      echo ""
      echo "Defaults:"
      echo "  grill.mode = $CFG_GRILL_MODE (source=$CFG_GRILL_SOURCE)"
      echo "  tdd.mode = $CFG_TDD_MODE (source=$CFG_TDD_SOURCE)"
      echo "  autoCommit.mode = $CFG_AUTOCOMMIT_MODE (source=$CFG_AUTOCOMMIT_SOURCE)"
      echo "  lockdown.default = $CFG_LOCKDOWN_DEFAULT (source=$CFG_LOCKDOWN_SOURCE)"
      echo "  lockdown.requireGrillForInvalidation = $CFG_LOCKDOWN_REQUIRE_GRILL"
      echo "  regression.immutability = $CFG_REGRESSION_IMMUTABILITY (source=$CFG_REGRESSION_SOURCE)"
      echo "  validation.certificationRequired = $CFG_VALIDATION_CERT_REQUIRED (source=$CFG_VALIDATION_SOURCE)"
      echo ""
      echo "Workflow-forced overrides:"
      echo "  bugfix-fastlane.tdd.mode = scenario-first (source=workflow-forced)"
      echo "  chaos-hardening.tdd.mode = scenario-first (source=workflow-forced)"
      echo ""
      echo "Auxiliary settings:"
      echo "  metrics.enabled = $CFG_METRICS_ENABLED"
      ;;
    get)
      local path="${1:-}"
      [[ -n "$path" ]] || die "Usage: bubbles policy get <path>"
      if ! read_control_plane_setting "$path"; then
        die "Unknown policy path: $path"
      fi
      echo ""
      ;;
    set)
      local path="${1:-}"
      local value="${2:-}"
      local source="repo-default"

      [[ -n "$path" && -n "$value" ]] || die "Usage: bubbles policy set <path> <value> [--source <provenance>]"
      shift 2
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --source)
            shift
            [[ $# -gt 0 ]] || die "Missing value after --source"
            source="$1"
            ;;
          *) die "Unknown option for bubbles policy set: $1" ;;
        esac
        shift
      done

      validate_policy_value "$path" "$value"
      validate_policy_source "$source"

      write_control_plane_setting "$path" "$value"
      case "$path" in
        grill.mode) CFG_GRILL_SOURCE="$source" ;;
        tdd.mode) CFG_TDD_SOURCE="$source" ;;
        autoCommit.mode) CFG_AUTOCOMMIT_SOURCE="$source" ;;
        lockdown.default|lockdown.requireGrillForInvalidation) CFG_LOCKDOWN_SOURCE="$source" ;;
        regression.immutability) CFG_REGRESSION_SOURCE="$source" ;;
        validation.certificationRequired) CFG_VALIDATION_SOURCE="$source" ;;
      esac
      save_control_plane_config
      echo "✅ Updated $path = $value"
      ;;
    reset)
      local path="${1:-}"

      if [[ -z "$path" ]]; then
        ensure_control_plane_config
        default_control_plane_config > "$CONTROL_PLANE_CONFIG"
        echo "✅ Reset control-plane policy registry to defaults"
        return 0
      fi

      default_value="$(default_value_for_policy_path "$path" || true)"
      [[ -n "$default_value" ]] || die "Unknown policy path: $path"

      validate_policy_value "$path" "$default_value"
      write_control_plane_setting "$path" "$default_value"
      case "$path" in
        grill.mode|grill.source) CFG_GRILL_SOURCE="repo-default" ;;
        tdd.mode|tdd.source) CFG_TDD_SOURCE="repo-default" ;;
        autoCommit.mode|autoCommit.source) CFG_AUTOCOMMIT_SOURCE="repo-default" ;;
        lockdown.default|lockdown.requireGrillForInvalidation|lockdown.source) CFG_LOCKDOWN_SOURCE="repo-default" ;;
        regression.immutability|regression.source) CFG_REGRESSION_SOURCE="repo-default" ;;
        validation.certificationRequired|validation.source) CFG_VALIDATION_SOURCE="repo-default" ;;
      esac
      save_control_plane_config
      echo "✅ Reset $path to $(read_control_plane_setting "$path")"
      ;;
    *)
      die "Unknown policy subcommand: $subcmd. Try: status, get, set, reset"
      ;;
  esac
}

cmd_metrics() {
  local subcmd="${1:-status}"
  load_control_plane_config

  case "$subcmd" in
    enable)
      CFG_METRICS_ENABLED="true"
      save_control_plane_config
      echo "✅ Metrics enabled. Events will be logged to $CONTROL_PLANE_METRICS_FILE"
      ;;
    disable)
      CFG_METRICS_ENABLED="false"
      save_control_plane_config
      echo "✅ Metrics disabled. Existing data preserved."
      ;;
    status)
      if [[ "$CFG_METRICS_ENABLED" == "true" ]]; then
        local count=0
        [[ -f "$CONTROL_PLANE_METRICS_FILE" ]] && count=$(wc -l < "$CONTROL_PLANE_METRICS_FILE")
        echo "Metrics: ENABLED ($count events collected)"
      else
        echo "Metrics: DISABLED (run: bubbles metrics enable)"
      fi
      ;;
    summary)
      if [[ ! -f "$CONTROL_PLANE_METRICS_FILE" ]]; then
        echo "No metrics data. Enable with: bubbles metrics enable"
        return
      fi
      echo "Metrics Summary:"
      echo "  Total events: $(wc -l < "$CONTROL_PLANE_METRICS_FILE")"
      echo "  Gate checks: $(grep -c '"type":"gate_check"' "$CONTROL_PLANE_METRICS_FILE" 2>/dev/null || echo 0)"
      echo "  Phase completions: $(grep -c '"type":"phase_complete"' "$CONTROL_PLANE_METRICS_FILE" 2>/dev/null || echo 0)"
      ;;
    gates)
      if [[ ! -f "$CONTROL_PLANE_METRICS_FILE" ]]; then echo "No data."; return; fi
      echo "Gate failure frequency:"
      grep '"type":"gate_check".*"result":"fail"' "$CONTROL_PLANE_METRICS_FILE" 2>/dev/null \
        | grep -oE '"gate":"[^"]*"' | sort | uniq -c | sort -rn || echo "  No failures recorded"
      ;;
    agents)
      if [[ ! -f "$CONTROL_PLANE_METRICS_FILE" ]]; then echo "No data."; return; fi
      echo "Agent invocations:"
      grep '"type":"phase_complete"' "$CONTROL_PLANE_METRICS_FILE" 2>/dev/null \
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
    policy)             cmd_policy "$@" ;;
    session)            cmd_session "$@" ;;
    lint)               cmd_lint "$@" ;;
    agnosticity)        cmd_agnosticity "$@" ;;
    guard)              cmd_guard "$@" ;;
    guard-selftest)     cmd_guard_selftest "$@" ;;
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
