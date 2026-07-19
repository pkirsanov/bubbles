# Bug Fix Design: BUG-026 Traceability Sequential Scope And Tiered DoD

## Design Brief

### Current State

`bubbles/scripts/traceability-guard.sh` discovers physical scope files and
immediately treats every discovered unit as applicable. Its G057/G059,
scenario-to-Test-Plan, physical-path, report-evidence, summary, confidence, and
G068 passes therefore have no shared current-scope projection.

The traceability G068 extractor and `state-transition-guard.sh` Check 4A and
Check 22 each stop a DoD section at the next depth-1-through-depth-4 heading.
That terminates a depth-3 DoD at a valid depth-4 tier before its checkbox rows.

### Target State

Every traceability invocation constructs one immutable ordered
`ApplicableUniverse` of `ScopeRecord` values before any pass runs. Default and
explicit all-scope invocations include every physical unit; explicit valueless
current-scope invocation validates v3 state and omits only exact
`not_started` transitive descendants of the state-derived current scope.

One sourceable, Bash-3.2-safe DoD section helper owns heading, fence, comment,
boundary, checkbox, and diagnostic semantics. Traceability and transition
Check 4A/22 consume that helper; the transition guard remains all-scope.

### Patterns To Follow

- Preserve the exact feature-first invocation shape already owned by
   `bubbles/scripts/traceability-guard.sh`.
- Follow the heading-aware lexical state-machine pattern already used by
   `extract_test_rows()` in `bubbles/scripts/traceability-guard.sh`.
- Follow the sourceable, idempotent helper pattern in
   `bubbles/scripts/guard-lib.sh` and `bubbles/scripts/scan-lib.sh`.
- Keep G068 trace-ID preference, significant-word normalization, stop words,
   percentage threshold, absolute floor, and confidence classification at
   their current values in both owning guards.
- Keep BUG-018 and
   `tests/regression/test_25_traceability_test_plan_heading_depth.sh` as
   protected compatibility baselines.

### Patterns To Avoid

- Physical discovery as a substitute for applicability.
- Scope-number or directory-order filtering as a substitute for graph reachability.
- Grep-based JSON extraction for a fail-closed state contract.
- Caller, environment, or fallback selection of current scope or status.
- Three locally copied DoD boundary parsers that can drift independently.
- A current-scope option on `state-transition-guard.sh`.

### Resolved Decisions

- `execution.scopeProgress`, when present and valid, is the effective
   operational registry; `certification.scopeProgress` remains mandatory and
   canonical. Both registries must agree wherever both carry a fact.
- Current-scope state and graph resolution is implemented by one managed
   Python-standard-library resolver; no package dependency is added.
- DoD section semantics are implemented once in a managed sourceable shell
   helper whose parser body is portable `awk`.
- State-transition Check 4A and Check 22 parse each split scope unit once and
   reuse the same helper output.
- Contract/usage refusal exits 2 before any traceability pass output; completed
   analysis with findings exits 1; clean analysis exits 0.
- Research Lab Feature 007 is downstream replay evidence only and is never a
   production constant, branch, fixture path, or state special case.

### Brief Open Items

None. Planning may refine test row grouping, but it must not weaken this
contract.

## Reconstruction Provenance

This design is a substantive reconciliation under canonical BUG-026. A
transient invalid BUG-024 identity collided with the already assigned
canonical BUG-024 and BUG-025 packets. The transient packet bytes were not
available and this design does not claim they were recovered. The active
contract is grounded in the current BUG-026 requirements and current
production source at `fc6a78b6659ff185c70c48630b6cc819e25601bc`.

The protected producer hashes observed at design start are:

| Surface | SHA-256 |
| --- | --- |
| `bubbles/scripts/traceability-guard.sh` | `dfc4e00a73d8018884a2ae2df1401cc24acca53014b587778c250cc6e9dcd3d9` |
| `bubbles/scripts/state-transition-guard.sh` | `a920046b45d388b7ad5750f44358f23e600d49ab037eee78bc8dfed4cb1ff538` |
| `bubbles/scripts/traceability-guard-selftest.sh` | `691b022fe8a7c4018844c7c74484d108fc3472ce6f0ea917b72e68882306d12f` |
| `bubbles/scripts/state-transition-guard-selftest.sh` | `0b0a8b4c89ba7bf239dc2fa8a15732e1fd20f7e1f11460897abd52056c9fadc3` |
| `tests/regression/test_25_traceability_test_plan_heading_depth.sh` | `71369bf8edae31a488a7d28bdd27c1844583bc0824ac670c8ee209ed18116715` |

These are design baselines, not delivery evidence. This phase does not modify
any producer.

## Purpose And Scope

The change adds a current-scope analysis context to traceability without
weakening all-scope promotion checks. It also makes tiered DoD extraction one
shared lexical contract across traceability G068 and transition G041/G068.

