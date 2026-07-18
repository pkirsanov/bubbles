# Framework Improvement Proposals (IMP)

This directory holds human-reviewable framework-improvement proposals per the `framework-health` mode (Gate **G125**). Proposals are **PROPOSED** until the repository owner approves them; per G125 they do **NOT** auto-mutate `bubbles/*` — implementation of an approved IMP flows through the named agents/gates in each proposal's "Files to touch" section.

## Provenance

Authored from a 4-pass agent-ecosystem audit (2026-07) of the Bubbles framework covering: agent usefulness/wiring, verification-surface overlap, the user-feedback/learning loop, state-machine completeness, the skills ecosystem, and autonomy/safety controls. Every finding was verified against source (subagent line-citations were discarded and re-checked).

IMP-021..025 are a second batch, authored from **multi-session convergence observations (2026-07, Research Lab Feature 010)** — a real long-running session in which a build-free static tool was driven through the maximum-assurance chain, concurrent writers collided in one worktree, a report grew past 2,000 lines, and a session edited one repository using another root's agent. They address delivery-weight ergonomics, concurrency safety, evidence bounds, and multi-root binding. They are PROPOSED (proposal-first per G125); none has been implemented.

## Proposals

| IMP | Title | Priority | Verified gaps | Summary |
|-----|-------|----------|---------------|---------|
| [IMP-001](IMP-001-bubbles-journey-agent.md) | `bubbles.journey` | 1 (highest) | P3, S3 | New guided post-implementation journey / scenario-refinement agent — the missing voice-of-user-from-the-live-product surface. |
| [IMP-002](IMP-002-readiness-review-mode.md) | `readiness-review` mode | 2 | P1, P2, D1 | System-level release-readiness synthesizer; gives `system-review` a first-class home; persists a validate-owned readiness verdict. |
| [IMP-003](IMP-003-autonomy-dial-and-safety-caps.md) | Autonomy dial + safety caps | 3 | A1, A2, A4 + grill/clarify | Single `autonomy:` level, session budget caps, dry-run/rollback, activates dormant grill + conditional clarify. |
| [IMP-004](IMP-004-verification-boundaries-and-coverage-gaps.md) | Verification boundaries + coverage gaps | 4 | P4, A3, P5 | Tighten fuzzy agent boundaries; document parallel-scope isolation; name owners for a11y/i18n, migration/backward-compat, longitudinal perf. |
| [IMP-005](IMP-005-framework-housekeeping.md) | Framework housekeeping | 5 | S1, S2, S3, D2, D3 | INVENTORY sync, Skills-First-Pointers standard, learning-loop seed, ops prompt-shims, improvements/ surface. |
| [IMP-020](IMP-020-agentic-evaluation-and-trust-hardening.md) | Agentic evaluation and trust hardening | Owner-approved | AF-001–AF-006, FIN-001 | APPROVED FOR IMPLEMENTATION on 2026-07-10. Seven independently landable scopes make eval fail closed and substantive, replace fake validator independence with provenance-labeled samples, add honest content/tool trust boundaries, compile the effective prompt/tool bundle, benchmark simple/focused/full workflows on held-out executable tasks, add a product-agnostic forecast-eval profile, and reconcile/release all public and generated surfaces. |
| [IMP-021](IMP-021-risk-tiered-rapid-tool-delivery.md) | Risk-tiered rapid tool-delivery mode | — | RTD1, RTD2, RTD3 | New `rapid-tool-delivery` mode gated by a mechanical low-risk resolver: short `select→implement→test→validate→docs→finalize` chain, non-null G128 budgets (reuses the shipped gate, no competing gate), a vertical-slice planning envelope, and deterministic risk-tiered routing. Preserves every universal integrity gate; `full-delivery` stays the default. Composes with IMP-022. |
| [IMP-022](IMP-022-mechanical-vertical-delivery-plan-guard.md) | Mechanical vertical-delivery plan guard | — | VDP1–VDP4 | New `bubbles.plan` gate enforcing time-to-first-usable-outcome, a risk-adjusted scope budget (≤3 increments / ≤5 active scopes for low-risk), horizontal-sequence detection, consumer-timing, and scenario-ID/DoD conservation, with actionable remediation + a Feature-010-shaped 14-scope negative fixture. Advisory-until-configured. Composes with IMP-021. |
| [IMP-024](IMP-024-evidence-receipts-targeted-revalidation-progress-truth.md) | Evidence receipts + targeted revalidation + progress truth | — | ER1–ER3 | Binds `report.md` to bounded immutable receipts + a certifying window (reuses `tool-log.sh`), input-closure targeted invalidation (only intersecting receipts invalidate; unknown stays conservative), and honest execution substates (`implemented`/`independently_verified`) distinct from validate-owned certification. Preserves G083/G005/G009/G056/G057. |

## Recommended implementation order

IMP-001 → IMP-002 → IMP-003 → IMP-004 → IMP-005. IMP-001 and IMP-002 are the highest-value capability additions; IMP-003 is the autonomy/safety hardening; IMP-004 and IMP-005 are refinement + housekeeping. IMP-005 SCOPE-1 (INVENTORY reconciliation) is sequenced AFTER the in-flight isolation-doctrine skills branch lands.

