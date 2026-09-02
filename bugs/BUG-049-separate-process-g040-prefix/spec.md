# BUG-049 Expected Behavior - Complete G040 PR Tokens

## Outcome Contract

- **Intent:** Detect real pull-request deferrals without matching words that begin with `pr`.
- **Success Signal:** `separate process` passes, while complete separate-PR wording still blocks.
- **Hard Constraints:** Case-insensitive matching remains. Existing genuine deferral terms retain their behavior.
- **Failure Condition:** Prefixes such as `process` trigger G040, or genuine PR deferral wording becomes accepted.

## Actors

- **Artifact author:** describes completed technical behavior.
- **Transition guard:** distinguishes technical prose from incomplete-work admissions.
- **Validation agent:** consumes the guard result without rewriting prose.

## User Scenarios

### Scenario 1 - Separate process is ordinary prose

```gherkin
Given a completed scope states that a verifier runs in a separate process
When G040 scans the artifact
Then it reports no deferral hit for that phrase
```

### Scenario 2 - Separate PR remains blocking

```gherkin
Given a scope states that work moves to a separate PR
When G040 scans the artifact
Then the transition is blocked for deferral language
```

### Scenario 3 - Separate pull request remains blocking

```gherkin
Given a report states that work moves to a separate pull request
When G040 scans the artifact
Then the transition is blocked for deferral language
```

### Scenario 4 - Prefix collision stays closed under case variation

```gherkin
Given an artifact uses Separate Process or SEPARATE PROCESS
When the case-insensitive scan runs
Then neither phrase is classified as a PR deferral
```

## Functional Requirements

- **FR-B049-001:** The abbreviated `PR` alternative must match a complete token.
- **FR-B049-002:** The full `pull request` phrase must match as a complete phrase.
- **FR-B049-003:** Case-insensitive matching must remain active.
- **FR-B049-004:** Words beginning with `pr`, including `process`, must not match the PR alternative.
- **FR-B049-005:** Existing real deferral fixtures must retain their blocking verdicts.
- **FR-B049-006:** The fix must remain portable under the repository's supported grep implementations.

## Acceptance Criteria

- SCN-B049-001 and SCN-B049-004 emit no G040 deferral hit.
- SCN-B049-002 and SCN-B049-003 emit the expected G040 block.
- Existing skip, deferred-work, placeholder, and certifying-window cases remain unchanged.
