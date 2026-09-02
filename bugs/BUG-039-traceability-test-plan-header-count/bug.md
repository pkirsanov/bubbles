# Bug: BUG-039 Traceability Test Plan Header Count

- **Filed:** 2026-09-02
- **Severity:** medium
- **Disposition:** open framework defect
- **Affects:** standalone traceability Test Plan extraction and summary accounting

## Summary

The standalone traceability guard reports four Markdown Test Plan headers as test rows in a four-scope packet shaped like Research Lab Feature 028. Twenty-four `TP-028-*` data rows are summarized as 28 rows.

## Packet Route

The defect changes a shared parser and requires adversarial compatibility and malformed-input regression coverage. It therefore uses a full root bug packet under `bugs/` and does not create a root `specs/` tree.

## Severity

- [ ] Critical - system unusable or data loss
- [ ] High - major workflow unavailable with no safe workaround
- [x] Medium - traceability output is incorrect and can mislead audit accounting
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Reproduced in an isolated fixture
- [x] Root cause confirmed
- [x] Regression test added
- [x] Fixed
- [x] Focused selftest passed
- [ ] Aggregate framework validation passed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Create an isolated single-file scope packet containing four scopes.
2. Give each scope one exact `### Test Plan` section with a Markdown header beginning `| ID | Type |`.
3. Add six `TP-028-*` data rows per scope, for 24 genuine rows total.
4. Run the standalone traceability guard with `--all-scopes`.
5. Observe the final `Test rows checked` summary.

## Expected Behavior

Markdown header and separator rows do not count. Each genuine Test Plan data row counts once. Four tables containing six data rows each aggregate to exactly 24. Legacy supported headings continue to parse. A malformed candidate row causes an explicit extraction failure instead of silently disappearing.

## Actual Behavior

The isolated four-scope fixture contains 24 `TP-028-*` data rows. The affected installed guard reports seven rows per scope and 28 rows in the aggregate. The excess equals one `| ID | Type | ... |` header per scope.

## Root Cause

The defect is in Test Plan parsing, not summary accounting. The affected extractor skips separators and only recognizes a header beginning `Test Type`. It emits an `ID | Type` header as ordinary data. The summary then correctly counts every emitted record.

The canonical source had already moved extraction to a header-aware parser, but that parser recognized only the legacy `Test Type` plus `File/Location` shape. The surgical fix extends that parser to recognize `ID` plus `Type` with supported file-column headings, requires the separator, emits only genuine data rows, and rejects malformed rows explicitly. Summary accumulation remains unchanged.

## Environment

- Repository: Bubbles source repository
- Platform: Linux under VS Code
- Trigger shape: Research Lab Feature 028-style four-scope Test Plan tables

## Scope Boundary

### Included

- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`
- This bug packet

### Excluded

- BUG-037 evidence-capture work
- BUG-038 train-metadata work
- Receipt-identity work
- State-transition guard aggregate work
- Full framework validation and release readiness in this invocation
- Downstream Research Lab artifacts

## Related

- Production parser: `bubbles/scripts/traceability-guard.sh`
- Focused regression suite: `bubbles/scripts/traceability-guard-selftest.sh`
- Downstream trigger shape: Research Lab Feature 028 Test Plan tables
