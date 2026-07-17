# Bug Fix Design: BUG-018 Traceability Test Plan Heading Depth

## Design Brief

### Current State

`bubbles/scripts/traceability-guard.sh` resolves each single-file scope unit or
per-scope `scope.md`, extracts scenarios, then calls `extract_test_rows` before
the caller can evaluate empty results. `extract_test_rows` selects only
`^### Test Plan`; its shared `extract_section` helper always stops at the next
level-3 heading, and its final grep pipeline returns status `1` when no concrete
row exists.

With `set -euo pipefail`, that expected no-match status escapes the command
substitution and terminates the guard immediately. The existing scope-qualified
diagnostic and final traceability summary are therefore unreachable for a valid
`## Test Plan`, a missing Test Plan, or a recognized but rowless Test Plan.

At this design snapshot, Git reports no staged or unstaged change for the
production guard, and
`tests/regression/test_25_traceability_test_plan_heading_depth.sh` does not
exist. The current source is still the pre-fix implementation.

### Target State

The guard recognizes only exact `## Test Plan` and `### Test Plan` headings
outside Markdown fences and HTML comments. It captures the selected heading
depth, includes nested content, and stops at the next ATX heading of the same or
a shallower depth.

Missing section, present-but-rowless section, and extractor failure are separate
states. The caller handles every state explicitly under `set -e` and
`pipefail`, emits one scope-qualified finding, and always reaches the normal
summary. Existing level-3 mappings and all downstream validation semantics stay
unchanged.

### Patterns to Follow

- Keep the repair inside the current traceability guard abstraction and its
   existing `fail` counter and final summary path.
- Follow `bubbles/scripts/traceability-guard-selftest.sh`: disposable complete
   packets invoke the real production guard.
- Follow `bubbles/scripts/framework-validate.sh` source-only regression
   registration used by `test_23` and `test_24`.
- Follow `bubbles/scripts/generate-release-manifest.sh`: tracked regression
   scripts are source-only; top-level guard scripts are managed payload files.
- Follow the Bash-version guard already used by
   `bubbles/scripts/implementation-reality-scan.sh` when optional fun-mode code
   cannot load under macOS system Bash 3.2.

### Patterns to Avoid

- Do not broaden the selector to `##+ Test Plan`; that would accept unsupported
   depth 4 and deeper headings.
- Do not change only the start regex; the current fixed level-3 boundary would
   still leak or truncate rows.
- Do not append a blanket `|| true`; that would erase the distinction between
   expected absence and an extractor failure.
- Do not copy extraction logic into tests or rewrite Research Lab's valid
   heading as a workaround.
- Do not edit generated release metadata by hand or absorb unrelated dirty
   release inputs into this repair.

### Resolved Decisions

- Use one specialized Test Plan row extractor; no general Markdown parser or
   new dependency is introduced.
- Return a closed internal status that distinguishes section missing from
   section present, while empty stdout remains the rowless representation.
- Handle command substitution inside an `if` condition so expected nonzero
   status cannot trigger `set -e`.
- Normalize the adjacent expected no-scenario status through the same checked
   caller pattern so its existing diagnostic is reachable.
- Preserve the current concrete-row filters and all scenario, file, evidence,
   and DoD matching behavior after extraction.
- Keep `fun-mode.sh` unchanged; the guard supplies no-op fun hooks under Bash
   versions that cannot source its associative-array implementation.

### Open Questions

None. Planning must translate this closed design into synchronized scope,
scenario, Test Plan, DoD, and machine-readable test contracts.

## Purpose and Scope

The repair restores traceability for the two Test Plan heading depths accepted
by Bubbles planning artifacts and makes malformed planning input fail with a
useful diagnostic instead of an unexplained shell exit. The behavior applies to
both single-file and per-scope-directory layouts because extraction runs on the
already-resolved `scope_analysis_files` unit in each layout.

The implementation boundary is narrow:

- production extraction and caller control flow in
   `bubbles/scripts/traceability-guard.sh`;
