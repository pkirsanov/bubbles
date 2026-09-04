#!/usr/bin/env bash
set -uo pipefail

# BUG-018 persistent production-path regression for Test Plan heading depth.
#
# Every case builds a complete disposable feature packet and invokes the real
# traceability guard. The test contains no copy of the production extractor.
# The missing, rowless, boundary, and no-scenario cases are adversarial: they
# fail if BUG-018 returns or if expected no-match status exits the guard early.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GUARD="$REPO_ROOT/bubbles/scripts/traceability-guard.sh"

if [[ ! -f "$GUARD" ]]; then
  printf 'test_25_traceability_test_plan_heading_depth: required guard missing: %s\n' "$GUARD" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug018-XXXXXXXX")"
RUN_OUTPUT=""
RUN_STATUS=0
RUN_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT INT TERM

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

assert_status() {
  local expected="$1"
  local label="$2"

  if [[ "$RUN_STATUS" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected exit $expected, got $RUN_STATUS)"
  fi
}

assert_nonzero_status() {
  local label="$1"

  if [[ "$RUN_STATUS" -ne 0 ]]; then
    pass "$label"
  else
    fail "$label (expected nonzero exit, got 0)"
  fi
}

assert_contains() {
  local expected="$1"
  local label="$2"

  if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$expected"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_not_contains() {
  local forbidden="$1"
  local label="$2"

  if printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$forbidden"; then
    fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

assert_occurrences() {
  local expected="$1"
  local needle="$2"
  local label="$3"
  local actual

  actual="$(printf '%s\n' "$RUN_OUTPUT" | grep -Fc -- "$needle")"
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected $expected occurrence(s), got $actual: $needle)"
  fi
}

assert_equal() {
  local expected="$1"
  local actual="$2"
  local label="$3"

  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label"
    printf '  expected: %s\n' "$expected" >&2
    printf '  actual:   %s\n' "$actual" >&2
  fi
}

run_guard() {
  local feature_dir="$1"
  local label="$2"
  local output_file

  RUN_COUNT=$((RUN_COUNT + 1))
  output_file="$WORKSPACE/run-${RUN_COUNT}.log"
  RUN_STATUS=0
  if bash "$GUARD" "$feature_dir" >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "--- $label production output ---"
  printf '%s\n' "$RUN_OUTPUT"
  printf '%s\n' "--- $label exit=$RUN_STATUS ---"
}

run_guard_from_root() {
  local repo_root="$1"
  local feature_path="$2"
  local label="$3"
  local output_file

  RUN_COUNT=$((RUN_COUNT + 1))
  output_file="$WORKSPACE/run-${RUN_COUNT}.log"
  RUN_STATUS=0
  if (
    cd "$repo_root" || exit 2
    bash "$GUARD" "$feature_path"
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "--- $label production output ---"
  printf '%s\n' "$RUN_OUTPUT"
  printf '%s\n' "--- $label exit=$RUN_STATUS ---"
}

run_guard_with_system_bash() {
  local feature_dir="$1"
  local label="$2"
  local output_file

  RUN_COUNT=$((RUN_COUNT + 1))
  output_file="$WORKSPACE/run-${RUN_COUNT}.log"
  RUN_STATUS=0
  if /usr/bin/env -i \
    HOME="$HOME" \
    PATH="/usr/bin:/bin:/usr/sbin:/sbin" \
    /bin/bash "$GUARD" "$feature_dir" >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "--- $label production output ---"
  printf 'SYSTEM_BASH_VERSION=%s\n' "$(/bin/bash -c 'printf "%s" "$BASH_VERSION"')"
  printf '%s\n' "$RUN_OUTPUT"
  printf '%s\n' "--- $label exit=$RUN_STATUS ---"
}

run_guard_with_parser_failure() {
  local feature_dir="$1"
  local label="$2"
  local output_file
  local shim_dir="$WORKSPACE/parser-failure-bin"
  local real_python

  real_python="$(command -v python3)"
  mkdir -p "$shim_dir"
  cat > "$shim_dir/python3" <<'SHIM'
#!/usr/bin/env bash
set -u

: "${BUG018_REAL_PYTHON:?missing real python path}"
if [[ "${1:-}" == "-" && "${2:-}" == */scope.md ]]; then
  exit 42
fi
exec "$BUG018_REAL_PYTHON" "$@"
SHIM
  chmod +x "$shim_dir/python3"

  RUN_COUNT=$((RUN_COUNT + 1))
  output_file="$WORKSPACE/run-${RUN_COUNT}.log"
  RUN_STATUS=0
  if PATH="$shim_dir:$PATH" BUG018_REAL_PYTHON="$real_python" \
    bash "$GUARD" "$feature_dir" >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "--- $label production output ---"
  printf '%s\n' "$RUN_OUTPUT"
  printf '%s\n' "--- $label exit=$RUN_STATUS ---"
}

run_guard_with_identity_mode_operation() {
  local feature_dir="$1"
  local label="$2"
  local target="$3"
  local operation="$4"
  local output_file
  local shim_dir="$WORKSPACE/identity-rewrite-bin"
  local real_python

  real_python="$(command -v python3)"
  mkdir -p "$shim_dir"
  cat > "$shim_dir/python3" <<'SHIM'
#!/usr/bin/env bash
set -u
: "${IDENTITY_REAL_PYTHON:?missing real python path}"
: "${IDENTITY_TARGET:?missing rewrite target}"
: "${IDENTITY_OPERATION:?missing identity operation}"
capture="$(mktemp)"
trap 'rm -f "$capture"' EXIT INT TERM
status=0
"$IDENTITY_REAL_PYTHON" "$@" >"$capture" || status=$?
if [[ "$status" -eq 0 && "${1:-}" == "-" && "${4:-}" == "tests/traceability-heading.e2e.sh" ]]; then
  current_mode="$(stat -c '%a' "$IDENTITY_TARGET" 2>/dev/null || stat -f '%Lp' "$IDENTITY_TARGET")"
  if [[ "$IDENTITY_OPERATION" == "change" ]]; then chmod 600 "$IDENTITY_TARGET"; else chmod "$current_mode" "$IDENTITY_TARGET"; fi
fi
cat "$capture"
exit "$status"
SHIM
  chmod +x "$shim_dir/python3"

  RUN_COUNT=$((RUN_COUNT + 1))
  output_file="$WORKSPACE/run-${RUN_COUNT}.log"
  RUN_STATUS=0
  if PATH="$shim_dir:$PATH" IDENTITY_REAL_PYTHON="$real_python" IDENTITY_TARGET="$target" IDENTITY_OPERATION="$operation" \
    bash "$GUARD" "$feature_dir" >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "--- $label production output ---"
  printf '%s\n' "$RUN_OUTPUT"
  printf '%s\n' "--- $label exit=$RUN_STATUS ---"
}

write_feature_scaffold() {
  local feature_dir="$1"
  local scenario_manifest="$2"
  local scope_report="$feature_dir/scopes/01-heading/report.md"

  mkdir -p "$feature_dir/scopes/01-heading/tests"

  cat > "$feature_dir/spec.md" <<'MARKDOWN'
# BUG-018 Fixture Spec
MARKDOWN

  cat > "$feature_dir/design.md" <<'MARKDOWN'
# BUG-018 Fixture Design
MARKDOWN

  cat > "$feature_dir/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "scopeLayout": "per-scope-directory"
}
JSON

  cat > "$feature_dir/scopes/01-heading/tests/traceability-heading.e2e.sh" <<'SHELL'
#!/usr/bin/env bash
exit 0
SHELL

  cat > "$scope_report" <<'MARKDOWN'
# Fixture Report

## Test Evidence

Production-path evidence references `tests/traceability-heading.e2e.sh`.
MARKDOWN

  printf '%s\n' "$scenario_manifest" > "$feature_dir/scenario-manifest.json"
}

build_equivalent_feature() {
  local feature_dir="$1"
  local test_plan_heading="$2"
  local scenario_manifest

  scenario_manifest='{
  "schemaVersion": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-BUG018-LEVEL-01",
      "linkedTests": [{"file": "scopes/01-heading/tests/traceability-heading.e2e.sh"}],
      "evidenceRefs": ["scopes/01-heading/report.md#test-evidence"]
    },
    {
      "scenarioId": "SCN-BUG018-LEVEL-02",
      "linkedTests": [{"file": "scopes/01-heading/tests/traceability-heading.e2e.sh"}],
      "evidenceRefs": ["scopes/01-heading/report.md#test-evidence"]
    }
  ]
}'
  write_feature_scaffold "$feature_dir" "$scenario_manifest"

  cat > "$feature_dir/scopes/01-heading/scope.md" <<MARKDOWN
