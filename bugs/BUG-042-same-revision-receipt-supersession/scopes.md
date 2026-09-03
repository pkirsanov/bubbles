# Scopes: BUG-042 Same-Revision Receipt Supersession

## Execution Outline

### Phase Order

1. **Scope 1 - Deterministic append-only proof-chain selection:** extend the
  existing resolver and its focused persistent selftest as one vertical change.
  Prove resolver, consumer, compatibility, rollback, and no-bypass behavior.

### New Types And Signatures

- Resolver-derived `LedgerIdentity { appendOrdinal, rowSha256 }`.
  Receipt schemas remain unchanged.
- Resolver-derived `SelectedChain { chainId, scenarioId, sourceRevision,
  testIdentity, negativeControl, red, implement, green }`.
- Closed `ReceiptDisposition`: `SELECTED | SUPERSEDED | UNRESOLVED | EXCLUDED`.
- Closed `selectionStatus`: `NO_COMPLETE_CHAIN | SELECTED |
  SELECTED_WITH_UNRESOLVED | ORDER_REFUSED`.
- New refusal codes: `SCS-CHAIN-PARTIAL` and
  `SCS-APPEND-ORDER-CONFLICT`.
- Additive per-scenario JSON fields: `selectionStatus`, `selectedChain`, and
  `receiptDispositions`. Drift-only output remains byte-compatible.
- No receipt-schema version, CLI flag, environment variable, network API,
  database, deployment, or UI contract changes.

### Validation Checkpoints

- **Checkpoint 0, external base prerequisite:** import only the exact two-path
  byte delta from existing commit `130691932e815c622ab9601195c8eba0c41c6b90`
  as uncommitted working-tree changes. Require the fixed `guard-lib.sh` blob,
  the exact single-entry manifest substitution with no other manifest diff,
  and a clean timeout selftest result before evaluating BUG-042.
- **Checkpoint 1, persistent RED:** each planned correction and conflict test
  must fail against the pre-fix resolver for the intended behavioral reason.
- **Checkpoint 2, focused GREEN:** the same focused cases must pass through
  `scenario-state-resolve-selftest.sh` after the resolver and registry change.
- **Checkpoint 3, consumer boundary:** transition-level checks must accept a
  superseded historical row and reject a current unresolved row.
- **Checkpoint 4, compatibility and rollback:** BUG-034 drift bytes, v1-v3
  receipts, no-bypass arguments, snapshot protection, and rollback receipt
  identity/count behavior must remain intact.
- **Checkpoint 5, repository validation:** planning gates, the source framework
  validation suite, and release readiness must pass before certification is
  requested.

## Plan Inventory

| # | Scope | Depends On | Surfaces | Primary tests | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Deterministic append-only proof-chain selection | None | Resolver, state registry, focused selftest, transition consumer test | 18 focused matrix cases plus consumer and repository checks | Not started |

## Planning Context

- Requirements: [spec.md](spec.md)
- Approved technical contract: [design.md](design.md)
- Execution evidence: [report.md](report.md)
- Human acceptance: [uservalidation.md](uservalidation.md)
- Scope count: one vertical repair inside the existing scenario-outcome
  derivation capability.
- Impacted surfaces: resolver logic, state vocabulary, focused shell selftest,
  phase-coordinator JSON consumption, and transition-guard text consumption.
- Unchanged surfaces: receipt schema, receipt writer, network APIs, UI,
  databases, deployment, and certification ownership.

## Scope 1: Deterministic append-only proof-chain selection

**Status:** [ ] Not started

**Scope-Kind:** `runtime-behavior`

**Depends On:** None

**Owner:** `bubbles.implement`

**Approved design source:** `design.md` defines the complete selection,
disposition, compatibility, security, migration, and rollback contract.

### Gherkin Scenarios (Regression Tests)

