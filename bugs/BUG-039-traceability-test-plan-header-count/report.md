# BUG-039 Report - Traceability Test Plan Header Count

## Summary

The revision-7 implementation repairs the interrupted embedded-Python parser, centralizes every structural parser-status-4 failure through `fail_structure`, and adds persistent parser-level cases for rowless canonical and legacy tables, malformed-width rows, deterministic visible-line diagnostics, and second-table rejection in `READ_ROWS` and `DONE`. A source-isolated reconstruction now supplies genuine G060 behavioral RED evidence: the current exact probe ran against committed pre-fix revision `85429a1640e0da07e79849401497f06308d0078e` and observed parser exit `0` with empty output for a recognized rowless table. The identical probe then ran against current working source and observed parser exit `4` with the required deterministic visible-line diagnostic. The post-RED focused selftest passes and retains the exact 24-row aggregate assertion. TP-B039-02 is now evidence-backed. Aggregate framework validation, human acceptance, the completion gate, and terminal certification remain open.

## Completion Statement

BUG-039 remains nonterminal. Focused implementation evidence is recorded, but no aggregate-validation, human-acceptance, or validate-owned certification completion is claimed.

## Change Boundary

Implementation may change only `bubbles/scripts/traceability-guard.sh` and `bubbles/scripts/traceability-guard-selftest.sh`. Planning may change only this BUG-039 packet. BUG-037, BUG-038, receipt identity, execution control, state transition, release metadata, generated files, `BUGS.md`, downstream repositories, staging, commits, and pushes remain excluded.

## Bug Reproduction - Before Fix

**Claim Source:** executed

The genuine behavioral RED uses committed pre-fix revision `85429a1640e0da07e79849401497f06308d0078e` (`docs: reconcile receipt and evidence helper bugs`). Its committed `traceability-guard.sh` blob is `6c4f41e48e6692d5dc2910d2d05d5c876052fc8f`, with file SHA-256 `7d9f9ee38da7f0f825ed4eeabd65a166ed5219b680bbc269d99b8793d74a3626`. The isolated fixture combines that committed guard with the current exact probe, SHA-256 `482afa1a4e5366850db27236aec3c020cb3e2643f40949c5a7a3c0fc41be3110`.

The probe supplies a recognized canonical header and valid same-width separator, then reaches EOF without a data row. The revised contract requires parser status `4` and `ERROR: rowless recognized Test Plan table at visible line 7`. The committed parser instead returned status `0` with empty stdout and stderr. The probe therefore exited `1` because pre-fix behavior silently accepted the malformed structure. No syntax, dependency, path, or harness failure contributed to this RED.

The earlier interrupted-source run still remains syntax-break evidence only. Its `IndentationError` is not used for G060.

## Root Cause Evidence

**Claim Source:** interpreted from the inspected source and executed failures

The initial interruption misindented the section-boundary parser block. After that syntax repair, direct parser-status assertions still failed because the selftest shim recognized only the original `scopes.md` path while single-file scope analysis invokes the parser against temporary projected scope units. The final selftest shim recognizes those temporary analysis units without changing production parser semantics.

### Code Diff Evidence

- **Claim Source:** executed and tool-observed
- **Allowed runtime path changed:** `bubbles/scripts/traceability-guard.sh`.
- **Allowed persistent regression path changed:** `bubbles/scripts/traceability-guard-selftest.sh`.
- **BUG-039 packet paths already changed by revision-7 planning:** `design.md`, `report.md`, `scenario-manifest.json`, `scopes.md`, `state.json`, and `test-plan.json`. This implementation invocation edited only `report.md` among those packet paths.
- **Excluded concurrent paths visible in the shared working tree:** seven BUG-038 packet files were modified by concurrent work. They were not edited, staged, reverted, or claimed by this invocation.
- **Explicitly absent from the targeted diff listing:** BUG-037 and `BUGS.md`.
- **Git operation boundary:** no staging, commit, push, generation, or session-control advancement was performed.

## Test Evidence