# Scope 01: Heading Equivalence

**Status:** In Progress

### Gherkin Scenarios

Scenario: SCN-BUG018-LEVEL-01 alpha heading maps normally
  Given an exact Test Plan heading
  When traceability runs
  Then alpha maps to a concrete test row

Scenario: SCN-BUG018-LEVEL-02 beta heading maps normally
  Given an exact Test Plan heading
  When traceability runs
  Then beta maps to a concrete test row

$test_plan_heading

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| regression E2E | T-LEVEL-A | SCN-BUG018-LEVEL-01 | tests/traceability-heading.e2e.sh | alpha heading maps normally |
| regression E2E | T-LEVEL-B | SCN-BUG018-LEVEL-02 | tests/traceability-heading.e2e.sh | beta heading maps normally |

### Definition of Done

- [ ] SCN-BUG018-LEVEL-01 alpha heading maps normally
- [ ] SCN-BUG018-LEVEL-02 beta heading maps normally
MARKDOWN
}

build_invalid_feature() {
  local feature_dir="$1"
  local test_plan_content="$2"
  local scenario_manifest

  scenario_manifest='{
  "schemaVersion": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-BUG018-INVALID-01",
      "linkedTests": [{"file": "scopes/01-heading/tests/traceability-heading.e2e.sh"}],
      "evidenceRefs": ["scopes/01-heading/report.md#test-evidence"]
    }
  ]
}'
  write_feature_scaffold "$feature_dir" "$scenario_manifest"

  cat > "$feature_dir/scopes/01-heading/scope.md" <<MARKDOWN
