# Changelog

## Versioning Scheme

Bubbles uses **MAJOR.MINOR.PATCH** (semver-style):

| Part | When to bump | Who bumps | Examples |
|------|-------------|-----------|----------|
| **PATCH** (3rd) | Every commit — auto-bumped by pre-commit hook | Hook (automatic) | Policy tweaks, doc fixes, skill updates, script fixes, single-gate additions |
| **MINOR** (2nd) | New capabilities, new agents, new gates, new workflow modes, structural changes to governance | Manual (`echo X.Y.0 > VERSION` before commit) | New agent added, new workflow mode, new gate family, taxonomy expansion |
| **MAJOR** (1st) | Breaking changes to installer, state.json schema, agent protocol, or downstream contract | Manual (`echo X.0.0 > VERSION` before commit) | state.json v3→v4, installer flag removal, agent handoff protocol change |

The pre-commit hook auto-increments PATCH on every commit. To bump MINOR or MAJOR, manually set the VERSION file before committing — the hook will then increment PATCH from the new base.

## [Unreleased]

### IMP-018 + IMP-019 packets finalized (deliver-then-delete cleanup)

- `macos-portability-guard.sh` + its hermetic selftest (the 13-class GNU/BSD
  pitfall lint — helper-aware, `# portable-ok:` pragma, caller-supplied surface,
  wired into `framework-validate`) shipped earlier and is green under
  framework-validate; the IMP-018 proposal packet is now removed per the
  deliver-then-delete improvements lifecycle (durable record: the shipped guard
  + selftest + this entry).
- IMP-019 (direct authorized workflow runners, shipped v7.19.0–v7.19.2) packet
  is likewise removed; its durable record is the v7.19.x entries below and the
  shipped control-plane/routing changes.

### IMP-023 Artifact-Writer Shared-State Guard + Structured Refusal (SCOPE-3/5/7)

- **Parent-owned shared-state guard (`runtime writer-guard`).**
  `bubbles/scripts/runtime-leases.sh` gains a `writer-guard` subcommand that
  mechanizes the IMP-004 SCOPE-2 contract: a child scope (`--role child`, the
  default) is refused when it writes a parent-owned `state.json` /
  `scenario-manifest.json` / `spec.md` / `design.md` or another scope's
  `scopes/<id>/report.md`, and is allowed to write its own report/scope/source/
  tests; a `--role parent` orchestrator may write shared state. Reuses the
  existing lease store, `slugify`, and lookup — no new lease system.
- **Structured `blocked` refusal envelope (SCOPE-5).** Both the writer-acquire
  conflict path and the writer-guard refusal now emit one machine-parseable
  `writer-lease-refusal result=blocked reason=... route=... remediation=...`
  line to stderr naming the owner, alongside the human sentence. The framework
  never "reconciles" two live writers by appending evidence (the Feature-010
  anti-pattern).
- **IMP-004 SCOPE-2 amendment (SCOPE-7).** IMP-004 SCOPE-2 is amended in place to
  cross-reference this lease + guard as its enforcement mechanism; IMP-004 keeps
  the documented contract, IMP-023 owns the mechanism.

Backed this session by the extended `runtime-lease-selftest.sh` (six new
writer-guard/envelope cases, all cases pass), a regenerated
`bubbles/release-manifest.json`, and green `framework-validate`. This entry does
not assert downstream upgrade, consumer byte parity, certification, or the
deferred SCOPE-6 deep agent-wiring increment.

### IMP-025 Multi-Root Repo-Binding Marker Stamping (SCOPE-5)

- **Installer stamps the repo-binding marker.** `install.sh` now writes a
  repo-relative `targetRepoSlug` into `.github/bubbles/.install-source.json`
  (derived by the SAME slug logic as the per-repo MCP server id), so
  `repo-binding-preflight.sh` resolves it and ENFORCES agent↔repo binding
  (exit 1 on a foreign workspace-root agent) instead of staying advisory. No
  per-machine absolute path is committed — the marker is a repo-relative slug.
- **Count-agnostic provenance invariant.** The installer-manifest I5 invariant
  is renamed `provenance_records_required_fields` and derives its field count,
  so adding a provenance field never again requires renaming the gate.
- Backed by the extended `install-provenance-selftest.sh` (stamps the marker;
  the freshly installed fixture's preflight resolves it and refuses a foreign
  agent-source) plus the generate-installer and repo-binding-preflight
  selftests, all green under `framework-validate`. This entry does not assert
  downstream upgrade or the deferred SCOPE-2/3/4/6 wiring.

### BUG-013 Semantic Sensitive Client Storage Classification

- **Operation-aware G028 Scan 2B.** Sensitive client storage is classified from
  storage operations, bounded immutable key aliases, credential-shaped values,
  and scrub state rather than physical-line word co-occurrence. Durable
  credential access remains blocking, while comments, noncredential caches,
  remove/clear operations, and proven all-field scrubbed rewrites do not become
  persistence findings.
- **One closed session credential classification.** Project config can classify
  one exact repo-relative path, `sessionStorage` key, and provider only as
  `third-party-market-data`, `low`, and `same-tab`. Unknown/dynamic providers,
  durable storage, high-trust auth/session/payment classes, wildcards,
  traversal, duplicates, malformed config, and unavailable parsing fail closed.
- **Portable managed validation.** The managed selftest uses
  `bubbles_run_with_timeout`, exercises the no-`timeout`/no-`gtimeout` watchdog
  path with exit `124`, and the source-only BUG-013 regression preserves every
  semantic adversarial pair through the production scanner.

The source behavior above is backed by the current-session managed selftest,
sanitized macOS-path run, `57 passed, 0 failed` persistent regression, and
regression-integrity guard. This entry does not assert downstream upgrade,
consumer byte parity, certification, or BUG-013 closure.

### BUG-012 G085 First-Adoption Classification

- **Two explicit downstream pass paths.** G085 retains the current-done fast
  path and now admits a genuine first adoption only when current numbered
  states exist, current done is zero, complete local Git history is proven,
  and no numbered top-level done-state blob is reachable from any local ref.
- **Established evidence remains durable.** A prior done state that was changed
  or deleted still blocks bootstrap re-entry with its commit and path, while
  state payloads remain private.
- **Unknown history fails closed.** Missing or nested Git roots, shallow or
  partial repositories, failed object traversal, and malformed current or
  historical state receive distinct integrity diagnostics. No mutable adoption
  marker, install timestamp, network lookup, cache, or bypass was introduced.

The source behavior above is backed by the current-session `71 passed, 0
failed` production-guard selftest, `16 passed, 0 failed` persistent adversarial
regression, touched-shell portability scan, and regression-quality guard. This
entry does not assert downstream installation, independent test-owner
verification, certification, or BUG-012 closure.

### BFW-01..05 Framework-improvement primitives (IMP-021..025)

Five reuse-first framework primitives, each shipped as a self-contained script
plus a hermetic selftest wired into `framework-validate`:

- **BFW-01 / IMP-021 — risk-tier resolver.** `risk-tier-resolve.sh` classifies a
  delivery surface as `rapid-tool-delivery` or `full-delivery`, fail-closed:
  rapid only on a positive low-risk signal with no high-risk trigger (auth,
  payment, secret, PII, DB migration, deploy/infra, cross-product proto).
  Reuses the G128 budget vocabulary; registers no new mode.
- **BFW-02 / IMP-022 — vertical-delivery plan guard.**
  `vertical-delivery-plan-guard.sh` mechanizes the existing `bubbles.plan`
  horizontal-plan-detection rule (advisory by default; blocks only under
  `verticalPlanGuard: block`).
- **BFW-03 / IMP-023 — exclusive artifact-writer lease.** `runtime
  writer-acquire` is a thin convention over the existing exclusive lease in
  `runtime-leases.sh`.
- **BFW-04 / IMP-024 — in-window duplicate-evidence detection.**
  `artifact-lint.sh` Check 3 rejects exact-duplicate evidence within one
  certifying window (content fingerprint over the existing marker).
- **BFW-05 / IMP-025 — repo-binding preflight.** `repo-binding-preflight.sh`
  refuses mutable work when the active agent's source repo slug differs from the
  repository being edited (reuses the installer's `mcp_repo_slug` derivation and
  the `.install-source.json` marker).

Each primitive is backed by its own passing selftest under `framework-validate`;
heavier workflow integration is deferred to follow-up work.

## v7.20.0 — registry-bound planning transition audits

**Theme:** Planning-only workflows now certify planning maturity through an
explicit registry-derived audit contract without fabricating delivery
completion, while done-ceiling workflows retain their strict delivery bar.

### BUG-009 Planning Audit Fix

- **Registry-bound planning transition audit (BUG-009).** Workflow registry
  entries now bind transition-audit policy explicitly. Only
  `product-to-planning` and `spec-scope-hardening` use
  `planning-maturity-v1` at `specs_hardened`; audit-bearing `done` modes use
  `delivery-completion-v1`, and adjacent non-done modes fail unsupported
  unless explicitly bound.
- **Profile-scoped guard and result contracts.** The read-only transition
  resolver derives the target/profile/digest/revision, guard inputs are
  assertion-only, and the ordered `TRANSITION_GUARD_RESULT_V1` names applicable
  and non-applicable checks. Honest incomplete planning no longer has to invent
  delivery artifacts, while done-ceiling completion checks remain strict.
- **Audit attempts and exact-ceiling certification.** `AUDIT_RESULT_V1` and
  `execution.audit` preserve interruption, supersession, resume, provenance,
  and one-to-one finding accounting. `PLANNING_AUDIT_CLEAN` certifies planning
  only, with delivery `NOT_EVALUATED`; validate alone may promote the two status
  mirrors to exactly `specs_hardened`.

Source behavior above is backed by the BUG-009 S06 framework validation,
agnosticity, resolver/guard/audit contract, and persistent regression evidence.
This release entry does not assert downstream upgrade, GuestHost installed-byte
provenance, consumer recertification, or BUG-009 closure.

## v7.19.2 — manifest-scoped downstream agnosticity

**Theme:** knb's v7.19.1 doctor exposed a downstream-only false positive: project-owned `bubbles-*` instructions and skills share the framework's discovery naming convention but are intentionally product/domain-specific. The agnosticity lint now distinguishes the installed framework payload from project extensions using `.github/bubbles/.manifest`.

### Fixed

- **Downstream managed-surface filtering.** When an install manifest exists, `agnosticity-lint.sh` scans only paths listed as framework-owned. Source checkouts have no install manifest and continue scanning every canonical portable surface.
- **Project extensions remain project-owned.** Unmanifested `bubbles-*` agents, instructions, and skills may contain repository-specific topology or product names without being mistaken for upstream framework drift.
- **Enforcement remains strict.** A manifested framework file with the same project-specific token still fails. The selftest includes both the exclusion case and its adversarial manifested twin.

### Validation

- Source full agnosticity scan is clean.
- Hermetic agnosticity selftest proves unmanifested extension exclusion and manifested-surface enforcement.
- All downstreams are re-upgraded to v7.19.2 and their built-in doctor results are checked.

## v7.19.1 — downstream doctor agnosticity and entry-point correction

**Theme:** The first v7.19.0 downstream upgrade correctly installed the direct-runner architecture but its built-in doctor exposed eleven portable-surface agnosticity violations that the source release-check's narrower agnosticity target list did not cover. This patch removes every concrete project/browser-tool assumption, corrects the installer's first commands to goal-first guidance, and preserves the downstream upgrade guarantee that doctor is green immediately after install.

### Fixed

- **Portable browser language.** `bubbles.journey` and the external-browser auth-capture skill now refer to the configured browser-automation tool family generically rather than naming one concrete provider. Tool aliases still come from the active environment.
- **Project-neutral examples.** Removed a concrete product name from the transition-guard selftest and replaced a product-specific shell path in the cross-platform skill with `scripts/*.sh`. Journey docs now use a generic portfolio analytics example.
- **Installer guidance.** The install completion banner now recommends `/bubbles.goal <outcome>` as the universal endpoint and `/bubbles.workflow <target> mode: <mode>` for deterministic single-mode execution.
- **macOS selftests.** `generate-installer-selftest.sh` uses a portable temp-file rewrite helper instead of GNU-only `sed -i`; `mode-resolver-selftest.sh` uses `bubbles_run_with_timeout` instead of raw `timeout`.
- **Release diagnostics.** `framework-validate.sh` now prints failed check labels in its final summary, so large validation logs remain actionable even when terminal scrollback truncates the failure location.

### Validation

- Full source `agnosticity-lint.sh --quiet` returns clean.
- v7.19.1 is re-run through framework validation and release-check before downstream re-upgrade.

## v7.19.0 — direct authorized workflow runners

**Theme:** A workflow is an execution contract, not a mandatory middle agent. `bubbles.goal` is now the universal one-outcome endpoint; `bubbles.workflow` runs exactly one explicit or super-resolved root mode; `bubbles.sprint` executes a timed queue of goals; and granted domain orchestrators run only their own mode families. The active top-level runner invokes specialist phase owners directly, eliminating the broken `goal → workflow → specialist` and `sprint → goal → specialist` subagent chains that VS Code's one-level delegation runtime cannot execute. [IMP-019]

### Changed

- **Clear runner boundaries.** Goal may compose zero, one, or several workflows for one outcome. Workflow is capped at one root mode and excludes the `autonomous-goal`, `autonomous-sprint`, and `iterate` meta modes. Sprint applies the goal contract directly to a prioritized queue under its time budget. Super resolves the authorized runner as well as the mode and does not execute product workflows.
- **Domain workflow ownership.** Explicit grants allow bug, releases, train, upkeep, propagation, stabilize, retro, and journey orchestrators to execute only their declared workflow families when top-level. When invoked as a phase owner, each performs only that phase and returns a result envelope.
- **Direct mapped-mode execution.** Trigger/remediation modes remain registry-defined, but the active authorized runner resolves them in the same top-level runtime and invokes their specialist phase owners directly with `executionModel: direct-authorized-runner`. Runner-to-runner subagent invocation and the parent-expanded fallback are retired for new execution.
- **Control phases are runner-relative.** `analyze`, `discover`, `bootstrap`, and `finalize` now resolve through `activeWorkflowRunner` instead of being hard-coded to `bubbles.workflow`.

### Enforcement

- **Gate G064 repurposed in place** from `child_workflow_depth_gate` to `workflow_runner_authorization_gate`. `bubbles/agent-capabilities.yaml::workflowModeGrants` is default-deny; `bubbles/workflows.yaml::workflowExecutionPolicy` declares direct top-level execution, the grant source, and meta-mode owners.
- **New `workflow-runner-grants-lint.sh` + hermetic selftest.** The lint rejects unknown modes, missing grants, non-orchestrator runners, ungranted intent routes, invalid meta-mode ownership, bad workflow root-mode limits, and positive nested-runner dispatch patterns. The selftest proves each failure class adversarially. Framework validation and state-transition Check 3H run the lint.
- **Backward compatibility.** Historical `parent-expanded` execution-history records remain readable by the state guard. Existing mode registry keys and persisted `state.json.workflowMode` values are unchanged. New executions use only `direct-authorized-runner`.

### Documentation

- README, agent manual, workflow-mode guide, autonomous-execution guide, control-plane design/schema/rollout docs, effective-prompting guide, recipes, catalog, super agent knowledge, TPB vocabulary, Markdown cheat sheet, HTML cheat sheet, capability ledger, and generated competitive docs now share the same goal/workflow/sprint/super/domain-runner model.

## v7.18.0 — bubbles.journey (Cathy Curtis) + runtime-lease weighted admission + design-language skill

### Added

- **`bubbles.journey` (Cathy Curtis)** — the cooperative-guided third stance alongside `bubbles.chaos` (stochastic) and `bubbles.redteam` (adversarial). Adds a `journey` phase, the `journey-refinement` workflow mode, an `experientialFriction` proactive `priorityScoring` dimension (scores user-discovered usability friction), and a `guidedJourney` execution tag. Activates structuring of `uservalidation.md` — acceptance remains human-owned; the agent never auto-checks human acceptance items (G057 unchanged). [IMP-001]
- **`readiness-review` synthesizer mode** — persists an advisory validate-owned `certification.readinessVerdict` (`ship | ship-with-notes | not-ready`) synthesized across spec/code/system/security/regression/redteam lenses, homed on `bubbles.system-review`. Advisory-to-release only; it is NEVER a `done` transition (G056 unchanged). [IMP-002]
- **Autonomy dial** — `autonomy: full | guarded | interactive` convenience tag that sets `grillMode`/`socratic`/`clarify` together (explicit flags override). `full` is the default (100% autonomous). Registers the `system-review` and `clarify` phases, a conditional `clarify` activation, and a `grill` interrogate activation that is **DEFAULT-OFF**. [IMP-003]
- **`dryRun: plan`** — a propose-only preview that resolves the full convergence plan and reports intended changes WITHOUT mutating code or state (extends `parallelScopes=dag-dry` to the whole loop). [IMP-003]
- **`sessionBudget` caps** — `maxTotalConvergenceIterations | maxWallClockMinutes | maxToolCalls` (null = unbounded). The advisory config shipped first; it is **now mechanically enforced** by Gate G128 (see next bullet). [IMP-003]
- **Gate G128 (`session_cap_enforcement_gate`)** — mechanically enforces the IMP-003 `sessionBudget` aggregate caps: the whole-session sibling of G082's per-`(specDir, agent)` convergence cap. Reads the recorded `sessionBudget` from `.specify/memory/bubbles.session.json`; when a non-null cap is present it blocks (finding `G128`, `blocked` envelope) once the AGGREGATE across all specs — summed convergence iterations, earliest→latest wall-clock minutes, or `toolCallCount` — exceeds its cap. **No-op by default** (no `sessionBudget`, or all-null caps → exit 0), so no existing repo is affected. No `--skip`/`--force`/`--ignore` bypass (matches G082). Guard `bubbles/scripts/session-cap-guard.sh` + hermetic selftest + persistent regression `tests/regression/test_22_session_cap_enforcement.sh`; wired into `state-transition-guard.sh` (Check 40) and `framework-validate.sh` (selftest + live guard). Gate count 108 → 109. [IMP-003]
- **Parallel-scope isolation contract** plus **accessibility/i18n and migration advisory owners**. [IMP-004]
- **`train` / `upkeep` / `propagate` prompt shims**, a `lessons.md` install seed, and the `improvements/` proposal surface + its `TEMPLATE`. [IMP-005]
- **`skills/INVENTORY.md` reconciliation + inventory-parity guard** — INVENTORY reconciled to the true 40-skill count (adds the missing `bubbles-long-running-commands` row); new `bubbles/scripts/inventory-parity-check.sh` (+ hermetic selftest, wired into `framework-validate.sh`) fails loud if a real `skills/<name>/` (with a `SKILL.md`, excluding `__*` probes) lacks an INVENTORY row or a row references a missing dir. [IMP-005]

### Changed

- **Verification Non-goals tightened** to sharpen the surface boundaries between the verification agents. [IMP-004]
- **Skills-First pointer backfill** applied to all 41 agents so every agent points at the relevant `SKILL.md` modules. INVENTORY reconciliation is now complete (see Added). [IMP-005]

### Runtime leases — resource-weighted admission (host-capacity OOM guard)

**Theme:** Extends the already-shipped session-aware runtime-coordination capability (`runtime-leases.sh`) with the one dimension it lacked — host-capacity (resource-weight) admission — so two *different* heavy builds sharing one host can no longer OOM-kill each other (exit 137) or orphan-hang when one session removes another's mid-build container. The existing lease model coordinated ownership, compatibility, and exclusivity but had no RAM-weight budget; this adds an opt-in, fully backward-compatible weighted-admission gate. Disabled by default (`runtime.capacityWeight: 0`), so a fresh install is unchanged until a host operator sets a budget.

- **`bubbles/scripts/runtime-leases.sh`**:
  - New config under the `runtime` section of `bubbles.config.json`: `capacityWeight` (number, default `0` = admission DISABLED) and optional `weightClasses` (built-in default `{ light: 1, medium: 4, heavy: 8 }`).
  - New `acquire` options: `--weight <light|medium|heavy>` (resolved via `weightClasses`, default `light`), `--weight-units <N>` (explicit integer units; takes precedence over `--weight`), and `--wait <seconds>` (block-and-poll for capacity before refusing; omitted = immediate structured refusal).
  - New persisted numeric `weight` field on every lease record (shown by `format_lease_line` / `lookup` / `list`). Legacy lease lines with no `weight` read as `0`, so existing registries keep parsing.
  - Admission gate: before creating a lease, sums `weight` over **effectively-active** leases only — stale/expired/released are excluded, so a dead session's heavy lease frees its budget automatically via the TTL/stale downgrade (the orphan-hang fix). When `active_sum + new_weight > capacityWeight`, refuses with a structured `Runtime capacity exceeded: …` message plus a `runtime_lease_capacity_refused` framework event, or blocks under `--wait`. The `--wait` poll loop uses a non-fatal lock attempt so transient registry contention does not abort the wait.
  - `summary` / `doctor` now print `Runtime capacity: <active_sum>/<capacityWeight> weight units` (or `disabled` when `capacityWeight=0`).
  - Backward-compat: with `capacityWeight` unset/`0`, `acquire` behaves exactly as before (the gate is skipped entirely).
- **`bubbles/scripts/runtime-lease-selftest.sh`** — adds weighted-admission cases (wired into `framework-validate` via the existing selftest hook): heavy-under-budget acquire, an **adversarial** second-heavy refusal (which fails if the gate is reverted — proven by a mutation run), capacity-frees-on-release, stale-lease-frees-capacity (orphan-hang analog), `--wait` immediate-refuse / wait-loop-timeout / post-release-success, `--weight-units` precedence + exact-boundary admission, and a backward-compat case proving two heavy leases both acquire when `capacityWeight` is unset. All pre-existing cases pass unchanged.
- **Docs** — `docs/issues/session-aware-runtime-coordination.md` documents weighted admission as a shipped extension; `docs/recipes/runtime-coordination.md` documents the `--weight` / `--weight-units` / `--wait` / `capacityWeight` operator surface plus the intended (not-yet-wired) downstream usage.

**Scope:** framework primitive only. Product-repo CLI wiring (acquiring a weighted `build` lease before a heavy build, an `exclusive` `land` lease before a push) is a separate later task. VERSION is intentionally not bumped here — release versioning is left to release-check.

### Design language as an opt-in skill (`bubbles.cinematic-designer` retired)

**Theme:** The premium-UI design vocabulary moves from a standalone execution-owner agent into a selectable, opt-in *design-language skill*, so `bubbles.ux` (gated, in the `analyst → ux → design → plan` chain) picks the design language and `bubbles.implement` applies it — closing the orphaned-contract seam where `cinematic-designer` read an `Aesthetic Preset` from `spec.md` that no upstream agent ever wrote.

