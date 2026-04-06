# Bug Spec: [BUG-001] Shell-Heavy Reality Scan Discovery Gap

## Problem Statement
Scope 05 Review-Only Interop Intake is implemented through legitimate shell, YAML, JSON, manifest, and docs surfaces. The current framework reality scan only discovers backticked paths with code-language extensions, so the scope becomes invisible to certification even when `scopes.md` lists the correct files.

## Outcome Contract
**Intent:** Framework validation must support honest discovery of legitimate shell-heavy implementation inventories. Certification should work for real scope surfaces without forcing fake wrapper files or artificial language shims.
**Success Signal:** Running `implementation-reality-scan.sh` against the Scope 05 feature packet resolves the declared on-disk implementation files and proceeds to content scanning instead of failing with `ZERO_FILES_RESOLVED`.
**Hard Constraints:** Legitimate `.sh`, `.yaml`, `.yml`, `.json`, and docs-backed framework surfaces may be implementation-bearing when the scope declares them. Truly missing inventories must still block. Temporary shims, wrapper files, or fake supported-language entries are forbidden. The fix must follow upstream-first framework ownership.
**Failure Condition:** Scope 05 still requires fabricated wrapper files to pass discovery, or the scanner continues to report `ZERO_FILES_RESOLVED` for the real on-disk inventory.

## Goals
- Make shell-heavy framework scopes discoverable by the reality scan when the declared files exist on disk.
- Preserve the zero-file block for scopes that genuinely do not declare any real implementation files.
- Keep framework immutability and upstream ownership intact.

## Non-Goals
- Loosening content checks after discovery.
- Introducing fake wrapper code, placeholder files, or synthetic coverage.
- Applying an ad hoc local patch during Scope 05 delivery.

## Requirements
- Discovery logic must resolve legitimate on-disk implementation paths declared in `scopes.md` or `design.md` even when they are shell, registry, manifest, or docs-heavy framework surfaces.
- The scan must continue to fail loudly when declared implementation files are absent from disk.
- Validation support for shell-heavy scopes must come from a real upstream framework fix, not from workaround artifacts.
- The fix must not depend on temporary shims or artificial supported-language wrappers.

## User Scenarios (Gherkin)

```gherkin
Scenario: Real shell-heavy inventories are discovered honestly
  Given a scope lists real on-disk implementation files that are primarily .sh, .yaml, .json, or documentation-backed framework surfaces
  When implementation-reality-scan runs against that scope
  Then the scanner resolves those files and scans them instead of raising ZERO_FILES_RESOLVED

Scenario: Missing inventories still fail honestly
  Given a scope does not list any real on-disk implementation files
  When implementation-reality-scan runs against that scope
  Then the scanner still blocks explicitly instead of passing on synthetic wrappers or fabricated coverage
```

## Acceptance Criteria
- Scope 05 style inventories are discoverable without adding fake code-language files.
- The zero-file block remains meaningful for genuinely missing inventories.
- The bug fix path keeps framework-managed script ownership upstream and forbids temporary shims.