# Scope 01: Invalid Test Plan

**Status:** In Progress

### Gherkin Scenarios

Scenario: SCN-BUG018-INVALID-01 invalid Test Plan input fails with a diagnostic
  Given malformed planning input
  When traceability runs
  Then it reaches the normal summary

$test_plan_content

### Definition of Done

- [ ] SCN-BUG018-INVALID-01 invalid Test Plan input fails with a diagnostic
MARKDOWN
}

build_false_heading_feature() {
  local feature_dir="$1"
  local scenario_manifest

  scenario_manifest='{
  "schemaVersion": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-BUG018-FALSE-01",
      "linkedTests": [{"file": "scopes/01-heading/tests/traceability-heading.e2e.sh"}],
      "evidenceRefs": ["scopes/01-heading/report.md#test-evidence"]
    }
  ]
}'
  write_feature_scaffold "$feature_dir" "$scenario_manifest"

  cat > "$feature_dir/scopes/01-heading/scope.md" <<'MARKDOWN'
# Scope 01: False Test Plan Headings

**Status:** In Progress

### Gherkin Scenarios

Scenario: SCN-BUG018-FALSE-01 unsupported headings remain unrecognized
  Given only unsupported Test Plan lookalikes
  When traceability runs
  Then it reports a missing exact section

#### Test Plan

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| regression E2E | T-DEPTH-FOUR | SCN-BUG018-FALSE-01 | tests/traceability-heading.e2e.sh | depth four is unsupported |

### Test Planning

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| regression E2E | T-PLANNING | SCN-BUG018-FALSE-01 | tests/traceability-heading.e2e.sh | Test Planning is not Test Plan |

```text
## Test Plan
| regression E2E | T-FENCED | SCN-BUG018-FALSE-01 | tests/traceability-heading.e2e.sh | fenced heading is inert |
```

<!--
### Test Plan
| regression E2E | T-COMMENTED | SCN-BUG018-FALSE-01 | tests/traceability-heading.e2e.sh | commented heading is inert |
-->

### Definition of Done

- [ ] SCN-BUG018-FALSE-01 unsupported headings remain unrecognized
MARKDOWN
}

build_boundary_feature() {
  local feature_dir="$1"
  local test_plan_heading="$2"
  local nested_heading="$3"
  local sibling_heading="$4"
  local scenario_manifest

  scenario_manifest='{
  "schemaVersion": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-BUG018-BOUNDARY-01",
      "linkedTests": [{"file": "scopes/01-heading/tests/traceability-heading.e2e.sh"}],
      "evidenceRefs": ["scopes/01-heading/report.md#test-evidence"]
    }
  ]
}'
  write_feature_scaffold "$feature_dir" "$scenario_manifest"

  cat > "$feature_dir/scopes/01-heading/scope.md" <<MARKDOWN
# Scope 01: Heading Boundary

**Status:** In Progress

### Gherkin Scenarios

Scenario: SCN-BUG018-BOUNDARY-01 heading depth boundaries retain nested rows and exclude later siblings
  Given nested Test Plan content
  When traceability runs
  Then only the nested row remains eligible

$test_plan_heading

$nested_heading

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| adversarial regression E2E | T-NESTED | SCN-BUG018-BOUNDARY-01 | tests/traceability-heading.e2e.sh | nested row remains eligible |

