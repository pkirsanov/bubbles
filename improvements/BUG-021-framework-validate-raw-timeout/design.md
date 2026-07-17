# Bug Fix Design: BUG-021 Framework Validate Raw Timeout

## Design Brief

### Current State

`bubbles/scripts/framework-validate.sh` registers two bounded checks by passing
raw `timeout` to `run_check`: the macOS portability guard selftest and the
workflow planning provenance selftest. Both use an environment-controlled
seconds value with an existing `120`-second default.

The entrypoint can expose an installed `gtimeout` as `timeout` through its PATH
compatibility directory, but base macOS has neither executable. The framework
already ships the complete portable contract as `bubbles_run_with_timeout` in
the colocated, install-managed `bubbles/scripts/guard-lib.sh`.

### Target State

`framework-validate.sh` sources that canonical helper and passes it to
`run_check` at exactly the two affected registrations. The labels, environment
keys, `120`-second defaults, child commands, output, tier behavior, aggregate
failure accounting, and final framework-validation exit contract stay intact.

Linux may resolve GNU `timeout`, a host with only coreutils-prefixed tools may
resolve `gtimeout`, and a host with neither uses the existing Bash watchdog.
The helper returns `124` on expiration in every lane; `run_check` records that
nonzero as one failed check, continues validation, and emits the existing final
exit `1` when any check failed.

### Patterns to Follow

- Source a sibling managed helper through the already-resolved `SCRIPT_DIR`, as
   `state-transition-guard.sh` and its selftests do.
- Use `bubbles_run_with_timeout <seconds> <command...>` exactly as documented in
   `guard-lib.sh` and `skills/bubbles-cross-platform-shell/SKILL.md`.
- Preserve `run_check` as the sole owner of PASS/FAIL labels, the failure count,
   failed-label collection, tier skipping, and the final validator result.
- Follow the source-only regression pattern used by `test_23` through `test_26`:
   register with `run_check_self_only`, assert install exclusion in
   `install-provenance-selftest.sh`, and let the release generator record it.
- Preserve foreign worktree bytes already present in the shared production,
   install-provenance, and generated-release files.

### Patterns to Avoid

- Do not add `portable-ok`, weaken `macos-portability-guard.sh`, or retain raw
   `timeout` behind a comment or shell indirection.
- Do not remove either deadline, call either selftest directly, or treat a
   timeout as a skip or success.
- Do not add a second local watchdog, provider selector, wrapper API, or
   `uname` branch; `guard-lib.sh` already owns those decisions.
- Do not remove the existing PATH shim. Other legacy selftests still consume
   GNU-form tools internally, and that compatibility surface is not this bug.
- Do not hand-edit downstream installed bytes or generator-owned release data.

### Resolved Decisions

- Load `guard-lib.sh` once from `SCRIPT_DIR`; a missing helper is a startup
   failure, never a raw-command or unbounded fallback.
- Replace only the two command prefixes with `bubbles_run_with_timeout`.
- Preserve both existing environment variable names and their `120` defaults.
- Keep helper exit `124` distinct internally while preserving `run_check`'s
   aggregate top-level exit `1` contract.
- Prove the repair with final regression bytes that fail before the source edit,
   then pass unchanged afterward, including per-call-site adversarial mutations.
- Keep the persistent regression source-only and the repaired entrypoint plus
   helper install-managed.

### Open Questions

None. `bubbles.plan` must translate this closed design into synchronized scope,
Test Plan, DoD, and machine-readable planning contracts before test or source
owners act.

## Purpose and Scope

This repair makes the two existing framework-validation deadlines portable
without changing what is validated or how validation results are reported. It
addresses `BR-021-001` through `BR-021-008` in [spec.md](spec.md) and no broader
timeout modernization.

The user-observable contract is the canonical framework validator: both named
selftests remain bounded and execute on Linux and macOS; a deadline is a failed
check rather than a hang, skip, command-not-found accident, or successful
validation.

## Root Cause and Controlling Path

### Current Control Flow

The relevant production path is:

```text
framework-validate.sh startup
   -> resolve SCRIPT_DIR and REPO_ROOT
   -> optionally create gsed/gtimeout PATH aliases
   -> define run_check and run_check_self_only
   -> resolve each existing deadline variable
   -> run_check <label> timeout <seconds> bash <selftest>
   -> record PASS or one aggregate failure
   -> continue all remaining checks
   -> exit 1 when failures > 0, otherwise exit 0
```

