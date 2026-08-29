# Scopes: BUG-039 Unusable Interpreter Misreported As Classification Failures

## Planning Basis

This plan derives from [spec.md](spec.md) and the committed secure redesign in
[design.md](design.md). Execution evidence belongs in [report.md](report.md).
Human acceptance belongs in [uservalidation.md](uservalidation.md).

Scope 1 records the delivered `managed-venv-only-v1` epoch. Its checked items
remain historical facts about that candidate. They do not prove, unlock, or
transfer into the `root-protected-native-python-v1` epoch.

Scope 2 is the active remediation plan. It preserves `SCN-B039-001` through
`SCN-B039-004` and adds one scenario for each secure-redesign finding. The
five-file implementation must land atomically because mixed authority and
supervision contracts cannot produce an accepted Scan 2B verdict.

## Execution Outline

### Phase Order

1. **Scope 1: Historical usability repair.** Preserve the already delivered
   skip and cascade behavior as evidence from the superseded implementation
   epoch.
2. **Scope 2: Authenticated Scan 2B runtime.** Replace caller-owned authority
  with the root-protected runtime. Replace process-group supervision with fixed
  operations, exact-child lifecycle, private cleanup, and one-epoch closure.

### New Types And Signatures

- `bubbles_python_runs(interpreter)` remains a general usability probe only.
- `bubbles_python_resolve_runnable()` remains general resolution only.
- `bubbles_python_resolve_security_runtime()` accepts no candidate and returns
  authenticated runtime identity plus closed diagnostics.
- `bubbles_python_run_security_operation(operation, registered captures,
  operation data)` accepts only closed operations and no executable vector.
- `bubbles_python_security_cleanup()` closes descriptors, reaps the exact
  direct child, removes private resources, and restores caller traps.
- `PYSEC1`, `PYMOD1`, `BPY1`, and `SCS1` remain closed protocols.
- `bubbles_python_run_bounded()`, process-group cleanup helpers, trusted-runtime
  globals, and managed-runtime security authority are removed.

### Validation Checkpoints

- Scope 1 is a historical checkpoint only. No Scope 1 evidence satisfies a
  Scope 2 item.
- Scope 2 first runs focused trust, helper-identity, lifecycle, cleanup, and
  cascade checks with their paired negative controls.
- The same immutable candidate then runs the macOS Bash 3.2 and Linux matrices
  without deadline increases or retry substitution.
- Full `framework-validate` and `release-check` execute only after focused
  checks are green on that candidate.
- A fresh security review accounts for every listed finding before planner
  reconciliation and validate-owned certification are requested.
- Existing checked human-acceptance content is historical and cannot accept
  the redesigned implementation.

## Plan Inventory

| Scope | Epoch | Surfaces | Primary validation | Status |
| --- | --- | --- | --- | --- |
| 1. Interpreter Usability Probe, Named Skip, And Honest Cascade | `managed-venv-only-v1` | Scanner selftest, regression cascade | Historical focused evidence | Done, historical and superseded |
| 2. Root-Protected Scan 2B Authority And Exact-Child Supervision | `root-protected-native-python-v1` | Five-file implementation boundary | Focused adversarial checks, both-platform matrix, full gates, security review | Not started |

## Scope 1: Interpreter Usability Probe, Named Skip, And Honest Cascade

**Status:** [x] Done
**Depends On:** None
**Epoch:** `managed-venv-only-v1` (historical and superseded for security closure)
**Consumer Surface:** CLI command output from the scanner selftest and `test_24`.

### Historical Evidence Boundary

This scope remains intelligible as the delivery record for the original
presence-versus-usability repair. Its implementation plan and checked DoD
describe that candidate only. The secure redesign does not reopen or rewrite
those observations. Every security-redesign claim is owned by Scope 2 and must
receive fresh evidence from one immutable `root-protected-native-python-v1`
candidate.

### Gherkin Scenarios (Regression)

