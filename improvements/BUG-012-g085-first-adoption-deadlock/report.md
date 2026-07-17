# Report: BUG-012 G085 First-Adoption Deadlock

Related artifacts: [scopes.md](scopes.md), [uservalidation.md](uservalidation.md)

## Summary

BUG-012's implementation-owned G085 guard, selftest, persistent regression,
delegated guidance, registry/docs, and release inputs have been reconciled in the
canonical Bubbles checkout. This resumed invocation freshly passed all nine
planned test rows, packet lint/freshness/traceability, regression quality,
portability, full framework validation, and release readiness. Terminal
promotion remains blocked on planning-owned scope-shape reconciliation, seven
independent specialist phases, and unavailable G090 session input. The packet
and scope remain `in_progress`; certification, Done status, downstream
propagation, commit, and release are not claimed.

## Decision Record

The active design rejects mutable adoption markers and classifies first adoption from current numbered state plus complete locally reachable Git history. A first-adoption pass requires zero current done states, zero historical numbered done blobs, and complete exact-root, non-shallow, non-partial traversal. Unknown history is an integrity failure, never evidence of absence.

## Completion Statement

Status remains `in_progress`. Implementation-owned execution evidence and DoD
reconciliation are complete. The next owner is `bubbles.plan` for the five
planning-shape findings emitted by the terminal transition guard; independent
test and certification phases follow that reconciliation. No propagation
result, downstream transition result, audit verdict, certification field, scope
Done status, or packet Done status is claimed.

### Code Diff Evidence

The implementation-bearing BUG-012 surface is confined to the production guard, its exhaustive selftest, the persistent G085 regression, delegated Check 26 guidance, direct G085 registry/generated-registry descriptions, direct operator/convergence docs, changelog/bug-log metadata, and the canonical release manifest. The worktree also contains unrelated dirty files; no reset, commit, push, downstream managed-copy edit, or unrelated cleanup was performed.

## Scenario Contract Evidence

| Scenario | Persistent regression | Focused classifier check | Evidence destination |
| --- | --- | --- | --- |
| `SCN-BUG-012-001` | `tests/regression/test_04_framework_dogfooding.sh` | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `report.md#test-evidence` |
| `SCN-BUG-012-002` | `tests/regression/test_04_framework_dogfooding.sh` | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `report.md#test-evidence` |
| `SCN-BUG-012-003` | `tests/regression/test_04_framework_dogfooding.sh` | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `report.md#test-evidence` |
| `SCN-BUG-012-004` | `tests/regression/test_04_framework_dogfooding.sh` | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `report.md#test-evidence` |

## Bug Reproduction - Before Fix

**Phase:** discovery
**Command:** `cd /Users/pkirsanov/Projects/research-lab && set +e; echo '=== BUG-012 BEFORE FIX: Research Lab G085 ==='; bash ../bubbles/bubbles/scripts/framework-dogfood-guard.sh --repo-root .; exit_code=$?; set -e; echo "guard-exit=$exit_code"; echo '=== REPOSITORY HISTORY QUALIFIERS ==='; echo "shallow=$(git rev-parse --is-shallow-repository)"; history_count=$(git log --all --format='%H' -- 'specs/*/state.json' | wc -l | tr -d ' '); echo "reachable-state-history-commits=$history_count"; echo '=== END BUG-012 BEFORE FIX ==='`
**Exit Code:** 0 for the evidence wrapper; the guard's captured exit is `1`
**Claim Source:** executed

<!-- markdownlint-disable MD010 -->
```text
=== BUG-012 BEFORE FIX: Research Lab G085 ===
G085 framework_dogfood_evidence_gate violation
	repositoryClass:    downstream-or-fixture
	specsDir:           ./specs
	numbered-feature state.json files found: 2
	count with status==done:                 0
	requirement:        downstream/fixture dogfood evidence needs at least one specs/NNN-*/state.json with top-level "status": "done"
	recipe:             docs/recipes/framework-dogfood.md
	remediation:        certify at least one downstream or fixture spec to done, or run against the Bubbles source repo where persistent specs/ is forbidden
	candidate specs currently in-flight:
		- ./specs/001-causal-rotation-intelligence/state.json  (status=not_started)
		- ./specs/002-distributed-tool-briefs-and-history/state.json  (status=not_started)
guard-exit=1
=== REPOSITORY HISTORY QUALIFIERS ===
shallow=false
reachable-state-history-commits=0
=== END BUG-012 BEFORE FIX ===
```
<!-- markdownlint-restore MD010 -->

## Gaps Phase Audit - 2026-07-14

This diagnostic pass audited only BUG-012 Scope 1 against its current
`spec.md`, `design.md`, `scopes.md`, implementation, test surfaces, and
execution report. It changed no planning-owned requirement, design, scope,
scenario, Test Plan, DoD, implementation, test, generated, release,
downstream-installed, or certification surface.

### Gap Classification

| Finding | Classification | Current disposition |
| --- | --- | --- |
| `BUG012-SIMPLIFY-003` | The report contains no live version promise. The three matches are literal verdict lines copied from `stale-deferral-lint-selftest.sh` cases 4-6. The live scanner already excludes its own fixture but scans the same fixture text after it is preserved inside fenced execution evidence. This is a lint false positive caused by a missing canonical raw-evidence exclusion or escaping contract. | OPEN. Scope 1 does not authorize `bubbles/scripts/stale-deferral-lint.sh` or its selftest. The Change Boundary requires planning before those files can change, so the immediate owner is `bubbles.plan`. A valid plan must retain scanner coverage for live Markdown narrative while exempting only provenance-preserving raw evidence and must add positive and adversarial scanner cases. |
| `BUG012-SIMPLIFY-004` | The 33 hard-tab diagnostics were literal command output, not prose formatting. The surrounding early simplify block lacked the MD010 metadata convention already used elsewhere in this report. | ADDRESSED. Added only `markdownlint-disable MD010` / `markdownlint-restore MD010` around the two raw fences. All 33 tabbed lines remain byte-literal; marker order passes and VS Code now reports no errors. |

No missing requirement, Gherkin scenario, Test Plan row, DoD item, production
behavior, persistent regression, or undocumented G085 consumer was found.
Traceability remains four scenarios, ten Test Plan rows, four scenario-to-row
mappings, and zero warnings. The focused classifier and persistent regression
remain substantive production-guard tests rather than proxies.

### Stale-Reference Contract Discriminator Evidence

**Phase:** gaps
**Executed:** YES (current invocation)
**Command:** execute `stale-deferral-lint.sh` in memory; count its BUG-012
diagnostics; classify report matches with a fenced-block-aware `awk` pass; and
inspect the scanner's Markdown, selftest, report, and fence rules
**Exit Code:** 0 for the discriminator; embedded live lint exit `1`
**Claim Source:** executed
**Output:**

```text
BUG012_GAPS_STALE_CONTRACT_DISCRIMINATOR_BEGIN
LINT_EXIT=1
LINT_ERROR_DIAGNOSTICS=3
BUG012_REPORT_DIAGNOSTICS=3
REPORT_TRIGGER_TOTAL=4
REPORT_TRIGGER_IN_FENCES=4
REPORT_TRIGGER_OUTSIDE_FENCES=0
SELFTEST_VERDICT_TRIGGER_LINES=4
LAPSED_FIXTURE_LINES=3
FUTURE_FIXTURE_LINES=1
MARKDOWN_SCAN_RULES=1
SELFTEST_PATH_EXCLUSIONS=1
REPORT_PATH_EXCLUSIONS=0
FENCED_BLOCK_RULES=0
RAW_EVIDENCE_CONTRACT_GAP=PASS
BUG012_GAPS_STALE_CONTRACT_DISCRIMINATOR_END
```

**Result:** PASS. Every matching report line is a fenced selftest verdict; no
live report narrative matches. The scanner excludes its own fixture path while
having no equivalent report or fenced-evidence rule. Therefore
`BUG012-SIMPLIFY-003` is not a legitimate BUG-012 report-content defect. It is
a false positive against immutable execution evidence and exposes a missing
canonical raw-evidence exclusion or escaping contract. Altering the historical
lines is prohibited; the scanner contract requires a planned source/test
change outside Scope 1's current Change Boundary.

### MD010 Provenance-Preserving Repair Evidence

**Phase:** gaps
**Executed:** YES (current invocation)
**Command:** targeted `awk` marker-order and literal-tab audit over the early simplify evidence block; VS Code `get_errors` before and after the marker-only edit
**Exit Code:** 0 for the marker audit; VS Code final result `No errors found`
**Claim Source:** executed
**Output:**

```text
BUG012_GAPS_MD010_MARKER_CHECK_BEGIN
TARGET_HEADING_LINE=103
DISABLE_LINE=105
RESTORE_LINE=155
FIRST_LITERAL_TAB_LINE=109
LAST_LITERAL_TAB_LINE=151
LITERAL_TAB_LINES=33
MARKER_ORDER=PASS
RAW_TAB_BYTES_PRESERVED=PASS
BUG012_GAPS_MD010_MARKER_CHECK_END
VS_CODE_DIAGNOSTICS_AFTER=No errors found
```

**Result:** PASS. The repair changes lint metadata only; the literal tabbed
terminal output remains intact.

### Focused Behavior And Regression Evidence

**Phase:** gaps
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** `bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 2:** 0
**Command 3:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 3:** 0
**Claim Source:** executed
**Output (verdict windows from the retained full transcript):**

<!-- markdownlint-disable MD010 -->

```text
--- S15: non-numbered and nested done evidence are ignored ---
	✅ PASS: S15 ignored non-numbered and nested done (exit=0)
	✅ PASS: S15 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	✅ PASS: S15 stdout contains 'historicalDone=0'
--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
	✅ PASS: S16 current-done guidance
	✅ PASS: S16 genuine first-adoption guidance
	✅ PASS: S16 stale single-path guidance is absent
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
FOCUSED_EXIT=0
=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
PERSISTENT_REGRESSION_EXIT=0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
REGRESSION_QUALITY_EXIT=0
BUG012_GAPS_FOCUSED_VALIDATION_END
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS. All G085 acceptance and fail-closed branches remain green,
including the byte-identical-current-state adversarial pair and effective
shallow-history refusal.

### Packet And Broad Validation Evidence

**Phase:** gaps
**Executed:** YES (current invocation)
**Commands:** artifact lint; artifact freshness guard; traceability guard;
implementation reality scan; canonical `bash bubbles/scripts/cli.sh framework-validate`
**Exit Codes:** 0, 0, 0, 0, 1
**Claim Source:** executed
**Output (packet summaries and canonical terminal window):**

<!-- markdownlint-disable MD010 -->

```text
Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
RESULT: PASS (0 failures, 0 warnings)
ARTIFACT_FRESHNESS_EXIT=0
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
TRACEABILITY_EXIT=0
Files scanned:  6
Violations:     0
Warnings:       1
REALITY_SCAN_EXIT=0
stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
FAIL: Stale-deferral lint (live)
Framework validation failed with 1 failing check(s).
Failed checks:
	- Stale-deferral lint (live)
BUG012_GAPS_FRAMEWORK_VALIDATE_EXIT=1
BUG012_GAPS_FRAMEWORK_VALIDATE_END
```

<!-- markdownlint-restore MD010 -->

**Result:** Packet structure, freshness, traceability, and implementation
reality pass. Canonical framework validation remains red on exactly one check,
the foreign-owned scanner contract above. The reality scan's single existing
warning is the planning-owned design fallback because `scopes.md` yields no
implementation paths; it is preserved as `BUG012-VAL-REALITY-DISCOVERY`.

### Execution State, Preservation, And G090 Evidence

**Phase:** gaps
**Executed:** YES (current invocation, after report/state reconciliation)
**Commands:** structured `state.json` assertions; certification-object SHA-256;
concurrent BUG-013 SHA-256 set; `retro-convergence-health.sh` for BUG-012
**Exit Codes:** 0 for state/preservation; 2 for the missing G090 input
**Claim Source:** executed
**Output:**

```text
BUG012_GAPS_STATE_VALIDATION_BEGIN
true
STATE_ASSERTIONS_EXIT=0
CERTIFICATION_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
CERTIFICATION_PRESERVATION=PASS
29789e09f019172f1677e98dec6fe5afd028c9395b945e48194434d5b56fc55d  bubbles/scripts/implementation-reality-scan.sh
531f16b782a55c61dbb1dd3a8da8ecea150533af360e7579e2598dc7639b3d27  bubbles/scripts/implementation-reality-scan-selftest.sh
77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3  bubbles/scripts/guards/sensitive-client-storage-scan.py
4aa18e2e4d8cca91b017661f5bbeaadc521443a250fb0864a33d5304e6840ce2  tests/regression/test_24_g028_sensitive_client_storage.sh
BUG012_GAPS_STATE_VALIDATION_END
BUG012_GAPS_G090_DIAGNOSTIC_BEGIN
retro-convergence-health: session JSON not found: /Users/pkirsanov/Projects/bubbles/.specify/memory/bubbles.session.json
BUG012_GAPS_G090_EXIT=2
BUG012_GAPS_G090_DIAGNOSTIC_END
```

**Result:** PASS for the intended nonterminal route and preservation checks;
G090 remains honestly blocked. The execution cursor points to `bubbles.gaps`
and `bubbles.plan`, while `completedPhaseClaims` remains exactly
`implement,test,regression,simplify`. No certification or concurrent BUG-013
byte changed.

### Lifecycle And Finding Accounting

| Finding | Status after gaps | Required owner |
| --- | --- | --- |
| `BUG012-SIMPLIFY-003` | OPEN: scanner contract expansion required; canonical framework validation exits `1` | `bubbles.plan` immediately, then the owners authorized by the expanded plan |
| `BUG012-SIMPLIFY-004` | ADDRESSED: MD010 metadata now encloses all 33 literal tab lines; diagnostics clean | `bubbles.gaps` |
| `BUG012-VAL-MODE-GAPS` | OPEN: diagnostic execution is recorded, but phase completion is not claimed while its foreign-owned blocker remains | `bubbles.plan` |
| `BUG012-VAL-MODE-HARDEN` | OPEN and not executed | `bubbles.harden` after gaps-owned blocker closure |
| `BUG012-VAL-G022-STABILIZE` | OPEN and not executed | `bubbles.stabilize` in resolved order |
| `BUG012-VAL-MODE-DEVOPS` | OPEN and not executed | `bubbles.devops` in resolved order |
| `BUG012-VAL-G022-SECURITY` | OPEN and not executed | `bubbles.security` in resolved order |
| `BUG012-VAL-G022-VALIDATE` | OPEN and not executed on the current lifecycle | `bubbles.validate` after all prerequisite owners and G090 input |
| `BUG012-VAL-G022-AUDIT` | OPEN and not executed on the current lifecycle | `bubbles.audit` after validation passes |
| `BUG012-VAL-MODE-FINALIZE` | OPEN and prohibited before successful audit | authorized top-level runner |
| `BUG012-VAL-G027` | OPEN: scope and certification remain `in_progress` with no completed scope | `bubbles.validate` only after all prerequisites pass |
| `BUG012-VAL-G090` | OPEN: current diagnostic still exits `2` because `.specify/memory/bubbles.session.json` is absent | authorized top-level session owner |
| `BUG012-VAL-EVIDENCE-SIGNALS` | PRESERVED warning | `bubbles.audit` |
| `BUG012-VAL-REALITY-DISCOVERY` | PRESERVED warning | `bubbles.plan` |
| `BUG012-VAL-SCOPE-PROGRESS` | PRESERVED warning; `certification.scopeProgress` remains untouched | `bubbles.validate` |

The resolved persisted workflow order remains `gaps -> harden -> stabilize ->
devops -> security -> validate -> audit -> finalize`. The foreign-owned scanner
gap interrupts that sequence before harden: Scope 1 explicitly requires any
Change Boundary expansion to return to planning. Therefore the actual immediate
owner is `bubbles.plan`, not `bubbles.harden`. The packet remains nonterminal,
and no Done, certification, release, propagation, or downstream-upgrade claim is
made.

### Additional Fail-Closed Current-State Finding

`BUG012-GAPS-STATUS-001` is a newly reproduced contract gap. The production
guard treats any parseable current JSON object as a valid non-done state. A
numbered current `state.json` with no top-level `status`, and one with an
unsupported top-level status, both receive `G085-FIRST-ADOPTION` when local Git
history is otherwise complete and contains no done blob.

This is **PARTIAL implementation plus UNTESTED behavior**, not a documentation
preference. The active contract requires valid current numbered states and says
missing, malformed, contradictory, incomplete, or indeterminate lifecycle
evidence cannot grant first adoption. The exhaustive selftest covers invalid
JSON but has no missing-status or unsupported-status adversary, so its `71/71`
result cannot falsify this bypass.

**Phase:** gaps
**Executed:** YES (current invocation)
**Command:** `bash /tmp/bubbles-bug012-gaps-status-probe.sh; probe_exit=$?; rm -f /tmp/bubbles-bug012-gaps-status-probe.sh; printf 'PROBE_EXIT=%s\n' "$probe_exit"; exit "$probe_exit"`
**Exit Code:** 0 for the reproducer; both embedded production-guard calls exited `0`
**Claim Source:** executed
**Output:**

```text
BUG012_GAPS_STATUS_VALIDATION_BEGIN
EXPECTED_CONTRACT=missing-or-unsupported-current-status-must-not-pass-first-adoption
CASE=missing
PASS Gate G085 (framework_dogfood_evidence_gate) decisionCode=G085-FIRST-ADOPTION currentDone=0 historicalDone=0 historyIntegrity=complete totalSpecs=1
CASE_EXIT=0
CONTRACT_GAP_CONFIRMED=missing-status-accepted
CASE=unsupported
PASS Gate G085 (framework_dogfood_evidence_gate) decisionCode=G085-FIRST-ADOPTION currentDone=0 historicalDone=0 historyIntegrity=complete totalSpecs=1
CASE_EXIT=0
CONTRACT_GAP_CONFIRMED=unsupported-status-accepted
FIXTURE_CLEANUP=OWNED_BY_TRAP
BUG012_GAPS_STATUS_VALIDATION_END
PROBE_EXIT=0
```

**Result:** FAIL against the finalized fail-closed contract. Both invalid
current lifecycle shapes receive the success decision reserved for proven first
adoption.

| Finding | Status after gaps | Required owner |
| --- | --- | --- |
| `BUG012-GAPS-STATUS-001` | OPEN: missing or unsupported current lifecycle status is accepted as proven first adoption | `bubbles.plan` first, to add the exact scenario/Test Plan/DoD contract and expand the Change Boundary; then `bubbles.implement` and `bubbles.test` |

No inline repair is permitted in this diagnostic phase. The required change
touches the production guard and both test surfaces and requires planning-owned
scenario/Test Plan/DoD updates. The immediate next owner remains
`bubbles.plan`; `bubbles.harden` is not yet eligible.

## Simplification Phase Review - 2026-07-14

This phase reviewed only the completed BUG-012 implementation and regression
surface. The required reuse, quality, and efficiency dimensions were evaluated
as separate read-only passes over the same changed files. This session exposes
no child-agent dispatch tool, so the three passes share this invocation's
provenance and are not represented as independent agents.

### Consolidated Findings

| Review pass | Findings | Disposition |
| --- | ---: | --- |
| Code reuse | 0 | The history classifier has one production implementation. The exhaustive selftest and minimal persistent regression have deliberately different responsibilities, so extracting their fixture helpers would increase coupling rather than remove production duplication. |
| Code quality | 0 | Stable decision and failure branches remain explicit, no dead code or deletion candidate was found, and the error-specific control flow is required to preserve the closed `E085-*` diagnostic contract. |
| Efficiency | 0 actionable | Narrower tree listing and batched blob reads were considered, but no measured bottleneck or material behavior-preserving gain justified changing the fail-closed traversal shape. A cache or reduced-history shortcut would weaken the design and was rejected. |

No file was deleted. This simplify invocation authored no production, test,
registry, documentation, generated, or release-manifest edit; its authored
source/test delta is `0` / `0`. During closeout, a concurrent writer changed
`tests/regression/test_04_framework_dogfooding.sh`. That change is preserved,
not attributed to this invocation, and validated separately below.

### No-Change Decision And Focused Evidence

**Phase:** simplify
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** `bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 2:** 0
**Claim Source:** executed
**Output (literal decision and verdict windows):**

<!-- markdownlint-disable MD010 -->

```text
--- S7: done state changed to in_progress remains established ---
	PASS: S7 changed historical done (exit=1)
	PASS: S7 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	PASS: S7 stderr contains 'historyPath=specs/001-foo/state.json'
	PASS: S7 stderr contains 'historyCommit='
	PASS: S7 blob privacy stderr omits 'G085_PRIVATE_BLOB_PAYLOAD'
--- S11: effective file:// shallow clone fails closed ---
	PASS: S11 fixture is genuinely shallow
	PASS: S11 shallow history (exit=2)
	PASS: S11 stderr contains 'failureCode=E085-HISTORY-SHALLOW'
	PASS: S11 stderr contains 'historyIntegrity=shallow'
--- S12a: extensions.partialClone metadata fails closed as partial history ---
	PASS: S12a extensions.partialClone metadata (exit=2)
	PASS: S12a stderr contains 'failureCode=E085-HISTORY-PARTIAL'
--- S12b: remote.promisor metadata fails closed as partial history ---
	PASS: S12b remote.promisor metadata (exit=2)
	PASS: S12b stderr contains 'failureCode=E085-HISTORY-PARTIAL'
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
framework-dogfood-guard-selftest: PASSED
```

```text
=== Regression: SCOPE-4 (Gate G085 - framework_dogfood_evidence_gate) ===
	PASS: S1 source repo without specs/ - PASS (exit=0)
	PASS: S2 source repo with specs/ - VIOLATION (exit=1)
	PASS: S3 exactly one downstream done numbered spec - PASS (exit=0)
	PASS: S3 current-done decision code
	PASS: S4 genuine first adoption - PASS (exit=0)
	PASS: S4 first-adoption decision code
	PASS: S4 proves complete history
	PASS: S5 adversarial repositories have identical current states
	PASS: S5 reachable historical done - VIOLATION (exit=1)
	PASS: S5 historical-done failure code
	PASS: S5 historical state path
	PASS: S6 shallow fixture setup is effective
	PASS: S6 shallow history - INTEGRITY FAILURE (exit=2)
	PASS: S6 shallow-history failure code
=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0
test_04_framework_dogfooding: REGRESSION PASSED
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS - the no-source-edit decision retains the complete `71/71`
classifier matrix and `16/16` persistent regression. In particular, changed,
deleted, and alternate-ref done history remains established, while shallow,
partial, malformed, and failed history remains unable to receive first-adoption
success.

### Protected-Byte Baseline And Route

**Phase:** simplify
**Executed:** YES (current invocation)
**Command:** SHA-256 fingerprinting of the five BUG-012 executable/test
surfaces, four concurrent BUG-013 surfaces, and the BUG-012 certification
object, followed by scoped `git diff --numstat`.
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** This is the pre-closeout baseline, not a claim that every
worktree byte remained static. The production guard, exhaustive selftest,
delegated guidance, state-transition wrapper, BUG-013 surfaces, and
certification object retained these hashes. The persistent regression later
changed concurrently from the baseline hash shown here; this simplify
invocation authored only evidence and execution metadata.
**Output:**

```text
BUG012_SIMPLIFY_BASELINE_BEGIN
BUG-012 protected executable hashes
2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4  bubbles/scripts/framework-dogfood-guard.sh
a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d  bubbles/scripts/framework-dogfood-guard-selftest.sh
d587280493e6dc2719c805d1c2a28f407b2c48041542641027858e6994477c84  bubbles/scripts/guards/tail-delegated-gates.sh
1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b  bubbles/scripts/state-transition-guard.sh
e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6  tests/regression/test_04_framework_dogfooding.sh
BUG-013 protected concurrent hashes
29789e09f019172f1677e98dec6fe5afd028c9395b945e48194434d5b56fc55d  bubbles/scripts/implementation-reality-scan.sh
531f16b782a55c61dbb1dd3a8da8ecea150533af360e7579e2598dc7639b3d27  bubbles/scripts/implementation-reality-scan-selftest.sh
77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3  bubbles/scripts/guards/sensitive-client-storage-scan.py
4aa18e2e4d8cca91b017661f5bbeaadc521443a250fb0864a33d5304e6840ce2  tests/regression/test_24_g028_sensitive_client_storage.sh
BUG-012 certification fingerprint
0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560  -
BUG-012 scoped numstat
363 28 bubbles/scripts/framework-dogfood-guard-selftest.sh
222 44 bubbles/scripts/framework-dogfood-guard.sh
2 1 bubbles/scripts/guards/tail-delegated-gates.sh
5 4 bubbles/scripts/state-transition-guard.sh
118 25 tests/regression/test_04_framework_dogfooding.sh
BUG012_SIMPLIFY_BASELINE_END
```

### Concurrent Regression-Harness Reconciliation

After the baseline above and before closeout, another writer replaced the
space-delimited `ALL_WORKSPACES` cleanup list in
`tests/regression/test_04_framework_dogfooding.sh` with one quoted parent
`WORKSPACE` and child fixture directories under it. Simplify did not author or
revert that edit. The current file hash is
`e4b4b3417ab683d451ab39fe87537d28abe8709d8f7a731cb306402c7c4bbf11`,
changed from baseline
`e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6`.

**Phase:** simplify
**Executed:** YES (current invocation, after concurrent change)
**Commands:** `git diff --check -- tests/regression/test_04_framework_dogfooding.sh`; `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`; `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`; `bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output (literal verdict signals):**

```text
e4b4b3417ab683d451ab39fe87537d28abe8709d8f7a731cb306402c7c4bbf11  tests/regression/test_04_framework_dogfooding.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files with adversarial signals: 1
Total assertions: 71
Passed:           71
Failed:           0
framework-dogfood-guard-selftest: PASSED
Total assertions: 16
Passed:           16
Failed:           0
test_04_framework_dogfooding: REGRESSION PASSED
```

**Result:** PASS - current-tree behavior is preserved after the concurrent
cleanup. The production classifier and exhaustive selftest remain unchanged;
the persistent regression still exercises the same 16 assertions and retains
an adversarial signal with no quality finding. The scoped `git diff --check`
also exited `0`; its successful empty output is recorded by that exit code.

| Finding | Simplify disposition | Next owner |
| --- | --- | --- |
| `BUG012-SIMPLIFY-NO-CHANGE` | Addressed: all three review dimensions found zero material production simplification; this invocation authored no source/test edit. A concurrent persistent-regression cleanup was preserved and current-tree checks remain green. | `bubbles.gaps` |

The packet and scope remain `in_progress`; simplify does not certify, publish,
propagate, upgrade downstream copies, or alter `certification.*`. The resolved
`bugfix-fastlane` phase immediately following `simplify` is `gaps`.

### Cleanup Authoring Attribution And Broad-Suite Route

This addendum records a separate simplify invocation that authored the
persistent-regression cleanup described above while the preceding simplify
review was running concurrently. It preserves that review's no-edit statement
as truthful for its own invocation. This invocation changed only
`tests/regression/test_04_framework_dogfooding.sh`: it replaced the
space-delimited cleanup list, whose mutations were lost inside command
substitutions, with one quoted parent workspace containing every child fixture.
The patch itself removed nine lines and added two. No production guard,
exhaustive selftest, consumer, registry, documentation, generated artifact,
downstream installation, planning artifact, scope status, or certification
field was changed.

#### Three-Lens Finding

| Review pass | Finding | Disposition |
| --- | --- | --- |
| Code reuse | The persistent regression maintained a separate cleanup registry even though the focused selftest already demonstrated one-parent-workspace ownership. | Reused the one-parent-workspace pattern locally without coupling the two test files. |
| Code quality | `stage_repo` and `stage_source_repo` were called through command substitution, so their `ALL_WORKSPACES` mutations occurred in subshells and never reached the EXIT trap. | Replaced hidden side effects with explicit child creation beneath one quoted parent. |
| Efficiency | Passing regression runs left disposable Git repositories under the macOS user temp root. | The trap now removes one parent recursively; the post-edit inventory proves no new top-level G085 regression workspace remains. |

No file deletion was proposed or performed. The production guard's explicit
failure branches were retained because each preserves a distinct fail-closed
code, integrity class, and producer-status check; extracting those branches
would add indirection without reducing behavior or risk.

#### Pre-Edit Discriminator

**Phase:** simplify
**Executed:** YES (current invocation, before edit)
**Command:** run the persistent regression, then inspect the actual macOS user
temporary root for newly created `bubbles-g085-regression-*` and
`bubbles-g085-source-*` directories.
**Exit Code:** 0 for the regression and the discriminating inventory command
**Claim Source:** interpreted
**Interpretation:** The regression's `16/16` behavior assertions passed, while
the immediately following Darwin-root inventory found the fixture directories
that its EXIT trap was intended to remove. This separated behavior correctness
from cleanup ownership and justified the narrow harness-only edit.
**Output (literal inventory window):**

```text
BUG012_SIMPLIFY_TEMP_ROOT_CHECK_BEGIN
TEMP_ROOT=/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/
FRESH_G085_TEMP_DIRECTORIES_BEGIN
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.swOjt0xFMy
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.OKuyxcBIZn
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.eAi0dGbGYZ
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.aqTy7nQgTi
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.0PTcUmmvKp
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-source-XXXXXXXX.b1BOclItck
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-source-XXXXXXXX.m0ckJUakAE
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.Vprsk4JytF
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.5r5zAya6vP
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-source-XXXXXXXX.kt9wrAhd22
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-source-XXXXXXXX.TmLZLqnfOe
/var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-g085-regression-XXXXXXXX.4wq7d9vteY
FRESH_G085_TEMP_DIRECTORIES_END
BUG012_SIMPLIFY_TEMP_ROOT_CHECK_END
```

The exact listed directories were removed after the test fix; no wildcard or
repository path was deleted.

#### Immediate And Focused Post-Edit Validation

**Phase:** simplify
**Executed:** YES (current invocation, immediately after edit)
**Commands:** `bash tests/regression/test_04_framework_dogfooding.sh` with a
before/after top-level temp inventory; focused G085 selftest; bugfix
regression-quality guard; macOS portability selftest; Bash syntax check; VS Code
diagnostics.
**Exit Codes:** 0 for every focused command; zero editor diagnostics
**Claim Source:** executed
**Output (literal regression and cleanup verdict):**

```text
BUG012_SIMPLIFY_FOCUSED_VALIDATION_BEGIN
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===
  ✅ PASS: S1 source repo without specs/ — PASS (exit=0)
  ✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
  ✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
  ✅ PASS: S3 current-done decision code
  ✅ PASS: S4 genuine first adoption — PASS (exit=0)
  ✅ PASS: S4 first-adoption decision code
  ✅ PASS: S4 proves complete history
  ✅ PASS: S5 adversarial repositories have identical current states
  ✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
  ✅ PASS: S5 historical-done failure code
  ✅ PASS: S5 historical state path
  ✅ PASS: S6 shallow fixture setup is effective
  ✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
  ✅ PASS: S6 shallow-history failure code
=== Regression verdict ===
  Total assertions: 16
  Passed:           16
  Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
REGRESSION_EXIT=0
PASS: no new top-level G085 regression workspace remains
BUG012_SIMPLIFY_FOCUSED_VALIDATION_END
```

```text
=== Selftest verdict ===
  Total assertions: 71
  Passed:           71
  Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
PASS: guard parses (bash -n)
PASS: guard is self-portable (guard scans its own source -> exit 0)
[selftest macos-portability-guard] OK — all assertions passed.
No errors found
```

#### Broad Validation And Finding Accounting

The first broad run overlapped a separate framework validation and observed an
observability twin workspace collision. An isolated rerun passed `12/12`, so no
observability source edit was justified. The final canonical broad rerun then
passed that selftest and every other check except the live stale-reference lint.
That lint now scans prior regression-owned raw evidence in this report. Rewriting
executed evidence would violate evidence provenance, and changing the lint is
outside Scope 1's Change Boundary, so the complete finding is routed to the next
mode-ordered diagnostic owner.

**Phase:** simplify
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 1
**Claim Source:** executed
**Output (literal terminal verdict window; full 48 KB transcript retained by
the current VS Code terminal execution):**

```text
observability-check-selftest: 12 passed, 0 failed
observability-check selftest passed.
PASS: Observability check twin selftest (wired fixture)
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
FAIL: Stale-deferral lint (live)
Framework validation failed with 1 failing check(s).
Failed checks:
  - Stale-deferral lint (live)
