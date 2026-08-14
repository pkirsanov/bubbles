# IMP-042 - Assurance-Preserving Lightweight Execution And Framework Cleanup

**Status:** PROPOSED (not yet applied) - awaiting owner review.
**Surface:** framework-health (G125) - human-reviewed. NO auto-mutation of `bubbles/*` until approved.
**Motivation:** Deep source, runtime, and external-pattern review of clean commit `09a8fc87033940721d8e112f03a838c305a50018` on 2026-08-13.
**Verified gaps addressed:** PERF-1 through PERF-5, WIP-4, COV-14 through COV-16, REG-9 through REG-12, COST-8, DOC-6, EV-9, HO-3.

## Executive Decision

Bubbles must keep full assurance while removing repeated work.

The framework already has useful primitives. It has validation tiers, changed-only selection, a result cache, test-impact planning, phase relevance, compaction, gate telemetry, and durable state. Several primitives stop before the execution boundary. Agent prose must still remember to call them, and the validation harness lacks declared dependencies.

This proposal adds one deterministic execution model:

1. Declare every check and workflow phase as a typed action.
2. Hash every declared input before reusing a result.
3. Run the smallest affected closure during repair loops.
4. Batch independent heavy work behind bounded parallel groups.
5. Run one cold full gate for the final exact release candidate.
6. Delete or demote only assets whose consumers are mechanically disproven.

The proposal does not weaken anti-fabrication, test substance, status ceilings, repository binding, or validate-owned certification.

## Provenance

### Repository Evidence

- Reviewed repository: `/Users/pkirsanov/Projects/bubbles`.
- Reviewed commit: `09a8fc87033940721d8e112f03a838c305a50018`.
- The worktree carried no changes while evidence was collected.
- The only later working-tree changes are this proposal and its index row.
- `origin/main` advanced to `a5e438c9e2b9963a8ec3a56c88c3ab2384ac22d6` during authoring.
- That commit changed scenario-compile lint files and the release manifest only.
- A targeted diff showed no overlap with any manifest entry cited here.
- Runtime latency input: `.specify/runtime/framework-events.jsonl`.
- Capability input: `bubbles/capability-ledger.yaml`.
- Workflow input: `bubbles/workflows.yaml` and `bubbles/workflows/modes.yaml`.
- Validation input: `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/release-check.sh`, and focused selftests.

### Executed Measurements

- Exact-commit core validation passed in 109 seconds.
- It executed 17 checks and skipped 288 checks.
- ShellCheck live validation took 41 seconds.
- Its selftest took another 41 seconds.
- Those two checks consumed 82 of 109 seconds.
- The bounded evidence block has SHA-256 `74a551bceb22ba50b8ca0257494267a70759967489fd317448e723227237d8d7`.
- Five successful recent core runs took 109 to 111 seconds.
- Three successful recent full runs took 1,883 to 2,081 seconds.
- Four successful recent release checks took 1,962 to 2,111 seconds.
- Focused selftests passed for tiering, changed-only selection, test-impact planning, phase relevance, compaction, and gate-hit logging.
- Selftest coverage reported 238 selftests as 219 enumerated, 17 discovered, and 2 denied.
- Governance indexing scanned 185 docs across 45 indexes and found zero orphans.
- Capability freshness reported 23 shipped capabilities and 78 present consumer paths.
- ShellCheck lints 516 tracked shell files in a single invocation.
- No top-level shell script under `bubbles/scripts/` lacked its executable bit.

### Direct Discriminators

- `mode-resolver.sh review action:readiness-synthesis target:system` exited 0.
- Passing the same v7 form as one argv token exited 1.
- `mode-resolver.sh --list-modes` emitted `phaseRelevance` as a mode.
- `cli.sh docs-registry effective` omitted every `requiredSections` list.
- The `framework-default` projection omitted the same lists.
- The effective registry redirects architecture and development to `README.md`.
- It still requires `docs/API.md`, `docs/Testing.md`, `docs/Deployment.md`, and `docs/Operations.md`. None of those files exist.
- The release manifest classifies `judge-adapter-contract-selftest.sh` as managed.
- The same manifest classifies `eval-harness.sh` as source-only.
- The local gate-hit log contains 112 run records and zero gate outcome records.
- Those run records came from unresolved transition-guard fixtures.
- That log is runtime-local, so a fresh clone starts with no history.

