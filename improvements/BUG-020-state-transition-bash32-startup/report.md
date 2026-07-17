# Report: BUG-020 State Transition Bash 3.2 Startup

Related artifacts: [scopes.md](scopes.md),
[scenario-manifest.json](scenario-manifest.json),
[test-plan.json](test-plan.json), and
[uservalidation.md](uservalidation.md).

## Planning Reconciliation

### Planning Summary

The active plan contains one `Not started` runtime-behavior scope and three
split-lane scenario contracts. Parser-free Bash 3.2 proves the complete
fun-mode API, the strict system-only real-guard lane proves only the exact
`E009-REGISTRY-MISSING` refusal with no Check 8 credit, and parser-aware Bash
3.2 plus newer-Bash lanes prove Check 8 and structured pass/finding outcomes.
The plan preserves one portable shared `fun-mode.sh` implementation, BUG-022
ownership, an explicit portability-lint blind-spot regression, and canonical
install/release provenance.

### Decision Record

The selected repair changes only the shared presentation module: closed `case`
dispatch replaces associative event storage, and positional arguments replace
nameref pool selection. `state-transition-guard.sh`, the transition resolver,
parser policy, BUG-022 empty-array sites, Check 8, BUG-019 `test_26`, existing
local compatibility hooks, the generic portability guard, downstream installed
copies, and certification remain excluded from BUG-020 authorship.

### Planning Completion Statement

PLANNING RECONCILED; DELIVERY REMAINS BLOCKED. Existing `test_27`, fun-mode,
guard, resolver, sibling-packet, evidence, and certification bytes are
preserved by this planning reconciliation. The current candidate source
predates the required revised final test bytes, so neither the historical
HEAD-restored diagnostic nor the current-source parser-blocked run is credited
as scenario-first RED. Scope 1 remains `Not started`, every delivery DoD item
remains unchecked, packet and certification status remain `blocked`, and the
immediate owner is `bubbles.test` for the prospective isolated final-byte RED.

### Scenario Contract Evidence

| Scenario | Primary persistent evidence | Additional required proof |
| --- | --- | --- |
| `SCN-BUG-020-001` | `T-BUG-020-01`, `T-BUG-020-02`, `T-BUG-020-12`, and `T-BUG-020-13` in `tests/regression/test_27_state_transition_bash32_startup.sh` | exact seven-function behavior, message/pool compatibility, and root-cause construct rejection |
| `SCN-BUG-020-002` | `T-BUG-020-03` in `test_27` | exact `E009-REGISTRY-MISSING`, nonzero exit, and zero Check 8 credit; BUG-022 retains result-integrity ownership |
| `SCN-BUG-020-003` | `T-BUG-020-04` through `T-BUG-020-11` in `test_27` | parser-aware Bash 3.2/newer-Bash pass and genuine-finding twins plus `T-BUG-020-14` managed coverage |

### Planned Test Evidence

No new `bubbles.test` evidence for `T-BUG-020-00` through `T-BUG-020-26` is
recorded by this planning invocation. All prior diagnostic and execution blocks
below remain historical evidence with their original dispositions. None is
reclassified as the prospective final-byte RED or as split-lane GREEN.

### Uncertainty Declarations

- The existing `test_27` bytes do not yet implement the revised split-lane
  contract and remain exclusively test-owned.
- No prospective isolated run has executed revised final test bytes against the
  known pre-fix fun-mode blob before candidate application in the same lineage.
- No complete split-lane GREEN, managed selftest, provenance, framework,
  release, or certification evidence exists for the reconciled contract.
- These facts keep every delivery item unchecked; no result is inferred from
  source inspection or prior BUG-019 execution.

### Coverage Report

Planned coverage is three scenarios and 27 synchronized Test Plan rows. The
ordered persistent contract covers prospective RED, parser-free API behavior,
the disabled-fun system-only resolver refusal, parser-aware Bash 3.2 and
newer-Bash pass/finding outcomes, newer-Bash API compatibility, and the known
root-cause construct assertion. Remaining rows cover managed behavior,
integrity, containment, packet gates, install provenance, framework
integration, release integration, and final certification. No UI, datastore,
network, telemetry, stress, or load category applies.

### Lint/Quality

