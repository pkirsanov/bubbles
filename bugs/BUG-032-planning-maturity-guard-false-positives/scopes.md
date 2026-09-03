# Scopes: BUG-032 Planning-Maturity Guard False Positives

## Execution Outline — Analyst And Design Reconciliation

### Phase Order

1. **Scope 1 — Semantic planning classifiers.** Reconcile Check 8B, Check 5A,
   and G040 through one tests-first state-transition lane.
2. **Scope 2 — Receipt identity.** Repair Check 43 after Scope 1 releases the
   shared state-transition source and selftest.
3. **Scope 3 — Delivery authority.** Preserve the independently verified G101
   repair while planning and evidence reach one coherent epoch.
4. **Scope 4 — Verification and release closure.** Verify five artifact
   obligations, generate the release manifest last, and run final validation.

### New Types And Signatures

- `check8b_classify_line <physical-line>` returns one closed Check 8B record.
- The Check 8B record carries class, reason, target, surfaces, and finite bounds.
- The context projection emits active declarations and structural table facts.
- A Check 5A performance contract carries polarity, metric, bound, and unit.
- A Check 43 identity carries the underlying program and complete target set.
- A G101 decision names the resolved mode and certification authority.
- No public command, receipt schema, route, or persistent data schema changes.

### Validation Checkpoints

- Planning contains exactly 26 active behavior scenarios before test edits.
- Row 144 remains accepted A-RED for its recorded pre-repair byte epoch.
- A fresh unchanged run recovers row 145's actual failure before test edits.
- The four security assertions then reach RED against unchanged production.
- Focused and full GREEN use the unchanged security test identities.
- Independent test and repeated security review release the shared source family.
- Scope 2 then captures B-RED, B-GREEN, and independent verification.
- Scope 3 retains rows 125 through 129 as independent C-GREEN evidence.
- Scope 4 verifies five non-behavior obligations after A, B, and C converge.
- The release-manifest generator runs after every tracked input settles.
- Final focused, framework, and release checks use one byte epoch.

### Current Planning Truth

- All four scopes are `In Progress`.
- Rows 130 and 141 are diagnostic history, not admissible A-RED evidence.
- Their closures include the rejected G068 same-ID assertion.
- Row 144 is accepted A-RED for its recorded pre-repair byte epoch.
- Row 145 exited one and remains a failed, nonterminal GREEN attempt.
- C-GREEN is independently verified but does not close Scope 3.
- The next owner is `bubbles.test` for unchanged-baseline recovery and the
  persistent four-finding security RED.
- B waits for A because both lanes write the state-transition source family.
- The BUG-035 empty-output-count finding remains outside this BUG-032 target.

Related artifacts: [specification](spec.md), [design](design.md),
[scenario contracts](scenario-manifest.json), [machine test handoff](test-plan.json),
[execution evidence](report.md), and [human acceptance](uservalidation.md).

## Active Behavior Inventory

The active inventory contains exactly these 26 behavior contracts:

`SCN-032-001`, `SCN-032-002`, `SCN-032-003`, `SCN-032-004`,
`SCN-032-005`, `SCN-032-006`, `SCN-032-007`, `SCN-032-008`,
`SCN-032-009`, `SCN-032-010`, `SCN-032-011`, `SCN-032-012`,
`SCN-032-013`, `SCN-032-014`, `SCN-032-015`, `SCN-032-016`,
`SCN-032-020`, `SCN-032-021`, `SCN-032-022`, `SCN-032-025`,
`SCN-032-026`, `SCN-032-028`, `SCN-032-033`, `SCN-032-034`,
`SCN-032-035`, and `SCN-032-036`.

### Folded Candidate Coverage

| Candidate | Surviving behavior | Folded coverage |
| --- | --- | --- |
| SCN-032-017 | SCN-032-013 | Passive removal stays with its actual object. |
| SCN-032-018 | SCN-032-015 | Passive artifact tails remain unresolved until clarified. |
| SCN-032-019 | SCN-032-014 | Owned passive negation preserves the surface. |
| SCN-032-023 | SCN-032-006 | Every command identity contributes its complete target set. |
| SCN-032-024 | SCN-032-007 | Transparent wrappers preserve underlying program identity. |

The artifact candidates formerly numbered 027, 030, 031, and 032 are not
behavior scenarios. Scope 4 carries their work as named verification
obligations. G068 retains structural-strict matching and gains no new matcher
policy.

## Scope 4 Verification Obligation Inventory

| Obligation | Finding | Required proof |
| --- | --- | --- |
| Evidence-anchor fidelity | `BUG032-HARDEN9-EVIDENCE-ANCHORS-011` | Checked claims resolve to substantive owner evidence without changing raw evidence. |
| G068 DoD fidelity | `BUG032-HARDEN9-G068-DOD-013` | SCN-032-014 DoD text states direct and owned-negation behavior. |
| Release-manifest finality | `BUG032-HARDEN9-RELEASE-MANIFEST-014` | Generation runs after all tracked inputs and freshness passes. |
| Test-comment truth | `BUG032-HARDEN9-TEST-PROSE-015` | Each owning selftest comment describes adjacent assertions. |
| Report-routing truth | `BUG032-HARDEN9-REPORT-ROUTE-016` | Active routing names only unresolved BUG-032 work. |

## Convergence-9 Finding Accounting

| Finding | Planning disposition | Owner route |
| --- | --- | --- |
| `BUG032-HARDEN9-C8B-PASSIVE-OBJECT-001` | Folded into SCN-032-013. | A test, implementation, independent test |
| `BUG032-HARDEN9-C8B-PASSIVE-TAIL-002` | Folded into SCN-032-015. | A test, implementation, independent test |
| `BUG032-HARDEN9-C8B-PASSIVE-NEGATION-003` | Folded into SCN-032-014. | A test, implementation, independent test |
| `BUG032-HARDEN9-C8B-CONTEXT-004` | Retained as SCN-032-020. | A test, implementation, independent test |
| `BUG032-HARDEN9-C5A-CONTEXT-005` | Retained as SCN-032-021. | A test, implementation, independent test |
| `BUG032-HARDEN9-C5A-COVERAGE-PROXY-006` | Retained as SCN-032-022. | A test, implementation, independent test |
| `BUG032-HARDEN9-C43-TARGET-OVERLAP-007` | Folded into SCN-032-006. | B test after A, implementation, independent test |
| `BUG032-HARDEN9-C43-WRAPPER-IDENTITY-008` | Folded into SCN-032-007. | B test after A, implementation, independent test |
| `BUG032-HARDEN9-C43-STDOUTBYTES-009` | Retained as SCN-032-025. | B test after A, implementation, independent test |
| `BUG032-HARDEN9-G101-CERTIFICATION-010` | Independently verified on the C source pair. Scope 3 remains nonterminal. | Preserve for final validation |
| `BUG032-HARDEN9-EVIDENCE-ANCHORS-011` | Planning-owned verification obligation. | `bubbles.plan` current checks |
| `BUG032-HARDEN9-G040-BOUNDARIES-012` | Retained as SCN-032-028. | A test, implementation, independent test |
| `BUG032-HARDEN9-G068-DOD-013` | Planning-owned verification obligation. | `bubbles.plan` current checks |
| `BUG032-HARDEN9-RELEASE-MANIFEST-014` | Verification obligation that runs last. | `bubbles.devops` |
| `BUG032-HARDEN9-TEST-PROSE-015` | Split by owning selftest file. | A/B test owner and C test owner |
| `BUG032-HARDEN9-REPORT-ROUTE-016` | Planning-owned verification obligation. | `bubbles.plan` current checks |

## Serialized Execution DAG

| Node | Owner | Write surface | Depends on | Current disposition |
| --- | --- | --- | --- | --- |
| P | `bubbles.plan` | Allowed BUG-032 planning artifacts | Verified spec and design | This reconciliation |
| A-BASELINE | `bubbles.test` | Evidence only from unchanged row-145 source and selftest family | P | First action |
| A-SECURITY-RED | `bubbles.test` | Persistent SCN-032-033 through SCN-032-036 assertions | A-BASELINE | Active route |
| A-SECURITY-GREEN | `bubbles.implement` | Planning checks, state-transition guard, unchanged security assertions | A-SECURITY-RED | Waiting |
| A-FULL-GREEN | `bubbles.test` | Evidence only from the unchanged complete A oracle | A-SECURITY-GREEN | Waiting |
| A-VERIFY | `bubbles.test` | Independent focused and complete evidence | A-FULL-GREEN | Waiting |
| A-SECURITY-REVIEW | `bubbles.security` | Diagnostic evidence only | A-VERIFY | Waiting |
| B-RED | `bubbles.test` | Check 43 assertions in the shared selftest | A-VERIFY | Waiting for A |
| B-GREEN | `bubbles.implement` | Check 43 source and assertions | B-RED | Waiting |
| B-VERIFY | `bubbles.test` | Evidence only | B-GREEN | Waiting |
| C-GREEN | `bubbles.test` | Evidence only | Existing C implementation | Independently verified |
| S4 | Owning specialists | Five verification surfaces | A-VERIFY, B-VERIFY, C-GREEN | Waiting |
| M | `bubbles.devops` | Generated release manifest | Every tracked input settled | Last writer |
| V | `bubbles.validate` | Validation evidence and certification-owned state | M | Waiting |

## Ordered Scope Inventory

| Order | Scope | Depends on | Status |
| --- | --- | --- | --- |
| 1 | Semantic planning classifiers | None | In Progress |
| 2 | Receipt clone execution identity | Scope 1 | In Progress |
| 3 | G101 delivery authority | None | In Progress |
| 4 | Verification and release closure | Scopes 1, 2, and 3 | In Progress |

---

## Scope 1: Semantic Planning Classifiers

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** None

### Goal

Make Check 8B and Check 5A classify active declarations only. Preserve direct
controls, finite bounds, and G040 complete-phrase behavior.

### Gherkin Scenarios

```gherkin
Feature: Planning declaration classification

  Scenario: SCN-032-001 - A stale generated path is replaced without changing a consumer interface
    Given a scope says a stale generation path is replaced by current generated output
    And no consumer route, path, endpoint, contract, or identifier changes
    When Check 8B classifies the scope
    Then the scope does not require a Consumer Impact Sweep

  Scenario Outline: SCN-032-002 - Replacement semantics remain outside consumer mutation classification
    Given a scope describes <replacement>
    And no consumer-visible interface identity changes
    When Check 8B classifies the scope
    Then the scope does not require a Consumer Impact Sweep

    Examples:
      | replacement |
      | a provider implementation being replaced |
      | a lifecycle state being replaced by its successor |
      | a generated artifact replacing a stale artifact path |

  Scenario Outline: SCN-032-003 - A real consumer interface mutation requires impact planning
    Given a scope explicitly <mutation> a consumer-visible <surface>
    When Check 8B classifies the scope
    Then the scope requires a Consumer Impact Sweep
    And it requires the consumer-impact completion item
    And it enumerates affected consumer surfaces

    Examples:
      | mutation | surface |
      | renames | route |
      | removes | path |
      | renames | endpoint |
      | removes | contract |
      | renames | identifier |

  Scenario: SCN-032-004 - An opted-out observability sentence is not an SLA promise
    Given a scope opts out of observability and declares no performance target
    When Check 5A classifies the scope
    Then the scope does not require stress coverage

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

  Scenario Outline: SCN-032-013 - Another object mutation does not transfer to a used consumer surface
    Given a scope says <declaration>
    And removal applies to stale cache entries instead of the public API route
    When Check 8B classifies the scope
    Then the route is preserved and impact checks are skipped
    And direct active or passive route removal still runs all three checks

    Examples:
      | declaration |
      | Remove stale cache entries before invoking the public API route without changing that route. |
      | The public API route is used while stale cache entries are removed. |

  Scenario Outline: SCN-032-014 - Unrelated negation does not exempt direct route removal
    Given one physical line says <declaration>
    When Check 8B classifies the line
    Then route remains direct-positive and runs all three impact checks
    And owned will-not negation preserves route and skips those checks
    And will-be removal remains direct-positive

    Examples:
      | declaration |
      | No cache migration is required; remove the public route. |
      | No cache migration is required. The public route is removed. |
      | Without migration remove the public route. |
      | The public route without migration is removed. |

  Scenario Outline: SCN-032-015 - Active and passive artifact tails require explicit ownership
    Given a scope says <declaration>
    When Check 8B classifies the declaration
    Then the unresolved form is ambiguous with reason surface-tail
    And the direct control remains direct-positive
    And the clarified artifact mutation preserves the consumer surface

    Examples:
      | declaration |
      | Remove the public API route example. |
      | Remove the endpoint test. |
      | The endpoint test is removed. |
      | The route example is removed. |

  Scenario Outline: SCN-032-016 - Exact limits proceed and first overflow or helper error blocks
    Given Check 8B receives <condition>
    When the classifier and guard evaluate it
    Then the classifier reports <classification> with reason <reason>
    And the guard follows the declared finite-boundary behavior

    Examples:
      | condition | classification | reason |
      | exactly 128 examined tokens | direct-positive | direct |
      | token 129 detected | ambiguous | token-limit |
      | exactly eight mutation candidates | direct-positive | direct |
      | candidate nine detected | ambiguous | candidate-limit |
      | bounded normalization fails | error | normalization-error |

  Scenario Outline: SCN-032-020 - Check 8B distinguishes fixtures from active declarations
    Given <context> contains "Remove the endpoint test."
    When Check 8B scans the complete scope artifact
    Then fixture text creates no active mutation result
    And the identical active declaration remains enforceable

    Examples:
      | context |
      | a fenced Gherkin scenario |
      | an Examples table cell |
      | a Test Plan description cell |

  Scenario Outline: SCN-032-021 - Check 5A distinguishes fixtures from active performance contracts
    Given <context> contains "The p95 latency budget is 200 ms."
    When Check 5A scans the complete scope artifact
    Then fixture text creates no affirmative contract
    And the identical active declaration remains affirmative

    Examples:
      | context |
      | a fenced Gherkin scenario |
      | an Examples table cell |
      | a Test Plan description cell |

  Scenario: SCN-032-022 - Prose-only stress wording cannot satisfy performance coverage
    Given an active scope declares a p95 latency contract
    And prose contains the word stress
    But no canonical Stress row and faithful DoD item cover that contract
    When Check 5A validates coverage
    Then it names both missing structures
    And the canonical Stress row plus faithful DoD control passes

  Scenario Outline: SCN-032-028 - G040 matches complete prohibited phrases only
    Given an active report or scope line contains <text>
    When G040 evaluates the line outside historical evidence
    Then the result is <result>

    Examples:
      | text | result |
      | A separate preservation clause stays negative. | allowed |
      | These are declared future workflow obligations. | allowed |
      | Move this work to a separate ticket. | blocked |
      | Implement this in a future scope. | blocked |

  Scenario Outline: SCN-032-033 - Context projection failures block both planning classifiers
    Given the scope context projection encounters <condition>
    When Check 8B and Check 5A consume the projection
    Then both checks produce <outcome>
    And failed or incomplete input never becomes an ordinary exemption
    And a failed partial projection discards every emitted record
    And the first projection failure ends processing without an automatic retry

    Examples:
      | condition | outcome |
      | a readable scope with a complete empty projection | ordinary no-declaration results |
      | a readable scope with complete active records | ordinary semantic results |
      | a producer failure before any record | a blocking context-projection-error |
      | a producer failure after a valid record prefix | a blocking context-projection-error with discarded records |
      | an input-read failure before completion | a blocking context-read-error |

  Scenario Outline: SCN-032-034 - Exact Markdown fixture structure fails closed
    Given a scope contains <context>
    When the shared context projection validates the complete scope
    Then the projection produces <result>
    And malformed structure blocks both Check 8B and Check 5A
    And a valid fixture does not suppress its identical active declaration

    Examples:
      | context | result |
      | a recognized Gherkin fence closed by the identical marker and length | fixture rows excluded |
      | a four-character fence closed by a three-character marker | fence-identity-error at opener and closer |
      | a backtick fixture fence closed by a tilde marker | fence-identity-error naming both marker types |
      | a recognized fixture fence with no exact closer | unclosed-fence-error at the opener |
      | a valid Examples table | fixture rows excluded |
      | an Examples table with a missing delimiter or inconsistent columns | examples-table-error at the first malformed row |
      | a valid Test Plan table | fixture cells excluded and structural rows preserved |
      | a Test Plan table with a missing delimiter or inconsistent columns | test-plan-table-error at the first malformed row |
      | an ordinary text fence with an active declaration | the declaration remains active |

  Scenario Outline: SCN-032-035 - G040 recognizes exact phrases across approved separators
    Given an active scope or report line contains <text>
    When G040 evaluates that physical line outside historical evidence
    Then the result is <result>
    And a block names the canonical phrase and original matched form
    And matching never crosses a newline or accepts a different second token

    Examples:
      | text | result |
      | Move this work to a separate ticket. | blocked |
      | Move this work to a Separate  Ticket. | blocked |
      | separate followed by one horizontal tab and ticket | blocked |
      | Move this work to a separate-ticket. | blocked |
      | Implement this in a FUTURE SCOPE. | blocked |
      | future followed by mixed spaces and horizontal tabs and scope | blocked |
      | Implement this in a future-scope. | blocked |
      | A separate preservation clause stays negative. | allowed |
      | These are future workflow obligations. | allowed |
      | The text says separately ticketed. | allowed |
      | The text says future scoped analysis. | allowed |

  Scenario Outline: SCN-032-036 - Line and token byte limits bound Check 8B work
    Given Check 8B receives <condition>
    When it validates byte bounds before token and relationship analysis
    Then it produces <classification> with reason <reason>
    And it reports <boundary>
    And overflow skips all three Consumer Impact Sweep checks

    Examples:
      | condition | classification | reason | boundary |
      | a direct declaration padded to exactly 4096 bytes | direct-positive | direct | line-bytes=4096/4096 |
      | the same declaration with byte 4097 | ambiguous | line-byte-limit | line-bytes=4097/4096:first-overflow |
      | a direct declaration with one neutral token of exactly 256 bytes | direct-positive | direct | token-bytes=256/256 |
      | the same declaration with token byte 257 | ambiguous | token-byte-limit | token-bytes=257/256:first-overflow |
      | one 100000-byte token | ambiguous | line-byte-limit | line-bytes=4097/4096:first-overflow |

    And the line decision inspects at most 4097 bytes
    And the token decision retains at most 256 bytes and inspects byte 257 only as a sentinel
    And the existing 128 and 129 token outcomes remain unchanged
    And the existing eight and nine candidate outcomes remain unchanged
```

