#!/usr/bin/env bash
# Focused framework-validation wiring contract for canonical scenario checks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/framework-validate.sh"
READER_SELFTEST="scenario-reference-reader-selftest.sh"
GENERATOR="$SCRIPT_DIR/generate-validation-checks.sh"

failures=0
pass() { printf 'PASS: %s\n' "$1"; }
fail() {
  printf 'FAIL: %s\n' "$1"
  failures=$((failures + 1))
}

if [[ ! -r "$VALIDATOR" || ! -r "$GENERATOR" ]]; then
  printf 'framework-validation-wiring-selftest: required validator/generator is not readable\n' >&2
  exit 2
fi

# Parse scheduled selftests with the same helper used by framework-validate's
# discovery sweep. Comments and incidental string mentions therefore cannot
# masquerade as an executable registration.
# shellcheck source=guard-lib.sh
source "$SCRIPT_DIR/guard-lib.sh"
validator_source="$(<"$VALIDATOR")"
scheduled="$(bubbles_scheduled_selftests "$validator_source")"
reader_count=0
while IFS= read -r scheduled_name; do
  [[ "$scheduled_name" == "$READER_SELFTEST" ]] || continue
  reader_count=$((reader_count + 1))
done <<<"$scheduled"

if [[ "$reader_count" -eq 1 ]]; then
  pass "reader selftest is scheduled exactly once"
else
  fail "reader selftest must be scheduled exactly once (observed $reader_count)"
fi

expected_registration='run_check "Scenario reference reader selftest (IMP-040 / COV-8)" bash "$SCRIPT_DIR/scenario-reference-reader-selftest.sh"'
if grep -Fxq "$expected_registration" "$VALIDATOR"; then
  pass "reader selftest uses the canonical unconditional run_check path"
else
  fail "reader selftest must use the canonical unconditional run_check path"
fi

while IFS='|' read -r selftest_name registration; do
  registration_count="$(grep -Fxc "$registration" "$VALIDATOR" || true)"
  if [[ "$registration_count" -eq 1 ]]; then
    pass "$selftest_name uses the canonical unconditional run_check path exactly once"
  else
    fail "$selftest_name must use the canonical unconditional run_check path exactly once (observed $registration_count)"
  fi
done <<'EOF'
scenario manifest v2 schema selftest|run_check "Scenario manifest v2 schema selftest (IMP-040 / COV-8)" bash "$SCRIPT_DIR/scenario-manifest-v2-schema-selftest.sh"
scenario manifest migration selftest|run_check "Scenario manifest migration selftest (IMP-040 / COV-8)" bash "$SCRIPT_DIR/scenario-manifest-migrate-selftest.sh"
YAML schema dispatch selftest|run_check "YAML schema dispatch selftest (IMP-040 / COV-8)" bash "$SCRIPT_DIR/yaml-schema-validate-selftest.sh"
framework validation wiring selftest|run_check "Framework validation wiring selftest (IMP-040 / COV-8)" bash "$SCRIPT_DIR/framework-validation-wiring-selftest.sh"
execution-control store selftest|run_check "Execution-control store selftest (IMP-054/055 / ECF-01)" bash "$SCRIPT_DIR/execution-control-selftest.sh"
EOF

resolver_line="$(grep -nFx 'run_check "Scenario linked-test resolution selftest (IMP-040 / COV-8)" bash "$SCRIPT_DIR/scenario-test-resolve-selftest.sh"' "$VALIDATOR" | cut -d: -f1)"
reader_line="$(grep -nFx "$expected_registration" "$VALIDATOR" | cut -d: -f1)"
if [[ -n "$resolver_line" && -n "$reader_line" ]] && (( reader_line == resolver_line + 1 )); then
  pass "reader selftest remains adjacent to scenario resolution"
else
  fail "reader selftest must remain immediately after scenario resolution"
fi

cr02_count=0
while IFS= read -r registration; do
  [[ "$registration" == *'run_check_self_only "CR-02 traceability current-scope universe regression"'* ]] || continue
  [[ "$registration" == *'tests/regression/test_33_traceability_current_scope_universe.sh'* ]] || continue
  cr02_count=$((cr02_count + 1))
done < <(awk '{ line=$0; sub(/^[ \t]+/, "", line); if (pending != "") { line=pending " " line; pending="" } if (line ~ /\\$/) { sub(/\\$/, "", line); pending=line; next } if (line ~ /^run_check(_self_only)?[ \t]/) print line }' "$VALIDATOR")
if [[ "$cr02_count" -eq 1 ]]; then
  pass "CR-02 regression is scheduled exactly once through run_check_self_only"
else
  fail "CR-02 regression must be scheduled exactly once through run_check_self_only (observed $cr02_count)"
fi

