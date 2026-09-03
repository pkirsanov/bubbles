# BUG-033 Scopes

Related artifacts: [spec.md](spec.md), [design.md](design.md),
[report.md](report.md), and [uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Scope 1 - Complete Check 43 receipt identity.** Preserve the implemented
  facet-1 and facet-2 behavior. Add exact bounded-launcher normalization and
  replace the ambiguous clone prose with the specified terminal verdict.

One scope remains coherent because all three facets modify one atomic Check 43
decision. They use the same classifier, renderer, focused selftest, and
whole-guard selftest. Splitting facet 3 from its safety pins would permit an
acceptance broadening without its refusal bounds.

### New Types And Signatures

- No persisted type, schema, endpoint, dependency, or configuration key changes.
- `strip_wrappers(tokens) -> normalized tokens plus wrapper metadata` gains:
  - `timeout DURATION UNDERLYING...`
  - `gtimeout DURATION UNDERLYING...`
  - the exact `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' SECONDS UNDERLYING...`
- The Check 43 classifier result gains stable verdict metadata for rendering:
  `verdict`, `reason`, identities, normalization source, compatibility facts,
  and effect.
- The existing command remains the external entry point:
  `bash bubbles/scripts/state-transition-guard.sh FEATURE_DIR`.

### Validation Checkpoints

1. Extract and exercise the production Check 43 jq definitions through
   `bubbles/scripts/receipt-identity-selftest.sh`.
2. Exercise the real guard process, isolated tool-call log, exit status, and
   terminal fields through `bubbles/scripts/state-transition-guard-selftest.sh`.
3. Run `bash bubbles/scripts/cli.sh framework-validate` only after both focused
   checkpoints pass.
4. Keep Scope 1 `In Progress` until every facet-3 and terminal-contract row has
   current execution evidence. Historical facet-1 and facet-2 evidence remains
   valid only for the checked items that link to it below.

## Scope Summary

| # | Name | Surfaces | Tests | DoD summary | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Receipt target grouping and wrapper normalization | Check 43 classifier and terminal renderer | Focused production-definition selftest, whole-guard functional regression, framework validation | Preserve facets 1/2; deliver facet 3 and the terminal contract without weakening refusal bounds | In Progress |

## Scope 1 - Receipt Target Grouping And Wrapper Normalization

**Status:** In Progress
**Depends On:** None
**Scope-Kind:** runtime-behavior

### Scope Intent

Classify a substantive receipt collision by the underlying evidence-producing
command. Accept only independently evidenced deterministic siblings. Retain
unsupported launcher grammar as identity-bearing data and expose one stable
accepted or refused terminal verdict.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B033-001 Repeated honest re-runs are not cloned evidence
  Given five receipts identify one validator over specs/alpha
    And four receipts identify the same validator over specs/beta
    And all nine receipts share one substantive output digest
    And every receipt carries distinct execution provenance
  When Check 43 classifies the collision
  Then the group is accepted as deterministic siblings
    And no evidence receipt clone is reported

Scenario: SCN-B033-002 Two identities over one target are still refused
  Given one receipt identifies `npm run lint` over specs/alpha
    And one receipt identifies `npm run test` over specs/alpha
    And both receipts share one substantive output digest
  When Check 43 classifies the collision
  Then an evidence receipt clone is reported

Scenario: SCN-B033-003 Existing transparent wrappers resolve to one command
  Given a receipt records one of these spellings:
    | `node scripts/check-page.mjs alpha` |
    | `env PAGE=alpha node scripts/check-page.mjs alpha` |
    | `zsh -c node scripts/check-page.mjs alpha` |
    | `PAGE=alpha node scripts/check-page.mjs alpha` |
    | `bash -c node scripts/check-page.mjs alpha` |
    | `sh -c node scripts/check-page.mjs alpha` |
  When Check 43 derives the underlying command family
  Then the command family is `node`

Scenario: SCN-B033-004 Existing wrappers do not hide different programs
  Given one receipt records `zsh -c cargo test`
    And another receipt records `env CI=1 npm run lint`
    And both receipts share one substantive output digest
  When Check 43 classifies the collision
  Then an evidence receipt clone is reported
    And the diagnostic preserves the `cargo` and `npm` command families

Scenario: SCN-B033-005 Timeout launchers expose the underlying command
  Given one receipt records `artifact-lint.sh TARGET`
    And another receipt records `timeout 120 artifact-lint.sh TARGET`
    And a third receipt records `gtimeout 120 artifact-lint.sh TARGET`
    And the receipts have compatible exits and independent provenance
    And the receipts share one substantive output digest
  When Check 43 classifies the collision
  Then all receipts identify `artifact-lint.sh TARGET`
    And no clone is reported solely because of either launcher

Scenario: SCN-B033-006 The exact portable alarm launcher exposes the underlying command
  Given one receipt records `artifact-lint.sh TARGET`
    And another receipt records `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 artifact-lint.sh TARGET`
    And both receipts have compatible exits and independent provenance
    And both receipts share one substantive output digest
  When Check 43 classifies the collision
  Then both receipts identify `artifact-lint.sh TARGET`
    And no clone is reported solely because of the portable launcher

Scenario: SCN-B033-007 Launcher removal composes with existing wrappers
  Given a supported launcher surrounds `env PAGE=alpha zsh -c node scripts/check-page.mjs alpha`
    And shell, environment, assignment, and launcher prefixes occur in every supported order from design.md
  When Check 43 derives the underlying command family and identity
  Then every complete composition exposes command family `node`
    And every complete composition retains `scripts/check-page.mjs`

Scenario: SCN-B033-008 Arbitrary Perl programs remain part of command identity
  Given one receipt records `/usr/bin/perl -e 'print 1' 120 artifact-lint.sh TARGET`
    And another receipt records `artifact-lint.sh TARGET`
    And both receipts share one substantive output digest
  When Check 43 derives their command identities
  Then the arbitrary Perl program remains visible in its identity
    And the receipts do not become equivalent through launcher normalization

Scenario: SCN-B033-009 Malformed launcher grammar remains unchanged
  Given a receipt records one of these unsupported spellings:
    | `timeout` |
    | `timeout 120` |
    | `gtimeout 120` |
    | `timeout --preserve-status 120 artifact-lint.sh TARGET` |
    | `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120` |
    | `/usr/bin/perl -e 'alarm shift @ARGV; print @ARGV' 120 artifact-lint.sh TARGET` |
  When Check 43 derives its command identity
  Then the recorded launcher prefix remains part of the identity
    And Check 43 does not infer an underlying command

Scenario: SCN-B033-010 Launchers do not hide different underlying commands
  Given one receipt records a supported launcher around `artifact-lint.sh TARGET`
    And another receipt records the same launcher kind around `state-transition-guard.sh TARGET`
    And both receipts share one substantive output digest
  When Check 43 classifies the collision for timeout, gtimeout, and portable Perl alarm launchers
  Then every collision reports an evidence receipt clone
    And every diagnostic preserves both underlying command identities

Scenario: SCN-B033-011 Exit-result differences remain incompatible
  Given one receipt records `timeout 120 artifact-lint.sh specs/alpha` with exit result 0
    And another receipt records `gtimeout 120 artifact-lint.sh specs/beta` with exit result 1
    And both receipts share one substantive output digest
    And both receipts carry independent provenance
  When Check 43 classifies the collision
  Then the group is not accepted as deterministic siblings
    And an evidence receipt clone is reported with both exit results
```

### Scenario Obligation Matrix

All scenarios change a shared guard consumer. Each scenario requires focused
parity against extracted production definitions. Each also requires a current
consumer-surface assertion through the real guard.

| Scenario | Behavior traits | Required proof | Risk tier | Negative control |
| --- | --- | --- | --- | --- |
| SCN-B033-001 | pure validation, shared consumer | Focused sibling classification plus accepted whole-guard verdict | Medium | Repeat or remove provenance and require refusal |
| SCN-B033-002 | pure validation, shared consumer, negative path | Focused clone classification plus refused whole-guard verdict | Medium | Make both command identities equal and require the mismatch to disappear |
| SCN-B033-003 | pure validation, shared consumer | Production-definition family assertions plus whole-guard acceptance | Medium | Replace one wrapped `node` command with `cargo` and require incompatibility |
| SCN-B033-004 | pure validation, shared consumer, negative path | Production-definition identity assertions plus both visible guard identities | Medium | Make both underlying programs equal and require the mismatch to disappear |
| SCN-B033-005 | pure validation, shared consumer | Direct, timeout, and gtimeout parity plus accepted whole-guard verdict | High | Add a timeout option and require identity to remain launcher-bearing |
| SCN-B033-006 | pure validation, shared consumer | Direct and exact Perl launcher parity plus accepted whole-guard verdict | High | Change the Perl program body and require identity to remain Perl-bearing |
| SCN-B033-007 | pure validation, shared consumer | Every supported composition produces one family and current guard acceptance | High | Insert unsupported launcher grammar and require normalization to stop there |
| SCN-B033-008 | pure validation, shared consumer, negative path | Arbitrary Perl identity retention plus refused whole-guard diagnostic | High | Replace the body with the exact alarm program and require equivalence |
| SCN-B033-009 | pure validation, shared consumer, negative path | Every malformed form remains unchanged plus representative guard refusals | High | Complete each accepted grammar and require bounded normalization |
| SCN-B033-010 | pure validation, shared consumer, negative path | Distinct identities for every launcher plus refused whole-guard diagnostics | High | Use one underlying command on both receipts and require command parity |
| SCN-B033-011 | pure validation, shared consumer, negative path | Independent exit comparison plus refused whole-guard exit diagnostic | High | Equalize both exit codes and require the exit mismatch to disappear |

**Implementation references:**
`bubbles/scripts/state-transition-guard.sh#Check-43` owns every asserted result.
`bubbles/scripts/receipt-identity-selftest.sh` extracts that production
definition for focused proof. `bubbles/scripts/state-transition-guard-selftest.sh`
proves the current consumer surface.

### Implementation Plan

1. Extend only the existing Check 43 `strip_wrappers` recursion in
   `bubbles/scripts/state-transition-guard.sh`.
   - Recognize `timeout` and `gtimeout` only when a non-option duration and a
     non-empty underlying command are present.
   - Recognize only the exact portable Perl token prefix defined in
     [design.md](design.md), followed by seconds and a non-empty command.
   - Consume a strict nonempty prefix on every recognized branch, then recurse.
   - Keep every unsupported or incomplete spelling unchanged.
   - Treat recorded command text as inert data. Never evaluate or execute it.
2. Preserve facet-1 target grouping, facet-2 recursive wrapper handling,
   receipt exit codes, category checks, provenance checks, and empty stdout.
3. Make the Check 43 classifier return structured compatibility details.
   Render the ordered ASCII terminal fields from that result without
   recomputing classification.
4. Preserve complete identities. Escape control characters and remove the
   legacy truncation from the Check 43 diagnostic path.
5. Add scenario-labeled focused assertions to
   `bubbles/scripts/receipt-identity-selftest.sh`. Continue extracting the
   production jq definition and fail with exit 2 when extraction fails.
6. Add scenario-labeled whole-guard fixtures to
   `bubbles/scripts/state-transition-guard-selftest.sh`. Use an isolated
   tool-call log and assert the real process exit and terminal output.

### Change Boundary

#### Allowed Behavior Files

- The Check 43 classifier and renderer inside
  `bubbles/scripts/state-transition-guard.sh`.
- Focused assertions in `bubbles/scripts/receipt-identity-selftest.sh`.
- Whole-guard fixtures and assertions in
  `bubbles/scripts/state-transition-guard-selftest.sh`.
- The single migrated Check 43 assertion in
  `bubbles/scripts/evidence-admission-hardening-selftest.sh`. Ratified under
  RG-003: this file is a first-party consumer of the refusal vocabulary this
  packet retires, so migrating it is intrinsic to the contract change rather
  than collateral cleanup. The widening authorizes only the assertion that
  named the retired `Evidence receipt CLONE` string.

#### Allowed Planning Files

- This BUG-033 packet's plan-owned artifacts.

#### Authorized Framework-Stats Refresh

This boundary authorizes `bubbles.docs` to run the canonical framework-stats
generator only to clear `F-B033-T23-STATS-FRESHNESS`. The invocation may write
only these six explicit paths.

- `docs/generated/framework-stats.json`
- `docs/generated/framework-stats.md`
- `docs/guides/FRAMEWORK_CONCEPTS.md`
- `README.md`
- `docs/CHEATSHEET.md`
- `docs/its-not-rocket-appliances.html`

The current source revision and worktree declare 32 phases. The checked-in
generated statistics declare 30 phases, so the stale state exists at `HEAD`.
The recorded diagnostic predicts byte changes in both generated statistics
files, `docs/CHEATSHEET.md`, and `docs/its-not-rocket-appliances.html`.
The generator also writes `docs/guides/FRAMEWORK_CONCEPTS.md` and `README.md`.
Those two targets must remain byte-stable for the current inputs.

No broader generated path or documentation glob is authorized. This boundary
does not authorize editing `bubbles/scripts/generate-framework-stats.sh`.

#### Authorized Release-Manifest Reconciliation

Planning authorizes `bubbles/release-manifest.json` as the only additional
generated path for `F-B033-T23-RELEASE-MANIFEST-FRESHNESS`. This correction is
required solely because the authorized framework-stats refresh changed the
managed checksums of `docs/generated/framework-stats.json`,
`docs/generated/framework-stats.md`, `docs/CHEATSHEET.md`, and
`docs/its-not-rocket-appliances.html`.

`Release manifest freshness` is the validator's final registered check. The
next owner is `bubbles.docs`. That owner must run the canonical release-manifest
generator and prove that the resulting manifest diff is bounded to the required
checksum reconciliation. The generator source at
`bubbles/scripts/generate-release-manifest.sh` remains excluded. No unrelated
source path or generated output is added to this boundary.

`F-B033-DIAG-EMPTY-OUTPUT-CAPTURE` remains an independent finding owned by
`bubbles.bug`. `bubbles/scripts/evidence-capture.sh` remains excluded from
BUG-033.

#### Excluded Surfaces

- Receipt schemas, evidence category mapping, provenance derivation, and the
  empty-stdout exemption.
- Every guard check other than Check 43.
- Dependencies, configuration, deployment, release propagation, and installed
  downstream copies.
- Broad script refactors and certification fields.
- Any selftest that the derived consumer scan below does NOT return. Membership
  in this boundary is decided by that scan, never by resemblance to a file that
  is already in it.

Collateral cleanup requires a separately authorized plan change. The
implementation diff must show zero changes in excluded file families.

### Consumer And Shared-Infrastructure Impact Sweep

Check 43 is a high-fan-out shared guard surface even though no route, path, or
public identifier is renamed.

- **Direct consumer:** `bash bubbles/scripts/state-transition-guard.sh FEATURE_DIR`.
- **Focused parity consumer:** production-definition extraction in
  `bubbles/scripts/receipt-identity-selftest.sh`.
- **Current surface canary:** whole-process execution in
  `bubbles/scripts/state-transition-guard-selftest.sh`.
- **Framework closure:** `bash bubbles/scripts/cli.sh framework-validate`.
- **Propagation boundary:** downstream repositories receive a later framework
  upgrade. This scope must not patch their installed copies.
- **Compatibility pins:** retain BUG-007 empty-output behavior, BUG-032
  provenance behavior, facet-1 target grouping, and facet-2 recursion.

#### Affected Consumer Enumeration

The Consumer Impact Sweep covers every known first-party execution and
propagation surface affected by the Check 43 identity or diagnostic contract:

1. State-transition guard callers that invoke
  `bash bubbles/scripts/state-transition-guard.sh FEATURE_DIR`.
2. Focused production-definition extraction in
  `bubbles/scripts/receipt-identity-selftest.sh`.
3. Real-process guard coverage in
  `bubbles/scripts/state-transition-guard-selftest.sh`.
4. The refusal-vocabulary assertion in
  `bubbles/scripts/evidence-admission-hardening-selftest.sh`.
5. Source-repository closure through
  `bash bubbles/scripts/cli.sh framework-validate`.
6. Downstream installs that consume the released guard through the standard
  framework upgrade path; installed copies remain excluded from direct edits.

The standard interface categories are explicitly classified: this CLI-only
contract has no navigation, breadcrumb, redirect, API client, generated client,
or deep link consumer. Its stale-reference scan covers guard callers, executable
selftest assertions, framework validation wiring, and downstream install
propagation.

Historical records returned by the derived scan remain byte-identical. They
are evidence records, not live consumers to migrate.

#### Derived Consumer Scan (RG-002, mandatory before any Check 43 field change)

The four named consumers above are a starting point, NOT the enumeration. They
were selected by authorship — the surfaces written alongside Check 43 — and
that is exactly how `bubbles/scripts/evidence-admission-hardening-selftest.sh`
was missed: it asserts Check 43 refusal text but was authored under IMP-102, so
it belonged to none of the four categories and the field change shipped without
migrating it. A consumer is defined by what it DEPENDS ON, not by who wrote it.

The authoritative enumeration is therefore derived, not maintained by hand. Run
it before changing any Check 43 emitted literal:

```bash
c43_literals() {  # $1 = git rev, or empty for the working tree
  local src
  if [ -n "$1" ]; then
    src="$(git show "$1:bubbles/scripts/state-transition-guard.sh")"
  else
    src="$(cat bubbles/scripts/state-transition-guard.sh)"
  fi
  printf '%s\n' "$src" | grep -oE \
    'Evidence receipt [A-Z]+|Check 43 [a-z][a-z ]+|check=43 verdict=[A-Z]+|reason=[a-z][a-z-]+' \
    | sort -u
}

# Every literal the change RETIRES (present pre-change, absent post-change):
comm -23 <(c43_literals HEAD) <(c43_literals "") | while IFS= read -r tok; do
  [ -n "$tok" ] || continue
  echo "--- retired literal: $tok ---"
  git grep -lF -- "$tok" HEAD -- \
    ':(exclude)bubbles/scripts/state-transition-guard.sh'
done
```

Two properties make this catch what the hand list missed:

1. **The vocabulary is read out of the guard, not remembered.** Adding a new
   `reason=` value or renaming a refusal headline extends the scanned set
   automatically.
2. **It scans the PRE-change revision for the retired literal.** A retired
   string no longer exists in the new guard, so grepping only the working tree
   finds nothing and gives false assurance. `git grep ... HEAD` is what surfaces
   the consumers that are about to break.

Every path the scan returns MUST be classified, in `report.md`, into exactly one
of two dispositions. There is no third bucket and no silent omission:

- **Live executable consumer** — the literal appears as an assertion argument in
  an executable surface (`*.sh`, test fixtures). It MUST be migrated to the new
  vocabulary under this packet, and the migrated assertion MUST be proven
  non-vacuous by mutation. If the path is outside `workBoundary.allowedPaths`,
  route the boundary decision to `bubbles.plan` before editing.
- **Historical record** — the literal appears as captured output or narrative in
  `BUGS.md`, a `report.md`, or a `bug.md`. It MUST be left byte-identical.
  Rewriting recorded evidence to match current behavior is fabrication, not
  migration.

Run against HEAD, this scan returns `BUGS.md`,
`bubbles/scripts/evidence-admission-hardening-selftest.sh`,
`bubbles/scripts/state-transition-guard-selftest.sh`,
`bugs/BUG-032-planning-maturity-guard-false-positives/report.md`, and
`bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/bug.md` — two
live consumers to migrate and three historical records to leave alone. It
returns the file the hand-maintained enumeration missed, which is the property
that closes RG-002.

### Rollback And Restore

Rollback restores only the facet-3 launcher branches and the structured Check
43 renderer. It retains facet-1 target grouping and facet-2 recursive wrapper
normalization. After rollback, run both named selftests. Keep BUG-033
`in_progress`. Rollback contains the change but does not certify the bug.

### Portability Contract

- The implementation classifies recorded `timeout` and `gtimeout` text. It does
  not require either binary to exist on the test host.
- The exact Perl launcher is tokenized as recorded data. The classifier does
  not invoke Perl while deriving identity.
- The test commands use `/usr/bin/perl` only as a bounded process runner. This
  command exists on the supported macOS and Linux validation hosts named by the
  source repository policy.
- jq logic must produce identical classifications on GNU/Linux and macOS.

### Test Plan

The focused command is:

`bash bubbles/scripts/evidence-capture.sh --label "BUG-033 focused receipt identity" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh`

The whole-guard command is:

`bash bubbles/scripts/evidence-capture.sh --label "BUG-033 whole guard" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/state-transition-guard-selftest.sh`

| ID | Scenario | Category | File / assertion | Expected result | Live system |
| --- | --- | --- | --- | --- | --- |
| T01 | SCN-B033-001 | unit | `bubbles/scripts/receipt-identity-selftest.sh` facet-1 acceptance | Nine re-runs over two targets form one sibling group and zero clones | No |
| T02 | SCN-B033-002 | unit | `bubbles/scripts/receipt-identity-selftest.sh` facet-1 adversarial bound | Two identities over one target produce one clone | No |
| T03 | SCN-B033-003 | unit | `bubbles/scripts/receipt-identity-selftest.sh` facet-2 family probe | Six direct and wrapped spellings derive family `node` | No |
| T04 | SCN-B033-003 | unit | `bubbles/scripts/receipt-identity-selftest.sh` facet-2 acceptance | Wrapper spelling alone produces no clone | No |
| T05 | SCN-B033-004 | unit | `bubbles/scripts/receipt-identity-selftest.sh` facet-2 adversarial bound | Wrapped cargo and npm remain distinct | No |
| T06 | SCN-B033-001, SCN-B033-002 | unit | `bubbles/scripts/receipt-identity-selftest.sh` BUG-007 and BUG-032 pins | Empty stdout and provenance bounds remain unchanged | No |
| T07 | SCN-B033-001 through SCN-B033-004 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh` historical whole-guard cases | The real guard accepts honest cases and refuses both adversarial cases | Yes |
| T08 | SCN-B033-005 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-005` | Direct, timeout, and gtimeout derive one identity | No |
| T09 | SCN-B033-005 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-005` | The real guard emits accepted deterministic siblings for both timeout launchers | Yes |
| T10 | SCN-B033-006 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-006` | Only the exact portable alarm spelling matches the direct identity | No |
| T11 | SCN-B033-006 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-006` | The real guard accepts the exact portable launcher without clone wording | Yes |
| T12 | SCN-B033-007 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-007` | Every supported wrapper order exposes `node scripts/check-page.mjs` | No |
| T13 | SCN-B033-007 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-007` | One composition per launcher kind is accepted by the real guard | Yes |
| T14 | SCN-B033-008 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-008` | Arbitrary Perl remains visible and differs from direct invocation | No |
| T15 | SCN-B033-008 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-008` | Refusal reports recorded identity and unchanged normalization | Yes |
| T16 | SCN-B033-009 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-009` | Every listed incomplete, option-bearing, and near-match form remains unchanged | No |
| T17 | SCN-B033-009 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-009` | Timeout and Perl malformed collisions retain their launcher prefixes | Yes |
| T18 | SCN-B033-010 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-010` | Every launcher exposes distinct artifact-lint and guard identities | No |
| T19 | SCN-B033-010 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-010` | Every launcher kind refuses and emits both complete identities | Yes |
| T20 | SCN-B033-011 | unit | `bubbles/scripts/receipt-identity-selftest.sh#SCN-B033-011` | Equal normalized commands with exits 0 and 1 fail sibling compatibility | No |
| T21 | SCN-B033-011 | functional regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-011` | The real guard refuses with exit reason and both exit values | Yes |
| T22 | SCN-B033-001, SCN-B033-008, SCN-B033-010, SCN-B033-011 | functional regression | Whole-guard terminal contract assertions | Ordered fields, effect, complete identities, escaping, narrow wrapping, and ANSI-free semantics match design | Yes |
| T23 | SCN-B033-001 through SCN-B033-011 | regression | `bash bubbles/scripts/cli.sh framework-validate` | The complete source-repository guard and selftest suite passes | Yes |
| T24 | SCN-B033-002 | e2e-api regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-002` | Regression: the real state-transition guard process refuses two command identities over one target with both identities and `effect=TRANSITION_BLOCKED` | Yes |
| T25 | SCN-B033-003 | e2e-api regression | `bubbles/scripts/state-transition-guard-selftest.sh#SCN-B033-003` | Regression: the real state-transition guard process resolves every direct, shell, `env`, and assignment spelling to `node` without a wrapper-only clone allegation | Yes |
| T26 | SCN-B033-001 through SCN-B033-011 | e2e-api regression | `bubbles/scripts/state-transition-guard-selftest.sh` | Broader E2E regression: the complete real-process Check 43 scenario family passes with no internal mocks | Yes |

Every row is a persistent regression. Rows T08 through T22 must use their exact
scenario IDs in emitted selftest labels. A wrong launcher prefix, changed
underlying command, or changed exit must make its owning assertion fail.

### Build Quality Gate

Run these commands in order from `/Users/pkirsanov/Projects/bubbles`:

1. `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 focused receipt identity" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 300 bash bubbles/scripts/receipt-identity-selftest.sh`
2. `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 whole guard" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 600 bash bubbles/scripts/state-transition-guard-selftest.sh`
3. `bash bubbles/scripts/evidence-capture.sh --label "BUG-033 framework validate" -- /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 1200 bash bubbles/scripts/cli.sh framework-validate`
4. `git diff --check`

The first failure stops the sequence. No command output may be filtered.

### Definition of Done - Tiered Validation

#### Preserved Historical Facet-1 And Facet-2 Evidence

These checked items retain their existing report anchors. They do not prove
facet 3 or the reconciled terminal contract.

- [x] T01: Facet 1 measures target distinctness per command identity.
      Evidence: [Facet 1](report.md#facet-1)
- [x] T02: Facet 1 still refuses two identities over one target.
      Evidence: [Bounds](report.md#bounds)
- [x] T03: Existing transparent wrappers resolve to one command family, `node`.
      Evidence: [Facet 2](report.md#facet-2)
- [x] T04: Facet 2 accepts equivalent wrapper spellings.
      Evidence: [Green](report.md#green)
- [x] T05: Facet 2 still exposes cargo and npm behind wrappers.
      Evidence: [Bounds](report.md#bounds)
- [x] T06: BUG-007 empty-output and BUG-032 provenance pins survived facets 1 and 2.
      Evidence: [Regression](report.md#regression)
- [x] T07: The historical whole-guard regression covered SCN-B033-001 through SCN-B033-004.
      Evidence: [Regression](report.md#regression)

#### Facet-3 Scenario Tests

The declaration below applies to the unchecked T23 item.

> **Uncertainty Declaration**
> **What was attempted:** The focused receipt suite, BUG-033-only real-guard
> suite, evidence-admission consumer, and packet integrity checks passed. One
> canonical full `framework-validate` was then launched under evidence capture
> with a 7200-second maximum.
> **What was observed:** The full command exited `1` before suite execution
> because another framework validator held the machine-wide lock. No second
> run was started. The conditional `release-check` was not eligible.
> **Why this is uncertain:** Lock refusal proves neither a current framework
> pass nor a current framework test failure, so T23 has no suite verdict.
> **What would resolve this:** After the active validator releases the lock,
> `bubbles.test` executes one canonical full validation and, only on exit `0`,
> one canonical release check.

- [x] T08: Focused SCN-B033-005 timeout and gtimeout identity parity passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T09: Whole-guard SCN-B033-005 accepted verdict passes. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T10: Focused SCN-B033-006 exact portable alarm identity parity passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T11: Whole-guard SCN-B033-006 accepted verdict passes. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T12: Focused SCN-B033-007 composed-wrapper matrix passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T13: Whole-guard SCN-B033-007 launcher composition fixtures pass. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T14: Focused SCN-B033-008 arbitrary Perl identity retention passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T15: Whole-guard SCN-B033-008 recorded-identity refusal passes. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T16: Focused SCN-B033-009 malformed grammar matrix passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T17: Whole-guard SCN-B033-009 malformed timeout and Perl refusals pass. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T18: Focused SCN-B033-010 distinct-command launcher matrix passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T19: Whole-guard SCN-B033-010 distinct-command diagnostics pass. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T20: Focused SCN-B033-011 independent exit comparison passes. → Evidence: [Facet 3 focused green evidence](report.md#facet-3-focused-green-evidence)
- [x] T21: Whole-guard SCN-B033-011 exit-result refusal passes. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [x] T22: Whole-guard terminal diagnostics satisfy field order, reason,
  effect, complete identity, control escaping, narrow wrapping, and
  ANSI-free semantics. → Evidence: [Facet 3 whole-guard evidence](report.md#facet-3-whole-guard-evidence)
- [ ] T23: The canonical framework validation suite passes after the focused
      and whole-guard checks.
  Attempt evidence: [Current-Tree Test Verification](report.md#current-tree-test-verification-2026-08-26)
- [x] Scenario-specific E2E regression tests for every new/changed/fixed behavior pass; T24 maps SCN-B033-002 and proves through the real state-transition guard process that two command identities over one target emit `reason=command-identity-mismatch`, both identities, and `effect=TRANSITION_BLOCKED`.
  → Evidence: [Current Test Phase T24-T26 Evidence](report.md#current-test-phase-t24-t26-evidence)
- [x] T25: Scenario-specific regression E2E for SCN-B033-003 executes the real
  state-transition guard process and proves that direct, shell, `env`, and
  assignment spellings resolve to command family `node` without a clone
  allegation caused solely by wrapper spelling.
  → Evidence: [Current Test Phase T24-T26 Evidence](report.md#current-test-phase-t24-t26-evidence)
- [x] Broader E2E regression suite passes; T26 executes the real
  state-transition guard process for SCN-B033-001 through SCN-B033-011
  without internal mocks.
  → Evidence: [Current Test Phase T24-T26 Evidence](report.md#current-test-phase-t24-t26-evidence)

#### Implementation And Containment

The declaration below applies individually to every unchecked item in this
subsection.

> **Uncertainty Declaration**
> **What was attempted:** The implementation, boundary, consumer, rollback, and portability work was planned.
> **What was observed:** This planning run changed no source or test behavior.
> **Why this is uncertain:** The required implementation and runtime proof do not exist in this planning result.
> **What would resolve this:** Implement Scope 1, execute its checks, and attach current evidence to each item.

- [x] Exact supported launchers normalize recursively without executing
  recorded command text. → Evidence: [Current Implement Focused Proof](report.md#current-implement-focused-proof) and [Current Implement Real-Guard Canary](report.md#current-implement-real-guard-canary)
- [x] Unsupported launcher grammar remains unchanged and visible. → Evidence: [Current Implement Focused Proof](report.md#current-implement-focused-proof) and [Current Implement Real-Guard Canary](report.md#current-implement-real-guard-canary)
- [x] Command, target, provenance, category, and exit compatibility remain
  independent classification dimensions. → Evidence: [Current Implement Focused Proof](report.md#current-implement-focused-proof) and [Current Implement Real-Guard Canary](report.md#current-implement-real-guard-canary)
- [x] The terminal renderer emits one stable accepted or refused verdict and
  cannot weaken `effect=TRANSITION_BLOCKED`. → Evidence: [Current Implement Real-Guard Canary](report.md#current-implement-real-guard-canary)
- [x] The consumer impact sweep confirms no stale first-party diagnostic
      consumer after any field change. → Evidence: [Consumer Impact Sweep](report.md#consumer-impact-sweep)
- [x] The consumer impact sweep is completed for every affected consumer enumerated above and zero stale first-party references remain. → Evidence: [Current Derived Consumer Closure](report.md#current-derived-consumer-closure) and [Current Migrated Consumer Proof](report.md#current-migrated-consumer-proof)
- [x] The shared-infrastructure canary proves the real guard independently of
  focused extraction. → Evidence: [Current Implement Real-Guard Canary](report.md#current-implement-real-guard-canary)
- [x] Rollback restores facet-3 and renderer changes while retaining facets 1
  and 2, then both named selftests pass. → Evidence: [Isolated Rollback And Restore Proof](report.md#isolated-rollback-and-restore-proof)
- [x] The final diff stays inside the declared change boundary. → Evidence: [Current Code-Only Snapshot](report.md#current-code-only-snapshot) and [Current Work-Boundary Proof](report.md#current-work-boundary-proof)
- [x] Change Boundary is respected and zero excluded file families were changed. → Evidence: [Current Code-Only Snapshot](report.md#current-code-only-snapshot) and [Current Work-Boundary Proof](report.md#current-work-boundary-proof)
- [ ] Portability checks prove identical recorded-command classification on
      supported macOS and Linux validation hosts.
  Uncertainty: [Portability Observation And Uncertainty](report.md#portability-observation-and-uncertainty) records macOS execution only; no Linux environment executed in this phase.

Scope 1 remains `In Progress` while any unchecked item remains. Only execution
agents may attach current facet-3 evidence and change those checkboxes.
