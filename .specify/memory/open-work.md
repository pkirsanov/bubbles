# Open Work Register

This file is COMMITTED on purpose. A record of open work that lives only in a
chat transcript, a terminal scrollback, or an uncommitted file is lost at
exactly the moment it is needed — when the session ends.

Render it with:

```
bash bubbles/scripts/cli.sh open-work
```

## What belongs here

Only **residue**: work that was noticed and never filed. It has no spec, no bug,
and no improvement entry, so nothing else in the repository knows it exists.

Rows for specs, bugs, and improvements are **derived on every run** from
`state.json` (via `work-tracker-project.sh`) and `improvements/INDEX.md`. Do not
author them here. Writing a status into this table that another artifact already
owns creates a second source of truth, and the two will disagree.

## Rules

- A residue row MUST carry both a `next-owner` and a `next-action`. A row nobody
  owns, or whose next step is "finish the thing", does not survive the next
  session and fails `open-work --lint`.
- `kind` must be `residue`. Any other value is a lint defect.
- `id` must be unique, so a row can be removed unambiguously when it closes.
- **Closed rows are DELETED, not tombstoned.** A row disappears when its work is
  done or when it graduates into a spec, bug, or improvement — at which point
  the derived projection covers it. This table answers "what is still open"; a
  growing tail of closed rows destroys that answer. Git history is the audit
  trail for what was removed and when.

## Residue

| id | title | kind | ref | state | next-owner | next-action | opened | last-seen |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| OW-002 | macOS release-hygiene produced 28 top-level FAIL against 2 on ubuntu; three root causes are now attributed and fixed, the rest are still unattributed | residue | GitHub Actions run 30779788232 on commit ad46b40, job release-hygiene-macos | open | framework-validate maintainer | Re-read the next macOS run once the current fixes land, then attribute each still-failing check individually. ATTRIBUTED AND FIXED 2026-08-03: bare `timeout` exiting 127 (13 call sites across 4 selftests), GNU-only `sed -i` in workflow-planning-provenance-selftest, and a shallow-clone `git show 86fc700` that failed evidence-admission on BOTH platforms. STILL UNATTRIBUTED: capability-ledger hermetic regeneration, capability freshness, gate-ID grep, MCP HTTP transport, MCP trust-boundary, context compactor, competitive docs, envelope truncation checks, repository work-boundary aggregate, and the runtime-concurrency check reporting "fixed state-snapshot lost an update in 1/10 rounds". Do not assume the remainder share a cause. RULED OUT 2026-08-06: OW-009's root cause (the timeout fallback watchdog holding the caller's stdout pipe and orphaning a long sleep) was tested as a shared explanation for these nine and REFUTED — none of capability-ledger, capability-freshness, mcp-http, mcp-trust, context-compactor, competitive-docs, envelope-truncation, work-boundary or state-snapshot calls bubbles_run_with_timeout, and run_check does not wrap checks in it either (only 3 call sites pass it explicitly). The fallback is macOS-only and so are these failures, which made it a plausible shared cause; it is not one. Do not re-test that link | 2026-08-03 | 2026-08-06 |
| OW-012 | Gate-hit telemetry now records which gates ever reject anything, but no gate has been retired on that evidence yet, and 26 declared gates are still named by no script at all | residue | bubbles/scripts/gate-hit-log.sh (landed IMP-036 SCOPE-4, logging half only). The 26 script-less ids measured 2026-08-05: G011-G017, G023, G030, G032, G033, G036, G050, G054, G062, G065, G066, G071, G079, G081, G112-G114, G116, G117, G119. First live sample over one guard run showed 29 gates observed and 20 with zero rejections | open | gate registry owner | Wait until the log carries at least 60 days across the consuming repos, then run `bash bubbles/scripts/gate-hit-log.sh report` per repo and retire every gate with zero recorded rejections. Do NOT retire on the first sample: a gate that has not yet rejected anything may simply not have been exercised, and one guard run against one spec is not evidence of uselessness. CORRECTED 2026-08-07 — the second half of this item was a MISMEASUREMENT and is now withdrawn. "26 declared gates named by no script at all" was produced by grepping bubbles/scripts/ for each gate id, which counts every NON-SCRIPT enforcement surface as absence. Read from the registry's own enforcedBy field instead: all 114 gates declare one, the surfaces are script 89 / mode-required 35 / guard-check 23 / behavioral 2 / unbound 2, every `script:` binding resolves to a file that exists, and `guard-check:6B` for G066 is present in state-transition-guard. Exactly TWO gates are `unbound` (G070, G071) and the schema says that value exists precisely so an unenforced gate stays visible rather than hiding behind a plausible-looking binding. There is no 26-gate wiring backlog; do not recreate one from a grep | 2026-08-06 | 2026-08-06 |
| OW-014 | IMP-036 landed all eight scopes but none of its outcome metrics has been re-measured, so the improvement is asserted by construction rather than observed | residue | IMP-036 was deleted on completion; the full rationale for each scope is in its commit message, and the baselines were measured 2026-08-05 across six delivery repos | open | framework health owner | Re-measure six numbers around 2026-10-06 using the method recorded in the IMP-036 commit messages. (1) parent-expanded occurrences in NEWLY written state: baseline 3,951 total, target 0 for new runs, read from `gate-hit-log.sh report` which now prints runs-using-parent-expansion. (2) bugs filed against an already-done parent spec: baseline 69 percent (813 of 1179), target under 40. (3) product share of changed lines: baseline 28 percent, target over 45. (4) state-file commits per repo per 60 days: baseline 306-563, target at least halved. (5) framework always-on context: baseline 850 lines, now 545. (6) GUARDRAIL, the fixed-30-day-window spec completion rate: baseline 45 percent for the June cohort, and if it FELL then something load-bearing was cut and must be restored before continuing. Do not report an improvement without its denominator; asserting one without measuring is the exact failure IMP-036 was written to correct | 2026-08-06 | 2026-08-06 |
