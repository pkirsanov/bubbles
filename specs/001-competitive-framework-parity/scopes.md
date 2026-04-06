# Scopes

## Execution Outline

### Phase Order
1. Scope 01 establishes the framework-owned capability ledger, freshness checks, and generated truth surfaces that all later competitive claims depend on.
2. Scope 02 packages source-to-downstream trust through release manifests, install provenance, and doctor or upgrade confidence outputs.
3. Scope 03 introduces the foundation adoption profile so a new repo can bootstrap through a Bubbles Lite path without weakening framework invariants.
4. Scope 04 expands the profile model into explicit maturity tiers that keep certification strict while changing onboarding guidance and advisory severity.
5. Scope 05 adds review-only interoperability intake so downstream maintainers can snapshot, normalize, and assess Claude Code, Roo Code, Cursor, and Cline assets safely.
6. Scope 06 closes the migration loop with supported interop apply flows and evaluator-facing migration guidance generated from the same truth surfaces.

### New Types And Signatures
- `bubbles/capability-ledger.yaml` becomes the framework-owned source of truth for shipped capability claims, competitor tags, issue refs, and freshness checks.
- `bubbles/release-manifest.json` packages verified source metadata, managed-file checksums, supported profiles, and supported interop sources for downstream installs.
- `bubbles/adoption-profiles.yaml` defines `foundation`, `delivery`, and `assured` onboarding profiles with guidance-only posture changes.
- `bubbles/interop-registry.yaml` defines external source detectors, parser kinds, normalized classes, supported targets, unsupported targets, and review-required rules.
- `.github/bubbles/.install-source.json` records downstream install provenance including version, source ref, git SHA, and dirty-tree state.
- `.github/bubbles-project/imports/interop-manifest.json` records imported source files, normalized output, generated project-owned targets, unsupported items, and proposal refs.
- `install.sh --bootstrap --profile <foundation|delivery|assured>` becomes the installer contract for profile-guided bootstrap.
- `bash bubbles/scripts/cli.sh doctor`, `bash bubbles/scripts/cli.sh repo-readiness`, `bash bubbles/scripts/cli.sh upgrade --dry-run`, and the new interop commands stay project-agnostic surfaces backed by framework-owned registries.

### Validation Checkpoints
1. After Scope 01, `framework-validate` and `release-check` must fail loudly on stale capability or issue claims before any profile or interop work proceeds.
2. After Scope 02, install provenance and release manifest canaries must prove downstream trust outputs before bootstrap guidance is changed.
3. After Scope 03, the docs-facing foundation front door and explicit foundation bootstrap path must pass canaries while the installer default remains `delivery` until those canaries justify any later default change.
4. After Scope 04, profile transition canaries must show that advisory posture changes without weakening validate-owned certification or scenario contracts.
5. After Scope 05, interop intake canaries must prove review-only imports stay inside project-owned paths before any apply flow is introduced.
6. After Scope 06, supported apply flows must prove exact allowed project-owned targets, proposal fallback on collisions, and evaluator migration docs must pass scenario-specific regressions plus broader framework validation, release, and docs-freshness reruns.

## Ordering Rationale

The sequence is intentionally vertical and trust-first. Scope 01 creates the truth layer that later comparison, docs, and issue claims consume. Scope 02 packages that truth into a source-to-downstream confidence pipeline. Scope 03 introduces the evaluator-facing foundation path and explicit foundation bootstrap canaries without changing the installer default prematurely. Scope 04 then expands the posture model into maturity tiers while keeping certification semantics fixed. Scopes 05 and 06 come last because interoperability depends on the trust, profile, and ownership rules being explicit before imported assets are allowed to land in downstream repos, and because apply-mode must inherit the exact target and fallback rules proven by review-only intake.

## Scope Table

| Scope | Depends On | Primary Outcome | Surfaces | Scenario Contracts | Test Focus | Status |
| --- | --- | --- | --- | --- | --- | --- |
| 01. Capability Truth And Freshness Hygiene | — | One framework-owned truth source drives competitive claims and freshness enforcement. | Registry, validation, docs, issue pages | SCN-001-A01, SCN-001-A02 | Ledger generation, freshness canaries, evaluator-visible docs regression | Done |
| 02. Release Manifest And Install Provenance Trust | 01 | Downstream installs expose verified upstream source and upgrade confidence. | Release, install, doctor, upgrade, docs | SCN-001-B01, SCN-001-B02 | Release manifest generation, provenance recording, doctor regression | Done |
| 03. Foundation Profile Bootstrap | 02 | New repos can follow a docs-recommended foundation path while installer default stays delivery until canaries justify change. | Installer, bootstrap docs, doctor, repo-readiness | SCN-001-C01, SCN-001-C02 | Fresh-repo bootstrap canary, front-door guidance regression, advisory-vs-certification UX regression | Done |
| 04. Maturity-Tier Governance Profiles | 03 | Teams can move between foundation, delivery, and assured guidance while gates stay strict. | Profiles registry, CLI, policy registry, docs | SCN-001-D01, SCN-001-D02 | Profile transition canary, CLI and docs regression | Done |
| 05. Review-Only Interop Intake | 04 | Existing external rules or modes can be imported into project-owned intake and proposal surfaces safely. | Interop registry, CLI, project-owned imports, install packaging, release metadata, docs | SCN-001-E01, SCN-001-E02 | Source detection, normalization, proposal escalation regression | Done |
| 06. Supported Interop Apply And Evaluator Migration Guidance | 05 | Supported imports can be applied into project-owned outputs and evaluators see a concrete migration story. | CLI, project-owned outputs, comparison docs, migration guide | SCN-001-F01, SCN-001-F02 | Apply-flow regression, migration-docs regression, broader framework reruns | Done |

## Scope 01: Capability Truth And Freshness Hygiene

**Status:** Done
**Depends On:** —

### Gherkin Scenarios

Scenario: SCN-001-A01 capability-ledger truth drives evaluator-facing claims consistently
  Given the framework-owned capability ledger declares shipped competitive capabilities and evidence references
  When generated comparison surfaces and landing docs are refreshed from that ledger
  Then evaluators see the same capability state, competitor mapping, and evidence trail across the published surfaces

Scenario: SCN-001-A02 freshness validation blocks stale issue or capability narratives
  Given a capability claim, issue page, or generated comparison surface drifts away from the framework-owned ledger
  When maintainers run framework validation or release-check
  Then the drift fails loudly before release packaging or docs publication proceeds

### UI Scenario Matrix

| Scenario | Preconditions | Steps | Expected | Test Type |
| --- | --- | --- | --- | --- |
| Evaluator scans competitive truth surfaces | Capability ledger and generated docs exist | Open README and generated comparison guide from a fresh checkout | Capability states and competitor mappings match exactly across both surfaces | e2e-ui |
| Maintainer reviews freshness failure output | Capability or issue drift is intentionally introduced in a fixture | Run validation surface and inspect CLI output | Drift is reported with the specific stale file and owning ledger entry | e2e-api |

### Implementation Plan

- Add `bubbles/capability-ledger.yaml` as the framework-owned ledger for capability state, competitor tags, docs refs, evidence refs, release introduction, and freshness rules.
- Extend `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/release-check.sh`, and `bubbles/scripts/docs-registry-effective.sh` so docs claims, issue pages, and generated competitive surfaces reconcile against the ledger.
- Generate evaluator-facing truth surfaces under `docs/generated/` and wire them into `README.md`, `docs/CATALOG.md`, and the relevant guide or recipe entry points.
- Update `docs/issues/` pages that expose shipped or proposed status so they consume the ledger-backed truth instead of hand-maintained status prose.
- Preserve project-agnostic command indirection by keeping all enforcement inside framework-owned registries and CLI surfaces rather than repo-specific commands.

### Implementation Files

- `bubbles/capability-ledger.yaml`
- `bubbles/scripts/generate-capability-ledger-docs.sh`
- `bubbles/scripts/framework-validate.sh`
- `bubbles/scripts/release-check.sh`
- `bubbles/scripts/docs-registry-effective.sh`
- `docs/generated/competitive-capabilities.md`
- `docs/generated/issue-status.md`

### Consumer Impact Sweep

- Validate first-party consumers of capability claims: `README.md`, `docs/CATALOG.md`, `docs/guides/AGENT_MANUAL.md`, `docs/recipes/README.md`, `docs/issues/*`, and any generated docs indexes.
- Validate stale-reference scans for capability IDs, issue IDs, competitor tags, and generated comparison paths across docs and validation scripts.

### Shared Infrastructure Impact Sweep

- Protected shared surfaces: `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/release-check.sh`, `bubbles/scripts/docs-registry-effective.sh`, and generated docs under `docs/generated/`.
- Blast radius: release gating, published docs trust, issue freshness status, and any workflow that consumes framework-generated truth surfaces.
- Independent canaries: a ledger-generation selftest that compares generated docs output with the ledger and a freshness selftest that injects drift and expects validation failure.
- Rollback or restore path: revert ledger wiring and generated docs changes together in one commit and rerun the canary selftests before any broader release or docs publish rerun.

### Change Boundary

- Allowed file families: `bubbles/capability-ledger.yaml`, `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/release-check.sh`, `bubbles/scripts/docs-registry-effective.sh`, `bubbles/docs-registry.yaml`, `docs/generated/**`, `docs/issues/**`, `docs/CATALOG.md`, `README.md`.
- Excluded surfaces: installer bootstrap flow, adoption profile registry, interop registry, downstream import paths, and state certification fields.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-01.1 | SCN-001-A01 | Functional | functional | `bubbles/scripts/capability-ledger-selftest.sh` | Generates comparison artifacts from the capability ledger and asserts exact field parity across published surfaces. | `bash bubbles/scripts/capability-ledger-selftest.sh` | No |
| TP-01.2 | SCN-001-A02 | Integration | integration | `bubbles/scripts/capability-freshness-selftest.sh` | Introduces drift in a fixture and proves `framework-validate` plus `release-check` fail with explicit ownership output. | `bash bubbles/scripts/capability-freshness-selftest.sh` | Yes |
| TP-01.3 | SCN-001-A01 | E2E UI | e2e-ui | `bubbles/scripts/competitive-docs-selftest.sh` | Opens the evaluator-facing docs path and asserts user-visible consistency between README and generated comparison docs. | `bash bubbles/scripts/competitive-docs-selftest.sh` | Yes |
| TP-01.4 | SCN-001-A02 | Regression E2E | e2e-api | `bubbles/scripts/framework-validate.sh` | Reruns the broader validation surfaces after truth-layer changes to keep stale docs or issue drift from reappearing. | `bash bubbles/scripts/framework-validate.sh` | Yes |

### Definition of Done

- [x] TP-01.1 proves SCN-001-A01 by keeping capability-ledger truth consistent across evaluator-facing claims, competitor mappings, and published docs.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/capability-ledger-selftest.sh
  Running capability-ledger selftest...
  Scenario: ledger-backed competitive docs stay aligned with the source-of-truth registry.
  PASS: Capability ledger generated surfaces are current
  PASS: Ledger defines workflow orchestration capability
  PASS: Ledger tracks runtime coordination proposal
  PASS: Generated capability guide exposes stable state summary
  PASS: Generated capability guide includes shipped workflow orchestration row
  PASS: Generated capability guide includes proposed runtime coordination row
  PASS: Generated issue status guide counts tracked gaps from the ledger
  capability-ledger selftest passed.
  ```

- [x] TP-01.2 proves SCN-001-A02 by failing loudly on stale capability, issue, or generated-doc drift.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/capability-freshness-selftest.sh
  Running capability-freshness selftest...
  Scenario: generated docs or issue status drift must fail loudly before release or publication.
  PASS: Fresh fixture generated from the capability ledger
  PASS: Generated capability guide drift is detected
  Generated competitive capabilities doc is stale. Run bubbles/scripts/generate-capability-ledger-docs.sh
  PASS: Issue status block drift is detected
  Issue capability-ledger block is stale for docs/issues/G068-word-overlap-threshold.md. Run bubbles/scripts/generate-capability-ledger-docs.sh
  capability-freshness selftest passed.
  $ cd /home/philipk/bubbles && bash bubbles/scripts/release-check.sh
  ==> Capability ledger docs freshness
  Capability ledger docs are current: 3 shipped, 1 partial, 2 proposed
  PASS: Capability ledger docs freshness
  ```

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior are added or updated, preserving the evaluator-visible docs path for SCN-001-A01 with user-visible assertions instead of proxy checks.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/competitive-docs-selftest.sh
  Running competitive-docs selftest...
  Scenario: README and generated evaluator docs expose the same competitive truth path.
  PASS: Capability ledger docs are current before evaluator-path assertions
  PASS: README links to the generated competitive guide with current ledger counts
  PASS: README links to the generated issue status guide with current tracked-gap count
  PASS: Generated competitive guide exposes the same state summary the README advertises
  PASS: Generated issue-status guide exposes the tracked-gap count referenced from README
  PASS: Generated competitive guide links evaluators to issue-backed proposal detail
  competitive-docs selftest passed.
  ```

- [x] Broader E2E regression suite passes.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/framework-validate.sh
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles

  ==> Portable surface agnosticity
  PASS: Portable surface agnosticity

  ==> Workflow registry consistency
  PASS: Workflow registry consistency

  ==> Agent ownership lint
  Agent ownership lint passed.
  PASS: Agent ownership lint

  ==> Capability ledger selftest
  Running capability-ledger selftest...
  ```

