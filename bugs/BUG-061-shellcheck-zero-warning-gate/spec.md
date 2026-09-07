# BUG-061 Expected Behavior - Zero-Warning Tracked Shell Surface

## Outcome Contract

- **Intent:** Remove the five unowned tracked ShellCheck findings without changing runtime behavior or weakening the gate.
- **Success Signal:** The focused five-file command and the canonical tracked-surface gate both exit zero at severity `warning`.
- **Hard Constraints:** Preserve command behavior, GNU/Linux and macOS portability, the two existing ownership groups, and the warning severity floor.
- **Failure Condition:** Any of the five warnings remains, a new warning appears, behavior changes, or a suppression hides the finding.

## Actors

- **Framework maintainer:** changes only the five assigned source constructs.
- **Regression owner:** runs focused and aggregate warning-level ShellCheck checks.
- **Downstream installer:** receives warning-clean framework shell assets through the generated release manifest.

## User Scenarios

### Scenario 1 - Disabled research adapter uses an explicit empty CDPATH

```gherkin
Scenario: SCN-B061-001 Disabled research adapter is warning-clean
  Given the disabled research adapter resolves its own directory with CDPATH disabled
  When warning-level ShellCheck inspects the tracked adapter
  Then no SC1007 finding is emitted
  And adapter-disabled dispatch behavior remains unchanged
```

### Scenario 2 - Local-command research adapter uses an explicit empty CDPATH

```gherkin
Scenario: SCN-B061-002 Local-command research adapter is warning-clean
  Given the local-command adapter resolves its own directory with CDPATH disabled
  When warning-level ShellCheck inspects the tracked adapter
  Then no SC1007 finding is emitted
  And adapter-local-command dispatch behavior remains unchanged
```

### Scenario 3 - Usage reference adapter has no unread digest assignment

```gherkin
Scenario: SCN-B061-003 Usage reference adapter is warning-clean
  Given the reference usage adapter declares only values consumed by its operations
  When warning-level ShellCheck inspects the tracked adapter
  Then no SC2034 finding is emitted for EMPTY_DIGEST
  And describe, quote, receipt, and verification behavior remains unchanged
```

### Scenario 4 - Research runner uses an explicit empty CDPATH

```gherkin
Scenario: SCN-B061-004 Research runner is warning-clean
  Given the research runner resolves its own directory with CDPATH disabled
  When warning-level ShellCheck inspects the tracked runner
  Then no SC1007 finding is emitted
  And research runtime dispatch behavior remains unchanged
```

### Scenario 5 - Migration selftest passes an explicit empty runtime directory

```gherkin
Scenario: SCN-B061-005 Migration fallback fixture is warning-clean
  Given the hostile fallback fixture intentionally clears XDG_RUNTIME_DIR
  When warning-level ShellCheck inspects the tracked selftest
  Then no SC1007 finding is emitted
  And the fallback lock-directory refusal assertion remains unchanged
```

## Functional Requirements

- **FR-B061-001:** `bubbles/adapters/research/disabled.sh` must be clean at `shellcheck -S warning` without changing adapter behavior.
- **FR-B061-002:** `bubbles/adapters/research/local-command.sh` must be clean at `shellcheck -S warning` without changing adapter behavior.
- **FR-B061-003:** `bubbles/adapters/usage/reference-test.sh` must contain no unread `EMPTY_DIGEST` assignment and must preserve its operation contracts.
- **FR-B061-004:** `bubbles/scripts/research-run.sh` must be clean at `shellcheck -S warning` without changing runtime dispatch behavior.
- **FR-B061-005:** `bubbles/scripts/scenario-manifest-migrate-selftest.sh` must clear `XDG_RUNTIME_DIR` explicitly and preserve the hostile fallback fixture.
- **FR-B061-006:** The focused five-file ShellCheck command must report zero findings and exit zero.
- **FR-B061-007:** The canonical tracked-shell ShellCheck gate must report zero findings and exit zero.
- **FR-B061-008:** No ShellCheck directive, allowlist, severity downgrade, or bypass may satisfy FR-B061-001 through FR-B061-007.
- **FR-B061-009:** Empty assignment syntax must work under Bash on GNU/Linux and macOS without OS detection or GNU-only flags.
- **FR-B061-010:** The reference-broker SC2034 owned by IMP-056 must remain outside this change.
- **FR-B061-011:** The three release-train-metadata SC2034 findings owned by BUG-038 must remain outside this change.
- **FR-B061-012:** The release manifest may change only after the five source repairs and focused checks are complete.

## Acceptance Criteria

- SCN-B061-001 through SCN-B061-005 each have a focused warning-level zero-finding result.
- The exact combined command from the pre-fix reproduction changes from exit 1 with five findings to exit 0 with no findings.
- Related research, usage-adapter, and migration selftests retain their current assertions.
- The canonical `shellcheck-lint.sh` tracked-surface command exits zero.
- Full framework validation passes before certification, but it is not executed by the filing owner.
- A diff boundary check shows no source change outside the five listed files and no change to either excluded ownership group.