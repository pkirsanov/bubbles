# BUG-051 Design - Separate Framework and Project Roots

## Root Cause Analysis

### Investigation Summary

The validator sets `REPO_ROOT` to two parents above its script. That expression
resolves to the repository root from `bubbles/scripts`. It resolves to
`.github` from `.github/bubbles/scripts` after installation.

The Python scan receives that value and runs
`repo_root.glob("specs/**/scenario-manifest.json")`. No later resolver corrects
the project root.

### Root Cause Hypothesis

One shell variable conflates the framework bundle root with the consuming
repository root. The source layout hides the conflation because both lookups
work from the same two-parent anchor.

The hypothesis fails if an installed fixture with both manifest layouts already
reports both files through the installed script.

### Impact Analysis

- **Affected component:** installed YAML schema validation.
- **Affected data:** downstream top-level and nested scenario manifests.
- **Affected users:** every repository that consumes an installed Bubbles copy.
- **Safety boundary:** malformed discovered manifests must still fail.

## Fix Design

### Solution Approach

Resolve two explicit locations:

1. Resolve the framework asset root relative to the validator script.
2. Resolve the consuming repository root through the supported source and installed layout contract.
3. Pass the repository root to project-artifact scans.
4. Pass the framework root to schema lookups.

Keep the recursive `specs/**/scenario-manifest.json` glob unchanged. Do not
create a second scan under `.github/specs`.

Extend `install-provenance-selftest.sh` with one installed fixture that contains
both manifest layouts. Execute the installed validator, not the source script,
against that fixture. Assert the discovered count and both paths. Add a malformed
nested manifest as the adversarial failure case.

### Downstream Regression Intent

The test must prove behavior after installation. A source-only validator run
cannot close this defect. The fixture must use the same `.github/bubbles`
projection that downstream repositories receive.

### Alternative Approaches Considered

1. **Change the glob to `../specs/**`.** Rejected because Python path traversal would encode another layout-specific depth.
2. **Copy downstream specs under `.github`.** Rejected because project artifacts do not belong in the managed framework tree.
3. **Test only the source validator.** Rejected because source layout masks the defect.
4. **Skip manifest validation downstream.** Rejected because it preserves the enforcement gap.

## Complexity Tracking

None - two named roots are the smallest repair that represents the two path authorities.