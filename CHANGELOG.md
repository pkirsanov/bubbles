# Changelog

## Versioning Scheme

Bubbles uses **MAJOR.MINOR.PATCH** (semver-style):

| Part | When to bump | Who bumps | Examples |
|------|-------------|-----------|----------|
| **PATCH** (3rd) | Every commit — auto-bumped by pre-commit hook | Hook (automatic) | Policy tweaks, doc fixes, skill updates, script fixes, single-gate additions |
| **MINOR** (2nd) | New capabilities, new agents, new gates, new workflow modes, structural changes to governance | Manual (`echo X.Y.0 > VERSION` before commit) | New agent added, new workflow mode, new gate family, taxonomy expansion |
| **MAJOR** (1st) | Breaking changes to installer, state.json schema, agent protocol, or downstream contract | Manual (`echo X.0.0 > VERSION` before commit) | state.json v3→v4, installer flag removal, agent handoff protocol change |

The pre-commit hook auto-increments PATCH on every commit. To bump MINOR or MAJOR, manually set the VERSION file before committing — the hook will then increment PATCH from the new base.

## Unreleased

## v4.1.0 — 2026-05-27

### Added — `delivered_pending_activation` ceiling + scope-kind taxonomy + lockdown contract

This release introduces the schema primitives needed to honestly ship work that
depends on external actors (operator commit, third-party approval, scheduled
cutover, regulator review) without forcing agents to either (a) fabricate
live-runtime evidence that does not yet exist, or (b) leave the status stuck at
`in_progress` indefinitely.

This commit ships the **schema additions only**. Subsequent v4.1.x commits will
land the matching gate logic changes (G073 deliverable manifest, G008A scope-kind
opt-out, G040 lockdown-FR allowlist, G022 phaseStubs, G009 evidence-by-reference,
G090 execution-runtime skip, G056 schema loosening, G041 annotation tolerance) so
gates evaluate these new ceilings/kinds/lockdowns correctly. Until those guard
patches land, the new modes/ceiling are inert (no existing spec uses them) and
no existing behavior changes.

**New top-level workflow registry entries** (`bubbles/workflows.yaml`):

- **`scopeKinds:` taxonomy** — declares the 6 recognised scope kinds
  (`runtime-behavior` (default), `contract-only`, `deploy-pointer`, `ci-config`,
  `docs-only`, `bootstrap`) with explicit `requiresLiveE2E` /
  `requiresIntegrationWiring` / per-kind evidence flags. Scopes opt in via an
  optional `Scope-Kind:` header in `scopes.md` / `scopes/<NN>/scope.md`. Default
  remains `runtime-behavior` so existing scopes that omit the header behave
  exactly as in v4.0.x.
- **`lockdownContract:` registry** — declares the lockdown-tag vocabulary that
  G040 will allow-list when paired with a cited FR / `condition:` / `unblocker:`
  / `expectedActivation:` field. Patterns include
  `[lockdown-deferred-FR-NNN]`, `[awaiting-operator-commit]`,
  `[awaiting-third-party-approval]`, `[awaiting-cutover-window]`,
  `[awaiting-regulator-review]`. Untagged "deferred", "future work",
  "placeholder", "stub for now", "TODO later", "punt" continue to fail G040.

**New workflow modes targeting `delivered_pending_activation` ceiling**:

- **`adapter-readiness-to-packet`** — deploy-adapter readiness mode. Ships
  `apply.sh` / `verify.sh` / `rollback.sh` / manifest schema plus an operator
  activation packet. Requires contract-level tests, `shellcheck`, `yamllint`,
  manifest schema validation, and dry-run apply. Honestly defers live runtime
  E2E until the operator commits per-host params. Default scope kind:
  `deploy-pointer`.
- **`dark-launch-shipped`** — feature-flag dark-launch mode. Ships implementation
  behind off-by-default flag. Requires full implement/test/audit plus sealed-env
  E2E with flag forced on. Honestly defers production E2E until rollout.
  Default scope kind: `runtime-behavior`.
- **`migration-shipped-pending-cutover`** — forward/backward-compatible migration
  mode. Ships migration code (DB / API / protocol). Requires backward-compat,
  forward-compat, and dual-read-or-dual-write contract tests plus rollback plan.
  Honestly defers live cutover E2E until scheduled window. Default scope kind:
  `contract-only`.

**Compatibility**: Pure additive. No existing mode, gate, or guard is modified
in this commit. The new ceiling string `delivered_pending_activation` is
recognised by `resolve_workflow_status_ceiling` (which reads the value directly
from `workflows.yaml`) and any existing guard logic that compares `status ==
ceiling` continues to work.

## v4.0.1 — 2026-05-26

### Fixed — Guard resilience for downstream + cross-layout invocation

Promoted downstream-tested patches into the framework's two most-invoked guards. These started as local QF patches and were proven in production before promotion; they extend the v3.11.1 downstream-installed guard layout resolution work without regressing any existing fixture.

- **`bubbles/scripts/artifact-lint.sh`**
  - `resolve_workflow_registry_file` falls back through 4 candidate paths (`$artifact_repo_root/bubbles/workflows.yaml`, `$artifact_repo_root/.github/bubbles/workflows.yaml`, `$script_repo_root/bubbles/workflows.yaml`, `$script_repo_root/.github/bubbles/workflows.yaml`) so `workflows.yaml` is found whether the lint runs from the source repo, an installed `.github/bubbles/` layout, or with a feature dir outside the script's repo root.
  - `resolve_workflow_status_ceiling_from_registry` adds a direct-YAML `statusCeiling` parser as fallback when `mode-resolver.sh` returns empty.
  - Passes `BUBBLES_WORKFLOWS_FILE` through to `mode-resolver.sh` so the resolver consults the resolved registry path explicitly.

- **`bubbles/scripts/state-transition-guard.sh`**
  - Same `resolve_workflow_registry_file` + direct-YAML fallback as artifact-lint.
  - Adds `is_test_fixture_dir` + `fixture_gate_skip` helpers so certain gates emit `INFO Fixture target under tests/fixtures; <gate> is not evaluated for artifact-state fixture acceptance` instead of false-positive blocking when the target is `tests/fixtures/*`.

### Preserved

- Grandfather clause for historical `done` specs is intact.
- All existing `state-transition-guard-selftest.sh` and `artifact-lint.sh` fixtures still pass with their original verdicts (no fixture relaxation, no gate weakening).
- No new gate ID introduced.
- No CHANGELOG promotion for shipped capabilities; this is a patch-level bug fix.

## v4.0.0 — 2026-05-26

### v4.0.0 — Skills-First Architecture (consolidated release)

This is the **v4.0.0 final** release. It consolidates the work shipped across alpha.1, alpha.2, and alpha.3 into the stable v4.0.0 line. No new content beyond the three alphas; the version bump records the strategic transition from agent-centric to skills-first discovery.

#### Skills-First Discovery Layer (14 skills)

The new `.github/skills/bubbles-*` skills are thin discovery shims that auto-load by description match in Copilot, Claude, Cursor, and other skill-aware tools. They route agents to the authoritative governance modules in `agents/bubbles_shared/*.md` without duplicating policy text. The 14 skills:

**Policy skills (alpha.1)**
- `bubbles-skills-first-discovery` — top-level situation-to-skill map
- `bubbles-anti-fabrication` — pre-DoD-checkbox honesty enforcement
- `bubbles-evidence-capture` — ≥10-line raw-output evidence shape
- `bubbles-dod-validation` — Tier 1/Tier 2 pre-completion audit
- `bubbles-status-transition` — `state.json` transitions + grandfather clause
- `bubbles-result-envelope` — end-of-run packet shape + finding accounting
- `bubbles-artifact-ownership-routing` — own-or-route + framework-managed boundary
- `bubbles-quality-gates-catalog` — gate ID lookup + canonical test taxonomy
- `bubbles-scope-workflow-runtime` — scope layout, Test Plan ↔ DoD parity

**Workflow + template skills (alpha.3)**
- `bubbles-workflow-execution-loops` — per-round synchronous dispatch-and-wait
- `bubbles-workflow-mode-resolution` — natural-language intent routing + template inheritance
- `bubbles-fix-cycle-protocol` — finding-set closure + cherry-pick prevention
- `bubbles-feature-template` — canonical feature artifact set + v3 control-plane fields
- `bubbles-bug-template` — 6-artifact bug shape + Gate 0 reproduction + adversarial regression

#### Agent-visible direction shift (alpha.2)

The 10 largest agents (super, validate, chaos, iterate, harden, workflow, bug, test, security, audit) now open with a Skills-First Pointer block naming the 3–5 skills the agent should consult before handling a request. No content was removed; no content-presence selftest was touched.

#### Documentation surface

- `README.md` skills row updated to highlight the 14-skill layer
- `agents/bubbles_shared/agent-common.md` gained a Skills-First Discovery Layer section
- `docs/CHEATSHEET.md` TPB Vocabulary gained `skills-first discovery`, `policy skill`, `grandfather clause` entries
- `docs/its-not-rocket-appliances.html` gained the matching three TPB cards
- `docs/recipes/framework-ops.md` gained a Skills-First Discovery section
- `bubbles/capability-ledger.yaml` gained the `skills-first-discovery-layer` shipped capability (released v4.0.0)
- All generated docs (competitive-capabilities, framework-stats, release-manifest) regenerated for v4.0.0

#### Preserved across the v4.0 release (NON-NEGOTIABLE)

- **Grandfather clause for historical `done` specs is intact.** `done-spec-audit.sh --profile advisory` remains the default; the pre-push hook continues to use `--profile changed`; historical specs are not re-evaluated under new policy unless their `state.json` is touched in the same commit. The skills-first refactor is purely additive — it does not introduce new mechanical guards, gate IDs, or recertification triggers.
- **All existing governance modules under `agents/bubbles_shared/*.md` remain authoritative.** Skills are discovery shims, not policy rewrites.
- **All mechanical guards in `bubbles/scripts/` are unchanged.** Gate IDs G024–G095+ behave identically. No new gate IDs were introduced in v4.0.0.
- **All 38 agents continue to work unchanged.** No agent prompt content was removed; alpha.2 added a Skills-First Pointer block at the top of 10 agents purely additively.
- **Selftest assertions updated only for the new shipped-capability count** (12 → 13). No content-presence selftest was relaxed or removed.

#### Roadmap beyond v4.0.0

The originally-planned "shrink the 10 biggest agents" target requires updating hundreds of content-presence selftests in lockstep with each agent edit. That refactor is a follow-up milestone (tracked as a framework-proposal) and will land as v4.1+ once the lockstep selftest work is staged. The v4.0 line ships the skills-first direction and the full discovery surface; the underlying agent prompts continue at their v3.11 size until lockstep work begins.

## v4.0.0-alpha.3 — 2026-05-26

### Added — Workflow internals + templates as discovery skills

5 new discovery skills extending the skills-first layer to workflow internals and artifact templates:

- `bubbles-workflow-execution-loops` — per-round synchronous dispatch-and-wait; batch-then-summarize prohibition; mapped-mode execution
- `bubbles-workflow-mode-resolution` — natural-language intent routing; template inheritance; statusCeiling/executionOptions/gates lookup
- `bubbles-fix-cycle-protocol` — finding-set closure; cherry-pick prevention; trigger-owned closure
- `bubbles-feature-template` — canonical feature artifact set (spec.md, design.md, scopes.md, report.md, uservalidation.md, state.json) + v3 control-plane fields
- `bubbles-bug-template` — bug folder shape (6 required artifacts); Gate 0 reproduction; adversarial regression

