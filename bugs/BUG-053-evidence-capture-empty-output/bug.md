# Bug: BUG-053 Evidence Capture Empty Output Line Count Duplication

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `F-B051-EVIDENCE-EMPTY-OUTPUT-002`
- **Affects:** `bubbles/scripts/evidence-capture.sh` and `bubbles/scripts/evidence-capture-selftest.sh`

## Summary

Evidence capture stores `0\n0` as the line count for a valid empty capture.
Later numeric comparisons emit arithmetic syntax errors even when the child
command exits successfully.

## Packet Route

The formatter ships to every downstream installation and protects execution
evidence. This defect therefore uses a full source bug packet and routes through
persisted `bugfix-fastlane`.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - canonical evidence output is malformed for a valid command result
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Existing reproduction record linked from BUG-051
- [x] Root-cause hypothesis grounded by current source inspection
- [ ] Persistent RED regression captured
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Run `evidence-capture.sh` around a child that writes nothing and exits zero.
2. Observe the formatted `lines:` field and the wrapper exit.
3. Inspect stderr for arithmetic diagnostics from the numeric branches.
4. Repeat with an empty-output child that exits nonzero.
5. Confirm both wrappers preserve their child exits.

The existing BUG-051 report records step 1 through step 3 for the zero-exit
case. This filing invocation did not rerun either case.

## Expected Behavior

- The formatter emits exactly one `lines: 0` field.
- The field contains one numeric scalar.
- The formatter emits the SHA-256 digest of the empty byte stream.
- The formatter emits no arithmetic syntax diagnostic.
- The wrapper preserves child exit zero and child exit nonzero.

## Actual Behavior

The formatter prints a valid `lines: 0` field followed by a stray `0`. It then
emits arithmetic syntax errors at the short-output and diagnostic comparisons.
The reproduced zero-exit child still returns zero.

## Root Cause Hypothesis

The line-count command combines data output and fallback control flow:

```bash
total="$(grep -c '' <"$tmp" 2>/dev/null || printf '0')"
```

For an empty file, grep prints `0` and returns 1. The fallback prints a second
zero into the same command substitution. `total` becomes a two-line value.
Arithmetic comparisons require one numeric scalar and reject `0\n0`.

The persistent empty-output test can disconfirm this hypothesis. It must show
that unchanged production already emits one clean scalar for both child exits.

## Impact

- Valid empty output produces malformed evidence framing.
- Arithmetic diagnostics can be mistaken for child-command failures.
- A successful child can return zero while its evidence block reports shell errors.
- Empty-output evidence cannot be treated as clean canonical formatter output.

## Environment

- Repository: canonical Bubbles source worktree
- Platform: macOS
- Discovery source: independent BUG-051 test-phase evidence
- Filing authority: command-level repository decision revision 3

## Scope Boundary

### Included

- Scalar line counting for a valid zero-byte capture
- Empty-output child exit zero
- Empty-output child exit nonzero
- Exact SHA-256 empty digest
- Arithmetic-diagnostic exclusion
- Non-empty output compatibility
- BUG-035 D14 capture-file disappearance regression preservation
- Generated release manifest refresh after implementation

### Excluded

- Capture-file lifecycle redesign
- Process-group or signal handling changes
- Hash algorithm changes
- Evidence receipt schema changes
- Editing BUG-035 or BUG-051 artifacts
- Downstream product artifact changes
- Production or selftest edits during filing

## Distinction From BUG-035 D14

BUG-035 D14 covers a capture path that disappears while the child runs. The
formatter must fail loud because it cannot hash the missing file.

BUG-053 covers a capture path that still exists and correctly contains zero
bytes. The empty digest is valid. Only the line-count scalar is malformed.

## Related

- [`BUG-051 report evidence-capture finding`](../BUG-051-yaml-validator-downstream-root/report.md#evidence-capture-empty-output-finding)
- [`BUG-035 D14`](../BUG-035-validation-control-plane-churn-and-scope-overreach/bug.md#defect-inventory)
- `bubbles/scripts/evidence-capture-selftest.sh` case 16 protects missing capture files.

## Filing Evidence

**Claim Source:** interpreted

The cited BUG-051 report and formatter source were read in this invocation. The
existing reproduction remains inherited execution evidence. No RED test was
added or run during filing.
