# Bug: BUG-012 G085 First-Adoption Deadlock

## Summary

Gate G085 rejects the first feature transition in a genuinely newly adopted downstream repository because its downstream decision requires a historical `status: done` spec that cannot exist yet.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - Major workflow blocked, no compliant downstream workaround
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status

- [ ] Reported
- [x] Confirmed from operator-supplied Research Lab transition evidence and controlling-path inspection
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reproduction Steps

1. Install Bubbles into a downstream repository that has no historical Bubbles feature completion.
2. Create the repository's first numbered feature specs; leave all top-level states nonterminal while the first feature proceeds through its workflow.
3. Run the state-transition guard for that first feature.
4. Observe delegated Gate G085 invoke `framework-dogfood-guard.sh` for the downstream repository.
5. Observe G085 reject the transition because `doneCount=0`, even though a completed spec is the outcome the first workflow is trying to reach.

## Expected Behavior

A downstream repository that is genuinely in its first Bubbles adoption cycle can pass G085 without a pre-existing done spec. The exception must be mechanically limited to first adoption. Once the repository has historical completed-spec evidence, G085 must continue requiring at least one numbered top-level spec with `status: done` and must reject regressions that erase or bypass that evidence.

## Actual Behavior

The downstream branch of `bubbles/scripts/framework-dogfood-guard.sh` counts numbered feature states and fails whenever `DONE_COUNT < 1`. It has no signal that distinguishes a genuinely new adoption from an established repository whose historical done evidence is missing.

## Environment

- Framework source: canonical `/Users/pkirsanov/Projects/bubbles`
- Downstream reporter: Research Lab
- Downstream state: two numbered specs, both `not_started`, no historical done spec
- Platform: macOS
- Date observed: 2026-07-12

## Error Output

The operator reports that Research Lab's post-setup transition failed Gate G085 because both downstream specs were `not_started` and no historical done spec existed. Current-session command-backed reproduction is recorded in [report.md](report.md).

## Root Cause

The downstream decision in `bubbles/scripts/framework-dogfood-guard.sh` models all zero-done repositories as equivalent. `DONE_COUNT < 1` is sufficient to detect absent dogfood evidence in established repositories, but insufficient to identify a bootstrap repository that has never had an opportunity to create that evidence. The guard therefore makes its own required evidence a prerequisite for producing the first instance of that evidence.

## Change Boundary

Allowed surfaces:

- `bubbles/scripts/framework-dogfood-guard.sh`
- `bubbles/scripts/framework-dogfood-guard-selftest.sh`
- `tests/regression/test_04_framework_dogfooding.sh`
- G085 registry and operator documentation directly describing this contract
- This BUG-012 packet and source bug log/index entries

Excluded surfaces:

- Downstream installed framework copies, including Research Lab `.github/bubbles/**`
- Unrelated gates and state-transition checks
- Release-train, deployment, observability, or product runtime code

## Related

- Gate: G085 `framework_dogfood_evidence_gate`
- Guard: `bubbles/scripts/framework-dogfood-guard.sh`
- Recipe: `docs/recipes/framework-dogfood.md`
- Reporter: Research Lab onboarding
