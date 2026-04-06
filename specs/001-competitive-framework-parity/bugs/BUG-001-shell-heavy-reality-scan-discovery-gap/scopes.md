# Scopes: [BUG-001] Shell-Heavy Reality Scan Discovery Gap

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Execution Outline

### Phase Order
1. Scope 1 closes the upstream discovery gap by tracking the canonical `bubbles/scripts/implementation-reality-scan.sh` surface, the dedicated selftest coverage, the live post-fix feature scan, and the broader framework regression reruns.

### New Types & Signatures
- `bubbles/scripts/implementation-reality-scan.sh <feature-dir> [--verbose]`
- `bubbles/scripts/implementation-reality-scan-selftest.sh`
- `bubbles/scripts/generate-release-manifest.sh`
- `bubbles/scripts/release-manifest-selftest.sh`
- `bubbles/scripts/framework-validate.sh`

### Validation Checkpoints
- Historical pre-fix live scan failure remains recorded in [report.md](report.md).
- Dedicated selftest verifies both the shell-heavy success case and the adversarial missing-inventory failure case.
- Live post-fix scan against `specs/001-competitive-framework-parity` must resolve real implementation files and report zero violations.
- The manifest generation and framework validation chain must pass after the discovery fix.

## Scope 1: Upstream Discovery Support For Shell-Heavy Inventories

**Status:** Done

### Gherkin Scenarios (Regression Tests)

```gherkin
Feature: Reality-scan discovery for shell-heavy scopes

  Scenario: Real shell-heavy inventories are discovered honestly (SCN-BUG-001-01)
    Given a scope lists real on-disk implementation files that are primarily .sh, .yaml, .json, or documentation-backed framework surfaces
    When implementation-reality-scan runs against that scope
    Then the scanner resolves those files and scans them instead of raising ZERO_FILES_RESOLVED

  Scenario: Missing inventories still fail honestly (SCN-BUG-001-02)
    Given a scope does not list any real on-disk implementation files
    When implementation-reality-scan runs against that scope
    Then the scanner still blocks explicitly instead of passing on synthetic wrappers or fabricated coverage
```

### Implementation Plan
1. Update the upstream discovery contract so declared implementation inventories may include legitimate shell, registry, manifest, and docs-heavy files.
2. Add regression coverage for a shell-heavy fixture packet and an adversarial missing-inventory fixture.
3. Re-run the framework validation chain against `specs/001-competitive-framework-parity` after the upstream fix lands.

### Implementation Files
- `bubbles/scripts/implementation-reality-scan.sh` - shared framework discovery script where the shell-heavy inventory resolution fix lives.
- `bubbles/scripts/implementation-reality-scan-selftest.sh` - dedicated regression selftest that proves both the shell-heavy success path and the adversarial missing-inventory failure path.
- `specs/001-competitive-framework-parity/scopes.md` - live shell-heavy packet inventory used as the real supporting discovery target for the post-fix scan.

### Shared Infrastructure Impact Sweep
- Protected surface: `bubbles/scripts/implementation-reality-scan.sh` is a shared framework validation script consumed by bug packets, live feature scans, and broader framework guards.
- Downstream contract surfaces: `scopes.md`-declared inventories, live `specs/001-competitive-framework-parity` scans, the dedicated selftest fixtures, and the final `framework-validate.sh` chain.
- Canary coverage: `bubbles/scripts/implementation-reality-scan-selftest.sh` plus the live `implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose` rerun.
- Restore path: revert the upstream script change and re-run the dedicated selftest plus the live feature scan to confirm the discovery gap reappears before accepting any rollback.

