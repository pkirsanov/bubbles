# BUG-039 Design - Traceability Test Plan Row Accounting

## Design Brief

### Current State

`extract_test_rows` reads visible Markdown lines under one exact Test Plan heading. It emits records that the shell summary counts without adjustment.

The active parser recognizes canonical and legacy header tokens. It detects a second well-formed Markdown table in both `READ_ROWS` and `DONE`.

The implementation already validates separator width and nonempty cells. However, some status-4 paths still exit without a parser diagnostic.

A recognized rowless table can still reach the outer no-concrete-rows guard. The parser does not yet classify every rowless boundary as status `4`.

### Target State

Use one deterministic state machine for exactly one visible Test Plan section and exactly one contiguous table. Emit one record for each valid data row.

Stop data emission at the first table boundary. Continue structural inspection through the section boundary or end of file.

Reject every second Markdown table, whether adjacent or separated from the first table. Reject every recognized table that emits no data row.

Every structural status-4 exit must include one stable diagnostic and one visible line number. Keep summary arithmetic unchanged.

### Patterns to Follow

- Keep Markdown preprocessing and cell tokenization in the Python block inside `extract_test_rows`.
- Keep extraction records in the existing `path<TAB>semantic text` shape.
- Keep the shell accumulator as a direct count of emitted records.
- Preserve the parser's exact Test Plan heading cardinality checks.
- Preserve second-table lookahead in both `READ_ROWS` and `DONE`.
- Route every structural status-4 exit through the diagnostic helper.

### Patterns to Avoid

- Do not emit rows from a later table. Continue scanning only to refuse that second table explicitly.
- Do not ignore later tables after the first table ends. Ignoring them violates the one-table section contract.
- Do not classify a separator from only its nonempty cells. That behavior accepts missing columns.
- Do not pad short rows or truncate long rows. Either behavior conceals malformed planning data.
- Do not subtract structural rows from the final count. That workaround makes totals depend on table count.

### Resolved Decisions

- The parser owns structural classification and row validation.
- The document contains exactly one canonical visible Test Plan section.
- That section contains exactly one contiguous Markdown Test Plan table.
- Canonical and legacy headers use closed vocabularies.
- A separator must immediately follow its recognized header.
- Header, separator, and data rows must have identical widths.
- Required identifying cells must be nonempty.
- Blank text, prose, and headings terminate data emission but not second-table inspection.
- A second table fails in both `READ_ROWS` and `DONE`.
- A recognized table must contain at least one valid data row.
- Every structural status-4 exit uses a stable diagnostic with its visible line number.
- Python owns the state machine. Bash only invokes it and propagates status.

### Open Questions

None. The specification and B039-CR-001, B039-CR-002, and B039-CR-003 review constraints determine the parser contract.

## Purpose and Scope

This design corrects standalone traceability row accounting. It does not change scenario matching, path resolution, DoD matching, or summary arithmetic.

The parser must count rows from exactly one supported Test Plan table. It must never absorb or ignore rows from a second table.

## Root Cause Analysis

The 28-for-24 symptom contains one extra extraction record per six-row table. The affected installed parser emitted each canonical header as data.

The canonical parser now has header awareness, strict separators, and second-table lookahead. The design remained stale and described later tables as ignored.

The current parser also has bare status-4 header exits. Its rowless path can fall through to the outer no-concrete-rows failure.

The shell accumulator increments once per emitted record. It cannot distinguish a genuine record from parser leakage.

The durable correction therefore belongs inside `extract_test_rows`. The output count remains the number of emitted data records.

## Review Reconciliation

The B039-CR-001, B039-CR-002, and B039-CR-003 review set is resolved through three closed contracts:

1. The heading and state-machine contract defines exactly one visible section and one contiguous table.
2. The row grammar defines exact widths, separator validity, and required cells.
3. The termination contract prevents later tables from entering the stream and refuses them explicitly.

No active design text preserves the earlier ignore-later-tables behavior.

## Architecture Overview

`extract_test_rows` retains two stages:

1. Preprocess Markdown into visible lines by removing fenced content and HTML comment content.
2. Parse the selected Test Plan section with the state machine below.

Cell tokenization remains pipe-aware. Escaped pipes and matching backtick runs do not split cells.

The parser prints no structural rows. Each accepted data row produces exactly one existing-format extraction record.