### G060 Reconstructed Behavioral RED-GREEN - 2026-09-02

**Claim Source:** executed

**Test identity:** `BUG-039-G060-rowless-recognized-table-v1`

**Probe SHA-256:** `482afa1a4e5366850db27236aec3c020cb3e2643f40949c5a7a3c0fc41be3110`

**RED source identity:** commit `85429a1640e0da07e79849401497f06308d0078e`; committed blob `6c4f41e48e6692d5dc2910d2d05d5c876052fc8f`; file SHA-256 `7d9f9ee38da7f0f825ed4eeabd65a166ed5219b680bbc269d99b8793d74a3626`; embedded-parser SHA-256 `28dd524228de536414f23f8520f65ebf6bfc056e9d72f0bd466428c1eecd710c`.

**GREEN source identity:** working-file SHA-256 `21adcf3dff77b832bf51bc2aee477869202ac2f9d85c419a16822cca23d84377`; embedded-parser SHA-256 `e8e3b2da06a4506f9c8b8eb68e44c08d1610248d4e85de15ba6347bd0d5e23a3`.

#### RED - committed pre-fix parser

**Executed:** YES (current session)

**Command:** `timeout 30 python3 /tmp/bubbles-bug039-g060-r7-85429a1/rowless_contract_probe.py /tmp/bubbles-bug039-g060-r7-85429a1/bubbles-scripts/traceability-guard.sh`

**Exit Code:** 1

**Output SHA-256:** `8574ba8b28c4c1524ab110785e49179ed97ed1967e27f41614ccfd4d3b53273f`

```text
test_id=BUG-039-G060-rowless-recognized-table-v1
scenario=recognized canonical Test Plan header plus valid separator reaches EOF before any data row
expected_exit=4
expected_diagnostic=ERROR: rowless recognized Test Plan table at visible line 7
guard_path=/tmp/bubbles-bug039-g060-r7-85429a1/bubbles-scripts/traceability-guard.sh
guard_sha256=7d9f9ee38da7f0f825ed4eeabd65a166ed5219b680bbc269d99b8793d74a3626
parser_sha256=28dd524228de536414f23f8520f65ebf6bfc056e9d72f0bd466428c1eecd710c
actual_exit=0
actual_stdout=''
actual_stderr=''
status_assertion=FAIL
diagnostic_assertion=FAIL
silent_structural_status=YES
result=RED revised rowless-table contract violated
```

**Result:** FAIL as required for G060 RED. The failure is the revised behavioral assertion: pre-fix parser status `0` and silent output instead of status `4` plus the deterministic diagnostic.

#### GREEN - identical probe against current working parser

**Executed:** YES (current session, after RED)

**Command:** `timeout 30 python3 /tmp/bubbles-bug039-g060-r7-85429a1/rowless_contract_probe.py bubbles/scripts/traceability-guard.sh`

**Exit Code:** 0

**Output SHA-256:** `23604431fb0636fee8e0fd95d6eb098173a01aa6f56123e6f5504ee241b0e462`

```text
test_id=BUG-039-G060-rowless-recognized-table-v1
scenario=recognized canonical Test Plan header plus valid separator reaches EOF before any data row
expected_exit=4
expected_diagnostic=ERROR: rowless recognized Test Plan table at visible line 7
guard_path=bubbles/scripts/traceability-guard.sh
guard_sha256=21adcf3dff77b832bf51bc2aee477869202ac2f9d85c419a16822cca23d84377
parser_sha256=e8e3b2da06a4506f9c8b8eb68e44c08d1610248d4e85de15ba6347bd0d5e23a3
actual_exit=4
actual_stdout=''
actual_stderr='ERROR: rowless recognized Test Plan table at visible line 7\n'
status_assertion=PASS
diagnostic_assertion=PASS
silent_structural_status=NO
result=GREEN revised rowless-table contract satisfied
```

**Result:** PASS. RED and GREEN use the same probe file, test identity, fixture grammar, expected status, and expected diagnostic. Only the guard source changes.

