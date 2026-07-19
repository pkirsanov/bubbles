# Report: BUG-026 Traceability Sequential Scope And Tiered DoD

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

This artifact-only invocation reconstructed the complete BUG-026 intake packet
from current canonical source, current consumer artifacts, and parent-provided
identity history. It did not recover unavailable transient packet bytes. It did
not edit production, tests, release metadata, documentation, sibling packets,
`improvements/INDEX.md`, Git history, or Research Lab.

## Completion Statement

BUG DELIVERY REMAINS IN PROGRESS. Identity collision recovery is complete only
in the sense that the defect now has a noncolliding canonical intake identity.
Both runtime defects, all test bytes, RED/GREEN evidence, integration,
documentation, release, downstream replay, and certification remain open. No
delivery DoD or terminal status is claimed.

## Identity Collision Record

**Phase:** discovery
**Claim Source:** executed
**Command:** canonical baseline command run from `/Users/pkirsanov/Projects/bubbles` using `git rev-parse`, `git status --short`, `date -u`, `git show --no-patch`, and `git ls-tree -r --name-only`
**Exit Code:** 0

```text
BUG026_CANONICAL_BASELINE_BEGIN
head=a11b2e84e33ec6dc02f8d913908d124c613e5919
branch=main
origin_main=a11b2e84e33ec6dc02f8d913908d124c613e5919
status_begin
M  agents/bubbles_shared/agent-common.md
A  agents/bubbles_shared/untrusted-content.md
M  bubbles/release-manifest.json
A  bubbles/schemas/tool-trust-registry.schema.json
M  bubbles/scripts/pre-tool-risk-gate-selftest.sh
M  bubbles/scripts/pre-tool-risk-gate.sh
M  bubbles/scripts/yaml-schema-validate.sh
A  bubbles/tool-trust-registry.yaml
M  docs/MCP.md
A  docs/recipes/tool-trust-and-untrusted-content.md
status_end
bug026_path=absent
created_at=2026-07-18T22:34:53Z
collision_commit_begin
commit=e9e1de266eb8f6a3abd26ee3e40f1b733017521e
subject=docs(framework): file skill workflow improvements
author_date=2026-07-18T00:05:45Z
commit_date=2026-07-18T03:21:25Z
collision_paths_begin
improvements/BUG-024-create-skill-placeholder-stubs/bug.md
improvements/BUG-024-create-skill-placeholder-stubs/design.md
improvements/BUG-024-create-skill-placeholder-stubs/report.md
improvements/BUG-024-create-skill-placeholder-stubs/scenario-manifest.json
improvements/BUG-024-create-skill-placeholder-stubs/scopes.md
improvements/BUG-024-create-skill-placeholder-stubs/spec.md
improvements/BUG-024-create-skill-placeholder-stubs/state.json
improvements/BUG-024-create-skill-placeholder-stubs/test-plan.json
improvements/BUG-024-create-skill-placeholder-stubs/uservalidation.md
improvements/BUG-025-skills-first-map-merged-rows/bug.md
improvements/BUG-025-skills-first-map-merged-rows/design.md
improvements/BUG-025-skills-first-map-merged-rows/report.md
improvements/BUG-025-skills-first-map-merged-rows/scenario-manifest.json
improvements/BUG-025-skills-first-map-merged-rows/scopes.md
improvements/BUG-025-skills-first-map-merged-rows/spec.md
improvements/BUG-025-skills-first-map-merged-rows/state.json
improvements/BUG-025-skills-first-map-merged-rows/test-plan.json
improvements/BUG-025-skills-first-map-merged-rows/uservalidation.md
collision_paths_end
BUG026_CANONICAL_BASELINE_END
```

**Interpretation:** The command proves the canonical BUG-026 path was absent,
the parent-observed revision still matched `origin/main`, and commit `e9e1de2`
already contained complete BUG-024 and BUG-025 identities. The status block is
pre-existing concurrent work and is not attributed to this invocation.

### Transient Packet Limitation

**Claim Source:** interpreted

The parent reported that a transient
`BUG-024-traceability-sequential-scope-and-tiered-dod` packet disappeared
during concurrent main reconciliation. No bytes from that packet were
available in the canonical checkout, and this invocation did not locate or
claim a recoverable byte source. BUG-026 is reconstructed, not byte-recovered.

## Current Source Inspection

**Phase:** discovery
**Claim Source:** interpreted

**Interpretation:** Current framework files were read with editor tools; no
guard command is represented by this section.

`traceability-guard.sh` currently discovers every physical scope, appends each
to `scope_files`, and sends each through `build_scope_analysis_units()` into
`scope_analysis_files`. No state-derived current-scope selection occurs before
G057/G059 or later passes.

Its current DoD extractor has this effective boundary:

```text
DoD heading at depth 1-4 -> in_dod=1
next heading at any depth 1-4 -> exit
checkbox rows are visible only before that next heading
```

`state-transition-guard.sh` Check 4A and Check 22 use the same any-heading
termination shape. This is interpreted source evidence for
`BUG026-F001-SEQUENTIAL-SCOPE-UNIVERSE`,
`BUG026-F002-TIERED-DOD-BOUNDARY`, and
`BUG026-F003-STATE-TRANSITION-PARITY`; it is not execution proof.

## Inherited Consumer Reproduction - Before Fix

**Phase:** discovery
**Claim Source:** interpreted

**Interpretation:** The block below is quoted from the current Research Lab
Scope 01 report, where it is tagged `Claim Source: executed`. This BUG-026
session did not re-execute the consumer guard and therefore treats the record
as inherited evidence rather than current-session execution.

```text
--- Traceability Summary ---
Scenarios checked: 32
Test rows checked: 90
Scenario-to-row mappings: 22
Concrete test file references: 22
Report evidence references: 4
DoD fidelity scenarios: 0 (mapped: 0, unmapped: 0)
Edge confidence (IMP-015 Scope B): declared=0 inferred=13 ambiguous=9
RESULT: FAILED (37 failures, 0 warnings)
```

The same consumer report preserves all 37 findings individually. Findings
01-28 are descendant-scope report/Test Plan findings from exact `not_started`
Scopes 02-09. Findings 29-37 are one false rowless-DoD finding for each scope.
The Scope 01 artifact demonstrates a depth-3 `### Definition of Done` followed
by valid depth-4 tier headings and real checkbox rows.

## BUG-018 Boundary Evidence

**Claim Source:** interpreted

BUG-018's current report states that its corrected source guard resolves
Feature 007, recognizes 32 linked tests, traverses all nine scopes, and reaches
the normal summary. It expressly classifies the 37 Feature-007-owned findings
as outside BUG-018 completion. BUG-026 preserves BUG-018 and test_25 as
protected compatibility surfaces; no BUG-018 bytes were changed.

## Reserved Regression Path

**Claim Source:** interpreted

The physical regression directory currently ends at test_29, while open
canonical packets reserve test_30 for BUG-023, test_31 for BUG-024, and test_32
for BUG-025. The next noncolliding reservation is:

```text
tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh
```

No file was created at that path. `bubbles.test` owns complete final bytes and
causal RED before implementation.

## Test Evidence

### Editor Diagnostics

**Phase:** discovery
**Tool:** VS Code diagnostics over the complete BUG-026 directory, followed by
the same check after the two local Markdown corrections
**Claim Source:** executed
**Result:** PASS

```text
Initial findings:
MD038/no-space-in-code: one code span carried an internal trailing space
MD024/no-duplicate-heading: repeated per-scope headings in single-file layout
Correction:
the code span now uses ^#{1,4}[[:space:]]
scopes.md locally disables MD024 so exact per-scope Test Plan and DoD headings remain guard-compatible
Focused rerun:
No errors found.
Post-foundation-tag rerun:
No errors found.
```

### Focused Packet Checks

**Phase:** discovery
**Commands:** `node -e` JSON parse and packet-parity assertions;
`bash bubbles/scripts/artifact-lint.sh improvements/BUG-026-traceability-sequential-scope-and-tiered-dod`;
`bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-026-traceability-sequential-scope-and-tiered-dod`;
`bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-026-traceability-sequential-scope-and-tiered-dod`;
packet-scoped `git diff --check`
**Exit Codes:** initial composite 1 because artifact lint required the exact
`## Test Evidence` heading; artifact-lint correction rerun 0; every other
individual check 0
**Claim Source:** executed

```text
PASS json-parse state.json version=3
PASS json-parse scenario-manifest.json version=1
PASS json-parse test-plan.json version=1
PASS json-parse all=3
BUG026_JSON_PARSE_EXIT=0
BUG026_ARTIFACT_LINT_EXIT=1
RESULT: PASS (0 failures, 0 warnings)
BUG026_FRESHNESS_EXIT=0
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
BUG026_G094_EXIT=0
PASS nine-file-inventory
PASS scope-spec-scenario-parity
PASS scope-manifest-scenario-parity
PASS scope-plan-test-parity
PASS dod-plan-test-parity
PASS test-id-sequence-01-through-20
PASS manifest-links-known-tests
PASS state-feature-dir
PASS state-nonterminal
PASS state-workflow-mode
PASS state-next-owner
PASS state-two-scope-dag
PASS scope-foundation-tag
PASS zero-checked-delivery-dod
PASS reserved-test-absent
PASS collision-finding-addressed
PASS unresolved-findings-preserved
scenarioCount=5
testPlanCount=20
fileCount=9
failed=0
BUG026_PACKET_SYNC_EXIT=0
BUG026_DIFF_CHECK_EXIT=0
Artifact lint PASSED.
BUG026_ARTIFACT_LINT_RERUN_EXIT=0
```

