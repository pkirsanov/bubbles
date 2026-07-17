# Bug: BUG-022 State Transition Bash 3.2 Empty-Array Nounset

## Summary

`bubbles/scripts/state-transition-guard.sh` aborts under stock macOS Bash
3.2 with `set -u` when an initialized but empty indexed array is expanded as
`"${array[@]}"`. The abort prevents the guard from emitting its structured
result and can convert an intended blocking result into a misleading caller
status.

## Severity

- [ ] Critical - System unusable, data loss
- [x] High - A mandatory completion guard can abort before its result contract
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status

- [x] Reported
- [x] Confirmed on stock macOS `/bin/bash` 3.2
- [ ] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reporter And Dependency

- Routed finding: `TEST-019-005-BASH32-EMPTY-ARRAY`
- Upstream packet: `improvements/BUG-019-state-transition-spec-mjs-path`
- Upstream discriminator: the corrected parser-aware `T-BUG-019-08` command
  retains `jq` and `yq`, reaches Check 8, and then exits `1` at the nounset
  boundary with `27/38` assertions passing.
- BUG-019 remains blocked until BUG-022 can return executable evidence without
  changing BUG-019's repaired Check 8 parser or its regression bytes.

## Reproduction Steps

1. Resolve required `jq` and `yq` binaries fail-loud.
2. Put macOS system directories first in `PATH`, followed by the parser
   directories.
3. Run the unchanged BUG-019 production regression under `/bin/bash`.
4. Observe `BASH_VERSION=3.2.57(1)-release`, `JQ_AVAILABLE=yes`, and
   `YQ_AVAILABLE=yes`.
5. Observe the production guard reach `--- Check 8: Test File Existence ---`.
6. Observe the compound and adversarial parser assertions pass.
7. Observe the guard abort at line 72 on `passed_gate_ids[@]` in zero-finding
   paths and at line 82 on `failed_check_ids[@]` in the missing-file path.
8. Observe that `END TRANSITION_GUARD_RESULT_V1` and expected structured fields
   are absent, while the harness reports `PASSED=27`, `FAILED=11`, and exits
   `1`.

## Expected Behavior

- Stock macOS Bash 3.2 executes the production guard with `set -euo pipefail`
  still active.
- Empty result collections serialize as `[]` and empty loops perform zero
  iterations without an unbound-variable abort.
- The first element can be recorded in an initially empty gate/check array.
- One and multiple elements retain current order, deduplication, formatting,
  failure count, gate attribution, and exit behavior.
- A genuine Check 8 failure remains blocking and emits a complete structured
  failure result.
- BUG-019 Check 8 parser behavior remains unchanged.

## Actual Behavior

The first gate-tagged pass reaches:

```bash
list_contains "$gate_id" "${passed_gate_ids[@]}" || passed_gate_ids+=("$gate_id")
```

On Bash 3.2 with nounset enabled, expanding the initialized empty array aborts
before `list_contains` can return false and before the first element is added.
The equivalent first-failure paths affect `failed_gate_ids[@]` and
`failed_check_ids[@]`. Additional empty-array sites are masked by those early
aborts and are inventoried below.

## Environment

- Repository: `/Users/pkirsanov/Projects/bubbles`
- Platform: macOS
- Interpreter: `/bin/bash` `3.2.57(1)-release`
- Production component: `bubbles/scripts/state-transition-guard.sh`
- Reproduction component: `tests/regression/test_26_state_transition_spec_mjs_path.sh`
- Required parsers: `jq` and `yq`, both present during the current reproduction
- Observation timestamp: `2026-07-16T05:27:32Z`

## Error Output

```text
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 72: passed_gate_ids[@]: unbound variable
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
GUARD_RUNS=4
ASSERTIONS=38
PASSED=27
FAILED=11
BUG-019 state-transition Check 8 regression FAILED
BUG022_REPRODUCTION_EXIT=1
```

## Empty-Array Expansion Inventory

Line numbers refer to the current dirty working-tree bytes observed during
intake. Those bytes are owned concurrently by BUG-019 and BUG-012 and were not
modified, reverted, or attributed to BUG-022.

### Direct result-state arrays