FRAMEWORK_VALIDATE_EXIT=1
EXPECTED_EXIT=0
ACTUAL_RESULT=BLOCKED
FOCUSED_G085=71/71
PERSISTENT_G085=16/16
REGRESSION_QUALITY=0 violations, 0 warnings
ISOLATED_OBSERVABILITY_TWIN=12/12
DURABLE_BLOCKER=live stale-reference lint over prior BUG-012 evidence
SIMPLIFY_SOURCE_CHECK=passed
CERTIFICATION_MUTATION=none
BUG012_SIMPLIFY_FRAMEWORK_END
```

| Finding | Disposition | Next owner |
| --- | --- | --- |
| `BUG012-SIMPLIFY-001` | Addressed: one quoted parent workspace now owns all persistent-regression fixtures; `16/16` assertions pass and no new top-level regression workspace remains. | `bubbles.simplify` |
| `BUG012-SIMPLIFY-002` | Addressed without code change: the concurrent observability collision was transient; the isolated twin selftest passes `12/12` and the final broad run passes that check. | `bubbles.simplify` |
| `BUG012-SIMPLIFY-003` | Unresolved and routed: canonical framework validation exits `1` only because the live stale-reference lint scans prior regression-owned raw evidence. Evidence cannot be rewritten, and the lint is outside this scope boundary. | `bubbles.gaps` |
| `BUG012-SIMPLIFY-004` | Unresolved and routed: VS Code reports MD010 on hard tabs in the earlier concurrent simplify transcript. Canonical artifact lint passes, and the lines are raw evidence that this invocation did not rewrite. | `bubbles.gaps` |

#### Packet And State Closeout

**Phase:** simplify
**Executed:** YES (current invocation, after report/state reconciliation)
**Commands:** artifact lint; artifact freshness guard; traceability guard;
structured JSON assertions for status, completed phase, next owner, last history
entry, and certification fingerprint; scoped `git diff --check`.
**Exit Codes:** 0 for every canonical packet/state command
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
RESULT: PASSED (0 warnings)
BUG012_SIMPLIFY_STATE_ASSERTIONS_BEGIN
STATUS=in_progress
CERTIFICATION_STATUS=in_progress
COMPLETED_PHASES=implement,test,regression,simplify
NEXT_OWNER=bubbles.gaps
BLOCKER_OWNER=bubbles.gaps
LAST_AGENT=bubbles.simplify
LAST_OUTCOME=route_required
CERTIFICATION_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
EXPECTED_CERTIFICATION_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
STATE_ASSERTIONS=PASS
CERTIFICATION_PRESERVATION=PASS
BUG012_SIMPLIFY_STATE_ASSERTIONS_END
BUG012_SIMPLIFY_DIFF_CHECK=PASS
```

Simplify is execution-complete but not terminal: the packet and scope remain
`in_progress`, `certification.*` remains byte-identical at
`0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560`,
and later lifecycle phases remain unresolved. The persisted mode resolves to
`gaps -> harden -> stabilize -> devops -> security -> validate -> audit ->
finalize`; the immediate next owner is `bubbles.gaps`, carrying
`BUG012-SIMPLIFY-003` and `BUG012-SIMPLIFY-004` without weakening or dropping
either finding.

## Regression Phase Verification - 2026-07-14

This diagnostic phase ran after the finalized independent-test handoff. It
re-executed the BUG-012 persistent production-guard regression, the exhaustive
G085 classifier matrix, the bugfix regression-quality gate, the G044 baseline
and conflict scan, and the canonical full framework suite. It did not edit
source, tests, planning artifacts, release inputs, downstream managed copies,
scope status, or `certification.*`.

<!-- markdownlint-disable MD010 -->

### Regression Baseline Comparison

| Signal | Independent-test baseline | Regression rerun | Delta | Status |
| --- | --- | --- | --- | --- |
| Focused G085 classifier | 71 passed, 0 failed | 71 passed, 0 failed | 0 | Stable |
| Persistent G085 regression | 16 passed, 0 failed | 16 passed, 0 failed | 0 | Stable |
| Bugfix regression quality | 0 violations, 0 warnings | 0 violations, 0 warnings | 0 | Stable |
| Canonical source behavior | clean source passes; source with persistent `specs/` refuses | same two outcomes | 0 | Stable |
| Existing downstream current-done behavior | `G085-CURRENT-DONE` passes | `G085-CURRENT-DONE` passes | 0 | Stable |
| Full framework validation | passed | passed | 0 terminal-verdict regressions | Stable |

The canonical framework command does not emit one aggregate test count, so the
broad comparison uses its terminal verdict and named check outcomes rather than
inventing a total. Scenario-contract coverage is evaluated separately by the
canonical traceability guard during phase closeout.

### Focused And Persistent G085 Evidence

**Phase:** regression
**Executed:** YES (current invocation)
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG012_REGRESSION_FOCUSED_BEGIN' && set +e; bash bubbles/scripts/framework-dogfood-guard-selftest.sh; exit_code=$?; set -e; printf 'BUG012_REGRESSION_FOCUSED_EXIT=%s\n' "$exit_code"; printf '%s\n' 'BUG012_REGRESSION_FOCUSED_END'; exit "$exit_code"`
**Exit Code 1:** 0
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG012_REGRESSION_PERSISTENT_BEGIN' && set +e; bash tests/regression/test_04_framework_dogfooding.sh; exit_code=$?; set -e; printf 'BUG012_REGRESSION_PERSISTENT_EXIT=%s\n' "$exit_code"; printf '%s\n' 'BUG012_REGRESSION_PERSISTENT_END'; exit "$exit_code"`
**Exit Code 2:** 0
**Claim Source:** executed
**Output (literal decision and verdict windows):**

```text
--- S0: source repo has no specs/ and evidence surfaces exist ---
	PASS: S0 source repo without specs/ (exit=0)
	PASS: S0 stdout contains 'PASS Gate G085'
	PASS: S0 stdout contains 'source repo has no persistent specs/'
--- S1: source repo contains specs/ ---
	PASS: S1 source repo specs/ violation (exit=1)
	PASS: S1 stderr contains 'G085'
	PASS: S1 stderr contains 'MUST NOT contain persistent specs/'
--- S4: one done numbered spec ---
	PASS: S4 one done numbered spec (exit=0)
	PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
	PASS: S4 stdout contains 'currentDone=1'
--- S5: first adoption with one committed in_progress spec in a path containing spaces ---
	PASS: S5 genuine first adoption (exit=0)
	PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	PASS: S5 stdout contains 'currentDone=0'
	PASS: S5 stdout contains 'historicalDone=0'
	PASS: S5 stdout contains 'historyIntegrity=complete'
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
framework-dogfood-guard-selftest: PASSED
BUG012_REGRESSION_FOCUSED_EXIT=0
```

```text
=== Regression: SCOPE-4 (Gate G085 - framework_dogfood_evidence_gate) ===
	PASS: S1 source repo without specs/ - PASS (exit=0)
	PASS: S2 source repo with specs/ - VIOLATION (exit=1)
	PASS: S2 stderr cites Gate G085
	PASS: S2 stderr cites source no-specs rule
	PASS: S3 exactly one downstream done numbered spec - PASS (exit=0)
	PASS: S3 current-done decision code
	PASS: S4 genuine first adoption - PASS (exit=0)
	PASS: S4 first-adoption decision code
	PASS: S4 proves complete history
	PASS: S5 adversarial repositories have identical current states
	PASS: S5 reachable historical done - VIOLATION (exit=1)
	PASS: S5 historical-done failure code
	PASS: S5 historical state path
	PASS: S6 shallow fixture setup is effective
	PASS: S6 shallow history - INTEGRITY FAILURE (exit=2)
	PASS: S6 shallow-history failure code
=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0
test_04_framework_dogfooding: REGRESSION PASSED
BUG012_REGRESSION_PERSISTENT_EXIT=0
```

**Result:** PASS - both baselines are unchanged. The durable regression proves
the existing source clean/refusal pair and current-done fast path alongside the
new first-adoption branch, reachable historical-done refusal, and shallow-
history integrity refusal.

### Regression Integrity And Cross-Spec Evidence

**Phase:** regression
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh` followed by exact protected-assertion, disabled-marker, interception, and bailout checks over the same persistent test.
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/regression-baseline-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --verbose`
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
BUBBLES REGRESSION QUALITY GUARD
Repo: /Users/pkirsanov/Projects/bubbles
Bugfix mode: true
Scanning tests/regression/test_04_framework_dogfooding.sh
Adversarial signal detected in tests/regression/test_04_framework_dogfooding.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
BUG012_REGRESSION_QUALITY_EXIT=0
PASS: persistent assertion present: S1 source repo without specs/
PASS: persistent assertion present: S2 source repo with specs/
PASS: persistent assertion present: S3 exactly one downstream done numbered spec
PASS: persistent assertion present: decisionCode=G085-CURRENT-DONE
PASS: persistent assertion present: S4 genuine first adoption
PASS: persistent assertion present: decisionCode=G085-FIRST-ADOPTION
PASS: persistent assertion present: S5 adversarial repositories have identical current states
PASS: persistent assertion present: E085-ESTABLISHED-DONE-REMOVED
PASS: persistent assertion present: S6 shallow fixture setup is effective
PASS: persistent assertion present: E085-HISTORY-SHALLOW
PASS: no disabled-test marker
PASS: no internal mock/interception pattern
PASS: no conditional bailout return
BUG012_REGRESSION_INTEGRITY_FAILURES=0
```

```text
Regression Baseline Guard
Spec: improvements/BUG-012-g085-first-adoption-deadlock
G044: Regression Baseline
No test baseline comparison table found in report.md (first run may establish baseline)
G045: Cross-Spec Regression
No done specs found - cross-spec regression check is informational only
Cross-spec check N/A (no done specs)
G046: Spec Conflict Detection
No route/endpoint collisions detected across specs
Summary
Regression baseline guard: PASSED
All 0 checks passed.
BUG012_G044_BASELINE_SCAN_EXIT=0
```

**Result:** PASS - the regression remains adversarial and cannot silently pass.
The mechanical cross-spec scan found no sibling done packet or route collision
under `improvements/`. BUG-012 changes no route, API, table, UI flow, or data
model; its high-fan-out dependency is the framework validation graph exercised
below.

### Cross-Framework Regression Evidence

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (terminal verdict window from the full current-session transcript):**

```text
PASS: Case 3: future deferred to v9.0 is allowed (exit 0)
PASS: Case 4: deferred to v2.0 at VERSION 2.0.0 is due (exit 1)
PASS: Case 5: deferred to v2.0 at VERSION 2.0.3 is due (exit 1)
PASS: Case 6: deferred until v1.0 variant (exit 1)
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)
Framework validation passed.
```

**Result:** PASS - the canonical full source-repository suite remains green
after the focused and persistent G085 checks. This is the required cross-
framework dependency rerun; no narrower G085 pass substitutes for it.

### Protected-Byte Preservation Evidence

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** pre-run SHA-256 snapshot followed by post-run exact comparisons for
the G085 source/test/consumer/release surfaces, all planning-owned BUG-012
artifacts, and the `certification` object.
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** Every post-run hash matched its captured pre-run value, and
the certification fingerprint remained identical. Therefore test execution did
not overwrite dirty BUG-012, BUG-013, release, planning, or certification work.
**Output:**

```text
PASS: unchanged bubbles/scripts/framework-dogfood-guard.sh sha256=2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4
PASS: unchanged bubbles/scripts/framework-dogfood-guard-selftest.sh sha256=a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d
PASS: unchanged bubbles/scripts/guards/tail-delegated-gates.sh sha256=d587280493e6dc2719c805d1c2a28f407b2c48041542641027858e6994477c84
PASS: unchanged bubbles/scripts/state-transition-guard.sh sha256=1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b
PASS: unchanged tests/regression/test_04_framework_dogfooding.sh sha256=e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6
PASS: unchanged bubbles/registry/gates.yaml sha256=77cc4822bd0c13e0263df2aae0c1bda3fa2fedbc38db2f88ca3ec6b070756f98
PASS: unchanged bubbles/workflows.yaml sha256=8862fad3d929242edf5830c019aee5f3a02ba2b50f6f2edcfa4361a6a9e1b274
PASS: unchanged docs/recipes/framework-dogfood.md sha256=20dcac1008dd187b4f5f0e8d0c59bf8e89786275c9e5a5b26df2449177153178
PASS: unchanged docs/Framework_Convergence_Health.md sha256=0551720718bb3558b7a24e132c05476c7e5c6ca04940659bb544f63e5ebff0c7
PASS: unchanged CHANGELOG.md sha256=e097d520444168d39c86e04538776abb8d3c9699202283cb0a3971552a13765e
PASS: unchanged BUGS.md sha256=27c21c34ece02bc093f4f08954bc31a8a9cacc693796510f090411bd759d6415
PASS: unchanged bubbles/release-manifest.json sha256=6ce65b48b265d72e842dbd871f8b57d8e63575a5fc819e5e82bcaa98d1119737
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/bug.md
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/spec.md
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/design.md
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/scopes.md
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/uservalidation.md
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/scenario-manifest.json
PASS: unchanged improvements/BUG-012-g085-first-adoption-deadlock/test-plan.json
PASS: certification fingerprint unchanged sha256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
POSTRUN_PRESERVATION_FAILURES=0
```

**Result:** PASS with the interpretation above - only regression-owned report
evidence and execution routing are eligible to change in this phase.

### Regression Finding Accounting And Route

| Finding | Regression disposition | Next owner |
| --- | --- | --- |
| `BUG012-VAL-G022-REGRESSION` | Addressed: focused `71/71`, persistent `16/16`, bugfix integrity `0/0`, G044 scan, and canonical framework validation all pass with protected bytes unchanged | `bubbles.simplify` |

No regression, coverage loss, route collision, data-model contradiction, UI-
flow break, or deployment-surface change was found. Deployment regression
detection is not applicable because BUG-012 changes no deployment surface.
Line-coverage tooling is not defined for this shell-governance repository;
scenario-contract coverage is checked by the canonical traceability guard
rather than replaced with an invented percentage.

The packet and scope remain `in_progress`. Regression does not certify the
scope, alter `certification.*`, publish a release, propagate downstream, or
close later `bugfix-fastlane` phases. The resolved next phase owner is
`bubbles.simplify`.

### Regression Phase Closeout Evidence

**Phase:** regression
**Executed:** YES (current invocation, after the evidence append)
**Commands:** canonical artifact lint, G044 baseline guard, artifact freshness
guard, traceability guard, and declared-path deployment-surface classification.
**Exit Codes:** 0
**Claim Source:** executed
**Output:**

```text
All checked DoD items in scopes.md have evidence blocks
No unfilled evidence template placeholders in scopes.md
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
Test baseline comparison found in report
Cross-spec check N/A (no done specs)
No route/endpoint collisions detected across specs
Regression baseline guard: PASSED
Freshness Boundary Isolation: no spec/design freshness boundaries detected
Superseded Scope Sections: no superseded scope sections detected
Artifact freshness RESULT: PASS (0 failures, 0 warnings)
scenario-manifest.json covers 4 scenario contract(s)
All linked tests from scenario-manifest.json exist
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
Traceability RESULT: PASSED (0 warnings)
BUG012_DEPLOYMENT_SURFACE_FAILURES=0
```

**Result:** PASS - regression Tier 1 packet checks and Tier 2 scenario,
baseline, cross-spec, silent-pass, adversarial, and deployment-applicability
checks are complete. No affected sibling done spec exists under the active
`improvements/` packet root; framework-wide consumers were exercised by the
canonical full suite. No regression was found, so regression-test remediation
and coverage-repair routing are not applicable.

<!-- markdownlint-restore MD010 -->

## BUG012-TEST-CONSUMER-001 Implementation Repair - 2026-07-14

This implementation invocation addressed only the routed stale Check 26
consumer reference. At first inspection, the exact planned comment-only delta
was already present in the dirty canonical worktree, so this invocation
preserved it rather than overwriting concurrent in-scope work. The active
wrapper now names both valid downstream decisions: `G085-CURRENT-DONE` and
`G085-FIRST-ADOPTION`. No executable line, gate order, exit contract, test,
registry, generated file, downstream managed copy, scope checkbox, status, or
`certification.*` field was changed by this invocation.

### Comment-Only Change Boundary Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Command:** `git diff --unified=3 -- bubbles/scripts/state-transition-guard.sh; git diff --check -- bubbles/scripts/state-transition-guard.sh improvements/BUG-012-g085-first-adoption-deadlock/report.md improvements/BUG-012-g085-first-adoption-deadlock/state.json`
**Exit Code:** `0`, `0`
**Claim Source:** executed
**Output:**

```text
BUG012_COMMENT_ONLY_DIFF_BEGIN
diff --git a/bubbles/scripts/state-transition-guard.sh b/bubbles/scripts/state-transition-guard.sh
index bb3ecc7..fb3e4b5 100755
--- a/bubbles/scripts/state-transition-guard.sh
+++ b/bubbles/scripts/state-transition-guard.sh
@@ -3221,10 +3221,11 @@ source "$SCRIPT_DIR/guards/tail-convergence-gates.sh"
 # The guard is source-aware. In the Bubbles source repository, persistent
 # `specs/` are forbidden and dogfood evidence comes from framework
 # validation, hermetic selftests, release manifests, and downstream or
-# fixture specs. In downstream/fixture repositories, the traditional
-# evidence model still applies: at least one numbered spec at status
-# `done` demonstrates the installed framework can drive work to
-# certification.
+# fixture specs. In downstream/fixture repositories, G085-CURRENT-DONE
+# passes on current numbered state evidence with exact top-level `status:
+# done`. G085-FIRST-ADOPTION passes only when the required current-state
+# and complete-history evidence is proven; missing or incomplete evidence
+# fails closed.
 if [[ "${BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST:-0}" == "1" ]]; then
BUG012_COMMENT_ONLY_DIFF_EXIT=0
BUG012_SCOPED_DIFF_CHECK_EXIT=0
BUG012_COMMENT_ONLY_DIFF_END
```

**Result:** PASS - the only `state-transition-guard.sh` delta is full-line
comment text inside the existing Check 26 wrapper. Runtime delegation and every
executable line are unchanged, and the scoped whitespace check is clean.

### Exact Stale-Reference And Consumer Sweep

**Phase:** implement
**Executed:** YES (current invocation)
**Command:** the exact zsh-safe assertion harness below was executed from the canonical repository root.

```bash
root="$PWD"; failures=0
check_contains() { label="$1"; file="$2"; needle="$3"; if grep -qF -- "$needle" "$file"; then printf 'PASS: %s\n' "$label"; else printf 'FAIL: %s\n' "$label"; failures=$((failures + 1)); fi; }
check_absent() { label="$1"; file="$2"; needle="$3"; if grep -qF -- "$needle" "$file"; then printf 'FAIL: %s\n' "$label"; failures=$((failures + 1)); else printf 'PASS: %s\n' "$label"; fi; }
check_manifest_hash() { label="$1"; section="$2"; manifest_path="$3"; expected="$4"; actual="$(/usr/bin/jq -r --arg section "$section" --arg manifest_path "$manifest_path" '.[$section][] | select(.path == $manifest_path) | .sha256' "$root/bubbles/release-manifest.json")"; if [[ "$actual" == "$expected" ]]; then printf 'PASS: %s hash=%s\n' "$label" "$actual"; else printf 'FAIL: %s expected=%s actual=%s\n' "$label" "$expected" "${actual:-missing}"; failures=$((failures + 1)); fi; }
printf '%s\n' 'BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_BEGIN' 'GROUP: delegated and broad callers'
check_contains 'delegated Check 26 names current-done path' "$root/bubbles/scripts/guards/tail-delegated-gates.sh" 'G085-CURRENT-DONE'
check_contains 'delegated Check 26 names first-adoption path' "$root/bubbles/scripts/guards/tail-delegated-gates.sh" 'G085-FIRST-ADOPTION'
check_contains 'framework validation registers focused G085 selftest' "$root/bubbles/scripts/framework-validate.sh" 'framework-dogfood-guard-selftest.sh'
check_contains 'state-transition caller sources delegated tail' "$root/bubbles/scripts/state-transition-guard.sh" 'source "$SCRIPT_DIR/guards/tail-delegated-gates.sh"'
check_absent 'state-transition caller has no obsolete done-only wrapper prose' "$root/bubbles/scripts/state-transition-guard.sh" 'fixture specs. In downstream/fixture repositories, the traditional'
check_contains 'state-transition caller comment names current-done path' "$root/bubbles/scripts/state-transition-guard.sh" 'G085-CURRENT-DONE'
check_contains 'state-transition caller comment names first-adoption path' "$root/bubbles/scripts/state-transition-guard.sh" 'G085-FIRST-ADOPTION'
printf '%s\n' 'GROUP: registry and operator references'
check_contains 'gate registry names current-done path' "$root/bubbles/registry/gates.yaml" 'G085-CURRENT-DONE'
check_contains 'gate registry names first-adoption path' "$root/bubbles/registry/gates.yaml" 'G085-FIRST-ADOPTION'
check_contains 'generated workflow registry names current-done path' "$root/bubbles/workflows.yaml" 'G085-CURRENT-DONE'
check_contains 'generated workflow registry names first-adoption path' "$root/bubbles/workflows.yaml" 'G085-FIRST-ADOPTION'
check_contains 'operator recipe names current-done path' "$root/docs/recipes/framework-dogfood.md" 'G085-CURRENT-DONE'
check_contains 'operator recipe names first-adoption path' "$root/docs/recipes/framework-dogfood.md" 'G085-FIRST-ADOPTION'
check_contains 'operator recipe rejects mutable marker' "$root/docs/recipes/framework-dogfood.md" 'There is no'
check_contains 'convergence reference names proven first adoption' "$root/docs/Framework_Convergence_Health.md" 'proven first-adoption state'
check_contains 'current changelog names two explicit pass paths' "$root/CHANGELOG.md" 'Two explicit downstream pass paths'
check_contains 'current changelog rejects mutable marker' "$root/CHANGELOG.md" 'No mutable adoption'
printf '%s\n' 'GROUP: release provenance'
check_manifest_hash 'managed guard manifest checksum' managedFileChecksums 'bubbles/scripts/framework-dogfood-guard.sh' '2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4'
check_manifest_hash 'managed selftest manifest checksum' managedFileChecksums 'bubbles/scripts/framework-dogfood-guard-selftest.sh' 'a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d'
check_manifest_hash 'managed recipe manifest checksum' managedFileChecksums 'docs/recipes/framework-dogfood.md' '20dcac1008dd187b4f5f0e8d0c59bf8e89786275c9e5a5b26df2449177153178'
check_manifest_hash 'source-only persistent regression checksum' sourceOnlyFileChecksums 'tests/regression/test_04_framework_dogfooding.sh' 'e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6'
printf 'CONSUMER_SWEEP_FAILURES=%s\n' "$failures"
if [[ "$failures" -ne 0 ]]; then printf '%s\n' 'BUG-012 exact first-party consumer sweep: FAIL' 'BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_END'; exit 1; fi
printf '%s\n' 'BUG-012 exact first-party consumer sweep: PASS' 'BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_END'
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_BEGIN
GROUP: delegated and broad callers
PASS: delegated Check 26 names current-done path
PASS: delegated Check 26 names first-adoption path
PASS: framework validation registers focused G085 selftest
PASS: state-transition caller sources delegated tail
PASS: state-transition caller has no obsolete done-only wrapper prose
PASS: state-transition caller comment names current-done path
PASS: state-transition caller comment names first-adoption path
GROUP: registry and operator references
PASS: gate registry names current-done path
PASS: gate registry names first-adoption path
PASS: generated workflow registry names current-done path
PASS: generated workflow registry names first-adoption path
PASS: operator recipe names current-done path
PASS: operator recipe names first-adoption path
PASS: operator recipe rejects mutable marker
PASS: convergence reference names proven first adoption
PASS: current changelog names two explicit pass paths
PASS: current changelog rejects mutable marker
GROUP: release provenance
PASS: managed guard manifest checksum hash=2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4
PASS: managed selftest manifest checksum hash=a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d
PASS: managed recipe manifest checksum hash=20dcac1008dd187b4f5f0e8d0c59bf8e89786275c9e5a5b26df2449177153178
PASS: source-only persistent regression checksum hash=e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6
CONSUMER_SWEEP_FAILURES=0
BUG-012 exact first-party consumer sweep: PASS
BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_END
```

**Result:** PASS - every first-party consumer assertion is green, the obsolete
wrapper prose is absent, both decision codes are present in the wrapper, and
the four G085 release-provenance hashes match the canonical manifest.

Two preliminary sweep harness attempts are retained as discarded evidence. All
reference assertions passed, but the provenance subchecks did not execute
because a helper local named `path` collided with zsh's reserved `path` array
and removed `jq` from command lookup. The final run above renamed that local to
`manifest_path`, invoked `/usr/bin/jq` explicitly, and is the sole controlling
consumer-sweep result.

### Focused G085 Tests

**Phase:** implement
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (selected literal decision and terminal window):**

```text
--- S4: one done numbered spec ---
  ✅ PASS: S4 one done numbered spec (exit=0)
  ✅ PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
  ✅ PASS: S4 stdout contains 'currentDone=1'
--- S5: first adoption with one committed in_progress spec in a path containing spaces ---
  ✅ PASS: S5 genuine first adoption (exit=0)
  ✅ PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
  ✅ PASS: S5 stdout contains 'currentDone=0'
  ✅ PASS: S5 stdout contains 'historicalDone=0'
  ✅ PASS: S5 stdout contains 'historyIntegrity=complete'
  ✅ PASS: S5 guard leaves refs, index, worktree, and object inventory unchanged
--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
  ✅ PASS: S16 current-done guidance
  ✅ PASS: S16 genuine first-adoption guidance
  ✅ PASS: S16 stale single-path guidance is absent
=== Selftest verdict ===
  Total assertions: 71
  Passed:           71
  Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
BUG012_G085_SELFTEST_3A91_EXIT=0
BUG012_G085_SELFTEST_3A91_END
```

**Result:** PASS - all 71 focused production-guard assertions pass, including
the two valid downstream decisions and delegated Check 26 guidance.

**Phase:** implement
**Executed:** YES (current invocation)
**Command:** `bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_G085_REGRESSION_6C42_BEGIN
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===
  ✅ PASS: S1 source repo without specs/ — PASS (exit=0)
  ✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
  ✅ PASS: S2 stderr cites Gate G085
  ✅ PASS: S2 stderr cites source no-specs rule
  ✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
  ✅ PASS: S3 current-done decision code
  ✅ PASS: S4 genuine first adoption — PASS (exit=0)
  ✅ PASS: S4 first-adoption decision code
  ✅ PASS: S4 proves complete history
  ✅ PASS: S5 adversarial repositories have identical current states
  ✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
  ✅ PASS: S5 historical-done failure code
  ✅ PASS: S5 historical state path
  ✅ PASS: S6 shallow fixture setup is effective
  ✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
  ✅ PASS: S6 shallow-history failure code
=== Regression verdict ===
  Total assertions: 16
  Passed:           16
  Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
BUG012_G085_REGRESSION_6C42_EXIT=0
BUG012_G085_REGRESSION_6C42_END
```

**Result:** PASS - all 16 persistent production-guard regression assertions
pass. Source invariance, current done, proven first adoption, historical-done
durability, and shallow-history refusal remain intact.

### Finding Accounting And Handoff

| Finding | Implementation disposition | Next owner |
| --- | --- | --- |
| `BUG012-TEST-CONSUMER-001` | Addressed: the active Check 26 wrapper comment names `G085-CURRENT-DONE` and proven `G085-FIRST-ADOPTION`; exact consumer sweep `0` failures; focused tests `71/71` and `16/16` | `bubbles.test` for independent rerun and test-owned Consumer Impact DoD reconciliation |

The packet and scope remain `in_progress`. This implementation handoff does not
check the independent-test Consumer Impact item, certify the scope, claim
release/propagation, or close BUG-012.

**Result:** FAIL as expected before a fix. The canonical production guard reproduces the operator's exact first-adoption deadlock against Research Lab without touching its installed framework copy.

## Bug Reproduction - Current-Session Red/Green Replay

**Phase:** implement
**Executed:** YES (in current session)
**RED:** failing proof captured from the committed pre-fix guard before applying
the current implementation.
**Command 1:** `set +e; /bin/bash <(git -C /Users/pkirsanov/Projects/bubbles show HEAD:bubbles/scripts/framework-dogfood-guard.sh) --repo-root /Users/pkirsanov/Projects/research-lab; guard_exit=$?; set -e; printf '%s\n' "PRE_FIX_GUARD_EXIT=$guard_exit"; [[ "$guard_exit" -eq 1 ]]`
**Exit Code 1:** 0 for the assertion wrapper; committed guard exit `1`
**GREEN:** passing proof captured from the current production guard against the
same unchanged downstream repository.
**Command 2:** `set +e; /bin/bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-dogfood-guard.sh --repo-root /Users/pkirsanov/Projects/research-lab; guard_exit=$?; set -e; printf '%s\n' "CURRENT_GUARD_EXIT=$guard_exit"; [[ "$guard_exit" -eq 0 ]]`
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
G085 framework_dogfood_evidence_gate violation
  repositoryClass:    downstream-or-fixture
  specsDir:           /Users/pkirsanov/Projects/research-lab/specs
  numbered-feature state.json files found: 2
  count with status==done:                 0
  requirement:        downstream/fixture dogfood evidence needs at least one specs/NNN-*/state.json with top-level "status": "done"
  recipe:             docs/recipes/framework-dogfood.md
  remediation:        certify at least one downstream or fixture spec to done, or run against the Bubbles source repo where persistent specs/ is forbidden
  candidate specs currently in-flight:
    - /Users/pkirsanov/Projects/research-lab/specs/001-causal-rotation-intelligence/state.json  (status=not_started)
    - /Users/pkirsanov/Projects/research-lab/specs/002-distributed-tool-briefs-and-history/state.json  (status=not_started)
PRE_FIX_GUARD_EXIT=1
framework-dogfood-guard: repositoryClass=downstream-or-fixture specsDir=/Users/pkirsanov/Projects/research-lab/specs totalSpecs=2 currentDone=0 historicalDone=0 historyIntegrity=complete
PASS Gate G085 (framework_dogfood_evidence_gate) decisionCode=G085-FIRST-ADOPTION currentDone=0 historicalDone=0 historyIntegrity=complete totalSpecs=2 specsDir=/Users/pkirsanov/Projects/research-lab/specs
CURRENT_GUARD_EXIT=0
```

**Result:** PASS - the exact committed guard reproduces the deadlock and the
current canonical guard clears G085 against the same unchanged full-history
downstream root. This is source-checkout validation, not an installed-framework
upgrade or byte-parity claim.

## Root Cause Evidence

**Phase:** discovery
**Claim Source:** interpreted
**Interpretation:** The source branch is a concrete control-flow explanation, but runtime reproduction is still required before implementation dispatch.

- `bubbles/scripts/framework-dogfood-guard.sh` counts top-level numbered feature states with exact `status: done`.
- Its downstream decision fails unconditionally when `DONE_COUNT < 1`.
- No adoption-lifecycle discriminator is consulted.
- Existing selftests currently require a one-`in_progress` downstream fixture to fail.

### Discriminating Signal Finding

**Phase:** discovery
**Claim Source:** interpreted
**Interpretation:** The completed [design.md](design.md) confirms reachable Git history as the lifecycle discriminator because `.install-source.json::installedAt` is rewritten on every install or upgrade. Research Lab is a full, non-shallow repository and has zero reachable commits touching top-level numbered spec state files; implementation must additionally prove exact-root, non-partial, all-ref traversal integrity before accepting absence.

Ratified fail-closed decision boundary:

| Current done count | Reachable historical top-level done evidence | History integrity | Proposed result |
| ---: | ---: | --- | --- |
| 1+ | any | any | Pass through existing dogfood evidence path |
| 0 | none | full non-shallow Git history | Pass as first adoption |
| 0 | present | full non-shallow Git history | Fail as established repository without current dogfood evidence |
| 0 | unknown | missing Git or shallow/incomplete history | Fail closed with actionable diagnostic |

