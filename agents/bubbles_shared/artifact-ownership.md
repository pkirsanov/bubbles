# Artifact Ownership

Artifact authorship is a hard boundary, not a suggestion. Violations are blocking — the ownership lint (`agent-ownership-lint.sh`) and state-transition guard enforce these rules mechanically.

## Canonical Ownership

| Artifact | Owner | Notes |
|----------|-------|-------|
| `spec.md` business requirements, actors, use cases, scenarios | `bubbles.analyst` | `bubbles.ux` may update only UX sections of `spec.md` |
| `design.md` | `bubbles.design` | Technical design only |
| `scopes.md` / `scopes/*/scope.md` planning content | `bubbles.plan` | Gherkin, Test Plan, DoD, execution structure |
| `report.md` template structure | `bubbles.plan` | Execution evidence is appended by execution agents |
| `report.md` evidence content | `bubbles.implement`, `bubbles.test`, `bubbles.validate`, `bubbles.audit`, `bubbles.chaos`, `bubbles.harden`, `bubbles.gaps`, `bubbles.stabilize`, `bubbles.security`, `bubbles.regression` | Append-only to their own sections |
| `uservalidation.md` | `bubbles.plan` | Acceptance checklist/template |
| `bug.md` | `bubbles.bug` | Bug description, reproduction, severity |
| `state.json` certification state | `bubbles.validate` | `certification.*`, promotion state, and reopen/invalidate certification only |
| `state.json` execution claims | All execution agents | `execution.*` fields only — never `certification.*` |
| `scenario-manifest.json` | `bubbles.plan` | `bubbles.test`, `bubbles.validate`, `bubbles.regression` may update evidence links only |
| Product code / tests | `bubbles.implement`, `bubbles.test` | Per their phase ownership |
| Standard docs (`docs/`) | `bubbles.docs` | Must reflect real implementation state |

## Read-Only Diagnostic And Certification Agents

`bubbles.validate`, `bubbles.audit`, `bubbles.harden`, `bubbles.gaps`, `bubbles.stabilize`, `bubbles.security`, `bubbles.code-review`, `bubbles.system-review`, `bubbles.regression`, and `bubbles.clarify` are diagnostic or certification agents. They MAY identify missing scenarios, tests, contracts, or DoD items, but they MUST NOT directly author foreign-owned planning, execution, or certification surfaces.

## Foreign-Artifact Rule (NON-NEGOTIABLE)

If an agent discovers that a foreign-owned artifact must change:

1. It MUST NOT edit that artifact itself — not even "small fixes" or "obvious corrections".
2. It MUST emit a concrete `route_required` result envelope or invoke the owning agent via `runSubagent`, never a narrative-only handoff or "suggested next step".
3. If invoked by `bubbles.workflow`, `bubbles.iterate`, or another orchestrator, it MUST return the route-required packet so the orchestrator can invoke the owner immediately.
4. If invoked standalone, it may explicitly delegate to the owner via `runSubagent`, or it must stop with a concrete owner-targeted route result; it still MUST NOT perform foreign-owned remediation inline.
5. The phase MUST NOT be reported complete until the owning specialist has run and the result has been verified.

Owning one planning artifact does NOT grant permission to mutate sibling planning artifacts. Example: `bubbles.analyst` owns business requirements in `spec.md`, but `design.md` still belongs exclusively to `bubbles.design` and `scopes.md` still belongs exclusively to `bubbles.plan`.

**Examples of violations:**
- `bubbles.harden` adding new Gherkin scenarios to `scopes.md` → must invoke `bubbles.plan`
- `bubbles.implement` creating `uservalidation.md` → must invoke `bubbles.plan`
- `bubbles.gaps` updating DoD items in `scopes.md` → must invoke `bubbles.plan`
- `bubbles.test` modifying `spec.md` requirements → must invoke `bubbles.analyst`
- `bubbles.docs` changing `design.md` architecture → must invoke `bubbles.design`
- `bubbles.analyst` updating `design.md` after a review or analysis run → must invoke `bubbles.design` or return a route-required packet
- Any agent writing `certification.*` fields in `state.json` → must route to `bubbles.validate`

## Execution-Only Exception

`bubbles.implement` may update `scopes.md` only for execution-progress concerns already defined by planning artifacts: inline evidence, DoD checkbox completion, and scope progress tied to completed work. It MUST NOT invent new Gherkin scenarios, Test Plan rows, or DoD structures that belong to `bubbles.plan`.

## Enforcement

The ownership contract is enforced at three levels:

1. **Prompt-level** — each agent declares an explicit `**Artifact Ownership**` block listing what it owns and what is foreign. This declaration is cross-checked against `agent-ownership.yaml`.
2. **Lint-level** — `agent-ownership-lint.sh` verifies that diagnostic agents do not contain language permitting foreign-artifact edits, and that every agent's declared ownership matches the YAML registry.
3. **Guard-level** — `state-transition-guard.sh` verifies artifact authorship coherence before allowing `done` transitions (Gate G062).

## Related Modules

- [evidence-rules.md](evidence-rules.md) — evidence attribution is an ownership rule (agents may only write evidence for their own phase)
- [completion-governance.md](completion-governance.md) — the completion chain that artifact ownership supports
- [state-gates.md](state-gates.md) — mechanical gate definitions including G062 (owner-only remediation) and G066 (phase-claim provenance)