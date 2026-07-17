# User Validation: BUG-021 Framework Validate Raw Timeout

Evidence source: [report.md](report.md)

## Checklist

Checked entries define the accepted intake and future validation contract. They
do not claim a fix, GREEN execution, release, downstream upgrade, or
certification; delivery evidence remains unchecked in [scopes.md](scopes.md).

### Reproduced Baseline

- [x] **Baseline:** BUG-019's exact portability surface reports two raw
  `timeout` calls in `framework-validate.sh` and exits `1`.
  - **Evidence:** [Bug Reproduction - Before Fix](report.md#bug-reproduction---before-fix)

### Portable Deadline Contract

- [x] **T-BUG-021-00 gate:** The complete final
  `tests/regression/test_28_framework_validate_portable_timeout.sh` bytes must
  fail against unchanged production for the intended two raw timeout
  registrations under the sanitized no-`timeout` / no-`gtimeout` path.
  - **Expected:** The recorded test digest is reused unchanged for GREEN.
  - **Boundary:** No production, install-provenance, or release-identity edit is
    eligible before this RED is valid.

- [x] **SCN-BUG-021-001:** Both deadline-bearing selftests must execute through
  the portable helper when no `timeout` or `gtimeout` binary exists.
  - **Verify:** `T-BUG-021-01`, `T-BUG-021-03`, and `T-BUG-021-05` after repair.
  - **Expected:** Both labels execute without command-not-found or raw-timeout
    scanner findings; missing `guard-lib.sh` fails before checks.

- [x] **SCN-BUG-021-002:** Deadline expiration must remain exit `124`, ordinary
  child failure must remain distinct, and removing helper routing must fail the
  regression.
  - **Verify:** `T-BUG-021-02`, `T-BUG-021-03`, and `T-BUG-021-04` after repair.

### Failing-First Ownership

- [x] **RED ownership:** `bubbles.test` owns final
  `tests/regression/test_28_framework_validate_portable_timeout.sh` bytes,
  records their SHA-256, and captures RED against unchanged production bytes.
  - **Expected:** RED fails only on the two raw registrations; fixture and
    unrelated failures are repaired while production remains unchanged.

- [x] **Identical GREEN ownership:** `bubbles.implement` may not edit
  `tests/regression/test_28_framework_validate_portable_timeout.sh`;
  independent `bubbles.test` must compare the GREEN digest with RED before
  interpreting post-fix output.

### Provider And Reintroduction Matrix

- [x] **Provider order:** No timeout provider exercises the real watchdog,
  gtimeout-only exercises `gtimeout`, and timeout-present selects `timeout`.
  - **Verify:** `T-BUG-021-05` and independent helper canary `T-BUG-021-06`.

- [x] **Two call-site mutants:** Raw timeout restored at each registration is
  rejected as a separately named staged mutant.
  - **Verify:** `T-BUG-021-04`.

- [x] **No supervision bypass:** Direct-child invocation and helper-`124`
  suppression/remapping are independently rejected.
  - **Verify:** `T-BUG-021-04`.

### Ownership Boundary

- [x] **Boundary:** BUG-021 may touch only the two framework-validation calls,
  dedicated regression, direct provenance/registration, and generated-release
  ownership surfaces.
  - **Expected:** Scanner/helper semantics, BUG-012/013/018/019, IMP-020,
    downstream managed bytes, and certification remain unchanged by non-owners.

- [x] **Source-only and install provenance:** `framework-validate.sh` and
  `guard-lib.sh` remain managed;
  `tests/regression/test_28_framework_validate_portable_timeout.sh` is
  registered exactly once through `run_check_self_only`, excluded from
  downstream `.manifest` and `.checksums`, and release-recorded under
  `sourceOnlyFileChecksums`.
  - **Verify:** `T-BUG-021-12`.

- [x] **Release handoff:** Generated identity is written only by
  `bubbles.releases` after source, regression, and provenance bytes settle.
  - **Verify:** `T-BUG-021-13` then release-owned `T-BUG-021-14`.
