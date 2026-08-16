# IMP-044 — Measurement Truth: One Populated Telemetry Plane

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) - human-reviewed. NO auto-mutation of `bubbles/*` until approved.
**Motivation:** An operator observed that metrics are never populated. A cross-repository audit confirmed it and found the sharper defect underneath. The framework runs two telemetry planes. The always-on plane is populated and rich. The opt-in plane is nearly empty and shallow. Every dashboard, agent, and recipe reads the empty one.
**Verified gaps addressed:** REG-13 readers count event types no producer writes. REG-14 declared dimensions never reach the declared store. REG-15 policy writer drops unknown keys. DOC-7 three false published claims. COV-17 no metrics lifecycle test.

## Executed Measurements

- Eight installed repositories were audited for metrics state.
- Six have an empty `.specify/metrics/` directory holding only `.gitignore`.
- The canonical bubbles source repository holds only `observations.jsonl` with 2 records.
- smackerel is the only repository with metrics enabled and data present.
- Its `events.jsonl` holds exactly 10 records, and all 10 carry `"type":"cli_command"`.
- Its `activity.jsonl` holds exactly 10 records, all for the commands `upgrade` and `doctor`.
- Zero records of type `gate_check` exist in any repository.
- Zero records of type `phase_complete` exist in any repository.
- QuantitativeFinance `.specify/runtime/gate-hits.jsonl` holds real per-gate records.
- A read of the first six lines shows `"kind":"gate"` entries naming G073, G051, G068, G082, G083, and G128 with `outcome`, `spec`, `mode`, `targetStatus`, and `guardVerdict`.
- QuantitativeFinance `.specify/runtime/` also holds `framework-events.jsonl`, `tool-calls.jsonl`, `workflow-runs.json`, and `scenario-runs.jsonl`.

## Direct Discriminators

- A repository-wide grep shows exactly two writers to the metrics plane, both in `cli.sh`, both called from one function.
- That function runs from an `EXIT` trap, so it can only ever describe the CLI process that just ended.
- The metrics record carries no `agent`, `spec`, `scope`, `gate`, `phase`, or `retry` field.
- The activity record assigns the command name to the field named `phase`.
- `gate-hit-log.sh` already writes per-gate outcomes, is always on, and ships a working `report` subcommand.
- `record_framework_event` writes to the runtime plane unconditionally and is not gated by `metrics.enabled`.
- `save_control_plane_config` writes a fixed template, so any key it does not name is dropped on the next write.

## Adversarial Re-Review

A second pass tried to falsify this proposal against the same tree.

- The claim "metrics are not collected" was falsified. Metrics are collected. They describe CLI housekeeping rather than delivery work.
- The claim "no gate telemetry exists" was falsified by reading a downstream `gate-hits.jsonl`. Per-gate outcomes exist, are current, and are richer than the dashboard's own schema.
- The claim "enabling metrics fixes it" was falsified by reading smackerel, which has metrics enabled and still cannot answer a single declared dimension.
- The claim "the registry is aspirational and harmless" was rejected. Three shipped surfaces instruct readers to compute values from a file that cannot contain them.
- The proposed remedy shifted as a result. The first draft added producers for two missing event types. The verified remedy is to stop maintaining a second plane and read the one that already works.

### Second Pass (post-authoring)

A later pass attacked the PROPOSAL rather than the problem, and corrected two claims.

- REG-14 originally read "eight declared dimensions are unproducible". That overstated the evidence. Two of the eight name a real producer in a registry comment. `bundle-cost-report.sh` exists, runs under `doctor`, and has its own selftest. The defensible claim is narrower and is now stated: none of the eight reaches the store that declares them, and six name no producer at all.
- SCOPE-3 originally proposed a `jq` merge. That was REJECTED against source. `cli.sh` states at line 277 that its JSON field reader is "simple grep-based, no jq dependency" and repeats at line 459 that it is "deliberately still no jq dependency". Its only `jq` use sits inside `doctor` and degrades with a message. The merge now uses `python3`, which `cmd_lessons add` already requires at line 3765.
- REG-13 originally read "readers target a store no writer targets". The store IS written, with `cli_command` records. The precise defect is that two subcommands count event types no producer writes.
- One finding was ADDED by this pass. The registry still declares `bundleCostProxy` while the producing script emits `referenceClosureProxy`, renamed under IMP-039.

