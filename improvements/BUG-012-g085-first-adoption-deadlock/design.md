# Bug Fix Design: BUG-012 G085 First-Adoption Deadlock

## Design Brief

### Current State

`bubbles/scripts/framework-dogfood-guard.sh` has separate source-repository and downstream branches. The downstream branch parses numbered top-level `state.json` files, counts exact top-level `status: done`, and fails whenever the current count is zero.

That rule is enforced by `bubbles/scripts/framework-dogfood-guard-selftest.sh` and `tests/regression/test_04_framework_dogfooding.sh`. Their current one-`in_progress` fixtures intentionally fail, but they do not distinguish first adoption from an established repository whose done state was changed or deleted.

### Target State

Keep current done-state evidence as the ordinary G085 pass. Only when there is no current done state may G085 grant a first-adoption pass, and only when a complete, non-shallow, repository-local Git history proves that no reachable numbered top-level state has ever had top-level `status: done`.

An established repository that changes or deletes its current done state still fails because the prior done blob remains reachable. Missing Git metadata, a parent repository mistaken for the target, shallow or partial history, malformed historical state, and failed history traversal are indeterminate and fail closed.

### Patterns to Follow

- Preserve the source-repository branch and its no-`specs/` evidence model in `bubbles/scripts/framework-dogfood-guard.sh`.
- Preserve exact top-level status parsing with `jq`; nested certification values do not count as G085 evidence.
- Use the production guard in both hermetic test surfaces rather than reproducing its decision in test helpers.
- Stage disposable repositories under `mktemp`, configure commit identity locally, and exercise real Git commits, deletions, and shallow clones.
- Keep installer propagation upstream-first through the release manifest and standard downstream upgrade path.

### Patterns to Avoid

- Do not use `.install-source.json::installedAt` or another install timestamp; refresh and upgrade rewrite installation provenance and can make an established repository look new.
- Do not introduce a mutable `firstAdoption` flag; deleting or resetting that flag would become a bypass equivalent to deleting current done state.
- Do not infer adoption from spec count, low spec numbers, or current nonterminal status alone.
- Do not scan patch text with `grep`; only parsed blob content can establish exact top-level `status: done`.
- Do not treat an incomplete history query as an empty history result.

### Resolved Decisions

- A current done state passes without consulting Git history, preserving existing established-repository behavior.
- Bootstrap evaluation requires at least one current numbered feature state; an empty `specs/` tree retains the existing failure.
- Historical evidence means any valid matching state blob in any commit reachable from `--all` refs with exact top-level `status: done`.
- Complete history for G085 means the target is the exact Git worktree root, is non-shallow, is not partial/promisor-backed, and every relevant commit/tree/blob query completes successfully.
- Historical done evidence plus zero current done evidence is a policy violation, not a bootstrap condition.
- Ambiguous history is an input-integrity error and uses exit `2`; a proven established-state regression uses exit `1`.
- The guard remains read-only and performs no checkout, reset, fetch, commit, or downstream framework mutation.

### Open Questions

None. The design intentionally treats only locally reachable refs as historical evidence; destructive history rewriting that removes every relevant object and ref is repository-history tampering outside G085's observable boundary.

## Purpose and Scope

The fix removes the circular dependency that prevents a downstream repository from completing its first Bubbles-managed feature while retaining G085's established-repository protection. The behavior applies only to the downstream/fixture branch. Canonical Bubbles source detection, source evidence surfaces, and the prohibition on a persistent source `specs/` tree remain unchanged.

The production change is confined to the G085 guard, its hermetic selftest, its persistent regression, and G085 contract documentation/registry surfaces. Generated release metadata must be refreshed because the guard, selftest, and direct documentation are installer-facing assets. Downstream installed copies, unrelated delegated gates, state-transition ordering, and product repositories are excluded from direct modification.

## Decision Model

G085 evaluates downstream repositories in this order:

