# IMP-049 — Proportionate Self-Validation and Truthful Ceilings

**Status:** PROPOSED

## Provenance

Evidence gathered 2026-08-18 against worktree HEAD `fc2e7ca` by direct measurement, not estimation:

- A **completed** `framework-validate` run from this session: `Wall clock: 3743s across 338 executed check(s).` Per-check timings from the same run's summary block.
- `bubbles/scripts/framework-validate.sh`, `release-check.sh`, `v5.3-selftest.sh`, `verify-payload-integrity.sh` read at the cited lines.
- `bubbles/workflows/modes.yaml` re-derived independently of the claim already recorded in `BUGS.md` BUG-017.
- `docs/generated/gate-coverage-map.md` and the `gateEnforcement.derived:` block in `bubbles/registry/gates.yaml`.
- `BUGS.md` dispositions read literally.

Landing commits for the prior improvement in this lineage: IMP-048 (`ccb7a92`, `bd9a692`, `0461dd3`, `87a8801`, `e430d00`, `74a1ce5`, `1f440dc`).

## Problem (verified against source)

The framework spends most of its validation budget re-proving things it has already proven, and advertises terminal states it cannot reach. Both are measured below. Neither is a quality problem — the checks themselves are dense and load-bearing — so the fix is to stop paying twice, not to check less.

**P1 — The framework validates itself three to four times per gate.**
`release-check.sh:119` runs the complete `framework-validate.sh`. Inside that suite, `v5.3-selftest.sh:150-153` installs a downstream tree and runs a **complete** `framework-validate.sh` again inside it. Measured cost of that one nested check: **1341s, 36% of the entire 3743s run**. The next check, `Transition guard selftest`, is 543s; the top two together are ~50% of the run.

The nested run's value is proving the framework behaves correctly under the downstream path layout (`.github/bubbles/scripts/` rather than `bubbles/scripts/`). But the payload it runs is *already* proven byte-identical: `verify-payload-integrity.sh:4-7` verifies every installed file against the `managedFileChecksums` recorded at release time, and `install.sh` calls it immediately after the copy. Classifying the 268 selftests by whether they can even observe the layout:

| Class | Count | Meaning |
|---|---|---|
| references `ROOT_DIR` / `REPO_ROOT` / `$SCRIPT_DIR/../` | 109 (41%) | genuinely path-sensitive |
| references none of those | **159 (59%)** | script-dir-local: same bytes, same fixtures, same verdict |

Re-running the 159 downstream proves nothing the checksum did not already prove. Proportional share of the redundant work: **~790s, ~21% of every full run**.

**P2 — Certification cost is what keeps landed fixes open.**
`BUGS.md:2140-2144` (BUG-032) records four guard repairs that are *implemented and landed on main* in `0531189`, still not closed, for one reason: "it is not validate-certified, and its Scope 4 obligations still require full framework-validate and release-check evidence that no session has captured against the current tree." Closing a finished fix costs ~2 CPU-hours. CI pays it twice per push — `.github/workflows/agnosticity.yml:39` and `:97` both run `release-check` on separate runners.

**P3 — Introspection blocks on the execution lock.**
`framework-validate.sh:52-67` acquires the machine-wide `flock` and exits 1 on contention. Argument parsing happens later, at `:303`; `--help` exits at `:313-323` and `--list-tier` executes no check at all. Observed twice this session: `--list-tier=full` returned the lock error, exit 1, zero checks listed, while another run held the lock. A pure read-only question cannot be asked while the machine is busy — including by the review that produced this proposal.

**P4 — 29 of 61 workflow modes advertise a terminal state with no path to it.**
Re-derived from `bubbles/workflows/modes.yaml` without reading BUG-017's method, and matching its count exactly: 55 modes declare a `statusCeiling`; 32 declare a ceiling below `done`; **29 of those declare no `transitionAudit`**, so the transition contract has no route to the state the registry advertises. `BUGS.md:1483-1486` classifies this severity high and names the precedent: "the same defect class as G087 before `81cac4e`: a terminal state the registry advertises with no truthful path to it."

**P5 — The gate→enforcer binding is hand-maintained prose.**
`docs/generated/gate-coverage-map.md` reports 118 gates, 81 declared mechanically enforced. The `gateEnforcement.derived:` reconciliation in `gates.yaml` (from line 1058) reports **70 of 118 `divergent`** and 1 `contradiction`. Most divergence is benign granularity, but 11 gates declare a `script:` enforcer the derived scan never observes. Spot-checking whether the named script mentions its own gate id at all:

```
G079 in test-impact-plan.sh            -> 0 occurrences
G133 in collected-test-count-guard.sh  -> 0 occurrences
G080 in trace-contract-guard.sh        -> 0 occurrences
G078 in batch-promotion-lint.sh        -> 0 occurrences
G110 in release-train-guard.sh         -> 0 occurrences
G067 in guards/planning-checks.sh      -> 1 occurrence
```

