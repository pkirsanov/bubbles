# Design: 001 Competitive Framework Parity

## Design Brief

### Current State

Bubbles already has the core governance primitives that competing frameworks usually lack: workflow orchestration in `bubbles/workflows.yaml`, hard artifact ownership in `agents/bubbles_shared/artifact-ownership.md`, validate-owned certification in version 3 `state.json`, framework immutability enforced through installed `.manifest` and `.checksums` snapshots plus `framework-write-guard`, and source-repo trust checks via `framework-validate` and `release-check`. The source repo also already exposes a front door (`bubbles.workflow`), framework ops (`bubbles.super`), install/bootstrap (`install.sh`), project-owned override seams (`.github/bubbles-project.yaml`), managed-doc resolution (`bubbles/docs-registry.yaml`), and explicit release-manifest plus install-source provenance packaging for downstream trust.

The weakness is not missing rigor. The weakness is that the rigor is harder to adopt, harder to compare, and harder to trust quickly than it should be. New downstream repos still face a large cognitive load after bootstrap, interoperability with Claude Code, Roo Code, Cursor, and Cline is mostly manual, source-to-downstream upgrade trust is present but not packaged as one coherent story, and public capability claims can drift because competitive positioning and freshness hygiene are not driven from a single source of truth.

### Target State

This feature turns Bubbles' existing framework primitives into a cohesive competitive product surface without weakening any governance guarantees. The target system adds three missing layers on top of the current control plane: profile-guided onboarding, project-owned interoperability intake, and source-to-downstream trust packaging. Those layers must reuse the current install, CLI, registry, validation, and upgrade surfaces instead of bypassing them.

The result should let an evaluator understand Bubbles quickly, let a downstream maintainer bootstrap with a clearer next-action path, let an adopting team import prior rule investments into project-owned surfaces, and let downstream consumers verify exactly what they installed and what changed during upgrades. Bubbles remains strict, but the strictness becomes more legible and easier to operationalize.

### Patterns To Follow

- Registry-driven framework behavior, following existing sources such as `bubbles/workflows.yaml`, `bubbles/action-risk-registry.yaml`, `bubbles/docs-registry.yaml`, and `bubbles/agent-ownership.yaml`.
- Upstream-first framework management, as already enforced by `install.sh`, `framework-write-guard`, and the framework immutability rules in `critical-requirements.md`.
- Project-owned override seams, especially `.github/bubbles-project.yaml`, `.specify/memory/agents.md`, `.github/copilot-instructions.md`, and `.specify/memory/constitution.md`.
- Existing framework trust surfaces: `framework-validate`, `release-check`, `doctor`, `repo-readiness`, `framework-write-guard`, and `upgrade --dry-run`.
- Generated or registry-backed published truth instead of hand-maintained duplicate claims.

### Patterns To Avoid

- Any "lite" mode that weakens validate-owned certification, scenario contracts, or artifact ownership.
- Direct edits to framework-managed downstream paths such as `.github/bubbles/**`, `.github/agents/bubbles*`, or `.github/prompts/bubbles*`.
- Interoperability flows that silently rewrite project-owned artifacts without a reviewable intake record.
- Competitive matrices or known-issue docs maintained as prose only, with no machine-readable freshness source.
- All-at-once bootstrap or upgrade replacement that changes install, CLI, docs, trust, and interop in one unsafe step.

### Resolved Decisions

- "Bubbles Lite" is implemented as a named adoption profile, not as a separate framework distribution.
- Adoption profiles change onboarding guidance and default policy posture, but they do not relax completion gates.
- The evaluator-facing and docs-facing front door should recommend the `foundation` path for first-time adoption, while the installer default remains `delivery` until profile canaries prove a safe default change is warranted.
- Interoperability import flows write only to project-owned intake, proposal, and override surfaces.
- Source-to-downstream trust is packaged through generated release metadata plus install-source provenance, not through looser certification semantics.
- Competitive positioning, shipped capability claims, and issue freshness are driven from a single framework-owned capability ledger.
- Rollout is incremental: truth and trust first, onboarding profiles second, interop apply flows last.

### Open Questions

