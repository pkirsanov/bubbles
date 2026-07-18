# Bug Fix Design: BUG-024 Traceability Sequential Scope And Tiered DoD

## Ownership Status

This is the active technical design reconciled by `bubbles.design`. It resolves
the two confirmed defects as one traceability contract and supersedes the
intake-only ownership disclaimer. It makes no implementation, test, release,
downstream-installation, or certification claim. Source, tests, planning
artifacts, reports, release bytes, and downstream managed copies remain owned
by their registered specialists.

## Design Brief

### Current State

The guard resolves layout, loads every per-directory `scope.md`, and uses that
filesystem set for every traceability pass. `state.json` contributes only the
layout string. `extract_dod_items()` then treats any level-1 through level-4
heading as the end of DoD, even when that heading is a deeper tier inside the
selected section.

### Target State

The guard has two closed evaluation contexts:

1. **all-scope**, which remains the default and analyzes every resolved scope;
2. **current-scope closure**, explicitly requested and derived from validated
   state, which omits only exact not-started descendants of the current scope.

Both contexts resolve one scope-analysis universe before G057/G059, delivery
traceability, and G068. DoD extraction records heading depth, retains deeper
tiers, ignores false headings in fences/comments, and stops at a sibling or
ancestor boundary. The terminal `state-transition-guard.sh` remains all-scope,
but its G041 and G068 DoD consumers use the same selected-depth semantics so a
tiered DoD cannot mean one thing during traceability and another at promotion.

### Patterns To Follow

- Preserve the one-argument all-scope interface and done-spec audit behavior.
- Follow BUG-018's exact heading recognition, depth-aware boundary, fence and
  HTML-comment exclusion, checked caller status, and normal final summary.
- Preserve the production/selftest-supported DoD start depths 1 through 4;
  BUG-024's level-2 and level-3 scenarios are required boundary examples, not
  a compatibility narrowing.
- Parse version-3 `state.json` through `jq`; never infer graph state with grep.
- Build disposable complete packets and invoke the real production guard.
- Keep source-only regression numbering at the verified free `test_31` path.

### Patterns To Avoid

- No automatic skip based only on `not_started`.
- No caller-supplied scope ID or list.
- No fallback from malformed state to all scopes, current scope, or an empty
  set.
- No duplicated implementation parser in regression code.
- No broad rewrite of scenario matching or G068 word-overlap logic.
- No edit to BUG-018 or its `test_25` regression.
- No independent applicability filter inside an individual traceability pass.
- No current-scope option on `state-transition-guard.sh` or any terminal
  validation, audit, done-spec, or promotion consumer.

### Resolved Decisions

- G094 proportionality applies because one applicability contract is shared by
  G057/G059, delivery mapping, report evidence, and G068, while one DoD section
  contract is shared by traceability and terminal transition checks.
- The public contexts are exactly default/all-scope and valueless
  `--current-scope`; callers cannot name a scope or omission set.
- `execution.currentScope` selects the active record, an execution registry may
  supply live nonterminal state for current v3 compatibility, and
  `certification.completedScopes` remains the only completion authority.
- Active-scope mode supports single-file packets only when every state record
  maps one-to-one to a numbered split unit. Unprovable mapping is exit `2`.
- State or context refusal exits `2` before analysis. Evaluated traceability or
  DoD findings exit `1` through the normal aggregate summary. A clean evaluated
  universe exits `0`.
- `state-transition-guard.sh` requires a source change in Check 4A and Check 22;
  a read-only audit alone would leave the same tiered parser defect at terminal
  promotion.

### Open Questions

None. Planning must reconcile its change boundary and test matrix to this
design before RED or implementation work begins.

## Root Cause Analysis

### Defect 1: Discovery And Applicability Are The Same Array

The controlling path is:

```text
detect_scope_layout
  -> find every scopes/*/scope.md into scope_files
  -> build every scope_analysis_files unit
  -> count all scope scenarios for G057/G059
  -> run delivery mapping over every analysis unit
  -> run G068 over every analysis unit
```

There is no stage that represents why a scope is applicable to this invocation.
Because filesystem discovery is reused directly, the guard has only feature-wide
semantics. The state fields that distinguish Feature 007 Scope 01 from its
eight not-started descendants are never read.

The defect affects more than the delivery loop. Filtering only
`scope_analysis_files` would leave G057/G059 global and could still make a
descendant manifest/test gap block the active scope. Applicability must be
resolved once and consumed by every pass.

### Defect 2: DoD Termination Ignores Selected Depth

