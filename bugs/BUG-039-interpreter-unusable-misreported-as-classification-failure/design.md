# Design: BUG-039 Privileged Entry And Native Scan 2B Supervision

> **Authoritative design epoch:** `privileged-native-supervision-v2`
>
> This section is the sole active architecture. The later
> `## Archive: Superseded Design Decisions` section preserves earlier designs.
> Historical contracts, labels, and evidence cannot guide implementation or
> certification for this epoch.

## Design Brief

### Current State

The clean successor still enters Scan 2B through ordinary Bash. Its security
runner stores a Bash child PID, uses a worker-held `BPY1` FIFO, and signals that
PID during cleanup.

The mutation harness also stores worker and watchdog PIDs. Its interrupt fixture
lets the target retain descriptor 9 and influence completion behavior.

The candidate CI workflow adds a manual source-only exact-head lane. This design
defines that lane alongside the existing supervision contract.

### Target State

Canonical callers launch Scan 2B through `privileged-bash-entry-v1`. The new
Bash process imports no exported functions and evaluates no `BASH_ENV`.

A root-protected `/usr/bin/perl` process owns each fixed operation. It forks,
signals, and reaps one direct worker with `waitpid` under a fixed wall.

The supervision architecture remains unchanged. A separate CI contract
qualifies one same-repository source SHA on Ubuntu and macOS.

### Patterns To Follow

- Retain `root-protected-native-python-v1` for Python authority.
- Retain `PYSEC1`, `PYMOD1`, and `SCS1` without semantic weakening.
- Retain the helper digest and one-read, same-byte execution contract.
- Keep general Python usability separate from Scan 2B authority.
- Preserve fail-closed findings and honest unavailable-prerequisite accounting.
- Derive worker completion only from supervisor-owned `waitpid`.
- Reuse the existing release-hygiene platform setup and 180-minute bound.

### Patterns To Avoid

- Do not use Bash builtin qualification as the authority boundary.
- Do not claim that re-exec reverses earlier hostile `BASH_ENV` activity.
- Do not retain a Bash worker or watchdog PID for signaling.
- Do not let the worker inherit the supervisor control descriptor.
- Do not treat FIFO EOF, readiness output, or worker text as completion.
- Do not add a Bash or PATH-selected supervisor fallback.
- Do not claim recursive descendant containment.
- Do not equate source identity with workflow identity, approval, publication,
  or certification.

### Resolved Decisions

- The aggregate epoch is `privileged-native-supervision-v2`.
- The entry contract is `privileged-bash-entry-v1` with protocol `BSEC1`.
- The supervisor is fixed `root-protected-perl-supervisor-v1` with protocol `BPS1`.
- The worker trust contract remains `root-protected-native-python-v1`.
- `/bin/bash`, `/usr/bin/env`, and `/usr/bin/perl` are fixed path anchors.
- The supervisor program is fixed source embedded in `python-env.sh`.
- The supervisor owns the 30-second wall and the two-second TERM grace.
- Parent Bash may retain one supervisor wait handle and may only wait on it.
- Parent signals become pending results until the supervisor has been reaped.
- Active labels use `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`.
- Scope 2 requires the widened source, test, governance, and documentation boundary.
- `.github/workflows/agnosticity.yml` adds one manual source-only exact-head matrix.
- The dispatch accepts one lowercase 40-hex commit SHA and runs only that matrix.
- Exact-head release hygiene disables receipt reuse and requires both platforms.

### Open Questions

None. This design does not claim implementation or verification.

## Purpose And Scope

This design supersedes the Bash exact-child and watchdog architecture. It also
closes the ordinary-shell startup gap at canonical Scan 2B production callers.

Requirements 1 through 6 in `spec.md` remain unchanged. Scenario identifiers
`SCN-B039-001` through `SCN-B039-009` remain stable.

The active architecture has four layers:

1. A privileged Bash entry process.
2. Root-protected fixed-path authentication.
3. A native Perl supervisor with direct-worker ownership.
4. An authenticated Python worker that executes pinned classifier bytes.

The security guarantee begins inside the privileged child. It makes no claim
about code that an ordinary caller ran before that boundary.

This design admits one CI workflow surface. It changes no runtime source
contract, test, state, evidence, or acceptance record.

## Requirement And Finding Reconciliation

### Existing Outcome Requirements

| Requirement | Active technical realization |
| --- | --- |
| Requirement 1 | An unavailable entry, supervisor, runtime, or helper withholds the entire classifier-dependent group. It emits no classifier-attributed pass or failure. |
| Requirement 2 | The skip reports a numeric status, a closed diagnostic, validated context, and an actionable remediation. Xcode licence status `69` remains distinct. |
| Requirement 3 | `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1` appears only when classifier-dependent scenarios did not execute. |
| Requirement 4 | A complete privileged path executes every semantic and configuration assertion. The authorized classifier mutation remains fatal. |
| Requirement 5 | All 23 classifier-dependent assertions remain one atomic verdict group. Partial supervision cannot earn a verdict. |
| Requirement 6 | `test_24` increments only `SKIP_COUNT` for the sentinel. `FAIL_COUNT` still owns suite failure. |

Usable Python is necessary but not sufficient. A clean verdict also requires
the privileged entry, authenticated supervisor, complete runtime closure,
same-byte helper identity, and valid `SCS1` output.

### Current Review Findings

| Finding | Scenario | Design closure | Remaining proof owner |
| --- | --- | --- | --- |
| `SEC-R1` | `SCN-B039-005` | Enter `/bin/bash -p` through an empty environment before any module source. | Implementation and hostile-startup tests on macOS and Linux. |
| `SEC-R2` | `SCN-B039-006` | Authenticate fixed `/usr/bin/perl`. Let its supervisor own and reap one direct worker with `waitpid`. | Implementation and lifecycle mutation tests. |
| `HAR-R1` | `SCN-B039-007` | Remove Bash worker and watchdog signaling. Propagate pending parent signals only after the supervisor wait completes. | Harness rewrite and signal-window proof. |
| `HAR-R2` | `SCN-B039-008` | Remove worker-held completion channels. Enforce wall and output limits without worker cooperation. | Harness rewrite and forged-control proof. |
| `HAR-R3` | `SCN-B039-009` | Reserve `SEC-OBS-002` for historical quotations. Use current BUG-039 labels in every active artifact and result. | Planning, test, report, and identifier checks. |

The clean successor has no active `SEC-OBS-002` occurrence outside design
history. This epoch prevents that historical label from returning as an active
test, planning, or evidence identifier.

## Clean Successor Reconciliation

The following source facts define the replacement boundary:

| Surface | Current clean-successor fact | Design consequence |
| --- | --- | --- |
| `python-env.sh` | Security cleanup stores `BUBBLES_PYTHON_SECURITY_ACTIVE_PID`, sends TERM and KILL, and then calls Bash `wait`. | Remove worker PID ownership from Bash. |
| `python-env.sh` | `BPY1` readiness and FIFO EOF control the operation lifecycle. | Replace target-influenced completion with supervisor `waitpid`. |
| Scanner | The script sources `guard-lib.sh` and `python-env.sh` in its ordinary Bash process. | Add privileged entry before either source. |
| Scanner selftest | The harness stores active-child and watchdog PIDs. Its interrupt target retains descriptor 9. | Replace the harness wall with the native supervisor. |
| CLI | `cmd_scan()` invokes the scanner with ordinary `bash`. | Launch the privileged boundary directly. |
| Transition guard | Check 16 wraps ordinary `bash` around the scanner. | Launch the same privileged boundary and preserve its real status. |
| Scope 2 | Active planning still prescribes the earlier five-file exact-child design. | `bubbles.plan` must reconcile the scope before implementation. |
| State | `workBoundary.allowedPaths` contains only the earlier five implementation and test paths. | The work boundary must widen to every required path below. |

The earlier root-protected Python work remains valuable. Only its Bash startup,
worker lifecycle, deadline, completion, and active identifier contracts are
superseded.

## Security Objective And Threat Model

### Security Objective

A clean Scan 2B contribution requires all conditions below:

1. The scanner starts inside `privileged-bash-entry-v1`.
2. That process imports no caller function and evaluates no `BASH_ENV`.
3. Every bootstrap executable passes root-protected native-path checks.
4. `/usr/bin/perl` starts in taint mode with an empty environment.
5. The supervisor accepts one closed operation and bounded arguments.
6. The supervisor forks exactly one direct worker.
7. The supervisor remains that worker's parent until `waitpid` reaps it.
8. The supervisor enforces wall and output limits without worker cooperation.
9. Python satisfies `root-protected-native-python-v1`, `PYSEC1`, and `PYMOD1`.
10. The classifier helper passes the size and digest checks before same-byte use.
11. Classifier output satisfies complete `SCS1` validation.
12. The supervisor emits one valid `BPS1` completion after reaping the worker.

Any failed condition withholds an earned clean result. Scan 2B then preserves
its existing fail-closed unresolved findings.

### Hostile Inputs

The boundary treats these inputs as hostile:

- exported functions, including slash-named functions
- `BASH_ENV`, `SHELLOPTS`, `BASHOPTS`, `CDPATH`, and `GLOBIGNORE`
- PATH, home, cache, Python, Perl, loader, and locale variables
- caller-selected runtimes and managed virtual environments
- project source, project configuration, and classifier output
- malformed operation names, paths, counts, and protocol records
- workers that exit, hang, flood output, close descriptors, or fork
- signals during entry, launch, collection, termination, and cleanup
- stale numeric PID values retained by Bash or a test harness

### Trusted Computing Base

The active TCB contains:

- the checked-out scanner and `python-env.sh`
- the fixed embedded Perl supervisor program
- fixed `/bin/bash`, `/usr/bin/env`, and `/usr/bin/perl`
- fixed metadata utilities used by path authentication
- the authenticated native Python and validated module closure
- the digest-matched classifier helper bytes
- kernel fork, pipe, signal, alarm, zombie, and wait semantics
- kernel-reported ownership, mode, and executable format

The TCB excludes Bash PID-liveness reasoning, `read -t`, FIFO EOF, job control,
a watchdog process, and target-authored completion.

### Explicit Non-Claims

The design makes no recursive containment claim. A compromised worker may fork,
double-fork, or call `setsid`.

The supervisor does not enumerate or signal descendants. It uses no process
group, session, cgroup, pidfd, or `/proc` containment claim.

A compatibility re-exec cannot undo hostile `BASH_ENV` activity that already
happened. The design also cannot protect against compromised root, kernel,
filesystem metadata, or checked-out framework source.

## Architecture Overview

```text
ordinary framework caller
  -> cli.sh or state-transition-guard.sh
    -> fixed child launcher
      -> POSIX special-builtin exec
        -> env -i /bin/bash -p
          -> BSEC1 boundary checks
          -> implementation-reality-scan.sh
            -> root-protected path authentication
            -> fixed /usr/bin/perl -T supervisor
              -> pipe setup and 30-second alarm
              -> fork one direct worker
                -> close supervisor-only descriptors
                -> exec one fixed operation
              -> bound stdout and stderr
              -> signal only an unreaped direct worker
              -> waitpid the direct worker
              -> emit one BPS1 completion
            -> validate PYSEC1, PYMOD1, and SCS1
            -> emit findings or fail-closed unresolved findings
```

Parent Bash stores only the Perl supervisor PID. It uses that value only as a
`wait` handle and clears it immediately after reaping the supervisor.

## Data Model

No lifecycle state persists across runs.

| Record | Required fields | Invariant |
| --- | --- | --- |
| `EntryBoundary` | protocol, contract, mode, privileged flag | The record is valid only when actual Bash mode contains `p`. |
| `SupervisorIdentity` | fixed path, resolved target, trust contract, native format | Identity completes only after full path authentication. |
| `SecurityRuntimeIdentity` | runtime path, `PYSEC1`, `PYMOD1`, trust contract | Identity completes only after path and module closure. |
| `OperationRequest` | closed operation, bounded scalars, bounded data paths | It contains no caller executable vector, program, helper path, wall, or output limit. |
| `SupervisorRun` | operation, status, owner, timed-out bit, worker kind, byte counts | It contains no PID and follows one valid `BPS1` record. |
| `SupervisorWaitHandle` | direct supervisor PID, wait state, pending signal | Bash may only wait on this value. |
| `CaptureRegistry` | private root and three capture paths | It contains no worker or watchdog PID. |
| `ClassifierVerdict` | status, diagnostic, scanned count, findings, protocol | `OK` requires valid `BPS1` and complete `SCS1`. |

The worker PID remains lexical Perl state. It never enters output, Bash state,
the environment, or cleanup files.

## API And Protocol Contracts

### Shell APIs

| API | Inputs | Outputs | Authority |
| --- | --- | --- | --- |
| `bubbles_python_runs()` | one general interpreter path | usability status and closed diagnostic | General only |
| `bubbles_python_resolve_runnable()` | none | existing ordered general resolution | General only |
| `bubbles_python_security_require_boundary()` | none | `BSEC1` status and closed diagnostic | Security entry |
| `bubbles_python_resolve_security_runtime()` | none | authenticated Python identity | Security runtime |
| `bubbles_python_run_security_operation()` | closed operation and operation data | status, ownership, and bounded capture paths | Security execution |
| `bubbles_python_security_cleanup()` | registered file resources | file cleanup status | File cleanup only |

`bubbles_python_security_cleanup()` contains no process signal or worker wait.
The operation wrapper reaps the supervisor before file cleanup begins.

### `BSEC1` Entry Protocol

After validating actual privileged mode and startup state, the scanner records:

```text
ENTRY\tBSEC1\tprivileged-bash-entry-v1\t<direct|compat-reexec>
```

The record is diagnostic. It is not a bearer token and cannot replace the
actual `$-` privileged-mode check.

`direct` means a canonical caller created the privileged process directly.
`compat-reexec` means an ordinary scanner process existed first and remains
unattested.

### `BPS1` Supervisor Protocol

The supervisor writes exactly one final control record after `waitpid`:

```text
COMPLETE\tBPS1\t<operation>\t<status>\t<owner>\t<timedOut>\t<workerKind>\t<stdoutBytes>\t<stderrBytes>
```

The record is at most 512 bytes. Its grammar is closed.

- `owner` is `worker`, `supervisor`, or `caller-signal`.
- `timedOut` is `0` or `1`.
- `workerKind` is `exit`, `signal`, or `not-started`.
- byte counts are unsigned decimal values within operation limits.

