#!/usr/bin/env bash
# 🫧 Bubbles Installer — "It ain't rocket appliances."
# Installs or updates the Bubbles agent system into your repo.
#
# Usage:
#   curl -fsSL .../install.sh | bash                    # Install shared framework files
#   curl -fsSL .../install.sh | bash -s -- --agents-only  # Install agents/workflows/scripts only
#   curl -fsSL .../install.sh | bash -s -- --bootstrap  # Install + scaffold project config
#   curl -fsSL .../install.sh | bash -s -- v1.0.0       # Pin to version
#   curl -fsSL .../install.sh | bash -s -- --bootstrap --cli ./myproject.sh --name "My Project"
#
set -euo pipefail

# ── Parse arguments ─────────────────────────────────────────────────
BUBBLES_REF="main"
DO_BOOTSTRAP=false
AGENTS_ONLY=false
CLI_OVERRIDE=""
NAME_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bootstrap)   DO_BOOTSTRAP=true; shift ;;
    --agents-only) AGENTS_ONLY=true; shift ;;
    --cli)         CLI_OVERRIDE="$2"; shift 2 ;;
    --name)        NAME_OVERRIDE="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: install.sh [REF] [OPTIONS]"
      echo ""
      echo "  REF                Git ref to install (default: main)"
      echo "  --bootstrap        Scaffold project config files after install"
      echo "  --cli ./foo.sh     Set CLI entrypoint (auto-detected if omitted)"
      echo "  --name \"My Proj\"   Set project name (auto-detected if omitted)"
      echo "  --agents-only      Skip shared instructions and skills"
      echo ""
      exit 0
      ;;
    *)             BUBBLES_REF="$1"; shift ;;
  esac
done

# ── Config ──────────────────────────────────────────────────────────
BUBBLES_REPO="pkirsanov/bubbles"
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
mkdir -p "${TARGET}/agents/bubbles_shared"
cp "$TEMP_DIR"/agents/bubbles.*.agent.md "${TARGET}/agents/"
cp "$TEMP_DIR"/agents/bubbles_shared/*.md       "${TARGET}/agents/bubbles_shared/"
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
mkdir -p "${TARGET}/bubbles/scripts"
cp "$TEMP_DIR"/bubbles/scripts/*.sh "${TARGET}/bubbles/scripts/"
chmod +x "${TARGET}"/bubbles/scripts/*.sh
ok "$(ls "${TARGET}"/bubbles/scripts/*.sh | wc -l) scripts installed"

# ── Migration: rename legacy shared instruction filenames ──────────
for legacy_pair in \
  "agents.instructions.md:bubbles-agents.instructions.md" \
  "skills.instructions.md:bubbles-skills.instructions.md" \
  "docker-lifecycle-governance.instructions.md:bubbles-docker-lifecycle-governance.instructions.md"; do
  legacy_name=${legacy_pair%%:*}
  namespaced_name=${legacy_pair##*:}
  legacy_path="${TARGET}/instructions/${legacy_name}"
  namespaced_path="${TARGET}/instructions/${namespaced_name}"
  if [[ -f "${legacy_path}" ]]; then
    if [[ ! -f "${namespaced_path}" ]]; then
      mv "${legacy_path}" "${namespaced_path}"
      info "Migrated: instructions/${legacy_name} → instructions/${namespaced_name}"
    else
      rm "${legacy_path}"
      info "Removed legacy instruction: instructions/${legacy_name}"
    fi
  fi
done

# ── Migration: rename legacy shared skill directories ──────────────
for legacy_pair in \
  "skill-authoring:bubbles-skill-authoring" \
  "docker-port-standards:bubbles-docker-port-standards" \
  "spec-template-bdd:bubbles-spec-template-bdd" \
  "docker-lifecycle-governance:bubbles-docker-lifecycle-governance"; do
  legacy_name=${legacy_pair%%:*}
  namespaced_name=${legacy_pair##*:}
  legacy_path="${TARGET}/skills/${legacy_name}"
  namespaced_path="${TARGET}/skills/${namespaced_name}"
  if [[ -d "${legacy_path}" ]]; then
    if [[ ! -d "${namespaced_path}" ]]; then
      mv "${legacy_path}" "${namespaced_path}"
      info "Migrated: skills/${legacy_name} → skills/${namespaced_name}"
    else
      rm -rf "${legacy_path}"
      info "Removed legacy skill directory: skills/${legacy_name}"
    fi
  fi
done

# ── Optional: shared instructions & skills ──────────────────────────
if [[ "$AGENTS_ONLY" != "true" ]]; then
  if [[ -d "$TEMP_DIR/instructions" ]]; then
    info "Installing shared instructions..."
    mkdir -p "${TARGET}/instructions"
    cp "$TEMP_DIR"/instructions/*.md "${TARGET}/instructions/" 2>/dev/null || true
    ok "$(ls "${TARGET}"/instructions/*.md 2>/dev/null | wc -l) shared instructions installed"
  fi
  if [[ -d "$TEMP_DIR/skills" ]]; then
    info "Installing shared skills..."
    for skill_dir in "$TEMP_DIR"/skills/*/; do
      skill_name=$(basename "$skill_dir")
      mkdir -p "${TARGET}/skills/${skill_name}"
      cp -r "${skill_dir}"* "${TARGET}/skills/${skill_name}/" 2>/dev/null || true
    done
    ok "$(find "${TARGET}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l) shared skills installed"
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