The current extractor enters on this pattern:

```text
^#{1,4}.*Definition of Done|^#{1,4}.*DoD
```

and exits on:

```text
^#{1,4}[ ]
```

For a level-3 DoD, a level-4 tier heading satisfies the exit expression. The
extractor therefore reaches zero checkboxes. This is a boundary bug, not a
fuzzy matching bug: `scenario_matches_dod()` never receives any items.

### Coupling

The active Scope 01 delivery mappings are valid, but the all-scope loop adds 28
descendant findings. G068 then adds one empty-DoD finding per scope. The two
decisions compose into the observed 37-finding result even though they require
separate local repairs.

## Current Production Source Anchors

The design binds to the current canonical implementation rather than the
Research Lab packet shape:

- `bubbles/scripts/traceability-guard.sh::scope_files` discovers every
  per-directory `scope.md` and currently feeds the G057/G059 count loop.
- `build_scope_analysis_units` populates `scope_analysis_files`; the delivery,
  concrete-file, report-reference, and G068 loops iterate that separate array.
- `extract_dod_items` uses fixed any-heading termination and returns no explicit
  missing, ambiguous, or parser-failure status.
- The `--- Scenario Manifest Cross-Check (G057/G059) ---` pass validates global
  manifest links before the per-analysis-unit delivery loop.
- `PASS 2: Gherkin -> DoD Content Fidelity (Gate G068)` independently reuses
  every analysis unit and the broken extractor.
- `bubbles/scripts/state-transition-guard.sh` Check 4A has the same fixed
  any-heading DoD boundary for G041, and Check 22 duplicates the fixed-boundary
  extraction for G068.

Research Lab Feature 007 is a consumer fixture proving the failure shape. No
path, scope count, status, or dependency from that downstream packet is encoded
in production logic.

## Capability Foundation

G094 applies proportionally. This is not a plugin framework: it is a closed
internal data contract that prevents five existing passes and two terminal
consumers from inventing different meanings for the same scope or DoD section.

### Applicable Scope Universe Contract

The resolver produces one immutable `ApplicableUniverse` before any
traceability pass runs.

| Field | Contract |
| --- | --- |
| `context` | Exactly `all-scopes` or `current-scope`. |
| `layout` | Exactly `single-file` or `per-scope-directory`. |
| `currentKey` | Null for all-scope; one resolved unit key for current-scope. |
| `records` | Ordered `ScopeRecord` list for every discovered analysis unit. |
| `applicableKeys` | Ordered keys consumed by every pass. |
| `omittedKeys` | Only exact not-started transitive descendants, with the fixed reason `not-started-descendant`. |
| `scenarioIds` | Stable IDs extracted only from applicable records for the G057/G059 projection. |

Each `ScopeRecord` contains only the fields the existing passes need:
`unitKey`, declared aliases, analysis path, display label, report path, status,
resolved dependency keys, completion membership, applicability, and omission
reason. There is no provider interface, callback registry, or public serialized
record format.

### DoD Section Contract

One closed `DoDExtraction` contract carries `status` plus ordered checkbox item
text. It owns accepted starts, selected-depth termination, fence/comment
exclusion, ambiguity, and read failure. G068 matching continues to own only the
existing trace-ID and word-overlap decision; it does not reinterpret section
boundaries.

### Foundation-Owned Invariants

- Discovery never implies applicability.
- State selection never comes from caller-supplied identity.
- A scope omitted from one applicable pass is omitted from every applicable
  pass in that invocation.
- Completion is certified state, not an execution-layer guess.
- Reduced context cannot execute after validation or audit begins.
- DoD extraction status is handled explicitly under `set -euo pipefail`.
- All-scope consumers never depend on active execution state.

## Concrete Implementations

### Default And Explicit All-Scope Resolution

The one-argument form and `--all-scopes` create records from every discovered
analysis unit, mark every record applicable, and do not require a valid
execution registry. This is the compatibility path for direct maintainers,
planning, `bubbles.validate`, audits, done-spec consumers, and final promotion.

### State-Bound Current-Scope Resolution

`--current-scope` validates version-3 state, resolves the state-selected current
unit and dependency graph, computes transitive descendants, and omits only the
records satisfying the closed omission predicate. It has no scope argument and
no environment override.

### Traceability Pass Projection

G057/G059 scenario-manifest checks, scenario-to-Test-Plan mapping, concrete
test-file checks, report-reference checks, and G068 each iterate the same
`applicableKeys` projection. They may derive pass-local data from a record, but
they cannot rediscover scope files or apply another status filter.