| Current numbered states | Current done count | Historical done | History integrity | Result |
| ---: | ---: | --- | --- | --- |
| any | `1+` | not consulted | not consulted | Pass through ordinary current dogfood evidence |
| `0` | `0` | not consulted | not consulted | Fail; no first feature exists to bootstrap |
| `1+` | `0` | absent | complete | Pass as first adoption |
| `1+` | `0` | present | complete | Fail; established repository lost current done evidence |
| `1+` | `0` | unknown | missing, shallow, partial, or query failure | Fail closed as indeterminate |

The first-adoption discriminator is therefore conjunctive:

1. the repository is in the downstream branch;
2. at least one current numbered top-level state exists and all current candidates are parseable under the existing contract;
3. no current candidate has exact top-level `status: done`;
4. Git resolves the supplied repository root as the exact worktree top level;
5. history is non-shallow and has no partial-clone/promisor marker;
6. the complete relevant-history traversal succeeds; and
7. no reachable historical candidate has exact top-level `status: done`.

Failure of conditions 4-6 is not equivalent to condition 7. Unknown history must never be collapsed into `historicalDone=0`.

## Architecture Overview

The source-repository branch returns before any downstream Git dependency is evaluated. The downstream branch retains its current discovery and current-state parse phase. If `DONE_COUNT > 0`, it returns the existing success immediately.

When `DONE_COUNT == 0`, a dedicated history classifier evaluates repository integrity before scanning state history. It canonicalizes both the requested root and `git rev-parse --show-toplevel` with physical-directory `pwd -P` semantics and requires equality. This prevents a non-Git fixture or nested directory from borrowing a parent checkout's history.

The classifier then requires `git rev-parse --is-inside-work-tree` to be true and `git rev-parse --is-shallow-repository` to return exactly `false`. Local partial-clone metadata (`extensions.partialClone` or a `remote.*.promisor=true` declaration) makes the evidence incomplete. Unsupported Git commands, malformed responses, missing objects, and nonzero traversal commands map to an indeterminate result.

Relevant history is read from all locally reachable refs using Git's literal repository object model and the pathspec `:(glob)specs/[0-9]*-*/state.json`. For each commit reported as touching that path class, the guard lists matching state files in that commit, reads the committed blobs, validates each blob with `jq`, and checks exact top-level `.status == "done"`. It stops on the first historical done blob. A changed or deleted current state is still classified as established because the earlier commit remains reachable.

The scan uses explicit temporary files and explicit command-status checks where process substitution or command substitution could erase a producer failure. Scratch state is removed by a trap. The classifier never invokes Git commands that mutate refs, the index, the worktree, or the object database, and it never fetches missing objects.

## Data Model and Storage

No new persisted configuration or adoption marker is introduced. The classifier consumes two read-only evidence sets:

| Evidence | Source | Semantics |
| --- | --- | --- |
| Current state | Working-tree `specs/[0-9]*-*/state.json` files | Ordinary G085 evidence and proof that a first feature currently exists |
| Historical state | Matching blobs in commits reachable from all local refs | Durable evidence that the repository previously completed a numbered feature |

The internal decision record is ephemeral and consists of `currentSpecCount`, `currentDoneCount`, `historyIntegrity`, and `historicalDoneFound`. `historyIntegrity` is a closed value: `complete`, `missing`, `shallow`, `partial`, `malformed`, or `query-failed`. It is never written to the repository.

History is monotonic for normal Git evolution: changing or deleting a done state creates a newer blob but leaves the earlier done blob reachable. Force-rewriting all refs and pruning the old objects can erase that evidence; G085 cannot prove facts that no longer exist locally, so repository controls must treat such rewriting as history tampering rather than a supported adoption transition.

## CLI Contract and Failure Model

The invocation remains:

```text
bash bubbles/scripts/framework-dogfood-guard.sh [--repo-root <path>] [--quiet]
```

