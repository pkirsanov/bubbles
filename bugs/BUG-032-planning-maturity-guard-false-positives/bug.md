# Bug: BUG-032 Planning-Maturity Guard False Positives

**Canonical packet:** `bugs/BUG-032-planning-maturity-guard-false-positives/`
**Source registry:** `BUGS.md`
**Filed:** 2026-08-15
**Owner surface:** Cross-cutting framework guard behavior

## Summary

Four framework checks used proxies broader than their intended contracts.
Downstream planning validation exposed false results in consumer impact, SLA,
receipt identity, and release delivery classification.

D1 through D4 are now implemented and covered by focused persistent tests.
Planning reconciliation records Scopes 1 through 3 as Done. BUG-032 remains
`in_progress` because Scope 4 and validate-owned certification remain open.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - the defects blocked valid planning or certification, and one
  finding falsely alleged evidence reuse
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Historical reproductions captured in persistent regression evidence
- [x] D1 through D4 implemented
- [x] Focused regression and adversarial controls recorded
- [x] Scopes 1 through 3 Done
- [ ] Scope 4 full validation complete
- [ ] Validate-certified
- [ ] Closed

## Defect Inventory

| ID | Guard surface | Historical defect | Current implemented contract |
| --- | --- | --- | --- |
| D1 | `bubbles/scripts/guards/planning-checks.sh`, Check 8B | Replacement or migration prose could trigger Consumer Impact Sweep without an interface mutation. | The bounded classifier requires an explicit interface mutation relationship. It preserves direct mutations and fails closed on ambiguity or overflow. |
| D2 | `bubbles/scripts/state-transition-guard.sh`, Check 5A | Explicit no-SLA, no-SLO, unavailable, or opted-out prose could require stress coverage. | Explicit non-affirmative posture does not trigger. A target, budget, threshold, guarantee, comparator, or quantitative unit still triggers. |
| D3 | `bubbles/scripts/state-transition-guard.sh`, Check 43 | Equal non-empty stdout could make independent deterministic validator runs look like cloned receipts. | Identity derives from normalized program plus dispatch script, target or input closure, numeric exit, and independent execution provenance. Evidence category remains known non-mixed sanity and diagnostic metadata only. Matching or differing labels do not establish a clone. |
| D4 | `bubbles/scripts/release-delivery-reconciliation-guard.sh`, G101 | Terminal-for-mode plus validate certification could make planning maturity satisfy `delivery=required`. | Planning, docs-only, validate-only, and prototype terminality cannot satisfy release delivery. Delivery-capable terminality plus validate certification remains required. |

## Historical Discovery And Reproduction

### Downstream observation

**Claim Source:** interpreted - operator-supplied discovery context preserved as
history, not execution by this reconciliation.

The operator reported the four defects while validating Ozhiva planning maturity.
The report included stale generation-path replacement prose, provider/lifecycle
replacement prose, an explicit no-SLO observability posture, deterministic
`artifact-lint.sh` runs over distinct spec directories, and a
`product-to-planning` packet at `specs_hardened` with validate certification.

The original discovery invocation treated the downstream report as operator
input. It did not claim that report as locally executed evidence.

### Captured RED And GREEN History

**Claim Source:** interpreted - current reads of `report.md`, `scopes.md`, and
the persistent test contracts. These records are not relabeled as new command
evidence.

1. Scope 1 retains pre-fix RED evidence for D1 and D2.
2. Scope 1 retains five-finding RED and implementation GREEN receipts for the
  bounded Check 8B repair.
3. Independent row 34 records exit zero against the frozen Check 8B production
  and persistent-oracle input closure.
4. Scope 2 retains D3 RED evidence and focused current receipt-identity results.
5. Scope 3 retains D4 RED and GREEN evidence plus the current decision table.

### Current Source Confirmation

**Claim Source:** interpreted - current-session reads of production and
persistent-test source.

1. Check 8B uses one bounded sourceable classifier with 128-token and
  eight-candidate limits.
2. Check 5A separates explicit opt-out posture from affirmative quantitative
  performance contracts.
3. Check 43 uses normalized program, dispatch script, target or input closure,
  numeric exit, and independent execution provenance.
4. Check 43 keeps category as known non-mixed sanity and diagnostic metadata.
5. G101 resolves delivery-capable mode semantics before accepting validate
  certification.

## Current Scope And Evidence Status