The design changes no Gherkin extraction rule, Test Plan row matcher, physical
test path rule, report evidence rule, G068 matching threshold, transition
profile, certification authority, or final-promotion requirement except where
those consumers must read the same applicable projection or corrected DoD
rows.

The design does not authorize product-specific logic, caller-selected scope
identity, state repair, status repair, hidden fallback, a transition-guard
current-scope mode, or edits to BUG-018/test_25.

## Architecture Overview

```text
traceability CLI
   -> closed argument parser
   -> physical scope discovery and deterministic unit splitting
   -> ScopeRecord construction
          all-scopes: filesystem-backed records
          current-scope: strict v3 state + graph + filesystem reconciliation
   -> immutable ApplicableUniverse
   -> applicable scenario-manifest projection (G057/G059)
   -> scenario/Test Plan/path/report passes
   -> shared DoD parse records
   -> G068 fidelity and confidence summaries
   -> exit 0 or 1

state-transition guard (always all-scope)
   -> existing physical discovery and deterministic unit splitting
   -> shared DoD parse records cached once per split scope unit
          -> Check 4A G041 list-format policy
          -> Check 22 G068 checkbox-row fidelity
   -> all unrelated transition checks unchanged
```

The contract-resolution boundary precedes the traceability banner and every
pass. A current-scope contract error cannot produce a partial scenario count,
partial manifest result, or partial confidence summary.

## Capability Foundation

### Foundation Contract

| Contract | Responsibility | Consumers |
| --- | --- | --- |
| `ScopeRecord` | Immutable canonical identity, aliases, status, dependencies, layout, scope file, report file, and graph classification for one physical analysis unit. | Applicability resolver and all traceability passes. |
| `ApplicableUniverse` | Ordered immutable projection of `ScopeRecord` values for one invocation context. | G057/G059, scenario/Test Plan mapping, path/report checks, counters, confidence, G068. |
| v3 state resolver | Structured state parsing, registry precedence/agreement, graph validation, context refusal, completion validation, and filesystem bijection. | `--current-scope` only. |
| DoD section protocol | One lexical parse result containing selected sections, checkbox rows, all column-zero list rows, line numbers, and one terminal diagnostic status. | Traceability G068 and transition Check 4A/22. |

### ScopeRecord

Each record has these normalized fields:

| Field | Contract |
| --- | --- |
| `canonicalId` | Exact non-empty identity chosen from `scopeId`, string `scope`, or normalized positive numeric `scope`; unique across the full registry. |
| `scopeNumber` | Positive integer when the state or numbered single-file unit supplies one; otherwise null. |
| `name` | Optional non-empty display name; never an identity alias by itself. |
| `status` | Exactly `not_started`, `in_progress`, `blocked`, or `done`. |
| `dependsOn` | Ordered, duplicate-free canonical-ID list after every dependency alias resolves exactly once. |
| `scopeDir` | Normalized feature-relative directory for per-directory layout, otherwise null. |
| `scopeFile` | Canonical contained readable scope artifact or generated single-file section unit. |
| `reportFile` | Canonical contained report artifact: adjacent report for per-directory layout, top-level report for single-file layout. |
| `aliases` | Closed derived set described below; no state-provided free-form alias list is accepted. |
| `physicalOrder` | Stable discovery/source-order key used before projection. |
| `isCurrent` | True for exactly one record in current-scope context, false otherwise. |
| `isDescendant` | True only when graph traversal reaches the record from current through dependency reverse edges. |

Records are constructed once. Passes receive the ordered applicable records
and may not append, remove, rediscover, or reorder them.

### ApplicableUniverse

The foundation supports exactly two contexts:

1. `all-scopes`: the default one-argument invocation and explicit
    `--all-scopes`. State is not consulted for applicability. Every physical
    analysis unit is included.
2. `current-scope`: explicit valueless `--current-scope`. The full v3 registry,
    dependency graph, completion set, context, and full physical mapping are
    validated before projection.

For current-scope context, a record is omitted if and only if:

```text
record.isDescendant == true AND record.status == "not_started"
```

The current record, every transitive prerequisite, every independent scope
including independent `not_started` scopes, and descendants with
`in_progress`, `blocked`, or `done` status remain applicable. The predicate
does not inspect scope numbers, names, directory order, or report contents.

### Extension Points

- Invocation context may select only the two contracts above.
- Layout mapping may produce per-directory files or proven numbered
   single-file units.
- Registry input may include the canonical certification registry alone or a
   validated operational execution registry that agrees with it.
- DoD consumers may request checkbox rows or all list-row classifications;
   they cannot redefine lexical section boundaries.

### Foundation-Owned Behavior

- Deterministic ordering and one-time projection.
- Fail-closed structured state and graph validation.
- Safe contained one-to-one path mapping.
- Exact descendant omission.
- Depth-aware DoD lexical semantics and diagnostic distinctions.
- No default, fallback, environment override, bypass, or partial-pass behavior.

## Concrete Implementations

### Traceability Scope Resolver

