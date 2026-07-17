# Scopes: BUG-018 Traceability Test Plan Heading Depth

> Planning note: this packet uses one vertical runtime-behavior scope because
> extraction, diagnostics, regression, consumer checks, and release provenance
> form one atomic production-path repair.

Related artifacts: [spec.md](spec.md), [design.md](design.md), [report.md](report.md), [uservalidation.md](uservalidation.md)

## Execution Outline

### Phase Order

1. **Scope 1 - Heading-aware extraction through canonical delivery:** add a
   failing production-path regression, repair exact heading recognition and
   checked caller control flow, preserve consumers, and validate the complete
   release unit before implementation can be considered complete.

### New Types And Signatures

- `extract_test_rows <scope-file>` remains internal and returns a closed status:
  `0` for a recognized exact section, `3` for no recognized exact section, and
  any other nonzero value for an extractor failure.
- Status `0` may produce empty stdout; that state means a recognized section
  with no concrete rows and is distinct from status `3`.
- `extract_scenarios <scope-file>` is captured through a checked assignment;
  grep no-match status `1` reaches the existing no-scenario diagnostic, while
  any other nonzero status is an extraction failure.
- Accepted starts are exact `## Test Plan` and `### Test Plan` headings outside
  fenced code and multiline HTML comments.
- A selected heading at depth `D` ends at the next valid ATX heading whose
  depth is less than or equal to `D`; deeper content remains in the section.
- Public guard exit classes remain `0`, `1`, and `2`; no new CLI option,
  environment variable, config key, dependency, or compatibility switch is
  introduced.
- Stable diagnostics are:
  `<scope> has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan)`,
  `<scope> has no concrete Test Plan rows to trace`, and
  `<scope> Test Plan extraction failed`.

### Validation Checkpoints

1. **RED checkpoint:** the committed regression exists before the source edit
   and fails against the current guard on the level-2 and silent-exit cases.
2. **Focused behavior checkpoint:** level-2, level-3 equivalence, missing,
   rowless, no-scenario, boundary, and Bash 3.2 cases pass through the real
   production guard with no copied extraction helper.
3. **Consumer checkpoint:** managed selftest, BUG-012, BUG-013, and the current
  Research Lab Feature 007 packet preserve their expected traceability path.
  Canonical behavior is proved first with a disposable Research-Lab-shaped
  fixture, then source compatibility is proved from the owning Research Lab
  root by recognizing every linked test, traversing every scope, reaching the
  normal summary, and avoiding any path-resolution, extraction, or silent-exit
  failure. Feature 007 may still return its own nonzero traceability findings;
  their closure is owned by Feature 007 Scope 09 and is not a BUG-018 gate.
4. **Governance checkpoint:** regression integrity, shell syntax, owned-surface
  portability, the exact framework-registration hunk, artifact lint,
  freshness, traceability, and G094 all pass.
5. **Framework checkpoint:** full framework validation passes after focused
   checks and registration are stable.
6. **Release checkpoint:** install-provenance assertions classify the guard and
  selftest as managed, the regression as source-only, release generation
  followed by release-check passes without hand-edited metadata, and the
  installed Research Lab replay runs only after supported upgrade ownership
  has delivered the validated canonical bytes.

### Ordering Rationale

The scope is intentionally vertical. Extraction, caller survival, persistent
regression, executable consumers, and release provenance are one observable
repair: splitting them would permit a locally green parser that is absent from
framework validation or the installed release. Each checkpoint blocks the next.

## Scope Inventory

| # | Scope | Depends On | Primary surfaces | Status |
| --- | --- | --- | --- | --- |
| 1 | Heading-Aware Traceability Extraction And Diagnostics | - | production guard, persistent regression, direct registration/release inputs | In Progress |

## Scope 1: Heading-Aware Traceability Extraction And Diagnostics

**Status:** In Progress
**Depends On:** -
**Scope-Kind:** runtime-behavior

### Outcome

The production traceability guard treats valid level-2 and level-3 Test Plan
headings equivalently, respects heading-aware section boundaries, and reports
missing/empty Test Plans through normal finding accounting instead of an
immediate `set -e` exit.

### Gherkin Scenarios

#### SCN-BUG-018-001: A level-2 Test Plan maps scenarios normally

```gherkin
Scenario: A level-2 Test Plan maps scenarios normally
   Given a valid per-scope packet has scenarios and concrete rows under ## Test Plan
  When the production traceability guard analyzes the packet
   Then it maps every scenario to its Test Plan row
   And it does not report a missing Test Plan
```