### Implementation Plan

1. Preserve row 144 as accepted A-RED for its recorded pre-repair byte epoch.
2. Preserve row 145 as a failed, nonterminal GREEN attempt without assigning a cause.
3. Replay the unchanged row-145 family and record its exact current failure.
4. Add the SCN-032-033 through SCN-032-036 persistent assertions only.
5. Keep production hashes `29cdfed6679109a1ee27f576959f3c7c83e0ef35f999f005d9c0ee7b87a12544`
  and `23d61add2d13e4cc363395721c99886ad9d12927dfddf43eda6c38f8b029e7e8`
  unchanged through the security RED.
6. Capture one RED that reaches every security assertion and every paired control.
7. Repair projection completion, exact Markdown structure, G040 separators, and byte admission.
8. Re-run the unchanged security assertions for focused GREEN.
9. Run the unchanged complete A oracle on the same test identity.
10. Obtain independent focused and complete verification on the final hashes.
11. Repeat the security review against those exact hashes.
12. Release the shared source family to B only after independent A verification.
13. Keep Check 43 and G101 implementation bytes outside this scope.

### Consumer Impact Sweep

This scope changes classifier decisions, not public command names. Consumers
include scope authors, guard diagnostics, planning checks, and persistent
selftests. No route, path, endpoint, or identifier is renamed.

### Change Boundary

**Allowed:** planning checks, state-transition source, the state-transition
selftest, adjacent truth-only comments, and this BUG-032 packet under each
canonical owner.

**Excluded:** Check 43 repair, G101 source, certification, human acceptance,
generated outputs, downstream copies, deployment, host state, and model state.

### Historical Checked Evidence Retained

These checked rows preserve narrower historical facts. They do not close the
reopened scope or the folded behavior contracts.