```gherkin
Feature: A missing prerequisite is named, not misattributed

  Scenario: SCN-B039-001 - Unusable interpreter produces a named skip, not classification failures
    Given the active developer directory has an unaccepted Xcode licence
      And python3 resolves on PATH but exits 69 without running
    When the managed selftest runs under the sanitized system-only PATH
    Then it emits SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
      And it emits a SKIP naming the interpreter, its exit status and the operator remediation
      And it emits zero FAIL lines
      And it exits 0

  Scenario: SCN-B039-002 - A usable interpreter under the same PATH runs everything
    Given DEVELOPER_DIR points at an accepted toolchain
    When the managed selftest runs under the sanitized system-only PATH
    Then no skip is emitted
      And every Scan 2B semantic and config-integrity assertion executes

  Scenario: SCN-B039-003 - The assertions still catch a real classifier regression
    Given a usable interpreter
      And the classifier's classification ladder is mutated
    When the managed selftest runs
    Then it exits 1 and reports the mismatched semantic tuples

  Scenario: SCN-B039-004 - A skipped coverage claim is never counted as a pass
    Given the managed selftest emitted the unavailable sentinel
    When test_24 evaluates the managed selftest run
    Then it records a SKIP rather than the coverage PASS label
      And the summary line reports the skip separately from passes and failures
```

### Implementation Plan

1. Add `sensitive_storage_classifier_usable()` to the selftest: probe execution
   and payload, not presence. Classify the reason and build a specific
   remediation for the Xcode-licence case.
2. Gate the Scan 2B semantic block and the four config-integrity scenarios behind
   the probe. On failure emit the sentinel, a named `SKIP`, the remediation, and
   the count of assertions not run.
3. Report skips in the selftest summary so a skipped run is never mistaken for a
   thorough one.
4. Give `test_24` a `skip()` recorder and `SKIP_COUNT`; branch on the sentinel so
   unmet coverage is a skip, never a pass; report skips in the summary line.

### Test Plan

| Test type | Scenario ID | Concrete test file | Mechanism |
| --- | --- | --- | --- |
| functional | SCN-B039-001 | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Run the managed harness with an unusable interpreter under the sanitized system-only PATH; assert the unavailable sentinel, named skip, zero classification `FAIL` lines, and exit 0. |
| functional | SCN-B039-002 | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Run the managed harness under the same sanitized PATH with a usable interpreter; assert no skip and execution of every Scan 2B semantic and config-integrity assertion. |
| adversarial / mutation | SCN-B039-003 | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Apply the one-token classifier-ladder mutation, assert exit 1 and mismatched semantic tuples, then verify GREEN restoration and byte identity. |
| regression (cascade) | SCN-B039-004 | `tests/regression/test_24_g028_sensitive_client_storage.sh` | Run the production regression harness; assert the unavailable sentinel records a `SKIP`, withholds the coverage `PASS` label, and reports skips separately from passes and failures. |

### Definition of Done

- [x] Root cause confirmed and documented — presence (`command -v`) conflated with usability
  - Evidence: [report.md](report.md) §3, §4. A/B reproduced independently: A_EXIT=1 / 11 issues, B_EXIT=1→0 with only `DEVELOPER_DIR` differing; interpreter exit 69 under A, Python 3.9.6 under B.
- [x] Blast radius measured, not assumed
  - Evidence: [report.md](report.md) §4. `CONFIG_INVALID` occurrences A=6 vs B=5; the extra is the valid-config run, proving 8 config assertions are vacuous.
- [x] Packet route resolved mechanically
  - Evidence: [report.md](report.md) §5. `micro-fix-admission.sh` → full packet, escalated on `no-new-behavior` + `contract-preserving`, exit 0.
- [x] Fix implemented
  - Evidence: probe + gated block in `implementation-reality-scan-selftest.sh`; sentinel branch in `test_24_g028_sensitive_client_storage.sh`.
- [x] Pre-fix reproduction FAILS with the misnamed verdict
  - Evidence: [report.md](report.md) §3. `A_EXIT=1`, "failed with 11 issue(s)", all 11 in the Scan 2B block.
- [x] SCN-B039-002 — Post-fix behaviour correct in all three environments; under the same sanitized PATH, the usable-interpreter control emits no skip and executes every Scan 2B semantic and config-integrity assertion
  - Evidence: [report.md](report.md) §6. V1 exit 0/0 skips, V2 exit 0/1 skip, V3 exit 0/0 skips.
- [x] SCN-B039-003 — Adversarial mutation proves the assertions still bite with a usable interpreter and reports the mismatched semantic tuples
  - Evidence: [report.md](report.md) §7. Mutant exit 1 with 3 FAILs under BOTH normal PATH and sanitized PATH + `DEVELOPER_DIR`.
