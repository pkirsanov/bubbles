# User Validation: BUG-026 Traceability Sequential Scope And Tiered DoD

Evidence source: [report.md](report.md)

## Checklist

The checked intake baseline confirms only identity recovery and substantive
defect capture. Runtime and delivery behaviors remain unchecked.

- [x] **Artifact intake baseline:** BUG-026 records the collision history, the
  37-finding consumer result, both root causes, the BUG-018 boundary, the
  reserved noncolliding regression path, and the no-delivery boundary without
  claiming unavailable transient bytes or runtime repair.
  - **Evidence:** [Identity Collision Record](report.md#identity-collision-record), [Inherited Consumer Reproduction](report.md#inherited-consumer-reproduction---before-fix)
  - **Claim Source:** interpreted

- [ ] **Sequential scope context:** Current-scope traceability omits only exact
  `not_started` transitive descendants and preserves every required visible
  scope class.
  - **Verify:** Run `T-BUG-026-02`, `T-BUG-026-10`, and `T-BUG-026-19`.
  - **Claim Source:** not-run
- [ ] **Fail-closed state:** Invalid registries, aliases, dependencies, paths,
  completion facts, phases, and terminal contexts refuse before analysis.
  - **Verify:** Run `T-BUG-026-03` through `T-BUG-026-06`.
  - **Claim Source:** not-run
- [ ] **Tiered DoD semantics:** Starts at depths 1-4 retain nested tiers through
  depth 6 while false headings and depth-5/6 starts remain inert.
  - **Verify:** Run `T-BUG-026-07`, `T-BUG-026-08`, and `T-BUG-026-11`.
  - **Claim Source:** not-run
- [ ] **All-scope compatibility:** Default and explicit all-scope contexts keep
  every physical scope and unchanged G068 thresholds.
  - **Verify:** Run `T-BUG-026-08`, `T-BUG-026-10`, and `T-BUG-026-17`.
  - **Claim Source:** not-run
- [ ] **BUG-018 compatibility:** test_25 bytes are unchanged and its heading-
  depth behavior remains green.
  - **Verify:** Run `T-BUG-026-12`.
  - **Claim Source:** not-run
- [ ] **Guard parity:** State-transition Check 4A and Check 22 share tiered DoD
  boundaries while state-transition remains all-scope.
  - **Verify:** Run `T-BUG-026-11` and `T-BUG-026-14`.
  - **Claim Source:** not-run
- [ ] **Portable delivery:** Focused, framework, provenance, release, source,
  and installed downstream checks pass on stable final bytes.
  - **Verify:** Run `T-BUG-026-09` and `T-BUG-026-13` through `T-BUG-026-20`.
  - **Claim Source:** not-run

## Goal

- Goal: close the active sequential scope using only applicable traceability
  while preserving all real and final-context findings.
- Success signal: the Feature 007 Scope 01 current-scope replay removes exactly
  the 28 descendant and nine rowless-DoD false classes, with all-scope,
  BUG-018, state-transition, and malformed-state regressions still green.

## Journey Steps

| Step | User Intent | Observed | Evidence | Friction |
| --- | --- | --- | --- | --- |
| 1 | Validate one current sequential scope | Current guard analyzes every physical scope | [Consumer reproduction](report.md#inherited-consumer-reproduction---before-fix) | broken |
| 2 | Keep tiered completion evidence visible | Current G068 parser reports all nine DoDs rowless | [Current source inspection](report.md#current-source-inspection) | broken |

## Open Refinements

- `bubbles.design` owns reconciliation of the strict state, projection, CLI,
  parser, and parity contracts before any final test bytes are written.
