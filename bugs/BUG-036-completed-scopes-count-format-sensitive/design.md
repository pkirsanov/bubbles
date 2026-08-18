# BUG-036 Design - Structured Completed-Scope Counting

## Root-Cause Analysis

### Investigation Summary

Check 5 captures the text near `completedScopes`, strips the first bracket, and
counts physical lines that contain a quoted value. This algorithm is not a JSON
array count.

### Root Cause

Structured state is parsed with line-oriented text tools. Several quoted entries
on one line count as one.

The current selftest fixtures use quoted entries formatted across lines. They
therefore satisfy the broken parser and cannot detect this defect.

### Impact Analysis

- **Affected component:** transition guard Check 5.
- **Affected data:** version 3 and compatible legacy state files.
- **Affected users:** all downstream repositories.
- **Safety impact:** a false empty count can emit a fabrication-shaped block.

## Fix Design

### Solution Approach

Use the guard's existing structured JSON dependency to read array length.

1. Select `certification.completedScopes` when it is an array.
2. Otherwise, select the legacy top-level array when present.
3. Reject any selected entry that is not a string scope ID.
4. Count the selected array through structured JSON length.
5. Leave Check 5C identifier validation unchanged.

Do not retain the text parser as a fallback. The guard already depends on
structured JSON processing. Falling back to the known-broken parser would keep
platform-dependent false verdicts alive.

### Test Design

Add a positive fixture derived from the existing passing delivery fixture. Give
it three Done scope artifacts and serialize all three string IDs on one line.
Run the real transition guard and assert both facts:

- exit code remains zero
- Check 5 reports a matching count of three

Keep the existing BUG-011 ordinal fixture and phantom-scope fixture as
adversarial safety pins.

### Alternative Approaches Considered

1. **Count commas.** Rejected. Empty arrays and strings containing commas break
   the heuristic.
2. **Count quoted tokens with `grep -o`.** Rejected. The parser remains
   format-sensitive and duplicates JSON parsing.
3. **Use Python with a text fallback.** Rejected. Structured JSON tooling is
   already a framework dependency. The fallback would preserve the defect.
4. **Accept every JSON element type.** Rejected. Remote BUG-011 establishes
   string scope IDs as the mapping contract.

## Complexity Tracking

None - the structured array-length query is the simplest viable fix.