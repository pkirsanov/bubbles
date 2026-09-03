# Design: BUG-046 Traceability Linked-Test Path Containment

## Design Brief

### Current State

[`traceability-guard.sh`](../../bubbles/scripts/traceability-guard.sh) projects linked-test paths from `scenario-manifest.json`.
Its `path_exists` function tests the repository and feature candidates with `-f`.
The function does not prove canonical containment before accepting either candidate.

The projector supports string references and object references with `file` or `path` members.
String references lose their first fragment suffix before the filesystem check.
All-scope and current-scope modes use separate projection implementations.

### Target State

Every projected linked-test path passes one shared lexical and physical validation contract.
Only a contained canonical regular file can satisfy the linked-test edge.
Rejected references fail the traceability verdict without exposing external filesystem state.

### Patterns to Follow

- Preserve the current argument and scope projection flow in [`traceability-guard.sh`](../../bubbles/scripts/traceability-guard.sh).
- Use Bash `pwd -P`, plain `readlink`, and component-boundary containment.
- Follow the bounded symlink approach in [`repository-binding.sh`](../../bubbles/scripts/repository-binding.sh).
- Extend the hermetic cases in [`traceability-guard-selftest.sh`](../../bubbles/scripts/traceability-guard-selftest.sh).
- Keep every manifest value quoted and treat it as data.

### Patterns to Avoid

- Do not retain `[[ -f "$base/$candidate" ]]` as the acceptance decision.
- Do not use textual prefix matching for containment.
- Do not use `realpath`, `readlink -f`, or GNU-only command options.
- Do not source [`repository-binding.sh`](../../bubbles/scripts/repository-binding.sh) as a helper library.
- Do not move this repair into [`guard-lib.sh`](../../bubbles/scripts/guard-lib.sh).
- Do not print an external canonical path or an unsafe raw reference.
- Do not open a linked test to inspect its contents.

### Resolved Decisions

- Preserve repository-first and feature-second resolution order.
- Canonicalize one selected repository root before reading the feature packet.
- Require the physical feature directory to remain inside that root.
- Classify lexical failures before joining a path to either base.
- Keep untrusted control-bearing text JSON-escaped until rejection.
- Resolve symlinks with portable shell primitives and a 40-hop bound.
- Require component-boundary containment and a final regular-file check.
- Recheck the canonical target before counting the edge.
- Keep diagnostics repository-relative and independent of external existence.
- Preserve legacy envelopes, reference forms, fragments, and scope modes.

### Open Questions

None. The specification and current guard path define the required behavior.

## Purpose And Scope

This design implements the containment contract in [`spec.md`](spec.md).
It changes only linked-test validation inside the existing traceability command.
It does not change scenario matching, evidence cardinality, scope selection, or report validation.

The implementation boundary contains these files:

| Surface | Allowed change |
| --- | --- |
| `bubbles/scripts/traceability-guard.sh` | Root selection, projection records, lexical checks, canonical resolution, and diagnostics |
| `bubbles/scripts/traceability-guard-selftest.sh` | Persistent scenarios, negative controls, portability coverage, and mutation witness |

All other source, test, bug, index, Git, and host surfaces remain excluded.

## Current Technical Path

The guard currently selects `repo_root` in `detect_repo_root` and argument normalization.
A relative feature path may select the caller's working directory as the repository root.
Otherwise, the script location selects the source or installed repository root.

`manifest_linked_test_projection` selects the applicable manifest references.
The all-scope branch uses `jq` against every scenario.
The current-scope branch uses Python after resolving the applicable scope universe.

Both branches eventually feed path text into `path_exists`.
That function checks `$repo_root/$candidate` before `$feature_dir/$candidate`.
Each check follows symlinks through `-f` without a containment decision.

The repair replaces only that final trust decision and its projection transport.
It leaves the surrounding scenario and evidence checks intact.

## Architecture Overview

The linked-test flow has seven ordered stages:

1. Select and canonicalize the repository root.
2. Resolve and contain the feature directory.
3. Parse the supported manifest envelope as structured data.
4. Project references for the selected scope mode as JSON Lines records.
5. Classify each extracted path lexically while it remains JSON-escaped.
6. Resolve accepted relative paths against the existing two bases.
7. Count only a stable, contained, canonical regular file.

The following decision flow applies to every projected record:

```text
manifest reference
  -> existing form and fragment extraction
  -> lexical classification
     -> rejected: one class-only failure
     -> accepted: repository base, then feature base
        -> portable symlink resolution
        -> component-boundary containment
        -> regular-file predicate
        -> stability recheck
        -> linked-test edge counts
```

## Canonical Root Selection

Root selection preserves the current caller contract.

1. A relative feature argument that exists below the caller's working directory selects that directory.
2. Every other invocation selects the source or installed root from the script location.
3. The selected directory resolves through `cd -P` and Bash `pwd -P`.
4. The resulting physical absolute path becomes the only canonical repository root.

The script must canonicalize `SCRIPT_DIR` before applying its source-versus-installed layout rule.
This prevents a symlinked script path from selecting a logical alias as the trust root.

The feature argument then resolves against the selected root when it is relative.
An absolute feature argument retains its current input meaning.
The guard canonicalizes the existing feature directory and requires repository containment.
It rejects an external feature directory before opening its manifest.

Hermetic tests must invoke the guard from their temporary repository root with a relative feature path.
They must not rely on an absolute feature directory outside the selected root.

## Projection Contract

`manifest_linked_test_projection` keeps its scope-selection responsibility.
Both branches emit one compact JSON object per projected reference.
The transport never emits an untrusted path as an unescaped output line.

Each projection record has this internal shape:

```json
{"ordinal":1,"field":"linkedTests","form":"string","path":"tests/example.spec.ts"}
```

`ordinal` is a generated numeric position for diagnostics.
`field` is either `linkedTests` or `linkedTestContracts`.
`form` is `string`, `file`, or `path`.
`path` holds the extracted path as a JSON string.

The form rules remain compatible:

| Input form | Extraction rule |
| --- | --- |
| String | Use text before the first `#`, matching current fragment behavior |
| Object with `file` | Use the string `file` member |
| Object without `file` and with `path` | Use the string `path` member |
| Object fragment text | Preserve current object-member behavior without new fragment interpretation |
| Object envelope | Read `.scenarios[]` |
| Legacy envelope | Read the top-level scenario array |

An existing `file` member retains precedence over `path`.
A supported form with an empty extracted path produces a rejection record.
The projector does not silently discard that reference.

The existing current-scope scenario selection remains unchanged.
The current-scope branch changes only its output record format and object-member precedence.
All-scope and current-scope consumers then use the same downstream validator.

## Lexical Validation

The guard classifies the JSON-encoded `path` before raw shell extraction.
This order prevents NUL, newline, and terminal-control bytes from entering a Bash variable.

The classifier applies this fixed precedence:

1. `control-character`
2. `empty-reference`
3. `absolute-reference`
4. `parent-traversal`
5. `lexically-safe-relative`

`control-character` covers `U+0000` through `U+001F` and `U+007F`.
`empty-reference` covers an empty value and printable whitespace-only text.

`absolute-reference` covers these host-independent forms:

- Any value beginning with `/`.
- Any value beginning with two backslashes.
- Any value beginning with an ASCII letter and `:`.

The drive rule rejects both drive-rooted and drive-qualified text.
This makes the result identical on macOS and Linux.

`parent-traversal` applies when any slash-delimited component equals `..`.
Names that merely contain two dots remain eligible.
Dot components remain eligible and canonicalize normally.

The classifier emits only its rejection class and numeric ordinal for unsafe text.
It never decodes or reproduces a rejected raw value.
No rejected lexical class reaches `-e`, `-L`, `-d`, `-f`, `readlink`, or `cd`.