No path, environment value, output byte, or PID appears in `BPS1`.
Missing, duplicate, malformed, oversized, or trailing control data produces
status `125` and `SUPERVISOR_PROTOCOL_INVALID`.

`BPY1`, its readiness record, and its lifecycle FIFO are archive-only. They
have no completion or deadline authority in this epoch.

### Retained Python And Classifier Protocols

`PYSEC1`, `PYMOD1`, and `SCS1` retain their current fields and validation.
The Perl supervisor does not parse them.

Parent Bash parses Python and classifier captures only after a valid `BPS1`.
A successful worker status cannot compensate for malformed protocol output.

## Capability Foundation

### Foundation Contracts

| Contract | Responsibility | Consumers |
| --- | --- | --- |
| `privileged-bash-entry-v1` | Enter a shell that imports no caller functions and evaluates no `BASH_ENV`. | CLI scan, transition guard Check 16, direct scanner compatibility |
| `root-protected-path-v1` | Authenticate fixed paths, links, ancestors, modes, caller access, and native format. | Entry anchors, Perl, Python, Apple tools |
| `root-protected-perl-supervisor-v1` | Own wall, output, status, signal, and direct-worker reaping. | Every bounded fixed operation and mutation wall |
| `root-protected-native-python-v1` | Validate isolated Python posture and module closure. | Runtime probe, module probe, classifier |
| `fixed-security-operation-v2` | Map a closed operation to fixed worker arguments and limits. | General probe, Apple resolution, Python probes, Scan 2B |

### Extension Points

There is no caller command, provider, or plugin extension. A new operation
requires a reviewed enum entry, fixed limits, protocol updates, and mutations.

An alternate supervisor requires a new trust contract and full parity proof.
Missing Perl never activates another provider.

### Foundation-Owned Behavior

The foundation owns entry, path authentication, empty environments, operation
closure, deadlines, output limits, status ownership, signals, direct-worker
reaping, file cleanup, and bounded diagnostics.

The Python helper continues to own classifier semantics.

## Concrete Implementations

### Privileged Bash Entry

Canonical callers create a child and execute this fixed shape inside it:

```text
POSIXLY_CORRECT=y exec /usr/bin/env -i \
  LC_ALL=C PATH=/usr/bin:/bin \
  BUBBLES_SECURITY_ENTRY_MODE=direct \
  /bin/bash -p -- <implementation-reality-scan.sh> <validated-arguments>
```

The assignment gives the POSIX special `exec` builtin precedence over an
imported function. The pathname argument prevents PATH selection.

`env -i` removes exported-function encodings and `BASH_ENV`. `bash -p` also
suppresses function import and startup environment evaluation.

The scanner verifies privileged mode before sourcing any file. It rejects a
forbidden startup variable or function encoding before Scan 2B work.

`cli.sh` and `state-transition-guard.sh` must launch this boundary directly.
They must not invoke ordinary `bash` and rely on scanner recovery.

### Ordinary Direct Scanner Compatibility

The scanner keeps a first-executable-statement compatibility re-exec:

```text
POSIXLY_CORRECT=y exec /usr/bin/env -i \
  LC_ALL=C PATH=/usr/bin:/bin \
  BUBBLES_SECURITY_ENTRY_MODE=compat-reexec \
  /bin/bash -p -- "$0" "$@"
```

This path preserves an ordinary direct invocation. It cannot undo, detect, or
clean hostile `BASH_ENV` activity that occurred before the first statement.

The inner process may earn authority after all checks pass. The earlier process
must remain labeled `compat-reexec` and unattested.

### Root-Protected Path Authentication

The existing algorithm remains active. It checks every ancestor, symlink, and
final target for UID 0 ownership, protected mode, caller writability, type, and
native ELF or Mach-O format.

Apple Python resolution still authenticates `xcode-select`, `xcrun`, the
developer directory, and the resolved Python before Python executes.

### Native Perl Supervisor

`python-env.sh` embeds one fixed Perl program and invokes only:

```text
/usr/bin/env -i LC_ALL=C /usr/bin/perl -T -w -e <fixed-program> <closed-arguments>
```

The program loads no Perl module. It uses Perl builtins for `fork`, `pipe`,
`select`, `alarm`, `kill`, `waitpid`, `sysread`, `syswrite`, and `exec`.

Every argument is untainted through a closed grammar. The program performs no
PATH lookup and accepts no caller program text.

### Authenticated Python Worker

The worker closes the supervisor control descriptor and every unused pipe end.
It receives only `/dev/null` stdin plus stdout and stderr pipe writers.

It executes one authenticated Python path with `-I -S -B` under `LC_ALL=C`.
It cannot write `BPS1` because it never inherits that descriptor.

### Scan 2B Adapter

The scanner requests `scan2b-classify` only after entry, supervisor, and runtime
authentication. It validates `BPS1` before it parses `SCS1`.

An unavailable supervisor has the same fail-closed effect as an unavailable
authenticated Python. It cannot become a zero-finding success.

### Variation Axes

| Axis | General usability | Scan 2B authority | Owner |
| --- | --- | --- | --- |
| Entry | Ordinary caller allowed | Privileged Bash required | Entry foundation |
| Runtime source | Override, managed environment, PATH | Fixed authenticated paths only | Runtime foundation |
| Operation | Fixed general probe | Closed security operation | Operation foundation |
| Completion | Supervisor `waitpid` | Supervisor `waitpid` plus protocol validation | Supervisor foundation |
| Failure effect | Candidate declines | Scanner fails closed | Scan adapter |
| Evidence value | Usability only | Full epoch evidence | Planning and validation |

## Native Supervisor Lifecycle

### Launch And Ownership

Parent Bash creates private captures and starts one Perl supervisor. It stores
`$!` only in `BUBBLES_PYTHON_SECURITY_SUPERVISOR_WAIT_PID`.

Bash never signals that value. It never stores a worker or watchdog PID.

The supervisor follows this state machine:

```text
START -> VALIDATED -> PIPES_OPEN -> FORKED -> OWNED
OWNED -> REAPED -> RECORDED -> EXITED
OWNED -> TERMINATING -> REAPED -> RECORDED -> EXITED
START..FORKED -> SETUP_FAILED -> RECORDED -> EXITED
```

Only Perl knows the worker PID. The supervisor installs no `SIGCHLD` handler
and never ignores `SIGCHLD`.

The event loop serializes `waitpid` and signal decisions. Once
`waitpid(worker, WNOHANG)` returns the worker PID, it clears ownership before
any later signal branch.

An exited but unreaped worker remains a child zombie. Its PID cannot be reused
while the supervisor owns that wait relationship.

### Independent Deadline And Output Collection

The supervisor arms a 30-second real-time alarm immediately before `fork`.
No worker descriptor or output record can extend or shorten that wall.

The supervisor reads stdout and stderr through separate pipes. It counts every
byte before writing the private captures.

Crossing a limit enters termination. A quiet worker receives the same absolute
wall as a chatty worker.

Worker pipe EOF is data state only. It never means process completion.

After `waitpid`, the supervisor drains currently buffered bytes without waiting
for descendant-held pipe EOF. It then closes its read ends.

### Termination

On deadline or output breach, the supervisor sends TERM only while ownership is
`OWNED`. It allows a fixed two-second grace.

It then sends KILL only if `waitpid` has not reaped the direct worker. It calls
`waitpid` for that same child and emits no completion before reaping.

Kernel-uninterruptible process state remains outside the userspace guarantee.

### Parent Signal Contract

Parent Bash traps HUP, INT, and TERM. The first trap records status `129`, `130`,
or `143`, then ignores later instances until the supervisor is reaped.

The trap never signals a PID and never removes capture files. If the signal
interrupts Bash `wait`, Bash resumes `wait` on the same supervisor child.

After a definitive supervisor wait, Bash clears the wait handle. It then cleans
files and returns the first pending signal status.

The Perl supervisor also uses deferred HUP, INT, and TERM handlers. Each handler
sets a flag. The event loop performs ownership-checked termination.

If only Bash receives the signal, it still waits for the supervisor's bounded
wall. If Perl also receives it, `BPS1.owner` is `caller-signal`.

### Signal Latency

The supervisor event-loop interval is at most 50 milliseconds. It dispatches
TERM within 100 milliseconds after its handler records a signal.

It returns within 2.25 seconds after receiving that signal, subject to kernel
scheduling and the stated KILL assumption.

If only Bash receives the signal, its maximum designed wait is the remaining
30-second wall plus the two-second grace and 250 milliseconds of cleanup.

## Fixed Operations, Limits, And Status Ownership

### Closed Operations And Limits

Every operation has a 30-second wall and a two-second TERM grace.

| Operation | stdout | stderr | Argument contract |
| --- | ---: | ---: | --- |
| `general-probe` | 16 KiB | 16 KiB | one interpreter path |
| `apple-select` | 4 KiB | 16 KiB | none |
| `apple-find-python` | 4 KiB | 16 KiB | one validated directory |
| `runtime-probe` | 16 KiB | 16 KiB | none |
| `module-probe` | 64 KiB | 16 KiB | none |
| `scan2b-classify` | 4 MiB | 64 KiB | at most 4,096 paths and 64 KiB aggregate text |

Each path is at most 4,096 bytes and contains no NUL or control byte. Operation
names are at most 32 ASCII bytes.

No environment variable or caller argument changes a wall, grace, output limit,
path count, text count, protocol size, helper size, or helper digest.

### Numeric Status Ownership

| Condition | Status | Diagnostic | Owner |
| --- | ---: | --- | --- |
| Complete operation | `0` | `OK` | `worker` |
| Invalid operation or argument | `2` | `ARGUMENT_INVALID` | `supervisor` |
| Xcode licence refusal | `69` | `XCODE_LICENSE_UNACCEPTED` | `worker` |
| Worker exec failure | `126` | `WORKER_EXEC_FAILED` | `worker` |
| Missing or untrusted supervisor or runtime | `127` | closed unavailable diagnostic | `supervisor` |
| Supervisor wall expiry | `124` | `SUPERVISOR_TIMEOUT` | `supervisor` |
| Supervisor setup or protocol failure | `125` | closed supervisor diagnostic | `supervisor` |
| Worker nonzero exit | exact worker exit | `WORKER_EXIT_NONZERO` | `worker` |
| Worker signal | `128 + signal` | `WORKER_SIGNAL` | `worker` |
| Caller HUP, INT, or TERM | `129`, `130`, or `143` | matching signal diagnostic | `caller-signal` |
| Output limit | `125` | `OUTPUT_LIMIT` | `supervisor` |

A worker-owned `124`, `125`, or `143` retains its number. `owner` and
`timedOut` distinguish it from supervisor and caller ownership.

The closed supervisor diagnostics are:

- `NOT_RUN`
- `OK`
- `SECURITY_BOUNDARY_REQUIRED`
- `SUPERVISOR_UNAVAILABLE`
- `SUPERVISOR_UNTRUSTED`
- `ARGUMENT_INVALID`
- `SUPERVISOR_SETUP_FAILED`
- `SUPERVISOR_FORK_FAILED`
- `SUPERVISOR_PROTOCOL_INVALID`
- `SUPERVISOR_TIMEOUT`
- `WORKER_EXEC_FAILED`
- `WORKER_EXIT_NONZERO`
- `WORKER_SIGNAL`
- `OUTPUT_LIMIT`
- `SIGNAL_HUP`
- `SIGNAL_INT`
- `SIGNAL_TERM`
- `INTERNAL`

Raw worker or supervisor output never enters a diagnostic line.

## Capture, Cleanup, Runtime, And Helper Identity

### Capture And Cleanup

The privileged Bash process sets `umask 077`. It creates one private directory
with mode `0700` and three capture files with mode `0600`.

The supervisor receives pre-opened worker-output and control descriptors. The
worker closes the control descriptor before `exec`.

Cleanup starts only after Bash reaps the supervisor. It closes descriptors,
parses bounded captures, removes the private directory, clears paths, and
restores traps.

Cleanup performs no `kill`, worker `wait`, PID probe, process-group operation,
or descendant discovery. An EXIT trap may remove files only after the
supervisor wait handle is clear.

Unexpected supervisor death cannot authorize success because valid `BPS1` is
absent. SIGKILL and host termination may leave private files.

### Python Runtime Identity

`root-protected-native-python-v1` remains active. `PYSEC1` still validates
isolated posture, version, executable, prefixes, and search roots.

`PYMOD1` still validates every required loaded module origin. Direct Python
operations retain `env -i`, `LC_ALL=C`, and `-I -S -B`.

### Classifier Helper Identity

The helper path remains fixed relative to the scanner. The driver reads at most
256 KiB plus one detection byte.

It requires SHA-256
`77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3`.

The driver decodes, compiles, and executes the same byte buffer. It never
reopens or imports the helper path after validation.

The digest binds reviewed bytes. It is not a Python sandbox and creates no
recursive containment claim.

## Failure Handling And Observability

The scanner emits one bounded status line:

```text
sensitive-storage classifier <state>: status=<n> diagnostic=<enum> entry=<BSEC1|none> entryMode=<direct|compat-reexec|none> supervisor=<root-protected-perl-supervisor-v1|none> supervisorProtocol=<BPS1|none> runtime=<root-protected-native-python-v1|none> pathProtocol=<PYSEC1|none> moduleProtocol=<PYMOD1|none> classifierProtocol=<SCS1|none>
```

Output may contain validated paths, counts, numeric statuses, and closed enums.
It must not contain environment values, source bytes, worker output, or PIDs.

| Failure | Scanner effect | Required test observation |
| --- | --- | --- |
| Ordinary direct entry | Compatibility re-exec | `compat-reexec` appears without a pre-boundary cleanliness claim. |
| Imported function or `BASH_ENV` | No marker enters the privileged child | Removing `-p` or `env -i` turns the paired test red. |
| Missing or untrusted Perl | Fail-closed unavailable authority | One named prerequisite and no classifier verdict. |
| Supervisor setup or fork failure | Fail closed with status `125` | No successful `BPS1`. |
| Fast worker exit | Reap before any signal branch | Exact worker status and zero post-reap signals. |
| Worker hang | TERM, grace, KILL, and `waitpid` | Status `124`, owner `supervisor`, timedOut `1`. |
| Worker closes descriptors | Continue until `waitpid` | No early success and no unbounded wait. |
| Worker forges `BPS1` text | Treat text as worker output | Control parser sees only supervisor output. |
| Output flood | Stop at exact byte crossing | `OUTPUT_LIMIT` without raw replay. |
| Parent HUP, INT, or TERM | Wait for bounded supervisor | Exact pending signal after supervisor reap. |
| Malformed or incomplete `SCS1` | Preserve unresolved findings | Closed classifier diagnostic. |

