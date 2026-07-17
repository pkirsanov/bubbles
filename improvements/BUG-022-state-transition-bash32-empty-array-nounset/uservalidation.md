# User Validation: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

Evidence source: [report.md](report.md)

## Checklist

Checked entries record the accepted intake facts and behavioral contract. They
do not claim a source repair, GREEN regression, release, downstream propagation,
or certification. Delivery state remains unchecked in [scopes.md](scopes.md).

### Planning Baseline

- [x] **One executable scope:** The active plan contains one sequential
  runtime-behavior scope and exactly the three zero, one, and multiple element
  scenarios declared by [spec.md](spec.md).
  - **Plan:** [Scope 1](scopes.md#scope-1-bash-32-empty-array-result-integrity)

- [x] **Current test ownership:** The physical
  `tests/regression/test_29_state_transition_bash32_empty_array_nounset.sh`
  exists at SHA-256
  `4fba2c2f117f7a5c1cc514833af9960aa4ce190add4ba1da21b5b16549156c17`;
  planning treats that identity only as a collision detector, leaves its bytes
  test-owned, and assigns it no current RED claim.
  - **Plan:** [Current Invocation Change Boundary](scopes.md#current-invocation-change-boundary)

- [x] **Failing-first owner order:** `bubbles.test` must select final regression
  bytes and capture fresh causal RED against all 43 unchanged sites before
  `bubbles.implement` may atomically touch the three production files.
  - **Plan:** [Owner Route](scopes.md#owner-route)

- [x] **Atomic sourced-module boundary:** Planning authorizes exactly 40 main
  sites, `PLANNING-CHANGE-BOUNDARY-SCOPE`, `CONTROL-PLANE-TDD-SCOPES`, and
  `CONTROL-PLANE-TDD-REPORTS`; a main-only repair or partial rollback is not an
  accepted delivery state.
  - **Plan:** [Protected-Byte Inventory And Source Containment](scopes.md#protected-byte-inventory-and-source-containment)

- [x] **Terminal prerequisites:** Full framework validation and release-check
  remain required execution obligations and are not represented as planning
  pass claims.
  - **Plan:** [Execution Outline](scopes.md#execution-outline)

### Reproduced Baseline

- [x] **Interpreter and dependencies:** The current reproduction used stock
  `/bin/bash` `3.2.57(1)-release` with both `jq` and `yq` available.
  - **Evidence:** [Bug Reproduction Before Fix](report.md#bug-reproduction-before-fix)

- [x] **Parser discriminator:** The compound and adversarial BUG-019 matrices
  reach production Check 8 and pass their complete-path assertions before the
  nounset abort.
  - **Evidence:** [Reproduction Interpretation](report.md#reproduction-interpretation)

- [x] **Empty-array failure:** The current guard aborts at
  `passed_gate_ids[@]` line 72 and `failed_check_ids[@]` line 82, ends at
  `27/38`, and does not emit a complete structured result.
  - **Evidence:** [Bug Reproduction Before Fix](report.md#bug-reproduction-before-fix)

### Zero, One, And Multiple Contract

- [x] **SCN-BUG-022-001:** Every intentional zero-element state must run under
  nounset, serialize empty result collections as `[]`, and preserve the
  intended exit.
  - **Delivery evidence contract:** `T-BUG-022-02`.

- [x] **SCN-BUG-022-002:** The first element must cross an empty accumulator
  boundary exactly once with unchanged attribution and deduplication.
  - **Delivery evidence contract:** `T-BUG-022-03`.

- [x] **SCN-BUG-022-003:** Multiple values must preserve order and genuine
  failures must remain blocking.
  - **Delivery evidence contract:** `T-BUG-022-04` and `T-BUG-022-05`.

### Strictness And Adversarial Integrity

- [x] **Nounset remains active:** No accepted repair may remove or locally
  suppress `set -u`.
  - **Verify:** `T-BUG-022-06` plus source review.

- [x] **No sentinels or bailouts:** Empty state is represented by zero values,
  not dummy IDs, and regression assertions fail directly when the result is
  incomplete or a failure is suppressed.
  - **Verify:** `T-BUG-022-05` and `T-BUG-022-09`.

- [x] **Complete family coverage:** Direct result arrays, result formatting,
  scope/report discovery, first evidence comparison, and final failed-gate
  lookup each have an independent adversarial signal; the three sourced-module
  sites each have a one-site mutant tied to their zero-scope or zero-report
  rationale.
  - **Plan:** [Behavior-Family And Mutant Matrix](scopes.md#behavior-family-and-mutant-matrix)

### Ownership Boundary

- [x] **Concurrent source separation:** BUG-019/BUG-012 own current dirty
  `state-transition-guard.sh` bytes, BUG-020 owns dirty `fun-mode.sh`, and
  BUG-021 owns dirty `framework-validate.sh`; intake changes none of them.

- [x] **Shared registry separation:** `BUGS.md` is dirty and was not edited.
  Registration remains `REGISTRY-022-001` until shared ownership reconciles.

- [x] **Release and downstream separation:** Generated release metadata and
  Research Lab remain unchanged. Supported propagation must consume canonical
  release/install tooling after validation.

- [x] **Certification separation:** State and certification remain blocked;
  only `bubbles.validate` may certify completion.
