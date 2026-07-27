#!/usr/bin/env bash
# Hermetic selftest for the IMP-107 / SCOPE-1 worktree-hygiene report + reaper.
# ---------------------------------------------------------------------------
# Synthesizes a throwaway git repo with one linked worktree in EACH hygiene
# state (merged / unmerged / dirty / prunable / lease-held / experiment) — each
# materially different, so the assertions are non-tautological — and asserts:
#   (a) worktree-hygiene-report.sh classifies every worktree correctly;
#   (b) worktree-reap.sh in DRY-RUN lists only merged+prunable and removes
#       nothing;
#   (c) worktree-reap.sh --yes removes ONLY merged+prunable (and their merged
#       local branches) and LEAVES unmerged/dirty/lease-held/experiment intact.
# The lease-held worktree is synthesized by GENUINELY acquiring an IMP-023
# writer-lease via runtime-leases.sh (with a hand-written-registry fallback,
# clearly WARNed, if that environment lacks a dependency).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_SH="$SCRIPT_DIR/worktree-hygiene-report.sh"
REAP_SH="$SCRIPT_DIR/worktree-reap.sh"
LEASES_SH="$SCRIPT_DIR/runtime-leases.sh"

FAILURES=0
pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT INT TERM
REPO="$TMP_ROOT/repo"

# Abort setup loudly (a setup failure is a real error, not an assertion miss).
setup() { if ! "$@"; then echo "SETUP-ABORT: $*" >&2; exit 1; fi; }

echo "Running worktree-hygiene guard selftest..."

# --- synthesize a repo with an initial commit on `main` ----------------------
setup git init -q "$REPO"
setup git -C "$REPO" config user.email "selftest@bubbles.local"
setup git -C "$REPO" config user.name "Bubbles Selftest"
setup git -C "$REPO" config commit.gpgsign false
# Pin the initial branch name to `main` regardless of the host git default.
setup git -C "$REPO" symbolic-ref HEAD refs/heads/main
printf 'base\n' > "$REPO/base.txt"
setup git -C "$REPO" add -A
setup git -C "$REPO" commit -qm base

WT_MERGED="$TMP_ROOT/wt-merged"
WT_UNMERGED="$TMP_ROOT/wt-unmerged"
WT_DIRTY="$TMP_ROOT/wt-dirty"
WT_GONE="$TMP_ROOT/wt-gone"
WT_LEASE="$TMP_ROOT/wt-lease"
WT_EXP="$TMP_ROOT/wt-exp"

# MERGED: a fresh branch at main's tip — 0 unique commits, clean.
setup git -C "$REPO" worktree add -q -b merged-wt "$WT_MERGED" main

# UNMERGED: a real unique commit not in trunk.
setup git -C "$REPO" worktree add -q -b feature-wt "$WT_UNMERGED" main
printf 'unique\n' > "$WT_UNMERGED/feature.txt"
setup git -C "$WT_UNMERGED" add -A
setup git -C "$WT_UNMERGED" commit -qm "unique feature commit"

# DIRTY: 0 unique commits but a real uncommitted modification to a tracked file.
setup git -C "$REPO" worktree add -q -b dirty-wt "$WT_DIRTY" main
printf 'uncommitted change\n' >> "$WT_DIRTY/base.txt"

# PRUNABLE: worktree directory really deleted; admin entry lingers.
setup git -C "$REPO" worktree add -q -b gone-wt "$WT_GONE" main
rm -rf "$WT_GONE"

# EXPERIMENT: a real .design-experiment marker at the worktree root.
setup git -C "$REPO" worktree add -q -b exp-wt "$WT_EXP" main
: > "$WT_EXP/.design-experiment"

# LEASE-HELD: genuinely acquire an IMP-023 writer-lease scoped to this worktree.
setup git -C "$REPO" worktree add -q -b lease-wt "$WT_LEASE" main
lease_mode="genuine"
if ! BUBBLES_REPO_ROOT="$WT_LEASE" BUBBLES_SESSION_ID="wt-selftest-session" \
     bash "$LEASES_SH" acquire --purpose wt-selftest-lease --environment dev \
       --share-mode exclusive --ttl-minutes 60 >/dev/null 2>&1; then
  lease_mode="approximated"
