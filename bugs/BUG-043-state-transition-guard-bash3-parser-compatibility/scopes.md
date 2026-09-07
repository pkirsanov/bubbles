# BUG-043 Scopes

Related artifacts: [bug.md](bug.md), [spec.md](spec.md), [design.md](design.md),
[test-plan.json](test-plan.json), [scenario-manifest.json](scenario-manifest.json),
[report.md](report.md), and [uservalidation.md](uservalidation.md).

## Execution Outline

### Phase Order

1. **Scenario-first parser RED:** Add the persistent dual-parser and
   source-derived fixture assertions before changing production source.
2. **Minimal parser repair:** Remove only the redundant opening and closing
   assignment quotes around the Check 7C command substitution.
3. **Semantic preservation:** Run the existing transition guard selftest with
   no verdict, applicability, severity, or bypass changes.
4. **Release propagation:** Regenerate the release manifest and verify an
   installer-created downstream copy from the repaired source bytes.
5. **Aggregate validation:** Run framework validation and release readiness on
   the same final source revision.

### New Types and Signatures

- No new API, state field, command option, or runtime support claim is added.
- Defective opening form: `claim_backing_analysis="$(python3 - "$state_file" <<'PY'`.
- Defective closing form: `)"` after the Check 7C heredoc delimiter.
- Repaired opening form: `claim_backing_analysis=$(python3 - "$state_file" <<'PY'`.
- Repaired closing form: `)` after the unchanged heredoc delimiter.
- Source-derived sentinel: `BUG043_SENTINEL_AFTER_FORMER_LINE_4016`.
- Adversarial mutation: restore only the two redundant outer quote characters,
  exactly once, without changing heredoc bytes.

### Validation Checkpoints

- **Checkpoint A:** `TP-01` fails on the frozen defect because Bash 3.2 rejects
  the same bytes that Bash 5.3 accepts.
- **Checkpoint B:** `TP-02` proves both repaired source-derived fixtures execute
  exactly one post-boundary sentinel.
- **Checkpoint C:** `TP-03` proves the exact quote-restoration mutant yields the
  closed parse and sentinel matrix.
- **Checkpoint D:** `TP-04` preserves all supported-runtime transition verdicts.
- **Checkpoint E:** `TP-05` proves generated-manifest and installer byte parity.
- **Checkpoint F:** `TP-06` runs framework and release checks after all focused
  checkpoints pass.

## Scope 1 - Restore Dual-Parser Compatibility

**Status:** Not Started

**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B043-001 Source guard parses under Bash 3 and Bash 5
  Given the canonical transition guard from the frozen source revision
  When syntax validation runs with real Bash 3 and real Bash 5 interpreters
  Then both interpreters accept the same source bytes

Scenario: SCN-B043-002 The regression rejects the incompatible grammar
  Given a private source-derived fixture containing the repaired Check 7C assignment and the exact Check 16 heading
  When the regression restores only the two redundant outer assignment quotes exactly once
  Then the repaired Bash 3 and Bash 5 fixtures each emit one post-boundary sentinel
    And the quote-restoration mutant exits 2 with no Bash 3 sentinel
    And the same mutant exits 0 with one Bash 5 sentinel

Scenario: SCN-B043-003 Supported-runtime guard behavior remains stable
  Given the parser-compatible source guard
  When the existing transition guard selftest runs under supported Bash
  Then every existing transition verdict remains unchanged
    And no check is bypassed or skipped

Scenario: SCN-B043-004 Downstream installation receives the repaired guard
  Given a release manifest generated from the validated source tree
  When Bubbles installs into a private downstream fixture
  Then the installed guard matches the source guard bytes
    And the installed copy passes the Bash 3 and Bash 5 syntax matrix