This boundary avoids the invalid alternatives of exempting every zero-done repository, trusting resettable current statuses, or using a refresh timestamp as proof of first adoption.

## Test Evidence

<!-- markdownlint-disable MD010 -->

### Focused G085 Classifier Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (source, permitted-pass, and delegated-guidance assertions from the raw run):**

```text
--- S0: source repo has no specs/ and evidence surfaces exist ---
	✅ PASS: S0 source repo without specs/ (exit=0)
	✅ PASS: S0 stdout contains 'PASS Gate G085'
	✅ PASS: S0 stdout contains 'source repo has no persistent specs/'
--- S1: source repo contains specs/ ---
	✅ PASS: S1 source repo specs/ violation (exit=1)
	✅ PASS: S1 stderr contains 'G085'
	✅ PASS: S1 stderr contains 'docs/recipes/framework-dogfood.md'
	✅ PASS: S1 stderr contains 'MUST NOT contain persistent specs/'
--- S4: one done numbered spec ---
	✅ PASS: S4 one done numbered spec (exit=0)
	✅ PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
	✅ PASS: S4 stdout contains 'currentDone=1'
--- S5: first adoption with one committed in_progress spec in a path containing spaces ---
	✅ PASS: S5 genuine first adoption (exit=0)
	✅ PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	✅ PASS: S5 stdout contains 'currentDone=0'
	✅ PASS: S5 stdout contains 'historicalDone=0'
	✅ PASS: S5 stdout contains 'historyIntegrity=complete'
	✅ PASS: S5 guard leaves refs, index, worktree, and object inventory unchanged
--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
	✅ PASS: S16 current-done guidance
	✅ PASS: S16 genuine first-adoption guidance
	✅ PASS: S16 stale single-path guidance is absent
```

**Result:** PASS - canonical-source behavior, ordinary current-done evidence,
genuine first adoption, read-only execution, and both delegated Check 26 pass
paths are covered through the production guard and current guidance source.

### Historical-Done Durability Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (historical-evidence assertions from the raw run):**

```text
--- S7: done state changed to in_progress remains established ---
	✅ PASS: S7 changed historical done (exit=1)
	✅ PASS: S7 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S7 stderr contains 'historyPath=specs/001-foo/state.json'
	✅ PASS: S7 stderr contains 'historyCommit='
	✅ PASS: S7 blob privacy stderr omits 'G085_PRIVATE_BLOB_PAYLOAD'
--- S8: deleted done state remains established while another current state remains ---
	✅ PASS: S8 deleted historical done (exit=1)
	✅ PASS: S8 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S8 stderr contains 'historyPath=specs/001-done/state.json'
--- S9: done state reachable only from another local branch is established ---
	✅ PASS: S9 all-ref historical done (exit=1)
	✅ PASS: S9 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S9 stderr contains 'historyPath=specs/001-foo/state.json'
```

**Result:** PASS - changed, deleted, and alternate-ref done evidence all remain
established, while the diagnostic exposes only the commit/path identity and not
the committed state payload.

### Fail-Closed History Integrity Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (distinct partial-history and final verdict assertions from the raw run):**

```text
--- S11: effective file:// shallow clone fails closed ---
	✅ PASS: S11 fixture is genuinely shallow
	✅ PASS: S11 shallow history (exit=2)
	✅ PASS: S11 stderr contains 'failureCode=E085-HISTORY-SHALLOW'
	✅ PASS: S11 stderr contains 'historyIntegrity=shallow'
--- S12a: extensions.partialClone metadata fails closed as partial history ---
	✅ PASS: S12a extensions.partialClone metadata (exit=2)
	✅ PASS: S12a stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12a stderr contains 'historyIntegrity=partial'
	✅ PASS: S12a stderr contains 'extensions.partialClone metadata is present'
--- S12b: remote.promisor metadata fails closed as partial history ---
	✅ PASS: S12b remote.promisor metadata (exit=2)
	✅ PASS: S12b stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12b stderr contains 'historyIntegrity=partial'
	✅ PASS: S12b stderr contains 'remote promisor metadata is enabled'
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
```

**Result:** PASS - `extensions.partialClone` and `remote.*.promisor` are
independent fixtures, and both fail closed with the same policy class while
retaining distinct discriminating diagnostics. The complete S3/S6/S10-S14
matrix also passed in this 71-assertion run.

### Persistent Production-Guard Regression Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===
	✅ PASS: S1 source repo without specs/ — PASS (exit=0)
	✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
	✅ PASS: S2 stderr cites Gate G085
	✅ PASS: S2 stderr cites source no-specs rule
	✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
	✅ PASS: S3 current-done decision code
	✅ PASS: S4 genuine first adoption — PASS (exit=0)
	✅ PASS: S4 first-adoption decision code
	✅ PASS: S4 proves complete history
	✅ PASS: S5 adversarial repositories have identical current states
	✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
	✅ PASS: S5 historical-done failure code
	✅ PASS: S5 historical state path
	✅ PASS: S6 shallow fixture setup is effective
	✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
	✅ PASS: S6 shallow-history failure code
=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
```

**Result:** PASS - the persistent suite executes the production guard against
real disposable repositories. Source invariance, current done, genuine first
adoption, identical-current-state historical divergence, and effective shallow
history all retain scenario-specific assertions with no early return.

### Regression Integrity Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

<!-- markdownlint-disable MD010 -->

```text
============================================================
	BUBBLES REGRESSION QUALITY GUARD
	Repo: /Users/pkirsanov/Projects/bubbles
	Timestamp: 2026-07-13T19:54:42Z
	Bugfix mode: true
============================================================
ℹ️  Scanning tests/regression/test_04_framework_dogfooding.sh
✅ Adversarial signal detected in tests/regression/test_04_framework_dogfooding.sh
============================================================
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
============================================================
```

**Result:** PASS - the persistent regression contains an adversarial signal and
the bugfix-quality guard reports zero violations and zero warnings.

### Portability Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/macos-portability-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/framework-dogfood-guard.sh bubbles/scripts/framework-dogfood-guard-selftest.sh bubbles/scripts/guards/tail-delegated-gates.sh tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 2:** 0
**Claim Source:** executed
**Output (canonical selftest verdict and complete touched-file scan):**

```text
	PASS: no-surface invocation exits 2 (usage)
	PASS: missing-path invocation exits 2 (usage)
	PASS: guard parses (bash -n)
	PASS: guard is self-portable (guard scans its own source -> exit 0)
	PASS: guard source (comments stripped) has no literal GNU-only form
[selftest macos-portability-guard] OK — all assertions passed.
== macOS portability guard -- scanning 4 file(s) ==
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

**Result:** PASS - the canonical portability guard selftest passes all classes,
and the two touched shell files contain none of the 13 mechanically forbidden
GNU/Bash-only forms.

### Packet Quality Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command 1:** `bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/artifact-lint.sh /Users/pkirsanov/Projects/bubbles/improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 1:** 0
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 2:** 0
**Command 3:** `bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/traceability-guard.sh /Users/pkirsanov/Projects/bubbles/improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 3:** 0
**Claim Source:** executed
**Output (verdict windows from the full unfiltered runs):**

```text
=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md
=== End Anti-Fabrication Checks ===
Artifact lint PASSED.
--- Check 1: Freshness Boundary Isolation (spec.md / design.md) ---
ℹ️  spec.md has no superseded/suppressed sections
ℹ️  design.md has no superseded/suppressed sections
--- Check 2: Superseded Scope Sections Are Non-Executable ---
ℹ️  scopes.md has no superseded scope section
--- Check 4: Result ---
RESULT: PASS (0 failures, 0 warnings)
--- Traceability Summary ---
ℹ️  Scenarios checked: 4
ℹ️  Test rows checked: 9
ℹ️  Scenario-to-row mappings: 4
ℹ️  Concrete test file references: 4
ℹ️  Report evidence references: 4
ℹ️  DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
```

**Result:** PASS - packet structure, anti-fabrication evidence shape, freshness,
four-scenario/nine-row traceability, and DoD fidelity all pass. Artifact lint
also reports one non-blocking advisory that `state.json` uses deprecated
`certification.scopeProgress`; implementation does not own certification state,
so this invocation preserves it and carries it in finding accounting.

### Source Integrity And Consumer Sweep Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command 1:** `guard=/Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-dogfood-guard.sh; printf '%s\n' '=== G085 OFFLINE/READ-ONLY SOURCE AUDIT ==='; grep -n 'GIT_NO_LAZY_FETCH=1' "$guard"; if grep -nE 'git -C .* (fetch|checkout|reset|commit|update-ref|repack|gc)( |$)' "$guard"; then printf '%s\n' 'FAIL: mutating Git command found'; exit 1; else printf '%s\n' 'PASS: no fetch/checkout/reset/commit/update-ref/repack/gc command'; fi; grep -n 'trap cleanup_history_workspace EXIT' "$guard"; grep -n 'rm -rf "$HISTORY_WORKSPACE"' "$guard"; printf '%s\n' 'PASS: history scan is local, lazy-fetch-disabled, and scratch-only'`
**Exit Code 1:** 0
**Command 2:** `root=/Users/pkirsanov/Projects/bubbles; stale='Downstream/fixture requirement: at least one specs/[0-9]*-*/state.json has top-level'; selftest="$root/bubbles/scripts/framework-dogfood-guard-selftest.sh"; files=("$root/bubbles/scripts/framework-dogfood-guard.sh" "$selftest" "$root/bubbles/scripts/guards/tail-delegated-gates.sh" "$root/tests/regression/test_04_framework_dogfooding.sh" "$root/bubbles/registry/gates.yaml" "$root/bubbles/workflows.yaml" "$root/docs/recipes/framework-dogfood.md"); printf '%s\n' '=== G085 CONSUMER ASSERTIONS ==='; stale_files="$(grep -lF "$stale" "${files[@]}" || true)"; [[ "$stale_files" == "$selftest" ]]; printf '%s\n' 'PASS stale literal is confined to S16 negative assertion'; for file in "${files[@]}"; do grep -qF 'G085-CURRENT-DONE' "$file"; grep -qF 'G085-FIRST-ADOPTION' "$file"; printf 'PASS both decision codes: %s\n' "${file#$root/}"; done; grep -qF 'current done evidence or with a proven first-adoption state' "$root/docs/Framework_Convergence_Health.md"; printf '%s\n' 'PASS convergence doc names both pass paths'; grep -qF 'Two explicit downstream pass paths' "$root/CHANGELOG.md"; printf '%s\n' 'PASS changelog names the two-path release contract'; printf '%s\n' 'PASS G085 consumer sweep complete'`
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
=== G085 OFFLINE/READ-ONLY SOURCE AUDIT ===
399:if ! GIT_NO_LAZY_FETCH=1 git -C "$REPO_ROOT" rev-list --all -- "$HISTORY_PATHSPEC" > "$COMMITS_FILE" 2> "$HISTORY_STDERR"; then
420:  if ! GIT_NO_LAZY_FETCH=1 git -C "$REPO_ROOT" ls-tree -r -z --name-only "$history_commit" -- specs > "$STATE_PATHS_FILE" 2> "$HISTORY_STDERR"; then
426:    if ! GIT_NO_LAZY_FETCH=1 git -C "$REPO_ROOT" cat-file blob "$history_commit:$history_path" > "$HISTORICAL_BLOB_FILE" 2> "$HISTORY_STDERR"; then
PASS: no fetch/checkout/reset/commit/update-ref/repack/gc command
361:trap cleanup_history_workspace EXIT
358:  rm -rf "$HISTORY_WORKSPACE" 2>/dev/null || true
PASS: history scan is local, lazy-fetch-disabled, and scratch-only
=== G085 CONSUMER ASSERTIONS ===
PASS stale literal is confined to S16 negative assertion
PASS both decision codes: bubbles/scripts/framework-dogfood-guard.sh
PASS both decision codes: bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS both decision codes: bubbles/scripts/guards/tail-delegated-gates.sh
PASS both decision codes: tests/regression/test_04_framework_dogfooding.sh
PASS both decision codes: bubbles/registry/gates.yaml
PASS both decision codes: bubbles/workflows.yaml
PASS both decision codes: docs/recipes/framework-dogfood.md
PASS convergence doc names both pass paths
PASS changelog names the two-path release contract
PASS G085 consumer sweep complete
```

**Result:** PASS - exact top-level/path filtering and blob privacy remain
covered by S7/S15, S5 proves repository state is unchanged, and the source audit
proves the history classifier is local, lazy-fetch-disabled, scratch-only, and
contains no mutating Git command. The only obsolete single-path literal is the
selftest assertion that requires it to be absent from delegated guidance.

### Registry And Release Metadata Evidence

**Phase:** implement
**Executed:** YES (in current session)
**Command 1:** `bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/generate-gates-block.sh --check`
**Exit Code 1:** 0
**Command 2:** `bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/workflow-registry-consistency.sh`
**Exit Code 2:** 0
**Command 3:** `bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Code 3:** 1 after the BUG-012 changelog correction, as expected
**Command 4:** `bash bubbles/scripts/generate-release-manifest.sh`
**Exit Code 4:** 0
**Command 5:** `bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Code 5:** 0
**Command 6:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/framework-dogfood-guard.sh bubbles/scripts/framework-dogfood-guard-selftest.sh bubbles/scripts/guards/tail-delegated-gates.sh tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 6:** 0
**Claim Source:** executed
**Output:**

```text
generate-gates-block: workflows.yaml is in sync with registry (470 registry lines)
workflow-registry consistency check passed.
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
Updated release manifest: 7.20.0 (611 managed files)
Release manifest is current: 7.20.0 (611 managed files)
== macOS portability guard -- scanning 4 file(s) ==
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

**Result:** PASS - canonical and generated gate registries agree, direct G085
docs/metadata agree with executable behavior, the combined 611-file managed
payload has a fresh canonical release manifest, and every touched BUG-012 shell
surface passes the portability scan.

### Historical Broad Validation Failure Evidence (Superseded)

The literal transcript below records the canceled invocation's transient
performance-budget failure. It is retained for provenance but no longer controls
the implementation disposition because the resumed invocation's canonical
`framework-validate` and `release-check` both exited `0`; see
[Resumed Framework And Release Evidence](#resumed-framework-and-release-evidence).

**Phase:** implement
**Executed:** YES (in current session)
**Command 1:** `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh`
**Result 1:** FAIL after the guard reliability performance selftest exceeded its committed budget
**Exit Code 1:** nonzero; the async terminal exposed the failed check but did not surface the numeric process exit
**Command 2:** `env -i HOME="$HOME" PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard-perf-selftest.sh`
**Result 2:** FAIL in a dedicated terminal; a later process audit proved another release/framework validation tree was concurrently active
**Exit Code 2:** nonzero; the async terminal exposed the `6 passed, 1 failed` verdict but did not surface the numeric process exit
**Claim Source:** executed
**Output:**

```text
PASS: timeout fires (124) on a hanging command
PASS: fast command exit code preserved (3)
PASS: pruned find returns only the real file (1), excludes generated-dir decoys
PASS: no generated-directory paths leak through the prune
PASS: pruned walk completes within budget (0s <= 10s)
FAIL: guard over     6036-line report.md took 131s (>= 30s budget) - Check 11 fork-storm may have regressed
============================================================
	BUBBLES STATE TRANSITION GUARD
	Feature: /var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/tmp.qcbeggBSXc/bug005/specs/005-perf-fixture
============================================================
--- Check 1: Required Artifacts ---
PASS: Required artifact exists: spec.md
PASS: Required artifact exists: design.md
PASS: Required artifact exists: uservalidation.md
PASS: Required artifact exists: state.json
PASS: Required artifact exists: scopes.md
PASS: Required artifact exists: report.md
--- Check 2: state.json Integrity ---
INFO: Current state.json status: in_progress
INFO: Current workflowMode: bugfix-fastlane
PASS: Check 11 distinct-category semantics preserved (exactly 1 illegitimate block detected)
[state-transition-guard-perf-selftest] 6 passed, 1 failed
FAIL: Guard reliability perf selftest (v6.1 / R1 / BUG-001)
```

**Historical result:** BLOCKED at that point - focused G085 checks did not fail, but the required full
framework gate did not pass: the committed BUG-005/guard-reliability performance
fixture took 131 seconds against a 30-second budget while another release and
framework-validation tree was active. The owning guard and perf-test files are
clean in this worktree and outside BUG-012's declared Change Boundary. The
failure is real gate evidence but is not sufficient to attribute a deterministic
baseline performance regression; an uncontended rerun is required.

<!-- markdownlint-restore MD010 -->

## Implementation Disposition

The planned G085 guard, selftest, persistent regression, delegated guidance,
registry, direct docs, changelog/bug-log metadata, and release-manifest changes
are implementation-green under fresh current-invocation execution. Scope 1 and
the packet remain `In Progress`; `bubbles.plan` must first reconcile transition-
guard planning requirements, after which the independent specialist chain can
continue. The validate-owned certification object is unchanged, and no Done
claim is made.

## Change Inventory

| Surface | Current disposition |
| --- | --- |
| BUG-012 artifact packet | Current implementation evidence and itemized uncertainties recorded under G085-compatible `improvements/` |
| Production guard | First-adoption classifier and stable diagnostics focused-green |
| Tests | Exhaustive selftest `71/71`; persistent regression `16/16`; regression-quality and portability guards pass |
| Registry/docs | Canonical/generated registry parity and named-consumer sweep pass |
| Release metadata | Canonical 611-file manifest is fresh; current-invocation release readiness passes |
| Downstream copies | No direct managed-copy edit or upgrade performed by this invocation |

## Research Lab Propagation

The required propagation mechanism is upstream install/upgrade only. Do not patch `.github/bubbles/**` in Research Lab.

### Validated local-source rehearsal path

This path is permitted only after specialist implementation, test, framework validation, and release-check evidence are green in the canonical checkout:

```bash
cd /Users/pkirsanov/Projects/research-lab
bash .github/bubbles/scripts/cli.sh upgrade --dry-run --local-source ../bubbles
bash .github/bubbles/scripts/cli.sh upgrade --local-source ../bubbles
bash .github/bubbles/scripts/cli.sh doctor
bash .github/bubbles/scripts/cli.sh framework-write-guard
bash .github/bubbles/scripts/framework-dogfood-guard.sh --repo-root "$PWD"
bash .github/bubbles/scripts/cli.sh guard specs/001-causal-rotation-intelligence
```

The canonical checkout is currently dirty, so the dry run must report that trust condition and the rehearsal must not be represented as a clean released install.

### Published release path

After release ownership publishes a validated Bubbles release containing BUG-012:

```bash
cd /Users/pkirsanov/Projects/research-lab
bash .github/bubbles/scripts/cli.sh upgrade --dry-run
bash .github/bubbles/scripts/cli.sh upgrade
bash .github/bubbles/scripts/cli.sh doctor
bash .github/bubbles/scripts/cli.sh framework-write-guard
bash .github/bubbles/scripts/framework-dogfood-guard.sh --repo-root "$PWD"
bash .github/bubbles/scripts/cli.sh guard specs/001-causal-rotation-intelligence
```

Required post-upgrade signals are: installed provenance points at the validated upstream revision/release; framework write guard is clean; installed G085 emits its explicit first-adoption pass; and the original transition proceeds past G085. This invocation executed only a source-checkout red/green replay against Research Lab; it did not run or claim the install/upgrade sequence, installed-byte parity, or the original full state transition.

## Reconciled Observations

- The earlier 131-second performance-budget failure did not recur: fresh
  `framework-validate` and `release-check` both pass.
- The implementation reality scan resolves six implementation-bearing files,
  reports zero violations, and emits one nonblocking planning-link advisory
  because discovery falls back from `scopes.md` to `design.md`. Adding the
  scanner-specific `### Implementation Files` planning section is not owned by
  `bubbles.implement`; the existing design fallback was manually reviewed.
- GuestHost and Research Lab contain pre-existing managed-framework dirt. This
  invocation did not edit, install, upgrade, reset, or copy any downstream
  managed framework path.

## Coverage Report

Executed coverage comprises all three focused classifier rows, all three
production-guard E2E regression rows, portability, full framework validation,
and release readiness. No skipped G085 scenario or silent-pass bailout was
observed.

## Lint/Quality

Artifact lint, artifact freshness, traceability, shell syntax, regression
quality, portability, generated-registry parity, workflow-registry consistency,
implementation reality, release-manifest freshness, full framework validation,
and release readiness all execute green. The implementation reality scan reports
zero violations and one manually reviewed planning-link advisory.

## Spot-Check Recommendations

- The adversarial fixtures were observed byte-identical at current state and
  divergent only on reachable historical done evidence.
- The shallow fixture asserted `--is-shallow-repository=true` before invoking
  the production guard.
- The focused selftest verified payload privacy and unchanged refs, index,
  worktree, and object inventory.

## Validation Summary

Focused BUG-012 behavior, packet coherence, full framework validation, and
release readiness pass. Terminal promotion is blocked by planning-owned scope
shape, missing independent specialist phases, scope/certification coherence, and
the absent G090 session snapshot. Validate-owned certification remains unclaimed.

## Audit Verdict

Not evaluated. Audit and certification remain owned by their designated specialists.

## Resumed Invocation Reconciliation - 2026-07-13

This resumed invocation did not reuse the earlier execution claims. It read the
current packet and dirty diff first, then re-executed T-BUG-012-01 through
T-BUG-012-09 against the current checkout. The fresh broad runs below supersede
the earlier transient guard-performance blocker as the controlling implementation
evidence; that older raw failure transcript remains preserved above as history.

<!-- markdownlint-disable MD010 -->

### Resumed Focused And Regression Evidence

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (literal terminal windows from the fresh 71-assertion run):**

```text
--- S4: one done numbered spec ---
	✅ PASS: S4 one done numbered spec (exit=0)
	✅ PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
	✅ PASS: S4 stdout contains 'currentDone=1'

--- S5: first adoption with one committed in_progress spec in a path containing
spaces ---
	✅ PASS: S5 genuine first adoption (exit=0)
	✅ PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	✅ PASS: S5 stdout contains 'currentDone=0'
	✅ PASS: S5 stdout contains 'historicalDone=0'
	✅ PASS: S5 stdout contains 'historyIntegrity=complete'
	✅ PASS: S5 guard leaves refs, index, worktree, and object inventory unchanged

--- S7: done state changed to in_progress remains established ---
	✅ PASS: S7 changed historical done (exit=1)
	✅ PASS: S7 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S7 stderr contains 'historyPath=specs/001-foo/state.json'
	✅ PASS: S7 stderr contains 'historyCommit='
	✅ PASS: S7 blob privacy stderr omits 'G085_PRIVATE_BLOB_PAYLOAD'

--- S8: deleted done state remains established while another current state remains ---
	✅ PASS: S8 deleted historical done (exit=1)
	✅ PASS: S8 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S8 stderr contains 'historyPath=specs/001-done/state.json'

--- S9: done state reachable only from another local branch is established ---
	✅ PASS: S9 all-ref historical done (exit=1)
	✅ PASS: S9 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S9 stderr contains 'historyPath=specs/001-foo/state.json'
```

```text
--- S11: effective file:// shallow clone fails closed ---
	✅ PASS: S11 fixture is genuinely shallow
	✅ PASS: S11 shallow history (exit=2)
	✅ PASS: S11 stderr contains 'failureCode=E085-HISTORY-SHALLOW'
	✅ PASS: S11 stderr contains 'historyIntegrity=shallow'

--- S12a: extensions.partialClone metadata fails closed as partial history ---
	✅ PASS: S12a extensions.partialClone metadata (exit=2)
	✅ PASS: S12a stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12a stderr contains 'historyIntegrity=partial'
	✅ PASS: S12a stderr contains 'extensions.partialClone metadata is present'

--- S12b: remote.promisor metadata fails closed as partial history ---
	✅ PASS: S12b remote.promisor metadata (exit=2)
	✅ PASS: S12b stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12b stderr contains 'historyIntegrity=partial'
	✅ PASS: S12b stderr contains 'remote promisor metadata is enabled'

--- S14: malformed reachable historical state fails distinctly ---
	✅ PASS: S14 malformed historical state (exit=2)
	✅ PASS: S14 stderr contains 'failureCode=E085-HISTORICAL-STATE-MALFORMED'
	✅ PASS: S14 stderr contains 'historyIntegrity=malformed'
	✅ PASS: S14 stderr contains 'historyPath=specs/001-foo/state.json'

--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
	✅ PASS: S16 current-done guidance
	✅ PASS: S16 genuine first-adoption guidance
	✅ PASS: S16 stale single-path guidance is absent

=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0

🟢 framework-dogfood-guard-selftest: PASSED
```

**Result:** PASS - T-BUG-012-01, T-BUG-012-02, and T-BUG-012-03 are green in
this invocation.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===

	✅ PASS: S1 source repo without specs/ — PASS (exit=0)
	✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
	✅ PASS: S2 stderr cites Gate G085
	✅ PASS: S2 stderr cites source no-specs rule
	✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
	✅ PASS: S3 current-done decision code
	✅ PASS: S4 genuine first adoption — PASS (exit=0)
	✅ PASS: S4 first-adoption decision code
	✅ PASS: S4 proves complete history
	✅ PASS: S5 adversarial repositories have identical current states
	✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
	✅ PASS: S5 historical-done failure code
	✅ PASS: S5 historical state path
	✅ PASS: S6 shallow fixture setup is effective
	✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
	✅ PASS: S6 shallow-history failure code

=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0

🟢 test_04_framework_dogfooding: REGRESSION PASSED
```

**Result:** PASS - T-BUG-012-04, T-BUG-012-05, and T-BUG-012-06 are green in
this invocation.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

<!-- markdownlint-disable MD010 -->

```text
============================================================
	BUBBLES REGRESSION QUALITY GUARD
	Repo: /Users/pkirsanov/Projects/bubbles
	Timestamp: 2026-07-13T21:38:42Z
	Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_04_framework_dogfooding.sh
✅ Adversarial signal detected in tests/regression/test_04_framework_dogfooding.sh

============================================================
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
============================================================
```

**Result:** PASS - the persistent regression has an adversarial signal and zero
quality violations or warnings.

### Resumed Portability And Boundary Evidence

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/macos-portability-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
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

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/framework-dogfood-guard.sh bubbles/scripts/framework-dogfood-guard-selftest.sh bubbles/scripts/guards/tail-delegated-gates.sh tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
== macOS portability guard -- scanning 4 file(s) ==
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

**Result:** PASS - T-BUG-012-07 and the direct four-file portability scan are
green in this invocation.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && if grep -nE '(^|[[:space:]])(git[[:space:]]+(-C[[:space:]]+"?[^[:space:]]+"?[[:space:]]+)?(fetch|checkout|reset|commit|add|rm|update-ref)|curl|wget)([[:space:]]|$)' bubbles/scripts/framework-dogfood-guard.sh; then printf '%s\n' 'FAIL: mutating or network command found'; exit 1; else printf '%s\n' 'PASS: no git fetch command' 'PASS: no git checkout command' 'PASS: no git reset command' 'PASS: no git commit command' 'PASS: no git add command' 'PASS: no git rm command' 'PASS: no git update-ref command' 'PASS: no curl command' 'PASS: no wget command' 'PASS: production guard remains read-only and offline'; fi`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: no git fetch command
PASS: no git checkout command
PASS: no git reset command
PASS: no git commit command
PASS: no git add command
PASS: no git rm command
PASS: no git update-ref command
PASS: no curl command
PASS: no wget command
PASS: production guard remains read-only and offline
```

**Result:** PASS - the implementation remains read-only and offline. The
pre-existing managed-framework dirt observed in GuestHost and Research Lab was
not touched by this invocation; no downstream upgrade or copy command ran.

### Resumed Framework And Release Evidence

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && env -i HOME="$HOME" PATH="/opt/homebrew/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash bubbles/scripts/release-check.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (final 25-line verdict window from the full canonical run):**

```text
stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation passed.
PASS: Framework validation

==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness

==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness

==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)

==> Release manifest freshness
Release manifest is current: 7.20.0 (611 managed files)
PASS: Release manifest freshness

==> Required release files
PASS: Required release files

==> No stray temp or backup files
PASS: No stray temp or backup files

Release check passed.
```

**Result:** PASS - T-BUG-012-08 and T-BUG-012-09 are green in the final
post-edit canonical run. The earlier performance-budget failure did not recur,
the live stale-deferral lint accepted the reconciled packet, and release
metadata remained fresh without regeneration.

### Resumed Consumer And Rollback Evidence

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && grep -nE 'G085-(CURRENT-DONE|FIRST-ADOPTION)|E085-(ESTABLISHED-DONE-REMOVED|HISTORY-(UNAVAILABLE|SHALLOW|PARTIAL|QUERY-FAILED)|HISTORICAL-STATE-MALFORMED)' bubbles/registry/gates.yaml bubbles/workflows.yaml bubbles/scripts/guards/tail-delegated-gates.sh docs/recipes/framework-dogfood.md docs/Framework_Convergence_Health.md tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (literal direct-consumer lines):**

```text
bubbles/scripts/guards/tail-delegated-gates.sh:30:    info "Downstream/fixture pass path G085-CURRENT-DONE: at least one current specs/[0-9]*-*/state.json has exact top-level \"status\": \"done\""
bubbles/scripts/guards/tail-delegated-gates.sh:31:    info "Downstream/fixture pass path G085-FIRST-ADOPTION: genuine first adoption has current numbered states, zero current done, complete exact-root non-shallow/non-partial local Git history, and zero reachable historical numbered top-level done states"
docs/recipes/framework-dogfood.md:35:| Downstream or hermetic fixture repository | `G085-CURRENT-DONE`: at least one current `specs/[0-9]*-*/state.json` has exact top-level `status: done`; or `G085-FIRST-ADOPTION`: current numbered states exist, current done is zero, local Git history is complete, and every reachable ref contains zero numbered top-level done-state blobs | No current numbered state; reachable historical done evidence with zero current done; malformed state; or unavailable, shallow, partial, malformed, or failed history evidence |
docs/recipes/framework-dogfood.md:46:   `G085-CURRENT-DONE`. This fast path does not require Git history.
docs/recipes/framework-dogfood.md:55:   `E085-ESTABLISHED-DONE-REMOVED` and identify its commit and path without
docs/recipes/framework-dogfood.md:58:   `G085-FIRST-ADOPTION`, reporting `currentDone=0`, `historicalDone=0`, and
tests/regression/test_04_framework_dogfooding.sh:201:assert_stdout_contains "S3 current-done decision code" "$stdout_done" "decisionCode=G085-CURRENT-DONE"
tests/regression/test_04_framework_dogfooding.sh:217:assert_stdout_contains "S4 first-adoption decision code" "$stdout_first_adoption" "decisionCode=G085-FIRST-ADOPTION"
tests/regression/test_04_framework_dogfooding.sh:239:assert_stderr_contains "S5 historical-done failure code" "$stderr_historical_done" "failureCode=E085-ESTABLISHED-DONE-REMOVED"
tests/regression/test_04_framework_dogfooding.sh:270:assert_stderr_contains "S6 shallow-history failure code" "$stderr_shallow" "failureCode=E085-HISTORY-SHALLOW"
```

**Result:** PASS - direct consumers carry the two pass paths and fail-closed
history contract; S16 rejects the obsolete single-path guidance.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash install.sh --help`
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** The explicit installer `REF` interface preserves the
design's release-level rollback mechanism by allowing installation of a prior
validated ref. The guard itself persists no state requiring data restoration.
**Output:**

```text
Usage: install.sh [REF] [OPTIONS]

	REF                Git ref to install (default: main)
	--bootstrap        Scaffold project config files after install
	--profile ID       Select bootstrap adoption profile (foundation, delivery, or
 assured)
	--cli ./foo.sh     Set CLI entrypoint (auto-detected if omitted)
	--name "My Proj"   Set project name (auto-detected if omitted)
	--agents-only      Skip shared instructions and skills
	--local-source DIR Install into this downstream repo from a local Bubbles checkout instead of GitHub
```

**Result:** PASS - the release-level rollback interface remains available.

### Resumed Packet And State Evidence

**Phase:** implement
**Executed:** YES (in current invocation)
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 1:** 0
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 2:** 0
**Command 3:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 3:** 0
**Claim Source:** executed
**Output (literal verdict windows):**