A new managed `bubbles/scripts/scope-universe-resolver.py` uses only the Python
standard library. It receives the already resolved feature directory and the
literal context `current-scope`; it receives no caller scope identity, status,
state path, registry path, or environment-derived policy.

The resolver validates the complete current-scope contract and emits a closed
tab-delimited record protocol. Tabs, newlines, control characters, and unsafe
path forms are rejected before emission, so shell parsing cannot reinterpret a
field. The guard consumes the protocol into Bash-3.2 indexed arrays and freezes
those arrays before the first pass. Missing `python3`, resolver invocation
failure, or malformed resolver output is a contract refusal, not an all-scope
fallback.

All-scope construction remains local to `traceability-guard.sh` so the current
one-argument behavior has no new state or Python dependency. It creates the
same `ScopeRecord` shape from physical discovery and the existing single-file
splitter, then freezes the complete ordered list.

### Shared DoD Section Helper

A new managed `bubbles/scripts/dod-section-lib.sh` is idempotently sourceable by
both guards. Its public function invokes one portable `awk` state machine and
emits records with this conceptual shape:

```text
SECTION<TAB>start-line<TAB>depth<TAB>visible-title
CHECKBOX<TAB>line<TAB>checked-or-unchecked<TAB>item-text
LIST<TAB>line<TAB>checkbox-or-non-checkbox<TAB>visible-line
STATUS<TAB>rows|rowless|missing|ambiguous|read_error|parse_error<TAB>detail
```

The exact protocol is internal, versioned in the helper comments, and covered
by helper/selftest assertions. Consumers must require exactly one terminal
`STATUS` record and reject malformed output.

`state-transition-guard.sh` parses every `scope_analysis_files` unit once
before Check 4A, retains the helper output in cleanup-tracked temporary files,
and reuses those exact bytes in Check 22. This is safer than parity-checked
local parsers under Bash 3.2 because section selection and lexical state exist
in one implementation. Check 4A still owns the policy that a column-zero DoD
list item must use checkbox grammar; Check 22 still owns scenario-to-DoD
fidelity and its existing word matcher.

`traceability-guard.sh` uses the same helper output for G068. Its existing
trace-ID-first matcher and confidence accounting remain local and unchanged.

### Traceability Pass Integration

The guard replaces pass-local physical discovery with iteration over
`ApplicableUniverse`:

- G057/G059 compute applicable scope scenario contracts and applicable
   manifest entries from the same records.
- Scenario-to-Test-Plan matching reads each record's `scopeFile`.
- Physical test paths resolve against the existing repository root and the
   record's physical scope directory.
- Report evidence reads the record's `reportFile`.
- Per-scope summaries, global totals, and edge-confidence counts include only
   applicable records.
- G068 reads scenarios and shared-helper checkbox rows from those same records.

No pass may iterate the original `scope_files` collection after the universe
is frozen.

### State-Transition Integration

`state-transition-guard.sh` receives no new CLI option and performs no
current-scope state resolution. Its all-scope discovery, completion checks,
G040 behavior, G073 behavior, transition contract resolution, and final
certification semantics remain unchanged.

Only these selected-depth responsibilities change:

- Check 4A iterates split `scope_analysis_files` units and consumes shared
   `LIST` records across every valid selected DoD section.
- Check 22 consumes shared `CHECKBOX` records from the same cached parse.
- Missing, rowless, ambiguous, read-error, and parse-error results are named
   explicitly. A scenario-bearing unit cannot silently skip G068 because the
   helper returned no rows.

Unrelated bytes, especially the current G040 and G073 implementations, remain
outside the implementation edit region and retain their current selftests.

### Variation Axes

| Axis | Options | Foundation ownership |
| --- | --- | --- |
| Invocation context | implicit all-scopes, explicit all-scopes, explicit current-scope | Yes |
| Layout | per-scope-directory, proven numbered single-file | Yes |
| Registry source | certification only, agreeing execution overlay plus certification | Yes |
| Scope relationship | current, prerequisite, independent, descendant | Yes |
| Scope status | not_started, in_progress, blocked, done | Yes |
| DoD start depth | 1, 2, 3, 4 accepted; 5 and 6 inert as starts | Yes |
| DoD consumer | G041 list-format policy, traceability G068, transition G068 | Boundaries yes; gate policy no |
| Delivery surface | canonical source, install-managed copy, source-only regression | Registration/release owners |

## Closed CLI Contract

The accepted command forms are exactly:

```text
bash bubbles/scripts/traceability-guard.sh FEATURE_DIR
bash bubbles/scripts/traceability-guard.sh FEATURE_DIR --all-scopes
bash bubbles/scripts/traceability-guard.sh FEATURE_DIR --current-scope
```

`FEATURE_DIR` remains the first argument. The optional context token remains
second. Context tokens are valueless and mutually exclusive. Option-before-
feature, missing feature, more than two arguments, duplicate options, valued
forms such as `--current-scope=01`, unknown options, `--` payloads, and any
scope/status/state-path/bypass/force/ignore/insecure/allow-once form exit 2.

