#!/usr/bin/env bash
set -euo pipefail

# Stress check for SCOPE-6 validation latency report rendering.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/validation-latency-report.sh" ]]; then
  REPORT="$REPO_ROOT/bubbles/scripts/validation-latency-report.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/validation-latency-report.sh" ]]; then
  REPORT="$REPO_ROOT/.github/bubbles/scripts/validation-latency-report.sh"
else
  echo "test_06_validation_latency: report script not executable from $REPO_ROOT" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-scope6-latency-stress-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

repo="$WORKSPACE/repo"
mkdir -p "$repo/.specify/memory"
session="$repo/.specify/memory/bubbles.session.json"

phases=(implement test validate audit docs)

{
  printf '{\n'
  printf '  "sessionId": "scope-06-stress",\n'
  printf '  "executionHistory": [],\n'
  printf '  "turnSnapshots": [\n'
  first=1
  for spec_num in $(seq 1 100); do
    for phase_index in 0 1 2 3 4; do
      phase="${phases[$phase_index]}"
      minute=$((phase_index * 2))
      end_minute=$((minute + 1))
      if [[ "$first" -eq 0 ]]; then
        printf ',\n'
      fi
      first=0
      printf '    {"agent":"bubbles.%s","phase":"%s","specDir":"specs/%03d-latency","startedAt":"2026-05-24T10:%02d:00Z","completedAt":"2026-05-24T10:%02d:00Z"}' \
        "$phase" "$phase" "$spec_num" "$minute" "$end_minute"
    done
  done
  printf '\n  ]\n'
  printf '}\n'
} > "$session"

PASS_COUNT=0
FAIL_COUNT=0

echo "=== test_06_validation_latency (SCOPE-6 stress) ==="
echo "Synthetic fixture: 100 specs x 5 phases = 500 turnSnapshots entries"

run_number=1
while [[ "$run_number" -le 10 ]]; do
  start_ns="$(date +%s%N)"; [[ "$start_ns" =~ ^[0-9]+$ ]] || start_ns="$(( $(date +%s) * 1000000000 ))"
  set +e
  output="$(bash "$REPORT" --repo-root "$repo" --since 30 --now "2026-05-24T12:00:00Z" 2>&1)"
  rc=$?
  set -e
  end_ns="$(date +%s%N)"; [[ "$end_ns" =~ ^[0-9]+$ ]] || end_ns="$(( $(date +%s) * 1000000000 ))"
  duration_ms=$(((end_ns - start_ns) / 1000000))

  if [[ "$rc" -eq 0 ]] && grep -qF "| Phase |" <<< "$output" && grep -qF "Valid durations: 500" <<< "$output" && [[ "$duration_ms" -lt 5000 ]]; then
    PASS_COUNT=$((PASS_COUNT + 1))
    printf 'PASS: run=%02d exit=%d durationMs=%d tableHeader=yes validDurations=500\n' "$run_number" "$rc" "$duration_ms"
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf 'FAIL: run=%02d exit=%d durationMs=%d\n' "$run_number" "$rc" "$duration_ms"
    printf '%s\n' "$output"
  fi
  run_number=$((run_number + 1))
done

echo "=== Stress verdict ==="
printf '  Passed runs: %d\n' "$PASS_COUNT"
printf '  Failed runs: %d\n' "$FAIL_COUNT"
printf '  Budget:      each run under 5000ms\n'

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_06_validation_latency: FAILED" >&2
  exit 1
fi

echo "test_06_validation_latency: PASSED"
exit 0
