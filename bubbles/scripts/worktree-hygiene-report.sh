#!/usr/bin/env bash
# worktree-hygiene-report.sh (IMP-107 / SCOPE-1 — gap WT-TEARDOWN)
# ---------------------------------------------------------------------------
# ADVISORY, READ-ONLY worktree-hygiene detector. Enumerates the repo's LINKED
# git worktrees and classifies each so the create->merge->DROP contract that is
# prose-only today (scope-workflow.md) becomes operator-visible. It NEVER
# mutates the repository and ALWAYS exits 0 (it is a doctor advisory host, not a
# gate). The safe reaper (worktree-reap.sh) consumes the machine-readable lines.
#
# Classifications (single primary label per worktree; precedence top-to-bottom):
#   PRUNABLE   — the worktree directory is gone (git marks it prunable)  -> reapable
#   LEASE-HELD — a live IMP-023 writer-lease covers it (runtime-leases)  -> SKIP (never touch)
#   EXPERIMENT — a `.design-experiment` marker is present at its root     -> report-only in SCOPE-1
#   DIRTY      — uncommitted / untracked changes in the worktree          -> never auto-reap
#   UNMERGED   — the branch has commits not in trunk (unique work)        -> triage, never auto-reap
#   MERGED     — branch fully in trunk (0 unique commits), clean          -> reapable
#
# Reuse, not reinvention: LEASE-HELD is decided by asking the existing
# `runtime-leases.sh summary` (IMP-023) — the same effective-status logic the
# `cli.sh doctor` runtime-lease advisory already trusts — so this detector can
# never disturb a concurrent live run. It only probes the lease system when the
# worktree already has a lease registry file, preserving the read-only contract.
#
# Modes:
#   (default)     human-readable per-worktree detail + one machine summary line
#   --porcelain   one TAB-separated line per LINKED worktree, for the reaper:
#                 CLASS\tPATH\tBRANCH\tAHEAD\tBEHIND\tDIRTY\tAGEDAYS
#   --help        usage, exit 0
#
# The summary line (both modes emit it in default mode; --porcelain omits it) is:
#   worktree-hygiene: N worktrees (M merged, U unmerged, P prunable, D dirty, L lease-held, E experiment)
# `cli.sh doctor` greps this line. There is NO --skip / --force / bypass flag.
#
# Portable to bash 3.2 (macOS) + GNU/BSD git; uses only git + POSIX text tools.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# REPO_ROOT resolution mirrors runtime-leases.sh exactly (source-tree vs the
# downstream .github/bubbles/scripts install, with a BUBBLES_REPO_ROOT override
# so the hermetic selftest can point it at a synthesized repo).
if [[ -n "${BUBBLES_REPO_ROOT:-}" ]]; then
  REPO_ROOT="$BUBBLES_REPO_ROOT"
elif [[ "$(basename "$(dirname "$SCRIPT_DIR")")" == "bubbles" && "$(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")" == ".github" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

LEASES_SH="$SCRIPT_DIR/runtime-leases.sh"

usage() {
  cat <<'EOF'
Usage: worktree-hygiene-report.sh [--porcelain] [--help]

Advisory, READ-ONLY report of linked git worktrees and their hygiene class
(PRUNABLE | LEASE-HELD | EXPERIMENT | DIRTY | UNMERGED | MERGED). Always exits 0.

  (no args)     Human-readable detail + a machine summary line consumed by doctor.
  --porcelain   One TAB-separated line per linked worktree for worktree-reap.sh:
                CLASS<TAB>PATH<TAB>BRANCH<TAB>AHEAD<TAB>BEHIND<TAB>DIRTY<TAB>AGEDAYS
  --help        Show this help and exit 0.

Reads only; never removes a worktree or branch (that is worktree-reap.sh).
No --skip / --force / bypass flag exists.
EOF
}

PORCELAIN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --porcelain) PORCELAIN=true; shift ;;
    -h | --help) usage; exit 0 ;;
    *) echo "worktree-hygiene-report: unknown option: $1" >&2; usage >&2; exit 0 ;;
  esac
done

# Not a git repository -> benign advisory no-op.
if ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  if [[ "$PORCELAIN" == false ]]; then
    echo "[worktree-hygiene] $REPO_ROOT is not a git repository (advisory no-op)."
    echo "worktree-hygiene: 0 worktrees (0 merged, 0 unmerged, 0 prunable, 0 dirty, 0 lease-held, 0 experiment)"
  fi
  exit 0
fi