- [x] Mutation reverted and file byte-identical
  - Evidence: [report.md](report.md) §7. sha256 `77a02ff1…` matches pre-mutation; `git diff --quiet` exit 0; GREEN restored.
- [x] SCN-B039-001 — Skip path contains no silent-pass bailout — it withholds a verdict and says so; the unusable-interpreter run emits the sentinel, a named skip, zero classification `FAIL` lines, and exit 0
  - Evidence: [report.md](report.md) §6, §7 row 3. Skip is counted, sentinel-marked, and the limitation is stated explicitly rather than hidden.
- [x] SCN-B039-004 — Cascade resolved honestly — a skip is not a pass; `test_24` records the skip separately and withholds the coverage `PASS` label
  - Evidence: [report.md](report.md) §8. `57 passed, 0 failed, 1 skipped`; coverage PASS label withheld.
- [x] Static analysis clean; pre-existing findings attributed
  - Evidence: [report.md](report.md) §9. `shellcheck -x` exit 0 on both; `shfmt` diff 250/127 identical at HEAD and after, none of the new code in the diff.
- [x] No stdout coupling broken in consumers
  - Evidence: [report.md](report.md) §10. `framework-validate` uses `run_check … bash "$selftest_path"` (exit status).

### Not Claimed

- `framework-validate` and `release-check` were excluded by operator instruction
  and belong to the parent runner. No framework-wide certification is claimed.
- Human acceptance is not recorded.

## Scope 2: Root-Protected Scan 2B Authority And Exact-Child Supervision

**Status:** Not Started
**Depends On:** Scope 1 as historical behavior only. No Scope 1 evidence transfers.
**Epoch:** `root-protected-native-python-v1`
**Foundation:** true
**Consumer Surface:** CLI command output from the scanner, both selftests, and `test_24`.

### Scope Outcome

Scan 2B accepts a clean contribution only from an authenticated native Python.
The caller cannot replace or modify that runtime path.

The runtime executes a pinned helper through a closed operation. The runner
supervises and reaps one exact direct child. Every exit path removes its private
resources. Final closure evidence names one immutable candidate epoch.

These scenarios stay in one scope because the design requires an atomic
five-file change. Separate source deliveries would create a mixed security
contract.

### Finding-To-Scenario Contract

| Finding | Scenario | Required closure |
| --- | --- | --- |
| `SEC-B039-001` | `SCN-B039-005` | Caller-owned, fake, PATH-selected, and managed runtimes cannot authorize a clean Scan 2B result. |
| `SEC-B039-002` | `SCN-B039-006` | Security execution exposes fixed operations, pins helper bytes, treats repository content as data, and states only direct-child containment. |
| `SEC-B039-003` | `SCN-B039-007` | Fixed-wall exact-child lifecycle preserves status and signal ownership without process-group or stale-PID mechanisms. |
| `SEC-OBS-001` | `SCN-B039-008` | Normal, setup-failure, child-failure, timeout, signal, and EXIT paths remove every private resource. |
| `SEC-B039-004` | `SCN-B039-009` | Closure accepts evidence from one immutable candidate epoch only. |

### Gherkin Scenarios (Security Regression)