- Whether profile selection should live only in bootstrap and `bubbles policy`, or also be surfaced as a first-class `bubbles setup` action.
- Which external ecosystems should get apply-reviewable support in the first interop apply release versus detect-only or review-only support.
- How much benchmark evidence should be automated in the source repo versus curated in published docs.

## Purpose And Scope

This design applies to the Bubbles source repository at `/home/philipk/bubbles`. It does not describe downstream application implementation details. Instead, it defines the framework changes required so downstream repos can adopt, evaluate, upgrade, and interoperate with Bubbles more safely and with less friction.

The design must preserve all of the following:

- validate-owned certification and `state.json` authority boundaries
- scenario-contract discipline and live-behavior traceability
- project-agnostic command indirection through project registries
- framework-managed file immutability and upstream-first repair flow
- separation between advisory repo-readiness and certification-grade validation

## Overview

The parity design introduces a Bubbles-native parity layer with five cooperating parts:

1. **Adoption profile layer** — a profile-driven onboarding experience that reduces cognitive load without lowering any delivery gates.
2. **Interoperability intake layer** — registry-driven detection, normalization, and reviewable translation of external rule or mode assets into project-owned Bubbles-compatible surfaces.
3. **Trust packaging layer** — generated release metadata plus downstream install provenance that make source-repo quality and downstream upgrade integrity explicit.
4. **Freshness and capability truth layer** — a framework-owned capability ledger that drives competitive claims, docs freshness checks, and known-issue status hygiene.
5. **Incremental rollout layer** — parity work lands in bounded slices on top of existing install, CLI, docs, and validation surfaces.

This is an additive design. Existing entry points remain the same:

- `install.sh` still installs and bootstraps the framework.
- `bubbles.workflow` remains the universal work entry point.
- `bubbles.super` remains the framework-ops and advice front door.
- `framework-validate`, `release-check`, `doctor`, `repo-readiness`, `framework-write-guard`, and `upgrade` remain the trust and health surfaces.

## Competitive Response Matrix

The parity design must stay explicit about which competitor pressure each surface is answering so implementation does not drift into generic framework expansion.

| Competitor Pressure | User Concern | Design Response | Guardrail Preserved |
|---------------------|--------------|-----------------|---------------------|
| Claude Code is easier to evaluate, package, and trust quickly | Evaluators and maintainers see Bubbles as more rigorous but less legible | Capability-ledger-generated comparison docs plus release manifest and install provenance make quality and upgrade trust visible from one source of truth | Validate-owned certification remains separate from docs, doctor, and trust metadata |
| Roo Code lowers migration friction through portable modes and sharable customization | Mature repos do not want to rewrite existing rule investments to trial Bubbles | Interop registry, review-only intake, and apply-reviewable project-owned outputs provide a migration wedge without creating a second mode system | Imported content never mutates framework-managed downstream files |
| Cursor has a clearer front door and lighter first-run experience | First-time adopters bounce before they experience Bubbles' control-plane value | Foundation-profile onboarding plus profile-aware doctor and repo-readiness sequencing reduce first-run drag without changing delivery rigor | Completion gates and scenario contracts remain identical across profiles |
| Cline wins on simplicity and low-friction coexistence | Teams want to start with their current rule surfaces and grow into stricter governance later | Detect-only and review-only interop plus migration guidance let teams coexist and progress incrementally instead of forcing greenfield adoption | Ownership boundaries and project-agnostic command indirection stay intact |

## Architecture

### System Shape

The target architecture keeps the existing source/downstream split and adds parity-focused registries plus reviewable import outputs.

| Layer | Surface | Ownership | Responsibility |
|------|---------|-----------|----------------|
| Source framework | `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/*.sh`, `bubbles/*.yaml` | Bubbles framework | Install, validate, release, import orchestration, registry resolution |
| Source published docs | `README.md`, `docs/guides/*`, `docs/recipes/*`, `CHANGELOG.md`, `docs/issues/*` | Bubbles framework | Evaluation guidance, onboarding guidance, trust explanation, competitive positioning |
| Downstream installed framework layer | `.github/bubbles/**`, `.github/agents/bubbles*`, `.github/prompts/bubbles*` | Bubbles framework | Immutable installed framework runtime |
| Downstream project policy layer | `.github/copilot-instructions.md`, `.specify/memory/agents.md`, `.specify/memory/constitution.md`, `.github/bubbles-project.yaml` | Downstream project | Project-specific commands, governance, doc overrides, custom scan patterns, interop preferences |
| Downstream interop intake layer | `.github/bubbles-project/imports/**`, `.github/bubbles-project/proposals/**` | Downstream project | Reviewable imported source snapshots, normalized manifests, migration reports, upstream proposals |