- the existing managed `traceability-guard-selftest.sh`;
- one source-only persistent regression at
   `tests/regression/test_25_traceability_test_plan_heading_depth.sh`;
- direct source-only registration in `framework-validate.sh`;
- direct install-provenance assertions for the changed managed guard and
   selftest plus the source-only regression; and
- generator-owned release metadata after the complete source set is stable.

Research Lab source, planning artifacts, installed `.github/bubbles/**` files,
unrelated traceability matching heuristics, unrelated registry content, and
manual release-manifest edits are excluded.

## Root Cause and Current Divergence

### Controlling Path

The current control flow is:

```text
scope layout resolution
   -> build_scope_analysis_units
   -> extract_scenarios in command substitution
   -> extract_test_rows in command substitution
   -> empty-scenario / empty-row diagnostics
   -> scenario-to-row, file, evidence, and DoD checks
   -> final summary
```

Three defects compose on the Test Plan path:

1. `extract_test_rows` passes the hardcoded selector `^### Test Plan`.
2. `extract_section` ends any selected section only when a line starts with
   three hashes and a space, independent of the selected heading depth.
3. The concrete-row grep pipeline returns `1` for expected no-match, which
    becomes the assignment status and triggers `set -e` before diagnostics.

One adjacent instance of the same control-flow defect exists in
`extract_scenarios`: its grep/sed pipeline returns `1` when a scope has no
scenario, so the caller's explicit `has no Gherkin scenarios to trace` branch
can also be skipped. This is repaired only at the checked-capture boundary; the
scenario grammar and matching behavior do not change.

The on-disk state diverges from the intake expectation that concurrent source
and regression edits exist. Current staged and unstaged diffs for the two named
implementation paths are empty, and the regression path is absent. Any edit
that appears after this snapshot must be reviewed against this design rather
than treated as completed work.

## Architecture and Extraction Contract

### Specialized Extractor

Replace the generic start-regex use with a Test Plan-specific extractor. The
extractor reads one resolved scope analysis unit and performs heading selection,
section boundary detection, fence/comment exclusion, and concrete-row filtering
in one portable `awk` program. Keeping these operations together avoids a shell
pipeline whose expected empty output carries failure status.

`extract_section` currently has no production caller other than
`extract_test_rows`. It may be removed or made private to the specialized path;
it must not remain as a second active interpretation of Test Plan boundaries.

### Exact Heading Recognition

Outside ignored regions, the only accepted start lines are:

```text
## Test Plan
### Test Plan
```

Trailing horizontal whitespace may be ignored. Leading indentation, trailing
closing hashes, additional title text, `Test Planning`, and depth 4 or deeper do
not match. The parser tracks fenced code blocks and multiline HTML comments so
an otherwise exact heading inside either region is data, not a section start.

The parser recognizes ATX headings by counting leading `#` characters with
portable character operations. It does not rely on GNU regex extensions or
three-argument `awk match` capture arrays.

### Depth-Aware Boundary

When the selected Test Plan heading has depth `D`, content continues until the
next valid ATX heading outside a fence/comment whose depth is `<= D`.

- For `## Test Plan`, level-3 through level-6 subsections stay inside the Test
   Plan, and the next level-1 or level-2 heading ends it.
- For `### Test Plan`, level-4 through level-6 subsections stay inside the Test
   Plan, and the next level-1, level-2, or level-3 heading ends it.
- The boundary heading itself is not emitted.

Pipe-prefixed lines inside a fence or HTML comment are never candidate table
rows. This prevents examples from becoming executable planning rows.

### Concrete Row Semantics

The specialized extractor preserves the current row contract exactly:

- include lines beginning with `|`;
- exclude Markdown separator rows containing only pipes, dashes, colons, and
   whitespace;
- exclude the header row whose first cell is case-insensitive `Test Type`; and
- preserve every remaining row byte for existing matching and path extraction.

No row count, scenario matcher, path matcher, report evidence check, edge
confidence classifier, or DoD fidelity heuristic changes in this repair.

## Internal Status and Error Model

