# BUG-054 Report

## Summary

This phase created the complete root bug packet. It inspected the G128 reader,
session and tool producers, exact-session usage adapter, and production callers.

No production source, test, registry, generated file, or downstream repository
was changed.

## Identity Provenance

The canonical packet identity is `BUG-054`. Before adjudication, this untracked
packet used the colliding draft label
`BUG-037-session-cap-cross-session-attribution`. That draft identity was never
canonical. Canonical `BUG-037` is
`BUG-037-uservalidation-opt-out-acceptance` and remains unchanged.

Historical command lines, captured output, receipt tags, and hashes below stay
verbatim. Any surviving `BUG-037`, `BUG037`, `B037`, or `bug037` token is an
explicit pre-adjudication evidence label for this packet, not a canonical ID.
Current prose uses the one-to-one `BUG-054` or `B054` identity.

The retained byte copy is
`bugs/_superseded-draft-037-session-cap-cross-session-attribution`. It is a
superseded draft archive, not a canonical bug and not delivery evidence. The
canonical root-bug namespace uses `bugs/BUG-*`, which excludes this path.

## ID-DELETE-001 Relocation Attempt - 2026-09-02

### Retained Byte Proof

**Phase:** bug
**Command:** Structured tool-log row 275 contains the exact bounded nine-file
`cmp` command.
**Exit Code:** 0
**Claim Source:** executed

```text
ID_DELETE_001_COPY_COMPARE_BEGIN
EXPECTED_FILE_COUNT=9
FILE=bug.md CMP_EXIT=0
FILE=design.md CMP_EXIT=0
FILE=report.md CMP_EXIT=0
FILE=scenario-manifest.json CMP_EXIT=0
FILE=scopes.md CMP_EXIT=0
FILE=spec.md CMP_EXIT=0
FILE=state.json CMP_EXIT=0
FILE=test-plan.json CMP_EXIT=0
FILE=uservalidation.md CMP_EXIT=0
COPY_COMPARE_FAILURES=0
ID_DELETE_001_COPY_COMPARE_END
```

The capture has stdout SHA-256
`26f214996332126603970d2d4d87034214a0b24ca852d745b2c6db20abb57312`.

### Source Removal Blocker

**Phase:** bug
**Command:** Structured tool-log rows 274 and 276 contain the exact bounded
canonical identity scan.
**Exit Code:** 1
**Claim Source:** executed

```text
ID_DELETE_001_DUPLICATE_SCAN_BEGIN
CANONICAL_GLOB=bugs/BUG-*
CANONICAL_DIRECTORY_COUNT=6
CANONICAL_DIRECTORY=bugs/BUG-032-planning-maturity-guard-false-positives ID=BUG-032
CANONICAL_DIRECTORY=bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization ID=BUG-033
CANONICAL_DIRECTORY=bugs/BUG-035-validation-control-plane-churn-and-scope-overreach ID=BUG-035
CANONICAL_DIRECTORY=bugs/BUG-036-completed-scopes-count-format-sensitive ID=BUG-036
CANONICAL_DIRECTORY=bugs/BUG-037-session-cap-cross-session-attribution ID=BUG-037
CANONICAL_DIRECTORY=bugs/BUG-054-session-cap-cross-session-attribution ID=BUG-054
DUPLICATE_CANONICAL_ID_COUNT=0
BUG054_CANONICAL_DIRECTORY_COUNT=1
BUG054_CANONICAL_DIRECTORY=bugs/BUG-054-session-cap-cross-session-attribution
BUG054_STATE_ID=BUG-054
OLD_DRAFT_PATH_PRESENT=true
SUPERSEDED_DRAFT_PATH_PRESENT=true
SUPERSEDED_DRAFT_FILE_COUNT=9
SUPERSEDED_DRAFT_CANONICAL_GLOB_MATCH_COUNT=0
ID_DELETE_001_DUPLICATE_SCAN_END
```

The retained path is excluded as intended. The original path still exists, so
the relocation is incomplete. The patch API reported each deletion as applied,
but inode and mtime inspection showed unchanged original files. Shell `mv`,
`rm`, `unlink`, and redirection remain unused per the operator constraint.

### Immediate Canonical Checks

**Phase:** bug
**Claim Source:** executed

- Tool-log row 273 records canonical artifact lint at exit 0.
- Tool-log row 277 records reference validation at exit 0.
- Tool-log rows 274 and 276 preserve both failed path-absence checks at exit 1.

## Completion Statement

Bug discovery and packet creation are complete. Production implementation,
red-stage regression execution, green-stage execution, validation, audit, and
certification have not run in this phase. The packet remains `in_progress`.

## Matching Packet Check

**Phase:** bug
**Command:** `find bugs -mindepth 1 -maxdepth 1 -type d -print`, followed by the exact matching-defect grep recorded below
**Exit Code:** 0 for the bounded wrapper. The matching grep returned 1.
**Claim Source:** interpreted

```text
BUG037_PACKET_CHECK_BEGIN
bugs/BUG-032-planning-maturity-guard-false-positives
bugs/BUG-035-validation-control-plane-churn-and-scope-overreach
bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization
bugs/BUG-036-completed-scopes-count-format-sensitive
MATCHING_DEFECT_SEARCH_EXIT=1
BUG037_PACKET_CHECK_END
```

**Interpretation:** Existing packets include a broader session-lifecycle bug,
but none names or specifies G128 cross-session attribution. The filing phase
provisionally used the colliding draft identity `BUG-037`. Current adjudication
supersedes it with canonical `BUG-054`.

## Source Inspection Evidence

**Phase:** bug
**Command:** bounded grep inspection of G128, state-snapshot, tool-log, usage-adapter, and caller source paths
**Exit Code:** 0
**Claim Source:** interpreted

```text
BUG037_INSPECTION_BEGIN
287:      (.convergenceLoops // [])
292:    toolPresent:  ((has("toolCallCount")) and (.toolCallCount != null)),
297:        (.turnSnapshots // [])
345:TOOL_LOG="$REPO_ROOT/.specify/runtime/tool-calls.jsonl"
351:    [ .[] | objects | select(has("stdoutBytes") or has("stderrBytes"))
379:      USAGE_SESSION="$(bash "$USAGE_ADAPTER_PATH" session 2>/dev/null || true)"
731:          hostSessionId: (if $host_session == "" then null else $host_session end),
793:         | select(.specDir != $specDir or .agent != $agent)
797:         iterationCount: $iterationCount,
61:SESSION_ID="${BUBBLES_SESSION_ID:-}"
63:  # Auto-generate a session id keyed by pid + timestamp.
64:  SESSION_ID="auto-$(date -u +%Y%m%dT%H%M%S)-$$"
171:SESSION_ID="$SESSION_ID" \
225:    "sessionId": os.environ['SESSION_ID'],
40:SESSION_FILTER="${2:-}"
68:      find "$root" -path '*/chatSessions/*' -name "${SESSION_FILTER}*" -type f 2>/dev/null || true
118:  session)
162:      session) echo '{}'; exit 0 ;;
bubbles/scripts/framework-validate.sh:1087:run_check "Session cap guard (live, G128)" env BUBBLES_REPO_ROOT="$REPO_ROOT" bash "$SCRIPT_DIR/session-cap-guard.sh" --quiet
bubbles/scripts/guards/tail-convergence-gates.sh:114:# Mechanical wrapper around bubbles/scripts/session-cap-guard.sh — the
bubbles/scripts/guards/tail-convergence-gates.sh:126:sess_guard="$SCRIPT_DIR/session-cap-guard.sh"
bubbles/scripts/guards/tail-convergence-gates.sh:139:  info "session-cap-guard.sh not present at $sess_guard; skipping (advisory)"
BUG037_INSPECTION_END
```

**Interpretation:** The source directly shows unfiltered G128 populations,
partial producer identity, prefix usage filtering, and callers without a
session argument. Source inspection does not replace a failing regression run.

## Bug Reproduction - Before Fix

**Phase:** bug
**Command:** not run
**Exit Code:** not applicable
**Claim Source:** not-run

The bounded filing phase did not execute a mixed-session guard fixture. The
source path is confirmed, while the executable red-stage obligation remains
unchecked in [scopes.md](scopes.md).

## Test Evidence

**Phase:** bug
**Command:** not run
**Exit Code:** not applicable
**Claim Source:** not-run

No test command ran. This phase owner was restricted to bug discovery and full
packet creation.

## Validation Evidence

**Phase:** bug
**Command:** not run
**Exit Code:** not applicable
**Claim Source:** not-run

Independent validation did not run.

## Audit Evidence

**Phase:** bug
**Command:** not run
**Exit Code:** not applicable
**Claim Source:** not-run

Independent audit did not run.

## Related Artifacts

- Scope and DoD: [scopes.md](scopes.md)
- Human acceptance: [uservalidation.md](uservalidation.md)

## Planning Reconciliation - 2026-09-01 08:15 UTC

### Planning Summary

The planning phase reconciled the active scope with the current specification,
design, source baseline, and existing test surfaces. It changed planning-owned
artifacts only. Production source, tests, and certification fields were not
edited.

### Decision Record

The plan retains one atomic runtime scope. The guard signature, convergence
identity, adapter proof, and caller forwarding must land together. Splitting
them could leave an active-budget caller or dimension without exact identity.

The plan removes the earlier tool-call producer proposal. Current production
sources cannot measure every host tool invocation. `maxToolCalls` therefore
stays unmeasurable with reason `no-exact-producer`.

The plan adds focused coverage for Check 40, framework validation, same-spec
concurrency, private-path exclusion, macOS Bash 3, and append-only history. It
also adds the machine-readable [test-plan.json](test-plan.json) handoff.

### Planning Completion Statement

The planning artifacts now describe all eight `SCN-B054-*` contracts, 20
executable Test Plan rows, and 20 matching test-related DoD items. Every
delivery DoD item remains unchecked. Human acceptance remains unrecorded and
unchecked.

### Ownership Boundary

This planning phase changed [scopes.md](scopes.md),
[scenario-manifest.json](scenario-manifest.json),
[test-plan.json](test-plan.json), [uservalidation.md](uservalidation.md), and
execution bookkeeping in [state.json](state.json). It did not edit source,
tests, or `certification.*`.

### Planning Validation Evidence

**Phase:** plan
**Command:** `/opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-037 final planning guards" -- /bin/zsh -f ../bug037-final-planning-guards.zsh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-037 final planning guards
$ /bin/zsh -f ../bug037-final-planning-guards.zsh
exit: 0
lines: 173
sha256: 49ce8c96982bfb09ecd8df9862266ea14f69ca33036e92f51d035950071a6bf2
--- first 20 ---
BEGIN=ARTIFACT_LINT
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ No forbidden sidecar artifacts present
✅ Found DoD section in scopes.md
✅ scopes.md DoD contains checkbox items
✅ All DoD bullet items use checkbox syntax in scopes.md
✅ Found Checklist section in uservalidation.md
✅ uservalidation checklist contains checkbox entries
✅ All checklist bullet items use checkbox syntax
✅ uservalidation separates automation readiness from human acceptance
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ state.json v3 has required field: status
✅ state.json v3 has required field: execution
✅ state.json v3 has required field: certification
--- omitted 133 line(s); sha256 above covers the full output ---
--- last 20 ---
ℹ️  DoD fidelity scenarios: 8 (mapped: 8, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=16 inferred=0 ambiguous=0

RESULT: PASSED (0 warnings)
EXIT_TRACEABILITY=0
BEGIN=VERTICAL_PLAN
[vertical-delivery-plan-guard] OK — first usable increment is early (scope 1 of 1); no horizontal chain; within scope budget.
EXIT_VERTICAL_PLAN=0
BEGIN=SCOPE_CONTEXT
[scope-context-fit-lint] OK — all 1 scope(s) are self-contained (no chat/session-replay dependency); a fresh specialist can execute from the durable artifacts.
EXIT_SCOPE_CONTEXT=0
BEGIN=PLAN_DEPTH
[plan-dependency-depth-guard] no dependsOn edges in bugs/BUG-037-session-cap-cross-session-attribution — no-op (position guard covers ordering)
EXIT_PLAN_DEPTH=0
BEGIN=REFERENCE_EXISTENCE
[reference-existence-lint] OK — 6 markdown file(s) scanned, every relative link target resolves
EXIT_REFERENCE_EXISTENCE=0
TEST_PLAN_PARITY markdown=20 dod=20 json=20 uniqueIds=20
TEST_PLAN_FIELD_SYNC_EXIT=0
FINAL_PLANNING_GUARDS_OVERALL=0
```