```

### Implementation Plan

1. Add a persistent parser regression before source mutation. Make the desired
  Bash 3.2 and Bash 5.3 parity assertion fail on the frozen defect.
2. Freeze one source hash and report both real interpreter paths, versions,
  exit codes, and complete stderr streams.
3. Build the executable fixture from unique current-source anchors. Extract the
  complete Check 7C assignment and the exact Check 16 heading.
4. Append `BUG043_SENTINEL_AFTER_FORMER_LINE_4016` after the extracted heading.
  Fail when either source anchor is absent or duplicated.
5. Add an adversarial copy that restores only the opening and closing outer
  assignment quotes. Require exactly one mutation at each quote boundary.
6. Assert the closed matrix: repaired parse `0/0`, repaired sentinels `1/1`,
  mutant parse `2/0`, and mutant sentinels `0/1` for Bash 3.2/Bash 5.3.
7. Remove only the two redundant production quote characters. Preserve every
  heredoc byte and every executable Check 7C branch.
8. Run the focused parser matrix and the complete transition guard selftest.
9. Regenerate `bubbles/release-manifest.json` through
  `bubbles/scripts/generate-release-manifest.sh` after focused checks pass.
10. Install into a private downstream fixture. Compare source and installed
   guard hashes, then run the same dual-parser matrix on the installed copy.
11. Run framework validation and release readiness on the final source bytes.
12. Publish only through the standard install or upgrade path. Never edit a
   downstream installed copy directly.

### Change Boundary

Allowed delivery paths:

- `bubbles/scripts/state-transition-guard.sh` for the two-character repair.
- `bubbles/scripts/bash-baseline-guard-selftest.sh` for parser, sentinel, and
  quote-restoration regression coverage.
- `bubbles/scripts/state-transition-guard-selftest.sh` only when an additive
  semantic-preservation assertion is required.
- `bubbles/release-manifest.json` only as generator output.
- This bug packet's execution evidence and execution-owned state fields.

Protected paths:

- Preserve all workflow, gate, and ownership registries.
- Preserve all unrelated source scripts, tests, bug packets, docs, and
  improvements.
- Preserve every downstream repository working tree.
- Preserve `.bubbles-worktree` exactly.
- Reject any production edit beyond the two outer assignment quotes unless
  planning is reconciled before mutation.

### Test Plan

| ID | Scenario | Expected test title | Type | Category | File or command surface | Command | Live System | Required assertion |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TP-01 | SCN-B043-001 | `Regression: SCN-B043-001 repaired guard parses under real Bash 3 and Bash 5 on identical bytes` | functional | functional | `bubbles/scripts/bash-baseline-guard-selftest.sh` | `bash bubbles/scripts/bash-baseline-guard-selftest.sh` | Yes | Record the scenario-first RED on frozen bytes, then require both parser exits to be zero on one frozen repaired-source hash. |
| TP-02 | SCN-B043-002 | `Regression: SCN-B043-002 source-derived fixture crosses the former Bash 3 recovery boundary` | functional | functional | `bubbles/scripts/bash-baseline-guard-selftest.sh` | `bash bubbles/scripts/bash-baseline-guard-selftest.sh` | Yes | Extract unique source anchors and require exactly one `BUG043_SENTINEL_AFTER_FORMER_LINE_4016` emission from each repaired interpreter leg. |
| TP-03 | SCN-B043-002 | `Mutation: SCN-B043-002 exact outer-quote restoration recreates the parser divergence` | functional | functional | `bubbles/scripts/bash-baseline-guard-selftest.sh` | `bash bubbles/scripts/bash-baseline-guard-selftest.sh` | Yes | Restore only the two outer assignment quotes exactly once and require repaired parse `0/0`, repaired sentinels `1/1`, mutant parse `2/0`, and mutant sentinels `0/1`. |
| TP-04 | SCN-B043-003 | `Regression: SCN-B043-003 supported-runtime transition verdicts remain unchanged` | functional | functional | `bubbles/scripts/state-transition-guard-selftest.sh` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Yes | Run the existing semantic suite under supported Bash with no bypass, skip, applicability, severity, or verdict drift. |
| TP-05 | SCN-B043-004 | `Regression: SCN-B043-004 installed transition guard matches source bytes and parser parity` | integration | integration | `bubbles/scripts/generate-installer-selftest.sh`, `bubbles/scripts/install-provenance-selftest.sh`, and `bubbles/scripts/v5.3-selftest.sh` | `bash bubbles/scripts/generate-installer-selftest.sh && bash bubbles/scripts/install-provenance-selftest.sh && bash bubbles/scripts/v5.3-selftest.sh` | Yes | Generate the release manifest, install into a private fixture, compare guard hashes, and require both installed parser legs to exit zero. |
| TP-06 | SCN-B043-003 | `Regression: BUG-043 framework validation and release readiness preserve parser and propagation contracts` | functional | functional | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate && bash bubbles/scripts/cli.sh release-check` | Yes | Run both aggregate checks on the final source bytes after focused parser, semantic, and installer checks pass. |

Every command runs through the execution agent's finite supervisor. `TP-01`
must execute first and preserve its nonzero RED receipt before production source
changes. `TP-02` through `TP-06` remain blocked until that receipt exists.

### Definition of Done

- [ ] **DOD-TP-01:** `TP-01` for `SCN-B043-001` records the scenario-first RED on frozen defect
  bytes and the final dual-parser GREEN on one repaired-source hash.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning defined the exact RED and GREEN parser oracle. No scenario test was authored or executed in this phase.
  > **What was observed:** The test row remains planned and the delivery scope remains Not Started.
  > **Why this is uncertain:** No current test receipt proves that the persistent regression fails before the repair and passes after it.
  > **What would resolve this:** `bubbles.test` must author `TP-01`, run it on frozen defect bytes, and preserve the nonzero RED receipt.
- [ ] **DOD-TP-02:** `TP-02` for `SCN-B043-002` derives the executable fixture from unique source
  anchors and proves each repaired interpreter emits exactly one post-boundary
  sentinel.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning encoded the source-anchor and sentinel contract. No source-derived fixture was authored or executed.
  > **What was observed:** `BUG043_SENTINEL_AFTER_FORMER_LINE_4016` appears in planning artifacts only.
  > **Why this is uncertain:** No persistent test proves unique anchor extraction or one sentinel from each repaired interpreter.
  > **What would resolve this:** `bubbles.test` must author and execute `TP-02` against both real parser binaries.