No bypass, bootstrap, history override, or network-enabling flag is added. `--quiet` suppresses informational detail but not the final pass or failure diagnostic.

Numeric exit semantics remain compatible:

| Exit | Meaning |
| ---: | --- |
| `0` | Source evidence is valid, current downstream done evidence exists, or first adoption is proven |
| `1` | A policy violation is proven |
| `2` | Arguments, state input, or repository history are malformed or indeterminate |

Changed and new diagnostics carry a stable `failureCode:` or `decisionCode:` field:

| Code | Exit | Condition |
| --- | ---: | --- |
| `G085-CURRENT-DONE` | `0` | At least one current numbered state is done |
| `G085-FIRST-ADOPTION` | `0` | Current numbered state exists, current/historical done are both zero, and history is complete |
| `E085-NO-CURRENT-SPEC` | `1` | No numbered current state exists, so no bootstrap transition is present |
| `E085-ESTABLISHED-DONE-REMOVED` | `1` | Historical done evidence exists but current done evidence is zero |
| `E085-CURRENT-STATE-MALFORMED` | `2` | A current candidate is not valid JSON |
| `E085-HISTORY-UNAVAILABLE` | `2` | Git is unavailable, the target is not a worktree root, or root resolution is inconsistent |
| `E085-HISTORY-SHALLOW` | `2` | Git reports a shallow repository |
| `E085-HISTORY-PARTIAL` | `2` | Partial-clone or promisor metadata makes local history incomplete |
| `E085-HISTORY-QUERY-FAILED` | `2` | A relevant commit, tree, or blob traversal fails |
| `E085-HISTORICAL-STATE-MALFORMED` | `2` | A reachable historical candidate cannot be parsed as JSON |

Existing source-repository and argument failures keep their numeric behavior. G085 documentation may add equivalent stable codes to those unchanged paths, but the implementation must not rename or collapse the codes above.

Success output for first adoption includes `decisionCode=G085-FIRST-ADOPTION`, `currentDone=0`, `historicalDone=0`, and `historyIntegrity=complete`. Established failure output includes the historical evidence path and commit identifier for remediation, but never prints blob content. Indeterminate failures name the failed integrity check and explain that a full local clone or restored Git metadata is required; they must not advise bypassing G085.

## Security, Integrity, and Privacy

The discriminator is fail closed because absence of evidence is accepted only after the evidence source itself is proven usable. A shallow clone cannot hide an older done blob, a nested directory cannot inherit unrelated parent history, and a partial clone cannot trigger a network-dependent result.

The scan reads only committed `state.json` blobs. It does not print their contents, execute hooks, inspect application data, contact remotes, or mutate repository state. Commit identifiers and state paths are acceptable diagnostics; state payloads remain private. The current source-repository protection is evaluated before downstream history logic, so this change cannot authorize persistent source specs.

## macOS and Linux Portability

The implementation remains compatible with macOS system Bash 3.2 and common Linux Bash versions:

- Use indexed arrays and `while IFS= read -r`; do not use `mapfile`, associative arrays, or Bash 4-only syntax.
- Use `pwd -P` from a validated directory for canonical paths; do not use GNU-only `readlink -f` or `realpath` assumptions.
- Keep paths NUL-delimited when emitted by `find` or `git ls-tree`; do not parse path lists with whitespace splitting.
- Remove the current `sort -z` dependency from the touched discovery path. Ordering is not part of the contract, and BSD `sort` portability must not determine correctness.
- Use portable `mktemp -d -t bubbles-g085-XXXXXXXX`, `LC_ALL=C`, and ordinary POSIX utilities; do not add GNU-only `sed`, `date`, `stat`, `grep -P`, or timeout forms.
- Capture Git command exit status explicitly. A failed producer in process substitution must not appear as an empty successful scan.
- Hermetic commits set identity with command-local or repository-local Git configuration and never depend on the developer's global Git config.

