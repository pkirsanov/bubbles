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
- [ ] SCN-B061-001 passes with explicit empty `CDPATH` and unchanged disabled-adapter behavior.
  > **Uncertainty Declaration**
  > **What was attempted:** Pre-fix ShellCheck reproduction only.
  > **What was observed:** `disabled.sh:4:21` emits SC1007.
  > **Why this is uncertain:** No source repair or post-change adapter check belongs to packet filing.
  > **What would resolve this:** Apply the bounded source repair, run T1 and T6, and record both exits.
- [ ] SCN-B061-002 passes with explicit empty `CDPATH` and unchanged local-command behavior.
  > **Uncertainty Declaration**
  > **What was attempted:** Pre-fix ShellCheck reproduction only.
  > **What was observed:** `local-command.sh:4:21` emits SC1007.
  > **Why this is uncertain:** No source repair or post-change adapter check belongs to packet filing.
  > **What would resolve this:** Apply the bounded source repair, run T2 and T6, and record both exits.
- [ ] SCN-B061-003 passes with no unread `EMPTY_DIGEST` assignment and unchanged usage behavior.
  > **Uncertainty Declaration**
  > **What was attempted:** Source inspection plus pre-fix ShellCheck reproduction.
  > **What was observed:** `reference-test.sh:14:1` emits SC2034.
  > **Why this is uncertain:** The assignment has not been removed and usage behavior has not been re-executed.
  > **What would resolve this:** Apply the bounded removal, then run T3 and T7.
- [ ] SCN-B061-004 passes with explicit empty `CDPATH` and unchanged research dispatch.
  > **Uncertainty Declaration**
  > **What was attempted:** Pre-fix ShellCheck reproduction only.
  > **What was observed:** `research-run.sh:4:21` emits SC1007.
  > **Why this is uncertain:** No source repair or post-change runtime check belongs to packet filing.
  > **What would resolve this:** Apply the bounded source repair, run T4 and T6, and record both exits.
- [ ] SCN-B061-005 passes with explicit empty `XDG_RUNTIME_DIR` and unchanged fallback assertion.
  > **Uncertainty Declaration**
  > **What was attempted:** Pre-fix ShellCheck reproduction only.
  > **What was observed:** `scenario-manifest-migrate-selftest.sh:619:45` emits SC1007.
  > **Why this is uncertain:** No source repair or post-change migration selftest belongs to packet filing.
  > **What would resolve this:** Apply the bounded source repair, then run T5 and T8.
- [ ] No inline disable, allowlist, severity downgrade, or bypass hides any finding.
  > **Uncertainty Declaration**
  > **What was attempted:** The design rejects each suppression path.
  > **What was observed:** Production bytes are unchanged during filing.
  > **Why this is uncertain:** The implementation diff does not exist yet.
  > **What would resolve this:** Scan the final five-file diff and run the canonical warning gate.
- [ ] The combined five-file command exits zero with no findings.
  > **Uncertainty Declaration**
  > **What was attempted:** The same command ran before source changes.
  > **What was observed:** It exited 1 with exactly five findings.
  > **Why this is uncertain:** No post-change command has run.
  > **What would resolve this:** Re-run the exact command after all five repairs.
- [ ] Affected behavior-preservation selftests pass.
  > **Uncertainty Declaration**
  > **What was attempted:** No behavior suite was run because filing cannot implement or validate source fixes.
  > **What was observed:** No behavior result is claimed.
  > **Why this is uncertain:** Static warning removal alone cannot prove command behavior.
  > **What would resolve this:** Run T6, T7, and T8 after the source delta.
- [ ] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior
  > **Uncertainty Declaration**
  > **What was attempted:** Five scenario contracts and focused commands were authored.
  > **What was observed:** Only the pre-fix combined command has executed.
  > **Why this is uncertain:** GREEN scenario evidence does not exist.
  > **What would resolve this:** Execute T1 through T10 after implementation.
- [ ] Broader E2E regression suite passes
  > **Uncertainty Declaration**
  > **What was attempted:** The broader framework command was deliberately not run by this filing owner.
  > **What was observed:** No broad-suite result is claimed.
  > **Why this is uncertain:** T11 belongs to the test and validation phases.
  > **What would resolve this:** Run T11 after focused GREEN evidence exists.
- [ ] GNU/Linux and macOS portability checks pass for all changed shell surfaces.
  > **Uncertainty Declaration**
  > **What was attempted:** Cross-platform syntax constraints were recorded in design.md.
  > **What was observed:** No source delta exists to validate.
  > **Why this is uncertain:** Portability must be checked on final bytes.
  > **What would resolve this:** Run T10 and shell syntax checks after implementation.
- [ ] Change Boundary is respected and both excluded ownership groups remain byte-unchanged.
  > **Uncertainty Declaration**
  > **What was attempted:** The exact allowed and excluded paths were recorded.
  > **What was observed:** Filing changes only packet and registry paths.
  > **Why this is uncertain:** The later source diff has not been produced.
  > **What would resolve this:** Classify every final changed path and compare excluded file digests.
- [ ] Release manifest is regenerated from validated source bytes.
  > **Uncertainty Declaration**
  > **What was attempted:** No manifest generation is warranted before source changes.
  > **What was observed:** The manifest remains untouched by filing.
  > **Why this is uncertain:** Generated inventory must reflect the eventual source delta.
  > **What would resolve this:** Regenerate and check the manifest after focused validation.
- [ ] `bubbles.validate` certifies the packet transition.
  > **Uncertainty Declaration**
  > **What was attempted:** No certification action was requested from the bug filing owner.
  > **What was observed:** Top-level and certification status remain `in_progress`.
  > **Why this is uncertain:** Only `bubbles.validate` owns certification.
  > **What would resolve this:** Validate the fully tested packet and run the transition guard.