fi
# Verify the lease system reports it active; otherwise approximate by writing a
# minimal active-lease registry directly (no runtime-leases.sh dependency).
lease_active="$(BUBBLES_REPO_ROOT="$WT_LEASE" bash "$LEASES_SH" summary 2>/dev/null \
  | sed -nE 's/.*active=([0-9]+).*/\1/p' | head -1)"
if [[ "${lease_active:-0}" -lt 1 ]]; then
  lease_mode="approximated"
  mkdir -p "$WT_LEASE/.specify/runtime"
  future="$(date -u -d '+60 minutes' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null \
    || date -u -v+60M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null)"
  now_ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  {
    printf '{\n  "version": 1,\n  "leases": [\n'
    printf '    {"leaseId":"rls_selftest_0001","repo":"wt-lease","sessionId":"wt-selftest-session","agent":"cli","worktree":"%s","branch":"lease-wt","purpose":"wt-selftest-lease","environment":"dev","composeProject":"wt-selftest-cp","stackGroup":"validation","shareMode":"exclusive","compatibilityFingerprint":"fp","resources":"","attachedSessions":"wt-selftest-session","startedAt":"%s","lastHeartbeatAt":"%s","expiresAt":"%s","status":"active","weight":0}\n' \
      "$WT_LEASE" "$now_ts" "$now_ts" "$future"
    printf '  ]\n}\n'
  } > "$WT_LEASE/.specify/runtime/resource-leases.json"
fi
if [[ "$lease_mode" == "approximated" ]]; then
  echo "WARN: could not cleanly acquire a genuine writer-lease in this environment;" \
       "approximated the LEASE-HELD worktree by writing a minimal active-lease registry" \
       "(the report still consumes runtime-leases.sh summary to classify it)."
fi

# class_of <machine-output> <path>  ->  classification token (or empty)
class_of() {
  printf '%s\n' "$1" | awk -F'\t' -v p="$2" '$2 == p { print $1; exit }'
}

# =====================================================================
# (a) report classifies every worktree correctly
# =====================================================================
machine="$(BUBBLES_REPO_ROOT="$REPO" bash "$REPORT_SH" --porcelain 2>/dev/null || true)"

assert_class() {
  local label="$1" path="$2" want="$3" got
  got="$(class_of "$machine" "$path")"
  if [[ "$got" == "$want" ]]; then pass "$label ($want)"; else fail "$label (expected $want, got '${got:-<none>}')"; fi
}

assert_class "a1 merged worktree"     "$WT_MERGED"   "MERGED"
assert_class "a2 unmerged worktree"   "$WT_UNMERGED" "UNMERGED"
assert_class "a3 dirty worktree"      "$WT_DIRTY"    "DIRTY"
assert_class "a4 prunable worktree"   "$WT_GONE"     "PRUNABLE"
assert_class "a5 lease-held worktree" "$WT_LEASE"    "LEASE-HELD"
assert_class "a6 experiment worktree" "$WT_EXP"      "EXPERIMENT"

# The human summary line must count each state exactly once (non-tautological).
summary="$(BUBBLES_REPO_ROOT="$REPO" bash "$REPORT_SH" 2>/dev/null | sed -n 's/^worktree-hygiene: //p' | tail -1)"
if [[ "$summary" == "6 worktrees (1 merged, 1 unmerged, 1 prunable, 1 dirty, 1 lease-held, 1 experiment)" ]]; then
  pass "a7 summary line counts each state once"
else
  fail "a7 summary line mismatch: '$summary'"
fi

# Report must exit 0 (advisory).
BUBBLES_REPO_ROOT="$REPO" bash "$REPORT_SH" >/dev/null 2>&1
rc=$?
if [[ "$rc" -eq 0 ]]; then pass "a8 report exits 0 (advisory)"; else fail "a8 report exit $rc (expected 0)"; fi

# =====================================================================
# (b) DRY-RUN reaper lists only merged+prunable and removes nothing
# =====================================================================
dry="$(BUBBLES_REPO_ROOT="$REPO" bash "$REAP_SH" 2>/dev/null || true)"

