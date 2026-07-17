# Bug: BUG-018 Traceability Test Plan Heading Depth

## Summary

The production `traceability-guard.sh` recognizes only a level-3
`### Test Plan` heading. A planning artifact accepted with a level-2
`## Test Plan` heading therefore produces no extracted rows, and the unguarded
grep pipeline exits the whole `set -e` script before the guard emits its
intended diagnostic.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - A blocking framework gate rejects a valid planning artifact without a diagnostic
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status

- [x] Reported
- [x] Confirmed from current downstream evidence and canonical source inspection
- [ ] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reproduction Steps

1. Create a per-scope feature packet whose scope contains Gherkin scenarios and
   a concrete Markdown Test Plan table under `## Test Plan`.
2. Keep all scenario-manifest links and planned test files valid so heading
   extraction is the only discriminator.
3. Confirm the packet is accepted by the artifact/planning surface that allows
   the level-2 heading.
4. Run the production `bubbles/scripts/traceability-guard.sh` against the
   feature directory under its normal `set -e` and `pipefail` contract.
5. Observe that output stops immediately after `Checking traceability for ...`
   and the process exits `1` without a missing-heading, missing-row, or final
   traceability summary diagnostic.

## Expected Behavior

- Both `## Test Plan` and `### Test Plan` are recognized when those shapes are
  valid planning artifacts.
- The selected section ends at the next Markdown heading of the same or a
  shallower depth, so nested headings cannot leak rows between sections.
- A recognized section with concrete rows reaches normal scenario-to-row
  mapping.
- A missing Test Plan section or a section with no concrete rows produces a
  stable, scope-qualified diagnostic and a nonzero final guard verdict.
- An expected no-match condition cannot terminate the guard through `set -e`.
- The implementation and persistent regression remain portable across macOS
  and Linux and exercise the production guard rather than a copied parser.

## Actual Behavior

`extract_test_rows` calls `extract_section "$scope_path" '^### Test Plan'` and
then pipes the result through three `grep` commands. A level-2 heading is never
selected. The final no-match status propagates through command substitution,
and `set -e` terminates the process before the caller's existing empty-row
diagnostic executes.

## Environment

- Canonical repository: `/Users/pkirsanov/Projects/bubbles`
- Downstream reporter: Research Lab Feature 007 Scope 01
- Canonical component: `bubbles/scripts/traceability-guard.sh`
- Downstream installed component: `.github/bubbles/scripts/traceability-guard.sh`
- Platform observed: macOS
- Date observed: 2026-07-15

## Error Output

The current downstream output and provenance are preserved in
[report.md](report.md#bug-reproduction---before-fix). The discriminating tail
is:

```text
All linked tests from scenario-manifest.json exist

Checking traceability for scopes/01-capability-foundation/scope.md
FEATURE007_TRACEABILITY_EXIT=1

Command exited with code 1
```

No traceability finding or summary is emitted after the scope announcement.

## Root Cause

Two defects compose:

1. The Test Plan section selector hardcodes the level-3 heading instead of
   recognizing the valid heading depths accepted by planning artifacts.
2. Expected `grep` no-match status is not handled as data, so command
   substitution becomes a fatal `set -e` control-flow edge before the caller
   can report the problem.

The shared `extract_section` helper also terminates only on `^###` followed by
a space, so simply changing the selector regex to include `##` would not
provide correct section boundaries for both depths.

## Change Boundary

Allowed future implementation surfaces:

- `bubbles/scripts/traceability-guard.sh`
- one focused traceability selftest only if an existing managed selftest cannot
  carry the regression
- `tests/regression/test_25_traceability_test_plan_heading_depth.sh`
- direct traceability registration and release-manifest inputs required to run
  that persistent regression
- this BUG-018 packet and direct bug index documentation if required by the
  owning documentation phase

Excluded surfaces:

- Research Lab Feature 007 source, tests, planning artifacts, or installed
  `.github/bubbles/**` files
- rewriting valid downstream `## Test Plan` headings as a workaround
- weakening scenario-to-row, file-existence, or evidence checks
- broad Markdown parsing refactors unrelated to Test Plan extraction
- generated release files edited by hand

## Related

- Reporter: `/Users/pkirsanov/Projects/research-lab/specs/007-technical-analysis-decision-lab/scopes/01-capability-foundation/report.md`
- Canonical source: `bubbles/scripts/traceability-guard.sh`
- Related existing packet: `improvements/BUG-013-g028-sensitive-client-storage-classification` owns the independent F007-S01-004 scanner finding

## Routing

This is an artifact-only bug intake. No implementation, regression test, broad
validation, release generation, or downstream mutation occurred. The immediate
next owner is `bubbles.design` to reconcile the discovery-phase design, followed
by `bubbles.plan`, `bubbles.implement`, `bubbles.test`, `bubbles.docs`, and
`bubbles.validate` under `bugfix-fastlane`.
