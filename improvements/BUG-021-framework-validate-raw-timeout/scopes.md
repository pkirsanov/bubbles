# Scopes: BUG-021 Framework Validate Raw Timeout

Planning authority: [spec.md](spec.md), [design.md](design.md),
[scenario-manifest.json](scenario-manifest.json),
[test-plan.json](test-plan.json), [report.md](report.md), and
[uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Scope 1 - Portable Framework Validation Deadlines:** establish the final
   source-only regression and mandatory pre-edit RED, route exactly two
   production registrations through the existing portable helper, then prove
   runtime, aggregation, install, framework, and release identity behavior.

### Owner Order Inside Scope 1

1. `bubbles.test` authors the complete persistent regression and captures a
   valid final-byte RED while production source remains unchanged.
2. `bubbles.implement` loads the managed sibling helper fail-loud, changes only
   the two deadline command prefixes, and registers the source-only regression.
3. `bubbles.test` runs the identical regression bytes and command for GREEN,
   then executes the focused and broad compatibility matrix.
4. `bubbles.test` reconciles install-provenance assertions without changing
   install behavior or copying the source-only regression downstream.
5. `bubbles.releases` regenerates release identity through canonical tooling
   after all source, test, and provenance bytes settle.
6. `bubbles.validate` evaluates completion evidence and remains the only owner
   permitted to write `certification.*` or terminal status.

### New Types and Signatures

- No new type, API, schema, provider, wrapper, feature flag, or dependency.
- Existing helper contract:
  `bubbles_run_with_timeout <seconds> <command...>`.
- Existing aggregate contract:
  `run_check <label> bubbles_run_with_timeout <seconds> bash <selftest>`.
- Authoritative, collision-free source-only regression entrypoint (all planning,
  state-routing, provenance, release, and status references use this exact
  path):
  `tests/regression/test_28_framework_validate_portable_timeout.sh`.
- Existing configuration keys and `120`-second defaults remain unchanged:
  `BUBBLES_MACOS_PORTABILITY_GUARD_SELFTEST_TIMEOUT_SECONDS` and
  `BUBBLES_WORKFLOW_PLANNING_PROVENANCE_SELFTEST_TIMEOUT_SECONDS`.

### Validation Checkpoints

1. **RED gate:** final regression bytes fail for the two production raw-call
   defects before any production, provenance, or release edit.
2. **Focused GREEN gate:** identical bytes and command prove no-timeout PATH,
   helper `0`/ordinary-nonzero/`124`, deadline forwarding, and `run_check`
   continuation and aggregate exit behavior.
3. **Reintroduction gate:** per-call-site raw mutations, direct-child bypass,
   and `124` suppression/remapping are rejected by named assertions.
4. **Portability gate:** direct and BUG-019 exact scans, portability selftest,
   canonical helper controls, regression quality, and Bash 3.2 syntax pass.
5. **Integration gate:** install provenance and full framework validation agree
   on managed source while
   `tests/regression/test_28_framework_validate_portable_timeout.sh` remains
   source-only.
6. **Release gate:** the release owner regenerates identity and `release-check`
   proves source, install, and release agreement before validation.

## Overview

This packet has one vertical scope because the user-observable outcome is one
framework-validation contract: both existing deadline-bearing registrations
remain bounded and observable on Linux and macOS without requiring optional
coreutils. Splitting test wiring, production calls, provenance, and release
identity into horizontal scopes would allow an intermediate state that cannot
be validated end to end.

Scope 1 cannot start production implementation until the final regression has
produced the mandatory valid RED. No later owner may reinterpret a scanner
suppression as runtime evidence.

| # | Scope | Depends On | Surfaces | Primary Tests | DoD Summary | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Portable Framework Validation Deadlines | None | framework validator, source-only regression, install provenance, release identity | production-path RED/GREEN, helper/result matrix, portability, framework, release | every Test Plan row passes; exact boundary and ownership hold | Not Started |

## Scope 1: Portable Framework Validation Deadlines

**Status:** Not Started
**Depends On:** None
**Foundation:** false
**Scope-Kind:** runtime-behavior

### Gherkin Scenarios

#### SCN-BUG-021-001: Framework validation runs both deadline-bearing checks without GNU timeout

```gherkin
Scenario: Framework validation runs both deadline-bearing checks without GNU timeout
  Given a macOS system-only PATH with neither timeout nor gtimeout
  When framework validation reaches the portability and planning provenance selftests
  Then both checks execute through the portable watchdog path
  And no command-not-found or raw-timeout portability finding occurs
```

#### SCN-BUG-021-002: Portable timeout outcomes remain observable and exact

```gherkin
Scenario: Portable timeout outcomes remain observable and exact
  Given a controlled child that exceeds its configured deadline
  When the production framework validation timeout path runs
  Then the check observes exit 124
  And a non-timeout child exit remains unchanged
  And removing the helper call makes the adversarial regression fail
```

These two IDs and texts must remain byte-for-byte aligned with
`scenario-manifest.json`. Every Test Plan row below names one or both IDs and
has exactly one matching test-completion DoD item.

### Mandatory Failing-First Gate

`bubbles.test` must complete
`tests/regression/test_28_framework_validate_portable_timeout.sh` before any
production edit. The test owner records the final regression-byte digest and
runs the exact command planned for GREEN against unchanged canonical
production bytes. Those complete test bytes must fail for the intended two raw
timeout registrations under the sanitized no-`timeout` / no-`gtimeout`
production path. If the test changes after RED, the changed final bytes must
produce a new valid RED before implementation resumes.

`bubbles.test` owns the final regression bytes and RED digest.
`bubbles.implement` must not edit
`tests/regression/test_28_framework_validate_portable_timeout.sh`; after the
production change, `bubbles.test` must prove the GREEN digest is identical to
the RED digest before interpreting any result.

The cross-platform digest command is exact and capability-based:

```bash
test_file="tests/regression/test_28_framework_validate_portable_timeout.sh"; if command -v sha256sum >/dev/null 2>&1; then sha256sum "$test_file"; else shasum -a 256 "$test_file"; fi
```

Stock Linux selects `sha256sum`; stock macOS selects `shasum -a 256`. A missing
digest provider is a hard command failure, not permission to continue without
the RED/GREEN byte-identity proof.

A valid RED must fail on the intended production defect and show all of these
signals:

- the staged canonical `framework-validate.sh` still contains both raw
  deadline registrations;
- the production-path contract rejects both missing helper-call expectations;
- neither controlled target-child execution marker is accepted as present when
  the raw optional command cannot resolve; and
- failure is not caused by fixture construction, missing canonical inputs,
  unrelated framework checks, an inverted expectation mode, or a bailout.

Production source, install provenance, generated release identity, BUG-019,
and certification fields remain unchanged throughout this gate.

### Production-Path Fixture Architecture

The regression creates one uniquely owned temporary root and removes it on
`EXIT`, `INT`, and `TERM`. It stages the current canonical
`framework-validate.sh` and `guard-lib.sh` under a source-shaped
`bubbles/scripts/` tree. Literal non-target script dependencies are
deterministic pass-through fixture commands; the two target selftests are
controlled children with independent behavior and execution markers.

The staged file under test is the real production entrypoint. The regression
must not copy or recreate `run_check`, `bubbles_run_with_timeout`, provider
selection, failed-label collection, or final aggregation.

The regression invokes the staged entrypoint from a sanitized environment and
constructs an owned system-tool fixture PATH containing only required commands.
Before execution it asserts that `timeout` and `gtimeout` are both unresolved
from that effective PATH. This forces the canonical helper watchdog on Linux
and macOS and prevents a developer-installed GNU utility from satisfying the
scenario accidentally. `BUBBLES_FRAMEWORK_VALIDATE_MODE=downstream` may omit
unrelated source-only registrations, but it must not suppress either affected
`run_check` registration.

Controlled cases must prove:

1. both target children succeed and both existing PASS labels appear;
2. the first target exceeds its independently supplied short deadline, direct
   helper control returns `124`, its failed label appears exactly once, the
   second target and a later sentinel execute, and validator exit is `1`;
3. the second target exits an ordinary non-timeout status such as `3`, direct
   helper control preserves `3`, its failed label appears exactly once, the
   later sentinel executes, and validator exit is `1`;
4. each existing environment key independently changes only its matching
   deadline while both static `120` defaults remain present; and
5. missing or unreadable staged `guard-lib.sh` fails at startup before target
   execution, with no raw-command or unbounded compatibility path.

The regression also exercises capability-based provider selection without
editing `guard-lib.sh`: `timeout` wins when available, `gtimeout` is used when
it alone is available, and neither provider selects the watchdog. Controlled
external-command fixtures may record provider selection and argv; the required
watchdog expiration proof still executes the real canonical watchdog path.

### Adversarial Reintroduction Matrix

Ephemeral mutations apply only to staged fixture bytes. Named assertions must
reject each independent mutation:

1. restore raw `timeout` at the macOS portability guard registration;
2. restore raw `timeout` at the workflow planning provenance registration;
3. invoke the first target child directly and drop supervision;
4. invoke the second target child directly and drop supervision; and
5. consume, coerce, or remap helper exit `124` before `run_check` records the
   failed check.

A static search for the helper name or a copied-helper unit test cannot satisfy
these cases. Each mutation must be rejected through the production registration
contract it breaks.

### Implementation Plan

1. `bubbles.test` creates the complete source-only regression, verifies its
   scenario IDs and named proof markers, audits it for bailout/self-validation,
   and captures the mandatory final-byte RED.
2. `bubbles.implement` sources `"$SCRIPT_DIR/guard-lib.sh"` once after
   `SCRIPT_DIR` resolves. Missing helper bytes fail startup under the existing
   strict shell mode; no compatibility branch is added.
3. `bubbles.implement` changes only the command prefix at the two designed
   registrations from raw `timeout` to `bubbles_run_with_timeout`. Labels,
   environment keys, `120` defaults, child argv, ordering, tier membership,
   output, and `run_check` aggregation remain unchanged.
4. `bubbles.implement` registers
   `tests/regression/test_28_framework_validate_portable_timeout.sh` through
   the existing `run_check_self_only` regression block. The persistent
   regression remains excluded from downstream installation.
5. `bubbles.test` runs the unchanged test bytes and command for GREEN, then
   completes the Test Plan in row order and records each result separately.
6. `bubbles.test` updates only BUG-021 assertions in
   `install-provenance-selftest.sh`, preserving all concurrent foreign bytes.
7. `bubbles.releases` regenerates `bubbles/release-manifest.json` with canonical
   tooling only after source, test, and provenance changes settle.
8. `bubbles.validate` checks the full completion chain and is the only owner
   that may write certification state.

The production source boundary is exactly two call-site replacements plus one
managed sibling-helper source and one source-only regression registration in
`framework-validate.sh`. `bubbles.implement` owns those source edits only after
the final-byte RED; `bubbles.test` owns the regression bytes and provenance
assertions; `bubbles.releases` alone owns generated release identity. No owner
may fold concurrent `portable-ok` or other foreign worktree changes into
BUG-021.

### Exact Helper and Aggregation Semantics

| Controlled child outcome | Required helper result | Required `run_check` behavior | Required validator result |
| --- | --- | --- | --- |
| exits `0` before deadline | `0` | existing PASS label; no failed-label entry | unchanged; `0` when all checks pass |
| exits ordinary nonzero `N` before deadline | the same `N` | existing FAIL label once; continue later checks | aggregate `1` |
| exceeds configured deadline | `124` | existing FAIL label once; continue later checks | aggregate `1` |

The helper boundary must keep ordinary failure distinct from timeout. The
validator boundary must keep aggregate failure distinct from helper `124`.
Neither a timed-out child nor an ordinary failure may terminate validation
before the later sentinel.

### `portable-ok` Classification

Any pre-existing or concurrently introduced `portable-ok` pragma associated
with a raw timeout line is foreign worktree content. Planning does not remove,
rewrite, or endorse that content. A green portability scan caused by a pragma
is lint suppression only: it cannot prove that stock macOS can execute either
deadline-bearing check and cannot close SCN-BUG-021-001, SCN-BUG-021-002, any
Test Plan row, or any DoD item. Runtime production-path evidence from the
no-timeout fixture remains mandatory even if a scanner invocation is green.

After the owning implementation removes the two raw calls, direct and exact
portability scans must pass on executable source behavior without relying on a
BUG-021 pragma exception.

### Shared Infrastructure Impact Sweep

`framework-validate.sh` is a high-fan-out validation harness. The protected
contracts that must remain unchanged are:

- source `bubbles/scripts/cli.sh framework-validate` dispatch;
- installed `.github/bubbles/scripts/framework-validate.sh` sibling resolution;
- current check labels, ordering, tier behavior, PASS/FAIL output, failure
  count, failed-label list, continuation, and aggregate exit vocabulary;
- both timeout environment keys and `120` defaults;
- the existing `gsed`/`gtimeout` compatibility PATH shim for unrelated checks;
- canonical `guard-lib.sh` provider order and status normalization;
- source-only regression registration and downstream install exclusion; and
- install provenance and generated release source identity.

Independent canaries are the staged production-path
`tests/regression/test_28_framework_validate_portable_timeout.sh`, the existing
macOS portability guard selftest, and the existing canonical helper performance
selftest. Broad framework validation runs only after those canaries pass.

Rollback is release-atomic: revert only BUG-021 canonical source, regression,
and provenance changes; have `bubbles.releases` regenerate release identity;
then validate the selected prior release through supported install/upgrade
flow. Never patch installed downstream bytes or restore one raw call in
isolation.

### Consumer Impact Sweep and Provenance

No route, path, identifier, API, or UI target is renamed or removed. Consumers
still require explicit validation because the entrypoint is install-managed:

- navigation, breadcrumbs, redirects, API clients, generated clients, deep
   links, and browser consumers are inapplicable because this repair exposes no
   route, API, or UI contract;
- stale-reference searches cover both deadline registrations, the source-only
   regression registration, install/source-only inventories, and generated
   release identity; and
- no compatibility shim or downstream patch may retain either raw call.

- canonical source invocation must preserve its command and aggregate result;
- downstream installed entrypoint and sibling helper must remain canonical and
  byte-identical under the supported installer/upgrade path;
- `tests/regression/test_28_framework_validate_portable_timeout.sh` must remain
   source-only while being registered and release-recorded;
- install-provenance assertions must classify the entrypoint, helper, and test
  correctly; and
- generated release identity must be produced by `bubbles.releases`, never by
  a planning, test, or implementation hand edit.

### Change Boundary

#### Allowed File Families And Authorized Delivery Surfaces by Owner

- `bubbles.test`:
  `tests/regression/test_28_framework_validate_portable_timeout.sh`, BUG-021
  assertions in `bubbles/scripts/install-provenance-selftest.sh`, and test-owned
  evidence sections in this packet's `report.md`.
- `bubbles.implement`:
  one fail-loud sibling-helper load, two command-prefix replacements, and one
  source-only regression registration in
  `bubbles/scripts/framework-validate.sh`, plus implementation-owned evidence.
- `bubbles.releases`:
  generator-produced `bubbles/release-manifest.json` changes after all input
  bytes settle.
- `bubbles.validate`:
  `state.json` certification and terminal transition fields only after every
  delivery obligation is evidence-backed.

#### Excluded Surfaces

- `bubbles/scripts/guard-lib.sh` and its timeout/watchdog algorithm;
- `bubbles/scripts/macos-portability-guard.sh` and
  `macos-portability-guard-selftest.sh` behavior;
- existing target-selftest behavior, labels, ordering, tier membership,
  summaries, public exit vocabulary, and unrelated PATH-shim consumers;
- BUG-012, BUG-013, BUG-018, BUG-019, BUG-020, IMP-020, and `test_26`;
- downstream installed `.github/bubbles/**` bytes;
- release-train config, deployment manifests, monitoring, backups, secrets,
  shared baselines, and unrelated documentation;
- manual edits to generated release metadata; and
- all `certification.*` writes by planning, test, implementation, or release
  owners.

Concurrent foreign bytes already present in shared files must be preserved.
Each owner audits a path-scoped diff and must not normalize, revert, or absorb
unrelated work.

### Test Plan

| Test Type | Test ID | Scenario ID | Category | File / Location | Expected test title or proof marker | Exact behavior | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Mandatory final-byte RED | T-BUG-021-00 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `tests/regression/test_28_framework_validate_portable_timeout.sh` | `RED: unchanged production rejects both raw deadline registrations` | Complete final test bytes fail before production edits for the intended two raw-call defects; the test digest and production-source baseline are recorded, with no inverted mode or unrelated fixture failure. | `for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh` | Yes |
| Regression E2E - no optional timeout | T-BUG-021-01 | SCN-BUG-021-001 | e2e-api | `tests/regression/test_28_framework_validate_portable_timeout.sh` | `SCN-BUG-021-001: system-only PATH runs both deadline-bearing checks via watchdog` | The staged real production entrypoint reaches both controlled children and labels using an internally owned tool PATH that proves both `timeout` and `gtimeout` absent; no command-not-found text or raw-timeout runtime failure occurs. | `/usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh` | Yes |
| Regression E2E - exact outcomes | T-BUG-021-02 | SCN-BUG-021-002 | e2e-api | `tests/regression/test_28_framework_validate_portable_timeout.sh` | `SCN-BUG-021-002: helper outcomes remain distinct through run_check aggregation` | Direct helper controls produce `0`, ordinary `3`, and watchdog `124`; production `run_check` emits one matching failed label, continues to the other target and later sentinel, and returns aggregate `1` for ordinary failure and timeout. | `/usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh` | Yes |
| Helper load and deadline configuration | T-BUG-021-03 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `tests/regression/test_28_framework_validate_portable_timeout.sh` | `Contract: helper load fails loud and both deadline overrides remain independent` | A missing helper fails before checks; each existing environment key affects only its matching target; both names and `120` defaults remain exact; no disable or unbounded branch exists. | `bash tests/regression/test_28_framework_validate_portable_timeout.sh` | No |
| Adversarial raw-call and bypass mutations | T-BUG-021-04 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `tests/regression/test_28_framework_validate_portable_timeout.sh` | `Adversarial: each raw call, direct child, and 124 remap is rejected independently` | Separately named staged mutants restore raw timeout at the macOS portability registration and at the planning-provenance registration; additional mutants invoke either child directly or suppress/remap helper `124`. Every mutant must fail its own assertion. | `bash tests/regression/test_28_framework_validate_portable_timeout.sh` | No |
| Provider-selection compatibility | T-BUG-021-05 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `tests/regression/test_28_framework_validate_portable_timeout.sh` | `Compatibility: timeout then gtimeout then watchdog provider order is unchanged` | Canonical helper selects `timeout` first, `gtimeout` when it alone is available, and the real watchdog when neither exists; provider argv and child status propagate without a helper edit. | `bash tests/regression/test_28_framework_validate_portable_timeout.sh` | No |
| Canonical helper semantic canary | T-BUG-021-06 | SCN-BUG-021-002 | integration | `bubbles/scripts/state-transition-guard-perf-selftest.sh` | `Canary: canonical helper preserves ordinary status and timeout 124` | Existing canonical helper control preserves ordinary child status `3` and normalizes expiration to `124`, independently of the new registration test. | `bash bubbles/scripts/state-transition-guard-perf-selftest.sh` | Yes |
| Portability guard canary | T-BUG-021-07 | SCN-BUG-021-001 | functional | `bubbles/scripts/macos-portability-guard-selftest.sh` | `raw timeout is RED and helper-mediated timeout is GREEN` | Existing scanner selftest still rejects raw timeout and accepts the canonical helper form; scanner behavior is not weakened. | `bash bubbles/scripts/macos-portability-guard-selftest.sh` | No |
| Direct production portability scan | T-BUG-021-08 | SCN-BUG-021-001 | functional | `bubbles/scripts/framework-validate.sh` | `framework-validate has zero raw-timeout findings without BUG-021 suppression` | Direct scan of the repaired production entrypoint reports no raw-timeout finding from either target registration and does not rely on a BUG-021 pragma. | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/framework-validate.sh` | No |
| BUG-019 exact portability surface | T-BUG-021-09 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `bubbles/scripts/macos-portability-guard.sh` | `TEST-019-004-PORTABILITY exact surface has zero findings` | The exact five-path command used by BUG-019 reports zero findings after the runtime repair; BUG-019 artifacts remain untouched. | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | No |
| Regression quality | T-BUG-021-10 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `bubbles/scripts/regression-quality-guard.sh` | `test_28_framework_validate_portable_timeout.sh has adversarial signal and no bailout` | The persistent bug regression contains behavior-producing assertions, no silent-pass bailout, no inverted broken-mode switch, and independent adversarial cases. | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_28_framework_validate_portable_timeout.sh` | No |
| Bash 3.2 syntax | T-BUG-021-11 | SCN-BUG-021-001, SCN-BUG-021-002 | functional | `bubbles/scripts/framework-validate.sh tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/install-provenance-selftest.sh` | `all changed BUG-021 shell parses with macOS system Bash` | Production entrypoint, source-only regression, and install-provenance assertions parse under `/bin/bash` without Bash 4-only syntax. | `/bin/bash -n bubbles/scripts/framework-validate.sh tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/install-provenance-selftest.sh` | No |
| Install provenance integration | T-BUG-021-12 | SCN-BUG-021-001, SCN-BUG-021-002 | integration | `bubbles/scripts/install-provenance-selftest.sh` | `managed entrypoint and helper install together while test_28_framework_validate_portable_timeout.sh remains source-only` | Canonical entrypoint/helper install identity is coherent, the supported downstream layout resolves the sibling helper, `tests/regression/test_28_framework_validate_portable_timeout.sh` is registered exactly once with `run_check_self_only`, remains absent from downstream `.manifest` and `.checksums`, and is release-recorded under `sourceOnlyFileChecksums`. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| Full framework integration | T-BUG-021-13 | SCN-BUG-021-001, SCN-BUG-021-002 | integration | `bubbles/scripts/cli.sh` | `framework-validate passes with both portable deadlines active` | Canonical source validation runs every registered check, including `tests/regression/test_28_framework_validate_portable_timeout.sh`, with unchanged labels, aggregation, and no collateral failure. | `bash bubbles/scripts/cli.sh framework-validate` | Yes |
| Release identity integration | T-BUG-021-14 | SCN-BUG-021-001, SCN-BUG-021-002 | integration | `bubbles/scripts/cli.sh` | `release-check accepts regenerated source, test, and provenance identity` | After release-owner regeneration, canonical source checksums, source-only inventory, install provenance, and release readiness agree without hand-edited metadata. | `bash bubbles/scripts/cli.sh release-check` | Yes |

No browser, UI, API server, database, network service, telemetry adapter, mutable
store, throughput target, or latency SLO is implicated. `e2e-ui`, UI-unit,
accessibility, stress, and load categories are inapplicable. The mandatory
scenario-specific E2E category is represented by the real framework-validation
process and production shell entrypoint, with no internal function copies or
request interception. The project config defines neither `testImpact` nor
`traceContracts`, so no impact-map or observability row applies.

### Test Environment Isolation

The regression owns one unique temporary root, one source-shaped staged tree,
and one sanitized fixture PATH. Cleanup runs on normal exit and signals. Tests
must not mutate downstream repositories, monitoring, backup destinations,
release-train config, deployment manifests, shared baselines, secrets, or
network services. Adversarial source mutations are confined to staged bytes.

### Planning and Packet Validation

These checks validate planning coherence; they do not satisfy delivery Test
Plan rows or justify checking a delivery item:

- artifact lint for the BUG-021 packet;
- artifact freshness against current `spec.md` and `design.md`;
- G094 Single-Capability Justification validation;
- traceability validation;
- strict `scopes.md` / `test-plan.json` / `scenario-manifest.json` / DoD parity;
- unresolved-template-token and active-prose scans; and
- BUG-021-scoped diff and whitespace validation.

### Definition of Done - Tiered Validation

Core behavior:

- [ ] `SCN-BUG-021-001 - Framework validation runs both deadline-bearing checks without GNU timeout`: both target checks execute through the portable watchdog path when neither `timeout` nor `gtimeout` exists, with no command-not-found or raw-timeout portability finding.
- [ ] `SCN-BUG-021-002 - Portable timeout outcomes remain observable and exact`: helper success `0`, ordinary child failure `3`, and timeout `124` remain distinct; `run_check` records one matching failure, continues, and preserves aggregate validator exit `1`.
- [ ] The source-only regression exists as final bytes and its recorded digest
   is identical between the valid RED and GREEN executions.
- [ ] The valid RED was captured before any production, provenance, or release
   edit and failed only on the intended two raw production registrations.
- [ ] Exactly two existing deadline call sites use the canonical helper, the
   managed sibling helper loads fail-loud, and no second timeout abstraction or
   bypass exists.
- [ ] Existing labels, child argv, check ordering, tier behavior, environment
   keys, `120` defaults, PATH shim, output, failed-label collection,
   continuation, and aggregate exit behavior remain unchanged.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior pass through the real staged framework-validation entrypoint.
- [ ] Broader E2E regression suite passes through canonical full framework validation after focused canaries are green.
- [ ] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns.
- [ ] Rollback or restore path for shared infrastructure changes is documented and verified through release-atomic source, provenance, and generated-identity restoration.
- [ ] The Consumer Impact Sweep is complete and zero stale first-party references remain across registrations, install/source-only inventories, and release identity.
- [ ] Change Boundary is respected and zero excluded file families were changed.
- [ ] Canonical source, installed sibling helper resolution, source-only test
   classification, and release identity agree through owner-controlled paths.
- [ ] A `portable-ok` pragma is not used as runtime portability evidence or as
   closure for either scenario.
- [ ] `bubbles.validate` alone writes certification or terminal state after all
   delivery and evidence obligations are complete.

Test evidence, one item per Test Plan row:

- [x] **T-BUG-021-00:** mandatory final-byte RED passes its validity audit and
   is recorded before production edits. Evidence destination:
   [Final-Byte RED Regression](report.md#final-byte-red-regression).
- [ ] **T-BUG-021-01:** system-only no-timeout production-path E2E passes for
   SCN-BUG-021-001. Evidence destination:
   [Portable Timeout Production Regression](report.md#portable-timeout-production-regression).
- [ ] **T-BUG-021-02:** exact helper/result aggregation E2E passes for
   SCN-BUG-021-002. Evidence destination:
   [Portable Timeout Production Regression](report.md#portable-timeout-production-regression).
- [ ] **T-BUG-021-03:** fail-loud helper loading, independent deadline
   forwarding, and both `120` defaults pass. Evidence destination:
   [Helper Load And Deadline Configuration](report.md#helper-load-and-deadline-configuration).
- [ ] **T-BUG-021-04:** every raw-call, direct-child, and `124`-remap mutation
   is rejected independently. Evidence destination:
   [Adversarial Reintroduction](report.md#adversarial-reintroduction).
- [ ] **T-BUG-021-05:** `timeout` / `gtimeout` / watchdog provider order and
   argument propagation remain exact. Evidence destination:
   [Provider And Canary Controls](report.md#provider-and-canary-controls).
- [ ] **T-BUG-021-06:** canonical helper semantic canary preserves ordinary
   status and timeout `124`. Evidence destination:
   [Provider And Canary Controls](report.md#provider-and-canary-controls).
- [ ] **T-BUG-021-07:** portability guard canary rejects raw timeout and accepts
   helper-mediated timeout. Evidence destination:
   [Provider And Canary Controls](report.md#provider-and-canary-controls).
- [ ] **T-BUG-021-08:** direct production portability scan has zero target raw
   calls without relying on a BUG-021 pragma. Evidence destination:
   [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] **T-BUG-021-09:** the exact BUG-019 five-path portability command passes
   while BUG-019 remains untouched. Evidence destination:
   [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] **T-BUG-021-10:** bugfix regression quality guard accepts
   `tests/regression/test_28_framework_validate_portable_timeout.sh` with
   adversarial signal and no silent-pass pattern. Evidence destination:
   [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] **T-BUG-021-11:** all changed BUG-021 shell parses under macOS system
   Bash 3.2. Evidence destination:
   [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] **T-BUG-021-12:** install provenance accepts the managed entrypoint/helper
   pair and source-only regression classification. Evidence destination:
   [Install And Source-Only Provenance](report.md#install-and-source-only-provenance).
- [ ] **T-BUG-021-13:** full canonical framework validation passes with both
   portable registrations active. Evidence destination:
   [Framework Validation](report.md#framework-validation).
- [ ] **T-BUG-021-14:** release-check accepts release-owner-generated identity
   for settled source, test, and provenance bytes. Evidence destination:
   [Release Validation](report.md#release-validation).

Build Quality Gate:

- [ ] RED precedes production edits and GREEN reuses identical regression bytes
   and command; focused canaries precede broad framework and release checks.
- [ ] Every evidence block records phase, exact command, actual exit, claim
   source, and raw current-session output with one-to-one finding accounting.
- [ ] Source-only registration, install provenance, generated release identity,
   Bash 3.2/macOS portability, and supported downstream upgrade agree on one
   settled canonical source set.
- [ ] `bubbles.validate` remains the only writer of certification fields,
   completed scope state, and terminal status.

### Uncertainty Declaration for Every Unchecked Delivery Item

**What was attempted:** Planning reconciled the authoritative scenarios,
production-path test architecture, owner order, Test Plan, DoD, and change
boundary. No delivery command was treated as implementation evidence.

**What was observed:** The design requires a physical source-only regression
and a final-byte RED before the two production call sites may change. Planning
has not established either delivery fact.

**Why this is uncertain:** The physical regression, RED output, source repair,
GREEN matrix, provenance reconciliation, release regeneration, and
certification require their declared owners and execution evidence.

**What would resolve this:** `bubbles.test` must first author the complete
`tests/regression/test_28_framework_validate_portable_timeout.sh` bytes and
capture the valid RED against unchanged production source. The remaining
owners then execute the ordered checkpoints without widening the change
boundary.

### Execution Handoff

Immediate next owner: `bubbles.test` for **T-BUG-021-00**, the mandatory
final-byte RED. Production implementation is prohibited until that evidence is
captured. If the RED fixture fails for construction or unrelated reasons, the
test owner repairs the test architecture and reruns RED against still-unchanged
production bytes; it does not route around the gate.
