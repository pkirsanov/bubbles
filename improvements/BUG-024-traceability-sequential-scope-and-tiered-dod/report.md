# Report: BUG-024 Traceability Sequential Scope And Tiered DoD

## Summary

BUG-024 records two confirmed canonical traceability defects. The current guard
uses filesystem discovery as applicability for all per-directory scopes, and
its DoD extractor exits at nested tier headings. A current-session read-only
canonical reproduction against Research Lab Feature 007 exited `1` with 37
findings. Planning now defines two sequential scopes, 19 scenario contracts,
and 41 owner-separated test rows. No implementation or test byte was created
or modified.

## Completion Statement

PLAN RECONCILIATION ONLY. The complete packet is synchronized for final-byte
RED ownership, but delivery remains unclaimed. Every delivery DoD item is
unchecked, status and certification remain `in_progress`, and the exact next
required owner is `bubbles.test`.

## Test Evidence

### Bug Reproduction - Before Fix

**Phase:** discovery
**Command:** `cd /Users/pkirsanov/Projects/research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab; guard_exit=$?; printf 'BUG024_CANONICAL_REPRO_EXIT=%s\n' "$guard_exit"; exit "$guard_exit"`
**Exit Code:** 1
**Claim Source:** executed

The terminal tool preserved the complete 18 KB output. This final contiguous
window is copied from that current-session transcript:

```text
ℹ️  No scenarios to check for DoD content fidelity

--- Traceability Summary ---
ℹ️  Scenarios checked: 32
ℹ️  Test rows checked: 90
ℹ️  Scenario-to-row mappings: 22
ℹ️  Concrete test file references: 22
ℹ️  Report evidence references: 4
ℹ️  DoD fidelity scenarios: 0 (mapped: 0, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=0 inferred=13 ambiguous=9

RESULT: FAILED (37 failures, 0 warnings)
BUG024_CANONICAL_REPRO_EXIT=1

Command exited with code 1
```

**Result:** The defect reproduces. The same output showed Scope 01 mapping all
four scenarios to Test Plan rows, concrete test files, and report evidence;
Scopes 02 through 09 then produced delivery findings; the G068 pass reported
one `has Gherkin scenarios but no DoD items` finding for each of nine scopes.

**Claim Source:** interpreted
**Interpretation:** The 28 plus 9 breakdown is supported by the current
consumer's one-to-one finding ledger and by the complete current-session output.
The raw terminal summary independently proves the aggregate 37, zero DoD
fidelity scenarios, and nonzero exit.

### Canonical Source Inspection

**Phase:** discovery
**Claim Source:** interpreted

The current canonical source was read directly:

```bash
if [[ "$scope_layout" == "per-scope-directory" ]]; then
  while IFS= read -r scope_path; do
    scope_files+=("$scope_path")
  done < <(find "$feature_dir/scopes" -mindepth 2 -maxdepth 2 -type f -name 'scope.md' | sort)
fi
```

`scope_files` feeds both G057/G059 and every `scope_analysis_files` pass. No
state field after `scopeLayout` is consumed on this path.

The current DoD extractor is:

```bash
extract_dod_items() {
  local scope_path="$1"
  awk '
    /^#{1,4}.*Definition of Done|^#{1,4}.*DoD/ {in_dod=1; next}
    /^#{1,4} / {if (in_dod) exit}
    in_dod && /^- \[(x| )\] / {
      sub(/^- \[(x| )\] /, "", $0)
      print
    }
  ' "$scope_path"
}
```

**Interpretation:** A level-4 tier immediately after a level-3 DoD satisfies
the exit rule. The checkbox loop is never reached. This confirms a section
boundary defect before fuzzy fidelity matching.

### Consumer State Inspection

**Phase:** discovery
**Claim Source:** interpreted

Research Lab Feature 007 state records:

- `execution.currentScope = 01-capability-foundation`;
- Scope 01 status `blocked` with no dependency;
- Scopes 02 through 09 status `not_started`;
- each later scope depends on every predecessor; and
- `execution.nextRequiredOwner = bubbles.bug`.

