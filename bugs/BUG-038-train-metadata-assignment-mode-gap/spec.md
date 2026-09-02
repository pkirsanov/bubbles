# BUG-038 Expected Behavior - Train Metadata Assignment

## Outcome Contract

- **Intent:** Give `bubbles.train` one authenticated direct-only metadata mutation path while retaining exact, wildcard, default-deny, and exclusion-aware mode admission.
- **Success Signal:** The authenticated active top-level `bubbles.train` runner assigns a declared train without changing train configuration, bundles, manifests, or release lifecycle state. A wildcard-admitted non-train runner is recognized as admitted but cannot mutate.
- **Hard Constraints:** Admission is not mutation authority. Explicit exclusions override wildcard grants. `BUBBLES_AGENT_NAME` is not authentication or ownership proof. Unknown trains, missing or wrong runners, ownership mismatches, and owned-field mismatches refuse without writes. Assignment never means cut or promotion. Canonical fields remain `releaseTrain` and optional `flagsIntroduced`; `releaseTrainRef` is forbidden.
- **Failure Condition:** A non-train top-level runner mutates, an environment declaration impersonates the owner, wildcard admission is treated as mutation authority, an excluded mode is admitted, the direct owner cannot assign metadata, an unknown train is accepted, or unrelated release surfaces change.

## Actors

- **Release packet owner:** classifies release intent and supplies grounded planning context.
- **Train metadata owner:** validates and writes `releaseTrain` and explicit `flagsIntroduced` metadata.
- **Workflow registry:** evaluates exact, wildcard, default-deny, and exclusion-aware admission without granting mutation ownership.
- **Authenticated active top-level runner:** supplies the non-spoofable runner identity used by the apply boundary.
- **Ownership registry:** requires `bubbles.train` to remain the sole `release-train-state` owner.
- **Mode-owned-field authority:** requires every requested field to appear in the assignment mode's `ownedStateFields`.
- **Transition guard:** consumes the resulting metadata without granting mutation authority.

## User Scenarios

### Scenario 1 - Exact owner assigns an existing train

```gherkin
Given a spec state needs a grounded train assignment
And the requested train exists in config/release-trains.yaml
When bubbles.train runs the train metadata assignment action
Then state.json records that train in releaseTrain
And no other state field changes
```

### Scenario 2 - Unknown train refuses

```gherkin
Given the requested train is absent from config/release-trains.yaml
When bubbles.train runs the train metadata assignment action
Then the operation refuses without changing state.json
And the refusal names the unknown train
```

### Scenario 3 - Configuration and bundles remain unchanged

```gherkin
Given release-train config and per-train flag bundles have known digests
When bubbles.train assigns spec train metadata
Then every config and feature-flag bundle digest remains unchanged
And no config bundle is generated
```

### Scenario 4 - Assignment has no lifecycle semantics

```gherkin
Given no candidate cut or deployment promotion was requested
When bubbles.train assigns spec train metadata
Then no tag, build, manifest pointer, train phase, or lifecycle status changes
And the result does not claim cut, promote, rollback, or retire
```

### Scenario 5 - Wildcard admission does not authorize mutation

```gherkin
Given a non-train top-level runner is admitted by a wildcard grant
When it requests train metadata assignment
Then admission is recognized but apply is refused
And state.json remains unchanged
```

### Scenario 6 - Explicit flags metadata stays bounded

```gherkin
Given bubbles.train receives an explicit flagsIntroduced list with an existing train
When it assigns train metadata
Then it writes only releaseTrain and flagsIntroduced
And it does not edit any feature-flag bundle
```

### Scenario 7 - Explicit exclusion overrides wildcard admission

```gherkin
Given a runner has a wildcard grant and an explicit exclusion for release-train-assign-metadata
When workflow authorization evaluates the request
Then admission is refused as excluded
And state.json remains unchanged
```

### Scenario 8 - Environment declaration cannot impersonate bubbles.train