Planning closeout requires packet artifact lint, freshness, and traceability.
Delivery additionally requires regression integrity, Bash syntax, the current
13-class portability scan, the dedicated associative-array/nameref assertion,
exact changed-path containment, install provenance, framework validation, and
release readiness in the order defined by [scopes.md](scopes.md#test-plan).

### Validation Summary

Planning is internally reconciled; delivery remains blocked on the prospective
test-owned RED. Physical `test_27` bytes already exist, but they must be revised,
frozen, and executed first in the isolated pre-fix lineage before any candidate
patch in that lineage. Existing source or test bytes authorize no implementation
or completion claim.

### Audit Verdict

Not evaluated. No audit or certification specialist ran, and no certification
field or terminal status was written.

## Active Delivery Evidence Template

The sections below are empty execution destinations owned by the named future
specialists. They do not replace or reinterpret the historical evidence later
in this report.

### Prospective Isolated Final-Byte RED

Owner: `bubbles.test`. Record the revised `test_27` SHA-256, protected source
identities, isolated pre-fix fun-mode blob identity, parser controls, exact
command, actual nonzero exit, historical startup discriminator, run/assertion
totals, cleanup result, and proof that the same test digest is required for
GREEN. The historical HEAD-restored and current-source parser-blocked runs are
not valid entries here.

#### Test-Owned Prospective RED Round - 2026-07-17

**Phase:** test
**Captured At:** `2026-07-17T04:21:11Z`
**Claim Source:** executed
**Result:** PASS - expected pre-fix RED; no GREEN, DoD, scope-completion, or
certification claim

The final nonduplicated regression bytes were frozen at SHA-256
`5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d`.
They ran before any candidate patch in a unique isolated source projection.
That projection copied the current protected `bubbles/` and `agents/` surfaces,
then replaced only `bubbles/scripts/fun-mode.sh` with the known pre-fix Git blob
`7da650141188f120f5ac25d4f77fada91bc96e88`. The home prefix in commands is
normalized to `~`; command arguments and behavioral output are unchanged.

**Pre-RED identity command:** `shasum -a 256 improvements/BUG-020-state-transition-bash32-startup/state.json improvements/BUG-020-state-transition-bash32-startup/scopes.md improvements/BUG-020-state-transition-bash32-startup/test-plan.json improvements/BUG-020-state-transition-bash32-startup/report.md tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json && printf 'HEAD_FUN_MODE_BLOB=%s\n' "$(git rev-parse HEAD:bubbles/scripts/fun-mode.sh)"`
**Exit Code:** 0
**Output:**

```text
BUG020_PRE_RED_IDENTITY_BEGIN
b2ceb2320669a0405447faadcec1887672c3ee4b1aac0b68c8a4d3cda1124563  improvements/BUG-020-state-transition-bash32-startup/state.json
247fe7f49262af8080b53d1e3da13553717a9392a87f0b37ed2c81cdf0ddbdff  improvements/BUG-020-state-transition-bash32-startup/scopes.md
a061887fa6b76558e87ec3fe6eada8ebd55e4981f561b8c1c161ba2da788e8fc  improvements/BUG-020-state-transition-bash32-startup/test-plan.json
8c2764f0181ac9f152106e51d0e22ed7408dfe6c332897a5d30828d0a80edbe2  improvements/BUG-020-state-transition-bash32-startup/report.md
5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d  tests/regression/test_27_state_transition_bash32_startup.sh
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a  bubbles/scripts/state-transition-guard.sh
c04eae6dd49fcd774d641f80bf924539755ee7cac45f6780559c50665ad049ff  improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json
HEAD_FUN_MODE_BLOB=7da650141188f120f5ac25d4f77fada91bc96e88
BUG020_PRE_RED_IDENTITY_END
```

**Prospective RED command:**

```bash
red_root="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug020-red-XXXXXXXX")" && cleanup_red_root() { rm -rf "$red_root"; } && trap cleanup_red_root EXIT INT TERM && red_exit=0 && printf '%s\n' 'BUG020_PROSPECTIVE_RED_BEGIN' && printf 'RED_ROOT=%s\n' "$red_root" && printf 'EXPECTED_HEAD_FUN_MODE_BLOB=%s\n' '7da650141188f120f5ac25d4f77fada91bc96e88' && if [[ "$(git rev-parse HEAD:bubbles/scripts/fun-mode.sh)" != '7da650141188f120f5ac25d4f77fada91bc96e88' ]]; then printf '%s\n' 'BUG020_RED_CONTROL_FAILURE=head-fun-mode-blob-mismatch'; red_exit=98; else mkdir -p "$red_root/tests/regression" && cp -R bubbles agents "$red_root/" && cp tests/regression/test_27_state_transition_bash32_startup.sh "$red_root/tests/regression/" && git archive --format=tar --output="$red_root/pre-fix.tar" HEAD bubbles/scripts/fun-mode.sh && tar -xf "$red_root/pre-fix.tar" -C "$red_root" && rm -f "$red_root/pre-fix.tar" && printf 'HEAD_FUN_MODE_BLOB=%s\n' "$(git rev-parse HEAD:bubbles/scripts/fun-mode.sh)" && printf 'PRE_FIX_FUN_MODE_SHA256=%s\n' "$(shasum -a 256 "$red_root/bubbles/scripts/fun-mode.sh" | awk '{print $1}')" && printf '%s\n' 'RED_TEST_DIGESTS_BEGIN' && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh "$red_root/tests/regression/test_27_state_transition_bash32_startup.sh" && printf '%s\n' 'RED_TEST_EXECUTION_BEGIN' && (cd "$red_root" && bash tests/regression/test_27_state_transition_bash32_startup.sh); red_exit=$?; fi; printf 'BUG020_PROSPECTIVE_RED_EXIT=%s\n' "$red_exit"; printf 'POST_RED_CANONICAL_TEST_SHA256='; shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh; cleanup_red_root; trap - EXIT INT TERM; if [[ ! -e "$red_root" ]]; then printf '%s\n' 'BUG020_PROSPECTIVE_RED_FIXTURE_REMOVED=true'; else printf '%s\n' 'BUG020_PROSPECTIVE_RED_FIXTURE_REMOVED=false'; red_exit=99; fi; printf '%s\n' 'BUG020_PROSPECTIVE_RED_END'; exit "$red_exit"
```

**Exit Code:** 1 (expected RED)
**Output:** lines 981-1029 of 1030 captured lines

```text
=== BUG-020 regression summary ===
GUARD_RUNS=10
SYSTEM_GUARD_RUNS=2
PARSER_GUARD_RUNS=8
API_RUNS=4
ASSERTIONS=224
PASSED=165
FAILED=59
BASH32_API_STARTUP_ABORTS=2
BASH32_GUARD_STARTUP_ABORTS=5
BASH32_SYSTEM_GUARD_STARTUP_ABORTS=1
BASH32_PARSER_GUARD_STARTUP_ABORTS=4
BASH32_RESOLVER_REFUSALS=0
BASH32_BUG022_OBSERVATIONS=0
BASH32_FOREIGN_PRE_CHECK8_ABORTS=0
BASH32_OTHER_PRE_CHECK8_ABORTS=0
BASH32_PARSER_LANES_RESERVED=4
BASH32_PARSER_CHECK8_MARKERS=0
BASH32_PARSER_RESULT_MARKERS=0
STRICT_SYSTEM_CONTROL_RUNS=1
STRICT_SYSTEM_CONTROL_STATUS=2
STRICT_SYSTEM_CONTROL_E009_REFUSALS=1
STRICT_SYSTEM_CONTROL_CHECK8_MARKERS=0
NEWER_PARSER_CONTROL_RUNS=4
ROOT_CAUSE_CONSTRUCTS=2
DECLARE_A_CONSTRUCTS=1
LOCAL_N_CONSTRUCTS=1
DECLARE_N_CONSTRUCTS=0
ASSOCIATIVE_GATE_PASSED_ENTRIES=1
EXPECTED_RED_ASSERTION_FAILURES=59
UNRELATED_ASSERTION_FAILURES=0
CONTROL_FAILURES=0
HARNESS_FAILURES=0
FINAL_SOURCE_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
FINAL_SOURCE_FUN_MODE_SHA256=00bc5aa96744aaa0a3ac784b2577728a9318fe9f95f4b3b91f422eb8c078b386
FINAL_TEST_FILE_SHA256=5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d
PARSER_AWARE_BASH32_PROOF_STATUS=RESERVED_FOR_POST_PATCH_AND_BUG022
GREEN_MUST_USE_TEST_SHA256=5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d
BUG020_RED_DISPOSITION=VALID_PRE_FIX_RED
BUG-020 state-transition Bash 3.2 startup regression FAILED
BUG020_PROSPECTIVE_RED_EXIT=1
POST_RED_CANONICAL_TEST_SHA256=5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d  tests/regression/test_27_state_transition_bash32_startup.sh
BUG020_PROSPECTIVE_RED_FIXTURE_REMOVED=true
BUG020_PROSPECTIVE_RED_END
```

This is a causal RED, not an accepted failing suite. The two Bash 3.2 API
roles, one Bash 3.2 system-only guard role, and four Bash 3.2 parser-aware guard
roles all hit the historical pre-fix startup discriminator. The newer-Bash
system-only control reached exact `E009-REGISTRY-MISSING` with nonzero exit and
zero Check 8 markers, all four newer-Bash parser-aware controls completed, and
the regression reported zero control, harness, unrelated-assertion, BUG-022,
foreign pre-Check-8, and other pre-Check-8 failures. Reintroducing the pre-fix
blob therefore makes the frozen regression fail for the planned reason.

##### Focused Test Integrity And Portability

**Phase:** test
**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_27_state_transition_bash32_startup.sh`; `/bin/bash -n bubbles/scripts/fun-mode.sh tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh`; `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_27_state_transition_bash32_startup.sh`; token-aware skip and live-mock scans of `test_27`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG020_FOCUSED_INTEGRITY_RECHECK_BEGIN
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: ~/Projects/bubbles
  Bugfix mode: true
============================================================
ℹ️  Scanning tests/regression/test_27_state_transition_bash32_startup.sh
✅ Adversarial signal detected in tests/regression/test_27_state_transition_bash32_startup.sh
============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
REGRESSION_QUALITY_EXIT=0
BASH32_SYNTAX_EXIT=0
== macOS portability guard -- scanning 3 file(s) ==
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
MACOS_PORTABILITY_EXIT=0
SKIP_MARKER_SCAN=PASS_ZERO_MATCHES
LIVE_MOCK_SCAN=PASS_ZERO_MATCHES
FOCUSED_INTEGRITY_FAILURES=0
BUG020_FOCUSED_INTEGRITY_RECHECK_END
```

An earlier auxiliary live-mock grep used the bare token `nock`, which matched
the canonical message text `Knock knock` and made that aggregate command exit
`1`. The token-aware recheck above repaired the scanner, not the regression;
the canonical regression-quality, Bash syntax, and portability commands had
already exited `0` in both runs.

##### Packet Governance And Exact Test Plan Parity

**Phase:** test
**Command:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-020-state-transition-bash32-startup`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-020-state-transition-bash32-startup`; `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-020-state-transition-bash32-startup`; `bash bubbles/scripts/traceability-guard.sh improvements/BUG-020-state-transition-bash32-startup`
**Exit Code:** 0
**Claim Source:** executed
**Output:** artifact/freshness/G094 window, lines 68-101 of 194

```text
Artifact lint PASSED.
ARTIFACT_LINT_EXIT=0
============================================================
  BUBBLES ARTIFACT FRESHNESS GUARD
  Feature: improvements/BUG-020-state-transition-bash32-startup
  Timestamp: 2026-07-17T04:18:56Z
============================================================
--- Check 1: Freshness Boundary Isolation (spec.md / design.md) ---
ℹ️  spec.md has no superseded/suppressed sections
✅ design.md isolates superseded/suppressed sections at the end
--- Check 2: Superseded Scope Sections Are Non-Executable ---
ℹ️  scopes.md has no superseded scope section
ℹ️  No superseded scope sections detected
--- Check 3: Per-Scope Directory Index References ---
ℹ️  Single-file scope layout detected — orphaned per-scope directory check not applicable
--- Check 4: Result ---
RESULT: PASS (0 failures, 0 warnings)
ARTIFACT_FRESHNESS_EXIT=0
capability-foundation-guard: Gate G094 applies: triggerHits=9 concreteImplementationEntries=0
capability-foundation-guard: spec.md contains non-empty Single-Capability Justification
capability-foundation-guard: design.md contains non-empty Single-Implementation Justification
capability-foundation-guard: UX primitive check not applicable: screenCount=0 uiReuseHits=0
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
G094_CAPABILITY_EXIT=0
```

**Output:** traceability window, lines 182-194 of 194

```text
--- Traceability Summary ---
ℹ️  Scenarios checked: 3
ℹ️  Test rows checked: 27
ℹ️  Scenario-to-row mappings: 3
ℹ️  Concrete test file references: 3
ℹ️  Report evidence references: 3
ℹ️  DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=0 inferred=1 ambiguous=5
RESULT: PASSED (0 warnings)
TRACEABILITY_EXIT=0
PACKET_GOVERNANCE_FAILURES=0
BUG020_PACKET_GOVERNANCE_END
```

The additional read-only parity comparator parsed `test-plan.json`, extracted
the Markdown Test Plan rows and row-specific test DoD items, and compared exact
order plus type, scenario IDs, category, file, title, command, and live-system
metadata.

**Command:**

```bash
repo_root="$(git -C "$HOME/Projects/bubbles" rev-parse --show-toplevel)"; feature_dir="$repo_root/improvements/BUG-020-state-transition-bash32-startup"; if [[ "$repo_root" != "$HOME/Projects/bubbles" ]]; then printf 'BUG020_COMPACT_PARITY_ROOT_MISMATCH=%s\n' "$repo_root"; exit 97; fi; node -e 'const f=require("fs"),[jp,sp]=process.argv.slice(1),o=JSON.parse(f.readFileSync(jp,"utf8")),j=o.scopes.flatMap(s=>s.tests||[]),l=f.readFileSync(sp,"utf8").split(/\r?\n/),u=v=>v.startsWith("`")&&v.endsWith("`")?v.slice(1,-1):v,s=v=>v.match(/SCN-BUG-020-\d+/g)||[],m=[],d=[],e=[],x=(a,b)=>JSON.stringify(a)===JSON.stringify(b);let p=false;for(const z of l){if(z==="### Test Plan"){p=true;continue}if(p&&/^### /.test(z))break;if(p&&/^\|/.test(z)&&!/^(\|\s*Test Type\s*\||\|\s*---)/.test(z)){const c=z.split("|").slice(1,-1).map(v=>v.trim());if(/T-BUG-020-\d+/.test(c[1]||""))m.push(c)}}for(const z of l){const q=z.match(/^- \[[ x]\] `(?<id>T-BUG-020-\d+) - (?<description>.*)`\. Evidence destination:/);if(q)d.push(q.groups)}const ids=j.map(v=>v.testId),mi=m.map(v=>u(v[1])),di=d.map(v=>v.id),want=Array.from({length:27},(_,i)=>`T-BUG-020-${String(i).padStart(2,"0")}`),req=["testId","type","category","file","scenarioId","scenarioIds","description","command","liveSystem"];j.forEach((v,i)=>{req.forEach(k=>{if(v[k]===undefined||v[k]===null||v[k]===""||(Array.isArray(v[k])&&!v[k].length))e.push(`${v.testId||i}.${k}=missing`)});const r=m[i],q=d[i];if(!r)return;e.push(...[[u(r[0]),v.type,"type"],[u(r[1]),v.testId,"testId"],[s(r[2]),v.scenarioIds,"scenarioIds"],[u(r[3]),v.category,"category"],[u(r[4]),v.file,"file"],[u(r[5]),v.description,"description"],[u(r[6]),v.command,"command"],[u(r[7]),String(v.liveSystem),"liveSystem"]].filter(a=>!x(a[0],a[1])).map(a=>`${v.testId}.${a[2]}`));if(q&&(q.id!==v.testId||q.description!==v.description))e.push(`${v.testId}.dod`)});[[o.scopes.length,1,"scopeCount"],[j.length,27,"jsonCount"],[m.length,27,"markdownCount"],[d.length,27,"dodCount"],[new Set(ids).size,27,"jsonUnique"],[new Set(mi).size,27,"markdownUnique"],[new Set(di).size,27,"dodUnique"]].forEach(a=>{if(a[0]!==a[1])e.push(`${a[2]}=${a[0]}`)});if(!x(ids,want))e.push("expectedIdSequence");if(!x(ids,mi))e.push("jsonMarkdownOrder");if(!x(ids,di))e.push("jsonDodOrder");console.log("BUG020_TEST_PLAN_PARITY_BEGIN",`\nJSON_PARSE=PASS\nJSON_SCOPE_COUNT=${o.scopes.length}\nJSON_TEST_COUNT=${j.length}\nJSON_TEST_UNIQUE_COUNT=${new Set(ids).size}\nMARKDOWN_TEST_COUNT=${m.length}\nMARKDOWN_TEST_UNIQUE_COUNT=${new Set(mi).size}\nDOD_TEST_COUNT=${d.length}\nDOD_TEST_UNIQUE_COUNT=${new Set(di).size}\nEXPECTED_ID_SEQUENCE=${x(ids,want)?"PASS":"FAIL"}\nJSON_MARKDOWN_ORDER=${x(ids,mi)?"PASS":"FAIL"}\nJSON_DOD_ORDER=${x(ids,di)?"PASS":"FAIL"}\nREQUIRED_JSON_FIELDS=${e.some(v=>v.endsWith("=missing"))?"FAIL":"PASS"}\nJSON_MARKDOWN_METADATA_CHECKS=${j.length*8}\nJSON_DOD_DESCRIPTION_CHECKS=${j.length*2}`);e.forEach(v=>console.log(`PARITY_MISMATCH=${v}`));console.log(`PARITY_MISMATCH_COUNT=${e.length}\nBUG020_TEST_PLAN_PARITY=${e.length?"FAIL":"PASS"}\nBUG020_TEST_PLAN_PARITY_END`);process.exit(e.length?1:0)' "$feature_dir/test-plan.json" "$feature_dir/scopes.md"
```

**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG020_TEST_PLAN_PARITY_BEGIN
JSON_PARSE=PASS
JSON_SCOPE_COUNT=1
JSON_TEST_COUNT=27
JSON_TEST_UNIQUE_COUNT=27
MARKDOWN_TEST_COUNT=27
MARKDOWN_TEST_UNIQUE_COUNT=27
DOD_TEST_COUNT=27
DOD_TEST_UNIQUE_COUNT=27
EXPECTED_ID_SEQUENCE=PASS
JSON_MARKDOWN_ORDER=PASS
JSON_DOD_ORDER=PASS
REQUIRED_JSON_FIELDS=PASS
JSON_MARKDOWN_METADATA_CHECKS=216
JSON_DOD_DESCRIPTION_CHECKS=54
PARITY_MISMATCH_COUNT=0
BUG020_TEST_PLAN_PARITY=PASS
BUG020_TEST_PLAN_PARITY_END
```

##### Protected Identity Recheck And Finding Ledger

**Phase:** test
**Command:** compare opening and pre-write inode, size, mtime, and SHA-256 for
BUG-020 `state.json`, `scopes.md`, `test-plan.json`, `report.md`, physical
`test_27`, `fun-mode.sh`, `state-transition-guard.sh`, and BUG-022 `state.json`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG020_PRE_WRITE_CONCURRENCY_RECHECK_BEGIN
IDENTITY target=improvements/BUG-020-state-transition-bash32-startup/state.json stat=146865810 9153 1784253702 sha256=b2ceb2320669a0405447faadcec1887672c3ee4b1aac0b68c8a4d3cda1124563
IDENTITY target=improvements/BUG-020-state-transition-bash32-startup/scopes.md stat=146865791 39987 1784253702 sha256=247fe7f49262af8080b53d1e3da13553717a9392a87f0b37ed2c81cdf0ddbdff
IDENTITY target=improvements/BUG-020-state-transition-bash32-startup/test-plan.json stat=146865809 19531 1784253702 sha256=a061887fa6b76558e87ec3fe6eada8ebd55e4981f561b8c1c161ba2da788e8fc
IDENTITY target=improvements/BUG-020-state-transition-bash32-startup/report.md stat=146865798 40701 1784253702 sha256=8c2764f0181ac9f152106e51d0e22ed7408dfe6c332897a5d30828d0a80edbe2
IDENTITY target=tests/regression/test_27_state_transition_bash32_startup.sh stat=147537502 40757 1784261567 sha256=5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d
IDENTITY target=bubbles/scripts/fun-mode.sh stat=125135876 6992 1784177553 sha256=edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e
IDENTITY target=bubbles/scripts/state-transition-guard.sh stat=130310172 154362 1784167635 sha256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
IDENTITY target=improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json stat=147768156 8639 1784254654 sha256=c04eae6dd49fcd774d641f80bf924539755ee7cac45f6780559c50665ad049ff
IDENTITY_MISMATCH_COUNT=0
BUG020_PRE_WRITE_CONCURRENCY_RECHECK_END
```

| Finding | Disposition | Evidence / owner |
| --- | --- | --- |
| `BUG020-PROSPECTIVE-RED-001` | Addressed | Frozen `test_27` SHA `5e82a2fb...b4a6c9d`; `VALID_PRE_FIX_RED`; 10 guard runs, 4 API runs, 224 assertions, 59 expected RED failures, zero control/harness/unrelated failures, isolated cleanup true. |
| `BUG020-DEPENDENCY-022` | Unresolved and foreign | Owner: BUG-022 packet owner; path: `improvements/BUG-022-state-transition-bash32-empty-array-nounset`; state SHA `c04eae6d...ad049ff`; no BUG-020 edit or completion credit. |

The test-owned route is `bubbles.implement` for candidate application after
this valid RED. The implementation owner must preserve the exact regression
SHA above and BUG-022 ownership. No candidate patch was applied in this round,
and every delivery DoD item, Scope 1 status, `completedPhaseClaims`, and
`certification.*` field remains unchanged.

### Parser-Free Fun API Proof

Owner: `bubbles.test`. Record separate stock Bash 3.2 disabled/enabled API
results and newer-Bash controls for all seven public functions, every named
event, unknown-event silence, all random pools, banner, prefix, summaries,
return values, and the `declare -A`/`local -n`/`declare -n` adversary.

### System-Only Resolver Refusal Proof

Owner: `bubbles.test`. Record the strict system-only Bash 3.2 real-guard case
with fun mode disabled, exact `E009-REGISTRY-MISSING`, nonzero exit, zero Check
8 markers, no optional-module startup error, and explicit separation from the
BUG-022-owned structured-result/empty-array contract.

### Parser-Aware Guard Outcomes

Owner: `bubbles.test`. Record fail-loud real `jq`/`yq` resolution, system-first
PATH identity, exact Bash interpreters, disabled/enabled pass and genuine-
finding fixtures, one Check 8 marker and one structured result per fixture,
expected exits, failed-check identity, fun output, and zero presentation-driven
governance changes.

### Implementation-Owned Verification Round - 2026-07-17

**Phase:** implement
**Captured At:** `2026-07-17T04:34:09Z`
**Claim Source:** interpreted
**Outcome:** `route_required`

The frozen prospective RED handoff was intact before execution. The current
candidate needed no source edit: the exact frozen regression exercised all
four direct-API cases and all ten real-guard cases with zero fun-mode startup
aborts and zero forbidden root-cause constructs. The aggregate remained
nonzero because three Bash 3.2 parser-aware runs reached the independently
owned BUG-022 `failed_check_ids[@]` nounset path, producing zero Bash 3.2
structured-result markers and 30 dependent assertion failures.

#### Frozen Candidate Execution

**Command:** `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh`
**Exit Code:** 1
**Claim Source:** interpreted
**Interpretation:** The output directly proves execution of every split lane
and preservation of the frozen bytes. Zero BUG-020 startup aborts plus zero
root-cause constructs support the candidate implementation; the three explicit
`BASH32_BUG022_OBSERVATIONS` and zero Bash 3.2 result markers keep the aggregate
failure foreign-owned and prohibit a BUG-020 GREEN or completion claim.
**Output:** terminal summary window from the full 42 KB output

```text
=== BUG-020 regression summary ===
GUARD_RUNS=10
SYSTEM_GUARD_RUNS=2
PARSER_GUARD_RUNS=8
API_RUNS=4
ASSERTIONS=224
PASSED=194
FAILED=30
BASH32_API_STARTUP_ABORTS=0
BASH32_GUARD_STARTUP_ABORTS=0
BASH32_SYSTEM_GUARD_STARTUP_ABORTS=0
BASH32_PARSER_GUARD_STARTUP_ABORTS=0
BASH32_RESOLVER_REFUSALS=1
BASH32_BUG022_OBSERVATIONS=3
BASH32_FOREIGN_PRE_CHECK8_ABORTS=0
BASH32_OTHER_PRE_CHECK8_ABORTS=0
BASH32_PARSER_LANES_RESERVED=0
BASH32_PARSER_CHECK8_MARKERS=4
BASH32_PARSER_RESULT_MARKERS=0
STRICT_SYSTEM_CONTROL_RUNS=1
STRICT_SYSTEM_CONTROL_STATUS=2
STRICT_SYSTEM_CONTROL_E009_REFUSALS=1
STRICT_SYSTEM_CONTROL_CHECK8_MARKERS=0
NEWER_PARSER_CONTROL_RUNS=4
ROOT_CAUSE_CONSTRUCTS=0
DECLARE_A_CONSTRUCTS=0
LOCAL_N_CONSTRUCTS=0
DECLARE_N_CONSTRUCTS=0
ASSOCIATIVE_GATE_PASSED_ENTRIES=0
EXPECTED_RED_ASSERTION_FAILURES=0
UNRELATED_ASSERTION_FAILURES=30
CONTROL_FAILURES=30
HARNESS_FAILURES=0
FINAL_SOURCE_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
FINAL_SOURCE_FUN_MODE_SHA256=edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e
FINAL_TEST_FILE_SHA256=5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d
PARSER_AWARE_BASH32_PROOF_STATUS=RESERVED_FOR_POST_PATCH_AND_BUG022
GREEN_MUST_USE_TEST_SHA256=5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d
BUG020_RED_DISPOSITION=RED_INVALID_FOREIGN_DEPENDENCY_BLOCKED
BUG-020 state-transition Bash 3.2 startup regression FAILED
```

#### Bash Syntax, Root-Cause, And Identity Proof

**Command:** `printf '%s\n' 'BUG020_IMPLEMENT_SYNTAX_IDENTITY_BEGIN' && printf 'GIT_ROOT=%s\n' "$(git rev-parse --show-toplevel)" && /bin/bash -c 'printf "BASH32_VERSION=%s\n" "$BASH_VERSION"' && newer_bash="$(command -v bash)" && "$newer_bash" -c 'printf "NEWER_BASH_VERSION=%s\n" "$BASH_VERSION"' && syntax_exit=0 && /bin/bash -n bubbles/scripts/fun-mode.sh tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh || syntax_exit=$? && printf 'BASH32_SYNTAX_EXIT=%s\n' "$syntax_exit" && printf 'DECLARE_A_CONSTRUCTS=%s\n' "$(grep -Ec '(^|[[:space:]])declare[[:space:]]+-A([[:space:]]|$)' bubbles/scripts/fun-mode.sh || true)" && printf 'LOCAL_N_CONSTRUCTS=%s\n' "$(grep -Ec '(^|[[:space:]])local[[:space:]]+-n([[:space:]]|$)' bubbles/scripts/fun-mode.sh || true)" && printf 'DECLARE_N_CONSTRUCTS=%s\n' "$(grep -Ec '(^|[[:space:]])declare[[:space:]]+-n([[:space:]]|$)' bubbles/scripts/fun-mode.sh || true)" && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard.sh improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json && printf '%s\n' 'BUG020_IMPLEMENT_SYNTAX_IDENTITY_END' && exit "$syntax_exit"`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
BUG020_IMPLEMENT_SYNTAX_IDENTITY_BEGIN
GIT_ROOT=/Users/pkirsanov/Projects/bubbles
BASH32_VERSION=3.2.57(1)-release
NEWER_BASH_VERSION=5.3.15(1)-release
BASH32_SYNTAX_EXIT=0
DECLARE_A_CONSTRUCTS=0
LOCAL_N_CONSTRUCTS=0
DECLARE_N_CONSTRUCTS=0
5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d  tests/regression/test_27_state_transition_bash32_startup.sh
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a  bubbles/scripts/state-transition-guard.sh
c04eae6dd49fcd774d641f80bf924539755ee7cac45f6780559c50665ad049ff  improvements/BUG-022-state-transition-bash32-empty-array-nounset/state.json
BUG020_IMPLEMENT_SYNTAX_IDENTITY_END
```

#### Focused Quality And Portability

**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_27_state_transition_bash32_startup.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-17T04:30:52Z
  Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_27_state_transition_bash32_startup.sh
✅ Adversarial signal detected in tests/regression/test_27_state_transition_bash32_startup.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

**Command:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_27_state_transition_bash32_startup.sh`
**Exit Code:** 0
**Claim Source:** executed
**Output:**

```text
== macOS portability guard -- scanning 3 file(s) ==
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

#### Packet Governance And Test-Plan Parity

**Commands:**

- `bash bubbles/scripts/artifact-lint.sh improvements/BUG-020-state-transition-bash32-startup` (exit 0; one nonblocking deprecated-`scopeProgress` warning)
- `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-020-state-transition-bash32-startup` (exit 0)
- `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-020-state-transition-bash32-startup` (exit 0)
- `bash bubbles/scripts/traceability-guard.sh improvements/BUG-020-state-transition-bash32-startup` (exit 0)
- read-only Node comparator for `test-plan.json` against the Markdown Test Plan and row-specific DoD entries (exit 0)

**Claim Source:** executed
**Output:** selected raw result windows

```text
Artifact lint PASSED.
--- Check 4: Result ---
RESULT: PASS (0 failures, 0 warnings)
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
--- Traceability Summary ---
ℹ️  Scenarios checked: 3
ℹ️  Test rows checked: 27
ℹ️  Scenario-to-row mappings: 3
ℹ️  Concrete test file references: 3
ℹ️  Report evidence references: 3
ℹ️  DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: PASSED (0 warnings)
BUG020_TEST_PLAN_PARITY_BEGIN
JSON_PARSE=PASS
JSON_SCOPE_COUNT=1
JSON_TEST_COUNT=27
JSON_TEST_UNIQUE_COUNT=27
MARKDOWN_TEST_COUNT=27
MARKDOWN_TEST_UNIQUE_COUNT=27
DOD_TEST_COUNT=27
DOD_TEST_UNIQUE_COUNT=27
EXPECTED_ID_SEQUENCE=PASS
JSON_MARKDOWN_ORDER=PASS
JSON_DOD_ORDER=PASS
REQUIRED_JSON_FIELDS=PASS
JSON_MARKDOWN_METADATA_CHECKS=216
JSON_DOD_DESCRIPTION_CHECKS=54
PARITY_MISMATCH_COUNT=0
BUG020_TEST_PLAN_PARITY=PASS
BUG020_TEST_PLAN_PARITY_END
```

#### Finding And Ownership Accounting

| Finding | Disposition | Owner / evidence |
| --- | --- | --- |
| `BUG020-PROSPECTIVE-RED-001` | Addressed and preserved | `bubbles.test`; frozen test SHA-256 `5e82a2fb6f140a4529c0ff4d4ad2bc6d949dff34f61c7758931347f51b4a6c9d`; valid prospective RED remains in the preceding test-owned section. |
| `BUG020-DEPENDENCY-022` | Unresolved and foreign | BUG-022, currently routed to `bubbles.design`; path `improvements/BUG-022-state-transition-bash32-empty-array-nounset`; state SHA-256 `c04eae6dd49fcd774d641f80bf924539755ee7cac45f6780559c50665ad049ff`. |

Production source changes by this implementation round: none. The candidate
`fun-mode.sh` SHA-256 remains
`edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e`;
the guard SHA-256 remains
`09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a`.
The regression's nonzero foreign-dependency disposition means the source-only
registration prerequisite was not satisfied. `framework-validate`, install
provenance, release checks, certification, DoD, scope status,
`completedPhaseClaims`, and `certification.*` were not executed or changed by
this round. Independent implementation verification is routed to
`bubbles.test`; BUG-022 ownership and path remain unchanged.

## Intake Record

### Summary

BUG-019 independent test exposed a foreign production-entrypoint failure. The
finding was deduplicated against every current `improvements/` BUG packet and
the absent `specs/` surface, reproduced once on the current tree, and traced to
the unconditional Bash-4-only `fun-mode.sh` source path. No fix was attempted.

### Completion Statement

NONTERMINAL INTAKE. The bug is confirmed and routed, not fixed, tested after a
fix, released, upgraded downstream, or certified. Every delivery DoD remains
unchecked and `state.json` remains blocked.

### Test Evidence

The before-fix diagnostic reproduction and packet-only artifact lint ran in
this intake. No source unit/integration test, E2E GREEN, framework validation,
release validation, downstream upgrade, or certification command ran for
BUG-020.

## Bug Reproduction - Before Fix

**Phase:** discovery
**Command:** `printf '%s\n' 'BUG020_CURRENT_REPRO_BEGIN'; set +e; /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh; reproduction_exit=$?; set -e; printf 'BUG020_CURRENT_REPRO_EXIT=%s\n' "$reproduction_exit"; printf '%s\n' 'BUG020_CURRENT_REPRO_END'; exit "$reproduction_exit"`
**Exit Code:** 1
**Claim Source:** executed

The following is the relevant opening window of the full current-session
output. The real home prefix is normalized to `~/Projects/bubbles` for PII
hygiene; no behavioral text is changed.

```text
BUG020_CURRENT_REPRO_BEGIN
=== BUG-019 harness control: real guard reaches Check 8 cleanly ===
--- BUG-019 baseline production output ---
~/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 baseline exit=1 ---
FAIL: baseline packet exits zero (expected exit 0, got 1)
FAIL: baseline reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
FAIL: baseline exercises the existing-file branch (missing: Test file exists: tests/example.sh)
FAIL: baseline reaches structured result start (missing: BEGIN TRANSITION_GUARD_RESULT_V1)
FAIL: baseline has no unrelated failed check (missing: failedChecks: [])
FAIL: baseline reaches the normal passing verdict (missing: verdict: PASS)
=== T-BUG-019-01 Regression: compound MJS paths remain complete through production Check 8 ===
=== T-BUG-019-02 Regression: ordinary suffix, backtick, and command-wrapper controls remain compatible ===
--- BUG-019 compound and compatibility matrix production output ---
~/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 compound and compatibility matrix exit=1 ---
FAIL: compound matrix reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
FAIL: compound matrix reaches a normal structured result (missing: END TRANSITION_GUARD_RESULT_V1)
FAIL: compound and compatibility matrix exits zero (expected exit 0, got 1)
FAIL: reporter compound path reaches the complete existing-file branch (missing: Test file exists: tests/palm-springs-rental-market-lab.spec.mjs)
```

The complete run executed all four fixtures and 38 assertions, ended with
`PASSED=11`, `FAILED=27`, `BUG020_CURRENT_REPRO_EXIT=1`, and
`BUG020_CURRENT_REPRO_END`. The first and repeated failure is before Check 8,
so this output is not evidence against BUG-019's repaired path extraction.

## Packet Structure Validation

**Phase:** documentation
**Command:** `packet_exit=0; for packet in improvements/BUG-020-state-transition-bash32-startup improvements/BUG-021-framework-validate-raw-timeout; do printf 'PACKET_LINT_BEGIN=%s\n' "$packet"; bash bubbles/scripts/artifact-lint.sh "$packet"; lint_exit=$?; printf 'PACKET_LINT_EXIT=%s path=%s\n' "$lint_exit" "$packet"; printf 'PACKET_LINT_END=%s\n' "$packet"; if [[ "$lint_exit" -ne 0 ]]; then packet_exit=1; fi; done; exit "$packet_exit"`
**Exit Code:** 0
**Claim Source:** executed

```text
PACKET_LINT_BEGIN=improvements/BUG-020-state-transition-bash32-startup
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
PACKET_LINT_EXIT=0 path=improvements/BUG-020-state-transition-bash32-startup
PACKET_LINT_END=improvements/BUG-020-state-transition-bash32-startup
```

The command also emitted one nonblocking notice that `scopeProgress` is
deprecated; that field remains because the active bug-agent contract explicitly
requires it in a version-3 intake state.

## Root-Cause Evidence

**Claim Source:** interpreted
**Interpretation:** Source inspection connects the executed startup error to an
unconditional load-order and shell-capability mismatch:

- `state-transition-guard.sh` enables nounset and sources `fun-mode.sh` before
  `guard-lib.sh` and before its check state is initialized.
- `fun-mode.sh` eagerly initializes `_FUN_MESSAGES` with `declare -A` at the
  reported line and also defines a `local -n` helper.
- macOS system Bash 3.2 supports neither associative arrays nor namerefs.
- the failure occurs with fun mode disabled, proving the public no-op functions
  are reached too late to protect startup.

This is root-cause analysis, not post-fix execution proof.

## Deduplication Result

**Claim Source:** interpreted

| Candidate | Result | Reason |
| --- | --- | --- |
| BUG-019 | Reporter only | Its state and report classify `TEST-019-003` as foreign and exclude this startup repair from its Check 8 boundary. |
| BUG-018 | Related, not duplicate | Its repair supplies local no-op hooks in `traceability-guard.sh`; its design explicitly keeps `fun-mode.sh` unchanged. |
| BUG-012 / BUG-013 | Not owners | Their scopes concern G085 adoption and G028 storage scanning, not state-transition startup. |
| Current `specs/` | No candidate | The canonical Bubbles checkout has no `specs/` directory. |
| `BUGS.md` | No candidate | No matching active `fun-mode.sh`, `gate_passed`, or Bash-3.2 startup record exists. |

Verdict: no active canonical bug packet owned the finding; BUG-020 is the
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
- Unresolved finding `BUG020-F001`: mandatory state-transition startup aborts
  before Check 8 under macOS Bash 3.2.
- Dependency impact: BUG-019 `T-BUG-019-08`, canonical framework validation,
  release reconciliation, and supported downstream upgrade remain blocked.

## Invocation Audit

No subagent was invoked because no `runSubagent` capability was available and
the operator requested packet-only diagnosis. No specialist execution is
claimed.

## Planned Delivery Evidence Destinations

These headings define the exact report anchors referenced by the reconciled
Test Plan. `bubbles.plan` records no delivery execution evidence in them.

### Final-Byte RED Regression

**Phase:** test
**Command:** `red_fixture="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug020-ba8-red-XXXXXXXX")" && cleanup_red_fixture() { rm -rf "$red_fixture"; } && trap cleanup_red_fixture EXIT INT TERM && mkdir -p "$red_fixture/tests/regression" && cp -R bubbles agents "$red_fixture/" && cp tests/regression/test_27_state_transition_bash32_startup.sh "$red_fixture/tests/regression/" && git archive --format=tar --output="$red_fixture/prior-fun-mode.tar" HEAD bubbles/scripts/fun-mode.sh && tar -xf "$red_fixture/prior-fun-mode.tar" -C "$red_fixture" && rm -f "$red_fixture/prior-fun-mode.tar" && printf '%s\n' 'BUG020_BA8_FINAL_RED_BEGIN' && printf 'HEAD_FUN_MODE_BLOB=%s\n' "$(git rev-parse HEAD:bubbles/scripts/fun-mode.sh)" && printf 'RED_FUN_MODE_BLOB=%s\n' "$(git hash-object "$red_fixture/bubbles/scripts/fun-mode.sh")" && printf 'PRE_RED_TEST_SHA256=' && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && printf 'FIXTURE_RED_TEST_SHA256=' && shasum -a 256 "$red_fixture/tests/regression/test_27_state_transition_bash32_startup.sh" && (cd "$red_fixture" && bash tests/regression/test_27_state_transition_bash32_startup.sh); red_exit=$?; printf 'BUG020_BA8_FINAL_RED_EXIT=%s\n' "$red_exit"; printf 'POST_RED_TEST_SHA256=' && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh; cleanup_red_fixture; trap - EXIT INT TERM; if [[ ! -e "$red_fixture" ]]; then printf '%s\n' 'BUG020_BA8_FINAL_RED_FIXTURE_REMOVED=true'; else printf '%s\n' 'BUG020_BA8_FINAL_RED_FIXTURE_REMOVED=false'; fi; printf '%s\n' 'BUG020_BA8_FINAL_RED_END'; exit "$red_exit"`
**Exit Code:** 1
**Claim Source:** executed
**Result:** PASS - expected pre-fix RED

