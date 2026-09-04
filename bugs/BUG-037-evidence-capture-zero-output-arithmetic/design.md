# BUG-037 Design — Evidence Capture Zero-Output Arithmetic

## Root-Cause Analysis

### Investigation Summary

The source initializes a private output file, runs the child, then derives `total` with `grep -c` plus a fallback printer. For an empty file, `grep -c ''` prints `0` but returns a no-match status. The fallback also prints `0`. Command substitution joins both outputs as `00`.

The formatter later treats `total` as an arithmetic operand. A line count should have one producer and one numeric representation. The current expression violates both properties.

The operator reported an arithmetic diagnostic from this path. The exact diagnostic text was not durably captured. The duplicated-zero source defect is confirmed. The exact diagnostic trigger remains a required red-stage observation.

### Root Cause

The expression uses process exit status to decide whether a count exists, even though `grep -c` already emitted a valid zero count. Its fallback appends data rather than supplying data only when no count was produced.

### Impact Analysis

- **Affected component:** `bubbles/scripts/evidence-capture.sh`.
- **Affected inputs:** zero-byte child output in normal formatting and verify preparation.
- **Affected consumers:** source validation and every downstream repository using bounded evidence capture.
- **Data risk:** no evidence bytes are changed, but metadata formatting can emit a diagnostic without a helper failure.

## Fix Design

### Solution Approach

Use one line-count producer that returns a canonical decimal count for every readable capture file. Do not infer count availability from no-match status. Keep the existing missing-file fail-closed check before counting.

Add focused fixtures for successful and failing zero-output children. Assert the exact count, empty-stream hash, absence of arithmetic diagnostics, and helper exit status. Preserve the existing non-empty selftest cases as adversarial controls.

Regenerate the release manifest only after focused and aggregate validation pass on the final bytes.

### Alternative Approaches Considered

1. Normalize `00` immediately before arithmetic. Rejected because it preserves the two-producer defect and treats one symptom.
2. Suppress arithmetic diagnostics. Rejected because evidence tooling must fail loudly rather than hide malformed metadata.
3. Special-case only a successful empty child. Rejected because failing zero-output children use the same count path.
4. Change the child exit contract. Rejected because the defect is metadata formatting, not command execution.

## Complexity Tracking

None — use one canonical count producer and focused regressions.
