# Scopes: BUG-012 G085 First-Adoption Deadlock

Related artifacts: [spec.md](spec.md), [design.md](design.md), [report.md](report.md), [uservalidation.md](uservalidation.md)

## Execution Outline

### Purpose

Repair G085 without creating a resettable adoption marker or weakening established-repository enforcement. The production guard may grant first adoption only when a current numbered feature exists, every current numbered state is valid and non-done, complete local Git history is provably available, and no matching historical blob across any reachable ref has exact top-level `status: done`.

The Scope 1 validation path also requires a narrow correction to the canonical stale-reference scanner: literal historical command output inside a fully structured `report.md` execution-evidence fence is not live framework policy, while equivalent narrative, source examples, incomplete evidence records, and malformed fences remain actionable scanner input.

### Phase Order

1. **Scope 1 - Fail-Closed G085 First-Adoption Classification:** implement the complete current-state/history decision model, preserve structured historical execution evidence without weakening live stale-reference detection, exercise both contracts adversarially, synchronize direct consumers, and prove canonical release readiness.

The repair is one vertical scope because the guard, its executable regression fixtures, its stable diagnostics, and installer-facing contract surfaces form one indivisible policy outcome. No later scope may compensate for a temporarily permissive classifier.

### New Types and Signatures

- `bash bubbles/scripts/framework-dogfood-guard.sh [--repo-root <path>] [--quiet] -> exit 0 | 1 | 2`
- `historyIntegrity := complete | missing | shallow | partial | malformed | query-failed`
- Success decisions: `G085-CURRENT-DONE`, `G085-FIRST-ADOPTION`
- Policy failures: `E085-NO-CURRENT-SPEC`, `E085-ESTABLISHED-DONE-REMOVED`
- Integrity failures: `E085-CURRENT-STATE-MALFORMED`, `E085-HISTORY-UNAVAILABLE`, `E085-HISTORY-SHALLOW`, `E085-HISTORY-PARTIAL`, `E085-HISTORY-QUERY-FAILED`, `E085-HISTORICAL-STATE-MALFORMED`
- Historical match identity: reachable commit identifier plus literal `specs/[0-9]*-*/state.json` path; blob payloads are never printed
- `bash bubbles/scripts/stale-deferral-lint.sh [REPO_ROOT] -> exit 0 | 1`
- `structuredExecutionEvidenceFence := report.md + complete execution metadata + exact text fence + matching close`
- No persisted first-adoption flag, timestamp, cache, environment variable, network lookup, or bypass option is introduced

### Validation Checkpoints

- **Classifier checkpoint:** focused production-guard selftest proves every decision branch and every distinct code before broader validation.
- **Scenario regression checkpoint:** each `SCN-BUG-012-001` through `SCN-BUG-012-004` has its own persistent production-guard E2E mapping; the adversarial pair uses identical current nonterminal states so clean history passes while changed/deleted historical done evidence fails.
- **Broader regression checkpoint:** full framework validation runs after the focused scenario regressions and must preserve the source branch, delegated caller behavior, registry generation, and unrelated framework selftests.
- **Portability checkpoint:** macOS/Linux shell validation proves Bash 3.2-compatible, GNU-independent discovery and explicit producer-status handling.
- **Framework checkpoint:** full framework validation proves the source-repository branch, current-done fast path, registries, and unrelated gates remain coherent.
- **Release checkpoint:** release-manifest freshness and release readiness prove installer-facing changes are reproducible before standard downstream upgrade propagation.
- **Evidence-scanner checkpoint:** the production stale-reference lint selftest proves a closed structured historical-evidence fence is ignored, while byte-equivalent live narrative, source fences, incomplete metadata, mixed evidence/narrative, and malformed or unclosed fences still fail.
- **Post-repair framework checkpoint:** full framework validation must return green with the preserved BUG-012 report evidence still byte-identical; a focused scanner selftest cannot substitute for this live repository scan.
- **Planning checkpoint:** artifact lint, freshness, and traceability must pass for this bug packet before implementation begins.

## Scope Inventory

| # | Scope | Depends On | Surfaces | Primary Validation | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | Fail-Closed G085 First-Adoption Classification | - | G085 guard/tests, stale-reference scanner/selftest, registry/docs, release metadata | focused matrices, adversarial E2E, framework/release gates | In Progress |

## Scope 1: Fail-Closed G085 First-Adoption Classification

**Status:** In Progress
**Depends On:** -
**Scope-Kind:** runtime-behavior

### Outcome

G085 preserves its ordinary current-done and canonical-source behavior while permitting exactly one new downstream success state: at least one valid current numbered state, zero current done states, complete non-shallow/non-partial history across all reachable refs, and zero historical numbered top-level done blobs. Every unavailable, incomplete, malformed, or failed history condition refuses with its own stable code.

### Gherkin Scenarios

#### SCN-BUG-012-001: Only proven current-done or genuine first-adoption evidence passes

```gherkin
Scenario Outline: SCN-BUG-012-001 G085 accepts only a permitted downstream success state
  Given the production G085 guard evaluates an exact downstream Git worktree root
  And the repository has <current-count> valid current numbered feature states
  And exactly <current-done> current numbered states have top-level status done
  And local history is <history-integrity>
  And reachable refs contain <historical-done> numbered historical top-level done blobs
  When G085 evaluates the repository without mutating it
  Then the guard exits 0 with decision code <decision-code>
  And the diagnostic reports the evidence that controls that decision

Examples:
  | current-count | current-done | history-integrity | historical-done | decision-code |
  | one or more   | one or more  | not consulted     | not consulted   | G085-CURRENT-DONE |
  | one or more   | zero         | complete          | zero            | G085-FIRST-ADOPTION |
```

