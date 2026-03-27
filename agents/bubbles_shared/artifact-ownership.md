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
| `state.json` certification state | `bubbles.validate` | `certification.*`, promotion state, and reopen/invalidate certification only |
| Product code / tests / runtime docs | `bubbles.implement`, `bubbles.test`, `bubbles.docs` | Per their phase ownership |

## Read-Only Diagnostic And Certification Agents

`bubbles.validate`, `bubbles.audit`, `bubbles.harden`, `bubbles.gaps`, `bubbles.stabilize`, `bubbles.security`, `bubbles.code-review`, `bubbles.system-review`, `bubbles.regression`, and `bubbles.clarify` are diagnostic or certification agents. They MAY identify missing scenarios, tests, contracts, or DoD items, but they MUST NOT directly author foreign-owned planning, execution, or certification surfaces.

## Foreign-Artifact Rule

If an agent discovers that a foreign-owned artifact must change:

1. It MUST NOT edit that artifact itself.
2. It MUST emit a concrete `route_required` result envelope or explicit owner-targeted delegation, never a narrative-only handoff.
3. If invoked by `bubbles.workflow`, `bubbles.iterate`, or another orchestrator, it MUST return the route-required packet so the orchestrator can invoke the owner immediately.
4. If invoked standalone, it may explicitly delegate to the owner, or it must stop with a concrete owner-targeted route result; it still MUST NOT perform foreign-owned remediation inline.
5. The phase MUST NOT be reported complete until the owning specialist has run and the result has been verified.

## Execution-Only Exception

`bubbles.implement` may update `scopes.md` only for execution-progress concerns already defined by planning artifacts: inline evidence, DoD checkbox completion, and scope progress tied to completed work. It MUST NOT invent new Gherkin scenarios, Test Plan rows, or DoD structures that belong to `bubbles.plan`.