# State Gates

Purpose: compact state/completion rules that must remain authoritative for all agents.

## Completion Chain
- A DoD item becomes `[x]` only after real validation evidence exists inline.
- A scope becomes `Done` only when every DoD item is valid.
- A spec becomes `done` only when every scope is `Done`.

## Read / Loop Discipline
- Max 3 consecutive reads before action.
- Max 3 docs per tier before action.
- No redundant rereads without a new reason.
- A reread is allowed when the file changed, the active phase changed, or a newly triggered gate requires re-checking it.
- No hunt loops for missing files.

## State Integrity
- Never inflate `certification.completedScopes`, `execution.completedPhaseClaims`, `certification.certifiedCompletedPhases`, or final status beyond artifact reality.
- Do not batch-complete DoD items.
- Do not bypass gates by reformatting DoD or status fields.
- Only `bubbles.validate` may write `certification.*` fields (Gate G056).
- `policySnapshot` must record effective mode settings with provenance (Gate G055).
- `transitionRequests` and `reworkQueue` must be empty before certification (Gate G061).
- Diagnostic and certification agents must route foreign-owned remediation instead of fixing inline (Gate G062).
- Agent and child-workflow invocations must end with a concrete result outcome, not narrative-only findings (Gate G063).
- Only orchestrators may invoke child workflows, and nesting depth must remain bounded (Gate G064).

## Mechanical Gates
- `state-transition-guard.sh` — DoD, scope status, certification/execution coherence, policy provenance (G055), certification state (G056), scenario manifest (G057), lockdown/regression (G058/G059), TDD evidence (G060), transition/rework closure (G061), packet/result integrity and framework contract enforcement (G062/G063/G064)
- `artifact-lint.sh` — schema validation (v2 + v3), phase coherence, scope parity, specialist completion
- `implementation-reality-scan.sh` — stub/fake/hardcoded data detection
- `artifact-freshness-guard.sh` — superseded content isolation (G052)
- `traceability-guard.sh` — Gherkin-to-test-to-evidence linkage, scenario manifest cross-check (G057/G059)
- `agent-ownership-lint.sh` — ownership/capability registry validation plus owner-only remediation, result-envelope, and child-workflow policy checks (G054/G062/G063/G064)
