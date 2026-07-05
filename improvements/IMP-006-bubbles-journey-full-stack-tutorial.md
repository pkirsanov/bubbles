# IMP-006 — bubbles.journey: Full-Stack Tutorial Walkthrough & Internal-Correctness Verification

**Status:** PROPOSED — **applied to the agent contract** (`agents/bubbles.journey.agent.md`, `prompts/bubbles.journey.prompt.md`, `docs/recipes/guided-journey.md`); workflow-integration deferred. Per G125 no `bubbles/*` config (workflows.yaml / modes.yaml / priorityScoring) is auto-mutated.
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved
**Motivation:** guided-journey walkthroughs of the live product surfaced that a green UI can pass while the backend is quietly wrong — the agent captured screen-level friction but never verified internal correctness (API / telemetry / data)
**Verified gaps addressed:** J1 (internal-correctness blind spot), J2 (no tutorial posture), J3 (dev/validate vs operate/prod plane ambiguity)

## Problem (verified against source)

- **J1 — internal-correctness blind spot.** `bubbles.journey` drives the LIVE UI and records ONE user-facing verdict per step. Its Behavioral Rules said only "Drive the LIVE running product … via Playwright (the project browser-automation stack) + direct API" and the Output Contract `Journey Steps` table carried a single `Friction` column. Nothing asserts the API the step actually fired, nothing queries the validate-plane trace/metrics for that step, and nothing reads the data store back. **A green UI over a sick trace or an un-persisted write passes today** — an undiscovered bug, not a pass.
- **J2 — no tutorial posture.** The checkpoint loop (one step → present → STOP → wait) is already the perfect teaching cadence, but the agent was framed as friction-capture only. It did not lead each step with a plain-language "what this step does and why", did not answer the user's questions before moving on, and produced no durable, replayable artifact — so a walkthrough couldn't double as onboarding.
- **J3 — plane ambiguity.** "dev/validate plane" appeared once as a parenthetical; the dev/validate-DRIVE vs operate/prod-READ-ONLY boundary was never stated as a NON-NEGOTIABLE and INV-12 was not referenced, leaving "drive prod" ambiguous.

No behavior-preserving change to any other agent is needed: `chaos` = stochastic (no user, no goal), `redteam` = adversarial, `grill` = pre-build. journey remains the cooperative-guided-WITH-the-user stance — this IMP hardens *how thoroughly it verifies each step* and *how it teaches*, without touching that stance.

## Proposal

Additive, behavior-preserving hardening of the journey agent contract. Every existing non-negotiable is preserved verbatim: the checkpoint-interactive loop, `uservalidation.md` ownership + the G057 human-acceptance boundary, the no-inline-edit-of-spec/design/scopes routing rule, anti-fabrication + the Execution Evidence Standard, the existing handoffs, Non-goals, and RESULT-ENVELOPE. `SCOPE-1..SCOPE-7` map one-to-one to the seven improvements `R1..R7`.

### SCOPE-1 — Full-stack per-step verification (R1 · J1) — headline

Replace the single "Drive the LIVE running product … via Playwright + direct API" Behavioral Rule with a **four-layer** contract verified at EVERY step:
1. **UI** — visible outcome via Playwright; capture the accessibility snapshot.
2. **API** — the request(s) that step fired (`browser_network_requests`) or a direct call; assert status + payload match the intent.
3. **Telemetry** — the validate-plane Jaeger/Prometheus spans/metrics for that step (resolved via `observability-endpoint-resolve.sh --plane validate`): expected spans present, **no error spans**, within SLO (the 4-signal mine).
4. **Data store** — a **read-only** assertion the expected state actually landed (DB row / cache key / queue message).

Degrade gracefully (API-only when no UI; skip a layer only when the target genuinely lacks it — and say so). "Internally works" = all four layers agree.

### SCOPE-2 — Playwright as a first-class, concrete capability (R2)