### Adversarial Re-Review

A second pass tried to falsify this proposal against the same tree.

- Prompt shims are one-to-one with agents. No agent lacks a shim and no shim lacks an agent.
- `test-impact-plan.sh` and `phase-relevance-resolve.sh` have no caller except their own selftests.
- The selftest denylist holds exactly two entries, and each is executed through another path.
- `v4.1.0-selftest.sh` runs only through the discovery sweep, so a comment naming it would silence it.
- `test-impact-shadow.sh` already fixes a shadow-first rule that forbids automatic test skipping.
- `generate-framework-stats.sh` verifies its own generated Markdown, so that file is not a free delete.

The pass corrected three counts, two latency targets, one parser recommendation, and one deletion proof. It also added the skip-accounting defect recorded below.

### External Research

- Nx affected execution uses Git plus a dependency graph to select impacted work. See <https://nx.dev/ci/features/affected>.
- Bazel cache keys cover declared actions, inputs, outputs, command lines, and environment. See <https://bazel.build/remote/caching>.
- Pytest supports last-failed, failed-first, and stepwise continuation while preserving a cold CI option. See <https://docs.pytest.org/en/stable/how-to/cache.html>.
- Gradle documentation was unavailable through the review fetcher. No recommendation relies on remembered Gradle behavior.

## Problem (Verified Against Source)

### Validation Cost And Selection

- **PERF-1 - Unstructured check inventory:** `framework-validate.sh` encodes checks as ordered `run_check` calls. A check has no stable ID, declared input closure, execution class, or dependency list.
- **PERF-2 - Duplicate execution:** ShellCheck scans the complete live shell surface twice. Release-manifest freshness also runs in full validation and again in `release-check`.
- **PERF-3 - Slow failure discovery:** Cheap registry, schema, and drift checks run after 82 seconds of ShellCheck work.
- **PERF-4 - Incomplete invalidation:** Changed-only selection and cache keys infer only `X-selftest.sh` and `X.sh`. Shared helpers, schemas, registries, fixtures, and tool versions are absent.
- **PERF-5 - Serial full suite:** Every check runs synchronously. Some checks use fixed scratch paths, so blanket parallelism would corrupt fixtures.
- **COV-14 - Label-derived push policy:** Core-tier membership uses substrings from human labels. A label rename can alter pre-push coverage.
- **COV-15 - Source-text scheduling:** Selftest discovery treats any basename mention in `framework-validate.sh` as scheduled. A comment can suppress a real selftest. `v4.1.0-selftest.sh` depends on discovery today, so it carries that exposure.
- **COV-15 - Mislabeled skip accounting:** Four distinct skip paths increment one counter. The summary reports every skip as a self-only check skipped under the current install mode and tells the operator to run from a source tree. A core run inside a source tree reported 288 such skips, which were tier skips.
- **COV-16 - Planned validation is not executed:** `test-impact-plan.sh` builds a plan from a project-owned impact map. No script except its own selftest calls it, so nothing executes the returned checks.

### Continuation And Context

- **WIP-4 - Ambiguous resume cursor:** State records a phase name. Modes intentionally repeat phases, including `validate` and `releases`.
- **WIP-4 - Incomplete run-state:** CLI run records omit workflow mode, phase ordinal, occurrence, pending owner, and accepted-result digest.
- **WIP-4 - Model-selected continuation:** `bubbles.workflow` inspects conversation text, run-state, and `state.json`, then asks the model to choose the next step.
- **COV-16 - Prose-only phase decisions:** `phase-relevance-resolve.sh` is executable and tested. No script except its own selftest calls it.
- **COST-8 - Tool output dominates context:** The recorded IMP-039 session attributed 49.7 percent of prompt tokens to tool results. Completion prose was only 0.34 percent of total tokens.
- **COST-8 - Oversized selected runners:** `bubbles.workflow` is 74,439 bytes. `bubbles.iterate` is 56,507 bytes. Much of their text repeats registry and phase behavior.
- **COST-8 - Non-atomic compaction:** The compactor emits a record and separately stamps `compactedAt`. G083 does not require a matching `compactedHistory` record.
- **COST-8 - False context budget:** `effective-bundle-measure.sh` now says it measures link reachability. Two budget scripts still describe and enforce it as loaded prompt size.

