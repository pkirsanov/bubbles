# IMP-033 — Session closeout and open-work durability: stop losing work at the session boundary

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** Reconciliation of commits `48a8cdb` and `fce781b` found two concrete loss modes in one closeout: the rollback initially removed three open bugs and a proposal without durable disposition, while `fce781b` added this IMP's index row without the linked proposal file. The same session also had to reconstruct remote divergence, merge state, worktree count, stashes, branches, and push readiness manually.
**Verified gaps addressed:** `WIP-1` improvement index integrity is one-way · `WIP-2` the active worktree is absent from hygiene closure · `WIP-3` remote and auxiliary Git closure has no aggregate verdict · `COV-5` no closeout regression surface exists · `EV-5` terminal result envelopes do not carry Git closeout facts

## Problem (verified against source)

- **`WIP-1` — improvement index integrity is one-way.** `improvements/INDEX.md`
  on `origin/main` names and links this proposal, but
  `improvements/IMP-033-session-closeout-and-open-work-durability.md` is absent
  from that tree and from all reachable and reflog history. Gate G125's
  `framework-health-evidence-lint.sh` checks that every proposal file has an
  index row. It does not check the inverse, so a broken index link passes.
- **`WIP-2` — worktree hygiene does not prove the active checkout is clean.**
  `worktree-hygiene-report.sh` deliberately skips the first worktree record
  because the main worktree is never a reap candidate. That is correct for
  reaping, but it means the report cannot certify that the active checkout has
  no tracked changes, untracked files, or unresolved merge state.
- **`WIP-3` — Git closure is distributed across manual commands.** The worktree
  report surfaces linked worktrees, stale branches, and stashes. It does not
  emit current branch, local and upstream SHA equality, ahead/behind counts,
  push outcome, or a closed final verdict over all of those facts. No
  `*closeout*` command exists under `bubbles/scripts/`.
- **`WIP-3` — open findings can disappear during a legitimate rollback.** The
  rollback reconciled in `48a8cdb` initially deleted BUG-004, BUG-005, BUG-006,
  and IMP-032's proposal history. The code rollback was intentional; the loss
  of independent open-work accounting was not. An external inventory had to
  detect the difference.
- **`COV-5` — no hermetic closeout regression surface exists.** Existing
  worktree hygiene selftests prove safe classification and reaping. They do not
  exercise a repository-level terminal tuple covering clean active worktree,
  one checked-out branch, no stashes, no extra local branches, and
  `HEAD == upstream` after a successful push.
- **`EV-5` — the terminal result envelope has no Git closure contract.**
  `skills/bubbles-result-envelope/SKILL.md` requires finding accounting and
  evidence references, but its terminal shape has no fields for commit SHA,
  push result, upstream SHA, active branch, worktree count, stash count, or
  residual local branches. A completion envelope can therefore omit the state
  needed to resume or audit repository closeout.

## Proposal

### SCOPE-1 — Bidirectional improvement-index integrity (`WIP-1`)

- Extend `framework-health-evidence-lint.sh` so every linked
  `IMP-NNN-*.md` target in the proposal table must exist, in addition to the
  existing file-to-row check.
- Treat a plain, intentionally unlinked historical row as valid only when its
  status is terminal (`APPLIED`, `REJECTED`, or `SUPERSEDED`). A `PROPOSED`,
  `ACCEPTED`, or `IN PROGRESS` row must link to an existing proposal file.
- Add adversarial fixtures for a missing linked proposal, an unlinked applied
  historical row, and an orphan proposal file.

### SCOPE-2 — Read-only repository closeout report (`WIP-2`, `WIP-3`)

- Add `bubbles/scripts/session-closeout-report.sh`, read-only and fail-loud on
  malformed Git state. It reports a closed field set:
  `repositoryRoot`, `branch`, `headSha`, `upstreamRef`, `upstreamSha`,
  `ahead`, `behind`, `clean`, `untrackedCount`, `unmergedCount`,
  `worktreeCount`, `stashCount`, and `extraLocalBranches`.
- Reuse `worktree-hygiene-report.sh` for linked-worktree, stale-branch, and
  stash facts. Do not duplicate its classifiers and do not make its report
  mutate the repository.
- Distinguish `ready-to-commit`, `ready-to-push`, `closed`, and `blocked`
  outcomes. A dirty tree is not a failure while work is active; it is a
  terminal closeout blocker only when the caller requests `--require-closed`.

### SCOPE-3 — Safe reconciliation plan, never silent cleanup (`WIP-3`)

- Add a planner mode that maps each non-closed fact to an explicit action:
  commit tracked work, classify untracked files, fetch and integrate upstream,
  push without force, or inspect a named stash/branch/worktree.
- Reuse `worktree-reap.sh` only for its existing MERGED and PRUNABLE set.
  Never auto-drop a stash, delete an unmerged branch, remove a dirty worktree,
  force-push, reset, or restore user changes.
- Emit unresolved items as routeable findings when no safe automated action
  exists.

### SCOPE-4 — Terminal envelope Git provenance (`EV-5`)

