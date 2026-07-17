# Bug Fix Design: BUG-019 State Transition Compound MJS Test Path

## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` Check 8 scans Markdown Test Plan
table rows, isolates backtick blocks, extracts the first substring matching a
flat extension ERE, and passes that substring unchanged to filesystem checks.
The controlling expression accepts `spec` and `test` as terminal extensions and
uses `\b`, so `tests/example.spec.mjs` becomes `tests/example.spec` even though
the complete `.spec.mjs` file exists.

The reporter observed 21 false missing paths from one real Research Lab Test
Plan. Its structured `test-plan.json`, `scenario-manifest.json`, and
traceability path retain the complete `.spec.mjs` value, which isolates the
defect to Check 8's Markdown token extraction. The canonical production guard
is already modified in the shared worktree by unrelated work; this design does
not attribute, normalize, or alter those bytes.

### Target State

Check 8 lexes a complete path-shaped candidate before deciding whether its
entire suffix is supported. It explicitly accepts `.spec.mjs` and `.test.mjs`,
preserves the current simple suffix family and ordinary `.spec.ts`/`.test.js`
controls, and never reduces a longer filename to a supported prefix.

Bare backticked paths and the existing shell-command forms remain valid.
Multiword prose is not a command or a path declaration, so a filename-shaped
word inside that prose never reaches the filesystem branch.

### Patterns to Follow

- Keep the behavior inside Check 8 in
  `bubbles/scripts/state-transition-guard.sh`; no second parser authority is
  introduced.
- Follow the left-to-right, first-accepted-path behavior already used by Check
  8, but implement it with explicit loops rather than `head -1`.
- Follow the positive/negative fixture twins in
  `bubbles/scripts/state-transition-guard-selftest.sh`: start from a packet
  known to pass unrelated checks and vary only one Test Plan input.
- Follow the source-only regression registration used by
  `bubbles/scripts/framework-validate.sh` for `test_23` and `test_24`.
- Use `bubbles/scripts/guard-lib.sh` helpers and Bash 3.2-compatible shell
  forms for macOS/Linux parity.

### Patterns to Avoid

- Do not fix this by reordering ERE alternatives. POSIX ERE matching is
  leftmost-longest; ordering does not create a whole-token boundary.
- Do not add `mjs` to the current substring expression and retain `\b`; that
  still accepts `.spec.mjs.backup` as a shorter valid prefix.
- Do not treat every backtick block containing a filename-shaped word as a
  command. That preserves the prose false positive.
- Do not replace Test Plan Markdown with `test-plan.json` opportunistically or
  create a silent JSON/Markdown precedence rule.
- Do not introduce a general Markdown parser, shell evaluator, new dependency,
  downstream workaround, or manual release-manifest edit.

### Resolved Decisions

- Select two-stage candidate-token extraction plus strict whole-candidate
  allowlist validation.
- Add only the two required MJS compounds: `.spec.mjs` and `.test.mjs`; bare
  `.mjs` does not become a new supported class.
- Preserve marker-only `.spec`/`.test` and every existing simple terminal
  suffix unless the consumer sweep disproves that compatibility requirement.
- Recognize a bare path block, `bash`/`sh` script invocation, and a supported
  script path used directly as the command. Do not evaluate command text.
- Preserve the first accepted candidate per Test Plan row.
- Use a production-path RED/GREEN regression with disposable planning-maturity
  packets and direct Check 8 output assertions.

### Open Questions

None. `bubbles.plan` must now synchronize the scope, scenario, Test Plan, DoD,
and machine-readable handoffs with this closed design.

## Purpose and Scope

This repair makes Check 8's filesystem validation truthful for complete test
path tokens. It changes only how a concrete path candidate is recognized; it
does not change scope discovery, Test Plan row selection, missing-file policy,
basename resolution, transition profiles, traceability behavior, or status
promotion.