## Implementation Evidence 2026-09-01

### Implementation Outcome

The candidate now evaluates all G128 measurements against one explicit host
session. It excludes mismatched and unattributed records without rewriting
history.

Convergence rows now use the exact session, spec, and agent key. Tool-result
bytes and prompt tokens require exact identity. `maxToolCalls` remains
unmeasurable because no exact production producer exists.

Check 40 and live framework validation now preserve `BREACH` exit 1 and
`INPUT-ERROR` exit 2. The implementation also preserves the existing cap
values, null behavior, strict comparison, and 70 percent soft boundary.

### Finding Accounting

| Finding | Disposition | Evidence |
| --- | --- | --- |
| `BUG054-IMP-001` repository-wide G128 attribution | Fixed in the candidate | Receipts 20 and 25 |
| `BUG054-IMP-002` malformed cap and record types could collapse into default-off or empty collections | Fixed after a current-session RED | Receipts 10 and 25 |
| `BUG054-IMP-003` stock Bash 3 treated the empty goal-node argument array as unbound | Fixed after a current-session RED | Receipts 22 through 25 |
| `BUG054-IMP-004` generated release metadata was stale | Regenerated only with the canonical generator | Receipt 27 |
| `BUG054-IMP-005` exact-session regressions lacked several planned adversarial assertions | Strengthened without weakening planned behavior | Receipts 25 and 32 |

No implementation-owned finding remains open.

### Scenario-First RED Evidence

**Phase:** implement
**Claim Source:** executed

| Receipt | Exit | Direct signal | Captured stdout SHA-256 |
| --- | ---: | --- | --- |
| `.specify/runtime/tool-calls.jsonl` row 20 | 1 | The isolated `origin/main` guard charged mismatched and unattributed history. The active fixture was within every populated measurable cap. | `9d8b0adf807a658bf8b0d74178954f75b30bfe9f66c5e0d2dd2afd1d90308b31` |
| `.specify/runtime/tool-calls.jsonl` row 10 | 1 | Boolean caps and non-array record collections produced four focused failures before the parser repair. | `d3fe7b56f945818013f786ead35c67badfd6a5f733f7beef95d6bb3455e36c4b` |
| `.specify/runtime/tool-calls.jsonl` row 22 | 1 | Stock Bash 3 exited before the first snapshot assertion. Xtrace located the empty-array nounset failure at `MIRROR_GOAL_NODE_ARGS`. | `5bb2a77bbe0adb8198ecec673c948e8bd97cf078c1fd1956f4d1f0357ca07b98` |

The baseline reconstruction used a throwaway fixture and materialized the
guard from `origin/main`. It verified the source blob before execution. It left
the candidate and retained fixture history unchanged.

The bounded Bash 3 xtrace diagnostic exited 1 with full-output SHA-256
`fbaad9a672a5e5387fcc0fae52da46eb7bc430ec943c89547bf16511efe93ddd`.
It printed `MIRROR_GOAL_NODE_ARGS[@]: unbound variable` at the failing
production line.

### Final Current-Byte GREEN Receipts

**Phase:** implement
**Claim Source:** executed

| Receipt | Exit | Covered implementation proof | Captured stdout SHA-256 |
| --- | ---: | --- | --- |
| Row 19 | 0 | Check 40 exact-session forwarding, retained history, and exit classification | `1e94d80223100ef00a50b237990a35154c59dca9990966dff49e08ed38b3c8f1` |
| Row 23 | 0 | State snapshot exact-key persistence under stock Bash 3 | `a9518bc951232d0f0e4d2db01fceb5cad6bfda7511427138dd61d0ac97e99df1` |
| Row 24 | 0 | Flock and mkdir-lock concurrency with independent G128 verdicts | `087e2857bd297a4cdf0bc26631109c86cd2e0b50e5cebfeaacd3f2ae1bee83e4` |
| Row 25 | 0 | Stock Bash 3 matrix for TP-01 through TP-13, TP-16, and TP-17 | `a9057a06fcc28562d04c70ef89e51fbc7da252c40101a050da4fdda95ec1d24b` |
| Row 26 | 0 | Live framework-validation caller forwarding and child status fidelity | `967fe93e07f3484fdd426b04aa9ba0487819c6a30416e0a419f55b61be20efb9` |
| Row 27 | 0 | Canonical release-manifest freshness on the stabilized source bytes | `6aa61f518e9da0740bc112ed04081e8da2b6327d45429e09e48593b263b20818` |
| Row 28 | 0 | Bash 3 and Bash 5 syntax for every changed shell file | `ce79fcf023e458059220fe197d5190bac2ede7c806320fb96d7ee1a322661b0b` |
| Row 31 | 0 | Canonical source ShellCheck wrapper with explicit empty-output sentinels | `615e5ec31a12421717f305a4496a4adfefc6294d9a5fc86f5d5343b0bedfb1a5` |
| Row 32 | 0 | Eight bug-regression files, zero violations, and zero warnings | `7edb0a8813bc20e22c9908a37e46bbce38c2e2d1cc9657015cb2c9c2985b725c` |
| Row 33 | 0 | Implementation reality scan over 25 resolved files with zero violations | `d4c2f4ca6771c6e2fb479143438ef7cac31133aaefb610da64de6e9da3760b38` |

The stock Bash matrix identified version `3.2.57(1)-release`. It ended with
`BASH3_MATRIX_FAILURES=0`. The persistent regression reported 32 passed and
zero failed assertions.

### Validation Interpretation

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The reality scan emitted one advisory fallback warning. It
resolved 25 files from the design, scanned them, and reported zero violations.
The active scope already lists the production and test paths in its change
boundary and Test Plan.

The raw ShellCheck invocation used ShellCheck's default info and style levels.
It reported existing noncanonical diagnostics. The repository-owned ShellCheck
wrapper then exited 0 on the same final source tree in receipt 31.

The first zero-output wrapper run exposed an arithmetic error in
`evidence-capture.sh`. The underlying canonical ShellCheck command exited 0.
Receipt 31 replaced that malformed capture with explicit output sentinels.
This independent observation is `OBS-B054-001` in the result envelope.

### Generated Artifact Repair

**Phase:** implement
**Claim Source:** executed

The first canonical freshness check exited 1 and printed
`Release manifest is stale`. The canonical generator then updated version
7.28.0 with 927 managed files. Receipt 27 records the subsequent check at exit
0 with `Release manifest is current`.

### Implementation Phase Boundary

This phase did not alter [scopes.md](scopes.md). All 38 DoD items remain
unchecked. It did not alter `certification.*` or mark the scope or bug done.

Full framework validation and release readiness did not run in this phase.
Independent test certification is not claimed. The required owner is
`bubbles.test`.

## Scope 1 Recovery Implementation - 2026-09-01

### Recovery Scope

This recovery preserved the silent attempt's current bytes. It changed only
Scope 1 source, tests, and the four authorized orchestrator contracts.

The implementation does not claim Scope 2 or later work. It does not claim
independent test execution, validation, certification, commit, or push.

### Recovery Finding Accounting

| Finding | Disposition | Current-session evidence |
| --- | --- | --- |
| `RF-B054-01` | Addressed. Packet validation now precedes target path derivation. Descriptor locks use no-follow opens and preserve planted bytes. | Rows 98 and 103 |
| `RF-B054-03` | Addressed. Exact-session policies use append-only compare-and-append revisions. Legacy and unrelated state remain preserved. | Rows 98 and 99 |
| `BUG054-S1-PARTIAL-001` | Addressed. A first policy write no longer requires a pre-existing memory directory. | RED row 86 and GREEN row 98 |
| `BUG054-S1-PARTIAL-002` | Addressed for future writes. Persistent flock state moved under the ignored runtime tree. | RED row 82 and GREEN rows 98 and 103 |
| `BUG054-S1-PARTIAL-003` | Addressed. Duplicate policy options now fail before packet or state access. | RED row 82 and GREEN row 98 |
| `BUG054-S1-PARTIAL-004` | Addressed. Every orchestrator contract now preserves all seven values and explicit nulls. | RED row 83 and GREEN row 99 |
| `BUG054-S1-HARDEN-001` | Addressed. Holder reads now verify one stable regular entry. Private and holder writes require complete descriptor writes. | Row 98 |

No Scope 1 implementation finding remains unresolved. The test owner must
independently verify the implementation before certification.

### Scope 1 Recovery RED Evidence

**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 780 /bin/bash bubbles/scripts/state-snapshot-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
# BUG-037 Scope 1 recovery RED ignored lock first policy duplicate options
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 780 /bin/bash bubbles/scripts/state-snapshot-selftest.sh
exit: 1
lines: 125
sha256: f665c2d52ba2386c4a9c2d3c0b6a3a1d4e4e963f0fdae8d78cee0f70fe18fd94
--- failure-shaped lines from the omitted region ---
FAIL: state snapshot must not leave a persistent flock artifact beside session memory
--- last 20 ---
FAIL: SCN-B037-010 production flock refusal changed planted target or session bytes
FAIL: SCN-B037-010 production mkdir refusal changed planted lock or session bytes
FAIL: SCN-B037-011 first exact-session policy write should create state without a legacy seed
state-snapshot: session policy compare-and-append refused
FAIL: SCN-B037-011 duplicate policy options must fail with byte-identical state
state-snapshot selftest failed with 5 issue(s) across 117 assertions in 21 cases.
```

Pre-existing current-session rows 76, 77, and 79 also contain admissible RED
records. Each has a nonzero exit, stable test identity, negative control,
implementation references, and scenario metadata. Recovery rows 82, 83, and
86 narrowed the remaining partial-edit defects before each production repair.

### Scope 1 Final State And Lock Evidence

**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 780 /bin/bash bubbles/scripts/state-snapshot-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-037 Scope 1 final state snapshot focused evidence
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 780 /bin/bash bubbles/scripts/state-snapshot-selftest.sh
exit: 0
lines: 123
sha256: 30a32f1b697a7baa051a05328fbaeff2dc42a93ab0acf02f3d416569919802a5
--- first 20 ---
Running state-snapshot selftest...
Scenario: orchestrator agents must record a per-turn snapshot in .specify/memory/bubbles.session.json without ever losing prior records.
PASS: Snapshot creates session JSON file when missing
PASS: First snapshot creates exactly one turnSnapshots entry
PASS: First snapshot turnNumber is 1
PASS: All required fields (phase, mode, agent, note, timestamp) present in first snapshot
PASS: First snapshot record carries the supplied phase/mode/agent and null scopeId
PASS: Append to existing session yields exactly 2 turnSnapshots entries
PASS: Appended record turnNumber correctly increments to 2
PASS: Pre-existing turnSnapshots[0] record is preserved verbatim
PASS: Non-snapshot session fields (sessionId) preserved across append
PASS: start+end snapshot pair produces exactly 2 records
PASS: start+end pair records modes in the correct order
PASS: start+end pair preserves matching scopeId across both records
PASS: start+end pair turnNumbers increment correctly (1 → 2)
PASS: in-place caller packet attack does not invalidate the captured snapshot
PASS: in-place packet capture is distinct, byte-identical, and mode 0600
PASS: in-place caller packet attack executes after private capture
PASS: in-place caller packet attack uses the intended inode semantics
PASS: in-place caller packet attack writes only to the captured repository root
--- omitted 83 line(s); sha256 above covers the full output ---
--- last 20 ---
PASS: SCN-B037-010 production flock refusal preserves planted target and session bytes
PASS: SCN-B037-010 production mkdir refusal preserves planted lock and session bytes
SCENARIO: SCN-B037-011 exact-session policy histories remain independent
PASS: SCN-B037-011 first exact-session policy write creates revision one from absent session state
PASS: SCN-B037-011 first writes and an identical retry preserve one policy record per exact session
PASS: TP-01-02 valid exact-session policy writes execute through forced flock and mkdir transactions
PASS: SCN-B037-011 policy writes preserve legacy policy, turns, exact convergence mappings, and unrelated state
PASS: SCN-B037-011 compare-and-append correction adds one linear revision without changing the sibling chain
PASS: SCN-B037-011 stale policy authority is rejected with byte-identical state
PASS: SCN-B037-011 duplicate policy options are rejected before state mutation
PASS: SCN-B037-011 stale expected revision is rejected with byte-identical state
PASS: SCN-B037-011 duplicate policy revision is rejected without state mutation
PASS: SCN-B037-011 branching policy chain is rejected without state mutation
PASS: SCN-B037-011 malformed policy record is rejected without state mutation
PASS: SCN-B037-011 malformed requested policy write is rejected without state mutation
state-snapshot selftest passed with 117 assertions across 21 cases.
```

