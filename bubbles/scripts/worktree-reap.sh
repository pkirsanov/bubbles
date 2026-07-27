#!/usr/bin/env bash
# worktree-reap.sh (IMP-107 / SCOPE-1 — gap WT-TEARDOWN)
# ---------------------------------------------------------------------------
# Explicit, SAFE-BY-CONSTRUCTION worktree reaper. It reaps ONLY the reapable set
# surfaced by worktree-hygiene-report.sh — `MERGED` and `PRUNABLE` worktrees —
# plus their fully-merged LOCAL branches. It is DRY-RUN BY DEFAULT: without
# `--yes` it prints exactly what it WOULD do and touches nothing.
#
# Hard safety invariants (IMP-107 R1-R5):
#   * REFUSES to reap UNMERGED / DIRTY / LEASE-HELD / EXPERIMENT worktrees — it
#     only reports them. A live IMP-023 writer-lease (LEASE-HELD) is re-checked
#     at action time, so a concurrent live run can never be disturbed.
#   * Local branch deletion uses `git branch -d` (SAFE delete — git itself
#     refuses a non-merged branch). It NEVER uses `git branch -D`.
#   * Worktree removal uses `git worktree remove` WITHOUT `--force` (git itself
#     refuses a dirty worktree). It NEVER passes `--force`.
#   * Remote branches are NEVER touched unless `--remote` is given, and even then
#     only AFTER the local safe-delete of that same branch has succeeded.
#   * There is NO `--skip` / `--force` / bypass flag. `--yes` means "act"; it is
#     not a safety override.
#
# SCOPE-1 note: EXPERIMENT (`.design-experiment`) worktrees are report-only here
# by design — reaping lingering experiments is IMP-107 SCOPE-3, and the marked-
# worktree identity signal is SCOPE-5. SCOPE-1 reaps ONLY provably merged-and-
# clean (or directory-gone) worktrees.
#
# Portable to bash 3.2 (macOS) + GNU/BSD git. Always exits 0.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${BUBBLES_REPO_ROOT:-}" ]]; then
  REPO_ROOT="$BUBBLES_REPO_ROOT"
elif [[ "$(basename "$(dirname "$SCRIPT_DIR")")" == "bubbles" && "$(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")" == ".github" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

REPORT_SH="$SCRIPT_DIR/worktree-hygiene-report.sh"
LEASES_SH="$SCRIPT_DIR/runtime-leases.sh"

usage() {
  cat <<'EOF'
Usage: worktree-reap.sh [--yes] [--remote] [--help]

Safely reap MERGED + PRUNABLE git worktrees (and their fully-merged LOCAL
branches). DRY-RUN BY DEFAULT — pass --yes to actually act.

  --yes       Perform the reap. Without it, print what WOULD be reaped and stop.
  --remote    ALSO delete the merged branch on origin, and ONLY after the local
              safe-delete of that same branch succeeded (network opt-in).
  --help      Show this help and exit 0.

NEVER reaps UNMERGED / DIRTY / LEASE-HELD / EXPERIMENT worktrees (report-only).
Uses `git worktree remove` (no --force) and `git branch -d` (no -D). A live
writer-lease is re-checked at action time. No --skip / --force / bypass flag.
EOF
}

APPLY=false
REMOTE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --yes) APPLY=true; shift ;;
    --remote) REMOTE=true; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "worktree-reap: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  echo "[worktree-reap] $REPO_ROOT is not a git repository (nothing to do)."
  exit 0
fi

# Re-check safety at action time (defense in depth beyond the report's class).
still_dirty() {
  local p="$1" n
  [[ -d "$p" ]] || { return 1; }
  n="$(git -C "$p" status --porcelain 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' ')"
  [[ "$n" =~ ^[0-9]+$ ]] || n=0
  [[ "$n" -gt 0 ]]
}

still_lease_held() {
  local p="$1" active
  [[ -f "$p/.specify/runtime/resource-leases.json" ]] || return 1
  [[ -x "$LEASES_SH" ]] || return 1
  active="$(BUBBLES_REPO_ROOT="$p" bash "$LEASES_SH" summary 2>/dev/null | sed -nE 's/.*active=([0-9]+).*/\1/p' | head -1)"
  [[ "$active" =~ ^[0-9]+$ ]] || active=0
  [[ "$active" -gt 0 ]]
}