For `G085-FIRST-ADOPTION`, success output must include `currentDone=0`, `historicalDone=0`, and `historyIntegrity=complete`. A reachable done blob under a non-numbered path is ignored and does not invalidate a genuine numbered first adoption.

#### SCN-BUG-012-002: Removed current done evidence remains an established-repository violation

```gherkin
Scenario Outline: SCN-BUG-012-002 Reachable historical done evidence prevents bootstrap re-entry
  Given a full downstream Git repository previously committed a numbered state with exact top-level status done
  And a later commit <current-change>
  And at least one valid current numbered nonterminal state remains
  When the production G085 guard scans every locally reachable ref
  Then the guard exits 1 with failure code E085-ESTABLISHED-DONE-REMOVED
  And the diagnostic identifies the matching commit and state path without printing blob content

Examples:
  | current-change |
  | changes that done state to in_progress |
  | deletes that done state |
```

#### SCN-BUG-012-003: Incomplete or invalid evidence fails closed with distinct diagnostics

```gherkin
Scenario Outline: SCN-BUG-012-003 G085 never converts unknown history into no historical done evidence
  Given current done evidence is zero
  And the repository presents <condition>
  When the production G085 guard evaluates the repository
  Then the guard exits <exit-code> with failure code <failure-code>
  And the diagnostic names the failed integrity condition without suggesting a bypass

Examples:
  | condition | exit-code | failure-code |
  | no current numbered state | 1 | E085-NO-CURRENT-SPEC |
  | malformed current numbered state JSON | 2 | E085-CURRENT-STATE-MALFORMED |
  | missing Git metadata, a non-worktree, a nested root, or inconsistent root resolution | 2 | E085-HISTORY-UNAVAILABLE |
  | shallow Git history | 2 | E085-HISTORY-SHALLOW |
  | partial-clone or promisor metadata | 2 | E085-HISTORY-PARTIAL |
  | failed commit, tree, or blob traversal | 2 | E085-HISTORY-QUERY-FAILED |
  | malformed reachable historical numbered state JSON | 2 | E085-HISTORICAL-STATE-MALFORMED |
```

#### SCN-BUG-012-004: Canonical source-repository evidence remains invariant

```gherkin
Scenario Outline: SCN-BUG-012-004 G085 preserves the canonical source evidence model
  Given the production G085 guard identifies the exact canonical Bubbles source repository
  And the source evidence surfaces are valid
  And the repository <specs-condition>
  When G085 evaluates the repository
  Then the guard exits <exit-code>
  And the downstream Git-history classifier is not consulted

Examples:
  | specs-condition | exit-code |
  | has no persistent specs tree | 0 |
  | contains a persistent specs tree | 1 |
```

#### SCN-BUG-012-005: Structured historical execution evidence is distinct from live policy text

```gherkin
Scenario Outline: SCN-BUG-012-005 Stale-reference scanning ignores only closed structured execution evidence
  Given a lapsed version-reference phrase appears in <location>
  And the surrounding Markdown structure is <structure>
  When the production stale-reference lint scans the repository
  Then the lint exits <exit-code>
  And <expected-treatment>

Examples:
  | location | structure | exit-code | expected-treatment |
  | a report.md raw-output block | complete Phase, Command, Exit Code, and Claim Source executed metadata followed by a closed text fence | 0 | the literal historical output is not interpreted as current framework policy |
  | report.md narrative | ordinary prose outside a fence | 1 | the live lapsed promise is reported |
  | a report.md raw-output block | incomplete execution metadata | 1 | the phrase remains scanned |
  | a report.md raw-output block | an otherwise eligible text fence with no matching close | 1 | the buffered phrase is scanned fail-closed |
  | a report.md raw-output block | a text fence with a malformed or mismatched closing fence | 1 | the buffered phrase is scanned fail-closed |
  | a report.md source block | a closed bash, sh, shell, or zsh fence | 1 | executable source text remains scanned |
  | non-evidence documentation | any fence or metadata shape | 1 | non-report documentation remains scanned |
  | report.md evidence plus report.md narrative | one valid evidence block and one live prose match | 1 | the live match cannot be hidden by valid evidence elsewhere in the file |
```

The only eligible opener is an exact triple-backtick `text` fence in a file whose basename is `report.md`. The same evidence record, before that opener and after the nearest Markdown heading or prior fence boundary, must contain `**Phase:**`, `**Command:**` or `**Commands:**`, an `**Exit Code...:**` field, and `**Claim Source:** executed`. The scanner buffers candidate content until an exact matching closing triple-backtick fence is observed; no match is suppressed before closure. A heading, end of file, mismatched fence, missing metadata field, non-`text` info string, or non-`report.md` path makes the entire candidate content live scanner input.

### UI Scenario Matrix

None: G085 is a non-interactive CLI guard. Its user-visible contract is plain-text diagnostics plus exit status, with no browser, mobile, visual, color-dependent, or assistive-technology surface.

### Implementation Plan