## Portable Canonical Resolution

The guard adds a local resolver beside `path_exists` and then removes `path_exists`.
The resolver remains private to `traceability-guard.sh`.

[`guard-lib.sh`](../../bubbles/scripts/guard-lib.sh) has no canonical-path or containment helper.
[`repository-binding.sh`](../../bubbles/scripts/repository-binding.sh) has private helpers for its command dispatcher.
Sourcing that executable would couple two unrelated command lifecycles.

The repair therefore reuses the proven primitive pattern, not the executable.
It uses only Bash tests, `pwd -P`, plain `readlink`, `dirname`, and `basename`.
It does not use GNU-only flags.

The resolver processes each canonical base in current order:

1. Canonical repository root.
2. Canonical feature directory.

The feature base must already be contained within the canonical repository root.
Duplicate physical bases are evaluated once.

For each base, the resolver walks path components and follows symlinks.
It limits the walk to 40 symlink hops.
It normalizes link targets with an absolute component stack.

An absolute symlink target is classified before target access.
A relative symlink target resolves from the physical symlink parent.
Any `..` introduced by a link target pops one component from that stack.
Crossing above the canonical repository root produces `outside-repository`.

The resolver checks containment after every physical directory resolution.
It also checks the final canonical target through an ancestor walk.
The ancestor walk compares complete components, not string prefixes.

The target must satisfy `-f` only after canonical containment succeeds.
A directory, device, socket, pipe, broken link, or missing entry cannot count.
An internal symlink may count when its final target is a contained regular file.

If the repository candidate fails, the feature candidate remains eligible.
An external candidate never contributes a successful result.
The first contained regular target preserves the current resolution order.

## Stability And TOCTOU Boundary

The guard resolves the candidate again immediately before counting the edge.
The second canonical target must equal the first canonical target.
It must also remain contained and regular.

A changed result produces `unstable-target` and a failing verdict.
This recheck narrows symlink replacement races without adding a native helper.

The shell cannot bind the check to an open file descriptor atomically.
That residual race is acceptable for this read-only lint.
The guard never reads, executes, copies, or hashes linked-test contents.

A concurrent repository writer can still change the lint verdict after the final check.
The writer already controls repository inputs and receives no expanded host authority.
Removing the remaining race would require a descriptor-based native implementation.
That complexity does not fit this guard's read-only decision.

## Diagnostic Contract

Diagnostics distinguish rejection causes without disclosing external state.

| Class | Display rule |
| --- | --- |
| `control-character` | Print the ordinal and class only |
| `empty-reference` | Print the ordinal and class only |
| `absolute-reference` | Print the ordinal and class only |
| `parent-traversal` | Print the ordinal and class only |
| `outside-repository` | Print the safe submitted relative path, never the link target |
| `missing-target` | Print the safe submitted relative path |
| `non-regular-target` | Print the safe submitted relative path |
| `unstable-target` | Print the safe submitted relative path |

The message must not print a canonical external path.
It must not identify whether an external target exists.
It must not print permissions, ownership, type metadata, or file contents.

External symlink targets use `outside-repository` whether the target exists or not.
Lexically invalid references never vary by filesystem state.

Pass diagnostics may retain the safe recorded relative path.
No diagnostic rewrites the manifest or exposes a host-specific absolute path.

When neither base accepts a lexically safe path, the resolver uses fixed precedence:

1. `unstable-target`
2. `outside-repository`
3. `non-regular-target`
4. `missing-target`

This order prevents external existence from selecting a different message.

## Data Model And Storage

The repair adds no persistent entity, schema, file format, or stored state.
Projection records exist only inside one guard process.
The manifest remains the source of linked-test references.

No migration is required.
No generated artifact changes.
No manifest rewrite occurs.

## CLI And Internal Contracts

The public command remains:

```text
bash bubbles/scripts/traceability-guard.sh <feature-dir> [--all-scopes|--current-scope]
```

Existing exit meanings remain unchanged:

| Exit | Meaning |
| --- | --- |
| `0` | No traceability failures were recorded |
| `1` | One or more traceability failures were recorded |
| `2` | The invocation shape or required feature directory is invalid |

Every rejected projected reference increments the existing failure count.
No rejected reference satisfies a linked-test edge.
Projection failures remain fail-closed.

The internal resolver returns a closed status, safe display text, and canonical target on success.
Only the success status exposes a canonical target to the caller.
Failure results never carry an external canonical target.

## UI And UX

No UI surface changes.
The command-line diagnostic contract is the only user-visible surface.

## Security And Privacy

Manifest values remain inert throughout parsing and validation.
The implementation must not use `eval`, `source`, `bash -c`, or command interpolation on a reference.
Every shell expansion that contains a path must remain quoted.

The projector parses JSON through `jq` or the existing Python branch.
It never constructs executable shell text from a manifest field.
Command-shaped values therefore remain literal path data.

The resolver may read an in-repository symlink value with plain `readlink`.
It may inspect contained filesystem metadata needed for canonicalization.
It never opens external target content.

The feature directory containment check also prevents an external manifest read.
Diagnostics suppress control-bearing and absolute raw values.

No authentication, authorization, secret, personal-data, or network surface changes.

## Configuration And Migrations

No configuration key, environment variable, feature flag, dependency, or migration is added.
The guard keeps its current command arguments and dependency posture.

## Observability And Failure Handling

The existing guard banner, pass count, failure count, and final verdict remain authoritative.
Each invalid linked-test reference adds one classed failure.

The guard must fail closed when root canonicalization fails.
It must also fail closed on a symlink loop, excessive link depth, or unstable target.
These conditions must not become missing-target passes.

No logs, metrics, traces, or external telemetry are added.
The command output contains the complete local diagnostic signal.

## Scenario-To-Test Mapping

All persistent cases belong in [`traceability-guard-selftest.sh`](../../bubbles/scripts/traceability-guard-selftest.sh).
They execute the real guard as a child process against a hermetic temporary repository.

| Scenario | Source seam | Test seam | Negative control and required assertion |
| --- | --- | --- | --- |
| `SCN-B046-001` | Root selection and contained regular-file success | Extend `build_clean_feature` with repository-relative and feature-relative files | A sibling missing path fails while both valid forms pass without manifest rewrites |
| `SCN-B046-002` | JSON lexical classifier before base resolution | Add paired traversal fixtures for present and absent external targets | Both runs emit the same `parent-traversal` class and neither emits existence details |
| `SCN-B046-003` | Host-independent absolute detection | Add POSIX, drive-qualified, and UNC records under system Bash and CI Bash | Create matching drive and UNC literal filenames inside the fixture and prove they still reject |
| `SCN-B046-004` | Symlink walk and ancestor containment | Link a safe relative name to existing and absent external targets | Both links emit `outside-repository`, never pass, and never print external target text |
| `SCN-B046-005` | Contained symlink success and final `-f` | Link one fixture path to an internal regular test file | A sibling link to an internal directory fails as `non-regular-target` |
| `SCN-B046-006` | JSON-escaped lexical classification | Add empty, spaces-only, NUL, newline, tab, escape, and delete references | Every run fails, and captured output contains no injected control byte |
| `SCN-B046-007` | Final regular-file predicate | Add missing, directory, FIFO, and Unix-socket fixture paths | Replacing `-f` with an existence-only decision makes the negative controls fail |
| `SCN-B046-008` | Quoted manifest transport and resolver calls | Add substitution, backtick, variable, wildcard, and separator-shaped values | A named sentinel remains absent and no command-shaped text executes |
| `SCN-B046-009` | Both projection branches and common validator | Reuse the current-scope fixture with string, `file`, `path`, fragment, and legacy envelopes | All-scope and current-scope agree for applicable rows while future-scope projection stays unchanged |

