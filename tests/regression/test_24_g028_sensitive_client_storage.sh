#!/usr/bin/env bash
set -uo pipefail

# BUG-013 persistent production-scanner regression for G028 Scan 2B.
#
# The fixture deliberately pairs operations that line-cooccurrence cannot
# distinguish. Every assertion executes the canonical scanner; no classifier
# behavior is reproduced in this test.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_SCRIPT="$SCRIPT_DIR/test_24_g028_sensitive_client_storage.sh"
SCANNER="$REPO_ROOT/bubbles/scripts/implementation-reality-scan.sh"
SELFTEST="$REPO_ROOT/bubbles/scripts/implementation-reality-scan-selftest.sh"
GUARD_LIB="$REPO_ROOT/bubbles/scripts/guard-lib.sh"
PYTHON_ENV="$REPO_ROOT/bubbles/scripts/python-env.sh"

for required_file in "$SCANNER" "$SELFTEST" "$GUARD_LIB" "$PYTHON_ENV"; do
  if [[ ! -f "$required_file" ]]; then
    printf 'test_24_g028_sensitive_client_storage: required canonical surface missing: %s\n' "$required_file" >&2
    exit 2
  fi
done

# shellcheck source=/dev/null
source "$GUARD_LIB"

# The managed-interpreter scenario below decides its own reachability with the
# SAME resolver the scan uses, so it can never skip coverage the scan would have
# run. python-env.sh is listed as a required surface above rather than probed
# for here: an unsourced resolver made every call to it a `command not found`,
# the scenario skipped under EVERY environment, and the skip line then reported
# the absent function as a statement about where the venv lives. Refusing loudly
# on a missing module is the only outcome that cannot be misread as that again.
# shellcheck source=/dev/null
source "$PYTHON_ENV"

# The managed selftest's successful producer contract always executes real
# Python. Resolve that prerequisite through the production API before entering
# sanitized fixtures, then pass the exact executable explicitly. A host with no
# runnable Python cannot satisfy this persistent regression and fails loudly.
SELFTEST_REAL_PYTHON=""
if bubbles_python_resolve_runnable >/dev/null; then
  SELFTEST_REAL_PYTHON="$BUBBLES_PYTHON_RUNNABLE"
else
  printf 'test_24_g028_sensitive_client_storage: runnable Python prerequisite failed: %s\n' \
    "$BUBBLES_PYTHON_RUNNABLE_REASON" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug013-XXXXXXXX")"
FIXTURE_REPO="$WORKSPACE/repo"
FEATURE_DIR="$FIXTURE_REPO/specs/001-sensitive-storage"
SOURCE_FILE="$FIXTURE_REPO/src/provider-client.js"
DART_SOURCE_FILE="$FIXTURE_REPO/src/provider-preferences.dart"
CONFIG_FILE="$FIXTURE_REPO/.github/bubbles-project.yaml"
RUN_OUTPUT=""
RUN_STATUS=0
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
BUG039_CASCADE_VERIFIED=0
TEST_COMPLETED=0
TEST_LIFECYCLE_PID=''
TEST_LIFECYCLE_DESCENDANT_PID=''

terminate_test_lifecycle_tree() {
  local waited=0
  if [[ "$TEST_LIFECYCLE_PID" =~ ^[1-9][0-9]*$ ]]; then
    kill -TERM -- "-$TEST_LIFECYCLE_PID" 2>/dev/null ||
      kill -TERM "$TEST_LIFECYCLE_PID" 2>/dev/null || true
    while kill -0 -- "-$TEST_LIFECYCLE_PID" 2>/dev/null && [[ "$waited" -lt 5 ]]; do
      /bin/sleep 1
      waited=$((waited + 1))
    done
    kill -KILL -- "-$TEST_LIFECYCLE_PID" 2>/dev/null ||
      kill -KILL "$TEST_LIFECYCLE_PID" 2>/dev/null || true
    wait "$TEST_LIFECYCLE_PID" 2>/dev/null || true
  fi
  if [[ "$TEST_LIFECYCLE_DESCENDANT_PID" =~ ^[1-9][0-9]*$ ]]; then
    kill -KILL "$TEST_LIFECYCLE_DESCENDANT_PID" 2>/dev/null || true
    wait "$TEST_LIFECYCLE_DESCENDANT_PID" 2>/dev/null || true
  fi
  TEST_LIFECYCLE_PID=''
  TEST_LIFECYCLE_DESCENDANT_PID=''
}

cleanup() {
  local status=$?
  trap - EXIT HUP INT TERM
  bubbles_python_terminate_active_tree
  terminate_test_lifecycle_tree
  /bin/rm -rf "$WORKSPACE"
  if [[ "$TEST_COMPLETED" -ne 1 && "$status" -eq 0 ]]; then
    printf '%s\n' 'FAIL: test_24 exited before its completion verdict' >&2
    status=1
  fi
  if [[ -n "${BUBBLES_TEST24_DONE_FILE:-}" ]]; then
    printf '%s\n' "$status" >"$BUBBLES_TEST24_DONE_FILE"
  fi
  exit "$status"
}

