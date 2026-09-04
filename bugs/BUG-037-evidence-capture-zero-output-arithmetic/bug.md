# Bug: BUG-037 Evidence Capture Zero-Output Arithmetic

- **Filed:** 2026-09-02
- **Severity:** high
- **Disposition:** open framework defect
- **Affects:** `bubbles/scripts/evidence-capture.sh` line-count metadata and arithmetic formatting

## Summary

A zero-line command capture can emit an arithmetic diagnostic while the child and helper still return success. The evidence block is therefore noisy and can misstate the reliability of its metadata path.

## Packet Route

The fix changes a shared evidence helper used by every downstream repository. It changes observable output and has cross-repository effect. This bug therefore uses a full root packet.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - evidence formatting can emit a diagnostic without failing closed
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Controlling source expression identified
- [ ] Exact diagnostic durably reproduced
- [ ] Regression tests added
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Run `evidence-capture.sh` around a successful child that emits zero bytes.
2. Run it around a failing child that emits zero bytes.
3. Capture combined helper output and the helper exit code.
4. Inspect the `lines`, `sha256`, and `exit` metadata.
5. Repeat through `--verify` with the empty-output digest.

## Expected Behavior

A zero-line capture emits `lines: 0`, the SHA-256 of the empty byte stream, and the real child exit code. It emits no arithmetic diagnostic. A failing child still produces valid evidence and the helper follows the child exit contract. Verify mode follows its existing match or mismatch contract.

## Actual Behavior

The operator observed an arithmetic diagnostic during a zero-line capture even though the child and helper returned zero. The exact diagnostic text was not preserved in a durable current-session artifact.

The source computes `total` with a command substitution whose success and fallback branches both print a digit for an empty file. `grep -c ''` prints `0` and exits nonzero. The fallback then prints another `0`, producing the non-canonical scalar `00`. Later conditions consume that scalar as arithmetic input.

## Root Cause

The line-count expression conflates data output with command success:

```text
total="$(grep -c '' <"$tmp" 2>/dev/null || printf '0')"
```

For an empty file, `grep` writes its valid count before returning its no-match status. The fallback appends another sentinel instead of replacing the first result. This creates `00`, then passes it into arithmetic comparisons. The exact shell diagnostic path remains unverified until the focused reproduction captures it.

## Impact

- A valid evidence block can contain a shell arithmetic diagnostic.
- Success can mask a metadata-path defect because the helper still follows the child exit code.
- Zero-output failing commands may produce the same formatting defect.
- Downstream reports can preserve misleading noise in evidence of record.

## Environment

- Repository: Bubbles source repository
- Platform: Linux under VS Code
- Discovery date: 2026-09-02

## Scope Boundary

### Included

- Canonical zero-line count generation
- Empty-stream SHA-256 metadata
- Successful and failing zero-output children
- Existing child and verify exit contracts
- Non-empty behavior preservation
- Focused selftest and release-manifest regeneration

### Excluded

- Timeout wrapper normalization
- Changes to bounded retention policy
- Changes to evidence receipt schema
- Broad helper refactoring

## Related

- `bugs/BUG-035-validation-control-plane-churn-and-scope-overreach/` D14 covers capture-file disappearance, not zero-output arithmetic.
- BUG-007 covers empty stdout in receipt-clone classification, not evidence-block formatting.

## Deferred Reason

This invocation owns documentation and root-cause routing only. Implementation belongs to `bubbles.implement`. Exact red-stage output remains unclaimed until a focused current-session reproduction runs.
