# Scopes: BUG-039 Unusable Interpreter Misreported As Classification Failures

## Planning Basis

This plan derives from [spec.md](spec.md) and the newly authoritative redesign in
[design.md](design.md). Execution evidence belongs in [report.md](report.md).
Human acceptance belongs in [uservalidation.md](uservalidation.md).

Scope 1 is a superseded historical record for the delivered
`managed-venv-only-v1` epoch. Its checked receipts remain historical facts.
They do not prove, unlock, or transfer into the active Scope 2 epoch.

Scope 2 is the only active execution scope. It preserves stable identifiers
`SCN-B039-001` through `SCN-B039-009` and implements the authoritative
`privileged-native-supervision-v2` design. The retained worker trust contract
is `root-protected-native-python-v1`. Privileged entry, native supervision,
caller integration, governance guidance, and evidence closure must land as one
coherent epoch because a mixed contract cannot earn Scan 2B authority.

## Execution Outline

### Phase Order

1. **Superseded Scope 1: Historical usability repair.** Preserve the prior
   receipts as archive-only context and execute none of its plan.
2. **Scope 2 red controls.** Make each `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`,
   and `HAR-R3` regression fail against the clean successor before source work.
3. **Scope 2 privileged entry and native supervision.** Add direct
   `privileged-bash-entry-v1`, fixed `root-protected-perl-supervisor-v1`, and
   retained `root-protected-native-python-v1` worker authority.
4. **Scope 2 caller and guidance integration.** Route the CLI and transition
   guard through the direct entry and align framework guidance with the same
   non-fallback contract.
5. **Scope 2 platform and repetition proof.** Run focused stock macOS Bash 3.2,
   supported Linux, and 30-consecutive lifecycle matrices on one candidate.
6. **Scope 2 closure.** Run complete framework and release gates, then obtain
   fresh security review, human acceptance, and validate-only certification.

### New Types And Signatures

- `bubbles_python_runs(interpreter)` remains a general usability probe only.
- `bubbles_python_resolve_runnable()` remains general resolution only.
- `bubbles_python_security_require_boundary()` accepts no caller authority and
  requires `BSEC1` plus actual privileged Bash mode.
- `bubbles_python_resolve_security_runtime()` accepts no candidate and returns
  authenticated `root-protected-native-python-v1` identity.
- `bubbles_python_run_security_operation(operation, operation_data)` accepts a
  closed operation and bounded data only; it exposes no executable vector.
- `bubbles_python_security_cleanup()` removes registered files only after the
  native supervisor has been reaped; it never signals or waits on a worker.
- `BSEC1` identifies privileged entry and `BPS1` records supervisor-owned
  completion after `waitpid`.
- `PYSEC1`, `PYMOD1`, and `SCS1` retain their current semantics and versions.
- `BPY1`, worker-held lifecycle FIFOs, Bash worker/watchdog PIDs, and Bash
  worker signaling are archive-only and absent from active execution.

### Validation Checkpoints

- Scope 1 is archive-only. No Scope 1 evidence satisfies a Scope 2 item.
- The five finding-specific red controls must fail for the intended reason
  before any Scope 2 implementation edit begins.
- Focused entry, supervisor, helper, cleanup, and skip-accounting checks gate
  the stock macOS Bash 3.2 lane.
- The macOS lane gates the supported Linux lane. Both lanes must authenticate
  fixed Perl and Python paths without a PATH or Bash supervisor fallback.
- Both platform lanes gate the 30-consecutive lifecycle matrix. A failed run is
  retained and is never replaced by a retry or wider deadline.
- The focused matrix gates caller integration and guidance validation.
- Caller integration gates complete `framework-validate`; that gate in turn
  gates `release-check` on the same immutable candidate.
- Framework and release success gate fresh independent security review.
- Security review gates fresh human acceptance. Human acceptance gates the
  final validate-only certification request.

## Plan Inventory

