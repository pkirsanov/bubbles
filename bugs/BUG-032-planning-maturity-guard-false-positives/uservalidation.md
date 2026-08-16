# User Validation: BUG-032 Planning-Maturity Guard False Positives

## Checklist

- [x] The packet presents all four Ozhiva-exposed observations as planning input,
  not as commands executed by this agent.
- [x] The consumer classifier plan includes negative stale-generation,
  provider-replacement, and lifecycle-replacement cases plus positive
  route/path/endpoint/contract/identifier mutation controls.
- [x] The SLA classifier plan includes explicit no-SLO/opt-out negatives plus
  genuine SLO, latency, throughput, p95, and p99 positives.
- [x] The receipt plan accepts only independently evidenced deterministic sibling
  runs and retains incompatible-command and empty-stdout controls.
- [x] The G101 plan rejects planning maturity and prototype output, preserves
  validate-certified done delivery, and reviews docs, validation-only, rapid,
  and pending-activation mode semantics.
- [x] Exact focused, full-framework, release, agnosticity, and diff validation
  commands are recorded in `scopes.md` and `report.md`.
- [x] The packet remains `in_progress`; no item claims the guard fixes or their
  regression tests have executed.

Unchecked items in this section are reserved for user-reported regressions. This
planning checklist verifies packet content only and is not implementation
acceptance.

## Goal

- **Goal:** Eliminate four false framework classifications while preserving each
  guard's adversarial positive case.
- **Success signal:** The persistent negative fixtures pass after implementation,
  their positive twins still trigger, G101 uses delivery-capable mode semantics,
  and full framework validation plus release check exit successfully.

## Validation Journey

| Step | User intent | Planned verification | Evidence destination |
| --- | --- | --- | --- |
| 1 | Prove current false positives | Add persistent fixtures and run focused selftests before production changes | `report.md`, E-032-RED-01 through E-032-RED-03 |
| 2 | Prove narrow fixes | Re-run the same focused selftests after each production change | `report.md`, scope-specific green evidence |
| 3 | Prove no broad exemptions | Inspect adversarial route/SLO/unrelated-command/prototype controls | `report.md`, scenario evidence sections |
| 4 | Prove framework compatibility | Run framework validation, release check, and agnosticity | `report.md`, E-032-FULL-01 through E-032-LINT-01 |

## Open Refinements

- None in the planning packet. Any implementation finding must be recorded and
  routed through the bugfix workflow rather than appended as an informal task.