## Platform And Dependency Contract

### macOS

The supported path requires root-protected native `/bin/bash`, `/usr/bin/env`,
and `/usr/bin/perl`. Apple Python resolution retains authenticated
`xcode-select` and `xcrun` handling.

Stock macOS Bash 3.2 must execute every entry and supervisor regression case.

### Linux

The supported path requires the same fixed anchors. The design does not assume
that every distribution installs `/usr/bin/perl`.

An absent, script-backed, writable, or untrusted Perl fails closed. PATH Perl,
Python supervision, Bash watchdogs, and external `timeout` are not substitutes.

The supported Linux lane must prove one authenticated Perl and Python positive.

### Dependency Posture

The supervision architecture adds no package-manager or runtime network
dependency. It promotes a fixed host primitive into the Scan 2B authority
preflight.

The CI lane reuses hosted-runner checkout and provisioning. Those operational
dependencies do not enter Scan 2B authority.

A release image without acceptable `/usr/bin/perl` cannot earn Scan 2B
authority. The result remains visible and non-authoritative.

## Source-Only Exact-Head CI Qualification

The lane lives in `.github/workflows/agnosticity.yml`. It qualifies one source
commit through release hygiene without changing `privileged-native-supervision-v2`.

### Trigger, Isolation, And Execution Contract

| Concern | Active contract |
| --- | --- |
| Trigger | `workflow_dispatch` only. |
| Input | One required `source_sha` string matching `^[0-9a-f]{40}$`. |
| Job isolation | Only `release-hygiene-exact-head` runs for `workflow_dispatch`. Existing jobs remain limited to pull requests or pushes. |
| Permissions | Workflow token permissions are read-only with `contents: read`. |
| Platforms | One matrix spans `ubuntu-latest` and `macos-latest`. |
| Bound | Each matrix job has `timeout-minutes: 180`. |
| Release command | Run `bash bubbles/scripts/cli.sh release-check` with `BUBBLES_RELEASE_CHECK_ACCEPT_RECEIPT=0`. |

The first step validates the input before checkout. Malformed input exits `2`
before any candidate repository code can run.

Checkout uses
`actions/checkout@11d5960a326750d5838078e36cf38b85af677262`. It sets
`repository` to `github.repository`, selects `source_sha`, fetches full history,
and disables persisted credentials.

After checkout, the job derives the expected HTTPS origin from
`github.repository`. It rejects any different origin before running candidate
scripts.

The job fetches `source_sha` explicitly from that origin without tags. It
requires `FETCH_HEAD`, checked-out `HEAD`, and `source_sha` to match exactly.

The job also requires `source_sha` to resolve as a commit. Only then may it run
the source-controlled provisioner or release check.

The macOS leg resolves one validated Homebrew prefix and installs Bash 4 or
newer. Both legs require Bash 4 or newer before provisioning Python.

The release step asserts that receipt reuse remains disabled. It then passes
the disabled value explicitly to `release-check`.

### Trust Boundary

Treat `source_sha` as hostile until the anchored lowercase-hex check passes.
Treat checked-out source as untrusted until origin, fetch, commit, and HEAD
checks all pass.

The CI control plane trusts the GitHub event repository identity, the pinned
checkout action, the hosted runner, runner Git, and the same-repository origin.
These components remain outside Scan 2B's native-supervision TCB.

Exact-head means only that candidate source `HEAD` equals the fetched
same-repository commit. The workflow definition is not asserted equal to
`source_sha`.

The lane does not prove branch ancestry, signature, review approval, source
safety, or release authorization. Mutable hosted-runner images also remain a
separate evidence identity.

### Failure Boundary

| Failure | Required outcome |
| --- | --- |
| Input is not one lowercase 40-hex SHA | Exit `2` before checkout. |
| Checkout or explicit fetch fails | The affected matrix leg fails without a fallback ref. |
| Origin differs from the event repository | Fail before candidate provisioning. |
| `FETCH_HEAD`, `HEAD`, or `source_sha` differs | Fail before candidate provisioning. |
| The object is not a commit | Fail before candidate provisioning. |
| Bash or Python provisioning fails | The affected matrix leg fails. |
| The 180-minute bound expires | The affected matrix leg fails. |
| Receipt reuse is not exactly disabled | Fail before `release-check`. |
| `release-check` exits nonzero | The affected matrix leg fails with its real status. |
| Either platform lacks successful evidence | Withhold exact-head qualification. |

No retry, alternate ref, cached receipt, fallback command, or partial-platform
success can produce qualification.

### Non-Goals

- Do not bind the workflow definition itself to `source_sha`.
- Do not publish, tag, sign, deploy, or update a release manifest.
- Do not create human acceptance, DoD completion, or certification.
- Do not authorize a cross-repository ref or persist checkout credentials.
- Do not change pull-request or push release-hygiene behavior.
- Do not modify the privileged entry, Perl supervisor, Python trust, or `SCS1` contracts.

### Evidence Requirements And Ownership

Exact-head evidence must identify the workflow run, attempt, event, and supplied
`source_sha`. It must record the controlling workflow revision separately.

Each matrix leg must record its runner platform. Its logs must show the accepted
origin, fetched SHA, checked-out HEAD, provisioned tools, and release-check run.

Both legs must conclude successfully within the bound. A failed, timed-out,
cancelled, or missing leg supplies no exact-head qualification evidence.

Evidence must show receipt reuse disabled for the release step. A pre-existing
receipt cannot replace execution against the selected source commit.

Changing the source SHA, workflow revision, checkout action pin, platform, or
release command invalidates the affected evidence set.

| Surface | Owner |
| --- | --- |
| Active technical contract in this file | `bubbles.design` |
| Workflow implementation and event permissions | `bubbles.devops` |
| Persistent workflow regression proof | `bubbles.test` |
| Scope, DoD, and scenario mapping | `bubbles.plan` |
| Current-session execution evidence | The agent that executes and records the run |
| Certification and terminal status | `bubbles.validate` |
| Source SHA selection | The manual dispatcher, without certification authority |

This design claims no workflow run or release-check result.

## Required Path Widening

The earlier five-file boundary cannot update production entry sites or their
governance consumers. Scope 2 must widen before implementation begins.

### Source And Test Paths

| Path | Required responsibility |
| --- | --- |
| `bubbles/scripts/python-env.sh` | Embed the fixed supervisor. Remove Bash worker signaling and target-held completion. |
| `bubbles/scripts/python-env-selftest.sh` | Prove entry, supervisor, status, signal, output, cleanup, and mutation contracts. |
| `bubbles/scripts/implementation-reality-scan.sh` | Require `BSEC1`, consume `BPS1`, and retain fail-closed `SCS1` handling. |
| `bubbles/scripts/implementation-reality-scan-selftest.sh` | Remove worker and watchdog PID cleanup, descriptor 9, FIFO completion, and old active labels. |
| `tests/regression/test_24_g028_sensitive_client_storage.sh` | Preserve honest skip accounting and assert current supervisor contracts. |
| `bubbles/scripts/cli.sh` | Launch the scanner through the direct privileged boundary and preserve its exit. |
| `bubbles/scripts/state-transition-guard.sh` | Launch Check 16 through the same boundary and preserve its real status. |
| `bubbles/scripts/state-transition-guard-selftest.sh` | Prove direct entry and status propagation at the certification call site. |

No new supervisor file is required. The fixed Perl source remains embedded in
`python-env.sh` to avoid another mutable helper identity.

### Governance And Documentation Paths

| Path | Required responsibility |
| --- | --- |
| `.github/copilot-instructions.md` | Replace raw ordinary scanner guidance with the canonical boundary and state the direct-call limitation. |
| `templates/copilot-instructions.md.tmpl` | Keep installed downstream guidance aligned with the source instruction. |
| `agents/bubbles_shared/critical-requirements.md` | Name the required privileged reality-scan boundary without weakening the gate. |
| `agents/bubbles.validate.agent.md` | Require evidence to identify `BSEC1`, `BPS1`, and the exact candidate epoch. |
| `docs/recipes/security-review.md` | Document Perl preflight, diagnostics, remediation, and explicit non-claims. |

Canonical guidance must route ordinary users through `cli.sh scan` or the
transition guard. Raw scanner invocation remains compatibility-only.

### CI And Operational Path

| Path | Required responsibility |
| --- | --- |
| `.github/workflows/agnosticity.yml` | Add the isolated source-only exact-head matrix and preserve existing pull-request and push lanes. |

The workflow remains operational code owned by `bubbles.devops`. This design
owns only the technical contract for that surface.

### BUG-039 Artifact Family

The boundary must admit
`bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure/**`.
Artifact ownership still controls each file.

- `design.md` holds this architecture.
- `scopes.md` and `scenario-manifest.json` require planner reconciliation.
- `state.json.workBoundary.allowedPaths` requires the widened path set.
- `report.md` may receive only current execution-owner evidence.
- `uservalidation.md` remains human-owned.
- `bug.md` and `spec.md` retain the bug and outcome contracts unless their owners
  identify a real requirement conflict.

### Explicitly Unchanged Surfaces

The classifier helper stays a read-only digest-pinned input. `guard-lib.sh` may
not become a timeout or lifecycle fallback for this boundary.

Only `.github/workflows/agnosticity.yml` changes among CI surfaces. Existing
pull-request and push jobs keep their prior event boundaries.

No dependency manifest, product datastore, browser, deployment, publication,
release-manifest, acceptance, or cross-repository surface changes.

CI network use is limited to checkout, same-origin fetch, and hosted-runner
provisioning. It creates no product network contract.

## Testing And Validation Strategy

No test result is claimed here. Every item below is a required implementation
proof on the final immutable candidate.

### Scenario Mapping

| Scenario | Primary surfaces | Required observable behavior |
| --- | --- | --- |
| `SCN-B039-001` | scanner selftest and `test_24` | One unavailable prerequisite, sentinel, zero false failures, and no false pass. |
| `SCN-B039-002` | Python and scanner selftests | A direct privileged entry executes every classifier assertion. |
| `SCN-B039-003` | scanner selftest | The authorized classifier mutation executes and remains fatal. |
| `SCN-B039-004` | `test_24` | Skip and pass counters remain distinct. |
| `SCN-B039-005` | Python and scanner selftests | Hostile shell startup cannot enter privileged authority. |
| `SCN-B039-006` | Python and scanner selftests | Native supervision, fixed operation, helper, and repository-as-data boundaries hold. |
| `SCN-B039-007` | Python and scanner selftests | `waitpid`, wall, status ownership, signals, and no Bash signaling hold. |
| `SCN-B039-008` | scanner selftest and `test_24` | Target control cannot end supervision and private files are removed. |
| `SCN-B039-009` | artifact guards and identifier scan | One epoch uses only current BUG-039 identifiers. |

### Exact-Head CI Proof

| Proof type | Required assertion |
| --- | --- |
| Focused workflow contract check | One dispatch input, dispatch-only job isolation, read-only permissions, pinned checkout, full history, disabled credentials, two platforms, and 180-minute bound. |
| Input negative control | Uppercase, short, long, non-hex, or multi-value text fails before checkout. |
| Provenance negative control | A different origin, fetch result, checked-out HEAD, or non-commit object fails before candidate scripts. |
| Live dispatch | Both platform legs run against the same `source_sha` and complete release hygiene without receipt reuse. |
| Evidence review | Source SHA, workflow revision, action pin, runner platform, command, and outcome remain separate identities. |

These checks validate the CI qualification contract. They do not replace the
supervisor, classifier, acceptance, or certification scenarios.

### Finding Negative Controls

| Finding | Positive proof | Required red mutation |
| --- | --- | --- |
| `SEC-R1` | Hostile exported functions and `BASH_ENV` create no marker inside direct entry. | Remove `-p`, remove `env -i`, or source one file before the boundary. |
| `SEC-R2` | Perl signals only while it owns an unreaped worker and calls `waitpid` exactly once. | Signal after reap, clear ownership late, or add Bash worker signaling. |
| `HAR-R1` | Bash holds only a wait-only supervisor PID and propagates pending signals after reaping it. | Restore worker or watchdog PID cleanup and trigger the post-reap signal window. |
| `HAR-R2` | Descriptor closure and forged text cannot end supervision. | Give the worker the control descriptor or let EOF select success. |
| `HAR-R3` | Active artifacts contain only current finding identifiers. | Reintroduce active `SEC-OBS-002` while archived quotations remain allowed. |

### Boundary Contamination Matrix

Tests must export hostile functions named `source`, `builtin`, `return`, `exec`,
`/bin/bash`, `/usr/bin/env`, `/usr/bin/perl`, `kill`, and `wait`.

A hostile `BASH_ENV` must write a marker and alter a return status. Direct entry
must execute none of that content.

The compatibility test may observe an outer marker. It must prove the marker
does not execute again inside the privileged child.

### Supervisor Lifecycle Matrix

Persistent tests must cover:

- worker exits `0`, `73`, `124`, `125`, and `143`
- worker termination by a real signal
- supervisor timeout `124`
- caller HUP `129`, INT `130`, and TERM `143`
- setup, fork, and exec failures
- exact-limit and one-byte-over-limit output
- worker exit before the first nonblocking `waitpid`
- worker exit between a poll and TERM decision
- immediate closure of every nonstandard worker descriptor
- forged `BPS1` in worker output
- a descriptor-holding descendant
- repeated fast-exit and timeout runs under PID churn

Assertions must prove event order, status owner, timeout bit, byte counts, one
reap, and zero post-reap signal events. They must not require real PID reuse.

### Retained Helper And Classifier Matrix

The existing helper controls remain required:

- digest mismatch blocks marker writes
- subprocess, `setsid`, double-fork, dynamic import, `ctypes`, `eval`, and
  `exec` payloads cannot execute under the old digest
- path replacement after one read cannot replace executed bytes
- reopening the helper path turns the same-byte negative control red
- an authorized one-token classifier mutation executes and breaks exact tuples

### Caller And Platform Matrix

CLI tests must prove `scan` enters direct `BSEC1` and preserves scanner status.
The transition-guard selftest must prove Check 16 does the same.

Direct scanner tests must cover direct privileged entry and `compat-reexec`.
Matching inputs must produce matching Scan 2B semantics.

Run the focused matrix on stock macOS Bash 3.2 and supported Linux Bash. Each
lane must prove authenticated Perl and Python positives.

Repeat success, fast exit, timeout, output limit, and signals 30 consecutive
times. Preserve every result without retrying or widening a deadline.

