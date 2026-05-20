#!/bin/bash
# Extract one QA frame at the visual midpoint of each scene.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FFMPEG="${FFMPEG:-ffmpeg}"
VIDEO="${VIDEO:-$SCRIPT_DIR/bubbles-overview.mp4}"
OUT="${OUT:-/tmp/qa}"

command -v "$FFMPEG" >/dev/null 2>&1 || {
    echo "ffmpeg binary not found; set FFMPEG to the ffmpeg path" >&2
    exit 1
}
[[ -f "$VIDEO" ]] || {
    echo "video file not found: $VIDEO" >&2
    exit 1
}
mkdir -p "$OUT"
declare -a TIMES=(16 55 103 154 202 245 286 332 387 447 507 553)
declare -a NAMES=(
    "01_board"
    "02_terminal"
    "03_six_artifacts"
    "04_slop_gauge"
    "05_workflow_modes"
    "06_chain"
    "07_agent_flow"
    "08_scopes_tree"
    "09_workflows"
    "10_test_grid"
    "11_loop_wheel"
    "12_first_move"
)
for i in "${!TIMES[@]}"; do
    t="${TIMES[$i]}"
    n="${NAMES[$i]}"
    "$FFMPEG" -y -hide_banner -nostats -loglevel error -ss "$t" -i "$VIDEO" -frames:v 1 "$OUT/$n.png"
    echo "wrote $OUT/$n.png at t=${t}s"
done
