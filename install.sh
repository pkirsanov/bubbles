#!/usr/bin/env bash
# 🫧 Bubbles Installer — "It ain't rocket appliances."
# Installs or updates the Bubbles agent system into your repo.
set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
BUBBLES_REPO="pkirsanov/bubbles"
BUBBLES_REF="${1:-main}"
GITHUB_BASE="https://raw.githubusercontent.com/${BUBBLES_REPO}/${BUBBLES_REF}"
TARGET=".github"

# ── Colors ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { printf "${CYAN}🫧${NC} %s\n" "$1"; }
ok()    { printf "${GREEN}✅${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}⚠️${NC}  %s\n" "$1"; }
fail()  { printf "${RED}❌${NC} %s\n" "$1"; exit 1; }

# ── Preflight ───────────────────────────────────────────────────────
command -v curl >/dev/null 2>&1 || fail "curl is required. Install it first."
command -v tar  >/dev/null 2>&1 || fail "tar is required. Install it first."

if [[ ! -d ".git" ]]; then
  fail "Not a git repo. Run this from your project root."
fi

# ── Download ────────────────────────────────────────────────────────
info "Downloading Bubbles ${BUBBLES_REF}..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

curl -fsSL "https://github.com/${BUBBLES_REPO}/archive/refs/heads/${BUBBLES_REF}.tar.gz" \
  -o "$TEMP_DIR/bubbles.tar.gz" 2>/dev/null \
  || curl -fsSL "https://github.com/${BUBBLES_REPO}/archive/refs/tags/${BUBBLES_REF}.tar.gz" \
    -o "$TEMP_DIR/bubbles.tar.gz" 2>/dev/null \
  || fail "Could not download Bubbles ref '${BUBBLES_REF}'. Check the version/branch name."

tar xzf "$TEMP_DIR/bubbles.tar.gz" -C "$TEMP_DIR" --strip-components=1

# ── Install agents ──────────────────────────────────────────────────
info "Installing agents..."
mkdir -p "${TARGET}/agents/_shared"
cp "$TEMP_DIR"/agents/bubbles.*.agent.md "${TARGET}/agents/"
cp "$TEMP_DIR"/agents/_shared/*.md       "${TARGET}/agents/_shared/"
ok "$(ls "${TARGET}"/agents/bubbles.*.agent.md | wc -l) agents installed"

# ── Install prompts ─────────────────────────────────────────────────
info "Installing prompts..."
mkdir -p "${TARGET}/prompts"
cp "$TEMP_DIR"/prompts/bubbles.*.prompt.md "${TARGET}/prompts/"
ok "$(ls "${TARGET}"/prompts/bubbles.*.prompt.md | wc -l) prompts installed"

# ── Install workflows ───────────────────────────────────────────────
info "Installing workflow config..."
mkdir -p "${TARGET}/bubbles"
cp "$TEMP_DIR"/bubbles/workflows.yaml "${TARGET}/bubbles/"
ok "workflows.yaml installed"

# ── Install scripts ─────────────────────────────────────────────────
info "Installing governance scripts..."
mkdir -p "${TARGET}/scripts"
cp "$TEMP_DIR"/scripts/bubbles*.sh "${TARGET}/scripts/"
chmod +x "${TARGET}"/scripts/bubbles*.sh
ok "$(ls "${TARGET}"/scripts/bubbles*.sh | wc -l) scripts installed"

# ── Optional: shared instructions & skills ──────────────────────────
if [[ "${2:-}" != "--agents-only" ]]; then
  if [[ -d "$TEMP_DIR/instructions" ]]; then
    info "Installing shared instructions..."
    mkdir -p "${TARGET}/instructions"
    cp "$TEMP_DIR"/instructions/*.md "${TARGET}/instructions/" 2>/dev/null || true
  fi
  if [[ -d "$TEMP_DIR/skills" ]]; then
    info "Installing shared skills..."
    for skill_dir in "$TEMP_DIR"/skills/*/; do
      skill_name=$(basename "$skill_dir")
      mkdir -p "${TARGET}/skills/${skill_name}"
      cp -r "${skill_dir}"* "${TARGET}/skills/${skill_name}/" 2>/dev/null || true
    done
  fi
fi

# ── Version stamp ───────────────────────────────────────────────────
if [[ -f "$TEMP_DIR/VERSION" ]]; then
  cp "$TEMP_DIR/VERSION" "${TARGET}/bubbles/.version"
  VERSION=$(cat "${TARGET}/bubbles/.version")
  ok "Bubbles v${VERSION} installed"
else
  ok "Bubbles (${BUBBLES_REF}) installed"
fi

# ── Summary ─────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${GREEN}🫧 DEEEE-CENT!${NC}\n"
echo ""
echo "Bubbles is installed. Next steps:"
echo ""
echo "  1. Add project-specific config to .github/copilot-instructions.md"
echo "  2. Try:  /bubbles.workflow   — full orchestration"
echo "  3. Try:  /bubbles.status     — check spec progress"
echo "  4. Try:  /bubbles.plan       — scope out a feature"
echo ""
echo "Docs:    https://github.com/${BUBBLES_REPO}"
echo "Update:  curl -fsSL https://raw.githubusercontent.com/${BUBBLES_REPO}/main/install.sh | bash"
echo ""
printf "${YELLOW}\"It ain't rocket appliances, but it works.\"${NC}\n"
