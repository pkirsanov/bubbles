# User Validation - BUG-048 Test Plan Owner Label Path Misclassification

Links: [report.md](report.md)

## Automation Readiness

- [ ] The pre-fix Finding Accounting fixture reports the owner label as a path.
- [ ] The fixed extractor checks only Test Plan path cells.
- [ ] Basename-only `.test` compatibility remains green.
- [ ] Real missing-path rejection remains active.
- [ ] Full framework validation and release readiness pass.

Automation readiness does not grant human acceptance.

## Checklist

- [ ] `bubbles.test` owner labels never become test paths.
- [ ] Legitimate basename-only `.test` files still resolve.
- [ ] Missing files in real Test Plan cells still block.
- [ ] File-shaped metadata in unrelated tables stays inert.

## Human Acceptance Record

- acceptedBy:
- acceptedAt:
- method:
- record:

## Goal

- Goal: Keep test path validation precise without weakening missing-file detection.
- Success signal: Only actual Test Plan file cells influence Check 8.

## Journey Steps

| Step | User Intent | Observed | Evidence | Friction |
| --- | --- | --- | --- | --- |

## Open Refinements

None recorded during filing.