The home prefix in the temporary path is omitted below; all behavioral and
identity bytes are unchanged. The complete command output contains 45 KB. This
is the terminal summary window plus the outer identity checks:

```text
BUG020_BA8_FINAL_RED_BEGIN
HEAD_FUN_MODE_BLOB=7da650141188f120f5ac25d4f77fada91bc96e88
RED_FUN_MODE_BLOB=7da650141188f120f5ac25d4f77fada91bc96e88
PRE_RED_TEST_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  tests/regression/test_27_state_transition_bash32_startup.sh
FIXTURE_RED_TEST_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  <tmp>/tests/regression/test_27_state_transition_bash32_startup.sh
GUARD_RUNS=8
API_RUNS=4
ASSERTIONS=201
PASSED=145
FAILED=56
BASH32_INTENDED_ABORTS=4
BASH32_PARSER_ABORTS=0
BASH32_OTHER_PRE_CHECK8_ABORTS=0
FINAL_SOURCE_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
FINAL_SOURCE_FUN_MODE_SHA256=00bc5aa96744aaa0a3ac784b2577728a9318fe9f95f4b3b91f422eb8c078b386
FINAL_TEST_FILE_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07
BUG020_RED_DISPOSITION=VALID_PRE_FIX_RED
BUG-020 state-transition Bash 3.2 startup regression FAILED
BUG020_BA8_FINAL_RED_EXIT=1
POST_RED_TEST_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  tests/regression/test_27_state_transition_bash32_startup.sh
BUG020_BA8_FINAL_RED_FIXTURE_REMOVED=true
BUG020_BA8_FINAL_RED_END
```

