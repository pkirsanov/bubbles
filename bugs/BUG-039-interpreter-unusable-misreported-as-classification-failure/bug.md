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

---

## 2026-09-01 Tests-First Finding — PRE-HAR-01

**Status:** Confirmed and open
**Disposition:** Retained in the existing BUG-039 packet because it affects the
same privileged Python harness. No production repair or GREEN result is claimed.

### Failure Contract

`PRE-HAR-01` interrupts the production EXIT trap during its first real
supervisor wait. The control uses a real Perl supervisor and a worker that
remains active for three seconds.

A correct EXIT path must continue waiting until the supervisor is reaped. It
must retain the wait handle and private root until that boundary completes.

Current-session receipt row 73 records exit 1 for the corrected real-supervisor
RED control. Its stdout hash is
`2936a173d440b34bdf0f1c92108d398f7bf17ff514fc03df677ec21ffac14fda`.
The receipt binds `bubbles/scripts/python-env-selftest.sh` at SHA-256
`405544e39fe8dd83f5a7732c845f329b93ee6402e47bb642ba6c356edca28a7d`.

**Claim Source:** executed — `.specify/runtime/tool-calls.jsonl` row 73.

### Root Cause

`_bubbles_python_security_exit_trap` performs one `wait` and suppresses a
non-zero result. It then clears
`BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID` unconditionally.

`bubbles_python_security_cleanup` refuses cleanup only while that handle is
non-empty. Clearing it after an interrupted wait removes the guard. Cleanup can
then delete the private root while the real supervisor remains alive.

The defect is not missing TERM forwarding. It is premature handle clearance
after an interruptible reap operation.

### Acceptance Boundary

1. Continue the EXIT reap boundary after an interrupted `wait`.
2. Clear the supervisor handle only after the process is no longer live.
3. Keep the private root until the supervisor is reaped.
4. Preserve the original owner exit status.
5. Leave no worker or supervisor residue.
6. Turn the current `PRE-HAR-01` RED control GREEN without polling forever.

### Planning Route

`bubbles.plan` owns the required Scope 2 planning update. It must add this
failure contract and preserve the current test-first evidence reference. This
bug-artifact pass does not modify `scopes.md`, `test-plan.json`,
`scenario-manifest.json`, `report.md`, or `state.json`.

---

## 2026-09-01 Regression Finding Disposition

The reproduction observations below come from the fresh `bubbles.regression`
result supplied for this persistence pass. This agent did not execute those
controls. Targeted source reads confirm the named candidate paths, but each
open finding still requires its own persistent RED control.

### REG-PY-REAP-01

- **Reproduction observation:** The EXIT trap retries `wait` only once. A
  second interruption can leave the supervisor live while the trap clears its
  wait handle.
- **Root cause hypothesis:** `_bubbles_python_security_exit_trap` performs one
  initial wait and one conditional retry. It then clears
  `BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID` without proving that the
  supervisor is no longer live.
- **Owner:** BUG-039 owns this finding through `PRE-HAR-01` and the HAR-R1
  lifecycle boundary. `bubbles.test` owns the RED control. `bubbles.implement`
  owns any later source repair.
- **Required RED control:** Interrupt both the initial wait and its retry while
  one real supervisor remains live. Assert that the owner cannot clear the
  handle or private root. Then allow a bounded later wait to reap the
  supervisor while preserving the original owner exit status.
- **Disposition (Gate G095):** OPEN as an extension of `PRE-HAR-01`. It is not
  a new bug ID. No production repair or GREEN result is claimed.

### REG-PY-BASH32-01

- **Reproduction observation:** The `PRE-HAR-01` harness reads `BASHPID` under
  stock Bash 3.2. The scenario is also absent from the default selftest
  aggregate.
- **Root cause hypothesis:** The harness assigns its owner identity directly
  from a Bash-version-sensitive variable. Its only call site is the dedicated
  internal interruption mode, so the default aggregate cannot collect the
  scenario.
- **Owner:** BUG-039 owns this test-contract defect. `bubbles.test` owns the
  harness and aggregate RED controls. No production source owner is assigned
  until those controls distinguish a harness failure from the product defect.
- **Required RED control:** Run the exact `PRE-HAR-01` mode under stock macOS
  Bash 3.2 and require portable owner identification before the lifecycle
  assertion runs. Run the default aggregate and require one `PRE-HAR-01`
  scenario marker and result. Both controls must reject silent omission.
- **Disposition (Gate G095):** OPEN under BUG-039. This is a test-contract
  defect tied to `PRE-HAR-01`, not a separate production bug.

### REG-CI-NONVACUITY-01

- **Reproduction observation:** The exact-head CI validator accepts a step
  that only prints the release-check command text.
- **Root cause hypothesis:** The validator selects a step by the
  `bubbles/scripts/cli.sh release-check` substring. It verifies that the step
  exists and disables receipt reuse, but it does not prove the shell actually
  invokes that command.