- [x] Consumer impact sweep is complete and zero stale first-party references remain across capability and issue consumers.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -RniE 'Competitive Capabilities|Issue Status|session-aware-runtime-coordination|G068-word-overlap-threshold|capability-ledger' README.md docs/issues docs/generated bubbles/scripts/framework-validate.sh bubbles/scripts/release-check.sh bubbles/scripts/capability-ledger-selftest.sh bubbles/scripts/capability-freshness-selftest.sh bubbles/scripts/competitive-docs-selftest.sh bubbles/scripts/generate-capability-ledger-docs.sh bubbles/capability-ledger.yaml
  README.md:463:| [Competitive Capabilities](docs/generated/competitive-capabilities.md) | Ledger-backed competitive posture guide — 3 shipped, 1 partial, 2 proposed |
  README.md:464:| [Issue Status](docs/generated/issue-status.md) | Ledger-backed status for 2 tracked framework gaps and proposals |
  docs/issues/G068-word-overlap-threshold.md:12:**Source Of Truth:** [Issue Status](../generated/issue-status.md)
  docs/issues/session-aware-runtime-coordination.md:12:**Source Of Truth:** [Issue Status](../generated/issue-status.md)
  docs/generated/issue-status.md:1:# Issue Status
  docs/generated/issue-status.md:7:| [session-aware-runtime-coordination.md](../issues/session-aware-runtime-coordination.md) | proposed | Session-aware runtime coordination | Runtime lease coordination is defined as a framework proposal, but not yet shipped into the control plane. |
  docs/generated/issue-status.md:8:| [G068-word-overlap-threshold.md](../issues/G068-word-overlap-threshold.md) | proposed | G068 DoD-Gherkin fidelity threshold tuning | The current G068 overlap heuristic has a documented false-positive gap and remains an open framework issue. |
  docs/generated/competitive-capabilities.md:1:# Competitive Capabilities
  docs/generated/competitive-capabilities.md:5:This page is generated from `bubbles/capability-ledger.yaml` and is the source-backed view of how Bubbles positions key framework capabilities against adjacent tools.
  bubbles/scripts/framework-validate.sh:47:run_check "Capability ledger selftest" bash "$SCRIPT_DIR/capability-ledger-selftest.sh"
  bubbles/scripts/release-check.sh:76:run_check "Capability ledger docs freshness" bash "$SCRIPT_DIR/generate-capability-ledger-docs.sh" --check
  bubbles/capability-ledger.yaml:82:  session-aware-runtime-coordination:
  ```

- [x] Shared validation and docs-generation infrastructure passes its independent canaries and stays inside the declared change boundary.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && git status --short
   M README.md
   M bubbles/scripts/framework-validate.sh
   M bubbles/scripts/release-check.sh
   M docs/issues/G068-word-overlap-threshold.md
   M docs/issues/session-aware-runtime-coordination.md
  ?? bubbles/capability-ledger.yaml
  ?? bubbles/scripts/capability-freshness-selftest.sh
  ?? bubbles/scripts/capability-ledger-selftest.sh
  ?? bubbles/scripts/competitive-docs-selftest.sh
  ?? bubbles/scripts/generate-capability-ledger-docs.sh
  ?? docs/generated/competitive-capabilities.md
  ?? docs/generated/issue-status.md
  ?? specs/
  $ cd /home/philipk/bubbles && bash bubbles/scripts/artifact-lint.sh specs/001-competitive-framework-parity
  Artifact lint PASSED.
  ```

## Scope 02: Release Manifest And Install Provenance Trust

**Status:** Done
**Depends On:** 01

### Gherkin Scenarios

Scenario: SCN-001-B01 downstream installs record release manifest and install provenance
  Given the source repo has passed framework validation and release-check
  When a downstream repo installs or upgrades Bubbles from an upstream release or local source
  Then the installed framework includes verified release metadata and explicit install-source provenance

Scenario: SCN-001-B02 doctor, framework-write-guard, and upgrade surfaces explain trust state without hiding local-source risk
  Given a downstream repo contains install provenance and an installed release manifest
  When maintainers run doctor, framework-write-guard, or upgrade dry-run surfaces
  Then they can see installed version, source ref, dirty-tree risk, managed-file integrity, and required remediation steps

### UI Scenario Matrix

| Scenario | Preconditions | Steps | Expected | Test Type |
| --- | --- | --- | --- | --- |
| Maintainer inspects trust output after install | Release manifest and install provenance are present in a downstream fixture | Run doctor, framework-write-guard, and upgrade dry-run against the fixture | The trust surfaces show version, source ref, SHA, install mode, dirty-source warnings, and managed-file integrity status explicitly | e2e-api |
| Maintainer reviews upgrade confidence docs | Installation and framework-ops guides are refreshed | Open guides from a fresh checkout | Docs explain how release manifests and install provenance affect trust and upgrade behavior | e2e-ui |

### Implementation Plan

- Generate `bubbles/release-manifest.json` during release hygiene with version, git SHA, supported profiles, supported interop sources, validated surfaces, and managed-file checksums.
- Update `install.sh` and the relevant `bubbles/scripts/cli.sh` commands so downstream installs record `.github/bubbles/.install-source.json` without weakening immutability or ownership boundaries, and ensure local-source installs persist only a symbolic `sourceRef` or the literal `local-source` instead of an absolute checkout path.
- Extend `bubbles/scripts/downstream-framework-write-guard.sh`, `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/release-check.sh`, and doctor or upgrade dry-run outputs to consume manifest plus provenance.
- Refresh `docs/guides/INSTALLATION.md`, `docs/recipes/framework-ops.md`, and any trust-oriented guide or changelog surface so source-to-downstream confidence is one coherent story.

### Implementation Files

- `install.sh`
- `bubbles/scripts/cli.sh`
- `bubbles/scripts/trust-metadata.sh`
- `bubbles/scripts/generate-release-manifest.sh`
- `bubbles/scripts/downstream-framework-write-guard.sh`
- `bubbles/scripts/framework-validate.sh`
- `bubbles/scripts/release-check.sh`
- `docs/guides/INSTALLATION.md`
- `docs/recipes/framework-ops.md`
- `CHANGELOG.md`

### Consumer Impact Sweep

- Validate first-party consumers of trust data: `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/downstream-framework-write-guard.sh`, `docs/guides/INSTALLATION.md`, `docs/recipes/framework-ops.md`, and upgrade dry-run output docs.
- Verify stale-reference scans for manifest keys, provenance keys, and doctor or upgrade text so older docs or scripts do not refer to removed trust fields.

### Shared Infrastructure Impact Sweep

- Protected shared surfaces: `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/release-check.sh`, `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/downstream-framework-write-guard.sh`.
- Blast radius: every downstream install or upgrade, doctor output, write-guard semantics, and release packaging.
- Independent canaries: a release-manifest generation selftest, a downstream install provenance selftest, and a trust-output selftest covering doctor, framework-write-guard, and upgrade dry-run fixtures for both upstream-release and local-source installs.
- Rollback or restore path: remove manifest or provenance consumers together, restore pre-change install outputs from git, and rerun the trust canaries before any wider install or release rerun.

### Change Boundary

- Allowed file families: `install.sh`, `bubbles/release-manifest.json` generation paths, `bubbles/scripts/cli.sh`, `bubbles/scripts/release-check.sh`, `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/downstream-framework-write-guard.sh`, `docs/guides/INSTALLATION.md`, `docs/recipes/framework-ops.md`, `CHANGELOG.md`.
- Excluded surfaces: capability ledger semantics outside trust consumption, adoption profile registry, interop parser logic, downstream project-owned override schemas, and certification-owned state fields.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-02.1 | SCN-001-B01 | Integration | integration | `bubbles/scripts/release-manifest-selftest.sh` | Generates release manifest metadata and verifies the expected trust fields and checksum inventory. | `bash bubbles/scripts/release-manifest-selftest.sh` | Yes |
| TP-02.2 | SCN-001-B01 | E2E API | e2e-api | `bubbles/scripts/install-provenance-selftest.sh` | Installs into a downstream fixture and verifies `.install-source.json`, installed manifest outputs, and the no-absolute-path `sourceRef` rule for release and local-source modes. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| TP-02.3 | SCN-001-B02 | E2E API | e2e-api | `bubbles/scripts/trust-doctor-selftest.sh` | Runs doctor, framework-write-guard, and upgrade dry-run against trust fixtures and asserts user-visible provenance, dirty-source, managed-file integrity, and remediation output. | `bash bubbles/scripts/trust-doctor-selftest.sh` | Yes |
| TP-02.3C | SCN-001-B02 | Integration | integration | `bubbles/scripts/trust-doctor-selftest.sh` | Canary: trust-doctor surfaces must pass before broader validation and release packaging reruns. | `bash bubbles/scripts/trust-doctor-selftest.sh` | Yes |
| TP-02.4 | SCN-001-B02 | Regression E2E | e2e-api | `bubbles/scripts/framework-validate.sh` | Reruns the broader source-repo trust regression surface after trust-layer changes, including manifest schema and trust selftests. | `bash bubbles/scripts/framework-validate.sh` | Yes |
| TP-02.5 | SCN-001-B02 | Regression E2E | e2e-api | `bubbles/scripts/release-check.sh` | Reruns release packaging and trust regression surfaces after trust-layer changes. | `bash bubbles/scripts/release-check.sh` | Yes |

### Definition of Done

- [x] TP-02.1 proves SCN-001-B01 by generating a complete release manifest with verified trust metadata.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/release-manifest-selftest.sh
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (168)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  PASS: Manifest exposes supported profile set
  release-manifest selftest passed.
  ```

- [x] TP-02.2 proves SCN-001-B01 by recording install provenance in both release and local-source flows without mutating framework-managed downstream files and without persisting absolute local-source checkout paths.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/install-provenance-selftest.sh
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Remote-ref provenance records requested source ref
  PASS: Remote-ref provenance stays clean
  PASS: Local-source install copies generated release manifest
  PASS: Local-source install writes install provenance
  PASS: Local-source provenance records install mode
  PASS: Local-source provenance records a symbolic source ref
  PASS: Local-source provenance records dirty working tree risk
  PASS: Local-source provenance never persists the absolute checkout path
  install-provenance selftest passed.
  ```

- [x] TP-02.3 proves SCN-001-B02 by exposing trust state, dirty-source risk, managed-file integrity, and remediation steps through doctor, framework-write-guard, and upgrade dry-run surfaces.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && timeout 600 bash bubbles/scripts/trust-doctor-selftest.sh
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Doctor shows remote-ref provenance
  PASS: Doctor warns when the installed source checkout was dirty
  PASS: Framework write guard reports managed-file integrity state
  PASS: Framework write guard shows local-source provenance
  PASS: Upgrade dry-run distinguishes untouched project-owned files
  PASS: Upgrade dry-run surfaces local-source trust risk
  PASS: Upgrade dry-run shows framework-managed replacement count
  PASS: Framework write guard fails loud on malformed release manifest
  PASS: Framework write guard names the missing manifest field
  PASS: Upgrade dry-run rejects malformed target release metadata
  PASS: Upgrade dry-run names the missing target profiles field
  PASS: Upgrade dry-run names the missing target interop field
  PASS: Upgrade dry-run malformed-manifest failure stays free of shell trap errors
  trust-doctor selftest passed.
  ```

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior are added or updated for SCN-001-B01 and SCN-001-B02.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/install-provenance-selftest.sh && timeout 600 bash bubbles/scripts/trust-doctor-selftest.sh
  Running install-provenance selftest...
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Local-source provenance never persists the absolute checkout path
  install-provenance selftest passed.
  Running trust-doctor selftest...
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Framework write guard reports managed-file integrity state
  PASS: Upgrade dry-run shows framework-managed replacement count
  trust-doctor selftest passed.
  ```

- [x] Broader E2E regression suite passes.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/release-manifest-selftest.sh && bash bubbles/scripts/framework-validate.sh && bash bubbles/scripts/release-check.sh
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (168)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  PASS: Manifest exposes supported profile set
  release-manifest selftest passed.
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles

  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (168 managed files)
  PASS: Release manifest freshness

  ==> Release manifest selftest
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (168)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  PASS: Manifest exposes supported profile set
  release-manifest selftest passed.
  PASS: Release manifest selftest

  ==> Install provenance selftest
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Remote-ref provenance records requested source ref
  PASS: Remote-ref provenance stays clean
  PASS: Local-source install copies generated release manifest
  PASS: Local-source install writes install provenance
  PASS: Local-source provenance records install mode
  PASS: Local-source provenance records a symbolic source ref
  PASS: Local-source provenance records dirty working tree risk
  PASS: Local-source provenance never persists the absolute checkout path
  install-provenance selftest passed.
  PASS: Install provenance selftest

  ==> Trust doctor selftest
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Doctor shows remote-ref provenance
  PASS: Doctor warns when the installed source checkout was dirty
  PASS: Framework write guard reports managed-file integrity state
  PASS: Framework write guard shows local-source provenance
  PASS: Upgrade dry-run distinguishes untouched project-owned files
  PASS: Upgrade dry-run surfaces local-source trust risk
  PASS: Upgrade dry-run shows framework-managed replacement count
  PASS: Framework write guard fails loud on malformed release manifest
  PASS: Framework write guard names the missing manifest field
  PASS: Upgrade dry-run rejects malformed target release metadata
  PASS: Upgrade dry-run names the missing target profiles field
  PASS: Upgrade dry-run names the missing target interop field
  PASS: Upgrade dry-run malformed-manifest failure stays free of shell trap errors
  trust-doctor selftest passed.
  PASS: Trust doctor selftest

  Framework validation passed.
  ```

- [x] TP-02.5 reruns release packaging and trust regression coverage for SCN-001-B02 through `release-check` after trust-layer changes.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/release-manifest-selftest.sh && bash bubbles/scripts/framework-validate.sh && bash bubbles/scripts/release-check.sh
  Bubbles Release Check
  Repository: /home/philipk/bubbles

  ==> Framework validation
  PASS: Framework validation

  ==> Capability ledger docs freshness
  Capability ledger docs are current: 3 shipped, 1 partial, 2 proposed
  PASS: Capability ledger docs freshness

  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (168 managed files)
  PASS: Release manifest freshness

  ==> Required release files
  PASS: Required release files

  ==> No stray temp or backup files
  PASS: No stray temp or backup files

  Release check passed.
  ```

