# BUG-053 Expected Behavior - Valid Empty Evidence Capture

## Outcome Contract

- **Intent:** Format valid empty child output without corrupting evidence metadata.
- **Success Signal:** Empty captures emit one numeric zero count, the empty digest, no arithmetic error, and the original child exit.
- **Hard Constraints:** Missing-file failure remains distinct. Non-empty line counting remains unchanged. The implementation works with GNU and BSD userland.
- **Failure Condition:** Empty output creates a multiline count, emits shell diagnostics, changes the digest, or masks the child exit.

## Actors

- **Evidence producer:** runs a command through the canonical formatter.
- **Evidence reviewer:** reads the exit, line count, digest, and retained output.
- **Downstream repository:** consumes the installed formatter unchanged.

## User Scenarios

### Scenario 1 - Empty successful output is formatted cleanly

```gherkin
Given a child command writes zero bytes to stdout and stderr
And the child exits zero
When evidence capture formats the result
Then it emits exactly one numeric lines field with value zero
And it emits the SHA-256 digest of the empty byte stream
And it emits no arithmetic syntax diagnostic
And it returns zero
```

### Scenario 2 - Empty failing output preserves the child exit

```gherkin
Given a child command writes zero bytes to stdout and stderr
And the child exits seven
When evidence capture formats the result
Then it emits exactly one numeric lines field with value zero
And it emits the SHA-256 digest of the empty byte stream
And it emits no arithmetic syntax diagnostic
And it returns seven
```

### Scenario 3 - Non-empty counting remains compatible

```gherkin
Given a child command writes one line
When evidence capture formats the result
Then it emits exactly one lines field with value one
And it preserves the existing short-output rendering
```

### Scenario 4 - Missing capture output still fails loud

```gherkin
Given the capture output path disappears while the child runs
When evidence capture verifies the capture file
Then it exits two with the concrete disappearance diagnostic
And it does not emit an empty evidence hash
```

## Functional Requirements

- **FR-B053-001:** A valid zero-byte capture must produce one `lines:` field.
- **FR-B053-002:** The field value must be the numeric scalar `0`.
- **FR-B053-003:** A valid zero-byte capture must produce `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
- **FR-B053-004:** Empty capture formatting must emit no arithmetic diagnostic.
- **FR-B053-005:** The wrapper must preserve child exit zero.
- **FR-B053-006:** The wrapper must preserve a nonzero child exit.
- **FR-B053-007:** Non-empty line counting and rendering must retain current behavior.
- **FR-B053-008:** Missing capture files must retain the BUG-035 D14 failure contract.
- **FR-B053-009:** Line counting must not depend on grep's empty-match exit status.
- **FR-B053-010:** The repair must use behavior available under GNU and BSD userland.

## Acceptance Criteria

- SCN-B053-001 returns zero and emits one `lines: 0` plus the empty digest.
- SCN-B053-002 returns seven and emits one `lines: 0` plus the empty digest.
- Neither empty-output scenario contains `arithmetic syntax error` or an arithmetic error token.
- SCN-B053-003 retains one-line short-output behavior.
- SCN-B053-004 retains the existing missing-file refusal.
- The focused selftest and full framework validation pass after the fix.
