# Specification: BUG-032 Planning-Maturity Guard False Positives

## Purpose

Define the behavior required to eliminate four framework false positives without
weakening the positive enforcement cases those guards protect.

## Outcome Contract

- **Intent:** Make planning-maturity and release guards classify explicit
  contract facts instead of inferring stronger claims from prose co-occurrence,
  deterministic output equality, or non-delivery terminality.
- **Success Signal:** All 12 BUG-032 scenarios and their adversarial twins pass,
  full framework validation and release checks pass, and BUG-028 is reconciled
  to validate-certified receipt-identity evidence.
- **Hard Constraints:** Preserve every positive enforcement case, Bash 3.2 and
  BSD/GNU portability, validate-owned certification, the declared work boundary,
  and the distinction between planning maturity and delivered implementation.
- **Failure Condition:** Any negative fixture still false-triggers, any positive
  twin stops blocking, incompatible receipt reuse escapes detection, a
  non-delivery mode satisfies G101, or a required framework/release gate fails.

## Operating Contract

This is a planning-only packet. It specifies future behavior and exact validation
commands. It does not claim that a regression test has failed, a fix has landed,
or any validation command has passed.

## Definitions

- **Consumer interface mutation:** an explicit rename, removal, move, or
  deprecation of a route, path, endpoint, contract, API, URL, slug, identifier,
  symbol, link, breadcrumb, navigation target, or redirect.
- **Replacement semantics:** prose describing stale generated material,
  providers, implementations, lifecycle states, or conceptual successors without
  changing a consumer-visible interface identity.
- **Affirmative performance contract:** a declared latency, throughput, response
  time, p95, p99, SLA, or SLO target, budget, threshold, or guarantee.
- **Explicit opt-out:** wording that says SLA/SLO or observability evidence is
  absent, disabled, not applicable, unavailable, or opted out.
- **Deterministic validator sibling executions:** separate executions of the same
  validator family and evidence category over distinct targets or input closures,
  carrying independent execution provenance, that legitimately emit identical
  non-empty stdout.
- **Delivery-capable terminal state:** a state whose resolved workflow contract
  represents shipped implementation rather than planning, documentation,
  validation-only review, or prototype-only output.

## User Scenarios

### SCN-032-001 - Stale generation path replacement is not an interface mutation

```gherkin
Scenario: A stale generated path is replaced without changing a consumer interface
  Given a scope says a stale generation path is replaced by current generated output
  And the scope does not rename, remove, move, or deprecate a consumer route, path, endpoint, contract, or identifier
  When Check 8B classifies the scope
  Then the scope is not required to add a Consumer Impact Sweep
```

### SCN-032-002 - Provider and lifecycle replacement is not an interface mutation

```gherkin
Scenario Outline: Replacement semantics remain outside consumer mutation classification
  Given a scope describes <replacement>
  And no consumer-visible interface identity changes
  When Check 8B classifies the scope
  Then the scope is not required to add a Consumer Impact Sweep

  Examples:
    | replacement |
    | a provider implementation being replaced |
    | a lifecycle state being replaced by its successor |
    | a generated artifact replacing a stale artifact path |
```

### SCN-032-003 - Actual interface rename or removal still triggers

```gherkin
Scenario Outline: A real consumer interface mutation requires impact planning
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
```

### SCN-032-004 - Explicit no-SLO wording does not trigger stress coverage

```gherkin
Scenario: An opted-out observability sentence is not an SLA promise
  Given a scope says observability is opted out and no trace or SLO evidence is injected
  And the scope declares no latency, throughput, response-time, p95, p99, SLA, or SLO target
  When Check 5A classifies the scope
  Then the scope is not required to add stress coverage
```

### SCN-032-005 - Genuine performance promises still trigger stress coverage

```gherkin
Scenario Outline: An affirmative performance contract requires stress coverage
  Given a scope declares <promise>
  When Check 5A classifies the scope
  Then the scope requires explicit stress coverage

  Examples:
    | promise |
    | an SLO of 99.9 percent availability |
    | a p95 latency budget of 200 ms |
    | a throughput target of 1000 requests per second |
    | a p99 response-time threshold of 500 ms |
```

