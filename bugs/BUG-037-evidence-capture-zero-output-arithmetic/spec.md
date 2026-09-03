# BUG-037 Expected Behavior — Zero-Output Evidence Capture

## Outcome Contract

- **Intent**: Make zero-output evidence blocks canonical and trustworthy for successful and failing child commands.
- **Success Signal**: Both zero-output child classes report `lines: 0` and the empty-stream SHA-256 without arithmetic diagnostics. Normal and verify modes preserve their documented exit contracts.
- **Hard Constraints**:
	- Preserve the child status in normal mode.
	- Preserve verify exits zero for a matching digest and three for a mismatch.
	- Keep non-empty, bounded, failure-extraction, timeout, signal, and descendant-cleanup behavior unchanged.
	- Cover every captured output byte with the reported digest, including bytes omitted from bounded display.
	- Never discard child output or invent command, exit, line-count, digest, or diagnostic metadata.
- **Failure Condition**: The repair fails if zero output produces malformed metadata or diagnostics. It also fails if any preserved behavior or full-output hash coverage changes.

### Non-Goals

- Change the bounded display policy or failure-line extraction policy.
- Change timeout, signal, process-group, descendant-cleanup, or capture-file-loss semantics.
- Change the evidence receipt schema or broaden the helper refactor beyond canonical line counting.

## Required Behavior

- A successful child with zero output produces `lines: 0`.
- A failing child with zero output also produces `lines: 0`.
- Both cases produce the SHA-256 of the empty byte stream.
- Neither case emits an arithmetic diagnostic.
- Normal mode exits with the child status according to the existing helper contract.
- Verify mode exits zero for a matching digest and exits three for a mismatch.
- Non-empty short, bounded, diagnostic, interrupted, and descendant-cleanup behavior remains unchanged.

## Scenarios

### SCN-B037-001 — Successful zero-output child

```gherkin
Given a child command exits zero and writes no stdout or stderr
When evidence capture formats the result
Then it reports zero lines and the empty-stream hash
And it emits no arithmetic diagnostic
And the helper exits zero
```

### SCN-B037-002 — Failing zero-output child

```gherkin
Given a child command exits nonzero and writes no stdout or stderr
When evidence capture formats the result
Then it reports zero lines and the empty-stream hash
And it emits no arithmetic diagnostic
And the helper exits with the child status
```

### SCN-B037-003 — Empty-output verification

```gherkin
Given the recorded digest is the empty-stream hash
When verify mode reruns a zero-output command
Then a matching run exits zero
And a changed-output run exits three
```

### SCN-B037-004 — Non-empty behavior is unchanged

```gherkin
Given existing non-empty capture fixtures
When the focused selftest runs after the fix
Then short and bounded output formatting remains unchanged
And child, signal, and verify exit contracts remain unchanged
```

## Acceptance Criteria

- The line count is one canonical base-ten integer.
- Empty output never reaches arithmetic comparison as a duplicated or malformed scalar.
- Focused tests prove both zero-output exit classes.
- An adversarial non-empty case proves the fix is not an empty-only shortcut that changes existing formatting.
- Full validation and release readiness remain required before certification.