The two deadline bindings are:

| Check label | Configuration key | Existing default | Child command |
| --- | --- | --- | --- |
| `macOS portability guard selftest (bubbles-cross-platform-shell)` | `BUBBLES_MACOS_PORTABILITY_GUARD_SELFTEST_TIMEOUT_SECONDS` | `120` | `bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"` |
| `Workflow planning provenance selftest` | `BUBBLES_WORKFLOW_PLANNING_PROVENANCE_SELFTEST_TIMEOUT_SECONDS` | `120` | `bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"` |

`run_check` executes the command vector in an `if "$@"` condition. It does not
rewrite the child command, capture its output, or terminate on one failure. Any
nonzero command status increments `failures` once, appends the label once, and
allows the next registration to run. At the end, one or more failed checks
produce the existing validator exit `1`.

### Root Cause

The registrations depend on a binary name while the framework portability
contract is a shell function. The PATH shim only closes the `gtimeout` naming
gap when optional coreutils is installed. It cannot synthesize a watchdog on a
base macOS path, and raw syntax remains a class-1 portability violation.

`guard-lib.sh` already closes both gaps. Its helper resolves `timeout`, then
`gtimeout`, then a Bash watchdog; propagates ordinary child status; and
normalizes watchdog SIGTERM status `143` to `124`. Reimplementing any part of
that policy in `framework-validate.sh` would create a second authority.

### Falsifiable Design Hypothesis

If `framework-validate.sh` sources the colocated helper and changes only the
two command prefixes, then a no-coreutils production-path fixture will execute
both child scripts, exact portability scanning will find no raw call, and a
timed-out child will reach `run_check` as nonzero without changing aggregate
result accounting.

This design is wrong if the production fixture still needs an optional timeout
binary, either environment override is not forwarded unchanged, an expiration
does not produce helper status `124`, validation stops before a later sentinel
check, or the final validator returns `124` instead of its established aggregate
failure status `1`.

## Selected Architecture

### Helper Loading Contract

After `SCRIPT_DIR` is resolved, `framework-validate.sh` sources
`$SCRIPT_DIR/guard-lib.sh` once. The existing idempotence guard in that file
prevents duplicate initialization. The helper is resolved relative to the
entrypoint, not the caller's working directory or an environment path.

There is no missing-helper compatibility branch. Under `set -euo pipefail`, a
missing or unreadable managed helper aborts validation nonzero before any check
runs. This is deliberate fail-loud behavior: an incomplete install must not
silently lose deadline protection.

Sourcing the helper does not install traps, mutate PATH, or execute a timeout.
The existing compatibility-directory cleanup trap therefore remains the sole
startup trap, and helper command resolution occurs later against the effective
PATH at each invocation.

### Exact Call-Site Transformation

The variable assignments and child commands remain byte-for-byte equivalent in
meaning. Only each command vector passed to `run_check` changes:

```text
run_check <label> timeout "$seconds" bash <selftest>
```

becomes:

```text
run_check <label> bubbles_run_with_timeout "$seconds" bash <selftest>
```

No subshell, command string, `eval`, background wrapper, redirection, or status
adapter is added. The seconds value is passed as one argument to the helper,
and the existing `bash <selftest>` vector follows unchanged.

### Deadline and Exit Semantics

| Child outcome | Helper result | `run_check` behavior | Final validator result |
| --- | --- | --- | --- |
| exits `0` before deadline | `0` | print existing PASS; no failure added | unchanged, normally `0` if all checks pass |
| exits ordinary nonzero `N` before deadline | `N` | print existing FAIL; add label once; continue | existing aggregate `1` |
| exceeds configured deadline | `124` | print existing FAIL; add label once; continue | existing aggregate `1` |

This separation is intentional. Exit `124` is the portable supervision
contract between `bubbles_run_with_timeout` and `run_check`; exit `1` is the
public aggregate result of `framework-validate.sh`. The fix must not make one
timed-out registration terminate the script under `set -e`, leak `124` as the
top-level result, or suppress the failed label.

The helper inherits stdout and stderr, so child diagnostics remain visible.
Both current environment overrides and `120` defaults remain exactly where they
are. No zero/blank value is introduced as a deadline-disable convention, and
no bypass flag or skip environment variable is added.