### Primary Flows

#### 1. Bootstrap And Onboarding Flow

1. Maintainer runs `install.sh --bootstrap`.
2. Installer selects an adoption profile or uses the default profile.
3. Bootstrap writes the same framework-managed assets as today plus profile-aware next-step guidance.
4. `doctor`, `repo-readiness`, and `bubbles.setup mode: refresh` present findings using the active profile's severity and sequencing.
5. Maintainer customizes only project-owned artifacts.

The profile changes how onboarding is explained and prioritized, not which completion gates apply later.

#### 2. Interoperability Intake Flow

1. Maintainer runs a new interop command against an external tool source.
2. Bubbles detects the external format using a framework-owned interop registry.
3. The raw external assets are snapshotted into a project-owned import folder.
4. Bubbles normalizes the assets into a Bubbles-neutral rule model.
5. Bubbles generates a reviewable translation report plus optional project-owned outputs.
6. Unsupported or framework-level translation needs become upstream proposals instead of local framework edits.

#### 3. Source-To-Downstream Trust Flow

1. Source repo release work runs `framework-validate` and `release-check`, which validate release-manifest generation plus the trust selftests from the source repo.
2. Release tooling generates a machine-readable release manifest from verified source truth.
3. `install.sh` copies that manifest into the downstream framework layer, writes `.github/bubbles/.install-source.json`, and regenerates downstream `.manifest` plus `.checksums` from the installed snapshot.
4. `doctor`, `framework-write-guard`, and `upgrade --dry-run` combine the installed release manifest, `.install-source.json`, and downstream `.checksums` snapshot to explain what is installed, where it came from, and whether managed files still match the installed snapshot.
5. `repo-readiness` remains advisory and separate from that trust statement.

#### 4. Public Evaluation Flow

1. Source repo capability claims are recorded in one framework-owned capability ledger.
2. Competitive docs, benchmark tables, and issue status pages consume that ledger.
3. `framework-validate` fails if capability claims, docs, issues, or source surfaces drift.
4. Evaluators see one current truth instead of mismatched docs and issue narratives.

### Framework-Owned Vs Project-Owned Override Rules

The following boundary is central to the design.

#### Framework-Owned

- install and bootstrap schemas
- CLI command surfaces and their source-repo implementations
- interoperability source registry and translation rules
- adoption profile definitions
- capability ledger, release manifest generation, and competitive docs generation
- downstream installed framework files under `.github/bubbles/**`, `.github/agents/bubbles*`, `.github/prompts/bubbles*`

#### Project-Owned

- selected project policy values and command mappings
- `.github/bubbles-project.yaml` profile or interop preferences when allowed by the schema
- imported-source snapshots and normalized migration reports
- repo-local override docs and additional project-specific instructions or skills
- upstream framework change proposals under `.github/bubbles-project/proposals/**`

This split prevents parity work from becoming a loophole for downstream framework mutation.

## Data Model

### New Framework-Owned Registries

#### 1. `bubbles/adoption-profiles.yaml`

Purpose: define named onboarding and governance posture profiles.

Profiles:

- `foundation` — externally presented as the Bubbles Lite onboarding path
- `delivery` — current full Bubbles default
- `assured` — higher-assurance default posture for teams that want stronger early guardrails

Required fields:

- `id`
- `label`
- `description`
- `intendedAudience`
- `bootstrapDefaults`
- `doctorSections`
- `repoReadinessSeverityMap`
- `policyDefaults`
- `requiredDocs`
- `recommendedNextCommands`
- `governanceInvariant: full-certification`

Important rule: every profile keeps validate-owned certification, artifact ownership, and scenario-contract requirements intact. Profiles change guidance, defaults, and advisory presentation only.

#### 2. `bubbles/interop-registry.yaml`

Purpose: define supported external ecosystems and how Bubbles detects and translates them.