# Exercise the real validator and its production run_check/cache path in a
# bounded fixture. The focused probe exits before the normal schedule, so the
# registered wiring selftest cannot recursively invoke itself.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT INT TERM
FIXTURE="$WORK/repo"
mkdir -p "$FIXTURE/bubbles/scripts" "$FIXTURE/bubbles/registry" "$FIXTURE/tests/regression"
cp "$VALIDATOR" "$FIXTURE/bubbles/scripts/framework-validate.sh"
cp "$SCRIPT_DIR/guard-lib.sh" "$FIXTURE/bubbles/scripts/guard-lib.sh"
cp "$SCRIPT_DIR/validate-cache.sh" "$FIXTURE/bubbles/scripts/validate-cache.sh"
cp "$SCRIPT_DIR/validation-closure.sh" "$FIXTURE/bubbles/scripts/validation-closure.sh"
cp "$GENERATOR" "$FIXTURE/bubbles/scripts/generate-validation-checks.sh"
printf 'test-version\n' >"$FIXTURE/VERSION"

run_validator_probe() {
  (
    cd "$FIXTURE"
    BUBBLES_FRAMEWORK_VALIDATE_READER_PROBE=1 \
      BUBBLES_FRAMEWORK_VALIDATE_MODE=source \
      BUBBLES_VALIDATE_CACHE_DIR="$WORK/cache" \
      bash bubbles/scripts/framework-validate.sh "$@"
  )
}

run_cr02_probe() {
  (
    cd "$FIXTURE"
    BUBBLES_FRAMEWORK_VALIDATE_CR02_PROBE=1 \
      BUBBLES_FRAMEWORK_VALIDATE_MODE=source \
      BUBBLES_VALIDATE_CACHE_DIR="$WORK/cr02-cache" \
      bash bubbles/scripts/framework-validate.sh "$@"
  )
}

cat >"$FIXTURE/tests/regression/test_33_traceability_current_scope_universe.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'executed\n' >>"$BUBBLES_CR02_PROBE_COUNTER"
[[ "${BUBBLES_CR02_PROBE_FAIL:-0}" == "0" ]]
EOF
printf '' >"$WORK/cr02-executions"
export BUBBLES_CR02_PROBE_COUNTER="$WORK/cr02-executions"

cr02_failure_status=0
cr02_failure_output="$(BUBBLES_CR02_PROBE_FAIL=1 run_cr02_probe --no-cache 2>&1)" || cr02_failure_status=$?
if [[ "$cr02_failure_status" -eq 1 ]] && [[ "$cr02_failure_output" == *"FAIL: CR-02 traceability current-scope universe regression"* ]]; then
  pass "failing CR-02 regression blocks through the real validator path"
else
  fail "failing CR-02 regression must block the real validator path (exit=$cr02_failure_status)"
fi
printf '' >"$WORK/cr02-executions"

missing_status=0
missing_output="$(run_validator_probe --no-cache 2>&1)" || missing_status=$?
if [[ "$missing_status" -eq 1 ]] && [[ "$missing_output" == *"FAIL: Scenario reference reader selftest"* ]]; then
  pass "missing reader selftest fails through the real validator run_check path"
else
  fail "missing reader selftest must fail the real validator path (exit=$missing_status)"
fi

cat >"$FIXTURE/bubbles/scripts/scenario-reference-reader-selftest.sh" <<'EOF'
#!/usr/bin/env bash
exit 23
EOF
failing_status=0
failing_output="$(run_validator_probe --no-cache 2>&1)" || failing_status=$?
if [[ "$failing_status" -eq 1 ]] && [[ "$failing_output" == *"FAIL: Scenario reference reader selftest"* ]]; then
  pass "failing reader selftest fails through the real validator run_check path"
else
  fail "failing reader selftest must fail the real validator path (exit=$failing_status)"
fi

cat >"$FIXTURE/bubbles/scripts/scenario-reference-reader.py" <<'EOF'
import os

with open(os.environ["BUBBLES_READER_PROBE_COUNTER"], "a", encoding="utf-8") as counter:
    counter.write("executed\n")
EOF
cat >"$FIXTURE/bubbles/scripts/scenario-reference-reader-selftest.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/scenario-reference-reader.py"
EOF
printf '' >"$WORK/executions"
export BUBBLES_READER_PROBE_COUNTER="$WORK/executions"

generator_status=0
generator_output="$(bash "$FIXTURE/bubbles/scripts/generate-validation-checks.sh" --repo-root "$FIXTURE" 2>&1)" || generator_status=$?
if [[ "$generator_status" -eq 0 ]] \
  && grep -Fq 'script: bubbles/scripts/scenario-reference-reader-selftest.sh' "$FIXTURE/bubbles/registry/validation-checks.yaml" \
  && grep -Fq -- '- bubbles/scripts/scenario-reference-reader.py' "$FIXTURE/bubbles/registry/validation-checks.yaml" \
  && grep -Fq 'script: tests/regression/test_33_traceability_current_scope_universe.sh' "$FIXTURE/bubbles/registry/validation-checks.yaml"; then
  pass "fixture registry derives reader and CR-02 regression closures"
