# Bug: BUG-046 Traceability Linked-Test Path Containment

## Summary

The shared traceability guard can accept a linked test path that resolves outside its allowed repository and feature boundaries.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - A blocking evidence-integrity guard can return a false pass
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status

- [ ] Reported
- [x] Confirmed (reproduced in the source finding)
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Classification

- Defect type: shared guard path-containment failure
- Security finding: `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001`
- Packet form: full
- Workflow mode: `bugfix-fastlane`

## Reproduction Steps

1. Use the bounded reproduction recorded for the source finding.
2. Observe the guard evaluate a manifest-controlled linked test path outside the allowed roots.
3. Observe the guard accept the external regular file as a valid linked test edge.

The authoritative reproduction evidence remains in the source report. This intake does not restate it as current-session execution.

## Expected Behavior

The guard must fail closed when a linked test path resolves outside the allowed repository and feature boundaries.

Only a contained test file may satisfy a scenario manifest's linked test edge.

## Actual Behavior

The guard checks whether joined path candidates name regular files. It does not first prove that the resolved target remains inside an allowed root.

## Environment

- Surface: `bubbles/scripts/traceability-guard.sh`
- Regression surface: `bubbles/scripts/traceability-guard-selftest.sh`
- Repository: Bubbles framework source
- Evidence origin: `bugs/BUG-045-traceability-empty-evidence-refs/report.md`

## Error Output

The source report records a successful guard result for an out-of-bound linked test target. See finding `F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001` in the related report.

## Initial Root Cause

`path_exists()` joins an untrusted linked test value to candidate roots and checks only whether the resulting path is a regular file.

The function does not canonicalize the target or enforce containment before accepting it. The manifest projection paths feed this check directly.

`bubbles.analyst` must complete the normative path contract before implementation begins.

## Impact

- A repository manifest can satisfy a required test edge with an unrelated local file.
- The traceability guard can report a false pass.
- Guard output can disclose whether a chosen local path exists.
- The defect affects the shared framework guard used by consuming repositories.

## Work Boundary

- `bugs/BUG-046-traceability-linked-test-path-containment/**`
- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`
- Cross-repository work is forbidden.

## Related

- Source finding: [`F-B045-SEC-LINKED-TEST-PATH-TRAVERSAL-001`](../BUG-045-traceability-empty-evidence-refs/report.md#security-defensive-review---2026-09-02t150152z)
- Affected guard: [`traceability-guard.sh`](../../bubbles/scripts/traceability-guard.sh)
- Regression surface: [`traceability-guard-selftest.sh`](../../bubbles/scripts/traceability-guard-selftest.sh)

## Routing

Next owner: `bubbles.analyst`.

The next owner must complete the full packet's specification artifacts. No implementation, test, validation, index, generated-file, Git, or host work has started.