Initial source IDs:

- `claude-code`
- `roo-code`
- `cursor`
- `cline`

Required fields:

- `sourceId`
- `displayName`
- `detectors` — file paths and patterns
- `parserKind`
- `normalizedClasses` — instruction, command-surface, workflow-mode, guardrail, tool-request, docs-reference
- `supportedTargets`
- `unsupportedTargets`
- `reviewRequired: true`
- `proposalWhenFrameworkChangeRequired: true`

The registry lets Bubbles add support for new ecosystems without spreading parser logic through docs and prompt prose.

#### 3. `bubbles/capability-ledger.yaml`

Purpose: become the single source of truth for shipped capability claims, competitor mapping, and issue freshness.

Required fields per capability:

- `capabilityId`
- `label`
- `state` — `shipped`, `beta`, `proposed`, `deprecated`, or `superseded`
- `ownerSurface` — source repo file or command family
- `docsRefs`
- `evidenceRefs`
- `competitorTags` — Claude Code, Roo Code, Cursor, Cline, or generic categories
- `releaseIntroduced`
- `issueRefs`
- `freshnessCheck` — what must remain in sync

This ledger feeds generated comparison tables, capability pages, and release-check freshness validation.

### Generated Framework Metadata

#### 4. `bubbles/release-manifest.json`

Purpose: package release trust metadata for downstream installs and upgrades.

Required fields:

- `version`
- `gitSha`
- `generatedAt`
- `managedFileChecksums`
- `supportedProfiles`
- `supportedInteropSources`
- `capabilityLedgerVersion`
- `validatedSurfaces` — commands and selftests executed before release
- `docsDigest`

This file is generated in the source repo during release hygiene and copied into the downstream installed framework layer.

The copied release manifest complements rather than replaces downstream `.manifest` and `.checksums`; those installed files remain the snapshot authority used by `framework-write-guard`.

### Downstream Metadata And Intake Surfaces

#### 5. `.github/bubbles/.install-source.json`

Purpose: record how the downstream repo received the installed framework snapshot.

Required fields:

- `installedVersion`
- `installMode` — `remote-ref` or `local-source`
- `sourceRef`
- `sourceGitSha`
- `sourceDirty`
- `installedAt`

This explicitly surfaces the existing local-source dirty-tree risk instead of leaving it implicit.

For local-source installs, `sourceRef` must be a symbolic ref label or the literal `local-source`; absolute checkout paths must not be persisted.

#### 6. `.github/bubbles-project/imports/interop-manifest.json`

Purpose: track imported external assets at the project-owned layer.

Required fields:

- `version`
- `imports[]`
- `sourceId`
- `sourceFiles`
- `normalizedOutput`
- `generatedTargets`
- `unsupportedItems`
- `proposalRefs`
- `reviewStatus`

#### 7. `.github/bubbles-project/imports/<source>/<timestamp>/`

Purpose: retain reviewable intake material.

Expected contents:

- `raw/` — original imported files
- `normalized.json` — normalized Bubbles-neutral representation
- `translation-report.md` — human review report
- `proposed-overrides/` — candidate project-owned outputs, never framework-managed files

### Existing Schema Extensions

#### `.specify/memory/bubbles.config.json`

Add an `adoptionProfile` field to the policy registry so profile selection becomes repo-local state instead of installer-only behavior.

#### `.github/bubbles-project.yaml`

Add an optional `interop` section for project-owned preferences only, such as:

- enabled external sources
- preferred target output paths for imported instructions or skills
- conflict policy: `review-required` only in the initial release

This file must not become a place to override framework-managed registries. It remains a project-owned extension layer.

## API And CLI Contracts

This feature is primarily CLI- and file-surface-based, not network-API-based.

### Installer Surface

#### `install.sh --bootstrap --profile <foundation|delivery|assured>`

Behavior:

- installs the same framework-managed bundle as today
- writes or refreshes bootstrap artifacts as today
- stores the selected profile in the bootstrap policy registry
- emits profile-aware next-step guidance
- never overwrites project-owned files that already exist

If no profile is provided, the default remains `delivery` to preserve current behavior.

### CLI Extensions

#### `bubbles policy profile`

Subcommands:

- `status`
- `set <profile>`
- `reset`