| Scope | Epoch | Surfaces | Primary validation | Status |
| --- | --- | --- | --- | --- |
| 1. Interpreter Usability Probe, Named Skip, And Honest Cascade | `managed-venv-only-v1` | Scanner selftest, regression cascade | Historical receipts only | Superseded; do not execute |
| 2. Privileged Scan 2B Entry And Native Supervisor | `privileged-native-supervision-v2` | Entry, supervisor, scanner, callers, governance, docs, tests | Red controls, focused and platform matrices, full gates, independent closure | Not started |

## Superseded Scope 1 (Do Not Execute): Interpreter Usability Probe, Named Skip, And Honest Cascade

**Status:** Superseded historical record; not active execution inventory
**Depends On:** None
**Epoch:** `managed-venv-only-v1` (historical and superseded for security closure)
**Consumer Surface:** CLI command output from the scanner selftest and `test_24`.

### Historical Evidence Boundary

This scope remains intelligible as the delivery record for the original
presence-versus-usability repair. Its implementation plan and checked DoD
describe that candidate only. The secure redesign does not reopen or rewrite
those observations. Every security-redesign claim is owned by Scope 2 and must
receive fresh evidence from one immutable `privileged-native-supervision-v2`
candidate whose worker trust remains `root-protected-native-python-v1`.

### Historical Scenario Records