The bug boundary is the reporter finding `AUD-005-S01-004` and the exact
behavior in [spec.md](spec.md). BUG-018 remains a separate defect in
`traceability-guard.sh` heading selection and expected no-match control flow.
No BUG-018 artifact or source surface participates in this repair.

## Controlling Parser Path

### Current Data Flow

The production path is:

```text
resolved scope files
  -> Markdown table-row grep
  -> backtick-block extraction
  -> flat supported-extension substring extraction
  -> first match in row
  -> test_files_in_plan[]
  -> direct -f check or basename-only resolution
  -> Check-8-file-existence finding/summary
```

The false path is computed by the second extraction step. Neither
`test-plan.json` nor `scenario-manifest.json` is read by Check 8, and no later
normalizer shortens the value: the local `path` value is appended directly to
`test_files_in_plan` and later used as `test_path`.

### Why The Word Boundary Truncates

The current terminal expression is:

```text
[A-Za-z0-9._/-]+\.(spec|test|rs|ts|tsx|js|jsx|sh|bash|bats|py|go|java|scala|dart)\b
```

In `example.spec.mjs`, `c` is a word character and the following `.` is a
non-word character, so `\b` is true immediately after `spec`. Because `spec`
is an accepted alternative and `mjs` is not, the expression has a valid match
ending at the marker. It is not anchored to the lexical token or backtick end.

For `example.spec.ts`, the leading path class can consume `.spec` and the final
`.ts` satisfies an accepted terminal suffix, so POSIX leftmost-longest matching
returns the complete token. `.test.js` behaves the same way. This difference is
why alternative ordering cannot repair the MJS case: the missing constraint is
whole-candidate validation, not preference between alternatives.

### Falsifiable Root Cause

The design is wrong if a production-path fixture demonstrates any of these:

- Check 8 receives the complete `.spec.mjs` value and a later branch truncates
  it;
- changing only `test-plan.json` changes Check 8's extracted value;
- the current guard truncates `.spec.ts` or `.test.js` identically; or
- the current guard rejects `example.spec.mjs.backup` without first accepting a
  shorter prefix.

The recorded intake evidence contradicts all four. The persistent regression
must retain these discriminators rather than unit-testing a copied regex.

## Behavioral Contract

| Input inside one Test Plan row | Context | Check 8 result |
| --- | --- | --- |
| `` `tests/palm-springs-rental-market-lab.spec.mjs` `` | bare path | accept the complete `.spec.mjs` path |
| `` `tests/example.test.mjs` `` | bare path | accept the complete `.test.mjs` path |
| `` `tests/example.spec.ts` `` | bare path | accept the complete `.spec.ts` path |
| `` `tests/example.test.js` `` | bare path | accept the complete `.test.js` path |
| `` `tests/example.sh` `` | bare simple suffix | retain current acceptance |
| `` `bash tests/example.sh` `` | shell command | accept the first non-option script operand |
| `` `bash -n tests/example.sh && shellcheck -x tests/example.sh` `` | shell command | accept `tests/example.sh` once, preserving first-candidate semantics |
| `` `./tests/example.sh check` `` | script as command | accept the first token `./tests/example.sh` |
| `` `tests/example.spec.mjs.backup` `` | extension-prefix adversary | accept no path and check no shorter prefix |
| `` `the prose token example.spec.mjs is illustrative` `` | multiword prose | accept no path and perform no basename lookup |
| `` `example.spec.mjs` `` | bare basename | accept as a declared basename and retain unique-resolution behavior |
| `` `node --test tests/example.spec.mjs` `` | unrecognized multiword command | accept no command-derived path; planners use a bare File/Location cell for this path |

The last two rows make the ambiguity boundary explicit. A bare backticked
filename is indistinguishable from a path declaration and remains one. A
multiword block is accepted as command text only under the narrow command
grammar below; Check 8 is not a general shell parser.

## Selected Architecture

### Stage 1: Complete Candidate Lexing

