# Scopes: BUG-039 Unusable Interpreter Misreported As Classification Failures

## Scope 1: Interpreter Usability Probe, Named Skip, And Honest Cascade
**Status:** [x] Done

### Gherkin Scenarios (Regression)

```gherkin
Feature: A missing prerequisite is named, not misattributed

  Scenario: SCN-B039-001 - Unusable interpreter produces a named skip, not classification failures
    Given the active developer directory has an unaccepted Xcode licence
      And python3 resolves on PATH but exits 69 without running
    When the managed selftest runs under the sanitized system-only PATH
    Then it emits SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1
      And it emits a SKIP naming the interpreter, its exit status and the operator remediation
      And it emits zero FAIL lines
      And it exits 0

  Scenario: SCN-B039-002 - A usable interpreter under the same PATH runs everything
    Given DEVELOPER_DIR points at an accepted toolchain
    When the managed selftest runs under the sanitized system-only PATH
    Then no skip is emitted
      And every Scan 2B semantic and config-integrity assertion executes

  Scenario: SCN-B039-003 - The assertions still catch a real classifier regression
    Given a usable interpreter
      And the classifier's classification ladder is mutated
    When the managed selftest runs
    Then it exits 1 and reports the mismatched semantic tuples

  Scenario: SCN-B039-004 - A skipped coverage claim is never counted as a pass
    Given the managed selftest emitted the unavailable sentinel
    When test_24 evaluates the managed selftest run
    Then it records a SKIP rather than the coverage PASS label
      And the summary line reports the skip separately from passes and failures
```

### Implementation Plan

1. Add `sensitive_storage_classifier_usable()` to the selftest: probe execution
   and payload, not presence. Classify the reason and build a specific
   remediation for the Xcode-licence case.
2. Gate the Scan 2B semantic block and the four config-integrity scenarios behind
   the probe. On failure emit the sentinel, a named `SKIP`, the remediation, and
   the count of assertions not run.
3. Report skips in the selftest summary so a skipped run is never mistaken for a
   thorough one.
4. Give `test_24` a `skip()` recorder and `SKIP_COUNT`; branch on the sentinel so
   unmet coverage is a skip, never a pass; report skips in the summary line.

### Test Plan

| Test type | Scenario ID | Concrete test file | Mechanism |
| --- | --- | --- | --- |
| functional | SCN-B039-001 | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Run the managed harness with an unusable interpreter under the sanitized system-only PATH; assert the unavailable sentinel, named skip, zero classification `FAIL` lines, and exit 0. |
| functional | SCN-B039-002 | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Run the managed harness under the same sanitized PATH with a usable interpreter; assert no skip and execution of every Scan 2B semantic and config-integrity assertion. |
| adversarial / mutation | SCN-B039-003 | `bubbles/scripts/implementation-reality-scan-selftest.sh` | Apply the one-token classifier-ladder mutation, assert exit 1 and mismatched semantic tuples, then verify GREEN restoration and byte identity. |
| regression (cascade) | SCN-B039-004 | `tests/regression/test_24_g028_sensitive_client_storage.sh` | Run the production regression harness; assert the unavailable sentinel records a `SKIP`, withholds the coverage `PASS` label, and reports skips separately from passes and failures. |

### Definition of Done

- [x] Root cause confirmed and documented — presence (`command -v`) conflated with usability
  - Evidence: [report.md](report.md) §3, §4. A/B reproduced independently: A_EXIT=1 / 11 issues, B_EXIT=1→0 with only `DEVELOPER_DIR` differing; interpreter exit 69 under A, Python 3.9.6 under B.
- [x] Blast radius measured, not assumed
  - Evidence: [report.md](report.md) §4. `CONFIG_INVALID` occurrences A=6 vs B=5; the extra is the valid-config run, proving 8 config assertions are vacuous.
- [x] Packet route resolved mechanically
  - Evidence: [report.md](report.md) §5. `micro-fix-admission.sh` → full packet, escalated on `no-new-behavior` + `contract-preserving`, exit 0.
- [x] Fix implemented
  - Evidence: probe + gated block in `implementation-reality-scan-selftest.sh`; sentinel branch in `test_24_g028_sensitive_client_storage.sh`.
- [x] Pre-fix reproduction FAILS with the misnamed verdict
  - Evidence: [report.md](report.md) §3. `A_EXIT=1`, "failed with 11 issue(s)", all 11 in the Scan 2B block.
- [x] SCN-B039-002 — Post-fix behaviour correct in all three environments; under the same sanitized PATH, the usable-interpreter control emits no skip and executes every Scan 2B semantic and config-integrity assertion
  - Evidence: [report.md](report.md) §6. V1 exit 0/0 skips, V2 exit 0/1 skip, V3 exit 0/0 skips.
- [x] SCN-B039-003 — Adversarial mutation proves the assertions still bite with a usable interpreter and reports the mismatched semantic tuples
  - Evidence: [report.md](report.md) §7. Mutant exit 1 with 3 FAILs under BOTH normal PATH and sanitized PATH + `DEVELOPER_DIR`.
- [x] Mutation reverted and file byte-identical
  - Evidence: [report.md](report.md) §7. sha256 `77a02ff1…` matches pre-mutation; `git diff --quiet` exit 0; GREEN restored.
- [x] SCN-B039-001 — Skip path contains no silent-pass bailout — it withholds a verdict and says so; the unusable-interpreter run emits the sentinel, a named skip, zero classification `FAIL` lines, and exit 0
  - Evidence: [report.md](report.md) §6, §7 row 3. Skip is counted, sentinel-marked, and the limitation is stated explicitly rather than hidden.
- [x] SCN-B039-004 — Cascade resolved honestly — a skip is not a pass; `test_24` records the skip separately and withholds the coverage `PASS` label
  - Evidence: [report.md](report.md) §8. `57 passed, 0 failed, 1 skipped`; coverage PASS label withheld.
- [x] Static analysis clean; pre-existing findings attributed
  - Evidence: [report.md](report.md) §9. `shellcheck -x` exit 0 on both; `shfmt` diff 250/127 identical at HEAD and after, none of the new code in the diff.
- [x] No stdout coupling broken in consumers
  - Evidence: [report.md](report.md) §10. `framework-validate` uses `run_check … bash "$selftest_path"` (exit status).

### Not Claimed

- `framework-validate` and `release-check` were excluded by operator instruction
  and belong to the parent runner. No framework-wide certification is claimed.
- Human acceptance is not recorded.
