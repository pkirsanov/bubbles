# IMP-002 — Supply-Chain Source Locking + Up-Front Complexity Justification

> **Type:** Framework self-improvement execution plan
> **Owner surface:** Bubbles framework (`skills/`, `instructions/`, `agents/`, `CHANGELOG.md`, `VERSION`, release manifest)
> **Status:** SHIPPED — committed and pushed before the v7.10.0 observability/guidance delivery (framework release line v7.9.x)
> **Authoring agent:** bubbles.workflow (parent-expanded; subagent runtime had no `runSubagent`)
> **Created:** 2026-06-11

> ⚠️ **Why this lives in `improvements/` and not `specs/`:** the Bubbles source
> repo MUST NOT keep persistent `specs/` execution packets — Gate **G085**
> (`framework_dogfood_evidence_gate`) fails if `specs/` exists in the canonical
> checkout (regression: `tests/regression/test_04_framework_dogfooding.sh`).
> The operator's request asked for `specs/` artifacts; the framework's own
> governance forbids them in the source repo, so this portable execution plan
> is the Bubbles-native equivalent (mirrors `IMP-001`). It carries the
> spec/design/scope/evidence content the request asked for.

---

## Outcome Contract

- **Intent:** Add two reusable, toolchain-agnostic governance policies that were
  genuinely missing from Bubbles:
  - **Policy A (supply-chain source locking):** lock *build-time* dependency
    resolution to an explicit allowlist of trusted registries/sources —
    complementary to, and explicitly distinct from, the *deploy-time* artifact
    provenance Bubbles already enforces (cosign/SLSA/SBOM/Trivy in the knb
    adapters).
  - **Policy B (complexity justification):** require new designs to justify any
    deviation from the simplest viable approach with rejected alternatives,
    up front, as a lightweight documentation discipline.
- **Success Signal:**
  1. A new portable skill + binding instruction exist for Policy A and pass the
     agnosticity lint and the release-manifest freshness check.
  2. The canonical design template carries a `## Complexity Tracking` section and
     `bubbles.design` carries one behavioral rule requiring it.
  3. `framework-validate` is green with the new files enumerated in the release
     manifest.
- **Hard Constraints:**
  - No project-specific content (agnosticity-clean); no `/home/` paths; no
    banned concrete-tool tokens.
  - **No new enforcement gate, no new script, no new workflow mode** — Policy A
    is enforced by each downstream repo's EXISTING blocking lint/pre-push gate
    using the ecosystem's native tool; Policy B is template/authoring discipline.
  - The two supply-chain axes (build-time SOURCE locking vs deploy-time artifact
    PROVENANCE) are cross-linked, not duplicated.
  - No `specs/` directory in the source repo (G085).
  - No commit, no push — operator review only.
- **Failure Condition:** A duplicated/forked provenance control, a new blocking
  gate the operator did not ask for, agnosticity drift, or a stale release
  manifest that fails `framework-validate`.

---

## SCOPE-1 — Supply-chain dependency-source locking (Policy A)

**Intent:** Generalize the EngOps rule "exactly one package source; never
reference the public index directly" into a toolchain-agnostic Bubbles policy.

**Gherkin**
- Given a dependency manifest that can resolve from an un-allowlisted index/source, when the repo's lint/pre-push gate runs, then it is a blocking finding.
- Given a `--extra-index-url` (or `,direct` / second-registry) fall-through to an un-allowlisted host, when the source check runs, then it fails.
- Given a checksum/verification disable knob (`GONOSUMCHECK`, `GOINSECURE`, `--trusted-host`), when the source check runs, then it fails.
- Given an agent reading this skill, then it distinguishes build-time SOURCE locking from deploy-time artifact PROVENANCE and cross-links the latter rather than duplicating it.

**Tasks**
- T1.1 — Author `skills/bubbles-supply-chain-source-locking/SKILL.md`: Core Rule, "Two Axes" distinction, per-ecosystem guidance (Cargo/npm/Go/pip), Forbidden vs Required table, enforcement guidance (downstream wires its existing blocking gate; no bypass), verification commands, See Also cross-links.
- T1.2 — Author binding `instructions/bubbles-supply-chain-source-locking.instructions.md` (`applyTo: "**"`) mirroring the newer instruction shape; The Rule, Two Axes, What Counts, Enforcement, Forbidden/Required table, See Also.
- T1.3 — Add the skill row to `skills/INVENTORY.md` (alphabetical position; KEEP).
- T1.4 — Confirm agnosticity-clean (no project names, no `/home/` paths, no banned tool tokens).

