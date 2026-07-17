# IMP-025 — Fail-Loud Multi-Root Agent & Repository Binding

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** Multi-session convergence observations (2026-07, Research Lab Feature 010) — the session edited the Research Lab repo while initially using GuestHost's `bubbles.analyst` and later QuantitativeFinance's `bubbles.goal`; Chronicle attributed the Research Lab work to the first workspace root (QuantitativeFinance). A session editing one repository ran an agent definition installed under a different workspace root, with no mechanical objection.
**Verified gaps addressed:** no target↔agent-source binding check (MR1), no repository-qualified agent identity (MR2), handoff envelopes omit repo/agent provenance (MR3).

## Problem (verified against source)

- **MR1 — no fail-loud binding between the edited repo and the agent's source root.** Bubbles already gives each repo's MCP server a **unique per-repo ID** (see the v7.19.x downstream agnosticity work), which disambiguates the framework *server*. But custom-agent SELECTION can still expose identically named installed agents from several workspace roots (`bubbles.goal` exists in every downstream `.github/agents/`), and nothing asserts that the selected agent's source root matches the repository being edited. The MCP-ID fix does NOT solve agent-source ambiguity. (MR1)
- **MR2 — agent identity is not repository-qualified.** The VS Code agent picker shows `bubbles.goal` with no repository qualifier, so a user in a multi-root workspace cannot tell `bubbles.goal (research-lab)` from `bubbles.goal (guesthost)`; picking the wrong copy is silent. (MR2)
- **MR3 — handoff/continuation envelopes omit provenance.** Handoff and continuation envelopes do not carry `repositoryRoot` / `agentSourceRoot` / `frameworkVersion` / target path, so a resumed session cannot validate that it is still bound to the intended repo + agent source. (MR3)

## Proposal

### SCOPE-1 — startup identity tuple + fail-loud binding assertion (MR1)

- Define a startup identity tuple: target Git root, active agent source root, framework provenance root + version, per-repo MCP server ID, and requested spec path. BEFORE any mutable work, assert that either (a) a downstream target uses THAT target repo's installed agent/MCP/config surfaces, or (b) canonical Bubbles source mode is explicitly selected for framework-health work. A GuestHost or QuantitativeFinance agent targeting the Research Lab repo MUST refuse before editing, with actionable remediation.
- **Discovery approach (evidence-bounded):** investigate what VS Code actually exposes about the selected custom-agent URI. If direct discovery is unavailable, implement an **install-time repo marker** in generated agent metadata/instructions plus a deterministic repo-root preflight helper (`repo-binding-preflight.sh`). Do NOT rely on unsupported editor APIs; the marker + preflight is the fallback that works today.

### SCOPE-2 — repository-qualified agent identity (MR2)

- Consider repository-qualified display labels or generated descriptions (e.g. `bubbles.goal (research-lab)`) so a user distinguishes copies WITHOUT forking agent behavior — the qualifier is presentation/metadata only; the agent contract is unchanged and still framework-owned.

### SCOPE-3 — provenance-bearing handoff/continuation envelopes (MR3)

- Require handoff/continuation envelopes to carry `repositoryRoot`, `agentSourceRoot`, `frameworkVersion`, and target path. Orchestrators MUST validate those fields on resume and refuse a resumed run whose current binding no longer matches.

### SCOPE-4 — attribution vs editor-limitation separation (MR1)

- Improve session/telemetry attribution WHERE Bubbles controls it (record the identity tuple in the session log). Clearly separate the VS Code Chronicle attribution limitation (attributes work to the first workspace root) as an upstream editor issue that Bubbles cannot fix unilaterally — document it rather than pretending the framework closes it.

### SCOPE-5 — installer/upgrade migration + generated-file ownership (agnosticity)

- Define how the repo marker is installed/upgraded and which generated file owns it. **No per-machine absolute path may be committed to any downstream repository** — the marker is a repo-relative identity token (repo name/slug), consistent with the agnosticity-lint + `.manifest` managed-surface model. The marker is framework-owned (regenerated on upgrade), never hand-edited.

### SCOPE-6 — multi-root fixtures

- Hermetic fixtures: correct downstream binding passes; a foreign installed agent targeting another repo refuses with remediation; canonical framework-source work passes; a cross-repo `goal` scenario uses explicit repo-qualified nodes; a stale/missing marker fails with actionable remediation; and unique per-repo MCP IDs remain compatible (no regression to the v7.19.x fix).

## Migration / rollout (additive + fail-safe)

- SCOPE-1 preflight is **advisory-until-configured** first (warns on a mismatch), then blocking once the marker is installed across the workspace's repos, so a partially-upgraded workspace is not bricked. SCOPE-2 labels + SCOPE-3 envelope fields + SCOPE-5 marker are additive. Sequencing: SCOPE-5 (marker + install) → SCOPE-1 (preflight) → SCOPE-3 (envelopes) → SCOPE-2/4/6.

## Risks & mitigations

- **R1** a false refusal blocking legitimate cross-repo work → cross-repo scenarios use explicit repo-qualified nodes (SCOPE-6); the preflight recognizes sanctioned canonical-source + cross-repo modes.
- **R2** reliance on an unsupported editor API → SCOPE-1 fallback is a repo marker + deterministic preflight that needs no special editor support.
- **R3** committing a machine-specific path downstream → SCOPE-5 mandates a repo-relative identity token only; agnosticity-lint covers the managed surface.

## Acceptance criteria (when implemented)

- An agent whose source root ≠ the edited repository refuses before the first mutable edit, naming the mismatch + remediation; a correctly-bound downstream agent passes; canonical framework-source work passes.
- Handoff/continuation envelopes carry `repositoryRoot`/`agentSourceRoot`/`frameworkVersion`/target and are validated on resume.
- No committed downstream file contains a per-machine absolute path; the marker is repo-relative and framework-owned; agnosticity-lint stays clean; per-repo MCP IDs remain unique.
- `framework-validate.sh` passes; the preflight + fixtures are wired in.

## Files to touch (on approval)

`bubbles/scripts/repo-binding-preflight.sh` + selftest (new preflight + fixtures, wired into `framework-validate.sh`), `install.sh` + `bubbles/installer/installer.yaml` (install/upgrade the repo-relative marker; generated-file ownership), `agents/bubbles_shared/*` orchestration/handoff modules (identity tuple + envelope fields + resume validation), `agents/bubbles_shared/project-config-contract.md` (marker contract), `bubbles/scripts/agnosticity-lint.sh` (marker stays repo-relative), `docs/guides/*` multi-root docs (attribution vs editor limitation) — name the owning agent/gate for each surface. Preserves the v7.19.x unique-per-repo-MCP-ID fix; does not fork agent behavior.
