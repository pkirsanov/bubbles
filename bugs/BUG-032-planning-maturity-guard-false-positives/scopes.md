# Scopes: BUG-032 Planning-Maturity Guard False Positives

## Scope Sequence

| Order | Scope | Depends on | Owner | Outcome |
| --- | --- | --- | --- | --- |
| 1 | Semantic consumer and SLA classifiers | None | `bubbles.implement` with tests-first red capture | Check 8B and Check 5A distinguish negative posture from positive contract declarations. |
| 2 | Receipt clone execution identity | Scope 1 | `bubbles.implement` | Check 43 accepts independent deterministic siblings and still blocks incompatible-command reuse. |
| 3 | G101 delivery-capable mode semantics | Scope 2 | `bubbles.implement` | Planning/docs/validate-only terminal states are not delivered; delivery aliases retain correct behavior. |
| 4 | Contract reconciliation and full validation | Scopes 1-3 | `bubbles.docs`, `bubbles.validate`, `bubbles.audit` through the delivery workflow | Docs, registry text, generated surfaces, focused selftests, full validation, and release checks agree. |

The delivery run must execute scopes in this order. Each implementation scope
starts by adding the persistent regression assertions and capturing their
expected pre-fix failure before changing production code.

---

## Scope 1: Semantic Consumer And SLA Classifiers

**Status:** Done
**Scope-Kind:** contract-only
**Depends on:** None

### Goal

Make Check 8B and Check 5A recognize affirmative contract changes without
penalizing stale-generation, provider/lifecycle replacement, or explicit
observability opt-out prose.

### Gherkin Scenarios

```gherkin
Feature: Planning prose semantic classification

  Scenario: SCN-032-001 - A stale generated path is replaced without changing a consumer interface
    Given a scope says a stale generation path is replaced by current generated output
    And the scope does not rename, remove, move, or deprecate a consumer route, path, endpoint, contract, or identifier
    And an unrelated clause says "Remove stale cache entries after replacement; the public API contract is unchanged."
    When Check 8B classifies the scope
    Then the scope is not required to add a Consumer Impact Sweep

  Scenario Outline: SCN-032-002 - Replacement semantics remain outside consumer mutation classification
    Given a scope describes <replacement>
    And no consumer-visible interface identity changes
    When Check 8B classifies the scope
    Then the scope is not required to add a Consumer Impact Sweep

    Examples:
      | replacement |
      | a provider implementation being replaced |
      | a lifecycle state being replaced by its successor |
      | a generated artifact replacing a stale artifact path |

  Scenario Outline: SCN-032-003 - A real consumer interface mutation requires impact planning
    Given a scope explicitly <mutation> a consumer-visible <surface>
    When Check 8B classifies the scope
    Then the scope requires a Consumer Impact Sweep
    And the scope requires the consumer-impact DoD item
    And the scope must enumerate affected consumer surfaces

    Examples:
      | mutation | surface |
      | renames | route |
      | removes | path |
      | renames | endpoint |
      | removes | contract |
      | renames | identifier |

  Scenario: SCN-032-004 - An opted-out observability sentence is not an SLA promise
    Given a scope says observability is opted out and no trace or SLO evidence is injected
    And the scope declares no latency, throughput, response-time, p95, p99, SLA, or SLO target
    And the scope says "No SLA is declared for this contract."
    And the scope says "SLA and SLO are not applicable to this documentation-only change."
    And the scope says "No SLO target is declared."
    And the scope says "The p95 latency target is not applicable."
    When Check 5A classifies the scope
    Then the scope is not required to add stress coverage

  Scenario Outline: SCN-032-005 - An affirmative performance contract requires stress coverage
    Given a scope declares <promise>
    When Check 5A classifies the scope
    Then the scope requires explicit stress coverage

    Examples:
      | promise |
      | an SLO of 99.9 percent availability |
      | a p95 latency budget of 200 ms |
      | a throughput target of 1000 requests per second |
      | a p99 response-time threshold of 500 ms |
      | The p95 latency budget is no more than 200 ms. |
```

### Implementation Plan

1. Add negative and positive fixtures to the existing state-transition guard
   selftest. Run the selftest before production changes and capture the expected
   failures for the new assertions.
2. Replace Check 8B's broad replacement/migration co-occurrence rule with the
   explicit mutation classifier defined in `design.md`.
3. Add polarity handling to Check 5A. Ensure quantitative target language
   overrides broad negation.
