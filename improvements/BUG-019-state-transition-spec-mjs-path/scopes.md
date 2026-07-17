# Scopes: BUG-019 State Transition Compound MJS Test Path

> Planning ownership is reconciled against the current dirty worktree and the
> closed design. The Check 8 repair and test bytes are preserved, every delivery
> checkbox remains open, and this packet stays blocked on named foreign owners.

Related artifacts: [spec.md](spec.md), [design.md](design.md), [report.md](report.md), [uservalidation.md](uservalidation.md)

## Execution Outline

### Phase Order

1. **Scope 1 - Whole-token Check 8 repair:** preserve the valid BUG-019 RED,
   current Check 8 implementation, and independent 38/38 GREEN evidence; route
   foreign Bash/runtime findings to their owning packets; then rerun the
   corrected system-Bash matrix before release and certification ownership.

### New Types And Signatures

- `candidate` is one complete maximal token over `[A-Za-z0-9._/-]`; Check 8
  never derives a supported substring from a longer candidate.
- Accepted candidate contexts are a bare backticked path, the first non-option
  operand of a `bash`/`sh` wrapper, or a supported shell script used as the
  command's first token.
- `allowedSuffix` is closed to `.spec.mjs`, `.test.mjs`, `.spec`, `.test`,
  `.rs`, `.ts`, `.tsx`, `.js`, `.jsx`, `.sh`, `.bash`, `.bats`, `.py`, `.go`,
  `.java`, `.scala`, and `.dart`.
- Stage 1 extracts a complete candidate; Stage 2 accepts it only when its
  terminal suffix is in the closed set and a basename character precedes it.
- Check 8 retains the existing `test_files_in_plan[]`, direct `-f` check,
  basename-only resolution, planning-maturity diagnostics, missing-file
  enforcement, aggregate result, and public exit classes.
- No new CLI flag, config key, dependency, generic Markdown parser, shell
  evaluator, or downstream compatibility path is introduced.

### Validation Checkpoints

1. **Preserved BUG-019 evidence checkpoint:** the final test-owned RED predates
   the Check 8 edit, and the unchanged regression later recorded independent
   38/38 GREEN. Neither fact closes the active scope or foreign findings.
2. **Planner command checkpoint:** `T-BUG-019-08` resolves `jq` and `yq`
   fail-loud, places system directories first so nested `bash` selects the
   platform system interpreter, and runs the unchanged production matrix.
3. **Foreign runtime checkpoint:** BUG-020 owns the `fun-mode.sh` Bash 3.2
   behavior and missing persistent coverage; BUG-021 owns raw timeout; the
   unpacketized empty-array nounset finding routes to `bubbles.bug` as BUG-022.
4. **Independent rerun checkpoint:** after the three foreign routes satisfy
   their own contracts, `bubbles.test` reruns the unchanged BUG-019 regression
   with both the normal command and corrected `T-BUG-019-08` command.
5. **Framework checkpoint:** focused canaries and install provenance run before
   any full framework validation. A lint pragma is not runtime portability
   evidence.
6. **Release checkpoint:** `bubbles.releases` alone regenerates canonical
   release metadata and runs `release-check` after all source inputs settle.
7. **Certification checkpoint:** `bubbles.validate` alone evaluates terminal
   evidence and writes certification or completion state.

### Ordering Rationale

The repair remains one vertical scope because parser behavior, persistent
production-path regression, managed selftest, registration, provenance, and
release validation form one observable framework contract. The parser evidence
is preserved, but foreign runtime ownership blocks the corrected system-Bash
row and every later release/certification checkpoint.

## Scope Inventory

| # | Scope | Depends On | Primary surfaces | Status |
| --- | --- | --- | --- | --- |
| 1 | Whole-Token Compound Test Path Extraction | - | Check 8, focused production-path regression, canonical registration | Blocked |

## Scope 1: Whole-Token Compound Test Path Extraction

**Status:** Blocked
**Depends On:** -
**Scope-Kind:** runtime-behavior

### Outcome

State-transition Check 8 preserves complete compound MJS test paths, retains
existing ordinary and command-wrapped controls, and rejects extension-prefix
or prose substrings as concrete test files.

### Gherkin Scenarios