### Contract Drift And Cleanup

- **REG-9 - Broken MCP v7 mode input:** `resolve_mode` accepts one string. The resolver requires the primitive and tags as separate argv elements.
- **REG-9 - Stale operator syntax:** The mode guide still teaches a bare leading mode name as operator input. The `mode: <registered-key>` form stays valid and must be preserved.
- **REG-9 - Misleading MCP tools:** `list_open_findings` runs a policy selftest. `verify_status_transition` duplicates `validate_dod` as an alias.
- **REG-9 - Ignored MCP input:** `validate_dod` declares `revert_on_fail`, but its argv template never renders the flag. Its annotations still claim read-only behavior.
- **REG-10 - Duplicate gate registry:** `registry/gates.yaml` is canonical. `workflows.yaml` carries a generated copy, and `gate-meta.sh` reads the generated copy.
- **REG-10 - Duplicate specialist registry:** `required-specialists.yaml` calls itself canonical but instructs maintainers to edit a hardcoded guard table too.
- **REG-10 - Duplicated adoption parser:** CLI, developer profile, readiness, and installer each parse adoption profiles. CLI silently maps an unknown profile to `delivery`. The others reject it.
- **REG-11 - Broken downstream package:** A managed judge selftest invokes a source-only eval harness.
- **REG-11 - False-clean install test:** `v5.3-selftest.sh` discards the complete downstream validator exit code while claiming the synthetic install is clean.
- **REG-11 - Broad payload glob:** Every top-level shell script and every file under `docs/` enters the managed payload before narrow exceptions are applied.
- **REG-12 - Managed-doc parser drift:** The resolver requires six-space list items. The registry uses indentationless YAML sequences, so `requiredSections` vanish.
- **REG-12 - Missing required docs:** The source override redirects architecture and development only. API, testing, deployment, and operations remain required but absent.

### Bureaucracy And Documentation

- **HO-3 - Fixed six-artifact cost:** Every `directFix` requires a full bug packet. This overhead applies even to a localized, contract-preserving repair.
- **EV-9 - Evidence policy conflict:** Agent instructions and G025 require inline-only evidence. `evidence-rules.md` and transition Check 9 permit anchored report or tool-log references.
- **DOC-6 - Phantom modes:** The mode guide documents `brainstorm`, `feature-bootstrap`, `redesign-existing`, and `product-discovery` as full sections. None of those keys exist in the mode registry.
- **DOC-6 - Duplicate recipe catalogs:** `docs/CATALOG.md` stops at 61 entries. `docs/recipes/README.md` is the mechanically checked catalog and contains more recipes.
- **DOC-6 - Weak governance indexing:** The index lint matches basenames in any agent or index. Every skill basename is `SKILL.md`, so unrelated mentions can satisfy indexing.
- **DOC-6 - Generated summary loss:** Block-scalar capability summaries render as a literal `>` in generated competitive docs.
- **DOC-6 - Generated authority inversion:** Generated issue pages call shipped capabilities tracked gaps and can describe projections as the source of truth.
- **DOC-6 - Unconsumed projection:** `framework-stats.md` is referenced only by its generator and release manifest. The JSON form has the real consumer.
- **DOC-6 - Historical docs ship downstream:** Frozen v5/v6 design files and a dated product review enter every downstream package through the all-docs glob.
- **DOC-6 - Status surface duplication:** The spec dashboard prints an empty `DONE` column. The status agent repeats four metrics and repeats the same continuation command.
- **DOC-6 - Stale runtime reader:** `retro-framework-health.sh` expects a top-level run array with `mode` and `outcome`. Current run-state uses `activeRuns` and `recentRuns` with `command` and `result`.

### Gate Execution And Telemetry

