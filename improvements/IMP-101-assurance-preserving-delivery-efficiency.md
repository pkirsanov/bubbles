# IMP-101 - Assurance-Preserving Delivery Efficiency

**Status:** PARTIALLY APPLIED - bounded-safe truth/accuracy fixes shipped + framework-validate green (2026-07-20); large/risky and owner-gated scopes deferred pending the four owner decisions below
**Surface:** framework-health (G125) - human-reviewed; only bounded-safe accuracy fixes auto-applied, NO architectural auto-mutation of `bubbles/*` until approved
**Motivation:** 2026-07-20 whole-system executive review of Bubbles documentation, agents, workflow registries, evidence paths, transition guards, installer, CLI/MCP, CI, tests, bug history, capability ledger, and the retired IMP-100 program
**Verified gaps addressed:** AF-101 evidence linkage; FLOW-101 registry/prose drift; CHURN-101 mandatory packet expansion; CTX-101 effective prompt load; VAL-101 duplicated validation; SUPPLY-101 install trust; DEPLOY-101 optional assurance; DOC-101 management-truth drift; HOST-101 runtime dispatch fragility; CLI-101 central-script concentration; GATE-101 gate-strength opacity
**Verification provenance:** every gap below cites `path:Lnnn` in the current worktree (VERSION 7.20.1, `main` at `eb77dca`); re-verified 2026-07-20 with `bash bubbles/scripts/cli.sh framework-validate` green, and each citation re-read line-by-line in a second review pass. That pass added the G072/Check-12 enforcement-mismatch finding (AF-101, GATE-101), the precise adoption-profile drift and 60-of-70 recipe-catalog count (DOC-101), and the tool-log session/prefix looseness (AF-101). Line numbers are advisory pointers for reviewers, not a mutation authorization (G125).

## Reconciliation (2026-07-20)

Applying the IMP-100 procedure honestly to this proposal: the bounded, low-risk,
non-owner-gated accuracy fixes were implemented and validated (framework green);
the large/risky architectural scopes and the four reserved owner decisions are
deferred, not fabricated as done. This file is retained as the owner-decision
and roadmap record.

**Addressed - shipped and framework-validate green:**

- **DOC-101 management-truth drift.** `docs/guides/INSTALLATION.md` agent/prompt
  counts (34 -> 41) and removal of the retired `AGENTS.md` scaffold bullet;
  `docs/MCP.md` tool/prompt counts (10 -> 12, 37 -> 41); `install.sh` `--profile`
  help now lists `production`; `docs/recipes/README.md` links all 70 recipes
  (was 60) via two new sections; `.github/copilot-instructions.md` source-repo
  command corrected to `cli.sh` (resolves the `./bubbles.sh` contradiction with
  `.specify/memory/agents.md`).
- **GATE-101 enforcer mismatch (SCOPE-11 sub-part).** `bubbles/registry/gates.yaml`
  G072 no longer claims enforcement by `state-transition-guard.sh` Check 12
  (which is duplicate/fabrication detection); it now accurately states that no
  mechanical guard scans the `**Claim Source:**` tag yet. The full five-class
  gate-strength taxonomy remains deferred.
- **SUPPLY-101 prerequisite documentation (sub-part).** `docs/guides/INSTALLATION.md`
  prerequisites now list `tar` and a SHA-256 utility, which `install.sh`
  preflight hard-requires. Source-authenticating install remains deferred.
- **SCOPE-10 management-truth enforcement (bounded core).** New
  `bubbles/scripts/management-truth-lint.sh` (+ hermetic selftest, wired
  source-only into framework-validate) mechanically fails if any
  `docs/recipes/*.md` is unlinked from the catalog index or any
  `adoption-profiles.yaml` id is absent from the installer `--profile` help,
  locking in the DOC-101 recipe and profile fixes so they cannot silently
  re-drift. Registry-generated count prose and a machine-readable
  bug-disposition ledger remain deferred.

**Deferred - reserved owner decisions required before implementation:**

- **SCOPE-2/3/4** compact change packets, delta-first planning, risk-proportional
  routing - gated on owner decisions (1) compact-v1 principle and (3) rollout
  threshold. A new delivery model; not auto-adoptable.
- **SCOPE-1** claim-bound raw-evidence receipts - gated on owner decision (2)
  durable evidence-backend policy; also a high-risk change to the 3,466-line
  `state-transition-guard.sh` evidence path that could reject currently-valid
  specs.
- **SCOPE-9** mandatory adopted deployment assurance - gated on owner decision
  (4) migration date/version; the concrete adapter is knb-owned per the
  deployment boundary.

**Deferred - risky/large architectural scopes kept off the keep-green path:**

