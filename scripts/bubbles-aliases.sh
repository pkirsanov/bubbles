#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────
# bubbles-aliases.sh — Sunnyvale alias resolution
# ────────────────────────────────────────────────────────────────────
# Resolves Sunnyvale-themed aliases to canonical Bubbles agent names
# and workflow modes.
#
# Usage (source from another script):
#   source "$(dirname "${BASH_SOURCE[0]}")/bubbles-aliases.sh"
#   resolve_agent_alias "worst-case-ontario"   → "bubbles.chaos"
#   resolve_mode_alias "bottle-kids"           → "stochastic-quality-sweep"
#
# Or use the lookup + quote:
#   sunnyvale_lookup "decent"
#   → prints: bubbles.status — "DEEEE-CENT!"
# ────────────────────────────────────────────────────────────────────

# ── Agent Aliases ───────────────────────────────────────────────────
# Maps sunnyvale <alias> → bubbles.<agent>

declare -A _AGENT_ALIASES=(
  [pull-the-strings]="bubbles.workflow"
  [worst-case-ontario]="bubbles.chaos"
  [i-am-the-liquor]="bubbles.audit"
  [shit-winds]="bubbles.audit"
  [get-two-birds-stoned]="bubbles.implement"
  [smokes-lets-go]="bubbles.bootstrap"
  [know-what-im-sayin]="bubbles.docs"
  [somethings-fucky]="bubbles.validate"
  [way-she-goes]="bubbles.analyst"
  [peanut-butter-and-jam]="bubbles.gaps"
  [safety-always-off]="bubbles.security"
  [decent]="bubbles.status"
  [greasy]="bubbles.harden"
  [supply-and-command]="bubbles.plan"
  [water-under-the-fridge]="bubbles.simplify"
  [have-a-good-one]="bubbles.handoff"
  [skid-row]="bubbles.cinematic-designer"
  [mans-gotta-eat]="bubbles.validate"
)

declare -A _AGENT_QUOTES=(
  [pull-the-strings]="Bubbles is pulling all the strings, boys."
  [worst-case-ontario]="Worst case Ontario, something breaks."
  [i-am-the-liquor]="I AM the liquor, Randy."
  [shit-winds]="The shit winds are coming."
  [get-two-birds-stoned]="Get two birds stoned at once."
  [smokes-lets-go]="Smokes, let's go."
  [know-what-im-sayin]="Know what I'm sayin'?"
  [somethings-fucky]="Something's fucky."
  [way-she-goes]="Way she goes, boys."
  [peanut-butter-and-jam]="BAAAAM! Peanut butter and JAAAAM!"
  [safety-always-off]="Safety... always off."
  [decent]="DEEEE-CENT!"
  [greasy]="That's greasy, boys."
  [supply-and-command]="It's supply and command, Julian."
  [water-under-the-fridge]="It's all water under the fridge."
  [have-a-good-one]="Have a good one, boys."
  [skid-row]="I was in Skid Row!"
  [mans-gotta-eat]="A man's gotta eat, Julian."
)

# ── Agent alias notes (special behavior) ────────────────────────────
declare -A _AGENT_NOTES=(
  [i-am-the-liquor]="Use with --strict flag for maximum enforcement"
  [get-two-birds-stoned]="Runs bubbles.implement then bubbles.test in sequence"
)

# ── Workflow Mode Aliases ───────────────────────────────────────────
# Maps sunnyvale <mode-alias> → canonical workflow mode

declare -A _MODE_ALIASES=(
  [boys-plan]="value-first-e2e-batch"
  [full-send]="full-delivery"
  [clean-and-sober]="full-delivery-strict"
  [shit-storm]="chaos-hardening"
  [smash-and-grab]="bugfix-fastlane"
  [randy-put-a-shirt-on]="validate-only"
  [bottle-kids]="stochastic-quality-sweep"
  [conky-says]="harden-gaps-to-doc"
  [freedom-35]="product-to-delivery"
  [gnome-sayin]="docs-only"
  [quick-dirty]="test-to-doc"
)