Structured receipt row 98 records this command with exit zero and complete
input closure. The Homebrew Bash runtime repetition is row 104.

### Scope 1 Final Autonomy Evidence

**Phase:** implement
**Command:** `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 480 /bin/bash bubbles/scripts/autonomy-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-037 Scope 1 final autonomy focused evidence
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=10s 480 /bin/bash bubbles/scripts/autonomy-resolve-selftest.sh
exit: 0
lines: 62
sha256: 544388bde4c55da5406f60c764abc2ee69e4746974782362aef14f2b0e541404
--- last 20 ---
PASS: SCN-B037-011 host-b refusal names the unattended boundedness contract
PASS: SCN-B037-011 bounded sibling and legacy policy cannot activate absent host-c
PASS: SCN-B037-011 absent host-c reports the exact-session default-off result
PASS: SCN-B037-011 final declared cap remains eligible for exact-session boundedness
PASS: SCN-B037-011 host-d preserves a non-null maxCumulativePromptTokens value
PASS: SCN-B037-011 only the unique latest exact-session head controls boundedness
PASS: SCN-B037-011 an all-null correction disables only its exact session
PASS: SCN-B037-011 branching exact-session policy history fails closed
PASS: SCN-B037-011 branch rejection uses the stable policy failure code
PASS: SCN-B037-011 duplicate exact-session policy revision fails closed
PASS: SCN-B037-011 malformed policy chain emits its stable failure code
PASS: SCN-B037-011 resolver rejects a symlink session-state capture
PASS: SCN-B037-011 stale authority cannot select a session policy head
PASS: SCN-B037-011 bubbles.goal.agent.md seeds all seven exact-session values and explicit nulls
PASS: SCN-B037-011 bubbles.workflow.agent.md seeds all seven exact-session values and explicit nulls
PASS: SCN-B037-011 bubbles.iterate.agent.md seeds all seven exact-session values and explicit nulls
PASS: SCN-B037-011 bubbles.sprint.agent.md seeds all seven exact-session values and explicit nulls
PASS: SCN-B037-011 workflow policy retains all seven cap names and null defaults
autonomy-resolve selftest passed.
```

Structured receipt row 99 records this command with exit zero and complete
input closure. The Homebrew Bash runtime repetition is row 105.

### Scope 1 Boundary And Quality Evidence

**Phase:** implement
**Claim Source:** executed

| Receipt | Exit | Direct signal |
| --- | ---: | --- |
| Row 90 | 0 | Python compiled `session-state-io.py` with bytecode outside the repository. |
| Row 95 | 0 | ShellCheck accepted all four changed shell files. |
| Row 96 | 0 | The bugfix regression-quality guard reported zero violations and zero warnings. |
| Row 97 | 0 | Git reported no tracked whitespace errors in the Scope 1 patch. |
| Row 100 | 0 | Stock macOS Bash parsed all four changed shell files. |
| Row 101 | 0 | Homebrew Bash parsed all four changed shell files. |
| Row 102 | 0 | The implementation reality scan found zero violations. |
| Row 103 | 0 | Every changed source and test path resolved inside the immutable boundary. |

The reality scan reported one existing discovery warning. It found paths through
the design fallback because the scope lacks a canonical implementation-files
section. The scan still resolved 34 files and found zero violations.

### Preserved Lock Artifact Observation

**Phase:** implement
**Claim Source:** executed

Row 103 proves that future persistent locks resolve under the ignored
`.specify/runtime` tree. The pre-existing
`.specify/memory/bubbles.session.json.flock` remains untracked and untouched.

The preserved file remains inode `268637576`, size zero, and SHA-256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
The recovery neither deleted nor committed it.

### Scope 1 Implementation Boundary

Scope 1 implementation-owned evidence is green. The bug remains
`in_progress`. Certification fields remain unchanged. The required owner is
`bubbles.test` for independent Scope 1 verification.

### Code Diff Evidence

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The current diff and final focused runs show the owned
Scope 1 implementation delta. The complete patch remains uncommitted.

- Added descriptor-safe state capture and flock or mkdir lock execution.
- Moved future persistent lock state into the ignored runtime tree.
- Added exact-session append-only budget history and compare-and-append writes.
- Preserved turns and exact session, spec, and agent convergence behavior.
- Restricted autonomy boundedness to the validated exact-session policy head.
- Reconciled all four orchestrator contracts with seven-cap and null fidelity.
- Added adversarial authority, lock, policy, and agent-contract regressions.

### Nonterminal Transition Guard Diagnostic

**Phase:** implement
**Command:** `state-transition-guard.sh bugs/BUG-037-session-cap-cross-session-attribution`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** The guard evaluated a whole-bug delivery transition. Scope
1 remains nonterminal and later scopes are intentionally unimplemented.

The diagnostic accepted the implement claim's specialist provenance and
execution backing. It blocked whole-bug completion because later phases,
regression planning, human acceptance, and certification are incomplete.

It also identified planning and freshness checks that belong to later phase
owners. This recovery did not modify foreign planning or certification fields.

## Scope 1 Independent Test Verification - 2026-09-01

### Verification Boundary

**Phase:** test
**Claim Source:** executed

This run verified only Scope 1 on the inherited dirty worktree. It executed no
Scope 2 through Scope 5 test command. It changed no production or test source.

The exact repository packet passed `repository-binding.sh validate-packet`
before any repository-local read. The test run then resolved all 59 declared
test paths without executing the linked later-scope tests.

The 35 implementation-owner receipts were read as context and excluded from
the independent verdict. Rows 111 through 121 were also excluded because the
persistent shell retained implementation-era scenario metadata. Row 120 also
used an overbroad `xit(` scan that matched Python `SystemExit(` text.

Rows 122 through 130 corrected the metadata before evidence links were written.
Rows 134 through 138 supersede those test runs against the stable scenario
contract. Diagnostic runs explicitly carry no scenario binding.

### Scope 1 Independent State And Lock Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/state-snapshot-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

| Test row | Scenario binding | Receipt | Input closure | Direct result |
| --- | --- | --- | ---: | --- |
| TP-01-01 | `SCN-B054-010` | Tool log row 134, stdout SHA-256 `ef9578e164664c71358672885e971a73ae727a6a5ae7564a1d4dc8b0857f5644` | 14 files | 117 assertions passed across 21 cases |
| TP-01-02 | `SCN-B054-009` | Tool log row 135, stdout SHA-256 `30cfe6a41ac536bd772c41c24ef7f7c86c1aae519f108fa776ca2a2005cbbdc5` | 14 files | 117 assertions passed across 21 cases |
| Compatibility | `SCN-B054-010` | Tool log row 137, stdout SHA-256 `aa2374acd8df60c23e0af5ffea8bcd75ec22dfd1685167e66c5817a1231e88f3` | 14 files | Homebrew Bash repeated all 117 assertions |

Each state run captured the complete 123-line output with SHA-256
`30a32f1b697a7baa051a05328fbaeff2dc42a93ab0acf02f3d416569919802a5`.

The adverse packet cases used stale, malformed, non-actionable, and wrong-root
authority. Every case created zero repository-local entries and preserved its
sentinel bytes.

The lock cases exercised symlink, FIFO, hard-link, replacement, stale-holder,
and malformed-holder inputs. They also exercised both production lock modes.
The tests preserved planted targets and session bytes on every refusal.

The policy cases exercised first writes, identical retries, corrections, stale
revisions, duplicate options, duplicate revisions, branches, and malformed
records. They preserved legacy policy, turns, convergence rows, sibling chains,
and unrelated state.

### Scope 1 Independent Autonomy Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/autonomy-resolve-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

| Test row | Scenario binding | Receipt | Input closure | Direct result |
| --- | --- | --- | ---: | --- |
| TP-01-03 | `SCN-B054-011` | Tool log row 136, stdout SHA-256 `561ac7497516e4fc7aa81a4c1db26d6ef06181fbc8c7b888936015b9007dd045` | 16 files | Exact-session autonomy selftest passed |
| Compatibility | `SCN-B054-011` | Tool log row 138, stdout SHA-256 `7f1c0b162a138c9a147c7074c771a65c52da409f88ea739a5b77f23b62050827` | 16 files | Homebrew Bash repeated the same verdict |

Each autonomy run captured 62 lines with SHA-256
`544388bde4c55da5406f60c764abc2ee69e4746974782362aef14f2b0e541404`.

The test selected bounded, all-null, absent, corrected, branched, duplicate,
symlinked, and stale-authority session histories through the production
resolver. A bounded sibling and legacy policy never activated another session.

All four orchestrator contracts contained each cap name exactly once. Each
contract required unchanged numeric values, explicit nulls, validated authority,
and the compare-and-append writer. The workflow schema retained seven cap names
and seven null defaults.

### Scope 1 Independent Quality And Boundary Evidence

**Phase:** test
**Claim Source:** executed

| Receipt | Exit | Direct signal |
| --- | ---: | --- |
| Row 127 | 0 | Python syntax, stock Bash syntax, Homebrew Bash syntax, and ShellCheck passed on the five Scope 1 implementation and test files. |
| Row 128 | 0 | The bugfix regression-quality guard found zero violations and zero warnings in both Scope 1 tests. |
| Row 129 | 0 | Skip and mock scans found no prohibited pattern. Scenario and seven-cap contract checks reported zero failures. |
| Row 130 | 0 | Every Scope 1 path resolved in-boundary. Current source identities and the legacy lock residue were recorded. |

The state tests use real packet validation, filesystem objects, locks, and
production writer calls. The autonomy tests use the production resolver over
ephemeral session state. Their assertions observe produced state and resolver
outcomes rather than pass-through fixture values.

### Scope 1 Legacy Lock Residue Disposition

**Phase:** test
**Claim Source:** executed

The inherited `.specify/memory/bubbles.session.json.flock` remains a regular,
untracked, zero-byte file. Its inode is `268637576`. Its SHA-256 remains
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.

No process held the file during row 130. Scope 1 now uses the ignored runtime
lock path. This invocation preserved the residue and did not treat it as source
or evidence.

The residue does not block Scope 2 implementation. Before eventual clean
integration, the workflow runner must confirm the file is still unopened and
remove only this untracked legacy path. It must not reset, stash, or discard the
inherited worktree.

### Scope 1 Independent Test Verdict

**Phase:** test
**Claim Source:** executed

TP-01-01, TP-01-02, and TP-01-03 passed on current Scope 1 source bytes under
stock macOS Bash. Both test programs also passed under Homebrew Bash.

Scope 1 is independently verified at the test phase. The bug remains
`in_progress`. Certification remains unchanged. The workflow runner may route
Scope 2 implementation to `bubbles.implement` without starting any later scope
from this test invocation.

## Scope 2 Implementation - 2026-09-01

### Scope 2 Boundary

**Phase:** implement
**Claim Source:** executed

This run changed only the Scope 2 helper, guard, selftest, and execution
evidence fields. It did not start Scope 3 or change certification fields.

The inherited dirty worktree remained intact. The legacy untracked lock residue
also remained untouched.

### Scope 2 Finding Accounting

| Finding | Disposition | Evidence |
| --- | --- | --- |
| `RF-B054-04` | Addressed. G128 captures one descriptor-safe state revision. It selects one linear exact-session policy head and validates every matching event. | Rows 153 through 155 |
| `RF-B054-06` | Addressed. The shared helper emits JSON strings. All untrusted guard values use that encoder before output. | Rows 149 and 155 |
| `BUG054-S2-001` | Addressed. Malformed known caps now retain a safe dimension diagnostic before identity evaluation. | Final selftest row 155 |
| `BUG054-S2-EVIDENCE-001` | Addressed. Two helper checks invoked the non-executable helper path incorrectly. Rows 149 and 150 replaced those invalid checks through explicit Python. | Rows 147 through 150 |

No Scope 2 implementation finding remains open. Independent Scope 2 test
verification remains owned by `bubbles.test`.

### Scope 2 Scenario-First RED Evidence

**Phase:** implement
**Claim Source:** executed

The strengthened selftest failed against the pre-Scope-2 production guard.
Each run used stable scenario metadata and a real negative control.

