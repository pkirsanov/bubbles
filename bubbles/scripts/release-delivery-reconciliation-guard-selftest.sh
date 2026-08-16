#!/usr/bin/env bash
set -uo pipefail

# release-delivery-reconciliation-guard-selftest.sh
#
# Hermetic selftest for `bubbles/scripts/release-delivery-reconciliation-guard.sh`
# (Gate G101 — IMP-006). Stages throwaway repo roots under a temp workspace and
# asserts the guard's exit code for clean + adversarial release-packet shapes.
#
# Scenarios:
#   S0  non-existent repo root                                  → exit 2
#   S1  reconciled mvp packet; required feature done +           → exit 0
#       validate-certified
#   S2  reconciled packet; required feature spec dir MISSING     → exit 1  (ADVERSARIAL:
#       (a downstream "promised-but-unspecced" shape)                       SCOPE-6 replay)
#   S3  reconciled packet; required feature status in_progress   → exit 1  (ADVERSARIAL)
#   S4  reconciled packet; required feature done but 'validate'  → exit 1  (ADVERSARIAL:
#       absent from completed phases (implement self-cert)                  self-certification)
#   S5  reconciled-packet header but ZERO feature annotations    → exit 1  (ADVERSARIAL:
#       (silent-no-op trap)                                                 fail-loud-on-malformed)
#   S6  grandfathered packet (no header), missing spec,          → exit 0  (backward-compat
#       no --require-coverage                                               WARN-only)
#   S7  same grandfathered packet + --require-coverage           → exit 1  (ADVERSARIAL:
#       (scenario/convergence path forces blocking)                        scenario path)
#   S8  reconciled packet; optional/carried/deferred features    → exit 0  (only 'required'
#       with spec=none                                                      is enforced)
#   S9  reconciled packet; required feature BLOCKED w/ reason     → exit 1  (ADVERSARIAL:
#                                                                           honest blocked != delivered)
#   S10 source-repo-shaped root (no docs/releases)               → exit 0  (EXEMPT)
#   S11 reconciled packet; annotation missing 'delivery' field   → exit 1  (ADVERSARIAL: malformed)
#   S12 reconciled packet; required feature delivered_prototype   → exit 1  (assurance invariant:
#       (validate-certified)                                                 prototype never deployable)#   S13 --mode structural; required feature in_progress          → exit 0  (delivery NOT asserted)
#   S14 --mode structural; required feature BLOCKED              → exit 0  (delivery NOT asserted)
#   S15 --mode structural; malformed annotation                  → exit 1  (ADVERSARIAL: teeth)
#   S16 --mode structural; required feature spec dir MISSING     → exit 1  (ADVERSARIAL: teeth)
#   S17 --mode bogus                                             → exit 2  (closed vocabulary)#
# Reference: improvements/IMP-006-release-delivery-reconciliation.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="$SCRIPT_DIR/release-delivery-reconciliation-guard.sh"

if [[ ! -x "$GUARD" ]]; then
  echo "selftest: guard not executable: $GUARD" >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "selftest: jq is required" >&2
  exit 2
fi

WORKSPACE="$(mktemp -d -t bubbles-reldeliv-selftest-XXXXXXXX)"
trap 'rm -rf "$WORKSPACE"' EXIT INT TERM

PASS_COUNT=0
FAIL_COUNT=0
FAILED=()

pass() {
  echo "  PASS: $1"
  PASS_COUNT=$((PASS_COUNT + 1))
}
bad() {
  echo "  FAIL: $1" >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
  FAILED+=("$1")
}

new_repo() {
  local name="$1"
  local d="$WORKSPACE/$name"
  mkdir -p "$d"
  printf '%s' "$d"
}

# mk_features <repo> <phase> <reconciled true|false> [annotation ...]
mk_features() {
  local repo="$1" phase="$2" reconciled="$3"
  shift 3
  local dir="$repo/docs/releases/$phase"
  mkdir -p "$dir"
  {
    echo "# $phase — features"
    echo ""
    if [[ "$reconciled" == "true" ]]; then
      echo "<!-- bubbles:reconciled-packet schemaVersion=1 phase=$phase -->"
    fi
    local ann
    for ann in "$@"; do
      echo "<!-- $ann -->"
    done
  } >"$dir/features.md"
}

# mk_features_dep <repo> <phase> <dependsOn-csv> [annotation ...]
# mk_features emits no dependsOn, which the prerequisite cases require.
mk_features_dep() {
  local repo="$1" phase="$2" depends="$3"
  shift 3
  local dir="$repo/docs/releases/$phase"
  mkdir -p "$dir"
  {
    echo "# $phase — features"
    echo ""
    echo "<!-- bubbles:reconciled-packet schemaVersion=1 phase=$phase dependsOn=$depends -->"
    local ann
    for ann in "$@"; do
      echo "<!-- $ann -->"
    done
  } >"$dir/features.md"
}

