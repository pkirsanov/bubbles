# Bug: BUG-050 Transition-Local Receipt Admission

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `F-B001-HARDEN-013`
- **Requested identifier:** BUG-049
- **Assigned identifier:** BUG-050 after the collision-safe shift caused by existing BUG-046
- **Affects:** receipt freshness, clone detection, scenario evidence admission, and mutation proof

## Summary

Check 43 adjudicates the complete repository tool log instead of the evidence
set admitted for the current transition. Unrelated stale receipts and unrelated
clone groups can therefore block a transition whose active evidence is fresh.

## Packet Route

This fix changes a shared evidence-admission contract and must preserve several
anti-fabrication protections. It therefore uses a full source bug packet.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - valid certification is blocked by unrelated immutable history
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Root cause grounded by current-session source inspection
- [ ] Executable RED regressions captured
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Create a repository tool log with fresh receipts admitted by the active packet.
2. Add older stale receipts for unrelated specs or scopes.
3. Add a substantive clone group for unrelated command identities.
4. Run the active packet's state transition guard.
5. Observe Check 43 pass the full log to `evidence-receipt-check.sh --strict`.
6. Observe clone detection also group the full log.
7. Observe unrelated history block the active transition.

## Expected Behavior

Check 43 evaluates the active evidence set admitted for the transition. A stale
or incompatible receipt inside that set blocks. Unrelated immutable history
does not vote on the transition.

A RED receipt remains valid historical proof after implementation changes.
A killed-mutant receipt remains valid proof of sensitivity when its source was
restored. Neither receipt requires its source hash to equal current production
bytes.

No implementation may delete the tool log, add a bypass, or weaken BUG-033
command identity protections.

## Actual Behavior

`evidence-receipt-check.sh` supersedes by evidence identity but evaluates every
current identity in the complete log. Check 43 invokes it without a transition
admission filter. The inline clone analysis also reads the complete log.

The scenario resolver filters by scenario and source revision during state
derivation, but Check 43 does not consume that admitted set. Mutation receipts
use a separate store and validate restoration against the original source
digest, not current source equality.

## Root Cause

Receipt validity and transition admission are conflated. Freshness answers
whether one receipt still describes its declared inputs. Admission answers
whether that receipt supports this transition. Check 43 performs freshness and
clone analysis before establishing the second fact.

This repository-global posture predates schema-v3 scenario bindings and the
current semantic Check 9 admission path. Those newer surfaces can identify the
active scenario, phase, claim, command, and revision, but Check 43 still consumes
all append-only history.

## Impact

- Unrelated work can permanently block an active transition.
- Honest append-only history becomes a liability.
- Operators are pressured to delete evidence to clear the gate.
- RED and mutation evidence can be incorrectly treated like current GREEN proof.
- An over-broad fix could reopen clone-reuse protections from BUG-033.

## Environment

- Repository: canonical Bubbles source worktree
- Revision: `830883fd5639ac066cb3d40a2a40a567cc3df22f`
- Platform: macOS
- Discovery source: downstream Ozhiva transition packet
- Downstream diagnostic: active receipts 319-329 were reported fresh with no active clone group, while unrelated history still blocked

## Scope Boundary

### Included

- Transition-specific admitted tool-log view
- Freshness checks over that admitted view
- Clone checks over that admitted view
- Active stale and active incompatible-clone adversaries
- Historical RED receipt semantics
- Historical mutation receipt semantics
- BUG-033 identity protection regressions
- Required generated release manifest update after implementation

### Excluded

- Tool-log deletion, compaction, or rewriting
- Bypass or ignore flags
- Treating stdout equality alone as proof of cloning
- Weakening source revision for GREEN, live, regression, or observed proof
- Editing downstream receipt logs
- Running RED or GREEN tests during filing

## Related

- `bubbles/scripts/evidence-receipt-check.sh` lines 130-237 evaluate the full current log view.
- `bubbles/scripts/state-transition-guard.sh` lines 3028-3191 define semantic Check 9 admission.
- `bubbles/scripts/state-transition-guard.sh` lines 4489-4745 run Check 43 over the complete log.
- `bubbles/scripts/scenario-state-resolve.sh` binds scenario receipts and derives RED through regression states.
- `bubbles/scripts/mutation-receipt.sh` lines 490-680 validate historical killed-mutant proof.
- `bubbles/scripts/receipt-identity-selftest.sh` pins BUG-007, BUG-028, BUG-032, and BUG-033 protections.

## Filing Evidence

**Claim Source:** interpreted

The current source paths and receipt semantics were inspected in this invocation.
The downstream receipt counts are operator-provided diagnostic input. No new
reproduction execution is represented as current-session evidence.