- **SCOPE-5** registry-derived execution contract (removing the hardcoded case
  table inside the 3,466-line guard); **SCOPE-6** blocking context budgets (could
  reject currently-passing over-budget agents); **SCOPE-7** one-pass parallel
  validation (refactor of the critical validation harness; the
  `BUBBLES_PREPUSH_TIER=core` opt-in already ships as a partial mitigation);
  **SCOPE-8** signed installation; **SCOPE-10 remainder** (registry-generated
  count prose plus a machine-readable bug-disposition ledger; the recipe- and
  profile-catalog enforcement core is shipped above); **SCOPE-11** full gate-strength
  taxonomy across all 109 gates; **SCOPE-12** modular CLI/guard decomposition
  (3,232-line `cli.sh` + 3,466-line guard); **SCOPE-13** dispatch-failure
  checkpointing; **SCOPE-14** held-out efficiency benchmark (depends on the
  above). FLOW-101's UX-applicability and mode-classification contradictions are
  policy reconciliations that need design intent and are folded into SCOPE-5.

These deferrals are honest scope boundaries, not completion claims. Nothing here
is marked done without shipped, validated proof, and the four owner decisions
remain open.

## Executive intent

Keep Bubbles' quality bar VERY HIGH while reducing the time spent creating,
copying, re-reading, and re-validating governance material that does not add
new assurance.

The program does **not** trade quality for speed. It removes repeated
representation and routing work while strengthening the proof chain:

1. Record real proof once, bind it to the exact claim, and verify it every time
   it is reused.
2. Require all planning semantics, but do not require six separate files when a
   mechanically low-risk change can carry the same semantics in a compact
   packet.
3. Invoke a specialist only when that specialist has a substantive decision or
   artifact to own. A typed, validated not-applicable result is better than a
   ceremonial agent pass.
4. Derive execution requirements from registries instead of repeating them in
   prose and shell `case` tables.
5. Run the narrowest sufficient check during iteration and the full assurance
   suite once at the release boundary for the exact same source revision.

## Non-regression quality contract

Every scope in this proposal MUST preserve or strengthen these invariants:

- **No fabricated completion.** A terminal claim requires current-session,
  machine-resolvable proof from a command that actually ran.
- **No metadata-only evidence.** A command name, exit code, output hash, or
  narrative summary without resolvable raw output cannot satisfy a DoD item.
- **No reduced behavioral coverage.** Every changed behavior still maps to a
  stable scenario, an expected assertion, and the correct test category.
- **No test substitution.** Unit, integration, E2E, stress, live-system, and
  human-validation categories retain their existing meanings.
- **No selective finding closure.** Every finding is fixed and revalidated,
  routed with its full payload, or blocks completion.
- **No ownership bypass.** Orchestrators dispatch; owning specialists write;
  `bubbles.validate` remains the sole certification writer.
- **No risk self-labeling.** Compact delivery eligibility is resolved
  mechanically. Ambiguous or elevated risk always escalates to the full path.
- **No deploy bypass.** Prototype assurance remains undeployable, and missing
  assurance becomes a refusal after the migration window.
- **No stale-cache certification.** Reused evidence and validation results must
  match the current source revision, input closure, policy digest, mode, scope,
  and claim.
- **No bypass flags.** New controls have no `--skip`, `--force`, `--ignore`, or
  allow-once escape hatch.

An efficiency change MUST be rejected if held-out evaluation shows any increase
in false terminal transitions, escaped findings, weakened scenario coverage,
or unverifiable evidence.

## Verified baseline gaps

### AF-101 - Evidence policy and enforcement diverge

`skills/bubbles-anti-fabrication/SKILL.md`,
`agents/bubbles_shared/evidence-rules.md`, and
`agents/bubbles_shared/scope-workflow.md` require current-session raw terminal
output for each checked DoD item. In contrast,
`bubbles/scripts/state-transition-guard.sh` Check 9 (evidence presence, L2187)
accepts, besides a validated inline raw block:

- a bare `Evidence:` marker with no validated raw block;
- a plain `report.md` link when the file merely exists; or
- any successful tool-log row whose command text shares two alpha-tokens with
  the DoD text (`_tool_log_covers_dod_item`, L2204).

That tool-log fallback does not require a matching current session, scope,
stable DoD identifier, fresh input closure, non-empty output, or a resolvable
raw-output object, yet its own comment labels it "cryptographic-hash-grade
evidence" (L2404). `tool-log.sh` streams stdout/stderr to temp files, records
only hashes and byte counts, and deletes the raw text on exit; with no SHA-256
utility present it records an all-zero hash (L115). `tool-capture-shim.sh` also
fails open and runs the command without a receipt when the logger is missing
(L54). The matcher never checks the current session: it accepts any historical
`.specify/runtime/tool-calls.jsonl` row whose `spec` equals the slug or merely
shares its numeric prefix (`sf.startswith(spec_slug.split('-', 1)[0])`), and the
inline path (case 3, `_c9_inline_evidence_re`, L2325) treats a lone Markdown
fence or the bare word `Evidence` within 15 lines as a satisfied block. The
documented contract in `skills/bubbles-anti-fabrication/SKILL.md`,
`agents/bubbles_shared/evidence-rules.md`, and
`agents/bubbles_shared/scope-workflow.md` (Per-DoD-Item Evidence, G025) requires
current-session raw output.

