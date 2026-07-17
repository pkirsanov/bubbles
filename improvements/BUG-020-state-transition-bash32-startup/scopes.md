# Scopes: BUG-020 State Transition Bash 3.2 Startup

Related artifacts: [spec.md](spec.md), [design.md](design.md),
[report.md](report.md), and [uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Scope 1 - Split-Lane Bash 3.2 Startup Proof:** preserve one portable
   `fun-mode.sh` implementation, prove its complete API without parsers, prove
   the strict system-only guard fails closed at `E009-REGISTRY-MISSING`, and
   reserve Check 8 plus structured-result proof for parser-aware guard lanes.

### New Types & Signatures

- No public CLI, schema, environment, or persisted-data contract changes.
- Preserve `fun_mode_active()`, `fun_message(event)`, `fun_pass()`,
  `fun_fail()`, `fun_warn()`, `fun_banner()`, and
  `fun_summary(result, failure_count?)` unchanged.
- Add one internal Bash-3.2-safe closed event dispatcher and positional-argument
  random-pool selector; do not add a version-selected implementation.
- Add `tests/regression/test_27_state_transition_bash32_startup.sh` as the
  source-only production regression registered once by framework validation.

### Validation Checkpoints

1. `bubbles.test` finalizes the revised split-lane regression bytes, records
   their digest, and runs those bytes first in an isolated projection against
   the known pre-fix `fun-mode.sh` blob; no current or historical run is
   retroactively credited as RED.
2. Only after valid isolated RED, `bubbles.implement` applies the candidate
   portable source in that same lineage; identical test bytes and command are
   then required for GREEN.
3. Parser-free Bash 3.2 proves all seven fun-mode functions with fun mode false
   and true. The strict system-only guard lane proves the exact resolver refusal
   and explicitly must not claim Check 8.
4. Parser-aware Bash 3.2 and newer-Bash lanes use real `jq` and `yq`, reach
   Check 8, and preserve pass and genuine-finding structured outcomes. Any
   empty-array nounset failure remains BUG-022-owned and blocks interpretation.
5. Focused source assertions cover `declare -A`, `local -n`, and `declare -n`,
   which the generic 13-class portability lint does not detect.
6. Managed selftests, syntax, regression quality, portability, and the exact
   changed-file boundary must pass before broad framework validation.
7. Packet artifact lint, freshness, capability-foundation, and traceability
   must pass before release reconciliation.
8. Owner-generated release metadata, release validation, and install provenance
   must agree on one canonical source identity before independent certification.

## Scope Summary

| # | Scope | Depends On | Surfaces | Primary Validation | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Split-Lane Bash 3.2 Startup Proof | - | Shared shell utility, production-process regression, managed selftest, framework registration, release provenance | Prospective identical-byte RED/GREEN, parser-free API, system-only resolver refusal, parser-aware Check 8 twins | Not started |

## Scope 1: Split-Lane Bash 3.2 Startup Proof

**Status:** Not started
**Depends On:** -
**Scope-Kind:** runtime-behavior

### Outcome

One Bash-3.2-compatible `fun-mode.sh` implementation preserves every public fun
API and enabled output. Parser-free Bash proves that API directly; the strict
system-only production guard passes fun-mode startup and fails closed at the
resolver's exact `E009-REGISTRY-MISSING` boundary without Check 8 credit; and
parser-aware real-guard lanes alone prove Check 8 and structured pass/finding
semantics. BUG-022 retains ownership of empty-array nounset behavior.

### Gherkin Scenarios

#### SCN-BUG-020-001: Parser-free Bash proves portable fun-mode startup

```gherkin
Scenario: Parser-free Bash proves portable fun-mode startup
   Given stock macOS Bash 3.2 with a strict system-only PATH
   And jq, yq, timeout, gtimeout, and newer Bash are unavailable
   When the regression sources the canonical fun-mode module under nounset
   And exercises its public API with fun mode disabled and enabled
   Then sourcing succeeds without an associative-array or nameref diagnostic
   And disabled calls remain silent
   And enabled calls preserve the existing message, pool, banner, and summary contract
```

#### SCN-BUG-020-002: Missing parsers produce the normal resolver refusal

```gherkin
Scenario: Missing parsers produce the normal resolver refusal
   Given stock macOS Bash 3.2 with a strict system-only PATH
   And jq and yq are unavailable
   When the regression invokes the real state-transition guard
   Then fun-mode initialization does not abort the guard
   And the guard reports E009-REGISTRY-MISSING with a nonzero exit
   And the run is not required or credited as reaching Check 8
   And empty-array result integrity remains governed by BUG-022
```

#### SCN-BUG-020-003: Parser-aware Bash proves the complete guard path

```gherkin
Scenario: Parser-aware Bash proves the complete guard path
   Given stock macOS Bash 3.2 with system directories first on PATH
   And the real jq and yq directories are appended without a newer Bash or timeout provider
   And passing and genuine-finding fixtures exercise disabled and enabled fun mode
   When the real state-transition guard runs under macOS system Bash
   Then each fixture reaches Check 8 exactly once
   And each fixture produces one structured transition result
   And pass and genuine-finding exits preserve their existing semantics
   And no optional fun-mode initialization error masks the guard outcome
```

### UI Scenario Matrix

None: BUG-020 changes a command-line governance process. Its user-visible
contract is complete terminal output and numeric process status; there is no
browser, mobile, visual, color-dependent, or assistive-technology surface.

### Implementation Plan

1. `bubbles.test` finalizes
   `tests/regression/test_27_state_transition_bash32_startup.sh`, records its
   SHA-256, and runs those exact bytes first in an isolated worktree or owned
   temporary source projection containing the known pre-fix `fun-mode.sh` blob
   and the protected dependency snapshot. Valid RED requires the parser-free API
   and parser-aware guard lanes to fail at the historical fun-mode startup
   discriminator while fixture construction and real-parser resolution controls
   pass. The prior current-source run remains
   `RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED` and supplies no RED credit.
   Record pre-edit SHA-256 identities for every excluded packet, source, test,
   and release path named by `T-BUG-020-18` so containment has a real baseline.
2. Only after that valid RED, `bubbles.implement` applies the portable candidate
   to `bubbles/scripts/fun-mode.sh` in the same isolated lineage, replacing the
    associative event catalog with closed `case` dispatch and nameref pool
    selection with positional arguments. Public names, messages, pools, output,
   and mode semantics stay unchanged; BUG-020 makes no production edit to
   `state-transition-guard.sh` or BUG-022-owned empty-array sites.
3. `bubbles.test` reruns the identical regression digest and commands. The
   strict system-only Bash 3.2 lane executes direct API `false` and `true` cases
   plus a disabled-fun real-guard case that must report
   `E009-REGISTRY-MISSING` nonzero and must not claim Check 8. Separate
   parser-aware Bash 3.2 and newer-Bash lanes resolve real `jq` and `yq`
   fail-loud, then execute disabled/enabled passing and genuine-finding cases
   that must reach Check 8 and preserve structured outcomes.
4. The same regression executes direct fun API `false` and `true` matrices
    under Bash 3.2 and newer Bash, then rejects `declare -A`, `local -n`, and
    `declare -n` explicitly so modern-shell success cannot hide the known
    portability-lint blind spot.
5. `bubbles.test` extends only the BUG-020 portions of the managed transition
    selftest, registers `test_27` once, and adds exact managed/source-only install
    provenance assertions. Focused tests, syntax, owned-surface portability, and
    boundary checks run before packet and broad gates.
6. `bubbles.test` runs full framework validation after the focused and packet
   checks pass. `bubbles.releases` then regenerates
   `bubbles/release-manifest.json` from the settled source/test set and runs
   install provenance plus release readiness against that source identity.
7. `bubbles.validate` evaluates the final delivery contract and remains the
    only writer of certification, completed-scope, and terminal-status fields.

### Consumer Impact Sweep

The public fun API remains unchanged for all direct consumers named by
[design.md](design.md#direct-shared-module-consumers). Validation must confirm:

- direct source consumers retain disabled silence and enabled event text;
- `implementation-reality-scan.sh` and `traceability-guard.sh` retain their
   existing local Bash-3.2 hooks without edits;
- `project-scan-setup.sh` retains its existing optional-source behavior without
   edits;
- the production state-transition guard retains nounset, source ordering,
   check ordering, Check 8 bytes, structured-result authority, and exit status;
- installer membership and checksums classify `fun-mode.sh` and the managed
   selftest as managed while `test_27` remains source-only; and
- downstream installed copies change only through supported release/install/
   upgrade provenance.

No route, public CLI, schema, generated client, UI target, deep link, config
key, feature flag, or persisted identifier is renamed or removed.

### Shared Infrastructure Impact Sweep

`fun-mode.sh` is a high-fan-out shared shell utility. Its independent canaries
are the direct API matrix under both shell roles, the disabled/enabled passing
guard twins, the disabled/enabled genuine-finding twins, and the known-root-
cause construct assertion. These focused canaries must pass before the managed
selftest and full framework suite.

Rollback restores the prior validated canonical release and generated manifest
as one unit through the supported release/install path. It does not retain a
state-transition-only shim, disable nounset, remove the persistent regression,
or patch a downstream managed copy.

### Change Boundary

Allowed delivery surfaces:

- `bubbles/scripts/fun-mode.sh`, limited to portable event dispatch and random
   pool selection;
- `tests/regression/test_27_state_transition_bash32_startup.sh`;
- `bubbles/scripts/state-transition-guard-selftest.sh`, limited to BUG-020
   disabled/enabled pass and genuine-finding twins;
- `bubbles/scripts/framework-validate.sh`, limited to one adjacent source-only
   BUG-020 regression registration;
- `bubbles/scripts/install-provenance-selftest.sh`, limited to exact BUG-020
   managed/source-only assertions;
- generator-owned `bubbles/release-manifest.json`, written only by release
   ownership after source and test bytes settle; and
- BUG-020 artifacts, each written only by its canonical owner.

Excluded surfaces:

- every production byte in `bubbles/scripts/state-transition-guard.sh`,
   including nounset, source order, Check 8, result schema, and exit behavior;
- `tests/regression/test_26_state_transition_spec_mjs_path.sh` and every
   BUG-019-owned Check 8 assertion;
- BUG-012, BUG-013, BUG-018, BUG-019, BUG-021,
   `improvements/BUG-022-state-transition-bash32-empty-array-nounset`, IMP-020,
   and all of their packet/test bytes;
- `implementation-reality-scan.sh`, `traceability-guard.sh`,
   `project-scan-setup.sh`, and their existing compatibility hooks;
- `macos-portability-guard.sh` and its current 13-class contract;
- downstream `.github/bubbles/**` installations, release-train/feature-flag
   config, deployment, monitoring, backup, secrets, and product repositories;
- hand-edited generated metadata, `certification.*`, terminal status, commits,
   pushes, and unrelated dirty worktree bytes; and
- opportunistic formatting, cleanup, or refactoring outside the exact allowed
   hunks.

Any evidence that the one-source repair is insufficient stops source work and
returns the packet to `bubbles.design`; no owner may expand this boundary
inline.

### Test Plan

| Test Type | Test ID | Scenario IDs | Category | File / Location | Exact Test Title | Command | Live System | Owner | Evidence Ref |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| red-regression | T-BUG-020-00 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Prospective RED: revised final test bytes fail at the historical fun-mode startup discriminator against the known pre-fix blob before any candidate patch | `red_root="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug020-red-XXXXXXXX")" && trap 'rm -rf "$red_root"' EXIT INT TERM && [[ "$(git rev-parse HEAD:bubbles/scripts/fun-mode.sh)" == "7da650141188f120f5ac25d4f77fada91bc96e88" ]] && mkdir -p "$red_root/tests/regression" && cp -R bubbles agents "$red_root/" && cp tests/regression/test_27_state_transition_bash32_startup.sh "$red_root/tests/regression/" && git archive --format=tar --output="$red_root/pre-fix.tar" HEAD bubbles/scripts/fun-mode.sh && tar -xf "$red_root/pre-fix.tar" -C "$red_root" && rm -f "$red_root/pre-fix.tar" && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh "$red_root/tests/regression/test_27_state_transition_bash32_startup.sh" && (cd "$red_root" && bash tests/regression/test_27_state_transition_bash32_startup.sh)` | true | `bubbles.test` | [Prospective Isolated Final-Byte RED](report.md#prospective-isolated-final-byte-red) |
| functional-api-regression | T-BUG-020-01 | SCN-BUG-020-001 | functional | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-free API: Bash 3.2 disabled mode sources under nounset and keeps all seven public functions silent | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | false | `bubbles.test` | [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof) |
| adversarial-functional-regression | T-BUG-020-02 | SCN-BUG-020-001 | functional | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-free API: Bash 3.2 enabled mode preserves events, unknown silence, pools, banner, prefix, and summary | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | false | `bubbles.test` | [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof) |
| adversarial-regression-e2e | T-BUG-020-03 | SCN-BUG-020-002 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | System-only guard: disabled fun mode reaches exact E009-REGISTRY-MISSING nonzero and never claims Check 8 | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [System-Only Resolver Refusal Proof](report.md#system-only-resolver-refusal-proof) |
| regression-e2e | T-BUG-020-04 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware Bash 3.2: disabled-fun passing fixture reaches Check 8 and one PASS result | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| regression-e2e | T-BUG-020-05 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware Bash 3.2: enabled-fun passing fixture reaches Check 8 and preserves fun output without changing PASS | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| adversarial-regression-e2e | T-BUG-020-06 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware Bash 3.2: disabled-fun genuine finding retains Check-8-file-existence and nonzero FAIL | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| adversarial-regression-e2e | T-BUG-020-07 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware Bash 3.2: enabled-fun genuine finding retains the same failed check and exit while preserving fun output | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| regression-e2e | T-BUG-020-08 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware newer Bash: disabled-fun passing fixture reaches Check 8 and one PASS result | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| regression-e2e | T-BUG-020-09 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware newer Bash: enabled-fun passing fixture preserves fun output without changing PASS | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| adversarial-regression-e2e | T-BUG-020-10 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware newer Bash: disabled-fun genuine finding retains structured nonzero failure | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| adversarial-regression-e2e | T-BUG-020-11 | SCN-BUG-020-003 | e2e-api | `tests/regression/test_27_state_transition_bash32_startup.sh` | Parser-aware newer Bash: enabled-fun genuine finding retains failure plus enabled fun output | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | true | `bubbles.test` | [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes) |
| functional-api-regression | T-BUG-020-12 | SCN-BUG-020-001 | functional | `tests/regression/test_27_state_transition_bash32_startup.sh` | Newer-Bash API control: disabled and enabled modes preserve the same seven-function contract as Bash 3.2 | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | false | `bubbles.test` | [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof) |
| portability-blind-spot-regression | T-BUG-020-13 | SCN-BUG-020-001 | functional | `tests/regression/test_27_state_transition_bash32_startup.sh` | Root-cause guard: canonical fun-mode source rejects declare -A, local -n, and declare -n even when the generic 13-class lint is green | `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh` | false | `bubbles.test` | [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof) |
| managed-guard-selftest | T-BUG-020-14 | SCN-BUG-020-003 | integration | `bubbles/scripts/state-transition-guard-selftest.sh` | Managed guard: parser-aware disabled/enabled pass and genuine-finding twins execute the canonical production guard | `bash bubbles/scripts/state-transition-guard-selftest.sh` | true | `bubbles.test` | [Managed Guard And Regression Quality](report.md#managed-guard-and-regression-quality) |
| regression-integrity | T-BUG-020-15 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | `bubbles/scripts/regression-quality-guard.sh` | Regression integrity: persistent BUG-020 regression has adversarial signal, direct assertions, exact run counts, and no bailout | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_27_state_transition_bash32_startup.sh` | false | `bubbles.test` | [Managed Guard And Regression Quality](report.md#managed-guard-and-regression-quality) |
| shell-syntax | T-BUG-020-16 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | authorized BUG-020 shell files | Shell syntax: all five authorized shell surfaces parse under macOS system Bash | `/bin/bash -n bubbles/scripts/fun-mode.sh tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | false | `bubbles.test` | [Portability And Change Boundary](report.md#portability-and-change-boundary) |
| shell-portability | T-BUG-020-17 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | `bubbles/scripts/macos-portability-guard.sh` | Shell portability: BUG-020-authored implementation and regression surfaces pass all 13 current classes while T-BUG-020-13 closes the known class gap | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_27_state_transition_bash32_startup.sh` | false | `bubbles.test` | [Portability And Change Boundary](report.md#portability-and-change-boundary) |
| change-boundary-audit | T-BUG-020-18 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | authorized and excluded BUG-020 paths | Boundary: pre/post digests and scoped diffs preserve every excluded byte and constrain allowed shared-file hunks | `find improvements/BUG-012-g085-first-adoption-deadlock improvements/BUG-013-g028-sensitive-client-storage-classification improvements/BUG-018-traceability-test-plan-heading-depth improvements/BUG-019-state-transition-spec-mjs-path improvements/BUG-021-framework-validate-raw-timeout improvements/BUG-022-state-transition-bash32-empty-array-nounset improvements/IMP-020-agentic-evaluation-and-trust-hardening.md -type f -exec shasum -a 256 {} + && shasum -a 256 bubbles/scripts/state-transition-guard.sh bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/implementation-reality-scan.sh bubbles/scripts/traceability-guard.sh bubbles/scripts/project-scan-setup.sh bubbles/scripts/macos-portability-guard.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/release-manifest.json && git status --short -- bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json improvements/BUG-020-state-transition-bash32-startup improvements/BUG-022-state-transition-bash32-empty-array-nounset && git diff --check -- bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | false | `bubbles.test` | [Portability And Change Boundary](report.md#portability-and-change-boundary) |
| artifact-lint | T-BUG-020-19 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | `improvements/BUG-020-state-transition-bash32-startup` | Packet lint: shape, one-scope status, evidence metadata, checklist syntax, and state integrity pass | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-020-state-transition-bash32-startup` | false | `bubbles.test` | [Packet Governance](report.md#packet-governance) |
| artifact-freshness | T-BUG-020-20 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | `improvements/BUG-020-state-transition-bash32-startup` | Packet freshness: active spec, design, and one-scope plan contain no stale executable planning content | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-020-state-transition-bash32-startup` | false | `bubbles.test` | [Packet Governance](report.md#packet-governance) |
| capability-proportionality | T-BUG-020-21 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | functional | `improvements/BUG-020-state-transition-bash32-startup` | G094: capability foundation guard accepts the single-implementation justification | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-020-state-transition-bash32-startup` | false | `bubbles.test` | [Packet Governance](report.md#packet-governance) |
| traceability | T-BUG-020-22 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | integration | `improvements/BUG-020-state-transition-bash32-startup` | Traceability: every scenario maps to physical test assertions, report destinations, and faithful DoD items | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-020-state-transition-bash32-startup` | true | `bubbles.test` | [Packet Governance](report.md#packet-governance) |
| framework-integration | T-BUG-020-23 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | integration | `bubbles/scripts/cli.sh` | Framework validation: full canonical framework validation includes BUG-020 after focused checks pass | `bash bubbles/scripts/cli.sh framework-validate` | true | `bubbles.test` | [Framework Validation](report.md#framework-validation) |
| install-provenance | T-BUG-020-24 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | integration | `bubbles/scripts/install-provenance-selftest.sh` | Install provenance: settled fun-mode and managed selftest install byte-identically while test_27 remains source-only and release-recorded | `bash bubbles/scripts/install-provenance-selftest.sh` | true | `bubbles.releases` | [Release And Install Provenance](report.md#release-and-install-provenance) |
| release-integration | T-BUG-020-25 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | integration | `bubbles/scripts/cli.sh` | Release validation: generated metadata, source identity, install provenance, and release readiness are current and coherent | `bash bubbles/scripts/cli.sh release-check` | true | `bubbles.releases` | [Release And Install Provenance](report.md#release-and-install-provenance) |
| certification-guard | T-BUG-020-26 | SCN-BUG-020-001, SCN-BUG-020-002, SCN-BUG-020-003 | integration | `bubbles/scripts/state-transition-guard.sh` | Certification: final transition passes only after all behavior, release, finding-accounting, and evidence obligations are complete | `bash bubbles/scripts/state-transition-guard.sh improvements/BUG-020-state-transition-bash32-startup` | true | `bubbles.validate` | [Certification Validation](report.md#certification-validation) |

Rows `T-BUG-020-00` through `T-BUG-020-13` are one ordered persistent test
contract. `T-BUG-020-00` first freezes the revised test digest and executes it
against the known pre-fix fun-mode blob in an isolated projection; the current
dirty source is not that RED baseline. After valid RED and candidate application
in the same lineage, identical test bytes execute parser-free API cases, the
system-only `E009-REGISTRY-MISSING` case, parser-aware Bash 3.2 and newer-Bash
pass/finding cases, newer-Bash API controls, and the canonical construct
assertion. Missing Bash 3.2 or real `jq`/`yq` prerequisites fail loud; no lane
substitutes a newer shell, parser shim, or timeout provider.

No browser, database, network, telemetry, load, stress, or mutable-store surface
is implicated. The repository defines no `testImpact` or `traceContracts` map
for this local governance utility. The real production-guard subprocess is the
required user-observable E2E surface.

### Test Environment Isolation

The regression creates one unique temporary parent and removes it on `EXIT`,
`INT`, and `TERM`. Every packet, copied managed surface, direct API probe, and
captured child log remains beneath that parent. Child guard invocations use the
exact system-only Bash 3.2 environment for parser-free API and resolver-refusal
proof. Full-guard cases use system directories first plus only the fail-loud
resolved real `jq`/`yq` directories; newer-Bash controls remain separate and no
timeout provider is introduced.

Fixtures may invoke canonical source but may not write to downstream
repositories, production monitoring, backup paths, release-train config,
deployment manifests, shared baselines, secrets, or network services.

### Definition of Done - Tiered Validation

Core behavior:

- [ ] `SCN-BUG-020-001 - Parser-free Bash proves portable fun-mode startup`: stock macOS Bash 3.2 with a strict system-only `PATH` sources the canonical module under nounset, keeps all seven public calls silent when disabled, and preserves named messages, unknown-event silence, all pools, banner, prefix, and summary when enabled without `jq`, `yq`, timeout, newer Bash, or a shim.
- [ ] `SCN-BUG-020-002 - Missing parsers produce the normal resolver refusal`: the strict system-only real-guard case with fun mode disabled passes fun-mode initialization, reports exact `E009-REGISTRY-MISSING` with a nonzero exit, and never claims Check 8; complete BLOCKED-result and empty-array integrity remain BUG-022-owned and receive no BUG-020 completion credit.
- [ ] `SCN-BUG-020-003 - Parser-aware Bash proves the complete guard path`: macOS system Bash with system directories first and only real `jq`/`yq` directories appended runs disabled/enabled pass and genuine-finding fixtures, reaches Check 8 exactly once per fixture, emits one structured result, and preserves fixture-controlled exits.
- [ ] `fun_mode_active`, `fun_message`, `fun_pass`, `fun_fail`, `fun_warn`, `fun_banner`, and `fun_summary` retain their public names, arguments, return semantics, messages, pool membership, prefix, and mode contract.
- [ ] BUG-020 attributes no production edit to `state-transition-guard.sh`, `transition-contract-resolver.sh`, parser policy, or BUG-022-owned empty-array sites; independently owned BUG-022 bytes may settle first and are consumed without authorship or completion credit.
- [ ] The focused construct assertion rejects `declare -A`, `local -n`, and `declare -n`; the current 13-class portability lint is retained as a separate useful but insufficient check.
- [ ] The Consumer Impact Sweep and Shared Infrastructure Impact Sweep pass before broad validation, and rollback restores one complete validated release unit.
- [ ] The Change Boundary reports zero BUG-020-attributed edits to excluded files, including BUG-022 and its tests, and preserves unrelated dirty work without reset, normalization, commit, or push.
- [ ] Canonical registration, managed/source-only provenance, generated release identity, framework validation, and release readiness agree on one settled source set.

Test evidence, one item per Test Plan row:

- [ ] `T-BUG-020-00 - Prospective RED: revised final test bytes fail at the historical fun-mode startup discriminator against the known pre-fix blob before any candidate patch`. Evidence destination: [Prospective Isolated Final-Byte RED](report.md#prospective-isolated-final-byte-red).
- [ ] `T-BUG-020-01 - Parser-free API: Bash 3.2 disabled mode sources under nounset and keeps all seven public functions silent`. Evidence destination: [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof).
- [ ] `T-BUG-020-02 - Parser-free API: Bash 3.2 enabled mode preserves events, unknown silence, pools, banner, prefix, and summary`. Evidence destination: [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof).
- [ ] `T-BUG-020-03 - System-only guard: disabled fun mode reaches exact E009-REGISTRY-MISSING nonzero and never claims Check 8`. Evidence destination: [System-Only Resolver Refusal Proof](report.md#system-only-resolver-refusal-proof).
- [ ] `T-BUG-020-04 - Parser-aware Bash 3.2: disabled-fun passing fixture reaches Check 8 and one PASS result`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-05 - Parser-aware Bash 3.2: enabled-fun passing fixture reaches Check 8 and preserves fun output without changing PASS`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-06 - Parser-aware Bash 3.2: disabled-fun genuine finding retains Check-8-file-existence and nonzero FAIL`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-07 - Parser-aware Bash 3.2: enabled-fun genuine finding retains the same failed check and exit while preserving fun output`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-08 - Parser-aware newer Bash: disabled-fun passing fixture reaches Check 8 and one PASS result`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-09 - Parser-aware newer Bash: enabled-fun passing fixture preserves fun output without changing PASS`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-10 - Parser-aware newer Bash: disabled-fun genuine finding retains structured nonzero failure`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-11 - Parser-aware newer Bash: enabled-fun genuine finding retains failure plus enabled fun output`. Evidence destination: [Parser-Aware Guard Outcomes](report.md#parser-aware-guard-outcomes).
- [ ] `T-BUG-020-12 - Newer-Bash API control: disabled and enabled modes preserve the same seven-function contract as Bash 3.2`. Evidence destination: [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof).
- [ ] `T-BUG-020-13 - Root-cause guard: canonical fun-mode source rejects declare -A, local -n, and declare -n even when the generic 13-class lint is green`. Evidence destination: [Parser-Free Fun API Proof](report.md#parser-free-fun-api-proof).
- [ ] `T-BUG-020-14 - Managed guard: parser-aware disabled/enabled pass and genuine-finding twins execute the canonical production guard`. Evidence destination: [Managed Guard And Regression Quality](report.md#managed-guard-and-regression-quality).
- [ ] `T-BUG-020-15 - Regression integrity: persistent BUG-020 regression has adversarial signal, direct assertions, exact run counts, and no bailout`. Evidence destination: [Managed Guard And Regression Quality](report.md#managed-guard-and-regression-quality).
- [ ] `T-BUG-020-16 - Shell syntax: all five authorized shell surfaces parse under macOS system Bash`. Evidence destination: [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] `T-BUG-020-17 - Shell portability: BUG-020-authored implementation and regression surfaces pass all 13 current classes while T-BUG-020-13 closes the known class gap`. Evidence destination: [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] `T-BUG-020-18 - Boundary: pre/post digests and scoped diffs preserve every excluded byte and constrain allowed shared-file hunks`. Evidence destination: [Portability And Change Boundary](report.md#portability-and-change-boundary).
- [ ] `T-BUG-020-19 - Packet lint: shape, one-scope status, evidence metadata, checklist syntax, and state integrity pass`. Evidence destination: [Packet Governance](report.md#packet-governance).
- [ ] `T-BUG-020-20 - Packet freshness: active spec, design, and one-scope plan contain no stale executable planning content`. Evidence destination: [Packet Governance](report.md#packet-governance).
- [ ] `T-BUG-020-21 - G094: capability foundation guard accepts the single-implementation justification`. Evidence destination: [Packet Governance](report.md#packet-governance).
- [ ] `T-BUG-020-22 - Traceability: every scenario maps to physical test assertions, report destinations, and faithful DoD items`. Evidence destination: [Packet Governance](report.md#packet-governance).
- [ ] `T-BUG-020-23 - Framework validation: full canonical framework validation includes BUG-020 after focused checks pass`. Evidence destination: [Framework Validation](report.md#framework-validation).
- [ ] `T-BUG-020-24 - Install provenance: settled fun-mode and managed selftest install byte-identically while test_27 remains source-only and release-recorded`. Evidence destination: [Release And Install Provenance](report.md#release-and-install-provenance).
- [ ] `T-BUG-020-25 - Release validation: generated metadata, source identity, install provenance, and release readiness are current and coherent`. Evidence destination: [Release And Install Provenance](report.md#release-and-install-provenance).
- [ ] `T-BUG-020-26 - Certification: final transition passes only after all behavior, release, finding-accounting, and evidence obligations are complete`. Evidence destination: [Certification Validation](report.md#certification-validation).

Build Quality Gate:

- [ ] A new prospective RED uses the revised final test digest against the known pre-fix blob in isolation before the candidate patch is applied in that lineage; the historical HEAD-restored diagnostic and `RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED` current-source run receive no RED credit; GREEN uses identical test bytes and commands.
- [ ] Every evidence block records its owning phase, exact command, actual exit, claim source, and raw output; no required case is skipped, intercepted, self-validating, or converted into a success-producing bailout.
- [ ] Direct documentation and generated release metadata describe only executed behavior and are written by their canonical owners.
- [ ] `bubbles.validate` remains the only writer of certification fields, completed scope state, and terminal status.

> **Uncertainty Declaration for every unchecked delivery item above**
> **What was attempted:** Planning reconciled one scope, three scenarios, 27
> Test Plan rows, matching DoD items, machine handoff, ownership boundaries,
> and the prospective isolated test-first route; no delivery command was run.
> **What was observed:** Historical evidence records a later HEAD-restored
> diagnostic and a current-source run classified
> `RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED`. Neither is the required revised
> final-test-byte RED, and the candidate source already predates that revision.
> **Why this is uncertain:** Planning does not execute or infer RED, source,
> GREEN, provenance, release, or certification results.
> **What would resolve this:** `bubbles.test` revises and freezes the final
> `test_27` bytes, stages the protected dependency snapshot plus known pre-fix
> fun-mode blob in isolation, and records a causally valid RED before any
> implementation owner applies the candidate patch in that same lineage.

### Sequential Gate And Execution Handoff

Scope 1 is the entire active execution inventory and remains **Not started**.
The immediate next owner is `bubbles.test` for `T-BUG-020-00`: revise and hash
the split-lane regression, then execute those final bytes first against the
known pre-fix fun-mode blob in an isolated lineage. No production source edit is
authorized by this planning round or by either historical diagnostic. Scope
completion and certification remain prohibited until all 27 test rows and the
grouped quality obligations have owner-tagged evidence.
