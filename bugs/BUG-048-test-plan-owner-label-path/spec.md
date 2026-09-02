# BUG-048 Expected Behavior - Semantic Test Plan Path Extraction

## Outcome Contract

- **Intent:** Extract test files from declared Test Plan path cells only.
- **Success Signal:** Finding Accounting owner labels are inert, while valid bare and qualified test paths still resolve.
- **Hard Constraints:** Basename-only `.test` files remain supported. Missing files in actual path cells still block delivery.
- **Failure Condition:** Any non-Test-Plan metadata becomes a test path, or a legitimate path cell stops being checked.

## Actors

- **Planner:** writes Test Plan rows and Finding Accounting metadata.
- **Transition guard:** verifies planned test file existence.
- **Validation agent:** consumes the guard verdict without rewriting planning data.

## User Scenarios

### Scenario 1 - Owner labels outside Test Plan are inert

```gherkin
Given a scope has five Finding Accounting rows owned by bubbles.test
And its Test Plan cites one existing test file
When Check 8 extracts planned paths
Then only the Test Plan file is checked
And bubbles.test is never treated as a file
```

### Scenario 2 - Basename-only dot-test files remain valid

```gherkin
Given a Test Plan file cell contains smoke.test
And exactly one file with that basename exists in the repository
When Check 8 verifies file existence
Then it resolves the file uniquely
And it emits no missing-path failure
```

### Scenario 3 - A missing actual path still blocks

```gherkin
Given a Test Plan file cell names missing.test
And no matching file exists
When Check 8 verifies file existence
Then delivery completion is refused
```

### Scenario 4 - File-shaped metadata in another table stays inert

```gherkin
Given a non-Test-Plan table contains backticked values ending in supported test suffixes
When Check 8 scans the scope artifact
Then those values are not extracted
```

## Functional Requirements

- **FR-B048-001:** Check 8 must identify the Test Plan section before extracting paths.
- **FR-B048-002:** Check 8 must identify file or path columns from the Test Plan header.
- **FR-B048-003:** Extraction must stop when the Test Plan table or section ends.
- **FR-B048-004:** Backticked values in unrelated tables must remain inert.
- **FR-B048-005:** Existing bare, command-wrapped, compound MJS, and basename-only paths must remain supported.
- **FR-B048-006:** A missing path from a real Test Plan path cell must remain blocking.
- **FR-B048-007:** The implementation must not maintain a blacklist of agent labels.

## Acceptance Criteria

- SCN-B048-001 passes with five `bubbles.test` labels and one existing path.
- SCN-B048-002 resolves one legitimate `smoke.test` basename.
- SCN-B048-003 rejects one missing `missing.test` path.
- SCN-B048-004 ignores a second file-shaped metadata table.
- Existing Check 8 shell and MJS fixtures retain their verdicts.
