#!/usr/bin/env bash
set -uo pipefail

LC_ALL=C
export LC_ALL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_HELPER="$SCRIPT_DIR/planning-source-baseline.sh"
TRANSITION_RESOLVER="$SCRIPT_DIR/transition-contract-resolver.sh"
SOURCE_STATE_HELPER="$SCRIPT_DIR/guards/g073-source-state.sh"
TRUST_METADATA="$SCRIPT_DIR/trust-metadata.sh"

if [[ "$(basename "$(dirname "$SCRIPT_DIR")")" == "bubbles" \
  && "$(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")" == ".github" ]]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi
FROZEN_REGRESSION="$REPO_ROOT/tests/regression/test_30_planning_transition_applicability_and_baseline.sh"

for required_file in \
  "$BASELINE_HELPER" \
  "$TRANSITION_RESOLVER" \
  "$SOURCE_STATE_HELPER" \
  "$TRUST_METADATA"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'planning-source-baseline-selftest: FAIL: required file missing: %s\n' "$required_file" >&2
    exit 1
  fi
done

for required_command in bash find git jq mktemp python3; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    printf 'planning-source-baseline-selftest: FAIL: required command unavailable: %s\n' "$required_command" >&2
    exit 1
  fi
done

# shellcheck source=/dev/null
source "$TRUST_METADATA"
# shellcheck source=/dev/null
source "$SOURCE_STATE_HELPER"

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-planning-baseline-selftest.XXXXXXXX")"
cleanup() {
  rm -rf "$WORKSPACE"
}
trap cleanup EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0
RUN_LOG=""
RUN_STATUS=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

assert_equal() {
  local observed="$1"
  local expected="$2"
  local label="$3"
  if [[ "$observed" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected=$expected observed=$observed)"
  fi
}

assert_file_hash() {
  local file="$1"
  local expected="$2"
  local label="$3"
  local observed=""
  if [[ ! -f "$file" ]]; then
    fail "$label (missing file: $file)"
    return
  fi
  observed="$(bubbles_sha256_file "$file")"
  assert_equal "$observed" "$expected" "$label"
}

result_field() {
  local log_file="$1"
  local field="$2"
  awk -v prefix="$field: " '
    $0 == "BEGIN PLANNING_SOURCE_BASELINE_RESULT_V1" { active=1; next }
    $0 == "END PLANNING_SOURCE_BASELINE_RESULT_V1" { exit }
    active && index($0, prefix) == 1 {
      print substr($0, length(prefix) + 1)
      exit
    }
  ' "$log_file"
}

run_helper() {
  local label="$1"
  shift
  RUN_LOG="$WORKSPACE/$label.log"
  set +e
  bash "$BASELINE_HELPER" "$@" > "$RUN_LOG" 2>&1
  RUN_STATUS=$?
  set -e
}

assert_result() {
  local label="$1"
  local expected_status="$2"
  local expected_reason="$3"
  local expected_exit="$4"
  if python3 - "$RUN_LOG" "$expected_status" "$expected_reason" "$expected_exit" <<'PY'
import re
import sys

path, expected_status, expected_reason, expected_exit = sys.argv[1:5]
with open(path, encoding="utf-8") as handle:
    lines = [line.rstrip("\n") for line in handle]

begin = "BEGIN PLANNING_SOURCE_BASELINE_RESULT_V1"
end = "END PLANNING_SOURCE_BASELINE_RESULT_V1"
if lines.count(begin) != 1 or lines.count(end) != 1:
    raise SystemExit(1)
start = lines.index(begin)
finish = lines.index(end)
fields = [
    "schemaVersion", "status", "reasonCode", "runId", "featureDir",
    "workflowMode", "auditProfile", "repositoryId", "startHead",
    "transitionContractDigest", "payloadDigest", "protectedEntryCount",
    "exitStatus",
]
body = lines[start + 1:finish]
if len(body) != len(fields):
    raise SystemExit(1)
values = {}
for index, field in enumerate(fields):
    prefix = field + ": "
    if not body[index].startswith(prefix):
        raise SystemExit(1)
    values[field] = body[index][len(prefix):]
if values["schemaVersion"] != "planning-source-baseline-result/v1":
    raise SystemExit(1)
if values["status"] != expected_status or values["reasonCode"] != expected_reason:
    raise SystemExit(1)
if values["exitStatus"] != expected_exit or not values["protectedEntryCount"].isdigit():
    raise SystemExit(1)
if values["runId"] != "NONE" and not re.fullmatch(r"psb-[0-9a-f]{64}", values["runId"]):
    raise SystemExit(1)
for field in ("repositoryId", "transitionContractDigest", "payloadDigest"):
    if values[field] != "NONE" and not re.fullmatch(r"sha256:[0-9a-f]{64}", values[field]):
        raise SystemExit(1)
if values["startHead"] != "NONE" and not re.fullmatch(r"[0-9a-f]{40,64}", values["startHead"]):
    raise SystemExit(1)
PY
  then
    if [[ "$RUN_STATUS" -eq "$expected_exit" ]]; then
      pass "$label emits one exact ordered result and matching process exit"
    else
      fail "$label process exit mismatch (expected=$expected_exit observed=$RUN_STATUS)"
    fi
  else
    fail "$label result schema/status/reason mismatch"
    printf '%s\n' "--- $label output ---" >&2
    cat "$RUN_LOG" >&2
    printf '%s\n' "--- end $label output ---" >&2
  fi
}

FIXTURE_REPO="$WORKSPACE/repository"
FEATURE_REL="specs/900-planning-source-baseline-selftest"
FEATURE_DIR="$FIXTURE_REPO/$FEATURE_REL"
STATE_FILE="$FEATURE_DIR/state.json"
mkdir -p "$FEATURE_DIR" "$FIXTURE_REPO/src" "$FIXTURE_REPO/.specify/memory"
git -C "$FIXTURE_REPO" init -q
git -C "$FIXTURE_REPO" config user.name 'Bubbles Baseline Selftest'
git -C "$FIXTURE_REPO" config user.email 'bubbles-baseline-selftest@example.invalid'

cat > "$FIXTURE_REPO/.gitignore" <<'EOF'
.specify/runtime/
EOF
cat > "$FIXTURE_REPO/.specify/memory/bubbles.config.json" <<'EOF'
{
  "version": 2,
  "defaults": {
    "grill": {"mode": "off", "source": "repo-default"},
    "tdd": {"mode": "scenario-first", "source": "repo-default"},
    "lockdown": {"default": false, "source": "repo-default"},
    "regression": {"immutability": "protected-scenarios", "source": "repo-default"},
    "validation": {"certificationRequired": true, "source": "workflow-forced"}
  }
}
EOF
cat > "$STATE_FILE" <<'EOF'
{
  "version": 3,
  "status": "in_progress",
  "workflowMode": "product-to-planning",
  "planningOnly": true,
  "planMaturityOnly": true,
  "execution": {
    "planningSourceBaselineHistory": []
  },
  "certification": {
    "status": "in_progress"
  },
  "policySnapshot": {
    "workflowMode": "product-to-planning"
  }
}
EOF
printf '%s\n' 'committed baseline bytes' > "$FIXTURE_REPO/src/baseline.rs"
git -C "$FIXTURE_REPO" add -A
git -C "$FIXTURE_REPO" commit -q -m 'test: seed planning baseline fixture'
printf '%s\n' 'staged pre-run bytes' > "$FIXTURE_REPO/src/baseline.rs"
git -C "$FIXTURE_REPO" add -- src/baseline.rs

START_HEAD="$(git -C "$FIXTURE_REPO" rev-parse --verify 'HEAD^{commit}')"
START_TREE="$(git -C "$FIXTURE_REPO" rev-parse --verify "$START_HEAD^{tree}")"
EXPECTED_REPOSITORY_ID="$(g073_source_state_repository_id "$FIXTURE_REPO")"
EXPECTED_CLASSIFIER_DIGEST="$(g073_source_state_classifier_digest)"
CONTRACT_JSON="$(bash "$TRANSITION_RESOLVER" "$FEATURE_DIR")"
EXPECTED_CONTRACT_DIGEST="$(printf '%s' "$CONTRACT_JSON" | jq -r '.contractDigest')"
SOURCE_STATE_BEFORE="$(g073_source_state_snapshot "$FIXTURE_REPO" "$START_HEAD")"

printf '%s\n' 'Running BUG-023 planning-source baseline lifecycle selftest...'

run_helper capture-first capture "$FEATURE_DIR"
assert_result 'initial capture' BASELINE_CAPTURED BASELINE_CAPTURED 0

FIRST_RUN_ID="$(jq -r '.execution.planningSourceBaseline.runId // ""' "$STATE_FILE")"
FIRST_ARTIFACT_REF="$(jq -r '.execution.planningSourceBaseline.artifactRef // ""' "$STATE_FILE")"
FIRST_SIDECAR="$FIXTURE_REPO/$FIRST_ARTIFACT_REF"
FIRST_PAYLOAD_DIGEST="$(jq -r '.execution.planningSourceBaseline.payloadDigest // ""' "$STATE_FILE")"

if python3 - \
  "$STATE_FILE" \
  "$FIRST_SIDECAR" \
  "$FEATURE_REL" \
  "$EXPECTED_REPOSITORY_ID" \
  "$START_HEAD" \
  "$START_TREE" \
  "$EXPECTED_CONTRACT_DIGEST" \
  "$EXPECTED_CLASSIFIER_DIGEST" <<'PY'
import hashlib
import json
import re
import sys

(
    state_path,
    sidecar_path,
    feature_dir,
    repository_id,
    start_head,
    start_tree,
    contract_digest,
    classifier_digest,
) = sys.argv[1:]

with open(state_path, encoding="utf-8") as handle:
    state = json.load(handle)
with open(sidecar_path, encoding="utf-8") as handle:
    sidecar = json.load(handle)

reference = state["execution"]["planningSourceBaseline"]
payload = sidecar["payload"]
expected_reference_keys = {
    "artifactRef", "auditProfile", "capturedAt", "featureDir", "lifecycle",
    "payloadDigest", "repositoryId", "runId", "schemaVersion", "startHead",
    "transitionContractDigest", "workflowMode",
}
expected_envelope_keys = {"payload", "payloadDigest", "schemaVersion"}
expected_payload_keys = {
    "auditProfile", "captureTargetRevision", "capturedAt", "entries",
    "featureDir", "protectedUniverse", "repositoryId", "runId", "startHead",
    "startTree", "transitionContractDigest", "workflowMode",
}
expected_entry_keys = {
    "entryKey", "head", "index", "indexStatus", "path", "relation",
    "stateClass", "worktree", "worktreeMatchesIndex", "worktreeStatus",
}
expected_identity_keys = {"contentDigest", "gitObjectId", "kind", "mode", "presence"}

assert set(reference) == expected_reference_keys
assert set(sidecar) == expected_envelope_keys
assert set(payload) == expected_payload_keys
assert reference["schemaVersion"] == "planning-source-baseline-ref/v1"
assert reference["lifecycle"] == "ACTIVE"
assert sidecar["schemaVersion"] == "planning-source-baseline/v1"
assert re.fullmatch(r"psb-[0-9a-f]{64}", reference["runId"])
assert reference["artifactRef"] == ".specify/runtime/planning-source-baselines/{}.json".format(reference["runId"][4:])
assert reference["featureDir"] == payload["featureDir"] == feature_dir
assert reference["workflowMode"] == payload["workflowMode"] == "product-to-planning"
assert reference["auditProfile"] == payload["auditProfile"] == "planning-maturity-v1"
assert reference["repositoryId"] == payload["repositoryId"] == repository_id
assert reference["startHead"] == payload["startHead"] == start_head
assert payload["startTree"] == start_tree
assert reference["transitionContractDigest"] == payload["transitionContractDigest"] == contract_digest
assert payload["protectedUniverse"] == {
    "classifierDigest": classifier_digest,
    "schemaVersion": "g073-protected-path-universe/v1",
}
assert isinstance(state["execution"]["planningSourceBaselineHistory"], list)
assert state["execution"]["planningSourceBaselineHistory"] == []
assert len(payload["entries"]) == 1
entry = payload["entries"][0]
assert set(entry) == expected_entry_keys
assert entry["path"] == "src/baseline.rs"
assert entry["stateClass"] == "STAGED_ONLY"
assert entry["indexStatus"] == "M" and entry["worktreeStatus"] == "."
assert entry["relation"] is None and entry["worktreeMatchesIndex"] is True
assert re.fullmatch(r"sha256:[0-9a-f]{64}", entry["entryKey"])
for identity_name in ("head", "index", "worktree"):
    identity = entry[identity_name]
    assert set(identity) == expected_identity_keys
    assert identity["presence"] in ("PRESENT", "ABSENT")
canonical = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
computed = "sha256:" + hashlib.sha256(canonical).hexdigest()
assert reference["payloadDigest"] == sidecar["payloadDigest"] == computed
PY
then
  pass 'capture writes the exact reference/envelope/payload/entry schemas with canonical digest and identity bindings'
else
  fail 'capture schema, digest, or identity contract mismatch'
fi

assert_equal "$(result_field "$RUN_LOG" runId)" "$FIRST_RUN_ID" 'capture result runId matches the state reference'
assert_equal "$(result_field "$RUN_LOG" payloadDigest)" "$FIRST_PAYLOAD_DIGEST" 'capture result digest matches the state reference'
assert_equal "$(result_field "$RUN_LOG" protectedEntryCount)" '1' 'capture result reports the exact protected entry count'
if grep -Fq -- "$FIXTURE_REPO" "$RUN_LOG"; then
  fail 'capture result withholds the absolute repository path'
else
  pass 'capture result withholds the absolute repository path'
fi
if [[ "$(g073_source_state_snapshot "$FIXTURE_REPO" "$START_HEAD")" == "$SOURCE_STATE_BEFORE" ]]; then
  pass 'capture preserves the protected source-state snapshot byte-for-byte'
else
  fail 'capture changed the protected source-state snapshot'
fi
if [[ -z "$(find "$FEATURE_DIR" "$FIXTURE_REPO/.specify/runtime/planning-source-baselines" -type f \( -name '.state.json.planning-baseline.*' -o -name '.planning-source-baseline.*' \) -print 2>/dev/null)" ]]; then
  pass 'capture leaves no state or sidecar temporary file after atomic renames'
else
  fail 'capture left an atomic-write temporary file behind'
fi

FIRST_STATE_HASH="$(bubbles_sha256_file "$STATE_FILE")"
FIRST_SIDECAR_HASH="$(bubbles_sha256_file "$FIRST_SIDECAR")"
run_helper capture-reuse capture "$FEATURE_DIR"
assert_result 'active capture reuse' BASELINE_REUSED BASELINE_REUSED 0
assert_file_hash "$STATE_FILE" "$FIRST_STATE_HASH" 'active reuse preserves exact state bytes'
assert_file_hash "$FIRST_SIDECAR" "$FIRST_SIDECAR_HASH" 'active reuse preserves exact sidecar bytes'
assert_equal "$(result_field "$RUN_LOG" runId)" "$FIRST_RUN_ID" 'active reuse reports the original runId'

LOCK_KEY="$(printf '%s' "$FEATURE_REL" | bubbles_sha256_stdin)"
LOCK_DIR="$FIXTURE_REPO/.specify/runtime/planning-source-baselines/locks/$LOCK_KEY.lock"
mkdir -p "$LOCK_DIR"
LOCK_STATE_HASH="$(bubbles_sha256_file "$STATE_FILE")"
LOCK_SIDECAR_HASH="$(bubbles_sha256_file "$FIRST_SIDECAR")"
run_helper capture-lock-contention capture "$FEATURE_DIR"
assert_result 'held feature lock' BLOCKED BASELINE_ENTRY_IDENTITY_INVALID 1
assert_file_hash "$STATE_FILE" "$LOCK_STATE_HASH" 'lock refusal preserves state bytes'
assert_file_hash "$FIRST_SIDECAR" "$LOCK_SIDECAR_HASH" 'lock refusal preserves sidecar bytes'
assert_equal "$(g073_source_state_snapshot "$FIXTURE_REPO" "$START_HEAD")" "$SOURCE_STATE_BEFORE" 'lock refusal preserves protected source state'
rm -rf "$LOCK_DIR"

run_helper close-completed close "$FEATURE_DIR" --outcome completed
assert_result 'completed close' BASELINE_CLOSED BASELINE_CLOSED_COMPLETED 0
assert_equal "$(jq -r '.execution.planningSourceBaseline.lifecycle' "$STATE_FILE")" 'CLOSED_COMPLETED' 'completed close records CLOSED_COMPLETED'
if jq -e '.execution.planningSourceBaseline.closedAt | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T")' "$STATE_FILE" >/dev/null 2>&1; then
  pass 'completed close records a UTC close timestamp'
else
  fail 'completed close does not record a valid close timestamp'
fi
assert_file_hash "$FIRST_SIDECAR" "$FIRST_SIDECAR_HASH" 'completed close preserves immutable sidecar bytes'

run_helper capture-after-completed capture "$FEATURE_DIR"
assert_result 'capture after completed close' BASELINE_CAPTURED BASELINE_CAPTURED 0
SECOND_RUN_ID="$(jq -r '.execution.planningSourceBaseline.runId' "$STATE_FILE")"
SECOND_SIDECAR="$FIXTURE_REPO/$(jq -r '.execution.planningSourceBaseline.artifactRef' "$STATE_FILE")"
SECOND_SIDECAR_HASH="$(bubbles_sha256_file "$SECOND_SIDECAR")"
if [[ "$SECOND_RUN_ID" != "$FIRST_RUN_ID" ]]; then
  pass 'capture after completed close creates a distinct runId'
else
  fail 'capture after completed close reused a closed runId'
fi
if jq -e --arg runId "$FIRST_RUN_ID" '
  .execution.planningSourceBaselineHistory | length == 1
  and .[0].runId == $runId
  and .[0].lifecycle == "CLOSED_COMPLETED"
  and (.[0].closedAt | type == "string")
' "$STATE_FILE" >/dev/null 2>&1; then
  pass 'completed reference is archived once in append-only history'
else
  fail 'completed reference history is missing or malformed'
fi
assert_file_hash "$FIRST_SIDECAR" "$FIRST_SIDECAR_HASH" 'history rollover preserves the first sidecar bytes'

run_helper close-aborted close "$FEATURE_DIR" --outcome aborted
assert_result 'aborted close' BASELINE_CLOSED BASELINE_CLOSED_ABORTED 0
assert_equal "$(jq -r '.execution.planningSourceBaseline.lifecycle' "$STATE_FILE")" 'CLOSED_ABORTED' 'aborted close records CLOSED_ABORTED'
assert_file_hash "$SECOND_SIDECAR" "$SECOND_SIDECAR_HASH" 'aborted close preserves immutable sidecar bytes'

run_helper capture-after-aborted capture "$FEATURE_DIR"
assert_result 'capture after aborted close' BASELINE_CAPTURED BASELINE_CAPTURED 0
THIRD_RUN_ID="$(jq -r '.execution.planningSourceBaseline.runId' "$STATE_FILE")"
if [[ "$THIRD_RUN_ID" != "$SECOND_RUN_ID" && "$THIRD_RUN_ID" != "$FIRST_RUN_ID" ]]; then
  pass 'capture after aborted close creates a third distinct runId'
else
  fail 'capture after aborted close reused a closed runId'
fi
if jq -e --arg first "$FIRST_RUN_ID" --arg second "$SECOND_RUN_ID" '
  .execution.planningSourceBaselineHistory | length == 2
  and .[0].runId == $first
  and .[0].lifecycle == "CLOSED_COMPLETED"
  and .[1].runId == $second
  and .[1].lifecycle == "CLOSED_ABORTED"
' "$STATE_FILE" >/dev/null 2>&1; then
  pass 'completed and aborted references retain deterministic append-only history order'
else
  fail 'completed and aborted history order is missing or malformed'
fi

THIRD_SIDECAR="$FIXTURE_REPO/$(jq -r '.execution.planningSourceBaseline.artifactRef' "$STATE_FILE")"
THIRD_STATE_HASH="$(bubbles_sha256_file "$STATE_FILE")"
THIRD_SIDECAR_HASH="$(bubbles_sha256_file "$THIRD_SIDECAR")"
run_helper invalid-close-outcome close "$FEATURE_DIR" --outcome invalid
assert_result 'invalid close outcome' BLOCKED BASELINE_REQUIRED_FIELD_MISSING 2
assert_file_hash "$STATE_FILE" "$THIRD_STATE_HASH" 'invalid close outcome preserves state bytes'
assert_file_hash "$THIRD_SIDECAR" "$THIRD_SIDECAR_HASH" 'invalid close outcome preserves sidecar bytes'

run_frozen_scenario() {
  local scenario_id="$1"
  local label="$2"
  local log_file="$WORKSPACE/$scenario_id.log"
  local exit_code=0
  if [[ ! -f "$FROZEN_REGRESSION" ]]; then
    printf 'SKIP: %s (source-only frozen regression is not installed downstream)\n' "$label"
    return
  fi
  set +e
  bash "$FROZEN_REGRESSION" --scenario "$scenario_id" > "$log_file" 2>&1
  exit_code=$?
  set -e
  if [[ "$exit_code" -eq 0 ]] \
    && grep -Fq 'GREEN_REGRESSION_VERDICT=BUG_023_CONTRACT_SATISFIED' "$log_file" \
    && grep -Fq 'CAUSAL_FAILURES=0' "$log_file" \
    && grep -Fq 'CONTROL_FAILURES=0' "$log_file" \
    && grep -Fq 'HARNESS_FAILURES=0' "$log_file"; then
    pass "$label"
  else
    fail "$label (exit=$exit_code)"
    cat "$log_file" >&2
  fi
}

run_frozen_scenario SCN-BUG-023-012 'frozen capture/atomicity/reuse/path-input matrix remains green'
run_frozen_scenario SCN-BUG-023-013 'frozen six-state exact-identity and no-mutation matrix remains green'
run_frozen_scenario SCN-BUG-023-014 'frozen mutation and compare-race matrix remains green'
run_frozen_scenario SCN-BUG-023-015 'frozen invalid-provenance/path-safety/capture-race matrix remains green'
run_frozen_scenario SCN-BUG-023-016 'frozen retry cannot bless post-capture dirt matrix remains green'
run_frozen_scenario SCN-BUG-023-017 'frozen absent-key legacy split and no-synthesis matrix remains green'

printf '%s\n' '----------------------------------------'
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  printf 'planning-source-baseline-selftest: %s passed, %s failed\n' "$PASS_COUNT" "$FAIL_COUNT" >&2
  exit 1
fi

printf 'planning-source-baseline-selftest: %s passed, 0 failed\n' "$PASS_COUNT"