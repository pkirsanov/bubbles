# BUG-039 Scopes

## Execution Outline

### Phase Order

1. **Scope 1 — Deterministic contiguous Test Plan extraction:** capture a focused G060 red proof, then implement and verify the five preserved scenario contracts in the standalone traceability parser and its focused persistent regression selftest.

### New Types and Signatures

- No public type, file-format, or CLI signature changes.
- Preserve extraction records as `path<TAB>semantic text`.
- Preserve exact section headings `## Test Plan` and `### Test Plan`.
- Preserve canonical `ID`, `Type`, and exactly one supported path heading.
- Preserve legacy `Test Type` and exactly one supported path heading.
- Keep path headings closed to `File/Location`, `File / Surface`, and `Persistent file and exact title`.
- Enforce recognized header, immediate same-width all-valid separator, and contiguous same-width data rows.
- Require every recognized canonical or legacy table to emit at least one valid data row.
- Fail with parser status `4`, one stable failure class, and one visible line number for every malformed structure, empty required cell, rowless recognized table, and second table in the section.
- Keep parser diagnostics distinct from the outer guard's existing `Test Plan extraction failed` context.

### Validation Checkpoints

- A focused pre-fix selftest case that fails for the revised contract is the G060 red checkpoint. Its command, nonzero status, and failure output must be captured before source repair.
- The focused selftest is the green checkpoint for each scenario after source repair.
- The active-shell syntax check is a narrow parse check only. It does not prove Bash 3.2 or GNU/BSD portability.
- Source review must separately confirm no Bash 4-only construct or GNU/BSD-specific table classifier was added.
- Planning-only artifact, scenario, traceability, obligation, mechanism, G028, and G070 checks validate this packet without running source tests or global validation.

## Active Scope Inventory

| # | Scope | Depends On | Scenario Coverage | Status |
| --- | --- | --- | --- | --- |
| 1 | Deterministic contiguous Test Plan extraction | — | SCN-B039-001 through SCN-B039-005 | In Progress |

## Scope 1: Deterministic contiguous Test Plan extraction

**Status:** In Progress

**Scope-Kind:** contract-only

**Depends On:** None

### Outcome

Standalone traceability emits exactly one record per valid data row from one recognized contiguous Test Plan table. It emits no structural rows and fails explicitly when the final table grammar is violated.

### Gherkin Scenarios

#### SCN-B039-001 - Structural rows do not count

```gherkin
Scenario: Structural rows do not count
Given a Test Plan section has one recognized header
And the next visible line is a same-width non-empty valid Markdown separator
When standalone traceability extracts the table
Then neither structural row contributes to the test-row total
```

#### SCN-B039-002 - Genuine rows count exactly once across tables

```gherkin
Scenario: Genuine rows count exactly once across tables
Given four scopes each contain one contiguous Test Plan table
And each table contains six distinct TP-028 data rows
When standalone traceability runs across all scopes
Then each genuine row counts once
And the aggregate total is exactly 24
```

#### SCN-B039-003 - Closed heading families remain compatible

```gherkin
Scenario: Closed heading families remain compatible
Given one Test Plan uses ID, Type, and Persistent file and exact title
And one Test Plan uses ID, Type, and File / Surface
And one Test Plan uses Test Type and File/Location
When standalone traceability extracts each table
Then every table's genuine rows remain traceable
And no unlisted path-heading alias is accepted
```

#### SCN-B039-004 - Malformed structure and data fail loudly

```gherkin
Scenario: Malformed structure and data fail loudly
Given a recognized Test Plan table has a missing, empty, invalid, delayed, or wrong-width separator
Or its contiguous data rows contain a wrong-width row or an empty required cell
When standalone traceability extracts the table
Then extraction fails explicitly
And invalid content is not silently omitted from accounting
```

#### SCN-B039-005 - Table boundaries and duplicate tables fail deterministically