#### SCN-BUG-019-001: Compound MJS test paths remain complete

```gherkin
Scenario: Compound MJS test paths remain complete
   Given backticked Test Plan cells name existing tests/palm-springs-rental-market-lab.spec.mjs and tests/example.test.mjs files
   And the shorter tests/palm-springs-rental-market-lab.spec and tests/example.test files do not exist
  When the production state-transition guard executes Check 8
   Then Check 8 verifies each complete MJS path through its existing filesystem branch
   And it reports neither shorter .spec nor .test prefix as missing
   And Check 8 and scenario traceability retain the same complete linked token
```

#### SCN-BUG-019-002: Existing compound controls retain complete paths

```gherkin
Scenario: Existing compound controls retain complete paths
   Given bare backticked Test Plan cells name existing .spec.ts, .test.js, marker-only, and simple shell test paths
   And command cells use bash tests/example.sh, bash -n tests/example.sh with a shellcheck continuation, and ./tests/example.sh check
  When the production state-transition guard executes Check 8
  Then Check 8 verifies each complete path
   And it selects the first complete accepted path from each recognized command context
   And it never treats a whole command block as a filesystem path
```

#### SCN-BUG-019-003: Extension prefixes and prose are rejected

```gherkin
Scenario: Extension prefixes and prose are rejected
   Given one backticked Test Plan cell contains tests/example.spec.mjs.backup
   And another contains the prose token example.spec.mjs is illustrative
   And an unrecognized command cell contains node --test tests/example.spec.mjs
  When the production state-transition guard executes Check 8
  Then neither cell becomes a concrete test path
  And no shorter prefix is checked on disk
   And a row set containing only those invalid contexts reaches the existing no-concrete-path branch
```

### UI Scenario Matrix

None found - this bug affects a command-line governance guard. The observable
contract is exact extracted paths, diagnostics, and process status.

### Implementation Plan

1. Preserve the current Check 8 and `test_26` bytes. BUG-019 planning does not
   edit, normalize, or attribute foreign changes in `fun-mode.sh` or the raw
   timeout call sites in `framework-validate.sh`.
2. `bubbles.bug` creates the complete BUG-022 packet for the Bash 3.2
   empty-array nounset failure at `passed_gate_ids[@]` and
   `failed_check_ids[@]`; BUG-019 does not expand its source boundary.
3. BUG-020 retains ownership of `fun-mode.sh`, its missing `test_27` mandatory
   pre-fix RED, persistent coverage, and spec-owned G094 justification. Existing
   worktree bytes are not treated as sequencing compliance.
4. BUG-021 retains ownership of the two raw timeout registrations and currently
   routes to `bubbles.plan` after analyst-owned Single-Capability Justification.
5. `bubbles.test` reruns the unchanged BUG-019 persistent regression after the
   foreign runtime routes settle, including the corrected parser-aware
   system-Bash command in `T-BUG-019-08`.
6. `bubbles.docs` reconciles only direct BUG-019 documentation claims, expected
   to be `BUGS.md` and `CHANGELOG.md` unless the managed-doc registry identifies
   another direct Check 8 contract surface.
7. `bubbles.releases` regenerates `bubbles/release-manifest.json` through
   canonical tooling after the complete owned source set is stable and runs
   the release gate; no specialist hand-edits generated bytes.
8. `bubbles.validate` independently executes certification gates and is the
   only owner permitted to write `certification.*`, completed scope state, or a
   terminal status.

### Consumer Impact Sweep

- Check 8 Markdown row selection, backtick-block enumeration,
   `test_files_in_plan[]`, direct path checks, basename-only resolution, and
   planning/delivery profile diagnostics;
- marker-only `.spec`/`.test`, ordinary `.spec.ts`/`.test.js`, compound
   `.spec.mjs`/`.test.mjs`, and every existing simple terminal suffix;
- bare-path, `bash`/`sh`, direct-script, first-candidate, placeholder-only,
   extension-prefix, prose, and unrecognized-command Test Plan contexts;
- single-file and per-scope-directory planning layouts;
- `state-transition-guard-selftest.sh`, `framework-validate.sh`,
   `install-provenance-selftest.sh`, release-manifest source-only inventory, and
   downstream installed managed bytes; and
