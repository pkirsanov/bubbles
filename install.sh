#!/usr/bin/env bash
# 🫧 Bubbles Installer — "It ain't rocket appliances."
# Installs or updates the Bubbles agent system into your repo.
#
# Usage:
#   curl -fsSL .../install.sh | bash                    # Install shared framework files
#   curl -fsSL .../install.sh | bash -s -- --agents-only  # Install agents/workflows/scripts only
#   curl -fsSL .../install.sh | bash -s -- --bootstrap  # Install + scaffold project config
#   curl -fsSL .../install.sh | bash -s -- --bootstrap --profile assured  # Install + scaffold with assured guidance
#   curl -fsSL .../install.sh | bash -s -- v1.0.0       # Pin to version
#   curl -fsSL .../install.sh | bash -s -- --bootstrap --cli ./myproject.sh --name "My Project"
#   bash /path/to/bubbles/install.sh --local-source /path/to/bubbles   # Install into another repo from a local checkout
#
set -euo pipefail

# ── Parse arguments ─────────────────────────────────────────────────
BUBBLES_REF="main"
DO_BOOTSTRAP=false
AGENTS_ONLY=false
CLI_OVERRIDE=""
NAME_OVERRIDE=""
ADOPTION_PROFILE=""
LOCAL_SOURCE=""
SOURCE_OVERRIDE_DIR="${BUBBLES_SOURCE_OVERRIDE_DIR:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bootstrap)   DO_BOOTSTRAP=true; shift ;;
    --agents-only) AGENTS_ONLY=true; shift ;;
    --cli)         CLI_OVERRIDE="$2"; shift 2 ;;
    --name)        NAME_OVERRIDE="$2"; shift 2 ;;
    --profile)     ADOPTION_PROFILE="$2"; shift 2 ;;
    --local-source) LOCAL_SOURCE="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: install.sh [REF] [OPTIONS]"
      echo ""
      echo "  REF                Git ref to install (default: main)"
      echo "  --bootstrap        Scaffold project config files after install"
      echo "  --profile ID       Select bootstrap adoption profile (foundation, delivery, production, or assured)"
      echo "  --cli ./foo.sh     Set CLI entrypoint (auto-detected if omitted)"
      echo "  --name \"My Proj\"   Set project name (auto-detected if omitted)"
      echo "  --agents-only      Skip shared instructions and skills"
      echo "  --local-source DIR Install into this downstream repo from a local Bubbles checkout instead of GitHub"
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

sha256_file() {
  local target_file="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target_file" | awk '{print $1}'
    return 0
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$target_file" | awk '{print $1}'
    return 0
  fi

  fail "sha256sum or shasum is required to write Bubbles provenance checksums"
}

# Batched sibling of sha256_file() for bulk snapshotting (OW-005). Reads
# newline-delimited paths (relative to base_dir) on stdin and emits
# "<sha256>\t<relative-path>", preserving input order. sha256_file() spawns two
# processes per file (the sha tool plus an awk to trim the path), which measured
# ~6s across ~775 managed files; this form spawns one per xargs batch instead.
sha256_batch() {
  local base_dir="$1"
  local -a sha_cmd

  if command -v sha256sum >/dev/null 2>&1; then
    sha_cmd=(sha256sum)
  elif command -v shasum >/dev/null 2>&1; then
    sha_cmd=(shasum -a 256)
  else
    fail "sha256sum or shasum is required to write Bubbles provenance checksums"
  fi

  # Hash from inside base_dir so the tool reports the relative path verbatim,
  # which keeps the emitted key identical to the manifest entry.
  (
    cd "$base_dir" 2>/dev/null || exit 0
    tr '\n' '\0' | xargs -0 "${sha_cmd[@]}" 2>/dev/null
  ) | awk '{ hash = $1; sub(/^[^ ]+[ ]+/, ""); print hash "\t" $0 }'
}

# ── Preflight ───────────────────────────────────────────────────────
if [[ -z "$LOCAL_SOURCE" ]]; then
  command -v curl >/dev/null 2>&1 || fail "curl is required. Install it first."
  command -v tar  >/dev/null 2>&1 || fail "tar is required. Install it first."
fi

if [[ ! -d ".git" ]]; then
  fail "Not a git repo. Run this from your project root."
fi

CURRENT_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
if [[ -f "$CURRENT_REPO_ROOT/install.sh" && -f "$CURRENT_REPO_ROOT/VERSION" && -d "$CURRENT_REPO_ROOT/agents" && -d "$CURRENT_REPO_ROOT/prompts" && -d "$CURRENT_REPO_ROOT/bubbles" && -f "$CURRENT_REPO_ROOT/bubbles/scripts/cli.sh" ]]; then
  fail "Do not run install.sh inside the Bubbles source repository. The installer is for downstream repos only. In the source repo, edit framework files directly and validate with 'bash bubbles/scripts/cli.sh framework-validate' or 'bash bubbles/scripts/cli.sh release-check'."
fi

# ── Source acquisition ──────────────────────────────────────────────
if [[ -n "$LOCAL_SOURCE" ]]; then
  TEMP_DIR="$LOCAL_SOURCE"
  info "Installing Bubbles from local source: ${LOCAL_SOURCE}"
  [[ -d "$TEMP_DIR/agents" ]] || fail "Local source missing agents/: ${LOCAL_SOURCE}"
  [[ -d "$TEMP_DIR/prompts" ]] || fail "Local source missing prompts/: ${LOCAL_SOURCE}"
  [[ -d "$TEMP_DIR/bubbles" ]] || fail "Local source missing bubbles/: ${LOCAL_SOURCE}"
elif [[ -n "$SOURCE_OVERRIDE_DIR" ]]; then
  TEMP_DIR="$SOURCE_OVERRIDE_DIR"
  info "Installing Bubbles ${BUBBLES_REF} from local source override"
  [[ -d "$TEMP_DIR/agents" ]] || fail "Source override missing agents/: ${SOURCE_OVERRIDE_DIR}"
  [[ -d "$TEMP_DIR/prompts" ]] || fail "Source override missing prompts/: ${SOURCE_OVERRIDE_DIR}"
  [[ -d "$TEMP_DIR/bubbles" ]] || fail "Source override missing bubbles/: ${SOURCE_OVERRIDE_DIR}"
else
  info "Downloading Bubbles ${BUBBLES_REF}..."
  TEMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TEMP_DIR"' EXIT

  curl -fsSL "https://github.com/${BUBBLES_REPO}/archive/refs/heads/${BUBBLES_REF}.tar.gz" \
    -o "$TEMP_DIR/bubbles.tar.gz" 2>/dev/null \
    || curl -fsSL "https://github.com/${BUBBLES_REPO}/archive/refs/tags/${BUBBLES_REF}.tar.gz" \
      -o "$TEMP_DIR/bubbles.tar.gz" 2>/dev/null \
    || fail "Could not download Bubbles ref '${BUBBLES_REF}'. Check the version/branch name."

  tar xzf "$TEMP_DIR/bubbles.tar.gz" -C "$TEMP_DIR" --strip-components=1
fi

TRUST_HELPERS="$TEMP_DIR/bubbles/scripts/trust-metadata.sh"
[[ -f "$TRUST_HELPERS" ]] || fail "Missing trust metadata helpers in source payload"
# shellcheck source=/dev/null  # dynamic path resolved from the extracted payload at install time
source "$TRUST_HELPERS"