### Terminal DoD Consumers

`state-transition-guard.sh` never receives reduced scope context. Its Check 4A
G041 scanner and Check 22 G068 extraction adopt the same `DoDExtraction`
semantics locally, while retaining their terminal all-scope input and existing
matching thresholds. A small parity matrix binds both implementations; no
general Markdown framework is introduced.

### Variation Axes

| Axis | Closed variants | Foundation ownership |
| --- | --- | --- |
| Evaluation context | all scopes; state-bound current scope | Context selection and omission predicate |
| Scope layout | per-scope directories; numbered single-file units | One-to-one unit mapping and deterministic order |
| Version-3 registry shape | canonical certification registry; compatible execution registry with certification cross-check | Precedence, normalization, contradiction refusal |
| Consumer | G057/G059; delivery/report mapping; traceability G068; terminal G041/G068 | Shared universe or section semantics; consumer-specific findings remain local |
| DoD start depth | existing supported ATX depths 1, 2, 3, 4 | Selected-depth boundary through level 6 |

### Planning Order Constraint

Because the active design separates the foundation from its consumers,
`bubbles.plan` must create a foundation-tagged scope for the normalized universe
and DoD extraction contracts, followed by one consumer-integration scope that
depends on it and wires traceability plus terminal parity. Planning may keep the
single-file packet layout because the resulting scope count remains below six,
but it cannot leave `test-plan.json` with `foundation: false` and one
undifferentiated scope.

## Scope Evaluation Contract

### Invocation Surface

The design reserves these closed forms:

```text
bash bubbles/scripts/traceability-guard.sh <feature-dir>
bash bubbles/scripts/traceability-guard.sh <feature-dir> --all-scopes
bash bubbles/scripts/traceability-guard.sh <feature-dir> --current-scope
```

No argument and `--all-scopes` are behaviorally identical. `--current-scope`
accepts no value. The feature directory remains the first positional argument.
Duplicate contexts, both contexts together, `--current-scope=<value>`, an
additional positional value, and every unknown option exit `2` with usage.

Public exits are closed:

| Exit | Meaning |
| ---: | --- |
| `0` | The selected universe was evaluated and has no finding. |
| `1` | Evaluation completed and one or more traceability/DoD findings reached the normal summary. |
| `2` | Usage, state, layout, parser prerequisite, or reduced-context contract refusal prevented a trustworthy evaluation. |

There is no `--skip`, `--force`, `--ignore`, `--allow-once`, scope-ID value,
path selector, status override, or environment-variable context control.

### Why Context Is Explicit

Automatic filtering from state was rejected. It would silently change direct
guard and planning-time behavior and could make a caller intending final
validation receive a reduced result. Explicit context preserves compatibility
and makes the final/all-scope contract observable.

### State Source And Validation

For `--current-scope`, `jq` reads a closed version-3 contract. Missing `jq`,
malformed JSON, or any wrong JSON type is exit `2`; grep-based state parsing is
not a fallback.

| State field | Authority in current-scope context |
| --- | --- |
| `.version` | Must be numeric `3`. Other versions are unsupported by this additive context. |
| `.scopeLayout` | Must agree with filesystem layout resolution when present. Filesystem/index evidence cannot contradict it. |
| `.workflowMode` | Must be a non-empty string; no caller or environment replacement is accepted. |
| `.status`, `.certification.status` | Must both exist, agree, and be exactly `in_progress` or `blocked`. This alone excludes every terminal mode status. |
| `.execution.currentScope` | Sole current-scope selector; string or positive integer; null/missing is invalid. |
| `.execution.currentPhase` | Must be a non-empty string and must not be `validate`, `audit`, or `finalize`. |
| `.execution.completedPhaseClaims`, `.certification.certifiedCompletedPhases` | If either contains `validate` or `audit`, reduced context is refused even when `currentPhase` later moved to docs or another tail phase. |
| `.execution.scopeProgress` | Compatible live registry. If the key exists, it must be a non-empty valid array and becomes the operational registry; an invalid present value never falls through. |
| `.certification.scopeProgress` | Canonical registry and certification cross-check. Required, non-empty, and identity-complete. It is the operational registry only when `.execution.scopeProgress` is absent. |
| `.certification.completedScopes` | Sole completed-scope set. Required array; every entry must resolve to exactly one record. |

`scopeInventory`, top-level `completedScopes`, artifact prose, and directory
ordering are not substitute registries in version 3. Supporting another shape
requires a later explicit contract change, not permissive probing.

