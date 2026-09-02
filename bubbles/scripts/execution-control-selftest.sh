#!/usr/bin/env bash
# ECF-01 adversarial selftest for the execution-control content and event store.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORE_IMPLEMENTATION="$SCRIPT_DIR/execution-control-store.py"
EVENT_SCHEMA="$SCRIPT_DIR/../schemas/execution-control-event.schema.json"
# shellcheck source=execution-control-lib.sh
source "$SCRIPT_DIR/execution-control-lib.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT INT TERM
STORE="$WORK/store"
GENESIS="sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
passes=0
failures=0
pass() { printf 'PASS: %s\n' "$1"; passes=$((passes + 1)); }
fail() { printf 'FAIL: %s\n' "$1"; failures=$((failures + 1)); }
expect_fail() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then fail "$label"; else pass "$label"; fi
}

printf '{"beta":2,"alpha":1}\n' >"$WORK/object-a.json"
object_result="$(bubbles_execution_control_object_put "$STORE" "$WORK/object-a.json")"
object_digest="$(printf '%s' "$object_result" | python3 -c 'import json,sys; print(json.load(sys.stdin)["objectDigest"])')"
[[ "$object_digest" == sha256:* ]] && pass "object-put returns a typed digest" || fail "object-put returns a typed digest"

printf '{ "alpha" : 1, "beta" : 2 }\n' >"$WORK/object-b.json"
object_result_2="$(bubbles_execution_control_object_put "$STORE" "$WORK/object-b.json")"
object_digest_2="$(printf '%s' "$object_result_2" | python3 -c 'import json,sys; print(json.load(sys.stdin)["objectDigest"])')"
[[ "$object_digest" == "$object_digest_2" ]] && pass "canonical identity ignores member order and whitespace" || fail "canonical identity ignores member order and whitespace"

object_path="$STORE/objects/${object_digest:7:2}/${object_digest:7}"
[[ "$(cat "$object_path")" == '{"alpha":1,"beta":2}' ]] && pass "object bytes are canonical JSON" || fail "object bytes are canonical JSON"
[[ "$(stat -c '%a' "$STORE")" == 700 && "$(stat -c '%a' "$object_path")" == 600 ]] && pass "store permissions are owner-private" || fail "store permissions are owner-private"

printf '{"alpha":1,"alpha":2}\n' >"$WORK/duplicate.json"
expect_fail "duplicate JSON members are rejected" bubbles_execution_control_object_put "$STORE" "$WORK/duplicate.json"
printf '{"value":NaN}\n' >"$WORK/nonfinite.json"
expect_fail "non-finite JSON numbers are rejected" bubbles_execution_control_object_put "$STORE" "$WORK/nonfinite.json"
[[ -f "$STORE_IMPLEMENTATION" ]] && pass "Python store implementation is present" || fail "Python store implementation is present"
if python3 -c 'import json,sys; s=json.load(open(sys.argv[1])); assert s["additionalProperties"] is False; assert set(s["properties"]["eventType"]["enum"]) == {"RECORD","CORRECT","SUPERSEDE"}' "$EVENT_SCHEMA"; then pass "event schema is closed over the ECF-01 event vocabulary"; else fail "event schema is closed over the ECF-01 event vocabulary"; fi

cat >"$WORK/event-1.json" <<EOF
{"contractType":"execution-control-event","schemaVersion":1,"eventType":"RECORD","eventId":"event-1","recordedAt":"2026-08-27T00:00:00Z","occurrenceId":"occurrence-1","attemptId":"attempt-1","posture":"shadow","subject":{"kind":"command","id":"subject-private-1"},"objectDigest":"$object_digest","supersedesEventId":null,"extensions":[]}
EOF
event_result="$(bubbles_execution_control_append "$STORE" 0 "$GENESIS" "$WORK/event-1.json")"
head_digest="$(printf '%s' "$event_result" | python3 -c 'import json,sys; print(json.load(sys.stdin)["eventDigest"])')"
[[ "$head_digest" == sha256:* ]] && pass "compare-and-append creates the first chained event" || fail "compare-and-append creates the first chained event"
expect_fail "stale compare-and-append predecessor is rejected" bubbles_execution_control_append "$STORE" 0 "$GENESIS" "$WORK/event-1.json"