```text
=== Anti-Fabrication Evidence Checks ===
✅ All checked DoD items in scopes.md have evidence blocks
✅ No unfilled evidence template placeholders in scopes.md
✅ No unfilled evidence template placeholders in report.md

=== End Anti-Fabrication Checks ===

Artifact lint PASSED.
--- Check 1: Freshness Boundary Isolation (spec.md / design.md) ---
ℹ️  spec.md has no superseded/suppressed sections
ℹ️  design.md has no superseded/suppressed sections
ℹ️  No spec/design freshness boundaries detected
--- Check 2: Superseded Scope Sections Are Non-Executable ---
ℹ️  scopes.md has no superseded scope section
ℹ️  No superseded scope sections detected
--- Check 4: Result ---
RESULT: PASS (0 failures, 0 warnings)
```

```text
--- Traceability Summary ---
ℹ️  Scenarios checked: 4
ℹ️  Test rows checked: 9
ℹ️  Scenario-to-row mappings: 4
ℹ️  Concrete test file references: 4
ℹ️  Report evidence references: 4
ℹ️  DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=4 inferred=0 ambiguous=4

RESULT: PASSED (0 warnings)
```

**Result:** PASS - packet lint, freshness, and traceability are green after the
fresh evidence and DoD edits.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/implementation-reality-scan.sh improvements/BUG-012-g085-first-adoption-deadlock --verbose`
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** Six implementation-bearing files are scanned with zero
violations. The single advisory concerns scanner discovery metadata in the
planning-owned scope shape, not an implementation defect; the design fallback
paths were manually checked against the declared Change Boundary.
**Output:**

```text
ℹ️  INFO: Scopes yielded 0 files — falling back to design.md for file discovery
⚠️  WARN: Resolved 6 file(s) from design.md fallback — scopes.md should reference these directly
ℹ️  INFO: Resolved 6 implementation file(s) to scan

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
--- Scan 7: IDOR / Auth Bypass Detection (Gate G047) ---
--- Scan 8: Silent Decode Failure Detection (Gate G048) ---

============================================================
	IMPLEMENTATION REALITY SCAN RESULT
============================================================

	Files scanned:  6
	Violations:     0
	Warnings:       1

🟡 PASSED with 1 warning(s) — manual review advised
```

**Result:** PASS with one nonblocking planning-link observation - no defaults,
stubs, fake data, client-storage, interception, or implementation-depth violation
is found in the resolved BUG-012 surface.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'BUG-012 declared implementation paths:' && for file_path in bubbles/scripts/framework-dogfood-guard.sh bubbles/scripts/framework-dogfood-guard-selftest.sh bubbles/scripts/guards/tail-delegated-gates.sh tests/regression/test_04_framework_dogfooding.sh bubbles/registry/gates.yaml bubbles/workflows.yaml docs/recipes/framework-dogfood.md docs/Framework_Convergence_Health.md bubbles/release-manifest.json BUGS.md; do if git status --short -- "$file_path" | grep -q .; then printf 'CHANGED %s\n' "$file_path"; else printf 'UNCHANGED %s\n' "$file_path"; fi; done && printf '%s\n' 'Excluded downstream managed copies:' && for repo_root in /Users/pkirsanov/Projects/QuantitativeFinance /Users/pkirsanov/Projects/GuestHost /Users/pkirsanov/Projects/WanderAide /Users/pkirsanov/Projects/smackerel /Users/pkirsanov/Projects/research-lab; do count=$(git -C "$repo_root" status --short -- .github/bubbles .github/agents .github/prompts .github/skills .github/instructions 2>/dev/null | wc -l | tr -d ' '); printf 'OBSERVED %s managed-path-dirty-count=%s\n' "$repo_root" "$count"; done`
**Exit Code 1:** 0
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && jq -S -c '.certification' improvements/BUG-012-g085-first-adoption-deadlock/state.json | shasum -a 256 && printf '%s\n' 'expected=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560' 'PASS: certification fingerprint unchanged after execution-cursor reconciliation'`
**Exit Code 2:** 0
**Claim Source:** interpreted
**Interpretation:** BUG-012's changed canonical paths are within the declared
families. GuestHost and Research Lab already contain unrelated managed-path dirt,
which was observed but not modified. The identical certification hash before and
after execution-cursor reconciliation proves no validate-owned field changed.
**Output:**

```text
BUG-012 declared implementation paths:
CHANGED bubbles/scripts/framework-dogfood-guard.sh
CHANGED bubbles/scripts/framework-dogfood-guard-selftest.sh
CHANGED bubbles/scripts/guards/tail-delegated-gates.sh
CHANGED tests/regression/test_04_framework_dogfooding.sh
CHANGED bubbles/registry/gates.yaml
CHANGED bubbles/workflows.yaml
CHANGED docs/recipes/framework-dogfood.md
CHANGED docs/Framework_Convergence_Health.md
CHANGED bubbles/release-manifest.json
CHANGED BUGS.md
Excluded downstream managed copies:
OBSERVED /Users/pkirsanov/Projects/QuantitativeFinance managed-path-dirty-count=0
OBSERVED /Users/pkirsanov/Projects/GuestHost managed-path-dirty-count=40
OBSERVED /Users/pkirsanov/Projects/WanderAide managed-path-dirty-count=0
OBSERVED /Users/pkirsanov/Projects/smackerel managed-path-dirty-count=0
OBSERVED /Users/pkirsanov/Projects/research-lab managed-path-dirty-count=46
0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560  -
expected=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
PASS: certification fingerprint unchanged after execution-cursor reconciliation
```

**Result:** PASS - execution-state reconciliation preserves certification and
the declared narrow repair boundary; unrelated dirty changes remain unattributed
and untouched.

<!-- markdownlint-restore MD010 -->

## Final Transition Guard Handoff

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && env -i HOME="$HOME" PATH="/opt/homebrew/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" /opt/homebrew/bin/bash bubbles/scripts/cli.sh guard improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code:** 1
**Claim Source:** executed
**Output (selected blocker and verdict lines from the full unfiltered run):**

```text
PASS: policySnapshot records allowed provenance values
PASS: Scenario-first TDD red→green ordering is recorded in the scope/report artifacts (mode source: repo-default)
PASS: Implementation delta evidence recorded with git-backed proof and non-artifact file paths (Gate G053)
BLOCK: Resolved scope artifacts have 2 scope(s) still marked 'In Progress' — ALL scopes must be Done
BLOCK: Required phase 'test' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'regression' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'simplify' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'stabilize' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'security' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'validate' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'audit' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Scope is missing DoD item for scenario-specific regression E2E coverage: Scope 1: Fail-Closed G085 First-Adoption Classification
BLOCK: Scope is missing DoD item for broader E2E regression suite coverage: Scope 1: Fail-Closed G085 First-Adoption Classification
BLOCK: Scope renames/removes interfaces but is missing DoD item for consumer impact sweep: Scope 1: Fail-Closed G085 First-Adoption Classification
BLOCK: Scope is a refactor/repair but is missing the change-boundary DoD item: scopes.md
BLOCK: Scope is a refactor/repair but does not enumerate allowed and excluded surfaces: scopes.md
BLOCK: Execution/certification phases claim implement/test phases but completedScopes is EMPTY — FABRICATION (Gate G027)
BLOCK: Execution/certification phases claim implement/test phases but ZERO scopes are marked 'Done' — FABRICATION (Gate G027)
BLOCK: Retro convergence health failed — Gate G090.
TRANSITION BLOCKED: 20 failure(s), 1 warning(s)
failedGateIds: [G022,G085,G027,G090]
blockingCode: DELIVERY_COMPLETION_FAILED
exitStatus: 1
verdict: FAIL
```

**Result:** FAIL for terminal promotion, with all implementation-owned guard
shape findings closed: G055 provenance, G060 RED-before-GREEN ordering, and G053
code-diff evidence now pass. The remaining planning findings require new or
rewritten DoD/planning content and therefore belong to `bubbles.plan`. The seven
missing phases require their named specialists. Scope completion and
`certification.*` remain validate-owned. The aggregate envelope lists G085 while
the dedicated Check 26 reports PASS; the unresolved G085-class findings are the
scenario-specific regression planning requirements, not a production-guard
behavior failure.

**Phase:** implement
**Executed:** YES (in current invocation)
**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' '=== G090 DIAGNOSTIC START ===' 'feature=improvements/BUG-012-g085-first-adoption-deadlock' 'repoRoot=/Users/pkirsanov/Projects/bubbles' 'requiredInput=.specify/memory/bubbles.session.json'; if [[ -f .specify/memory/bubbles.session.json ]]; then printf '%s\n' 'sessionInput=present'; else printf '%s\n' 'sessionInput=missing'; fi; printf '%s\n' 'invoking=retro-convergence-health.sh'; set +e; env -i HOME="$HOME" PATH="/opt/homebrew/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" /opt/homebrew/bin/bash bubbles/scripts/retro-convergence-health.sh improvements/BUG-012-g085-first-adoption-deadlock --repo-root /Users/pkirsanov/Projects/bubbles; diagnostic_exit=$?; set -e; printf '%s\n' "diagnosticExit=$diagnostic_exit" 'expectedResolution=provide a real session JSON snapshot' 'mutationPerformed=no' '=== G090 DIAGNOSTIC END ==='; [[ "$diagnostic_exit" -eq 1 ]]`
**Exit Code:** 1 for the assertion wrapper; diagnostic exit `2`
**Claim Source:** executed
**Output:**

```text
=== G090 DIAGNOSTIC START ===
feature=improvements/BUG-012-g085-first-adoption-deadlock
repoRoot=/Users/pkirsanov/Projects/bubbles
requiredInput=.specify/memory/bubbles.session.json
sessionInput=missing
invoking=retro-convergence-health.sh
retro-convergence-health: session JSON not found: /Users/pkirsanov/Projects/bubbles/.specify/memory/bubbles.session.json
diagnosticExit=2
expectedResolution=provide a real session JSON snapshot
mutationPerformed=no
=== G090 DIAGNOSTIC END ===
```

**Result:** BLOCKED - G090 cannot be reconstructed honestly because the required
session snapshot is absent. No synthetic convergence counters were written.

### Remaining Finding Accounting

| Finding | Status | Required owner |
| --- | --- | --- |
| `BUG012-PLAN-REGRESSION-DOD` | Open: scenario-specific and broader E2E regression DoD wording is not recognized, although regression Test Plan rows and executed tests exist | `bubbles.plan` |
| `BUG012-PLAN-CONSUMER-DOD` | Open: consumer-impact DoD wording is not recognized | `bubbles.plan` |
| `BUG012-PLAN-CHANGE-BOUNDARY` | Open: change-boundary DoD wording and allowed/excluded enumeration are not recognized | `bubbles.plan` |
| `BUG012-SPECIALIST-PHASES` | Open: `test`, `regression`, `simplify`, `stabilize`, `security`, `validate`, and `audit` have not executed | named phase owners |
| `BUG012-SCOPE-CERTIFICATION` | Open: scope remains `In Progress`, `completedScopes` remains empty, and G027 blocks terminal coherence | `bubbles.validate` after prerequisite phases |
| `BUG012-G090-SESSION` | Blocked: `.specify/memory/bubbles.session.json` is absent | workflow/session owner |
| `BUG012-EVIDENCE-SIGNAL-WARNING` | Advisory: 18 of 30 report evidence blocks lack terminal-output signals under the guard heuristic | `bubbles.audit` review |
| `BUG012-REALITY-DISCOVERY-WARNING` | Advisory: reality scan resolves six files through `design.md` fallback because scope discovery yields none | `bubbles.plan` |
| `BUG012-DEPRECATED-SCOPE-PROGRESS` | Advisory: artifact lint reports validate-owned `certification.scopeProgress` as deprecated | `bubbles.validate` |

## Independent Test Verification - 2026-07-13

This section records only the fresh `bubbles.test` execution after the
implementation handoff. The packet and scope remain `in_progress`; no
certification, Done status, commit, push, release, downstream upgrade, or
installed-copy result is claimed. Full structured command records use session
`bug012-test-20260713T223939Z` in `.specify/runtime/tool-calls.jsonl`.

<!-- markdownlint-disable MD010 -->

### Independent Focused Matrix Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh` (executed through `bubbles/scripts/tool-log.sh` with BUG-012 test metadata)
**Exit Code:** 0
**Claim Source:** executed
**Output (literal assertion windows from the fresh run):**

```text
--- S0: source repo has no specs/ and evidence surfaces exist ---
	✅ PASS: S0 source repo without specs/ (exit=0)
	✅ PASS: S0 stdout contains 'PASS Gate G085'
	✅ PASS: S0 stdout contains 'source repo has no persistent specs/'
--- S3: downstream specs/ exists, zero numbered feature state.json ---
	✅ PASS: S3 zero numbered state.json (exit=1)
	✅ PASS: S3 stderr contains 'failureCode=E085-NO-CURRENT-SPEC'
	✅ PASS: S3 stderr contains 'currentSpecs=0'
--- S4: one done numbered spec ---
	✅ PASS: S4 one done numbered spec (exit=0)
	✅ PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
	✅ PASS: S4 stdout contains 'currentDone=1'
--- S5: first adoption with one committed in_progress spec in a path containing spaces ---
	✅ PASS: S5 genuine first adoption (exit=0)
	✅ PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	✅ PASS: S5 stdout contains 'currentDone=0'
	✅ PASS: S5 stdout contains 'historicalDone=0'
	✅ PASS: S5 stdout contains 'historyIntegrity=complete'
	✅ PASS: S5 guard leaves refs, index, worktree, and object inventory unchanged
--- S6: malformed state.json (invalid JSON) ---
	✅ PASS: S6 malformed state.json (exit=2)
	✅ PASS: S6 stderr contains 'failureCode=E085-CURRENT-STATE-MALFORMED'
--- S7: done state changed to in_progress remains established ---
	✅ PASS: S7 changed historical done (exit=1)
	✅ PASS: S7 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S7 stderr contains 'historyPath=specs/001-foo/state.json'
	✅ PASS: S7 stderr contains 'historyCommit='
	✅ PASS: S7 blob privacy stderr omits 'G085_PRIVATE_BLOB_PAYLOAD'
--- S8: deleted done state remains established while another current state remains ---
	✅ PASS: S8 deleted historical done (exit=1)
	✅ PASS: S8 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S8 stderr contains 'historyPath=specs/001-done/state.json'
--- S9: done state reachable only from another local branch is established ---
	✅ PASS: S9 all-ref historical done (exit=1)
	✅ PASS: S9 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S9 stderr contains 'historyPath=specs/001-foo/state.json'
--- S10: missing Git metadata and nested requested root fail unavailable ---
	✅ PASS: S10 missing Git metadata (exit=2)
	✅ PASS: S10 missing stderr contains 'failureCode=E085-HISTORY-UNAVAILABLE'
	✅ PASS: S10 nested root (exit=2)
	✅ PASS: S10 nested stderr contains 'failureCode=E085-HISTORY-UNAVAILABLE'
	✅ PASS: S10 nested stderr contains 'not the exact Git worktree root'
--- S11: effective file:// shallow clone fails closed ---
	✅ PASS: S11 fixture is genuinely shallow
	✅ PASS: S11 shallow history (exit=2)
	✅ PASS: S11 stderr contains 'failureCode=E085-HISTORY-SHALLOW'
	✅ PASS: S11 stderr contains 'historyIntegrity=shallow'
--- S12a: extensions.partialClone metadata fails closed as partial history ---
	✅ PASS: S12a extensions.partialClone metadata (exit=2)
	✅ PASS: S12a stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12a stderr contains 'historyIntegrity=partial'
	✅ PASS: S12a stderr contains 'extensions.partialClone metadata is present'
--- S12b: remote.promisor metadata fails closed as partial history ---
	✅ PASS: S12b remote.promisor metadata (exit=2)
	✅ PASS: S12b stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12b stderr contains 'historyIntegrity=partial'
	✅ PASS: S12b stderr contains 'remote promisor metadata is enabled'
--- S13: broken reachable ref fails commit traversal ---
	✅ PASS: S13 failed reachable-ref traversal (exit=2)
	✅ PASS: S13 commit stderr contains 'failureCode=E085-HISTORY-QUERY-FAILED'
--- S13: missing historical tree object fails closed ---
	✅ PASS: S13 failed historical tree traversal (exit=2)
	✅ PASS: S13 tree stderr contains 'failureCode=E085-HISTORY-QUERY-FAILED'
--- S13: missing historical state blob fails closed ---
	✅ PASS: S13 failed historical blob traversal (exit=2)
	✅ PASS: S13 blob stderr contains 'failureCode=E085-HISTORY-QUERY-FAILED'
--- S14: malformed reachable historical state fails distinctly ---
	✅ PASS: S14 malformed historical state (exit=2)
	✅ PASS: S14 stderr contains 'failureCode=E085-HISTORICAL-STATE-MALFORMED'
	✅ PASS: S14 stderr contains 'historyIntegrity=malformed'
	✅ PASS: S14 stderr contains 'historyPath=specs/001-foo/state.json'
--- S15: non-numbered and nested done evidence are ignored ---
	✅ PASS: S15 ignored non-numbered and nested done (exit=0)
	✅ PASS: S15 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	✅ PASS: S15 stdout contains 'historicalDone=0'
--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
	✅ PASS: S16 current-done guidance
	✅ PASS: S16 genuine first-adoption guidance
	✅ PASS: S16 stale single-path guidance is absent
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
```

**Result:** PASS - the production guard was exercised against real disposable
Git repositories for every planned decision and integrity branch. This directly
proves current done, first adoption, changed/deleted/alternate-ref history,
empty and malformed state, exact-root, shallow, both partial-history markers,
all three traversal failures, malformed history, canonical source, delegated
guidance, read-only repository state, and blob-payload privacy.

### Independent Persistent Regression Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command:** `bash tests/regression/test_04_framework_dogfooding.sh` (executed through `bubbles/scripts/tool-log.sh` with BUG-012 test metadata)
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===
	✅ PASS: S1 source repo without specs/ — PASS (exit=0)
	✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
	✅ PASS: S2 stderr cites Gate G085
	✅ PASS: S2 stderr cites source no-specs rule
	✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
	✅ PASS: S3 current-done decision code
	✅ PASS: S4 genuine first adoption — PASS (exit=0)
	✅ PASS: S4 first-adoption decision code
	✅ PASS: S4 proves complete history
	✅ PASS: S5 adversarial repositories have identical current states
	✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
	✅ PASS: S5 historical-done failure code
	✅ PASS: S5 historical state path
	✅ PASS: S6 shallow fixture setup is effective
	✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
	✅ PASS: S6 shallow-history failure code
=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
```

**Result:** PASS - the real production guard distinguishes byte-identical
current states solely by reachable historical done evidence. Reintroducing
either unconditional zero-done rejection or blanket zero-done acceptance makes
one side of the adversarial pair fail.

### Independent Regression Integrity And Authenticity Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command 1:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 1:** 0
**Command 2:** read-only assertion audit over the two required tests and production guard
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
BUG-012 TEST AUTHENTICITY AUDIT
PASS: selftest invokes production GUARD subprocess
PASS: persistent regression invokes production GUARD subprocess
PASS: selftest uses disposable mktemp workspace
PASS: persistent regression uses disposable mktemp repositories
PASS: selftest initializes real Git repositories
PASS: persistent regression initializes real Git repositories
PASS: selftest creates real Git commits
PASS: persistent regression creates real Git commits
PASS: selftest creates an effective depth-1 file clone
PASS: persistent regression creates an effective depth-1 file clone
PASS: adversarial pair asserts byte-identical current states
PASS: privacy assertion rejects historical blob payload disclosure
PASS: read-only assertion compares repository snapshots
PASS: no mock or interception APIs in required tests
PASS: no disabled/skip/only/todo markers in required tests
PASS: tests do not duplicate production Git-history traversal
PASS: production guard contains no mutating or network command
AUTHENTICITY_AUDIT_FAILURES=0
```

**Result:** PASS - no mocked classifier/Git/state parser, interception API,
disabled test, duplicated history traversal, mutating Git command, network
command, silent-pass bailout, or self-validating classifier assertion remains.

### Independent Scenario And Test Plan Parity Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command:** read-only exact-ID parity assertion plus `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
SCENARIO_COUNT=4
JSON_TEST_ROW_COUNT=10
MARKDOWN_TEST_ID_COUNT=10
DOD_REFERENCED_TEST_ID_COUNT=10
PASS scenario parity: SCN-BUG-012-001
PASS scenario parity: SCN-BUG-012-002
PASS scenario parity: SCN-BUG-012-003
PASS scenario parity: SCN-BUG-012-004
PASS Test Plan/DoD parity: T-BUG-012-01 -> bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS Test Plan/DoD parity: T-BUG-012-02 -> bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS Test Plan/DoD parity: T-BUG-012-03 -> bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS Test Plan/DoD parity: T-BUG-012-04 -> tests/regression/test_04_framework_dogfooding.sh
PASS Test Plan/DoD parity: T-BUG-012-05 -> tests/regression/test_04_framework_dogfooding.sh
PASS Test Plan/DoD parity: T-BUG-012-06 -> tests/regression/test_04_framework_dogfooding.sh
PASS Test Plan/DoD parity: T-BUG-012-07 -> bubbles/scripts/macos-portability-guard-selftest.sh
PASS Test Plan/DoD parity: T-BUG-012-08 -> bubbles/scripts/cli.sh
PASS Test Plan/DoD parity: T-BUG-012-09 -> bubbles/scripts/cli.sh
PASS Test Plan/DoD parity: T-BUG-012-10 -> tests/regression/test_04_framework_dogfooding.sh
PARITY_FAILURES=0
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
```

**Result:** PASS - coverage is 4/4 scenarios and 10/10 planned test rows, with
one matching DoD test item and a physical test file for every row.

### Independent Portability Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command 1:** `bash bubbles/scripts/macos-portability-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/framework-dogfood-guard.sh bubbles/scripts/framework-dogfood-guard-selftest.sh bubbles/scripts/guards/tail-delegated-gates.sh tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
PASS: guard parses (bash -n)
PASS: guard is self-portable (guard scans its own source -> exit 0)
PASS: guard source (comments stripped) has no literal GNU-only form
[selftest macos-portability-guard] OK — all assertions passed.
== macOS portability guard -- scanning 4 file(s) ==
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

**Result:** PASS - the canonical selftest and direct four-file scan are green
on macOS.

### Independent Framework, Release, And Packet Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command 1:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code 2:** 0
**Command 3:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 3:** 0
**Command 4:** `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 4:** 0
**Command 5:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 5:** 0
**Claim Source:** executed
**Output (literal final windows; full framework/release stdout hashes are in the tool log):**

```text
stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)
Framework validation passed.
[tool-log] recorded exit=0 duration=1802576ms
Framework validation passed.
PASS: Framework validation
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness
PASS: Cheatsheet freshness (v6.0 / B7)
Release manifest is current: 7.20.0 (611 managed files)
PASS: Release manifest freshness
PASS: Required release files
PASS: No stray temp or backup files
Release check passed.
[tool-log] recorded exit=0 duration=1476455ms
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
Scenarios checked: 4
Test rows checked: 10
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
```

**Result:** PASS - full framework validation, release readiness, artifact lint,
freshness, and traceability are green. The framework source is observability
`EXEMPT (no-runtime)`, so trace/SLO capture is correctly not applicable. The
artifact lint advisory for deprecated validate-owned
`certification.scopeProgress` remains preserved rather than mutated here.

### Independent Preservation Evidence

**Phase:** test
**Executed:** YES (in current invocation)
**Command:** certification-block and dirty-tree SHA-256 comparison with current planner timestamps and packet status
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
CERTIFICATION_BASELINE_SHA256=3814561a4fdcffd2de72cf9be26616930d9a7e0b13aaedc48dc007162c177b64
CERTIFICATION_CURRENT_SHA256=3814561a4fdcffd2de72cf9be26616930d9a7e0b13aaedc48dc007162c177b64
PROTECTED_TREE_BASELINE_SHA256=a1a1a521e820cff2b26799f8ca9d2e24fb30023b8acdbbd5a9cdfb49dc48c5f5
PROTECTED_TREE_CURRENT_SHA256=f5121d8547d317132dc7baecc8ed2781cfda9b082413c1ec553583e3466f2b30
PASS: certification bytes are unchanged
OBSERVED: protected tree changed concurrently; no byte-identity claim is made
CURRENT_SCENARIO_MANIFEST_GENERATED_AT=2026-07-13T23:45:00Z
CURRENT_TEST_PLAN_GENERATED_AT=2026-07-13T23:45:00Z
CURRENT_TEST_ROWS=10
PACKET_STATUS=in_progress
CERTIFICATION_STATUS=in_progress
FINAL_TEST_TIMESTAMP=2026-07-13T23:54:39Z
PRESERVATION_RECORD=HONEST
```

**Result:** PASS for the owned preservation contract - the complete
`certification` block is byte-identical and both statuses remain
`in_progress`. The whole-tree hashes intentionally differ because a concurrent
planner updated BUG-012 `scopes.md`, `test-plan.json`, and
`scenario-manifest.json` at `23:45:00Z`; those edits were read, revalidated,
and preserved. No reset, commit, push, downstream upgrade, or edit outside
BUG-012 `report.md` and `state.json::execution*` was performed by this test
phase.

### Independent Test Disposition

All ten current planned test rows are green, with zero test or production-guard defect
found. The concurrent planner has reconciled the planning-shape findings into
the current 10-row handoff, while the historical finding table remains
preserved. G090 session input, remaining specialist phases, scope promotion,
and certification remain outside this test phase. This is a non-certifying
`route_required` handoff to `bubbles.validate`; no `certification.*` field is
rewritten here.

<!-- markdownlint-restore MD010 -->

## Independent Validation Review - 2026-07-14

This review consumed the finalized ten-row planning packet and the independent
test evidence recorded above. It did not reclassify prior test execution as a
validate-phase run. No provisional status write was needed because the
transition guard accepts an explicit target plus fresh contract assertions.
The scope, packet status, and every `certification.*` value remain unchanged.

### Outcome Contract Verification (G070)

**Phase:** validate
**Claim Source:** interpreted
**Interpretation:** `spec.md` contains `## Problem Contract`, requirements, and
acceptance scenarios, but it does not contain the required `## Outcome Contract`
section or declared `Intent`, `Success Signal`, `Hard Constraints`, and
`Failure Condition` fields. Existing behavior evidence cannot substitute for a
missing analyst-owned declaration.

| Field | Declared | Evidence | Status |
| --- | --- | --- | --- |
| Intent | Not declared in an Outcome Contract | Existing Problem Contract is not the required field | FAIL |
| Success Signal | Not declared in an Outcome Contract | Current test evidence demonstrates behavior but cannot supply the missing declaration | FAIL |
| Hard Constraints | Not declared in an Outcome Contract | Constraints exist elsewhere but are not extracted or relabeled by validate | FAIL |
| Failure Condition | Not declared in an Outcome Contract | No canonical field is available to evaluate | FAIL |

### Current Packet Mechanics

**Phase:** validate
**Executed:** YES (current validation invocation)
**Command 1:** `bash bubbles/scripts/transition-contract-resolver.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 2:** 0
**Command 3:** `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 3:** 0
**Command 4:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 4:** 0
**Claim Source:** executed
**Output (literal verdict signals from the full recorded commands):**

```text
workflowMode=bugfix-fastlane
auditProfile=delivery-completion-v1
targetStatus=done
contractDigest=sha256:aa91472c047d3d985d38c1d308feb1e6081955b2aa553816deb5987d9cdc449f
Artifact lint PASSED.
state.json uses deprecated field 'scopeProgress'
RESULT: PASS (0 failures, 0 warnings)
scenario-manifest.json covers 4 scenario contract(s)
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
```

**Result:** PASS for packet structure, freshness, and ten-row traceability. The
deprecated validate-owned `certification.scopeProgress` field remains a
nonblocking advisory and was not changed during a failed certification review.

### Contemplated Done Transition

**Phase:** validate
**Executed:** YES (current validation invocation)
**Command:** `bash bubbles/scripts/state-transition-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --target-status done --expect-workflow-mode bugfix-fastlane --expect-contract-digest sha256:aa91472c047d3d985d38c1d308feb1e6081955b2aa553816deb5987d9cdc449f`
**Exit Code:** 1
**Claim Source:** executed
**Output (terminal verdict window from the final current-byte guard run):**

```text
DoD items total: 23 (checked: 19, unchecked: 4)
BLOCK: Resolved scope artifacts have 4 UNCHECKED DoD items - ALL must be [x] for 'done'
BLOCK: Required phase 'regression' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'simplify' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'stabilize' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'security' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'validate' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'audit' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Execution/certification phases claim implement/test phases but completedScopes is EMPTY - FABRICATION (Gate G027)
BLOCK: Execution/certification phases claim implement/test phases but ZERO scopes are marked 'Done' - FABRICATION (Gate G027)
BLOCK: Retro convergence health failed - Gate G090.
TRANSITION BLOCKED: 12 failure(s), 1 warning(s)
failedGateIds: [G022,G027,G090]
failedChecks: [Check-4-completion,Check-5-all-done]
blockingCode: DELIVERY_COMPLETION_FAILED
failureCount: 12
exitStatus: 1
verdict: FAIL
```

**Result:** FAIL. The guard confirms that the earlier planning-shape findings
are closed, but terminal certification is mechanically prohibited.

### G090 Session Snapshot Diagnostic

**Phase:** validate
**Executed:** YES (current validation invocation)
**Command:** `bash bubbles/scripts/retro-convergence-health.sh improvements/BUG-012-g085-first-adoption-deadlock --repo-root /Users/pkirsanov/Projects/bubbles --format json`
**Exit Code:** 2
**Claim Source:** executed
**Output:**

```text
featureDir=improvements/BUG-012-g085-first-adoption-deadlock
repoRoot=/Users/pkirsanov/Projects/bubbles
requiredSession=/Users/pkirsanov/Projects/bubbles/.specify/memory/bubbles.session.json
sessionInput=missing
execution=begin
retro-convergence-health: session JSON not found: /Users/pkirsanov/Projects/bubbles/.specify/memory/bubbles.session.json
execution=end
g090Exit=2
snapshotSynthesized=no
statusMutation=no
requiredUnblock=real readable session JSON with complete BUG-012-attributed start/end snapshots
```

**Result:** BLOCKED. No narrative or synthetic convergence counters were used
as a substitute for the absent session input.

### Validation Finding Accounting

| Finding | Severity | Owner | Unblock condition |
| --- | --- | --- | --- |
| `BUG012-VAL-G070` | blocker | `bubbles.analyst` | Add the canonical Outcome Contract fields without changing delivered behavior, then re-run validation review |
| `BUG012-VAL-DOD-HANDOFF` | blocker | `bubbles.test` | Reconcile current independent evidence against all four finalized unchecked items, attach exact evidence references, and leave none unchecked |
| `BUG012-VAL-G022-REGRESSION` | blocker | `bubbles.regression` | Execute and record the required regression phase after the finalized test handoff |
| `BUG012-VAL-G022-SIMPLIFY` | blocker | `bubbles.simplify` | Execute and record the required simplify phase after regression |
| `BUG012-VAL-MODE-GAPS` | blocker | `bubbles.gaps` | Execute and record the mode-ordered gaps phase |
| `BUG012-VAL-MODE-HARDEN` | blocker | `bubbles.harden` | Execute and record the mode-ordered harden phase |
| `BUG012-VAL-G022-STABILIZE` | blocker | `bubbles.stabilize` | Execute and record the required stabilize phase in workflow order |
| `BUG012-VAL-MODE-DEVOPS` | blocker | `bubbles.devops` | Execute and record the mode-ordered devops phase |
| `BUG012-VAL-G022-SECURITY` | blocker | `bubbles.security` | Execute and record the required security phase in workflow order |
| `BUG012-VAL-G022-VALIDATE` | blocker | `bubbles.validate` | Re-run deep validation only after prior required owners and G090 input are complete |
| `BUG012-VAL-G022-AUDIT` | blocker | `bubbles.audit` | Produce the current delivery audit result after validation passes |
| `BUG012-VAL-MODE-FINALIZE` | blocker | authorized top-level runner | Run finalize only after a current successful audit and fresh resolver/guard assertions exist |
| `BUG012-VAL-G027` | blocker | `bubbles.validate` | Certify scope completion only after every DoD item and prerequisite phase is complete and the guard exits 0 |
| `BUG012-VAL-G090` | blocker | authorized top-level session owner | Supply a real readable session snapshot with complete BUG-012-attributed start/end records; do not reconstruct it from prose |
| `BUG012-VAL-EVIDENCE-SIGNALS` | warning | `bubbles.audit` | Review the final guard advisory that 23 of 40 report evidence blocks lack terminal-output signals |
| `BUG012-VAL-REALITY-DISCOVERY` | warning | `bubbles.plan` | Review the existing implementation-file discovery fallback from scopes to design; the reality scan itself remains green |
| `BUG012-VAL-SCOPE-PROGRESS` | warning | `bubbles.validate` | Remove deprecated `certification.scopeProgress` only during a legitimate certification-state reconciliation |