Static checks permit one `$!` assignment for the supervisor wait handle. They
must reject Bash worker or watchdog PIDs, PID signals, `kill -0`, job control,
process groups, completion FIFOs, and target-held control descriptors.

## Immutable Evidence Epoch And Ownership

Only `privileged-native-supervision-v2` evidence may close the redesigned Scope
2. Earlier managed-runtime and Bash exact-child evidence remains historical.

One evidence epoch binds all of these values:

- clean immutable commit
- exact-head run identity, attempt, workflow revision, and dispatch `source_sha`
- per-leg origin, `FETCH_HEAD`, `HEAD`, action pin, and runner platform
- helper digest
- `BSEC1`, `BPS1`, `PYSEC1`, `PYMOD1`, and `SCS1` protocol versions
- macOS and Linux platform identities
- focused scenario and mutation results
- disabled release-check receipt reuse
- complete `framework-validate` and `release-check` results
- independent security review
- fresh human acceptance
- validate-owned certification

Changing any implementation, test, protocol, digest, or active planning byte
invalidates the affected evidence. Pass totals never replace named scenario,
finding, command, and candidate identities.

Planner-owned reconciliation must happen before implementation. It must replace
the old exact-child Scope 2 contract, update the path boundary, and preserve all
nine scenario IDs.

Implementation and test owners may record only current-epoch evidence. Only
`bubbles.validate` may write certification or terminal status.

The exact-head lane may supply release-check evidence only when both matrix
legs satisfy the source, workflow, platform, and no-receipt identities above.

## Migration, Rollout, And Safe Rollback

The implementation must land as one coherent security epoch. A mixed entry,
supervisor, runtime, or planning contract cannot earn authority.

The required order is:

1. Reconcile Scope 2 and widen the approved paths.
2. Add red tests for all five current findings.
3. Add direct privileged entry to the scanner and both production callers.
4. Replace Bash lifecycle logic with the fixed native supervisor.
5. Remove watchdog, FIFO, worker PID, and stale cleanup mechanisms.
6. Retain Python trust, helper identity, `SCS1`, and skip behavior.
7. Update active identifiers and required guidance.
8. Reconcile the exact-head workflow contract and its focused controls.
9. Execute focused macOS and Linux matrices on one immutable candidate.
10. Dispatch exact-head release hygiene for that same source SHA.
11. Execute complete framework and release gates on that candidate.
12. Obtain independent security review, human acceptance, and certification.

Safe rollback means fail closed. It disables authoritative Scan 2B acceptance
when privileged entry or native supervision is unavailable.

Rollback must not restore ordinary Bash authority, a Bash watchdog,
target-controlled completion, positive worker-PID cleanup, managed-runtime
self-attestation, or a shell timeout fallback.

## Alternatives And Tradeoffs

### Keep Builtin-Qualified Bash Cleanup

Rejected. Imported functions can affect shell control before qualification.
Bash PID text also does not prove an unreaped parent-child relationship.

### Rely Only On Scanner Re-Exec

Rejected for canonical callers. Re-exec preserves compatibility but cannot undo
earlier `BASH_ENV` activity.

### Keep FIFO Completion And A Bash Watchdog

Rejected. A target can close inherited descriptors. A second Bash PID also
recreates stale signaling and status-ownership problems.

### Use Process Groups Or Descendant Enumeration

Rejected. `setsid`, double-fork, reparenting, exit, and PID reuse defeat the
portable claim.

### Use Linux-Only Process Facilities

Rejected. pidfds, cgroups, and `/proc` do not provide the required macOS
contract.

### Use External `timeout`

Rejected. It is not a macOS base primitive and loses exact status ownership.

### Use Python As Its Own Supervisor

Rejected. The Python runtime and module closure are subjects of authentication.
Self-supervision would create circular authority.

### Add A Compiled Supervisor

Rejected. It adds a build, signing, architecture, and installation pipeline.
Fixed Perl supplies the required Unix process primitives.

### Add A Separate Perl File

Rejected. Another mutable helper creates a new identity and packaging edge.

### Select Perl From PATH Or Add A Bash Fallback

Rejected. Either choice reopens caller executable authority or restores the
invalidated lifecycle.

## Complexity Tracking

| Decision | Simpler alternative | Why rejected |
| --- | --- | --- |
| Direct privileged entry | Qualify Bash builtins | Qualification does not stop exported functions or `BASH_ENV`. |
| Native `fork` and `waitpid` | Bash worker and watchdog | Bash may retain recyclable PID text after child reaping. |
| Streaming output limits | Check file size afterward | A worker can exceed the bound before inspection. |
| Closed `BPS1` ownership | Numeric status only | The same status can belong to worker, supervisor, or caller signal. |
| Widened caller boundary | Keep five files | Production callers currently create ordinary Bash scanner processes. |
| Embedded Perl source | Separate helper | A new file adds identity and packaging obligations. |
| Fail closed without Perl | Shell fallback | A fallback restores the rejected security path. |
| Separate exact-head matrix | Reuse branch-triggered jobs | A dedicated dispatch isolates source qualification from pull-request and push behavior. |

## Risks And Open Questions

### Accepted Risks

- A host without authenticated `/usr/bin/perl` cannot earn Scan 2B authority.
- An ordinary direct caller may execute hostile `BASH_ENV` before re-exec.
- Compromised root, kernel, filesystem, Perl, Python, or framework source
  invalidates the trust anchor.
- A compromised worker may create descendants that outlive it.
- Kernel-uninterruptible worker state may exceed userspace timing.
- SIGKILL or host termination may leave private capture files.
- The embedded supervisor expands the reviewed TCB in `python-env.sh`.
- Source exact-head does not make the workflow definition or runner image immutable.
- The lane can test a same-repository commit without proving release approval.

### Remaining Architecture Questions

None. Platform availability is an explicit prerequisite, not an implicit
fallback decision.

## Archive: Superseded Design Decisions

Everything below this heading is historical and non-authoritative. The content
remains in its original order so reviewers can trace the prior
`root-protected-native-python-v1` direct-child design and its managed-runtime
predecessor. Its headings are archival even when their original wording uses
the present tense.

### Archived Epoch: Root-Protected Scan 2B Authority

### Archived Section: Design Brief

### Current State

The current candidate gives Scan 2B authority to the managed virtualenv selected by
`bubbles_python_resolve_trusted_runnable()` in
`bubbles/scripts/python-env.sh`. A successful payload probe establishes usability,
but it does not authenticate the executable that produced the payload.

The same module exposes `bubbles_python_run_bounded()` for arbitrary commands.
That runner enables Bash job control and signals negative process-group IDs.
Its callers and selftests also retain descendant PID numbers for cleanup.

### Target State

Scan 2B will accept output only from a root-protected native Python runtime.
The trust contract proves filesystem protection, not operating-system provenance.
It rejects any path the non-root caller can replace or modify.

The scanner will use only fixed operations over an authenticated runtime.
It will pin the classifier helper bytes before those bytes execute.
The supervisor will track, signal, and reap one exact direct child.

### Patterns To Follow

- Keep classification logic in `bubbles/scripts/guards/sensitive-client-storage-scan.py`.
- Keep fail-closed degradation in `bubbles/scripts/implementation-reality-scan.sh`.
- Keep general Python resolution separate in `bubbles/scripts/python-env.sh`.
- Keep `SCS1` as the closed classifier result protocol.
- Keep `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1` as the machine skip signal.

### Patterns To Avoid

- Do not treat a challenge response as executable authentication.
- Do not treat a managed directory, PATH order, or package-manager brand as authority.
- Do not execute the macOS `/usr/bin/python3` launcher before resolving its target.
- Do not accept a caller-selected executable in the security runner.
- Do not use Bash job control, negative PID signaling, or PID-liveness polling.
- Do not claim recursive containment against `setsid`, double-fork, or runtime compromise.
- Do not retain descendant PID numbers for later destructive cleanup.
- Do not replay child output or environment values in diagnostics.

### Resolved Decisions

- The trust contract is `root-protected-native-python-v1`.
- Root ownership is necessary, but it never proves vendor or package provenance.
- A UID 0 caller cannot establish separation and receives a fail-closed result.
- Homebrew, MacPorts, Python.org, and OS paths are judged by identical controls.
- Apple launcher resolution uses authenticated `xcode-select` and `xcrun` operations.
- Python starts with an empty environment and `-I -S -B`.
- `PYSEC1` validates runtime posture and import search roots.
- `PYMOD1` validates loaded module origins before classification.
- The helper digest binds the exact bytes compiled and executed.
- `BPY1` readiness, FIFO EOF, and exact `wait` establish child completion.
- Every production wall limit is fixed at 30 seconds.
- All captures and FIFOs have deterministic signal and EXIT cleanup.

### Open Questions

None. Source changes, tests, security review, and certification remain unexecuted.

### Archived Section: Purpose And Scope

This design replaces the candidate's self-attested managed-runtime authority.
It also replaces the generic process-group runner used by the security path.
The design preserves `SCN-B039-001` through `SCN-B039-004`.

No analyst-owned requirement change is needed.
The revised mechanisms preserve all six requirements in `spec.md`.
The scanner still fails closed when authoritative classification cannot run.

The ratified implementation boundary remains sufficient:

| Path | Planned responsibility |
| --- | --- |
| `bubbles/scripts/python-env.sh` | Separate general usability from security authority. Add path authentication and fixed-operation supervision. |
| `bubbles/scripts/python-env-selftest.sh` | Pin trust, runner, status, signal, cleanup, and negative-control contracts. |
| `bubbles/scripts/implementation-reality-scan.sh` | Route Scan 2B through the authenticated runtime and same-byte helper driver. |
| `bubbles/scripts/implementation-reality-scan-selftest.sh` | Exercise all four scenarios and the security matrix through production paths. |
| `tests/regression/test_24_g028_sensitive_client_storage.sh` | Preserve honest skip accounting and the cross-runner cascade. |

The classifier helper remains unchanged.
Its bytes become a pinned input to the fixed driver.
No other `command -v python3` caller enters this packet.

`SEC-OBS-002` concerns G022 plan and design phase vocabulary.
It is explicitly excluded from BUG-039 and receives no design change here.

This document contains design decisions only.
It does not claim that source, tests, or evidence implement these decisions.

### Archived Section: Requirement Reconciliation

| Existing requirement | Active technical realization |
| --- | --- |
| Requirement 1 | The selftest withholds classifier-dependent assertions when no authenticated runtime can execute. It emits one named skip and no classifier-attributed failures. |
| Requirement 2 | The skip carries a numeric status, closed diagnostic, validated path context, and an exact operator action. Xcode licence failures retain status `69`. |
| Requirement 3 | `SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1` appears only when the scenario group did not execute. |
| Requirement 4 | An authenticated usable runtime executes every semantic and configuration assertion. A one-token classifier mutation remains fatal. |
| Requirement 5 | All 23 runtime-dependent assertions are withheld together. None can emit a vacuous pass or failure. |
| Requirement 6 | `test_24` increments only `SKIP_COUNT` for the sentinel. `FAIL_COUNT` continues to govern its exit status. |

The term "usable interpreter" retains its observable meaning.
Security authority adds a prerequisite before Scan 2B can accept that interpreter's output.
An executable that runs but lacks authority cannot produce an earned verdict.

### Archived Section: Current Source Facts

The following facts were read from the exact combined candidate before this edit:

| Surface | Current fact that constrains the design |
| --- | --- |
| `python-env.sh` | `managed-venv-only-v1` accepts a user-controlled managed interpreter after a forgeable payload probe. |
| `python-env.sh` | `bubbles_python_run_bounded()` accepts an arbitrary command vector, enables `set -m`, and signals a negative process-group ID. |
| `python-env.sh` | Cleanup calls unqualified `kill` and `wait`, which a sourcing caller can shadow with shell functions. |
| `implementation-reality-scan.sh` | Scan 2B invokes the generic runner and accepts a valid `SCS1` stream from the selected managed interpreter. |
| Three shell test files | Lifecycle fixtures retain numeric descendant PIDs and can send destructive signals after those PIDs become stale. |
| Classifier helper | The current file is 39,534 bytes. Its SHA-256 is `77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3`. |
| Classifier helper | Its imports are standard-library modules. The reviewed file has no process-launch, fork, session, socket, or dynamic-import call. |
| CI | `.github/workflows/agnosticity.yml` runs release hygiene on Ubuntu and macOS. |

The five superseded runner and trust APIs have no source consumer outside the
five-file boundary in this candidate.
That inventory permits replacement without silently widening implementation scope.

### Archived Section: Security Objective And Threat Model

### Security Objective

A clean Scan 2B contribution requires all of these conditions:

1. Candidate discovery does not execute caller-owned code.
2. The selected runtime path and every resolved target are root-protected.
3. The selected target is a native ELF or Mach-O executable.
4. Python starts without caller-controlled loader or Python environment state.
5. Python reports the required isolated posture and supported version.
6. Every import search root and loaded module origin is root-protected.
7. The classifier helper matches the reviewed digest and size limit.
8. The driver compiles and executes the exact byte buffer it checked.
9. The direct child completes before the fixed wall deadline and is reaped.
10. The captured output satisfies the existing `SCS1` protocol.

Failure of any condition invokes the existing Scan 2B fail-closed path.
No alternate interpreter becomes authoritative after an authenticated execution fails.

### Hostile Inputs

The design treats these values and files as untrusted:

- `BUBBLES_PYTHON`, `BUBBLES_PYTHON_HOME`, `XDG_CACHE_HOME`, and `HOME`
- PATH entries and executables writable by the invoking user
- `PYTHONPATH`, `PYTHONHOME`, virtualenv variables, and all other `PYTHON*` values
- `LD_*`, `DYLD_*`, locale values, and loader injection variables
- `DEVELOPER_DIR` until its complete path passes the trust contract
- project source and project configuration under scan
- a fake executable that prints the expected probe token
- a fake executable that prints a syntactically clean `SCS1` stream
- malformed output, oversized output, crashes, hangs, and signal exits
- relative, empty, aliased, writable, cyclic, or control-bearing path text
- classifier helper bytes that differ from the reviewed digest

### Trusted Computing Base

The design trusts these components:

- the checked-out scanner, Python environment module, and fixed Python driver
- `/bin/bash` and the Bash builtins named by the runner contract
- fixed absolute base-system utilities used by metadata, files, and launch
- kernel ownership, permission, pipe, signal, and process-parent semantics
- a root-protected native Python and its validated import closure
- the classifier helper only after its exact digest matches