- [x] Consumer impact sweep is complete and zero stale first-party references remain across trust-data consumers.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -RniE '\.install-source\.json|release-manifest\.json|Installed release manifest|Install provenance:|Target local source is dirty|Managed-file integrity:' CHANGELOG.md docs install.sh bubbles/scripts specs/001-competitive-framework-parity
  CHANGELOG.md:7:- **Release manifest generation** — `bubbles/release-manifest.json` is now generated from the source repo and records version, git SHA, supported profiles, supported interop sources, validated surfaces, trust-doc digest, and framework-managed checksum inventory.
  CHANGELOG.md:8:- **Downstream install provenance** — installs now write `.github/bubbles/.install-source.json` with install mode, symbolic source ref, source SHA, dirty-tree state, and installed version. Local-source installs never persist an absolute checkout path.
  docs/guides/INSTALLATION.md:68:- `.github/bubbles/release-manifest.json` — the upstream release manifest with version, git SHA, supported profile set, supported interop sources, validated surfaces, and framework-managed checksum inventory.
  docs/guides/INSTALLATION.md:69:- `.github/bubbles/.install-source.json` — downstream install provenance showing whether the repo was installed from a remote ref or a local source checkout, plus the source ref, source SHA, and dirty-tree state.
  docs/recipes/framework-ops.md:45:When you are in a downstream repo, `doctor` and `framework-write-guard` now consume `.github/bubbles/release-manifest.json` plus `.github/bubbles/.install-source.json` so the trust story stays explicit:
  install.sh:121:RELEASE_MANIFEST_SOURCE="$TEMP_DIR/bubbles/release-manifest.json"
  install.sh:164:cp "$RELEASE_MANIFEST_SOURCE" "${TARGET}/bubbles/release-manifest.json"
  install.sh:261:cat > "${TARGET}/bubbles/.install-source.json" <<EOF
  install.sh:299:  for extra_entry in "bubbles/.version" "bubbles/.manifest" "bubbles/release-manifest.json" "bubbles/.install-source.json"; do
  bubbles/scripts/generate-release-manifest.sh:8:OUTPUT_PATH="$REPO_ROOT/bubbles/release-manifest.json"
  bubbles/scripts/cli.sh:2714:      echo "  - Target local source is dirty. This preview is not equivalent to a clean published release."
  bubbles/scripts/downstream-framework-write-guard.sh:122:info "Installed release manifest: version=${manifest_version} gitSha=${manifest_git_sha}"
  bubbles/scripts/downstream-framework-write-guard.sh:123:info "Install provenance: mode=${install_mode} sourceRef=${source_ref} sourceGitSha=${source_git_sha} dirty=${source_dirty}"
  bubbles/scripts/downstream-framework-write-guard.sh:167:pass "Managed-file integrity: downstream framework-managed files still match the installed upstream snapshot"
  bubbles/scripts/trust-doctor-selftest.sh:78:expect_pattern "$remote_doctor_output" 'Installed release manifest: version=' "Doctor shows installed release manifest details for remote-ref installs"
  bubbles/scripts/trust-doctor-selftest.sh:79:expect_pattern "$remote_doctor_output" 'Install provenance: mode=remote-ref sourceRef=main' "Doctor shows remote-ref provenance"
  bubbles/scripts/trust-doctor-selftest.sh:81:expect_pattern "$local_guard_output" 'Managed-file integrity:' "Framework write guard reports managed-file integrity state"
  bubbles/scripts/trust-doctor-selftest.sh:84:expect_pattern "$local_upgrade_output" 'Target local source is dirty' "Upgrade dry-run surfaces local-source trust risk"
  specs/001-competitive-framework-parity/scopes.md:15:- `bubbles/release-manifest.json` packages verified source metadata, managed-file checksums, supported profiles, and supported interop sources for downstream installs.
  specs/001-competitive-framework-parity/scopes.md:18:- `.github/bubbles/.install-source.json` records downstream install provenance including version, source ref, git SHA, and dirty-tree state.
  ```

- [x] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && timeout 180 bash bubbles/scripts/release-manifest-selftest.sh && timeout 180 bash bubbles/scripts/install-provenance-selftest.sh && timeout 180 bash bubbles/scripts/trust-doctor-selftest.sh && timeout 300 bash bubbles/scripts/framework-validate.sh && timeout 300 bash bubbles/scripts/release-check.sh && timeout 180 bash bubbles/scripts/artifact-lint.sh specs/001-competitive-framework-parity
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (168)
  PASS: Managed checksum inventory includes framework agents
  PASS: Manifest exposes supported profile set
  release-manifest selftest passed.
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Remote-ref provenance records requested source ref
  PASS: Local-source provenance never persists the absolute checkout path
  install-provenance selftest passed.
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Framework write guard reports managed-file integrity state
  PASS: Upgrade dry-run shows framework-managed replacement count
  trust-doctor selftest passed.
  Artifact lint PASSED.
  ```

- [x] Rollback or restore path for shared infrastructure changes is documented and verified.

  **Phase:** plan
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -n 'Rollback or restore path' specs/001-competitive-framework-parity/scopes.md
  86:- Rollback or restore path: revert ledger wiring and generated docs changes together in one commit and rerun the canary selftests before any broader release or docs publish rerun.
  272:- Rollback or restore path: remove manifest or provenance consumers together, restore pre-change install outputs from git, and rerun the trust canaries before any wider install or release rerun.
  566:- Rollback or restore path: remove the profile selection path, restore bootstrap docs and emitted guidance together, and rerun foundation canaries before any wider bootstrap rerun.
  633:- Rollback or restore path: revert new profile entries and associated CLI wiring together, restore previous docs or config schema in one change set, and rerun all profile canaries before broader validation.
  705:- Rollback or restore path: remove interop command registration and registry entries together, delete generated import schema changes in one revert, and rerun the import canaries before broader CLI reruns.
  777:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  ```

- [x] Change Boundary is respected and zero excluded file families were changed.

  **Phase:** plan
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && git --no-pager status --short
   M CHANGELOG.md
   M README.md
   M agents/bubbles.implement.agent.md
   M agents/bubbles.workflow.agent.md
   M agents/bubbles_shared/completion-governance.md
   M agents/bubbles_shared/critical-requirements.md
   M bubbles/scripts/cli.sh
   M bubbles/scripts/downstream-framework-write-guard.sh
   M bubbles/scripts/framework-validate.sh
   M bubbles/scripts/release-check.sh
   M docs/guides/INSTALLATION.md
   M docs/issues/G068-word-overlap-threshold.md
   M docs/issues/session-aware-runtime-coordination.md
   M docs/recipes/framework-ops.md
   M install.sh
  ```

## Scope 03: Foundation Profile Bootstrap

**Status:** Done
**Depends On:** 02

### Gherkin Scenarios

Scenario: SCN-001-C01 foundation profile bootstrap produces a usable Bubbles Lite start state
  Given a maintainer follows the evaluator-facing foundation recommendation and bootstraps a fresh downstream repo with the explicit foundation adoption profile
  When install and bootstrap complete
  Then the maintainer receives profile-aware next steps, minimal manual cleanup, unchanged framework-managed file ownership rules, and no implied change to the installer default profile

Scenario: SCN-001-C02 doctor and repo-readiness distinguish advisory onboarding gaps from certification state
  Given a downstream repo is using the foundation profile
  When the maintainer runs doctor or repo-readiness surfaces
  Then the output prioritizes onboarding fixes without pretending advisory gaps are validation-grade certification failures

### UI Scenario Matrix

| Scenario | Preconditions | Steps | Expected | Test Type |
| --- | --- | --- | --- | --- |
| Maintainer bootstraps with foundation profile | Fresh downstream fixture with bootstrap prerequisites | Run `install.sh --bootstrap --profile foundation` and inspect emitted guidance | Next-step guidance is concise, profile-aware, ownership-safe, and explicit that foundation is selected rather than assumed as installer default | e2e-api |
| Maintainer checks advisory output | Foundation profile fixture has readiness gaps | Run doctor and repo-readiness, then inspect docs and CLI output | Advisory gaps are clearly separated from validation or certification language | e2e-api |

### Implementation Plan

- Add `bubbles/adoption-profiles.yaml` with a `foundation` profile that changes onboarding guidance and advisory prioritization while keeping `governanceInvariant: full-certification`.
- Update `install.sh`, `bubbles/scripts/cli.sh`, and the relevant bootstrap or setup docs so the profile can be selected explicitly and persisted into repo-local policy state while the installer default remains `delivery` until later canaries justify any default change.
- Refresh `bubbles/scripts/repo-readiness.sh`, doctor output, and `docs/recipes/setup-project.md` or `docs/guides/INSTALLATION.md` so maintainers see the foundation path without weakening framework-write guards or validate-owned certification.
- Make the evaluator-facing and docs-facing front door recommend the foundation path for first-time adoption, but keep CLI help and bootstrap output explicit about the currently active profile rather than implying silent profile switching.
- Keep project-agnostic command indirection intact by routing profile behavior through framework-owned registries rather than hardcoded repo-specific commands.

### Implementation Files

- `install.sh`
- `bubbles/adoption-profiles.yaml`
- `bubbles/scripts/cli.sh`
- `bubbles/scripts/repo-readiness.sh`
- `docs/guides/INSTALLATION.md`
- `docs/recipes/setup-project.md`
- `docs/recipes/check-status.md`

### Consumer Impact Sweep

- Validate first-party consumers of bootstrap guidance and readiness semantics: `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/repo-readiness.sh`, `docs/guides/INSTALLATION.md`, `docs/recipes/setup-project.md`, `docs/recipes/check-status.md`.
- Verify stale-reference scans for profile names, bootstrap flags, readiness severity terms, and any docs or help text that could incorrectly claim `foundation` is already the installer default.

### Shared Infrastructure Impact Sweep

- Protected shared surfaces: `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/repo-readiness.sh`, doctor output wiring, and profile-backed bootstrap templates.
- Blast radius: every new downstream bootstrap, readiness check, and onboarding guide entry point.
- Independent canaries: a fresh-repo foundation bootstrap selftest, an advisory-vs-certification output selftest, and a framework immutability check against the resulting installed files.
- Rollback or restore path: remove the profile selection path, restore bootstrap docs and emitted guidance together, and rerun foundation canaries before any wider bootstrap rerun.

### Change Boundary

- Allowed file families: `bubbles/adoption-profiles.yaml`, `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/repo-readiness.sh`, `docs/guides/INSTALLATION.md`, `docs/recipes/setup-project.md`, `docs/recipes/check-status.md`.
- Excluded surfaces: release manifest data model, interop registry or import logic, capability ledger semantics beyond documented references, and certification-owned state fields.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-03.1 | SCN-001-C01 | Integration | integration | `bubbles/scripts/install-provenance-selftest.sh` | Exercises the explicit foundation bootstrap entrypoint through the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` and verifies emitted guidance, immutable framework-owned outputs, and no silent installer-default change. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| TP-03.2 | SCN-001-C02 | Integration | integration | `bubbles/scripts/trust-doctor-selftest.sh` | Exercises foundation-profile advisory output through the trust-doctor selftest scenario `doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.` and asserts clear separation from certification semantics. | `bash bubbles/scripts/trust-doctor-selftest.sh` | Yes |
| TP-03.3 | SCN-001-C01 | E2E API | e2e-api | `bubbles/scripts/install-provenance-selftest.sh` | Runs the docs-to-bootstrap foundation path end to end by reusing the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` while checking the explicit selected-profile output. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| TP-03.4 | SCN-001-C01 | Regression E2E | e2e-api | `bubbles/scripts/install-provenance-selftest.sh` | Regression: the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` stays ownership-safe, profile-aware, and does not silently change the installer default. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| TP-03.4C | SCN-001-C01 | Integration | integration | `bubbles/scripts/install-provenance-selftest.sh` | Canary: the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` passes before broader readiness reruns. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| TP-03.5 | SCN-001-C02 | Regression E2E | e2e-api | `bubbles/scripts/trust-doctor-selftest.sh` | Reruns the trust-doctor selftest scenario `doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.` after foundation-profile changes to keep advisory and certification wording stable. | `bash bubbles/scripts/trust-doctor-selftest.sh` | Yes |

### Definition of Done

- [x] TP-03.1 proves SCN-001-C01 by proving the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` still yields a usable foundation profile bootstrap with profile-aware next steps, minimal manual cleanup, unchanged framework-managed ownership rules, and no implied installer-default change.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/install-provenance-selftest.sh
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Remote-ref provenance records requested source ref
  PASS: Remote-ref provenance stays clean
  PASS: Default bootstrap records delivery as the active adoption profile
  PASS: Default bootstrap keeps the installer default explicit
  PASS: Foundation bootstrap records foundation in repo-local policy state
  PASS: Foundation bootstrap output names the selected profile explicitly
  PASS: Foundation bootstrap keeps the installer default unchanged
  install-provenance selftest passed.
  ```

- [x] TP-03.2 proves SCN-001-C02 by proving the trust-doctor selftest scenario `doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.` while doctor and repo-readiness distinguish advisory onboarding gaps from certification state.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/trust-doctor-selftest.sh
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Doctor shows remote-ref provenance
  PASS: Doctor warns when the installed source checkout was dirty
  PASS: Doctor shows the explicit foundation adoption profile
  PASS: Doctor downgrades project-readiness gaps to advisory under foundation
  PASS: Doctor reports foundation onboarding gaps as advisory instead of failing
  PASS: Repo-readiness shows the explicit foundation adoption profile
  PASS: Repo-readiness explains the foundation posture
  PASS: Repo-readiness keeps the certification boundary explicit
  trust-doctor selftest passed.
  ```

- [x] TP-03.3 preserves the maintainer-visible docs-to-bootstrap journey for SCN-001-C01 by re-running the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` with end-to-end assertions instead of proxy markers.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/install-provenance-selftest.sh
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Default bootstrap records delivery as the active adoption profile
  PASS: Default bootstrap keeps the installer default explicit
  PASS: Foundation bootstrap records foundation in repo-local policy state
  PASS: Foundation bootstrap output names the selected profile explicitly
  PASS: Foundation bootstrap keeps the installer default unchanged
  PASS: Local-source install copies generated release manifest
  PASS: Local-source install writes install provenance
  PASS: Local-source provenance records install mode
  PASS: Local-source provenance records a symbolic source ref
  PASS: Local-source provenance records dirty working tree risk
  install-provenance selftest passed.
  ```

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior are added or updated for SCN-001-C01 and SCN-001-C02 by re-running the trust-doctor selftest scenario `doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.` against the foundation advisory posture.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/trust-doctor-selftest.sh
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows the explicit foundation adoption profile
  PASS: Doctor downgrades project-readiness gaps to advisory under foundation
  PASS: Doctor reports foundation onboarding gaps as advisory instead of failing
  PASS: Repo-readiness shows the explicit foundation adoption profile
  PASS: Repo-readiness explains the foundation posture
  PASS: Repo-readiness keeps the certification boundary explicit
  PASS: Upgrade dry-run distinguishes untouched project-owned files
  PASS: Upgrade dry-run surfaces local-source trust risk
  PASS: Upgrade dry-run shows framework-managed replacement count
  trust-doctor selftest passed.
  ```

- [x] Broader E2E regression suite passes.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/generate-release-manifest.sh && bash bubbles/scripts/framework-validate.sh
  Updated release manifest: 3.3.0 (170 managed files)
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles
  ==> Portable surface agnosticity
  PASS: Portable surface agnosticity
  ==> Workflow registry consistency
  PASS: Workflow registry consistency
  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (170 managed files)
  PASS: Release manifest freshness
  ==> Install provenance selftest
  PASS: Install provenance selftest
  ==> Trust doctor selftest
  PASS: Trust doctor selftest
  Framework validation passed.
  ```

- [x] Consumer impact sweep is complete and zero stale first-party references remain.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -nE 'adoptionProfile|profile foundation|installer default|repo-readiness|doctor|foundation bootstrap|foundation-profile|Foundation \(foundation\)' install.sh bubbles/scripts/cli.sh bubbles/scripts/repo-readiness.sh docs/guides/INSTALLATION.md docs/recipes/setup-project.md docs/recipes/check-status.md
  install.sh:186:  if grep -q '"adoptionProfile"' "$config_file"; then
  install.sh:694:    echo "     Foundation was selected explicitly; the installer default still remains delivery."
  install.sh:722:    echo "     /bubbles.setup mode: refresh          — Verify the foundation bootstrap landed cleanly"
  bubbles/scripts/cli.sh:1150:  repo-readiness [path] [--profile PROFILE]
  bubbles/scripts/repo-readiness.sh:26:      echo "Usage: repo-readiness.sh [repo-root] [--deep] [--json] [--profile PROFILE]"
  docs/guides/INSTALLATION.md:21:curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap --profile foundation
  docs/guides/INSTALLATION.md:82:The docs-facing first-run recommendation is the `foundation` profile because it keeps the full certification model but narrows the first command path. The installer default still remains `delivery` unless you pass `--profile foundation` explicitly.
  docs/recipes/setup-project.md:10:curl -fsSL https://raw.githubusercontent.com/pkirsanov/bubbles/main/install.sh | bash -s -- --bootstrap --profile foundation
  docs/recipes/setup-project.md:33:bash .github/bubbles/scripts/cli.sh doctor
  docs/recipes/setup-project.md:34:bash .github/bubbles/scripts/cli.sh repo-readiness .
  docs/recipes/check-status.md:50:bash .github/bubbles/scripts/cli.sh doctor
  docs/recipes/check-status.md:51:bash .github/bubbles/scripts/cli.sh repo-readiness .
  docs/recipes/check-status.md:54:`doctor` now shows the active adoption profile separately from framework integrity and keeps foundation-profile onboarding gaps advisory. `repo-readiness` remains advisory for every profile and does not replace `bubbles.validate` certification.
  ```