### Validation Disposition

Outcome is `route_required`, not certification. Although the current execution
cursor records `bubbles.test`, G070 exposes an earlier unresolved bootstrap
owner: `bubbles.analyst` must supply the missing Outcome Contract first. Test
reconciliation and every subsequent mode phase remain unresolved. No scope/spec
status or certification field was changed.

## Finalized Independent-Test Reconciliation - 2026-07-14

This section records only commands executed after G070 was resolved and after
the four finalized `Independent-test handoff` requirements existed. Prior
test-phase transcripts were not reused to mark these items. The packet and
scope remain nonterminal; certification, commit, push, downstream upgrade, and
Done status are not claimed.

<!-- markdownlint-disable MD010 -->

### Finalized Focused Scenario Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== FINALIZED FOCUSED E2E START ===
MAPPINGS=T-BUG-012-04,T-BUG-012-05,T-BUG-012-06,T-BUG-012-10
COMMAND=bash tests/regression/test_04_framework_dogfooding.sh
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===

	✅ PASS: S1 source repo without specs/ — PASS (exit=0)
	✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
	✅ PASS: S2 stderr cites Gate G085
	✅ PASS: S2 stderr cites source no-specs rule
	✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
	✅ PASS: S3 current-done decision code
	✅ PASS: S4 genuine first adoption — PASS (exit=0)
	✅ PASS: S4 first-adoption decision code
	✅ PASS: S4 proves complete history
	✅ PASS: S5 adversarial repositories have identical current states
	✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
	✅ PASS: S5 historical-done failure code
	✅ PASS: S5 historical state path
	✅ PASS: S6 shallow fixture setup is effective
	✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
	✅ PASS: S6 shallow-history failure code

=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0

🟢 test_04_framework_dogfooding: REGRESSION PASSED
FOCUSED_E2E_EXIT=0
```

**Result:** PASS - the one shared executable has four distinct finalized
mappings: T-04 is S1-S4, T-05 is the byte-identical S5 adversary, T-06 is the
effective-shallow S6 refusal, and T-10 is the dedicated S1-S2 canonical-source
pair.

**Phase:** test
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 1:** 0
**Command 2:** token-aware exact assertion/authenticity audit over `tests/regression/test_04_framework_dogfooding.sh` and `bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
ASSERTION SET T-BUG-012-04 / SCN-BUG-012-001
PASS: T04 asserts source-clean exit
PASS: T04 asserts source-with-specs exit
PASS: T04 asserts current-done decision
PASS: T04 asserts first-adoption decision
PASS: T04 asserts complete history
ASSERTION SET T-BUG-012-05 / SCN-BUG-012-002
PASS: T05 compares current files byte-for-byte
PASS: T05 asserts reachable historical done exit
PASS: T05 asserts stable failure code
PASS: T05 asserts historical path identity
ASSERTION SET T-BUG-012-06 / SCN-BUG-012-003
PASS: T06 proves shallow fixture is effective
PASS: T06 asserts integrity exit 2
PASS: T06 asserts shallow failure code
ASSERTION SET T-BUG-012-10 / SCN-BUG-012-004
PASS: T10 source fixture invokes production guard
PASS: T10 source violation invokes production guard
PASS: T10 source violation asserts no-specs rule
AUTHENTICITY AND FALSE-POSITIVE CONTROLS
PASS: persistent regression resolves canonical production guard
PASS: selftest resolves canonical production guard
PASS: no disabled/skip/only/todo markers
PASS: no request interception or mock framework
PASS: no copied production history traversal
PASS: no failure-condition bailout return
AUTHENTICITY_AUDIT_FAILURES=0
BUG-012 focused authenticity audit: PASS
```

**Result:** PASS - the finalized E2E mappings execute the production guard
against disposable Git repositories and contain no skip, bailout, interception,
or duplicated `rev-list`/`ls-tree`/`cat-file` traversal. An initial broad
`xit(` scan matched the helper name `assert_exit`; it exited `1` and was
superseded by the token-aware scan above. That scanner false positive is not
treated as a test defect.

### Finalized Broader Framework Evidence

**Phase:** test
**Executed:** YES (current invocation, after the focused E2E and authenticity checks)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (final literal verdict window from the retained 48 KB transcript):**

```text
FOCUSED_E2E_COMPLETED_BEFORE_BROAD=true
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)

stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation passed.
T_BUG_012_08_EXIT=0
```

**Result:** PASS - T-BUG-012-08 ran as a separate broad command after the
focused scenario rows. Its current result is not inferred from or replaced by
the 16-assertion focused run.

### Finalized Consumer Impact Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`; `bash bubbles/scripts/cli.sh release-check`; exact first-party G085 reference and release-manifest sweep; `bash bubbles/scripts/generate-gates-block.sh --check`; `bash bubbles/scripts/workflow-registry-consistency.sh`
**Exit Codes:** `0`, `0`, `1`, `0`, `0`
**Claim Source:** executed
**Output (focused and release signals):**

```text
--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
	✅ PASS: S16 current-done guidance
	✅ PASS: S16 genuine first-adoption guidance
	✅ PASS: S16 stale single-path guidance is absent
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
T_BUG_012_01_EXIT=0
Framework validation passed.
PASS: Framework validation
Release manifest is current: 7.20.0 (611 managed files)
PASS: Release manifest freshness
PASS: Required release files
PASS: No stray temp or backup files
Release check passed.
T_BUG_012_09_EXIT=0
generate-gates-block: workflows.yaml is in sync with registry (470 registry lines)
GATES_BLOCK_CHECK_EXIT=0
workflow-registry consistency check passed.
WORKFLOW_REGISTRY_EXIT=0
```

**Output (exact first-party sweep discriminator):**

```text
GROUP: delegated and broad callers
PASS: delegated Check 26 names current-done path
PASS: delegated Check 26 names first-adoption path
PASS: framework validation registers focused G085 selftest
PASS: state-transition caller sources delegated tail
FAIL: state-transition caller has no obsolete done-only wrapper prose
FAIL: state-transition caller comment names current-done path
FAIL: state-transition caller comment names first-adoption path
GROUP: registry and operator references
PASS: gate registry names current-done path
PASS: gate registry names first-adoption path
PASS: generated workflow registry names current-done path
PASS: generated workflow registry names first-adoption path
PASS: operator recipe names current-done path
PASS: operator recipe names first-adoption path
PASS: operator recipe rejects mutable marker
PASS: convergence reference names proven first adoption
PASS: current changelog names two explicit pass paths
PASS: current changelog rejects mutable marker
GROUP: release provenance
PASS: managed guard manifest checksum hash=2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4
PASS: managed selftest manifest checksum hash=a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d
PASS: managed recipe manifest checksum hash=20dcac1008dd187b4f5f0e8d0c59bf8e89786275c9e5a5b26df2449177153178
PASS: source-only persistent regression checksum hash=e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6
CONSUMER_SWEEP_FAILURES=3
BUG-012 exact first-party consumer sweep: FAIL
```

**Result:** FAIL - runtime and generated consumers are green, but the active
Check 26 wrapper comment in `bubbles/scripts/state-transition-guard.sh` still
describes only the obsolete "traditional" current-done model. The file is clean
and production-owned, so this test phase did not edit it. Finding
`BUG012-TEST-CONSUMER-001` routes to `bubbles.implement` for the narrow comment
correction and a consumer-sweep rerun.

### Finalized Change Boundary Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** BUG-012 marker-attributed path classification; delegated Check 26 diff classification; downstream managed-projection SHA-256 comparison; NUL-safe unrelated-work preservation audit
**Exit Codes:** `0`, `0`, `0`, `1` (the last command detected two concurrent BUG-013 writes and preserved them)
**Claim Source:** interpreted
**Interpretation:** The behavioral claim is BUG-012 attribution, not global
worktree immobility. All 19 BUG-012 marker-attributed paths are allowed, the
only delegated-gate delta is Check 26 G085 guidance, all five downstream managed
projections retain their baseline hashes, the Git index predates this
invocation, and the only post-baseline unrelated writes are two BUG-013 packet
files owned by another concurrent process. This invocation neither changed nor
reverted those files and does not claim them.
**Output:**

```text
=== BUG-012 MARKER-ATTRIBUTED PATH CLASSIFICATION ===
PASS: allowed BUG-012 marker path: BUGS.md
PASS: allowed BUG-012 marker path: CHANGELOG.md
PASS: allowed BUG-012 marker path: bubbles/registry/gates.yaml
PASS: allowed BUG-012 marker path: bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS: allowed BUG-012 marker path: bubbles/scripts/framework-dogfood-guard.sh
PASS: allowed BUG-012 marker path: bubbles/scripts/guards/tail-delegated-gates.sh
PASS: allowed BUG-012 marker path: bubbles/workflows.yaml
PASS: allowed BUG-012 marker path: docs/Framework_Convergence_Health.md
PASS: allowed BUG-012 marker path: docs/recipes/framework-dogfood.md
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/bug.md
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/design.md
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/report.md
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/scenario-manifest.json
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/scopes.md
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/spec.md
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/state.json
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/test-plan.json
PASS: allowed BUG-012 marker path: improvements/BUG-012-g085-first-adoption-deadlock/uservalidation.md
PASS: allowed BUG-012 marker path: tests/regression/test_04_framework_dogfooding.sh
BUG012_ATTRIBUTED_PATHS=19
ATTRIBUTION_FAILURES=0
BUG-012 marker-attributed Change Boundary: PASS
```

```text
PASS: state-transition guard implementation bytes are clean (stale comment is a consumer defect, not a BUG-012 change)
PASS: tail-delegated-gates.sh diff is limited to G085 downstream guidance
PASS: no mutable adoption marker/cache file was introduced
PASS: QuantitativeFinance managed projection preserved sha256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
PASS: GuestHost managed projection preserved sha256=e2bc5e77dd0ae242b940dafe374ac26861f8ed43e7b203bd3f5b8e8c687961df
PASS: WanderAide managed projection preserved sha256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
PASS: smackerel managed projection preserved sha256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
PASS: research-lab managed projection preserved sha256=37bcaa7e652f33d5ad63e689c14b009218af2eb9f5cd829706d9d7108923dbdf
PASS: Git index predates invocation ctime=1783921958
FAIL: unrelated path changed during invocation: improvements/BUG-013-g028-sensitive-client-storage-classification/report.md ctime=1784004655
FAIL: unrelated path changed during invocation: improvements/BUG-013-g028-sensitive-client-storage-classification/scenario-manifest.json ctime=1784004655
UNRELATED_PATHS_CHECKED=47
PRESERVATION_FAILURES=2
```

**Result:** PASS for the finalized BUG-012 Change Boundary item with
interpreted provenance. Concurrent BUG-013 changes remain visible, preserved,
and unclaimed; they are not attributed to BUG-012 and were not overwritten.

### Finalized Finding Accounting And Disposition

| Finding | Status | Owner |
| --- | --- | --- |
| `BUG012-TEST-AUDIT-001` | Addressed: broad `xit(` scan matched `assert_exit`; token-aware rerun is green | `bubbles.test` |
| `BUG012-TEST-BOUNDARY-001` | Addressed: aggregate unrelated-tree hash changed; per-path audit identified two concurrent BUG-013 writes, preserved and unclaimed | `bubbles.test` |
| `BUG012-TEST-CONSUMER-001` | Open: state-transition Check 26 wrapper comment retains obsolete done-only prose | `bubbles.implement` |
| Existing regression/simplify/gaps/harden/stabilize/devops/security/validate/audit/finalize findings | Preserved; no downstream phase is advanced while the consumer finding remains | existing named owners |
| Existing G027/G090 blockers and advisories | Preserved; no certification or session evidence is synthesized | existing named owners |

**Test verdict:** `NOT_TESTED` for finalized handoff completion because one of
the four required items remains open. Focused scenario E2E, broad framework
validation, and Change Boundary are independently green; Consumer Impact is
not. Required next owner is `bubbles.implement`, not `bubbles.regression`.

### Finalized Execution Metadata And Transition Diagnostic

**Phase:** test
**Executed:** YES (current invocation)
**Command:** JSON/certification fingerprint and execution-history coherence assertions over `improvements/BUG-012-g085-first-adoption-deadlock/state.json`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== FINAL TEST METADATA COHERENCE ===
CERTIFICATION_SHA256=fdf01915da4888a2a2671be092039c91e5b50636cff059934670023f9a88bee8
PASS: certification bytes unchanged
status=in_progress
certification.status=in_progress
scopeProgress=in_progress
completedPhaseClaims=implement
testHistoryEntries=2
nextRequiredOwner=bubbles.implement
PASS: incomplete finalized test phase is not claimed complete
PASS: current test history records route_required
FINAL_TEST_METADATA=COHERENT
```

**Result:** PASS - both test executions remain in `executionHistory`, while
`execution.completedPhaseClaims` no longer claims the finalized test phase is
complete. Packet, scope, and certification statuses remain nonterminal, and the
certification block is byte-identical to the pre-invocation baseline.

**Phase:** test
**Executed:** YES (current invocation; diagnostic only)
**Command:** `bash bubbles/scripts/state-transition-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --target-status done --expect-workflow-mode bugfix-fastlane --expect-contract-digest sha256:aa91472c047d3d985d38c1d308feb1e6081955b2aa553816deb5987d9cdc449f`
**Exit Code:** 1
**Claim Source:** executed
**Output (literal current terminal result):**

```text
MUTATION_FLAG=absent
DoD items total: 23 (checked: 22, unchecked: 1)
BLOCK: Resolved scope artifacts have 1 UNCHECKED DoD items - ALL must be [x] for 'done'
BLOCK: Required phase 'test' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'regression' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'simplify' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'stabilize' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'security' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'validate' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'audit' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Execution/certification phases claim implement/test phases but completedScopes is EMPTY - FABRICATION (Gate G027)
BLOCK: Execution/certification phases claim implement/test phases but ZERO scopes are marked 'Done' - FABRICATION (Gate G027)
BLOCK: Retro convergence health failed - Gate G090.
PASS: Framework dogfood evidence contract is satisfied (Gate G085)
TRANSITION BLOCKED: 13 failure(s), 1 warning(s)
failedGateIds: [G022,G027,G090]
failedChecks: [Check-4-completion,Check-5-all-done]
blockingCode: DELIVERY_COMPLETION_FAILED
failureCount: 13
exitStatus: 1
verdict: FAIL
FINAL_REPORT_ONLY_GUARD_EXIT=1
```

**Result:** EXPECTED BLOCK - the command omitted `--revert-on-fail`, the only
mutating guard option. It confirms G085 is green while the open consumer item,
test and all subsequent required phases, G027, G090, nonterminal scope state,
and the evidence-signal advisory remain intact. No status or certification
write occurred.

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; scoped `git diff --check`
**Exit Codes:** `0`, `0`, `0`, `0`
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
FINAL_ARTIFACT_LINT_EXIT=0
--- Check 1: Freshness Boundary Isolation (spec.md / design.md) ---
spec.md has no superseded/suppressed sections
design.md has no superseded/suppressed sections
No spec/design freshness boundaries detected
--- Check 2: Superseded Scope Sections Are Non-Executable ---
scopes.md has no superseded scope section
No superseded scope sections detected
--- Check 4: Result ---
RESULT: PASS (0 failures, 0 warnings)
FINAL_ARTIFACT_FRESHNESS_EXIT=0
scenario-manifest.json covers 4 scenario contract(s)
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
FINAL_TRACEABILITY_EXIT=0
SCOPED_DIFF_CHECK_EXIT=0
```

**Result:** PASS - the reconciled packet remains structurally valid, fresh, and
traceable after the final test evidence and execution metadata edits. Artifact
lint retains only the pre-existing validate-owned deprecated
`certification.scopeProgress` advisory; this test phase does not modify it.

### Supplemental Full Matrix And Release Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** paired committed-pre-fix/current production-guard replay against `/Users/pkirsanov/Projects/research-lab`
**Exit Code 2:** 0 for the paired assertion; pre-fix guard `1`, current guard `0`
**Command 3:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code 3:** 0
**Claim Source:** executed
**Output (fresh full-matrix discriminator):**

```text
PASS: S3 zero numbered state.json (exit=1)
PASS: S3 stderr contains 'failureCode=E085-NO-CURRENT-SPEC'
PASS: S4 one done numbered spec (exit=0)
PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
PASS: S5 genuine first adoption (exit=0)
PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
PASS: S5 guard leaves refs, index, worktree, and object inventory unchanged
PASS: S6 malformed state.json (exit=2)
PASS: S6 stderr contains 'failureCode=E085-CURRENT-STATE-MALFORMED'
PASS: S7 changed historical done (exit=1)
PASS: S8 deleted historical done (exit=1)
PASS: S9 all-ref historical done (exit=1)
PASS: S10 missing Git metadata (exit=2)
PASS: S10 nested root (exit=2)
PASS: S11 fixture is genuinely shallow
PASS: S11 shallow history (exit=2)
PASS: S12a extensions.partialClone metadata (exit=2)
PASS: S12b remote.promisor metadata (exit=2)
PASS: S13 failed reachable-ref traversal (exit=2)
PASS: S13 failed historical tree traversal (exit=2)
PASS: S13 failed historical blob traversal (exit=2)
PASS: S14 malformed historical state (exit=2)
PASS: S14 stderr contains 'failureCode=E085-HISTORICAL-STATE-MALFORMED'
PASS: S15 ignored non-numbered and nested done (exit=0)
PASS: S16 current-done guidance
PASS: S16 genuine first-adoption guidance
PASS: S16 stale single-path guidance is absent
Total assertions: 71
Passed:           71
Failed:           0
framework-dogfood-guard-selftest: PASSED
```

**Output (fresh red-green and release verdicts):**

```text
BUG012_PRE_FIX_GUARD_EXIT=1
PASS Gate G085 (framework_dogfood_evidence_gate) decisionCode=G085-FIRST-ADOPTION currentDone=0 historicalDone=0 historyIntegrity=complete totalSpecs=2
BUG012_CURRENT_GUARD_EXIT=0
expected-red=1
expected-green=0
downstream-managed-copy-edit=no
Framework validation passed.
PASS: Framework validation
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness
PASS: Cheatsheet freshness (v6.0 / B7)
Release manifest is current: 7.20.0 (611 managed files)
PASS: Release manifest freshness
PASS: Required release files
PASS: No stray temp or backup files
Release check passed.
BUG012_RELEASE_CHECK_EXIT=0
```

**Result:** PASS for the focused matrix, red-green trace, broad framework, and
release rows. Current done, first adoption, changed/deleted/all-ref historical
done, empty inventory, malformed current and historical state, missing/nested
Git roots, effective shallow history, both partial-history markers, and all
three traversal failures are independently exercised against the current
production guard.

**Phase:** test
**Executed:** YES (current invocation)
**Command:** exact Check 26 wrapper-versus-delegated-source discriminator
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== BUG-012 STALE CONSUMER DISCRIMINATOR ===
wrapper=state-transition-guard.sh Check 26
runtime=tail-delegated-gates.sh Check 26
3225:# evidence model still applies: at least one numbered spec at status
30: info "Downstream/fixture pass path G085-CURRENT-DONE: ..."
31: info "Downstream/fixture pass path G085-FIRST-ADOPTION: ..."
OBSERVED_RUNTIME_CONTRACT=two-path
OBSERVED_WRAPPER_COMMENT=obsolete-done-only
BUG012_STALE_CONSUMER_FINDINGS=1
REQUIRED_OWNER=bubbles.implement
MUTATION_PERFORMED=no
=== BUG-012 STALE CONSUMER DISCRIMINATOR END ===
```

**Result:** FAIL for finalized Consumer Impact completion. The production
runtime path is correct and all executable checks pass, but the active wrapper
comment is a stale first-party contract reference. This independently confirms
`BUG012-TEST-CONSUMER-001`; no implementation edit was made by `bubbles.test`.

### Check 26 Wrapper Reconciliation Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code 2:** 0
**Command 3:** exact wrapper/delegated Check 26 discriminator
**Exit Code 3:** 0
**Command 4:** `bash bubbles/scripts/generate-gates-block.sh --check`
**Exit Code 4:** 0
**Command 5:** `bash bubbles/scripts/workflow-registry-consistency.sh`
**Exit Code 5:** 0
**Claim Source:** executed
**Output:**

```text
PASS: S4 one done numbered spec (exit=0)
PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
PASS: S5 genuine first adoption (exit=0)
PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
PASS: S5 stdout contains 'historyIntegrity=complete'
PASS: S16 current-done guidance
PASS: S16 genuine first-adoption guidance
PASS: S16 stale single-path guidance is absent
Total assertions: 71
Passed:           71
Failed:           0
framework-dogfood-guard-selftest: PASSED
state-transition-guard selftest passed.
PASS: wrapper names G085-CURRENT-DONE
PASS: wrapper names G085-FIRST-ADOPTION
PASS: wrapper requires current-state evidence
PASS: wrapper requires complete-history evidence
PASS: wrapper states incomplete evidence fails closed
PASS: wrapper has no obsolete traditional-model prose
PASS: delegated runtime names G085-CURRENT-DONE
PASS: delegated runtime names G085-FIRST-ADOPTION
CONSUMER_DISCRIMINATOR_FAILURES=0
BUG-012 Check 26 consumer discriminator: PASS
generate-gates-block: workflows.yaml is in sync with registry (470 registry lines)
workflow-registry consistency check passed.
```

**Result:** PASS - the authorized non-executable wrapper comment names both
downstream pass decisions and states that first adoption requires proven
current-state and complete-history evidence, with missing or incomplete
evidence failing closed. No executable guard line, gate ordering, or status
semantic changed. `BUG012-TEST-CONSUMER-001` is implementation-addressed and
remains test-owned for independent Consumer Impact reconciliation.

### Wrapper Portability And Release Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Command 1:** `bash -n bubbles/scripts/state-transition-guard.sh && bash bubbles/scripts/macos-portability-guard-selftest.sh && bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh`
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/cli.sh framework-validate` (initial run)
**Exit Code 2:** 1
**Command 3:** `bash bubbles/scripts/generate-release-manifest.sh && bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Code 3:** 0
**Command 4:** `bash bubbles/scripts/cli.sh framework-validate` (post-generation rerun)
**Exit Code 4:** 0
**Command 5:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code 5:** 0
**Claim Source:** executed
**Output:**

```text
state-transition-guard.sh syntax: PASS
[selftest macos-portability-guard] OK — all assertions passed.
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
Framework validation failed with 2 failing check(s).
Failed checks:
	- Release manifest freshness
	- Release manifest selftest
Updated release manifest: 7.20.0 (611 managed files)
Release manifest is current: 7.20.0 (611 managed files)
Framework validation passed.
PASS: Capability ledger docs freshness
PASS: Framework stats freshness
PASS: Cheatsheet freshness (v6.0 / B7)
PASS: Release manifest freshness
PASS: Required release files
PASS: No stray temp or backup files
Release check passed.
```

**Result:** PASS after one bounded micro-fix loop. The initial broad run
correctly rejected stale checksums after an installer-managed file changed.
Canonical manifest generation reconciled the current managed tree; its
immediate freshness check, the fresh full framework rerun, and standalone
release readiness then passed. No downstream upgrade or managed-copy edit ran.

### Implementation Packet And Boundary Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Command 1:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 1:** 0
**Command 2:** `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 2:** 0
**Command 3:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Code 3:** 0
**Command 4:** scoped `git diff --check`
**Exit Code 4:** 0
**Command 5:** final wrapper/manifest SHA-256 and wrapper `git diff --numstat`
**Exit Code 5:** 0
**Claim Source:** interpreted
**Interpretation:** The executable packet checks prove structure, freshness,
and ten-row traceability. The wrapper delta is five added and four removed
comment lines. The release manifest is the planned generated companion and
also retains pre-existing current-tree managed-file updates. BUG-013 and all
other unrelated dirt remain preserved and unclaimed.
**Output:**

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
scenario-manifest.json covers 4 scenario contract(s)
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b  bubbles/scripts/state-transition-guard.sh
6ce65b48b265d72e842dbd871f8b57d8e63575a5fc819e5e82bcaa98d1119737  bubbles/release-manifest.json
5       4       bubbles/scripts/state-transition-guard.sh
PASS: state-transition executable and unrelated text bytes match HEAD outside authorized Check 26 comment block
M bubbles/release-manifest.json
M bubbles/scripts/state-transition-guard.sh
?? improvements/BUG-012-g085-first-adoption-deadlock/
?? improvements/BUG-013-g028-sensitive-client-storage-classification/
```

**Result:** PASS for the authorized implementation boundary. The independent
Consumer Impact checkbox remains unchanged, packet and scope remain
`in_progress`, `certification.*` is untouched, and all later lifecycle,
G027, G090, and advisory findings remain active.

### Implementation Finding Accounting

| Finding | Implementation disposition | Next owner |
| --- | --- | --- |
| `BUG012-TEST-CONSUMER-001` | Addressed in the authorized Check 26 wrapper comment with fresh focused, transition/delegated, portability, framework, release, and packet evidence | `bubbles.test` for final independent Consumer Impact reconciliation |
| Existing later lifecycle findings | Preserved without phase advancement | Existing named owners after test reconciliation |
| Existing G027/G090 blockers and advisories | Preserved without certification or terminal transition | Existing named owners |

**Implementation verdict:** `route_required`. The narrow implementation finding
is addressed with current evidence; final Consumer Impact reconciliation stays
independently owned by `bubbles.test`.

### Post-Handoff Transition Diagnostic Evidence

**Phase:** implement
**Executed:** YES (current invocation; diagnostic only)
**Command:** `bash bubbles/scripts/state-transition-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --target-status done --expect-workflow-mode bugfix-fastlane --expect-contract-digest sha256:aa91472c047d3d985d38c1d308feb1e6081955b2aa553816deb5987d9cdc449f`
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
DoD items total: 23 (checked: 22, unchecked: 1)
BLOCK: Resolved scope artifacts have 1 UNCHECKED DoD items - ALL must be [x] for 'done'
BLOCK: Resolved scope artifacts have 2 scope(s) still marked 'In Progress' - ALL scopes must be Done
PASS: Required phase 'implement' recorded in execution/certification phase records
BLOCK: Required phase 'test' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'regression' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'simplify' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'stabilize' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'security' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'validate' NOT in execution/certification phase records (Gate G022 violation)
BLOCK: Required phase 'audit' NOT in execution/certification phase records (Gate G022 violation)
WARN: report.md has 36 of 61 evidence blocks that lack terminal output signals (potentially fabricated)
BLOCK: Execution/certification phases claim implement/test phases but completedScopes is EMPTY - FABRICATION (Gate G027)
BLOCK: Execution/certification phases claim implement/test phases but ZERO scopes are marked 'Done' - FABRICATION (Gate G027)
BLOCK: Retro convergence health failed - Gate G090.
PASS: Framework dogfood evidence contract is satisfied (Gate G085)
TRANSITION BLOCKED: 13 failure(s), 1 warning(s)
failedGateIds: [G022,G027,G090]
blockingCode: DELIVERY_COMPLETION_FAILED
exitStatus: 1
verdict: FAIL
```

**Result:** EXPECTED BLOCK - the invocation omitted `--revert-on-fail` and made
no state mutation. It proves the G085 wrapper/runtime contract is green while
the independent Consumer Impact item, nonterminal scopes, later lifecycle,
G027, G090, and the existing advisory remain active. No Done claim is made.

<!-- markdownlint-restore MD010 -->

## Final Independent Consumer Impact Reverification - 2026-07-14

This section records only the independent `bubbles.test` rerun after the stale
Check 26 wrapper text was repaired. The dirty canonical worktree was preserved.
No implementation, release-manifest generation, commit, push, reset, downstream
upgrade, scope promotion, or `certification.*` mutation was performed.

<!-- markdownlint-disable MD010 -->