The gap is compounded by an unenforced sibling control. Gate G072
(`bubbles/registry/gates.yaml` L215, evidence_provenance_gate) requires every
evidence block to carry a `**Claim Source:**` tag (`executed` / `interpreted` /
`not-run`) and declares itself "Enforced by bubbles.validate evidence review
plus state-transition-guard.sh Check 12". But Check 12
(`state-transition-guard.sh` L2600) is duplicate/clone/fabrication detection,
and no guard check scans a DoD item for the `**Claim Source:**` tag (its only
functional use is report-fence format validation in `stale-deferral-lint.sh`
L148). So the exact executed/interpreted/not-run provenance taxonomy this
program relies on already exists as G072 yet has no mechanical DoD-level
enforcement. This divergence is the first priority.

### CHURN-101 - Artifact count is fixed instead of risk-proportional

`agents/bubbles_shared/critical-requirements.md` (ALL-OR-NOTHING bug artifacts,
L102) and `agents/bubbles_shared/workflow-orchestration-core.md` (a one-line
`go.mod` change and a multi-file refactor "both go through the same
artifact-first pipeline", L46) require every code-change finding to receive its
own full six-artifact bug packet and full planning/delivery chain. This
preserves rigor but repeats unchanged parent requirements, design context,
scenarios, and evidence framing. The same semantic contract can be represented
more compactly for mechanically low-risk deltas without reducing coverage.

### FLOW-101 - Registry policy is repeated in prompts and shell tables

`bubbles/workflows/modes.yaml` is the canonical mode registry, but
`state-transition-guard.sh` separately hardcodes required specialist phases by
mode in a shell `case` table (L1447-1531). Newer modes including
`rapid-tool-delivery`, `readiness-review`, and `journey-refinement` are absent
from that table, so its Check 6 imposes no specialist-completion requirement on
them. Shared orchestration modules also disagree on UX: `workflow-orchestration-core.md`
L13 says UX is mandatory even for framework/operator/non-UI work, while
`workflow-phase-engine.md` L53 invokes UX "ONLY when the finding touches UI".
The literal `mode:` pre-classification rule (`workflow-delegation-core.md` L41)
routes every token-less request to `VAGUE`, which conflicts with the documented
continuation and framework-operation buckets in the same module. One
registry-backed execution contract should replace these parallel
interpretations.

### CTX-101 - Effective context is much larger than the budgeted surface

`instruction-budget-lint.sh` budgets individual agent files. The shipped
`effective-bundle-measure.sh` shows the transitive surface is the real cost.
Measured 2026-07-20 via `effective-bundle-measure.sh`, the `bubbles.workflow`
closure is 42 files, 461,019 bytes, and 6,724 lines; `bubbles.implement` is
147,712 bytes and 1,884 lines. The effective bundle is report-only and is not a
blocking budget. Large repeated governance bundles increase latency and make
contradictory instructions harder to detect.

### VAL-101 - Full validation is duplicated and sequential

The default source pre-push hook (`bubbles/scripts/hooks/pre-push.sh`) runs full
`framework-validate` (L52), then runs `release-check` (L62-64), which runs full
`framework-validate` again (`release-check.sh` L109). The core tier is opt-in
via `BUBBLES_PREPUSH_TIER=core` (L36). `framework-validate.sh` maintains a long
sequential command list and rebuilds multiple independent install fixtures. The
retired IMP-100 explicitly deferred bounded parallel execution, shared fixtures,
and release-check deduplication.

### SUPPLY-101 - Install integrity is post-copy, not source-authenticating

The documented remote path downloads a branch or tag archive (`install.sh`
L117) and trusts the release manifest inside the same archive. `install.sh`
checks only `curl`/`tar` at preflight (L86-87), parses `managedFileChecksums`
with line-oriented awk (L153), does not independently verify a signed digest
before copying, does not validate every payload file against
`managedFileChecksums` before install, and does not call
`bubbles_validate_release_manifest_schema` on the normal install path (that
validator runs only in `cli.sh upgrade` and the downstream write guard).
Documentation also omits required or conditionally required tools: `tar`, a
SHA-256 utility, `perl`, Python 3.10 for MCP, and `yq`/`jq` for core governance
paths.

### DEPLOY-101 - Assurance enforcement remains fail-open when absent

`release-assurance-gate.sh` skips specs without `certification.assurance.level`
(L53-54). `deploy-manifest-assurance-lint.sh` exits zero when the assurance
block is absent (L153) and WARN-and-skips when `yq` is absent. The framework
contract exists, but the concrete knb adapter wiring remains downstream work.
Prototype refusal is therefore conditional on adoption, not yet universal.

### DOC-101 - Generated and management surfaces can be reproducibly stale

Installation docs still claim 34 agent/prompt definitions
(`docs/guides/INSTALLATION.md` L33-34) and a root `AGENTS.md` scaffold (L43),
while the installer ships 41 agents and explicitly removed that scaffold
(`install.sh` L921). MCP docs claim 10 tools and 37 prompts (`docs/MCP.md` L39)
while the live catalog holds 12 tool definitions (`bubbles/mcp/tools/*.json`)
and 41 prompt shims. The recipe catalog `docs/recipes/README.md` links 60 of the
70 recipe files, omitting live recipes such as `adversarial-verification`,
`incident-response`, `propagate-changes`, `observe-production`, and
`release-train-lifecycle`. `BUGS.md` can retain an open disposition after the
implementation and adversarial regression have landed. The source-repo policy
and command registry also disagree on `./bubbles.sh`:
`.github/copilot-instructions.md` L50 says "Always use `./bubbles.sh`" while
`.specify/memory/agents.md` L119 says "Do not invent `./bubbles.sh`". Installer
`--profile` help (`install.sh` L39) lists only `foundation, delivery, assured`,
omitting the registry's fourth id `production` (`bubbles/adoption-profiles.yaml`
defines `foundation, delivery, production, assured`). Freshness checks currently
prove deterministic regeneration, not semantic accuracy across all public
surfaces.