detect_trunk() {
  local c o
  for c in main master; do
    if git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$c"; then
      printf '%s\n' "$c"
      return 0
    fi
  done
  o="$(git -C "$REPO_ROOT" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null || true)"
  if [[ -n "$o" ]]; then
    printf '%s\n' "${o#refs/remotes/origin/}"
    return 0
  fi
  git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || printf '%s\n' 'main'
}

TRUNK="$(detect_trunk)"

# "<ahead> <behind>" of $1 (a branch or sha) versus TRUNK. ahead = commits in
# ref not in trunk (unique work); behind = commits in trunk not in ref.
count_ahead_behind() {
  local ref="$1" out ahead behind
  [[ -n "$ref" ]] || { printf '0 0\n'; return 0; }
  out="$(git -C "$REPO_ROOT" rev-list --left-right --count "$TRUNK...$ref" 2>/dev/null || true)"
  [[ -n "$out" ]] || { printf '0 0\n'; return 0; }
  behind="$(printf '%s' "$out" | awk '{print $1}')"
  ahead="$(printf '%s' "$out" | awk '{print $2}')"
  [[ "$ahead" =~ ^[0-9]+$ ]] || ahead=0
  [[ "$behind" =~ ^[0-9]+$ ]] || behind=0
  printf '%s %s\n' "$ahead" "$behind"
}

# Age in whole days of a ref's tip commit; -1 when unresolvable.
ref_age_days() {
  local ref="$1" ct now
  [[ -n "$ref" ]] || { printf '%s\n' '-1'; return 0; }
  ct="$(git -C "$REPO_ROOT" log -1 --format=%ct "$ref" 2>/dev/null || true)"
  [[ "$ct" =~ ^[0-9]+$ ]] || { printf '%s\n' '-1'; return 0; }
  now="$(date -u +%s)"
  printf '%s\n' "$(( (now - ct) / 86400 ))"
}

worktree_dirty_count() {
  local p="$1"
  [[ -d "$p" ]] || { printf '%s\n' '0'; return 0; }
  git -C "$p" status --porcelain 2>/dev/null | sed '/^$/d' | wc -l | tr -d ' '
}

# 1 iff a live writer-lease covers the worktree. Reuses runtime-leases.sh's own
# effective-status logic (its `summary` reports active=N), and only probes when
# the worktree already owns a lease registry file — so this stays read-only.
worktree_lease_held() {
  local p="$1" reg active
  reg="$p/.specify/runtime/resource-leases.json"
  [[ -f "$reg" ]] || { printf '%s\n' '0'; return 0; }
  [[ -x "$LEASES_SH" ]] || { printf '%s\n' '0'; return 0; }
  active="$(BUBBLES_REPO_ROOT="$p" bash "$LEASES_SH" summary 2>/dev/null | sed -nE 's/.*active=([0-9]+).*/\1/p' | head -1)"
  [[ "$active" =~ ^[0-9]+$ ]] || active=0
  if [[ "$active" -gt 0 ]]; then printf '%s\n' '1'; else printf '%s\n' '0'; fi
}

# classify_worktree <path> <branch> <head-sha> <detached:0|1> <prunable:0|1>
# Emits: CLASS<TAB>AHEAD<TAB>BEHIND<TAB>DIRTY<TAB>AGEDAYS
classify_worktree() {
  local p="$1" b="$2" head="$3" prune="$5"
  local ref ab ahead=0 behind=0 dirty=0 lease=0 exp=0 age=-1 cls="UNMERGED"

  ref="$b"; [[ -n "$ref" ]] || ref="$head"
  ab="$(count_ahead_behind "$ref")"
  ahead="${ab%% *}"; behind="${ab##* }"
  age="$(ref_age_days "$ref")"

  if [[ "$prune" -eq 1 ]]; then
    cls="PRUNABLE"
  else
    dirty="$(worktree_dirty_count "$p")"
    lease="$(worktree_lease_held "$p")"
    [[ -f "$p/.design-experiment" ]] && exp=1
    if [[ "$lease" -eq 1 ]]; then
      cls="LEASE-HELD"
    elif [[ "$exp" -eq 1 ]]; then
      cls="EXPERIMENT"
    elif [[ "$dirty" -gt 0 ]]; then
      cls="DIRTY"
    elif [[ "$ahead" -eq 0 ]]; then
      cls="MERGED"
    else
      cls="UNMERGED"
    fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$cls" "$ahead" "$behind" "$dirty" "$age"
}

# --- enumerate worktrees (porcelain state machine; first record = main) -------
n_total=0 n_merged=0 n_unmerged=0 n_prunable=0 n_dirty=0 n_lease=0 n_exp=0
detail_lines=""
machine_lines=""