### Current Exact Consumer Impact Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** the exact zsh-safe assertion harness already printed under
[Exact Stale-Reference And Consumer Sweep](#exact-stale-reference-and-consumer-sweep)
was rerun unchanged from `/Users/pkirsanov/Projects/bubbles`.
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_BEGIN
GROUP: delegated and broad callers
PASS: delegated Check 26 names current-done path
PASS: delegated Check 26 names first-adoption path
PASS: framework validation registers focused G085 selftest
PASS: state-transition caller sources delegated tail
PASS: state-transition caller has no obsolete done-only wrapper prose
PASS: state-transition caller comment names current-done path
PASS: state-transition caller comment names first-adoption path
GROUP: registry and operator references
PASS: gate registry names current-done path
PASS: gate registry names first-adoption path
PASS: generated workflow registry names current-done path
PASS: generated workflow registry names first-adoption path
PASS: operator recipe names current-done path
PASS: operator recipe names first-adoption path
PASS: operator recipe rejects mutable marker
PASS: convergence reference names proven first adoption
PASS: current changelog names two explicit pass paths
PASS: current changelog rejects mutable marker
GROUP: release provenance
PASS: managed guard manifest checksum hash=2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4
PASS: managed selftest manifest checksum hash=a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d
PASS: managed recipe manifest checksum hash=20dcac1008dd187b4f5f0e8d0c59bf8e89786275c9e5a5b26df2449177153178
PASS: source-only persistent regression checksum hash=e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6
CONSUMER_SWEEP_FAILURES=0
BUG-012 exact first-party consumer sweep: PASS
BUG012_EXACT_CONSUMER_SWEEP_EVIDENCE_END
```

**Result:** PASS - all 20 first-party reference and provenance assertions are
green. The three assertions that controlled the prior failure now prove the
obsolete wrapper prose is absent and both `G085-CURRENT-DONE` and
`G085-FIRST-ADOPTION` are present. No stale mutable-marker or blanket zero-done
assumption remains on the enumerated first-party surface.

### Current Focused Scenario And Authenticity Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code 1:** 0
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 2:** 0
**Command 3:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code 3:** 0
**Command 4:** token-aware disabled-test, mock/interception, and conditional
bailout scan over the two required test files.
**Exit Code 4:** 0
**Claim Source:** executed
**Output:**

```text
--- S4: one done numbered spec ---
	PASS: S4 one done numbered spec (exit=0)
	PASS: S4 stdout contains 'decisionCode=G085-CURRENT-DONE'
--- S5: first adoption with one committed in_progress spec in a path containing spaces ---
	PASS: S5 genuine first adoption (exit=0)
	PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	PASS: S5 stdout contains 'historyIntegrity=complete'
--- S16: delegated G085 guidance names current-done and genuine first-adoption paths ---
	PASS: S16 current-done guidance
	PASS: S16 genuine first-adoption guidance
	PASS: S16 stale single-path guidance is absent
=== Selftest verdict ===
	Total assertions: 71
	Passed:           71
	Failed:           0
framework-dogfood-guard-selftest: PASSED
BUG012_INDEPENDENT_71_EXIT=0
PASS: S5 adversarial repositories have identical current states
PASS: S5 reachable historical done - VIOLATION (exit=1)
PASS: S6 shallow fixture setup is effective
PASS: S6 shallow history - INTEGRITY FAILURE (exit=2)
=== Regression verdict ===
	Total assertions: 16
	Passed:           16
	Failed:           0
test_04_framework_dogfooding: REGRESSION PASSED
BUG012_INDEPENDENT_16_EXIT=0
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
PASS: no disabled/skip/only/todo marker in bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS: no mock/interception pattern in bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS: no disabled/skip/only/todo marker in tests/regression/test_04_framework_dogfooding.sh
PASS: no mock/interception pattern in tests/regression/test_04_framework_dogfooding.sh
PASS: no conditional bailout return in persistent regression
SKIP_MOCK_AUDIT_FAILURES=0
```

**Result:** PASS - the exhaustive classifier remains green at 71/71 and the
persistent adversarial regression remains green at 16/16. The regression has a
real adversarial signal and contains no disabled marker, interception/mock, or
failure-condition bailout.

One initial regression command ran from the terminal's prior directory and
exited `127` before the test script started. It is discarded non-evidence; the
explicit canonical-root exit-0 rerun above is the controlling result. An initial
multiline sweep submission also produced no usable verdict and is discarded.

### Current Broad Framework And Release Evidence

**Phase:** test
**Executed:** YES (current invocation, after focused checks)
**Command 1:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh framework-validate`
**Exit Code 1:** 0 on the controlling rerun
**Command 2:** `cd /Users/pkirsanov/Projects/bubbles && env -i HOME="$HOME" PATH="/opt/homebrew/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash bubbles/scripts/release-check.sh`
**Exit Code 2:** 0
**Claim Source:** executed
**Output:**

```text
transition-contract-resolver-selftest: PASS
passes=55
failures=0
skips=1
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
stale-deferral-lint-selftest: 11 pass, 0 fail
PASS: Stale-deferral lint selftest
[stale-deferral-lint] OK - no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)
Framework validation passed.
BUG012_INDEPENDENT_FRAMEWORK_RERUN_EXIT=0
Framework validation passed.
PASS: Framework validation
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness
PASS: Cheatsheet freshness (v6.0 / B7)
Release manifest is current: 7.20.0 (611 managed files)
PASS: Release manifest freshness
PASS: Required release files
PASS: No stray temp or backup files
Release check passed.
BUG012_INDEPENDENT_RELEASE_RERUN_EXIT=0
```

**Result:** PASS - the canonical broad suite passed after the focused rows, and
the isolated release check passed with current 611-file manifest provenance.
The framework source reported observability `EXEMPT (no-runtime)`, so no trace
or SLO artifact applies to this local governance guard.

The first broad run named one resolver-selftest failure. A direct discriminator
was externally interrupted at exit `130`; the clean-environment rerun then
passed 55/0 with one policy-allowed optional JSON Schema skip, and the full
canonical framework rerun passed. The first release request surfaced output
from a concurrent BUG-013 validation and supports no BUG-012 claim; the isolated
exit-0 release run above is controlling. No concurrent process was killed.

### Current Test Integrity, Packet, And Preservation Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** artifact lint, artifact freshness, traceability, token-aware test
integrity scans, certification fingerprint comparison, and scoped source
SHA-256 comparison against the pre-run baseline.
**Exit Codes:** 0
**Claim Source:** interpreted
**Interpretation:** The packet commands directly prove four-scenario/ten-row
coherence and zero test-integrity findings. The certification fingerprint is
programmatically identical. The six printed source hashes match the captured
pre-run baseline byte-for-byte, so the test rerun did not overwrite the dirty
implementation or generated release surfaces.
**Output:**

```text
Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
RESULT: PASS (0 failures, 0 warnings)
ARTIFACT_FRESHNESS_EXIT=0
scenario-manifest.json covers 4 scenario contract(s)
All linked tests from scenario-manifest.json exist
Scenarios checked: 4
Test rows checked: 10
Scenario-to-row mappings: 4
Concrete test file references: 4
Report evidence references: 4
DoD fidelity scenarios: 4 (mapped: 4, unmapped: 0)
RESULT: PASSED (0 warnings)
TRACEABILITY_EXIT=0
EXPECTED_CERTIFICATION_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
CURRENT_CERTIFICATION_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
PASS: certification bytes unchanged
1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b  bubbles/scripts/state-transition-guard.sh
2a8c6994f9d9239d6472c7e35ab35c203be585a56af123fcf0ea25fab0def6b4  bubbles/scripts/framework-dogfood-guard.sh
a765ac8e9ff3c011aaa2adba85fb8739d3fbcfffa9280d0f1c035b5079f6b11d  bubbles/scripts/framework-dogfood-guard-selftest.sh
d587280493e6dc2719c805d1c2a28f407b2c48041542641027858e6994477c84  bubbles/scripts/guards/tail-delegated-gates.sh
e353d3cf7abb8fba917b4b79e1ab62ff642eeb6e43630600e0b90060998d91b6  tests/regression/test_04_framework_dogfooding.sh
6ce65b48b265d72e842dbd871f8b57d8e63575a5fc819e5e82bcaa98d1119737  bubbles/release-manifest.json
PASS: source hashes remain at captured baseline values
```

**Result:** PASS with the interpretation above - current test execution changed
none of the protected source or certification bytes. The only authored updates
from this invocation are test-owned evidence/progress in the BUG-012 packet.

### Current Four-Item Reconciliation And Route

| Finalized test-owned item | Current disposition | Evidence |
| --- | --- | --- |
| Scenario-specific E2E | PASS | [Current focused scenario and authenticity evidence](#current-focused-scenario-and-authenticity-evidence) |
| Broader E2E regression | PASS | [Current broad framework and release evidence](#current-broad-framework-and-release-evidence) |
| Consumer Impact Sweep | PASS | [Current exact consumer impact evidence](#current-exact-consumer-impact-evidence) |
| Change Boundary | PASS (`interpreted`) | [Current test integrity, packet, and preservation evidence](#current-test-integrity-packet-and-preservation-evidence) |

All four finalized independent-test items now have current execution evidence.
`BUG012-TEST-CONSUMER-001` is addressed one-to-one; no test-owned finding remains
open. The resolved `bugfix-fastlane` phase order is `implement -> test ->
regression -> simplify -> gaps -> harden -> stabilize -> devops -> security ->
validate -> audit -> finalize`, so the next required specialist is
`bubbles.regression`.

The scope and packet remain `in_progress`. G027, G090, later specialist phases,
scope promotion, audit, finalization, release publication, propagation, and
downstream upgrade remain unclaimed. `certification.*` is unchanged.

<!-- markdownlint-restore MD010 -->

## Structured Report-Evidence Scanner Implementation - 2026-07-14

The planned classifier and Cases 12-19 were already present as concurrent
worktree changes when this invocation inspected the two authorized scripts.
This invocation preserved those bytes, reconciled them against
`SCN-BUG-012-005`, executed the committed pre-repair source in memory as the RED
control, and validated the worktree candidate through the focused and protected
regression surfaces.

### RED And GREEN Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Commands:** in-memory `git show HEAD:bubbles/scripts/stale-deferral-lint.sh`
execution against the current repository; `bash
bubbles/scripts/stale-deferral-lint-selftest.sh`
**Exit Codes:** 1, 0
**Claim Source:** executed
**Output:**

```text
[stale-deferral-lint][ERROR] improvements/BUG-012-g085-first-adoption-deadlock/report.md references 'deferred to v2.0' but current VERSION is 7.20.0 (>= v2.0). The promised release has arrived — implement it, or restate the status without a lapsed version promise.
[stale-deferral-lint][ERROR] improvements/BUG-012-g085-first-adoption-deadlock/report.md references 'deferred to v2.0' but current VERSION is 7.20.0 (>= v2.0). The promised release has arrived — implement it, or restate the status without a lapsed version promise.
[stale-deferral-lint][ERROR] improvements/BUG-012-g085-first-adoption-deadlock/report.md references 'deferred to v1.0' but current VERSION is 7.20.0 (>= v1.0). The promised release has arrived — implement it, or restate the status without a lapsed version promise.
PASS: Case 1: clean tree (exit 0)
PASS: Case 2: lapsed deferred to v1.5 (exit 1)
PASS: Case 3: future deferred to v9.0 is allowed (exit 0)
PASS: Case 4: deferred to v2.0 at VERSION 2.0.0 is due (exit 1)
PASS: Case 5: deferred to v2.0 at VERSION 2.0.3 is due (exit 1)
PASS: Case 6: deferred until v1.0 variant (exit 1)
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
```

**Result:** PASS - the committed implementation reproduces the report false
positives, while the worktree production lint passes every protected and new
case.

### Preservation, Portability, And Release Metadata Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Commands:** focused G085 selftest; persistent G085 regression; macOS system
Bash selftest and syntax parse; touched-shell portability guard; bugfix
regression-quality guard; live stale-reference lint; release-manifest freshness
and exact hash comparison
**Exit Codes:** 0 for every command
**Claim Source:** executed
**Output:**

```text
=== Selftest verdict ===
  Total assertions: 74
  Passed:           74
  Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
=== Regression verdict ===
  Total assertions: 19
  Passed:           19
  Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
stale-deferral-lint-selftest: 19 pass, 0 fail
BUG012_SYSTEM_BASH_SYNTAX_EXIT=0
PASS: the scanned surface is WSL+macOS portable.
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
Release manifest is current: 7.20.0 (613 managed files)
c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40  bubbles/scripts/stale-deferral-lint.sh
250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25  bubbles/scripts/stale-deferral-lint-selftest.sh
MANIFEST_ENTRY path=bubbles/scripts/stale-deferral-lint-selftest.sh sha256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
MANIFEST_ENTRY path=bubbles/scripts/stale-deferral-lint.sh sha256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
```

**Result:** PASS - G085 behavior is preserved, the two changed scripts remain
portable, and the existing generated manifest already contains their exact
current hashes. No manifest regeneration was needed.

### Packet-Coherence Evidence

**Phase:** implement
**Executed:** YES (current invocation)
**Commands:** BUG-012 artifact lint, artifact freshness, traceability guard, and
implementation reality scan
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
scenario-manifest.json covers 5 scenario contract(s)
All linked tests from scenario-manifest.json exist
Scenarios checked: 5
Test rows checked: 13
Scenario-to-row mappings: 5
Concrete test file references: 5
Report evidence references: 5
DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
RESULT: PASSED (0 warnings)
Files scanned:  6
Violations:     0
Warnings:       1
PASSED with 1 warning(s) — manual review advised
```

**Result:** PASS with one preserved advisory - the reality scanner used its
design fallback even though Scope 1 names the concrete scanner paths. It found
zero implementation violations. Certification remains owned by
`bubbles.validate`.

### Implementation Finding Disposition

| Finding | Disposition | Exact next owner |
| --- | --- | --- |
| `BUG012-SIMPLIFY-003` | Addressed on the authorized implementation bytes: baseline RED reproduced; production classifier and Cases 1-19 pass; live source scan passes | `bubbles.test` |
| `BUG012-SIMPLIFY-004` | Preserved as already addressed; the original report prefix remained byte-identical before this append | none |
| `BUG012-VAL-REALITY-DISCOVERY` | Preserved advisory with zero reality-scan violations | `bubbles.validate` retains certification ownership |
| `BUG012-VAL-G090` and the recorded subsequent lifecycle gates | Preserved without reconstructing session input or making certification claims | owners already recorded in Scope 1 Required Lifecycle Continuation |

The packet remains `in_progress`. Independent `T-BUG-012-11` through
`T-BUG-012-13`, subsequent specialist execution, certification, audit,
finalization, release publication, propagation, and downstream installation are
not claimed by this implementation invocation.

## Independent Scanner Verification After Implementation Handoff - 2026-07-14

This section records only the fresh `bubbles.test` execution started at
`2026-07-14T22:04:45Z`. Existing dirty work was preserved. No production
source, test source, planning-owned artifact, checked prior evidence,
`certification.*` field, BUG-013 artifact, release manifest, commit, or push was
changed by this invocation.

<!-- markdownlint-disable MD010 -->

### Focused G085 Preservation Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`; `bash tests/regression/test_04_framework_dogfooding.sh`; `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`; `bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/stale-deferral-lint-selftest.sh`
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
=== Selftest verdict ===
	Total assertions: 74
	Passed:           74
	Failed:           0

🟢 framework-dogfood-guard-selftest: PASSED
BUG012_G085_SELFTEST_EXIT=0
=== Regression verdict ===
	Total assertions: 19
	Passed:           19
	Failed:           0

🟢 test_04_framework_dogfooding: REGRESSION PASSED
BUG012_G085_PERSISTENT_EXIT=0
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
BUG012_G085_REGRESSION_QUALITY_EXIT=0
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
BUG012_STALE_REGRESSION_QUALITY_EXIT=0
```

**Result:** PASS - the amended scanner bytes do not regress the current G085
decision matrix, persistent adversarial regression, or either bugfix regression
quality check.

### T-BUG-012-11 Nineteen-Case Evidence

**Phase:** test
**Executed:** YES (current invocation, after the G085 canaries)
**Command:** `bash bubbles/scripts/stale-deferral-lint-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: Case 1: clean tree (exit 0)
PASS: Case 2: lapsed deferred to v1.5 (exit 1)
PASS: Case 3: future deferred to v9.0 is allowed (exit 0)
PASS: Case 4: deferred to v2.0 at VERSION 2.0.0 is due (exit 1)
PASS: Case 5: deferred to v2.0 at VERSION 2.0.3 is due (exit 1)
PASS: Case 6: deferred until v1.0 variant (exit 1)
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
BUG012_T_BUG_012_11_EXIT=0
BUG012_FOCUSED_TESTS_END
```

**Result:** PASS - Cases 1-11 remain green, Case 12 is the sole structured
report-evidence exemption, and Cases 13-19 retain the seven fail-closed paths.

### T-BUG-012-12 Canonical Framework Evidence

**Phase:** test
**Executed:** YES (current invocation, after T-BUG-012-11)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
==> Stale-deferral lint selftest
PASS: Case 1: clean tree (exit 0)
PASS: Case 2: lapsed deferred to v1.5 (exit 1)
PASS: Case 3: future deferred to v9.0 is allowed (exit 0)
PASS: Case 4: deferred to v2.0 at VERSION 2.0.0 is due (exit 1)
PASS: Case 5: deferred to v2.0 at VERSION 2.0.3 is due (exit 1)
PASS: Case 6: deferred until v1.0 variant (exit 1)
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation failed with 2 failing check(s).
Failed checks:
	- Release manifest freshness
	- Release manifest selftest
BUG012_T_BUG_012_12_EXIT=1
```

**Result:** FAIL - T-BUG-012-12 is not complete. The focused scanner checks are
green inside the canonical run, but global release-manifest freshness and its
selftest fail.

### T-BUG-012-13 Canonical Release Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
Framework validation failed with 2 failing check(s).
Failed checks:
	- Release manifest freshness
	- Release manifest selftest
FAIL: Framework validation

==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness

==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness

==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)

==> Release manifest freshness
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Release manifest freshness

==> Required release files
PASS: Required release files

==> No stray temp or backup files
PASS: No stray temp or backup files

Release check failed with 2 failing check(s).
BUG012_T_BUG_012_13_EXIT=1
```

**Result:** FAIL - T-BUG-012-13 is not complete because canonical release
readiness inherits the same two manifest failures.

### Independent Release-Manifest Hash Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** direct SHA-256 comparison for the two BUG-012 paths; full manifest-entry SHA-256 audit; `bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Codes:** 0 for the two BUG-012 entries; 1 for global freshness
**Claim Source:** executed
**Output:**

```text
BUG012_TARGET_MANIFEST_HASH_VERIFICATION_BEGIN
PATH=bubbles/scripts/stale-deferral-lint.sh
EXPECTED_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
ACTUAL_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
RESULT=PASS
PATH=bubbles/scripts/stale-deferral-lint-selftest.sh
EXPECTED_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
ACTUAL_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
RESULT=PASS
BUG012_TARGET_MANIFEST_HASH_FAILURES=0
BUG012_TARGET_MANIFEST_HASH_VERIFICATION_END
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
BUG012_MANIFEST_CHECK_EXIT=1
BUG012_GLOBAL_MANIFEST_MISMATCH_AUDIT_BEGIN
MISMATCH path=bubbles/scripts/adversarial-resolve-selftest.sh expected=17bd31044d4114a9ce7cd36bc95c49b12809f17edc410c3c0db744bc4c247da8 actual=303cd0725408c40b24a54e84322be2e741059c9f6b908b9694bfc9f895346292
MISMATCH path=bubbles/scripts/adversarial-resolve.sh expected=159b8769acff6197763373718242b111b93f0bb15d53e98ad579fba37853dbe4 actual=e2410877d05cd179f145446c612527b253ae13c9f87680d42f1eb8a58702c694
BUG012_GLOBAL_MANIFEST_MISMATCH_COUNT=2
BUG012_GLOBAL_MANIFEST_MISMATCH_AUDIT_END
```

**Result:** PASS for the two independently requested BUG-012 hash comparisons;
FAIL for global manifest freshness. The complete mismatch set contains exactly
the two concurrent IMP-020 paths shown above, not either BUG-012 scanner path.

### Portability, Test Integrity, And Preservation Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** `/bin/bash -n bubbles/scripts/stale-deferral-lint.sh bubbles/scripts/stale-deferral-lint-selftest.sh`; `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/stale-deferral-lint.sh bubbles/scripts/stale-deferral-lint-selftest.sh`; token-aware disabled-test and mock/interception scans; post-run SHA-256 comparison
**Exit Codes:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_SYSTEM_BASH_SYNTAX_EXIT=0
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
PASS: the scanned surface is WSL+macOS portable.
BUG012_PORTABILITY_EXIT=0
PASS: no disabled marker in bubbles/scripts/stale-deferral-lint-selftest.sh
PASS: no mock or interception in bubbles/scripts/stale-deferral-lint-selftest.sh
PASS: no disabled marker in bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS: no mock or interception in bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS: no disabled marker in tests/regression/test_04_framework_dogfooding.sh
PASS: no mock or interception in tests/regression/test_04_framework_dogfooding.sh
BUG012_TEST_INTEGRITY_FAILURES=0
c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40  bubbles/scripts/stale-deferral-lint.sh
250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25  bubbles/scripts/stale-deferral-lint-selftest.sh
ca675e955f9e47b50d7f15281f8cc0880f00560d6a2f87fc276d2449663c7f23  bubbles/release-manifest.json
ca1a2d55a17fbd049ad31b7513eb80226e4d453200dbb9ffe4a339630bfefd1b  certification-only SHA-256
```

**Result:** PASS - test execution introduced no source or certification
mutation. The two scanner files, release manifest, and certification-only hash
match the pre-run baseline; required tests contain no disabled or mocked-live
patterns.

### Finding Accounting And Exact Route

| Finding | Disposition | Exact owner |
| --- | --- | --- |
| `BUG012-TEST-SCANNER-001` | Addressed: T-BUG-012-11 passes all 19 cases; focused G085 preservation and test-integrity checks are green | none |
| `BUG012-TEST-HASH-001` | Addressed: both BUG-012 release-manifest entries exactly match current scanner bytes | none |
| `BUG012-TEST-RELEASE-MANIFEST-001` | Open: canonical framework and release checks fail because the manifest has exactly two concurrent IMP-020 mismatches, `adversarial-resolve.sh` and `adversarial-resolve-selftest.sh` | `bubbles.releases`, which owns generated checksums and manifest freshness for IMP-020 S2 |

**Test verdict:** `NOT_TESTED` for the amended independent handoff. T-BUG-012-11
is green, but T-BUG-012-12 and T-BUG-012-13 are red. No test-phase completion
claim, scope promotion, certification, release, or propagation claim is made.
After `bubbles.releases` reconciles the complete two-path manifest finding,
`bubbles.test` must freshly rerun T-BUG-012-12 and T-BUG-012-13 before the
recorded lifecycle can proceed.

<!-- markdownlint-restore MD010 -->

## Independent Release-Manifest Reverification After Releases Handoff - 2026-07-14

This section records only the resumed `bubbles.test` verification after
`bubbles.releases` reconciled `BUG012-TEST-RELEASE-MANIFEST-001`. Existing
dirty work was preserved. This invocation changed no production source, test
source, planning artifact, release manifest, IMP-020 source, BUG-013 artifact,
prior evidence, or `certification.*` field.

### T-BUG-012-12 Canonical Framework Reverification

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (verdict window from the preserved full terminal transcript):**

```text
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)
stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)
Framework validation passed.
BUG012_RESUME_T12_FRAMEWORK_VALIDATE_EXIT=0
BUG012_RESUME_T12_FRAMEWORK_VALIDATE_END
```

**Result:** PASS. `T-BUG-012-12` now proves the amended scanner selftest and
live scanner remain active and green inside the full canonical framework run.

### T-BUG-012-13 Canonical Release Reverification

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code:** 0
**Claim Source:** executed
**Output (release verdict window from the preserved full terminal transcript):**

```text
Framework validation passed.
PASS: Framework validation
==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness
==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)
==> Release manifest freshness
Release manifest is current: 7.20.0 (613 managed files)
PASS: Release manifest freshness
==> Required release files
PASS: Required release files
==> No stray temp or backup files
PASS: No stray temp or backup files
Release check passed.
BUG012_RESUME_T13_RELEASE_CHECK_EXIT=0
BUG012_RESUME_T13_RELEASE_CHECK_END
```

**Result:** PASS. `T-BUG-012-13` now proves canonical release readiness and
the generated release manifest are current after the release-owned repair.

### Full Manifest Consistency And Exact BUG-012 Hashes

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/generate-release-manifest.sh --check`; full
SHA-256 comparison of every `managedFileChecksums` and
`sourceOnlyFileChecksums` entry; exact manifest-to-byte comparison for
`stale-deferral-lint.sh` and `stale-deferral-lint-selftest.sh`
**Exit Codes:** 0, 0, 0
**Claim Source:** executed
**Output:**

```text
Release manifest is current: 7.20.0 (613 managed files)
CANONICAL_MANIFEST_CHECK_EXIT=0
ENTRY_ENUMERATION_EXIT=0
MANAGED_ENTRIES_CHECKED=613
SOURCE_ONLY_ENTRIES_CHECKED=51
TOTAL_ENTRIES_CHECKED=664
FULL_ENTRY_MISMATCHES=0
FULL_ENTRY_AUDIT=PASS
PATH=bubbles/scripts/stale-deferral-lint.sh
MANIFEST_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
ACTUAL_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
RESULT=PASS
PATH=bubbles/scripts/stale-deferral-lint-selftest.sh
MANIFEST_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
ACTUAL_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
RESULT=PASS
BUG012_SCANNER_HASH_FAILURES=0
```

The first custom all-entry probe was rejected as evidence because its `jq`
formatter failed and process-substitution status did not propagate. The
corrected audit above captures `ENTRY_ENUMERATION_EXIT=0`, requires both entry
classes to be non-empty, checks all 664 rows, and reports zero mismatches.

### Focused G085 Drift Check

**Phase:** test
**Executed:** YES (current invocation; run only after the prior broad transcript
could not be independently reopened for its embedded G085 verdict)
**Commands:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`;
`bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Codes:** 0, 0
**Claim Source:** executed
**Output:**

<!-- markdownlint-disable MD010 -->

```text
=== Selftest verdict ===
	Total assertions: 74
	Passed:           74
	Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
BUG012_RESUME_G085_SELFTEST_EXIT=0
=== Regression verdict ===
	Total assertions: 19
	Passed:           19
	Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
BUG012_RESUME_G085_REGRESSION_EXIT=0
BUG012_RESUME_FOCUSED_G085_END
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS. There is no intervening G085 classifier or persistent
regression drift on the current bytes.

### Post-Edit State And Preservation Validation

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** state JSON and execution-route assertions; certification-object
SHA-256 comparison; BUG-012 artifact lint; live stale-reference lint; scoped
diff check; pre/post SHA-256 comparison for the release manifest and five
protected executable/test files; historical report-prefix comparison
**Exit Codes:** 0
**Claim Source:** executed
**Output:**

```text
STATE_JSON_PARSE_EXIT=0
STATE_EXECUTION_ASSERTIONS_EXIT=0
CERTIFICATION_SHA256=3d00f253cc516cf33665701c1b79d448472d6f455d9596ce3d94d236d204b638
CERTIFICATION_PRESERVATION=PASS
Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
LIVE_STALE_DEFERRAL_LINT_EXIT=0
SCOPED_DIFF_CHECK_EXIT=0
PASS label=release manifest unchanged path=bubbles/release-manifest.json sha256=d75fde3c182d79c8d88a49fc4a48756c6d3906085dbb909dd52fe0666dccd826
PASS label=scanner unchanged path=bubbles/scripts/stale-deferral-lint.sh sha256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
PASS label=scanner selftest unchanged path=bubbles/scripts/stale-deferral-lint-selftest.sh sha256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
PASS label=G085 guard unchanged path=bubbles/scripts/framework-dogfood-guard.sh sha256=29e34ba6463b031b965929ccecbccb9243acb86f8c1491d31e1af412df2758f7
PASS label=G085 selftest unchanged path=bubbles/scripts/framework-dogfood-guard-selftest.sh sha256=3794b40a58879029ef8e36dcfe29ffe90b74c4f3960747ef7ee3e33229178f8b
PASS label=G085 persistent regression unchanged path=tests/regression/test_04_framework_dogfooding.sh sha256=9f614102c5d74b0020964c4af3ec131daa2d48373a8f243ab51d3f441335a26b
PREFIX_ENUMERATION_EXIT=0
REPORT_PREFIX_SHA256=04004dbed39c94e9111ea5404764d550ec72d43b04f79779c82e04e5e11064d5
EXPECTED_PREFIX_SHA256=04004dbed39c94e9111ea5404764d550ec72d43b04f79779c82e04e5e11064d5
PRIOR_REPORT_PREFIX_PRESERVATION=PASS
```

The initial report-prefix probe included the newly inserted blank section
separator, so its mismatch was rejected. The next probe used `index` as a BSD
`awk` loop variable and failed to parse, so its empty hash was also rejected.
The final portable probe above captures the producer exit explicitly, removes
only the append separator, and proves the complete historical prefix is
byte-identical.

### Finding Closure And Route

| Finding | Current disposition | Exact owner |
| --- | --- | --- |
| `BUG012-TEST-SCANNER-001` | Addressed: the current broad run executes all 19 scanner cases and the live scan remains green | none |
| `BUG012-TEST-HASH-001` | Addressed: both exact BUG-012 scanner hashes match the manifest | none |
| `BUG012-TEST-RELEASE-MANIFEST-001` | Addressed: canonical checks pass and all 664 manifest entries match current bytes | none |
| `BUG012-TEST-EVIDENCE-PROBE-001` | Addressed: the invalid zero-row custom audit was rejected and replaced by an explicit-status, non-empty 664-row audit | none |
| `BUG012-TEST-PREFIX-PROBE-001` | Addressed: both invalid prefix probes were rejected; the portable explicit-status retry proves the prior report prefix is byte-identical | none |

**Test verdict:** `TESTED` for the amended independent handoff. Every
test-owned row `T-BUG-012-11` through `T-BUG-012-13` is now satisfied on the
current scanner and release-manifest bytes. The packet and scope remain
`in_progress`; no certification, scope promotion, release publication,
propagation, commit, or push is claimed. Per Scope 1 Required Lifecycle
Continuation, the exact next owner is `bubbles.regression` for fresh amended-byte
regression verification before simplify and gaps re-entry.

## Current-Tree Drift Correction After Green Reverification - 2026-07-14

The green `T-BUG-012-12` and `T-BUG-012-13` executions above remain valid for
the bytes present when those commands ran. Before final handoff, a concurrent
writer changed both IMP-020 resolver files again. The release manifest was not
updated to those later bytes, so the earlier green evidence cannot support a
current-tree `TESTED` verdict. No foreign-owned file was edited or reverted.

### Renewed Complete Manifest Audit

**Phase:** test
**Executed:** YES (current invocation, after the concurrent changes)
**Commands:** full SHA-256 comparison of all 664 release-manifest entries;
exact BUG-012 scanner hash comparison; canonical
`bash bubbles/scripts/generate-release-manifest.sh --check`
**Exit Codes:** 0 for complete mismatch enumeration and BUG-012 target hashes;
1 for canonical current-manifest freshness
**Claim Source:** executed
**Output:**

```text
BUG012_RESUME_CONCURRENT_DRIFT_AUDIT_BEGIN
ENTRY_ENUMERATION_EXIT=0
MISMATCH section=managedFileChecksums path=bubbles/scripts/adversarial-resolve-selftest.sh expected=303cd0725408c40b24a54e84322be2e741059c9f6b908b9694bfc9f895346292 actual=fce3a6381d232eb423b778451876005ec4fbed84e6e131aed54d46378e9bea24
MISMATCH section=managedFileChecksums path=bubbles/scripts/adversarial-resolve.sh expected=e2410877d05cd179f145446c612527b253ae13c9f87680d42f1eb8a58702c694 actual=b289c029580b006a1e19618eee8f61efb3e3f050299b0aecc9e43a753a7d1442
TOTAL_ENTRIES_CHECKED=664
CURRENT_MANIFEST_MISMATCHES=2
BUG012_TARGET_HASHES_BEGIN
PATH=bubbles/scripts/stale-deferral-lint.sh expected=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 actual=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 result=PASS
PATH=bubbles/scripts/stale-deferral-lint-selftest.sh expected=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 actual=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 result=PASS
BUG012_TARGET_HASHES_END
BUG012_RESUME_CONCURRENT_DRIFT_AUDIT_END
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FINAL_MANIFEST_CHECK_EXIT=1
```

**Result:** FAIL for current global manifest freshness. The complete current
mismatch set is exactly the same two IMP-020 paths, now at newer hashes. Both
BUG-012 scanner entries remain exact matches.

### Superseding Current Finding Accounting And Route

| Finding | Current disposition | Exact owner |
| --- | --- | --- |
| `BUG012-TEST-SCANNER-001` | Addressed: current scanner hashes remain exact and the earlier current-session 19-case/live-scan executions are green | none |
| `BUG012-TEST-HASH-001` | Addressed: both BUG-012 scanner entries still match current bytes | none |
| `BUG012-TEST-EVIDENCE-PROBE-001` | Addressed: invalid custom audit output was rejected and replaced with explicit producer-status audits | none |
| `BUG012-TEST-PREFIX-PROBE-001` | Addressed: invalid prefix probes were rejected and the portable retry proved historical evidence preservation | none |
| `BUG012-TEST-RELEASE-MANIFEST-001` | OPEN again: two later concurrent IMP-020 byte changes made the global manifest stale after the green checks | `bubbles.releases` |

**Current test verdict:** `NOT_TESTED` for the amended independent handoff on
the final observed tree. `T-BUG-012-12` and `T-BUG-012-13` were green before
the concurrent byte changes, but current release-manifest consistency is red.
The packet and scope remain `in_progress`; certification, release publication,
propagation, commit, and push remain unclaimed. The exact next owner is
`bubbles.releases`; after those two current IMP-020 hashes are reconciled and
stable, `bubbles.test` must freshly rerun the two broad rows again.

## Fresh Release-Reconciled Test Handoff - 2026-07-15

This test-owned append supersedes only the currentness verdict in the preceding
drift correction. It does not rewrite prior evidence. The reconciled tree was
quiescent before execution, and every non-owned byte remained stable through
the final pre-edit check.

### T-BUG-012-11 Fresh Adversarial Scanner Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/stale-deferral-lint-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (complete case-verdict window):**

```text
BUG012_FRESH_T11_BEGIN
PASS: Case 1: clean tree (exit 0)
PASS: Case 2: lapsed deferred to v1.5 (exit 1)
PASS: Case 3: future deferred to v9.0 is allowed (exit 0)
PASS: Case 4: deferred to v2.0 at VERSION 2.0.0 is due (exit 1)
PASS: Case 5: deferred to v2.0 at VERSION 2.0.3 is due (exit 1)
PASS: Case 6: deferred until v1.0 variant (exit 1)
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
BUG012_FRESH_T11_EXIT=0
BUG012_FRESH_T11_END
```

**Result:** PASS. All pre-amendment cases and the eight structured-evidence
cases retain their exact expected outcomes.

### Fresh G085 Canaries And Regression Quality

**Phase:** test
**Executed:** YES (current invocation, after T-BUG-012-11)
**Commands:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`;
`bash tests/regression/test_04_framework_dogfooding.sh`;
`bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Codes:** 0, 0, 0
**Claim Source:** executed
**Output (verdict windows):**

<!-- markdownlint-disable MD010 -->

```text
=== Selftest verdict ===
	Total assertions: 74
	Passed:           74
	Failed:           0
BUG012_FRESH_G085_SELFTEST_EXIT=0
BUG012_FRESH_G085_SELFTEST_END
=== Regression verdict ===
	Total assertions: 19
	Passed:           19
	Failed:           0
BUG012_FRESH_G085_REGRESSION_EXIT=0
BUG012_FRESH_G085_REGRESSION_END
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
BUG012_FRESH_REGRESSION_QUALITY_RETRY_EXIT=0
BUG012_FRESH_REGRESSION_QUALITY_RETRY_END
```

**Result:** PASS. The focused classifier remains 74/74, the persistent real-Git
regression remains 19/19, and the bugfix discriminator finds an adversarial
signal with no bailout violation.

### T-BUG-012-12 Fresh Canonical Framework Evidence

**Phase:** test
**Executed:** YES (current invocation, after T-BUG-012-11 and G085 canaries)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (verdict window from the preserved full terminal transcript):**

```text
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
[stale-deferral-lint] OK - no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation passed.
BUG012_FRESH_T12_FRAMEWORK_VALIDATE_EXIT=0
BUG012_FRESH_T12_FRAMEWORK_VALIDATE_END
```

**Result:** PASS. The full framework suite executes the amended scanner selftest
and the live scanner on the current bytes.

### T-BUG-012-13 Fresh Canonical Release Evidence

**Phase:** test
**Executed:** YES (current invocation, independent full release run)
**Command:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code:** 0
**Claim Source:** executed
**Output (release verdict window from the preserved full terminal transcript):**

```text
Framework validation passed.
PASS: Framework validation
==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
==> Framework stats freshness
Framework stats are current: 41 Agents - 109 Gates - 60 Workflow Modes - 30 Phases (v7.20.0)
PASS: Framework stats freshness
==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)
==> Release manifest freshness
Release manifest is current: 7.20.0 (613 managed files)
PASS: Release manifest freshness
==> Required release files
PASS: Required release files
==> No stray temp or backup files
PASS: No stray temp or backup files
Release check passed.
BUG012_FRESH_T13_RELEASE_CHECK_EXIT=0
BUG012_FRESH_T13_RELEASE_CHECK_END
```

**Result:** PASS. Canonical release readiness and generated-manifest freshness
are green after the final release-owned reconciliation.

### Complete Manifest And Exact Scanner Hash Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/generate-release-manifest.sh --check`; full
SHA-256 comparison of every `managedFileChecksums` and
`sourceOnlyFileChecksums` row; unique manifest-row comparison for the BUG-012
scanner and scanner selftest
**Exit Codes:** 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG012_FRESH_MANIFEST_AUDIT_BEGIN
Release manifest is current: 7.20.0 (613 managed files)
CANONICAL_MANIFEST_CHECK_EXIT=0
ENTRY_ENUMERATION_EXIT=0
MANAGED_ENTRIES_CHECKED=613
SOURCE_ONLY_ENTRIES_CHECKED=51
EXPECTED_TOTAL_ENTRIES=664
TOTAL_ENTRIES_CHECKED=664
FULL_ENTRY_MISMATCHES=0
FULL_ENTRY_AUDIT_EXIT=0
PATH=bubbles/scripts/stale-deferral-lint.sh
ROW_COUNT=1
MANIFEST_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
ACTUAL_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
RESULT=PASS
PATH=bubbles/scripts/stale-deferral-lint-selftest.sh
ROW_COUNT=1
MANIFEST_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
ACTUAL_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
RESULT=PASS
BUG012_SCANNER_HASH_FAILURES=0
BUG012_FRESH_MANIFEST_AUDIT_END
```

**Result:** PASS. All 664 manifest entries match current file bytes, and each
BUG-012 scanner path has exactly one manifest row with the exact current hash.

### Final Pre-Edit Source And Manifest Stability

**Phase:** test
**Executed:** YES (current invocation)
**Command:** complete pre/post SHA-256 and file-mode fingerprint comparison for
all non-owned tracked and non-ignored files, plus exact protected-file and HEAD
comparisons and active-writer detection
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_POST_RUN_STABILITY_BEGIN
ACTIVE_WRITER_CHECK=PASS
ACTIVE_WRITERS=0
HEAD_STABILITY=PASS sha=9b785d7da7554082cfe0232998ef72cc99637087
ENUMERATION_EXIT=0
NON_OWNED_FILES_FINGERPRINTED=942
EXPECTED_NON_OWNED_TREE_SHA256=5ea776732d87ce3dc244cd3a39ed381fba7273eed21c7198bf58183dfe9c663c
CURRENT_NON_OWNED_TREE_SHA256=5ea776732d87ce3dc244cd3a39ed381fba7273eed21c7198bf58183dfe9c663c
NON_OWNED_TREE_STABILITY=PASS
PASS label=release-manifest path=bubbles/release-manifest.json sha256=220d2b7ff2447c32fee14c5439a6c9cc5e6ec60e5afdaa530e50e530c732f145
PASS label=scanner path=bubbles/scripts/stale-deferral-lint.sh sha256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
PASS label=scanner-selftest path=bubbles/scripts/stale-deferral-lint-selftest.sh sha256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
PASS label=g085-guard path=bubbles/scripts/framework-dogfood-guard.sh sha256=29e34ba6463b031b965929ccecbccb9243acb86f8c1491d31e1af412df2758f7
PASS label=g085-selftest path=bubbles/scripts/framework-dogfood-guard-selftest.sh sha256=3794b40a58879029ef8e36dcfe29ffe90b74c4f3960747ef7ee3e33229178f8b
PASS label=g085-regression path=tests/regression/test_04_framework_dogfooding.sh sha256=9f614102c5d74b0020964c4af3ec131daa2d48373a8f243ab51d3f441335a26b
STABILITY_FAILURES=0
BUG012_POST_RUN_STABILITY_END
```

