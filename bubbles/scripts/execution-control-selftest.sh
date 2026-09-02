#!/usr/bin/env bash
# ECF-01 adversarial selftest for the execution-control content and event store.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ECF_DRIVER="$SCRIPT_DIR/execution-control-v2-selftest.py"
ECF_STORE="$SCRIPT_DIR/execution-control-store.py"
ECF_LOCK_SELFTEST="$SCRIPT_DIR/execution-control-lock-selftest.py"
ECF_SCHEMA="$SCRIPT_DIR/../schemas/execution-control-event.schema.json"
ECF_SECURITY_OUTCOMES="$SCRIPT_DIR/../registry/execution-control-security-outcomes.json"

for required_input in "$ECF_DRIVER" "$ECF_STORE" "$ECF_LOCK_SELFTEST" "$ECF_SCHEMA" "$ECF_SECURITY_OUTCOMES"; do
	if [[ ! -r "$required_input" ]]; then
		printf 'execution-control-selftest: required input is not readable: %s\n' "$required_input" >&2
		exit 2
	fi
done

python3 "$ECF_DRIVER"

expected_ids="$(
	{
		for number in $(seq -w 1 11); do printf 'SEC-ECF-%s\n' "$number"; done
		for number in $(seq 12 16); do printf 'ECF-SEC-%s\n' "$number"; done
	} | LC_ALL=C sort
)"
actual_ids="$(jq -r '.outcomes[].id' "$ECF_SECURITY_OUTCOMES" | LC_ALL=C sort)"
[[ "$actual_ids" == "$expected_ids" ]] || {
	printf 'execution-control-selftest: security outcome IDs are not the exact closed 16-ID set\n' >&2
	exit 1
}
[[ "$(jq '[.outcomes[] | select(.status == "closed")] | length' "$ECF_SECURITY_OUTCOMES")" -eq 16 ]] || {
	printf 'execution-control-selftest: every security outcome must be closed\n' >&2
	exit 1
}
[[ "$(jq '[.outcomes[].id] | unique | length' "$ECF_SECURITY_OUTCOMES")" -eq 16 ]] || {
	printf 'execution-control-selftest: security outcome IDs must be unique\n' >&2
	exit 1
}

while IFS=$'\t' read -r outcome_id implementation_file implementation_symbol test_file test_marker; do
	implementation_path="$SCRIPT_DIR/../../$implementation_file"
	test_path="$SCRIPT_DIR/../../$test_file"
	[[ -f "$implementation_path" && -f "$test_path" ]] || {
		printf 'execution-control-selftest: %s has an unresolved implementation or test file\n' "$outcome_id" >&2
		exit 1
	}
	grep -Eq "(def|class) ${implementation_symbol}([(:]|$)" "$implementation_path" || {
		printf 'execution-control-selftest: %s implementation symbol is unresolved: %s\n' "$outcome_id" "$implementation_symbol" >&2
		exit 1
	}
	grep -Fq "$test_marker" "$test_path" || {
		printf 'execution-control-selftest: %s adversarial test marker is unresolved: %s\n' "$outcome_id" "$test_marker" >&2
		exit 1
	}
done < <(jq -r '.outcomes[] | [.id, .implementation.file, .implementation.symbol, .adversarialTest.file, .adversarialTest.marker] | @tsv' "$ECF_SECURITY_OUTCOMES")

printf 'execution-control-selftest: exact security-outcome ledger validated (16 closed, unique, resolvable)\n'