cat >"$WORK/event-2.json" <<EOF
{"contractType":"execution-control-event","schemaVersion":1,"eventType":"CORRECT","eventId":"event-2","recordedAt":"2026-08-27T00:00:01Z","occurrenceId":"occurrence-1","attemptId":"attempt-2","posture":"reference-enforce","subject":{"kind":"command","id":"subject-private-1"},"objectDigest":"$object_digest","supersedesEventId":"event-1","extensions":[]}
EOF
event_result_2="$(bubbles_execution_control_append "$STORE" 1 "$head_digest" "$WORK/event-2.json")"
head_digest_2="$(printf '%s' "$event_result_2" | python3 -c 'import json,sys; print(json.load(sys.stdin)["eventDigest"])')"
[[ "$head_digest_2" == sha256:* ]] && pass "correction appends without rewriting history" || fail "correction appends without rewriting history"

read_result="$(bubbles_execution_control_read "$STORE" 1 10)"
[[ "$(printf '%s' "$read_result" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["events"]))')" == 2 ]] && pass "bounded read returns verified events" || fail "bounded read returns verified events"
verify_result="$(bubbles_execution_control_verify "$STORE")"
[[ "$(printf '%s' "$verify_result" | python3 -c 'import json,sys; print(json.load(sys.stdin)["verified"])')" == True ]] && pass "full chain and object verification succeeds" || fail "full chain and object verification succeeds"

bubbles_execution_control_project "$STORE" "$WORK/projection.json" >/dev/null
if ! grep -Eq 'subject-private|occurrence-1|attempt-1|attempt-2|recordedAt' "$WORK/projection.json"; then pass "projection excludes raw identities and timestamps"; else fail "projection excludes raw identities and timestamps"; fi
[[ "$(python3 -c 'import json,sys; print(sorted(json.load(open(sys.argv[1]))))' "$WORK/projection.json")" == "['contractType', 'eventCount', 'eventTypeCounts', 'headDigest', 'objectCount', 'postureCounts', 'schemaVersion']" ]] && pass "projection exposes structural fields only" || fail "projection exposes structural fields only"

cp "$STORE/events.jsonl" "$WORK/events.clean"
python3 -c 'import json,sys; p=sys.argv[1]; rows=open(p).read().splitlines(); v=json.loads(rows[0]); v["posture"]="off"; rows[0]=json.dumps(v,separators=(",",":"),sort_keys=True); open(p,"w").write("\n".join(rows)+"\n")' "$STORE/events.jsonl"
chmod 600 "$STORE/events.jsonl"
expect_fail "tampered event content is rejected" bubbles_execution_control_verify "$STORE"
cp "$WORK/events.clean" "$STORE/events.jsonl"
chmod 600 "$STORE/events.jsonl"

printf '%s\n' "$event_result" | python3 -c 'import json,sys; e=json.load(sys.stdin); print(json.dumps({"contractType":"execution-control-head","schemaVersion":1,"sequence":e["sequence"],"eventDigest":e["eventDigest"]},separators=(",",":"),sort_keys=True))' >"$STORE/head.json"
printf '%s\n' "$event_result_2" | python3 -c 'import json,sys; e=json.load(sys.stdin); print(json.dumps({"contractType":"execution-control-pending","schemaVersion":1,"expectedSequence":1,"expectedHeadDigest":e["previousEventDigest"],"event":e},separators=(",",":"),sort_keys=True))' >"$STORE/pending.json"
chmod 600 "$STORE/head.json" "$STORE/pending.json"
if bubbles_execution_control_verify "$STORE" >/dev/null && [[ ! -e "$STORE/pending.json" ]]; then pass "exact ledger-tip pending state recovers after a crash"; else fail "exact ledger-tip pending state recovers after a crash"; fi