else
  fail "fixture registry must derive reader and CR-02 closures (exit=$generator_status output=$generator_output)"
fi

cr02_cold_output="$(run_cr02_probe --cache 2>&1)"
cr02_cold_status=$?
if [[ "$cr02_cold_status" -eq 0 ]] && [[ "$cr02_cold_output" == *"PASS: CR-02 traceability current-scope universe regression"* ]] \
  && [[ "$(wc -l <"$WORK/cr02-executions" | tr -d ' ')" -eq 1 ]]; then
  pass "CR-02 cache cold miss executes the regression exactly once"
else
  fail "CR-02 cache cold miss must execute exactly once (exit=$cr02_cold_status)"
fi

cr02_reuse_output="$(run_cr02_probe --cache 2>&1)"
cr02_reuse_status=$?
if [[ "$cr02_reuse_status" -eq 0 ]] && [[ "$cr02_reuse_output" == *"REUSED: CR-02 traceability current-scope universe regression"* ]] \
  && [[ "$(wc -l <"$WORK/cr02-executions" | tr -d ' ')" -eq 1 ]]; then
  pass "unchanged CR-02 registry closure reuses the cached result"
else
  fail "unchanged CR-02 closure must reuse without execution (exit=$cr02_reuse_status)"
fi

printf '\n# CR-02 cache invalidation\n' >>"$FIXTURE/tests/regression/test_33_traceability_current_scope_universe.sh"
cr02_change_output="$(run_cr02_probe --cache 2>&1)"
cr02_change_status=$?
if [[ "$cr02_change_status" -eq 0 ]] && [[ "$cr02_change_output" == *"PASS: CR-02 traceability current-scope universe regression"* ]] \
  && [[ "$(wc -l <"$WORK/cr02-executions" | tr -d ' ')" -eq 2 ]]; then
  pass "changing the CR-02 regression invalidates cached validation"
else
  fail "CR-02 regression change must invalidate cache (exit=$cr02_change_status)"
fi

cold_output="$(run_validator_probe --cache 2>&1)"
cold_status=$?
if [[ "$cold_status" -eq 0 ]] && [[ "$cold_output" == *"PASS: Scenario reference reader selftest"* ]] \
  && [[ "$(wc -l <"$WORK/executions" | tr -d ' ')" -eq 1 ]]; then
  pass "cache cold miss executes the reader selftest once and records PASS"
else
  fail "cache cold miss must execute exactly once (exit=$cold_status)"
fi

reuse_output="$(run_validator_probe --cache 2>&1)"
reuse_status=$?
if [[ "$reuse_status" -eq 0 ]] && [[ "$reuse_output" == *"REUSED: Scenario reference reader selftest"* ]] \
  && [[ "$(wc -l <"$WORK/executions" | tr -d ' ')" -eq 1 ]]; then
  pass "unchanged declared closure reuses the cached reader result without duplicate execution"
else
  fail "unchanged reader closure must reuse exactly once (exit=$reuse_status)"
fi

printf '\n# reader selftest cache invalidation\n' >>"$FIXTURE/bubbles/scripts/scenario-reference-reader-selftest.sh"
selftest_change_output="$(run_validator_probe --cache 2>&1)"
selftest_change_status=$?
if [[ "$selftest_change_status" -eq 0 ]] && [[ "$selftest_change_output" == *"PASS: Scenario reference reader selftest"* ]] \
  && [[ "$(wc -l <"$WORK/executions" | tr -d ' ')" -eq 2 ]]; then
  pass "changing the reader selftest invalidates cached validation"
else
  fail "reader selftest change must invalidate cache (exit=$selftest_change_status)"
fi

printf '\n# declared implementation input cache invalidation\n' >>"$FIXTURE/bubbles/scripts/scenario-reference-reader.py"
input_change_output="$(run_validator_probe --cache 2>&1)"
input_change_status=$?
if [[ "$input_change_status" -eq 0 ]] && [[ "$input_change_output" == *"PASS: Scenario reference reader selftest"* ]] \
  && [[ "$(wc -l <"$WORK/executions" | tr -d ' ')" -eq 3 ]]; then
  pass "changing the declared reader implementation invalidates cached validation"
else
  fail "declared reader implementation change must invalidate cache (exit=$input_change_status)"
fi

if [[ "$failures" -ne 0 ]]; then
  printf 'framework-validation-wiring-selftest: %s failure(s)\n' "$failures" >&2
  exit 1
fi

printf 'framework-validation-wiring-selftest: all checks passed\n'