#!/usr/bin/env bash
# bubbles/adapters/judge/routing-ollama.sh — ROUTING judge for the R3 held-out eval.
#
# operating-baseline.md R3 requires proving an orchestrator still DETECTS AND
# ROUTES every gate before any module leaves its loaded closure. The corpus
# cannot do that: it scores static artifacts with deterministic checks and never
# invokes a model. This judge closes that gap by actually running the bundle.
#
# Invoked by eval-harness.sh as:  routing-ollama.sh <out_dir> <task_path>
#
# out_dir contract (written by the caller, NOT by this adapter):
#   agent.txt     absolute path to the *.agent.md under evaluation
#   scenario.md   the held-out scenario text the orchestrator must route
#
# It composes the agent's EFFECTIVE bundle (the agent file plus its transitive
# bubbles_shared closure — the same closure effective-bundle-measure.sh reports),
# puts the scenario to the model, and returns the gate ids the model says it
# would raise as gatesDetected. run_judge then fails the task naming any gate in
# expectedGates that is absent, which is the regression signal R3 asks for.
#
# FAIL-CLOSED: every error path returns error/unavailable with a null score. A
# routing eval that cannot run must never read as "routing is intact".
#
# Config: BUBBLES_EVAL_JUDGE_URL (required), BUBBLES_EVAL_JUDGE_MODEL,
#         BUBBLES_EVAL_JUDGE_THINK.

set -euo pipefail

ADAPTER_VERSION="1.0.0"

emit_failure() {
  BUBBLES_RJ_STATUS="$1" BUBBLES_RJ_CODE="$2" BUBBLES_RJ_MESSAGE="$3" \
  BUBBLES_RJ_VERSION="$ADAPTER_VERSION" python3 - <<'PY'
import json, os
message = os.environ["BUBBLES_RJ_MESSAGE"]
print(json.dumps({
    "status": os.environ["BUBBLES_RJ_STATUS"],
    "score": None,
    "verdict": message,
    "rubricFindings": [message],
    "provenance": {"adapter": "routing-ollama", "version": os.environ["BUBBLES_RJ_VERSION"]},
    "error": {"code": os.environ["BUBBLES_RJ_CODE"], "message": message},
}, sort_keys=True))
PY
  exit 0
}

case "${1:-}" in
  -h | --help)
    cat >&2 <<'EOF'
routing-ollama.sh — routing judge (Ollama backend) for the R3 held-out eval
Usage: routing-ollama.sh <out_dir> <task_path>
out_dir must contain agent.txt (path to a *.agent.md) and scenario.md
EOF
    exit 0
    ;;
esac

OUT_DIR="${1:-}"
TASK_PATH="${2:-}"

[ -n "$OUT_DIR" ] || emit_failure "error" "routing-usage" "out_dir argument is required"
[ -n "$TASK_PATH" ] || emit_failure "error" "routing-usage" "task_path argument is required"
[ -d "$OUT_DIR" ] || emit_failure "error" "routing-out-dir-missing" "out_dir does not exist"
[ -r "$OUT_DIR/agent.txt" ] || emit_failure "error" "routing-agent-missing" "out_dir/agent.txt is required"
[ -r "$OUT_DIR/scenario.md" ] || emit_failure "error" "routing-scenario-missing" "out_dir/scenario.md is required"
[ -n "${BUBBLES_EVAL_JUDGE_URL:-}" ] || emit_failure "unavailable" "routing-url-unset" "BUBBLES_EVAL_JUDGE_URL is not set"
command -v python3 >/dev/null 2>&1 || emit_failure "error" "routing-python-missing" "python3 is required"
command -v curl >/dev/null 2>&1 || emit_failure "error" "routing-curl-missing" "curl is required"

AGENT_PATH="$(cat "$OUT_DIR/agent.txt")"
[ -r "$AGENT_PATH" ] || emit_failure "error" "routing-agent-unreadable" "agent file named by agent.txt is not readable"

BUBBLES_RJ_AGENT="$AGENT_PATH" \
BUBBLES_RJ_SCENARIO_FILE="$OUT_DIR/scenario.md" \
BUBBLES_RJ_URL="$BUBBLES_EVAL_JUDGE_URL" \
BUBBLES_RJ_MODEL="${BUBBLES_EVAL_JUDGE_MODEL:-qwen3:30b-a3b}" \
BUBBLES_RJ_THINK="${BUBBLES_EVAL_JUDGE_THINK:-false}" \
BUBBLES_RJ_EXCLUDE="${BUBBLES_EVAL_ROUTING_EXCLUDE:-}" \
BUBBLES_RJ_VERSION="$ADAPTER_VERSION" \
python3 - <<'PY'
import json, os, re, subprocess, sys, uuid

VERSION = os.environ["BUBBLES_RJ_VERSION"]
MODEL = os.environ["BUBBLES_RJ_MODEL"]
MAX_BUNDLE_BYTES = 120000