```gherkin
Feature: Same-revision receipt replacement preserves append-only evidence

  Scenario: SCN-B042-001 - A later coherent chain supersedes substituted-test history
    Given a failing RED receipt for test identity A
    And a later IMPLEMENT receipt
    And an older GREEN receipt for test identity B
    And a newer GREEN receipt for test identity A
    When scenario state is resolved at the same source revision
    Then the latest complete chain uses test identity A
    And SCS-TEST-SUBSTITUTED remains visible as SUPERSEDED
    And the historical row does not block the resolver consumer

  Scenario: SCN-B042-002 - A later coherent chain supersedes substituted-control history
    Given a failing RED receipt for negative control A
    And a later IMPLEMENT receipt
    And an older GREEN receipt for negative control B
    And a newer GREEN receipt for negative control A
    When scenario state is resolved at the same source revision
    Then the latest complete chain uses negative control A
    And SCS-CONTROL-SUBSTITUTED remains visible as SUPERSEDED
    And the historical row does not block certification eligibility

  Scenario: SCN-B042-003 - A later failing RED supersedes exit-zero RED history
    Given an old RED receipt with exit code zero
    And a newer RED receipt with a non-zero exit code
    And later matching IMPLEMENT and GREEN receipts
    When scenario state is resolved at the same source revision
    Then the newer RED anchors the authoritative chain
    And SCS-RED-NOT-FAILING remains visible as SUPERSEDED
    And the old RED receipt does not block certification eligibility

  Scenario: SCN-B042-004 - Physical append order is deterministic and conflict-safe
    Given two candidate receipts with identical timestamps
    And their physical JSONL append order is unique
    When scenario state is resolved
    Then append ordinal determines precedence
    And byte-identical rows retain distinct ordinals
    And repeated execution returns byte-identical selection output
    But a non-unique model ordinal is refused without a tie breaker

  Scenario: SCN-B042-005 - A prior valid chain remains visible beside an unresolved later campaign
    Given a complete valid RED-to-GREEN chain
    And a later invalid or incomplete same-group campaign
    When scenario state is resolved
    Then the prior selected chain remains visible in output
    And the later campaign is UNRESOLVED
    And its original refusal remains blocking
    But a still-newer coherent chain may supersede an eligible historical conflict
```

### External Base Prerequisite Import

Commit `130691932e815c622ab9601195c8eba0c41c6b90` already exists on the
local `origin/main` ref. It is not an ancestor of this worktree's pinned
revision `a8e870039573a4a9c84da5a039446d1139a1b968`. It repairs portable
progress-log size parsing in `bubbles_run_with_progress_timeout`. It does not
implement or alter same-revision receipt supersession.

BUG-042 needs those existing base bytes because repository regression invokes
`guard-lib-timeout-selftest.sh`. The pre-fix BSD `wc -c` rendering returns
`rc=2` before the idle or absolute deadline can be evaluated.

The prerequisite commit has exactly these two path deltas. File modes remain
unchanged.

| Path | Commit parent blob | Commit fixed blob | Closed byte delta |
| --- | --- | --- | --- |
| `bubbles/scripts/guard-lib.sh` | `fd037b38afd892dfe642aca4a859189900bd5609` | `e8e404a5c157c94e822a07dcee1076d1239d7a8b` | Insert the exact six lines below after the `current_size="$(wc -c ...)"` assignment. |
| `bubbles/release-manifest.json` | `b98809a6de827d3ba8fe3bd6543c6b208fa7ec42` | `e599f7d92582fd8b08615b2669b87940dc0397d5` | Replace only the `guard-lib.sh` SHA-256 value from `0c5f9cfb8d61eb59e37f0d98de02cce8936a59800b9fc6e6a3fb01e9d7c0750c` to `c27cad8f23ec9dafb3049fe21b9be3b95c9f973fd70e094293752b2d99ae787c`. |

The manifest blob IDs identify the inspected source commit. They are not
whole-file preconditions for this worktree. Its clean manifest is blob
`429bb7ab75c636ccd94923264f2b5daa84d2f081` and contains unrelated branch
content. Its line 222 carries the exact old `guard-lib.sh` SHA-256 above.

Exact authorized `guard-lib.sh` insertion:

```bash
    # BSD `wc` right-aligns its count in a fixed-width field ("      12"); GNU
    # does not, and command substitution strips only the TRAILING newline. The
    # raw capture therefore failed `^[0-9]+$` on the first poll of every BSD
    # host, returning 2 before either deadline was ever evaluated. Normalize
    # before the numeric test; an unreadable log still yields "" and fails loud.
    current_size="${current_size//[[:space:]]/}"
```

The implementation owner must first require `guard-lib.sh` to match parent
blob `fd037b38afd892dfe642aca4a859189900bd5609`. It must also require the
manifest to remain clean at blob `429bb7ab75c636ccd94923264f2b5daa84d2f081`.
The manifest entry must carry the exact old SHA-256. Any mismatch refuses the
import.

