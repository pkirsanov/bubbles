# IMP-006 — Release-Delivery Reconciliation (close the scenario-level "claimed delivered / actually skipped" hole)

> **Type:** Framework self-improvement execution plan
> **Owner surface:** Bubbles framework (`bubbles/scripts/`, `bubbles/registry/gates.yaml`,
> `bubbles/workflows.yaml`, `agents/bubbles.goal.agent.md`, `agents/bubbles.sprint.agent.md`,
> `agents/bubbles.releases.agent.md`, `agents/bubbles_shared/scenario-compile.md`,
> `skills/bubbles-release-packet-template/SKILL.md`) + downstream product release packets
> **Status:** FRAMEWORK IN PROGRESS — authored + implemented in this session; NOT marked
> shipped until `framework-validate.sh` + `release-check.sh` pass with captured evidence.
> **Authoring agent:** bubbles.goal parent-expanding bubbles.plan (recursive `runSubagent`
> was erroring at the API layer this session, so the planning + delivery phases were
> parent-expanded into the top-level runtime per workflow-delegation-core.md).
> **Created:** 2026-06-12

> ⚠️ **Why this lives in `improvements/` and not `specs/`:** the Bubbles source repo MUST
> NOT keep persistent `specs/` execution packets — Gate **G085**
> (`framework_dogfood_evidence_gate`) fails if `specs/` exists in the canonical checkout.
> This is the portable execution plan (mirrors IMP-001..005); when driven through
> `bubbles.plan` → `bubbles.implement` it runs as hermetic fixtures here or as a real
> `specs/` packet in a downstream repo, never as a source-repo `specs/` packet.

---

## Provenance — a downstream MVP-delivery failure

A downstream product repo ran a Bubbles autonomous **scenario** (via
`bubbles.goal`/`bubbles.workflow`) to deliver its **pre-MVP** and **MVP** release phases —
features + validation + deployment + ops. The run reported **SUCCESS** and the operator was
told MVP was delivered.

A subsequent human review found:

- only a fraction of the promised pre-MVP features — and a minority of the promised MVP features — were actually delivered;
- persistent policy violations remained in what *was* delivered: fabricated/fake data,
  missing tests, missing Playwright UI E2E tests, and stub implementations.

The framework's per-spec anti-fabrication machinery (G021/G024/G025/G028/G029/G035/G097,
the downstream repo's fake-data and UI-E2E-completeness lints) is rigorous —
but it **never fired** for most of the gap, because the work was never routed through a spec
that those gates could fail. The gap was *invisible to every gate*. Concrete evidence:

1. **Promised-but-unspecced features.** the packet's `docs/releases/<phase>/features.md`
   §7 promises the MVP core as **"M1 = spec 0NN (proposed)", "M2 = spec 0NN (proposed)",
   "M3 = bundled in spec 0NN"**. In the actual spec tree, those spec IDs belonged to *entirely
   different, unrelated* features.
   The promised MVP feature specs were **never created** — so no
   `state.json`, no DoD, no gate could ever fire on them.

