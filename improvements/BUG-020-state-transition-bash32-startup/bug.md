# Bug: BUG-020 State Transition Bash 3.2 Startup

## Summary

The production state-transition guard aborts while sourcing `fun-mode.sh` under
macOS system Bash 3.2, before any transition check can run, because the optional
fun-mode catalog is initialized with Bash-4-only associative-array syntax.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - A blocking framework guard cannot start on the declared macOS shell baseline
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

1. Use the canonical Bubbles source checkout on macOS.
2. Remove Homebrew and MacPorts tools from the child process environment by
   selecting only `/usr/bin:/bin:/usr/sbin:/sbin`.
3. Invoke the existing BUG-019 production-path regression with `/bin/bash`:
   `/usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`.
4. Observe all four production-guard fixtures exit before the Check 8 banner.

## Expected Behavior

`state-transition-guard.sh` must start under the repository's macOS system-Bash
baseline whether optional fun mode is enabled or disabled. A disabled optional
presentation layer must not prevent governance checks from executing.

## Actual Behavior

`state-transition-guard.sh` enables `set -u` and unconditionally sources
`fun-mode.sh` before `guard-lib.sh` or any transition check. macOS Bash 3.2
cannot initialize the associative `_FUN_MESSAGES` catalog. Expansion of the
first key is therefore interpreted as an ordinary indexed-array subscript, and
`set -u` reports `gate_passed: unbound variable`. The guard exits `1` before
`--- Check 8: Test File Existence ---`.

## Environment

- Component: `bubbles/scripts/state-transition-guard.sh`
- Dependency: `bubbles/scripts/fun-mode.sh`
- Consumer: `tests/regression/test_26_state_transition_spec_mjs_path.sh`
- Shell: macOS `/bin/bash` 3.2.57 under a system-only `PATH`
- Platform: macOS
- Observed: 2026-07-15 local / 2026-07-16 UTC

## Error Output

```text
~/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 baseline exit=1 ---
FAIL: baseline reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
```

Full current-session evidence is in
[report.md](report.md#bug-reproduction---before-fix).

## Root Cause

The mandatory guard entrypoint loads an optional presentation module before its
portable helpers and before any behavior gate. That module eagerly declares an
associative array and later uses namerefs, both unavailable in macOS system Bash
3.2. No version/capability boundary protects the source operation. The failure
occurs even with fun mode disabled because catalog initialization is eager.

## Deduplication

- `improvements/BUG-019-state-transition-spec-mjs-path` is the reporter. Its
  owned Check 8 repair is green under modern Bash, and its independent test
  explicitly classifies this startup abort as foreign `TEST-019-003`.
- `improvements/BUG-018-traceability-test-plan-heading-depth` is related but not
  an owner. It adds Bash-3.2 no-op hooks inside `traceability-guard.sh` and its
  design explicitly says to keep `fun-mode.sh` unchanged.
- No other active BUG packet in `improvements/` owns `fun-mode.sh` startup or
  state-transition Bash-3.2 compatibility. This checkout has no `specs/`
  directory, and `BUGS.md` has no matching active record.

## Change Boundary

Future implementation may change only:

- `bubbles/scripts/state-transition-guard.sh` and/or
  `bubbles/scripts/fun-mode.sh` at the capability boundary;
- one dedicated source-only regression, reserved by this packet as
  `tests/regression/test_27_state_transition_bash32_startup.sh`;
- the directly corresponding managed selftest, framework registration, install
  provenance assertion, and generator-owned release metadata; and
- this BUG-020 packet plus direct bug-index documentation if its owner requires
  an index entry.

Excluded from this bug:

- changing Check 8 extraction or `test_26` behavior owned by BUG-019;
- changing BUG-012, BUG-013, BUG-018, BUG-019, or IMP-020 artifacts;
- changing traceability parsing, unrelated fun text, release-train config,
  downstream installed framework bytes, or generated metadata by hand; and
- adding a Homebrew/coreutils prerequisite, bypass flag, or test-only PATH shim
  as the production fix.

## Related

- Reporter: `improvements/BUG-019-state-transition-spec-mjs-path`
- Related but non-owning: `improvements/BUG-018-traceability-test-plan-heading-depth`
- Portability doctrine: `skills/bubbles-cross-platform-shell/SKILL.md`

## Deferred Reason

This invocation is documentation-only by operator request. No source, test,
release, certification, or foreign packet byte was changed. The packet remains
nonterminal and routes first to `bubbles.design`, then `bubbles.plan`, before
any implementation owner may act.
