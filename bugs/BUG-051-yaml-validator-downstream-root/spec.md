# BUG-051 Expected Behavior - Installed YAML Validator Project Root

## Outcome Contract

- **Intent:** Validate project scenario manifests from source and installed layouts.
- **Success Signal:** Both layouts discover the same top-level and nested manifests.
- **Hard Constraints:** Schema assets remain install-local. Project discovery starts at the consuming repository root.
- **Failure Condition:** An installed validator scans `.github/specs/**` or reports no files when repository manifests exist.

## Actors

- **Downstream maintainer:** installs Bubbles into a product repository.
- **YAML schema validator:** validates framework registries and project scenario manifests.
- **Install provenance selftest:** exercises the installed validator inside a real fixture layout.

## User Scenarios

### Scenario 1 - Installed validator discovers a top-level manifest

```gherkin
Given Bubbles is installed under .github/bubbles in a downstream repository
And a valid scenario manifest exists under specs/<feature>
When the installed YAML schema validator runs
Then it validates the top-level scenario manifest
```

### Scenario 2 - Installed validator discovers a nested bug manifest

```gherkin
Given Bubbles is installed under .github/bubbles in a downstream repository
And a valid scenario manifest exists under specs/<feature>/bugs/<bug>
When the installed YAML schema validator runs
Then it validates the nested bug scenario manifest
```

### Scenario 3 - Invalid installed manifest remains blocking

```gherkin
Given an installed fixture contains a malformed nested scenario manifest
When the installed YAML schema validator runs
Then it exits non-zero with the manifest path in its failure output
```

### Scenario 4 - Source and installed discovery remain equivalent

```gherkin
Given equivalent manifest trees exist in source and installed layouts
When each layout runs its validator
Then both runs report the same discovered manifest count
```

## Functional Requirements

- **FR-B051-001:** The validator must resolve the consuming repository root independently from the framework asset root.
- **FR-B051-002:** The installed validator must scan repository-root `specs/**/scenario-manifest.json`.
- **FR-B051-003:** The recursive scan must include top-level feature and nested bug manifests.
- **FR-B051-004:** The validator must load its schema from the active framework installation.
- **FR-B051-005:** Invalid discovered manifests must retain a non-zero verdict.
- **FR-B051-006:** Source-layout validation must retain its current recursive behavior.
- **FR-B051-007:** The fix must not create or scan `.github/specs` as a substitute project tree.

## Acceptance Criteria

- SCN-B051-001 and SCN-B051-002 report two validated manifests in the installed fixture.
- SCN-B051-003 fails on the named malformed manifest.
- SCN-B051-004 proves source and installed discovery parity.
- Existing framework registry schema checks retain their verdicts.