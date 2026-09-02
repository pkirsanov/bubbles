# Bug: BUG-047 Reasoned Skip Phase Accounting

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `F-B001-HARDEN-010`
- **Requested identifier:** BUG-046
- **Assigned identifier:** BUG-047 because BUG-046 exists on local branch `fix/bug045-framework-tier-lock-leak`
- **Affects:** `bubbles/workflows/modes.yaml`, `bubbles/scripts/state-transition-guard.sh`, and `bubbles/scripts/state-transition-guard-selftest.sh`

## Summary

A canonical reasoned skip cannot satisfy the current transition guard. Check 6
ignores skipped `executionHistory` records, while Check 7A rejects their
intentional zero-duration decision spans.

## Packet Route

The fix changes a shared transition verdict in every downstream installation.
It therefore uses the full source bug packet. The top-level ledger entry remains
the source repository's convention-required index and disposition record.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - a valid workflow decision cannot reach certification
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Root cause grounded by current-session source inspection
- [ ] Executable RED regression captured
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Use a done-ceiling mode whose required phase may be skipped by `phaseRelevance`.
2. Record the decision only in `executionHistory` with `outcome: skipped` and a reason.
3. Give that decision equal start and completion instants.
4. Keep the skipped phase out of `completedPhaseClaims`, as the mode registry requires.
5. Run the state transition guard.
6. Observe Check 6 report the required phase missing.
7. Observe Check 7A report the skip decision as a nontrivial zero-duration run.

## Expected Behavior

A validated reasoned skip satisfies required-phase accounting without becoming
a completed phase claim. An authorized skip decision may have zero duration.
A nontrivial executed phase with an undeclared zero-duration span must still
fail.

## Actual Behavior

Check 6 merges certification, completion claims, legacy phases, and phase stubs.
It never reads canonical skipped history. Check 7A classifies zero duration by
phase name alone and exempts only `finalize` and `select`.

## Root Cause

The mode registry defines reasoned skips as decision records, but the guard has
no shared skip classifier. Required-phase accounting and timestamp plausibility
therefore interpret the same record as absence and fabricated execution.

The existing tests cover completion-claim source merging and zero-duration
execution. They do not compose those checks around one canonical skip record.

## Impact

- Valid phase relevance decisions can make terminal transition unreachable.
- Authors may be pressured to forge a completion claim for work that did not run.
- Authors may add an unmeasured-duration escape to a measured skip decision.
- Genuine zero-duration execution must remain detectable after the fix.

## Environment

- Repository: canonical Bubbles source worktree
- Revision: `830883fd5639ac066cb3d40a2a40a567cc3df22f`
- Platform: macOS
- Discovery source: downstream Ozhiva installed transition guard

## Scope Boundary

### Included

- Canonical skip validation and required-phase accounting
- Zero-duration classification for authorized decision records
- Re-evaluation metadata validation
- Positive and adversarial transition-guard regressions
- Required generated release manifest update after implementation

### Excluded

- Changing which phases may skip
- Adding skip flags or bypasses
- Treating a skipped phase as completed execution
- Editing downstream installations
- Running RED or GREEN tests in this filing invocation

## Related

- `bubbles/workflows/modes.yaml` lines 15-33 define the skip record contract.
- `bubbles/scripts/state-transition-guard.sh` lines 1642-1848 implement Check 6.
- `bubbles/scripts/state-transition-guard.sh` lines 2332-2608 implement Check 7A.
- `bubbles/scripts/phase-relevance-resolve.sh` supplies the canonical skip verdict and reason.

## Filing Evidence

**Claim Source:** interpreted

The cited source regions were read from the clean isolated worktree. The
downstream failure facts are operator-provided diagnostic input. No
reproduction command or test ran during this filing invocation.