- [x] The original SCN-032-001 through SCN-032-005 classifier matrix passed its recorded epoch. → Evidence: [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence)
- [x] The original active-form SCN-032-013 controls passed without the folded passive-object case. → Evidence: [Receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] The original SCN-032-014 unrelated-negation controls passed without the rejected G068 assertion. → Evidence: [Receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] The original active-form SCN-032-015 artifact-tail controls passed before passive tails joined the contract. → Evidence: [Receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-016 finite limits, helper errors, sourceability, and no-process controls passed their recorded epoch. → Evidence: [Receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)

### Test Plan

| Test ID | Scenario binding | Type | File | Exact persistent titles | Command | Required result |
| --- | --- | --- | --- | --- | --- | --- |
| TP-01-01 | All prior Scope 1 scenarios | Regression functional | `bubbles/scripts/state-transition-guard-selftest.sh` | Every manifest-linked title for SCN-032-001 through SCN-032-005, SCN-032-013 through SCN-032-016, SCN-032-020 through SCN-032-022, and SCN-032-028 | `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | Preserve every prior positive, negative, boundary, and active-twin control. |
| TP-01-02 | SCN-032-013 through SCN-032-016, SCN-032-020 through SCN-032-022, SCN-032-028 | Prior accepted tests-first RED | `bubbles/scripts/state-transition-guard-selftest.sh` | The exact authorized row-144 titles, with no SCN-032-029 assertion | Row 144 command: `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 11100 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-032 clean TP-01-02 authorized A-RED after route-oracle repair" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | Preserve row 144 as accepted A-RED only for its recorded pre-repair byte epoch. |
| TP-01-03 | All prior Scope 1 scenarios | Unchanged baseline recovery | `bubbles/scripts/state-transition-guard-selftest.sh` | The unchanged row-145 oracle titles | `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 11100 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-032 unchanged row-145 baseline recovery" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | Record the actual result and exact failing assertion without assigning a cause in advance. |
| TP-01-04 | SCN-032-033 through SCN-032-036 | Tests-first security RED | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 SEC-001 blocks Check 8B and Check 5A on producer and input-read failure`; `BUG-032 SEC-001 discards partial projection records and preserves complete controls`; `BUG-032 SEC-002 rejects fence identity and fixture table structure defects in first-error order`; `BUG-032 SEC-002 preserves valid fixture suppression and identical active twins`; `BUG-032 SEC-003 matches exact G040 phrases across case and horizontal separators`; `BUG-032 SEC-003 preserves punctuation boundaries and benign near-miss twins`; `BUG-032 SEC-004 enforces exact 4096 and 4097 line-byte boundaries`; `BUG-032 SEC-004 enforces exact 256 and 257 token-byte boundaries`; `BUG-032 SEC-004 preserves 128 and 129 token and eight and nine candidate controls`; `BUG-032 SEC-004 bounds oversized one-token input before semantic work` | `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 11100 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-032 four-finding security RED" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit nonzero against unchanged production. Each finding block reaches a failing assertion, and every paired valid control executes. |
| TP-01-05 | SCN-032-033 through SCN-032-036 | Focused security GREEN | `bubbles/scripts/state-transition-guard-selftest.sh` | The exact unchanged ten TP-01-04 titles | `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 11100 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-032 focused four-finding security GREEN" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | All ten security titles pass after production repair. The test file identity matches the RED oracle. |
| TP-01-06 | All Scope 1 scenarios | Unchanged full GREEN | `bubbles/scripts/state-transition-guard-selftest.sh` | Every prior and security title from TP-01-01 and TP-01-04 | `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 11100 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-032 unchanged complete A GREEN" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit zero with the same security test-file hash used by RED and focused GREEN. |
| TP-01-07 | All Scope 1 scenarios | Independent regression | `bubbles/scripts/state-transition-guard-selftest.sh` | The exact unchanged TP-01-06 title set | `/opt/local/bin/gtimeout --signal=TERM --kill-after=60s 11100 /opt/homebrew/bin/bash bubbles/scripts/evidence-capture.sh --label "BUG-032 independent complete A verification" -- /opt/local/bin/gtimeout --signal=TERM --kill-after=60s 10800 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | A separate test-owner run exits zero on the recorded final source and test hashes. |
| TP-01-08 | SCN-032-036 | Bounded oversized-token regression | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 SEC-004 bounds oversized one-token input before semantic work` | `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 120 /opt/homebrew/bin/bash bubbles/scripts/state-transition-guard-selftest.sh` | The persistent case admits at most 4,097 line bytes, reports `line-byte-limit`, starts no semantic work, and completes within the 120-second outer guard. |
| TP-01-09 | SCN-032-033 through SCN-032-036 | Repeated security review | Final A source and test hashes | All four `BUG032-SEC-*` findings plus hostile input, path, cleanup, and no-retry controls | `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/security-gate.sh --repo-root .` followed by an independent `bubbles.security` review | The mechanical gate exits zero, and security reports all four findings addressed on the independently verified hashes. |
| TP-01-10 | All Scope 1 scenarios | Syntax, portability, and regression quality | `bubbles/scripts/guards/planning-checks.sh`; `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/state-transition-guard-selftest.sh` | Shell syntax plus the persistent bugfix quality scan | `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash -n bubbles/scripts/guards/planning-checks.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh` and `/opt/local/bin/gtimeout --signal=TERM --kill-after=10s 300 /opt/homebrew/bin/bash bubbles/scripts/regression-quality-guard.sh --bugfix bubbles/scripts/state-transition-guard-selftest.sh` | Both commands exit zero on the independently verified A epoch. |

### Definition of Done

- [ ] TP-01-01 preserves SCN-032-001 stale-path replacement, SCN-032-002 provider and lifecycle replacement, SCN-032-003 direct mutations, SCN-032-004 opt-out, SCN-032-005 affirmative contracts, SCN-032-013 passive object ownership, SCN-032-014 direct removal after unrelated negation and owned-negation preservation, SCN-032-015 active and passive tails, SCN-032-016 finite limits, SCN-032-020 Check 8B fixtures, SCN-032-021 Check 5A fixtures, SCN-032-022 canonical Stress structure, and SCN-032-028 lexical boundaries.
  > **Uncertainty Declaration**
  > **What was attempted:** Earlier evidence covered the prior matrix.
  > **What was observed:** The final security oracle does not exist.
  > **Why this is uncertain:** Source and test bytes will change during security repair.
  > **What would resolve this:** Run TP-01-06 and retain every prior control.
- [ ] TP-01-02 preserves row 144 as accepted A-RED for its authorized pre-repair byte epoch.
  > **Uncertainty Declaration**
  > **What was attempted:** Tool-log row 144 was read during planning.
  > **What was observed:** It is schema-v3, exited one, and excludes SCN-032-029.
  > **Why this is uncertain:** It predates SCN-032-033 through SCN-032-036.
  > **What would resolve this:** Retain row 144 as prior RED and complete TP-01-04.
- [ ] TP-01-03 replays the unchanged row-145 family and records its exact current result.
  > **Uncertainty Declaration**
  > **What was attempted:** Row 145 was read during planning.
  > **What was observed:** It exited one and remains nonterminal.
  > **Why this is uncertain:** Its exact failure output was not recovered.
  > **What would resolve this:** Run TP-01-03 before any security test edit.
- [ ] TP-01-04 captures persistent RED for SCN-032-033 projection failures and partial disposal, SCN-032-034 exact fences and valid tables with malformed first-error blocking, SCN-032-035 exact G040 separator matching with benign twins, and SCN-032-036 exact byte boundaries with preserved count controls and bounded oversized input.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning defined ten stable security titles.
  > **What was observed:** None exists in the persistent selftest.
  > **Why this is uncertain:** No security RED has executed.
  > **What would resolve this:** Author only those titles and run TP-01-04 against unchanged production.
- [ ] TP-01-05 reaches focused GREEN with the exact unchanged TP-01-04 test identities.
  > **Uncertainty Declaration**
  > **What was attempted:** No security production repair ran.
  > **What was observed:** Current source still exposes all four defects.
  > **Why this is uncertain:** RED must precede repair.
  > **What would resolve this:** Repair production after TP-01-04, then run TP-01-05 unchanged.
- [ ] TP-01-06 passes the unchanged complete A oracle with every prior and security title.
  > **Uncertainty Declaration**
  > **What was attempted:** No complete security-aware GREEN run exists.
  > **What was observed:** Row 145 exited one before these security titles existed.
  > **Why this is uncertain:** Focused success cannot replace the complete oracle.
  > **What would resolve this:** Run TP-01-06 without changing the TP-01-04 test hash.
- [ ] TP-01-07 independently verifies the final A source and unchanged oracle hashes.
  > **Uncertainty Declaration**
  > **What was attempted:** No independent security-aware A run exists.
  > **What was observed:** The final byte pair has not been produced.
  > **Why this is uncertain:** Independence requires a separate test-owner run.
  > **What would resolve this:** Run TP-01-07 after TP-01-06 on recorded hashes.
- [ ] TP-01-08 proves the 100000-byte token stops at byte 4097 within the bounded runtime guard.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning defined the exact oversized-token title and command.
  > **What was observed:** The current helper has no line-byte sentinel.
  > **Why this is uncertain:** No persistent runtime-bound assertion exists.
  > **What would resolve this:** Add the TP-01-08 assertion before repair and pass it after repair.
- [ ] TP-01-09 repeats mechanical and specialist security review against the independently verified final hashes.
  > **Uncertainty Declaration**
  > **What was attempted:** The first security review produced four required findings.
  > **What was observed:** No post-repair security result exists.
  > **Why this is uncertain:** Security must inspect the final source and test bytes.
  > **What would resolve this:** Run the gate and independent security review after TP-01-07.
- [ ] TP-01-10 passes syntax, portability, and regression-quality checks on the final A epoch.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning changed no source or test file.
  > **What was observed:** The final A epoch does not exist.
  > **Why this is uncertain:** These checks must inspect the settled repair.
  > **What would resolve this:** Run both TP-01-10 commands after independent A verification.

---

## Scope 2: Receipt Clone Execution Identity

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** Scope 1

### Goal

Make Check 43 compare complete targets and underlying wrapped programs. Fail
closed when non-empty hash metadata claims zero bytes.

### Gherkin Scenarios

```gherkin
Feature: Receipt identity classification

  Scenario Outline: SCN-032-006 - Complete target sets decide deterministic sibling independence
    Given receipts share one non-empty stdout hash and one normalized validator program
    And every command identity contributes its complete target set
    And complete target sets are <relation>
    When Check 43 evaluates receipt identity
    Then the result is <result>

    Examples:
      | relation | result |
      | disjoint | accept deterministic validator siblings |
      | overlapping | report a receipt clone |

  Scenario Outline: SCN-032-007 - Incompatible underlying programs still block through wrappers
    Given <first program> and <second program> share one substantive stdout hash
    And either program may use a transparent evidence wrapper
    When Check 43 evaluates the underlying program identities
    Then it reports incompatible programs as a receipt clone
    And the same wrapped validator over disjoint targets remains a sibling

    Examples:
      | first program | second program |
      | cargo test | npm run lint |
      | npm run lint | npm run test |

  Scenario: SCN-032-008 - The canonical empty stdout hash remains exempt
    Given multiple receipts carry the canonical empty stdout hash
    When Check 43 evaluates receipt identity
    Then it reports no receipt clone
    And optional zero or absent byte metadata does not change the exemption

  Scenario: SCN-032-025 - Contradictory stdout metadata fails closed
    Given a receipt has a non-empty stdout hash and zero stdout bytes
    When Check 43 evaluates substantive output
    Then it names contradictory metadata and retains the receipt in analysis
    And legitimate empty and positive-byte controls retain their behavior
```

### Implementation Plan

1. Wait for independent A verification to release the shared files.
2. Add the complete-target, wrapper, and contradiction assertions.
3. Capture B-RED with disjoint, same-target, empty, and positive-byte controls.
4. Collect every target for each normalized command identity.
5. Reduce only the closed transparent-wrapper set.
6. Keep zero-byte contradiction rows in fail-closed analysis.
7. Re-run the unchanged B assertions to GREEN.
8. Obtain independent B verification before Scope 4.

### Change Boundary

**Allowed:** Check 43 source, its selftests, adjacent comments, and directly
related receipt-identity documentation under the owning phase.

**Excluded:** Check 8B and Check 5A behavior after A verification, G101 source,
receipt schema changes, certification, downstream copies, and generated output.

### Historical Checked Evidence Retained

- [x] The original SCN-032-006 distinct-target sibling case passed without the folded complete-target overlap. → Evidence: [Current receipt and frozen-input closure](report.md#current-receipt-and-frozen-input-closure)
- [x] The original SCN-032-007 incompatible direct-program controls passed without transparent-wrapper coverage. → Evidence: [Current receipt and frozen-input closure](report.md#current-receipt-and-frozen-input-closure)
- [x] SCN-032-008 canonical empty stdout behavior passed its recorded epoch. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)

### Test Plan

| Test ID | Scenario binding | Type | File | Exact persistent titles | Command | Required result |
| --- | --- | --- | --- | --- | --- | --- |
| TP-02-01 | SCN-032-006 through SCN-032-008 | Regression functional | `bubbles/scripts/state-transition-guard-selftest.sh`; `bubbles/scripts/receipt-identity-selftest.sh` | Existing deterministic-sibling, incompatible-program, same-target, and empty-output titles | `bash bubbles/scripts/receipt-identity-selftest.sh` | Preserve the original Check 43 controls. |
| TP-02-02 | SCN-032-006, SCN-032-007, SCN-032-025 | Tests-first RED | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 compares complete target sets for every command identity`; `BUG-032 Check 43 preserves disjoint-target siblings and same-target refusal controls`; `BUG-032 Check 43 unwraps evidence-capture to compare underlying programs`; `BUG-032 Check 43 preserves same-program wrapped siblings over distinct targets`; `BUG-032 Check 43 fails closed on non-empty hash with zero-byte metadata`; `BUG-032 Check 43 preserves canonical empty and ordinary non-empty controls` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit nonzero before Check 43 repair while all controls execute. |
| TP-02-03 | Same scenarios as TP-02-02 | Regression GREEN | `bubbles/scripts/state-transition-guard-selftest.sh` | The exact unchanged TP-02-02 titles | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit zero after Check 43 repair. |
| TP-02-04 | Same scenarios as TP-02-02 | Independent regression | `bubbles/scripts/state-transition-guard-selftest.sh` | The exact unchanged TP-02-02 titles | `bash bubbles/scripts/state-transition-guard-selftest.sh` | A separate test-owner run verifies current B bytes. |
| TP-02-05 | All Scope 2 scenarios | Syntax and compatibility | `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/state-transition-guard-selftest.sh`; `bubbles/scripts/receipt-identity-selftest.sh` | Existing receipt-schema and shell-syntax assertions | `bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh bubbles/scripts/receipt-identity-selftest.sh` | Exit zero on the B verification epoch. |

### Definition of Done

- [ ] TP-02-01 preserves SCN-032-006 deterministic siblings over disjoint complete target sets, SCN-032-007 incompatible underlying programs through transparent wrappers, and SCN-032-008 canonical empty stdout exemption.
  > **Uncertainty Declaration**
  > **What was attempted:** Historical controls were retained without replay.
  > **What was observed:** Their prior receipts predate folded target and wrapper coverage.
  > **Why this is uncertain:** Shared source may change during A and B.
  > **What would resolve this:** Run the canonical receipt selftest after B-GREEN.
- [ ] TP-02-02 captures B-RED for SCN-032-006 complete target overlap, SCN-032-007 transparent-wrapper identity, and SCN-032-025 contradictory non-empty hash with zero-byte metadata after A releases the shared files.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 98 exercised the three defects diagnostically.
  > **What was observed:** The six planned B titles are not yet persistent.
  > **Why this is uncertain:** Diagnostic probes do not satisfy tests-first RED.
  > **What would resolve this:** Author the six titles and run the selftest before B production edits.
- [ ] TP-02-03 reaches GREEN with unchanged B assertions.
  > **Uncertainty Declaration**
  > **What was attempted:** No B implementation run exists.
  > **What was observed:** Harden row 98 reports all three defects.
  > **Why this is uncertain:** Production repair has not followed B-RED.
  > **What would resolve this:** Repair Check 43 and rerun the same assertions.
- [ ] TP-02-04 independently verifies the B source and oracle pair.
  > **Uncertainty Declaration**
  > **What was attempted:** No independent B run exists.
  > **What was observed:** The final B bytes do not exist.
  > **Why this is uncertain:** Independence requires a later separate run.
  > **What would resolve this:** Run the unchanged selftest under a separate test owner.
- [ ] TP-02-05 proves B syntax and receipt compatibility.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning changed no B source.
  > **What was observed:** No final B epoch exists.
  > **Why this is uncertain:** Syntax and compatibility must match final source bytes.
  > **What would resolve this:** Run TP-02-05 after B-GREEN.

---

## Scope 3: G101 Delivery Authority

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** None

### Goal

Preserve explicit v3 certification as G101 delivery authority. Keep documented
legacy compatibility only when no certification object exists.

### Gherkin Scenarios

```gherkin
Feature: Required release delivery

  Scenario: SCN-032-009 - Planning maturity is not release delivery
    Given a product-to-planning packet is specs_hardened and validate-certified
    When G101 reconciles delivery required
    Then it reports NOT-DELIVERED and exits one

  Scenario: SCN-032-010 - Coherent full delivery remains accepted
    Given a full-delivery packet and explicit certification are done
    And validate is certified
    When G101 reconciles delivery required
    Then it reports DELIVERED and exits zero

  Scenario: SCN-032-011 - Prototype output remains non-deliverable
    Given a required feature is delivered_prototype and validate-certified
    When G101 reconciles delivery required
    Then it reports NOT-DELIVERED and exits one

  Scenario Outline: SCN-032-012 - Terminal aliases follow resolved mode semantics
    Given a required feature has <status> under <mode>
    When G101 reconciles delivery required
    Then the result is <result>

    Examples:
      | status | mode | result |
      | validated | validate-only | NOT-DELIVERED |
      | docs_updated | docs-only | NOT-DELIVERED |
      | delivered_pending_activation | dark-launch-shipped | DELIVERED |
      | delivered_fast | rapid-tool-delivery | DELIVERED |

  Scenario Outline: SCN-032-026 - Explicit v3 certification controls delivery authority
    Given a required full-delivery feature has <state shape>
    When G101 reconciles delivery required
    Then the result is <result>
    And the decision source is <authority>

    Examples:
      | state shape | result | authority |
      | coherent explicit done with validate certified | DELIVERED | explicit v3 certification |
      | top-level done and certification in_progress | NOT-DELIVERED | explicit v3 certification mirror |
      | explicit certification in_progress with legacy validate | NOT-DELIVERED | explicit v3 certification object |
      | no certification object with legacy done and validate | DELIVERED | documented legacy compatibility |
```

### C Evidence Disposition

Rows 125 through 129 independently verify the G101 repair. They use production
hash `92ec63dcf9f79aaeb89ec1f319bdb48dc0a70fec7e58e6680ef5a771a6cd6212`
and selftest hash
`f4e373f8a46f4102944924c4eaa983a0ee6a74ef7624a5977f792fe63c855a0c`.
This evidence is GREEN for C only. It does not close Scope 3 or the bug packet.

### Implementation Plan

1. Preserve the verified C source and selftest bytes.
2. Keep SCN-032-009 through SCN-032-012 controls linked to G101.
3. Keep SCN-032-026 explicit-conflict and legacy controls linked to G101.
4. Re-run focused C only if later tracked edits invalidate its input closure.
5. Include C in the final frozen-byte validation epoch.

### Change Boundary

**Allowed:** G101 source and selftest only when current evidence becomes stale,
adjacent truth-only comments, and this packet under canonical owners.

**Excluded:** A and B source, mode ceilings, certification writes, release
annotations, downstream release packets, and generated output before Scope 4.

### Historical Checked Evidence Retained

- [x] SCN-032-009 through SCN-032-012 passed the earlier G101 mode-decision matrix. → Evidence: [Scope 3 GREEN Evidence](report.md#scope-3-green-evidence)

### Test Plan

| Test ID | Scenario binding | Type | File | Exact persistent titles | Command | Required result |
| --- | --- | --- | --- | --- | --- | --- |
| TP-03-01 | SCN-032-009 through SCN-032-012 | Regression functional | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | S12, S13, S16, S17, S18, S19, and S20 titles linked by the manifest | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Preserve the full mode-decision matrix. |
| TP-03-02 | SCN-032-026 | Tests-first RED and GREEN pair | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `BUG-032 G101 rejects explicit status-mirror divergence`; `BUG-032 G101 gives explicit v3 certification precedence over legacy phases`; `BUG-032 G101 preserves coherent v3 and no-certification legacy controls` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Preserve the tests-first pairing and independently verified C-GREEN. |
| TP-03-03 | All Scope 3 scenarios | Frozen-epoch verification | G101 source and selftest | Current source and selftest identity plus the focused command | Bounded identity check followed by the focused selftest | Preserve the verified hashes or capture replacement proof if either changes. |

### Definition of Done

- [ ] TP-03-01 preserves SCN-032-009 planning non-delivery, SCN-032-010 coherent full delivery, SCN-032-011 prototype non-delivery, and SCN-032-012 mode-owned terminal aliases.
  > **Uncertainty Declaration**
  > **What was attempted:** Historical mode evidence was retained.
  > **What was observed:** Scope 3 planning changed after that evidence.
  > **Why this is uncertain:** Final validation must use the settled packet.
  > **What would resolve this:** Include the mode matrix in the final frozen epoch.
- [ ] TP-03-02 retains independently verified SCN-032-026 behavior: explicit v3 mirror conflicts and legacy-field overrides remain NOT-DELIVERED, while coherent v3 and absent-certification legacy controls remain DELIVERED.
  > **Uncertainty Declaration**
  > **What was attempted:** Rows 125 through 129 independently verified C.
  > **What was observed:** Both named hashes passed the focused C checks.
  > **Why this is uncertain:** Planning and final release evidence have not converged.
  > **What would resolve this:** Preserve the hashes and include C in final validation.
- [ ] TP-03-03 proves C evidence remains current after tracked edits settle.
  > **Uncertainty Declaration**
  > **What was attempted:** Current planning records the verified hash pair.
  > **What was observed:** Other BUG-032 files remain under active repair.
  > **Why this is uncertain:** Final input closure may differ.
  > **What would resolve this:** Recheck the hash pair immediately before final validation.

---

## Verification Stage 4: Verification And Release Closure

**Planning Scope:** 4
**Status:** In Progress
**Scope-Kind:** docs-only
**Depends on:** Scopes 1, 2, and 3

### Goal

Close five named verification obligations without creating behavior scenarios.
Then generate derived output last and validate one frozen byte epoch.

### Verification Obligations

1. **Evidence-anchor fidelity** — `BUG032-HARDEN9-EVIDENCE-ANCHORS-011`.
2. **G068 DoD fidelity** — `BUG032-HARDEN9-G068-DOD-013`.
3. **Release-manifest finality** — `BUG032-HARDEN9-RELEASE-MANIFEST-014`.
4. **Test-comment truth** — `BUG032-HARDEN9-TEST-PROSE-015`.
5. **Report-routing truth** — `BUG032-HARDEN9-REPORT-ROUTE-016`.

### Implementation Plan

1. Verify planning-owned evidence anchors without changing raw evidence.
2. Verify SCN-032-014 DoD fidelity under structural-strict G068.
3. Let the A/B test owner correct the state-transition selftest comments.
4. Let the C test owner correct the release-delivery selftest comments.
5. Verify report and state route only unresolved BUG-032 work.
6. Run release-manifest generation after all tracked inputs settle.
7. Freeze source, selftest, planning, and generated-output identities.
8. Run focused checks, framework validation, and release checks once.
9. Route terminal certification only through `bubbles.validate`.

### Change Boundary

**Allowed:** directly governed comments and documentation, the five verification
surfaces, generated release output through its canonical generator, and final
evidence under canonical owners.

**Excluded:** unrelated improvements, downstream copies, human acceptance,
direct certification writes, deployment, promotion, host state, and model state.

### Test Plan

Scope 4 rows use a verification binding. They do not allocate `SCN-*` IDs.

| Test ID | Binding kind | Binding | Type | File or command surface | Required result |
| --- | --- | --- | --- | --- | --- |
| TP-04-01 | Verification | `BUG032-HARDEN9-EVIDENCE-ANCHORS-011` | Artifact fidelity | BUG-032 packet and Check 9 | Checked references resolve to substantive owner evidence. Raw evidence stays unchanged. |
| TP-04-02 | Verification | `BUG032-HARDEN9-G068-DOD-013` | Traceability | `bubbles/scripts/traceability-guard.sh` | SCN-032-014 maps to faithful direct and owned-negation DoD text. |
| TP-04-03 | Verification | `BUG032-HARDEN9-TEST-PROSE-015` | Test-comment truth A/B | `bubbles/scripts/state-transition-guard-selftest.sh` | The Check 43 comment describes category as diagnostic. |
| TP-04-04 | Verification | `BUG032-HARDEN9-TEST-PROSE-015` | Test-comment truth C | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | The G101 comments name their actual adjacent case groups. |
| TP-04-05 | Verification | `BUG032-HARDEN9-REPORT-ROUTE-016` | Route parity | BUG-032 report and state | Active routing names test-only A correction next, keeps B waiting, and leaves BUG-035 outside. |
| TP-04-06 | Verification | `BUG032-HARDEN9-RELEASE-MANIFEST-014` | Generated-output freshness | `bubbles/scripts/regen-derived.sh`; `bubbles/scripts/generate-release-manifest.sh` | Generation runs last and final freshness exits zero. |
| TP-04-07 | Behavior set | All 26 active scenarios | Planning integrity | Canonical planning checks | All planning checks pass on settled planning bytes. |
| TP-04-08 | Behavior set | All 26 active scenarios | Scenario-test resolution | `bubbles/scripts/scenario-test-resolve.sh` | Only not-yet-authored security and B titles may remain unresolved before their RED runs. Final validation resolves all titles. |
| TP-04-09 | Behavior set | All 26 active scenarios | Focused regression | A/B state-transition and C release-delivery selftests | Every focused suite passes on one frozen epoch. |
| TP-04-10 | Behavior set | All 26 active scenarios | Full release validation | `bubbles/scripts/cli.sh framework-validate`; `bubbles/scripts/cli.sh release-check` | Both captures exit zero on the same epoch. |

### Definition of Done

- [ ] TP-04-01 verifies evidence-anchor fidelity without changing raw evidence.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning references were reconciled.
  > **What was observed:** Current artifact checks still need final-byte execution.
  > **Why this is uncertain:** Later owner edits can change anchors.
  > **What would resolve this:** Re-run Check 9 after report edits settle.
- [ ] TP-04-02 verifies faithful SCN-032-014 DoD text under structural-strict G068.
  > **Uncertainty Declaration**
  > **What was attempted:** The active DoD states both required sides.
  > **What was observed:** No new G068 policy is planned.
  > **Why this is uncertain:** The canonical traceability check must confirm final bytes.
  > **What would resolve this:** Run traceability and G068 checks after planning settles.
- [ ] TP-04-03 verifies the A/B selftest comment against adjacent assertions.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning split comment ownership by file.
  > **What was observed:** The state-transition comment remains test-owned.
  > **Why this is uncertain:** This planning transaction cannot edit tests.
  > **What would resolve this:** The A/B test owner corrects and verifies it.
- [ ] TP-04-04 verifies the C selftest comments against adjacent assertions.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning recorded separate C comment ownership.
  > **What was observed:** C behavior is GREEN, but comment truth remains test-owned.
  > **Why this is uncertain:** This planning transaction cannot edit the C selftest.
  > **What would resolve this:** The C test owner corrects and verifies both comments.
- [ ] TP-04-05 verifies report and state routing truth.
  > **Uncertainty Declaration**
  > **What was attempted:** Active planning routes only the A correction next.
  > **What was observed:** B waits for A and C verification is complete.
  > **Why this is uncertain:** A later route edit could reintroduce stale work.
  > **What would resolve this:** Re-run route parity after planning settles.
- [ ] TP-04-06 generates and verifies the release manifest last.
  > **Uncertainty Declaration**
  > **What was attempted:** No generator ran during planning.
  > **What was observed:** Harden rows 96 and 97 reported stale output.
  > **Why this is uncertain:** Tracked inputs remain unsettled.
  > **What would resolve this:** Run the generator after A, B, comments, docs, and planning settle.
- [ ] TP-04-07 passes every canonical planning-integrity check.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning reconciled all allowed planning surfaces.
  > **What was observed:** Final checks have not yet completed.
  > **Why this is uncertain:** Cross-artifact consistency requires executed guards.
  > **What would resolve this:** Run the bounded validation list from this row.
- [ ] TP-04-08 resolves every required persistent test title before final validation.
  > **Uncertainty Declaration**
  > **What was attempted:** Existing A and C titles were inventoried.
  > **What was observed:** B titles remain absent before B-RED.
  > **Why this is uncertain:** The final test oracle is incomplete.
  > **What would resolve this:** Author B-RED titles and rerun scenario resolution.
- [ ] TP-04-09 passes all focused behavior suites on one frozen epoch.
  > **Uncertainty Declaration**
  > **What was attempted:** No long state-transition selftest ran during planning.
  > **What was observed:** A and B remain open while C is independently GREEN.
  > **Why this is uncertain:** One complete focused epoch does not exist.
  > **What would resolve this:** Run focused suites after A and B verification.
- [ ] TP-04-10 passes framework validation and release checks on the same epoch.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning intentionally avoided long release commands.
  > **What was observed:** Generated output and behavior lanes remain open.
  > **Why this is uncertain:** Release assurance requires settled inputs.
  > **What would resolve this:** Capture both commands after manifest generation.

## Superseded Planning Inventory

<!-- bubbles:g040-skip-begin -->

The prior 32-scenario plan is superseded by the verified analyst specification
and design. Historical execution evidence remains in [report.md](report.md).
No prior raw command block is relabeled as current proof.

~~~~text
SUPPRESSED HISTORICAL APPENDIX. The planning bytes below predate the verified
22-scenario analyst and design reconciliation. They are inert and must not be
executed as the active plan.

# Scopes: BUG-032 Planning-Maturity Guard False Positives

## Execution Outline

### Phase Order

1. **Scope 1 - Semantic consumer and SLA classifiers.** Reopened for the six
  Check 8B/5A behavior defects and the G040 exact-boundary defect. The original
  row-34 closure remains historical evidence for SCN-032-001 through
  SCN-032-016 only.
2. **Scope 2 - Receipt clone execution identity.** Reopened for complete target
  sets, evidence-capture wrapper unwrapping, and contradictory stdout metadata.
  It waits for Scope 1 because both scopes write the state-transition guard and
  its persistent selftest.
3. **Scope 3 - G101 delivery-capable mode semantics.** Reopened for explicit v3
  certification precedence. Its release guard and selftest are disjoint from
  Scope 1, so its RED lane may execute in parallel after this plan settles.
4. **Scope 4 - Contract reconciliation and full validation.** Remains In
  Progress. It owns planning-reference fidelity, report-route truth, test-comment
  truth, ordered generated surfaces, and the final frozen-byte validation gate.

### New Types And Signatures

- `Check 8B input`: one physical scope declaration, normalized without using
  punctuation as a semantic boundary.
- `check8b_classify_line <physical-line>`: one Bash 4+ in-process lexer/parser
  entry point between the existing Check 8B production markers.
- `Check 8B result`: exactly one of `irrelevant`, `negative`,
  `direct-positive`, `mixed-surface`, `ambiguous`, or `error`, plus mutation
  target, ordered direct and preserved surfaces, unresolved phrase, reason,
  boundary, retained-token count, and candidate count.
- `Check 8B bounds`: exactly 128 admitted tokens and eight admitted mutation
  candidates remain classifiable. Token 129 and candidate nine are overflow
  sentinels and never enter semantic relationship analysis.
- `Check 8B execution`: the marked per-line helper uses Bash built-ins only.
  It starts no normalizer process, child shell, pipeline, command substitution,
  or process substitution.
- `Check 43 identity`: normalized program plus dispatch script, target or input
  closure, numeric exit status, and independent execution provenance.
- `Check 43 category`: known non-mixed sanity and diagnostic metadata only; a
  label difference is not receipt identity and is not a clone cause.
- No public command, receipt schema, route, configuration key, or persistent
  data schema is introduced or renamed.

### Validation Checkpoints

- **Scope 1 historical checkpoint:** retain the genuine SCN-032-013
  pre-production RED and the first finite-helper canonical GREEN as diagnostic
  history. The GREEN predates BUG032-CR-01/02/03 and BUG032-ENG-01/02 and cannot
  satisfy final acceptance.
- **After Scope 1 review RED:** persistent assertions for phrase-local
  negation, surface-tail closure, operational token collection, zero per-line
  process fan-out, and the complete discriminator matrix fail against the
  unchanged first candidate while protected twins remain classified.
- **After Scope 1 final GREEN:** marker/sourceability checks, all direct and
  negative twins, 128/129 tokens, eight/nine candidates, helper error,
  mixed-surface all-three checks, structural no-process proof, shadow-command
  zero counts, syntax, and portability pass on the final helper bytes.
- **After Scope 2:** both receipt selftests prove differing labels are accepted
  only for one normalized program with independent targets and provenance;
  incompatible programs and one-target identity collisions still block.
- **After Scope 3 dependency release:** the existing G101 decision-table suite
  remains green; no new G101 implementation is planned by this remediation.
- **Before Scope 4 completion:** artifact, scenario, obligation, mechanism,
  traceability, focused selftest, full framework, and release checks all use
  the same 22-scenario planning epoch and frozen source/test byte set.

### Current Execution Truth

- All four scopes are `In Progress` under the verified specification.
- Scope 1 owns SCN-032-001 through SCN-032-005, SCN-032-013 through
  SCN-032-016, SCN-032-020 through SCN-032-022, and SCN-032-028.
- Scope 2 owns SCN-032-006 through SCN-032-008 and SCN-032-025. Complete
  target-set behavior is folded into SCN-032-006. Wrapper behavior is folded
  into SCN-032-007.
- Scope 3 owns SCN-032-009 through SCN-032-012 and SCN-032-026. Rows 125
  through 129 independently verify C-GREEN on the source and selftest hashes
  fixed by `design.md`. Scope 3 remains nonterminal while planning and evidence
  consolidate.
- Scope 4 owns five verification obligations. It owns no behavior scenario.
- Rows 130 and 141 remain diagnostic history. Their A-RED closures include the
  rejected SCN-032-029 assertion and are inadmissible for tests-first proof.
- The next writer is `bubbles.test`. It must remove the SCN-032-029 oracle,
  fold candidate test bindings into surviving scenarios, and capture clean
  A-RED against unchanged production bytes.

### Implementation Files

- Scope 1 classifier source: `bubbles/scripts/guards/planning-checks.sh` and
  `bubbles/scripts/state-transition-guard.sh`.
- Scope 1 and Scope 2 persistent oracle:
  `bubbles/scripts/state-transition-guard-selftest.sh`.
- Scope 2 canonical receipt-identity oracle:
  `bubbles/scripts/receipt-identity-selftest.sh`.
- Scope 3 delivery-reconciliation source and persistent oracle:
  `bubbles/scripts/release-delivery-reconciliation-guard.sh` and
  `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh`.

Related artifacts: [specification](spec.md), [design](design.md),
[scenario contracts](scenario-manifest.json), [machine test handoff](test-plan.json),
[execution evidence](report.md), and [human acceptance](uservalidation.md).

### Convergence Iteration 9 Finding Map

This reconciliation extends the existing four scopes. It preserves
SCN-032-001 through SCN-032-016 and their evidence history. New semantics use
new identifiers. The independent `BUG035-D14-EMPTY-OUTPUT-COUNT` finding stays
bound to BUG-035 and is not a BUG-032 scenario, test, DoD, or status claim.

| Harden finding | New stable scenario | Existing scope extended | Executable lane |
| --- | --- | --- | --- |
| `BUG032-HARDEN9-C8B-PASSIVE-OBJECT-001` | SCN-032-017 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-C8B-PASSIVE-TAIL-002` | SCN-032-018 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-C8B-PASSIVE-NEGATION-003` | SCN-032-019 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-C8B-CONTEXT-004` | SCN-032-020 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-C5A-CONTEXT-005` | SCN-032-021 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-C5A-COVERAGE-PROXY-006` | SCN-032-022 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-C43-TARGET-OVERLAP-007` | SCN-032-023 | Scope 2 | B - Check 43, after A |
| `BUG032-HARDEN9-C43-WRAPPER-IDENTITY-008` | SCN-032-024 | Scope 2 | B - Check 43, after A |
| `BUG032-HARDEN9-C43-STDOUTBYTES-009` | SCN-032-025 | Scope 2 | B - Check 43, after A |
| `BUG032-HARDEN9-G101-CERTIFICATION-010` | SCN-032-026 | Scope 3 | C - G101 release delivery |
| `BUG032-HARDEN9-EVIDENCE-ANCHORS-011` | SCN-032-027 | Scope 4 | E - planning/report reconciliation |
| `BUG032-HARDEN9-G040-BOUNDARIES-012` | SCN-032-028 | Scope 1 | A - Check 8B/5A/G040 |
| `BUG032-HARDEN9-G068-DOD-013` | SCN-032-029 | Scope 4 | E - planning/report reconciliation |
| `BUG032-HARDEN9-RELEASE-MANIFEST-014` | SCN-032-030 | Scope 4 | F - final generated surfaces |
| `BUG032-HARDEN9-TEST-PROSE-015` | SCN-032-031 | Scope 4 | D - source-adjacent comment truth |
| `BUG032-HARDEN9-REPORT-ROUTE-016` | SCN-032-032 | Scope 4 | E - planning/report reconciliation |

Every executable behavior row starts with a persistent RED assertion against
the unchanged production bytes. Its paired positive or adversarial control runs
in the same RED command. Production remediation is admissible only after that
failure is captured. The later GREEN run must use the same assertion and input
pair; replacing or weakening the RED assertion is not remediation.

### Convergence Iteration 9 Dependency DAG

| Node | Owner | Write surfaces | Depends on | Parallel rule |
| --- | --- | --- | --- | --- |
| E | `bubbles.plan` | BUG-032 planning artifacts and planning-owned report anchors | validated planning transaction | Runs now as the single shared-artifact writer. |
| A-RED | `bubbles.test` | `bubbles/scripts/state-transition-guard-selftest.sh` only | E | May run in parallel with C-RED because their files are disjoint. |
| C-RED | `bubbles.test` | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` only | E | May run in parallel with A-RED because their files are disjoint. |
| A-GREEN | `bubbles.implement` | `bubbles/scripts/guards/planning-checks.sh`, `bubbles/scripts/state-transition-guard.sh`, and the A-RED selftest only when an assertion defect is proven | A-RED | Exclusive writer for the shared state-transition source/selftest family. |
| B-RED | `bubbles.test` | Check 43 rows in `bubbles/scripts/state-transition-guard-selftest.sh` | A-GREEN | Serialized after A because both lanes write the same selftest. |
| B-GREEN | `bubbles.implement` | Check 43 logic in `bubbles/scripts/state-transition-guard.sh` and its persistent selftests | B-RED | Exclusive writer for the shared state-transition source/selftest family. |
| C-GREEN | `bubbles.implement` | `bubbles/scripts/release-delivery-reconciliation-guard.sh` and its selftest | C-RED | May run in parallel with A-GREEN and B because its files are disjoint. |
| D | Writer of the owning A, B, or C lane | Truth-only comments inside a source or test file already owned by that lane | owning lane GREEN | Never a separate concurrent writer of an implementation or test file. |
| F | `bubbles.devops` | canonical release-manifest generated outputs only | A-GREEN, B-GREEN, C-GREEN, D, E | Runs once after every source, test, documentation, and registry input settles. |
| V | `bubbles.validate` | validation evidence and validate-owned state only | F | Runs focused parity checks, then final framework and release gates on one frozen byte epoch. |

The first executable frontier after this planning transaction is A-RED and
C-RED. B cannot write concurrently with A because both own regions of
`state-transition-guard.sh` and `state-transition-guard-selftest.sh`. Comment
truth changes stay with the lane already writing that file. Shared BUG-032
state and report artifacts remain single-writer surfaces.

## Ordered Execution Inventory

| Order | Scope | Depends on | Owner | Outcome | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Semantic consumer and SLA classifiers | None | `bubbles.test`, then `bubbles.implement`, then independent `bubbles.test` | Check 8B and Check 5A classify only active declarations, require canonical Stress coverage, and enforce exact G040 boundaries. | In Progress |
| 2 | Receipt clone execution identity | Scope 1 | `bubbles.test`, then `bubbles.implement`, then independent `bubbles.test` | Check 43 considers complete target sets, unwraps evidence-capture, and fails closed on contradictory byte metadata. | In Progress |
| 3 | G101 delivery-capable mode semantics | None | `bubbles.test`, then `bubbles.implement`, then independent `bubbles.test` | Explicit v3 certification is authoritative while the documented no-certification legacy control remains compatible. | In Progress |
| 4 | Contract reconciliation and full validation | Scopes 1-3 | `bubbles.docs`, `bubbles.validate`, `bubbles.audit` through the delivery workflow | Docs, registry text, generated surfaces, focused selftests, full validation, and release checks agree. | In Progress |

The delivery run must execute scopes in this order. Each implementation scope
starts by adding the persistent regression assertions and capturing their
expected pre-fix failure before changing production code.

---

## Historical Scope 1: Semantic Consumer And SLA Classifiers

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** None
**Execution gate:** Reopened by convergence-9 harden rows 93 and 100 plus the
G040 diagnostic. Row 34 remains historical evidence for its frozen original
assertions and cannot satisfy the new tests.

### Goal

Make Check 8B and Check 5A recognize affirmative contract changes without
penalizing stale-generation, provider/lifecycle replacement, explicit
observability opt-out prose, owned negation, or clarified artifact mutations.
Check 8B must also fail closed on unresolved ownership and finite overflows,
while using no external process in its per-line path.

**Consumer surface:** The state-transition guard CLI command and its ordered
operator diagnostic record.

### Gherkin Scenarios

```gherkin
Feature: Planning prose semantic classification

  Historical Case: SCN-032-001 - A stale generated path is replaced without changing a consumer interface
    Given a scope says a stale generation path is replaced by current generated output
    And the scope does not rename, remove, move, or deprecate a consumer route, path, endpoint, contract, or identifier
    When Check 8B classifies the scope
    Then the scope is not required to add a Consumer Impact Sweep

  Historical Case Outline: SCN-032-002 - Replacement semantics remain outside consumer mutation classification
    Given a scope describes <replacement>
    And no consumer-visible interface identity changes
    When Check 8B classifies the scope
    Then the scope is not required to add a Consumer Impact Sweep

    Examples:
      | replacement |
      | a provider implementation being replaced |
      | a lifecycle state being replaced by its successor |
      | a generated artifact replacing a stale artifact path |

  Historical Case Outline: SCN-032-003 - A real consumer interface mutation requires impact planning
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

  Historical Case: SCN-032-004 - An opted-out observability sentence is not an SLA promise
    Given a scope says observability is opted out and no trace or SLO evidence is injected
    And the scope declares no latency, throughput, response-time, p95, p99, SLA, or SLO target
    And the scope says "No SLA is declared for this contract."
    And the scope says "SLA and SLO are not applicable to this documentation-only change."
    And the scope says "No SLO target is declared."
    And the scope says "The p95 latency target is not applicable."
    When Check 5A classifies the scope
    Then the scope is not required to add stress coverage

  Historical Case Outline: SCN-032-005 - An affirmative performance contract requires stress coverage
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

  Historical Case: SCN-032-013 - An unrelated object mutation is not an interface mutation
    Given a scope says "Remove stale cache entries before invoking the public API route without changing that route."
    And the removal action applies to stale cache entries rather than the public API route
    And the scope preserves the public API route identity
    When Check 8B classifies the scope
    Then the scope is not required to add a Consumer Impact Sweep
    And a scope that directly removes the public API route still requires a Consumer Impact Sweep

  Historical Case Outline: SCN-032-014 - An unrelated negation does not exempt a direct route removal
    Given one physical scope line says <declaration>
    And <negated phrase> does not negate the route-removal relationship
    When Check 8B classifies the line
    Then route remains a direct mutation surface
    And the classification is direct-positive with reason direct
    And Check 8B evaluates the Consumer Impact Sweep section, completion item, and affected-consumer inventory

    Examples:
      | declaration | negated phrase |
      | No cache migration is required; remove the public route. | cache migration requirement |
      | No cache migration is required. The public route is removed. | cache migration requirement |
      | Without migration remove the public route. | migration auxiliary phrase |
      | The public route without migration is removed. | migration auxiliary phrase |

  Historical Case Outline: SCN-032-015 - A trailing artifact noun prevents a guessed surface mutation
    Given a scope says <declaration>
    And <artifact> can be the mutation object instead of the preceding consumer surface
    When Check 8B classifies the declaration
    Then the classification is ambiguous with reason surface-tail
    And the guard blocks with a local rewrite that distinguishes the artifact from the consumer surface
    And the guard skips all three Consumer Impact Sweep checks
    And removing the artifact noun remains direct-positive
    And an explicit separate preservation clause remains negative

    Examples:
      | declaration | artifact |
      | Remove the public API route example. | example |
      | Remove the endpoint test. | test |
      | Remove the contract fixture. | fixture |
      | Remove the link documentation. | documentation |

  Historical Case Outline: SCN-032-016 - Exact finite limits proceed and the first overflow or helper error blocks
    Given Check 8B receives <condition>
    When the classifier and real guard evaluate that condition
    Then the classifier reports <classification> with reason <reason>
    And the guard must <guard behavior>

    Examples:
      | condition | classification | reason | guard behavior |
      | exactly 126 neutral tokens followed by remove route | direct-positive | direct | evaluate all three Consumer Impact Sweep requirements |
      | the same declaration with one extra leading neutral token | ambiguous | token-limit | block before semantic scan and skip all three impact checks |
      | exactly eight valid direct mutation-and-surface candidate pairs | direct-positive | direct | evaluate all three Consumer Impact Sweep requirements |
      | the same candidate sequence with a ninth valid pair | ambiguous | candidate-limit | block before relationship analysis and skip all three impact checks |
      | bounded normalization returns a nonzero helper result | error | normalization-error | block as classifier failure and skip all three impact checks |

  Historical Case: SCN-032-017 - A used passive surface is not the object removed in another clause
    Given a scope says "The public API route is used while stale cache entries are removed."
    When the production Check 8B helper and real guard classify the declaration
    Then the classification is negative with reason preserved-surface
    And the mutation target is stale cache entries while route is preserved
    And all three Consumer Impact Sweep checks are skipped
    And the control "The public API route is removed." remains direct-positive and runs all three checks

  Historical Case Outline: SCN-032-018 - Passive artifact tails require explicit ownership
    Given a scope says <unresolved declaration>
    When the production Check 8B helper and real guard classify the declaration
    Then the unresolved form is ambiguous with reason surface-tail and all three impact checks are skipped
    And <direct control> remains direct-positive and runs all three checks
    And <clarified artifact declaration> is negative with the named consumer surface preserved

    Examples:
      | unresolved declaration | direct control | clarified artifact declaration |
      | The endpoint test is removed. | The endpoint is removed. | The endpoint test is removed. The public endpoint remains unchanged. |
      | The route example is removed. | The public route is removed. | The route example is removed. The public route remains unchanged. |

  Historical Case: SCN-032-019 - Passive will-not negation preserves the consumer surface
    Given a scope says "The public route will not be removed."
    When the production Check 8B helper and real guard classify the declaration
    Then the classification is negative with reason preserved-surface
    And route is preserved and all three Consumer Impact Sweep checks are skipped
    And the control "The public route will be removed." remains direct-positive and runs all three checks

  Historical Case Outline: SCN-032-020 - Fixture prose is not an active interface declaration
    Given <fixture context> contains "Remove the endpoint test."
    When Check 8B scans the complete scope artifact
    Then that fixture text is not classified as an active interface declaration
    And an identical sentence in an active implementation declaration remains ambiguous with reason surface-tail

    Examples:
      | fixture context |
      | a fenced Gherkin scenario |
      | an Examples table cell |
      | a Test Plan description or expected-result cell |

  Historical Case Outline: SCN-032-021 - Quoted performance fixtures are not active contracts
    Given <fixture context> contains "The p95 latency budget is 200 ms."
    When Check 5A scans the complete scope artifact
    Then that fixture text does not establish an affirmative performance contract
    And the identical sentence in an active requirement or implementation declaration remains affirmative

    Examples:
      | fixture context |
      | a fenced Gherkin scenario |
      | an Examples table cell |
      | a Test Plan description or expected-result cell |

  Historical Case: SCN-032-022 - Stress coverage requires a canonical Test Plan row and faithful DoD item
    Given an active scope declaration contains an affirmative p95 latency contract
    And Gherkin, prose, or test descriptions contain the word stress
    But the scope has no canonical Stress Test Plan row and no matching stress DoD item
    When Check 5A validates coverage
    Then coverage fails with the missing canonical row and DoD named
    And a control with an actual Stress Test Plan row plus its faithful DoD item passes coverage

  Historical Case Outline: SCN-032-028 - G040 matches prohibited phrases at exact boundaries only
    Given an active report or scope line contains <text>
    When the G040 incomplete-work language scan evaluates the line outside historical evidence
    Then the result is <result>

    Examples:
      | text | result |
      | A separate preservation clause stays negative. | allowed |
      | These are declared future workflow obligations. | allowed |
      | Move this work to a separate ticket. | blocked |
      | Implement this in a future scope. | blocked |
```

### Implementation Plan

1. Preserve the genuine SCN-032-013 pre-production RED and the first finite
  helper's canonical GREEN as historical evidence. Mark that GREEN superseded
  for final acceptance by BUG032-CR-01/02/03 and BUG032-ENG-01/02.
2. Before production changes, add persistent failing assertions for every
  review finding. Keep the direct and owned-negation twins running in the same
  RED command so a broad exemption cannot masquerade as a fix.
3. Keep exactly one `# BEGIN CHECK8B FINITE CLASSIFIER` marker, one matching end
  marker, and the existing private `check8b_classify_line` entry point. Extract
  and source that exact declaration-only block in the persistent selftest.
4. Replace the first candidate with the bounded four-stage helper from
  `design.md`: admit at most 128 tokens, discover at most eight mutation
  candidates, parse phrase-local relationships, and reduce to the closed
  six-class result record.
5. Bind `no`, `not`, `never`, and `without` only to their owned noun, mutation,
  preservation, or auxiliary phrase. Preserve the four owned-negation negative
  controls while making all four SCN-032-014 declarations direct-positive.
6. Require completed consumer-surface phrases. Return `surface-tail` for each
  unresolved artifact noun, direct-positive when the noun is removed, and
  negative only when a separate clause explicitly preserves the same surface.
7. Detect token 129 before retaining, lowercasing, or inspecting it. Detect
  candidate nine before parsing it. Assert retained array lengths and overflow
  precedence, including the ninth-candidate `surface-tail` adversary.
8. Return a complete `error` record with `normalization-error` for the ASCII
  `0x01` fixture. Keep invalid invocation as a focused `invalid-arguments`
  helper assertion rather than a proxy for the real guard error path.
9. Aggregate ordered direct surfaces only from `direct-positive` and
  `mixed-surface` results. Run the section, completion-item, and
  affected-consumer checks for every direct surface. Never run them for a
  separately preserved surface, ambiguity, overflow, or helper error.
10. Prove the marked per-line block contains only Bash 4+ built-ins and shell
  syntax. Reject external commands, command or process substitution, pipelines,
  and child-shell launches. Run the complete matrix with hostile shadow
  functions and require zero forbidden-command invocations.
11. Preserve Check 5A polarity handling and its quantitative positive twins.
  Keep Check 43 and G101 bytes outside this scope.
12. Run marker/sourceability, focused helper, real guard, static syntax, and
  GNU/BSD portability checks in that order. Freeze production and persistent
  test hashes before accepting the final GREEN epoch.
13. Add the SCN-032-017 through SCN-032-022 and SCN-032-028 persistent
  assertions before changing production source. Capture one failing RED run
  that also executes every paired positive or negative control.
14. Extend passive relationship parsing so a passive mutation owns its actual
  grammatical object. A consumer surface used in another phrase cannot become
  the removed object through a backward scan.
15. Apply surface-tail closure and explicit clarification to passive forms.
  Preserve `will not be removed` as owned negation while keeping `will be
  removed` direct-positive.
16. Give Check 8B and Check 5A a shared context boundary that excludes fenced
  Gherkin, Examples rows, and Test Plan fixture or expected-result cells from
  active declaration classification. Keep identical active implementation or
  requirement declarations enforceable.
17. Replace broad Check 5A coverage word matching with a structural requirement
  for a canonical Stress Test Plan row and its faithful DoD item whenever an
  active affirmative performance contract exists.
18. Make G040 match the complete prohibited phrase at lexical boundaries.
  Preserve both blocked controls and both benign controls from SCN-032-028.
19. Keep the complete Scope 1 source and selftest family under one exclusive
  writer from A-RED through A-GREEN. Scope 2 begins only after that writer
  releases the shared files.

### Test Plan

| Scenario | Test Type | Persistent test file | Persistent test identifier | Exact command | Evidence and required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-001, SCN-032-002, SCN-032-004 | Regression E2E - pre-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics`; `BUG032-IV-F3 Check 5A accepts explicit no-SLA/no-SLO, negated-target, and not-applicable target prose without stress coverage` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Non-zero after the new fixtures are added but before production predicates change; output identifies D1 and D2 assertions. [Scope 1 RED Evidence](report.md#scope-1-red-evidence) |
| SCN-032-001 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for stale-generation replacement semantics. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-002 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores stale-generation, provider, lifecycle, and artifact replacement semantics` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for provider, lifecycle, and generated-artifact replacement semantics. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-003 | Adversarial E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG032-IV-F1 Check 8B triggers on the exact mutation inflections 'renames' and 'removes'`; `BUG-032 Check 8B still flags all 5 explicit route/path/endpoint/contract/identifier mutations` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 while every explicit `renames`/`removes` twin still requires impact planning. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-004 | Regression E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG032-IV-F3 Check 5A accepts explicit no-SLA/no-SLO, negated-target, and not-applicable target prose without stress coverage`; `BUG032-IV-F3 Check 5A does not turn explicit negated or not-applicable target posture into an affirmative contract` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for explicit no-SLO, negated-target, and not-applicable target prose. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-005 | Adversarial E2E - post-fix | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 5A still treats 'no more than 200 ms p95 latency' as an affirmative performance contract`; `Check 5A still flags all 5 genuine SLA declarations (p95 latency, throughput, SLA, SLO, p99 response time)` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 while genuine quantitative targets still require stress coverage. [Scope 1 GREEN Evidence](report.md#scope-1-green-evidence) |
| SCN-032-013 | Functional regression - pre-fix RED | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B classifies unpunctuated cache removal plus preserved public route as negative` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | After adding the assertion and before changing production, exit non-zero because `Remove stale cache entries before invoking the public API route without changing that route` is misclassified; output must also show the direct-removal control remains positive. [SCN-032-013 RED evidence target](report.md#scope-1-scn-032-013-red-evidence) |
| SCN-032-013 | Functional regression - post-fix negative | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B classifies punctuated and unpunctuated cache removal plus preserved public route as negative` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0; both sentence forms report `classification=negative`, `mutationTarget=stale cache entries`, and `preservedSurfaces=route`, with no Consumer Impact Sweep requirement. [SCN-032-013 GREEN evidence target](report.md#scope-1-scn-032-013-green-evidence) |
| SCN-032-013 | Adversarial functional - direct positive | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B keeps active and passive public-route removal direct-positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0; `Remove the public API route` and `The public API route is removed` each report `classification=direct-positive` and `remove:route`, then invoke all three impact-planning checks. [SCN-032-013 GREEN evidence target](report.md#scope-1-scn-032-013-green-evidence) |
| SCN-032-013 | Adversarial functional - mixed surface | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B classifies preserved route plus removed redirect as mixed-surface` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0; `Preserve the public API route while removing the legacy redirect` reports direct `remove:redirect`, preserved `route`, and evaluates impact planning only for the redirect. [SCN-032-013 GREEN evidence target](report.md#scope-1-scn-032-013-green-evidence) |
| SCN-032-013 | Adversarial functional - ambiguity and bound | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B blocks same-surface mutation and preservation as ambiguous`; `BUG-032 Check 8B blocks unresolved nearby route mention as ambiguous`; `BUG-032 Check 8B blocks relevant declarations above 128 tokens as ambiguous` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when the outer selftest proves each inner guard fixture exits non-zero with `classification=ambiguous` and reason `conflict`, `unresolved`, or `token-limit`, plus local rewrite guidance. [SCN-032-013 GREEN evidence target](report.md#scope-1-scn-032-013-green-evidence) |
| SCN-032-013 | Production-helper extraction contract | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B finite classifier extracted from production markers (no test/source drift)` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when the test extracts and sources the marked helper from `bubbles/scripts/guards/planning-checks.sh`; a missing marker or copied test-only grammar fails. [SCN-032-013 GREEN evidence target](report.md#scope-1-scn-032-013-green-evidence) |
| SCN-032-014 | Tests-first review RED - BUG032-CR-01 | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B keeps direct mutations positive after unrelated no or without phrases`; `BUG-032 Check 8B keeps owned negation negative` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production remediation, exit non-zero because one or more unrelated-negation declarations are suppressed. The same run must prove the four owned-negation controls remain negative. [Five-finding RED evidence target](report.md#scope-1-five-finding-red-evidence) |
| SCN-032-015 | Tests-first review RED - BUG032-CR-02 | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B blocks trailing artifact nouns as surface-tail`; `BUG-032 Check 8B discriminates direct and explicitly preserved trailing-noun twins` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production remediation, exit non-zero because the first candidate accepts an unclosed surface head. Direct and explicit-preservation twins must remain independently asserted. [Five-finding RED evidence target](report.md#scope-1-five-finding-red-evidence) |
| SCN-032-016 | Tests-first review RED - BUG032-CR-03 | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B admits exactly 128 tokens and rejects token 129 before semantic scan` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production remediation, exit non-zero because the first candidate normalizes and materializes the complete line before detecting overflow. The RED assertion must inspect retained token count and absence of token 129. [Five-finding RED evidence target](report.md#scope-1-five-finding-red-evidence) |
| SCN-032-016 | Tests-first review RED - BUG032-ENG-01 | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B exact marked source has no statically admitted process-capable syntax or executable command head`; `BUG-032 Check 8B hostile shadow command counts remain zero` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production remediation, exit non-zero because structural scanning finds the per-line process mechanisms or hostile shadow counters observe a forbidden invocation. Marker extraction is reported separately. [Five-finding RED evidence target](report.md#scope-1-five-finding-red-evidence) |
| SCN-032-014, SCN-032-015, SCN-032-016 | Tests-first review RED - BUG032-ENG-02 | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned complete discriminator matrix identifiers in the five preceding rows plus the exact-limit, helper-error, and mixed-surface identifiers below | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production remediation, exit non-zero with every newly added discriminator executed. No review finding may be inferred from the earlier baseline GREEN. [Five-finding RED evidence target](report.md#scope-1-five-finding-red-evidence) |
| SCN-032-014 | Functional regression - phrase-local negation twins | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B keeps direct mutations positive after unrelated no or without phrases`; `BUG-032 Check 8B keeps owned negation negative` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when all four unrelated-negation active/passive declarations are `direct-positive/direct` and each guard fixture reports the section, completion-item, and inventory requirements, while all four owned-negation controls are negative and report none. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-015 | Functional regression - surface-tail and direct/preserved twins | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B blocks trailing artifact nouns as surface-tail`; `BUG-032 Check 8B discriminates direct and explicitly preserved trailing-noun twins` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when route example, endpoint test, contract fixture, and link documentation block as `ambiguous/surface-tail` with all three checks skipped; removing each tail is direct-positive, and a separate unchanged clause makes the artifact mutation negative. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-016 | Boundary regression - exact 128/129 tokens | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B admits exactly 128 tokens and rejects token 129 before semantic scan` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when 128 tokens classify ordinarily with retained length 128 and all three direct checks, while token 129 yields `ambiguous/token-limit`, remains absent from retained arrays, and runs no impact check. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-016 | Boundary regression - exact eight/nine candidates | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B admits exactly eight candidates and rejects candidate nine before relationship analysis` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when eight pairs remain direct with candidate length eight and all three checks, while candidate nine yields `ambiguous/candidate-limit`; the ninth `remove route example` adversary must still report candidate-limit rather than surface-tail. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-016 | Guard regression - candidate overflow and helper error | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B guard fails closed on candidate-limit and normalization-error`; `BUG-032 Check 8B invalid invocation returns a complete invalid-arguments error record` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when candidate overflow and ASCII `0x01` normalization error make the real guard nonzero with reason-specific local correction and all three impact fields skipped; invalid invocation is asserted directly at helper level. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Production-marker and sourceability contract | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B finite classifier has one atomic marker block whose pre-source declaration-only detector admits only complete supported function declarations and inert marker-bounded comments`; existing production-marker extraction assertion | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when exactly one marker pair is extracted, sourcing preserves shell options, traps, `IFS`, working directory, and positional arguments, emits no output, and exposes the production entry point without copied grammar or legacy-regex fallback. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-016 | Structural regression - no per-line process fan-out | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B exact marked source has no statically admitted process-capable syntax or executable command head`; `BUG-032 Check 8B hostile shadow command counts remain zero` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when the exact marked block has no forbidden command, command/process substitution, pipeline, or child-shell launch, and the complete matrix passes with each shadowed `tr`, `sed`, `awk`, `grep`, `perl`, and `python` count equal to zero. The one bounded marker extraction process is reported separately. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Mixed-surface all-three requirements | `bubbles/scripts/state-transition-guard-selftest.sh` | Planned: `BUG-032 Check 8B mixed surfaces run all three requirements for every direct surface only` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when one-direct and two-direct mixed fixtures preserve declaration order, report `route` only as preserved, and emit each missing section, completion-item, and inventory requirement once for the complete direct set. [Final classifier evidence target](report.md#scope-1-final-five-finding-green-evidence) |
| SCN-032-017 | Tests-first RED - passive unrelated object | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B keeps a used passive surface separate from an unrelated passive object`; `BUG-032 Check 8B passive direct-route control remains direct-positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because the passive cache-removal fixture is falsely direct for route. The direct passive route-removal control must execute and pass in the same run. Harden row 93 is diagnostic input, not this persistent RED receipt. |
| SCN-032-017 | Regression GREEN - passive unrelated object twin | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B keeps a used passive surface separate from an unrelated passive object`; `BUG-032 Check 8B passive direct-route control remains direct-positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when the cache target is negative with route preserved and all three checks skipped, while direct passive route removal remains positive and runs all three checks. |
| SCN-032-018 | Tests-first RED - passive tail and clarification | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B blocks passive artifact tails and accepts explicit passive clarification`; `BUG-032 Check 8B passive tail direct controls remain positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero for the passive tail or clarified artifact fixture while every direct control remains independently asserted. Harden row 93 is diagnostic input, not this persistent RED receipt. |
| SCN-032-018 | Regression GREEN - passive tail triples | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B blocks passive artifact tails and accepts explicit passive clarification`; `BUG-032 Check 8B passive tail direct controls remain positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when unresolved passive tails block as `surface-tail`, direct controls stay positive, and explicit artifact clarification is negative with the consumer surface preserved. |
| SCN-032-019 | Tests-first RED - passive will-not negation | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B preserves passive will-not negation`; `BUG-032 Check 8B passive will-be control remains direct-positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because `will not be removed` is falsely positive. The `will be removed` control must execute and pass in the same run. Harden row 93 is diagnostic input, not this persistent RED receipt. |
| SCN-032-019 | Regression GREEN - passive negation twin | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B preserves passive will-not negation`; `BUG-032 Check 8B passive will-be control remains direct-positive` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when `will not` preserves route and skips all three checks while `will be` remains direct and runs all three checks. |
| SCN-032-020 | Tests-first RED - Check 8B context boundary | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores Gherkin Examples and Test Plan fixture prose`; `BUG-032 Check 8B still evaluates identical active declarations` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because at least one fixture-context phrase is classified. The identical active declaration must still block or trigger as appropriate in the same run. |
| SCN-032-020 | Regression GREEN - Check 8B context twins | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 8B ignores Gherkin Examples and Test Plan fixture prose`; `BUG-032 Check 8B still evaluates identical active declarations` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when all three fixture contexts are ignored and the identical active declaration remains enforceable. |
| SCN-032-021 | Tests-first RED - Check 5A context boundary | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 5A ignores quoted Gherkin Examples and Test Plan performance fixtures`; `BUG-032 Check 5A still evaluates identical active performance contracts` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because a quoted 200 ms fixture is treated as active. The identical active p95 contract must remain positive in the same run. Harden row 100 is diagnostic input, not this persistent RED receipt. |
| SCN-032-021 | Regression GREEN - Check 5A context twins | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 5A ignores quoted Gherkin Examples and Test Plan performance fixtures`; `BUG-032 Check 5A still evaluates identical active performance contracts` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when all fixture contexts are ignored and the active p95 contract still requires canonical stress coverage. |
| SCN-032-022 | Tests-first RED - canonical Stress coverage | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 5A rejects stress-word coverage without a canonical Stress Test Plan row and DoD`; `BUG-032 Check 5A accepts a canonical Stress row with faithful DoD` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because broad prose containing `stress` falsely satisfies coverage. The structurally complete control must execute in the same run. Harden row 100 is diagnostic input, not this persistent RED receipt. |
| SCN-032-022 | Regression GREEN - canonical Stress coverage twin | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 5A rejects stress-word coverage without a canonical Stress Test Plan row and DoD`; `BUG-032 Check 5A accepts a canonical Stress row with faithful DoD` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when broad prose fails coverage and the canonical Stress Test Plan row plus faithful DoD control passes. |
| SCN-032-028 | Tests-first RED - G040 exact boundaries | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 G040 permits benign separate-clause and future-workflow wording`; `BUG-032 G040 still blocks exact separate-ticket and future-scope phrases` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because one or both benign prefixes are blocked. Both exact prohibited-phrase controls must remain blocked in the same run. |
| SCN-032-028 | Regression GREEN - G040 boundary twins | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 G040 permits benign separate-clause and future-workflow wording`; `BUG-032 G040 still blocks exact separate-ticket and future-scope phrases` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when both benign lines pass and both exact prohibited phrases block outside historical evidence. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Static shell syntax | `bubbles/scripts/guards/planning-checks.sh`; `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/state-transition-guard-selftest.sh` | Shell syntax for the changed planning classifiers and persistent selftest | `bash -n bubbles/scripts/guards/planning-checks.sh bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 on the final byte epoch. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Framework portability | `bubbles/scripts/state-transition-guard-selftest.sh` through the framework selftest suite | All Scope 1 SCN-specific identifier groups above | `bash bubbles/scripts/cli.sh framework-validate` | Exit 0 on the same final byte epoch; Bash 4+ sourceability, macOS/BSD, and Linux/GNU compatibility cases remain green. |

### Consumer Impact Sweep

This scope changes classifier behavior, not a public route, path, endpoint, or
redirect. SCN-032-013 proves that cache mutation does not become route mutation
through nearby wording. SCN-032-014 proves that unrelated negation cannot hide
a direct mutation. SCN-032-015 blocks unresolved artifact ownership rather than
guessing. SCN-032-016 preserves exact-limit inputs and fails closed at the first
overflow or helper error. The consumer surfaces are downstream scope authors,
the planning-check caller, the state-transition guard terminal contract, and
persistent selftests. No framework command, route, identifier, prompt, or file
location is renamed or removed.

### Affected Consumer Surfaces

The affected consumers are downstream scope-author planning text,
`planning-checks.sh` aggregation, guard diagnostics, persistent selftest
assertions, and stale-reference checks. The terminal UX must expose irrelevant,
negative, direct, mixed, ambiguous, and error outcomes in the `spec.md` reading
order. It must expose stable `surface-tail`, `token-limit`, `candidate-limit`,
and `normalization-error` corrections. Navigation, breadcrumbs, API clients,
generated clients, and deep links do not consume these classifier internals;
their names remain positive surface vocabulary and adversarial test data.

### Change Boundary

**Allowed file families:** `bubbles/scripts/guards/planning-checks.sh`, the Check
5A integration in `bubbles/scripts/state-transition-guard.sh`,
`bubbles/scripts/state-transition-guard-selftest.sh`, source comments directly
governing those checks, and this bug's planning/evidence artifacts under their
respective owners.

**Excluded surfaces:** Check 43 receipt identity, G101 delivery semantics,
`BUGS.md` registry reconciliation, user acceptance, certification fields,
downstream planning artifacts and installed copies, unrelated classifiers,
workflow mode semantics, release/deploy/host/runtime/model selection, and any
generated surface before its canonical generation step in Scope 4.

### Definition of Done

Checked items below preserve the earlier D1/D2 evidence and bind the later
five-finding obligations to the independent row-34 adjudication on the exact
current production and persistent-oracle hashes.

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
- [x] SCN-032-013 has a genuine pre-fix RED receipt for the unpunctuated cache-removal sentence while direct public-route removal remains positive. → Evidence: [Implementation RED capture](report.md#implementation-red-capture---2026-08-31)
- [x] SCN-032-013 punctuated and unpunctuated cache-removal declarations classify `negative` with the other target and preserved route named. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-013 direct active and passive public-route removals classify `direct-positive` and retain all impact-planning checks. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-013 preserved route plus removed redirect classifies `mixed-surface` and evaluates only the redirect mutation. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-013 same-surface contradiction, unresolved nearby route mention, and the 128-token cap each block as `ambiguous` with specific rewrite guidance. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-013 tests extract the finite Check 8B helper from stable production markers and fail when markers or production grammar drift. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-014 and BUG032-CR-01 have tests-first RED proof, then final GREEN proof that all four unrelated `no`/`without` declarations stay direct-positive and invoke all three planning checks while all four owned-negation controls remain negative. → Evidence: [Accepted five-finding RED receipt](report.md#accepted-five-finding-red-receipt), [current implementation GREEN receipt](report.md#current-implementation-green-receipt), and [independent row-34 verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-015 and BUG032-CR-02 have tests-first RED proof, then final GREEN proof for all four `surface-tail` adversaries, all direct twins, and all explicit-preservation twins, with guessed impact checks skipped. → Evidence: [Accepted five-finding RED receipt](report.md#accepted-five-finding-red-receipt), [current implementation GREEN receipt](report.md#current-implementation-green-receipt), and [independent row-34 verification](report.md#receipt-and-frozen-input-verification)
- [x] BUG032-CR-03 has tests-first RED proof, then final GREEN proof that exactly 128 tokens are admitted and token 129 triggers before retention, normalization, or semantic scan. → Evidence: [Accepted five-finding RED receipt](report.md#accepted-five-finding-red-receipt), [current implementation GREEN receipt](report.md#current-implementation-green-receipt), and [independent row-34 verification](report.md#receipt-and-frozen-input-verification)
- [x] BUG032-ENG-01 has tests-first RED proof, then final structural and hostile-shadow GREEN proof that the marked per-line helper starts zero forbidden normalizer processes. → Evidence: [Accepted five-finding RED receipt](report.md#accepted-five-finding-red-receipt), [current implementation GREEN receipt](report.md#current-implementation-green-receipt), and [independent row-34 verification](report.md#receipt-and-frozen-input-verification)
- [x] BUG032-ENG-02 has tests-first RED proof, then final GREEN proof for exact eight/nine candidates, guard-level candidate-limit and normalization-error, mixed-surface all-three checks, marker/sourceability, and every direct/negative discriminator. → Evidence: [Accepted five-finding RED receipt](report.md#accepted-five-finding-red-receipt), [current implementation GREEN receipt](report.md#current-implementation-green-receipt), and [independent row-34 verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-016 exact eight-candidate input remains direct-positive, candidate nine and its trailing-tail adversary return candidate-limit before parsing, and the real guard skips all three impact checks for overflow. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-016 ASCII `0x01` normalization failure returns a complete `error/normalization-error` record, makes the real guard nonzero, names a local correction, and leaves all three impact fields skipped; invalid arguments have their separate helper-level assertion. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification)
- [x] SCN-032-013 through SCN-032-016 source exactly one declaration-only marker block, preserve caller shell state, remove the legacy-regex fallback, and pass static Bash syntax plus GNU/BSD portability checks on the same final byte epoch. → Evidence: [Independent row-34 receipt and frozen-input verification](report.md#receipt-and-frozen-input-verification) and [regression row-34 closure](report.md#row-34-and-frozen-input-closure)
- [ ] SCN-032-017 has a persistent tests-first RED assertion that exposes passive unrelated-object ownership while the direct passive route control remains positive.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 93 executed an ad hoc six-case adversary.
  > **What was observed:** The passive unrelated-object case failed and the direct passive control passed; no persistent assertion exists in the selftest.
  > **Why this is uncertain:** Diagnostic execution does not prove a durable regression test reaches the global failure gate.
  > **What would resolve this:** Add both exact identifiers from the Test Plan and capture the expected nonzero selftest before production changes.
- [ ] SCN-032-017 classifies the cache entry removal as negative with route preserved and all three impact checks skipped, while direct passive route removal remains positive and runs all three checks.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-017.
  > **What was observed:** Current production fails the negative case in harden row 93.
  > **Why this is uncertain:** The implementation and independent GREEN proof do not exist.
  > **What would resolve this:** Repair passive object ownership and run the unchanged persistent twin assertions to exit 0.
- [ ] SCN-032-018 has a persistent tests-first RED assertion for passive surface tails and explicit artifact clarification, with direct passive controls in the same run.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 93 executed passive tail, clarified artifact, and direct controls outside the persistent suite.
  > **What was observed:** The unresolved and clarified forms failed their expected classifications.
  > **Why this is uncertain:** The selftest has no durable SCN-032-018 identifiers.
  > **What would resolve this:** Add the planned identifiers and capture their expected nonzero pre-repair selftest result.
- [ ] SCN-032-018 blocks unresolved passive tails as `surface-tail`, accepts explicit clarification as a negative artifact mutation, and preserves direct-positive passive controls.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-018.
  > **What was observed:** Current production returns direct-positive or conflict for the harden cases.
  > **Why this is uncertain:** No implementation or independent verification closes the three-way discriminator.
  > **What would resolve this:** Repair passive phrase closure and run the unchanged tail, clarification, and direct assertions to exit 0.
- [ ] SCN-032-019 has a persistent tests-first RED assertion that exposes lost `will not` negation while `will be removed` stays direct-positive.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 93 executed the negative declaration and its direct control.
  > **What was observed:** The negative declaration was falsely direct-positive.
  > **Why this is uncertain:** No persistent selftest assertion records the failure.
  > **What would resolve this:** Add both planned identifiers and capture the expected nonzero selftest before production changes.
- [ ] SCN-032-019 preserves route under passive `will not` negation and skips all three checks while its `will be` control remains direct-positive.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-019.
  > **What was observed:** Current production loses the negation in harden row 93.
  > **Why this is uncertain:** The production predicate and independent GREEN evidence are absent.
  > **What would resolve this:** Repair auxiliary-bound negation and run the unchanged persistent twins to exit 0.
- [ ] SCN-032-020 has a persistent tests-first RED assertion that exposes Check 8B classification inside Gherkin, Examples, and Test Plan fixture contexts while the identical active declaration remains enforceable.
  > **Uncertainty Declaration**
  > **What was attempted:** The registry-bound transition diagnostic scanned the current packet.
  > **What was observed:** It emitted twelve ambiguity blocks over fixture and Test Plan prose.
  > **Why this is uncertain:** No isolated persistent context matrix exists.
  > **What would resolve this:** Add the planned context and active-declaration identifiers and capture their expected nonzero pre-repair result.
- [ ] SCN-032-020 ignores all three fixture contexts without weakening classification of the identical active implementation declaration.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-020.
  > **What was observed:** Current production does not separate fixture context from active declarations.
  > **Why this is uncertain:** Context-boundary implementation and independent GREEN evidence are absent.
  > **What would resolve this:** Implement the shared context boundary and run the unchanged negative and active controls to exit 0.
- [ ] SCN-032-021 has a persistent tests-first RED assertion that exposes quoted performance fixtures while the identical active p95 contract remains affirmative.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 100 executed a quoted fixture and active-packet probe.
  > **What was observed:** The quoted fixture was falsely positive.
  > **Why this is uncertain:** The durable selftest does not carry the planned context identifiers.
  > **What would resolve this:** Add both planned identifiers and capture the expected nonzero selftest before production changes.
- [ ] SCN-032-021 ignores quoted Gherkin, Examples, and Test Plan performance fixtures while retaining active p95 contract enforcement.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-021.
  > **What was observed:** Current production treats fixture prose as an active contract.
  > **Why this is uncertain:** The Check 5A context fix and independent GREEN evidence are absent.
  > **What would resolve this:** Implement the context boundary and run the unchanged fixture and active-contract controls to exit 0.
- [ ] SCN-032-022 has a persistent tests-first RED assertion proving that a broad `stress` word can falsely satisfy Check 5A while a canonical Stress row plus faithful DoD remains the positive control.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 100 inspected the current packet and a coverage proxy fixture.
  > **What was observed:** Coverage passed without a canonical Stress Test Plan row.
  > **Why this is uncertain:** The persistent selftest does not yet encode the structural negative and positive pair.
  > **What would resolve this:** Add both planned identifiers and capture the expected nonzero selftest before production changes.
- [ ] SCN-032-022 rejects prose-only stress coverage and accepts only the canonical Stress Test Plan row with its faithful DoD item.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-022.
  > **What was observed:** The current broad word predicate passes the invalid fixture.
  > **Why this is uncertain:** Structural coverage enforcement and independent GREEN evidence are absent.
  > **What would resolve this:** Replace the proxy with canonical row and DoD parsing, then run the unchanged paired assertions to exit 0.
- [ ] SCN-032-028 has a persistent tests-first RED assertion for both benign prefixes and both exact prohibited-phrase controls.
  > **Uncertainty Declaration**
  > **What was attempted:** The registry-bound transition diagnostic scanned the current report window.
  > **What was observed:** G040 blocked both benign SCN-032-028 controls as substring hits.
  > **Why this is uncertain:** No persistent exact-boundary matrix exists.
  > **What would resolve this:** Add both planned identifiers and capture the expected nonzero selftest with all four controls executed.
- [ ] SCN-032-028 permits both benign lines and blocks both exact prohibited phrases outside historical evidence.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-028.
  > **What was observed:** Current G040 matching is broader than the declared phrase boundaries.
  > **Why this is uncertain:** Boundary-safe enforcement and independent GREEN evidence are absent.
  > **What would resolve this:** Implement complete-phrase lexical boundaries and run the unchanged four-case matrix to exit 0.

---

## Historical Scope 2: Receipt Clone Execution Identity

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** Scope 1
**Execution gate:** Blocked on Scope 1 because both scopes write
`state-transition-guard.sh` and `state-transition-guard-selftest.sh`. Harden row
98 supplies diagnostic RED input, not a persistent tests-first receipt.

### Scope 2 Goal

Distinguish independent deterministic validator executions from substantive
receipt reuse across incompatible commands, while preserving the existing
empty-stdout contract.

**Consumer surface:** The state-transition guard CLI command and its Check 43
receipt-identity diagnostic.

<!-- markdownlint-disable-next-line MD024 -->
### Gherkin Scenarios

```gherkin
Feature: Receipt clone identity

  Historical Case: SCN-032-006 - One validator runs independently over two spec targets
    Given two validator receipts have the same normalized program identity
    And each receipt targets a distinct subject or input closure
    And each receipt has independent execution provenance and the same numeric exit status
    And each receipt has a known non-mixed evidence category with a different label
    And both executions emit the same non-empty stdout hash
    When Check 43 evaluates the receipts
    Then it does not report a receipt clone
    And it accepts the receipts as deterministic validator siblings

  Historical Case Outline: SCN-032-007 - One substantive output hash appears under incompatible normalized program identities
    Given receipts for <first program> and <second program> share one non-empty stdout hash
    And their normalized program identities are incompatible
    And each receipt has a known non-mixed evidence category
    When Check 43 evaluates receipt identity
    Then it reports a receipt clone
    And the finding names the incompatible normalized program identities
    And category labels appear only as diagnostic context, not receipt identity

    Examples:
      | first program | second program |
      | cargo test | npm run lint |
      | npm run lint | npm run test |

  Historical Case: SCN-032-008 - Different commands emit no stdout
    Given multiple receipts carry the SHA-256 digest of empty stdout
    When Check 43 evaluates receipt identity
    Then it does not report a receipt clone
    And the exemption does not depend on the optional stdoutBytes field

  Historical Case: SCN-032-023 - Every target of every normalized command identity participates in overlap detection
    Given one normalized validator program has multiple command identities and each identity has a complete target set
    And a target from a non-first receipt overlaps another command identity in the same substantive hash group
    When Check 43 evaluates receipt identity
    Then it reports a receipt clone instead of a deterministic sibling
    And a control whose complete target sets are disjoint remains an accepted deterministic sibling
    And the existing same-target control remains blocking

  Historical Case: SCN-032-024 - Evidence-capture wrappers preserve the underlying program identity
    Given two receipts share one substantive stdout hash and both invoke evidence-capture
    And one wrapped command runs cargo test while the other runs npm lint
    When Check 43 normalizes program identity
    Then it reports the incompatible underlying programs as a receipt clone
    And a control that wraps the same underlying validator over distinct targets remains an accepted deterministic sibling

  Historical Case: SCN-032-025 - Contradictory non-empty hash and zero-byte metadata fails closed
    Given a receipt carries a non-empty stdout hash and stdoutBytes is zero
    When Check 43 evaluates substantive output
    Then it reports contradictory metadata and keeps the receipt in fail-closed clone analysis
    And the canonical empty hash with zero or absent byte metadata remains exempt
    And a non-empty hash with positive byte metadata follows ordinary identity analysis
```

### Scope 2 Implementation Plan

1. Preserve the existing Check 43 deterministic-sibling fixture and add the
  dedicated receipt-identity canonical fixture as the differing-label proof.
  The rows must share one normalized validator program while targets or input
  closures and execution provenance remain distinct.
2. Derive command identity, normalized program identity including `run` or
  `exec` dispatch script, target identity, numeric exit status, and execution
  provenance from current receipt fields.
3. Keep evidence category as known non-mixed sanity metadata and diagnostic
  context. Category labels may agree or differ; a difference alone never
  creates a clone finding.
4. Preserve the cargo-test versus npm-lint, npm-run-lint versus npm-run-test,
  same-target multi-identity, cross-spec reuse, provenance-poor, empty-stdout,
  and equivalent-wrapper adversarial bounds.
5. Do not exempt ambiguous rows that cannot prove independent target and
  execution identity.
6. Keep diagnostics explicit about normalized program, category, target, exit,
  and provenance so the blocking cause cannot be confused with category.
7. Execute both receipt-identity and state-transition selftests after Scope 1
  returns to Done.
8. After Scope 1 releases the shared files, add SCN-032-023 through
  SCN-032-025 to the persistent selftest before changing Check 43 production
  logic. Capture one RED run with the distinct-target, same-target, same-wrapper,
  empty-hash, and ordinary non-empty controls in the same execution.
9. Derive the complete target set for every normalized command identity. Reject
  any cross-identity overlap; never project one representative receipt.
10. Unwrap evidence-capture as a transparent evidence wrapper and derive
  program identity from its wrapped argv. Keep the wrapper in provenance
  diagnostics without letting it collapse incompatible underlying programs.
11. Treat a non-empty hash paired with zero-byte metadata as contradictory and
  fail closed. Preserve the canonical empty digest exemption with zero or
  absent byte metadata and ordinary analysis for positive byte counts.
12. Run the unchanged RED assertions to GREEN, then execute the canonical
  receipt-identity controls and an independent test-owner verification before
  Scope 2 may close.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| Scenario | Test Type | Persistent test file | Persistent test identifier | Exact command | Evidence and required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-006 | Functional regression - historical RED | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 accepts independent deterministic validator siblings over distinct targets` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Historical non-zero proof remains at [Scope 2 RED Evidence](report.md#scope-2-red-evidence); it covers the original deterministic-sibling false positive without being relabeled as differing-category proof. |
| SCN-032-006 | Functional regression - normalized program and target | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 accepts independent deterministic validator siblings over distinct targets`; `BUG-032 Check 43 preserves BUG-019 equivalent command-spelling normalization` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 for one normalized validator program over independent targets/provenance and for equivalent wrapper spelling. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-006 | Functional regression - differing category labels | `bubbles/scripts/receipt-identity-selftest.sh` | `BUG-028 canonical: one validator over three subjects with differing tags is not reported as cloned evidence`; `BUG-028 canonical: the three-subject group is accepted through the deterministic-sibling path`; `BUG-028 defect 1: one command tagged test and validate is not reported as cloned evidence` | `bash bubbles/scripts/receipt-identity-selftest.sh` | Exit 0; differing known non-mixed labels do not create a clone when normalized program, independent targets, equal numeric exit, and independent provenance satisfy sibling identity. [D3 reconciliation evidence target](report.md#scope-2-normalized-program-category-evidence) |
| SCN-032-007 | Adversarial functional - incompatible normalized programs | `bubbles/scripts/receipt-identity-selftest.sh` | `BUG-032 pin: incompatible command families sharing one stdout are still refused`; `BUG-028 defect 1 bound: two identities sharing ONE target and one stdout are still refused`; `BUG-028 bound: a group mixing two specs on one stdout is still refused` | `bash bubbles/scripts/receipt-identity-selftest.sh` | Exit 0 only when cargo versus npm, npm lint versus npm test, one-target multi-identity, and cross-spec collisions remain blocking because program or target identity is incompatible; categories appear only in diagnostics. [D3 reconciliation evidence target](report.md#scope-2-normalized-program-category-evidence) |
| SCN-032-008 | Functional regression - empty stdout | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 preserves empty-stdout exemption without stdoutBytes`; `BUG-032 Check 43 does not treat empty stdout as substantive cloned evidence` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 with the empty-stdout exemption independent of optional `stdoutBytes`. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-006, SCN-032-007, SCN-032-008 | Receipt schema compatibility | `bubbles/scripts/state-transition-guard-selftest.sh` using `bubbles/scripts/tool-log.sh` schema-v2 fixture rows | The SCN-032-006 through SCN-032-008 identifiers above | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Fixtures with and without optional `stdoutBytes`/`inputClosure` are handled conservatively. [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence) |
| SCN-032-023 | Tests-first RED - complete target overlap | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 compares complete target sets for every command identity`; `BUG-032 Check 43 preserves disjoint-target siblings and same-target refusal controls` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because overlap hidden after the first receipt is accepted. Complete disjoint-target and same-target controls must run in the same command. Harden row 98 is diagnostic input, not this persistent RED receipt. |
| SCN-032-023 | Regression GREEN - complete target controls | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 compares complete target sets for every command identity`; `BUG-032 Check 43 preserves disjoint-target siblings and same-target refusal controls` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when any complete-set overlap blocks, every complete disjoint set remains a sibling, and the deterministic same-target control still blocks. |
| SCN-032-024 | Tests-first RED - underlying wrapped program | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 unwraps evidence-capture to compare underlying programs`; `BUG-032 Check 43 preserves same-program wrapped siblings over distinct targets` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because incompatible wrapped programs collapse to evidence-capture. The same-program wrapped control must run in the same command. Harden row 98 is diagnostic input, not this persistent RED receipt. |
| SCN-032-024 | Regression GREEN - wrapper identity twins | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 unwraps evidence-capture to compare underlying programs`; `BUG-032 Check 43 preserves same-program wrapped siblings over distinct targets` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when wrapped cargo and npm programs block while the same wrapped validator over disjoint targets remains a sibling. |
| SCN-032-025 | Tests-first RED - contradictory stdout metadata | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 fails closed on non-empty hash with zero-byte metadata`; `BUG-032 Check 43 preserves canonical empty and ordinary non-empty controls` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Before production repair, exit nonzero because contradictory metadata disappears from analysis. Empty-hash and positive-byte controls must run in the same command. Harden row 98 is diagnostic input, not this persistent RED receipt. |
| SCN-032-025 | Regression GREEN - stdout metadata controls | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 fails closed on non-empty hash with zero-byte metadata`; `BUG-032 Check 43 preserves canonical empty and ordinary non-empty controls` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only when contradictory metadata is named and blocks, canonical empty output stays exempt, and positive-byte non-empty output follows ordinary identity analysis. |
| SCN-032-006, SCN-032-007, SCN-032-008 | Static shell syntax | `bubbles/scripts/state-transition-guard.sh`; `bubbles/scripts/state-transition-guard-selftest.sh` | Shell syntax for Check 43 and its persistent SCN assertions | `bash -n bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0. |

### Scope 2 Consumer Impact Sweep

Check 43 diagnostics are consumed by every downstream transition guard. Update
source comments and evidence-contract docs so they identify normalized program,
dispatch script, target, numeric exit, and execution provenance as receipt
identity. Category stays known non-mixed sanity metadata and diagnostic context;
a category-label difference alone is not a clone. No command name, receipt
field, or public path is renamed or removed.

### Scope 2 Affected Consumer Surfaces

The affected consumers are downstream transition-guard diagnostics,
evidence-contract documentation, the state-transition and receipt-identity
selftests, and stale-reference scans. Consumer review must find zero active
claims that category agreement defines sibling identity or category difference
defines cloning. Navigation, breadcrumbs, redirects, API clients, generated
clients, and deep links do not consume receipt-identity internals.

### Scope 2 Change Boundary

**Allowed file families:** Check 43 logic, its persistent selftest, evidence
contract docs, G021/Gate metadata if wording changes, and this packet.

**Excluded surfaces:** stale-receipt validation, tool-log schema changes unless
red fixtures prove them necessary, evidence admission for markdown-only repos,
and all downstream installed copies.

<!-- markdownlint-disable-next-line MD024 -->
### Definition of Done

- [x] SCN-032-006 deterministic-validator fixture fails before the production fix. → Evidence: [Scope 2 RED Evidence](report.md#scope-2-red-evidence)
- [x] SCN-032-006 one normalized validator program over distinct targets with equal numeric exit and independent provenance is accepted when categories are known and non-mixed, whether their labels agree or differ. → Evidence: [Current receipt and frozen-input closure](report.md#current-receipt-and-frozen-input-closure)
- [x] SCN-032-007 cargo test versus npm lint sharing one substantive hash remains blocking. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-007 npm-run lint versus npm-run test, two identities sharing one target, and cross-spec incompatible-program reuse remain blocking; category labels are diagnostic only. → Evidence: [Current receipt and frozen-input closure](report.md#current-receipt-and-frozen-input-closure)
- [x] SCN-032-008 empty-stdout digest handling passes with present and absent stdoutBytes. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-006, SCN-032-007, and SCN-032-008 retain conservative handling when identity metadata is missing. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-006, SCN-032-007, and SCN-032-008 keep BUG-007 and BUG-019 regression assertions green. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] SCN-032-006, SCN-032-007, and SCN-032-008 have scenario-specific E2E regression tests for every changed behavior. → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] Broader E2E regression suite passes → Evidence: [Scope 2 GREEN Evidence](report.md#scope-2-green-evidence)
- [x] Consumer impact sweep confirms zero stale first-party references remain → Evidence: [Scope 2 Boundary Evidence](report.md#scope-2-boundary-evidence)
- [x] Change Boundary is respected and zero excluded file families were changed → Evidence: [Scope 2 Boundary Evidence](report.md#scope-2-boundary-evidence)
- [ ] SCN-032-023 has a persistent tests-first RED assertion for non-first target overlap with deterministic disjoint-target and same-target controls in the same run.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 98 executed the overlap defect and both existing controls.
  > **What was observed:** A hidden overlap was accepted while the disjoint-target and same-target controls produced their expected outcomes.
  > **Why this is uncertain:** The adversary is not part of the persistent state-transition selftest.
  > **What would resolve this:** Add both planned identifiers after Scope 1 releases the file and capture the expected nonzero pre-repair run.
- [ ] SCN-032-023 compares every target in each command identity, blocks any overlap, accepts complete disjoint sets, and retains same-target refusal.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-023.
  > **What was observed:** Current Check 43 projects only the first receipt target in harden row 98.
  > **Why this is uncertain:** Complete-set logic and independent GREEN proof are absent.
  > **What would resolve this:** Implement complete target sets and run the unchanged three-way control matrix to exit 0.
- [ ] SCN-032-024 has a persistent tests-first RED assertion for incompatible programs under evidence-capture with a same-program wrapped sibling control.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 98 executed the incompatible wrapped-program case and a deterministic control.
  > **What was observed:** Check 43 accepted incompatible underlying programs as siblings.
  > **Why this is uncertain:** No persistent wrapper-unwrapping assertion reaches the selftest failure gate.
  > **What would resolve this:** Add both planned identifiers and capture the expected nonzero pre-repair run.
- [ ] SCN-032-024 compares underlying wrapped programs, blocks incompatible programs, and preserves same-program wrapped siblings over disjoint targets.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-024.
  > **What was observed:** The common evidence-capture wrapper currently masks the underlying program difference.
  > **Why this is uncertain:** Transparent wrapper normalization and independent GREEN proof are absent.
  > **What would resolve this:** Implement wrapped-argv identity and run the unchanged incompatible and compatible twins to exit 0.
- [ ] SCN-032-025 has a persistent tests-first RED assertion for non-empty hash with zero-byte metadata plus canonical empty and ordinary non-empty controls.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 98 executed all three metadata shapes.
  > **What was observed:** Contradictory metadata disappeared from both clone and sibling analysis.
  > **Why this is uncertain:** The persistent oracle does not carry the contradiction case.
  > **What would resolve this:** Add both planned identifiers and capture the expected nonzero pre-repair run.
- [ ] SCN-032-025 fails closed on contradictory stdout metadata while preserving the canonical empty exemption and ordinary positive-byte analysis.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-025.
  > **What was observed:** The current predicate discards the contradiction in harden row 98.
  > **Why this is uncertain:** Fail-closed metadata handling and independent GREEN proof are absent.
  > **What would resolve this:** Implement the three-state metadata decision and run the unchanged controls to exit 0.

---

## Historical Scope 3: G101 Delivery-Capable Mode Semantics

**Status:** In Progress
**Scope-Kind:** contract-only
**Depends on:** None
**Execution gate:** Ready for a disjoint tests-first RED lane after this planning
transaction. Harden row 95 supplies diagnostic RED input, not a persistent
tests-first receipt.

### Scope 3 Goal

Require release reconciliation to prove delivered implementation, not merely a
terminal result in any workflow mode.

**Consumer surface:** The G101 release-reconciliation CLI command and its
operator-visible DELIVERED or NOT-DELIVERED result.

<!-- markdownlint-disable-next-line MD024 -->
### Gherkin Scenarios

```gherkin
Feature: Required release delivery semantics

  Historical Case: SCN-032-009 - A validate-certified product-to-planning packet reaches specs_hardened
    Given a required release feature binds a spec in product-to-planning mode
    And the spec status and certification status are specs_hardened
    And validate appears in certified completed phases
    When G101 reconciles delivery=required
    Then the guard exits 1
    And the feature is reported NOT-DELIVERED

  Historical Case: SCN-032-010 - A full-delivery packet is done and validate-certified
    Given a required release feature binds a full-delivery spec
    And the spec status is done
    And validate appears in certified completed phases
    When G101 reconciles delivery=required
    Then the guard exits 0
    And the feature is reported DELIVERED

  Historical Case: SCN-032-011 - A validate-certified prototype reaches delivered_prototype
    Given a required release feature binds a prototype-tier spec
    And the spec status is delivered_prototype
    And validate appears in certified completed phases
    When G101 reconciles delivery=required
    Then the guard exits 1
    And the feature is reported NOT-DELIVERED

  Historical Case Outline: SCN-032-012 - Terminal status meaning follows the resolved mode contract
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

  Historical Case Outline: SCN-032-026 - Explicit v3 certification is authoritative for delivery
    Given a required full-delivery feature has <state shape>
    When G101 reconciles delivery=required
    Then the delivery result is <result>
    And the decision source is <authority>

    Examples:
      | state shape | result | authority |
      | top-level done and certification done with validate certified | DELIVERED | explicit v3 certification |
      | top-level done and certification in_progress | NOT-DELIVERED | explicit v3 certification mirror |
      | explicit certification in_progress while legacy completedPhases contains validate | NOT-DELIVERED | explicit v3 certification object |
      | no certification object with legacy done and legacy validate phase | DELIVERED | documented legacy compatibility control |
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
8. Add the complete SCN-032-026 four-case matrix to the persistent G101
  selftest and capture its expected RED result before production changes. Keep
  coherent v3 and no-certification legacy controls in the same run.
9. When a certification object exists, require top-level and certification
  status mirrors to agree and source phase completion only from explicit v3
  certification fields. Never let legacy phase fields override that object.
10. Apply legacy `done` plus validate compatibility only when the certification
  object is absent, matching the existing design contract.
11. Re-run the unchanged four-case matrix to GREEN and require independent
  test-owner verification before Scope 3 may close.

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
| SCN-032-026 | Tests-first RED - certification authority | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `BUG-032 G101 rejects explicit status-mirror divergence`; `BUG-032 G101 gives explicit v3 certification precedence over legacy phases`; `BUG-032 G101 preserves coherent v3 and no-certification legacy controls` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Before production repair, exit nonzero because both explicit-conflict cases are falsely delivered. Coherent v3 and legacy-without-certification controls must pass in the same run. Harden row 95 is diagnostic input, not this persistent RED receipt. |
| SCN-032-026 | Regression GREEN - certification authority matrix | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `BUG-032 G101 rejects explicit status-mirror divergence`; `BUG-032 G101 gives explicit v3 certification precedence over legacy phases`; `BUG-032 G101 preserves coherent v3 and no-certification legacy controls` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 only when both explicit v3 conflicts are NOT-DELIVERED, coherent v3 is DELIVERED, and the absent-certification legacy control retains documented compatibility. |
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
- [ ] SCN-032-026 has a persistent tests-first RED assertion for both explicit v3 conflicts with coherent v3 and absent-certification legacy controls in the same run.
  > **Uncertainty Declaration**
  > **What was attempted:** Harden row 95 executed the complete four-case matrix outside the persistent G101 selftest.
  > **What was observed:** Both explicit-conflict cases were falsely DELIVERED while both controls passed.
  > **Why this is uncertain:** The persistent selftest does not carry the three planned identifiers.
  > **What would resolve this:** Add the planned matrix and capture its expected nonzero result before production changes.
- [ ] SCN-032-026 rejects explicit status-mirror divergence, gives explicit v3 certification precedence over legacy phase fields, and preserves coherent v3 plus absent-certification legacy controls.
  > **Uncertainty Declaration**
  > **What was attempted:** No post-repair persistent run exists for SCN-032-026.
  > **What was observed:** Current G101 accepts both conflicts in harden row 95.
  > **Why this is uncertain:** Certification-authority implementation and independent GREEN proof are absent.
  > **What would resolve this:** Implement explicit-object precedence and run the unchanged four-case matrix to exit 0.

---

## Historical Validation Inventory: Contract Reconciliation And Full Validation

**Status:** In Progress
**Scope-Kind:** docs-only
**Depends on:** Scopes 1, 2, and 3
**Execution gate:** Scopes 1-3 are Done. This planning reconciliation does not
execute or pre-check any Scope 4 obligation.

### Scope 4 Goal

Make source comments, gate metadata, shared documentation, generated framework
surfaces, and release evidence agree with the implemented contracts.

**Consumer surface:** The framework-validation and release-check CLI commands
and their operator-visible evidence captures.

<!-- markdownlint-disable-next-line MD024 -->
### Gherkin Scenarios

```gherkin
Feature: Planning evidence and release-surface truth

  Historical Case: SCN-032-027 - Checked DoD evidence resolves to its own substantive block
    Given a checked DoD claim references an owner-authored report evidence block
    When Check 9 resolves the reference
    Then the anchor resolves to at least ten non-blank lines with Claim Source and command output for an execution claim
    And a parent heading, short block, missing anchor, or prose-only execution block remains blocking
    And no original raw execution evidence is rewritten

  Rejected Historical Case: The DoD faithfully states SCN-032-014 behavior
    Given SCN-032-014 requires unrelated negation to preserve direct route removal and all three impact-planning checks
    When G068 compares the scenario with Scope 1 DoD text
    Then a DoD item states that exact behavior and its owned-negation negative control
    And a generic classifier-completion item cannot satisfy the scenario

  Historical Case: SCN-032-030 - Release-manifest generation runs after every tracked input settles
    Given source, persistent tests, test comments, planning artifacts, docs, and registry inputs have reached their final byte epoch
    When the canonical derived-surface generator runs
    Then the release manifest is generated last and the freshness check exits zero
    And changing a tracked input after generation makes the freshness check fail

  Historical Case: SCN-032-031 - Test comments describe the assertions they accompany
    Given a persistent selftest comment names receipt sibling identity or a numbered G101 case group
    When the comment truth check compares it with the adjacent executable assertions
    Then category labels are described as diagnostic rather than required equality
    And the G101 comments name S26 through S28 and S29 through S31 respectively
    And executable test expectations remain unchanged by the comment-only edit

  Historical Case: SCN-032-032 - The active Completion Statement routes only unresolved work
    Given BUG032-GAPS-STATE-NOTES-009 is addressed in the fresh gaps record
    And the convergence-9 behavior lanes remain unresolved
    When the report Completion Statement and state execution route are compared
    Then neither surface routes the addressed finding
    And both select the tests-first A-RED and C-RED frontier under canonical next owner bubbles.test
    And BUG035-D14-EMPTY-OUTPUT-COUNT remains an independent BUG-035 sibling
```

### Validation Contracts

These process obligations bind the original sixteen scenarios and the sixteen
convergence-9 scenarios. SCN-032-027 and SCN-032-029 through SCN-032-032 are
first-class manifest entries rather than prose-only process notes.

| Scenario binding | Scope 4 validation contract | Persistent validation surface | Required Scope 4 outcome |
| --- | --- | --- | --- |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Focused classifier selftests and published Check 8B/5A contracts agree. | `bubbles/scripts/state-transition-guard-selftest.sh`, source comments, gate metadata, and shared framework documentation | No source claims whole-prose co-occurrence proves consumer mutation, line-global negation can exempt a later mutation, an open surface head is direct, post-materialization bounds are finite, per-line external normalization is acceptable, or negated/no-SLO prose is an affirmative promise. |
| SCN-032-006, SCN-032-007, SCN-032-008 | Focused receipt-identity selftests and published Check 43 contracts agree. | `bubbles/scripts/state-transition-guard-selftest.sh`, evidence-contract documentation, and G021 metadata | No source claims different command strings cannot honestly emit identical stdout. |
| SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Focused delivery selftests and published G101 contracts agree. | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh`, mode-resolution documentation, and G101 metadata | No source claims every validate-certified terminal mode is delivered. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Full framework validation and release checks preserve all focused behavior on one final byte epoch. | Canonical generated surfaces, final source/test identity inventory, `framework-validate`, and `release-check` evidence captures | Both full commands exit 0 with current-session, hash-verifiable evidence after final source and persistent test identities are frozen and before any Scope 4 DoD item is checked. |

### Scope 4 Implementation Plan

1. Search source comments, shared docs, gate metadata, BUGS entries, and release
   guidance for the four superseded claims.
2. Update only contracts changed by Scopes 1-3.
3. Reconcile BUG-028 to validation-backed or validate-certified BUG-032 D3
  evidence after the current implementation epoch is validated.
4. Correct planning-owned checked DoD references to the nearest substantive
   owner-authored evidence blocks. Preserve every raw evidence byte. Add the
   exact SCN-032-014 DoD wording required by G068 and remove the stale addressed
   finding from the active Completion Statement route.
5. Keep each truth-only test comment edit with the A, B, or C lane already
   writing that file. If no executable writer touches a file, assign one
   exclusive `bubbles.test` writer after the corresponding GREEN checkpoint.
6. Regenerate derived framework surfaces through `regen-derived.sh` only after
   every source, persistent test, comment, planning, documentation, registry,
   and release-note input settles. The release manifest remains the generator's
   final output. Do not hand-edit downstream copies.
7. Freeze the final source and persistent-test SHA-256 and git-object identities.
  Treat any later byte change as invalidating all final focused and whole-suite
  receipts.
8. Run focused selftests again, including every SCN-032-014 through
  SCN-032-032 discriminator and no-process proof.
9. Run full framework validation and release check through hash-verifiable
   evidence capture because their output exceeds the compact-output threshold.
10. Recheck the frozen byte inventory, then run final diff and unrelated-worktree
  checks.

<!-- markdownlint-disable-next-line MD024 -->
### Test Plan

| Scenario binding | Test Type | Persistent test file | Persistent test identifier | Exact command | Required result |
| --- | --- | --- | --- | --- | --- |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Focused state-transition regression | `bubbles/scripts/state-transition-guard-selftest.sh` | All Scope 1 identifiers, including phrase-local negation twins, four surface-tail triples, exact 128/129 tokens, exact eight/nine candidates, candidate-overflow precedence, helper error, mixed-surface all-three checks, one marker pair, sourceability, structural no-process proof, and shadow-command zero counts | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only after all focused classifier assertions pass on the frozen final source/test byte epoch. |
| SCN-032-006, SCN-032-007, SCN-032-008 | Focused state-transition receipt regression | `bubbles/scripts/state-transition-guard-selftest.sh` | `BUG-032 Check 43 accepts independent deterministic validator siblings over distinct targets`; `BUG-032 Check 43 preserves empty-stdout exemption without stdoutBytes` | `bash bubbles/scripts/state-transition-guard-selftest.sh` | Exit 0 only after the normalized-program sibling and empty-stdout assertions pass. |
| SCN-032-006, SCN-032-007 | Focused canonical receipt-identity reconciliation | `bubbles/scripts/receipt-identity-selftest.sh` | `BUG-028 canonical: one validator over three subjects with differing tags is not reported as cloned evidence`; `BUG-028 canonical: the three-subject group is accepted through the deterministic-sibling path`; `BUG-032 pin: incompatible command families sharing one stdout are still refused`; `BUG-028 defect 1 bound: two identities sharing ONE target and one stdout are still refused`; `BUG-028 bound: a group mixing two specs on one stdout is still refused` | `bash bubbles/scripts/receipt-identity-selftest.sh` | Exit 0 only when differing known non-mixed labels remain diagnostic, one normalized program over independent targets is accepted, and incompatible normalized programs or one-target identity collisions remain blocking. |
| SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012 | Focused G101 regression | `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `S13 product-to-planning/specs_hardened is not delivered`; `S16 full-delivery/done remains delivered`; `S12 required feature delivered_prototype is refused (prototype never deployable)`; `S17 dark-launch-shipped/pending-activation remains delivered`; `S18 rapid-tool-delivery/delivered_fast remains delivered`; `S19 unknown mode gains no pending-activation fallback`; `S20 product-to-planning/done is incoherent, not delivered` | `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Exit 0 only after the full delivery decision table passes. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Final-byte identity checkpoint | All changed production and persistent test files for Scopes 1-3 | SHA-256, git-object, byte-count, and changed-path inventory recorded before and after the focused/full commands | Canonical bounded identity command recorded in `report.md` | The before and after inventories are identical. Any changed byte invalidates the focused, framework, and release receipts and requires re-execution. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Full framework validation | All three persistent selftest files above through the canonical framework suite | All SCN-linked identifiers above | `bash bubbles/scripts/evidence-capture.sh --label "BUG-032 framework validate" -- bash bubbles/scripts/cli.sh framework-validate` | Captured exit 0 with verifiable full-output hash on the frozen final byte epoch. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Release check | All three persistent selftest files above through the canonical release suite | All SCN-linked identifiers above | `bash bubbles/scripts/evidence-capture.sh --label "BUG-032 release check" -- bash bubbles/scripts/cli.sh release-check` | Captured exit 0 with verifiable full-output hash on the same frozen final byte epoch. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Agnosticity | Canonical source and generated framework surfaces | Portable-contract scan for the SCN-linked behavior | `bash bubbles/scripts/cli.sh agnosticity` | Exit 0; no downstream product name is introduced into portable framework fixtures. |
| SCN-032-001, SCN-032-002, SCN-032-003, SCN-032-004, SCN-032-005, SCN-032-006, SCN-032-007, SCN-032-008, SCN-032-009, SCN-032-010, SCN-032-011, SCN-032-012, SCN-032-013, SCN-032-014, SCN-032-015, SCN-032-016 | Patch integrity | `bugs/BUG-032-planning-maturity-guard-false-positives/scopes.md` | Markdown and whitespace integrity for all SCN mappings | `git diff --check` | Exit 0. |
| SCN-032-027 | Evidence-anchor regression | `bubbles/scripts/state-transition-guard-selftest.sh` and this BUG-032 packet | `BUG-032 Check 9 accepts nearest substantive owner evidence and rejects parent short missing or prose-only execution anchors` | `bash bubbles/scripts/state-transition-guard-selftest.sh` and `bash bubbles/scripts/state-transition-guard.sh bugs/BUG-032-planning-maturity-guard-false-positives` | The persistent positive/negative fixture passes. The packet emits no Check 9 block for the fourteen repaired references or the former prose-only execution reference. Raw evidence bytes remain unchanged. |
| SCN-032-029 | G068 DoD fidelity | `bubbles/scripts/state-transition-guard-selftest.sh` and this BUG-032 packet | `BUG-032 G068 requires SCN-032-014 direct-after-unrelated-negation and owned-negation control wording` | `bash bubbles/scripts/state-transition-guard-selftest.sh` and `bash bubbles/scripts/traceability-guard.sh bugs/BUG-032-planning-maturity-guard-false-positives` | The exact-behavior fixture passes, its generic-DoD negative control blocks, and packet traceability reports zero Gherkin-to-DoD gaps. |
| SCN-032-030 | Release-manifest ordering and freshness | `bubbles/scripts/regen-derived-selftest.sh`; `bubbles/scripts/generate-release-manifest.sh`; `bubbles/release-manifest.json` | `generators invoked in dependency order (gate enforcement -> stats -> cheatsheet -> ledger -> gate-map -> manifest LAST)`; `a generator still stale after regeneration makes the wrapper exit non-zero` | `bash bubbles/scripts/regen-derived-selftest.sh`; then `bash bubbles/scripts/regen-derived.sh`; then `bash bubbles/scripts/regen-derived.sh --check-only` | The ordering selftest exits 0. Mutation-mode regeneration runs only after all tracked inputs settle. The final check-only run exits 0; a late-input fixture remains a blocking control. |
| SCN-032-031 | Test-comment truth | `bubbles/scripts/state-transition-guard-selftest.sh`; `bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | `BUG-032 test comments describe current Check 43 and G101 assertion groups` | `bash bubbles/scripts/state-transition-guard-selftest.sh`; `bash bubbles/scripts/release-delivery-reconciliation-guard-selftest.sh` | Comments state the active category-diagnostic contract and correct S26-S28/S29-S31 groups. Adjacent executable assertions and expected results are byte-identical except for changes separately required by A, B, or C. |
| SCN-032-032 | Report-route truth | `bugs/BUG-032-planning-maturity-guard-false-positives/report.md`; `bugs/BUG-032-planning-maturity-guard-false-positives/state.json` | `BUG-032 active Completion Statement routes only the convergence-9 executable frontier` | `bash bubbles/scripts/artifact-lint.sh bugs/BUG-032-planning-maturity-guard-false-positives` plus the bounded planning parity assertion recorded in the planning report | The active route omits addressed `BUG032-GAPS-STATE-NOTES-009`, names canonical `bubbles.test`, carries A-RED and C-RED as parallel lanes, and preserves the independent BUG-035 disposition. |
| SCN-032-017 through SCN-032-032 | Markdown-machine Test Plan parity | `bugs/BUG-032-planning-maturity-guard-false-positives/scopes.md`; `bugs/BUG-032-planning-maturity-guard-false-positives/test-plan.json` | Every Markdown row has one semantically equal machine row and no machine row is orphaned | Canonical bounded parity assertion recorded in `report.md` | Scope row counts, scenario sets, files, identifiers, commands, and expected outcomes match exactly. |
| SCN-032-001 through SCN-032-032 | Scenario uniqueness and obligation integrity | `scenario-manifest.json`; `bubbles/registry/proof-obligations.yaml` | Unique SCN IDs and per-scenario trait obligations | `bash bubbles/scripts/scenario-obligation-lint.sh bugs/BUG-032-planning-maturity-guard-false-positives` | Exactly 32 active unique IDs exist; every trait owes a matching obligation and no scenario declares the entire vocabulary. |
| SCN-032-017 through SCN-032-032 | Planned identifier reachability | All persistent test files named by new Test Plan rows | Every planned test identifier appears in its declared file after test authorship | Canonical bounded identifier-resolution assertion recorded in `report.md` | Before test authorship the missing identifiers are explicitly expected. After A-RED, B-RED, C-RED, and Scope 4 test-comment ownership settle, zero identifiers are missing. |
| SCN-032-001 through SCN-032-032 | Reference existence | All paths and gate references introduced by this reconciliation | Repository-relative references resolve | `bash bubbles/scripts/reference-existence-lint.sh bugs/BUG-032-planning-maturity-guard-false-positives` | Exit 0 after every planned path exists; no phantom script, gate, or artifact reference remains. |

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

- [ ] BUG-028 is reconciled to validation-backed or validate-certified BUG-032
  D3 evidence, with the receipt-identity requirement and evidence link preserved.
- [ ] SCN-032-027 checked DoD references resolve to their nearest substantive
  owner-authored blocks; parent, short, missing, and prose-only execution
  anchors remain blocking controls; original raw evidence bytes are unchanged.
- [ ] SCN-032-029 faithfully states that SCN-032-014 keeps every direct route
  removal positive after unrelated `no` or `without`, runs the sweep section,
  completion-item, and affected-consumer checks, and keeps owned-negation twins
  negative; a generic completion statement does not satisfy G068.
- [ ] SCN-032-031 test comments describe category labels as diagnostic, name
  the correct S26-S28 and S29-S31 G101 groups, and do not change unrelated
  executable assertions.
- [ ] SCN-032-032 removes the addressed `BUG032-GAPS-STATE-NOTES-009` route from
  the active Completion Statement, names the tests-first A-RED and C-RED
  frontier, and preserves `BUG035-D14-EMPTY-OUTPUT-COUNT` as an independent
  BUG-035 route.
- [ ] Every changed behavior contract has synchronized source comments, docs, and
  gate metadata.
- [ ] SCN-032-030 proves `regen-derived.sh` invokes the release manifest last,
  mutation-mode generation runs only after every source/test/comment/planning/
  docs/registry input settles, and the final check-only run reports fresh.
- [ ] Focused state-transition and G101 selftests pass.
- [ ] Full framework validation passes with current-session captured evidence.
- [ ] Release check passes with current-session captured evidence.
- [ ] Agnosticity and portability checks pass.
- [ ] `git diff --check` passes.
- [ ] Unrelated pre-existing changes under `improvements/` remain untouched.
- [ ] All checked DoD evidence is recorded only after actual execution.
- [ ] SCN-032-001 through SCN-032-016 each have scenario-specific persistent regression coverage, and SCN-032-014 through SCN-032-016 include every five-finding discriminator from Scope 1.
- [ ] Broader E2E regression suite passes
- [ ] The final source and persistent-test byte inventory is identical before and after focused selftests, framework validation, and release check; no superseded first-candidate receipt is used as final proof.
- [ ] Consumer impact sweep confirms zero stale first-party references remain
- [ ] Change Boundary is respected and zero excluded file families were changed
- [ ] Markdown Test Plan and `test-plan.json` have exact row parity for all four
  scopes and SCN-032-001 through SCN-032-032.
- [ ] Scenario IDs are unique, every declared behavior trait has its required
  obligation, and all 32 scenarios resolve through the scenario-manifest guard.
- [ ] Every planned persistent test identifier introduced for SCN-032-017
  through SCN-032-032 exists in its declared test file before final validation.
- [ ] Artifact lint, traceability, scenario obligations, planned identifier
  reachability, and reference existence all pass after the final planning epoch.
~~~~
<!-- bubbles:g040-skip-end -->
