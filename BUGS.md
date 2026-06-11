# Bubbles Framework — Known Bugs

> **Why this file exists:** the Bubbles source repo cannot keep `specs/` (G085 dogfood guard), so framework-internal defects are tracked here as the operator-visible bug log. Downstream consumer repos file their bugs in their own `specs/<feature>/bugs/BUG-NNN-*/` structure as usual.
>
> Every entry below has an explicit disposition per Gate G095 (Discovered-Issue Disposition).

---

## BUG-001 — state-transition-guard.sh hangs in Check 3G (Framework Ownership And Result Contract)

- **Filed:** 2026-05-27
- **Disposition:** mitigated + items 2/4 hypothesis-invalidated (2026-06-11 empirical re-test) — fail-safe timeout shipped AND the suspected filesystem-walk root cause does NOT exist in the actual Check 3G sub-guard; no hang reproduces in source or any of the 5 downstream layouts. See "Empirical Re-Test (2026-06-11)" below.
- **Discovered by:** `bubbles.goal` session implementing G022/G060/G061 fixes
- **Severity:** low (was medium) — the guard now fails cleanly instead of hanging; selftest converges
- **Affects:** `bubbles/scripts/state-transition-guard.sh` Check 3G (Framework Ownership And Result Contract — gates G042/G063/G064)

### Mitigation Shipped (partial)

Check 3G now wraps its sub-guard invocation in a hard timeout and reports its
wall-clock cost, so the indefinite hang is gone — the check fails safe with a
named error instead of blocking forever:

- `state-transition-guard.sh` ~L765: `bubbles_run_with_timeout 30 bash "$framework_ownership_lint_script"` — on overrun it emits `Framework ownership lint TIMED OUT after 30s (BUG-001 guard)` and counts a failure (item 1 — done for Check 3G).
- `state-transition-guard.sh` ~L779: `warn "Check 3G wall-clock ${_c3g_elapsed}s exceeded the 30s budget"` (item 3 — per-check budget surfaced for Check 3G).
- The same `bubbles_run_with_timeout` wrapper now guards the other heavy sub-invocations (artifact-lint ~L2158, freshness-guard ~L2176, reality-scan ~L2352).

Items 2 & 4 are RECLASSIFIED as hypothesis-invalidated (not a live defect) — see the
Empirical Re-Test below. A full Checks 3–34 timeout audit (item 1 broadened to every
check) remains advisable but is not blocking.

### Empirical Re-Test (2026-06-11)

Re-investigated under a `bubbles.goal` monitoring session. Findings:

- Check 3G's ONLY sub-guard is `agent-ownership-lint.sh` (`state-transition-guard.sh`
  L364: `framework_ownership_lint_script="$SCRIPT_DIR/agent-ownership-lint.sh"`).
- That script contains **no** `find` / `grep -r` / `ls -R` recursive walk, so the
  "filesystem-walk exclusions" root cause (item 2) does not apply to it — it only
  greps a fixed set of known files.
- Measured runtime: **~0.3s** in the source layout and RC=0 / "Agent ownership lint
  passed." in all 5 downstream installed layouts (wanderaide, knb, quantitativeFinance,
  guestHost, smackerel). No hang anywhere.
- The only way its `grep -nE "$pattern" "$file"` helpers could hang is if `grep`
  received **zero** file args and fell back to stdin (verified: that path does hang,
  RC=124 under `timeout`). But every call passes a quoted `"$file"`, and
  `set -euo pipefail` makes an unset path a hard error — so grep always gets exactly
  one file arg and can never block on stdin. A missing/empty file arg returns RC=2
  (clean error), not a hang.

Conclusion: the documented hang does not reproduce in the current sub-guard; items 2
(walk exclusions) and 4 (500-spec walk perf fixture) target a root cause that is not
present. The shipped 30s timeout already makes any hypothetical future regression
fail-safe. If a hang ever recurs, root-cause it in `state-transition-guard.sh`'s own
Check-3G framing or a *different* check — not in a (nonexistent) sub-guard walk.

### Reproduction

```bash
cd /path/to/any/downstream/repo/with/real/spec
timeout 15 bash <bubbles>/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature>
# Observed: process times out (exit 124); last printed line is "--- Check 3G: Framework Ownership And Result Contract (G042/G063/G064) ---"
# Hang occurs AFTER Check 3F completes successfully.
```

Concrete observation during the G022/G060/G061 fix session:

```
✅ PASS: state.json transitionRequests queue is empty
✅ PASS: state.json reworkQueue is empty
✅ PASS: Transition and rework routing is closed

--- Check 3G: Framework Ownership And Result Contract (G042/G063/G064) ---
<hangs indefinitely until SIGTERM>
```

### Suspected Root Cause

> **INVALIDATED 2026-06-11** (see Empirical Re-Test above): the actual Check 3G
> sub-guard `agent-ownership-lint.sh` performs NO recursive filesystem walk and
> runs in ~0.3s across source + all 5 downstream layouts. The walk hypothesis below
> is retained for history only.

Check 3G appears to invoke a sub-guard (likely `agent-ownership-lint.sh` or a packet-routing scanner) without a timeout, OR performs a recursive filesystem walk that touches large generated directories (`.git/`, `node_modules/`, `target/`, `vendor/`, `dist/`, container build caches) without exclusions. Needs root-cause investigation.

### Impact

- `state-transition-guard.sh` cannot complete on real downstream spec dirs in reasonable time (observed >60s, killed at 300s during selftest).
- `state-transition-guard-selftest.sh` runs all 1230 lines through the guard repeatedly and exceeds wall-clock budget on developer machines.
- Forces operators to invoke individual sub-guards instead of the unified entry point.

### Required Fix

1. ~~Add a 30s hard timeout around every sub-guard invocation in Check 3G (and audit Checks 3-34 for the same pattern).~~ **DONE for Check 3G + the heavy sub-invocations** (see Mitigation Shipped above); a full Checks 3–34 audit is still advisable.
2. Add exclusion globs (`.git`, `node_modules`, `target`, `vendor`, `dist`, `__pycache__`, `.bubbles-cache`, container build dirs) to any filesystem walks in Check 3G's sub-guards. **INVALIDATED 2026-06-11** — the Check 3G sub-guard has no filesystem walk; nothing to exclude (see Empirical Re-Test).
3. ~~Add a per-check wall-clock budget reported in the verdict so future regressions surface immediately.~~ **DONE for Check 3G** (budget warn at ~L779); broaden to all checks if the pattern recurs.
4. Add a hermetic perf regression to `tests/regression/` that runs Check 3G against a synthetic 500-spec fixture and fails if elapsed > 5s. **MOOT 2026-06-11** — the sub-guard does not walk specs, so a 500-spec fixture exercises no slow path; a generic per-check wall-clock budget (item 3, broadened) is the better guard if regressions recur.

### Acceptance

- `timeout 60 bash bubbles/scripts/state-transition-guard.sh specs/<real-feature>` returns exit code (any) within 60s on every downstream repo.
- `state-transition-guard-selftest.sh` completes within 5 minutes.
- Per-check wall-clock budget appears in verdict block.

### Cross-References

- Discovered while implementing G022/G060/G061 (commit `1d79931`).
- This bug is the canonical demonstration of Gate G095 (Discovered-Issue Disposition) — it was previously deflected with "pre-existing and unrelated" and is now filed properly.