Its Scope 01 report preserves all 37 findings individually. Its Scope 01
artifact uses `### Definition of Done` with deeper tier headings, including
`#### Build Quality Gate`, and artifact lint has already recognized the DoD
checkbox structure in the downstream evidence.

### Related BUG-018 Boundary

**Phase:** discovery
**Claim Source:** interpreted

BUG-018 fixed Test Plan heading depth and caller survival. Its scope and report
explicitly say Feature 007's later 37 findings belong to Feature 007 rather
than BUG-018. BUG-024 cites that packet and leaves every BUG-018 byte unchanged.

## Planned Test Evidence Anchors

The physical regression path is reserved only in planning artifacts:
`tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`.
It did not exist when intake checked the verified free path and was not created.

### T-BUG-024-000

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`
**Claim Source:** not-run
**Reason:** `bubbles.test` has not created frozen final regression bytes or
captured causal RED against unchanged production.

### T-BUG-024-001

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-001`
**Claim Source:** not-run
**Reason:** Exact descendant-omission regression bytes do not exist.

### T-BUG-024-002

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-002`
**Claim Source:** not-run
**Reason:** Completed-prerequisite adversarial regression bytes do not exist.

### T-BUG-024-003

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-003`
**Claim Source:** not-run
**Reason:** Independent and non-not-started descendant adversaries do not exist.

### T-BUG-024-004

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-004`
**Claim Source:** not-run
**Reason:** Canonical registry and currentScope alias regression bytes do not exist.

### T-BUG-024-005

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-005`
**Claim Source:** not-run
**Reason:** Execution-registry precedence and contradiction regressions do not exist.

### T-BUG-024-006

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-006`
**Claim Source:** not-run
**Reason:** Malformed identity/type/dependency/cycle regressions do not exist.

### T-BUG-024-007

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-007`
**Claim Source:** not-run
**Reason:** Path, filesystem, and completion mismatch regressions do not exist.

### T-BUG-024-008

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-008`
**Claim Source:** not-run
**Reason:** Terminal/final/validate/audit/finalize refusal regressions do not exist.

### T-BUG-024-009

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-009`
**Claim Source:** not-run
**Reason:** Duplicate/conflicting/valued/unknown/bypass CLI regressions do not exist.

### T-BUG-024-010

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-010`
**Claim Source:** not-run
**Reason:** Per-directory and single-file mapping regression bytes do not exist.

### T-BUG-024-011

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-011`
**Claim Source:** not-run
**Reason:** Applicable/omitted/all-scope no-scenario regression bytes do not exist.

### T-BUG-024-012

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-012`
**Claim Source:** not-run
**Reason:** DoD depth-1-through-4 and nested-level-through-6 regression bytes do not exist.

### T-BUG-024-013

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-013`
**Claim Source:** not-run
**Reason:** Boundary, false-start, rowless, missing, ambiguous, and read-failure regression bytes do not exist.

### T-BUG-024-014

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case applicable-universe-foundation`
**Claim Source:** not-run
**Reason:** Focused applicable-universe foundation cases do not exist.

### T-BUG-024-015

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case dod-extraction-foundation`
**Claim Source:** not-run
**Reason:** Focused DoD-extraction foundation cases do not exist.

### T-BUG-024-016

**Phase:** test
**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`
**Claim Source:** not-run
**Reason:** The source-only regression file does not exist, so integrity cannot execute.

### T-BUG-024-017

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-014`
**Claim Source:** not-run
**Reason:** One-projection integration regression bytes do not exist.

### T-BUG-024-018

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case terminal-dod-parity`
**Claim Source:** not-run
**Reason:** State-transition Check 4A/22 parity regression bytes do not exist.

### T-BUG-024-019

**Phase:** test
**Command:** `git diff --exit-code -- improvements/BUG-018-traceability-test-plan-heading-depth tests/regression/test_25_traceability_test_plan_heading_depth.sh && bash tests/regression/test_25_traceability_test_plan_heading_depth.sh`
**Claim Source:** not-run
**Reason:** BUG-018 byte-integrity and execution canary was not run by its test owner.

### T-BUG-024-020

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-017`
**Claim Source:** not-run
**Reason:** Managed/final all-scope consumer regression bytes do not exist.