1. Preserve the canonical-source branch and current numbered-state parsing contract; return `G085-CURRENT-DONE` before any conditional Git-history dependency.
2. For zero current done states, require at least one valid current numbered state and classify the supplied repository only when it is the exact physical Git worktree root.
3. Refuse shallow repositories and any partial/promisor metadata before scanning history; treat unsupported or malformed Git responses as indeterminate rather than empty evidence.
4. Traverse commits reachable from `--all` refs for the literal numbered-state path class, list matching blobs per commit, parse every candidate with `jq`, and stop only on a proven historical done match or a complete no-match traversal.
5. Preserve command failures through explicit temporary files and status checks, remove only guard-owned scratch state by trap, and keep the entire classifier read-only and offline.
6. Extend the hermetic production-guard selftest with the full decision matrix from the design, including real commits, a committed deletion, an effective `file://` shallow clone, separate `extensions.partialClone` and `remote.*.promisor=true` fixtures, a broken traversal, malformed historical JSON, and an ignored non-numbered done path.
7. Extend the persistent regression with the minimal adversarial pair: identical current nonterminal files with clean history versus reachable prior done history. Keep canonical-source and ordinary current-done regression coverage.
8. Synchronize stable codes and two downstream pass paths in the direct G085 registry, workflow registry, `bubbles/scripts/guards/tail-delegated-gates.sh` G085 guidance, operator/convergence documentation, and release-manifest inputs without implying that zero current done alone is sufficient.
9. Run focused, portability, framework, artifact, freshness, traceability, manifest-freshness, and release-readiness checks; record execution evidence without changing certification state.
10. Replace whole-file grep evaluation in the stale-reference lint only for `report.md` candidates with a streaming, fail-closed evidence-record classifier. Suppress a reference match only after the exact structured `text` fence contract in `SCN-BUG-012-005` closes successfully; preserve all existing path exclusions, version comparison, diagnostics, exit semantics, and scan extensions. Keep the parser compatible with macOS Bash 3.2 and BSD userland: no associative arrays, `mapfile`, GNU-only `awk` capture arrays, GNU-only `sed`, or platform-specific in-place rewrite.
11. Extend the stale-reference lint selftest without weakening Cases 1-11. Add separately named cases for closed structured evidence, equivalent live narrative, incomplete metadata, an unclosed fence, shell-source fences, non-report fenced content, and valid evidence mixed with live narrative. Refresh only the release-manifest hashes mechanically required by the two changed installer-managed scripts.
12. Propagate only through the standard canonical release/install/upgrade mechanism. Do not edit, copy into, or certify a downstream `.github/bubbles/**` installation in this scope.

### Decision Invariants

| Invariant | Required behavior |
| --- | --- |
| Current done fast path | One or more exact top-level current done states pass without requiring Git history |
| Empty current inventory | Zero numbered current states fails with `E085-NO-CURRENT-SPEC` |
| Bootstrap conjunction | Current numbered count `1+` AND current done `0` AND exact full root AND non-shallow AND non-partial AND complete traversal AND historical done `0` |
| Historical durability | A reachable prior done blob fails even when changed or deleted in the working tree/current commit |
| All-ref reachability | A done blob reachable from any local ref is established evidence; scanning only `HEAD` is insufficient |
| Exact state semantics | Only parseable numbered `state.json` blobs with exact top-level `.status == "done"` count |
| Unknown is not absent | Missing, shallow, partial, malformed, or failed history never becomes `historicalDone=0` |
| Read-only execution | No checkout, reset, fetch, commit, ref/index/worktree/object mutation, or downstream framework write |
| Source invariance | Canonical Bubbles source still forbids persistent `specs/` and uses its existing source evidence model |
| Numeric compatibility | Proven policy failures exit `1`; malformed or indeterminate input exits `2`; permitted evidence exits `0` |
| Evidence exemption identity | Only a fully closed exact `text` fence in `report.md`, bound to complete same-record execution metadata with `Claim Source: executed`, may suppress a match |
| Fence parsing fails closed | Candidate matches are buffered until a matching close; malformed, mismatched, interrupted, or unclosed fences are scanned rather than exempted |
| Scanner coverage remains live | Narrative, source-language fences, non-report documentation, incomplete evidence records, and live text beside valid evidence retain ordinary stale-reference enforcement |
| Existing scanner behavior | Current version comparison, whole-file historical exclusions, selftest-path exclusion, diagnostics, extensions, and Cases 1-11 remain unchanged and green |

### Consumer Impact Sweep

The stable diagnostic contract and zero-current-done branch are consumed or described by the following first-party surfaces. Each must be checked for stale assumptions that every zero-done downstream repository fails or that first adoption is represented by a mutable marker:

- `bubbles/scripts/framework-dogfood-guard-selftest.sh`
- `bubbles/scripts/guards/tail-delegated-gates.sh` G085 failure guidance
- `tests/regression/test_04_framework_dogfooding.sh`
- `bubbles/registry/gates.yaml`
- the generated workflow registry derived from the gate registry
- `docs/recipes/framework-dogfood.md`
- convergence, release, and operator references that describe G085 evidence
- `bubbles/release-manifest.json` and its canonical generator/freshness check
- state-transition/framework-validation callers that consume only exit status or terminal diagnostics
- installed downstream copies reached through the standard release/upgrade mechanism
- `bubbles/scripts/framework-validate.sh`, which runs the stale-reference selftest and the live source-repository scan as separate checks
- `bubbles/scripts/stale-deferral-lint.sh` report scanning, which must distinguish immutable executed output from current policy prose without changing non-report behavior
- `bubbles/scripts/stale-deferral-lint-selftest.sh` Cases 1-11, whose existing exclusions and lapsed/future comparison semantics are protected behavior

No route, public API, protobuf contract, UI target, generated client, deep link, or database schema is renamed or removed. Existing numeric exit semantics remain stable.

### Shared Infrastructure Impact Sweep

`framework-dogfood-guard.sh` is a high-fan-out framework guard installed into downstream repositories. Its protected contracts are:

- source-repository detection and persistent-`specs/` prohibition;
- current numbered-state discovery and exact top-level JSON parsing;
- ordinary current-done success behavior;
- downstream zero-done refusal behavior except for the proven conjunction;
- stable exit classes consumed by state-transition and framework-validation wrappers;
- installer manifest coverage and checksum freshness;
- macOS Bash 3.2 and Linux portability;
- read-only, offline execution in arbitrary repository paths, including spaces.

Independent canaries are the source-clean/source-with-specs pair, the current-done fast path, the genuine-first-adoption fixture, the identical-current-state adversarial pair, and explicit shallow/partial/query-failure fixtures. Broad framework validation runs only after these focused canaries pass.

The stale-reference lint is also high fan-out because framework validation runs it against the canonical repository and installer-managed copies carry both the lint and selftest. Its independent canaries are one valid structured report-evidence block, the byte-equivalent live-narrative failure, incomplete metadata, unclosed-fence failure, source-fence failure, non-report fenced failure, and a mixed valid-evidence/live-narrative failure. The existing eleven selftest cases run in the same invocation. Rollback restores the prior lint and selftest together through the prior validated release manifest; a one-file rollback is prohibited because parser behavior and its contract tests must remain paired.

Rollback is installation of the prior validated canonical Bubbles release through the standard release mechanism. No data restore is required because the guard persists nothing. Rollback restores the prior deadlock and therefore must be explicit and observable rather than an internal fallback.

### Change Boundary

Allowed file families:

- `bubbles/scripts/framework-dogfood-guard.sh`
- `bubbles/scripts/framework-dogfood-guard-selftest.sh`
- `bubbles/scripts/stale-deferral-lint.sh`, limited to recognizing structured execution-evidence fences in `report.md` while preserving stale-reference detection everywhere else
- `bubbles/scripts/stale-deferral-lint-selftest.sh`, limited to adversarial coverage of that structured evidence contract plus preservation of every existing case
- `bubbles/scripts/guards/tail-delegated-gates.sh`, limited to the Check 26 G085 diagnostic
- `bubbles/scripts/state-transition-guard.sh`, limited exclusively to the non-executable Check 26 G085 wrapper comment: it may name `G085-CURRENT-DONE` and `G085-FIRST-ADOPTION`, describe both pass paths, and state that first adoption fails closed unless current-state and complete-history evidence is proven; executable code, gate ordering, status semantics, and unrelated text remain excluded
- `tests/regression/test_04_framework_dogfooding.sh`
- direct G085 registry and generated workflow-registry surfaces
- direct G085 operator/convergence documentation named by the design
- canonical release-manifest generator inputs and generated `bubbles/release-manifest.json`
- execution evidence appended to this bug packet by the owning execution agents

For the scanner reconciliation, the newly authorized implementation delta is exactly `bubbles/scripts/stale-deferral-lint.sh`, `bubbles/scripts/stale-deferral-lint-selftest.sh`, and the hash-only refresh of their existing entries in generated `bubbles/release-manifest.json`. The manifest currently records both scripts by SHA-256, so that generated refresh is mechanically required. No scanner-related registry, workflow-registry, changelog, recipe, agent, prompt, test-regression, or documentation edit is authorized by this amendment.

Excluded surfaces:

- downstream `.github/bubbles/**` installed copies, including Research Lab
- unrelated delegated-gate checks outside `tail-delegated-gates.sh` Check 26, unrelated tests, workflows, registries, and documentation
- whole-file, whole-directory, filename-pattern, or generic Markdown-fence exemptions from stale-reference scanning; live narrative, shell/source fences, non-evidence documentation, malformed or unclosed fences, and fenced text without the required execution-evidence metadata remain scanned
- `report.md` evidence content, `uservalidation.md`, `tests/regression/test_04_framework_dogfooding.sh`, and every source/test file not named in the scanner reconciliation allowance
- state-transition gate ordering or status semantics outside G085
- mutable adoption flags, install timestamps, caches, environment overrides, and bypass options
- network fetching or remote-history mutation
- `spec.md`, `design.md`, `bug.md`, and all `certification.*` fields
- unrelated cleanup, formatting, or refactoring

Any required expansion of this boundary must return to planning before additional files are changed.

### Test Plan