Reference the Playwright MCP browser tool family (navigate / snapshot / click / evaluate / **network_requests**) as the standard UI-driving + UI→API-bridging method, generically (the MCP prefix varies per environment — not hardcoded). Wired as a Skills-First pointer in SCOPE-5.

### SCOPE-3 — Plane governance (R3 · J3)

Add a NON-NEGOTIABLE Behavioral Rule: DRIVE / MUTATE only on the **dev/validate** plane (`env=test`, G115-safe). The **operate/prod** plane is **READ-ONLY** observation (health, telemetry, data reads) per **INV-12** — never mutate prod. Prod-DRIVE is allowed ONLY for a self-owned, single-tenant system (a home-lab deploy or a static local tool) with explicit operator consent and no shared-tenant blast radius.

### SCOPE-4 — Tutorial posture + durable artifact (R4 · J2)

A journey is *almost a tutorial*. At each step the agent gives a plain-language "what this step does and why" and answers the user's questions about the feature before moving on (teaching is part of the walk — still one-step-then-stop). The agent MAY emit a durable, **replayable walkthrough** into `uservalidation.md` (goal → each step → what it does → how to verify across UI + API + telemetry + data) so the session doubles as onboarding — WITHOUT auto-checking any human acceptance item (**G057 preserved**).

### SCOPE-5 — Skills-First pointers (R5)

Append three to the existing four (keep the current four):
- `bubbles-external-browser-auth-capture` — drive the LIVE UI step-by-step via the Playwright MCP browser tools (incl. `browser_network_requests`); human-in-the-loop for auth-gated steps.
- `bubbles-observability-adapter` — the 4-signal telemetry mine + the `observability-endpoint-resolve.sh` plane resolver (validate vs operate, read-only prod).
- the per-repo **trace-capture** skill (name varies per repo) — concrete Jaeger/Prometheus host:port wiring + `capture-slo.sh`; resolve via the plane resolver, never hardcode.

**No `tools:` frontmatter is added.** The sibling convention (`bubbles.chaos`) is `description` + `handoffs` only; tools are granted globally via the MCP grant.

### SCOPE-6 — Output-contract update (R6)

- Expand the `Journey Steps` table to carry the four evidence lanes + BOTH verdicts: `Step | User Intent | Action | Observed (UI) | API | Telemetry | Data | Friction | Internal`.
- Define the **internal verdict** vocabulary alongside the existing friction verdict: friction `works | unclear | inconvenient | missing | broken` (user-facing) AND internal `backend-correct | api-mismatch | telemetry-error/missing | data-not-persisted`.
- Add a **Hidden Defects (UI-passed, backend-failed)** section: a step that is UI-`works` but not internally `backend-correct` is a hidden defect → route to `bubbles.bug` with the captured API/trace/data as the reproduction. Keep the existing Friction Findings / Refined Scenarios / Recommended Move sections.
- Mirror the internal verdict into the Behavioral Rules "capture at each step" line and the checkpoint-loop "present" step.

### SCOPE-7 — Propagation to downstream repos (R7) — RECORD ONLY, operator-gated

**Not executed by this IMP.** Rollout to the consuming repos is a single operator-gated installer re-sync, NOT a manual downstream edit:

```bash
# from each consuming repo (or driven centrally), operator-run:
bash /path/to/bubbles/install.sh --local-source /path/to/bubbles
```

`install.sh --local-source` re-vendors the framework-managed files (including the upgraded `agents/bubbles.journey.agent.md`, `prompts/bubbles.journey.prompt.md`, and the recipe) into each downstream repo's `.github/bubbles/…` tree and **rewrites that repo's `.github/bubbles/.checksums`**, so `downstream-framework-write-guard.sh` (`bubbles framework-write-guard`) stays green. Direct/manual edits to framework-managed files in a downstream repo are FORBIDDEN — they trip the write guard; the only sanctioned propagation path is the installer re-sync. The five consuming repos are `QuantitativeFinance`, `GuestHost`, `WanderAide`, `smackerel`, and `knb`.

