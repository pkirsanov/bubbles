# Bug: BUG-048 Test Plan Owner Label Path Misclassification

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `F-B001-HARDEN-011`
- **Requested identifier:** BUG-047
- **Assigned identifier:** BUG-048 after the collision-safe shift caused by existing BUG-046
- **Affects:** `bubbles/scripts/state-transition-guard.sh` and `bubbles/scripts/state-transition-guard-selftest.sh`

## Summary

Check 8 scans every Markdown table row and treats a backticked owner label ending
in `.test` as a test file. A Finding Accounting row naming `bubbles.test` can
therefore block a valid transition as a nonexistent basename-only test path.

## Packet Route

The fix changes a shared transition verdict and Markdown extraction contract.
It therefore uses a full source bug packet.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - valid transition is blocked by unrelated metadata
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

1. Create a valid scope with a concrete Test Plan file path.
2. Add a separate Finding Accounting table.
3. Put five backticked `bubbles.test` owner labels in that table.
4. Run the state transition guard.
5. Observe Check 8 treat each owner label as a basename-only `.test` file.
6. Observe nonexistent-path failures unrelated to the Test Plan.

## Expected Behavior

Check 8 extracts paths only from actual Test Plan path or file-location cells.
A legitimate basename-only file such as `smoke.test` remains supported. Owner
labels outside the Test Plan never become paths.

## Actual Behavior

Check 8 filters only for generic table shape. It examines every backtick block
on every qualifying row. `_check8_candidate_has_supported_suffix()` accepts a
bare `.test` suffix, so `bubbles.test` is classified as a file candidate.

## Root Cause

The extractor validates token syntax but not table semantics. It has no state
for the current section, no header-derived path-column index, and no boundary at
the end of the Test Plan table.

The existing invalid-context fixture covers prose and unsupported wrappers only
inside a Test Plan. It does not place valid file-shaped metadata in a different
table.

## Impact

- Valid Finding Accounting tables can block certification.
- The false failure points authors toward nonexistent test files.
- Removing basename-only `.test` support would break legitimate repositories.
- Broad table scans can misclassify other file-shaped metadata later.

## Environment

- Repository: canonical Bubbles source worktree
- Revision: `830883fd5639ac066cb3d40a2a40a567cc3df22f`
- Platform: macOS
- Discovery source: downstream Ozhiva transition packet

## Scope Boundary

### Included

- Test Plan section and table boundary recognition
- Header-derived file/path cell extraction
- Legitimate basename-only `.test` compatibility
- Finding Accounting owner-label adversary
- Required generated release manifest update after implementation

### Excluded

- Removing `.test` from supported file suffixes
- Changing Finding Accounting schema
- Rewriting Markdown parsers outside Check 8
- Editing downstream artifacts
- Running RED or GREEN tests during filing

## Related

- `bubbles/scripts/state-transition-guard.sh` lines 2832-3014 own Check 8.
- `bubbles/scripts/state-transition-guard-selftest.sh` lines 2845-3099 cover current path extraction.

## Filing Evidence

**Claim Source:** interpreted

The cited source regions were read in this invocation. The five-label downstream
observation is operator-provided diagnostic input. No test execution is claimed.
