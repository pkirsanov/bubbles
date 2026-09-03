#!/usr/bin/env bash
# bubbles/adapters/usage/vscode-copilot.sh — reference host-usage adapter.
#
# Reads per-request usage records the VS Code Copilot Chat host writes to disk
# (IMP-039 SCOPE-2). It MEASURES; it never estimates.
#
# WHY A REFERENCE ADAPTER EXISTS
# `bubbles/workflows.yaml` excluded `tokenCount` because the VS Code Copilot
# API does not expose it. That is true of the API and incomplete about the host:
# the host also writes the numbers to a file. This adapter reads that file. It
# is the only sanctioned route from a real token count into a Bubbles surface.
#
# SCHEMA OWNERSHIP — READ BEFORE TRUSTING THIS
# The artifact and its field names are HOST-OWNED and versioned by the host, not
# by this framework. This adapter is written against the documented shape:
#
#   <workspaceStorage>/<workspace-id>/chatSessions/<session-id>.jsonl
#   per completed request: promptTokens, completionTokens, copilotCredits,
#                          modelId, promptTokenDetails
#
# When no exact artifact exists, or one exact stable artifact carries no
# request-like usage object, this adapter returns neutral-empty records. Unsafe,
# unstable, unreadable, malformed, or mixed exact input fails loud instead of
# becoming a valid-looking subset. It does NOT fall back to a derived number,
# because a derived number is the failure this scope exists to prevent. A
# remote/SSH/WSL server install is a normal case of "absent": the records live
# on the CLIENT machine, so point
# BUBBLES_USAGE_VSCODE_ROOT at the client-side workspaceStorage or accept
# `unmeasured`.
#
# Configuration:
#   BUBBLES_USAGE_VSCODE_ROOT   explicit workspaceStorage directory. Required
#                               for remote installs; otherwise the standard
#                               per-platform locations are searched.
#
# Verbs and shapes are identical to none.sh, so a consumer never branches on
# which adapter answered — only on `status.measured`.

set -euo pipefail

VERB="${1:-}"
SESSION_FILTER="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_IO_HELPER="$SCRIPT_DIR/../../scripts/session-state-io.py"
PYTHON_BIN="$(command -v python3 2>/dev/null || true)"

emit_unmeasured_status() {
  printf '{"measured":false,"adapter":"vscode-copilot","reason":"%s"}\n' "$1"
}

declare -a USAGE_ROOTS=()
if [[ -n "${BUBBLES_USAGE_VSCODE_ROOT:-}" ]]; then
  USAGE_ROOTS+=("$BUBBLES_USAGE_VSCODE_ROOT")
else
  USAGE_ROOTS+=(
    "$HOME/Library/Application Support/Code/User/workspaceStorage"
    "$HOME/Library/Application Support/Code - Insiders/User/workspaceStorage"
    "$HOME/.config/Code/User/workspaceStorage"
    "$HOME/.config/Code - Insiders/User/workspaceStorage"
    "$HOME/AppData/Roaming/Code/User/workspaceStorage"
  )
fi

require_usage_reader() {
  if [[ -z "$PYTHON_BIN" || ! -f "$STATE_IO_HELPER" || -L "$STATE_IO_HELPER" ]]; then
    echo "[vscode-copilot][ERROR] safe usage reader is unavailable" >&2
    return 1
  fi
}

read_usage() {
  local projection="$1"
  local requested="${2:-}"
  local root
  local -a command=(
    "$PYTHON_BIN"
    "$STATE_IO_HELPER"
    parse-usage
    --projection "$projection"
  )
  if [[ -n "$requested" ]]; then
    command+=(--session-id "$requested")
  fi
  for root in "${USAGE_ROOTS[@]}"; do
    command+=(--root "$root")
  done
  "${command[@]}"
}

emit_usage_or_error() {
  local projection="$1"
  local requested="${2:-}"
  local output rc
  set +e
  output="$(read_usage "$projection" "$requested")"
  rc=$?
  set -e
  if [[ "$rc" -ne 0 ]]; then
    echo "[vscode-copilot][ERROR] exact usage input is unsafe or invalid" >&2
    return 2
  fi
  printf '%s\n' "$output"
}

case "$VERB" in
  requests)
    [[ -n "$SESSION_FILTER" ]] || { echo '[]'; exit 0; }
    require_usage_reader || exit 2
    emit_usage_or_error requests "$SESSION_FILTER" || exit $?
    exit 0
    ;;
  session)
    [[ -n "$SESSION_FILTER" ]] || { echo '{}'; exit 0; }
    require_usage_reader || exit 2
    emit_usage_or_error session "$SESSION_FILTER" || exit $?
    exit 0
    ;;
  status)
    require_usage_reader || { emit_unmeasured_status "safe usage reader is unavailable"; exit 0; }
    emit_usage_or_error status || exit $?
    exit 0
    ;;
  capabilities)
    printf '%s\n' '{"requests":"native","session":"derived","toolResultBytes":"unsupported","compactionCheckpoints":"unsupported"}'
    exit 0
    ;;
  selftest)
    case "${2:-}" in
      requests) echo '[]'; exit 0 ;;
      session) echo '{}'; exit 0 ;;
      capabilities) printf '%s\n' '{"requests":"native","session":"derived","toolResultBytes":"unsupported","compactionCheckpoints":"unsupported"}'; exit 0 ;;
      status) emit_unmeasured_status "selftest"; exit 0 ;;
      *) echo "[vscode-copilot][ERROR] selftest requires a known verb" >&2; exit 1 ;;
    esac
    ;;
  -h | --help | "")
    cat >&2 <<'EOF'
vscode-copilot.sh — reference host-usage adapter (reads VS Code chatSessions)
Usage: vscode-copilot.sh <verb> [sessionId]
Verbs: requests [sessionId] | session [sessionId] | status | capabilities |
       selftest <verb>
Env:   BUBBLES_USAGE_VSCODE_ROOT — workspaceStorage dir (required for remote installs)
EOF
    exit 0
    ;;
  *)
    echo "[vscode-copilot][ERROR] unknown verb '$VERB'" >&2
    exit 1
    ;;
esac