Each selected registry entry requires `scope`, `status`, and `dependsOn`.
`scope` is a positive integer or non-empty string. Optional `scopeId` is a
second exact alias for the same record. Numeric `scope` values and digit-only
string references normalize to their base-10 integer identity; slugs remain
byte-exact. Every alias must resolve to one record and no alias may identify two
records. `dependsOn` must be an array of declared aliases; unknown, duplicate,
self, or ambiguous edges fail. The complete graph must be acyclic.

Per-directory records normalize `scopeArtifact` to a `scope.md` path or
`scopeDir` to its child `scope.md`. If both exist they must normalize to the
same safe feature-relative path. Paths must not be absolute, contain traversal,
or escape the feature after physical resolution. Every discovered unit and
every registry record must map one-to-one. Where both registries declare an
identity, dependency, or path field, their normalized values must agree.

The operational registry owns live nonterminal statuses. Status values are
exactly `not_started`, `in_progress`, `blocked`, or `done`. Certification owns
completion:

1. The normalized `done` set in the operational registry must equal
  `certification.completedScopes`.
2. The normalized `done` set in `certification.scopeProgress` must equal the
  same completed set.
3. No non-completed record may be `done` in either registry; no completed
  record may carry another status.
4. The current record resolves exactly once and its operational status is
  `in_progress` or `blocked`.
5. Every transitive prerequisite of the current record is `done` and therefore
  appears in both certified completion surfaces.
6. Additional `in_progress` or `blocked` records are not rejected or omitted;
  DAG concurrency and contradictory descendant activation remain visible to
  traceability rather than becoming a hidden state shortcut.

Missing, malformed, empty, duplicate, unknown, cyclic, filesystem-divergent,
completion-contradictory, phase-final, or terminal state emits one
state-qualified refusal and exit `2` before any scope pass. The guard prints no
partial pass set and never falls back to all, one, or zero scopes.

### Applicability Algorithm

Let `C` be the validated current scope and `Desc(C)` its transitive dependency
descendants. With `dependsOn` edges pointing from a scope to its prerequisites,
`S` is in `Desc(C)` exactly when following `dependsOn` edges from `S` can reach
`C`. A resolved scope `S` is omitted only when:

```text
S is in Desc(C)
and S.status == not_started
and S is absent from the certified completed set
```

Every other scope remains applicable. This deliberately keeps the current
scope, completed prerequisites, independent scopes (including not-started
independent scopes), active or blocked descendants, done descendants, and any
scope with contradictory completion state visible or refused. Zero applicable
records is impossible after valid current resolution and is still checked as
an internal contract failure.

The output must identify context and counts without presenting omission as a
pass claim, for example:

```text
Traceability context: current-scope
Current scope: 01-capability-foundation
Applicable scopes: 1
Not-started descendant scopes outside this closure context: 8
```

### One Resolved Scope Universe

Discovery creates one internal record per analysis unit; state validation
enriches those same records. Both layouts produce the foundation record shape.
Every pass receives `applicableKeys` and cannot iterate `scope_files`,
`scope_analysis_files`, `find`, or raw state independently after resolution.

For G057/G059, derive the applicable scenario-ID set from those units and
validate matching manifest records, linked tests, and evidence refs only for
that set. The manifest must be valid JSON in either context. In current-scope
context, each applicable scenario needs a stable ID resolving to exactly one
manifest entry; absence or duplication fails. Extra manifest entries belonging
only to omitted descendants remain inert, including their not-yet-created test
or evidence paths, and cannot satisfy a missing applicable entry. In all-scope
context the projection is complete and preserves the existing complete-packet
obligation.

## Heading-Aware DoD Contract

### Accepted Starts

Outside fenced code and HTML comments, preserve the current case-sensitive DoD
start predicate on valid ATX heading depths 1 through 4: the visible heading
title contains `Definition of Done` or `DoD`. Existing suffixes such as
`- Tiered Validation` remain accepted, and the managed selftest's
`#### Definition of Done` remains valid. Depth 5/6 headings, prose lines, and
token matches inside ignored regions are not starts.

The implementation recognizes a valid ATX heading by counting one through six
leading `#` bytes and requiring end-of-line or horizontal whitespace next. It
tracks backtick/tilde fences and multiline HTML comments using the same
portable discipline as BUG-018. This intentionally removes false starts inside
examples without narrowing real level-1 through level-4 starts.

### Boundary Rule

After selecting a start depth `D`, retain content until the next valid ATX
heading outside ignored regions whose depth is `<= D`. The boundary heading is
not emitted.

