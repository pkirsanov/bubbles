# Bug: BUG-042 Same-Revision Receipt Supersession

## Summary

`scenario-state-resolve.sh` lets historical invalid receipts block a later
coherent proof chain at the same source revision.

## Severity

- [ ] Critical - System unusable or data loss.
- [x] High - Certification is blocked with no append-only repair path.
- [ ] Medium - Feature broken with a safe workaround.
- [ ] Low - Minor issue.

## Status

- [ ] Reported.
- [x] Confirmed (reproduced).
- [ ] In Progress.
- [ ] Fixed.
- [ ] Verified.
- [ ] Closed.

## Reproduction Steps

1. Create one scenario with a failing RED receipt and an IMPLEMENT receipt.
2. Append an invalid same-revision GREEN receipt with a substituted test or control.
3. Append a later valid GREEN receipt that matches the RED discriminator.
4. Run `bubbles/scripts/scenario-state-resolve.sh --certifiable` on the fixture.
5. Observe whether the historical invalid row remains a blocking refusal.

The same pattern applies when an exit-zero RED precedes a later failing RED and
coherent GREEN chain.

## Expected Behavior

The resolver preserves every receipt and selects the latest coherent chain by
deterministic append order. Earlier invalid rows become superseded diagnostics.
They do not block the selected chain. A later unresolved invalid row still
blocks and cannot erase the previously valid chain silently.

## Actual Behavior

Source inspection shows that the resolver sorts by `ts`, visits receipts from
oldest to newest, and appends refusal records while scanning. A later coherent
receipt can add the expected derived state, but it cannot remove the earlier
blocking refusal.

The operator supplied a downstream Research Lab BUG-022 observation with exit
1 and 34 blockers. The reported split is 28 `SCS-TEST-SUBSTITUTED`, 5
`SCS-CONTROL-SUBSTITUTED`, and 1 `SCS-RED-NOT-FAILING`. This observation is
diagnostic input only. It is not this packet's execution evidence.

## Environment

- Service: Bubbles scenario state resolver
- Version: current bound worktree for scenario node `bubbles-file-scenario-receipt-supersession-bug`
- Platform: macOS
- Repository: `bubbles-scenario-receipt-supersession`

## Error Output

The current-session historical-row fixture derives `GREEN_TARGETED` and still
emits `SCS-TEST-SUBSTITUTED`. It reports `certifiable: no` and exits 1. The
control log differs by one omitted historical row. It reports `certifiable:
yes` and exits 0. The raw output is in `report.md` at `E-B042-REPRO`.

## Root Cause

The resolver computes refusals as irreversible side effects of an oldest-first
scan. It does not first select an authoritative same-revision chain. As a
result, a historical invalid row retains veto power after a later valid chain
supersedes it.

## Related

- Related framework bug: `BUG-034`
- Downstream reproduction source: Research Lab `BUG-022`
- Production owner: `bubbles/scripts/scenario-state-resolve.sh`
- Planned persistent test owner: `bubbles/scripts/scenario-state-resolve-selftest.sh`

## Disposition

This packet owns the same-revision replacement defect. `BUG-034` remains
narrower. It made only `SCS-REVISION-DRIFT` nonblocking after stale receipts
were excluded. It deliberately left the three refusal codes in this packet
blocking.

No source fix is part of this discovery and bootstrap slice.