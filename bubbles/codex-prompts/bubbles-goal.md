---
description: Run the Bubbles goal orchestrator
argument-hint: OUTCOME
---

Spawn the `bubbles_goal` custom agent as lead orchestrator for:

$ARGUMENTS

Have it choose the relevant Bubbles workflow and delegate independent work to
`bubbles_plan`, `bubbles_implement`, `bubbles_validate`, `bubbles_audit`, and
`bubbles_review` where relevant. Collect results, resolve material findings,
run verification, and return evidence.