An attacker who can change the scanner or its embedded digest can change the verifier.
That attacker is outside this guard's enforceable boundary.

Root, kernel, filesystem-driver, package-manager authority, and OS image compromise
are also outside the boundary.
The contract assumes kernel-reported ownership and access checks are authoritative.

### Residual Process Threat

The runner guarantees termination and reaping for one exact direct child.
It does not guarantee recursive descendant containment.

A compromised trusted runtime could fork, double-fork, or call `setsid`.
A caller-controlled filesystem implementation could also lie about metadata.
Neither condition may be described as contained.

The design removes untrusted executable launch from the security path.
It also rejects changed helper bytes before compilation.
These controls prevent the known escape fixtures from becoming executable input.

### Archived Section: Finding Accounting

| Finding | Design accounting | Closure state after this design |
| --- | --- | --- |
| `SEC-B039-001` | Replace managed self-attestation with pre-execution root-protected path, native-format, environment, and import-closure checks. | Design-accounted. Implementation and independent security proof remain required. |
| `SEC-B039-002` | Remove the generic command vector from security execution. Expose only fixed operations and state the direct-child residual boundary. | Design-accounted. Implementation and adversarial proof remain required. |
| `SEC-B039-003` | Remove job control, negative signaling, `kill -0`, and descendant PID retention. Use builtin-qualified exact-child supervision. | Design-accounted. macOS and Linux proof remain required. |
| `SEC-B039-004` | Define one final implementation epoch. Invalidate managed-runtime evidence and require planner-owned contract reconciliation before certification. | Design-accounted. Planner and validation ownership remain active. |
| `SEC-OBS-001` | Register every capture, FIFO, descriptor, and temporary directory before launch. Clean them on normal return, signal, and EXIT. | Design-accounted. Signal-path tests remain required. |
| `SEC-OBS-002` | Keep the plan/design phase-vocabulary observation outside this packet. It belongs to G022. | Accounted by explicit exclusion. No BUG-039 change is authorized. |

No finding above is claimed fixed in source.

### Archived Section: Architecture Overview

```text
implementation-reality-scan.sh
  -> collect Scan 2B source paths
  -> python-env.sh security runtime resolver
    -> discover fixed and PATH-derived candidates without executing them
    -> resolve the Apple launcher target through fixed xcode-select/xcrun operations
    -> validate ancestors, links, target metadata, and native format
    -> run PYSEC1 in an empty isolated environment
    -> validate executable, prefixes, and search roots
    -> run PYMOD1 and validate loaded module origins
  -> fixed scan2b-classify operation
    -> create private bounded captures and BPY1 FIFO
    -> launch one exact direct child without job control
    -> read helper bytes once and verify size plus SHA-256
    -> compile and execute the same byte buffer
    -> classify project files as data and emit SCS1
    -> require BPY1 readiness, FIFO EOF, exact wait, and SCS1 completion
  -> emit findings or preserve fail-closed unresolved findings
```

The general Python resolver remains available for non-security consumers.
Its success has no path into the security runtime globals or Scan 2B acceptance.

### Archived Section: Data Model

No state persists across scanner runs.
The following records exist only in shell variables and private captures:

| Record | Required fields | Invariant |
| --- | --- | --- |
| `SecurityRuntimeIdentity` | candidate, resolved target, reported executable, trust contract, provenance | Runtime fields are non-empty only after path, posture, and closure validation. |
| `RuntimeResolution` | numeric status, diagnostic, rejection, candidate count | Status is zero only with diagnostic `OK`. |
| `SecurityRunResult` | operation, direct child PID, status, diagnostic, timeout ownership, readiness, FIFO EOF | The PID is cleared immediately after exact `wait`. |
| `ClassifierVerdict` | status, diagnostic, scanned count, finding count, protocol version | Diagnostic is `OK` only after trusted execution and complete `SCS1`. |
| `CleanupRegistry` | private directory, stdout path, stderr path, FIFO path, open descriptors | Every entry is cleared by the same idempotent cleanup path. |

No record contains raw child output or environment values.
Capture paths never leave the current process tree.

### Archived Section: API And Contracts

| API | Inputs | Outputs | Authority |
| --- | --- | --- | --- |
| `bubbles_python_runs()` | one general interpreter path | usability status and closed diagnostic | General only |
| `bubbles_python_resolve_runnable()` | none | existing ordered general resolution | General only |
| `bubbles_python_resolve_security_runtime()` | none | authenticated runtime identity and closed diagnostics | Security authority |
| `bubbles_python_run_security_operation()` | closed operation, registered captures, validated operation data | exact child status and closed runner diagnostics | Security execution |
| `bubbles_python_security_cleanup()` | current registered lifecycle state | no output | Exact-child and private-file cleanup |

`python-env.sh` owns the fixed operation programs and helper digest.
`implementation-reality-scan.sh` owns `SCS1` parsing and fail-closed findings.

No new scanner flag, environment override, or executable-selection API is introduced.

### Archived Section: Capability Foundation

`python-env.sh` owns two separate capability classes.
It must never promote a general usability result into security authority.

### General Python Capability

The general capability answers whether an interpreter can run a fixed probe.
It preserves the existing resolution order for general consumers:

1. `BUBBLES_PYTHON`
2. the managed virtualenv
3. `python3` from PATH

`bubbles_python_runs()` remains a usability check only.
It invokes one fixed Python probe and accepts no arbitrary command vector.

The general probe can execute a caller-selected interpreter.
It therefore makes no trust or descendant-containment claim.
Security code must never call it.

### Security Runtime Capability

`bubbles_python_resolve_security_runtime()` accepts no candidate argument.
It ignores all general resolver locators and overrides.
It emits no stdout when called as a sourceable API.

It returns `0` only after path authentication, `PYSEC1`, and `PYMOD1` pass.
It returns `1` for an unavailable or rejected runtime.
It returns `2` for an internal contract error.

It always sets these diagnostic globals:

```text
BUBBLES_PYTHON_SECURITY_RUNTIME
BUBBLES_PYTHON_SECURITY_STATUS
BUBBLES_PYTHON_SECURITY_DIAGNOSTIC
BUBBLES_PYTHON_SECURITY_REJECTION
BUBBLES_PYTHON_SECURITY_CANDIDATE_COUNT
BUBBLES_PYTHON_SECURITY_PROVENANCE
BUBBLES_PYTHON_SECURITY_TRUST_CONTRACT
```

The runtime path and provenance are non-empty only after complete authentication.
The trust contract always reads `root-protected-native-python-v1`.

### Fixed Security Execution Capability

`bubbles_python_run_security_operation()` accepts only a closed operation name,
registered capture paths, and operation-specific data paths.
It never accepts an executable, module name, helper path, or Python program.

The runner revalidates the stored runtime identity before every Python launch.
Positive globals are diagnostics and never act as bearer credentials.

The following candidate APIs are removed:

- `bubbles_python_run_bounded()`
- `bubbles_python_terminate_process_group()`
- `bubbles_python_terminate_active_tree()`
- `bubbles_python_resolve_trusted_runnable()`
- `BUBBLES_PYTHON_TRUSTED*`

Their current in-repository consumers all live inside the approved boundary.

### Archived Section: Concrete Implementations

### `general-python-usability-v2`

This implementation preserves non-security resolution behavior.
It probes only the supplied interpreter with one fixed payload.
It tracks and reaps its exact direct child within the fixed wall limit.

It does not authenticate the interpreter.
It does not promise cleanup of a malicious interpreter's descendants.

### `root-protected-native-python-v1`

This implementation authenticates a native Python through filesystem protection.
Every ancestor, symlink, final target, search root, and module origin receives checks.

The name deliberately avoids `os-owned`.
Root metadata cannot prove whether Apple, a Linux distribution, MacPorts,
Python.org, or another privileged installer supplied a file.

### Apple Launcher Resolver

The Apple resolver handles `/usr/bin/python3` without executing that launcher.
It authenticates and invokes fixed `xcode-select` and `xcrun` operations first.
The Python path returned by `xcrun --find python3` then receives full authentication.

### Scan 2B Adapter

The adapter consumes only `root-protected-native-python-v1`.
It validates helper identity, execution lifecycle, and `SCS1`.
It never falls through to `general-python-usability-v2`.

### Variation Axes

| Axis | General capability | Security capability |
| --- | --- | --- |
| Purpose | Usability | Clean security-verdict authority |
| Candidate sources | Override, managed environment, PATH | Fixed system candidate and absolute PATH entries |
| Ownership | User-owned allowed | UID 0 required |
| Caller write access | Allowed | Rejected |
| File format | Any executable | Native ELF or Mach-O only |
| Environment | General caller environment | Empty environment with closed values |
| Python posture | Probe-specific | `-I -S -B`, Python 3.9 or newer |
| Execution surface | Fixed general probe | Closed authenticated operations only |
| Failure effect | Candidate declines | Scan 2B fails closed |

### Archived Section: Runtime Trust Contract

### Candidate Discovery

The resolver constructs candidates without `command -v`.
It evaluates each candidate independently in this order:

1. `/usr/bin/python3`, when present
2. `<entry>/python3` for each absolute PATH entry, in PATH order

Empty and relative PATH entries produce no candidate.
Duplicate candidate strings are removed with a Bash 3.2 indexed-array loop.
Control bytes, tabs, carriage returns, and newlines cause rejection before logging.

`BUBBLES_PYTHON`, managed-environment locators, and home paths are ignored.
They remain inputs to the general capability only.

A rejected candidate never authorizes or poisons another candidate.
The resolver may continue only to the next independently authenticated path.
If none succeeds, it publishes one deterministic aggregate diagnostic.

### Root-Protected Path Algorithm

The resolver first requires `EUID != 0`.
A UID 0 caller can modify root-owned candidates and has no separated anchor.
That invocation returns `CALLER_WRITE_AUTHORITY_UNSEPARATED` before launch.

The metadata helper capability-tests BSD and GNU `stat` formats.
It validates the complete record shape rather than trusting command exit alone.
It never branches on an operating-system name.

Every directory from `/` through the candidate parent must satisfy all checks:

- owner UID equals `0`
- file type is directory
- group-write and other-write mode bits are clear
- Bash reports the directory not writable by the effective caller

The final target must satisfy all checks:

- owner UID equals `0`
- file type is a regular executable
- group-write and other-write mode bits are clear
- setuid and setgid mode bits are clear
- Bash reports the file not writable by the effective caller

The explicit write test catches an ACL that grants this caller write access.
The contract does not claim to model another user's ACL rights.

### Symlink Resolution

The resolver inspects each symlink before following it.
The symlink and its containing directory must be UID 0 owned and protected.

Relative targets resolve against the verified link parent.
Absolute targets restart validation from `/`.
Lexical normalization handles `.` and `..` using indexed arrays.

Every normalized target receives the complete ancestor and final-target checks.
A repeated target yields `SYMLINK_CYCLE`.
More than 32 links yields `SYMLINK_DEPTH`.

Symlink mode bits are not treated as authority.
The protected parent controls replacement and the target receives independent checks.

### Native Executable Check

The final target's first four bytes must match one accepted native format:

- ELF `7f454c46`
- Mach-O `feedface`, `cefaedfe`, `feedfacf`, or `cffaedfe`
- fat Mach-O `cafebabe`, `bebafeca`, `cafebabf`, or `bfbafeca`

This check rejects scripts and text wrappers.
It does not prove vendor identity and cannot replace path authentication.

### Apple Launcher Resolution

When the candidate is `/usr/bin/python3` and both Apple resolver tools exist,
the resolver takes this path:

1. Validate `/usr/bin/xcode-select` and `/usr/bin/xcrun` as protected native tools.
2. If `DEVELOPER_DIR` is set, validate that complete directory path.
3. Otherwise run the fixed `xcode-select -p` operation and validate its one-line result.
4. Run fixed `xcrun --find python3` under `env -i` with `LC_ALL=C` and the validated directory.
5. Require one bounded absolute result and authenticate its full symlink chain.
6. Execute the authenticated target directly for all Python operations.

The design never runs `/usr/bin/python3` to discover where it will dispatch.
This closes the pre-authentication launcher gap in the diagnostic draft.

An `xcrun` status `69` with the known licence signature maps to
`XCODE_LICENSE_UNACCEPTED`.
No Python candidate executes in that path.

Other `xcode-select` or `xcrun` failures map to closed resolver diagnostics.
Raw tool output remains inside a bounded private capture.

### Trust-Anchor Evaluation

| Installation or caller class | Decision |
| --- | --- |
| User-owned Homebrew prefix | Reject before execution. The package brand cannot override caller writability. |
| Root-protected Homebrew, MacPorts, or Python.org path | Accept only if every link, ancestor, target, search root, and module origin passes. |
| Root-owned link into a user-owned package tree | Reject the first unprotected target component. |
| Root-owned Linux distribution Python | Accept after native, isolated-posture, search-root, and module-origin checks. No fixed Linux prefix is assumed. |
| Nix-style root-protected store path | Eligible through an absolute PATH entry when its complete chain passes. |
| Conda or virtualenv under a user directory | Reject before execution. |
| UID 0 caller | Reject because caller and root authority are not separated. |

On the review host, `/opt/homebrew` is UID 501 owned and is rejected.
`/opt/local` is root-protected, but no `python3` entry exists there.
The Command Line Tools resolver returns a root-protected Python 3.9.6 symlink.

The same `xcrun` operation returns status `69` for the unaccepted Xcode directory.
That observation confirms pre-Python licence diagnosis on the reviewed macOS host.

No Linux runtime was executed during this design-only run.
Ubuntu behavior therefore remains a required implementation proof, not a current claim.

### Sanitized Python Environment

Each Python operation starts through authenticated absolute `/usr/bin/env` with
an empty environment.
The child receives only `LC_ALL=C`.

Apple resolver operations may also receive a validated `DEVELOPER_DIR`.
Direct Python operations never need that variable.

Python receives `-I -S -B`.
Standard input is `/dev/null`.
Standard output, standard error, and lifecycle control use separate private files.

No PATH, home, cache, virtualenv, loader, or Python override reaches Python.

### `PYSEC1` Runtime Protocol

The fixed runtime probe imports only `sys`.
It emits tab-delimited records for these facts:

- protocol version and Python major plus minor version
- isolated, no-site, ignore-environment, and no-bytecode flags
- `sys.executable`
- base and executable prefixes
- every `sys.path` entry
- one final search-root count

The parser requires Python 3.9 or newer and all four posture flags equal to `1`.
It requires absolute executable, prefix, and search paths.

