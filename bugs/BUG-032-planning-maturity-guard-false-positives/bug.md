# Bug: BUG-032 Planning-Maturity Guard False Positives

**Canonical packet:** `bugs/BUG-032-planning-maturity-guard-false-positives/`
**Source registry:** `BUGS.md`
**Filed:** 2026-08-15
**Owner surface:** Cross-cutting framework guard behavior

## Summary

Four framework checks use proxies that are broader than the contracts they claim
to enforce. Real planning-maturity validation in a downstream repository exposed
false blocks in consumer-impact classification, SLA classification, evidence
receipt clone detection, and required-feature delivery reconciliation.

This packet plans the fixes only. It does not change guard scripts, selftests,
workflow registries, generated assets, or downstream installations.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - valid planning or certification can be blocked, and one finding
  falsely alleges evidence reuse
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Controlling source mechanisms confirmed by current-session source reads
- [x] Planning in progress
- [ ] Executable pre-fix regression captured in the persistent selftests
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Defect Inventory

| ID | Guard surface | False-positive behavior | Required invariant |
| --- | --- | --- | --- |
| D1 | `bubbles/scripts/guards/planning-checks.sh`, Check 8B | Generic replacement prose containing an interface-shaped noun such as `path` triggers Consumer Impact Sweep requirements even when no consumer interface changes. Provider and lifecycle replacement prose has the same failure shape. | Only an actual route, path, endpoint, contract, API, URL, slug, identifier, symbol, link, breadcrumb, navigation, or redirect rename/removal/deprecation triggers the sweep. |
| D2 | `bubbles/scripts/state-transition-guard.sh`, Check 5A | Explicit opt-out prose such as `observability is opted out and no trace or SLO evidence is injected` is treated as an SLA promise and therefore requires stress coverage. | Negated or opted-out wording does not trigger. Genuine latency, throughput, response-time, p95, p99, SLA, and SLO declarations still trigger. |
| D3 | `bubbles/scripts/state-transition-guard.sh`, Check 43 | Separate runs of one deterministic validator against different spec targets can emit identical non-empty stdout and are classified as a cloned receipt because grouping starts from `stdoutHash`. | Independent executions of the same validator family and evidence category over distinct targets are not clones. One substantive result reused across unrelated command families or categories still blocks. Empty-stdout handling remains unchanged. |
| D4 | `bubbles/scripts/release-delivery-reconciliation-guard.sh`, G101 | `specs_hardened` can satisfy `delivery=required` after validate certification because terminal-for-mode is treated as delivered. | Planning maturity never means product delivery. Only delivery-capable terminal states, interpreted through the resolved mode contract and validate certification, may satisfy `delivery=required`. |

## Reproduction Context

### Downstream observation

**Claim Source:** interpreted - operator-supplied current-session problem statement,
not execution performed by this agent.

The operator reported the four defects while validating Ozhiva planning maturity.
The report included stale generation-path replacement prose, provider/lifecycle
replacement prose, an explicit no-SLO observability posture, deterministic
`artifact-lint.sh` runs over distinct spec directories, and a
`product-to-planning` packet at `specs_hardened` with validate certification.

No downstream repository was read or modified in this invocation. Repository
authority is bound to the canonical Bubbles source checkout.

### Source confirmation

**Claim Source:** interpreted - current-session reads of the controlling source.

1. Check 8B applies one verb/noun co-occurrence expression to each complete
   scope file and includes generic `replace`, `replaced`, and `migration` terms.
2. Check 5A classifies a scope with a single positive-token grep and has no
   negation or opt-out branch.
3. Check 43 groups non-empty receipts by `stdoutHash`, then compares derived
   command identities. Its premise says different commands cannot honestly emit
   identical stdout, which deterministic validators disprove.
4. G101 calls terminal-for-mode and also carries a fallback allowlist containing
   `validated`, `docs_updated`, `specs_hardened`, and
   `delivered_pending_activation` without separating planning, review, docs, and
   delivery semantics.