**Claim Source:** interpreted - current reads of `scopes.md`, `test-plan.json`,
`state.json`, and the planning reconciliation in `report.md`.

- Scope 1 is Done with 27 Markdown rows and 27 machine rows.
- Scope 2 is Done with 7 Markdown rows and 7 machine rows.
- Scope 3 is Done with 7 Markdown rows and 7 machine rows.
- Scope 4 is In Progress. Its full validation and certification work is
  unclaimed.
- Top-level status and certification status remain `in_progress`.
- This reconciliation does not claim `framework-validate`, `release-check`, or
  validate certification for the current tree.

## Expected Behavior

- Benign replacement prose does not demand a Consumer Impact Sweep.
- Explicit no-SLO, no-SLA, unavailable, not-applicable, and opted-out posture
  sentences do not demand stress coverage unless the same declaration contains
  a genuine quantitative performance contract.
- Separate deterministic validator executions are distinguished by normalized
  program plus dispatch script, target or input closure, numeric exit, and
  independent execution provenance.
- Evidence category remains known non-mixed sanity and diagnostic metadata.
  Category-label agreement or difference does not establish cloning.
- `delivery=required` rejects planning-only and review-only terminal states.
- Existing protection remains active for actual consumer-interface mutations,
  genuine performance promises, unrelated-command receipt reuse, non-delivery
  states, and prototype-only states.

## Historical Actual Behavior

Before the repairs, broad proxies classified negative cases as positive contract
declarations. Those statements describe discovery history, not current source
behavior.

## Historical Root Cause

The shared root cause was semantic overreach. Content similarity or lifecycle
terminality stood in for narrower contract facts.

- Check 8B conflated nearby words with an interface mutation.
- Check 5A conflated a mentioned term with an affirmative promise.
- Check 43 conflated equal output bytes with shared execution identity.
- G101 conflated terminal-for-mode with delivered-to-release.

`design.md` defines narrow positive contracts and adversarial controls for each
case. It deliberately avoids broad exemptions.

## Historical Impact

- Valid planning packets could be blocked until authors added irrelevant sections or
  stress plans.
- Honest evidence could receive the framework's serious clone/fabrication finding.
- A required release feature could be falsely counted as delivered at a planning
  ceiling, which is an enforcement hole rather than only a false block.
- Downstream authors could distort planning prose to appease classifiers, reducing
  the truthfulness of their artifacts.

## Environment

- Framework: canonical Bubbles source checkout
- Platform: macOS
- Discovery context: downstream Ozhiva planning-maturity validation, supplied by
  the operator
- Current evidence epoch: frozen Check 8B production and persistent-oracle
  identities recorded in `report.md`

## Scope Boundary

### Included

- Check 8B consumer-surface mutation classification
- Check 5A affirmative SLA/SLO/performance classification
- Check 43 substantive receipt-clone identity
- G101 delivery-capable terminal-state resolution
- Persistent selftests on the existing state-transition and release-delivery
  reconciliation selftest surfaces
- Contract documentation and registry prose that become inaccurate after the
  implementation

### Excluded

- Production guard and persistent-test changes in this reconciliation
- Reworking all natural-language classifiers in the framework
- Weakening stale-receipt checks
- Disabling clone detection or exempting all deterministic output
- Changing Ozhiva planning artifacts to work around framework behavior
- Reclassifying `delivered_prototype` as deployable
- Scope 4 DoD, validate-owned certification, and human acceptance
- BUG-035 and `bubbles/scripts/evidence-capture.sh`

## Related

- `BUGS.md` BUG-028 records D3 as an open standalone finding. BUG-032 subsumes
  its false-accusation implementation. BUG-028 follow-up recommendations and its
  validation-linked closure rule remain open.
- `BUGS.md` BUG-007 protects empty-stdout handling.
- `BUGS.md` BUG-019 protects equivalent command-spelling normalization.
- BUG-035 owns `BUG035-D14-EMPTY-OUTPUT-COUNT` as an unrelated routed sibling.
- Check 43 was introduced under IMP-027 evidence integrity work.
- G101 identifies its original owner as IMP-006 in source comments and selftests.

## Open Disposition

BUG-032 remains open. Scope 4 still requires final contract reconciliation,
full framework and release validation, and validate-owned certification.
BUG-028 must not close before its recorded follow-up and validation conditions
are satisfied.
