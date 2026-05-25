#!/usr/bin/env bash
set -euo pipefail

# Stress check for SCOPE-7 retro convergence health large-session handling.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RETRO_HEALTH="$REPO_ROOT/bubbles/scripts/retro-convergence-health.sh"
SPEC_DIR="specs/900-fixture-retro-health"

if [[ ! -f "$RETRO_HEALTH" ]]; then
  echo "test_07_retro_convergence_health_large_session: missing $RETRO_HEALTH" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "test_07_retro_convergence_health_large_session: jq is required" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-scope7-retro-health-stress-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

repo="$WORKSPACE/repo"
mkdir -p "$repo/.specify/memory"
session="$repo/.specify/memory/bubbles.session.json"

{
  printf '{\n'
  printf '  "sessionId": "scope-07-stress",\n'
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
    printf '    {"specDir":"%s","turnNumber":%d,"startedAt":"2026-05-24T11:00:00Z","completedAt":"2026-05-24T11:01:00Z","content":"steady-state validation sample"}' "$SPEC_DIR" "$index"
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$session"

PASS_COUNT=0
FAIL_COUNT=0

echo "=== test_07_retro_convergence_health_large_session (SCOPE-7 stress) ==="
echo "Synthetic fixture: 250 loops + 250 envelopes + 1000 complete turnSnapshots"

run_number=1
while [[ "$run_number" -le 5 ]]; do
  start_ns="$(date +%s%N)"
  set +e
  bash "$RETRO_HEALTH" "$SPEC_DIR" --repo-root "$repo" --format json --out "$WORKSPACE/health.md" > "$WORKSPACE/health.json" 2> "$WORKSPACE/health.err"
  json_rc=$?
  set -e
  end_ns="$(date +%s%N)"
  duration_ms=$(((end_ns - start_ns) / 1000000))

  if [[ "$json_rc" -eq 0 ]] \
    && jq -e '.convergenceHealth.slo == "pass" and .snapshotCompleteness == 1 and .convergenceHealth.turnCount == 1000' "$WORKSPACE/health.json" >/dev/null \
    && grep -qF "## Convergence Health" "$WORKSPACE/health.md" \
    && grep -qF 'SLO: `pass`' "$WORKSPACE/health.md" \
    && [[ "$duration_ms" -lt 5000 ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'PASS: run=%02d jsonExit=%d markdownOut=yes durationMs=%d validJson=yes turnCount=1000\n' "$run_number" "$json_rc" "$duration_ms"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL: run=%02d jsonExit=%d durationMs=%d\n' "$run_number" "$json_rc" "$duration_ms"
    cat "$WORKSPACE/health.err"
    cat "$WORKSPACE/health.json" 2>/dev/null || true
    cat "$WORKSPACE/health.md" 2>/dev/null || true
  fi

  run_number=$((run_number + 1))
done

echo "=== Stress verdict ==="
printf '  Passed runs: %d\n' "$PASS_COUNT"
printf '  Failed runs: %d\n' "$FAIL_COUNT"
printf '  Budget:      each JSON stdout + markdown --out run under 5000ms\n'

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_07_retro_convergence_health_large_session: FAILED" >&2
  exit 1
fi

echo "test_07_retro_convergence_health_large_session: PASSED"
exit 0