- [ ] **DOD-TP-03:** `TP-03` for `SCN-B043-002` restores only the two outer assignment quotes
  exactly once and proves the complete repaired-versus-mutant parse and sentinel
  matrix.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning encoded the two-character mutation and closed `0/0`, `1/1`, `2/0`, `0/1` oracle.
  > **What was observed:** The scenario manifest and structured test plan agree on that oracle.
  > **Why this is uncertain:** No persistent mutation test proves exact quote restoration or unchanged heredoc bytes.
  > **What would resolve this:** `bubbles.test` must author `TP-03` and execute the repaired and mutant fixtures under Bash 3.2 and Bash 5.3.
- [ ] **DOD-TP-04:** `TP-04` for `SCN-B043-003` proves every supported-runtime transition verdict,
  applicability decision, and severity remains unchanged with no skipped check.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning mapped semantic preservation to the existing transition guard selftest.
  > **What was observed:** This planning phase did not execute that suite on repaired production bytes.
  > **Why this is uncertain:** No current post-repair receipt proves unchanged verdicts, applicability, severity, and check execution.
  > **What would resolve this:** `bubbles.test` must run `TP-04` after the minimal production repair.
- [ ] **DOD-TP-05:** `TP-05` for `SCN-B043-004` proves generator-produced manifest bytes install an
  identical guard that passes both real parser legs.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning mapped propagation to the canonical generator and three existing installer selftests.
  > **What was observed:** No release manifest was generated and no downstream fixture was installed in this phase.
  > **Why this is uncertain:** Source-to-installed byte parity and installed parser parity have no current execution receipt.
  > **What would resolve this:** `bubbles.test` must execute `TP-05` after focused parser and semantic checks pass.
- [ ] **DOD-TP-06:** `TP-06` for `SCN-B043-003` proves framework validation and release readiness
  preserve parser, semantic, and downstream propagation contracts.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning defined the aggregate final-source commands and their execution order.
  > **What was observed:** Neither aggregate command ran on repaired source bytes during planning.
  > **Why this is uncertain:** Focused checks cannot substitute for final framework validation and release readiness.
  > **What would resolve this:** `bubbles.test` must execute `TP-06` after `TP-01` through `TP-05` pass.
- [ ] The production edit removes exactly the redundant opening and closing
  assignment quotes around Check 7C and changes no heredoc byte.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning froze the allowed edit as two shell quote characters.
  > **What was observed:** Production source remains byte-identical to `HEAD`.
  > **Why this is uncertain:** The selected repair has not been applied or compared against the planned byte boundary.
  > **What would resolve this:** `bubbles.implement` must apply the two-character repair after the `TP-01` RED receipt and record a byte-level diff.
- [ ] No bypass, skip, silent fallback, runtime-policy expansion, or direct
  downstream patch is introduced.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning prohibited each listed behavior and protected every downstream working tree.
  > **What was observed:** This planning invocation introduced none of them.
  > **Why this is uncertain:** The assertion applies to later test, source, generated-manifest, and propagation changes that do not exist yet.
  > **What would resolve this:** Execution and validation agents must scan the final changed paths and downstream status before certification.
- [ ] The final changed-path audit contains only the declared delivery paths and
  preserves every protected path.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning declared exact allowed and protected file families.
  > **What was observed:** The current planning boundary is clean, but no delivery changes exist.
  > **Why this is uncertain:** A pre-delivery boundary check cannot prove the final delivery change set.
  > **What would resolve this:** `bubbles.validate` must compare the final changed paths with this boundary.
- [ ] The release manifest is regenerated only after focused parser and semantic
  checks pass.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning placed manifest generation after focused parser and semantic checkpoints.
  > **What was observed:** The release manifest remains byte-identical to `HEAD`.
  > **Why this is uncertain:** No execution sequence has yet demonstrated the required ordering.
  > **What would resolve this:** Execution receipts must show focused checks succeeded before the canonical generator ran.
- [ ] The standard install or upgrade path carries the released repair without
  direct downstream edits.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning restricted propagation to the standard install or upgrade path.
  > **What was observed:** No downstream install or upgrade ran during planning.
  > **Why this is uncertain:** The propagated byte identity and absence of direct downstream edits remain unexecuted claims.
  > **What would resolve this:** `TP-05` must install into a private fixture and compare source and installed hashes.
- [ ] Human acceptance remains separate from automation readiness.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning preserved the separate automation and human sections in `uservalidation.md`.
  > **What was observed:** The human acceptance record remains unrecorded.
  > **Why this is uncertain:** Automation cannot grant the required human acceptance.
  > **What would resolve this:** A human must complete the acceptance checklist after delivery evidence exists.
- [ ] `bubbles.validate` certifies the packet transition after every unchecked
  item receives current execution evidence.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning preserved all certification fields and requested no transition.
  > **What was observed:** Status and certification remain `in_progress`, with zero completed scopes.
  > **Why this is uncertain:** Delivery, acceptance, specialist phases, and certification have not run.
  > **What would resolve this:** After every delivery item has valid evidence, route the current packet to `bubbles.validate` for independent certification.

### Current Routing

The next owner is `bubbles.test`. That owner must author and execute the
scenario-first `TP-01` RED before any production source mutation.
