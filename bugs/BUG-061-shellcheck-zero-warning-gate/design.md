# BUG-061 Design - Explicit Empty Assignments and Dead Assignment Removal

## Root Cause Analysis

### Investigation Summary

The canonical gate at `bubbles/scripts/shellcheck-lint.sh` collects tracked
shell files and invokes `shellcheck -S warning -f gcc`. It exits 1 when the
captured findings output is non-empty.

A focused current-session invocation used the same severity and formatter on
the five assigned files. It exited 1 with four SC1007 warnings and one SC2034
warning. Source inspection tied every warning to one concrete assignment.

### Root Cause

Three research entrypoints use `CDPATH= cd` to prevent caller CDPATH state from
affecting directory resolution. One migration fixture uses
`XDG_RUNTIME_DIR= python3` to force fallback selection. Both forms intend an
empty environment value, but the unquoted empty right-hand side followed by a
space is precisely the SC1007 warning shape.

The usage reference adapter assigns the empty-stream digest to `EMPTY_DIGEST`
but never reads or exports that shell variable. The digest is not part of any
operation branch in the inspected script, so the assignment is dead and emits
SC2034.

The gate is working as designed. The five source constructs violate its
zero-warning contract.

### Impact Analysis

- **Affected components:** research adapters, research runner, usage reference adapter, scenario-manifest migration selftest.
- **Affected behavior:** static gate outcome; runtime behavior must remain byte-for-byte equivalent at the command contract.
- **Affected users:** framework maintainers and downstream installers blocked by source validation.
- **Ownership boundary:** one IMP-056 warning and three BUG-038 warnings are explicitly excluded.

## Fix Design

### Solution Approach

1. Replace each `CDPATH= cd` prefix with an explicit empty assignment such as
   `CDPATH='' cd`, preserving the command, arguments, substitution, and physical
   path resolution.
2. Remove the unexported unread `EMPTY_DIGEST` assignment from
   `reference-test.sh`; do not replace it with a ShellCheck directive.
3. Replace `XDG_RUNTIME_DIR= python3` with an explicit empty assignment such as
   `XDG_RUNTIME_DIR='' python3`, preserving `TMPDIR`, arguments, and expected
   exit handling.
4. Run the exact five-file pre-fix command and require exit zero with empty
   finding output.
5. Run related behavioral selftests, then the canonical tracked-shell gate.
6. Run the full framework suite only under the later test or validation owner.
7. Regenerate `bubbles/release-manifest.json` after validated source edits.

### Persistent Regression Design

The existing warning-level gate is the persistent regression mechanism. Each
scenario also has a focused one-file invocation so one clean file cannot hide a
warning in another.

Adversarial controls are mutation-based:

- Restore `CDPATH= cd` in any of the three research files. Its focused command
  must emit SC1007 and exit 1.
- Restore `XDG_RUNTIME_DIR= python3` in the migration fixture. Its focused
  command must emit SC1007 and exit 1.
- Restore an unread `EMPTY_DIGEST` assignment. Its focused command must emit
  SC2034 and exit 1.
- Add an inline disable or lower the severity. Contract checks must reject the
  attempted suppression even if ShellCheck exits zero.

### Behavior-Preservation Checks

- Run the existing research admission and adapter contract checks for the
  three research entrypoints.
- Run the usage adapter v2 selftest for the reference adapter.
- Run the scenario-manifest migration selftest for the runtime-directory fixture.
- Keep all child exit, JSON contract, fallback-directory, and lock-safety
  assertions unchanged.

### WSL and macOS Contract

- Use Bash syntax accepted by both environments.
- Express empty values with quotes instead of relying on parser ambiguity.
- Add no GNU-only option, OS branch, or dependency.
- Wrap actual commands with the available finite supervisor while preserving
  the canonical inner command.
- Run the repository macOS portability guard on every changed shell surface.

### Rollback

If behavior-preservation checks fail, revert only the five source-file changes
and any release-manifest regeneration from the same repair. Keep the BUG-061
packet and `BUGS.md` entry open. Re-run the focused command to confirm the
known five-warning pre-fix state and route the behavior failure back to the
implementation owner. Do not retain a partial suppression or mixed source state.

### Alternative Approaches Considered

1. **Add ShellCheck disable comments.** Rejected because it hides actionable warnings and defeats the zero-warning contract.
2. **Lower the gate severity.** Rejected because it changes repository policy to accommodate five source defects.
3. **Allowlist the five paths.** Rejected because it creates permanent blind spots in tracked shell assets.
4. **Absorb every current warning.** Rejected because the reference-broker and release-train findings already have different owners.
5. **Refactor path-resolution helpers.** Rejected because a cross-file abstraction is unnecessary for four explicit empty assignments.
6. **Retain `EMPTY_DIGEST` by exporting it.** Rejected because export would create a new observable contract for an unused value.

## Complexity Tracking

None - four explicit empty assignments and one dead assignment removal are the simplest viable source repair.