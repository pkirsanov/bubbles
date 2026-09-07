# Bug: BUG-049 G040 Separate Process Prefix False Match

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `F-B001-HARDEN-012`
- **Requested identifier:** BUG-048
- **Assigned identifier:** BUG-049 after the collision-safe shift caused by existing BUG-046
- **Affects:** `bubbles/scripts/state-transition-guard.sh` and `bubbles/scripts/state-transition-guard-selftest.sh`

## Summary

Gate G040 uses the unbounded case-insensitive alternative `separate PR`. It
matches the prefix of the legitimate phrase `separate process` and falsely
classifies completed-work prose as deferral.

## Packet Route

The fix changes a shared completion guard verdict. It therefore uses a full
source bug packet.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - valid delivery can be blocked as incomplete work
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

1. Create an otherwise valid delivery packet.
2. Put the sentence `The verifier runs in a separate process.` outside a code fence.
3. Run the state transition guard.
4. Observe Check 18 report a deferral-language hit.
5. Replace the phrase with an unrelated sentence and observe the false hit disappear.

## Expected Behavior

G040 matches a complete `PR` token or the complete phrase `pull request`.
`Separate process` remains ordinary technical prose. Genuine wording that moves
work to a separate PR or pull request remains blocking.

## Actual Behavior

The case-insensitive ERE alternative `separate PR` has no trailing boundary.
`PR` therefore matches the first two letters of `process`.

## Root Cause

The deferral vocabulary mixes complete phrases with an abbreviation that needs
a token boundary. The current G040 fixtures cover broad deferral phrases and
placeholder narrowing. They do not pair a prefix-collision negative with its
real deferral positive.

## Impact

- Valid scope and report prose can block terminal transition.
- The diagnostic falsely alleges deferred work.
- Authors may distort precise technical prose to satisfy a regex accident.
- A careless narrowing could disable genuine separate-PR deferral detection.

## Environment

- Repository: canonical Bubbles source worktree
- Revision: `830883fd5639ac066cb3d40a2a40a567cc3df22f`
- Platform: macOS
- Discovery source: downstream Ozhiva transition packet

## Scope Boundary

### Included

- Complete-token matching for `PR`
- Complete-phrase matching for `pull request`
- Negative `separate process` fixtures
- Positive `separate PR` and `separate pull request` fixtures
- Required generated release manifest update after implementation

### Excluded

- Broad redesign of every G040 term
- Changing planning-maturity applicability
- Adding new deferral vocabulary
- Editing downstream artifacts
- Running RED or GREEN tests during filing

## Related

- `bubbles/scripts/state-transition-guard.sh` line 4131 defines the G040 pattern.
- `bubbles/scripts/state-transition-guard-selftest.sh` lines 2429-2492 build current G040 fixtures.
- `bubbles/scripts/state-transition-guard-selftest.sh` lines 3824-3920 assert current G040 behavior.

## Filing Evidence

**Claim Source:** interpreted

The exact unbounded pattern and current fixture coverage were read in this
invocation. The downstream false block is operator-provided diagnostic input.
No execution result is claimed.