- `## Definition of Done` retains `###` through `######` tiers.
- `### Definition of Done` retains `####` through `######` tiers.
- `# Definition of Done` retains level-2 through level-6 tiers.
- `#### Definition of Done` retains level-5 and level-6 tiers.
- A same-depth or shallower heading ends the section.

### Checkbox Rule

Preserve the existing checked/unchecked checkbox grammar and item text bytes.
Only unindented lines beginning with `- [x]` or `- [ ]` followed by one space
are items; uppercase `X`, nested bullets, and non-checkbox bullets retain their
existing non-item meaning for G068. Checkboxes inside fences/comments or after
the boundary are excluded. A
recognized section with no real checkbox is distinct from a missing section or
extractor failure. The entire analysis unit is scanned for accepted starts so a
second accepted DoD section is ambiguous rather than silently ignored.

### Closed Extractor Status

The DoD extractor should mirror the BUG-018 explicit-status approach:

| Status | Meaning | Caller behavior |
| ---: | --- | --- |
| `0` | Exactly one accepted DoD section found | Use zero or more extracted checkbox items. Empty stdout is rowless. |
| `3` | No accepted DoD section | Emit missing-DoD finding. |
| `4` | More than one accepted DoD section in one scope unit | Emit ambiguous-DoD finding. |
| other nonzero | Read/parser failure | Emit extraction-failure finding. |

The caller captures output in a checked `if` assignment, records the status
immediately, and branches before inspecting stdout. Status `0` with empty
stdout emits the rowless/no-DoD-items fidelity finding. Missing, rowless,
ambiguous, and parser failure each emit exactly one scope-qualified finding and
all reach the normal aggregate summary and public exit `1`; none can terminate
the shell early or become a successful empty section.

## Single-File Layout

The existing split of `scopes.md` into temporary `## Scope N:` units remains.
All-scope context preserves current labels and ordering. Active-scope context is
supported only when all of the following prove identity-to-unit mapping:

1. Every executable unit starts with the existing exact numbered grammar
  `## Scope <positive-integer>:` and each number occurs once.
2. Every operational registry record declares a numeric `scope` alias and each
  number maps to exactly one split unit.
3. Registry numbers and split-unit numbers are equal as sets; optional aliases
  cannot redirect a number to another unit.
4. `execution.currentScope` resolves through the validated record aliases, not
  by searching heading text.
5. All units share `scopes.md` as source and top-level `report.md` as evidence;
  no temporary line range is accepted as persisted identity.

Free-form `## Scope:` headings, missing numbers, duplicate numbers, a state
record without numeric identity, or any set mismatch makes `--current-scope`
unsupported for that packet and exits `2`. Default/all-scope behavior remains
unchanged even when active mapping is unsupported.

## No-Scenario Behavior

- Applicable unit with no scenario: existing nonzero diagnostic.
- Omitted not-started descendant with no scenario: no active-closure finding.
- All-scope execution: the same descendant is applicable and the existing
  diagnostic returns.
- Zero applicable units is always a state/application error.

## Compatibility And Consumer Impact

### Direct Consumers

- `bubbles.validate` keeps using all-scope semantics.
- `done-spec-audit.sh` keeps using the one-argument all-scope form.
- planning, audits, finalization, direct maintainers, and terminal promotion
  keep existing all-scope behavior.
- `bubbles.plan` owns adding the valueless current-scope command to the active
  scope contract; `bubbles.implement`, `bubbles.test`, and regression owners may
  execute it before validation begins.
- An accidental current-scope request after validate/audit state is recorded
  refuses with exit `2`; the caller cannot downgrade it to all-scope implicitly.

### Existing Parsing

- BUG-018 Test Plan extraction, diagnostics, and `test_25` remain unchanged.
- Scenario row matching, path extraction, report matching, confidence
  classification, and G068 fuzzy thresholds remain unchanged.
- `state-transition-guard.sh` Check 4A and Check 22 are confirmed semantic
  consumers of the same broken boundary. `bubbles.implement` must change only
  their DoD section scanners; Check 4 completion counting, scope status,
  transition contracts, and reduced-context behavior remain unchanged.
- `state-transition-guard.sh` remains all-scope and gains no BUG-024 CLI option.
- `artifact-lint.sh` retains its planning-shape role and current canonical
  level-3 section check; BUG-024 does not turn it into another runtime parser.
