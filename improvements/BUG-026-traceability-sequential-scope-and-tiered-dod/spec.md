# Expected Behavior: BUG-026 Traceability Sequential Scope And Tiered DoD

## Problem Contract

Traceability must support both whole-packet promotion and active sequential-
scope work without hiding real findings. It must also parse the framework's
accepted tiered Definition of Done structure consistently across traceability
and state-transition enforcement. Context selection and DoD extraction must
fail closed on malformed or ambiguous inputs.

## Actors

- An implementation agent closing the sole current scope in a sequential DAG.
- A planning, validation, or audit caller requiring all-scope coverage.
- A maintainer authoring single-file or per-scope-directory planning packets.
- A framework validator enforcing G041, G057, G059, and G068.
- A downstream repository consuming canonical or installed framework bytes.

## Domain Capability Model

### Applicable Scope Universe

One immutable ordered projection identifies which physical scope analysis
units apply to one guard invocation. It is derived from the invocation context,
strict v3 state, dependency graph, scope identity aliases, completion records,
safe paths, and filesystem mapping before any traceability pass executes.

### DoD Section Semantics

One depth-aware section contract identifies accepted DoD starts, ignores false
headings, retains nested tiers, extracts the existing checkbox grammar, and
returns distinct missing, rowless, ambiguous, and parser/read outcomes.

### Guard Integrations

- `traceability-guard.sh` consumes the applicable universe for every pass.
- `state-transition-guard.sh` remains all-scope while Check 4A and Check 22
  consume equivalent DoD boundary semantics.
- Source, installed, validation, release, and downstream replay preserve the
  same externally observable contracts.

## Requirements

### BR-026-001 Preserve One-Argument All-Scope Behavior

The existing one-argument invocation must continue to analyze every physical
scope. An explicit valueless `--all-scopes` option must produce the same scope
universe, ordering, diagnostics, and exit semantics.

### BR-026-002 Closed Current-Scope CLI

The guard must accept an explicit valueless `--current-scope` option. It must
not accept a caller-provided scope ID, status, state path, environment override,
or a second context option. Unknown, duplicated, valued, bypass-shaped, force,
ignore, and allow-once arguments must exit with a usage error before analysis.

### BR-026-003 State-Derived Context Only

`--current-scope` must derive the current identity, phase, statuses,
dependencies, filesystem locations, and completion facts only from a readable,
valid v3 `state.json`. Missing or malformed state must fail closed without
falling back to all-scope behavior.

### BR-026-004 V3 Registry Shape Support

The resolver must support the framework's current v3 operational and
certification scope-registry shapes. When both are present, overlapping
identity, status, dependency, path, and completion facts must agree. Missing
required fields, wrong JSON types, duplicate identities or paths, contradictory
registries, and unsupported registry shapes must fail closed.

### BR-026-005 Identity And Alias Resolution

Numeric scope numbers, canonical `scopeId`, `scopeDir`, scope artifact path,
and accepted current-scope aliases must resolve to exactly one registry entry
and exactly one physical analysis unit. Unknown, duplicate, traversal-shaped,
absolute, escaping, or multiply-resolving aliases must fail closed.

### BR-026-006 Dependency Graph Integrity

Every dependency must resolve to a known scope. Self-dependencies, duplicate
dependencies, cycles, impossible status/dependency combinations, and a current
scope whose prerequisites contradict completion records must fail closed.

### BR-026-007 Exact Descendant Omission Rule

Only exact `not_started` transitive descendants of the resolved current scope
may be omitted in `--current-scope` context. Omission must be computed from the
validated dependency graph, not numbering or directory order.

### BR-026-008 Findings That Remain Visible

The current scope, completed prerequisites, independent scopes, and descendants
with active, blocked, or done status must remain applicable. Contradictory
state must be refused rather than hidden. No finding may disappear merely
because its scope number is greater than the current scope number.

### BR-026-009 Final And Terminal Refusal

`--current-scope` must refuse terminal packets and final promotion contexts in
which all-scope coverage is required. Done-spec, validation, audit, and final
promotion paths must use one-argument or explicit `--all-scopes` semantics.

### BR-026-010 Safe Filesystem Mapping

Every applicable registry entry must map to its declared, readable scope file
inside the feature directory. Every physical scope must map according to the
selected layout contract. Missing files, duplicate mappings, extra ambiguous
files, path escapes, report mismatches, and completion cross-check mismatches
must fail closed.

### BR-026-011 Single-File Layout Proof

Current-scope filtering in single-file layout is permitted only when validated
state identities map provably one-to-one to numbered scope units. Otherwise
`--current-scope` must fail closed. All-scope single-file behavior must remain
unchanged.

### BR-026-012 One Immutable Projection

The guard must construct one immutable applicable scope universe before
G057/G059, scenario/Test Plan mapping, physical test path checks, report-
evidence checks, summaries, edge confidence, and G068. Every pass must consume
that same ordered projection; no pass may rediscover all physical scopes.

### BR-026-013 Accepted DoD Starts

Outside fenced code and HTML comments, a recognized Definition of Done or DoD
heading at depth 1, 2, 3, or 4 starts an accepted section. Headings at depths 5
and 6 do not start a DoD section.

### BR-026-014 Tiered DoD Boundaries