$sibling_heading

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| adversarial regression E2E | T-MUST-NOT-LEAK | unrelated sibling behavior | tests/should-not-leak.e2e.sh | later sibling row must be excluded |

#### Definition of Done

- [ ] SCN-BUG018-BOUNDARY-01 heading depth boundaries retain nested rows and exclude later siblings
MARKDOWN
}

build_no_scenario_feature() {
  local feature_dir="$1"

  write_feature_scaffold "$feature_dir" '{"schemaVersion": 1, "scenarios": []}'
  cat > "$feature_dir/scopes/01-heading/scope.md" <<'MARKDOWN'
# Scope 01: No Scenario

**Status:** In Progress

### Gherkin Scenarios

This scope intentionally contains no executable Scenario line.

### Test Plan

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| adversarial regression E2E | T-NO-SCENARIO | no scenario | tests/traceability-heading.e2e.sh | expected no-match reaches diagnostic |

### Definition of Done

- [ ] Expected no-scenario no-match reaches the explicit diagnostic and final summary
MARKDOWN
}

build_research_lab_shaped_feature() {
  local repo_root="$1"
  local feature_dir="$repo_root/specs/007-technical-analysis-decision-lab"
  local scope_dir="$feature_dir/scopes/01-capability-foundation"

  mkdir -p "$repo_root/tests" "$scope_dir"

  cat > "$repo_root/tests/technical-analysis-decision-lab.spec.mjs" <<'JAVASCRIPT'
export const canonicalResearchLabFixture = true;
JAVASCRIPT

  cat > "$feature_dir/spec.md" <<'MARKDOWN'
# Research Lab Fixture Spec
MARKDOWN

  cat > "$feature_dir/design.md" <<'MARKDOWN'
# Research Lab Fixture Design
MARKDOWN

  cat > "$feature_dir/state.json" <<'JSON'
{
  "version": 3,
  "status": "in_progress",
  "scopeLayout": "per-scope-directory"
}
JSON

  cat > "$feature_dir/scenario-manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "scenarios": [
    {
      "scenarioId": "SCN-BUG018-RESEARCH-01",
      "linkedTests": [{"file": "tests/technical-analysis-decision-lab.spec.mjs"}],
      "evidenceRefs": ["scopes/01-capability-foundation/report.md#test-evidence"]
    }
  ]
}
JSON

  cat > "$scope_dir/scope.md" <<'MARKDOWN'
# Scope 01: Capability Foundation

**Status:** In Progress

### Gherkin Scenarios

Scenario: SCN-BUG018-RESEARCH-01 canonical source resolves owner-root linked test
  Given a Research-Lab-shaped packet with an owner-root test path
  When the canonical source guard runs from the owning repository root
  Then traceability resolves the packet and linked test inside that checkout

## Test Plan

| Test Type | Test ID | Scenario | File / Location | Exact behavior |
| --- | --- | --- | --- | --- |
| regression E2E | T-RESEARCH-LAB | SCN-BUG018-RESEARCH-01 | tests/technical-analysis-decision-lab.spec.mjs | canonical source resolves owner-root linked test |

### Definition of Done

- [ ] SCN-BUG018-RESEARCH-01 canonical source resolves owner-root linked test
MARKDOWN

  cat > "$scope_dir/report.md" <<'MARKDOWN'
# Research Lab Fixture Report

## Test Evidence

Canonical fixture evidence references `tests/technical-analysis-decision-lab.spec.mjs`.
MARKDOWN
}

mapping_set() {
  printf '%s\n' "$1" \
    | grep -F 'scenario mapped to Test Plan row:' \
    | sed -E 's/^.*scenario mapped to Test Plan row:[[:space:]]*//' \
    | LC_ALL=C sort
}

printf '%s\n' '=== T-BUG-018-01 Regression: level-2 Test Plan maps every scenario ==='
LEVEL2_FEATURE="$WORKSPACE/level-2"
build_equivalent_feature "$LEVEL2_FEATURE" '## Test Plan'
run_guard "$LEVEL2_FEATURE" 'T-BUG-018-01 level-2'
assert_status 0 'level-2 packet exits zero'
assert_contains 'scenario mapped to Test Plan row: SCN-BUG018-LEVEL-01 alpha heading maps normally' 'level-2 maps alpha'
assert_contains 'scenario mapped to Test Plan row: SCN-BUG018-LEVEL-02 beta heading maps normally' 'level-2 maps beta'
assert_contains 'RESULT: PASSED (0 warnings)' 'level-2 reaches successful final summary'
assert_not_contains 'has no recognized Test Plan section' 'level-2 is not reported missing'
LEVEL2_OUTPUT="$RUN_OUTPUT"
if LEVEL2_MAPPING_SET="$(mapping_set "$LEVEL2_OUTPUT")"; then
  :
