# Bug: BUG-038 Train Metadata Assignment Mode Gap

- **Filed:** 2026-09-02
- **Severity:** high
- **Disposition:** open framework defect
- **Affects:** release-train workflow authorization and spec state metadata

## Summary

`bubbles.train` owns `releaseTrain` and `flagsIntroduced` in spec state. The workflow grant registry gives that agent no mode for assigning those fields. A grounded classification therefore cannot become authorized state metadata.

## Packet Route

The fix changes shared workflow authorization, train behavior, and downstream state mutation. It also needs adversarial authorization tests. This bug therefore uses a full root packet.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - the sole metadata owner cannot perform an owned mutation
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Reproduced
- [x] Controlling contract gap identified
- [ ] Design owner approved the fix design
- [ ] Planning owner approved the scope
- [ ] Regression tests added
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Resolve each existing v7 train lifecycle tuple through `mode-resolver.sh`.
2. Confirm cut, promote, rollback, retire, and all-train status resolve.
3. Resolve `ship action:assign target:train-metadata`.
4. Observe that the resolver returns exit 1 because no alias matches.
5. Compare that result with the ownership registry for the two state fields.
6. Compare the result with the `bubbles.train` workflow grant list.

## Expected Behavior

A narrowly named v7 action lets `bubbles.train` assign an existing train to `releaseTrain`. It may also record explicitly supplied `flagsIntroduced` metadata. The operation validates the train registry and changes only those owned fields.

The operation must not cut, promote, roll back, or retire a train. It must not modify release-train config, flag bundles, manifests, config bundles, or lifecycle certification. Every other agent remains unauthorized for the mutation.

## Actual Behavior

The five registered lifecycle and status tuples resolve. The metadata assignment tuple returns exit 1 with `no v5 alias matches v6 form`.

The ownership registry still reserves `releaseTrain` and `flagsIntroduced` writes for `bubbles.train`. The grant registry authorizes only cut, promote, rollback, retire, and all-train status modes. These contracts create an authorization dead end.

## Root Cause

Ownership and execution authorization were introduced as separate controls. The ownership registry assigned the fields to `bubbles.train`. The mode registry and grant list modeled only train lifecycle operations and status reporting.

No mode represents the distinct metadata-only mutation. The read-only backfill planner can recommend a train, but it cannot authorize the owner to persist that recommendation.

## Downstream Trigger

The operator reported a real QuantitativeFinance bug packet with an approved pre-MVP classification. `bubbles.train` refused to write the classification because no authorized mutation mode exists.

This downstream account is diagnostic input from the operator. The framework reproduction above independently confirms the missing route. This packet does not restate downstream output as framework execution evidence.

## Impact

- Approved release classification cannot be persisted through the exact owner.
- Agents must either refuse correctly or violate ownership and workflow grants.
- Read-only backfill recommendations cannot reach their intended state fields.
- Missing metadata can keep release-train guards noisy or blocking.
- Reusing cut or promote would falsely imply artifact or deployment semantics.

## Environment

- Repository: Bubbles source repository
- Platform: Linux under VS Code
- Discovery date: 2026-09-02

## Scope Boundary

### Included

- One metadata-only release-train workflow mode
- One v7 alias for metadata assignment
- `bubbles.train` grant and agent contract updates
- Existing-train validation
- Field-level mutation isolation
- Authorization isolation for every other agent
- Operator documentation
- Focused and aggregate selftests

### Excluded

- Train creation
- Candidate cuts
- Slot promotion
- Rollback
- Train retirement
- Release packet classification ownership
- Changes to config or feature-flag bundle content
- Changes to manifests or deployment adapters

## Related

- Ownership authority: `bubbles/agent-ownership.yaml`
- Grant authority: `bubbles/agent-capabilities.yaml`
- Mode authority: `bubbles/workflows/modes.yaml`
- Alias authority: `bubbles/workflows/aliases.yaml`
- Agent contract: `agents/bubbles.train.agent.md`
- Read-only planner: `bubbles/scripts/release-train-backfill-planner.sh`

## Historical Filing Note

The initial filing invocation documented and reproduced the defect only. At that time, no production workflow, grant, alias, agent, documentation, or selftest file changed. Design validation was then the next required action.

This note describes the initial filing state, not the current packet. The current implementation and test status appear in `report.md`.
