# User Validation - BUG-061 ShellCheck Zero-Warning Gate

Links: [report.md](report.md)

## Automation Readiness

- [ ] Each of the five focused ShellCheck commands exits zero at severity `warning`.
- [ ] The combined five-file command exits zero with no warning records.
- [ ] Research, usage-adapter, and migration behavior checks pass.
- [ ] The canonical tracked-shell warning gate passes.
- [ ] GNU/Linux and macOS portability checks pass.
- [ ] Broader framework validation passes.

Automation readiness does not grant human acceptance.

## Checklist

- [ ] Research adapters and the runner resolve their own directories with CDPATH explicitly disabled.
- [ ] The usage reference adapter behaves the same without the unread digest assignment.
- [ ] The migration fallback fixture still clears XDG_RUNTIME_DIR and rejects the hostile directory.
- [ ] ShellCheck reports no warning-level finding on any assigned surface.
- [ ] Existing IMP-056 and BUG-038 ownership groups remain unchanged.

## Human Acceptance Record

- acceptedBy:
- acceptedAt:
- method:
- record:

## Goal

- Goal: Restore a truthful zero-warning framework shell gate without changing command behavior.
- Success signal: Focused and aggregate ShellCheck checks are clean, related behavior checks pass, and excluded owner bytes are unchanged.

## Journey Steps

| Step | User Intent | Observed | Evidence | Friction |
| --- | --- | --- | --- | --- |

## Open Refinements

None recorded during filing.