The implementation remains in `bubbles/scripts/traceability-guard.sh::extract_test_rows`. Focused regression coverage remains in `bubbles/scripts/traceability-guard-selftest.sh`.

### Exact Test Plan Heading Boundary

The section heading grammar is exactly `^(#{2,3}) Test Plan$` after visible-line preprocessing and trailing-whitespace removal.

This grammar accepts only `## Test Plan` and `### Test Plan`. It rejects leading indentation, alternate capitalization, extra words, and deeper headings.

The document must contain exactly one matching heading. This is the canonical visible Test Plan section for extraction.

No match retains parser status `3`. Multiple matches retain parser status `5`.

The section ends at the next Markdown heading whose depth is equal to or shallower than the Test Plan heading depth.

## Deterministic Table State Machine

The parser uses the closed states `SEEK_HEADER`, `EXPECT_SEPARATOR`, `READ_ROWS`, and `DONE`.

### `SEEK_HEADER`

Skip blank lines, prose, separators, and unrelated table rows. An unrelated row contains none of the reserved header signature tokens.

The reserved normalized tokens are `id`, `type`, `testtype`, and every supported path-heading alias. A row containing any reserved token is a header candidate.

A candidate must match exactly one supported header vocabulary. Reject partial, duplicate, or mixed candidates with extraction status `4`.

Transition to `EXPECT_SEPARATOR` after accepting one header. Record its width, table kind, and selected path-column index.

If the section boundary or end of file arrives without a candidate, return zero records. The outer guard reports that no concrete Test Plan rows exist.

### `EXPECT_SEPARATOR`

The next preprocessed line must be a valid separator row. No blank, prose, heading, or different table row may intervene.

Reject a missing, delayed, malformed, or wrong-width separator with parser status `4`. Transition to `READ_ROWS` only after full validation.

At the section boundary or end of file, fail with the stable missing-separator diagnostic. Report the first unavailable visible line after the section body.

### `READ_ROWS`

Accept contiguous data rows with the recorded width. Validate required cells before emitting each record.

A valid data row emits exactly one record. Never pad, truncate, merge, or silently omit a row.

A blank line, prose line, or deeper heading ends data emission. Transition to `DONE` only after confirming that at least one row was emitted.

A table row followed immediately by a valid same-width separator starts a second Markdown table. Fail with parser status `4` at that header line.

Reject an unexpected separator inside the active data region. Reject every wrong-width row that is not a detected new-table header.

If any termination boundary occurs before the first data row, fail with rowless parser status `4`. Use the boundary's visible line number.

At the section boundary or end of file, finish cleanly only when `row_count` is positive. Otherwise fail rowless with status `4`.

### `DONE`

Inspect every remaining line only for a second Markdown table. Never emit or validate second-table data rows.

Any header-shaped row followed by a valid same-width separator is a second table. Fail with parser status `4` at its header line.

The section boundary and end of file are clean in `DONE` because entry requires a positive `row_count`. No content beyond the section boundary is inspected.

### Terminal Transition Matrix

| Current state | Input or terminal event | Result |
| --- | --- | --- |
| `SEEK_HEADER` | Recognized header | Record grammar and transition to `EXPECT_SEPARATOR` |
| `SEEK_HEADER` | Section boundary or end of file | Return zero records for outer rowless handling |
| `EXPECT_SEPARATOR` | Valid immediate separator | Transition to `READ_ROWS` |
| `EXPECT_SEPARATOR` | Any other line, section boundary, or end of file | Parser status `4` with separator diagnostic and visible line |
| `READ_ROWS` | Valid data row | Emit one record and increment `row_count` |
| `READ_ROWS` | Second-table header plus valid separator | Parser status `4` with second-table diagnostic at the header line |
| `READ_ROWS` | Blank, prose, or deeper heading with positive `row_count` | Transition to `DONE` and continue second-table inspection |
| `READ_ROWS` | Blank, prose, deeper heading, section boundary, or end of file with zero rows | Parser status `4` with rowless diagnostic and boundary line |
| `READ_ROWS` | Section boundary or end of file with positive `row_count` | Clean extraction end |
| `DONE` | Second-table header plus valid separator | Parser status `4` with second-table diagnostic at the header line |
| `DONE` | Section boundary or end of file | Clean extraction end |