- scenario-manifest and traceability consumers, which must retain the same
   complete concrete test token without changing BUG-018 behavior.

No route, public API, schema, generated client, UI target, deep link, config
key, or identifier is renamed or removed. The sweep protects extraction
consumers and stale prefix assumptions rather than introducing a compatibility
shim.

### Shared Infrastructure Impact Sweep

`bubbles/scripts/state-transition-guard.sh` is an installer-managed,
high-fan-out certification guard. Independent canaries required before broad
validation are:

- the existing bare `.sh`, placeholder-only, and command-wrapped Check 8 twins;
- exact positive compound MJS and ordinary control fixtures;
- exact negative extension-prefix, prose, and unrecognized-command fixtures;
- a baseline fixture that reaches the Check 8 marker and normal structured
   result before any BUG-019 assertion is interpreted;
- direct-path and basename-only file-existence behavior under planning and
   delivery profiles; and
- the full managed selftest before `framework-validate` and `release-check`.

Rollback restores the prior validated canonical release, its guard/selftest,
registration, provenance assertions, and generated manifest as one unit. It
does not leave a partial parser or downstream workaround in place.

### Change Boundary

#### Owned Change Inventory

| Path | Required delta | Owner |
| --- | --- | --- |
| `bubbles/scripts/state-transition-guard.sh` | Check 8 complete-candidate extraction and whole-suffix validation only | `bubbles.implement` |
| `bubbles/scripts/state-transition-guard-selftest.sh` | focused compound/control/adversarial Check 8 twins | `bubbles.test` |
| `tests/regression/test_26_state_transition_spec_mjs_path.sh` | persistent production-path RED/GREEN regression | `bubbles.test` |
| `bubbles/scripts/framework-validate.sh` | one `run_check_self_only` BUG-019 registration adjacent to `test_23`/`test_24` | `bubbles.test` |
| `bubbles/scripts/install-provenance-selftest.sh` | managed guard/selftest and source-only `test_26` assertions | `bubbles.test` |
| `BUGS.md`, `CHANGELOG.md` | direct truthful BUG-019 documentation only when executable evidence exists | `bubbles.docs` |
| `bubbles/release-manifest.json` | generator-owned refresh after settled source | `bubbles.releases` |
| BUG-019 planning artifacts | scenario, Test Plan, DoD, acceptance, evidence-index, and execution routing | `bubbles.plan` |
| `state.json::certification.*` and terminal transition | independent certification only | `bubbles.validate` |

The regression filename is collision-free: BUG-018 now owns
`test_25_traceability_test_plan_heading_depth.sh`, its framework registration,
and its source-only provenance assertion. No `test_26` file, framework
registration, or provenance assertion exists. Therefore
`test_26_state_transition_spec_mjs_path.sh` remains the next appropriate
source-only slot for BUG-019.

#### Excluded Surfaces

- Research Lab and every downstream installed `.github/bubbles/**` path;
- BUG-012, BUG-013, BUG-018, their artifacts, tests, and owning source paths;
- `bubbles/scripts/traceability-guard.sh`, generic Markdown parsing, unrelated
   state-transition checks/helpers, and existing file-existence semantics;
- release-train config, deployment manifests, monitoring, backups, secrets,
   and network services;
- hand-edited generated release bytes; and
- every unrelated dirty or untracked path already present in the canonical
   worktree.

Any required expansion stops the active owner before that path is edited and
returns the packet to the relevant owner. Collateral cleanup is not authorized.

### Finding Ledger And Owner Routes

