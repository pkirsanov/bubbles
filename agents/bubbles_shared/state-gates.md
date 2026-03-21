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
- Never inflate `completedScopes`, `completedPhases`, or final status beyond artifact reality.
- Do not batch-complete DoD items.
- Do not bypass gates by reformatting DoD or status fields.

## Mechanical Gates
- `state-transition-guard.sh`
- `artifact-lint.sh`
- `implementation-reality-scan.sh`