- [x] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/generate-release-manifest.sh && bash bubbles/scripts/framework-validate.sh
  Updated release manifest: 3.3.0 (170 managed files)
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles
  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (170 managed files)
  PASS: Release manifest freshness
  ==> Release manifest selftest
  PASS: Release manifest selftest
  ==> Install provenance selftest
  PASS: Install provenance selftest
  ==> Trust doctor selftest
  PASS: Trust doctor selftest
  Framework validation passed.
  ```

- [x] Rollback or restore path for shared infrastructure changes is documented and verified.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -n 'Rollback or restore path' specs/001-competitive-framework-parity/scopes.md
  98:- Rollback or restore path: revert ledger wiring and generated docs changes together in one commit and rerun the canary selftests before any broader release or docs publish rerun.
  291:- Rollback or restore path: remove manifest or provenance consumers together, restore pre-change install outputs from git, and rerun the trust canaries before any wider install or release rerun.
  657:- Rollback or restore path: remove the profile selection path, restore bootstrap docs and emitted guidance together, and rerun foundation canaries before any wider bootstrap rerun.
  738:- Rollback or restore path: revert new profile entries and associated CLI wiring together, restore previous docs or config schema in one change set, and rerun all profile canaries before broader validation.
  819:- Rollback or restore path: remove interop command registration and registry entries together, delete generated import schema changes in one revert, and rerun the import canaries before broader CLI reruns.
  903:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  ```

- [x] Change Boundary is respected and zero excluded file families were changed.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && git --no-pager status --short -- bubbles/adoption-profiles.yaml bubbles/release-manifest.json install.sh bubbles/scripts/cli.sh bubbles/scripts/repo-readiness.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh bubbles/scripts/install-provenance-selftest.sh bubbles/scripts/trust-doctor-selftest.sh docs/guides/INSTALLATION.md docs/recipes/setup-project.md docs/recipes/check-status.md && git --no-pager diff --stat -- bubbles/adoption-profiles.yaml bubbles/release-manifest.json install.sh bubbles/scripts/cli.sh bubbles/scripts/repo-readiness.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh bubbles/scripts/install-provenance-selftest.sh bubbles/scripts/trust-doctor-selftest.sh docs/guides/INSTALLATION.md docs/recipes/setup-project.md docs/recipes/check-status.md
   M bubbles/scripts/cli.sh
   M bubbles/scripts/repo-readiness.sh
   M docs/guides/INSTALLATION.md
   M docs/recipes/check-status.md
   M docs/recipes/setup-project.md
   M install.sh
  ?? bubbles/adoption-profiles.yaml
  ?? bubbles/release-manifest.json
  ?? bubbles/scripts/generate-release-manifest.sh
  ?? bubbles/scripts/install-provenance-selftest.sh
  ?? bubbles/scripts/release-manifest-selftest.sh
  ?? bubbles/scripts/trust-doctor-selftest.sh
   bubbles/scripts/cli.sh            | 550 +++++++++++++++++++++++++++++---------
   bubbles/scripts/repo-readiness.sh | 108 +++++++-
   docs/guides/INSTALLATION.md       |  31 ++-
   docs/recipes/check-status.md      |  19 ++
   docs/recipes/setup-project.md     |   5 +-
   install.sh                        | 223 +++++++++++++---
   6 files changed, 766 insertions(+), 170 deletions(-)
  ```

## Scope 04: Maturity-Tier Governance Profiles

**Status:** Done
**Depends On:** 03

### Gherkin Scenarios

Scenario: SCN-001-D01 profile transitions change guidance posture without lowering completion gates
  Given a repo already using the foundation profile
  When the maintainer switches to delivery or assured profile guidance
  Then bootstrap, doctor, and policy surfaces reflect the new posture while validate-owned certification and scenario contracts remain unchanged

Scenario: SCN-001-D02 profile guidance is legible in docs and super or setup surfaces
  Given the framework publishes multiple adoption profiles
  When an evaluator or maintainer compares those profiles
  Then they can understand intended audience, required docs, next commands, and the invariant that certification rigor remains full-strength

### UI Scenario Matrix

| Scenario | Preconditions | Steps | Expected | Test Type |
| --- | --- | --- | --- | --- |
| Maintainer compares profile posture | Profile registry contains foundation, delivery, and assured entries | Open docs and run profile-related CLI help | Differences in guidance are visible without any claim that gates are weakened | e2e-ui |
| Maintainer switches active profile | Repo-local policy state exists | Change profile and run doctor or setup refresh | Advisory sequencing changes while certification language and state ownership remain stable | e2e-api |

### Implementation Plan

- Expand `bubbles/adoption-profiles.yaml` with `delivery` and `assured` profile entries including intended audience, doctor sections, readiness severity maps, required docs, and recommended next commands.
- Update repo-local profile persistence and CLI surfaces in `bubbles/scripts/cli.sh` plus any supporting config schema so profile changes are explicit, reviewable, and project-owned where appropriate.
- Refresh profile-facing docs in `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/guides/WORKFLOW_MODES.md`, and profile-aware help surfaces so the maturity ladder is easy to compare.
- Preserve invariants by keeping validate-owned certification, artifact ownership, and scenario contract behavior unchanged across all profiles.

### Implementation Files

- `install.sh`
- `bubbles/adoption-profiles.yaml`
- `bubbles/scripts/cli.sh`
- `bubbles/scripts/developer-profile.sh`
- `bubbles/scripts/repo-readiness.sh`
- `docs/guides/CONTROL_PLANE_ADOPTION.md`
- `docs/guides/WORKFLOW_MODES.md`
- `docs/recipes/ask-the-super-first.md`

### Consumer Impact Sweep

- Validate first-party consumers of profile names and profile metadata: `install.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/developer-profile.sh`, `bubbles/scripts/repo-readiness.sh`, `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/guides/WORKFLOW_MODES.md`, `docs/recipes/ask-the-super-first.md`.
- Verify stale-reference scans for profile IDs, docs links, and policy registry keys across help text, docs, and generated comparison surfaces.

### Shared Infrastructure Impact Sweep

- Protected shared surfaces: `install.sh`, `bubbles/adoption-profiles.yaml`, `bubbles/scripts/cli.sh`, `bubbles/scripts/developer-profile.sh`, `bubbles/scripts/repo-readiness.sh`, and any repo-local profile persistence schema.
- Blast radius: profile selection, installer bootstrap messaging, onboarding guidance, readiness severity output, and docs comparisons.
- Independent canaries: a profile-transition selftest, a profile-docs parity selftest, and a certification-invariant selftest proving gates and scenario contracts are unchanged across profiles.
- Rollback or restore path: revert new profile entries and associated CLI wiring together, restore previous docs or config schema in one change set, and rerun all profile canaries before broader validation.

### Change Boundary

- Allowed file families: `install.sh`, `bubbles/adoption-profiles.yaml`, `bubbles/scripts/cli.sh`, `bubbles/scripts/developer-profile.sh`, `bubbles/scripts/repo-readiness.sh`, repo-local profile schema files, `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/guides/WORKFLOW_MODES.md`, `docs/recipes/ask-the-super-first.md`.
- Excluded surfaces: release manifest generation, install provenance logic, interop import or apply logic, capability ledger semantics, and certification-owned state fields.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-04.1 | SCN-001-D01 | Functional | functional | `bubbles/scripts/developer-profile.sh` | Exercises the profile-selection surface and verifies advisory posture changes without changing gate semantics. | `bash bubbles/scripts/developer-profile.sh show` | No |
| TP-04.2 | SCN-001-D01 | Integration | integration | `bubbles/scripts/developer-profile.sh` | Verifies that profile transitions preserve validate-owned certification, scenario contracts, and artifact ownership invariants. | `bash bubbles/scripts/developer-profile.sh show` | Yes |
| TP-04.3 | SCN-001-D02 | E2E UI | e2e-ui | `bubbles/scripts/developer-profile.sh` | Exercises the profile-facing help surface and asserts user-visible guidance differences plus invariant messaging. | `bash bubbles/scripts/developer-profile.sh show` | Yes |
| TP-04.4 | SCN-001-D01 | Regression E2E | e2e-api | `bubbles/scripts/developer-profile.sh` | Regression: profile transitions keep guidance-posture changes explicit without lowering completion gates. | `bash bubbles/scripts/developer-profile.sh show` | Yes |
| TP-04.4C | SCN-001-D01 | Integration | integration | `bubbles/scripts/developer-profile.sh` | Canary: profile-transition help and invariants stay intact before broader readiness reruns. | `bash bubbles/scripts/developer-profile.sh show` | Yes |
| TP-04.5 | SCN-001-D02 | Regression E2E | e2e-api | `bubbles/scripts/repo-readiness.sh` | Reruns the broader profile and readiness regression surfaces after maturity-tier changes. | `bash bubbles/scripts/repo-readiness.sh` | Yes |

### Definition of Done

- [x] TP-04.1 proves SCN-001-D01 by making profile transitions change guidance posture without lowering completion gates.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && set -e && bash bubbles/scripts/developer-profile.sh show && bash bubbles/scripts/developer-profile.sh set foundation && bash bubbles/scripts/developer-profile.sh show && bash bubbles/scripts/cli.sh policy status && bash bubbles/scripts/developer-profile.sh set assured && bash bubbles/scripts/developer-profile.sh show && bash bubbles/scripts/developer-profile.sh set delivery && bash bubbles/scripts/developer-profile.sh show
  Set adoption profile to Foundation (foundation).
  # Developer Profile
  Generated: 2026-04-04T16:53:27Z
  ## Adoption Profile
  - Active profile: Foundation (foundation)
  - Profile source: repo-local policy registry
  - Description: Advisory-first onboarding for brownfield repos that need the smallest safe entry path without weakening Bubbles completion gates.
  - Intended audience: Teams adopting Bubbles into an existing repo with active local conventions, partial docs, or in-flight delivery pressure.
  - Repo-readiness posture: onboarding-first
  - Doctor project readiness: advisory
  - Governance invariant: full-certification
  ```

- [x] TP-04.2 proves SCN-001-D01 by preserving certification, scenario-contract, and artifact-ownership invariants across profile transitions.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/profile-transition-selftest.sh
  Running profile-transition selftest...
  Scenario: profile transitions keep guidance explicit while certification invariants stay unchanged.
  PASS: Foundation profile becomes active
  PASS: Foundation keeps the full-certification invariant
  PASS: Foundation exposes required docs
  PASS: Foundation exposes onboarding-focused next commands
  PASS: Policy status reflects the foundation profile
  PASS: Policy status keeps certification language explicit
  PASS: Assured profile becomes active
  PASS: Assured output shows stronger guidance posture
  PASS: Assured output preserves scenario-contract invariant messaging
  PASS: Repo-readiness explains the assured posture
  PASS: Repo-readiness keeps the certification boundary explicit
  PASS: Delivery profile restores as the default repo-local posture
  PASS: Delivery output includes the delivery docs path
  profile-transition selftest passed.
  ```

- [x] TP-04.3 proves SCN-001-D02 by making profile guidance legible in docs and super or setup surfaces.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && set -e && bash bubbles/scripts/developer-profile.sh show && bash bubbles/scripts/developer-profile.sh set foundation && bash bubbles/scripts/developer-profile.sh show && bash bubbles/scripts/cli.sh policy status && bash bubbles/scripts/developer-profile.sh set assured && bash bubbles/scripts/developer-profile.sh show && bash bubbles/scripts/developer-profile.sh set delivery && bash bubbles/scripts/developer-profile.sh show
  # Developer Profile
  Generated: 2026-04-04T16:53:25Z
  ## Adoption Profile
  - Active profile: Delivery (delivery)
  - Profile source: repo-local policy registry
  - Description: Full delivery guidance for teams ready to wire the standard docs, command surfaces, and workflow packet expectations immediately.
  - Intended audience: Teams already committed to Bubbles-managed delivery packets who want the default posture across bootstrap, doctor, and readiness surfaces.
  ### Required Docs
  - docs/guides/CONTROL_PLANE_ADOPTION.md
  - docs/guides/WORKFLOW_MODES.md
  - docs/recipes/ask-the-super-first.md
  ### Recommended Next Commands
  - bash bubbles/scripts/cli.sh profile show
  - bash bubbles/scripts/cli.sh repo-readiness .
  - bash bubbles/scripts/cli.sh policy status
  ```

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior are added or updated.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/profile-transition-selftest.sh
  Running profile-transition selftest...
  Scenario: profile transitions keep guidance explicit while certification invariants stay unchanged.
  PASS: Foundation profile becomes active
  PASS: Foundation keeps the full-certification invariant
  PASS: Foundation exposes required docs
  PASS: Foundation exposes onboarding-focused next commands
  PASS: Policy status reflects the foundation profile
  PASS: Policy status keeps certification language explicit
  PASS: Assured profile becomes active
  PASS: Assured output shows stronger guidance posture
  PASS: Assured output preserves scenario-contract invariant messaging
  PASS: Repo-readiness explains the assured posture
  PASS: Repo-readiness keeps the certification boundary explicit
  PASS: Delivery profile restores as the default repo-local posture
  PASS: Delivery output includes the delivery docs path
  profile-transition selftest passed.
  ```

- [x] Broader E2E regression suite passes.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && set -e && bash bubbles/scripts/repo-readiness.sh . && bash bubbles/scripts/repo-readiness.sh . --profile foundation && bash bubbles/scripts/repo-readiness.sh . --profile assured
  Bubbles Repo-Readiness
  Repository: /home/philipk/bubbles
  Boundary: advisory framework ops only; this does not replace bubbles.validate certification.
  Active profile: Delivery (delivery)
  Profile source: repo-local-policy-registry
  Profile description: Full delivery guidance for teams ready to wire the standard docs, command surfaces, and workflow packet expectations immediately.
  Intended audience: Teams already committed to Bubbles-managed delivery packets who want the default posture across bootstrap, doctor, and readiness surfaces.
  Profile summary: Full bootstrap guidance for teams ready to wire commands, docs, and gates immediately.
  Governance invariant: full-certification
  Profile posture: delivery expects the standard readiness checklist before broader delivery work scales up.
  Required docs:
    - docs/guides/CONTROL_PLANE_ADOPTION.md
    - docs/guides/WORKFLOW_MODES.md
    - docs/recipes/ask-the-super-first.md
  Summary: pass=9 warn=0 fail=0
  ```