| Finding | Current disposition | Deterministic owner and packet |
| --- | --- | --- |
| `AUD-005-S01-004` | Addressed at the BUG-019 implementation/test surface: the preserved report records valid pre-fix RED and independent 38/38 GREEN for the unchanged `test_26` bytes. This does not complete Scope 1. | BUG-019; retain for final independent rerun and certification accounting. |
| `PLAN-019-002-SYSTEM-PATH-PARSERS` | Addressed in planner-owned Markdown/JSON: `T-BUG-019-08` now resolves mandatory `jq`/`yq`, uses system directories first, and runs the unchanged matrix under `/bin/bash`. | `bubbles.plan`, BUG-019. |
| `TEST-019-003` | Unresolved ownership/sequencing collision: `fun-mode.sh` changed during BUG-019, but BUG-020 exclusively owns that behavior and still requires its final-byte pre-fix RED plus a spec-owned G094 justification. No valid BUG-020 RED or sequence compliance is inferred. | `bubbles.analyst` for BUG-020 G094, then `bubbles.test` for BUG-020's mandatory RED/sequencing disposition; packet `improvements/BUG-020-state-transition-bash32-startup`. |
| `TEST-019-006-FUN-MODE-PERSISTENT-COVERAGE` | Unresolved: implementation-owned probes do not replace BUG-020's absent persistent `test_27` regression. | `bubbles.test` through BUG-020 after its analyst-owned gap is closed. |
| `TEST-019-004-PORTABILITY` | Unresolved: stock macOS lacks raw `timeout`; scanner suppression cannot prove runtime behavior. | `bubbles.plan` through `improvements/BUG-021-framework-validate-raw-timeout`, whose analyst justification is present. |
| `TEST-019-005-BASH32-EMPTY-ARRAY` | Unresolved and unpacketized: with parsers available, Bash 3.2 reaches Check 8 but aborts when empty `passed_gate_ids[@]` or `failed_check_ids[@]` is expanded under nounset. Repository search found no existing owning packet. | `bubbles.bug` must create the complete packet at `improvements/BUG-022-state-transition-bash32-empty-array-nounset`. |
| `RELEASE-019-001` | Unresolved: generated release metadata and `release-check` remain untouched by this reconciliation. | `bubbles.releases` after BUG-019/020/021/022 source and test inputs settle. |
| `PACKET-019-001` | Unresolved and nonterminal: unchecked DoD, foreign findings, release identity, and certification remain open. | `bubbles.validate` only after every preceding owner returns executable evidence. |

### Test Plan