4. Run the focused selftest and inspect diagnostics for all positive and negative
   fixtures.
5. Keep shell forms compatible with Bash 3.2, BSD grep, and GNU grep.

### Test Plan

| Scenario | Test Type | Persistent test file | Persistent test identifier | Exact command | Evidence and required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-001, SCN-032-002, SCN-032-004 | Regression E2E - pre-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics`; `BUG032-IV-F3 Check 5A accepts explicit no-SLA/no-SLO, negated-target, and not-applicable target prose without stress coverage` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Non-zero after the new fixtures are added but before production predicates change; output identifies D1 and D2 assertions. [Scope 1 RED Evidence](report.md#scope-1-red-evidence) |
| SCN-032-001 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics`; `BUG032-IV-F2 Check 8B does not bridge cache cleanup to an unchanged public API contract in another clause` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for stale generation and unrelated-clause replacement semantics. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-002 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics`; `BUG032-IV-F2 Check 8B does not bridge cache cleanup to an unchanged public API contract in another clause` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for provider, lifecycle, and generated-artifact replacement semantics. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-003 | Adversarial E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG032-IV-F1 Check 8B triggers on the exact mutation inflections 'renames' and 'removes'`; `BUG-032 Check 8B still flags all 5 explicit route/path/endpoint/contract/identifier mutations` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 while every explicit `renames`/`removes` twin still requires impact planning. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-004 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG032-IV-F3 Check 5A accepts explicit no-SLA/no-SLO, negated-target, and not-applicable target prose without stress coverage`; `BUG032-IV-F3 Check 5A does not turn explicit negated or not-applicable target posture into an affirmative contract` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for explicit no-SLO, negated-target, and not-applicable target prose. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-005 | Adversarial E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 5A still treats 'no more than 200 ms p95 latency' as an affirmative performance contract`; `Check 5A still flags all 5 genuine SLA declarations (p95 latency, throughput, SLA, SLO, p99 response time)` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 while genuine quantitative targets still require stress coverage. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005 | Static shell syntax | `bubbles/scripts/guards/planning-checks.sh`; `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/state-transition-guard-selftest.sh` | Shell syntax for the changed planning classifiers and persistent selftest | `bash -n bubbles/scripts/guards/planning-checks.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005 | Framework portability | `bubbles/scripts/state-transition-guard-selftest.sh` through the framework selftest suite | The five SCN-specific identifiers above | `bash bubbles/scripts/cli.sh framework-validate` | Exit 0; macOS compatibility cases remain green. |

### Consumer Impact Sweep

This scope changes classifier behavior, not a public route/path/endpoint. The
consumer surfaces are downstream scope authors, `state-transition-guard.sh`, and
its persistent selftest. No framework command, route, identifier, prompt, or
file location is renamed or removed.

### Change Boundary

**Allowed file families:** Check 8B and Check 5A production code, their existing
persistent selftest, source comments, and directly governing docs/gate metadata.

**Excluded surfaces:** receipt identity, G101 delivery semantics, downstream
planning artifacts, unrelated natural-language classifiers, and generated
copies before canonical regeneration.

### Definition of Done

- [x] SCN-032-001, SCN-032-002, and SCN-032-004 pre-fix regression assertions for stale generation/path replacement,
  provider replacement, lifecycle replacement, and explicit no-SLO wording fail
  against the current production predicates. → Evidence: [Scope 1 RED Evidence](report.md#scope-1-red-evidence)
- [x] SCN-032-003 positive route/path/endpoint/contract/identifier `renames`/`removes` fixtures
  still require Consumer Impact Sweep. → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] SCN-032-005 positive SLO and latency/throughput/p95/p99 fixtures still require stress
  coverage. → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] SCN-032-005 keeps the `no more than 200 ms p95 latency` adversarial polarity fixture
  positive. → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, and SCN-032-005 post-fix state-transition guard selftest assertions pass. → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, and SCN-032-005 have scenario-specific E2E regression tests for every changed behavior. → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] Broader E2E regression suite passes → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] Consumer impact sweep confirms zero stale first-party references remain → Evidence: [Scope 1 Boundary Evidence](report.md#scope-1-boundary-evidence)
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Scope 1 Boundary Evidence](report.md#scope-1-boundary-evidence)

---

## Scope 2: Receipt Clone Execution Identity

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** Scope 1

### Scope 2 Goal

Distinguish independent deterministic validator executions from substantive
receipt reuse across incompatible commands, while preserving the existing
empty-stdout contract.

<!-- markdownlint-disable-next-line MD024 -->
### Gherkin Scenarios

```gherkin
Feature: Receipt clone identity

  Scenario: SCN-032-006 - One validator runs independently over two spec targets
    Given two successful artifact-lint executions have the same executable family and lint category
    And each execution targets a different spec directory
    And each receipt has independent time or session provenance and a distinct target or input closure
    And both executions emit the same non-empty stdout hash
    When Check 43 evaluates the receipts
    Then it does not report a receipt clone

  Scenario: SCN-032-007 - One substantive output hash appears under unrelated command identities
    Given a cargo test receipt and an npm lint receipt share one non-empty stdout hash
    And their command families or evidence categories are incompatible
    When Check 43 evaluates receipt identity
    Then it reports a receipt clone
    And the finding names the incompatible command families or categories

  Scenario: SCN-032-008 - Different commands emit no stdout
    Given multiple receipts carry the SHA-256 digest of empty stdout
    When Check 43 evaluates receipt identity
    Then it does not report a receipt clone
    And the exemption does not depend on the optional stdoutBytes field
