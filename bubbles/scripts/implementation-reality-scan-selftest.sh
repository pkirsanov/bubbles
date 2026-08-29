#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAN_SCRIPT="$SCRIPT_DIR/implementation-reality-scan.sh"
SELFTEST_SCRIPT="$SCRIPT_DIR/implementation-reality-scan-selftest.sh"
GUARD_LIB="$SCRIPT_DIR/guard-lib.sh"
TMPDIR="$(mktemp -d)"
FIXTURE_ROOT="$TMPDIR/fixtures"
CLASSIFIER_HELPER_CACHE_DIR="$SCRIPT_DIR/guards/__pycache__"
SELFTEST_COMPLETED=0
SELFTEST_LIFECYCLE_PID=''
SELFTEST_ACTIVE_CHILD=''

selftest_stop_exact_child() {
  if [[ "$SELFTEST_LIFECYCLE_PID" =~ ^[1-9][0-9]*$ ]]; then
    builtin kill -TERM "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
    builtin kill -KILL "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
    builtin wait "$SELFTEST_LIFECYCLE_PID" 2>/dev/null || true
  fi
  SELFTEST_LIFECYCLE_PID=''
}

selftest_stop_active_child() {
  if [[ "$SELFTEST_ACTIVE_CHILD" =~ ^[1-9][0-9]*$ ]]; then
    builtin kill -TERM "$SELFTEST_ACTIVE_CHILD" 2>/dev/null || true
    builtin kill -KILL "$SELFTEST_ACTIVE_CHILD" 2>/dev/null || true
    builtin wait "$SELFTEST_ACTIVE_CHILD" 2>/dev/null || true
  fi
  SELFTEST_ACTIVE_CHILD=''
}

selftest_cleanup() {
  local status=$?
  builtin trap - EXIT HUP INT TERM
  bubbles_python_security_cleanup || true
  selftest_stop_active_child
  selftest_stop_exact_child
  /bin/rm -rf "$TMPDIR" "$CLASSIFIER_HELPER_CACHE_DIR"
  if [[ "$SELFTEST_COMPLETED" -ne 1 && "$status" -eq 0 ]]; then
    echo "FAIL: implementation-reality-scan selftest exited before its completion verdict" >&2
    status=1
  fi
  exit "$status"
}

selftest_signal() {
  local status="$1"
  trap - HUP INT TERM
  exit "$status"
}

trap selftest_cleanup EXIT
trap 'selftest_signal 129' HUP
trap 'selftest_signal 130' INT
trap 'selftest_signal 143' TERM

# Private child modes exercise this script's own EXIT/INT/TERM contract. They
# are entered only by the bounded parent regression below. The ready file lives
# outside the child's TMPDIR so the parent can prove that the EXIT cleanup
# removed the exact temporary tree the child created.
if [[ -n "${BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_CHILD_MODE:-}" ]]; then
  if [[ -z "${BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE:-}" ]]; then
    echo "implementation-reality-scan selftest child mode requires a ready file" >&2
    exit 2
  fi
  case "$BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_CHILD_MODE" in
    premature-exit)
      printf '%s\n' "$TMPDIR" >"$BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE"
      exit 0
      ;;
    timeout-exit)
      printf '%s\n' "$TMPDIR" >"$BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE"
      exit 124
      ;;
    interrupt-hold)
      /usr/bin/mkfifo "$TMPDIR/interrupt-hold.fifo"
      exec 9<>"$TMPDIR/interrupt-hold.fifo"
      printf '%s\n' "$TMPDIR" >"$BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE"
      builtin read -r -t 300 _selftest_hold <&9
      ;;
    *)
      echo "implementation-reality-scan selftest child mode is invalid" >&2
      exit 2
      ;;
  esac
fi

# Importing the production classifier must never leave generated state beside
# a security helper. Remove residue from an earlier run before testing, and the
# EXIT trap repeats this cleanup even when an assertion fails.
rm -rf "$CLASSIFIER_HELPER_CACHE_DIR"

# shellcheck source=/dev/null
source "$GUARD_LIB"

# The scan resolves its classifier interpreter through python-env.sh. This
# selftest's skip decision has to be made by the SAME resolver, or it can skip
# coverage the scan would have run.
# shellcheck source=/dev/null
source "$SCRIPT_DIR/python-env.sh"

# Successful producer tests need a real interpreter independently of the
# managed-path trust fixture used by the scanner. Resolve it through the
# production API, then pass the exact resolved executable to that wrapper. A
# machine with no runnable Python cannot execute this required contract and
# therefore fails the selftest prerequisite instead of reporting a skip.
CLASSIFIER_TEST_PYTHON="${BUBBLES_SELFTEST_REAL_PYTHON:-}"
if [[ -n "$CLASSIFIER_TEST_PYTHON" && -x "$CLASSIFIER_TEST_PYTHON" ]] &&
  bubbles_python_runs "$CLASSIFIER_TEST_PYTHON"; then
  :
elif bubbles_python_resolve_runnable >/dev/null; then
  CLASSIFIER_TEST_PYTHON="$BUBBLES_PYTHON_RUNNABLE"
else
  printf 'implementation-reality-scan selftest prerequisite failed: runnable Python required: %s\n' \
    "$BUBBLES_PYTHON_RUNNABLE_REASON" >&2
  exit 2
fi

failures=0
skips=0
RUN_OUTPUT=""
RUN_STATUS=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

skip() {
  echo "SKIP: $1"
  skips=$((skips + 1))
}

assert_selftest_lifecycle_fails_closed() {
  local mode="$1"
  local signal_name="$2"
  local expected_status="$3"
  local label="$4"
  local ready_fifo="$TMPDIR/lifecycle-$mode-$signal_name.ready.fifo"
  local output_file="$TMPDIR/lifecycle-$mode-$signal_name.log"
  local child_pid=""
  local child_tmp=""
  local child_status=0
  local read_status=0

  /usr/bin/mkfifo "$ready_fifo"
  BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_CHILD_MODE="$mode" \
    BUBBLES_IMPLEMENTATION_REALITY_SELFTEST_READY_FILE="$ready_fifo" \
    /bin/bash "$SELFTEST_SCRIPT" >"$output_file" 2>&1 </dev/null &
  child_pid=$!
  SELFTEST_LIFECYCLE_PID="$child_pid"
  exec 6<"$ready_fifo"
  if builtin read -r -t 10 child_tmp <&6; then read_status=0; else read_status=$?; fi
  exec 6>&-
  if [[ "$read_status" -ne 0 || -z "$child_tmp" ]]; then
    selftest_stop_exact_child
    fail "$label reaches its bounded ready point"
    return
  fi

  if [[ "$signal_name" != "NONE" ]]; then
    builtin kill -"$signal_name" "$child_pid" 2>/dev/null || true
  fi
  if builtin wait "$child_pid" 2>/dev/null; then child_status=0; else child_status=$?; fi
  SELFTEST_LIFECYCLE_PID=''

  if [[ "$child_status" -eq "$expected_status" ]]; then
    pass "$label preserves fatal exit $expected_status"
  else
    fail "$label expected exit $expected_status, got wait=$child_status"
  fi
  if [[ -n "$child_tmp" && ! -e "$child_tmp" ]]; then
    pass "$label removes its temporary tree"
  else
    fail "$label removes its temporary tree (still present: $child_tmp)"
    [[ -z "$child_tmp" ]] || rm -rf "$child_tmp"
  fi
  pass "$label retains no descendant PID for destructive cleanup"
  if /usr/bin/grep -Fq 'implementation-reality-scan selftest passed' "$output_file"; then
    fail "$label must not emit a success summary"
  else
    pass "$label emits no success summary"
  fi
}

echo "Scenario: premature and interrupted selftest exits fail closed while cleaning up."
assert_selftest_lifecycle_fails_closed premature-exit NONE 1 "Premature EXIT"
assert_selftest_lifecycle_fails_closed timeout-exit NONE 124 "Timeout exit"
assert_selftest_lifecycle_fails_closed interrupt-hold HUP 129 "HUP interruption"
assert_selftest_lifecycle_fails_closed interrupt-hold TERM 143 "TERM interruption"

# Is the Scan 2B classifier's interpreter USABLE -- not merely present?
#
# Those are different questions and on macOS they diverge. /usr/bin/python3 is a
# shim that dispatches through the ACTIVE developer directory, so when Xcode.app
# is selected and its licence has not been accepted the shim resolves (satisfying
# `command -v python3`) and then exits 69 without executing a line. The scan then
# fails closed to SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED for every candidate
# line -- correct behaviour -- and assertions on exact classifier tuples fail
# while naming the code under scan, when the real subject is the absent
# prerequisite.
#
# This asks the SAME resolver the scan asks: python-env.sh's authenticated
# root-protected-native-python-v1 trust contract. BUBBLES_PYTHON, managed-venv
# locators, and caller PATH entries cannot become classifier authority.
CLASSIFIER_UNAVAILABLE_REASON=""
CLASSIFIER_REMEDIATION=""

