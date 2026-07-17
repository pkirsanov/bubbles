# Report: BUG-019 State Transition Compound MJS Test Path

Related artifacts: [scopes.md](scopes.md), [scenario-manifest.json](scenario-manifest.json), [test-plan.json](test-plan.json), [uservalidation.md](uservalidation.md)

## Summary

The discovery evidence accounts for Research Lab finding `AUD-005-S01-004` and
the preserved RED proves the former Check 8 truncation while traceability
retains the complete linked token. Check 8 is repaired, the unchanged
production regression has independent 38/38 evidence, and the managed selftest
contains matching compound/control/adversarial twins. Planner reconciliation
replaces the parser-starving `T-BUG-019-08` command and keeps BUG-019 blocked on
BUG-020, BUG-021, an unpacketized Bash 3.2 empty-array defect, release metadata,
and independent certification.

## Completion Statement

BUG-019 remains `blocked` and routes next to `bubbles.bug` for complete creation
of `improvements/BUG-022-state-transition-bash32-empty-array-nounset`.
BUG-020 retains the `fun-mode.sh` ownership/sequencing collision and missing
mandatory RED/G094 obligations; BUG-021 retains the raw-timeout repair and
routes to `bubbles.plan`. After all source packets stabilize,
`bubbles.releases` owns generated manifest reconciliation and release
readiness. Every delivery DoD item remains unchecked, Scope 1 remains
`Blocked`, completed phase claims remain empty, and `certification.*` remains
validate-owned and unchanged.

## Planning Reconciliation Index

### Scope And Owner Inventory

| Surface | Exact path or family | Owner | Current planning disposition |
| --- | --- | --- | --- |
| Check 8 source | `bubbles/scripts/state-transition-guard.sh` | `bubbles.implement` | Check 8-local two-stage candidate/suffix repair only |
| Managed Check 8 matrix | `bubbles/scripts/state-transition-guard-selftest.sh` | `bubbles.test` | compound, compatibility, prefix, prose, and command-context twins |
| Persistent regression | `tests/regression/test_26_state_transition_spec_mjs_path.sh` | `bubbles.test` | collision-free source-only slot; must own valid RED and identical-command GREEN |
| Framework registration | `bubbles/scripts/framework-validate.sh` | `bubbles.test` | one adjacent `run_check_self_only` registration |
| Install classification | `bubbles/scripts/install-provenance-selftest.sh` | `bubbles.test` | managed guard/selftest and source-only regression assertions |
| Direct documentation | `BUGS.md`, `CHANGELOG.md` unless the docs registry resolves another direct contract | `bubbles.docs` | truthful executed behavior only |
| Generated release state | `bubbles/release-manifest.json` | `bubbles.releases` | canonical generation after source stabilization |
| Certification | `state.json::certification.*`, scope completion, terminal status | `bubbles.validate` | preserved until independent certification |
| Bash 3.2 fun startup | `bubbles/scripts/fun-mode.sh`, BUG-020 `test_27` and packet | BUG-020 owners | foreign collision; no BUG-020 RED or sequencing compliance inferred |
| Portable validation deadlines | two raw timeout registrations in `bubbles/scripts/framework-validate.sh` | BUG-021 owners | analyst justification present; packet routes to `bubbles.plan` |
| Bash 3.2 empty arrays | `passed_gate_ids[@]`, `failed_check_ids[@]` under nounset | `bubbles.bug` intake | no existing packet; deterministic target BUG-022 |

Research Lab, downstream installed framework bytes, BUG-012, BUG-013, BUG-018,
`traceability-guard.sh`, and unrelated dirty work are excluded from BUG-019
authoring.

## Current Planner Finding Ledger

| Finding | Disposition | Owner / packet |
| --- | --- | --- |
| `AUD-005-S01-004` | Addressed at the implementation/test surface by the preserved Check 8 repair, valid RED, and independent 38/38 GREEN. Scope completion is not inferred. | BUG-019 |
| `PLAN-019-002-SYSTEM-PATH-PARSERS` | Addressed in planner-owned artifacts: the exact command resolves `jq`/`yq` and keeps system paths first for nested Bash selection. | `bubbles.plan`, BUG-019 |
| `TEST-019-003` | Unresolved ownership/sequencing collision. `fun-mode.sh` changed, but BUG-020 still owns the behavior, lacks its mandatory final-byte pre-fix RED, and retains a spec-owned G094 gap. | `bubbles.analyst`, then `bubbles.test`, BUG-020 |
| `TEST-019-006-FUN-MODE-PERSISTENT-COVERAGE` | Unresolved; implementation probes do not replace BUG-020's absent persistent `test_27`. | `bubbles.test`, BUG-020 |
| `TEST-019-004-PORTABILITY` | Unresolved; raw timeout remains a stock-macOS runtime defect and a pragma cannot close it. | `bubbles.plan`, BUG-021 |
| `TEST-019-005-BASH32-EMPTY-ARRAY` | Unresolved; no existing packet owns the nounset failures exposed when required parsers are available. | `bubbles.bug` must create BUG-022 |
| `RELEASE-019-001` | Unresolved and untouched; no release check or generated metadata write belongs to this planning pass. | `bubbles.releases` after source stabilization |
| `PACKET-019-001` | Unresolved and nonterminal; all certification and terminal fields remain unchanged. | `bubbles.validate` after every prior owner |

The corrected `T-BUG-019-08` command is:

```bash
jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh
```

This is a runnable parser-behavior command on macOS and Linux/WSL when the two
mandatory parsers are installed. It does not claim GREEN while the foreign
empty-array nounset defect remains open.

### Planner Reconciliation Evidence - 2026-07-16

**Phase:** planning

**Commands:**

```bash
bash bubbles/scripts/artifact-lint.sh improvements/BUG-019-state-transition-spec-mjs-path
bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-019-state-transition-spec-mjs-path
bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-019-state-transition-spec-mjs-path
bash bubbles/scripts/traceability-guard.sh improvements/BUG-019-state-transition-spec-mjs-path
node -e 'const f=require("fs"),d="improvements/BUG-019-state-transition-spec-mjs-path",s=f.readFileSync(d+"/scopes.md","utf8"),r=f.readFileSync(d+"/report.md","utf8"),p=JSON.parse(f.readFileSync(d+"/test-plan.json")),m=JSON.parse(f.readFileSync(d+"/scenario-manifest.json")),j=JSON.parse(f.readFileSync(d+"/state.json")),rows=s.split("\n").filter(x=>/^\|/.test(x)&&/\| T-BUG-019-[0-9]{2} \|/.test(x)),ids=rows.map(x=>x.split("|")[2].trim()),tests=p.scopes[0].tests,dod=[...s.matchAll(/^- \[ \] `?(T-BUG-019-[0-9]{2})`?/gm)].map(x=>x[1]),cmd=rows.find(x=>x.includes("T-BUG-019-08")).split("|")[7].trim().slice(1,-1),need=["AUD-005-S01-004","PLAN-019-002-SYSTEM-PATH-PARSERS","TEST-019-003","TEST-019-006-FUN-MODE-PERSISTENT-COVERAGE","TEST-019-004-PORTABILITY","TEST-019-005-BASH32-EMPTY-ARRAY","RELEASE-019-001","PACKET-019-001"],scopeBlocked=/\*\*Status:\*\* Blocked/.test(s),certPreserved=j.certification.scopeProgress[0].status==="not_started"&&j.certification.completedScopes.length===0&&j.certification.certifiedCompletedPhases.length===0,ok=ids.length===18&&tests.length===18&&dod.length===18&&m.scenarios.length===3&&tests.find(x=>x.testId==="T-BUG-019-08").command===cmd&&need.every(x=>s.includes(x)&&r.includes(x))&&scopeBlocked&&j.status==="blocked"&&j.certification.status==="blocked"&&certPreserved&&j.execution.nextRequiredOwner==="bubbles.bug"; console.log(JSON.stringify({markdownTests:ids.length,jsonTests:tests.length,dodTestItems:dod.length,manifestScenarios:m.scenarios.length,t08CommandParity:tests.find(x=>x.testId==="T-BUG-019-08").command===cmd,findingLedgerEntries:need.length,scopeArtifactStatus:scopeBlocked?"Blocked":"MISMATCH",state:j.status,certification:j.certification.status,certificationScopeProgress:j.certification.scopeProgress[0].status,certificationOwnershipPreserved:certPreserved,nextRequiredOwner:j.execution.nextRequiredOwner,result:ok?"PASS":"FAIL"},null,2)); process.exit(ok?0:1)'
jq_bin="$(command -v jq)" && yq_bin="$(command -v yq)" && /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin:$(dirname "$jq_bin"):$(dirname "$yq_bin")" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh; exit_code=$?; printf 'BUG019_CORRECTED_T08_EXIT=%s\n' "$exit_code"; exit "$exit_code"
bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-020-state-transition-bash32-startup
bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-021-framework-validate-raw-timeout
shasum -a 256 bubbles/scripts/state-transition-guard.sh bubbles/scripts/fun-mode.sh bubbles/scripts/framework-validate.sh tests/regression/test_26_state_transition_spec_mjs_path.sh
```

**Exit Codes:** `0, 0, 0, 0, 0, 1, 1, 0, 0`.

**Claim Source:** executed

The commands ran without output filtering. These are literal result lines from
their complete current-session captures:

```text
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
capability-foundation-guard: PASS Gate G094 - state.json.createdAt is missing; treating spec as grandfathered
Scenarios checked: 3
Test rows checked: 18
Scenario-to-row mappings: 3
Concrete test file references: 3
Report evidence references: 3
DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: PASSED (0 warnings)
{
  "markdownTests": 18,
  "jsonTests": 18,
  "dodTestItems": 18,
  "manifestScenarios": 3,
  "t08CommandParity": true,
  "findingLedgerEntries": 8,
  "scopeArtifactStatus": "Blocked",
  "state": "blocked",
  "certification": "blocked",
  "certificationScopeProgress": "not_started",
  "certificationOwnershipPreserved": true,
  "nextRequiredOwner": "bubbles.bug",
  "result": "PASS"
}
PASS: compound matrix reaches production Check 8
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: adversarial matrix reaches production Check 8
PASS: all-invalid contexts reach the no-concrete-path branch
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 72: passed_gate_ids[@]: unbound variable
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
GUARD_RUNS=4
ASSERTIONS=38
PASSED=27
FAILED=11
BUG-019 state-transition Check 8 regression FAILED
BUG019_CORRECTED_T08_EXIT=1
G094 capability_foundation_gate: FAILED with 1 finding(s)
capability-foundation-guard: PASS Gate G094 - capability foundation requirements satisfied
09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a  bubbles/scripts/state-transition-guard.sh
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d  bubbles/scripts/framework-validate.sh
244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655  tests/regression/test_26_state_transition_spec_mjs_path.sh
```

BUG-020's G094 command is the exit `1` in this ledger; BUG-021's is exit `0`.
The corrected BUG-019 command is intentionally nonzero because it reaches the
routed empty-array nounset failure instead of starving the guard of parsers.
Full `framework-validate` and `release-check` were not run in this planning
reconciliation, and no generated release byte was written.

## Scenario Contract Evidence

