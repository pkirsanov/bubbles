# BUG-033 Expected Behavior — Receipt Identity Normalization

## Outcome Contract

Check 43 must compare the program that produced a receipt, not transparent command wrappers. It must preserve distinct child identities and reject ambiguous wrapper syntax.

## Required Behavior

### Target grouping

- Repeated receipts for one command identity may name the same target.
- Distinct command identities must name distinct non-empty targets to qualify as deterministic siblings.
- Every receipt must retain independent execution provenance.

### Shell, environment, and assignment wrappers

- Supported shell, `env`, and leading assignment wrappers are transparent.
- Wrapper removal must expose the child program and its identity arguments.
- Distinct child programs remain distinct after normalization.

### Timeout wrappers

An exact-basename `timeout` or `gtimeout` wrapper is transparent only when its full prefix matches this grammar:

1. Zero or more accepted options may appear before the duration.
2. Accepted options are `-k D`, `--kill-after=D`, `--kill-after D`, `-s S`, `--signal=S`, `--signal S`, `-v`, `--verbose`, `--foreground`, `--preserve-status`, and `--`.
3. Exactly one required duration follows the options.
4. At least one child argument follows the duration.
5. The duration and option values must satisfy the supported timeout value grammar.

Unknown options, malformed values, missing values, missing durations, and missing child arguments remain opaque. Near-miss executable names also remain opaque.

## Scenarios

### SCN-B033-001 — Repeated honest reruns

Repeated receipts for one validator over two targets qualify as deterministic siblings when every receipt has independent provenance.

### SCN-B033-002 — Same target across distinct identities

Two command identities over one target remain a clone finding when they share substantive output.

### SCN-B033-003 — Transparent shell wrappers

Equivalent shell, `env`, and assignment spellings resolve to one command family and identity.

### SCN-B033-004 — Distinct wrapped programs

Shell and environment wrappers do not collapse different child programs.

### SCN-B033-005 — Transparent timeout wrapper

A bare child and the same child behind valid `timeout` or `gtimeout` syntax resolve to the same identity.

### SCN-B033-006 — Short verbose timeout option

`timeout -v <duration> <child...>` is accepted as a transparent wrapper.

### SCN-B033-007 — Opaque malformed timeout syntax

Unknown or malformed timeout syntax retains `timeout` or `gtimeout` as the command family.

### SCN-B033-008 — Distinct timeout children

Different child programs remain distinct when both use accepted timeout wrappers and share substantive output.

### SCN-B033-009 — Persistent session lock path

The exact `.specify/memory/bubbles.session.json.flock` path is ignored. The session JSON and every other memory-state path remain visible to Git.

## Acceptance Criteria

- Whole-guard cases accept equivalent bare and timeout-wrapped child commands.
- Whole-guard cases refuse different children that share one output.
- Whole-guard cases accept the short `-v` option.
- Whole-guard cases keep malformed and unknown timeout forms opaque.
- The exact persistent flock path is ignored without broadening the memory-state ignore surface.
- Earlier target-grouping and wrapper evidence remains unchanged and distinguishable from the timeout facet evidence.
- Timeout-facet DoD items remain incomplete until current-session red and green executions exist.