| Test row | Scenario | Exit | Captured output SHA-256 | Intended failure |
| --- | --- | ---: | --- | --- |
| 143 | `SCN-B054-001` and `TP-02-01` | 1 | `7e0ce3825820bc73a15f28d14d3ca6d8bf62ad3c020fe6d3dc2d68d81c79ecb8` | Live-path rereads and missing immutable revision assertions failed. |
| 144 | `SCN-B054-002` and `TP-02-02` | 1 | `9b5109c4f9619208e9ba15b6827f75d766ec83598ad21644e9b1b855d4206674` | Closed boundary status assertions failed. |
| 145 | `SCN-B054-006` and `TP-02-03` | 1 | `b7d09811e89c84d5357154716ffa5ffec69727993681770f038f5c0668a4aa70` | Policy-chain, escaping, and safe-state assertions failed. |

Row 146 records the first incomplete GREEN attempt at exit 1. Rows 147 and 148
record invalid helper quality commands. They do not support completion claims.

### Scope 2 TP-02-01 Immutable Event Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 153 maps to canonical `SCN-B054-001`. Its receipt retains the
pre-adjudication scenario tag. Its eight-file input closure covers the
production guard and helper and carries the immutable-state negative control.

```text
# BUG-037 Scope 2 TP-02-01 current-byte GREEN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 900 /bin/bash bubbles/scripts/session-cap-guard-selftest.sh
exit: 0
lines: 278
sha256: 2a8fdbd2ff8fa268b13165d8e2178c67400f5068fb795cbdc2cc8165a105b7b3
[selftest] PASS: S2h quiet output retains all seven dimensions
[selftest] PASS: S2h quiet final status: one final PASS/exit-0 record is last on stdout
[selftest] Scenario S2i / SCN-B037-001 / TP-02-01: unsafe state path forms fail instead of being followed
[selftest] PASS: S2i a symlink state entry is rejected: exit 2
[selftest] PASS: S2i names unsafe immutable capture: stderr contains 'reason=unsafe-session-state'
[selftest] PASS: S2i unsafe path final status: one final INPUT-ERROR/exit-2 record is last on stderr
Passed assertions: 226
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

### Scope 2 TP-02-02 Exact Boundary Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 154 maps to canonical `SCN-B054-002`. Its receipt retains the
pre-adjudication scenario tag. Its production G128 negative control moves one
observation from equality to one unit above.

```text
# BUG-037 Scope 2 TP-02-02 current-byte GREEN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 900 /bin/bash bubbles/scripts/session-cap-guard-selftest.sh
exit: 0
lines: 278
sha256: 7034ccc97060e7e0a284987ee3fe738d88068330bb6a16a681275ab2976c7659
[selftest] PASS: Sc reports exact-session convergence 8/10
[selftest] PASS: Sc preserves the 70 percent soft-boundary status
[selftest] PASS: Sd exit code (aggregate 13 > cap 10): exit 1
[selftest] PASS: Sd stderr names observation and cap
[selftest] PASS: S2h quiet output retains all seven dimensions
[selftest] PASS: S2h quiet final status: one final PASS/exit-0 record is last on stdout
Passed assertions: 226
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

### Scope 2 TP-02-03 Policy And Diagnostic Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 155 maps to canonical `SCN-B054-006`. Its receipt retains the
pre-adjudication scenario tag and exact policy and escaping controls.
This was the required final implementation-owner command on current source
bytes.

```text
# BUG-037 Scope 2 TP-02-03 final implementation-owner GREEN
$ /opt/local/bin/gtimeout --signal=TERM --kill-after=20s 900 /bin/bash bubbles/scripts/session-cap-guard-selftest.sh
exit: 0
lines: 278
sha256: 154063767f8f15f7fafb94241da8f2d22531f0407441f2a492b8d44801d9e7bc
[selftest] PASS: S2h quiet output retains policy selection
[selftest] PASS: S2h quiet output retains counts
[selftest] PASS: S2h quiet output retains all seven dimensions
[selftest] PASS: S2h quiet output retains the summary
[selftest] PASS: S2h quiet output retains the action
[selftest] PASS: S2h quiet final status: one final PASS/exit-0 record is last on stdout
Passed assertions: 226
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

### Scope 2 Helper And Shell Quality Evidence

**Phase:** implement
**Claim Source:** executed

| Receipt | Exit | Direct signal |
| --- | ---: | --- |
| Row 149 | 0 | The helper preserved exact captured bytes and SHA-256 identity. It JSON-escaped newline, tab, carriage return, escape, quote, backslash, and delimiter input. |
| Row 150 | 0 | Python bytecode compilation and AST parsing passed. Bytecode stayed outside the repository. |
| Row 151 | 0 | Stock macOS Bash 3 and Homebrew Bash 5 parsed both shell files. ShellCheck warning-level analysis passed. |
| Row 152 | 0 | The bugfix regression-quality guard found zero violations and zero warnings. |

The Python checks used the standard library and real descriptor-helper
subprocesses. No Pylance execution surface was available in this session.

### Scope 2 Boundary And Preservation Evidence

**Phase:** implement
**Command:** bounded Scope 2 work-boundary and preservation matrix
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 156 records six allowed paths and the unchanged workflow-policy
hash. It also records the untouched legacy lock and the inherited worktree.

```text
# BUG-037 Scope 2 boundary and preservation
exit: 0
lines: 71
sha256: 4bd3c482bd907c9c3e884de206e349297b36dcb53912a451cdd70141a1b44c47
BOUNDARY path=bubbles/scripts/session-state-io.py exit=0
disposition=in-boundary
BOUNDARY path=bubbles/scripts/session-cap-guard.sh exit=0
disposition=in-boundary
BOUNDARY path=bubbles/scripts/session-cap-guard-selftest.sh exit=0
disposition=in-boundary
WORKTREE_STATUS_COUNT=35
BUG037_SCOPE2_BOUNDARY_FAILURES=0
BUG037_SCOPE2_BOUNDARY_END
```

The workflow-policy SHA-256 remained
`ac316176d96c680191931e478bf7538c42015a94d26789faa151df7baa18473d`.
The source `specs/` directory remained absent. The IMP-055 concept scan found
no match in the three Scope 2 source and test files.

### Scope 2 Implementation Verdict

**Phase:** implement
**Claim Source:** executed

Scope 2 implementation-owner tests pass on current source bytes. The bug stays
`in_progress`. Scope 3 remains unstarted. Certification remains unchanged.

The next owner is `bubbles.test` for independent Scope 2 verification.

## Scope 2 Independent Test Verification - 2026-09-01

### Scope 2 Independent Verification Boundary

**Phase:** test
**Claim Source:** executed

This run verified only Scope 2 on the inherited dirty worktree. It executed no
Scope 3 through Scope 5 Test Plan row. It changed no production or test source.

The supplied repository packet passed `repository-binding.sh validate-packet`
before repository inspection. Row 158 then resolved all 59 linked test
references without executing them. The resolver reported three Scope 2
scenarios and three Scope 2 Test Plan rows.

Implementation rows 142 through 157 were read as context only. They do not
support this independent verdict.

### Scope 2 Independent TP-02-01 Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 175 maps only to canonical `SCN-B054-001`. Its receipt retains the
pre-adjudication scenario tag. Its eight-file input closure
matches the current helper, guard, selftest, specification, design, scope,
test-plan, and scenario-manifest bytes. The receipt source revision is
`830883fd5639ac066cb3d40a2a40a567cc3df22f`.

```text
# BUG-037 Scope 2 independent TP-02-01 current-byte stock-Bash GREEN
exit: 0
lines: 278
sha256: 6e9d14fb5d5599271a26e8581489f580406fc466b64522a939d7ad374a9172e3
[selftest] PASS: S2h quiet output retains all seven dimensions
[selftest] PASS: S2h quiet final status: one final PASS/exit-0 record is last on stdout
[selftest] Scenario S2i / SCN-B037-001 / TP-02-01: unsafe state path forms fail instead of being followed
[selftest] PASS: S2i a symlink state entry is rejected: exit 2
[selftest] PASS: S2i names unsafe immutable capture: stderr contains 'reason=unsafe-session-state'
[selftest] PASS: S2i unsafe path final status: one final INPUT-ERROR/exit-2 record is last on stderr
Passed assertions: 226
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

### Scope 2 Independent TP-02-02 Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 176 maps only to canonical `SCN-B054-002`. Its receipt retains the
pre-adjudication scenario tag. Its eight-file input closure
matches current bytes. The negative control changes equality to one unit over
and makes unmeasurable input eligible for the boundary.

```text
# BUG-037 Scope 2 independent TP-02-02 current-byte stock-Bash GREEN
exit: 0
lines: 278
sha256: 893d37a23ce129e0730da13c050f539e58d7aeec44139d8d37dc767bfaf9cadf
[selftest] PASS: Sc exit code (aggregate 8 <= cap 10): exit 0
[selftest] PASS: Sc reports exact-session convergence 8/10: stdout contains 'G128 dimension name=maxTotalConvergenceIterations cap=10 state=MEASURED observed=8'
[selftest] PASS: Sc preserves the 70 percent soft-boundary status: stdout contains 'G128 status=SOFT-BOUNDARY exit=0 session="host-current"'
[selftest] PASS: Sd exit code (aggregate 13 > cap 10): exit 1
[selftest] PASS: Sd stderr names the exact-session breach: stderr contains 'G128 status=BREACH exit=1 session="host-current"'
[selftest] PASS: Sd stderr names observation and cap: stderr contains 'G128 breach name=maxTotalConvergenceIterations observed=13 cap=10'
Passed assertions: 226
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

### Scope 2 Independent TP-02-03 Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 177 maps only to canonical `SCN-B054-006`. Its receipt retains the
pre-adjudication scenario tag. Its eight-file input closure
matches current bytes. The negative control selects shared policy, permits an
unknown key, infers tool calls, or emits raw control bytes.

```text
# BUG-037 Scope 2 independent TP-02-03 current-byte stock-Bash GREEN
exit: 0
lines: 278
sha256: 0b93aebe64ea348b17745f74c0b5f1e89ccb9f25589abb6694ea6f66c30aacc7
[selftest] PASS: S2h quiet output retains policy selection: stdout contains 'G128 budget session="host-current" revision=1 policyCount=1 capCount=7'
[selftest] PASS: S2h quiet output retains counts: stdout contains 'G128 records source=convergence matching=1 mismatched=1 unattributed=1 excluded=2 eligible=1'
[selftest] PASS: S2h quiet output retains all seven dimensions
[selftest] PASS: S2h quiet output retains the summary: stdout contains 'G128 summary measured='
[selftest] PASS: S2h quiet output retains the action: stdout contains 'G128 action=continue'
[selftest] PASS: S2h quiet final status: one final PASS/exit-0 record is last on stdout
Passed assertions: 226
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

### Scope 2 Independent Receipt And Quality Evidence

**Phase:** test
**Claim Source:** executed

These probes ran before scenario evidence links were written. They verify the
unchanged source and test bytes, not the later evidence-artifact epoch.

| Receipt | Exit | Direct signal |
| --- | ---: | --- |
| Row 164 | 0 | Python AST and in-memory compile passed. Descriptor capture, SHA-256, mode 0600, symlink refusal, JSON round-trip, and one-line escaping passed. |
| Row 165 | 0 | The bugfix regression-quality guard found zero violations and zero warnings. |
| Row 167 | 0 | Five disposable mutations each produced assertion failures and exit 1. Repository source remained unchanged. |
| Row 169 | 0 | All six candidate paths resolved in-boundary. The corrected manifest covered 32 protected dirty paths. |

The mutation receipt reintroduced live-path rereads, subset timestamp
filtering, shared budget selection, permissive budget keys, and raw diagnostic
interpolation. Every mutation failed the real selftest.

The stock runtime was Bash `3.2.57(1)-release`. Bash syntax and ShellCheck
warning-level analysis passed. The refined skip scan and live-interception scan
returned no match.

### Scope 2 Independent Command Correction Accounting

**Phase:** test
**Claim Source:** executed