### SCN-032-006 - Deterministic validator siblings are independent evidence

```gherkin
Scenario: One validator runs independently over two spec targets
  Given two successful artifact-lint executions have the same executable family and lint category
  And each execution targets a different spec directory
  And each receipt has independent time or session provenance and a distinct target or input closure
  And both executions emit the same non-empty stdout hash
  When Check 43 evaluates receipt identity
  Then it does not report a receipt clone
```

### SCN-032-007 - Unrelated commands sharing substantive output still block

```gherkin
Scenario: One substantive output hash appears under unrelated command identities
  Given a cargo test receipt and an npm lint receipt share one non-empty stdout hash
  And their command families or evidence categories are incompatible
  When Check 43 evaluates receipt identity
  Then it reports a receipt clone
  And the finding names the incompatible command families or categories
```

### SCN-032-008 - Empty stdout remains exempt

```gherkin
Scenario: Different commands emit no stdout
  Given multiple receipts carry the SHA-256 digest of empty stdout
  When Check 43 evaluates receipt identity
  Then it does not report a receipt clone
  And the exemption does not depend on the optional stdoutBytes field
```

### SCN-032-009 - Planning maturity is not release delivery

```gherkin
Scenario: A validate-certified product-to-planning packet reaches specs_hardened
  Given a required release feature binds a spec in product-to-planning mode
  And the spec status and certification status are specs_hardened
  And validate appears in certified completed phases
  When G101 reconciles delivery=required
  Then the guard exits 1
  And the feature is reported NOT-DELIVERED
```

### SCN-032-010 - Validate-certified done delivery remains accepted

```gherkin
Scenario: A full-delivery packet is done and validate-certified
  Given a required release feature binds a full-delivery spec
  And the spec status is done
  And validate appears in certified completed phases
  When G101 reconciles delivery=required
  Then the guard exits 0
  And the feature is reported DELIVERED
```

### SCN-032-011 - Prototype output remains non-deliverable

```gherkin
Scenario: A validate-certified prototype reaches delivered_prototype
  Given a required release feature binds a prototype-tier spec
  And the spec status is delivered_prototype
  And validate appears in certified completed phases
  When G101 reconciles delivery=required
  Then the guard exits 1
  And the feature is reported NOT-DELIVERED
```

### SCN-032-012 - Delivery aliases are resolved through mode semantics

