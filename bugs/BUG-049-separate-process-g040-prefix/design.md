# BUG-049 Design - Token-Bounded PR Deferral Matching

## Root Cause Analysis

### Investigation Summary

G040's `deferral_pattern` includes `separate PR` among unbounded alternatives.
The scan uses case-insensitive extended regular expressions. The abbreviation
therefore matches the prefix `pr` in `process`.

### Root Cause

The pattern treats an abbreviation as an ordinary phrase. Unlike a full word,
`PR` needs an explicit right token boundary. The complete `pull request` form is
also absent from this alternative.

### Impact Analysis

- **Affected component:** state transition Check 18, Gate G040.
- **Affected data:** scope and report prose outside excluded regions.
- **Affected users:** any repository describing process isolation.
- **Safety boundary:** actual pull-request deferrals must still block.

## Fix Design

### Solution Approach

Replace the ambiguous alternative with two complete forms:

- `separate[[:space:]]+PR` followed by a portable non-word or end boundary
- `separate[[:space:]]+pull[[:space:]]+request` followed by the same boundary

Keep the case-insensitive scan. Use POSIX ERE constructs supported by BSD and GNU
grep. Avoid `\b` if its portability differs across supported implementations.
A shape such as `([^[:alnum:]_]|$)` provides an explicit right boundary.

Do not add `separate process` to the exclusion list. The positive pattern should
be correct without a growing false-positive allowlist.

### Test Design

Add one negative fixture with `separate process`, plus uppercase and title-case
variants. Add positive fixtures for `separate PR`, `separate PR.`, and
`separate pull request`.

Run the same real transition guard path used by current G040 fixtures. Preserve
existing positive deferral and placeholder-admission controls.

### Alternative Approaches Considered

1. **Exclude `separate process`.** Rejected. It repairs one word while preserving every future `pr*` collision.
2. **Remove `separate PR`.** Rejected. Genuine deferral wording would pass.
3. **Use a case-sensitive scan.** Rejected. Existing G040 behavior is intentionally case-insensitive.
4. **Use Perl lookahead.** Rejected. The guard must remain portable across BSD and GNU environments.

## Complexity Tracking

None - two token-bounded alternatives are the smallest durable repair.
