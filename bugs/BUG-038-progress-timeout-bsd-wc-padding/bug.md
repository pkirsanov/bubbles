# BUG-038: `bubbles_run_with_progress_timeout` aborts on the first poll on every BSD/macOS host

**Severity:** High
**Status:** Fixed
**Packet form:** compact (micro-fix)
**Component:** `bubbles/scripts/guard-lib.sh`
**Reported:** 2026-08-23
**Environment:** macOS (Darwin, arm64), BSD userland `wc`; bash 5.3.15 and bash 3.2.57 both reproduce

---

## Summary

`bubbles_run_with_progress_timeout` never enforced either of its two deadlines on a
BSD/macOS host. It returned `2` — its invalid-invocation code — one second into any
command that outlived the first poll. The function appeared to work only because a
command that exits before the first poll never reaches the broken branch.

## Root cause

BSD `wc` right-aligns its count in a fixed-width field; GNU `wc` does not. The polling
loop captured that count and tested it against `^[0-9]+$` without normalizing it:

```bash
current_size="$(wc -c 2>/dev/null < "$log_file")" || current_size=""
if [[ ! "$current_size" =~ ^[0-9]+$ ]]; then
  timeout_rc=2
  break
fi
```

Command substitution strips the TRAILING newline only. The leading pad survives, so on
BSD the capture is `"      12"`, the regex fails, `timeout_rc=2` is set, and the loop
breaks on iteration one — before `last_progress_at`, `idle_secs`, or `absolute_secs` is
ever consulted.

The root cause is the missing normalization, not the regex. The regex is the correct
guard for an unreadable log; it was simply being fed an un-normalized value.

Confirmed on this host:

```
raw wc -c output : [      12]
byte length      : 8
REGEX ^[0-9]+$   : DOES NOT MATCH  -> timeout_rc=2
after stripping  : [12]            -> matches
```

## Impact

Three contracted behaviors were inert on every BSD/macOS host:

| Contract | Expected | Actual before fix |
|---|---|---|
| Idle deadline | `124`, reason `idle` | `2`, reason empty |
| Absolute deadline | `125`, reason `absolute` | `2`, reason empty |
| Run to completion with progress | command's own exit code | `2` after ~1s |

A timed-out validator was also not force-terminated, so its process group leaked. The
committed selftest `guard-lib-timeout-selftest.sh` already asserted all four behaviors
and had been failing at HEAD.

The only non-test caller, `v5.3-selftest.sh:200`, recognizes exactly `0`, `124` and
`125`. A returned `2` escaped every branch it understands and surfaced as
`T3c: downstream framework-validate exited 2 without a trailing Failed checks block` —
a failure blamed on the downstream repository rather than on this runner. Read from the
source, not executed; see the provenance note in [report.md](report.md).

## Reproduction (before fix)

```
$ bash bubbles/scripts/guard-lib-timeout-selftest.sh
exit: 1
  FAIL  progress-aware command returned rc=2 after 2s
  FAIL  idle timeout returned rc=2 reason=none after 2s
  FAIL  absolute timeout returned rc=2 reason=none after 2s
  FAIL  timed-out validator leaked or blocked: pid=81706 rc=2 reason=none elapsed=6s
guard-lib timeout selftest: 4 failure(s)
```

Full raw output with exit codes is in [report.md](report.md).

## Attribution

Pre-existing at HEAD, not a regression from in-flight work. `git status --short` and
`git diff HEAD` over `bubbles/scripts/guard-lib.sh` and
`bubbles/scripts/guard-lib-timeout-selftest.sh` both emitted zero lines before the fix.

## Fix

Normalize the capture before the numeric test, using fork-free bash parameter
substitution that behaves identically under GNU and BSD userland:

```bash
current_size="${current_size//[[:space:]]/}"
```

No macOS special-case and no capability probe: the expansion removes whitespace that GNU
`wc` never emits, so the GNU path is unchanged. Verified to work on bash 3.2.57, the
macOS baseline.

## Micro-fix admission answers

<!-- Answers below are read mechanically by bubbles/scripts/micro-fix-admission.sh -->

- micro-fix-admission: no-new-behavior = no
  The fix adds no behavior. It makes the implementation produce the return codes and
  reasons that the committed selftest and the function's own header comment already
  specify. The contract is unchanged; only the broken path is corrected.
- micro-fix-admission: no-schema-change = no
  No persisted schema, wire contract, or artifact shape is touched. One shell variable
  is normalized in memory.
- micro-fix-admission: no-auth-surface = no
  `guard-lib.sh` has no authentication, authorization, or session-identity code.
- micro-fix-admission: no-payment-surface = no
  No payment, billing, or money-movement code exists anywhere in this repository.
- micro-fix-admission: no-secret-surface = no
  No secret, key material, or credential flows through the changed line. The value is a
  byte count of a progress log.
- micro-fix-admission: no-deployment-surface = no
  No deployment, host configuration, or release wiring is changed.
- micro-fix-admission: no-cross-product-effect = no
  Every caller is framework-internal: `guard-lib-timeout-selftest.sh` and
  `v5.3-selftest.sh`. Verified by repo-wide grep; no product or downstream repository
  code calls `bubbles_run_with_progress_timeout`, and its signature and return-code
  contract are unchanged.
- micro-fix-admission: contract-preserving = yes
  `guard-lib-timeout-selftest.sh` was not modified. `git diff` over it is empty after
  the fix. Every assertion still asserts exactly what it asserted before; the four
  previously-failing cases now pass against unchanged assertions.

## Sweep for the same defect class

Repo-wide sweep of `wc -[clmw]` captures across `bubbles/scripts/` and `tests/` found
this as the only instance in the failure class. Full classification is in
[report.md](report.md) under `## Sweep`.