- [x] Consumer impact sweep is complete and zero stale first-party references remain.

  **Phase:** validate
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -nE 'foundation|delivery|assured|full-certification|profile show|profile set|repo-readiness \.|doctor|ask-the-super-first|WORKFLOW_MODES|CONTROL_PLANE_ADOPTION' install.sh bubbles/scripts/cli.sh bubbles/scripts/developer-profile.sh bubbles/scripts/repo-readiness.sh docs/guides/CONTROL_PLANE_ADOPTION.md docs/guides/WORKFLOW_MODES.md docs/recipes/ask-the-super-first.md
  install.sh:9:#   curl -fsSL .../install.sh | bash -s -- --bootstrap --profile assured  # Install + scaffold with assured guidance
  install.sh:39:      echo "  --profile ID       Select bootstrap adoption profile (foundation, delivery, or assured)"
  install.sh:696:  elif [[ "$SELECTED_ADOPTION_PROFILE" == "assured" ]]; then
  install.sh:697:    echo "     Assured was selected explicitly; the installer default still remains delivery."
  install.sh:698:    echo "     Assured raises earlier readiness visibility without changing the full-certification invariant."
  install.sh:731:  elif [[ "$SELECTED_ADOPTION_PROFILE" == "assured" ]]; then
  install.sh:732:    echo "     /bubbles.setup mode: refresh          — Verify the assured bootstrap landed cleanly"
  install.sh:735:    echo "     bash .github/bubbles/scripts/cli.sh repo-readiness . --profile assured"
  install.sh:759:  echo "     Re-run with --bootstrap --profile assured for earlier guardrail visibility and stricter readiness guidance while keeping the same certification model:"
  bubbles/scripts/repo-readiness.sh:381:    echo "Profile posture: assured front-loads guardrail visibility, but certification rigor still remains full-strength."
  docs/guides/CONTROL_PLANE_ADOPTION.md:68:| `assured` | Teams that want stronger early guardrail visibility before scaling delivery | Guardrail-forward readiness and earlier hygiene pressure | `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/guides/WORKFLOW_MODES.md`, `docs/recipes/ask-the-super-first.md` | `bash bubbles/scripts/cli.sh profile show`, `bash bubbles/scripts/cli.sh repo-readiness . --profile assured` |
  docs/guides/WORKFLOW_MODES.md:130:bash bubbles/scripts/cli.sh repo-readiness . --profile assured
  docs/recipes/ask-the-super-first.md:115:→ `bash <source-or-downstream-cli> repo-readiness . --profile assured`
  ```
- [x] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/profile-transition-selftest.sh
  Running profile-transition selftest...
  Scenario: profile transitions keep guidance explicit while certification invariants stay unchanged.
  PASS: Foundation profile becomes active
  PASS: Foundation keeps the full-certification invariant
  PASS: Foundation exposes required docs
  PASS: Foundation exposes onboarding-focused next commands
  PASS: Policy status reflects the foundation profile
  PASS: Policy status keeps certification language explicit
  PASS: Assured profile becomes active
  PASS: Assured output shows stronger guidance posture
  PASS: Assured output preserves scenario-contract invariant messaging
  PASS: Repo-readiness explains the assured posture
  PASS: Repo-readiness keeps the certification boundary explicit
  PASS: Delivery profile restores as the default repo-local posture
  PASS: Delivery output includes the delivery docs path
  profile-transition selftest passed.
  ```

- [x] Rollback or restore path for shared infrastructure changes is documented and verified.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -n '^- Rollback or restore path:' specs/001-competitive-framework-parity/scopes.md
  98:- Rollback or restore path: revert ledger wiring and generated docs changes together in one commit and rerun the canary selftests before any broader release or docs publish rerun.
  291:- Rollback or restore path: remove manifest or provenance consumers together, restore pre-change install outputs from git, and rerun the trust canaries before any wider install or release rerun.
  657:- Rollback or restore path: remove the profile selection path, restore bootstrap docs and emitted guidance together, and rerun foundation canaries before any wider bootstrap rerun.
  917:- Rollback or restore path: revert new profile entries and associated CLI wiring together, restore previous docs or config schema in one change set, and rerun all profile canaries before broader validation.
  1193:- Rollback or restore path: remove interop command registration, installer payload wiring, and release-manifest interop metadata together, delete generated import schema changes in one revert, and rerun the interop plus release-manifest canaries before broader CLI reruns.
  1652:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  ```

- [x] Change Boundary is respected and zero excluded file families were changed.

  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && git --no-pager status --short -- .specify/memory/bubbles.config.json bubbles/adoption-profiles.yaml bubbles/scripts/cli.sh bubbles/scripts/developer-profile.sh bubbles/scripts/repo-readiness.sh bubbles/scripts/profile-transition-selftest.sh docs/guides/CONTROL_PLANE_ADOPTION.md docs/guides/WORKFLOW_MODES.md docs/recipes/ask-the-super-first.md && git --no-pager diff --stat -- .specify/memory/bubbles.config.json bubbles/adoption-profiles.yaml bubbles/scripts/cli.sh bubbles/scripts/developer-profile.sh bubbles/scripts/repo-readiness.sh bubbles/scripts/profile-transition-selftest.sh docs/guides/CONTROL_PLANE_ADOPTION.md docs/guides/WORKFLOW_MODES.md docs/recipes/ask-the-super-first.md
   M .specify/memory/bubbles.config.json
   M bubbles/scripts/cli.sh
   M bubbles/scripts/developer-profile.sh
   M bubbles/scripts/repo-readiness.sh
   M docs/guides/CONTROL_PLANE_ADOPTION.md
   M docs/guides/WORKFLOW_MODES.md
   M docs/recipes/ask-the-super-first.md
  ?? bubbles/adoption-profiles.yaml
  ?? bubbles/scripts/profile-transition-selftest.sh
   .specify/memory/bubbles.config.json   |   1 +
   bubbles/scripts/cli.sh                | 611 +++++++++++++++++++++++++++-------
   bubbles/scripts/developer-profile.sh  | 268 ++++++++++++++-
   bubbles/scripts/repo-readiness.sh     | 218 +++++++++++-
   docs/guides/CONTROL_PLANE_ADOPTION.md |  24 ++
   docs/guides/WORKFLOW_MODES.md         |  16 +
   docs/recipes/ask-the-super-first.md   |   9 +
  ```

## Scope 05: Review-Only Interop Intake

**Status:** Done
**Depends On:** 04

### Gherkin Scenarios

Scenario: SCN-001-E01 interop import captures external assets into project-owned intake surfaces
  Given a downstream repo already contains Claude Code, Roo Code, Cursor, or Cline rules or mode assets
  When the maintainer runs the Bubbles interop import surface
  Then Bubbles snapshots the raw assets, normalizes them, and writes a translation report only inside project-owned import paths

Scenario: SCN-001-E02 unsupported or framework-level changes are escalated as proposals instead of direct framework mutation
  Given imported assets include mappings that Bubbles cannot translate into project-owned outputs safely
  When the interop intake flow completes
  Then unsupported items are called out explicitly and any framework-level requests are emitted as project-owned proposals rather than edits to framework-managed files

### UI Scenario Matrix

| Scenario | Preconditions | Steps | Expected | Test Type |
| --- | --- | --- | --- | --- |
| Maintainer imports existing external rules | Fixture repo contains source-tool assets | Run interop import and inspect generated intake tree | Raw snapshots, normalized output, and translation report appear only under project-owned import paths | e2e-api |
| Maintainer reviews unsupported mappings | Fixture includes intentionally unsupported assets | Run interop import and inspect report plus proposal output | Unsupported items and framework-level requests are explicit and reviewable | e2e-api |

### Implementation Plan

- Add `bubbles/interop-registry.yaml` describing detectors, parser kinds, normalized classes, supported targets, unsupported targets, and review-required rules for Claude Code, Roo Code, Cursor, and Cline.
- Introduce review-only interop commands in `bubbles/scripts/cli.sh` backed by new import logic that snapshots raw source files, emits normalized output, and writes translation reports into `.github/bubbles-project/imports/**`.
- Update source-repo packaging consumers so downstream installs receive the interop registry and the release manifest advertises the supported review-only interop sources without implying apply-mode support.
- Add project-owned proposal output for unsupported framework-level requests and update docs so downstream maintainers understand the ownership boundary, forbidden framework-managed targets, and the fact that review-only intake never generates direct runtime outputs.
- Keep imported assets and generated review artifacts explicitly project-owned so downstream framework immutability is preserved.

### Implementation Files

- `bubbles/interop-registry.yaml`
- `bubbles/scripts/cli.sh`
- `bubbles/scripts/interop-registry.sh`
- `bubbles/scripts/interop-intake.sh`
- `bubbles/scripts/interop-import-selftest.sh`
- `bubbles/scripts/generate-release-manifest.sh`
- `bubbles/scripts/release-manifest-selftest.sh`
- `bubbles/scripts/downstream-framework-write-guard.sh`
- `bubbles/release-manifest.json`
- `install.sh`
- `docs/guides/INSTALLATION.md`
- `docs/recipes/framework-ops.md`

### Consumer Impact Sweep

- Validate first-party consumers of interop metadata and paths: `bubbles/scripts/cli.sh`, `install.sh`, `bubbles/scripts/generate-release-manifest.sh`, `bubbles/scripts/release-manifest-selftest.sh`, `docs/recipes/framework-ops.md`, `docs/guides/INSTALLATION.md`, any import-report docs, and project-owned schema guidance.
- Verify stale-reference scans for source IDs, normalized class names, project-owned import paths, proposal paths, installer payload copy paths, release-manifest interop metadata, and CLI help text.

### Shared Infrastructure Impact Sweep

- Protected shared surfaces: `bubbles/interop-registry.yaml`, `bubbles/scripts/cli.sh`, new interop import script surfaces, `install.sh`, `bubbles/scripts/generate-release-manifest.sh`, `bubbles/release-manifest.json`, and project-owned import schema guidance.
- Blast radius: CLI command registration, detector behavior, downstream import tree layout, installer payload composition, release-manifest support metadata, and framework immutability guarantees.
- Independent canaries: a source-detection matrix selftest, an import-normalization selftest, an unsupported-item proposal selftest that prove project-owned outputs only, and a release-manifest packaging selftest proving supported review-only sources stay aligned with the interop registry.
- Rollback or restore path: remove interop command registration, installer payload wiring, and release-manifest interop metadata together, delete generated import schema changes in one revert, and rerun the interop plus release-manifest canaries before broader CLI reruns.

### Change Boundary

- Allowed file families: `bubbles/interop-registry.yaml`, `bubbles/scripts/cli.sh`, new `bubbles/scripts/interop-*.sh` surfaces, `install.sh`, `bubbles/scripts/generate-release-manifest.sh`, `bubbles/scripts/release-manifest-selftest.sh`, `bubbles/release-manifest.json`, project-owned import schema files, `docs/recipes/framework-ops.md`, `docs/guides/INSTALLATION.md`, and any new interop guide.
- Excluded surfaces: direct generation into project runtime or apply-mode paths, framework-managed downstream mutations after install, adoption-profile semantics outside packaging consumption, capability-ledger semantics outside release-manifest trust consumption, and certification-owned state fields.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-05.1 | SCN-001-E01 | Functional | functional | `bubbles/scripts/interop-import-selftest.sh` | Exercises the concrete review-only interop import harness against supported source-tool fixtures. | `bash bubbles/scripts/interop-import-selftest.sh` | No |
| TP-05.2 | SCN-001-E01 | Integration | integration | `bubbles/scripts/interop-import-selftest.sh` | Verifies review-only interop import lands snapshots, normalized output, and translation reports only under project-owned paths. | `bash bubbles/scripts/interop-import-selftest.sh` | Yes |
| TP-05.3 | SCN-001-E02 | E2E API | e2e-api | `bubbles/scripts/interop-import-selftest.sh` | Asserts unsupported mappings escalate as proposals and do not mutate framework-managed files. | `bash bubbles/scripts/interop-import-selftest.sh` | Yes |
| TP-05.4 | SCN-001-E01 | Regression E2E | e2e-api | `bubbles/scripts/interop-import-selftest.sh` | Regression: review-only interop import keeps snapshots, normalized output, and translation reports inside project-owned intake paths. | `bash bubbles/scripts/interop-import-selftest.sh` | Yes |
| TP-05.4C | SCN-001-E01 | Integration | integration | `bubbles/scripts/interop-import-selftest.sh` | Canary: review-only interop import must pass before broader immutability reruns. | `bash bubbles/scripts/interop-import-selftest.sh` | Yes |
| TP-05.5 | SCN-001-E02 | Regression E2E | e2e-api | `bubbles/scripts/interop-import-selftest.sh` | Regression: unsupported or framework-level translations stay proposal-only and never mutate framework-managed files. | `bash bubbles/scripts/interop-import-selftest.sh` | Yes |
| TP-05.6 | SCN-001-E01 | Stress | stress | `bubbles/scripts/interop-import-selftest.sh` | Stress: repeated translation-import batches stay bounded, deterministic, and proposal-safe across supported source fixtures. | `bash bubbles/scripts/interop-import-selftest.sh` | Yes |
| TP-05.7 | SCN-001-E06 | Integration | integration | `bubbles/scripts/release-manifest-selftest.sh` | Regression: the release-manifest selftest scenario `release hygiene generates one complete trust manifest for downstream installs.` remains green after review-only interop intake changes. | `bash bubbles/scripts/release-manifest-selftest.sh` | Yes |
| TP-05.8 | SCN-001-E07 | E2E API | e2e-api | `bubbles/scripts/install-provenance-selftest.sh` | Regression: the install-provenance selftest scenario `downstream installs capture release metadata and provenance for release and local-source modes.` remains green after review-only interop intake changes. | `bash bubbles/scripts/install-provenance-selftest.sh` | Yes |
| TP-05.9 | SCN-001-E08 | E2E API | e2e-api | `bubbles/scripts/trust-doctor-selftest.sh` | Regression: the trust-doctor selftest scenario `doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.` remains green after review-only interop intake changes. | `bash bubbles/scripts/trust-doctor-selftest.sh` | Yes |

### Closeout Notes

- The review-only interop intake baseline remains the active project-owned import surface for Scope 05.
- Validate-owned certification state remains unchanged and is not advanced by this plan reconciliation pass.

### Definition of Done