# ── Bootstrap: scaffold project config ──────────────────────────────
if [[ "$DO_BOOTSTRAP" == "true" ]]; then
  echo ""
  info "Bootstrapping project configuration..."

  # ── Auto-detect project name ──────────────────────────────────────
  if [[ -n "$NAME_OVERRIDE" ]]; then
    PROJECT_NAME="$NAME_OVERRIDE"
  else
    # Try git remote name, fall back to directory name
    PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
    # Title-case it: my-project → My Project
    PROJECT_NAME=$(echo "$PROJECT_NAME" | sed 's/[-_]/ /g' | sed 's/\b\(.\)/\u\1/g')
  fi
  info "Project name: ${PROJECT_NAME}"

  # ── Auto-detect CLI entrypoint ────────────────────────────────────
  if [[ -n "$CLI_OVERRIDE" ]]; then
    CLI_ENTRYPOINT="$CLI_OVERRIDE"
  else
    # Look for a *.sh runner script in project root (not install.sh, not hidden)
    CLI_ENTRYPOINT=""
    for candidate in ./*.sh; do
      [[ ! -f "$candidate" ]] && continue
      base=$(basename "$candidate")
      # Skip common non-CLI scripts
      case "$base" in
        install.sh|setup.sh|uninstall.sh|.*.sh) continue ;;
      esac
      CLI_ENTRYPOINT="./$base"
      break
    done
    if [[ -z "$CLI_ENTRYPOINT" ]]; then
      CLI_ENTRYPOINT="./$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-').sh"
      warn "No CLI script found. Using placeholder: ${CLI_ENTRYPOINT}"
      warn "Create this file or re-run with: --cli ./yourscript.sh"
    else
      info "CLI entrypoint: ${CLI_ENTRYPOINT}"
    fi
  fi

  # ── Template substitution helper ──────────────────────────────────
  apply_template() {
    local src="$1" dst="$2"
    sed \
      -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
      -e "s|{{CLI_ENTRYPOINT}}|${CLI_ENTRYPOINT}|g" \
      "$src" > "$dst"
  }

  TEMPLATE_DIR="$TEMP_DIR/templates"
  CREATED_COUNT=0
  SKIPPED_COUNT=0

  # ── Create directories ────────────────────────────────────────────
  mkdir -p specs
  mkdir -p .specify/memory
  mkdir -p "${TARGET}/instructions"
  mkdir -p "${TARGET}/docs"
  mkdir -p "${TARGET}/bubbles/docs"

  # ── Migration: rename old paths from pre-v2 installs ──────────────
  if [[ -d "${TARGET}/agents/_shared" && ! -d "${TARGET}/agents/bubbles_shared" ]]; then
    mv "${TARGET}/agents/_shared" "${TARGET}/agents/bubbles_shared"
    info "Migrated: agents/_shared → agents/bubbles_shared"
  fi
  for legacy_pair in \
    "agents.instructions.md:bubbles-agents.instructions.md" \
    "skills.instructions.md:bubbles-skills.instructions.md" \
    "docker-lifecycle-governance.instructions.md:bubbles-docker-lifecycle-governance.instructions.md"; do
    legacy_name=${legacy_pair%%:*}
    namespaced_name=${legacy_pair##*:}
    legacy_path="${TARGET}/instructions/${legacy_name}"
    namespaced_path="${TARGET}/instructions/${namespaced_name}"
    if [[ -f "${legacy_path}" ]]; then
      if [[ ! -f "${namespaced_path}" ]]; then
        mv "${legacy_path}" "${namespaced_path}"
        info "Migrated: instructions/${legacy_name} → instructions/${namespaced_name}"
      else
        rm "${legacy_path}"
        info "Removed legacy instruction: instructions/${legacy_name}"
      fi
    fi
  done
  for legacy_pair in \
    "skill-authoring:bubbles-skill-authoring" \
    "docker-port-standards:bubbles-docker-port-standards" \
    "spec-template-bdd:bubbles-spec-template-bdd" \
    "docker-lifecycle-governance:bubbles-docker-lifecycle-governance"; do
    legacy_name=${legacy_pair%%:*}
    namespaced_name=${legacy_pair##*:}
    legacy_path="${TARGET}/skills/${legacy_name}"
    namespaced_path="${TARGET}/skills/${namespaced_name}"
    if [[ -d "${legacy_path}" ]]; then
      if [[ ! -d "${namespaced_path}" ]]; then
        mv "${legacy_path}" "${namespaced_path}"
        info "Migrated: skills/${legacy_name} → skills/${namespaced_name}"
      else
        rm -rf "${legacy_path}"
        info "Removed legacy skill directory: skills/${legacy_name}"
      fi
    fi
  done
  # Migrate old script paths (scripts/bubbles*.sh → bubbles/scripts/)
  for old_script in "${TARGET}"/scripts/bubbles*.sh; do
    [[ -f "$old_script" ]] || continue
    base=$(basename "$old_script" | sed 's/^bubbles-//' | sed 's/^bubbles\.sh$/cli.sh/')
    if [[ -f "${TARGET}/bubbles/scripts/${base}" ]]; then
      rm "$old_script"
      info "Migrated: scripts/$(basename "$old_script") → bubbles/scripts/${base}"
    fi
  done
  # ── Scaffold: copilot-instructions.md ─────────────────────────────
  if [[ ! -f "${TARGET}/copilot-instructions.md" ]]; then
    if [[ -f "$TEMPLATE_DIR/copilot-instructions.md.tmpl" ]]; then
      apply_template "$TEMPLATE_DIR/copilot-instructions.md.tmpl" "${TARGET}/copilot-instructions.md"
      ok "Created ${TARGET}/copilot-instructions.md"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped ${TARGET}/copilot-instructions.md (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  # ── Scaffold: terminal-discipline.instructions.md ─────────────────
  if [[ ! -f "${TARGET}/instructions/terminal-discipline.instructions.md" ]]; then
    if [[ -f "$TEMPLATE_DIR/terminal-discipline.instructions.md.tmpl" ]]; then
      apply_template "$TEMPLATE_DIR/terminal-discipline.instructions.md.tmpl" \
        "${TARGET}/instructions/terminal-discipline.instructions.md"
      ok "Created ${TARGET}/instructions/terminal-discipline.instructions.md"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped ${TARGET}/instructions/terminal-discipline.instructions.md (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  # ── Scaffold: constitution.md ─────────────────────────────────────
  if [[ ! -f ".specify/memory/constitution.md" ]]; then
    if [[ -f "$TEMPLATE_DIR/constitution.md.tmpl" ]]; then
      apply_template "$TEMPLATE_DIR/constitution.md.tmpl" ".specify/memory/constitution.md"
      ok "Created .specify/memory/constitution.md"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/memory/constitution.md (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  # ── Scaffold: agents.md (command registry) ────────────────────────
  if [[ ! -f ".specify/memory/agents.md" ]]; then
    if [[ -f "$TEMPLATE_DIR/agents.md.tmpl" ]]; then
      apply_template "$TEMPLATE_DIR/agents.md.tmpl" ".specify/memory/agents.md"
      ok "Created .specify/memory/agents.md"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/memory/agents.md (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  # ── Scaffold: bubbles/docs/CROSS_PROJECT_SETUP.md ──────────────────────
  if [[ ! -f "${TARGET}/bubbles/docs/CROSS_PROJECT_SETUP.md" ]]; then
    cat > "${TARGET}/bubbles/docs/CROSS_PROJECT_SETUP.md" <<'CROSSEOF'
# Bubbles Cross-Project Setup

> Reference doc for applying Bubbles to this project.
> See `.github/agents/bubbles_shared/project-config-contract.md` for the full contract.

## Required Configuration Files

| File | Status |
|------|--------|
| `.github/copilot-instructions.md` | ✅ Created by bootstrap |
| `.github/instructions/terminal-discipline.instructions.md` | ✅ Created by bootstrap |
| `.specify/memory/constitution.md` | ✅ Created by bootstrap |
| `.specify/memory/agents.md` | ✅ Created by bootstrap |

## Customization Checklist

- [ ] Update CLI commands in `copilot-instructions.md` and `agents.md`
- [ ] Add project-specific test types and commands
- [ ] Add Docker/container configuration (if applicable)
- [ ] Add project-specific principles to `constitution.md`
- [ ] Add key file locations and code patterns
- [ ] Update terminal discipline with project-specific forbidden/required commands
CROSSEOF
  ok "Created ${TARGET}/bubbles/docs/CROSS_PROJECT_SETUP.md"
    CREATED_COUNT=$((CREATED_COUNT + 1))
  fi

  # ── Scaffold: bubbles/docs/SETUP_SOURCES.md ────────────────────────────
  if [[ ! -f "${TARGET}/bubbles/docs/SETUP_SOURCES.md" ]]; then
    cat > "${TARGET}/bubbles/docs/SETUP_SOURCES.md" <<'SRCEOF'
# Bubbles Setup Sources Registry

> Single source of truth for what `/bubbles.bootstrap` reviews.

## Internal Sources

| Source | Path | Purpose |
|--------|------|---------|
| Project config contract | `.github/agents/bubbles_shared/project-config-contract.md` | Required project configuration |
| Agent common governance | `.github/agents/bubbles_shared/agent-common.md` | Universal agent rules |
| Scope workflow | `.github/agents/bubbles_shared/scope-workflow.md` | Workflow templates |
| Workflows config | `.github/bubbles/workflows.yaml` | Workflow mode definitions |

## External Sources

> Add external libraries, skills, or references reviewed by bootstrap here.
SRCEOF
  ok "Created ${TARGET}/bubbles/docs/SETUP_SOURCES.md"
    CREATED_COUNT=$((CREATED_COUNT + 1))
  fi

  echo ""
  ok "Bootstrap complete: ${CREATED_COUNT} files created, ${SKIPPED_COUNT} skipped (already exist)"
fi

# ── Summary ─────────────────────────────────────────────────────────
echo ""
printf "${BOLD}${GREEN}🫧 DEEEE-CENT!${NC}\n"
echo ""

if [[ "$DO_BOOTSTRAP" == "true" ]]; then
  echo "Bubbles is installed and bootstrapped. Your project is ready."
  echo ""
  echo "  📁 Created:"
  echo "     specs/                                          — Feature/bug specs go here"
  echo "     .specify/memory/constitution.md                 — Project governance"
  echo "     .specify/memory/agents.md                       — Command registry"
  echo "     .github/copilot-instructions.md                 — Project policies"
  echo "     .github/instructions/terminal-discipline...md   — CLI discipline"
  echo ""
  printf "  ${YELLOW}⚠️  Action required:${NC} Update the TODO items in the generated files\n"
  echo "     to match your project's actual commands, paths, and config."
  echo ""
  echo "  Then open VS Code and run these agents in order:"
  echo ""
  echo "     /bubbles.commands                   — Auto-detect your project and regenerate agents.md"
  echo "     /bubbles.bootstrap mode: refresh    — Verify setup is complete"
  echo "     /bubbles.status                     — Check spec progress"
  echo "     /bubbles.analyst  <describe feature> — Start new feature work"
  echo "     /bubbles.workflow full-delivery      — Run the full pipeline"
else
  echo "Bubbles is installed. Next steps:"
  echo ""
  echo "  Option A — Full bootstrap (recommended for new projects):"
  echo "     Re-run with --bootstrap to scaffold project config:"
  printf "     ${CYAN}curl -fsSL .../install.sh | bash -s -- --bootstrap${NC}\n"
  echo ""
  echo "  Option B — Agents only install:"
  echo "     Re-run with --agents-only if you want to skip shared instructions and skills:"
  printf "     ${CYAN}curl -fsSL .../install.sh | bash -s -- --agents-only${NC}\n"
  echo ""
  echo "  Option C — Manual project setup on top of the shared install:"
  echo "     1. Add project-specific config to .github/copilot-instructions.md"
  echo "     2. Create .specify/memory/agents.md with your commands"
  echo "     3. Create .specify/memory/constitution.md with your principles"
  echo ""
  echo "  Then try:"
  echo "     /bubbles.workflow   — full orchestration"
  echo "     /bubbles.status     — check spec progress"
  echo "     /bubbles.plan       — scope out a feature"
fi
echo ""
echo "Docs:    https://github.com/${BUBBLES_REPO}"
echo "Update:  curl -fsSL https://raw.githubusercontent.com/${BUBBLES_REPO}/main/install.sh | bash"
echo ""
printf "${YELLOW}\"It ain't rocket appliances, but it works.\"${NC}\n"
