# Bug Fix Design: BUG-045

## Root Cause Analysis

### Investigation Summary

The investigation followed the production path rather than inferring behavior
from the originating BUG-037 narrative.

1. `scenario_manifest_total` counts scenario objects with a non-empty `id` or
   `scenarioId`.
2. Linked-test projection validates the linked test paths independently.
3. `manifest_evidence_refs` counts every scenario where `evidenceRefs` has JSON
   type `array`.
4. Equality between that count and `scenario_manifest_total` emits the all-
   covered pass line.
5. Later report-reference checks use `scopes.md` Test Plan rows and do not read
   the manifest array members.

The minimal fixture held every other traceability edge valid and changed only
`evidenceRefs` from a one-member array to `[]`. The guard returned 0 and emitted
the all-covered pass line. This isolates the defect to the cardinality predicate.

### Root Cause

The guard treats container type as proof of content:

```bash
map(select((.evidenceRefs | type) == "array")) | length
```

An empty array satisfies the selector, so the count cannot distinguish zero
references from one or more references. The pass/fail branch then overstates
coverage.

The JSON schema does not require `evidenceRefs` and does not declare `minItems`.
The guard is therefore the sole current enforcement surface for this
completeness rule.

### Current BUG-037 Qualification

The origin finding recorded three empty arrays. During this concurrent packet
run, the independent BUG-037 implementation owner populated them. A clean current
measurement at tool-log row 455 found 19 typed arrays, 19 non-empty arrays, and
0 empty arrays. This does not invalidate the guard defect; it removes BUG-037 as
a current malformed-input fixture. The hermetic one-scenario fixture at row 457
is the authoritative current reproduction.

### Impact Analysis

- Affected component: `bubbles/scripts/traceability-guard.sh` manifest
  evidence-reference cross-check.
- Affected assurance: G057/G059 traceability output can state complete evidence
  coverage for empty arrays.
- Data impact: none. The guard is read-only.
- User impact: packet authors and validators can receive a false green
  traceability verdict.
- Cross-product impact: the script is shipped to downstream repositories, but
  this packet changes only canonical framework source.

## Fix Design

### Solution Approach

Change the existing structured jq selector so a scenario counts only when:

```jq
(.evidenceRefs | type) == "array" and (.evidenceRefs | length) > 0
```

Keep the existing count comparison and diagnostic wording. Add focused cases to
`traceability-guard-selftest.sh`:

1. A one-scenario fixture with `evidenceRefs: []` must exit non-zero and contain
   `records evidenceRefs for only 0 of 1`.
2. The current non-empty canonical fixture remains exit 0.
3. A two-scenario mixed fixture must exit non-zero and contain `only 1 of 2`.
4. Mutation coverage restores the old type-only predicate and proves the new
   empty/mixed assertions fail while the non-empty control remains green.

### Why This Is The Smallest Correct Repair

The count and pass/fail branch already implement the intended control flow. Only
the admission predicate is incomplete. Adding a second parser, changing the
schema, or adding per-reference path validation would widen the contract beyond
the reported zero-cardinality defect.

### Alternative Approaches Considered

1. Add `minItems: 1` to the JSON schema. Rejected because the traceability guard
   does not validate this manifest through that schema on this path, legacy
   envelopes are supported, and the user limited the repair to the guard and its
   focused selftest.
2. Validate report anchors and reject blank strings. Rejected as a separate
   semantic contract with a larger blast radius.
3. Repair BUG-037's empty arrays only. Rejected because the concurrent owner has
   already populated them and data repair does not fix the guard's false pass.
4. Add a second post-count loop. Rejected because it duplicates the predicate
   and creates two answers for the same completeness decision.

## Change Boundary

Allowed:

- `bugs/BUG-045-traceability-empty-evidence-refs/**`
- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`

Forbidden:

- `bugs/BUG-037-uservalidation-opt-out-acceptance/**`
- `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/**`
- `BUGS.md`, `improvements/INDEX.md`, and `bubbles/release-manifest.json`
- session JSON or lock files
- downstream repositories, refs, worktrees, remotes, deployment, or cleanup
- broad framework validation in this packet-only phase

## Complexity Tracking

None - the proposed repair extends the existing predicate and adds focused
coverage at the owning selftest.