```gherkin
Scenario Outline: Terminal status meaning follows the resolved mode contract
  Given a required release feature has status <status>
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

## Functional Requirements

- **FR-032-001:** Check 8B MUST classify only explicit consumer-interface
  rename, removal, move, or deprecation semantics as consumer-impact work.
- **FR-032-002:** `replace`, `replaced`, and generic `migration` wording MUST NOT
  independently establish a consumer-interface mutation.
- **FR-032-003:** Check 8B MUST retain positive coverage for actual route, path,
  endpoint, contract, and identifier rename/removal declarations.
- **FR-032-004:** Check 5A MUST distinguish an affirmative performance contract
  from an explicit no-SLA/no-SLO/opted-out posture.
- **FR-032-005:** A quantitative target, budget, threshold, or guarantee MUST
  take precedence over a broad negation suppression when both appear.
- **FR-032-006:** Check 5A MUST retain positive coverage for SLA, SLO, latency,
  throughput, p95, p99, and response-time declarations.
- **FR-032-007:** Check 43 MUST preserve the empty-stdout digest exemption and
  MUST NOT make it depend on optional `stdoutBytes`.
- **FR-032-008:** Check 43 MUST derive receipt identity from more than
  `stdoutHash`, using command family/executable, evidence category, exit status,
  execution time or session provenance, and target/input closure when present.
- **FR-032-009:** Two independently evidenced runs of the same deterministic
  validator category over distinct targets MUST NOT be classified as clones
  solely because stdout is byte-identical.
- **FR-032-010:** A substantive hash shared by incompatible command families or
  evidence categories MUST remain blocking.
- **FR-032-011:** Missing identity metadata MUST NOT create a blanket exemption.
  The implementation must retain a conservative result when execution
  independence cannot be established.
- **FR-032-012:** G101 MUST resolve terminal status against the effective mode
  contract, not terminality alone.
- **FR-032-013:** `specs_hardened`, `validated`, and `docs_updated` MUST NOT
  satisfy `delivery=required` under their current planning, validation-only, and
  docs-only mode classes.
- **FR-032-014:** `done` with validate certification MUST remain accepted for a
  delivery-capable packet. An explicitly non-delivery mode claiming `done` MUST
  be rejected as incoherent.
- **FR-032-015:** `delivered_pending_activation` MUST remain accepted only when
  it is the terminal state of a resolved delivery-capable mode and validate
  certification is present.
- **FR-032-016:** `delivered_fast` MUST remain accepted only for its resolved
  rapid delivery mode and validate certification.
- **FR-032-017:** `delivered_prototype` MUST remain refused regardless of
  validate certification.
- **FR-032-018:** Every negative regression MUST have an adversarial positive
  twin that fails if the implementation disables or broadly exempts the guard.
- **FR-032-019:** Regression coverage MUST persist in
  `state-transition-guard-selftest.sh` and
  `release-delivery-reconciliation-guard-selftest.sh`.
- **FR-032-020:** Contract prose in source comments, gate metadata, and shared
  framework documentation MUST be updated when implementation changes their
  current claims.

## G101 Delivery Decision Table

| Status | Current mode meaning | Required result | Reason |
| --- | --- | --- | --- |
| `specs_hardened` | Planning-only terminal ceiling | Refuse | Planning artifacts are mature; product behavior is not delivered. |
| `validated` | Validation/readiness terminal ceiling | Refuse | A read-only or validation-only outcome is not implementation delivery. |
| `docs_updated` | Documentation terminal ceiling | Refuse | Documentation completion does not ship product behavior. |
| `done` | Full delivery terminal state | Accept with validate certification | This is the ordinary delivered state. |
| `delivered_fast` | Rapid delivery terminal alias | Accept only under its resolved delivery mode and validate certification | The mode ships a bounded implementation. |
| `delivered_pending_activation` | Implementation shipped; external activation remains | Accept only under a resolved pending-activation delivery mode and validate certification | The deliverable exists even though activation is externally gated. |
| `delivered_prototype` | Prototype assurance tier | Refuse | Prototype output is explicitly non-deployable. |

## Non-Functional Requirements

- The classifiers MUST remain POSIX/BSD-compatible on macOS and GNU-compatible
  on Linux/WSL.
- The implementation MUST not introduce an unbounded whole-repository scan.
- Diagnostic output MUST identify why a declaration was treated as positive,
  negative, independent, incompatible, or non-delivery.
- Existing downstream receipt schemas MUST remain readable.
- The change MUST not require modifying downstream planning prose to preserve
  truthfulness.

## Out Of Scope

- A general natural-language parser for all framework policy prose
- Retiring Consumer Impact Sweep, stress coverage, receipt clone detection, or
  release reconciliation
- Replacing structured receipts with stdout similarity
- Reclassifying planning, docs, validation-only, or prototype modes as delivery
- Editing downstream Ozhiva artifacts

## Acceptance Criteria

1. All twelve scenarios have persistent executable assertions.
2. The four required negative fixture families pass after the fix.
3. Every positive/adversarial twin still triggers the protected guard behavior.
4. The focused selftests pass on macOS and through the framework validation
   compatibility environment.
5. G101 exits 1 for product-to-planning plus `specs_hardened` plus validate
   certification, exits 0 for full-delivery plus `done` plus validate
   certification, and exits 1 for `delivered_prototype`.
6. Empty-stdout receipt handling remains covered and green.
7. Framework docs and gate descriptions no longer state that differing command
   strings or generic terminality alone prove cloning or delivery.
8. The full framework validation and release check pass with current-session,
   hash-verifiable evidence.