The prior source SHA-256 is
`00bc5aa96744aaa0a3ac784b2577728a9318fe9f95f4b3b91f422eb8c078b386`.
The output records all four Bash-3.2 guard cases aborting on the intended
`gate_passed: unbound variable` discriminator before Check 8. All four
newer-Bash guard controls and both newer-Bash direct-API controls ran, so the
RED is not a fixture-setup or universal-test failure.

### Bash 3.2 And Newer Bash Regression Matrix

**Phase:** test
**Command:** `printf '%s\n' 'BUG020_BA8_CURRENT_RUN_BEGIN' && printf 'PRE_CURRENT_TEST_SHA256=' && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && printf 'CURRENT_FUN_MODE_SHA256=' && shasum -a 256 bubbles/scripts/fun-mode.sh && printf 'CURRENT_GUARD_SHA256=' && shasum -a 256 bubbles/scripts/state-transition-guard.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh; current_exit=$?; printf 'BUG020_BA8_CURRENT_RUN_EXIT=%s\n' "$current_exit"; printf 'POST_CURRENT_TEST_SHA256=' && shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh; printf '%s\n' 'BUG020_BA8_CURRENT_RUN_END'; exit "$current_exit"`
**Exit Code:** 1
**Claim Source:** executed
**Result:** FAIL - current-source Bash-3.2 production cases blocked before Check 8

