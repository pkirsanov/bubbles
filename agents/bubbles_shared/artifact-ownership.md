# Artifact Ownership

Artifact authorship is a hard boundary, not a suggestion.

## Canonical Ownership

| Artifact | Owner | Notes |
|----------|-------|-------|
| `spec.md` business requirements, actors, use cases, scenarios | `bubbles.analyst` | `bubbles.ux` may update only UX sections of `spec.md` |
| `design.md` | `bubbles.design` | Technical design only |
| `scopes.md` / `scopes/*/scope.md` planning content | `bubbles.plan` | Gherkin, Test Plan, DoD, execution structure |
| `report.md` template structure | `bubbles.plan` | Execution evidence is appended later by execution agents |
| `uservalidation.md` | `bubbles.plan` | Acceptance checklist/template |
| Product code / tests / runtime docs | `bubbles.implement`, `bubbles.test`, `bubbles.docs` | Per their phase ownership |

## Read-Only Diagnostic Agents

`bubbles.validate`, `bubbles.harden`, `bubbles.gaps`, `bubbles.stabilize`, `bubbles.security`, and `bubbles.review` are diagnostic and routing agents. They MAY identify missing scenarios, tests, contracts, or DoD items, but they MUST NOT directly author `spec.md`, `design.md`, `scopes.md`, or `uservalidation.md`.

## Foreign-Artifact Rule

If an agent discovers that a foreign-owned artifact must change:

1. It MUST NOT edit that artifact itself.
2. If invoked directly, it MUST invoke the owning specialist via `runSubagent` and wait for completion before continuing.
3. If invoked by `bubbles.workflow` or `bubbles.iterate`, it MUST return a route-required result so the orchestrator can invoke the owner immediately.
4. The phase MUST NOT be reported complete until the owning specialist has run and the result has been verified.

## Execution-Only Exception

`bubbles.implement` may update `scopes.md` only for execution-progress concerns already defined by planning artifacts: inline evidence, DoD checkbox completion, and scope progress tied to completed work. It MUST NOT invent new Gherkin scenarios, Test Plan rows, or DoD structures that belong to `bubbles.plan`.