### Linux and macOS Resolution

- Linux/WSL with GNU coreutils: the helper selects `timeout` and appends the
   existing seconds unit expected by its contract.
- A host exposing only `gtimeout`: the helper selects `gtimeout`; if the
   existing startup shim has already aliased it to `timeout`, the first branch
   is behaviorally equivalent.
- macOS or a hermetic path with neither executable: the helper starts the child
   and watchdog, terminates an overdue child, and normalizes `143` to `124`.

No operating-system name is consulted. Provider selection remains capability
based and wholly owned by `guard-lib.sh`.

### Single-Implementation Justification

This is a narrow repair to two consumers of an existing timeout foundation. It
adds no provider, adapter, screen, service, or shared contract. A new framework
validation timeout abstraction would duplicate `guard-lib.sh` and increase the
change surface without removing complexity.

## Data, API, UI, and Configuration Impact

No persisted data, schema, migration, HTTP/API contract, UI, authorization
rule, feature flag, or release-train bundle changes. The only configuration
surface is the two pre-existing timeout environment variables; their names,
interpretation as seconds, and defaults remain unchanged.

No new dependency is introduced. Bash, existing system utilities, and the
already-managed helper are sufficient.

## Security, Integrity, and No-Bypass Contract

- Selftest command vectors remain arrays of arguments; no string evaluation or
   shell interpolation layer is added.
- Missing helper bytes fail before validation rather than running unbounded.
- A deadline expiration remains a failed check and cannot be reclassified as a
   skip, warning, or success.
- `portable-ok`, scanner exclusions, `--skip`, `--force`, `--no-timeout`, and
   environment-based disable switches are forbidden.
- The regression uses only owned temporary fixtures and does not write to
   downstream repositories, release-train config, monitoring, backups,
   deployment manifests, secrets, or shared baselines.

## Failing-First Regression Architecture

### Persistent Surface

`tests/regression/test_28_framework_validate_portable_timeout.sh` is the
source-only production-path regression. It resolves the canonical
`framework-validate.sh`, `guard-lib.sh`, portability scanner, and required
shell tools at startup; a missing required source exits nonzero rather than
skipping.

The regression creates one unique temporary root and removes it on `EXIT`,
`INT`, and `TERM`. It stages the current canonical `framework-validate.sh` and
`guard-lib.sh` bytes under a source-shaped `bubbles/scripts/` tree. Other
literal script dependencies are represented by deterministic pass-through
fixture executables, while the two target selftests are controlled children.
The staged entrypoint is the production script under test; the test does not
copy or recreate `run_check`, helper selection, deadline forwarding, or result
accounting.

`BUBBLES_FRAMEWORK_VALIDATE_MODE=downstream` suppresses unrelated source-only
work without adding a production bypass: both affected registrations use
`run_check`, not `run_check_self_only`, and therefore still execute. A fixture
PATH contains only explicitly required commands and omits both `timeout` and
`gtimeout`, forcing the real helper's watchdog path on Linux and macOS alike.

### Valid RED Before Source Repair

The final regression bytes are executed before any production edit with their
post-repair expectations unchanged. The run is a valid RED only when:

- the exact portability scan reports both class-1 raw-timeout call sites;
- the staged production entrypoint reaches both named registrations;
- both controlled child execution markers are absent because raw `timeout`
   cannot be resolved in the fixture PATH; and
- the assertions fail on the helper-call and executed-child expectations, not
   on fixture construction, a missing canonical source, or an unrelated check.

There is no `--expect-broken`, inverted assertion mode, bailout return, or
pre-fix alternate fixture. Those identical bytes and commands are retained for
GREEN.

### GREEN and Result-Accounting Matrix

After the two-call repair, the same fixture runs these cases:

1. **Both children succeed:** both execution markers and existing PASS labels
    appear; no command-not-found text or target failure appears.
2. **First child times out:** its deadline override is set to a short positive
    value, the helper-level control observes `124`, `run_check` records exactly
    that label once, the second target and a later sentinel check still execute,
    and the validator exits aggregate `1`.
3. **Second child exits an ordinary nonzero:** direct helper control preserves
    that status, `run_check` records exactly the second label once, later checks
    execute, and the validator exits aggregate `1`.