```

### Scope 2 Implementation Plan

1. Extend the existing Check 43 selftest block with deterministic sibling
   receipts. Give the rows different spec targets, input closures or normalized
   targets, timestamps/session provenance, and durations while keeping stdout
   identical.
2. Verify the new negative fixture fails under the current Check 43 logic.
3. Retain existing BUG-007 empty-stdout cases and BUG-019 equivalent-spelling
   behavior.
4. Derive command family, evidence category, target identity, exit status, and
   execution provenance from current receipt fields.
5. Block incompatible family/category collisions. Do not exempt ambiguous rows
   that cannot prove independent execution.
6. Improve the finding text to show derived identity fields.
7. Run the full state-transition guard selftest.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| Scenario | Test Type | Persistent test file | Persistent test identifier | Exact command | Evidence and required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-006 | Regression E2E - pre-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 accepts independent deterministic validator siblings over distinct targets` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Non-zero because the deterministic-validator sibling fixture is falsely classified as a clone. [Scope 2 RED Evidence](report.md#scope-2-red-evidence) |
| SCN-032-006 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 accepts independent deterministic validator siblings over distinct targets`; `BUG-032 Check 43 preserves BUG-019 equivalent command-spelling normalization` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for independent validator siblings and equivalent command spelling. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-007 | Adversarial E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG032-IV-F4 Check 43 blocks substantive stdout reuse across incompatible categories with one normalized command identity`; `BUG032-IV-F4 Check 43 reports the same-identity incompatible-category receipt clone`; `BUG-032 Check 43 blocks substantive stdout reuse across incompatible commands`; `BUG-032 Check 43 reports the incompatible-command receipt clone` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 while incompatible command families/categories remain blocking. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-008 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 preserves empty-stdout exemption without stdoutBytes`; `BUG-032 Check 43 does not treat empty stdout as substantive cloned evidence` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 with the empty-stdout exemption independent of optional `stdoutBytes`. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-006, SCN-032-007, SCN-032-008 | Receipt schema compatibility | `bubbles/scripts/state-transition-guard-selftest.sh` using `bubbles/scripts/tool-log.sh` schema-v2 fixture rows | The SCN-032-006 through SCN-032-008 identifiers above | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Fixtures with and without optional `stdoutBytes`/`inputClosure` are handled conservatively. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-006, SCN-032-007, SCN-032-008 | Static shell syntax | `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/state-transition-guard-selftest.sh` | Shell syntax for Check 43 and its persistent SCN assertions | `bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0. |

### Scope 2 Consumer Impact Sweep

Check 43 diagnostics are consumed by every downstream transition guard. Update
source comments and evidence-contract docs so they no longer claim that
different commands cannot honestly emit identical stdout. No command name,
receipt field, or public path is renamed or removed.

### Scope 2 Change Boundary

**Allowed file families:** Check 43 logic, its persistent selftest, evidence
contract docs, G021/Gate metadata if wording changes, BUG-028 disposition, and
this packet.

**Excluded surfaces:** stale-receipt validation, tool-log schema changes unless
red fixtures prove them necessary, evidence admission for markdown-only repos,
and all downstream installed copies.

<!-- markdownlint-disable-next-line MD024 -->
### Definition of Done

- [x] SCN-032-006 deterministic-validator fixture fails before the production fix. → Evidence: [Scope 2 RED Evidence](report.md#scope-2-red-evidence)
- [x] SCN-032-006 same validator family/category plus independent target/execution provenance
  is not classified as a clone. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-007 cargo test versus npm lint sharing one substantive hash remains blocking. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-008 empty-stdout digest handling passes with present and absent stdoutBytes. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-006, SCN-032-007, and SCN-032-008 retain conservative handling when identity metadata is missing. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-006, SCN-032-007, and SCN-032-008 keep BUG-007 and BUG-019 regression assertions green. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [ ] BUG-028 is reconciled to the validate-certified BUG-032 evidence.
- [x] SCN-032-006, SCN-032-007, and SCN-032-008 have scenario-specific E2E regression tests for every changed behavior. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] Broader E2E regression suite passes → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] Consumer impact sweep confirms zero stale first-party references remain → Evidence: [Scope 2 Boundary Evidence](report.md#scope-2-boundary-evidence)
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Scope 2 Boundary Evidence](report.md#scope-2-boundary-evidence)

---

## Scope 3: G101 Delivery-Capable Mode Semantics

**Status:** Blocked
**Blocked by:** Scope 2 remains open pending BUG-028 documentation reconciliation.
**Scope-Kind:** contract-only
**Depends on:** Scope 2

### Scope 3 Goal

Require release reconciliation to prove delivered implementation, not merely a
terminal result in any workflow mode.

<!-- markdownlint-disable-next-line MD024 -->
### Gherkin Scenarios

```gherkin
Feature: Required release delivery semantics

  Scenario: SCN-032-009 - A validate-certified product-to-planning packet reaches specs_hardened
    Given a required release feature binds a spec in product-to-planning mode
    And the spec status and certification status are specs_hardened
    And validate appears in certified completed phases
    When G101 reconciles delivery=required
    Then the guard exits 1
    And the feature is reported NOT-DELIVERED

  Scenario: SCN-032-010 - A full-delivery packet is done and validate-certified
    Given a required release feature binds a full-delivery spec
    And the spec status is done
    And validate appears in certified completed phases
    When G101 reconciles delivery=required
    Then the guard exits 0
    And the feature is reported DELIVERED

  Scenario: SCN-032-011 - A validate-certified prototype reaches delivered_prototype
    Given a required release feature binds a prototype-tier spec
    And the spec status is delivered_prototype
    And validate appears in certified completed phases
    When G101 reconciles delivery=required
    Then the guard exits 1
    And the feature is reported NOT-DELIVERED

  Scenario Outline: SCN-032-012 - Terminal status meaning follows the resolved mode contract
    Given a required feature has status <status>
    And its resolved workflow mode is <mode>
    And validate certification is present
    When G101 reconciles delivery=required
    Then the delivery result is <result>

    Examples:
      | status | mode | result |
      | validated | validate-only | NOT-DELIVERED |
      | docs_updated | docs-only | NOT-DELIVERED |
      | delivered_pending_activation | dark-launch-shipped | DELIVERED |
      | delivered_fast | rapid-tool-delivery | DELIVERED |
```

### Scope 3 Implementation Plan

1. Extend the G101 selftest helper to accept an explicit workflow mode while
   retaining existing scenario defaults.
2. Add planning, docs-only, validate-only, rapid-delivery, and
   pending-activation fixtures. Run before production changes and capture the
   expected `specs_hardened` false pass as a failing assertion.
3. Resolve the effective mode using the canonical mode resolver.
4. Separate terminal-for-mode from delivery-capable terminality.
5. Preserve validate certification as a necessary condition, not a sufficient
   one.
6. Preserve legacy validate-certified `done` compatibility and explicit
   `delivered_prototype` refusal.
7. Run the focused G101 selftest.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| Scenario | Test Type | Persistent test file | Persistent test identifier | Exact command | Evidence and required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-009 | Regression E2E - pre-fix | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S13 product-to-planning/specs_hardened is not delivered` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Non-zero after S13 planning fixtures are added because the pre-fix G101 accepts `specs_hardened`. [Scope 3 RED Evidence](report.md#scope-3-red-evidence) |
| SCN-032-009 | Regression E2E - post-fix | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S13 product-to-planning/specs_hardened is not delivered`; `S13 reports planning maturity as NOT-DELIVERED` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 with planning maturity refused. [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence) |
| SCN-032-010 | Adversarial E2E - post-fix | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S16 full-delivery/done remains delivered`; `S16 reports a delivery-capable validate-certified success` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 with validate-certified full delivery accepted. [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence) |
| SCN-032-011 | Regression E2E - post-fix | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S12 required feature delivered_prototype is refused (prototype never deployable)`; `S12 reports prototype output as NOT-DELIVERED` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 with prototype output refused. [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence) |
| SCN-032-012 | Mode-contract E2E - post-fix | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S17 dark-launch-shipped/pending-activation remains delivered`; `S18 rapid-tool-delivery/delivered_fast remains delivered`; `S19 unknown mode gains no pending-activation fallback`; `S20 product-to-planning/done is incoherent, not delivered` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0; planning/docs/validate modes refuse and delivery aliases pass only under owning modes. [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence) |
| SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Mode contract | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` using `bubbles/workflows/modes.yaml` through the canonical resolver | The S12, S13, S16, S17, S18, S19, and S20 identifiers above | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 for the full decision table. [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence) |
| SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Static shell syntax | `bubbles/scripts/release-delivery-reconciliation-guard.sh`; `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Shell syntax for G101 and its persistent SCN assertions | `bash -n bubbles/scripts/release-delivery-reconciliation-guard.sh bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0. |

### Scope 3 Consumer Impact Sweep

G101 output is consumed by release workflows. Preserve its command line and exit
code vocabulary. Update status explanations and gate metadata; do not rename the
gate, command, release annotation fields, or runtime summary path.

### Scope 3 Change Boundary

**Allowed file families:** G101 guard/selftest, mode-resolution consumption,
release-delivery docs, gate metadata, generated registry/manifest surfaces, and
this packet.

**Excluded surfaces:** changing mode ceilings, redefining prototype assurance,
changing release annotation syntax, or modifying downstream release packets.

<!-- markdownlint-disable-next-line MD024 -->
### Definition of Done

- [x] SCN-032-009 product-to-planning plus specs_hardened plus validate certification exits 1. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-010 full-delivery plus done plus validate certification exits 0. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-011 delivered_prototype plus validate certification exits 1. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-012 validate-only/validated and docs-only/docs_updated exit 1. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-012 current delivered_pending_activation modes remain accepted only under
  their resolved delivery contracts. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-012 rapid-tool-delivery/delivered_fast remains accepted only under its
  resolved delivery contract. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-012 unknown mode aliases do not gain a permissive fallback. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] SCN-032-009, SCN-032-010, SCN-032-011, and SCN-032-012 have scenario-specific E2E regression tests for every changed behavior. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] Broader E2E regression suite passes → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)