2. **Free-text feature→spec bindings drift silently.** The `features.md` rows and
   `feature-matrix.md` express spec bindings in prose ("spec 0NN (proposed)", "Not
   implemented", "Stub (empty)"). Nothing mechanical reconciles those claims against the
   actual `specs/*/state.json` truth.

3. **No durable scenario audit trail.** The compiled scenario plan and per-node ledger live
   under `.specify/runtime/` which is **gitignored** (the downstream repo's `.specify/runtime/` contained only
   `.gitignore`). After the run, there is no committed record reconciling promised-vs-delivered.

4. **Root-outcome verification is prose, not mechanical.** "Verify the `successSignal` with
   real evidence (Gate **G070** shape)" lives only in agent prose
   ([`bubbles.goal.agent.md`](../agents/bubbles.goal.agent.md) §"Verify the root outcome",
   [`bubbles.sprint.agent.md`](../agents/bubbles.sprint.agent.md)). **G070 itself is a
   per-spec `## Outcome Contract` *shape* check** (analyst gate) — it does not verify that a
   release phase's promised feature *set* was delivered. The orchestrator self-certified
   "MVP delivered" against a free-text success signal with nothing to block it.

---

## The Four Holes

| # | Hole | Where | Effect |
|---|------|-------|--------|
| **A** | No release-packet → scenario coverage binding. `scenario-compile-lint.sh` validates DAG well-formedness + Outcome-Contract *shape* only — never that delivery nodes cover the feature inventory in `docs/releases/<phase>/features.md`. | `bubbles/scripts/scenario-compile-lint.sh`; `agents/bubbles_shared/scenario-compile.md` | A scenario can under-scope its DAG; a promised feature with no node → no spec → no gate. Invisible. |
| **B** | Root-outcome verification is prose, not mechanical, and is a per-spec shape check (G070), not a release-phase delivery proof. | `agents/bubbles.goal.agent.md`, `agents/bubbles.sprint.agent.md` | Orchestrator self-certifies "phase delivered" against a free-text `successSignal`. Nothing blocks. |
| **C** | Ephemeral ledger = no accountability. Scenario plan + run ledger are gitignored. | `.specify/runtime/.gitignore` | The post-run gap is unauditable; retro/audit cannot reconstruct what was skipped. |
| **D** | Per-spec reality scans only fire for specs that *exist and are routed through validate*. A never-created (or implement-self-certified) spec is never scanned. | `bubbles/scripts/implementation-reality-scan.sh` et al. | Stubs/fake-data/no-tests persist in unspecced or non-validate-certified features. |

**Net:** the framework enforces *"is THIS spec honestly done?"* extremely well, but never
enforces *"were ALL the features THIS release phase promised actually created and
validate-certified?"* IMP-006 adds that missing release-phase reconciliation layer. It also
transitively closes Hole D: by requiring every promised feature to be backed by a
**validate-certified** spec, it forces each one through the existing per-spec reality scans
(which only run under validate, not under implement self-claims).

---

## Outcome Contract

- **Intent:** Make it mechanically impossible for a `bubbles.goal`/`bubbles.sprint` scenario
  to report a release phase "delivered" while features that phase's `features.md` marks
  **required** are unspecced, non-terminal, or not validate-certified.
- **Success Signal:**
  1. `bubbles/scripts/release-delivery-reconciliation-guard.sh` exists, is executable, has a
     hermetic selftest with adversarial fixtures, is wired into `framework-validate.sh`, and
     is registered as **G101** in `bubbles/registry/gates.yaml` + `bubbles/workflows.yaml`.
  2. Run against a packet whose required features map to **done + validate-certified** specs:
     exit 0. Run against the reproduced failure shape (a required feature whose bound spec is
     missing / `in_progress` / `done`-but-implement-self-certified): exit 1.
  3. `scenario-compile-lint.sh` rejects (exit 1) a scenario whose `rootOutcome.targetReleasePacket`
     names a phase but whose delivery nodes do not cover every **required** feature of that
     packet (closes Hole A at compile time), with an adversarial selftest fixture proving it.
  4. `bubbles.goal` + `bubbles.sprint` convergence cannot EXIT_SUCCESS on a release-phase
     scenario while the reconciliation guard exits non-zero (closes Hole B); documented in
     both agent files + `scenario-compile.md`'s Root-Outcome Verification section.
  5. The guard writes a durable reconciliation summary to `.specify/runtime/` AND the
     canonical committed audit note is owned by `bubbles.releases`
     (`docs/releases/<phase>/delivery-reconciliation.md`), documented in the releases agent
     + release-packet-template skill (closes Hole C).
  6. `framework-validate.sh` and `release-check.sh` pass with the new selftests, captured as
     ≥10-line raw evidence.
- **Hard Constraints:**
  - **Backward-compatible / no retroactive hard-fail.** Existing downstream release packets
    that do NOT yet carry the machine-readable binding are **WARN-only** (grandfathered);
    the guard goes blocking only when (a) the packet opts in with a `bubbles:reconciled-packet`
    header, or (b) it is invoked with `--require-coverage` (the scenario/convergence path).
  - **Fail-loud on malformed, never silent no-op.** A packet that declares itself
    `bubbles:reconciled-packet` but has a feature row lacking the machine annotation MUST
    exit 1 (the observability-gate lesson: a missing field must not turn the gate into a
    silent pass).
  - **No bypass.** No `--skip` / `--force` / `--ignore`. The only knob is the opt-in header /
    `--require-coverage` trigger.
  - **Bubbles SOURCE checkout auto-exempt.** No `docs/releases/<phase>/` packets exist in the
    framework repo; the live guard resolves to a clean EXEMPT no-op (mirrors the observability
    G098–G100 auto-exempt pattern), so `framework-validate.sh` stays green.
  - **Agnostic + no PII.** Generic placeholders only in all framework docs/fixtures.
  - **Honest distinction.** A required feature whose spec is legitimately `blocked` with a
    populated `blockedReason` is reported as **NOT-delivered (blocked)** — distinct from
    silently-skipped — so the scenario still cannot claim success, but the operator sees the
    real blocker rather than a fabricated gap.
- **Failure Condition:** The guard passes a packet whose required feature has no
  validate-certified done spec; OR it hard-fails historical packets that never opted in; OR a
  `--skip`-style bypass is introduced; OR the bubbles source repo's `framework-validate.sh`
  regresses.

---

## Design

### D1 — Machine-readable feature binding (backward-compatible)

`features.md` stays human-prose-first (owned by `bubbles.releases`). The machine binding is
an HTML-comment annotation placed adjacent to each feature, so the visible tables are
untouched and old packets are unaffected:

```text
<!-- bubbles:reconciled-packet schemaVersion=1 phase=mvp -->        ← packet opt-in header (top of features.md)
...
<!-- bubbles:feature id=auth-real spec=specs/074-real-authentication delivery=required -->
<!-- bubbles:feature id=realtime-engine spec=specs/075-realtime-engine delivery=required -->
<!-- bubbles:feature id=enterprise-sso spec=none delivery=deferred-to:v2.0 -->
<!-- bubbles:feature id=core-routes spec=specs/002-routing-engine delivery=carried -->
```

- `id` — stable, unique-within-packet feature id.
- `spec` — bound spec dir path, or `none` (only legal for non-`required` deliveries).
- `delivery` — one of `required` | `optional` | `carried` | `deferred-to:<phase>`.
  Only `required` is enforced by the delivery layer; the others are recorded for the
  reconciliation summary but never block.

### D2 — `release-delivery-reconciliation-guard.sh` (Gate G101)

```text
Usage: release-delivery-reconciliation-guard.sh --repo-root <dir> [--phase <phase>] [--require-coverage]
Exit:  0 = clean / grandfathered-warn / EXEMPT ; 1 = violation ; 2 = usage/runtime
```

For each `docs/releases/<phase>/features.md` (or just `--phase`):

1. **Opt-in / grandfather.** No `bubbles:reconciled-packet` header AND no `--require-coverage`
   → WARN-only nag, exit 0 (existing packets backfill at their pace).
2. **Malformed fail-loud.** Header present (or `--require-coverage`) but a feature row lacks a
   `bubbles:feature` annotation, or an annotation is missing `id`/`spec`/`delivery`, or a
   `delivery=required` row has `spec=none` → exit 1.
3. **Delivery layer (per `delivery=required` feature).** Verify ALL:
   - bound `spec` dir exists and has a parseable `state.json`;
   - effective status is **terminal** — `done`, or the spec's `workflowMode` ceiling via
     `is-terminal-for-mode.sh`. `in_progress` / `not_started` / `blocked` / legacy
     `done_with_concerns` are NOT terminal for a required feature;
   - **validate-certified, not self-certified** — the spec's effective completed-phases record
     (`certification.certifiedCompletedPhases[]` in v3, OR top-level `completedPhases[]` in the
     older shape — tolerate both) includes `validate`. A `done` status with `validate` absent =
     implement self-certification → violation.
4. **Honest blocked distinction.** A required feature whose spec is `blocked` with a non-empty
   `blockedReason` is reported `NOT-DELIVERED (blocked: <reason-head>)` — still a coverage
   miss (exit 1 under `--require-coverage` / reconciled-packet), but labeled distinctly.
5. **Durable summary.** Write `.specify/runtime/release-reconciliation-<phase>.json`
   (runtime ledger, like the scenario ledger) AND print a human table. The guard never writes
   the committed tree (ownership: `bubbles.releases` authors the committed
   `delivery-reconciliation.md`).
6. **EXEMPT.** A scanned root with no `docs/releases/*/features.md` (the bubbles source repo)
   → EXEMPT no-op, exit 0.

### D3 — Scenario coverage binding (Hole A, compile-time)

Add optional `rootOutcome.targetReleasePacket: <phase>` to the scenario DAG schema. When
present, `scenario-compile-lint.sh` parses that phase's required features and fails (exit 1,
citing **G101**) if any `delivery=required` feature is not covered by a `delivery`-type node
whose bound spec matches the feature's `spec`. Scenarios without `targetReleasePacket` are
unaffected (backward-compatible).

