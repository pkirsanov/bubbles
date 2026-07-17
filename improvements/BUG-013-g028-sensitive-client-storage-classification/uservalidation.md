# User Validation: BUG-013 G028 Sensitive Client Storage Classification

Evidence source: [report.md](report.md)

## Checklist

Checked items record the user-visible acceptance baseline included in the plan.
They do not claim implementation completion, current-session execution, or
validation certification; those claims remain gated by [scopes.md](scopes.md),
[report.md](report.md), and validate-owned state.

### Discovery Baseline

- [x] **Baseline:** The canonical scanner reproduces the indirect durable-write
  miss, provider non-differentiation, cache/comment false positive, and cleanup
  false positive in one hermetic fixture.
  - **Evidence:** [Hermetic Semantic Matrix](report.md#bug-reproduction---before-fix-hermetic-semantic-matrix)

- [x] **Baseline:** Direct managed selftest execution fails on macOS because it
  invokes raw `timeout` even though the shipped portable helper exists.
  - **Evidence:** [Managed Selftest Portability Reproduction](report.md#managed-selftest-portability-reproduction)

### Durable Storage Protection

- [x] **SCN-BUG-013-001 - Indirected durable credential storage is blocked.**
  Literal, constant, alias-chain, helper-indirected, and supported durable-handle
  credential writes receive the same fail-closed treatment.
  - **Steps:** Run the focused and persistent fixtures for each key form.
  - **Expected:** Exit `1` with `DURABLE_CREDENTIAL_STORAGE` at the operation;
    no credential value is printed.
  - **Verify:** `T-BUG-013-01`, `T-BUG-013-07`.
  - **Evidence:** [report.md](report.md)

### Exact Session Classification

- [x] **SCN-BUG-013-002 - One exact market provider is allowed only in
  configured session storage.** The approval is bound to one normalized
  path/key/provider tuple and the closed low-privilege same-tab classification.
  - **Steps:** Run the exact tuple, unknown provider, dynamic provider, and
    identical `localStorage` variants.
  - **Expected:** Only the exact session tuple is clear; every other variant is
    blocking with a distinct reason.
  - **Verify:** `T-BUG-013-02`, `T-BUG-013-07`.
  - **Evidence:** [report.md](report.md)

- [x] **SCN-BUG-013-003 - High-trust secrets cannot use the session
  exception.** Auth, login-session, bearer/refresh-token, and payment material
  remain blocking through an otherwise exact market-provider tuple.
  - **Steps:** Keep the tuple exact and vary only the secret class.
  - **Expected:** Every case exits `1` with `FORBIDDEN_SECRET_CLASS`.
  - **Verify:** `T-BUG-013-03`, `T-BUG-013-07`.
  - **Evidence:** [report.md](report.md)

### False-Positive Protection

- [x] **SCN-BUG-013-004 - Cache comments and cleanup do not masquerade as
  persistence.** Inline comments and noncredential market caches do not create
  findings, while the neighboring real credential operation remains blocking.
  - **Steps:** Put auth/payment vocabulary only in comments beside an untainted
    cache write and retain a neighboring real credential write.
  - **Expected:** Cache write is clear; real credential write is blocking.
  - **Verify:** `T-BUG-013-04`, `T-BUG-013-07`.
  - **Evidence:** [report.md](report.md)

  - **Steps:** Exercise comments, `removeItem`, complete and partial scrubbed
    rewrites, conditional deletes, separate cleanup helpers, and a before-scrub
    control.
  - **Expected:** Only proven complete cleanup is clear; every uncertain or
    credential-bearing write remains blocking.
  - **Verify:** `T-BUG-013-04`, `T-BUG-013-07`.
  - **Evidence:** [report.md](report.md)

### Fail-Closed Config And Portability

- [x] **SCN-BUG-013-005 - Classification uncertainty fails closed.** Unknown
  and dynamic providers plus invalid, ambiguous, absent, or unevaluable config
  never create an approval.
  - **Steps:** Run wildcard, duplicate, traversal, malformed, unknown-field,
    unknown-enum, and parser-unavailable fixtures.
  - **Expected:** Each exits nonzero with exact config/provider diagnostics.
  - **Verify:** `T-BUG-013-05`, `T-BUG-013-07`.
  - **Evidence:** [report.md](report.md)

- [x] **SCN-BUG-013-006 - The managed selftest runs on macOS without GNU
  timeout.** The focused validation uses the shipped portable helper rather
  than requiring a command named `timeout`.
  - **Steps:** Run with neither `timeout` nor `gtimeout` on `PATH`, then execute
    an intentional timeout control.
  - **Expected:** Fixture matrix executes; helper timeout returns `124`.
  - **Verify:** `T-BUG-013-06`, `T-BUG-013-07`, `T-BUG-013-09`.
  - **Evidence:** [report.md](report.md)

### Canonical Delivery Boundary

- [x] **Planning contract:** Stress coverage is not applicable because BUG-013
  introduces no latency, throughput, capacity, response-time, or service-level
  target; its behavioral risk is covered by production-scanner E2E and broad
  framework/release integration rows.
  - **Basis:** [Stress Coverage Classification](scopes.md#stress-coverage-classification)

- [x] **Planning contract:** Every changed behavior retains scenario-specific
  persistent E2E coverage, and independent test must also run the broader
  framework/release pair on one settled current-tree snapshot.
  - **Verify:** `T-BUG-013-01` through `T-BUG-013-06`, then
    `T-BUG-013-09` and `T-BUG-013-10`.
  - **Basis:** [Test Plan and independent-test handoff](scopes.md#test-plan)

- [x] **Boundary:** This packet changes no Research Lab file or downstream
  framework-managed copy.
  - **Basis:** Planning edits are confined to plan-owned BUG-013 artifacts;
    existing canonical production/test edits and unrelated dirty work are
    preserved, and no downstream managed copy is edited.

- [x] **Planning contract:** Independent test must verify that every
  BUG-013-attributed change stays inside the `bug.md` Change Boundary and that
  zero excluded file families changed before validation can assess completion.
  - **Verify:** Current-tree allowed/excluded-family audit by `bubbles.test`.
  - **Basis:** [Change Boundary](bug.md#change-boundary)

- [x] **What:** Consumers receive the validated repair only through canonical
  release/install/upgrade provenance.
  - **Steps:** Complete release validation, perform supported downstream
    upgrade, then run doctor and framework-write-guard before the installed
    scanner reproduction.
  - **Expected:** Installed bytes match the validated release and no manual
    managed-file drift exists.
  - **Verify:** Release and downstream owning phases.
  - **Evidence:** [report.md](report.md)
