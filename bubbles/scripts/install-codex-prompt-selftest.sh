#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="${SCRIPT_DIR}/install-codex-prompt.sh"
SOURCE_PROMPT="${SCRIPT_DIR}/../codex-prompts/bubbles-goal.md"
TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-codex-prompt.XXXXXX")"
trap 'rm -rf "$TEST_DIR"' EXIT

PROMPT_DIR="${TEST_DIR}/prompts"
bash "$INSTALLER" --prompt-dir "$PROMPT_DIR"
cmp -s "$SOURCE_PROMPT" "${PROMPT_DIR}/bubbles-goal.md"

printf 'operator-owned prompt\n' > "${PROMPT_DIR}/bubbles-goal.md"
if bash "$INSTALLER" --prompt-dir "$PROMPT_DIR"; then
  echo "FAIL: installer overwrote an existing prompt without --force" >&2
  exit 1
fi

bash "$INSTALLER" --prompt-dir "$PROMPT_DIR" --force
cmp -s "$SOURCE_PROMPT" "${PROMPT_DIR}/bubbles-goal.md"
echo "install-codex-prompt-selftest: PASS"
