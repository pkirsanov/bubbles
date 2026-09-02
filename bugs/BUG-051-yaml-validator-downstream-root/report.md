# BUG-051 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Captured the installed-layout root defect before the production edit.
- Separated the framework bundle root from the consuming project root.
- Added top-level, nested, malformed, and source-parity regression coverage.
- Regenerated the release manifest after the focused test passed.
- Re-ran implementation reality and artifact checks after planning added the
  exact two-file implementation inventory.

## Completion Statement

Scope 01 has current implementation, focused regression, implementation
reality, artifact, and change-boundary evidence. The implementation phase is
complete and routed to `bubbles.test`. The bug and scope remain `in_progress`;
T6 and validate-owned certification remain pending.

## Test Evidence

### RED installed-root reproduction

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash /private/tmp/bug051-yaml-validator-root-probe.sh /private/tmp/bubbles-ozhiva-transition-unblock-ca550392`
**Exit Code:** 1
**Claim Source:** executed
**Evidence Capture SHA-256:** `d25d1d16a8b7bd9408b6c7ef9ad8037cafeb490c57bb87f2346eb0fcdf1839c9`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 53
**Output:**

```text
BUG-051 SOURCE OUTPUT BEGIN
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: PASS  specs/**/scenario-manifest.json (2 file(s))
BUG-051 SOURCE OUTPUT END
BUG-051 SOURCE EXIT=0
BUG-051 INSTALLED OUTPUT BEGIN
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: SKIP  specs/**/scenario-manifest.json (none present)
BUG-051 INSTALLED OUTPUT END
BUG-051 INSTALLED EXIT=0
BUG-051 RED: installed layout did not discover the same two repository manifests
```

### Persistent installed regression

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1400 /opt/homebrew/bin/bash bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `4d524af8cd4ad5d7ab5799f6c1fed80fa6ac0856a3a9e0dd291659bc46f8d6ba`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 58
**Output Window:** lines 326-365 of 365. The capture hash covers every line.

```text
PASS: Adapter is executable: prometheus.sh
PASS: Local install creates schemas/ directory
PASS: Schema installed: workflows.schema.json
PASS: Schema installed: capability-ledger.schema.json
PASS: Schema installed: adoption-profiles.schema.json
BUG-051 source validator output:
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: PASS  specs/**/scenario-manifest.json (2 file(s))
BUG-051 installed validator output:
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: PASS  specs/**/scenario-manifest.json (2 file(s))
PASS: BUG-051 source validator discovers top-level and nested manifests
PASS: BUG-051 installed fixture contains specs/001-feature/scenario-manifest.json
PASS: BUG-051 installed fixture contains specs/001-feature/bugs/BUG-001-nested/scenario-manifest.json
PASS: BUG-051 installed validator executes both repository manifests
PASS: BUG-051 source and installed manifest discovery counts agree
PASS: BUG-051 installed validator does not scan .github/specs
BUG-051 malformed installed validator output:
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: FAIL  specs/001-feature/bugs/BUG-001-nested/scenario-manifest.json — 3 validation error(s)
  scenarios/0: 'title' is a required property
  scenarios/0: 'requiredTestType' is a required property
  scenarios/0/id: 'invalid' does not match '^SCN-[A-Z0-9]+-[0-9]+$'