### HOST-101 - Core orchestration inherits an upstream dispatch failure

`BUGS.md` BUG-003 (L275) documents the VS Code/Anthropic thinking-block
serialization failure. Bubbles cannot repair the host serializer, but its core
runners depend on `runSubagent`. A failed dispatch batch must be checkpointed
and resumed without losing finding accounting or claiming phases that never ran.

### CLI-101 - Operational concerns are concentrated in one shell file

`bubbles/scripts/cli.sh` is a 3,232-line dispatcher containing 42 `cmd_*`
handlers plus profile parsing, doctor, upgrade, runtime state, metrics, and hook
operations. `state-transition-guard.sh` (3,466 lines) and `artifact-lint.sh`
(1,764 lines) are also large policy hotspots. Concentration raises review cost
and makes small changes exercise a broad regression surface.

### GATE-101 - The headline gate count does not communicate enforcement strength

The 109 registered gates include mechanical blockers, mechanical advisories,
conditional no-ops, and prompt-behavior contracts - e.g.
`bubbles/registry/gates.yaml` L209 `execution_only_validation_gate` is enforced
behaviorally, not by a script. Worse, a gate's declared mechanical enforcer can
be inaccurate: G072 (L215, evidence_provenance_gate) states it is "Enforced by
... state-transition-guard.sh Check 12", but Check 12 (`state-transition-guard.sh`
L2600) is duplicate/fabrication detection and validates no Claim-Source
provenance tag. Counting these as equivalent controls obscures where assurance
comes from, which gates are actually mechanical, and where model adherence is
still required.

## Improvement inventory

| Priority | Scope | Improvement | Quality effect | Bureaucracy/time effect |
| --- | --- | --- | --- | --- |
| P0 | SCOPE-1 | Claim-bound raw evidence receipts | Higher | Record once; reference safely |
| P0 | SCOPE-2 | Compact low-risk change packets | Same or higher | Fewer duplicated spec files |
| P0 | SCOPE-3 | Delta-first planning and finding grouping | Same | Less repeated parent context |
| P1 | SCOPE-4 | Risk-proportional specialist routing | Same | Eliminate ceremonial passes |
| P1 | SCOPE-5 | Registry-derived execution contract | Higher | Remove duplicate policy maintenance |
| P1 | SCOPE-6 | Effective context budgets | Higher | Lower prompt load and contradiction risk |
| P1 | SCOPE-7 | One-pass proportional validation | Same or higher | Remove duplicate full runs |
| P1 | SCOPE-8 | Signed, dependency-aware installation | Higher | Faster diagnosis; safer upgrades |
| P1 | SCOPE-9 | Mandatory adopted deployment assurance | Higher | Fewer late deployment surprises |
| P2 | SCOPE-10 | Generated management truth | Higher | Eliminate manual count/status upkeep |
| P2 | SCOPE-11 | Gate-strength taxonomy | Higher transparency | Faster risk interpretation |
| P2 | SCOPE-12 | Modular CLI and guard internals | Same | Smaller review/test blast radius |
| P2 | SCOPE-13 | Dispatch-failure checkpointing | Higher | Less lost orchestration work |
| Required proof | SCOPE-14 | Quality/efficiency benchmark | Prevents regression | Quantifies actual time savings |

## Proposal

### SCOPE-1 - Claim-bound, raw-output evidence receipts (AF-101)

Replace token-overlap evidence matching with a closed receipt contract.

Each receipt MUST include:

- stable `receiptId`, `sessionId`, `invocationId`, agent, spec, scope, and one or
  more stable `DOD-*` claim IDs;
- exact argv as an array, cwd, start/end timestamps, exit code, and framework
  version/source SHA;
- declared input closure with content hashes and policy/transition-contract
  digest;
- stdout/stderr byte counts, hashes, and a resolvable raw-output object;
- output classification (`executed`, `interpreted`, `not-run`) plus explicit
  interpretation when applicable.

The `executed` / `interpreted` / `not-run` classification MUST reuse the
existing G072 `**Claim Source:**` taxonomy rather than introduce a parallel
vocabulary, and SCOPE-1 MUST add the guard check that G072 currently lacks so
the tag is mechanically validated on every `[x]` DoD item — closing the AF-101
enforcement gap instead of leaving it behaviorally reviewed only.