| Test Type | Test ID | Scenario | Category | File / Location | Exact behavior | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| RED regression | T-BUG-019-00 | SCN-BUG-019-001, SCN-BUG-019-003 | e2e-api | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | final regression bytes fail before source repair because production Check 8 reports `.spec`/`.test` prefixes and accepts prefix/prose substrings | `bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | Yes |
| Regression E2E | T-BUG-019-01 | SCN-BUG-019-001 - Compound MJS test paths remain complete | e2e-api | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | `Regression: compound MJS paths remain complete through production Check 8` | `bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | Yes |
| Regression E2E | T-BUG-019-02 | SCN-BUG-019-002 - Existing compound controls retain complete paths | e2e-api | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | `Regression: ordinary suffix, backtick, and command-wrapper controls remain compatible` | `bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | Yes |
| Adversarial Regression E2E | T-BUG-019-03 | SCN-BUG-019-003 - Extension prefixes and prose are rejected | e2e-api | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | `Regression: extension-prefix and prose candidates never reach Check 8 filesystem validation` | `bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | Yes |
| Managed guard selftest | T-BUG-019-04 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | compound/control/adversarial twins plus existing bare-shell, placeholder-only, and command-wrapper cases execute the production guard | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes |
| Regression integrity | T-BUG-019-05 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | functional | `bubbles/scripts/regression-quality-guard.sh` | persistent regression has adversarial signal, direct assertions, and no silent-pass bailout | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_26_state_transition_spec_mjs_path.sh` | No |
| Shell syntax | T-BUG-019-06 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | functional | changed BUG-019 shell files | every changed shell file parses under macOS system Bash | `/bin/bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | No |
| Shell portability | T-BUG-019-07 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | functional | `bubbles/scripts/macos-portability-guard.sh` | every changed shell file contains none of the mechanically forbidden GNU/Bash-only forms | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | No |
| System-Bash production regression | T-BUG-019-08 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | e2e-api | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | mandatory `jq` and `yq` resolve fail-loud; system directories remain first so the harness and nested production guard select the platform system Bash; the unchanged complete matrix executes | `jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | Yes |
| Install provenance | T-BUG-019-09 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `bubbles/scripts/install-provenance-selftest.sh` | guard and managed selftest install byte-identically while `test_26` remains source-only and release-recorded | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| Framework integration | T-BUG-019-10 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `bubbles/scripts/cli.sh` | registered BUG-019 regression and all existing framework checks pass | `bash bubbles/scripts/cli.sh framework-validate` | Yes |
| Release integration | T-BUG-019-11 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `bubbles/scripts/cli.sh` | generated metadata, install provenance, source identity, and release readiness are current | `bash bubbles/scripts/cli.sh release-check` | Yes |
| Artifact lint | T-BUG-019-12 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | functional | `improvements/BUG-019-state-transition-spec-mjs-path` | required packet shape, evidence metadata, checklist syntax, and state integrity pass | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-019-state-transition-spec-mjs-path` | No |
| Artifact freshness | T-BUG-019-13 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | functional | `improvements/BUG-019-state-transition-spec-mjs-path` | no stale active or executable superseded planning content remains | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | No |
| Capability proportionality | T-BUG-019-14 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | functional | `improvements/BUG-019-state-transition-spec-mjs-path` | G094 accepts the design's single-implementation justification | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | No |
| Traceability | T-BUG-019-15 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `improvements/BUG-019-state-transition-spec-mjs-path` | every scenario maps to its primary production regression, report evidence, and faithful DoD item | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | Yes |
| Transition contract | T-BUG-019-16 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `bubbles/scripts/transition-contract-resolver.sh` | bugfix-fastlane resolves the current delivery-completion contract without caller-selected policy | `bash bubbles/scripts/transition-contract-resolver.sh improvements/BUG-019-state-transition-spec-mjs-path` | Yes |
| Certification guard | T-BUG-019-17 | SCN-BUG-019-001, SCN-BUG-019-002, SCN-BUG-019-003 | integration | `bubbles/scripts/state-transition-guard.sh` | the production transition guard preserves Check 8 file-existence enforcement and passes only after every delivery obligation has evidence | `bash bubbles/scripts/state-transition-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | Yes |

`Live System: Yes` means the real production guard or framework runner executes
as a subprocess against disposable repositories. No browser, network,
database, telemetry, stress, or load runtime applies. The project config defines
neither `testImpact` nor `traceContracts`, so no generated impact-map or
observability row applies.

### Test Environment Isolation

All regression fixtures must use uniquely created temporary directories and be
removed through traps on `EXIT`, `INT`, and `TERM`. They must invoke the
canonical production guard and keep all packet/test/log files beneath one
owned parent. They may not mutate a downstream repository, installed framework
copy, monitoring surface, backup path, release-train configuration, deployment
manifest, shared baseline, or network service.

### Definition of Done - Tiered Validation

Core behavior:

- [ ] `SCN-BUG-019-001 - Compound MJS test paths remain complete`: complete `.spec.mjs` and `.test.mjs` paths reach the existing filesystem branch, no marker prefix is checked, and traceability retains the same token.
- [ ] `SCN-BUG-019-002 - Existing compound controls retain complete paths`: ordinary `.spec.ts`/`.test.js`, marker-only/simple suffixes, bare backticks, shell wrappers, and direct-script commands preserve first-accepted-candidate behavior.
- [ ] `SCN-BUG-019-003 - Extension prefixes and prose are rejected`: `.spec.mjs.backup`, extension-shaped prose, and unrecognized multiword commands produce no concrete path or shorter filesystem lookup.
- [ ] Stage 1 emits only a complete maximal path-alphabet candidate from one recognized context; Markdown and command text remain inert and unevaluated.
- [ ] Stage 2 validates the complete candidate against the closed suffix set; bare `.mjs` and every unlisted compound remain unsupported.
- [ ] Existing direct-path, basename-only, planning-maturity, delivery missing-file, placeholder, deduplication, aggregate-result, and public exit semantics remain unchanged.
- [ ] Consumer and shared-infrastructure sweeps pass before broad validation, and rollback restores one coherent validated release unit.
- [ ] The owned Change Inventory is exact; excluded paths, unrelated dirty work, downstream managed bytes, and `certification.*` remain untouched by non-owning phases.
- [ ] Direct documentation describes only executed behavior, and generated release metadata is produced only by canonical tooling after source stabilization.

Test evidence, one item per Test Plan row:

- [ ] `T-BUG-019-00` records honest current-session RED output from final regression bytes before the production edit.
- [ ] `T-BUG-019-01` passes the exact compound MJS production-path assertions after the repair.
- [ ] `T-BUG-019-02` passes ordinary suffix, backtick, and command-wrapper compatibility assertions.
- [ ] `T-BUG-019-03` passes extension-prefix, prose, unrecognized-command, and no-shorter-lookup adversarial assertions.
- [ ] `T-BUG-019-04` passes the complete managed state-transition selftest with existing Check 8 canaries retained.
- [ ] `T-BUG-019-05` reports adversarial signal and zero silent-pass regression-quality findings.
- [ ] `T-BUG-019-06` passes macOS system-Bash syntax for every changed shell file.
- [ ] `T-BUG-019-07` passes the direct portability scan for every changed shell file.
- [ ] `T-BUG-019-08` resolves required `jq` and `yq` fail-loud, selects the platform system Bash for the harness and nested guard, and passes the unchanged full production regression.
- [ ] `T-BUG-019-09` proves managed/source-only installation and release provenance classifications.
- [ ] `T-BUG-019-10` passes canonical full framework validation after focused GREEN.
- [ ] `T-BUG-019-11` passes canonical release validation after the owned source set settles.
- [ ] `T-BUG-019-12` passes canonical BUG-019 artifact lint.
- [ ] `T-BUG-019-13` passes canonical BUG-019 artifact freshness.
- [ ] `T-BUG-019-14` passes G094 capability-proportionality validation.
- [ ] `T-BUG-019-15` passes scenario, test, evidence, and DoD traceability with physical test files present.
- [ ] `T-BUG-019-16` resolves the current bugfix-fastlane transition contract successfully.
- [ ] `T-BUG-019-17` passes the production certification guard without weakening Check 8 file-existence enforcement.

Build Quality Gate:

- [ ] RED precedes the production edit and GREEN reruns identical regression bytes and command; every evidence block records phase, exact command, actual exit, claim source, and raw current-session output.
- [ ] Every scenario has one primary persistent regression mapping, no required case is skipped, and the adversarial cases fail if substring extraction or bailout behavior returns.
- [ ] Focused canaries, broader framework checks, release validation, and all certification gates pass in order with one-to-one finding accounting.
- [ ] Documentation, registration, install provenance, source-only inventory, generated manifest, and executable behavior agree with the settled source set.
- [ ] Change-boundary verification reports zero BUG-019-attributed excluded-path changes and preserves unrelated BUG-012/013/018 work.
- [ ] `bubbles.validate` remains the only writer of certification fields, completed scope state, and terminal status.

> **Uncertainty Declaration for unchecked delivery items**
> **What was attempted:** Planning reconciled current source/test evidence,
> exact packet ownership, three scenario contracts, the 18-row Test Plan, and
> nonterminal routing. No historical output was relabeled as current execution.
> **What was observed:** BUG-019 has preserved valid RED and independent 38/38
> GREEN evidence, while the former system-only PATH removed `jq`/`yq`. The
> corrected command reaches the foreign Bash 3.2 empty-array boundary recorded
> in `report.md`; BUG-020 and BUG-021 retain their own unmet contracts.
> **Why this remains open:** BUG-022 does not yet exist, BUG-020 has no valid
> mandatory pre-fix RED or spec-owned G094 closure, BUG-021 remains routed to
> planning, and release/certification owners have not run their terminal work.
> **What would resolve this:** Create BUG-022 through `bubbles.bug`, satisfy the
> BUG-020 and BUG-021 packet contracts without modifying BUG-019 bytes, rerun
> the corrected BUG-019 test rows, then obtain release and validate-owned
> evidence in order.

### Execution Handoff

Immediate owner: `bubbles.bug`, solely to create the complete BUG-022 packet at
`improvements/BUG-022-state-transition-bash32-empty-array-nounset`. BUG-019
cannot proceed to independent test completion while the corrected system-Bash
row aborts in that unowned runtime path. Once BUG-020, BUG-021, and BUG-022
return executable evidence, `bubbles.test` reruns the unchanged BUG-019 rows;
release and certification retain their named owners. No nested workflow is
authorized from this planning node.