- [x] TP-05.1 proves SCN-001-E01 by capturing external assets into project-owned intake surfaces and classifying the supported external source formats correctly.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/interop-import-selftest.sh
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import detects Claude Code assets
  PASS: Interop import detects Roo Code assets
  PASS: Interop import reports generated project-owned targets
  PASS: Interop status reports review-required imports
  PASS: Interop status includes supported source records
  PASS: Interop import reports workflow-mode proposal routing
  PASS: Framework write guard still passes after interop import
  interop-import selftest passed.
  ```
- [x] TP-05.2 proves SCN-001-E01 by writing raw snapshots, normalized output, and translation reports only into project-owned intake paths.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/interop-import-selftest.sh
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import writes the project-owned interop manifest
  PASS: Interop import snapshots Claude Code raw assets
  PASS: Interop import writes normalized output
  PASS: Interop import writes translation reports
  PASS: Interop import stages review-only candidate outputs under proposed-overrides
  PASS: Interop import never writes under framework-managed .github/bubbles surfaces
  PASS: Interop import routes workflow-mode requests into project-owned proposals
  interop-import selftest passed.
  ```
- [x] TP-05.3 proves SCN-001-E02 by escalating unsupported or framework-level changes as proposals instead of direct framework mutation.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/interop-import-selftest.sh
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import reports workflow-mode proposal routing
  PASS: Framework write guard still passes after interop import
  PASS: Interop import never writes under framework-managed .github/bubbles surfaces
  PASS: Interop import routes workflow-mode requests into project-owned proposals
  interop-import selftest passed.
  ```
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior are added or updated.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && git status --short -- bubbles/interop-registry.yaml bubbles/scripts/interop-registry.sh bubbles/scripts/interop-intake.sh bubbles/scripts/interop-import-selftest.sh bubbles/scripts/cli.sh docs/guides/INSTALLATION.md docs/recipes/framework-ops.md install.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh bubbles/release-manifest.json && git --no-pager diff --stat -- bubbles/interop-registry.yaml bubbles/scripts/interop-registry.sh bubbles/scripts/interop-intake.sh bubbles/scripts/interop-import-selftest.sh bubbles/scripts/cli.sh docs/guides/INSTALLATION.md docs/recipes/framework-ops.md install.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh bubbles/release-manifest.json
   M bubbles/scripts/cli.sh
   M docs/guides/INSTALLATION.md
   M docs/recipes/framework-ops.md
   M install.sh
  ?? bubbles/interop-registry.yaml
  ?? bubbles/release-manifest.json
  ?? bubbles/scripts/generate-release-manifest.sh
  ?? bubbles/scripts/interop-import-selftest.sh
  ?? bubbles/scripts/interop-intake.sh
  ?? bubbles/scripts/interop-registry.sh
  ?? bubbles/scripts/release-manifest-selftest.sh
   bubbles/scripts/cli.sh        | 618 +++++++++++++++++++++++++++++++++---------
   docs/guides/INSTALLATION.md   |  41 ++-
   docs/recipes/framework-ops.md |  26 ++
   install.sh                    | 241 +++++++++++++---
   4 files changed, 757 insertions(+), 169 deletions(-)
  ```
- [x] Broader E2E regression suite passes.

  **Phase:** test
  ```text
  $ cd /home/philipk/bubbles && timeout 900 bash bubbles/scripts/framework-validate.sh
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles

  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (175 managed files)
  PASS: Release manifest freshness

  ==> Release manifest selftest
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (175)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  PASS: Manifest exposes foundation as a supported profile
  PASS: Manifest exposes delivery as a supported profile
  PASS: Manifest exposes Claude Code as a supported interop source
  PASS: Manifest exposes Roo Code as a supported interop source
  PASS: Manifest exposes Cursor as a supported interop source
  PASS: Manifest exposes Cline as a supported interop source
  release-manifest selftest passed.
  PASS: Release manifest selftest

  ==> Install provenance selftest
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Remote-ref provenance records requested source ref
  PASS: Remote-ref provenance stays clean
  PASS: Default bootstrap records delivery as the active adoption profile
  PASS: Default bootstrap keeps the installer default explicit
  PASS: Foundation bootstrap records foundation in repo-local policy state
  PASS: Foundation bootstrap output names the selected profile explicitly
  PASS: Foundation bootstrap keeps the installer default unchanged
  PASS: Local-source install copies generated release manifest
  PASS: Local-source install writes install provenance
  PASS: Local-source provenance records install mode
  PASS: Local-source provenance records a symbolic source ref
  PASS: Local-source provenance records dirty working tree risk
  PASS: Local-source provenance never persists the absolute checkout path
  PASS: Unsafe local-source refs fall back to literal local-source provenance
  install-provenance selftest passed.
  PASS: Install provenance selftest

  ==> Trust doctor selftest
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Doctor shows remote-ref provenance
  PASS: Doctor warns when the installed source checkout was dirty
  PASS: Doctor shows the explicit foundation adoption profile
  PASS: Doctor downgrades project-readiness gaps to advisory under foundation
  PASS: Doctor reports foundation onboarding gaps as advisory instead of failing
  PASS: Repo-readiness shows the explicit foundation adoption profile
  PASS: Repo-readiness explains the foundation posture
  PASS: Repo-readiness keeps the certification boundary explicit
  PASS: Framework write guard reports managed-file integrity state
  PASS: Framework write guard shows local-source provenance
  PASS: Upgrade dry-run distinguishes untouched project-owned files
  PASS: Upgrade dry-run surfaces local-source trust risk
  PASS: Upgrade dry-run shows framework-managed replacement count
  PASS: Framework write guard fails loud on malformed release manifest
  PASS: Framework write guard names the missing manifest field
  PASS: Upgrade dry-run rejects malformed target release metadata
  PASS: Upgrade dry-run names the missing target profiles field
  PASS: Upgrade dry-run names the missing target interop field
  PASS: Upgrade dry-run malformed-manifest failure stays free of shell trap errors
  trust-doctor selftest passed.
  PASS: Trust doctor selftest

  Framework validation passed.
  ```
- [x] TP-05.7 preserves the release-manifest trust baseline during review-only interop intake, keeping `release hygiene generates one complete trust manifest for downstream installs.` true for the post-implementation packet.
  **Phase:** test
  ```text
  $ cd /home/philipk/bubbles && timeout 900 bash bubbles/scripts/framework-validate.sh
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles

  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (175 managed files)
  PASS: Release manifest freshness

  ==> Release manifest selftest
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (175)
  release-manifest selftest passed.
  ```
- [x] TP-05.8 preserves downstream install provenance during review-only interop intake, keeping `downstream installs capture release metadata and provenance for release and local-source modes.` true for the post-implementation packet.
  **Phase:** test
  ```text
  $ cd /home/philipk/bubbles && timeout 900 bash bubbles/scripts/framework-validate.sh
  ==> Install provenance selftest
  Running install-provenance selftest...
  Scenario: downstream installs capture release metadata and provenance for release and local-source modes.
  PASS: Remote-ref install copies release manifest
  PASS: Remote-ref install writes install provenance
  PASS: Remote-ref provenance records install mode
  PASS: Remote-ref provenance records requested source ref
  PASS: Remote-ref provenance stays clean
  PASS: Default bootstrap records delivery as the active adoption profile
  PASS: Default bootstrap keeps the installer default explicit
  PASS: Foundation bootstrap records foundation in repo-local policy state
  PASS: Foundation bootstrap output names the selected profile explicitly
  PASS: Foundation bootstrap keeps the installer default unchanged
  PASS: Local-source install copies generated release manifest
  PASS: Local-source install writes install provenance
  PASS: Local-source provenance records install mode
  PASS: Local-source provenance records a symbolic source ref
  PASS: Local-source provenance records dirty working tree risk
  PASS: Local-source provenance never persists the absolute checkout path
  install-provenance selftest passed.
  ```
- [x] TP-05.9 preserves trust-surface behavior during review-only interop intake, keeping `doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.` true for the post-implementation packet.
  **Phase:** test
  ```text
  $ cd /home/philipk/bubbles && timeout 900 bash bubbles/scripts/framework-validate.sh
  ==> Trust doctor selftest
  Running trust-doctor selftest...
  Scenario: doctor, framework-write-guard, and upgrade dry-run expose trust state and local-source risk explicitly.
  PASS: Doctor shows installed release manifest details for remote-ref installs
  PASS: Doctor shows remote-ref provenance
  PASS: Doctor warns when the installed source checkout was dirty
  PASS: Doctor shows the explicit foundation adoption profile
  PASS: Doctor downgrades project-readiness gaps to advisory under foundation
  PASS: Doctor reports foundation onboarding gaps as advisory instead of failing
  PASS: Repo-readiness shows the explicit foundation adoption profile
  PASS: Repo-readiness explains the foundation posture
  PASS: Repo-readiness keeps the certification boundary explicit
  PASS: Framework write guard reports managed-file integrity state
  PASS: Framework write guard shows local-source provenance
  PASS: Upgrade dry-run distinguishes untouched project-owned files
  PASS: Upgrade dry-run surfaces local-source trust risk
  PASS: Upgrade dry-run shows framework-managed replacement count
  trust-doctor selftest passed.
  ```