## Supported Header Vocabularies

Header matching lowercases each trimmed cell and removes all whitespace. It preserves punctuation such as `/`.

### Canonical Vocabulary

A canonical header contains exactly one `ID`, exactly one `Type`, and exactly one supported path heading.

It must not contain `Test Type`. Other nonreserved columns remain allowed and preserve their declared order.

Canonical data rows require nonempty `ID`, `Type`, and selected path cells.

### Legacy Vocabulary

A legacy header contains exactly one `Test Type` and exactly one supported path heading.

It must not contain the canonical `ID` or `Type` signature. Other nonreserved columns remain allowed.

Legacy data rows require nonempty `Test Type` and selected path cells.

### Retained Path-Heading Aliases

| Display heading | Normalized token | Reason retained |
| --- | --- | --- |
| `File/Location` | `file/location` | This is the legacy Bubbles Test Plan heading and existing compatibility surface. |
| `File / Surface` | `file/surface` | Current planning packets use this heading for file-backed and non-file validation surfaces. |
| `Persistent file and exact title` | `persistentfileandexacttitle` | Feature 028 uses this heading for persistent regression identity and triggered BUG-039. |

The aliases form a closed set. A header containing zero aliases, multiple different aliases, or a duplicate alias is malformed.

## Separator Grammar

A separator is valid only when every condition below holds:

1. It is a Markdown table row parsed by the existing cell tokenizer.
2. Its cell count equals the accepted header width.
3. Every separator cell is nonempty after trimming.
4. Every cell matches `:?-{3,}:?` after whitespace removal.

Alignment colons may appear on either side. Each cell must contain at least three hyphens.

An all-empty row is never a separator. A partly empty row is never a separator.

## Data-Row Grammar and Emission

Every data row must have exactly the accepted header width. Extra and missing cells are explicit extraction failures.

Required cells are validated after trimming. Optional cells may remain empty.

The emitted path value comes from the selected path-heading column. Semantic text excludes all path aliases and the `Command` column.

The parser emits each valid row once in source order. The shell summary sums those records without offsets or table-based compensation.

## Termination and Failure Model

| Condition | Result |
| --- | --- |
| No exact Test Plan heading | Explicit extraction status `3` |
| More than one exact Test Plan heading | Explicit extraction status `5` |
| No supported header candidate in the section | Clean parser end with zero records, followed by the existing no-concrete-rows guard failure |
| Partial, duplicate, or mixed supported header | Explicit extraction status `4` |
| Missing or non-immediate separator | Explicit extraction status `4` |
| Separator has an empty cell, invalid token, or wrong width | Explicit extraction status `4` |
| Blank, prose, deeper heading, section boundary, or end before any data row | Explicit rowless parser status `4` |
| Data row has the wrong width or an empty required cell | Explicit extraction status `4` |
| Unexpected separator inside data rows | Explicit extraction status `4` |
| Blank, prose, heading, section boundary, or end after valid data | Clean table end |
| New table header followed by a valid same-width separator in `READ_ROWS` | Explicit second-table parser status `4` at the header line |
| New table header followed by a valid same-width separator in `DONE` | Explicit second-table parser status `4` at the header line |
| Non-table content after `DONE` | Inspected without emission until the section boundary or end |

Every structural status-4 path writes one stable actionable diagnostic to standard error. The diagnostic includes the failure class and visible line number.

No structural branch may call `SystemExit(4)` directly. Each branch must use the shared structural-failure helper.

Stable failure classes are `malformed Test Plan header`, `missing or delayed Test Plan separator`, `wrong-width Test Plan separator`, `invalid or empty Test Plan separator cell`, `rowless recognized Test Plan table`, `second Markdown table in Test Plan section`, `unexpected separator inside Test Plan data rows`, `malformed Test Plan row`, and `required Test Plan cell is empty`.

Width diagnostics include expected and observed cell counts. Other diagnostics name the required correction without printing Markdown content.

Parser status `4` identifies malformed table structure. The outer guard preserves the nonzero status and adds its existing `Test Plan extraction failed` failure.

Parser statuses `3` and `5` remain heading-cardinality signals. The outer guard maps them to their dedicated missing-section and multiple-section failures.

A clean parser result with zero records means no recognized header candidate existed. Only that case reaches the outer no-concrete-rows failure.

