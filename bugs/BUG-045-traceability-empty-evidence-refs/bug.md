# Bug: BUG-045 - Traceability accepts empty evidence reference arrays

## Summary

`traceability-guard.sh` counts any `evidenceRefs` value whose JSON type is
`array` as evidence coverage. An empty array therefore satisfies the manifest
cross-check and produces the false pass line `records evidenceRefs for all`.

This packet owns only `F-B037-GAPS-TRACEABILITY-EMPTY-REF-018`. It does not
change BUG-037 or absorb either of BUG-037's other open findings.

## Severity

- [ ] Critical - System unusable or data loss
- [x] High - A blocking evidence-integrity guard can return a false pass
- [ ] Medium - Feature broken with a reliable workaround
- [ ] Low - Minor issue

## Status

- [ ] Reported
- [x] Confirmed (reproduced)
- [ ] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

Current lifecycle state remains `in_progress`. The defect is packeted and routed
to `bubbles.implement`; no source repair is part of this invocation.

## Origin Finding

- Finding: `F-B037-GAPS-TRACEABILITY-EMPTY-REF-018`
- Origin packet: `bugs/BUG-037-uservalidation-opt-out-acceptance`
- Original observation: BUG-037 had three scenario contracts with empty
  `evidenceRefs` arrays while the guard reported coverage for all 19 scenarios.
- Current-byte qualification: a concurrent BUG-037 owner populated those arrays
  before this packet's clean measurement. The current manifest measured 19
  typed arrays, 19 non-empty arrays, and 0 empty arrays. BUG-037 is therefore a
  non-reproducing control now, not this packet's RED fixture.

## Reproduction Steps

1. Create the same one-scenario feature shape used by
   `traceability-guard-selftest.sh`.
2. Keep its Gherkin, Test Plan row, linked test file, report reference, and DoD
   mapping valid.
3. Set the scenario's `evidenceRefs` to `[]`.
4. Run `bash bubbles/scripts/traceability-guard.sh <fixture>`.
5. Observe exit 0 and the line `scenario-manifest.json records evidenceRefs for
   all 1 scenario contract(s)`.

The executed fixture is
`/private/tmp/bubbles-bug045-empty-evidence-fixture-386921a3`. It is diagnostic
input only and is not part of the repository change.

## Expected Behavior

A scenario contributes to the evidence-reference coverage count only when
`evidenceRefs` is an array with at least one member. A manifest containing an
empty array must make the guard exit non-zero and report the exact covered count.

## Actual Behavior

The production guard exits 0 for the one-scenario empty-array fixture. It reports
that evidence references exist for all scenarios even though the only array has
cardinality zero.

## Environment

- Repository: canonical Bubbles source
- Framework version recorded by tool log: `7.28.0`
- Platform: macOS
- Shell used for reproduction: Homebrew Bash
- Repository binding: session `vscode-d6173f50fde08e4fc6fdf133dac19e92`,
  decision revision 4 for node `reconcile-bug-037-validation-registry`

## Error Output

```text
--- Scenario Manifest Cross-Check (G057/G059) ---
scenario-manifest.json covers 1 scenario contract(s)
scenario-manifest.json linked test exists: tests/widget-render.e2e.spec.ts
scenario-manifest.json records evidenceRefs for all 1 scenario contract(s)
All linked tests from scenario-manifest.json exist
...
RESULT: PASSED (0 warnings)
BUG045_EMPTY_REF_DIRECT_REPRO_EXIT=0
```

## Root Cause

The controlling assignment in `bubbles/scripts/traceability-guard.sh` filters
scenarios only by this condition:

```jq
(.evidenceRefs | type) == "array"
```

It never evaluates `(.evidenceRefs | length) > 0`. The resulting count is then
compared with `scenario_manifest_total`; equal counts select the pass branch.
The remaining traceability checks derive report coverage from `scopes.md` and
its Test Plan rows, not from each manifest scenario's `evidenceRefs` contents,
so no later check closes the hole.

## Fix Boundary

Allowed implementation surfaces:

- `bugs/BUG-045-traceability-empty-evidence-refs/**`
- `bubbles/scripts/traceability-guard.sh`
- `bubbles/scripts/traceability-guard-selftest.sh`

The implementation owner must not edit BUG-037, BUG-033, the release manifest,
session control files, downstream repositories, refs, worktrees, or remotes.

## Related

- Origin: `bugs/BUG-037-uservalidation-opt-out-acceptance`
- Controlling guard: `bubbles/scripts/traceability-guard.sh`
- Focused regression owner: `bubbles/scripts/traceability-guard-selftest.sh`
- Related gate family: G057/G059 scenario traceability

## Deferred Reason

Not deferred. Source repair is routed to `bubbles.implement` under the resolved
`fix target:bug action:fastlane` workflow, persisted as `bugfix-fastlane`.