```gherkin
Feature: A missing prerequisite is named, not misattributed

  Historical record: SCN-B039-001 - Unusable interpreter produces a named skip, not classification failures
    Given the active developer directory has an unaccepted Xcode licence
      And python3 resolves on PATH but exits 69 without running
    When the managed selftest runs under the sanitized system-only PATH
    Then it emits SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
      And it emits a SKIP naming the interpreter, its exit status and the operator remediation
      And it emits zero FAIL lines
      And it exits 0

  Historical record: SCN-B039-002 - A usable interpreter under the same PATH runs everything
    Given DEVELOPER_DIR points at an accepted toolchain
    When the managed selftest runs under the sanitized system-only PATH
    Then no skip is emitted
      And every Scan 2B semantic and config-integrity assertion executes

  Historical record: SCN-B039-003 - The assertions still catch a real classifier regression
    Given a usable interpreter
      And the classifier's classification ladder is mutated
    When the managed selftest runs
    Then it exits 1 and reports the mismatched semantic tuples

  Historical record: SCN-B039-004 - A skipped coverage claim is never counted as a pass
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

## Scope 2: Privileged Scan 2B Entry And Native Supervisor

**Status:** Not Started
**Depends On:** None. Superseded Scope 1 is historical context, not an execution dependency.
**Epoch:** `privileged-native-supervision-v2`
**Retained Worker Trust:** `root-protected-native-python-v1`
**Foundation:** true
**Consumer Surface:** Direct scanner invocation, `cli.sh scan`, transition-guard Check 16, both owning selftests, `test_24`, framework guidance, security review, human acceptance, and validate-only certification.

### Scope Outcome

Every canonical Scan 2B caller enters `privileged-bash-entry-v1` before sourcing
framework modules. A fixed root-protected `/usr/bin/perl` supervisor owns,
signals, and reaps one direct authenticated Python worker with `waitpid`.

Bash retains only a wait handle for the Perl supervisor. It never stores or
signals a worker or watchdog PID. Worker output, EOF, readiness text, and
worker-held descriptors cannot decide completion. The final accepted evidence
set names one immutable `privileged-native-supervision-v2` candidate.

All active work remains in one foundation scope. Splitting entry, supervisor,
callers, or guidance would temporarily create conflicting authority contracts.

### Finding-To-Scenario Contract

| Finding | Stable scenario | Required closure | Owner |
| --- | --- | --- | --- |
| `SEC-R1` | `SCN-B039-005` | Canonical callers enter `/bin/bash -p` through an empty environment before any module source. | `bubbles.implement`; adversarial proof by `bubbles.test` |
| `SEC-R2` | `SCN-B039-006` | Fixed root-protected `/usr/bin/perl` owns one direct worker and reaps it with `waitpid` before completion. | `bubbles.implement`; lifecycle proof by `bubbles.test` |
| `HAR-R1` | `SCN-B039-007` | Bash carries no worker/watchdog signaling authority and propagates pending parent signals only after supervisor reap. | `bubbles.implement`; signal-window proof by `bubbles.test` |
| `HAR-R2` | `SCN-B039-008` | Only supervisor-owned `waitpid` determines completion; target-controlled output, EOF, and descriptors cannot do so. | `bubbles.implement`; forged-control proof by `bubbles.test` |
| `HAR-R3` | `SCN-B039-009` | Active artifacts use current finding identifiers and one immutable epoch. Historical identifiers remain archive-only. | `bubbles.plan`, `bubbles.test`, `bubbles.security`, and `bubbles.validate` within their owned artifacts |

### Gherkin Scenarios

```gherkin
Feature: Scan 2B earns authority through privileged native supervision

  Scenario: SCN-B039-001 - An unavailable prerequisite is named without a false verdict
    Given the privileged entry, native supervisor, authenticated runtime, or pinned helper cannot execute
    When the managed Scan 2B selftest evaluates the classifier-dependent group
    Then it emits SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
      And it emits one actionable SKIP with numeric status and a closed diagnostic
      And it emits no classifier-attributed PASS or FAIL
      And the scanner preserves fail-closed unresolved findings

  Scenario: SCN-B039-002 - A complete privileged path executes every classifier assertion
    Given privileged entry, the native supervisor, the authenticated Python worker, and the pinned helper all validate
    When the managed Scan 2B selftest runs
    Then every semantic and configuration assertion executes
      And no unavailable sentinel is emitted
      And BSEC1, BPS1, PYSEC1, PYMOD1, and SCS1 are each complete

  Scenario: SCN-B039-003 - The authorized classifier mutation remains fatal
    Given one copied candidate carries the authorized one-token classifier mutation and its reviewed helper digest
    When normal and sanitized privileged Scan 2B paths execute that candidate
    Then both runs exit nonzero on the exact semantic tuple mismatch
      And restoring the candidate restores byte identity

  Scenario: SCN-B039-004 - A skipped coverage claim remains distinct from a pass
    Given the managed selftest emitted the unavailable sentinel
    When test_24 accounts for the managed Scan 2B result
    Then it increments SKIP_COUNT only
      And it withholds the coverage PASS label
      And FAIL_COUNT remains the suite exit authority

  Scenario: SCN-B039-005 - SEC-R1 privileged entry excludes hostile Bash startup state
    Given exported functions and BASH_ENV attempt marker writes and status changes
    When a canonical caller launches Scan 2B
    Then env -i and /bin/bash -p establish BSEC1 before any module source
      And no hostile marker enters the privileged child
      And an ordinary direct scanner invocation is labeled compat-reexec without claiming pre-boundary cleanliness

  Scenario: SCN-B039-006 - SEC-R2 native supervision owns one direct worker through reap
    Given a fixed root-protected /usr/bin/perl and authenticated Python are available
    When a closed security operation starts, exits, fails, times out, floods output, or receives a signal
    Then the Perl supervisor remains the direct worker parent until waitpid reaps that worker
      And it signals only while that unreaped ownership exists
      And it emits one valid BPS1 completion after reap
      And no caller selects a program, helper path, wall, grace period, or output limit

  Scenario: SCN-B039-007 - HAR-R1 Bash never signals a worker or watchdog PID
    Given parent HUP, INT, or TERM can arrive during launch, collection, termination, or cleanup
    When Bash waits for the Perl supervisor
    Then Bash retains only the supervisor wait handle
      And no Bash path stores or signals a worker or watchdog PID
      And pending parent status is returned only after the supervisor has been reaped
      And no stale PID, process-group, job-control, kill-zero, or descendant cleanup path exists

  Scenario: SCN-B039-008 - HAR-R2 target-controlled channels cannot determine completion
    Given a worker closes descriptors, forges BPS1 text, hangs after output, or leaves a descriptor-holding descendant
    When the native supervisor collects bounded output
    Then only supervisor-owned waitpid determines worker completion
      And the worker cannot write the supervisor control descriptor
      And pipe EOF and worker text are data rather than completion authority
      And cleanup starts only after the supervisor is reaped

  Scenario: SCN-B039-009 - HAR-R3 current identifiers bind one immutable evidence epoch
    Given historical evidence and the active privileged-native-supervision-v2 candidate both exist
    When focused, platform, caller, documentation, framework, release, security, acceptance, and validation records are evaluated
    Then active records use SEC-R1, SEC-R2, HAR-R1, HAR-R2, and HAR-R3 only
      And every accepted record names the same immutable candidate commit and protocol epoch
      And earlier evidence satisfies no active Scope 2 item
      And only bubbles.validate writes certification or terminal status