| Lines | Array | Context | Zero-element reachability |
| --- | --- | --- | --- |
| 72 | `passed_gate_ids` | First call to `record_passed_gate` invokes `list_contains` | Directly reproduced after Check 18's first gate-tagged pass |
| 77 | `failed_gate_ids` | First call to `record_failed_gate` invokes `list_contains` | Reachable when the first gate-tagged failure occurs |
| 82 | `failed_check_ids` | First call to `record_failed_check` invokes `list_contains` | Directly reproduced in the Check 8 missing-file fixture |
| 124 | `transition_required_gate_ids` | PASS result records every required gate | Zero is schema-permitted; not the observed BUG-019 mode state |
| 128 | `passed_gate_ids` | Result construction filters passed gates | Reachable when no pass has recorded a gate ID |
| 129 | `failed_gate_ids` | Passed-gate filtering calls `list_contains` | Common zero state when passes exist and no gate-tagged failure exists |
| 142 | `transition_not_applicable_checks` | Structured result formatting | Deterministically zero for `delivery-completion-v1` |
| 143 | `effective_passed_gate_ids` | Structured result formatting | Reachable on blocked paths before an effective pass is accumulated |
| 144 | `failed_gate_ids` | Structured result formatting | Reachable on every successful guard and untagged failure path |
| 145 | `failed_check_ids` | Structured result formatting | Reachable on every successful guard |
| 3458 | `failed_gate_ids` | Planning failure selects `SOURCE_EDIT_LOCKOUT` via `list_contains` | Reachable when failures exist but none records a gate ID |

`transition_applicable_check_classes` at line 141 is populated for both valid
audit profiles and is not a valid-contract zero state. It is retained as a
control rather than classified as a defect.

### Per-scope discovery arrays

`scope_files` is nonempty in the single-file layout because the path is added
even when the file is missing. It is empty in the validly selected
`per-scope-directory` layout when no `scopes/*/scope.md` exists. The earliest
unguarded expansion is line 558; it masks later intended structure findings.

Every unguarded `scope_files[@]` site that can see that zero state is at lines
558, 563, 564, 594, 637, 1004, 1022, 1056, 1115, 1167, 1186, 1245, 1313,
1363, 2142, 2351, 2454, 2627, 2750, 2974, 3055, and 3079. Line 563 is an array
copy; the others are loops. Sites at lines 575, 630-631, and 647 are protected
by positive count checks or use count-only expansion and are controls.

### Per-scope report discovery arrays

`report_files` can be empty when per-scope `scope.md` files exist but no
per-scope `report.md` files exist. Unguarded loops at lines 2464, 2510, 2712,
3002, and 3041 can abort. The explicit zero-report diagnostic at line 2479
uses count-only expansion safely, but line 2464 dominates it in the current
ordering.

### Per-scope evidence comparison array

At line 2642, the first nonempty inline evidence block expands
`evidence_hashes[@]` while `evidence_hashes=()`. This zero state is expected on
the first block and can abort before the first hash is appended.

### Count-guarded controls

The following arrays use a nonempty invariant or a positive `${#array[@]}`
guard before element expansion and are not classified as defects:
`transition_resolver_args`, `scope_section_tmp_files`, `required_files`,
`required_specialists`, `planning_required_agents`, `timestamps`, `intervals`,
`block_words`, `test_files_in_plan`, `required_headers`, `impl_files`, and
`evidence_blocks`.

## Root Cause

Bash 3.2 treats a quoted `"${array[@]}"` expansion of an initialized empty
indexed array as an unset-variable error under `set -u`. The guard relies on
newer Bash behavior that expands the same state to zero arguments. Several
paths intentionally begin with empty accumulator arrays or intentionally
diagnose zero discovered artifacts, so the incompatibility is part of normal
control flow rather than malformed input. Disabling nounset would hide the
invariant instead of repairing Bash 3.2-compatible empty-list handling.

## Separation And Change Boundary

- `state-transition-guard.sh` is dirty under concurrent BUG-019 and BUG-012
  ownership. BUG-022 intake preserves all bytes.
- `fun-mode.sh` is dirty under BUG-020 ownership. BUG-022 does not touch it.
- `framework-validate.sh` is dirty under BUG-021 ownership. BUG-022 does not
  touch it.
- Existing regression tests, including `test_26` and planned BUG-020/021 test
  numbers, are unchanged.
- `BUGS.md` is dirty and lacks stable BUG-020/021 registration. BUG-022
  registration is routed as `REGISTRY-022-001`; this intake does not edit the
  shared file.
- Generated release metadata is owned by `bubbles.releases` after source and
  test bytes settle.
- Downstream Research Lab and every installed downstream framework copy are
  read-only for this intake. Propagation must use canonical release/install
  tooling after validation; no downstream hand-edit is permitted.

## Related

- Dependency: `improvements/BUG-019-state-transition-spec-mjs-path`
- Separate runtime bug: `improvements/BUG-020-state-transition-bash32-startup`
- Separate timeout bug: `improvements/BUG-021-framework-validate-raw-timeout`
- Canonical source: `bubbles/scripts/state-transition-guard.sh`
- Reproduction harness: `tests/regression/test_26_state_transition_spec_mjs_path.sh`

## Routing

This invocation owns BUG-022 intake, reproduction, static source inventory,
and packet creation only. `bubbles.design` is the immediate owner to reconcile
the Bash 3.2-compatible repair design and prove that every zero-state family
is covered without disabling nounset or changing guard semantics. After that,
`bubbles.plan` owns the executable scope, final test numbering, Test Plan, and
DoD reconciliation.
