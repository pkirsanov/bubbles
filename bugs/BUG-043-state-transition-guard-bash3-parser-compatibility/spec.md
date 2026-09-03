# BUG-043 Expected Behavior - Bash Parser Compatibility

## Outcome Contract

- **Intent:** Restore parser compatibility for the transition guard.
- **Success signal:** Bash 3 and Bash 5 both accept the source with `-n`.
- **Hard constraint:** Supported-runtime transition semantics remain unchanged.
- **Failure condition:** Either parser rejects the source or the fix weakens a guard verdict.

## Actors

- **Framework maintainer:** identifies and repairs the incompatible construct.
- **Transition guard caller:** requires a guard that starts before evaluating state.
- **Downstream installer:** projects validated source bytes into consumer repositories.
- **Validation agent:** certifies parser parity and semantic preservation.

## User Scenarios

### SCN-B043-001 - Source guard parses under Bash 3 and Bash 5

```gherkin
Given the canonical transition guard from the frozen source revision
When syntax validation runs with real Bash 3 and real Bash 5 interpreters
Then both interpreters accept the same source bytes
```

### SCN-B043-002 - The regression rejects the incompatible grammar

```gherkin
Given a temporary guard copy with the exact incompatible construct restored
When the dual-interpreter syntax regression runs
Then the Bash 3 leg exposes the parser divergence
And the production guard remains accepted by both interpreters
```

### SCN-B043-003 - Supported-runtime guard behavior remains stable

```gherkin
Given the parser-compatible source guard
When the existing transition guard selftest runs under supported Bash
Then every existing transition verdict remains unchanged
And no check is bypassed or skipped
```

### SCN-B043-004 - Downstream installation receives the repaired guard

```gherkin
Given a release manifest generated from the validated source tree
When Bubbles installs into a temporary downstream repository
Then the installed transition guard matches the source guard bytes
And the installed copy passes the Bash 3 and Bash 5 syntax matrix
```

## Functional Requirements

- **FR-B043-001:** The source guard must pass `/bin/bash -n` on the required macOS validation host.
- **FR-B043-002:** The source guard must pass `/opt/homebrew/bin/bash -n` on the same host.
- **FR-B043-003:** Investigation must identify the first incompatible grammar construct, not only the reported recovery line.
- **FR-B043-004:** The repair must use a Bash 3 parseable form with equivalent supported-runtime semantics.
- **FR-B043-005:** The regression must execute both real interpreters against identical file bytes.
- **FR-B043-006:** A mutation must restore the incompatible construct and prove the regression detects it.
- **FR-B043-007:** The existing transition guard selftest must pass under the supported Bash runtime.
- **FR-B043-008:** The fix must not add a bypass, silent fallback, or weakened verdict.
- **FR-B043-009:** The release manifest must be regenerated through `bubbles/scripts/generate-release-manifest.sh`.
- **FR-B043-010:** Installer verification must compare the installed guard with the validated source bytes.
- **FR-B043-011:** The installed guard must pass the same dual-interpreter syntax matrix.
- **FR-B043-012:** Downstream repositories must receive the repair only through install or upgrade.
- **FR-B043-013:** Direct Bash 3 runtime support remains outside this parser-only contract.
- **FR-B043-014:** The implementation must stay inside the boundary defined in [design.md](design.md).

## Non-Functional Requirements

- **NFR-B043-001:** Every command must use a finite timeout.
- **NFR-B043-002:** Regression fixtures must use private temporary directories and remove them on exit.
- **NFR-B043-003:** The parse matrix must report each interpreter path, version, exit code, and stderr.
- **NFR-B043-004:** Generated artifacts must remain deterministic.
- **NFR-B043-005:** The repair must preserve Linux and macOS source portability.

## Acceptance Criteria

- The persistent regression fails on the frozen pre-fix bytes for the supplied parser mismatch.
- Both real interpreters accept the repaired source bytes.
- The adversarial mutation recreates the interpreter divergence.
- Existing guard semantics pass their focused and aggregate selftests.
- A temporary downstream install contains the repaired source bytes.
- Release validation passes before certification.

## Related Artifacts

- [Bug record](bug.md)
- [Investigation and fix design](design.md)
- [Delivery scope](scopes.md)
- [Evidence record](report.md)
