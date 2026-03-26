# Bubbles Control Plane Schemas

This document defines the proposed schema surfaces for the control-plane redesign.

Related documents:
- [Control Plane Design](CONTROL_PLANE_DESIGN.md)
- [Control Plane Rollout](CONTROL_PLANE_ROLLOUT.md)

These schemas are proposals for framework evolution. They are not active runtime contracts yet.

## Schema Set

The control plane needs eight concrete schema surfaces:

1. Agent capability registry
2. Execution policy registry
3. Scenario contract manifest
4. `state.json` version 3
5. Transition request packet
6. Rework packet
7. Lockdown approval record
8. Invalidation ledger entry

## 1. Agent Capability Registry

Proposed file: `bubbles/agent-capabilities.yaml`

```yaml
version: 1
generatedFrom:
  - agents/bubbles.*.agent.md
  - bubbles/agent-ownership.yaml
  - bubbles/workflows.yaml
agents:
  bubbles.workflow:
    class: orchestrator
    ownsPhases:
      - finalize
    delegatesPhases:
      select: bubbles.iterate
      bootstrap:
        - bubbles.analyst
        - bubbles.ux
        - bubbles.design
        - bubbles.plan
      implement: bubbles.implement
      test: bubbles.test
      regression: bubbles.regression
      docs: bubbles.docs
      validate: bubbles.validate
      audit: bubbles.audit
      chaos: bubbles.chaos
    canAskUserDirectly: false
    mayWriteState:
      execution:
        - activeAgent
        - currentPhase
        - runStartedAt
      certification: []
  bubbles.validate:
    class: certification
    ownsPhases:
      - validate
      - certify-state
    canAskUserDirectly: false
    mayWriteState:
      execution: []
      certification:
        - status
        - completedScopes
        - certifiedCompletedPhases
        - scopeProgress
        - lockdownState
        - invalidationLedger
    mustDelegate:
      planning: bubbles.plan
      design: bubbles.design
      businessRequirements: bubbles.analyst
      ux: bubbles.ux
      implementation: bubbles.implement
      testCoverage: bubbles.test
  bubbles.grill:
    class: interactive-gate
    ownsPhases:
      - interrogate
    canAskUserDirectly: true
    mayWriteState:
      execution:
        - approvalPrompts
      certification: []
```

### Invariants

- generated file only; do not hand-edit
- every workflow phase must resolve to exactly one owning agent or explicit owner chain
- certification fields may only be owned by `bubbles.validate`
- `canAskUserDirectly` must be explicit for every agent

## 2. Execution Policy Registry

Proposed file: `.specify/memory/bubbles.config.json`

```json
{
  "version": 2,
  "defaults": {
    "grill": {
      "mode": "off",
      "source": "repo-default"
    },
    "tdd": {
      "mode": "scenario-first",
      "defaultForModes": ["bugfix-fastlane", "chaos-hardening"],
      "source": "repo-default"
    },
    "autoCommit": {
      "mode": "off",
      "source": "repo-default"
    },
    "lockdown": {
      "default": false,
      "requireGrillForInvalidation": true,
      "source": "repo-default"
    },
    "regression": {
      "immutability": "protected-scenarios",
      "source": "repo-default"
    },
    "validation": {
      "certificationRequired": true,
      "source": "repo-default"
    }
  },
  "modeOverrides": {
    "bugfix-fastlane": {
      "tdd": {
        "mode": "scenario-first",
        "source": "workflow-forced"
      }
    },
    "chaos-hardening": {
      "tdd": {
        "mode": "scenario-first",
        "source": "workflow-forced"
      }
    }
  }
}
```

### Proposed CLI Surface

```text
bubbles policy status
bubbles policy get tdd.mode
bubbles policy set tdd.mode scenario-first
bubbles policy set grill.mode required-on-ambiguity
bubbles policy set lockdown.default true
bubbles policy reset grill.mode
```

### Invariants

- repo-local mutable defaults live here, not in agent files
- every effective policy value must preserve provenance
- workflow may override defaults, but the override must be recorded

## 3. Scenario Contract Manifest

Proposed file: `specs/<feature>/scenario-manifest.json`

```json
{
  "version": 1,
  "featureDir": "specs/042-catalog-assistant",
  "generatedAt": "2026-03-26T12:00:00Z",
  "scenarios": [
    {
      "scenarioId": "SCN-042-001",
      "scope": "02-search-flow",
      "title": "Guest can open the catalog search screen",
      "gherkin": {
        "given": "a guest is on the landing page",
        "when": "the guest opens search",
        "then": "the catalog search screen appears"
      },
      "gherkinHash": "sha256:...",
      "behaviorClass": "ui",
      "changeType": "new",
      "requiredTestType": "e2e-ui",
      "regressionRequired": true,
      "lockdown": false,
      "linkedTests": [
        {
          "file": "dashboard/e2e/tests/catalog-search.spec.ts",
          "testId": "guest-open-search"
        }
      ],
      "evidenceRefs": [
        "report.md#scenario-scn-042-001"
      ],
      "replacedBy": null,
      "invalidatedBy": null
    }
  ]
}
```

### Invariants

- scenario IDs are stable across implementation churn until the behavior contract is explicitly invalidated
- every changed user-visible or external behavior must appear here
- every scenario must point to live-system tests when its behavior class requires it

