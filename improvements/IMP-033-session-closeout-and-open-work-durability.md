# IMP-033 — Session closeout and open-work durability: stop losing work at the session boundary

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** An operator repeatedly hand-writes a multi-paragraph reconciliation prompt ("reconcile all local changes, merge stashes/worktrees/branches to main, commit, push, leave local state clean, and record open work so the next session can pick it up") because Bubbles has no capability for it. Audited against the framework source at commit `5f77d3520bf60d94e0a5d674ee5349d35605b7c5` and against `.specify/runtime/framework-events.jsonl`, `.specify/runtime/workflow-runs.json`, and `.specify/memory/bubbles.session.json`.
**Verified gaps addressed:** WIP-1 (session-boundary work durability), WIP-2 (the open-work record is ignored, unwritten, or the wrong shape), WIP-3 (no closeout command or mode), COV-5 (hygiene detector blind to the primary worktree and the remote), EV-5 (`doctor` prints a green hygiene tick over unseen state)

## Provenance

| Evidence | Source |
|---|---|
| Framework HEAD at audit time | `git rev-parse HEAD` → `5f77d3520bf60d94e0a5d674ee5349d35605b7c5` |
| Live repo state at audit time | `git status --porcelain` → 8 (8 tracked modifications, 0 staged, 0 untracked at snapshot); `git rev-list --count origin/main..HEAD` → 6 |
| Detector verdict on that same state | `bubbles/scripts/worktree-hygiene-report.sh` → all zeros, exit 0 |
| Health-check verdict on that same state | `bubbles/scripts/cli.sh doctor` → `✅ Worktree hygiene: 0 worktrees (0 merged, 0 unmerged, 0 prunable, 0 dirty, 0 lease-held, 0 experiment)`, `Result: 20 passed, 0 failed, 8 advisory`, exit 0 |
| Session-state durability | `.specify/memory/.gitignore` names four files, one of which is `bubbles.session.json`; `.specify/runtime/.gitignore` is `*` |
| Session-archive path | `grep -rln "memory/sessions" bubbles/scripts/` → `trajectory-inspector.sh` only, which READS it; `.specify/memory/sessions/` does not exist |
| Existing projection seam | `bubbles/scripts/work-tracker-project.sh` — read-only, idempotent `state.json` → provider-neutral work-item projection |
| Existing aggregation seam | `bubbles/scripts/trajectory-inspector.sh` — already composes session, archived sessions, `lessons.md`, and `specs/*/state.json` |
| Upkeep dispatch constraint | `agents/bubbles.upkeep.agent.md` frontmatter sets `disable-model-invocation: true` (pure top-level runner) |
| Registry sizes | `agents/*.agent.md` → 41; `modes.yaml` top-level mode ids → 61 |
| Session-state freshness | `.specify/memory/bubbles.session.json` last written `2026-07-15T…`, while `.specify/runtime/framework-events.jsonl` was written the day of this audit |
| Runtime inputs analyzed | `.specify/runtime/framework-events.jsonl`, `.specify/runtime/workflow-runs.json`, `bubbles/registry/gates.yaml`, `bubbles/workflows/modes.yaml`, `bubbles/workflows/aliases.yaml` |
| Terminal-status registration | `grep -rln "backup_verified"` → `bubbles/workflows/modes.yaml` ONLY; no separate status registry constrains a new `statusCeiling` |

> **The audit state is a pinned snapshot, not current state.** The 8 dirty files and 6 unpushed commits above were observed at `5f77d352`. A later session committed that work, so `git status` today shows a clean tree at a newer HEAD. The snapshot is cited by commit precisely so it stays checkable after the tree moves; it is evidence of what the detector reported at that moment, not a claim about the tree right now.

## Problem (verified against source)