- Concurrent G040/G073 edits already present in `state-transition-guard.sh` are
  protected. The implementation owner must re-read current bytes and apply a
  surgical Check 4A/22 change without reverting or absorbing those edits.

### Release Consumers

- Managed payloads: `traceability-guard.sh`,
  `traceability-guard-selftest.sh`, `state-transition-guard.sh`, and
  `state-transition-guard-selftest.sh` remain installer-managed canonical
  bytes. No new generic parser file is introduced.
- Source-only: `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`
  is tracked in the release source-only inventory and never installed.
- Framework validation registers `test_31` once with `run_check_self_only`,
  adjacent to the existing BUG-018/019/021/023 regression registrations. The
  managed selftests continue through their existing registrations.
- Install provenance adds direct managed/source-only assertions for every
  changed class; it does not redefine generic manifest discovery.
- The capability ledger records the state-bound applicable-universe capability
  and its traceability/state-transition consumers. Generated capability docs
  are regenerated by their owner rather than edited as design work.
- `bubbles/release-manifest.json` is regenerated only by `bubbles.releases`
  after all managed/source-only inputs and registrations are stable. It remains
  untouched during design, planning, RED, and implementation convergence.
- Downstream delivery uses supported install/upgrade from the canonical
  release. Canonical-source replay precedes installed replay; no downstream
  `.github/bubbles/**` byte is copied or patched manually.

## Data, Configuration, And Migration

There is no persisted application data, network API, environment setting,
feature flag, or state migration. `ApplicableUniverse`, `ScopeRecord`, and
`DoDExtraction` exist only for one process invocation. `state.json` and
scenario-manifest data are read-only inputs.

The current-scope context is additive and supports only version 3. Existing
packets do not need rewriting to retain default all-scope behavior. A v3 packet
requesting reduced context must satisfy one of the two explicit registry shapes
and all cross-checks; compatibility is a reader contract, not a migration or a
silent normalization write.

Single-file temporary units keep the existing cleanup trap. New normalized
record output must stay under process-owned temporary storage, never the feature
packet, release metadata, or a downstream repository.

## Security And Integrity

- State and manifest JSON are parsed as data through `jq`; no `eval`, sourced
  state, or shell interpolation is permitted.
- Feature-relative paths reject absolute paths, traversal, and physical escape
  before any file is read.
- Scope identity and dependencies resolve through exact declared aliases, not
  fuzzy labels or caller strings.
- The active context cannot authorize omission through an environment variable
  or arbitrary path/status input.
- Malformed or contradictory state fails before analysis, so a corrupted
  control plane cannot accidentally produce a smaller successful universe.
- Test fixtures contain no credentials, production endpoints, monitoring
  writes, backup paths, release-train mutation, or downstream managed-file
  mutation.

## Observability And Failure Handling

This is a local CLI guard with no service telemetry or trace topology. Its
observable contract is deterministic stdout/stderr plus exit status:

- Every evaluated run prints context, current scope when present, discovered,
  applicable, and omitted-descendant counts before pass output.
- Omitted descendants are informational context, never `PASS` claims.
- State/usage refusals name the failed contract class and exit `2` without a
  partial traceability summary.
- Missing, rowless, ambiguous, and failed DoD extraction each name the scope,
  add one finding, and reach the existing final summary with exit `1`.
- Existing scenario, row, file, report, DoD, confidence, failure, and warning
  totals count only the applicable universe in current-scope context and every
  scope in all-scope context.
- No diagnostic prints raw JSON state or unrelated packet contents.

## Rollout, Compatibility, And Rollback

Rollout is additive: canonical source first, RED then GREEN, framework
registration/provenance, owner-generated release identity, supported upgrade,
and finally read-only downstream replay. No feature flag is introduced because
the one-argument behavior is unchanged and current-scope is explicit.

Compatibility invariants are:

- one argument and `--all-scopes` remain byte-for-byte equivalent in meaning;
- planning, validate, audit, done-spec, and final consumers stay all-scope;
- Test Plan extraction and BUG-018 bytes remain unchanged;
- G068 trace-ID and word-overlap thresholds remain unchanged in both guards;
- level-1 through level-4 DoD starts remain recognized outside ignored regions;
- public exits keep `0` pass, `1` findings, and `2` contract/usage refusal.

Rollback is one coherent release unit: traceability guard and selftest,
state-transition Check 4A/22 and selftest, `test_31` registration/provenance,
capability registration/docs, and generated release identity. A rollback must
restore the prior managed release as a unit; it must not retain a caller that
passes `--current-scope` against a guard version that lacks the option, and it
must never revert unrelated concurrent G040/G073 work. No data rollback or
state rewrite is required.