Every existing path receives full root-protected checks.
A missing archive path may pass only when its nearest existing parent passes.
The parser rejects current-directory, relative, empty, duplicate, and trailing records.

### `PYMOD1` Module-Origin Protocol

The fixed module probe imports the exact modules needed by the driver and helper:

- `ast`, `dataclasses`, `hashlib`, `os`, `pathlib`
- `re`, `sys`, `types`, and `typing`

It reports every loaded module with a built-in, frozen, or file origin.
Every file origin must be absolute and root-protected.

The protocol requires every named module and an exact final record count.
It rejects missing, relative, writable, malformed, duplicate, and trailing records.

The empty environment removes loader injection variables.
The verified binary and OS loader configuration remain inside the declared TCB.

### Classifier Helper Identity

The helper path is fixed relative to the scanner.
The caller cannot supply a helper path.

The fixed driver enforces these checks before helper execution:

1. Open the helper once for reading.
2. Read at most 256 KiB plus one detection byte.
3. Reject any byte count above 256 KiB.
4. Require SHA-256 `77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3`.
5. Decode the same byte buffer as UTF-8.
6. Compile that buffer with the fixed helper path as its source name.
7. Execute the compiled object in a fresh registered module.
8. Call `parse_project_config()` and `analyze_file()` from that module.

The driver never reopens or imports the helper path.
The checked bytes and executed bytes are identical.

The digest is not a Python sandbox.
It binds one reviewed framework helper to the scanner's reviewed trust boundary.
A helper change requires a matching digest review and negative-control update.

### Archived Section: Fixed-Wall Supervision Contract

### Closed Operations

| Operation | Executable identity | Caller-supplied values |
| --- | --- | --- |
| `general-probe` | General candidate, never security-authoritative | Interpreter path only |
| `apple-select` | Root-protected `/usr/bin/xcode-select` | None |
| `apple-find-python` | Root-protected `/usr/bin/xcrun` | Validated developer directory only |
| `runtime-probe` | Internally authenticated Python | None |
| `module-probe` | Internally authenticated Python | None |
| `scan2b-classify` | Internally authenticated Python and fixed driver | Repository, config, and source data paths |

Security callers cannot select the executable for the last five operations.
`general-probe` belongs only to the general capability.

The scanner converts every operation data path to an absolute path.
The fixed driver requires the config and each source to resolve within the repository.
Project source enters only as data and never as Python code or a shell command.

### Fixed Limits

Every production operation has a 30-second wall limit.
No environment variable or caller argument changes that value.

| Operation | stdout limit | stderr limit |
| --- | ---: | ---: |
| `general-probe` | 16 KiB | 16 KiB |
| `apple-select` | 4 KiB | 16 KiB |
| `apple-find-python` | 4 KiB | 16 KiB |
| `runtime-probe` | 16 KiB | 16 KiB |
| `module-probe` | 64 KiB | 16 KiB |
| `scan2b-classify` | 4 MiB | 64 KiB |

The child applies a coarse file-size resource limit before launch.
The parent then checks exact byte counts before parsing.
Any limit breach fails closed and no raw bytes enter diagnostics.

Tests that need shorter deadlines modify a copied runner.
No test-only timeout variable enters the production contract.

### Private Files And Permissions

The runner sets `umask 077` before creating state.
It creates one private directory with mode `0700`.

Standard output and error captures are regular files with mode `0600`.
The lifecycle FIFO also has mode `0600`.
All paths live inside the registered private directory.

The runner registers each path before any child can use it.
Partial setup failure removes every path created so far.

### `BPY1` Readiness And Completion

The lifecycle FIFO carries one readiness record:

```text
READY\tBPY1\t<operation>
```

A child-side limit setup failure emits one alternate record:

```text
ERROR\tBPY1\t<operation>\tLIMIT_SETUP_FAILED
```

The parent opens a read-write anchor before launch.
It then opens the read descriptor while that anchor prevents open deadlock.

The background subshell closes inherited parent descriptors.
It opens the FIFO writer and applies resource limits.
It writes `ERROR` and exits `125` if limit setup fails.
Otherwise it writes `READY`.
It then immediately `exec`s the fixed operation.
The subshell PID therefore becomes the operation PID.

After the exact readiness record, the parent closes its anchor.
It performs one more timed read and requires FIFO EOF before the deadline.
Any second record is `CONTROL_MALFORMED`.

The parent checks pending signals before interpreting a failed read.
A failed read before the deadline is EOF.
A failed read at or after the deadline is `CONTROL_TIMEOUT`.

FIFO EOF proves every inherited writer closed.
The parent then calls exact-child `wait` and preserves the returned status.
Python operations also require their own final protocol record.

The lifecycle sequence is fixed and contains no retry or polling loop.

### Launch Registration And Signals

Before the background launch, the runner enters `LAUNCHING` state.
Signal traps record the requested status without assuming a PID exists.

The command after `&` assigns `$!` to the active PID.
The runner then enters `REGISTERED` and checks any pending signal immediately.
No unrelated command may occur between those steps.

If a signal arrives after registration, cleanup addresses only that positive PID.
The runner uses `builtin kill` and `builtin wait`.
Caller functions named `kill` or `wait` cannot intercept those operations.

The runner never uses `set -m`, `jobs`, `disown`, `kill -0`, or negative PIDs.
It never discovers descendants and never records a descendant PID.

Signal mapping is fixed:

| Signal | Returned status |
| --- | ---: |
| HUP | 129 |
| INT | 130 |
| TERM | 143 |

The signal handler closes descriptors after exact-child cleanup.
It then removes the private directory and restores the caller's prior traps.

### Status And Diagnostic Mapping

| Condition | Numeric status | Diagnostic |
| --- | ---: | --- |
| Operation and payload complete | 0 | `OK` |
| Invalid operation or arguments | 2 | `ARGUMENT_INVALID` |
| No eligible candidate | 127 | `NO_CANDIDATE` |
| Candidate rejected before execution | 127 | `NO_AUTHENTICATED_CANDIDATE` plus rejection enum |
| Apple licence refusal | 69 | `XCODE_LICENSE_UNACCEPTED` |
| Runner-owned deadline | 124 | `CONTROL_TIMEOUT` with `timedOut=1` |
| Runner setup or protocol failure | 125 | Closed setup or control diagnostic |
| Child exits nonzero before timeout | Exact child status | `CHILD_EXIT_NONZERO` with `timedOut=0` |
| HUP, INT, or TERM received by runner | 129, 130, or 143 | Matching signal diagnostic |
| Output limit exceeded | 125 | `OUTPUT_LIMIT` |

A child-owned status `124`, `125`, or `143` keeps that numeric value.
The diagnostic and `timedOut` bit distinguish ownership.
The runner never infers timeout from a signal-shaped child status.

### Cleanup State Machine

One cleanup function owns all security-operation resources.
It is idempotent and follows this order:

1. Disable its own signal and EXIT traps through Bash builtins.
2. If an active direct child exists, send TERM and then KILL to that positive PID.
3. Wait for that exact child and immediately clear the active PID.
4. Close every registered FIFO descriptor.
5. Remove the complete private directory through absolute `/bin/rm`.
6. Clear every registered path and lifecycle state.
7. Restore prior caller traps when returning from a sourceable API.

Normal success calls the same cleanup after the child is reaped.
Signal and EXIT paths call it before returning their preserved status.

The scanner and both selftests also register their outer private roots.
Their traps remove those roots after the security runner completes cleanup.

No cleanup path reads a saved descendant PID.
No failed assertion sends a destructive signal to an observed PID number.

### Archived Section: Protocol And Error Model

### Security Runtime Diagnostics

`BUBBLES_PYTHON_SECURITY_DIAGNOSTIC` uses this closed vocabulary:

| Diagnostic | Meaning |
| --- | --- |
| `NOT_RUN` | Resolution has not started. |
| `OK` | One runtime completed every trust and closure check. |
| `CALLER_WRITE_AUTHORITY_UNSEPARATED` | UID 0 cannot establish caller separation. |
| `NO_CANDIDATE` | No candidate path exists. |
| `NO_AUTHENTICATED_CANDIDATE` | Candidates exist, but all fail pre-execution trust. |
| `METADATA_UNAVAILABLE` | Required metadata cannot be obtained or parsed. |
| `APPLE_RESOLUTION_UNAVAILABLE` | Fixed Apple resolver tools or records failed. |
| `DEVELOPER_DIR_UNTRUSTED` | The selected developer directory is not protected. |
| `XCODE_LICENSE_UNACCEPTED` | Trusted `xcrun` returned the known status and signature. |
| `PROBE_TIMEOUT` | An authenticated candidate exceeded the fixed wall. |
| `PROBE_EXIT_NONZERO` | An authenticated candidate exited nonzero. |
| `PROBE_PROTOCOL_INVALID` | `PYSEC1` is incomplete, malformed, or polluted. |
| `PYTHON_VERSION_UNSUPPORTED` | Python is earlier than 3.9. |
| `RUNTIME_CLOSURE_UNTRUSTED` | Executable, prefix, or search-root trust failed. |
| `MODULE_PROTOCOL_INVALID` | `PYMOD1` is incomplete, malformed, or polluted. |
| `MODULE_CLOSURE_UNTRUSTED` | A loaded module origin failed trust. |

When no candidate succeeds, aggregate diagnostics use this priority:

1. caller separation or metadata failure
2. Xcode licence refusal
3. untrusted developer directory
4. runtime or module closure failure
5. unsupported Python version
6. timeout or nonzero probe exit
7. no candidate or no authenticated candidate

Ties use candidate discovery order.

Candidate rejection uses exactly these values:

| Rejection | Meaning |
| --- | --- |
| `NONE` | No candidate rejection exists. |
| `ABSENT` | The candidate path does not exist. |
| `PATH_TEXT_UNSAFE` | Path text contains a forbidden delimiter or control byte. |
| `NOT_ABSOLUTE` | A candidate or required target is relative. |
| `ANCESTOR_OWNER` | An ancestor is not UID 0 owned. |
| `ANCESTOR_MODE_WRITABLE` | An ancestor grants group or other write access. |
| `ANCESTOR_CALLER_WRITABLE` | Effective access lets this caller modify an ancestor. |
| `SYMLINK_OWNER` | A symlink is not UID 0 owned. |
| `SYMLINK_DEPTH` | The link chain exceeds 32 entries. |
| `SYMLINK_CYCLE` | The link chain repeats a target. |
| `TARGET_OWNER` | The final executable is not UID 0 owned. |
| `TARGET_MODE_WRITABLE` | The final executable grants group or other write access. |
| `TARGET_CALLER_WRITABLE` | Effective access lets this caller modify the target. |
| `TARGET_TYPE` | The final target is not a regular executable file. |
| `TARGET_FORMAT` | The final target is not ELF or Mach-O. |
| `TOOL_UNTRUSTED` | A fixed platform utility fails the same path contract. |

### Security Runner Diagnostics

`BUBBLES_PYTHON_SECURITY_RUN_DIAGNOSTIC` uses exactly these values:

| Diagnostic | Meaning |
| --- | --- |
| `NOT_RUN` | No operation has started. |
| `OK` | Readiness, FIFO EOF, exact wait, and operation protocol all completed. |
| `ARGUMENT_INVALID` | The operation or its data contract is invalid. |
| `CAPTURE_UNAVAILABLE` | Private directory, file, FIFO, or descriptor setup failed. |
| `LIMIT_SETUP_FAILED` | The child could not apply its fixed file limit. |
| `CONTROL_TIMEOUT` | The fixed wall expired before lifecycle completion. |
| `CONTROL_MALFORMED` | The lifecycle record is partial, unexpected, or duplicated. |
| `CHILD_EXIT_NONZERO` | Exact wait returned nonzero without runner timeout ownership. |
| `OUTPUT_LIMIT` | A capture crossed its operation-specific limit. |
| `SIGNAL_HUP` | The runner received HUP and returned 129. |
| `SIGNAL_INT` | The runner received INT and returned 130. |
| `SIGNAL_TERM` | The runner received TERM and returned 143. |
| `INTERNAL` | Exact wait, descriptor closure, or cleanup invariants failed. |

### Scan 2B Diagnostics

The scanner maps security execution to this closed vocabulary:

| Diagnostic | Meaning |
| --- | --- |
| `SECURITY_RUNTIME_UNAVAILABLE` | Runtime authentication or closure validation failed. |
| `HELPER_MISSING` | The fixed helper path is absent. |
| `HELPER_TOO_LARGE` | The helper exceeds 256 KiB. |
| `HELPER_DIGEST_MISMATCH` | Helper bytes differ from the reviewed digest. |
| `HELPER_DECODE_INVALID` | Digest-matched bytes are not UTF-8. |
| `HELPER_COMPILE_INVALID` | Digest-matched bytes do not compile. |
| `RUNNER_CHANNEL_INVALID` | `BPY1` readiness or EOF is invalid. |
| `RUNNER_INTERNAL` | Private setup, exact wait, or cleanup failed. |
| `CLASSIFIER_TIMEOUT` | The fixed classification wall expired. |
| `CLASSIFIER_EXIT_NONZERO` | The child exited nonzero without runner timeout ownership. |
| `CLASSIFIER_OUTPUT_LIMIT` | Standard output or error crossed its fixed bound. |
| `CLASSIFIER_OUTPUT_EMPTY` | Exit zero produced no classifier records. |
| `CLASSIFIER_RECORD_MALFORMED` | An `SCS1` record failed closed validation. |
| `CLASSIFIER_RECORD_AFTER_COMPLETION` | Data followed the completion record. |
| `CLASSIFIER_COMPLETION_MISSING` | No completion record exists. |
| `CLASSIFIER_COMPLETION_DUPLICATE` | More than one completion record exists. |
| `CLASSIFIER_SCANNED_COUNT_MISMATCH` | Completion does not cover every source file. |
| `OK` | Trusted execution and complete `SCS1` validation succeeded. |

Raw stdout and stderr never appear in operator diagnostics.
Human remediation derives only from status, closed enum, and validated path context.

### `SCS1` Compatibility

`SCS1` does not change.
A valid stream contains zero or more `FINDING` records.
It ends with exactly one `COMPLETE\tSCS1\t<count>` record.

The count must equal the supplied source count.
A valid zero-finding completion remains distinct from empty output.

Existing finding fields, allowlists, path checks, and completion checks remain active.
Only the authority allowed to produce the stream changes.

### Archived Section: Failure Handling