No environment variable is read for context, identity, status, state path, or
error relaxation. Setting similarly named environment variables has no effect.

`state-transition-guard.sh` keeps its existing CLI byte-for-byte outside the
separately owned BUG-026 DoD-helper integration. In particular it gains no
`--current-scope` token.

## Closed V3 State Contract

### Structured Parsing And Version

Current-scope mode requires readable, structurally valid JSON in exactly
`FEATURE_DIR/state.json`. Top-level `version` must be JSON number `3`.
Missing `python3`, missing/unreadable state, malformed JSON, duplicate JSON
keys, wrong types, unsupported version, or trailing non-JSON content refuses
with exit 2.

The parser uses duplicate-key detection; it does not silently retain the last
duplicate member.

### Registry Precedence

`certification.scopeProgress` is mandatory, non-empty, and is the canonical
v3 registry.

`execution.scopeProgress` is optional. Precedence is exact:

1. If the key is absent, the effective registry is
   `certification.scopeProgress`.
2. If the key is present, it must be a valid non-empty complete registry. It
   becomes the effective operational registry.
3. A present null, scalar, object, empty array, or invalid execution registry
   refuses. It never falls back to certification.
4. When both registries are present, they must contain the same canonical
   scope set. Every overlapping `scope`, `scopeId`, `name`, `status`,
   `dependsOn`, `scopeDir`, `scopeFile`, `evidenceFile`, and completion field
   must agree after normalization. A missing field may be supplied from the
   canonical entry only when that field is optional; conflicting values refuse.

Legacy top-level `scopeProgress` is not a supported current-scope registry.

### Registry Entry Validation

Each entry must be an object and must provide:

- a unique identity through positive integer/string `scope` or non-empty
  string `scopeId`;
- exact canonical status;
- a duplicate-free JSON array `dependsOn` (empty is valid);
- per-directory path fields required by the mapping contract;
- correct JSON types for every present optional field.

Empty strings, booleans masquerading as integers, duplicate canonical IDs,
duplicate numbers, duplicate paths, duplicate aliases, and unknown fields that
attempt to supply identity/status/path overrides refuse. Optional display and
certification fields remain data, not alternate identity sources.

### Closed Current Identity Aliases

`execution.currentScope` is mandatory and may resolve through only these
derived aliases:

- the exact positive integer `scope` value;
- its exact decimal string and zero-padded numeric form when unambiguous;
- the exact string `scope` value;
- the exact `scopeId` value;
- the exact normalized `scopeDir` value;
- the basename of `scopeDir`;
- the exact normalized `scopeDir/scope.md` value.

Display `name`, environment values, CLI values, partial strings, case-folded
strings, glob patterns, path suffix guesses, and free-form state alias arrays
are not aliases. The supplied value must match exactly one record. Zero or
multiple matches refuse.

### Packet, Phase, And Current Status

Top-level `status` and `certification.status` must both be canonical and must
agree. Current-scope context accepts only packet status `in_progress` or
`blocked`. `not_started`, `specs_hardened`, `docs_updated`, `validated`,
`done`, legacy terminal values, or a non-null top-level `certifiedAt` refuse.

`execution.currentPhase` must be one exact nonterminal token from the current
v3/workflow vocabulary: `context`, `discover`, `select`, `analyze`, `bootstrap`,
`interrogate`, `plan`, `planning`, `documentation`, `implement`, `test`,
`regression`, `simplify`, `gaps`, `harden`, `stabilize`, `devops`, `security`,
`docs`, `chaos`, `redteam`, `releases`, `journey`, `retro`, `spec-review`,
`code-review`, `system-review`, or `bug`. `validate`, `audit`, and `finalize`
always refuse. Unknown, null, or empty phases also refuse. This prevents a
final consumer from narrowing an all-scope gate.

The resolved current `ScopeRecord.status` must be `in_progress` or `blocked`.
A current record marked `not_started` or `done` refuses rather than selecting a
replacement.

### Dependency Graph

Every dependency alias must resolve exactly once. Dependencies are normalized
to canonical IDs. Duplicate edges, unknown edges, self-edges, and cycles
refuse. Traversal uses the validated graph, never numbering.

Status consistency rules are:

- every `done` record has only `done` prerequisites;
- every `in_progress` record has only `done` prerequisites;
- the current `blocked` record also has only `done` prerequisites;
- `not_started` and non-current `blocked` records may have incomplete
  prerequisites and remain visible or omittable according to the exact
  projection predicate.

Every transitive prerequisite of current must therefore be `done`.

### Completion Consistency

Every `certification.completedScopes` member resolves through the same closed
alias set. The normalized completion set must equal exactly the set of records
whose validated status is `done`. Duplicate, unknown, omitted-done, or
included-non-done members refuse.