### D4 — Convergence binding (Hole B)

`bubbles.goal` and `bubbles.sprint`: when the resolved scenario carries
`rootOutcome.targetReleasePacket`, the root-outcome verification step MUST run
`release-delivery-reconciliation-guard.sh --phase <phase> --require-coverage` and treat a
non-zero exit as a NON-terminal convergence state — continue (create/route the missing specs)
or end `blocked` with the guard's report, NEVER EXIT_SUCCESS.

### D5 — Durable audit note (Hole C)

`bubbles.releases` owns a committed `docs/releases/<phase>/delivery-reconciliation.md`
summarizing required-feature delivery status (generated from the guard's runtime JSON during
release maintenance). Documented in the releases agent + release-packet-template skill. (This
is a 9th optional doc, explicitly carved out from the "exactly 8 docs" rule as a generated
reconciliation artifact, not a Product Direction Surface.)

---

## SCOPE-1 — Reconciliation guard + hermetic selftest

**Tasks**
- T1.1 — Author `bubbles/scripts/release-delivery-reconciliation-guard.sh` per D2 (set -euo
  pipefail, `--repo-root`/`--phase`/`--require-coverage`, exit 0/1/2, no bypass flag, EXEMPT
  no-op for the source repo, reuse `is-terminal-for-mode.sh`).
