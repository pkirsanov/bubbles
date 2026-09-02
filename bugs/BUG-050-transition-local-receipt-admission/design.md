# BUG-050 Design - Transition Evidence Admission View

## Root Cause Analysis

### Investigation Summary

Check 43 locates the repository root and opens one global tool log. It invokes
`evidence-receipt-check.sh --strict` on that complete file. Its inline clone
analysis then reads the same complete file.

`evidence-receipt-check.sh` can supersede older receipts with the same evidence
identity. It cannot decide whether a current identity belongs to this
transition. Check 9 and `scenario-state-resolve.sh` have stronger scenario and
claim bindings, but Check 43 does not consume their admitted subset.

### Root Cause

The evidence pipeline lacks one reusable transition-admission view. Each
consumer selects rows independently. Check 43 therefore equates repository-wide
current history with transition evidence.

This conflation also obscures phase semantics. RED is historical proof that
precedes implementation. Mutation proof establishes test sensitivity against a
captured source and verifies restoration. Current source equality is appropriate
for post-fix proof, not for those historical receipts.

### Impact Analysis

- **Affected components:** semantic evidence admission, receipt freshness, clone detection, scenario state derivation, and mutation proof checks.
- **Affected data:** append-only tool-call and mutation receipt stores.
- **Affected users:** every repository with more than one receipt campaign.
- **Safety boundary:** actively admitted stale or incompatible evidence must still fail.

## Fix Design

### Solution Approach

Create one transition admission projection from the active packet and tool log.
The projection must contain only receipts that can support current checked DoD
items and scenario obligations.

Reuse the semantic bindings already required by Check 9.

- Bind the target spec.
- Require an explicit scenario pointer.
- Bind the scenario record.
- Bind the receipt phase.
- Require complete claim coverage.
- Require a command.
- Require outcome compatibility.
- Apply the phase-aware revision rule.

Pass this projection to both Check 43 consumers. The original log remains
untouched.

`evidence-receipt-check.sh` should accept an explicit admitted-view input or a
structured filter contract. It must not infer a target from CWD. Its default
full-log reporting mode may remain for standalone diagnostics. Strict transition
use must always supply the admitted view.

Move the Check 43 clone program into a helper if required. Feed the same
admitted view to focused identity tests and the full guard. Preserve existing
identity definitions and BUG-033 bounds.

### Phase-Aware Revision Rules

- **RED:** admit a receipt as historical proof when its scenario, test identity,
  negative control, and ordering relationship are valid. Do not require current
  source equality.
- **IMPLEMENT:** use the implementation change receipt appropriate to the
  candidate transition.
- **GREEN, LIVE, REGRESSION, OBSERVED:** keep current source or candidate
  compatibility requirements.
- **Mutation:** validate `sourceDigest == restoredDigest`, a distinct mutant,
  expected failure signature, observed failure, and isolated execution. Do not
  compare `sourceDigest` with current production bytes.

The design must not let a historical RED receipt satisfy GREEN. Phase remains a
required binding.

### Test Design

Add four admission fixtures:

1. Active fresh receipts plus many unrelated stale rows must pass.
2. One admitted stale receipt must block.
3. Active clean receipts plus unrelated clone groups must pass.
4. One admitted incompatible clone group must block with identity detail.

Add a scenario-state fixture where RED cites pre-change source and GREEN cites
the current candidate. It must derive the ordered pair without admitting stale
GREEN evidence.

Add or extend mutation receipt fixtures so later production source changes do
not invalidate an earned kill. Keep the existing restoration, isolation, and
forgery adversaries.

Run `receipt-identity-selftest.sh` unchanged or with additive active-admission
cases. Every BUG-033 protection must remain green.

### Alternative Approaches Considered

1. **Delete stale rows.** Rejected. It violates append-only evidence history.
2. **Ignore all stale receipts.** Rejected. Actively admitted stale proof must block.
3. **Scope only by spec string.** Rejected. One spec can hold several scopes, scenarios, phases, and incompatible claims.
4. **Disable cross-spec clone checks globally.** Rejected. Reusing one receipt for incompatible active claims must remain detectable.
5. **Require every historical source hash to match current source.** Rejected. That destroys test-first RED and earned mutation history.
6. **Add an ignore flag.** Rejected. Admission is a contract, not a bypass.

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Shared admission projection | Filter Check 43 by `.spec` only | Spec matching cannot distinguish phase, scenario, claim, or active obligation. |
| Phase-aware revision rules | Exempt all old receipts | Broad age exemptions would admit stale post-fix proof. |