## Testing Strategy

### Persistent Regression

Reserve only:

`tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh`

`bubbles.test` must create it before implementation, invoke the real production
guard, and record causal RED. It must not source or copy a production
applicability or Markdown helper.

Every fixture is a complete disposable packet with state, scope files, reports,
scenario manifest, concrete tests, and DoD. Invalid fixtures vary one intended
dimension. Unique `mktemp -d` roots and cleanup traps isolate all bytes.

### Required Adversaries

- Seed one descendant gap that is absent only from valid active closure and is
  visible in default/all-scope execution.
- Change that descendant to `in_progress`, `blocked`, and `done`; each becomes
  applicable and exposes the gap.
- Seed a completed prerequisite gap; it always blocks.
- Seed an independent `not_started` scope; it remains applicable and blocks.
- Exercise both canonical `certification.scopeProgress` resolution and the
  compatible `execution.scopeProgress` resolution with matching certification.
- Exercise present-but-empty execution registry, identity-set mismatch,
  dependency/path mismatch, and operational/certified status contradiction.
- Exercise malformed JSON, absent registry/current scope, duplicate identity,
  unknown status, unknown dependency, cycle, filesystem mismatch, and
  completion contradiction.
- Exercise top-level/certification status mismatch, terminal status,
  validate/audit/finalize current phase, and prior validate/audit phase claims;
  every reduced-context request refuses with exit `2`.
- Exercise level-1 through level-4 DoD starts, with required level-2/3 nested
  tier cases, same-depth/shallower boundaries, fenced/comment false headings,
  rowless, missing, ambiguous, and injected parser failure.
- Exercise single-file proven mapping and each unsupported/ambiguous mapping,
  plus no-scenario behavior in active and all-scope contexts.
- Exercise duplicate/conflicting/valued/unknown CLI arguments and prove no
  bypass-shaped option is accepted.
- Prove state-transition G041/G068 parity by running the same DoD matrix through
  traceability G068 and state-transition Check 4A/22 while keeping the
  state-transition invocation all-scope.
- Rerun the byte-unchanged BUG-018 regression and all pre-existing managed
  selftest cases.

### Scenario-To-Test Intent

| Scenario | Required design assertion |
| --- | --- |
| SCN-BUG-024-001 | Current plus certified prerequisites and every non-omittable record form one pass universe. |
| SCN-BUG-024-002 | A certified prerequisite gap remains in every pass and blocks. |
| SCN-BUG-024-003 | Default/final, independent, active, blocked, and done descendant gaps remain visible. |
| SCN-BUG-024-004 | Every state, phase, graph, completion, path, and CLI contradiction refuses without fallback. |
| SCN-BUG-024-005 | Single-file active mapping is proof-based; all-scope/no-scenario compatibility remains. |
| SCN-BUG-024-006 | Level-2 nested tiers are retained and sibling/ancestor content excluded. |
| SCN-BUG-024-007 | Level-3 nested tiers are retained and sibling/ancestor content excluded. |
| SCN-BUG-024-008 | BUG-018 Test Plan extraction and regression bytes remain unchanged. |

Planning must add explicit level-1/level-4 compatibility, state-transition
G041/G068 parity, final-context refusal, and registry-shape rows; those are
design-derived coverage obligations, not new analyst scenarios.

### Validation Order

1. Test-owned final-byte RED against unchanged production.
2. Focused selected cases for active scope and DoD depth.
3. Full persistent regression.
4. Managed traceability and state-transition selftests, including DoD parity.
5. Regression-quality and no-bailout checks.
6. Bash syntax, macOS system Bash 3.2, and portability scan.
7. Byte-unchanged BUG-018 regression.
8. Done-spec audit, validate invocation, state-transition, and direct all-scope
  consumer canaries proving reduced context is absent.
9. BUG-024 artifact, freshness, traceability, and G094 gates after every
  planned physical test exists.
10. Full framework validation after source-only registration is stable.
11. Install provenance and release check after owner-generated metadata.
12. Canonical-source Research Lab replay, supported downstream upgrade, and
  installed replay without downstream mutation.

No focused check substitutes for final all-scope or release validation.

## Change Boundary And Ownership

