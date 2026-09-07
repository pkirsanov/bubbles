#!/usr/bin/env bash
# Install Bubbles' optional Codex slash-command prompt into a user-local directory.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PROMPT="${SCRIPT_DIR}/../codex-prompts/bubbles-goal.md"
PROMPT_DIR="${CODEX_HOME:-${HOME}/.codex}/prompts"
FORCE=false

usage() {
  cat <<'EOF'
Usage: bash bubbles/scripts/install-codex-prompt.sh [--prompt-dir DIR] [--force]

Installs the optional /prompts:bubbles-goal Codex custom prompt. The default
location is $CODEX_HOME/prompts, or ~/.codex/prompts when CODEX_HOME is unset.
Existing prompts are never replaced unless --force is supplied.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt-dir)
      [[ $# -ge 2 ]] || { echo "--prompt-dir requires a directory" >&2; exit 2; }
      PROMPT_DIR="$2"
      shift 2
      ;;
    --force) FORCE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -f "$SOURCE_PROMPT" ]] || { echo "Missing prompt template: $SOURCE_PROMPT" >&2; exit 1; }
mkdir -p "$PROMPT_DIR"
TARGET_PROMPT="${PROMPT_DIR}/bubbles-goal.md"

if [[ -f "$TARGET_PROMPT" ]] && cmp -s "$SOURCE_PROMPT" "$TARGET_PROMPT"; then
  echo "Codex prompt is already current: $TARGET_PROMPT"
  exit 0
fi

if [[ -e "$TARGET_PROMPT" && "$FORCE" != true ]]; then
  echo "Refusing to overwrite existing prompt: $TARGET_PROMPT (use --force)" >&2
  exit 1
fi

cp "$SOURCE_PROMPT" "$TARGET_PROMPT"
echo "Installed Codex prompt: $TARGET_PROMPT"