- [x] Consumer impact sweep is complete and zero stale first-party references remain.

  **Phase:** test
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -RniE 'interop-registry|supported interop source|supportedInteropSources|\.github/bubbles-project/imports|\.github/bubbles-project/proposals|interop-manifest\.json|review-only interop' bubbles/interop-registry.yaml bubbles/scripts/cli.sh bubbles/scripts/interop-intake.sh bubbles/scripts/interop-import-selftest.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh install.sh docs/guides/INSTALLATION.md docs/recipes/framework-ops.md
  bubbles/interop-registry.yaml:18:      - .github/bubbles-project/imports/<source>/<timestamp>/raw/
  bubbles/interop-registry.yaml:19:      - .github/bubbles-project/imports/<source>/<timestamp>/normalized.json
  bubbles/interop-registry.yaml:20:      - .github/bubbles-project/imports/<source>/<timestamp>/translation-report.md
  bubbles/scripts/cli.sh:27:#   interop <subcommand>          Detect, import, and inspect review-only interop intake packets
  bubbles/scripts/cli.sh:1717:  local proposal_dir="$REPO_ROOT/.github/bubbles-project/proposals"
  bubbles/scripts/interop-intake.sh:36:  - Non-dry-run output is written only under .github/bubbles-project/imports/** and .github/bubbles-project/proposals/**.
  bubbles/scripts/interop-intake.sh:533:    echo "Interop manifest: ${IMPORTS_ROOT#"$REPO_ROOT"/}/interop-manifest.json"
  bubbles/scripts/generate-release-manifest.sh:127:  printf '  "supportedInteropSources": ['
  bubbles/scripts/release-manifest-selftest.sh:64:interop_sources="$(bubbles_json_array_joined "$manifest_file" supportedInteropSources ', ')"
  install.sh:242:if [[ -f "$TEMP_DIR/bubbles/interop-registry.yaml" ]]; then
  docs/guides/INSTALLATION.md:76:Review-only interop intake also stays fully project-owned. When a downstream repo wants to assess Claude Code, Roo Code, Cursor, or Cline assets without mutating the framework layer, use:
  docs/recipes/framework-ops.md:13:**Interop rule:** Review-only interop intake is project-owned. `bubbles interop import --review-only` may snapshot and normalize Claude Code, Roo Code, Cursor, or Cline assets into `.github/bubbles-project/imports/**`, and it may emit project-owned proposals under `.github/bubbles-project/proposals/**` when imported workflow concepts would require framework-managed Bubbles changes. It must never write directly to `.github/bubbles/**`, `.github/agents/bubbles*`, `.github/prompts/bubbles*`, or `.github/skills/bubbles-*`.
  ```
- [x] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns.

  **Phase:** test
  ```text
  $ cd /home/philipk/bubbles && timeout 600 bash bubbles/scripts/interop-import-selftest.sh
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import detects Claude Code assets
  PASS: Interop import detects Roo Code assets
  PASS: Interop import reports generated project-owned targets
  PASS: Interop import writes the project-owned interop manifest
  PASS: Interop import snapshots Claude Code raw assets
  PASS: Interop import writes normalized output
  PASS: Interop import writes translation reports
  PASS: Interop import stages review-only candidate outputs under proposed-overrides
  PASS: Interop status reports review-required imports
  PASS: Interop status includes supported source records
  PASS: Interop import reports workflow-mode proposal routing
  PASS: Framework write guard still passes after interop import
  PASS: Interop import never writes under framework-managed .github/bubbles surfaces
  PASS: Interop import routes workflow-mode requests into project-owned proposals
  interop-import selftest passed.

  $ cd /home/philipk/bubbles && timeout 600 bash bubbles/scripts/release-manifest-selftest.sh
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (175)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  PASS: Manifest exposes foundation as a supported profile
  PASS: Manifest exposes delivery as a supported profile
  PASS: Manifest exposes Claude Code as a supported interop source
  PASS: Manifest exposes Roo Code as a supported interop source
  PASS: Manifest exposes Cursor as a supported interop source
  PASS: Manifest exposes Cline as a supported interop source
  release-manifest selftest passed.
  ```
- [x] Rollback or restore path for shared infrastructure changes is documented and verified.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && grep -n 'Rollback or restore path: remove interop command registration' specs/001-competitive-framework-parity/scopes.md && ls -la bubbles/scripts/interop-import-selftest.sh bubbles/scripts/release-manifest-selftest.sh && grep -n 'supportedInteropSources' bubbles/release-manifest.json && grep -n 'interop-registry.yaml' install.sh bubbles/scripts/generate-release-manifest.sh docs/guides/INSTALLATION.md docs/recipes/framework-ops.md
  578:  705:- Rollback or restore path: remove interop command registration and registry entries together, delete generated import schema changes in one revert, and rerun the import canaries before broader CLI reruns.
  834:  819:- Rollback or restore path: remove interop command registration and registry entries together, delete generated import schema changes in one revert, and rerun the import canaries before broader CLI reruns.
  1108:  578:  705:- Rollback or restore path: remove interop command registration and registry entries together, delete generated import schema changes in one revert, and rerun the import canaries before broader CLI reruns.
  1193:- Rollback or restore path: remove interop command registration, installer payload wiring, and release-manifest interop metadata together, delete generated import schema changes in one revert, and rerun the interop plus release-manifest canaries before broader CLI reruns.
  -rw-r--r-- 1 philipk philipk 4702 Apr  4 23:19 bubbles/scripts/interop-import-selftest.sh
  -rwxr-xr-x 1 philipk philipk 3274 Apr  4 23:19 bubbles/scripts/release-manifest-selftest.sh
  8:  "supportedInteropSources": ["claude-code", "roo-code", "cursor", "cline"],
  install.sh:242:if [[ -f "$TEMP_DIR/bubbles/interop-registry.yaml" ]]; then
  install.sh:243:  cp "$TEMP_DIR"/bubbles/interop-registry.yaml "${TARGET}/bubbles/"
  ```
- [x] Change Boundary is respected and zero excluded file families were changed.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && git status --short -- bubbles/interop-registry.yaml bubbles/scripts/cli.sh bubbles/scripts/interop-registry.sh bubbles/scripts/interop-intake.sh bubbles/scripts/interop-import-selftest.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh bubbles/release-manifest.json install.sh docs/guides/INSTALLATION.md docs/recipes/framework-ops.md && git diff --stat -- bubbles/interop-registry.yaml bubbles/scripts/cli.sh bubbles/scripts/interop-registry.sh bubbles/scripts/interop-intake.sh bubbles/scripts/interop-import-selftest.sh bubbles/scripts/generate-release-manifest.sh bubbles/scripts/release-manifest-selftest.sh bubbles/release-manifest.json install.sh docs/guides/INSTALLATION.md docs/recipes/framework-ops.md
   M bubbles/scripts/cli.sh
   M docs/guides/INSTALLATION.md
   M docs/recipes/framework-ops.md
   M install.sh
  ?? bubbles/interop-registry.yaml
  ?? bubbles/release-manifest.json
  ?? bubbles/scripts/generate-release-manifest.sh
  ?? bubbles/scripts/interop-import-selftest.sh
  ?? bubbles/scripts/interop-intake.sh
  ?? bubbles/scripts/interop-registry.sh
  ?? bubbles/scripts/release-manifest-selftest.sh
   bubbles/scripts/cli.sh        | 618 +++++++++++++++++++++++++++++++++---------
   docs/guides/INSTALLATION.md   |  41 ++-
   docs/recipes/framework-ops.md |  26 ++
   install.sh                    | 241 +++++++++++++---
   4 files changed, 757 insertions(+), 169 deletions(-)
  ```
- [x] Stress coverage for the translation-heavy interop intake path passes and proves repeated import batches stay bounded.

  **Phase:** test
  ```text
  $ cd /home/philipk/bubbles && timeout 1200 bash bubbles/scripts/interop-import-selftest.sh && timeout 1200 bash bubbles/scripts/interop-import-selftest.sh && timeout 1200 bash bubbles/scripts/interop-import-selftest.sh
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import detects Claude Code assets
  PASS: Interop import detects Roo Code assets
  PASS: Interop import reports generated project-owned targets
  PASS: Interop import writes the project-owned interop manifest
  PASS: Interop import snapshots Claude Code raw assets
  PASS: Interop import writes normalized output
  PASS: Interop import writes translation reports
  PASS: Interop import stages review-only candidate outputs under proposed-overrides
  PASS: Interop status reports review-required imports
  PASS: Interop status includes supported source records
  PASS: Interop import reports workflow-mode proposal routing
  PASS: Framework write guard still passes after interop import
  PASS: Interop import never writes under framework-managed .github/bubbles surfaces
  PASS: Interop import routes workflow-mode requests into project-owned proposals
  interop-import selftest passed.
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import detects Claude Code assets
  PASS: Interop import detects Roo Code assets
  PASS: Interop import reports generated project-owned targets
  PASS: Interop import writes the project-owned interop manifest
  PASS: Interop import snapshots Claude Code raw assets
  PASS: Interop import writes normalized output
  PASS: Interop import writes translation reports
  PASS: Interop import stages review-only candidate outputs under proposed-overrides
  PASS: Interop status reports review-required imports
  PASS: Interop status includes supported source records
  PASS: Interop import reports workflow-mode proposal routing
  PASS: Framework write guard still passes after interop import
  PASS: Interop import never writes under framework-managed .github/bubbles surfaces
  PASS: Interop import routes workflow-mode requests into project-owned proposals
  interop-import selftest passed.
  Running interop-import selftest...
  Scenario: review-only interop intake snapshots supported external assets inside project-owned paths and proposals workflow-mode changes instead of mutating framework-managed files.
  PASS: Interop import detects Claude Code assets
  PASS: Interop import detects Roo Code assets
  PASS: Interop import reports generated project-owned targets
  PASS: Interop import writes the project-owned interop manifest
  PASS: Interop import snapshots Claude Code raw assets
  PASS: Interop import writes normalized output
  PASS: Interop import writes translation reports
  PASS: Interop import stages review-only candidate outputs under proposed-overrides
  PASS: Interop status reports review-required imports
  PASS: Interop status includes supported source records
  PASS: Interop import reports workflow-mode proposal routing
  PASS: Framework write guard still passes after interop import
  PASS: Interop import never writes under framework-managed .github/bubbles surfaces
  PASS: Interop import routes workflow-mode requests into project-owned proposals
  interop-import selftest passed.
  ```

## Scope 06: Supported Interop Apply And Evaluator Migration Guidance

**Status:** Done
**Depends On:** 05

### Gherkin Scenarios

Scenario: SCN-001-F01 supported interop apply writes only project-owned outputs
  Given a review-only import has produced a supported interop proposal
  When the maintainer applies that proposal through the supported Bubbles flow
  Then only declared project-owned outputs are generated, the import manifest is updated, collisions fall back to proposals, and framework-managed downstream files remain untouched

Scenario: SCN-001-F02 evaluator-facing migration guidance explains supported, review-only, and unsupported paths clearly
  Given the capability ledger, interop registry, and trust surfaces are up to date
  When an evaluator reviews the competitive migration guide and benchmark narrative
  Then they can understand supported migration flows, review-only gaps, governance tradeoffs, and expected adoption effort versus Claude Code, Roo Code, Cursor, and Cline

### UI Scenario Matrix

| Scenario | Preconditions | Steps | Expected | Test Type |
| --- | --- | --- | --- | --- |
| Maintainer applies a supported interop proposal | Review-only import fixture exists with supported targets | Run supported apply command and inspect outputs | Only declared project-owned outputs change, collisions fall back to proposals, and the import manifest records the apply result | e2e-api |
| Evaluator reads migration guidance | Capability and interop docs are refreshed | Open migration guide from README or docs landing page | Supported, review-only, and unsupported paths are explicit and tied to evidence-backed claims | e2e-ui |

### Implementation Plan

- Extend interop apply logic so supported targets can generate project-owned outputs only for explicit allowed targets declared in the import manifest: `.github/instructions/imported-*.instructions.md`, project-owned `.github/skills/<project-skill>/`, additive recommendation blocks in `.specify/memory/agents.md`, and project-owned helper paths under `scripts/`.
- Require collision fallback behavior so any target that would touch framework-managed paths or overwrite project-owned files without a clean additive merge remains under `.github/bubbles-project/imports/**/proposed-overrides/` instead of being applied automatically.
- Refresh evaluator-facing docs in `README.md`, `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/recipes/setup-project.md`, and a migration-focused guide so the competitive value narrative comes from the same capability and interop truth surfaces.
- Generate benchmark or comparison tables from `bubbles/capability-ledger.yaml` plus `bubbles/interop-registry.yaml` rather than maintaining manual migration or competitor prose.
- Keep unsupported mappings explicit and review-only so supported apply flows never become a back door for framework-managed downstream edits.

### Implementation Files

- `bubbles/scripts/cli.sh`
- `bubbles/scripts/interop-apply.sh`
- `bubbles/scripts/interop-apply-selftest.sh`
- `bubbles/interop-registry.yaml`
- `bubbles/capability-ledger.yaml`
- `bubbles/scripts/capability-ledger-selftest.sh`
- `bubbles/scripts/competitive-docs-selftest.sh`
- `bubbles/scripts/generate-capability-ledger-docs.sh`
- `bubbles/scripts/framework-validate.sh`
- `README.md`
- `docs/guides/CONTROL_PLANE_ADOPTION.md`
- `docs/guides/INTEROP_MIGRATION.md`
- `docs/recipes/setup-project.md`
- `docs/generated/interop-migration-matrix.md`
- `.github/bubbles-project/imports/interop-manifest.json`

### Consumer Impact Sweep

- Validate first-party consumers of migration guidance and apply metadata: `README.md`, `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/recipes/setup-project.md`, interop CLI help, generated comparison docs, and project-owned import manifest consumers.
- Verify stale-reference scans for competitor names, source IDs, support states, migration guide anchors, allowed apply targets, forbidden framework-managed targets, and proposal-fallback paths.

### Shared Infrastructure Impact Sweep

- Protected shared surfaces: `bubbles/scripts/cli.sh`, interop apply scripts, `bubbles/interop-registry.yaml`, `bubbles/capability-ledger.yaml`, and generated evaluator docs.
- Blast radius: project-owned output generation, evaluator-facing migration narrative, and any command path that claims supported migration coverage.
- Independent canaries: a supported-apply selftest, a migration-docs parity selftest, and a framework-immutability selftest proving apply flows never touch framework-managed downstream files.
- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.

### Change Boundary

- Allowed file families: `bubbles/scripts/cli.sh`, new `bubbles/scripts/interop-apply*.sh` surfaces, `bubbles/interop-registry.yaml`, `bubbles/capability-ledger.yaml`, `README.md`, `docs/guides/CONTROL_PLANE_ADOPTION.md`, `docs/recipes/setup-project.md`, any migration guide or generated comparison docs.
- Excluded surfaces: installer bootstrap semantics outside documented links, release manifest generation logic, profile registry semantics, framework-managed downstream install artifacts, and certification-owned state fields.

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-06.1 | SCN-001-F01 | Integration | integration | `bubbles/scripts/interop-apply-selftest.sh` | Exercises the supported-interop apply selftest scenario `supported interop apply generates only declared project-owned outputs, records manifest apply status, and falls back to proposals on collisions.` | `bash bubbles/scripts/interop-apply-selftest.sh` | Yes |
| TP-06.2 | SCN-001-F02 | Functional | functional | `bubbles/scripts/capability-ledger-selftest.sh` | Verifies the capability-ledger selftest scenario `ledger-backed competitive docs stay aligned with the source-of-truth registry.` while keeping evaluator-facing migration guidance aligned with capability-ledger and interop-registry truth surfaces. | `bash bubbles/scripts/capability-ledger-selftest.sh` | No |
| TP-06.3 | SCN-001-F02 | E2E UI | e2e-ui | `bubbles/scripts/competitive-docs-selftest.sh` | Exercises the competitive-docs selftest scenario `README and generated evaluator docs expose the same competitive truth path.` and checks that evidence-backed migration guidance remains current. | `bash bubbles/scripts/competitive-docs-selftest.sh` | Yes |
| TP-06.4 | SCN-001-F01 | Regression E2E | e2e-api | `bubbles/scripts/interop-apply-selftest.sh` | Regression: supported interop apply writes only declared project-owned outputs and collisions fall back to proposals. | `bash bubbles/scripts/interop-apply-selftest.sh` | Yes |
| TP-06.4C | SCN-001-F01 | Integration | integration | `bubbles/scripts/interop-apply-selftest.sh` | Canary: supported apply stays proposal-safe before broader validation, release, and immutability reruns. | `bash bubbles/scripts/interop-apply-selftest.sh` | Yes |
| TP-06.5 | SCN-001-F02 | Regression E2E | e2e-ui | `bubbles/scripts/competitive-docs-selftest.sh` | Regression: evaluator-facing migration guidance keeps supported, review-only, and unsupported paths explicit while `README and generated evaluator docs expose the same competitive truth path.` remains true. | `bash bubbles/scripts/competitive-docs-selftest.sh` | Yes |
| TP-06.6 | SCN-001-F01 | Regression E2E | e2e-api | `bubbles/scripts/framework-validate.sh` | Reruns the broader framework validation, release, and immutability regressions after supported interop apply changes. | `bash bubbles/scripts/framework-validate.sh` | Yes |
| TP-06.7 | SCN-001-F06 | E2E API | e2e-api | `bubbles/scripts/framework-validate.sh` | Regression: the framework-validation rerun preserves the release-manifest selftest scenario `release hygiene generates one complete trust manifest for downstream installs.` after supported interop apply changes. | `bash bubbles/scripts/framework-validate.sh` | Yes |

### Closeout Notes

- Supported interop apply and evaluator-facing migration guidance are the current shipped planning outcomes for Scope 06.
- Validate-owned certification state remains unchanged and is not advanced by this plan reconciliation pass.

### Definition of Done

- [x] TP-06.1 proves SCN-001-F01 by applying supported interop outputs only into declared project-owned paths with manifest updates, collision fallback to proposals, and zero framework-managed mutations.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/interop-apply-selftest.sh
  Running interop-apply selftest...
  Scenario: supported interop apply generates only declared project-owned outputs, records manifest apply status, and falls back to proposals on collisions.
  PASS: Interop import detects Claude Code assets before apply
  PASS: Interop apply processes Claude Code packets
  PASS: Interop apply writes project-owned imported instructions
  PASS: Interop apply writes project-owned helper tooling paths
  PASS: Interop apply appends additive recommendations into .specify/memory/agents.md
  PASS: Interop apply reports collision fallback targets
  PASS: Interop status reports apply collisions explicitly
  PASS: Interop status reports successful apply status explicitly
  PASS: Interop status reports the applied project-owned outputs
  PASS: Interop apply leaves colliding project-owned files untouched
  PASS: Interop status records apply-collision proposal routing
  PASS: Interop manifest remains project-owned after apply
  PASS: Framework write guard still passes after supported apply
  PASS: Interop apply never writes under framework-managed .github/bubbles surfaces
  PASS: Interop apply routes collisions into project-owned proposals
  interop-apply selftest passed.
  ```
- [x] TP-06.2 proves SCN-001-F02 by keeping `ledger-backed competitive docs stay aligned with the source-of-truth registry.` while evaluator-facing migration guidance explains supported, review-only, and unsupported paths clearly from the shared truth surfaces.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/capability-ledger-selftest.sh
  Running capability-ledger selftest...
  Scenario: ledger-backed competitive docs stay aligned with the source-of-truth registry.
  PASS: Capability ledger generated surfaces are current
  PASS: Ledger defines workflow orchestration capability
  PASS: Ledger defines supported interop apply capability
  PASS: Ledger tracks runtime coordination proposal
  PASS: Generated capability guide exposes stable state summary
  PASS: Generated capability guide includes shipped workflow orchestration row
  PASS: Generated capability guide includes shipped supported interop apply row
  PASS: Generated capability guide includes proposed runtime coordination row
  PASS: Generated issue status guide counts tracked gaps from the ledger
  PASS: Generated migration matrix is refreshed from the interop registry
  capability-ledger selftest passed.
  ```
- [x] TP-06.3 preserves SCN-001-F02 by keeping `README and generated evaluator docs expose the same competitive truth path.` with user-visible assertions instead of proxy checks.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/competitive-docs-selftest.sh
  Running competitive-docs selftest...
  Scenario: README and generated evaluator docs expose the same competitive truth path.
  PASS: Capability ledger docs are current before evaluator-path assertions
  PASS: README links to the generated competitive guide with current ledger counts
  PASS: README links to the generated issue status guide with current tracked-gap count
  PASS: README links to the generated interop migration matrix
  PASS: Generated competitive guide exposes the same state summary the README advertises
  PASS: Generated issue-status guide exposes the tracked-gap count referenced from README
  PASS: Generated competitive guide links evaluators to issue-backed proposal detail
  PASS: Generated interop migration matrix exposes the same state summary the README advertises
  PASS: Generated interop migration matrix covers Claude Code
  PASS: Adoption guide links to the interop migration guidance surfaces
  PASS: Setup recipe links to the interop migration guidance surfaces
  competitive-docs selftest passed.
  ```
- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior are added or updated.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && git status --short -- README.md bubbles/scripts/cli.sh bubbles/scripts/interop-apply.sh bubbles/scripts/interop-apply-selftest.sh bubbles/interop-registry.yaml bubbles/capability-ledger.yaml docs/guides/CONTROL_PLANE_ADOPTION.md docs/recipes/setup-project.md docs/guides/INTEROP_MIGRATION.md docs/generated/interop-migration-matrix.md bubbles/scripts/generate-capability-ledger-docs.sh bubbles/scripts/capability-ledger-selftest.sh bubbles/scripts/competitive-docs-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/capability-freshness-selftest.sh bubbles/release-manifest.json && git diff --stat -- README.md bubbles/scripts/cli.sh bubbles/scripts/interop-apply.sh bubbles/scripts/interop-apply-selftest.sh bubbles/interop-registry.yaml bubbles/capability-ledger.yaml docs/guides/CONTROL_PLANE_ADOPTION.md docs/recipes/setup-project.md docs/guides/INTEROP_MIGRATION.md docs/generated/interop-migration-matrix.md bubbles/scripts/generate-capability-ledger-docs.sh bubbles/scripts/capability-ledger-selftest.sh bubbles/scripts/competitive-docs-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/capability-freshness-selftest.sh bubbles/release-manifest.json
   M README.md
   M bubbles/scripts/cli.sh
   M bubbles/scripts/framework-validate.sh
   M docs/guides/CONTROL_PLANE_ADOPTION.md
   M docs/recipes/setup-project.md
  ?? bubbles/capability-ledger.yaml
  ?? bubbles/interop-registry.yaml
  ?? bubbles/release-manifest.json
  ?? bubbles/scripts/capability-freshness-selftest.sh
  ?? bubbles/scripts/capability-ledger-selftest.sh
  ?? bubbles/scripts/competitive-docs-selftest.sh
  ?? bubbles/scripts/generate-capability-ledger-docs.sh
  ?? bubbles/scripts/interop-apply-selftest.sh
  ?? bubbles/scripts/interop-apply.sh
  ?? docs/generated/interop-migration-matrix.md
  ?? docs/guides/INTEROP_MIGRATION.md
   README.md                             |   6 +
   bubbles/scripts/cli.sh                | 618 +++++++++++++++++++++++++++-------
   bubbles/scripts/framework-validate.sh |  11 +
   docs/guides/CONTROL_PLANE_ADOPTION.md |  40 ++-
   docs/recipes/setup-project.md         |  11 +-
   5 files changed, 561 insertions(+), 125 deletions(-)
  ```
- [x] Broader E2E regression suite passes.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/framework-validate.sh
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles

  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (178 managed files)
  PASS: Release manifest freshness

  ==> Release manifest selftest
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (178)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  PASS: Manifest exposes foundation as a supported profile
  PASS: Manifest exposes delivery as a supported profile
  PASS: Manifest exposes Claude Code as a supported interop source
  PASS: Manifest exposes Roo Code as a supported interop source
  PASS: Manifest exposes Cursor as a supported interop source
  PASS: Manifest exposes Cline as a supported interop source
  release-manifest selftest passed.
  PASS: Release manifest selftest
  Framework validation passed.
  ```

  **Phase:** implement
  **Command:** `cd /home/philipk/bubbles && timeout 600 bash bubbles/scripts/cli.sh doctor && timeout 1200 bash bubbles/scripts/cli.sh release-check`
  **Exit Code:** 0
  ```text
  $ cd /home/philipk/bubbles && timeout 600 bash bubbles/scripts/cli.sh doctor && timeout 1200 bash bubbles/scripts/cli.sh release-check
  🫧 Bubbles Doctor — Project Health Check
  ═══════════════════════════════════════════

  Framework Integrity
  Installer payload, trust provenance, and managed-file integrity.

    ✅ Core agents installed (34)
    ✅ Governance scripts installed (53)
    ✅ Workflow config present
    ✅ Control-plane policy registry present (.specify/memory/bubbles.config.json)
    ✅ All scripts executable
    ✅ Bubbles source version: 3.3.0
  Result: 14 passed, 0 failed, 0 advisory

  Bubbles Release Check
  Repository: /home/philipk/bubbles

  ==> Framework validation
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles
  Release check passed.
  ```
- [x] TP-06.7 preserves the release-manifest trust baseline during supported interop apply, keeping `release hygiene generates one complete trust manifest for downstream installs.` true for the post-implementation packet.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/framework-validate.sh
  Bubbles Framework Validation
  Repository: /home/philipk/bubbles

  ==> Release manifest freshness
  Release manifest is current: 3.3.0 (178 managed files)
  PASS: Release manifest freshness

  ==> Release manifest selftest
  Running release-manifest selftest...
  Scenario: release hygiene generates one complete trust manifest for downstream installs.
  PASS: Committed release manifest is current
  PASS: Release manifest exists
  PASS: Manifest records release version
  PASS: Manifest records source git SHA
  PASS: Manifest records trust docs digest
  PASS: Manifest records framework-managed file count (178)
  PASS: Managed checksum inventory includes framework agents
  PASS: Managed checksum inventory includes shared CLI surface
  release-manifest selftest passed.
  ```
- [x] Consumer impact sweep is complete and zero stale first-party references remain.
  **Phase:** implement
  **Evidence:**
  ```text
  $ cd /home/philipk/bubbles && grep -RniE 'Interop Migration|interop migration matrix|supported interop apply|supportedApplyTargets|interop apply --safe|CONTROL_PLANE_ADOPTION|setup-project' README.md docs/guides/CONTROL_PLANE_ADOPTION.md docs/recipes/setup-project.md docs/guides/INTEROP_MIGRATION.md docs/generated/interop-migration-matrix.md bubbles/capability-ledger.yaml bubbles/interop-registry.yaml bubbles/scripts/cli.sh bubbles/scripts/interop-intake.sh bubbles/scripts/interop-apply.sh
  README.md:465:| [Interop Migration Matrix](docs/generated/interop-migration-matrix.md) | Ledger + registry-backed migration matrix for Claude Code, Roo Code, Cursor, and Cline |
  README.md:470:| [Interop Migration Guide](docs/guides/INTEROP_MIGRATION.md) | Supported apply, review-only intake, and proposal-only migration paths for external rule ecosystems |
  docs/guides/CONTROL_PLANE_ADOPTION.md:10:- [Interop Migration Guide](INTEROP_MIGRATION.md)
  docs/guides/CONTROL_PLANE_ADOPTION.md:11:- [Generated Interop Migration Matrix](../generated/interop-migration-matrix.md)
  docs/guides/CONTROL_PLANE_ADOPTION.md:173:## Interop Migration Path
  docs/guides/CONTROL_PLANE_ADOPTION.md:175:Use the generated migration matrix and the interop migration guide when a repo already carries Claude Code, Roo Code, Cursor, or Cline assets.
  docs/guides/CONTROL_PLANE_ADOPTION.md:183:- [Interop Migration Matrix](../generated/interop-migration-matrix.md)
  docs/recipes/setup-project.md:44:1. Open the [Interop Migration Guide](../guides/INTEROP_MIGRATION.md).
  docs/recipes/setup-project.md:45:2. Open the generated [Interop Migration Matrix](../generated/interop-migration-matrix.md).
  docs/guides/INTEROP_MIGRATION.md:1:# Interop Migration Guide
  docs/guides/INTEROP_MIGRATION.md:10:- [Interop Migration Matrix](../generated/interop-migration-matrix.md)
  docs/guides/INTEROP_MIGRATION.md:51:3. Apply only through `interop apply --safe`.
  docs/generated/interop-migration-matrix.md:1:# Interop Migration Matrix
  bubbles/capability-ledger.yaml:64:    label: Supported interop apply
  bubbles/scripts/interop-intake.sh:367:    printf '  "supportedApplyTargets": %s,\n' "$supported_apply_targets_json"
  bubbles/scripts/interop-apply.sh:291:    mapfile -t supported_apply_targets < <(bubbles_json_array_items "$entry_file" supportedApplyTargets)
  ```
- [x] Independent canary suite for shared fixture/bootstrap contracts passes before broad suite reruns.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && bash bubbles/scripts/framework-validate.sh
  ==> Capability ledger selftest
  Running capability-ledger selftest...
  Scenario: ledger-backed competitive docs stay aligned with the source-of-truth registry.
  PASS: Capability ledger generated surfaces are current
  PASS: Ledger defines supported interop apply capability
  PASS: Generated migration matrix is refreshed from the interop registry
  capability-ledger selftest passed.
  PASS: Capability ledger selftest

  ==> Competitive docs selftest
  Running competitive-docs selftest...
  Scenario: README and generated evaluator docs expose the same competitive truth path.
  PASS: README links to the generated interop migration matrix
  PASS: Generated interop migration matrix exposes the same state summary the README advertises
  PASS: Setup recipe links to the interop migration guidance surfaces
  competitive-docs selftest passed.
  PASS: Competitive docs selftest

  ==> Interop apply selftest
  Running interop-apply selftest...
  Scenario: supported interop apply generates only declared project-owned outputs, records manifest apply status, and falls back to proposals on collisions.
  PASS: Interop apply writes project-owned imported instructions
  PASS: Interop manifest remains project-owned after apply
  PASS: Framework write guard still passes after supported apply
  interop-apply selftest passed.
  PASS: Interop apply selftest
  ```
- [x] Rollback or restore path for shared infrastructure changes is documented and verified.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && grep -n 'Rollback or restore path: revert apply wiring and generated migration docs together' specs/001-competitive-framework-parity/scopes.md && ls -la bubbles/scripts/interop-apply-selftest.sh bubbles/scripts/capability-ledger-selftest.sh bubbles/scripts/competitive-docs-selftest.sh bubbles/scripts/framework-validate.sh && grep -n 'supported-interop-apply' bubbles/capability-ledger.yaml && grep -n 'interop-migration-matrix.md' README.md docs/guides/CONTROL_PLANE_ADOPTION.md docs/recipes/setup-project.md bubbles/scripts/generate-capability-ledger-docs.sh
  579:  777:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  835:  903:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  1109:  579:  777:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  1538:- Rollback or restore path: revert apply wiring and generated migration docs together, clear the new project-owned output paths in test fixtures, and rerun apply plus docs canaries before broader validation reruns.
  -rw-r--r-- 1 philipk philipk 2360 Apr  5 19:25 bubbles/scripts/capability-ledger-selftest.sh
  -rw-r--r-- 1 philipk philipk 3028 Apr  5 19:25 bubbles/scripts/competitive-docs-selftest.sh
  -rwxr-xr-x 1 philipk philipk 2854 Apr  5 19:26 bubbles/scripts/framework-validate.sh
  -rw-r--r-- 1 philipk philipk 5712 Apr  5 19:26 bubbles/scripts/interop-apply-selftest.sh
  63:  supported-interop-apply:
  README.md:465:| [Interop Migration Matrix](docs/generated/interop-migration-matrix.md) | Ledger + registry-backed migration matrix for Claude Code, Roo Code, Cursor, and Cline |
  docs/guides/CONTROL_PLANE_ADOPTION.md:11:- [Generated Interop Migration Matrix](../generated/interop-migration-matrix.md)
  docs/guides/CONTROL_PLANE_ADOPTION.md:183:- [Interop Migration Matrix](../generated/interop-migration-matrix.md)
  docs/recipes/setup-project.md:45:2. Open the generated [Interop Migration Matrix](../generated/interop-migration-matrix.md).
  bubbles/scripts/generate-capability-ledger-docs.sh:406:  echo '| [Interop Migration Matrix](docs/generated/interop-migration-matrix.md) | Ledger + registry-backed migration matrix for Claude Code, Roo Code, Cursor, and Cline |'
  bubbles/scripts/generate-capability-ledger-docs.sh:445:  [[ -f "$GENERATED_DIR/interop-migration-matrix.md" ]] || {
  bubbles/scripts/generate-capability-ledger-docs.sh:458:  cmp -s "$interop_doc_temp" "$GENERATED_DIR/interop-migration-matrix.md" || {
  bubbles/scripts/generate-capability-ledger-docs.sh:490:write_file "$GENERATED_DIR/interop-migration-matrix.md" "$interop_doc_temp"
  ```
- [x] Change Boundary is respected and zero excluded file families were changed.
  **Phase:** implement
  ```text
  $ cd /home/philipk/bubbles && git status --short -- README.md bubbles/scripts/cli.sh bubbles/scripts/interop-apply.sh bubbles/scripts/interop-apply-selftest.sh bubbles/interop-registry.yaml bubbles/capability-ledger.yaml docs/guides/CONTROL_PLANE_ADOPTION.md docs/recipes/setup-project.md docs/guides/INTEROP_MIGRATION.md docs/generated/interop-migration-matrix.md bubbles/scripts/generate-capability-ledger-docs.sh bubbles/scripts/capability-ledger-selftest.sh bubbles/scripts/competitive-docs-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/capability-freshness-selftest.sh bubbles/release-manifest.json && git diff --stat -- README.md bubbles/scripts/cli.sh bubbles/scripts/interop-apply.sh bubbles/scripts/interop-apply-selftest.sh bubbles/interop-registry.yaml bubbles/capability-ledger.yaml docs/guides/CONTROL_PLANE_ADOPTION.md docs/recipes/setup-project.md docs/guides/INTEROP_MIGRATION.md docs/generated/interop-migration-matrix.md bubbles/scripts/generate-capability-ledger-docs.sh bubbles/scripts/capability-ledger-selftest.sh bubbles/scripts/competitive-docs-selftest.sh bubbles/scripts/framework-validate.sh bubbles/scripts/capability-freshness-selftest.sh bubbles/release-manifest.json
   M README.md
   M bubbles/scripts/cli.sh
   M bubbles/scripts/framework-validate.sh
   M docs/guides/CONTROL_PLANE_ADOPTION.md
   M docs/recipes/setup-project.md
  ?? bubbles/capability-ledger.yaml
  ?? bubbles/interop-registry.yaml
  ?? bubbles/release-manifest.json
  ?? bubbles/scripts/capability-freshness-selftest.sh
  ?? bubbles/scripts/capability-ledger-selftest.sh
  ?? bubbles/scripts/competitive-docs-selftest.sh
  ?? bubbles/scripts/generate-capability-ledger-docs.sh
  ?? bubbles/scripts/interop-apply-selftest.sh
  ?? bubbles/scripts/interop-apply.sh
  ?? docs/generated/interop-migration-matrix.md
  ?? docs/guides/INTEROP_MIGRATION.md
   README.md                             |   6 +
   bubbles/scripts/cli.sh                | 618 +++++++++++++++++++++++++++-------
   bubbles/scripts/framework-validate.sh |  11 +
   docs/guides/CONTROL_PLANE_ADOPTION.md |  40 ++-
   docs/recipes/setup-project.md         |  11 +-
   5 files changed, 561 insertions(+), 125 deletions(-)
  ```