Any per-record `certifiedAt`/completion marker must be present only for a done
record and must agree across registries. A done record without a required
canonical completion fact, or a non-done record carrying one, refuses.

### Filesystem And Path Safety

All state paths are relative POSIX paths beneath the feature directory.
Absolute paths, empty components, `.`/`..`, backslashes, control characters,
tabs/newlines, home expansion, glob metacharacters, or normalization changes
refuse. Canonical real paths must remain contained after symlink resolution.

No two records may resolve to the same canonical directory, scope file,
report file, inode, or single-file section. Every registry record and every
physical unit participates in a full one-to-one mapping before descendant
omission is computed. An omitted descendant cannot hide an extra, missing,
duplicate, unreadable, or escaping scope mapping.

For per-scope-directory layout:

- `scopeDir` resolves to one `scopes/NN-name` directory;
- `scopeFile` is absent or exactly `scopeDir/scope.md`;
- `evidenceFile` is absent or exactly `scopeDir/report.md`;
- both declared artifacts are regular, contained, and readable;
- physical `scopes/*/scope.md` files and registry entries form a bijection.

For single-file layout:

- the physical source remains `scopes.md` with top-level `report.md`;
- units start only at existing numbered `## Scope N:` headings;
- section numbers are unique and source ordered;
- every state record resolves by exact numeric identity to one section and
  every section resolves to one record;
- missing, duplicate, unnumbered, or non-bijective sections refuse
  current-scope context.

All-scope single-file behavior continues to analyze every discovered numbered
unit in source order and does not require state mapping.

## Deterministic Ordering

Per-directory all-scope discovery preserves the current C-locale lexical order
of physical `scopes/*/scope.md` paths. Single-file units preserve source order.
Current-scope projection removes qualifying records without reordering the
remaining records.

Manifest checks, scope summaries, findings, report checks, confidence counts,
and G068 all iterate this order. Graph traversal order cannot change output
order.

## Scenario Manifest Projection

G057/G059 operate on applicable scenarios, not on the unfiltered manifest.
For each applicable `ScopeRecord`, scenario IDs are extracted with the existing
trace-ID rules and bound to manifest entries by exact `scenarioId` plus a
`scope` value resolving to that record's closed alias set.

An applicable scenario must have exactly one applicable manifest entry. A
missing or duplicate applicable entry is a finding even if an omitted
descendant has an entry with similar text. Linked-test existence and
`evidenceRefs` checks run only for applicable entries in current-scope mode.

Manifest entries that resolve uniquely to omitted descendants are inert: they
do not increase applicable counts, produce missing-file findings, or satisfy
an applicable scenario. Unknown, ambiguous, or cross-scope manifest identity
remains a real finding. All-scope mode projects every physical scope, so every
manifest entry remains exposed as before.

## DoD Section Contract

### Lexical Rules

The shared parser processes each split scope unit linearly:

1. Verify the input is a readable regular file.
2. Track backtick and tilde fences independently. An opener is a run of at
   least three identical markers after leading whitespace. A closer uses the
   same marker, a run at least as long as the opener, and only trailing
   whitespace. Fence payload is inert.
3. Remove single-line and multiline HTML comment spans before heading and list
   recognition. Comment payload is inert.
4. Outside inert regions, recognize ATX headings only at depths 1 through 6
   when the marker run is followed by whitespace or end of line.
5. Apply the existing case-insensitive Definition-of-Done/DoD title predicate.
   Only matching headings at depths 1 through 4 start a section. Matching
   headings at depths 5 and 6 are ordinary nested content and do not start one.
6. Record the start depth. Deeper real headings through depth 6 remain inside
   the section. The next real heading at the same or shallower depth ends it.
7. If that boundary is another accepted sibling DoD start, close the prior
   section and open the sibling. Process sibling sections in source order.
8. A deeper accepted DoD start while a section is open is ambiguous rather
   than silently treated as a tier or second overlapping section.
9. Extract checkboxes only with the existing exact column-zero prefixes
   `- [ ]` or `- [x]`, each followed by one space. Preserve lowercase `x`
   behavior.
10. Classify every column-zero list row beginning with `-` followed by one
    space so G041 can distinguish a valid checkbox from a non-checkbox list
    item.

Unclosed fences/comments, impossible lexical state, malformed helper output,
or internal `awk` failure return parser failure. They never become an empty
row set.

### Diagnostic States

Each unit returns exactly one status:

| Status | Meaning | Traceability treatment | Transition treatment |
| --- | --- | --- | --- |
| `rows` | At least one accepted section and checkbox row. | Continue G068. | Check 4A and Check 22 consume cached rows. |
| `rowless` | Accepted section(s), zero checkbox rows. | Named exit-1 finding when scenarios require DoD fidelity. | Named blocking finding; no silent Check 22 skip. |
| `missing` | No accepted DoD heading. | Named exit-1 finding when scenarios exist. | Named blocking finding where DoD/G068 is required. |
| `ambiguous` | Overlapping/deeper accepted DoD structure. | Named exit-1 finding. | Named blocking finding. |
| `read_error` | Input cannot be read as a regular file. | Named exit-1 finding in all-scope analysis; current-scope mapping catches it earlier as exit 2. | Named blocking finding. |
| `parse_error` | Lexical/helper/protocol failure. | Named exit-1 finding. | Named blocking finding. |