Purpose: change the active adoption profile after bootstrap without hand-editing config.

#### `bubbles interop detect [path]`

Purpose: detect external rule or mode sources without generating any outputs.

Output:

- detected source IDs
- matched files
- supported translation classes
- unsupported classes that would require manual mapping or proposal creation

#### `bubbles interop import <source> [path] [--dry-run]`

Purpose: generate a project-owned import packet for an external ecosystem.

Rules:

- `--dry-run` prints the planned intake and target paths only
- non-dry-run writes to `.github/bubbles-project/imports/**` and other project-owned override paths only
- unsupported items produce proposal refs instead of framework mutations

#### `bubbles interop status`

Purpose: show unresolved imports, review status, and proposal dependencies.

#### `bubbles doctor`

Enhancement: split output into three clearly labeled sections:

- `Framework Integrity`
- `Adoption Profile Progress`
- `Project Readiness Advisory`

This makes the distinction between framework trust and repo-readiness explicit at the main health surface.

#### `bubbles repo-readiness [path] [--profile X]`

Enhancement: findings are classified according to the active or requested profile so the user sees what blocks the next stage versus what is advisory later.

This command remains advisory. It does not certify completion and it does not mutate `state.json` certification fields.

#### `bubbles upgrade [version] [--dry-run]`

Enhancement: show a trust diff using the current installed release manifest versus the target release manifest.

The dry-run path must resolve the target manifest from the requested upstream ref or local source checkout before printing the diff.

The dry-run output must distinguish:

- framework-managed files that will be replaced
- project-owned files that will not be touched
- profile changes or new supported interop sources
- trust warnings, including dirty local-source provenance

### Existing Trust Commands With Expanded Responsibility

#### `framework-validate`

New responsibilities:

- verify capability ledger coherence with actual source surfaces
- verify docs issue pages do not contradict shipped capability state
- verify release-manifest schema plus trust selftests for manifest generation, downstream provenance fixtures, and doctor or upgrade trust output
- verify adoption profile registry schema
- verify interop registry schema and parser fixture coverage

`framework-validate` remains a source-repo validator. It does not read a downstream repo's `.install-source.json` directly outside fixture-based selftests.

#### `release-check`

New responsibilities:

- require generated `release-manifest.json`
- require capability-ledger freshness validation
- require trust selftests that exercise downstream provenance and doctor or upgrade trust fixtures
- require competitive docs and trust docs to be present and synchronized

## Interoperability And Migration Design

### Normalized Import Model

All imported external assets are normalized into one Bubbles-native model before any project-owned outputs are generated.

Normalized classes:

- `instruction`
- `workflow-hint`
- `mode-definition`
- `command-reference`
- `guardrail`
- `docs-reference`
- `tooling-request`

This prevents each external ecosystem from becoming a special case in every downstream command.

### Target Output Mapping

| Normalized Class | Preferred Output | Ownership |
|------------------|------------------|-----------|
| `instruction` | `.github/instructions/imported-*.instructions.md` or additive sections in existing project-owned instructions | Project-owned |
| `guardrail` | `.github/copilot-instructions.md` or `.specify/memory/constitution.md` proposals | Project-owned |
| `command-reference` | `.specify/memory/agents.md` recommendation block or migration report | Project-owned |
| `workflow-hint` / `mode-definition` | `translation-report.md` plus upstream proposal when a framework workflow change is required | Project-owned report + proposal |
| `tooling-request` | `.github/skills/<project-skill>/` proposal or `scripts/` recommendation | Project-owned |
| unsupported framework mutation | `.github/bubbles-project/proposals/<slug>.md` | Project-owned proposal |

No interop flow may write to framework-managed directories in a downstream repo.

### Apply Target Policy

Apply-reviewable output is allowed to generate direct candidate files only when the target path is unambiguously project-owned and declared in the import manifest.

Allowed direct candidate targets:

- `.github/instructions/imported-*.instructions.md`
- `.github/skills/<project-skill>/` where the skill namespace is project-owned and not `bubbles-*`
- additive recommendation blocks in `.specify/memory/agents.md`
- project-owned helper paths under `scripts/`

Required fallback behavior:

