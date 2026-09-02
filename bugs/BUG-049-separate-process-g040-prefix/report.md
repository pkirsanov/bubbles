# BUG-049 Report

Links: [scopes.md](scopes.md) | [uservalidation.md](uservalidation.md)

## Summary

- Replaced the prefix-unbounded `separate PR` branch with portable right-bounded
  `PR` and `pull request` alternatives.
- Added a BUG-049-only production-guard matrix for lower, title, and upper-case
  process prose plus genuine PR controls.
- Regenerated the shared release manifest from the changed source bytes.
- Recorded the complete T1-T5 guard aggregate from current-session tool-log row
  333 without replaying the shared selftest during closeout.

## Completion Statement

Scope 01 implementation is present, its focused scenario matrix passes, and the
complete T1-T5 guard aggregate is recorded at tool-log row 333. The bug and
scope remain in progress; full source framework T6 and validate-owned
certification are not claimed by this implementation report. Independent T1-T5
verification is routed to `bubbles.test`.

## Test Evidence

### Scenario-First RED

**Executed:** YES (current session)
**Phase:** implement
**Command:** `BUBBLES_STATE_TRANSITION_GUARD_BUG049_ONLY=1 /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 960 /opt/homebrew/bin/bash bubbles/scripts/tool-log.sh -- /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --lines 40 --label 'BUG-049 Scope 01 scenario-first focused RED on current shared guard bytes' -- /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 900 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 1 (expected RED)
**Claim Source:** executed

```text
# BUG-049 Scope 01 scenario-first focused RED on current shared guard bytes
exit: 1
lines: 176
sha256: b6d9711e22c6de0f429cad96f88997bf963f77c4fe837bfc1ef324175f913075
--- first 40 ---
Running BUG-049 negative: separate process case variants remain inert...
FAIL: BUG-049 SCN-B049-001/004: complete process tokens do not match the PR alternative
🔴 BLOCK: Report artifact contains        1 deferral language hit(s): report.md — evidence of deferred work (Gate G040)
Running BUG-049 positive: separate PR at end of line remains blocking...
PASS: BUG-049 SCN-B049-002: a complete PR token at end of line remains blocking
Running BUG-049 positive: case-insensitive separate PR with punctuation remains blocking...
PASS: BUG-049 SCN-B049-002/004: a case variant followed by punctuation remains blocking
Running BUG-049 positive: separate pull request remains blocking...
FAIL: BUG-049 SCN-B049-003: the complete pull request phrase remains blocking
state-transition-guard BUG-049 selftest failed with 2 issue(s).
```

### Focused GREEN

**Executed:** YES (current session)
**Phase:** implement
**Command:** `BUBBLES_STATE_TRANSITION_GUARD_BUG049_ONLY=1 /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 960 /opt/homebrew/bin/bash bubbles/scripts/tool-log.sh -- /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --lines 40 --label 'BUG-049 Scope 01 focused GREEN immediately after first source edit' -- /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 900 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-049 Scope 01 focused GREEN immediately after first source edit
exit: 0
lines: 10
sha256: 72bf9e2796cdf2b1ff3133d590af75b86f102d9d1ddce100c2153e1b6cb2694a
Running BUG-049 negative: separate process case variants remain inert...
PASS: BUG-049 SCN-B049-001/004: complete process tokens do not match the PR alternative
Running BUG-049 positive: separate PR at end of line remains blocking...
PASS: BUG-049 SCN-B049-002: a complete PR token at end of line remains blocking
Running BUG-049 positive: case-insensitive separate PR with punctuation remains blocking...
PASS: BUG-049 SCN-B049-002/004: a case variant followed by punctuation remains blocking
Running BUG-049 positive: separate pull request remains blocking...
PASS: BUG-049 SCN-B049-003: the complete pull request phrase remains blocking
state-transition-guard BUG-049 selftest passed.
```

### Shell And Portability

**Executed:** YES (current session)
**Phase:** implement
**Commands:** `bash -n` and `shellcheck -S warning -x` on both touched scripts; `bash bubbles/scripts/macos-portability-guard.sh` on both touched scripts
**Exit Codes:** 0, 0, 0
**Claim Source:** executed

```text
== macOS portability guard -- scanning 2 file(s) ==
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
ok   class-14 mktemp-parent-dir: none
ok   class-15 mktemp-nontrailing-x: none
ok   class-16 awk-3arg-match: none
PASS: the scanned surface is WSL+macOS portable.
# BUG-049 focused GREEN under GNU grep
exit: 0
lines: 10
sha256: 72bf9e2796cdf2b1ff3133d590af75b86f102d9d1ddce100c2153e1b6cb2694a
state-transition-guard BUG-049 selftest passed.
```

### Scenario And Mechanism Checks

**Executed:** YES (current session)
**Phase:** implement
**Commands:** `scenario-compile-lint.sh`, `scenario-obligation-lint.sh`, `scenario-test-resolve.sh`, and `test-mechanism-lint.sh`
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed

```text
# BUG-049 exact scenario plan compile lint
exit: 0
lines: 1
sha256: c5ef395450de27d800f04b7725548773cc18a5910842690a25b7db3ce4ceee4f
[scenario-compile-lint] OK (scenario 'ozhiva-framework-delivery-evox2-20260901': 22 node(s), 4 repo(s) validated)
# BUG-049 scenario obligation lint
exit: 0
lines: 1
sha256: 3979d4214fdb7145fa4cad82986c6a605516b95479ac3ed7f6308d0a62022a0b
[scenario-obligation-lint] OK — 4 scenario(s) with a coherent derived obligation matrix
# BUG-049 linked scenario test resolution
exit: 0
lines: 1
sha256: 596c804c1e26a659adf9302f86fa4a9761f7ee95120affa27fed93353cbdc118
[scenario-test-resolve] OK — 4 reference(s) resolved via literal-scan
# BUG-049 test mechanism lint
exit: 0
lines: 2
sha256: 36ffdf83fc233d8197e21b38176847355aac161f635cd8a56fba0c9fa68295f6
[test-mechanism-lint] OK — 4 declared mechanism(s) coherent with their scenario traits
[mutation-receipt] OK — mutationExecution adapter is none (inert)
```

### Implementation Reality

**Executed:** YES (current session)
**Phase:** implement
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-049-separate-process-g040-prefix`
**Exit Code:** 0
**Claim Source:** executed