The implementation owner then uses an IDE `apply_patch` edit to apply only the
displayed source insertion and single manifest hash replacement. It must not
cherry-pick, merge, check out, or restore the commit. It must not create a
prerequisite-only commit. After editing, `guard-lib.sh` must hash to fixed blob
`e8e404a5c157c94e822a07dcee1076d1239d7a8b`. A zero-context manifest diff must
contain only the one removed hash line and one added hash line recorded above.

`bubbles/release-manifest.json` remains excluded from BUG-042 authorship. Its
only permitted working-tree delta is the exact one-line upstream hash
replacement coupled to the exact source insertion. No manifest regeneration
or unrelated hash update is permitted. Apply the bytes only in this canonical
source worktree. Do not install or copy them to a downstream repository.

The focused prerequisite proof is exactly:

```bash
/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 \
  /opt/homebrew/bin/bash bubbles/scripts/guard-lib-timeout-selftest.sh
```

It must exit `0`, print ten `PASS` case lines, print zero `FAIL` case lines,
and end with `guard-lib timeout selftest: OK (10 cases)`. This check proves only
the imported timeout normalization. It does not prove BUG-042, framework
validation, or release readiness.

### Implementation Plan

  1. Import and verify the exact external base prerequisite above without
    committing it separately. Stop if the source blob identity differs, the
    manifest has any other delta, or the focused timeout selftest misses its
    exact exit and output contract.
  2. Add all `B042-T01` through `B042-T18` blocks to
   `bubbles/scripts/scenario-state-resolve-selftest.sh` before changing the
   resolver. Capture the expected defect RED and current-protection results.
  3. Snapshot the initial byte length of one regular JSONL ledger. Read that
   exact prefix once and reject replacement, truncation, or a short read with
   runtime exit 2.
  4. Enumerate every physical record before admission. Derive a one-based append
   ordinal and SHA-256 over the exact record bytes without the newline.
  5. Preserve blank, malformed, non-object, and unbound rows in physical ordering.
   Keep their existing admission behavior and exclude them from proof chains.
  6. Partition admitted receipts by `(scenarioId, sourceRevision)`. Build complete
   and incomplete campaigns without crossing either group-key component.
  7. Match RED and GREEN on `(testIdentity, negativeControl)`. Choose the latest
   eligible RED and IMPLEMENT before each successful GREEN.
  8. Select the complete chain with the greatest terminal GREEN ordinal. Refuse
   missing, duplicate, nonpositive, or nonmonotonic model ordinals with
   `SCS-APPEND-ORDER-CONFLICT`.
  9. Derive `chainId` from length-prefixed UTF-8 group, proof, and ledger identity
   fields. Do not use delimiter joining.
  10. Classify admitted rows after selection as `SELECTED`, `SUPERSEDED`,
   `UNRESOLVED`, or `EXCLUDED`. Only the design's closed four-code set can
   become superseded.
  11. Emit `SCS-CHAIN-PARTIAL` for a RED-only or RED-plus-IMPLEMENT campaign after
    the selected GREEN. Keep the selected chain visible and return semantic
    refusal exit 1.
  12. Add the two refusal codes to `bubbles/registry/scenario-states.yaml`. Keep
    all existing code semantics and no-bypass argument handling unchanged.
  13. Add conditional JSON selection fields and `SUPERSEDED` text diagnostics.
    Keep drift-only `BUG-034` output byte-identical.
  14. Exercise `phase-coordinator.sh` JSON consumption and
    `state-transition-guard.sh` text consumption from hermetic blocks in the
    owning resolver selftest. Do not edit either consumer.
  15. Rerun the identical focused cases for GREEN evidence. Then run the source
    framework validation and release checks through `bubbles/scripts/cli.sh`.

### Change Boundary

#### Allowed Implementation Files

- `bubbles/scripts/scenario-state-resolve.sh`
- `bubbles/scripts/scenario-state-resolve-selftest.sh`
- `bubbles/registry/scenario-states.yaml`

#### Allowed Planning And Evidence Files

- `bugs/BUG-042-same-revision-receipt-supersession/**`

#### Closed External Prerequisite Import Exception

- `bubbles/scripts/guard-lib.sh`: only the six-line insertion and exact blob
  transition recorded above.