## Problem (Verified Against Source)

### Store And Reader Parity

- **REG-13 — Two dashboard subcommands read event types that no code writes.** `cli.sh` lines 3706 and 3707 count `"type":"gate_check"` and `"type":"phase_complete"`. Lines 3725 and 3731 group by the same two types. A repository-wide grep finds those strings only in those reader lines. No producer exists.
- **REG-13 — The only producers describe the CLI, not the work.** `cli.sh` line 950 writes the event record and line 973 writes the activity record. Both are called only from `record_cli_completion` at lines 1016 and 1017, which runs from the `EXIT` trap installed at line 4246. The plane can therefore only ever describe a finished CLI invocation.
- **REG-13 — The data the dashboards want already exists elsewhere.** `gate-hit-log.sh` appends per-gate outcomes to `.specify/runtime/gate-hits.jsonl`, sourced by `state-transition-guard.sh` at lines 162 to 175. That store is always on, carries `gate`, `outcome`, `spec`, `mode`, and `guardVerdict`, and already has a `report` subcommand.
- **REG-13 — The runtime plane is unconditional while the metrics plane is opt-in.** `cli.sh` line 107 points `CONTROL_PLANE_EVENT_FILE` at `.specify/runtime/framework-events.jsonl`, and `record_framework_event` at line 712 writes without consulting `metrics.enabled`. The audited repositories confirm the split. Runtime files are populated. Metrics files are empty.

### Declared Versus Producible

- **REG-14 — None of the eight declared dimensions reaches the store that declares them.** `workflows.yaml` lines 1403 onward declare eight `measuredDimensions` under `activityTracking`, whose `storageFile` is `activity.jsonl`. That record carries `timestamp`, `command`, `phase`, `result`, `durationMs`, `target`, and `args`. Six of the eight name no producer anywhere. `linesChanged` names git in a comment and `bundleCostProxy` names `bundle-cost-report.sh`, and neither writes to the declared store.
- **REG-14 — One declared dimension carries a name its producer stopped using.** The registry declares `bundleCostProxy` at line 1417. `bundle-cost-report.sh` emits `referenceClosureProxy`, renamed under IMP-039 so a reachability proxy would stop reading as spend. `bubbles.retro.agent.md` already uses the new name. The registry still carries the old one.
- **REG-14 — Three declared scopes have no corresponding field.** Lines 1400 onward declare `perAgentTracking`, `perSpecTracking`, and `perScopeTracking` as true. No record carries an agent, spec, or scope identifier.
- **REG-14 — The activity record redefines `phase` as the command name.** `cli.sh` line 973 assigns `$command_name` to the field named `phase`. Every phase value in smackerel is therefore `upgrade` or `doctor`, neither of which is a workflow phase.
- **REG-14 — A declared evaluation block has no reader.** `workflows.yaml` line 1428 declares `outcomeEvals` with four dimensions. A repository-wide grep for `outcomeEval` returns that line and one config key. No code reads either.

### Configuration Durability

- **REG-15 — Enabling metrics silently drops unrelated policy.** `save_control_plane_config` at `cli.sh` lines 1154 to 1215 writes a fixed template naming `version`, `adoptionProfile`, `defaults`, `modeOverrides`, and `metrics`. Any other key is lost on the next write.
- **REG-15 — The loss is not hypothetical in this workspace.** The bubbles source config carries `outcomeEvalsEnabled` at line 49. Three downstream configs carry a `crossModelReview` block. Running `metrics enable` in any of those four repositories would delete that content while reporting success.

### Published Claims

- **DOC-7 — The retrospective agent instructs an impossible computation.** `bubbles.retro.agent.md` line 87 describes `events.jsonl` as providing "skill duration, gate pass/fail". Lines 118 onward instruct the agent to count gate pass and fail by gate ID from that file. No gate identifier is ever written to it.
- **DOC-7 — The status agent promises five unavailable values.** `bubbles.status.agent.md` lines 199 onward present total agent invocations, retries consumed against budget, gate pass rate, average scope completion, and lines changed as readable from `activity.jsonl`. None is derivable from its seven fields.
- **DOC-7 — The operator recipe names the wrong producer.** `docs/recipes/framework-ops.md` line 258 states that governance scripts log events to `.specify/metrics/events.jsonl`. No governance script writes there. The one writer is the CLI completion trap.