- if a target would collide with a framework-managed path, the output stays under `.github/bubbles-project/imports/**/proposed-overrides/`
- if a target would overwrite an existing project-owned file without a clean additive merge, Bubbles emits a proposal and translation report instead of applying automatically
- every apply result must be recorded in `.github/bubbles-project/imports/interop-manifest.json` with the exact generated targets

Forbidden targets:

- `.github/bubbles/**`
- `.github/agents/bubbles*`
- `.github/prompts/bubbles*`
- `.github/skills/bubbles-*`

### Import Modes

#### Detect-Only

- no files written
- used during evaluation or discovery

#### Reviewable Intake

- writes raw snapshots, normalized output, and translation report
- no project-owned runtime artifact is changed automatically

#### Apply-Reviewable

- generates reviewable project-owned outputs in explicit destinations
- still does not touch framework-managed files
- requires explicit user action or follow-up workflow to merge the outputs

This packet landed detect-only and reviewable intake first, then added supported apply-reviewable outputs for bounded project-owned targets once fixture coverage and conflict handling were proven. Unsupported or ambiguous targets remain review-only or proposal-driven.

### Conflict Handling

All initial interop flows use `review-required` conflict handling.

Conflicts include:

- imported rules contradicting current project-owned governance
- imported command references that do not map to the repo's command registry
- imported mode semantics that would require new framework workflow behavior
- imported assumptions that would weaken validate-owned certification or artifact ownership

Conflicts are reported in `translation-report.md` and optionally escalated into project-owned framework proposals.

## Security And Compliance

This feature introduces no relaxation of certification, validation, or immutability rules.

Required constraints:

- imported external rules may not bypass Bubbles gate enforcement
- profile changes may not disable validate-owned certification
- trust metadata may not be used as a substitute for validate certification
- source-provenance recording must not expose sensitive local filesystem details beyond what is needed for trust diagnostics
- framework-managed file replacement remains installer- and upgrade-only

The distinction between advisory and authoritative surfaces must stay visible:

- `repo-readiness` is advisory
- `doctor` is operational
- `framework-validate` is source-framework self-validation
- `framework-write-guard` is installed-layer integrity
- `bubbles.validate` remains the only certification authority for feature closeout

## Observability And Failure Handling

### Required Visibility

- installer output must show selected profile and provenance mode
- `doctor` must show framework integrity, profile progress, and advisory readiness as separate sections
- `interop import` must show every generated target path and every unsupported item
- `upgrade --dry-run` must show trust warnings before install
- `framework-validate` and `release-check` must fail loudly when docs or capability claims drift

### Failure Model

| Failure | Handling |
|--------|----------|
| Unknown external source format | Detect-only result with explicit unsupported classification |
| Imported asset requires framework mutation | Generate project-owned proposal; do not patch framework files |
| Dirty local-source install detected | Warn in doctor and upgrade diff; never present as a clean published release install |
| Capability ledger disagrees with docs or issue pages | Fail `framework-validate` and `release-check` |
| Profile value is invalid or missing | Fail fast and fall back to explicit user choice instead of implicit default mutation |

## Docs Surfaces

### Source-Repo Published Docs To Add Or Update

#### Update

- `README.md` — concise comparison story, profile-aware install entry, trust pipeline summary
- `docs/guides/INSTALLATION.md` — profile-aware bootstrap flow, onboarding sequencing, trust metadata explanation
- `docs/recipes/framework-ops.md` — trust and interop commands, advisory versus authoritative boundaries
- `docs/guides/CONTROL_PLANE_ADOPTION.md` — adoption profiles and incremental migration path
- `CHANGELOG.md` — shipped parity surfaces and release metadata changes

#### Add

- `docs/guides/ADOPTION_PROFILES.md` — what `foundation`, `delivery`, and `assured` mean
- `docs/guides/INTEROPERABILITY.md` — supported sources, import modes, ownership boundaries, conflict model
- `docs/guides/COMPETITIVE_POSITIONING.md` — concise comparison narrative generated from the capability ledger

### Issue And Freshness Hygiene

Issue pages under `docs/issues/*` should carry structured frontmatter or metadata fields tying each issue to a capability ID and current issue state. `framework-validate` uses that relationship to block stale public claims such as an issue page implying a missing capability that the ledger marks as shipped.