test_signal() {
  local status="$1"
  trap - HUP INT TERM
  exit "$status"
}

trap cleanup EXIT
trap 'test_signal 129' HUP
trap 'test_signal 130' INT
trap 'test_signal 143' TERM

if [[ -n "${BUBBLES_TEST24_CHILD_MODE:-}" ]]; then
  if [[ -z "${BUBBLES_TEST24_READY_FILE:-}" ]]; then
    echo "test_24 child mode requires a ready file" >&2
    exit 2
  fi
  case "$BUBBLES_TEST24_CHILD_MODE" in
    premature-exit)
      printf '%s\t\n' "$WORKSPACE" >"$BUBBLES_TEST24_READY_FILE"
      exit 0
      ;;
    timeout-exit)
      printf '%s\t\n' "$WORKSPACE" >"$BUBBLES_TEST24_READY_FILE"
      exit 124
      ;;
    interrupt-hold)
      /bin/sleep 300 &
      test_descendant_pid=$!
      TEST_LIFECYCLE_DESCENDANT_PID="$test_descendant_pid"
      printf '%s\t%s\n' "$WORKSPACE" "$test_descendant_pid" >"$BUBBLES_TEST24_READY_FILE"
      wait "$test_descendant_pid"
      ;;
    *)
      echo "test_24 child mode is invalid" >&2
      exit 2
      ;;
  esac
fi

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'PASS: %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'FAIL: %s\n' "$1" >&2
}

# A skip is not a pass. It is counted and reported separately so an unmet
# coverage claim can never be scraped out of this transcript as a satisfied one.
skip() {
  SKIP_COUNT=$((SKIP_COUNT + 1))
  printf 'SKIP: %s\n' "$1"
}

assert_test_lifecycle_fails_closed() {
  local mode="$1"
  local signal_name="$2"
  local expected_status="$3"
  local label="$4"
  local ready_file="$WORKSPACE/lifecycle-$mode-$signal_name.ready"
  local done_file="$WORKSPACE/lifecycle-$mode-$signal_name.done"
  local output_file="$WORKSPACE/lifecycle-$mode-$signal_name.log"
  local child_pid=""
  local child_workspace=""
  local child_descendant_pid=""
  local child_status=0
  local cleanup_status=""
  local deadline=0
  local monitor_was_enabled=0

  [[ "$-" == *m* ]] && monitor_was_enabled=1
  set -m
  BUBBLES_TEST24_CHILD_MODE="$mode" \
    BUBBLES_TEST24_READY_FILE="$ready_file" \
    BUBBLES_TEST24_DONE_FILE="$done_file" \
    /bin/bash "$TEST_SCRIPT" >"$output_file" 2>&1 </dev/null &
  child_pid=$!
  TEST_LIFECYCLE_PID="$child_pid"
  [[ "$monitor_was_enabled" -eq 1 ]] || set +m

  deadline=$((SECONDS + 10))
  while [[ ! -s "$ready_file" ]] && kill -0 "$child_pid" 2>/dev/null && [[ "$SECONDS" -lt "$deadline" ]]; do
    /bin/sleep 1
  done
  if [[ ! -s "$ready_file" ]]; then
    terminate_test_lifecycle_tree
    fail "$label reaches its bounded ready point"
    return
  fi
  IFS=$'\t' read -r child_workspace child_descendant_pid <"$ready_file"
  TEST_LIFECYCLE_DESCENDANT_PID="$child_descendant_pid"

  if [[ "$signal_name" != "NONE" ]]; then
    kill -"$signal_name" -- "-$child_pid" 2>/dev/null || kill -"$signal_name" "$child_pid" 2>/dev/null || true
  fi
  deadline=$((SECONDS + 10))
  while [[ ! -s "$done_file" ]] && kill -0 "$child_pid" 2>/dev/null && [[ "$SECONDS" -lt "$deadline" ]]; do
    /bin/sleep 1
  done
  if [[ ! -s "$done_file" ]]; then
    terminate_test_lifecycle_tree
    fail "$label reaches its bounded cleanup-complete point"
    return
  fi
  cleanup_status="$(/bin/cat "$done_file")"
  wait "$child_pid" 2>/dev/null || child_status=$?
  TEST_LIFECYCLE_PID=''
  if [[ "$child_status" -eq "$expected_status" && "$cleanup_status" == "$expected_status" ]]; then
    pass "$label preserves fatal exit $expected_status"
  else
    fail "$label expected exit $expected_status, got wait=$child_status cleanup=$cleanup_status"
  fi
  if [[ -n "$child_workspace" && ! -e "$child_workspace" ]]; then
    pass "$label removes its temporary tree"
  else
    fail "$label removes its temporary tree (still present: $child_workspace)"
    [[ -z "$child_workspace" ]] || rm -rf "$child_workspace"
  fi
  if [[ -z "$child_descendant_pid" ]] || ! kill -0 "$child_descendant_pid" 2>/dev/null; then
    pass "$label leaves no descendant process"
  else
    fail "$label leaked descendant $child_descendant_pid"
    kill -KILL "$child_descendant_pid" 2>/dev/null || true
  fi
  TEST_LIFECYCLE_DESCENDANT_PID=''
  if /usr/bin/grep -Fq 'test_24_g028_sensitive_client_storage: ' "$output_file"; then
    fail "$label must not emit a success summary"
  else
    pass "$label emits no success summary"
  fi
}