The Test Plan extractor uses a closed internal status contract:

| Status | Meaning | Stdout contract | Caller action |
| ---: | --- | --- | --- |
| `0` | exact section found | zero or more concrete rows | distinguish populated from rowless by stdout |
| `3` | no exact accepted section found | empty | emit missing-section finding |
| other nonzero | read/parser/extractor failure | not trusted | emit extraction-failure finding |

Status `3` is intentionally separate from normal tool failures. The caller
must capture the function in an `if` condition, record `$?` immediately in the
`else` branch, and branch on the table above. It must not disable `set -e`,
disable `pipefail`, or collapse all nonzero statuses to success.

The caller evaluates scenarios first through the same checked-assignment shape:
grep no-match status `1` means no scenarios and reaches the existing
scope-qualified finding; any other nonzero status is an extraction failure.
After a missing scenario finding, the scope ends without attempting Test Plan
mapping.

For Test Plan handling, diagnostics are exact active contracts:

```text
<scope> has no recognized Test Plan section (expected exact ## Test Plan or ### Test Plan)
<scope> has no concrete Test Plan rows to trace
<scope> Test Plan extraction failed
```

Each condition adds one finding through `fail`, skips mapping for that scope,
and reaches the existing final summary:

```text
RESULT: FAILED (<N> failures, <W> warnings)
```

A missing section must not also be reported as an empty section. A header-only
or separator-only recognized section is rowless, not missing.

## Caller and Consumer Contract

### Internal Callers

The current source has one `extract_test_rows` caller in the primary per-scope
traceability loop. It runs once for each `scope_analysis_files` entry produced
from either:

- a single-file `scopes.md` split into one temporary unit per `## Scope N:`; or
- each `scopes/*/scope.md` file in per-scope-directory layout.

The second Gherkin-to-DoD pass reuses `extract_scenarios` and
`extract_dod_items` but does not consume Test Plan rows. Its scenario capture
must use the same expected-no-match-safe caller contract so it cannot regress
to a silent exit.

### Executable Consumers

- `traceability-guard-selftest.sh` invokes the production guard and protects
   the managed install surface.
- `framework-validate.sh` already runs that managed selftest and must also run
   the new persistent BUG-018 regression with `run_check_self_only`.
- `done-spec-audit.sh` invokes the production guard for each done spec and
   treats nonzero as an audit failure; it must now receive complete diagnostics
   and the normal final summary.
- `bubbles.validate` and direct maintainers invoke the guard by path and consume
   its existing top-level exits `0`, `1`, and `2`; those public exit classes do
   not change.
- `state-transition-guard.sh` has a separate G068 fuzzy-matching implementation
   but does not call Test Plan extraction. No change to that implementation is
   authorized.

### Release and Installation Consumers

- `traceability-guard.sh` and `traceability-guard-selftest.sh` remain managed
   installer payload files discovered by the existing trust-metadata inventory.
- `test_25_traceability_test_plan_heading_depth.sh` remains source-only. The
   existing release-manifest generator discovers it only after Git tracks the
   file; it must not appear in downstream `.manifest` or `.checksums`.
- `install-provenance-selftest.sh` must reuse its existing managed/source-only
   assertion helpers to prove those three classifications and byte identities.
- `generate-release-manifest.sh`, `trust-metadata.sh`, and `install.sh` require
   no behavior change if their generic discovery produces the classifications
   above.
- `bubbles/release-manifest.json` is regenerated from the settled canonical
   source by release tooling after registration and provenance assertions are
   complete. It is never hand-edited.

## Data Model, Configuration, and Migration

No persisted data, configuration key, schema, environment variable, network
endpoint, or migration is introduced. Extractor status exists only during one
guard process. Temporary single-file scope units retain their existing cleanup
trap.

There is no compatibility flag and no bypass. Valid planning documents need no
rewrite or migration; both accepted heading depths become behaviorally
equivalent.

## Security and Integrity

The repair changes parsing control flow, not traceability policy. It must not
weaken scenario-to-row matching, linked-test existence, evidence references,
path resolution, edge confidence, or Gherkin-to-DoD fidelity.

