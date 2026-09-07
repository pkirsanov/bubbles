# BUG-048 Design - Header-Bound Test Plan Extraction

## Root Cause Analysis

### Investigation Summary

Check 8 selects every line matching a broad Markdown table pattern. It then
examines every backtick block in the row. Candidate validation accepts supported
suffixes, including bare `.test`.

### Root Cause

The extractor recognizes lexical path shapes without first proving that a token
came from a Test Plan file-location cell. This makes table metadata and file
paths indistinguishable.

A blacklist for `bubbles.test` would hide one symptom. It would not repair the
missing semantic boundary and would fail on the next owner label or metadata
value with a supported suffix.

### Impact Analysis

- **Affected component:** state transition Check 8.
- **Affected data:** Markdown scope artifacts with multiple tables.
- **Affected users:** repositories using Finding Accounting and basename paths.
- **Safety boundary:** real missing Test Plan files must still block.

## Fix Design

### Solution Approach

Implement a small stateful Test Plan table extractor.

1. Enter extraction only under a `## Test Plan` or `### Test Plan` heading.
2. Parse the first Markdown table header within that section.
3. Resolve columns named `File`, `Path`, `File/Location`, or equivalent canonical forms.
4. Extract candidates only from those columns in following data rows.
5. Leave the section when another equal-or-higher heading starts.
6. Leave the table when a non-table line ends it.
7. Reuse the existing candidate and command-wrapper validation for the selected cell.

The implementation must derive position from the header. It must not assume a
fixed column number because current templates differ.

### Test Design

Build a fixture with one real Test Plan path and a later Finding Accounting
table containing five `bubbles.test` labels. The pre-fix guard must report the
owner label as missing. The post-fix guard must check only the real test file.

Add these controls.

- Resolve an existing basename-only `smoke.test` from a real path cell.
- Block a missing basename-only `missing.test` from a real path cell.
- Keep a file-shaped value in another table inert.
- Keep existing shell and compound MJS fixtures green.

### Alternative Approaches Considered

1. **Reject bare `.test`.** Rejected. It breaks a required legitimate filename.
2. **Exclude strings beginning `bubbles.`.** Rejected. It is label-specific and leaves generic metadata misclassification.
3. **Scan only rows containing `Regression E2E`.** Rejected. Other valid test categories also name files.
4. **Parse `test-plan.json` only.** Rejected. Markdown fallback remains a compatibility contract.

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Header-derived column extraction | Owner-label blacklist | A blacklist repairs one token while preserving the category error. |