The selftest must run under the framework's macOS portability validation as well as the normal Linux validation path. Tests assert decisions and codes, not nondeterministic path ordering or Git's default branch name.

## Configuration, Migration, and Rollout

No configuration key, environment variable, schema migration, or persisted marker is required. Git becomes a conditional downstream dependency only for the zero-current-done branch; repositories with current done evidence retain the existing fast path.

The canonical source change updates the guard and tests first. Direct G085 descriptions in `bubbles/registry/gates.yaml`, the generated workflow registry, `docs/recipes/framework-dogfood.md`, and convergence/operator references must describe the two downstream pass paths and the fail-closed history requirements without implying that every zero-done repository passes.

Because installer-managed files change, `bubbles/release-manifest.json` must be regenerated by the canonical release tooling and release readiness must verify its hashes. The standard Bubbles release/upgrade mechanism then propagates the guard and selftest to downstream `.github/bubbles/**` installations. Research Lab is validated only after that upgrade path installs the canonical revision; its managed framework copy is never edited or manually copied.

Rollback is release-level reinstallation of the prior validated Bubbles revision. There is no data rollback because the guard writes no repository state. A rollback restores the deadlock, so it is an emergency compatibility action rather than a silent fallback.

## Observability and Failure Handling

G085 is a local governance guard with no runtime service or telemetry backend. Its observability contract is deterministic stdout/stderr plus exit status.

Ordinary current-done success, first-adoption success, established-state failure, and history-integrity failure are distinguishable by stable decision/failure codes. Diagnostics expose counts and integrity classification so a state-transition wrapper can report the controlling reason without parsing prose. `--quiet` still emits the terminal decision line.

History scanning stops at the first exact done blob because additional matches do not change the decision. Any parse or object-read error before a conclusive absence result aborts with exit `2`. Cleanup traps remove only guard-owned temporary files and preserve the original nonzero result if cleanup itself encounters an error.

## Testing and Validation Strategy

Both test surfaces execute the production guard against disposable real Git repositories. The guard selftest owns the full decision matrix; the persistent regression owns the smallest matrix that detects this bug and a broad zero-done exemption.

### Hermetic Fixture Matrix

| Scenario | Repository construction | Expected assertion |
| --- | --- | --- |
| Source clean | Existing synthetic source evidence surfaces, no `specs/` | Exit `0`; source behavior unchanged |
| Source with specs | Existing synthetic source plus `specs/` | Exit `1`; source prohibition unchanged |
| Current done fast path | Downstream with a current done state | Exit `0`; `G085-CURRENT-DONE`; history classifier not required |
| Empty downstream | Full Git repo with no numbered current state | Exit `1`; `E085-NO-CURRENT-SPEC` |
| Genuine first adoption | Full Git repo with committed nonterminal numbered states and no done blob in any reachable commit | Exit `0`; `G085-FIRST-ADOPTION` |
| Done changed to nonterminal | Commit `status: done`, then commit `status: in_progress` | Exit `1`; `E085-ESTABLISHED-DONE-REMOVED` |
| Done state deleted | Commit a done state, then delete and commit the deletion while another nonterminal state remains | Exit `1`; historical evidence still found |
| Shallow history hides done | Clone at depth 1 after done-to-nonterminal history | Exit `2`; `E085-HISTORY-SHALLOW` |
| Missing Git metadata | Nonterminal state in a directory that is not an exact Git root | Exit `2`; `E085-HISTORY-UNAVAILABLE` |
| Partial/promisor repository | Full fixture marked with partial/promisor metadata | Exit `2`; `E085-HISTORY-PARTIAL` |
| Broken history traversal | Fixture with an unreadable/missing relevant object or invalid ref | Exit `2`; `E085-HISTORY-QUERY-FAILED` |
| Malformed historical state | Commit malformed state JSON, then leave a valid current nonterminal state | Exit `2`; `E085-HISTORICAL-STATE-MALFORMED` |
| Non-numbered historical done | Commit `specs/foo/state.json` as done | It is ignored; a valid numbered first feature can still use the bootstrap path |