Markdown is parsed as inert text. Fence/comment contents are never executed,
and test fixtures contain no secret, credential, production endpoint, or
downstream path. Extractor failures remain visible rather than being converted
to empty successful results.

## macOS and Linux Portability

The production guard must execute under macOS system Bash 3.2 and Linux Bash:

- On Bash 4 or newer, source `fun-mode.sh` as today.
- On Bash 3.2, do not source its associative-array and nameref implementation;
   define only the no-op `fun_fail`, `fun_warn`, and `fun_banner` hooks consumed
   by this guard.
- Use indexed arrays only; do not add associative arrays, namerefs, `mapfile`,
   `readarray`, or `[[ -v ... ]]`.
- Use portable `awk`, `grep -E`, `sed -E`, `mktemp`, and `LC_ALL=C` ordering.
- Do not use `grep -P`, raw `timeout`, GNU `sed -i`, `readlink -f`, or
   GNU-specific three-argument `awk match`.
- Do not pass multiline section text through `awk -v`; read the scope file
   directly.

The regression must include a sanitized macOS system-path execution using
`/bin/bash` and must not rely only on the framework validation PATH shim.

## Test Fixture Isolation

Both test surfaces create one unique parent with `mktemp -d` under
`${TMPDIR:-/tmp}` and remove it through traps on `EXIT`, `INT`, and `TERM`.
Every packet, concrete linked test, log, and comparison file lives beneath that
parent.

Fixtures are structurally complete enough that heading extraction is the only
changed discriminator: scope layout, Gherkin, scenario manifest, concrete test
path, report reference, and DoD fidelity are valid. Invalid fixtures vary only
the intended heading/row condition. No fixture writes to a downstream repo,
monitoring plane, backup path, release-train config, deployment manifest, or
shared fixed temp path.

## Testing and Validation Strategy

### Managed Selftest

Extend `traceability-guard-selftest.sh` without removing its existing clean,
untraceable, declared-edge, or ambiguous-edge cases. Add production-guard cases
for:

- exact level-2 success;
- existing level-3 success;
- missing exact section, including depth-4, `Test Planning`, fenced, and
   commented false headings;
- recognized empty, separator-only, and header-only sections;
- level-2 nested rows followed by a level-2 sibling table;
- level-3 nested rows followed independently by level-3 and level-2 boundaries;
- no Gherkin scenarios reaching the existing explicit diagnostic; and
- macOS Bash 3.2 startup with optional fun mode disabled.

### Persistent Regression

`tests/regression/test_25_traceability_test_plan_heading_depth.sh` invokes the
real production guard against disposable packets. Its minimum matrix is:

| Case | Discriminator | Required assertion |
| --- | --- | --- |
| level-2 valid | exact `## Test Plan` | exit `0`; complete mapping set |
| level-3 valid | exact `### Test Plan` | exit `0`; mapping set equals level 2 |
| missing | no accepted exact heading | nonzero; missing diagnostic and final summary |
| rowless | accepted heading, no concrete row | nonzero; rowless diagnostic and final summary |
| header-only | header and separator, no data | same rowless contract |
| boundary | nested content plus later same-depth table | nested row eligible; later row excluded |

The heading-depth pair keeps every scenario, row, path, report reference, and
DoD item byte-identical except the heading marker. The invalid cases assert
required diagnostics directly and cannot return early on their absence. The
boundary case includes an unrelated later row that would create an observable
extra mapping or path failure if leakage returns.

### Scenario Mapping

| Scenario | Primary proof | Broader proof |
| --- | --- | --- |
| `SCN-BUG-018-001` | level-2 production regression | managed selftest and framework validation |
| `SCN-BUG-018-002` | byte-equal level-2/level-3 mapping comparison | existing level-3 BUG-012/BUG-013 packet canaries |
| `SCN-BUG-018-003` | missing, empty, and header-only diagnostic cases | done-spec audit consumer behavior |
| `SCN-BUG-018-004` | nested/sibling boundary adversary | managed level-2 and level-3 boundary matrix |