### T-BUG-024-021

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-018`
**Claim Source:** not-run
**Reason:** Cross-runtime regression bytes do not exist.

### T-BUG-024-022

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --scenario SCN-BUG-024-019`
**Claim Source:** not-run
**Reason:** Canonical owner-separated delivery regression bytes do not exist.

### T-BUG-024-023

**Phase:** test
**Command:** `bash bubbles/scripts/traceability-guard-selftest.sh`
**Claim Source:** not-run
**Reason:** The managed traceability selftest has no BUG-024-owned cases yet.

### T-BUG-024-024

**Phase:** test
**Command:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
**Claim Source:** not-run
**Reason:** The managed state-transition selftest has no BUG-024-owned parity cases yet.

### T-BUG-024-025

**Phase:** test
**Command:** `bash bubbles/scripts/done-spec-audit-selftest.sh`
**Claim Source:** not-run
**Reason:** Done-spec all-scope behavior was not executed for BUG-024 delivery.

### T-BUG-024-026

**Phase:** test
**Command:** `bash tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh --case all-scope-consumers`
**Claim Source:** not-run
**Reason:** Default/explicit all-scope canary bytes do not exist.

### T-BUG-024-027

**Phase:** test
**Command:** `/bin/bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`
**Claim Source:** not-run
**Reason:** The complete changed shell set does not exist.

### T-BUG-024-028

**Phase:** test
**Command:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod`
**Claim Source:** not-run
**Reason:** Test-owned delivery artifact lint has not executed after physical regression creation.

### T-BUG-024-029

**Phase:** test
**Command:** `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod`
**Claim Source:** not-run
**Reason:** Test-owned delivery freshness validation has not executed after physical regression creation.

### T-BUG-024-030

**Phase:** test
**Command:** `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod`
**Claim Source:** not-run
**Reason:** Test-owned delivery G094 validation has not executed after physical regression creation.

### T-BUG-024-031

**Phase:** test
**Command:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-024-traceability-sequential-scope-and-tiered-dod`
**Claim Source:** not-run
**Reason:** Complete packet traceability cannot pass while planned physical test/source/evidence bytes are absent.

### T-BUG-024-032

**Phase:** test
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Claim Source:** not-run
**Reason:** Full framework validation has not run against registered BUG-024 delivery bytes.

### T-BUG-024-033

**Phase:** test
**Command:** `bash bubbles/scripts/install-provenance-selftest.sh`
**Claim Source:** not-run
**Reason:** BUG-024 managed/source-only provenance assertions do not exist.

### T-BUG-024-034

**Phase:** docs
**Command:** `bash bubbles/scripts/capability-ledger-selftest.sh`
**Claim Source:** not-run
**Reason:** Capability registration and owner-generated projections do not exist.

### T-BUG-024-035

**Phase:** releases
**Command:** `bash bubbles/scripts/generate-release-manifest.sh && bash bubbles/scripts/generate-release-manifest.sh --check && bash bubbles/scripts/cli.sh release-check`
**Claim Source:** not-run
**Reason:** Release owner has not generated BUG-024 release identity.

### T-BUG-024-036

**Phase:** test
**Command:** `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab --current-scope`
**Claim Source:** not-run
**Reason:** Canonical-source current-scope replay requires implemented canonical bytes.

### T-BUG-024-037

**Phase:** test
**Command:** `cd ../research-lab && bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab`
**Claim Source:** not-run
**Reason:** Canonical-source all-scope proof requires implemented canonical bytes.

### T-BUG-024-038

**Phase:** devops
**Command:** `cd ../research-lab && bash .github/bubbles/scripts/cli.sh upgrade`
**Claim Source:** not-run
**Reason:** Supported downstream upgrade requires validated canonical release identity.

### T-BUG-024-039

**Phase:** test
**Command:** `cd ../research-lab && bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab --current-scope`
**Claim Source:** not-run
**Reason:** Installed current-scope replay requires supported upgrade delivery.