printf '{"contractType":"execution-control-head","schemaVersion":1,"sequence":0,"eventDigest":"%s"}\n' "$GENESIS" >"$STORE/head.json"
chmod 600 "$STORE/head.json"
expect_fail "head rollback is rejected" bubbles_execution_control_verify "$STORE"
printf '%s\n' "$event_result_2" | python3 -c 'import json,sys; e=json.load(sys.stdin); print(json.dumps({"contractType":"execution-control-head","schemaVersion":1,"sequence":e["sequence"],"eventDigest":e["eventDigest"]},separators=(",",":"),sort_keys=True))' >"$STORE/head.json"
chmod 600 "$STORE/head.json"

printf '{"contractType":"execution-control-pending","schemaVersion":1,"expectedSequence":2,"expectedHeadDigest":"%s","event":%s}\n' "$head_digest_2" "$event_result_2" >"$STORE/pending.json"
chmod 600 "$STORE/pending.json"
expect_fail "impossible pending recovery is rejected" bubbles_execution_control_verify "$STORE"
rm -f "$STORE/pending.json"

chmod 644 "$STORE/head.json"
expect_fail "permissive store file mode is rejected" bubbles_execution_control_verify "$STORE"
chmod 600 "$STORE/head.json"

mv "$STORE/projections" "$STORE/projections.real"
ln -s "$STORE/projections.real" "$STORE/projections"
expect_fail "symlinked store paths are rejected" bubbles_execution_control_verify "$STORE"
rm "$STORE/projections"
mv "$STORE/projections.real" "$STORE/projections"

printf '{"beta":2,"alpha":1}\n' >"$WORK/object-c.json"
ln -s "$WORK/object-c.json" "$WORK/object-link.json"
expect_fail "symlinked input files are rejected" bubbles_execution_control_object_put "$STORE" "$WORK/object-link.json"

cat >"$WORK/event-duplicate-attempt.json" <<EOF
{"contractType":"execution-control-event","schemaVersion":1,"eventType":"RECORD","eventId":"event-3","recordedAt":"2026-08-27T00:00:02Z","occurrenceId":"occurrence-2","attemptId":"attempt-2","posture":"shadow","subject":{"kind":"command","id":"subject-private-2"},"objectDigest":"$object_digest","supersedesEventId":null,"extensions":[]}
EOF
expect_fail "duplicate attempt identity is rejected" bubbles_execution_control_append "$STORE" 2 "$head_digest_2" "$WORK/event-duplicate-attempt.json"

cat >"$WORK/event-race-a.json" <<EOF
{"contractType":"execution-control-event","schemaVersion":1,"eventType":"RECORD","eventId":"event-race-a","recordedAt":"2026-08-27T00:00:03Z","occurrenceId":"occurrence-race-a","attemptId":"attempt-race-a","posture":"shadow","subject":{"kind":"command","id":"subject-race-a"},"objectDigest":"$object_digest","supersedesEventId":null,"extensions":[]}
EOF
cat >"$WORK/event-race-b.json" <<EOF
{"contractType":"execution-control-event","schemaVersion":1,"eventType":"RECORD","eventId":"event-race-b","recordedAt":"2026-08-27T00:00:03Z","occurrenceId":"occurrence-race-b","attemptId":"attempt-race-b","posture":"shadow","subject":{"kind":"command","id":"subject-race-b"},"objectDigest":"$object_digest","supersedesEventId":null,"extensions":[]}
EOF
race_successes=0
bubbles_execution_control_append "$STORE" 2 "$head_digest_2" "$WORK/event-race-a.json" >/dev/null 2>&1 & race_a=$!
bubbles_execution_control_append "$STORE" 2 "$head_digest_2" "$WORK/event-race-b.json" >/dev/null 2>&1 & race_b=$!
if wait "$race_a"; then race_successes=$((race_successes + 1)); fi
if wait "$race_b"; then race_successes=$((race_successes + 1)); fi
[[ "$race_successes" -eq 1 ]] && pass "portable lock serializes concurrent compare-and-append" || fail "portable lock serializes concurrent compare-and-append"

if [[ "$failures" -ne 0 ]]; then
  printf 'execution-control-selftest: %s passed, %s failed\n' "$passes" "$failures" >&2
  exit 1
fi
printf 'execution-control-selftest: %s assertions passed\n' "$passes"
