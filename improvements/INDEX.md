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
| [IMP-006](IMP-006-bubbles-journey-full-stack-tutorial.md) | `bubbles.journey` full-stack tutorial | 6 | J1, J2, J3 | Harden the journey agent contract: four-layer per-step verification (UI + API + telemetry + data), tutorial posture + replayable walkthrough, dev/validate-drive vs operate/prod-read-only plane governance (INV-12), internal verdict + Hidden Defects routing. Agent-contract applied; workflow wiring deferred; composes with (does not require) IMP-001 SCOPE-2/3/5. |
| [IMP-017](IMP-017-template-case-collision-fix.md) | Template case-collision fix + prevention guard | — | C1, C2, C3 | Removes the case-colliding duplicate registry template (`templates/AGENTS.md.tmpl` vs `templates/agents.md.tmpl`, same blob `7874afaf…`), fixes `install.sh` (drops the buggy root-`AGENTS.md` scaffold that generated the wrong content from the colliding name + the two "Created AGENTS.md" claims), and adds `bubbles/scripts/case-collision-guard.sh` (+ hermetic selftest, both wired into `framework-validate.sh`) so the bug class cannot recur. SCOPE-1–3 applied; a correct starter-`AGENTS.md` scaffold is deferred. |
| [IMP-018](IMP-018-macos-portability-guard.md) | Reusable macOS/WSL portability guard + selftest | — | MP1, MP2, MP3 | Adds `bubbles/scripts/macos-portability-guard.sh` (+ hermetic selftest wired into `framework-validate.sh`) — a reusable, portable-by-design, caller-supplied-surface lint mechanizing the 13-class `bubbles-cross-platform-shell` pitfall table (helper-aware + `# portable-ok:` pragma; NO default surface, never scans the framework's own scripts). SCOPE-1–4 applied. |
| [IMP-019](IMP-019-direct-authorized-workflow-runners.md) | Direct authorized workflow runners | — | WRA1, WRA2, WRA3, WRA4 | Makes `bubbles.goal` the universal outcome endpoint, narrows `bubbles.workflow` to one mode, keeps sprint as a timed goal queue, grants domain orchestrators only their own modes, and mechanically forbids nested workflow runners through G064. Applied in v7.19.0; downstream doctor hardening shipped in v7.19.1-v7.19.2. |

## Recommended implementation order

IMP-001 → IMP-002 → IMP-003 → IMP-004 → IMP-005. IMP-001 and IMP-002 are the highest-value capability additions; IMP-003 is the autonomy/safety hardening; IMP-004 and IMP-005 are refinement + housekeeping. IMP-005 SCOPE-1 (INVENTORY reconciliation) is sequenced AFTER the in-flight isolation-doctrine skills branch lands.

## Net assessment

The framework's process integrity (anti-fabrication, gates, ownership, compaction, evidence provenance) is sound — the audit found no dead gate/mode references and no broken state guards on the `done` path. These proposals address capabilities at the human/safety edges, not structural bugs.

## Gap-code legend

- **P1** no readiness synthesizer · **P2** audit verdict not persisted · **P3** no voice-of-user-from-live-product path · **P4** fuzzy verification boundaries · **P5** unowned verification concerns (a11y/i18n, migration, longitudinal perf)
- **A1** no session/cost cap · **A2** no run-level rollback/dry-run · **A3** parallel-scope shared-state contract · **A4** no single autonomy level
- **S1** INVENTORY drift · **S2** Skills-First-Pointers coverage · **S3** learning-loop cold-start + user-blindness
- **D1** no consolidated review mode · **D2** ops prompt-shim parity · **D3** improvements/ surface
- **J1** journey internal-correctness blind spot (UI-only verify) · **J2** no journey tutorial posture · **J3** journey dev/validate-vs-operate plane ambiguity
- **C1** case-colliding duplicate registry template · **C2** `install.sh` scaffolded root `AGENTS.md` from the wrong (colliding) template · **C3** no case-collision prevention guard  _(IMP-017 — a separately-discovered cross-platform bootstrap bug fix, NOT part of the 2026-07 audit. `improvements/` jumps 006 → 017 because the delivered IMP-007..016 docs were deleted-on-delivery per the improvements-doc lifecycle; IMP-017 is the next free number in the monotonic IMP sequence, and IMP-007 is permanently assigned to `regen-derived.sh`.)_
- **MP1** no reusable framework portability guard (only a product-local 4-class check) · **MP2** the 13-class GNU/BSD pitfall table unenforced mechanically (shellcheck does not model BSD/GNU runtime divergence) · **MP3** no framework-validate selftest locking the portability contract  _(IMP-018 — a separately-discovered framework-tooling addition, NOT part of the 2026-07 audit; the next free number after IMP-017.)_
- **WRA1** goal/workflow responsibility overlap · **WRA2** runner-to-runner subagent deadlock · **WRA3** no per-agent mode grants · **WRA4** public docs named workflow rather than goal as the universal endpoint  _(IMP-019 — owner-approved architecture correction on 2026-07-09.)_
