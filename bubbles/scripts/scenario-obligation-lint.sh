#!/usr/bin/env bash
set -euo pipefail

# scenario-obligation-lint.sh
#
# IMP-040 SCOPE-3 / COV-9 — keep the obligation matrix derived, not enumerated.
#
# WHY THIS EXISTS
# Scenario coverage was row-based: a scenario could carry a unit row while its
# user-visible path had no live-system test at all. The obligation matrix fixes
# that by deriving required proof from the scenario's BEHAVIOR TRAITS.
#
# A derived matrix has one characteristic failure mode, and the proposal names
# it directly: attaching every category to every scenario. That is not a safe
# default. An obligation set that never varies carries no information about the
# scenario it is attached to, and it trains a reviewer to skim a block that is
# always identical — which is how row-based coverage failed in the first place.
#
# WHAT IT CHECKS
#   A. TRAIT-COVERED     — every declared trait owes at least one obligation.
#   B. OBLIGATION-ANCHORED — every obligation names a trait the scenario declared.
#   C. NOT-ENUMERATED    — no scenario declares the ENTIRE trait vocabulary.
#
# Check C is deliberately narrow. It fires only on the maximal set, which is
# unambiguous: a scenario that is simultaneously pure calculation, user-visible
# UI, an API contract, mutable state, degraded state, a shared consumer, a
# dependency path, responsive/accessible AND SLA-sensitive is a feature, not a
# scenario. A judgement-based threshold ("too many traits") would reject
# legitimate multi-trait scenarios, and a gate that rejects correct work gets
# switched off.
#
# SAFE TO BLOCK ON DAY ONE, unlike the linked-test resolver: these fields are
# new and optional, so the lint is inert on every packet that does not declare
# them. It cannot retro-break an existing manifest.
#
# Exit codes:
#   0  clean, or nothing declared
#   1  finding
#   2  usage error / unparseable manifest

SPEC_DIR=""
QUIET=0

die_usage() {
  printf 'scenario-obligation-lint: %s\n' "$1" >&2
  printf 'usage: scenario-obligation-lint.sh <specDir> [--quiet]\n' >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --quiet) QUIET=1 ;;
    -h|--help) sed -n '4,38p' "${BASH_SOURCE[0]}"; exit 0 ;;
    --skip*|--force*|--ignore*|--no-verify*)
      die_usage "bypass-shaped flag '$1' is not supported; derive the matrix instead" ;;
    -*) die_usage "unknown option '$1'" ;;
    *) [[ -z "$SPEC_DIR" ]] || die_usage "unexpected argument '$1'"; SPEC_DIR="$1" ;;
  esac
  shift
done

[[ -n "$SPEC_DIR" ]] || die_usage "a spec directory is required"
[[ -d "$SPEC_DIR" ]] || die_usage "spec directory not found: $SPEC_DIR"

MANIFEST="$SPEC_DIR/scenario-manifest.json"
if [[ ! -f "$MANIFEST" ]]; then
  [[ "$QUIET" -eq 1 ]] || printf '[scenario-obligation-lint] NA — no scenario-manifest.json\n'
  exit 0
fi

command -v python3 >/dev/null 2>&1 || die_usage "python3 is required"

MANIFEST="$MANIFEST" QUIET="$QUIET" python3 - <<'PY'
import json, os, sys

manifest_path = os.environ["MANIFEST"]
quiet = os.environ.get("QUIET") == "1"

try:
    with open(manifest_path, encoding="utf-8") as fh:
        manifest = json.load(fh)
except (OSError, ValueError) as exc:
    print(f"scenario-obligation-lint: cannot parse {manifest_path}: {exc}", file=sys.stderr)
    sys.exit(2)

VOCABULARY = {
    "pure-calculation", "user-visible-ui", "api-contract", "mutable-state",
    "degraded-state", "shared-consumer", "dependency-path",
    "responsive-accessible", "sla-sensitive",
}

findings = []
declared = 0

scenarios = manifest.get("scenarios")
if not isinstance(scenarios, list):
    scenarios = []

for scenario in scenarios:
    if not isinstance(scenario, dict):
        continue
    sid = scenario.get("id") or scenario.get("scenarioId") or "<unidentified-scenario>"
    traits = scenario.get("behaviorTraits")
    obligations = scenario.get("obligations")

    if not isinstance(traits, list) or not traits:
        # Nothing declared: the lint is inert rather than demanding the new
        # fields from packets written before they existed.
        if isinstance(obligations, list) and obligations:
            findings.append((sid, "OBLIGATION-ANCHORED",
                             "obligations are declared but behaviorTraits is empty; "
                             "an obligation must name the trait that implies it"))
        continue

    declared += 1
    trait_set = {t for t in traits if isinstance(t, str)}

    unknown = sorted(trait_set - VOCABULARY)
    if unknown:
        findings.append((sid, "UNKNOWN-TRAIT",
                         f"not in the obligation vocabulary: {', '.join(unknown)}"))

    if trait_set >= VOCABULARY:
        findings.append((sid, "NOT-ENUMERATED",
                         "declares the ENTIRE trait vocabulary. The matrix is derived "
                         "per scenario from the traits it actually has; a set that never "
                         "varies carries no information about the scenario"))

    obligation_traits = set()
    if isinstance(obligations, list):
        for ob in obligations:
            if not isinstance(ob, dict):
                continue
            trait = ob.get("trait")
            proof = ob.get("requiredProof")
            if not isinstance(trait, str) or not trait:
                findings.append((sid, "OBLIGATION-ANCHORED", "an obligation declares no trait"))
                continue
            obligation_traits.add(trait)
            if not isinstance(proof, str) or not proof.strip():
                findings.append((sid, "TRAIT-COVERED",
                                 f"obligation for '{trait}' states no requiredProof"))
            if trait not in trait_set:
                findings.append((sid, "OBLIGATION-ANCHORED",
                                 f"obligation names trait '{trait}' which the scenario does not declare"))

    uncovered = sorted(trait_set - obligation_traits)
    if uncovered:
        findings.append((sid, "TRAIT-COVERED",
                         f"declared trait(s) with no obligation: {', '.join(uncovered)}"))

if findings:
    print("scenario-obligation-lint: FAIL — obligation matrix is not coherent (COV-9)", file=sys.stderr)
    for sid, code, detail in findings:
        print(f"  {code}: {sid}", file=sys.stderr)
        print(f"    {detail}", file=sys.stderr)
    print("", file=sys.stderr)
    print(f"scenario-obligation-lint: {len(findings)} finding(s).", file=sys.stderr)
    sys.exit(1)

if not quiet:
    if declared:
        print(f"[scenario-obligation-lint] OK — {declared} scenario(s) with a coherent derived obligation matrix")
    else:
        print("[scenario-obligation-lint] OK — no behaviorTraits declared (inert)")
sys.exit(0)
PY