```gherkin
Scenario: Table boundaries and duplicate tables fail deterministically
Given a recognized Test Plan table has started emitting contiguous data rows
When a non-table line or any heading appears
Then the current table ends
And a later Markdown table in the same Test Plan section fails explicitly as a second table
```

### Implementation Plan

1. Keep visible-line preprocessing, pipe-aware cell tokenization, and extraction formatting inside `extract_test_rows`.
2. Recognize only canonical `ID` plus `Type` or legacy `Test Type`, each with exactly one path heading from the closed three-heading set.
3. Require the separator on the next visible line, at header width, with no empty cells and only valid Markdown separator cells.
4. Emit no header or separator record. Emit each immediately following contiguous valid data row once in source order.
5. Require every data row to match header width and every applicable canonical or legacy required cell to be non-empty.
6. Route every structural status-`4` branch through one diagnostic helper. Do not leave any bare `SystemExit(4)` branch. Emit one deterministic failure class and the applicable visible line number, including section-boundary and end-of-file failures.
7. Return rowless parser status `4` whenever a recognized table reaches blank text, prose, a deeper heading, the section boundary, or end of file before its first valid data row.
8. Detect and refuse a second Markdown table while in `READ_ROWS` and while in `DONE`. Report the second header's visible line and never emit or validate its data rows.
9. End data emission at blank text, prose, or any heading. Continue inspection only through the selected section's equal-or-shallower heading boundary or end of file. Do not inspect content beyond that section boundary.
10. Preserve parser statuses `3` and `5` for missing and multiple exact Test Plan headings. Preserve a clean zero-record parser result only when no recognized header candidate exists. Keep parser failure text distinct from the outer guard failure.
11. Keep summary arithmetic as a direct count of emitted records, without offsets or compensating subtraction.
12. Add positive controls for both heading families and all three exact path headings, plus adversarial controls for every malformed, diagnostic, state, boundary, and end-of-file case.
13. Before source repair, run the focused selftest against a targeted revised-contract case and retain its expected nonzero result as G060 red evidence. After repair, rerun the focused selftest as green evidence.
14. Run only the focused regression and narrow active-shell syntax check for source verification. Do not run global validation in this scope invocation.

### Scenario Obligation and Implementation Mapping

| Scenario | Behavior Traits | Obligations | Implementation Refs |
| --- | --- | --- | --- |
| SCN-B039-001 | `pure-calculation` | Persistent regression proves structural rows emit zero records and valid rows remain countable. | `bubbles/scripts/traceability-guard.sh::extract_test_rows`; focused cases in `bubbles/scripts/traceability-guard-selftest.sh` |
| SCN-B039-002 | `pure-calculation` | G060 red proof precedes repair; persistent aggregate regression proves exactly 24 emitted records with no duplicate identity. | `extract_test_rows`; standalone summary accumulator; focused four-table fixture |
| SCN-B039-003 | `static-metadata`, `degraded-state` | Persistent compatibility and rejection cases prove the closed canonical, legacy, and path-heading vocabularies. | Header-candidate normalization and grammar selection in `extract_test_rows`; focused alias fixtures |
| SCN-B039-004 | `degraded-state` | Every structural status-`4` path has a deterministic parser diagnostic and visible line; parser and outer-guard failures remain separately observable. | Structural-failure helper and `EXPECT_SEPARATOR`/`READ_ROWS` terminal branches; focused stderr/status assertions |
| SCN-B039-005 | `degraded-state` | Persistent cases cover blank, prose, deeper/equal/shallower heading, section-boundary, and EOF transitions; second tables fail in both `READ_ROWS` and `DONE`. | `READ_ROWS`/`DONE` transitions and bounded lookahead in `extract_test_rows`; focused boundary fixtures |

### Change Boundary

**Allowed implementation files:** `bubbles/scripts/traceability-guard.sh` and `bubbles/scripts/traceability-guard-selftest.sh`.

