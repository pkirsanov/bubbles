# Evidence Rules

Purpose: canonical source for execution evidence and anti-fabrication requirements.

## Rules
- Pass/fail claims require actual command execution.
- Evidence must be raw terminal output, not narrative summaries.
- Required test or validation evidence must contain enough raw output to show real execution signals.
- Evidence blocks must map to actual tool executions from the current session.
- Fabricated, copied, or template evidence blocks invalidate completion claims.
- Evidence sections must not contain unresolved continuation or follow-up language (`Next Steps`, `Recommended routing`, `Re-run /bubbles.*`, `Commit the fix`, `Record DoD evidence`, `Run full E2E suite`). If any of these phrases appear outside quoted historical evidence, the evidence section is incomplete.
- All state-modifying and diagnostic agents must conclude with a structured `## RESULT-ENVELOPE` outcome (`completed_owned`, `completed_diagnostic`, `route_required`, or `blocked`). Narrative-only conclusions without a structured envelope are equivalent to fabrication for completion-tracking purposes.