4. **Deadline forwarding:** each existing environment key is varied
    independently; only its matching child is bounded by that supplied seconds
    value. Static source assertions retain both `120` defaults.

The helper-level success, ordinary-failure, and watchdog-`124` controls are
necessary but not sufficient alone. Completion requires the staged production
entrypoint assertions above, which exercise real registration, argument order,
`run_check`, continuation, failed-label collection, and final summary behavior.

### Adversarial Reintroduction Cases

The regression creates temporary mutations of the staged production file, not
the canonical worktree, and requires its contract checker to reject each:

- restore raw `timeout` at the first registration;
- restore raw `timeout` at the second registration;
- call either child directly and thereby drop timeout supervision; and
- consume or remap helper `124` before `run_check` can account for failure.

Each mutation must fail a named assertion. A test that only scans for the word
`bubbles_run_with_timeout`, only unit-tests a copied helper, or merely observes
top-level exit `1` is tautological and cannot satisfy this design.

### Existing Focused Controls

- `macos-portability-guard-selftest.sh` already proves a helper call is GREEN
   and raw `timeout` is a class-1 RED; its behavior remains unchanged.
- `state-transition-guard-perf-selftest.sh` already proves timeout status `124`
   and ordinary child status `3` at the canonical helper boundary; it remains a
   compatibility control, not a substitute for the new production-path test.
- The exact BUG-019 six-file portability command and a direct scan of
   `framework-validate.sh` must both exit clean after the repair.

## Testing and Validation Strategy

| Scenario | Focused proof | Compatibility proof | Broad proof |
| --- | --- | --- | --- |
| `SCN-BUG-021-001` | no-timeout production fixture executes both controlled children through the helper and exact scans are clean | portability guard selftest plus Bash 3.2 syntax | canonical `framework-validate` in source and supported downstream install modes |
| `SCN-BUG-021-002` | helper `0`/ordinary nonzero/`124` matrix plus production `run_check` continuation, failed-label, and final-exit assertions | existing guard-lib perf selftest | canonical `framework-validate`, install provenance, then `release-check` |

Required validation order after planning is:

1. Author final regression bytes and capture the valid pre-edit RED.
2. Apply only the helper source and two command-prefix replacements.
3. Run the identical regression bytes and command for GREEN.
4. Run the existing portability and helper-semantic selftests.
5. Run direct and BUG-019 exact portability scans plus Bash syntax checks.
6. Run BUG-021 artifact lint, freshness, capability-foundation, and
    traceability checks without transitioning status.
7. Run full canonical framework validation after focused checks are green.
8. Reconcile install provenance and generator-owned release identity, then run
    release validation only after concurrent managed-file edits settle.

Design-phase checks prove artifact coherence only. They are not implementation,
RED/GREEN, release, downstream-upgrade, or certification evidence.

## Consumer and Provenance Impact

| Consumer or surface | Required effect |
| --- | --- |
| `bubbles/scripts/cli.sh framework-validate` | unchanged command and aggregate result contract; it consumes repaired managed bytes |
| source-tree maintainers | both named checks run with current labels and deadlines on Linux/macOS |
| downstream `.github/bubbles/scripts/framework-validate.sh` | installed canonical entrypoint sources the colocated installed helper |
| downstream `.github/bubbles/scripts/guard-lib.sh` | remains install-managed and byte-identical to canonical source; no helper edit |
| `macos-portability-guard.sh` callers | exact changed-file scans no longer report either raw call; scanner behavior is unchanged |
| `tests/regression/test_28_framework_validate_portable_timeout.sh` | tracked and release-recorded as source-only; never copied into downstream installs |
| `install-provenance-selftest.sh` | asserts the entrypoint/helper managed relationship and `test_28` source-only exclusion/checksum classification |
| `bubbles/release-manifest.json` | regenerated from canonical tooling after source/test/provenance bytes settle; framework entrypoint checksum and source-only regression inventory update together |
| BUG-019 | receives no edits; its foreign portability finding is resolved only by consuming the canonical BUG-021 repair evidence |

The relative sibling load path is valid in both source
`bubbles/scripts/` and installed `.github/bubbles/scripts/` layouts. No
downstream patch, copied regression, or project-specific path is permitted.

## Exact Change and Ownership Boundary

### Authorized Future Surfaces