### Validation Order

Validation runs from narrow to broad:

1. Bash syntax under `/bin/bash` for every changed shell file.
2. Managed traceability selftest.
3. Persistent BUG-018 regression.
4. Bugfix regression-quality guard against the persistent test.
5. macOS portability guard against all changed shell files.
6. Existing level-3 traceability canaries, including BUG-012 and BUG-013.
7. BUG-018 artifact lint, artifact freshness, traceability, and G094 checks.
8. Full `bash bubbles/scripts/cli.sh framework-validate`.
9. Canonical release regeneration and `bash bubbles/scripts/cli.sh release-check`
    after all managed inputs are stable.

No focused check substitutes for the full framework or release gate, and no
pre-fix or concurrent command output is a post-fix pass claim.

## Observability and Failure Handling

This local governance guard has no service telemetry workflow. Its observable
contract is stdout/stderr plus numeric exit status. Missing, rowless, and
extractor-failure diagnostics are stable enough for tests and operators to
distinguish input classes, while the standard final summary remains the public
aggregate verdict.

## Rollout and Rollback

Canonical source, managed selftest, source-only regression, framework
registration, and install-provenance assertions form one release unit. Release
ownership regenerates derived metadata with the release manifest last, runs
`release-check`, and distributes only through the supported install/upgrade
path. Research Lab verifies installed provenance and reruns the original
Feature 007 traceability command after receiving those canonical bytes.

Rollback reverts that complete canonical unit, regenerates release metadata
from the reverted source, passes `release-check`, and installs the prior
validated release through the same supported path. It does not rewrite
downstream headings, hand-copy managed files, or preserve a partial extractor
change. Rollback restores the known defect and must be represented honestly.

## Alternatives and Tradeoffs

| Alternative | Decision | Reason |
| --- | --- | --- |
| Rewrite `## Test Plan` downstream | Rejected | Valid planning input must not compensate for a managed guard defect |
| Broaden only the selector regex | Rejected | Leaves wrong boundaries, silent no-match, and unsupported depth acceptance |
| Add blanket success fallbacks | Rejected | Masks extractor failures and cannot distinguish missing from empty |
| General Markdown parser dependency | Rejected | Two exact headings and ATX boundaries do not justify supply-chain or runtime cost |
| Change shared `fun-mode.sh` | Rejected | A local optional-hook fallback satisfies Bash 3.2 without widening the repair |
| Specialized portable extractor | Selected | Smallest path that owns heading, boundary, row, and status semantics together |

## Complexity Tracking

| Decision | Simpler alternative considered | Why rejected |
| --- | --- | --- |
| Fence/comment-aware depth scanner | Anchored start and end regexes | False headings and pipe rows inside examples would remain executable input |
| Closed internal extraction status | Empty stdout only | Cannot distinguish missing section, rowless section, and parser failure |
| Managed plus persistent production-path tests | Managed selftest only | Registration or source-only release coverage could disappear independently |
| Bash-version-gated fun hooks | Assume Homebrew Bash | The contract explicitly includes macOS system Bash 3.2 |

### Single-Implementation Justification

This is a narrow repair inside one existing traceability guard with one concrete
Test Plan extraction path. It introduces no second provider, adapter, strategy,
screen, service, or shared domain contract. A capability foundation or plugin
surface would add indirection without another implementation or consumer need.

## Risks and Open Questions

Open questions: none.

Residual risks are bounded by the design:

- Lightweight Markdown scanning is not a full CommonMark parser. The accepted
   grammar is intentionally closed to exact ATX headings, fences, HTML comments,
   and pipe tables used by Bubbles artifacts.
- A concurrent implementation may reappear after this design snapshot. It must
   be reconciled against the closed status, boundary, portability, fixture, and
   registration contracts above before any execution claim.
- Release metadata currently contains unrelated dirty work. Regeneration must
   wait for a stable owning source set so BUG-018 does not absorb another
   feature's unfinished bytes.