| Surface | Intended change | Owner |
| --- | --- | --- |
| `bubbles/scripts/traceability-guard.sh` | Context parsing, state validation, unified applicability records, DoD extraction | `bubbles.implement` |
| `bubbles/scripts/traceability-guard-selftest.sh` | Managed active/all/DoD matrix | `bubbles.test` |
| `bubbles/scripts/state-transition-guard.sh` | Selected-depth DoD semantics in Check 4A and Check 22 only; all-scope remains mandatory | `bubbles.implement` |
| `bubbles/scripts/state-transition-guard-selftest.sh` | G041/G068 tiered DoD parity and unchanged terminal context | `bubbles.test` |
| `tests/regression/test_31_traceability_sequential_scope_and_tiered_dod.sh` | Persistent production-path regression | `bubbles.test` |
| `bubbles/scripts/framework-validate.sh` | One source-only registration | `bubbles.implement` |
| `bubbles/scripts/install-provenance-selftest.sh` | Managed/source-only assertions | `bubbles.test` |
| `bubbles/capability-ledger.yaml` | Applicable-universe capability and real consumer registration | `bubbles.implement` |
| generated capability projection | Regenerated from the ledger after source stability | `bubbles.docs` |
| managed docs and changelog | Public invocation and compatibility contract | `bubbles.docs` |
| `bubbles/release-manifest.json` | Generated identity after source stability | `bubbles.releases` |

This intake owns none of those edits.

## Alternatives And Tradeoffs

| Alternative | Decision | Reason |
| --- | --- | --- |
| Skip every `not_started` scope | Rejected | Hides independent/applicable gaps and can weaken final validation. |
| Infer active context automatically | Rejected | Changes default behavior and makes caller intent ambiguous. |
| Caller supplies a scope ID | Rejected | Becomes an arbitrary omission surface and can disagree with state. |
| Filter only the delivery loop | Rejected | G057/G059 and G068 would still evaluate a different universe. |
| Ignore every level-4 heading | Rejected | Breaks level-4 DoD starts and same-depth boundaries. |
| Rewrite Research Lab DoD headings | Rejected | Valid accepted artifacts must not compensate for a canonical parser defect. |
| Reuse BUG-018 test file | Rejected | BUG-018 owns a distinct regression contract and must remain unchanged. |
| Leave state-transition DoD parsing unchanged | Rejected | Terminal G041/G068 would still truncate the same tiered section and disagree with traceability. |
| Add a shared general Markdown parser library | Rejected | Only two narrow consumers need parity; a closed scanner contract plus parity tests avoids a new broad dependency. |
| Accept top-level or inferred completion fields | Rejected | Version 3 assigns completion authority to certification; permissive probing would hide contradictions. |

## Complexity Tracking

| Decision | Simpler alternative | Why required |
| --- | --- | --- |
| Explicit context plus fail-closed state graph | Filter on current directory name | Final and independent-scope integrity require real applicability semantics. |
| One scope record universe for all passes | Filter each loop independently | Independent filters can drift and hide different findings. |
| Depth-aware fence/comment parser | Stop at fixed heading regex | Tier headings and examples otherwise truncate or leak items. |
| Dual v3 registry reader with certification cross-check | Read only whichever `scopeProgress` appears first | Current active packets need live execution state, while completion must remain validate-owned and contradictions must block. |
| State-transition Check 4A/22 parity | Repair traceability only | Terminal promotion would retain the same parser defect and could disagree with the focused guard. |
| Persistent plus managed tests | One local fixture | Registration, installed payload, and direct behavior can regress independently. |

### Proportionality Decision

The foundation is required because the same applicability decision feeds five
traceability passes and the same DoD boundary semantics feed two production
guards. It remains deliberately internal and closed; a provider/plugin API or
general Markdown abstraction would exceed the demonstrated reuse.

## Risks And Open Questions

None blocking. The canonical v3 certification surface, the observed compatible
execution registry, terminal phase/status refusal, level-4 managed-selftest
compatibility, and state-transition semantic overlap have been resolved above.

The next owner is `bubbles.plan`, which must account for these planning-owned
findings before RED begins:

- `BUG024-P001-FOUNDATION-ORDERING`: replace the single undifferentiated scope
  and `foundation: false` machine entry with foundation-before-consumer scope
  ordering.
- `BUG024-P002-TEST-MATRIX-DRIFT`: add registry-shape, independent-scope,
  terminal-refusal, level-1/level-4, CLI refusal, and state-transition G041/G068
  parity coverage to `scopes.md`, `test-plan.json`, and scenario mappings.
- `BUG024-P003-CHANGE-BOUNDARY-DRIFT`: add the confirmed state-transition,
  capability registration, projection, and managed/source-only surfaces while
  preserving every user-protected concurrent file.