- `bubbles/release-manifest.json`: only the coupled one-line SHA-256 replacement
  from the current clean manifest blob recorded above. The inspected commit's
  whole-file manifest blobs are provenance, not worktree target blobs.
- Both deltas remain uncommitted until BUG-042 implementation and its required
  validation are evaluated together. They grant no permission to edit timeout
  behavior, timeout tests, other manifest entries, generated copies, or
  downstream installations.

#### Excluded Files And Surfaces

- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- `bubbles/scripts/phase-coordinator.sh`
- `bubbles/scripts/phase-coordinator-selftest.sh`
- `bubbles/scripts/framework-validate.sh`
- `bubbles/scripts/tool-log.sh`
- `bubbles/schemas/tool-call.schema.json`
- `bubbles/release-manifest.json`, except for the closed one-line prerequisite
  import above
- `bugs/BUG-034-*`
- Every other worktree, branch, repository, deployment, and runtime service

Collateral cleanup is prohibited. Expand this boundary through planning before
changing any excluded file.

### Shared Infrastructure Impact Sweep

The resolver is a protected, high-fan-out certification input. The change must
preserve these downstream contracts:

- Receipt admission, revision exclusion, state rank, required-state, and
  certifiability semantics.
- `phase-coordinator.sh` receives valid additive JSON on exit-zero resolution.
- `state-transition-guard.sh` retains state lines and `REFUSED` blocking text.
- Schema versions 1, 2, and 3 remain accepted without persisted ordinals.
- Rollback stops advancement while preserving all six existing receipts.
- Every bypass-shaped argument retains usage exit 2.

Run the focused resolver suite as the independent canary before broad checks.
Its consumer blocks must invoke production consumer scripts without changing
their source. A code rollback restores the old resolver and registry entries.
It never rewrites, compacts, migrates, or deletes ledger bytes.

### Consumer Impact Sweep

- **Producer:** `scenario-state-resolve.sh` adds conditional JSON fields and
  `SUPERSEDED` text lines.
- **JSON consumer:** `phase-coordinator.sh` must accept additive fields and
  preserve the full successful payload under `scenarioStates`.
- **Text consumer:** `state-transition-guard.sh` must accept superseded history
  and must still reject every unresolved current conflict.
- **Receipt producer:** `tool-log.sh` remains unchanged because ordinals and row
  digests are resolver-derived.
- **Schemas and generated clients:** no contract field changes exist.
- **Navigation, breadcrumbs, redirects, deep links, API clients, and UI:** none
  exist for this command-only resolver.
- **Stale-reference scan:** confirm no new caller parses the closed additive
  fields as a required legacy shape.

### Test Plan

All matrix rows persist in
`bubbles/scripts/scenario-state-resolve-selftest.sh`. The command for every row
is `bash bubbles/scripts/scenario-state-resolve-selftest.sh`. Each block invokes
the production resolver and prints the exact title below.

