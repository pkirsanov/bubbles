#!/usr/bin/env bash
# =============================================================================
# bubbles-implementation-reality-scan.sh
# =============================================================================
# Scans implementation source files for stub, fake, hardcoded data, and
# default/fallback patterns that violate the "Real Implementation" and
# "No Defaults/No Fallbacks" policies.
#
# This script is PROJECT-AGNOSTIC — it works on any repo. It scans files
# referenced in scopes.md (or per-scope scope.md) for violations.
#
# Scans:
#   1. Backend stub patterns (hardcoded vecs, fake/mock/stub functions)
#   2. Frontend fake data (getSimulationData, mock imports, hardcoded arrays)
#   3. Frontend API call absence (hooks/services with zero fetch/axios calls)
#   4. Prohibited simulation helpers in production (seeded_pick/seeded_range)
#   5. Default/fallback value patterns (unwrap_or, || default, ?? fallback)
#
# Usage:
#   bash .github/scripts/bubbles-implementation-reality-scan.sh <feature-dir> [--verbose]
#
# Exit codes:
#   0 = No violations found
#   1 = Violations detected (blocking)
#   2 = Usage error
#
# Called automatically by bubbles-state-transition-guard.sh (Check 15).
# Can also be run standalone for pre-completion self-audit.
# =============================================================================
set -euo pipefail

feature_dir="${1:-}"
verbose="false"

for arg in "$@"; do
  if [[ "$arg" == "--verbose" ]]; then
    verbose="true"
  fi
done

if [[ -z "$feature_dir" ]]; then
  echo "ERROR: missing feature directory argument"
  echo "Usage: bash .github/scripts/bubbles-implementation-reality-scan.sh specs/<NNN-feature-name> [--verbose]"
  exit 2
fi

if [[ ! -d "$feature_dir" ]]; then
  echo "ERROR: feature directory not found: $feature_dir"
  exit 2
fi

violations=0
warnings=0
scanned_files=0

violation() {
  local file="$1"
  local line_num="$2"
  local pattern="$3"
  local context="$4"
  echo "🔴 VIOLATION [$pattern] $file:$line_num"
  if [[ "$verbose" == "true" ]]; then
    echo "   Context: $context"
  fi
  violations=$((violations + 1))
}

vwarn() {
  local message="$1"
  echo "⚠️  WARN: $message"
  warnings=$((warnings + 1))
}

pass() {
  local message="$1"
  echo "✅ PASS: $message"
}

info() {
  local message="$1"
  echo "ℹ️  INFO: $message"
}

# =============================================================================
# Detect scope layout and collect scope files
# =============================================================================
scope_files=()
if [[ -f "$feature_dir/scopes/_index.md" ]]; then
  while IFS= read -r scope_path; do
    scope_files+=("$scope_path")
  done < <(find "$feature_dir/scopes" -mindepth 2 -maxdepth 2 -type f -name 'scope.md' 2>/dev/null | sort)
elif [[ -f "$feature_dir/scopes.md" ]]; then
  scope_files=("$feature_dir/scopes.md")
fi