For each table row, enumerate backtick blocks from left to right. Strip only
the outer backticks and surrounding horizontal whitespace. Do not execute,
`eval`, source, or expand the content.

Classify each block into one of three contexts:

1. **Bare path:** the complete trimmed block is one path-alphabet token.
2. **Shell wrapper:** the first word is `bash` or `sh`; the candidate is the
   first non-option operand whose complete lexical token is path-shaped.
3. **Script command:** the first word itself is a supported `.sh`, `.bash`, or
   `.bats` path; that first word is the candidate.

All other multiword blocks are ignored. This rejects the specified prose
without maintaining a broad command-name registry. The shell-wrapper parser
does not interpret quotes, substitutions, globs, redirections, or `bash -c`;
the Test Plan's File/Location cell remains the authority for commands outside
the three existing forms.

A candidate is a maximal token over the existing path alphabet
`[A-Za-z0-9._/-]`. It may terminate only at the backtick edge, ASCII
whitespace, or a recognized shell control separator (`;`, `&&`, `||`). Other
trailing punctuation remains part of an invalid block rather than being
silently stripped. In particular, dots remain inside the candidate, so
`.spec.mjs.backup` reaches validation as one complete value.

### Stage 2: Strict Suffix Validation

Validate the entire candidate with anchored shell `case` patterns, not another
substring-producing grep. The closed allowlist is:

- explicit compound suffixes: `.spec.mjs`, `.test.mjs`;
- existing marker suffixes: `.spec`, `.test`;
- existing terminal suffixes: `.rs`, `.ts`, `.tsx`, `.js`, `.jsx`, `.sh`,
  `.bash`, `.bats`, `.py`, `.go`, `.java`, `.scala`, `.dart`.

At least one basename character must precede the suffix. A candidate containing
characters outside the existing path alphabet is invalid. Bare `.mjs`,
`.spec.cjs`, `.test.mts`, and every unlisted suffix remain unsupported because
the bug contract establishes no need to broaden them.

Whole-string `case` matching is the decisive property: a complete candidate
ending `.spec.mjs.backup` matches none of the allowed patterns, while
`.spec.mjs` matches exactly. It also avoids non-portable lookahead/lookbehind
and the current `\b` ambiguity.

### Row Selection And Deduplication

The first candidate that passes both stages becomes the row's `path`, matching
the current first-match contract. The implementation leaves the existing
placeholder exclusions, `test_files_in_plan` array, duplicate-row behavior,
filesystem checks, planning-maturity messages, basename-only search, counters,
and aggregate warning/failure semantics unchanged.

Selection is expressed as loops with `break`; it must not use `head`, `tail`,
or another output-truncating pipeline to select the first value.

## Candidate Comparison

| Candidate class | Strength | Blocking weakness for BUG-019 | Decision |
| --- | --- | --- | --- |
| Extension ordering or whole-suffix additions in the existing Markdown ERE | Small textual change; retains current pipeline | Ordering is not preference under POSIX leftmost-longest matching; adding `mjs` still allows prefix extraction from `.mjs.backup`, and a substring ERE still finds filename-shaped prose. Anchoring the whole backtick block would break command wrappers. | Rejected |
| Two-stage candidate-token extraction plus strict allowlist validation | Separates lexical completeness from suffix policy; preserves commands without accepting prose; implementable with Bash 3.2 and portable ERE/case forms | Adds one small local helper/control loop and requires explicit context tests | Selected |
| Structured `test-plan.json` consumption with Markdown fallback | Avoids scraping arbitrary Markdown when JSON is present | Changes Check 8's authority and precedence, creates dual-source drift/fallback semantics, and does not cover packets without the structured artifact. It crosses the narrow parser boundary and overlaps planning governance. | Rejected |

No generic Markdown parser is justified. The current table-row selector remains
unchanged, and the repair operates only on backtick blocks already selected by
Check 8.

### Single-Implementation Justification