- **PERF-4 - Repeated global checks:** Each spec transition reruns global framework lints such as ownership and workflow-runner grants.
- **PERF-4 - No prerequisite graph:** The transition guard continues checks after required structure fails. It cannot mark dependent checks as blocked-not-run.
- **COV-15 - Fixture telemetry pollution:** The source gate-hit log contains fixture run records but no per-gate outcomes. It cannot support retirement decisions.
- **COV-15 - Existence is not use:** Capability freshness proves consumer paths exist. It does not prove they invoke the capability.

## Design Principles

1. Preserve one cold full assurance gate for the final exact tree.
2. Reuse only results whose declared inputs are unchanged.
3. Treat unknown dependencies as affected work.
4. Keep unknown execution classes serial.
5. Record every skip and cache hit as a check result.
6. Keep runtime truth in scripts and registries, not duplicated agent prose.
7. Make source-only and downstream-managed payload classes explicit.
8. Require two independent signals before deleting an asset.
9. Keep historical evidence in source when it has audit value.
10. Do not ship maintainer-only history downstream.

## Proposal

### SCOPE-2 - Typed Validation Check Registry (PERF-1, COV-14)

- Add a canonical check registry.
- Give each check a stable `checkId`.
- Declare argv, tier, push-blocking posture, install mode, timeout, and platform.
- Declare input files, input globs, environment keys, tool versions, and outputs.
- Declare `serial`, `isolated`, or `timing-sensitive` execution classes.
- Generate core and full execution plans from this registry.
- Fail validation when a push-blocking check has no core disposition.
- Keep unregistered discovered selftests runnable in a conservative serial lane.

### SCOPE-3 - Dependency-Complete Receipts And Affected Execution (PERF-4, COV-16)

- Replace same-basename invalidation with declared input closures.
- Record a receipt for every check result.
- Key each receipt by check ID, command, input hashes, toolchain, platform, and validator version.
- Store exit code, duration, stdout hash, stderr hash, and cache status.
- Treat a missing declaration as run-required and cache-forbidden.
- Compute the affected check closure from changed files and reverse dependencies.
- Run previous failures first.
- Run changed checks, dependents, and always-run invariants next.
- When no declared input changed, reuse cacheable receipts and run only always-run checks.
- Keep cache disabled for timing-sensitive checks and cold CI lanes.
- Adopt the shadow-first rule that `test-impact-shadow.sh` already fixes in source.
- Report a proposed subset before any subset is permitted to skip work.

### SCOPE-4 - Batched Heavy Validation (PERF-5)

- Add a bounded scheduler for explicitly isolated checks.
- Keep unknown checks serial.
- Give each check a private temporary root and output file.
- Preserve deterministic report order by check ID or registry order.
- Shadow serial and parallel plans on the same commit.
- Require identical check IDs, exits, and normalized output hashes before enabling a parallel group.
- Preserve a serial diagnostic mode for scheduler failures.

### SCOPE-5 - Validation Epochs And Final Assurance (PERF-4)

- Define a validation epoch by tree SHA, work boundary, platform, and toolchain.
- Permit one heavy baseline early in a large repair batch.
- After repairs, rerun failed checks and their affected closure only.
- Accumulate unrelated side-effect risk for the next heavy boundary.
- Run one cold full `release-check` on the final exact release candidate.
- Never require a full suite after every scope, finding, or small repair.
- Never reuse a whole-suite verdict across a changed tree.
- Keep the full-suite fallback permanently available, as the shadow reporter already requires.

### SCOPE-6 - Executable Workflow Cursor And Phase Coordinator (WIP-4, COV-16)

- Add a deterministic next-step resolver.
- Persist mode digest, phase ordinal, phase occurrence, scope, round, and last accepted result digest.
- Distinguish repeated phases such as `validate#1` and `validate#2`.
- Make the coordinator invoke `phase-relevance-resolve.sh` before each phase.
- Make it record skip inputs, verdict, reason, and reevaluation triggers.
- Make test phases execute `test-impact-plan.sh` output rather than restating it.
- Resume from the first unresolved occurrence without replaying accepted phases.
- Keep conversation text diagnostic-only during resume.

### SCOPE-7 - Atomic Context Compaction (COST-8)

