# BUG-035 Scopes

## Scope 1 - Validation Control-Plane Convergence

**Status:** In Progress

**Foundation:** IMP-048 is delivered. Its durable record is
`improvements/INDEX.md` row `IMP-048`. Dispatch receipts, test-leaf receipts,
session budgets, and state liveness are available for this scope to consume.

### Gherkin Scenarios

```gherkin
Scenario: SCN-B035-001 A bounded session resumes without operator nudges
  Given a mutable delivery session has accepted work and unresolved occurrences
    And the session crosses its soft lifecycle boundary
  When Bubbles rolls the session over
  Then it persists the first unresolved occurrence
    And it starts a continuation with the same work boundary
    And it does not require a user to send continue or Try Again

Scenario: SCN-B035-002 Accepted proof is reused across compatible consumers
  Given a test leaf passed for one candidate, input closure, and environment
    And a later certification consumer requires the same proof
  When the consumer resolves its evidence
  Then it reports REUSED with the original receipt identifier
    And it does not execute the test leaf again
    And a changed covering input invalidates that receipt

Scenario: SCN-B035-003 Certification projects lifecycle state atomically
  Given execution claims and accepted receipts satisfy one scope
  When bubbles.validate certifies the scope
  Then one authoritative certification transaction is written
    And compatibility status fields are derived from that transaction
    And a stale projection does not make the packet unresolvable

Scenario: SCN-B035-004 An unrelated finding routes without taking over the task
  Given a narrow task has a frozen work boundary
    And a repository-wide check finds a defect outside that boundary
  When Bubbles classifies the finding
  Then it creates or references an owned packet
    And the parent receives ROUTE_ONLY unless a named shared release floor fails
    And a release-floor refusal names the mode rule that made it blocking

Scenario: SCN-B035-005 Validation depth follows resolved risk
  Given a mutable change has no high-risk traits
  When Bubbles resolves its validation plan
  Then focused proof and one aggregate release check are required
    And unrelated high-risk validation is not injected
    But unknown or high-risk changes retain the full assurance chain

Scenario: SCN-B035-006 Unchanged assurance closure stops equivalent replay
  Given all scenario and gate obligations passed on frozen inputs
    And an assurance closure records the accepted receipts
  When the same validation is requested again
  Then Bubbles reports REUSED for the closure
    And a rerun occurs only after invalidation or with a stated rerun reason

Scenario: SCN-B035-007 Source bug artifacts use a declared packet form
  Given the Bubbles source repository contains root bug packet directories
    And Gate G085 forbids a specs directory in the source repository
  When the bug-packet authority validates a new source bug
  Then the root packet matches a declared source form
    And BUGS.md has one documented role
    And no undeclared fourth form is accepted

Scenario: SCN-B035-008 Payload closure is deterministic
  Given a large managed scheduler uses a self-only source dependency
  When payload closure evaluates unchanged bytes repeatedly
  Then every verdict accepts the guarded dependency
    And an unguarded dependency remains refused

Scenario: SCN-B035-009 Changed-only validation uses exact source HEAD
  Given the source checkout is detached from an older main branch
  When the changed-only selftest creates its fixture
  Then the fixture baseline equals source HEAD
    And changed-only selection remains narrow after a fixture commit

Scenario: SCN-B035-010 Large-output assertions are deterministic
  Given captured output contains one required diagnostic among many lines
  When a selftest asserts the diagnostic under pipefail
  Then the assertion passes on every run
    And an absent diagnostic still fails

Scenario: SCN-B035-011 Performance contention is confirmed before failure
  Given one large-report guard run exceeds 30 seconds of wall time
  When Bubbles measures the guard process tree
  Then sub-budget CPU time identifies host contention
    And a retry occurs only when both wall and CPU time exceed the budget
    And two wall-and-CPU over-budget samples fail

Scenario: SCN-B035-012 Core-tier pattern matching is deterministic
  Given the shipped validator has no dead core pattern
  When its pattern lint runs repeatedly on unchanged bytes
  Then every run passes
    And the renamed-check adversary still fails

Scenario: SCN-B035-013 Downstream validation distinguishes progress from a hang
  Given installed-tree validation is still producing log output under contention
    And the caller CWD belongs to another repository
  When its original wall duration exceeds one hour
  Then the idle deadline resets on progress
    And an absolute ceiling still bounds endless output
    And a silent child fails at the idle deadline
    And downstream commands and transition gates use the installed or guarded repository root
    And timeout diagnostics do not cascade into missing-skip findings
    And an unexplained nonzero child fails closed

Scenario: SCN-B035-014 Evidence capture fails closed when output disappears
  Given a command is running under the evidence capture wrapper
  When its private capture output is removed before finalization
  Then the wrapper exits with a capture-integrity error
    And it emits no blank hash or evidence-shaped block
```

### Implementation Plan

1. Consume the delivered IMP-048 receipt and lifecycle surfaces.
2. Add assurance-closure production and consumption.
3. Make validate certification the single writable lifecycle authority.
4. Generate compatibility projections from certification.
5. Add boundary outcomes for in-scope, route-only, and shared-floor findings.
6. Apply risk resolution to every mutable entry path.
7. Reconcile `bubbles/registry/bug-packet.yaml` with source repository practice.
8. Make payload-closure pipeline recognition full-reading and deterministic.
9. Make changed-only fixtures baseline from exact source HEAD.
10. Replace quiet captured-output pipelines with direct string assertions.
11. Record wall and process-tree CPU time, and retry only when both breach the
  performance threshold.