**Allowed planning files:** this BUG-039 `spec.md`, `scopes.md`, `scenario-manifest.json`, `test-plan.json`, `state.json`, and `report.md`.

**Excluded:** BUG-039 `design.md` and `uservalidation.md`; BUG-037; BUG-038; receipt identity; execution control; state transition; release-train metadata; generated files; `BUGS.md`; downstream repositories; source or test edits during planning reconciliation; global validation; staging; commits; pushes; and session-control advancement.

### Implementation Files

- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`

### Test Plan

| ID | Scenario | Type | File / Surface | Exact Command | Expected Proof |
| --- | --- | --- | --- | --- | --- |
| TP-B039-01 | SCN-B039-001 | Persistent structural-row regression | `bubbles/scripts/traceability-guard-selftest.sh` | `timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` | A recognized header and immediate same-width all-valid separator emit zero structural records; valid data rows still emit once. |
| TP-B039-02 | SCN-B039-002 | G060 red-before-green exact-aggregate regression | `bubbles/scripts/traceability-guard-selftest.sh` | `timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` | Before source repair, a targeted revised-contract assertion fails nonzero and its output is retained. After repair, four six-row tables emit exactly 24 records, with every TP-028 identity observed once. The red evidence must predate the green evidence. |
| TP-B039-03 | SCN-B039-003 | Persistent closed-vocabulary regression | `bubbles/scripts/traceability-guard-selftest.sh` | `timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` | Both exact heading families and all three exact path headings pass; unlisted, duplicate, partial, and mixed headers return parser status `4` with stable diagnostics. |
| TP-B039-04 | SCN-B039-004 | Persistent malformed, rowless, and failure-layer regression | `bubbles/scripts/traceability-guard-selftest.sh` | `timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` | Missing, empty, invalid, delayed, narrow, and wide separators; malformed-width rows; empty required cells; and blank, prose, deeper-heading, section-boundary, and EOF rowless terminals return parser status `4`, a stable failure class, and the correct visible line before invalid emission. Parser diagnostics remain distinct from the outer `Test Plan extraction failed` failure, and no structural path uses a bare status-only exit. |
| TP-B039-05 | SCN-B039-005 | Persistent state-boundary and second-table regression | `bubbles/scripts/traceability-guard-selftest.sh` | `timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` | Exact blank/prose/deeper-heading/equal-or-shallower-section/EOF behavior is covered; adjacent and separated second tables fail at their visible header line in `READ_ROWS` and `DONE`, and no second-table row emits. |
| TP-B039-06 | Cross-cutting parser verification | Active-shell syntax and portability review | `bubbles/scripts/traceability-guard.sh`; `bubbles/scripts/traceability-guard-selftest.sh` | `timeout 30 bash -n bubbles/scripts/traceability-guard.sh && timeout 30 bash -n bubbles/scripts/traceability-guard-selftest.sh` | Files parse under active Bash. Separate source review confirms the changed classifier remains in Python and introduces no Bash 4-only or GNU/BSD-specific table-classification dependency; syntax alone does not prove Bash 3.2 portability. |

### Definition of Done

#### Implementation and Boundary Items

- [ ] The parser implements the exact headings, closed aliases, immediate same-width valid separator, contiguous rows, termination, second-table refusal, required-cell refusal, rowless refusal, and width refusal.
- [ ] Every recognized canonical or legacy Test Plan table contains at least one valid data row; blank, prose, heading, section-boundary, and EOF rowless terminals return parser status `4` with a stable diagnostic and visible line.
- [ ] Every structural status-`4` branch uses the shared deterministic diagnostic helper; no bare `SystemExit(4)` remains, and parser diagnostics remain distinct from outer guard failures.
- [ ] Summary accounting directly counts emitted valid records without a structural-row offset.
- [ ] The implementation stays within the declared boundary and excluded surfaces remain unchanged by BUG-039.
- [ ] Code Diff Evidence classifies every changed path and proves at least one allowed source or test path changed during implementation while every excluded path family stayed untouched. This item remains unchecked until implementation produces a real diff.

#### Test Plan Parity Items

- [ ] **TP-B039-01 / SCN-B039-001:** Structural rows emit zero records while valid data rows emit exactly once.
- [x] **TP-B039-02 / SCN-B039-002:** A focused G060 red run is captured before source repair with the exact failing assertion, nonzero status, and unmodified output; the later green run proves the four-table aggregate emits exactly 24 distinct data records. → Evidence: [report.md#g060-reconstructed-behavioral-red-green---2026-09-02](report.md#g060-reconstructed-behavioral-red-green---2026-09-02)

	**Phase:** implement

	**Claim Source:** executed

	**RED:** `BUG-039-G060-rowless-recognized-table-v1` ran against committed pre-fix revision `85429a1640e0da07e79849401497f06308d0078e` and exited `1` because the embedded parser silently returned status `0` instead of required status `4`.

	```text
	test_id=BUG-039-G060-rowless-recognized-table-v1
	scenario=recognized canonical Test Plan header plus valid separator reaches EOF before any data row
	expected_exit=4
	expected_diagnostic=ERROR: rowless recognized Test Plan table at visible line 7
	guard_sha256=7d9f9ee38da7f0f825ed4eeabd65a166ed5219b680bbc269d99b8793d74a3626
	parser_sha256=28dd524228de536414f23f8520f65ebf6bfc056e9d72f0bd466428c1eecd710c
	actual_exit=0
	actual_stdout=''
	actual_stderr=''
	status_assertion=FAIL
	diagnostic_assertion=FAIL
	silent_structural_status=YES
	result=RED revised rowless-table contract violated
	```

	**GREEN:** The identical probe then ran against current working source and exited `0`; the later persistent focused regression exited `0` with 439-line SHA-256 `46c27fbe26e93a28e4c386cdbe4851e2629a958d5ad32d5264f1a9afad57c882` and retained the exact 24-row assertion.

	```text
	test_id=BUG-039-G060-rowless-recognized-table-v1
	scenario=recognized canonical Test Plan header plus valid separator reaches EOF before any data row
	expected_exit=4
	expected_diagnostic=ERROR: rowless recognized Test Plan table at visible line 7
	guard_sha256=21adcf3dff77b832bf51bc2aee477869202ac2f9d85c419a16822cca23d84377
	parser_sha256=e8e3b2da06a4506f9c8b8eb68e44c08d1610248d4e85de15ba6347bd0d5e23a3
	actual_exit=4
	actual_stdout=''
	actual_stderr='ERROR: rowless recognized Test Plan table at visible line 7\n'
	status_assertion=PASS
	diagnostic_assertion=PASS
	silent_structural_status=NO
	result=GREEN revised rowless-table contract satisfied
	```
- [ ] **TP-B039-03 / SCN-B039-003:** Exact supported headings pass and unlisted, duplicate, partial, or mixed headings fail with deterministic parser diagnostics.
- [ ] **TP-B039-04 / SCN-B039-004:** Every specified malformed separator, malformed row, empty required-cell condition, and recognized-rowless terminal fails with parser status `4`, a stable failure class, and the correct visible line; parser and outer guard failures remain separately observable and no bare structural status-only exit remains.
- [ ] **TP-B039-05 / SCN-B039-005:** Exact section-boundary and EOF behavior passes, and second tables fail in `READ_ROWS` and `DONE` without contributing records.
- [ ] **TP-B039-06:** Syntax passes and portability review avoids inferring Bash 3.2 support from active-shell syntax alone.

#### Completion Gate

- [ ] All five scenarios have current-session evidence, all six Test Plan rows have matching evidence-backed DoD transitions, red evidence predates green evidence, and validate-owned certification permits closure.