```gherkin
Feature: Scan 2B accepts only authenticated execution from one candidate epoch

  Scenario: SCN-B039-005 - Caller-owned Python output cannot authorize a clean verdict
    Given caller-owned PATH and managed Python executables emit the expected probe, PYSEC1, PYMOD1, and clean SCS1 strings
    When the production Scan 2B path resolves and executes its classifier authority
    Then neither caller-owned executable is accepted as the security runtime
      And neither caller-owned executable marker is created
      And Scan 2B uses an independently authenticated native runtime or fails closed without an earned clean verdict

  Scenario: SCN-B039-006 - Fixed operations execute pinned helper bytes with repository content treated as data
    Given the security runtime is authenticated
      And project paths, source bytes, and configuration contain shell-shaped and Python-shaped hostile content
    When Scan 2B invokes the fixed scan2b-classify operation
    Then no caller can select an executable, module, helper path, Python program, or generic command vector
      And helper bytes are size-bounded and digest-verified before the same byte buffer is compiled and executed
      And altered or path-replaced helper content cannot execute
      And project content enters only as validated data paths within the repository
      And diagnostics claim termination and reaping only for the exact direct child

  Scenario: SCN-B039-007 - Exact-child supervision preserves lifecycle and status on macOS and Linux
    Given the fixed operation runs under stock macOS Bash 3.2 and Linux Bash
    When it succeeds, exits nonzero, exceeds its wall, reports malformed control, returns a signal-shaped status, or receives HUP, INT, or TERM
    Then the runner registers, signals with a positive PID, and waits for exactly its direct child
      And it preserves runner-owned, child-owned, and caller-signal status distinctions
      And it uses no Bash job control, negative process-group signal, caller-shadowable kill or wait, kill-zero polling, or descendant PID retention
      And it performs no destructive stale-PID cleanup
      And no signal in the launch registration window leaves an unowned direct child

  Scenario: SCN-B039-008 - Every lifecycle path removes private execution resources
    Given a security operation registered its private directory, captures, FIFO, descriptors, traps, and direct-child state
    When the operation completes normally or leaves through partial setup failure, child failure, timeout, HUP, INT, TERM, or EXIT cleanup
    Then the exact child is reaped when present
      And every registered descriptor is closed
      And every capture, FIFO, path, and temporary directory is absent
      And prior caller traps are restored without replaying child output or environment values

  Scenario: SCN-B039-009 - Final closure accepts one immutable candidate epoch only
    Given historical BUG-039 evidence and a stabilized root-protected implementation candidate exist
    When focused checks, platform matrices, full gates, security review, planner reconciliation, human acceptance, and certification are evaluated
    Then every accepted evidence record names the same immutable candidate commit
      And evidence from a prior commit or managed-runtime epoch satisfies no redesigned DoD item
      And any implementation change invalidates affected evidence
      And no pass-count literal substitutes for named scenario, finding, and command evidence
      And only bubbles.validate may write certification or terminal status
```

### Implementation Files

1. `bubbles/scripts/python-env.sh`
2. `bubbles/scripts/python-env-selftest.sh`
3. `bubbles/scripts/implementation-reality-scan.sh`
4. `bubbles/scripts/implementation-reality-scan-selftest.sh`
5. `tests/regression/test_24_g028_sensitive_client_storage.sh`

### Change Boundary

Implementation and test edits may touch only the five files above. Planner
reconciliation may update `scopes.md` and `scenario-manifest.json`. Those
planning files do not widen the implementation boundary.

The classifier helper is a read-only, digest-pinned input. Unrelated Python
callers, CI workflows, managed docs, `spec.md`, `design.md`, `state.json`,
`report.md`, and `uservalidation.md` remain unchanged by implementation work.

Route a measured need outside this boundary to the owning specialist before
editing it. Do not include collateral cleanup.

### Consumer And Shared-Infrastructure Impact Sweep

- Treat `python-env.sh` as protected shared infrastructure.
- Preserve general interpreter usability and activation for non-security
  consumers.
- Remove superseded runner and trust APIs only after a repository-wide consumer
  trace confirms that active consumers stay inside the five-file boundary.
- Search source, tests, scripts, configuration, and docs for stale references
  to removed APIs and `BUBBLES_PYTHON_TRUSTED*`.
- Keep historical references only when their surrounding section labels the old
  epoch as historical.
- Run `python-env-selftest.sh` as the independent canary before scanner tests.
- Make the safe rollback state fail Scan 2B closed.
- Never restore managed self-attestation or generic process-group supervision as
  a rollback.
- Stop and route a boundary finding when the canary exposes a changed contract
  in an unapproved consumer.

<!-- markdownlint-disable-next-line MD024 -->
### Implementation Plan

1. Add pre-execution path, symlink, ancestor, native-format, caller-write, and
   Apple launcher validation to `python-env.sh`.
2. Add isolated posture, search-root, and module-origin validation under
   `root-protected-native-python-v1`.
3. Keep general usability separate from security authority.
4. Ignore general overrides and managed-venv locators during security
   resolution.
5. Add only the closed security operations from `design.md`.
6. Pin the helper size and digest before compiling the same byte buffer.
7. Validate every project, config, and source path as repository-contained
   data.
8. Replace process-group control with `BPY1` readiness, FIFO EOF, exact
   `builtin wait`, positive-PID signaling, and fixed status mapping.
