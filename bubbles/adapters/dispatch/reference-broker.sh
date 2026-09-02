#!/usr/bin/env bash
# Hermetic repository-reference broker. This is not a native host interceptor.
set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$SCRIPT_DIR/../../scripts" && pwd)"
ENGINE="$SCRIPTS_DIR/measured-budget-runtime.py"
FINALIZER="$SCRIPTS_DIR/measured-budget-broker-finalize.py"
USAGE_ADAPTER="$SCRIPT_DIR/../usage/reference-test.sh"

usage() {
  cat >&2 <<'EOF'
Usage: reference-broker.sh capabilities
       reference-broker.sh dispatch --store-root PATH --permit-consumption FILE
         --action FILE

The action file is {"argv":[...],"actionDigest":"sha256:..."}. The digest is
sha256 over canonical JSON {"argv":[...]}. The consumption file carries every
permit binding required by MBE-1. Native VS Code, MCP, and ambient interception
are unsupported. This broker gates only the child argv routed through it.
EOF
}

digest_text() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    echo "reference-broker: sha256 utility unavailable" >&2
    return 2
  fi
}

[[ $# -gt 0 ]] || { usage; exit 2; }
verb="$1"
shift
if [[ "$verb" == "capabilities" ]]; then
  printf '%s\n' '{"adapterId":"reference-broker","ambientInterception":"unsupported","enforcementKind":"repository-reference","mcpInterception":"unsupported","nativeVsCodeInterception":"unsupported"}'
  exit 0
fi
[[ "$verb" == "dispatch" ]] || { echo "reference-broker: unsupported verb '$verb'" >&2; exit 2; }

store_root=""
consumption_file=""
action_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --store-root) store_root="${2:-}"; shift 2 ;;
    --permit-consumption) consumption_file="${2:-}"; shift 2 ;;
    --action) action_file="${2:-}"; shift 2 ;;
    *) echo "reference-broker: unknown option '$1'" >&2; exit 2 ;;
  esac
done
for required in "$store_root" "$consumption_file" "$action_file"; do
  [[ -n "$required" ]] || { usage; exit 2; }
done
for required_file in "$consumption_file" "$action_file"; do
  [[ -f "$required_file" ]] || { echo "reference-broker: required input unavailable" >&2; exit 2; }
done
command -v jq >/dev/null 2>&1 || { echo "reference-broker: jq is required" >&2; exit 2; }

# No shell strings, control characters, environment assignments, or relative
# executables are accepted. The exact argv is the authorized action.
jq -e '.argv | type == "array" and length > 0 and all(.[]; type == "string" and length > 0 and (contains("\n")|not) and (contains("\r")|not) and (contains("\u0000")|not))' "$action_file" >/dev/null || {
  echo "reference-broker: action argv is invalid" >&2
  exit 2
}
executable="$(jq -r '.argv[0]' "$action_file")"
case "$executable" in /*) ;; *) echo "reference-broker: executable must be an absolute path" >&2; exit 2 ;; esac
[[ -x "$executable" && -f "$executable" ]] || { echo "reference-broker: executable is unavailable" >&2; exit 2; }

canonical_action="$(jq -cS '{argv:.argv}' "$action_file")"
computed_digest="sha256:$(printf '%s' "$canonical_action" | digest_text)"
declared_digest="$(jq -r '.actionDigest // ""' "$action_file")"
permit_digest="$(jq -r '.action_digest // .actionDigest // ""' "$consumption_file")"
[[ "$declared_digest" == "$computed_digest" && "$permit_digest" == "$computed_digest" ]] || {
  echo "reference-broker: action digest does not match permit binding" >&2
  exit 4
}

# MBE validates every permit binding, expiry, and one-use state under the ECF
# lock. A failed consumption exits before the child can run.
python3 "$ENGINE" permit-consume --store-root "$store_root" --input "$consumption_file" >/dev/null

argv=()
argv_index=0
while IFS= read -r item; do
  argv[$argv_index]="$item"
  argv_index=$((argv_index + 1))
done < <(jq -r '.argv[]' "$action_file")
expected_argc="$(jq -r '.argv | length' "$action_file")"
[[ "$argv_index" -eq "$expected_argc" ]] || {
  echo "reference-broker: action argv could not be loaded exactly" >&2
  exit 2
}

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-reference-broker.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT INT TERM
child_status=0
env -i PATH=/usr/bin:/bin HOME="$work_dir" LANG=C LC_ALL=C "${argv[@]}" >"$work_dir/stdout" 2>"$work_dir/stderr" || child_status=$?

permit_id="$(jq -r '.permit_id // .permitId // ""' "$consumption_file")"
[[ -n "$permit_id" ]] || { echo "reference-broker: permit identity unavailable" >&2; exit 2; }
at="$(jq -r '.consumed_at // .consumedAt // ""' "$consumption_file")"
[[ -n "$at" ]] || { echo "reference-broker: dispatch time unavailable" >&2; exit 2; }
python3 "$FINALIZER" context --store-root "$store_root" --permit-id "$permit_id" --child-exit-code "$child_status" --at "$at" >"$work_dir/receipt-input.json"
BUBBLES_USAGE_REFERENCE_TEST=enabled bash "$USAGE_ADAPTER" receipt "$work_dir/receipt-input.json" >"$work_dir/receipt.json"
python3 "$ENGINE" usage-record --store-root "$store_root" --input "$work_dir/receipt.json" >/dev/null
jq -cS --arg at "$at" '{receipt:.,verifiedAt:$at}' "$work_dir/receipt.json" >"$work_dir/verification-input.json"
BUBBLES_USAGE_REFERENCE_TEST=enabled bash "$USAGE_ADAPTER" verify-receipt "$work_dir/verification-input.json" >"$work_dir/verification.json"
python3 "$ENGINE" usage-record --store-root "$store_root" --input "$work_dir/verification.json" >/dev/null
receipt_id="$(jq -r '.usageReceiptId' "$work_dir/receipt.json")"
verification_id="$(jq -r '.verificationId' "$work_dir/verification.json")"
settlement_json="$(python3 "$FINALIZER" settle --store-root "$store_root" --permit-id "$permit_id" --usage-receipt-id "$receipt_id" --receipt-verification-id "$verification_id" --at "$at")"
outcome="$(printf '%s' "$settlement_json" | jq -r '.terminalState')"
stdout_bytes="$(wc -c <"$work_dir/stdout" | tr -d ' ')"
stderr_bytes="$(wc -c <"$work_dir/stderr" | tr -d ' ')"
printf '{"childExitCode":%s,"contractType":"reference-dispatch-result","nativeHostInterception":"unsupported","schemaVersion":1,"settlement":"%s","stderrBytes":%s,"stdoutBytes":%s}\n' "$child_status" "$outcome" "$stderr_bytes" "$stdout_bytes"
exit "$child_status"