RELEASE_MANIFEST_SOURCE="$TEMP_DIR/bubbles/release-manifest.json"
GENERATED_LOCAL_MANIFEST=""
if [[ -n "$LOCAL_SOURCE" ]]; then
  if bubbles_owns_git_checkout "$TEMP_DIR"; then
    GENERATED_LOCAL_MANIFEST="$(mktemp)"
    trap '[[ -n "$GENERATED_LOCAL_MANIFEST" ]] && rm -f "$GENERATED_LOCAL_MANIFEST"' EXIT
    bash "$TEMP_DIR/bubbles/scripts/generate-release-manifest.sh" --repo-root "$TEMP_DIR" --output "$GENERATED_LOCAL_MANIFEST"
    RELEASE_MANIFEST_SOURCE="$GENERATED_LOCAL_MANIFEST"
  elif [[ -f "$TEMP_DIR/bubbles/release-manifest.json" ]]; then
    RELEASE_MANIFEST_SOURCE="$TEMP_DIR/bubbles/release-manifest.json"
  else
    fail "Local source is not a git checkout and does not contain bubbles/release-manifest.json"
  fi
fi

[[ -f "$RELEASE_MANIFEST_SOURCE" ]] || fail "Missing release manifest in source payload. Run bubbles/scripts/generate-release-manifest.sh before installing."

release_manifest_owns_managed_path() {
  local relative_path="$1"

  awk -v relative_path="$relative_path" '
    BEGIN {
      section_line="  \"managedFileChecksums\": ["
      expected_prefix="    {\"path\": \"" relative_path "\", \"sha256\": \""
    }
    $0 == section_line { in_section=1; next }
    in_section && ($0 == "  ]," || $0 == "  ]") { exit }
    in_section && index($0, expected_prefix) == 1 { found=1; exit }
    END { exit found ? 0 : 1 }
  ' "$RELEASE_MANIFEST_SOURCE"
}

ADOPTION_PROFILES_SOURCE="$TEMP_DIR/bubbles/adoption-profiles.yaml"
[[ -f "$ADOPTION_PROFILES_SOURCE" ]] || fail "Missing adoption profile registry in source payload."

adoption_profile_ids() {
  awk '
    /^profiles:/ { in_profiles=1; next }
    in_profiles && /^  [A-Za-z0-9_-]+:$/ {
      profile=$1
      sub(":$", "", profile)
      print profile
    }
  ' "$ADOPTION_PROFILES_SOURCE"
}

adoption_profile_value() {
  local profile="$1"
  local key="$2"

  awk -v profile="$profile" -v key="$key" '
    /^profiles:/ { in_profiles=1; next }
    in_profiles && $0 ~ ("^  " profile ":$") { in_profile=1; next }
    in_profile && /^  [A-Za-z0-9_-]+:$/ { in_profile=0 }
    in_profile && $0 ~ ("^    " key ":") {
      sub("^    " key ":[[:space:]]*", "", $0)
      gsub(/^"|"$/, "", $0)
      print
      exit
    }
  ' "$ADOPTION_PROFILES_SOURCE"
}

profile_supported() {
  local requested_profile="$1"
  local known_profile

  while IFS= read -r known_profile; do
    [[ -n "$known_profile" ]] || continue
    if [[ "$known_profile" == "$requested_profile" ]]; then
      return 0
    fi
  done < <(adoption_profile_ids)

  return 1
}

persist_adoption_profile() {
  local config_file="$1"
  local selected_profile="$2"

  [[ -f "$config_file" ]] || fail "Cannot persist adoption profile; missing config file: $config_file"

  if grep -q '"adoptionProfile"' "$config_file"; then
    perl -0pi -e 's/"adoptionProfile"\s*:\s*"[^"]+"/"adoptionProfile": "'"$selected_profile"'"/' "$config_file"
  else
    perl -0pi -e 's/(\{\n  "version": [0-9]+,\n)/$1  "adoptionProfile": "'"$selected_profile"'",\n/' "$config_file"
  fi
}

SELECTED_ADOPTION_PROFILE="${ADOPTION_PROFILE:-delivery}"

profile_supported "$SELECTED_ADOPTION_PROFILE" || fail "Unknown adoption profile '${SELECTED_ADOPTION_PROFILE}'. Supported profiles: $(adoption_profile_ids | tr '\n' ' ' | sed 's/[[:space:]]*$//')"

if [[ "$DO_BOOTSTRAP" != "true" && -n "$ADOPTION_PROFILE" ]]; then
  fail "--profile requires --bootstrap so the selected adoption profile can be written into repo-local policy state."
fi

SELECTED_PROFILE_LABEL="$(adoption_profile_value "$SELECTED_ADOPTION_PROFILE" label)"
SELECTED_PROFILE_SUMMARY="$(adoption_profile_value "$SELECTED_ADOPTION_PROFILE" bootstrapSummary)"
SELECTED_PROFILE_INVARIANT="$(adoption_profile_value "$SELECTED_ADOPTION_PROFILE" governanceInvariant)"

# ── Orphan-prune helpers for framework-managed mirror directories ────
# When a release REMOVES a framework-managed agent / prompt / instruction /
# skill, an already-installed downstream keeps the orphan unless it is pruned.
# The v7.3.2 prune covered only bubbles/scripts/ + guards/; this generalizes that
# hardening to the remaining managed mirrors (IMP-008).
#
# Trust anchor: the PREVIOUS install's manifest (${TARGET}/bubbles/.manifest),
# which lists exactly the files the framework owned last time. An entry is an
# orphan iff it was framework-owned (present in the old manifest) AND the NEW
# source payload ($TEMP_DIR) no longer ships it. Operator-owned files (never in
# the manifest) are therefore NEVER touched. On a first install there is no old
# manifest, so nothing is pruned. The new manifest is written post-copy, so the
# old one is still intact when these run.
PRE_INSTALL_MANIFEST="${TARGET}/bubbles/.manifest"