def emit(status, verdict, findings, score=None, gates=None, error=None, inv=None):
    provenance = {"adapter": "routing-ollama", "version": VERSION, "provider": "ollama", "model": MODEL}
    if inv:
        provenance["invocationId"] = inv
    result = {
        "status": status,
        "score": score,
        "verdict": verdict,
        "rubricFindings": findings,
        "provenance": provenance,
    }
    if gates is not None:
        result["gatesDetected"] = gates
    if error is not None:
        result["error"] = error
    print(json.dumps(result, sort_keys=True))
    sys.exit(0)


def fail(status, code, message, inv=None):
    emit(status, message, [message], None, None, {"code": code, "message": message}, inv)


agent_path = os.environ["BUBBLES_RJ_AGENT"]
base_url = os.environ["BUBBLES_RJ_URL"].rstrip("/")
think = os.environ["BUBBLES_RJ_THINK"].strip().lower() == "true"
inv = str(uuid.uuid4())

try:
    scenario = open(os.environ["BUBBLES_RJ_SCENARIO_FILE"], encoding="utf-8").read().strip()
except OSError:
    fail("error", "routing-scenario-unreadable", "scenario.md could not be read", inv)
if not scenario:
    fail("error", "routing-scenario-empty", "scenario.md is empty", inv)

# Resolve the agent's effective closure the same way effective-bundle-measure.sh
# does: the agent file plus every bubbles_shared/<name>.md it transitively cites.
# BUBBLES_EVAL_ROUTING_EXCLUDE drops named modules so a SCOPE-2 reduction can be
# MEASURED against the gate set before any agent file is edited.
excluded = {n.strip() for n in os.environ.get("BUBBLES_RJ_EXCLUDE", "").split(",") if n.strip()}
agent_dir = os.path.dirname(os.path.abspath(agent_path))
shared_dir = os.path.join(agent_dir, "bubbles_shared")
seen, queue, parts, total = set(), [os.path.abspath(agent_path)], [], 0
while queue:
    path = queue.pop(0)
    if path in seen or not os.path.isfile(path):
        continue
    seen.add(path)
    try:
        body = open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        continue
    if total < MAX_BUNDLE_BYTES:
        chunk = body[: MAX_BUNDLE_BYTES - total]
        parts.append(f"--- {os.path.basename(path)} ---\n{chunk}")
        total += len(chunk)
    for name in re.findall(r"bubbles_shared/([A-Za-z0-9._-]+)\.md", body):
        if name in excluded:
            continue
        queue.append(os.path.join(shared_dir, f"{name}.md"))

if not parts:
    fail("error", "routing-bundle-empty", "agent bundle resolved to no readable content", inv)

prompt = (
    "You are the orchestrator described by the INSTRUCTIONS below. Read them, then "
    "read the SCENARIO. Decide which governance gates apply and would be raised.\n\n"
    "Reply with ONLY JSON: {\"gatesDetected\":[\"G019\",...],\"reasoning\":\"one sentence\"}\n"
    "Use the gate identifiers exactly as the instructions spell them (G followed by "
    "three digits). List every gate that applies. If none apply, return an empty array.\n\n"
    "INSTRUCTIONS:\n" + "\n\n".join(parts) + "\n\nSCENARIO:\n" + scenario
)

payload = {
    "model": MODEL,
    "prompt": prompt,
    "format": "json",
    "stream": False,
    "think": think,
    "options": {"num_predict": 400, "temperature": 0},
}

try:
    done = subprocess.run(
        ["curl", "-s", "--fail-with-body", "--max-time", "290",
         "-H", "Content-Type: application/json", "--data-binary", "@-",
         f"{base_url}/api/generate"],
        input=json.dumps(payload), capture_output=True, text=True, check=False,
    )
except OSError as exc:
    fail("error", "routing-invoke-failed", f"curl could not run: {type(exc).__name__}", inv)

if done.returncode != 0:
    fail("unavailable", "routing-endpoint-unreachable", f"curl exit {done.returncode}", inv)

try:
    envelope = json.loads(done.stdout)
except ValueError:
    fail("error", "routing-transport-malformed", "endpoint did not return JSON", inv)

body = (envelope.get("response") or "").strip() or (envelope.get("thinking") or "").strip()
if not body:
    fail("error", "routing-empty-response", "model returned no content", inv)

try:
    parsed = json.loads(body)
except ValueError:
    fail("error", "routing-malformed-json", "model output was not parseable JSON", inv)

if not isinstance(parsed, dict):
    fail("error", "routing-malformed-json", "model output was not a JSON object", inv)

raw_gates = parsed.get("gatesDetected")
if not isinstance(raw_gates, list):
    fail("error", "routing-no-gates-field", "model output had no gatesDetected array", inv)

# Normalise to canonical Gnnn so casing or stray prose cannot mask a real match.
gates = []
for item in raw_gates:
    match = re.search(r"G\d{3}", str(item).upper())
    if match and match.group(0) not in gates:
        gates.append(match.group(0))

reasoning = str(parsed.get("reasoning") or "").strip() or "routing evaluated"
emit("passed", reasoning[:200], [f"gates routed: {', '.join(gates) if gates else 'none'}"], 1.0, gates, None, inv)
PY
