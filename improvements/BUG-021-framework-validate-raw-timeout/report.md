# Report: BUG-021 Framework Validate Raw Timeout

Planning contract: [Scope 1](scopes.md#scope-1-portable-framework-validation-deadlines)
and [user validation](uservalidation.md).

## Planning Reconciliation

### Planning Summary

The active plan contains one plain-status `Not Started` scope, exactly two
scenario contracts, and one valid 15-row machine handoff. It requires
test-owned final
`tests/regression/test_28_framework_validate_portable_timeout.sh` bytes and
pre-edit RED, implementation-owned fail-loud sibling-helper loading plus
exactly two command-prefix replacements and one source-only registration,
identical-digest GREEN ownership, helper
`0`/ordinary-`3`/timeout-`124` behavior, no-timeout/gtimeout/timeout provider
coverage, two separately named call-site reintroduction mutants, install
provenance, broad canaries, and a release-owner metadata handoff.

### Planning Completion Statement

PLANNING RECONCILED; DELIVERY NOT EXECUTED. Scope 1 remains `Not Started`, the
packet remains `blocked`, and all delivery DoD items remain unchecked. No
production script, test, `spec.md`, `design.md`, certification field, generated
release file, sibling packet, commit, or remote was modified by this planning
invocation.

### Finding Accounting

| Finding | Planning disposition | Next owner |
| --- | --- | --- |
| `PLAN-021-001` | Addressed: scope inventory and header use canonical plain `Not Started`. | `bubbles.plan` |
| `PLAN-021-002` | Addressed: the concatenated stale machine handoff was removed; one JSON document with 15 unique rows remains. | `bubbles.plan` |
| `PLAN-021-003` | Addressed: every active artifact uses the exact `tests/regression/test_28_framework_validate_portable_timeout.sh` path and synchronized Test Plan titles. | `bubbles.plan` |
| `BUG021-F001` | Open: production still contains the two raw registrations until valid RED authorizes implementation. | `bubbles.test`, then `bubbles.implement` |
| `TRACE-021-001` | Open: `SCN-BUG-021-001` manifest link names the physically absent `tests/regression/test_28_framework_validate_portable_timeout.sh`. | `bubbles.test` |
| `TRACE-021-002` | Open: `SCN-BUG-021-002` manifest link names the physically absent `tests/regression/test_28_framework_validate_portable_timeout.sh`. | `bubbles.test` |
| `TRACE-021-003` | Open: `SCN-BUG-021-001` primary mapped row cannot resolve a concrete test file until `tests/regression/test_28_framework_validate_portable_timeout.sh` exists. | `bubbles.test` |
| `TRACE-021-004` | Open: `SCN-BUG-021-002` primary mapped row cannot resolve a concrete test file until `tests/regression/test_28_framework_validate_portable_timeout.sh` exists. | `bubbles.test` |
| `TEST-021-001` | Open: complete final `tests/regression/test_28_framework_validate_portable_timeout.sh` bytes and an intended pre-edit RED with recorded digest do not exist. | `bubbles.test` |
| `IMPLEMENT-021-001` | Queued: source sibling helper fail-loud, replace exactly two call prefixes, register `tests/regression/test_28_framework_validate_portable_timeout.sh` once. | `bubbles.implement` after RED |
| `TEST-021-002` | Queued: prove identical test digest for GREEN and run all focused and broad rows. | `bubbles.test` after implementation |
| `RELEASE-021-001` | Queued: regenerate canonical identity only after source/test/provenance bytes settle. | `bubbles.releases` |
| `VALIDATE-021-001` | Queued and unclaimed. | `bubbles.validate` |

### Execution Route

Route the complete open set to `bubbles.test`. It must author final
`tests/regression/test_28_framework_validate_portable_timeout.sh` bytes,
capture their SHA-256 and protected-byte baseline, and run the planned
system-Bash command against unchanged production. Fixture-construction or
unrelated failures are not valid RED and must be repaired before source work.

## Planned Delivery Evidence

### Final-Byte RED Regression

**Phase:** test
**Executed:** YES (current session)
**Command:** `for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** The execution is a valid causal RED for the two intended
raw production registrations: the direct scan found exactly those two raw
`timeout` calls, both target children were prevented from starting by the
owned no-provider PATH, all ten staged production-entrypoint cases and all five
adversarial mutants executed, and `HARNESS_FAILURES=0`. It is not accepted as
the immutable final-byte gate because the current untracked test file contains
two complete harness generations concatenated at physical line 793; the first
harness exits `1` before the appended harness executes. Test-byte ownership
must reconcile that conflict and rerun the exact command against still-unchanged
production before implementation is eligible.
**Byte Provenance:** test SHA-256
`b91a774ecaa02106c8b898a29b6f7cb8438bf1cee9670008bfd3983e8b54ebc9`;
production SHA-256
`189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d`;
helper SHA-256
`411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1`.
The test was untracked at execution, measured 1,521 lines / 62,338 bytes, and
contained the exact boundary
`793:printf '%s\n' 'BUG-021 portable framework timeout regression passed.'#!/usr/bin/env bash`.
Production contained one raw macOS registration, one raw planning registration,
zero helper registrations, and zero sibling-helper source lines.
**Output:** contiguous opening and terminal-summary windows from the preserved
18 KB unfiltered command capture:

```text
b91a774ecaa02106c8b898a29b6f7cb8438bf1cee9670008bfd3983e8b54ebc9  tests/regression/test_28_framework_validate_portable_timeout.sh
189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d  bubbles/scripts/framework-validate.sh
PASS: owned watchdog PATH resolves neither timeout nor gtimeout
=== BUG-021 immutable byte controls ===
SOURCE_VALIDATOR_SHA256_BEFORE=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
SOURCE_HELPER_SHA256_BEFORE=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
TEST_FILE_SHA256=b91a774ecaa02106c8b898a29b6f7cb8438bf1cee9670008bfd3983e8b54ebc9
GREEN_MUST_USE_TEST_SHA256=b91a774ecaa02106c8b898a29b6f7cb8438bf1cee9670008bfd3983e8b54ebc9
=== RED: unchanged production rejects both raw deadline registrations ===
== macOS portability guard -- scanning 1 file(s) ==
FAIL macOS-portability violation -- class-1 raw-timeout
  /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh:190:run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"
  /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh:292:run_check "Workflow planning provenance selftest" timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"
  remedy: route through bubbles_run_with_timeout (guard-lib.sh); preserve exit 124
```

```text
PASS: regression leaves canonical framework validator bytes unchanged
PASS: regression leaves canonical guard-lib bytes unchanged
PASS: regression test bytes stay stable during execution
PASS: all ten staged production-entrypoint cases executed
PASS: all five direct helper/provider controls executed
PASS: all five adversarial mutants executed without bailout
=== BUG-021 regression summary ===
TEST_FILE_SHA256_FINAL=b91a774ecaa02106c8b898a29b6f7cb8438bf1cee9670008bfd3983e8b54ebc9
GREEN_MUST_USE_TEST_SHA256_FINAL=b91a774ecaa02106c8b898a29b6f7cb8438bf1cee9670008bfd3983e8b54ebc9
SOURCE_VALIDATOR_SHA256_AFTER=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
SOURCE_HELPER_SHA256_AFTER=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PORTABILITY_SCAN_EXIT=1
VALIDATOR_RUNS=10
HELPER_RUNS=5
MUTANT_RUNS=5
PASSED_ASSERTIONS=44
CONTRACT_FAILURES=33
HARNESS_FAILURES=0
BUG-021 portable framework timeout regression FAILED.
BUG021_EXACT_COMMAND_EXIT=1
BUG021_EXACT_EXIT_ASSERTION=PASS
TEST28_IMMUTABLE_AFTER_RUN=PASS
PRODUCTION_IMMUTABLE_AFTER_RUN=PASS
```

**RED Disposition:** `VALID_INTENDED_RED__FINAL_BYTE_PROVENANCE_CONFLICT`.
The raw production defect is proven, but `T-BUG-021-00` remains unchecked and
production implementation remains locked until `bubbles.test` reconciles one
authoritative final harness and repeats this exact immutable-byte RED.

#### Authoritative Single-Harness RED

**Phase:** test
**Executed:** YES (current session)
**Command:** `for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Code:** 1 (intended pre-fix RED)
**Claim Source:** executed
**Result:** PASS for the mandatory failing-first gate. This is not a GREEN or
post-implementation claim. The harness itself emitted
`BUG021_RED_DISPOSITION=VALID_PRE_FIX_RED` with `HARNESS_FAILURES=0`, while the
unchanged production path failed the 16 repaired-contract assertions.
**Byte Provenance:** the adopted test-owned file is one 935-line / 39,369-byte
harness with SHA-256
`feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5`.
The test digest before, after, and required for GREEN is identical. Production
remained
`189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d`;
the helper, scanner, install-provenance, and release-manifest controls also
remained unchanged.
During post-edit invariant checking, concurrent test-owned refinements appeared
after the initial 932-line RED, including a ShellCheck source annotation and
normalized deadline/provider assertion wording. Those bytes were preserved,
not reverted. The exact planned command was rerun on the resulting 935-line
file, and the evidence below is from that later run. The earlier
`4203c9743e2958476e431371012e59e3931fc5b8bdf8963e23dba650443ed469`
digest is superseded and is not the digest authorized for GREEN.
**Output:** selected opening and terminal-summary windows from the preserved
18 KB raw command capture:

```text
feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5  tests/regression/test_28_framework_validate_portable_timeout.sh
189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d  bubbles/scripts/framework-validate.sh
PASS: owned watchdog PATH resolves neither timeout nor gtimeout
=== BUG-021 immutable pre-run byte controls ===
PRODUCTION_SHA256_BEFORE=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
HELPER_SHA256_BEFORE=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
SCANNER_SHA256_BEFORE=eff632de9192ddce2f0ea969c08bea2002a809649cc8b3fd31ee1edb4a625ca6
PROVENANCE_SHA256_BEFORE=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_BEFORE=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_BEFORE=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
GREEN_MUST_USE_TEST_SHA256=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
PASS: canonical source has exactly the two planned raw-timeout registrations
=== RED: unchanged production rejects both raw deadline registrations ===
== macOS portability guard -- scanning 1 file(s) ==
FAIL macOS-portability violation -- class-1 raw-timeout
  /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh:190:run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"
  /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh:292:run_check "Workflow planning provenance selftest" timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"
  remedy: route through bubbles_run_with_timeout (guard-lib.sh); preserve exit 124
RED_OBSERVED_PORTABILITY_EXIT=1
RED_OBSERVED_RAW_MAC_CALLS=1
RED_OBSERVED_RAW_PLAN_CALLS=1
```

```text
PASS: repaired-reference registration contract is exact
PASS: repaired-reference success preserves validator exit 0
PASS: regression leaves canonical framework validator bytes unchanged
PASS: regression leaves canonical guard-lib bytes unchanged
PASS: regression leaves portability scanner bytes unchanged
PASS: regression leaves install-provenance bytes unchanged
PASS: regression leaves release-manifest bytes unchanged
PASS: regression test bytes remain stable during execution
PASS: all eleven staged production-entrypoint cases execute
PASS: all five direct helper/provider controls execute
PASS: all five adversarial mutants execute without bailout
PASS: unique disposable regression workspace was removed
=== BUG-021 regression summary ===
PRODUCTION_SHA256_AFTER=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
HELPER_SHA256_AFTER=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256_AFTER=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_AFTER=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_AFTER=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
GREEN_MUST_USE_TEST_SHA256_FINAL=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
SOURCE_SHAPE=pre-fix
PORTABILITY_SCAN_EXIT=1
CANONICAL_EXIT=1
CANONICAL_MAC_STARTED=no
CANONICAL_PLAN_STARTED=no
CANONICAL_SENTINEL=yes
VALIDATOR_RUNS=11
HELPER_RUNS=5
MUTANT_RUNS=5
PASSED_ASSERTIONS=80
CONTRACT_FAILURES=16
HARNESS_FAILURES=0
BUG021_RED_DISPOSITION=VALID_PRE_FIX_RED
BUG-021 portable framework deadline regression FAILED.
```

**Finding Closure:** `TEST28_FINAL_BYTE_PROVENANCE_CONFLICT` and
`T-BUG-021-00` are closed by the single-harness shape, immutable digest, and
fresh exact-command RED above. `BUG021-F001` remains open because production is
still intentionally pre-fix; the next required owner is `bubbles.implement`.
Every GREEN, provenance, broad-framework, release, and certification claim
remains unmade.

#### Pre-Implementation Test-Owner Checks

**Phase:** test
**Executed:** YES (current session)
**Commands:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_28_framework_validate_portable_timeout.sh`; `/bin/bash -n bubbles/scripts/framework-validate.sh tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/install-provenance-selftest.sh`; `bash bubbles/scripts/macos-portability-guard-selftest.sh`; `bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Result:** PASS. Regression quality reports one adversarial signal with zero
violations or warnings; macOS system Bash parses the planned changed-shell
surface; and the canonical scanner selftest rejects raw timeout while accepting
portable helper usage. The final direct scan of `test_28` also passes all 13
classes: the two raw-call mutation literals carry narrow `portable-ok`
annotations and no executable raw timeout call is present.
**Output:**

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-17T00:25:02Z
  Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_28_framework_validate_portable_timeout.sh
✅ Adversarial signal detected in tests/regression/test_28_framework_validate_portable_timeout.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

```text
BUG021_FINAL_BASH32_SYNTAX_BEGIN
BUG021_FINAL_BASH32_SYNTAX_EXIT=0
  935   39369 tests/regression/test_28_framework_validate_portable_timeout.sh
feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5  tests/regression/test_28_framework_validate_portable_timeout.sh
189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d  bubbles/scripts/framework-validate.sh
BUG021_FINAL_BASH32_SYNTAX_END
```

```text
== macos-portability-guard selftest ==
  PASS: GREEN fixture (portable forms + pragmas + guarded mapfile) -> exit 0
  PASS: RED class1-raw-timeout -> exit 1 + names 'class-1 raw-timeout'
  PASS: RED class2-sed-i -> exit 1 + names 'class-2 in-place-sed'
  PASS: RED class3-date-d -> exit 1 + names 'class-3 date-d-parse'
  PASS: RED class4-stat-c -> exit 1 + names 'class-4 stat-c-mtime'
  PASS: RED class5-readlink-f -> exit 1 + names 'class-5 readlink-f-absolutize'
  PASS: RED class6-grep-P -> exit 1 + names 'class-6 grep-pcre'
  PASS: RED class7-isset -> exit 1 + names 'class-7 bracket-v-isset'
  PASS: RED class8-mapfile -> exit 1 + names 'class-8 mapfile-readarray'
  PASS: RED class9-mktemp-suffix -> exit 1 + names 'class-9 mktemp-suffix'
  PASS: RED class10-df-output -> exit 1 + names 'class-10 df-output'
  PASS: RED class11-bin-true -> exit 1 + names 'class-11 bin-true-false'
  PASS: RED class12-paste -> exit 1 + names 'class-12 paste-no-stdin-operand'
  PASS: RED class13-date-ns -> exit 1 + names 'class-13 date-nanoseconds'
  PASS: directory surface recurses into *.sh (nested dirty file caught)
  PASS: PORTABILITY_SCAN_PATHS env surface is honored
  PASS: no-surface invocation exits 2 (usage)
  PASS: missing-path invocation exits 2 (usage)
  PASS: guard parses (bash -n)
  PASS: guard is self-portable (guard scans its own source -> exit 0)
  PASS: guard source (comments stripped) has no literal GNU-only form

[selftest macos-portability-guard] OK — all assertions passed.
```

```text
== macOS portability guard -- scanning 1 file(s) ==
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
PASS: the scanned surface is WSL+macOS portable.
```

#### Invocation Routing And Non-Planned Scan Note

The operator rejected a prior parallel invocation because it returned the
wrong BUG-020 packet. That invocation is not represented as a BUG-021
specialist run, and this test invocation neither inspected nor modified
BUG-020 or BUG-022. The operator also reported an orchestrator-owned broad scan
of `test_28` that matched intentional raw-timeout fixture strings and assertion
language. That observation is not a Test Plan row, was not used as runtime
portability evidence, and creates no BUG-021 product finding. The planned
scanner-selftest canary above is the applicable pre-implementation check.

### Portable Timeout Production Regression

#### Implementation-Owned Repair And Immutable GREEN Attempt

**Phase:** implement
**Executed:** YES (current session)
**Command:** `for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** The production path is repaired and every runtime-specific
GREEN signal passed: the immutable test digest stayed
`feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5`,
`SOURCE_SHAPE=repaired`, both target children and the later sentinel ran, the
provider order and helper `0`/`3`/`124` outcomes passed, missing
`guard-lib.sh` failed before target execution, all 11 validator cases, 5
helper cases, and 5 mutants ran, and `HARNESS_FAILURES=0`. The command is not a
valid overall GREEN because the immutable harness produced one contract
failure: it forbids the literal `class-1 raw-timeout`, while the canonical
scanner prints `ok   class-1 raw-timeout: none` on every clean scan. Therefore
`T-BUG-021-01` through `T-BUG-021-05` remain unchecked and independent
`bubbles.test` ownership must reconcile the immutable assertion before this
implementation can continue to source-only registration or provenance wiring.
**Output:** opening and terminal-summary windows from the preserved 16 KB
unfiltered command capture:

```text
feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5  tests/regression/test_28_framework_validate_portable_timeout.sh
55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20  bubbles/scripts/framework-validate.sh
PASS: owned watchdog PATH resolves neither timeout nor gtimeout
=== BUG-021 immutable pre-run byte controls ===
PRODUCTION_SHA256_BEFORE=55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20
HELPER_SHA256_BEFORE=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256_BEFORE=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_BEFORE=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_BEFORE=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
GREEN_MUST_USE_TEST_SHA256=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
PASS: canonical source has exactly the repaired helper registration shape
== macOS portability guard -- scanning 1 file(s) ==
ok   class-1 raw-timeout: none
PASS: the scanned surface is WSL+macOS portable.
RED_OBSERVED_PORTABILITY_EXIT=0
PASS: canonical framework validator passes direct portability scan
FAIL-CONTRACT: direct portability scan reports no raw-timeout class (unexpected: class-1 raw-timeout)
PASS: canonical validator sources the managed sibling helper exactly once
PASS: canonical mac registration invokes the portable helper exactly once
PASS: canonical planning registration invokes the portable helper exactly once
```

```text
PASS: regression leaves canonical framework validator bytes unchanged
PASS: regression leaves canonical guard-lib bytes unchanged
PASS: regression leaves portability scanner bytes unchanged
PASS: regression leaves install-provenance bytes unchanged
PASS: regression leaves release-manifest bytes unchanged
PASS: regression test bytes remain stable during execution
PASS: all eleven staged production-entrypoint cases execute
PASS: all five direct helper/provider controls execute
PASS: all five adversarial mutants execute without bailout
PASS: unique disposable regression workspace was removed
=== BUG-021 regression summary ===
PRODUCTION_SHA256_AFTER=55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20
HELPER_SHA256_AFTER=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256_AFTER=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_AFTER=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_AFTER=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
GREEN_MUST_USE_TEST_SHA256_FINAL=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
SOURCE_SHAPE=repaired
PORTABILITY_SCAN_EXIT=0
CANONICAL_EXIT=0
CANONICAL_MAC_STARTED=yes
CANONICAL_PLAN_STARTED=yes
CANONICAL_SENTINEL=yes
VALIDATOR_RUNS=11
HELPER_RUNS=5
MUTANT_RUNS=5
PASSED_ASSERTIONS=95
CONTRACT_FAILURES=1
HARNESS_FAILURES=0
BUG021_RED_DISPOSITION=RED_INVALID_MIXED_OR_UNRELATED_FAILURE
BUG-021 portable framework deadline regression FAILED.
```

> **Uncertainty Declaration**
> **What was attempted:** The exact immutable RED command was run after the
> production-only repair, with the same test bytes and sanitized PATH.
> **What was observed:** All production runtime, helper, provider, fail-loud,
> mutation, cleanup, and protected-byte assertions passed; one scanner-output
> string assertion failed.
> **Why this is uncertain:** The immutable test rejects a class label that the
> canonical scanner emits in both clean and failing reports, so its exit `1`
> cannot certify the otherwise-green production behavior.
> **What would resolve this:** The test owner must make the assertion distinguish
> a failing class diagnostic from the canonical clean `ok ...: none` line,
> establish a fresh valid RED for those final bytes as required by TDD, and
> route the resulting immutable digest back for implementation GREEN.

#### Test-Owned Clean-Label Reconciliation And Fresh Final-Byte Lineage

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed
**Result:** PASS for the narrowly owned test correction and its mandatory fresh
lineage. At test-phase intake, the concurrent current test-owned bytes already
contained the intended two-sided assertion: require the canonical clean scanner
line `ok   class-1 raw-timeout: none`, and reject only the actual violation
diagnostic `FAIL macOS-portability violation -- class-1 raw-timeout`. Those
bytes were preserved rather than overwritten.

The final regression is 936 lines / 39,571 bytes at SHA-256
`62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78`.
Because that digest differs from the prior `feed758...` GREEN attempt, test
lineage was restarted. The exact final bytes were copied into an isolated
six-input fixture; only the three BUG-021 production edits were reversed in
that fixture. The reconstructed production SHA-256 was
`189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d`,
exactly matching the packet's preserved pre-fix blob. The first RED attempt was
externally interrupted before its terminal summary and is invalid. The complete
rerun below is the only accepted RED.

The complete RED produced `PASSED_ASSERTIONS=80`,
`CONTRACT_FAILURES=17`, `HARNESS_FAILURES=0`, and
`BUG021_RED_DISPOSITION=VALID_PRE_FIX_RED`. The previous 16 repaired-contract
failures remain, and the seventeenth is the newly explicit absence of the clean
scanner line on genuinely dirty pre-fix source. The exact same test digest then
ran against current production SHA-256
`55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20`
and produced `PASSED_ASSERTIONS=97`, `CONTRACT_FAILURES=0`,
`HARNESS_FAILURES=0`, and `BUG021_RED_DISPOSITION=CURRENT_SOURCE_GREEN`.
Both runs executed all 11 staged validator cases, all 5 helper/provider cases,
and all 5 adversarial mutants. `guard-lib.sh`, install provenance, and release
manifest remained at their prior protected hashes.

##### Full Raw Final-Byte RED Evidence

**Command:** `cd /tmp/bubbles-bug021-lineage-62f724f && for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Code:** 1 (intended pre-fix RED)
**Claim Source:** interpreted
**Interpretation:** The output directly shows the two raw production calls,
missing clean class result, actual class-1 failure diagnostic, no target starts,
continued sentinel execution, 17 repaired-contract failures, zero harness
failures, stable final test and protected source hashes, and a valid pre-fix RED
disposition. The nonzero exit is expected and is not a current-source failure.
**Raw Output:** complete command-output content from the preserved 356-line /
18,775-byte terminal capture follows. Terminal-width wraps are normalized; a
token-for-token comparison after removing whitespace passed, so no command
output was omitted or summarized.

```text
62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78  tests/regression/test_28_framework_validate_portable_timeout.sh
189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d  bubbles/scripts/framework-validate.sh
PASS: owned watchdog PATH resolves neither timeout nor gtimeout
=== BUG-021 immutable pre-run byte controls ===
PRODUCTION_SHA256_BEFORE=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
HELPER_SHA256_BEFORE=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
SCANNER_SHA256_BEFORE=eff632de9192ddce2f0ea969c08bea2002a809649cc8b3fd31ee1edb4a625ca6
PROVENANCE_SHA256_BEFORE=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_BEFORE=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_BEFORE=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
GREEN_MUST_USE_TEST_SHA256=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
PASS: canonical source has exactly the two planned raw-timeout registrations
=== RED: unchanged production rejects both raw deadline registrations ===
== macOS portability guard -- scanning 1 file(s) ==
FAIL macOS-portability violation -- class-1 raw-timeout
  /private/tmp/bubbles-bug021-lineage-62f724f/bubbles/scripts/framework-validate.sh:190:run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"
  /private/tmp/bubbles-bug021-lineage-62f724f/bubbles/scripts/framework-validate.sh:292:run_check "Workflow planning provenance selftest" timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"
  remedy: route through bubbles_run_with_timeout (guard-lib.sh); preserve exit 124
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

FAIL: 1 macOS-portability construct class(es) found in the scanned surface.
See instructions/wsl-macos-compatibility.instructions.md (and skill bubbles-cross-platform-shell).
RED_OBSERVED_PORTABILITY_EXIT=1
RED_OBSERVED_RAW_MAC_CALLS=1
RED_OBSERVED_RAW_PLAN_CALLS=1
FAIL-CONTRACT: canonical framework validator passes direct portability scan (expected=0 actual=1)
FAIL-CONTRACT: direct portability scan reports the clean raw-timeout class result (missing: ok   class-1 raw-timeout: none)
FAIL-CONTRACT: direct portability scan reports no class-1 raw-timeout violation (unexpected: FAIL macOS-portability violation -- class-1 raw-timeout)
FAIL-CONTRACT: canonical validator sources the managed sibling helper exactly once (expected=1 actual=0)
FAIL-CONTRACT: canonical mac registration invokes the portable helper exactly once (expected=1 actual=0)
FAIL-CONTRACT: canonical planning registration invokes the portable helper exactly once (expected=1 actual=0)
FAIL-CONTRACT: canonical mac registration has no raw deadline call (expected=0 actual=1)
FAIL-CONTRACT: canonical planning registration has no raw deadline call (expected=0 actual=1)
PASS: mac deadline retains its environment key and 120-second default
PASS: planning deadline retains its environment key and 120-second default
VALIDATOR_CASE name=canonical-success exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  /tmp/bubbles-bug021-SL0v7Ds5/stage-canonical-success/bubbles/scripts/framework-validate.sh: line 125: timeout: command not found
  FAIL: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  /tmp/bubbles-bug021-SL0v7Ds5/stage-canonical-success/bubbles/scripts/framework-validate.sh: line 125: timeout: command not found
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 2 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - macOS portability guard selftest (bubbles-cross-platform-shell)
    - Workflow planning provenance selftest
FAIL-CONTRACT: canonical success case preserves validator exit 0 (expected=0 actual=1)
FAIL-CONTRACT: canonical success case executes mac target (missing file: /tmp/bubbles-bug021-SL0v7Ds5/markers-1-canonical-success/mac.started)
FAIL-CONTRACT: canonical success case completes mac target (missing file: /tmp/bubbles-bug021-SL0v7Ds5/markers-1-canonical-success/mac.finished)
FAIL-CONTRACT: canonical success case executes planning target (missing file: /tmp/bubbles-bug021-SL0v7Ds5/markers-1-canonical-success/plan.started)
FAIL-CONTRACT: canonical success case completes planning target (missing file: /tmp/bubbles-bug021-SL0v7Ds5/markers-1-canonical-success/plan.finished)
PASS: canonical success case reaches later sentinel
FAIL-CONTRACT: canonical success case reports mac PASS (missing: PASS: macOS portability guard selftest (bubbles-cross-platform-shell))
FAIL-CONTRACT: canonical success case reports planning PASS (missing: PASS: Workflow planning provenance selftest)
FAIL-CONTRACT: canonical success case needs no optional deadline provider (unexpected: command not found)
FAIL-CONTRACT: canonical success case preserves aggregate PASS (missing: Framework validation passed.)
=== BUG-021 repaired-reference non-vacuity controls ===
PASS: repaired-reference registration contract is exact
VALIDATOR_CASE name=candidate-success exit=0 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: repaired-reference success preserves validator exit 0
PASS: repaired-reference success executes mac target
PASS: repaired-reference success completes mac target
PASS: repaired-reference success executes planning target
PASS: repaired-reference success completes planning target
PASS: repaired-reference success reaches later sentinel
PASS: repaired-reference success reports mac PASS
PASS: repaired-reference success reports planning PASS
PASS: repaired-reference success needs no optional deadline provider
PASS: repaired-reference success preserves aggregate PASS
=== SCN-BUG-021-001: system-only PATH runs both deadline-bearing checks via watchdog ===
=== SCN-BUG-021-002: helper outcomes remain distinct through run_check aggregation ===
VALIDATOR_CASE name=candidate-mac-timeout exit=1 macDeadline=1 planDeadline=4
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=2 exit=0
  FAIL: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - macOS portability guard selftest (bubbles-cross-platform-shell)
PASS: mac deadline preserves aggregate validator exit 1
PASS: mac deadline executes bounded target
PASS: mac deadline stops overdue target
PASS: mac deadline executes other target
PASS: mac deadline completes other target
PASS: mac deadline reaches later sentinel
PASS: mac deadline records one failed check result
PASS: mac deadline records one failed-label entry
PASS: mac deadline preserves other target PASS
PASS: mac deadline contributes one aggregate failure
PASS: mac deadline selects the real watchdog path
VALIDATOR_CASE name=candidate-plan-timeout exit=1 macDeadline=4 planDeadline=1
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=2 exit=0
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - Workflow planning provenance selftest
PASS: plan deadline preserves aggregate validator exit 1
PASS: plan deadline executes bounded target
PASS: plan deadline stops overdue target
PASS: plan deadline executes other target
PASS: plan deadline completes other target
PASS: plan deadline reaches later sentinel
PASS: plan deadline records one failed check result
PASS: plan deadline records one failed-label entry
PASS: plan deadline preserves other target PASS
PASS: plan deadline contributes one aggregate failure
PASS: plan deadline selects the real watchdog path
VALIDATOR_CASE name=candidate-plan-exit3 exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=3
  BUG021_TARGET plan finished exit=3
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - Workflow planning provenance selftest
PASS: ordinary child exit 3 preserves aggregate validator exit 1
PASS: ordinary failure leaves mac target complete
PASS: ordinary failure completes planning child before exit 3
PASS: ordinary failure reaches later sentinel
PASS: ordinary failure preserves mac PASS
PASS: ordinary failure records one planning FAIL
PASS: ordinary failure records one planning failed-label entry
PASS: ordinary failure contributes one aggregate failure
PASS: ordinary failure needs no optional deadline provider
=== Contract: helper load fails loud and both deadline overrides remain independent ===
VALIDATOR_CASE name=candidate-missing-helper exit=1 macDeadline=4 planDeadline=5
PASS: missing managed helper fails validator startup nonzero
PASS: missing-helper diagnostic identifies the managed sibling helper
PASS: missing helper fails before mac target execution
PASS: missing helper fails before planning target execution
PASS: missing helper fails before later sentinel execution
=== Compatibility: timeout then gtimeout then watchdog provider order is unchanged ===
HELPER_CASE name=helper-success exit=0 seconds=4
PASS: canonical watchdog helper preserves child success 0
HELPER_CASE name=helper-exit3 exit=3 seconds=4
PASS: canonical watchdog helper preserves ordinary child exit 3
HELPER_CASE name=helper-watchdog-124 exit=124 seconds=1
PASS: canonical watchdog helper normalizes expiration to 124
HELPER_CASE name=helper-timeout-provider exit=0 seconds=7
PASS: GNU provider preserves child success
PASS: GNU provider receives seconds suffix and child argv
PASS: GNU timeout binary wins when both providers are available
HELPER_CASE name=helper-gtimeout-provider exit=3 seconds=8
PASS: gtimeout provider preserves ordinary child exit 3
PASS: gtimeout provider receives seconds suffix and child argv when timeout is absent
=== Adversarial: each raw call, direct child, and 124 remap is rejected independently ===
VALIDATOR_CASE name=mutant-raw-mac exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  /tmp/bubbles-bug021-SL0v7Ds5/stage-mutant-raw-mac/bubbles/scripts/framework-validate.sh: line 126: timeout: command not found
  FAIL: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - macOS portability guard selftest (bubbles-cross-platform-shell)
PASS: raw mac registration mutant is rejected by the exact registration contract
PASS: raw mac registration mutant is rejected by the staged production success contract
VALIDATOR_CASE name=mutant-raw-plan exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  /tmp/bubbles-bug021-SL0v7Ds5/stage-mutant-raw-plan/bubbles/scripts/framework-validate.sh: line 126: timeout: command not found
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - Workflow planning provenance selftest
PASS: raw planning registration mutant is rejected by the exact registration contract
PASS: raw planning registration mutant is rejected by the staged production success contract
VALIDATOR_CASE name=mutant-direct-mac exit=0 macDeadline=1 planDeadline=4
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=2 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: direct mac child mutant is rejected by the exact registration contract
PASS: direct mac child mutant is rejected by the staged mac-timeout contract
VALIDATOR_CASE name=mutant-direct-plan exit=0 macDeadline=4 planDeadline=1
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=2 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: direct planning child mutant is rejected by the exact registration contract
PASS: direct planning child mutant is rejected by the staged planning-timeout contract
VALIDATOR_CASE name=mutant-remap-124 exit=0 macDeadline=1 planDeadline=4
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=2 exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: helper 124 remap mutant is rejected by the exact registration contract
PASS: helper 124 remap mutant is rejected by the staged mac-timeout contract
PASS: regression leaves canonical framework validator bytes unchanged
PASS: regression leaves canonical guard-lib bytes unchanged
PASS: regression leaves portability scanner bytes unchanged
PASS: regression leaves install-provenance bytes unchanged
PASS: regression leaves release-manifest bytes unchanged
PASS: regression test bytes remain stable during execution
PASS: all eleven staged production-entrypoint cases execute
PASS: all five direct helper/provider controls execute
PASS: all five adversarial mutants execute without bailout
PASS: unique disposable regression workspace was removed
=== BUG-021 regression summary ===
PRODUCTION_SHA256_AFTER=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
HELPER_SHA256_AFTER=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256_AFTER=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_AFTER=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_AFTER=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
GREEN_MUST_USE_TEST_SHA256_FINAL=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
SOURCE_SHAPE=pre-fix
PORTABILITY_SCAN_EXIT=1
CANONICAL_EXIT=1
CANONICAL_MAC_STARTED=no
CANONICAL_PLAN_STARTED=no
CANONICAL_SENTINEL=yes
VALIDATOR_RUNS=11
HELPER_RUNS=5
MUTANT_RUNS=5
PASSED_ASSERTIONS=80
CONTRACT_FAILURES=17
HARNESS_FAILURES=0
BUG021_RED_DISPOSITION=VALID_PRE_FIX_RED
BUG-021 portable framework deadline regression FAILED.
```

##### Full Raw Exact-Current-Production GREEN Evidence

**Command:** `cd /Users/pkirsanov/Projects/bubbles && for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Code:** 0
**Claim Source:** executed
**Raw Output:** complete command-output content from the preserved 318-line /
16,276-byte terminal capture follows. Terminal-width wraps are normalized; a
token-for-token comparison after removing whitespace passed, so no command
output was omitted or summarized.

```text
62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78  tests/regression/test_28_framework_validate_portable_timeout.sh
55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20  bubbles/scripts/framework-validate.sh
PASS: owned watchdog PATH resolves neither timeout nor gtimeout
=== BUG-021 immutable pre-run byte controls ===
PRODUCTION_SHA256_BEFORE=55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20
HELPER_SHA256_BEFORE=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
SCANNER_SHA256_BEFORE=eff632de9192ddce2f0ea969c08bea2002a809649cc8b3fd31ee1edb4a625ca6
PROVENANCE_SHA256_BEFORE=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_BEFORE=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_BEFORE=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
GREEN_MUST_USE_TEST_SHA256=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
PASS: canonical source has exactly the repaired helper registration shape
=== RED: unchanged production rejects both raw deadline registrations ===
== macOS portability guard -- scanning 1 file(s) ==
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

PASS: the scanned surface is WSL+macOS portable.
RED_OBSERVED_PORTABILITY_EXIT=0
RED_OBSERVED_RAW_MAC_CALLS=0
RED_OBSERVED_RAW_PLAN_CALLS=0
PASS: canonical framework validator passes direct portability scan
PASS: direct portability scan reports the clean raw-timeout class result
PASS: direct portability scan reports no class-1 raw-timeout violation
PASS: canonical validator sources the managed sibling helper exactly once
PASS: canonical mac registration invokes the portable helper exactly once
PASS: canonical planning registration invokes the portable helper exactly once
PASS: canonical mac registration has no raw deadline call
PASS: canonical planning registration has no raw deadline call
PASS: mac deadline retains its environment key and 120-second default
PASS: planning deadline retains its environment key and 120-second default
VALIDATOR_CASE name=canonical-success exit=0 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: canonical success case preserves validator exit 0
PASS: canonical success case executes mac target
PASS: canonical success case completes mac target
PASS: canonical success case executes planning target
PASS: canonical success case completes planning target
PASS: canonical success case reaches later sentinel
PASS: canonical success case reports mac PASS
PASS: canonical success case reports planning PASS
PASS: canonical success case needs no optional deadline provider
PASS: canonical success case preserves aggregate PASS
=== BUG-021 repaired-reference non-vacuity controls ===
PASS: repaired-reference registration contract is exact
VALIDATOR_CASE name=candidate-success exit=0 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: repaired-reference success preserves validator exit 0
PASS: repaired-reference success executes mac target
PASS: repaired-reference success completes mac target
PASS: repaired-reference success executes planning target
PASS: repaired-reference success completes planning target
PASS: repaired-reference success reaches later sentinel
PASS: repaired-reference success reports mac PASS
PASS: repaired-reference success reports planning PASS
PASS: repaired-reference success needs no optional deadline provider
PASS: repaired-reference success preserves aggregate PASS
=== SCN-BUG-021-001: system-only PATH runs both deadline-bearing checks via watchdog ===
=== SCN-BUG-021-002: helper outcomes remain distinct through run_check aggregation ===
VALIDATOR_CASE name=candidate-mac-timeout exit=1 macDeadline=1 planDeadline=4
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=2 exit=0
  FAIL: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - macOS portability guard selftest (bubbles-cross-platform-shell)
PASS: mac deadline preserves aggregate validator exit 1
PASS: mac deadline executes bounded target
PASS: mac deadline stops overdue target
PASS: mac deadline executes other target
PASS: mac deadline completes other target
PASS: mac deadline reaches later sentinel
PASS: mac deadline records one failed check result
PASS: mac deadline records one failed-label entry
PASS: mac deadline preserves other target PASS
PASS: mac deadline contributes one aggregate failure
PASS: mac deadline selects the real watchdog path
VALIDATOR_CASE name=candidate-plan-timeout exit=1 macDeadline=4 planDeadline=1
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=2 exit=0
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - Workflow planning provenance selftest
PASS: plan deadline preserves aggregate validator exit 1
PASS: plan deadline executes bounded target
PASS: plan deadline stops overdue target
PASS: plan deadline executes other target
PASS: plan deadline completes other target
PASS: plan deadline reaches later sentinel
PASS: plan deadline records one failed check result
PASS: plan deadline records one failed-label entry
PASS: plan deadline preserves other target PASS
PASS: plan deadline contributes one aggregate failure
PASS: plan deadline selects the real watchdog path
VALIDATOR_CASE name=candidate-plan-exit3 exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=3
  BUG021_TARGET plan finished exit=3
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - Workflow planning provenance selftest
PASS: ordinary child exit 3 preserves aggregate validator exit 1
PASS: ordinary failure leaves mac target complete
PASS: ordinary failure completes planning child before exit 3
PASS: ordinary failure reaches later sentinel
PASS: ordinary failure preserves mac PASS
PASS: ordinary failure records one planning FAIL
PASS: ordinary failure records one planning failed-label entry
PASS: ordinary failure contributes one aggregate failure
PASS: ordinary failure needs no optional deadline provider
=== Contract: helper load fails loud and both deadline overrides remain independent ===
VALIDATOR_CASE name=candidate-missing-helper exit=1 macDeadline=4 planDeadline=5
PASS: missing managed helper fails validator startup nonzero
PASS: missing-helper diagnostic identifies the managed sibling helper
PASS: missing helper fails before mac target execution
PASS: missing helper fails before planning target execution
PASS: missing helper fails before later sentinel execution
=== Compatibility: timeout then gtimeout then watchdog provider order is unchanged ===
HELPER_CASE name=helper-success exit=0 seconds=4
PASS: canonical watchdog helper preserves child success 0
HELPER_CASE name=helper-exit3 exit=3 seconds=4
PASS: canonical watchdog helper preserves ordinary child exit 3
HELPER_CASE name=helper-watchdog-124 exit=124 seconds=1
PASS: canonical watchdog helper normalizes expiration to 124
HELPER_CASE name=helper-timeout-provider exit=0 seconds=7
PASS: GNU provider preserves child success
PASS: GNU provider receives seconds suffix and child argv
PASS: GNU timeout binary wins when both providers are available
HELPER_CASE name=helper-gtimeout-provider exit=3 seconds=8
PASS: gtimeout provider preserves ordinary child exit 3
PASS: gtimeout provider receives seconds suffix and child argv when timeout is absent
=== Adversarial: each raw call, direct child, and 124 remap is rejected independently ===
VALIDATOR_CASE name=mutant-raw-mac exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  /tmp/bubbles-bug021-LVZK6FhB/stage-mutant-raw-mac/bubbles/scripts/framework-validate.sh: line 126: timeout: command not found
  FAIL: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - macOS portability guard selftest (bubbles-cross-platform-shell)
PASS: raw mac registration mutant is rejected by the exact registration contract
PASS: raw mac registration mutant is rejected by the staged production success contract
VALIDATOR_CASE name=mutant-raw-plan exit=1 macDeadline=4 planDeadline=5
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  /tmp/bubbles-bug021-LVZK6FhB/stage-mutant-raw-plan/bubbles/scripts/framework-validate.sh: line 126: timeout: command not found
  FAIL: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation failed with 1 failing check(s) (39 self-only check(s) skipped under install-mode=downstream).
  Failed checks:
    - Workflow planning provenance selftest
PASS: raw planning registration mutant is rejected by the exact registration contract
PASS: raw planning registration mutant is rejected by the staged production success contract
VALIDATOR_CASE name=mutant-direct-mac exit=0 macDeadline=1 planDeadline=4
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=2 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: direct mac child mutant is rejected by the exact registration contract
PASS: direct mac child mutant is rejected by the staged mac-timeout contract
VALIDATOR_CASE name=mutant-direct-plan exit=0 macDeadline=4 planDeadline=1
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=0 exit=0
  BUG021_TARGET mac finished exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=2 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: direct planning child mutant is rejected by the exact registration contract
PASS: direct planning child mutant is rejected by the staged planning-timeout contract
VALIDATOR_CASE name=mutant-remap-124 exit=0 macDeadline=1 planDeadline=4
  ==> macOS portability guard selftest (bubbles-cross-platform-shell)
  BUG021_TARGET mac started sleep=2 exit=0
  PASS: macOS portability guard selftest (bubbles-cross-platform-shell)
  ==> Workflow planning provenance selftest
  BUG021_TARGET plan started sleep=0 exit=0
  BUG021_TARGET plan finished exit=0
  PASS: Workflow planning provenance selftest
  BUG021_SENTINEL reached after both deadline registrations
  Framework validation passed (39 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
  Framework validation passed.
PASS: helper 124 remap mutant is rejected by the exact registration contract
PASS: helper 124 remap mutant is rejected by the staged mac-timeout contract
PASS: regression leaves canonical framework validator bytes unchanged
PASS: regression leaves canonical guard-lib bytes unchanged
PASS: regression leaves portability scanner bytes unchanged
PASS: regression leaves install-provenance bytes unchanged
PASS: regression leaves release-manifest bytes unchanged
PASS: regression test bytes remain stable during execution
PASS: all eleven staged production-entrypoint cases execute
PASS: all five direct helper/provider controls execute
PASS: all five adversarial mutants execute without bailout
PASS: unique disposable regression workspace was removed
=== BUG-021 regression summary ===
PRODUCTION_SHA256_AFTER=55a48d4149527af474a9713389f997e72fc0f35c8e71e954fe4035147cec6e20
HELPER_SHA256_AFTER=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256_AFTER=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_AFTER=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
TEST_SHA256_AFTER=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
GREEN_MUST_USE_TEST_SHA256_FINAL=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
SOURCE_SHAPE=repaired
PORTABILITY_SCAN_EXIT=0
CANONICAL_EXIT=0
CANONICAL_MAC_STARTED=yes
CANONICAL_PLAN_STARTED=yes
CANONICAL_SENTINEL=yes
VALIDATOR_RUNS=11
HELPER_RUNS=5
MUTANT_RUNS=5
PASSED_ASSERTIONS=97
CONTRACT_FAILURES=0
HARNESS_FAILURES=0
BUG021_RED_DISPOSITION=CURRENT_SOURCE_GREEN
BUG-021 portable framework deadline regression passed.
```

##### Focused Final-Test Integrity Evidence

**Command:** regression-quality guard, `/bin/bash -n`, direct macOS portability
scan of `test_28`, and a complete skip/only/todo/pending marker scan
**Exit Code:** 0
**Claim Source:** executed
**Raw Output:**

```text
BUG021_TEST_INTEGRITY_BEGIN
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-17T02:25:35Z
  Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_28_framework_validate_portable_timeout.sh
✅ Adversarial signal detected in tests/regression/test_28_framework_validate_portable_timeout.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
BUG021_REGRESSION_QUALITY_EXIT=0
BUG021_BASH32_SYNTAX_EXIT=0
== macOS portability guard -- scanning 1 file(s) ==
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

PASS: the scanned surface is WSL+macOS portable.
BUG021_TEST_PORTABILITY_EXIT=0
BUG021_FORBIDDEN_TEST_MARKER_HITS=0
BUG021_TEST_INTEGRITY_EXIT=0
BUG021_TEST_INTEGRITY_END
```

**Finding Closure:** `IMMUTABLE_TEST28_CLEAN_LABEL_ASSERTION_CONFLICT` and
`TEST28_CLEAN_SCANNER_LABEL_CONTRADICTION` are closed by the two-sided scanner
assertion and fresh `62f724...` RED/GREEN lineage. No DoD checkbox, scope
status, completion claim, certification field, production registration,
install-provenance assertion, generated release identity, or broad framework
validation claim changed. `IMPLEMENT-021-001` remains open because the
source-only `test_28` registration is still absent; the packet routes next to
`bubbles.implement`, after which `bubbles.test` still owns the remaining
focused canaries and broad selected suite.

### Helper Load And Deadline Configuration

Reserved for `T-BUG-021-03`. No execution claim exists.

### Adversarial Reintroduction

Reserved for `T-BUG-021-04`. No execution claim exists.

### Provider And Canary Controls

Reserved for `T-BUG-021-05` through `T-BUG-021-07`. No execution claim exists.

### Portability And Change Boundary

#### Direct Repaired Production Scan

**Phase:** implement
**Executed:** YES (current session)
**Command:** `printf '%s\n' 'BUG021_DIRECT_REPAIRED_SCAN_BEGIN' && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/framework-validate.sh; scan_exit=$?; printf 'BUG021_DIRECT_REPAIRED_SCAN_EXIT=%s\n' "$scan_exit"; printf '%s\n' 'BUG021_DIRECT_REPAIRED_SCAN_END'; exit "$scan_exit"`
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS for the direct repaired production scan. This independently
confirms the scanner's clean-output vocabulary and does not close the failed
immutable GREEN or any test-owned DoD row.
**Output:**

```text
BUG021_DIRECT_REPAIRED_SCAN_BEGIN
== macOS portability guard -- scanning 1 file(s) ==
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

PASS: the scanned surface is WSL+macOS portable.
BUG021_DIRECT_REPAIRED_SCAN_EXIT=0
BUG021_DIRECT_REPAIRED_SCAN_END
```

#### Implementation Boundary Snapshot

**Phase:** implement
**Executed:** YES (current session)
**Command:** exact post-edit SHA-256, source-shape count, `git diff --check`,
and timestamp capture over the BUG-021 protected surfaces
**Exit Code:** 0
**Claim Source:** executed
**Result:** PASS. The immutable test and every protected foreign shared file
retain their preflight hashes. Production contains exactly one fail-loud helper
source, one helper-mediated macOS registration, one helper-mediated planning
registration, and zero raw target registrations. The source-only test
registration remains absent because the mandatory first GREEN failed before
adjacent integration work was permitted.
**Output:**

```text
BUG021_IMPLEMENT_BOUNDARY_BEGIN
TEST28_SHA256=feed758f9d4a73184f8ecbfbac7e9792d2390a8b3050849322d20da2e41f53a5
HELPER_SHA256=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
HELPER_SOURCE_COUNT=1
HELPER_MAC_COUNT=1
HELPER_PLAN_COUNT=1
RAW_TARGET_COUNT=0
TEST28_REGISTRATION_COUNT=0
FRAMEWORK_DIFF_CHECK=PASS
SOURCE_EDITED_AT=2026-07-17T00:35:13Z
BOUNDARY_CAPTURED_AT=2026-07-17T00:38:04Z
BUG021_IMPLEMENT_BOUNDARY_END
```

### Install And Source-Only Provenance

Reserved for `T-BUG-021-12`. No execution claim exists.

### Framework Validation

Reserved for `T-BUG-021-13`. No execution claim exists.

### Release Validation

Reserved for `T-BUG-021-14`. No execution claim exists.

## Planning Validation Evidence

### Artifact Structure And Freshness

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Commands:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-021-framework-validate-raw-timeout`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-021-framework-validate-raw-timeout`
**Exit Codes:** 0, 0
**Claim Source:** executed
**Output:**

```text
Required artifact exists: spec.md
Required artifact exists: design.md
Required artifact exists: uservalidation.md
Required artifact exists: state.json
Required artifact exists: scopes.md
Required artifact exists: report.md
No forbidden sidecar artifacts present
Found DoD section in scopes.md
scopes.md DoD contains checkbox items
All DoD bullet items use checkbox syntax in scopes.md
Found Checklist section in uservalidation.md
uservalidation checklist contains checkbox entries
Top-level status matches certification.status
Artifact lint PASSED.
spec.md has no superseded/suppressed sections
design.md has no superseded/suppressed sections
No spec/design freshness boundaries detected
scopes.md has no superseded scope section
No superseded scope sections detected
RESULT: PASS (0 failures, 0 warnings)
```

**Result:** PASS. The packet has the required artifact shape, one active
single-file scope, canonical nonterminal state, checked-by-default acceptance
baseline, no active superseded scope, and no freshness warning. Artifact lint
retains its nonblocking notice for validate-owned deprecated
`certification.scopeProgress`; planning did not modify that object.

### Capability Proportionality

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Command:** `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-021-framework-validate-raw-timeout`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
capability-foundation-guard: Gate G094 applies: triggerHits=22 concreteImplementationEntries=0
capability-foundation-guard: spec.md contains non-empty Single-Capability Justification
capability-foundation-guard: design.md contains non-empty Single-Implementation Justification
capability-foundation-guard: UX primitive check not applicable: screenCount=0 uiReuseHits=0
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
SPEC_CAPABILITY_AUTHORITY=Single-Capability Justification
DESIGN_CAPABILITY_AUTHORITY=Single-Implementation Justification
EXISTING_FOUNDATION=bubbles/scripts/guard-lib.sh
AFFECTED_CONSUMERS=2
NEW_CAPABILITY_FOUNDATION=none
G094_EXIT=0
```

**Result:** PASS. The analyst-owned Single-Capability Justification and
design-owned Single-Implementation Justification both bind the repair to the
existing `guard-lib.sh` timeout authority rather than a new abstraction.

### Traceability Handoff

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Command:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-021-framework-validate-raw-timeout`
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
scenario-manifest.json covers 2 scenario contract(s)
scenario-manifest.json references missing linked test file: tests/regression/test_28_framework_validate_portable_timeout.sh
scenario-manifest.json references missing linked test file: tests/regression/test_28_framework_validate_portable_timeout.sh
Scope 1: Portable Framework Validation Deadlines scenario mapped to Test Plan row: Framework validation runs both deadline-bearing checks without GNU timeout
Scope 1: Portable Framework Validation Deadlines mapped row references no existing concrete test file: Framework validation runs both deadline-bearing checks without GNU timeout
Scope 1: Portable Framework Validation Deadlines scenario mapped to Test Plan row: Portable timeout outcomes remain observable and exact
Scope 1: Portable Framework Validation Deadlines mapped row references no existing concrete test file: Portable timeout outcomes remain observable and exact
Scenarios checked: 2
Test rows checked: 15
Scenario-to-row mappings: 2
Concrete test file references: 0
DoD fidelity scenarios: 2 (mapped: 2, unmapped: 0)
RESULT: FAILED (4 failures, 0 warnings)
```

**Result:** EXPECTED ROUTE. Scenario, Test Plan, and DoD semantics are mapped;
the only four failures are the two manifest links and two primary mapped rows
for the deliberately absent, test-owned
`tests/regression/test_28_framework_validate_portable_timeout.sh`. Planning
must not create or pretend that physical regression exists. Those exact
findings route to `bubbles.test` as `TEST-021-001`.

### Strict Planning Parity

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Commands:** three sanitized `node -e` assertions over
`spec.md`, `scopes.md`, `scenario-manifest.json`, `test-plan.json`, and
`report.md`: row/DoD parity; scenario/manifest/report-anchor parity; structural
delivery-contract coverage
**Exit Codes:** 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG021_ROW_PARITY_BEGIN
oneMachineScope=PASS
markdownRows=PASS
jsonRows=PASS
fieldParity=PASS
orderedUniqueIds=PASS
markdownIdParity=PASS
oneDodPerRow=PASS
rowDrift=none
BUG021_ROW_PARITY_END
BUG021_SCENARIO_PARITY_BEGIN
exactTwoScenarios=PASS
specScopeGherkinParity=PASS
manifestCount=PASS
manifestPrimaryLinks=PASS
manifestEvidenceRefs=PASS
reportAnchors=PASS
test28Absent=PASS
scenarioCount=2
reportAnchorCount=9
BUG021_SCENARIO_PARITY_END
BUG021_STRUCTURAL_CONTRACT_BEGIN
oneVerticalRuntimeScope=PASS
scopeNotStarted=PASS
testFirstOwnerOrder=PASS
finalByteRedLock=PASS
helperResultMatrix=PASS
fiveAdversarialCases=PASS
sharedConsumerSweeps=PASS
exactChangeBoundary=PASS
rollbackInstallRelease=PASS
bash32Mac=PASS
onlyApplicableCategories=PASS
BUG021_STRUCTURAL_CONTRACT_END
```

**Result:** PASS. The packet has exactly two spec-equal Gherkin scenarios, one
vertical runtime scope, 15 byte-synchronized Markdown/JSON rows, 15 ordered
row-specific DoD items, exact manifest test titles/files, nine resolved report
anchors, and all required RED, helper, adversarial, sweep, boundary, rollback,
provenance, Bash 3.2/macOS, and category-exclusion contracts.

### Active Prose, State, And Scoped Boundary

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Commands:** active-prose placeholder scan over six planning/state artifacts;
state invariant assertion; `git diff --check --
improvements/BUG-021-framework-validate-raw-timeout`; physical
`tests/regression/test_28_framework_validate_portable_timeout.sh` absence
check; path-scoped `git status --short --untracked-files=all`
**Exit Codes:** 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG021_ACTIVE_PROSE_SCAN_BEGIN
files=6
hits=0
BUG021_ACTIVE_PROSE_SCAN_END
BUG021_STATE_INVARIANTS_BEGIN
statusBlocked=PASS
certificationBlocked=PASS
scopeNotStarted=PASS
noCompletedClaims=PASS
nextOwnerTest=PASS
onePlanningRoute=PASS
activeAgent=bubbles.plan
currentPhase=planning
BUG021_STATE_INVARIANTS_END
BUG021_SCOPED_BOUNDARY_BEGIN
packetDiffCheck=PASS
test28Absent=PASS
M bubbles/release-manifest.json
M bubbles/scripts/framework-validate.sh
M bubbles/scripts/install-provenance-selftest.sh
?? improvements/BUG-021-framework-validate-raw-timeout/
BUG021_SCOPED_BOUNDARY_END
```

**Result:** PASS for the planning-owned state and active prose. Active prose has
zero placeholder hits; status and certification remain `blocked`; Scope 1
remains `not_started`; completion arrays remain empty; and exactly one planning
history route targets `bubbles.test`. Because the packet is untracked,
`git diff --check` does not prove its internal whitespace; the explicit
nine-file content scan below is the authoritative packet-content check. The
three listed shared delivery files were already dirty at planning entry and
were not edited, normalized, reset, staged, committed, or attributed to
BUG-021 planning.

### Untracked Packet Content Scan

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Command:** Node scan of every regular file in
`improvements/BUG-021-framework-validate-raw-timeout` for trailing whitespace,
conflict markers, final newlines, and JSON parseability
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG021_UNTRACKED_PACKET_SCAN_BEGIN
files=9
issues=0
BUG021_UNTRACKED_PACKET_SCAN_END
```

**Result:** PASS. All nine packet files have final newlines, no trailing
whitespace or conflict markers, and every JSON artifact parses successfully.

### Final Packet Gates And Pre-Fix Source Lock

**Phase:** planning
**Executed:** YES (prior planning invocation)
**Commands:** final BUG-021 artifact lint, artifact freshness, G094 capability
guard, and a read-only source-lock assertion over
`bubbles/scripts/framework-validate.sh` plus physical
`tests/regression/test_28_framework_validate_portable_timeout.sh` existence
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG021_FINAL_ARTIFACT_LINT_BEGIN
Artifact lint PASSED.
BUG021_FINAL_ARTIFACT_LINT_EXIT=0
BUG021_FINAL_ARTIFACT_LINT_END
BUG021_FINAL_FRESHNESS_BEGIN
RESULT: PASS (0 failures, 0 warnings)
BUG021_FINAL_FRESHNESS_EXIT=0
BUG021_FINAL_FRESHNESS_END
BUG021_FINAL_G094_BEGIN
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
BUG021_FINAL_G094_EXIT=0
BUG021_FINAL_G094_END
BUG021_SOURCE_LOCK_BEGIN
RAW_TARGET_REGISTRATIONS=2
HELPER_TARGET_REGISTRATIONS=0
GUARD_LIB_SOURCE_LINES=0
TEST28_STATE=absent
BUG021_SOURCE_LOCK_EXIT=0
BUG021_SOURCE_LOCK_END
```

**Result:** PASS for planning and lockout. The final packet remains structurally
valid and fresh, the existing single implementation is justified, and no
production repair has begun. `bubbles.test` still owns the complete final-byte
regression and intended RED that must precede helper wiring.

## Intake Record

### Summary

BUG-019 independent test exposed two foreign raw-timeout calls in canonical
framework validation. The finding was deduplicated against all current BUG/IMP
packets and the absent `specs/` surface, reproduced once on the current tree,
and traced to a binary-level shim that does not consume the existing portable
helper. No fix was attempted.

### Completion Statement

NONTERMINAL INTAKE. The bug is confirmed and routed, not fixed, tested after a
fix, released, upgraded downstream, or certified. Every delivery DoD remains
unchecked and `state.json` remains blocked.

### Test Evidence

The before-fix exact portability diagnostic and packet-only artifact lint ran
in this intake. No RED regression file, GREEN, framework validation, release
validation, downstream upgrade, or certification command ran for BUG-021.

## Bug Reproduction - Before Fix

**Phase:** discovery
**Command:** `printf '%s\n' 'BUG021_CURRENT_REPRO_BEGIN'; set +e; bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh; reproduction_exit=$?; set -e; printf 'BUG021_CURRENT_REPRO_EXIT=%s\n' "$reproduction_exit"; printf '%s\n' 'BUG021_CURRENT_REPRO_END'; exit "$reproduction_exit"`
**Exit Code:** 1
**Claim Source:** executed

```text
BUG021_CURRENT_REPRO_BEGIN
== macOS portability guard -- scanning 5 file(s) ==
FAIL macOS-portability violation -- class-1 raw-timeout
   bubbles/scripts/framework-validate.sh:190:run_check "macOS portability guard selftest (bubbles-cross-platform-shell)" timeout "$macos_portability_guard_timeout_seconds" bash "$SCRIPT_DIR/macos-portability-guard-selftest.sh"
   bubbles/scripts/framework-validate.sh:292:run_check "Workflow planning provenance selftest" timeout "$planning_provenance_timeout_seconds" bash "$SCRIPT_DIR/workflow-planning-provenance-selftest.sh"
   remedy: route through bubbles_run_with_timeout (guard-lib.sh); preserve exit 124
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

FAIL: 1 macOS-portability construct class(es) found in the scanned surface.
See instructions/wsl-macos-compatibility.instructions.md (and skill bubbles-cross-platform-shell).
BUG021_CURRENT_REPRO_EXIT=1
BUG021_CURRENT_REPRO_END
```

## Packet Structure Validation

**Phase:** documentation
**Command:** `packet_exit=0; for packet in improvements/BUG-020-state-transition-bash32-startup improvements/BUG-021-framework-validate-raw-timeout; do printf 'PACKET_LINT_BEGIN=%s\n' "$packet"; bash bubbles/scripts/artifact-lint.sh "$packet"; lint_exit=$?; printf 'PACKET_LINT_EXIT=%s path=%s\n' "$lint_exit" "$packet"; printf 'PACKET_LINT_END=%s\n' "$packet"; if [[ "$lint_exit" -ne 0 ]]; then packet_exit=1; fi; done; exit "$packet_exit"`
**Exit Code:** 0
**Claim Source:** executed

```text
PACKET_LINT_BEGIN=improvements/BUG-021-framework-validate-raw-timeout
Required artifact exists: spec.md
Required artifact exists: design.md
Required artifact exists: uservalidation.md
Required artifact exists: state.json
Required artifact exists: scopes.md
Required artifact exists: report.md
No forbidden sidecar artifacts present
Detected state.json status: blocked
Detected state.json workflowMode: bugfix-fastlane
Top-level status matches certification.status
Artifact lint PASSED.
PACKET_LINT_EXIT=0 path=improvements/BUG-021-framework-validate-raw-timeout
PACKET_LINT_END=improvements/BUG-021-framework-validate-raw-timeout
```

The command also emitted one nonblocking notice that `scopeProgress` is
deprecated; that field remains because the active bug-agent contract explicitly
requires it in a version-3 intake state.

## Root-Cause Evidence

**Claim Source:** interpreted
**Interpretation:** Source inspection connects the exact scanner output to a
narrow supervision-contract mismatch:

- `framework-validate.sh` creates a `gtimeout` alias only when the optional GNU
  binary is installed.
- the script does not source `guard-lib.sh` and directly invokes raw `timeout`
  at the two scanner-reported registrations.
- `guard-lib.sh` already implements `timeout`, `gtimeout`, and watchdog
  fallbacks with exit `124` normalization.
- the exact scanner is helper-aware and therefore correctly distinguishes the
  raw calls from calls routed through `bubbles_run_with_timeout`.

This is root-cause analysis, not post-fix execution proof.

## Deduplication Result

**Claim Source:** interpreted

| Candidate | Result | Reason |
| --- | --- | --- |
| IMP-018 | Prior design context, not bug owner | It introduced the scanner and documents intentional framework exemption, but it is not an active bug packet and leaves both calls raw. |
| BUG-013 | Different call sites | Its raw-timeout scope is limited to sensitive-storage scanner selftest runners. |
| BUG-018 | Reporter only | Its report classifies the same two lines as pre-existing and excludes framework-validation portability from its repair. |
| BUG-019 | Reporter only | Row `T-BUG-019-07` records the exact foreign failure and leaves implementation to another owner. |
| Current `specs/` | No candidate | The canonical Bubbles checkout has no `specs/` directory. |
| `BUGS.md` | No candidate | No matching active record owns these two registrations. |

Verdict: no active canonical bug packet owned the finding; BUG-021 is the
single canonical intake.

## Bug Verification - After Fix

**Phase:** discovery
**Claim Source:** not-run
**Reason:** The operator prohibited implementation, test changes, release
metadata changes, certification, and downstream mutation in this invocation.
No after-fix command exists because no fix exists.

## Ownership And Routing

- First required owner: `bubbles.design` for authoritative design ownership.
- Later owners: `bubbles.plan`, `bubbles.test` for failing-first regression,
  `bubbles.implement`, independent `bubbles.test`, `bubbles.releases`,
  `bubbles.docs`, and `bubbles.validate`.
- Unresolved finding `BUG021-F001`: two framework validation deadlines bypass
  the portable helper and fail the exact portability contract.
- Dependency impact: BUG-019 `T-BUG-019-07`, canonical framework validation,
  release reconciliation, and supported downstream upgrade remain blocked.

## Invocation Audit

No subagent was invoked because no `runSubagent` capability was available and
the operator requested packet-only diagnosis. No specialist execution is
claimed.

## Independent Scope 1 Test Round - 2026-07-17

This section records one synchronous `bubbles.test` round against the current
canonical source. The round started at `2026-07-17T04:50:45Z` and completed at
`2026-07-17T05:58:23Z`. It changed one test-owned downstream fixture,
`bubbles/scripts/v5.3-selftest.sh`, and appended only test evidence plus
execution routing in this packet. It did not edit the frozen BUG-021
regression, production validator, timeout helper, install-provenance selftest,
release manifest, planning artifacts, DoD checkboxes, scope status,
`completedPhaseClaims`, top-level status, or `certification.*`.

### Current Byte Identity

**Phase:** test
**Executed:** YES (current session)
**Command:** SHA-256 fence over the frozen regression, production validator,
helper, install-provenance selftest, release manifest, sibling packet states,
and the downstream canary
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78  tests/regression/test_28_framework_validate_portable_timeout.sh
a493a55d5f616d44ac67c1aa24dd595ba05498b16c03fc08ec37dd5f03c5d4cd  bubbles/scripts/framework-validate.sh
411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1  bubbles/scripts/guard-lib.sh
15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa  bubbles/scripts/install-provenance-selftest.sh
c329e52c490fbbb52a2c139c59cf2a182a6b8906f75491c1e0c24a1611efce70  bubbles/release-manifest.json
5fd3cc5e870d74e7b94454119e4eee8d6dd369111a2e0f5f3eed9ee9fc93fdc9  improvements/BUG-019-state-transition-spec-mjs-path/state.json
9c40a1b4adeb8c0fb1b136de149f77f8b770134887c2ca02a008043d6ca1253f  improvements/BUG-020-state-transition-bash32-startup/state.json
c04eae6dd49fcd774d641f80bf924539755ee7cac45f6780559c50665ad049ff  improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json
011d3bb05df635c80b61bda9934c524970cc2a338ac6dbe9e4ddb4b6111585ce  bubbles/scripts/v5.3-selftest.sh
```

**Result:** PASS. Every protected and sibling hash remained stable throughout
the final frozen regression and both broad validation commands. The
`c329e52c...` release-manifest bytes are preserved as concurrent release
provenance and are not attributed to this test round.

### Frozen Production Regression - T-BUG-021-01 Through T-BUG-021-05

**Phase:** test
**Executed:** YES (current session)
**Command:** `for file in tests/regression/test_28_framework_validate_portable_timeout.sh bubbles/scripts/framework-validate.sh; do if command -v sha256sum >/dev/null 2>&1; then sha256sum "$file"; elif command -v shasum >/dev/null 2>&1; then shasum -a 256 "$file"; else printf 'SHA-256 tool unavailable\n' >&2; exit 127; fi; done; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_28_framework_validate_portable_timeout.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:** terminal accounting from the final complete run

```text
PRODUCTION_SHA256_AFTER=a493a55d5f616d44ac67c1aa24dd595ba05498b16c03fc08ec37dd5f03c5d4cd
HELPER_SHA256_AFTER=411aa38232ec144958d5cafbad2e7f7f6b2a8e9ad2427afea184e5f1057208f1
PROVENANCE_SHA256_AFTER=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_SHA256_AFTER=c329e52c490fbbb52a2c139c59cf2a182a6b8906f75491c1e0c24a1611efce70
TEST_SHA256_AFTER=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
GREEN_MUST_USE_TEST_SHA256_FINAL=62f724f731d7e4c000fab97e4ced4ffd7c0003450ebaaa6c4cca397d119e3d78
SOURCE_SHAPE=repaired
PORTABILITY_SCAN_EXIT=0
CANONICAL_EXIT=0
CANONICAL_MAC_STARTED=yes
CANONICAL_PLAN_STARTED=yes
CANONICAL_SENTINEL=yes
VALIDATOR_RUNS=11
HELPER_RUNS=5
MUTANT_RUNS=5
PASSED_ASSERTIONS=97
CONTRACT_FAILURES=0
HARNESS_FAILURES=0
BUG021_RED_DISPOSITION=CURRENT_SOURCE_GREEN
BUG-021 portable framework deadline regression passed.
```

**Result:** PASS. The real staged production entrypoint executes both deadline
targets with neither optional timeout provider, preserves helper results `0`,
ordinary `3`, and watchdog `124`, records timeout and ordinary failure once,
continues to the other target and later sentinel, fails loud when the managed
helper is missing, preserves both independent deadline overrides and `120`
defaults, selects `timeout` before `gtimeout` before watchdog, and rejects both
raw-call, both direct-child, and the `124`-remap mutants.

### Focused Canary Matrix - T-BUG-021-06 Through T-BUG-021-11

**Phase:** test
**Executed:** YES (current session)
**Commands:** the exact Test Plan commands for helper semantics, portability
guard behavior, direct production portability, BUG-019's exact portability
surface, regression quality, and Bash 3.2 syntax
**Exit Codes:** 0, 0, 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
state-transition-guard-perf-selftest: 7 passed, 0 failed
PASS: timeout helper propagates ordinary child exit 3
PASS: timeout helper normalizes watchdog expiration to 124
[selftest macos-portability-guard] OK - all assertions passed.
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
DIRECT_PRODUCTION_PORTABILITY_EXIT=0
BUG019_EXACT_PORTABILITY_EXIT=0
BASH32_SYNTAX_EXIT=0
SOURCE_HELPER_COUNT=1
HELPER_TARGET_CALL_COUNT=2
RAW_TARGET_COUNT=0
BUG019_LINE=298
BUG021_LINE=299
EXACT_REGISTRATION_COUNT=1
```

**Result:** PASS. The BUG-021 source-only registration exists exactly once and
is immediately after BUG-019. Direct and exact portability scans report zero
findings without a BUG-021 suppression. The frozen regression has an
adversarial signal and no regression-quality finding, and all changed BUG-021
shell parses under macOS system Bash.

### Downstream Fixture RED To GREEN

The first full framework run exposed a local test-fixture defect: the
synthetic downstream tree in `bubbles/scripts/v5.3-selftest.sh` copied the now
helper-dependent `framework-validate.sh` but omitted its managed sibling
`guard-lib.sh`. That selftest failed at validator startup before its own
assertions. Test ownership added only `guard-lib.sh` to the existing copy list
and immediately reran the same selftest.

**Phase:** test
**Executed:** YES (current session)
**Command:** `bash bubbles/scripts/v5.3-selftest.sh`
**Exit Code:** 0 after the one-line test-owned repair
**Claim Source:** executed
**Result:** PASS. Source-mode and downstream-mode detection pass, the complete
source-only skip set stays clean in the synthesized downstream tree, and both
downstream-resolvable selftests pass. `/bin/bash -n` and the 13-class macOS
portability scan also exit `0` for the changed canary. Its final SHA-256 is
`011d3bb05df635c80b61bda9934c524970cc2a338ac6dbe9e4ddb4b6111585ce`.

The initial broad-run MCP HTTP transport failure was replayed separately and
passed all `6/6` assertions. It is retained as transient broad-run evidence,
not relabeled as a BUG-021 implementation or release finding.

### Install And Source-Only Boundary - T-BUG-021-12

**Phase:** test
**Executed:** PARTIAL for the complete row
**Commands:** canonical `install-provenance-selftest.sh` plus a fresh supported
install into an owned temporary Git repository
**Exit Codes:** 0, 0
**Claim Source:** executed
**Output:** fresh supported-install boundary

```text
INSTALL_EXIT=0
PASS: framework validator installed
PASS: guard-lib sibling installed
PASS: installed validator matches canonical source
PASS: installed helper matches canonical source
PASS: .manifest owns framework validator
PASS: .manifest owns guard-lib sibling
PASS: .checksums records framework validator
PASS: .checksums records guard-lib sibling
PASS: test_28 remains absent from downstream install
PASS: test_28 remains absent from downstream .manifest
PASS: test_28 remains absent from downstream .checksums
INSTALLED_HELPER_SOURCE_COUNT=1
INSTALLED_SOURCE_ONLY_REGISTRATION_COUNT=1
INSTALLED_RELEASE_MANIFEST_TEST28_COUNT=0
RELEASE_IDENTITY_OWNER=bubbles.releases
SUPPORTED_INSTALL_BOUNDARY_FAILURES=0
```

**Result:** PARTIAL. Managed entrypoint/helper installation, byte identity,
downstream ownership, sibling loading, source-only registration, and downstream
exclusion are proven. The canonical install-provenance selftest also passes its
current declared matrix (`614` managed files), but it has no BUG-021-specific
assertion and the current release manifest has zero `test_28` source-only
entries. Therefore `T-BUG-021-12` remains incomplete rather than being marked
passed.

The first supported-install probe is discarded: its temporary target was not
initialized as a Git repository, so `install.sh` correctly refused with
`Not a git repo`. No product assertion from that attempt supports a pass claim.

### Broad Framework Validation - T-BUG-021-13

**Phase:** test
**Executed:** YES (current session)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 1
**Claim Source:** executed
**Output:** terminal aggregate after the v5.3 repair

```text
PASS: v5.3 downstream-install selftest (G1)
PASS: MCP HTTP transport selftest (v6.1 / R9)
PASS: BUG-021 portable framework deadline regression
PASS: Install provenance selftest
Framework validation failed with 2 failing check(s).
Failed checks:
  - Release manifest freshness
  - Release manifest selftest
```

**Result:** FAIL for the complete row. The registered BUG-021 regression,
downstream canary, MCP transport, install provenance, and every non-release
broad check are green. The two remaining labels are one release-identity root
and its dependent selftest. A focused check confirms the current generated
manifest is stale and still lacks the frozen `test_28` source-only identity.
No generated byte was edited by this test round.

### Release Validation - T-BUG-021-14

**Phase:** test
**Executed:** YES (current session)
**Command:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code:** 1
**Claim Source:** executed
**Output:** terminal aggregate

```text
Framework validation failed with 2 failing check(s).
Failed checks:
  - Release manifest freshness
  - Release manifest selftest
FAIL: Framework validation
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Release manifest freshness
Unexpected temporary or backup file: improvements/BUG-022-state-transition-bash32-empty-array-nounset/.design-clean-99fcbe20.tmp
FAIL: No stray temp or backup files
Release check failed with 3 failing check(s).
```

**Result:** FAIL. `RELEASE-021-001` remains release-owned. The extra temporary
file is a foreign BUG-022 cleanup finding; this test round neither created nor
removed it. The release manifest remains exactly
`c329e52c490fbbb52a2c139c59cf2a182a6b8906f75491c1e0c24a1611efce70`.

### Packet, Traceability, And Test-Substance Evidence

**Phase:** test
**Executed:** YES (current session)
**Commands:** BUG-021 artifact lint, artifact freshness, G094,
traceability, strict Markdown/JSON/DoD parity, and deterministic test-substance
audit
**Exit Codes:** 0, 0, 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
Scenarios checked: 2
Test rows checked: 15
Scenario-to-row mappings: 2
Concrete test file references: 2
Report evidence references: 2
DoD fidelity scenarios: 2 (mapped: 2, unmapped: 0)
RESULT: PASSED (0 warnings)
JSON_TEST_IDS=T-BUG-021-00,T-BUG-021-01,T-BUG-021-02,T-BUG-021-03,T-BUG-021-04,T-BUG-021-05,T-BUG-021-06,T-BUG-021-07,T-BUG-021-08,T-BUG-021-09,T-BUG-021-10,T-BUG-021-11,T-BUG-021-12,T-BUG-021-13,T-BUG-021-14
PARITY_FAILURES=0
SKIP_ONLY_TODO_PENDING_HITS=0
REQUEST_INTERCEPTION_HITS=0
SCENARIO_001_MARKERS=1
SCENARIO_002_MARKERS=1
RAW_CALL_MUTANT_REFERENCES=6
DIRECT_CHILD_MUTANT_REFERENCES=6
TIMEOUT_REMAP_MUTANT_REFERENCES=3
REAL_PRODUCTION_ENTRYPOINT_BINDINGS=1
MOCK_AUDIT_RECLASSIFICATIONS=none
SELF_VALIDATING_AUDIT=PASS-production-exit-label-marker-and-mutant-outcomes
ADVERSARIAL_AUDIT=PASS-five-independent-mutants
TEST_SUBSTANCE_AUDIT_EXIT=0
```

The first shell implementation of the substance audit is discarded because a
multi-file `grep -c` result contained filename prefixes and caused zsh
arithmetic failure. The deterministic Node audit above is the controlling
evidence. No skip, only, todo, pending, interception, mock, silent bailout, or
self-validating required assertion remains.

### Scope 1 Test Verdict

| Test rows | Category | Current result | Required skips |
| --- | --- | --- | ---: |
| `T-BUG-021-00` | historical mandatory RED | PASS, preserved prior valid final-byte RED | 0 |
| `T-BUG-021-01` through `T-BUG-021-05` | e2e-api / functional | PASS, frozen production regression `97/0/0`, `11/5/5` | 0 |
| `T-BUG-021-06` through `T-BUG-021-11` | integration / functional | PASS, all focused helper, portability, quality, and syntax canaries | 0 |
| `T-BUG-021-12` | install provenance | PARTIAL, managed install and source-only exclusion pass; release identity absent | 0 |
| `T-BUG-021-13` | full framework integration | FAIL, two release-manifest checks | 0 |
| `T-BUG-021-14` | release identity | FAIL, release identity plus foreign BUG-022 temp file | 0 |

Overall verdict: **NOT_TESTED for complete Scope 1 delivery**. The BUG-021
runtime behavior, registration, focused suite, downstream fixture, managed
install relationship, and packet gates are independently green. The selected
15-row matrix is not all green, so this round does not mark Scope 1 Done, add a
completed test phase, change any DoD checkbox, or request certification.

### Finding Accounting And Route

| Finding | Disposition |
| --- | --- |
| `IMPLEMENT-021-001` | Addressed: exactly one adjacent source-only registration exists and executes the frozen production regression. |
| `TEST-021-002` | Unresolved overall: focused/current-runtime evidence is green, but rows 12-14 remain partial or failed on release identity. |
| `RELEASE-021-001` | Unresolved; owner `bubbles.releases` must generate canonical identity after the source/test/provenance set is accepted. |
| `VALIDATE-021-001` | Unresolved; owner `bubbles.validate` only after release and all selected rows pass. |
| `IMPLEMENT-021-CONCURRENT-RELEASE-MUTATION` | Addressed as provenance only: manifest SHA `c329e52c...` is preserved and not attributed to BUG-021 implementation or test. |
| `TEST-021-003-DOWNSTREAM-FIXTURE-HELPER` | Addressed: the synthetic downstream fixture now stages the mandatory managed sibling and passes. |
| `TEST-021-004-MCP-TRANSIENT` | Addressed diagnostically: isolated replay passes `6/6`, and the second broad run passes. |
| `BUG022-RELEASE-TEMP-001` | Unresolved foreign finding: BUG-022 owns its `.design-clean-99fcbe20.tmp` path. |

**Route:** `route_required` to `bubbles.releases`. This is a generated-identity
handoff, not a completion claim. The foreign BUG-022 temporary-file finding
must remain with its owning packet, and `bubbles.validate` remains downstream
of successful release validation.
