# User Validation: BUG-020 State Transition Bash 3.2 Startup

Evidence source: [report.md](report.md)

## Checklist

Checked entries define the accepted planning and validation contract. They do
not claim a source repair, RED or GREEN execution, release readiness,
downstream upgrade, or certification; delivery evidence remains unchecked in
[scopes.md](scopes.md).

### Reproduced Baseline

- [x] **Baseline:** Sanitized macOS `/bin/bash` aborts at
  `fun-mode.sh:23` with `gate_passed: unbound variable` before Check 8.
  - **Evidence:** [Bug Reproduction - Before Fix](report.md#bug-reproduction---before-fix)

### Portable Startup Contract

- [x] **SCN-BUG-020-001 - Parser-free Bash proves portable fun-mode
  startup.** Stock macOS Bash 3.2 with a strict system-only `PATH` sources the
  canonical module under nounset and exercises the complete public API without
  `jq`, `yq`, timeout, gtimeout, newer Bash, or a shim.
  - **Expected with disabled mode:** All seven public calls remain silent.
  - **Expected with enabled mode:** Named event text, unknown-event silence,
    all random pools, banner, prefix, and summary selection remain intact.
  - **Verify:** `T-BUG-020-01`, `T-BUG-020-02`, `T-BUG-020-12`, and
    `T-BUG-020-13`.

- [x] **SCN-BUG-020-002 - Missing parsers produce the normal resolver
  refusal.** Stock macOS Bash 3.2 with the strict system-only `PATH` invokes the
  real guard with fun mode disabled.
  - **Expected:** Fun-mode initialization succeeds, exact
    `E009-REGISTRY-MISSING` appears with a nonzero exit, and the lane is neither
    required nor credited as reaching Check 8.
  - **Ownership:** Complete BLOCKED-result and empty-array integrity remain
    BUG-022-owned and receive no BUG-020 completion credit.
  - **Verify:** `T-BUG-020-03`.

### Parser-Aware Guard Contract

- [x] **SCN-BUG-020-003 - Parser-aware Bash proves the complete guard
  path.** macOS system Bash keeps system directories first and appends only the
  fail-loud resolved real `jq` and `yq` directories; a separate newer-Bash lane
  supplies compatibility proof.
  - **Expected:** Disabled/enabled passing and genuine-finding fixtures each
    reach Check 8 once, emit one structured result, preserve fixture-controlled
    exits, and never let presentation output change governance truth.
  - **Verify:** `T-BUG-020-04` through `T-BUG-020-11` and `T-BUG-020-14`.

### Mandatory Test Order

- [x] **Prospective RED first:** `bubbles.test` revises and freezes the final
  `test_27` bytes, then runs those exact bytes in an isolated projection against
  the known pre-fix fun-mode blob and protected dependency snapshot before any
  candidate patch is applied in that lineage.
  - **Expected:** The parser-free API and parser-aware guard lanes fail at the
    historical fun-mode startup discriminator while fixture construction and
    real-parser controls pass. The earlier HEAD-restored diagnostic and the
    `RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED` current-source run receive no
    RED credit.
  - **Verify:** `T-BUG-020-00`.

- [x] **GREEN with identical bytes:** Only after valid prospective RED, the
  candidate patch is applied in the same isolated lineage and the identical
  test digest and commands execute the split matrix.
  - **Expected:** Parser-free API cases prove public behavior; the strict
    system-only guard proves `E009` without Check 8 credit; parser-aware Bash
    3.2 and newer-Bash cases alone prove Check 8 and structured outcomes.
  - **Verify:** `T-BUG-020-01` through `T-BUG-020-13`.

- [x] **Portability blind spot stays explicit:** The generic portability lint
  remains required but does not claim coverage of associative arrays or
  namerefs.
  - **Expected:** The dedicated regression rejects `declare -A`, `local -n`,
    and `declare -n` independently of the 13-class scan.
  - **Verify:** `T-BUG-020-13` and `T-BUG-020-17`.

### Ownership Boundary

- [x] **Boundary:** BUG-020 changes the shared implementation only in
  `fun-mode.sh`; the production guard, resolver, parser policy, and BUG-022
  empty-array sites are excluded from BUG-020 authorship.
  - **Expected:** BUG-012/013/018/019/021, IMP-020, BUG-019 `test_26`, Check 8,
    BUG-022 and its tests, existing local compatibility hooks, generic
    portability policy, downstream managed bytes, unrelated dirt, and
    certification remain unchanged by BUG-020 owners. Independently owned
    BUG-022 changes may settle and be consumed without BUG-020 credit.
  - **Verify:** `T-BUG-020-18`.

- [x] **Canonical delivery:** Managed source, managed selftest, source-only
  regression, generated manifest, framework validation, and release readiness
  must agree before downstream consumers receive the repair through supported
  install/upgrade provenance.
  - **Verify:** `T-BUG-020-23`, `T-BUG-020-24`, and `T-BUG-020-25` in that
    declared order.
