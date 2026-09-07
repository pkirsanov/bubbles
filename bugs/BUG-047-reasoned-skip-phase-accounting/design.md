# BUG-047 Design - Canonical Skip Classification

## Root Cause Analysis

### Investigation Summary

The mode registry states that skipped phases live only in `executionHistory`.
Check 6 reads no history when building its phase set. Check 7A reads history,
but treats every non-exempt phase record as executed work.

### Root Cause

No production helper validates and classifies one `executionHistory` entry as a
canonical skip decision. The guard's two consumers therefore apply incompatible
models to the same record.

Check 6 interprets absence from completion claims as missing work. Check 7A
interprets equal timestamps as implausible execution. Both interpretations are
reasonable for execution records and wrong for a validated decision record.

### Impact Analysis

- **Affected components:** workflow phase relevance and transition certification.
- **Affected data:** version 3 `executionHistory` and completion claims.
- **Affected users:** every downstream repository using phase relevance.
- **Safety boundary:** malformed skips must never excuse a required phase.

## Fix Design

### Solution Approach

Add one canonical skip classifier that reads the registry schema. Reuse its
result in Check 6 and Check 7A.

A canonical skip must meet every condition below.

1. The record names a known phase and sets `outcome: skipped`.
2. The record gives a substantive reason.
3. The record gives a changed-surface list.
4. The record gives a boolean `reevaluated` value.
5. A re-evaluated record names its trigger.
6. The phase is absent from `neverSkip`.

Check 6 should merge validated skip phase names into phase accounting. It must
not append them to execution or certification claims.

Check 7A should exclude validated skip records from executed-duration checks.
It should continue reporting malformed skips and executed zero-duration spans.

The implementation should avoid a second copy of the skip schema. It may add a
small helper or a single shared analysis pass inside the guard. The authoritative
fields remain in `bubbles/workflows/modes.yaml`.

### Test Design

Add a composed fixture to `state-transition-guard-selftest.sh`. The fixture must
require `stabilize`, omit it from completion claims, and record one valid skip.
It must clear both Check 6 and Check 7A.

Add three adversarial twins.

- Remove the reason and require the record to remain invalid.
- Label a `neverSkip` phase skipped and require rejection.
- Execute a zero-duration `stabilize` phase and require a block.

Retain existing `phase-relevance-resolve-selftest.sh` coverage. Extend it only if
the resolver output contract changes.

### Alternative Approaches Considered

1. **Add skipped phases to `completedPhaseClaims`.** Rejected. This contradicts the registry and fabricates execution.
2. **Exempt every `outcome: skipped` record from duration checks.** Rejected. A malformed label would become a bypass.
3. **Add `stabilize` to the zero-duration exemption set.** Rejected. It would hide real zero-duration execution.
4. **Use `phaseStubs` instead of skip history.** Rejected. It creates a second decision record and preserves drift.

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Shared skip classifier | Two local string checks | Local checks would drift across phase accounting and plausibility again. |