- **COV-5 — the hygiene detector cannot see the two most common leak vectors.** `bubbles/scripts/worktree-hygiene-report.sh` enumerates LINKED worktrees only. Its own code skips the primary worktree in two places ("The main worktree is never a reap candidate; skip it silently."). Its only reference to a remote is `symbolic-ref refs/remotes/origin/HEAD`, used solely to derive the trunk BRANCH NAME. It therefore has no concept of uncommitted work in the checkout the operator actually types in, and no concept of commits that exist locally but not on the remote. Framework-wide, `grep -rln "unpushed\|not pushed\|ahead of origin"` over `agents/ prompts/ skills/ instructions/ bubbles/ docs/` returns ZERO files.
- **EV-5 — `doctor` reports clean over state it never looked at.** On this repo, holding 8 dirty files and 6 unpushed commits, `cli.sh doctor` printed `✅ Worktree hygiene: 0 worktrees (…0 dirty…)` and finished `20 passed, 0 failed`. A green tick is being produced as proof of a condition the detector is structurally incapable of observing. `cli.sh:2258` also matches `^worktree-hygiene: ` only, so the detector's SECOND line (`worktree-hygiene-branches:` — stale branches and lingering stashes) is computed and then discarded before it ever reaches the operator.
- **WIP-1 — nothing records work that did not become an artifact.** `bubbles.recap` produces Done / In Progress / Open in a chat response and is explicitly read-only ("It is read-only — it does NOT modify artifacts, state.json, or any files"). `bubbles.handoff` produces one copyable block the human must paste into a new chat. Both surfaces evaporate when the window closes. Work that never reached a `spec.md`, a `BUG-NNN`, or an `IMP-NNN` has no durable home at all.
- **WIP-2 — the record that exists is either ignored, unwritten, or the wrong shape.** Three surfaces look like they should hold open work and none does. `.specify/memory/bubbles.session.json` carries exactly the right content (`turnSnapshots[].note`, `convergenceLoops[]`) but `.specify/memory/.gitignore` names it, so it never leaves the machine; its last write also predates the current runtime event log by weeks, so present-day runs are not maintaining it. `.specify/memory/sessions/*.json` WOULD be committed, because that `.gitignore` names four files and not the directory, but `grep -rln "memory/sessions" bubbles/scripts/` returns exactly one file, `trajectory-inspector.sh`, which READS it. The archive path has a reader and no writer, and the directory does not exist. `.specify/memory/lessons.md` is committed and durable, but it is a learning log with no owner, no next action, and no open-versus-closed state. `.specify/runtime/` is the only directory ignored wholesale (`.gitignore` is `*`), which is correct for event logs and wrong as a home for work state.
- **WIP-3 — no closeout capability exists at any layer.** `cli.sh --help` lists no `closeout`, `finish`, or `reconcile` command. `bubbles/workflows/modes.yaml` declares 61 modes and none of them closes out local state; `grep -rn "closeout"` across `agents/ skills/ bubbles/workflows/` resolves exclusively to WORKFLOW closeout (the `finalize` phase of a spec run), never SESSION closeout. `bubbles/scripts/release-check.sh` contains no clean-tree or pushed-state check. The operator's hand-written prompt is the current implementation.
- **Corroborating detail — the residue is real, and the closest drift surface still cannot see it.** During this audit the working tree held untracked `skills/__manifest_leak_probe/`, `bubbles/scripts/__manifest_leak_probe.sh`, and `bubbles/adapters/observability/__manifest_leak_probe.sh` — the exact three paths `release-manifest-purity-selftest.sh:54-56` plants, plus the skill `inventory-parity-check-selftest.sh:113` plants. `inventory-parity-check.sh:8` documents the probe as "planted+removed by" the selftests, so residue in the tree means either a run in flight or a cleanup that did not complete; the audit cannot distinguish the two, and that is the point — no surface tells the operator which. `repo-drift-report.sh` comes closest and still misses it: it does report uncommitted (`:275`) and staged (`:280`) edits, but it sources them from `git diff --name-only -- "$@"` and `git diff --cached --name-only -- "$@"`, which are caller-path-scoped and cover TRACKED files only. Untracked residue is invisible to it, and it computes no ahead or behind count.

## Delivered

- **SCOPE-1 — LANDED.** `worktree-hygiene-report.sh` emits the third `worktree-hygiene-local:` summary line (primary-worktree dirty/untracked counts, ahead/behind against the resolved remote trunk, and ALL non-trunk local branches), with honest `remote=none` / `remote-untracked` / `remote-unverified` / `detached-HEAD` degradation and an opt-in `--fetch`. `--porcelain` is byte-identical, asserted by `worktree-hygiene-guard-selftest.sh` cases f9–f11 and h1–h11.
- **SCOPE-2 — LANDED.** `cli.sh doctor` consumes all three summary lines. The green tick now requires every observed counter across all three to be zero AND the remote comparison to have been observable; dirty-only renders as a neutral note, while unpushed commits, non-trunk branches, and stashes render as warnings. The previously discarded `worktree-hygiene-branches:` line now reaches the operator. Exit-code contract unchanged. Asserted by `doctor-hygiene-surface-selftest.sh`.

