# BUG-052 Design - Certification-First Scope Progress Resolution

## Root Cause Analysis

### Investigation Summary

The guard selects scope progress with
`(.scopeProgress // .certification.scopeProgress // [])`. Current selftests
exercise top-level and certification shapes independently. They do not create a
state document that carries both fields.

jq's alternative operator does not treat `[]` as absent. A deprecated empty
array therefore terminates selection before the canonical field is read.

### Root Cause Hypothesis

The field order preserves an older top-level authority model. Strict version 3
state moved canonical scope progress under `certification`, but this guard did
not invert its compatibility precedence.

The hypothesis fails if the unchanged guard blocks a fixture with top-level
`[]` and a canonical over-depth graph.

### Impact Analysis

- **Affected component:** plan dependency-depth guard input selection.
- **Affected data:** version 3 states that retain a deprecated top-level field.
- **Affected users:** plan authors relying on block posture.
- **Safety boundary:** legacy top-level-only states must remain readable.

## Fix Design

### Solution Approach

Select `certification.scopeProgress` first. Fall back to top-level
`scopeProgress` only when the canonical field is absent or null. Keep the final
empty-array no-op.

Update the source comment to name certification as canonical and top-level as
deprecated compatibility. Do not append `execution.scopeProgress` to the jq
chain. Execution may carry an optional agreement overlay, but it cannot choose
the graph that enforcement evaluates.

Add four paired fixtures to the nearest selftest:

1. Top-level `[]` plus canonical over-depth graph must block.
2. Canonical shallow graph plus legacy over-depth graph must pass.
3. Legacy top-level-only over-depth graph must still block.
4. Canonical shallow graph plus execution over-depth graph must still use canonical data.

### Downstream Regression Intent

The primary RED fixture must use a complete state document with both field
locations. Separate single-field fixtures cannot detect precedence regressions.

### Alternative Approaches Considered

1. **Treat empty arrays as absent.** Rejected because a present canonical empty array is an authoritative value.
2. **Add `execution.scopeProgress` as another fallback.** Rejected because execution is not strict version 3 authority.
3. **Remove top-level compatibility.** Rejected because legacy state remains supported when certification data is absent.
4. **Change the dependency-depth algorithm.** Rejected because graph evaluation is correct after input selection.

## Complexity Tracking

None - reversing two authority operands and adding paired fixtures is the smallest viable repair.