PASS: BUG-051 malformed nested installed manifest remains blocking and named
PASS: Local install creates/preserves repo-root .gitignore
PASS: Repo-root .gitignore contains improvements/ entry
PASS: Installer did NOT create stray .github/.gitignore with improvements/
PASS: Installed manifest reports 927 managed files (>=300 sanity floor)
install-provenance selftest passed.
```

### Cross-platform shell validation

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `a16baf86c41851b508f19adbea1e5b662941df0aa01f0c66b58577d34f4b2ac6`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 60
**Output:**

```text
== macOS portability guard -- scanning 2 file(s) ==
ok   class-1 raw-timeout: none
ok   class-2 in-place-sed: none
ok   class-3 date-d-parse: none
ok   class-4 stat-c-mtime: none
ok   class-5 readlink-f-absolutize: none
ok   class-6 grep-pcre: none
ok   class-7 bracket-v-isset: none
ok   class-8 mapfile-readarray: none
ok   class-9 mktemp-suffix: none
ok   class-10 df-output: none
ok   class-11 bin-true-false: none
ok   class-12 paste-no-stdin-operand: none
ok   class-13 date-nanoseconds: none
ok   class-14 mktemp-parent-dir: none
ok   class-15 mktemp-nontrailing-x: none
ok   class-16 awk-3arg-match: none

PASS: the scanned surface is WSL+macOS portable.
```

### Managed release manifest

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-release-manifest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 57
**Tool Log Exit Code:** 0
**Tool Log Duration:** 18477 ms
**Tool Log Stdout SHA-256:** `4db88a57bfcd5e4b293807266ccde996d44cd5f9c38260d55f557850c64c9fa6`
**Evidence Capture SHA-256:** `4815d540e941642607988ec417f5b86c003e9bbfb8f02ab8bdcbdc3caf61449a`
**Output:** `Updated release manifest: 7.28.0 (927 managed files)`

### Change boundary

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/git diff --check -- bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json bugs/BUG-051-yaml-validator-downstream-root`
**Command:** `/opt/local/bin/git diff --name-only -- bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json`
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** The tracked implementation delta contains only the two planned scripts and the generated release manifest.
**Output:**

```text
BUG051_FINAL_DIFF_CHECK_BEGIN
BUG051_FINAL_DIFF_CHECK_EXIT=0
BUG051_CHANGED_IMPLEMENTATION_PATHS_BEGIN
bubbles/release-manifest.json
bubbles/scripts/install-provenance-selftest.sh
bubbles/scripts/yaml-schema-validate.sh
BUG051_CHANGED_IMPLEMENTATION_PATHS_EXIT=0
BUG051_CHANGED_IMPLEMENTATION_PATHS_END
```

### Initial implementation reality finding

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 240 /opt/homebrew/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-051-yaml-validator-downstream-root`
**Exit Code:** 1
**Claim Source:** executed
**Evidence Capture SHA-256:** `b783d0cf494df2223d9775fe65a90afab5b6e02e39eb8b2faa77e753148465b6`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 66
**Output:**

```text
ℹ️  INFO: Scopes yielded 0 files — falling back to design.md for file discovery
ℹ️  INFO: No Implementation Files in scopes.md/design.md — falling back to filesystem search for slug 'BUG-051-yaml-validator-downstream-root'
🔴 VIOLATION [ZERO_FILES_RESOLVED] No implementation file paths resolved from scope files

  This means scopes.md / scope.md files either:
    1. Do not reference implementation files in backtick-wrapped paths, or
    2. Reference files that do not exist on disk

  Scanning nothing = no assurance. This is a blocking failure.
  Fix: Ensure scopes.md lists implementation files as `path/to/file.ext`

============================================================
  REALITY SCAN RESULT: 1 violation(s), 0 warning(s)
  Files scanned: 0
============================================================
```

The scanner reads paths from a planning-owned `### Implementation Files`
section. This historical run preceded the planning-owned inventory. The current
scope now names both implementation files, and the resumed scan below resolves
them without a violation.

### Post-planning implementation closeout

#### Current-byte implementation reality

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 300 /opt/homebrew/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-051-yaml-validator-downstream-root`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `361d0a45a81eaddc2c5b1a35c08e531f947d68f88363b101390a2ffe06c2037a`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 84
**Output:**

```text
ℹ️  INFO: Resolved 2 implementation file(s) to scan

--- Scan 1: Gateway/Backend Stub Patterns ---

--- Scan 1B: Handler / Endpoint Execution Depth ---