- `bubbles/scripts/framework-validate.sh`: one sibling-helper source plus the
   two raw command-prefix replacements; later, one source-only regression
   registration in the existing regression block;
- `tests/regression/test_28_framework_validate_portable_timeout.sh`: one
   source-only production-path RED/GREEN regression;
- `bubbles/scripts/install-provenance-selftest.sh`: BUG-021 managed/source-only
   classification assertions only;
- `bubbles/release-manifest.json`: generator-owned output only, after canonical
   regeneration by its owning release phase; and
- BUG-021 artifacts, each changed only by its declared owner.

### Explicitly Excluded

- `bubbles/scripts/guard-lib.sh` and its timeout algorithm;
- `bubbles/scripts/macos-portability-guard.sh` and
   `macos-portability-guard-selftest.sh` behavior;
- existing selftest business behavior, framework-validation tier membership,
   install-mode rules, labels, summaries, and public exit vocabulary;
- BUG-012, BUG-013, BUG-018, BUG-019, BUG-020, IMP-020, and `test_26`;
- downstream installed `.github/bubbles/**` files;
- train config, deployment manifests, monitoring, backups, secrets, and
   unrelated documentation; and
- manual edits to generated release metadata or certification fields.

At design time, `framework-validate.sh`, `install-provenance-selftest.sh`, and
`bubbles/release-manifest.json` already contain foreign worktree changes. Future
owners must integrate only the named BUG-021 lines, preserve all foreign bytes,
and audit the exact diff rather than normalize or revert those files.

## Observability and Failure Handling

This is a local framework process with no service, network, datastore,
telemetry adapter, or SLO workflow. Its observable signals are child output,
the existing per-check PASS/FAIL label, failed-label list, failure count, and
process exit.

A timeout is observable at two layers: helper status `124` in the focused
contract test and one normal failed check in framework-validation output. A
missing helper is an immediate startup failure. A missing optional coreutils
binary is not an error because the watchdog is the canonical third provider.

## Rollout and Rollback

Rollout proceeds through final planning, source-only RED, the two-call source
repair, identical-command GREEN, focused controls, full framework validation,
install-provenance reconciliation, canonical release generation, and
`release-check`. Downstream consumers upgrade only through the supported
installer/upgrade flow after canonical release identity is coherent.

Rollback is release-atomic. Revert the BUG-021 canonical source/test/provenance
changes, regenerate release metadata through the canonical generator, validate
that release unit, and have downstream consumers reinstall the selected prior
validated release. Do not restore raw calls only in an installed checkout,
retain a new manifest with old source bytes, or patch BUG-019 as compensation.
If rolled back, BUG-021 remains open because the original macOS defect returns.

## Alternatives and Tradeoffs

| Alternative | Benefit | Rejection reason |
| --- | --- | --- |
| Keep the PATH shim only | no new source line | requires optional coreutils and still fails exact raw-timeout scanning |
| Add `portable-ok` or scanner exemption | smallest textual diff | hides a real unbounded base-macOS path and violates no-bypass policy |
| Remove both deadlines | avoids missing executable | permits hangs and changes user-visible validation behavior |
| Add a local `run_with_timeout` function | self-contained entrypoint | duplicates provider order and `124` semantics already owned by `guard-lib.sh` |
| Wrap all framework checks in timeouts | broader consistency | changes unrelated registrations and exceeds the two-call bug boundary |
| Unit-test `guard-lib.sh` only | cheap | existing tests already do this and cannot detect missing source/registration wiring or result-accounting drift |

## Complexity Tracking

None - simplest viable approach used. The production repair consumes the
existing helper at two call sites; the larger regression matrix is required to
distinguish raw-call, dropped-deadline, wrong-status, and aggregate-accounting
regressions without broadening production code.

## Risks and Open Questions

No blocking design question remains.

Residual risks are bounded and testable:

- the shared production/provenance/release files are concurrently dirty, so a
   later owner could overwrite foreign bytes unless it applies and audits a
   surgical diff;
- a fixture that asserts only final exit `1` could confuse an ordinary failure
   with a correct timeout, so helper-level `124` and production failed-label
   assertions are both mandatory; and
- a test that runs only on a Linux PATH containing GNU `timeout` would not prove
   the watchdog path, so the hermetic no-timeout PATH is mandatory even when
   broad Linux CI is green.
