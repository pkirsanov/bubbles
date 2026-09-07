# BUG-051 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Installed Validator Root Separation

**Status:** In Progress
**Implementation Phase:** Complete; routed to `bubbles.test` with T6 and validate-owned certification pending.
**Independent Test Phase:** Focused T1-T5 verification is complete on current bytes. T6 and validate-owned certification remain pending.
**Scenario Route:** Return upward to `complete-bubbles-bug052`; its recorded next owner is `bubbles.implement`.
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B051-001 Installed validator discovers a top-level manifest
  Given Bubbles is installed under .github/bubbles in a downstream fixture
  And a valid manifest exists under specs/001-feature
  When the installed YAML schema validator runs
  Then it includes that manifest in the validated count

Scenario: SCN-B051-002 Installed validator discovers a nested bug manifest
  Given the downstream fixture has a valid nested bug scenario manifest
  When the installed YAML schema validator runs
  Then it includes that nested manifest in the validated count

Scenario: SCN-B051-003 Invalid installed manifest remains blocking
  Given the downstream fixture has an invalid nested bug scenario manifest
  When the installed YAML schema validator runs
  Then it exits non-zero and names that manifest

Scenario: SCN-B051-004 Source and installed discovery stay equivalent
  Given source and installed fixtures contain equivalent manifest trees
  When both validator layouts run
  Then both report the same manifest count
```

### Implementation Plan

1. Add top-level and nested manifests to an installed provenance fixture.
2. Execute the installed validator before production changes and capture the RED miss.
3. Separate framework schema location from consuming repository root resolution.
4. Assert both installed manifest paths and their aggregate count.
5. Add a malformed nested manifest adversary and require a non-zero verdict.
6. Preserve source-layout and framework-registry validation behavior.
7. Run full canonical framework validation.
8. Regenerate the release manifest after validated source changes.

### Implementation Files

- `bubbles/scripts/yaml-schema-validate.sh`
- `bubbles/scripts/install-provenance-selftest.sh`

### Change Boundary

**Allowed paths:**

- `bubbles/scripts/yaml-schema-validate.sh`
- `bubbles/scripts/install-provenance-selftest.sh`
- `bubbles/release-manifest.json`
- this bug packet and `BUGS.md`

**Excluded paths:** scenario schemas, installer architecture, downstream product artifacts, unrelated validators, and other bug packets.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B051-001 | Regression E2E: installed top-level manifest discovery | functional | `bubbles/scripts/install-provenance-selftest.sh` | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| T2 | SCN-B051-002 | Installed nested bug manifest discovery | functional | `bubbles/scripts/install-provenance-selftest.sh` | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| T3 | SCN-B051-003 | Adversarial malformed installed manifest remains blocking | functional | `bubbles/scripts/install-provenance-selftest.sh` | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| T4 | SCN-B051-004 | Source and installed discovery count parity | functional | `bubbles/scripts/install-provenance-selftest.sh` | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| T5 | Aggregate | Existing installer provenance and schema regressions remain green | regression | `bubbles/scripts/install-provenance-selftest.sh` | `bash bubbles/scripts/install-provenance-selftest.sh` | No |
| T6 | Aggregate | Full source framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

**Current Test Evidence:** [Independent focused T1-T5 verification](report.md#independent-focused-t1-t5-verification)

### Definition of Done

- [x] Root cause is confirmed by the installed-layout RED result. → Evidence: [RED installed-root reproduction](report.md#red-installed-root-reproduction)
- [x] SCN-B051-001 the installed validator discovers the top-level manifest. → Evidence: [Persistent installed regression](report.md#persistent-installed-regression)
- [x] SCN-B051-002 the installed validator discovers the nested bug manifest. → Evidence: [Persistent installed regression](report.md#persistent-installed-regression)
- [x] SCN-B051-003 a malformed installed manifest produces a non-zero verdict. → Evidence: [Persistent installed regression](report.md#persistent-installed-regression)
- [x] SCN-B051-004 source and installed discovery counts agree. → Evidence: [Persistent installed regression](report.md#persistent-installed-regression)
- [x] Framework schemas still resolve from the active source or installed bundle. → Evidence: [Persistent installed regression](report.md#persistent-installed-regression)
- [x] The pre-fix regression test fails for the expected downstream-root reason. → Evidence: [RED installed-root reproduction](report.md#red-installed-root-reproduction)
- [x] The adversarial regression would fail if `.github` became the scan root again. → Evidence: [RED installed-root reproduction](report.md#red-installed-root-reproduction)
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior → Evidence: [Persistent installed regression](report.md#persistent-installed-regression)
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** The exact T1-T5 command, `bash bubbles/scripts/install-provenance-selftest.sh`, ran independently on current bytes and exited 0.
  > **What was observed:** All four scenario assertions and the aggregate installer regression passed. The scenario instruction reserved T6 for one combined validation after BUG-047 through BUG-052 implementation.
  > **Why this is uncertain:** `bash bubbles/scripts/cli.sh framework-validate` did not run in this invocation.
  > **What would resolve this:** Execute the combined T6 framework validation after BUG-052 implementation is complete.
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Change boundary](report.md#change-boundary)
- [x] Release manifest is regenerated from the validated source tree. → Evidence: [Managed release manifest](report.md#managed-release-manifest)
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No validate-owned certification command ran during independent focused test verification.
  > **What was observed:** Current evidence covers the implementation RED, independent T1-T5 GREEN, portability, and current release-manifest identity.
  > **Why this is uncertain:** Certification fields remain owned by `bubbles.validate`.
  > **What would resolve this:** Run validate-owned certification after the combined T6 scenario validation.