--- Scan 1C: Endpoint Not-Implemented / Placeholder Responses ---

--- Scan 1D: External Integration Authenticity ---

--- Scan 2: Frontend Hardcoded Data Patterns ---

--- Scan 2B: Sensitive Client Storage ---

--- Scan 3: Frontend API Call Absence ---

--- Scan 4: Prohibited Simulation Helpers in Production ---

--- Scan 5: Default/Fallback Value Patterns ---

--- Scan 6: Live-System Test Interception ---
ℹ️  INFO: No live-system test files referenced in scope artifacts for interception scan

--- Scan 7: IDOR / Auth Bypass Detection (Gate G047) ---

--- Scan 8: Silent Decode Failure Detection (Gate G048) ---

============================================================
  IMPLEMENTATION REALITY SCAN RESULT
============================================================

  Files scanned:  2
  Violations:     0
  Warnings:       0

🟢 PASSED: No source code reality violations detected
```

#### Current artifact structure

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 240 /opt/homebrew/bin/bash bubbles/scripts/artifact-lint.sh bugs/BUG-051-yaml-validator-downstream-root`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 83
**Output:**

```text
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
✅ state.json v3 has required field: policySnapshot
✅ state.json v3 has recommended field: transitionRequests
✅ state.json v3 has recommended field: reworkQueue
✅ state.json v3 has recommended field: executionHistory
✅ Top-level status matches certification.status
ℹ️  Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'in_progress'
✅ report.md contains section matching: ###[[:space:]]+Summary|^##[[:space:]]+Summary
✅ report.md contains section matching: ###[[:space:]]+Completion Statement|^##[[:space:]]+Completion Statement
✅ report.md contains section matching: ###[[:space:]]+Test Evidence|^##[[:space:]]+Test Evidence
✅ Mode-specific report gates skipped (status not in promotion set)
✅ Value-first selection rationale lint skipped (not a value-first report)
✅ Scenario path-placeholder lint skipped (no matching scenario sections found)

=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
```

#### Current change boundary

**Executed:** YES
**Phase:** implement
**Commands:** `/opt/local/bin/git diff --check -- bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json bugs/BUG-051-yaml-validator-downstream-root`; `/opt/local/bin/git diff --name-only -- bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json`
**Exit Code:** 0 for both commands
**Claim Source:** interpreted
**Tool Logs:** `.specify/runtime/tool-calls.jsonl` rows 86-88
**Interpretation:** Diff hygiene produced no diagnostics, and the implementation
delta remains limited to the two planned scripts plus the generated release
manifest and the untracked BUG-051 packet.
**Output:**

```text
 M bubbles/release-manifest.json
 M bubbles/scripts/install-provenance-selftest.sh
 M bubbles/scripts/yaml-schema-validate.sh
?? bugs/BUG-051-yaml-validator-downstream-root/
```

#### Protected neighboring bug bytes

**Executed:** YES
**Phase:** implement
**Command:** `/usr/bin/shasum -a 256 bugs/BUG-047-reasoned-skip-phase-accounting/* bugs/BUG-048-test-plan-owner-label-path/* bugs/BUG-049-separate-process-g040-prefix/* bugs/BUG-050-transition-local-receipt-admission/* bugs/BUG-052-plan-scope-progress-precedence/*`
**Exit Code:** 0 for both executions
**Claim Source:** executed
**Evidence Capture SHA-256 Before:** `8e2df1fb3271f1074481f82f0b729c0e3773947fb8f3555a4e3a1fa3c5ca3892`
**Evidence Capture SHA-256 After:** `8e2df1fb3271f1074481f82f0b729c0e3773947fb8f3555a4e3a1fa3c5ca3892`
**Tool Logs:** `.specify/runtime/tool-calls.jsonl` rows 79 and 89
**Output Window:** 45 checksums were captured before and after reconciliation;
the complete output hash is identical.