- **Owner:** BUG-039 Scope 2 owns the exact-head extension. `bubbles.test` owns
  the RED control. `bubbles.devops` owns any later workflow repair.
- **Required RED control:** Replace the fixture's release step with a command
  that prints the exact release-check text but never invokes it. Preserve the
  receipt-reuse environment field. Require the validator to reject that
  fixture while continuing to accept a real invocation.
- **Disposition (Gate G095):** OPEN under BUG-039 Scope 2 and `TP-S2-08`. No
  workflow repair or live CI qualification is claimed.

#### Convergence 9 final bypass addendum

- **Final bypass detail:** command text placed inside an unreachable block such
  as `if false; then ...; fi` is accepted even though the release-check command
  can never run. Rejecting print-only text does not close this dead-branch
  variant.
- **Required control extension:** reject command text found only in dead
  branches or unreachable shell blocks. Accept only one canonical,
  directly-reachable release-check run form, with an adversarial fixture for
  the dead `if false` block and a positive fixture for that canonical form.
- **Claim Source:** interpreted from the operator-supplied convergence-9 final
  precommit review. **Executed provenance:** not-run in this artifact-only
  invocation; neither the dead-branch fixture nor live exact-head CI was run.
- **Open disposition:** `REG-CI-NONVACUITY-01` remains OPEN. Dead-branch
  acceptance is the control gap. Exact-head live CI qualification remains
  pending and is not itself classified as a defect. No workflow repair, RED or
  GREEN result, or live CI qualification is claimed.

### Addressed Planning Finding - REG-PLAN-EXACTHEAD-01

**Disposition:** Addressed for planning reconciliation only. The current
[design.md](design.md) defines the source-only exact-head CI contract. The
current [scopes.md](scopes.md) maps it to `SCN-B039-010` and `TP-S2-08` with
unchecked delivery and evidence obligations.

This disposition does not close `REG-CI-NONVACUITY-01`. It does not claim
workflow implementation, RED execution, live CI proof, certification, or bug
completion.

**Claim Source:** interpreted from the current `design.md`, `scopes.md`, and
`state.json` planning history read during this persistence pass.

### Sequencing Obligation - REG-MANIFEST-STALE-01

**Classification:** Ordered release sequencing obligation, not a distinct
defect and not a new bug ID.

**Required sequence:** Keep the release manifest untouched while source, test,
and workflow bytes remain unsettled. Regenerate it once after every such byte
has settled. Then validate every generated identity against that final byte
set before release closure.

**Disposition:** OPEN and pending under BUG-039. The active bugfix runner owns
the ordering. This persistence pass does not regenerate or validate the
manifest.

### One-To-One Finding Accounting

| Finding | Existing record | Disposition |
| --- | --- | --- |
| `REG-EC-STATUS-01` | BUG-046 in `BUGS.md` | Open RED control, no duplicate bug |
| `REG-FV-OBSERVER-01` | BUG-045 in `BUGS.md` | Open RED control, no duplicate bug |
| `REG-PY-REAP-01` | BUG-039 and `PRE-HAR-01` | Open RED control |
| `REG-PY-BASH32-01` | BUG-039 test contract | Open RED control |
| `REG-CI-NONVACUITY-01` | BUG-039 Scope 2 | Open RED control |
| `REG-PLAN-EXACTHEAD-01` | BUG-039 planning reconciliation | Addressed for planning only |
| `REG-MANIFEST-STALE-01` | BUG-039 release sequence | Open sequencing obligation, not a defect |

### 2026-09-02 Precommit Security Review Routing

The review raised three umbrella concerns: evidence-receipt metadata integrity,
lock-object identity, and signal-target identity. Receipt metadata has two
independent controls, so the stable IDs below keep finding-to-control accounting
one-to-one without creating duplicate bug packets.

| Stable finding | Existing owner | Umbrella and open disposition |
| --- | --- | --- |
| `SEC-PRECOMMIT-HELPER-01` | BUG-046 in `BUGS.md` | Child control of `REG-EC-STATUS-01`; open |
| `SEC-PRECOMMIT-LABEL-01` | BUG-047 in `BUGS.md` | Child control of `REG-EC-STATUS-01`; open |
| `SEC-PRECOMMIT-LOCK-01` | BUG-045 in `BUGS.md` | Lock-object identity control; open |
| `SEC-PRECOMMIT-PID-01` | BUG-045 in `BUGS.md` | Signal-target identity control; open |

Exact-head live CI remains pending qualification under
`REG-CI-NONVACUITY-01`. The precommit security review did not classify that
pending qualification as a source defect, and this persistence pass neither
ran nor claimed a live-CI result.

**Claim Source:** interpreted from the operator-supplied current-session
precommit review boundary and the existing `REG-CI-NONVACUITY-01` record. The
four security reproductions and exact-head live CI were not run in this
persistence pass.