9. Close the launch registration window without job control or PID polling.
10. Use one idempotent cleanup path for every return, signal, and EXIT path.
11. Route Scan 2B only through authenticated fixed execution.
12. Preserve `SCS1`, fail-closed findings, the unavailable sentinel, and honest
    cascade accounting.
13. Add persistent positive and adversarial coverage in the three boundary test
    files.
14. Stabilize one clean candidate before collecting final evidence.
15. Obtain fresh security review, planner reconciliation, human acceptance, and
    validate-owned certification against that candidate.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| Test Type | Scenario / Finding | Concrete Test File | Command | Required Behavior | Negative Control | Platform / Live System |
| --- | --- | --- | --- | --- | --- | --- |
| functional | `SCN-B039-001`, `SCN-B039-005` / `SEC-B039-001` | `bubbles/scripts/python-env-selftest.sh` | `bash bubbles/scripts/python-env-selftest.sh` | General usability stays separate while only a fully authenticated runtime receives security identity. | Caller-owned and managed fake executables emit valid probe and protocol text. Mutating one authority predicate must make marker or clean-verdict assertions red. | macOS Bash 3.2 and Linux Bash. Real production module. |
| functional | `SCN-B039-002`, `SCN-B039-005` / `SEC-B039-001` | `bubbles/scripts/implementation-reality-scan-selftest.sh` | `bash bubbles/scripts/implementation-reality-scan-selftest.sh` | The original unavailable and usable outcomes remain honest through the production scanner. | A fake PATH or managed executable forges clean output. Removing pre-execution authentication must make the production-path regression red. | macOS Bash 3.2 and Linux Bash. Real production scanner. |
| functional | `SCN-B039-003` | `bubbles/scripts/implementation-reality-scan-selftest.sh` | `bash bubbles/scripts/implementation-reality-scan-selftest.sh` | A copied candidate updates the expected helper digest for a one-token classifier mutation. The mutant executes and exact semantic tuple assertions fail under normal and sanitized authenticated runs. | Replacing the semantic assertions with completion-only checks must make this mutation appear green and fail the test's negative-control assertion. | macOS and Linux. Real scanner with an authorized copied-helper mutation. |
| functional | `SCN-B039-006` / `SEC-B039-002` | `bubbles/scripts/implementation-reality-scan-selftest.sh` | `bash bubbles/scripts/implementation-reality-scan-selftest.sh` | The fixed driver validates helper identity, same-byte execution, repository containment, and complete `SCS1`. | Altered helpers retain the old digest and attempt marker writes, subprocess launch, `setsid`, double fork, dynamic import, `ctypes`, `eval`, and `exec`. A copied-driver reopen mutation must also turn red. | macOS and Linux. Real scanner with adversarial inputs. |
| stress | `SCN-B039-007` / `SEC-B039-003` | `bubbles/scripts/python-env-selftest.sh` | `bash bubbles/scripts/python-env-selftest.sh` | The design-defined repeated matrix preserves exact-child lifecycle and status with fixed deadlines and no retry substitution. | Copied-runner mutations add shadowable builtins, negative-PID signaling, job control, polling, a launch gap, or status collapse. | Stock macOS Bash 3.2 and Linux Bash. Real runner. |
| functional | `SCN-B039-008` / `SEC-OBS-001` | `bubbles/scripts/python-env-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh` | `bash bubbles/scripts/python-env-selftest.sh` and `bash bubbles/scripts/implementation-reality-scan-selftest.sh` | Every normal, setup, child, timeout, signal, and EXIT path removes registered resources and restores traps. | Copied-runner mutations omit one registration, descriptor close, exact wait, private-root removal, or trap restoration. Each matching assertion must turn red. | macOS Bash 3.2 and Linux Bash. Real cleanup path. |
| functional | `SCN-B039-004` | `tests/regression/test_24_g028_sensitive_client_storage.sh` | `bash tests/regression/test_24_g028_sensitive_client_storage.sh` | An unavailable authority remains a separate skip and never becomes a coverage pass. | A sentinel-to-pass mutation must turn the counter and withheld-label assertions red before byte-identical restoration. | macOS and Linux release lanes. Real scanner cascade. |
| functional | `SCN-B039-009` / `SEC-B039-004` | `bubbles/scripts/traceability-guard.sh`, `bubbles/scripts/state-transition-guard.sh` | Run the confirmed BUG-039 scenario, traceability, and transition checks against the stabilized commit. | Final evidence, review, planning, acceptance, and validation records identify one candidate commit. Historical evidence satisfies no redesigned item. | Supply an earlier candidate identifier, then change one implementation byte. Acceptance of stale evidence fails the negative control. | Platform-neutral contract check after both lanes. |
| functional | All scenarios | Five implementation files | Run Bash syntax, warning-level shell lint, consumer-trace, and forbidden-mechanism checks on the exact candidate. | All five files parse. The approved boundary contains every active removed-API consumer. Forbidden supervision constructs are absent from the security path. | Reintroduce one removed API reference or forbidden construct in a copied tree. The matching focused check must turn red. | Platform-neutral static checks. No runtime service. |
| functional | All scenarios | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | The complete framework validation succeeds on the same immutable candidate used by focused evidence. | A reduced suite, filtered output, prior run, or different commit cannot satisfy this row. | Full framework execution. |
| functional | All scenarios | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh release-check` | Release readiness succeeds on the same candidate after focused and full validation. | A changed tree or mismatched commit invalidates this row and downstream closure claims. | Full release execution. |

This scope changes no browser UI, HTTP API, mutable datastore, or runtime
service. Production shell entrypoints provide the end-to-end path. Hostile
fixtures and copied-runner mutations complement that path and never replace it.

### Definition Of Done

- [ ] The implementation diff contains only the five approved files. An
  independent diff check finds no collateral source, test, workflow, docs,
  state, report, or human-acceptance edit.
- [ ] `SCN-B039-001` through `SCN-B039-004` remain valid under the root-protected
  epoch. Fresh scenario evidence comes from the stabilized candidate.
- [ ] `SCN-B039-005` rejects caller-owned, fake, PATH-selected, and managed
  interpreters despite forged probe and protocol strings. Every paired
  authority mutation turns red before byte-identical restoration.
- [ ] `SCN-B039-006` proves the closed operation surface, helper pin, same-byte
  execution, repository-as-data boundary, complete `SCS1`, and direct-child-only
  claim. Every helper payload and reopen mutation turns red before restoration.
- [ ] `SCN-B039-007` proves exact-child supervision for every named outcome on
  stock macOS Bash 3.2 and Linux Bash. No forbidden supervision mechanism or
  launch orphan remains.
- [ ] `SCN-B039-008` proves every named lifecycle path removes all private
  resources, reaps the exact child, clears lifecycle state, and restores caller
  traps. Every omitted-cleanup mutation turns red.
- [ ] The consumer sweep finds zero active consumers of removed runner and
  trust APIs outside the approved boundary. Every retained old reference is
  historical text.
- [ ] The shared-infrastructure canary passes before scanner and broad suites.
  It preserves general Python behavior and verifies the fail-closed rollback.
- [ ] Focused syntax, shell lint, trust, helper, lifecycle, cleanup, scanner,
  cascade, and forbidden-mechanism checks succeed. Required cases remain
  active. Deadlines remain fixed. Runs use no retries or output filters.
- [ ] The complete cross-platform matrix succeeds on stock macOS Bash 3.2 and
  Linux Bash. Both lanes prove an authenticated positive path and every
  portable negative path.
- [ ] `framework-validate` and `release-check` both succeed with complete output
  on the same clean immutable candidate used by all final evidence.
- [ ] A fresh independent security review accounts for `SEC-B039-001`,
  `SEC-B039-002`, `SEC-B039-003`, `SEC-B039-004`, and `SEC-OBS-001` one to one.
  The review makes no recursive containment claim.
- [ ] After implementation stabilization, `bubbles.plan` reconciles the
  scenario, Test Plan, DoD, ownership, and evidence-epoch contracts to the exact
  candidate. It does not convert historical evidence into current evidence.
- [ ] `SCN-B039-009` proves every focused, platform, framework, release,
  security, planning, acceptance, and validation record names one candidate
  commit. No pass total substitutes for named evidence.
- [ ] The human owner records fresh acceptance for the redesigned behavior.
  Existing checked `uservalidation.md` content remains historical acceptance.
- [ ] `bubbles.validate` verifies exact-candidate evidence and owns every
  certification or terminal-status write. Other specialists leave
  certification state untouched.