- Extend the terminal RESULT-ENVELOPE contract with an optional
  `repositoryCloseout` block carrying the report's closed fields plus
  `commitSha`, `pushRemote`, `pushOutcome`, and the exact commands used for the
  final proof.
- Require the block for source-repository DevOps and release closeouts that
  claim a push completed. Keep it optional for read-only agents and
  non-repository-sensitive invocations.
- Validate internal consistency: `outcome: completed_owned` plus
  `pushOutcome: succeeded` requires `headSha == upstreamSha`, `clean: true`,
  `unmergedCount: 0`, and no extra worktree/branch/stash state.

### SCOPE-5 — Hermetic closeout selftest and doctor advisory (`COV-5`)

- Build a temporary bare remote plus working clone fixture covering clean
  closure, dirty main, untracked file, unresolved merge, ahead-only,
  behind-only, diverged, extra worktree, stash, and extra local branch.
- Wire the selftest into `framework-validate`.
- Add a `doctor` advisory that names non-closed facts without changing its exit
  code. Closeout enforcement belongs to the explicit `--require-closed` call,
  not ordinary health inspection.

## Migration / rollout

- Land SCOPE-1 first. It closes the exact missing-file defect without changing
  runtime behavior.
- Land SCOPE-2 and its selftest next as report-only. Exercise it in source-repo
  closeouts before adding any required envelope field.
- Land SCOPE-3 only by composing existing safe reapers and explicit operator
  actions. It must remain non-destructive by default.
- Land SCOPE-4 after the report schema is stable so the envelope references one
  canonical field set.
- Keep the `doctor` integration advisory. Require closeout only in explicit
  DevOps/release finalization paths.

## Risks & mitigations

- **R1** A closeout command becomes a destructive "clean everything" shortcut
  → keep the report read-only, reuse the existing safe reaper, and prohibit
  reset, restore, force-push, stash drop, and unmerged-branch deletion.
- **R2** Remote checks block offline work → distinguish unknown/unfetched
  upstream state from divergence; only `--require-closed` refuses an unknown
  final push state.
- **R3** The aggregate duplicates worktree classifiers and drifts → consume the
  existing report's machine-readable output instead of reimplementing it.
- **R4** Required envelope fields burden diagnostic agents → scope the closeout
  block to state-modifying repository finalizers and pushed-completion claims.
- **R5** Historical applied IMP rows become invalid because their files were
  intentionally retired → require files only for nonterminal linked rows and
  keep explicit terminal historical rows legal.

## Acceptance criteria (when implemented)

- A `PROPOSED` index row linking a missing IMP file fails G125 with the missing
  path; an `APPLIED` unlinked historical row remains legal.
- The closeout report produces stable machine-readable facts for every fixture
  and never changes Git status, refs, worktrees, stashes, or remotes.
- `--require-closed` succeeds only when the active branch is the declared
  trunk, the tree is clean, `HEAD == upstream`, exactly one worktree exists,
  no stash exists, and no extra local branch remains.
- Every unsafe state names the exact retained artifact and a bounded operator
  action. No fixture is reset, force-pushed, restored, or silently deleted.
- A pushed `completed_owned` DevOps envelope is rejected when its closeout
  fields contradict the repository facts.
- `framework-validate` executes the closeout selftest, and `doctor` reports
  non-closed state as advisory without changing its exit code.

## Files to touch (on approval)

`bubbles/scripts/framework-health-evidence-lint.sh` and
`bubbles/scripts/framework-health-evidence-lint-selftest.sh` (SCOPE-1,
`bubbles.test`) · new `bubbles/scripts/session-closeout-report.sh` and
`bubbles/scripts/session-closeout-report-selftest.sh` (SCOPE-2/3/5,
`bubbles.devops` + `bubbles.test`) · `bubbles/scripts/worktree-hygiene-report.sh`
only if a missing machine field cannot be consumed without changing its current
contract (`bubbles.devops`) · `skills/bubbles-result-envelope/SKILL.md` and
`agents/bubbles_shared/evidence-rules.md` (SCOPE-4, `bubbles.docs`) ·
`bubbles/scripts/audit-result-contract-lint.sh` and selftest (SCOPE-4,
`bubbles.test`) · `bubbles/scripts/cli.sh` and `framework-validate.sh`
(SCOPE-5 wiring, `bubbles.devops`).

## Provenance

- `git cat-file -e origin/main:improvements/IMP-033-session-closeout-and-open-work-durability.md` failed because the committed index target does not exist.
- `git log --all --reflog -S 'Session closeout and open-work durability'` found only commit `fce781b` modifying `improvements/INDEX.md`; no proposal artifact exists in reachable or reflog history.
- Source inspection of `framework-health-evidence-lint.sh` verified file-to-row checking without row-to-file checking.
- Source inspection of `worktree-hygiene-report.sh` verified that the main worktree is skipped and branches/stashes are report-only.
- The reconciliation diff leading to `48a8cdb` verified that BUG-004, BUG-005, BUG-006, and IMP-032 accounting could be removed alongside an otherwise intentional rollback.