#### Post-RED persistent focused regression

**Claim Source:** executed

`timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` ran after the first valid behavioral RED and exited `0`. The 439-line output SHA-256 is `46c27fbe26e93a28e4c386cdbe4851e2629a958d5ad32d5264f1a9afad57c882`, ending with `[selftest traceability-guard] PASS`. The persistent assertion at `traceability-guard-selftest.sh:1123-1124` requires `Test rows checked: 24` and labels the assertion `BUG-039 four Test Plan tables aggregate exactly 24 genuine rows`.

#### Focused packet checks after evidence update

**Claim Source:** executed

| Check | Command | Exit | Lines | SHA-256 / result |
| --- | --- | ---: | ---: | --- |
| Artifact lint | `timeout 120 bash bubbles/scripts/artifact-lint.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | 40 | `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`; artifact lint passed and confirmed every checked DoD item has an evidence block. |
| Packet traceability | `timeout 150 bash bubbles/scripts/traceability-guard.sh bugs/BUG-039-traceability-test-plan-header-count --all-scopes` | 0 | 62 | `a43c6fc4a7e58549aa44b0a4629eaf522b06dad7e82f3b2c501a4ac06a0b319c`; five scenarios, six Test Plan rows, five scenario-row mappings, five DoD mappings, and zero warnings. |

These checks validate the focused packet shape and traceability after the G060 update. They do not certify the bug, run aggregate framework validation, or complete human acceptance.

### Revision-7 Focused Implementation — 2026-09-02

**Claim Source:** executed in the current session

**Success Signal:** A four-table fixture with 24 genuine rows reports exactly 24.

| Check | Command | Exit | Lines | SHA-256 / exact result |
| --- | --- | ---: | ---: | --- |
| Focused parser regression | `timeout 300 bash bubbles/scripts/traceability-guard-selftest.sh` | 0 | 439 | `46c27fbe26e93a28e4c386cdbe4851e2629a958d5ad32d5264f1a9afad57c882`; final output reports `[selftest traceability-guard] PASS` |
| Active-shell syntax | `timeout 30 bash -n bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh` | 0 | 0 | Empty-output SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`; this proves active-shell parsing only |
| Adversarial regression quality | `timeout 60 bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/traceability-guard-selftest.sh` | 0 | 15 | `52f41639d4c5d3cd3b9f46117d5123b1313f8cda2f9eed8ef91a54a8e3de883d`; one file scanned and adversarial signal detected |
| GNU/BSD portability guard | `timeout 60 bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/traceability-guard.sh bubbles/scripts/traceability-guard-selftest.sh` | 0 | 19 | `a16baf86c41851b508f19adbea1e5b662941df0aa01f0c66b58577d34f4b2ac6`; all 16 portability classes clean |
| Artifact lint | `timeout 90 bash bubbles/scripts/artifact-lint.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | 40 | `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567` |
| Scenario-reference resolution | `timeout 90 bash bubbles/scripts/scenario-test-resolve.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | 1 | `0dcfba7fd7daa37bc02b638fdda3da4cd6235bec7fa68cf45a919782a6673bf1`; five references resolved |
| Packet traceability | `timeout 90 bash bubbles/scripts/traceability-guard.sh bugs/BUG-039-traceability-test-plan-header-count --all-scopes` | 0 | 62 | `b8f3f21697c287d76f237ac9fd3f56cb07323a6582119ed399cdca0aeba93b63`; five scenarios, six rows, zero warnings |
| Scenario-obligation lint | `timeout 90 bash bubbles/scripts/scenario-obligation-lint.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | 1 | `65e1b9b55671e52df5fed6a395b47468d622b2bb17d21810f7249b8748d81a93`; five coherent obligation sets |
| Test-mechanism lint | `timeout 90 bash bubbles/scripts/test-mechanism-lint.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | 2 | `370b60628b444d257236d9a3e0e601fcf14a74e2f94a1923e0a5475c66555cb3`; five coherent mechanisms and inert mutation adapter |
| Implementation-reality scan | `timeout 90 bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-039-traceability-test-plan-header-count --verbose` | 0 | 36 | `361d0a45a81eaddc2c5b1a35c08e531f947d68f88363b101390a2ffe06c2037a`; two files, zero violations, zero warnings |
| Goal-fidelity guard before this report update | `timeout 120 bash bubbles/scripts/goal-fidelity-guard.sh --boundary pre-certification --session-file .specify/memory/bubbles.session.json --spec-dir bugs/BUG-039-traceability-test-plan-header-count` | 1 | 2 | `942da3bb256e92a18d300f8ef7d413e115a10eadc3a4991726da164a5980043c`; correctly refused because the report did not yet demonstrate the declared Success Signal |
| Goal-fidelity guard after this report update | `timeout 120 bash bubbles/scripts/goal-fidelity-guard.sh --boundary pre-certification --session-file .specify/memory/bubbles.session.json --spec-dir bugs/BUG-039-traceability-test-plan-header-count` | 0 | 1 | `3bc6db28381ca97126677622f3eccd914d5ec26e9fae7e71814eeaf2db389a46`; pre-certification boundary passed |

