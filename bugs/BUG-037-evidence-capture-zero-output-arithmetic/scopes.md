# BUG-037 Scopes

## Scope 1 — Canonical Zero-Output Metadata

**Status:** In Progress

### Gherkin Scenarios

The authoritative scenarios are SCN-B037-001 through SCN-B037-004 in `spec.md` and `scenario-manifest.json`.

### Implementation Plan

1. Add focused zero-output tests before changing the helper.
2. Capture the exact arithmetic diagnostic and failing assertions.
3. Replace the two-producer line-count expression with one canonical counter.
4. Re-run the same zero-output fixtures.
5. Run the existing non-empty helper selftest as an adversarial control.
6. Run aggregate framework and release validation.
7. Regenerate the release manifest from validated bytes.

### Test Plan

| ID | Test | Type | Surface |
| --- | --- | --- | --- |
| T1 | Successful zero-output child reports canonical metadata | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| T2 | Failing zero-output child reports canonical metadata and propagates status | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| T3 | Empty-output verify match and mismatch preserve exit contracts | unit | `bubbles/scripts/evidence-capture-selftest.sh` |
| T4 | Existing non-empty, bounded, signal, and cleanup cases remain unchanged | regression | `bubbles/scripts/evidence-capture-selftest.sh` |
| T5 | Regression E2E — framework validation preserves evidence helper behavior | functional | `bubbles/scripts/cli.sh framework-validate` |
| T6 | Release readiness validates generated manifest consistency | functional | `bubbles/scripts/cli.sh release-check` |

### Definition of Done

- [ ] Exact zero-output arithmetic diagnostic is captured before the fix.
  > **Uncertainty Declaration**
  > **What was attempted:** No reproduction command was authorized in this artifact-only invocation.
  > **What was observed:** The operator reported the diagnostic, but its exact text was not durably captured.
  > **Why this is uncertain:** Source inspection confirms `00`, but does not prove the exact diagnostic path.
  > **What would resolve this:** Run the focused zero-output fixtures before changing `evidence-capture.sh`.
- [ ] Successful zero-output capture reports zero lines, the empty hash, and exit zero without diagnostics.
- [ ] Failing zero-output capture reports zero lines, the empty hash, and the child status without diagnostics.
- [ ] Empty-output verify match and mismatch retain the existing exit contract.
- [ ] Non-empty capture behavior remains unchanged.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
- [ ] Broader E2E regression suite passes
- [ ] Release manifest is regenerated from the validated source tree.
- [ ] `bubbles.validate` certifies the packet transition.