### Verification

- **COV-17 — The metrics surface has no test at all.** A grep across `tests/` and every `*selftest.sh` for `cmd_metrics`, `metrics enable`, `metrics.enabled`, and `Metrics Summary` returns nothing. No test asserts that enabling metrics produces a record, that a subcommand reads what a producer wrote, or that saving policy preserves unrelated keys.

## Design Principles

1. One plane of record. A second, quieter plane is how the readers drifted.
2. Never declare a dimension the record shape cannot carry.
3. Prefer deleting an unproducible claim over building a producer nobody asked for.
4. A policy writer must preserve what it does not understand.
5. Reuse the populated store rather than backfilling the empty one.
6. A surface with no test is a surface that will drift again.

## Proposal

### SCOPE-1 — Point the readers at the populated store (REG-13)

- Reimplement `metrics gates` on `gate-hit-log.sh report`, which already aggregates per-gate outcomes from the always-on runtime store.
- Reimplement `metrics agents` on `state.json` `executionHistory`, which is the only place agent identity per phase actually exists, and which `bubbles.retro` already reads for the same purpose.
- Keep `metrics summary` reporting CLI invocation counts and durations, and rename its rows to say so.
- Recommendation: read the runtime store directly rather than copying records into the metrics store. A copy adds a synchronization failure mode and a second truth.
- Alternative considered and rejected: emitting `gate_check` and `phase_complete` events into `events.jsonl`. That rebuilds a parallel plane whose data already exists in better shape, and it leaves the opt-in toggle able to switch gate history off.

### SCOPE-2 — Make the registry describe what is produced (REG-14)

- Reduce `metrics.activityTracking.measuredDimensions` to the dimensions the CLI plane can actually produce, which are invocation count and wall-clock duration.
- Move `gatePassFailRate` into a new `gateTelemetry` block naming `.specify/runtime/gate-hits.jsonl` as its store and `gate-hit-log.sh` as its producer.
- Move `phaseDuration`, `retryCount`, `scopeCompletionTime`, and `phaseSkipRate` into a `derivedFromState` block naming `executionHistory` as the source, matching how `bubbles.retro` already computes them.
- Rename the `phase` field in the activity record to `subcommand`, because that is the value assigned at `cli.sh` line 973.
- Rename `bundleCostProxy` to `referenceClosureProxy` so the registry matches the field `bundle-cost-report.sh` emits, and record that script as its producer rather than the activity store.
- Either give `outcomeEvals` a reader or mark the block unimplemented. Recommendation: mark it unimplemented, since no consumer has appeared since it was declared.

### SCOPE-3 — Preserve unknown configuration keys (REG-15)

- Replace the fixed heredoc in `save_control_plane_config` with a structured merge that rewrites only the keys the CLI owns.
- Use `python3`, which `cmd_lessons add` already requires at `cli.sh` line 3765, so the merge adds no new dependency to a mutating path. Do NOT use `jq`. `cli.sh` records at lines 277 and 459 that its JSON handling is deliberately jq-free.
- Refuse the write with a named remediation when `python3` is absent, rather than silently rewriting the file from a template.
- Add an adversarial test that writes a config carrying an unknown top-level block, runs `metrics enable`, and asserts the unknown block survives byte for byte.
- Recommendation: refuse rather than degrade. A policy writer that cannot preserve content must not overwrite it.

### SCOPE-4 — Correct the three published claims (DOC-7)

- Update `bubbles.retro.agent.md` to read gate outcomes from the gate-hit store and to stop describing `events.jsonl` as carrying gate results.
- Update `bubbles.status.agent.md` to present only values its named sources can produce, and to name `executionHistory` for the agent and phase rows.
- Update `docs/recipes/framework-ops.md` line 258 to name the CLI completion trap as the producer and to state what the store does and does not contain.
- Sequence this scope after SCOPE-1 so each corrected sentence describes shipped behavior.