The scripts exist and implement the behaviour; what is absent is any mechanical link proving the declared enforcer is the real one.

**P6 — Blocking checks assert documentation wording.**
~122 literal-prose assertions across the selftest suite, concentrated in `workflow-delegation-selftest.sh` (37 in 156 lines), `continuation-routing-selftest.sh` (32), `workflow-surface-selftest.sh` (18), `super-surface-selftest.sh` (17). 20 selftests read live `agents/ docs/ prompts/ skills/ instructions/` paths instead of fixtures. The extreme case, `workflow-surface-selftest.sh:64`, asserts generated HTML markup: `'wf-name">full-delivery<'`. Rewording a sentence breaks a blocking gate, which taxes exactly the documentation edits the framework most wants to encourage.

### What was investigated and is NOT a problem

Recorded because a proposal that only lists confirmations is not a review:

- **Agent prose duplication is 2.4%**, not the sprawl the 1.63 MB total suggests. Verbatim blocks ≥400 B in ≥3 agent files: 5 blocks, 21,477 B. The two largest are *pointers to* shared modules, not copied content — the extraction already happened. `instruction-budget-lint.sh agents` exits 0.
- **Zero orphaned scripts.** Every one of 250 non-selftest scripts is referenced elsewhere in the repo.
- **All 61 workflow modes are reachable by code.** Mode count is not dead weight; P4 is the real defect.
- **The selftests are dense, not padded.** No "script exists" or "has a usage block" tests exist; 244 of 268 build `mktemp` fixtures. 268 selftests over 251 scripts is fan-in (25 → `guard-lib.sh`, 25 → `cli.sh`), not one-test-per-script sprawl.
- **Tiering already protects the daily loop.** `pre-push.sh:69-78` runs `--tier=core` (16 checks / 260s). The 3743s is confined to certification and CI.
- **A real fast lane already exists and is the DEFAULT.** `bubbles/registry/bug-packet.yaml:30-114` admits a 3-artifact compact packet, and in the framework source repo a one-line fix is a single `BUGS.md` entry. `micro-fix-packet.yaml:12-17` records that it became the default in IMP-047 S-D, retiring a measurement precondition no producer could satisfy — "A precondition the system cannot produce is a permanent veto dressed as rigour."
- **The two implementation-free adapter families (`mutation`, `test-inventory`) are NOT dead weight** and are deliberately excluded from this proposal. `mutation-receipt.sh` is consumed by the mutation-execution-receipt contract delivered in IMP-048 SCOPE-4; retiring the family would remove a mechanism that shipped eight days ago.

## Proposal

### SCOPE-1 — WITHDRAWN: prove downstream only what only downstream can prove (VAL-1)

**Withdrawn 2026-08-18 after implementation, on measurement. The problem statement P1 was wrong in two independent ways, and both were found by building the thing and testing it.**

**The classification rule was unsafe.** "References `ROOT_DIR` / `REPO_ROOT` / `$SCRIPT_DIR/../`" describes the selftest's own text, but layout dependence usually lives in the SUBJECT the selftest drives. `bubbles/scripts/v7-selftest.sh` contains zero root identifiers and would have been skipped; it invokes `mode-resolver.sh`, which resolves the repository root itself and reads `bubbles/workflows.yaml`. Run against a byte-identical copy of the script directory with no repository around it, it exits 1 with 5 failures. The rule would have silenced exactly the regression the nested downstream run exists to catch. A correct classifier must close transitively over invoked siblings, which drops the provably-local set from 52 to **8**.

**The saving was not there anyway.** The ~790s figure assumed cost is proportional to count. It is not, and the correlation runs the wrong way: a selftest that cannot observe the layout is one that builds a `mktemp` fixture and hands its subject an explicit root — and those are the cheap ones. Measured at millisecond resolution, the 8 provably-local selftests cost **2.376s**, 0.06% of a 3743s run. Even the unsafe 52-file ceiling is 58.3s, 1.6%.

The 1341s is real, but it is not in the checks a correct rule can remove. Attacking it requires measuring where that time actually goes inside the nested run — the path-sensitive selftests and the live guards — which this proposal did not do. Recorded as an open question rather than a plan.

A conservative classifier and an integrity-gated selection mechanism were built and proven (10/10 fixtures, 5/5 integrity cases, including two false negatives its own fixtures caught on the first pass). Neither is retained: unwired machinery is exactly the weight this proposal argues against.

### SCOPE-2 — Consume a validation that already happened (VAL-2)

`framework-validate` records a run receipt: the tier, the verdict, and a digest over every managed file it validated. `release-check` consumes a PASSING receipt whose digest matches the current tree instead of re-running the suite.