- **SCOPE-3 — LANDED.** `.specify/memory/open-work.md` is a committed markdown register (plus `templates/open-work.md.tmpl`, seeded by `install.sh`). `open-work-report.sh` is the single aggregator: spec and bug rows are DERIVED through `work-tracker-project.sh` (consumed unchanged), improvement rows from `improvements/INDEX.md`, and terminal-for-mode is delegated to `is-terminal-for-mode.sh` so mode ceilings are not misreported as backlog. Only `residue` rows are authored, and `--lint` rejects a row with no next-owner, a placeholder next-action, a non-residue kind, a duplicate id, or a git-ignored register. `trajectory-inspector.sh` renders it as section 6 and `cli.sh open-work` exposes the same code path with `--format json`. Asserted by `open-work-report-selftest.sh` (19 cases; a1/a2 mutate `state.json` and observe the rendered row change, proving derivation rather than authorship).

- **SCOPE-4 — LANDED.** `cli.sh closeout` (over `closeout-report.sh`) reports the hygiene snapshot, a disposition per branch and stash (`merge-able`, `has-unique-commits`, `dirty`, `lease-held`, `checked-out`), unrecorded residue as register-shaped rows, the exact commands, and the open-work register. Report-only is the default and `--apply` is the only execution mechanism; `--dry-run` is an explicit no-op synonym. `--apply` executes only `git branch -d` on a fully-merged, unleased, not-checked-out branch plus the session archive to `.specify/memory/sessions/<id>.json`, closing the reader-without-writer path in `trajectory-inspector.sh`. The IMP-023 writer-lease is re-checked AT ACTION TIME, mirroring `worktree-reap.sh`'s `still_lease_held()`. There is no `--force`, `--skip`, or `--ignore` at any layer.
  Asserted by `closeout-report-selftest.sh` (27 cases). The load-bearing case is e2: a lease acquired AFTER the report but BEFORE `--apply`, which is the only case that separates an action-time check from a snapshot-time one. d1 is its positive control — without proof that the delete path is live, every refusal assertion would pass for the wrong reason.
  **Two defects were found by building the harness, and both are fixed.** (1) `closeout-report.sh` and `open-work-report.sh` accepted an EMPTY `--repo-root` and fell back to walking upward from the current directory. A caller passing an unset variable therefore pointed a mutating command at whatever repository the process was standing in. Empty is now a usage error (case g3). (2) `local name="$1" repo="$TMP_ROOT/$name"` is unsafe: bash declares every name in a single `local` before evaluating any assignment, so `$name` is unbound under `set -u` and the path silently collapses to empty — and `git -C ""` is a no-op that operates on the current repository. The harness now routes every fixture path through a `fixture()` guard that refuses an empty path or any path outside its own temp root.

## Proposal

### SCOPE-5 — The workflow mode (WIP-3) — land last, and only after the policy carve-out below is approved

Register `upkeep task:session-closeout`, mapping to a new v5 registry key `upkeep-session-closeout`.

**Tag key verified in source: `task:`, not `action:`.** All seven existing upkeep aliases use `tags: { task: <name> }` (`upkeep-backup-verify` through `upkeep-compliance-sweep`). An `action:` tag on the `upkeep` primitive breaks the established grammar and the `(primitive, tag)` uniqueness invariant `mode-alias-selftest.sh` enforces.

The mode definition must match the shape its family already uses, not a shape borrowed from `framework-health`. This block is ILLUSTRATIVE: `grep` finds no schema validating `statusCeiling`, `terminalAliases`, `requiredGates`, or `constraints` keys, so the authoritative check at landing time is `mode-alias-selftest.sh` (alias invariants), not a schema.

```yaml
upkeep-session-closeout:
  statusCeiling: closeout_recorded      # verified: terminal statuses live ONLY in modes.yaml; no registry to update
  terminalAliases: [ closeout_recorded ]
  phaseOrder: [ select, audit, docs, finalize ]
  requiredGates: [ G001, G011, G012, G073 ]   # the verified baseline `resume-only` carries
  constraints:
    modeClass: upkeep
    requireOpenWorkRegisterWrite: true
    planningTruthMutation: false
    specReviewDefault: off
```

Two notes on that block, both from reading the family rather than pattern-matching it:

- **`requireCalendarTaskDue` is OMITTED, not set to `false`.** All seven existing uses take a task-NAME string (`backup`, `restore-test`, `patch-cycle`, …). A boolean there would be a type violation, and absence is how every non-upkeep mode already expresses "not calendar-gated". The omission is exactly what the carve-out below has to authorize.
- **`requiredGates` is the verified `resume-only` baseline only.** Existing upkeep modes add `G006` (`docs_sync_gate`) and `G007` (`validation_gate`) because they run real devops and validate phases. A read-only closeout runs neither, so `G007` in particular should not be copied in by imitation. The final set is the mode owner's call at landing time.

**Decision: reuse the `upkeep` primitive; do not add a sixteenth.** `bubbles/workflows/aliases.yaml` declares "The 15 canonical v6 primitives" and the v6.0 collapse is the whole point of that file. `upkeep` already means recurring operational hygiene. That today's upkeep TASKS are production-oriented (backup, restore-drill, patch-cycle, secret-rotation) is a property of the task list, not of the primitive.

**Decision: give it a `workstation` task class with a repo-local ledger.** `bubbles.upkeep` currently proves its claims against the knb-side `/srv/backups/upkeep-ledger.jsonl` on a deploy host, and its honesty contract depends on that. Session closeout is developer-workstation hygiene and must record to `.specify/runtime/` instead. Keeping the two ledgers separate preserves the production-evidence contract untouched.

**Unresolved conflict, surfaced rather than smuggled: the `upkeep` family is calendar-gated and session closeout is not.** Every existing upkeep mode carries `requireCalendarTaskDue: <task>`, and `bubbles-upkeep-operations.instructions.md` is a NON-NEGOTIABLE policy that states "DO NOT invoke `upkeep-*` workflow modes unless the corresponding task is `DUE` in the calendar output" and lists "Running unscheduled 'safety drills'" as a forbidden pattern. Session closeout is inherently ad-hoc: it happens whenever the operator stops working, which no calendar can predict. The two options are:

- **Option A (recommended): an explicit, named carve-out.** Amend `bubbles-upkeep-operations.instructions.md` to scope the calendar rule to the `production` task class and exempt the `workstation` class by name. The rule's stated rationale is that ad-hoc drills are "workload and ledger noise" — a cost that comes from exercising a deploy host and writing to the production ledger. A workstation closeout touches neither. The carve-out must be written into the instruction file, because a silent exception to a NON-NEGOTIABLE policy is exactly the erosion those files exist to prevent.
- **Option B: drop SCOPE-5 entirely.** SCOPE-4's `cli.sh closeout` already delivers the operator capability. The mode adds an agent-driven path and nothing else. If the owner declines the carve-out, this scope should be withdrawn rather than forced.

SCOPE-5 is therefore the last scope to land and is the one most reasonably deferred. SCOPE-1 through SCOPE-4 have no dependency on it.

**Constraint verified in source: `bubbles.upkeep` is a pure top-level runner.** Its frontmatter sets `disable-model-invocation: true`, so it CANNOT be dispatched as a subagent, and per `bubbles-agents.instructions.md` no agent may name it in `agents:`. SCOPE-5 must therefore NOT route `bubbles.workflow` into it, and any design that assumes orchestrator dispatch will silently no-op. The mode runs in the runner the operator invokes directly:

```
/bubbles.upkeep             # runs the due task, including session-closeout
```

That is the short prompt this proposal exists to provide, and it needs no new prompt shim, because `prompts/bubbles.upkeep.prompt.md` already exists.

**Alternative considered and rejected: a new `bubbles.closeout` agent.** `doctor` reports 41 installed agents and flags five over their bundle-cost target. What SCOPE-1 through SCOPE-4 add is a detector plus a report, which needs no new dispatch surface and no new prompt shim.

### SCOPE-6 — Enforce at the only moment enforcement is possible (WIP-1)

An end-of-session invariant cannot be enforced at end of session. The operator simply stops typing; no hook fires, and a git hook is useless here because the failure mode is precisely NOT pushing. The enforceable moment is the NEXT session's first repository-bound command.

- Have the `resume` primitive and `doctor` read the open-work register and lead with carried-over items.
- Keep it surfacing, not blocking. Refusing to start work because the previous session left something open would punish the operator for the framework's own gap.

### SCOPE-7 — Multi-repo honesty, without weakening the binding contract (WIP-3)

