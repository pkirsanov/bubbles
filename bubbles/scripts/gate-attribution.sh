#!/usr/bin/env bash
# Gate attribution across an agent's effective closure (IMP-028 SCOPE-2).
#
# R3 blocks closure reduction until a held-out eval shows zero gate-detection
# regression. On hardware where the closure exceeds the model context, that eval
# cannot see the whole bundle (measured: 114,476 tokens vs a 32,768 window), so a
# whole-bundle verdict is not obtainable.
#
# This answers the decidable part DETERMINISTICALLY instead: which modules are the
# SOLE carrier of a gate reference. Removing such a module orphans that gate — the
# text disappears from the closure entirely — which is the concrete failure R3
# guards against, and it needs no model at all.
#
# SCOPE AND LIMITS, stated plainly:
#   - This counts gate-id REFERENCES, not semantic definitions. A module that only
#     mentions a gate in passing still counts as a carrier.
#   - Zero sole-gates means removal orphans NO gate id. It does NOT prove routing
#     is unaffected; cross-module context can still matter. It narrows candidates,
#     it does not certify them.
#   - A module carrying sole gates is a hard NO for removal. That direction IS
#     conclusive: the reference would simply be gone.
#
# Usage: gate-attribution.sh <agent.md> [--json]

set -euo pipefail

AGENT="${1:-}"
FORMAT="${2:-text}"

if [[ -z "$AGENT" || "$AGENT" == "-h" || "$AGENT" == "--help" ]]; then
  cat >&2 <<'EOF'
gate-attribution.sh — which closure modules solely carry a gate reference
Usage: gate-attribution.sh <path/to/agent.md> [--json]
EOF
  exit 0
fi

[[ -r "$AGENT" ]] || { echo "gate-attribution: cannot read $AGENT" >&2; exit 1; }

BUBBLES_GA_AGENT="$AGENT" BUBBLES_GA_FORMAT="$FORMAT" python3 - <<'PY'
import collections, json, os, re, sys

agent = os.path.abspath(os.environ["BUBBLES_GA_AGENT"])
as_json = os.environ["BUBBLES_GA_FORMAT"] == "--json"
shared = os.path.join(os.path.dirname(agent), "bubbles_shared")

seen, queue, mods = set(), [agent], {}
while queue:
    path = queue.pop(0)
    if path in seen or not os.path.isfile(path):
        continue
    seen.add(path)
    body = open(path, encoding="utf-8", errors="replace").read()
    mods[os.path.basename(path)] = (len(body), set(re.findall(r"\bG\d{3}\b", body)))
    for name in re.findall(r"bubbles_shared/([A-Za-z0-9._-]+)\.md", body):
        queue.append(os.path.join(shared, name + ".md"))

carriers = collections.defaultdict(set)
for name, (_, gates) in mods.items():
    for gate in gates:
        carriers[gate].add(name)

sole = {g: next(iter(m)) for g, m in carriers.items() if len(m) == 1}
owner = collections.Counter(sole.values())
root = os.path.basename(agent)

blocked = sorted(
    ((mods[m][0], m, c) for m, c in owner.items() if m != root), reverse=True
)
candidates = sorted(
    ((b, m) for m, (b, _) in mods.items() if m not in owner and m != root), reverse=True
)

if as_json:
    print(json.dumps({
        "agent": root,
        "modules": len(mods),
        "gatesReferenced": len(carriers),
        "soleCarriedGates": len(sole),
        "blockedModules": [{"module": m, "bytes": b, "soleGates": c} for b, m, c in blocked],
        "candidateModules": [{"module": m, "bytes": b} for b, m in candidates],
        "candidateBytes": sum(b for b, _ in candidates),
    }, indent=2, sort_keys=True))
    sys.exit(0)

print(f"agent                : {root}")
print(f"closure modules      : {len(mods)}")
print(f"gate ids referenced  : {len(carriers)}")
print(f"sole-carried gates   : {len(sole)}")
print()
print("NOT REMOVABLE — sole carrier of a gate reference:")
for b, m, c in blocked:
    print(f"  {b:7d}B  {c:3d} sole-gate(s)  {m}")
print()
print(f"CANDIDATES — carry no sole gate ({len(candidates)} modules, {sum(b for b,_ in candidates)} bytes):")
for b, m in candidates:
    print(f"  {b:7d}B  {m}")
print()
print("Candidates are NARROWED, not certified: zero sole-gates proves no gate id is")
print("orphaned, not that routing is unchanged. Confirm each with the routing eval.")
PY