Fail-closed by construction: absent receipt, mismatched digest, non-passing verdict, or a tier lower than required all cause `release-check` to run the validation itself. The receipt records what was validated, so it can never certify a tree it did not see.

### SCOPE-3 — Introspection never takes the lock (VAL-3)

Parse arguments before acquiring the lock. `--help`, `--version`, and `--list-tier` answer while another run is in flight, because they execute no check and mutate no shared scratch fixture. The lock still guards every path that actually runs checks.

### SCOPE-4 — A ceiling below `done` must declare how it is reached (TRUTH-1)

Make the rule mechanical: a mode whose `statusCeiling` is below `done` MUST declare a `transitionAudit` route, and a lint fails when it does not. Then discharge the existing 29 — each either gains the audit route it always implied, or stops advertising a ceiling it cannot reach. Closes BUG-017.

### SCOPE-5 — A declared enforcer must actually enforce (TRUTH-2)

Fail when a gate declares a `script:` enforcer that does not reference that gate id. This turns the `gateEnforcement.derived:` reconciliation from a report into a contract for the strict case, without touching the benign granularity divergences that make up most of the 70.

### SCOPE-6 — Blocking checks assert behaviour, not wording (COST-1)

Move literal-prose assertions out of blocking selftests into a documentation-consistency lint that reports without blocking. Blocking selftests assert structure and behaviour against fixtures. The HTML-markup assertion in `workflow-surface-selftest.sh:64` is the clearest case: a generated presentation detail must never gate a framework release.

## Migration / rollout

Every scope is additive and default-safe. SCOPE-1 and SCOPE-2 change only *when* work is skipped, and both fail toward doing the work. SCOPE-3 is a pure reordering. SCOPE-4 and SCOPE-5 add lints that must be discharged in the same change that introduces them, so the tree is never left failing. SCOPE-6 reclassifies checks without deleting the assertions.

## Risks & mitigations

- **R1 — A skipped downstream selftest hides a real layout defect.** Mitigation: the classifier is conservative (unclassifiable ⇒ run), the skip requires a passing integrity verification, and the selection is printed. Proven by mutation: forcing a path-sensitive selftest into the skip set must turn a test red.
- **R2 — A stale receipt certifies a tree it never saw.** Mitigation: the digest covers every managed file; any mismatch runs the full validation. Proven by mutation: altering one managed byte after the receipt must force a re-run.
- **R3 — Moving the lock introduces a race.** Mitigation: only non-executing paths answer before the lock; every check-executing path still acquires it first.
- **R4 — Discharging 29 ceilings degrades into raising them all to `done`.** Mitigation: raising a ceiling is only admissible where the mode genuinely reaches `done`; otherwise the audit route is declared. The lint cannot distinguish these, so the change records the reason per mode.
- **R5 — Reclassifying prose assertions loses real coverage.** Mitigation: assertions move, they are not deleted; the docs lint still runs and still reports.
- **R6 — The measured savings do not materialise.** Mitigation: the acceptance criteria require a re-measured wall clock, not a predicted one.

## Acceptance criteria (when implemented)

1. ~~A full `framework-validate` reports a wall clock materially below the 3743s baseline.~~ **Void — SCOPE-1 withdrawn.** The measurement that would have satisfied this instead disproved it: the removable share is 2.376s, not ~790s. No wall-clock reduction to `framework-validate` is claimed.
2. ~~The downstream selection is printed and auditable; a mutation that mis-classifies a path-sensitive selftest fails a test.~~ **Void — SCOPE-1 withdrawn.** The mutation was performed and is what withdrew the scope: `v7-selftest.sh`, which the proposed rule classified as skippable, fails with 5 errors under a bare tree.
3. `release-check` on an unchanged tree consumes the receipt and does not re-run the suite; a one-byte change forces a re-run.
4. `--list-tier` and `--help` answer with exit 0 while another run holds the lock.
5. No mode declares a below-`done` ceiling without a `transitionAudit` route; BUG-017 closes with evidence.
6. No gate declares a `script:` enforcer that never names it.
7. No blocking selftest asserts generated HTML or agent prose wording.
8. `shellcheck-lint.sh`, `regen-derived.sh --check-only`, `management-truth-lint.sh` and `framework-health-evidence-lint.sh` all exit 0.

## Files to touch (on approval)

- `bubbles/scripts/v5.3-selftest.sh`, plus a new downstream-selection classifier and its selftest
- `bubbles/scripts/framework-validate.sh` (lock ordering, run receipt)
- `bubbles/scripts/release-check.sh` (receipt consumption)
- `bubbles/workflows/modes.yaml` and the mode-ceiling lint
- `bubbles/registry/gates.yaml` reconciliation and its enforcing lint
- `bubbles/scripts/workflow-surface-selftest.sh` and the other prose-bound selftests