The operator's real workflow spans seven repositories in one workspace. The repository-binding contract is deliberately one repository per command, and `repository-binding-host-context.sh:191` fails closed on a workspace root that is not a Git worktree, with no bypass. That refusal fired during this very audit on a non-git workspace folder.

- Do NOT soften the fail-closed behavior. Authority resolution is the wrong place to become permissive.
- Make the refusal actionable instead: name the offending root and print the reduced-root command the operator can run immediately.
- Have `closeout` end by printing the exact per-repository invocation for each of the OTHER host-declared roots, so the operator runs N bounded closeouts rather than one unbounded sweep.

## Migration / rollout

- SCOPE-1 and SCOPE-2 landed together, as required; see the Delivered section.
- SCOPE-3 landed on top of two scripts that already existed: it CONSUMES `work-tracker-project.sh` unchanged and EXTENDS `trajectory-inspector.sh`.
- SCOPE-4 landed on SCOPE-1 (snapshot) and SCOPE-3 (residue rows).
- SCOPE-5 lands LAST, is gated on the Option A carve-out being approved, and is withdrawable without affecting anything else. Nothing in SCOPE-1 through SCOPE-4 depends on it. When it lands it must keep the `mode-alias-selftest.sh` invariants green.
- SCOPE-6 depends on SCOPE-3.
- SCOPE-7 splits: the refusal-message half is doc-and-message only and can land first; the per-repository print depends on SCOPE-4.
- Every scope is advisory-until-configured. No gate is registered by this proposal, and none should be until SCOPE-1 through SCOPE-4 have run against real repositories for at least one release cycle.

## Risks & mitigations

- **R1 — the register decays into a stale second source of truth.** Mitigate by deriving every artifact-backed row at render time and permitting authorship only for `residue` rows. This is the same invariant IMP-032 established for status mirrors.
- **R2 — alert fatigue turns the advisory into noise.** A dirty tree mid-session is the normal case, so a permanent yellow warning would train the operator to ignore the block. Mitigate with the ranked signals in SCOPE-2 and configurable thresholds; dirty-only stays a note.
- **R3 — `--apply` destroys work.** Mitigate with dry-run default, a hard refusal on unmerged, dirty, and stashed state, and no force flag at any layer.
- **R4 — an offline or remote-less run reports a false clean.** This is the exact failure class the proposal exists to close, so reproducing it would be self-defeating. Mitigate with explicit `remote=none` and `remote-unverified` states, covered by hermetic selftest fixtures.
- **R5 — scope creep into a git porcelain.** Mitigate by keeping `closeout` a reporter: it PRINTS commands, and `--apply` executes only the provably safe subset.
- **R6 — the widened detector breaks `worktree-reap.sh`.** Mitigate with a byte-identical `--porcelain` assertion in the selftest, run before and after.
- **R7 — reusing `work-tracker-project.sh` couples this register to that script's output contract.** Its header states the projection is a pure function of `state.json` with byte-identical output for identical input, which is exactly the property being relied on. Mitigate by CONSUMING it unchanged and treating any future edit to it as a contract change for all its consumers, not just this one.
- **R8 — a design that assumes orchestrator dispatch into `bubbles.upkeep` fails silently.** `disable-model-invocation: true` means a subagent dispatch does not error, it no-ops. Mitigate by keeping the operator invocation direct (`/bubbles.upkeep`) and asserting in the selftest that no agent's `agents:` list names it.
- **R9 — SCOPE-5 erodes a NON-NEGOTIABLE policy if the carve-out is implicit.** Registering a calendar-exempt mode in a calendar-gated family without amending `bubbles-upkeep-operations.instructions.md` would create precisely the silent exception that policy forbids. Mitigate by making the instruction amendment a precondition of SCOPE-5, and by withdrawing SCOPE-5 if the owner declines it.
- **R10 — a concurrent session makes the closeout snapshot stale between report and apply.** A second session can commit, branch, or stash in the same repository while `closeout` is deciding, so an `--apply` that trusts its opening snapshot can act on state that moved. This is not hypothetical: a concurrent session committed the working tree during this audit. Mitigate by consuming the existing IMP-023 writer-lease exactly as `worktree-reap.sh` does — re-check at action time (`still_lease_held()`), never from the snapshot — and by refusing rather than proceeding when the lease is held.

## Acceptance criteria (when implemented)