```text
PRE_CURRENT_TEST_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  tests/regression/test_27_state_transition_bash32_startup.sh
CURRENT_FUN_MODE_SHA256=edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
CURRENT_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a  bubbles/scripts/state-transition-guard.sh
GUARD_RUNS=8
API_RUNS=4
ASSERTIONS=201
PASSED=161
FAILED=40
BASH32_INTENDED_ABORTS=0
BASH32_PARSER_ABORTS=4
BASH32_OTHER_PRE_CHECK8_ABORTS=0
FINAL_SOURCE_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
FINAL_SOURCE_FUN_MODE_SHA256=edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e
FINAL_TEST_FILE_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07
BUG020_RED_DISPOSITION=RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED
BUG-020 state-transition Bash 3.2 startup regression FAILED
BUG020_BA8_CURRENT_RUN_EXIT=1
POST_CURRENT_TEST_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  tests/regression/test_27_state_transition_bash32_startup.sh
BUG020_BA8_CURRENT_RUN_END
```

**Phase:** test
**Command:** `blocker_failures=0 && for fun_mode in false true; do printf 'CASE fun=%s shell=' "$fun_mode"; /bin/bash -c 'printf "%s\n" "$BASH_VERSION"'; /usr/bin/env -i HOME="$HOME" PATH='/usr/bin:/bin:/usr/sbin:/sbin' BUBBLES_FUN_MODE="$fun_mode" /bin/bash bubbles/scripts/state-transition-guard.sh improvements/BUG-020-state-transition-bash32-startup; guard_exit=$?; printf 'CASE_RESULT fun=%s exit=%s\n' "$fun_mode" "$guard_exit"; if [[ "$guard_exit" -ne 2 ]]; then blocker_failures=$((blocker_failures + 1)); fi; done && printf 'BLOCKER_ASSERTION_FAILURES=%s\n' "$blocker_failures"; exit "$blocker_failures"`
**Exit Code:** 2
**Claim Source:** executed
**Result:** FAIL - both public guard invocations stopped before Check 8

