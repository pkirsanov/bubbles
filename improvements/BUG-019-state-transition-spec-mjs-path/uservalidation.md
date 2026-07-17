# User Validation: BUG-019 State Transition Compound MJS Test Path

Evidence source: [report.md](report.md)

## Checklist

Checked entries describe the accepted validation contract, reproduced
discovery baseline, and current ownership routing. They do not claim scope
completion, release readiness, downstream propagation, or certification.

No checkbox in this file is delivery evidence. Delivery claims remain the
unchecked DoD items in [scopes.md](scopes.md) until their owning phases append
current-session raw output to [report.md](report.md).

### Discovery Baseline

- [x] **Baseline:** The exact production regex truncates the reporter
  `.spec.mjs` path to `.spec` and the `.test.mjs` twin to `.test`.
  - **Evidence:** [Production Regex Discriminator](report.md#production-regex-discriminator---before-fix)

- [x] **Baseline:** The installed Check 8 pipeline derives 21 nonexistent
  `.spec` paths from the reporter's real rows while the complete file exists.
  - **Evidence:** [Reporter Check 8 Reproduction](report.md#reporter-check-8-reproduction---before-fix)

- [x] **Baseline:** The adjacent traceability guard resolves the exact linked
  `.spec.mjs` file and exits `0`.
  - **Evidence:** [Traceability Discriminator](report.md#traceability-discriminator)

### Compound Path Preservation

- [x] **SCN-BUG-019-001 - Compound MJS paths:** Existing `.spec.mjs` and
  `.test.mjs` paths must remain complete through production Check 8.
  - **Steps:** Run `T-BUG-019-01` against isolated planning-maturity packets
    where the complete files exist and their marker prefixes do not.
  - **Expected:** Exact complete-path diagnostics appear; no `.spec` or `.test`
    prefix is checked; traceability retains the same complete token.
  - **Verify:** `T-BUG-019-01`.
  - **Evidence contract:** [GREEN Production-Path Regression](report.md#green-production-path-regression)

- [x] **SCN-BUG-019-002 - Ordinary controls:** Existing `.spec.ts`, `.test.js`,
  marker-only/simple suffixes, bare shell paths, and recognized command-wrapped
  shell paths must retain current behavior.
  - **Steps:** Run `T-BUG-019-02` and managed selftest `T-BUG-019-04` against
    bare paths, `bash`/`sh` wrappers, a shellcheck continuation, and a direct
    `./tests/example.sh check` command.
  - **Expected:** Every complete control path passes unchanged; first-candidate
    behavior remains stable; no whole command block becomes a path.
  - **Verify:** `T-BUG-019-02`, `T-BUG-019-04`.
  - **Evidence contract:** [Compatibility And Portability Evidence](report.md#compatibility-and-portability-evidence)

### Adversarial Rejection

- [x] **SCN-BUG-019-003 - Whole-token boundary:** An extension-prefix filename
  extension-shaped prose, and an unrecognized multiword command must not become
  test paths.
  - **Steps:** Run `T-BUG-019-03` with `.spec.mjs.backup`, prose, and
    `node --test tests/example.spec.mjs` adversaries.
  - **Expected:** No input or shorter prefix reaches direct or basename file
    checks; an all-invalid row set reaches the no-concrete-path branch.
  - **Verify:** `T-BUG-019-03`, `T-BUG-019-05`.
  - **Evidence contract:** [Adversarial Regression Evidence](report.md#adversarial-regression-evidence)

### Canonical Delivery Boundary

- [x] **Boundary:** Planning changes only planner-owned BUG-019 packet
  artifacts and execution routing; production, tests, docs, generated release
  bytes, certification, BUG-012/013/018, and Research Lab remain under their
  named owners.
  - **Basis:** [Planning Reconciliation Index](report.md#planning-reconciliation-index)

- [x] **Delivery contract:** Research Lab receives a repair only through
  supported canonical release/install/upgrade provenance.
  - **Expected:** No installed `.github/bubbles/**` or reporter workaround is
    part of the repair.
  - **Verify:** `T-BUG-019-09`, `T-BUG-019-10`, `T-BUG-019-11`, and downstream
    owner evidence.
  - **Evidence contract:** [Framework Release And Certification Evidence](report.md#framework-release-and-certification-evidence)

### Planning And Ownership Reconciliation

- [x] **Runnable system-Bash contract:** `T-BUG-019-08` keeps system paths
  first for the harness and nested guard while explicitly retaining the
  resolved `jq` and `yq` directories.
  - **Expected:** Missing parsers fail before execution; installed parsers are
    available without selecting Homebrew Bash on macOS.
  - **Evidence contract:** [Current Planner Finding Ledger](report.md#current-planner-finding-ledger)

- [x] **Foreign-finding closure contract:** BUG-020 owns the fun-mode collision,
  BUG-021 owns portable timeout, and the unpacketized empty-array nounset defect
  routes to `bubbles.bug` as BUG-022.
  - **Expected:** BUG-019 source and test bytes remain unchanged while every
    finding has exactly one named packet or intake owner.
  - **Evidence contract:** [Current Planner Finding Ledger](report.md#current-planner-finding-ledger)
