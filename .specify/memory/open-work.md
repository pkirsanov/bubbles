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
| OW-002 | macOS release-hygiene produced 28 top-level FAIL against 2 on ubuntu; three root causes are now attributed and fixed, the rest are still unattributed | residue | GitHub Actions run 30779788232 on commit ad46b40, job release-hygiene-macos | open | framework-validate maintainer | Re-read the next macOS run once the current fixes land, then attribute each still-failing check individually. ATTRIBUTED AND FIXED 2026-08-03: bare `timeout` exiting 127 (13 call sites across 4 selftests), GNU-only `sed -i` in workflow-planning-provenance-selftest, and a shallow-clone `git show 86fc700` that failed evidence-admission on BOTH platforms. STILL UNATTRIBUTED: capability-ledger hermetic regeneration, capability freshness, gate-ID grep, MCP HTTP transport, MCP trust-boundary, context compactor, competitive docs, envelope truncation checks, repository work-boundary aggregate, and the runtime-concurrency check reporting "fixed state-snapshot lost an update in 1/10 rounds". Do not assume the remainder share a cause | 2026-08-03 | 2026-08-03 |
| OW-009 | state-transition-guard runs ~129s on a stock macOS PATH versus ~9s with GNU coreutils present, which blows the 45s budget in workflow-planning-provenance-selftest | residue | bubbles/scripts/state-transition-guard.sh, measured against the selftest's 905-planning-provenance-missing-owners fixture | open | guard performance owner | Profile the guard under a PATH carrying no GNU coreutils and find the slow fallback path. Measured 2026-08-03: 9s with /opt/local/bin (MacPorts GNU tools) on PATH, 129s without, and identical foreground vs backgrounded — so the portable-timeout watchdog in guard-lib.sh is NOT the cause (verified: rc=0 in 0s for a fast command, rc=124 in 2s for a slow one). Raising BUBBLES_WORKFLOW_PLANNING_PROVENANCE_GUARD_TIMEOUT_SECONDS would hide the slowness rather than fix it | 2026-08-03 | 2026-08-03 |
| OW-011 | The v5 mode names printed in operator docs are supported today through the `mode: <key>` form; what is still undecided is whether to retire the v7 grandfather path and publish only the v6 primitive+tag form | residue | corrected 2026-08-04: the original evidence tested the BARE leading token (`mode-resolver.sh spec-scope-hardening`), which v7 removes by design, and never tested the `mode: <key>` form the docs actually use. docs/CHEATSHEET.md line 171 documents `mode: <key>` and the v6 form as the two supported inputs, and agents/bubbles_shared/workflow-input-bootstrap.md itself uses `mode: improve-existing`. A sweep of docs, agents, skills, prompts and templates for the genuinely-rejected bare leading token now returns 0 occurrences; the 4 that existed in docs/CHEATSHEET.md were fixed | open | workflow registry owner | Decide whether v7 keeps the `mode: <key>` surface or retires BUBBLES_MODE_GRANDFATHER and publishes only the v6 primitive+tag form. Retiring the grandfather path and rewriting the files that carry `mode: <key>` are one coupled change, so do not convert file-by-file on sight | 2026-08-03 | 2026-08-04 |
| OW-013 | 53 historical free-text agent ids are frozen in the agent-id enum baseline; the lint stops NEW drift but retires none of the existing values | residue | bubbles/scripts/agent-id-enum-lint.baseline (landed IMP-036 SCOPE-7). Union measured across the six consuming repos 2026-08-06. Four categories with different remedies: 14 retired agents and 17 legacy ralph.* ids age out on their own; 8 composite ids record several agents in ONE field and need one entry per agent; 5 carry a scope suffix welded onto the id; 9 are non-agent actors or sweep pseudo-agents that should use manual/operator/human plus a sibling field | open | control-plane schema owner | Shrink the baseline category by category, starting with the 8 composite ids and 5 scope-suffixed ids, since those are the two categories that actively corrupt aggregation rather than merely aging out. The lint already reports stale entries, so removing a category is safe once its records are rewritten. Do NOT add ids to this file to silence a failure - that inverts the ratchet | 2026-08-06 | 2026-08-06 |
| OW-012 | Gate-hit telemetry now records which gates ever reject anything, but no gate has been retired on that evidence yet, and 26 declared gates are still named by no script at all | residue | bubbles/scripts/gate-hit-log.sh (landed IMP-036 SCOPE-4, logging half only). The 26 script-less ids measured 2026-08-05: G011-G017, G023, G030, G032, G033, G036, G050, G054, G062, G065, G066, G071, G079, G081, G112-G114, G116, G117, G119. First live sample over one guard run showed 29 gates observed and 20 with zero rejections | open | gate registry owner | Wait until the log carries at least 60 days across the consuming repos, then run `bash bubbles/scripts/gate-hit-log.sh report` per repo and retire every gate with zero recorded rejections. Resolve the 26 script-less ids separately by wiring each to an enforcement script or deleting it. Do NOT retire on the first sample: a gate that has not yet rejected anything may simply not have been exercised, and one guard run against one spec is not evidence of uselessness | 2026-08-06 | 2026-08-06 |
| OW-014 | IMP-036 landed all eight scopes but none of its outcome metrics has been re-measured, so the improvement is asserted by construction rather than observed | residue | IMP-036 was deleted on completion; the full rationale for each scope is in its commit message, and the baselines were measured 2026-08-05 across six delivery repos | open | framework health owner | Re-measure six numbers around 2026-10-06 using the method recorded in the IMP-036 commit messages. (1) parent-expanded occurrences in NEWLY written state: baseline 3,951 total, target 0 for new runs, read from `gate-hit-log.sh report` which now prints runs-using-parent-expansion. (2) bugs filed against an already-done parent spec: baseline 69 percent (813 of 1179), target under 40. (3) product share of changed lines: baseline 28 percent, target over 45. (4) state-file commits per repo per 60 days: baseline 306-563, target at least halved. (5) framework always-on context: baseline 850 lines, now 545. (6) GUARDRAIL, the fixed-30-day-window spec completion rate: baseline 45 percent for the June cohort, and if it FELL then something load-bearing was cut and must be restored before continuing. Do not report an improvement without its denominator; asserting one without measuring is the exact failure IMP-036 was written to correct | 2026-08-06 | 2026-08-06 |