- `upkeep task:session-closeout` resolves through `mode-resolver.sh` with all four `mode-alias-selftest.sh` invariants intact, and no agent's `agents:` list names `bubbles.upkeep`. If the Option A carve-out is declined, this criterion is void because the scope is withdrawn.
- `.specify/memory/sessions/<id>.json` is written by closeout and read back by `trajectory-inspector.sh`, closing the reader-without-writer path. (LANDED with SCOPE-4.)
- After a closeout writes the register, the next `doctor` run prints an open-work section containing every `residue` row id from that register. This is asserted against the hermetic fixture; "the operator does not have to restate it" is the intent, and the row-id match is the check.
- The `resume` primitive reads the register and names the carried-over items before selecting work, asserted against the same fixture. (SCOPE-6 has two halves; the criterion above only covers `doctor`.)
- `repository-binding-host-context.sh` refusing a non-git workspace root names the offending root in its message and prints the reduced-root command, asserted by a fixture with one non-git root among several git roots. Its exit code and fail-closed behaviour are unchanged, asserted by the same fixture. (SCOPE-7, first half.)
- `closeout` ends by printing one invocation line per OTHER host-declared root, asserted against a multi-root fixture. No cross-root state is read, preserving the one-repository-per-command binding contract. (SCOPE-7, second half.)

## Incidental finding (recorded, not fixed by this proposal)

Authoring this proposal surfaced an unrelated convention mismatch, recorded here rather than dropped, because "record the open work" is the principle this proposal argues for.

`framework-health-evidence-lint.sh:200` satisfies its index-row check with `grep -qF "$base"`, where `base` is the FULL basename including `.md`. `INDEX.md` instructs authors to "add a row below", and every historical row carries the bare identifier (`| IMP-030 | …`) rather than the filename. Those rows fail check 4.

The mismatch is live and reproducible, and the proof is visible in `INDEX.md` itself. Line 48 carries IMP-032 as a bare identifier (`| IMP-032 | …`), the form `INDEX.md` and `TEMPLATE.md` instruct authors to write. Line 49 carries IMP-033 as a LINK, because a bare row made the lint fail during this very audit and linking the filename was the only way to pass. That asymmetry inside one table is the finding.

The applied-IMP convention is what keeps this from being noticed: an APPLIED proposal's file is deleted and its INDEX row kept, so `git ls-tree HEAD improvements/` currently holds no IMP file at all for the lint to scan, and the check succeeds vacuously. The requirement therefore only ever binds a LIVE proposal, which is precisely when a false pass is most expensive. (An earlier draft of this finding cited IMP-032 as present in `HEAD` at commit `be678f8`; a concurrent session has since committed its deletion, which is why the proof is anchored to the INDEX rows rather than to a transient tree state.)

IMP-033 satisfies the check by linking its identifier to its filename. Either the lint should match on the `IMP-NNN` identifier, or `INDEX.md` and `TEMPLATE.md` should require the linked-filename row form. Owner: the G125 lint author.

## Files to touch (on approval)

`bubbles/scripts/cli.sh` (SCOPE-7: per-repository print) — framework maintainer.
`bubbles/workflows/modes.yaml` and `bubbles/workflows/aliases.yaml` (SCOPE-5: `upkeep-session-closeout` key plus the `upkeep task:session-closeout` tuple — `task:`, matching all seven existing upkeep aliases) — `bubbles.workflow` owns mode registration; `mode-alias-selftest.sh` must stay green.
`instructions/bubbles-upkeep-operations.instructions.md` (SCOPE-5 PRECONDITION: scope the calendar-gating rule to the `production` task class and name the `workstation` exemption) — `bubbles.upkeep`; without this amendment SCOPE-5 must not land.
`agents/bubbles.upkeep.agent.md` (SCOPE-5: `workstation` task class with the repo-local ledger, explicitly separate from the production ledger) — `bubbles.upkeep`.
`agents/bubbles.recap.agent.md` and `agents/bubbles.handoff.agent.md` (SCOPE-3: point their Open/In-Progress output at the durable register instead of ending in chat only; both stay read-only) — respective agent owners.
`bubbles/scripts/repository-binding-host-context.sh` (SCOPE-7: actionable refusal message naming the non-git root; fail-closed behavior unchanged) — repository-binding owner.
`docs/CHEATSHEET.md` and `docs/guides/WORKFLOW_MODES.md` (SCOPE-4, SCOPE-5: document the command and the mode) — `bubbles.docs`.