## Install And Bootstrap Impacts

### Foundation Profile As The "Bubbles Lite" Path

The competitive requirement for a lighter entry path is met through the `foundation` adoption profile.

Foundation profile characteristics:

- installs the full framework bundle, not a reduced fork
- keeps the same ownership and certification rules
- presents a smaller first-run command path and clearer prioritization
- classifies more findings as later-stage advisory work rather than first-run blockers
- emphasizes `workflow`, `super`, `setup refresh`, `commands`, `doctor`, and `repo-readiness`

This avoids the trap of creating a second governance model.

### Front-Door Presentation Rule

The published adoption story should recommend `foundation` as the evaluation and first-run path in README and installation guidance, while keeping `delivery` as the installer default during the initial rollout.

This split is intentional:

- evaluators and first-time adopters get the lighter path without needing to discover it themselves
- existing users keep current bootstrap behavior unless they opt into the new profile
- Scope 03 can prove the `foundation` posture in fresh downstream canaries before any future decision to change the installer default is considered

### Bootstrap Output Changes

Bootstrap should generate a profile-aware setup summary that clearly separates:

- required framework integrity items
- required project-owned customization items
- recommended next commands
- optional advanced configuration

Existing generated setup docs such as `CROSS_PROJECT_SETUP.md` and `SETUP_SOURCES.md` should become profile-aware rather than being replaced by new bootstrap artifacts.

## Rollout Strategy

### Phase 1: Truth And Freshness

Deliver:

- `capability-ledger.yaml`
- issue metadata model
- generated comparison/trust docs driven from the ledger
- `framework-validate` freshness checks

Why first: this improves public trust and reduces stale-doc risk without changing downstream install behavior.

### Phase 2: Trust Packaging

Deliver:

- `release-manifest.json`
- `.install-source.json`
- `doctor` and `upgrade --dry-run` trust diff enhancements
- `release-check` generation and verification

Why second: this strengthens source-to-downstream trust using existing install and write-guard primitives.

### Phase 3: Adoption Profiles

Deliver:

- `adoption-profiles.yaml`
- installer profile flag
- `bubbles policy profile` support
- profile-aware `doctor` and `repo-readiness`
- adoption profile docs

Why third: onboarding becomes clearer once truth and trust surfaces already exist.

### Phase 4: Interop Detect And Reviewable Intake

Deliver:

- `interop-registry.yaml`
- `bubbles interop detect`
- `bubbles interop import --dry-run`
- project-owned import manifest and translation report format

Why fourth: gives evaluation and migration value without yet risking broad project-owned mutations.

### Phase 5: Apply-Reviewable Interop

Deliver:

- project-owned generated output paths
- conflict-aware apply mode
- proposal generation for unsupported framework changes

Why fifth: only safe once the detect and review layers have reliable fixture coverage.

### Scope Alignment And Exit Rules

| Scope | Design Surface | Exit Condition In Design Terms | Competitor Outcome Unlocked |
|------|----------------|--------------------------------|-----------------------------|
| 01 | Capability ledger and freshness truth | One machine-checked truth source drives docs, issue state, and comparison claims without drift | Evaluators can trust Bubbles' public story instead of treating it as framework marketing |
| 02 | Release manifest and install provenance | Downstream installs can prove what was installed, from where, and whether local-source risk exists | Trust packaging becomes competitive with enterprise-facing alternatives |
| 03 | Foundation profile bootstrap | A new repo reaches a workable first-run state with profile-aware guidance and no ownership confusion | Bubbles closes the biggest onboarding-friction gap versus Cursor, Roo, and Cline |
| 04 | Maturity-tier profile model | Teams can move between guidance postures without any change to certification or scenario rigor | Bubbles gains progressive adoption without creating a weaker governance edition |
| 05 | Review-only interop intake | External rule investments can be analyzed and normalized entirely inside project-owned paths | Roo- and Cline-style migration pressure is answered without immutability drift |
| 06 | Supported apply plus migration guidance | Safe project-owned outputs and evaluator-facing migration docs tell a concrete parity story with bounded support states | Evaluators and maintainers see a credible migration path instead of a greenfield-only framework |

## Testing Strategy

### Validation Categories