else
  LEVEL2_MAPPING_SET=""
fi

printf '%s\n' '=== T-BUG-018-02 Regression: level-3 Test Plan preserves the level-2 mapping set ==='
LEVEL3_FEATURE="$WORKSPACE/level-3"
build_equivalent_feature "$LEVEL3_FEATURE" '### Test Plan'
run_guard "$LEVEL3_FEATURE" 'T-BUG-018-02 level-3'
assert_status 0 'level-3 packet exits zero'
assert_contains 'RESULT: PASSED (0 warnings)' 'level-3 reaches successful final summary'
LEVEL3_OUTPUT="$RUN_OUTPUT"
if LEVEL3_MAPPING_SET="$(mapping_set "$LEVEL3_OUTPUT")"; then
  :
else
  LEVEL3_MAPPING_SET=""
fi
assert_equal "$LEVEL2_MAPPING_SET" "$LEVEL3_MAPPING_SET" 'level-2 and level-3 mapping sets are equal'
assert_equal '2' "$(printf '%s\n' "$LEVEL3_MAPPING_SET" | grep -c 'SCN-BUG018-LEVEL-')" 'equivalent mapping set contains both scenarios'

printf '%s\n' '=== T-BUG-018-03 Regression: missing exact Test Plan heading reports once and reaches final summary ==='
MISSING_FEATURE="$WORKSPACE/missing-heading"
build_invalid_feature "$MISSING_FEATURE" 'This scope has no Test Plan heading.'
run_guard "$MISSING_FEATURE" 'T-BUG-018-03 missing heading'
assert_nonzero_status 'missing heading exits nonzero'
assert_occurrences 1 'has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan)' 'missing heading reports the exact diagnostic once'
assert_not_contains 'has no concrete Test Plan rows to trace' 'missing heading is not misreported as rowless'
assert_contains '--- Traceability Summary ---' 'missing heading reaches traceability summary'
assert_contains 'RESULT: FAILED (' 'missing heading reaches final failed summary'

FALSE_HEADING_FEATURE="$WORKSPACE/false-headings"
build_false_heading_feature "$FALSE_HEADING_FEATURE"
run_guard "$FALSE_HEADING_FEATURE" 'T-BUG-018-03 unsupported headings'
assert_nonzero_status 'unsupported heading packet exits nonzero'
assert_occurrences 1 'has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan)' 'depth-four, Test Planning, fenced, and commented headings remain unrecognized'
assert_contains 'RESULT: FAILED (' 'unsupported heading packet reaches final failed summary'

printf '%s\n' '=== T-BUG-018-15 Regression: duplicate visible exact Test Plan sections fail closed ==='
DUPLICATE_SECTION_FEATURE="$WORKSPACE/duplicate-visible-sections"
build_equivalent_feature "$DUPLICATE_SECTION_FEATURE" '## Test Plan'
cat >>"$DUPLICATE_SECTION_FEATURE/scopes/01-heading/scope.md" <<'MARKDOWN'

### Test Plan

| Test Type | File / Location | Exact behavior |
| --- | --- | --- |
| regression E2E | tests/traceability-heading.e2e.sh | duplicate visible section is ambiguous |
MARKDOWN
run_guard "$DUPLICATE_SECTION_FEATURE" 'T-BUG-018-15 duplicate visible sections'
assert_nonzero_status 'duplicate visible level-2/level-3 sections exit nonzero'
assert_occurrences 1 'has multiple visible exact Test Plan sections; exactly one ## Test Plan or ### Test Plan is applicable' 'duplicate visible sections report structural ambiguity once'

printf '%s\n' '=== T-BUG-018-16 Regression: fenced, commented, and depth-four headings do not count as duplicates ==='
HIDDEN_DUPLICATE_FEATURE="$WORKSPACE/hidden-duplicate-sections"
build_equivalent_feature "$HIDDEN_DUPLICATE_FEATURE" '## Test Plan'
cat >>"$HIDDEN_DUPLICATE_FEATURE/scopes/01-heading/scope.md" <<'MARKDOWN'

```markdown
### Test Plan
```

<!--
## Test Plan
-->