Multiple sibling DoD sections are not ambiguous. Their rows are concatenated
in source order and remain distinct by source line.

### G068 Fidelity Invariance

BUG-026 changes only which units and checkbox rows reach G068. It does not
change:

- trace-ID extraction or trace-ID-first preference in traceability;
- normalization and minimum significant-word length;
- the true-stop-word set;
- all-words requirement for fewer than three significant words;
- `ceil(50%)` overlap plus absolute overlap floor 3 for larger scenarios;
- scenario-to-row matching, which intentionally has a different threshold;
- declared/inferred/ambiguous confidence classification.

The two guards retain their current matcher ownership. Focused parity tests
pin their existing word sets and thresholds while the shared helper guarantees
selected-depth row parity.

## Data And Control Flow

1. Parse the CLI without reading state or emitting pass output.
2. Resolve and contain the feature directory using existing repository-root
   behavior.
3. Discover physical scope artifacts and split single-file units.
4. Build all-scope records, or invoke the strict v3 resolver and reconcile the
   full state/filesystem graph.
5. In current-scope mode, compute reverse graph reachability, mark exact
   descendants, and apply the two-condition omission predicate.
6. Freeze `ApplicableUniverse`; assert it is non-empty and current appears
   exactly once when applicable.
7. Project G057/G059 manifest entries from the universe.
8. Run all scenario/Test Plan/path/report passes over record fields only.
9. Parse DoD once per applicable unit and run G068 over shared-helper rows.
10. Emit summaries and return analysis status.

No consumer can request a wider or narrower list after step 6.

## Error And Exit Semantics

### Exit 2: Contract Refusal

The guard emits one concise `ERROR [E026-*]` diagnostic and exits before the
banner or any pass when it encounters:

- `E026-USAGE`: closed CLI violation;
- `E026-PARSER-UNAVAILABLE`: required structured parser unavailable;
- `E026-STATE-READ` / `E026-STATE-SYNTAX` / `E026-STATE-VERSION`;
- `E026-REGISTRY-MISSING` / `E026-REGISTRY-SHAPE` /
  `E026-REGISTRY-CONFLICT`;
- `E026-CURRENT-IDENTITY` / `E026-CONTEXT-FINAL`;
- `E026-GRAPH-UNKNOWN` / `E026-GRAPH-CYCLE` /
  `E026-GRAPH-STATUS`;
- `E026-COMPLETION-CONFLICT`;
- `E026-PATH-UNSAFE` / `E026-MAPPING-NONBIJECTIVE`;
- `E026-RESOLVER-PROTOCOL`.

The diagnostic names the invariant and feature-relative scope identity where
safe. It never dumps raw state, environment values, or absolute downstream
topology. Exit 2 never falls back to all-scope and never reports partial
scenario, manifest, or confidence counts.

### Exit 1: Completed Analysis With Findings

The existing `fail()` accounting remains the analysis path. Missing mappings,
test files, report evidence, applicable manifest entries, and DoD diagnostic
states are findings. The guard reaches the normal summary and exits 1.

### Exit 0: Clean Applicable Analysis

All applicable checks completed with zero failures. Warnings retain current
nonblocking semantics.

## Security And Path Handling

- Current identity and status come only from validated state.
- No state content is evaluated or sourced as shell.
- Resolver output rejects shell metacharacter-bearing protocol fields and is
  parsed as data, never with `eval`.
- Realpath containment and one-to-one mapping prevent traversal, symlink
  escape, alias collision, and duplicate physical-unit attacks.
- State and manifest diagnostics use feature-relative identities.
- No raw state, credential-like environment value, or consumer-specific host
  path is logged.
- There is no bypass token, hidden environment switch, compatibility fallback,
  or status/scope override.

## Portability

- Shell code must run under macOS system Bash 3.2 and current Linux Bash.
- Use indexed arrays only; no associative arrays, namerefs, `mapfile`, or
  `readarray`.
- DoD parsing uses portable POSIX `awk`; no three-argument `match()` capture.
- Ordering uses C-locale semantics and no GNU-only `sort`, `sed`, `date`,
  `readlink`, or `stat` flags.
- Temporary files use portable `mktemp` forms and existing cleanup traps.
- Python uses only the standard library and is invoked explicitly; absence is
  a visible exit-2 refusal.

## Configuration, Migration, And Compatibility

No feature flag, environment setting, port, datastore, schema migration, or
state rewrite is introduced. Existing v3 state remains unchanged on disk.