## Composition with IMP-001 (independence note)

This IMP **composes with but does NOT require** IMP-001's still-pending `SCOPE-2` (`journey` phase), `SCOPE-3` (`journey-refinement` mode), and `SCOPE-5`/`experientialFriction` scoring. Those add workflow *wiring* around the agent; IMP-006 hardens the agent *contract itself* and is independently landable. If IMP-001's workflow scopes land later, the four-layer loop and internal verdict flow through unchanged. Per-agent `tools:` frontmatter is intentionally **NOT** added here (see SCOPE-5).

## Migration / rollout (fully additive, behavior-preserving)

- SCOPE-1..SCOPE-6 are already applied to the agent contract, the prompt shim, and the recipe. No existing rule is weakened or removed; every prior non-negotiable is preserved verbatim.
- No `bubbles/workflows.yaml`, `bubbles/workflows/modes.yaml`, or `priorityScoring` change — the only config surface stays untouched (G125).
- SCOPE-7 (propagation) is a separate, operator-gated `install.sh --local-source` re-sync; it is documented here, not executed.

## Risks & mitigations

- **R1** four-layer verification adds per-step cost → degrade gracefully (API-only when no UI; skip a genuinely-absent layer and say so); the checkpoint loop already paces one step at a time.
- **R2** a journey step could mutate prod → SCOPE-3 makes dev/validate-only DRIVE a NON-NEGOTIABLE; operate/prod is read-only per INV-12.
- **R3** `uservalidation.md` automation-mirroring (G057) → the durable walkthrough records observations only; the agent never toggles a human acceptance item.
- **R4** downstream drift if a repo hand-edits the vendored agent → forbidden; propagation is installer-only and the write guard enforces it (SCOPE-7).

## Acceptance criteria

- `bash bubbles/scripts/framework-validate.sh` passes.
- `agents/bubbles.journey.agent.md` carries the 3 new Skills-First pointers (7 total), the four-layer verification loop, the plane-governance NON-NEGOTIABLE (INV-12), the internal verdict vocabulary, and the Hidden Defects table.
- `prompts/bubbles.journey.prompt.md` and `docs/recipes/guided-journey.md` are in sync (tutorial posture, four-layer verification, plane governance, one hidden-defect example).
- No `tools:` frontmatter added; the `description` + `handoffs` sibling convention is preserved.
- Every prior non-negotiable preserved verbatim: checkpoint-interactive loop, `uservalidation.md` ownership + G057, no-inline-edit-of-spec/design/scopes routing, anti-fabrication + Execution Evidence Standard, existing handoffs, Non-goals, RESULT-ENVELOPE.
- Propagation via `install.sh --local-source` (rewriting `.github/bubbles/.checksums`) is documented as the operator-gated rollout, not executed; no downstream repo is touched.

## Files to touch (on approval)

- `agents/bubbles.journey.agent.md` (**applied**) — frontmatter `description`; Skills-First pointers +3; Behavioral Rules four-layer + plane governance + internal verdict; Interaction Model tutorial posture + durable walkthrough; Output Contract four lanes + Hidden Defects; Artifact Ownership `uservalidation.md` structuring bullet. Owner: `bubbles.journey` agent contract.
- `prompts/bubbles.journey.prompt.md` (**applied**) — mirrored `description` + router line.
- `docs/recipes/guided-journey.md` (**applied**) — four-layer verification, tutorial posture, plane governance, hidden-defect example (Cathy's voice preserved).
- `improvements/IMP-006-bubbles-journey-full-stack-tutorial.md` (**this file**, new).
- `improvements/INDEX.md` — proposals table row (owner-reviewed).
- (SCOPE-7, operator-gated, **NOT executed**) `install.sh --local-source` re-sync of the five consuming repos — rewrites each `.github/bubbles/.checksums`; no manual downstream edit.