This is a narrow bug fix inside one existing Check 8 parser path. It adds no
provider, adapter, screen, service, or reusable cross-feature contract. A
parser framework or capability abstraction would add more surface than the
complete-token repair and would violate the bug's change boundary.

## Data Model, API, UI, and Configuration

No persisted data model, schema, migration, endpoint, public API, UI, feature
flag, environment variable, or configuration key changes. The only internal
values are one backtick block, one complete candidate, and the existing
`test_files_in_plan` array during a guard process.

The operator-visible interface remains the guard's existing command, Check 8
diagnostics, aggregate transition result, and numeric exit status. No new
status class or bypass flag is introduced.

## Security and Integrity

- Markdown and command cells remain inert text; the parser never executes or
  evaluates their contents.
- The accepted path alphabet does not expand, so whitespace, substitutions,
  quoting tricks, and shell metacharacters cannot become filesystem paths.
- Full-candidate validation prevents an attacker or malformed plan from making
  a supported prefix stand in for a different file.
- Existing direct-path and pruned basename-resolution boundaries remain
  unchanged.
- Fixtures contain no secrets, network access, production telemetry, backup
  paths, deployment manifests, or downstream managed files.

## macOS and Linux Portability

Production and regression shell must run under macOS system Bash 3.2 and Linux
Bash:

- use `#!/usr/bin/env bash`, indexed arrays, `while IFS= read -r`, and shell
  `case` patterns;
- use only BSD/GNU-common `grep -E`/`grep -oE` where extraction is still
  needed; do not use `grep -P`, lookaround, or `\b` as a token terminator;
- do not add `mapfile`, `readarray`, associative arrays, namerefs, `[[ -v ]]`,
  raw GNU `sed -i`, `readlink -f`, GNU-only `mktemp` flags, or raw `timeout`;
- use existing `guard-lib.sh` helpers for temp-file rewrites and timeouts;
- avoid OS-name branching; behavior is defined by portable syntax rather than
  `uname`; and
- never truncate production/test command output with `head`, `tail`, `sed -n`,
  or filtered command pipelines. Assertion code may search saved fixture logs,
  but it prints the complete log on failure.

The focused portability proof runs both `bash -n` and
`macos-portability-guard.sh` on every changed shell file. A sanitized PATH and
`/bin/bash` execution on macOS protects the real BSD-userland path rather than
relying only on the framework validation GNU-tool shim.

## Production-Path Adversarial Regression

### Persistent Test Surface

Create `tests/regression/test_26_state_transition_spec_mjs_path.sh` as a
source-only regression and register it with `run_check_self_only` in
`bubbles/scripts/framework-validate.sh`. The script resolves the canonical
`bubbles/scripts/state-transition-guard.sh` and invokes that file as a
subprocess. It does not copy the parser expression or call a test-only
replacement.

`bubbles/scripts/install-provenance-selftest.sh` records the existing
classification: the production guard and managed selftest install downstream;
`test_26` is release-recorded but source-only. The generic release-manifest
generator discovers tracked regression scripts; its output is regenerated only
through canonical tooling after source changes settle.

### Fixture Architecture

The regression creates one unique parent under `${TMPDIR:-/tmp}` and removes it
on `EXIT`, `INT`, and `TERM`. It writes a complete planning-maturity packet
whose non-Check-8 requirements are known to pass, then creates one fixture copy
per matrix case. Each copy changes only:

- the Test Plan File/Location or Command cell;
- the concrete test file when the case requires an existing path; and
- the assertion label identifying the expected Check 8 branch.

A simple existing `.sh` baseline runs first. It must reach the literal
`--- Check 8: Test File Existence ---` marker, exit through the normal
structured guard result, and contain no unrelated failed check. If this control
fails, the regression reports fixture/harness drift and does not interpret the
result as BUG-019 behavior.