Default one-argument all-scope behavior and explicit `--all-scopes` are
behaviorally identical. `done-spec-audit.sh`, validation, audit, finalize, and
state transition continue using all-scope behavior. No caller must adopt
current-scope unless it is closing active sequential work from validated state.

BUG-018 packet files and test_25 remain byte-identical. Its level-2/level-3
Test Plan extraction, missing/rowless distinction, boundary behavior,
caller-root resolution, and Bash 3.2 startup remain behavior-compatible.

## Observability And Failure Visibility

This is a CLI guard with no service telemetry or external data plane. Its
observable contract is deterministic stdout/stderr plus exit status.

Current-scope success output must identify context and applicable/omitted
counts without exposing omitted scopes as pass results. Exit-2 refusal carries
one stable error code. Exit-1 output keeps per-finding diagnostics and the
normal summary. All-scope summary labels and counts remain compatible.

No metric, trace, network call, or production monitoring write is added.

## Testing And Validation Strategy

### Scenario Mapping

| Scenario | Primary validation | Required assertions |
| --- | --- | --- |
| SCN-BUG-026-001 | Focused production-path regression | Exact descendant omission and retention of current, prerequisites, independent not_started, and active/blocked/done descendants; every pass sees identical record IDs/order. |
| SCN-BUG-026-002 | Resolver/CLI adversarial matrix | Registry precedence/agreement, malformed types, aliases, graph, completion, paths, mappings, context refusal, exit 2 before pass output, no env/CLI override. |
| SCN-BUG-026-003 | Shared-helper and guard integration matrix | Start depths 1-4, nested depths through 6, boundaries, sibling sections, deeper ambiguity, fences/comments, checkbox grammar, six statuses, Check 4A/22 shared bytes. |
| SCN-BUG-026-004 | Existing plus new regressions | Default equals explicit all-scope; test_25 and BUG-018 tree unchanged; current G068 thresholds and no-scenario behavior unchanged. |
| SCN-BUG-026-005 | Managed/source replay | Canonical and installed guards share helper/resolver bytes; transition remains all-scope; downstream replay has no production special case or consumer write. |

### Causal RED

Before production edits, `bubbles.test` must freeze complete test_33 bytes and
show independent failures for:

1. unstarted transitive descendants leaking into current-scope applicability;
2. nested tier headings terminating DoD extraction.

The RED fixture must use generic disposable feature data shaped like the
contract. Research Lab Feature 007 may be invoked later as consumer evidence,
but its path, identity, scope count, and finding counts must not be embedded in
production behavior.

### Focused Coverage

- Resolver tests cover every state, registry, alias, graph, completion, path,
   mapping, ordering, and context branch.
- DoD helper tests cover every lexical transition and terminal status.
- Traceability integration proves G057/G059, scenario/Test Plan, path, report,
   summary/confidence, and G068 use the same projection.
- State-transition integration proves Check 4A and Check 22 reuse one cached
   parse while G040/G073 and all-scope behavior remain unchanged.
- Mutation-strength tests reintroduce number filtering, registry fallback,
   early tier termination, comment/fence leakage, and silent empty-result
   handling; each mutation must fail the regression.
- System-Bash execution proves Bash 3.2 startup and behavior.

### Compatibility And Hygiene

- Compare BUG-018 packet and test_25 against the pre-implementation Git tree;
   any byte delta fails.
- Re-run existing traceability and transition selftests plus focused test_33.
- Run artifact lint, artifact freshness, G094, regression quality, install
   provenance, framework validation, and release readiness only in their
   planned owner phases.
- Canonical-source replay precedes supported installed replay. Neither replay
   may manually edit a downstream managed framework file.

This design phase runs only design-profile checks. It does not run runtime
tests, framework validation, release validation, or downstream replay.

## Rollout And Rollback

### Rollout

1. `bubbles.plan` reconciles scopes, scenario manifest, test plan, and DoD to
   this contract.
2. `bubbles.test` freezes complete regression bytes and records causal RED.
3. `bubbles.implement` adds the resolver/helper and surgical guard integration.
4. `bubbles.test` completes focused, compatibility, mutation, and portability
   evidence.
5. `bubbles.docs` updates only managed behavior references selected from final
   implementation.
6. `bubbles.releases` regenerates release identity after source, test, and doc
   bytes stabilize.
7. `bubbles.validate` independently certifies the complete nonterminal packet
   and delivery transition.

No flag or staged behavior fork is required. The release train is
`framework-next`.

### Rollback

Rollback restores the resolver/helper and the two guard integrations to their
pre-implementation Git bytes, then reruns the protected all-scope and BUG-018
compatibility checks. It does not rewrite v3 state, suppress findings, change
G068 thresholds, or install hand-edited downstream bytes.

## Source Ownership And Delivery Classification