```text
BUG-051 protected neighboring bug byte baseline
exit: 0
lines: 45
sha256: 8e2df1fb3271f1074481f82f0b729c0e3773947fb8f3555a4e3a1fa3c5ca3892
BUG-051 protected neighboring bug byte final
exit: 0
lines: 45
sha256: 8e2df1fb3271f1074481f82f0b729c0e3773947fb8f3555a4e3a1fa3c5ca3892
protected packet: BUG-047-reasoned-skip-phase-accounting
protected packet: BUG-048-test-plan-owner-label-path
protected packet: BUG-049-separate-process-g040-prefix
protected packet: BUG-050-transition-local-receipt-admission
protected packet: BUG-052-plan-scope-progress-precedence
result: all protected file checksums are byte-identical
```

#### Execution-state namespace

**Executed:** YES
**Phase:** implement
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/execution-substate-guard.sh bugs/BUG-051-yaml-validator-downstream-root`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 85
**Output:**

```text
[execution-substate-guard] OK — execution substate (if any) is valid and distinct from certification in bugs/BUG-051-yaml-validator-downstream-root.
```

#### Implementation delta paths

**Executed:** YES
**Phase:** implement
**Command:** `/opt/local/bin/git diff --name-only -- bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 87
**Output:**

```text
bubbles/release-manifest.json
bubbles/scripts/install-provenance-selftest.sh
bubbles/scripts/yaml-schema-validate.sh
```

### Independent focused T1-T5 verification

**Executed:** YES
**Phase:** test
**Selected Rows:** T1, T2, T3, T4, T5
**Excluded Row:** T6, by the scenario instruction
**Tool Log Rows:** 93-106
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=20s 1400 /opt/homebrew/bin/bash bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `4d524af8cd4ad5d7ab5799f6c1fed80fa6ac0856a3a9e0dd291659bc46f8d6ba`
**Output Window:** Last 40 lines of 365. The capture hash covers every line.

```text
PASS: Adapter is executable: none.sh
PASS: Adapter installed: prometheus.sh
PASS: Adapter is executable: prometheus.sh
PASS: Local install creates schemas/ directory
PASS: Schema installed: workflows.schema.json
PASS: Schema installed: capability-ledger.schema.json
PASS: Schema installed: adoption-profiles.schema.json
BUG-051 source validator output:
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: PASS  specs/**/scenario-manifest.json (2 file(s))
BUG-051 installed validator output:
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: PASS  specs/**/scenario-manifest.json (2 file(s))
PASS: BUG-051 source validator discovers top-level and nested manifests
PASS: BUG-051 installed fixture contains specs/001-feature/scenario-manifest.json
PASS: BUG-051 installed fixture contains specs/001-feature/bugs/BUG-001-nested/scenario-manifest.json
PASS: BUG-051 installed validator executes both repository manifests
PASS: BUG-051 source and installed manifest discovery counts agree
PASS: BUG-051 installed validator does not scan .github/specs
BUG-051 malformed installed validator output:
yaml-schema-validate: PASS  bubbles/workflows.yaml
yaml-schema-validate: PASS  bubbles/capability-ledger.yaml
yaml-schema-validate: PASS  bubbles/adoption-profiles.yaml
yaml-schema-validate: PASS  bubbles/tool-trust-registry.yaml
yaml-schema-validate: FAIL  specs/001-feature/bugs/BUG-001-nested/scenario-manifest.json — 3 validation error(s)
  scenarios/0: 'title' is a required property
  scenarios/0: 'requiredTestType' is a required property
  scenarios/0/id: 'invalid' does not match '^SCN-[A-Z0-9]+-[0-9]+$'
PASS: BUG-051 malformed nested installed manifest remains blocking and named
PASS: Local install creates/preserves repo-root .gitignore
PASS: Repo-root .gitignore contains improvements/ entry
PASS: Installer did NOT create stray .github/.gitignore with improvements/
PASS: Installed manifest reports 927 managed files (>=300 sanity floor)
install-provenance selftest passed.
```