| Condition | Execution effect | Scan 2B effect | Selftest effect |
| --- | --- | --- | --- |
| Fake managed interpreter | Never enters security discovery | Trusted candidate runs or scan fails closed | Fake marker remains absent |
| User-owned PATH Python | Rejected before launch | Next pre-auth candidate is considered | Rejection is asserted |
| Unsafe `DEVELOPER_DIR` | Apple Python does not launch | Another independent candidate may be considered | Closed rejection is asserted |
| UID 0 caller | No Python launches | Fail-closed unresolved findings | Root-specific condition is named |
| Xcode licence refusal | `xcrun` runs, Python does not | Fail-closed unresolved findings | Status `69`, sentinel, and remediation |
| No authenticated runtime | No Python launches | Fail-closed unresolved findings | One counted skip and sentinel |
| Modified helper | Python may start, helper does not execute | Fail-closed unresolved findings | Digest mismatch and marker absence |
| Runtime probe hang | Exact Python PID launches | Fail-closed unresolved findings | Status `124` and exact wait proof |
| Child exits `73` | Exact child is reaped | Fail-closed unresolved findings | Status `73`, no timeout claim |
| Child writes protocol then hangs | FIFO stays open | Fail-closed timeout | Status `124` |
| Empty or malformed protocol | Exact child is reaped | Fail-closed unresolved findings | Matching closed diagnostic |
| Valid `SCS1`, zero findings | Checked helper executes | Clean Scan 2B contribution | Earned pass |
| Valid `SCS1`, findings | Checked helper executes | Blocking findings | Exact tuple assertions |
| HUP, INT, or TERM | Exact child is killed and reaped | Scanner exits with signal status | Private paths are absent |

### Archived Section: Observability And Security-Safe Operator Output

The scanner emits one bounded status line for Scan 2B:

```text
sensitive-storage classifier <state>: status=<n> diagnostic=<enum> runtimeDiagnostic=<enum> rejection=<enum> candidates=<n> trust=root-protected-native-python-v1 provenance=<none|root-protected-path> pathProtocol=<none|PYSEC1> moduleProtocol=<none|PYMOD1> classifierProtocol=<none|SCS1>
```

An optional second line may name one rejected candidate with Bash `%q` escaping.
It may name the developer directory only after that directory passes trust checks.

Output may include paths, counts, numeric statuses, and closed enums.
It must not include child bytes, project source, environment values, or secret material.

The Xcode remediation names the validated developer directory and offers:

- `sudo xcodebuild -license accept`
- selecting accepted Command Line Tools
- setting the validated Command Line Tools directory for one invocation

Generic remediation requests a root-protected native Python 3.9 or newer.
It never recommends the managed virtualenv as Scan 2B authority.

### Archived Section: Configuration, Migration, And Portability

The security path adds no configurable default or fallback.
Its wall limits, output limits, protocol versions, helper path, and digest are constants.

General Python configuration remains available to general consumers.
The security resolver ignores those values instead of reinterpreting them.

No data migration exists.
The source migration is the atomic five-file change described below.

The design adds no package, language runtime, or network dependency.
It uses Bash 3.2 builtins and base macOS or Linux utilities at absolute paths.

| Purpose | Primitive |
| --- | --- |
| Shell and exact child | `/bin/bash`, `builtin kill`, `builtin wait`, `builtin read`, `builtin trap` |
| Empty environment | `/usr/bin/env` |
| Metadata and links | `/usr/bin/stat`, `/usr/bin/readlink` |
| Native magic | `/usr/bin/od` |
| Private files | `/usr/bin/mktemp`, `/usr/bin/mkfifo`, `/bin/chmod`, `/bin/rm` |
| Exact byte counts | `/usr/bin/wc` |
| Apple resolution | `/usr/bin/xcode-select`, `/usr/bin/xcrun` when both exist |
| Fixed wall | Bash `SECONDS` and timed `read` |

An absent or ambiguous primitive fails closed.
The code never substitutes an ambient PATH utility.

The implementation may not use associative arrays, `wait -n`, `readlink -f`,
GNU-only `stat`, `setsid`, `/proc`, cgroups, or platform-name branching.
BSD and GNU metadata forms are selected by validated tool behavior.

### Archived Section: Testing And Validation Strategy

No test result is claimed by this design.
Every row below is a required implementation proof.

### Scenario Mapping

| Scenario | Test surface | Required behavior |
| --- | --- | --- |
| `SCN-B039-001` | `implementation-reality-scan-selftest.sh` | The Xcode licence condition emits one sentinel, one named skip, zero classifier `FAIL` labels, and status `0` when no other assertion fails. |
| `SCN-B039-002` | `implementation-reality-scan-selftest.sh` | A root-protected runtime under the same sanitized PATH executes all 23 semantic and configuration assertions. |
| `SCN-B039-003` | Copied scanner tree with one classifier mutation | The exact semantic assertions make both normal and sanitized runs exit `1`. The copied tree returns to byte identity. |
| `SCN-B039-004` | `test_24_g028_sensitive_client_storage.sh` | The sentinel increments only `SKIP_COUNT` and never emits the coverage pass label. |

### Runtime And Trust Matrix

The persistent tests must cover these cases on macOS and Linux where applicable:

- root-protected native Python positive control
- user-owned managed Python with a forged probe and clean `SCS1`
- user-owned PATH Python and caller-owned symlink prefix
- root-owned symlink into a user-owned target
- protected symlink chain positive control
- symlink cycle and depth overflow
- group-writable, other-writable, ACL-writable, and wrong-owner components
- text executable with valid probe output
- hostile `PYTHONPATH`, `PYTHONHOME`, `LD_*`, and `DYLD_*` values
- unsupported Python version and malformed `PYSEC1`
- untrusted search root and module origin
- root caller when a non-interactive root lane exists
- accepted Command Line Tools resolution
- unaccepted Xcode status `69` when that host condition exists

The test must mutate each trust check and make its paired marker assertion red.
A marker absence without a red mutation is insufficient.

### Helper Identity Matrix

Copied-tree tests alter the helper with these payload classes:

- harmless marker write
- `subprocess` launch
- `os.setsid`
- double fork
- dynamic import, `ctypes`, `eval`, or `exec`

Every altered helper must fail digest validation before compilation.
No payload marker may appear.

A same-byte test replaces the helper path after the driver reads it.
The already-read buffer must execute and the replacement marker must remain absent.
The negative control reopens the path and makes that assertion red.

### Supervision Matrix

Each platform must exercise these outcomes:

- success status `0`
- child status `73`
- runner timeout `124`
- control failure `125`
- child-owned status `143`
- caller HUP `129`, INT `130`, and TERM `143`
- malformed readiness record
- EOF before operation-protocol completion
- valid completion followed by a hang
- stdout and stderr limit breaches
- signal delivery before PID publication
- signal delivery during each FIFO read state

Caller functions named `kill` and `wait` must record zero invocations.
Mutating `builtin kill` or `builtin wait` to an unqualified call must make that test red.

The launch-window test uses a copied runner with a synchronization point.
A structural assertion also requires PID assignment immediately after `&`.

No test stores or signals a descendant PID.
No cleanup assertion uses a destructive stale-PID fallback.
Exact `wait` completion and private-path removal are the lifecycle proof.

### Determinism And Platform Proof

Run the nested fixed-operation matrix 30 times on stock macOS Bash 3.2.
Run each iteration once and preserve every result.

Repeat the matrix on Linux Bash.
Do not increase a deadline or retry a failed iteration.

Static checks must find no job-control command, negative PID signal,
PID-liveness polling, or generic command vector in the security path.

The Ubuntu and macOS release lanes must each prove one authenticated positive path.
If a lane has no eligible runtime, it may report the defined skip.
That skipped lane cannot close `SEC-B039-001` or `SEC-B039-003`.

### Validation Commands

Implementation owners must run the focused selftests through the source repository's
canonical shell surfaces.
They must also run Bash syntax checks on all five boundary files.

Artifact lint and traceability validation must use the BUG-039 directory.
The final immutable candidate must then pass `framework-validate` and `release-check`.

Output above 40 lines must use the repository evidence-capture helper.
No evidence from the managed-runtime candidate can satisfy these checks.

### Archived Section: Packet Epoch And Ownership Reconciliation

The packet has three distinct epochs:

| Epoch | Meaning | Certification use |
| --- | --- | --- |
| Presence-versus-usability reproduction | Original BUG-039 diagnosis | Historical diagnosis only |
| `managed-venv-only-v1` implementation | Current combined source before this redesign | Superseded security evidence |
| `root-protected-native-python-v1` implementation | Candidate produced from this design | Sole eligible closure epoch |

`scopes.md` currently says Done against the superseded epoch.
`state.json` correctly remains `in_progress` with uncertified scope progress.
No checked scope claim may carry into the final epoch unchanged.

Planner-owned reconciliation must complete these actions:

1. Replace managed-runtime and process-group expectations in `scopes.md`.
2. Preserve all four scenario IDs and map each to the new negative controls.
3. Reconcile `scenario-manifest.json` with the same implementation epoch.
4. Mark prior evidence references as historical or replace them with exact-candidate refs.
5. Keep every human acceptance checkbox and record untouched by automation.

Implementation and test owners may append only their own current evidence.
Security review must inspect the exact immutable candidate independently.
Only `bubbles.validate` may write certification or terminal status.

An implementation change after evidence capture starts a new epoch.
Every affected proof must run again on the new tree.

### Archived Section: Migration And Safe Rollback

The five-file source change must land atomically.
A mixed trust contract cannot produce an authoritative Scan 2B result.

The implementation sequence is:

1. Reconcile planner-owned scenarios and tests to this design.
2. Add red trust, helper-identity, supervision, signal, cleanup, and cascade cases.
3. Add root-protected path and Apple launcher resolution.
4. Add `PYSEC1`, `PYMOD1`, and fixed-operation supervision.
5. Add helper same-byte validation and route Scan 2B through it.
6. Remove managed security authority and generic runner consumers.
7. Run focused mutations and both platform matrices on one immutable candidate.
8. Reconcile packet wording and evidence references to that candidate.
9. Run independent security review and validate-owned certification.

Reverting to managed self-attestation is not a safe rollback.
The safe rollback is a reviewed source state that always fails Scan 2B closed.

That state preserves candidate collection and unresolved findings.
It disables every clean classifier acceptance until authenticated execution returns.
No runtime flag may activate or bypass that state.

### Archived Section: Alternatives And Tradeoffs

### Keep The Managed Virtualenv With A Stronger Challenge

Rejected. A caller who controls the executable can forge every requested payload.
Usability evidence cannot become executable authentication.

### Call The Contract `os-owned-native-python-v1`

Rejected. UID 0 metadata proves protection from this caller, not vendor provenance.
The truthful long-run name is `root-protected-native-python-v1`.

### Trust Package-Manager Brand Or Prefix

Rejected. Homebrew and MacPorts ownership depends on installation posture.
The same prefix can be protected on one host and caller-writable on another.

### Trust A Local Runtime Hash Or Receipt

Rejected. A receipt beside a caller-selected runtime shares the attacker's authority.
A repository list of platform runtime hashes would create a release lifecycle outside this boundary.

### Add Runtime Signature Verification

Not selected. No cross-platform signer or runtime release contract exists in this packet.
Adding one requires an explicit dependency and source-lock design.

### Execute `/usr/bin/python3` Then Validate `sys.executable`

Rejected. The Apple launcher may execute an untrusted developer-directory target first.
Fixed `xcode-select` and `xcrun` resolution authenticates the target before Python starts.

### Authenticate Only The Final Executable

Rejected. A protected-looking link can traverse a caller-writable ancestor or target.
Python can also import code from writable search roots.

### Keep Process-Group Supervision

Rejected. A descendant can leave the group with `setsid` or double-fork.
Job-control launch timing also creates nondeterministic Bash 3.2 behavior.

### Enumerate And Kill Descendants

Rejected. Discovery races reparenting, exit, and PID reuse.
No portable macOS and Linux primitive closes those races from Bash 3.2.

### Use A Linux Sandbox Or Cgroup

Rejected. Those controls do not provide the required macOS contract.
Treating a Linux control as universal would be false.

### Use `/usr/bin/perl` As Supervisor

Rejected. Perl is not a declared framework runtime dependency.
A Bash fallback would create two security paths with divergent behavior.

### Rewrite The Classifier Without Python

Rejected. The helper contains 1,112 lines of semantic classification logic.
A second implementation would create policy drift and exceed the five-file boundary.

### Use A Helper AST Allowlist

Rejected. A sound allowlist needs name binding, receiver typing, and alias analysis.
Exact reviewed helper identity is narrower and testable.

### Archived Section: Complexity Tracking

| Decision | Simpler alternative considered | Why rejected |
| --- | --- | --- |
| Root-protected ancestor and symlink validation | Check only final-file owner | An unprotected prefix can redirect the execution target. |
| Apple pre-resolution | Execute `/usr/bin/python3` and inspect `sys.executable` | The launcher can execute the wrong target before authentication. |
| `PYSEC1` and `PYMOD1` | Trust the native executable path | Python can load caller-controlled code through search roots or module origins. |
| Exact helper digest and one-read execution | Import the fixed helper path | Import reopens caller-writable bytes and permits a check-to-use race. |
| FIFO readiness plus EOF | Poll a completion file or PID | Polling races status, PID reuse, and process completion. |
| Separate general and security capabilities | Reuse one ordered resolver | Usability and authority answer different questions. |
| Fixed security operations | Keep an arbitrary command vector | Generic launch lets caller-selected code enter the trust path. |

### Archived Section: Risks And Open Questions

### Accepted Risks

- Hosts with only caller-owned Python cannot produce a clean Scan 2B verdict.
- UID 0 invocations cannot establish caller separation and fail closed.
- Root or OS compromise invalidates the local trust anchor.
- Malicious filesystem metadata remains outside the enforceable boundary.
- A compromised authenticated runtime can escape direct-child cleanup.
- Helper changes require an explicit digest update and renewed negative controls.
- Linux and macOS proof remains mandatory before any security finding closes.

### Remaining Architecture Questions

None. Supporting caller-owned runtimes requires a signed runtime distribution contract.
That contract is not implicit in BUG-039.

### Archived Section: Managed-Venv Design Decisions

Everything below this heading documents the `managed-venv-only-v1` epoch.
It remains historical context and must not guide implementation or certification.

### Archive: Root Cause, Precisely Located

Two predicates are being conflated:

| Predicate | Answered by | True on this machine |
| --- | --- | --- |
| Is `python3` **present**? | `command -v python3` | yes |
| Can `python3` **run**? | executing it | **no** — exit 69 |

