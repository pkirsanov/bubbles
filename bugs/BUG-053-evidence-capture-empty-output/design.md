# BUG-053 Design - Portable Scalar Line Counting

## Root Cause Analysis

### Investigation Summary

The BUG-051 report records valid empty child output. The formatter emits the
empty digest, then reports arithmetic syntax errors at both branches that
compare the line count.

The formatter currently assigns `total` with a command substitution that runs
`grep -c ''` and appends `printf '0'` when grep returns nonzero. GNU and BSD
grep both print a zero count for an empty file and return 1 because no input
line matched.

### Root Cause

The formatter treats grep's no-match status as if grep produced no count.
However, grep already wrote `0`. The fallback writes another `0` into the same
command substitution. This creates the multiline string `0\n0`.

The hash path is correct for a present zero-byte file. The child exit path is
also independent and preserved in the reproduced success case.

### Impact Analysis

- **Affected component:** compact evidence formatter line-count metadata.
- **Affected data:** valid command captures with zero output bytes.
- **Affected users:** framework and downstream users who capture quiet commands.
- **Safety boundary:** a missing capture file must still fail before formatting.

## Fix Design

### Solution Approach

Replace the grep-plus-fallback line counter with one portable operation that
always prints exactly one numeric scalar. The narrow candidate is:

```bash
total="$(awk 'END { print NR + 0 }' <"$tmp")"
```

POSIX awk reports `0` for an empty file and counts non-empty logical lines with
`NR`. It does not use no-match status as control flow. Keep the existing file
existence check, hash calculation, rendering branches, and exit propagation.

Add persistent cases beside the existing evidence-capture selftests. Capture
the RED result before changing production source.

### Persistent Regression Design

1. Run an empty-output child that exits zero.
2. Require wrapper exit zero and formatted `exit: 0`.
3. Require exactly one `lines:` field and exact value `lines: 0`.
4. Require the SHA-256 empty digest.
5. Reject arithmetic syntax and error-token diagnostics.
6. Repeat the same formatting assertions with an empty-output child that exits seven.
7. Require wrapper exit seven and formatted `exit: 7`.
8. Retain the one-line short-output case.
9. Retain case 16 for capture-file disappearance.

The empty-output cases are load-bearing. Restoring the current grep expression
must make them fail because the line metadata becomes multiline and arithmetic
diagnostics return.

### Portability Contract

- Use the system awk behavior shared by GNU and BSD userland.
- Do not add GNU-only flags.
- Do not detect the operating system.
- Run the focused selftest under the canonical framework PATH posture.
- Run the shell portability checks required by the source repository.

### Alternative Approaches Considered

1. **Keep grep and append `true`.** Rejected because line data would still depend on grep's no-match status contract.
2. **Special-case empty files with `-s`.** Rejected because it adds a branch where one scalar counter is sufficient.
3. **Use `wc -l` plus whitespace normalization.** Rejected because normalization adds more machinery than the awk scalar.
4. **Change arithmetic comparisons to tolerate multiline input.** Rejected because it hides malformed metadata instead of fixing its source.
5. **Reuse BUG-035 missing-file handling.** Rejected because a present empty file is valid and hashable.

## Complexity Tracking

None - one portable scalar counter plus focused persistent cases is the simplest viable repair.