| Test Type | Test ID | Scenario | Category | File / Location | Exact behavior or case label | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| guard selftest | T-BUG-012-01 | SCN-BUG-012-001, SCN-BUG-012-004 | functional | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `S0-S2 source evidence; S4 current done; S5 first adoption and read-only execution; S15 non-numbered and nested done ignored; S16 delegated G085 guidance names both pass paths` | `bash bubbles/scripts/framework-dogfood-guard-selftest.sh` | No |
| guard selftest | T-BUG-012-02 | SCN-BUG-012-002 | functional | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `S7 changed, S8 deleted, and S9 alternate-ref historical done remain established` | `bash bubbles/scripts/framework-dogfood-guard-selftest.sh` | No |
| guard selftest | T-BUG-012-03 | SCN-BUG-012-003 | functional | `bubbles/scripts/framework-dogfood-guard-selftest.sh` | `S3 empty inventory; S6 malformed current; S10 unavailable or nested root; S11 shallow; S12a extensions.partialClone; S12b promisor; S13 commit, tree, or blob failure; S14 malformed historical` | `bash bubbles/scripts/framework-dogfood-guard-selftest.sh` | No |
| regression E2E | T-BUG-012-04 | SCN-BUG-012-001, SCN-BUG-012-004 | e2e-api | `tests/regression/test_04_framework_dogfooding.sh` | `S1 source clean; S2 source with specs; S3 current done; S4 genuine first adoption` | `bash tests/regression/test_04_framework_dogfooding.sh` | Yes |
| adversarial regression E2E | T-BUG-012-05 | SCN-BUG-012-002 | e2e-api | `tests/regression/test_04_framework_dogfooding.sh` | `Regression: S5 byte-identical current states diverge only on reachable historical done evidence` | `bash tests/regression/test_04_framework_dogfooding.sh` | Yes |
| regression E2E | T-BUG-012-06 | SCN-BUG-012-003 | e2e-api | `tests/regression/test_04_framework_dogfooding.sh` | `Regression: S6 effective shallow history never receives bootstrap success` | `bash tests/regression/test_04_framework_dogfooding.sh` | Yes |
| portability | T-BUG-012-07 | SCN-BUG-012-001, SCN-BUG-012-002, SCN-BUG-012-003, SCN-BUG-012-004 | integration | `bubbles/scripts/macos-portability-guard-selftest.sh` | `portability guard selftest; touched framework shell executes under the T-BUG-012-08 framework-validate portability shim` | `bash bubbles/scripts/macos-portability-guard-selftest.sh` | No |
| broader regression | T-BUG-012-08 | SCN-BUG-012-001, SCN-BUG-012-002, SCN-BUG-012-003, SCN-BUG-012-004 | integration | `bubbles/scripts/cli.sh` | `Broader regression: framework-validate preserves source, registry, delegated G085 guidance, installer checks, and unrelated selftest behavior after focused E2E passes` | `bash bubbles/scripts/cli.sh framework-validate` | Yes |
| release integration | T-BUG-012-09 | SCN-BUG-012-001, SCN-BUG-012-002, SCN-BUG-012-003, SCN-BUG-012-004 | integration | `bubbles/scripts/cli.sh` | `release-check proves manifest freshness and canonical release readiness` | `bash bubbles/scripts/cli.sh release-check` | Yes |
| regression E2E | T-BUG-012-10 | SCN-BUG-012-004 | e2e-api | `tests/regression/test_04_framework_dogfooding.sh` | `Regression: S1 canonical source remains clear and S2 canonical source with persistent specs remains blocked without downstream history classification` | `bash tests/regression/test_04_framework_dogfooding.sh` | Yes |
| adversarial regression E2E | T-BUG-012-11 | SCN-BUG-012-005 | e2e-api | `bubbles/scripts/stale-deferral-lint-selftest.sh` | `Regression: Cases 1-11 remain green; Case 12 closed structured report evidence passes; Cases 13-19 prove live narrative, incomplete metadata, unclosed fences, malformed or mismatched fences, shell-source fences, non-report fences, and mixed evidence/narrative still fail` | `bash bubbles/scripts/stale-deferral-lint-selftest.sh` | Yes |
| broader regression | T-BUG-012-12 | SCN-BUG-012-005 | integration | `bubbles/scripts/cli.sh` | `Broader regression: framework-validate returns green with byte-identical BUG-012 historical evidence and the live stale-reference scan still enabled` | `bash bubbles/scripts/cli.sh framework-validate` | Yes |
| release integration | T-BUG-012-13 | SCN-BUG-012-005 | integration | `bubbles/scripts/cli.sh` | `release-check proves the generated release manifest contains current hashes for the repaired lint and selftest and no unrelated generated drift` | `bash bubbles/scripts/cli.sh release-check` | Yes |

The E2E rows execute the production guard as a subprocess against real disposable Git repositories and real committed object history. They do not mock the classifier, Git, `jq`, state parsing, deletion semantics, or shallow/partial detection. `Live System: Yes` denotes the real executable governance system rather than an HTTP service.

### Independent Verification Mapping

- **Scenario-specific Regression E2E:** `T-BUG-012-04` preserves its completed S1-S4 aggregate contract and maps the downstream success behavior in `SCN-BUG-012-001`; `T-BUG-012-05` maps historical-done enforcement; `T-BUG-012-06` maps incomplete-history refusal; and `T-BUG-012-10` gives `SCN-BUG-012-004` a dedicated source-invariance mapping. Their shared shell executable is intentional: each mapping names a distinct production-guard assertion set and no row substitutes a proxy check for its scenario.
- **Broader regression:** `T-BUG-012-08` runs only after the focused scenario rows and checks the wider framework surface. A focused regression pass cannot substitute for this row, and a broad pass cannot erase a focused failure.
- **Consumer impact:** `T-BUG-012-01` case S16 validates delegated G085 guidance, while `T-BUG-012-08` validates state-transition/framework callers and generated registry consumers and `T-BUG-012-09` validates installer/release-manifest consumers. Independent test must confirm no first-party consumer treats zero current done as sufficient or depends on a mutable first-adoption marker.
- **Change boundary:** independent test must compare the actual changed-path set with the allowed and excluded families above, confirm zero downstream managed-copy or unrelated delegated-gate changes, and treat pre-existing unrelated work as preserved rather than part of this bug.
- **Structured-evidence scanner regression:** `T-BUG-012-11` maps every `SCN-BUG-012-005` example to a separately named production-lint fixture. Case 12 is the sole pass added by the amendment; Cases 13-19 are adversarial failures that prevent a generic report, fence, path, metadata, or mixed-content exemption.
- **Post-repair broad and release checks:** `T-BUG-012-12` must run after `T-BUG-012-11` and the unchanged G085 focused/persistent rows. `T-BUG-012-13` proves only the two managed script hashes changed in generated release metadata. Neither row may reuse the pre-amendment `T-BUG-012-08` or `T-BUG-012-09` evidence claim.

### Impact-Aware Validation

The canonical Bubbles source repository has no downstream project `testImpact` or wired runtime `traceContracts` map applicable to this local governance guard. The required impact sequence is explicit:

1. focused guard selftest;
2. persistent G085 regression;
3. adversarial stale-reference lint selftest with all existing and new cases;
4. macOS portability validation for touched shell;
5. full framework validation because installer-managed, high-fan-out guards changed;
6. release-manifest freshness and release readiness because installer-facing assets changed;
7. bug artifact lint, freshness, and traceability for planning/requirements coherence.

No external telemetry workflow applies. Deterministic decision/failure codes, exit status, and captured command output are the observability evidence.

### Definition of Done - Tiered Validation

Core behavior:

- [x] `SCN-BUG-012-001`: the ordinary current-done path returns `G085-CURRENT-DONE` without consulting history, the canonical-source branch remains unchanged, and genuine first adoption returns `G085-FIRST-ADOPTION` only when every conjunction term is proven. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed).
- [x] `SCN-BUG-012-002`: changed or deleted current done evidence remains detectable across reachable refs and returns `E085-ESTABLISHED-DONE-REMOVED` with exit `1`. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed).
- [x] `SCN-BUG-012-003`: no current spec, malformed current state, unavailable history, shallow history, partial history, failed traversal, and malformed historical state return their specified distinct codes and numeric exits. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed).
- [x] `SCN-BUG-012-004`: canonical source repositories retain their existing clean-source pass and persistent-`specs/` refusal behavior without entering downstream history classification. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed).
- [x] Exact top-level JSON semantics, numbered-path filtering, blob privacy, offline execution, and read-only repository behavior match the design. Evidence: [resumed focused and boundary evidence](report.md#resumed-portability-and-boundary-evidence) (**Phase:** implement; **Claim Source:** executed).
- [x] The Consumer Impact Sweep is complete and no first-party surface retains a stale mutable-marker or blanket zero-done assumption. Evidence: [resumed consumer evidence](report.md#resumed-consumer-and-rollback-evidence) (**Phase:** implement; **Claim Source:** executed).
- [x] The Shared Infrastructure Impact Sweep canaries pass before broad validation, and the release-level rollback path remains available. Evidence: [resumed regression, framework, release, and rollback evidence](report.md#resumed-consumer-and-rollback-evidence) (**Phase:** implement; **Claim Source:** interpreted; the explicit installer `REF` interface preserves prior-release installation).
- [x] The implementation stays within the declared Change Boundary; no downstream managed copy, unrelated gate/test, or `certification.*` field changes were made by this invocation. Evidence: [resumed packet and state evidence](report.md#resumed-packet-and-state-evidence) (**Phase:** implement; **Claim Source:** interpreted; the certification fingerprint is unchanged and pre-existing unrelated dirt is preserved).
- [x] Direct G085 registry, generated registry, delegated state-transition guidance, operator/convergence documentation, and canonical release-manifest surfaces describe the two pass paths and fail-closed history requirements consistently. Evidence: [resumed consumer, framework, and release evidence](report.md#resumed-framework-and-release-evidence) (**Phase:** implement; **Claim Source:** executed).

Test evidence, one item per Test Plan row:

- [x] `T-BUG-012-01` passes with current-invocation evidence for selftest cases S0-S2, S4, S5, S15, and S16. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed; exit `0`, 71/71 total assertions).
- [x] `T-BUG-012-02` passes with current-invocation evidence for selftest cases S7-S9. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed; exit `0`).
- [x] `T-BUG-012-03` passes with current-invocation evidence for selftest cases S3, S6, S10-S11, S12a-S12b, and S13-S14. Evidence: [resumed focused evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed; exit `0`, 71/71 total assertions).
- [x] `T-BUG-012-04` passes with current-invocation production-guard E2E evidence for regression cases S1-S4. Evidence: [resumed regression evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed; exit `0`, 16/16 assertions).
- [x] `T-BUG-012-05` passes with current-invocation adversarial E2E evidence for regression case S5. Evidence: [resumed regression evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed; identical current states diverge on reachable done history).
- [x] `T-BUG-012-06` passes with current-invocation production-guard E2E evidence for regression case S6. Evidence: [resumed regression evidence](report.md#resumed-focused-and-regression-evidence) (**Phase:** implement; **Claim Source:** executed; effective shallow fixture exits `2`).
- [x] `T-BUG-012-07` passes with current-invocation portability-guard selftest and direct touched-shell evidence. Evidence: [resumed portability evidence](report.md#resumed-portability-and-boundary-evidence) (**Phase:** implement; **Claim Source:** executed; both commands exit `0`).
- [x] `T-BUG-012-08` passes with current-invocation full framework-validation evidence. Evidence: [resumed framework evidence](report.md#resumed-framework-and-release-evidence) (**Phase:** implement; **Claim Source:** executed; exit `0`).
- [x] `T-BUG-012-09` passes with current-invocation release-manifest freshness and release-readiness evidence. Evidence: [resumed release evidence](report.md#resumed-framework-and-release-evidence) (**Phase:** implement; **Claim Source:** executed; exit `0`, 611 managed files current).

Build quality gate:

- [x] Artifact lint, freshness, and traceability pass for the bug packet; changed-path classification contains an implementation-bearing path before delivery completion; touched shell has no syntax/portability findings; documentation matches executable behavior; release metadata is generated by canonical tooling; all commands and raw outputs are recorded in `report.md` with claim-source tags; no test skip, silent-pass bailout, fabricated evidence, unchecked uncertainty without a declaration, or certification mutation remains. Evidence: [resumed packet and state evidence](report.md#resumed-packet-and-state-evidence), [resumed portability evidence](report.md#resumed-portability-and-boundary-evidence), and [resumed framework/release evidence](report.md#resumed-framework-and-release-evidence) (**Phase:** implement; **Claim Source:** interpreted; reality scan exits `0` with zero violations and one manually reviewed planning-link advisory).

Independent-test handoff (planning-owned requirements; implementation claims above remain unchanged):

- [x] Scenario-specific E2E regression tests for EVERY new/changed/fixed behavior pass: `bubbles.test` executes `T-BUG-012-04`, `T-BUG-012-05`, `T-BUG-012-06`, and `T-BUG-012-10`, records independent evidence for each exact scenario assertion set, and confirms no skip, bailout, interception, or duplicated production history traversal exists. Evidence: [finalized focused scenario evidence](report.md#finalized-focused-scenario-evidence) (**Phase:** test; **Claim Source:** executed).
  - **Current test evidence:** [current focused scenario and authenticity evidence](report.md#current-focused-scenario-and-authenticity-evidence) (**Phase:** test; **Claim Source:** executed; 71/71 focused and 16/16 persistent assertions pass).
- [x] Broader E2E regression suite passes: after all focused rows pass, `bubbles.test` executes `T-BUG-012-08` and records the complete broader framework result; focused evidence is not reused as the broad-suite result. Evidence: [finalized broader framework evidence](report.md#finalized-broader-framework-evidence) (**Phase:** test; **Claim Source:** executed).
  - **Current test evidence:** [current broad framework and release evidence](report.md#current-broad-framework-and-release-evidence) (**Phase:** test; **Claim Source:** executed; canonical framework validation exits `0` after the focused rows).
- [x] The Consumer Impact Sweep is complete and zero stale first-party references remain: `bubbles.test` verifies the consumer mapping above through `T-BUG-012-01`, `T-BUG-012-08`, and `T-BUG-012-09`, confirms no first-party consumer retains a blanket zero-done or mutable-marker assumption, and routes any foreign-owned documentation defect without editing it here. Evidence: [current exact consumer impact evidence](report.md#current-exact-consumer-impact-evidence) and [current broad framework and release evidence](report.md#current-broad-framework-and-release-evidence) (**Phase:** test; **Claim Source:** executed; exact sweep has zero failures, 71/71 remains green, framework validation and release-check exit `0`).
- [x] Change Boundary is respected and zero excluded file families were changed: `bubbles.test` verifies that BUG-012-related changes stay inside the allowed file families, no downstream managed copy or unrelated delegated-gate surface changed for this bug, and unrelated pre-existing dirty work remains preserved and unclaimed. Evidence: [finalized Change Boundary evidence](report.md#finalized-change-boundary-evidence) (**Phase:** test; **Claim Source:** interpreted; every BUG-012 marker-attributed path is allowed, downstream managed projections are byte-identical, and concurrent BUG-013 writes are preserved and explicitly unclaimed).
  - **Current test evidence:** [current test integrity, packet, and preservation evidence](report.md#current-test-integrity-packet-and-preservation-evidence) (**Phase:** test; **Claim Source:** interpreted; certification and six protected source hashes match the pre-run baseline).

Planning-owner scanner reconciliation (new obligations; existing checked claims above remain preserved):

- [ ] `SCN-BUG-012-005`: the production scanner ignores a lapsed reference only inside a fully closed, exact `text` fence in `report.md` with complete same-record `Phase`, `Command`, `Exit Code`, and `Claim Source: executed` metadata; equivalent live text and every fail-closed example remain violations.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning defined the parser contract and authorized paths; no implementation command was run by `bubbles.plan`.
  > **What was observed:** The current production lint still scans whole matching files and the gaps discriminator records three fenced-evidence diagnostics.
  > **Why this is uncertain:** The planned behavior has no implementation evidence on the amended bytes.
  > **What would resolve this:** `bubbles.implement` applies the bounded parser change, then `bubbles.test` executes `T-BUG-012-11` and records each Case 12-19 verdict.
- [ ] `T-BUG-012-11` passes all existing Cases 1-11 unchanged and the separately named Cases 12-19 prove the structured-evidence pass plus seven adversarial non-exemption paths against the production lint.
  > **Uncertainty Declaration**
  > **What was attempted:** The exact fixtures, expected exits, and production test file are mapped in the Test Plan and `test-plan.json`.
  > **What was observed:** The unchanged selftest currently has only Cases 1-11; no Case 12-19 output exists.
  > **Why this is uncertain:** Planning cannot claim test results for cases that the test owner has not authored and executed.
  > **What would resolve this:** `bubbles.test` independently runs `bash bubbles/scripts/stale-deferral-lint-selftest.sh` after implementation and records all nineteen case verdicts.
- [ ] The unchanged G085 focused selftest remains `71/71`, the persistent regression remains `16/16`, and regression-quality validation remains clean after the scanner bytes change; prior evidence is preserved but does not prove the amended bytes.
  > **Uncertainty Declaration**
  > **What was attempted:** Existing G085 evidence and protected test paths were preserved and hash-checked during planning.
  > **What was observed:** The scanner implementation has not changed in this planning invocation, so no post-change G085 run exists.
  > **Why this is uncertain:** Pre-amendment passes cannot prove behavior after source bytes change.
  > **What would resolve this:** `bubbles.test` reruns the 71-assertion selftest, 16-assertion persistent regression, and regression-quality guard against the implemented scanner revision.
- [ ] `T-BUG-012-12` returns green after `T-BUG-012-11`, with the BUG-012 report, all raw evidence, and all 23 existing checked items unchanged.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning preserved all 23 checked items and excluded `report.md` from the implementation boundary.
  > **What was observed:** Current framework validation is documented as red on the unchanged live stale-reference scanner.
  > **Why this is uncertain:** A green broad result requires the authorized source repair and a fresh full execution.
  > **What would resolve this:** After `T-BUG-012-11` passes, `bubbles.test` runs `bash bubbles/scripts/cli.sh framework-validate` and verifies the protected report and checked-item baselines.
- [ ] `T-BUG-012-13` proves release-manifest freshness for only the repaired scanner and selftest entries and canonical release readiness remains green.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning verified that the generated release manifest already tracks both authorized scripts by SHA-256.
  > **What was observed:** Their implementation hashes remain unchanged during planning, so no generated hash refresh or post-change release result exists.
  > **Why this is uncertain:** Release readiness must evaluate the actual implemented script hashes.
  > **What would resolve this:** Implementation refreshes only the two existing manifest entries through canonical tooling and `bubbles.test` executes `bash bubbles/scripts/cli.sh release-check`.
- [ ] Independent boundary verification proves the scanner reconciliation changed only the two named scripts plus their generated release-manifest hashes; `report.md`, `uservalidation.md`, the G085 persistent regression, unrelated BUG-013/concurrent files, and `certification.*` remain byte-identical.
  > **Uncertainty Declaration**
  > **What was attempted:** Planning captured protected hashes and declared the exact allowed and excluded families.
  > **What was observed:** Planning changed only planning-owned packet surfaces; the implementation delta does not exist yet.
  > **Why this is uncertain:** Boundary compliance can be proven only after the implementation owner finishes the authorized edit.
  > **What would resolve this:** Independent test compares post-implementation hashes and changed paths against the baseline and fails on any excluded-family mutation.

### Sequential Gate

Scope 1 is the entire active execution inventory and remains **In Progress**. It cannot become Done until every Core Behavior item, every Test Plan mapping, the independent-test handoff items, and the Build Quality Gate have owner-tagged execution evidence. Only `bubbles.validate` may certify completion.

### Required Lifecycle Continuation

The scanner amendment reopens execution coverage only for the newly authorized bytes; it does not erase or rewrite prior G085 evidence. The required owner sequence is:

| Finding or phase | Current state | Required owner and gate |
| --- | --- | --- |
| `BUG012-SIMPLIFY-003` implementation | Planned, not executed | `bubbles.implement` authors only the two scanner scripts and required generated manifest hashes |
| Independent scanner verification | Required, not executed | `bubbles.test` executes `T-BUG-012-11` through `T-BUG-012-13` plus fresh G085 `71/71` and `16/16` preservation checks |
| Regression and simplification freshness | Required for amended bytes | `bubbles.regression`, then `bubbles.simplify`, re-evaluate the changed scanner behavior without altering preserved evidence |
| `BUG012-VAL-MODE-GAPS` re-entry | Required after fresh implementation/test/regression/simplify evidence | `bubbles.gaps` closes or re-routes `BUG012-SIMPLIFY-003`; it may claim the gaps phase only when the foreign-owned blocker is actually resolved |
| `BUG012-VAL-MODE-HARDEN` | Required and unexecuted | `bubbles.harden` audits the amended Test Plan and scanner contract after gaps closes |
| `BUG012-VAL-G022-STABILIZE` | Required and unexecuted | `bubbles.stabilize` runs in resolved order |
| `BUG012-VAL-MODE-DEVOPS` | Required and unexecuted | `bubbles.devops` validates release/install operational obligations in resolved order |
| `BUG012-VAL-G022-SECURITY` | Required and unexecuted | `bubbles.security` validates fail-closed and no-bypass behavior in resolved order |
| `BUG012-VAL-G090` | Blocked on absent real session snapshot | The authorized top-level session owner supplies `.specify/memory/bubbles.session.json`; no specialist reconstructs it from report prose |
| `BUG012-VAL-G022-VALIDATE` and `BUG012-VAL-G027` | Required and unexecuted on the amended lifecycle | `bubbles.validate` runs only after every preceding owner and real G090 input are satisfied; only validate may write `certification.*` |
| `BUG012-VAL-G022-AUDIT` and evidence-signal warning | Required and unexecuted on the amended lifecycle | `bubbles.audit` evaluates all executed and interpreted evidence only after validation passes |
| `BUG012-VAL-MODE-FINALIZE` | Prohibited until audit succeeds | The authorized top-level runner finalizes without implementation, certification, propagation, or release claims from planning |
| `BUG012-SIMPLIFY-004` | Addressed by gaps | Preserve the MD010 metadata and all 33 literal tab lines exactly; no additional owner action is planned |
| `BUG012-VAL-REALITY-DISCOVERY` and `BUG012-VAL-SCOPE-PROGRESS` | Preserved warnings | Planning records the concrete scanner paths here; validate alone controls scope-progress certification |

The persisted packet stays `in_progress`; `completedPhaseClaims` and every prior evidence block remain historical execution facts, not proof of the new scanner bytes. The next owner may be set to `bubbles.implement` only after planning artifact lint, freshness, traceability, JSON/Markdown mapping checks, and protected-byte checks all pass.

### Independent Test Handoff

**Status:** In Progress

The four finalized G085 independent-test items retain their current evidence.
The scanner amendment adds `T-BUG-012-11` through `T-BUG-012-13`, which have no
execution claim yet. The scope and packet remain nonterminal,
`certification.*` remains unchanged, and the route proceeds to implementation
only after the planning checks pass. Fresh scanner verification, G085
preservation checks, gaps re-entry, every named specialist phase, G027, and
G090 remain active and unclaimed.