- Append the compact record and stamp its source envelope under one lock.
- Deduplicate by raw pointer and record digest.
- Make G083 require one matching `compactedHistory` entry per compacted envelope.
- Keep the latest two raw envelopes as required today.
- Preserve blocked findings, repository binding, goal identity, owner, and raw pointer.
- Fail closed when the atomic write cannot complete.

### SCOPE-9 - Proportional Micro-Fix Packet (HO-3, EV-9)

- Add a typed compact packet for localized, contract-preserving defects.
- Keep reproduction, changed boundary, risk class, root cause, regression test, commands, evidence, owner, and certification.
- Admit only low-risk work with no new behavior, schema, auth, payment, secret, deployment, or cross-product effect.
- Escalate automatically to the full bug packet when any admission condition fails.
- Preserve reproduce-before-fix and adversarial regression requirements.
- Measure packet authoring time and defect escape rate before making it the default.

### SCOPE-10 - Compact Durable Status Tracking (WIP-4, DOC-6)

- Limit open-work and improvement-index inline detail.
- Keep ID, state, owner, blocker, next executable action, opened date, and `detailsRef` inline.
- Consolidate the status agent's duplicated metric rows and its repeated continuation command.
- Move chronological logs and long incident narratives behind referenced files.
- Generate derived status from owning artifacts.
- Remove no-op state writes and duplicate status tables.
- Keep Git history as the closed-item audit trail.

### SCOPE-11 - Explicit Selftest Scheduling And Semantic Reachability (COV-15)

Delivered: invocation-based scheduling shared by the sweep and the coverage lint, and path-aware governance and skill indexing. Remaining:

- Require executable consumers to name the capability they consume.
- Keep report-only posture until dynamic-call false positives are calibrated.

### SCOPE-12 - Manifest-Driven Downstream Payload (REG-11)

- Make managed, source-only, generated, optional, and historical classes explicit.
- Stop treating every top-level script and every documentation file as managed by default.
- Classify the judge adapter selftest with the eval subsystem, or ship its complete dependency closure.
- Replace the synthetic partial-copy downstream test with a real installer fixture.
- Require the complete downstream `framework-validate` exit code to be zero.
- Assert every managed executable has its runtime dependencies in the same payload class.
- Assert source-only tests remain executable in source validation and absent downstream.

### SCOPE-13 - Canonical Registry Consolidation (REG-10, REG-12)

- Make `gate-meta.sh` read `registry/gates.yaml` directly.
- Shadow every query against the generated workflow copy.
- Remove the generated gate block only after byte-equivalent queries pass.
- Make transition Check 6 read `required-specialists.yaml` directly.
- Move rationale prose beside the registry or into focused docs.
- Delete the shadow comparator after the runtime consumes the registry.
- Extract one adoption-profile parser and one unknown-value policy.
- Repair managed-doc list parsing without adding a YAML tool dependency.
- Keep the portable-awk constraint that lets the resolver run on a minimal PATH.
- Validate required managed-doc path existence and required section retention.

### SCOPE-14 - Context And Agent-Prose Cleanup (COST-8)

- Rename link-closure metrics to reference-closure metrics everywhere.
- Remove blocking prompt-cost claims based on link reachability.
- Keep reference closure as an advisory coupling signal.
- Deprecate global and per-agent bundle budgets after config migration.
- Move deterministic workflow tables from agent prose into executable resolvers.
- Load phase-owned policy modules through an explicit context manifest.
- Keep non-active skills and reference modules as on-demand pointers.
- Keep identity, prohibitions, ownership, dispatch boundaries, and result contracts in agent files.
- Require held-out routing tests before deleting policy prose.
- Measure actual tool-result bytes and host prompt tokens when an adapter exists.

### SCOPE-15 - Evidence Policy Single Source (EV-9)

- Make `evidence-rules.md` the canonical evidence-location contract.
- Preserve the raw-output substance requirement.
- Permit one canonical stored block with anchored or receipt-based references.
- Remove inline-only contradictions from instructions, scope workflow, and G025.
- Make the transition guard and docs describe the same two reference forms.
- Keep per-item attribution and individual validation.
- Reject duplicate pastes when they claim to be separate executions.