### SCOPE-5 — Test the metrics lifecycle (COV-17)

- Add `metrics-lifecycle-selftest.sh` covering a disabled default writing nothing, an enable writing a record, a summary reading that record, and a disable preserving prior data.
- Add the SCOPE-3 unknown-key preservation case to the same selftest.
- Add an adversarial case asserting that no subcommand reports a non-zero count for a dimension with no producer. That case fails today and is the regression guard for this entire proposal.
- Register the selftest in `framework-validate.sh`.

### SCOPE-6 — Reconcile stale downstream configuration (REG-15)

- Report, without auto-editing, downstream configs carrying keys the framework no longer supports. Three carry `crossModelReview`, which `adversarial-aggregate-selftest.sh` treats as a rejected token on other surfaces.
- Surface the finding through the `doctor` advisory channel so the operator decides.
- Recommendation: never auto-remove a project-owned key. Downstream config is project-owned, and silent deletion is the defect SCOPE-3 exists to fix.

## Migration / Rollout

- SCOPE-1 changes reader implementations only. No store changes and no data migration.
- SCOPE-2 edits the registry. It removes claims rather than adding behavior, so no repository loses a working capability.
- SCOPE-3 changes a writer and must land with its adversarial test in the same change.
- SCOPE-4 depends on SCOPE-1 and lands after it.
- SCOPE-5 can be authored first as a failing test that documents current behavior, then completed as the scopes land.
- SCOPE-6 is advisory output only.
- Suggested order: 5 authored failing, then 1, 2, 3, 4, 6.
- No scope requires a downstream repository to re-enable metrics, and no scope changes the shipped default of disabled.

## Risks And Mitigations

- **R1 — Reading the runtime store couples metrics to the guard.** Mitigation: the coupling already exists through `bubbles.retro`, and `gate-hit-log.sh` degrades to a clear "no telemetry yet" message when the log is absent.
- **R2 — Removing declared dimensions reads as capability loss.** Mitigation: nothing is lost, because no dimension was ever produced. The change moves each one to the block that can actually produce it or marks it unimplemented.
- **R3 — The structured merge needs `python3`, which may be absent.** Mitigation: refuse the write with a named remediation instead of falling back to the template that causes the data loss. `cmd_lessons add` already fails the same way on the same dependency, so the posture is consistent.
- **R4 — The gate-hit store carries fixture pollution in the source repository.** Mitigation: this is already recorded as COV-15 in IMP-042. SCOPE-1 filters on `kind` and on spec paths outside the temporary directory, and the two proposals should land in either order without conflict.
- **R5 — Renaming the activity `phase` field breaks a downstream reader.** Mitigation: no downstream reader exists. The only consumer is `bubbles.status.agent.md`, which SCOPE-4 updates in the same proposal.

## Files To Touch

| File | Owner | Change |
|---|---|---|
| `bubbles/scripts/cli.sh` | framework | Reimplement `metrics gates` and `metrics agents`, rename the activity field, merge-preserving config writer |
| `bubbles/workflows.yaml` | framework | Split dimensions by real producer, mark `outcomeEvals` unimplemented |
| `agents/bubbles.retro.agent.md` | framework | Read gate outcomes from the gate-hit store |
| `agents/bubbles.status.agent.md` | framework | Present only producible values |
| `docs/recipes/framework-ops.md` | framework | Name the real producer |
| `bubbles/scripts/metrics-lifecycle-selftest.sh` | framework | New lifecycle and preservation test |
| `bubbles/scripts/framework-validate.sh` | framework | Register the new selftest |

## Acceptance Criteria

1. `metrics gates` reports real per-gate outcomes in a repository whose guard has run.
2. `metrics agents` reports agent invocations derived from `executionHistory`.
3. No subcommand reads an event type that no producer writes.
4. Every dimension in `workflows.yaml` names a store and a producer that exist.
5. `metrics enable` preserves an unknown top-level config block byte for byte.
6. `metrics-lifecycle-selftest.sh` passes, including the unknown-key and no-producer cases.
7. No agent or recipe describes a metrics file as containing a field it cannot contain.