| Finding | Invalid receipt | Resolution |
| --- | ---: | --- |
| `TEST-B054-S2-CMD-001` | Row 163 exited 1 because inline Python quoting was malformed. Its broad `xit(` pattern also matched `last_exit()`. | Row 164 used in-memory Python syntax and a token-boundary skip scan. |
| `TEST-B054-S2-CMD-002` | Row 166 exited 1 before mutation execution because one inline f-string escaped quotes incorrectly. | Row 167 executed all five disposable mutations. |
| `TEST-B054-S2-PRES-001` | Row 168 exited 0 but parsed backslash-zero instead of NUL. Its one-path manifest is inadmissible. | Row 169 parsed `bytes([0])`, required 32 protected paths, and preserved every identity. |
| `TEST-B054-S2-CERT-001` | Row 170 used a newline-bearing `jq` rendering against a newline-free Python baseline hash. The values were not comparable. | Row 172 used the original canonical Python method and matched the pre-edit certification hash. |
| `TEST-B054-S2-PROSE-001` | Row 171 saw zero prose findings but its regex expected a literal backslash sequence. | Row 172 parsed rule prefixes and integer tails without regex escaping. |
| `TEST-B054-S2-CLOSURE-001` | Rows 159 through 161 passed before scenario evidence references were added. Their declared manifest input then became stale. | Rows 175 through 177 repeated all three TP rows against the final scenario-manifest bytes. |

The invalid receipts remain immutable. None supports a completion claim.

### Scope 2 Independent Boundary And Preservation Evidence

**Phase:** test
**Claim Source:** executed

Row 169 recorded the corrected pre-edit preservation baseline.

```text
PROTECTED_DIRTY_PATH_COUNT=32
PROTECTED_DIRTY_MANIFEST_SHA256=a7dcbcbab702eaf3831c7cc9b0035f3b6132d72b564e2cec2c407ec1df7ec9bc
INDEX_SHA256=0b57ac59ca42972aafc2c9fa8291ae008fe2f194e4310448653cb6a8c0b8f0ca
CERTIFICATION_SHA256=297a0fc7a817ed212878af757031a39b540dc803c230269b601bd893bd1a9e41
LEGACY_LOCK_REGULAR=True
LEGACY_LOCK_INODE=268637576
LEGACY_LOCK_BYTES=0
LEGACY_LOCK_SHA256=e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
CURRENT_SOURCE_TEST_PLAN_HASHES_MATCH_ENTRY=true
SOURCE_SPECS_DIRECTORY_ABSENT=true
SCOPE2_DIFF_CHECK_EXIT=0
BUG037_SCOPE2_PREEDIT_BOUNDARY_FAILURES=0
```

The legacy zero-byte lock remains local residue. This test run did not alter,
delete, stage, or classify it as source evidence.

### Scope 2 Independent Test Verdict

**Phase:** test
**Claim Source:** executed

TP-02-01, TP-02-02, and TP-02-03 passed on current source bytes under stock
macOS Bash. Each run passed 226 assertions with zero failures.

The three final receipts use separate scenario bindings and complete current input
closures. The disposable mutation matrix caught all five named regressions.

Scope 2 is independently verified at the test phase. The bug remains
`in_progress`. Certification remains unchanged. Scope 3 remains unstarted and
routes to `bubbles.implement` through the workflow runner.

## Scope 3 Implementation Evidence - 2026-09-02

### Scope 3 RED Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/usage-adapter-contract-selftest.sh` and `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 1 and 1
**Claim Source:** executed

The adapter RED run proved that the old reader returned neutral or partial data
for exact unsafe and malformed inputs. The G128 RED run proved that it reopened
the live tool-log path and accepted present null byte members.

```text
# BUG-037 Scope 3 RED TP-03-02 complete exact usage contract
$ /bin/bash bubbles/scripts/usage-adapter-contract-selftest.sh
exit: 1
lines: 54
sha256: d60143f4544bf1793918fe32adf133e9bdbfa1465945a3f563711a401213a7db
FAIL BUG-037 exact selection preserves newline filename bytes
FAIL BUG-037 exact symlink artifacts fail loud
FAIL BUG-037 symlink usage roots fail loud
FAIL BUG-037 non-regular exact artifacts fail loud
FAIL BUG-037 unreadable traversal fails loud
FAIL BUG-037 mixed valid and null prompt-token records fail loud
FAIL BUG-037 incomplete request-like records fail loud
usage-adapter-contract-selftest: 26 check(s), 7 failure(s)

# BUG-037 Scope 3 RED TP-03-03 immutable receipts and null bytes
$ /bin/bash bubbles/scripts/session-cap-guard-selftest.sh
exit: 1
lines: 372
sha256: b746662510b652e1b52e87f1d35e7c6b05e3cadf4b422fdc0bd000cda6ca6b6e
Failed assertions: 10
```

### Scope 3 TP-03-01 Receipt Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/tool-log-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
PASS: Case 1: success command preserves exit 0
PASS: Case 1: stdout streamed to caller
PASS: Case 1: log file created
PASS: Case 1: log has exactly one line
PASS: Case 1: JSON record has all required fields with correct values
PASS: Case 2: failure command preserves exit 42
PASS: Case 2: log appended (now 2 lines)
PASS: Case 2: same sessionId across calls; exit recorded
PASS: Case 3: distinct sessionId produces distinct log entries
SKIP: Case 4 schema validation (jsonschema not available)
PASS: Case 5: concurrent wrappers both preserve exit 0
CONCURRENT_SESSION_BYTES_OK
PASS: Case 5: concurrent delta has one distinct valid byte-bearing row per session
tool-log-selftest: PASS
```

The captured command exited 0 with 14 output lines and SHA-256
`c6d28c3697ae67abea4a011f9823602ee8d00fae7d6a77574eed6f98185bbca8`.
The optional schema-library case was skipped because `jsonschema` was absent;
the Scope 3 receipt and concurrency assertions executed and passed.

### Scope 3 TP-03-02 Exact Usage Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/usage-adapter-contract-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-037 Scope 3 FINAL TP-03-02 exact usage artifact
$ /bin/bash bubbles/scripts/usage-adapter-contract-selftest.sh
exit: 0
lines: 35
sha256: 552c9fb091d2198ab01b262044306b115e3454b027f210a92d55373e6b05d5c8
ok BUG-037 exact selection preserves newline filename bytes
ok BUG-037 exact symlink artifacts fail loud
ok BUG-037 symlink usage roots fail loud
ok BUG-037 non-regular exact artifacts fail loud
ok BUG-037 unreadable traversal fails loud
ok BUG-037 unreadable exact artifacts fail loud
ok BUG-037 symlinked traversal parents cannot escape containment
ok BUG-037 replacement during exact artifact traversal fails loud
ok BUG-037 malformed exact artifacts fail loud
ok BUG-037 mixed valid and null prompt-token records fail loud
ok BUG-037 incomplete request-like records fail loud
ok BUG-037 exact artifacts with no request-like object remain neutral
ok BUG-037 non-integer or negative prompt-token case 1 fails loud
ok BUG-037 non-integer or negative prompt-token case 2 fails loud
ok BUG-037 non-integer or negative prompt-token case 3 fails loud
ok BUG-037 non-integer or negative prompt-token case 4 fails loud
usage-adapter-contract-selftest: 34 check(s), 0 failure(s)
```

The replacement case ran the real adapter and real helper with an OS audit hook
that replaced the selected candidate immediately before its no-follow open. The
helper detected the identity mismatch and the adapter returned exit 2.

### Scope 3 TP-03-03 Receipt Consumption Evidence

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
# BUG-037 Scope 3 FINAL TP-03-03 receipt and usage evaluation
$ /bin/bash bubbles/scripts/session-cap-guard-selftest.sh
exit: 0
lines: 308
sha256: e76417334e68209ab8d834202295dd60b06376b1451579c19a5bdbb39b74ba27
[selftest] PASS: S3a first verdict remains on the captured under-cap tool-log prefix: exit 0
[selftest] PASS: S3a jq never received the live tool-log pathname after capture
[selftest] PASS: S3a a later invocation observes the replacement tool-log prefix: exit 1
[selftest] PASS: S3b absent byte partners contribute zero when the present member is valid: exit 0
[selftest] PASS: S3b present null stdoutBytes fails closed: exit 2
[selftest] PASS: S3b present null stderrBytes fails closed: exit 2
[selftest] PASS: S3b an interior empty physical receipt row fails closed: exit 2
[selftest] PASS: S3b a symlink tool log fails before receipt evaluation: exit 2
[selftest] PASS: S3b an unreadable tool log fails before receipt evaluation: exit 2
[selftest] PASS: S3c a usage result missing request count is invalid: exit 2
Passed assertions: 253
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

The compact evidence SHA-256 covers all 308 lines, including the retained Scope
1 and Scope 2 scenarios that ran in the same selftest.

### Scope 3 Boundary And Quality Evidence

**Phase:** implement
**Command:** bounded Scope 3 boundary, syntax, diff, and forbidden-concept matrix
**Exit Code:** 0
**Claim Source:** executed

```text
BUG037_SCOPE3_BOUNDARY_BEGIN
BOUNDARY path=bubbles/scripts/session-state-io.py allowed=true
BOUNDARY path=bubbles/adapters/usage/vscode-copilot.sh allowed=true
BOUNDARY path=bubbles/scripts/session-cap-guard.sh allowed=true
BOUNDARY path=bubbles/scripts/tool-log-selftest.sh allowed=true
BOUNDARY path=bubbles/scripts/usage-adapter-contract-selftest.sh allowed=true
BOUNDARY path=bubbles/scripts/session-cap-guard-selftest.sh allowed=true
TOOL_LOG_DIFF_EXIT=0
SCOPE3_BASH_SYNTAX_EXIT=0
SCOPE3_DIFF_CHECK_EXIT=0
FORBIDDEN_PRODUCTION_CONCEPT_SCAN=PASS
SOURCE_SPECS_DIRECTORY_ABSENT=true
GENERATED_PYTHON_BYTECODE_ABSENT=true
BUG037_SCOPE3_BOUNDARY_FAILURES=0
BUG037_SCOPE3_BOUNDARY_END
```

The bugfix regression-quality guard also exited 0 after scanning all three
Scope 3 test owners. It reported zero violations, zero warnings, and adversarial
signals in both the adapter and G128 selftests.

### Scope 3 Reality Scan Observation

**Phase:** implement
**Command:** `/bin/bash bubbles/scripts/implementation-reality-scan.sh bugs/BUG-037-session-cap-cross-session-attribution`
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** The scanner found zero implementation violations across 34 files. Its one warning reflects its requirement for a dedicated `### Implementation Files` heading; the existing single-file plan declares the six Scope 3 paths in its inventory, immutable boundary, change boundary, and Test Plan instead.

```text
INFO: Scopes yielded 0 files - falling back to design.md for file discovery
WARN: Resolved 34 file(s) from design.md fallback - scopes.md should reference these directly
INFO: Resolved 34 implementation file(s) to scan
--- Scan 1: Gateway/Backend Stub Patterns ---
--- Scan 2: Frontend Hardcoded Data Patterns ---
--- Scan 4: Prohibited Simulation Helpers in Production ---
--- Scan 5: Default/Fallback Value Patterns ---
--- Scan 6: Live-System Test Interception ---
--- Scan 7: IDOR / Auth Bypass Detection (Gate G047) ---
--- Scan 8: Silent Decode Failure Detection (Gate G048) ---
IMPLEMENTATION REALITY SCAN RESULT
Files scanned: 34
Violations: 0
Warnings: 1
PASSED with 1 warning(s) - manual review advised
```

### Scope 3 Implementation Verdict

**Phase:** implement
**Claim Source:** executed

Scope 3 implementation-owner checks pass on current bytes. The bug remains
`in_progress`, certification remains unchanged, and independent test ownership
belongs to `bubbles.test`.

## Scope 3 Independent Test Verification - 2026-09-02

### Scope 3 Independent Binding And Selection

**Phase:** test
**Claim Source:** executed

The supplied actionable packet passed `repository-binding.sh validate-packet`
against its external session control file. The validator reported repository
`bubbles-g128-session-scope-r1`, decision revision 1, and `actionable=true`.

The v7 tuple `fix action:fastlane target:bug` resolved to the persisted
`bugfix-fastlane` mode. Grandfathered persisted-mode resolution exited 0. Its
captured 46-line output has SHA-256
`986156f2dbb912fa87df07d087705abebbe2af8d9db0959aa61484fc7b443022`.

Tool-log row 183 records the linked-test resolver. It resolved all 59
pre-adjudication `BUG-037`-labeled scenario references and exited 0. The
canonical mapping is `BUG-054`. Its captured output has SHA-256
`92afb2f2bed3878dc90c23148f8691868a5c1774e36126f6e29393a07b86b82b`.