## Reproduction Steps For The Delivery Run

These are the required future red-stage steps. They are not claimed as executed
in this planning invocation.

1. Add the negative and positive Check 8B fixtures described in `spec.md` to
   `bubbles/scripts/state-transition-guard-selftest.sh`.
2. Add the negative opt-out and positive SLO/latency fixtures for Check 5A to the
   same selftest.
3. Add two independent deterministic validator receipts with identical non-empty
   stdout, distinct spec targets, and distinct execution provenance to the Check
   43 selftest block. Add the unrelated-command adversarial twin and retain the
   empty-stdout cases.
4. Add a G101 fixture whose state is `specs_hardened`, whose mode is
   `product-to-planning`, and whose completed phases include `validate`.
5. Run the focused selftests before guard changes. The newly added assertions
   must fail for D1-D4 while the existing positive controls remain green.
6. Record the full red output in `report.md` before changing production guards.

## Expected Behavior

- Benign replacement prose does not demand a Consumer Impact Sweep.
- Explicit no-SLO, no-SLA, unavailable, not-applicable, and opted-out posture
  sentences do not demand stress coverage unless the same declaration contains
  a genuine quantitative performance contract.
- Separate deterministic validator executions are distinguished by command
  family, evidence category, target/input closure, exit status, and execution
  provenance rather than by stdout bytes alone.
- `delivery=required` rejects planning-only and review-only terminal states.
- Existing protection remains active for actual consumer-interface mutations,
  genuine performance promises, unrelated-command receipt reuse, non-delivery
  states, and prototype-only states.

## Actual Behavior

The current proxies classify each of the reported negative cases as if it were a
positive contract declaration. The resulting blocks are false because the
underlying consumer interface, performance promise, receipt identity, or product
delivery fact is absent.

## Root Cause

The shared root cause is semantic overreach: content similarity or lifecycle
terminality is treated as proof of the narrower fact the gate is intended to
enforce.

- Check 8B conflates nearby words with an interface mutation.
- Check 5A conflates a mentioned term with an affirmative promise.
- Check 43 conflates equal output bytes with shared execution identity.
- G101 conflates terminal-for-mode with delivered-to-release.

`design.md` defines narrow positive contracts and adversarial controls for each
case. It deliberately avoids broad exemptions.

## Impact

- Valid planning packets can be blocked until authors add irrelevant sections or
  stress plans.
- Honest evidence can receive the framework's serious clone/fabrication finding.
- A required release feature can be falsely counted as delivered at a planning
  ceiling, which is an enforcement hole rather than only a false block.
- Downstream authors may distort planning prose to appease classifiers, reducing
  the truthfulness of their artifacts.

## Environment

- Framework: canonical Bubbles source checkout
- Platform: macOS
- Discovery context: downstream Ozhiva planning-maturity validation, supplied by
  the operator
- Source revision: intentionally not asserted; this planning invocation did not
  capture a revision receipt

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

- Any guard, selftest, registry, generated asset, or downstream-install edit in
  this invocation
- Reworking all natural-language classifiers in the framework
- Weakening stale-receipt checks
- Disabling clone detection or exempting all deterministic output
- Changing Ozhiva planning artifacts to work around framework behavior
- Reclassifying `delivered_prototype` as deployable

## Related

- `BUGS.md` BUG-028 records D3 as an open standalone finding. BUG-032 subsumes
  its implementation planning and must reconcile BUG-028 when D3 is delivered.
- `BUGS.md` BUG-007 protects empty-stdout handling.
- `BUGS.md` BUG-019 protects equivalent command-spelling normalization.
- Check 43 was introduced under IMP-027 evidence integrity work.
- G101 identifies its original owner as IMP-006 in source comments and selftests.

## Deferred Reason

Implementation is deliberately deferred because the operator requested a
planning-only invocation. The next delivery owner must begin with failing
persistent regression fixtures and must not edit a production guard before the
red evidence exists.
