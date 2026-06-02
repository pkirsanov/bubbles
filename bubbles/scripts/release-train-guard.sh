#!/usr/bin/env bash
# release-train-guard.sh — validates release-train discipline across a repo.
#
# Enforces (per spec — bubbles-release-trains.instructions.md):
#   1. config/release-trains.yaml exists and is well-formed
#   2. Every train declared has phase ∈ {active, maintained, frozen, retired}
#   3. Every train declared has target_slot ∈ {prod, staging, none}
#   4. Every train references a flag bundle that exists on disk
#   5. Every spec under specs/ in `in_progress` or `done` declares releaseTrain
#   6. Every declared releaseTrain refers to an existing train id
#   7. Every train declares retention policy + pii classification (G118, G120)
#   8. No flag introduced by a spec is default-ON in any train other than the
#      spec's declared releaseTrain (G111)
#
# Exit 0 = clean. Exit 1 = violations found (printed to stderr).
# No --skip / --force / --ignore flag exists by design.

set -euo pipefail

REPO_ROOT="${1:-.}"
TRAINS_FILE="$REPO_ROOT/config/release-trains.yaml"
SPECS_DIR="$REPO_ROOT/specs"
FAILED=0

err() { echo "[release-train-guard][ERROR] $*" >&2; FAILED=1; }
warn() { echo "[release-train-guard][WARN] $*" >&2; }
info() { echo "[release-train-guard] $*"; }

if [[ ! -f "$TRAINS_FILE" ]]; then
  err "config/release-trains.yaml not found at $TRAINS_FILE"
  exit 1
fi

if ! command -v yq >/dev/null 2>&1; then
  err "yq is required (https://github.com/mikefarah/yq)"
  exit 1
fi

# Check 1+2+3+4+7: train declarations
TRAIN_IDS="$(yq -r '.trains[].id' "$TRAINS_FILE")"
if [[ -z "$TRAIN_IDS" ]]; then
  err "no trains declared in $TRAINS_FILE"
  exit 1
fi

for tid in $TRAIN_IDS; do
  phase="$(yq -r ".trains[] | select(.id==\"$tid\") | .phase" "$TRAINS_FILE")"
  slot="$(yq -r ".trains[] | select(.id==\"$tid\") | .target_slot" "$TRAINS_FILE")"
  bundle="$(yq -r ".trains[] | select(.id==\"$tid\") | .flags_bundle" "$TRAINS_FILE")"
  retention="$(yq -r ".trains[] | select(.id==\"$tid\") | .retention" "$TRAINS_FILE")"
  pii="$(yq -r ".trains[] | select(.id==\"$tid\") | .pii" "$TRAINS_FILE")"

  case "$phase" in
    active|maintained|frozen|retired) ;;
    *) err "train '$tid' has invalid phase '$phase' (expected active|maintained|frozen|retired)" ;;
  esac

  case "$slot" in
    prod|staging|none) ;;
    *) err "train '$tid' has invalid target_slot '$slot' (expected prod|staging|none)" ;;
  esac

  if [[ -z "$bundle" || "$bundle" == "null" ]]; then
    err "train '$tid' missing flags_bundle"
  elif [[ ! -f "$REPO_ROOT/$bundle" ]]; then
    err "train '$tid' flags_bundle '$bundle' not found on disk"
  fi

  if [[ -z "$retention" || "$retention" == "null" ]]; then
    err "train '$tid' missing retention policy (G118)"
  fi

  if [[ -z "$pii" || "$pii" == "null" ]]; then
    err "train '$tid' missing pii classification (G120)"
  fi
done

# Check 5+6: every active spec declares a valid releaseTrain
if [[ -d "$SPECS_DIR" ]]; then
  while IFS= read -r state_file; do
    status="$(yq -r '.status // ""' "$state_file" 2>/dev/null || echo "")"
    case "$status" in
      in_progress|done|specs_hardened|delivered_pending_activation|train_cut|train_promoted) ;;
      *) continue ;;
    esac

    train="$(yq -r '.releaseTrain // ""' "$state_file" 2>/dev/null || echo "")"
    if [[ -z "$train" || "$train" == "null" ]]; then
      err "spec $(dirname "$state_file") status=$status missing releaseTrain field"
      continue
    fi

    if ! echo "$TRAIN_IDS" | grep -qxF "$train"; then
      err "spec $(dirname "$state_file") declares releaseTrain '$train' not in registry"
    fi
  done < <(find "$SPECS_DIR" -name state.json -type f 2>/dev/null)
fi

# Check 8: flag default-OFF on other trains (G111)
# For each spec with flagsIntroduced, verify each flag is default-OFF in every
# train EXCEPT the spec's declared releaseTrain.
if [[ -d "$SPECS_DIR" ]]; then
  while IFS= read -r state_file; do
    spec_train="$(yq -r '.releaseTrain // ""' "$state_file" 2>/dev/null || echo "")"
    [[ -z "$spec_train" || "$spec_train" == "null" ]] && continue

    flags="$(yq -r '.flagsIntroduced[]? // ""' "$state_file" 2>/dev/null || echo "")"
    [[ -z "$flags" ]] && continue

    for flag in $flags; do
      for tid in $TRAIN_IDS; do
        [[ "$tid" == "$spec_train" ]] && continue
        bundle="$(yq -r ".trains[] | select(.id==\"$tid\") | .flags_bundle" "$TRAINS_FILE")"
        [[ -z "$bundle" || ! -f "$REPO_ROOT/$bundle" ]] && continue
        value="$(yq -r ".flags.${flag} // \"unset\"" "$REPO_ROOT/$bundle" 2>/dev/null || echo "unset")"
        case "$value" in
          true|"True"|"TRUE"|on|ON|enabled|ENABLED)
            err "G111 violation: spec $(dirname "$state_file") introduces flag '$flag' on train '$spec_train' but it is default-ON in train '$tid' (bundle: $bundle)"
            ;;
        esac
      done
    done
  done < <(find "$SPECS_DIR" -name state.json -type f 2>/dev/null)
fi

if [[ "$FAILED" -ne 0 ]]; then
  err "release-train-guard FAILED"
  exit 1
fi

info "release-train-guard PASSED ($(echo "$TRAIN_IDS" | wc -w) trains)"
exit 0