#### SCN-BUG-018-002: Existing level-3 Test Plans remain compatible

```gherkin
Scenario: Existing level-3 Test Plans remain compatible
   Given an equivalent valid packet has the same rows under ### Test Plan
  When the production traceability guard analyzes the packet
   Then it produces the same scenario mapping and successful verdict
```

#### SCN-BUG-018-003: Invalid Test Plan input fails with a diagnostic

```gherkin
Scenario Outline: Invalid Test Plan input fails with a diagnostic
   Given a scope has no recognized Test Plan section or no concrete rows
  When the production traceability guard analyzes the packet
  Then it emits a scope-qualified Test Plan diagnostic
  And it reaches the normal nonzero guard summary
  And it does not stop immediately after the scope announcement
```

#### SCN-BUG-018-004: Section boundaries follow heading depth

```gherkin
Scenario: Section boundaries follow heading depth
  Given a level-2 Test Plan contains a nested level-3 subsection
   And a later level-2 section contains unrelated table rows
   When the production traceability guard extracts Test Plan rows
  Then nested Test Plan rows remain eligible
   And rows from the later level-2 section are excluded
```

### UI Scenario Matrix

None found - this bug affects a command-line governance guard. Observable
behavior is the complete diagnostic stream and numeric exit status.

### Implementation Plan

1. Create `tests/regression/test_25_traceability_test_plan_heading_depth.sh`
   first. It must construct structurally complete disposable packets, invoke
   `bubbles/scripts/traceability-guard.sh`, print the exact case titles from
   `T-BUG-018-01` through `T-BUG-018-07`, and contain no extraction helper.
2. Run that persistent test against the unchanged production guard and record
   the nonzero RED output proving level-2 rejection and post-announcement
   termination before any source edit.
3. Gate optional fun-mode loading in `traceability-guard.sh`: source the
   existing implementation only on Bash 4+, and define the three consumed
   no-op hooks on Bash 3.2 without modifying `fun-mode.sh`.
4. Replace the Test Plan start/boundary pipeline with one portable specialized
   extractor that recognizes only exact level-2/level-3 starts, ignores fences
   and comments, retains deeper content, stops at same-or-shallower headings,
   preserves concrete row bytes, and returns the closed status contract.
5. Capture Test Plan and scenario extraction inside checked `if` assignments.
   Emit exactly one scope-qualified finding for missing, rowless, no-scenario,
   or extractor-failure states and continue to the existing final summary.
6. Extend `traceability-guard-selftest.sh` without removing existing clean,
   untraceable, declared-edge, or ambiguous-edge coverage. Add the complete
   heading, boundary, row-state, no-scenario, and Bash 3.2 matrix.
7. Register the source-only regression in `framework-validate.sh` through
   `run_check_self_only`; do not change unrelated registry ordering or checks.
8. Extend `install-provenance-selftest.sh` using its existing assertion helpers
   so the guard and managed selftest remain installer payloads while the new
   regression remains source-only with canonical byte identity.
9. Run focused RED/GREEN, selftest, integrity, shell syntax, owned-surface
   portability, registration-hunk, direct-consumer, packet-governance, and full
   framework checkpoints in the Test Plan order.
10. Regenerate `bubbles/release-manifest.json` only with canonical release
  tooling after all source inputs are stable, run release-check, deliver the
  validated release through supported install/upgrade ownership, and only
  then run the installed Research Lab consumer command.
11. Update only direct bug-index documentation whose claims changed, and keep
    validate-owned certification and terminal status untouched until validation.

### Consumer Impact Sweep

- **Scope layouts:** single-file `scopes.md` units and per-scope-directory
  `scopes/*/scope.md` files both pass through `scope_analysis_files`.
- **Internal symbols:** every definition and caller of `extract_section`,
  `extract_test_rows`, and `extract_scenarios`, including both scenario passes,
  must be inventoried; no second active boundary interpretation may remain.
- **Diagnostics and exits:** `fail`, scope-qualified findings, warning/failure
  counts, final `RESULT: FAILED (...)`, and public exits `0`/`1`/`2` remain the
  only caller-visible contract.
- **Executable framework consumers:** `traceability-guard-selftest.sh`,
  `framework-validate.sh`, `done-spec-audit.sh`, `bubbles.validate`, and direct
  maintainer invocations must retain their production path.