The adversarial regression is the pair with identical current nonterminal state: one repository has no historical done blob and passes, while the other previously committed done and fails. This pair fails if the implementation regresses to either unconditional zero-done rejection or blanket zero-done acceptance.

The shallow-clone case uses a local `file://` clone with at least two commits so `--depth=1` is effective without network access. Fixture setup verifies `git rev-parse --is-shallow-repository` before invoking the guard; a fixture that is not actually shallow fails the test setup rather than producing a false guard result.

Design acceptance requires artifact lint plus the Design profile checks. Delivery acceptance additionally requires the focused G085 selftest, persistent regression, macOS portability guard/selftest, full `framework-validate`, release-manifest freshness, and `release-check`. Downstream acceptance runs the standard upgrade dry run and upgrade, framework write guard, installed G085 guard, and the originally blocked Research Lab transition.

## UI and Accessibility

None found: G085 is a non-interactive CLI guard and introduces no visual, browser, mobile, or assistive-technology surface. Diagnostics remain plain text and do not rely on color for meaning.

## Alternatives and Tradeoffs

| Alternative | Decision | Rationale |
| --- | --- | --- |
| Pass whenever current done count is zero | Rejected | Permanently exempts established repositories after done state is removed |
| Use current spec count or status | Rejected | Current files are resettable and do not establish lifecycle history |
| Use install/upgrade timestamp | Rejected | Upgrade rewrites provenance and misclassifies established repositories |
| Add a mutable adoption flag | Rejected | Deleting or resetting the marker becomes a bypass and adds lifecycle coupling to the installer |
| Seed a synthetic done spec | Rejected | Fabricates the evidence G085 is intended to prove |
| Search textual Git patches | Rejected | Can match deleted lines, nested fields, or invalid JSON and cannot prove exact top-level state |
| Query only `HEAD` | Rejected | A branch switch can hide done evidence still reachable from another local ref |
| Query all reachable refs and parse blobs | Selected | Uses existing durable repository evidence and detects normal changes/deletions without new mutable state |

The selected approach costs a bounded Git-history scan only in the exceptional zero-current-done path. That cost is preferable to weakening a convergence gate or creating an installer-owned lifecycle marker.

## Complexity Tracking

| Decision | Simpler alternative | Why rejected |
| --- | --- | --- |
| Fail-closed all-ref blob history classifier | Treat every zero-current-done repository as first adoption | Cannot distinguish genuine adoption from removed established evidence |
| Explicit shallow/partial/query-integrity checks | Assume a successful `git log` means complete history | Empty output from incomplete history would silently authorize bootstrap |
| Real Git repositories in hermetic fixtures | Mock history-classifier output | Would not validate the production Git path, deletion semantics, or shallow-clone behavior |

### Single-Implementation Justification

This is a narrow repair inside one existing G085 guard, not a new reusable provider, adapter, strategy, UI primitive, or cross-service capability. A general adoption-classification framework would add extension points without a second consumer and would increase the policy surface that must remain fail closed.

## Risks and Open Questions

Open questions: none.

Residual risks are bounded and explicitly handled:

- Very large repositories may make the exceptional history scan noticeable. It runs only when current done evidence is absent and stops at the first done blob; tests must not add a correctness-changing cache.
- Reachable Git history cannot attest to objects removed by destructive ref rewriting and pruning. Normal state changes and deletions remain detectable; repository history tampering requires repository-level controls.
- Older Git versions that cannot provide the required shallow/pathspec behavior fail with `E085-HISTORY-QUERY-FAILED` rather than receiving a bootstrap pass.
- Historical malformed state can block bootstrap classification. The safe remediation is to restore a valid current done spec or repair repository history through normal repository governance, not to bypass the gate.
