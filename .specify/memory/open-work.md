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