- **NEW skill `skills/bubbles-cinematic-design/`** (SKILL.md + `references/presets.md` + `references/patterns.md`) — the four aesthetic presets, the fixed premium design system, and the cinematic interaction-pattern library, with a NON-NEGOTIABLE composition rule (apply patterns *through* the project's own UI skill + design tokens; the project skill wins on concrete values) and the sticky resolution precedence.
- **`bubbles.ux`** — new `design-language:` / `preset:` options + NL rows + a **Design Language Resolution** step (precedence: explicit option → `spec.md` `### Design Language` → repo `designLanguages.default` → none); writes `### Design Language` into `spec.md`, and recommends (never auto-writes) the operator-owned `designLanguages.default` for repo-wide stickiness. `bubbles.implement` reads `### Design Language` and loads the design-language skill + the project UI skill; `bubbles.design` elaborates component specs against it.
- **`bubbles.cinematic-designer` RETIRED** — agent + prompt deleted; removed from `agent-capabilities.yaml`, the alias surfaces (`skid-row`), the `ux` handoff/relationship, the README roster, and `AGENT_MANUAL`. Its execution flow duplicated `bubbles.implement` (which already owns `product-code`); only the knowledge was unique, and that now lives in the skill. `bubbles.super` needs no edit — it discovers the new skill and the removed agent dynamically.
- **HARD per-repo opt-in (the first optional framework skill)** — `bubbles/registry/optional-skills.txt` declares opt-in skills + their enablement token; `install.sh` vendors an optional skill ONLY when the downstream `.github/bubbles-project.yaml` `designLanguages` opts in (and prunes it on opt-out), so it stays physically absent (non-loading) elsewhere; `bubbles-drift-check.sh` is optional-aware (an absent opted-out skill is reported `OPT-OUT`, not `MISSING`), with two new selftest cases (9 total). `designLanguages` is documented in `project-config-contract.md`.
- **Skills-first discovery + INVENTORY** updated (35 skills); the generated CHEATSHEET / HTML cheatsheet / framework-stats regenerate from these source edits via `regen-derived.sh`.

### G053 Code Diff Evidence recognizes shell runtime paths (parity with G093)

**Theme:** Closes a silent inconsistency between the two delivery-delta gates. `delivery-implementation-delta-guard.sh` (G093) already classifies `*.sh` as a `runtime` delivery path via its `path_family()` helper, but the `state-transition-guard.sh` Check 13B (G053) "Code Diff Evidence" runtime-path regex omitted `.sh`/`.bash`. The effect: a legitimate shell-only delivery (a git-hook fix, an operator/deploy script, a CI helper) passed G093 but was wrongly rejected by G053 with "Code Diff Evidence does not show any non-artifact runtime/source/config file paths", blocking an otherwise-complete spec from `done`.

- **`bubbles/scripts/state-transition-guard.sh`** — Check 13B (G053) runtime-path detection regex gains `sh|bash`, so a `*.sh` / `*.bash` path cited in a `### Code Diff Evidence` section now counts as a non-artifact runtime path, matching the G093 `path_family` classifier. No other extension behavior changes; artifact-only evidence is still rejected.
- **`bubbles/scripts/state-transition-guard-selftest.sh`** — adds two G053 Check 13B cases (wired into `framework-validate` via the existing selftest hook): a positive case proving a shell-only Code Diff Evidence (whose ONLY runtime-extension token is a `.sh` path) is accepted, and a non-vacuous negative twin proving an artifact-only Code Diff Evidence is still rejected. All pre-existing cases pass unchanged.

**Scope:** gate-consistency fix only. VERSION is intentionally not bumped here — release versioning is left to release-check.

### Cross-platform (Linux + macOS) runtime portability

**Theme:** The framework's runtime guards/scripts used several GNU-coreutils-only forms (`sed -i <prog>`, `date -d`, `date +%s%N`, `grep -P`) that abort or silently degrade under macOS BSD userland, so a contributor on macOS could not reliably run the guards the agents run. This makes the core runtime path OS-agnostic; each form now picks the working variant at runtime.

- **`bubbles/scripts/guard-lib.sh`** — new portable helpers (`bubbles_sed_inplace`, `bubbles_iso_to_epoch`, `bubbles_now_ms`, `bubbles_file_mtime_epoch`) beside the existing `bubbles_run_with_timeout`. `bubbles_sed_inplace` rewrites via a temp file (GNU `sed -i <prog>` and BSD `sed -i '' <prog>` are mutually incompatible); `bubbles_iso_to_epoch` parses ISO-UTC timestamps AND bare `YYYY-MM-DD` dates on both GNU (`date -d`) and BSD (`date -j -f`); `bubbles_now_ms` falls back to second resolution when BSD `date` lacks `%N`; `bubbles_file_mtime_epoch` pairs `stat -c`/`stat -f`.
- **`bubbles/scripts/state-transition-guard.sh`** — revert-on-fail `sed -i` (×5) and timestamp-plausibility `date -d` (×3) now call the portable helpers (guard-lib already sourced).
- **`bubbles/scripts/artifact-lint.sh`** — timestamp `date -d` (×3) → a portable `bubbles_iso_to_epoch` defined **locally** (self-contained, no cross-file source) so the script stays runnable when a selftest copies it alone into an isolated fixture repo.
- **`bubbles/scripts/done-spec-audit.sh`** — recertification `sed -i` (×4) → a portable `bubbles_sed_inplace`, likewise defined **locally**; its selftest copies the script by itself into a fixture repo, so a sourced sibling lib would not resolve there.
- **`bubbles/scripts/observability-opt-out-guard.sh` / `observability-posture-guard.sh`** — `revisitAfter` `date -d` gains an inline BSD `date -j -f` fallback (kept inline to preserve their deliberate no-external-tool self-resolution path).
- **`bubbles/scripts/tool-log.sh`** — `date +%s%N` duration timing tolerates BSD `date` lacking `%N` (numeric guard → second-resolution fallback).
- **`bubbles/scripts/gate-id-grep.sh`** — auto-detects a PCRE-capable grep (system `grep` → `ggrep`) so its back-reference scans run on macOS without the operator pre-setting `BUBBLES_GREP`; the fail-loud no-PCRE path is preserved.
- **`bubbles/scripts/framework-validate.sh`** — at startup, when the GNU tools exist only under their `g`-prefixed names (macOS coreutils), exposes `gsed`→`sed` and `gtimeout`→`timeout` on PATH for this process and every selftest subprocess it spawns, so selftests that still call GNU `sed -i` / `timeout` directly run on macOS unchanged (a no-op on Linux, which already has the unprefixed GNU tools).
- **`tests/stress/test_06/07/08`** — `date +%s%N` latency timing guards against BSD `date` lacking `%N` (same numeric-guard fallback as tool-log).

**Follow-up (full `framework-validate` parity on macOS):** the remaining BSD-userland gaps surfaced by a full `framework-validate.sh` run are now closed, so the whole suite — not just the core runtime path — runs green on macOS.

- **`bubbles/scripts/mode-resolver.sh`** — `_normalize_tags` piped into `paste -sd ' '` with no file operand; GNU `paste` reads stdin there but BSD `paste` errors (`usage: paste …`), so every v6 primitive+tag alias resolved to the empty string (58 `Mode alias selftest` failures). Now `paste -sd ' ' -` (explicit stdin operand; works on both).
- **`bubbles/scripts/mcp-grant-reconcile.sh`** — `awk -v strip="$strip"` passed a newline-separated grant list; BSD awk rejects a `-v` value containing a literal newline (`awk: newline in string`). Now the newline list is collapsed to a comma-separated value (grant tokens are validated `[A-Za-z0-9_.-]+`, never contain commas) and split on `,` inside awk.
- **gawk 3-arg `match()` shim** — `context-compactor.sh`, `generate-capability-ledger-docs.sh`, `docs-registry-resolve.sh`, and `developer-profile.sh` use the GNU-awk-only `match($0, /re/, arr)` capture form, which BSD awk rejects (`awk: syntax error`). Each now prefers `gawk` when present (`awk() { command gawk "$@"; }`), fixing the `context-compactor`, `capability-ledger`, `capability-freshness`, and `competitive-docs` selftests.
- **`bubbles/scripts/context-compactor.sh`** — also stopped canonicalizing the rawPointer with `readlink -f` (macOS rewrites `/var/...`→`/private/var/...`, diverging from the caller's path); an already-absolute path is now preserved verbatim.
- **`bubbles/scripts/developer-profile.sh`** — also `date -u -d "N days ago"` (GNU relative date) gains a BSD `date -u -v-Nd` fallback.
- **`bubbles/scripts/interop-intake.sh`** — `paste -sd ', '` (no operand) → `paste -sd ', ' -`.
- **`bubbles/scripts/mode-alias-selftest.sh`** — GNU `mktemp --suffix=.yaml` (unsupported by BSD `mktemp`) → create-then-rename to add the extension.
- **Dep-gated selftests SKIP gracefully** — when the active `python3` lacks an optional module, `result-envelope-validate-selftest.sh` (jsonschema) and `v5.2-selftest.sh` F7 (PyYAML) now print a `SKIP` line and exit 0 instead of hard-failing, matching the framework's existing graceful-degradation convention (`model-tier-advisory-selftest.sh` already skipped identically, and the underlying `result-envelope-validate.sh` / `model-tier-advisory.sh` already degrade to `SKIP`). A real regression on a fully-provisioned box still fails (F7 only skips when PyYAML is genuinely absent).
- **`bubbles/release-manifest.json`** — regenerated: 24 source files' checksums had drifted (the fixes above plus earlier commits whose manifest was never re-run), so `Release manifest freshness`, `Release manifest selftest`, and the committed-manifest check are current again.

Verified on macOS (BSD userland): a full `bash bubbles/scripts/framework-validate.sh` run exits `0` with **zero failing checks**. The only `SKIP` lines are the framework's intended graceful-degradation path for optional Python modules (PyYAML / jsonschema) absent from the active interpreter — the same convention `model-tier-advisory-selftest` already used; installing those modules (or pointing `python3` at an interpreter that has them) lights the skipped checks up with no code change.

**Follow-up (`cli.sh doctor` macOS parity):** running `bash bubbles/scripts/cli.sh doctor` on BSD userland (an operator surface `framework-validate` does not exercise) surfaced two residual issues, now fixed:

- **`bubbles/scripts/cli.sh`** — `current_epoch_ms` used `date +%s%3N` for command timing; BSD `date` lacks `%N`/`%3N` and emits a literal `N`, so `duration_ms=$((end_ms - COMMAND_START_MS))` aborted with `value too great for base (error token is "…N")` at the end of every `cli.sh` subcommand on macOS. Now numeric-guarded with a second-resolution (`×1000`) fallback, matching the `tool-log.sh` pattern.
- **`skills/bubbles-skill-authoring/SKILL.md`** — the earlier skills-placement correction illustrated project-specific skill names with two literal product names (`wanderaide-*`, `smackerel-*`); the doctor's portable-surface agnosticity lint (correctly) flags product names in a portable framework skill. Genericized to a `<repo>-` placeholder; the `knb` ecosystem references in other portable skills are pre-existing and allowlisted.

`cli.sh doctor` now reports **17 passed, 0 failed** on macOS.

**Scope:** runtime + selftest path. VERSION not bumped (release-check owns versioning).

### Cross-platform shell as a first-class framework skill + instruction

**Theme:** The BSD/GNU portability knowledge proven out across the two runtime-portability passes above was repo-local — `wsl-macos-compatibility` existed only as a WanderAide skill and as an independently-authored per-repo instruction, never in the framework source — despite governing the framework's own 200+ shell scripts. This promotes it to a reusable framework asset so every downstream repo (and the framework itself) shares one authoritative portability contract.

- **NEW skill `skills/bubbles-cross-platform-shell/`** — the GNU-vs-BSD pitfall→portable table (`sed -i`, `date -d` / `+%s%N`, `paste` stdin operand, `awk -v` newlines, 3-arg `match()`, `mktemp --suffix`, `readlink -f` symlink canonicalization, `grep -P`, `/bin/true`, `mapfile`, locale `sort`), the `guard-lib.sh` helper reference (`bubbles_sed_inplace`, `bubbles_iso_to_epoch`, `bubbles_now_ms`, `bubbles_file_mtime_epoch`, `bubbles_run_with_timeout`), the selftest graceful-degradation rule, and the `framework-validate` PATH-shim recipe. Registered in `skills/INVENTORY.md` (KEEP) and the `bubbles-skills-first-discovery` router.
- **NEW instruction `instructions/wsl-macos-compatibility.instructions.md`** (`applyTo: "**"`) — the binding policy counterpart: the `timeout`→`gtimeout`→watchdog resolution wrapper, the forbidden→required forms table, the selftest SKIP contract, and the verification checklist. Becomes the framework source of truth that syncs to every repo (previously each repo carried an independently-authored copy that could silently diverge).
- **Derived artifacts regenerated** via `regen-derived.sh` (framework-stats, cheatsheet, capability-ledger docs, release manifest — 583 managed files). `framework-validate.sh` passes (exit 0, zero failing checks) on macOS.

**Scope:** framework skill + instruction (additive). VERSION not bumped (release-check owns versioning).

### Skill placement & naming invariant (root-cause fix for skill drift)

**Theme:** A capability-placement audit across the framework and the five downstream repos surfaced recurring skill drift — `bubbles-`prefixed skills stranded in a single repo (knb's deploy trio: `bubbles-zero-manual-deployment`, `bubbles-client-binary-release`, `bubbles-shared-services-selector`) and the same UNPREFIXED skill name (`chaos-execution`, `trace-capture`, `bug-fix-testing`) independently authored in three-plus repos. Root cause: `bubbles-skill-authoring` had a "project vs personal" scope rule but no framework-vs-repo NAMING rule, so nothing declared where a skill lives or what its prefix means. This codifies one invariant so every future skill lands correctly and the existing violators get an unambiguous, consistent target.

- **`skills/bubbles-skill-authoring/SKILL.md`** — new **Placement & Naming Invariant** section: `bubbles-<x>` is RESERVED for framework-owned, framework-sourced skills that sync to every repo; `<repo>-<x>` (`knb-*`, `wanderaide-*`, `smackerel-*`, …) is repo-specific and lives only in that repo. Includes the one-branch decision tree (product-agnostic contract → framework `bubbles-*`; concrete wiring of a framework capability → `<repo>-*`), the two anti-patterns it kills (a `bubbles-*` skill stranded in a downstream repo; the same unprefixed name duplicated across repos), and the safe migration procedure (route to the owning repo / the framework — never rename across contended repos in one shot).
- **`instructions/bubbles-skills.instructions.md`** (`applyTo: "**"`, synced to every repo) — a tight statement of the reserved-`bubbles-`prefix rule that points at the skill's decision tree.

**Scope:** governance (skill authoring). No skills renamed here — the invariant is the standard against which each owning repo migrates its own violators. VERSION not bumped (release-check owns versioning).

### Skill placement invariant corrected to defer to project-config-contract.md

**Theme:** The invariant in the entry immediately above was over-strict and conflicted with the framework's EXISTING authoritative convention, so it is corrected here. `agents/bubbles_shared/project-config-contract.md` § Skills Classification already governs placement by CONTENT (Portable vs Project-specific) and explicitly sanctions UNPREFIXED domain skill names (`chaos-execution`, `protobuf-only`) — while the framework-synced `bubbles.chaos.agent.md` PINS the exact path `.github/skills/chaos-execution/SKILL.md`. The prior "no unprefixed / rename to `<repo>-*`" rule would have (a) broken the framework chaos agent's skill-load contract and (b) required rewriting the same skill names across 55+ downstream files including historical done-spec artifacts (knb specs 019/025/027/028/032 `state.json` / `report.md` / `uservalidation.md`, tests, and all four `contract.yaml`). This defers to the existing authority instead of competing with it.

- **`skills/bubbles-skill-authoring/SKILL.md`** — the "Placement & Naming Invariant" section is replaced with "Placement & Naming": classify by CONTENT (portable vs project-specific) per `project-config-contract.md`; the `bubbles-` prefix is a convention for portable skills (not a mechanical rename mandate); unprefixed domain names AND `<repo>-*` are both acceptable for project-specific skills; a skill a framework agent PINS by fixed path (e.g. `chaos-execution`) is a contract and MUST NOT be renamed.
- **`instructions/bubbles-skills.instructions.md`** — the "reserved prefix" rule is replaced with the same content-based classification plus the framework-agent-pinned-name rule.
- **No downstream skills renamed.** The earlier-contemplated `chaos-execution` / `trace-capture` / `bug-fix-testing` renames and the knb `bubbles-*` deploy-skill renames are withdrawn — each is either the sanctioned unprefixed pattern, a framework-agent-pinned contract, or too deeply embedded in historical artifacts to rename safely.

**Scope:** governance correction (skill authoring). VERSION not bumped (release-check owns versioning).

### Regression test_13 realigned to the v7 mode-collapse

**Theme:** `tests/regression/test_13_spec_review_auto_route.sh` had been red since v7.0.0 — a stale test, NOT a caught regression (the framework behavior is correct). It (a) resolved persisted mode names (`bugfix-fastlane`, `full-delivery`) through `mode-resolver.sh` WITHOUT the grandfather flag v7 requires after v5-name input was removed, and (b) asserted `specReviewDefault` / `modeClass` / etc. against the RAW `.modes.<name>.constraints` path even though v7 moved those constraints to template inheritance (the raw mode has no `constraints` key; the RESOLVED mode carries them).

- `assert_resolved_yq` now resolves with `BUBBLES_MODE_GRANDFATHER=1` (per the resolver's own remediation hint) and discards stderr so the captured file is pure resolved-mode YAML.
- R5 (`docs-only`) and R6 (`spec-review-to-doc`) switch from `assert_yq` on the raw `workflows.yaml` to `assert_resolved_yq` on the resolved mode. Their expected values (`off` / `docs-only` / `false`; `off` / `spec-review-only` / `true` / `true`) are unchanged and confirmed against the resolver.

The full `tests/regression` suite now runs 21/21 on macOS (and Linux — the fix is platform-independent). Surfaced while extending the macOS "run all" verification beyond `framework-validate`.

**Scope:** regression test alignment. VERSION not bumped (release-check owns versioning).

### developer-profile.sh clear_stale — second `date -d` BSD fallback (review pass)

**Theme:** A follow-up review pass across all `bubbles/scripts/*.sh` for residual BSD-userland gaps found one genuine miss: `developer-profile.sh` `clear_stale()` computed its cutoff with GNU `date -u -d "N days ago"` and no fallback, even though its twin `show_stale()` was already fixed. On macOS the cutoff resolved empty. It now carries the same `|| date -u -v-Nd` BSD fallback.

The rest of the scan came back clean: `sed -i` survives only in selftests that run under the `framework-validate` PATH shim; the `date` / `stat` / `paste` / `readlink` / 3-arg-`match()` runtime uses are all guarded or gawk-shimmed; `install.sh` is portable; and the extensive `mapfile` usage is the framework's existing bash-4+ requirement (an environment prerequisite like GNU coreutils, not a per-script bug).

**Scope:** runtime path. VERSION not bumped (release-check owns versioning).

## v7.17.0 — artifact-lint certifying-window marker + v5 delivery-lockdown mode restored

**Theme:** Two additive, independent changes ship together. (1) artifact-lint Check 3 (evidence legitimacy) gains an opt-in certifying-window boundary marker so a long-running spec with extensive pre-heuristic round-history can promote to `done` without retroactively rewriting hundreds of historical evidence blocks (which the append-only audit rule forbids). (2) The pre-v6 `delivery-lockdown` workflow mode is restored as a grandfathered registry key.

### artifact-lint Check 3 — certifying-window boundary marker

Check 3 applied its done-strict (>=3-line / >=2-signal) heuristic to the ENTIRE accumulated `report.md` corpus, so a long-running spec's historical evidence — often pre-dating the signal heuristic, frequently irreproducible, and frozen by the append-only rule — was re-judged by today's stricter rule, making Path-A promotion structurally impossible.

- **`bubbles/scripts/artifact-lint.sh`** — Check 3 now honors an opt-in `<!-- bubbles:certifying-window-begin -->` marker in `report.md` only. Code blocks BEFORE the marker are prior-window history (counted as skipped, NOT enforced, like the `evidence-legitimacy-skip` region); blocks AFTER it are done-strict-checked exactly as before. The exemption is strictly opt-in PER FILE: a report.md with NO marker is enforced in full (the marker can never silently disable Check 3 fleet-wide), and more than one marker fails loud (ambiguous window start). A distinct info line reports the prior-window skip count separately from the skip-region count.
- NEW **`bubbles/scripts/artifact-lint-selftest.sh`** (hermetic + adversarial; wired into `framework-validate.sh`) asserts: a compact PRE-marker block is exempt while a signal-rich POST-marker block passes; a weak POST-marker block is still enforced; two markers fail loud; and — the integrity guarantee — a marker-LESS report still enforces Check 3 in full (no silent fleet-wide disable).

**Integrity:** this is NOT an anti-fabrication weakening. Fresh current-window evidence stays fully done-strict; only prior-window history (already audited in earlier rounds) is exempt, and only when the author opts in with one append-only marker. Like the skip region, the marker MUST mark the real current-window start and MUST NEVER hide fresh fabricated evidence.

### Workflows — v5 `delivery-lockdown` mode restored (grandfathered)

- **`bubbles/workflows/modes.yaml`** + **`bubbles/workflows/aliases.yaml`** + **`agents/bubbles.workflow.agent.md`** — re-adds the pre-v6 `delivery-lockdown` registry key (the v5 name of `full-delivery`) so persisted artifacts (`state.json.workflowMode: delivery-lockdown`) keep resolving via the grandfather path. Identical maximum-assurance delivery semantics to `full-delivery`; new operator input MUST use `full-delivery`. The extra `lifecycle: lockdown` tag keeps the (primitive, tag-set) tuple unique vs `full-delivery`.

## v7.16.1 — Downstream framework-validate: source-only-skip 5 fixture-dependent selftests

**Theme:** A propagation dry-run surfaced that `framework-validate.sh` exited non-zero in a clean *downstream* install (5 failing checks) even though every live governance guard passed. Root cause: 5 selftests were wired with `run_check` (always-run) instead of `run_check_self_only`, yet they depend on source-only inputs the installer does not vendor — the `tests/fixtures/observability/` fixtures (the G098/G099/G100 selftests + the check-twin) and the canonical `bubbles` MCP token (a downstream install carries a per-repo `bubbles-<slug>` token, which makes `mcp-grant-selftest` structurally unsatisfiable). They now join the existing source-only-skip set, so downstream `framework-validate` exits 0 with explicit SKIP accounting, while the source repo still runs all 5 and the live G098/G099/G100 guards still run everywhere.

### Fix

- **`bubbles/scripts/framework-validate.sh`** — `run_check` → `run_check_self_only` for `MCP tool grant selftest (v7.1)`, `Observability posture guard selftest (G098)`, `Observability opt-out guard selftest (G099)`, `Observability SLO guard selftest (G100)`, and `Observability check twin selftest (wired fixture)`, each with an inline rationale. The live guards, `observability-endpoint-resolve-selftest`, and `prometheus-adapter-fetch-selftest` stay `run_check` — they pass downstream (no source-tree fixtures required). Source `framework-validate` behavior is unchanged (`run_check_self_only` is a passthrough in source mode), and the v5.3 downstream-install selftest's fixed 13-label assertion is unaffected (its synthesized tree never copies these 5 scripts). Canonical source only; re-vendors downstream via `release-manifest.json`.

## v7.16.0 — IMP-016: skill-evolution loop hardening + skill-template contract

**Theme:** An analyst review of Nate B. Jones' Open Skills / OB1 against Bubbles' existing skill surface found Bubbles already implements most of the thesis (skills-first discovery, on-demand loading, verification-as-contract via gates, project-vs-personal scope, AND an already-shipped Skill Evolution Loop). Of the five candidate borrows, three are genuinely additive and are IMPLEMENTED; two are redundant with surfaces Bubbles already owns and are DESCOPED with rationale. NO new agent is created — the borrowed flywheel maps onto the existing `bubbles.create-skill` (Sam Losco) + the `skill-evolution.sh` loop, so no new TPB persona is consumed. The IMP-016 blueprint doc is deleted on delivery per the improvements-doc lifecycle (the durable record is the shipped code + the new selftest + this entry).

### IMP-016 IP-2 — "When NOT to use" + "Works well with" skill-template sections

- **`skills/bubbles-skill-authoring/SKILL.md`** adds both as RECOMMENDED body sections (negative triggers that route to a sibling skill; composition pointers to the skills this one chains with), and **`agents/bubbles.create-skill.agent.md`** scaffolds both stubs for every new skill. Closes the template gap (1/34 skills carried a negative trigger, 0 carried a composition pointer). Existing skills are NOT mass-rewritten — the guidance is additive for new/edited skills and the discovery router stays authoritative.

### IMP-016 IP-4 — promote-to-skill decision rule

- The single stated promotion trigger — *"do it once → a prompt is fine; recurring + non-obvious + verified → promote to a skill"* — is codified in `skills/bubbles-skill-authoring/SKILL.md`, `agents/bubbles.create-skill.agent.md`, and the `skill-evolution.sh` proposal output, giving the evolution loop and the `INVENTORY.md` pruning policy a shared trigger (promotion and pruning are the two ends of one lifecycle).

### IMP-016 IP-1 — Skill Evolution Loop quality bar + dedup + anti-hoarding

- **`bubbles/scripts/skill-evolution.sh`** — every emitted `.specify/memory/skill-proposals.md` proposal now carries the creation quality bar (**Reusable · Non-trivial · Specific · Verified**), a dedup-before-create line (search existing `.github/skills/` + `INVENTORY.md` first, prefer update over a near-duplicate), and an anti-hoarding prompt (review least-recently-modified skills when the set is large). The threshold/dismiss/exit behavior is byte-unchanged.
- **`agents/bubbles.create-skill.agent.md`** gains a pre-scaffold quality gate applying the same dedup-search + quality bar + decision rule. **`bubbles/workflows.yaml` `skillEvolution:`** documents the bar + rule (no behavior change).
- NEW **`bubbles/scripts/skill-evolution-selftest.sh`** (hermetic + adversarial; wired into `framework-validate.sh`) asserts a repeated pattern still fires a proposal, the proposal now carries the quality-bar + dedup + decision-rule scaffolding, dismiss still works, and a below-threshold pattern produces NO proposal (the adversarial leg proves the threshold is unchanged).

### IMP-016 IP-3 + IP-5 — descoped as redundant

- **IP-3 (personal-scope skills)** — DESCOPED. Bubbles already separates personal/cross-repo procedural preference from project scope via `developerProfile` (`.specify/memory/developer-profile.md`) + the agent user-memory layer; a new personal-skills surface would duplicate them and add drift. One clarifying paragraph in `bubbles-skill-authoring` routes personal preferences there instead — no new mechanism.
- **IP-5 (per-skill `metadata.json`)** — DESCOPED. `skills/INVENTORY.md` + SKILL.md frontmatter (`name`/`description` triggers) already provide the machine-readable registry; a parallel `metadata.json` would be a second source of truth (violates SST) and a new drift surface. No change.

Docs synced: `docs/CHEATSHEET.md` (Sam's Specialties + skill-evolution row + new TPB vocabulary), `docs/its-not-rocket-appliances.html` (skill-evolution gate line + alias row), `skills/INVENTORY.md` (LOC 96→115), `agents/bubbles.super.agent.md` (§12 proposal note), and the `framework-health` recipe (the promote-a-recurring-lesson-to-a-skill flow). Canonical source only; re-vendors downstream via `release-manifest.json`. Full framework-validate green.

## v7.15.0 — IMP-015: MCP `graph_neighbors` verb + traceability edge-confidence tags

**Theme:** Completes the two IMP-014 follow-ons that v7.13.0 deferred. Both build on the already-shipped governance hub graph (`bubbles-hub-report.sh`) and the SST-derived edges it already computes — no new graph extraction, no LLM, no new vendored data source. The IMP-015 blueprint doc is deleted on delivery per the improvements-doc lifecycle.

### IMP-015 Scope A — MCP `graph_neighbors` verb

- **`bubbles/mcp/tools/graph_neighbors.json`** registers a `graph_neighbors` MCP tool (server tool count 11→12) so agents query the governance reverse-dependency graph through the MCP surface instead of grepping. It is backed by **`bubbles/scripts/bubbles-graph-neighbors.sh`**, a thin twin that does an existence check then `exec`s `bubbles-hub-report.sh --node <id> --format json` unchanged (no graph re-derivation). Returns the provenance-tagged `{ node, kind, inDegree, dependents:[{source, provenance, line}] }` payload; an unknown node yields a structured error (exit 3). Wired into `mcp-server-selftest.sh` (T20–T22) and documented in `docs/MCP.md`.

### IMP-015 Scope B — traceability edge-confidence tags

- **`bubbles/scripts/traceability-guard.sh`** now tags every scenario→TestPlanRow and scenario→DoD mapping `declared` (shared trace ID), `inferred` (single fuzzy match), or `ambiguous` (>1 fuzzy match), plus an `Edge confidence` summary line — all informational, via the existing `info` channel. Tags are computed READ-ONLY at the call sites (`classify_match_kind` + recheck loops); the twinned match functions (`scenario_matches_dod` / `scenario_matches_row` / `extract_trace_ids`), the `failures` counter, and the exit block are byte-for-byte untouched (purely additive — `git diff --numstat` reports 0 deletions), so the guard's pass/fail/exit semantics are provably unchanged. `traceability-guard-selftest.sh` gains Case 3 (declared) + Case 4 (ambiguous) and asserts the unchanged Case 1 = exit 0 / Case 2 = exit non-zero behavior.

Borrows the *concepts* (reverse-dependency query, edge-provenance/confidence tagging) from a graphify trial while continuing to REJECT its fuzzy tree-sitter+LLM re-derivation of edges the SSTs already declare authoritatively.

Canonical source only; re-vendors downstream via `release-manifest.json`. Full framework-validate green.

## v7.14.0 — control-plane policy activation (BUG-008): SST precedence + real G060 red→green ordering + grandfather

> *"Don't bolt a control panel to the trailer and then never wire it to the breaker, Bubbles — flip the switches or take 'em off."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A control-plane audit found the v3 gates G055–G060 sourced effective policy ONLY from each spec's `state.json.policySnapshot`, with NO fallback to the repo Single-Source-of-Truth defaults in `.specify/memory/bubbles.config.json`. Because ~93% of downstream specs carry no snapshot, the global control-plane settings (grill / tdd / autoCommit / lockdown / regression / validation) were declared-but-INERT, and the one evidence gate that did run (G060) passed merely because a report or template contained the word "tdd" — a rubber-stamp. This release activates the SST and gives G060 teeth, without retro-breaking historical specs.

### Layer 1 — SST precedence resolver activates the control-plane settings (BUG-008)

- **`bubbles/scripts/guard-lib.sh`** gains `resolve_effective_policy` / `resolve_effective_policy_source`, a self-contained precedence resolver: per-spec `policySnapshot.<section>.<key|mode|value>` → repo SST `defaults.<section>.<key>` in `.specify/memory/bubbles.config.json` → hardcoded framework default. python3-backed, injection-safe (args via argv), and graceful when the SST config is absent (falls through to the framework default — never a silent skip).
- **Check 3A (G055)** no longer HARD-FAILS when `policySnapshot` is absent: the SST config IS the provenance of record, so provenance resolves from it and the check PASSES with an INFO note. Only a missing snapshot AND a missing SST config remains a fail. When a snapshot IS present, the stricter per-snapshot checks are unchanged.
- **Check 3D (G058/G059)** surfaces the effective `regression.immutability` resolved through the chain (the lockdown/regression triggers still key off `scenario-manifest.json`).
- **Check 3E (G060)** resolves the effective TDD mode through the chain (framework default `scenario-first`), so a missing snapshot no longer leaves the SST default inert. The existing per-packet exempt-handling and the bugfix-fastlane/chaos-hardening forced-scenario-first behavior are unchanged.

### Layer 2 — G060 real red→green ordering (no more keyword rubber-stamp)

- The old G060 evidence test was `grep -qiE '…|tdd'` — it matched the template word "tdd" and proved nothing. It is replaced by **`detect_red_green_ordering`**: G060 passes ONLY when a failing-proof (RED) marker appears on an earlier line than the first passing-proof (GREEN) marker in the SAME report. The literal word "tdd"/"scenario-first" alone can never pass.

### Grandfather clause (no retro-break)

- A spec with NO `policySnapshot` whose `state.json.createdAt` is missing or strictly before the cutoff `2026-06-18` has the newly-activated G060 enforcement downgraded to a grandfathered INFO (never a blocking fail), mirroring the G094 pattern. New specs (`createdAt ≥ cutoff`) and any spec that DOES carry a `policySnapshot` get full enforcement. This protects the ~93% of historical done specs across the 5 downstream repos.

### Selftest + regression (the proof)

- **`bubbles/scripts/control-plane-policy-activation-selftest.sh`** (hermetic; wired into `framework-validate.sh`) — 19 assertions: A activation-from-config, B adversarial keyword-only (`tdd`) FAILS hardened G060 while still matching the old grep, C red→green ordering passes, D grandfather, E precedence legs (snapshot > config > framework default) + boolean normalization.
- **`tests/regression/test_21_control_plane_activation.sh`** — exercises the REAL `state-transition-guard.sh` against staged fixture specs and asserts the Check 3A SST-fallback + Check 3E activation/fail/pass/grandfather output lines.

### Doc fix (bundled)

- `agents/bubbles.iterate.agent.md` mislabeled the zero-deferral check as "Gate G036" (`red_green_traceability_gate`); corrected to "Gate G040" (`incomplete_work_language_gate`), matching `agents/bubbles.implement.agent.md`. `gates.yaml` is the source of truth; no other doc was touched.

Canonical source only; re-vendors downstream via `release-manifest.json`. Full framework-validate green.

## v7.13.0 — guard false-positive fixes (BUG-006/007) + maintenance ergonomics (IMP-007/008/010/011)

> *"Don't make folks rewrite the trailer just 'cause the inspector's clipboard is too twitchy, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A session-history review across the five downstream repos surfaced a recurring friction class — guards that flag ORDINARY artifact wording and force agents to reword legitimate evidence — plus several re-discovered maintenance rituals. This release fixes the two concrete guard false-positives and delivers the maintenance-ergonomics and governance-visibility improvements (IMP-007 through IMP-014). Full framework-validate + release-check green.

### Fixes — guard false-positives (BUG-006, BUG-007)

- **BUG-006 — `state-transition-guard.sh` Check 4B/Check 5 now ignore header summary blockquotes.** Both checks read `**Status:**` lines with an unanchored grep, so a top-of-file rollup blockquote like `> **Status:** all scopes Not Started (planning refreshed …)` was mis-read as a non-canonical scope status (Check 4B) AND mis-counted in the scope tally / `state.json` cross-reference (Check 5). Both now exclude `^>`-prefixed blockquote lines. **Safety:** a canonical scope status MUST be a plain line, so a `> **Status:** Done` blockquote can never smuggle a scope to Done — it is simply not counted. Adversarial selftest pair: a header blockquote no longer fails; a plain `**Status:** Deferred` scope line is STILL flagged (no over-exclusion).
- **BUG-007 — Check 8C (Shared-Infra Blast-Radius) trigger tightened.** The middle-alternation second arm allowed the generic words `setup|contract|flow`, so benign prose (a Test Plan row describing a "regression session" re-running a user "flow") matched `session`+`flow` and wrongly demanded a Shared Infrastructure Impact Sweep. The arm is narrowed to a real test-infrastructure noun (`fixture|fixtures|harness|bootstrap`); the `shared|global|common|core` qualifier arm and the specific multi-word-phrase arm (which signal GENUINE shared infra) are unchanged. Adversarial selftest: benign `session`+`flow` prose no longer trips 8C, while the genuine shared-fixture positive/negative fixtures STILL do.
- Both fixes are verdict-preserving for real violations, shellcheck-clean, and keep the BUG-005 perf selftest green (2s on a 6036-line fixture). Canonical source only; re-vendor downstream via `release-manifest.json`.

### IMP-007 — derived-artifact regeneration wrapper (`regen-derived.sh` + `release-check --fix`)

- **`bubbles/scripts/regen-derived.sh`** regenerates the four derived artifacts in the one correct dependency order — framework-stats → cheatsheet → capability-ledger-docs → **release-manifest LAST** (it checksums the others) — then re-runs every generator in `--check` mode and FAILS LOUD if any is still stale (catches a silent no-op). `--check-only` diagnoses without regenerating. This removes the recurring "which generators, in what order?" trap that blocks the push at `release-check` after a green `framework-validate`.
- **`release-check.sh --fix`** runs `regen-derived.sh` before the freshness gates, so one command both diagnoses and remediates; bare `release-check.sh` is unchanged (check-only).
- Hermetic `regen-derived-selftest.sh` (stubbed generators) asserts dependency order, fail-loud on a still-stale artifact, `--check-only` non-mutation, and bad-usage exit 2. Wired into `framework-validate.sh`.

### IMP-008 — installer orphan-prune completeness (agents / prompts / instructions / skills)

- The v7.3.2 orphan-prune covered only `bubbles/scripts/` + `guards/`. `install.sh` now also prunes orphan framework files from the `agents/`, `prompts/`, `instructions/`, and `skills/` mirrors when a release REMOVES one upstream. The prune is keyed on the PREVIOUS install's `bubbles/.manifest` keep-set, so operator-authored files (never framework-managed) are NEVER removed — closing the gap the v7.3.2 work explicitly flagged for the shared `instructions/`/`skills/` dirs.
- `install-provenance-selftest.sh` gains seven assertions: an orphan framework agent/prompt/instruction/skill is pruned on reinstall, while a real framework file AND operator-owned instruction/skill files survive.

### IMP-010 — canonical long-running-commands skill

- **`skills/bubbles-long-running-commands/SKILL.md`** promotes the repeatedly-reinvented "run a long build/test/deploy without polling" discipline into a product-agnostic skill (the pattern previously lived only in one downstream's project-local agent). Codifies the modern model — background/async + end the turn + await the completion notification; an optional signal-file heartbeat for cheap mid-flight peeks — plus the anti-patterns (polling a build terminal, short timeouts that kill mid-compile, concluding "stalled" from a quiet long command) and the terminal-discipline tie-in. Delivered as a SKILL (not an agent) because it is procedural knowledge: skills are discovered dynamically, are NOT counted by framework-stats, and avoid the heavy agent-capabilities/ownership/routing registration. agnosticity-lint clean.

### IMP-011 — new-gate scaffolder (`scaffold-gate.sh`)

- **`bubbles/scripts/scaffold-gate.sh`** collapses the error-prone parts of the 10-step new-gate ritual: it computes the next free gate ID (skipping the burned **G096** and the reserved **G102–G109** gap), computes the next `tests/regression/test_NN` number, stamps the three new skeleton files (guard + hermetic selftest + regression) with the correct exit-code contract, refuses to clobber, supports `--dry-run`, and prints the precise copy-pasteable wiring checklist for the shared-file touchpoints. It is intentionally PURELY ADDITIVE — it does NOT auto-edit `gates.yaml` / `workflows.yaml` / `state-transition-guard.sh` / `framework-validate.sh` (programmatic edits to those load-bearing files would make the tool a new failure surface); the checklist ends with `regen-derived.sh` (IMP-007).
- `scaffold-gate-selftest.sh` — 13 assertions including next-ID after G127→G128, burned-G096 skip (G095→G097), reserved-gap skip (G101→G110), `--dry-run` non-mutation, clobber refusal, and bad-name/usage exits. Wired into `framework-validate.sh`.

### Deferred sub-parts (tracked in the IMP docs)

- A generic cross-guard self-fixture meta-selftest (IMP-009) — the concrete contracts shipped in `scan-lib-selftest.sh`; a generic harness across heterogeneous guards overlaps with the live lints and is built only if a new self-match class appears.
- Bounded `-jN` parallelism for framework-validate (IMP-012) — the tiering already delivers the fast-signal win; parallel output/tmp contention needs its own care.
- The vendoring surface-thinning study (IMP-013) — analysis-only; it would alter the `.checksums` trust model and must be ratified on its own.
- The optional MCP `graph_neighbors` verb + traceability edge-confidence tagging (IMP-014 follow-ons).

### IMP-009 — guard false-positive hardening (systemic: `scan-lib.sh`)

- **`bubbles/scripts/scan-lib.sh`** centralizes the three recurring scan mistakes behind sourceable helpers: `bubbles_scan_files` (excludes a guard's own `*selftest*` fixtures + generated dirs — the G115 self-match class), `bubbles_strip_comments` (drops pure-comment lines before a code-evidence grep), and `bubbles_status_lines` (excludes `>`-blockquote summary lines — the BUG-006 class). `state-transition-guard.sh` Check 4B + Check 5 were retrofitted to consume `bubbles_status_lines` (a real consumer per G029; removes the duplicated inline exclusion). `scan-lib-selftest.sh` proves all three contracts; the state-transition-guard selftest stays green (verdict-identical retrofit). Wired into `framework-validate.sh`.

### IMP-012 — framework-validate tiering + bounded de-fork

- **Tiering:** `framework-validate.sh` gains `--tier=core|full` (default `full` runs every check exactly as before, so pre-push/release-check are unchanged) and `--list-tier=core|full` (dry-lists the core subset, exit 0, no execution). `core` runs the fast structural/lint/generator/scan subset. `framework-validate-tier-selftest.sh` (fast, non-circular via `--list-tier`) proves the core/full split + unknown-flag exit 2.
- **De-fork (BUG-005 continuation):** the per-EVERY-line boolean `echo "$line" | grep -qE` tests in `artifact-freshness-guard.sh` were converted to zero-fork bash `[[ =~ ]]` builtins with byte-identical ERE (verdict-preserving; selftest green). Case-insensitive once-per-heading classifications keep their `grep -qiE` form, mirroring BUG-005's rare-path principle.

### IMP-013 — per-repo framework drift signal (`bubbles-drift-check.sh`)

- **`bubbles/scripts/bubbles-drift-check.sh`** recomputes the sha256 of every vendored managed file against the installed `release-manifest.json` and reports per-file IN-SYNC / DRIFTED / MISSING plus ORPHAN framework scripts — a fast, read-only, no-network "am I drifted from the framework?" signal between upgrades. Exit 0 in-sync, 1 on drift/missing, 2 on malformed input; `--format json`. `bubbles-drift-check-selftest.sh` (7 cases) wired into `framework-validate.sh`; a non-blocking drift advisory added to `cli.sh doctor`. (The phase-2 surface-thinning study stays analysis-only — it would alter the `.checksums` trust model and must be ratified on its own.)

### IMP-014 — governance blast-radius hub report (`bubbles-hub-report.sh`)

- **`bubbles/scripts/bubbles-hub-report.sh`** composes the framework's OWN dependency graph from the authoritative in-repo SSTs/source (script source/call graph, agent/script shared-module includes, gate references) — deterministically, no LLM, no network — and ranks the most-depended-on nodes by in-degree so the blast radius of a change is visible BEFORE the change. `--node <id>` prints the exact provenance-tagged reverse-dependency closure; `--top N`; `--format text|json`. Exit 0 (informational) / 2 (usage); never 1. The live run surfaces the real hubs (`critical-requirements.md`, `agent-common.md`, `state-transition-guard.sh`, `cli.sh`, gate `G027`). `bubbles-hub-report-selftest.sh` (8 cases, fixture graph with known edges) wired into `framework-validate.sh`; a non-blocking hub snapshot added to `cli.sh doctor`. Borrows the *concepts* (degree centrality, reverse-dep query, edge-provenance tagging) from a graphify trial while REJECTING its fuzzy tree-sitter+LLM re-derivation of edges the SSTs already declare authoritatively.

### Bugs filed

- `BUGS.md` gains **BUG-006** and **BUG-007** (full artifacts: reproduction, proven root cause, expected behavior, landed fix), each marked fixed (working tree) per Gate G095 discovered-issue disposition.

### Execution provenance

- Improvement execution plans `improvements/IMP-007/008/009/010/011/012/013/014.md` were authored to scope this review pass, then DELETED on confirmed delivery (each was implemented as shipped scripts + hermetic selftests + framework-validate wiring, all green) per the improvements-doc lifecycle. The durable record is the shipped code + selftests + this CHANGELOG entry, not the plan docs. `improvements/IMP-001-observability-first-class.md` is now also DELETED on confirmed framework delivery: its framework deliverable (the `traceContracts.observability` posture/SLO contract, gates G098–G100, the four observability guards + the `prometheus` adapter + `observability-adapter-lint.sh` + the MCP `check_observability` tool) shipped in v7.10.x and is verified byte-identical across the canonical `bubbles/` tree and all five downstream `.github/bubbles/` trees, with the proof-of-adoption bar met on three wired repos (QF `085`, smackerel `090`, wanderaide `154`) that each carry a real captured-telemetry `slo:` link G100 enforces green. The two residual boxes are downstream-repo chores, not framework work, and are formally G095-deferred: SCOPE-8 T8.3 (a knb operator-doc paragraph naming the operate-plane `BUBBLES_OBS_*` env-injection path) and the optional SCOPE-9 guesthost 4th dogfood (the `≥1 wired repo carries a real slo: link` DoD threshold is already exceeded 3×). Neither blocks the shipped capability. The source repo keeps no persistent `specs/` per Gate G085.

## v7.12.1 — state-transition-guard Check 11 fork-storm fix (BUG-005)

> *"If the smoke detector takes two minutes to chirp, folks figure the trailer ain't on fire, Bubbles. Make it quick."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Fixes [`BUGS.md` BUG-005](BUGS.md) — `state-transition-guard.sh` Check 11 (report.md evidence-block legitimacy) took ~126s of wall-clock on a 4888-line `report.md` because the inline scan forked a subshell **per line** (the `echo "$line" | grep` fence test) and **8× per closed code block** (`echo "$block_content" | grep` signal tests). The guard returned a CORRECT verdict — this was purely a fork-storm performance defect that made any untimed downstream caller (e.g. a `knb` sweep test) appear to hang for ~2 minutes.

### Fix — Check 11 (and 3 sibling hot loops) converted to zero-fork bash builtins

- **Check 11 evidence-block scan:** fence detection is now `[[ "$line" == '```'* ]]` / `[[ "$line" == '```' ]]` (glob, zero fork). The 8 per-block signal greps are collapsed into **per-line distinct-category flag accumulation** inside the existing read loop — each of the 8 categories is OR'd as the block's lines stream by, then `signals = sum of the 8 flags` at block close. The verdict is **byte-identical**: a block is legitimate iff it has ≥3 lines AND ≥2 DISTINCT matching categories. A naive single `grep -cE` (which counts matching LINES, not categories, and would change the verdict) is intentionally NOT used. Case-insensitive categories (i/ii/iv/v/vii — original `grep -qiE`) run under `shopt -s nocasematch`; case-sensitive categories (iii/vi/viii — original `grep -qE`) run with it off. Per-line testing also preserves grep's line-oriented `^`/`$` anchor semantics. The now-unused `block_content` accumulator (an O(n²) string concat) was dropped.
- **Sibling hot loops also de-forked:** Check 4A (DoD format manipulation), Check 9 (per-`[x]` evidence-marker scan), and Check 12 (duplicate-evidence fence detection) had their per-line `echo|grep` boolean tests converted to bash `[[ =~ ]]` / glob builtins. `grep -oE | sed` extraction pipelines (which run at most once per matched line) are left as-is.

### Perf + correctness regression

- **`state-transition-guard-perf-selftest.sh`** gains a BUG-005 section that builds a synthetic ~5000-line `report.md` (≈1000 legitimate filler blocks + one exactly-2-category legit block + one single-category-repeated illegitimate block) and runs the real guard with `BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1`. It asserts (a) the whole guard completes in **< 30s** (the fork-storm took ~126s; measured **3s** on a 6036-line fixture), and (b) **exactly one** illegitimate block is detected — proving distinct-category counting survived and did NOT regress to matching-line counting.
- `state-transition-guard-selftest.sh` stays green (verdict semantics unchanged).

### Scope

- Canonical Bubbles source only. The guard is framework-managed downstream (`release-manifest.json`), so the fix re-vendors into the 5 product repos via the manifest on their next `/bubbles.setup` — a separate propagation step, not part of this commit. `release-manifest.json` regenerated (the guard + perf-selftest checksums change).

## v7.12.0 — release-delivery reconciliation gate (G101, IMP-006)

> *"You can't tell the boys the trailer's built when half the rooms got no floor, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Delivers `improvements/IMP-006-release-delivery-reconciliation.md` — closes the scenario-level *"claimed delivered / actually skipped"* hole. The downstream symptom: a `bubbles.goal`/`bubbles.workflow` scenario tasked to "deliver the MVP" reported SUCCESS while only ~35% of the MVP features in `docs/releases/mvp/features.md` were actually built (the rest were unspecced, stubbed, or self-certified). The per-spec anti-fabrication gates (G021/G024/G025/G028/G029/G097 + downstream lints) are rigorous — but they only fire for specs that EXIST and are routed through `validate`. A feature that is *promised in a release packet but never specced* has no `state.json`, so no per-spec gate can ever fail on it. The gap was invisible to every gate. G101 adds the missing release-phase reconciliation layer.

### New gate — G101 `release_delivery_reconciliation_gate`

- **`bubbles/scripts/release-delivery-reconciliation-guard.sh`** reconciles the PROMISED required-feature set in `docs/releases/<phase>/features.md` against the DELIVERED (terminal + validate-certified) spec truth. Each feature carries an HTML-comment machine binding authored by `bubbles.releases` (the visible prose tables are untouched): `<!-- bubbles:feature id=<id> spec=<spec-dir|none> delivery=required|optional|carried|deferred-to:<phase> -->`, with a packet opt-in header `<!-- bubbles:reconciled-packet schemaVersion=1 phase=<phase> -->`.
- For every `delivery=required` feature the guard verifies (1) the bound spec dir exists with a parseable `state.json`, (2) status is TERMINAL (`done` or the mode ceiling via `is-terminal-for-mode.sh`; `in_progress`/`not_started`/`blocked`/`done_with_concerns` are NOT terminal), and (3) the spec is VALIDATE-certified (`validate` in `certification.certifiedCompletedPhases[]` v3 or top-level `completedPhases[]` legacy) — so an implement self-certification with `validate` absent is a finding. This transitively closes the stub/fake-data half: forcing every required feature through `validate` re-runs the downstream per-spec reality scans (`no-fake-handler-data.sh`, `audit-ui-e2e-completeness.sh`) that only run under validate.
- **Posture:** RECONCILED (blocking) when the packet carries the `bubbles:reconciled-packet` header OR `--require-coverage` is passed (the `bubbles.goal`/`bubbles.sprint` convergence path); otherwise GRANDFATHERED (WARN-only, exit 0) so existing downstream packets backfill at their pace. FAIL-LOUD on malformed (a reconciled packet that binds nothing, a missing `id`/`spec`/`delivery`, a duplicate id, an invalid `delivery`, or a `required` feature with `spec=none`). A required feature whose spec is legitimately `blocked` with a reason is reported NOT-DELIVERED (blocked) — distinct from silently-skipped. Bubbles SOURCE checkout auto-exempt (no `docs/releases/`). No `--skip`/`--force`/`--ignore` bypass.
- **Hermetic selftest** `release-delivery-reconciliation-guard-selftest.sh` — 12 scenarios (S0–S11) including the exact downstream replay (S2: a reconciled `mvp` packet whose required feature binds a non-existent spec dir → exit 1), implement-self-cert (S4), the silent-no-op trap (S5), grandfather vs `--require-coverage` (S6/S7), and source-repo EXEMPT (S10).

### Scenario coverage — compile-time twin (Hole A)

- **`scenario-compile-lint.sh`** now reads an optional `rootOutcome.targetReleasePacket: <phase>` on the scenario DAG. When set and the phase's `features.md` is reachable, every `delivery=required` feature MUST be covered by some `delivery`-type node's `coversFeatures[]` — an under-scoped DAG (a promised required feature with no delivery node) is rejected at compile time before execution. Two new selftest cases (covered → exit 0; under-scoped → exit 1).

### Convergence binding (Hole B)

- **`bubbles.goal`** and **`bubbles.sprint`** root-outcome verification now runs `release-delivery-reconciliation-guard.sh --phase <phase> --require-coverage` for any release-phase scenario and treats a non-zero exit as a NON-terminal convergence state — loop back to create/route the missing required-feature specs, or end `blocked` — NEVER EXIT_SUCCESS. Documented in `agents/bubbles_shared/scenario-compile.md` → Root-Outcome Verification.

### Ownership + knowledge surfaces

- **`bubbles.releases`** owns the `bubbles:reconciled-packet` header + per-feature annotations in `features.md` and an OPTIONAL generated `docs/generated/release-reconciliation-<phase>.md` audit note (under `docs/generated/`, NOT a 9th packet doc — `release-packet-location-guard.sh` unaffected). Documented in the releases agent + `skills/bubbles-release-packet-template/SKILL.md`.
- Registered as G101 in `bubbles/registry/gates.yaml` + `bubbles/workflows.yaml`; rationale entry in `agents/bubbles_shared/quality-gates.md` (range note updated: G101 used, G102–G109 reserved) + quick-ref row in `skills/bubbles-quality-gates-catalog/SKILL.md`; TPB vocabulary term `release-delivery reconciliation`; `bubbles.super` NL-routing; release-planning recipe section. Wired into `framework-validate.sh` (selftest + live guard, source-repo EXEMPT). Full framework-validate + release-check green.

### Execution provenance

- **Execution plan:** `improvements/IMP-006-release-delivery-reconciliation.md` (deleted on delivery per the improvements-doc lifecycle; recoverable from git history). The source repo keeps no persistent `specs/` per Gate G085 — the framework dogfood evidence gate.
- IMP-002/003/004/005 improvement docs deleted on confirmed full delivery (their gates/skills/docs are shipped and validated in-tree); IMP-001 retained (downstream SCOPE-7..9 still pending per-repo adoption).

### Bundled — PII/agnosticity hardening (BUG-004)

- Scrubbed real downstream product names out of the framework's docs and test fixtures (`improvements/IMP-001`, the deleted `IMP-006`, `docs/v4.1.0-delivered-pending-activation.md`, `CHANGELOG` history, `BUGS.md`, and several guard selftests) per `docs/SCOPE_POLICY.md` — the repo stays product-agnostic.
- Fixed **BUG-004**: `agnosticity-lint.sh` no longer uses a hardcoded downstream-name list (which both false-positived on the installer's `bubbles-<slug>` MCP-id token and silently under-checked unlisted products). It now derives the repo's own project slug and exempts the `bubbles-<slug>` token on agent `tools:` lines; an adversarial `agnosticity-lint-selftest.sh` case proves a genuine bare project-name leak is still flagged.
- Untracked runtime session state (`.specify/memory/bubbles.session.json`) and added it to `.specify/memory/.gitignore`, matching the sibling runtime files (`developer-profile.md`, `skill-proposals*.md`).

## v7.11.3 — IMP-005 curated gate-catalog backfill + non-blocking freshness advisory

> *"You can't keep addin' rooms to the trailer and never update the map, Bubbles. Folks get lost."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Closes the IMP-005 documentation gap — the prose gate-catalog (`quality-gates.md`) had drifted to a ~G081 ceiling while the registry shipped through G127. Backfilled the catalog and added a non-blocking advisory so the gap can never silently reopen. No gate, schema, or enforcement change — docs + one advisory script.

### SCOPE-1 — `quality-gates.md` Gate Family Reference (G082–G127)

- Added a grouped **`## Gate Family Reference (G082–G127)`** section: Convergence/context (G082–G086), Planning/spec (G087–G091), Terminal/delivery (G092–G093), Capability/discovery (G094–G095, G097), Observability (G098–G100), Release-train/upkeep (G110–G120), Propagation (G121–G123), Incident/framework-health/model-tier/capability-consumer (G124–G127).
- Each entry carries the registry-accurate gate name + one-line rationale + enforcing guard script. Range statement corrected to G001–G127 (notes G096 burned, G101–G109 reserved gap, registry as single source of truth, `gate-meta.sh <id>` for the authoritative entry).

### SCOPE-2 — non-blocking gate-catalog freshness advisory

- **New `bubbles/scripts/gate-catalog-freshness.sh`** — compares the registry's highest gate id against the curated ceilings in `quality-gates.md` and `skills/bubbles-quality-gates-catalog/SKILL.md`. ALWAYS exits 0 (advisory, mirrors `repo-drift-report.sh`); WARNs to stderr when a catalog ceiling lags the registry. No-op when no registry present.
- Wired into `framework-validate.sh` as an informational check (after `repo-drift-report`). Shellcheck clean. Adversarial proof: a synthetic G100-ceiling catalog against a G127 registry emits two WARN lines but still exits 0 (non-blocking contract holds); current tree prints *"curated gate catalogs are current with the registry (ceiling G127)"* exit 0.

## v7.11.2 — framework-health recipe ↔ G127 cross-reference

**Theme:** Documentation polish completing the v7.11.x G127 line. The `framework-health` recipe reads `bubbles/capability-ledger.yaml` to flag stale capabilities; G127 now *enforces* consumer freshness on that same ledger. Added a one-line cross-reference so the analysis recipe points at the enforcement gate (the retro *nudge* vs the blocking *gate* relationship is now explicit). No code, gate, or schema change.

## v7.11.1 — G127 shape-not-substance fix + gate-catalog band

> *"A lock that opens for a blank key ain't a lock at all, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A critical review of the v7.11.0 G127 delivery found one real defect in the new guard and two gate-catalog gaps. All fixed; full framework-validate green.

### Fix — empty/blank-only `consumers:` no longer pass G127 (shape-not-substance hole)

- **`capability-consumer-freshness.sh` now counts NON-EMPTY consumers.** v7.11.0 based the ORPHAN check on the raw array size, so a `state: shipped` capability declaring `consumers: ["", ""]` (all blank) slipped through with exit 0 and the self-incriminating message *"OK … 0 consumer path(s) verified present."* — the exact shape-not-substance FAILURE CONDITION the IMP-004 risk register names. The guard now orphans a blank-only list and flags any stray blank entry as `MALFORMED` (fail loud) instead of silently `continue`-skipping it.
- **Selftest 16 → 19 cases:** added all-blank → ORPHAN, all-blank names the capability, and real+blank → MALFORMED adversarial cases. Proven: the exact `consumers: ["", ""]` fixture that returned exit 0 in v7.11.0 now returns exit 1.

### Fix — gate-catalog quick-ref is ID-current (G110–G127 band)

- **`skills/bubbles-quality-gates-catalog/SKILL.md`** previously stopped at G100. Added a compact `G110–G126` band row (release-train / upkeep / propagation / incident / framework-health / model-tier gates) + a dedicated `G127` row, restoring the quick-ref's "look up any gate by ID" completeness.

### Identified improvement — IMP-005 (deeper rationale-doc backfill)

- **Filed `improvements/IMP-005-curated-gate-catalog-backfill.md`** (per G095 discovered-issue disposition): the rationale-bearing module `agents/bubbles_shared/quality-gates.md` enumerates gates only through ~G081 and needs a G082–G127 backfill. Scoped as docs-only with an optional non-blocking freshness advisory — too large for a drive-by review edit, so tracked as a proposal.

## v7.11.0 — capability-consumer freshness gate (G127, IMP-004)

> *"You can't be the decency police and let your own trailer go to shit, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Delivers `improvements/IMP-004-capability-consumer-freshness.md` — the durable, framework-wide fix for the "orphan foundation" failure class that v7.10.1 only patched for the two observability entries. The framework stops exempting its OWN capability ledger from the G029 integration-completeness standard it enforces downstream.

### New gate — G127 `capability_consumer_freshness_gate`

- **Every `state: shipped` capability in `bubbles/capability-ledger.yaml` MUST now declare a non-empty `consumers:` list whose every path exists on disk.** This is the G029 standard ("every shipped artifact has a real consumer") applied to the framework's own ledger. `partial` / `proposed` / `deprecated` capabilities are exempt (no-op).
- Enforced by **`bubbles/scripts/capability-consumer-freshness.sh`**: a repo with no ledger (every downstream product checkout) no-ops via a parser-free pre-check that runs BEFORE the fail-closed parser gate; a missing `yq` fails closed (blocking gate) ONLY when a ledger is present; there is **no `--skip`/`--force`/`--ignore` bypass**. An orphan shipped capability is a real finding — wire a consumer or downgrade the `state`.
- Existence check (not semantic-reference): proves each declared consumer file is present. Choosing consumers that genuinely invoke the owner is the authoring contract; a future G097-style semantic-grep enhancement can layer on without changing the gate contract.
- Hermetic selftest **`bubbles/scripts/capability-consumer-freshness-selftest.sh`** (16 cases): shipped-with-consumers PASS; shipped-no-consumers FAIL (ORPHAN); shipped-dangling-consumer FAIL (DANGLING); one-good-one-dangling adversarial FAIL; proposed/partial/deprecated no-op PASS; no-ledger no-op PASS; ledger-present-without-yq fail-closed; no-ledger-without-yq still no-ops; bypass flags rejected (exit 2); `--help` exit 0. Both the selftest and a live ledger guard are wired into `bubbles/scripts/framework-validate.sh`.

### Ledger backfill — all shipped capabilities now declare real consumers

- **`consumers:` backfilled for all 17 shipped capabilities** that lacked it (the 2 observability entries already had it from v7.10.1). Every listed consumer is a real, existing executable surface that invokes/references the owner (e.g. `workflow-orchestration` → mode-resolver + state-transition-guard + workflow agent; `artifact-ownership` → agent-ownership-lint + selftest; `session-aware-runtime-coordination` → cli.sh + framework-validate + lease selftest). The live guard verifies **61 consumer paths across 19 shipped capabilities** all exist.
- **The gate dogfoods itself:** `capability-consumer-freshness` is itself registered as a shipped capability (consumers: framework-validate.sh, its selftest, gates.yaml), so it must satisfy its own rule. Ledger state summary is now **20 shipped, 1 partial, 0 proposed**.
- `IMP-004` status moved from PROPOSED to delivered.

### Notes

- One new gate ID (G127), one new capability, no new workflow mode. Registry now declares 107 gates.
- Regenerated: `workflows.yaml` gates block, `docs/generated/competitive-capabilities.md`, `docs/generated/interop-migration-matrix.md`, README capability row, framework-stats, release manifest.

## v7.10.1 — observability enforcement teeth + orphan-root-cause follow-up

> *"A lock you never check ain't a lock, Bubbles — it's a decoration."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A critical review of v7.10.0 found the observability posture model had no downstream teeth and the "orphan → live" claim was only half-true. This patch closes all four findings with real, tested wiring (no new gate IDs; G098/G099/G100 unchanged in number, now actually enforced).

### P0 — Posture model now enforced at the universal done-gate

- **G098/G099/G100 are now wired into `state-transition-guard.sh`** (Checks 37/38/39, via `bubbles/scripts/guards/tail-delegated-gates.sh`). v7.10.0 wired them only into source-repo `framework-validate.sh` (which self-EXEMPTs), so the posture/SLO model was **inert in every downstream repo**. Now every repo's done-certification runs them. Proven end-to-end: a wired+instrumented fixture with breaching SLO evidence blocks (exit 1); within-target passes (exit 0).
- **`observability-slo-guard.sh` is now non-adopter-safe.** A parser-free, builtins-only opt-in pre-check runs BEFORE the fail-closed jq/yq gate, so a repo that never adopted observability no-ops even without jq/yq (the fail-closed requirement applies ONLY to repos that opted in). This is what makes G100 safe to wire into the universal done-gate. The pre-check is indentation-aware: it recognizes adoption ONLY as a `traceContracts:` parent with an indented `observability:` child, so a comment-only `# observability:` mention or an unrelated `not_observability:` key never trips it. Selftests prove a non-adopter without any parser is never blocked, including the comment-only and unrelated-key cases (34/34 SLO selftest).

### P1 — Resolver is now a real executable consumer (orphan actually closed)

- **`observability-endpoint-resolve.sh` gains a `--names-only` read-only mode** (reports `adapter=`/`profile=` without materializing or requiring plane-scoped secret env) and **`observability-check.sh` now invokes it** for all 4 signals × 2 planes, surfacing an `endpoints` block in the `check_observability` verdict. v7.10.0's resolver + adapter fetch verbs had ZERO executable consumers (only agent-prompt prose); now a shipped script behind the MCP tool consumes the resolver. A new hermetic `observability-check-selftest.sh` (wired into `framework-validate.sh`) stages a wired fixture and asserts the full JSON envelope reports `endpoints.validate.sloBurn == prometheus` (and the expected `none` entries). Resolver selftest 38/38; observability-check selftest 12/12.
- **`consumers:` field added to `capability-ledger.yaml`** (both observability entries) + declared in `capability-ledger.schema.json`. The listed consumers are real (state-transition-guard, observability-check, ops agents).
- **Systemic root cause filed as `improvements/IMP-004-capability-consumer-freshness.md`.** v7.10.0 routed the durable fix to a "candidate IMP-002" that never materialized (IMP-002 shipped as supply-chain locking). IMP-004 is the real follow-up: a framework-dogfood freshness check requiring every `state: shipped` capability to declare existing consumers. The dangling phantom reference in IMP-001 is corrected.

### P2 — Prometheus adapter live path now actually normalizes (and is tested)

- **`fetch-slo-burn` / `fetch-error-rate` / `fetch-deploy-impact` now normalize** the raw Prometheus vector envelope to the contracted bare map shape (`normalize_query_map` / `normalize_deploy_impact`). v7.10.0's live query verbs emitted the **raw provider envelope** — non-compliant with the documented map contract — and the adapter-lint never caught it because it only checked hand-written `selftest` shapes. The `selftest` query verbs now drive canned raw envelopes through the SAME normalizers (matching `fetch-alerts`), so the shape selftest proves real normalization.
- **New `bubbles/scripts/prometheus-adapter-fetch-selftest.sh`** exercises every live verb end-to-end against a shadowed `curl` returning canned raw envelopes — proving the real curl→normalize pipeline (verb dispatch, exact URL-encoded query construction, normalization) yields the contracted shapes, including empty-vector responses normalizing to `{}` (17/17). Wired into `framework-validate.sh`.

### Notes

- No new gate IDs, no new workflow mode. G098/G099/G100 are the same gates, now enforced downstream.
- New selftests wired into `framework-validate.sh`: prometheus live-fetch, observability-check wired-fixture envelope, and observability-check live smoke.
- `capability-ledger-selftest.sh` now asserts every path in the two observability `consumers:` lists exists on disk, so the consumer claim is mechanically verified (not prose-only) ahead of the full IMP-004 freshness gate.
- Release manifest, framework-stats, and capability-ledger docs regenerated.

## v7.10.0 — observability as a first-class citizen + operator/contributor guidance

> *"You can't fix what you can't see, Bubbles. Put the kitty-cam on prod and watch it like the kitties."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Two improvements ship together. **IMP-001** makes observability a first-class Bubbles concern: every repo must *declare a posture* (`wired` / `opted-out` / undeclared), wired repos must *prove telemetry + SLOs* in integration/e2e/stress, and ops agents *consume live operate-plane telemetry* during incidents, promotes, and SLO reviews — while opt-out stays a legitimate, recorded, expiring choice. It also converts the v5 observability-adapter layer (which shipped mechanism + lint + skill but had **zero wired consumers** — a G029 orphan foundation) into a live capability. **IMP-003** closes two guidance gaps: an operator-facing effective-prompting guide and a contributor-facing MCP "when to graduate a script to a tool" rubric.

### IMP-001 — Observability first-class

- **New contract `traceContracts.observability`** (nested under the existing, already-parsed `traceContracts:` key — never renamed, R2-C). Carries `schemaVersion`, tri-state `posture`, `policy.undeclaredPosture`, `decision`, `optOut` (reasonCode/reason/revisitAfter/approvedBy), two-plane `endpoints` (validate→ephemeral test stack, operate→prod), and `slos`. **Clean cutover:** the orphan v5 `liveTelemetryEndpoints` flat map is DELETED in the same change (no consumer existed, so no deprecation cycle).
- **Three new gates.** **G098** `observability_posture_declared_gate` (WARN-default nag; project-flippable to blocking), **G099** `observability_opt_out_freshness_gate` (route-required when committed `revisitAfter` lapses), **G100** `observability_slo_evidence_gate` (BLOCKING when `posture: wired` and an instrumented scope targets a workflow with an `slo:`). **G080** trace-contract language upgraded SHOULD → MUST-when-wired; **G026** stress/load now cites the SLO registry when wired (no double-enforcement with G100). Registry now defines **106 gates**. G096 stays burned.
- **New guards + selftests** (all NO-bypass, hermetic, framework-validate-wired): `observability-posture-guard.sh`, `observability-opt-out-guard.sh`, `observability-slo-guard.sh`, `observability-endpoint-resolve.sh` (plane→adapter+profile resolver, fail-loud, validate-plane cannot read operate env), plus `observability-check.sh` (one-shot posture+SLO+trace verdict). SLO guard fails loud on malformed/wrong-workflow evidence before any numeric compare; selftests include **adversarial-observability** cases (a regressed observed value / dropped metric MUST fail).
- **Breaking adapter-payload normalization (R2-D).** `none.sh` now returns `[]` for `fetch-alerts` and `{}` for the other three verbs; `prometheus.sh` normalizes the raw alerts envelope to a bare array; `observability-adapter-lint.sh` asserts per-verb shapes (array for alerts, object for the rest) with an adversarial case proving a raw provider envelope is rejected.
- **`bubbles doctor` Observability Posture line** (advisory; never changes doctor's exit code) renders WIRED / OPTED-OUT until <date> / OPT-OUT EXPIRED ⚠ / UNDECLARED ⚠ / EXEMPT.
- **`bubbles.setup focus: observability`** routine: read-only stack discovery → PROPOSE (`wired` with endpoints+SLO stubs, or `opted-out` with reason/revisit) → WAIT → APPLY; never auto-writes config; handles traceContracts-only migration, wired→opted-out decommission, and the legacy-key clean cutover. `install.sh` prints a non-blocking posture reminder and never writes `bubbles-project.yaml`.
- **Ops agents consume operate-plane telemetry (orphan → live).** `bubbles.stabilize` fetches alerts/error-rate/deploy-impact FIRST during a wired incident and routes rollback to `bubbles.train`; `bubbles.upkeep` adds a `slo-review` task (weekly, wired only) routing burning SLOs to stabilize (opt-out reminders stay guard/doctor-owned, INV-9); `bubbles.train` gates promote/rollback on operate-plane deploy-impact + SLO burn (read-only, INV-12); `bubbles.devops` owns the wiring-execution boundary. New **MCP tool `check_observability`** (11 tools total) wraps the `observability-check.sh` bash twin; reads flow through `record_evidence` for provenance.
- **DoD injection + design template.** `scope-workflow.md` auto-adds telemetry-captured + SLO-met DoD items for wired instrumented scopes (with the "3 AM reconstructibility" acceptance heuristic); the `design.md` template gains an optional `### Trace Topology` section (required for wired service-bearing instrumented scopes); `agent-common.md` gains the "evidence is the agent's sensory input" (Loopy-AI) philosophy note. Explicit `observabilityWorkflow` Test Plan field added to `planning-core.md` + `project-config-contract.md`.
- **Isolation preserved.** Validate-plane telemetry is `env=test*` only (G115); new env-pollution + resolver selftests prove an `env=prod` test write blocks and a validate resolution cannot reach operate env. New template `templates/observability.yaml.tmpl` + fixtures under `bubbles/tests/fixtures/observability/`.
- **Execution plan:** `improvements/IMP-001-observability-first-class.md` (SCOPE-1..6 delivered in the source repo; SCOPE-7 downstream dogfood, SCOPE-8 source/knb posture, SCOPE-9 downstream propagation applied per-repo) — DELETED on confirmed framework delivery per the improvements-doc lifecycle; see the v7.13.0 `### Execution provenance` note above for the deletion rationale and the two G095-deferred downstream chores.

### IMP-003 — Operator & contributor guidance

- **New operator guide `docs/guides/EFFECTIVE_PROMPTING.md`** — good-request checklist, anti-patterns, and an "intent over runbook" section tying crisp outcomes to `bubbles.goal` / `bubbles.workflow`; linked from `docs/CATALOG.md` + `README.md` and surfaced by `bubbles.super`.
- **MCP graduation rubric** added to `docs/MCP.md` ("When to graduate a script to an MCP tool") — stay-a-script vs add-a-thin-tool criteria that restate the non-negotiable bash-twin-canonical invariant (the server never holds logic); cross-linked from `docs/v6-mcp-design.md` + `docs/guides/AGENT_MANUAL.md`. Docs-only; no new gate/guard/schema.
- **Execution plan:** `improvements/IMP-003-operator-contributor-guidance.md`.

### Notes

- No existing repo breaks on upgrade: undeclared posture is WARN by default; the Bubbles source repo auto-resolves to `no-runtime` EXEMPT.
- Capability ledger, framework stats, cheatsheet, and release manifest regenerated; lockstep propagation to downstream `.github/bubbles/` trees flows via each repo's `install.sh`.

## v7.9.0 — build-time dependency-source locking + up-front complexity justification

> *"It don't matter how good the lock on the shed is, Bubbles, if you let any stranger hand you the parts that go inside it."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Bubbles was already strong on *deploy-time* artifact provenance (cosign keyless + SLSA build-provenance + SBOM + Trivy, enforced in the knb deploy adapters) but said nothing about where dependencies are RESOLVED FROM at *build* time — leaving dependency-confusion, typosquat, and malicious-mirror exposure ungoverned. It also had simplicity *principles* and a post-hoc `bubbles.simplify` agent, but no requirement to justify ADDED complexity up front with rejected alternatives. v7.9.0 closes both gaps with two reusable, toolchain-agnostic governance additions — **no new enforcement gate, no new script, no new workflow mode**.

### What changed

- **New skill `bubbles-supply-chain-source-locking`** + **binding instruction `instructions/bubbles-supply-chain-source-locking.instructions.md`** (`applyTo: "**"`). The rule: build-time dependency resolution MUST be locked to an explicit allowlist of trusted sources; arbitrary/implicit upstreams are forbidden. Each downstream repo wires the ecosystem-appropriate source check into its EXISTING blocking lint/pre-push gate — Rust (cargo-deny `[sources]` with `unknown-registry`/`unknown-git = "deny"` + a single `allow-registry`), Node (pinned `.npmrc` registry + committed lockfile + `npm ci`), Go (`GOFLAGS=-mod=readonly`, pinned `GOPROXY`, committed `go.sum`, no checksum-disable knobs), Python (single `--index-url`, hash-pinned requirements, no `--extra-index-url` fall-through) — with no `--skip`/`--force` bypass.
- **Explicitly distinguished from deploy-time provenance.** The skill and instruction carry a "Two Axes" section that separates *build-time SOURCE locking* (this policy) from *deploy-time artifact PROVENANCE* (cosign/SLSA/SBOM/Trivy, owned by `bubbles-deployment-target-adapter`) and cross-links the two as complementary controls rather than duplicating them. A repo needs both; neither substitutes for the other.
- **Both design templates gain a `## Complexity Tracking` section** — the feature design template (`agents/bubbles_shared/feature-templates.md`, columns `Decision | Simpler alternative considered | Why rejected`) and the bug-fix design template (`agents/bubbles_shared/bug-templates.md`, columns `Decision | Simpler fix considered | Why rejected`, framed for deviation from the minimal fix). If a design introduces no deviation from the simplest viable approach, the author records `None — simplest viable approach used.` (feature) / `None — simplest viable fix used.` (bug fix); only deviations need rows. This is a lightweight documentation discipline, NOT a blocking gate. `bubbles.design` requires the section on both surfaces.
- **No new gate, no new workflow mode, no new script.** Policy A is enforced by each downstream repo's existing lint/pre-push gate using the ecosystem's native tool; Policy B is a template/authoring discipline. `skills/INVENTORY.md` updated; the release manifest regenerated.
- **Execution plan:** `improvements/IMP-002-supply-chain-source-locking-and-complexity-tracking.md` (the source repo keeps no persistent `specs/` per Gate G085 — the framework dogfood evidence gate).

## v7.7.0 — restricted orchestrators bind the per-repo MCP server (token materialization + newline fix)

> *"You renamed everybody's clicker to stop the fightin', Bubbles — but then the five remotes in the drawer were still callin' out the old name and turnin' on nothin'. Make 'em say the new name."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** v7.5.0 gave the framework MCP server a UNIQUE per-repo id (`bubbles-<repo-slug>`) so VS Code 1.118+ stops dedup-disabling it in multi-root workspaces. But the five restricted orchestrators (`bubbles.goal`, `bubbles.sprint`, `bubbles.iterate`, `bubbles.bug`, `bubbles.workflow`) ship a `tools:` allowlist that still named the generic `bubbles` server — now a dead token the IDE silently ignores. So the server started, but those five autonomous agents never bound it; they fell back to bash twins. v7.7.0 closes that gap: the `bubbles` token is the canonical **placeholder**, materialized per-repo to `bubbles-<repo-slug>` in the installed agents so they actually bind the running server. Investigating it also surfaced a latent newline bug in the v7.1 grant machinery, fixed here.

### What changed

- **Per-repo MCP server-token materialization.** `bubbles/scripts/mcp-grant-reconcile.sh` gains `bubbles_mcp_server_token`, which returns `bubbles-<repo-slug>` in a downstream install layout (`.github/bubbles/scripts`) and the canonical `bubbles` in the Bubbles source layout. The slug algorithm is byte-identical to `install.sh`'s MCP-registration step, so the agent token always matches the registered `.vscode/mcp.json` server id. `inject` materializes the placeholder; `reconcile` (used by the downstream write guard) normalizes the per-repo token back to `bubbles` before hashing — so the canonical `.checksums` still matches and a materialized agent stays drift-clean, exactly like a stripped grant. The Bubbles source repo keeps canonical `bubbles` (no materialization).
- **`mcp sync` materializes even with no operator grants.** Because `inject` now materializes, the existing `install.sh` post-copy `mcp sync` step rewrites the five orchestrators to the per-repo token automatically — no new install step, no operator action.
- **Latent trailing-newline bug fixed.** `agents/bubbles.workflow.agent.md` shipped without a trailing newline; the grant-sync awk rewrite always re-emits a final newline, so any `mcp sync` added a byte and drifted `workflow` from `.checksums` (breaking the v7.1 grant feature for that one agent). The agent now ends with a newline, and `mcp-grant-selftest.sh` asserts all five restricted source agents do (regression T13).
- **Selftest coverage.** `mcp-grant-selftest.sh` grows to 22 assertions: the materialization round-trip (inject → `bubbles-<slug>`; reconcile → canonical), a downstream end-to-end reconcile that proves the write guard stays green, the "grant equal to the server token is not double-appended" case, and the restricted-agent newline invariant.
- **Docs.** `agents/bubbles_shared/project-config-contract.md` (`mcp.grants` contract), `docs/MCP.md`, and `docs/guides/AGENT_MANUAL.md` document materialization and the write-guard normalization.
- **No new gate, no new workflow mode.** Pure lib + selftest change, consistent with the v7.1 grant trust model: the trust anchor stays on the canonical `.checksums`.

## v7.6.0 — goal scenario compiler: cross-repo, approval-gated, depth-safe missions

> *"One plan, boys. From the napkin to the park bein' online — and nobody deploys till I say go."*

**Theme:** Operators kept asking for one outcome bigger than a single spec — "get this repo ready for my target and ship it; the adapter repo owns the target details; deliver everything, deploy, then stand up ongoing ops." Until now that meant either a priority-picker (`iterate`, wrong semantics) or hand-running a chain of modes. v7.6.0 adds the **Goal Scenario Compiler**: `bubbles.goal` (single outcome) and `bubbles.sprint` (multi outcome) compile a high-level outcome into a typed, dependency-ordered, possibly cross-repo DAG whose nodes each resolve to an EXISTING workflow mode or specialist — no new per-journey workflow modes, no orchestrator nesting.

### What changed

- **New shared contract `agents/bubbles_shared/scenario-compile.md`.** Defines the scenario DAG schema, node types (`diagnostic`/`planning`/`delivery`/`verification`/`action`/`ongoing-ops`), the per-repo execution + per-repo validate-owned certification boundary, the pre-mutation approval-token gate for host-mutating action nodes (the propagate pattern), the runtime plan/ledger under `.specify/runtime/`, and the root Outcome Contract (Gate G070 shape) verified at the end.
- **`bubbles.super` is scenario-aware (resolver only).** Its `RESOLUTION-ENVELOPE` gains optional cross-repo fields (`goalClass`, `primaryRepo`, `supportingRepos`, `targetEnvironment`, `deploymentModel`, `constraints`, `compositionHint`) plus a scenario-detection resolution rule and a discovery-source row. `super` still resolves intent ONLY — it never compiles or executes the DAG.
- **`bubbles.goal` / `bubbles.sprint` compile + execute.** goal converges a single declared outcome; sprint executes a multi-outcome mission in dependency order (not effort-reorder). Both keep execution depth ≤ 1 by parent-expanding each node in the top-level runtime.
- **New lint `bubbles/scripts/scenario-compile-lint.sh` + hermetic selftest.** Validates a compiled scenario DAG: no node resolves to a `requiresTopLevelRuntime` fan-out mode (Gate G064 depth safety — the forbidden set is DERIVED from `modes.yaml` so it never drifts), every node references a real mode/agent and a declared repo, action nodes are fully gated (`approvalRequired` + `riskClass` + `opsPacket`), `dependsOn` is an acyclic DAG, and `rootOutcome` is a complete Outcome Contract. Wired into `framework-validate.sh`; second-line persistent regression at `tests/regression/test_20_scenario_compile.sh`.
- **Routing + discovery.** `bubbles/intent-routes.yaml` gains scenario phrases → (`bubbles.goal`, `autonomous-goal`) and (`bubbles.sprint`, `autonomous-sprint`). New capability-ledger entry `cross-repo-scenario-orchestration`. New recipe `docs/recipes/cross-repo-scenario.md` (#54), WORKFLOW_MODES "Goal Scenarios Are Not Workflow Modes" section, and TPB aliases `i-got-a-plan-boys` (goal) / `the-whole-operation` (sprint).
- **No new certification gate, no new fan-out mode.** The scenario is data + a lint, mirroring the observability/intent-routes lint pattern. Completion stays spec/scope/DoD/validate-owned per repo (Gates G024/G025/G056).

## v7.5.0 — transparent multi-root MCP: installer auto-registers a unique per-repo server id

> *"You can't share one remote between four trailers and expect the TV to come on, Bubbles. Everybody gets their own clicker."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** The Bubbles MCP server shipped since v6.0, but registering it was a manual copy-the-sample-config step, and every repo used the same server id (`bubbles`). VS Code 1.118 deduplicates MCP servers that share a name and **disables all but one** — so in a multi-root workspace with several Bubbles repos, only one repo's server stayed enabled and the rest silently went dark (showing a perpetual "refresh tools" and never being used). The fix makes registration automatic and collision-proof: the installer writes a **unique per-repo** server id so every repo's server stays enabled, and the agent uses it with no manual steps beyond VS Code's one-time trust prompt.

### What changed

- **New installer step `register_mcp_vscode`.** `install.sh` now writes/merges a `bubbles-<repo-slug>` server entry into the repo-root `.vscode/mcp.json` on every install/upgrade. The slug is derived from the repo directory name (lowercase, non-alphanumeric → `-`). The step is idempotent, creates the file if absent, migrates a legacy generic `bubbles` entry (preserving any operator-added `env`), leaves every other server in the file untouched, and skips an unparseable file rather than clobbering it. python3-gated; warns (never fails) when python3 is absent.
- **Declared in the installer manifest.** `bubbles/installer/installer.yaml` gains a `register_mcp_vscode` step (new `mcp_register` step type, marker `Registering Bubbles MCP server`) so `generate-installer.sh --check` and its adversarial selftest enforce the step stays present.
- **Why unique ids (VS Code 1.118 dedup).** When multiple workspace folders register a server under the same name, VS Code keeps only the most-specific one enabled and disables the others. A per-repo id sidesteps the dedup so all repos' servers coexist and stay enabled. The default Agent auto-selects enabled MCP tools, so transparent use needs no agent tool-list edits; the only remaining gate is VS Code's one-time per-server trust confirmation (a security control the installer does not bypass).
- **Docs.** `docs/MCP.md` (auto-registration + multi-root troubleshooting), `docs/guides/AI_ENVIRONMENT.md` and `agents/bubbles_shared/project-config-contract.md` (Bubbles manages exactly its one unique-id entry; the rest of `.vscode/mcp.json` stays project-owned).

## v7.4.0 — requirement-mechanism correspondence gate (G097): named mechanism must trace to code or a disclosed justification

> *"Sayin' you put a deadbolt on the door don't mean there's a deadbolt on the door, Bubbles. I gotta be able to grab the handle and check."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A connector shipped green claiming OAuth2 + PKCE, but the implementation used a static bearer token — no PKCE anywhere. Self-consistent tests passed against an in-process fake, a paraphrased report over-claimed delivery, and the certification layer waved it through because every existing gate checks *shape*, not *requirement-to-code correspondence*: G021 verifies a command RAN (tests can pass against a fake), G028 verifies a real call is MADE (a real call with the wrong auth passes), and traceability-guard verifies a test EXISTS (not that it asserts the correct behavior). The gap was only caught later by a reconcile/`gaps` sweep that ran the one mechanical check that works — *"a requirement names a mechanism → grep the code for it"*. G097 pulls that check forward from a later sweep into certification.

### What changed

- **New gate G097 (`requirement_mechanism_correspondence_gate`).** When `spec.md`/`design.md`/scope files name a concrete mechanism (PKCE, OAuth2, refresh_token, CSRF, HMAC, mTLS, SAML, WebAuthn, TOTP, Content-Security-Policy, HSTS, Idempotency-Key), the guard greps the scope's declared implementation files (same backtick-path extraction as G028) for that mechanism or a known synonym. Pure comment lines are stripped before matching, so a `// TODO: PKCE` over bearer-only code does NOT count as implementing PKCE.
- **Warn-and-require-justification, not blind hard-block.** A named mechanism is cleared by EITHER code evidence OR an explicit disclosure — a `## Requirement-Mechanism Justifications` section (in `spec.md` or `report.md`) or a `Mechanism-Justification: <mechanism> — <reason>` line. A legitimate differently-named mechanism is never blocked; only a mechanism named with NEITHER code evidence NOR a justification is a finding. Honest disclosure over mechanical green.
- **Two advisory nudges (never change the exit code).** (#4) a security mechanism named with no negative/rejection assertion in the scope's tests — the environment-independent adversarial case that fails if the bug is reintroduced; (#3) a live-tier (integration/e2e) test backed only by an in-process fake server (`httptest.Server`/`MockWebServer`/`WireMock`) that does not exercise the real external contract.
- **Grandfather clause.** Specs whose `state.json.createdAt` is absent or earlier than 2026-06-08 are WARN-only, so the upgrade never retroactively blocks closed downstream work; only specs created on/after the cutoff get blocking enforcement.
- **Wiring.** `bubbles/scripts/requirement-mechanism-guard.sh` + hermetic `requirement-mechanism-guard-selftest.sh`; registered in `bubbles/registry/gates.yaml` (and the generated `bubbles/workflows.yaml` gates block); invoked by `state-transition-guard.sh` as Check 36; persistent regression `tests/regression/test_19_requirement_mechanism.sh`; wired into `framework-validate.sh`.
- **Gate id G096 is intentionally skipped** — it was burned by the reverted phantom 7.3.0 orchestrator-artifact-write-guard experiment (see 7.3.1/7.3.2 below) and is not reused, to keep the historical record unambiguous.

## v7.3.2 — installer prunes stale framework scripts on upgrade

> *"When you swap the engine, Bubbles, you take the old busted one OUT — you don't just leave it rattlin' in the trunk."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** `install.sh` copied framework scripts into a downstream but never removed scripts that no longer exist upstream. When the phantom 7.3.0 added four G096 scripts (`orchestrator-artifact-write-guard.sh` + selftest, `session-state-write.sh` + selftest) and 7.3.1 removed them from source, the orphans lingered in every downstream's `.github/bubbles/scripts/`. Because `registry-consistency-selftest` scans every installed script for gate IDs, those orphans — which reference the since-removed `G096` — failed downstream `framework-validate` even though the source repo was green. This is a general upgrade-hygiene gap: any file removed upstream would have lingered.

### What changed

- **`install.sh` now prunes stale framework scripts.** After copying `bubbles/scripts/*.sh` (and `bubbles/scripts/guards/*.sh`), it removes any installed script not present in the source payload, mirroring the framework-managed set. `.github/bubbles/scripts/` is framework-managed (project-owned scripts live in top-level `scripts/`), so mirroring source is safe and self-heals orphans on the next upgrade.
- **`install-provenance-selftest.sh`** gained a hermetic prune regression: it plants an orphan script in an installed fixture, re-installs, and asserts the orphan is pruned while a real framework script (`framework-validate.sh`) survives.
- Re-upgrading the five downstreams to 7.3.2 auto-removes the four orphan G096 scripts and restores green downstream validation.

## v7.3.1 — orchestrators keep `edit` so delegated workers can do real work (reverts the 7.3.0 pure-router experiment)

> *"You don't take the keys off the dispatcher and then wonder why the truck won't move, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A 7.3.0 experiment (Gate G096) tried to make "an orchestrator never authors a file" *mechanical* by stripping the `edit` tool from `bubbles.goal` and `bubbles.sprint`, turning them into edit-less "pure routers." In VS Code this **broke delegation itself**: a subagent *inherits the parent's tools by default*, so an orchestrator with no `edit` dispatches workers (`bubbles.implement`, `bubbles.test`, …) that also have no `edit` — and every dispatch returns `blocked`. An orchestrator that cannot give its workers the tools to do the work is not an orchestrator. 7.3.1 reverts the edit-stripping: all five orchestrators carry the uniform canonical allowlist again, so dispatched workers inherit a full tool surface and can do any work.

> **Note on versioning:** 7.3.0 was distributed to downstreams from an uncommitted working tree but never committed, tagged, or pushed as a real release; it also failed its own G096 guard (one orchestrator was missing the required marker). 7.3.1 is the first committed/tagged/pushed release of this line and supersedes that phantom 7.3.0 — downstreams upgrade straight to 7.3.1.

### What changed

- **Reverted the G096 edit-stripping.** All five orchestrators (`bubbles.goal`, `bubbles.sprint`, `bubbles.iterate`, `bubbles.bug`, `bubbles.workflow`) keep the uniform canonical allowlist `tools: [read, search, edit, agent, todo, web, execute, bubbles, playwright]`. Because the orchestrator's surface includes `edit`, every worker it dispatches inherits `edit` and can create/modify files. Removed the `orchestrator-artifact-write-guard.sh` (G096) guard, the `session-state-write.sh` narrow writer, the per-agent pure-router core in `mcp-grant-reconcile.sh`, and the `G096` gate registry entry.
- **"Orchestrators delegate, they don't author" stays as prose discipline** in the agent bodies (and Gate G042 ownership), where it lived before — it is enforced by instruction, not by amputating a tool the workers need.
- **`docs/guides/AGENT_MANUAL.md`** now documents the VS Code subagent tool-inheritance rule (a subagent inherits the parent session's tools) and adds a troubleshooting section: edit failures and `blocked` dispatches are a session-side issue — use **Agent** mode, enable the **Edit Files** tool group, and reload the window after an upgrade. It also states explicitly that orchestrators must keep `edit` so their workers inherit it.

## v7.2.0 — bubbles + playwright MCP tools default-on for the restricted orchestrators

> *"Give the man the whole toolbox, Bubbles — not just the rusty screwdriver."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** The five autonomous orchestrators (`bubbles.goal`, `bubbles.sprint`, `bubbles.iterate`, `bubbles.bug`, `bubbles.workflow`) ship a restrictive `tools:` allowlist, which meant they could not call MCP tools out of the box — including the framework's *own* `bubbles` MCP server. Worse, VS Code's tool picker cannot persist an MCP tool into a checksum-pinned framework agent file (it opens the file, the toggle does not stick), so operators had no working way to enable them. v7.2.0 makes `bubbles` (the framework MCP server) and `playwright` part of the canonical default allowlist for those five orchestrators.

### What changed

- The canonical orchestrator allowlist is now `tools: [read, search, edit, agent, todo, web, execute, bubbles, playwright]` (was the 7 base tools). Unknown tokens are ignored by the IDE when the matching MCP server is not configured in `.vscode/mcp.json`, so this is harmless for projects that do not use those servers and immediately functional for those that do.
- `BUBBLES_MCP_CORE_TOOLS` in `mcp-grant-reconcile.sh` was extended to match, so the grant-aware integrity model stays exact: `mcp sync` reproduces the new canonical line byte-for-byte, the write guard reconciles against the new canonical `.checksums`, and per-project `mcp.grants` continue to layer *additional* tools on top of the defaults.
- `bubbles` and `playwright` are now defaults, not grants — listing them under `mcp.grants` is a no-op (the resolver excludes canonical tokens). Docs (`project-config-contract.md`, `AGENT_MANUAL.md`) updated accordingly.
- `mcp-grant-selftest.sh` reworked to the new canonical line and non-core example grants (`github`, `context7`); all 14 adversarial assertions still pass, including the six integrity cases.

### Operator note

After upgrading a downstream to v7.2.0, **reload the VS Code window** (`Developer: Reload Window`) so the editor re-reads the updated agent definitions — a running session keeps the agent `tools:` lists it loaded at startup. The `bubbles`/`playwright` servers must be present in `.vscode/mcp.json` for the tools to actually resolve; they are ignored otherwise.

## v7.1.0 — operator-managed MCP tool grants for restricted orchestrators

> *"You can hand Ricky a bigger toolbox without leavin' the shed unlocked, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Five framework-managed orchestrators ship a deliberately **restrictive** `tools:` allowlist (`bubbles.goal`, `bubbles.sprint`, `bubbles.iterate`, `bubbles.bug`, `bubbles.workflow`). Because those files are checksum-pinned, an operator who wanted one of them to also drive an MCP tool (Playwright, a GitHub server, a DB client) had no good option — editing the allowlist triggered "Framework-managed file drift detected" and was wiped on the next refresh. v7.1.0 adds a project-owned, refresh-safe grant mechanism with a **grant-aware** integrity model: the trust anchor stays on the canonical `.checksums`, project config is used only as a strip-allowlist, and any undeclared edit still fails as drift.

### Operator-managed grants

- **Declare** extra tools in the project-owned `.github/bubbles-project.yaml` under `mcp.grants`. Keys are agent names or the reserved alias `restricted-orchestrators` (fans out to all five); values are tool **names** only — never secrets, hosts, or per-machine values (SST / no-PII preserving).
- **Apply** with `bash .github/bubbles/scripts/cli.sh mcp sync` — a deterministic, append-only, idempotent injector that rewrites each restricted orchestrator's canonical single-line `tools:` array to `core + sorted(declared grants)`. `install.sh` re-runs the sync after writing agents, so grants **survive a framework refresh**.
- **Integrity** (`downstream-framework-write-guard.sh`) is now grant-aware: it strips ONLY the operator-declared grant tokens and exact-matches the result against the unchanged canonical `.checksums`. A declared grant reconciles to canonical (clean); an **undeclared** tool, a body edit, or a missing core tool leaves a non-canonical reconstruction and still fails as drift. The canonical agent hashes are unchanged by this feature.

### New surfaces

- `bubbles/scripts/mcp-grant-reconcile.sh` — sourceable library: canonical core + restricted-agent constants, `mcp.grants` resolution (yq via stdin redirect, snap-confinement-safe), and the symmetric reconcile/inject transforms.
- `bubbles/scripts/mcp-grant-sync.sh` — the `mcp sync` injector CLI (`--check`, `--quiet`); warns (never fails) on a grant whose server is absent from `.vscode/mcp.json`.
- `bubbles/scripts/mcp-grant-selftest.sh` — **hermetic adversarial selftest** (14 assertions) covering the six integrity cases the write guard depends on: declared grant accepted; declared grant + body tamper drifts; undeclared tool drifts; grant removed resets to canonical; missing core `agent` drifts; and no false positive before sync. Plus injector idempotency and an end-to-end `mcp sync` run against a synthetic downstream tree. Wired into `framework-validate`.
- `cli.sh mcp sync`, install-time re-sync, and docs in `project-config-contract.md` (`mcp.grants` Contract) and `bubbles.setup.agent.md` (refresh step 7).

**Notes.** `trust-metadata.sh` is unchanged: its checksum path verifies a pristine source bundle (pre-install, no grants), so it correctly stays canonical. The optional strict extension to `orchestrator-tool-frontmatter-lint.sh` was intentionally not added — it would duplicate the now-grant-aware write guard, which is the authoritative undeclared-token check.

## v7.0.8 — release-packet-location-guard selftest (last untested guard)

> *"Every decky in the park gets a smoke detector, Bubbles — even the shed out back."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Continuing the v7.0.7 sweep for untested guards. After classifying every guard/lint script, `release-packet-location-guard.sh` (owned by `bubbles.releases`, enforces the canonical `docs/releases/<phase>/...` packet location) was the last real guard with neither a selftest nor live framework-validate coverage. The other naming-convention gaps were confirmed non-issues: `artifact-lint` is exercised by two sibling selftests and five callers, `action-risk-registry-lint` runs live, and `downstream-framework-write-guard` is exercised by `trust-doctor-selftest` via `cli.sh framework-write-guard`. Selftest filenames referenced only in frozen design docs (`v6-mcp-design.md`, `v5.2-design.md`) and `DEPRECATIONS.md` are intentionally historical and were left untouched.

### release-packet-location-guard selftest

- **New hermetic selftest** `release-packet-location-guard-selftest.sh` (7 assertions) with two adversarial cases: a misplaced `specs/releases/<phase>/vision.md` and an upper-case `docs/RELEASE-1/features.md` must both BLOCK (exit 1), while a generic `docs/guides/features.md` off any release-shaped path must NOT be flagged (proving the false-positive filter). It also covers the canonical single-doc and full 8-doc packet (pass), the empty repo (pass), and the missing-repo-root fail-fast (exit 2).
- **Wired into `framework-validate`** so the guard's placement logic is verified on every source-side validation run. No guard behavior changed; this is pure coverage.

## v7.0.7 — G095 discovered-issue disposition guard selftest (close documented-but-missing coverage)

> *"You can't write 'tested' on the box if the test was never in the box, Bubbles."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A review sweep for untested guards surfaced a documented-but-nonexistent selftest. The gates registry (G095, `discovered_issue_disposition_gate`) stated "Hermetic selftest: `bubbles/scripts/discovered-issue-disposition-guard-selftest.sh`" — but that file did not exist. G095 is a BLOCKING anti-fabrication gate (wired as state-transition-guard Check 35, and the bash twin behind the MCP `route_finding` tool), so a silent break in its deferral-phrase or disposition logic would have gone unnoticed. v7.0.7 makes the registry claim true.

### G095 selftest

- **New hermetic selftest** `discovered-issue-disposition-guard-selftest.sh` (9 assertions) with two adversarial cases: an unfiled "out of scope" deferral must BLOCK (exit 1), and a disposition row dated *yesterday* must still BLOCK (exit 1) — proving the guard requires a *today*-dated `## Discovered Issues` row, not just any row. It also covers inline `BUG-NNN` disposition (pass), clean reports (pass), the `--envelope` RESULT-ENVELOPE scan path (BLOCK on unfiled deferral), and the malformed-input fail-fast paths (exit 2).
- **Wired into `framework-validate`** next to the sibling G084 pre-existing-deferral guard selftest, so the gate's mechanics are now verified on every source-side validation run. No guard behavior changed; this is pure coverage that closes the registry's drift.

## v7.0.6 — MCP protocol version negotiation

> *"You can't keep answerin' the door in last year's bathrobe, Bubbles. The kitties grew up."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A continued review against current AI-assisted development surfaces found the MCP server hardcoded a single protocol version (`2024-11-05`) and ignored what the client requested in `initialize` — it always echoed its own. Newer MCP clients negotiate (`2025-03-26`, `2025-06-18`). v7.0.6 makes the handshake spec-aligned without changing the verbatim, thin-wrapper tool/resource design.

### MCP protocol version negotiation

- **`initialize` now negotiates the protocol version** per the MCP spec: it echoes the client's requested version when it is one the server supports (`2024-11-05`, `2025-03-26`, `2025-06-18`), and otherwise returns its latest supported version (`2025-06-18`) so the client can decide whether to proceed. Previously the server always returned `2024-11-05` regardless of the request.
- The exposed wire surface (tools + annotations, resources + templates, prompts) is compatible across the supported range; newer-only features remain optional capabilities the server does not advertise, so no tool/resource behavior changes.
- **`mcp-server-selftest.sh` expanded T1–T18 → T1–T19**: a new assertion proves `initialize` echoes a supported requested version and falls back to the latest for an unknown one.
- `docs/MCP.md` updated: protocol line now states the negotiated version range, and the selftest invariant count is 19.

## v7.0.5 — MCP quick-start selftest count reconciliation

**Theme:** Final release-surface drift cleanup after v7.0.4. The MCP server selftest expanded to T1–T18, and the detailed selftest paragraph was correct, but the quick-start snippet still said T1–T17. v7.0.5 reconciles that last stale count so both MCP documentation locations match the executable selftest.

## v7.0.4 — MCP prompt catalog support for modern agent clients

> *"If the prompts are sittin' right there, why's the robot pretendin' it can't see 'em?"* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A follow-up review against current AI-assisted development surfaces found that Bubbles had MCP tools, resources, resource templates, and an advertised prompt capability — but `prompts/list` returned an empty catalog even though the framework ships 37 prompt shims. v7.0.4 connects that surface without adding a new runtime dependency or duplicating prompt logic.

### MCP prompt catalog

- **`prompts/list` now exposes the existing Bubbles prompt shims** from `prompts/*.prompt.md` in the source repo and `.github/prompts/*.prompt.md` downstream. This lets MCP-aware clients that surface prompt catalogs discover Bubbles entrypoints directly, not only tools/resources.
- **`prompts/get` now returns a real prompt body** as a user message, prefixed with the target `agent:` from frontmatter (for example `bubbles.workflow`). Unknown prompt names return a real `-32005` (`ERR_PROMPT_NOT_FOUND`) error.
- **`tools/list` now includes MCP tool annotations** for modern client planning/safety: read-only/idempotent hints for query/validation tools, and non-read-only/open-world/destructive-capable hints for `record_evidence` (which wraps arbitrary commands and writes the tool log).
- **No prompt logic is duplicated.** The MCP server parses the existing VS Code prompt shim frontmatter/body and exposes it read-only, preserving the same thin-wrapper design as tools/resources.
- **`mcp-server-selftest.sh` expanded T1–T14 → T1–T18**: prompt catalog list, prompt body retrieval, unknown prompt error, and tool annotation exposure are now mechanically covered.
- `docs/MCP.md` now documents the prompt catalog, updated catalog counts (10 tools, 5 static resources, 2 resource templates, 37 prompts), and the current selftest invariant count.

## v7.0.3 — Self-review follow-ups: PCRE-grep fail-fast + orchestrator tool-frontmatter reconciliation

> *"The lint was lintin' the wrong thing, Bubbles. It's like a smoke detector that goes off 'cause the toast is too quiet."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** Two follow-up findings from the v7.0.2 self-review, fixed to the same standard — every change carries a guard + adversarial selftest, and a previously-unwired live scan is reconciled with reality and then enforced. No resolver/state.json behavior change.

### PCRE-grep fail-fast (gate-id-grep)

- **`gate-id-grep.sh` now fail-fasts (exit 2) when the host `grep` lacks PCRE (`-P`) support** instead of silently passing. The duplicate-adjacent and reference scans depend on `grep -P` (back-reference `\1`, precise word boundaries); on a grep without `-P` (BSD/macOS default, or a GNU grep built `--without-pcre`) those scans erred out, got swallowed by `2>/dev/null || true`, found zero matches, and the gate **passed vacuously** — a false negative. A startup probe now refuses to run silently. Override with `BUBBLES_GREP=ggrep` (macOS Homebrew GNU grep).
- Selftest extended with an adversarial case: a stub `grep` that rejects `-P` must drive exit 2 with the guard message (would regress to a silent exit 0 if the guard were removed).

### Orchestrator tool-frontmatter reconciliation

- **`orchestrator-tool-frontmatter-lint.sh` no longer false-positives on agents that declare no `tools:` allowlist.** An agent with absent `tools:` inherits ALL tools (including `agent`), so delegation works — it is not a defect. The guard previously treated absent `tools:` as "missing agent" and flagged 17 healthy orchestrators; only the *selftest* was wired into `framework-validate` (not the live scan), so the live failure stayed hidden. The guard now flags only a **present** `tools:` allowlist that omits `agent` — the real failure mode (`runSubagent(...)` silently blocked).
- **The live scan is now wired into `framework-validate`** alongside the selftest (next to `agent-ownership-lint`), so the convention is actually enforced going forward — closing the under-enforcement gap.
- Selftest extended with an adversarial absent-`tools:` orchestrator fixture that must PASS (would have exited 1 before this fix), and the PASS marker reworded to reflect "declares `agent` OR inherits all tools."
- **The `tools:` frontmatter convention is now documented** in `docs/guides/AGENT_MANUAL.md` (Orchestrators section): omit `tools:` to inherit all; if you declare it on an orchestrator you MUST include `agent`; opt a terminal agent out with `delegationModel: none`.

## v7.0.2 — Framework self-review: MCP templated resources shipped, stale-deferral guard, doc reconciliation

> *"You can't just keep sayin' you'll fix the deck next summer, Rick. It's been four summers."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** A framework self-review surfaced one meta-issue — Bubbles ships fixes but doesn't always reconcile its own tracking surfaces, the exact freshness discipline it enforces on downstream repos. v7.0.2 fixes the concrete instances and adds a mechanical guard so the whole class can't recur. No resolver/guard/state.json behavior change.

### MCP templated resources (the unfulfilled "deferred to v6.1")

- **Templated MCP resources are now implemented** (they had been marked "deferred to v6.1" since v6.0 but never shipped). The server resolves `uriTemplate` resources (RFC 6570 level-1 `{var}`):
  - `bubbles://gates/{id}` — one gate's metadata via the `gate-meta.sh` bash twin (a `commandTemplate`-backed resource; never a duplicated parser). Unknown id → real `-32004` error.
  - `bubbles://spec/{nnn}/state.json` — a spec's control-plane state via a `pathTemplate` glob (`specs/{nnn}*/state.json`); resolves in downstream repos only.
- New `resources/templates/list` JSON-RPC method advertises the templated catalog. Extracted `{var}` values may not contain `..`; command-backed reads surface verbatim stdout with the same anti-fabrication guarantee as tools.
- `mcp-server-selftest.sh` extended 11 → **14 assertions** (T12 templates/list, T13 templated gate read via bash twin, T14 unknown-gate ERR_RESOURCE_FAILED).

### Stale-deferral guard (prevents the whole class)

- **`stale-deferral-lint.sh`** (+ hermetic selftest, 10 cases incl. an adversarial one) FAILS when a live surface says `deferred to vX.Y` where `X.Y <=` the current VERSION — a promise that has come due. Historical records (CHANGELOG.md, frozen design docs, ADRs) are excluded. Wired into `framework-validate` (live scan is source-only; selftest runs everywhere). This is the mechanical backstop that would have caught the MCP deferral three releases ago.

### Doc / tracking reconciliation (found by the new guard)

- `docs/MCP.md` — documents the templated resources, refreshes the selftest count (14), drops the stale "v6.0"/"deferred to v6.1" framing, and reframes "What The Server Does Not Do."
- `docs/recipes/upgrade-to-v6.md` — the result-envelope "missing → blocking" flip was promised for v6.1 but never shipped; restated as "missing warns (not yet blocking); use `--strict` to opt in."
- `skills/INVENTORY.md` — the CONSOLIDATE/POINTER-DELETE matrix no longer pins a lapsed v6.0.1 (the audit concluded 0 pruning candidates).
- `BUGS.md` — BUG-001 reconciled to **partially-mitigated**: the Check 3G fail-safe 30s timeout (`BUG-001 guard`) and wall-clock budget shipped; root-cause filesystem-walk exclusions + perf regression remain open.

### Shellcheck cleanup + regression gate (found real validation bugs)

- **`shellcheck-lint.sh`** (+ hermetic selftest with an adversarial dirty-fixture case) lints the entire tracked shell surface (**222 scripts**) at `-S warning` and fails on any finding. Wired into `framework-validate` (source-only). This locks in the cleanup so warnings cannot silently regress; before this, shellcheck was never run in validate.
- **Full `-S warning` cleanup** of the shell surface (was ~80 findings across 30 files; now **zero**). The sweep surfaced four real defects that prose review had missed:
  - **3 dead-branch validation bugs (SC2221/SC2222).** `full-delivery` was swallowed by an earlier `full-delivery|value-first-e2e-batch)` case branch in `artifact-lint.sh` (×2) and `state-transition-guard.sh`, making the comprehensive `full-delivery)` branch unreachable — so full-delivery silently under-enforced its required specialists. Fixed by removing `full-delivery|` from the short-list branch, restoring the registry's `phaseOrder` for the mode. State-transition-guard selftest confirms no behavior regression.
  - **Real quoting bug in `traceability-guard.sh` (SC2027).** Its copy of `json_first_string` used extra quote-segments that trapped `$key` inside single quotes (never expanded), so `scopeLayout` detection silently returned empty and fell back to the default layout. Aligned to the byte-identical working form used by the other three guards (`state-transition-guard`, `artifact-lint`, `artifact-freshness-guard`).
  - **Real env-prefix bug in `upkeep-calendar-selftest.sh` (SC2034).** `UPKEEP_LEDGER=… output=$(…)` set a shell var the external calendar binary never saw, so the "recent backup marked ok" case passed only by accident. Restructured to a command-prefix assignment so the ledger path actually reaches the binary.
- **Dead code removed** (no-dead-code policy): `diff_range`, `HAS_JSON`, three unused `*_FILE` path constants and `scope_name` in `cli.sh`, `REQUIRED_AGENTS`, `wi_parity_present`, and `install.sh`'s `PROFILE_SELECTED_EXPLICITLY`. Genuine false positives (namerefs, intentional globs, literal display tildes, sourced-fragment parent-scope vars) carry justified `# shellcheck disable` directives instead.

## v7.0.1 — v7 surface closure: operator surfaces migrated, migrator made idempotent, cheatsheet/super v7-aware

> *"You said you let the decals go, Ricky. The recipes still had 'em on."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** v7.0.0 shipped the resolver rejection but left the framework's *own* operator surfaces carrying bare v5 leading-token forms, and the migrate-modes selftest actually pinned that un-migrated state. v7.0.1 finishes the job: every operator-facing surface now uses the v6 form, the migrator is idempotent for self-named primitives and guards the v7 invariant, and the super agent + both cheatsheets state the v7 input rule explicitly. No behavior change to the resolver or guards; no `state.json` impact.

### Operator surfaces migrated to v6 forms

- **17 recipes** under `docs/recipes/` plus `README.md`, `docs/guides/WORKFLOW_MODES.md`, and `install.sh` had bare `/bubbles.workflow <v5-name> for <feature>` leading-token forms — the exact shape `mode-resolver.sh` now rejects. All were rewritten to the v6 primitive+tag form (e.g. `chaos-hardening` → `validate action:chaos-iterative`, `propagate-forward` → `propagate action:forward-merge`). The valid `mode: <registry-key>` form was left untouched — it resolves by direct registry lookup and is not the rejected leading-token shape.
- **`migrate-modes-v5-to-v6.sh` now scans `docs/recipes/`.** The default scan previously excluded recipes on a stale "already reviewed" premise; that exclusion is removed so the migrator both fixes and guards them.

### Migrator correctness

- **Idempotency fix for self-named primitives.** Where a v6 form begins with the v5 token (`framework-health` → `framework-health action:proposal-first`), a naive rewrite re-matched `workflow framework-health` on the second pass and double-applied the tail. A negative-lookahead guard (applied only when the v6 first token equals the v5 name) makes the rewrite idempotent. Covered by a new adversarial selftest assertion.
- **Selftest Assertion 7 flipped to the v7 invariant.** It previously asserted the real repo `--check` exits 2 with `install.sh` pending — pinning the un-migrated state. It now asserts a clean `--check` (exit 0), so any reintroduced bare v5 form in an operator surface is caught as a regression.

### Docs & discovery surfaces are v7-aware

- **`bubbles.super`** gained an ABSOLUTE v7 mode-input rule: always emit `mode: <key>` or the v6 primitive+tag form, never a bare `/bubbles.workflow <v5-name>` leading token.
- **`docs/CHEATSHEET.md` and `docs/its-not-rocket-appliances.html`** carry a v7 input note clarifying that the mode column lists registry keys, how to invoke them, and that bare leading-token input is rejected (existing `state.json` keys unaffected).
- **README callout phrasing corrected at the generator** (`generate-framework-stats.sh`): "v5 aliases that still resolve" → "v5 aliases retained as registry keys" — precise under v7, where bare v5 *input* no longer resolves but the *keys* are retained.

## v7.0.0 — Mode-collapse completion: v5 name input removed, existing artifacts grandfathered

> *"You gotta let the old decals go, Ricky. The trailer rolls the same."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** v7.0 completes the v6 mode collapse. Through the entire v6 cycle, bare v5 mode names (e.g. `bugfix-fastlane`) kept working as operator input with a deprecation hint. **v7.0 removes them as input** — the one intentional breaking change — while leaving every existing artifact untouched. The v5 names remain the canonical registry keys; there is **no `state.json` schema change** and **no per-spec migration**. This release also makes `framework-validate` clean under a downstream install by skipping six maintainer-only selftests that were never downstream-aware.

### The one breaking change (and why it isn't, for your existing work)

- **`mode-resolver.sh` rejects bare v5 mode NAMES as operator input** (exit 3) and prints the v6 primitive+tag form to use instead. Start new work with the v6 form: `fix target:bug action:fastlane`, not `bugfix-fastlane`.
- **v5 names remain the registry keys.** `bubbles/workflows/modes.yaml` is still keyed by the v5 names. `state.json.workflowMode` still stores them. The guards (`state-transition-guard.sh`, `artifact-lint.sh`, `is-terminal-for-mode.sh`) resolve status ceilings by **direct registry lookup of the stored key** — `mode-resolver.sh` isn't even on that path for a mode that exists in the registry.
- **Existing specs/scopes/bugs/ops are completely unaffected.** No schema change, no migration, no re-validation. Already-complete work stays exactly as it is; only *new* operator input must use the v6 form.
- **Grandfather switch for programmatic resolution.** Tools that resolve a *persisted* mode set `BUBBLES_MODE_GRANDFATHER=1` (or pass `--grandfather`), which downgrades the rejection to a one-line deprecation notice and resolves the stored key. The three guards set this automatically. Operators never need it for normal work.

### Downstream-install validation fix (was a latent v6.0/v6.1 regression)

Six maintainer-only selftests were added in v6.0/v6.1 with `run_check` instead of the downstream-aware `run_check_self_only`, so a downstream `framework-validate` FAILed on expected-to-be-missing source assets (`install.sh`, the cheatsheet JSON registry, the eval golden-task fixtures). They now SKIP cleanly under `install-mode=downstream`, mirroring the v5.3 pattern:

- Portable surface agnosticity
- Cheatsheet generator selftest (v6.0 / B7)
- Installer manifest check (v6.0 / B9)
- Installer manifest selftest (v6.0 / B9)
- Migrate-modes-v5-to-v6 selftest (v6.0 / C1)
- Golden-task eval harness selftest (v6.1 / R11)

`v5.3-selftest.sh` now asserts all 13 source-only selftests skip downstream (was 9).

### Also removed in v7.0

- **`BUBBLES_PARALLEL_PHASES` opt-out flag.** Parallel phase fan-out for parallel-eligible phases (per the workflow-execution-loops DAG) was opt-in in v6.0, default-on in v6.1, and is now **mandatory** — the sequential-dispatch opt-out is gone. Determinism guarantees remain enforced by `parallel-fanout.sh` + `parallel-fanout-determinism-selftest.sh`.

### New selftest

- **`bubbles/scripts/v7-selftest.sh`** — asserts: (1) a bare v5 name is rejected with exit 3 + a v6-form hint; (2) the v6 primitive+tag form resolves; (3) `BUBBLES_MODE_GRANDFATHER=1` and `--grandfather` resolve a stored v5 key with a deprecation notice; (4) a persisted-mode ceiling still resolves through the guards for an existing-artifact fixture; (5) the alias table is structurally intact (v6 forms still map to registry keys). Wired into `framework-validate.sh`.

### Migration

```bash
# Find operator-side surfaces still using v5 names:
bash bubbles/scripts/migrate-modes-v5-to-v6.sh --check        # source repo
bash .github/bubbles/scripts/migrate-modes-v5-to-v6.sh --check # downstream
# Apply (idempotent):
bash bubbles/scripts/migrate-modes-v5-to-v6.sh --write
```

### What v7.0 does NOT do

- Does not change `state.json` schema.
- Does not rename or remove any registry mode key (the v5 names stay as keys).
- Does not require migrating any existing spec/scope/bug/ops artifact.
- Does not remove the alias table — it still maps v6 forms to registry keys.
- Does not touch agent contracts, gates (still 102), phases, or the MCP surface.

---

## v6.1.0 — Deep-review follow-ups: blocking model floor, parallel dispatch, pre-tool gating, HTTP MCP, eval harness

> *"You can't handcuff the wind, but you can put a timeout on it."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** v6.1 implements every item from the v6.0 deep review (R1–R16). It hardens the anti-fabrication and reliability surface (auto-capture, guard timeouts), promotes three advisory mechanisms to blocking/default-on (model floor, parallel dispatch, pre-tool risk gating), ships HTTP transport for the MCP server, adds output-quality eval, and **physically splits the two largest monoliths** (`state-transition-guard.sh` and the `modes:` registry inside `workflows.yaml`). **Zero breaking changes**: every v5/v6 mode name and `state.json` schema stays compatible. New gate **G126** brings the registry to **102 gates**.

### Highlights

- **R1 — Guard reliability (BUG-001):** new `bubbles/scripts/guard-lib.sh` provides `bubbles_run_with_timeout` (portable, 124-on-timeout) and `bubbles_pruned_find` (excludes `.git`/`node_modules`/`target`/build caches). `state-transition-guard.sh` Check 3G is now wrapped in a 30s timeout with a per-check wall-clock budget; three other sub-guards are timeout-wrapped; the unbounded whole-repo `find` in the test-file check is replaced with a pruned walk. Closes the BUG-001 hang. Selftest: `state-transition-guard-perf-selftest.sh`.
- **R2 — Automatic tool-call capture:** `tool-capture-shim.sh` (sourceable) routes gate-relevant commands through `tool-log.sh` so evidence provenance is a ground-truth side effect, not a manual step (`BUBBLES_AUTOCAPTURE=1` shadow wrappers + explicit `bubbles_capture`). Markdown evidence stays a valid fallback. Selftest: `tool-capture-shim-selftest.sh`.
- **R3/R12 — Gate-band collision fixed:** project-local custom gates move to **G900+**; the framework reserves **G001–G199** (G200–G899 is a deliberate gap). `gate-id-grep.sh` always-allow threshold raised 100→900; docs + memory updated.
- **R4 — Blocking model-tier floor (G126):** `modeDefaults.modelFloorEnforcedPhases` (default `audit, security, validate`) makes `model-tier-advisory.sh check` exit non-zero when a known model is below floor for an enforced phase. Never false-blocks on unknown models / undeclared floors. Selftest: `model-tier-advisory-selftest.sh`.
- **R5 — Workflow-mode registry split + family inventory:** the `modes:` block (mode definitions + `phaseRelevance`) is **physically split out** of `workflows.yaml` into the dedicated canonical registry `bubbles/workflows/modes.yaml` (see *Surface reduction* below — no duplicated copy). `mode-family-inventory.sh` enforces that every mode maps to exactly one canonical v6 primitive. Selftests: `mode-family-inventory-selftest.sh`, `generate-modes-block.sh --check` (re-inlining guard).
- **R6/R7 — Agent-surface decisions:** ADR-001 records the explicit decision to keep the four orchestration agents and the nine diagnostic agents, with rationale and revisit triggers (drift already contained by G086 and G042/G056/G061/G063).
- **R8 — Parallel phase fan-out default-ON:** `parallel-fanout.sh` is the deterministic reference aggregator + DAG conflict validator; the dispatcher default flips to ON (`BUBBLES_PARALLEL_PHASES=0` opts out). Selftest: `parallel-fanout-determinism-selftest.sh` (100-run shuffle invariance, DAG rejection, failure aggregation).
- **R9 — MCP HTTP transport:** `bubbles/mcp/server.py --transport http --host --port` serves JSON-RPC over HTTP POST with `GET /health` and optional `BUBBLES_MCP_HTTP_TOKEN` bearer auth — reachable from CI/cloud, not just a local stdio shell. Same dispatch as stdio. Selftest: `mcp-http-transport-selftest.sh`.
- **R10 — Real-time PreToolUse risk gate:** `pre-tool-risk-gate.sh` (declared `pre-tool` in `hooks.json`) BLOCKs `destructive_mutation`/`external_side_effect` actions *before* execution using the existing `action-risk-registry.yaml`; `--confirm`/`BUBBLES_RISK_CONFIRM` override. Selftest: `pre-tool-risk-gate-selftest.sh`.
- **R11 — Golden-task eval harness:** `eval-harness.sh` scores produced output (spec/report folders) against fixed rubrics (`bubbles/eval/tasks/*.json`) with a pluggable `BUBBLES_EVAL_JUDGE` LLM-as-judge — output-quality regression testing, not just gate-pass. Selftest: `eval-harness-selftest.sh`.
- **R13 — Gate registry ordering:** registry reordered to strict ascending sequence (G066<G067<G068<G069).
- **R14 — README modes badge:** now renders "15 primitives + 40 aliases" instead of the bare "55", matching the v6 narrative.
- **R15 — GENERATED sentinel:** the `gates:` block in `workflows.yaml` now carries an explicit GENERATED-from-registry header + gate-band note.

### Statistics

- **Gates:** 102 (was 101; +G126 model-tier floor).
- **New selftests:** 8 (R1, R2, R4, R5, R8, R9, R10, R11), all wired into `framework-validate.sh`.
- **New scripts:** `guard-lib.sh`, `parallel-fanout.sh`, `pre-tool-risk-gate.sh`, `tool-capture-shim.sh`, `eval-harness.sh`, `mode-family-inventory.sh` + their selftests + `mcp-http-transport-selftest.sh`.
- **Mode count, agent count, schema:** unchanged. No operator capability removed.

### Surface reduction (monolith splits — the subtractive half of v6.1)

The v6.1 review correctly flagged that the framework's two biggest files were monoliths the modernization plan (M4, S2) had never actually split. Both are now split, behavior-preserving, validated by their existing selftests:

- **M4 — `state-transition-guard.sh` split.** The G023 enforcement core dropped from **3,972 → 2,967 lines** (−1,005, −25%). Self-contained check clusters were extracted into sourced fragments under `bubbles/scripts/guards/`: `control-plane-checks.sh` (Checks 3A/3H/3C/3D/3E/3F — G055–G061/G063), `planning-checks.sh` (Checks 8A–8D — G043/G067/G069), `tail-convergence-gates.sh` (Checks 23–25 — G082–G084), and `tail-delegated-gates.sh` (Checks 26–35 — G085–G095). Fragments are `source`d in the same shell scope, so execution is byte-identical; Check 3G stays inline because it carries the BUG-001 timeout wrapper. The `state-transition-guard-selftest.sh` passes with zero real failures after the split.
- **S2 — `workflows.yaml` modes split (true split, not a mirror).** The 1,343-line `modes:` block (the final top-level section) was **physically removed** from `workflows.yaml` (**2,737 → 1,400 lines, −1,337 / −49%**) and now lives only in a dedicated canonical registry, `bubbles/workflows/modes.yaml`. There is no duplicated copy. `mode-resolver.sh` composes `workflows.yaml` + `modes.yaml` at read time (resolution is byte-identical to pre-split); every other modes reader — `state-transition-guard.sh`, `artifact-lint.sh`, `delivery-implementation-delta-guard.sh`, `is-terminal-for-mode.sh`, `intent-routes-lint.sh`, `generate-framework-stats.sh`, `generate-cheatsheet.sh`, `workflow-registry-consistency.sh`, `planning-workflow-chain-guard.sh`, `mode-family-inventory.sh` — reads `modes.yaml` directly (falling back to an inline `modes:` block for pre-split fixtures/repos). `bubbles/scripts/generate-modes-block.sh` is now a strip + no-duplication guard (`--strip` removes an inline block; `--check`, wired into `framework-validate`, blocks any re-inlining regression). Maintainers edit modes in a focused registry instead of scrolling a 2,700-line config.

**New split artifacts:** `bubbles/scripts/guards/{control-plane-checks,planning-checks,tail-convergence-gates,tail-delegated-gates}.sh`, `bubbles/workflows/modes.yaml`, `bubbles/scripts/generate-modes-block.sh`.

### What v6.1 does NOT do

- Does not change `state.json` schema or any mode name.
- Does not add SSE streaming to the MCP HTTP transport (POST + health only).
- Does not fragment the single `modes.yaml` registry into 15 per-family files — the registry split already eliminates the monolith and `mode-family-inventory.sh --family <p>` provides per-family inspection/validation. (Decided, not deferred — see ADR-001 R5.)

---

## v6.0.0 — MCP-aware framework, mode collapse, structurally-impossible bug classes

> *"It ain't rocket appliances, boys."* — Sunnyvale Trailer Park Operator Newsletter, June 2026

**Theme:** v6.0 is a subtractive release that collapses 55 v5 workflow modes to 15 v6 primitives + tag grammar, makes the v5.2 advisory paths default-on for evidence/diff/envelope gates, ships an MCP server for agent-native integration, and renders adapter/gitignore/missing-chmod bug classes structurally impossible. **Zero breaking changes** for operators on v5.x: every v5 mode name keeps working through the full v6 cycle, and every state.json schema stays compatible.

### Highlights

#### Group A (MCP — shipped earlier on `main`)

- A1-A6: Python stdlib-only MCP server, declarative tool catalog, declarative resource catalog, sample client configs for VS Code / Claude / Cursor / Cline, and selftest.

#### Group B (subtractive release)

- **B1** `evidence-tool-log-bridge.sh` — MCP-primary with structured JSON envelope (`--format=json` default). The MCP `query_tool_log` tool now returns a parseable envelope instead of human-readable text.
- **B2** `diff-evidence-guard.sh` — strict for ALL specs by default; explicit `state.json.modernization.diffEvidence: "advisory"` opt-out; v5 grandfather for pre-cutoff specs without a modernization block.
- **B3** `result-envelope-validate.sh` — malformed envelopes block on every framework-validate; missing envelopes still warn (v6.1 will flip missing → blocking after per-agent envelope rollout). Schema accepts richer envelope shape (`additionalProperties: true`), `nextRequiredOwner`/`blockedReason` aliases, and `[string, null]` null placeholders.
- **B4** Mode collapse — 55 v5 mode names → 15 v6 primitives + tag grammar. `bubbles/workflows/aliases.yaml` is the alias map; `mode-resolver.sh` accepts both forms; v5 names emit a deprecation hint on stderr; full byte-identical resolution parity across the round-trip.
- **B5** Skills inventory baseline — `skills/INVENTORY.md` enumerates all 34 skills with `KEEP`/`CONSOLIDATE`/`POINTER-DELETE`/`REVIEW` status. Zero deletions in v6.0 (no pure-pointer skills found in the audit).
- **B6** Doc audience matrix — `docs/governance-index.md` gains an Audience Matrix (operator / agent / maintainer) and per-section `**Audience:**` tags. Zero merges (no true content duplicates found across 96 governance docs).
- **B7** Cheatsheet generator — `bubbles/cheatsheet/{modes,aliases,vocabulary}.json` is the single source of truth; `generate-cheatsheet.sh` renders `docs/CHEATSHEET.md` AND `docs/its-not-rocket-appliances.html` from it; the v5.0.1 H7 drift selftest is retired (drift is now structurally impossible).
- **B8** v5.1 advisory paths absorbed by B1/B2/B3 — audit shows the distinct v5.1 implementation was already consolidated by v5.2; remaining advisory surfaces are documented operator escape hatches, not vestigial v5.1.
- **B9** Installer manifest + structural checker — `bubbles/installer/installer.yaml` enumerates every install.sh step; `generate-installer.sh --check` audits install.sh against the manifest; 5 invariants close historical bug classes (wrong gitignore root closing bug `ce01576`, missing chmod on scripts/adapters, silent step deletion, missing provenance fields). 7-assertion selftest with 6 adversarial mutation fixtures.
- **B10** Parallel phase fan-out contract — opt-in dispatcher (`BUBBLES_PARALLEL_PHASES=1`) in v6.0, default in v6.1. The 5-condition DAG, parallel-eligible / sequential-only phase shapes, 5 determinism guarantees, and failure-handling rules are normative immediately so workflow agents can cite them today.

#### Group C (migration tooling)

- **C1** `migrate-modes-v5-to-v6.sh` — one-shot rewriter; `--check` dry-run (exit 2 if rewrites pending); `--write` applies; idempotent. Default scope excludes framework internals. 9-assertion selftest.
- **C2** `docs/DEPRECATIONS.md` — authoritative v5 → v6 shape-change log with high-traffic mode mapping table, opt-out flags, removal schedule.
- **C3** `docs/recipes/upgrade-to-v6.md` — step-by-step upgrade recipe with what-does-not-change list and rollback steps.

### Statistics

- **Managed files:** 499 (was 481 at v5.3.0; +18 new files for installer manifest, cheatsheet registry, workflows alias map, MCP catalog, migration tooling, deprecations doc, upgrade recipe).
- **Selftests:** +6 new in v6.0 (B1, B2, B3, B4, B7, B9, C1).
- **Operator-visible mode count:** 55 → 15 + tags (or any v5 name still works).
- **Zero deletions:** skills (34 stay), recipes (63 stay), guides (12 stay), maintainer docs (8 stay; +1 added: DEPRECATIONS.md).

### What v6.0 does NOT do

- Does not remove the bash script surface (MCP wraps it, doesn't replace it).
- Does not remove markdown evidence (still fully valid when diff-evidence-guard is advisory).
- Does not remove any operator capability — only renames (with aliases active), generates (instead of hand-editing), or prunes redundant docs/skills (where audits found candidates — they didn't).
- Does not introduce HTTP transport (deferred to v6.1).
- Does not change `state.json` schema (deferred to v7).
- Does not delete v5 mode names (deferred to v7).
- Does not enforce the parallel dispatcher (opt-in via env var; default in v6.1).

### Upgrade Path

```bash
curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- v6.0.0
bash .github/bubbles/scripts/framework-validate.sh
bash .github/bubbles/scripts/migrate-modes-v5-to-v6.sh --check
bash .github/bubbles/scripts/migrate-modes-v5-to-v6.sh --write   # if check returned 2
```

Full upgrade recipe: [`docs/recipes/upgrade-to-v6.md`](docs/recipes/upgrade-to-v6.md). Full shape-change log: [`docs/DEPRECATIONS.md`](docs/DEPRECATIONS.md).

---

## v6.0 Group C — Migration Tooling and Docs

### C1 + C2 + C3 — migration script, deprecations log, upgrade recipe

**Theme:** v6.0 / Group C wraps the migration story. Operators who installed any v5.x release get a single command to rewrite v5 mode names to v6 primitive+tag form (C1), a single doc that catalogs every shape change between v5.3 and v6.0 (C2), and a single recipe walking through the upgrade end to end (C3).

#### Changes

- **NEW** `bubbles/scripts/migrate-modes-v5-to-v6.sh` — one-shot rewriter. `--check` dry-run (exit 0 clean, 2 if rewrites pending, 1 on error); `--write` applies; idempotent. Default scope: operator-visible surfaces only (`*.md`, `Makefile`, `install.sh`). Excludes framework internals (`agents/`, `skills/`, `bubbles/scripts/`, `bubbles/workflows/`, generated cheatsheets, historical design docs, `CHANGELOG.md`). `--include-instructions` extends scope to `instructions/` and `.github/instructions/`. Pure-bash awk parser for `bubbles/workflows/aliases.yaml` (no yq dependency).
- **NEW** `bubbles/scripts/migrate-modes-v5-to-v6-selftest.sh` — 9 assertions covering: aliases parse, --check exits 0 on empty corpus, --check exits 2 on dirty corpus, --check does not modify files, --write rewrites correctly, --write is idempotent, default scope excludes framework internals, real-repo --check lists install.sh, unknown-flag exits 1, missing aliases file exits 1.
- **NEW** `docs/DEPRECATIONS.md` — authoritative log of v5 → v6 shape changes. Operator-facing how-to-verify-your-surface section, complete table of high-traffic v5 → v6 mode mappings, opt-out flags for the three default flips (B1/B2/B3), removal schedule (v5 names removed in v7).
- **NEW** `docs/recipes/upgrade-to-v6.md` — step-by-step upgrade recipe. Pre-flight check, installer re-run, framework-validate, migration --check + --write, doctor, installer manifest check, cheatsheet regen, push. Includes what-does-not-change list and rollback steps.
- **`docs/governance-index.md`** — DEPRECATIONS.md added to Framework Maintainer Docs; upgrade-to-v6.md added to Recipes.
- **`bubbles/scripts/framework-validate.sh`** — registers the C1 selftest (gated on the migrate script being executable to support downstream installs that haven't synced the new file yet).
- **`bubbles/release-manifest.json`** — regenerated. trust-metadata picks up the two new scripts + two new docs automatically.

#### Invariants

- Migration is idempotent. Running `--write` twice produces no second-run changes.
- Framework internals are excluded by default. Operator surfaces are the target.
- Adding a new v5-only file under an excluded path WILL NOT be migrated (correct: it's a framework internal that uses v5 names as fixtures).
- DEPRECATIONS.md captures only operator-facing shape changes. Framework-internal refactors are documented in their own CHANGELOG entry, not here.
- Upgrade recipe references commands by their downstream-install path (`.github/bubbles/scripts/...`). It is operator-facing, not source-tree-facing.

## v6.0 Group B — Subtractive Release

### B10 — Parallel phase fan-out contract (opt-in dispatcher in v6.0; default in v6.1)

**Theme:** v6 design B10 called for "independent phases run in parallel where DAG permits". The DISPATCHER implementation that honors this is opt-in in v6.0 (`BUBBLES_PARALLEL_PHASES=1`); v6.0 ships the CONTRACT so workflow agents, selftests, and operators all read the same DAG rules, parallel-eligible phase shapes, determinism guarantees, and failure-handling requirements.

#### Changes

- **`agents/bubbles_shared/workflow-execution-loops.md`** — new "Phase 0.11: Parallel Phase Fan-Out (v6.0 / B10)" section. Defines:
  - The 5-condition DAG that determines whether two phases MAY be dispatched in parallel (no data dependency, no status-promotion ordering, no shared mutable singleton, no finding-ownership conflict, both read-only OR both idempotent).
  - Canonical parallel-eligible phase shapes (e.g. `bubbles.security` + `bubbles.test` against the same spec, per-spec `bubbles.docs` across N specs, per-scope `bubbles.test` with disjoint test files).
  - Canonical sequential-only phase shapes (`bubbles.implement` + `bubbles.implement` same spec, any pair around a `state.json` write).
  - 5 determinism guarantees (stable phase-name-sorted output ordering, stable finding ordering, latest-`at`-timestamp aggregation, per-phase temp-directory isolation, same-DAG-same-envelope-sequence selftest).
  - Failure-handling rules (no-kill, full-aggregation, never mask partial-success).
  - Operator opt-in via `BUBBLES_PARALLEL_PHASES=1`.
  - 4-item anti-pattern checklist.

#### Why opt-in, not default-on, in v6.0

- Audit gap: not every workflow agent has been audited against the DAG.
- Determinism gap: the dispatcher's stable-ordering invariant isn't yet enforced by a selftest.
- Operator surprise: operators dependent on v5 sequential log ordering would see a reordered stream; the opt-in flag gives one release for adaptation.

#### Invariants

- The CONTRACT is normative immediately. Workflow agent definitions and reviewers can cite the DAG rules today regardless of dispatcher implementation status.
- Parent envelope failure aggregation rules apply to both sequential and parallel dispatch — the contract is dispatch-mode-independent.
- The parallel doctrine is subordinate to per-round synchronous dispatch. Rounds remain synchronous; parallelization is WITHIN-round only.

#### v6.1 plan

- Default-on the parallel dispatcher.
- Ship `bubbles/scripts/parallel-fanout-determinism-selftest.sh` enforcing same-DAG-same-envelope-sequence across 100 runs.
- Audit + tag every workflow agent's phases with `parallel-eligible: true|false` metadata.

### B8 — v5.1 advisory paths absorbed by B1/B2/B3 (no distinct path to remove)

**Theme:** v6 design B8 called for removing "v5.1 advisory paths superseded by v5.2 primaries" in `evidence-tool-log-bridge.sh`, `diff-evidence-guard.sh`, and `result-envelope-validate.sh`. Audit of the three scripts shows there is **no distinct v5.1 advisory code path remaining** — v5.2 unified the implementation and B1/B2/B3 already removed the advisory-only behavior at the entry-point level.

#### What B1/B2/B3 already did

- **B1** (`evidence-tool-log-bridge.sh`) — flipped the bridge from text-only to JSON-by-default. The always-exit-0 semantic was preserved deliberately so MCP integrations can interpret the JSON envelope; that semantic is NOT a v5.1 advisory remnant, it's the canonical contract.
- **B2** (`diff-evidence-guard.sh`) — flipped the default from advisory to strict for all specs. The remaining advisory branch is a per-spec opt-out (`state.json.modernization.diffEvidence == "advisory"`) plus a v5 grandfather clause for pre-cutoff specs with NO modernization block. Both are documented operator escape hatches, not v5.1 advisory code paths.
- **B3** (`result-envelope-validate.sh`) — flipped the default from `--advisory` to blocking-on-malformed. `--advisory` remains as an explicit operator flag for bisecting upstream changes; that's intentional opt-out, not vestigial v5.1.

#### Why not delete `--advisory` too

The design rationale for `--advisory` in B3 is documented in `docs/DEPRECATIONS.md`: it is "temporary backwards compatibility (e.g., bisecting an upstream change)". Removing it would deny operators a debugging tool with zero offsetting benefit. The flag is scheduled for removal in v6.1 once the agent set has fully migrated to the v6 schema (per `docs/DEPRECATIONS.md` "Removal Schedule").

#### What B8 actually delivers

This entry is the audit conclusion: B8 has no incremental code change to ship in v6.0. The three scripts are already at the post-B8 shape because B1/B2/B3 consolidated the surface. The "Selftests updated" requirement in the B8 row is satisfied by the v5 / B1/B2/B3 selftest updates.

#### Invariants

- Zero deletions in v6.0 / B8. The three scripts retain their B1/B2/B3 shape.
- Advisory escape hatches (`--advisory`, state.json opt-out, v5 grandfather) are documented operator surfaces, not vestigial v5.1 code paths.
- v6.1 removes `--advisory` from `result-envelope-validate.sh` per the DEPRECATIONS.md removal schedule.

### B9 — Installer manifest + structural checker (adapter/gitignore bug class structurally impossible)

**Theme:** v6 design B9 called for an installer-as-generated-artifact (typed manifest + generator). v6.0 ships the verification half of that pattern: a typed manifest (`bubbles/installer/installer.yaml`) plus a structural checker (`bubbles/scripts/generate-installer.sh --check`) that audits `install.sh` against the manifest on every framework-validate run. Generation FROM the manifest is deferred to a future increment; verification AGAINST the manifest closes the historical bug classes today (improvements/ landing in the wrong .gitignore root, missing chmod +x on scripts/adapters, silent step deletion, missing provenance fields).

#### Changes

- **NEW** `bubbles/installer/installer.yaml` — typed enumeration of every action `install.sh` performs. 23 steps covering directory copies, glob installs, gitignore writes, migrations, version stamp, provenance write. 5 invariants close historical bug classes (wrong gitignore root, missing chmod, missing step, missing provenance field).
- **NEW** `bubbles/scripts/generate-installer.sh` — `--check` mode parses the manifest and verifies `install.sh` implements every required step's marker AND satisfies every invariant. Exit codes: `0` PASS, `1` violation, `2` manifest or installer source error.
- **NEW** `bubbles/scripts/generate-installer-selftest.sh` — 8 assertions including 6 adversarial mutation fixtures (remove a marker → FAIL; write improvements/ to `${TARGET}/.gitignore` → FAIL closing bug `ce01576`; drop chmod +x on scripts → FAIL; drop chmod +x on adapters → FAIL; drop a provenance field → FAIL; missing install.sh → exit 2). Fixtures live under `$HOME/.cache/bubbles-installer-selftest/` (snap-confined yq compatibility).
- **`bubbles/scripts/framework-validate.sh`** — registers `Installer manifest check` and `Installer manifest selftest` immediately after the B3 result-envelope selftest.
- **`bubbles/scripts/trust-metadata.sh`** — enumerates `bubbles/installer/**` into the release manifest so downstream installs receive the typed manifest alongside the checker.
- **`install.sh`** — copies `bubbles/installer/` to `${TARGET}/bubbles/installer/` during downstream install (mirrors the v6.0 / B4 + B7 patterns). The manifest's new `install_installer_manifest` step makes this copy self-describing.

#### Invariants closed

| ID | Invariant | Historical bug class |
|---|---|---|
| I1 | `gitignore_root_is_repo_root` | bug `ce01576` — `improvements/` was written to `${TARGET}/.gitignore` instead of repo-root `.gitignore`, so git still tracked the scratch directory |
| I2 | `scripts_are_chmod_x` | scripts copied without exec bit → downstream operators got permission denied |
| I3 | `adapter_files_are_chmod_x` | same class for `bubbles/adapters/*.sh` |
| I4 | `every_step_has_a_marker` | silent step deletion went unnoticed until a downstream operator noticed missing files |
| I5 | `provenance_records_six_fields` | a provenance field was dropped from the `.install-source.json` heredoc, breaking trust-doctor downstream |

#### Working order

- v6.0 ships the verification layer (this entry). `install.sh` stays the source of truth at runtime.
- v6.1 or v7 may flip the relationship and generate `install.sh` from the manifest. The checker stays valid in both modes because it asserts a structural correspondence, not a generation direction.

#### Invariants of the change itself

- Adding a real step to `install.sh` without a matching manifest entry → I4 FAILs.
- Adding a manifest entry without implementing it in `install.sh` → marker-missing FAILs.
- Downstream byte-compatibility: every previously-installed file still installs at the same path; one new directory (`${TARGET}/bubbles/installer/`) is added.

### B6 — Doc audience matrix + consolidation notes (zero deletions)

**Theme:** v6 design B6 called for tagging every doc with audience (`operator` / `agent` / `maintainer`) and merging near-duplicate recipes/guides. After auditing all 96 governance docs — 63 recipes, 12 guides, 7 maintainer docs, 14 instructions/skills — **no true content duplicates were found**. Recipe families that share a theme (e.g., the four `retro-driven-*` variants plus `retro-quality-sweep.md` plus `retro.md`) are distinct workflows that compose the same primitive into different end-to-end shapes; merging them would lose useful content.

#### Changes

- **`docs/governance-index.md`** — gains an explicit **Audience Matrix** section defining the three canonical audiences (operator, agent, maintainer) with entry-point examples for each. Every existing section header gains an `**Audience:**` line. A new **Consolidation Notes** section documents the v6.0 finding (zero merge candidates) and explains why doc count stays at 96.

#### Invariants

- Zero deletions, zero merges, zero structural changes to recipes/guides/skills/instructions.
- Audience tagging is at the section level, not file-level frontmatter, so no recipe content is touched. Frontmatter is reserved for future B6.x increments if a use case emerges.
- Future drift toward duplication is detected by `governance-index-lint.sh` — if a near-duplicate IS added, it shows up in the orphan check before being indexed.
- Doc count from 96 stays at 96 in v6.0; the design's "drops ~15%" goal was based on the assumption duplicates would surface during the audit. They didn't.

### B5 — Skills inventory + pruning baseline (zero deletions)

**Theme:** v6 design B5 called for trimming thin-pointer skills (<80 LOC each) and keeping substantive policy skills. After auditing every skill in `skills/`, the conclusion is that **no skill in the current set is a pure pointer** — every entry carries enforceable rules that an agent invokes at trigger time. The v6.0 baseline is therefore "zero deletions", captured in a new `skills/INVENTORY.md` so v6.0.1 can act on operator-reviewed pruning candidates if they emerge later.

#### Changes

- **NEW** `skills/INVENTORY.md` — single source of truth listing every skill with its LOC, status (KEEP / CONSOLIDATE / POINTER-DELETE / REVIEW), and notes on why it's substantive. The full table covers 34 skills, ~3,800 LOC, 0 pruning candidates.

#### Invariants

- No skill is removed in v6.0 — downstream installs stay byte-compatible with v5.3.0.
- The inventory file is the audit point for future pruning decisions.
- If a future skill IS authored as a pure pointer, it's recorded here with `POINTER-DELETE` status and removed in the next minor release.
- The inventory itself is the v6.0 deliverable; an auto-generator (`bubbles/scripts/generate-skill-inventory.sh`) is planned for v6.1 so the size column never drifts.

### B3 — result-envelope validator: malformed envelopes block; missing still warn

**Theme:** v5.2 / F5 added the validator as fully advisory. v6.0 / B3 flips the default policy: malformed envelopes now BLOCK framework-validate, but missing envelopes still WARN. Authoring valid envelopes for all 40 agents is a substantial content task tracked separately as v6.1 — flipping "missing → blocking" today would block every push without first rolling out per-agent envelope blocks.

The v5.2 / F5 advisory mode is preserved verbatim under `--advisory` for operators who need temporary backwards compatibility (e.g., bisecting an upstream change).

#### Changes

- **`bubbles/schemas/result-envelope.schema.json`** — three compatibility fixes:
  - `additionalProperties` flipped to `true` (was `false`) so agents can carry richer fields (`roleClass`, `featureDir`, `scopeIds`, `dodItems`, `packetRef`, `artifactsCreated`, `artifactsUpdated`, etc.) without schema drift.
  - `nextRequiredOwner` accepted as an alias for `nextOwner` when `outcome=route_required`. Either field satisfies the conditional `required` clause via `anyOf`.
  - `blockedReason` accepted as an alias for `blocker.reason` when `outcome=blocked`, same `anyOf` pattern.
  - Both `nextOwner` and `nextRequiredOwner` accept `["string", "null"]` so template envelopes that show null placeholders for non-routing outcomes parse cleanly.
- **`bubbles/scripts/result-envelope-validate.sh`** — three modes instead of two:
  - `--advisory` (was the v5.2 default) — never block.
  - no args (v6.0 default) — block on **malformed** envelopes only; warn on missing.
  - `--strict` (v6.1+ opt-in) — block on missing OR malformed.
- **NEW** `bubbles/scripts/result-envelope-validate-selftest.sh` — 12 assertions covering all three modes plus the schema-compatibility fixes plus a deliberately-invalid `outcome` fixture that fails in every mode (truly invalid envelope is always blocking).
- **`bubbles/scripts/framework-validate.sh`** — the advisory invocation is upgraded to v6.0 default mode and the new selftest is registered after the diff-evidence-guard selftest.

#### Invariants

- Monotonically stronger: v5.2 advisory mode still reachable; v6.0 strictly adds malformed-blocks behavior; v6.1 strict mode is opt-in.
- Backwards compatible: agents that already carry `nextRequiredOwner` or `blockedReason` (instead of `nextOwner` / `blocker.reason`) keep working.
- Schema accepts richer envelope shape — no agent file needs editing to pass v6.0 default mode.
- Adversarial: a deliberately invalid `outcome` value fails in v6.0 default AND strict modes (truly invalid envelope always blocks).
- Out of scope for B3: authoring envelope blocks for the 38 agents that currently lack one. Tracked as v6.1.

### B2 — diff-evidence-guard default-on for all specs

**Theme:** v5.2 / F2 introduced a date-based auto-strict policy: specs created on/after `2026-06-04` got strict mode automatically; older specs stayed advisory. v6.0 flips the default — diff-evidence-guard is strict for ALL specs unless the spec's `state.json.modernization.diffEvidence` explicitly opts out to `"advisory"`. The v5 grandfather clause survives ONLY for pre-cutoff specs that have no `modernization` block at all — touching `state.json` (any write) demotes them to v6 policy.

#### Changes

- **`bubbles/scripts/diff-evidence-guard.sh`** — promotion rules rewritten:
  - `state.json.modernization.diffEvidence == "advisory"` → advisory mode (explicit opt-out).
  - `state.json.modernization.diffEvidence == "enforce"` → strict mode (explicit opt-in).
  - `state.json.modernization` missing or empty → strict mode by default (v6.0 / B2).
  - **Grandfather:** pre-cutoff (`< 2026-06-04`) spec with NO `modernization` block at all → advisory (legacy compatibility). Touching `state.json` demotes to v6 policy.
  - `--strict` flag and `BUBBLES_DIFF_EVIDENCE_GUARD_STRICT=1` still force strict.
  - Pre-existing bug fix: the FAIL/WARN output used backticks (`` `{p}` ``) inside the bash heredoc, which collapsed them via command substitution. Switched to single quotes.
  - Pre-existing bug fix: `Path(sf).relative_to(repo_root)` failed when `sf` was already a relative path. Use `str(Path(sf).resolve()).removeprefix(...)` instead.
- **NEW** `bubbles/scripts/diff-evidence-guard-selftest.sh` — 7 assertions covering all promotion paths: enforce/advisory choice in state.json, v6 default-on, v5 grandfather clause, `--strict` and env-var overrides, and a real-committed-path-claim positive case.
- **`bubbles/scripts/framework-validate.sh`** — registers the new B2 selftest after the B1 bridge selftest.

#### Invariants

- Monotonically stronger: v5.2's date-based auto-strict still applies; v6.0 broadens it to all-specs-unless-opted-out.
- Backwards compatible: pre-cutoff specs with no modernization block stay advisory until their state.json is touched.
- Manual overrides (`--strict`, env var) work in both directions.
- Markdown ≥10-line raw-evidence path remains the parallel evidence channel that v5 introduced; diff-evidence-guard is an ADDITIONAL signal that path-claims in DoD text correspond to actual git changes.

### B1 — evidence-tool-log-bridge MCP-primary with structured JSON envelope

**Theme:** v5.1 introduced the bridge as an advisory matcher and v5.2 promoted it to a primary evidence path (alongside the markdown ≥10-line raw-output path). v6.0 flips it to MCP-primary: the bridge gains a `--format=json` mode whose structured envelope is consumed by the `query_tool_log` MCP tool. When an MCP-aware client is registered, the orchestrator can ask "does the tool-log already contain evidence that satisfies DoD item X?" and receive a programmatic answer instead of a human-readable text blob. The bash twin and the markdown evidence path both remain accepted.

#### Changes

- **`bubbles/scripts/evidence-tool-log-bridge.sh`** — gains `--format=text|json`. JSON mode emits:

    ```json
    {
      "spec":           "<spec-slug>",
      "logPath":        "<absolute path>",
      "logPresent":     true | false,
      "scopeFiles":     N,
      "dodItems":       N,
      "toolLogEntries": N,
      "matchedDodItems": N,
      "coveragePct":    0-100,
      "matches":        [{"scopeFile":..., "line":N, "dodBody":..., "cmd":..., "ts":..., "overlapTokens":[...]}, ...]
    }
    ```

- **NEW** `bubbles/scripts/evidence-tool-log-bridge-selftest.sh` — 8 assertions covering text mode (no log + with log), JSON mode (no log + with log), valid-JSON output, unknown-format rejection, missing-arg rejection, and MCP catalog wiring.
- **`bubbles/mcp/tools/query_tool_log.json`** — `argsTemplate` now appends `--format=json` so the MCP tool returns a parseable envelope. `successExitCodes` tightened to `[0]` (was `[0, 1]`; the bridge no longer signals coverage gaps via exit code).
- **`bubbles/scripts/framework-validate.sh`** — registers the new bridge selftest after `tool-log-selftest`.

#### Invariants

- Bridge is monotonically stronger: text mode behavior preserved; JSON mode is additive.
- Markdown ≥10-line raw-evidence path is still a fully accepted form (the bridge never blocks).
- MCP tool surfaces verbatim bridge stdout — the server doesn't summarize.
- Adversarial: unknown `--format` value rejected; missing spec dir rejected.

### B4 — workflow mode collapse: 55 v5 modes → 15 v6 primitives + tags

**Theme:** v5 exposed 55 hand-coded workflow modes (`release-train-promote`, `upkeep-restore-drill`, `bugfix-fastlane`, ...). v6.0 collapses the operator-visible surface to 15 canonical primitives plus a deterministic tag grammar. Every v5 mode still works through the v6 cycle via an alias map; the v7 release removes the v5 names. The migrate-modes-v5-to-v6.sh script (Group C / C1) will rewrite operator invocations automatically.

#### Changes

- **NEW** `bubbles/workflows/aliases.yaml` — the v5 → v6 alias map. 55 entries cover every mode in `bubbles/workflows.yaml`. 15 canonical primitives (`analyze`, `plan`, `implement`, `test`, `validate`, `fix`, `ship`, `propagate`, `upkeep`, `review`, `improve`, `docs`, `iterate`, `resume`, `framework-health`). Tag grammar: `action:<verb>`, `task:<task-name>`, `target:<thing>`, `train:<name>`, `edge:<direction>`, `lifecycle:<state>`.
- **NEW** `bubbles/scripts/mode-alias-selftest.sh` — 11 assertions covering: parse + non-empty, 1:1 coverage with workflows.yaml, no unknown v5 references, every primitive canonical, tuple uniqueness, full v6→v5 round-trip (55 modes), byte-identical resolution (subset by default; full set under `BUBBLES_MODE_ALIAS_FULL_PARITY=1`), plus three adversarial fixtures (unknown primitive, unknown tag, duplicate tuple).
- **`bubbles/scripts/mode-resolver.sh`** — extended with:
  - `--list-aliases` (TSV: v5-name<TAB>primitive<TAB>tag-set)
  - `--resolve-v6 <primitive> [tag:val ...]` (v6 form → v5 mode name)
  - Bare-arg dispatch accepts both `<v5-mode>` (with one-line deprecation hint pointing at the v6 form) and `<primitive> tag:val [tag:val ...]` (v6 form, resolves internally to v5 and prints the v5 resolution).
  - Honors `BUBBLES_WORKFLOW_ALIASES_FILE` env var (used by selftest fixtures).
- **`bubbles/scripts/framework-validate.sh`** — registers the new `mode-alias-selftest` selftest after `mode-resolver-selftest`.
- **`bubbles/scripts/trust-metadata.sh`** — enumerates `bubbles/workflows/**` into the release manifest so downstream installs receive the alias map.
- **`install.sh`** — copies `bubbles/workflows/` to `${TARGET}/bubbles/workflows/` during downstream install (mirrors the v5.2.1 / B7 patterns).
- **`bubbles/release-manifest.json`** — regenerated (489 managed files; was 487).
- **`CHANGELOG.md`** — v6.0 Group B4 entry.

#### Invariants

- v5 names remain valid through the entire v6 cycle (deprecation warning only, never block).
- Every v5 mode maps to exactly one (primitive, tag-set) tuple; every tuple is unique.
- Resolved-mode bytes are identical between v5 invocation and v6 invocation.
- `analyze` is a canonical v6 primitive with no v5 alias; v6 unlocks `analyze target:<thing>` as a new direct-invocation surface that v5 only exposed under `plan target:product action:analyze-design-plan`.
- Adversarial regression: unknown v6 primitive, unknown tag for a known primitive, and duplicate tuple in an alternate aliases file are all rejected.

#### Working order

- B7 (cheatsheet generator) shipped in commit `eb9a617`.
- B4 (this entry) ships the alias map + selftest. Operators can now invoke either form; documentation and migration script land in C1-C3.

### B7 — cheatsheet generator + retire H7 drift selftest

**Theme:** the v5.0.1 H7 drift selftest treated `docs/CHEATSHEET.md` and `docs/its-not-rocket-appliances.html` as two independent surfaces that had to be kept in sync. v6 collapses them to a single source of truth so drift is structurally impossible.

#### Changes

- **NEW** `bubbles/cheatsheet/` — registry directory. Three JSON files (`modes.json`, `aliases.json`, `vocabulary.json`) plus a `README.md` describing the schema and the add-an-entry workflow. The registry is the only place an operator edits mode/alias/vocabulary content; both cheatsheets are generated.
- **NEW** `bubbles/scripts/generate-cheatsheet.sh` — generator. Reads the registry, validates it (every mode name must resolve to a real `workflows.yaml` entry; every `maps_to` must be a `bubbles.<agent>` token or a known mode; no duplicate aliases or vocab terms), then renders six blocks: three in `docs/CHEATSHEET.md` (`GENERATED:CHEATSHEET_ALIASES_*`, `GENERATED:CHEATSHEET_MODES_*`, `GENERATED:CHEATSHEET_VOCABULARY_*`) and three in `docs/its-not-rocket-appliances.html` (`GENERATED:HTML_ALIASES_TABLE_*`, `GENERATED:HTML_MODES_CARDS_*`, `GENERATED:HTML_VOCABULARY_CARDS_*`). Supports `--check` for CI.
- **NEW** `bubbles/scripts/generate-cheatsheet-selftest.sh` — 17 assertions covering registry parse, `--check` parity, marker presence in both files, and two adversarial fixtures (phantom workflow mode → reject; duplicate alias → reject).
- **`bubbles/scripts/framework-validate.sh`** — replaces the `cheatsheet-drift-selftest` invocation with `generate-cheatsheet-selftest`.
- **`bubbles/scripts/release-check.sh`** — adds `generate-cheatsheet.sh --check` as a freshness gate; release fails if the registry was edited without regenerating the cheatsheets.
- **`bubbles/scripts/trust-metadata.sh`** — enumerates `bubbles/cheatsheet/**` into the release manifest so downstream installs receive the registry alongside the generator.
- **DELETED** `bubbles/scripts/cheatsheet-drift-selftest.sh` — the v5.0.1 H7 diff-only check. The generator makes drift impossible by construction.
- **`docs/CHEATSHEET.md`** — `Command Aliases`, `Workflow Modes`, and `TPB Vocabulary` tables are now between `GENERATED:CHEATSHEET_*` markers.
- **`docs/its-not-rocket-appliances.html`** — `Sunnyvale Command Aliases` table, `Workflow Mode Aliases` cards, and `TPB Vocabulary` cards are now between `GENERATED:HTML_*` markers.

#### Invariants

- Registry is the only edit point; both cheatsheets regenerate from it.
- `--check` mode is byte-identical reproducible (used by `framework-validate` and `release-check`).
- Adversarial regression: removing a `GENERATED:*` marker, adding an unknown mode, or duplicating an alias all fail the selftest.

## v5.3.0 — Downstream-install validation cleanup

**Theme:** `framework-validate` was authored inside the framework source repo and several of its selftests hardcoded assumptions that only hold from that tree (`install.sh` at repo root, `VERSION` file, `README.md`/`docs/` layout, `agents/` and `bubbles/` directly under the repo root). When downstream repos installed Bubbles, their copy of `framework-validate` would FAIL 11+ checks against expected-to-be-missing files, even though every framework-managed asset was installed correctly. A downstream install surfaced this with 11 baseline failures (9 source-only + 2 path-resolution).

v5.3 fixes the validation surface to be downstream-aware without weakening anti-fabrication or any gate enforcement.

### Changes

- **bubbles/scripts/framework-validate.sh** (`G1`): adds install-mode detection (`source` / `downstream` / `unknown`) based on presence of `install.sh`+`VERSION` (source) vs `.github/bubbles/.install-source.json` (downstream). Override via `BUBBLES_FRAMEWORK_VALIDATE_MODE=source|downstream` for selftest harnesses that synthesize either tree.
- **bubbles/scripts/framework-validate.sh**: new `run_check_self_only` wrapper. The 9 selftests that depend on framework-source-only assets (`install.sh`, `VERSION`, the framework's own `README.md`/`docs/`/`bubbles/capability-ledger.yaml`) now SKIP instead of FAIL when run from a downstream tree, with explicit `SKIP: <label> (framework-source-only; install-mode=...)` accounting. Footer reports both `failures` and `skipped` counts. List: capability-ledger, capability-freshness, competitive-docs, interop-apply, release-manifest-freshness, release-manifest-selftest, release-manifest-purity, install-provenance, trust-doctor, runtime-lease.
- **bubbles/scripts/spec-review-handoff-selftest.sh**: dual-resolve `agents/` and `bubbles/` so the selftest works from either source repo (`<root>/agents/...`) or downstream install (`<root>/.github/agents/...`).
- **bubbles/scripts/workflow-delegation-selftest.sh**: dual-resolve `docs/` and `bubbles/` for the same reason. `WORKFLOW_MODES.md`, `agent-capabilities.yaml`, `workflows.yaml` are all resolved against the active install tree.
- **bubbles/scripts/v5.3-selftest.sh** (NEW): synthesizes a minimal `.github/`-style downstream tree and asserts (T1) install-mode detection works downstream, (T2) install-mode detection works from source, (T3) all 9 self-only selftests SKIP cleanly with no FAIL, (T4) spec-review-handoff selftest passes against the synthetic tree, (T5) workflow-delegation selftest passes against the synthetic tree. Wired into `framework-validate.sh` so the v5.3 invariant is enforced on every source-side run.

### Downstream Verification

`cd ~/<repo> && bash .github/bubbles/scripts/framework-validate.sh` now exits 0 with:

```
SKIP: Capability ledger selftest (framework-source-only; install-mode=downstream)
SKIP: Capability freshness selftest (framework-source-only; install-mode=downstream)
SKIP: Competitive docs selftest (framework-source-only; install-mode=downstream)
SKIP: Interop apply selftest (framework-source-only; install-mode=downstream)
SKIP: Release manifest freshness (framework-source-only; install-mode=downstream)
SKIP: Release manifest selftest (framework-source-only; install-mode=downstream)
SKIP: Release manifest purity selftest (framework-source-only; install-mode=downstream)
SKIP: Install provenance selftest (framework-source-only; install-mode=downstream)
SKIP: Trust doctor selftest (framework-source-only; install-mode=downstream)
SKIP: Runtime lease selftest (framework-source-only; install-mode=downstream)
Framework validation passed (10 self-only check(s) skipped under install-mode=downstream). Run from a framework-source tree to execute them.
```

(was: `Framework validation failed with 11 failing check(s).`)

### Backward Compatibility

- Source-repo `framework-validate` runs the full set unchanged — no selftest weakened, no gate skipped, no assertion removed.
- Downstream `framework-validate` now passes when the install is healthy. Genuine breakage (broken `workflows.yaml`, missing schema, drift in a downstream-resolvable selftest) still FAILs.
- `cli.sh doctor` and `cli.sh framework-validate` dispatch surface unchanged.
- No agent contract change. No state.json schema change. No `install.sh` behavior change.

## v5.2.1 — Installer + manifest enumerator for v5.2 F4 registry

**Theme:** v5.2.0 introduced `bubbles/registry/gates.yaml` (F4 gate registry consolidation) but the `install.sh` script and the release-manifest enumerator (`bubbles/scripts/trust-metadata.sh`) were not updated to copy/enumerate the new directory. Downstream repos that ran v5.2.0's installer received the new scripts (`generate-gates-block.sh`, `gates-registry-selftest.sh`) but no `bubbles/registry/gates.yaml` for them to read against — the gates-registry-selftest would skip, and the drift check would fail to find the canonical source.

v5.2.1 closes this gap.

### Changes

- **install.sh**: new install step copies `bubbles/registry/` from the source payload into `${TARGET}/bubbles/registry/` (mirrors the existing `bubbles/schemas/` copy pattern).
- **bubbles/scripts/trust-metadata.sh** (`bubbles_framework_manifest_entries`): enumerates every file under `bubbles/registry/` so the release manifest tracks `bubbles/registry/gates.yaml` as a framework-managed file. Downstream repos receive it on install and pre-push `release-manifest` selftests stay green.

### Backward Compatibility

- All v5.2.0 work items (F1–F9) ship unchanged.
- Downstream repos that already upgraded to v5.2.0 should re-run `install.sh --local-source` (or remote install) to pick up `bubbles/registry/gates.yaml`. Until they do, the gates-registry-selftest reports SKIP rather than FAIL on the missing file (it returns early instead of asserting drift).
- No agent contract change. No state.json schema change.

## v5.2.0 — Flip advisory plumbing → primary

**Theme:** v5.1 introduced typed plumbing (tool-log, evidence-bridge, diff-evidence-guard, gate-meta facade, code-search facade, schema validators) as opt-in/advisory so the framework + 5 downstream repos could absorb the change without breakage. v5.2 flips the bridges to primary so the typed paths actually do enforcement, and consolidates the gate registry so v6 MCP work has a single source to point at.

Anti-fabrication monotonically stronger. Markdown evidence path stays valid for the entire v5.2 cycle. No mode rename. No agent contract change. No state.json schema change. Pure mechanical upgrade via `install.sh --local-source`.

### F1 — Tool-log primary evidence path

- `bubbles/scripts/state-transition-guard.sh` Check 9 now accepts a 4th evidence path: a tool-call log entry whose `cmd` shares ≥2 distinct alpha-tokens with the DoD line body AND has `exitCode == 0`. Agents that wrap their gate-relevant commands via `tool-log.sh` no longer need to inline ≥10-line raw output under every DoD item — the structured log is cryptographic-hash-grade evidence that the command actually ran.
- The existing markdown paths (cases 1–3: inline `Evidence:` marker, anchor link, inline evidence block) remain valid. F1 is strictly additive: a DoD item with EITHER a markdown evidence block OR a matching tool-log entry passes.
- Anti-fabrication invariant: a DoD with NEITHER still fails.

### F2 — Diff-evidence-guard auto-strict for new specs

- `bubbles/scripts/diff-evidence-guard.sh` now auto-promotes to `--strict` mode when:
  - `state.json.modernization.diffEvidence == "enforce"`, OR
  - the spec's first commit is on/after `2026-06-04` (v5.2 cutoff).
- Older specs default to advisory. Operators can opt a spec out of strict mode by setting `state.json.modernization.diffEvidence == "advisory"`.
- The `BUBBLES_DIFF_EVIDENCE_GUARD_STRICT=1` env var and `--strict` flag continue to override (always force strict).

### F3 — Tool-call schema v2 (additive, backward-compatible)

- `bubbles/schemas/tool-call.schema.json` adds `schemaVersion` (1|2) and `framework` provenance block (`{name, version, sourceGitSha}`).
- `bubbles/scripts/tool-log.sh` writes `schemaVersion: 2` on every new entry and resolves framework provenance from `.github/bubbles/.version` (downstream repos) or repo `VERSION` (the framework repo itself) plus `.github/bubbles/.install-source.json` `sourceGitSha`.
- Schema explicitly accepts both v1 (no `schemaVersion`) and v2 records. Existing logs continue to validate. Migration is forward-only.

### F4 — Gate registry consolidation

- New canonical file: `bubbles/registry/gates.yaml` (extracted verbatim from the workflows.yaml `gates:` block).
- New generator: `bubbles/scripts/generate-gates-block.sh` with three modes:
  - default — splice registry into `bubbles/workflows.yaml` (byte-identical when in sync).
  - `--check` — exit 0 if in sync, 1 if drifted. Used in `framework-validate`.
  - `--print` — emit the regenerated `workflows.yaml` to stdout.
- Design: the registry IS the canonical YAML form. The generator splices the registry verbatim between the `gates:` line in `workflows.yaml` and the first blank line whose next non-blank is a top-level key OR top-level comment. Round-trip is byte-identical by construction; all comments inside the registry are preserved.
- New selftest: `bubbles/scripts/gates-registry-selftest.sh` (T1 registry exists, T2 in sync, T3 round-trip stable, T4 drift detected, T5 gate-meta count matches).
- `framework-validate` runs both the drift `--check` and the round-trip selftest.

### F5 — Result-envelope validator (advisory in v5.2, blocking in v6)

- New script: `bubbles/scripts/result-envelope-validate.sh`. Scans every `agents/*.agent.md` for fenced JSON blocks tagged as `result_envelope:` or under a `## Result Envelope` heading and validates each against `bubbles/schemas/result-envelope.schema.json`.
- Advisory in v5.2: missing block warns, malformed block warns, always exit 0. v6 flips to blocking (`--strict` exits 1).
- Runs in `framework-validate` to surface drift early.

### F6 — Code-search auto-select with cache

- `bubbles/scripts/code-search.sh` persists the chosen backend (`rg` or `grep`) to `.specify/runtime/code-search.tool` on first call. Subsequent invocations skip the `command -v rg` probe.
- `BUBBLES_CODE_SEARCH_BACKEND=rg|grep` override is honored and does NOT mutate the cache (one-shot override).

### F7 — Model-tier warning written to tool-call log

- `bubbles/scripts/model-tier-advisory.sh` now writes a structured `model-tier-warning` entry to the tool-call log when active model < floor.
- Entry shape: `schemaVersion: 2`, `tags: ["model-tier-warning"]`, plus a `modelTier` sub-object with `{mode, phase, floor, active, severity: "warn"}`. Survives operator scrollback and is queryable alongside command evidence.
- Stdout text is unchanged.

### F8 — Selftests

- New: `bubbles/scripts/gates-registry-selftest.sh` (5 assertions for F4).
- New: `bubbles/scripts/v5.2-selftest.sh` (aggregate for F1/F3/F6/F7; 8 assertions including v1↔v2 schema backward-compat, cache persistence, warning-only-when-below-floor).
- All v5.2 selftests wired into `framework-validate.sh`.

### F9 — Release

- VERSION → `5.2.0`. Downstream upgrade is `install.sh --local-source` with no manual steps. Migration steps (per repo, all optional): opt specs into `diffEvidence: enforce` in `state.json.modernization`; start emitting v2 tool-call records.

### Backward Compatibility

| Existing artifact | v5.2 behavior |
|---|---|
| `report.md` with markdown-only evidence | Still validates (paths 1–3 in Check 9). |
| `tool-call.jsonl` v1 entries | Still validate. New writes are v2. |
| Spec without `diffEvidence` declared in `state.json.modernization` | Auto-strict if spec was created on/after 2026-06-04; advisory otherwise. |
| Agent file without `result_envelope:` block | Warn-only in v5.2; blocking in v6. |
| Downstream repo without `bubbles/registry/gates.yaml` | `install.sh --local-source` creates it. |

### What v5.2 Does Not Do

- Does not remove the markdown evidence path.
- Does not delete any v5.1 advisory script (they become primary, not gone).
- Does not introduce MCP.
- Does not change agent prompts or mode names.
- Does not require any operator to rewrite historical `report.md` files.

## v5.1.1 — Top-level-runtime routing for fan-out modes

**Theme:** Close Failure Mode 4 — silent parent-expansion of fan-out workflow modes in subagent runtimes that lack `runSubagent`. Anti-fabrication invariant strictly stronger: fan-out modes (sweep / iterate / autonomous-*) can no longer be collapsed into one agent's turn through the parent-expansion fallback.

### Background

v5.0.x defined parent-expanded child mode as the fallback when nested `bubbles.workflow` subagents lack `runSubagent`. That fallback is correct for single-spec modes (`bugfix-fastlane`, `harden-to-doc`, etc.) where the phase chain is sequential and a single agent can legitimately execute every phase. It is INCORRECT for fan-out modes that dispatch N rounds × per-finding specialist chains (`bubbles.bug` → `bubbles.implement` → `bubbles.test` → `bubbles.validate` → `bubbles.audit` → `bubbles.docs`): collapsing those into one agent's turn forges cross-role transitions and produces evidence with no real specialist provenance.

### Changes

- **New mode constraint** `constraints.requiresTopLevelRuntime: true` declared on the six fan-out modes in `bubbles/workflows.yaml`:
  - `stochastic-quality-sweep`
  - `retro-quality-sweep`
  - `iterate`
  - `autonomous-goal`
  - `autonomous-sprint`
  - `idea-to-release-completion`
- **New routing rule** in `agents/bubbles_shared/workflow-execution-loops.md`: when a subagent runtime resolves a mode with `requiresTopLevelRuntime: true`, it MUST emit `route_required` with `routingReason: "top-level-runtime-required"` and `nextOwner: "user-session"`. Parent-expansion is forbidden for these modes.
- **New Failure Mode 4** added to the dispatch-failure-mode table — silent parent-expansion of fan-out modes is now an explicit prohibition with policy text.
- **Updated `bubbles.workflow` agent** (`agents/bubbles.workflow.agent.md`) — TOOL-AVAILABILITY ESCALATION section adds the `requiresTopLevelRuntime` exception explicitly.
- **Updated `bubbles.iterate` agent** (`agents/bubbles.iterate.agent.md`) — new "Top-Level Runtime Requirement" section spells out the route-up behavior for the iterate-in-subagent case.
- **Updated `bubbles.super` agent** (`agents/bubbles.super.agent.md`) — Front-Door Policy section adds the top-level-runtime routing rule so super doesn't dispatch fan-out modes as subagents.
- **New selftest** `bubbles/scripts/top-level-runtime-routing-selftest.sh` asserts: every fan-out mode has the flag set to exactly boolean `true`; no other mode has the flag spuriously set; documentation mentions Failure Mode 4 + the Top-level-runtime modes section + the `route_required` routingReason; every fan-out mode is listed by name in that section. Wired into `framework-validate.sh`.

### Backward compatibility

- Single-spec modes (`bugfix-fastlane`, `full-delivery`, `feature-delivery`, all `*-to-doc` modes, `release-train-*`, `upkeep-*`, `propagate-*`, `incident-fastlane`, `framework-health`, etc.) still allow parent-expansion exactly as in v5.0.x — only the six listed fan-out modes change.
- No agent contract change, no state.json schema change, no gate addition or removal.
- Mechanical upgrade via `install.sh --local-source`.

### Why this hotfix ships before v5.2

v5.2 strengthens evidence/diff/envelope enforcement during sweeps. If sweeps cannot orchestrate properly because subagent runtimes silently parent-expand and break role separation, v5.2's stronger evidence rules have no legitimate orchestrator to enforce them. Fix the orchestration loop first.

## v5.1.0 — Modernization Foundation

**Theme:** Structured tool-call provenance, machine-verifiable result envelopes, query-able gate registry, model-tier policy advisory. Sets up v6's MCP migration by replacing prose-based plumbing with typed artifacts. Anti-fabrication is monotonically stronger; no existing gate softened.

### M1 — Structured tool-call evidence log

- **New:** `bubbles/scripts/tool-log.sh` wraps any command, streams stdout/stderr to the caller AND records a JSONL entry to `.specify/runtime/tool-calls.jsonl` with `{ts, sessionId, agent, spec, scope, cmd, exitCode, durationMs, stdoutHash, stderrHash, tags}`.
- **New:** `bubbles/schemas/tool-call.schema.json` defines the record shape.
- **New:** `bubbles/scripts/tool-log-selftest.sh` (4 cases, all PASS) — exit-code preservation, session continuity, hash recording, schema validation.
- **No-bypass design:** there is no `--no-log` flag. Anti-fabrication invariant — every wrap MUST record.

### M2 — Evidence ↔ tool-log bridge (advisory in v5.1, primary in v5.2)

- **New:** `bubbles/scripts/evidence-tool-log-bridge.sh` reports DoD ↔ tool-call coverage for a spec. Heuristic matcher: ≥2 non-stopword token overlap between DoD body and recorded `cmd`, plus `exitCode == 0`.
- **Advisory only in v5.1.** Existing ≥10-line raw-output evidence path remains valid. v5.2 promotes tool-log to a primary structured evidence path — at which point DoD items with a passing tool-log entry no longer require inline ≥10-line output.

### M3 — JSON result envelopes

- **New:** `bubbles/schemas/result-envelope.schema.json` — typed shape for the `RESULT-ENVELOPE` every Bubbles agent emits. Fields: `agent`, `outcome` (one of `completed_owned`/`completed_diagnostic`/`route_required`/`blocked`), `findings[]`, `addressedFindings[]`, `unresolvedFindings[]`, `nextOwner`, `blocker`, `continuation`, `toolCalls[]`.
- Markdown envelope stays for human readability. JSON envelope is additive — workflow agent will start consuming it instead of grepping prose in v6.

### M5 — Diff-aware DoD evidence guard

- **New:** `bubbles/scripts/diff-evidence-guard.sh` cross-references DoD claims of `add`/`create`/`new` against `git diff <baseSha>..HEAD`. When a DoD item names a file path it claims to have added but the path isn't in the diff, the guard reports a mismatch.
- Advisory in v5.1 (`BUBBLES_DIFF_EVIDENCE_GUARD_STRICT=1` to flip blocking). Catches the "claimed done, didn't change code" failure mode that survives prose-evidence inspection.

### M6 — Gate registry query helper

- **New:** `bubbles/scripts/gate-meta.sh` exposes `list` / `count` / `exists` / `name` / `description` / `json` queries against the canonical `gates:` block. Becomes the single read interface as v5.2/v6 prepare to migrate gate metadata to `bubbles/registry/gates.yaml` — callers won't change.

### M7 — Model-tier policy (advisory)

- **New:** `bubbles/workflows.yaml` `modeDefaults.modelFloor` per-phase declarations. Defaults: `sonnet-class` for analyze/design/plan/implement/validate/audit/chaos/review/retro/spec-review; `opus-class` for security; unset for mechanical phases like `test`.
- **New:** `bubbles/scripts/model-tier-advisory.sh check --mode <m> --phase <p>` reads `BUBBLES_ACTIVE_MODEL` and warns when below floor. Advisory in v5.1; v6 S9 promotes to blocking.

### M8 — Code-search facade

- **New:** `bubbles/scripts/code-search.sh` delegates to `rg` when present, falls back to `grep`. Stable output across backends, 400-line cap (override with `--no-cap`). Saves agents from reinventing `grep`/`find` per repo and reduces token cost of exploration.

### M9 — Schema-validated control-plane manifests

- **New schemas:** `scenario-manifest.schema.json` (SCN-* contract manifests under `specs/*/scenario-manifest.json`), `propagation-policy.schema.json` (J-Roc's `propagation-policy.yaml`), `result-envelope.schema.json` (M3).
- `bubbles/scripts/yaml-schema-validate.sh` now also discovers and validates every `specs/*/scenario-manifest.json` plus `propagation-policy.yaml` when present. Drift in those manifests becomes a commit-time failure.

### Framework validation wiring

- `framework-validate.sh` now runs in order: registry-consistency-selftest → yaml-schema-validate → cheatsheet-drift-selftest → **tool-log-selftest (new)** → existing chain.

### Downstream impact

- Pure additive. No mode rename, no agent contract change, no state.json schema change.
- Agents may adopt `tool-log.sh` wrapping incrementally; no policy mandate yet.
- Mechanical upgrade: `install.sh --local-source <v5.1.0-checkout>`.

## v5.0.2 — Installer Schema Distribution + Manifest Self-Drift Fix

Follow-up patch to v5.0.1 that closes two gaps surfaced during the first downstream upgrade:

- **Installer now distributes JSON Schemas downstream.** `install.sh` had no copy block for `bubbles/schemas/`, so v5.0.1's `yaml-schema-validate.sh` had nothing to validate against in downstream repos. Added a typed copy step and extended the install-provenance selftest with 4 new assertions covering the schemas directory and each schema file.
- **Manifest enumeration now includes `bubbles/schemas/` and `bubbles/scripts/hooks/`** so downstream installs receive the new v5.0.1 surfaces via the standard manifest path.
- **Manifest freshness check is now stable against self-touching commits.** Previously the `gitSha` field embedded in the manifest pointed at the *prior* commit when the manifest itself was part of the new commit, producing a chicken-and-egg "stale" verdict. Two fixes: (1) `generate-release-manifest.sh` excludes the manifest from the payload-SHA `git log` lookup; (2) the `--check` comparator now diffs manifest content while ignoring the volatile `gitSha`/`generatedAt` fields. Counts, checksums, and inventories are still compared exactly.

Downstream impact: pure mechanical upgrade. After running `install.sh --local-source <v5.0.2-checkout>`, repos will have `.github/bubbles/schemas/` populated and can run `bash .github/bubbles/scripts/yaml-schema-validate.sh` locally.

## v5.0.1 — Hardening Release (Framework Eats Its Own Dog Food)

**Theme:** Close the drift gaps the v5.0.0 ship cycle exposed. No new features, no policy softening. Every selftest added in this release would have caught a real bug shipped in the previous cycle.

**Anti-fabrication invariant preserved.** This release adds 4 new selftests, fixes 4 registry-drift bugs, and tightens 1 installer regression — all without relaxing any gate.

### Registry Consistency (H1, H2, H3)

- **New:** `bubbles/scripts/registry-consistency-selftest.sh` — validates every `Gxxx` referenced in `workflows.yaml`, scripts, agents, and docs resolves to a gate defined in `bubbles/workflows.yaml` `gates:` block. Allows documented "former Gxxx" history mentions and custom-gate `G100+` range. Also lints `state-transition-guard.sh` for duplicate `CHECK <id>` labels.
- **Fixed:** added missing gate definitions G071 (`execution_only_validation_gate`), G072 (`evidence_provenance_gate`), G073 (`planning_only_source_edit_lockout_gate`) — referenced in 28 `requiredGates:` lists and 4 shared-module governance docs but never defined.
- **Fixed:** `state-transition-guard.sh` CHECK 20 now correctly references Gate G021 instead of the consolidated former G049.
- **Fixed:** annotated legacy `G045`/`G046`/`G099` references in regression-baseline-guard and gate-id-grep-selftest as documented history mentions.
- **Fixed:** renamed duplicate `CHECK 3B` (Validate certification → CHECK 3H) and corrected the misnumbered `# CHECK 4` comment block in `state-transition-guard.sh`.

### YAML Schema Validation (H4)

- **New:** `bubbles/schemas/{workflows,capability-ledger,adoption-profiles}.schema.json` — Draft-07 JSON Schemas for the three YAML registries that caused the strict-parser failures in the v5.0 downstream upgrade cycle.
- **New:** `bubbles/scripts/yaml-schema-validate.sh` — validates each YAML against its schema using PyYAML + jsonschema. Skips gracefully if dependencies unavailable; passes deterministically when present. Catches yesterday's "unquoted colon in YAML string" bug class at commit time.

### Installer Regression Fixtures (H5)

- **Extended:** `bubbles/scripts/install-provenance-selftest.sh` with 9 new post-install assertions covering the latent bugs found in the v5.0.0 downstream upgrade:
  - Adapters directory `.github/bubbles/adapters/observability/` is created.
  - `none.sh` and `prometheus.sh` are installed and executable.
  - Repo-root `.gitignore` is created/preserved and contains `improvements/`.
  - Negative assertion: NO stray `.github/.gitignore` is created (the earlier `${TARGET}/.gitignore` bug).
  - Manifest reports >= 300 managed files (sanity floor against enumeration regression).

### Manifest Enumeration Purity (H6)

- **New:** `bubbles/scripts/release-manifest-purity-selftest.sh` — plants untracked files inside framework directories, regenerates the manifest, and asserts the untracked files do NOT appear. Locks in the `git ls-files` fix added to `trust-metadata.sh`.

### Cheatsheet Drift Check (H7)

- **New:** `bubbles/scripts/cheatsheet-drift-selftest.sh` — diff-only check that every workflow mode and TPB vocabulary term present in `docs/CHEATSHEET.md` also appears in `docs/its-not-rocket-appliances.html`. Catches the v5.0 drift class where mode/vocab updates landed in MD but not HTML.
- **Fixed:** backfilled 4 workflow modes (`simplify-to-doc`, `spec-review-to-doc`, `release-planning-to-doc`, `idea-to-release-completion`) and 17 TPB vocabulary terms into the HTML cheatsheet so both surfaces are aligned. v6 replaces this with a generator (S5 in modernization plan).

### Pre-Push Hook for Source Repo (H8)

- **New:** `bubbles/scripts/hooks/pre-push.sh` + `bubbles/scripts/install-bubbles-hooks.sh`. Framework maintainers can install a pre-push hook that runs `framework-validate.sh` and `release-check.sh` before allowing any push. Idempotent and appends to any existing hook rather than replacing it. NO bypass flags.

### Honest Stats (H9)

- Gate count badge in `README.md` and `docs/generated/framework-stats.*` regenerated to reflect 101 gates (was 98 with 3 missing definitions). Counts now equal the actual `gates:` block size and the selftest enforces no dead refs.

### Framework Validation Wiring

- `framework-validate.sh` now runs in order: registry-consistency-selftest → yaml-schema-validate → cheatsheet-drift-selftest → existing checks → release-manifest-purity-selftest → existing tail.

### Downstream Impact

- Pure framework hardening. Downstream upgrade is mechanical (`install.sh --local-source`).
- No mode renames. No agent contract changes. No state.json schema changes.

## v5.0.0 — Production Cycle Platform

The full production-cycle layer: cross-train propagation, multi-train portfolio rollup, incident response fastlane, live telemetry adapters, and framework self-observation. One new agent (J-Roc / `bubbles.propagate`), five workflow modes, six gates, two reference adapters, plus NL-first routing so users still only ever type into `bubbles.super`/`workflow`/`goal`/`sprint`.

### Added — bubbles.propagate (J-Roc) — cross-train change propagation

- New agent `bubbles.propagate` (J-Roc, "cross-train hustler") with single-prop SVG icon `icons/jroc-cap.svg` (backward cap) and quote *"Same fix, every park, knawmsayin?"*.
- Owns `propagation-policy.yaml` (root or `config/`) and `propagation-ledger.yaml` (append-only JSONL).
- Three operations: `forward` (auto-cherry-pick across declared train edges), `backport` (reverse cherry-pick under approval guard), `audit` (read-only drift report).
- Boundary discipline: routes cherry-pick execution to `bubbles.devops` (Tommy) and receiving-train validation to `bubbles.validate`/`bubbles.test` per edge policy. NEVER runs `git cherry-pick` inline; NEVER edits `config/release-trains.yaml` or flag bundles.
- New skill `skills/bubbles-propagation-policy/` documenting the policy schema, edge semantics, ledger contract.
- New instructions `instructions/bubbles-propagation.instructions.md` (`applyTo: "**"`) with non-negotiable rules.
- New template `templates/propagation-policy.yaml.tmpl`.
- New recipe `docs/recipes/propagate-changes.md` (NL-first ordering).

### Added — bubbles.train multi-train rollup (`status --all-trains`)

- New action on `bubbles.train` (DVS): read-only rollup across every declared train. Reports id, phase, target_slot, flags_bundle, retention, pii, open-flag count.
- New script `bubbles/scripts/release-train-rollup.sh` + selftest (4 cases). Reads `config/release-trains.yaml` + `specs/*/state.json` for the open-flag count.
- New recipe `docs/recipes/multi-train-status.md`.

### Added — Incident fastlane

- New mode `incident-fastlane`: chains `bubbles.stabilize` (diagnose + classify severity) → `bubbles.train` (rollback authority) → `bubbles.devops` (redeploy) → `bubbles.validate` (confirm) → `bubbles.docs` (notes). Stabilize NEVER rolls back inline — DVS keeps that authority.
- `bubbles.stabilize` extended with a Severity Classification section (`incident`/`high`/`medium`/`low`).
- New recipe `docs/recipes/incident-response.md`.

### Added — Observability adapter contract

- New schema extension under `traceContracts.liveTelemetryEndpoints` documented in `docs/guides/CONTROL_PLANE_SCHEMAS.md`. Selects an adapter per signal (alerts / slo-burn / error-rate / deploy-impact).
- New adapter directory `bubbles/adapters/observability/`:
  - `none.sh` — default; all 4 verbs return `{}`.
  - `prometheus.sh` — reference; queries `${PROMETHEUS_BASE_URL}` (NO default; fail-fast when unset).
- Uniform 4-verb contract: `fetch-alerts`, `fetch-slo-burn`, `fetch-error-rate`, `fetch-deploy-impact`. Adapter exit 1 = telemetry unavailable (NOT a framework failure); consumers gracefully degrade.
- New script `bubbles/scripts/observability-adapter-lint.sh` + selftest (5 cases). Grep-validates every adapter declares all 4 verbs; runtime-verifies `none.sh` returns `{}`.
- New skill `skills/bubbles-observability-adapter/`.
- New recipe `docs/recipes/observe-production.md`.

### Added — Framework self-observation (`bubbles.retro target: framework`)

- New retro target: pivots `bubbles.retro` (Jim Lahey) from product retro to framework retro.
- Reads `.specify/runtime/framework-events.jsonl`, `workflow-runs.json`, `bubbles/capability-ledger.yaml`.
- Writes ONE proposal per invocation to `improvements/IMP-NNN-<slug>.md`. NEVER mutates `bubbles/*`, `agents/*`, or `bubbles/workflows.yaml`. Proposal-first; human-in-the-loop preserved.
- New mode `framework-health` (statusCeiling `framework_proposal_written`).
- New script `bubbles/scripts/retro-framework-health.sh` + selftest (4 cases) including a sentinel-mtime check enforcing the "zero writes outside `improvements/`" boundary.
- New recipe `docs/recipes/framework-health.md`.

### Added — NL-first routing surface

- New `bubbles/intent-routes.yaml`: 6 routes mapping 32 natural-language phrases to (targetAgent, targetMode) pairs.
  - "ship to v2 and v3" → propagate-forward
  - "backport" → propagate-backport
  - "what's missing on prod" → propagate-audit
  - "what's in prod and dev" → release-train-status-all
  - "prod is broken" → incident-fastlane
  - "framework health" → framework-health
- New script `bubbles/scripts/intent-routes-lint.sh` + selftest (8 cases). Validates: version, non-empty routes, lowercase phrases, no duplicates, every targetAgent in `agent-capabilities.yaml`, every targetMode in `workflows.yaml` (`.modes` key).
- `bubbles.super` Discovery Surfaces table updated: reads `intent-routes.yaml` to match NL phrases BEFORE falling back to descriptive parsing of agent docs.

### Added — Workflow modes (5 new) and gates (5 new)

| Mode | Ceiling | Owner |
|------|---------|-------|
| `propagate-forward` | `propagated_forward` | bubbles.propagate |
| `propagate-backport` | `propagated_backward` | bubbles.propagate |
| `propagate-audit` | `propagation_audited` | bubbles.propagate |
| `release-train-status-all` | `train_status_reported` | bubbles.train |
| `incident-fastlane` | `incident_mitigated` | bubbles.stabilize → bubbles.train chain |
| `framework-health` | `framework_proposal_written` | bubbles.retro |

| Gate | Name | Enforces |
|------|------|----------|
| G121 | propagation-policy-declared | `propagation-policy.yaml` exists + parses + references only declared trains |
| G122 | propagation-validation-required | Every edge has `receivingTrainValidationMode`; `none` requires `validationSkipReason` |
| G123 | propagation-ledger-recorded | Every operation appends one immutable JSONL line; backports record `approvalToken` |
| G124 | incident-severity-declared | `incident-fastlane` requires per-finding severity tag; `incident` routes rollback to bubbles.train |
| G125 | framework-health-evidence | `framework-health` writes proposal under `improvements/`; ZERO framework-file mutation |

### Registry changes

- `bubbles/agent-capabilities.yaml`: registered `bubbles.propagate` (class: execution-owner) with `executionClaimWriters` entry.
- `bubbles/agent-ownership.yaml`: added `propagation-policy` + `propagation-ledger` artifacts; added 3 routing rules (`crossTrainPropagation`, `propagationBackportApproval`, `propagationAudit`).
- `agents/bubbles.workflow.agent.md` mode enum: added all 6 new modes.
- `bubbles/scripts/framework-validate.sh`: wired 4 new selftests + 2 new live lints (intent-routes, observability-adapter).

### Stats

- Agents: 39 → 40
- Gates: 92 → 98
- Workflow modes: 49 → 55
- Phases: 26 (unchanged)

### TPB vocabulary

J-Roc joins the cast. The full bench in v5:

- DVS — single-train lifecycle (cut, promote, rollback, retire)
- **J-Roc — cross-train propagation (NEW)**
- Treena Lahey — recurring upkeep (backup, restore drill, BCDR, patch, secret rotation, flag cleanup, compliance sweep)
- Sonny Iron Lung Smith — release packets
- Shitty Bill — stabilization (now with `incident` severity routing)
- Tommy Bean — devops execution
- Tyrone — autonomous single goal
- Erica — autonomous multi-goal sprint
- Jim Lahey — retros (now with `target: framework` self-observation)
- Mr. Lahey — general first-touch

## v4.2.4 — Release Trains + Upkeep Framework

### Added — Release Trains + Upkeep Framework (Phase 0)

New trunk-based release-train model + recurring operational upkeep layer. Adds 2 agents, 11 workflow modes, 11 gates (G110-G120), 6 skills, 3 instructions, 2 schema templates, 2 recipes, 4 scripts.

**New agents:**

- **`bubbles.train`** (Detroit Velvet Smooth) — release-train lifecycle operator. Cuts candidates, promotes between slots, rollback pointer-swap, retires trains. Owns feature-flag lifecycle. New icon: `icons/dvs-mic.svg` (single-prop velvet curtain + cardioid mic on stand). Quote: *"Smoooth as silk, gentlemen. The train rolls on schedule."*
- **`bubbles.upkeep`** (Treena Lahey) — recurring operational hygiene owner. Calendar-driven dispatcher for backup verify, restore drill, BCDR drill, patch cycle, secret rotation, flag-cleanup audit, compliance sweep. New icon: `icons/treena-broom.svg` (single-prop broom + apron tie). Quote: *"Trailer don't clean itself, Jim. Never has."*

**New workflow modes** (`bubbles/workflows.yaml`):

- `release-train-cut`, `release-train-promote`, `release-train-rollback`, `release-train-retire` (status ceilings: `train_cut`, `train_promoted`, `train_rolled_back`, `train_retired`)
- `upkeep-backup-verify`, `upkeep-restore-drill`, `upkeep-bcdr-drill`, `upkeep-patch-cycle`, `upkeep-secret-rotation`, `upkeep-flag-cleanup`, `upkeep-compliance-sweep` (status ceilings: `backup_verified`, `restore_verified`, `bcdr_verified`, `patched`, `secrets_rotated`, `flags_audited`, `compliance_swept`)

**New gates (G110-G120):**

- G110 release-train-discipline, G111 flag-default-off-on-other-trains, G112 backup-evidence-required, G113 restore-drill-evidence, G114 bcdr-evidence, G115 env-pollution-isolation, G116 offsite-backup-required-for-prod-trains, G117 audit-trail-immutable, G118 backup-retention-declared, G119 secret-rotation-recorded, G120 pii-classification-declared

**New skills** (`bubbles/skills/`):

- `bubbles-release-train-model/` — trunk + trains + flags + phases doctrine
- `bubbles-upkeep-cadence/` — daily/weekly/monthly/quarterly playbook + ledger schema
- `bubbles-backup-bcdr-doctrine/` — 4-tier model (T1 ZFS / T2 host-local / T3 USB / T4 cloud), `OFFSITE_BACKEND` swap contract, RTO/RPO definitions
- `bubbles-env-pollution-isolation/` — extends test-env-isolation with monitoring + backup + manifest pollution vectors (G115)
- `bubbles-config-bundle-per-train/` — per-train YAML flag bundle authoring + language-specific consumption (Rust/Go/TS/Python)
- `bubbles-flag-lifecycle/` — naming discipline, retirement triggers, "flag dies + 1 cycle" rule

**New instructions** (`bubbles/instructions/`, all `applyTo: "**"`):

- `bubbles-release-trains.instructions.md` — non-negotiable train rules
- `bubbles-upkeep-operations.instructions.md` — calendar discipline + ledger immutability
- `bubbles-env-pollution-isolation.instructions.md` — extends test-env-isolation

**New scripts** (`bubbles/scripts/`):

- `release-train-guard.sh` — validates train registry + flag default-off (G110, G111)
- `release-train-flag-audit.sh` — overdue flag cleanup advisory
- `upkeep-calendar.sh` — calendar-driven due-task lister
- `env-pollution-scan.sh` — test-code → prod-surface write detector (G115)

**New schema templates** (`bubbles/templates/`):

- `release-trains.yaml.tmpl` — per-repo train registry schema
- `upkeep-calendar.yaml.tmpl` — per-repo upkeep cadence schema

**New recipes** (`bubbles/docs/recipes/`):

- `release-train-lifecycle.md` — cut + promote + rollback + retire operator recipe
- `upkeep-monthly.md` — monthly operator checklist + quarterly drill walkthrough

**Boundary model — B2 cooperative (anti-drift, anti-fabrication):**

- One writer per surface (`bubbles.train` owns `release-trains.yaml`, flag bundles, train-state fields; `bubbles.upkeep` owns `upkeep-calendar.yaml`, upkeep ledger, runbook, compliance report).
- Read access is open: `bubbles.train` reads upkeep ledger for promote-freshness gating (G112/G113); `bubbles.upkeep` reads train config + knb manifest for restore-test scoping.
- All writes flow through owner via packet — no inference, no fabrication.

**Compliance (C1 + C3):**

- 4 new compliance gates (G117-G120) baked into existing audit surface.
- New quarterly `upkeep-compliance-sweep` mode generates `docs/Compliance_Report.md`; `bubbles.upkeep` gathers evidence, `bubbles.audit` certifies. Treena cannot certify her own work.

**Cheatsheet + vocabulary updates:**

- `docs/CHEATSHEET.md` — added DVS + Treena rows; added 17 new TPB vocabulary entries (release train, cut, promote, slot, train phase, dark code, flag retirement, drift, upkeep cycle, near-line backup, offsite backup, restore drill, BCDR drill, RTO/RPO, OFFSITE_BACKEND, upkeep ledger, pollution isolation, compliance sweep)
- `docs/its-not-rocket-appliances.html` — matching DVS + Treena cards + 17 vocabulary cards
- `docs/guides/AUTONOMOUS_EXECUTION.md` — 3 new TPB vocabulary terms

**Registry updates:**

- `bubbles/agent-capabilities.yaml` — registered `bubbles.train` + `bubbles.upkeep` with `readOnlyAccess` cooperative boundary; added to executionClaimWriters
- `bubbles/agent-ownership.yaml` — added 9 new artifact entries (release-trains-config, feature-flag-bundles, release-train-state, release-trains-doc, upkeep-calendar, upkeep-ledger, upkeep-runbook, compliance-report) + 9 new routingRules entries

### Added — `artifact-lint.sh` Check 3 evidence-legitimacy skip markers (report.md only)

- **Check 3 escape hatch** (`bubbles/scripts/artifact-lint.sh`): Added
  HTML-comment marker pair `<!-- bubbles:evidence-legitimacy-skip-begin -->` /
  `<!-- bubbles:evidence-legitimacy-skip-end -->` that exempts wrapped code
  blocks from the ≥3-line and ≥2-terminal-signal evidence-legitimacy checks
  Check 3 enforces at `state.status == done`. Markers are honored ONLY in
  `report.md` files (spec.md/design.md/scopes.md retain stricter evidence
  shape) and ONLY when they appear outside fenced code blocks. Unmatched
  begin/end markers or an open skip region at EOF fail the lint with a
  dedicated `❌ Unmatched evidence-legitimacy-skip markers in <file>` message.
  An informational line `ℹ️  Skipped N evidence blocks under … markers in
  <file>` is emitted when N > 0. Intended use: long-running specs whose
  accumulated round-history evidence pre-dates the stricter signal heuristic;
  preserves the audit trail without forcing destructive rewrites of historical
  rounds. **Audit-trail-preservation tool only — MUST NOT be applied to
  fresh-round evidence.**

### Changed — Guard tier-4 refinements (G009 evidence-by-reference + G056 schema loosening)

- **G009 DoD Evidence Presence** (`bubbles/scripts/state-transition-guard.sh`):
  Added evidence-by-reference resolver. When a `- [x]` line carries a
  markdown link of shape `[<text>](report.md#anchor)` (or
  `[…](../report.md#anchor)`), the gate now resolves the link, finds the
  anchor in the target report (Markdown heading slug, explicit
  `{#anchor}` attribute, or `<a name="anchor">`), and requires ≥10 non-blank
  lines of evidence between the anchor and the next heading (or EOF). This
  honors the long-standing report.md convention where multi-line terminal
  output is captured once and referenced by many DoD items, without forcing
  each `[x]` to inline 10+ lines of evidence. Pre-existing inline-evidence
  paths (`Executed:`, `Command:`, `Exit Code:`, fenced blocks) continue to
  satisfy G009 as in v4.0.x.
- **G056 Validate Certification State** (`bubbles/scripts/state-transition-guard.sh`):
  Loosened the schema check to enforce field PRESENCE without restricting
  value type. Pre-v4.1.0 patterns required `"certifiedCompletedPhases": [`,
  `"scopeProgress": [`, `"lockdownState": {` literal starts, which fired
  false positives when bubbles.validate emitted `null` or `[]` / `{}` as
  legitimate placeholders before the first scope landed. The field's
  structural content is still enforced by other gates (G024, G026, G027).

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

Promoted downstream-tested patches into the framework's two most-invoked guards. These started as local downstream patches and were proven in production before promotion; they extend the v3.11.1 downstream-installed guard layout resolution work without regressing any existing fixture.

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

- **Workflow registry consistency (Fix 1+6 for v3.8.0 release)** — `bubbles/scripts/workflow-registry-consistency.sh` `mode_inventory()` and `bubbles/scripts/generate-framework-stats.sh` `count_workflow_modes()` are now section-aware: the awk only collects 2-indent keys nested under the top-level `modes:` section. The previous awk inspected every 2-indent key in the file and used the `description:`-as-next-line heuristic alone, which incorrectly captured `outcomeStates.done` and `outcomeStates.blocked` (both have `description:` as the next field) and would have captured any future top-level section that adopted the same indentation+description convention. The new `phaseRelevance:` config block inside `modes:` is correctly excluded by the surviving description heuristic. Regenerated `agents/bubbles.workflow.agent.md` `Supported options:` to enumerate the canonical 35 delivery modes (alphabetical, `|`-separated, line ends exactly at the closing backtick so the `^- \`mode: ([^\`]+)\`$` regex in `supported_options_inventory()` matches), with the explanatory note moved to a follow-up indented bullet. Regenerated `docs/generated/framework-stats.json` workflowModes count from 34 → 35. Net: `workflow-registry-consistency.sh`,`cli.sh doctor` Check 9, and `workflow-surface-selftest.sh` all flip from FAIL → PASS.
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