Certification accepts either inline raw output or a receipt whose raw object is
present and hash-valid at guard time. Missing, malformed, stale, unknown,
cross-session, cross-spec, cross-scope, metadata-only, or unbound receipts fail
closed. `--strict` treats both stale and unknown receipts as failures.

The fixed `>=10` presentation-line rule remains a conservative legacy heuristic
for unstructured Markdown evidence, but a typed receipt MUST NOT force an
operator to pad a naturally short command with synthetic verbosity. It instead
preserves the command's complete raw stdout/stderr byte-for-byte and binds the
claim to a declared machine oracle or exact expected signal. A two-line real
result with a claim-specific oracle is stronger than ten lines of unrelated
framing; a two-line narrative summary is still invalid.

One receipt MAY support multiple DoD claims only when each stable DoD ID is
explicitly bound and the command output directly proves each claim. The guard
must not infer linkage from shared words. Remove acceptance of bare `Evidence:`
markers and unanchored report links.

Store raw output once in a content-addressed evidence backend. The initial
backend may be repo-local for the current session; release certification needs
a durable backend or CI artifact whose digest remains resolvable. Reports carry
bounded excerpts and receipt references, not repeated full output.

If receipt capture, hashing, raw-object persistence, or append fails, the
wrapped command may report its own execution result to the operator but MUST
NOT become certifying evidence. Evidence-required execution fails closed and
must be rerun through a healthy recorder.

### SCOPE-2 - Mechanically gated compact change packets (CHURN-101)

Add `packetProfile: compact-v1` for a narrow repair or small enhancement only
when `risk-tier-resolve.sh` proves all eligibility conditions. A compact packet
contains the same required semantics in fewer physical files:

1. `change.md` - parent-spec reference, observed problem, Outcome Contract,
   change boundary, affected scenario deltas, design decision, test plan, and
   DoD;
2. `state.json` - unchanged machine-readable execution/certification boundary;
3. `report.md` - finding accounting plus receipt references and bounded human
   interpretation.

Eligibility requires all of the following:

- risk class is mechanically `low`;
- one repository and one bounded change surface;
- an existing parent behavior contract or a complete outcome contract in the
  compact packet;
- no auth, payment, secret, PII, database migration, deploy/prod,
  host-singleton, cross-product, public-contract, schema, or destructive data
  change;
- no unresolved ambiguity and no requirement for a new reusable capability
  foundation.

Any ambiguity or elevated-risk trigger escalates to the full packet before
implementation. The full feature, bug, and ops packet remains unchanged and is
the default. Compact does not mean direct/unplanned: scenarios, tests, DoD,
evidence, finding accounting, validation, and audit remain mandatory.

### SCOPE-3 - Delta-first planning and root-cause grouping (CHURN-101)

- Reference unchanged parent requirements/design/scenarios by stable anchor and
  digest instead of copying them into each bug packet.
- Record only the behavioral delta, affected consumers, new risks, and changed
  acceptance proof.
- Permit one compact packet to close several findings only when they share one
  proven root cause, one change boundary, and one validation plan. Unrelated
  findings remain independently tracked.
- Generate traceability views from references; do not duplicate source text.
- Keep scenario and DoD IDs stable through restructuring so proof remains
  reusable and drift remains detectable.

### SCOPE-4 - Risk-proportional specialist routing (CHURN-101, FLOW-101)

Define substantive activation conditions in the mode registry:

- Full/high-risk delivery retains the canonical analyst -> UX -> design -> plan
  chain and the full quality/certification chain.
- Compact low-risk delivery invokes planning owners only for a changed decision
  in their ownership domain. Existing parent truth can be referenced rather
  than rewritten.
- UX remains mandatory for changed UI, user journeys, operator workflows,
  status/error language, and human approval flows. It is not invoked solely to
  restate that a backend-only implementation has no UX delta.
- A skipped phase requires a typed `notApplicable` record with registry rule,
  evaluated surface, reason, source revision, and guard validation. Free-form
  phase stubs do not satisfy completion.
- `bubbles.validate` always runs; audit requirements follow the assurance
  profile and never disappear through relevance routing.
- Publish one generated diagnostic routing table mapping trigger, owner,
  expected output, and next action. `clarify`, `grill`, `spec-review`, `gaps`,
  `harden`, `stabilize`, `code-review`, and `system-review` must each have one
  primary trigger; composed review modes declare their deliberate overlap.

### SCOPE-5 - Registry-derived execution and contradiction lint (FLOW-101)

- Derive required specialist phases directly from resolved `phaseOrder`,
  `neverSkip`, relevance rules, status ceiling, and transition-audit profile.
- Remove the hardcoded mode-to-specialist `case` table from
  `state-transition-guard.sh`.
- Compile one typed input-classification decision table for structured,
  continuation, continue, vague, and framework requests. Agent prose points to
  that table instead of restating ordering rules.