### Scope 3 Independent TP-03-01 Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/tool-log-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 184 binds the command to the current `tool-log.sh`, selftest, and
schema bytes. The complete 14-line child output has SHA-256
`c6d28c3697ae67abea4a011f9823602ee8d00fae7d6a77574eed6f98185bbca8`.
The structured receipt has stdout SHA-256
`e004d8e42f425df0b9102fc634828962f5208cd3b9650eae2cd8d28ce2df6fb4`.

```text
PASS: Case 1: success command preserves exit 0
PASS: Case 1: stdout streamed to caller
PASS: Case 1: log file created
PASS: Case 1: log has exactly one line
PASS: Case 1: JSON record has all required fields with correct values
PASS: Case 2: failure command preserves exit 42
PASS: Case 2: log appended (now 2 lines)
PASS: Case 2: same sessionId across calls; exit recorded
PASS: Case 3: distinct sessionId produces distinct log entries
SKIP: Case 4 schema validation (jsonschema not available)
PASS: Case 5: concurrent wrappers both preserve exit 0
CONCURRENT_SESSION_BYTES_OK
PASS: Case 5: concurrent delta has one distinct valid byte-bearing row per session
tool-log-selftest: PASS
```

#### Scope 3 Optional Dependency Classification

**Phase:** test
**Claim Source:** interpreted
**Interpretation:** Case 4 is an optional library-backed schema check. The
planned receipt assertions are Cases 1 through 3 and Case 5. Those assertions
all executed and passed.

Cases 1 through 3 and Case 5 are the required TP-03-01 receipt contract. They
all executed. Case 5 compares the physical append delta and requires exactly
one valid byte-bearing row for each concurrent session.

Case 4 is an optional library-backed schema check. The framework's
cross-platform shell policy requires graceful skip when an optional Python
module is absent. TP-03-01 does not name that optional library as a required
assertion. The skip therefore does not bypass a Scope 3 assertion.

### Scope 3 Independent TP-03-02 Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/usage-adapter-contract-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 185 binds the command to the current adapter, safe reader, and
selftest bytes. The complete 35-line child output has SHA-256
`552c9fb091d2198ab01b262044306b115e3454b027f210a92d55373e6b05d5c8`.
The structured receipt has stdout SHA-256
`7d16beea9601fea5b510bf37536bb10f8171f137d9f6357189df8a9ce7312f43`.

```text
ok   vscode-copilot totals one exact artifact and emits exact identity proof
ok   vscode-copilot requests returns only the exact artifact records
ok   BUG-037 unscoped requests and session verbs return neutral shapes
ok   BUG-037 prefix-only selectors return neutral shapes
ok   BUG-037 duplicate exact artifacts are ambiguous and return neutral shapes
ok   BUG-037 exact selection preserves newline filename bytes
ok   BUG-037 exact symlink artifacts fail loud
ok   BUG-037 symlink usage roots fail loud
ok   BUG-037 non-regular exact artifacts fail loud
ok   BUG-037 unreadable traversal fails loud
ok   BUG-037 unreadable exact artifacts fail loud
ok   BUG-037 symlinked traversal parents cannot escape containment
ok   BUG-037 replacement during exact artifact traversal fails loud
ok   BUG-037 malformed exact artifacts fail loud
ok   BUG-037 mixed valid and null prompt-token records fail loud
ok   BUG-037 incomplete request-like records fail loud
ok   BUG-037 exact artifacts with no request-like object remain neutral
usage-adapter-contract-selftest: 34 check(s), 0 failure(s)
```

The output contains every pre-adjudication `BUG-037` exact-selector assertion.
Those assertions now map to canonical `BUG-054`. None used the
test's `jq not installed` fallback branch. Exact absence and ambiguity remain
unmeasurable. Unsafe or incomplete exact input fails closed.

### Scope 3 Independent TP-03-03 Evidence

**Phase:** test
**Command:** `/bin/bash bubbles/scripts/session-cap-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

Tool-log row 186 binds the command to the current G128 guard, safe reader,
usage adapter, and selftest bytes. The complete 308-line child output has
SHA-256
`6c50d9a27b9ac1dd91843ddce360b6344a07e02d2509dc636143eba4a9380dd4`.
The structured receipt has stdout SHA-256
`ac7e703d1f071934c6501367879fd6fc722fbdd8ddd0b2bec8200343eea12148`.

```text
[selftest] PASS: S3a first verdict remains on the captured under-cap tool-log prefix: exit 0
[selftest] PASS: S3a jq never received the live tool-log pathname after capture
[selftest] PASS: S3a a later invocation observes the replacement tool-log prefix: exit 1
[selftest] PASS: S3b absent byte partners contribute zero when the present member is valid: exit 0
[selftest] PASS: S3b present null stdoutBytes fails closed: exit 2
[selftest] PASS: S3b present null stderrBytes fails closed: exit 2
[selftest] PASS: S3b an interior empty physical receipt row fails closed: exit 2
[selftest] PASS: S3b a symlink tool log fails before receipt evaluation: exit 2
[selftest] PASS: S3b an unreadable tool log fails before receipt evaluation: exit 2
[selftest] PASS: S3c a usage result missing request count is invalid: exit 2
Passed assertions: 253
Failed assertions: 0
session-cap-guard-selftest: ALL SCENARIOS PASS
```

The same immutable prefix backs maximum and cumulative receipt bytes. Invalid
matching rows emit no partial dimensions or summary. The closed usage proof
requires exact identity, one artifact, request count, and valid token totals.

### Scope 3 Independent Non-Vacuity And Quality Evidence

**Phase:** test
**Claim Source:** executed

The project mutation resolver returned `adapter=none`. The scenario contracts
therefore use their declared perturbed-input controls. Tool-log row 197 records
the corrected disposable mutation run. It caught all six mutations and proved
that candidate source hashes remained unchanged. The complete 856-line output
has SHA-256
`a46afd4024668a91a45e4dc1d9654c9684b4f62e6ab458b1afccbc2a939c4acf`.

```text
MUTATION_CAUGHT name=receipt-session-attribution
MUTATION_CAUGHT name=exact-artifact-name-selection
MUTATION_CAUGHT name=candidate-no-follow-open
MUTATION_CAUGHT name=prompt-token-integer-validation
MUTATION_CAUGHT name=present-null-byte-validation
MUTATION_CAUGHT name=closed-usage-request-proof
MUTATIONS_CAUGHT=6/6
CANDIDATE_SOURCE_UNCHANGED=true
BUG037_SCOPE3_MUTATION_FAILURES=0
BUG037_SCOPE3_MUTATION_SENSITIVITY_END
```

The bugfix regression-quality guard exited 0 on all three Scope 3 test owners.
It reported zero violations and zero warnings. Its captured 18-line output has
SHA-256
`5775ebb11e000e361b60c3558d5e9518774533dc26a9775f5d2594f2ead8d452`.

Bash syntax exited 0 for all five shell paths. In-memory Python compilation
exited 0 with output `PYTHON_SCOPE3_SYNTAX_OK` and SHA-256
`b3d1c828e2c1312604134a23b1a23bc7a00c87f4394c01d020bd049941c321ba`.
ShellCheck at warning severity exited 0. The all-severity diagnostic run found
only information and style codes `SC2329`, `SC2015`, and `SC2181`.

The token-boundary skip-marker scan found no `skip`, `only`, `todo`, `pending`,
or disabled test marker. The optional jsonschema text and unexecuted
dependency-absence branches are not test-runner skip markers.

### Scope 3 Independent Boundary And Preservation Evidence

**Phase:** test
**Claim Source:** executed

Tool-log row 199 records the corrected 36-line preservation matrix. It exited
0 with SHA-256
`4bb3d44bff6365323d8bb6d62d78b39935b60126c8c111cadfff818da8c90e52`.

```text
SCOPE3_DIFF_CHECK_EXIT=0
SOURCE_SPECS_DIRECTORY_ABSENT=true
STRICT_GREATER_THAN_PRESERVED=true
SOFT_BOUNDARY_70_PRESERVED=true
MAX_TOOL_CALLS_UNMEASURABLE_NO_PROXY=true
SEVEN_CAP_SCHEMA_PRESERVED=true
BUG037_SCOPE3_PRESERVATION_FAILURES=0
```

The six current Scope 3 path hashes are:

| Path | SHA-256 |
| --- | --- |
| `bubbles/scripts/session-state-io.py` | `831faef531cff1dc638c822421abe2f944a856a792bded2643bc824801912b37` |
| `bubbles/adapters/usage/vscode-copilot.sh` | `4f71e50b8e577cd6d7347b6290c231efb23543f7d03675255d4f963afc858523` |
| `bubbles/scripts/session-cap-guard.sh` | `d7ae40255bd5e752bbd2ebdd6f77010a5042997d914629b684b0a834c420e0aa` |
| `bubbles/scripts/tool-log-selftest.sh` | `890ecd3a9172a8bdb571ce4509b5d5cdb5f16baaf3cc9abfe98ffb1369bd74c8` |
| `bubbles/scripts/usage-adapter-contract-selftest.sh` | `2c924d641dc2e14b7c9253062f3c9a1f1ca17955bf59b09c19be404c42838add` |
| `bubbles/scripts/session-cap-guard-selftest.sh` | `49bf884c975a2e118f23c7dab397a89b0e8e9c3f2ca97d79c94d48b98b61f9c3` |

`tool-log.sh`, both G082 files, and `bubbles/workflows/modes.yaml` remain
byte-identical to `HEAD`. The pre-Scope-3 closure hashes also still match for
the modified Scope 4 caller and caller-test paths. Scope 3 did not alter those
pre-existing candidate bytes.

The seven cap names retain integer type and null defaults. The mode-value
registry remains byte-identical. G128 retains strict `observed > cap`, the 70
percent soft boundary, append-only history, and
`maxToolCalls=UNMEASURABLE` with reason `no-exact-producer`.

Before this test-owned update, certification remained `in_progress`. Its
canonical SHA-256 was
`297a0fc7a817ed212878af757031a39b540dc803c230269b601bd893bd1a9e41`.

### Scope 3 Independent Command Correction Accounting

**Phase:** test
**Claim Source:** executed

The initial mode probes used an invalid combined v7 argument and omitted the
persisted-mode grandfather switch. Corrected resolution then exited 0.

The first empty-output Bash syntax capture exposed an
`evidence-capture.sh` zero-line formatting defect. Tool-log row 189 records the
same `bash -n` command directly with exit 0 and empty stdout and stderr hashes.

Tool-log row 190 selected Apple's Xcode-bound Python and exited 69. Row 191
used the PATH-resolved Homebrew Python and compiled the helper successfully.
No dependency or license state changed.

Tool-log row 195 attempted a PyYAML-based cap parser and exited 1 because the
optional module is absent. The corrected parser used the required `yq` binary.

Tool-log row 196 exposed two mutation-harness changes that independent defenses
neutralized. Row 197 strengthened those disposable mutations and caught all
six. Tool-log row 198 used an incorrect textual 70 percent predicate. Row 199
matched the production numeric expression and exited 0. None of these invalid
or diagnostic receipts supports the independent test verdict.

Tool-log row 200 caught an unscoped status edit that changed the first matching
Scope 1 line instead of Scope 3. The correction restored Scope 1 and changed
only the heading-scoped Scope 3 line. Row 201 then passed the same state,
scope, report, and certification-coherence assertions.

### Scope 3 Post-Edit Governance Evidence

**Phase:** test
**Claim Source:** executed

| Receipt | Check | Exit | Captured output SHA-256 or direct signal |
| ---: | --- | ---: | --- |
| 201 | State, report, scope, and certification coherence | 0 | `SCOPE3_POST_EDIT_STATE_COHERENT` |
| 202 | Execution substate guard | 0 | `04c66dc438baa0c7ad74f3bbfb2d901f1ecf726b46619f728f43cfabf3aeab75` |
| 203 | Pre-adjudication `BUG-037` artifact lint | 0 | `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567` |
| 204 | Traceability guard | 0 | `5856f9826abc740c8115d13b4f602e9c90211588a1635ffef5f106f84072c4b4` |
| 205 | Test-mechanism lint | 0 | `ed6fef21ede9b64f05ebe8d14bb47b9670ecace3c68eccb503eb87bb6f366d38` |
| 206 | Scenario-obligation lint | 0 | `be4a8642358b3229128f01071fd9f4af59e279e391114e54083fad5c637eb8da` |
| 207 | Required skip and fake-live mock scan | 0 | Both pattern searches returned expected no-match exit 1 |
| 208 | Implementation reality scan | 0 | `0aea0474da2e34025c822af8367474d14c7821153128e1a4045fb2e1e16e633f` |
| 209 | Technical prose lint | 0 | `a07a5f9d65cdd5cd8837b655fc00759b2d2c94978a11d81b3703693f4b9eb413` |

Artifact lint found all required artifacts and passed its anti-fabrication
checks. Traceability checked 15 scenarios and 25 test rows with zero warnings.
The mechanism and obligation linters accepted all 15 scenario declarations.
The reality scan found zero violations. It reported one discovery warning
because this single-file plan relies on its declared `design.md` fallback.

### Scope 3 Independent Test Verdict

**Phase:** test
**Claim Source:** executed

TP-03-01, TP-03-02, and TP-03-03 passed as fresh independent executions on the
current six-path candidate. Every required Scope 3 assertion executed. The
optional jsonschema branch is permitted optional-capability degradation and is
not a skipped planned assertion.

Scope 3 is independently verified. BUG-054 remains `in_progress`.
Certification and human acceptance remain unchanged. Scope 4 is next and must
route through the top-level workflow runner to `bubbles.implement`.

## Scope 4 Implementation Evidence - 2026-09-02

### Scope 4 Binding And Execution Boundary

**Phase:** implement
**Claim Source:** executed

The exact revision-3 repository packet passed `repository-binding.sh
validate-packet` before this bookkeeping run read or wrote repository files.
The canonical `fix action:fastlane target:bug` mode resolved with
`statusCeiling: done`. Open-file and active-process checks found no competing
writer for the BUG-054 artifacts.

This run changed only this implementation-owned report section and the
execution fields in `state.json`. It did not start Scope 5, execute TP-04-02,
generate release metadata, change certification, or alter the preserved
untracked `.specify/memory/bubbles.session.json.flock` file.

### Scope 4 Current-Byte Receipt Evidence

**Phase:** implement
**Claim Source:** executed

The final green receipts and every entry in their input closures were compared
directly with the current checkout. All recorded SHA-256 values matched.

| Test Plan row | Tool-log receipt | Exit | Duration | Output evidence | Current-byte result |
| --- | ---: | ---: | ---: | --- | --- |
| `TP-04-01` | 231 | 0 | 1,539 ms | stdout SHA-256 `b68882c1c66b23cc706d2b72f80021aa2b46c68ae691649b37b3170661a05aee`, 2,896 bytes | All three closure entries matched. |
| `TP-04-02` | 238 | 0 | 789,954 ms | stdout SHA-256 `91e90a64eee7a861c1a5d129275ffd04b52373dc57b0aa885eaf52f22c4ad4c2`, 5,666 bytes | All six closure entries matched. |
| `TP-04-03` | 230 | 0 | 62,797 ms | stdout SHA-256 `193b0a0a07539e6cb3c073f69d4fa8cad1e82b09cb736723e84a8019c0ada263`, 2,542 bytes | All five closure entries matched. |

Each receipt records the empty-stream SHA-256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`
and zero bytes for stderr. TP-04-01 and TP-04-03 were not rerun because their
complete relevant closures still match current bytes. Row 238 remains the final
TP-04-02 execution. This bookkeeping run did not execute that command again.