Source inspection confirms the changed table classifier remains inside the embedded Python parser. The shell wrapper adds no Bash 4-only array/map construct and no GNU/BSD table-classification command. The portability guard passed, but neither that scan nor active-shell syntax is represented as execution under Bash 3.2.

### TP-B039-01 - Structural rows

**Claim Source:** executed

The focused parser regression passed and includes the canonical four-table fixture. Its assertions prove each six-row table excludes its header and separator and the aggregate contains 24 genuine rows.

### TP-B039-02 - G060 red-before-green exact 24-row aggregate

**Claim Source:** executed

The reconstructed RED is valid: the exact rowless-table contract probe exited `1` because committed pre-fix parser revision `85429a1640e0da07e79849401497f06308d0078e` silently returned parser status `0` and no diagnostic. The identical probe then passed against current working source, observing parser status `4` and the exact visible-line diagnostic. The later focused selftest exited `0`, produced 439 lines with SHA-256 `46c27fbe26e93a28e4c386cdbe4851e2629a958d5ad32d5264f1a9afad57c882`, and retained the exact 24-row aggregate assertion. G060 and TP-B039-02 are satisfied. The earlier `IndentationError` run remains excluded from behavioral RED evidence.

### TP-B039-03 - Closed heading compatibility

**Claim Source:** executed

The focused regression passes canonical and legacy heading controls, all three exact path aliases, and deterministic status-4 rejection of unsupported, duplicate, partial, and mixed header families.

### TP-B039-04 - Malformed, rowless, and failure-layer behavior

**Claim Source:** executed

The focused regression passes missing, empty, invalid, delayed, narrow, and wide separator cases; narrow and wide data rows; empty required cells; canonical and legacy rowless terminals; direct parser-status-4 markers; exact visible-line diagnostics; and separate outer extraction-failure assertions. Source inspection finds one `SystemExit(4)`, owned only by `fail_structure`.

### TP-B039-05 - Boundaries and second-table refusal

**Claim Source:** executed

The focused regression passes blank, prose, deeper-heading, section-boundary, and EOF rowless boundaries plus adjacent and separated second-table rejection in the parser's `READ_ROWS` and `DONE` states.

### TP-B039-06 - Active-shell syntax and portability review

**Claim Source:** executed and interpreted

Both files parse under the active Bash. The dedicated portability guard passes all 16 checks. Source review confirms Python still owns Markdown classification. No claim of actual Bash 3.2 execution is made.

### Superseded Planning-Only Evidence Declaration

The earlier revision-7 planning-only declaration predated the focused implementation and G060 reconstruction recorded above. Its statements that no current-session implementation or Test Plan evidence existed are superseded and are not active evidence claims. The preserved focused implementation section is the active evidence source. Active-shell syntax and static portability checks still do not prove native Bash 3.2 execution.

## Historical Revision-5 Validate-Owned Evidence — Superseded for Current Planning Claims

