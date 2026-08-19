#!/usr/bin/env bash
set -euo pipefail

# Persistent regression for SCOPE-11 / Gate G088.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -x "$REPO_ROOT/bubbles/scripts/post-cert-spec-edit-guard.sh" ]]; then
  GUARD="$REPO_ROOT/bubbles/scripts/post-cert-spec-edit-guard.sh"
  SELFTEST="$REPO_ROOT/bubbles/scripts/post-cert-spec-edit-guard-selftest.sh"
elif [[ -x "$REPO_ROOT/.github/bubbles/scripts/post-cert-spec-edit-guard.sh" ]]; then
  GUARD="$REPO_ROOT/.github/bubbles/scripts/post-cert-spec-edit-guard.sh"
  SELFTEST="$REPO_ROOT/.github/bubbles/scripts/post-cert-spec-edit-guard-selftest.sh"
else
  echo "test_11_post_cert_spec_edit: guard not executable from $REPO_ROOT" >&2
  exit 2
fi

PASS_COUNT=0
FAIL_COUNT=0

WORKSPACE="$(mktemp -d -t bubbles-g088-regression-XXXXXXXX)"
cleanup() {
  rm -rf "$WORKSPACE" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

pass() { PASS_COUNT=$((PASS_COUNT + 1)); echo "PASS: $*"; }
fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); echo "FAIL: $*"; }

display_path() {
  local path="$1"
  if [[ -n "${HOME:-}" && "$path" == "$HOME"/* ]]; then
    # shellcheck disable=SC2088  # literal ~/ is intentional display text, not a path to expand
    printf '~/%s' "${path#"$HOME"/}"
  else
    printf '%s' "$path"
  fi
}

run_check() {
  local label="$1"
  shift
  set +e
  "$@"
  local rc=$?
  set -e
  if [[ "$rc" -eq 0 ]]; then
    pass "$label exit=$rc"
  else
    fail "$label exit=$rc"
  fi
}

stage_post_cert_fixture() {
  local repo="$WORKSPACE/g088-source-free-fixture"
  local spec_dir="$repo/specs/900-fixture-post-cert"
  rm -rf "$repo"
  mkdir -p "$spec_dir/scopes/01-fixture"
  git -C "$repo" -c init.defaultBranch=main init >/dev/null
  git -C "$repo" config user.email regression@example.invalid
  git -C "$repo" config user.name "G088 Regression"
  cat > "$spec_dir/spec.md" <<'EOF'
# Post-Certification Fixture Spec

Initial planning truth.
EOF
  cat > "$spec_dir/design.md" <<'EOF'
# Post-Certification Fixture Design

Initial design truth.
EOF
  cat > "$spec_dir/scopes/_index.md" <<'EOF'
# Scope Index

| # | Scope | Status |
|---|-------|--------|
| 01 | fixture | Done |
EOF
  cat > "$spec_dir/scopes/01-fixture/scope.md" <<'EOF'
# Scope 01 Fixture

**Status:** Done
EOF
  cat > "$spec_dir/state.json" <<'JSON'
{
  "version": 3,
  "featureDir": "specs/900-fixture-post-cert",
  "featureName": "Post-Certification Fixture",
  "status": "done",
  "workflowMode": "full-delivery",
  "linkedImplementationSpec": null,
  "linkedPlanningPacket": null,
  "planningOnly": false,
  "planningOnlyJustification": null,
  "specDependsOn": [],
  "certifiedAt": "2026-05-01T00:00:00Z",
  "requiresRevalidation": false,
  "executionHistory": []
}
JSON
  git -C "$repo" add .
  GIT_AUTHOR_DATE="2026-04-30T00:00:00Z" GIT_COMMITTER_DATE="2026-04-30T00:00:00Z" git -C "$repo" commit -m "baseline certified fixture" >/dev/null
  printf '%s' "$spec_dir"
}

echo "=== test_11_post_cert_spec_edit (Gate G088 regression) ==="
echo "Repository: $(display_path "$REPO_ROOT")"
echo "Guard: $(display_path "$GUARD")"
echo "Selftest: $(display_path "$SELFTEST")"

echo ""
echo "--- R1: SCOPE-11 hermetic G088 post-certification edit matrix ---"
run_check "R1 selftest matrix" bash "$SELFTEST"

echo ""
echo "--- R2: staged fixture post-cert edit guard pass with G092 legacy-read-only boundary ---"
fixture_spec="$(stage_post_cert_fixture)"
run_check "R2 staged fixture" bash "$GUARD" "$fixture_spec"

# IMP-049 Option C: the classifier must clear a mandated redaction and must NOT
# clear a requirements change. Both directions are persistent regressions, not
# only hermetic selftest scenarios, because a filter bug that silently suppresses
# real drift is the worst outcome this gate can have (IMP-049 R1).
echo ""
echo "--- R3: a concrete-value -> placeholder redaction is cleared, not reported as drift ---"
r3_spec="$(stage_post_cert_fixture)"
r3_repo="$(cd "$r3_spec/../.." && pwd -P)"
# The certified baseline must actually carry the concrete value, so the later
# edit is a one-line substitution rather than a whole-file rewrite.
printf 'Deploy to prod-01.internal.example-corp.com nightly.\n' > "$r3_spec/spec.md"
GIT_AUTHOR_DATE="2026-04-30T00:00:00Z" GIT_COMMITTER_DATE="2026-04-30T00:00:00Z" \
  git -C "$r3_repo" commit -aq --amend --no-edit >/dev/null 2>&1
printf 'Deploy to <DEPLOY_HOST> nightly.\n' > "$r3_spec/spec.md"
GIT_AUTHOR_DATE="2026-05-02T00:00:00Z" GIT_COMMITTER_DATE="2026-05-02T00:00:00Z" \
  git -C "$r3_repo" commit -aqm "chore(genericize): remove machine-local values" >/dev/null 2>&1
run_check "R3 redaction cleared" bash "$GUARD" "$r3_spec"

echo ""
echo "--- R4 ADVERSARIAL: a requirements change is still reported as drift ---"
r4_spec="$(stage_post_cert_fixture)"
r4_repo="$(cd "$r4_spec/../.." && pwd -P)"
printf 'The system MUST retain audit records for 30 days.\n' > "$r4_spec/spec.md"
GIT_AUTHOR_DATE="2026-04-30T00:00:00Z" GIT_COMMITTER_DATE="2026-04-30T00:00:00Z" \
  git -C "$r4_repo" commit -aq --amend --no-edit >/dev/null 2>&1
printf 'The system MUST retain audit records for 90 days.\n' > "$r4_spec/spec.md"
GIT_AUTHOR_DATE="2026-05-02T00:00:00Z" GIT_COMMITTER_DATE="2026-05-02T00:00:00Z" \
  git -C "$r4_repo" commit -aqm "chore(genericize): remove machine-local values" >/dev/null 2>&1
if bash "$GUARD" "$r4_spec" >/dev/null 2>&1; then
  fail "R4 requirements change was wrongly cleared as a redaction"
else
  pass "R4 requirements change still reported as drift"
fi

echo ""
echo "=== Regression verdict ==="
printf '  Total checks: %d\n' "$((PASS_COUNT + FAIL_COUNT))"
printf '  Passed:       %d\n' "$PASS_COUNT"
printf '  Failed:       %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "test_11_post_cert_spec_edit: FAILED" >&2
  exit 1
fi

echo "test_11_post_cert_spec_edit: PASSED"
exit 0