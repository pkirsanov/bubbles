# User Validation: BUG-018 Traceability Test Plan Heading Depth

Evidence source: [report.md](report.md)

## Checklist

Checked entries describe the accepted validation contract and current
discovery baseline. They do not claim implementation, test execution, release
readiness, or validate-owned certification.

### Discovery Baseline

- [x] **Baseline:** A current downstream scope with `## Test Plan` reaches the
  first traceability scope announcement and then exits `1` without a finding or
  final summary.
  - **Evidence:** [Before Fix](report.md#bug-reproduction---before-fix)

- [x] **Baseline:** Canonical source hardcodes `^### Test Plan` and exposes
  expected grep no-match to `set -e` through command substitution.
  - **Evidence:** [Canonical Source Inspection](report.md#canonical-source-inspection)

### Supported Heading Shapes

- [x] **Contract SCN-BUG-018-001 - Level-2 Test Plan:** A valid `## Test Plan` packet
  must map every scenario and complete normally.
  - **Steps:** Run the production guard against the planned level-2 fixture.
  - **Expected:** All expected scenario-to-row mappings appear; exit `0`.
  - **Verify:** `T-BUG-018-01`.
  - **Evidence:** [GREEN Production-Path Regression](report.md#green-production-path-regression)

- [x] **Contract SCN-BUG-018-002 - Level-3 compatibility:** The equivalent
  `### Test Plan` packet must retain identical mappings.
  - **Steps:** Run the production guard against otherwise identical level-2 and
    level-3 fixtures and compare mapping sets.
  - **Expected:** Mapping sets and successful verdicts are equal.
  - **Verify:** `T-BUG-018-02`.
  - **Evidence:** [GREEN Production-Path Regression](report.md#green-production-path-regression)

### Diagnostic Integrity

- [x] **Contract SCN-BUG-018-003 - Invalid input fails loud:** Missing exact
  headings and recognized empty, header-only, or separator-only Test Plans must
  produce distinct scope-qualified diagnostics.
  - **Steps:** Run each invalid fixture through the production guard.
  - **Expected:** Missing input reports the exact-heading diagnostic; recognized
    rowless input reports the concrete-row diagnostic; each reaches one normal
    nonzero summary without an immediate post-announcement exit.
  - **Verify:** `T-BUG-018-03`, `T-BUG-018-04`.
  - **Evidence:** [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival)

- [x] **Contract SCN-BUG-018-003 - Expected no-scenario no-match:** A scope
  without Gherkin scenarios must reach its explicit diagnostic and the final
  summary rather than exit from command substitution.
  - **Steps:** Run the no-scenario disposable packet through the production guard.
  - **Expected:** The existing scope-qualified no-scenario diagnostic and normal
    nonzero final summary are both present.
  - **Verify:** `T-BUG-018-06`.
  - **Evidence:** [Diagnostic And Caller Survival](report.md#diagnostic-and-caller-survival)

- [x] **Contract SCN-BUG-018-004 - Section boundaries:** Nested deeper content
  remains inside a Test Plan while rows under the next same-or-shallower section
  stay excluded for both accepted start depths.
  - **Steps:** Run the boundary fixture and inspect mapped rows.
  - **Expected:** Nested Test Plan rows map; the adversarial sibling row cannot
    create an extra mapping or linked-path failure.
  - **Verify:** `T-BUG-018-05`.
  - **Evidence:** [Boundary And Adversarial Regression](report.md#boundary-and-adversarial-regression)

### Portability And Caller Startup

- [x] **Contract - macOS Bash 3.2:** The production guard starts under sanitized
  macOS system `/bin/bash` with optional fun mode disabled and preserves normal
  behavior on Bash 4+.
  - **Steps:** Run the persistent matrix under the sanitized system-only path,
    run Bash syntax for all changed BUG-018 shell files, run portability only
    over BUG-018-authored implementation/test surfaces, and validate the exact
    framework-registration hunk independently.
  - **Expected:** Startup succeeds without associative arrays or namerefs; all
    changed shell parses; owned surfaces are portable; unrelated
    `framework-validate.sh` lines are not claimed by the portability result.
  - **Verify:** `T-BUG-018-07`, `T-BUG-018-10`, `T-BUG-018-19`.
  - **Evidence:** [Portability And Bash 3.2](report.md#portability-and-bash-32)

### Canonical Delivery Boundary

- [x] **Boundary:** BUG-018 intake changes only canonical improvement artifacts
  and does not edit Research Lab, installed `.github/bubbles/**`, production
  source, tests, registry, or release files.
  - **Evidence:** [Completion Statement](report.md#completion-statement)

- [x] **Contract - direct consumers:** BUG-012 and BUG-013 retain existing
  level-3 behavior; canonical downstream behavior uses an owned disposable
  Research-Lab-shaped fixture; the current Research Lab packet is checked with
  canonical source from its own repository root.
  - **Expected for `T-BUG-018-17`:** The guard resolves Feature 007, recognizes
    all 32 manifest-linked tests, traverses all nine scopes, reaches the normal
    final summary, emits no path-resolution or extractor failure, and does not
    stop after a scope announcement. Exit `1` may report the foreign packet's
    37 nonterminal traceability findings; this contract does not classify those
    findings as passed or resolved.
  - **Ownership boundary:** Full Feature 007 traceability belongs to Feature 007
    Scope 09 and is not a BUG-018 completion prerequisite.
  - **Verify:** `T-BUG-018-11`, `T-BUG-018-12`, `T-BUG-018-17`.
  - **Evidence:** [Consumer Regression](report.md#consumer-regression) and
    [T-17 Source Compatibility Planning Contract](report.md#t-17-source-compatibility-planning-contract)

- [x] **Contract - canonical delivery:** Consumers receive the repair only through
  canonical release/install/upgrade provenance.
  - **Expected:** Installed guard bytes match the validated release; no manual
    downstream workaround or managed-file edit occurs; installed Research Lab
    replay runs only after supported upgrade delivery.
  - **Verify:** `T-BUG-018-14`, `T-BUG-018-15`, `T-BUG-018-16`,
    `T-BUG-018-18`.
  - **Evidence:** [Release And Install Provenance](report.md#release-and-install-provenance)
