# Framework Improvement Proposals (IMP)

This directory holds human-reviewable framework-improvement proposals per the `framework-health` mode (Gate **G125**). Proposals are **PROPOSED** until the repository owner approves them; per G125 they do **NOT** auto-mutate `bubbles/*` — implementation of an approved IMP flows through the named agents/gates in each proposal's "Files to touch" section.

## Provenance

Authored from a 4-pass agent-ecosystem audit (2026-07) of the Bubbles framework covering: agent usefulness/wiring, verification-surface overlap, the user-feedback/learning loop, state-machine completeness, the skills ecosystem, and autonomy/safety controls. Every finding was verified against source (subagent line-citations were discarded and re-checked).

## Proposals

| IMP | Title | Priority | Verified gaps | Summary |
|-----|-------|----------|---------------|---------|
| [IMP-001](IMP-001-bubbles-journey-agent.md) | `bubbles.journey` | 1 (highest) | P3, S3 | New guided post-implementation journey / scenario-refinement agent — the missing voice-of-user-from-the-live-product surface. |
| [IMP-002](IMP-002-readiness-review-mode.md) | `readiness-review` mode | 2 | P1, P2, D1 | System-level release-readiness synthesizer; gives `system-review` a first-class home; persists a validate-owned readiness verdict. |
| [IMP-003](IMP-003-autonomy-dial-and-safety-caps.md) | Autonomy dial + safety caps | 3 | A1, A2, A4 + grill/clarify | Single `autonomy:` level, session budget caps, dry-run/rollback, activates dormant grill + conditional clarify. |
| [IMP-004](IMP-004-verification-boundaries-and-coverage-gaps.md) | Verification boundaries + coverage gaps | 4 | P4, A3, P5 | Tighten fuzzy agent boundaries; document parallel-scope isolation; name owners for a11y/i18n, migration/backward-compat, longitudinal perf. |
| [IMP-005](IMP-005-framework-housekeeping.md) | Framework housekeeping | 5 | S1, S2, S3, D2, D3 | INVENTORY sync, Skills-First-Pointers standard, learning-loop seed, ops prompt-shims, improvements/ surface. |

## Recommended implementation order

IMP-001 → IMP-002 → IMP-003 → IMP-004 → IMP-005. IMP-001 and IMP-002 are the highest-value capability additions; IMP-003 is the autonomy/safety hardening; IMP-004 and IMP-005 are refinement + housekeeping. IMP-005 SCOPE-1 (INVENTORY reconciliation) is sequenced AFTER the in-flight isolation-doctrine skills branch lands.

## Net assessment

The framework's process integrity (anti-fabrication, gates, ownership, compaction, evidence provenance) is sound — the audit found no dead gate/mode references and no broken state guards on the `done` path. These proposals address capabilities at the human/safety edges, not structural bugs.

## Gap-code legend

- **P1** no readiness synthesizer · **P2** audit verdict not persisted · **P3** no voice-of-user-from-live-product path · **P4** fuzzy verification boundaries · **P5** unowned verification concerns (a11y/i18n, migration, longitudinal perf)
- **A1** no session/cost cap · **A2** no run-level rollback/dry-run · **A3** parallel-scope shared-state contract · **A4** no single autonomy level
- **S1** INVENTORY drift · **S2** Skills-First-Pointers coverage · **S3** learning-loop cold-start + user-blindness
- **D1** no consolidated review mode · **D2** ops prompt-shim parity · **D3** improvements/ surface