- Resolve the UX conditionality conflict and the G070/G073 labeling drift.
- Add a contradiction lint that compares agent/shared prose anchors with the
  registry and rejects unreachable branches, wrong gate IDs, unknown modes,
  and conflicting MUST-level statements.

### SCOPE-6 - Effective prompt-bundle budgets (CTX-101)

- Promote `effective-bundle-measure.sh` from report-only to a blocking budget
  for orchestrators and a warning budget for specialists during rollout.
- Budget transitive bytes, lines, directive count, and duplicate normative
  statements, not only the root agent file.
- Move stable decisions into scripts/registries and replace repeated prose with
  short typed references.
- Load skills and detailed procedures on trigger, not universally.
- Require one primary trigger per routing branch so multiple diagnostic agents
  do not activate for the same reason unless the mode explicitly composes them.
- Initial target: reduce the `bubbles.workflow` measured transitive bundle by at
  least 50% without removing any invariant or reducing held-out adherence.

### SCOPE-7 - One-pass proportional validation (VAL-101)

- Make `--tier=core` the routine local pre-push path only after full validation
  becomes mandatory in protected CI for every proposed source revision.
- Run full `framework-validate` once per exact revision. `release-check` may
  reuse its signed/content-addressed result only when source SHA, dirty-tree
  state, generated-artifact digest, policy digest, platform, and toolchain all
  match; otherwise it reruns.
- Run full validation on both Ubuntu and macOS in CI.
- Execute hermetic independent selftests in a bounded worker pool with stable
  ordered reporting.
- Share immutable install fixtures across provenance/trust tests; each mutating
  test receives an isolated copy-on-write view.
- Add per-check latency budgets and trend output. A timeout is a failure, not a
  skipped pass.

### SCOPE-8 - Signed, dependency-aware installation (SUPPLY-101)

- Make versioned release artifacts the documented default; keep `main` only as
  an explicit development channel.
- Publish an independently signed release digest/manifest and verify it before
  extracting or copying any file.
- Validate the release-manifest schema and every managed-file checksum before
  installation.
- Fail before mutation when required dependencies are absent or incompatible.
  Report required, optional, and feature-specific dependencies separately.
- Check Python >=3.10 before registering MCP; check `yq` v4 and `jq` before
  claiming full governance readiness; check `perl`, `tar`, and SHA-256 tooling
  before their first use.
- Preserve current downstream drift checks as post-install defense in depth.

### SCOPE-9 - Mandatory assurance after an adoption window (DEPLOY-101)

- Add an explicit assurance-adoption version to release-train and deploy
  contracts.
- Before that version, missing metadata is a visible migration warning. At and
  after it, missing `certification.assurance`, missing manifest attestation,
  missing parser, or missing evidence digest is a deployment refusal.
- Production and assured profiles fail closed immediately once migrated.
- Complete the knb-owned adapter path that emits the build-manifest attestation
  and invokes `deploy-manifest-assurance-lint.sh` in preflight.
- Verify the manifest's evidence digest against a resolvable certification
  receipt, not merely presence of a string.
- Prototype remains universally undeployable; fast deploys only where the
  target floor and risk class permit it.

### SCOPE-10 - Generated management and documentation truth (DOC-101)

- Generate agent, prompt, MCP tool/resource, mode, recipe, profile, and managed
  file counts from canonical registries/directories.
- Make the recipe catalog fail when a non-support recipe is unlisted or a link
  is stale.
- Add semantic rendering tests for multiline YAML so generated tables cannot
  emit a literal `>` as a summary.
- Introduce one machine-readable bug disposition ledger. `BUGS.md`, changelog,
  issue status, and capability status become generated/read-only views.
- A bug cannot remain `reported` when its defining regression is present and
  passing without an explicit reconciliation finding; conversely, passing code
  alone cannot mark it closed without required verification.
- Add cross-surface claim tests for installation behavior, prerequisites, MCP
  inventory, adoption profiles, source-repo command entrypoints, and scaffolded
  files.

### SCOPE-11 - Gate-strength taxonomy (GATE-101)

Classify each gate as exactly one of:

- `mechanical-blocking`;
- `mechanical-advisory`;
- `behavioral-contract`;
- `conditional-noop`;
- `external-enforcement`.

Publish counts by class and applicability instead of presenting the total as
equivalent mechanical controls. Prioritize converting anti-fabrication,
ownership, certification, and deployment behavioral rules into mechanical
blockers. A gate may keep its ID while its enforcement strengthens. The
classification pass MUST also reconcile each gate's registry-declared enforcer
against the check that actually runs and correct mismatches — for example G072,
which names `state-transition-guard.sh Check 12` but is not enforced by it
(Check 12 is duplicate/fabrication detection).

### SCOPE-12 - Modular CLI and guard internals (CLI-101)

- Keep `cli.sh` as the stable public dispatcher but move command families into
  independently tested modules: status/query, policy/profile, runtime, trust,
  upgrade/install, hooks, metrics, and framework validation.
- Extract transition-guard checks behind a typed check registry with declared
  inputs, outputs, timeout, applicability, and gate IDs.