| Scenario | Primary persistent assertion | Required evidence sections |
| --- | --- | --- |
| `SCN-BUG-019-001` | `Regression: compound MJS paths remain complete through production Check 8` | [RED](#red-production-path-regression), [GREEN](#green-production-path-regression) |
| `SCN-BUG-019-002` | `Regression: ordinary suffix, backtick, and command-wrapper controls remain compatible` | [GREEN](#green-production-path-regression), [Compatibility](#compatibility-and-portability-evidence) |
| `SCN-BUG-019-003` | `Regression: extension-prefix and prose candidates never reach Check 8 filesystem validation` | [RED](#red-production-path-regression), [Adversarial](#adversarial-regression-evidence) |

The persistent path is appropriate and collision-free: BUG-018 now owns
`test_25_traceability_test_plan_heading_depth.sh`, its adjacent
`framework-validate.sh` registration, and its source-only install-provenance
assertion. No `test_26` file, framework registration, or provenance assertion
exists. BUG-019 therefore retains `test_26`, whose future registration belongs
after BUG-018's `test_25` entry and whose install provenance must remain
source-only.

## Production Regex Discriminator - Before Fix

**Phase:** discovery
**Command:**

```bash
printf '%s\n' 'BUG019_PRODUCTION_REGEX_DISCRIMINATOR_RERUN_BEGIN' 'SOURCE=bubbles/scripts/state-transition-guard.sh Check 8' 'PIPELINE=backtick extraction -> exact production extension regex -> first match' 'CASE_COUNT=6'; inputs=('real-reporter|`tests/palm-springs-rental-market-lab.spec.mjs`' 'compound-test-mjs|`tests/palm-springs-rental-market-lab.test.mjs`' 'ordinary-spec-ts|`tests/palm-springs-rental-market-lab.spec.ts`' 'ordinary-test-js|`tests/palm-springs-rental-market-lab.test.js`' 'extension-prefix-prose|`tests/palm-springs-rental-market-lab.spec.mjs.backup`' 'non-path-prose|`the prose token example.spec.mjs should not be a test path`'); for entry in "${inputs[@]}"; do label="${entry%%|*}"; line="${entry#*|}"; extracted="$(echo "$line" | /usr/bin/grep -oE '`[^`]*`' | /usr/bin/grep -oE '[A-Za-z0-9._/-]+\.(spec|test|rs|ts|tsx|js|jsx|sh|bash|bats|py|go|java|scala|dart)\b' | /usr/bin/head -1 || true)"; printf 'CASE=%s\nINPUT=%s\nEXTRACTED=%s\n' "$label" "$line" "${extracted:-<empty>}"; done; printf '%s\n' 'DISCRIMINATOR_RERUN_STATUS=complete' 'BUG019_PRODUCTION_REGEX_DISCRIMINATOR_RERUN_END'
```

**Exit Code:** 0
**Claim Source:** executed

```text
BUG019_PRODUCTION_REGEX_DISCRIMINATOR_RERUN_BEGIN
SOURCE=bubbles/scripts/state-transition-guard.sh Check 8
PIPELINE=backtick extraction -> exact production extension regex -> first match
CASE_COUNT=6
CASE=real-reporter
INPUT=`tests/palm-springs-rental-market-lab.spec.mjs`
EXTRACTED=tests/palm-springs-rental-market-lab.spec
CASE=compound-test-mjs
INPUT=`tests/palm-springs-rental-market-lab.test.mjs`
EXTRACTED=tests/palm-springs-rental-market-lab.test
CASE=ordinary-spec-ts
INPUT=`tests/palm-springs-rental-market-lab.spec.ts`
EXTRACTED=tests/palm-springs-rental-market-lab.spec.ts
CASE=ordinary-test-js
INPUT=`tests/palm-springs-rental-market-lab.test.js`
EXTRACTED=tests/palm-springs-rental-market-lab.test.js
CASE=extension-prefix-prose
INPUT=`tests/palm-springs-rental-market-lab.spec.mjs.backup`
EXTRACTED=tests/palm-springs-rental-market-lab.spec
CASE=non-path-prose
INPUT=`the prose token example.spec.mjs should not be a test path`
EXTRACTED=example.spec
DISCRIMINATOR_RERUN_STATUS=complete
BUG019_PRODUCTION_REGEX_DISCRIMINATOR_RERUN_END
```

The original probe used `path` as a zsh variable. In zsh, `path` is tied to
`PATH`, so only its first row was valid before later commands became
unresolvable. That attempt is excluded from evidence; the complete rerun above
uses `extracted` and absolute reader-tool paths.

## Reporter Check 8 Reproduction - Before Fix

**Phase:** discovery
**Command:** `export PATH="/opt/homebrew/bin:/opt/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"; cd /Users/pkirsanov/Projects/research-lab && printf '%s\n' 'BUG019_REPORTER_CHECK8_ROWS_BEGIN' 'SOURCE=.github/bubbles/scripts/state-transition-guard.sh:2042' 'INPUT=specs/005-palm-springs-rental-market-lab/scopes.md'; if [[ -f tests/palm-springs-rental-market-lab.spec.mjs ]]; then printf '%s\n' 'REAL_PATH=tests/palm-springs-rental-market-lab.spec.mjs' 'REAL_PATH_EXISTS=yes'; else printf '%s\n' 'REAL_PATH=tests/palm-springs-rental-market-lab.spec.mjs' 'REAL_PATH_EXISTS=no'; fi; false_missing_count=0; while IFS= read -r line; do extracted="$(echo "$line" | grep -oE '`[^`]*`' | grep -oE '[A-Za-z0-9._/-]+\.(spec|test|rs|ts|tsx|js|jsx|sh|bash|bats|py|go|java|scala|dart)\b' | head -1 || true)"; if [[ "$extracted" == 'tests/palm-springs-rental-market-lab.spec' ]]; then false_missing_count=$((false_missing_count + 1)); if [[ -f "$extracted" ]]; then exists=yes; else exists=no; fi; printf 'FALSE_MISSING_ROW=%02d EXTRACTED=%s EXISTS=%s\n' "$false_missing_count" "$extracted" "$exists"; fi; done < <(grep -E '^\|.*\|.*\|.*\|' specs/005-palm-springs-rental-market-lab/scopes.md 2>/dev/null || true); printf 'FALSE_MISSING_COUNT=%s\n' "$false_missing_count"; printf '%s\n' 'BUG019_REPORTER_CHECK8_ROWS_END'`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG019_REPORTER_CHECK8_ROWS_BEGIN
SOURCE=.github/bubbles/scripts/state-transition-guard.sh:2042
INPUT=specs/005-palm-springs-rental-market-lab/scopes.md
REAL_PATH=tests/palm-springs-rental-market-lab.spec.mjs
REAL_PATH_EXISTS=yes
FALSE_MISSING_ROW=01 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=02 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=03 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=04 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=05 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=06 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=07 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=08 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=09 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=10 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=11 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=12 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=13 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=14 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=15 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=16 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=17 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=18 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=19 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=20 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_ROW=21 EXTRACTED=tests/palm-springs-rental-market-lab.spec EXISTS=no
FALSE_MISSING_COUNT=21
BUG019_REPORTER_CHECK8_ROWS_END
```

## Traceability Discriminator

**Phase:** discovery
**Command:** `bash .github/bubbles/scripts/traceability-guard.sh specs/005-palm-springs-rental-market-lab`
**Exit Code:** 0
**Claim Source:** executed

The command emitted more than 100 lines. It was run without output filtering;
the full 18 KB tool capture was read. These are the relevant raw windows.

```text
--- Scenario Manifest Cross-Check (G057/G059) ---
scenario-manifest.json covers 19 scenario contract(s)
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json linked test exists: tests/palm-springs-rental-market-lab.spec.mjs
scenario-manifest.json records evidenceRefs
All linked tests from scenario-manifest.json exist
```

```text
--- Traceability Summary ---
Scenarios checked: 19
Test rows checked: 43
Scenario-to-row mappings: 19
Concrete test file references: 19
Report evidence references: 19
DoD fidelity scenarios: 19 (mapped: 19, unmapped: 0)
Edge confidence (IMP-015 Scope B): declared=21 inferred=0 ambiguous=17

RESULT: PASSED (0 warnings)
BUG019_REPORTER_TRACEABILITY_EXIT=0
BUG019_REPORTER_TRACEABILITY_END
```

This proves the reporter path is healthy in traceability and isolates BUG-019
from BUG-018's Test Plan heading-depth defect.

## Installed Guard Entrypoint Attempts

**Claim Source:** interpreted
**Interpretation:** The accepted `cli.sh guard` entrypoint was attempted twice,
but neither attempt is used as the reproduction proof above.

1. `/bin/bash .github/bubbles/scripts/cli.sh guard ...` hit
   `fun-mode.sh: line 23: gate_passed: unbound variable` under macOS Bash 3.2
   and misleadingly returned `0`; it did not reach Check 8.
2. The PATH-selected `bash .github/bubbles/scripts/cli.sh guard ...` entered the
   full transition guard, but the tool capture returned before a final verdict
   was exposed. No exit code or missing-file count is inferred from it.

The focused reporter reproduction executes the installed Check 8 expression
and filesystem branch over all real rows, so the defect evidence does not rely
on either inconclusive wrapper attempt.

## Canonical Source Inspection

**Claim Source:** interpreted
**Interpretation:** Canonical and installed source contain the same controlling
Check 8 extraction line. Check 8 scrapes Markdown scope rows, not
`test-plan.json`, then checks the extracted token with `-f`.

```bash
path="$(echo "$line" | grep -oE '`[^`]*`' | grep -oE '[A-Za-z0-9._/-]+\.(spec|test|rs|ts|tsx|js|jsx|sh|bash|bats|py|go|java|scala|dart)\b' | head -1 || true)"
```

The reporter's `test-plan.json` and `scenario-manifest.json` preserve the full
`.spec.mjs`; only the Check 8 Markdown-token extractor invents `.spec`.

## BUG-018 Non-Collision Record

BUG-018 owns `traceability-guard.sh` heading-depth and expected-no-match
control flow. BUG-019 owns `state-transition-guard.sh` Check 8 path extraction.
The current traceability pass is positive evidence that BUG-018 is not the
controlling path for `AUD-005-S01-004`. No BUG-018 artifact was changed.

## Test Evidence

**Claim Source:** executed

The persistent production-path regression and its mandatory pre-fix RED now
exist. Source repair, test-owned GREEN, managed-selftest expansion, framework
validation, and release validation have not run in this test pass. Their exact
contracts and owners remain recorded in [scopes.md](scopes.md) and
[test-plan.json](test-plan.json).

### RED Production-Path Regression

**Phase:** test
**Executed:** YES (current session)
**Command:** `BUBBLES_SESSION_ID='BUG019-PREFIX-RED-20260715' BUBBLES_AGENT_NAME='bubbles.test' BUBBLES_SPEC='BUG-019-state-transition-spec-mjs-path' BUBBLES_SCOPE='Scope-1' BUBBLES_TOOL_LOG_TAGS='current-session,pre-fix-red,T-BUG-019-00,SCN-BUG-019-001,SCN-BUG-019-002,SCN-BUG-019-003' bash bubbles/scripts/tool-log.sh bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed
**Tool-log reference:** session `BUG019-PREFIX-RED-20260715`, command row at
`2026-07-15T23:30:48Z`, stdout 45,324 bytes,
`stdoutHash=6bae05fe1daf392cf9718e41f1b16a96dba700487e0511f089eb45fa5aa2b87a`,
stderr 1,557 bytes,
`stderrHash=f55c4d8f9cefa8eba48fbd783a23191261bf4b8adf8ffb458489d408e25e6f90`.

The command was executed unfiltered through `bubbles/scripts/tool-log.sh`.
This raw window contains the complete assertion verdicts; the structured
tool-log row preserves command, exit, duration, byte counts, and stream hashes
for the full 46,881-byte capture.

```text
--- BUG-019 compound and compatibility matrix exit=1 ---
PASS: compound matrix reaches production Check 8
PASS: compound matrix reaches a normal structured result
FAIL: compound and compatibility matrix exits zero (expected exit 0, got 1)
FAIL: reporter compound path reaches the complete existing-file branch (missing: Test file exists: tests/palm-springs-rental-market-lab.spec.mjs)
FAIL: compound test path reaches the complete existing-file branch (missing: Test file exists: tests/example.test.mjs)
FAIL: bare, wrapped, continued, later-block, and broader shell contexts select the complete path (expected 6 occurrence(s), got 5: Test file exists: tests/example.sh)
FAIL: reporter marker prefix is never checked as a missing file (unexpected: Test Plan references non-existent file: tests/palm-springs-rental-market-lab.spec)
FAIL: compound-test marker prefix is never checked as a missing file (unexpected: Test Plan references non-existent file: tests/example.test)
FAIL: compound matrix has no aggregate missing-file failure (unexpected: test files from Test Plan DO NOT EXIST)
PASS: ordinary .spec.ts control remains complete
PASS: ordinary .test.js control remains complete
PASS: marker-only .spec control remains accepted
PASS: marker-only .test control remains accepted
PASS: direct script command selects its first token
--- BUG-019 adversarial matrix exit=1 ---
PASS: adversarial matrix reaches production Check 8
FAIL: adversarial-only packet exits zero (expected exit 0, got 1)
FAIL: all-invalid contexts reach the no-concrete-path branch (missing: No concrete test file paths found in Test Plan across resolved scope files)
FAIL: invalid contexts never reach the existing-file branch (unexpected: Test file exists:)
FAIL: invalid contexts never reach the missing-file branch (unexpected: Test Plan references non-existent)
PASS: prose never triggers shorter basename resolution
PASS: prose never triggers complete basename resolution
FAIL: adversarial rejection introduces no failed check (missing: failedChecks: [])
FAIL: adversarial rejection reaches the normal passing verdict (missing: verdict: PASS)
--- BUG-019 missing-file enforcement exit=1 ---
PASS: missing-file control reaches production Check 8
PASS: genuinely missing allowed test path exits nonzero
PASS: missing allowed path reaches the existing Check 8 failure branch
PASS: missing allowed path contributes to the aggregate failure
PASS: structured result attributes the block to Check 8 file existence
PASS: missing-file control reaches the normal failing verdict
PASS: missing allowed path is not misclassified as no concrete path
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=25
FAILED=13
BUG-019 state-transition Check 8 regression FAILED
```

**Result:** PASS for the mandatory RED checkpoint. The nonzero exit is the
expected pre-fix result: the clean baseline passed, every planned assertion
executed, ordinary and command-wrapper controls remained active, all 13
assertion failures were compound/adversarial BUG-019 discriminators, and the
genuinely missing allowed file still blocked solely through
`failedChecks: [Check-8-file-existence]`.

### GREEN Production-Path Regression

**Claim Source:** executed

Independent GREEN evidence now exists in
[Test Pass 2 - Independent Ordered Verification](#test-pass-2---independent-ordered-verification).
The unchanged persistent regression executed four real production-guard
fixtures, reached Check 8 and the structured result, and passed all 38
assertions.

### Adversarial Regression Evidence

**Claim Source:** executed

The independent focused run rejects `.spec.mjs.backup`, extension-shaped prose,
`node --test`, quoted shell syntax, and `bash -c` without reaching either
filesystem branch. The bugfix regression-quality guard independently reports
one adversarial file and zero violations or warnings. Exact command, exit, and
tool-log provenance appear in Test Pass 2 below.

### Compatibility And Portability Evidence

**Claim Source:** executed

Marker-only/simple suffixes, `.spec.ts`, `.test.js`, bare and wrapped shell
paths, direct scripts, first-candidate behavior, regression quality, and macOS
system-Bash syntax pass. The exact five-file portability command remains
nonzero only for two pre-existing raw `timeout` calls in
`framework-validate.sh`; sanitized Bash 3.2 remains nonzero only because
`fun-mode.sh:23` aborts before Check 8. Both are foreign findings and no source
or test was weakened to conceal them.

### Framework Release And Certification Evidence

**Claim Source:** executed

Install provenance and packet gates through transition-contract resolution
pass. Serial canonical framework validation runs every registered check and
exits `1` only for release-manifest freshness and release-manifest selftest.
`release-check` was deliberately not run and generated metadata was not
modified, preserving release-owner authority. The production transition guard
also exits `1` while the packet remains intentionally nonterminal; its Check 8
section verifies every planned test file exists.

## Artifact Validation

### Canonical Artifact Lint

**Phase:** documentation
**Command:** `bash bubbles/scripts/cli.sh lint improvements/BUG-019-state-transition-spec-mjs-path`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG019_ARTIFACT_LINT_BEGIN
COMMAND=bash bubbles/scripts/cli.sh lint improvements/BUG-019-state-transition-spec-mjs-path
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
uservalidation checklist has checked-by-default entries
All checklist bullet items use checkbox syntax
Detected state.json status: blocked
Detected state.json workflowMode: bugfix-fastlane
state.json v3 has required field: status
state.json v3 has required field: execution
state.json v3 has required field: certification
state.json v3 has required field: policySnapshot
state.json v3 has recommended field: transitionRequests
state.json v3 has recommended field: reworkQueue
state.json v3 has recommended field: executionHistory
Top-level status matches certification.status
state.json uses deprecated field 'scopeProgress' - see scope-workflow.md state.json canonical schema v2
Workflow mode 'bugfix-fastlane' allows status 'done'; current status is 'blocked'
report.md contains section matching: Summary
report.md contains section matching: Completion Statement
report.md contains section matching: Test Evidence
Mode-specific report gates skipped (status not in promotion set)
All checked DoD items in scopes.md have evidence blocks
No unfilled evidence template placeholders in scopes.md
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
BUG019_ARTIFACT_LINT_EXIT=0
BUG019_ARTIFACT_LINT_END
```

The `scopeProgress` message is a nonblocking compatibility warning shared with
the BUG-018 local packet pattern. This intake does not rewrite validate-owned
state schema.

### Artifact Freshness

**Phase:** documentation
**Command:** `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-019-state-transition-spec-mjs-path`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG019_ARTIFACT_FRESHNESS_BEGIN
COMMAND=bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-019-state-transition-spec-mjs-path
BUBBLES ARTIFACT FRESHNESS GUARD
Feature: improvements/BUG-019-state-transition-spec-mjs-path
Check 1: Freshness Boundary Isolation (spec.md / design.md)
spec.md has no superseded/suppressed sections
design.md has no superseded/suppressed sections
No spec/design freshness boundaries detected
Check 2: Superseded Scope Sections Are Non-Executable
scopes.md has no superseded scope section
No superseded scope sections detected
Check 3: Per-Scope Directory Index References
Single-file scope layout detected - orphaned per-scope directory check not applicable
Check 4: Result
RESULT: PASS (0 failures, 0 warnings)
BUG019_ARTIFACT_FRESHNESS_EXIT=0
BUG019_ARTIFACT_FRESHNESS_END
```

### Pre-Reconciliation Traceability Planning Blocker

**Phase:** documentation
**Command:** `bash bubbles/scripts/traceability-guard.sh improvements/BUG-019-state-transition-spec-mjs-path`
**Exit Code:** 1
**Claim Source:** executed

This historical run found one discovery-packet wording mismatch in addition to
the missing regression. The DoD wording was corrected before the eight-row
handoff was replaced by the current 18-row plan. The complete discriminating
output is preserved here as pre-reconciliation evidence:

```text
BUG019_TRACEABILITY_RERUN_BEGIN
COMMAND=bash bubbles/scripts/traceability-guard.sh improvements/BUG-019-state-transition-spec-mjs-path
BUBBLES TRACEABILITY GUARD
Feature: improvements/BUG-019-state-transition-spec-mjs-path
Scenario Manifest Cross-Check (G057/G059)
scenario-manifest.json covers 3 scenario contract(s)
scenario-manifest.json references missing linked test file: tests/regression/test_26_state_transition_spec_mjs_path.sh
scenario-manifest.json references missing linked test file: tests/regression/test_26_state_transition_spec_mjs_path.sh
scenario-manifest.json references missing linked test file: tests/regression/test_26_state_transition_spec_mjs_path.sh
scenario-manifest.json records evidenceRefs
Checking traceability for Scope 1: Whole-Token Compound Test Path Extraction
Scope 1 scenario mapped to Test Plan row: Compound MJS test paths remain complete
Scope 1 mapped row references no existing concrete test file: Compound MJS test paths remain complete
Scope 1 scenario mapped to Test Plan row: Existing compound controls retain complete paths
Scope 1 mapped row references no existing concrete test file: Existing compound controls retain complete paths
Scope 1 scenario mapped to Test Plan row: Extension prefixes and prose are rejected
Scope 1 mapped row references no existing concrete test file: Extension prefixes and prose are rejected
Gherkin -> DoD Content Fidelity (Gate G068)
Scope 1 scenario maps to DoD item: Compound MJS test paths remain complete
Scope 1 scenario maps to DoD item: Existing compound controls retain complete paths
Scope 1 scenario maps to DoD item: Extension prefixes and prose are rejected
DoD fidelity: 3 scenarios checked, 3 mapped to DoD, 0 unmapped
Traceability Summary
Scenarios checked: 3
Test rows checked: 8
Scenario-to-row mappings: 3
Concrete test file references: 0
Report evidence references: 0
DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: FAILED (6 failures, 0 warnings)
BUG019_TRACEABILITY_RERUN_EXIT=1
BUG019_TRACEABILITY_RERUN_END
```

The six findings in this historical capture already pointed only to the absent
test-owned regression. The row count is superseded by the final planning gate
below; the raw result remains preserved rather than rewritten as current output.

### Final Planning Gates And Traceability Handoff

**Phase:** planning
**Commands:** canonical BUG-019 artifact lint, artifact freshness, G094
capability proportionality, and traceability guard from the Bubbles source root
**Exit Codes:** 0, 0, 0, 1
**Claim Source:** executed

```text
Artifact lint PASSED.
BUG019_FINAL_ARTIFACT_LINT_EXIT=0
RESULT: PASS (0 failures, 0 warnings)
BUG019_FINAL_FRESHNESS_EXIT=0
capability-foundation-guard: PASS Gate G094 - state.json.createdAt is missing; treating spec as grandfathered
BUG019_FINAL_G094_EXIT=0
scenario-manifest.json covers 3 scenario contract(s)
scenario-manifest.json references missing linked test file: tests/regression/test_26_state_transition_spec_mjs_path.sh
scenario-manifest.json references missing linked test file: tests/regression/test_26_state_transition_spec_mjs_path.sh
scenario-manifest.json references missing linked test file: tests/regression/test_26_state_transition_spec_mjs_path.sh
Scope 1: Whole-Token Compound Test Path Extraction scenario mapped to Test Plan row: Compound MJS test paths remain complete
Scope 1: Whole-Token Compound Test Path Extraction mapped row references no existing concrete test file: Compound MJS test paths remain complete
Scope 1: Whole-Token Compound Test Path Extraction scenario mapped to Test Plan row: Existing compound controls retain complete paths
Scope 1: Whole-Token Compound Test Path Extraction mapped row references no existing concrete test file: Existing compound controls retain complete paths
Scope 1: Whole-Token Compound Test Path Extraction scenario mapped to Test Plan row: Extension prefixes and prose are rejected
Scope 1: Whole-Token Compound Test Path Extraction mapped row references no existing concrete test file: Extension prefixes and prose are rejected
DoD fidelity: 3 scenarios checked, 3 mapped to DoD, 0 unmapped
Scenarios checked: 3
Test rows checked: 18
Scenario-to-row mappings: 3
Concrete test file references: 0
DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: FAILED (6 failures, 0 warnings)
BUG019_FINAL_TRACEABILITY_EXIT=1
```

**Result:** `route_required`. Planner-owned structure, freshness,
proportionality, scenario mapping, and DoD fidelity are coherent. Traceability
remains nonzero for exactly six implementation-owned findings: three manifest
links and three mapped scenario rows name the deliberately absent
`tests/regression/test_26_state_transition_spec_mjs_path.sh`. No additional
traceability finding exists, and planning does not create the test or claim its
future RED/GREEN evidence. Execution routing now names `bubbles.implement`;
packet status, scope status, completed-phase claims, and `certification.*`
remain nonterminal and unchanged.

## Initial Planning Finding Accounting (Historical)

This section records the first planning handoff and is retained as history.
The active disposition is [Current Planner Finding Ledger](#current-planner-finding-ledger).

- `AUD-005-S01-004` remains unresolved as a source defect and is now routed
  one-to-one into canonical BUG-019.
- `PLAN-019-001` is addressed: the stale discovery/design handoff is replaced
  by one reconciled `runtime-behavior` scope routed to `bubbles.implement`.
- `PLAN-019-002` is addressed: the coarse eight-row handoff is replaced by 18
  synchronized Markdown/JSON rows and 18 matching test-evidence DoD items.
- `PLAN-019-003` is addressed: scenario-manifest ownership, exact primary test
  titles, report anchors, change inventory, and owner routing are synchronized.
- Source repair, test-owned RED/GREEN, documentation, release validation,
  downstream upgrade, and validate-owned certification remain unresolved and
  individually assigned in the planning index.

## Initial Planning Uncertainty Declaration (Historical)

**What was attempted:** exact canonical regex execution, the installed Check 8
pipeline over reporter Test Plan rows, the installed traceability guard, and
the accepted installed guard CLI entrypoint.

**What was observed:** the focused production path reproduces 21 false missing
rows; traceability passes with the complete file; the full guard wrapper
attempts were inconclusive for the reasons recorded above.

**Why this remains open:** planning reconciliation is not implementation or
test execution; no specialist-owned regression or source repair exists.

**What would resolve this:** test-owned production-path RED, the bounded
implementation-owned repair, identical-command GREEN, managed compatibility
and portability checks, independent framework/release validation, direct docs,
and validate-owned certification.

## Invocation Audit

No subagents or nested workflow runners were invoked. This was the intake and
planning node of the top-level `bubbles.goal` runner's direct-authorized
`bugfix-fastlane`. The next required owner is `bubbles.implement`.

### Implement Pass 1 - Mandatory RED Handoff

This direct-authorized implementation pass stopped at the scenario-first TDD
gate. It did not edit production source, test source, registration surfaces,
release artifacts, planning content, DoD checkboxes, downstream repositories,
or `certification.*`. The current source defect remains open until the test
owner creates and executes the planned production-path regression against these
pre-fix bytes.

#### Mode And Path-Scoped Baseline

**Phase:** implement
**Commands:** persisted-mode resolution, full/scoped Git status and diff,
current/HEAD blob hashing, SHA-256 hashing, and exact Check 8 block capture
**Exit Code:** 0 for the grandfathered resolver and baseline captures
**Claim Source:** executed

```text
BUG019_IMPLEMENT_PREFLIGHT_GRANDFATHERED_BEGIN
DEPRECATION (v7 grandfather): resolving removed v5 mode 'bugfix-fastlane'
statusCeiling: done
requiredGates: [G001, G002, G003, G004, G005, G006, G007, G008, G009, G010,
G011, G012, G014, G015, G016, G018, G019, G020, G021, G022, G023, G024,
G025, G026, G027, G028, G029, G033, G034, G035, G040, G044, G047, G048,
G051, G055, G056, G057, G059, G060, G061, G094]
forceTddMode: scenario-first
requireBugReproductionBeforeFix: true
requireProtectedRegressionContracts: true
BUG019_IMPLEMENT_PREFLIGHT_GRANDFATHERED_END
```

```text
HEAD=9b785d7da7554082cfe0232998ef72cc99637087
HEAD_BLOB=bb3ecc7ae7103bc961a30b5f0fad1256cd23b1a6
WORKTREE_BLOB=fb3e4b55ab5a50450ed42e3c10e71dbb3f550aae
WORKTREE_SHA256=1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b
SOURCE_STATUS= M bubbles/scripts/state-transition-guard.sh
CHECK8_LINES=2030-2091
CHECK8_BYTES=3365
CHECK8_SHA256=c74719b56b01c361eb2a6b6ce4da44307d44214bb04a11fa414fa4ec19492521
TEST26_EXISTS=no
STATE_TRANSITION_SELFTEST_SHA256=20593a047f006cde0eb3db51f1c50b27c3230a46344d35aeea27e1da83dfd3ea
FRAMEWORK_VALIDATE_SHA256=05e4a2e8fc86c337967765058f573ee51700aabac6db1c5df4b4f197e673d765
INSTALL_PROVENANCE_SHA256=738849a827eca7c9e14f3c7edae744b8e9f9859236ea353b4b96ac07ade463c2
FRAMEWORK_VALIDATE_STATUS= M bubbles/scripts/framework-validate.sh
INSTALL_PROVENANCE_STATUS= M bubbles/scripts/install-provenance-selftest.sh
TEST25_STATUS=?? tests/regression/test_25_traceability_test_plan_heading_depth.sh
```

The source diff present before this pass is an unrelated G085 comment change
after Check 26, outside the captured Check 8 block. The two direct registration
files already contain concurrent BUG-013, BUG-018, and IMP-020 work. Their
hashes above are the preservation baseline; BUG-019 additions must be narrow
adjacent additions and must not replace or normalize those bytes.

#### Current-Source Falsifiable Discriminator

**Phase:** implement
**Command:** parse both `grep -oE` patterns from the current Check 8 source line
and execute them against the six design discriminators
**Exit Code:** 0
**Claim Source:** executed

```text
BUG019_CURRENT_EXTRACTOR_DISCRIMINATOR_BEGIN
CASE=spec-mjs
INPUT=`tests/example.spec.mjs`
EXTRACTED=tests/example.spec
RESULT=PASS
CASE=test-mjs
INPUT=`tests/example.test.mjs`
EXTRACTED=tests/example.test
RESULT=PASS
CASE=spec-ts
INPUT=`tests/example.spec.ts`
EXTRACTED=tests/example.spec.ts
RESULT=PASS
CASE=test-js
INPUT=`tests/example.test.js`
EXTRACTED=tests/example.test.js
RESULT=PASS
CASE=extension-prefix
INPUT=`tests/example.spec.mjs.backup`
EXTRACTED=tests/example.spec
RESULT=PASS
CASE=prose
INPUT=`the prose token example.spec.mjs is illustrative`
EXTRACTED=example.spec
RESULT=PASS
DISCRIMINATOR_RESULT=PASS
CAPTURED_AT=2026-07-15T23:13:31Z
BUG019_CURRENT_EXTRACTOR_DISCRIMINATOR_END
```

This confirms the local hypothesis: the current flat substring ERE truncates
the two MJS compounds while ordinary `.spec.ts` and `.test.js` controls remain
complete, and it false-accepts both planned adversaries. This focused
discriminator does not execute the production guard and therefore is not the
required `T-BUG-019-00` RED proof.

#### Existing Regression And Registration Check

Repository searches found no `.spec.mjs`, `.test.mjs`, or BUG-019 `test_26`
case under `tests/` or `bubbles/scripts/`. The existing managed Check 8
selftest covers bare `.sh`, placeholder-only, and command-wrapped `.sh` cases,
but not the planned compound/control/adversarial matrix. The collision check
also proves `tests/regression/test_26_state_transition_spec_mjs_path.sh` is
absent while BUG-018's untracked `test_25` exists and is already registered.

The exact test-owned surfaces are:

- `tests/regression/test_26_state_transition_spec_mjs_path.sh` - create and run
  now for the mandatory pre-fix RED;
- `bubbles/scripts/state-transition-guard-selftest.sh` - add the managed
  compound/control/adversarial twins after the production repair;
- `bubbles/scripts/framework-validate.sh` - add one adjacent
  `run_check_self_only` BUG-019 registration while preserving current dirty
  bytes; and
- `bubbles/scripts/install-provenance-selftest.sh` - add the BUG-019 managed
  guard/selftest and source-only `test_26` assertions while preserving current
  dirty bytes.

`bubbles/release-manifest.json` is not a direct test-owner registration surface;
it remains generator-owned and must not be hand-edited.

#### Route Request To Test Owner

`bubbles.test` must create the persistent regression and execute its final
post-repair assertions against the unchanged pre-fix production source. The
regression must:

1. invoke the actual Check 8 path in
   `bubbles/scripts/state-transition-guard.sh` against isolated disposable
   planning-maturity fixtures, without copying the parser;
2. reach the literal Check 8 marker and normal structured guard result before
   interpreting BUG-019 assertions;
3. exit nonzero on current bytes because `.spec.mjs` and `.test.mjs` are
   truncated to `.spec` and `.test`;
4. protect complete `.spec.ts`, `.test.js`, marker/simple suffix, bare
   backtick, `bash`/`sh` wrapper, shellcheck-continuation, and direct-script
   command behavior;
5. cover `.spec.mjs.backup`, extension-shaped prose, backtick boundaries, and
   unrecognized command-wrapper adversaries, proving no shorter direct or
   basename lookup occurs;
6. prove existing-file acceptance and missing-file enforcement both remain
   active, so the fixture cannot pass through a vacuous no-path branch;
7. fail closed when required canonical or fixture inputs are absent, count its
   named assertions, and contain no skip, inverted-expectation, conditional
   success, `|| true`, or other silent-pass bailout;
8. remain macOS system-Bash 3.2 and Linux portable, with unique temporary
   ownership and cleanup traps; and
9. print the complete production output and assertion summary, preserving the
   expected nonzero RED result without filtering or hiding output.

The test owner must return the exact regression file hash, command, nonzero
exit, and full raw RED output. Only that valid production-path RED permits
`bubbles.implement` to modify Check 8.

#### Implement-Pass Finding Accounting

- `IMP-019-001` addressed: mode ceiling, dirty-tree baseline, source/Check 8
  hashes, and concurrent registration bytes are captured above.
- `IMP-019-002` addressed: the design hypothesis is confirmed against the
  current source-owned extractor, and ordinary controls discriminate it from a
  broad suffix failure.
- `IMP-019-003` addressed: no existing persistent test provides the exact
  production-path RED; `test_26` remains collision-free and the direct
  registration surfaces are identified.
- `AUD-005-S01-004` unresolved: the production defect remains intentionally
  unchanged until valid test-owned RED exists.
- `T-BUG-019-00` unresolved: the persistent production-path regression and
  current pre-fix RED output remain test-owned and absent.

#### Post-Edit Handoff Validation

**Phase:** implement
**Commands:** baseline-integrity validator over the touched packet and protected
surfaces; canonical BUG-019 artifact lint
**Exit Codes:** 0, 0
**Claim Source:** executed

The first integrity invocation exited `1` because its local hash slice included
the separator immediately before Check 8 while the recorded baseline began at
the Check 8 comment. That invocation still reported the full production-file
hash unchanged. The slice boundary was corrected without any repository edit,
and the identical invariant set then passed:

```text
BUG019_IMPLEMENT_HANDOFF_VALIDATION_BEGIN
status-remains-blocked=PASS
execution-agent-implement=PASS
execution-phase-implement=PASS
next-owner-test=PASS
awaiting-test-red=PASS
no-completed-phase-claim=PASS
certification-byte-semantics-unchanged=PASS
implement-history-route=PASS
report-handoff-present=PASS
report-route-test=PASS
report-no-green-claim=PASS
production-full-sha-unchanged=PASS
check8-sha-unchanged=PASS
test26-still-absent=PASS
managed-selftest-unchanged=PASS
framework-registration-unchanged=PASS
provenance-registration-unchanged=PASS
release-manifest-unchanged=PASS
planning-bug.md-unchanged=PASS
planning-design.md-unchanged=PASS
planning-scenario-manifest.json-unchanged=PASS
planning-scopes.md-unchanged=PASS
planning-spec.md-unchanged=PASS
planning-test-plan.json-unchanged=PASS
planning-uservalidation.md-unchanged=PASS
VALIDATION_RESULT=PASS
BUG019_IMPLEMENT_HANDOFF_VALIDATION_END
```

```text
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
Mode-specific report gates skipped (status not in promotion set)
All checked DoD items in scopes.md have evidence blocks
No unfilled evidence template placeholders in scopes.md
No unfilled evidence template placeholders in report.md
Artifact lint PASSED.
```

`IMP-019-004` is addressed: the validator-boundary defect was local to the
read-only checking command, was corrected transparently, and the corrected
post-edit integrity check plus canonical packet lint both pass.

**Result:** `route_required` to `bubbles.test`. No GREEN, framework validation,
release readiness, implementation completion, verification, certification, or
terminal status is claimed.

### Test Pass 1 - Mandatory Pre-Fix RED

This direct-authorized test pass created only the persistent source-only
regression, its adjacent framework registration, its install-provenance
classification, test-owned evidence, and execution routing. Production Check
8, the managed state-transition selftest, generated release metadata,
downstream repositories, planning content, DoD checkboxes, status, and
`certification.*` were not modified.

#### Regression Quality

**Phase:** test
**Command:** `BUBBLES_SESSION_ID='BUG019-PREFIX-RED-20260715' BUBBLES_AGENT_NAME='bubbles.test' BUBBLES_SPEC='BUG-019-state-transition-spec-mjs-path' BUBBLES_SCOPE='Scope-1' BUBBLES_TOOL_LOG_TAGS='current-session,pre-fix-red,T-BUG-019-05,regression-quality' bash bubbles/scripts/tool-log.sh bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-15T23:32:38Z
  Bugfix mode: true
============================================================
ℹ️  Scanning tests/regression/test_26_state_transition_spec_mjs_path.sh
✅ Adversarial signal detected in tests/regression/test_26_state_transition_spec_mjs_path.sh
============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

**Result:** PASS. The persistent regression contains an adversarial signal and
no silent-pass, bailout, or bugfix-regression violation.

#### Portability And Registration Integrity

**Phase:** test
**Command:** `BUBBLES_SESSION_ID='BUG019-PREFIX-RED-20260715' BUBBLES_AGENT_NAME='bubbles.test' BUBBLES_SPEC='BUG-019-state-transition-spec-mjs-path' BUBBLES_SCOPE='Scope-1' BUBBLES_TOOL_LOG_TAGS='current-session,pre-fix-red,T-BUG-019-07,portability' bash bubbles/scripts/tool-log.sh bash bubbles/scripts/macos-portability-guard.sh tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 0
**Claim Source:** executed

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

The macOS system-Bash syntax command exited `0` for the regression,
`framework-validate.sh`, and `install-provenance-selftest.sh`. The exact
registration/integrity capture then reported:

```text
BUG019_TEST_REGISTRATION_INTEGRITY_BEGIN
TEST26_SHA256=244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655
FRAMEWORK_REGISTRATION_COUNT=1
PROVENANCE_CLASSIFICATION_COUNT=1
WHOLE_GUARD_EXPECTED=1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b
WHOLE_GUARD_ACTUAL=1f80abf7d7093c8aaefd7428f0c69eec62eefcaa394cd077c3b89ebc61f1188b
WHOLE_GUARD_RESULT=PASS
CHECK8_EXPECTED=c74719b56b01c361eb2a6b6ce4da44307d44214bb04a11fa414fa4ec19492521
CHECK8_ACTUAL=c74719b56b01c361eb2a6b6ce4da44307d44214bb04a11fa414fa4ec19492521
CHECK8_RESULT=PASS
MANAGED_SELFTEST_EXPECTED=20593a047f006cde0eb3db51f1c50b27c3230a46344d35aeea27e1da83dfd3ea
MANAGED_SELFTEST_ACTUAL=20593a047f006cde0eb3db51f1c50b27c3230a46344d35aeea27e1da83dfd3ea
MANAGED_SELFTEST_RESULT=PASS
INTEGRITY_RESULT=PASS
```

The primary failing RED workspace was removed by its `EXIT` trap after the
recorded exit `1`; the cleanup proof reported
`RED_WORKSPACE_REMOVED=PASS`, with `EXIT`, `INT`, and `TERM` traps registered.

#### Sanitized System-Bash Execution Blocker

**Phase:** test
**Command:** `BUBBLES_SESSION_ID='BUG019-PREFIX-RED-20260715' BUBBLES_AGENT_NAME='bubbles.test' BUBBLES_SPEC='BUG-019-state-transition-spec-mjs-path' BUBBLES_SCOPE='Scope-1' BUBBLES_TOOL_LOG_TAGS='current-session,pre-fix-red,T-BUG-019-08,system-bash,portability' bash bubbles/scripts/tool-log.sh /usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed
**Tool-log reference:** session `BUG019-PREFIX-RED-20260715`, command row at
`2026-07-15T23:43:07Z`, stdout 1,998 bytes,
`stdoutHash=b83f12a42aae57c8f98867440afc40316aeaf367529e1dbc745bc49e68e05a48`,
stderr 2,809 bytes,
`stderrHash=ce8817e17768e0b267cdfd63d1d182ef45ca244657d4dbbf083b6894a893da24`.

```text
=== BUG-019 harness control: real guard reaches Check 8 cleanly ===
--- BUG-019 baseline production output ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 baseline exit=1 ---
FAIL: baseline packet exits zero (expected exit 0, got 1)
FAIL: baseline reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
FAIL: baseline exercises the existing-file branch (missing: Test file exists: tests/example.sh)
FAIL: baseline reaches structured result start (missing: BEGIN TRANSITION_GUARD_RESULT_V1)
FAIL: baseline has no unrelated failed check (missing: failedChecks: [])
FAIL: baseline reaches the normal passing verdict (missing: verdict: PASS)
--- BUG-019 compound and compatibility matrix production output ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 compound and compatibility matrix exit=1 ---
--- BUG-019 adversarial matrix production output ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 adversarial matrix exit=1 ---
--- BUG-019 missing-file enforcement production output ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 missing-file enforcement exit=1 ---
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
GUARD_RUNS=4
ASSERTIONS=38
PASSED=11
FAILED=27
BUG-019 state-transition Check 8 regression FAILED
```

**Result:** unexpected precondition failure, not BUG-019 RED evidence. The
PATH-selected run used Homebrew Bash `5.3.15` and reached Check 8; sanitized
`/bin/bash` is macOS Bash `3.2.57` and aborted in the pre-existing
`fun-mode.sh` associative-array catalog before the guard banner. The regression
source itself passes `/bin/bash -n` and the 13-class portability scan, but
`T-BUG-019-08` remains unclaimed until the production entrypoint can reach
Check 8 under the declared Bash baseline. No workaround or production edit was
made in this pass.

#### Test-Pass Finding Accounting

- `TEST-019-001` addressed: the collision-free persistent production-path
  regression exists at SHA-256
  `244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655`,
  is registered once with `run_check_self_only`, and is classified once as
  source-only release provenance.
- `T-BUG-019-00` addressed: final post-repair assertions produced a valid
  current-session RED against unchanged production bytes, with four guard runs,
  38 total assertions, 25 passes, 13 exact BUG-019 failures, and exit `1`.
- `TEST-019-002` addressed: regression-quality, macOS/Linux portability,
  macOS system-Bash syntax, skip-marker absence, registration counts, fixture
  cleanup after the failing RED, and production-byte integrity checks are
  clean.
- `TEST-019-003` unresolved: sanitized macOS Bash `3.2.57` aborts in
  `bubbles/scripts/fun-mode.sh:23` before Check 8 with
  `gate_passed: unbound variable`. This is not the compound-MJS discriminator
  and is routed as a foreign production-entrypoint finding for
  `bubbles.implement` to classify without broadening BUG-019 silently.
- `AUD-005-S01-004` unresolved: Check 8 still truncates compound MJS paths and
  accepts invalid prefix/prose contexts; the production repair belongs to
  `bubbles.implement`.
- `T-BUG-019-01` through `T-BUG-019-04` remain unclaimed: GREEN and the managed
  behavior twins require the implementation-owned Check 8 repair first.
- `T-BUG-019-08` remains unclaimed because the sanitized system-Bash run never
  reached Check 8.
- Expected nonzero: the primary RED and the genuine missing-file negative
  control. Unexpected nonzero: the sanitized system-Bash precondition failure
  recorded as `TEST-019-003`. No other unexpected failure was observed.

#### Test-Pass Invocation Audit

- Top-level controller: existing direct-authorized `bubbles.goal` runner.
- Specialist executed directly: `bubbles.test` only.
- Nested workflow invocations: zero.
- Nested agent dispatches: zero.
- Production source edits: zero.
- Generated release edits: zero.
- Downstream or Research Lab edits: zero.
- Immediate routing owner: `bubbles.implement`.

**Result:** `route_required` to `bubbles.implement`. The packet remains blocked
and nonterminal; no GREEN, full framework validation, release check, fixed,
verified, done, scope completion, DoD completion, or certification claim is
made.

### Implement Pass 2 - Whole-Token Check 8 Repair

This direct-authorized implementation pass changed only Check 8 extraction in
`bubbles/scripts/state-transition-guard.sh`. It preserved the pre-existing
G085 comment delta later in that file, the test-owned regression and
registration bytes, generated release metadata, downstream installed bytes,
BUG-012/013/018, IMP-020, planning content, DoD checkboxes, scope status, and
`certification.*`.

#### Source Repair

**Phase:** implement
**Claim Source:** interpreted
**Interpretation:** The source now separates complete candidate recognition
from closed suffix validation. Backtick blocks are considered from left to
right. Only a bare path, the first script operand of `bash`/`sh`, or a direct
`.sh`/`.bash`/`.bats` command can produce a candidate. The whole candidate must
end in one of the planned suffixes, including `.spec.mjs` and `.test.mjs`, and
must have a nonempty basename stem. No command text is executed or evaluated.
The existing `test_files_in_plan`, direct-path check, basename lookup,
planning/delivery profile branches, aggregate diagnostics, and public exits
below extraction are unchanged.

Current source SHA-256 after the repair:

```text
09a7357ba7902509fda526277a1f48b226acc6033b9a4a867b2a3e5f6edc727a  bubbles/scripts/state-transition-guard.sh
```

#### Focused Repair Loop

**Phase:** implement
**Command 1:** `BUBBLES_SESSION_ID='BUG019-SCOPE01-IMPLEMENT-GREEN-20260715' BUBBLES_AGENT_NAME='bubbles.implement' BUBBLES_SPEC='BUG-019-state-transition-spec-mjs-path' BUBBLES_SCOPE='Scope-1' BUBBLES_TOOL_LOG_TAGS='current-session,post-edit,green,T-BUG-019-01,T-BUG-019-02,T-BUG-019-03' bash bubbles/scripts/tool-log.sh bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code 1:** 1
**Command 2:** `BUBBLES_SESSION_ID='BUG019-SCOPE01-IMPLEMENT-GREEN-20260715-TRY2' BUBBLES_AGENT_NAME='bubbles.implement' BUBBLES_SPEC='BUG-019-state-transition-spec-mjs-path' BUBBLES_SCOPE='Scope-1' BUBBLES_TOOL_LOG_TAGS='current-session,post-edit,green,retry-2,T-BUG-019-01,T-BUG-019-02,T-BUG-019-03' bash bubbles/scripts/tool-log.sh bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code 2:** 0
**Claim Source:** executed
**Tool-log references:** attempt 1 at `2026-07-16T01:08:06Z`,
`stdoutHash=c53f7ba43eb5e9355410a1bde0a3d737537c3a505bb7f62fdc1940210f0cc870`,
`stderrHash=0aa1557e3b24465bef42e280643d41bf4fcf131404a7ab4f083cbaa6560f3756`;
attempt 2 at `2026-07-16T01:09:25Z`,
`stdoutHash=15927f63e264d229db01938d612e3f7a9ad629d328e8afb7995f49b2683fe840`,
empty-stderr SHA-256
`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.

Attempt 1 proved the compound and ordinary controls were repaired but exposed
one local grammar defect: exact `bash -c` was skipped as an option, allowing its
following MJS command string to become a candidate. That one accepted path
caused all five remaining adversarial assertion failures.

```text
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: ordinary .spec.ts control remains complete
PASS: ordinary .test.js control remains complete
PASS: reporter marker prefix is never checked as a missing file
PASS: compound-test marker prefix is never checked as a missing file
FAIL: adversarial-only packet exits zero (expected exit 0, got 1)
FAIL: all-invalid contexts reach the no-concrete-path branch (missing: No concrete test file paths found in Test Plan across resolved scope files)
FAIL: invalid contexts never reach the missing-file branch (unexpected: Test Plan references non-existent)
FAIL: adversarial rejection introduces no failed check (missing: failedChecks: [])
FAIL: adversarial rejection reaches the normal passing verdict (missing: verdict: PASS)
GUARD_RUNS=4
ASSERTIONS=38
PASSED=33
FAILED=5
BUG-019 state-transition Check 8 regression FAILED
```

The local retry added exact `-c` to the already planned command-string
rejection. The identical regression then passed every positive, compatibility,
adversarial, and non-vacuity assertion:

```text
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: bare, wrapped, continued, later-block, and broader shell contexts select the complete path
PASS: direct script command selects its first token
PASS: reporter marker prefix is never checked as a missing file
PASS: compound-test marker prefix is never checked as a missing file
PASS: adversarial-only packet exits zero
PASS: all-invalid contexts reach the no-concrete-path branch
PASS: invalid contexts never reach the existing-file branch
PASS: invalid contexts never reach the missing-file branch
PASS: adversarial rejection introduces no failed check
PASS: adversarial rejection reaches the normal passing verdict
PASS: genuinely missing allowed test path exits nonzero
PASS: structured result attributes the block to Check 8 file existence
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
GUARD_RUNS=4
ASSERTIONS=38
PASSED=38
FAILED=0
BUG-019 state-transition Check 8 regression passed.
```

**Result:** PASS for the implementation-owned focused GREEN. The final test
bytes are unchanged at
`244b8121aa5da530d6456b5a672481fca82cdc2bf41f49dbafc6a45f1a602655`.

#### Focused Quality And Packet Checks

**Phase:** implement
**Commands:** macOS system-Bash syntax for the edited source; direct portability
scan of the edited source; bugfix regression-quality guard; BUG-019 artifact
lint, freshness, G094 capability proportionality, and traceability
**Exit Codes:** 0, 0, 0, 0, 0, 0, 0
**Claim Source:** executed

The syntax command intentionally emitted no stdout or stderr. Its structured
tool-log row at `2026-07-16T01:10:02Z` records exit `0`, duration 11 ms, and the
empty-stream SHA-256 for both streams. The following block contains only
literal lines emitted by the other six commands:

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
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
Artifact lint PASSED.
RESULT: PASS (0 failures, 0 warnings)
capability-foundation-guard: PASS Gate G094 - state.json.createdAt is missing; treating spec as grandfathered
scenario-manifest.json covers 3 scenario contract(s)
All linked tests from scenario-manifest.json exist
Scenarios checked: 3
Test rows checked: 18
Scenario-to-row mappings: 3
Concrete test file references: 3
Report evidence references: 3
DoD fidelity scenarios: 3 (mapped: 3, unmapped: 0)
RESULT: PASSED (0 warnings)
```

The seven successful commands are recorded under session
`BUG019-SCOPE01-IMPLEMENT-GREEN-20260715-TRY2` in
`.specify/runtime/tool-calls.jsonl`. No full framework validation or release
check was started in this implementation pass, and
`bubbles/release-manifest.json` was not generated or edited. Its preserved
SHA-256 is
`ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6`.

#### Implement-Pass Finding Accounting And Handoff

- `AUD-005-S01-004` is addressed at the implementation surface: complete MJS
  paths now reach the existing filesystem branch and invalid prefix/prose/
  unrecognized-command contexts produce no candidate.
- `T-BUG-019-00` remains valid test-owned RED evidence and predates the source
  repair.
- `BUG019-IMPLEMENT-TRY1` is addressed: exact `bash -c` now follows the closed
  unrecognized-command rule; the same regression moved from 33/38 to 38/38.
- `T-BUG-019-01`, `T-BUG-019-02`, and `T-BUG-019-03` have implementation-owned
  GREEN evidence. Independent test ownership must rerun them before any scope
  or test-phase completion claim.
- `T-BUG-019-05`, `T-BUG-019-06`, `T-BUG-019-07`, and packet rows
  `T-BUG-019-12` through `T-BUG-019-15` pass in this implementation session.
- `TEST-019-003` remains unresolved and outside the authorized Check 8 hunk:
  sanitized macOS Bash 3.2 still reaches the pre-existing `fun-mode.sh`
  startup failure before Check 8. This pass did not broaden into optional fun
  mode or weaken `T-BUG-019-08`.
- `T-BUG-019-04`, `T-BUG-019-08`, `T-BUG-019-09`, `T-BUG-019-10`,
  `T-BUG-019-11`, `T-BUG-019-16`, and `T-BUG-019-17` remain unclaimed by this
  implementation pass. Managed test expansion, independent system-Bash
  classification, install/framework/release validation, and certification
  retain their named owners.

**Result:** `route_required` to `bubbles.test`. The source repair is focused
GREEN, but the packet remains blocked and nonterminal. No DoD checkbox, scope
status, completed phase claim, fixed/verified/closed marker, certification,
release, propagation, downstream upgrade, commit, or push is claimed.

### Test Pass 2 - Independent Ordered Verification

This direct-authorized `bubbles.test` pass independently reread the packet,
production Check 8, persistent regression, managed selftest, framework
registration, and install-provenance assertions. It added only the planned
managed Check 8 twins to
`bubbles/scripts/state-transition-guard-selftest.sh`: one compound-MJS and
compatibility fixture plus one all-invalid adversarial fixture. The persistent
regression, production guard, framework registration, install-provenance
assertions, generated release metadata, downstream bytes, BUG-012/013/018,
IMP-020, and `certification.*` were not edited by this pass.

#### Ordered Command And Exit Ledger

**Phase:** test
**Executed:** YES (current session)
**Claim Source:** executed
**Session:** `BUG019-SCOPE01-INDEPENDENT-TEST-20260715`

Every executable row below ran through `bubbles/scripts/tool-log.sh`; the exact
inner command, exit, duration, stream byte counts, and SHA-256 hashes are in
`.specify/runtime/tool-calls.jsonl` under the stated session and `T-BUG-019-*`
tag.

| Row | Exact inner command | Exit | Disposition |
| --- | --- | ---: | --- |
| `T-BUG-019-00` | `bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | not rerun | Historical final-byte RED remains preserved at session `BUG019-PREFIX-RED-20260715`; production bytes were not reverted to manufacture a second RED. |
| `T-BUG-019-01`..`03` | `bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | 0 | Four real guard runs; 38/38 assertions pass. |
| `T-BUG-019-04` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | 0 | Ordered managed run passes; 12,614 stdout bytes. |
| `T-BUG-019-05` | `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_26_state_transition_spec_mjs_path.sh` | 0 | One adversarial file; zero violations and warnings. |
| `T-BUG-019-06` | `/bin/bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | 0 | macOS system-Bash syntax passes; both streams are empty and hash to the canonical empty SHA-256. |
| `T-BUG-019-07` | `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh` | 1 | Foreign: existing raw `timeout` calls at `framework-validate.sh:190,292`; no BUG-019-added line is implicated. |
| `T-BUG-019-08` | `/usr/bin/env -i HOME=/Users/pkirsanov PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh` | 1 | Foreign `TEST-019-003`: all four fixtures abort at `fun-mode.sh:23` before Check 8 (`gate_passed: unbound variable`). |
| `T-BUG-019-09` | `bash bubbles/scripts/install-provenance-selftest.sh` | 0 | Managed guard/selftest bytes and source-only `test_26` classification pass in disposable installer fixtures. |
| `T-BUG-019-10` | `bash bubbles/scripts/cli.sh framework-validate` | 1 | Canonical serial run; only release-manifest freshness and release-manifest selftest fail. |
| `T-BUG-019-11` | `bash bubbles/scripts/cli.sh release-check` | not run | Release-owner boundary: stable generated metadata has not been reconciled. |
| `T-BUG-019-12` | `bash bubbles/scripts/artifact-lint.sh improvements/BUG-019-state-transition-spec-mjs-path` | 0 | Packet shape passes; deprecated `scopeProgress` is a nonblocking warning. |
| `T-BUG-019-13` | `bash bubbles/scripts/artifact-freshness-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | 0 | Zero failures and warnings. |
| `T-BUG-019-14` | `bash bubbles/scripts/capability-foundation-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | 0 | G094 grandfathered pass because `createdAt` is absent. |
| `T-BUG-019-15` | `bash bubbles/scripts/traceability-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | 0 | Three scenarios, 18 rows, three concrete linked tests, zero warnings. |
| `T-BUG-019-16` | `bash bubbles/scripts/transition-contract-resolver.sh improvements/BUG-019-state-transition-spec-mjs-path` | 0 | Resolves `bugfix-fastlane` to `delivery-completion-v1`. |
| `T-BUG-019-17` | `bash bubbles/scripts/state-transition-guard.sh improvements/BUG-019-state-transition-spec-mjs-path` | 1 | Expected nonterminal refusal; Check 8 verifies every planned file. No state reversion flag was used. |

#### Focused And Managed Raw Output

**Command:** `bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool-log:** `2026-07-16T01:24:22Z`, stdout 45,872 bytes,
`stdoutHash=d88e198ffa9302fd0a26179d7dd7732a71b4416b406238867937413b922fa3bd`

```text
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: ordinary .spec.ts control remains complete
PASS: ordinary .test.js control remains complete
PASS: reporter marker prefix is never checked as a missing file
PASS: compound-test marker prefix is never checked as a missing file
PASS: adversarial-only packet exits zero
PASS: all-invalid contexts reach the no-concrete-path branch
PASS: invalid contexts never reach the existing-file branch
PASS: invalid contexts never reach the missing-file branch
PASS: genuinely missing allowed test path exits nonzero
PASS: structured result attributes the block to Check 8 file existence
GUARD_RUNS=4
ASSERTIONS=38
PASSED=38
FAILED=0
BUG-019 state-transition Check 8 regression passed.
```

**Command:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
**Exit Code:** 0
**Claim Source:** executed
**Tool-log:** `2026-07-16T01:27:16Z`, stdout 12,614 bytes,
`stdoutHash=76b09fe93ae6e423b173ca18cb2766e4fd6776c0f3b3b088492f1c67c218ef55`

```text
Running BUG-019 Check 8 compound-MJS compatibility selftest...
PASS: BUG-019 compound-MJS compatibility fixture passes the transition guard
PASS: BUG-019 Check 8 preserves the complete .spec.mjs path
PASS: BUG-019 Check 8 preserves the complete .test.mjs path
PASS: BUG-019 Check 8 preserves the ordinary .spec.ts control
PASS: BUG-019 Check 8 preserves the ordinary .test.js control
PASS: BUG-019 Check 8 preserves the command-wrapped shell control
PASS: BUG-019 Check 8 never checks the shorter .spec prefix
PASS: BUG-019 Check 8 never checks the shorter .test prefix
Running BUG-019 Check 8 adversarial-context selftest...
PASS: BUG-019 adversarial-context fixture passes without accepting a test path
PASS: BUG-019 invalid contexts reach the no-concrete-path branch
PASS: BUG-019 invalid contexts never reach the existing-file branch
PASS: BUG-019 invalid contexts never reach the missing-file branch
state-transition-guard selftest passed.
```

#### Nonzero And Not-Run Classification

**Claim Source:** executed

```text
T-BUG-019-07 exit=1 foreign=framework-validate.sh:190,292 raw-timeout
T-BUG-019-08 exit=1 foreign=fun-mode.sh:23 gate_passed-unbound-before-Check-8
T-BUG-019-09 exit=0 managed-and-source-only-install-provenance-pass
T-BUG-019-10 exit=1 failed-check=Release-manifest-freshness
T-BUG-019-10 exit=1 failed-check=Release-manifest-selftest
T-BUG-019-11 executed=no reason=release-owner-must-reconcile-stable-generated-inputs
T-BUG-019-12 exit=0 artifact-lint-pass
T-BUG-019-13 exit=0 freshness-pass
T-BUG-019-14 exit=0 G094-pass
T-BUG-019-15 exit=0 traceability-pass
T-BUG-019-16 exit=0 transition-contract-pass
T-BUG-019-17 exit=1 expected-nonterminal-refusal
T-BUG-019-17 check8=PASS all-planned-test-files-exist
release-check executed=no
generated-release-metadata modified-by-test=no
```

The certification guard reports `failureCount: 23`, `exitStatus: 1`, and
`verdict: FAIL`. Its expected nonterminal ledger includes 33 unchecked DoD
items, one `Not Started` scope, zero completed phase claims, and failed gates
`G055,G060,G022,G053,G040`. Check 8 itself passes for all 22 extracted file
references, including the complete compound-MJS regression path. This pass does
not reinterpret that refusal as a regression or mark any completion item.

#### Test Integrity Audit

**Phase:** test
**Command:** `printf '%s\n' 'BUG019_FINAL_STATIC_TEST_AUDIT_BEGIN' 'FILE=tests/regression/test_26_state_transition_spec_mjs_path.sh' 'CHECK=skip-only-todo-pending'; if grep -En 't\.Skip|\.skip\(|xit\(|xdescribe\(|\.only\(|test\.todo|it\.todo|pending\(' tests/regression/test_26_state_transition_spec_mjs_path.sh; then printf '%s\n' 'SKIP_MARKER_RESULT=FAIL'; exit 1; else printf '%s\n' 'SKIP_MARKER_MATCHES=0' 'SKIP_MARKER_RESULT=PASS'; fi; printf '%s\n' 'CHECK=live-test-interception'; if grep -En 'page\.route|context\.route|msw|nock|intercept|jest\.fn|sinon\.stub|mock\(' tests/regression/test_26_state_transition_spec_mjs_path.sh; then printf '%s\n' 'MOCK_AUDIT_RESULT=FAIL'; exit 1; else printf '%s\n' 'MOCK_PATTERN_MATCHES=0' 'MOCK_AUDIT_RESULT=PASS'; fi; printf '%s\n' 'PRODUCTION_GUARD_INVOCATION=bash "$GUARD" "$feature_dir"' 'FIXTURE_ISOLATION=mktemp-plus-EXIT-INT-TERM-trap' 'ASSERTION_SOURCE=production-guard-output' 'SELF_VALIDATING_REPLACEMENT_HEURISTIC=PASS' 'BUG019_FINAL_STATIC_TEST_AUDIT_END'`
**Exit Code:** 0
**Claim Source:** executed

```text
BUG019_FINAL_STATIC_TEST_AUDIT_BEGIN
FILE=tests/regression/test_26_state_transition_spec_mjs_path.sh
CHECK=skip-only-todo-pending
SKIP_MARKER_MATCHES=0
SKIP_MARKER_RESULT=PASS
CHECK=live-test-interception
MOCK_PATTERN_MATCHES=0
MOCK_AUDIT_RESULT=PASS
PRODUCTION_GUARD_INVOCATION=bash "$GUARD" "$feature_dir"
FIXTURE_ISOLATION=mktemp-plus-EXIT-INT-TERM-trap
ASSERTION_SOURCE=production-guard-output
SELF_VALIDATING_REPLACEMENT_HEURISTIC=PASS
BUG019_FINAL_STATIC_TEST_AUDIT_END
```

#### Independent-Test Finding Accounting

- `TEST-019-004` addressed: managed Check 8 twins now exercise compound MJS,
  ordinary suffixes, wrapped shell controls, shorter-prefix rejection, and
  all-invalid contexts through the real production guard.
- `T-BUG-019-01` through `T-BUG-019-06`, `T-BUG-019-09`, and
  `T-BUG-019-12` through `T-BUG-019-16` are independently executed and pass.
- `TEST-019-003` remains unresolved and foreign: sanitized macOS Bash 3.2
  aborts in `fun-mode.sh:23` before Check 8. Owner: `bubbles.implement`.
- `TEST-019-004-PORTABILITY` remains unresolved and foreign: the exact planned
  portability surface detects pre-existing raw `timeout` calls in
  `framework-validate.sh:190,292`. Owner: `bubbles.implement`.
- `RELEASE-019-001` remains unresolved: framework validation fails only release
  manifest freshness and selftest; release-check was not run and generated
  metadata was not changed. Owner after source stabilization: `bubbles.releases`.
- `PACKET-019-001` remains nonterminal by design: certification guard failures
  account for unchecked delivery, uncompleted phases, and planning/evidence
  promotion gates. Owners: `bubbles.plan` for foreign planning shape and
  `bubbles.validate` only after every prior owner closes its work.

**Result:** `route_required`. Immediate owner is `bubbles.implement` for the
foreign shell entrypoint and portability findings. Then `bubbles.test` must
rerun affected rows, `bubbles.releases` must reconcile generated release
metadata and run release readiness, and `bubbles.validate` remains the sole
certification/terminal-status owner. No commit or push occurred.

### Implement Pass 3 - Foreign Shell Ownership And Root-Cause Classification

This direct-authorized `bubbles.implement` pass classified the two foreign
prerequisites returned by independent test. It made no source, test, planning,
DoD, certification, generated-release, downstream, BUG-012/018, IMP-020,
BUG-020, or BUG-021 edit.

#### Mode And Change-Boundary Decision

**Phase:** implement
**Claim Source:** interpreted

`state.json::workflowMode` is `bugfix-fastlane`; that mode inherits
`base-delivery`, whose resolved `statusCeiling` is `done`. Implementation is
therefore permitted in principle. The active scope does not authorize either
foreign repair:

- `fun-mode.sh` is absent from the Scope 1 Owned Change Inventory and is not a
  Check 8 extraction surface;
- `framework-validate.sh` is owned by BUG-019 only for one adjacent
  `run_check_self_only` registration; and
- the Change Boundary requires any expansion to stop before editing the path
  and excludes unrelated state-transition helpers and collateral cleanup.

The controlling conclusion is falsifiable and exact: neither
`TEST-019-003` nor `TEST-019-004-PORTABILITY` may be repaired inside BUG-019.
Both already have deduplicated bug packets with their own closed source and
regression boundaries, so widening BUG-019 or creating another packet would
violate ownership and finding deduplication.

#### TEST-019-003 - Bash 3.2 Fun-Mode Startup

**Phase:** implement
**Command:** `/usr/bin/env -i HOME="$HOME" PATH="/usr/bin:/bin:/usr/sbin:/sbin" /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed

Relevant raw current-session output:

```text
=== BUG-019 harness control: real guard reaches Check 8 cleanly ===
--- BUG-019 baseline production output ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 baseline exit=1 ---
FAIL: baseline packet exits zero (expected exit 0, got 1)
FAIL: baseline reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
FAIL: baseline exercises the existing-file branch (missing: Test file exists: tests/example.sh)
FAIL: baseline reaches structured result start (missing: BEGIN TRANSITION_GUARD_RESULT_V1)
FAIL: baseline has no unrelated failed check (missing: failedChecks: [])
FAIL: baseline reaches the normal passing verdict (missing: verdict: PASS)
=== T-BUG-019-01 Regression: compound MJS paths remain complete through production Check 8 ===
=== T-BUG-019-02 Regression: ordinary suffix, backtick, and command-wrapper controls remain compatible ===
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
GUARD_RUNS=4
ASSERTIONS=38
PASSED=11
FAILED=27
BUG-019 state-transition Check 8 regression FAILED
```

The local hypothesis was that disabled optional fun mode still aborts because
the catalog is initialized eagerly with Bash-4-only associative-array syntax;
repairing only that declaration would expose a second Bash-4-only nameref in
the enabled random-wrapper path. Direct source inspection found `declare -A`
at line 23 and `local -n` at line 112. An isolated Bash 3.2 source probe exited
`127` before reaching its end marker. A no-edit probe of BUG-020's selected
portable forms produced:

```text
CURRENT_SOURCE_BEGIN
bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
CURRENT_SOURCE_RC=127
PORTABLE_DISABLED_BYTES=0
PORTABLE_KNOWN=Decent!
PORTABLE_UNKNOWN_BYTES=0
PORTABLE_POOL_MATCH=pass
PORTABLE_PATTERN_CONTRACT=pass
PORTABLE_PATTERN_RC=0
```

This supports a closed `case` dispatcher plus existing Bash-3.2 indexed pools
and positional-argument random selection. It proves representative disabled,
known-event, unknown-event, and pool contracts without claiming the unexecuted
full BUG-020 matrix. The exact repair and complete behavior proof belong to
`improvements/BUG-020-state-transition-bash32-startup`, whose current
`state.json` routes first to `bubbles.plan` for planning reconciliation.

#### TEST-019-004-PORTABILITY - Framework Validation Deadlines

**Phase:** implement
**Command:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
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
```

The local hypothesis was that these calls are only conditionally mediated by
the private PATH shim and are real base-macOS violations, not intentional
`portable-ok` exemptions. The shim aliases `gtimeout` only when that optional
binary exists; `framework-validate.sh` does not source `guard-lib.sh`, and
neither raw call has a pragma. The canonical helper probe under sanitized Bash
3.2 produced:

```text
BASH_VERSION=3.2.57(1)-release
TIMEOUT_BIN=absent
GTIMEOUT_BIN=absent
GUARD_LIB_SOURCE=pass
ORDINARY_CHILD_RC=7
WATCHDOG_TIMEOUT_RC=124
HELPER_CONTRACT=pass
```

The existing `bubbles_run_with_timeout` helper is therefore required: it works
without GNU coreutils, preserves ordinary child status, and normalizes the
watchdog timeout to `124`. Adding an exemption would hide an executable defect.
The exact two-call migration belongs to
`improvements/BUG-021-framework-validate-raw-timeout`, whose current
`state.json` routes first to `bubbles.analyst` for the missing G094
Single-Capability Justification before planning resumes.

#### Protected Bytes And Finding Handoff

**Phase:** implement
**Claim Source:** executed

Pre-edit hashes retained for foreign and generated surfaces:

```text
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d  bubbles/scripts/framework-validate.sh
ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6  bubbles/release-manifest.json
801885ceea92919ba3e6870bd2809205ad1e415184c958c3bb86d80c5e13a9a0  improvements/BUG-020-state-transition-bash32-startup/state.json
00d087e419df0b2b7486c59cc2cd91847e2d1efbedecae3b8235a6245d671afb  improvements/BUG-021-framework-validate-raw-timeout/state.json
```

### Implement Pass 4 - Direct-Authorized Bash 3 Repair And Truthful Routing

This direct-authorized `bubbles.implement` pass followed the operator's newer,
explicit authorization to repair the shared Bash 3.2 startup defect from the
current bytes. It replaced only Bash-4-only internals in
`bubbles/scripts/fun-mode.sh`. It did not edit a test, planning artifact, DoD
checkbox, scope status, release manifest, downstream repository, terminal
status, or `certification.*`. Two exploratory `portable-ok` comments in
`framework-validate.sh` were removed after the stock-macOS runtime probe
falsified their rationale; the final file has no source delta attributable to
this pass.

#### TEST-019-003 Pre-Repair Reproduction

**Phase:** implement
**Command:** `/usr/bin/env -i HOME=/Users/pkirsanov PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
=== BUG-019 harness control: real guard reaches Check 8 cleanly ===
--- BUG-019 baseline production output ---
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/fun-mode.sh: line 23: gate_passed: unbound variable
--- BUG-019 baseline exit=1 ---
FAIL: baseline packet exits zero (expected exit 0, got 1)
FAIL: baseline reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
FAIL: baseline exercises the existing-file branch (missing: Test file exists: tests/example.sh)
FAIL: baseline reaches structured result start (missing: BEGIN TRANSITION_GUARD_RESULT_V1)
FAIL: baseline has no unrelated failed check (missing: failedChecks: [])
FAIL: baseline reaches the normal passing verdict (missing: verdict: PASS)
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=11
FAILED=27
BUG-019 state-transition Check 8 regression FAILED
```

The falsifiable local hypothesis was that `fun-mode.sh` aborts while being
sourced because `declare -A` is unsupported by Bash 3.2, while `local -n` is a
second latent Bash-4-only path for enabled wrappers. The production repair
replaced the associative catalog with one closed `case` dispatcher and changed
the random helper to receive indexed-pool elements as positional arguments.
The seven public functions, all event messages, all pool members, unknown-event
silence, and enabled/disabled semantics remain unchanged.

#### Final Bash 3.2 Fun API Proof

**Phase:** implement
**Command:** `/usr/bin/env -i HOME=/Users/pkirsanov PATH=/usr/bin:/bin:/usr/sbin:/sbin BUBBLES_FUN_MODE=true /bin/bash -c 'set -euo pipefail; source bubbles/scripts/fun-mode.sh; fun_message gate_passed; fun_message unknown_event; fun_pass; fun_fail; fun_warn; fun_banner; fun_summary pass; fun_summary fail 5; fun_summary fail 1; printf "%s\n" FUN_MODE_BASH32_API_PASS'`
**Exit Code:** 0
**Claim Source:** executed

```text
   🫧 Decent!
   🫧 Decent!
   🫧 Holy f***, boys.
   🫧 The shit winds are coming, Randy.
   🫧 ────────────────────────────────────────
   🫧  BUBBLES FUN MODE: ON
   🫧  "It ain't rocket appliances."
   🫧 ────────────────────────────────────────
   🫧 Way she goes, boys. Way she goes.
   🫧 Boys, we're in the eye of a shiticane.
   🫧 Something's fucky.
FUN_MODE_BASH32_API_PASS
```

The unknown event emits no line, matching the prior optional-message contract.
The random wrapper selections are intentionally nondeterministic members of
their unchanged pools.

#### Complete Event-Catalog Preservation Proof

**Phase:** implement
**Command:** `bash -c 'set -euo pipefail; events=(gate_passed scope_ready gate_failed fabrication_detected missing_evidence all_gates_pass build_failed spec_completed warnings_found chaos_clean regression_clean regression_found spec_conflict recap security_vuln docs_updated deferral_detected deferral_blocks_done manipulation_detected format_bypass invented_status handoff_complete gap_found bug_located build_succeeds milestone_reached guard_start guard_blocked guard_clear lint_start lint_clean lint_dirty dashboard_start scan_start scan_clean scan_dirty audit_start audit_clean audit_dirty); failures=0; for event in "${events[@]}"; do expected="$(BUBBLES_FUN_MODE=true bash -c '\''source <(git show HEAD:bubbles/scripts/fun-mode.sh); fun_message "$1"'\'' _ "$event")"; actual="$(BUBBLES_FUN_MODE=true bash -c '\''source bubbles/scripts/fun-mode.sh; fun_message "$1"'\'' _ "$event")"; if [[ "$actual" == "$expected" ]]; then printf "PASS: %s message unchanged\n" "$event"; else printf "FAIL: %s message changed\n" "$event"; failures=$((failures + 1)); fi; done; unknown="$(BUBBLES_FUN_MODE=true bash -c '\''source bubbles/scripts/fun-mode.sh; fun_message unknown_event'\'')"; if [[ -z "$unknown" ]]; then printf "%s\n" "PASS: unknown event remains silent"; else printf "%s\n" "FAIL: unknown event emitted output"; failures=$((failures + 1)); fi; printf "EVENTS=%s FAILURES=%s\n" "${#events[@]}" "$failures"; [[ "$failures" -eq 0 ]]'`
**Exit Code:** 0
**Claim Source:** executed

```text
PASS: gate_passed message unchanged
PASS: scope_ready message unchanged
PASS: gate_failed message unchanged
PASS: fabrication_detected message unchanged
PASS: missing_evidence message unchanged
PASS: all_gates_pass message unchanged
PASS: build_failed message unchanged
PASS: spec_completed message unchanged
PASS: warnings_found message unchanged
PASS: chaos_clean message unchanged
PASS: regression_clean message unchanged
PASS: regression_found message unchanged
PASS: spec_conflict message unchanged
PASS: recap message unchanged
PASS: security_vuln message unchanged
PASS: docs_updated message unchanged
PASS: deferral_detected message unchanged
PASS: deferral_blocks_done message unchanged
PASS: manipulation_detected message unchanged
PASS: format_bypass message unchanged
PASS: invented_status message unchanged
PASS: handoff_complete message unchanged
PASS: gap_found message unchanged
PASS: bug_located message unchanged
PASS: build_succeeds message unchanged
PASS: milestone_reached message unchanged
PASS: guard_start message unchanged
PASS: guard_blocked message unchanged
PASS: guard_clear message unchanged
PASS: lint_start message unchanged
PASS: lint_clean message unchanged
PASS: lint_dirty message unchanged
PASS: dashboard_start message unchanged
PASS: scan_start message unchanged
PASS: scan_clean message unchanged
PASS: scan_dirty message unchanged
PASS: audit_start message unchanged
PASS: audit_clean message unchanged
PASS: audit_dirty message unchanged
PASS: unknown event remains silent
EVENTS=39 FAILURES=0
```

#### Final BUG-019 Production Regression

**Phase:** implement
**Command:** `bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: ordinary .spec.ts control remains complete
PASS: ordinary .test.js control remains complete
PASS: reporter marker prefix is never checked as a missing file
PASS: compound-test marker prefix is never checked as a missing file
PASS: adversarial-only packet exits zero
PASS: all-invalid contexts reach the no-concrete-path branch
PASS: invalid contexts never reach the existing-file branch
PASS: invalid contexts never reach the missing-file branch
PASS: genuinely missing allowed test path exits nonzero
PASS: structured result attributes the block to Check 8 file existence
GUARD_RUNS=4
ASSERTIONS=38
PASSED=38
FAILED=0
BUG-019 state-transition Check 8 regression passed.
```

#### T-BUG-019-08 Planning And Runtime Discriminators

The exact planned system-only command is not a valid complete production
regression command: its `PATH` removes mandatory `jq` and `yq`, so the
fail-closed transition-contract resolver cannot initialize. After the
fun-mode repair, the same command no longer reports `fun-mode.sh:23`; it reaches
the resolver failure and then a separate Bash 3.2 empty-array nounset failure.

**Phase:** implement
**Command:** `/usr/bin/env -i HOME=/Users/pkirsanov PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
=== BUG-019 harness control: real guard reaches Check 8 cleanly ===
--- BUG-019 baseline production output ---
E009-REGISTRY-MISSING: required registry parser is unavailable
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
--- BUG-019 baseline exit=1 ---
FAIL: baseline packet exits zero (expected exit 0, got 1)
FAIL: baseline reaches production Check 8 (missing: --- Check 8: Test File Existence ---)
FAIL: baseline reaches structured result start (missing: BEGIN TRANSITION_GUARD_RESULT_V1)
FAIL: baseline has no unrelated failed check (missing: failedChecks: [])
PASS: genuinely missing allowed test path exits nonzero
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=11
FAILED=27
BUG-019 state-transition Check 8 regression FAILED
```

Keeping system paths first while appending the installed parser directory lets
the unchanged regression execute the real guard under nested `/bin/bash` 3.2.
That run reaches Check 8 and independently exposes empty-array expansions under
`set -u` at `passed_gate_ids[@]` and `failed_check_ids[@]`. This defect is
outside BUG-019's closed Check 8 source boundary and outside BUG-020's design,
which explicitly keeps `state-transition-guard.sh` unchanged.

**Phase:** implement
**Command:** `/usr/bin/env -i HOME=/Users/pkirsanov PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin /bin/bash tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
PASS: compound matrix reaches production Check 8
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 72: passed_gate_ids[@]: unbound variable
FAIL: compound matrix reaches a normal structured result (missing: END TRANSITION_GUARD_RESULT_V1)
PASS: compound and compatibility matrix exits zero
PASS: reporter compound path reaches the complete existing-file branch
PASS: compound test path reaches the complete existing-file branch
PASS: adversarial matrix reaches production Check 8
FAIL: adversarial rejection introduces no failed check (missing: failedChecks: [])
/Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh: line 82: failed_check_ids[@]: unbound variable
FAIL: genuinely missing allowed test path exits nonzero (expected nonzero exit, got 0)
PASS: all 4 production-guard fixtures executed
PASS: all 36 planned assertions executed
=== BUG-019 regression summary ===
GUARD_RUNS=4
ASSERTIONS=38
PASSED=27
FAILED=11
BUG-019 state-transition Check 8 regression FAILED
```

`bubbles.plan` owns reconciliation of the impossible `T-BUG-019-08` command.
The array failure requires an explicit sibling-bug/design disposition rather
than an undocumented BUG-019 source expansion.

#### TEST-019-004-PORTABILITY Runtime Classification

The two `framework-validate.sh` raw timeout calls are not merely a scanner
policy mismatch. The private shim maps optional `gtimeout` when installed but
has no provider or watchdog on stock macOS. A source-local exemption is
therefore untruthful and was not retained.

**Phase:** implement
**Command:** `/usr/bin/env -i HOME=/Users/pkirsanov PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/bash -c 'printf "%s\n" STOCK_MACOS_TIMEOUT_PROBE_BEGIN "BASH_VERSION=$BASH_VERSION" "PATH=$PATH"; printf "BASH_BIN="; command -v bash; if command -v timeout >/dev/null 2>&1; then printf "%s\n" TIMEOUT_BIN=present; else printf "%s\n" TIMEOUT_BIN=absent; fi; if command -v gtimeout >/dev/null 2>&1; then printf "%s\n" GTIMEOUT_BIN=present; else printf "%s\n" GTIMEOUT_BIN=absent; fi; printf "%s\n" RAW_TIMEOUT_CALL_BEGIN; set +e; timeout 1 /usr/bin/true; raw_timeout_rc=$?; set -e; printf "%s\n" "RAW_TIMEOUT_CALL_RC=$raw_timeout_rc" "EXPECTED_PORTABLE_TIMEOUT_RC=0"; if [[ "$raw_timeout_rc" -eq 127 ]]; then printf "%s\n" RUNTIME_CLASSIFICATION=actual-defect; else printf "%s\n" RUNTIME_CLASSIFICATION=not-reproduced; fi; printf "%s\n" STOCK_MACOS_TIMEOUT_PROBE_END'`
**Exit Code:** 0
**Claim Source:** executed

```text
STOCK_MACOS_TIMEOUT_PROBE_BEGIN
BASH_VERSION=3.2.57(1)-release
PATH=/usr/bin:/bin:/usr/sbin:/sbin
BASH_BIN=/bin/bash
TIMEOUT_BIN=absent
GTIMEOUT_BIN=absent
RAW_TIMEOUT_CALL_BEGIN
/bin/bash: timeout: command not found
RAW_TIMEOUT_CALL_RC=127
EXPECTED_PORTABLE_TIMEOUT_RC=0
RUNTIME_CLASSIFICATION=actual-defect
STOCK_MACOS_TIMEOUT_PROBE_END
```

**Phase:** implement
**Command:** `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/framework-validate.sh bubbles/scripts/install-provenance-selftest.sh`
**Exit Code:** 1
**Claim Source:** executed

```text
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
```

The helper migration remains owned by
`improvements/BUG-021-framework-validate-raw-timeout`; its current
`nextRequiredOwner` is `bubbles.plan`. Timeout protection was neither removed
nor weakened in this pass.

#### Focused Validation Ledger

**Phase:** implement
**Claim Source:** executed

| Exact command | Exit | Current-byte result |
| --- | ---: | --- |
| `/bin/bash -n bubbles/scripts/fun-mode.sh bubbles/scripts/framework-validate.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_26_state_transition_spec_mjs_path.sh bubbles/scripts/install-provenance-selftest.sh` | 0 | All planned and touched shell files parse under macOS Bash 3.2. |
| `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/fun-mode.sh` | 0 | The owned fun-mode repair passes all 13 portability classes. |
| `bash bubbles/scripts/macos-portability-guard-selftest.sh` | 0 | Canonical green/red fixtures, pragma handling, recursion, env surface, usage, syntax, and self-portability pass. |
| `bash bubbles/scripts/state-transition-guard-selftest.sh` | 0 | Managed guard suite, including BUG-019 compound and adversarial twins, passes. |
| `bash bubbles/scripts/install-provenance-selftest.sh` | 0 | Managed BUG-019 guard/selftest and source-only regression classifications pass. |
| `git diff --check -- bubbles/scripts/fun-mode.sh bubbles/scripts/framework-validate.sh` | 0 | No whitespace errors. |

#### Concrete Test Rework Packet

Target owner: `bubbles.test`, after planning and the foreign runtime finding are
reconciled.

1. Add or adopt persistent production-source coverage that starts actual
   `/bin/bash` 3.2, sources `bubbles/scripts/fun-mode.sh`, and exercises disabled
   mode, every named event, unknown-event silence, all wrappers, banner, and
   summary without copying the dispatcher or pools.
2. Keep the regression fail-loud: do not skip or mask the empty-array nounset
   abort in `state-transition-guard.sh`.
3. Execute the planner-reconciled macOS production command with the same
   `/bin/bash` interpreter for the test harness and nested production guard,
   while making mandatory registry parsers available explicitly.
4. Rerun `test_26`, the managed guard selftest, Bash syntax, the exact
   portability surface, and install provenance; record independent raw output
   and actual exits.

#### Finding Accounting And Route

- `AUD-005-S01-004` addressed at the implementation surface: the unchanged
  production regression remains `38/38` and preserves complete compound MJS
  paths.
- `TEST-019-003` addressed at its reported source cause: `fun-mode.sh` contains
  no associative arrays, namerefs, or other Bash-4-only construct, and its
  public API executes under sanitized Bash 3.2.
- `TEST-019-004-PORTABILITY` unresolved: stock macOS has no timeout provider,
  so the two raw calls require BUG-021's planned `guard-lib.sh` migration.
  Owner: `bubbles.plan`, then `bubbles.implement` in BUG-021.
- `RELEASE-019-001` unresolved and untouched. Owner: `bubbles.releases` after
  all source inputs stabilize; `release-check` was not run by this pass.
- `PACKET-019-001` unresolved and nonterminal. Owner: `bubbles.plan` for the
  invalid `T-BUG-019-08` command and foreign-finding disposition; terminal
  certification remains `bubbles.validate`-only.
- `PLAN-019-002-SYSTEM-PATH-PARSERS` newly unresolved: `T-BUG-019-08` removes
  mandatory `jq`/`yq` and cannot prove its stated production matrix. Owner:
  `bubbles.plan`.
- `TEST-019-005-BASH32-EMPTY-ARRAY` newly unresolved: with parsers restored,
  Bash 3.2 reaches Check 8 but aborts on empty-array nounset expansions in the
  production guard. Owner: planning/design disposition into a dedicated bug;
  no BUG-019 expansion is authorized.
- `TEST-019-006-FUN-MODE-PERSISTENT-COVERAGE` newly unresolved: the production
  repair has an implementation-owned executable probe but requires independent
  persistent coverage. Owner: `bubbles.test` after the preceding route closes.

**Result:** `route_required`. The immediate owner is `bubbles.plan`. BUG-019
source behavior is stable under normal execution, but the exact planned macOS
row cannot pass and source stabilization is not sufficient for an independent
test completion claim. No commit, push, release check, or terminal transition
occurred.

#### Final Regression-Integrity Addendum

**Phase:** implement
**Command:** `bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_26_state_transition_spec_mjs_path.sh`
**Exit Code:** 0
**Claim Source:** executed

```text
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-16T04:33:34Z
  Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_26_state_transition_spec_mjs_path.sh
✅ Adversarial signal detected in tests/regression/test_26_state_transition_spec_mjs_path.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
```

- `TEST-019-003` is preserved one-for-one and routed to BUG-020; its exact
  current owner is `bubbles.plan`.
- `TEST-019-004-PORTABILITY` is preserved one-for-one and routed to BUG-021;
  its exact current owner is `bubbles.analyst`.
- `RELEASE-019-001` remains owned by `bubbles.releases` only after the source
  inputs from the active packets stabilize. No release command ran and no
  generated manifest byte was written in this pass.
- `PACKET-019-001` remains nonterminal. No DoD checkbox, scope status,
  completion claim, certification field, or terminal status changed.

**Result:** `route_required`. Ordered first owner is `bubbles.plan` for
BUG-020 because the Bash 3.2 startup abort prevents BUG-019's production row
from reaching Check 8. BUG-021's independent route to `bubbles.analyst` remains
explicit and unresolved; neither finding is absorbed into BUG-019.

#### Concurrent Foreign-Byte Addendum

**Phase:** implement
**Claim Source:** executed

During final protected-byte validation, `framework-validate.sh` changed outside
this invocation from SHA-256
`189358ad65cda1f97593e4c7999f27e1c80ebc4ef5be1d1077c295001a7bf76d` to
`9abe15cb28f224f0fbcd45c44ca17013c1ecab2404c7d81fa4b4fd724f9a512f`.
The concurrent delta adds `portable-ok` pragmas above both raw `timeout` calls
and retains unrelated IMP-020 and BUG-013/018/019 registrations. This pass did
not create, modify, or revert that delta.

The exact BUG-019 portability command now exits `0` because the scanner honors
the new pragmas:

```text
== macOS portability guard -- scanning 5 file(s) ==
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

That scanner result does not resolve `TEST-019-004-PORTABILITY`. The declared
system-only macOS PATH still has neither provider, and the unchanged raw call
still fails:

```text
BASH_VERSION=3.2.57(1)-release
TIMEOUT_BIN=absent
GTIMEOUT_BIN=absent
RAW_TIMEOUT_CALL_BEGIN
/bin/bash: timeout: command not found
RAW_TIMEOUT_CALL_RC=127
SANITIZED_RAW_TIMEOUT_PROBE_RC=127
```

The new pragma rationale is therefore false for stock macOS: the startup shim
maps `gtimeout` only when optional coreutils is installed. BUG-021's closed
boundary explicitly forbids weakening the scanner or adding `portable-ok` to
conceal these calls, and its selected helper migration remains necessary.
`TEST-019-004-PORTABILITY` stays routed one-for-one to BUG-021, currently
`bubbles.analyst`; a lint-only green result is not accepted as runtime GREEN.

Post-concurrency protected hashes are:

```text
edfc310d3a5182c680bd1ef79a2115e7be22b030b6da37e8acfbcf6ff2efa00e  bubbles/scripts/fun-mode.sh
9abe15cb28f224f0fbcd45c44ca17013c1ecab2404c7d81fa4b4fd724f9a512f  bubbles/scripts/framework-validate.sh
ae8da0b141500d7711e14d5907992ef4436b683b02e86c296a6609f20c657af6  bubbles/release-manifest.json
801885ceea92919ba3e6870bd2809205ad1e415184c958c3bb86d80c5e13a9a0  improvements/BUG-020-state-transition-bash32-startup/state.json
00d087e419df0b2b7486c59cc2cd91847e2d1efbedecae3b8235a6245d671afb  improvements/BUG-021-framework-validate-raw-timeout/state.json
```
