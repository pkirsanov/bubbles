# Bug: BUG-051 YAML Validator Downstream Root Misresolution

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source finding:** `FP-YAML-DOWNSTREAM-ROOT`
- **Affects:** `bubbles/scripts/yaml-schema-validate.sh` and `bubbles/scripts/install-provenance-selftest.sh`

## Summary

The YAML schema validator derives one root for both framework assets and project
artifacts. That root points at the repository in source layout but at `.github`
after a downstream install. The installed validator therefore scans
`.github/specs/**` and reports no scenario manifests.

## Packet Route

The fix changes validation behavior in every downstream installation. It uses a
full source bug packet and routes through `bugfix-fastlane`.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - downstream scenario manifests silently escape schema validation
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Root-cause hypothesis grounded by current-session source inspection
- [ ] Executable RED regression captured
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Reproduction Steps

1. Create a downstream install fixture with a Git repository root.
2. Install Bubbles under `.github/bubbles/` in that fixture.
3. Add one top-level `specs/<feature>/scenario-manifest.json` file.
4. Add one nested `specs/<feature>/bugs/<bug>/scenario-manifest.json` file.
5. Run the installed `.github/bubbles/scripts/yaml-schema-validate.sh`.
6. Compare its manifest count with the source-layout validator result.

These are pre-production RED steps. This filing invocation did not execute
them.

## Expected Behavior

The source and installed validators scan the consuming repository's
`specs/**/scenario-manifest.json` tree. Both top-level and nested manifests are
validated against the installed scenario manifest schema.

## Actual Behavior

The reported installed run prints `specs/**/scenario-manifest.json (none
present)`. Source inspection shows that two parents above
`.github/bubbles/scripts` is `.github`, not the consuming repository root.

## Root Cause Hypothesis

`REPO_ROOT` serves two unrelated roles. It locates installed framework schemas,
and it anchors project-owned artifact discovery. The two roles share a path in
source layout but diverge after installation.

The installed-fixture RED test can disconfirm this hypothesis. It must show that
the installed validator already discovers both project-root manifests.

## Impact

- Downstream scenario manifests can avoid schema validation.
- The validator emits a clean-looking skip instead of exposing the missing scan.
- Nested bug manifests receive the same false-negative treatment.
- Source-only validation can pass while the installed behavior remains broken.

## Environment

- Repository: canonical Bubbles source worktree
- Revision: `830883fd5639ac066cb3d40a2a40a567cc3df22f`
- Platform: macOS
- Discovery source: downstream Ozhiva transition review

## Scope Boundary

### Included

- Separate framework schema location from consuming repository root resolution
- Installed validation of top-level scenario manifests
- Installed validation of nested bug scenario manifests
- A malformed installed manifest adversary
- Source and installed layout parity
- Required generated release manifest update after implementation

### Excluded

- Scenario manifest schema changes
- Installer redesign
- Changes to unrelated YAML registry validation
- Production or selftest edits during filing
- Downstream product artifact edits

## Related

- `bubbles/scripts/yaml-schema-validate.sh` derives `REPO_ROOT` two parents above the script.
- `bubbles/scripts/install-provenance-selftest.sh` already creates installed downstream fixtures.

## Filing Evidence

**Claim Source:** interpreted

The root derivation and recursive scan path were read in this invocation. The
reported downstream output is operator-provided diagnostic input. No RED
execution result is claimed.