# Bug: BUG-019 State Transition Compound MJS Test Path

## Summary

State-transition Check 8 truncates complete `.spec.mjs` and `.test.mjs` Test
Plan paths to `.spec` and `.test`, then reports the derived prefixes as missing
even when the complete files exist.

## Severity

- [ ] Critical - System unusable, data loss
- [ ] High - Major feature broken, no workaround
- [x] Medium - A blocking governance check false-fails valid test paths
- [ ] Low - Minor issue, cosmetic

## Status

- [x] Reported
- [x] Confirmed with current-session canonical and reporter discriminators
- [ ] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reporter Finding

- Finding: `AUD-005-S01-004`
- Reporter repository: Research Lab, read-only for this intake
- Reporter feature: `specs/005-palm-springs-rental-market-lab`
- Real test: `tests/palm-springs-rental-market-lab.spec.mjs`
- Canonical owner: this BUG-019 packet

## Reproduction Steps

1. Confirm the reporter's `test-plan.json` and scenario manifest name
   `tests/palm-springs-rental-market-lab.spec.mjs` and that the file exists.
2. Feed the same token through the exact extension regex used by canonical and
   installed `state-transition-guard.sh` Check 8.
3. Observe that the extracted token ends at `.spec`.
4. Apply the installed Check 8 pipeline to the reporter's real `scopes.md`
   Test Plan rows.
5. Observe 21 derived `tests/palm-springs-rental-market-lab.spec` paths, all
   nonexistent, while the complete `.spec.mjs` path exists.
6. Run the reporter's installed traceability guard and observe that it resolves
   the exact `.spec.mjs` linked test and exits `0`.

## Expected Behavior

- Check 8 preserves `.spec.mjs` and `.test.mjs` as complete path tokens.
- Existing `.spec.ts` and `.test.js` paths remain complete.
- Simple supported paths such as `.sh`, `.rs`, and `.py` retain current
  behavior.
- A supported extension must terminate the path token. A filename whose
  supported suffix is only a prefix, such as `.spec.mjs.backup`, is not a
  valid test path.
- Backticked prose containing an extension-shaped substring is not accepted as
  a test file.
- Check 8 and traceability agree on the concrete test path.

## Actual Behavior

The current expression is:

```text
[A-Za-z0-9._/-]+\.(spec|test|rs|ts|tsx|js|jsx|sh|bash|bats|py|go|java|scala|dart)\b
```

For `.spec.mjs` and `.test.mjs`, `mjs` is not an accepted terminal extension,
while the word boundary before the next dot permits the shorter `.spec` or
`.test` prefix to match. The same boundary accepts extension-prefix filenames
and extension-shaped prose substrings.

## Environment

- Canonical repository: `/Users/pkirsanov/Projects/bubbles`
- Canonical component: `bubbles/scripts/state-transition-guard.sh`, Check 8
- Reporter repository: `/Users/pkirsanov/Projects/research-lab` (read-only)
- Installed component: `.github/bubbles/scripts/state-transition-guard.sh`
- Platform observed: macOS
- Date observed: 2026-07-15

## Error Output

Current-session reporter-path evidence is preserved in
[report.md](report.md#reporter-check-8-reproduction---before-fix). The
discriminating result is:

```text
REAL_PATH=tests/palm-springs-rental-market-lab.spec.mjs
REAL_PATH_EXISTS=yes
FALSE_MISSING_ROW=01 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=02 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=03 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=04 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=05 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=06 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=07 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=08 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=09 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_COUNT=21
```

## Root Cause

Check 8 treats a set of simple terminal extensions and the marker suffixes
`.spec` and `.test` as one flat alternation. It does not model compound test
suffixes such as `.spec.mjs`. Its `\b` boundary accepts the shorter marker
before another dot, so extraction returns a syntactically valid prefix rather
than the complete Test Plan token. The Markdown row scan then performs a real
filesystem check against that invented prefix.

## Distinction From BUG-018

BUG-018 owns `traceability-guard.sh` Test Plan heading-depth selection and a
silent `set -e` no-match exit. BUG-019 owns `state-transition-guard.sh` Check 8
path-token extraction. The reporter's traceability guard exits `0` and resolves
the exact `.spec.mjs` path, which is a direct discriminator between the two
defects. BUG-018 is not changed by this intake.

## Change Boundary

Allowed implementation surfaces after design and planning reconciliation:

- `bubbles/scripts/state-transition-guard.sh`, limited to Check 8 extraction
- `tests/regression/test_26_state_transition_spec_mjs_path.sh`
- the narrow selftest or framework-validation registration needed to execute
  that regression
- generator-owned release inputs only when required by canonical validation
- this BUG-019 packet and its compact `BUGS.md` entry

Excluded surfaces:

- Research Lab source, tests, specs, or installed `.github/bubbles/**` files
- BUG-012, BUG-013, and BUG-018 artifacts
- rewriting reporter Test Plan paths as a workaround
- weakening Check 8 file existence or allowing arbitrary extension substrings
- broad Test Plan or Markdown parser replacement without new evidence
- hand-edited generated release artifacts

## Related

- Reporter finding: `AUD-005-S01-004`
- Reporter evidence: `specs/005-palm-springs-rental-market-lab/report.md`
- Canonical source: `bubbles/scripts/state-transition-guard.sh`
- Adjacent unrelated bug: `improvements/BUG-018-traceability-test-plan-heading-depth`

## Routing

This invocation owns intake and discovery only. The immediate owner is
`bubbles.design` to reconcile the root-cause and minimal-fix design before
`bubbles.plan` reconciles the regression and scope contracts. No source fix,
test implementation, post-fix execution, release mutation, or certification
occurred.
