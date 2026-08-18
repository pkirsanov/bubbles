# Bug: BUG-036 Completed Scopes Count Is Format Sensitive

- **Filed:** 2026-08-18
- **Severity:** high
- **Disposition:** open framework defect
- **Registry update:** intentionally excluded by operator instruction
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, Check 5

## Summary

Check 5 counts lines containing quoted values instead of parsing the
`completedScopes` JSON array. A valid compact string-ID array is undercounted
because several entries on one physical line count as one.

## Packet Route

The fix changes a shared downstream guard verdict. It adds observable behavior
and has cross-repository effect. The bug therefore uses a full packet.

The source registry does not declare root bug packets, but the operator
explicitly requested new files and prohibited a `BUGS.md` update. BUG-035 D7
owns that separate packet-contract contradiction.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - valid certification can be blocked as a fabrication failure
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Controlling parser confirmed by current-session source read
- [x] Executable pre-fix regression captured
- [x] Focused fix implemented
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Create a valid version 3 `state.json` with three completed scope IDs.
2. Store the three quoted IDs on one physical line.
3. Mark three corresponding scope artifacts `Done`.
4. Run `state-transition-guard.sh` against the packet.
5. Observe Check 5 count one entry instead of three.

## Expected Behavior

Check 5 must count string-ID array entries independent of whitespace and line
breaks. A populated ordinal array must remain a distinct wrong-element-type
failure, never an empty array. Check 5C remains responsible for mapping string
identifiers to real artifacts.

## Actual Behavior

The guard captures array text and runs `grep -cE '"[^"]+"'`. `grep -c` counts
matching lines. It does not count array entries.

## Root Cause

The guard uses text processing for structured JSON. Its result depends on
serialization layout rather than the parsed array.

Every existing positive fixture serializes quoted entries in the shape the text
scan expects. No adversarial fixture places several valid IDs on one line.

## Impact

- Valid packets can be blocked from transition.
- A false count mismatch can allege state-integrity or fabrication failure.
- Authors may reformat valid JSON to satisfy a parser accident.
- Every downstream repository that installs the guard is affected.

## Environment

- Repository: Bubbles source repository
- Platform: Linux under VS Code
- Discovery context: GuestHost transition validation

## Scope Boundary

### Included

- Structured completed-scope counting
- Certification-first and legacy top-level array precedence
- Compact-array adversarial fixture
- Existing ordinal wrong-element-type regression
- Existing phantom-scope validation
- Release-manifest regeneration

### Excluded

- Changing the completed-scope schema
- Accepting phantom scope identifiers
- Modifying downstream state files
- Editing `BUGS.md`
- Changing certification ownership

## Related

- `bugs/BUG-035-validation-control-plane-churn-and-scope-overreach/` D3 records
  the broader duplicated-lifecycle cost.
- GuestHost historical reports describe the same false-empty parser symptom.

## Deferred Reason

The structured parser fix and focused regression are complete. Full framework
and release validation remain pending. No terminal or certified claim is made.