```text
ℹ️  INFO: Resolved 2 implementation file(s) to scan
--- Scan 1: Gateway/Backend Stub Patterns ---
--- Scan 1B: Handler / Endpoint Execution Depth ---
--- Scan 1C: Endpoint Not-Implemented / Placeholder Responses ---
--- Scan 1D: External Integration Authenticity ---
--- Scan 2: Frontend Hardcoded Data Patterns ---
--- Scan 2B: Sensitive Client Storage ---
--- Scan 3: Frontend API Call Absence ---
--- Scan 4: Prohibited Simulation Helpers in Production ---
--- Scan 5: Default/Fallback Value Patterns ---
--- Scan 6: Live-System Test Interception ---
ℹ️  INFO: No live-system test files referenced in scope artifacts for interception scan
--- Scan 7: IDOR / Auth Bypass Detection (Gate G047) ---
--- Scan 8: Silent Decode Failure Detection (Gate G048) ---
  Files scanned:  2
  Violations:     0
  Warnings:       0
🟢 PASSED: No source code reality violations detected
```

### Traceability Guard

**Executed:** YES (current session)
**Phase:** implement
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/traceability-guard.sh bugs/BUG-049-separate-process-g040-prefix`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-049 scenario traceability guard
exit: 0
lines: 55
sha256: 80d8066d93a483aea0e5098bc5ef8c81322a687361c7fd7fbf4159b1fe641483
--- Scenario Manifest Cross-Check (G057/G059) ---
✅ scenario-manifest.json covers 4 scenario contract(s)
✅ scenario-manifest.json records evidenceRefs for all 4 scenario contract(s)
✅ All linked tests from scenario-manifest.json exist
ℹ️  scopes.md summary: scenarios=4 test_rows=7
--- Gherkin → DoD Content Fidelity (Gate G068) ---
ℹ️  DoD fidelity: 4 scenarios checked, 4 mapped to DoD, 0 unmapped
--- Traceability Summary ---
ℹ️  Scenarios checked: 4
ℹ️  Test rows checked: 7
ℹ️  Scenario-to-row mappings: 4
ℹ️  Concrete test file references: 4
ℹ️  Report evidence references: 4
ℹ️  DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=8 inferred=0 ambiguous=0
RESULT: PASSED (0 warnings)
```

### Regression Quality

**Executed:** YES (current session)
**Phase:** implement
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /private/tmp/bubbles-ozhiva-transition-unblock-ca550392
  Timestamp: 2026-09-02T14:50:38Z
  Bugfix mode: true
============================================================
ℹ️  Scanning bubbles/scripts/state-transition-guard-selftest.sh
✅ Adversarial signal detected in bubbles/scripts/state-transition-guard-selftest.sh
============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

### Complete T1-T5 Aggregate

**Executed:** YES (current session; existing tool-log evidence)
**Phase:** implement
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --lines 40 --label BUG-049 Scope 01 complete state-transition-guard selftest current final source bytes -- /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 5400 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool Log:** `.specify/runtime/tool-calls.jsonl` row 333