- **Adjacent guard:** `state-transition-guard.sh` owns a separate G068 matcher
  and is searched for stale coupling but must not be edited.
- **Canonical packet canaries:** BUG-012 and BUG-013 exercise existing level-3
  plans directly with the repaired production guard.
- **Current downstream consumer:** canonical behavior is exercised against a
  disposable Research-Lab-shaped packet owned by the regression; Research Lab
  `specs/007-technical-analysis-decision-lab` is then checked from the Research
  Lab repository root with canonical source. This check owns only BUG-018
  source compatibility: owning-root resolution, recognition of all 32 linked
  tests, traversal of all nine scopes, the normal final summary, and absence of
  path-resolution, extractor, or post-announcement silent-exit failures. Its 37
  current traceability findings remain Feature-007-owned delivery findings;
  full Feature 007 traceability is owned by Feature 007 Scope 09 and is not a
  BUG-018 completion prerequisite. The installed `.github/bubbles/**` guard is
  replayed only after supported upgrade ownership has delivered the validated
  release.
- **Release consumers:** managed inventory, source-only regression inventory,
  checksums, release-manifest generation, install provenance, and upgrade bytes
  must agree; the source-only test must never enter downstream managed payloads.
- **Reference sweep:** source, selftests, regression registration, release
  assertions, BUG-012, BUG-013, and Research Lab references are searched for
  stale heading-depth or copied-extractor assumptions before completion.

### Change Boundary

Allowed delivery file families:

- `bubbles/scripts/traceability-guard.sh`;
- `bubbles/scripts/traceability-guard-selftest.sh`;
- `tests/regression/test_25_traceability_test_plan_heading_depth.sh`;
- the direct BUG-018 registration block in
  `bubbles/scripts/framework-validate.sh`;
- direct managed/source-only assertions in
  `bubbles/scripts/install-provenance-selftest.sh`;
- generator-owned `bubbles/release-manifest.json`, produced only after the
  source set is stable; and
- direct BUG-018 index text owned by the documentation phase.

Excluded surfaces that must remain byte-identical:

- `bug.md`, `spec.md`, and `design.md` business/technical content during
  implementation;
- `bubbles/scripts/fun-mode.sh`, `state-transition-guard.sh`,
  `generate-release-manifest.sh`, `trust-metadata.sh`, and `install.sh`;
- all unrelated traceability matchers, quality gates, regressions, and release
  registrations;
- BUG-012, BUG-013, IMP-020, adversarial-resolve, and their evidence packets;
- Research Lab source, tests, planning artifacts, and installed managed files;
- every other downstream repository and every deployment, secret, monitoring,
  backup, release-train, or manifest surface; and
- opportunistic formatting, cleanup, refactoring, or manual metadata edits.

Any required change outside the allowed list stops implementation and returns
the packet to the owning specialist before that file is touched.

### Test Plan