```gherkin
Given the authenticated active top-level runner is not bubbles.train
And BUBBLES_AGENT_NAME says bubbles.train
When apply requests train metadata assignment
Then authorization refuses because the environment declaration is not authentication
And state.json remains unchanged
```

### Scenario 9 - Missing runner refuses

```gherkin
Given no authenticated active top-level runner is available
When apply requests train metadata assignment
Then authorization refuses before mutation
And state.json remains unchanged
```

### Scenario 10 - Ownership mismatch refuses

```gherkin
Given bubbles.train is the authenticated active top-level runner
And the ownership registry does not name it as the sole release-train-state owner
When apply requests train metadata assignment
Then authorization refuses without changing state.json
```

### Scenario 11 - Owned-field mismatch refuses

```gherkin
Given bubbles.train is the authenticated active top-level runner
And the assignment mode does not own one requested canonical field
When apply requests that field mutation
Then authorization refuses without changing state.json
```

### Scenario 12 - Dry-run reports without mutation

```gherkin
Given a syntactically valid assignment request and readable authorities
When the helper runs in dry-run mode
Then it reports the candidate and any admission or ownership finding
And it does not modify state.json or create a replacement candidate
```

### Scenario 13 - Identical apply is an atomic no-op

```gherkin
Given state.json already contains the requested canonical metadata
When bubbles.train repeats the same authorized apply
Then state.json bytes, mode, and modification time remain unchanged
```

## Functional Requirements

- **FR-B038-001:** The registry must define one narrowly named metadata assignment mode.
- **FR-B038-002:** The v7 tuple must be `ship action:assign target:train-metadata`.
- **FR-B038-003:** The backing mode key must be `release-train-assign-metadata`.
- **FR-B038-004:** Mode admission must use the existing exact, wildcard, default-deny, and exclusion-aware `workflowModeGrants` semantics. Explicit exclusions must override exact or wildcard admission.
- **FR-B038-005:** The operation must require the target train to exist in `config/release-trains.yaml`.
- **FR-B038-006:** The operation may change only `state.json.releaseTrain` and explicitly supplied `state.json.flagsIntroduced`.
- **FR-B038-007:** The operation must preserve top-level status, certification, execution metadata, and every unrelated state field.
- **FR-B038-008:** The operation must not modify release-train config, feature-flag bundles, generated config bundles, or manifests.
- **FR-B038-009:** The operation must not invoke build, cut, promote, rollback, retire, deploy, or pointer-swap behavior.
- **FR-B038-010:** Unknown trains must refuse before any write.
- **FR-B038-011:** The agent contract and operator documentation must distinguish assignment from release lifecycle operations.
- **FR-B038-012:** Apply must succeed only when the authenticated active top-level runner is exactly `bubbles.train`, the ownership registry names `bubbles.train` as the sole `release-train-state` owner, and the mode owns every requested field. `BUBBLES_AGENT_NAME` and wildcard admission must not establish mutation authority.
- **FR-B038-013:** Existing train lifecycle modes and aliases must retain their current behavior.
- **FR-B038-014:** Dry-run must report the candidate plus admission or ownership findings without mutating the destination or leaving a replacement candidate.
- **FR-B038-015:** Adversarial selftests must independently prove wildcard admission, exclusion precedence, wrong and missing runner refusal, ownership mismatch refusal, owned-field mismatch refusal, and direct-owner success.

## Success Criteria

- The new v7 tuple resolves to the metadata assignment mode.
- An existing train can be written by `bubbles.train` in a hermetic fixture.
- An unknown train exits nonzero and leaves fixture bytes unchanged.
- Config, flag bundle, and manifest fixture digests remain unchanged.
- No build, tag, deployment, pointer-swap, or train-phase marker appears.
- Wildcard admission is recognized but mutation by a non-train top-level runner is refused.
- Explicit exclusion overrides wildcard admission.
- Wrong and missing active runners, spoofed `BUBBLES_AGENT_NAME`, ownership mismatch, and owned-field mismatch refuse without writes.
- Existing cut, promote, rollback, retire, and status aliases still resolve.
- Focused authorization, helper, alias, syntax, and portability checks pass.