## Adversarial Validation Matrix

| Case | Fixture shape | Expected result |
| --- | --- | --- |
| Canonical positive control | `ID`, `Type`, one retained path alias, valid separator, and six valid rows | Six records and no structural records |
| Legacy positive control | `Test Type`, `File/Location`, valid separator, and one valid row | One record |
| Missing separator | Canonical header followed by a data row | Status `4` before emission |
| Delayed separator | Canonical header followed by blank or prose, then a valid separator | Status `4` before emission |
| Short separator token | One separator cell contains fewer than three hyphens | Status `4` |
| Empty separator cell | Separator width matches, but one cell is empty | Status `4` |
| Narrow separator | Separator has fewer cells than the header | Status `4` |
| Wide separator | Separator has more cells than the header | Status `4` |
| Interrupted table | Valid rows are followed by blank text, prose, or a heading, then pipe rows | Only rows before interruption count |
| Adjacent second table | Valid rows are followed by a header and an immediate valid separator | Status `4` at the second header; no second-table rows count |
| Separated second table | A blank or prose line separates two valid tables | Status `4` at the second header; no second-table rows count |
| Empty canonical ID | Canonical data row has an empty `ID` cell | Status `4` |
| Empty canonical type | Canonical data row has an empty `Type` cell | Status `4` |
| Empty canonical path | Canonical data row has an empty selected path cell | Status `4` |
| Empty legacy type | Legacy data row has an empty `Test Type` cell | Status `4` |
| Empty legacy path | Legacy data row has an empty selected path cell | Status `4` |
| Duplicate path alias | Header repeats one alias or contains two retained aliases | Status `4` |
| Mixed vocabulary | Header combines `Test Type` with canonical `ID` or `Type` | Status `4` |
| Unrelated table before header | Unrelated table has no reserved signature token, then the supported table follows | Only the supported table counts |
| Unrelated table after data | Valid table ends, then an unrelated table follows | Status `4` at the second header; no second-table rows count |

The four-table aggregate control contains four canonical tables with six rows each. It must emit exactly 24 records.

## Cross-Platform Implementation Contract

Implement the state machine in the existing Python 3 parser. Use indexed iteration and bounded lookahead for new-table detection.

Keep the surrounding shell compatible with Bash 3.2. Do not add associative arrays, `mapfile`, or Bash 4-only parameter operations.

Do not depend on GNU or BSD variants of `sed`, `awk`, `grep`, `stat`, `date`, or `readlink` for table classification.

Use Python string handling and `re.fullmatch` for normalization and grammar checks. This keeps behavior identical across GNU and BSD userlands.

### Single-Implementation Justification

This is a narrow bug fix inside one existing parser. A provider, adapter, plugin, or reusable parser framework would add unused extension points.

## Security, Privacy, and Compliance

The parser reads repository Markdown and emits existing path and semantic fields. It introduces no new trust boundary or persisted data.

Malformed input fails closed. The design does not execute Markdown content or resolve new external resources.

## Configuration, Migration, and Rollout

No configuration or data migration applies. The parser behavior changes atomically with its focused regression coverage.

Rollback restores the previous parser block. Summary arithmetic and extraction record format remain compatible.

## Observability and Failure Handling

Keep diagnostics deterministic and line-oriented. Include the failure class and preprocessed line number without dumping file contents.

Keep parser diagnostics distinct from outer guard failures. The parser explains malformed structure. The outer guard explains extraction failure in scope context.

Do not convert parser failures into warnings. The caller must discard captured partial output when extraction returns nonzero.

## Alternatives and Tradeoffs

1. **Subtract one row per table in the summary.** Rejected because a fixed offset masks malformed structure and depends on table count.
2. **Count only identifiers with a `TP-` prefix.** Rejected because legacy tables do not require an ID column.
3. **Ignore tables after interruption.** Rejected because silence permits multiple table authorities inside one Test Plan section.
4. **Accept ragged separators or rows.** Rejected because padding and truncation conceal malformed planning obligations.
5. **Implement the state machine in shell.** Rejected because portable Markdown tokenization is clearer in the existing Python parser.

## Open Questions and Risks

None. The retained aliases and termination behavior are explicit and closed.

## Complexity Tracking

None — simplest viable approach used.