IMP-020 is independently owner-approved and follows its internal dependency order **S1 → S2 → S3 → S4 → S5 → S6 → S7**. It must not be implemented as one undifferentiated change: evaluator failure semantics precede sample aggregation; trust metadata precedes effective-bundle hashing and held-out execution; documentation/release reconciliation closes the sequence.

The Feature-010 batch originally spanned IMP-021..025. **IMP-023** (writer-lease concurrency safety) and **IMP-025** (multi-root agent/repo binding) are now delivered. The remaining PROPOSED items are **IMP-021 + IMP-022** (risk-tiered delivery + vertical-plan guard, one planning/delivery pair) → **IMP-024** (evidence bounds + progress truth), unprioritized pending owner review. IMP-023 amended IMP-004 SCOPE-2 rather than superseding it.

## Net assessment

The framework's process integrity (anti-fabrication, gates, ownership, compaction, evidence provenance) is sound — the audit found no dead gate/mode references and no broken state guards on the `done` path. These proposals address capabilities at the human/safety edges, not structural bugs.

The completed 2026-07-10 adversarial review qualifies that earlier assessment: structural process gates may be wired, but current agentic-evaluation, validator-independence, ambient-tool trust, and effective-instruction claims are not yet supported by outcome-level evidence. IMP-020 is the approved remediation plan; approval is not a pass claim.

## Gap-code legend

- **P1** no readiness synthesizer · **P2** audit verdict not persisted · **P3** no voice-of-user-from-live-product path · **P4** fuzzy verification boundaries · **P5** unowned verification concerns (a11y/i18n, migration, longitudinal perf)
- **A1** no session/cost cap · **A2** no run-level rollback/dry-run · **A3** parallel-scope shared-state contract · **A4** no single autonomy level
- **S1** INVENTORY drift · **S2** Skills-First-Pointers coverage · **S3** learning-loop cold-start + user-blindness
- **D1** no consolidated review mode · **D2** ops prompt-shim parity · **D3** improvements/ surface
- **J1** journey internal-correctness blind spot (UI-only verify) · **J2** no journey tutorial posture · **J3** journey dev/validate-vs-operate plane ambiguity
- **C1** case-colliding duplicate registry template · **C2** `install.sh` scaffolded root `AGENTS.md` from the wrong (colliding) template · **C3** no case-collision prevention guard  _(IMP-017 — a separately-discovered cross-platform bootstrap bug fix, NOT part of the 2026-07 audit. `improvements/` jumps 006 → 017 because the delivered IMP-007..016 docs were deleted-on-delivery per the improvements-doc lifecycle; IMP-017 is the next free number in the monotonic IMP sequence, and IMP-007 is permanently assigned to `regen-derived.sh`.)_
- **MP1** no reusable framework portability guard (only a product-local 4-class check) · **MP2** the 13-class GNU/BSD pitfall table unenforced mechanically (shellcheck does not model BSD/GNU runtime divergence) · **MP3** no framework-validate selftest locking the portability contract  _(IMP-018 — a separately-discovered framework-tooling addition, NOT part of the 2026-07 audit; the next free number after IMP-017.)_
- **WRA1** goal/workflow responsibility overlap · **WRA2** runner-to-runner subagent deadlock · **WRA3** no per-agent mode grants · **WRA4** public docs named workflow rather than goal as the universal endpoint  _(IMP-019 — owner-approved architecture correction on 2026-07-09.)_
- **AF-001** regex/file eval rubrics admit hollow outputs · **AF-002** judge exceptions fail open without status · **AF-003** same-runtime samples are mislabeled independent votes and cross-model execution is unimplemented · **AF-004** no held-out executable outcome/cost/provenance benchmark · **AF-005** no untrusted-content policy or ambient-tool/MCP/data-egress trust contract · **AF-006** instruction lint measures files rather than the effective loaded prompt/tool bundle · **FIN-001** no product-agnostic downstream vintage/forecast evaluation profile  _(IMP-020 — owner-approved implementation plan on 2026-07-10.)_
- **RTD1** one delivery weight for every risk class · **RTD2** low-risk work pays the maximum-assurance tax · **RTD3** the G128 budget primitive is unused by any mode  _(IMP-021 — Feature-010 convergence observations; PROPOSED.)_
- **VDP1** vertical-slice preference is behavioral not mechanical · **VDP2** no time-to-first-usable-outcome check · **VDP3** no risk-adjusted scope budget · **VDP4** consumer-timing deferral undetected  _(IMP-022 — Feature-010 convergence observations; PROPOSED.)_
- **WL1** the existing lease covers runtime capacity not spec artifacts · **WL2** the parent-owned shared-state contract is documented but unenforced · **WL3** no stale/crash takeover for artifact writers  _(IMP-023 — Feature-010 convergence observations; PROPOSED.)_
- **ER1** unbounded report growth despite evidence-by-reference · **ER2** all-or-nothing revalidation on any byte change · **ER3** no execution-progress substate distinct from certification  _(IMP-024 — Feature-010 convergence observations; PROPOSED.)_
- **MR1** no target↔agent-source binding check · **MR2** agent identity not repository-qualified · **MR3** handoff envelopes omit repo/agent provenance  _(IMP-025 — Feature-010 convergence observations; PROPOSED.)_