### Wired

- `agent-common.md` Skills-First Discovery Layer expanded with 5 new triggers
- `bubbles-skills-first-discovery` situation-map updated with the new entries
- `bubbles/capability-ledger.yaml` skills-first-discovery-layer capability now lists all 14 discovery skills as evidence
- README skills row updated count
- Release manifest regenerated to include the 5 new SKILL.md files

### Preserved

- Grandfather clause for historical `done` specs is intact.
- No mechanical guard, gate ID, or recertification trigger changed.
- All 38 agents continue to work unchanged.

## v4.0.0-alpha.2 — 2026-05-26

### Added — Skills-First Pointer headers on 10 largest agents

- **Skills-First Pointer blocks** added to the 10 largest agents (super, validate, chaos, iterate, harden, workflow, bug, test, security, audit). Each block names 3–5 skills the agent should consult before handling a request. Purely additive: no content removed, no selftest assertions affected.
- Discovery benefit: when these agents are loaded, the skill names are visible at the top of the prompt and route to the right policy module on demand.

### Scope honesty

- The originally-planned "shrink the 10 biggest agents" target requires updating the framework's content-presence selftests (hundreds of `PASS: <agent> mentions <token>` assertions) in lockstep with each agent edit. That lockstep refactor is genuinely multi-session work and is deferred to a follow-up milestone tracked as a framework-proposal.
- Alpha.2 ships the skills-first **direction** at the top of every large agent prompt without changing any selftest, gate, or policy. Token savings in this alpha are modest; the strategic posture is fully shipped.

### Preserved

- Grandfather clause for historical `done` specs is intact.
- No mechanical guard, gate ID, or recertification trigger changed.
- All 38 agents continue to work unchanged.

## v4.0.0-alpha.1 — 2026-05-26

### Added — Skills-First Discovery Layer

- **9 new discovery skills** under `skills/bubbles-*/`:
  - `bubbles-skills-first-discovery` — top-level "which skill applies" map
  - `bubbles-anti-fabrication` — pre-DoD-checkbox honesty enforcement
  - `bubbles-evidence-capture` — ≥10-line raw-output evidence shape
  - `bubbles-dod-validation` — Tier 1/Tier 2 pre-completion audit
  - `bubbles-status-transition` — `state.json` transitions + grandfather clause
  - `bubbles-result-envelope` — end-of-run packet shape and finding accounting
  - `bubbles-artifact-ownership-routing` — own-or-route, framework-managed boundary
  - `bubbles-quality-gates-catalog` — gate ID lookup, canonical test taxonomy
  - `bubbles-scope-workflow-runtime` — scope layout, Test Plan ↔ DoD parity
- **`agent-common.md` Skills-First Discovery Layer section** — additive index linking the new skills to their authoritative governance modules
- **README skills row** updated to highlight the v4.0 skills-first layer
- **CHEATSHEET TPB Vocabulary** — added `skills-first discovery`, `policy skill`, and `grandfather clause` entries
- **`its-not-rocket-appliances.html`** — same three TPB cards added to the visual cheatsheet
- **`docs/recipes/framework-ops.md`** — new "Skills-First Discovery (v4.0+)" section pointing to every shipped policy skill
- **Capability ledger entry `skills-first-discovery-layer`** registered as `shipped` for v4.0.0

### Preserved (NON-NEGOTIABLE)

- **Grandfather clause for historical `done` specs is intact.** `done-spec-audit.sh --profile advisory` remains the default; the pre-push hook continues to use `--profile changed`; historical specs are not re-evaluated under new policy unless their `state.json` is touched in the same commit. The skills-first refactor is purely additive — it does not introduce new mechanical guards, gate IDs, or recertification triggers.
- **All existing governance modules under `agents/bubbles_shared/*.md` stay authoritative.** Skills are discovery shims, not policy rewrites. The mechanical guards in `bubbles/scripts/` are unchanged.
- **All existing agents continue to work unchanged.** No agent prompt content was removed or restructured in this alpha. Agent shrinking ships incrementally in v4.0.0-alpha.2 with paired selftest updates per agent.

### Roadmap

- **v4.0.0-alpha.2** — shrink the 10 largest agents (`super`, `validate`, `chaos`, `iterate`, `harden`, `bug`, `workflow`, `test`, `audit`, `security`) by replacing repeated policy prose with skill pointers. Each agent edit ships with paired updates to its content-presence selftests.
- **v4.0.0-alpha.3** — move workflow internals (execution loops, phase engine, mode resolution, fix cycle) and templates (feature, scope, bug) from `agents/bubbles_shared/` into skills, leaving thin orchestration in agents.
- **v4.0.0 final** — full validation, regenerated capability ledger and release manifest, downstream rollout.

## v3.11.1 — 2026-05-26

### Fixed

- **Downstream-installed guard layout resolution** — `orchestrator-persistence-lint.sh`, `planning-workflow-chain-guard.sh`, `delivery-implementation-delta-guard.sh`, and `strict-terminal-status-guard.sh` now resolve both Bubbles source layout (`agents/...`, `bubbles/workflows.yaml`) and downstream-installed layout (`.github/agents/...`, `.github/bubbles/workflows.yaml`). Added downstream-layout selftest fixtures for G086, G091, G093, and G092 so installed repos no longer fail solely because guards searched source-only paths.
- **G092 downstream script text scanning** — `strict-terminal-status-guard.sh` now treats `.github/bubbles/scripts/*` as script/detection context, matching source-layout `bubbles/scripts/*`, so installed guard code that detects legacy `done_with_concerns` is not misclassified as active permission prose.

## v3.11.0 — 2026-05-25

### Added

- **Capability-First Design doctrine** — Added `agents/bubbles_shared/capability-foundation.md`, validation IDs AN5/DE4/UX9/P4, and the `bubbles-capability-foundation-design` skill. Planning agents now model reusable capability foundations before concrete providers/adapters/variants when proportionality applies.
- **Gate G094 (`capability_foundation_gate`)** — New guard `bubbles/scripts/capability-foundation-guard.sh` plus hermetic selftest and persistent regression. It detects adapter/provider/strategy/plugin/channel/driver/connector/variant signals or multiple concrete implementations, enforces required capability sections, and grandfathers older specs via `state.json.createdAt`.
- **Capability design examples and recipes** — Added `docs/examples/capability-foundation.example.md` and `docs/recipes/design-a-capability.md`, then cross-linked the doctrine through guides, recipes, cheatsheets, and visual/TPB vocabulary surfaces.

## v3.10.0 — 2026-05-25

### Added

- **Framework convergence health documentation** — Added `docs/Framework_Convergence_Health.md` as the durable published overview for G082-G093: convergence cap, context compaction discipline, pre-existing deferral blocking, source-aware framework dogfood evidence, orchestrator persistence lint, planning packet linkage, post-certification edit detection, inter-spec dependency enforcement, retro convergence health, planning workflow chain enforcement, strict terminal statuses, and delivery implementation delta enforcement.
- **Spec implementation alignment documentation** — Added `docs/Spec_Implementation_Alignment.md` to publish the hardened spec/implementation linkage contract: state linkage fields, planning-only classification, post-certification edit handling, dependency revalidation, spec-review default routing to `improve-existing`, G092 observations, and G093 delivery delta classification.

### Changed

- **Bubbles source repo no longer carries persistent `specs/`** — Migrated the temporary `specs/001-framework-convergence-health/` dogfood packet into durable docs and framework assets. The Bubbles source repository now treats a repo-local `specs/` tree as invalid; source dogfood evidence comes from framework validation, hermetic selftests, release manifest checks, and downstream/fixture specs.
- **G085 source-aware dogfood evidence** — `framework-dogfood-guard.sh` now distinguishes the Bubbles source repository from downstream/fixture repositories. In source, the guard fails if `specs/` exists and verifies validation/release evidence surfaces. In downstream/fixture repos, it still accepts at least one numbered `specs/[0-9]*-*/state.json` with `status: done`.
- **G092/G093 close the certification loopholes** — New terminal certification writes are restricted to `done` or `blocked`, with low/medium non-blocking notes stored as observations. Done-ceiling delivery modes now need implementation/runtime/config/contract/test/docs delta outside `specs/` and `.specify/` before certification.

### Fixed

- **`implementation-reality-scan.sh` Scan 1D Go connector helper false positives** — Scan 1D now treats idiomatic Go helper `return nil` lines as non-fake when a sibling non-test file in the same Go package has real upstream/client-call evidence. Other suspicious integration patterns still fire, and a no-op connector package with no external call path remains blocking. Added hermetic selftest coverage for the honest-helper pass case and the adversarial no-op connector failure case.

## v3.8.0 — 2026-05-10

Bubbles framework v3.8.0 — 21 improvements landed across runtime coordination, in-loop tooling, governance hygiene, and operator UX. Three independent audits (Opus 4.7, GPT-5.5, Gemini 3.1 Pro) returned GO. See ledger entries below.

### Documentation

- Added stateless-shell-session reinforcement to terminal-discipline instructions (T3I-A7).
- Added empty-output sentinel convention to terminal-discipline (T3C-A9).
- Added windowed-read pattern to operating-baseline (T3D-A3).
- New recipe: bookend phases for long workflows (T3F-B11).
- New recipe: UX single-file sweep (T3G-B13).
- Added bin/ and install.sh conventions to skill authoring guidance (T3H-A4).

### Added