- Replace ad hoc JSON/YAML grep parsing on security- or trust-relevant paths
  with structured parsers; fail closed when the parser is unavailable.
- Preserve all command names, exit semantics, and downstream compatibility
  through contract tests before removing old implementations.

### SCOPE-13 - Host dispatch-failure checkpointing (HOST-101)

Bubbles cannot fix the upstream serializer, so harden around it:

- Persist a dispatch intent before every `runSubagent` call and a result only
  after a valid envelope returns.
- A host 400/serialization failure leaves the phase `not_started` or
  `interrupted`, never completed.
- Preserve the exact unstarted dispatch queue and finding ledger in a compact
  continuation envelope suitable for a fresh user turn.
- Dispatch early in a turn before accumulating large tool outputs when the
  runtime is known vulnerable.
- Keep the upstream issue and workaround visible in doctor/health output; do
  not claim an in-repo fix for an external defect.

### SCOPE-14 - Held-out quality and efficiency benchmark (all gaps)

Use the shipped eval harness and held-out isolation guard to compare the current
full process, the refactored full process, and the compact eligible process.

Quality metrics (must not regress):

- false terminal transitions;
- fabricated or unresolvable evidence accepted;
- escaped blocking findings;
- scenario/DoD/test traceability coverage;
- wrong test-category acceptance;
- ownership or certification-authority violations;
- high-risk work incorrectly admitted to compact delivery.

Efficiency metrics (must improve for eligible work):

- wall-clock time to first validated result;
- tool calls and agent invocations;
- number and bytes of authored planning artifacts;
- repeated evidence bytes;
- duplicate validation executions;
- context bundle bytes and compaction events.

Release criteria:

- zero quality regression on every adversarial fixture;
- zero compact admission for the high-risk corpus;
- zero metadata-only evidence acceptance;
- full path behavior remains backward-compatible;
- compact eligible fixtures show a material improvement, with an initial target
  of at least 30% lower median agent/tool calls and authored artifact bytes;
- any failed quality criterion blocks rollout regardless of efficiency gain.

## How specification churn is reduced

| Current cost | Proposed replacement | Assurance retained or improved |
| --- | --- | --- |
| Six files for every code finding | Three-file compact packet for mechanically low-risk deltas | Same outcome, scenario, test, DoD, state, and audit semantics |
| Parent requirements copied into each bug | Stable parent anchors + delta-only contract | Digest detects parent drift |
| Raw output pasted under many DoD items | One raw content-addressed receipt + explicit DoD-ID bindings | Stronger current-session and hash verification |
| One bug folder per symptom | Group only findings with one proven root cause/boundary | One-to-one finding accounting remains |
| Every planning owner invoked ceremonially | Registry-triggered substantive owners + typed N/A records | Full chain remains for elevated risk |
| Full validation executed twice before push | Core local check + one full protected-CI/release receipt per exact revision | Full assurance still required before release |
| Repeated prompt law across many files | Registry/script SST + short references | Contradiction lint strengthens adherence |

## Migration and rollout

1. **Phase A - Repair proof before reducing ceremony.** Implement SCOPE-1 and
   its adversarial regressions first. No compact packet can ship while the weak
   tool-log fallback remains accepted.
2. **Phase B - Make current full delivery registry-derived.** Implement
   SCOPE-5 and SCOPE-6 without changing packet shape or phase applicability.
3. **Phase C - Benchmark the unchanged full path.** Establish SCOPE-14 baseline
   metrics and mutation corpus.
4. **Phase D - Add compact packets default-off.** Implement SCOPE-2 through
   SCOPE-4 behind `compactPacketPolicy: advisory`, then run held-out comparison.
5. **Phase E - Enable compact only for proven low-risk classes.** Move to
   `compactPacketPolicy: enabled` only after all quality criteria pass.
6. **Phase F - Optimize validation and implementation internals.** Implement
   SCOPE-7, SCOPE-10, SCOPE-11, and SCOPE-12 with output parity tests.
7. **Phase G - Harden trust boundaries.** Implement SCOPE-8, then route the
   concrete adapter portion of SCOPE-9 to knb ownership.
8. **Phase H - Runtime resilience.** Implement SCOPE-13 and retain the upstream
   issue until host behavior is independently fixed.

No existing full packet is migrated automatically. Historical artifacts remain
readable. Compact packets are additive and can be promoted to full packets
losslessly when risk changes.

## Risks and mitigations

- **R1 - Compact becomes a shortcut.** Mechanical fail-closed eligibility,
  adversarial high-risk fixtures, and automatic promotion to full.
- **R2 - Evidence references hide missing raw proof.** Guard-time object
  resolution and hash verification; absent object blocks.
- **R3 - Shared receipts overclaim several DoD items.** Stable DoD IDs and
  explicit per-claim bindings; no token inference.
- **R4 - Phase relevance skips a necessary specialist.** Registry rules,
  changed-surface record, validate review, and mutation tests per activation
  trigger.
- **R5 - Cached validation masks a change.** Cache key includes source, dirty
  state, generated outputs, policy, platform, and toolchain; mismatch reruns.