if printf '%s\n' "$dry" | grep -q "would reap MERGED   $WT_MERGED"; then
  pass "b1 dry-run lists MERGED"
else
  fail "b1 dry-run missing MERGED line"
fi
if printf '%s\n' "$dry" | grep -q "would reap PRUNABLE $WT_GONE"; then
  pass "b2 dry-run lists PRUNABLE"
else
  fail "b2 dry-run missing PRUNABLE line"
fi
# Must NOT propose reaping the protected states.
if printf '%s\n' "$dry" | grep -qE "would reap .*($WT_UNMERGED|$WT_DIRTY|$WT_LEASE|$WT_EXP)"; then
  fail "b3 dry-run proposed reaping a protected worktree"
else
  pass "b3 dry-run never proposes a protected worktree"
fi
# Dry-run mutated nothing: every present worktree dir still exists, branches intact.
if [[ -d "$WT_MERGED" && -d "$WT_UNMERGED" && -d "$WT_DIRTY" && -d "$WT_LEASE" && -d "$WT_EXP" ]] \
  && git -C "$REPO" show-ref --verify --quiet refs/heads/merged-wt \
  && git -C "$REPO" show-ref --verify --quiet refs/heads/gone-wt; then
  pass "b4 dry-run modified nothing"
else
  fail "b4 dry-run unexpectedly modified the repo"
fi

# =====================================================================
# (c) --yes reaps ONLY merged+prunable; leaves the rest intact
# =====================================================================
BUBBLES_REPO_ROOT="$REPO" bash "$REAP_SH" --yes >/dev/null 2>&1
rc=$?
if [[ "$rc" -eq 0 ]]; then pass "c0 reaper --yes exits 0"; else fail "c0 reaper --yes exit $rc"; fi

# MERGED worktree + branch removed.
if [[ ! -d "$WT_MERGED" ]] && ! git -C "$REPO" show-ref --verify --quiet refs/heads/merged-wt; then
  pass "c1 MERGED worktree and branch reaped"
else
  fail "c1 MERGED worktree/branch not fully reaped"
fi
# PRUNABLE admin entry cleared + branch removed.
if ! git -C "$REPO" worktree list --porcelain 2>/dev/null | grep -q "^worktree $WT_GONE$" \
  && ! git -C "$REPO" show-ref --verify --quiet refs/heads/gone-wt; then
  pass "c2 PRUNABLE entry pruned and branch reaped"
else
  fail "c2 PRUNABLE entry/branch not fully reaped"
fi
# UNMERGED intact (worktree + unique branch).
if [[ -d "$WT_UNMERGED" ]] && git -C "$REPO" show-ref --verify --quiet refs/heads/feature-wt; then
  pass "c3 UNMERGED worktree and branch left intact"
else
  fail "c3 UNMERGED worktree/branch was disturbed"
fi
# DIRTY intact.
if [[ -d "$WT_DIRTY" ]] && git -C "$REPO" show-ref --verify --quiet refs/heads/dirty-wt; then
  pass "c4 DIRTY worktree and branch left intact"
else
  fail "c4 DIRTY worktree/branch was disturbed"
fi
# LEASE-HELD intact (never disturb a live run).
if [[ -d "$WT_LEASE" ]] && git -C "$REPO" show-ref --verify --quiet refs/heads/lease-wt; then
  pass "c5 LEASE-HELD worktree and branch left intact"
else
  fail "c5 LEASE-HELD worktree/branch was disturbed"
fi
# EXPERIMENT intact (SCOPE-1 is report-only for experiments).
if [[ -d "$WT_EXP" ]] && git -C "$REPO" show-ref --verify --quiet refs/heads/exp-wt; then
  pass "c6 EXPERIMENT worktree and branch left intact"
else
  fail "c6 EXPERIMENT worktree/branch was disturbed"
fi

echo
if [[ "$FAILURES" -gt 0 ]]; then
  echo "worktree-hygiene-guard-selftest FAILED with $FAILURES issue(s)."
  exit 1
fi
echo "worktree-hygiene-guard-selftest: all cases passed."