#### Linked scenario resolution

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 180 /opt/homebrew/bin/bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-051-yaml-validator-downstream-root --repo-root /private/tmp/bubbles-ozhiva-transition-unblock-ca550392`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `596c804c1e26a659adf9302f86fa4a9761f7ee95120affa27fed93353cbdc118`
**Output:** `[scenario-test-resolve] OK — 4 reference(s) resolved via literal-scan`

#### Independent shell portability

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `a16baf86c41851b508f19adbea1e5b662941df0aa01f0c66b58577d34f4b2ac6`
**Output:**

```text
== macOS portability guard -- scanning 2 file(s) ==
ok   class-1 raw-timeout: none
ok   class-2 in-place-sed: none
ok   class-3 date-d-parse: none
ok   class-4 stat-c-mtime: none
ok   class-5 readlink-f-absolutize: none
ok   class-6 grep-pcre: none
ok   class-7 bracket-v-isset: none
ok   class-8 mapfile-readarray: none
ok   class-9 mktemp-suffix: none
ok   class-10 df-output: none
ok   class-11 bin-true-false: none
ok   class-12 paste-no-stdin-operand: none
ok   class-13 date-nanoseconds: none
ok   class-14 mktemp-parent-dir: none
ok   class-15 mktemp-nontrailing-x: none
ok   class-16 awk-3arg-match: none

PASS: the scanned surface is WSL+macOS portable.
```

#### Current release-manifest identity

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `229c480c967b4984a879ab6b9c6442cf009bffecec8f15483ed4fec3ab097a73`
**Output:** `Release manifest is current: 7.28.0 (927 managed files)`

#### Regression and obligation quality

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/regression-quality-guard.sh --bugfix --verbose bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `b7cd466b19972e6b48c077e574ec96d12da4b7a7799df2f447aaa4224b1234e6`
**Output:**

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /private/tmp/bubbles-ozhiva-transition-unblock-ca550392
  Timestamp: 2026-09-02T04:32:12Z
  Bugfix mode: true
============================================================

ℹ️  Scanning bubbles/scripts/install-provenance-selftest.sh
✅ Adversarial signal detected in bubbles/scripts/install-provenance-selftest.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/scenario-obligation-lint.sh bugs/BUG-051-yaml-validator-downstream-root`
**Exit Code:** 0
**Claim Source:** executed
**Evidence Capture SHA-256:** `3979d4214fdb7145fa4cad82986c6a605516b95479ac3ed7f6308d0a62022a0b`
**Output:** `[scenario-obligation-lint] OK — 4 scenario(s) with a coherent derived obligation matrix`

#### Test-mechanism finding

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/test-mechanism-lint.sh bugs/BUG-051-yaml-validator-downstream-root --repo-root /private/tmp/bubbles-ozhiva-transition-unblock-ca550392`
**Exit Code:** 1
**Claim Source:** executed
**Finding:** `F-B051-TEST-MECHANISM-001`
**Owner:** `bubbles.plan`
**Disposition:** Routed in the result envelope; the test agent did not modify the plan-owned scenario contract.
**Output:**

```text
test-mechanism-lint: FAIL — declared mechanism does not support the claim (COV-10)
  NON-VACUITY: SCN-B051-003
    riskTier 'high' needs at least 'mutation' but the control is 'perturbed-input'. Strengthen it, or state a negativeControlFallbackReason naming why it cannot be

test-mechanism-lint: 1 finding(s).
```

#### Planner mechanism repair

**Executed:** YES
**Phase:** bootstrap
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/homebrew/bin/bash bubbles/scripts/test-mechanism-lint.sh bugs/BUG-051-yaml-validator-downstream-root --repo-root /private/tmp/bubbles-ozhiva-transition-unblock-ca550392`
**Exit Code:** 0
**Claim Source:** executed
**Finding:** `F-B051-TEST-MECHANISM-001`
**Owner:** `bubbles.plan`
**Disposition:** Addressed. `SCN-B051-003` now declares the supported `mutation`
mechanism. Its negative control still makes the malformed manifest valid and
requires the installed validator verdict to change from failing to passing.
**Output:**