bubbles_prune_managed_file_orphans() {
  # $1 = manifest path prefix to scope the prune (e.g. "agents/", "prompts/",
  # "instructions/"). Matches flat managed files (a leading "agents/" prefix also
  # covers agents/bubbles_shared/*).
  local prefix="$1"
  [[ -f "$PRE_INSTALL_MANIFEST" ]] || return 0
  local entry
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    [[ "$entry" == \#* ]] && continue
    [[ "$entry" == "$prefix"* ]] || continue
    if [[ ! -e "$TEMP_DIR/$entry" && -e "${TARGET}/$entry" ]]; then
      rm -f "${TARGET}/$entry"
      info "Pruned orphan framework file: $entry"
    fi
  done < "$PRE_INSTALL_MANIFEST"
}

bubbles_prune_managed_skill_orphans() {
  # Skills are dir-per-skill (skills/<name>/...). A framework skill whose <name>
  # the old manifest recorded but the new source dropped is removed whole.
  [[ -f "$PRE_INSTALL_MANIFEST" ]] || return 0
  local skill_name
  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    if [[ ! -d "$TEMP_DIR/skills/$skill_name" && -d "${TARGET}/skills/$skill_name" ]]; then
      rm -rf "${TARGET:?}/skills/${skill_name}"
      info "Pruned orphan framework skill: skills/${skill_name}"
    fi
  done < <(grep -oE '^skills/[^/]+/' "$PRE_INSTALL_MANIFEST" | sort -u | sed -e 's#^skills/##' -e 's#/$##')
}

bubbles_prune_managed_tree_orphans() {
  # $1 = framework-managed directory relative to ${TARGET} and ${TEMP_DIR}.
  # Files absent from the new source or its managed checksum contract are stale
  # and must not survive an upgrade. This mirrors the scripts/ + guards/ prune.
  local relative_dir="$1"
  local installed_root="${TARGET}/${relative_dir}"
  local installed_file
  local relative_path

  [[ -d "$installed_root" ]] || return 0
  while IFS= read -r installed_file; do
    [[ -f "$installed_file" ]] || continue
    relative_path="${installed_file#${TARGET}/}"
    if [[ ! -f "$TEMP_DIR/$relative_path" ]] || \
      ! release_manifest_owns_managed_path "$relative_path"; then
      rm -f "$installed_file"
      info "Pruned orphan framework file: $relative_path"
    fi
  done < <(find "$installed_root" -type f 2>/dev/null | LC_ALL=C sort)
}

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

# Prune orphan framework agents/prompts removed upstream (IMP-008). The leading
# "agents/" prefix also covers agents/bubbles_shared/*; operator-authored agents
# (never in the manifest) are untouched.
bubbles_prune_managed_file_orphans "agents/"
bubbles_prune_managed_file_orphans "prompts/"

# ── Install workflows ───────────────────────────────────────────────
info "Installing workflow config and registries..."
mkdir -p "${TARGET}/bubbles"
cp "$TEMP_DIR"/bubbles/*.yaml "${TARGET}/bubbles/" 2>/dev/null || true
if [[ -f "$TEMP_DIR/bubbles/agnosticity-allowlist.txt" ]]; then
  cp "$TEMP_DIR"/bubbles/agnosticity-allowlist.txt "${TARGET}/bubbles/"
fi
if [[ -f "$TEMP_DIR/bubbles/requirements.txt" ]]; then
  cp "$TEMP_DIR"/bubbles/requirements.txt "${TARGET}/bubbles/"
fi
cp "$RELEASE_MANIFEST_SOURCE" "${TARGET}/bubbles/release-manifest.json"
ok "workflows.yaml + registries installed"

# ── Install scripts ─────────────────────────────────────────────────
info "Installing governance scripts..."
mkdir -p "${TARGET}/bubbles/scripts"
cp "$TEMP_DIR"/bubbles/scripts/*.sh "${TARGET}/bubbles/scripts/"
chmod +x "${TARGET}"/bubbles/scripts/*.sh
# Top-level Python framework scripts (e.g. scope-universe-resolver.py, BUG-026)
# are manifest-managed like the *.sh scripts and MUST be installed too, or a
# downstream guard that invokes them would hit a missing file. The *.sh glob
# above does not match them; the guard `[[ -f ]]` handles the no-match case.
for py_script in "$TEMP_DIR"/bubbles/scripts/*.py; do
  [[ -f "$py_script" ]] || continue
  cp "$py_script" "${TARGET}/bubbles/scripts/"
  chmod +x "${TARGET}/bubbles/scripts/$(basename "$py_script")"
done
# Prune stale framework scripts: remove any installed bubbles/scripts/*.sh that
# no longer exists in the source payload. .github/bubbles/scripts/ is a
# framework-managed directory (project-owned scripts live in top-level scripts/),
# so mirroring the source set is safe and prevents an orphaned script — e.g. a
# guard or selftest removed upstream in a later release — from lingering and
# breaking downstream validation. (registry-consistency-selftest scans every
# installed script for gate IDs; an orphan referencing a since-removed gate
# fails the whole run.)
for installed_script in "${TARGET}"/bubbles/scripts/*.sh; do
  [[ -e "$installed_script" ]] || continue
  script_base="$(basename "$installed_script")"
  if [[ ! -f "$TEMP_DIR/bubbles/scripts/$script_base" ]] || \
    ! release_manifest_owns_managed_path "bubbles/scripts/$script_base"; then
    rm -f "$installed_script"
  fi
done
# bubbles/scripts/guards/ holds the sourced check-fragments that
# state-transition-guard.sh loads (v6.1 / M4 split). The top-level *.sh glob
# above does NOT descend into subdirectories, so the guards/ fragments MUST be
# copied explicitly or downstream guard runs would `source` a missing file and
# hard-fail. Fragments are sourced (not executed), so the exec bit is optional.
if [[ -d "$TEMP_DIR/bubbles/scripts/guards" ]]; then
  mkdir -p "${TARGET}/bubbles/scripts/guards"
  cp -R "$TEMP_DIR"/bubbles/scripts/guards/. "${TARGET}/bubbles/scripts/guards/"
  # Prune stale guard fragments the same way (mirror the source guards/ set).
  for installed_guard in "${TARGET}"/bubbles/scripts/guards/*.sh; do
    [[ -e "$installed_guard" ]] || continue
    guard_base="$(basename "$installed_guard")"
    if [[ ! -f "$TEMP_DIR/bubbles/scripts/guards/$guard_base" ]] || \
      ! release_manifest_owns_managed_path "bubbles/scripts/guards/$guard_base"; then
      rm -f "$installed_guard"
    fi
  done
fi

# bubbles/scripts/hooks/ contains the framework-maintainer hook payload used by
# install-bubbles-hooks.sh. The top-level scripts glob is non-recursive, so this
# managed tree needs an explicit copy + prune just like guards/.
if [[ -d "$TEMP_DIR/bubbles/scripts/hooks" ]]; then
  info "Installing framework hook payload..."
  mkdir -p "${TARGET}/bubbles/scripts/hooks"
  cp -R "$TEMP_DIR"/bubbles/scripts/hooks/. "${TARGET}/bubbles/scripts/hooks/"
  find "${TARGET}/bubbles/scripts/hooks" -type f -name '*.sh' -exec chmod +x {} \;
  bubbles_prune_managed_tree_orphans "bubbles/scripts/hooks"
  ok "$(find "${TARGET}/bubbles/scripts/hooks" -type f 2>/dev/null | wc -l) framework hook file(s) installed"
fi
ok "$(ls "${TARGET}"/bubbles/scripts/*.sh | wc -l) scripts installed$([[ -d "${TARGET}/bubbles/scripts/guards" ]] && echo " (+$(ls "${TARGET}"/bubbles/scripts/guards/*.sh 2>/dev/null | wc -l) guard fragments)")"

# ── Install adapters ─────────────────────────────────────────────────
if [[ -d "$TEMP_DIR/bubbles/adapters" ]]; then
  info "Installing framework adapters..."
  mkdir -p "${TARGET}/bubbles/adapters"
  cp -R "$TEMP_DIR"/bubbles/adapters/. "${TARGET}/bubbles/adapters/"
  find "${TARGET}/bubbles/adapters" -type f -name '*.sh' -exec chmod +x {} \;
  ok "$(find "${TARGET}/bubbles/adapters" -type f 2>/dev/null | wc -l) adapter file(s) installed"
fi

# ── Observability posture reminder (READ-ONLY; never writes config) ───
# IMP-001 SCOPE-5 (T5.4). After the framework/adapter copy, surface a one-line
# reminder when the repo has NOT declared an observability posture, or when its
# opt-out has expired. This is ADVISORY only: it resolves the posture via the
# G098 guard's read-only `--print-state` query and PRINTS a reminder. It does
# NOT write or scaffold `bubbles-project.yaml` — the operator declares posture
# later via `/bubbles.setup focus: observability`. A missing yq parser resolves
# to UNAVAILABLE (no reminder); never a failure.
OBS_POSTURE_GUARD="${TARGET}/bubbles/scripts/observability-posture-guard.sh"
if [[ -f "$OBS_POSTURE_GUARD" ]]; then
  OBS_STATE="$(bash "$OBS_POSTURE_GUARD" --print-state --repo-root . 2>/dev/null || echo 'UNAVAILABLE')"
  case "$OBS_STATE" in
    UNDECLARED)
      warn "Observability posture is UNDECLARED — run '/bubbles.setup focus: observability' to declare wired|opted-out. (advisory; no config was written)" ;;
    OPTED-OUT-EXPIRED*)
      warn "Observability opt-out EXPIRED (revisitAfter ${OBS_STATE#OPTED-OUT-EXPIRED|}) — run '/bubbles.setup focus: observability' to re-open the decision. (advisory; no config was written)" ;;
  esac
fi

# ── Install JSON Schemas (v5.0.1) ─────────────────────────────────────
# Schemas for workflows/capability-ledger/adoption-profiles let downstream
# repos run yaml-schema-validate.sh locally before commits.
if [[ -d "$TEMP_DIR/bubbles/schemas" ]]; then
  info "Installing framework schemas..."
  mkdir -p "${TARGET}/bubbles/schemas"
  cp -R "$TEMP_DIR"/bubbles/schemas/. "${TARGET}/bubbles/schemas/"
  ok "$(find "${TARGET}/bubbles/schemas" -type f 2>/dev/null | wc -l) schema file(s) installed"
fi

# ── Install the managed adversarial-sample record schema (BUG015-F2) ──
# The installed agents/bubbles_shared/agent-common.md red-team contract names
# bubbles/eval/schemas/adversarial-sample.schema.json as the authoritative record
# schema (version 1). It is manifest-managed (trust-metadata.sh), so it MUST ship
# downstream at its exact referenced path or record-producing agents and reviewers
# cannot resolve it. Copy ONLY this single file — task-v2/evaluator-result stay
# source-only (BUG015-F1 demoted the eval-harness that consumes them), so this is
# never a whole-directory copy of bubbles/eval/schemas/.
ADVERSARIAL_SAMPLE_SCHEMA="bubbles/eval/schemas/adversarial-sample.schema.json"
if [[ -f "$TEMP_DIR/$ADVERSARIAL_SAMPLE_SCHEMA" ]]; then
  info "Installing adversarial-sample record schema..."
  mkdir -p "${TARGET}/bubbles/eval/schemas"
  cp "$TEMP_DIR/$ADVERSARIAL_SAMPLE_SCHEMA" "${TARGET}/$ADVERSARIAL_SAMPLE_SCHEMA"
  ok "adversarial-sample record schema installed"
fi

# ── Install registry (v5.2.1 / F4 installer fix) ──────────────────────
# bubbles/registry/gates.yaml is canonical for gate definitions starting
# in v5.2. generate-gates-block.sh splices it back into workflows.yaml.
# Drift detection in framework-validate requires this file to be present.
if [[ -d "$TEMP_DIR/bubbles/registry" ]]; then
  info "Installing framework registry..."
  mkdir -p "${TARGET}/bubbles/registry"
  cp -R "$TEMP_DIR"/bubbles/registry/. "${TARGET}/bubbles/registry/"
  ok "$(find "${TARGET}/bubbles/registry" -type f 2>/dev/null | wc -l) registry file(s) installed"
fi

# ── Install MCP server + catalogs (v6.0 / A1-A6) ──────────────────────
# bubbles/mcp/ contains the Python MCP server, declarative tool catalog
# (JSON), declarative resource catalog (JSON), and sample client config
# snippets (vscode/claude/cursor/cline). The MCP server is OPTIONAL —
# downstream repos that don't register it still get every Bubbles gate
# via the bash scripts. But we install the surface unconditionally so
# operators can register the MCP server later without re-running install.
if [[ -d "$TEMP_DIR/bubbles/mcp" ]]; then
  info "Installing MCP server + catalog..."
  mkdir -p "${TARGET}/bubbles/mcp"
  cp -R "$TEMP_DIR"/bubbles/mcp/. "${TARGET}/bubbles/mcp/"
  ok "$(find "${TARGET}/bubbles/mcp" -type f 2>/dev/null | wc -l) MCP file(s) installed"
fi

# ── Register the Bubbles MCP server in .vscode/mcp.json (unique id) ────
# VS Code reads each workspace folder's own .vscode/mcp.json. When several
# folders in a multi-root workspace all register a server under the SAME
# generic id ("bubbles"), the editor's MCP gateway cannot disambiguate the
# duplicates and silently refuses to start any of them — the server shows a
# perpetual "Update Tools"/refresh state and never connects or surfaces its
# tools. To make the server start cleanly in single- AND multi-root setups,
# we register it under a UNIQUE per-repo id (bubbles-<repo-slug>) derived
# from the repo directory name, and we manage ONLY that one entry. Every
# other server in the file is operator-owned and left untouched; the file
# itself remains project-owned. A legacy generic "bubbles" entry is migrated
# to the unique id (its operator-added env is preserved). This step is a
# no-op on re-install when the entry is already current.
if command -v python3 >/dev/null 2>&1; then
  info "Registering Bubbles MCP server in .vscode/mcp.json (unique per-repo id)..."
  mcp_repo_basename="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
  mcp_repo_slug="$(printf '%s' "$mcp_repo_basename" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//')"
  [[ -n "$mcp_repo_slug" ]] || mcp_repo_slug="repo"
  mcp_server_id="bubbles-${mcp_repo_slug}"
  mkdir -p .vscode
  set +e
  BUBBLES_MCP_SERVER_ID="$mcp_server_id" python3 - ".vscode/mcp.json" <<'PYEOF'
import json
import os
import sys

path = sys.argv[1]
server_id = os.environ["BUBBLES_MCP_SERVER_ID"]
canonical = {
    "type": "stdio",
    "command": "python3",
    "args": ["${workspaceFolder}/.github/bubbles/mcp/server.py"],
    "env": {"BUBBLES_MCP_LOG_LEVEL": "INFO"},
}

original_text = None
doc = {}
if os.path.isfile(path):
    try:
        with open(path, encoding="utf-8") as handle:
            original_text = handle.read()
        doc = json.loads(original_text) if original_text.strip() else {}
    except (ValueError, OSError):
        sys.exit(3)  # not parseable JSON — leave the operator's file untouched

if not isinstance(doc, dict):
    sys.exit(3)

servers = doc.get("servers")
if not isinstance(servers, dict):
    servers = {}

# Preserve operator-added env when migrating a legacy generic "bubbles"
# entry (or refreshing our own unique entry) to the unique per-repo id.
preserved_env = {}
for key in ("bubbles", server_id):
    existing = servers.get(key)
    if isinstance(existing, dict) and isinstance(existing.get("env"), dict):
        preserved_env.update(existing["env"])

if server_id != "bubbles":
    servers.pop("bubbles", None)

entry = dict(canonical)
merged_env = dict(canonical["env"])
merged_env.update(preserved_env)
entry["env"] = merged_env
servers[server_id] = entry
doc["servers"] = servers

new_text = json.dumps(doc, indent=4) + "\n"
if original_text == new_text:
    sys.exit(4)  # already registered and current — nothing to write

with open(path, "w", encoding="utf-8") as handle:
    handle.write(new_text)
sys.exit(0)
PYEOF
  mcp_register_rc=$?
  set -e
  case "$mcp_register_rc" in
    0) ok "Bubbles MCP server registered as '${mcp_server_id}' in .vscode/mcp.json" ;;
    4) ok "Bubbles MCP server already current as '${mcp_server_id}' in .vscode/mcp.json" ;;
    3) warn ".vscode/mcp.json is not valid JSON — left it untouched. Add a '${mcp_server_id}' server entry by hand (see ${TARGET}/bubbles/mcp/clients/vscode.json)." ;;
    *) warn "Could not register Bubbles MCP server in .vscode/mcp.json (python3 exit ${mcp_register_rc})." ;;
  esac
else
  warn "python3 not found — skipped .vscode/mcp.json registration (the Bubbles MCP server requires python3)."
fi

# ── Install workflow alias map (v6.0 / B4) ────────────────────────────
# bubbles/workflows/ holds the v5 -> v6 primitive+tag alias map and any
# other future per-workflow-family YAML. The mode-resolver consults the
# alias map to translate legacy v5 mode strings to v6 primitive+tag form.
# v5 names remain valid through the entire v6 cycle.
if [[ -d "$TEMP_DIR/bubbles/workflows" ]]; then
  info "Installing workflow alias map..."
  mkdir -p "${TARGET}/bubbles/workflows"
  cp -R "$TEMP_DIR"/bubbles/workflows/. "${TARGET}/bubbles/workflows/"
  ok "$(find "${TARGET}/bubbles/workflows" -type f 2>/dev/null | wc -l) workflow alias file(s) installed"
fi

# ── Install installer manifest (v6.0 / B9) ────────────────────────────
# bubbles/installer/installer.yaml is the typed enumeration of every
# step install.sh performs. Consumed by
# bubbles/scripts/generate-installer.sh --check so downstream
# re-validators can verify that install.sh actually implements every
# declared step. Closes adapter/gitignore/missing-chmod bug classes.
if [[ -d "$TEMP_DIR/bubbles/installer" ]]; then
  info "Installing installer manifest..."
  mkdir -p "${TARGET}/bubbles/installer"
  cp -R "$TEMP_DIR"/bubbles/installer/. "${TARGET}/bubbles/installer/"
  ok "$(find "${TARGET}/bubbles/installer" -type f 2>/dev/null | wc -l) installer manifest file(s) installed"
fi

# bubbles/cheatsheet/ is the managed source registry consumed by the installed
# generate-cheatsheet.sh. The generated docs are not a substitute for these
# inputs; downstream regeneration and freshness checks require the registry.
if [[ -d "$TEMP_DIR/bubbles/cheatsheet" ]]; then
  info "Installing cheatsheet registry..."
  mkdir -p "${TARGET}/bubbles/cheatsheet"
  cp -R "$TEMP_DIR"/bubbles/cheatsheet/. "${TARGET}/bubbles/cheatsheet/"
  bubbles_prune_managed_tree_orphans "bubbles/cheatsheet"
  ok "$(find "${TARGET}/bubbles/cheatsheet" -type f 2>/dev/null | wc -l) cheatsheet registry file(s) installed"
fi

# Framework-health proposals are downstream-local scratch by default. Keep this
# outside --bootstrap so normal upgrades also preserve the documented behavior.
# .gitignore lives at the repo root (cwd), NOT under .github/.
if [[ ! -f ".gitignore" ]]; then
  touch ".gitignore"
fi
if ! grep -qx 'improvements/' ".gitignore" 2>/dev/null; then
  printf '\n# Bubbles framework-health proposals (downstream-local)\nimprovements/\n' >> ".gitignore"
  ok "Added improvements/ to .gitignore"
fi

# ── Install bootstrap scaffolding assets ───────────────────────────
if [[ -d "$TEMP_DIR/templates" ]]; then
  info "Installing bootstrap templates..."
  mkdir -p "${TARGET}/templates"
  cp "$TEMP_DIR"/templates/* "${TARGET}/templates/" 2>/dev/null || true
  ok "$(find "${TARGET}/templates" -type f 2>/dev/null | wc -l) bootstrap templates installed"
fi

if [[ -d "$TEMP_DIR/.specify" ]]; then
  info "Installing bootstrap defaults..."
  mkdir -p "${TARGET}/.specify/memory" "${TARGET}/.specify/metrics" "${TARGET}/.specify/runtime"
  [[ -f "$TEMP_DIR/.specify/memory/bubbles.config.json" ]] && cp "$TEMP_DIR/.specify/memory/bubbles.config.json" "${TARGET}/.specify/memory/bubbles.config.json"
  [[ -f "$TEMP_DIR/.specify/memory/.gitignore" ]] && cp "$TEMP_DIR/.specify/memory/.gitignore" "${TARGET}/.specify/memory/.gitignore"
  [[ -f "$TEMP_DIR/.specify/metrics/.gitignore" ]] && cp "$TEMP_DIR/.specify/metrics/.gitignore" "${TARGET}/.specify/metrics/.gitignore"
  [[ -f "$TEMP_DIR/.specify/runtime/.gitignore" ]] && cp "$TEMP_DIR/.specify/runtime/.gitignore" "${TARGET}/.specify/runtime/.gitignore"
  ok "bootstrap defaults installed"
fi

# ── Install framework docs ──────────────────────────────────────────
if [[ -d "$TEMP_DIR/docs" ]]; then
  info "Installing framework docs..."
  mkdir -p "${TARGET}/docs"
  cp -r "$TEMP_DIR"/docs/* "${TARGET}/docs/" 2>/dev/null || true
  ok "$(find "${TARGET}/docs" -type f 2>/dev/null | wc -l) framework docs installed"
fi

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
# Optional (opt-in) skill gating (design-language skills, etc.). A skill listed
# in the source payload's bubbles/registry/optional-skills.txt is vendored ONLY
# when the downstream repo opts in via `.github/bubbles-project.yaml`
# `designLanguages`. Otherwise it is skipped, and a stale prior opt-in copy is
# pruned (opt-out). This keeps a niche / premium skill physically absent — and
# therefore non-loading — in repos that have not enabled it.
BUBBLES_OPTIONAL_SKILLS_REGISTRY="$TEMP_DIR/bubbles/registry/optional-skills.txt"

bubbles_project_config_path() {
  if [[ -f "${TARGET}/bubbles-project.yaml" ]]; then
    printf '%s' "${TARGET}/bubbles-project.yaml"
  elif [[ -f "bubbles-project.yaml" ]]; then
    printf '%s' "bubbles-project.yaml"
  fi
}

bubbles_design_language_enabled() {
  # $1 = enablement token. Enabled iff the project config's designLanguages:
  # block contains the token (substring match — friendly alias or full skill
  # name both match). No yq dependency.
  local token="$1" cfg
  cfg="$(bubbles_project_config_path)"
  [[ -n "$cfg" ]] || return 1
  awk '/^designLanguages:/{f=1; next} /^[A-Za-z0-9_-]+:/{f=0} f' "$cfg" | grep -qiF "$token"
}

bubbles_optional_skill_token() {
  # $1 = skill dir name. Prints the enablement token and returns 0 if the skill
  # is optional (listed in the registry); returns 1 if it is a normal skill.
  [[ -f "$BUBBLES_OPTIONAL_SKILLS_REGISTRY" ]] || return 1
  local want="$1" name token rest
  while read -r name token rest; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    if [[ "$name" == "$want" ]]; then
      printf '%s' "${token:-$name}"
      return 0
    fi
  done < "$BUBBLES_OPTIONAL_SKILLS_REGISTRY"
  return 1
}

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
      # Opt-in gating for optional skills (e.g. design-language skills).
      if opt_token="$(bubbles_optional_skill_token "$skill_name")"; then
        if ! bubbles_design_language_enabled "$opt_token"; then
          # Not opted in: skip vendoring; prune a stale prior opt-in copy.
          if [[ -d "${TARGET}/skills/${skill_name}" ]]; then
            rm -rf "${TARGET:?}/skills/${skill_name}"
            info "Pruned opted-out optional skill: skills/${skill_name}"
          fi
          continue
        fi
        info "Optional skill opted in: skills/${skill_name}"
      fi
      mkdir -p "${TARGET}/skills/${skill_name}"
      cp -r "${skill_dir}"* "${TARGET}/skills/${skill_name}/" 2>/dev/null || true
    done
    ok "$(find "${TARGET}/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l) shared skills installed"
  fi

  # Prune orphan framework instructions/skills removed upstream (IMP-008).
  # Keyed on the old manifest, so operator-authored instruction files and skill
  # directories (never framework-managed) are never removed.
  bubbles_prune_managed_file_orphans "instructions/"
  bubbles_prune_managed_skill_orphans
fi

# ── Payload integrity verification (IMP-101 SCOPE-8) ────────────────
# Every managed file has now been copied. The .checksums snapshot written below
# is computed FROM the installed bytes, so it cannot detect a payload that
# arrived corrupt (truncated download, failed extraction, partial disk write, a
# single tampered file). Before we stamp + snapshot the install, verify every
# installed framework file against the CANONICAL sha256 recorded in the release
# manifest's managedFileChecksums. INTEGRITY only, not authenticity: a
# coordinated tamper of BOTH a file AND its manifest entry needs a signed
# manifest (keys the operator does not hold at install time; deferred) — this
# closes the corruption / incomplete-download / single-file-tamper class at zero
# key-management cost. The verifier is a managed script already copied above;
# guard on its presence so an older payload lacking it never breaks the install.
PAYLOAD_VERIFIER="$TEMP_DIR/bubbles/scripts/verify-payload-integrity.sh"
if [[ -f "$PAYLOAD_VERIFIER" ]]; then
  PAYLOAD_INSTALL_PROFILE="full"
  [[ "$AGENTS_ONLY" == "true" ]] && PAYLOAD_INSTALL_PROFILE="agents-only"
  info "Verifying payload integrity against release manifest..."
  # --require-manifest: this is a REAL install, and install.sh already refused to
  # proceed without a source manifest (see the RELEASE_MANIFEST_SOURCE preflight).
  # Passing the flag makes the verifier fail hard (never green-skip) if the manifest
  # is somehow absent at verify time — closing the incomplete-payload gap where a
  # missing manifest would otherwise return an advisory exit 0 (IMP-102 SCOPE-6).
  if bash "$PAYLOAD_VERIFIER" \
    --target "$TARGET" \
    --manifest "$RELEASE_MANIFEST_SOURCE" \
    --install-profile "$PAYLOAD_INSTALL_PROFILE" \
    --require-manifest \
    --quiet; then
    ok "Payload integrity verified against release manifest"
  else
    fail "Payload integrity check failed — installed framework files do not match the release manifest checksums (corruption or incomplete download). Re-run the installer; if this persists, the downloaded payload is corrupt or was modified in transit."
  fi
else
  # IMP-027 SCOPE-4 / SEC-1 — fail closed when the verifier is missing.
  #
  # This block previously had NO else branch. The rationale was backward
  # compatibility: an older payload that predates the verifier should still
  # install. The consequence was that omitting ONE file from the downloaded
  # tarball silently disabled integrity verification for the entire install,
  # and the install still reported success. That is a tampering primitive, not
  # a compatibility case — and the verifier cannot check its own absence,
  # because only the verifier reads the manifest.
  #
  # The manifest now declares whether it expects the verifier. Genuinely old
  # payloads (no declaration) keep the permissive path; anything from this
  # version forward cannot silently skip verification.
  payload_verifier_required="false"
  if [[ -n "${RELEASE_MANIFEST_SOURCE:-}" && -f "$RELEASE_MANIFEST_SOURCE" ]]; then
    if grep -q '"payloadVerifierRequired"[[:space:]]*:[[:space:]]*true' "$RELEASE_MANIFEST_SOURCE" 2>/dev/null; then
      payload_verifier_required="true"
    fi
  fi

  if [[ "$payload_verifier_required" == "true" ]]; then
    fail "Payload integrity verifier is missing (bubbles/scripts/verify-payload-integrity.sh) but the release manifest declares payloadVerifierRequired: true. A payload that declares the verifier and does not ship it has been altered or truncated — refusing to install. Re-download the payload from the official source."
  fi
  warn "Payload integrity verifier not present in this payload; skipping verification (legacy payload — its manifest does not declare payloadVerifierRequired)."
fi

# ── Version stamp ───────────────────────────────────────────────────
if [[ -f "$TEMP_DIR/VERSION" ]]; then
  cp "$TEMP_DIR/VERSION" "${TARGET}/bubbles/.version"
  VERSION=$(cat "${TARGET}/bubbles/.version")
  ok "Bubbles v${VERSION} installed"
else
  ok "Bubbles (${BUBBLES_REF}) installed"
fi

INSTALL_MODE='remote-ref'
SOURCE_REF="$BUBBLES_REF"
SOURCE_GIT_SHA="$(bubbles_json_string_field "$RELEASE_MANIFEST_SOURCE" gitSha)"
SOURCE_DIRTY='false'

if [[ -n "$LOCAL_SOURCE" ]]; then
  INSTALL_MODE='local-source'
  SOURCE_REF="$(bubbles_local_source_ref "$LOCAL_SOURCE")"
  SOURCE_GIT_SHA="$(bubbles_local_source_sha "$LOCAL_SOURCE")"
  SOURCE_DIRTY="$(bubbles_local_source_dirty "$LOCAL_SOURCE")"
fi

if [[ "$INSTALL_MODE" == 'remote-ref' ]] && ! bubbles_provenance_ref_is_safe "$SOURCE_REF"; then
  fail "Ref '${SOURCE_REF}' cannot be persisted safely in install provenance"
fi

[[ -n "$SOURCE_REF" ]] || fail "Could not determine a symbolic source ref for this install"
[[ -n "$SOURCE_GIT_SHA" ]] || fail "Could not determine source git SHA for this install"

INSTALL_VERSION="${VERSION:-$(bubbles_json_string_field "$RELEASE_MANIFEST_SOURCE" version)}"
[[ -n "$INSTALL_VERSION" ]] || fail "Could not determine installed Bubbles version"

# Repo-relative identity slug (IMP-025 SCOPE-5) — SAME derivation as the per-repo
# MCP server id (mcp_repo_slug, above) and repo-binding-preflight.sh repo_slug_of.
# Computed unconditionally here because mcp_repo_slug is only set inside the
# python3 MCP-registration block, so the marker must be derived independently to
# always be stamped. Repo-RELATIVE only (repo basename slug) — never an absolute
# path. repo-binding-preflight.sh reads this targetRepoSlug marker to refuse a
# foreign workspace-root agent editing this repo.
TARGET_REPO_SLUG="$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")"
TARGET_REPO_SLUG="$(printf '%s' "$TARGET_REPO_SLUG" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C sed -e 's/[^a-z0-9]/-/g' -e 's/--*/-/g' -e 's/^-//' -e 's/-$//')"
[[ -n "$TARGET_REPO_SLUG" ]] || TARGET_REPO_SLUG="repo"

cat > "${TARGET}/bubbles/.install-source.json" <<EOF
{
  "installedVersion": "${INSTALL_VERSION}",
  "installMode": "${INSTALL_MODE}",
  "sourceRef": "${SOURCE_REF}",
  "sourceGitSha": "${SOURCE_GIT_SHA}",
  "sourceDirty": ${SOURCE_DIRTY},
  "targetRepoSlug": "${TARGET_REPO_SLUG}",
  "installedAt": "$(bubbles_current_timestamp)"
}
EOF
ok "Install provenance written (${INSTALL_MODE}: ${SOURCE_REF})"

if [[ "$SOURCE_DIRTY" == "true" ]]; then
  warn "Installed from a dirty local source checkout. Doctor and upgrade surfaces will flag this as a trust risk."
fi

# ── Framework manifest ──────────────────────────────────────────────
# Generate a manifest of all framework-managed files so that lint tools
# can detect non-framework files added to managed directories.
{
  echo "# Bubbles framework manifest — auto-generated by install.sh"
  echo "# Files listed here are framework-owned and overwritten on upgrade."
  echo "# DO NOT add project-specific files to these directories."
  bubbles_framework_manifest_entries "$TEMP_DIR" true
  [[ -f "${TARGET}/bubbles/hooks.json" ]] && echo "bubbles/hooks.json"
} > "${TARGET}/bubbles/.manifest"
ok "Framework manifest written ($(wc -l < "${TARGET}/bubbles/.manifest") entries)"

{
  echo "# Bubbles framework checksum snapshot — auto-generated by install.sh"
  # Emit the path list first, then hash it in one batched pass. Order is
  # preserved (managed entries, then the extras), so the snapshot layout is
  # unchanged; only the number of spawned processes drops.
  {
    while IFS= read -r managed_entry; do
      [[ -n "$managed_entry" ]] || continue
      [[ "$managed_entry" == \#* ]] && continue
      [[ -f "${TARGET}/${managed_entry}" ]] || continue
      printf '%s\n' "$managed_entry"
    done < "${TARGET}/bubbles/.manifest"

    for extra_entry in "bubbles/.version" "bubbles/.manifest" "bubbles/release-manifest.json" "bubbles/.install-source.json"; do
      [[ -f "${TARGET}/${extra_entry}" ]] || continue
      printf '%s\n' "$extra_entry"
    done
  } | sha256_batch "$TARGET"
} > "${TARGET}/bubbles/.checksums"
ok "Framework checksum snapshot written ($(wc -l < "${TARGET}/bubbles/.checksums") entries)"

# ── Apply operator-declared MCP tool grants (v7.1) ──────────────────
# The .checksums snapshot above captured the CANONICAL restricted-orchestrator
# allowlists. Operator-declared grants (.github/bubbles-project.yaml mcp.grants)
# are now re-applied on top so they survive this refresh. The write guard is
# grant-aware: a declared grant reconciles to canonical; undeclared edits drift.
if [[ -f "${TARGET}/bubbles/scripts/mcp-grant-sync.sh" ]]; then
  if bash "${TARGET}/bubbles/scripts/mcp-grant-sync.sh" --quiet; then
    ok "MCP tool grants synced (restricted orchestrators)"
  else
    info "MCP tool grant sync skipped (no grants declared or yq unavailable)"
  fi
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
  mkdir -p .specify/metrics
  mkdir -p .specify/runtime
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

  # NOTE (IMP-017): the root-level AGENTS.md scaffold was removed. It generated
  # from templates/AGENTS.md.tmpl — a case-colliding duplicate of
  # templates/agents.md.tmpl (the command-registry template) — so on
  # case-insensitive filesystems (macOS/Windows) the two names collapsed to ONE
  # physical file AND the scaffold wrote the WRONG content (the command
  # registry, not repo guardrails). A correct starter-AGENTS.md scaffold is a
  # SEPARATE future feature (deferred). The command-registry template is still
  # scaffolded to .specify/memory/agents.md below.

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

  # ── Scaffold: lessons.md (skill-evolution learning-loop seed) ─────
  if [[ ! -f ".specify/memory/lessons.md" ]]; then
    cat > ".specify/memory/lessons.md" <<'LESSONSEOF'
# Lessons

<!-- Skill-evolution learning loop: add one lesson per bullet line below (e.g. "- reproduce the failing scenario before writing the fix"). A lesson recorded 3+ times proposes a new/updated skill (see skillEvolution in bubbles/workflows.yaml); lines starting with '#' are ignored and the file auto-compacts past ~150 lines into lessons-archive.md. -->
LESSONSEOF
    ok "Created .specify/memory/lessons.md (skill-evolution seed)"
    CREATED_COUNT=$((CREATED_COUNT + 1))
  else
    warn "Skipped .specify/memory/lessons.md (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  # ── Scaffold: open-work.md (IMP-033 SCOPE-3 open-work register) ───
  # The register is per-consuming-repo, not framework-only: the framework ships
  # the renderer and the lint, and each adopting repo owns its own residue rows
  # alongside the constitution.md and agents.md that already live there.
  if [[ ! -f ".specify/memory/open-work.md" ]]; then
    if [[ -f "$TEMPLATE_DIR/open-work.md.tmpl" ]]; then
      apply_template "$TEMPLATE_DIR/open-work.md.tmpl" ".specify/memory/open-work.md"
      ok "Created .specify/memory/open-work.md (open-work register)"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/memory/open-work.md (already exists)"
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
| `.github/bubbles-project.yaml` | ✅ Created by bootstrap (optional, customize scan patterns) |

## Customization Checklist

- [ ] Update CLI commands in `copilot-instructions.md`, `AGENTS.md`, and `agents.md`
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

> Single source of truth for what `/bubbles.setup` reviews.

## Internal Sources

| Source | Path | Purpose |
|--------|------|---------|
| Project config contract | `.github/agents/bubbles_shared/project-config-contract.md` | Required project configuration |
| Agent common governance | `.github/agents/bubbles_shared/agent-common.md` | Universal agent rules |
| Scope workflow | `.github/agents/bubbles_shared/scope-workflow.md` | Workflow templates |
| Workflows config | `.github/bubbles/workflows.yaml` | Workflow mode definitions |

## External Sources

> Add external libraries, skills, or references reviewed by setup here.
SRCEOF
  ok "Created ${TARGET}/bubbles/docs/SETUP_SOURCES.md"
    CREATED_COUNT=$((CREATED_COUNT + 1))
  fi

  # ── Scaffold: bubbles.config.json (control-plane policy registry) ─
  if [[ ! -f ".specify/memory/bubbles.config.json" ]]; then
    if [[ -f "$TEMP_DIR/.specify/memory/bubbles.config.json" ]]; then
      cp "$TEMP_DIR/.specify/memory/bubbles.config.json" ".specify/memory/bubbles.config.json"
      ok "Created .specify/memory/bubbles.config.json (control-plane defaults)"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/memory/bubbles.config.json (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  persist_adoption_profile ".specify/memory/bubbles.config.json" "$SELECTED_ADOPTION_PROFILE"
  info "Active adoption profile recorded: ${SELECTED_PROFILE_LABEL} (${SELECTED_ADOPTION_PROFILE})"

  # ── Scaffold: runtime artifact ignore rules ───────────────────────
  if [[ ! -f ".specify/memory/.gitignore" ]]; then
    if [[ -f "$TEMP_DIR/.specify/memory/.gitignore" ]]; then
      cp "$TEMP_DIR/.specify/memory/.gitignore" ".specify/memory/.gitignore"
      ok "Created .specify/memory/.gitignore (runtime profile/proposal artifacts stay untracked)"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/memory/.gitignore (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  if [[ ! -f ".specify/metrics/.gitignore" ]]; then
    if [[ -f "$TEMP_DIR/.specify/metrics/.gitignore" ]]; then
      cp "$TEMP_DIR/.specify/metrics/.gitignore" ".specify/metrics/.gitignore"
      ok "Created .specify/metrics/.gitignore (runtime metrics stay untracked)"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/metrics/.gitignore (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  if [[ ! -f ".specify/runtime/.gitignore" ]]; then
    if [[ -f "$TEMP_DIR/.specify/runtime/.gitignore" ]]; then
      cp "$TEMP_DIR/.specify/runtime/.gitignore" ".specify/runtime/.gitignore"
      ok "Created .specify/runtime/.gitignore (runtime lease registry stays untracked)"
      CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
  else
    warn "Skipped .specify/runtime/.gitignore (already exists)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  fi

  # ── Auto-generate: .github/bubbles-project.yaml ───────────────────────
  if [[ ! -f ".github/bubbles-project.yaml" ]] || ! grep -q '^scans:' ".github/bubbles-project.yaml" 2>/dev/null; then
    setup_script=".github/bubbles/scripts/project-scan-setup.sh"
    if [[ -f "$setup_script" ]]; then
      info "Auto-detecting project scan patterns..."
      bash "$setup_script" --quiet 2>/dev/null || true
      if [[ -f ".github/bubbles-project.yaml" ]]; then
        ok "Auto-generated .github/bubbles-project.yaml from codebase analysis"
        CREATED_COUNT=$((CREATED_COUNT + 1))
      else
        warn "Could not auto-generate .github/bubbles-project.yaml (will use generic defaults)"
      fi
    else
      warn "Skipped project scan setup (script not found at $setup_script)"
    fi
  else
    warn "Skipped .github/bubbles-project.yaml (already configured — project-owned)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
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
  echo "  🧭 Active adoption profile: ${SELECTED_PROFILE_LABEL} (${SELECTED_ADOPTION_PROFILE})"
  echo "     ${SELECTED_PROFILE_SUMMARY}"
  echo "     Governance invariant: ${SELECTED_PROFILE_INVARIANT}"
  if [[ "$SELECTED_ADOPTION_PROFILE" == "foundation" ]]; then
    echo "     Foundation was selected explicitly; the installer default still remains delivery."
  elif [[ "$SELECTED_ADOPTION_PROFILE" == "assured" ]]; then
    echo "     Assured was selected explicitly; the installer default still remains delivery."
    echo "     Assured raises earlier readiness visibility without changing the full-certification invariant."
  else
    echo "     Delivery remains the installer default during the current rollout."
  fi
  echo ""
  echo "  📁 Created:"
  echo "     specs/                                          — Feature/bug specs go here"
  echo "     .specify/memory/constitution.md                 — Project governance"
  echo "     .specify/memory/agents.md                       — Command registry"
  echo "     .specify/memory/bubbles.config.json             — Control-plane defaults"
  echo "     .specify/memory/.gitignore                      — Ignore runtime profile/proposal artifacts"
  echo "     .specify/metrics/.gitignore                     — Ignore runtime metrics artifacts"
  echo "     .github/copilot-instructions.md                 — Project policies"
  echo "     .github/instructions/terminal-discipline...md   — CLI discipline"
  echo "     .github/bubbles-project.yaml                    — Scan patterns (auto-detected)"
  echo ""
  echo "  Runtime-generated control-plane artifacts are created on demand and stay untracked:"
  echo "     .specify/memory/developer-profile.md"
  echo "     .specify/memory/skill-proposals.md"
  echo "     .specify/memory/skill-proposals-dismissed.md"
  echo "     .specify/metrics/*.jsonl"
  echo ""
  printf "  ${YELLOW}⚠️  Action required:${NC} Update the TODO items in the generated files\n"
  echo "     to match your project's actual commands, paths, and config."
  echo ""
  echo "  Then open VS Code and run these next steps:"
  echo ""
  if [[ "$SELECTED_ADOPTION_PROFILE" == "foundation" ]]; then
    echo "     /bubbles.setup mode: refresh          — Verify the foundation bootstrap landed cleanly"
    echo "     /bubbles.commands                     — Auto-detect your project and regenerate agents.md"
    echo "     bash .github/bubbles/scripts/cli.sh doctor"
    echo "     bash .github/bubbles/scripts/cli.sh repo-readiness ."
    echo "     /bubbles.workflow implement action:full-delivery target:spec — Move into the full delivery pipeline when ready"
  elif [[ "$SELECTED_ADOPTION_PROFILE" == "assured" ]]; then
    echo "     /bubbles.setup mode: refresh          — Verify the assured bootstrap landed cleanly"
    echo "     /bubbles.commands                     — Auto-detect your project and regenerate agents.md"
    echo "     bash .github/bubbles/scripts/cli.sh doctor"
    echo "     bash .github/bubbles/scripts/cli.sh repo-readiness . --profile assured"
    echo "     /bubbles.status                       — Review stricter readiness guidance before scaling delivery"
    echo "     /bubbles.workflow implement action:full-delivery target:spec — Run the same full-strength delivery pipeline when ready"
  else
    echo "     /bubbles.commands                   — Auto-detect your project and regenerate agents.md"
    echo "     /bubbles.setup mode: refresh        — Verify setup is complete"
    echo "     bash .github/bubbles/scripts/cli.sh doctor"
    echo "     bash .github/bubbles/scripts/cli.sh repo-readiness ."
    echo "     /bubbles.status                     — Check spec progress"
    echo "     /bubbles.analyst  <describe feature> — Start new feature work"
    echo "     /bubbles.workflow implement action:full-delivery target:spec — Run the full pipeline"
  fi
else
  echo "Bubbles is installed. Next steps:"
  echo ""
  echo "  Option A — Foundation bootstrap (recommended for first-time adoption and evaluation):"
  echo "     Re-run with --bootstrap --profile foundation to scaffold project config with the lighter first-run posture:"
  printf "     ${CYAN}curl -fsSL .../install.sh | bash -s -- --bootstrap --profile foundation${NC}\n"
  echo ""
  echo "  Option B — Default delivery bootstrap:"
  echo "     Re-run with --bootstrap to use the current installer default profile:"
  printf "     ${CYAN}curl -fsSL .../install.sh | bash -s -- --bootstrap${NC}\n"
  echo ""
  echo "  Option C — Assured bootstrap:"
  echo "     Re-run with --bootstrap --profile assured for earlier guardrail visibility and stricter readiness guidance while keeping the same certification model:"
  printf "     ${CYAN}curl -fsSL .../install.sh | bash -s -- --bootstrap --profile assured${NC}\n"
  echo ""
  echo "  Option D — Agents only install:"
  echo "     Re-run with --agents-only if you want to skip shared instructions and skills:"
  printf "     ${CYAN}curl -fsSL .../install.sh | bash -s -- --agents-only${NC}\n"
  echo ""
  echo "  Option E — Manual project setup on top of the shared install:"
  echo "     1. Add project-specific config to .github/copilot-instructions.md and AGENTS.md"
  echo "     2. Create .specify/memory/agents.md with your commands"
  echo "     3. Create .specify/memory/constitution.md with your principles"
  echo ""
  echo "  Then try:"
  echo "     /bubbles.goal <outcome>                 — universal one-outcome execution"
  echo "     /bubbles.workflow <target> mode: <mode> — deterministic single-mode execution"
  echo "     /bubbles.status     — check spec progress"
  echo "     /bubbles.plan       — scope out a feature"
fi
echo ""
echo "Docs:    https://github.com/${BUBBLES_REPO}"
echo "Update:  curl -fsSL https://raw.githubusercontent.com/${BUBBLES_REPO}/main/install.sh | bash"
echo ""
printf "${YELLOW}\"It ain't rocket appliances, but it works.\"${NC}\n"