**Result:** PASS. No writer became active and no source, manifest, test,
planning, certification, BUG-013, IMP-020, or unrelated dirty byte changed
during the run. The only following edits are this test-owned append and
`state.json` execution metadata.

### Evidence Hygiene And Finding Accounting

The first regression-quality invocation emitted only an unrelated Conda
shell-startup diagnostic and no task framing; it was rejected as evidence. The
explicit working-directory retry above is the only regression-quality result
cited. Session storage did not expose a reliable first-command timestamp, so no
`runStartedAt` value is invented; the exact completion timestamp is recorded in
execution metadata.

| Finding | Disposition | Exact owner |
| --- | --- | --- |
| `BUG012-FRESH-SCANNER-001` | Addressed: T-BUG-012-11 passes 19/19 | none |
| `BUG012-FRESH-G085-001` | Addressed: focused 74/74, persistent 19/19, regression-quality 0 violations | none |
| `BUG012-FRESH-FRAMEWORK-001` | Addressed: T-BUG-012-12 exits 0 | none |
| `BUG012-FRESH-RELEASE-001` | Addressed: T-BUG-012-13 exits 0 | none |
| `BUG012-FRESH-MANIFEST-001` | Addressed: all 664 rows and both exact scanner hashes match | none |
| `BUG012-FRESH-CURRENTNESS-001` | Addressed: 942-file non-owned tree, HEAD, manifest, and protected hashes are stable | none |
| `BUG012-FRESH-EVIDENCE-PROBE-001` | Addressed: non-evidence probes were rejected; only explicit successful retries are cited | none |

**Current test verdict:** `TESTED` for the release-reconciled independent
handoff. The packet and scope remain `in_progress`; planning checkboxes,
`certification.*`, release publication, propagation, commit, and push remain
untouched and unclaimed. Under the persisted `bugfix-fastlane` phase order and
the packet's prior green-route contract, the exact next owner is
`bubbles.regression` for fresh amended-byte regression verification.

## Independent Current-Byte G085 Verification - 2026-07-15

This test-owned append supersedes only the immediately preceding currentness
verdict. It records independent execution from the canonical Bubbles checkout
without changing production code, tests, planning content, state, BUG-013, or
unrelated dirty work. No reset, commit, push, release, propagation, or terminal
status is claimed.

### Current Focused G085 Matrix Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (raw requested-scenario and verdict windows, in execution order):**

<!-- markdownlint-disable MD010 -->

```text
--- S6: malformed state.json (invalid JSON) ---
	✅ PASS: S6 malformed state.json (exit=2)
	✅ PASS: S6 stderr contains 'failureCode=E085-CURRENT-STATE-MALFORMED'
--- S6: numbered state.json symlink to external done JSON fails closed ---
	✅ PASS: S6 external current-state symlink (exit=2)
	✅ PASS: S6 symlink stderr contains 'failureCode=E085-CURRENT-STATE-MALFORMED'
	✅ PASS: S6 symlink stderr contains 'current numbered state.json files must be regular non-symbolic-link files'
--- S9: done state reachable only from another local branch is established ---
	✅ PASS: S9 all-ref historical done (exit=1)
	✅ PASS: S9 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	✅ PASS: S9 stderr contains 'historyPath=specs/001-foo/state.json'
--- S11: effective file:// shallow clone fails closed ---
	✅ PASS: S11 fixture is genuinely shallow
	✅ PASS: S11 shallow history (exit=2)
	✅ PASS: S11 stderr contains 'failureCode=E085-HISTORY-SHALLOW'
	✅ PASS: S11 stderr contains 'historyIntegrity=shallow'
--- S12a: extensions.partialClone metadata fails closed as partial history ---
	✅ PASS: S12a extensions.partialClone metadata (exit=2)
	✅ PASS: S12a stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12a stderr contains 'historyIntegrity=partial'
	✅ PASS: S12a stderr contains 'extensions.partialClone metadata is present'
--- S12b: remote.promisor metadata fails closed as partial history ---
	✅ PASS: S12b remote.promisor metadata (exit=2)
	✅ PASS: S12b stderr contains 'failureCode=E085-HISTORY-PARTIAL'
	✅ PASS: S12b stderr contains 'historyIntegrity=partial'
	✅ PASS: S12b stderr contains 'remote promisor metadata is enabled'
--- S14: malformed reachable historical state fails distinctly ---
	✅ PASS: S14 malformed historical state (exit=2)
	✅ PASS: S14 stderr contains 'failureCode=E085-HISTORICAL-STATE-MALFORMED'
	✅ PASS: S14 stderr contains 'historyIntegrity=malformed'
	✅ PASS: S14 stderr contains 'historyPath=specs/001-foo/state.json'
=== Selftest verdict ===
	Total assertions: 74
	Passed:           74
	Failed:           0
🟢 framework-dogfood-guard-selftest: PASSED
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS. The full focused run passed 74/74. The quoted raw windows
directly prove the requested symlink, shallow, partial, malformed-current,
malformed-history, and all-ref historical-done branches. The same full run also
passed current-done, genuine-first-adoption, changed/deleted done history,
failed traversal, exact-root, source-repository, and read-only checks.

### Current Persistent Regression Evidence

**Phase:** test
**Executed:** YES (current invocation, after the focused selftest)
**Command:** `bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

<!-- markdownlint-disable MD010 -->

```text
=== Regression: SCOPE-4 (Gate G085 — framework_dogfood_evidence_gate) ===
	✅ PASS: S1 source repo without specs/ — PASS (exit=0)
	✅ PASS: S2 source repo with specs/ — VIOLATION (exit=1)
	✅ PASS: S2 stderr cites Gate G085
	✅ PASS: S2 stderr cites source no-specs rule
	✅ PASS: S3 exactly one downstream done numbered spec — PASS (exit=0)
	✅ PASS: S3 current-done decision code
	✅ PASS: S3B external current-state symlink — INTEGRITY FAILURE (exit=2)
	✅ PASS: S3B current-state integrity failure code
	✅ PASS: S3B symlink diagnostic
	✅ PASS: S4 genuine first adoption — PASS (exit=0)
	✅ PASS: S4 first-adoption decision code
	✅ PASS: S4 proves complete history
	✅ PASS: S5 adversarial repositories have identical current states
	✅ PASS: S5 reachable historical done — VIOLATION (exit=1)
	✅ PASS: S5 historical-done failure code
	✅ PASS: S5 historical state path
	✅ PASS: S6 shallow fixture setup is effective
	✅ PASS: S6 shallow history — INTEGRITY FAILURE (exit=2)
	✅ PASS: S6 shallow-history failure code
=== Regression verdict ===
	Total assertions: 19
	Passed:           19
	Failed:           0
🟢 test_04_framework_dogfooding: REGRESSION PASSED
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS. The persistent production-guard regression passed 19/19.
It independently preserves the symlink, first-adoption, reachable-prior-done,
shallow-history, current-done, and canonical-source canaries. Partial,
malformed, and alternate-ref historical-done behavior is protected by the
focused 74-assertion matrix above rather than by this intentionally smaller
persistent file.

### Current Regression Quality Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

<!-- markdownlint-disable MD010 -->

```text
============================================================
	BUBBLES REGRESSION QUALITY GUARD
	Repo: /Users/pkirsanov/Projects/bubbles
	Timestamp: 2026-07-15T17:32:03Z
	Bugfix mode: true
============================================================
ℹ️  Scanning tests/regression/test_04_framework_dogfooding.sh
✅ Adversarial signal detected in tests/regression/test_04_framework_dogfooding.sh
============================================================
	REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
	Files scanned: 1
	Files with adversarial signals: 1
============================================================
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS. The persistent file contains an adversarial signal and no
silent-pass or regression-quality finding.

### Current Serial Framework And Release Evidence

**Phase:** test
**Executed:** YES (current invocation; commands completed serially)
**Command 1:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code 1:** 1
**Command 2:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code 2:** 1
**Claim Source:** executed
**Output (raw terminal verdict windows):**

<!-- markdownlint-disable MD010 -->

```text
stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)
Framework validation failed with 2 failing check(s).
Failed checks:
	- Release manifest freshness
	- Release manifest selftest
Command exited with code 1
FAIL: Framework validation
==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness
==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)
==> Release manifest freshness
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Release manifest freshness
==> Required release files
PASS: Required release files
==> No stray temp or backup files
PASS: No stray temp or backup files
Release check failed with 2 failing check(s).
Command exited with code 1
```

<!-- markdownlint-restore MD010 -->

**Result:** FAIL. Both required broad commands were run serially and both exit
`1`. The failure is not hidden by the green G085 checks: framework validation
fails its release-manifest freshness and release-manifest selftest checks, and
release-check consequently fails framework validation plus its own release
manifest freshness check.

### Current Release Drift Classification Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** enumerate `bubbles/release-manifest.json` managed and source-only checksum rows with `jq`, hash every referenced current file with `shasum -a 256`, and separately compare the two G085 script rows
**Exit Code:** 0 for the discriminator contract (exactly two unrelated mismatches, zero missing files, both G085 rows current)
**Claim Source:** executed
**Output:**

```text
BUG012_CURRENT_RELEASE_DRIFT_BEGIN
MANIFEST_VERSION=7.20.0
MANAGED_ROWS=613
SOURCE_ONLY_ROWS=51
MISMATCH path=bubbles/scripts/adversarial-resolve-selftest.sh expected=afba9a5ac830882eeecc7cdfc26d151cd30a13196607a65b06809ba611a6025a actual=6c399e3ad6a5a6882d121e1d3a7a0b563d404eb2b6c50843451d6bd966650ac5
MISMATCH path=bubbles/scripts/adversarial-resolve.sh expected=f7d4c0692c991baaa435296dbc9729741dad5a7b27ce4e2b064b89c63eb91b1e actual=e4cfad55b241cd982d94c07120c07f1ca5a7a860cec193fa85ce1868d91cc618
BUG012_MANIFEST_MATCH path=bubbles/scripts/framework-dogfood-guard.sh sha256=29e34ba6463b031b965929ccecbccb9243acb86f8c1491d31e1af412df2758f7
BUG012_MANIFEST_MATCH path=bubbles/scripts/framework-dogfood-guard-selftest.sh sha256=3794b40a58879029ef8e36dcfe29ffe90b74c4f3960747ef7ee3e33229178f8b
MISMATCH_COUNT=2
MISSING_COUNT=0
DRIFT_CLASSIFICATION=unrelated-adversarial-resolve-pair
BUG012_CURRENT_RELEASE_DRIFT_END
```

**Result:** PASS for classification, not for release readiness. All 664
manifest rows were examined. The only stale rows are the unrelated
`adversarial-resolve.sh` pair; both BUG-012 G085 rows match current bytes. This
test phase does not own those production/release bytes and did not regenerate
the manifest.

### Current Scenario-Link And Finding Accounting

The pre-append scenario-manifest audit resolved all five scenario IDs, all 11
linked-test references, and all 13 existing evidence references with zero
failures. This section is now the fresh evidence destination for every BUG-012
scenario.

**Phase:** test
**Executed:** YES (current invocation, after the report and evidence-link edit)
**Command:** parse `scenario-manifest.json` with `jq`; resolve every
`linkedTests[].file`; GitHub-slug every report heading; resolve every
`evidenceRefs[]` anchor; assert 5 scenarios, 11 linked-test references, 18
evidence references, 5 fresh references, and zero failures
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_POST_EDIT_SCENARIO_LINK_AUDIT_BEGIN
JSON_PARSE=PASS
PASS scenario=SCN-BUG-012-001 linkedTest=tests/regression/test_04_framework_dogfooding.sh
PASS scenario=SCN-BUG-012-001 linkedTest=bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS scenario=SCN-BUG-012-002 linkedTest=tests/regression/test_04_framework_dogfooding.sh
PASS scenario=SCN-BUG-012-002 linkedTest=bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS scenario=SCN-BUG-012-003 linkedTest=tests/regression/test_04_framework_dogfooding.sh
PASS scenario=SCN-BUG-012-003 linkedTest=bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS scenario=SCN-BUG-012-004 linkedTest=tests/regression/test_04_framework_dogfooding.sh
PASS scenario=SCN-BUG-012-004 linkedTest=bubbles/scripts/framework-dogfood-guard-selftest.sh
PASS scenario=SCN-BUG-012-005 linkedTest=bubbles/scripts/stale-deferral-lint-selftest.sh
PASS scenario=SCN-BUG-012-005 linkedTest=bubbles/scripts/cli.sh
PASS scenario=SCN-BUG-012-005 linkedTest=bubbles/scripts/cli.sh
PASS scenario=SCN-BUG-012-001 evidenceRef=report.md#independent-current-byte-g085-verification---2026-07-15
PASS scenario=SCN-BUG-012-002 evidenceRef=report.md#independent-current-byte-g085-verification---2026-07-15
PASS scenario=SCN-BUG-012-003 evidenceRef=report.md#independent-current-byte-g085-verification---2026-07-15
PASS scenario=SCN-BUG-012-004 evidenceRef=report.md#independent-current-byte-g085-verification---2026-07-15
PASS scenario=SCN-BUG-012-005 evidenceRef=report.md#independent-current-byte-g085-verification---2026-07-15
SCENARIOS=5
LINKED_TEST_REFS=11
EVIDENCE_REFS=18
FRESH_EVIDENCE_REFS=5
LINK_FAILURES=0
BUG012_POST_EDIT_SCENARIO_LINK_AUDIT_END
```

**Result:** PASS. Every linked test exists and every report anchor resolves on
the final evidence-link bytes.

| Finding | Current disposition | Exact next owner |
| --- | --- | --- |
| `BUG012-CURRENT-G085-001` | Addressed: focused selftest 74/74, persistent regression 19/19, regression-quality 0 findings | none |
| `BUG012-CURRENT-LINKS-001` | Addressed after edit: 5 scenarios, 11 test refs, 18 evidence refs, 5 fresh refs, zero failures | none |
| `BUG012-CURRENT-RELEASE-001` | OPEN: framework-validate and release-check each exit 1 because two unrelated adversarial-resolve manifest rows are stale | `bubbles.releases` |

**Current test verdict:** `NOT_TESTED` for the full selected handoff because
the required broad framework and release checks are red. The G085 focused and
persistent behavior is independently green on current bytes. After the
release-owned checksum reconciliation, the broad commands require a fresh
serial rerun before the packet can route to `bubbles.regression`.

## Post-Release Manifest Reconciliation Test Handoff - 2026-07-15

This test-owned append supersedes only the immediately preceding red broad-check
verdict. The focused G085 74/74, persistent G085 19/19, regression-quality, and
scenario-link results in that section remain prior-session context rather than
new proof from this invocation. This invocation independently re-executed the
two superseded broad rows on the release-reconciled current tree and audited the
generated manifest without changing source, tests, generated files, planning
artifacts, or certification.

### Post-Release Preflight Evidence

**Phase:** test
**Executed:** YES (current invocation)
**Command:** exact process/lock inspection plus SHA-256 comparison of
`bubbles/release-manifest.json`, `bubbles/scripts/stale-deferral-lint.sh`, and
`bubbles/scripts/stale-deferral-lint-selftest.sh` against the operator-supplied
values
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_POST_RELEASE_PREFLIGHT_BEGIN
RUN_STARTED_AT=2026-07-15T20:41:52Z
RUNTIME_LOCK_FILES=0
ACTIVE_VALIDATOR_WRITER_COUNT=0
HASH label=release-manifest path=bubbles/release-manifest.json expected=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6 actual=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6 result=PASS
HASH label=scanner path=bubbles/scripts/stale-deferral-lint.sh expected=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 actual=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 result=PASS
HASH label=scanner-selftest path=bubbles/scripts/stale-deferral-lint-selftest.sh expected=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 actual=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 result=PASS
PREFLIGHT_FAILURES=0
PREFLIGHT_RESULT=PASS
BUG012_POST_RELEASE_PREFLIGHT_END
```

**Result:** PASS. No active validator, manifest writer, or runtime lock was
present, and all three protected hashes matched exactly before test execution.

### T-BUG-012-12 Post-Release Framework Evidence

**Phase:** test
**Executed:** YES (current invocation, first accepted broad command)
**Command:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code:** 0
**Claim Source:** executed
**Output (verdict window from the full unfiltered terminal run):**

```text
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest

==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)

Framework validation passed.
```

**Result:** PASS. The canonical full framework command completed on the
reconciled current tree, including the amended 19-case scanner selftest and the
live scanner.

### T-BUG-012-13 Post-Release Release Evidence

**Phase:** test
**Executed:** YES (current invocation, serially after T-BUG-012-12)
**Command:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code:** 0
**Claim Source:** executed
**Output (release verdict window from the full unfiltered terminal run):**

```text
Framework validation passed.
PASS: Framework validation

==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness

==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness

==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)

==> Release manifest freshness
Release manifest is current: 7.20.0 (613 managed files)
PASS: Release manifest freshness

==> Required release files
PASS: Required release files

==> No stray temp or backup files
PASS: No stray temp or backup files

Release check passed.
```

**Result:** PASS. Canonical release readiness is green after the release-owned
two-row reconciliation; this is test evidence only and is not a release or
publication claim.

### Post-Release Complete Manifest Audit

**Phase:** test
**Executed:** YES (current invocation, after both broad rows)
**Commands:** `bash bubbles/scripts/generate-release-manifest.sh --check`;
status-checked `jq` enumeration and SHA-256 comparison of every
`managedFileChecksums` and `sourceOnlyFileChecksums` row; exact unique-row
comparison for the two BUG-012 scanner paths
**Exit Codes:** 0, 0
**Claim Source:** executed
**Output:**

```text
Release manifest is current: 7.20.0 (613 managed files)
BUG012_POST_RELEASE_MANIFEST_AUDIT_BEGIN
MANIFEST_SHA256=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
SCHEMA_AND_NONEMPTY_STATUS=PASS
MANAGED_DECLARED=613 MANAGED_NONEMPTY=PASS
SOURCE_ONLY_DECLARED=51 SOURCE_ONLY_NONEMPTY=PASS
ENTRY_ENUMERATION_EXIT=0
ENTRY_ENUMERATION_NONEMPTY=PASS
MANAGED_AUDITED=613 MANAGED_COUNT_STATUS=PASS
SOURCE_ONLY_AUDITED=51 SOURCE_ONLY_COUNT_STATUS=PASS
TOTAL_AUDITED=664 EXPECTED_TOTAL=664 TOTAL_COUNT_STATUS=PASS
MISSING=0 MISMATCHES=0 MALFORMED=0
SCANNER path=bubbles/scripts/stale-deferral-lint.sh ROW_COUNT=1 MANIFEST_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 ACTUAL_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 SUPPLIED_SHA256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 RESULT=PASS
SCANNER path=bubbles/scripts/stale-deferral-lint-selftest.sh ROW_COUNT=1 MANIFEST_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 ACTUAL_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 SUPPLIED_SHA256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 RESULT=PASS
AUDIT_FAILURES=0
MANIFEST_AUDIT_STATUS=PASS
BUG012_POST_RELEASE_MANIFEST_AUDIT_END
```

**Result:** PASS. Both checksum arrays are nonempty, all 664 declared rows were
audited, no file is missing or mismatched, and each scanner path has exactly one
manifest row matching both its supplied and current SHA-256.

### Pre-Edit Stability And Evidence Hygiene

**Phase:** test
**Executed:** YES (current invocation, immediately before this append/update)
**Command:** active-writer and runtime-lock check; dirty-path inventory hash;
raw certification-block hash; complete file-mode and SHA-256 fingerprint for
all 951 non-owned tracked and non-ignored files; protected hash comparisons
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG012_PRE_EDIT_STABILITY_BEGIN
RUNTIME_LOCK_FILES=0
ACTIVE_VALIDATOR_WRITER_COUNT=0
HEAD=9b785d7da7554082cfe0232998ef72cc99637087
DIRTY_PATH_COUNT=56 DIRTY_INVENTORY_SHA256=e71ad9669705d451d580357a90df1ea3fbc1134a3bfaa983c880a35cc6a0c165
CERTIFICATION_RAW_BLOCK_SHA256=fdf01915da4888a2a2671be092039c91e5b50636cff059934670023f9a88bee8
NON_OWNED_ENUMERATION_EXIT=0 NON_OWNED_FILES=951 NON_OWNED_TREE_SHA256=29f29d983d87224ea1a2ac24a369ab91473191d23814fee5e34f96401be45019
PROTECTED label=release-manifest path=bubbles/release-manifest.json sha256=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6 result=PASS
PROTECTED label=scanner path=bubbles/scripts/stale-deferral-lint.sh sha256=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40 result=PASS
PROTECTED label=scanner-selftest path=bubbles/scripts/stale-deferral-lint-selftest.sh sha256=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25 result=PASS
PRE_EDIT_STABILITY_FAILURES=0
PRE_EDIT_STABILITY_STATUS=PASS
BUG012_PRE_EDIT_STABILITY_END
```

Two commands initially landed in another workspace root because the terminal
selector changed sessions. Both failed before executing a BUG-012 command or
reading a BUG-012 file, were rejected as evidence, and were rerun from an
explicit absolute canonical-checkout `cd`. Only the successful canonical runs
above support this handoff.

The external-current-state symlink behavior is already covered and green in the
preceding focused and persistent evidence. This append does not reopen the stale
external-symlink probe as a defect.

### Post-Release Finding Accounting And Route

| Finding | Current disposition | Exact owner |
| --- | --- | --- |
| `BUG012-CURRENT-RELEASE-001` | Addressed: release-owned reconciliation is current and fresh serial T-BUG-012-12/T-BUG-012-13 executions both exit 0 | none |
| `BUG012-POST-RELEASE-MANIFEST-001` | Addressed: canonical check passes; 613 managed plus 51 source-only rows equal 664 audited rows with zero missing, mismatched, or malformed entries; both scanner rows are unique and exact | none |
| `BUG012-POST-RELEASE-CWD-001` | Addressed: two wrong-directory probes were rejected, then every cited command was rerun from the explicit canonical checkout | none |
| `BUG012-GAPS-STATUS-001` | OPEN and preserved: missing or unsupported current lifecycle status still requires the existing simplify-to-gaps lifecycle re-entry; no stale symlink defect is substituted for it | `bubbles.gaps` after the required regression and simplify phases |

**Current test verdict:** `TESTED` for the release-reconciled post-release
handoff and exactly the superseded broad rows. The packet, scope, and
certification remain `in_progress`; no regression, simplify, gaps, validation,
certification, release publication, commit, push, or Done outcome is claimed.
The exact next owner is `bubbles.regression` for fresh amended-byte regression.

## Amended-Byte Regression Attempt - 2026-07-15

This direct `bubbles.regression` invocation evaluated only BUG-012 and its
declared implementation/test surfaces. It did not edit production code, tests,
planning content, release metadata, BUG-013, IMP-020, downstream installations,
or `certification.*`. Fresh focused checks passed, but the required serial
framework and release commands were not started because a foreign
`release-check` process chain remained live. No regression verdict is issued
without those current-session broad results.

### Baseline Comparison

| Signal | Test handoff | Regression attempt | Delta | Status |
| --- | --- | --- | --- | --- |
| Structured-evidence scanner | 19 passed, 0 failed | 19 passed, 0 failed | 0 | Stable |
| Focused G085 classifier | 74 passed, 0 failed | 74 passed, 0 failed | 0 | Stable |
| Persistent G085 regression | 19 passed, 0 failed | 19 passed, 0 failed | 0 | Stable |
| Required-file regression quality | 2 files with adversarial signals; 0 findings | 2 files with adversarial signals; 0 findings | 0 | Stable |
| Scenario-contract coverage | 5 scenarios, 13 test rows, 0 unmapped | 5 scenarios, 13 test rows, 0 unmapped | 0 | Stable |
| Canonical framework validation | exit 0 | not run because foreign validator was live | unknown | Blocked |
| Canonical release readiness | exit 0 | not run because foreign validator was live | unknown | Blocked |

The repository command registry defines no line-coverage command for this Bash
framework checkout. Coverage regression is therefore measured by the declared
scenario contracts, Test Plan rows, persistent regression assertions, and the
canonical full-suite result. The first three are stable; the full-suite result
is unavailable in this invocation and is not inferred from prior evidence.

### Structured-Evidence Scanner Regression

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** `BUBBLES_SESSION_ID=bug012-regression-20260715T220121Z BUBBLES_AGENT_NAME=bubbles.regression BUBBLES_SPEC=BUG-012-g085-first-adoption-deadlock BUBBLES_SCOPE=Scope-1 BUBBLES_TOOL_LOG_TAGS=regression,T-BUG-012-11,adversarial,post-test bash bubbles/scripts/tool-log.sh bash bubbles/scripts/stale-deferral-lint-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
PASS: Case 1: clean tree (exit 0)
PASS: Case 2: lapsed deferred to v1.5 (exit 1)
PASS: Case 3: future deferred to v9.0 is allowed (exit 0)
PASS: Case 4: deferred to v2.0 at VERSION 2.0.0 is due (exit 1)
PASS: Case 5: deferred to v2.0 at VERSION 2.0.3 is due (exit 1)
PASS: Case 6: deferred until v1.0 variant (exit 1)
PASS: Case 7: CHANGELOG.md historical exclusion (exit 0)
PASS: Case 8: docs/v6-mcp-design.md exclusion (exit 0)
PASS: Case 9: missing VERSION fails (exit 1)
PASS: Case 10: lapsed caught alongside a legit future deferral (exit 1)
PASS: Case 11: own selftest path is excluded (exit 0)
PASS: Case 12: closed structured report evidence is allowed (exit 0)
PASS: Case 13: equivalent live report narrative fails (exit 1)
PASS: Case 14: incomplete evidence metadata fails (exit 1)
PASS: Case 15: unclosed text fence fails (exit 1)
PASS: Case 16: malformed or mismatched fence close fails (exit 1)
PASS: Case 17: shell-source fence fails (exit 1)
PASS: Case 18: fenced text outside report.md fails (exit 1)
PASS: Case 19: valid evidence mixed with live narrative fails (exit 1)

stale-deferral-lint-selftest: 19 pass, 0 fail
[tool-log] recorded exit=0 duration=432ms
BUG012_REGRESSION_T11_EXIT=0
```

**Result:** PASS. The sole new exemption remains the complete closed execution
record; live narrative, incomplete metadata, malformed or unclosed fences,
source fences, non-report files, and mixed content remain blocking inputs.

### Focused And Persistent G085 Regression

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** `BUBBLES_SESSION_ID=bug012-regression-20260715T220121Z BUBBLES_AGENT_NAME=bubbles.regression BUBBLES_SPEC=BUG-012-g085-first-adoption-deadlock BUBBLES_SCOPE=Scope-1 BUBBLES_TOOL_LOG_TAGS=regression,T-BUG-012-01-03,G085,focused,post-test bash bubbles/scripts/tool-log.sh bash bubbles/scripts/framework-dogfood-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output (selected adversarial branches and terminal verdict from the full run):**

<!-- markdownlint-disable MD010 -->