| Test Type | Test ID | Scenario | Category | File / Location | Test title / exact behavior | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| red-regression | T-BUG-018-00 | SCN-BUG-018-001, SCN-BUG-018-003 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | RED: unchanged production guard rejects level-2 input and exits after the scope announcement | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| regression-e2e | T-BUG-018-01 | SCN-BUG-018-001 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: level-2 Test Plan maps every scenario | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| regression-e2e | T-BUG-018-02 | SCN-BUG-018-002 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: level-3 Test Plan preserves the level-2 mapping set | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| adversarial-regression-e2e | T-BUG-018-03 | SCN-BUG-018-003 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: missing exact Test Plan heading reports once and reaches final summary | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| adversarial-regression-e2e | T-BUG-018-04 | SCN-BUG-018-003 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: recognized empty, header-only, and separator-only Test Plans report rowless and reach final summary | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| adversarial-regression-e2e | T-BUG-018-05 | SCN-BUG-018-004 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: heading-depth boundaries retain nested rows and exclude later siblings | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| adversarial-regression-e2e | T-BUG-018-06 | SCN-BUG-018-003 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: expected no-scenario no-match reaches the explicit diagnostic and final summary | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| regression-e2e | T-BUG-018-07 | SCN-BUG-018-001, SCN-BUG-018-003 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Regression: Bash 3.2 starts with optional fun mode disabled | `/usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| managed-selftest | T-BUG-018-08 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | functional | `bubbles/scripts/traceability-guard-selftest.sh` | Managed selftest: exact headings, row states, depth boundaries, no-scenario handling, and existing edge cases pass | `bash bubbles/scripts/traceability-guard-selftest.sh` | false |
| regression-integrity | T-BUG-018-09 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | functional | `bubbles/scripts/regression-quality-guard.sh` | Regression integrity: BUG-018 has adversarial signal, direct assertions, and no bailout | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_25_traceability_test_plan_heading_depth.sh` | false |
| shell-portability | T-BUG-018-10 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | functional | changed BUG-018 shell files | Shell contract: Bash syntax passes for all five changed BUG-018 shell files, and macOS portability passes for the four BUG-018-authored implementation/test surfaces without claiming whole-file framework-validate portability | `/bin/bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh tests/regression/test_25_traceability_test_plan_heading_depth.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh tests/regression/test_25_traceability_test_plan_heading_depth.sh bubbles/scripts/install-provenance-selftest.sh` | false |
| consumer-regression | T-BUG-018-11 | SCN-BUG-018-002, SCN-BUG-018-003 | integration | improvements/BUG-012-g085-first-adoption-deadlock, improvements/BUG-013-g028-sensitive-client-storage-classification | Direct consumers: BUG-012 and BUG-013 preserve level-3 mapping and normal summaries | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock && bash bubbles/scripts/traceability-guard.sh improvements/BUG-013-g028-sensitive-client-storage-classification` | true |
| canonical-downstream-fixture | T-BUG-018-12 | SCN-BUG-018-001, SCN-BUG-018-003 | e2e-api | `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | Canonical production behavior: the real source guard traces a disposable Research-Lab-shaped packet whose linked paths resolve inside its owned fixture | `bash tests/regression/test_25_traceability_test_plan_heading_depth.sh` | true |
| packet-governance | T-BUG-018-13 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | integration | `improvements/BUG-018-traceability-test-plan-heading-depth` | Packet governance: artifact lint, freshness, traceability, and G094 pass | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-018-traceability-test-plan-heading-depth && bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-018-traceability-test-plan-heading-depth && bash bubbles/scripts/traceability-guard.sh improvements/BUG-018-traceability-test-plan-heading-depth && bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-018-traceability-test-plan-heading-depth` | true |
| framework-integration | T-BUG-018-14 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | integration | `bubbles/scripts/cli.sh` | Framework validation: registered BUG-018 regression and all existing checks pass | `bash bubbles/scripts/cli.sh framework-validate` | true |
| install-provenance | T-BUG-018-15 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Install provenance: guard and selftest are managed while BUG-018 regression is source-only | `bash bubbles/scripts/install-provenance-selftest.sh` | true |
| release-integration | T-BUG-018-16 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | integration | `bubbles/scripts/cli.sh` | Release validation: generated metadata is current and canonical install provenance passes | `bash bubbles/scripts/cli.sh release-check` | true |
| downstream-source-consumer | T-BUG-018-17 | SCN-BUG-018-001, SCN-BUG-018-003 | integration | `../research-lab/specs/007-technical-analysis-decision-lab` | Downstream source compatibility: from the owning Research Lab root, the canonical source guard resolves Feature 007, recognizes all 32 manifest-linked tests, traverses all nine scopes, reaches the normal final summary, emits no path-resolution or extractor failure, and does not stop after a scope announcement. Exit `1` is accepted only as the foreign packet's own nonterminal traceability verdict; this row does not assert that its 37 Feature-007-owned findings pass or are resolved. | `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab` | true |
| downstream-installed-replay | T-BUG-018-18 | SCN-BUG-018-001, SCN-BUG-018-003 | integration | `../research-lab/.github/bubbles/scripts/traceability-guard.sh` | Installed downstream replay: after T-BUG-018-16 and supported release/install/upgrade delivery, the installed Research Lab guard traces Feature 007 without any manual managed-file edit | `cd ../research-lab && bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab` | true |
| registration-hunk | T-BUG-018-19 | SCN-BUG-018-001, SCN-BUG-018-002, SCN-BUG-018-003, SCN-BUG-018-004 | functional | `bubbles/scripts/framework-validate.sh` | Registration boundary: the BUG-018 source-only regression is added through one exact direct `run_check_self_only` line, the hunk is whitespace-clean, and no whole-file portability claim is made | `git diff HEAD --check -- bubbles/scripts/framework-validate.sh && registration_hunk="$(git diff HEAD --unified=0 -- bubbles/scripts/framework-validate.sh)" && registration_count="$(grep -Fxc '+run_check_self_only "BUG-018 traceability Test Plan heading-depth regression" bash "$REPO_ROOT/tests/regression/test_25_traceability_test_plan_heading_depth.sh"' <<< "$registration_hunk")" && [[ "$registration_count" -eq 1 ]]` | false |

`Live System: true` means the real production guard or framework runner is
executed as a subprocess against disposable repositories. No browser, network,
database, or external telemetry runtime applies.

The project config defines neither `testImpact` nor `traceContracts`; no impact
map, observability workflow, trace evidence, or SLO evidence row applies.

### Test Environment Isolation

Both test surfaces must create one unique parent with `mktemp -d` beneath
`${TMPDIR:-/tmp}` and install cleanup traps for `EXIT`, `INT`, and `TERM`.
Every feature packet, linked test, scenario manifest, report, log, and mapping
comparison file must remain under that parent. Fixtures must be complete enough
that heading or row state is the only discriminator and must invoke the real
production guard. No copied parser or shared fixed temp path is permitted.

No fixture may write to a downstream repository, installed managed path,
production monitoring plane, backup root, release-train config, deployment
manifest, shared baseline, or network service. The Research Lab rows are
read-only guard invocations; supported install/upgrade tooling owns any managed
byte change outside this scope's tests.

### Definition of Done - Tiered Validation

Core behavior:

- [x] `SCN-BUG-018-001 - A level-2 Test Plan maps scenarios normally`: a valid exact `## Test Plan` maps every scenario to its Test Plan row and does not report a missing Test Plan. Evidence: [GREEN Production-Path Regression](report.md#green-production-path-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `SCN-BUG-018-002 - Existing level-3 Test Plans remain compatible`: an equivalent exact `### Test Plan` produces the same scenario mapping and successful verdict as level 2. Evidence: [GREEN Production-Path Regression](report.md#green-production-path-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `SCN-BUG-018-003 - Invalid Test Plan input fails with a diagnostic`: a missing recognized section or recognized section without concrete rows emits the applicable scope-qualified diagnostic, reaches the normal nonzero summary, and never stops after the scope announcement. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed).
- [x] `SCN-BUG-018-004 - Section boundaries follow heading depth`: nested deeper Test Plan rows remain eligible and rows under the next same-or-shallower sibling heading are excluded. Evidence: [Boundary And Adversarial Regression](report.md#boundary-and-adversarial-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] Exact level-2 and level-3 headings are recognized only outside fences and comments; unsupported text and deeper headings remain unrecognized. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed).
- [x] The specialized extractor preserves concrete row bytes, retains deeper nested content, and stops at the next same-or-shallower ATX heading. Evidence: [GREEN Production-Path Regression](report.md#green-production-path-regression) and [Boundary And Adversarial Regression](report.md#boundary-and-adversarial-regression) (**Phase:** implement; **Claim Source:** interpreted; equal mapping sets and exact one-row boundary summaries preserve the existing row consumer contract).
- [x] Extractor status distinguishes missing exact section, recognized rowless section, and internal failure without disabling `set -e` or `pipefail`. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed; the production-path fault injection reports `Test Plan extraction failed` once and reaches the final summary).
- [x] Both scenario capture passes treat expected no-match as data and reach the scope-qualified no-scenario diagnostic. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed).
- [ ] Existing scenario mapping, linked-test, evidence, edge-confidence, DoD-fidelity, warning, and public exit semantics remain unchanged.
  > **Uncertainty Declaration**
  > **What was attempted:** The four original managed selftest families, direct BUG-012/BUG-013 canaries, and focused BUG-018 matrix all executed.
  > **What was observed:** Those checks pass, and the external source consumer reaches its normal summary after recognizing all 32 linked tests and traversing all nine scopes. Full framework validation did not complete in this invocation.
  > **Why this is uncertain:** The claim spans every existing consumer and aggregate semantic, which focused checks alone cannot prove.
  > **What would resolve this:** Independent test runs one serial canonical framework validation; the corrected `T-BUG-018-17` compatibility assertion is now recorded separately below.