## 4. `state.json` Version 3

Proposed file: `specs/<feature>/state.json`

```json
{
  "version": 3,
  "featureDir": "specs/042-catalog-assistant",
  "featureName": "Catalog Assistant",
  "workflowMode": "full-delivery",
  "execution": {
    "activeAgent": "bubbles.workflow",
    "currentPhase": "implement",
    "currentScope": "02-search-flow",
    "runStartedAt": "2026-03-26T12:00:00Z",
    "completedPhaseClaims": ["select", "bootstrap", "implement"],
    "pendingTransitionRequests": ["TR-042-001"]
  },
  "certification": {
    "status": "in_progress",
    "completedScopes": ["01-schema"],
    "certifiedCompletedPhases": ["select", "bootstrap"],
    "scopeProgress": [
      {
        "scope": "01-schema",
        "status": "done",
        "certifiedAt": "2026-03-26T12:15:00Z"
      },
      {
        "scope": "02-search-flow",
        "status": "in_progress",
        "certifiedAt": null
      }
    ],
    "lockdownState": {
      "active": false,
      "lockedScenarioIds": []
    }
  },
  "policySnapshot": {
    "grill": {
      "mode": "required-on-ambiguity",
      "source": "repo-default"
    },
    "tdd": {
      "mode": "scenario-first",
      "source": "workflow-forced"
    }
  },
  "transitionRequests": [
    "TR-042-001"
  ],
  "reworkQueue": [],
  "executionHistory": []
}
```

### Invariants

- `execution` records claims and in-flight state
- `certification` records authoritative state
- only `bubbles.validate` may mutate `certification`
- promotion to `done` is impossible without validate certification

## 5. Transition Request Packet

Proposed file: embedded in state or stored under `specs/<feature>/transitions/`

```json
{
  "transitionRequestId": "TR-042-001",
  "requestedBy": "bubbles.implement",
  "requestedAt": "2026-03-26T12:20:00Z",
  "target": {
    "kind": "scope",
    "id": "02-search-flow",
    "requestedStatus": "done"
  },
  "basis": {
    "dodItems": ["DOD-02-03", "DOD-02-04"],
    "scenarioIds": ["SCN-042-001", "SCN-042-002"],
    "evidenceRefs": [
      "report.md#scope-02-evidence"
    ]
  },
  "status": "pending-validation"
}
```

### Invariants

- execution agents may request promotion
- only validate may resolve the request as approved or rejected
- a request without evidence refs is invalid

## 6. Rework Packet

Proposed file: embedded in state or stored under `specs/<feature>/rework/`

```json
{
  "reworkId": "RW-042-001",
  "createdBy": "bubbles.validate",
  "createdAt": "2026-03-26T12:30:00Z",
  "reason": "scenario-proof-missing",
  "owner": "bubbles.test",
  "scope": "02-search-flow",
  "dodItems": ["DOD-02-04"],
  "scenarioIds": ["SCN-042-002"],
  "requiredActions": [
    "add failing targeted e2e-ui proof",
    "link the test to SCN-042-002",
    "re-run validation"
  ],
  "status": "open"
}
```

### Invariants

- validate never reopens work without a concrete packet
- route-required outcomes must include an owner and scenario or DoD references
- workflow must not report phase success while open rework packets remain

## 7. Lockdown Approval Record

Proposed file: `specs/<feature>/lockdown-approvals.json`

```json
{
  "approvalId": "LKA-042-001",
  "scenarioId": "SCN-042-001",
  "requestedBy": "bubbles.workflow",
  "approvedVia": "bubbles.grill",
  "approvedAt": "2026-03-26T12:40:00Z",
  "approvedBy": "user",
  "reason": "Product behavior intentionally changing for new checkout flow",
  "replacementScenarioId": "SCN-042-017"
}
```

### Invariants

- only locked scenarios require this record
- approval alone is not enough; it must pair with invalidation and replacement planning

## 8. Invalidation Ledger Entry

Proposed file: `specs/<feature>/invalidation-ledger.json`

```json
{
  "invalidationId": "INV-042-001",
  "scenarioId": "SCN-042-001",
  "invalidatedAt": "2026-03-26T12:45:00Z",
  "invalidatedBy": "bubbles.validate",
  "approvedBy": "LKA-042-001",
  "reason": "Approved behavior change",
  "replacementScenarioId": "SCN-042-017",
  "affectedTests": [
    "dashboard/e2e/tests/catalog-search.spec.ts::guest-open-search"
  ]
}
```

### Invariants

- protected regression tests may only change after invalidation exists
- only validate may certify invalidation
- invalidation must point to the replacement scenario when behavior is replaced, not removed entirely

## Schema Relationships

The schemas work together in this order:

1. capability registry decides ownership and delegation
2. policy registry resolves defaults and provenance
3. scenario manifest defines behavior contracts
4. execution agents write transition requests
5. validate certifies or rejects through state version 3
6. rejected transitions create rework packets
7. lockdown approvals and invalidation entries govern protected scenario changes

## Minimum Mechanical Enforcement Needed

These schemas become meaningful only when paired with mechanical enforcement:

- capability registry lint
- policy provenance guard
- scenario manifest guard
- validate-only certification guard
- lockdown guard
- regression immutability guard
- rework packet completeness guard

Without those guards, the schemas would remain descriptive instead of authoritative.