### T-BUG-024-040

**Phase:** test
**Command:** `cd ../research-lab && bash .github/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab`
**Claim Source:** not-run
**Reason:** Installed all-scope proof requires supported upgrade delivery.

## Planning Validation Boundary

Plan-phase synchronization, scenario hashing, artifact lint, freshness, G094,
traceability, editor diagnostics, and diff-integrity outcomes are recorded in
`state.json.execution.planningValidation`. They validate planning shape only
and satisfy none of T-BUG-024-000 through T-BUG-024-040. Full framework
validation, install provenance, release checks, status transition, DoD
validation, physical RED/GREEN, and source tests remain not run by their
declared owners.

## Finding Accounting

| Finding | Evidence | Disposition | Required owner |
| --- | --- | --- | --- |
| `BUG024-P001-FOUNDATION-ORDERING` | [Scope Inventory](scopes.md#scope-inventory) | addressed: exactly two runtime scopes; Scope 1 is `foundation:true`; Scope 2 depends on Scope 1 | none |
| `BUG024-P002-TEST-MATRIX-DRIFT` | [Scope 1](scopes.md#scope-1-applicable-universe-and-dod-extraction-foundation), [Scope 2](scopes.md#scope-2-guard-integration-terminal-parity-and-canonical-delivery) | addressed: 19 scenarios and 41 synchronized rows/DoD/anchors | none |
| `BUG024-P003-CHANGE-BOUNDARY-DRIFT` | [Shared Change Boundary](scopes.md#shared-change-boundary) | addressed: surgical guard/selftest regions plus owner-separated provenance/docs/release/downstream delivery | none |
| `BUG024-T001-FINAL-BYTE-RED-REQUIRED` | [T-BUG-024-000](#t-bug-024-000) | unresolved: physical `test_31` and stable-source causal RED are absent | `bubbles.test` |
| `BUG024-F001-SEQUENTIAL-SCOPE-APPLICABILITY` | unconditional `scope_files` construction plus 28 descendant findings | unresolved production defect; implementation waits for causal RED | `bubbles.implement` |
| `BUG024-F002-TIERED-DOD-BOUNDARY` | fixed any-heading exit plus nine empty-DoD findings | unresolved production defect; implementation waits for causal RED | `bubbles.implement` |
| `BUG024-RELATED-018` | BUG-018 report/scopes classify the 37 later findings separately | addressed as deduplication; BUG-018 remains closed to this packet | none |
| `BUG024-INTAKE-COMPLETE` | nine substantive packet artifacts created together | addressed by this invocation; no gate pass claimed | none |

## Containment

This planning invocation modified only `scopes.md`, `test-plan.json`,
`scenario-manifest.json`, planning-owned report anchors/routing,
`uservalidation.md`, and execution-owned `state.json` inside the BUG-024
packet. It did not edit production source, tests, release metadata, existing
bug packets, or Research Lab. Protected concurrent dirty bytes were observed
but not normalized, reverted, or absorbed.

## Invocation Audit

No orchestrator or specialist subagent was invoked. This is the directly
authorized plan phase of an active top-level `bubbles.goal` `bugfix-fastlane`
run, and the user explicitly forbade another orchestrator. The handoff is a
`route_required` result to `bubbles.test` for final-byte causal RED, not a
represented dispatch.

## Uncertainty Declaration

> **What was attempted:** The authoritative spec/design and all packet
> artifacts were reconciled into two scopes; exact Markdown/JSON/DoD/report
> parity, scenario hashes, packet gates, traceability, diagnostics, and change
> containment were checked.
> **What was observed:** Planning shape is synchronized. Canonical traceability
> remains nonzero because `test_31` is absent and the current DoD extractor
> still truncates both tiered DoD sections.
> **Why this is uncertain:** No final regression bytes, causal RED,
> implementation, managed selftest GREEN, framework validation, release,
> supported upgrade, or installed replay exists for BUG-024.
> **What would resolve this:** `bubbles.test` creates the final source-only
> regression and captures stable-source causal RED before `bubbles.implement`
> changes production bytes.
