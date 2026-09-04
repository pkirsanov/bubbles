# BUG-039 Expected Behavior - Traceability Test Plan Row Accounting

## Outcome Contract

- **Intent:** Count only valid Test Plan data rows in standalone traceability summaries.
- **Success Signal:** A four-table fixture with 24 genuine rows reports exactly 24.
- **Hard Constraints:** Each Test Plan section contains exactly one contiguous Test Plan table. Headers and separators count zero. Genuine rows count once. The closed heading aliases remain accepted. Malformed structure, malformed data, and a second table fail explicitly.
- **Failure Condition:** Structural Markdown rows inflate totals, valid rows are lost or duplicated, unsupported headings expand the contract, or invalid table content disappears without failure.

## Test Plan Table Contract

- A Test Plan section starts at an exact visible `## Test Plan` or `### Test Plan` heading.
- The section ends at the next visible heading of equal or shallower depth.
- The section may contain prose before its table, but it must contain exactly one Markdown table.
- The table starts with one recognized header row. The next visible line must be its separator row.
- The separator must have the same cell count as the header. Every separator cell must be non-empty and match Markdown separator grammar.
- Data rows start immediately after the separator. They remain contiguous until the first non-table line or any heading.
- A blank line is non-table content and ends the contiguous data rows.
- Any later Markdown table within the same Test Plan section is a second table and must fail explicitly.
- A recognized table with no valid data rows must fail explicitly as rowless.

### Closed Header Vocabulary

The parser accepts exactly these two required heading families. Required headings may appear in any column order and must appear once.

1. Canonical family: `ID`, `Type`, and one supported path heading.
2. Legacy family: `Test Type` and one supported path heading.

The supported path headings are a closed list:

- `File/Location`
- `File / Surface`
- `Persistent file and exact title`

Markdown cell-edge padding is not part of a heading. No other path-heading alias is supported by this bug contract.

## User Scenarios

### Scenario 1 - Structural rows do not count

```gherkin
Given a Test Plan section has one recognized header
And the next visible line is a same-width non-empty valid Markdown separator
When standalone traceability extracts the table
Then neither structural row contributes to the test-row total
```

### Scenario 2 - Genuine rows count exactly once across tables

```gherkin
Given four scopes each contain one contiguous Test Plan table
And each table contains six distinct TP-028 data rows
When standalone traceability runs across all scopes
Then each genuine row counts once
And the aggregate total is exactly 24
```

### Scenario 3 - Closed heading families remain compatible

```gherkin
Given one Test Plan uses ID, Type, and Persistent file and exact title
And one Test Plan uses ID, Type, and File / Surface
And one Test Plan uses Test Type and File/Location
When standalone traceability extracts each table
Then every table's genuine rows remain traceable
And no unlisted path-heading alias is accepted
```

### Scenario 4 - Malformed structure and data fail loudly

```gherkin
Given a recognized Test Plan table has a missing, empty, invalid, delayed, or wrong-width separator
Or its contiguous data rows contain a wrong-width row or an empty required cell
When standalone traceability extracts the table
Then extraction fails explicitly
And invalid content is not silently omitted from accounting
```

### Scenario 5 - Table boundaries and duplicate tables fail deterministically

```gherkin
Given a recognized Test Plan table has started emitting contiguous data rows
When a non-table line or any heading appears
Then the current table ends
And a later Markdown table in the same Test Plan section fails explicitly as a second table
```

## Functional Requirements

- **FR-B039-001:** Each exact visible `## Test Plan` or `### Test Plan` section must contain exactly one contiguous Markdown Test Plan table.
- **FR-B039-002:** A recognized table header must use either the canonical required headings `ID` and `Type` or the legacy required heading `Test Type`.
- **FR-B039-003:** Each recognized header must contain exactly one path heading from this closed list: `File/Location`, `File / Surface`, or `Persistent file and exact title`.
- **FR-B039-004:** Every required heading must appear exactly once. Required headings may appear in any column order. No unlisted path-heading alias may become accepted through this repair.
- **FR-B039-005:** The next visible line after a recognized header must be a same-width separator with no empty cells. Every cell must match Markdown separator grammar.
- **FR-B039-006:** Header and separator rows must emit no extraction records.
- **FR-B039-007:** Data rows must start immediately after the separator and remain contiguous until the first non-table line or any heading.
- **FR-B039-008:** A blank line must end the contiguous data-row block. Any later Markdown table inside the same Test Plan section must fail explicitly as a second table.
- **FR-B039-009:** A wrong-width data row or a data row with an empty required cell must return a nonzero extraction status and a visible guard failure.
- **FR-B039-010:** A missing, empty, invalid, delayed, or wrong-width separator must return a nonzero extraction status and a visible guard failure.
- **FR-B039-011:** A recognized table with no valid data rows must return the existing explicit rowless failure.
- **FR-B039-012:** Every valid data row must emit exactly one extraction record.
- **FR-B039-013:** Summary accounting must sum emitted data records without compensating offsets.
- **FR-B039-014:** Multiple valid Test Plan tables across multiple scopes must aggregate exactly.
- **FR-B039-015:** The parser must remain compatible with Bash 3.2 hosts and GNU/BSD userlands.
- **FR-B039-016:** The change must remain surgical and preserve unrelated active changes.

## Success Criteria

- The isolated pre-fix fixture reproduces the 28-for-24 defect or establishes a more precise canonical-source divergence.
- Focused selftest proves zero contribution from headers and separators.
- Focused selftest proves 24 genuine rows aggregate to 24 across four scope tables.
- Focused selftest proves each genuine row is emitted once.
- Focused selftest covers all three supported path-heading aliases and both required heading families.
- Focused selftest proves an unlisted path-heading alias fails instead of expanding the contract.
- Focused selftest proves missing, empty, invalid, delayed, and wrong-width separators fail explicitly.
- Focused selftest proves wrong-width data rows and empty required cells fail explicitly.
- Focused selftest proves non-table content and headings terminate contiguous data rows.
- Focused selftest proves a second table in one Test Plan section fails explicitly.
- Focused selftest proves a recognized table with no valid data rows retains its explicit rowless failure.
- Only the parser, its focused selftest, and BUG-039 packet files change for this repair.