```

### Owner Assignments

| Surface | Allowed responsibility | Owner |
| --- | --- | --- |
| `scopes.md`, `scenario-manifest.json`, planning and work-boundary routing in `state.json` | Preserve scenario contracts, parity, epoch, path boundary, and next-owner routing. | `bubbles.plan` |
| `python-env.sh`, scanner, CLI, and transition guard | Implement privileged entry, fixed native supervision, protocol validation, and caller status propagation. | `bubbles.implement` |
| Owning selftests, `test_24`, red mutations, platform lanes, repetition, and full executable gates | Add and execute persistent scenario-specific proof without weakening existing assertions. | `bubbles.test` |
| Framework instruction, template, shared requirement, validation-agent guidance, and security recipe | Align operator and agent guidance after runtime behavior is stable. | `bubbles.docs` for prose; code-owning specialists review executable snippets |
| One-to-one review of `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3` | Inspect the exact immutable candidate and return a fresh security result. | `bubbles.security` |
| Acceptance checklist decisions | Review current behavior and explicitly accept or reject each current item. | Human owner |
| Certification and terminal state | Re-resolve the transition, verify exact-candidate evidence, and own all `certification.*`, `certifiedAt`, and terminal-status writes. | `bubbles.validate` |

### Change Boundary

`workBoundary.allowedPaths` must contain exactly this set:

1. `bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure/**`
2. `bubbles/scripts/python-env.sh`
3. `bubbles/scripts/python-env-selftest.sh`
4. `bubbles/scripts/implementation-reality-scan.sh`
5. `bubbles/scripts/implementation-reality-scan-selftest.sh`
6. `tests/regression/test_24_g028_sensitive_client_storage.sh`
7. `bubbles/scripts/cli.sh`
8. `bubbles/scripts/state-transition-guard.sh`
9. `bubbles/scripts/state-transition-guard-selftest.sh`
10. `.github/copilot-instructions.md`
11. `templates/copilot-instructions.md.tmpl`
12. `agents/bubbles_shared/critical-requirements.md`
13. `agents/bubbles.validate.agent.md`
14. `docs/recipes/security-review.md`

Artifact ownership still limits writes inside the BUG-039 folder. The widened
path set is not permission for one specialist to edit another owner's file.

Every dependency manifest, workflow, classifier-helper byte, `guard-lib.sh`,
release manifest, datastore, network, browser, deployment, cross-repository,
and unrelated Python call site is excluded. Collateral cleanup is prohibited.

### Consumer And Shared-Infrastructure Impact Sweep

- Treat `python-env.sh`, the scanner entry, `cli.sh scan`, and transition-guard
  Check 16 as protected shared infrastructure.
- Inventory direct callers of the scanner, security APIs, `BSEC1`, `BPS1`,
  `PYSEC1`, `PYMOD1`, `SCS1`, `BPY1`, worker/watchdog PID state, and old active
  finding labels before removal.
- Preserve general Python usability consumers. General resolver success never
  becomes Scan 2B authority.
- Run `python-env-selftest.sh` as the independent canary before scanner,
  transition-guard, framework, or release suites.
- Verify `cli.sh scan` and transition-guard Check 16 enter the direct privileged
  boundary and preserve the scanner's real status.
- Keep the classifier helper read-only and digest-pinned. Update no helper byte.
- The rollback state fails Scan 2B closed. It never restores ordinary Bash
  authority, a Bash watchdog, a worker-held completion channel, or a PATH
  supervisor fallback.
- Before broad validation, prove zero changed path outside the exact boundary
  and zero active stale consumer reference outside an explicitly archived
  section.

<!-- markdownlint-disable-next-line MD024 -->
### Implementation Plan

1. `bubbles.test` adds persistent red controls for all five current findings.
   Each control must fail on clean successor `72bbb987ef6c396ba00b1e6b94b95526d230e1a5`
   for the intended missing contract before implementation starts.
2. `bubbles.implement` adds the first-executable-statement compatibility entry
   to the scanner and direct privileged entry to `cli.sh` and transition-guard
   Check 16.
3. `bubbles.implement` authenticates fixed `/usr/bin/perl` with the retained
   root-protected path checks and embeds the fixed taint-mode supervisor in
   `python-env.sh`.
4. `bubbles.implement` moves wall, output, status, signal, direct-worker
   ownership, and `waitpid` reaping into the Perl supervisor. Bash retains only
   a supervisor wait handle.
5. `bubbles.implement` removes active `BPY1`, completion FIFO, worker/watchdog
   PID, Bash worker signal, process-group, job-control, and stale-PID cleanup
   mechanisms from the security path.
6. `bubbles.implement` preserves `root-protected-native-python-v1`, `PYSEC1`,
   `PYMOD1`, same-byte helper identity, complete `SCS1`, fail-closed findings,
   unavailable sentinel behavior, and honest skip accounting.
7. `bubbles.test` rewrites the owning harnesses around supervisor-owned control
   and adds the full lifecycle, boundary contamination, helper, caller,
   platform, and 30-consecutive matrices from the design.
8. `bubbles.docs` aligns the five admitted guidance surfaces with the direct
   privileged caller path, Perl prerequisite, diagnostics, remediation, and
   explicit non-claims.
9. `bubbles.test` stabilizes one clean immutable candidate, then executes Test
   Plan rows `TP-S2-01` through `TP-S2-09` in order without evidence reuse.
10. `bubbles.security`, the human owner, and `bubbles.validate` execute rows
    `TP-S2-10` through `TP-S2-12` against that unchanged candidate.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| ID | Category | Scenario / finding coverage | Concrete files or surface | Required command or action | Required observable result | Owner | Live |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `TP-S2-01` | adversarial red controls | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, `HAR-R3` | `bubbles/scripts/python-env-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh`, `tests/regression/test_24_g028_sensitive_client_storage.sh` | Run `/bin/bash bubbles/scripts/python-env-selftest.sh`, `/bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh`, and `/bin/bash tests/regression/test_24_g028_sensitive_client_storage.sh` with each bounded finding mutation before production edits. | Every finding-specific control is RED for its intended missing invariant. The failed outputs and exact clean-successor identity remain recorded; no old receipt is substituted. | `bubbles.test` | Yes: production shell paths with copied mutations |
| `TP-S2-02` | functional implementation | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, `HAR-R3` | `bubbles/scripts/python-env-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh`, `tests/regression/test_24_g028_sensitive_client_storage.sh` | Run `/bin/bash bubbles/scripts/python-env-selftest.sh`, then `/bin/bash bubbles/scripts/implementation-reality-scan-selftest.sh`, then `/bin/bash tests/regression/test_24_g028_sensitive_client_storage.sh` on the implemented candidate. | Privileged entry, native supervision, retained worker trust, classifier semantics, skip accounting, cleanup, and all red-to-green controls succeed with no skipped required case. | `bubbles.implement` writes source; `bubbles.test` executes proof | Yes: real framework scripts |
| `TP-S2-03` | platform functional | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2` | `bubbles/scripts/python-env-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh`, `tests/regression/test_24_g028_sensitive_client_storage.sh` | On macOS, run the three focused commands from `TP-S2-02` with stock `/bin/bash` 3.2 and fixed base-system anchors. | The lane authenticates `/usr/bin/perl` and Python, executes all portable positive and negative cases, preserves exact status ownership, and leaves no process or private-file residue. | `bubbles.test` | Yes: stock macOS Bash 3.2 |
| `TP-S2-04` | platform functional | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2` | `bubbles/scripts/python-env-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh`, `tests/regression/test_24_g028_sensitive_client_storage.sh` | In the supported Linux lane, run the three focused commands from `TP-S2-02` with `/bin/bash` and fixed `/usr/bin/perl`. | The lane proves one authenticated Perl and Python positive plus every portable negative case. Missing or untrusted Perl fails closed and never activates a fallback. | `bubbles.test` | Yes: supported Linux runner |
| `TP-S2-05` | stress / repeated lifecycle | `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`; `SEC-R2`, `HAR-R1`, `HAR-R2` | `bubbles/scripts/python-env-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh` | Run each persistent success, fast-exit, timeout, output-limit, HUP, INT, and TERM matrix for 30 consecutive iterations through the owning selftest commands. | All 30 iterations preserve event order, owner, timeout bit, byte counts, one reap, zero post-reap signals, fixed wall and grace, and zero retry substitution or residue. | `bubbles.test` | Yes: real process lifecycle on macOS and Linux |
| `TP-S2-06` | caller integration / regression | `SCN-B039-002`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2` | `bubbles/scripts/implementation-reality-scan-selftest.sh`, `bubbles/scripts/state-transition-guard-selftest.sh` | Run `bash bubbles/scripts/cli.sh scan .` and `bash bubbles/scripts/state-transition-guard-selftest.sh` after focused lanes succeed. | CLI scan and Check 16 enter direct `BSEC1`, validate `BPS1`, preserve the scanner's real status, and expose no ordinary-Bash authority or target-controlled completion path. | `bubbles.test` | Yes: canonical caller entrypoints |
| `TP-S2-07` | documentation and static contract | `SCN-B039-009`; `HAR-R3` | Five admitted guidance paths plus active BUG-039 artifacts | Run `bash bubbles/scripts/cli.sh agnosticity` and `bash bubbles/scripts/cli.sh lint bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure`, then scan active text for current epoch, trust root, protocols, finding identifiers, and forbidden fallback claims. | Source guidance and install template agree on direct privileged entry, Perl preflight, remediation, non-claims, and current identifiers. Historical labels occur only in explicit archives. | `bubbles.docs`; planning parity reviewed by `bubbles.plan` | No: artifact and static contract |
| `TP-S2-08` | full framework regression | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, `HAR-R3` | `bubbles/scripts/framework-validate.sh` | Run `bash bubbles/scripts/cli.sh framework-validate` through bounded evidence capture on the clean immutable candidate. | The complete unfiltered framework validation exits 0 and records the candidate commit, helper digest, protocol epoch, platform evidence references, and no replacement run. | `bubbles.test` | Yes: complete framework validation |
| `TP-S2-09` | release readiness regression | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, `HAR-R3` | `bubbles/scripts/release-check.sh` | Run `bash bubbles/scripts/cli.sh release-check` through bounded evidence capture on the unchanged candidate from `TP-S2-08`. | Release readiness exits 0 with complete output. Its candidate and protocol identities match every accepted focused and framework record. | `bubbles.test` | Yes: complete release validation |
| `TP-S2-10` | independent security review | `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, `HAR-R3` | `docs/recipes/security-review.md` and exact immutable candidate receipts | Invoke `/bubbles.security` for BUG-039 after `TP-S2-09`, with the candidate commit and `privileged-native-supervision-v2` epoch fixed. | A fresh review accounts for all five findings one to one, validates red controls and final proofs, and makes no recursive descendant-containment or pre-boundary cleanliness claim. | `bubbles.security` | Yes: independent review of executed proof |
| `TP-S2-11` | human acceptance | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `HAR-R3` | `bugs/BUG-039-interpreter-unusable-misreported-as-classification-failure/uservalidation.md` | The human owner reviews the unchanged candidate and records fresh decisions in `uservalidation.md`; automation does not alter acceptance boxes. | Every current acceptance item is explicitly accepted by the human owner. Historical checked content alone satisfies nothing in Scope 2. | Human owner | Yes: human review of current behavior |
| `TP-S2-12` | validate-only certification | `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, `HAR-R3` | `bubbles/scripts/state-transition-guard.sh` | Invoke `/bubbles.validate` in validate-only certification mode after `TP-S2-11`. | Validate re-resolves the current transition, proves Test Plan and DoD parity, rejects stale evidence, and alone writes any certification or terminal status. | `bubbles.validate` | Yes: certification over current execution evidence |

This scope changes no browser UI, HTTP API, mutable datastore, or network
service. Production shell entrypoints are the external behavior surface. Copied
mutations complement those entrypoints and never replace the real path.

### Definition Of Done — Test Plan Parity

Each item below matches exactly one Test Plan row. Every item starts unchecked.
No earlier BUG-039 evidence may check an item.

- [ ] `TP-S2-01` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`. Owner: `bubbles.test`. All five finding-specific red controls execute against clean successor `72bbb987ef6c396ba00b1e6b94b95526d230e1a5` and fail for the intended missing invariant before implementation.
- [ ] `TP-S2-02` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`. Owners: `bubbles.implement` and `bubbles.test`. The complete in-boundary implementation turns every focused scenario and mutation control green without a skipped required case. An exact changed-path check reports no collateral edit.
- [ ] `TP-S2-03` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, and `SCN-B039-008`; `SEC-R1`, `SEC-R2`, `HAR-R1`, and `HAR-R2`. Owner: `bubbles.test`. Stock macOS `/bin/bash` 3.2 executes the complete focused positive and negative matrix with authenticated Perl and Python, exact status ownership, and zero process or private-file residue.
- [ ] `TP-S2-04` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, and `SCN-B039-008`; `SEC-R1`, `SEC-R2`, `HAR-R1`, and `HAR-R2`. Owner: `bubbles.test`. The supported Linux lane executes the complete portable matrix. It proves authenticated Perl and Python positives. It also proves absent or untrusted Perl fails closed without a fallback.
- [ ] `TP-S2-05` — `SCN-B039-006`, `SCN-B039-007`, and `SCN-B039-008`; `SEC-R2`, `HAR-R1`, and `HAR-R2`. Owner: `bubbles.test`. Thirty consecutive iterations of every required lifecycle class preserve event order, status owner, timeout bit, byte counts, one reap, zero post-reap signals, fixed timing, and zero retries or residue.
- [ ] `TP-S2-06` — `SCN-B039-002`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, and `SCN-B039-008`; `SEC-R1`, `SEC-R2`, `HAR-R1`, and `HAR-R2`. Owner: `bubbles.test`. `cli.sh scan` and transition-guard Check 16 both enter direct `BSEC1`, validate `BPS1`, and preserve the scanner's real status under positive and adversarial caller integration cases.
- [ ] `TP-S2-07` — `SCN-B039-009`; `HAR-R3`. Owners: `bubbles.docs` and `bubbles.plan`. All admitted guidance and active planning artifacts agree on epoch `privileged-native-supervision-v2`, worker trust `root-protected-native-python-v1`, current identifiers, Perl prerequisite, remediation, and explicit non-claims. Lint and static contract checks pass.
- [ ] `TP-S2-08` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`. Owner: `bubbles.test`. Complete bounded `framework-validate` exits 0 on the clean immutable candidate and records the exact candidate, helper digest, protocols, and platform-proof identities without filtered output or replacement evidence.
- [ ] `TP-S2-09` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`. Owner: `bubbles.test`. Complete bounded `release-check` exits 0 on the unchanged `TP-S2-08` candidate and matches every accepted focused, platform, caller, and framework identity.
- [ ] `TP-S2-10` — `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`. Owner: `bubbles.security`. A fresh independent security review accounts one to one for `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`. It validates current red and green proof and records every explicit non-claim.
- [ ] `TP-S2-11` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`; `HAR-R3`. Owner: Human owner. Fresh human acceptance is recorded for the current immutable candidate without automation changing `uservalidation.md`. Historical acceptance satisfies no item.
- [ ] `TP-S2-12` — `SCN-B039-001`, `SCN-B039-002`, `SCN-B039-003`, `SCN-B039-004`, `SCN-B039-005`, `SCN-B039-006`, `SCN-B039-007`, `SCN-B039-008`, and `SCN-B039-009`; `SEC-R1`, `SEC-R2`, `HAR-R1`, `HAR-R2`, and `HAR-R3`. Owner: `bubbles.validate`. Validate-only certification re-resolves the transition, verifies current-candidate evidence and 12-row parity, rejects every stale epoch, and owns all certification or terminal-status writes.