#### Test Plan
MARKDOWN
run_guard "$HIDDEN_DUPLICATE_FEATURE" 'T-BUG-018-16 hidden duplicate lookalikes'
assert_status 0 'fenced, commented, and depth-four headings leave exactly one applicable Test Plan'
assert_not_contains 'multiple visible exact Test Plan sections' 'hidden duplicate lookalikes remain non-counting'

printf '%s\n' '=== T-BUG-018-04 Regression: recognized empty, header-only, and separator-only Test Plans report rowless and reach final summary ==='
EMPTY_FEATURE="$WORKSPACE/empty-section"
build_invalid_feature "$EMPTY_FEATURE" '### Test Plan'
run_guard "$EMPTY_FEATURE" 'T-BUG-018-04 empty section'
assert_nonzero_status 'empty recognized section exits nonzero'
assert_occurrences 1 'has no concrete Test Plan rows to trace' 'empty recognized section reports rowless once'
assert_not_contains 'has no recognized Test Plan section' 'empty recognized section is not reported missing'
assert_contains 'RESULT: FAILED (' 'empty recognized section reaches final summary'

SEPARATOR_FEATURE="$WORKSPACE/separator-only"
build_invalid_feature "$SEPARATOR_FEATURE" $'### Test Plan\n\n| --- | --- | --- |'
run_guard "$SEPARATOR_FEATURE" 'T-BUG-018-04 separator-only section'
assert_nonzero_status 'separator-only recognized section exits nonzero'
assert_occurrences 1 'has no concrete Test Plan rows to trace' 'separator-only section reports rowless once'
assert_contains 'RESULT: FAILED (' 'separator-only section reaches final summary'

HEADER_FEATURE="$WORKSPACE/header-only"
build_invalid_feature "$HEADER_FEATURE" $'### Test Plan\n\n| Test Type | Test ID | File / Location |\n| --- | --- | --- |'
run_guard "$HEADER_FEATURE" 'T-BUG-018-04 header-only section'
assert_nonzero_status 'header-only recognized section exits nonzero'
assert_occurrences 1 'has no concrete Test Plan rows to trace' 'header-only section reports rowless once'
assert_contains 'RESULT: FAILED (' 'header-only section reaches final summary'

run_guard_with_parser_failure "$LEVEL3_FEATURE" 'T-BUG-018-04 extractor failure'
assert_nonzero_status 'extractor failure exits nonzero'
assert_occurrences 1 'Test Plan extraction failed' 'extractor failure reports its distinct diagnostic once'
assert_not_contains 'has no recognized Test Plan section' 'extractor failure is not reported missing'
assert_not_contains 'has no concrete Test Plan rows to trace' 'extractor failure is not reported rowless'
assert_contains 'RESULT: FAILED (' 'extractor failure reaches final summary'

printf '%s\n' '=== T-BUG-018-08 Regression: required Test Plan headers may be reordered ==='
REORDERED_FEATURE="$WORKSPACE/reordered-headers"
build_invalid_feature "$REORDERED_FEATURE" $'### Test Plan\n\n| Exact behavior | File / Location | Scenario | Test Type |\n| --- | --- | --- | --- |\n| invalid Test Plan input fails with a diagnostic | tests/traceability-heading.e2e.sh | SCN-BUG018-INVALID-01 | regression E2E |'
run_guard "$REORDERED_FEATURE" 'T-BUG-018-08 reordered headers'
assert_status 0 'reordered required headers exit zero'
assert_contains 'scenario maps to concrete test file: scopes/01-heading/tests/traceability-heading.e2e.sh' 'reordered File/Location column owns the concrete path'

printf '%s\n' '=== T-BUG-018-09 Regression: duplicate required headers fail closed ==='
DUPLICATE_FEATURE="$WORKSPACE/duplicate-headers"
build_invalid_feature "$DUPLICATE_FEATURE" $'### Test Plan\n\n| Test Type | File / Location | Test Type | Exact behavior |\n| --- | --- | --- | --- |\n| regression E2E | tests/traceability-heading.e2e.sh | e2e-ui | invalid Test Plan input fails with a diagnostic |'
run_guard "$DUPLICATE_FEATURE" 'T-BUG-018-09 duplicate headers'
assert_nonzero_status 'duplicate required header exits nonzero'
assert_occurrences 1 'Test Plan extraction failed' 'duplicate required header reports extraction failure once'