```text
[test-mechanism-lint] OK — 4 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
```

`F-B051-EVIDENCE-EMPTY-OUTPUT-002` remains separately routed to `bubbles.bug`.
T6 and validate-owned certification remain pending. No source file changed as
part of this planner repair.

#### Current boundary identity

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /usr/bin/shasum -a 256 bugs/BUG-047-reasoned-skip-phase-accounting/* bugs/BUG-048-test-plan-owner-label-path/* bugs/BUG-049-separate-process-g040-prefix/* bugs/BUG-050-transition-local-receipt-admission/* bugs/BUG-052-plan-scope-progress-precedence/*`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 103
**Evidence Capture SHA-256:** `8e2df1fb3271f1074481f82f0b729c0e3773947fb8f3555a4e3a1fa3c5ca3892`
**Result:** The 45 protected packet checksums match the pre-test baseline.

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/local/bin/git diff --name-only -- bubbles/scripts/yaml-schema-validate.sh bubbles/scripts/install-provenance-selftest.sh bubbles/release-manifest.json`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 106
**Evidence Capture SHA-256:** `c9bcc9cf41dc632b1703266ee410b307f4db1becd70740fafdc6b7b57b39666d`
**Output:**

```text
bubbles/release-manifest.json
bubbles/scripts/install-provenance-selftest.sh
bubbles/scripts/yaml-schema-validate.sh
```

**Executed:** YES
**Phase:** test
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/local/bin/git diff --check -- bugs/BUG-051-yaml-validator-downstream-root/report.md bugs/BUG-051-yaml-validator-downstream-root/scopes.md bugs/BUG-051-yaml-validator-downstream-root/state.json`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 105
**Output:** Empty stdout with structured exit 0.

#### Evidence-capture empty-output finding

**Executed:** YES
**Phase:** test
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --lines 40 --label 'BUG-051 independent test-owned artifact diff check' -- /opt/local/bin/gtimeout --signal=TERM --kill-after=5s 120 /opt/local/bin/git diff --check -- bugs/BUG-051-yaml-validator-downstream-root/report.md bugs/BUG-051-yaml-validator-downstream-root/scopes.md bugs/BUG-051-yaml-validator-downstream-root/state.json`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 104
**Finding:** `F-B051-EVIDENCE-EMPTY-OUTPUT-002`
**Owner:** `bubbles.bug`
**Disposition:** Routed in the result envelope; the replacement structured check is row 105.
**Output:**

```text
exit: 0
lines: 0
0
sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
bubbles/scripts/evidence-capture.sh: line 201: [[: 0
0: arithmetic syntax error in expression (error token is "0")
bubbles/scripts/evidence-capture.sh: line 213: 0
0: arithmetic syntax error in expression (error token is "0")
```

#### Independent test verdict

The selected T1-T5 rows passed with zero selected-row failures. T6 did not run.
The execution substate may record independent verification, while the bug and
scope remain `in_progress`. The broader E2E DoD and validate-owned
certification remain unchecked. `F-B051-TEST-MECHANISM-001` remains routed to
the planning owner and does not alter the observed T1-T5 command verdict.
`F-B051-EVIDENCE-EMPTY-OUTPUT-002` records the separate formatter defect; row
105 supplies the clean replacement diff-check receipt.

<!-- bubbles:certifying-window-begin -->

## Code Diff Evidence

The validator now resolves the framework bundle and consuming project as
separate roots. The selftest executes source and installed validators from an
unrelated working directory. It also proves that an invalid nested manifest
remains blocking.

## Validation Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run.

## Chaos Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.chaos
**Claim Source:** not-run

Chaos validation is not part of filing and has not run.