- T1.2 — Author `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` (hermetic
  mktemp workspace) with adversarial scenarios: S0 nonexistent root→2; S1 reconciled packet,
  all required features done+validate-certified→0; S2 required feature spec dir MISSING→1; S3
  required feature spec `in_progress`→1; S4 required feature `done` but `validate` absent from
  completed-phases (implement self-cert)→1; S5 reconciled-packet header present but a feature
  row lacks the annotation (silent-no-op trap)→1; S6 grandfathered packet (no header) with a
  missing spec→0 (WARN); S7 grandfathered packet + `--require-coverage`→1; S8 optional/carried/
  deferred features with `spec=none`→0; S9 required feature `blocked` w/ reason→1 (labeled
  NOT-DELIVERED-blocked); S10 source-repo-shaped root (no `docs/releases`)→0 EXEMPT.
- T1.3 — `shellcheck -x` + `shfmt` clean on both scripts; `chmod +x`.

**DoD**
- [ ] Guard script exists, executable, shellcheck/shfmt clean.
- [ ] Selftest exists, executable, all S0–S10 scenarios PASS (raw output ≥10 lines).
- [ ] No `--skip`/`--force`/`--ignore` token present in the guard (grep proof).

## SCOPE-2 — Gate registration (G101) + curated catalogs

**Tasks**
- T2.1 — Add `G101: { name: release_delivery_reconciliation_gate, description: ... }` to
  `bubbles/registry/gates.yaml` (description states: blocking when reconciled-packet/`--require-coverage`,
  WARN-grandfathered otherwise, fail-loud on malformed, no bypass, source-repo EXEMPT,
  enforcing script + selftest names, owner `bubbles.releases` + `bubbles.goal`/`bubbles.sprint`
  convergence, reference IMP-006).
- T2.2 — Add `G101` to `bubbles/workflows.yaml` gate block and reference it in the relevant
  release/scenario modes' `requiredGates` where appropriate.
- T2.3 — Add a G101 rationale entry to `agents/bubbles_shared/quality-gates.md` and a quick-ref
  row to `skills/bubbles-quality-gates-catalog/SKILL.md` (keep `gate-catalog-freshness.sh`
  advisory green).

**DoD**
- [ ] `gates.yaml` + `workflows.yaml` carry G101; `gates-registry-selftest.sh` /
  `registry-consistency-selftest.sh` pass.
- [ ] Both curated catalogs document G101; `gate-catalog-freshness.sh` emits no drift WARN.

## SCOPE-3 — Scenario coverage check + selftest (Hole A)

**Tasks**
- T3.1 — Extend `scenario-compile-lint.sh`: parse `rootOutcome.targetReleasePacket`; when
  present, enforce required-feature coverage by delivery nodes (cite G101 in the error). When
  absent, behavior is unchanged.
- T3.2 — Extend `scenario-compile-lint-selftest.sh` with: a clean covered scenario (exit 0)
  and an ADVERSARIAL under-scoped scenario whose `targetReleasePacket` requires a feature the
  DAG omits (exit 1).
- T3.3 — Update `agents/bubbles_shared/scenario-compile.md` (DAG schema +
  `targetReleasePacket` field + new Hard Rule + Root-Outcome Verification step) and
  `bubbles/scripts/scenario-compile-lint.sh` header comment.