# mk_spec <repo> <specpath> <status> [phase ...]   (completedPhases)
mk_spec() {
  local repo="$1" specpath="$2" status="$3"
  shift 3
  local dir="$repo/$specpath"
  mkdir -p "$dir"
  local phases_json="[]"
  if [[ $# -gt 0 ]]; then
    local acc=""
    local p
    for p in "$@"; do acc="$acc\"$p\","; done
    phases_json="[${acc%,}]"
  fi
  cat >"$dir/state.json" <<EOF
{ "version": 3, "specId": "$(basename "$specpath")", "status": "$status", "workflowMode": "full-delivery", "completedPhases": $phases_json }
EOF
}

# mk_spec_blocked <repo> <specpath> <reason>
mk_spec_blocked() {
  local repo="$1" specpath="$2" reason="$3"
  local dir="$repo/$specpath"
  mkdir -p "$dir"
  cat >"$dir/state.json" <<EOF
{ "version": 3, "specId": "$(basename "$specpath")", "status": "blocked", "workflowMode": "full-delivery", "blockedReason": "$reason", "completedPhases": ["plan","design","implement"] }
EOF
}

run_guard() {
  bash "$GUARD" "$@" >/dev/null 2>&1
  RC=$?
}

# mk_spec_mode <repo> <specpath> <status> <workflowMode> [phase ...]
# Needed because mk_spec hardcodes full-delivery, and the planning-only
# assurance cases turn on the spec's MODE, not just its status.
mk_spec_mode() {
  local repo="$1" specpath="$2" status="$3" wfmode="$4"
  shift 4
  local dir="$repo/$specpath"
  mkdir -p "$dir"
  local phases_json="[]"
  if [[ $# -gt 0 ]]; then
    local acc=""
    local p
    for p in "$@"; do acc="$acc\"$p\","; done
    phases_json="[${acc%,}]"
  fi
  cat >"$dir/state.json" <<EOF
{ "version": 3, "specId": "$(basename "$specpath")", "status": "$status", "workflowMode": "$wfmode", "completedPhases": $phases_json }
EOF
}

expect_rc() {
  local want="$1" desc="$2"
  if [[ "$RC" -eq "$want" ]]; then
    pass "$desc (rc=$RC)"
  else
    bad "$desc (want $want, got $RC)"
  fi
}

# ----------------------------------------------------------------------------
# S0 — non-existent repo root → 2
run_guard --repo-root "$WORKSPACE/does-not-exist"
expect_rc 2 "S0 non-existent repo root"

# S1 — reconciled, required feature done + validate-certified → 0
R1="$(new_repo s1)"
mk_features "$R1" mvp true \
  "bubbles:feature id=auth-real spec=specs/074-auth delivery=required"
mk_spec "$R1" specs/074-auth "done" plan design implement test validate audit docs
run_guard --repo-root "$R1" --phase mvp
expect_rc 0 "S1 required feature done+validate-certified"

# S2 — reconciled, required feature spec dir MISSING → 1 (downstream replay, SCOPE-6)
R2="$(new_repo s2)"
mk_features "$R2" mvp true \
  "bubbles:feature id=strategy-agent-runtime spec=specs/075-strategy-agent-runtime delivery=required"
# NOTE: no specs/075-* created — the exact downstream "promised but never specced" shape.
run_guard --repo-root "$R2" --phase mvp
expect_rc 1 "S2 required feature spec MISSING (downstream promised-but-unspecced replay)"

# S3 — reconciled, required feature in_progress → 1
R3="$(new_repo s3)"
mk_features "$R3" mvp true \
  "bubbles:feature id=billing spec=specs/076-billing delivery=required"
mk_spec "$R3" specs/076-billing in_progress plan design implement
run_guard --repo-root "$R3" --phase mvp
expect_rc 1 "S3 required feature in_progress"

# S4 — reconciled, required feature done but validate ABSENT → 1 (self-cert)
R4="$(new_repo s4)"
mk_features "$R4" mvp true \
  "bubbles:feature id=entitlements spec=specs/077-entitlements delivery=required"
mk_spec "$R4" specs/077-entitlements "done" plan design implement test
run_guard --repo-root "$R4" --phase mvp
expect_rc 1 "S4 required feature done but implement-self-certified (validate absent)"

# S5 — reconciled-packet header but ZERO annotations → 1 (silent-no-op trap)
R5="$(new_repo s5)"
mk_features "$R5" mvp true
run_guard --repo-root "$R5" --phase mvp
expect_rc 1 "S5 reconciled packet binds nothing (silent-no-op trap)"

# S6 — grandfathered packet (no header), missing spec, no --require-coverage → 0
R6="$(new_repo s6)"
mk_features "$R6" mvp false \
  "bubbles:feature id=foo spec=specs/078-foo delivery=required"
run_guard --repo-root "$R6" --phase mvp
expect_rc 0 "S6 grandfathered packet (WARN-only, missing spec tolerated)"

# S7 — same grandfathered packet + --require-coverage → 1
run_guard --repo-root "$R6" --phase mvp --require-coverage
expect_rc 1 "S7 grandfathered packet + --require-coverage forces blocking"

# S8 — reconciled, optional/carried/deferred with spec=none → 0
R8="$(new_repo s8)"
mk_features "$R8" mvp true \
  "bubbles:feature id=sso spec=none delivery=deferred-to:v2.0" \
  "bubbles:feature id=market-routes spec=none delivery=carried" \
  "bubbles:feature id=nice-to-have spec=none delivery=optional"
run_guard --repo-root "$R8" --phase mvp
expect_rc 0 "S8 non-required features with spec=none"

# S9 — reconciled, required feature BLOCKED with reason → 1
R9="$(new_repo s9)"
mk_features "$R9" mvp true \
  "bubbles:feature id=bridge spec=specs/063-bridge delivery=required"
mk_spec_blocked "$R9" specs/063-bridge "framework lint heuristic mismatch; operator-actionable"
run_guard --repo-root "$R9" --phase mvp
expect_rc 1 "S9 required feature blocked-with-reason (not delivered)"

# S10 — source-repo-shaped root (no docs/releases) → 0 EXEMPT
R10="$(new_repo s10)"
mkdir -p "$R10/bubbles/scripts" "$R10/agents"
run_guard --repo-root "$R10"
expect_rc 0 "S10 no docs/releases → EXEMPT"

# S11 — reconciled, annotation missing 'delivery' field → 1 (malformed)
R11="$(new_repo s11)"
mk_features "$R11" mvp true \
  "bubbles:feature id=broken spec=specs/079-broken"
mk_spec "$R11" specs/079-broken "done" plan design implement test validate
run_guard --repo-root "$R11" --phase mvp
expect_rc 1 "S11 malformed annotation (missing delivery field)"

# S12 — reconciled, required feature at delivered_prototype, FULLY validate-certified → 1
#       (assurance invariant: prototype tier is NEVER deployable, so it can never
#       satisfy a delivery=required feature — even validate-certified. This LOCKS the
#       explicit refusal so a future prototype-tier mode that declares delivered_prototype
#       terminal cannot silently reconcile a prototype as "delivered" — the deploy hole.)
R12="$(new_repo s12)"
mk_features "$R12" mvp true \
  "bubbles:feature id=proto-only spec=specs/080-proto delivery=required"
mk_spec "$R12" specs/080-proto "delivered_prototype" plan design implement test validate
run_guard --repo-root "$R12" --phase mvp
expect_rc 1 "S12 required feature delivered_prototype is refused (prototype never deployable)"

# ----------------------------------------------------------------------------
# Structural mode (G101 R2 split). Structural validates packet GRAMMAR without
# asserting that a bound spec is finished, so general framework validation can
# pass while planned delivery stays honestly red. S15/S16 are the adversarial
# half: if structural ever stopped enforcing grammar it would become the exact
# silent no-op this guard exists to refuse, and both cases would flip to 0.

# S13 — structural, required feature in_progress → 0 (delivery mode gives 1; cf. S3)
R13="$(new_repo s13)"
mk_features "$R13" mvp true \
  "bubbles:feature id=wip spec=specs/090-wip delivery=required"
mk_spec "$R13" specs/090-wip "in_progress" plan design
run_guard --repo-root "$R13" --phase mvp --mode structural
expect_rc 0 "S13 structural: in_progress required feature does not fail (delivery not asserted)"

# S14 — structural, required feature BLOCKED → 0 (delivery mode gives 1; cf. S9)
R14="$(new_repo s14)"
mk_features "$R14" mvp true \
  "bubbles:feature id=blocked-feat spec=specs/091-blocked delivery=required"
mk_spec_blocked "$R14" specs/091-blocked "operator-actionable credential rotation"
run_guard --repo-root "$R14" --phase mvp --mode structural
expect_rc 0 "S14 structural: blocked required feature does not fail (delivery not asserted)"

# S15 — ADVERSARIAL. structural MUST still refuse a malformed annotation (cf. S11).
R15="$(new_repo s15)"
mk_features "$R15" mvp true \
  "bubbles:feature id=broken spec=specs/092-broken"
mk_spec "$R15" specs/092-broken "done" plan design implement test validate
run_guard --repo-root "$R15" --phase mvp --mode structural
expect_rc 1 "S15 structural STILL refuses malformed annotation (teeth)"

# S16 — ADVERSARIAL. structural MUST still refuse a promised-but-unspecced feature (cf. S2).
R16="$(new_repo s16)"
mk_features "$R16" mvp true \
  "bubbles:feature id=ghost spec=specs/093-never-created delivery=required"
run_guard --repo-root "$R16" --phase mvp --mode structural
expect_rc 1 "S16 structural STILL refuses required feature with missing spec dir (teeth)"

# S17 — closed mode vocabulary; an unknown mode is a usage error, never a silent pass.
R17="$(new_repo s17)"
mk_features "$R17" mvp true \
  "bubbles:feature id=ok spec=specs/094-ok delivery=required"
mk_spec "$R17" specs/094-ok "done" plan design implement test validate
run_guard --repo-root "$R17" --phase mvp --mode bogus
expect_rc 2 "S17 unknown --mode is a usage error"

# ----------------------------------------------------------------------------
# assurance=implemented must rest on a mode that actually implements.
# These three cases are a set: S18 proves the refusal, S19 proves it is NOT a
# blanket ban on assurance, and S20 proves it is classified as delivery rather
# than grammar. Without S19 the check could be satisfied by refusing everything.

# S18 — planning-only terminal + assurance=implemented → 1
R18="$(new_repo s18)"
mk_features "$R18" mvp true \
  "bubbles:feature id=planned-only spec=specs/095-planning delivery=required assurance=implemented"
mk_spec_mode "$R18" specs/095-planning "specs_hardened" "spec-scope-hardening" plan design validate
run_guard --repo-root "$R18" --phase mvp
expect_rc 1 "S18 assurance=implemented over a planning-only terminal is refused"

# S19 — real delivered implementation carrying the same claim → 0
R19="$(new_repo s19)"
mk_features "$R19" mvp true \
  "bubbles:feature id=really-built spec=specs/096-built delivery=required assurance=implemented"
mk_spec "$R19" specs/096-built "done" plan design implement test validate
run_guard --repo-root "$R19" --phase mvp
expect_rc 0 "S19 assurance=implemented over a delivered implementation passes"

# S20 — the same planning-only packet is a DELIVERY finding, not a grammar one
R20="$(new_repo s20)"
mk_features "$R20" mvp true \
  "bubbles:feature id=planned-only spec=specs/097-planning delivery=required assurance=implemented"
mk_spec_mode "$R20" specs/097-planning "specs_hardened" "spec-scope-hardening" plan design validate
run_guard --repo-root "$R20" --phase mvp --mode structural
expect_rc 0 "S20 structural does not fail planning-only assurance (delivery concern)"

# ----------------------------------------------------------------------------
# An OPEN PREREQUISITE blocks the requested phase. Also a set: S21 proves the
# block, S22 proves it is not a blanket refusal of any phase that declares a
# dependsOn, and S23 proves it is a delivery assertion rather than grammar.

# S21 — later phase is asserted while its prerequisite is still open -> 1
R21="$(new_repo s21)"
mk_features "$R21" mvp true \
  "bubbles:feature id=foundation spec=specs/100-foundation delivery=required"
mk_spec "$R21" specs/100-foundation "in_progress" plan design
mk_features_dep "$R21" voyager mvp \
  "bubbles:feature id=later spec=specs/101-later delivery=required"
mk_spec "$R21" specs/101-later "done" plan design implement test validate
run_guard --repo-root "$R21" --phase voyager
expect_rc 1 "S21 open MVP prerequisite blocks a later phase"

# S22 — same shape, prerequisite actually delivered -> 0
R22="$(new_repo s22)"
mk_features "$R22" mvp true \
  "bubbles:feature id=foundation spec=specs/100-foundation delivery=required"
mk_spec "$R22" specs/100-foundation "done" plan design implement test validate
mk_features_dep "$R22" voyager mvp \
  "bubbles:feature id=later spec=specs/101-later delivery=required"
mk_spec "$R22" specs/101-later "done" plan design implement test validate
run_guard --repo-root "$R22" --phase voyager
expect_rc 0 "S22 delivered prerequisite does not block the later phase"

# S23 — the prerequisite check is a delivery assertion, not grammar -> 0
R23="$(new_repo s23)"
mk_features "$R23" mvp true \
  "bubbles:feature id=foundation spec=specs/100-foundation delivery=required"
mk_spec "$R23" specs/100-foundation "in_progress" plan design
mk_features_dep "$R23" voyager mvp \
  "bubbles:feature id=later spec=specs/101-later delivery=required"
mk_spec "$R23" specs/101-later "done" plan design implement test validate
run_guard --repo-root "$R23" --phase voyager --mode structural
expect_rc 0 "S23 structural does not apply the prerequisite block"

# ----------------------------------------------------------------------------
echo ""
echo "release-delivery-reconciliation-guard selftest: $PASS_COUNT passed, $FAIL_COUNT failed"
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  printf '  - %s\n' "${FAILED[@]}" >&2
  exit 1
fi
exit 0
