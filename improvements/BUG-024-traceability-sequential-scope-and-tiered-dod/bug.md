# Bug: BUG-024 Traceability Sequential Scope And Tiered DoD

## Summary

`traceability-guard.sh` conflates active sequential scope closure with final
feature validation and truncates Definition of Done extraction at nested tier
headings. A valid completed active scope can therefore be blocked by
not-started descendant scopes and can be reported as having no DoD items even
when its accepted tiered DoD contains checkboxes.

## Severity

- [ ] Critical - System unusable or data loss
- [x] High - A blocking framework gate prevents legitimate sequential scope closure
- [ ] Medium - Feature broken with a reliable workaround
- [ ] Low - Minor or cosmetic issue

## Status

- [x] Reported
- [x] Confirmed by current canonical source inspection and current-session reproduction
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reporter And Unblocking Target

- Downstream consumer: Research Lab Feature 007, Scope 01
- Active workflow: top-level `bubbles.goal` full-delivery
- Canonical repository: `/Users/pkirsanov/Projects/bubbles`
- Affected component: `bubbles/scripts/traceability-guard.sh`
- Current active scope: `01-capability-foundation`, status `blocked`
- Not-started descendants: Scopes 02 through 09 in a strict dependency chain
- Required canonical release train: `framework-next`

This packet records an upstream framework defect. It does not certify Research
Lab Feature 007 and does not alter any downstream managed framework copy.

## Reproduction Steps

1. Use a complete per-scope-directory packet with a strict dependency chain.
2. Set `state.json.execution.currentScope` to the active first scope, mark that
   scope `blocked` or `in_progress`, and mark its dependent descendants
   `not_started`.
3. Give the active scope complete scenario, Test Plan, concrete test, report,
   and tiered DoD evidence.
4. Leave descendant scope reports and mappings in their honest not-started
   state.
5. Run the real canonical guard from the consumer repository root:
   `bash ../bubbles/bubbles/scripts/traceability-guard.sh specs/007-technical-analysis-decision-lab`.
6. Observe that the guard analyzes every `scopes/*/scope.md`, emits 28 delivery
   findings from Scopes 02 through 09, reports no DoD items for all nine scopes,
   and exits `1` with 37 findings.

## Expected Behavior

- The existing one-argument guard invocation retains all-scope behavior.
- A distinct state-bound active-scope closure context checks the current scope,
  completed prerequisites, and every other scope that is presently applicable.
- Only a scope whose status is exactly `not_started` and whose dependency path
  makes it a descendant of the current scope may be omitted from active-scope
  closure findings.
- A descendant that becomes active, completed, or otherwise applicable is
  checked and can block.
- Final validation, audit, done-spec audit, and explicit all-scope execution
  check every scope and continue to catch any descendant gap.
- Missing, invalid, ambiguous, or contradictory state in active-scope context
  fails loud. No all-scope or empty-set fallback is permitted.
- A DoD section at level 2 or level 3 retains nested tier headings and ends only
  at the next sibling or ancestor heading, matching BUG-018's heading-depth
  boundary semantics for Test Plan extraction.
- Existing single-file packets and no-scenario diagnostics retain their current
  behavior unless active-scope context is explicitly requested and validated.

## Actual Behavior

### Sequential Scope Applicability

The per-scope-directory branch runs `find ... -name scope.md | sort` and appends
every result to `scope_files`. Every file then feeds `scope_analysis_files`, the
G057/G059 scenario-manifest pass, delivery traceability, and G068. The guard
reads only `scopeLayout` from `state.json`; it never consumes `currentScope`,
scope status, dependency edges, or completed-scope state.

### Tiered DoD Extraction

`extract_dod_items()` enters on a level-1 through level-4 heading containing
`Definition of Done` or `DoD`, then exits on the next level-1 through level-4
heading. For the accepted shape below, the first `####` tier heading ends the
section before any checkbox is read:

```markdown
### Definition of Done

#### Core Delivery Items

- [x] The behavioral contract is complete.

#### Build Quality Gate

- [ ] The complete gate is green.
```

## Current Reproduction Result

The current-session canonical reproduction exited `1`. Its terminal summary
reported 32 scenarios, 90 rows, 22 mappings, four report references, zero DoD
fidelity scenarios, and 37 failures. The exact observed output is recorded in
[report.md](report.md#bug-reproduction---before-fix).

## Root Cause

Two independent local decisions compose into one blocking result:

1. Scope discovery is also scope applicability. The guard has no intermediate
   applicability model, so filesystem presence makes every scope active for
   every pass.
2. DoD extraction uses a fixed any-heading terminator rather than remembering
   the selected DoD heading depth. A deeper tier heading is misclassified as a
   section boundary.

The first defect is not fixed safely by skipping all `not_started` scopes. Such
a rule would hide independent applicable work and would weaken final feature
validation. The second is not fixed safely by ignoring all level-4 headings,
because a level-4 DoD section must still end at a level-4 sibling.

## Falsifiable Hypothesis

If a disposable complete packet is held constant while only invocation context,
scope status/dependency state, or DoD heading depth changes, then:

- active-scope context must change only descendant applicability findings;
- default/all-scope context must continue to expose the descendant gap; and
- level-2 and level-3 DoD sections must produce the same checkbox set while a
  sibling or ancestor section remains excluded.

Any cross-case change to scenario mapping, path resolution, report evidence,
or BUG-018 Test Plan behavior falsifies the proposed boundary.

## Change Boundary

### Candidate canonical surfaces

- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`
- reserved regression `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`
- direct source-only framework-validation registration for that regression
- direct install-provenance assertions for changed managed/source-only files
- owner-regenerated release metadata after source and tests are stable
- direct managed documentation owned by later workflow phases

### Protected surfaces

- `bubbles/release-manifest.json` during this intake
- every file under BUG-018, BUG-022, and BUG-023
- `tests/regression/test_25_traceability_test_plan_heading_depth.sh`
- `tests/regression/test_23_planning_audit_contract.sh`
- `tests/regression/test_26_state_transition_spec_mjs_path.sh`
- `tests/regression/test_30_planning_transition_applicability_and_baseline.sh`
- all Research Lab files and installed `.github/bubbles/**` bytes
- unrelated traceability matching heuristics and state-transition G068 logic

## Related And Deduplication

- Related canonical packet:
  `improvements/BUG-018-traceability-test-plan-heading-depth/`
- BUG-018 repaired Test Plan heading-depth extraction, caller survival, and
  owner-root path resolution. Its scopes and report explicitly classify the
  remaining Feature 007 findings as separate packet-owned traceability work.
- BUG-024 does not reopen BUG-018 and requires its regression to remain
  byte-identical and green.
- Consumer evidence:
  `/Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab/`

## Routing

This is an artifact-only intake. No implementation source, test, release,
existing bug packet, or Research Lab byte changed. The exact next required
owner is `bubbles.design` for the `bugfix-fastlane` bootstrap design ownership
step. After design reconciliation, `bubbles.plan` owns the final scope,
scenario-manifest, and test-plan contract. The reserved regression must then be
written and executed RED by `bubbles.test` before `bubbles.implement` changes
production bytes.