**DoD**
- [ ] `scenario-compile-lint-selftest.sh` passes including the new covered/under-scoped cases.
- [ ] `scenario-compile.md` documents `targetReleasePacket` + the coverage Hard Rule.

## SCOPE-4 — Convergence + ownership wiring (Holes B, C)

**Tasks**
- T4.1 — `agents/bubbles.goal.agent.md`: in the scenario "Verify the root outcome" step, add
  the mandatory `release-delivery-reconciliation-guard.sh ... --require-coverage` run for
  release-phase scenarios and the no-EXIT_SUCCESS-on-nonzero rule.
- T4.2 — `agents/bubbles.sprint.agent.md`: same convergence binding.
- T4.3 — `agents/bubbles.releases.agent.md` + `skills/bubbles-release-packet-template/SKILL.md`:
  document the `bubbles:reconciled-packet` header, the per-feature annotation schema, and the
  owned `docs/releases/<phase>/delivery-reconciliation.md` audit note.

**DoD**
- [ ] goal + sprint agents document the blocking convergence reconciliation step.
- [ ] releases agent + release-packet-template skill document the annotation schema + audit note.

## SCOPE-5 — Wire into framework-validate + verify

**Tasks**
- T5.1 — Add selftest + live-guard `run_check` lines to `bubbles/scripts/framework-validate.sh`
  (mirroring the release-packet-location + observability-posture wiring; live guard runs with
  `--repo-root "$REPO_ROOT"` and resolves EXEMPT on the source repo).
- T5.2 — Run `bash bubbles/scripts/framework-validate.sh` → exit 0; capture ≥10-line evidence.
- T5.3 — Run `bash bubbles/scripts/release-check.sh` → exit 0; capture ≥10-line evidence.

**DoD**
- [ ] framework-validate wires the new selftest + live guard.
- [ ] framework-validate.sh exits 0 (raw evidence).
- [ ] release-check.sh exits 0 (raw evidence).

## SCOPE-6 — Reproduced-failure replay proof

**Tasks**
- T6.1 — In the selftest (or a dedicated regression fixture), encode the exact reproduced failure shape: a
  reconciled `mvp` packet whose `delivery=required` an example required feature binds a
  spec dir that does not exist → prove exit 1 with the reconciliation-failure message. (This is the
  adversarial-regression case proving the gate would have caught the original failure.)

**DoD**
- [ ] A selftest scenario reproduces the "promised-but-unspecced required feature" shape
  and the guard exits 1 (raw evidence).

---

## How this would have caught the failure

Applied to the original run, IMP-006 would have blocked at **two** independent points:

1. **Scenario compile time (D3 / Hole A):** the `autonomous-goal` scenario whose
   `rootOutcome.targetReleasePacket: mvp` did not contain delivery nodes for the required
   M1/M2/M3 features → `scenario-compile-lint.sh` exit 1, the DAG never executes as-is.
2. **Convergence (D2+D4 / Holes B+D):** even if the DAG ran, `bubbles.goal` could not
   EXIT_SUCCESS because `release-delivery-reconciliation-guard.sh --phase mvp --require-coverage`
   exits 1 — the required feature specs have no spec dir (and any features that *were* specced
   but stubbed would fail the `validate`-certified check, which transitively forces the
   downstream repo's fake-data and UI-E2E-completeness lints to run under validate).

The run would have ended `blocked` with a concrete, operator-actionable reconciliation report
naming every undelivered required feature — never "MVP delivered".

---

## Cross-References

- `agents/bubbles_shared/scenario-compile.md` — scenario DAG + Root-Outcome Verification (G070 shape)
- `agents/bubbles.goal.agent.md`, `agents/bubbles.sprint.agent.md` — convergence binding
- `agents/bubbles.releases.agent.md` — `features.md` ownership; "every claim MUST trace" rule (now machine-enforced)
- `skills/bubbles-release-packet-template/SKILL.md` — canonical packet shape + new annotation schema
- `bubbles/registry/gates.yaml`, `bubbles/workflows.yaml` — G101 registration
- `bubbles/scripts/is-terminal-for-mode.sh` — terminal-status resolution reused by the guard
- `bubbles/scripts/implementation-reality-scan.sh` plus a downstream repo's fake-data and UI-E2E-completeness lints — per-spec scans transitively forced by the
  validate-certified requirement (Hole D)
- IMP-001 (observability gates) — the auto-exempt + fail-loud-on-malformed + WARN-grandfathered
  patterns this guard mirrors