The initial artifact-lint exit is preserved rather than overwritten. Its only
finding was the missing canonical report heading; the same canonical command
passed after that local correction. These are packet-shape checks only and do
not satisfy runtime, test, release, downstream, or certification DoD.

### Expected Nonzero Traceability Classification

**Phase:** discovery
**Command:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-026-traceability-sequential-scope-and-tiered-dod`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** The full output contains 14 missing scenario-manifest links
to the intentionally absent reserved test_33, five scenario rows whose first
mapped concrete path is that same absent file, and two false rowless-DoD
findings caused by the current tier-heading defect. Those classes total the
observed 21 failures. The result is expected for nonterminal intake and is not
claimed as delivery success.

```text
scenario-manifest.json covers 5 scenario contract(s)
scenario-manifest.json references missing linked test file: tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh
scenario-manifest.json linked test exists: tests/regression/test_25_traceability_test_plan_heading_depth.sh
scenario-manifest.json linked test exists: bubbles/scripts/cli.sh
Scope 1: Applicable Universe And Tiered DoD Foundation summary: scenarios=3 test_rows=9
Scope 2: Guard Integration And Delivery Closure summary: scenarios=2 test_rows=11
Scope 1: Applicable Universe And Tiered DoD Foundation has Gherkin scenarios but no DoD items - cannot verify content fidelity
Scope 2: Guard Integration And Delivery Closure has Gherkin scenarios but no DoD items - cannot verify content fidelity
Scenarios checked: 5
Test rows checked: 20
Scenario-to-row mappings: 5
Concrete test file references: 0
Report evidence references: 0
DoD fidelity scenarios: 0 (mapped: 0, unmapped: 0)
Edge confidence (IMP-015 Scope B): declared=3 inferred=0 ambiguous=2
RESULT: FAILED (21 failures, 0 warnings)
BUG026_TRACEABILITY_EXIT=1
```

## Finding Accounting

| Finding | Current disposition | Next owner |
| --- | --- | --- |
| `BUG026-F000-IDENTITY-COLLISION` | Addressed by assigning the next free canonical identity BUG-026 and recording that transient bytes were unavailable. | None |
| `BUG026-F001-SEQUENTIAL-SCOPE-UNIVERSE` | Confirmed by current-source and inherited consumer inspection; unresolved. | `bubbles.design` |
| `BUG026-F002-TIERED-DOD-BOUNDARY` | Confirmed by current-source and inherited consumer inspection; unresolved. | `bubbles.design` |
| `BUG026-F003-STATE-TRANSITION-PARITY` | Same boundary defect identified in Check 4A and Check 22; unresolved. | `bubbles.design` |
| `BUG026-F004-REGRESSION-ABSENT` | test_33 is reserved but intentionally absent; no RED/GREEN claim. | `bubbles.test` after design/plan |
| `BUG026-F005-CERTIFICATION-OPEN` | No implementation or delivery evidence exists. | `bubbles.validate` after delivery |

## Invocation Audit

No subagent or nested orchestrator was invoked. This was the `bubbles.bug`
intake phase under the active top-level `bubbles.goal` runner executing
`bugfix-fastlane` with `executionModel: direct-authorized-runner`.

## Final Containment Snapshot

**Phase:** discovery
**Command:** final canonical `git rev-parse HEAD`, `git rev-parse origin/main`,
full `git status --short`, and packet-scoped `git status --short`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG026_FINAL_CONTAINMENT_BEGIN
head=fc6a78b6659ff185c70c48630b6cc819e25601bc
origin_main=fc6a78b6659ff185c70c48630b6cc819e25601bc
full_status_begin
?? improvements/BUG-026-traceability-sequential-scope-and-tiered-dod/
full_status_end
packet_status_begin
?? improvements/BUG-026-traceability-sequential-scope-and-tiered-dod/
packet_status_end
BUG026_FINAL_CONTAINMENT_END
```

**Interpretation:** An independent concurrent writer advanced canonical
`main`/`origin/main` after the `a11b2e84...` intake baseline. The final status
contains only this untracked BUG-026 directory. No production, test, release,
documentation, sibling-packet, index, or Research Lab path remains changed by
this invocation.

## Created Artifact Record

**Claim Source:** interpreted

The requested packet consists of `bug.md`, `spec.md`, `design.md`, `scopes.md`,
`report.md`, `uservalidation.md`, `scenario-manifest.json`, `test-plan.json`,
and `state.json`. Every delivery DoD remains unchecked.
