# BUG-045 User Validation

## Automation Readiness

Written by automation. These items record packet readiness and grant no terminal
certification.

- [x] The empty-array defect was reproduced through the production guard
- [x] The exact type-only predicate and pass branch were identified
- [x] The current BUG-037 manifest was measured separately and left untouched
- [x] The implementation boundary is limited to the guard and its focused selftest

## Checklist

Human acceptance is opt-out. Uncheck an item whose delivered behavior does not
meet the expectation.

- [x] A scenario with `evidenceRefs: []` is rejected by the traceability guard
- [x] The refusal reports the exact number of covered scenario contracts
- [x] A scenario with a non-empty evidence reference remains accepted
- [x] The focused regression fails if the type-only predicate is restored
- [x] BUG-037, BUG-033, the release manifest, and session control files remain unchanged
- [x] No broad framework validation or unrelated repository operation is added to this fix

An unchecked item blocks terminal promotion until the behavior is fixed and the
user re-checks it. Unchecking nothing is acceptance; implementation evidence and
validate-owned certification are still independently required.

## Human Acceptance Record

Optional. Not required for terminal transition under the opt-out contract.

- acceptedBy: [human name or handle - never an agent id]
- acceptedAt: [YYYY-MM-DDTHH:MM:SSZ]
- method: [human-interactive | external-record]
- record: [required only for external-record]

## Goal

- Goal: prevent an empty evidence-reference container from being reported as evidence coverage
- Success signal: the focused CLI regression rejects empty and mixed manifests while preserving the non-empty control