delete_local_branch() {
  # Safe-delete a merged local branch; echo an outcome word. Never uses -D.
  local branch="$1"
  [[ -n "$branch" ]] || { echo "no-branch"; return 0; }
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$branch" || { echo "branch-absent"; return 0; }
  if git -C "$REPO_ROOT" branch -d "$branch" >/dev/null 2>&1; then
    echo "branch-deleted"
  else
    echo "branch-retained"
  fi
}

maybe_delete_remote_branch() {
  # Only after a successful local safe-delete, and only with --remote.
  local branch="$1" local_outcome="$2"
  [[ "$REMOTE" == true ]] || return 0
  [[ -n "$branch" ]] || return 0
  [[ "$local_outcome" == "branch-deleted" ]] || return 0
  git -C "$REPO_ROOT" show-ref --verify --quiet "refs/remotes/origin/$branch" || return 0
  if git -C "$REPO_ROOT" push origin --delete "$branch" >/dev/null 2>&1; then
    echo "    remote: deleted origin/$branch"
  else
    echo "    remote: origin/$branch delete declined (left intact)"
  fi
}

machine="$(BUBBLES_REPO_ROOT="$REPO_ROOT" bash "$REPORT_SH" --porcelain 2>/dev/null || true)"

reaped=0 skipped=0

if [[ "$APPLY" == true ]]; then
  echo "[worktree-reap] APPLYING — reaping MERGED + PRUNABLE worktrees under $REPO_ROOT"
  # Clear dir-gone (prunable) admin entries first, so a lingering PRUNABLE
  # branch is no longer reported as "checked out" and can be safely deleted.
  git -C "$REPO_ROOT" worktree prune >/dev/null 2>&1 || true
else
  echo "[worktree-reap] DRY-RUN (no --yes) — nothing will be modified. Under $REPO_ROOT:"
fi

if [[ -z "$machine" ]]; then
  echo "  (no linked worktrees — nothing to reap)"
  echo "[worktree-reap] done: 0 reaped, 0 skipped."
  exit 0
fi

while IFS=$'\t' read -r cls path branch _; do
  [[ -n "${cls:-}" ]] || continue
  case "$cls" in
    MERGED)
      if [[ "$APPLY" == false ]]; then
        echo "  [dry-run] would reap MERGED   $path (branch=${branch:-<detached>})"
        reaped=$((reaped + 1))
        continue
      fi
      # Defense in depth: never touch a worktree that turned dirty/lease-held.
      if still_lease_held "$path"; then
        echo "  SKIP  $path — became LEASE-HELD (live run); left intact"
        skipped=$((skipped + 1)); continue
      fi
      if still_dirty "$path"; then
        echo "  SKIP  $path — became DIRTY; left intact"
        skipped=$((skipped + 1)); continue
      fi
      if git -C "$REPO_ROOT" worktree remove "$path" >/dev/null 2>&1; then
        local_outcome="$(delete_local_branch "$branch")"
        echo "  REAPED MERGED   $path (branch=${branch:-<detached>}, $local_outcome)"
        maybe_delete_remote_branch "$branch" "$local_outcome"
        reaped=$((reaped + 1))
      else
        echo "  SKIP  $path — 'git worktree remove' declined (left intact)"
        skipped=$((skipped + 1))
      fi
      ;;
    PRUNABLE)
      if [[ "$APPLY" == false ]]; then
        echo "  [dry-run] would reap PRUNABLE $path (branch=${branch:-<detached>}; git worktree prune)"
        reaped=$((reaped + 1))
      else
        # The directory is already gone and its admin entry was pruned above.
        # Safe-delete the branch if it lingers.
        local_outcome="$(delete_local_branch "$branch")"
        echo "  REAPED PRUNABLE $path (branch=${branch:-<detached>}, $local_outcome)"
        maybe_delete_remote_branch "$branch" "$local_outcome"
        reaped=$((reaped + 1))
      fi
      ;;
    *)
      echo "  keep  $cls $path — report-only (never auto-reaped in SCOPE-1)"
      skipped=$((skipped + 1))
      ;;
  esac
done <<EOF
$machine
EOF

if [[ "$APPLY" == true ]]; then
  echo "[worktree-reap] done: $reaped reaped, $skipped skipped."
else
  echo "[worktree-reap] dry-run: $reaped would be reaped, $skipped would be kept. Re-run with --yes to act."
fi
exit 0