The portability case runs with macOS system Bash through `run_trace_case_system_bash`.
The same persistent selftest runs on Linux in the existing framework validation path.

The non-regular set uses types that a hermetic unprivileged test can create.
Directory, FIFO, and Unix socket controls kill an existence-only mutation.
The production `-f` predicate covers other non-regular inode types through the same branch.

## Testing And Validation Strategy

The implementation phase must add one mutation-sensitive regression group.
That group stages a guard copy with the former existence-only acceptance decision.
At least traversal and external-symlink scenarios must fail against that copy.

The focused validation order is:

1. Run `bash -n` against both changed shell files.
2. Run `traceability-guard-selftest.sh` against the current source bytes.
3. Run the macOS portability guard for the changed shell surface.
4. Run the repository's full framework validation at the final implementation boundary.

The tests must compare classed diagnostics, exit status, and sentinel state.
They must not treat fixture setup values as proof of guard behavior.
Every assertion must observe output or state produced by the real guard process.

No API, UI, integration-service, stress, load, or live-host test applies.
This repair changes one build-free command-line lint and its hermetic functional regression suite.

## Rollout And Rollback

The repair ships atomically with its persistent selftest changes.
It needs no data migration, manifest migration, configuration rollout, or host action.

Rollout retains existing valid manifests without rewriting their paths.
New rejection classes affect only references that violate the containment contract.

Rollback reverts the guard and its BUG-046 selftest cases together.
A rollback restores the known High-severity vulnerability.
The inherited finding must remain unresolved after any rollback.
The bug status must remain `in_progress` until a corrected repair passes independent verification.

## Alternatives And Tradeoffs

### Use `realpath` Or `readlink -f`

Rejected because the supported macOS userland lacks the required GNU behavior.
Flag probing would add branches while preserving portability risk.

### Use Python `os.path.realpath` For Every Mode

Rejected because it would add Python to the all-scope acceptance path.
The required operations fit existing portable shell primitives.

### Add A Shared Helper To `guard-lib.sh`

Rejected because BUG-046 changes one consumer and the approved boundary excludes that library.
No current `guard-lib.sh` function supplies this contract.

### Source `repository-binding.sh`

Rejected because that file is an executable command dispatcher, not a source-only library.
Its helper also canonicalizes before applying this design's external-target diagnostic rule.

### Accept On Lexical Normalization Alone

Rejected because symlinks can escape a lexically contained path.
Physical containment is required before `-f` can establish acceptance.

### Open The File And Validate Its Contents

Rejected because test-content quality is outside BUG-046.
Opening the file would enlarge the disclosure and race surface.

### Single-Implementation Justification

BUG-046 repairs one existing guard decision and one existing selftest suite.
It adds no second provider, adapter, strategy, service, screen, or shared contract consumer.
A shared path library would exceed the approved boundary and add unsupported coupling.

## Complexity Tracking

| Decision | Simpler alternative considered | Why rejected |
| --- | --- | --- |
| JSON Lines projection records | Emit raw paths as newline-delimited text | Raw control characters can cross the parser-to-shell boundary before validation |
| Bounded component and symlink walk | Canonicalize once and compare a string prefix | One-shot prefix checks miss symlink escapes and sibling-prefix paths |
| Final canonical stability recheck | Trust the first canonical result | A second check narrows a practical read-only lint race without native code |

## Risks And Open Questions

### Risks

- Projection branches could drift if they do not emit the same record contract.
- A diagnostic could accidentally decode rejected control-bearing text.
- Repository and feature resolution could change precedence during refactoring.
- Concurrent repository mutation can still change state after the final check.

Each first three risks has a paired persistent negative control above.
The TOCTOU section defines the accepted boundary for the fourth risk.

No open questions remain. Planning can derive implementation and test scopes from this design.