- **R6 - Prompt reduction drops an invariant.** Effective-bundle diff plus
  held-out instruction-adherence and negative tests before deletion.
- **R7 - Parallel tests race.** Hermetic classification, bounded workers,
  isolated mutable fixtures, deterministic aggregation, immediate fallback to
  sequential on shared-state detection.
- **R8 - Signed install adds operator friction.** One preflight command and
  precise dependency remediation; no silent downgrade to unsigned.
- **R9 - Bug grouping hides independent work.** Root-cause and boundary
  identity are required; validate can split the packet before certification.
- **R10 - Management views auto-close incorrectly.** Code/test evidence can
  propose reconciliation but only the owning status transition closes it.

## Acceptance criteria when implemented

- A mutation fixture with a successful unrelated command cannot satisfy a DoD
  item through shared words.
- A receipt with missing raw output, wrong session/spec/scope/DoD ID, stale
  input, malformed JSON, or unknown freshness blocks certification.
- The `**Claim Source:**` provenance taxonomy (G072) is enforced by a guard
  check on every `[x]` DoD item, and each registry gate's declared enforcement
  mechanism matches the check that actually runs.
- Every high-risk classifier fixture selects the full packet and full mode.
- A low-risk compact fixture retains scenario, assertion, test-category, DoD,
  finding, ownership, validation, and audit parity with the full fixture.
- Converting a compact packet to full loses no IDs, decisions, findings, or
  evidence links.
- Required specialist phases are derived from the resolved registry; adding a
  mode cannot silently bypass phase-completion enforcement.
- Input classification and UX applicability have one non-contradictory
  contract with executable branch tests.
- Full protected CI passes on Linux and macOS for the same revision.
- Release check does not rerun an already valid full result for the exact same
  revision, but any relevant change invalidates that result.
- Installer refuses malformed, unsigned, checksum-mismatched, or
  dependency-incompatible payloads before mutating the target repo.
- Adopted deployment targets refuse missing assurance metadata and missing
  assurance tooling.
- Public counts, catalogs, scaffold claims, capability state, and bug status
  agree with canonical machine-readable sources.
- The held-out benchmark satisfies every quality criterion and the efficiency
  threshold before compact delivery is enabled by default.

## Files to touch on approval

Ownership is explicit; this proposal does not authorize cross-owner edits.

- **Evidence and certification:** `bubbles.implement` / `bubbles.test` own
  `tool-log.sh`, receipt storage, bridge, and tests; `bubbles.validate` owns
  certification consumption; `bubbles.audit` independently reviews the new
  proof contract.
- **Packet/profile design:** `bubbles.analyst` owns requirements,
  `bubbles.design` owns the packet schema/design, `bubbles.plan` owns templates
  and rollout scopes; `bubbles.validate` owns terminal-state compatibility.
- **Workflow registry and agents:** `bubbles.plan` owns planning workflow
  contract changes; framework implementation changes route through
  `bubbles.implement`; agent ownership lint and workflow registry selftests
  enforce parity.
- **Validation/CLI/install:** `bubbles.devops` owns CI, hook, release, and
  installer execution changes; `bubbles.test` owns cross-platform and
  adversarial regression coverage.
- **Deployment adapter:** framework contract changes are upstream Bubbles work;
  concrete target adapter changes route to the knb-owned deployment surface.
- **Managed docs:** `bubbles.docs` owns installation, MCP, catalog, generated
  status, and operator guidance updates.

Expected source surfaces include:

`bubbles/scripts/{tool-log,evidence-receipt-check,evidence-tool-log-bridge,state-transition-guard,artifact-lint}.sh`,
`bubbles/schemas/`, `templates/`, `agents/bubbles_shared/`,
`bubbles/workflows{.yaml,/modes.yaml}`, `bubbles/agent-capabilities.yaml`,
`bubbles/scripts/{framework-validate,release-check,cli}.sh`, `install.sh`,
`.github/workflows/`, `bubbles/capability-ledger.yaml`, `BUGS.md`, and the
managed docs/generated surfaces.

## Owner decisions required before implementation

1. Approve or reject the `compact-v1` packet principle. If rejected, retain the
   evidence, registry, validation, trust, context, and documentation scopes;
   those improvements stand independently.
2. Select the durable raw-evidence backend policy: repo content-addressed
   objects, signed CI artifacts, or a pluggable combination. Metadata-only is
   not an option.
3. Confirm the rollout threshold for enabling compact packets after held-out
   evaluation. Recommended starting requirement: zero quality regressions and
   at least 30% median efficiency improvement on eligible fixtures.
4. Confirm the assurance migration date/version after which missing deploy
   metadata becomes an unconditional refusal.

## Program definition of done

This proposal is complete only when Bubbles can demonstrate, on held-out and
adversarial fixtures, that eligible low-risk work reaches the same or higher
assurance with materially fewer artifacts, agent/tool calls, repeated evidence
bytes, and wall-clock time; high-risk work remains on the unchanged full path;
and no terminal state can be reached with fabricated, stale, metadata-only, or
unresolvable proof.