For each accepted start, the extractor must track its heading depth, retain
real nested headings through depth 6, and stop only at the next real heading
of the same or shallower depth. Multiple valid sibling DoD sections must be
processed deterministically in source order.

### BR-026-015 False Heading Isolation

Heading-shaped text inside backtick or tilde fenced code, including variable
fence lengths, and inside single-line or multiline HTML comments must not
start, nest, or end a DoD section.

### BR-026-016 DoD Diagnostic States

The extractor must distinguish at least: no accepted DoD heading, accepted
heading with zero checkbox rows, ambiguous accepted structure, unreadable
input, and parser failure. The caller must preserve the specific diagnostic
and must not collapse these states into a silent empty result.

### BR-026-017 Preserve Existing Fidelity Semantics

The checkbox grammar, scenario extraction, trace-ID preference, significant-
word normalization, overlap thresholds, confidence classification, and G068
pass/fail thresholds must remain unchanged except for feeding them the correct
scope universe and DoD rows.

### BR-026-018 State-Transition Parity

`state-transition-guard.sh` remains all-scope. Check 4A G041 must inspect
non-checkbox list items throughout valid tiered DoD sections, and Check 22 G068
must extract the same checkbox rows and diagnostic distinctions as
traceability. Design must choose and verify a single owned semantic contract
without weakening either gate.

### BR-026-019 BUG-018 Compatibility

The bytes of `tests/regression/test_25_traceability_test_plan_heading_depth.sh`
and every BUG-018 packet artifact remain unchanged. Its level-2/level-3 Test
Plan behavior and source-root compatibility must remain green. Historical
BUG-018 evidence remains historical even when BUG-026 removes the separately
owned 28/9 false-blocking classes.

### BR-026-020 Portable And Deterministic

All implementation and regression paths must run on macOS system Bash 3.2 and
Linux without GNU-only assumptions. Ordering and diagnostics must be stable
under the repository's portable sorting and path rules.

### BR-026-021 No Bypass

No skip, force, ignore, insecure, allow-once, status override, scope-ID
override, malformed-state fallback, or silent parser fallback may be added.

### BR-026-022 Delivery Provenance

Focused regression, existing guard selftests, regression registration,
artifact checks, framework validation, managed documentation, install
provenance, release readiness, canonical-source downstream replay, and
installed downstream replay must all agree on final stable bytes before
certification.

## Acceptance Scenarios

```gherkin
Feature: Trace the correct scope universe and tiered DoD contracts

  Scenario: SCN-BUG-026-001 Current scope omits only exact unstarted descendants
    Given valid v3 state with one current scope and a mixed dependency graph
    When traceability runs with the valueless current-scope context
    Then only exact not_started transitive descendants are omitted
    And current, prerequisite, independent, active, blocked, and done scopes remain visible

  Scenario: SCN-BUG-026-002 Invalid current-scope context fails closed
    Given malformed, contradictory, unsafe, cyclic, terminal, or unmappable state
    When current-scope context is requested
    Then traceability refuses before any pass runs
    And no all-scope fallback or caller override is accepted

  Scenario: SCN-BUG-026-003 Tiered DoD rows survive nested headings
    Given accepted DoD starts at depths one through four with nested tiers through depth six
    When the DoD section contract parses headings, comments, fences, boundaries, and checkboxes
    Then every real checkbox row remains available to G041 and G068
    And missing, rowless, ambiguous, read, and parser failures remain distinct

  Scenario: SCN-BUG-026-004 All-scope and BUG-018 behavior remain compatible
    Given a done or final-context packet and the existing BUG-018 regression
    When default and explicit all-scope validation run
    Then every physical scope remains visible in stable order
    And BUG-018 Test Plan heading-depth behavior remains green without byte edits

  Scenario: SCN-BUG-026-005 Source and installed guards share one contract
    Given final source, test, documentation, provenance, and release bytes
    When canonical-source and installed downstream replays execute
    Then both expose the same current-scope and tiered-DoD behavior
    And state-transition Check 4A and Check 22 retain all-scope parity
```

## Outcome Contract

- **Intent:** Let sequential scope work prove its current delivery without
  hiding any finding that is not an exact unstarted transitive descendant, and
  parse accepted tiered DoD structure consistently.
- **Success Signal:** Research Lab Feature 007 Scope 01 can run canonical
  `--current-scope` traceability without the 28 descendant or nine rowless-DoD
  false findings, while all-scope, BUG-018, malformed-state, and gate-parity
  regressions remain green.
- **Hard Constraints:** Fail-closed state, one immutable projection, unchanged
  all-scope default, unchanged G068 thresholds, all-scope state-transition,
  no protected packet edits, no bypass, and macOS/Linux portability.
- **Failure Condition:** Any real current/prerequisite/independent/final
  finding is hidden, malformed state falls back, nested DoD rows disappear, or
  all-scope/BUG-018/state-transition behavior regresses.

## Release Train

Target train: `framework-next`. No feature flag is introduced.

## Non-Goals

- Changing Feature 007 planning, product code, tests, evidence, or state.
- Rewriting BUG-018 evidence or regression bytes.
- Changing G068 word matching, confidence, or threshold formulas.
- Adding caller-controlled scope identity or status.
- Changing state-transition guard from all-scope context.

## References

- [bug.md](bug.md)
- [design.md](design.md)
- [scopes.md](scopes.md)
- [report.md](report.md)
- [uservalidation.md](uservalidation.md)