declare -A _MODE_QUOTES=(
  [boys-plan]="Julian's got a plan. A good plan this time."
  [full-send]="Full send, boys."
  [clean-and-sober]="We're doing this clean and sober."
  [shit-storm]="We're in the eye of a shiticane."
  [smash-and-grab]="Get in, fix it, get out."
  [randy-put-a-shirt-on]="Randy, put a shirt on!"
  [bottle-kids]="Bottle kids! Take cover!"
  [conky-says]="Conky says you've got issues."
  [freedom-35]="Freedom 35, boys!"
  [gnome-sayin]="Gnome sayin'? Document it."
  [quick-dirty]="Quick and dirty, boys."
)

# ── Public API ──────────────────────────────────────────────────────

# Resolve an agent alias to canonical agent name
# Returns empty string if not found
resolve_agent_alias() {
  local alias="$1"
  echo "${_AGENT_ALIASES[$alias]:-}"
}

# Resolve a workflow mode alias to canonical mode name
# Returns empty string if not found
resolve_mode_alias() {
  local alias="$1"
  echo "${_MODE_ALIASES[$alias]:-}"
}

# Get the quote for an agent alias
agent_alias_quote() {
  local alias="$1"
  echo "${_AGENT_QUOTES[$alias]:-}"
}

# Get the quote for a mode alias
mode_alias_quote() {
  local alias="$1"
  echo "${_MODE_QUOTES[$alias]:-}"
}

# Full lookup: try agent first, then mode. Prints formatted result.
# Returns 0 if found, 1 if not found.
sunnyvale_lookup() {
  local alias="$1"
  local agent="${_AGENT_ALIASES[$alias]:-}"
  local mode="${_MODE_ALIASES[$alias]:-}"

  if [[ -n "$agent" ]]; then
    local quote="${_AGENT_QUOTES[$alias]:-}"
    local note="${_AGENT_NOTES[$alias]:-}"
    echo "🫧 $alias → $agent"
    [[ -n "$quote" ]] && echo "   \"$quote\""
    [[ -n "$note" ]] && echo "   Note: $note"
    return 0
  elif [[ -n "$mode" ]]; then
    local quote="${_MODE_QUOTES[$alias]:-}"
    echo "🫧 $alias → workflow mode: $mode"
    [[ -n "$quote" ]] && echo "   \"$quote\""
    return 0
  else
    return 1
  fi
}

# List all aliases in a formatted table
list_all_aliases() {
  echo ""
  echo "🫧 Sunnyvale Agent Aliases"
  echo "──────────────────────────────────────────────────────────────"
  printf "  %-28s %-30s %s\n" "ALIAS" "MAPS TO" "QUOTE"
  printf "  %-28s %-30s %s\n" "─────" "───────" "─────"
  for alias in $(echo "${!_AGENT_ALIASES[@]}" | tr ' ' '\n' | sort); do
    local agent="${_AGENT_ALIASES[$alias]}"
    local quote="${_AGENT_QUOTES[$alias]:-}"
    printf "  %-28s %-30s %s\n" "$alias" "$agent" "\"$quote\""
  done

  echo ""
  echo "🫧 Sunnyvale Workflow Mode Aliases"
  echo "──────────────────────────────────────────────────────────────"
  printf "  %-28s %-30s %s\n" "ALIAS" "MAPS TO" "QUOTE"
  printf "  %-28s %-30s %s\n" "─────" "───────" "─────"
  for alias in $(echo "${!_MODE_ALIASES[@]}" | tr ' ' '\n' | sort); do
    local mode="${_MODE_ALIASES[$alias]}"
    local quote="${_MODE_QUOTES[$alias]:-}"
    printf "  %-28s %-30s %s\n" "$alias" "$mode" "\"$quote\""
  done
  echo ""
}