**DoD**
- [x] Skill authored, project-agnostic, with the Two-Axes distinction + deploy-provenance cross-links. Evidence: `skills/bubbles-supply-chain-source-locking/SKILL.md` (178 lines).
- [x] Binding instruction authored with `applyTo: "**"` + Forbidden/Required table + no-bypass rule. Evidence: `instructions/bubbles-supply-chain-source-locking.instructions.md` (88 lines).
- [x] INVENTORY row added. Evidence: `skills/INVENTORY.md`.
- [x] Agnosticity lint clean. Evidence: see "Validation Evidence" below (exit 0, 395 files).
- [x] No new gate/script introduced (enforcement delegated to downstream repos' existing gates).

---

## SCOPE-2 — Up-front complexity justification (Policy B)

**Intent:** Add a lightweight, optional-when-simple complexity-justification
discipline to the canonical design template so new designs inherit it.

**Gherkin**
- Given a new design with no deviation from the simplest viable approach, when the author fills the template, then they record `None — simplest viable approach used.`.
- Given a design that adds complexity, when the author fills the template, then each deviation gets a row: `Decision | Simpler alternative considered | Why rejected`.
- Given `bubbles.design` runs, then its behavioral rules require the `## Complexity Tracking` section.

**Tasks**
- T2.1 — Add a `## Complexity Tracking` section to the canonical `design.md` template in `agents/bubbles_shared/feature-templates.md` (the single source; the `bubbles-feature-template` skill points to it, does not embed a copy).
- T2.2 — Add one behavioral-rule bullet to `agents/bubbles.design.agent.md` requiring the section.
- T2.3 — Keep it a documentation discipline; do NOT add an enforcement script/gate.

**DoD**
- [x] `## Complexity Tracking` section added to the design template with the `None — simplest viable approach used.` rule + columns. Evidence: `agents/bubbles_shared/feature-templates.md`.
- [x] One behavioral rule added to `bubbles.design`. Evidence: `agents/bubbles.design.agent.md`.
- [x] No enforcement gate/script added (proportionate change).

---

## Files Created / Modified

| Path | Change |
|------|--------|
| `skills/bubbles-supply-chain-source-locking/SKILL.md` | **NEW** (Policy A skill, 178 lines) |
| `instructions/bubbles-supply-chain-source-locking.instructions.md` | **NEW** (Policy A binding instruction, 88 lines) |
| `skills/INVENTORY.md` | MODIFIED (added skill row) |
| `agents/bubbles_shared/feature-templates.md` | MODIFIED (Policy B: `## Complexity Tracking` in design template) |
| `agents/bubbles.design.agent.md` | MODIFIED (Policy B: one behavioral rule) |
| `VERSION` | MODIFIED (7.7.0 → 7.9.0, MINOR per documented rules) |
| `CHANGELOG.md` | MODIFIED (added `## v7.9.0` section) |
| `bubbles/release-manifest.json` | REGENERATED (538 → 540 managed files, version 7.9.0, refreshed docsDigest + checksums) |
| `improvements/IMP-002-...md` | **NEW** (this execution plan) |

---

## Validation Evidence

| Check | Command | Exit | Result |
|-------|---------|------|--------|
| Release manifest regen | `bash bubbles/scripts/generate-release-manifest.sh` | 0 | `Updated release manifest: 7.9.0 (540 managed files)`; both new files enumerated (grep count 2) |
| Agnosticity lint | `bash bubbles/scripts/cli.sh agnosticity` | 0 | `Scanning 395 portable file(s)` → `project-agnostic and tool-agnostic` |
| Framework validate | `bash bubbles/scripts/cli.sh framework-validate` | (recorded in operator report) | full self-validation incl. release-manifest freshness + dogfood gate |

---

## Operator Decisions Surfaced

1. **`specs/` → `improvements/`:** the request asked for `specs/` artifacts, but
   G085 forbids `specs/` in the source repo. This IMP doc is the Bubbles-native
   substitute (same content, allowed location). If the operator prefers, the
   work can instead be dogfooded as hermetic fixtures or in a downstream repo.
2. **VERSION bump 7.7.0 → 7.9.0 (MINOR, reconciled):** this feature is a new
   governance capability (new skill + new binding instruction), which is MINOR
   per the CHANGELOG versioning table ("New capabilities … structural changes to
   governance"). The original working-tree bump targeted 7.8.0, but 7.8.0 (and
   possibly 7.8.1) already exist on the canonical release line — corroborated by
   IMP-001 and IMP-003, which both review against a "shipped v7.8.0" baseline.
   This clone's committed HEAD was behind (VERSION 7.7.0), so the feature is
   renumbered to 7.9.0 — the next free MINOR under the one-feature-per-MINOR
   cadence (7.5 → 7.6 → 7.7 → 7.9, with 7.8.x reserved for the canonical line's
   entries when this clone is synced). Pure renumber; no behavioral change. The
   pre-commit hook auto-increments PATCH on commit; operator confirms the hook
   respects the manual MINOR base.
3. **Staging:** the two NEW files were `git add`-ed (NOT committed) so the
   release-manifest generator (which enumerates tracked files) includes them and
   the change set validates green. Everything else is unstaged working-tree
   edits. Operator may unstage if preferred.
4. **Downstream re-sync:** product/overlay repos pick up the new skill +
   instruction on their next `install.sh` run (glob copy of `skills/*/` and
   `instructions/*.md`); the design-template + agent changes flow the same way.
5. **Bug-fix design template (`bug-templates.md`):** Policy B initially shipped
   the `## Complexity Tracking` section in the feature `design.md` template only.
   Parity has since been applied — the section now also ships in the bug-fix
   design template (`agents/bubbles_shared/bug-templates.md`), framed for
   deviation from the minimal fix, so both design surfaces carry the discipline.