flush_record() {
  local path="$1" head="$2" branch="$3" detached="$4" prunable="$5" is_main="$6"
  [[ -n "$path" ]] || return 0
  # The main worktree is never a reap candidate; skip it silently.
  [[ "$is_main" -eq 1 ]] && return 0

  local fields cls ahead behind dirty age
  fields="$(classify_worktree "$path" "$branch" "$head" "$detached" "$prunable")"
  cls="$(printf '%s' "$fields" | cut -f1)"
  ahead="$(printf '%s' "$fields" | cut -f2)"
  behind="$(printf '%s' "$fields" | cut -f3)"
  dirty="$(printf '%s' "$fields" | cut -f4)"
  age="$(printf '%s' "$fields" | cut -f5)"

  n_total=$((n_total + 1))
  case "$cls" in
    MERGED)     n_merged=$((n_merged + 1)) ;;
    UNMERGED)   n_unmerged=$((n_unmerged + 1)) ;;
    PRUNABLE)   n_prunable=$((n_prunable + 1)) ;;
    DIRTY)      n_dirty=$((n_dirty + 1)) ;;
    LEASE-HELD) n_lease=$((n_lease + 1)) ;;
    EXPERIMENT) n_exp=$((n_exp + 1)) ;;
  esac

  local disp_branch="$branch"
  [[ -n "$disp_branch" ]] || disp_branch="(detached)"
  local note="triage — never auto-reap"
  case "$cls" in
    MERGED)     note="reapable (merged + clean)" ;;
    PRUNABLE)   note="reapable (directory gone)" ;;
    LEASE-HELD) note="SKIP — live writer-lease" ;;
    EXPERIMENT) note="report-only (SCOPE-1); .design-experiment marker" ;;
    DIRTY)      note="never auto-reap (uncommitted changes)" ;;
    UNMERGED)   note="triage — never auto-reap (unique commits)" ;;
  esac

  machine_lines="${machine_lines}${machine_lines:+
}$(printf '%s\t%s\t%s\t%s\t%s\t%s\t%s' "$cls" "$path" "$branch" "$ahead" "$behind" "$dirty" "$age")"
  detail_lines="${detail_lines}${detail_lines:+
}$(printf '  %-11s %s  branch=%s  ahead=%s behind=%s  dirty=%s  age=%sd  -> %s' \
    "$cls" "$path" "$disp_branch" "$ahead" "$behind" "$dirty" "$age" "$note")"
}

wt_path="" wt_head="" wt_branch="" wt_detached=0 wt_prunable=0 record_idx=0
while IFS= read -r line; do
  if [[ -z "$line" ]]; then
    if [[ -n "$wt_path" ]]; then
      local_is_main=0
      [[ "$record_idx" -eq 0 ]] && local_is_main=1
      # The first record is the main worktree; it is never a reap candidate.
      flush_record "$wt_path" "$wt_head" "$wt_branch" "$wt_detached" "$wt_prunable" "$local_is_main"
      record_idx=$((record_idx + 1))
    fi
    wt_path="" wt_head="" wt_branch="" wt_detached=0 wt_prunable=0
    continue
  fi
  case "$line" in
    "worktree "*) wt_path="${line#worktree }" ;;
    "HEAD "*)     wt_head="${line#HEAD }" ;;
    "branch "*)   wt_branch="${line#branch refs/heads/}" ;;
    "detached")   wt_detached=1 ;;
    "prunable"*)  wt_prunable=1 ;;
    *) : ;;
  esac
done < <(git -C "$REPO_ROOT" worktree list --porcelain 2>/dev/null)
# Flush a trailing record if porcelain did not end with a blank line.
if [[ -n "$wt_path" ]]; then
  local_is_main=0
  [[ "$record_idx" -eq 0 ]] && local_is_main=1
  flush_record "$wt_path" "$wt_head" "$wt_branch" "$wt_detached" "$wt_prunable" "$local_is_main"
fi

if [[ "$PORCELAIN" == true ]]; then
  [[ -n "$machine_lines" ]] && printf '%s\n' "$machine_lines"
  exit 0
fi

echo "[worktree-hygiene] Linked worktrees under $REPO_ROOT (trunk=$TRUNK):"
if [[ "$n_total" -eq 0 ]]; then
  echo "  (none — only the main worktree is present)"
else
  printf '%s\n' "$detail_lines"
fi
echo "worktree-hygiene: ${n_total} worktrees (${n_merged} merged, ${n_unmerged} unmerged, ${n_prunable} prunable, ${n_dirty} dirty, ${n_lease} lease-held, ${n_exp} experiment)"
exit 0
