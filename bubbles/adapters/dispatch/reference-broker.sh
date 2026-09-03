#!/usr/bin/env bash
# Hermetic repository-reference broker. This is not a native host interceptor.
set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$SCRIPT_DIR/../../scripts" && pwd)"
ENGINE="$SCRIPTS_DIR/measured-budget-runtime.py"
FINALIZER="$SCRIPTS_DIR/measured-budget-broker-finalize.py"
SNAPSHOT_HELPER="$SCRIPTS_DIR/reference-broker-snapshot.py"
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
  printf '%s\n' '{"adapterId":"reference-broker","ambientInterception":"unsupported","descriptorExec":"unsupported","enforcementKind":"repository-reference","executableSnapshot":{"launchStrategy":"broker-owned-copy","permitted":["linux-regular-native-elf-without-existing-absolute-path-arguments","linux-dash-inline-c"],"refused":["explicit-interpreter-with-script-path","group-world-writable-executable","mach-o","script-pathname","shebang","symlink","unknown-format"]},"mcpInterception":"unsupported","nativeVsCodeInterception":"unsupported"}'
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
command -v jq >/dev/null 2>&1 || { echo "reference-broker: jq is required" >&2; exit 2; }

work_dir="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-reference-broker.XXXXXX")"
chmod 700 "$work_dir"
trap 'rm -rf "$work_dir"' EXIT INT TERM
python3 "$SNAPSHOT_HELPER" --action "$action_file" --permit-consumption "$consumption_file" --output-dir "$work_dir"
snapshot_action="$work_dir/action.json"
snapshot_consumption="$work_dir/permit-consumption.json"

# MBE validates every permit binding, expiry, and one-use state under the ECF
# lock. A failed consumption exits before the child can run.
python3 "$ENGINE" permit-consume --store-root "$store_root" --input "$snapshot_consumption" >/dev/null

argv=()
argv_index=0
while IFS= read -r item; do
  argv[$argv_index]="$item"
  argv_index=$((argv_index + 1))
done < <(jq -r '.argv[1:][]' "$snapshot_action")
expected_argc="$(jq -r '.argv | length - 1' "$snapshot_action")"
[[ "$argv_index" -eq "$expected_argc" ]] || {
  echo "reference-broker: action argv could not be loaded exactly" >&2
  exit 2
}

python3 "$SNAPSHOT_HELPER" launch --output-dir "$work_dir"
child_status="$(<"$work_dir/child-status")"
[[ "$child_status" =~ ^[0-9]+$ ]] || {
  echo "reference-broker: child exit status is invalid" >&2
  exit 4
}

permit_id="$(jq -r '.permit_id // .permitId // ""' "$snapshot_consumption")"
[[ -n "$permit_id" ]] || { echo "reference-broker: permit identity unavailable" >&2; exit 2; }
at="$(jq -r '.consumed_at // .consumedAt // ""' "$snapshot_consumption")"
[[ -n "$at" ]] || { echo "reference-broker: dispatch time unavailable" >&2; exit 2; }
python3 "$FINALIZER" context --store-root "$store_root" --permit-id "$permit_id" --child-exit-code "$child_status" --at "$at" >"$work_dir/receipt-input.json"
BUBBLES_USAGE_REFERENCE_TEST=enabled bash "$USAGE_ADAPTER" receipt "$work_dir/receipt-input.json" >"$work_dir/receipt.json"
python3 "$ENGINE" usage-record --store-root "$store_root" --input "$work_dir/receipt.json" >/dev/null
[[ -n "${BUBBLES_USAGE_REFERENCE_AUTHORITY:-}" ]] || { echo "reference-broker: receipt authority is not configured" >&2; exit 4; }
jq -cS --arg at "$at" '{receipt:.,verifiedAt:$at}' "$work_dir/receipt.json" >"$work_dir/verification-payload.json"
chmod 600 "$work_dir/verification-payload.json"
python3 "$SCRIPTS_DIR/security-authority.py" sign usage-receipt "$BUBBLES_USAGE_REFERENCE_AUTHORITY" "$work_dir/verification-payload.json" >"$work_dir/authenticator.json"
jq -cS --slurpfile auth "$work_dir/authenticator.json" '. + {authenticator:$auth[0].authenticator}' "$work_dir/verification-payload.json" >"$work_dir/verification-input.json"
chmod 600 "$work_dir/verification-input.json"
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