The durable evidence source is the complete JSONL row. This projection records
the exact fields consumed by implementation closeout:

```text
toolLogRow=333
schemaVersion=2
timestamp=2026-09-02T15:08:33Z
sessionId=vscode-495a6380e8e00ef101b07d78b21f9341
agent=bubbles.implement
spec=BUG-049-separate-process-g040-prefix
scope=01-token-bounded-g040-pr-matching
exitCode=0
durationMs=841375
stdoutHash=3180ede34622de0bd8dfd76b6e31c93a83d9e63c8d01e582a8e5652f46b931b4
stdoutBytes=6617
stderrHash=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
stderrBytes=0
inputClosure[bubbles/scripts/state-transition-guard.sh]=7eceacc13e633996f03a50813cbe2cd8165910d291975ddb1fa9354387078a82
inputClosure[bubbles/scripts/state-transition-guard-selftest.sh]=71b6d196ded793af9a67a722a4189514ab08c43fd8d282a47c05843800217818
tags=BUG-049,SCOPE-01,implement,GREEN,T1,T2,T3,T4,T5,complete-state-transition-guard-selftest,G040,binding-revision-4,current-final-source-bytes,no-T6
```

### Release Manifest

**Executed:** YES (current session)
**Phase:** implement
**Commands:** `bash bubbles/scripts/generate-release-manifest.sh` and `bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Codes:** 0, 0
**Claim Source:** executed

```text
# BUG-049 regenerate release manifest from changed source bytes
exit: 0
lines: 1
sha256: 4815d540e941642607988ec417f5b86c003e9bbfb8f02ab8bdcbdc3caf61449a
Updated release manifest: 7.28.0 (927 managed files)
# BUG-049 verify regenerated release manifest
exit: 0
lines: 1
sha256: 229c480c967b4984a879ab6b9c6442cf009bffecec8f15483ed4fec3ab097a73
Release manifest is current: 7.28.0 (927 managed files)
BUG049_RELEASE_MANIFEST_EXIT generate=0 check=0
# BUG-049 release manifest focused selftest
exit: 0
lines: 30
sha256: f475d294f78256f27f11797df1f03ad755db104de9f55dd84ebf2a5928780210
PASS: Committed release manifest is current
PASS: Manifest records framework-managed file count (927)
release-manifest selftest passed.
# BUG-049 release manifest purity selftest
exit: 0
lines: 7
sha256: 57d8bb32b6247af62d10f1c656311336c3bc00594930600ac580a62f70e2b36d
release-manifest-purity-selftest: PASS
```

<!-- bubbles:certifying-window-begin -->

## Code Diff Evidence

**Executed:** YES (current session)
**Phase:** implement
**Command:** `git status --short`, `git diff --stat`, and `git diff --name-only` over the BUG-049 allowed surface, followed by sibling packet status inspection
**Exit Code:** 0
**Claim Source:** executed

```text
BUG049_ALLOWED_STATUS_BEGIN
 M bubbles/release-manifest.json
 M bubbles/scripts/state-transition-guard-selftest.sh
 M bubbles/scripts/state-transition-guard.sh
?? bugs/BUG-049-separate-process-g040-prefix/
BUG049_ALLOWED_DIFF_STAT_BEGIN
 bubbles/release-manifest.json                      |  20 +-
 bubbles/scripts/state-transition-guard-selftest.sh | 538 ++++++++++++++++++++-
 bubbles/scripts/state-transition-guard.sh          | 297 +++++++++++-
 3 files changed, 831 insertions(+), 24 deletions(-)
BUG049_ALLOWED_DIFF_NAMES_BEGIN
bubbles/release-manifest.json
bubbles/scripts/state-transition-guard-selftest.sh
bubbles/scripts/state-transition-guard.sh
BUG049_SIBLING_PACKET_STATUS_BEGIN
?? bugs/BUG-047-reasoned-skip-phase-accounting/
?? bugs/BUG-048-test-plan-owner-label-path/
?? bugs/BUG-050-transition-local-receipt-admission/
?? bugs/BUG-051-yaml-validator-downstream-root/
?? bugs/BUG-052-plan-scope-progress-precedence/
BUG049_BOUNDARY_INVENTORY_END
```

The shared script totals are cumulative for the serialized scenario checkout;
this node edited the G040 pattern, its BUG-049 selftest matrix, this packet's
implementation-owned fields, and the generated release manifest only.

## Validation Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.validate
**Claim Source:** not-run

Validate-owned certification has not run.

## Audit Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.audit
**Claim Source:** not-run

Audit has not run.

## Chaos Evidence

**Executed:** NO
**Command:** not run
**Phase Agent:** bubbles.chaos
**Claim Source:** not-run

Chaos validation is not part of filing and has not run.
