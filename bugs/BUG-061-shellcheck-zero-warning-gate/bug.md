# Bug: BUG-061 Tracked ShellCheck Warnings Break the Zero-Warning Gate

- **Filed:** 2026-09-02
- **Severity:** high
- **Disposition:** open in-repository framework defect
- **Source:** BUG-050 regression-phase finding routing
- **Affects:** five tracked shell surfaces listed below

## Summary

Five currently unowned ShellCheck warnings make the warning-level zero-finding
framework gate nonzero. Four intentional empty environment assignments use the
ambiguous `NAME= command` spelling that ShellCheck reports as SC1007. One usage
adapter declares an unexported constant that it never reads, which ShellCheck
reports as SC2034.

## Packet Route

This finding-routing node requires a persisted full source bug packet. The
packet groups only the five unowned warning instances because they share one
operational failure: tracked warning-level ShellCheck is not clean. Production
and test changes belong to the implementation and test owners.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - a required framework regression gate cannot reach zero warnings
- [ ] Medium - degraded behavior with a reliable release path
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Confirmed by current-session focused reproduction
- [x] Root cause localized to five tracked assignments
- [ ] Persistent regression is green
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Explicit Findings

| Finding | Surface | Location | Rule | Current construct |
| --- | --- | --- | --- | --- |
| F-B061-001 | research disabled adapter | `bubbles/adapters/research/disabled.sh` | SC1007 | `CDPATH= cd` |
| F-B061-002 | research local-command adapter | `bubbles/adapters/research/local-command.sh` | SC1007 | `CDPATH= cd` |
| F-B061-003 | usage reference adapter | `bubbles/adapters/usage/reference-test.sh` | SC2034 | unread `EMPTY_DIGEST` assignment |
| F-B061-004 | research runner | `bubbles/scripts/research-run.sh` | SC1007 | `CDPATH= cd` |
| F-B061-005 | scenario-manifest migration selftest | `bubbles/scripts/scenario-manifest-migrate-selftest.sh` | SC1007 | `XDG_RUNTIME_DIR= python3` |

## Reproduction Steps

1. Use ShellCheck 0.11.0 from the repository command environment.
2. Invoke `shellcheck -S warning -f gcc` with exactly the five affected files.
3. Observe four SC1007 warnings and one SC2034 warning.
4. Observe exit code 1.

The exact current-session command, output, and full-output hash are recorded in
[report.md](report.md#exact-five-warning-before-fix).

## Expected Behavior

- Every tracked shell surface is clean at ShellCheck severity `warning`.
- Intentional empty environment values are explicit and portable.
- The usage adapter contains no unread shell assignment.
- Removing the warnings does not change adapter, runner, migration, or test behavior.
- No inline disable, severity downgrade, allowlist, or bypass hides a warning.

## Actual Behavior

The focused command exits 1 with exactly these findings:

```text
bubbles/adapters/research/disabled.sh:4:21: SC1007
bubbles/adapters/research/local-command.sh:4:21: SC1007
bubbles/adapters/usage/reference-test.sh:14:1: SC2034
bubbles/scripts/research-run.sh:4:21: SC1007
bubbles/scripts/scenario-manifest-migrate-selftest.sh:619:45: SC1007
```

## Root Cause

The gate correctly enforces zero warning-level findings. The affected source
uses warning-producing syntax despite having simple intent:

- `CDPATH= cd` and `XDG_RUNTIME_DIR= python3` rely on an empty assignment before
  a command. ShellCheck treats the space after `=` as ambiguous and emits SC1007.
- `EMPTY_DIGEST` is a shell-local assignment with no read in
  `reference-test.sh`, so ShellCheck emits SC2034.

The defect is in the five tracked source constructs. It is not a defect in the
gate, its severity floor, or ShellCheck configuration.

## Impact

- The repository warning-level ShellCheck gate remains nonzero.
- BUG-050 aggregate regression cannot treat the shell surface as clean.
- Release validation cannot honestly claim a zero-warning framework surface.
- The warnings obscure newly introduced ShellCheck findings in aggregate output.

## Environment

- Repository: canonical Bubbles source worktree
- Branch: `fix/ozhiva-transition-unblock`
- Reproduced commit: `8be79548c10f671bc14a89a8827d91752c3d83fd`
- Platform: macOS
- ShellCheck: 0.11.0
- Repository decision: `rb:vscode-2913ac96e8446707d06d7b480573b88f:4`

## Change Boundary

### Included source surfaces

- `bubbles/adapters/research/disabled.sh`
- `bubbles/adapters/research/local-command.sh`
- `bubbles/adapters/usage/reference-test.sh`
- `bubbles/scripts/research-run.sh`
- `bubbles/scripts/scenario-manifest-migrate-selftest.sh`

### Included control surfaces

- `bugs/BUG-061-shellcheck-zero-warning-gate/**`
- `BUGS.md`
- `bubbles/release-manifest.json` only after a validated source change requires regeneration

### Excluded ownership groups

- `bubbles/adapters/dispatch/reference-broker.sh` SC2034 belongs to
  `improvements/IMP-056-fail-closed-cross-repository-dispatch-authorization.md`.
- The three SC2034 findings in
  `bubbles/scripts/release-train-metadata-assign-selftest.sh` belong to
  `bugs/BUG-038-train-metadata-assignment-mode-gap/`.
- No warning from either ownership group may be fixed, copied, reclassified, or
  used to widen BUG-061.

### Other exclusions

- `bubbles/scripts/shellcheck-lint.sh` policy or severity changes
- ShellCheck disable directives or warning allowlists
- Broad shell cleanup outside the five listed surfaces
- Framework validation execution during packet filing
- Downstream installed copies

## Related

- [BUG-050 transition-local receipt admission](../BUG-050-transition-local-receipt-admission/bug.md)
- [BUG-038 train metadata assignment](../BUG-038-train-metadata-assignment-mode-gap/bug.md)
- [IMP-056 dispatch authorization](../../improvements/IMP-056-fail-closed-cross-repository-dispatch-authorization.md)
- [Canonical ShellCheck gate](../../bubbles/scripts/shellcheck-lint.sh)

## Filing Evidence

**Claim Source:** executed

The focused current-session reproduction exited 1 with exactly five warnings.
Its full output SHA-256 is
`c7f1dc6cd8750450fbd8d4ca3410e2e3f45da28163207641f4940e715dab9261`.
No production or test source was modified during filing.