- [x] Optional fun hooks preserve current behavior on Bash 4+ and permit `/bin/bash` 3.2 startup without changing `fun-mode.sh`. Evidence: [Portability And Bash 3.2](report.md#portability-and-bash-32) and [Managed Selftest And Regression Integrity](report.md#managed-selftest-and-regression-integrity) (**Phase:** implement; **Claim Source:** executed).
- [ ] Consumer impact sweep proves every internal caller, executable consumer, packet canary, downstream command, and release consumer is accounted for.
  > **Uncertainty Declaration**
  > **What was attempted:** Internal definitions/callers, the managed selftest, BUG-012/BUG-013, the dedicated canonical Research-Lab-shaped fixture, and the exact own-root Research Lab source command were executed against the current repair.
  > **What was observed:** `T-BUG-018-12` passes 55/55 assertions, and `T-BUG-018-17` resolves Feature 007, recognizes all 32 root-relative linked tests, traverses all nine scopes, and reaches the normal summary with no BUG-018 path-resolution, extractor, or silent-exit signal. Feature 007 reports 37 packet-owned traceability findings, none of which is claimed passed or resolved; installed Research Lab bytes remain pre-upgrade.
  > **Why this is uncertain:** The current-session `T-BUG-018-17` assertion proves source compatibility, but supported release/install/upgrade prerequisites remain incomplete. Feature 007 full traceability is independently owned by its Scope 09 and does not contribute to this BUG-018 uncertainty.
  > **What would resolve this:** Release/install ownership satisfies `T-BUG-018-15`/`16` and performs the supported upgrade before `T-BUG-018-18` runs without a manual managed-file edit.
- [x] Test fixtures are unique, complete, production-path, trap-cleaned, and isolated from every protected downstream or operational surface. Evidence: [GREEN Production-Path Regression](report.md#green-production-path-regression) and [Portability And Bash 3.2](report.md#portability-and-bash-32) (**Phase:** implement; **Claim Source:** executed; both full matrices pass, `env-pollution-scan` passes, and `BUG018_RESIDUAL_FIXTURE_COUNT=0`).
- [ ] The change boundary contains all edits within allowed file families and leaves every excluded surface byte-identical.
  > **Uncertainty Declaration**
  > **What was attempted:** Scoped `git diff --check`, scoped status, editor diagnostics, and current SHA-256 identity capture were executed over every BUG-018 implementation path.
  > **What was observed:** All BUG-018 changes are within allowed families, but the pre-existing worktree has many concurrent dirty and untracked files.
  > **Why this is uncertain:** No stable pre-run byte baseline exists for every excluded concurrent path, so absolute byte identity cannot be claimed honestly.
  > **What would resolve this:** Independent test captures and compares a stable protected-path baseline while concurrent writers are quiescent.

Test evidence:

- [x] `T-BUG-018-00` records current-session RED output before the production source edit. Evidence: [RED Production-Path Regression](report.md#red-production-path-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-01` passes the exact level-2 production-path case. Evidence: [GREEN Production-Path Regression](report.md#green-production-path-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-02` proves byte-equivalent level-2/level-3 fixtures yield equal mapping sets. Evidence: [GREEN Production-Path Regression](report.md#green-production-path-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-03` proves missing exact headings report once and reach the final summary. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-04` proves empty, header-only, and separator-only sections are rowless and reach the final summary. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed; the same run also proves distinct extractor-failure handling).
- [x] `T-BUG-018-05` proves nested rows remain and later same-or-shallower sibling rows are excluded. Evidence: [Boundary And Adversarial Regression](report.md#boundary-and-adversarial-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-06` proves expected no-scenario no-match reaches its diagnostic and final summary. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-07` proves macOS system Bash starts with optional fun mode disabled. Evidence: [Portability And Bash 3.2](report.md#portability-and-bash-32) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-08` passes the complete managed selftest without removing existing cases. Evidence: [Managed Selftest And Regression Integrity](report.md#managed-selftest-and-regression-integrity) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-09` passes the bugfix regression-quality guard with adversarial signal and no bailout. Evidence: [Managed Selftest And Regression Integrity](report.md#managed-selftest-and-regression-integrity) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-10` passes Bash syntax for all five changed BUG-018 shell files and macOS portability for the four BUG-018-authored implementation/test surfaces. Evidence: [Corrected Shell And Registration Contracts](report.md#corrected-shell-and-registration-contracts) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-11` passes direct BUG-012 and BUG-013 production-guard canaries. Evidence: [Consumer Regression](report.md#consumer-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-12` proves canonical production behavior against a disposable Research-Lab-shaped packet owned by the persistent regression. Evidence: [Canonical Research-Lab-Shaped Fixture](report.md#canonical-research-lab-shaped-fixture) (**Phase:** implement; **Claim Source:** executed).
- [x] `T-BUG-018-13` passes artifact lint, freshness, traceability, and G094 for BUG-018. Evidence: [Packet Governance](report.md#packet-governance) (**Phase:** implement; **Claim Source:** executed).
- [ ] `T-BUG-018-14` passes full framework validation with the registered regression. Evidence: [Framework Validation](report.md#framework-validation).
  > **Uncertainty Declaration**
  > **What was attempted:** Shared-validator occupancy was checked again after the current-session `T-BUG-018-17` assertion.
  > **What was observed:** No matching framework-validation, release-check, install-provenance, or traceability process remains; `T-BUG-018-14` itself was not executed in this invocation.
  > **Why this is uncertain:** There is no current-session broad framework verdict for BUG-018.
  > **What would resolve this:** `bubbles.test` runs one independent, serial canonical framework validation while the shared lane and source identities remain stable.
- [ ] `T-BUG-018-15` proves managed/source-only installer classification and byte identity. Evidence: [Release And Install Provenance](report.md#release-and-install-provenance).
  > **Uncertainty Declaration**
  > **What was attempted:** Provenance assertions, current canonical/manifest identities, Git tracking state, and installed Research Lab identity were inspected without entering the occupied install lane.
  > **What was observed:** Canonical guard hash `dfc4e00a...` and selftest hash `691b022f...` differ from generated metadata; the new regression is untracked and absent; the installed guard still has pre-upgrade hash `dd9784a1...`.
  > **Why this is uncertain:** The install-provenance selftest cannot legitimately pass until canonical release generation includes the tracked regression and changed managed bytes.
  > **What would resolve this:** Normal repository tracking plus release-owned manifest regeneration, followed by the exact install-provenance selftest.
- [ ] `T-BUG-018-16` passes generated release validation after all source inputs are stable. Evidence: [Release And Install Provenance](report.md#release-and-install-provenance).
  > **Uncertainty Declaration**
  > **What was attempted:** Release-lane occupancy, manifest identities, and tracked/source-only classification were checked.
  > **What was observed:** The shared lane is currently clear, but unrelated release inputs are dirty, the regression is untracked, and release metadata remains unsettled for the managed BUG-018 files.
  > **Why this is uncertain:** Regeneration now would exclude the source-only regression and could absorb unfinished foreign release inputs.
  > **What would resolve this:** Settle and track the complete source set, regenerate through canonical tooling, then run one serial release check.
- [x] `T-BUG-018-17` proves BUG-018 downstream source compatibility from the owning Research Lab root: Feature 007 resolves, all 32 manifest-linked tests are recognized, all nine scopes are traversed, the normal final summary is reached, and no path-resolution, extractor, or post-announcement silent-exit failure occurs. Exit `1` may carry the 37 nonterminal Feature-007-owned traceability findings; this item does not claim those findings pass or are resolved. Planning contract: [Corrected Test Contract Index](report.md#corrected-test-contract-index). Evidence: [Current-Session Corrected T-BUG-018-17 Compatibility Assertion](report.md#current-session-corrected-t-bug-018-17-compatibility-assertion) (**Phase:** implement; **Claim Source:** executed).
- [ ] `T-BUG-018-18` replays Research Lab Feature 007 with installed managed bytes only after `T-BUG-018-16` and supported release/install/upgrade delivery complete. Planning contract: [Corrected Test Contract Index](report.md#corrected-test-contract-index).
  > **Uncertainty Declaration**
  > **What was attempted:** The installed pre-upgrade guard was invoked before canonical delivery completed.
  > **What was observed:** It retained the old silent-exit behavior, which is expected from stale installed bytes and is not an implementation failure.
  > **Why this is uncertain:** No supported upgrade has yet delivered the validated canonical release to Research Lab.
  > **What would resolve this:** Release/install ownership performs the supported upgrade after `T-BUG-018-16`, then executes `T-BUG-018-18` without any manual managed-file edit.
- [x] `T-BUG-018-19` proves the exact BUG-018 framework-registration hunk is present and whitespace-clean without asserting portability of unrelated `framework-validate.sh` lines. Evidence: [Corrected Shell And Registration Contracts](report.md#corrected-shell-and-registration-contracts) (**Phase:** implement; **Claim Source:** executed).

Build Quality Gate:

- [x] RED precedes source changes; GREEN reruns the same persistent production-path command; every evidence block carries the producing phase, exact command, actual exit code, claim source, and raw output. Evidence: [RED Production-Path Regression](report.md#red-production-path-regression) and [GREEN Production-Path Regression](report.md#green-production-path-regression) (**Phase:** implement; **Claim Source:** executed).
- [x] The adversarial missing, rowless, boundary, and no-scenario cases fail if the defect returns and contain no early-return or silent-pass branch. Evidence: [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival), [Boundary And Adversarial Regression](report.md#boundary-and-adversarial-regression), and [Managed Selftest And Regression Integrity](report.md#managed-selftest-and-regression-integrity) (**Phase:** implement; **Claim Source:** executed).
- [ ] Framework registration, source-only inventory, managed install provenance, generated release metadata, and direct documentation agree with the settled source set.
  > **Uncertainty Declaration**
  > **What was attempted:** Registration and provenance assertions were implemented; current manifest identities were audited.
  > **What was observed:** Registration exists, but the source-only file is untracked and all three BUG-018 release entries are absent or stale.
  > **Why this is uncertain:** Generated and installed provenance cannot agree before the settled tracked source set exists.
  > **What would resolve this:** Release ownership regenerates from the tracked settled source and reruns install/release validation.
- [ ] All required focused and broad checks pass with zero skipped required cases and no regression in existing traceability behavior.
  > **Uncertainty Declaration**
  > **What was attempted:** The 55-assertion default and Bash 3.2 regressions, managed selftest, regression-quality, corrected `T-BUG-018-10`/`12`/`17`/`19`, direct canaries, packet gates, diff checks, isolation, and editor diagnostics all executed.
  > **What was observed:** Every BUG-018-owned focused check passes. `T-BUG-018-17` satisfies the observable source-compatibility signals and returns the foreign packet's 37 nonterminal findings; `T-BUG-018-14`, `T-BUG-018-15`, `T-BUG-018-16`, and `T-BUG-018-18` were not executed in this T-17-only invocation.
  > **Why this is uncertain:** One serial framework validation, release provenance, supported upgrade, and installed replay remain incomplete. Feature 007 Scope 09 owns its 37 findings independently.
  > **What would resolve this:** Independent test and release/install ownership execute the remaining gated BUG-018 rows in order.
- [ ] Documentation uses the exact accepted headings, status distinctions, diagnostics, public exits, release path, and rollback unit from the design.
  > **Uncertainty Declaration**
  > **What was attempted:** Implementation evidence was synchronized to the existing design terminology in this report.
  > **What was observed:** No managed-documentation owner ran and no direct BUG-018 index documentation was changed.
  > **Why this is uncertain:** Implementation cannot certify the complete managed documentation surface.
  > **What would resolve this:** `bubbles.docs` reconciles managed docs after independent behavior and release validation.
- [ ] No source, test, documentation, release, scope, or certification completion is claimed without current-session evidence from its owning phase.
  > **Uncertainty Declaration**
  > **What was attempted:** Every checked item above links current-session implement evidence; blocked rows remain unchecked with explicit declarations.
  > **What was observed:** No terminal completion or certification claim is present, but independent test/docs/release/validate phases have not yet reviewed this accounting.
  > **Why this is uncertain:** Cross-phase ownership verification belongs to later specialists.
  > **What would resolve this:** Independent test and audit verify the evidence provenance before validation.
- [ ] `bubbles.validate` remains the only writer of `certification.*`, completed scope state, and terminal status promotion.
  > **Uncertainty Declaration**
  > **What was attempted:** This invocation avoided all `certification.*`, completed-scope, and terminal-status writes.
  > **What was observed:** Certification remains blocked and unclaimed in the current state artifact.
  > **Why this is uncertain:** Final ownership compliance is established only after all later phases finish.
  > **What would resolve this:** `bubbles.validate` performs the eventual certification transition after all prerequisites pass.

### Execution Handoff

Implementation executed the existing corrected rows inside the declared
boundary. `T-BUG-018-10`, `T-BUG-018-12`, and `T-BUG-018-19` pass. Planning now
defines `T-BUG-018-17` as a downstream source-compatibility assertion, not a
Feature 007 completion gate: the exact command resolves the owning checkout,
recognizes all 32 linked tests, traverses all nine scopes, reaches the normal
summary, and avoids BUG-018 path-resolution, extractor, and silent-exit
failures. Its exit `1` and 37 findings remain owned by Feature 007 Scope 09 and
are not claimed passing or resolved. `bubbles.implement` is the next owner to
record this corrected assertion against the already captured raw output.
`T-BUG-018-18` remains gated by the distinct release/install prerequisites.
Scope status, incomplete delivery DoD items, certification, and top-level
status remain unchanged.
