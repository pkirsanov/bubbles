#!/usr/bin/env bash
#
# Bubbles — payload integrity verifier (IMP-101 SCOPE-8).
#
# Verifies that every INSTALLED framework-managed file matches the CANONICAL
# sha256 recorded in the release manifest's managedFileChecksums (computed at
# release time in the source repo). install.sh calls this immediately after the
# copy flow, before it stamps + snapshots the install, to catch a payload that
# arrived corrupt — a truncated download, a failed tar extraction, a partial
# disk write, or a single tampered file — none of which the self-referential
# .checksums snapshot install.sh writes can detect (that snapshot is computed
# FROM the installed bytes, so it faithfully records corruption instead of
# flagging it).
#
# SCOPE (honest limits): this is an INTEGRITY check — do the bytes we installed
# match the release's recorded bytes? — NOT an AUTHENTICITY check. Because the
# manifest ships inside the same payload, a coordinated tamper that rewrites
# BOTH a managed file AND its manifest entry is out of scope; defeating that
# needs a cryptographically SIGNED manifest (keys the operator does not hold at
# install time) and is deliberately deferred. This check nonetheless closes the
# corruption / incomplete-download / single-file-tamper class at zero
# key-management cost.
#
# Managed entries that are legitimately NOT installed for the current profile
# are SKIPPED, never failed: source-only trees (tests/, bubbles/eval/,
# bubbles/cheatsheet/) are never vendored downstream, and instructions/ + skills/
# are absent under --agents-only or when an optional skill is not opted in. Only
# a file that IS present at the target but whose bytes differ from the manifest
# is a hard FAILURE.
#
# Usage:
#   verify-payload-integrity.sh [--target DIR] [--manifest FILE] [--quiet]
#
#   --target DIR     Install root that holds the managed trees (default: .github)
#   --manifest FILE  release-manifest.json to verify against
#                    (default: <target>/bubbles/release-manifest.json)
#   --quiet          Suppress the success line (failures always print to stderr)
#
# Exit codes:
#   0 = every installed managed file matches (or manifest absent -> advisory)
#   1 = one or more installed managed files mismatch the manifest
#   2 = usage / environment error (unknown flag, or no sha256 tool)
#
set -euo pipefail

TARGET_DIR=".github"
MANIFEST_FILE=""
QUIET="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)   TARGET_DIR="$2"; shift 2 ;;
    --manifest) MANIFEST_FILE="$2"; shift 2 ;;
    --quiet)    QUIET="true"; shift ;;
    -h | --help)
      cat <<'EOF'
Usage: verify-payload-integrity.sh [--target DIR] [--manifest FILE] [--quiet]

Verifies every installed framework-managed file against the canonical sha256
recorded in the release manifest (managedFileChecksums). A present-but-mismatched
file is a hard failure (corruption / incomplete download); a manifest entry with
no installed file is skipped (source-only or not installed in this profile).

Exit codes: 0 = clean, 1 = mismatch found, 2 = usage / no sha256 tool.
EOF
      exit 0
      ;;
    *)
      echo "verify-payload-integrity: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

[[ -n "$MANIFEST_FILE" ]] || MANIFEST_FILE="${TARGET_DIR}/bubbles/release-manifest.json"

say() { [[ "$QUIET" == "true" ]] || printf '%s\n' "$*"; }

# A missing manifest is advisory, never fatal here: install.sh's own preflight
# already refuses to install without a manifest, and an older downstream layout
# predating this file should not hard-fail a re-scan.
if [[ ! -f "$MANIFEST_FILE" ]]; then
  say "verify-payload-integrity: no release manifest at ${MANIFEST_FILE} — skipped (advisory)"
  exit 0
fi

# Resolve the sha256 tool once (fail fast if neither is available). Indexed array
# keeps the invocation shellcheck-clean and works on bash 3.2 (macOS system bash).
if command -v sha256sum >/dev/null 2>&1; then
  SHA_CMD=(sha256sum)
elif command -v shasum >/dev/null 2>&1; then
  SHA_CMD=(shasum -a 256)
else
  echo "verify-payload-integrity: sha256sum or shasum is required" >&2
  exit 2
fi

sha256_of() { "${SHA_CMD[@]}" "$1" | awk '{print $1}'; }

verified=0
skipped=0
failures=""

# One pass over managedFileChecksums. The awk section detection mirrors the
# existing release_manifest_owns_managed_path() parser in install.sh (no JSON
# dependency; BSD/GNU awk compatible). Each emitted record is "<path>\t<sha256>".
while IFS=$'\t' read -r rel_path expected_sha; do
  [[ -n "$rel_path" ]] || continue
  installed="${TARGET_DIR}/${rel_path}"
  if [[ ! -f "$installed" ]]; then
    skipped=$((skipped + 1))
    continue
  fi
  actual_sha=""
  if ! actual_sha="$(sha256_of "$installed" 2>/dev/null)"; then
    failures="${failures}
  ${rel_path}
    could not hash installed file"
    continue
  fi
  if [[ "$actual_sha" != "$expected_sha" ]]; then
    failures="${failures}
  ${rel_path}
    expected ${expected_sha}
    actual   ${actual_sha}"
  else
    verified=$((verified + 1))
  fi
done < <(
  awk '
    BEGIN { section_line = "  \"managedFileChecksums\": [" }
    $0 == section_line { in_section = 1; next }
    in_section && ($0 == "  ]," || $0 == "  ]") { exit }
    in_section {
      path_value = $0
      sub(/^.*"path": "/, "", path_value)
      sub(/".*/, "", path_value)
      sha_value = $0
      sub(/^.*"sha256": "/, "", sha_value)
      sub(/".*/, "", sha_value)
      if (path_value != "" && sha_value != "")
        print path_value "\t" sha_value
    }
  ' "$MANIFEST_FILE"
)

if [[ -n "$failures" ]]; then
  echo "verify-payload-integrity: FAILED — ${verified} file(s) verified, but the following installed framework file(s) do NOT match the release manifest (corruption or incomplete download):${failures}" >&2
  exit 1
fi

say "verify-payload-integrity: OK — ${verified} installed framework file(s) match the release manifest (${skipped} manifest entries not installed in this profile)"
exit 0