- `gate-id-grep.sh` + selftest: detects duplicate-adjacent and unknown gate IDs across governance docs (T3B-B7).
- Gate G075 (scope-index-parity-gate): per-scope-directory layout — blocks scope advancement when the status column of `scopes/_index.md` disagrees with the `**Status:**` line of any linked `scopes/NN-name/scope.md`; detects fabricated batch promotions that update individual scope files while leaving the index showing "In Progress". Enforced by state-transition-guard.sh Check 5B.
- Gate G076 (phantom-scope-detection-gate): blocks state.json transitions when any entry in `completedScopes` (or `certification.completedScopes`) does not map to a real scope directory or `## Scope N:` heading on disk. Enforced by state-transition-guard.sh Check 5C.
- Gate G077 (execution-history-plausibility-gate): blocks state.json transitions when `executionHistory` entries have implausible timestamps — three or more consecutive identical intervals, zero-duration non-trivial entries, or overlapping runs — and enforces that `certification.lockdownState.round` is ≤ implement-phase run count and `lastCleanRound` ≤ `round`. Enforced by state-transition-guard.sh Checks 7A and 7B.
- Gate G078 (batch-promotion-limit-gate): CI gate that blocks any single git commit (or push range) from promoting more than one spec's `state.json` `status` to "done" without explicit override. Enforced by `bubbles/scripts/batch-promotion-lint.sh` and the `state-transition-guard` GitHub Actions workflow.
- **Governance-doc orphan lint (T2E-B6)** — added `bubbles/scripts/governance-index-lint.sh` (+ hermetic selftest) that scans every `agents/bubbles_shared/*.md`, `instructions/*.instructions.md`, `skills/*/SKILL.md`, and `docs/recipes/*.md` and asserts each one is referenced from at least one well-known index (`README.md`, `agents/bubbles_shared/agent-common.md`, `agents/bubbles_shared/scope-workflow.md`, `docs/governance-index.md`, or any `agents/*.agent.md`). Detects governance docs that ship with the framework but are unreachable from any roll-up index — a class of drift that has previously hidden behind doc-search noise. Args: `--repo-root <path>`, `--allow <regex>` (repeatable), `--verbose`. Exits 0 on zero orphans, 1 on any orphan. Allowlists self-index docs (the indexes themselves) and `README.md`/`CHANGELOG.md`/`LICENSE`/`VERSION`/`docs/issues/*`/`docs/generated/*`/`*-selftest.md`. Selftest stages PASS + FAIL fixtures and asserts both exit code and the `ORPHAN_GOVERNANCE_DOC:` marker (6/6 assertions PASS). Wired into `bubbles/scripts/framework-validate.sh` as a conditional `run_check`. Also added `docs/governance-index.md` as the canonical roll-up listing all 111 governance docs grouped by category — the lint itself naturally covers it (it is a well-known index). Live repo: 111 docs scanned, 41 indexes consulted, 0 orphans. (#improvement-T2E-B6)
- **Orchestrator frontmatter `agent`-tool lint (T2F-B9)** — added `bubbles/scripts/orchestrator-tool-frontmatter-lint.sh` (+ hermetic selftest) that scans every `agents/*.agent.md` and asserts each orchestrator declares `agent` in its frontmatter `tools:` list. An orchestrator without `agent` in `tools:` cannot call `runSubagent(...)` at runtime — the IDE blocks the tool, the orchestrator silently degrades into a single-agent transcript, and the entire delegation pipeline collapses without any visible error. Detects orchestrators by (a) hardcoded canonical name list (workflow, iterate, goal, sprint, harden, gaps, bug, system-review, code-review, releases, bootstrap, setup, handoff, recap, status, retro, spec-review, regression) OR (b) body keyword scan for `runSubagent(`, `runUntilComplete: true`, "delegate to", "specialist agent". Honors frontmatter opt-out `delegationModel: none` for genuinely terminal agents. Args: `--repo-root <path>`, `--allow <agent-name>` (repeatable), `--verbose`. Exits 0 if all OK, 1 otherwise. Frontmatter parser handles both inline (`tools: [a, b, agent]`) and block (`tools:\n  - agent`) YAML list forms via an awk state machine; matches `agent` as a word-boundary token (so `agentic` / `agent-foo` do NOT match). Selftest stages 4 fixtures (PASS, FAIL, opt-out, non-orchestrator) plus an `--allow` rescue test (8/8 assertions PASS). Wired into `bubbles/scripts/framework-validate.sh`. Live repo: surfaced 17 orchestrators missing the `agent` tool (audit, code-review, devops, gaps, handoff, harden, recap, regression, releases, retro, setup, simplify, spec-review, stabilize, status, super, system-review) — REPORT-ONLY for now; no auto-fix per scope policy. (#improvement-T2F-B9)
- **`bubbles trajectory` CLI + `trajectory-inspector.sh` (T2G-A6)** — added `bubbles/scripts/trajectory-inspector.sh` (+ hermetic selftest) and wired `bubbles trajectory [options]` into `bubbles/scripts/cli.sh`. Prints a human-readable trajectory report from the active Bubbles session, recent turn snapshots, lessons memory, and per-spec state files. Output sections: (1) Session Summary (sessionId, agent, mode, featureDir, status, currentPhase, lastUpdatedAt), (2) Phase Progression (phase counts + last N turn snapshots from `turnSnapshots[]`), (3) Scope Progression (per-scope `Status:` from `scopes/*/scope.md` or `scopes.md`, plus `completedScopes` from spec `state.json`), (4) Recent Lessons (tail of `.specify/memory/lessons.md`), (5) Active Specs (one row per `specs/*/state.json` with status / workflowMode / currentPhase). Args: `--session <id>` (search default + archived sessions), `--last <N>` (default 10), `--format text|json` (default text), `--repo-root <path>`, `--verbose`. Always exits 0 when no active session (prints `(no active session)` for text or `{"sessionFound": false, ...}` for JSON); only exits 2 on usage errors. Hard dependency on `jq` for `--format json`; degrades gracefully without `jq` for text format. Selftest stages a synthetic active session (2 turn snapshots, 1 active spec with 2 scopes, lessons.md with 2 entries) plus a no-active-session fixture and asserts (a) text output contains all 5 section headers + fixture identifiers, (b) `--format json` is valid JSON with `sessionFound=true` and `turnSnapshots.length == 2`, (c) `--last 1` trims to the most recent turn, (d) no-active-session path emits `(no active session)` text and `sessionFound=false` JSON both with exit 0, (e) invalid `--last` value exits 2 (25/25 assertions PASS). Wired into `bubbles/scripts/framework-validate.sh`. (#improvement-T2G-A6)
- **8 hermetic selftest scripts for guard/lint scripts (T2D-B4)** — added `bubbles/scripts/regression-quality-guard-selftest.sh`, `regression-baseline-guard-selftest.sh`, `traceability-guard-selftest.sh`, `artifact-freshness-guard-selftest.sh`, `agent-ownership-lint-selftest.sh`, `agnosticity-lint-selftest.sh`, `instruction-budget-lint-selftest.sh`, and `value-selection-lint-selftest.sh`. Each selftest stages synthetic clean and violating fixtures inside a `mktemp -d` tree, invokes the script under test, asserts both exit-code and key output-token expectations (e.g., `FALSE_NEGATIVE_BAILOUT`, `ADVERSARIAL_REGRESSION_MISSING`, `PROJECT_NAME`, `OVER BUDGET`, `superseded scope section`, `Value-First Selection Cycle`, `missing version header`, `Route collision`), and cleans up via `trap 'rm -rf "$TMPDIR"' EXIT INT TERM`. Selftests for `agent-ownership-lint` and `agnosticity-lint` clone the framework surface (`bubbles/`, `agents/`) into the temp tree before perturbing fixtures so the live repo state is never mutated. All 8 are wired into `bubbles/scripts/framework-validate.sh` as conditional `run_check` entries (`if [[ -x "$SCRIPT_DIR/<name>-selftest.sh" ]]; then ...`) following the established optional-selftest pattern. (#improvement-T2D-B4)
- **Mode template inheritance for `bubbles/workflows.yaml`** — workflow modes may now declare `inherits: [<template-name>...]` to share common scalars, maps, and arrays via reusable bundles defined under a new top-level `modeTemplates:` block. Resolver `bubbles/scripts/mode-resolver.sh` (commands: `<mode-name>`, `--list-modes`, `--list-templates`, `--validate`) deep-merges maps, concatenates and dedups arrays (preserving first-occurrence order; `requiredGates` is sorted alphabetically as a canonical gate set), uses scalar latest-wins, rejects inherits cycles, and rejects unknown template references. v3.9 ships 4 templates (`base-delivery`, `delivery-quality-constraints` with the 12 universal anti-fabrication constraints, `delivery-gate-baseline` with the 39-gate common baseline, `finding-owned-remediation` with the 4-constraint diagnostic-discovered-work bundle). 5 modes refactored to use them: `full-delivery`, `bugfix-fastlane`, `harden-to-doc`, `gaps-to-doc`, `iterate` — all five verified byte-identical resolved output via per-mode diff. The remaining 32 modes intentionally stay verbose pending a follow-up refactor. Selftest `bubbles/scripts/mode-resolver-selftest.sh` exercises 6 cases including cycle detection and unknown-template rejection; both `--validate` and the selftest are wired into `framework-validate`. Pattern documented in `agents/bubbles_shared/workflow-mode-resolution.md#mode-template-inheritance`. Capability ledger row `mode-template-inheritance` shipped at `v3.9.0`. Hard dependency on `yq` (mikefarah, v4+). (#improvement-T2C-B3)
- `done_with_concerns` first-class workflow outcome state: workflow modes (`bubbles/workflows.yaml`) now permit a third terminal outcome alongside `done` and `blocked`. Agents emit a structured `concerns: []` array (entries with `severity: low|medium`, `followUpOwner`, `followUpAction`) instead of fabricating success or stalling. Pattern documented in `agents/bubbles_shared/completion-governance.md#outcome-state-done_with_concerns`. Wired into workflow, validate, audit, harden, and gaps agents. Capability `done-with-concerns-outcome-state` shipped at v3.8.0. (#improvement-B12)
- **Orchestrator context compactor** (`bubbles/scripts/context-compactor.sh` + selftest): orchestrator agents (workflow, sprint, goal, iterate) now compact accumulated subagent RESULT-ENVELOPEs into structured ledger entries before context pressure causes truncation or fabrication. Pattern documented in `agents/bubbles_shared/operating-baseline.md#context-compaction-discipline-orchestrator-agents`. Capability ledger row `orchestrator-context-compaction` shipped at `v3.8.0`. (#improvement-A5)
- **Per-turn state snapshot** (`bubbles/scripts/state-snapshot.sh` + selftest): orchestrator agents (`bubbles.workflow`, `bubbles.sprint`, `bubbles.goal`, `bubbles.iterate`, and any agent doing multi-turn work) emit turn-start (`--mode start`) and turn-end (`--mode end`) records into `.specify/memory/bubbles.session.json` `turnSnapshots[]` carrying `turnNumber` (auto-increment), UTC ISO8601 `timestamp`, `phase`, `scopeId`, `mode`, `note`, and `agent` (from `$BUBBLES_AGENT_NAME`). Enables deterministic crash-resume (next agent can detect `start` without matching `end`) and a per-turn audit trail for compliance. Hard dependency on `jq`; if `jq` is missing, orchestrator MUST surface `state_snapshot_drift: true` in RESULT-ENVELOPE. Pattern documented in `agents/bubbles_shared/operating-baseline.md#per-turn-state-snapshot`. Capability ledger row `per-turn-state-snapshot` shipped at `v3.8.0`. (#improvement-A2)
- **Project-pluggable linter-on-edit gate** (`bubbles/scripts/edit-lint-gate.sh` + selftest): specialist agents (`bubbles.implement`, `bubbles.devops`, `bubbles.simplify`, `bubbles.harden`) MAY invoke the gate after editing source files. Framework supplies the dispatcher; downstream projects register language-specific linters via `.specify/memory/bubbles.config.json` under `editLintGate.linters` (e.g., `cargo clippy`, `npx eslint`, `ruff check`). Default behavior is no-op (opt-in only) — the framework MUST NOT bundle default linters, preserving framework agnosticity. Anti-fabrication tie-in: if `enabled: true`, agents MUST include the gate's exit code in their RESULT-ENVELOPE evidence. Pattern documented in `agents/bubbles_shared/operating-baseline.md#linter-on-edit-gate-project-pluggable`. Capability ledger row `linter-on-edit-gate` shipped at `v3.8.0`. (#improvement-A1)

### Fixed

- **Workflow registry consistency (Fix 1+6 for v3.8.0 release)** — `bubbles/scripts/workflow-registry-consistency.sh` `mode_inventory()` and `bubbles/scripts/generate-framework-stats.sh` `count_workflow_modes()` are now section-aware: the awk only collects 2-indent keys nested under the top-level `modes:` section. The previous awk inspected every 2-indent key in the file and used the `description:`-as-next-line heuristic alone, which incorrectly captured `outcomeStates.done` and `outcomeStates.blocked` (both have `description:` as the next field) and would have captured any future top-level section that adopted the same indentation+description convention. The new `phaseRelevance:` config block inside `modes:` is correctly excluded by the surviving description heuristic. Regenerated `agents/bubbles.workflow.agent.md` `Supported options:` to enumerate the canonical 35 delivery modes (alphabetical, `|`-separated, line ends exactly at the closing backtick so the `^- \`mode: ([^\`]+)\`$` regex in `supported_options_inventory()` matches), with the explanatory note moved to a follow-up indented bullet. Regenerated `docs/generated/framework-stats.json` workflowModes count from 34 → 35. Net: `workflow-registry-consistency.sh`, `cli.sh doctor` Check 9, and `workflow-surface-selftest.sh` all flip from FAIL → PASS.
- **Release manifest regenerated to reflect v3.8 framework changes (Fix 2/3/4)** — ran `bubbles/scripts/generate-release-manifest.sh` to refresh `bubbles/release-manifest.json` for the current source SHA and the expanded managed-file set (318 files; previously stale at 299). The manifest now covers the T2D/T2E/T2F/T2G/T2H/T3B selftest scripts (`regression-quality-guard-selftest.sh`, `regression-baseline-guard-selftest.sh`, `traceability-guard-selftest.sh`, `artifact-freshness-guard-selftest.sh`, `agent-ownership-lint-selftest.sh`, `agnosticity-lint-selftest.sh`, `instruction-budget-lint-selftest.sh`, `value-selection-lint-selftest.sh`, `governance-index-lint-selftest.sh`, `orchestrator-tool-frontmatter-lint-selftest.sh`, `trajectory-inspector-selftest.sh`, `gate-id-grep-selftest.sh`) and other v3.8-era additions. Net: `release-manifest-freshness`, `committed-release-manifest-current`, and `release-manifest-selftest` framework-validate checks all flip from FAIL → PASS.
- **Trust doctor selftest (Fix 5)** — root cause was cascade from Fix 1+6: `trust-doctor-selftest.sh` runs `cli.sh doctor` inside a command substitution under `set -euo pipefail`. When doctor's Check 9 (`workflow-registry-consistency.sh`) exited non-zero, doctor exited non-zero, the `$(...)` capture aborted the script via `set -e` before any assertion ran (selftest always exited 1 with no PASS/FAIL output beyond the scenario header). With the registry consistency fix in place, doctor passes and the selftest now runs all 20 assertions PASS. No script change required to `trust-doctor-selftest.sh` itself — preserves the original trust signaling without weakening any guarantee.
- **Autonomous orchestrator capability-claim audit (T1D-B10)** — audited the four top-level orchestrator agents (`bubbles.goal`, `bubbles.sprint`, `bubbles.workflow`, `bubbles.iterate`) and confirmed all major capability claims (single-goal 7-phase convergence loop with `max_iterations: 10` matching `bubbles/workflows.yaml` `maxConvergenceIterations`, time-budget enforcement and 15-minute wrap-up reserve in `autonomous-sprint`, mode-driven phase dispatch with `runSubagent` delegation in `workflow`, priority-driven work picker with `WORK-ENVELOPE` contract in `iterate`, `agent` tool alias in frontmatter on all four files, never-stop escape hatches, parent-expansion fallback when nested `runSubagent` is unavailable, G042 Anti-Manipulation Policy enforcement in `workflow`) match the advertised behavior in `bubbles/workflows.yaml`. Capability ledger baseline preserved at **6 shipped, 1 partial, 0 proposed** — the umbrella `workflow-orchestration` row already covers these orchestrators as sub-capabilities; no flip required. No `bubbles/workflows.yaml` mode-definition drift found (`autonomous-goal` and `autonomous-sprint` mode entries are complete with `statusCeiling: done`, full `phaseOrder`, comprehensive `requiredGates`, and full `constraints` blocks). Reconciled 8 narrow `drift_doc_only` typos in agent files: corrected `Anti-Fabrication (Gate G042)` → `Anti-Fabrication (Gate G021)` in `bubbles.goal.agent.md` and `bubbles.sprint.agent.md` (G021 is the canonical anti-fabrication gate; G042 is `artifact_ownership_enforcement_gate`); fixed duplicate `G028, G028` → `G028, G029` in COMPLETION GATES references in `bubbles.workflow.agent.md`, `bubbles.iterate.agent.md` (also added missing `G027`), `bubbles.audit.agent.md` (also added `G029` callout to the gate description), `bubbles.implement.agent.md` (both `G028+G028` paired-scan reference and the COMPLETION GATES list), and `bubbles.test.agent.md`. Validation: `bubbles/scripts/cli.sh doctor` baseline preserved (15 passed / 1 pre-existing workflow-registry failure / 0 advisory — no NEW failures introduced); `bubbles/scripts/agent-ownership-lint.sh` exit 0; `bubbles/scripts/agnosticity-lint.sh` exit 0 (194 portable files clean). (#improvement-T1D-B10)
- **G068 (`word-overlap threshold`) false-positive fix** — `bubbles/scripts/state-transition-guard.sh` (`stg_significant_words`/`stg_scenario_matches_dod`) and `bubbles/scripts/traceability-guard.sh` (`significant_words`/`scenario_matches_dod`) now (1) lower the minimum significant-word length from 4 to 3 chars so 3-letter domain words (API, DoD, SLA, CSV, CSP, JWT, SDK, CLI, CRD, SBOM) are counted, (2) trim the exclusion list to TRUE stop words only — removed `user`, `users`, `system`, `should`, `must`, `have`, `has`, `will`, `given`, `after`, `before`, `where`, `their`, `there`, `about`, `only` which are frequently the distinguishing words in Gherkin scenario titles, and (3) switch from a fixed absolute overlap count to a percentage threshold: a DoD item now matches a scenario when `overlap / scenario_significant_word_count ≥ 0.50` AND `overlap ≥ 3`, with full-overlap fallback for scenarios that have fewer than 3 significant words so very small specs are not penalized. Capability ledger flipped `dod-gherkin-fidelity-threshold` from `proposed` → `shipped` (regenerated `docs/generated/issue-status.md`, `docs/generated/competitive-capabilities.md`, README block, and `bubbles/release-manifest.json`); `bubbles/scripts/capability-ledger-selftest.sh`, `bubbles/scripts/competitive-docs-selftest.sh`, and `bubbles/scripts/capability-freshness-selftest.sh` updated to expect the new `5 shipped, 1 partial, 1 proposed` counts and the reversed G068 drift fixture direction. (#issue-G068)

### Changed

- **Reconciled `session-aware-runtime-coordination` ledger drift** — audit confirmed `bubbles/scripts/runtime-leases.sh` (acquire / attach / release / heartbeat / doctor / reclaim-stale / summary / lookup with compatibility fingerprints, share modes, and stale-lease takeover) and `bubbles/scripts/runtime-lease-selftest.sh` (19-case selftest including downstream installation/CLI integration) are shipped, and that the lease registry is wired into `bubbles/scripts/cli.sh` (`runtime` subcommand passthrough, `cmd_status` runtime summary, `cmd_doctor` conflict/stale detection) and `bubbles/scripts/framework-validate.sh` (selftest invocation). Flipped capability `session-aware-runtime-coordination` from `proposed` → `shipped` with `releaseIntroduced: v3.8.0`; expanded `summary`, added evidence/docs refs to `docs/guides/CONTROL_PLANE_DESIGN.md`, `docs/guides/CONTROL_PLANE_SCHEMAS.md`, `bubbles/scripts/runtime-leases.sh`, `bubbles/scripts/runtime-lease-selftest.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/framework-validate.sh`. Added `## Resolution` section to `docs/issues/session-aware-runtime-coordination.md` documenting shipped surface, acceptance-criteria status (all 7 met), and known follow-ups (agent-prompt integration is optional incremental enhancement, not a gap). Regenerated `docs/generated/competitive-capabilities.md`, `docs/generated/issue-status.md`, `docs/generated/interop-migration-matrix.md`, and the README ledger block — counts now read **6 shipped, 1 partial, 0 proposed**. Updated count assertions in `bubbles/scripts/capability-ledger-selftest.sh`, `bubbles/scripts/competitive-docs-selftest.sh`, and `bubbles/scripts/capability-freshness-selftest.sh`; refreshed `bubbles/release-manifest.json` hashes. (#issue-session-aware-runtime-coordination)

### Changed

- **Persona rebalance** — `bubbles.sprint` persona swapped from "Donna" (non-canonical) to **Erica** (Trevor's mom — ran "Liquor Inside / Liquor Outside" hustle in TPB). New canonical icon `icons/erica-doublestack.svg` (two stacked liquor bottles + stopwatch overlay) replaces `icons/donna-whistle.svg`. Quote, command aliases, and TPB vocabulary updated across CHEATSHEET, README, recipe, guides, and HTML cheatsheet to *"Inside and outside, both at once. Don't fall behind."*
- **Persona convention documented** — added "Persona Convention: Contextual Variants" section to `docs/CHEATSHEET.md` ratifying that Mr. Lahey (sober/super vs. drunk/retro), Camera Crew (silent/status vs. talking-head/recap), and Cory + Trevor (solo bug+handoff vs. paired setup) are intentional contextual variants of the same TPB character, not duplicates. Future agents may NOT casually reuse a persona; the table is the authoritative allowlist.

### Removed

- **`icons/donna-whistle.svg`** — replaced by `icons/erica-doublestack.svg`.

## 3.7.0

### Added

- **`bubbles.releases` agent** — new owner agent for producing and refreshing phase release packets (vision/features/actions/business-plan/deployment/marketing/monetization/ops-scalability) and plan packets across product repos. Carries the Sonny "Iron Lung" Smith TPB persona. Owns release-packets and plan-packets per `agent-ownership.yaml`.
- **`release-planning-to-doc` workflow mode** — registered in `bubbles/workflows.yaml` as a doc-only mode that gates on Product Direction Surfaces presence (INVESTOR_OVERVIEW.md, Product-Principles.md, product-principles.instructions.md) before allowing release packet creation.
- **Product Direction Surfaces convention** — new guide at `docs/guides/PRODUCT_DIRECTION_SURFACES.md` defines the required investor/product-principles trio plus the recommended `docs/plans/` and `docs/releases/` structure for downstream product repos.
- **`bubbles-product-principle-discovery` skill** — new repo-local skill encoding the evidence-based principle-surfacing protocol: cite source (existing repo doc), no fabrication, flag every drafted principle "Surfaced for owner approval — not yet ratified", never auto-ratify.
- **`bubbles.releases` recipe** — new `docs/recipes/release-planning.md` walks operators through the phase-release planning loop, carry-forward rules, and Product Direction Surfaces preflight.
- **Sonny "Iron Lung" Smith icon** — new TPB-style line-art SVG at `icons/sonny-ledger.svg` (wheelchair + breathing tube + open ledger) carries the agent's identity across docs.

### Changed

- **`bubbles.setup` agent** — now requires Product Direction Surfaces trio when bootstrapping or refreshing downstream repos. Missing surfaces are surfaced as setup findings, not auto-created (owner must approve product direction).
- **`bubbles-repo-readiness` skill** — readiness audit now includes Product Direction Surfaces presence check.
- **`docs/CATALOG.md`, `docs/recipes/README.md`, `docs/CHEATSHEET.md`, `docs/guides/AGENT_MANUAL.md`, `docs/guides/WORKFLOW_MODES.md`, `README.md`, `docs/its-not-rocket-appliances.html`** — registered the new agent, recipe, mode, and Sonny vocabulary entries across catalog and reference surfaces.

## 3.6.2

### Changed

- **Orchestrator authoring guidance** — documented the structural YAML body convention for router/orchestrator agents, including the required relationship between body-level tool allowlists and frontmatter tool availability.

### Fixed

- **Autonomous orchestrator tool access** — `bubbles.sprint`, `bubbles.goal`, `bubbles.workflow`, `bubbles.iterate`, and `bubbles.bug` now declare the VS Code `agent` tool alias in frontmatter so their mandatory `runSubagent` delegation path is available at runtime instead of only described in body-level governance text.
- **Outcome-first dispatch contract** — autonomous orchestrators now explicitly route to the better-fit Bubbles mode, child workflow, or specialist owner when that is needed to satisfy user intent. They must not stop and ask the user to switch mode; only a missing `agent` tool may produce a blocked envelope.
- **Capability registry parity** — `bubbles.goal` and `bubbles.sprint` are now declared as orchestrators in `agent-capabilities.yaml`, matching their existing child-workflow permissions and execution-claim writer status.
- **Regression selftest** — `workflow-delegation-selftest.sh` now checks child-workflow caller frontmatter for the `agent` tool alias plus the outcome-first dispatch and missing-agent-tool policy anchors.

## 3.6.1

### Fixed (`implementation-reality-scan.sh`)

- **Filesystem fallback by spec slug** — when neither `scopes.md` nor `design.md` enumerate `Implementation Files`, fall back to filesystem search for files whose names contain the spec slug (e.g. `037-llm-agent-tools` → matches `*llm_agent_tools*` and `*llm-agent-tools*`). Previously triggered `ZERO_FILES_RESOLVED` even when implementation clearly existed. Project-agnostic: searches from repo root excluding `node_modules`, `.dart_tool`, `.venv`, `venv`, `.git`, `target`, `build`, `dist`, `coverage`, `specs`.
- **Consolidated `[Nn]ot [Ii]mplemented` pattern** — replaced 4 separate patterns (`'Not Implemented'`, `'throw new Error\\('`, `'not implemented'`, `'return .*not implemented'`) with one case-insensitive regex. The `'throw new Error\\('` pattern was a major false-positive generator — it matched any thrown error, not just unimplemented placeholders.
- **Narrower Python `responses` library detection** — replaced bare `'responses\\.'` (which matched `requests.responses.json()`, `mock.responses[0]`, etc.) with three specific patterns: `'^import responses'`, `'@responses\\.activate'`, `'responses\\.add\\('`.
- **Skip docstring matches in Python tests** — awk state machine tracks Python triple-quoted-string regions and excludes those line numbers from intercept checks. Documentation examples in `"""..."""` are no longer flagged.

### Why

These fixes were discovered as local mods in a downstream installation and upstreamed verbatim (with the filesystem fallback generalized for project-agnosticism).

## 3.6.0

### Added

- **UX8 validation gate** — `validation-profiles.md` now requires `{FEATURE_DIR}` to contain no UX sidecar files (`ux.md`, `wireframes.md`, `flows.md`, `user-flows.md`, `screens.md`). All UX content MUST live inside `spec.md` under `## UI Wireframes` and `## User Flows`.
- **Forbidden Artifacts policy** in `agents/bubbles_shared/artifact-ownership.md` — declarative ownership map of filenames that MUST NOT exist as sidecars (UX, business, design, planning, evidence). Includes a speckit interop note clarifying that `tasks.md`, `data-model.md`, `requirements.md`, and `test-plan.md` are NOT forbidden (they belong to the speckit workflow that coexists with bubbles).
- **`artifact-lint.sh` enforcement** — script now fails when any forbidden sidecar filename appears under a feature/bug folder, with a message pointing to `artifact-ownership.md → Forbidden Artifacts`.
- **`bubbles.ux` agent hardening** — Single-File Output Rule (FORBIDDEN/REQUIRED table), Phase 5 absolute-write directive, and Tier 2 mechanical pre-report gate (`grep` for `## UI Wireframes` + loop checking forbidden filenames).
- **`ux-bootstrap.md`** — added single-file output constraint to the UX bootstrap module so every UX agent invocation reads it before writing.

### Why

The `bubbles.ux` agent (running under `/bubbles.goal` orchestration) was observed creating sidecar `ux.md` files in 4 specs of a downstream installation instead of appending wireframes to `spec.md`. Diagnosis confirmed the prompts were unambiguous, but no mechanical enforcement existed — the LLM made a stylistic judgment to "split for organization." This release adds the missing enforcement layer so the same mistake fails the lint gate immediately.

## 3.5.1

### Orchestrator Delegation Enforcement (Goal + Sprint Agents)

- **bubbles.goal — Orchestrator-Only Identity:** Added `⛔ ORCHESTRATOR-ONLY IDENTITY` section with explicit prohibition table forbidding the goal agent from making direct code changes. Goal agent is a convergence-loop controller that MUST delegate all specialist work via `runSubagent`.
- **bubbles.goal — Phase delegation hardened:** Phases 2, 3, and 5 YAML now include `invocation_method: runSubagent` and explicit comments clarifying that "invoke" means `runSubagent`, not self-execution. Phase 5 remediation now mandates `bubbles.workflow` as the sole delegation target (not individual specialists).
- **bubbles.goal — `runSubagent` prompt templates:** Added concrete prompt templates for every phase (plan, implement, test, validate, audit, chaos, workflow, simplify, docs) showing exactly what context to pass each specialist.
- **bubbles.sprint — Orchestrator-Only Identity:** Added `⛔ ORCHESTRATOR-ONLY IDENTITY` section establishing the sprint agent as a time-bounded queue controller that MUST delegate all goal work to `bubbles.goal` via `runSubagent`. No exceptions for perceived simplicity.
- **bubbles.sprint — Phase Execution Matrix:** Added scannable 4-phase table mapping what the sprint agent does directly vs. what it delegates.
- **bubbles.sprint — `runSubagent` prompt templates:** Added prompt templates for `bubbles.super`, `bubbles.goal`, and `bubbles.docs` invocations.
- **bubbles.sprint — execute_goal hardened:** YAML block now includes `invocation: runSubagent(bubbles.goal)`, `prompt_must_include` list, and ⛔ prohibition comment.
- **Gate G042 — Delegation Fabrication:** New anti-fabrication gate added to both goal and sprint agents. Defines fabrication patterns (inline implementation, direct specialist calls, terminal-as-implementation, etc.), quantitative detection heuristics (minimum `runSubagent` call counts per phase), and consequences (all work suspect, audit required).

### Stochastic Sweep Must Remediate, Not Just Report (Regression Fix)

- **Root cause:** `workflow-execution-loops.md` Phase 0.9 was a table-of-contents skeleton that listed what it owned but never provided the step-by-step round loop procedure. The round loop existed only in YAML comments, and the "wait for child completion" requirement was in a separate generic protocol file (`workflow-fix-cycle-protocol.md`), not wired into the loop body. This allowed the LLM to interpret "dispatch N rounds" as "generate N round selections and produce a findings report."
- **Fix: Populated the authoritative round loop** — `workflow-execution-loops.md` Phase 0.9 now contains the full step-by-step round procedure: pool resolution → synchronous round loop (select → resolve → dispatch via `runSubagent` → WAIT for terminal RESULT-ENVELOPE → record → classify → next round) → sweep summary with continuation.
- **Fix: Explicit synchronous dispatch-and-wait** — every round MUST dispatch its child workflow and wait for completion before the next round starts. Batching round selections without dispatching child workflows is now explicitly FORBIDDEN in three locations.
- **Fix: No report-only completion** — producing a findings table without dispatching child workflows to remediate is now explicitly called out as a policy violation in the execution loops, the workflow agent anchors, and the fix-cycle protocol.
- **Fix: Fix-cycle protocol round-loop clause** — `workflow-fix-cycle-protocol.md` now explicitly addresses round-based loops (stochastic sweep, iterate), requiring dispatch → wait → record per round.
- **Selftest coverage** — 10 new assertions in `finding-closure-selftest.sh` verify the synchronous round loop, batch-then-summarize prohibition, report-only prohibition, runSubagent dispatch requirement, and per-round wait-before-next instruction.

### Workflow Dispatch Reliability

- **Instruction budget is now a framework validation gate** — `framework-validate` and `doctor` now fail when any agent prompt exceeds the hard instruction-budget limit instead of treating budget drift as an informational audit only.
- **Workflow fix-cycle protocol extracted** — the stochastic repair-round dispatch contract moved into `workflow-fix-cycle-protocol.md` so `bubbles.workflow` keeps the same behavior with less prompt bloat.
- **Planning specialist provenance** — `bubbles.design` and `bubbles.plan` now record bootstrap execution in `state.json.executionHistory`, and the state transition guard now checks that analyze-first modes actually dispatched the required planning owners.
- **Planning provenance selftest** — `framework-validate` now runs a dedicated negative fixture proving `bubbles.workflow` cannot author planning artifacts without analyst, UX, design, and plan provenance in `executionHistory`.
- **Source-repo project config cleanup** — the Bubbles source checkout now carries real maintainer commands and source-repo paths in `.github/copilot-instructions.md`, eliminating the last doctor-visible bootstrap placeholders.

### Release Manifest And Install Provenance Trust

- **Release manifest generation** — `bubbles/release-manifest.json` is now generated from the source repo and records version, git SHA, supported profiles, supported interop sources, validated surfaces, trust-doc digest, and framework-managed checksum inventory.
- **Downstream install provenance** — installs now write `.github/bubbles/.install-source.json` with install mode, symbolic source ref, source SHA, dirty-tree state, and installed version. Local-source installs never persist an absolute checkout path.
- **Trust-aware framework ops** — downstream `framework-write-guard`, `doctor`, and `upgrade --dry-run` now surface installed provenance, managed-file integrity, and dirty local-source warnings explicitly instead of treating trust state as implicit.
- **Trust canaries** — added `release-manifest-selftest.sh`, `install-provenance-selftest.sh`, and `trust-doctor-selftest.sh`, and wired them into `framework-validate` plus `release-check`.

### Workflow Continuation Guardrails

- **Continuation language now preserves active workflow orchestration** — `bubbles.workflow` and `bubbles.super` treat follow-ups like `continue`, `fix all found`, `fix everything found`, `address rest`, `fix the rest`, and `resolve remaining findings` as workflow continuation, not as permission to drop into raw specialist execution.
- **Active workflow mode preservation** — continuation handling now prefers the active mode and target recovered from continuation envelopes, recent workflow outputs, workflow run-state, or spec state. Existing `stochastic-quality-sweep`, `iterate`, and `full-delivery` runs stay in those modes unless the remaining work is explicitly narrowed.
- **Continuation envelope widened** — `preferredWorkflowMode` in recap/status/workflow continuation packets now accepts any valid workflow mode from `bubbles/workflows.yaml`, allowing stochastic sweeps and iterate runs to survive handoff and recovery without lossy down-conversion.
- **Stochastic sweep closeout safety** — when a stochastic sweep ends with non-terminal touched specs, workflow output must preserve a workflow-owned continuation packet instead of suggesting raw `/bubbles.implement`, `/bubbles.test`, or similar specialist follow-ups.

### Planning Alignment & Research Quality (v3.4)

- **Design Brief** — `bubbles.design` now produces a required ~30-50 line alignment checkpoint at the top of design.md: current state, target state, patterns to follow/avoid, resolved decisions, open questions. Gives reviewers 5-minute steering leverage before expensive scoping.
- **Execution Outline** — `bubbles.plan` now produces a required ~30-50 line preamble at the top of scopes.md: phase order, new types/signatures, validation checkpoints. Like C header files for the plan.
- **Phase 0.55: Objective Research Pass** — For brownfield modes (`improve-existing`, `redesign-existing`, `full-delivery`, `bugfix-fastlane`, `reconcile-to-doc`), the workflow runs a two-pass research phase: (1) generate codebase questions while knowing the intent, (2) research in a fresh solution-blind context. Produces objective "current truth" instead of confirmation-biased research.
- **Horizontal plan detection** — `bubbles.plan` Phase 4 now mechanically detects horizontal scope sequences (3+ consecutive single-layer scopes) and restructures into vertical slices.
- **Slop Tax metrics** — `bubbles.retro` tracks rework: scope reopens, phase retries, post-validate reversions, design reversals, fix-on-fix chains, net forward progress score. Target: < 15%.
- **`instruction-budget-lint.sh`** — New script counting directive lines per agent prompt. Warning at 120, hard at 200. Registered as `bubbles lint-budget` CLI command.
- **Super agent v3.4 awareness** — Design Brief, Execution Outline, Phase 0.55, horizontal plan detection, Slop Tax, instruction budget lint, 18 previously undocumented CLI commands now surfaced.
- **CHEATSHEET fixes** — Added missing gates G067 (shared infrastructure blast radius) and G069 (collateral change containment).
- **WORKFLOW_MODES.md fixes** — Added missing `retro-to-simplify`, `retro-to-harden`, `retro-to-review` to Quick Reference table. Added new capability sections.

### Data-Driven Workflow Modes + Recipe Catalog (v3.3)

- **3 new workflow modes** — `retro-to-simplify`, `retro-to-harden`, `retro-to-review`: data-driven workflows that run retro hotspot analysis first to identify targets, then execute the appropriate action (simplify, harden, or code-review) on those targets
- **2 new phases** — `retro` (owner: bubbles.retro) and `code-review` (owner: bubbles.code-review) added to the phase registry in workflows.yaml
- **3 new recipes** — `retro-driven-simplify.md`, `retro-driven-harden.md`, `retro-driven-review.md` with workflow diagrams, decision tables, and related recipe links
- **Recipe Catalog** — new `docs/CATALOG.md` providing a numbered index of all 38 recipes with mode/agent mappings, category groupings, and a decision tree for choosing the right recipe
- **README updated** — added Recipe Catalog link to nav bar, updated mode count to 33
- **New Sunnyvale aliases** — `sunnyvale liquor-then-tape` (retro-to-simplify), `sunnyvale liquor-then-harden` (retro-to-harden), `sunnyvale liquor-then-look` (retro-to-review)
- **New Rickyisms** — "Liquor then tape", "Liquor then harden", "Liquor then look"
- **New vocabulary** — Data-driven workflow terms added to CHEATSHEET.md and HTML cheatsheet
- **Framework stats updated** — 30→33 workflow modes, 23→25 phases across all docs and badges
- **Super agent updated** — new intent resolution entries, workflow mode advisor row, and v3.3 awareness for data-driven modes
- **Recipes README** — new "Data-Driven Workflows (Retro → Action)" section, code-health-analysis moved there
- **iterate supportedModes** — 3 new modes added to iterate's mode pool

### Deep Code Hotspot Analysis — Retro Agent Enhancement (v3.3)

- **Bug-fix density mapping** — `bubbles.retro` now classifies commits as bug-fix vs feature and surfaces files with highest bug-fix ratio ("bug magnets" — files where >50% of commits are fixes)
- **Co-change coupling detection** — Computes a co-change matrix from git history to find files that always change together, especially cross-directory pairs revealing hidden architectural dependencies
- **Author concentration (bus factor)** — Reports single-author risk per high-churn file. Files with bus factor = 1 are knowledge silos
- **Churn trend analysis** — Compares current hotspots against prior retro data to show stabilizing, worsening, new, and resolved hotspots
- **Recommended actions** — Retro output now includes a "Recommended Actions" section with targeted follow-up commands (`/bubbles.simplify` for bug magnets, `/bubbles.code-review` for coupling, `/bubbles.harden` for worsening hotspots)
- **Focused retro modes** — New sub-commands: `hotspots` (deep hotspot-only analysis), `coupling` (co-change coupling only), `busfactor` (author concentration only). All support time-bounding: `hotspots week`, `hotspots month`
- **New Sunnyvale aliases** — `sunnyvale wheres-the-bodies` (retro hotspots), `sunnyvale whos-driving` (retro busfactor), `sunnyvale tangled-up` (retro coupling)
- **New Rickyisms** — "Where the bodies are buried" (deep hotspot analysis), "All tangled up like Christmas lights" (co-change coupling), "Somebody's gotta drive" (bus factor)
- **New Fun Mode messages** — Deep hotspot analysis, co-change coupling detected, bus factor risk, bug magnet file, hotspot stabilizing, hotspot worsening
- **Super agent v3.3 awareness** — Updated intent resolution, decision flow, and Tag Selection Matrix with hotspot-related entries
- **New recipe** — `code-health-analysis.md` — data-driven refactoring workflow using retro hotspot analysis
- **Updated recipe** — `retro.md` expanded with new commands, output descriptions, and "Acting On Findings" section
- **Docs updated** — CHEATSHEET.md, HTML cheatsheet, AGENT_MANUAL.md, recipes/README.md all updated with new capabilities

### Universal Entry Point — Workflow as Single Front Door (v3.3)

- **Phase -1: Intent Resolution** — `bubbles.workflow` now accepts ANY input (vague natural language, continuation requests, framework ops, or structured parameters). A new Phase -1 classifies input into 4 buckets (STRUCTURED, VAGUE, CONTINUE, FRAMEWORK) and delegates to the appropriate agent via `runSubagent`:
  - VAGUE → invokes `bubbles.super` for NLP intent resolution (returns RESOLUTION-ENVELOPE)
  - CONTINUE → invokes `bubbles.iterate` for work discovery (returns WORK-ENVELOPE)
  - FRAMEWORK → invokes `bubbles.super` for framework operation execution (returns FRAMEWORK-ENVELOPE)
  - STRUCTURED → skips Phase -1 entirely (existing behavior unchanged)
- **RESOLUTION-ENVELOPE** — New subagent response contract for `bubbles.super`. When invoked via `runSubagent`, super returns machine-readable `{ mode, specTargets, tags, confidence }` instead of user-facing slash commands. Direct user invocation behavior unchanged.
- **WORK-ENVELOPE** — New subagent picker contract for `bubbles.iterate`. When invoked via `runSubagent` in picker mode, iterate returns `{ spec, scope, mode, workType, priority }` without executing work. Direct user invocation behavior unchanged.
- **FRAMEWORK-ENVELOPE** — New subagent response contract for `bubbles.super` framework operations. Returns `{ operation, result, status }` for doctor, hooks, upgrade, metrics, etc.
- **Iterate NLP delegation** — `bubbles.iterate` now delegates to `bubbles.super` when free-text input cannot be resolved by iterate's own Natural Language Input Resolution table. Zero logic duplication — super is the single NLP resolver.
- **Handoff additions** — Added `bubbles.super` as handoff target for both `bubbles.workflow` (Intent Resolution, Framework Operations) and `bubbles.iterate` (Intent Resolution). Added `bubbles.iterate` as handoff target for `bubbles.workflow` (Work Discovery).
- All existing modes, phases, gates, specialist dispatch, and direct agent invocation remain unchanged.

### Docs, Prefix Rule, G068 Issue (v3.3)

- **Command prefix rule strengthened** — The `/` slash prefix rule for agent commands is now NON-NEGOTIABLE in `agent-common.md` and explicitly added to `bubbles.recap`, `bubbles.handoff`, and `bubbles.status` agents. All agents generating next-step commands or continuation options MUST use `/bubbles.*`, never `@bubbles.*`.
- **Workflow emphasized as universal entry point** across all docs:
  - CHEATSHEET.md: workflow card updated, "Starting a Job" table reordered, natural language section rewritten, new vocabulary entries ("Just tell Bubbles", "Bubbles figures it out")
  - HTML cheatsheet: workflow card, iterate card, vocabulary, Rickyisms updated, version bumped to v3.2
  - WORKFLOW_MODES.md: new "Workflow Is The Universal Entry Point" section with examples
  - AGENT_MANUAL.md: workflow promoted to "Start Here First" with usage examples
  - Recipes: new `just-tell-bubbles.md` recipe, updated `ask-the-super-first.md` with v3.2 note, updated `resume-work.md` with "continue" shortcut
- **G068 issue filed** — `docs/issues/G068-word-overlap-threshold.md` documents the false-positive matching problem where `stg_significant_words` exclusion list and 3-word overlap threshold prevent legitimate DoD items from matching their source Gherkin scenarios. Proposes lowering min word length from 4→3, reducing exclusion list, and considering percentage-based thresholds.

### Learning & Personalization (v3.2)

- **Skill Evolution Loop** — Closed-loop learning from `lessons.md`. When the same problem pattern occurs 3+ times, the framework generates a skill proposal in `.specify/memory/skill-proposals.md`. User approves, `bubbles.create-skill` scaffolds the SKILL.md. Configured in `workflows.yaml` → `skillEvolution:`.
- **Developer Profile (Observation-Driven)** — Dynamically tracks developer preferences from measurable activity: git diffs, taste decisions, workflow mode choices, post-agent code edits, scope sizing patterns. Patterns promoted to profile after ≥3 observations. Feeds `decisionPolicy` for taste-decision auto-resolution. Fresh/aging/stale/contradicted confidence tiers prevent staleness. Never auto-applied — always user-visible.
- **Activity Tracking (Measurable Only)** — Extended `metrics` with `activityTracking:` for per-agent/per-spec/per-scope metrics. Tracks only what is measurable: invocation count, phase duration, retry count, gate pass/fail rate, scope completion time, lines changed. Explicitly does NOT track dollar costs or token counts (not exposed by platform).
- **Brainstorm Mode** — New workflow mode for exploratory thinking before implementation. Runs `analyze → bootstrap → harden → finalize` with `statusCeiling: specs_hardened`. Socratic mode on by default. Outputs spec/design/scopes artifacts with zero code written. Like YC office hours for features.
- **Parallel Scope Execution** — New opt-in execution tag `parallelScopes: dag|dag-dry` for concurrent scope execution via git worktrees. DAG-independent scopes (no mutual dependencies) run in parallel, dependent scopes wait. `maxParallelScopes: 2-4`. Off by default — sequential execution remains the safe default.
- **Agent Activity Dashboard** — `bubbles.status` now shows per-agent invocation table, active execution chain visualization, and measurable activity metrics when tracking is enabled.
- Updated `bubbles.super` with v3.2 capability awareness: brainstorm mode, skill evolution, developer profile, activity tracking, parallel scopes. New CLI commands: `skill-proposals`, `profile`, `profile --stale`, `profile --clear-stale`.
- New recipes: `brainstorm-idea.md`, `parallel-scopes.md`.
- Updated HTML cheatsheet, CHEATSHEET.md, WORKFLOW_MODES.md, and recipes README with new features, Rickyisms, and TPB vocabulary.
- New Rickyisms: "Let me think about it over a couple smokes" (brainstorm), "Get two birds stoned at once" (parallel scopes), "The park knows what you like" (developer profile), "Same greasy mistake three times" (skill evolution), "Count the empties, Randy" (activity tracking).

### DevOps Execution Lane

- Added `bubbles.devops` as a new execution owner for CI/CD, build, deployment, monitoring, observability, and release automation work.
- Kept `bubbles.stabilize` diagnostic and routed operational execution through `bubbles.devops` across workflow control-plane registries and iterate/review dispatch tables.
- Added `devops-to-doc` workflow mode and inserted the `devops` phase into delivery and hardening paths that already pass through operational stabilization.
- Updated README, cheat sheets, HTML roster, workflow docs, agent manual, and recipes to reflect the new DevOps lane.

### Control Plane v3.0 — Registry-Driven Delegation, Validate-Owned Certification, and Scenario Contracts

Major architectural evolution implementing the unified control-plane design across the entire framework:

**New registries and schemas:**
- `bubbles/agent-capabilities.yaml` — Machine-readable agent class, phase ownership, artifact ownership, user-interaction permissions, and execution/certification write authority for all 33 agents.
- `bubbles/agent-ownership.yaml` v2 — Extended with `state.json` ownership (validate-owned), `scenario-manifest.json`, `lockdown-approvals.json`, `invalidation-ledger.json`, `transition-requests.json`, `rework-queue.json` ownership blocks, certified field declarations, and expanded routing rules.
- `.specify/memory/bubbles.config.json` v2 — Central execution policy registry with defaults for grill, TDD, auto-commit, lockdown, regression immutability, and validation certification. Mode overrides for `bugfix-fastlane` and `chaos-hardening`. Managed by `bubbles policy` CLI.

**New gates (G054–G064):**
- `G054 capability_delegation_gate` — Foreign-owned work must route through registered specialist.
- `G055 policy_provenance_gate` — Active modes must record value plus source provenance.
- `G056 validate_certification_gate` — Only validate may certify promotion state.
- `G057 scenario_manifest_gate` — Changed behavior must map to stable scenario IDs and live tests.
- `G058 lockdown_gate` — Locked scenarios require grill approval and invalidation.
- `G059 regression_contract_gate` — Protected regression tests cannot drift without scenario invalidation.
- `G060 scenario_tdd_gate` — Targeted failing proof required before green certification when TDD active.
- `G061 rework_packet_gate` — Route-required findings must produce structured packets.
- `G062 owner_only_remediation_gate` — Only owning planning/execution specialists may remediate owned surfaces; diagnostics and certification must route.
- `G063 concrete_result_gate` — Every agent invocation must finish with a concrete result shape rather than narrative-only findings.
- `G064 child_workflow_depth_gate` — Only orchestrators may invoke child workflows, and workflow nesting depth is bounded.

**State model v3:**
- `state.json` version 3 with `execution.*` (runtime claims) and `certification.*` (validate-owned authority) split. Top-level `status` mirrors `certification.status`.
- `policySnapshot` records effective grill/TDD/auto-commit/lockdown/regression/validation settings with provenance per run.
- `transitionRequests` and `reworkQueue` for structured specialist-to-validate routing.
- `scenario-manifest.json` template with stable `SCN-*` IDs, Gherkin hashes, linked tests, evidence refs, lockdown/regression flags.

**Guard script updates:**
- `state-transition-guard.sh` — New checks: 3A (policy provenance G055), 3B (certification state G056), 3C (scenario manifest G057), 3D (lockdown/regression G058/G059), 3E (TDD evidence G060), 3F (transition/rework closure G061), 3G (framework ownership/result contract integrity G062/G063/G064). Revert logic clears `certifiedCompletedPhases`, `completedPhaseClaims`, and legacy `completedPhases`.
- `state-transition-guard-selftest.sh` — Creates temporary docs-only fixtures to exercise the real promotion guard, including a positive path, a negative packet-field path for G063, and an illegal child-workflow caller path for G064.
- `artifact-lint.sh` — v3 schema validation with `execution`/`certification`/`policySnapshot` required fields. Backward-compatible v2 fallback. Nested array extraction for certification-scoped `completedScopes` and `certifiedCompletedPhases`.
- `spec-dashboard.sh` — Prefers `certification.status` and `certification.completedScopes` when present.
- `traceability-guard.sh` — Scenario manifest cross-check (G057/G059): verifies scope-defined Gherkin scenarios map to manifest entries with linked tests and evidence refs.
- `agent-ownership-lint.sh` — Extended to validate `agent-capabilities.yaml`, `state.json` ownership, `scenario-manifest.json` ownership, `certificationWriter`, orchestrator-only child workflows, and RESULT-ENVELOPE coverage across primary prompt surfaces.

**CLI:**
- `bubbles policy status|get|set|reset` — Manage control-plane defaults and provenance from the CLI.

**Prompt migrations (all 33 agents updated where applicable):**
- Orchestrators (workflow, iterate, bug) updated to use `execution.currentPhase`/`certification.status` split and route final closure through validate.
- Planning agents (analyst, ux, design, plan, security) updated to use v3 state template and execution-only metadata writes.
- Execution agents (implement, test, docs, chaos) record `execution.completedPhaseClaims` only; never write `certification.*`.
- Diagnostic agents (harden, gaps, regression) reference `certification.completedScopes` and `execution.completedPhaseClaims` coherence.
- `bubbles.validate` updated with validate-owned certification checks (items 2–9), policy provenance, scenario contract, and transition/rework closure.
- `bubbles.audit` references execution/certification phase records.
- `bubbles.grill` updated for `grillMode` (off/on-demand/required-on-ambiguity/required-for-lockdown).
- `bubbles.super` updated with `grillMode`/`tdd`/`backlogExport` control-plane tags.
- `bubbles.super` front-door policy is now explicit: use it for vague intent and prompt translation, but bypass it when the exact specialist or workflow mode is already known.

**Workflow mode updates:**
- Added `full-delivery` convergence loop — a maximum-assurance workflow mode that repeats the full improvement and certification chain until validate can legitimately certify `done` or records an explicit blocker. Supports optional `improvementPrelude` and `improvementPreludeRounds` tags for bounded analyst/UX/design/plan refresh passes ahead of implementation rounds.
- Added `specReview: once-before-implement` — a one-shot execution tag that runs `bubbles.spec-review` before legacy implementation/improvement work so stale or redundant active specs are reconciled once instead of rediscovered every retry round. `improve-existing`, `reconcile-to-doc`, `redesign-existing`, and `full-delivery` now default this hook on.
- `bugfix-fastlane` and `chaos-hardening` now force `scenario-first` TDD by default (`forceTddMode: scenario-first`).
- `chaos-hardening` now lockdown-aware with `requireProtectedRegressionContracts`.
- `grillFirst` tag deprecated in favor of `grillMode` with `inherit` default.
- New `lockdown` optional tag with values: `inherit|off|protect-existing-scenarios|require-approval`.
- `defaultPolicyBehavior` and `policyRegistry` sections added to `executionOptions`.
- G054–G064 wired into delivery enforcement, with G062/G063/G064 enforced by framework lint and promotion-time guard checks.

**Shared governance docs:**
- `feature-templates.md` — v3 state.json template, scenario-manifest.json template, policySnapshot structure.
- `scope-templates.md` — v3 state snippet, scenario contract evidence sections.
- `scope-workflow.md` — Execution/certification split, validate-owned finalize, phase recording responsibility, status ceiling examples updated.
- `completion-governance.md`, `state-gates.md`, `quality-gates.md` — Updated for v3 field names.
- `project-config-contract.md` — Anti-fabrication checklist updated for certification-owned fields.

**Skills and instructions:**
- `bubbles-agents.instructions.md` — Control Plane Requirements section added.
- `bubbles-skills.instructions.md` — Skill-level control-plane guidance.
- `bubbles-skill-authoring/SKILL.md` — References control-plane artifacts.
- `bubbles-spec-template-bdd/SKILL.md` — Stable `SCN-*` scenario contract readiness.
- `bubbles-test-integrity/SKILL.md` — Durable scenario contracts and live-test linkage.

**Docs and cheat sheets:**
- `docs/guides/CONTROL_PLANE_DESIGN.md` — Full architecture design document.
- `docs/guides/CONTROL_PLANE_ROLLOUT.md` — Phased rollout plan mapping all 11 requested changes.
- `docs/guides/CONTROL_PLANE_SCHEMAS.md` — Schema definitions for all 8 control-plane surfaces.
- `docs/CHEATSHEET.md` — Updated to 64 gates, no-hybrid control-plane law summary, and public-facing owner/executor vs diagnostic/certification taxonomy.
- `docs/its-not-rocket-appliances.html` — v3.0, now updated through the DevOps lane expansion to 33 agents, 64 gates, 29 modes, and 20 phases. Control Plane Quick Rules, public taxonomy, and Sunnyvale vocabulary updated.
- All recipes updated from `grillFirst` to `grillMode`.

**Install system:**
- `install.sh` now installs `agent-ownership.yaml` and `agent-capabilities.yaml` alongside `workflows.yaml`.
- Bootstrap scaffolds `.specify/memory/bubbles.config.json` from the Bubbles source.
- Framework manifest includes YAML registry files.

- Added `bubbles-test-integrity` portable skill — Trinity's field manual for making sure tests are real, not greasy shortcuts. Consolidates Gherkin scenario coverage, anti-mock scans, anti-false-positive scans, assertion audits, and Test Plan↔DoD parity checks into one actionable checklist. Activates on any test work.
- Added artifact-freshness reconciliation as a first-class planning rule: analyst, UX, design, and plan now reconcile stale active content and isolate superseded material instead of leaving conflicting truths active.
- Added `artifact-freshness-guard.sh` plus Gate `G052` so superseded sections are mechanically isolated from active truth, superseded scope appendices cannot keep executable status/Test Plan/DoD structure, and per-scope directory drift is blocked when `scopes/_index.md`, on-disk `scopes/NN-*`, and `state.json.scopeProgress.scopeDir` fall out of sync.
- Added explicit existing-feature redesign support: new `redesign-existing` workflow mode, new `same-lot-new-trailer` Sunnyvale alias, and updated docs/recipes for reconcile vs improve vs redesign decisions.
- Strengthened planning validation profiles to check active-requirement, active-UX, active-design, and active-scope reconciliation.
- Added machine-readable `## ROUTE-REQUIRED` orchestration blocks to `bubbles.validate` and `bubbles.audit`, then promoted `## RESULT-ENVELOPE` to the primary workflow contract and kept the legacy block as compatibility fallback during migration.
- Fixed `done-spec-audit.sh` so it resolves installed-project repo roots correctly, rejects running outside repos with `specs/`, and fails closed on suspicious zero-done-spec scans.
- Added `bubbles/scripts/agnosticity-lint.sh` and a shipped allowlist file so portable Bubbles surfaces are mechanically checked for project-specific and concrete-tool drift.
- Wired agnosticity checks into the Bubbles CLI, doctor output, generated git hooks, installer payload, and GitHub Actions.
- Generalized remaining shared prompt, workflow, and governance references that still named concrete projects or browser automation tools.

## v2.3.0 — 2026-03-23

### New Gates: G047, G048, G049, G050, G051 — Systemic Pattern Prevention

Five new gates addressing systemic vulnerability and quality patterns discovered across multiple specs:

- **G047** (`idor_auth_bypass_gate`) — BLOCKING. Detects handlers extracting user/org/tenant identity from request body instead of auth context (JWT/session/middleware). Prevents IDOR vulnerabilities (OWASP A01). Enforced by `implementation-reality-scan.sh` Scan 7 and `bubbles.security` Phase 3.2.
- **G048** (`silent_decode_failure_gate`) — BLOCKING. Detects code that silently discards deserialization/decode errors (`if let Ok()`, `filter_map(.ok())`, `unwrap_or_default()` on decode). Prevents data corruption from going undetected. Enforced by `implementation-reality-scan.sh` Scan 8.
- **G049** (`evidence_clone_detection_gate`) — BLOCKING. Detects copy-pasted evidence where ≥80% of lines are shared across different DoD items. Strengthens G021 anti-fabrication. Enforced by `state-transition-guard.sh` Check 20.
- **G050** (`gateway_route_forwarding_gate`) — BLOCKING. Ensures every backend endpoint has a corresponding gateway/proxy forwarding rule. Prevents unreachable endpoints. Strengthens G035 vertical slice gate.
- **G051** (`test_env_dependency_gate`) — BLOCKING. Detects test failures caused by missing environment variables. Prevents pre-existing env-dependent test failures from persisting. Enforced by `state-transition-guard.sh` Check 19.

### Pluggable Scan Pattern System (`.github/bubbles-project.yaml`)

All new scan patterns (G047, G048, G051) are **project-configurable** via `.github/bubbles-project.yaml`. Projects can override or extend detection patterns without modifying Bubbles core:

```yaml
scans:
  idor:
    bodyIdentityPatterns: [...]
    authContextPatterns: '...'
    handlerFilePatterns: '...'
  silentDecode:
    patterns: [...]
    errorHandling: '...'
  testEnvDependency:
    patterns: '...'
```

When no project config exists, sensible generic defaults apply across all languages.

### Updated Files

- **`workflows.yaml`** — 5 new gate definitions (project-agnostic). Added to 6 delivery modes + `inheritedRequiredGates` + phase-level gates.
- **`implementation-reality-scan.sh`** — Scan 7 (IDOR) and Scan 8 (silent decode) load patterns from `bubbles-project.yaml` with generic fallbacks. Language-specific patterns removed from core.
- **`state-transition-guard.sh`** — Check 19 (env dependency) loads extra patterns from `bubbles-project.yaml`. Check 20 (evidence similarity) added.
- **`bubbles.security.agent.md`** — Phase 3.2 and 3.6 reference mechanical scan enforcement rather than hardcoding language-specific grep patterns. OWASP mapping updated.
- **`bubbles.audit.agent.md`** — Checklist expanded with G047-G051 rows. Quick scans delegate to `implementation-reality-scan.sh`.
- **`project-config-contract.md`** — New section documenting `bubbles-project.yaml` scan extension interface.
- **`project-scan-setup.sh`** — NEW. Auto-detects project languages, auth patterns, serialization, handler dirs, and test env dependencies. Generates `bubbles-project.yaml` with project-appropriate scan patterns.
- **`cli.sh`** — New `bubbles project setup [--dry-run]` subcommand invoking `project-scan-setup.sh`.
- **`install.sh`** — Bootstrap scaffolds `bubbles-project.yaml` template. Post-bootstrap output recommends `bubbles project setup`.
- **`bubbles.setup.agent.md`** — Post-apply validation checks for `bubbles-project.yaml`. Recommends `bubbles project setup` when scan config is missing.

---

## v2.2.0 — 2026-03-23

### New Agent: `bubbles.regression` (Steve French)

Cross-feature regression guardian. Detects test baseline regressions, cross-spec interference, design contradictions, and coverage decreases after implementation or bug fixes.

- **Character:** Steve French (the mountain lion from Trailer Park Boys)
- **Signature:** *"Something's prowlin' around in the code, boys."*
- **Icon:** `steve-french-paw.svg` — a paw print with claw marks (regression scratches)
- **Phase:** `regression` — runs after `test`, before `simplify`
- **Role:** Diagnostic agent (read-only for artifacts, routes fixes to specialists)

### New Gates: G044, G045, G046

- **G044** (`regression_baseline_gate`) — Test baseline snapshot before/after implementation. Previously-passing tests must still pass. Enforced by `regression-baseline-guard.sh`.
- **G045** (`cross_spec_regression_gate`) — Tests from already-done specs re-executed after changes. Catches cross-feature interference (e.g., spec N breaking spec M).
- **G046** (`spec_conflict_detection_gate`) — Route/endpoint collisions, shared table mutations, contradictory business rules scanned across all specs before implementation.

### Post-Implementation Hardening (Mandatory)

All delivery modes now include a mandatory hardening sequence after `test`:

```
implement → test → regression → simplify → stabilize → security → docs → ...
```

**Updated modes:** `full-delivery`, `full-delivery-strict`, `bugfix-fastlane`, `feature-bootstrap`, `value-first-e2e-batch`, `chaos-hardening`, `product-to-delivery`, `harden-to-doc`, `gaps-to-doc`, `harden-gaps-to-doc`, `reconcile-to-doc`, `stabilize-to-doc`, `improve-existing`, `stochastic-quality-sweep`, `iterate`

Previously, `simplify`, `stabilize`, and `security` were only in specialized modes. Now they run on every delivery.

### New Governance Script

- `regression-baseline-guard.sh` — Mechanical enforcement for G044/G045/G046. Checks test baseline existence, cross-spec inventory, and route collision detection.

### New Recipes

- **[Regression Check](docs/recipes/regression-check.md)** — How to verify new changes didn't break existing features
- **[Post-Implementation Hardening](docs/recipes/post-impl-hardening.md)** — The mandatory hardening sequence explained

### Infrastructure

- `bubbles.regression` added to `agent-ownership.yaml` as diagnostic agent
- `regression` trigger added to `stochastic-quality-sweep` trigger pool
- `regression` fix cycle: `bootstrap → implement → test → validate → audit`
- `e2e-regression.md` expanded with cross-spec regression rules (G044-G046)
- Fun mode messages for regression events (Steve French purring, prowling)
- 29 agents, 45 gates, 18 phases total

### Character & Quote Improvements

- **system-review:** Private Dancer → **Orangie** (the goldfish who sees everything from the fishbowl)
  - New icon: `orangie-fishbowl.svg`
  - Quote: *"Orangie sees everything. He's not dead, he's just... reviewing."*
- **iterate/Jacob:** *"I'll do whatever you need, Julian."* (was: "I can help with that.")
- **ux/Lucy:** *"You can't just slap things together and call it a home, Ricky."* (was: generic)
- **bug/Cory:** *"I didn't wanna find it, but... there it is."* (was: "I found the thing that's busted.")
- **simplify/Donny:** *"Just tape it up and move on."* (was: "Have another drink, Ray!")
- **handoff/Trevor:** *"Here, take this. I gotta go."* (was: "Cory, take this to Julian.")
- **create-skill/Sam:** *"I used to be a vet, you know. I got specialties."* (was: generic)

### Complete Alias Coverage

- 36 agent aliases (every agent has at least one `sunnyvale` alias)
- 24 workflow mode aliases (every mode has a `sunnyvale` alias)
- New agent aliases: the-super, i-got-work-to-do, not-how-that-works, lets-get-organized, whats-going-on-here, parts-unknown, whole-show, nice-kitty, just-fixes, pave-your-cave, jim-needs-a-plan, used-to-be-a-vet, true, ill-do-whatever, cant-just-slap
- New mode aliases: shit-winds-coming, gut-feeling, survival-of-the-fitness, i-toad-a-so, bill-fixes-it, open-and-shut, just-watching, smokes-and-setup, keep-going, resume-the-tape, whats-the-big-idea, harden-up, we-broke-it

### Icon Improvements

- `steve-french-paw.svg` — proper 4-toe cat paw anatomy
- `lucy-mirror.svg` — simplified to single hand mirror with sparkle
- `donny-ducttape.svg` — added torn edge zigzag detail
- `orangie-fishbowl.svg` — new icon for system-review (fishbowl with fish and bubbles)

---

## v2.1.0 — 2026-03-19

### New Gate: G040 — Zero Deferral Language

Agents were writing deferral language ("deferred to future scope", "out of scope", "will address later") into DoD items and then marking specs as "done". This is now mechanically blocked.

- **Gate G040** (`zero_deferral_language_gate`) — state-transition-guard.sh Check 18 scans scope and report artifacts for deferral language patterns and BLOCKS promotion to "done" if found
- Added to `inheritedRequiredGates` (applies to ALL delivery modes)
- Deferral scan added to Tier 2 validation tables in: `bubbles.implement` (I5), `bubbles.iterate` (IT6), `bubbles.workflow` (W5), `bubbles.audit` (A7), `bubbles.harden` (H10)
- Rule 2 (Scope Cannot Be Done) and Rule 3 (Spec Cannot Be Done) in agent-common.md updated to explicitly block on deferral language
- Zero Deferral Policy expanded with FABRICATED COMPLETION declaration
- critical-requirements.md "No TODO Debt" expanded with deferral pattern list
- scope-workflow.md Status Transition Gate and Spec Completion sections updated
- 40 gates total (up from 39)

---

## v2.0.0 — 2026-03-17

Major reorganization and new features. Prefix-based file ownership, per-scope git commits, self-healing loops, framework operations agent, and more.

### Breaking Changes

- `agents/_shared/` → `agents/bubbles_shared/` (all internal references updated)
- `scripts/bubbles*.sh` → `bubbles/scripts/*.sh` (scripts consolidated under `bubbles/` folder, `bubbles-` prefix dropped)
- `scripts/bubbles.sh` → `bubbles/scripts/cli.sh` (main CLI moved)
- Generated docs moved from `.github/docs/BUBBLES_*.md` to `.github/bubbles/docs/`
- `autoCommit` changed from boolean to enum: `off|scope|dod`

### New Features

- **`bubbles.super` agent** (26th agent) — first-touch assistant for framework operations, commands, prompts, setup, upgrades, metrics, custom gates, lessons, and diagnostics
- **Self-healing loop protocol (G039)** — bounded, non-stacking fix loops with maxDepth=1, context narrowing, retry budgets
- **Atomic git commits** — `autoCommit: scope|dod` creates structured commits after validated milestones
- **Lessons-learned memory** — `.specify/memory/lessons.md` with auto-compaction at workflow start when >150 lines
- **Git hooks system** — built-in hook catalog + custom hooks, `hooks.json` registry, `bubbles hooks install/add/remove/run/status`
- **Custom gates** — project-defined quality gates via `.github/bubbles-project.yaml`, auto-discovered by state transition guard
- **Doctor command** — `bubbles doctor [--heal]` validates installation health with 11 checks and auto-fix
- **Scope DAG visualization** — `bubbles dag <spec>` outputs Mermaid dependency diagram
- **Metrics dashboard** — optional, off by default. JSONL event logging for gate failures, phase durations, agent invocations
- **Upgrade command** — `bubbles upgrade [version]` with migration, generated doc regeneration, and staleness recommendations
- **Status --explain** — `bubbles.status --explain` for narrative progress summaries
- **Spec examples gallery** — `docs/examples/` with annotated reference specs for REST API endpoints and bug fixes

### Infrastructure

- Prefix-based file ownership model: `bubbles.` prefix = Bubbles-owned (overwritten on upgrade), everything else = project-owned (never touched)
- Install.sh migration logic for pre-v2 → v2 path transitions
- `bubbles-project.yaml` for project-local extensions (custom gates) without modifying workflows.yaml
- `hooks.json` for hook registry management
- Fun mode aliases for new super agent

## v1.0.0 — 2026-03-17

Initial release. Rebranded from the Ralph agent system.

### What's Included

- **25 agents** — bubbles.workflow through bubbles.bug
- **25 prompt shims** — routing files for VS Code Copilot Chat
- **7 shared governance docs** — agent-common, scope-workflow, templates, etc.
- **9 governance scripts** — artifact lint, state transition guard, etc.
- **1 workflow config** — 23 modes, 33 gates, complete phase definitions
- **23 SVG icons** — one per agent character
- **install.sh** — one-line installer for any repo
- **Documentation** — agent manual, workflow guide, 10 recipes, visual cheatsheet