`bubbles/scripts/implementation-reality-scan.sh:696` gates the sensitive-storage
classifier on the first predicate. The `/usr/bin/python3` shim dispatches through
the *active developer directory*; with Xcode.app selected and its licence
unaccepted, the shim resolves (satisfying `command -v`) and then exits 69 without
executing a line of the helper.

The scanner's response to that is correct and must not change. It prints
`sensitive-storage classifier failed: exit=69`, echoes the interpreter's stderr,
and fails closed by degrading every candidate line to
`SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED`. The selftest's own
"Parser-unavailable configured approval fails closed" scenario depends on exactly
that behaviour.

The defect is one layer up, in the **selftest**: it asserts on classifier output
without ever checking that the classifier could produce any. The failure text it
then emits describes the code under scan when the real subject is the harness's
missing prerequisite.

### Archive: Blast Radius

Measured, not assumed. Under the dead interpreter the scan emits
`CONFIG_INVALID` for **any** config that declares a `sensitiveClientStorage`
key — including the deliberately *valid* one:

```text
SENSITIVE_STORAGE_CONFIG_INVALID occurrences:  A (dead interpreter) = 6,  B (live) = 5
```

The extra occurrence in A is the valid-config run. Therefore the four
`assert_sensitive_invalid_config` scenarios (8 assertions) report **PASS**
under the dead interpreter no matter what the config contains. They cannot
distinguish valid from invalid. Likewise 4 of the 15 semantic assertions pass
vacuously because the blanket `CLASSIFICATION_UNRESOLVED` degradation happens
to satisfy them.

So the honest tally under a dead interpreter is not "11 failures". It is
**23 assertions across 5 scenarios, none of which produced an earned verdict** —
11 red for the wrong reason, 12 green for no reason.

### Archive: Repair

**Add a usability probe to the selftest and emit a named SKIP for the scenario
group whose preconditions cannot hold.** This is the operator's preferred
option, and the evidence above strengthens it: the skip must cover the config
scenarios too, not only the visibly-failing semantic block.

#### Archive Note: Why this layer

The scanner is correct; changing it would break a contract the framework relies
on. The selftest is what asserts a precondition it never established. Fix the
predicate where the wrong predicate is used.

#### Archive Note: The probe

`command -v python3` is replaced, for this decision only, by an execution probe:

```bash
python3 -c 'import sys; sys.stdout.write("classifier-probe-ok")' </dev/null
```

Both the exit status and the payload are checked, so a wrapper that exits 0
while emitting a warning cannot masquerade as a healthy interpreter.

#### Archive Note: The skip message

Names the cause and the operator action, matching the framework's existing idiom
(`SKIP: BLOCK (#4) schema-invalid tool-log line — python 'jsonschema' not
importable`). When the probe output carries the Xcode licence signature the
remediation is specific:

- `sudo xcodebuild -license accept`, **or**
- point the active developer directory at an accepted toolchain
  (`sudo xcode-select -s /Library/Developer/CommandLineTools`, or
  `DEVELOPER_DIR=/Library/Developer/CommandLineTools` for one shell).

Otherwise it falls back to a generic repair instruction carrying the captured
diagnostic. The message also states which assertions did not run, so a reader
cannot mistake a quiet run for a thorough one.

#### Archive Note: The sentinel

One stable, greppable line for machine consumers:

```text
SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
```

Absent ⇒ the scenario group executed. Present ⇒ it did not. This is what lets
`test_24` tell a skip from a pass without parsing prose.

### Archive: Rejected Alternatives

**Override `DEVELOPER_DIR` inside the test.** Confirmed rejected, and the
operator's reasoning holds. The sanitized-PATH scenario's entire value is that
it proves the scanner works under **default** system resolution with no
Homebrew. Injecting a hand-picked developer directory makes the scenario
pass by construction: it would no longer be able to observe the class of
environment defect it exists to expose, while still reporting green. That is a
strictly worse failure mode than the current loud-but-misnamed one, because it
is silent.

**Relax the semantic assertions, or teach `test_24` to tolerate 11 mismatches.**
Forbidden and correctly so. The assertions encode the classifier's contract. The
mutation proof below exists precisely to demonstrate they are untouched and still
lethal.

**Fix it in the scanner** (e.g. make the scanner probe usability and refuse).
Rejected **as to refusal**, and that half stands: the scanner's degradation is
contracted behaviour that the "Parser-unavailable configured approval fails
closed" scenario asserts, so the scanner must still degrade rather than refuse.

Superseded **as to probing**. The original entry also claimed "the scanner is
not the thing making an unchecked assumption". Evidence gathered during delivery
falsifies that clause. `implementation-reality-scan.sh:696` gated on
`command -v python3`, which is the presence-versus-usability conflation this bug
is about, sitting in the producer itself. The scanner therefore does probe
usability now, and it still degrades exactly as before; only the gate predicate,
the diagnostic string, and the interpreter actually invoked changed. The
contracted `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED` reason strings are
untouched. See `## Change Boundary` for the recorded rationale and its limits.

### Archive: Guarantee Preservation

A skip path that swallows real failures is worse than the bug. The design is
therefore validated by mutation, not by inspection:

1. With a **usable** interpreter, break the classifier's classification logic.
2. The selftest must go **RED** — proving the skip does not engage and the
   assertions still bite.
3. Revert; the selftest must go **GREEN**.
4. The mutated file must be byte-identical to HEAD afterwards (`git diff --quiet`
   plus a hash comparison).

### Archive: Cascade for `test_24`

`assert_status 0 "managed selftest runs with the system-only PATH"` is
unconditional and so cannot distinguish "ran everything and passed" from "ran
almost nothing". A skip is not a pass and must never be counted as one.

Resolution: a third outcome. `test_24` gains a `SKIP_COUNT` and a `skip()`
recorder. After running the managed selftest with the sanitized PATH it
branches on the sentinel:

- sentinel **absent** → the selftest ran the full scenario set → `assert_status 0`
  exactly as before; meaning unchanged.
- sentinel **present** → record an explicit **SKIP** for the coverage claim
  (never a pass), and separately still require exit 0, because a selftest that
  skips must not also be failing. The unmet coverage is named in the output.

### Archive: Change Boundary

Ratified by `bubbles.plan` after independent verification. Two paths outside the
originally declared boundary were widened into it. The widening is bounded to
one defect class and is not a standing licence over either file.

#### Archive Note: In boundary

| Path | Why it is in scope |
| --- | --- |
| `bugs/BUG-039-.../**` | The packet itself. |
| `bubbles/scripts/implementation-reality-scan-selftest.sh` | The harness that asserted without establishing its precondition. |
| `tests/regression/test_24_g028_sensitive_client_storage.sh` | The cascade that could not tell a skip from a pass. |
| `bubbles/scripts/implementation-reality-scan.sh` | **Widened.** The presence-versus-usability conflation lives here, at the `command -v python3` gate. Repairing only the harness would leave the producer still choosing an interpreter by presence. |
| `bubbles/scripts/python-env.sh` | **Widened.** The framework's designated usability-aware interpreter resolver. It carried the same misreporting defect one layer down. |
| `bubbles/scripts/python-env-selftest.sh` | **Widened (second widening).** The owning module's selftest, for the API this packet added to that module. Rationale below. |

#### Archive Note: Recorded rationale for the two widened paths

`implementation-reality-scan.sh` is admitted because the bug's subject is the
conflation of presence with usability, and this file is where that conflation is
literally written. The change is confined to three things: the gate predicate,
the diagnostic string, and the interpreter actually invoked. The contracted
degradation to `SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED` is byte-for-byte
unchanged, so the "Parser-unavailable configured approval fails closed" scenario
keeps its meaning. The file now sources `python-env.sh`; that is safe because
`python-env.sh` guards its CLI dispatch behind `[[ "${BASH_SOURCE[0]}" == "${0}" ]]`,
produces no output when sourced, and is itself a managed install, so it is
present wherever the scanner is.

`python-env.sh` is admitted because it carried the same defect class as the
filed bug. Under `set -u` with `HOME` unset, `${XDG_CACHE_HOME:-$HOME/.cache}`
did not merely abort. It yielded an empty home and the caller then published
`/bin/python3` — a path that does not exist — as a resolved interpreter. An
absent locator was reported as "no interpreter satisfies the required modules",
which is a sentence about interpreters when nothing had been able to name one.
That is the filed bug's failure mode, one layer down, in the module the
framework designates to answer this exact question.

The alternative — probing usability locally inside the scanner — was rejected
because it would put a third interpreter-resolution contract in the tree, in the
file whose wrong local guess started this.

#### Archive Note: Measured justification for admitting `python-env.sh`

Deferring it does not merely postpone a repair; it permanently surrenders
coverage. With a sanitized PATH and `HOME` set — the ordinary real-world
invocation — the repaired resolver reaches the managed venv and the Scan 2B
scenario group **runs to completion with zero skips**. Without the repair the
same invocation selects the dead `/usr/bin/python3`, degrades, and the group is
skipped every time. A selftest-only fix would have converted a loud wrong answer
into a quiet permanent gap.

#### Archive Note: Recorded rationale for the second widening

Declared after the first widening was ratified, because that widening is what
created the obligation. Admitting `python-env.sh` added new API to a shared
module — `bubbles_python_runs`, `bubbles_python_resolve_runnable`, and the
globals `BUBBLES_PYTHON_RUNNABLE` / `BUBBLES_PYTHON_RUNNABLE_REASON` — and
changed an existing contract, because `bubbles_python_home` and
`bubbles_python_venv_python` can now decline instead of always printing.

The admitting argument is deliberately **not** "same defect class"; that argument
is refused below and stays refused. It is narrower and it is about this packet's
own output: a boundary must cover the change that was made, and the change added
API to this module. The owning module's selftest is where that API is pinned.

The measurement that makes it necessary rather than tidy: the original defect
survived **because** nothing in this file pinned the module's behaviour when the
locator was absent. `python-env.sh` was already usability-aware, and it still
published `/bin/python3` — a path that does not exist on this machine — as a
resolved interpreter, because `${XDG_CACHE_HOME:-$HOME/.cache}` aborted inside a
command substitution and the empty result was concatenated with `/bin/python3`.
Every other case in the file passed throughout. Coverage that cannot observe the
defect sitting next to it is what let this reach two consumers.

Admitted work is confined to **adding** cases that pin the API this packet
introduced: the ordered locator precedence, the absent-locator condition, the
payload check, and the absent-locator reason string. No existing case is
modified, relaxed, renumbered, or deleted.

#### Archive Note: Explicitly excluded paths

The following are **not** admitted by either widening, and must not join them by
analogy:

- Any `python-env.sh` change unrelated to locator guarding or interpreter
  usability. Module-resolution policy, the pinned requirements set, venv
  provisioning behaviour, and the `bubbles_python_resolve` module contract are
  all untouched and stay untouched.
- Migrating any of the 20+ remaining `command -v python3` call sites. Those are
  the same defect class, which is exactly why they need their own packet with
  their own blast-radius analysis rather than being swept in here.
- Any `python-env-selftest.sh` change that is not new coverage for the API this
  packet added. Weakening, relaxing, or renumbering an existing case is refused,
  and so is repairing an unrelated pre-existing weakness in that file — see the
  routed finding below.
- Any file that merely consumes `python-env.sh`.

"It is the same defect class" is the argument this section exists to refuse. A
shared module is widened one defect at a time, with the measurement that shows
what deferring it would cost.

#### Archive Note: Gap closed by the second widening

Previously recorded as open and unadmitted, on the rule that a boundary must
describe the change that was made rather than the change that might be made.
The change has now been made, the widening above declares it, and the gap is
closed: `python-env-selftest.sh` gained Cases 12-15, which pin the ordered
locator precedence, the absent-locator condition, the payload check, and the
absent-locator reason string. Non-vacuity is established by mutation — the
historical unguarded `$HOME` is restored, the new assertions go red naming the
fabricated `/bin/python3`, and the file is verified byte-identical after revert.

#### Archive Note: Routed `test_24` finding

Found while executing this packet's evidence, reported rather than repaired.

`tests/regression/test_24_g028_sensitive_client_storage.sh` calls
`bubbles_python_home` and `bubbles_python_runs` in its BUG-040 block without
ever sourcing the module that defines them. The run emits
`test_24…: line 614: bubbles_python_home: command not found`, the `if` is
therefore false, `bubbles_python_runs` is never reached, and the block reports
`no managed venv at <no locator>`.

That diagnostic is false, and it is false in exactly this bug's shape: an absent
prerequisite — the unsourced module — is being reported as a statement about
where the venv lives. The scenario cannot execute under any environment, so its
six assertions are unreachable and the skip it records is unearned.

It is left open deliberately. The call sites do not exist at HEAD, so this is
in-flight work in this tree with no owning packet: `bugs/BUG-040-*` does not
exist. Repairing it would newly activate six assertions whose outcome is not
measured here, which is a blast radius that belongs to a declared packet, not to
a drive-by edit made while another validation run is in flight. Routed to the
parent runner with the measured evidence above.

#### Archive Note: `python-env.sh` consumers at ratification

12 files reference the module. Only these call its functions:

| Consumer | Functions used | Affected by this change |
| --- | --- | --- |
| `cli.sh` | `bubbles_python_activate` | No, when a locator is set. Returns 1 cleanly instead of aborting when none is. |
| `dependency-posture.sh` | `bubbles_python_activate` | Same. |
| `python-env-selftest.sh` | `bubbles_python_activate`, `bubbles_python_provision` | Same, plus a new exit-2 path that only fires with no locator. |
| `framework-validate.sh` | executes `--path`, never sources | Diagnostic text only. |
| `implementation-reality-scan.sh` | `bubbles_python_resolve_runnable` | In boundary. |
| `implementation-reality-scan-selftest.sh` | `bubbles_python_resolve_runnable` | In boundary. |
| `test_24_g028_sensitive_client_storage.sh` | `bubbles_python_home`, `bubbles_python_runs` | In boundary. |

The remaining references are comments or documentation. `bubbles_python_runs`
and `bubbles_python_resolve_runnable` are additive: no pre-existing consumer
calls them. The signature changes on `bubbles_python_home` and
`bubbles_python_venv_python` are observable only when no locator is set at all,
which previously produced a fabricated path rather than a correct one.

The summary line reports skips alongside passes and failures, so a skipped run
is visible in the transcript and in any log scraped from it. `FAIL_COUNT` still
governs the exit code, so a genuine regression is still fatal.