assert_status() {
  local expected="$1"
  local label="$2"

  if [[ "$RUN_STATUS" -eq "$expected" ]]; then
    pass "$label"
  else
    fail "$label (expected exit $expected, got $RUN_STATUS)"
  fi
}

assert_contains() {
  local expected="$1"
  local label="$2"

  if grep -Fq -- "$expected" <<<"$RUN_OUTPUT"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_not_contains() {
  local forbidden="$1"
  local label="$2"

  if grep -Fq -- "$forbidden" <<<"$RUN_OUTPUT"; then
    fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

line_for() {
  local marker="$1"
  grep -nF -- "$marker" "$SOURCE_FILE" | cut -d: -f1
}

line_for_file() {
  local marker="$1"
  local source_file="$2"
  grep -nF -- "$marker" "$source_file" | cut -d: -f1
}

assert_finding() {
  local line_number="$1"
  local reason="$2"
  local label="$3"

  if printf '%s\n' "$RUN_OUTPUT" | awk -v line_number="$line_number" -v reason="$reason" '
    index($0, "VIOLATION [SENSITIVE_CLIENT_STORAGE]") && $0 ~ (":" line_number "$") {
      at_target = 1
      next
    }
    at_target && index($0, "reason=" reason) {
      found = 1
    }
    at_target && index($0, "VIOLATION [") {
      at_target = 0
    }
    END { exit found ? 0 : 1 }
  '; then
    pass "$label"
  else
    fail "$label (line $line_number missing reason=$reason)"
  fi
}

assert_no_finding() {
  local line_number="$1"
  local label="$2"

  if printf '%s\n' "$RUN_OUTPUT" | grep -Eq "VIOLATION \[SENSITIVE_CLIENT_STORAGE\].*:${line_number}$"; then
    fail "$label (unexpected finding at line $line_number)"
  else
    pass "$label"
  fi
}

run_scanner() {
  local output_file="$WORKSPACE/scanner-output.txt"
  RUN_OUTPUT=""
  RUN_STATUS=0

  if (
    cd "$FIXTURE_REPO" || exit 2
    bubbles_run_with_timeout 180 bash "$SCANNER" "$FEATURE_DIR" --verbose
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "$RUN_OUTPUT"
}

write_valid_config() {
  mkdir -p "$(dirname "$CONFIG_FILE")"
  cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
      - path: src/provider-client.js
        storage: sessionStorage
        key: providerCredential
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
}

write_fixture() {
  mkdir -p "$FEATURE_DIR" "$(dirname "$SOURCE_FILE")"
  cat > "$FEATURE_DIR/scopes.md" <<'MARKDOWN'
# Scope 1: Sensitive Storage Fixture

**Status:** In Progress

## Implementation Plan

Exercise the production G028 scanner against one semantic storage matrix.

### Implementation Files

- `src/provider-client.js`
- `src/provider-preferences.dart`
MARKDOWN

  cat > "$SOURCE_FILE" <<'JAVASCRIPT'
const LITERAL_KEY = "marketProvider:twelvedata:apiKey";
const KEY_ALIAS_ONE = LITERAL_KEY;
const KEY_ALIAS_TWO = KEY_ALIAS_ONE;
const SESSION_KEY = "marketProvider:twelvedata:apiKey";
const UNKNOWN_SESSION_KEY = "marketProvider:unknown-vendor:apiKey";
const CACHE_KEY = "marketCache:latestSnapshot";
const PROVIDER_ID = "twelvedata";
const OBJECT_SESSION_KEY = "providerCredential";

export function literalDurableCredential() {
  localStorage.setItem("marketProvider:twelvedata:apiKey", "BUG013_CREDENTIAL_VALUE_MUST_NOT_APPEAR");
}

export function aliasDurableCredential(providerCredential) {
  localStorage.setItem(KEY_ALIAS_TWO, providerCredential);
}

function credentialStorageKey() {
  return "providerCredentials";
}

export function helperIndirectDurableCredential(payload) {
  const helperKey = credentialStorageKey();
  localStorage.setItem(helperKey, payload);
}

function dynamicCredentialStorageKey(scope) {
  return `${scope}:credentials`;
}

export function dynamicHelperDurableCredential(scope, payload) {
  const dynamicDurableKey = dynamicCredentialStorageKey(scope);
  localStorage.setItem(dynamicDurableKey, payload);
}

export function exactSessionCredential(providerCredential) {
  sessionStorage.setItem(SESSION_KEY, providerCredential);
}

export function exactObjectSessionCredential(providerCredential) {
  const providerRecord = { provider: PROVIDER_ID, apiKey: providerCredential };
  sessionStorage.setItem(OBJECT_SESSION_KEY, JSON.stringify(providerRecord));
}

export function unknownSessionCredential(providerCredential) {
  sessionStorage.setItem(UNKNOWN_SESSION_KEY, providerCredential);
}

export function dynamicSessionCredential(provider, providerCredential) {
  const dynamicKey = `marketProvider:${provider}:apiKey`;
  sessionStorage.setItem(dynamicKey, providerCredential);
}

export function durableInsteadOfSession(providerCredential) {
  localStorage.setItem(SESSION_KEY, providerCredential);
}

export function unresolvedLocalStorageOperation(providerCredential) {
  localStorage.persistCredential(SESSION_KEY, providerCredential);
}

export function forbiddenBearer(authBearerToken) {
  sessionStorage.setItem(SESSION_KEY, authBearerToken);
}

export function forbiddenLoginSession(loginSessionSecret) {
  sessionStorage.setItem(SESSION_KEY, loginSessionSecret);
}

export function forbiddenRefresh(refreshToken) {
  sessionStorage.setItem(SESSION_KEY, refreshToken);
}

export function forbiddenPayment(paymentCardNumber) {
  sessionStorage.setItem(SESSION_KEY, paymentCardNumber);
}

export function forbiddenCvv(cardCvv) {
  sessionStorage.setItem(SESSION_KEY, cardCvv);
}

export function safeMarketCache(marketSnapshot) {
  localStorage.setItem(CACHE_KEY, JSON.stringify(marketSnapshot)); // No auth token, payment secret, or session credential is stored here.
}

export function safeRemoval(authToken) {
  authToken && localStorage.removeItem("legacyAuthToken");
}

export function unsafeBeforeScrub(providerCredential) {
  const unsafeRecord = { apiKey: providerCredential, price: 42 };
  localStorage.setItem("marketCache:beforeScrub", JSON.stringify(unsafeRecord));
}

export function safeScrubbedRewrite(providerCredential, authBearerToken) {
  const scrubbedRecord = { apiKey: providerCredential, authToken: authBearerToken, price: 42 };
  delete scrubbedRecord.apiKey;
  delete scrubbedRecord.authToken;
  localStorage.setItem("marketCache:scrubbed", JSON.stringify(scrubbedRecord));
}

export function unsafeConditionalScrub(providerCredential, shouldScrub) {
  const conditionalRecord = { apiKey: providerCredential, price: 42 };
  if (shouldScrub) {
    delete conditionalRecord.apiKey;
  }
  localStorage.setItem("marketCache:conditionalScrub", JSON.stringify(conditionalRecord));
}

const separateHelperRecord = { apiKey: providerCredential, price: 42 };

function scrubSeparateHelperRecord() {
  delete separateHelperRecord.apiKey;
}

export function unsafeSeparateHelperWrite() {
  localStorage.setItem("marketCache:separateHelper", JSON.stringify(separateHelperRecord));
}

export function safeLoadedScrub(serializedRecord) {
  const loadedRecord = JSON.parse(serializedRecord);
  if (loadedRecord.apiKey || loadedRecord.refreshToken) {
    delete loadedRecord.apiKey;
    delete loadedRecord.refreshToken;
    localStorage.setItem("marketCache:loadedScrubbed", JSON.stringify(loadedRecord));
  }
}

export function unsafePartialLoadedScrub(serializedRecord) {
  const partialLoadedRecord = JSON.parse(serializedRecord);
  if (partialLoadedRecord.apiKey || partialLoadedRecord.refreshToken) {
    delete partialLoadedRecord.apiKey;
    localStorage.setItem("marketCache:partialLoadedScrub", JSON.stringify(partialLoadedRecord));
  }
}

export function asyncBatchCredential(refreshToken, marketSnapshot) {
  AsyncStorage.multiSet([
    ["refreshToken", refreshToken],
    ["marketCache:latest", JSON.stringify(marketSnapshot)],
  ]);
}

export function indexedDbObjectStoreCredential(database, providerCredential) {
  const transaction = database.transaction("credentials", "readwrite");
  const credentialStore = transaction.objectStore("credentials");
  credentialStore.put(providerCredential, SESSION_KEY);
}
JAVASCRIPT

  cat > "$DART_SOURCE_FILE" <<'DART'
Future<void> sharedPreferencesCredential(
  SharedPreferences preferences,
  String providerCredential,
) async {
  await preferences.setString(
    "marketProvider:twelvedata:apiKey",
    providerCredential,
  );
}
DART

  write_valid_config
}

assert_invalid_config() {
  local label="$1"

  run_scanner
  assert_status 1 "$label exits with a blocking scanner verdict"
  assert_contains "reason=SENSITIVE_STORAGE_CONFIG_INVALID" "$label reports config integrity"
}

write_fixture

printf '%s\n' '=== BUG-039 cascade lifecycle fail-closed matrix ==='
assert_test_lifecycle_fails_closed premature-exit NONE 1 "test_24 premature EXIT"
assert_test_lifecycle_fails_closed timeout-exit NONE 124 "test_24 timeout exit"
assert_test_lifecycle_fails_closed interrupt-hold HUP 129 "test_24 HUP interruption"
assert_test_lifecycle_fails_closed interrupt-hold INT 130 "test_24 INT interruption"
assert_test_lifecycle_fails_closed interrupt-hold TERM 143 "test_24 TERM interruption"

printf '%s\n' '=== BUG-013 production scanner semantic matrix ==='
run_scanner
assert_status 1 "semantic matrix retains blocking findings"
assert_finding "$(line_for 'localStorage.setItem("marketProvider:twelvedata:apiKey"')" "DURABLE_CREDENTIAL_STORAGE" "literal durable credential is blocked"
assert_finding "$(line_for 'localStorage.setItem(KEY_ALIAS_TWO')" "DURABLE_CREDENTIAL_STORAGE" "two-hop alias durable credential is blocked"
assert_finding "$(line_for 'localStorage.setItem(helperKey')" "DURABLE_CREDENTIAL_STORAGE" "helper-indirected durable credential is blocked"
assert_finding "$(line_for 'localStorage.setItem(dynamicDurableKey')" "DURABLE_CREDENTIAL_STORAGE" "dynamic credential-key indirection fails closed"
assert_no_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, providerCredential)')" "exact configured same-tab market credential is allowed"
assert_no_finding "$(line_for 'sessionStorage.setItem(OBJECT_SESSION_KEY')" "immutable object provider resolves to an exact configured session tuple"
assert_finding "$(line_for 'sessionStorage.setItem(UNKNOWN_SESSION_KEY')" "SESSION_PROVIDER_UNKNOWN" "unknown provider is blocked distinctly"
assert_finding "$(line_for 'sessionStorage.setItem(dynamicKey')" "SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED" "dynamic provider is blocked as unresolved"
assert_finding "$(line_for 'localStorage.setItem(SESSION_KEY')" "DURABLE_CREDENTIAL_STORAGE" "configured tuple cannot authorize localStorage"
assert_finding "$(line_for 'localStorage.persistCredential(SESSION_KEY')" "FORBIDDEN_SECRET_CLASS" "unknown localStorage methods fail closed before operation classification"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, authBearerToken)')" "FORBIDDEN_SECRET_CLASS" "bearer material cannot use the exception"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, loginSessionSecret)')" "FORBIDDEN_SECRET_CLASS" "login-session material cannot use the exception"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, refreshToken)')" "FORBIDDEN_SECRET_CLASS" "refresh material cannot use the exception"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, paymentCardNumber)')" "FORBIDDEN_SECRET_CLASS" "payment material cannot use the exception"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, cardCvv)')" "FORBIDDEN_SECRET_CLASS" "CVV material cannot use the exception"
assert_no_finding "$(line_for 'localStorage.setItem(CACHE_KEY')" "comment vocabulary does not taint a market cache"
assert_no_finding "$(line_for 'localStorage.removeItem')" "removeItem is cleanup rather than persistence"
assert_finding "$(line_for 'localStorage.setItem("marketCache:beforeScrub"')" "DURABLE_CREDENTIAL_STORAGE" "credential-bearing object before scrub is blocked"
assert_no_finding "$(line_for 'localStorage.setItem("marketCache:scrubbed"')" "proven scrubbed rewrite is clear"
assert_finding "$(line_for 'localStorage.setItem("marketCache:conditionalScrub"')" "DURABLE_CREDENTIAL_STORAGE" "conditional scrub does not prove delete-before-write"
assert_finding "$(line_for 'localStorage.setItem("marketCache:separateHelper"')" "DURABLE_CREDENTIAL_STORAGE" "separate cleanup helper does not prove execution before write"
assert_no_finding "$(line_for 'localStorage.setItem("marketCache:loadedScrubbed"')" "all observed loaded credential fields are scrubbed"
assert_finding "$(line_for 'localStorage.setItem("marketCache:partialLoadedScrub"')" "FORBIDDEN_SECRET_CLASS" "partial loaded-object scrub leaves high-trust material blocked"
assert_finding "$(line_for 'AsyncStorage.multiSet([')" "FORBIDDEN_SECRET_CLASS" "real AsyncStorage batch credential persistence is blocked"
assert_finding "$(line_for 'credentialStore.put(providerCredential, SESSION_KEY)')" "DURABLE_CREDENTIAL_STORAGE" "real IndexedDB object-store credential persistence is blocked"
assert_finding "$(line_for_file 'await preferences.setString(' "$DART_SOURCE_FILE")" "DURABLE_CREDENTIAL_STORAGE" "real SharedPreferences instance credential persistence is blocked"
assert_not_contains "BUG013_CREDENTIAL_VALUE_MUST_NOT_APPEAR" "diagnostics redact credential values"
assert_contains "storage=localStorage" "diagnostics identify storage kind"
assert_contains "operation=persist" "diagnostics identify operation kind"
assert_contains "configMatch=exact" "diagnostics identify exact config match"