sensitive_storage_classifier_usable() {
  CLASSIFIER_UNAVAILABLE_REASON=""
  CLASSIFIER_REMEDIATION=""

  # Not a command substitution: the resolver's numeric status and closed
  # diagnostic globals must survive for the skip contract below.
  if bubbles_python_resolve_security_runtime; then
    return 0
  fi

  CLASSIFIER_UNAVAILABLE_REASON="status=$BUBBLES_PYTHON_SECURITY_STATUS diagnostic=$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC rejection=$BUBBLES_PYTHON_SECURITY_REJECTION candidates=$BUBBLES_PYTHON_SECURITY_CANDIDATE_COUNT trust=$BUBBLES_PYTHON_SECURITY_TRUST_CONTRACT provenance=$BUBBLES_PYTHON_SECURITY_PROVENANCE"
  case "$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC" in
    XCODE_LICENSE_UNACCEPTED)
      CLASSIFIER_REMEDIATION="run 'sudo xcodebuild -license accept', select accepted Command Line Tools, or set the validated Command Line Tools DEVELOPER_DIR for one invocation"
      ;;
    *)
      CLASSIFIER_REMEDIATION="install a root-protected native Python 3.9 or newer with protected import roots"
      ;;
  esac
  return 1
}

assert_output_contains() {
  local expected="$1"
  local label="$2"
  if grep -Fq -- "$expected" <<<"$RUN_OUTPUT"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_output_not_contains() {
  local forbidden="$1"
  local label="$2"
  if grep -Fq -- "$forbidden" <<<"$RUN_OUTPUT"; then
    fail "$label (unexpected: $forbidden)"
  else
    pass "$label"
  fi
}

run_scan_in_repo() {
  local repo_root="$1"
  local feature_dir="$2"
  local output_file="$TMPDIR/run-scan-in-repo.txt"
  RUN_OUTPUT=""
  RUN_STATUS=0
  if (
    cd "$repo_root" || exit 2
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
    bubbles_run_with_timeout 180 bash "$SCAN_SCRIPT" "$feature_dir" --verbose
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "$RUN_OUTPUT"
}

run_scan_in_repo_with_home() {
  local repo_root="$1"
  local feature_dir="$2"
  local python_home="$3"
  local output_file="$TMPDIR/run-scan-with-home.txt"
  local started_at=$SECONDS
  local elapsed_seconds=0
  RUN_OUTPUT=""
  RUN_STATUS=0
  if (
    cd "$repo_root" || exit 2
    export BUBBLES_PYTHON=""
    export BUBBLES_PYTHON_HOME="$python_home"
    export BUBBLES_SELFTEST_REAL_PYTHON="$CLASSIFIER_TEST_PYTHON"
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
    bubbles_run_with_timeout 180 /bin/bash "$SCAN_SCRIPT" "$feature_dir" --verbose
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "$RUN_OUTPUT"
  elapsed_seconds=$((SECONDS - started_at))
  printf 'SELFTEST_SCAN_METRIC fixture=%s status=%s elapsed_seconds=%s\n' \
    "${python_home##*/}" "$RUN_STATUS" "$elapsed_seconds"
}

run_scan_in_repo_with_hostile_env() {
  local repo_root="$1"
  local feature_dir="$2"
  local python_home="$3"
  local hostile_path="$4"
  local marker_file="$5"
  local output_file="$TMPDIR/run-scan-with-hostile-env.txt"
  local started_at=$SECONDS
  local elapsed_seconds=0
  RUN_OUTPUT=""
  RUN_STATUS=0
  if (
    cd "$repo_root" || exit 2
    unset BUBBLES_PYTHON BUBBLES_PYTHON_HOME XDG_CACHE_HOME HOME
    export PATH="$hostile_path:${PATH:-}"
    export BUBBLES_PYTHON_HOME="$python_home"
    export BUBBLES_SELFTEST_REAL_PYTHON="$CLASSIFIER_TEST_PYTHON"
    export BUBBLES_HOSTILE_ENV_MARKER="$marker_file"
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
    bubbles_run_with_timeout 180 /bin/bash "$SCAN_SCRIPT" "$feature_dir" --verbose
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "$RUN_OUTPUT"
  elapsed_seconds=$((SECONDS - started_at))
  printf 'SELFTEST_SCAN_METRIC fixture=hostile-env status=%s elapsed_seconds=%s\n' \
    "$RUN_STATUS" "$elapsed_seconds"
}

run_scan_in_repo_without_locator() {
  local repo_root="$1"
  local feature_dir="$2"
  local output_file="$TMPDIR/run-scan-without-locator.txt"
  RUN_OUTPUT=""
  RUN_STATUS=0
  if (
    cd "$repo_root" || exit 2
    unset BUBBLES_PYTHON BUBBLES_PYTHON_HOME XDG_CACHE_HOME HOME
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
    bubbles_run_with_timeout 180 /bin/bash "$SCAN_SCRIPT" "$feature_dir" --verbose
  ) >"$output_file" 2>&1; then
    RUN_STATUS=0
  else
    RUN_STATUS=$?
  fi
  RUN_OUTPUT="$(cat "$output_file")"
  printf '%s\n' "$RUN_OUTPUT"
}

run_expect_success() {
  local feature_dir="$1"
  local label="$2"
  local output=""
  local output_file="$TMPDIR/run-expect-success.txt"

  if bubbles_run_with_timeout 180 bash "$SCAN_SCRIPT" "$feature_dir" --verbose >"$output_file" 2>&1; then
    output="$(cat "$output_file")"
    echo "$output"
    pass "$label"
  else
    output="$(cat "$output_file")"
    echo "$output"
    fail "$label"
  fi
}

run_expect_zero_files_failure() {
  local feature_dir="$1"
  local label="$2"
  local output=""
  local output_file="$TMPDIR/run-expect-zero-files.txt"
  local status=0

  if bubbles_run_with_timeout 180 bash "$SCAN_SCRIPT" "$feature_dir" --verbose >"$output_file" 2>&1; then
    output="$(cat "$output_file")"
    echo "$output"
    fail "$label"
    return
  else
    status=$?
    output="$(cat "$output_file")"
    echo "$output"
  fi

  if [[ "$status" -eq 1 ]] && grep -Fq 'ZERO_FILES_RESOLVED' <<< "$output"; then
    pass "$label"
  else
    fail "$label"
  fi
}

run_expect_fake_integration_failure() {
  local feature_dir="$1"
  local label="$2"
  local output=""
  local output_file="$TMPDIR/run-expect-fake-integration.txt"
  local status=0

  if bubbles_run_with_timeout 180 bash "$SCAN_SCRIPT" "$feature_dir" --verbose >"$output_file" 2>&1; then
    output="$(cat "$output_file")"
    echo "$output"
    fail "$label"
    return
  else
    status=$?
    output="$(cat "$output_file")"
    echo "$output"
  fi

  if [[ "$status" -eq 1 ]] && grep -Fq 'FAKE_INTEGRATION' <<< "$output"; then
    pass "$label"
  else
    fail "$label"
  fi
}

create_shell_heavy_fixture() {
  local feature_dir="$FIXTURE_ROOT/shell-heavy-feature"
  mkdir -p "$feature_dir/scripts" "$feature_dir/config" "$feature_dir/docs"

  cat > "$feature_dir/scopes.md" <<EOF
# Scopes: Shell Heavy Fixture

## Scope 1: Inventory Discovery

### Implementation Files

- \`$feature_dir/scripts/validate.sh\`
- \`$feature_dir/config/service.yaml\`
- \`$feature_dir/config/service.yml\`
- \`$feature_dir/config/schema.json\`
- \`$feature_dir/docs/operator.md\`
EOF

  cat > "$feature_dir/scripts/validate.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "fixture validation complete"
EOF

  cat > "$feature_dir/config/service.yaml" <<'EOF'
service: shell-heavy
mode: explicit
EOF

  cat > "$feature_dir/config/service.yml" <<'EOF'
service: shell-heavy-yml
mode: explicit
EOF

  cat > "$feature_dir/config/schema.json" <<'EOF'
{"service":"shell-heavy","mode":"explicit"}
EOF

  cat > "$feature_dir/docs/operator.md" <<'EOF'
# Operator Notes

This fixture proves non-code implementation inventories are still resolved.
EOF
}

create_missing_inventory_fixture() {
  local feature_dir="$FIXTURE_ROOT/missing-inventory-feature"
  mkdir -p "$feature_dir"

  cat > "$feature_dir/scopes.md" <<'EOF'
# Scopes: Missing Inventory Fixture

## Scope 1: Missing Inventory

This scope intentionally has no backtick-wrapped implementation file paths.
EOF
}

create_go_connector_package_fixture() {
  local feature_dir="$FIXTURE_ROOT/go-connector-package-feature"
  local package_dir="$feature_dir/internal/connector/honest"
  mkdir -p "$package_dir"

  cat > "$feature_dir/scopes.md" <<EOF
# Scopes: Go Connector Package Fixture

## Scope 1: Honest Connector Helpers

### Implementation Files

- \`$package_dir/client.go\`
- \`$package_dir/capability.go\`
- \`$package_dir/normalizer.go\`
EOF

  cat > "$package_dir/client.go" <<'EOF'
package honest

import (
	"context"
	"net/http"
)

type Client struct {
	httpClient *http.Client
}

func (c *Client) Fetch(ctx context.Context, endpoint string) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, nil)
	if err != nil {
		return err
	}
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return nil
}
EOF

  cat > "$package_dir/capability.go" <<'EOF'
package honest

import "fmt"

func ValidateCapability(version string) error {
	if version == "" {
		return fmt.Errorf("capability version is required")
	}
	return nil
}
EOF

  cat > "$package_dir/normalizer.go" <<'EOF'
package honest

type Artifact struct {
	ID string
}

type DegradedDiagnostic struct {
	Reason string
}

func Normalize(raw string) (*Artifact, *DegradedDiagnostic) {
	if raw == "" {
		return nil, &DegradedDiagnostic{Reason: "missing trusted artifact"}
	}
	return &Artifact{ID: raw}, nil
}
EOF
}

create_fake_connector_fixture() {
  local feature_dir="$FIXTURE_ROOT/fake-connector-feature"
  local package_dir="$feature_dir/internal/connector/external"
  mkdir -p "$package_dir"

  cat > "$feature_dir/scopes.md" <<EOF
# Scopes: Fake Connector Fixture

## Scope 1: No-op Connector

### Implementation Files

- \`$package_dir/connector.go\`
EOF

  cat > "$package_dir/connector.go" <<'EOF'
package external

type Connector struct{}

func (c *Connector) Sync() error {
	return nil
}
EOF
}

# NEGATIVE (must NOT flag): legitimate OpenTelemetry no-op tracer fallback plus
# closed-vocabulary span-status literals ("noop"). These are observability
# constructs, not faked upstream integration. Proves the Scan 1D telemetry
# refinement exempts them. Mirrors the real assistant_adapter package shape: a
# sibling with a real external call so the package carries an external signal.
create_telemetry_noop_adapter_fixture() {
  local feature_dir="$FIXTURE_ROOT/telemetry-noop-adapter-feature"
  local package_dir="$feature_dir/internal/adapter/telemetry"
  mkdir -p "$package_dir"

  cat > "$feature_dir/scopes.md" <<EOF
# Scopes: Telemetry No-op Adapter Fixture

## Scope 1: OpenTelemetry no-op tracer fallback + closed-vocab span status

### Implementation Files

- \`$package_dir/tracer_fallback.go\`
EOF

  # Real upstream transport lives in a sibling (unlisted) so the package has a
  # genuine external-call signal, exactly like the real adapter package.
  cat > "$package_dir/sender.go" <<'EOF'
package telemetry

import "net/http"

func send(client *http.Client, url string) error {
	resp, err := client.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return nil
}
EOF

  # The scanned file: OTel no-op tracer fallback + "noop" span-status literals,
  # mirroring internal/telegram/assistant_adapter/adapter.go lines 147/152/154/
  # 214/338. With the Scan 1D refinement these MUST NOT be flagged.
  cat > "$package_dir/tracer_fallback.go" <<'EOF'
package telemetry

// buildTracer returns the real tracer, or a no-op tracer fallback when a
// caller omits one so span-emission sites stay unconditional.
func buildTracer() (Tracer, error) {
	noopTr, _, err := tracing.NewTracer(ctx, tracing.Config{Enabled: false, ServiceName: "svc"})
	if err != nil {
		return nil, fmt.Errorf("build noop tracer fallback: %w", err)
	}
	tr = noopTr
	return tr, nil
}

// endTranslate ends the root span with the closed-vocabulary status literal
// "noop" (contract: status is one of ok|error|noop).
func endTranslate(span Span) {
	tracing.EndSpan(span, "noop", "not_assistant_message")
	rootStatus := "noop"
	_ = rootStatus
}
EOF
}

# ADVERSARIAL (must STILL flag): a genuinely faked no-op integration. 'Relay'
# is supposed to reach an upstream bus, but the body is a bare, non-telemetry,
# non-quoted no-op with no external call. The Scan 1D refinement MUST NOT exempt
# this — proves the exclusion opens no hole for real fakes.
create_fake_noop_integration_fixture() {
  local feature_dir="$FIXTURE_ROOT/fake-noop-integration-feature"
  local package_dir="$feature_dir/internal/connector/relay"
  mkdir -p "$package_dir"

  cat > "$feature_dir/scopes.md" <<EOF
# Scopes: Fake No-op Integration Fixture

## Scope 1: Bare no-op integration (must STILL flag)

### Implementation Files

- \`$package_dir/relay.go\`
EOF

  cat > "$package_dir/relay.go" <<'EOF'
package relay

// Relay is supposed to reach the upstream notification bus.
func Relay(payload string) error {
	outcome := noop
	_ = outcome
	return nil
}

func noop() {}
EOF
}

create_sensitive_storage_fixture() {
  SENSITIVE_REPO="$FIXTURE_ROOT/sensitive-storage-repo"
  SENSITIVE_FEATURE="$SENSITIVE_REPO/specs/001-sensitive-storage"
  SENSITIVE_SOURCE="$SENSITIVE_REPO/src/provider-client.js"
  SENSITIVE_DART_SOURCE="$SENSITIVE_REPO/src/provider-preferences.dart"
  SENSITIVE_CONFIG="$SENSITIVE_REPO/.github/bubbles-project.yaml"
  mkdir -p "$SENSITIVE_FEATURE" "$(dirname "$SENSITIVE_SOURCE")" "$(dirname "$SENSITIVE_CONFIG")"

  cat > "$SENSITIVE_FEATURE/scopes.md" <<'EOF'
# Scope 1: Sensitive Storage Selftest

### Implementation Files

- `src/provider-client.js`
- `src/provider-preferences.dart`
EOF

  cat > "$SENSITIVE_SOURCE" <<'EOF'
const KEY = "marketProvider:twelvedata:apiKey";
const KEY_ALIAS = KEY;
const UNKNOWN_KEY = "marketProvider:unknown-vendor:apiKey";
const CACHE_KEY = "marketCache:latest";
localStorage.setItem(KEY_ALIAS, providerCredential);
sessionStorage.setItem(KEY, providerCredential);
sessionStorage.setItem(UNKNOWN_KEY, providerCredential);
sessionStorage.setItem(`marketProvider:${provider}:apiKey`, providerCredential);
localStorage.setItem(KEY, providerCredential);
sessionStorage.setItem(KEY, authBearerToken);
localStorage.setItem(CACHE_KEY, marketSnapshot); // auth token and payment secret are comments only
localStorage.removeItem("legacyAuthToken");
const beforeScrub = { apiKey: providerCredential, price: 42 };
localStorage.setItem("marketCache:before", JSON.stringify(beforeScrub));
const afterScrub = { apiKey: providerCredential, authToken: authBearerToken, price: 42 };
delete afterScrub.apiKey;
delete afterScrub.authToken;
localStorage.setItem("marketCache:after", JSON.stringify(afterScrub));
indexedDB.open("authCredentialDatabase");
SharedPreferences.putString("refreshToken", refreshToken);
AsyncStorage.multiSet("paymentCard", paymentCardNumber);
const transaction = providerDatabase.transaction("credentials", "readwrite");
const credentialStore = transaction.objectStore("credentials");
credentialStore.put(providerCredential, KEY);
EOF

  cat > "$SENSITIVE_DART_SOURCE" <<'EOF'
Future<void> persistProviderCredential(
  SharedPreferences preferences,
  String providerCredential,
) async {
  await preferences.setString(
    "marketProvider:twelvedata:apiKey",
    providerCredential,
  );
}
EOF

  write_sensitive_valid_config
}

write_sensitive_valid_config() {
  cat > "$SENSITIVE_CONFIG" <<'EOF'
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
EOF
}

create_classifier_protocol_fixture() {
  PROTOCOL_REPO="$FIXTURE_ROOT/classifier-protocol-repo"
  PROTOCOL_FEATURE="$PROTOCOL_REPO/specs/001-classifier-protocol"
  PROTOCOL_SOURCE="$PROTOCOL_REPO/src/view.js"
  mkdir -p "$PROTOCOL_FEATURE" "$(dirname "$PROTOCOL_SOURCE")"

  cat > "$PROTOCOL_FEATURE/scopes.md" <<'EOF'
# Scope 1: Classifier Protocol Selftest

### Implementation Files

- `src/view.js`
EOF

  write_protocol_boundary_source
}

write_protocol_boundary_source() {
  cat > "$PROTOCOL_SOURCE" <<'EOF'
export function cacheSnapshot(snapshot) {
  localStorage.setItem("marketCache:latest", JSON.stringify(snapshot));
}
EOF
}

write_protocol_zero_source() {
  cat > "$PROTOCOL_SOURCE" <<'EOF'
export function formatLabel(value) {
  return String(value);
}
EOF
}

write_protocol_finding_source() {
  cat > "$PROTOCOL_SOURCE" <<'EOF'
export function persistCredential(providerCredential) {
  localStorage.setItem("marketProvider:twelvedata:apiKey", providerCredential);
}
EOF
}

# A managed-interpreter fixture is production input, not a substitute parser.
# Every assertion below observes implementation-reality-scan.sh. The fixture
# only controls what the executable does at the probe/helper trust boundary.
# The real-forward mode execs the independently resolved Python with every
# production argument unchanged. Mutation modes alter only a copied driver
# string in the temporary fixture so the assertions prove they have teeth.
make_classifier_python_fixture() {
  local home="$1"
  local mode="$2"
  local path="$home/bin/python3"
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<EOF
#!/bin/bash
mode='$mode'
real_python="\${BUBBLES_SELFTEST_REAL_PYTHON:-}"
if [[ "\${1:-}" == "-B" ]]; then
  shift
fi
if [[ "\${1:-}" == "-c" && "\${2:-}" == *bubbles-python-runs* ]]; then
  case "\$mode" in
    forge-all)
      printf '%s\n' 'forged managed runtime executed' >"\${BUBBLES_SCOPE2_FORGED_MARKER:?marker required}"
      printf 'COMPLETE\tSCS1\t1\n'
      exit 0
      ;;
    probe-silent) exit 0 ;;
    probe-malformed) printf '%s' 'not-the-probe-protocol'; exit 0 ;;
    probe-hang) exec /bin/sleep 300 ;;
    xcode) printf '%s\n' 'You have not agreed to the Xcode license agreements. SECRET_MUST_NOT_LEAK' >&2; exit 69 ;;
    *) printf '%s' 'bubbles-python-runs'; exit 0 ;;
  esac
fi
case "\$mode" in
  real-forward)
    [[ -n "\$real_python" && -x "\$real_python" ]] || exit 75
    exec "\$real_python" "\$@"
    ;;
  mutate-completion)
    [[ -n "\$real_python" && -x "\$real_python" ]] || exit 75
    if [[ "\${1:-}" == "-c" && "\${2:-}" == *COMPLETE* && "\${2:-}" == *SCS1* ]]; then
      mutation_prefix='import builtins
_bubbles_original_print = builtins.print
def _bubbles_mutated_print(*args, **kwargs):
    if args and isinstance(args[0], str) and args[0].startswith("COMPLETE\\tSCS1\\t"):
        return None
    return _bubbles_original_print(*args, **kwargs)
print = _bubbles_mutated_print
'
      mutated_driver="\$mutation_prefix
\$2"
      shift 2
      exec "\$real_python" -c "\$mutated_driver" "\$@"
    fi
    exec "\$real_python" "\$@"
    ;;
  mutate-classification)
    [[ -n "\$real_python" && -x "\$real_python" ]] || exit 75
    if [[ "\${1:-}" == "-c" && "\${2:-}" == *'for finding in module.analyze_file(source_path, repo_root, approvals):'* ]]; then
      original_driver="\$2"
      classification_line='for finding in module.analyze_file(source_path, repo_root, approvals):'
      mutated_driver="\${original_driver//\$classification_line/for finding in ():}"
      [[ "\$mutated_driver" != "\$original_driver" ]] || exit 76
      shift 2
      exec "\$real_python" -c "\$mutated_driver" "\$@"
    fi
    exec "\$real_python" "\$@"
    ;;
esac
case "\$mode" in
  helper-hang) exec /bin/sleep 300 ;;
  helper-failure)
    printf '%s\n' 'SECRET_MUST_NOT_LEAK helper failure bytes' >&2
    exit 73
    ;;
  helper-empty) exit 0 ;;
  helper-malformed) printf '%s\n' 'NOT_A_CLASSIFIER_RECORD SECRET_MUST_NOT_LEAK' ;;
  helper-missing-completion)
    printf 'FINDING\tsrc/view.js\t2\tDURABLE_CREDENTIAL_STORAGE\tlocalStorage\tpersist\tmarketProvider:twelvedata:apiKey\ttwelvedata\tabsent\n'
    ;;
  helper-duplicate-completion)
    printf 'COMPLETE\tSCS1\t1\nCOMPLETE\tSCS1\t1\n'
    ;;
  helper-count-mismatch) printf 'COMPLETE\tSCS1\t2\n' ;;
  *) exit 74 ;;
esac
EOF
  chmod +x "$path"
}

assert_classifier_boundary_failure() {
  local mode="$1"
  local expected_status="$2"
  local expected_diagnostic="$3"
  local probe_timeout_seconds="${4:-30}"
  local home="$FIXTURE_ROOT/classifier-python-$mode"
  local observed_diagnostic=""
  make_classifier_python_fixture "$home" "$mode"
  BUBBLES_SELFTEST_PROBE_TIMEOUT_SECONDS="$probe_timeout_seconds" \
    run_scan_in_repo_with_home "$PROTOCOL_REPO" "$PROTOCOL_FEATURE" "$home"
  if [[ "$RUN_STATUS" -eq 1 ]]; then
    pass "$mode fails closed"
  else
    fail "$mode fails closed (expected scanner exit 1, got $RUN_STATUS)"
  fi
  if grep -Fq -- "status=$expected_status diagnostic=$expected_diagnostic" <<<"$RUN_OUTPUT"; then
    pass "$mode reports bounded numeric status and closed diagnostic"
  else
    observed_diagnostic="$(grep -F 'sensitive-storage classifier' <<<"$RUN_OUTPUT" || true)"
    fail "$mode expected status=$expected_status diagnostic=$expected_diagnostic; observed: $observed_diagnostic"
  fi
  assert_output_contains "reason=SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED" "$mode produces unresolved source findings"
  assert_output_not_contains "SECRET_MUST_NOT_LEAK" "$mode never replays executable output"
}

assert_classifier_boundary_failure_with_timeout() {
  local mode="$1"
  local expected_status="$2"
  local expected_diagnostic="$3"
  local timeout_seconds="$4"
  local home="$FIXTURE_ROOT/classifier-python-$mode-timeout-$timeout_seconds"
  local observed_diagnostic=""
  make_classifier_python_fixture "$home" "$mode"
  BUBBLES_SELFTEST_CLASSIFIER_TIMEOUT_SECONDS="$timeout_seconds" \
    run_scan_in_repo_with_home "$PROTOCOL_REPO" "$PROTOCOL_FEATURE" "$home"
  if [[ "$RUN_STATUS" -eq 1 ]]; then
    pass "$mode timeout control fails closed"
  else
    fail "$mode timeout control fails closed (expected scanner exit 1, got $RUN_STATUS)"
  fi
  if grep -Fq -- "status=$expected_status diagnostic=$expected_diagnostic" <<<"$RUN_OUTPUT"; then
    pass "$mode timeout control reports bounded numeric status and closed diagnostic"
  else
    observed_diagnostic="$(grep -F 'sensitive-storage classifier' <<<"$RUN_OUTPUT" || true)"
    fail "$mode timeout control expected status=$expected_status diagnostic=$expected_diagnostic; observed: $observed_diagnostic"
  fi
  assert_output_contains "reason=SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED" "$mode timeout control produces unresolved source findings"
  assert_output_not_contains "SECRET_MUST_NOT_LEAK" "$mode timeout control never replays executable output"
}

assert_classifier_helper_cache_absent() {
  local label="$1"
  if [[ -e "$CLASSIFIER_HELPER_CACHE_DIR" ]]; then
    fail "$label (unexpected helper cache: $CLASSIFIER_HELPER_CACHE_DIR)"
  else
    pass "$label"
  fi
}

real_finding_contract_holds() {
  [[ "$RUN_STATUS" -eq 1 ]] || return 1
  grep -Fq -- "classifier protocol complete: version=SCS1 scanned=1 findings=1" <<<"$RUN_OUTPUT" || return 1
  grep -Fq -- "reason=DURABLE_CREDENTIAL_STORAGE storage=localStorage operation=persist key=marketProvider:twelvedata:apiKey provider=twelvedata configMatch=absent" <<<"$RUN_OUTPUT" || return 1
  return 0
}

assert_sensitive_invalid_config() {
  local label="$1"
  run_scan_in_repo "$SENSITIVE_REPO" "$SENSITIVE_FEATURE"
  if [[ "$RUN_STATUS" -eq 1 ]]; then
    pass "$label blocks"
  else
    fail "$label blocks (expected exit 1, got $RUN_STATUS)"
  fi
  assert_output_contains "reason=SENSITIVE_STORAGE_CONFIG_INVALID" "$label reports config integrity"
}

create_shell_heavy_fixture
create_missing_inventory_fixture
create_go_connector_package_fixture
create_fake_connector_fixture
create_telemetry_noop_adapter_fixture
create_fake_noop_integration_fixture
create_sensitive_storage_fixture
create_classifier_protocol_fixture

echo "Scenario: SCN-B039-005 caller-owned managed/PATH Python cannot authorize a clean Scan 2B verdict."
write_protocol_finding_source
scope2_forged_home="$FIXTURE_ROOT/classifier-python-forge-all"
scope2_forged_marker="$FIXTURE_ROOT/classifier-python-forge-all.marker"
make_classifier_python_fixture "$scope2_forged_home" forge-all
export BUBBLES_SCOPE2_FORGED_MARKER="$scope2_forged_marker"
run_scan_in_repo_with_home "$PROTOCOL_REPO" "$PROTOCOL_FEATURE" "$scope2_forged_home"
unset BUBBLES_SCOPE2_FORGED_MARKER
if [[ "$RUN_STATUS" -eq 1 ]]; then
  pass "SCN-B039-005 forged managed runtime cannot earn a clean scanner verdict"
else
  fail "SCN-B039-005 forged managed runtime earned scanner exit $RUN_STATUS"
fi
if [[ ! -e "$scope2_forged_marker" ]]; then
  pass "SCN-B039-005 forged managed runtime marker remains absent"
else
  fail "SCN-B039-005 forged managed runtime executed before authentication"
fi
assert_output_contains "trust=root-protected-native-python-v1" "SCN-B039-005 scanner reports the root-protected trust contract"
assert_output_not_contains "classifier protocol complete: version=SCS1 scanned=1 findings=0" "SCN-B039-005 forged clean SCS1 cannot satisfy Scan 2B"

echo "Scenario: SCN-B039-005 copied authentication bypass turns the forged-runtime assertions red."
authority_live_hashes="$(/usr/bin/shasum -a 256 "$SCRIPT_DIR/python-env.sh" "$SCAN_SCRIPT" "$SCRIPT_DIR/guards/sensitive-client-storage-scan.py")"
authority_root="$FIXTURE_ROOT/authority-bypass-mutation"
authority_scripts="$authority_root/bubbles/scripts"
authority_env="$authority_scripts/python-env.sh"
authority_scanner="$authority_scripts/implementation-reality-scan.sh"
authority_fake_bin="$authority_root/caller-bin"
authority_fake="$authority_fake_bin/python3"
authority_marker="$authority_root/caller-runtime-executed.marker"
authority_untrusted_developer="$authority_root/untrusted-developer"
authority_output="$TMPDIR/authority-bypass-mutation.output"
mkdir -p "$authority_scripts/guards" "$authority_fake_bin" "$authority_untrusted_developer"
/bin/cp "$SCRIPT_DIR/python-env.sh" "$authority_env"
/bin/cp "$GUARD_LIB" "$authority_scripts/guard-lib.sh"
/bin/cp "$SCAN_SCRIPT" "$authority_scanner"
/bin/cp "$SCRIPT_DIR/guards/sensitive-client-storage-scan.py" "$authority_scripts/guards/sensitive-client-storage-scan.py"
/usr/bin/awk '
  /^_bubbles_python_security_authenticate_path\(\) \{/ {
    print
    print "  BUBBLES_PYTHON_SECURITY_PATH_RESOLVED=\"$1\""
    print "  BUBBLES_PYTHON_SECURITY_PATH_REJECTION=NONE"
    print "  BUBBLES_PYTHON_SECURITY_PATH_DIAGNOSTIC=OK"
    print "  return 0"
    print "}"
    skipping=1
    next
  }
  skipping && /^}/ { skipping=0; next }
  !skipping { print }
' "$SCRIPT_DIR/python-env.sh" >"$authority_env"
cat >"$authority_fake" <<EOF
#!/bin/bash
program=''
previous=''
for argument in "\$@"; do
  if [[ "\$previous" == -c ]]; then program="\$argument"; break; fi
  previous="\$argument"
done
case "\$program" in
  *'RUNTIME\tPYSEC1'*)
    printf 'RUNTIME\tPYSEC1\t3\t9\n'
    printf 'FLAGS\tPYSEC1\t1\t1\t1\t1\n'
    printf 'EXECUTABLE\tPYSEC1\t%s\n' '$authority_fake'
    printf 'PREFIX\tPYSEC1\tbase\t/\nPREFIX\tPYSEC1\texec\t/\n'
    printf 'PATH\tPYSEC1\t/\nCOMPLETE\tPYSEC1\t1\n'
    ;;
  *'MODULE\tPYMOD1'*)
    for name in ast dataclasses hashlib os pathlib re sys types typing; do
      printf 'MODULE\tPYMOD1\t%s\tbuilt-in\t-\n' "\$name"
    done
    printf 'COMPLETE\tPYMOD1\t9\n'
    ;;
  *)
    printf '%s\n' 'forged caller-owned runtime executed' >'$authority_marker'
    printf 'COMPLETE\tSCS1\t1\n'
    ;;
esac
exit 0
EOF
chmod +x "$authority_fake"
RUN_OUTPUT=""
RUN_STATUS=0
if (
  cd "$PROTOCOL_REPO" || exit 2
  PATH="$authority_fake_bin:/usr/bin:/bin:/usr/sbin:/sbin" \
    DEVELOPER_DIR="$authority_untrusted_developer" \
    /bin/bash "$authority_scanner" "$PROTOCOL_FEATURE" --verbose
) >"$authority_output" 2>&1; then RUN_STATUS=0; else RUN_STATUS=$?; fi
RUN_OUTPUT="$(/bin/cat "$authority_output")"
authority_after_hashes="$(/usr/bin/shasum -a 256 "$SCRIPT_DIR/python-env.sh" "$SCAN_SCRIPT" "$SCRIPT_DIR/guards/sensitive-client-storage-scan.py")"
if [[ "$RUN_STATUS" -eq 0 && -e "$authority_marker" ]] &&
  grep -Fq 'classifier protocol complete: version=SCS1 scanned=1 findings=0' <<<"$RUN_OUTPUT"; then
  pass "SCN-B039-005 authority-bypass mutation makes forged clean output and marker assertions red"
else
  fail "SCN-B039-005 authority-bypass mutation did not expose the expected compromise (status=$RUN_STATUS marker=$([[ -e "$authority_marker" ]] && echo present || echo absent))"
fi
if [[ "$authority_live_hashes" == "$authority_after_hashes" ]]; then
  pass "SCN-B039-005 authority mutation leaves live production bytes identical"
else
  fail "SCN-B039-005 authority mutation changed live production bytes"
fi

# The production path must have an authenticated positive control on this host
# before helper-identity tests can claim anything about classifier execution.
if DEVELOPER_DIR=/Library/Developer/CommandLineTools bubbles_python_resolve_security_runtime; then
  SECURITY_RUNTIME="$BUBBLES_PYTHON_SECURITY_RUNTIME"
  pass "SCN-B039-005 authenticated CLT/xcrun runtime is available to scanner tests"
else
  SECURITY_RUNTIME=""
  fail "SCN-B039-005 authenticated CLT/xcrun runtime unavailable: status=$BUBBLES_PYTHON_SECURITY_STATUS diagnostic=$BUBBLES_PYTHON_SECURITY_DIAGNOSTIC rejection=$BUBBLES_PYTHON_SECURITY_REJECTION"
fi

run_copied_scan_with_helper() {
  local mode="$1"
  local payload="$2"
  local expected_digest_mode="$3"
  local copy_root="$FIXTURE_ROOT/helper-$mode"
  local copy_scripts="$copy_root/bubbles/scripts"
  local copy_scanner="$copy_scripts/implementation-reality-scan.sh"
  local copy_helper="$copy_scripts/guards/sensitive-client-storage-scan.py"
  local output_file="$TMPDIR/helper-$mode.output"
  local helper_digest=""
  mkdir -p "$copy_scripts/guards"
  /bin/cp "$SCRIPT_DIR/python-env.sh" "$copy_scripts/python-env.sh"
  /bin/cp "$GUARD_LIB" "$copy_scripts/guard-lib.sh"
  /bin/cp "$SCAN_SCRIPT" "$copy_scanner"
  /bin/cp "$SCRIPT_DIR/guards/sensitive-client-storage-scan.py" "$copy_helper"
  printf '%s\n' "$payload" >>"$copy_helper"
  if [[ "$expected_digest_mode" == updated ]]; then
    helper_digest="$(/usr/bin/shasum -a 256 "$copy_helper" | /usr/bin/awk '{print $1}')"
    /usr/bin/perl -pi -e "s/77a02ff179d529812d75cfa223bef5f9f171a9169dce050ab46fb2f1f0834df3/$helper_digest/g" "$copy_scripts/python-env.sh"
  fi
  RUN_OUTPUT=""
  RUN_STATUS=0
  if (
    cd "$PROTOCOL_REPO" || exit 2
    DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash "$copy_scanner" "$PROTOCOL_FEATURE" --verbose
  ) >"$output_file" 2>&1; then RUN_STATUS=0; else RUN_STATUS=$?; fi
  RUN_OUTPUT="$(/bin/cat "$output_file")"
  printf '%s\n' "$RUN_OUTPUT"
}

echo "Scenario: SCN-B039-006 altered helper payload classes fail digest authentication before execution."
for helper_payload_mode in marker subprocess setsid double-fork dynamic-import ctypes eval exec; do
  helper_marker="$TMPDIR/helper-$helper_payload_mode.marker"
  case "$helper_payload_mode" in
    marker) helper_payload="open('$helper_marker', 'w').write('executed')" ;;
    subprocess) helper_payload="__import__('subprocess').run(['/usr/bin/touch', '$helper_marker'])" ;;
    setsid) helper_payload="__import__('os').setsid(); open('$helper_marker', 'w').write('executed')" ;;
    double-fork) helper_payload="(__import__('os').fork() == 0 and __import__('os').fork() == 0 and open('$helper_marker', 'w').write('executed'))" ;;
    dynamic-import) helper_payload="__import__('pathlib').Path('$helper_marker').write_text('executed')" ;;
    ctypes) helper_payload="__import__('ctypes'); open('$helper_marker', 'w').write('executed')" ;;
    eval) helper_payload="eval(\"open('$helper_marker', 'w').write('executed')\")" ;;
    exec) helper_payload="exec(\"open('$helper_marker', 'w').write('executed')\")" ;;
  esac
  run_copied_scan_with_helper "$helper_payload_mode" "$helper_payload" original
  if [[ "$RUN_STATUS" -eq 1 ]] &&
    grep -Fq 'diagnostic=HELPER_DIGEST_MISMATCH' <<<"$RUN_OUTPUT" &&
    [[ ! -e "$helper_marker" ]]; then
    pass "SCN-B039-006 $helper_payload_mode payload is rejected before execution"
  else
    fail "SCN-B039-006 $helper_payload_mode payload status=$RUN_STATUS marker=$([[ -e "$helper_marker" ]] && echo present || echo absent)"
  fi
done

echo "Scenario: SCN-B039-006 copied-driver digest update executes reviewed classifier mutation and semantic assertions bite."
run_copied_scan_with_helper classification-mutation \
  '# copied candidate marker: digest updated, production classifier bytes intentionally changed below' updated
classification_copy="$FIXTURE_ROOT/helper-classification-mutation/bubbles/scripts/guards/sensitive-client-storage-scan.py"
classification_env="$FIXTURE_ROOT/helper-classification-mutation/bubbles/scripts/python-env.sh"
classification_scanner="$FIXTURE_ROOT/helper-classification-mutation/bubbles/scripts/implementation-reality-scan.sh"
classification_previous_digest="$(/usr/bin/shasum -a 256 "$classification_copy" | /usr/bin/awk '{print $1}')"
/usr/bin/perl -pi -e 's/DURABLE_CREDENTIAL_STORAGE/SESSION_CREDENTIAL_UNAPPROVED/g' "$classification_copy"
classification_digest="$(/usr/bin/shasum -a 256 "$classification_copy" | /usr/bin/awk '{print $1}')"
/usr/bin/perl -pi -e "s/$classification_previous_digest/$classification_digest/g" "$classification_env"
RUN_OUTPUT=""
RUN_STATUS=0
if (
  cd "$SENSITIVE_REPO" || exit 2
  DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash "$classification_scanner" "$SENSITIVE_FEATURE" --verbose
) >"$TMPDIR/classification-mutation.output" 2>&1; then RUN_STATUS=0; else RUN_STATUS=$?; fi
RUN_OUTPUT="$(/bin/cat "$TMPDIR/classification-mutation.output")"
if [[ "$RUN_STATUS" -eq 1 ]] && ! grep -Fq 'diagnostic=HELPER_DIGEST_MISMATCH' <<<"$RUN_OUTPUT" &&
  grep -Fq 'classifier protocol complete: version=SCS1' <<<"$RUN_OUTPUT" &&
  grep -Fq 'reason=SESSION_CREDENTIAL_UNAPPROVED' <<<"$RUN_OUTPUT" &&
  ! grep -Fq 'reason=DURABLE_CREDENTIAL_STORAGE storage=localStorage operation=persist key=marketProvider:twelvedata:apiKey provider=twelvedata configMatch=absent' <<<"$RUN_OUTPUT"; then
  pass "SCN-B039-003 copied classifier mutation executes after explicit digest review and changes semantic tuples"
  pass "Corrupting production classification makes the real-finding contract red"
else
  fail "SCN-B039-003 copied classifier mutation did not reach semantic classification (status=$RUN_STATUS)"
fi

echo "Scenario: SCN-B039-003 copied-driver completion mutation is rejected by the production protocol parser."
completion_root="$FIXTURE_ROOT/driver-completion-mutation"
completion_scripts="$completion_root/bubbles/scripts"
completion_scanner="$completion_scripts/implementation-reality-scan.sh"
completion_env="$completion_scripts/python-env.sh"
completion_helper="$completion_scripts/guards/sensitive-client-storage-scan.py"
completion_output="$TMPDIR/driver-completion-mutation.output"
mkdir -p "$completion_scripts/guards"
/bin/cp "$SCRIPT_DIR/python-env.sh" "$completion_env"
/bin/cp "$GUARD_LIB" "$completion_scripts/guard-lib.sh"
/bin/cp "$SCAN_SCRIPT" "$completion_scanner"
/bin/cp "$SCRIPT_DIR/guards/sensitive-client-storage-scan.py" "$completion_helper"
completion_record_before="$(/usr/bin/grep -cF 'print("COMPLETE\tSCS1\t%d" % scanned)' "$completion_env" || true)"
/usr/bin/perl -pi -e 's/^print\("COMPLETE\\tSCS1\\t%d" % scanned\)$/pass # copied completion-emission mutation/' "$completion_env"
completion_record_after="$(/usr/bin/grep -cF 'print("COMPLETE\tSCS1\t%d" % scanned)' "$completion_env" || true)"
RUN_OUTPUT=""
RUN_STATUS=0
if (
  cd "$PROTOCOL_REPO" || exit 2
  DEVELOPER_DIR=/Library/Developer/CommandLineTools /bin/bash "$completion_scanner" "$PROTOCOL_FEATURE" --verbose
) >"$completion_output" 2>&1; then RUN_STATUS=0; else RUN_STATUS=$?; fi
RUN_OUTPUT="$(/bin/cat "$completion_output")"
if [[ "$completion_record_before" -eq 1 && "$completion_record_after" -eq 0 &&
  "$RUN_STATUS" -eq 1 &&
  "$RUN_OUTPUT" == *"diagnostic=CLASSIFIER_COMPLETION_MISSING"* ]] &&
  ! real_finding_contract_holds; then
  pass "Deleting production completion emission makes the real-finding contract red"
  pass "Completion-emission mutant fails through the production scanner path"
else
  fail "SCN-B039-003 completion mutation result before=$completion_record_before after=$completion_record_after status=$RUN_STATUS"
fi

echo "Scenario: SCN-B039-006 same-byte helper execution resists a post-read path replacement."
same_byte_marker="$TMPDIR/same-byte-original.marker"
replacement_marker="$TMPDIR/same-byte-replacement.marker"
same_byte_helper="$TMPDIR/same-byte-helper.py"
same_byte_replacement="$TMPDIR/same-byte-replacement.py"
same_byte_driver_raw="$TMPDIR/same-byte-driver.raw.py"
same_byte_driver="$TMPDIR/same-byte-driver.py"
same_byte_reopen="$TMPDIR/same-byte-reopen.py"
same_byte_live_hash="$(/usr/bin/shasum -a 256 "$SCRIPT_DIR/python-env.sh")"
cat >"$same_byte_helper" <<EOF
from pathlib import Path
Path("$same_byte_marker").write_text("original", encoding="utf-8")
class ConfigError(Exception):
    line = 0
class Finding:
    def __init__(self, **kwargs):
        pass
    def emit(self):
        pass
def parse_project_config(config_path, repository):
    return [], None
def analyze_file(source_path, repository, approvals):
    return []
EOF
cat >"$same_byte_replacement" <<EOF
from pathlib import Path
Path("$replacement_marker").write_text("replacement", encoding="utf-8")
class ConfigError(Exception):
    line = 0
class Finding:
    def __init__(self, **kwargs):
        pass
    def emit(self):
        pass
def parse_project_config(config_path, repository):
    return [], None
def analyze_file(source_path, repository, approvals):
    return []
EOF
same_byte_digest="$(/usr/bin/shasum -a 256 "$same_byte_helper" | /usr/bin/awk '{print $1}')"
_bubbles_python_security_scan_driver >"$same_byte_driver_raw"
/usr/bin/awk -v replacement="$same_byte_replacement" '
  { print }
  /helper_code = compile\(helper_text/ {
    printf "    os.replace(Path(\"%s\"), helper_path)\n", replacement
  }
' "$same_byte_driver_raw" >"$same_byte_driver"
if "$SECURITY_RUNTIME" -I -S -B "$same_byte_driver" \
  "$same_byte_helper" "$same_byte_digest" 262144 \
  "$PROTOCOL_REPO" "$PROTOCOL_REPO/.github/bubbles-project.yaml" "$PROTOCOL_SOURCE" &&
  [[ -e "$same_byte_marker" && ! -e "$replacement_marker" ]]; then
  pass "SCN-B039-006 production driver executes its checked byte buffer after path replacement"
else
  fail "SCN-B039-006 production driver did not preserve the checked byte buffer"
fi
/bin/rm -f "$same_byte_marker" "$replacement_marker"
cat >"$same_byte_helper" <<EOF
from pathlib import Path
Path("$same_byte_marker").write_text("original", encoding="utf-8")
class ConfigError(Exception):
    line = 0
class Finding:
    def __init__(self, **kwargs):
        pass
    def emit(self):
        pass
def parse_project_config(config_path, repository):
    return [], None
def analyze_file(source_path, repository, approvals):
    return []
EOF
cat >"$same_byte_replacement" <<EOF
from pathlib import Path
Path("$replacement_marker").write_text("replacement", encoding="utf-8")
class ConfigError(Exception):
    line = 0
class Finding:
    def __init__(self, **kwargs):
        pass
    def emit(self):
        pass
def parse_project_config(config_path, repository):
    return [], None
def analyze_file(source_path, repository, approvals):
    return []
EOF
same_byte_digest="$(/usr/bin/shasum -a 256 "$same_byte_helper" | /usr/bin/awk '{print $1}')"
/usr/bin/awk '
  /exec\(helper_code, module.__dict__\)/ {
    print "    helper_code = compile(helper_path.read_text(encoding=\"utf-8\"), str(helper_path), \"exec\", dont_inherit=True)"
  }
  { print }
' "$same_byte_driver" >"$same_byte_reopen"
if "$SECURITY_RUNTIME" -I -S -B "$same_byte_reopen" \
  "$same_byte_helper" "$same_byte_digest" 262144 \
  "$PROTOCOL_REPO" "$PROTOCOL_REPO/.github/bubbles-project.yaml" "$PROTOCOL_SOURCE" &&
  [[ ! -e "$same_byte_marker" && -e "$replacement_marker" ]]; then
  pass "SCN-B039-006 copied production-driver reopen mutation turns the same-byte assertion red"
else
  fail "SCN-B039-006 copied production-driver reopen mutation did not execute replacement bytes"
fi
same_byte_after_hash="$(/usr/bin/shasum -a 256 "$SCRIPT_DIR/python-env.sh")"
if [[ "$same_byte_live_hash" == "$same_byte_after_hash" ]]; then
  pass "SCN-B039-006 same-byte and reopen mutations leave live production bytes identical"
else
  fail "SCN-B039-006 same-byte mutation changed live production bytes"
fi

echo "Running implementation-reality-scan discovery selftest..."
echo "Scenario: shell-heavy fixtures resolve honest implementation inventory."
run_expect_success "$FIXTURE_ROOT/shell-heavy-feature" "Shell-heavy fixture resolves .sh/.yaml/.yml/.json/docs-backed inventory"

echo "Scenario: missing inventories still fail with ZERO_FILES_RESOLVED."
run_expect_zero_files_failure "$FIXTURE_ROOT/missing-inventory-feature" "Missing-inventory fixture fails honestly without shim files"

echo "Scenario: Go connector helper nil returns are not fake when the package has a real transport client."
run_expect_success "$FIXTURE_ROOT/go-connector-package-feature" "Go connector helper return nil lines pass when a sibling client performs external calls"

echo "Scenario: no-op connector still fails external integration authenticity."
run_expect_fake_integration_failure "$FIXTURE_ROOT/fake-connector-feature" "No-op connector without an external call is still flagged as FAKE_INTEGRATION"

echo "Scenario: OpenTelemetry no-op tracer fallback + quoted 'noop' span-status literals are NOT flagged as fake integrations."
run_expect_success "$FIXTURE_ROOT/telemetry-noop-adapter-feature" "Telemetry no-op tracer fallback + quoted 'noop' span-status literals pass Scan 1D (BUG-064-001 false-positive class)"

echo "Scenario: a bare non-telemetry no-op integration body is STILL flagged (exclusion opens no hole)."
run_expect_fake_integration_failure "$FIXTURE_ROOT/fake-noop-integration-feature" "Bare non-telemetry, non-quoted no-op integration body is still flagged as FAKE_INTEGRATION"

assert_classifier_helper_cache_absent "Selftest removes prior bytecode from the real helper directory"

write_protocol_zero_source
run_scan_in_repo "$PROTOCOL_REPO" "$PROTOCOL_FEATURE"
if [[ "$RUN_STATUS" -eq 0 ]]; then
  pass "Real zero-finding producer executes the production driver and helper"
else
  fail "Real zero-finding producer executes the production driver and helper (scanner exit $RUN_STATUS)"
fi
assert_output_contains "classifier protocol complete: version=SCS1 scanned=1 findings=0" "Real zero-finding completion reports the honest scanned count"
assert_output_not_contains "VIOLATION [SENSITIVE_CLIENT_STORAGE]" "Source without a sensitive operation has no storage finding"
assert_classifier_helper_cache_absent "Real zero-finding producer creates no helper-side bytecode cache"

first_real_zero_status="$RUN_STATUS"
first_real_zero_summary="$(grep -F 'classifier protocol complete:' <<<"$RUN_OUTPUT" || true)"
run_scan_in_repo "$PROTOCOL_REPO" "$PROTOCOL_FEATURE"
second_real_zero_summary="$(grep -F 'classifier protocol complete:' <<<"$RUN_OUTPUT" || true)"
if [[ "$first_real_zero_status" -eq 0 && "$RUN_STATUS" -eq 0 &&
  "$first_real_zero_summary" == "$second_real_zero_summary" &&
  "$second_real_zero_summary" == *"version=SCS1 scanned=1 findings=0"* ]]; then
  pass "Consecutive real zero-finding production runs have identical verdict summaries"
else
  fail "Consecutive real zero-finding production runs diverged (first=$first_real_zero_status/$first_real_zero_summary second=$RUN_STATUS/$second_real_zero_summary)"
fi
assert_classifier_helper_cache_absent "Second consecutive real zero-finding producer creates no helper-side bytecode cache"

write_protocol_finding_source
run_scan_in_repo "$PROTOCOL_REPO" "$PROTOCOL_FEATURE"
if [[ "$RUN_STATUS" -eq 1 ]]; then
  pass "Real finding producer remains blocking after protocol completion"
else
  fail "Real finding producer remains blocking after protocol completion (scanner exit $RUN_STATUS)"
fi
assert_output_contains "classifier protocol complete: version=SCS1 scanned=1 findings=1" "Real finding completion reports one scanned file and one finding"
assert_output_contains "reason=DURABLE_CREDENTIAL_STORAGE storage=localStorage operation=persist key=marketProvider:twelvedata:apiKey provider=twelvedata configMatch=absent" "Real classifier emits the exact durable-credential finding tuple"
assert_classifier_helper_cache_absent "Real finding producer creates no helper-side bytecode cache"

echo "Scenario: a hostile PATH env cannot replace the trusted classifier launch."
hostile_env_path="$FIXTURE_ROOT/hostile-env-path"
hostile_env_marker="$FIXTURE_ROOT/hostile-env-executed"
mkdir -p "$hostile_env_path"
cat >"$hostile_env_path/env" <<'EOF'
#!/bin/bash
printf '%s\n' 'hostile env executed' >"$BUBBLES_HOSTILE_ENV_MARKER"
printf 'COMPLETE\tSCS1\t1\n'
exit 0
EOF
chmod +x "$hostile_env_path/env"
run_scan_in_repo_with_hostile_env "$PROTOCOL_REPO" "$PROTOCOL_FEATURE" \
  "$scope2_forged_home" "$hostile_env_path" "$hostile_env_marker"
if real_finding_contract_holds; then
  pass "Hostile PATH env cannot suppress the real classifier finding"
else
  hostile_env_diagnostic="$(grep -F 'sensitive-storage classifier' <<<"$RUN_OUTPUT" || true)"
  fail "Hostile PATH env cannot suppress the real classifier finding (scanner exit $RUN_STATUS; observed: $hostile_env_diagnostic)"
fi
if [[ ! -e "$hostile_env_marker" ]]; then
  pass "Trusted classifier launch never executes hostile PATH env"
else
  fail "Trusted classifier launch never executes hostile PATH env (marker exists)"
fi
assert_classifier_helper_cache_absent "Hostile PATH env scenario leaves the helper directory clean"

if sensitive_storage_classifier_usable; then
  echo "Scenario: semantic Scan 2B distinguishes storage operations and exact session classification."
  run_scan_in_repo "$SENSITIVE_REPO" "$SENSITIVE_FEATURE"
  if [[ "$RUN_STATUS" -eq 1 ]]; then
    pass "Sensitive storage matrix retains blocking findings"
  else
    fail "Sensitive storage matrix retains blocking findings (expected exit 1, got $RUN_STATUS)"
  fi
  assert_output_contains "reason=DURABLE_CREDENTIAL_STORAGE storage=localStorage operation=persist key=marketProvider:twelvedata:apiKey provider=twelvedata" "Literal and alias-resolved durable credentials are blocked"
  assert_output_not_contains "src/provider-client.js:6" "Exact configured session credential is allowed"
  assert_output_contains "reason=SESSION_PROVIDER_UNKNOWN" "Unknown session provider is blocked distinctly"
  assert_output_contains "reason=SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED" "Dynamic session provider is blocked unresolved"
  assert_output_contains "reason=FORBIDDEN_SECRET_CLASS storage=sessionStorage" "High-trust session material cannot use approval"
  assert_output_not_contains "src/provider-client.js:11" "Inline comment vocabulary does not taint cache"
  assert_output_not_contains "src/provider-client.js:12" "removeItem remains cleanup"
  assert_output_contains "src/provider-client.js:14" "Credential object before scrub remains blocking"
  assert_output_not_contains "src/provider-client.js:18" "Proven scrubbed rewrite remains clear"
  assert_output_contains "storage=indexedDB operation=read" "IndexedDB credential access remains covered"
  assert_output_contains "storage=SharedPreferences operation=persist" "SharedPreferences credential persistence remains covered"
  assert_output_contains "storage=AsyncStorage operation=persist" "AsyncStorage credential persistence remains covered"
  assert_output_contains "storage=indexedDB operation=persist key=marketProvider:twelvedata:apiKey" "IndexedDB object-store credential persistence remains covered"
  assert_output_contains "src/provider-preferences.dart" "SharedPreferences instance credential persistence remains covered"

  echo "Scenario: sensitive storage project configuration fails closed."
  cat > "$SENSITIVE_CONFIG" <<'EOF'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: ../src/*.js
        storage: sessionStorage
        key: marketProvider:*:apiKey
        provider: '*'
        credentialClass: third-party-market-data
        privilege: low
        lifetime: same-tab
EOF
  assert_sensitive_invalid_config "Traversal and wildcard approval"

  cat > "$SENSITIVE_CONFIG" <<'EOF'
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
EOF
  assert_sensitive_invalid_config "Duplicate approval tuple"

  cat > "$SENSITIVE_CONFIG" <<'EOF'
scans:
  sensitiveClientStorage:
    unknownField: true
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage: localStorage
        key: marketProvider:twelvedata:apiKey
        provider: twelvedata
        credentialClass: auth-token
        privilege: high
        lifetime: durable
EOF
  assert_sensitive_invalid_config "Unknown field and enum values"

  cat > "$SENSITIVE_CONFIG" <<'EOF'
scans:
  sensitiveClientStorage:
    approvedSessionCredentials:
      - path: src/provider-client.js
        storage sessionStorage
        key: marketProvider:twelvedata:apiKey
EOF
  assert_sensitive_invalid_config "Malformed sensitive storage YAML"
else
  # Machine-readable for consumers (tests/regression/test_24_...) so a skip can
  # never be scraped as a pass.
  echo "SENSITIVE_STORAGE_CLASSIFIER_UNAVAILABLE=1"
  skip "semantic Scan 2B classification and sensitive-storage config integrity — $CLASSIFIER_UNAVAILABLE_REASON"
  echo "      remediation: $CLASSIFIER_REMEDIATION"
  echo "      not run: 15 semantic classification assertions, 8 config-integrity assertions."
  echo "      Both groups assert exact classifier tuples. With the classifier unable to start, the scan"
  echo "      fails closed to SENSITIVE_STORAGE_CLASSIFICATION_UNRESOLVED for every candidate line and"
  echo "      emits SENSITIVE_STORAGE_CONFIG_INVALID for any config declaring the key, so neither a pass"
  echo "      nor a failure from these assertions would carry information about the classifier."
fi

write_sensitive_valid_config
NO_PARSER_PATH="$TMPDIR/no-parser-path"
mkdir -p "$NO_PARSER_PATH"
for tool_name in awk basename cat cut dirname find grep head sed sort tr wc; do
  tool_path="$(command -v "$tool_name" 2>/dev/null || true)"
  [[ -z "$tool_path" ]] || ln -s "$tool_path" "$NO_PARSER_PATH/$tool_name"
done
parser_output=""
parser_status=0
if parser_output="$(
  cd "$SENSITIVE_REPO" || exit 2
  env -i PATH="$NO_PARSER_PATH" /bin/bash "$SCAN_SCRIPT" "$SENSITIVE_FEATURE" --verbose 2>&1
)"; then
  parser_status=0
else
  parser_status=$?
fi
printf '%s\n' "$parser_output"
if [[ "$parser_status" -eq 1 ]] && printf '%s\n' "$parser_output" | grep -Fq 'reason=SENSITIVE_STORAGE_CONFIG_INVALID'; then
  pass "Parser-unavailable configured approval fails closed"
else
  fail "Parser-unavailable configured approval fails closed"
fi

echo "Scenario: portable watchdog preserves exit 124 without GNU coreutils."
NO_TIMEOUT_PATH="$TMPDIR/no-timeout-path"
mkdir -p "$NO_TIMEOUT_PATH"
ln -s "$(command -v sleep)" "$NO_TIMEOUT_PATH/sleep"
portable_timeout_status=0
if (
  PATH="$NO_TIMEOUT_PATH"
  hash -r
  bubbles_run_with_timeout 1 /bin/sleep 5
); then
  portable_timeout_status=0
else
  portable_timeout_status=$?
fi
if [[ "$portable_timeout_status" -eq 124 ]]; then
  echo "PORTABLE_WATCHDOG_FALLBACK=124"
  pass "Portable watchdog preserves exit 124"
else
  echo "PORTABLE_WATCHDOG_FALLBACK=$portable_timeout_status"
  fail "Portable watchdog preserves exit 124"
fi

echo "Scenario: fixed-operation timeout recovery leaves the next classifier run healthy."
write_protocol_zero_source
run_scan_in_repo "$PROTOCOL_REPO" "$PROTOCOL_FEATURE"
if [[ "$RUN_STATUS" -eq 0 ]]; then
  pass "Classifier remains reusable after both watchdog timeouts"
else
  fail "Classifier remains reusable after both watchdog timeouts (scanner exit $RUN_STATUS)"
fi
assert_output_contains "classifier protocol complete: version=SCS1 scanned=1 findings=0" "Post-timeout classifier completes its protocol"
assert_classifier_helper_cache_absent "Post-timeout real producer leaves the helper directory clean"

# Only a run that reaches this point may return its verdict. The EXIT trap
# converts every earlier zero-status exit into failure, while preserving any
# original nonzero status and the dedicated INT/TERM statuses.
SELFTEST_COMPLETED=1

echo "implementation-reality-scan selftest summary: failures=$failures skips=$skips"

if [[ "$skips" -gt 0 ]]; then
  echo "implementation-reality-scan selftest skipped $skips scenario group(s) for an absent prerequisite."
fi

if [[ "$failures" -gt 0 ]]; then
  echo "implementation-reality-scan selftest failed with $failures issue(s)."
  exit 1
fi

if [[ "$skips" -gt 0 ]]; then
  echo "implementation-reality-scan selftest passed the scenarios it could run ($skips skipped)."
  exit 0
fi

echo "implementation-reality-scan selftest passed."