**Claim Source:** interpreted

**Interpretation:** In the earlier revision-5 session, the focused selftest exited 0 and its hash-backed 267-line output covered the then-current BUG-039 parser cases. That historical run does not satisfy revision-7 G060 red-before-green evidence, current source-test evidence, Code Diff Evidence, aggregate framework validation, or certification.

### Current-Session Command Evidence

**Claim Source:** executed

| Gate | Command | Exit | Result |
| --- | --- | ---: | --- |
| Repository packet | `repository-binding.sh validate-packet` against control revision 5 | 0 | PASS |
| Artifact shape | `artifact-lint.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | PASS with a legacy-layout warning for `uservalidation.md` |
| Scenario references | `scenario-test-resolve.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | PASS |
| Focused parser regression | `traceability-guard-selftest.sh` | 0 | PASS; 267 captured lines, SHA-256 `964a3c608d35836e38ffb289d06762bc11b1fbf2b5bd7191db8f5a73bea56438` |
| Active-shell syntax | `bash -n` on the parser and selftest | 0, 0 | PASS |
| GNU/BSD portability scan | `macos-portability-guard.sh` on the parser and selftest | 0 | PASS |
| Packet traceability | `traceability-guard.sh bugs/BUG-039-traceability-test-plan-header-count` | 1 | FAIL; zero scope-defined Gherkin scenarios detected |
| Goal fidelity | `goal-fidelity-guard.sh --boundary pre-certification ...` | 0 after this addendum | PASS |
| Artifact freshness | `artifact-freshness-guard.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | PASS; zero failures and zero warnings |
| Implementation reality | `implementation-reality-scan.sh ... --verbose` | 1 | FAIL; no implementation paths resolved from scope or design artifacts |
| Transition contract | `transition-contract-resolver.sh bugs/BUG-039-traceability-test-plan-header-count` | 0 | PASS; `bugfix-fastlane`, target `done`, delivery audit required |
| State transition | `state-transition-guard.sh bugs/BUG-039-traceability-test-plan-header-count` | 1 | FAIL; 26 failures, eight failed gates |
| Aggregate framework validation | prohibited by the focused operator boundary | not run | UNRUN |
| Human acceptance | checklist remains unchecked | not run | BLOCKED |

### Traceability Failure Evidence

**Claim Source:** executed

```text
# BUG-039 traceability guard
$ bash bubbles/scripts/traceability-guard.sh bugs/BUG-039-traceability-test-plan-header-count
exit: 1
lines: 24
sha256: ce0722b4f8d3897a666a5d3cc7b87b78962b7a5f57effb505af8ccc39463231e
--- output ---
--- Scenario Manifest Cross-Check (G057/G059) ---
No scope-defined Gherkin scenarios found — scenario manifest cross-check skipped
Checking traceability for Scope 1: Deterministic contiguous Test Plan extraction
Scope 1: Deterministic contiguous Test Plan extraction has no Gherkin scenarios to trace
Scenarios checked: 0
Test rows checked: 0
Scenario-to-row mappings: 0
Concrete test file references: 0
Report evidence references: 0
RESULT: FAILED (1 failures, 0 warnings)
```

### Certification Disposition

**Claim Source:** interpreted

BUG-039 remains `in_progress`. The planning packet now recognizes SCN-B039-001 through SCN-B039-005 and preserves six Test Plan rows. The next required owner is `bubbles.test` for independent focused execution and finding classification. Aggregate framework validation, human acceptance, and validate-owned certification remain later blockers and are not advanced here.

### Transition Guard Result

**Claim Source:** executed

The current-session transition guard produced SHA-256 `906d4d7992b9e342421444a723ed84ae27f06a52146ab04f9419d208aad46d47`, exit 1, `failureCount: 26`, and `blockingCode: DELIVERY_COMPLETION_FAILED`. Failed gates were `G055`, `G060`, `G041`, `G022`, `G053`, `G027`, `G028`, and `G136`. No certification field was advanced.