Planning-maturity is intentional isolation. A current prefix extraction is
observable as `Future implementation-owned test file is not physically
required at planning maturity: <invented-prefix>` without turning unrelated
delivery-completion checks into fixture requirements. After repair, an existing
complete file is observable as `Planned test file already exists; physical
existence is not used as planning-maturity proof: <complete-path>`.

### RED Proof

Before the production edit, run the final regression bytes with their intended
post-fix assertions. The script must exit nonzero because at least these exact
assertions fail:

- complete `.spec.mjs` existence diagnostic is absent;
- complete `.test.mjs` existence diagnostic is absent;
- `.spec`/`.test` invented-prefix diagnostics are present;
- prefix-adversary and prose fixtures do not reach the no-concrete-path branch.

The RED run is invalid if it fails before the Check 8 marker, because a required
canonical file is missing, or because an unrelated failed-check list is
nonempty. There is no `--expect-broken`, inverted expectation, conditional
return, or skip mode.

### GREEN Proof

After the source repair, execute the identical regression file and fixture
matrix. It must assert:

- exact complete-path diagnostics for `.spec.mjs`, `.test.mjs`, `.spec.ts`,
  `.test.js`, and command-wrapped `.sh`;
- absence of `.spec` and `.test` invented-prefix diagnostics;
- no-concrete-path behavior for `.spec.mjs.backup` and prose;
- no basename-resolution message for `example.spec` or `example.spec.mjs` in
  the prose case;
- normal Check 8 marker and structured guard result for every fixture; and
- zero assertion failures.

The same behavior matrix is added to the existing managed
`state-transition-guard-selftest.sh` using its known-positive per-scope fixture
and positive/negative twin pattern. This protects installed bytes; the
source-only regression independently protects the canonical production entry
point and RED/GREEN contract.

### Non-Tautology And Bailout Controls

- Every positive fixture creates the complete file named by the Test Plan and
  separately asserts that the shorter marker prefix does not exist.
- Every adversarial fixture asserts both no accepted candidate and no shorter
  filesystem lookup; merely getting exit `0` is insufficient.
- Required canonical paths are checked at startup; absence exits `2`, never
  success.
- The test counts named assertions and requires the expected total before its
  final zero exit.
- Fixture creation, guard invocation, and assertion failures are not wrapped in
  success-producing `|| true` branches.
- The regression-quality guard scans the committed test for adversarial signal
  and silent-pass patterns.

## Testing and Validation Strategy

| Scenario | Focused production proof | Compatibility proof | Broad proof |
| --- | --- | --- | --- |
| `SCN-BUG-019-001` | exact `.spec.mjs` and `.test.mjs` RED/GREEN fixture assertions | managed Check 8 compound cases | `framework-validate` then `release-check` |
| `SCN-BUG-019-002` | exact `.spec.ts`, `.test.js`, bare `.sh`, and shell-wrapper assertions | existing Check 8 shell and command-wrapper twins | `framework-validate` |
| `SCN-BUG-019-003` | `.spec.mjs.backup` and prose no-candidate/no-prefix assertions | managed adversarial twins and regression-quality guard | `framework-validate` |

Validation order after implementation is:

1. Run the persistent regression before the production edit and preserve the
   valid RED discriminator.
2. Apply the focused Check 8 repair.
3. Run the identical regression for GREEN.
4. Run `state-transition-guard-selftest.sh`.
5. Run regression-quality, Bash syntax, and macOS portability checks.
6. Run BUG-019 artifact lint, freshness, traceability, and G094 checks.
7. Run full `framework-validate` only after focused checks are green.
8. Regenerate release metadata canonically and run `release-check` only after
   all concurrent managed inputs have settled.

No design-phase command is delivery evidence, and no focused check substitutes
for implementation/test/validation ownership.

## Changed-File Boundary

### Authorized Implementation And Test Surfaces

- `bubbles/scripts/state-transition-guard.sh`: Check 8 local extraction helper
  and call site only;
- `bubbles/scripts/state-transition-guard-selftest.sh`: focused compound,
  prefix, prose, and compatibility fixtures only;