### Scope 4 TP-04-02 Repair Accounting

**Phase:** implement
**Claim Source:** executed

The hostile-CWD fixture retains the complete transition-guard fast path. A
separate real G090 invocation uses the disposable repository as its explicit
root, proving that the ambient directory does not select runtime state.

The passing Check 40 fixture measures eight convergence iterations against a
cap of ten. It now requires `G128 status=SOFT-BOUNDARY exit=0` and the matching
caller-owned `Check 40 PASS` record instead of incorrectly requiring `PASS`.
Row 238 is the final green execution containing both repairs.

### Scope 4 Finding Accounting

| Finding | Disposition | Evidence |
| --- | --- | --- |
| `RF-B054-02` | Addressed. Check 40 and framework validation validate actionable packet authority, require a stable available guard, and accept only the closed child status and exit matrix. | Rows 230 and 238 |
| `RF-B054-07` | Addressed. G082 filters the authoritative host session and target spec while retaining the per-spec maximum. | Row 231 |
| Hostile-CWD transition fixture lost the complete caller path when testing G090. | Addressed. The transition fixture keeps its full fast path, and G090 executes separately against the disposable repository root. | Row 238 |
| The passing Check 40 fixture expected `PASS` for an observed value of 8 against a cap of 10. | Addressed. The fixture now requires the correct `SOFT-BOUNDARY` status with exit 0. | Row 238 |
| Scope 4 bookkeeping introduced one report prose-semicolon finding. | Addressed. The sentence was split, and the same lint then reported only the two pre-existing findings. | Row 257 |

No Scope 4 implementation finding remains unresolved. Independent verification
is not claimed by this implementation record.

### Scope 4 Quality And Work-Boundary Evidence

**Phase:** implement
**Claim Source:** executed

Rows 253 through 257 record the post-edit bookkeeping checks.

| Receipt | Check | Exit | Direct signal |
| ---: | --- | ---: | --- |
| 239 | Stock macOS Bash syntax over the seven Scope 4 caller, guard, and selftest paths | 0 | Empty stdout and stderr with recorded exit 0 |
| 240 | Homebrew Bash syntax over the same paths | 0 | Empty stdout and stderr with recorded exit 0 |
| 241 | Bugfix regression-quality guard over the three Scope 4 test owners | 0 | Three adversarial signals, zero violations, zero warnings; complete output SHA-256 `b9430dcc9df827833cdb717e8cb82e67b223d03170a8e6e87932aba026118812` |
| 242 | Focused `git diff --check` over the six modified Scope 4 implementation paths | 0 | Empty stdout and stderr with recorded exit 0 |
| 243-250 | Strict work-boundary resolution for six implementation paths plus `report.md` and `state.json` | 0 | Every candidate resolved `disposition=in-boundary` and `repoMatch=true` |
| 251 | Parent `state-transition-guard.sh` diff check | 0 | Parent script remains unchanged |
| 252 | Pre-edit protected-artifact identity capture | 0 | Release metadata, planning artifacts, user validation, and the preserved lock were hashed before bookkeeping |

### Scope 4 Post-Edit Bookkeeping Evidence

**Phase:** implement
**Claim Source:** executed

| Receipt | Check | Exit | Direct signal |
| ---: | --- | ---: | --- |
| 253 | Exact Scope 4 state and execution-history assertion | 0 | Printed `true`; routing points to `bubbles.test`, and certification retains its nonterminal values |
| 254 | Execution-substate guard | 0 | Valid implementation substate remains distinct from certification; complete output SHA-256 `04c66dc438baa0c7ad74f3bbfb2d901f1ecf726b46619f728f43cfabf3aeab75` |
| 255 | Focused pre-adjudication `BUG-037` artifact lint | 0 | All required artifacts and anti-fabrication checks passed; complete output SHA-256 `182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567` |
| 257 | Report technical-prose recheck | 0 | No Scope 4 prose-semicolon finding remains; complete output SHA-256 `20baf3c8ac159af3ba338c64d757ea15aaa0429ac61fdb1aeee474e35a73192b` |

### Scope 4 Implementation Verdict

**Phase:** implement
**Claim Source:** executed

Scope 4 implementation and implementation-owned checks are complete on the
current bytes. BUG-054 remains `in_progress`. Certification and human
acceptance remain unchanged. Scope 5 remains unstarted. The required owner is
`bubbles.test` for independent Scope 4 verification.

## Identity Adjudication Route Reconciliation - 2026-09-02

### Preservation Constraint

**Phase:** bug
**Constraint Source:** operator

The operator requires every dirty byte to remain intact. The operator
prohibits reset, stash, and shell mutation. Three recorded IDE patch deletion
attempts left the old directory unchanged. Physical deletion is unavailable
through the permitted edit surface. It is not permitted for this route.

### Candidate Exclusion Evidence

**Phase:** bug
**Command:** `/opt/local/bin/git status --short --untracked-files=all -- bugs/BUG-037-session-cap-cross-session-attribution bugs/BUG-054-session-cap-cross-session-attribution bugs/_superseded-draft-037-session-cap-cross-session-attribution`; `/opt/local/bin/git ls-files --stage -- bugs/BUG-037-session-cap-cross-session-attribution bugs/BUG-054-session-cap-cross-session-attribution bugs/_superseded-draft-037-session-cap-cross-session-attribution`; `/opt/local/bin/git diff --cached --name-status -- bugs/BUG-037-session-cap-cross-session-attribution`
**Exit Code:** 0
**Claim Source:** interpreted
**Interpretation:** Every old entry is untracked. The index and cached-diff
sections are empty, so the old path has no tracked or staged entry.

```text
BUG054_PREEDIT_INDEX_CLASSIFICATION_BEGIN
GIT_STATUS_PATHS_BEGIN
?? bugs/BUG-037-session-cap-cross-session-attribution/bug.md
?? bugs/BUG-037-session-cap-cross-session-attribution/design.md
?? bugs/BUG-037-session-cap-cross-session-attribution/report.md
?? bugs/BUG-037-session-cap-cross-session-attribution/scenario-manifest.json
?? bugs/BUG-037-session-cap-cross-session-attribution/scopes.md
?? bugs/BUG-037-session-cap-cross-session-attribution/spec.md
?? bugs/BUG-037-session-cap-cross-session-attribution/state.json
?? bugs/BUG-037-session-cap-cross-session-attribution/test-plan.json
?? bugs/BUG-037-session-cap-cross-session-attribution/uservalidation.md
?? bugs/BUG-054-session-cap-cross-session-attribution/bug.md
?? bugs/BUG-054-session-cap-cross-session-attribution/design.md
?? bugs/BUG-054-session-cap-cross-session-attribution/report.md
?? bugs/BUG-054-session-cap-cross-session-attribution/scenario-manifest.json
?? bugs/BUG-054-session-cap-cross-session-attribution/scopes.md
?? bugs/BUG-054-session-cap-cross-session-attribution/spec.md
?? bugs/BUG-054-session-cap-cross-session-attribution/state.json
?? bugs/BUG-054-session-cap-cross-session-attribution/test-plan.json
?? bugs/BUG-054-session-cap-cross-session-attribution/uservalidation.md
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/bug.md
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/design.md
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/report.md
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/scenario-manifest.json
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/scopes.md
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/spec.md
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/state.json
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/test-plan.json
?? bugs/_superseded-draft-037-session-cap-cross-session-attribution/uservalidation.md
GIT_STATUS_PATHS_EXIT=0
GIT_LS_FILES_STAGE_BEGIN
GIT_LS_FILES_STAGE_EXIT=0
OLD_PATH_CACHED_DIFF_BEGIN
OLD_PATH_CACHED_DIFF_EXIT=0
BUG054_PREEDIT_INDEX_CLASSIFICATION_END
```

### Routing Disposition

Candidate exclusion closes `ID-DELETE-001` as an execution-routing blocker.
It does not delete or reclassify the retained local residue.

Exclude the old path from every staging operation, commit, and candidate.
Before commit, assert that the old path is neither tracked nor staged. Before
release validation, use a clean worktree created from the committed candidate.
Assert that it contains exactly one canonical `BUG-054` directory and no
duplicate canonical bug ID.

This reconciliation makes no Scope 4 verification claim. The operator reports
independent passes for `TP-04-01` and `TP-04-03`. That report remains
diagnostic input rather than this agent's execution evidence. The operator also
reports that a concurrent full selftest contaminated `TP-04-02`.

`bubbles.test` must rerun `TP-04-02` in isolation before adjudicating Scope 4.
Scope 5 remains unstarted. Certification and human acceptance remain unchanged.

## Goal-Node Physical Deletion Retry - 2026-09-02

### Binding And Boundary

**Phase:** bug
**Claim Source:** executed

The exact inherited goal-node packet passed `repository-binding.sh
validate-packet` at control revision 8 before this retry read or wrote the
worktree. No preflight ran, and command affinity remained unchanged.

This retry targeted only the nine files under
`bugs/BUG-037-session-cap-cross-session-attribution`. It used the IDE patch
surface for attempted deletion. It did not use shell `rm`, `unlink`, `mv`, or
redirection.

### Pre-Delete Byte Evidence

