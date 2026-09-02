# BUG-033 Expected Behavior — Receipt Identity Normalization

## Outcome Contract

**Intent:** Check 43 must accept honest reruns and equivalent transparent-wrapper spellings as evidence from the same producing program without weakening its ability to detect reused output across incompatible command identities. The persistent session lock may remain untracked, but the session state itself must remain visible.

**Success Signal:** Repeated receipts with independent provenance are accepted when they represent one command identity over valid targets; supported shell, environment, assignment, `timeout`, and `gtimeout` wrappers normalize to their child identity; incompatible child identities still produce a clone finding; malformed timeout syntax remains opaque; and a Git classification check ignores exactly `.specify/memory/bubbles.session.json.flock` while keeping `.specify/memory/bubbles.session.json` and neighboring memory-state paths visible.

**Hard Constraints:** Independent execution provenance remains mandatory for every receipt. Distinct command identities must retain distinct non-empty targets. Transparent-wrapper normalization is limited to the closed grammar in this specification and must never infer a child from malformed, unknown, attached, clustered, incomplete, or near-miss timeout syntax. Different child programs must remain distinguishable after normalization. The exact flock ignore rule must not broaden to the session JSON or neighboring memory-state paths. Existing provenance checks, empty-output handling, command-family compatibility, category sanity checks, and clone detection must not be weakened.

**Failure Condition:** The repair fails if an honest rerun is still accused of cloning, an unsupported wrapper is attributed to an apparent child, incompatible identities stop refusing shared substantive output, independent provenance is no longer required, or the ignore rule hides session state beyond the exact flock file.

**Non-Goals:** This repair does not redefine receipt provenance, relax clone detection for incompatible identities, accept arbitrary shell or timeout syntax, alter evidence categories, or hide persistent session state.

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

A bare canonical `timeout` or `gtimeout` token is transparent only when its full prefix matches this grammar:

1. Zero or more accepted options may appear before the duration.
2. Accepted options are `-k D`, `--kill-after=D`, `--kill-after D`, `-s S`, `--signal=S`, `--signal S`, `-v`, `--verbose`, `--foreground`, `--preserve-status`, and `--`.
3. Exactly one required duration follows the options.
4. At least one child argument follows the duration.
5. The duration and option values must satisfy the supported timeout value grammar.

Unknown options, malformed values, missing values, missing durations, and missing child arguments remain opaque. Near-miss executable names also remain opaque.

Path-qualified timeout tokens also remain opaque, including apparent system
paths such as `/usr/bin/timeout` and attacker-controlled paths such as
`/tmp/timeout`. A receipt records the command string but carries no authenticated
executable resolution or binary identity. Check 43 therefore cannot establish
that any path-qualified token names the canonical timeout implementation and
must preserve that wrapper identity rather than attribute its output to the
apparent child.

## Scenarios

### SCN-B033-001 — Repeated honest reruns

Repeated receipts for one validator over two targets qualify as deterministic siblings when every receipt has independent provenance.

### SCN-B033-002 — Same target across distinct identities

Two command identities over one target remain a clone finding when they share substantive output.

### SCN-B033-003 — Transparent shell wrappers

Equivalent shell, `env`, and assignment spellings resolve to one command family and identity.

### SCN-B033-004 — Distinct wrapped programs

Shell and environment wrappers do not collapse different child programs.

### SCN-B033-005 — Transparent bare canonical timeout wrapper

A bare child and the same child behind valid bare `timeout` or `gtimeout` syntax resolve to the same identity.

### SCN-B033-006 — Short verbose timeout option

`timeout -v <duration> <child...>` is accepted as a transparent wrapper.

### SCN-B033-007 — Opaque malformed or unverified timeout syntax

Unknown, malformed, near-miss, or path-qualified timeout syntax retains its wrapper identity rather than being attributed to the apparent child.

### SCN-B033-008 — Distinct timeout children

Different child programs remain distinct when both use accepted timeout wrappers and share substantive output.

### SCN-B033-009 — Persistent session lock path

The exact `.specify/memory/bubbles.session.json.flock` path is ignored. The session JSON and every other memory-state path remain visible to Git.

## Acceptance Criteria

- Whole-guard cases accept equivalent bare and timeout-wrapped child commands.
- Bare canonical `timeout` and `gtimeout` are positive controls, while both
	path-qualified system wrappers and attacker-controlled timeout paths remain
	opaque because the receipt schema cannot authenticate executable resolution.
- Whole-guard cases refuse different children that share one output.
- Whole-guard cases accept the short `-v` option.
- Whole-guard cases keep malformed and unknown timeout forms opaque.
- The exact persistent flock path is ignored without broadening the memory-state ignore surface.
- Earlier target-grouping and wrapper evidence remains unchanged and distinguishable from the timeout facet evidence.
- Timeout-facet DoD items remain incomplete until current-session red and green executions exist.