```text
BUG020_PARSER_BLOCKER_DIRECT_BEGIN
CASE fun=false shell=3.2.57(1)-release
E009-REGISTRY-MISSING: required registry parser is unavailable
bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
CASE_RESULT fun=false exit=1
CASE fun=true shell=3.2.57(1)-release
E009-REGISTRY-MISSING: required registry parser is unavailable
bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
CASE_RESULT fun=true exit=1
BLOCKER_ASSERTION_FAILURES=2
BUG020_PARSER_BLOCKER_DIRECT_END
```

The four newer-Bash pass/finding cases completed with their expected exits and
structured results. The four actual macOS Bash 3.2 production cases did not
reach Check 8 in `bubbles/scripts/state-transition-guard.sh`: system-only PATH
does not expose the registry parser required by the transition-contract
resolver. A direct false/true invocation additionally emitted
`E009-REGISTRY-MISSING: required registry parser is unavailable`, followed by
`failed_check_ids[@]: unbound variable` at guard line 82 and exit `1`.

This is an honest blocker, not GREEN evidence. The exact planned matrix cannot
pass simultaneously with both the mandatory system-only PATH and the
prohibition on a test-only PATH shim. Per the design's falsification rule, the
one-source repair is insufficient and must return to `bubbles.design`.

### Direct Fun API And Root-Cause Guard