- `tests/regression/test_26_state_transition_spec_mjs_path.sh`: source-only
  production-path regression;
- `bubbles/scripts/framework-validate.sh`: one source-only regression
  registration;
- `bubbles/scripts/install-provenance-selftest.sh`: managed/source-only
  classification assertions for BUG-019;
- `bubbles/release-manifest.json`: generator-owned output only after canonical
  regeneration; and
- BUG-019 artifacts, each changed only by its owning specialist.

### Excluded Surfaces

- Research Lab source, tests, specs, and installed `.github/bubbles/**` bytes;
- BUG-012, BUG-013, BUG-018, their tests, and their planning artifacts;
- `traceability-guard.sh` and its heading/parser behavior;
- release-train config, deployment manifests, monitoring, backups, and secrets;
- unrelated state-transition checks or helpers;
- hand-edited generated release output; and
- every unrelated dirty file already present in the canonical worktree.

If required canonical registration collides with concurrent dirty work, the
owner must reconcile that exact file without discarding foreign changes. The
bug boundary does not authorize cleanup or formatting outside the named lines.

## Compatibility and Failure Semantics

The public guard command, top-level exits, Check 8 heading, pass/warn/fail
messages, planning-maturity policy, basename resolution, and aggregate result
schema remain stable.

- A valid extracted path that exists follows the existing pass/info branch.
- A valid extracted path that is absent follows the existing profile-specific
  missing-file branch.
- A prefix adversary or non-command prose produces no candidate and therefore
  cannot create a missing-file finding or basename search.
- If all rows lack valid paths, the existing no-concrete-path warning remains.
- An internal parser error must not be converted to a valid path or success;
  normal shell failure handling remains fail-visible.

There is no compatibility flag, skip switch, heuristic fallback, or downstream
rename. Research Lab receives repaired managed bytes only through the supported
canonical release/install/upgrade path.

## Observability and Operations

This is a local governance script with no service, network, telemetry adapter,
database, or SLO workflow. Observable behavior is the exact Check 8 diagnostic,
the structured transition result, and process exit. Regression logs retain the
complete guard output for failed cases and use uniquely owned temporary paths.

## Rollout and Rollback

Rollout order is canonical source repair, managed selftest, source-only
regression, framework registration, provenance classification, focused tests,
full framework validation, canonical release generation, and release check.
Only then may downstream repositories upgrade through supported provenance.

Rollback restores the prior validated canonical release and its generated
manifest as one release unit. It does not patch Research Lab, rename the
reporter's valid `.spec.mjs` test, weaken Check 8, or retain a downstream
workaround.

## Complexity Tracking

| Decision | Simpler alternative considered | Why rejected |
| --- | --- | --- |
| Two-stage lexical candidate plus whole-suffix validation | Add/reorder `mjs` in the current ERE | Does not reject extension-prefix or prose substrings and retains the non-terminal `\b` defect |
| Narrow bare-path/shell-wrapper context grammar | Accept any filename-shaped word in a backtick block | Reproduces the prose false positive; a general shell parser is unnecessary |
| Production-path source-only regression plus managed selftest twins | Unit-test the suffix patterns alone | Would not exercise table-row selection, backtick handling, first-candidate behavior, filesystem branches, or installed managed bytes |

## Risks and Open Questions

No blocking design question remains.

Residual implementation risks are bounded and testable:

- a consumer may rely on an unrecognized multiword command cell without a bare
  File/Location path; the implementation consumer sweep must identify such a
  row before changing the parser;
- a concurrent owner may modify one authorized shared registration or release
  file; BUG-019 must preserve those bytes and validate the merged surface; and
- marker-only `.spec`/`.test` files may exist even though they are uncommon;
  compatibility fixtures keep their current acceptance until evidence supports
  a separately planned contract change.

These are validation obligations for the planned implementation, not reasons
to broaden this parser or modify another bug packet.
