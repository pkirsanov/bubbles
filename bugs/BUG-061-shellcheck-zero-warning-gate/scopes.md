# BUG-061 Scopes

Links: [spec.md](spec.md) | [design.md](design.md) | [report.md](report.md) | [uservalidation.md](uservalidation.md)

## Scope 1 - Restore the Tracked Shell Zero-Warning Contract

**Status:** In Progress
**Priority:** P1
**Depends On:** None

### Gherkin Scenarios

```gherkin
Scenario: SCN-B061-001 Disabled research adapter is warning-clean
  Given the adapter intentionally disables CDPATH during directory resolution
  When warning-level ShellCheck inspects disabled.sh
  Then no SC1007 finding is emitted
  And adapter-disabled behavior remains unchanged

Scenario: SCN-B061-002 Local-command research adapter is warning-clean
  Given the adapter intentionally disables CDPATH during directory resolution
  When warning-level ShellCheck inspects local-command.sh
  Then no SC1007 finding is emitted
  And adapter-local-command behavior remains unchanged

Scenario: SCN-B061-003 Usage reference adapter is warning-clean
  Given the adapter declares only values consumed by its operations
  When warning-level ShellCheck inspects reference-test.sh
  Then no SC2034 finding is emitted for EMPTY_DIGEST
  And usage adapter behavior remains unchanged

Scenario: SCN-B061-004 Research runner is warning-clean
  Given the runner intentionally disables CDPATH during directory resolution
  When warning-level ShellCheck inspects research-run.sh
  Then no SC1007 finding is emitted
  And research runtime dispatch remains unchanged

Scenario: SCN-B061-005 Migration fallback fixture is warning-clean
  Given the fixture intentionally clears XDG_RUNTIME_DIR
  When warning-level ShellCheck inspects scenario-manifest-migrate-selftest.sh
  Then no SC1007 finding is emitted
  And the hostile fallback-directory assertion remains unchanged
```

### Implementation Plan

1. Re-run the exact five-file command and retain the pre-fix nonzero evidence.
2. Make empty `CDPATH` explicit in the three research entrypoints.
3. Remove only the unread `EMPTY_DIGEST` assignment from the usage reference adapter.
4. Make empty `XDG_RUNTIME_DIR` explicit in the migration selftest fixture.
5. Run each one-file ShellCheck scenario and the combined five-file command.
6. Run affected behavior-preservation selftests.
7. Run the canonical tracked-shell warning gate and portability checks.
8. Prove the diff is limited to the declared boundary and excluded owner bytes are unchanged.
9. Regenerate the release manifest after the validated source delta.
10. Route the broader framework suite and certification to their owning phases.

### Implementation Files

- `bubbles/adapters/research/disabled.sh`
- `bubbles/adapters/research/local-command.sh`
- `bubbles/adapters/usage/reference-test.sh`
- `bubbles/scripts/research-run.sh`
- `bubbles/scripts/scenario-manifest-migrate-selftest.sh`

### Change Boundary

**Allowed paths:**

- the five Implementation Files above
- `bugs/BUG-061-shellcheck-zero-warning-gate/**`
- `BUGS.md`
- `bubbles/release-manifest.json` after validated source changes

**Excluded paths:** `bubbles/adapters/dispatch/reference-broker.sh`,
`bubbles/scripts/release-train-metadata-assign-selftest.sh`, ShellCheck gate
policy, unrelated shell assets, downstream installations, and every other bug
or improvement artifact.

### Test Plan

| ID | Scenario | Test | Type | File/Location | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- |
| T1 | SCN-B061-001 | Focused SC1007 regression for disabled adapter | functional | `bubbles/adapters/research/disabled.sh` | `shellcheck -S warning -f gcc bubbles/adapters/research/disabled.sh` | No |
| T2 | SCN-B061-002 | Focused SC1007 regression for local-command adapter | functional | `bubbles/adapters/research/local-command.sh` | `shellcheck -S warning -f gcc bubbles/adapters/research/local-command.sh` | No |
| T3 | SCN-B061-003 | Focused SC2034 regression for usage reference adapter | functional | `bubbles/adapters/usage/reference-test.sh` | `shellcheck -S warning -f gcc bubbles/adapters/usage/reference-test.sh` | No |
| T4 | SCN-B061-004 | Focused SC1007 regression for research runner | functional | `bubbles/scripts/research-run.sh` | `shellcheck -S warning -f gcc bubbles/scripts/research-run.sh` | No |
| T5 | SCN-B061-005 | Focused SC1007 regression for migration fallback fixture | functional | `bubbles/scripts/scenario-manifest-migrate-selftest.sh` | `shellcheck -S warning -f gcc bubbles/scripts/scenario-manifest-migrate-selftest.sh` | No |
| T6 | Supporting behavior | Research adapter and runner behavior preservation | regression | `bubbles/scripts/research-admission-cli-selftest.sh` | `bash bubbles/scripts/research-admission-cli-selftest.sh` | No |
| T7 | Supporting behavior | Usage adapter behavior preservation | regression | `bubbles/scripts/usage-adapter-v2-selftest.sh` | `bash bubbles/scripts/usage-adapter-v2-selftest.sh` | No |
| T8 | Supporting behavior | Migration behavior preservation | regression | `bubbles/scripts/scenario-manifest-migrate-selftest.sh` | `bash bubbles/scripts/scenario-manifest-migrate-selftest.sh` | No |
| T9 | Aggregate | Regression E2E: tracked warning-level ShellCheck gate | Regression E2E | `bubbles/scripts/shellcheck-lint.sh` | `bash bubbles/scripts/shellcheck-lint.sh` | No |
| T10 | Aggregate | GNU/Linux and macOS portability | regression | `bubbles/scripts/macos-portability-guard.sh` | canonical source portability command over the five changed files | No |
| T11 | Aggregate | Broader framework regression | Regression E2E | `bubbles/scripts/cli.sh` | `bash bubbles/scripts/cli.sh framework-validate` | No |