if [[ ${#scope_files[@]} -eq 0 ]]; then
  echo "ERROR: No scope files found in $feature_dir"
  exit 2
fi

# =============================================================================
# Extract implementation source file paths from scope files
# =============================================================================

# resolve_path: given a potentially bare filename or relative path, attempt to
# find the actual file on disk. Returns resolved path or empty string.
resolve_path() {
  local candidate="$1"
  # If it already exists as given, use it directly
  if [[ -f "$candidate" ]]; then
    echo "$candidate"
    return
  fi
  # If the path has no directory component (bare filename like "ml.rs"),
  # search common source directories for it.
  if [[ "$candidate" != */* ]]; then
    local found
    found="$(find services/gateway/src/handlers \
                  services/gateway/src/scripting/api \
                  services/ \
                  libs/ \
             -maxdepth 5 -name "$candidate" -type f 2>/dev/null | head -1 || true)"
    if [[ -n "$found" ]]; then
      echo "$found"
      return
    fi
  fi
  echo ""
}

# add_impl_file: deduplicate and add to impl_files array
add_impl_file() {
  local path="$1"
  for existing in "${impl_files[@]+"${impl_files[@]}"}"; do
    if [[ "$existing" == "$path" ]]; then
      return
    fi
  done
  impl_files+=("$path")
}

impl_files=()

# Batch-extract all backtick-wrapped file paths from each scope file using
# a single grep pass per file (avoids per-line subprocess overhead on large
# scopes.md files).
for scope_file in "${scope_files[@]}"; do
  while IFS= read -r raw_path; do
    # Strip backticks
    path="${raw_path//\`/}"
    # Strip any trailing ::test_name references (e.g., `file.rs::test_foo`)
    path="${path%%::*}"
    resolved="$(resolve_path "$path")"
    if [[ -n "$resolved" ]]; then
      add_impl_file "$resolved"
    fi
  done < <(grep -oE '`[^`]+\.(rs|ts|tsx|js|jsx|py|go|java|dart)\b[^`]*`' "$scope_file" 2>/dev/null | sort -u || true)
done

# =============================================================================
# Fallback: If scopes yielded zero files, try design.md
# =============================================================================
if [[ ${#impl_files[@]} -eq 0 ]] && [[ -f "$feature_dir/design.md" ]]; then
  info "Scopes yielded 0 files — falling back to design.md for file discovery"
  while IFS= read -r raw_path; do
    path="${raw_path//\`/}"
    path="${path%%::*}"
    resolved="$(resolve_path "$path")"
    if [[ -n "$resolved" ]]; then
      add_impl_file "$resolved"
    fi
  done < <(grep -oE '`[^`]+\.(rs|ts|tsx|js|jsx|py|go|java|dart)\b[^`]*`' "$feature_dir/design.md" 2>/dev/null | sort -u || true)
  if [[ ${#impl_files[@]} -gt 0 ]]; then
    vwarn "Resolved ${#impl_files[@]} file(s) from design.md fallback — scopes.md should reference these directly"
  fi
fi

if [[ ${#impl_files[@]} -eq 0 ]]; then
  echo "🔴 VIOLATION [ZERO_FILES_RESOLVED] No implementation file paths resolved from scope files"
  echo ""
  echo "  This means scopes.md / scope.md files either:"
  echo "    1. Do not reference implementation files in backtick-wrapped paths, or"
  echo "    2. Reference files that do not exist on disk"
  echo ""
  echo "  Scanning nothing = no assurance. This is a blocking failure."
  echo "  Fix: Ensure scopes.md lists implementation files as \`path/to/file.rs\`"
  echo ""
  echo "============================================================"
  echo "  REALITY SCAN RESULT: 1 violation(s), 0 warning(s)"
  echo "  Files scanned: 0"
  echo "============================================================"
  exit 1
fi

info "Resolved ${#impl_files[@]} implementation file(s) to scan"
echo ""

# =============================================================================
# SCAN 1: Gateway/Backend Stub Detection
# =============================================================================
# Detects handlers that return hardcoded/seeded data instead of real
# backend service calls. Common patterns:
#   - vec![StructName { field: "literal" }]  (Rust hardcoded vec)
#   - return Ok(vec![...])  with inline struct construction
#   - generate_*, simulate_*, seed_*, fake_* function calls in handlers
#   - Static arrays/slices returned directly from handler functions
# =============================================================================
echo "--- Scan 1: Gateway/Backend Stub Patterns ---"

BACKEND_STUB_PATTERNS=(
  # Rust: hardcoded vec construction in handler-like contexts
  'vec!\[.*{.*:.*"'
  # Rust: returning seeded/simulated/fake data function calls
  'generate_fake\|generate_mock\|generate_stub\|generate_sample'
  'simulate_.*data\|simulation_data\|get_simulation\|getSimulation'
  'seed_data\|seeded_data\|fake_data\|mock_data\|sample_data\|dummy_data'
  'hardcoded_\|HARDCODED_\|SAMPLE_DATA\|MOCK_DATA\|FAKE_DATA\|DUMMY_DATA'
  # Any language: static/const arrays used as response data
  'static.*RESPONSES\|static.*ITEMS\|static.*RECORDS\|static.*ENTRIES'
  'const.*RESPONSES\|const.*ITEMS\|const.*RECORDS\|const.*ENTRIES'
  # Functions explicitly named as stubs/fakes
  'fn fake_\|fn mock_\|fn stub_\|fn placeholder_'
  'function fake\|function mock\|function stub\|function placeholder'
  'def fake_\|def mock_\|def stub_\|def placeholder_'
)

for impl_file in "${impl_files[@]}"; do
  scanned_files=$((scanned_files + 1))
  file_ext="${impl_file##*.}"

  # Only scan backend files (rs, go, py, java) for backend stub patterns
  if [[ "$file_ext" == "rs" || "$file_ext" == "go" || "$file_ext" == "py" || "$file_ext" == "java" ]]; then
    # Skip test files — stubs/mocks in test files are a separate concern
    if echo "$impl_file" | grep -qE '(test|spec|_test\.rs|_test\.go|test_)'; then
      continue
    fi

    # Find the #[cfg(test)] boundary — lines after this are test code (Rust)
    cfg_test_line=999999
    if [[ "$file_ext" == "rs" ]]; then
      local_cfg="$(grep -n '#\[cfg(test)\]' "$impl_file" 2>/dev/null | head -1 | cut -d: -f1 || true)"
      if [[ -n "$local_cfg" ]]; then cfg_test_line=$local_cfg; fi
    fi

    for pattern in "${BACKEND_STUB_PATTERNS[@]}"; do
      while IFS=: read -r line_num matched_line; do
        # Skip lines in #[cfg(test)] module
        if [[ "$line_num" -ge "$cfg_test_line" ]]; then
          continue
        fi
        # Skip comment lines
        if echo "$matched_line" | grep -qE '^\s*(//|#|/\*|\*)'; then
          continue
        fi
        violation "$impl_file" "$line_num" "BACKEND_STUB" "$matched_line"
      done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
    done

    # Multi-line vec! detection (Rust only): vec![ on one line, struct or
    # json macro with string literals on subsequent lines.
    #
    # Approved patterns that are NOT violations:
    #   1. Lines annotated with "// @catalog" — static API metadata
    #   2. vec! within ±30 lines of SimPrng/OrnsteinUhlenbeck/MarkovChain
    #      usage — approved stochastic simulation, not hardcoded data
    if [[ "$file_ext" == "rs" ]]; then
      while IFS=: read -r line_num matched_line; do
        # Skip lines in #[cfg(test)] module
        if [[ "$line_num" -ge "$cfg_test_line" ]]; then
          continue
        fi
        if echo "$matched_line" | grep -qE '^\s*(//|/\*|\*)'; then
          continue
        fi
        # Skip lines annotated as approved static metadata
        if echo "$matched_line" | grep -qE '@catalog'; then
          continue
        fi
        # Skip vec! within ±30 lines of approved simulation model usage
        file_len=$(wc -l < "$impl_file")
        sim_start=$((line_num - 30))
        if [[ $sim_start -lt 1 ]]; then sim_start=1; fi
        sim_end=$((line_num + 30))
        if [[ $sim_end -gt $file_len ]]; then sim_end=$file_len; fi
        has_sim="$(sed -n "${sim_start},${sim_end}p" "$impl_file" | grep -cE 'SimPrng|OrnsteinUhlenbeck|MarkovChain|from_seed_str' || true)"
        if [[ "$has_sim" -gt 0 ]]; then
          continue
        fi
        # Check if any of the next 5 lines contain struct field: "literal"
        # or serde_json key-value pairs with string values (need 3+ to be
        # considered hardcoded data, not just an ID field)
        end_line=$((line_num + 5))
        if [[ $end_line -gt $file_len ]]; then end_line=$file_len; fi
        has_struct_literal="$(sed -n "$((line_num + 1)),${end_line}p" "$impl_file" | grep -cE '[a-z_]+:\s*"|"[a-z_]+":\s*"' || true)"
        if [[ "$has_struct_literal" -ge 3 ]]; then
          violation "$impl_file" "$line_num" "HARDCODED_VEC_STRUCT" "$matched_line (struct with string literals follows)"
        fi
      done < <(grep -nE 'vec!\[' "$impl_file" 2>/dev/null | grep -vE '^\s*(//|/\*|\*)' | grep -vE 'vec!\[\s*\]' || true)
    fi
  fi
done
echo ""

# =============================================================================
# SCAN 2: Frontend Hardcoded Data Detection
# =============================================================================
# Detects frontend code using hardcoded/simulation data instead of real
# API calls. Common patterns:
#   - getSimulationData() calls
#   - Hooks with zero fetch()/axios/api calls that return static data
#   - Hardcoded arrays/objects used as component data sources
#   - Import of simulation/mock data modules in production code
# =============================================================================
echo "--- Scan 2: Frontend Hardcoded Data Patterns ---"

FRONTEND_FAKE_PATTERNS=(
  # Simulation data function calls
  'getSimulationData\|getSimulation\|useSimulationData\|useSimulation'
  'getMockData\|useMockData\|getFakeData\|useFakeData'
  'getSampleData\|useSampleData\|getDummyData\|useDummyData'
  # Import of simulation/mock/fake data modules
  'import.*simulat\|import.*mockData\|import.*fakeData\|import.*sampleData'
  'from.*simulat.*import\|from.*mock_data\|from.*fake_data\|from.*sample_data'
  'require.*simulat\|require.*mockData\|require.*fakeData'
  # Hardcoded data constants used as data sources
  'MOCK_.*=\s*\[\|FAKE_.*=\s*\[\|SAMPLE_.*=\s*\[\|DUMMY_.*=\s*\['
  'SIMULATION_.*=\s*\[\|HARDCODED_.*=\s*\['
  'mockData\s*=\s*\[\|fakeData\s*=\s*\[\|sampleData\s*=\s*\['
  'simulationData\s*=\s*\[\|dummyData\s*=\s*\['
  # Static data generation in hooks
  'generate_fake\|generate_mock\|generate_stub\|generate_sample'
)

for impl_file in "${impl_files[@]}"; do
  file_ext="${impl_file##*.}"

  # Only scan frontend files (ts, tsx, js, jsx, dart) for frontend patterns
  if [[ "$file_ext" == "ts" || "$file_ext" == "tsx" || "$file_ext" == "js" || "$file_ext" == "jsx" || "$file_ext" == "dart" ]]; then
    # Skip test files
    if echo "$impl_file" | grep -qE '(\.test\.|\.spec\.|__tests__|__mocks__|e2e|playwright)'; then
      continue
    fi

    for pattern in "${FRONTEND_FAKE_PATTERNS[@]}"; do
      while IFS=: read -r line_num matched_line; do
        # Skip comment lines
        if echo "$matched_line" | grep -qE '^\s*(//|#|/\*|\*|{/\*)'; then
          continue
        fi
        violation "$impl_file" "$line_num" "FRONTEND_FAKE_DATA" "$matched_line"
      done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
    done
  fi
done
echo ""

# =============================================================================
# SCAN 3: Frontend API Call Absence Detection
# =============================================================================
# Detects frontend hook/service files that should make API calls but don't.
# A "data hook" or "service" file that has zero fetch/axios/api calls is
# likely returning hardcoded or simulated data.
#
# Heuristic: files matching *hook*.ts, *service*.ts, use*.ts, *api*.ts
# that contain zero occurrences of: fetch, axios, api., useMutation,
# useQuery, httpClient, .get(, .post(, .put(, .delete(, .patch(
# =============================================================================
echo "--- Scan 3: Frontend API Call Absence ---"

API_CALL_PATTERNS='fetch\|axios\|\.get(\|\.post(\|\.put(\|\.delete(\|\.patch(\|useMutation\|useQuery\|useSWR\|httpClient\|apiClient\|grpc\|protobuf'

for impl_file in "${impl_files[@]}"; do
  file_ext="${impl_file##*.}"
  file_basename="$(basename "$impl_file")"

  # Only check frontend data-fetching files
  if [[ "$file_ext" == "ts" || "$file_ext" == "tsx" || "$file_ext" == "js" || "$file_ext" == "jsx" ]]; then
    # Skip test files
    if echo "$impl_file" | grep -qE '(\.test\.|\.spec\.|__tests__|__mocks__|e2e|playwright)'; then
      continue
    fi

    # Check if this looks like a data-fetching file (hook, service, api)
    is_data_file="false"
    if echo "$file_basename" | grep -qiE '(hook|service|api|fetch|data|store|query|use[A-Z])'; then
      is_data_file="true"
    fi
    # Also check if file contains "export function use" or "export const use" (custom hook pattern)
    if grep -qE 'export\s+(function|const)\s+use[A-Z]' "$impl_file" 2>/dev/null; then
      is_data_file="true"
    fi

    if [[ "$is_data_file" == "true" ]]; then
      api_call_count="$(grep -cE "$API_CALL_PATTERNS" "$impl_file" 2>/dev/null || true)"
      if [[ "$api_call_count" -eq 0 ]]; then
        violation "$impl_file" "0" "NO_API_CALLS" "Data hook/service file has ZERO API calls — likely returning hardcoded data"
      fi
    fi
  fi
done
echo ""

# =============================================================================
# SCAN 4: seeded_pick / seeded_range in production Rust code
# =============================================================================
# Project-specific: quantitativeFinance prohibits seeded_pick/seeded_range
# in production code (allowed in test code only).
# This scan is only active if the patterns are found in scope-referenced files.
# =============================================================================
echo "--- Scan 4: Prohibited Simulation Helpers in Production ---"

PROHIBITED_SIM_PATTERNS=(
  'seeded_pick\|seeded_range\|seed_from_str'
)

for impl_file in "${impl_files[@]}"; do
  file_ext="${impl_file##*.}"

  # Only scan Rust production files
  if [[ "$file_ext" == "rs" ]]; then
    if echo "$impl_file" | grep -qE '(test|spec|_test\.rs|tests/)'; then
      continue
    fi
    for pattern in "${PROHIBITED_SIM_PATTERNS[@]}"; do
      while IFS=: read -r line_num matched_line; do
        if echo "$matched_line" | grep -qE '^\s*(//|/\*|\*)'; then
          continue
        fi
        violation "$impl_file" "$line_num" "PROHIBITED_SIM_HELPER" "$matched_line"
      done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
    done
  fi
done
echo ""

# =============================================================================
# SCAN 5: Default/Fallback Value Detection in Production Code
# =============================================================================
# Detects production code that uses default values, fallbacks, or silent
# recovery instead of failing fast on missing config/data.
# These patterns hide failures and violate the "No Defaults" policy.
#
# Language-specific patterns:
#   Rust:    unwrap_or(), unwrap_or_default(), unwrap_or_else(|| default)
#   Go:      getEnv("K", "fallback"), os.Getenv with || fallback
#   Python:  os.getenv("K", "default"), .get("k", default)
#   TS/JS:   || "default", ?? "fallback", || 'fallback'
#   Shell:   ${VAR:-default}
# =============================================================================
echo "--- Scan 5: Default/Fallback Value Patterns ---"

RUST_DEFAULT_PATTERNS=(
  'unwrap_or\b\|unwrap_or_default\b\|unwrap_or_else'
  'or_else.*Ok\|or_else.*Some'
)

GO_DEFAULT_PATTERNS=(
  'getEnv.*,.*"[^"]\+'
  'Getenv.*\|\|'
  'LookupEnv.*default\|LookupEnv.*fallback'
)

TS_JS_DEFAULT_PATTERNS=(
  'process\.env\.\w\+\s*[|][|]\s*['"'"'"]*'
  'import\.meta\.env\.\w\+\s*[|][|]\s*['"'"'"]*'
  'import\.meta\.env\.\w\+\s*\?\?\s*['"'"'"]*'
  'env\.\w\+\s*\?\?\s*['"'"'"]*'
  'env\.\w\+\s*[|][|]\s*['"'"'"]*'
)

PYTHON_DEFAULT_PATTERNS=(
  'os\.getenv.*,\s*['"'"'"]'
  'os\.environ\.get.*,\s*['"'"'"]'
  '\.get(.*,\s*['"'"'"].*default'
)

for impl_file in "${impl_files[@]}"; do
  file_ext="${impl_file##*.}"

  # Skip test files
  if echo "$impl_file" | grep -qE '(test|spec|_test\.|\.test\.|\.spec\.|__tests__|__mocks__|e2e|playwright)'; then
    continue
  fi

  case "$file_ext" in
    rs)
      for pattern in "${RUST_DEFAULT_PATTERNS[@]}"; do
        while IFS=: read -r line_num matched_line; do
          if echo "$matched_line" | grep -qE '^\s*(//|/\*|\*)'; then continue; fi
          violation "$impl_file" "$line_num" "DEFAULT_FALLBACK" "$matched_line"
        done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
      done
      ;;
    go)
      for pattern in "${GO_DEFAULT_PATTERNS[@]}"; do
        while IFS=: read -r line_num matched_line; do
          if echo "$matched_line" | grep -qE '^\s*(//|/\*|\*)'; then continue; fi
          violation "$impl_file" "$line_num" "DEFAULT_FALLBACK" "$matched_line"
        done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
      done
      ;;
    ts|tsx|js|jsx)
      for pattern in "${TS_JS_DEFAULT_PATTERNS[@]}"; do
        while IFS=: read -r line_num matched_line; do
          if echo "$matched_line" | grep -qE '^\s*(//|/\*|\*|{/\*)'; then continue; fi
          violation "$impl_file" "$line_num" "DEFAULT_FALLBACK" "$matched_line"
        done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
      done
      ;;
    py)
      for pattern in "${PYTHON_DEFAULT_PATTERNS[@]}"; do
        while IFS=: read -r line_num matched_line; do
          if echo "$matched_line" | grep -qE '^\s*#'; then continue; fi
          violation "$impl_file" "$line_num" "DEFAULT_FALLBACK" "$matched_line"
        done < <(grep -nE "$pattern" "$impl_file" 2>/dev/null || true)
      done
      ;;
  esac
done
echo ""

# =============================================================================
# FINAL VERDICT
# =============================================================================
echo "============================================================"
echo "  IMPLEMENTATION REALITY SCAN RESULT"
echo "============================================================"
echo ""
echo "  Files scanned:  $scanned_files"
echo "  Violations:     $violations"
echo "  Warnings:       $warnings"
echo ""

if [[ "$violations" -gt 0 ]]; then
  echo "🔴 BLOCKED: $violations source code reality violation(s) found"
  echo ""
  echo "These violations indicate stub, fake, or hardcoded data patterns"
  echo "in implementation files. ALL violations must be resolved before"
  echo "the spec/scope can be marked 'done'."
  echo ""
  echo "Common fixes:"
  echo "  - Replace hardcoded Vec/array returns with real DB queries"
  echo "  - Replace getSimulationData() with real API fetch() calls"
  echo "  - Replace simulate_*() in handlers with real service calls"
  echo "  - Add real fetch/axios/grpc calls to data hooks"
  echo "  - Replace unwrap_or()/unwrap_or_default() with ? and fail-fast"
  echo "  - Replace || 'default' / ?? 'fallback' with explicit missing-config errors"
  echo "  - Replace os.getenv('K', 'default') with fail-fast on missing env"
  exit 1
else
  if [[ "$warnings" -gt 0 ]]; then
    echo "🟡 PASSED with $warnings warning(s) — manual review advised"
  else
    echo "🟢 PASSED: No source code reality violations detected"
  fi
  exit 0
fi