### SCOPE-16 - Documentation And Generated Projection Cleanup (DOC-6)

Delivered: block-scalar preservation, generated-page authority framing, and the generated issue summary column. Remaining:

- Replace the phantom mode sections that document unregistered keys.
- Reduce `docs/CATALOG.md` to a distinct decision aid or redirect to the checked recipe index.
- Repair the governance index claim and its path-aware lint.
- Delete `framework-stats.md` only together with its generator self-check and its manifest entry, or index it as a human surface.
- Move dated reviews behind a historical review index.
- Keep frozen design history in source but exclude maintainer-only history from downstream payloads.

### SCOPE-17 - Transition Guard Plan And Gate Telemetry (PERF-4, COV-15)

- Classify transition checks as spec-local, repo-global, or external.
- Declare prerequisite edges between transition checks.
- Emit `BLOCKED_NOT_RUN` for checks whose prerequisites failed.
- Continue independent checks to preserve one-pass diagnostics.
- Reuse repo-global receipts only when their input closure is unchanged.
- Tag telemetry as product, fixture, selftest, or migration.
- Exclude fixture-only records from retirement reports by default.
- Require downstream observation windows before retiring any gate.

### SCOPE-18 - Compatibility Removal Train (REG-9, DOC-6)

- Inventory deprecated flags, aliases, framing paths, and legacy schemas.
- Scan all downstream repositories before removal.
- Announce one versioned removal train.
- Add migration commands and a release-note matrix.
- Remove only compatibility paths with zero current consumers.
- Keep persisted v5 registry keys and grandfathered artifact reads.
- Keep legacy terminal-state readers while old artifacts remain.

## Cleanup Disposition Matrix

### Remove Or Consolidate After Focused Proof

| Candidate | Disposition | Required proof |
| --- | --- | --- |
| `framework-stats.md` | Delete or index | No downstream or human consumer exists, and the generator self-check plus manifest entry change together |

### Migrate Before Deletion

| Candidate | Migration condition |
| --- | --- |
| Generated `gates:` block | Every reader uses `registry/gates.yaml` |
| Required-specialist guard table | Check 6 consumes the registry |
| Required-specialist shadow comparator | Runtime registry cutover passes |
| Effective-bundle budget layers | Config and docs use reference-closure terminology |
| Managed source-only selftests | Payload-class contract and real downstream fixture pass |
| MCP alias tools | Usage scan and deprecation window complete |
| `docs/CATALOG.md` inventory | Checked recipe index is the sole inventory |
| Deprecated flags and framing | Downstream usage scan is empty |

### Keep

| Asset | Reason |
| --- | --- |
| Compact always-on kernel | It carries universal repository and evidence invariants within budget |
| Downstream agent, skill, prompt, and instruction copies | Installer-managed offline distribution |
| Prompt shims | Current prompt and agent inventory is one-to-one |
| Versioned aggregate selftests | They protect supported migration and persisted-artifact contracts. `v4.1.0-selftest.sh` reaches execution through discovery only |
| `migrate-modes-v5-to-v6.sh` | It is the supported migration tool |
| Persisted v5 mode keys and grandfathering | Current guards and historical artifacts consume them |
| Frozen v5/v6 design documents in source | Maintainer history has audit value |
| Gate coverage map | It has a distinct generated enforcement view and freshness check |
| Installer templates | The installer consumes them |
| MCP catalog files | The server loads tool and resource JSON dynamically |

## Delivery Amendments

Evidence found during implementation that changed a proposed action.

