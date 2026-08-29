# BUG-039: Unusable Python Interpreter Is Misreported As 11 Semantic Classification Failures

**Status:** Confirmed
**Severity:** High
**Reported:** 2026-08-24
**Component:** `bubbles/scripts/implementation-reality-scan-selftest.sh` (Scan 2B semantic scenarios)
**Cascades into:** `tests/regression/test_24_g028_sensitive_client_storage.sh`, `framework-validate`

---

## Summary

When the Python interpreter that the Scan 2B sensitive-storage classifier
requires is present on `PATH` but cannot execute, the managed selftest runs the
semantic classification assertions anyway. Their preconditions cannot hold, so
eleven of them fail and the selftest announces
`implementation-reality-scan selftest failed with 11 issue(s).` That sentence
names the wrong defect. There are not eleven classification defects. There is
one missing prerequisite.

The misnomer cascades: `test_24_g028_sensitive_client_storage.sh` asserts the
managed selftest exits 0 and reports `FAIL: managed selftest runs with the
system-only PATH`, and `framework-validate` surfaces roughly fourteen
unrelated-looking failures including `BUG-013 sensitive client storage
regression`.

## Root Cause

`bubbles/scripts/implementation-reality-scan.sh` line 696 gates the classifier
on `command -v python3`. That is a **presence** check, not a **usability**
check. The two are not the same predicate, and on macOS they diverge.

On a machine where `xcode-select -p` points at `/Applications/Xcode.app/Contents/Developer`
and the Xcode licence has not been accepted, `/usr/bin/python3` exists and
resolves — it is a shim that dispatches through the *active developer
directory*, so it inherits that directory's unaccepted-licence failure. The
shim therefore satisfies `command -v` and then exits **69** without executing a
single line of the helper, printing:

```
You have not agreed to the Xcode license agreements. Please run 'sudo xcodebuild -license' ...
```

The scanner handles this correctly and honestly. It reports
`sensitive-storage classifier failed: exit=69`, echoes the interpreter's stderr,
and degrades every candidate line to
`reason=SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED`. That degradation is the
designed fail-closed behaviour and it is not the bug.

The bug is one layer up. The **selftest** does not check whether the classifier
prerequisite is satisfiable before asserting on classifier output. It asserts
exact semantic tuples such as
`reason=DURABLE_CREDENTIAL_STORAGE storage=localStorage operation=persist ...`
against output that, by construction, can only contain
`CLASSIFICATION_UNRESOLVED`. The resulting failure text describes the code under
scan, when the true subject is the interpreter under the test harness.

A second, quieter half of the same root cause: four assertions in the same block
**pass vacuously** under the dead interpreter, because the blanket
`CLASSIFICATION_UNRESOLVED` degradation happens to satisfy them. A block that
reports 11 red and 4 green when zero of the 15 verdicts were actually earned is
not partially working; it is entirely uninformative.

## Reproduction — Single-Variable A/B

Exactly one variable differs between the two runs.

```
A: env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash <selftest> </dev/null
   A_EXIT=1 — "implementation-reality-scan selftest failed with 11 issue(s)."
   interpreter under A: exit 69, "You have not agreed to the Xcode license agreements..."

B: env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin \
     DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash <selftest> </dev/null
   B_EXIT=0 — "implementation-reality-scan selftest passed."
   interpreter under B: Python 3.9.6
```

`DEVELOPER_DIR` changes which developer directory the `/usr/bin/python3` shim
dispatches through. Nothing about the repository, the scanner, the classifier or
the fixtures differs between A and B. Both
`implementation-reality-scan-selftest.sh` and
`bubbles/scripts/guards/sensitive-client-storage-scan.py` are clean at HEAD; this
is pre-existing and was not introduced by in-flight work.

Verbatim evidence for A, B and the machine context is in
[report.md](report.md).

## Expected Behaviour

When the classifier prerequisite is unsatisfiable, the selftest must say so —
naming the cause and the operator action — and must not run assertions whose
preconditions cannot hold. When the prerequisite IS satisfiable, every
assertion must run exactly as before and must still catch a real classifier
regression.

A skip is not a pass. Any consumer of the selftest must be able to tell the two
apart mechanically.

## Non-Remedies (rejected, with reasons)

- **Overriding `DEVELOPER_DIR` inside the test.** Rejected. The sanitized-PATH
  scenario exists to prove the scanner works under DEFAULT system resolution
  with no Homebrew. Hand-picking a developer directory that happens to work
  means the scenario no longer tests what its name claims.
- **Relaxing or deleting the semantic assertions, or making `test_24` tolerate
  the eleven mismatches.** Forbidden. The assertions are correct. They must
  still run, and must still fail, when the classifier is genuinely wrong.
- **Accepting the Xcode licence.** Not available to automation: `sudo -n true`
  reports `a password is required`. This is an operator action and the framework
  cannot depend on it having been taken.

## Packet Route

`bash bubbles/scripts/micro-fix-admission.sh` resolves this to the **full**
packet. The compact route is refused on two admission conditions:

- `no-new-behavior = yes` — the fix adds an observable SKIP path and a
  machine-readable sentinel that a downstream consumer (`test_24`) reads.
- `contract-preserving = no` — `test_24`'s `assert_status 0 "managed selftest
  runs with the system-only PATH"` changes meaning: an unconditional pass
  becomes a pass-or-explicit-skip discrimination.

Escalation is automatic and has no override flag.

<!-- Admission answers, read by micro-fix-admission.sh -->
micro-fix-admission: no-new-behavior = yes
micro-fix-admission: no-schema-change = no
micro-fix-admission: no-auth-surface = no
micro-fix-admission: no-payment-surface = no
micro-fix-admission: no-secret-surface = no
micro-fix-admission: no-deployment-surface = no
micro-fix-admission: no-cross-product-effect = no
micro-fix-admission: contract-preserving = no