**Phase:** bug
**Command:** bounded nine-file SHA-256 and `cmp` matrix over the original,
archive, and canonical BUG-054 packet
**Exit Code:** 0
**Claim Source:** executed

```text
ID_DELETE_001_PREDELETE_BYTES_BEGIN
EXPECTED_FILE_COUNT=9
ORIGINAL_FILE_COUNT=9
ARCHIVE_FILE_COUNT=9
CANONICAL_BUG054_FILE_COUNT=9
FILE=bug.md ORIGINAL_SHA256=c19cac8d63ff8ad3a7e9f284fbe07ea53211fc328d0a916b6661a207fd73c2ae ARCHIVE_SHA256=c19cac8d63ff8ad3a7e9f284fbe07ea53211fc328d0a916b6661a207fd73c2ae CMP_EXIT=0
FILE=design.md ORIGINAL_SHA256=92084767f8f778bffe59a8d3c8e10dbd3ccb68c133cf2a51b1c8ad29c28c4055 ARCHIVE_SHA256=92084767f8f778bffe59a8d3c8e10dbd3ccb68c133cf2a51b1c8ad29c28c4055 CMP_EXIT=0
FILE=report.md ORIGINAL_SHA256=0b0dba6e3b782176247b7dc2519d68c28670855643003be82f6bd783f4b40fb2 ARCHIVE_SHA256=0b0dba6e3b782176247b7dc2519d68c28670855643003be82f6bd783f4b40fb2 CMP_EXIT=0
FILE=scenario-manifest.json ORIGINAL_SHA256=c91a1700a825558262b6d6eb4d21199c7e20560190442402604d79a0014ab876 ARCHIVE_SHA256=c91a1700a825558262b6d6eb4d21199c7e20560190442402604d79a0014ab876 CMP_EXIT=0
FILE=scopes.md ORIGINAL_SHA256=1f986fd592e956a9ca012385d888156291934774dd3f5b96c8a8448448eb0548 ARCHIVE_SHA256=1f986fd592e956a9ca012385d888156291934774dd3f5b96c8a8448448eb0548 CMP_EXIT=0
FILE=spec.md ORIGINAL_SHA256=f37e7b538678bb2b5de66a29ede71914af5aa96701aa4184fb03efddb3f1d79e ARCHIVE_SHA256=f37e7b538678bb2b5de66a29ede71914af5aa96701aa4184fb03efddb3f1d79e CMP_EXIT=0
FILE=state.json ORIGINAL_SHA256=84d8658a1137bd7e9742e9361711397642a7bd450629ea84c31c8c2e00698c7e ARCHIVE_SHA256=84d8658a1137bd7e9742e9361711397642a7bd450629ea84c31c8c2e00698c7e CMP_EXIT=0
FILE=test-plan.json ORIGINAL_SHA256=2dc386c6b2a82ffe2cfcbdf417a70e62e15e85b94040c8f8d86f9d492a252afb ARCHIVE_SHA256=2dc386c6b2a82ffe2cfcbdf417a70e62e15e85b94040c8f8d86f9d492a252afb CMP_EXIT=0
FILE=uservalidation.md ORIGINAL_SHA256=632ccab60c4c02d47428b52f9dcab81e2add0566fc63523e2b97323863620f42 ARCHIVE_SHA256=632ccab60c4c02d47428b52f9dcab81e2add0566fc63523e2b97323863620f42 CMP_EXIT=0
PREDELETE_FAILURES=0
ID_DELETE_001_PREDELETE_BYTES_END
```

### Post-Delete Disconfirmation

**Phase:** bug
**Command:** immediate bounded old-path, retained-hash, BUG-054-hash, and
canonical-identity check after the IDE deletion operation
**Exit Code:** 1
**Claim Source:** executed

```text
ID_DELETE_001_POSTDELETE_FOCUSED_BEGIN
OLD_PATH_EXISTS=true
ARCHIVE_FILE_COUNT=9
CANONICAL_BUG054_FILE_COUNT=9
CANONICAL_DIRECTORY_GLOB_COUNT=6
BUG054_CANONICAL_DIRECTORY_COUNT=1
FILE=bug.md ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=design.md ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=report.md ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=scenario-manifest.json ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=scopes.md ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=spec.md ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=state.json ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=test-plan.json ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
FILE=uservalidation.md ARCHIVE_RETAINED=true BUG054_UNCHANGED=true
DUPLICATE_CANONICAL_ID_COUNT=0
POSTDELETE_FAILURES=1
ID_DELETE_001_POSTDELETE_FOCUSED_END
```

The executable check falsified physical deletion. The IDE patch result alone
cannot support an absence claim.

### Probe Restoration

**Phase:** bug
**Command:** bounded nine-file SHA-256 and `cmp` matrix after restoring the
one-file IDE acquisition probe
**Exit Code:** 0
**Claim Source:** executed

```text
ID_DELETE_001_PROBE_RESTORE_BEGIN
FILE=bug.md CMP_EXIT=0
FILE=design.md CMP_EXIT=0
FILE=report.md CMP_EXIT=0
FILE=scenario-manifest.json CMP_EXIT=0
FILE=scopes.md CMP_EXIT=0
FILE=spec.md CMP_EXIT=0
FILE=state.json CMP_EXIT=0
FILE=test-plan.json CMP_EXIT=0
FILE=uservalidation.md CMP_EXIT=0
RESTORE_FAILURES=0
ID_DELETE_001_PROBE_RESTORE_END
```

### Finding And Route

`ID-DELETE-001` remains unresolved. Candidate exclusion does not meet this
goal node's physical absence condition. The next required owner remains
`bubbles.bug`. Routing to `bubbles.test` is withheld until a permitted IDE
file operation removes the nine original files and empty directory, and the
same old-path and retained-hash checks pass.

### Focused Post-Edit Checks

**Phase:** bug
**Claim Source:** executed

The canonical artifact lint exited 0. Its 40-line captured output has SHA-256
`182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567`.

```text
# BUG-054 identity reconciliation artifact lint
$ /opt/homebrew/bin/bash bubbles/scripts/artifact-lint.sh bugs/BUG-054-session-cap-cross-session-attribution
exit: 0
lines: 40
sha256: 182cf27f7948b167f9fdebccae5bf6994636355face5d8ae0a4d55666dc9b567
✅ Required artifact exists: spec.md
✅ Required artifact exists: design.md
✅ Required artifact exists: uservalidation.md
✅ Required artifact exists: state.json
✅ Required artifact exists: scopes.md
✅ Required artifact exists: report.md
✅ Detected state.json status: in_progress
✅ Detected state.json workflowMode: bugfix-fastlane
✅ Top-level status matches certification.status
✅ No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
```

The focused reference lint exited 0 with this complete output.

```text
[reference-existence-lint] OK — 6 markdown file(s) scanned, every relative link target resolves
```

The identity candidate check exited 0. Its 66-line captured output has SHA-256
`1d1f13ba50d953af0832eb1c99b129f58729df04428de1c99d28390deb98a84c`.

```text
ARTIFACT_ROOT=bugs/BUG-037-session-cap-cross-session-attribution FILE_COUNT=9
ARTIFACT_ROOT=bugs/BUG-054-session-cap-cross-session-attribution FILE_COUNT=9
ARTIFACT_ROOT=bugs/_superseded-draft-037-session-cap-cross-session-attribution FILE_COUNT=9
OLD_ARCHIVE_CMP file=bug.md exit=0
OLD_ARCHIVE_CMP file=design.md exit=0
OLD_ARCHIVE_CMP file=report.md exit=0
OLD_ARCHIVE_CMP file=scenario-manifest.json exit=0
OLD_ARCHIVE_CMP file=scopes.md exit=0
OLD_ARCHIVE_CMP file=spec.md exit=0
OLD_ARCHIVE_CMP file=state.json exit=0
OLD_ARCHIVE_CMP file=test-plan.json exit=0
OLD_ARCHIVE_CMP file=uservalidation.md exit=0
OLD_PATH_INDEX_QUERY_EXIT=1
OLD_PATH_TRACKED_OR_STAGED=false
LOCAL_RESIDUE_EXCLUDED=bugs/BUG-037-session-cap-cross-session-attribution
FILTERED_CANDIDATE_BUG054_COUNT=1
FILTERED_CANDIDATE_DUPLICATE_ID_COUNT=0
IDENTITY_CANDIDATE_FAILURES=0
BUG054_IDENTITY_CANDIDATE_CHECK_END
```

The first state probe named the unavailable `/opt/homebrew/bin/jq` path and
exited 127. It performed no write. The corrected probe resolved `/usr/bin/jq`.
It asserted the exact route and the complete unchanged certification object.

```text
BUG054_ROUTING_STATE_CHECK_BEGIN
JQ_PATH=/usr/bin/jq
true
ROUTING_AND_CERTIFICATION_ASSERT_EXIT=0
1714:## Identity Adjudication Route Reconciliation - 2026-09-02
CURRENT_EVIDENCE_ANCHOR_EXIT=0
BUG054_ROUTING_STATE_CHECK_END
```

## Goal-Node Exact Single-File Deletion Probe - 2026-09-02

### Binding And Scope

**Phase:** bug
**Claim Source:** executed

The inherited `bubbles-close-bug-054` goal-node packet passed
`repository-binding.sh validate-packet` at control revision 8. The validated
root was `/private/tmp/bubbles-g128-session-scope-r1`. No preflight ran, and
the command-level affinity was not changed.

This invocation was limited to `ID-DELETE-001`. The operator required one
exact IDE `Delete File` probe for the original `bug.md`, followed by an
immediate path check. A reported-success operation that did not unlink the
file was the explicit stop condition.

### Fresh Pre-Probe Identity

**Phase:** bug
**Claim Source:** executed

The original directory contained exactly the nine expected untracked files.
Every original returned `cmp` exit 0 against the retained archive copy.

| File | Original and archive SHA-256 | `cmp` exit |
| --- | --- | ---: |
| `bug.md` | `c19cac8d63ff8ad3a7e9f284fbe07ea53211fc328d0a916b6661a207fd73c2ae` | 0 |
| `design.md` | `92084767f8f778bffe59a8d3c8e10dbd3ccb68c133cf2a51b1c8ad29c28c4055` | 0 |
| `report.md` | `0b0dba6e3b782176247b7dc2519d68c28670855643003be82f6bd783f4b40fb2` | 0 |
| `scenario-manifest.json` | `c91a1700a825558262b6d6eb4d21199c7e20560190442402604d79a0014ab876` | 0 |
| `scopes.md` | `1f986fd592e956a9ca012385d888156291934774dd3f5b96c8a8448448eb0548` | 0 |
| `spec.md` | `f37e7b538678bb2b5de66a29ede71914af5aa96701aa4184fb03efddb3f1d79e` | 0 |
| `state.json` | `84d8658a1137bd7e9742e9361711397642a7bd450629ea84c31c8c2e00698c7e` | 0 |
| `test-plan.json` | `2dc386c6b2a82ffe2cfcbdf417a70e62e15e85b94040c8f8d86f9d492a252afb` | 0 |
| `uservalidation.md` | `632ccab60c4c02d47428b52f9dcab81e2add0566fc63523e2b97323863620f42` | 0 |

The same pre-probe inventory reported `IDENTITY_FAILURES=0`.

### Exact Probe And Immediate Disconfirmation

**Phase:** bug
**Claim Source:** executed

The IDE operation targeted only this exact absolute path:

```text
/private/tmp/bubbles-g128-session-scope-r1/bugs/BUG-037-session-cap-cross-session-attribution/bug.md
```

The edit API returned this result:

```text
The following files were successfully edited:
/private/tmp/bubbles-g128-session-scope-r1/bugs/BUG-037-session-cap-cross-session-attribution/bug.md
```

The immediate exact-path check then returned exit 1 with this complete output:

```text
ID_DELETE_001_PROBE_VERIFY_BEGIN
PROBE_PATH_PRESENT=/private/tmp/bubbles-g128-session-scope-r1/bugs/BUG-037-session-cap-cross-session-attribution/bug.md
ID_DELETE_001_PROBE_VERIFY_END
```

The path-presence check disproved physical deletion. The API success response
does not support an absence claim. No second probe ran, and none of the other
eight originals was targeted. Shell deletion and every destructive workaround
remained unused.

### Blocked Disposition

`ID-DELETE-001` remains unresolved. This invocation stopped at the required
first-probe failure. It did not run post-deletion artifact checks and did not
route BUG-054 to `bubbles.test` because the old-path absence precondition did
not pass.
