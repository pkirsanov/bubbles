# Expected Behavior: BUG-019 State Transition Compound MJS Test Path

## Problem Contract

State-transition Check 8 must extract a complete concrete test path from Test
Plan rows before checking the filesystem. A suffix marker that appears inside a
longer filename is not a complete path match, and prose is not a test path.

## Actors

- A planner naming concrete test files in Markdown Test Plan rows.
- An implementer relying on Check 8 to distinguish existing tests from missing
  implementation work.
- A validator comparing state-transition and traceability outcomes.
- A downstream repository consuming immutable installed framework bytes.

## Requirements

### BR-001 Preserve Compound MJS Paths

The production Check 8 path must preserve `*.spec.mjs` and `*.test.mjs` tokens
through extraction and filesystem existence checks.

### BR-002 Preserve Existing Controls

The repair must preserve complete ordinary controls including `*.spec.ts` and
`*.test.js`, plus currently supported simple extensions such as `.sh`, `.rs`,
`.py`, and `.go`.

### BR-003 Require A Whole Path Token

A supported suffix must terminate the extracted path token at an allowed
delimiter or the end of the backtick block. Inputs such as
`tests/example.spec.mjs.backup` must not be reduced to and accepted as
`tests/example.spec` or `tests/example.spec.mjs`.

### BR-004 Reject Prose Matches

Backticked prose such as `the prose token example.spec.mjs is illustrative`
must not produce a concrete test path merely because one word has a supported
suffix shape.

### BR-005 Preserve Command-Wrapped Paths

The existing Check 8 contract for command cells such as
`bash tests/example.sh` must remain intact. Tightening whole-token behavior must
not restore the earlier whole-backtick-command false failure.

### BR-006 Align Concrete Path Semantics

For a Test Plan path also linked by `scenario-manifest.json`, Check 8 and
traceability must resolve the same complete file token.

### BR-007 Persistent Production-Path Regression

A committed regression must invoke the real
`bubbles/scripts/state-transition-guard.sh` Check 8 path against disposable
repositories. A copied regex unit test is insufficient.

### BR-008 Failing-First Contract

The production-path regression must fail against the current canonical source
because the real `.spec.mjs` path is reported missing as `.spec`. The same
regression must pass after the repair. Discovery evidence is not a substitute
for this specialist-owned RED and GREEN execution.

### BR-009 Adversarial Matrix

The persistent regression must contain all of these cases:

| Case | Input | Required extraction |
| --- | --- | --- |
| reporter compound path | `tests/palm-springs-rental-market-lab.spec.mjs` | complete input path |
| compound test path | `tests/example.test.mjs` | complete input path |
| ordinary spec control | `tests/example.spec.ts` | complete input path |
| ordinary test control | `tests/example.test.js` | complete input path |
| extension-prefix adversary | `tests/example.spec.mjs.backup` | no accepted test path |
| prose adversary | `the prose token example.spec.mjs is illustrative` | no accepted test path |

The matrix must assert exact path and guard behavior, not only process exit.

### BR-010 No Bailout

The regression may not use a conditional return, skipped case, missing-fixture
pass, or broad output exclusion that converts absent expected behavior into
success.

### BR-011 Cross-Platform Shell

The repair and regression must run on macOS and Linux using portable shell and
userland forms. They must remain compatible with the repository's declared
shell baseline and portability guard.

### BR-012 Canonical-Only Delivery

The repair must land only in canonical Bubbles. Research Lab receives it only
through the supported release/install/upgrade path; no installed-framework
file may be patched directly.

## Acceptance Scenarios

```gherkin
Feature: Check complete test path tokens before filesystem validation

  Scenario: Compound MJS test paths remain complete
    Given Test Plan rows name existing .spec.mjs and .test.mjs files
    When the production state-transition guard executes Check 8
    Then Check 8 verifies the complete paths
    And it does not report their .spec or .test prefixes missing

  Scenario: Existing compound controls retain complete paths
    Given Test Plan rows name existing .spec.ts and .test.js files
    When the production state-transition guard executes Check 8
    Then Check 8 verifies each complete control path

  Scenario: Extension prefixes and prose do not become test paths
    Given Test Plan cells contain an extension-prefix filename and extension-shaped prose
    When the production state-transition guard executes Check 8
    Then neither input is accepted as a concrete test path
    And no shorter prefix is checked on disk
```

## Non-Goals

- Changing traceability Test Plan heading extraction owned by BUG-018.
- Accepting every possible JavaScript module naming convention without a
  concrete framework contract.
- Replacing all Markdown Test Plan extraction with a new parser.
- Editing downstream managed framework copies or reporter planning artifacts.
- Claiming a source repair, regression pass, or release from this intake.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
