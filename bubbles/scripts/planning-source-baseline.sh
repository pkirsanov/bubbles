#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/trust-metadata.sh"
source "$SCRIPT_DIR/guards/g073-source-state.sh"

status="BLOCKED"
reason_code="BASELINE_REQUIRED_FIELD_MISSING"
run_id="NONE"
feature_identity="NONE"
workflow_mode="NONE"
audit_profile="NONE"
repository_id="NONE"
start_head="NONE"
contract_digest="NONE"
payload_digest="NONE"
protected_entry_count=0
exit_status=2
lock_dir=""

emit_result() {
  printf '%s\n' 'BEGIN PLANNING_SOURCE_BASELINE_RESULT_V1'
  printf '%s\n' 'schemaVersion: planning-source-baseline-result/v1'
  printf 'status: %s\n' "$status"
  printf 'reasonCode: %s\n' "$reason_code"
  printf 'runId: %s\n' "$run_id"
  printf 'featureDir: %s\n' "$feature_identity"
  printf 'workflowMode: %s\n' "$workflow_mode"
  printf 'auditProfile: %s\n' "$audit_profile"
  printf 'repositoryId: %s\n' "$repository_id"
  printf 'startHead: %s\n' "$start_head"
  printf 'transitionContractDigest: %s\n' "$contract_digest"
  printf 'payloadDigest: %s\n' "$payload_digest"
  printf 'protectedEntryCount: %s\n' "$protected_entry_count"
  printf 'exitStatus: %s\n' "$exit_status"
  printf '%s\n' 'END PLANNING_SOURCE_BASELINE_RESULT_V1'
}

finish() {
  local requested_exit="$1"
  exit_status="$requested_exit"
  emit_result
  exit "$requested_exit"
}

cleanup() {
  if [[ -n "$lock_dir" ]]; then
    rmdir "$lock_dir" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

if [[ "$#" -lt 2 ]]; then
  finish 2
fi

operation="$1"
feature_dir="$2"
shift 2

case "$operation" in
  capture)
    [[ "$#" -eq 0 ]] || finish 2
    ;;
  close)
    [[ "$#" -eq 2 && "$1" == "--outcome" ]] || finish 2
    close_outcome="$2"
    [[ "$close_outcome" == "completed" || "$close_outcome" == "aborted" ]] || finish 2
    ;;
  *)
    finish 2
    ;;
esac

if [[ ! -d "$feature_dir" || ! -f "$feature_dir/state.json" ]]; then
  reason_code="BASELINE_REQUIRED_FIELD_MISSING"
  finish 1
fi

feature_abs="$(cd "$feature_dir" && pwd -P)"
repo_root="$(git -C "$feature_abs" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  reason_code="BASELINE_REPOSITORY_BINDING_MISMATCH"
  finish 1