```text
--- S5: first adoption with one committed in_progress spec in a path containing spaces ---
	PASS: S5 genuine first adoption (exit=0)
	PASS: S5 stdout contains 'decisionCode=G085-FIRST-ADOPTION'
	PASS: S5 stdout contains 'currentDone=0'
	PASS: S5 stdout contains 'historicalDone=0'
	PASS: S5 stdout contains 'historyIntegrity=complete'
	PASS: S5 guard leaves refs, index, worktree, and object inventory unchanged
--- S6: numbered state.json symlink to external done JSON fails closed ---
	PASS: S6 external current-state symlink (exit=2)
	PASS: S6 symlink stderr contains 'failureCode=E085-CURRENT-STATE-MALFORMED'
	PASS: S6 symlink stderr contains 'current numbered state.json files must be regular non-symbolic-link files'
--- S7: done state changed to in_progress remains established ---
	PASS: S7 changed historical done (exit=1)
	PASS: S7 stderr contains 'failureCode=E085-ESTABLISHED-DONE-REMOVED'
	PASS: S7 stderr contains 'historyPath=specs/001-foo/state.json'
	PASS: S7 stderr contains 'historyCommit='
	PASS: S7 blob privacy stderr omits 'G085_PRIVATE_BLOB_PAYLOAD'
--- S11: effective file:// shallow clone fails closed ---
	PASS: S11 fixture is genuinely shallow
	PASS: S11 shallow history (exit=2)
	PASS: S11 stderr contains 'failureCode=E085-HISTORY-SHALLOW'
	PASS: S11 stderr contains 'historyIntegrity=shallow'
=== Selftest verdict ===
	Total assertions: 74
	Passed:           74
	Failed:           0
framework-dogfood-guard-selftest: PASSED
BUG012_REGRESSION_G085_FOCUSED_EXIT=0
```

**Result:** PASS. Current-done, genuine first adoption, symlink rejection,
changed/deleted/all-ref historical done, shallow/partial/query failure,
malformed history, exact-root, source invariance, and read-only behavior all
passed in the complete 74-assertion run.

**Phase:** regression
**Executed:** YES (current invocation, after the focused selftest)
**Command:** `BUBBLES_SESSION_ID=bug012-regression-20260715T220121Z BUBBLES_AGENT_NAME=bubbles.regression BUBBLES_SPEC=BUG-012-g085-first-adoption-deadlock BUBBLES_SCOPE=Scope-1 BUBBLES_TOOL_LOG_TAGS=regression,T-BUG-012-04-06-10,G085,persistent,adversarial,post-test bash bubbles/scripts/tool-log.sh bash tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
=== Regression: SCOPE-4 (Gate G085 - framework_dogfood_evidence_gate) ===
	PASS: S1 source repo without specs/ - PASS (exit=0)
	PASS: S2 source repo with specs/ - VIOLATION (exit=1)
	PASS: S2 stderr cites Gate G085
	PASS: S2 stderr cites source no-specs rule
	PASS: S3 exactly one downstream done numbered spec - PASS (exit=0)
	PASS: S3 current-done decision code
	PASS: S3B external current-state symlink - INTEGRITY FAILURE (exit=2)
	PASS: S3B current-state integrity failure code
	PASS: S3B symlink diagnostic
	PASS: S4 genuine first adoption - PASS (exit=0)
	PASS: S4 first-adoption decision code
	PASS: S4 proves complete history
	PASS: S5 adversarial repositories have identical current states
	PASS: S5 reachable historical done - VIOLATION (exit=1)
	PASS: S5 historical-done failure code
	PASS: S5 historical state path
	PASS: S6 shallow fixture setup is effective
	PASS: S6 shallow history - INTEGRITY FAILURE (exit=2)
	PASS: S6 shallow-history failure code
=== Regression verdict ===
	Total assertions: 19
	Passed:           19
	Failed:           0
test_04_framework_dogfooding: REGRESSION PASSED
BUG012_REGRESSION_G085_PERSISTENT_EXIT=0
```

<!-- markdownlint-restore MD010 -->

**Result:** PASS. The persistent real-Git regression retains the targeted
first-adoption/historical-done adversarial pair that would fail if the original
deadlock or a blanket zero-done exemption returned. This fresh run verifies the
durable green contract; the historical RED transcript is not relabeled as
current execution evidence.

### Regression Quality And Portability

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** `BUBBLES_SESSION_ID=bug012-regression-20260715T220121Z BUBBLES_AGENT_NAME=bubbles.regression BUBBLES_SPEC=BUG-012-g085-first-adoption-deadlock BUBBLES_SCOPE=Scope-1 BUBBLES_TOOL_LOG_TAGS=regression,quality,all-required,adversarial,silent-pass,post-test bash bubbles/scripts/tool-log.sh bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/stale-deferral-lint-selftest.sh tests/regression/test_04_framework_dogfooding.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUBBLES REGRESSION QUALITY GUARD
Repo: /Users/pkirsanov/Projects/bubbles
Bugfix mode: true
Scanning bubbles/scripts/stale-deferral-lint-selftest.sh
Adversarial signal detected in bubbles/scripts/stale-deferral-lint-selftest.sh
Scanning tests/regression/test_04_framework_dogfooding.sh
Adversarial signal detected in tests/regression/test_04_framework_dogfooding.sh
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 2
Files with adversarial signals: 2
[tool-log] recorded exit=0 duration=78ms
BUG012_REGRESSION_ALL_REQUIRED_QUALITY_EXIT=0
BUG012_REGRESSION_ALL_REQUIRED_QUALITY_END
```

**Result:** PASS. Both required regression executables contain adversarial
signals and no silent-pass, disabled-test, interception, or bailout finding.

**Phase:** regression
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/macos-portability-guard-selftest.sh`; `bash -n bubbles/scripts/framework-dogfood-guard.sh bubbles/scripts/framework-dogfood-guard-selftest.sh bubbles/scripts/stale-deferral-lint.sh bubbles/scripts/stale-deferral-lint-selftest.sh tests/regression/test_04_framework_dogfooding.sh`
**Exit Codes:** 0, 0
**Claim Source:** executed
**Output (terminal portability window and explicit parse result):**

```text
PASS: RED class5-readlink-f -> exit 1 + names 'class-5 readlink-f-absolutize'
PASS: RED class6-grep-P -> exit 1 + names 'class-6 grep-pcre'
PASS: RED class8-mapfile -> exit 1 + names 'class-8 mapfile-readarray'
PASS: RED class9-mktemp-suffix -> exit 1 + names 'class-9 mktemp-suffix'
PASS: RED class12-paste -> exit 1 + names 'class-12 paste-no-stdin-operand'
PASS: RED class13-date-ns -> exit 1 + names 'class-13 date-nanoseconds'
PASS: directory surface recurses into *.sh (nested dirty file caught)
PASS: PORTABILITY_SCAN_PATHS env surface is honored
PASS: no-surface invocation exits 2 (usage)
PASS: missing-path invocation exits 2 (usage)
PASS: guard parses (bash -n)
PASS: guard is self-portable (guard scans its own source -> exit 0)
PASS: guard source (comments stripped) has no literal GNU-only form
[selftest macos-portability-guard] OK - all assertions passed.
PORTABILITY_SELFTEST_EXIT=0
[tool-log] recorded exit=0 duration=8ms
TOUCHED_SHELL_SYNTAX_EXIT=0
BUG012_REGRESSION_PORTABILITY_END
```

**Result:** PASS. The portability guard and every touched BUG-012 shell/test
file parse successfully on the current macOS checkout.

### Packet, Cross-Spec, Coverage, And Design Review

**Phase:** regression
**Executed:** YES (current invocation)
**Commands:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/regression-baseline-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --verbose`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output (terminal summary windows):**

```text
All checked DoD items in scopes.md have evidence blocks
No unfilled evidence template placeholders in scopes.md
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
Test baseline comparison found in report
No done specs found - cross-spec regression check is informational only
Cross-spec check N/A (no done specs)
No route/endpoint collisions detected across specs
Regression baseline guard: PASSED
No spec/design freshness boundaries detected
No superseded scope sections detected
RESULT: PASS (0 failures, 0 warnings)
scenario-manifest.json covers 5 scenario contract(s)
All linked tests from scenario-manifest.json exist
Scenarios checked: 5
Test rows checked: 13
Scenario-to-row mappings: 5
Concrete test file references: 5
Report evidence references: 5
DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
RESULT: PASSED (0 warnings)
```

**Result:** PASS for the executed packet and scenario checks. Targeted reads
found no other spec packet that owns the G085 or stale-reference scanner
contract, and the changed tests add explicit assertions rather than weakening
the prior contract. BUG-012 changes no route, API, table, data model, UI flow,
or deployment path. The design remains internally coherent with the guard and
scanner scenarios, but cross-framework coherence is not declared complete
until the canonical full suite runs.

### Protected Bytes And Deployment Applicability

**Phase:** regression
**Executed:** YES (current invocation, before report/state edits)
**Command:** compare pre/post SHA-256 for BUG-012, BUG-013, and IMP-020 protected files; compare HEAD and the raw certification object; run scoped `git diff --check`; classify deployment paths with `git diff --quiet -- deploy .github/workflows/build.yml config scripts/deploy`
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** Every printed post-run hash equals the corresponding
pre-run hash captured at `2026-07-15T22:01:21Z`; HEAD and the certification
object also match. Exit `0` from the deployment path comparison means the
deployment regression scan is not applicable to this diff.
**Output:**

```text
HEAD=9b785d7da7554082cfe0232998ef72cc99637087
release-manifest=ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6
scanner=c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40
scanner-selftest=250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25
g085-guard=29e34ba6463b031b965929ccecbccb9243acb86f8c1491d31e1af412df2758f7
g085-selftest=3794b40a58879029ef8e36dcfe29ffe90b74c4f3960747ef7ee3e33229178f8b
g085-regression=9f614102c5d74b0020964c4af3ec131daa2d48373a8f243ab51d3f441335a26b
imp020-resolver=33b6572fd73aa4fec7151ba9f693b0521e36547856ff5ce6a31277335b885f95
imp020-resolver-selftest=4a26c8dbc30b39aa8d6de2f3631b8e95c59394ffeb521af76d2a90bbdf83d0cd
imp020-aggregate=fa08970d4a430183d3eda345244e0119203adebb5119c204dccc873dbfcc56e9
imp020-aggregate-selftest=00419d6913fa0cd6e261fb3d7098be5a8f7926ab5f0b86fe588061ad00a5d8f7
bug013-reality-scan=29789e09f019172f1677e98dec6fe5afd028c9395b945e48194434d5b56fc55d
bug013-storage-scan=77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3
bug013-regression=4aa18e2e4d8cca91b017661f5bbeaadc521443a250fb0864a33d5304e6840ce2
certification-object=07c1e75c4944b7e2d9da7d472bcfb6adc36622e88335849b31ade6982823d3b0
POSTRUN_HASH_EXIT=0
POSTRUN_CERTIFICATION_HASH_EXIT=0
SCOPED_DIFF_CHECK_EXIT=0
DEPLOYMENT_SURFACE_DIFF_EXIT=0
DEPLOYMENT_REGRESSION_SCAN=NOT_APPLICABLE
```

### Broad-Suite Concurrency Blocker

**Phase:** regression
**Executed:** YES (current invocation; process classification only)
**Commands:** `pgrep -fl 'bubbles/scripts/(cli\.sh|framework-validate\.sh|generate-release-manifest\.sh|release-check|tool-log\.sh)'`; `ps -p 80360,80444,80453 -o pid=,ppid=,state=,etime=,command=`; `pgrep -P 80453`; `ps -ww -p 23136 -o pid=,ppid=,state=,etime=,command=`
**Exit Codes:** 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
BUG012_REGRESSION_QUIESCENCE_BEGIN
80360 bash bubbles/scripts/cli.sh release-check
80444 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/release-check.sh
80453 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh
ACTIVE_VALIDATOR_QUERY_EXIT=0
QUIESCENCE_RESULT=BLOCKED
BROAD_VALIDATION_SAFE=NO
BUG012_REGRESSION_PROCESS_STATE_BEGIN
80360 48081 S+ 19:05 bash bubbles/scripts/cli.sh release-check
80444 80360 S+ 19:05 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/release-check.sh
80453 80444 S+ 19:05 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/framework-validate.sh
DIRECT_CHILD_PIDS=23136
23136 80453 S+ 08:28 bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/install-provenance-selftest.sh
BUG012_REGRESSION_FOREIGN_CHILD_DETAIL_END
```

**Result:** BLOCKED for broad execution. The process chain is live and sleeping,
not zombie metadata. This invocation neither killed it nor started a competing
framework/release run.

**Phase:** regression
**Commands not run:** `bash bubbles/scripts/cli.sh framework-validate`; `bash bubbles/scripts/cli.sh release-check`
**Exit Codes:** not available because neither command was started
**Claim Source:** not-run
**Reason:** A foreign serial `release-check` chain already owned the broad
validation surface and was still executing `install-provenance-selftest.sh`.

> **Uncertainty Declaration**
> **What was attempted:** Two quiescence checks separated by all focused BUG-012 regression work, followed by live process-state and child-process classification.
> **What was observed:** PIDs 80360, 80444, 80453, and child 23136 remained live; the child was `install-provenance-selftest.sh`.
> **Why this is uncertain:** Focused checks cannot establish the current canonical full-suite or release-readiness verdict, and prior test-phase broad results are not reused as regression evidence.
> **What would resolve this:** After that exact foreign process chain exits, rerun the two commands serially from `/Users/pkirsanov/Projects/bubbles`, then repeat protected-hash comparison and regression closeout checks.

### Finding Accounting And Route

| Finding | Regression disposition | Exact owner |
| --- | --- | --- |
| `BUG012-REGRESSION-SCANNER-001` | Addressed: scanner selftest passes 19/19 on current bytes | none |
| `BUG012-REGRESSION-G085-001` | Addressed: focused 74/74 and persistent 19/19 pass on current bytes | none |
| `BUG012-REGRESSION-QUALITY-001` | Addressed: both required files have adversarial signals and zero quality findings | none |
| `BUG012-REGRESSION-PORTABILITY-001` | Addressed: portability selftest and all touched-shell parse checks exit 0 | none |
| `BUG012-REGRESSION-TRACEABILITY-001` | Addressed: 5 scenarios, 13 rows, 5 mappings, and zero warnings | none |
| `BUG012-REGRESSION-PRESERVATION-001` | Addressed: all frozen BUG-012, BUG-013, IMP-020, HEAD, and certification hashes remain exact | none |
| `BUG012-REGRESSION-BROAD-CONCURRENCY-001` | OPEN: current framework and release commands were not run while foreign PIDs 80360/80444/80453/23136 owned the broad surface | `bubbles.regression` after the foreign chain exits |
| `BUG012-GAPS-STATUS-001` | OPEN and preserved: missing or unsupported current lifecycle status remains assigned to the existing simplify-to-gaps re-entry | `bubbles.gaps` after regression and simplify |

**Regression verdict:** NOT ISSUED. A green focused matrix does not authorize
`REGRESSION_FREE` while the mandatory full suite and release check are absent,
and no current evidence supports either a code-regression or design-conflict
verdict. This attempt returns `route_required` to `bubbles.regression` for the
two missing serial broad commands. The packet, scope, and certification remain
`in_progress`.

### Route Closeout Evidence

**Phase:** regression
**Executed:** YES (current invocation, after report/state reconciliation)
**Commands:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/regression-baseline-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --verbose`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; exact `jq` route assertions and certification-object SHA-256; scoped `git diff --check`
**Exit Codes:** 0, 0, 0, 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
Test baseline comparison found in report
Cross-spec check N/A (no done specs)
No route/endpoint collisions detected across specs
Regression baseline guard: PASSED
REGRESSION_BASELINE_EXIT=0
RESULT: PASS (0 failures, 0 warnings)
ARTIFACT_FRESHNESS_EXIT=0
Scenarios checked: 5
Test rows checked: 13
Scenario-to-row mappings: 5
DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
RESULT: PASSED (0 warnings)
TRACEABILITY_EXIT=0
STATE_ASSERTIONS_EXIT=0
STATUS=in_progress
ACTIVE_AGENT=bubbles.regression
CURRENT_PHASE=regression
NEXT_OWNER=bubbles.regression
CERTIFICATION_STATUS=in_progress
LAST_HISTORY_AGENT=bubbles.regression
LAST_HISTORY_OUTCOME=route_required
07c1e75c4944b7e2d9da7d472bcfb6adc36622e88335849b31ade6982823d3b0  -
CERTIFICATION_HASH_EXIT=0
STATE_DIFF_CHECK_EXIT=0
BUG012_REGRESSION_CLOSEOUT_END
```

**Result:** PASS for the nonterminal route. This closeout validates the packet
and preserves certification; it does not replace the two broad commands named
in `BUG012-REGRESSION-BROAD-CONCURRENCY-001`.

## Resumed Broad Regression Classification - 2026-07-16

This regression-owned append resumes only the two mandatory broad commands
left unexecuted by the preceding regression attempt. It does not edit BUG-012
production code, tests, planning content, generated release inputs, BUG-013,
BUG-018, BUG-019, IMP-020, downstream installations, or `certification.*`.
The shared validation lane was occupied by a foreign `release-check` chain at
entry; that chain completed before this invocation acquired the lane.

### Focused Rerun Decision

The prior current-session focused evidence remains `19/19` for the structured-
evidence scanner, `74/74` for the focused G085 classifier, and `19/19` for the
persistent G085 regression. Those results are not relabeled as new execution.
The requested discriminator was byte identity: all five BUG-012 executable
surfaces retained the exact hashes recorded by the prior regression attempt,
so another focused execution was not triggered.

**Phase:** regression
**Executed:** YES (current invocation; identity discriminator only)
**Commands:** quiescence scan; SHA-256 comparison against the preceding
regression evidence; final `shasum -a 256` snapshot
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** Exact executable identity means the user-requested
"rerun only if bytes changed" condition is false. This proves why no focused
command was repeated; it does not manufacture a new `19/74/19` execution.
**Output:**

```text
ACTIVE_VALIDATOR_SCAN_EXIT=1
QUIESCENCE=PASS
HASH_FAILURES=0
BUG012_EXECUTABLE_HASH_CHANGES=0
c5a2db3325cde370539d6df3cbebf5741563433c85a2c3f6c2a6f02473c74d40  bubbles/scripts/stale-deferral-lint.sh
250644b4140a3883b484102bf3a26b1976d2f27acd97553ba2aff77c93784a25  bubbles/scripts/stale-deferral-lint-selftest.sh
29e34ba6463b031b965929ccecbccb9243acb86f8c1491d31e1af412df2758f7  bubbles/scripts/framework-dogfood-guard.sh
3794b40a58879029ef8e36dcfe29ffe90b74c4f3960747ef7ee3e33229178f8b  bubbles/scripts/framework-dogfood-guard-selftest.sh
9f614102c5d74b0020964c4af3ec131daa2d48373a8f243ab51d3f441335a26b  tests/regression/test_04_framework_dogfooding.sh
ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6  bubbles/release-manifest.json
CERTIFICATION_OBJECT_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
REPORT_PREFIX_BYTES=284444
REPORT_PREFIX_SHA256=516fdf765399ecb22ddce2c3452deddda3c761dae02612a7951fcc1d9df41389
```

### Mandatory Serial Broad Evidence

**Phase:** regression
**Executed:** YES (current invocation; commands completed serially)
**Command 1:** `bash bubbles/scripts/cli.sh framework-validate`
**Exit Code 1:** 1
**Command 2:** `bash bubbles/scripts/cli.sh release-check`
**Exit Code 2:** 1
**Claim Source:** executed
**Output (terminal verdict windows from the full unfiltered runs):**

<!-- markdownlint-disable MD010 -->

```text
stale-deferral-lint-selftest: 19 pass, 0 fail
PASS: Stale-deferral lint selftest
==> Stale-deferral lint (live)
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
PASS: Stale-deferral lint (live)
Framework validation failed with 3 failing check(s).
Failed checks:
	- Release manifest freshness
	- Release manifest selftest
	- BUG-019 state-transition compound MJS test-path regression
Command exited with code 1
```

```text
FAIL: Framework validation
==> Capability ledger docs freshness
Capability ledger docs are current: 22 shipped, 1 partial, 0 proposed
PASS: Capability ledger docs freshness
==> Framework stats freshness
Framework stats are current: 41 Agents · 109 Gates · 60 Workflow Modes · 30 Phases (v7.20.0)
PASS: Framework stats freshness
==> Cheatsheet freshness (v6.0 / B7)
PASS: Cheatsheet freshness (v6.0 / B7)
==> Release manifest freshness
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Release manifest freshness
==> Required release files
PASS: Required release files
==> No stray temp or backup files
PASS: No stray temp or backup files
Release check failed with 2 failing check(s).
```

<!-- markdownlint-restore MD010 -->

**Result:** FAIL. The required broad commands ran in the requested order and
did not overlap. `release-check` began only after `framework-validate` returned
exit `1`. The broad failure names no BUG-012 check; it names foreign current-
tree work described below.

### Foreign Functional Failure Classification

BUG-019 created and registered
`tests/regression/test_26_state_transition_spec_mjs_path.sh` after BUG-012's
clean preflight. BUG-019's current state is `blocked`, names
`AWAITING_IMPLEMENTATION_FIX`, and routes to `bubbles.implement`. The direct
registered regression reproduces the same broad failure: baseline and genuine-
missing-file controls pass, while compound MJS truncation and invalid
prefix/prose acceptance produce 13 assertion failures.

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** `bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed
**Output (failure and terminal summary window):**

```text
PASS: baseline packet exits zero
PASS: baseline reaches production Check 8
PASS: baseline exercises the existing-file branch
FAIL: compound and compatibility matrix exits zero (expected exit 0, got 1)
FAIL: reporter compound path reaches the complete existing-file branch
FAIL: compound test path reaches the complete existing-file branch
FAIL: reporter marker prefix is never checked as a missing file
FAIL: compound-test marker prefix is never checked as a missing file
FAIL: adversarial-only packet exits zero (expected exit 0, got 1)
FAIL: all-invalid contexts reach the no-concrete-path branch
PASS: prose never triggers shorter basename resolution
PASS: genuinely missing allowed test path exits nonzero
PASS: missing allowed path reaches the existing Check 8 failure branch
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=25
FAILED=13
BUG-019 state-transition Check 8 regression FAILED
BUG012_FOREIGN_BUG019_DIAGNOSTIC_EXIT=1
```

**Result:** FAIL in foreign BUG-019, not BUG-012. No inline repair is permitted
from this diagnostic phase. BUG-019's own state routes the bounded production
repair to `bubbles.implement`.

### Foreign Release Drift Classification

The standalone release-manifest selftest exits `1` only because the committed
manifest is stale; its remaining 19 structure and inventory assertions pass.
A complete temporary-manifest comparison made no worktree write and found five
managed checksum changes, all owned outside BUG-012:

- IMP-020: `bubbles/scripts/adversarial-resolve-selftest.sh`;
- BUG-019: `bubbles/scripts/framework-validate.sh` and
  `bubbles/scripts/install-provenance-selftest.sh`;
- BUG-018: `bubbles/scripts/traceability-guard.sh` and
  `bubbles/scripts/traceability-guard-selftest.sh`.

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** `bash bubbles/scripts/release-manifest-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed
**Output:**

```text
Running release-manifest selftest...
Scenario: release hygiene generates one complete trust manifest for downstream installs.
Release manifest is stale. Run bubbles/scripts/generate-release-manifest.sh
FAIL: Committed release manifest is current
PASS: Release manifest exists
PASS: Manifest records release version
PASS: Manifest records source git SHA
PASS: Manifest records trust docs digest
PASS: Manifest records framework-managed file count (613)
PASS: Managed checksum inventory includes framework agents
PASS: Managed checksum inventory includes shared CLI surface
PASS: Manifest records source-only file count (51)
PASS: Source-only checksum inventory includes G094 regression test
PASS: Managed checksum inventory includes IMP-020 S2 aggregator
PASS: Managed checksum inventory includes IMP-020 S2 aggregator selftest
PASS: Source-only checksum inventory includes IMP-020 S2 sample schema
PASS: IMP-020 S2 sample schema remains source-only
PASS: Manifest exposes foundation as a supported profile
PASS: Manifest exposes delivery as a supported profile
release-manifest selftest failed with 1 issue(s).
BUG012_FOREIGN_MANIFEST_DIAGNOSTIC_EXIT=1
```

**Phase:** regression
**Executed:** YES (current invocation)
**Command:** generate a temporary manifest with
`bash bubbles/scripts/generate-release-manifest.sh --repo-root "$PWD" --output "$manifest_tmp"`, compare both checksum arrays with Node, then remove the temporary file via the EXIT trap
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
Updated release manifest: 7.20.0 (613 managed files)
TEMP_GENERATOR_EXIT=0
MANIFEST_DELTA section=managedFileChecksums kind=CHANGED path=bubbles/scripts/adversarial-resolve-selftest.sh committed=4a26c8dbc30b39aa8d6de2f3631b8e95c59394ffeb521af76d2a90bbdf83d0cd generated=9b3251ab0b2f05b0902f7e8add2848c884449cbc067c582d5d7a914148b2dbc9
MANIFEST_DELTA section=managedFileChecksums kind=CHANGED path=bubbles/scripts/framework-validate.sh committed=1354085b22169309b636b4db574bf499979000d587159c624d407b6f15e6636b generated=189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d
MANIFEST_DELTA section=managedFileChecksums kind=CHANGED path=bubbles/scripts/install-provenance-selftest.sh committed=640e89e11d765cb57c0200d835e3a50b9478145f3062e3cb5f4475f701a631f1 generated=15ca35d04c5d2877fbbc727a837a7f5d60839e927e6879a360b69e9f6d69dbaa
MANIFEST_DELTA section=managedFileChecksums kind=CHANGED path=bubbles/scripts/traceability-guard-selftest.sh committed=4c138b753f2a338141efb0a79e2725bece5e26854ab6efc36de1e6cb42bf2a38 generated=691b022fe8a7c4018844c7c74484d108fc3472ce6f0ea917b72e68882306d12f
MANIFEST_DELTA section=managedFileChecksums kind=CHANGED path=bubbles/scripts/traceability-guard.sh committed=dd9784a195c6832a696024406cd73b3aeb9dbc603bed3b53065b44e7eec9f668 generated=dfc4e00a73d8018884a2ae2df1401cc24acca53014b587778c250cc6e9dcd3d9
MANIFEST_DELTA_TOTAL=5
COMMITTED_MANAGED_COUNT=613
GENERATED_MANAGED_COUNT=613
COMMITTED_SOURCE_ONLY_COUNT=51
GENERATED_SOURCE_ONLY_COUNT=51
MANIFEST_COMPARE_EXIT=0
```

**Result:** PASS for classification, not release readiness. BUG-018's current
packet routes its own blocking Research Lab finding to `bubbles.bug`; IMP-020
S2 assigns the changed selftest to `bubbles.test`; BUG-019 routes its production
failure to `bubbles.implement`. `bubbles.releases` owns manifest regeneration
after those source owners stabilize their bytes.

### Baseline, Coverage, And Coherence Delta

| Signal | Prior current-session evidence | Resumed result | Classification |
| --- | --- | --- | --- |
| Structured-evidence scanner | 19 passed, 0 failed | not repeated; executable hash exact | BUG-012 stable |
| Focused G085 classifier | 74 passed, 0 failed | not repeated; executable hash exact | BUG-012 stable |
| Persistent G085 regression | 19 passed, 0 failed | not repeated; executable hash exact | BUG-012 stable |
| Canonical framework validation | exit 0 | exit 1 | foreign BUG-019 plus release drift |
| Canonical release readiness | exit 0 | exit 1 | foreign framework failure plus release drift |

The framework command registry defines no line-coverage command. Scenario and
assertion coverage therefore remain the declared five-scenario/13-row mapping
plus the focused and persistent assertion counts; no BUG-012 test or source
byte changed. BUG-012 changes no route, API, table, UI flow, deployment path,
or shared data contract. No design contradiction was detected. Deployment
regression detection remains not applicable to the BUG-012 diff.

### Resumed Finding Accounting And Route

| Finding | Regression disposition | Exact owner |
| --- | --- | --- |
| `BUG012-REGRESSION-BROAD-CONCURRENCY-001` | ADDRESSED: the replacement foreign release chain completed, final quiescence passed, and both mandatory commands executed serially | none |
| `BUG012-REGRESSION-IN-SCOPE-001` | ADDRESSED for attribution: all BUG-012 executable hashes remain exact and no broad failure names a BUG-012 check; no clean broad verdict is claimed | none |
| `BUG012-REGRESSION-FOREIGN-BUG019-001` | OPEN: registered BUG-019 regression exits 1 with 13 compound-path and invalid-candidate failures; BUG-019 state names `AWAITING_IMPLEMENTATION_FIX` | `bubbles.implement` |
| `BUG012-REGRESSION-FOREIGN-BUG018-001` | OPEN: two BUG-018 traceability files differ from release metadata; BUG-018 state retains 37 Research Lab Feature 007 packet findings | `bubbles.bug`, then `bubbles.releases` |
| `BUG012-REGRESSION-FOREIGN-IMP020-001` | OPEN: IMP-020's resolver selftest changed after BUG-012 preflight and differs from release metadata | `bubbles.test`, then `bubbles.releases` |
| `BUG012-REGRESSION-FOREIGN-MANIFEST-001` | OPEN: five foreign managed checksum rows are stale; regeneration before source stabilization would immediately drift again | `bubbles.releases` after the source owners above |
| `BUG012-GAPS-STATUS-001` | OPEN and preserved: missing or unsupported current lifecycle status remains assigned to the existing simplify-to-gaps re-entry | `bubbles.gaps` after a green regression phase and simplify |

### Regression Verdict

⚠️ REGRESSION_DETECTED

The current tree has one foreign failing registered regression and five foreign
release-manifest checksum deltas. No failure is attributable to BUG-012, but a
green focused matrix cannot authorize `REGRESSION_FREE` while the mandatory
broad commands exit `1`. The BUG-012 packet and certification remain
`in_progress`; regression does not advance to `simplify`. The immediate owner
is `bubbles.implement` for BUG-019's production repair. Release reconciliation
and a fresh BUG-012 regression execution follow only after all named foreign
source owners return stable bytes.

### Post-Edit Route Validation

**Phase:** regression
**Executed:** YES (current invocation, after report/state reconciliation)
**Commands:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/regression-baseline-guard.sh improvements/BUG-012-g085-first-adoption-deadlock --verbose`; `bash bubbles/scripts/traceability-guard.sh improvements/BUG-012-g085-first-adoption-deadlock`; `bash bubbles/scripts/stale-deferral-lint.sh "$PWD"`; scoped `git diff --check`; exact state, certification, and report-prefix assertions
**Exit Codes:** 0, 0, 0, 0, 0, 0, 0
**Claim Source:** executed
**Output:**

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
ARTIFACT_FRESHNESS_EXIT=0
Regression baseline guard: PASSED
REGRESSION_BASELINE_EXIT=0
Scenarios checked: 5
Test rows checked: 13
Scenario-to-row mappings: 5
DoD fidelity scenarios: 5 (mapped: 5, unmapped: 0)
RESULT: PASSED (0 warnings)
TRACEABILITY_EXIT=0
[stale-deferral-lint] OK — no lapsed forward-references (current VERSION 7.20.0)
STALE_DEFERRAL_LIVE_EXIT=0
SCOPED_DIFF_CHECK_EXIT=0
STATE_ASSERTIONS=PASS
STATUS=in_progress
CERTIFICATION_STATUS=in_progress
ACTIVE_AGENT=bubbles.regression
CURRENT_PHASE=regression
NEXT_OWNER=bubbles.implement
BLOCKER_CODE=FOREIGN_BROAD_VALIDATION_FAILURES
LAST_HISTORY_OUTCOME=route_required
COMPLETED_PHASE_CLAIMS=implement,test,regression,simplify
CERTIFICATION_OBJECT_SHA256=0060ef7ad0dbc09d9d9136ee84c3bc29ebe81e527752e91ea4ea4e1fa3977560
REPORT_PREFIX_BYTES=284444
REPORT_PREFIX_SHA256=516fdf765399ecb22ddce2c3452deddda3c761dae02612a7951fcc1d9df41389
STATE_AND_PREFIX_ASSERTIONS_EXIT=0
```

**Result:** PASS for the nonterminal owner route. The packet remains
`in_progress`; no certification, Done, release, commit, or push claim is made.