### Change Boundary
- Allowed file families: `bubbles/scripts/implementation-reality-scan.sh` for the source fix and this bug packet's plan-owned artifacts.
- Excluded surfaces: `.github/bubbles/scripts/` install artifacts, foreign-owned `bug.md` and `design.md`, and `state.json` certification fields.
- Collateral cleanup is explicitly excluded unless the owning specialist expands scope first.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-BUG-001.1 | SCN-BUG-001-01 | Integration | integration | `bubbles/scripts/implementation-reality-scan.sh` | Historical pre-fix reproduction against the live feature packet confirms the `ZERO_FILES_RESOLVED` blocker before the upstream discovery fix. | `timeout 180 bash bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose` | Yes |
| TP-BUG-001.2 | SCN-BUG-001-01 | Regression E2E | e2e-api | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Regression: the dedicated selftest shell-heavy fixture resolves declared `.sh`, `.yaml`, `.json`, and docs-backed surfaces without artificial wrappers. | `timeout 180 bash bubbles/scripts/implementation-reality-scan-selftest.sh` | Yes |
| TP-BUG-001.3 | SCN-BUG-001-02 | Regression E2E | e2e-api | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Missing inventories still fail honestly: the dedicated selftest keeps `ZERO_FILES_RESOLVED` as a blocking outcome when the fixture omits real implementation inventory. | `timeout 180 bash bubbles/scripts/implementation-reality-scan-selftest.sh` | Yes |
| TP-BUG-001.4 | SCN-BUG-001-01 | Integration | integration | `bubbles/scripts/implementation-reality-scan.sh` | Live post-fix scan against the Scope 05 feature packet resolves the declared implementation inventory and reports zero violations. | `timeout 180 bash bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose` | Yes |
| TP-BUG-001.5 | SCN-BUG-001-01 | Integration | integration | `bubbles/scripts/generate-release-manifest.sh` | Regenerates the framework release manifest consumed by the broader regression chain after the discovery fix. | `timeout 180 bash bubbles/scripts/generate-release-manifest.sh` | Yes |
| TP-BUG-001.6 | SCN-BUG-001-01 | Integration | integration | `bubbles/scripts/release-manifest-selftest.sh` | Verifies the regenerated release manifest remains internally consistent after the discovery fix lands. | `timeout 180 bash bubbles/scripts/release-manifest-selftest.sh` | Yes |
| TP-BUG-001.7 | SCN-BUG-001-01 | Integration | integration | `bubbles/scripts/framework-validate.sh` | Confirms the broader framework validation suite passes with the shell-heavy discovery fix in place. | `timeout 900 bash bubbles/scripts/framework-validate.sh` | Yes |

### Definition of Done — 3-Part Validation

- [x] Root cause confirmed and documented
  Evidence: [design.md](design.md) records the extension-gated discovery root cause, and [report.md](report.md#bug-reproduction-before-fix) preserves the live `ZERO_FILES_RESOLVED` reproduction that exposed it.
- [x] Upstream discovery supports legitimate shell/yaml/json/docs-heavy implementation inventories without requiring shim files
  Evidence:
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/implementation-reality-scan-selftest.sh
  Shell-heavy fixture: PASSED with 5 implementation files resolved and 0 violations.
  ```
- [x] Pre-fix regression test FAILS with `ZERO_FILES_RESOLVED` on the live Scope 05 feature packet
  Evidence: [report.md](report.md#bug-reproduction-before-fix) preserves the historical installed-surface reproduction, including the inline command record below:
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash .github/bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose
  ℹ️  INFO: Scopes yielded 0 files — falling back to design.md for file discovery
  🔴 VIOLATION [ZERO_FILES_RESOLVED] No implementation file paths resolved from scope files
  Command exited with code 1
  ```
- [x] Adversarial regression case exists and proves genuinely missing inventories still block
  Evidence:
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/implementation-reality-scan-selftest.sh
  Missing-inventory fixture: FAILED honestly with ZERO_FILES_RESOLVED.
  Selftest marked the adversarial missing-inventory case as PASS.
  ```
- [x] Post-fix regression test PASSES for the live Scope 05 feature packet
  Evidence:
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose
  Result: Resolved 30 implementation file(s), 0 violations, PASSED.
  ```
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
  Evidence: Test rows `TP-BUG-001.2` and `TP-BUG-001.3` map directly to `SCN-BUG-001-01` and `SCN-BUG-001-02`, and both scenarios are recorded in [scenario-manifest.json](scenario-manifest.json).
- [x] Broader E2E regression suite passes
  Evidence:
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/generate-release-manifest.sh
  Result: passed.
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/release-manifest-selftest.sh
  Result: passed.
  $ cd /home/philipk/bubbles && timeout 900 bash bubbles/scripts/framework-validate.sh
  Result: passed.
  ```
- [x] Temporary shims or artificial supported-language wrappers are not used
  Evidence: The post-fix live scan passes against the real `specs/001-competitive-framework-parity` inventory, and the dedicated selftest uses declared shell, YAML, JSON, and docs-backed fixture files instead of wrapper code.
- [x] Change Boundary is respected and zero excluded file families were changed
  Evidence: The repair stayed inside `bubbles/scripts/implementation-reality-scan.sh` plus this bug packet's plan-owned artifacts; excluded install-artifact surfaces and `bug.md` remained untouched, while `state.json` received only the bounded bug-owned execution/provenance repair required for guard compatibility.
- [x] Red→green evidence is recorded for scenario-first TDD mode
  Evidence: [report.md](report.md#red-green-evidence) records the historical red `ZERO_FILES_RESOLVED` reproduction and the green post-repair selftest/live validation evidence without claiming certification-owned closure.
- [x] Plan-owned bug packet records the post-fix execution evidence without modifying certification-owned closure
  Evidence: [report.md](report.md) now contains the before-fix and after-fix execution record, and `state.json` now reflects only bug-owned execution/provenance updates while `certification.status` remains blocked.