| Test Plan ID | Design row | Scenario IDs | Category | File/Location and exact persistent test title | RED or current-protection expectation | GREEN expectation | Live system |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `TP-B042-T01` | `B042-T01` | `SCN-B042-001` | integration | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T01 substituted-test replacement` | The final matching GREEN still leaves `SCS-TEST-SUBSTITUTED` blocking. Removing that GREEN also blocks. | The final matching GREEN selects A, supersedes the older diagnostic, and the transition consumer accepts the chain. | Yes |
| `TP-B042-T02` | `B042-T02` | `SCN-B042-002` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T02 substituted-control replacement` | The final matching GREEN still leaves `SCS-CONTROL-SUBSTITUTED` blocking. | The final matching GREEN selects control A and supersedes the older diagnostic. | No |
| `TP-B042-T03` | `B042-T03` | `SCN-B042-003` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T03 exit-zero RED replacement` | The old exit-zero RED leaves `SCS-RED-NOT-FAILING` blocking despite the complete replacement chain. | The failing RED anchors the selected chain and supersedes the old diagnostic. | No |
| `TP-B042-T04` | `B042-T04` | `SCN-B042-004` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T04 equal timestamps use append ordinal` | Selection output lacks resolver-derived ordinal and chain identity. | Two unchanged runs return byte-identical selected ordinals and chain ID. | No |
| `TP-B042-T05` | `B042-T05` | `SCN-B042-005` | integration | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T05 later substituted-test remains unresolved` | Output cannot report a selected chain beside the later blocker. | The A chain stays visible, B is `UNRESOLVED`, exit is 1, and the transition consumer refuses. | Yes |
| `TP-B042-T06` | `B042-T06` | `SCN-B042-002`, `SCN-B042-005` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T06 later substituted-control remains unresolved` | Output cannot distinguish a current control conflict from superseded history. | The selected chain stays visible and the later control substitution blocks. | No |
| `TP-B042-T07` | `B042-T07` | `SCN-B042-003`, `SCN-B042-005` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T07 later exit-zero RED remains unresolved` | The resolver cannot retain the selected chain beside the current bad RED. | The selected chain stays visible and `SCS-RED-NOT-FAILING` blocks. | No |
| `TP-B042-T08` | `B042-T08` | `SCN-B042-005` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T08 later RED-only campaign is partial` | No `SCS-CHAIN-PARTIAL` diagnostic exists. | The selected chain stays visible and the missing IMPLEMENT campaign blocks. | No |
| `TP-B042-T09` | `B042-T09` | `SCN-B042-005` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T09 later RED-IMPLEMENT campaign is partial` | No `SCS-CHAIN-PARTIAL` diagnostic names the missing GREEN. | The selected chain stays visible and the missing GREEN campaign blocks. | No |
| `TP-B042-T10` | `B042-T10` | `SCN-B042-001` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T10 still-later coherent chain closes conflict` | The intermediate substituted-test refusal remains irreversible. | The final A chain is selected, B becomes `SUPERSEDED`, and exit is 0. | No |
| `TP-B042-T11` | `B042-T11` | `SCN-B042-004` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T11 duplicate rows retain distinct ordinals` | Output has no raw-row digest and append-ordinal identity. | The later duplicate GREEN wins. Both rows share a digest and retain distinct ordinals. | No |
| `TP-B042-T12` | `B042-T12` | `SCN-B042-005` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T12 cross-scenario isolation` | Output lacks explicit per-group disposition evidence. | Scenario B cannot supersede scenario A. A remains blocking. | No |
| `TP-B042-T13` | `B042-T13` | `SCN-B042-001` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T13 BUG-034 revision isolation` | Current protection: all three revision-drift outcomes pass and their bytes are captured. | The same three outputs and exit codes remain byte-identical. | No |
| `TP-B042-T14` | `B042-T14` | `SCN-B042-001` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T14 proof identity cannot borrow phases` | Output lacks `NO_COMPLETE_CHAIN` selection status. | RED A and GREEN B never combine into a complete chain. Exit is 1. | No |
| `TP-B042-T15` | `B042-T15` | `SCN-B042-004` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T15 duplicate model ordinal refuses order` | The order-conflict branch and refusal code do not exist. | A bounded temporary mutation forces duplicate terminal ordinals and receives `SCS-APPEND-ORDER-CONFLICT` without a tie breaker. | No |
| `TP-B042-T16` | `B042-T16` | `SCN-B042-004` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T16 legacy receipts derive local identities` | Versions 1 through 3 parse, but selection ordinals and row identities are absent. | Equivalent v1, v2, and v3 envelopes derive equivalent local selection outcomes without persisted ordinals. | No |
| `TP-B042-T17` | `B042-T17` | all five scenarios | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T17 bypass arguments remain rejected` | Current protection: every bypass-shaped flag returns usage exit 2. | The same flags remain rejected by name after the repair. | No |
| `TP-B042-T18` | `B042-T18` | `SCN-B042-005` | functional | `bubbles/scripts/scenario-state-resolve-selftest.sh` - `B042-T18 rollback preserves current ledger identities` | The six-receipt rollback count passes, but no ledger identities are exposed for preservation checks. | Rollback stops advancement and preserves all six receipt counts, ordinals, digests, and source bytes. | No |

**Test Plan to DoD parity:** 18 matrix rows map one-to-one to the 18 matrix
evidence items below. `scenario-manifest.json` retains exactly five stable
scenario identities.

### Category Exclusions

- `e2e-api` is not applicable because the resolver exposes no network API.
- `e2e-ui` and `ui-unit` are not applicable because the resolver has no UI.
- `stress` and `load` are not applicable because the design defines no latency,
  throughput, or concurrency target.
- The integration rows use real production CLI consumers with hermetic local
  fixtures. They do not intercept or mock an owned boundary.

### Validation Sequence

1. Verify the prerequisite source parent blob and current clean manifest blob.
  Apply only the two authorized upstream deltas. Verify the fixed source blob
  and one-entry-only manifest diff, then run the exact focused timeout selftest.
  Do not begin BUG-042 evaluation if this gate fails.
2. Capture the focused pre-fix matrix through
   `bubbles/scripts/scenario-state-resolve-selftest.sh`.
3. Rerun that exact focused suite after implementation.
4. Run the bugfix regression-quality guard against the focused selftest.
5. Run planning, scenario, mechanism, consumer, and reference gates.
6. Run `bash bubbles/scripts/cli.sh framework-validate`.
7. Run `bash bubbles/scripts/cli.sh release-check` on the final candidate.

The focused prerequisite pass authorizes only continued evaluation. Neither it
nor the current six BUG-042 finding checks may be reported as a passing full
framework suite.

### Definition of Done - 3-Part Validation

#### Core Delivery Items

- [ ] The resolver snapshots one regular JSONL prefix and derives ordinal and raw-row digest identities without changing receipt bytes.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning fixed the snapshot and identity contract from `design.md`.
  > **What was observed:** Planning did not modify the resolver.
  > **Why this is uncertain:** No execution proves stable prefix reads or exact-byte hashing.
  > **What would resolve this:** Implement the reader and run the focused identity cases.

- [ ] The resolver selects the latest complete same-group proof chain before it classifies diagnostics.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning mapped chain construction to the five stable scenarios.
  > **What was observed:** The current eager-refusal algorithm remains unchanged.
  > **Why this is uncertain:** No selected-chain output exists yet.
  > **What would resolve this:** Implement selection and run `B042-T01` through `B042-T14`.

- [ ] Receipt dispositions and selection statuses use only the approved closed vocabularies.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning recorded all four dispositions and four statuses.
  > **What was observed:** The production output does not expose these fields.
  > **Why this is uncertain:** Output compatibility has not been executed.
  > **What would resolve this:** Add the conditional fields and assert their exact values.

- [ ] The registry defines `SCS-CHAIN-PARTIAL` and `SCS-APPEND-ORDER-CONFLICT` without weakening any existing refusal.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning limited registry work to two closed codes.
  > **What was observed:** The registry remains unchanged.
  > **Why this is uncertain:** Registry consumers have not read the new entries.
  > **What would resolve this:** Add both entries and run registry plus resolver checks.

- [ ] Phase-coordinator and transition-guard consumer behavior remains compatible without source changes to either consumer.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning defined success and refusal canaries in `B042-T01` and `B042-T05`.
  > **What was observed:** No consumer canary has run against the additive output.
  > **Why this is uncertain:** Resolver-only assertions cannot prove consumer behavior.
  > **What would resolve this:** Invoke both production consumers from the focused hermetic suite.

- [x] The exact existing timeout-normalization prerequisite is present as the authorized uncommitted source blob transition and one-entry-only manifest substitution, and its focused ten-case selftest passes before BUG-042 evaluation.
  > **Phase:** implement
  > **Claim Source:** executed
  > **Evidence:** [E-B042 External Base Prerequisite Import](report.md#e-b042-external-base-prerequisite-import). The source reached blob `e8e404a5c157c94e822a07dcee1076d1239d7a8b`, the manifest has only the authorized one-entry `1/1` substitution, and the exact focused command exited `0` with ten PASS cases, zero FAIL cases, and `guard-lib timeout selftest: OK (10 cases)`.
  > **Boundary routing:** `state.json` still carries the older path list. Both exception paths mechanically classify `route-same-repo`; `F-B042-BOUNDARY-METADATA-01` records that mismatch without widening or bypassing the state boundary.

- [ ] The implementation changes only allowed paths and preserves receipt schemas, BUG-034 artifacts, contested guards, and release metadata.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning declared exact allowed and excluded file families.
  > **What was observed:** No implementation diff exists.
  > **Why this is uncertain:** Collateral containment requires the completed diff.
  > **What would resolve this:** Classify the final changed-path set against the Change Boundary.

#### Matrix Evidence Items - 18 Items For 18 Test Plan Rows

- [ ] `TP-B042-T01` proves `SCN-B042-001`: a later coherent chain supersedes substituted-test history, retains the diagnostic as `SUPERSEDED`, and reaches consumer acceptance without a historical block.
  > **Uncertainty Declaration**
  > **What was attempted:** The exact fixture sequence and assertions are planned.
  > **What was observed:** The persistent block does not exist in the focused selftest.
  > **Why this is uncertain:** The historical veto and corrected consumer result have not run.
  > **What would resolve this:** Add the block before the fix, capture RED, then rerun it after the fix.

- [ ] `TP-B042-T02` proves `SCN-B042-002`: a later coherent chain supersedes substituted-control history and retains the diagnostic as `SUPERSEDED` without blocking eligibility.
  > **Uncertainty Declaration**
  > **What was attempted:** The exact fixture sequence and assertions are planned.
  > **What was observed:** The persistent block does not exist in the focused selftest.
  > **Why this is uncertain:** The control-replacement path has not run.
  > **What would resolve this:** Add the block before the fix, capture RED, then rerun it after the fix.

- [ ] `TP-B042-T03` proves `SCN-B042-003`: a later failing RED supersedes exit-zero RED history and anchors the authoritative chain.
  > **Uncertainty Declaration**
  > **What was attempted:** The exact fixture sequence and assertions are planned.
  > **What was observed:** The persistent block does not exist in the focused selftest.
  > **Why this is uncertain:** The replacement RED path has not run.
  > **What would resolve this:** Add the block before the fix, capture RED, then rerun it after the fix.

- [ ] `TP-B042-T04` proves `SCN-B042-004`: physical append order is deterministic and conflict-safe for equal timestamps.
  > **Uncertainty Declaration**
  > **What was attempted:** The repeated-output and ordinal assertions are planned.
  > **What was observed:** Current output has no selection ledger identities.
  > **Why this is uncertain:** Timestamp independence has not been proved.
  > **What would resolve this:** Run two fixed-byte fixtures before and after the repair.

- [ ] `TP-B042-T05` proves `SCN-B042-005`: a prior valid chain remains visible beside an unresolved later campaign, and the production consumer refuses.
  > **Uncertainty Declaration**
  > **What was attempted:** The selected-chain-plus-blocker assertions are planned.
  > **What was observed:** The persistent block and consumer canary do not exist.
  > **Why this is uncertain:** Current-conflict preservation has not run end to end.
  > **What would resolve this:** Add the focused block and run both production consumers.

- [ ] `TP-B042-T06` records persistent RED and GREEN evidence for a later unresolved substituted-control row.
  > **Uncertainty Declaration**
  > **What was attempted:** The selected-chain-plus-control-blocker assertions are planned.
  > **What was observed:** The persistent block does not exist.
  > **Why this is uncertain:** A broad control exemption has not been ruled out by execution.
  > **What would resolve this:** Add the case and prove the later row stays blocking.

- [ ] `TP-B042-T07` records persistent RED and GREEN evidence for a later unresolved exit-zero RED.
  > **Uncertainty Declaration**
  > **What was attempted:** The selected-chain-plus-current-RED assertions are planned.
  > **What was observed:** The persistent block does not exist.
  > **Why this is uncertain:** A broad RED exemption has not been ruled out by execution.
  > **What would resolve this:** Add the case and prove the later bad RED stays blocking.

- [ ] `TP-B042-T08` records persistent RED and GREEN evidence for a later RED-only partial campaign.
  > **Uncertainty Declaration**
  > **What was attempted:** The missing-IMPLEMENT diagnostic is planned.
  > **What was observed:** `SCS-CHAIN-PARTIAL` does not exist in production.
  > **Why this is uncertain:** The partial-campaign boundary has not run.
  > **What would resolve this:** Add the case and assert campaign ordinal, missing phase, and exit 1.

- [ ] `TP-B042-T09` records persistent RED and GREEN evidence for a later RED-plus-IMPLEMENT partial campaign.
  > **Uncertainty Declaration**
  > **What was attempted:** The missing-GREEN diagnostic is planned.
  > **What was observed:** `SCS-CHAIN-PARTIAL` does not exist in production.
  > **Why this is uncertain:** The second partial-campaign boundary has not run.
  > **What would resolve this:** Add the case and assert campaign ordinal, missing phase, and exit 1.

- [ ] `TP-B042-T10` records persistent RED and GREEN evidence for a still-later coherent chain that closes an eligible conflict.
  > **Uncertainty Declaration**
  > **What was attempted:** The invalid-then-complete sequence is planned.
  > **What was observed:** Current refusals remain irreversible.
  > **Why this is uncertain:** A still-later chain has not proved direct replacement.
  > **What would resolve this:** Add the case and assert final chain identity, supersession, and exit 0.

- [ ] `TP-B042-T11` records persistent RED and GREEN evidence for byte-identical duplicate rows with distinct ordinals.
  > **Uncertainty Declaration**
  > **What was attempted:** Digest and ordinal assertions are planned.
  > **What was observed:** Current output exposes neither identity field.
  > **Why this is uncertain:** Digest equality and append-event distinction have not run.
  > **What would resolve this:** Add duplicate rows and assert equal digests, unique ordinals, and latest selection.

- [ ] `TP-B042-T12` records persistent RED and GREEN evidence for cross-scenario isolation.
  > **Uncertainty Declaration**
  > **What was attempted:** Separate scenario groups are planned in one ledger.
  > **What was observed:** No disposition assertions exist for both groups.
  > **Why this is uncertain:** Cross-scenario supersession has not been excluded by the new selector.
  > **What would resolve this:** Add the case and prove scenario A remains blocking beside scenario B.

- [ ] `TP-B042-T13` records current-protection and post-fix evidence for all three BUG-034 revision-drift outcomes.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning identified the existing three load-bearing assertions.
  > **What was observed:** They have not run against a source change in this phase.
  > **Why this is uncertain:** Byte compatibility depends on the completed implementation.
  > **What would resolve this:** Capture current bytes, then compare outputs and exit codes after the repair.

- [ ] `TP-B042-T14` records persistent RED and GREEN evidence that proof identities cannot borrow phases.
  > **Uncertainty Declaration**
  > **What was attempted:** The RED-A, IMPLEMENT, GREEN-B sequence is planned.
  > **What was observed:** Current output has no complete-chain selection status.
  > **Why this is uncertain:** Identity isolation has not run through the new candidate builder.
  > **What would resolve this:** Add the case and assert no selected chain plus exit 1.

- [ ] `TP-B042-T15` records persistent RED and GREEN evidence for fail-closed duplicate model ordinals.
  > **Uncertainty Declaration**
  > **What was attempted:** A bounded temporary production mutation is planned.
  > **What was observed:** The conflict branch and refusal code do not exist.
  > **Why this is uncertain:** The impossible-order invariant has not been forced through production logic.
  > **What would resolve this:** Add the mutation case and assert only `SCS-APPEND-ORDER-CONFLICT` decides the tie.

- [ ] `TP-B042-T16` records persistent RED and GREEN evidence for v1, v2, and v3 receipts without persisted ordinals.
  > **Uncertainty Declaration**
  > **What was attempted:** Equivalent legacy-envelope fixtures are planned.
  > **What was observed:** Current parsing works, but local selection identities do not exist.
  > **Why this is uncertain:** Migration-free parity has not run through the new selector.
  > **What would resolve this:** Add all three envelopes and compare their derived outcomes.

- [ ] `TP-B042-T17` records current-protection and post-fix evidence that every bypass-shaped argument returns usage exit 2.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning retained the existing five-flag rejection loop.
  > **What was observed:** The loop has not run against the completed repair.
  > **Why this is uncertain:** Argument handling could change during implementation.
  > **What would resolve this:** Run the exact rejection loop after the final source edit.

- [ ] `TP-B042-T18` records persistent RED and GREEN evidence that rollback preserves all six receipt identities and source bytes.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning extends the existing six-receipt rollback assertion.
  > **What was observed:** Current rollback exposes count but no derived identities.
  > **Why this is uncertain:** New metadata preservation has not run under rollback.
  > **What would resolve this:** Assert count, ordinals, digests, source hash, and stopped advancement after the repair.

#### Build Quality Gate

- [ ] All focused planning, regression, framework, and release checks pass on the final candidate.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning names every required focused and broad command.
  > **What was observed:** Delivery commands have not run because source and tests remain unchanged.
  > **Why this is uncertain:** Planning validation cannot certify implementation or release readiness.
  > **What would resolve this:** Execute the validation sequence after all allowed implementation edits.