fi
repo_root="$(cd "$repo_root" && pwd -P)"
case "$feature_abs" in
  "$repo_root"/*) feature_identity="${feature_abs#"$repo_root/"}" ;;
  *) reason_code="BASELINE_SPEC_BINDING_MISMATCH"; finish 1 ;;
esac

state_file="$feature_abs/state.json"
contract_file="$(mktemp "${TMPDIR:-/tmp}/bubbles-planning-baseline-contract.XXXXXX")"
contract_error="$(mktemp "${TMPDIR:-/tmp}/bubbles-planning-baseline-error.XXXXXX")"
set +e
bash "$SCRIPT_DIR/transition-contract-resolver.sh" "$feature_abs" > "$contract_file" 2> "$contract_error"
resolver_status=$?
set -e
if [[ "$resolver_status" -ne 0 ]]; then
  rm -f "$contract_file" "$contract_error"
  reason_code="BASELINE_TRANSITION_BINDING_MISMATCH"
  finish 2
fi
rm -f "$contract_error"

workflow_mode="$(jq -r '.workflowMode // ""' "$contract_file")"
audit_profile="$(jq -r '.auditProfile // ""' "$contract_file")"
contract_digest="$(jq -r '.contractDigest // ""' "$contract_file")"
target_revision="$(jq -r '.targetRevision // ""' "$contract_file")"
if [[ "$audit_profile" != "planning-maturity-v1" ]] || ! jq -e '.requiredGates | index("G073") != null' "$contract_file" >/dev/null 2>&1; then
  rm -f "$contract_file"
  reason_code="BASELINE_PROFILE_BINDING_MISMATCH"
  finish 1
fi
rm -f "$contract_file"

repository_id="$(g073_source_state_repository_id "$repo_root")"
runtime_dir="$repo_root/.specify/runtime/planning-source-baselines"
locks_dir="$runtime_dir/locks"
mkdir -p "$locks_dir"
lock_key="$(printf '%s' "$feature_identity" | bubbles_sha256_stdin)"
lock_dir="$locks_dir/$lock_key.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  reason_code="BASELINE_ENTRY_IDENTITY_INVALID"
  finish 1
fi

reference_type="$(jq -r 'if (.execution | type) != "object" or (.execution | has("planningSourceBaseline") | not) then "absent" elif (.execution.planningSourceBaseline | type) == "object" then (.execution.planningSourceBaseline.lifecycle // "partial") else (.execution.planningSourceBaseline | type) end' "$state_file" 2>/dev/null || printf '%s' malformed)"

if [[ "$operation" == "close" ]]; then
  [[ "$reference_type" == "ACTIVE" ]] || { reason_code="BASELINE_REQUIRED_FIELD_MISSING"; finish 1; }
  validation_json=""
  if ! validation_json="$(g073_source_state_validate "$repo_root" "$feature_identity" "$workflow_mode" "$audit_profile" "$contract_digest" "$state_file")"; then
    reason_code="$(printf '%s' "$validation_json" | jq -r '.reasonCode // "BASELINE_REQUIRED_FIELD_MISSING"' 2>/dev/null || printf '%s' BASELINE_REQUIRED_FIELD_MISSING)"
    finish 1
  fi
  run_id="$(jq -r '.runId' "$state_file" 2>/dev/null || jq -r '.execution.planningSourceBaseline.runId' "$state_file")"
  run_id="$(jq -r '.execution.planningSourceBaseline.runId' "$state_file")"
  payload_digest="$(jq -r '.execution.planningSourceBaseline.payloadDigest' "$state_file")"
  start_head="$(jq -r '.execution.planningSourceBaseline.startHead' "$state_file")"
  protected_entry_count="$(printf '%s' "$validation_json" | jq -r '.protectedEntryCount')"
  closed_at="$(bubbles_current_timestamp)"
  state_tmp="$(mktemp "$feature_abs/.state.json.planning-baseline.XXXXXX")"
  lifecycle="CLOSED_COMPLETED"
  reason_code="BASELINE_CLOSED_COMPLETED"
  [[ "$close_outcome" == "completed" ]] || { lifecycle="CLOSED_ABORTED"; reason_code="BASELINE_CLOSED_ABORTED"; }
  jq --arg lifecycle "$lifecycle" --arg closedAt "$closed_at" \
    '.execution.planningSourceBaseline.lifecycle = $lifecycle | .execution.planningSourceBaseline.closedAt = $closedAt' \
    "$state_file" > "$state_tmp"
  mv "$state_tmp" "$state_file"
  status="BASELINE_CLOSED"
  finish 0
fi

if [[ "$reference_type" == "ACTIVE" ]]; then
  validation_json=""
  if ! validation_json="$(g073_source_state_validate "$repo_root" "$feature_identity" "$workflow_mode" "$audit_profile" "$contract_digest" "$state_file")"; then
    reason_code="$(printf '%s' "$validation_json" | jq -r '.reasonCode // "BASELINE_REQUIRED_FIELD_MISSING"' 2>/dev/null || printf '%s' BASELINE_REQUIRED_FIELD_MISSING)"
    finish 1
  fi
  run_id="$(jq -r '.execution.planningSourceBaseline.runId' "$state_file")"
  payload_digest="$(jq -r '.execution.planningSourceBaseline.payloadDigest' "$state_file")"
  start_head="$(jq -r '.execution.planningSourceBaseline.startHead' "$state_file")"
  protected_entry_count="$(printf '%s' "$validation_json" | jq -r '.protectedEntryCount')"
  status="BASELINE_REUSED"
  reason_code="BASELINE_REUSED"
  finish 0
elif [[ "$reference_type" != "absent" && "$reference_type" != CLOSED_COMPLETED && "$reference_type" != CLOSED_ABORTED ]]; then
  reason_code="BASELINE_REQUIRED_FIELD_MISSING"
  finish 1
fi

prior_reference='null'
if [[ "$reference_type" == CLOSED_COMPLETED || "$reference_type" == CLOSED_ABORTED ]]; then
  prior_reference="$(jq -c '.execution.planningSourceBaseline' "$state_file")"
fi

start_head="$(git -C "$repo_root" rev-parse --verify 'HEAD^{commit}' 2>/dev/null || true)"
if [[ ! "$start_head" =~ ^[0-9a-f]{40,64}$ ]]; then
  reason_code="BASELINE_START_HEAD_UNRESOLVED"
  finish 1
fi
start_tree="$(git -C "$repo_root" rev-parse --verify "$start_head^{tree}" 2>/dev/null || true)"
captured_at="$(bubbles_current_timestamp)"
nonce_file="$(mktemp "${TMPDIR:-/tmp}/bubbles-planning-baseline-nonce.XXXXXX")"
nonce="$(basename "$nonce_file")"
rm -f "$nonce_file"
run_hex="$(printf 'repository=%s\nfeature=%s\nmode=%s\nprofile=%s\nhead=%s\ntime=%s\npid=%s\nnonce=%s\n' \
  "$repository_id" "$feature_identity" "$workflow_mode" "$audit_profile" "$start_head" "$captured_at" "$$" "$nonce" | bubbles_sha256_stdin)"
run_id="psb-$run_hex"
artifact_ref=".specify/runtime/planning-source-baselines/$run_hex.json"
sidecar="$repo_root/$artifact_ref"
if [[ -e "$sidecar" ]]; then
  reason_code="BASELINE_RUN_BINDING_MISMATCH"
  finish 1
fi

snapshot_a=""
snapshot_b=""
if ! snapshot_a="$(g073_source_state_snapshot "$repo_root" "$start_head")"; then
  reason_code="BASELINE_ENTRY_IDENTITY_INVALID"
  finish 1
fi
head_mid="$(git -C "$repo_root" rev-parse --verify 'HEAD^{commit}' 2>/dev/null || true)"
if ! snapshot_b="$(g073_source_state_snapshot "$repo_root" "$start_head")"; then
  reason_code="BASELINE_ENTRY_IDENTITY_INVALID"
  finish 1
fi
head_after="$(git -C "$repo_root" rev-parse --verify 'HEAD^{commit}' 2>/dev/null || true)"
if [[ "$start_head" != "$head_mid" || "$start_head" != "$head_after" || "$snapshot_a" != "$snapshot_b" ]]; then
  reason_code="BASELINE_ENTRY_IDENTITY_INVALID"
  finish 1
fi

classifier_digest="$(g073_source_state_classifier_digest)"
payload_json="$(jq -cS -n \
  --arg runId "$run_id" \
  --arg capturedAt "$captured_at" \
  --arg featureDir "$feature_identity" \
  --arg workflowMode "$workflow_mode" \
  --arg auditProfile "$audit_profile" \
  --arg repositoryId "$repository_id" \
  --arg startHead "$start_head" \
  --arg startTree "$start_tree" \
  --arg transitionContractDigest "$contract_digest" \
  --arg captureTargetRevision "$target_revision" \
  --arg classifierDigest "$classifier_digest" \
  --argjson entries "$snapshot_a" \
  '{
    auditProfile: $auditProfile,
    captureTargetRevision: $captureTargetRevision,
    capturedAt: $capturedAt,
    entries: $entries,
    featureDir: $featureDir,
    protectedUniverse: {
      classifierDigest: $classifierDigest,
      schemaVersion: "g073-protected-path-universe/v1"
    },
    repositoryId: $repositoryId,
    runId: $runId,
    startHead: $startHead,
    startTree: $startTree,
    transitionContractDigest: $transitionContractDigest,
    workflowMode: $workflowMode
  }')"
payload_digest="sha256:$(printf '%s' "$payload_json" | bubbles_sha256_stdin)"
sidecar_json="$(jq -cS -n --argjson payload "$payload_json" --arg payloadDigest "$payload_digest" '{payload: $payload, payloadDigest: $payloadDigest, schemaVersion: "planning-source-baseline/v1"}')"
sidecar_tmp="$(mktemp "$runtime_dir/.planning-source-baseline.XXXXXX")"
printf '%s\n' "$sidecar_json" > "$sidecar_tmp"
chmod 0600 "$sidecar_tmp"
baseline_owner="$(id -un)"
if chmod +a "$baseline_owner allow read" "$sidecar_tmp" 2>/dev/null; then
  :
elif command -v setfacl >/dev/null 2>&1; then
  setfacl -m "u:$baseline_owner:r" "$sidecar_tmp" 2>/dev/null || true
fi
mv "$sidecar_tmp" "$sidecar"

reference_json="$(jq -cS -n \
  --arg runId "$run_id" \
  --arg artifactRef "$artifact_ref" \
  --arg payloadDigest "$payload_digest" \
  --arg capturedAt "$captured_at" \
  --arg featureDir "$feature_identity" \
  --arg workflowMode "$workflow_mode" \
  --arg auditProfile "$audit_profile" \
  --arg repositoryId "$repository_id" \
  --arg startHead "$start_head" \
  --arg transitionContractDigest "$contract_digest" \
  '{
    artifactRef: $artifactRef,
    auditProfile: $auditProfile,
    capturedAt: $capturedAt,
    featureDir: $featureDir,
    lifecycle: "ACTIVE",
    payloadDigest: $payloadDigest,
    repositoryId: $repositoryId,
    runId: $runId,
    schemaVersion: "planning-source-baseline-ref/v1",
    startHead: $startHead,
    transitionContractDigest: $transitionContractDigest,
    workflowMode: $workflowMode
  }')"
state_tmp="$(mktemp "$feature_abs/.state.json.planning-baseline.XXXXXX")"
if [[ "$prior_reference" == null ]]; then
  jq --argjson reference "$reference_json" \
    '.execution.planningSourceBaseline = $reference | .execution.planningSourceBaselineHistory = (.execution.planningSourceBaselineHistory // [])' \
    "$state_file" > "$state_tmp"
else
  jq --argjson prior "$prior_reference" --argjson reference "$reference_json" \
    '.execution.planningSourceBaselineHistory = ((.execution.planningSourceBaselineHistory // []) + [$prior]) | .execution.planningSourceBaseline = $reference' \
    "$state_file" > "$state_tmp"
fi
mv "$state_tmp" "$state_file"

protected_entry_count="$(printf '%s' "$snapshot_a" | jq -r 'length')"
status="BASELINE_CAPTURED"
reason_code="BASELINE_CAPTURED"
finish 0