Actual executions must use the available finite process supervisor without
changing the canonical inner command.

### Definition of Done

- [x] The exact five-warning pre-fix subset is reproduced on current bytes. -> Evidence: [Exact five-warning before fix](report.md#exact-five-warning-before-fix) (**Phase:** bug; **Claim Source:** executed)
- [x] Every warning is mapped one-to-one to an in-scope source construct. -> Evidence: [Source occurrence inventory](report.md#source-occurrence-inventory) (**Phase:** bug; **Claim Source:** interpreted)
- [x] SCN-B061-001 passes with explicit empty `CDPATH` and unchanged disabled-adapter behavior. -> Evidence: [Focused ShellCheck GREEN](report.md#focused-shellcheck-green) and [Behavior Preservation](report.md#behavior-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B061-002 passes with explicit empty `CDPATH` and unchanged local-command behavior. -> Evidence: [Focused ShellCheck GREEN](report.md#focused-shellcheck-green) and [Behavior Preservation](report.md#behavior-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B061-003 passes with no unread `EMPTY_DIGEST` assignment and unchanged usage behavior. -> Evidence: [Focused ShellCheck GREEN](report.md#focused-shellcheck-green) and [Behavior Preservation](report.md#behavior-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B061-004 passes with explicit empty `CDPATH` and unchanged research dispatch. -> Evidence: [Focused ShellCheck GREEN](report.md#focused-shellcheck-green) and [Behavior Preservation](report.md#behavior-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] SCN-B061-005 passes with explicit empty `XDG_RUNTIME_DIR` and unchanged fallback assertion. -> Evidence: [Focused ShellCheck GREEN](report.md#focused-shellcheck-green) and [Behavior Preservation](report.md#behavior-preservation) (**Phase:** implement; **Claim Source:** executed)
- [x] No inline disable, allowlist, severity downgrade, or bypass hides any finding. -> Evidence: [Implementation Source Boundary](report.md#implementation-source-boundary) (**Phase:** implement; **Claim Source:** executed)
- [x] The combined five-file command exits zero with no findings. -> Evidence: [Focused ShellCheck GREEN](report.md#focused-shellcheck-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Affected behavior-preservation selftests pass. -> Evidence: [Behavior Preservation](report.md#behavior-preservation) (**Phase:** implement; **Claim Source:** executed)
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
  > **Uncertainty Declaration**
  > **What was attempted:** T1 through T10 executed sequentially after the source repair.
  > **What was observed:** T1-T8 and T10 passed on the final provisioned environment. T9 exited 1 with exactly the four foreign-owned SC2034 warnings.
  > **Why this is uncertain:** The aggregate repository gate is nonzero, and independent test-owner replay has not run.
  > **What would resolve this:** `bubbles.test` independently replays the packet matrix and classifies the four excluded warnings without weakening the gate.
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** T11 was deliberately not run under this implement-phase assignment.
  > **What was observed:** No `framework-validate` result is claimed.
  > **Why this is uncertain:** T11 and independent broader regression belong to `bubbles.test`.
  > **What would resolve this:** `bubbles.test` runs T11 from the committed source SHA and records its actual result.
- [x] GNU/Linux and macOS portability checks pass for all changed shell surfaces. -> Evidence: [Portability GREEN](report.md#portability-green) (**Phase:** implement; **Claim Source:** executed)
- [x] Change Boundary is respected and both excluded ownership groups remain byte-unchanged. -> Evidence: [Implementation Source Boundary](report.md#implementation-source-boundary) (**Phase:** implement; **Claim Source:** executed)
- [x] Release manifest is regenerated from validated source bytes. -> Evidence: [Release Manifest](report.md#release-manifest) (**Phase:** implement; **Claim Source:** executed)
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No certification action was requested from the bug filing owner.
  > **What was observed:** Top-level and certification status remain `in_progress`.
  > **Why this is uncertain:** Only `bubbles.validate` owns certification.
  > **What would resolve this:** Validate the fully tested packet and run the transition guard.