printf '%s\n' '=== T-BUG-018-10 Regression: unrelated tables inside Test Plan are ignored ==='
UNRELATED_FEATURE="$WORKSPACE/unrelated-table"
build_invalid_feature "$UNRELATED_FEATURE" $'### Test Plan\n\n| Owner | Review State |\n| --- | --- |\n| test-team | ready |\n\n| Exact behavior | File / Location | Test Type |\n| --- | --- | --- |\n| invalid Test Plan input fails with a diagnostic | tests/traceability-heading.e2e.sh | regression E2E |'
run_guard "$UNRELATED_FEATURE" 'T-BUG-018-10 unrelated table'
assert_status 0 'unrelated table before valid Test Plan table exits zero'
assert_contains 'summary: scenarios=1 test_rows=1' 'unrelated table contributes no concrete test row'

printf '%s\n' '=== T-BUG-018-13 Regression: escaped pipes and code spans preserve Test Plan cells ==='
ESCAPED_PIPE_FEATURE="$WORKSPACE/escaped-pipe-code-span"
build_invalid_feature "$ESCAPED_PIPE_FEATURE" $'### Test Plan\n\n| Exact behavior | File / Location | Test Type |\n| --- | --- | --- |\n| invalid Test Plan input fails with a diagnostic and preserves alpha \\| beta | `tests/traceability-heading.e2e.sh` | regression E2E |'
run_guard "$ESCAPED_PIPE_FEATURE" 'T-BUG-018-13 escaped pipe and code span'
assert_status 0 'escaped pipe and code-span packet exits zero'
assert_contains 'scenario maps to concrete test file: scopes/01-heading/tests/traceability-heading.e2e.sh' 'code-span path resolves without escaped-pipe column drift'
assert_contains 'summary: scenarios=1 test_rows=1' 'escaped pipe remains in one Test Plan row'

printf '%s\n' '=== T-BUG-018-14 Regression: permission-mode identity is revalidated ==='
IDENTITY_FEATURE="$WORKSPACE/identity-in-place-rewrite"
build_invalid_feature "$IDENTITY_FEATURE" $'### Test Plan\n\n| Exact behavior | File / Location | Test Type |\n| --- | --- | --- |\n| invalid Test Plan input fails with a diagnostic | tests/traceability-heading.e2e.sh | regression E2E |'
run_guard_with_identity_mode_operation "$IDENTITY_FEATURE" 'T-BUG-018-14 chmod-only identity change' "$IDENTITY_FEATURE/scopes/01-heading/tests/traceability-heading.e2e.sh" change
if [[ "$RUN_STATUS" -ne 0 ]] && printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- 'mapped test file identity changed before evidence use'; then
  pass 'mode/device/inode/size/mtime identity detects chmod-only mutation and exits nonzero'
else
  fail 'mode/device/inode/size/mtime identity did not reject chmod-only mutation'
fi
chmod 644 "$IDENTITY_FEATURE/scopes/01-heading/tests/traceability-heading.e2e.sh"
run_guard_with_identity_mode_operation "$IDENTITY_FEATURE" 'T-BUG-018-14 unchanged-mode positive' "$IDENTITY_FEATURE/scopes/01-heading/tests/traceability-heading.e2e.sh" same
assert_status 0 'unchanged-mode operation remains accepted'

printf '%s\n' '=== T-BUG-018-11 Regression: Command cannot substitute for File/Location ==='
COMMAND_ONLY_FEATURE="$WORKSPACE/command-only-path"
build_invalid_feature "$COMMAND_ONLY_FEATURE" $'### Test Plan\n\n| Test Type | Scenario | Command | Exact behavior |\n| --- | --- | --- | --- |\n| regression E2E | SCN-BUG018-INVALID-01 | bubbles/scripts/traceability-guard.sh | invalid Test Plan input fails with a diagnostic |'
run_guard "$COMMAND_ONLY_FEATURE" 'T-BUG-018-11 command column isolation'
assert_nonzero_status 'missing File/Location path exits nonzero even when Command exists'
assert_contains 'Test Plan extraction failed' 'missing File/Location header is diagnosed'
assert_not_contains 'scenario maps to concrete test file: bubbles/scripts/traceability-guard.sh' 'Command path never impersonates the test file'

printf '%s\n' '=== T-BUG-018-05 Regression: heading-depth boundaries retain nested rows and exclude later siblings ==='
BOUNDARY2_FEATURE="$WORKSPACE/boundary-level-2"
build_boundary_feature "$BOUNDARY2_FEATURE" '## Test Plan' '### Nested Cases' '## Later Same-Depth Section'
run_guard "$BOUNDARY2_FEATURE" 'T-BUG-018-05 level-2 boundary'
assert_status 0 'level-2 boundary packet exits zero'
assert_contains 'scenario mapped to Test Plan row: SCN-BUG018-BOUNDARY-01 heading depth boundaries retain nested rows and exclude later siblings' 'level-2 nested row remains eligible'
assert_contains 'summary: scenarios=1 test_rows=1' 'level-2 later same-depth sibling row is excluded'
assert_not_contains 'should-not-leak.e2e.sh' 'level-2 sibling path never reaches a diagnostic'