- The release-level manifest re-check is RETAINED, not removed. Freshness now runs last inside `framework-validate`, but only a second invocation after the suite can observe a managed file dirtied during the run. The cost is one hash pass against a ~2100 second gate.
- The macOS CI claim was imprecise rather than false. A macOS `release-check` leg exists and is gated to pushes, so the hook now states Linux on pull requests and pushes, macOS on pushes.
- The status agent's duplicated rows moved to SCOPE-10. They are agent-routing prose, not leaf cleanup, and SCOPE-14 requires held-out routing tests before prose deletion.
- The `--list-modes` regression needed no new test. `mode-alias-selftest.sh` was already stripping `phaseRelevance` itself, so removing that workaround made its existing coverage check the regression.
- `validate_dod.revert_on_fail` was REMOVED rather than wired. The guard supports the flag, but certification state is validate-owned, so exposing a status rewrite to a model-invocable tool creates a forging vector. The CLI keeps the capability.
- `search_code` carried the same ignored-input defect as `validate_dod`, and worse: three declared inputs were unrendered while the description promised one of them worked. Fixed under the same scope.
- Bare v5 operator syntax was corrected during SCOPE-8 because it shares the mode contract. The phantom mode sections remain with SCOPE-16.
- The selftest denylist needed no change. It already required a stated reason per entry and already failed on a stale entry, and both of its two entries are executed through another path.
- Path-aware skill indexing exposed six skills that no index referenced. The basename rule had been reporting them as indexed because every skill file is named `SKILL.md`.

## Migration And Rollout

### Wave 0 - Leaf Cleanup

- SCOPE-1 and SCOPE-8 are delivered. See their CHANGELOG entries.
- Land the safe parts of SCOPE-10 and SCOPE-16 next.
- Run focused tests after each edit.
- Run one core validation after the leaf batch.

### Wave 1 - Shadow Registries

- Land the typed check registry without changing execution.
- Compare the generated plan with the current ordered run.
- Land canonical parser and registry readers behind shadow comparisons.

### Wave 2 - Receipts And Affected Execution

- Enable receipts in report-only mode.
- Compare affected plans with full cold runs.
- Require zero missed failures before skipping any check by default.

### Wave 3 - Bounded Parallelism

- Parallelize one audited group first.
- Compare serial and parallel outputs on the same commit.
- Expand only after stable parity.

### Wave 4 - Workflow Runtime

- Add the occurrence-aware cursor and executable phase coordinator.
- Mirror legacy phase names during migration.
- Validate interrupted and repeated-phase resumes.

### Wave 5 - Payload And Cleanup Migrations

- Cut over payload classes, canonical registries, evidence policy, and managed docs.
- Remove shadow copies only after their consumers reach zero.

### Heavy Validation Cadence

- Run focused validation immediately after each edit.
- Rerun only failed checks and their declared affected closure during repair.
- Batch unrelated side-effect risk for the next heavy boundary.
- Run a cold full `release-check` once per final exact release candidate.
- Run macOS and Linux promotion lanes before publishing framework changes.
- Do not run the full suite after every finding, scope, or documentation correction.

## Risks And Mitigations

- **R1 Stale cache result:** A missing input could preserve a false pass, and a skipped check looks exactly like a passing check. Unknown inputs force execution and disable caching.
- **R2 Parallel fixture collision:** Two checks could share scratch state. Unknown checks remain serial, and isolated checks receive private roots.
- **R3 Resume schema drift:** Old state lacks occurrence fields. Additive readers infer a conservative first unresolved occurrence and record migration.
- **R4 Micro-fix quality loss:** A compact packet could hide design work. Closed admission rules escalate risky or behavior-changing work automatically.
- **R5 Active asset deletion:** Dynamic callers can defeat grep. Require manifest, runtime, index, and downstream usage checks before deletion.
- **R6 Policy loss during agent slimming:** Markdown links are not loaded automatically. Require explicit loaders and held-out routing tests first.
- **R7 Delayed broad regression:** Focused loops can miss an unrelated effect. Preserve the exact-tree cold release gate, keep the permanent full-suite fallback, and batch risk at wave boundaries.
- **R8 Registry cutover drift:** A consumer may still read a generated copy. Run shadow queries and block deletion while any old reader remains.
- **R9 Telemetry contamination:** Fixtures can distort gate utility. Tag source class and exclude fixtures from product-retirement reports.
- **R10 Proposal breadth:** This IMP spans several ownership surfaces. Land each scope independently and keep every intermediate tree green.

## Acceptance Criteria (When Implemented)

### Validation Outcomes