**Phase:** test
**Command:** same current-source regression command recorded in [Bash 3.2 And Newer Bash Regression Matrix](#bash-32-and-newer-bash-regression-matrix)
**Exit Code:** 1 overall; all four direct API subprocesses exited 0
**Claim Source:** executed
**Result:** PASS for `T-BUG-020-09` through `T-BUG-020-13`; overall matrix remains blocked

```text
API_CASE_RESULT shell=bash-3.2 fun=false exit=0
API_ASSERTIONS=48
API_FAILURES=0
API_PROBE_RESULT=PASS mode=false
API_CASE_RESULT shell=bash-3.2 fun=true exit=0
API_ASSERTIONS=48
API_FAILURES=0
API_PROBE_RESULT=PASS mode=true
API_CASE_RESULT shell=bash-newer fun=false exit=0
API_ASSERTIONS=48
API_FAILURES=0
API_PROBE_RESULT=PASS mode=false
API_CASE_RESULT shell=bash-newer fun=true exit=0
API_ASSERTIONS=48
API_FAILURES=0
API_PROBE_RESULT=PASS mode=true
PASS: canonical fun-mode source rejects declare -A
PASS: canonical fun-mode source rejects local -n
PASS: canonical fun-mode source rejects declare -n
```

Disabled mode remained silent. Enabled mode exercised every named event,
unknown-event silence, all three random pools, banner, and all summary branches
under Bash 3.2.57 and Bash 5.3.15.

### Managed Guard And Regression Quality

`T-BUG-020-14` was not run because the focused production regression is blocked
before Check 8. It remains unchecked.

**Phase:** test
**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_27_state_transition_bash32_startup.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: ~/Projects/bubbles
  Timestamp: 2026-07-16T05:47:17Z
  Bugfix mode: true
============================================================
ℹ️  Scanning tests/regression/test_27_state_transition_bash32_startup.sh
✅ Adversarial signal detected in tests/regression/test_27_state_transition_bash32_startup.sh
============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

### Portability And Change Boundary

**Phase:** test
**Command:** `/bin/bash -n bubbles/scripts/fun-mode.sh tests/regression/test_27_state_transition_bash32_startup.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed

**Phase:** test
**Command:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/fun-mode.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_27_state_transition_bash32_startup.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
== macOS portability guard -- scanning 3 file(s) ==
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
BUG020_PORTABILITY_SCAN_EXIT=0
```

Every regression run verified the production guard, fun-mode source, and test
file stayed byte-identical during that run and removed its temporary workspace.
No reset, checkout, commit, push, BUG-019/BUG-021 edit, production-source edit,
or downstream mutation was performed by `bubbles.test`.

### Packet Governance

**Phase:** test
**Commands:** `bash bubbles/scripts/artifact-lint.sh improvements/BUG-020-state-transition-bash32-startup`; `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-020-state-transition-bash32-startup`; `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-020-state-transition-bash32-startup`; `bash bubbles/scripts/traceability-guard.sh improvements/BUG-020-state-transition-bash32-startup`
**Exit Codes:** 0; 0; 1; 1
**Claim Source:** executed

```text
Artifact lint PASSED.
BUG020_ARTIFACT_LINT_EXIT=0
--- Check 4: Result ---
RESULT: PASS (0 failures, 0 warnings)
BUG020_ARTIFACT_FRESHNESS_EXIT=0
capability-foundation-guard: Gate G094 applies: triggerHits=3 concreteImplementationEntries=0
G094 capability_foundation_gate violation: spec.md must contain ## Domain Capability Model or ### Single-Capability Justification when proportionality applies
capability-foundation-guard: design.md contains non-empty Single-Implementation Justification
G094 capability_foundation_gate: FAILED with 1 finding(s)
BUG020_CAPABILITY_GUARD_EXIT=1
✅ All linked tests from scenario-manifest.json exist
ℹ️  Scenarios checked: 3
ℹ️  Test rows checked: 27
ℹ️  DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: FAILED (1 failures, 0 warnings)
BUG020_TRACEABILITY_EXIT=1
```

The G094 finding is spec-owned and routes to `bubbles.analyst`. Traceability's
single finding was the missing report reference to the concrete production
guard; this section now names `bubbles/scripts/state-transition-guard.sh` and
was rechecked after this evidence write.

**Phase:** test
**Command:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-020-state-transition-bash32-startup`
**Exit Code:** 0
**Claim Source:** executed

```text
✅ All linked tests from scenario-manifest.json exist
✅ Scope 1: Portable State-Transition Startup report references concrete test evidence: tests/regression/test_27_state_transition_bash32_startup.sh
✅ Scope 1: Portable State-Transition Startup report references concrete test evidence: bubbles/scripts/state-transition-guard.sh
✅ Scope 1: Portable State-Transition Startup report references concrete test evidence: tests/regression/test_27_state_transition_bash32_startup.sh
ℹ️  Scenarios checked: 3
ℹ️  Test rows checked: 27
ℹ️  Scenario-to-row mappings: 3
ℹ️  Concrete test file references: 3
ℹ️  Report evidence references: 3
ℹ️  DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
ℹ️  Edge confidence (IMP-015 Scope B): declared=0 inferred=3 ambiguous=3
RESULT: PASSED (0 warnings)
BUG020_TRACEABILITY_RECHECK_EXIT=0
```

### Framework Validation

Evidence destination for `T-BUG-020-23`, owned by `bubbles.test` after focused
and packet checks.

### Release And Install Provenance

Evidence destination for `T-BUG-020-24` and `T-BUG-020-25`, owned by
`bubbles.releases` after source and test bytes settle.

### Certification Validation

Evidence destination for `T-BUG-020-26`, owned by `bubbles.validate` after all
prior findings and evidence obligations close.

## Test-Phase Authority Correction

**Phase:** test
**Command:** `shasum -a 256 tests/regression/test_27_state_transition_bash32_startup.sh && bash tests/regression/test_27_state_transition_bash32_startup.sh`
**Exit Code:** 1
**Claim Source:** executed
**Result:** FAIL - `RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED`

The operator-designated pre-fix baseline is the exact dirty current
`bubbles/scripts/fun-mode.sh`, not an archived `HEAD` blob. The earlier
isolated run with `HEAD:bubbles/scripts/fun-mode.sh` remains historical
diagnostic evidence, but it does not satisfy `T-BUG-020-00` and does not
authorize implementation. The authoritative current-source result is:

```text
ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07  tests/regression/test_27_state_transition_bash32_startup.sh
GUARD_RUNS=8
API_RUNS=4
ASSERTIONS=201
PASSED=161
FAILED=40
BASH32_INTENDED_ABORTS=0
BASH32_PARSER_ABORTS=4
BASH32_OTHER_PRE_CHECK8_ABORTS=0
FINAL_SOURCE_GUARD_SHA256=09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a
FINAL_SOURCE_FUN_MODE_SHA256=edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e
FINAL_TEST_FILE_SHA256=ba8b7c8fb912131e5f7b06290c1247c84377bfdb67e217b05573e32beb420d07
BUG020_RED_DISPOSITION=RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED
BUG-020 state-transition Bash 3.2 startup regression FAILED
BUG020_EXACT_COMMAND_EXIT=1
BUG020_EXACT_COMMAND_CAPTURE_END
```

All eight guard cases and four direct API cases executed. The direct API
subprocesses passing on Bash 3.2 and Bash 5, and the current source rejecting
`declare -A`, `local -n`, and `declare -n`, are diagnostic controls only. They
are not GREEN and do not complete `T-BUG-020-09` through `T-BUG-020-13`, because
the ordered persistent execution is blocked at `T-BUG-020-00` and all four
Bash 3.2 production guard cases stopped before Check 8 on missing `yq`.

### Finding Closure Ledger

| Finding | Status | Required owner |
| --- | --- | --- |
| `BUG020-RED-001` | Unresolved: exact current source produced zero intended `gate_passed` aborts, so mandatory pre-fix RED is invalid. | `bubbles.design` |
| `BUG020-PARSER-001` | Unresolved: system-only `PATH` lacks `yq`; the real guard cannot reach Check 8 and then encounters the separate `failed_check_ids[@]` nounset path. | `bubbles.design` |
| `BUG020-BASELINE-001` | Unresolved: dirty current `fun-mode.sh` already contains the portable target mechanism, contradicting the packet's recorded pre-fix source shape. | `bubbles.design` |
| `BUG020-G094-001` | Addressed by the concurrent `bubbles.analyst` invocation; its execution history records the evidence-grounded Single-Capability Justification. | `bubbles.analyst` |
| `BUG020-PLAN-001` | Unresolved: `test-plan.json` contains duplicate/missing row fields and path drift from `scopes.md`; test ownership did not edit it. | `bubbles.plan` |
| `BUG020-TRACE-001` | Addressed: packet traceability passes after report evidence names the concrete production guard. | `bubbles.test` |
| `BUG020-CONCURRENCY-001` | Addressed: the concurrent leading regression was preserved; only this invocation's duplicate appended suffix was removed before the settled SHA and run. | `bubbles.test` |

`T-BUG-020-00` and every delivery DoD item remain unchecked. No production,
managed selftest, framework registration, install provenance, release manifest,
planning, certification, scope-status, commit, push, release, or GREEN claim is
made. Design reconciliation remains next and must preserve the completed
analyst-owned G094 prerequisite before any implementation route can open.

## Planning Reconciliation - Split-Lane Contract (2026-07-16)

This planner-owned section is the current evidence-destination template for the
reconciled scope. All earlier command output and specialist interpretations
above remain append-only historical records. In particular:

- [Final-Byte RED Regression](#final-byte-red-regression) used a later
  HEAD-restored source projection after the candidate source already existed;
  it is diagnostic and does not satisfy current `T-BUG-020-00`.
- [Test-Phase Authority Correction](#test-phase-authority-correction) records
  the current-source disposition
  `RED_INVALID_CURRENT_SOURCE_PARSER_BLOCKED`; it is neither intended RED nor
  GREEN and authorizes no production edit.
- No command was run by `bubbles.plan` to prove any delivery item, so every
  scope DoD checkbox remains open and certification remains blocked.

### Reconciled Planning Summary

The active inventory remains one `Not started` runtime-behavior scope with
three stable scenario IDs and 27 Test Plan rows:

| Scenario | Environment contract | Persistent rows |
| --- | --- | --- |
| `SCN-BUG-020-001` | Stock macOS Bash 3.2, strict system-only `PATH`, no parsers, timeout, or newer Bash; source and exercise the canonical seven-function fun API | `T-BUG-020-01`, `T-BUG-020-02`, `T-BUG-020-12`, `T-BUG-020-13` |
| `SCN-BUG-020-002` | Stock macOS Bash 3.2, strict system-only `PATH`, disabled fun mode; invoke the real guard | `T-BUG-020-03` |
| `SCN-BUG-020-003` | System directories first with only real `jq`/`yq` directories appended fail-loud; separate Bash 3.2 and newer-Bash guard cases | `T-BUG-020-04` through `T-BUG-020-11`, plus `T-BUG-020-14` |

The system-only guard lane must report exact `E009-REGISTRY-MISSING` nonzero
and must not claim Check 8. Parser-aware lanes alone prove Check 8, one
structured result, and fixture-controlled pass/finding exits. Complete
empty-array and BLOCKED-result integrity remains owned by BUG-022.

### Prospective RED Routing Classification

**Evidence owner:** `bubbles.test`

**Required evidence contract:** Revise and freeze the final `test_27` bytes;
record their digest; create an isolated worktree or owned temporary source
projection with the protected dependency snapshot and exact known pre-fix
`fun-mode.sh` blob; run the final test bytes before applying any candidate patch
in that lineage. A valid RED shows the historical fun-mode startup discriminator
in the parser-free API and parser-aware guard roles while fixture construction
and real-parser controls pass. Record the exact command, actual nonzero exit,
claim source, raw output, source identity, test digest, and cleanup result.

**Current planning state:** Not run. Historical evidence above is not reusable
for this row.

### Parser-Free API Routing Classification

**Evidence owner:** `bubbles.test`

**Required evidence contract:** With stock macOS Bash 3.2 and the strict
system-only `PATH`, prove disabled and enabled source/API behavior under nounset
without `jq`, `yq`, timeout, gtimeout, or newer Bash. Include all seven public
functions, every named event, unknown-event silence, all pools, banner, prefix,
summary branches, return behavior, the newer-Bash API control, and rejection of
`declare -A`, `local -n`, and `declare -n`.

**Current planning state:** Not run for the reconciled final test bytes.

### Resolver Refusal Routing Classification

**Evidence owner:** `bubbles.test`

**Required evidence contract:** Invoke the real guard under stock macOS Bash
3.2 with strict system-only `PATH` and disabled fun mode. Assert that fun-mode
startup succeeds, exact `E009-REGISTRY-MISSING` appears, the process exits
nonzero, and no Check 8 credit is claimed. Record any later empty-array or
result-emission behavior as BUG-022-owned rather than converting it into
BUG-020 success or failure.

**Current planning state:** Not run for the reconciled final test bytes.

### Parser-Aware Guard Routing Classification

**Evidence owner:** `bubbles.test`

**Required evidence contract:** Resolve real `jq` and `yq` fail-loud, append
only their directories after system directories, assert the Bash role, and run
disabled/enabled pass and genuine-finding fixtures under macOS system Bash and
newer Bash. Each fixture must reach Check 8 once, emit one structured result,
preserve fixture-controlled exit semantics, and keep presentation output from
changing governance truth. No parser shim, newer-Bash substitution for the
macOS lane, or timeout provider is permitted.

**Current planning state:** Not run for the reconciled final test bytes.

### Planning Route

The exact next owner is `bubbles.test` for `T-BUG-020-00`. Test ownership must
revise the existing test-owned regression to the split-lane contract and obtain
the prospective isolated final-test-byte RED. Only a valid result from that new
lineage may route the candidate patch to `bubbles.implement`; this planning run
does not authorize or perform source, test, registration, release, downstream,
sibling, certification, commit, or push mutations.

### Planner Finding Reconciliation

This table is additive to the historical [Finding Closure Ledger](#finding-closure-ledger).
It does not rewrite the earlier test-owned observations; it records how the
analyst/design split-lane contract changes their current routing disposition.

| Finding | Current disposition | Owner |
| --- | --- | --- |
| `PLAN_REQUIREMENT_PARITY_RECONCILIATION_REQUIRED` | Addressed: active scenarios, scope, Test Plan, DoD, machine manifests, report destinations, acceptance checklist, and execution route now encode parser-free API proof, system-only `E009` refusal without Check 8 credit, and parser-aware Check 8/result proof. | `bubbles.plan` |
| `BUG020-F001` | Open delivery umbrella, preserved without duplication: mandatory Bash 3.2 startup is not yet fixed or certified; its next executable obligations are represented by `BUG020-PROSPECTIVE-RED-001` and `BUG020-DEPENDENCY-022`. | `bubbles.test` |
| `BUG020-RED-001` | Reclassified, not erased: the current-source run remains invalid RED and receives no credit; its replacement obligation is `BUG020-PROSPECTIVE-RED-001`. | `bubbles.test` |
| `BUG020-PARSER-001` | Addressed in planning semantics: missing parsers are the expected strict system-only resolver refusal; Check 8 assertions moved exclusively to real-parser lanes. The later empty-array symptom remains `BUG020-DEPENDENCY-022`. | `bubbles.plan` |
| `BUG020-BASELINE-001` | Addressed in planning semantics: the dirty candidate is patch input only; a new isolated final-test-before-candidate lineage is mandatory. | `bubbles.plan` |
| `BUG020-G094-001` | Addressed by analyst-owned Single-Capability Justification; the canonical G094 command remains a required planning diagnostic. | `bubbles.analyst` |
| `BUG020-PLAN-001` | Addressed: `test-plan.json` has 27 unique complete rows with canonical paths and exact ordered Markdown/DoD parity. | `bubbles.plan` |
| `BUG020-TRACE-001` | Addressed by the prior test invocation; current traceability is rerun as a planner closeout gate. | `bubbles.test` |
| `BUG020-CONCURRENCY-001` | Addressed by the prior test invocation; current planning preserved all unrelated dirty bytes and historical evidence. | `bubbles.test` |
| `BUG020-TDD-LINEAGE-RESTART` | Addressed in the executable plan and evidence template: identical final test bytes must run before and after candidate application in one isolated lineage. | `bubbles.plan` |
| `BUG020-REPORT-TEMPLATE-PARITY` | Addressed: report destinations separately cover prospective RED, parser-free API, resolver refusal, parser-aware outcomes, managed checks, provenance, and certification. | `bubbles.plan` |
| `BUG020-BUG022-OWNERSHIP` | Addressed: no BUG-020 source/test authorization includes BUG-022 empty-array sites; the sibling packet remains the sole repair owner. | `bubbles.plan` |
| `BUG020-PROSPECTIVE-RED-001` | Unresolved: revised final `test_27` bytes have not yet executed first against the known pre-fix blob in the required isolated lineage. | `bubbles.test` |
| `BUG020-DEPENDENCY-022` | Unresolved external dependency: complete Bash 3.2 structured-result interpretation requires the independently owned BUG-022 repair; BUG-020 may consume but not author or claim it. | BUG-022 packet owner |
