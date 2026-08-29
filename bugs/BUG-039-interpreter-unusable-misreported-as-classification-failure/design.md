# Design: BUG-039 Root-Protected Scan 2B Authority

## Design Brief

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

## Purpose And Scope

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

## Requirement Reconciliation

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

## Current Source Facts

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

## Security Objective And Threat Model

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

## Finding Accounting

| Finding | Design accounting | Closure state after this design |
| --- | --- | --- |
| `SEC-B039-001` | Replace managed self-attestation with pre-execution root-protected path, native-format, environment, and import-closure checks. | Design-accounted. Implementation and independent security proof remain required. |
| `SEC-B039-002` | Remove the generic command vector from security execution. Expose only fixed operations and state the direct-child residual boundary. | Design-accounted. Implementation and adversarial proof remain required. |
| `SEC-B039-003` | Remove job control, negative signaling, `kill -0`, and descendant PID retention. Use builtin-qualified exact-child supervision. | Design-accounted. macOS and Linux proof remain required. |
| `SEC-B039-004` | Define one final implementation epoch. Invalidate managed-runtime evidence and require planner-owned contract reconciliation before certification. | Design-accounted. Planner and validation ownership remain active. |
| `SEC-OBS-001` | Register every capture, FIFO, descriptor, and temporary directory before launch. Clean them on normal return, signal, and EXIT. | Design-accounted. Signal-path tests remain required. |
| `SEC-OBS-002` | Keep the plan/design phase-vocabulary observation outside this packet. It belongs to G022. | Accounted by explicit exclusion. No BUG-039 change is authorized. |

No finding above is claimed fixed in source.

## Architecture Overview

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

## Data Model

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

## API And Contracts

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

## Capability Foundation

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

## Concrete Implementations

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

## Runtime Trust Contract

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

## Fixed-Wall Supervision Contract

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

## Protocol And Error Model

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

## Failure Handling

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

## Observability And Security-Safe Operator Output

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

## Configuration, Migration, And Portability

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

## Testing And Validation Strategy

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

## Packet Epoch And Ownership Reconciliation

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

## Migration And Safe Rollback

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

## Alternatives And Tradeoffs

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

## Complexity Tracking

| Decision | Simpler alternative considered | Why rejected |
| --- | --- | --- |
| Root-protected ancestor and symlink validation | Check only final-file owner | An unprotected prefix can redirect the execution target. |
| Apple pre-resolution | Execute `/usr/bin/python3` and inspect `sys.executable` | The launcher can execute the wrong target before authentication. |
| `PYSEC1` and `PYMOD1` | Trust the native executable path | Python can load caller-controlled code through search roots or module origins. |
| Exact helper digest and one-read execution | Import the fixed helper path | Import reopens caller-writable bytes and permits a check-to-use race. |
| FIFO readiness plus EOF | Poll a completion file or PID | Polling races status, PID reuse, and process completion. |
| Separate general and security capabilities | Reuse one ordered resolver | Usability and authority answer different questions. |
| Fixed security operations | Keep an arbitrary command vector | Generic launch lets caller-selected code enter the trust path. |

## Risks And Open Questions

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

## Superseded Design Decisions

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
