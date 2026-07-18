# User Validation: BUG-025 Skills-First Map Merged Rows

Evidence source: [report.md](report.md)

## Checklist

The checked intake baseline confirms only that the defect contract was captured.
Implementation and verification items remain unchecked.

- [x] **Artifact intake baseline:** The two merged-row defects, expected table
  contract, affected routes, and no-fix boundary are recorded in this packet
  without claiming map repair or regression execution.
  - **Evidence:** [Source Inspection Evidence](report.md#source-inspection-evidence)
  - **Claim Source:** interpreted

- [ ] **Four independent routes:** Scope authoring, feature-folder creation,
  fix-cycle work, and skill authoring occupy four separate rows.
  - **Verify:** Run `T-BUG-025-02`.
  - **Claim Source:** not-run
- [ ] **Row cardinality:** Every map data row has exactly two nonempty cells.
  - **Verify:** Run `T-BUG-025-02` and `T-BUG-025-03`.
  - **Claim Source:** not-run
- [ ] **Situation uniqueness:** Duplicate normalized situations fail with both
  row identities.
  - **Verify:** Run `T-BUG-025-04`.
  - **Claim Source:** not-run
- [ ] **Target resolution:** Every target resolves to an existing skill;
  unknown and duplicate targets fail while a valid multi-target row passes.
  - **Verify:** Run `T-BUG-025-04`.
  - **Claim Source:** not-run
- [ ] **Merged-row prevention:** Exact current `| ||` fixtures and independent
  re-merges of each repaired row fail.
  - **Verify:** Run `T-BUG-025-03` and `T-BUG-025-05`.
  - **Claim Source:** not-run
- [ ] **Framework provenance:** Focused, install, framework, and release checks
  pass against final canonical bytes.
  - **Verify:** Run `T-BUG-025-06` through `T-BUG-025-09`.
  - **Claim Source:** not-run