| Surface | Classification | Owner | Contract |
| --- | --- | --- | --- |
| `design.md` | Packet, design-owned | `bubbles.design` | This authoritative contract. |
| Planning packet twins | Packet, plan-owned | `bubbles.plan` | Scenario/Test Plan/DoD parity after design. |
| `bubbles/scripts/scope-universe-resolver.py` | Install-managed production | `bubbles.implement` | Strict v3 resolver and immutable record protocol. |
| `bubbles/scripts/dod-section-lib.sh` | Install-managed production | `bubbles.implement` | Sole DoD lexical and selected-depth owner. |
| `bubbles/scripts/traceability-guard.sh` | Install-managed production | `bubbles.implement` | CLI, universe freeze, pass integration, local G068 matcher. |
| `bubbles/scripts/state-transition-guard.sh` | Install-managed production | `bubbles.implement` | Shared parse cache plus Check 4A/22 consumption only; all-scope and unrelated bytes preserved. |
| Managed guard selftests | Install-managed tests | `bubbles.test` | Helper/resolver/guard behavior and parity. |
| `tests/regression/test_33_traceability_sequential_scope_and_tiered_dod.sh` | Source-only regression | `bubbles.test` | Persistent production-path RED/GREEN and compatibility coverage. |
| Managed behavior docs/capability registration | Install-managed docs/registry as applicable | `bubbles.docs` | Final behavior only, no delivery overclaim. |
| Install inventory/provenance registration | Install-managed registration | `bubbles.test` with release reconciliation | Resolver/helper and managed selftests install together. |
| `bubbles/release-manifest.json` | Generated release identity | `bubbles.releases` | Stable final source/test/doc checksums. |
| Downstream installed bytes | Generated by supported installer/upgrade | Downstream operator workflow | No manual managed-file edits. |
| `certification.*` and terminal status | Validate-owned | `bubbles.validate` | Independent final authority only. |

`improvements/INDEX.md`, BUG-012 through BUG-025, all Research Lab files,
unrelated framework files, Git history, and concurrent work are protected.

## Alternatives And Tradeoffs

### Local DoD Parsers With Parity Tests

Rejected. Parity tests can detect selected cases but leave three executable
boundary implementations. A sourceable helper matches current framework
library practice and makes Check 4A/22 consume identical selected rows.

### Bash-Only V3 Graph Resolver

Rejected. Bash 3.2 has no associative arrays or reliable structured JSON
parser. Emulating maps with delimited strings would weaken duplicate, alias,
type, graph, and path validation. Python standard library adds no package while
keeping data parsing separate from shell execution.

### Filter Greater Scope Numbers Or Every Not-Started Scope

Rejected. Numbering does not encode reachability, and independent
`not_started` scopes must remain visible. Exact reverse-edge traversal is the
smallest rule that satisfies the requirements.

### Let Invalid Current State Fall Back To All Scope

Rejected. It hides the caller's context error behind a different analysis and
can mix partial pass output with a contract refusal. Exit 2 is explicit and
retryable only after state is corrected.

### Add Current-Scope To State Transition

Rejected. Transition, validate, audit, and finalize are final consumers and
must expose every scope gap.

## Complexity Tracking

| Decision | Simpler alternative considered | Why rejected |
| --- | --- | --- |
| Managed Python state resolver | Inline grep/sed or Bash string parsing | Cannot enforce JSON types, duplicate keys, aliases, graph cycles, completion equality, and realpath bijection safely under Bash 3.2. |
| Shared DoD helper and parse cache | Three small local regex edits | Local edits preserve semantic drift and cannot guarantee Check 4A/22 selected-depth parity. |
| Full registry/filesystem validation before omission | Validate only current plus retained scopes | An omitted descendant could hide malformed graph, unsafe paths, duplicate mappings, or completion contradictions. |
| Exact manifest projection | Keep global manifest count and ignore only scope loops | An omitted descendant entry could satisfy an applicable missing entry or create unrelated missing-file findings. |

## Risks And Mitigations

| Risk | Mitigation |
| --- | --- |
| Strict state validation rejects a previously tolerated malformed packet. | Exit 2 names the exact invariant; all-scope remains available only when explicitly invoked, never as fallback. |
| New managed helpers are omitted from install/release inventory. | Install-provenance assertions and release-manifest reconciliation are explicit owner-gated delivery rows. |
| Shared helper changes G068 matching accidentally. | Helper owns extraction only; existing matcher functions and thresholds remain local and are pinned by compatibility tests. |
| State-transition edit collides with concurrent work. | Implementation starts from fresh hashes, limits edits to sourcing/cache/Check 4A/22, and preserves G040/G073 plus unrelated bytes. |
| Single-file splitting maps the wrong state scope. | Current-scope mode requires an exact numbered-section bijection and refuses otherwise. |
| Consumer evidence becomes a production special case. | Generic fixtures own regression; downstream Feature 007 is replay evidence only. |

## Open Questions

None blocking. The exact grouping of plan-owned test rows belongs to
`bubbles.plan`; the behavioral contract, ownership boundaries, and exit
semantics above are closed.
