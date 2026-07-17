# Bug: BUG-021 Framework Validate Raw Timeout

## Summary

`framework-validate.sh` invokes raw `timeout` for two registered selftests even
though the framework already ships `bubbles_run_with_timeout`; the exact
portability scan therefore fails and a base macOS system path has no watchdog
fallback when neither `timeout` nor `gtimeout` exists.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - Canonical validation and downstream release readiness are blocked
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status

- [x] Reported
- [x] Confirmed (reproduced)
- [ ] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reproduction Steps

1. Use the canonical Bubbles source checkout.
2. Run BUG-019's exact portability surface:
   `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh`.
3. Observe class 1 report raw `timeout` at the macOS portability selftest and
   workflow planning provenance selftest registrations.
4. Observe the scan exits `1` even though the other 12 construct classes are
   clean.

## Expected Behavior

Framework-owned deadlines must route through the shipped portable helper. The
same validation script must work when GNU `timeout` exists, when only
`gtimeout` exists, and when neither exists and the watchdog fallback is needed.
An exact portability scan of the changed framework file must pass.

## Actual Behavior

`framework-validate.sh` does not source `guard-lib.sh`. It directly passes raw
`timeout` to `run_check` at the two deadline-bearing registrations. Its PATH
shim can alias `gtimeout` only when that optional binary is installed; it does
not supply the helper's Bash watchdog fallback. The mechanical scanner correctly
reports both raw call sites and exits `1`.

## Environment

- Component: `bubbles/scripts/framework-validate.sh`
- Portable helper: `bubbles/scripts/guard-lib.sh`
- Scanner: `bubbles/scripts/macos-portability-guard.sh`
- Reporter: BUG-019 independent row `T-BUG-019-07`
- Platform: macOS
- Observed: 2026-07-15 local / 2026-07-16 UTC

## Error Output

```text
FAIL macOS-portability violation -- class-1 raw-timeout
bubbles/scripts/framework-validate.sh:190:run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout ...
bubbles/scripts/framework-validate.sh:292:run_check "Workflow planning provenance selftest" timeout ...
remedy: route through bubbles_run_with_timeout (guard-lib.sh); preserve exit 124
```

Full current-session evidence is in
[report.md](report.md#bug-reproduction---before-fix).

## Root Cause

IMP-018 introduced a PATH compatibility shim and intentionally exempted the
framework's own scripts from whole-tree scanning. Two later/current
registrations still use the raw binary contract rather than the already-shipped
portable helper contract. That assumption is narrower than the declared
macOS/WSL policy: it requires an optional GNU binary, is mechanically visible
as forbidden raw syntax, and has no watchdog fallback on base macOS.

## Deduplication

- `improvements/IMP-018-macos-portability-guard.md` documents the scanner and
  the intentional framework exemption, but it is an improvement record, not an
  active bug packet, and it does not remediate these exact calls.
- `improvements/BUG-013-g028-sensitive-client-storage-classification` owns raw
  timeout calls in its scanner selftest runners, not `framework-validate.sh`.
- BUG-018 and BUG-019 both record these two lines as foreign findings and leave
  their source outside their change boundaries.
- No other active BUG packet in `improvements/` owns the two registrations.
  This checkout has no `specs/` directory, and `BUGS.md` has no matching active
  record.

## Change Boundary

Future implementation may change only:

- `bubbles/scripts/framework-validate.sh` to consume the existing portable
  timeout helper at the two deadline-bearing registrations;
- one dedicated source-only regression, reserved as
  `tests/regression/test_28_framework_validate_portable_timeout.sh`;
- the directly corresponding focused selftest/registration, install provenance
  assertion, and generator-owned release metadata; and
- this BUG-021 packet plus direct bug-index documentation if required by its
  owning documentation phase.

Excluded from this bug:

- weakening `macos-portability-guard.sh`, adding `portable-ok` to conceal these
  calls, or changing `guard-lib.sh` when its existing helper contract suffices;
- changing BUG-012, BUG-013, BUG-018, BUG-019, IMP-020, or BUG-019 `test_26`;
- changing selftest behavior beyond replacing the invocation transport;
- requiring Homebrew/MacPorts coreutils, adding a bypass, or dropping timeout
  protection; and
- editing downstream installed files or generated release metadata by hand.

## Related

- Reporter: `improvements/BUG-019-state-transition-spec-mjs-path`
- Prior design context: `improvements/IMP-018-macos-portability-guard.md`
- Portable helper contract: `skills/bubbles-cross-platform-shell/SKILL.md`

## Deferred Reason

This invocation is documentation-only by operator request. No source, test,
release, certification, or foreign packet byte was changed. The packet remains
nonterminal and routes first to `bubbles.design`, then `bubbles.plan`, before
any implementation owner may act.
