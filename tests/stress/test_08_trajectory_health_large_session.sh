#!/usr/bin/env bash
set -euo pipefail

# Stress check for SCOPE-8 trajectory-inspector health mode.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RETRO_HEALTH="$REPO_ROOT/bubbles/scripts/retro-convergence-health.sh"
INSPECTOR="$REPO_ROOT/bubbles/scripts/trajectory-inspector.sh"
SPEC_DIR="specs/900-fixture-trajectory-health"

if [[ ! -f "$RETRO_HEALTH" ]]; then
  echo "test_08_trajectory_health_large_session: missing $RETRO_HEALTH" >&2
  exit 2
fi

if [[ ! -f "$INSPECTOR" ]]; then
  echo "test_08_trajectory_health_large_session: missing $INSPECTOR" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-scope8-trajectory-health-stress-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

repo="$WORKSPACE/repo"
mkdir -p "$repo/.specify/memory"
session="$repo/.specify/memory/bubbles.session.json"
health_json="$WORKSPACE/convergence-health.json"

{
  printf '{\n'
  printf '  "sessionId": "scope-08-stress",\n'
  printf '  "convergenceLoops": [\n'
  first=1
  for index in $(seq 1 250); do
    if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
    first=0
    iteration=$(((index % 10) + 1))
    printf '    {"specDir":"%s","agent":"bubbles.workflow","iterationCount":%d,"lastIterationAt":"2026-05-24T10:00:00Z"}' "$SPEC_DIR" "$iteration"
  done
  printf '\n  ],\n'
  printf '  "envelopesReceived": [\n'
  first=1
  for index in $(seq 1 250); do
    if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
    first=0
    printf '    {"specDir":"%s","rawSizeBytes":%d,"compactedAt":"2026-05-24T10:00:00Z"}' "$SPEC_DIR" "$((900 + index))"
  done
  printf '\n  ],\n'
  printf '  "turnSnapshots": [\n'
  first=1
  for index in $(seq 1 1000); do
    if [[ "$first" -eq 0 ]]; then printf ',\n'; fi
    first=0
    printf '    {"specDir":"%s","turnNumber":%d,"startedAt":"2026-05-24T11:00:00Z","completedAt":"2026-05-24T11:01:00Z","content":"steady-state trajectory sample"}' "$SPEC_DIR" "$index"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$session"

bash "$RETRO_HEALTH" "$SPEC_DIR" --repo-root "$repo" --format json > "$health_json"

PASS_COUNT=0
FAIL_COUNT=0

echo "=== test_08_trajectory_health_large_session (SCOPE-8 stress) ==="
echo "Synthetic fixture: precomputed convergence-health JSON plus 1000-snapshot re-derive session"

run_number=1
while [[ "$run_number" -le 5 ]]; do
  start_ns="$(date +%s%N)"; [[ "$start_ns" =~ ^[0-9]+$ ]] || start_ns="$(( $(date +%s) * 1000000000 ))"
  set +e
  bash "$INSPECTOR" --health --input "$health_json" > "$WORKSPACE/input.out" 2> "$WORKSPACE/input.err"
  input_rc=$?
  bash "$INSPECTOR" --repo-root "$repo" --health --spec "$SPEC_DIR" > "$WORKSPACE/spec.out" 2> "$WORKSPACE/spec.err"
  spec_rc=$?
  set -e
  end_ns="$(date +%s%N)"; [[ "$end_ns" =~ ^[0-9]+$ ]] || end_ns="$(( $(date +%s) * 1000000000 ))"
  duration_ms=$(((end_ns - start_ns) / 1000000))

  if [[ "$input_rc" -eq 0 ]] \
    && [[ "$spec_rc" -eq 0 ]] \
    && grep -qF "Convergence Health:" "$WORKSPACE/input.out" \
    && grep -qF "turnCount=1000" "$WORKSPACE/input.out" \
    && grep -qF "status=HEALTHY" "$WORKSPACE/input.out" \
    && grep -qF "Convergence Health:" "$WORKSPACE/spec.out" \
    && grep -qF "turnCount=1000" "$WORKSPACE/spec.out" \
    && grep -qF "status=DEGRADED" "$WORKSPACE/spec.out" \
    && [[ "$duration_ms" -lt 5000 ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'PASS: run=%02d inputExit=%d specExit=%d durationMs=%d inputSummary=yes specSummary=yes\n' "$run_number" "$input_rc" "$spec_rc" "$duration_ms"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL: run=%02d inputExit=%d specExit=%d durationMs=%d\n' "$run_number" "$input_rc" "$spec_rc" "$duration_ms"
    cat "$WORKSPACE/input.err"
    cat "$WORKSPACE/input.out"
    cat "$WORKSPACE/spec.err"
    cat "$WORKSPACE/spec.out"
  fi

  run_number=$((run_number + 1))
done

echo "=== Stress verdict ==="
printf '  Passed runs: %d\n' "$PASS_COUNT"
printf '  Failed runs: %d\n' "$FAIL_COUNT"
printf '  Budget:      each input+rederive pair under 5000ms\n'

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_08_trajectory_health_large_session: FAILED" >&2
  exit 1
fi

echo "test_08_trajectory_health_large_session: PASSED"
exit 0