- [x] Consumer impact sweep confirms zero stale first-party references remain → Evidence: [Scope 3 Boundary Evidence](report.md#scope-3-boundary-evidence)
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Scope 3 Boundary Evidence](report.md#scope-3-boundary-evidence)

---

## Validation-Only Scope 4: Contract Reconciliation And Full Validation

**Status:** Not Started
**Scope-Kind:** docs-only
**Depends on:** Scopes 1, 2, and 3

### Scope 4 Goal

Make source comments, gate metadata, shared documentation, generated framework
surfaces, and release evidence agree with the implemented contracts.

### Validation Contracts

These are process obligations bound to the canonical product scenarios. They do
not define additional Gherkin scenarios or manifest entries.

| Scenario binding | Scope 4 validation contract | Persistent validation surface | Required Scope 4 outcome |
| --- | --- | --- | --- |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005 | Focused classifier selftests and published Check 8B/5A contracts agree. | `bubbles/scripts/state-transition-guard-selftest.sh`, source comments, gate metadata, and shared framework documentation | No source claims whole-prose co-occurrence proves consumer mutation or that negated/no-SLO prose is an affirmative promise. |
| SCN-032-006, SCN-032-007, SCN-032-008 | Focused receipt-identity selftests and published Check 43 contracts agree. | `bubbles/scripts/state-transition-guard-selftest.sh`, evidence-contract documentation, and G021 metadata | No source claims different command strings cannot honestly emit identical stdout. |
| SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Focused delivery selftests and published G101 contracts agree. | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh`, mode-resolution documentation, and G101 metadata | No source claims every validate-certified terminal mode is delivered. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Full framework validation and release checks preserve all focused behavior. | Canonical generated surfaces, `framework-validate`, and `release-check` evidence captures | Both full commands exit 0 with current-session, hash-verifiable evidence before any Scope 4 DoD item is checked. |

### Scope 4 Implementation Plan

1. Search source comments, shared docs, gate metadata, BUGS entries, and release
   guidance for the four superseded claims.
2. Update only contracts changed by Scopes 1-3.
3. Reconcile BUG-028 to BUG-032 evidence after D3 is verified.
4. Regenerate derived framework surfaces through the canonical generator used by
   the release process. Do not hand-edit downstream copies.
5. Run focused selftests again.
6. Run full framework validation and release check through hash-verifiable
   evidence capture because their output exceeds the compact-output threshold.
7. Run final diff and unrelated-worktree checks.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| Scenario binding | Test Type | Persistent test file | Persistent test identifier | Exact command | Required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005 | Focused state-transition regression | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics`; `BUG032-IV-F1 Check 8B triggers on the exact mutation inflections 'renames' and 'removes'`; `BUG032-IV-F2 Check 8B does not bridge cache cleanup to an unchanged public API contract in another clause`; `BUG032-IV-F3 Check 5A accepts explicit no-SLA/no-SLO, negated-target, and not-applicable target prose without stress coverage`; `BUG-032 Check 5A still treats 'no more than 200 ms p95 latency' as an affirmative performance contract` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only after all focused classifier assertions pass. |
| SCN-032-006, SCN-032-007, SCN-032-008 | Focused receipt-identity regression | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 accepts independent deterministic validator siblings over distinct targets`; `BUG032-IV-F4 Check 43 blocks substantive stdout reuse across incompatible categories with one normalized command identity`; `BUG-032 Check 43 preserves empty-stdout exemption without stdoutBytes` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only after independent, incompatible, and empty-stdout assertions pass. |
| SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Focused G101 regression | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S13 product-to-planning/specs_hardened is not delivered`; `S16 full-delivery/done remains delivered`; `S12 required feature delivered_prototype is refused (prototype never deployable)`; `S17 dark-launch-shipped/pending-activation remains delivered`; `S18 rapid-tool-delivery/delivered_fast remains delivered`; `S19 unknown mode gains no pending-activation fallback`; `S20 product-to-planning/done is incoherent, not delivered` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 only after the full delivery decision table passes. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Full framework validation | Both persistent selftest files above through the canonical framework suite | All SCN-linked identifiers above | `bash bubbles/scripts/evidence-capture.sh --label "BUG-032 framework validate" -- bash bubbles/scripts/cli.sh framework-validate` | Captured exit 0 with verifiable full-output hash. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Release check | Both persistent selftest files above through the canonical release suite | All SCN-linked identifiers above | `bash bubbles/scripts/evidence-capture.sh --label "BUG-032 release check" -- bash bubbles/scripts/cli.sh release-check` | Captured exit 0 with verifiable full-output hash. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Agnosticity | Canonical source and generated framework surfaces | Portable-contract scan for the SCN-linked behavior | `bash bubbles/scripts/cli.sh agnosticity` | Exit 0; no downstream product name is introduced into portable framework fixtures. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Patch integrity | `bugs/BUG-032-planning-maturity-guard-false-positives/scopes.md` | Markdown and whitespace integrity for all SCN mappings | `git diff --check` | Exit 0. |

### Scope 4 Consumer Impact Sweep

Review all downstream-consumed source comments, gate descriptions, shared docs,
release guidance, and generated manifests. The public commands and gate IDs stay
stable. The sweep must prove there are no stale first-party descriptions of the
old classifier, clone, or delivery semantics.

### Scope 4 Change Boundary

**Allowed file families:** docs and registry entries directly governing D1-D4,
canonical generated outputs, BUG-028/BUG-032 tracking, and release notes.

**Excluded surfaces:** unrelated IMP files already modified in the worktree,
product-specific docs, downstream installed framework copies, and unrelated
gates.

<!-- markdownlint-disable-next-line MD024 -->
### Definition of Done

- [ ] Every changed behavior contract has synchronized source comments, docs, and
  gate metadata.
- [ ] Derived surfaces are generated by the canonical process rather than edited
  directly.
- [ ] Focused state-transition and G101 selftests pass.
- [ ] Full framework validation passes with current-session captured evidence.
- [ ] Release check passes with current-session captured evidence.
- [ ] Agnosticity and portability checks pass.
- [ ] `git diff --check` passes.
- [ ] Unrelated pre-existing changes under `improvements/` remain untouched.
- [ ] All checked DoD evidence is recorded only after actual execution.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
- [ ] Broader E2E regression suite passes
- [ ] Consumer impact sweep confirms zero stale first-party references remain
- [ ] Change Boundary is respected and zero excluded file families were changed
