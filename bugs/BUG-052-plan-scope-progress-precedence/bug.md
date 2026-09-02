# Bug: BUG-052 Plan Scope Progress Precedence

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `FP-PLAN-SP-PRECEDENCE`
- **Affects:** `bubbles/scripts/plan-dependency-depth-guard.sh` and `bubbles/scripts/plan-dependency-depth-guard-selftest.sh`

## Summary

The plan dependency-depth guard resolves deprecated top-level `scopeProgress`
before canonical `certification.scopeProgress`. A top-level empty array therefore
shadows a valid canonical dependency graph and makes the guard no-op.

## Packet Route

The fix changes a planning guard verdict and protects strict version 3 state
authority. It uses a full source bug packet and routes through
`bugfix-fastlane`.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - a disallowed horizontal plan can silently avoid enforcement
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Root-cause hypothesis grounded by current-session source inspection
- [ ] Executable RED regression captured
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Create a plan dependency-depth fixture under block posture.
2. Set top-level `scopeProgress` to `[]`.
3. Put a valid over-depth per-scope array under `certification.scopeProgress`.
4. Create every referenced `scopeDir/scope.md` body.
5. Run `plan-dependency-depth-guard.sh` against the fixture.
6. Observe the current no-op instead of the expected block.

These are pre-production RED steps. This filing invocation did not execute
them.

## Expected Behavior

Strict version 3 state reads `certification.scopeProgress` as canonical. The
deprecated top-level field is a compatibility fallback only when the canonical
field is absent. `execution.scopeProgress` does not become an authority source.

## Actual Behavior

The guard evaluates `(.scopeProgress // .certification.scopeProgress // [])`.
In jq, an empty array is present for `//`. The top-level `[]` wins, and the
guard exits through its no-scopeProgress path.

## Root Cause Hypothesis

The read precedence predates strict version 3 authority and still labels the
top-level field canonical. The compatibility field is selected before the
certification-owned field.

The shadow-fixture RED test can disconfirm this hypothesis. It must show that
the current guard already blocks using the nested canonical graph.

## Impact

- A valid canonical dependency graph can be ignored.
- Horizontal plans can pass under block posture.
- The output reports missing scope progress when canonical data exists.
- Adding `execution.scopeProgress` to the selection chain would create another authority conflict.

## Environment

- Repository: canonical Bubbles source worktree
- Revision: `830883fd5639ac066cb3d40a2a40a567cc3df22f`
- Platform: macOS
- Discovery source: downstream Ozhiva transition review

## Scope Boundary

### Included

- Canonical `certification.scopeProgress` precedence
- Deprecated top-level compatibility fallback
- Empty top-level shadow regression
- Canonical-versus-legacy adversarial precedence
- Explicit non-authority for `execution.scopeProgress`
- Required generated release manifest update after implementation

### Excluded

- New state fields
- Promotion of `execution.scopeProgress` to authority
- State schema redesign
- Dependency-depth algorithm changes
- Production or selftest edits during filing
- Downstream product artifact edits

## Related

- `bubbles/scripts/plan-dependency-depth-guard.sh` selects top-level scope progress first.
- `bubbles/scripts/plan-dependency-depth-guard-selftest.sh` covers each shape separately but not simultaneous conflicting fields.

## Filing Evidence

**Claim Source:** interpreted

The jq precedence expression and current selftest fixtures were read in this
invocation. The downstream finding is operator-provided diagnostic input. No
RED execution result is claimed.