| Area | Validation Type | Required Coverage |
|------|-----------------|-------------------|
| Capability ledger and docs freshness | Source-repo script selftests + doc generation tests | Every capability claim and linked issue/doc surface |
| Release trust packaging | Source-repo release-check integration tests | Manifest generation, digest stability, dirty-source warnings |
| Install/bootstrap profiles | Installer integration tests against temporary repos | All profiles, idempotent reruns, no project-owned overwrites |
| Doctor/readiness separation | CLI integration tests | Clear distinction between framework integrity and advisory readiness |
| Interop detection and normalization | Fixture-driven integration tests | Claude Code, Roo Code, Cursor, and Cline sample inputs |
| Interop apply boundaries | Integration tests | Writes only to project-owned paths; proposal routing for framework changes |

### Test Design Principles

- Use fixture repos or temp repos to validate install, upgrade, and import behavior.
- Preserve the current source-repo selftest pattern used by `framework-validate`, `guard-selftest`, `runtime-selftest`, and workflow surface selftests.
- Add explicit canary tests for shared installer and CLI surfaces before broader source-repo validation reruns.
- Treat `install.sh`, `bubbles/scripts/cli.sh`, `framework-validate.sh`, `release-check.sh`, and import scripts as high-fan-out shared infrastructure for planning and validation purposes.

### Scenario Mapping

- **BS-001 / UC-001** maps to capability-ledger-driven docs, competitive positioning docs, and freshness validation.
- **BS-002 / UC-002** maps to profile-aware bootstrap, doctor, and repo-readiness behavior.
- **BS-003 / UC-003** maps to interop detect, import, normalization, and proposal routing.
- **BS-004 / UC-004** maps to release manifest generation, install provenance recording, write guard, and upgrade diff output.
- **BS-005 / UC-005** maps to capability-ledger and issue freshness cross-checks.
- **BS-006 / UC-006** maps to trust manifest plus immutable framework-managed upgrade flow.

## Alternatives Considered

### 1. Separate "Lite" Distribution

Rejected because it would create a second framework contract, fragment docs, and invite pressure to weaken gates for adoption.

### 2. Direct Import Into Framework-Managed Downstream Files

Rejected because it violates upstream-first immutability and would make imported compatibility content vulnerable to silent overwrite on upgrade.

### 3. Docs-Only Competitive Positioning

Rejected because the current problem is not lack of prose. It is lack of machine-checked freshness and traceable trust packaging.

### 4. Replacing Existing Trust Surfaces With One New Command

Rejected because Bubbles already has the correct trust primitives. The gap is coherence and packaging, not command count.

## Planning Constraints For `bubbles.plan`

- Any scope touching `install.sh`, `bubbles/scripts/cli.sh`, `framework-validate.sh`, `release-check.sh`, or generated docs surfaces must be treated as shared infrastructure and must include canary coverage plus rollback planning.
- Adoption profile scopes must preserve identical completion gates across profiles; they may change defaults and advisory severity only.
- Interop scopes must maintain an explicit change boundary that limits writes to project-owned import, proposal, and override surfaces.
- Capability-ledger and docs-freshness scopes must make registry data the source of truth; hand-maintained duplicate matrices are not acceptable.
- Trust packaging scopes must keep `repo-readiness` advisory and must not move certification authority out of `bubbles.validate`.

## Risks And Open Questions

### Risks

- External ecosystem formats may drift faster than Bubbles can maintain import fidelity. The interop registry and fixture corpus mitigate this, but support should be explicit and versioned.
- Adoption profile naming could be misunderstood as a governance downgrade. Public docs must explain that profiles tune onboarding posture, not completion rigor.
- Capability-ledger freshness checks will add release discipline overhead. That is intentional, but the ledger schema must stay narrow enough to be maintainable.
- Install provenance warnings about dirty local-source installs could surprise current power users. The design should warn clearly without blocking legitimate local-source testing workflows.

### Open Questions

- Should the first competitive-positioning release include benchmark-style timing or setup-count metrics, or only capability and workflow comparisons?
- Which external ecosystems should get apply-reviewable support in the first interop apply release versus detect-only support?
- Should profile selection also be surfaced through `bubbles setup`, or remain limited to bootstrap and `bubbles policy` during the first rollout?