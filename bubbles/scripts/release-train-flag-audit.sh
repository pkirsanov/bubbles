#!/usr/bin/env bash
# release-train-flag-audit.sh — identifies feature flags that are overdue
# for cleanup (introduced by a spec on a train that has graduated > 1 cycle).
#
# Output: list of (flag, train, owner-spec, cycles-overdue) lines.
# Exit 0 always; this is an audit, not a gate.

set -euo pipefail

REPO_ROOT="${1:-.}"
TRAINS_FILE="$REPO_ROOT/config/release-trains.yaml"
SPECS_DIR="$REPO_ROOT/specs"
GRACE_CYCLES="${FLAG_GRACE_CYCLES:-1}"

if [[ ! -f "$TRAINS_FILE" ]]; then
  echo "[flag-audit] config/release-trains.yaml not found; skipping"
  exit 0
fi

command -v yq >/dev/null 2>&1 || { echo "[flag-audit] yq required" >&2; exit 1; }

declare -A train_phase
while IFS=$'\t' read -r tid phase; do
  train_phase[$tid]="$phase"
done < <(yq -r '.trains[] | [.id, .phase] | @tsv' "$TRAINS_FILE")

echo "## Flag cleanup audit ($(date -u +%FT%TZ))"
echo
printf "%-30s %-20s %-15s %s\n" "FLAG" "TRAIN" "PHASE" "OWNER_SPEC"
printf -- "-%.0s" {1..90}
echo

overdue_count=0

while IFS= read -r state_file; do
  spec_dir="$(dirname "$state_file")"
  train="$(yq -r '.releaseTrain // ""' "$state_file" 2>/dev/null || echo "")"
  [[ -z "$train" || "$train" == "null" ]] && continue

  flags="$(yq -r '.flagsIntroduced[]? // ""' "$state_file" 2>/dev/null || echo "")"
  [[ -z "$flags" ]] && continue

  phase="${train_phase[$train]:-unknown}"

  # Flags whose train is `frozen` or `retired` are overdue.
  case "$phase" in
    frozen|retired)
      for flag in $flags; do
        printf "%-30s %-20s %-15s %s\n" "$flag" "$train" "$phase" "$spec_dir"
        overdue_count=$((overdue_count + 1))
      done
      ;;
  esac
done < <(find "$SPECS_DIR" -name state.json -type f 2>/dev/null)

echo
echo "Overdue flags: $overdue_count"
exit 0