- Core validation p50 is at most 75 seconds after SCOPE-1, measured against 109 seconds that include 41 seconds of duplicated ShellCheck work.
- Core validation p50 reaches 45 seconds only after ShellCheck input scoping or bounded parallelism lands.
- A per-check latency profile of the cold full suite is published before any full-suite reduction target is set.
- The full-suite target is then derived from that profile rather than assumed.
- Every old and new check ID appears exactly once in a full execution report.
- Serial and parallel plans produce identical normalized results before parallel default activation.
- A change to any declared transitive input invalidates every dependent receipt.
- An undeclared dependency causes execution, never a cache hit.
- One final cold release check passes on the exact published commit.

### Workflow Outcomes

- An interrupted repeated-phase mode resumes at the correct phase occurrence.
- Phase relevance decisions are executable, persisted, and reevaluated on declared triggers.
- Test-impact output drives real commands and records their receipts.
- Compaction cannot stamp success without a matching history record.
- A compact micro-fix packet cannot admit high-risk or behavior-changing work.

### Cleanup Outcomes

- No selftest can be suppressed by appearing only in a comment.
- Every managed executable has a complete managed dependency closure.
- The real installed downstream tree passes complete framework validation.
- Gate metadata and required specialists each have one runtime source.
- Unknown adoption profiles receive the same fail-loud result from every caller.
- Managed-doc required sections survive resolution.
- Active docs contain no phantom mode and no rejected bare v5 invocation.
- Generated capability summaries preserve block scalars.
- No fixture-only gate telemetry enters the default retirement report.
- Every deleted file has a recorded consumer scan and migration disposition.

### Context Outcomes

- Always-on framework instructions remain below the current 8,000-byte ceiling.
- Reference closure is never reported as loaded prompt cost.
- Tool-result bytes and prompt tokens are reported only from configured usage adapters.
- The workflow runner shrinks only after held-out routing quality remains unchanged.
- Open-work rows stay bounded and retain an actionable owner and next action.

## Files To Touch (On Approval)

### Validation Runtime

- `bubbles/scripts/framework-validate.sh`, `bubbles/scripts/release-check.sh`, and `bubbles/scripts/hooks/pre-push.sh` - `bubbles.implement`. PERF-1 through PERF-5.
- New check-registry, planner, receipt, and scheduler scripts under `bubbles/scripts/` - `bubbles.implement`.
- Focused and adversarial selftests under `bubbles/scripts/` - `bubbles.test`.
- `.github/workflows/agnosticity.yml` - `bubbles.devops`.

### Workflow And State

- `bubbles/workflows/modes.yaml`, state schemas, and state templates - `bubbles.implement`. WIP-4.
- `agents/bubbles.workflow.agent.md` and shared workflow modules - `bubbles.docs` after executable behavior exists.
- `bubbles/scripts/phase-relevance-resolve.sh` and `bubbles/scripts/test-impact-plan.sh` consumers - `bubbles.implement`.
- `bubbles/scripts/context-compactor.sh` and G083 guard/selftests - `bubbles.implement` and `bubbles.test`.

### Contracts And Cleanup

- `bubbles/mcp/tools/*.json`, MCP server tests, and mode resolver tests - `bubbles.implement` and `bubbles.test`.
- `bubbles/registry/gates.yaml`, `bubbles/registry/required-specialists.yaml`, and their readers - `bubbles.implement`.
- `bubbles/scripts/trust-metadata.sh`, `generate-release-manifest.sh`, `install.sh`, and downstream-install tests - `bubbles.implement` and `bubbles.test`.
- Adoption-profile and managed-doc parser consumers - `bubbles.implement`.
- `agents/bubbles_shared/evidence-rules.md`, G025, instructions, and scope workflow - `bubbles.docs`, with guard parity owned by `bubbles.implement`.
- Operator docs, generated-doc generators, status surfaces, and historical indexes - `bubbles.docs`.
- `bubbles/scripts/framework-health-evidence-lint.sh` and cleanup inventory checks - `bubbles.test` and `bubbles.implement`.

## Owner Decisions Requested

1. Approve the typed check registry as the validation source of truth.
2. Approve one final cold full gate per release candidate instead of one full gate per repair.
3. Approve the compact micro-fix packet pilot for low-risk repairs.
4. Approve removal of blocking budgets based on reference closure.
5. Approve a versioned compatibility removal train after downstream usage measurement.