12. Replace core-tier quiet pattern matching and repeat its shipped check.
13. Replace v5.3's fixed wall timeout with idle-progress and absolute bounds,
  bind downstream commands to the installed root, and bind transition gates to
  the guarded repository rather than ambient CWD.
14. Namespace evidence-capture storage and fail closed when output disappears.
15. Add focused, adversarial, and full-framework regression coverage.

### Test Plan

| ID | Scenario | Test | Type | Planned surface |
| --- | --- | --- | --- | --- |
| T1 | SCN-B035-001 | Session soft-boundary rollover resumes the first unresolved occurrence | functional | `bubbles/scripts/session-review-selftest.sh` |
| T2 | SCN-B035-002 | Compatible consumers reuse a passing leaf and changed inputs invalidate it | unit | `bubbles/scripts/phase-coordinator-selftest.sh` |
| T3 | SCN-B035-003 | Certification transaction projects every compatibility field atomically | unit | `bubbles/scripts/transition-contract-resolver-selftest.sh` |
| T4 | SCN-B035-004 | Out-of-boundary findings route while shared release floors still block | functional | `bubbles/scripts/work-boundary-resolve-selftest.sh` |
| T5 | SCN-B035-005 | Low-risk work receives focused validation and unknown risk fails closed | unit | `bubbles/scripts/risk-tier-resolve-selftest.sh` |
| T6 | SCN-B035-006 | Assurance closure reuses unchanged proof and requires a rerun reason after closure | functional | planned `bubbles/scripts/assurance-closure-selftest.sh` |
| T7 | SCN-B035-007 | Source packet forms and canonical manifest readers match their authorities | unit | `bubbles/scripts/traceability-guard-selftest.sh`; planned `bubbles/scripts/bug-packet-contract-selftest.sh` |
| T8 | Aggregate | Regression E2E - all fourteen scenarios compose through the real CLI | functional | `bubbles/scripts/cli.sh framework-validate` |
| T9 | SCN-B035-008 | Large self-only scheduler remains accepted and unguarded twin fails | unit | `bubbles/scripts/payload-closure-guard-selftest.sh` |
| T10 | SCN-B035-009 | Detached source revision becomes the changed-only fixture baseline | unit | `bubbles/scripts/framework-validate-changed-only-selftest.sh` |
| T11 | SCN-B035-010 | Captured-output contains and excludes assertions remain stable across aggregate posture, mechanism, delivery-plan, and sensitive-storage checks | unit | `bubbles/scripts/adversarial-resolve-selftest.sh`, `bubbles/scripts/autonomy-posture-guard-selftest.sh`, `bubbles/scripts/evidence-tool-log-bridge-selftest.sh`, `bubbles/scripts/implementation-reality-scan-selftest.sh`, `bubbles/scripts/rapid-tool-delivery-mode-selftest.sh`, `bubbles/scripts/requirement-mechanism-guard-selftest.sh`, `bubbles/scripts/vertical-delivery-plan-guard-selftest.sh`, and `tests/regression/test_24_g028_sensitive_client_storage.sh` |
| T12 | SCN-B035-011 | Wall-only contention passes, while repeated wall-and-CPU slowness fails | unit | `bubbles/scripts/state-transition-guard-perf-selftest.sh` |
| T13 | SCN-B035-012 | Shipped core-tier validator passes 20 runs while renamed check fails | unit | `bubbles/scripts/core-tier-pattern-lint-selftest.sh` |
| T14 | SCN-B035-013 | Progress resets idle timeout; silent, chatty, and unexplained-nonzero children fail correctly | unit | `bubbles/scripts/guard-lib-timeout-selftest.sh` and `bubbles/scripts/v5.3-selftest.sh` |
| T15 | SCN-B035-014 | Capture-file loss fails loud and emits no empty evidence hash | unit | `bubbles/scripts/evidence-capture-selftest.sh` |

### Definition of Done

- [ ] SCN-B035-001 passes with automatic rollover and no manual continuation
      prompt.
- [ ] SCN-B035-002 passes with receipt reuse and input-scoped invalidation.
- [ ] SCN-B035-003 passes with one validate-owned lifecycle transaction and
      derived projections.
- [ ] SCN-B035-004 passes for route-only, in-boundary, and shared-floor cases.
- [ ] SCN-B035-005 passes for low, high, and unknown risk classifications.
- [ ] SCN-B035-006 passes for closure reuse, invalidation, and explicit rerun.
- [ ] SCN-B035-007 passes with one declared source packet contract.
- [ ] SCN-B035-008 passes repeatedly while its unguarded twin still fails.
- [ ] SCN-B035-009 passes from a detached source revision.
- [ ] SCN-B035-010 passes for present and absent diagnostics.
- [ ] SCN-B035-011 passes for wall-only contention and repeated wall-and-CPU slowness.
- [ ] SCN-B035-012 passes repeatedly and preserves the dead-pattern adversary.
- [ ] SCN-B035-013 passes for active progress, silence, endless output, and unexplained nonzero exit.
- [ ] SCN-B035-014 passes for capture-file loss without an empty evidence hash.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
- [ ] Broader E2E regression suite passes
- [ ] Full framework validation and release readiness pass with zero new
      warnings.
- [ ] Documentation and generated registry consumers agree with the canonical
      contracts.
- [ ] bubbles.validate certifies every scenario and the packet transition.