printf '%s\n' '=== BUG-013 invalid project configuration matrix ==='
cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: /absolute/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
assert_invalid_config "absolute config path"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: ../src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
assert_invalid_config "parent-traversing config path"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src//provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
assert_invalid_config "non-normalized config path"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/*.js
        storage: sessionStorage
        key: marketProvider:*:apiKey
        provider: '*'
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
assert_invalid_config "wildcard config tuple"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
      - path: src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
assert_invalid_config "duplicate config tuple"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
      - path: src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: unknown-vendor
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
YAML
assert_invalid_config "ambiguous provider boundary"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage: sessionStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: third-party-market-data
        privilege: elevated
        lifetime: same-tab
        bypass: true
YAML
assert_invalid_config "unknown field and enum"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage sessionStorage
        key: marketProvider:twelvedata:apiKey
YAML
assert_invalid_config "malformed YAML"

printf '%s\n' '=== BUG-013 absent and empty config default-deny cases ==='
rm -f "$CONFIG_FILE"
run_scanner
assert_status 1 "absent sensitive storage config remains default-deny"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, providerCredential)')" "SESSION_CREDENTIAL_UNAPPROVED" "absent config cannot approve a session credential"
assert_not_contains "reason=SENSITIVE_STORAGE_CONFIG_INVALID" "absent config is not misreported as malformed"

cat > "$CONFIG_FILE" <<'YAML'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials: []
YAML
run_scanner
assert_status 1 "empty approval list remains default-deny"
assert_finding "$(line_for 'sessionStorage.setItem(SESSION_KEY, providerCredential)')" "SESSION_CREDENTIAL_UNAPPROVED" "empty approval list cannot approve a session credential"
assert_not_contains "reason=SENSITIVE_STORAGE_CONFIG_INVALID" "documented empty approval list is valid config"

printf '%s\n' '=== BUG-013 parser-unavailable fail-closed case ==='
write_valid_config
NO_PYTHON_PATH="$WORKSPACE/no-python-path"
mkdir -p "$NO_PYTHON_PATH"
for tool_name in awk basename cat cut dirname find grep head sed sort tr wc; do
  tool_path="$(command -v "$tool_name" 2>/dev/null || true)"
  if [[ -n "$tool_path" ]]; then
    ln -s "$tool_path" "$NO_PYTHON_PATH/$tool_name"
  fi
done
PARSER_OUTPUT_FILE="$WORKSPACE/parser-unavailable.txt"
if (
  cd "$FIXTURE_REPO" || exit 2
  env -i PATH="$NO_PYTHON_PATH" /bin/bash "$SCANNER" "$FEATURE_DIR" --verbose
) >"$PARSER_OUTPUT_FILE" 2>&1; then
  RUN_STATUS=0
else
  RUN_STATUS=$?
fi
RUN_OUTPUT="$(cat "$PARSER_OUTPUT_FILE")"
printf '%s\n' "$RUN_OUTPUT"
assert_status 1 "parser-unavailable config fails closed"
assert_contains "reason=SENSITIVE_STORAGE_CONFIG_INVALID" "parser-unavailable config reports integrity reason"

printf '%s\n' '=== BUG-039 managed selftest deterministic unavailable interpreter ==='
# The managed candidate emits an Xcode-like exit 69. The PATH candidate passes
# the public probe but cannot run the helper. A presence/sentinel-only resolver
# falls through and misclassifies the harness; the trusted managed-only resolver
# must stop on the managed provenance and emit the unavailable sentinel. This
# makes the cascade branch independent of the host's real python installation.
FORCED_UNAVAILABLE_HOME="$WORKSPACE/forced-unavailable-python"
FORCED_FALLTHROUGH_PATH="$WORKSPACE/forced-fallthrough-path"
mkdir -p "$FORCED_UNAVAILABLE_HOME/bin" "$FORCED_FALLTHROUGH_PATH"
cat > "$FORCED_UNAVAILABLE_HOME/bin/python3" <<'SH'
#!/usr/bin/env bash
printf '%s\n' 'You have not agreed to the Xcode license agreements. CASCADE_SECRET_MUST_NOT_LEAK' >&2
exit 69
SH
chmod +x "$FORCED_UNAVAILABLE_HOME/bin/python3"
cat > "$FORCED_FALLTHROUGH_PATH/python3" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "-c" && "${2:-}" == *bubbles-python-runs* ]]; then
  printf '%s' 'bubbles-python-runs'
  exit 0
fi
printf '%s\n' 'CASCADE_SECRET_MUST_NOT_LEAK helper failure' >&2
exit 73
SH
chmod +x "$FORCED_FALLTHROUGH_PATH/python3"

SELFTEST_OUTPUT_FILE="$WORKSPACE/selftest-output.txt"
if env -i PATH="$FORCED_FALLTHROUGH_PATH:/usr/bin:/bin:/usr/sbin:/sbin" \
  BUBBLES_PYTHON="$SELFTEST_REAL_PYTHON" \
  BUBBLES_PYTHON_HOME="$FORCED_UNAVAILABLE_HOME" \
  /bin/bash "$SELFTEST" >"$SELFTEST_OUTPUT_FILE" 2>&1 </dev/null; then
  RUN_STATUS=0
else
  RUN_STATUS=$?
fi
RUN_OUTPUT="$(cat "$SELFTEST_OUTPUT_FILE")"
printf '%s\n' "$RUN_OUTPUT"

# BUG-039. The managed selftest's Scan 2B scenarios need a python3 that can
# actually execute, and under the sanitized PATH that is not guaranteed: on
# macOS /usr/bin/python3 dispatches through the active developer directory, so
# an unaccepted Xcode licence makes it resolve and then exit 69. The selftest
# now says so explicitly instead of reporting the missing prerequisite as
# classification failures. Branch on its sentinel: coverage that did not run is
# recorded as a SKIP, never as a PASS. Exit 0 is still required either way,
# because a selftest that skips must not also be failing.
assert_contains "SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1" "deterministic unavailable interpreter emits the machine sentinel"
assert_contains "status=69 diagnostic=XCODE_LICENSE_UNACCEPTED" "deterministic unavailable interpreter reports sanitized exit 69"
assert_not_contains "CASCADE_SECRET_MUST_NOT_LEAK" "deterministic unavailable diagnostics never replay executable output"
if grep -Fq 'SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1' <<<"$RUN_OUTPUT"; then
  pass_before_sentinel=$PASS_COUNT
  skip_before_sentinel=$SKIP_COUNT
  skip "managed selftest Scan 2B coverage (classifier interpreter unusable; selftest reported the cause and remediation)"
  if [[ "$PASS_COUNT" -eq "$pass_before_sentinel" && "$SKIP_COUNT" -eq $((skip_before_sentinel + 1)) ]]; then
    pass "unavailable sentinel increments only the skip counter"
    BUG039_CASCADE_VERIFIED=1
  else
    fail "unavailable sentinel must increment skip, never pass"
  fi
  assert_status 0 "managed selftest exits cleanly when it skips an absent prerequisite"
else
  fail "deterministic unavailable interpreter did not reach the sentinel branch"
fi
assert_contains "PORTABLE_WATCHDOG_FALLBACK=124" "managed selftest preserves watchdog exit 124"
assert_contains "PASS: Real zero-finding producer executes the production driver and helper" "managed selftest executes the real zero-finding producer"
assert_contains "PASS: Real classifier emits the exact durable-credential finding tuple" "managed selftest executes real classifier classification"
assert_contains "PASS: Deleting production completion emission makes the real-finding contract red" "managed selftest proves completion-emission teeth"
assert_contains "PASS: Corrupting production classification makes the real-finding contract red" "managed selftest proves classification teeth"
assert_contains "PASS: Real finding producer creates no helper-side bytecode cache" "managed selftest proves helper bytecode suppression"
assert_contains "PASS: Trusted classifier launch never executes hostile PATH env" "managed selftest proves PATH env cannot replace the trusted launch"
assert_contains "PASS: Premature EXIT preserves fatal exit 1" "managed selftest proves premature exit fails closed"
assert_contains "PASS: Timeout exit preserves fatal exit 124" "managed selftest proves timeout exit fails closed"
assert_contains "PASS: HUP interruption preserves fatal exit 129" "managed selftest proves HUP interruption fails closed"
assert_contains "PASS: INT interruption preserves fatal exit 130" "managed selftest proves INT interruption fails closed"
assert_contains "PASS: TERM interruption preserves fatal exit 143" "managed selftest proves TERM interruption fails closed"
if [[ ! -e "$REPO_ROOT/bubbles/scripts/guards/__pycache__" ]]; then
  pass "canonical selftest leaves the helper bytecode cache absent"
else
  fail "canonical selftest leaves the helper bytecode cache absent"
fi

printf '%s\n' '=== BUG-040 managed selftest sanitized PATH with the managed interpreter ==='
# The scenario above sanitizes the WHOLE environment, so on a machine whose only
# usable interpreter is the managed venv there is no locator left to name it and
# the run degrades to the BUG-039 skip. That skip is correct, and it stays: the
# scenario above is what keeps it exercised.
#
# It is not the best available answer, though. The managed venv owns its own
# interpreter at an absolute path, so it resolves WITHOUT consulting PATH. This
# scenario re-introduces exactly one fact -- where that venv lives -- and nothing
# else, then demands FULL Scan 2B coverage under the same system-only PATH.
# BUBBLES_PYTHON_HOME is chosen over HOME deliberately: it hands back the venv
# location and no other ambient value.
#
# The property under test is unchanged. PATH is still system-only, and the
# assertions below only pass if the classifier really classified.
#
# Three different things can make this scenario unreachable, and collapsing them
# into one sentence is what BUG-039 is about. "No managed venv" asserted while a
# working venv sits on disk is a false report, so each condition names itself:
# an absent LOCATOR is a statement about the environment, an absent INTERPRETER
# is a statement about provisioning, and an interpreter that is present but does
# not execute is a statement about the interpreter. The gate is unchanged --
# bubbles_python_runs already returns 1 for a non-executable path, so splitting
# the -x case out only splits the REASON, never the decision.
MANAGED_PYTHON_HOME=""
MANAGED_PYTHON=""
MANAGED_PYTHON_SKIP_REASON=""
if ! MANAGED_PYTHON_HOME="$(bubbles_python_home)"; then
  MANAGED_PYTHON_SKIP_REASON="no locator names the managed venv (none of $BUBBLES_PYTHON_LOCATOR_VARS is set), so its path cannot be resolved"
else
  MANAGED_PYTHON="$MANAGED_PYTHON_HOME/bin/python3"
  if [[ ! -x "$MANAGED_PYTHON" ]]; then
    MANAGED_PYTHON_SKIP_REASON="no managed venv interpreter at $MANAGED_PYTHON"
  elif ! bubbles_python_runs "$MANAGED_PYTHON"; then
    MANAGED_PYTHON_SKIP_REASON="the managed venv interpreter at $MANAGED_PYTHON is present but does not execute"
  fi
fi
if [[ -n "$MANAGED_PYTHON_SKIP_REASON" ]]; then
  skip "managed selftest full Scan 2B coverage under a sanitized PATH ($MANAGED_PYTHON_SKIP_REASON; provision with 'bash bubbles/scripts/python-env.sh --provision')"
else
  MANAGED_OUTPUT_FILE="$WORKSPACE/selftest-managed-output.txt"
  if env -i PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    BUBBLES_PYTHON="$SELFTEST_REAL_PYTHON" BUBBLES_PYTHON_HOME="$MANAGED_PYTHON_HOME" \
    /bin/bash "$SELFTEST" >"$MANAGED_OUTPUT_FILE" 2>&1 </dev/null; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$MANAGED_OUTPUT_FILE")"
  printf '%s\n' "$RUN_OUTPUT"
  assert_status 0 "managed selftest runs with the system-only PATH and the managed interpreter"
  assert_not_contains "SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1" "managed interpreter removes the classifier-unavailable degradation"
  assert_not_contains "SKIP:" "managed interpreter leaves no skipped scenario group"
  # Teeth: these three pass only when the classifier actually distinguished the
  # cases. A scan that fell back to CLASSIFICATION_UNRESOLVED cannot produce them.
  assert_contains "PASS: Exact configured session credential is allowed" "managed interpreter runs the exact-approval semantic assertion"
  assert_contains "PASS: Unknown session provider is blocked distinctly" "managed interpreter runs the unknown-provider semantic assertion"
  assert_contains "PASS: Malformed sensitive storage YAML reports config integrity" "managed interpreter runs the config-integrity assertion"
fi

printf '%s\n' '=== BUG-013 regression summary ==='
printf 'test_24_g028_sensitive_client_storage: %s passed, %s failed, %s skipped\n' "$PASS_COUNT" "$FAIL_COUNT" "$SKIP_COUNT"
printf 'BUG039_DETERMINISTIC_CASCADE_VERIFIED=%s\n' "$BUG039_CASCADE_VERIFIED"
TEST_COMPLETED=1
if [[ "$FAIL_COUNT" -ne 0 ]]; then
  exit 1
fi
printf '%s\n' 'BUG013_GREEN_REGRESSION=SEMANTIC_STORAGE_CLASSIFICATION_SATISFIED'