BOUNDARY3_FEATURE="$WORKSPACE/boundary-level-3"
build_boundary_feature "$BOUNDARY3_FEATURE" '### Test Plan' '#### Nested Cases' '### Later Same-Depth Section'
run_guard "$BOUNDARY3_FEATURE" 'T-BUG-018-05 level-3 boundary'
assert_status 0 'level-3 boundary packet exits zero'
assert_contains 'scenario mapped to Test Plan row: SCN-BUG018-BOUNDARY-01 heading depth boundaries retain nested rows and exclude later siblings' 'level-3 nested row remains eligible'
assert_contains 'summary: scenarios=1 test_rows=1' 'level-3 later same-depth sibling row is excluded'
assert_not_contains 'should-not-leak.e2e.sh' 'level-3 sibling path never reaches a diagnostic'

printf '%s\n' '=== T-BUG-018-06 Regression: expected no-scenario no-match reaches the explicit diagnostic and final summary ==='
NO_SCENARIO_FEATURE="$WORKSPACE/no-scenario"
build_no_scenario_feature "$NO_SCENARIO_FEATURE"
run_guard "$NO_SCENARIO_FEATURE" 'T-BUG-018-06 no scenario'
assert_nonzero_status 'no-scenario packet exits nonzero'
assert_occurrences 1 'has no Gherkin scenarios to trace' 'no-scenario packet reports its explicit diagnostic once'
assert_contains '--- Traceability Summary ---' 'no-scenario packet reaches traceability summary'
assert_contains 'RESULT: FAILED (' 'no-scenario packet reaches final failed summary'

printf '%s\n' '=== T-BUG-018-07 Regression: Bash 3.2 starts with optional fun mode disabled ==='
run_guard_with_system_bash "$LEVEL3_FEATURE" 'T-BUG-018-07 system Bash'
assert_status 0 'system Bash runs the production guard successfully'
assert_contains 'RESULT: PASSED (0 warnings)' 'system Bash reaches the normal final summary'
assert_not_contains 'associative array' 'system Bash does not load unsupported optional fun-mode state'
assert_not_contains 'unbound variable' 'system Bash has no optional fun-mode startup failure'

printf '%s\n' '=== T-BUG-018-12 Canonical production behavior: disposable Research-Lab-shaped packet resolves inside its owned fixture ==='
RESEARCH_LAB_ROOT="$WORKSPACE/research-lab"
RESEARCH_LAB_FEATURE='specs/007-technical-analysis-decision-lab'
build_research_lab_shaped_feature "$RESEARCH_LAB_ROOT"
RESEARCH_LAB_ROOT="$(cd "$RESEARCH_LAB_ROOT" && pwd)"
run_guard_from_root "$RESEARCH_LAB_ROOT" "$RESEARCH_LAB_FEATURE" 'T-BUG-018-12 Research Lab fixture'
assert_status 0 'Research-Lab-shaped packet exits zero'
assert_contains "Feature: $RESEARCH_LAB_ROOT/$RESEARCH_LAB_FEATURE" 'relative feature path resolves inside the fixture owner root'
assert_contains 'scenario mapped to Test Plan row: SCN-BUG018-RESEARCH-01 canonical source resolves owner-root linked test' 'Research Lab scenario maps through canonical source'
assert_contains 'scenario maps to concrete test file: tests/technical-analysis-decision-lab.spec.mjs' 'owner-root linked test resolves inside the fixture'
assert_contains 'report references concrete test evidence: tests/technical-analysis-decision-lab.spec.mjs' 'fixture report binds owner-root test evidence'
assert_contains 'RESULT: PASSED (0 warnings)' 'Research-Lab-shaped packet reaches successful final summary'
assert_not_contains 'references missing linked test file' 'Research-Lab-shaped packet has no cross-root path failure'

printf '%s\n' '=== BUG-018 regression summary ==='
printf 'test_25_traceability_test_plan_heading_depth: %s passed, %s failed\n' "$PASS_COUNT" "$FAIL_COUNT"
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi

printf '%s\n' 'BUG018_GREEN_REGRESSION=HEADING_AWARE_TRACEABILITY_SATISFIED'