# IMP-053 — The pre-execution risk gate fails open on any unrecognized risk class

**Status:** IN PROGRESS 2026-08-19 — owner approved; SCOPE-1/2/3 implementation present; full framework validation pending
**Surface:** framework-health (G125) — owner-approved framework mutation under the Bubbles maintainer flow
**Motivation:** Audit of enforcement-vs-declaration asymmetries, continuing the class of defect closed by IMP-050 (a contract half that no gate enforced) and IMP-051 (declared enforcement that never ran). `pre-tool-risk-gate.sh` is a **live builtin PreToolUse hook** (`bubbles/hooks.json:3`) that decides ALLOW/WARN/BLOCK before an action executes. Its verdict is only as trustworthy as the risk class it reads, and both the class vocabulary and the registry that supplies it are under-enforced.
**Verified gaps addressed:** ARR-1 partial lint coverage, ARR-2 inert whole-file check, ARR-3 gate fails open on unrecognized class, ARR-4 unregistered command defaults to allow, ARR-5 stale registry entries, ARR-6 duplicated class vocabulary, ARR-7 lint has no selftest

## Provenance

Every claim below was derived by direct inspection and measurement of the shipped
tree, not from a runtime telemetry export. The inputs analyzed were:

| Input | What it established |
|---|---|
| `bubbles/scripts/pre-tool-risk-gate.sh` (328 lines) | `BLOCK_CLASSES` is an allow-list (line 51); the decision path ends in `# read_only / owned_mutation / anything else -> allow silently.` (line 327); an absent registry entry resolves to `read_only` (line 260) |
| `bubbles/hooks.json` (line 3) | the gate is a live builtin `PreToolUse` hook, so its verdict is enforced before execution rather than advisory |
| `bubbles/scripts/action-risk-registry-lint.sh` (88 lines) | `required_commands` names 9 commands (line 16); the final whole-file grep (line 86) is an alternation satisfied by any single `defaultRiskClass:` line |
| `bubbles/action-risk-registry.yaml` (113 lines) | 39 commands declared; classes used are `read_only` (29) and `owned_mutation` (10); `validRiskClasses` is a third copy of the vocabulary |
| `bubbles/scripts/cli.sh` `main()` dispatch (from line 4484) | 14 dispatched commands carry no registry entry; `autofix` has a registry entry but no dispatch case |
| Live `--risk-class` probes against the shipped gate | `destructive_mutation` exits 3, while `destructive_mutuation`, `destructive-mutation`, `DESTRUCTIVE_MUTATION`, and `totally_bogus_class` each exit 0 |
| Mutation runs against an isolated registry fixture (`BUBBLES_ACTION_RISK_REGISTRY`) | M1 control on required `doctor` exits 1; M2 bogus class on `status`, M3 removed `defaultRiskClass`, and M4 typo class on `upgrade` each exit 0 |
| Write-surface scan of each unregistered command's script | `closeout-report.sh:306,310`, `interop-intake.sh:288,326,366`, and `mcp-grant-sync.sh:117,118` write repository state; the remaining 11 show no non-temp writes |


## Problem (verified against source)

- **ARR-3 — the gate fails open on any unrecognized class (highest severity):** `bubbles/scripts/pre-tool-risk-gate.sh:51` defines `BLOCK_CLASSES` as an **allow-list** (`destructive_mutation external_side_effect`), and line 327 ends the decision path with the comment `# read_only / owned_mutation / anything else -> allow silently.` followed by `exit 0`. Any class string that is not spelled exactly right therefore falls through to ALLOW. Proven live against the shipped script via `--risk-class`:

  | class string | exit | meaning |
  |---|---|---|
  | `destructive_mutation` | 3 | BLOCK (correct) |
  | `external_side_effect` | 3 | BLOCK (correct) |
  | `destructive_mutuation` (typo) | **0** | **silently allowed** |
  | `destructive-mutation` (hyphen) | **0** | **silently allowed** |
  | `DESTRUCTIVE_MUTATION` (case) | **0** | **silently allowed** |
  | `totally_bogus_class` | **0** | **silently allowed** |

  A single-character error in the registry converts a blocking classification into a silent allow. The failure is undetectable at the point of use because the gate emits no diagnostic for an unknown class.

- **ARR-1 — the lint validates 9 of 39 registered commands:** `bubbles/scripts/action-risk-registry-lint.sh:16` hardcodes `required_commands` to nine names (`doctor runtime framework-validate release-check repo-readiness framework-events run-state policy recall`). `bubbles/action-risk-registry.yaml` declares **39** commands. The remaining 30 receive no class validation. Mutation-proven in an isolated fixture (M1 is the control that proves the lint is not inert):

  | mutation | exit | verdict |
  |---|---|---|
  | M0 unmodified registry | 0 | fixture valid |
  | M1 bad class on **required** `doctor` | 1 | correctly caught |
  | M2 bad class on **unvalidated** `status` | **0** | **not caught** |
  | M3 `defaultRiskClass` key **removed** from `status` | **0** | **not caught** |
  | M4 typo class on **unvalidated** `upgrade` | **0** | **not caught** |

  ARR-1 and ARR-3 compose: an invalid class can be introduced for 30 of 39 commands without the lint objecting, and the gate will then silently allow it.

- **ARR-2 — the final whole-file check is inert:** `action-risk-registry-lint.sh:86` runs `grep -E 'defaultRiskClass:|: (read_only|owned_mutation|destructive_mutation|external_side_effect|runtime_teardown)$' "$REGISTRY_FILE" >/dev/null`. The alternation makes this satisfied by **any single** `defaultRiskClass:` line, which every registry necessarily contains. It reads as a vocabulary check over the whole file but can never fail on a bad class. This is the same shape as the false enforcement claim removed under IMP-051.

- **ARR-4 — an unregistered command silently resolves to `read_only`:** `pre-tool-risk-gate.sh:260` is `printf '%s' "${value:-read_only}"`, so a command absent from the registry is treated as the lowest-risk class. Proven live: `--resolve totally-unregistered-command` prints `read_only`. Comparing the `main()` dispatch in `bubbles/scripts/cli.sh:4484` against the registry, **14** real commands are unregistered — including the mutating `closeout`, `release-train-backfill`, `work-tracker-project`, and `verify-changed-specs`, plus `eval`, `mcp`, `open-work`, `trajectory`, `interop`, `dashboard`, `list`, `audit`, and two selftest entry points. Note the deliberate contrast inside the same script: a missing **tool-trust** registry fails **closed** (line 145, `failing closed`), and an unknown recall operation defaults to `owned_mutation` (line 281). The CLI path is the one that fails open.

- **ARR-5 — stale registry entries:** `autofix` and `help` carry registry entries but have no dispatch case in `cli.sh main()`. Dead classifications drift out of step with reality and give false confidence that coverage is complete.

- **ARR-6 — the class vocabulary is duplicated with no shared authority:** the complete valid set is written in `action-risk-registry-lint.sh:15`; the block and warn subsets are written again in `pre-tool-risk-gate.sh:51-52`. Nothing binds them. A class added in one place and not the other produces exactly the silent-allow behavior in ARR-3. This is the duplicated-authority defect IMP-050 closed for release-packet doc names via a shared library.

- **ARR-7 — the lint has no selftest:** `bubbles/scripts/pre-tool-risk-gate-selftest.sh` exists, but there is no `action-risk-registry-lint-selftest.sh`. The lint runs live in `framework-validate.sh:951`, so it is trusted in the tier without any proof that it can fail. That is what allowed ARR-1 and ARR-2 to persist.

## Proposal

### SCOPE-1 — One class vocabulary, and a lint that validates every command (ARR-1, ARR-2, ARR-6, ARR-7)

- Add `bubbles/scripts/action-risk-classes-lib.sh` as the single authority for the class vocabulary, exporting the ordered valid set plus the block and warn subsets, mirroring the shape of `release-packet-docs-lib.sh` delivered under IMP-050. Bash-3.2-safe, source-guarded.
- Rewrite `action-risk-registry-lint.sh` to enumerate **every** command in the registry and validate each one's `defaultRiskClass` (and every `overrides:` value) against the shared vocabulary, reporting each offender by name. Retain the nine `required_commands` as an additional presence check so the existing contract is preserved, not replaced.
- Replace the inert line-86 grep with a real assertion over all extracted class values.
- Add `action-risk-registry-lint-selftest.sh` covering: clean registry passes; bad class on a required command fails; bad class on a previously unvalidated command fails; missing `defaultRiskClass` fails; bad `overrides` value fails; and an adversarial case proving no environment variable can suppress a finding.

**Decision:** the vocabulary lives in a sourced library rather than being duplicated a third time. The alternative — teaching the lint to parse the gate's `BLOCK_CLASSES` string — would couple a linter to a hook's internals and still leave two spellings of the truth.

### SCOPE-2 — The gate fails closed on an unrecognized class (ARR-3)

- Introduce an explicit "unrecognized class" branch in `pre-tool-risk-gate.sh`. A class string that is not in the shared valid vocabulary is an **integrity failure**, not a low-risk action, and MUST block with a distinct reason (`reason=unknown-risk-class`) and a non-zero exit rather than fall through to the silent allow at line 327.
- Preserve every existing verdict for every currently valid class, so `read_only` and `owned_mutation` continue to allow and `runtime_teardown` continues to warn. The change is observable only for strings that are already meaningless today.
- Extend `pre-tool-risk-gate-selftest.sh` with the four proven fall-through strings (typo, hyphen, case, garbage) asserting BLOCK.

**Decision:** fail closed on an *unrecognized* class, but deliberately do **not** change the `${value:-read_only}` default for *unregistered* commands in this scope. Those are different failures: an unknown class means the registry says something we cannot interpret, whereas an absent entry is a coverage gap best fixed by adding the entry (SCOPE-3). Flipping the unregistered default to block in the same change would turn a coverage gap into a live outage for 14 commands.

### SCOPE-3 — Registry/CLI parity, enforced (ARR-4, ARR-5)

- Add a parity check to the lint: every top-level command dispatched by `cli.sh main()` MUST have a registry entry, and every registry entry MUST correspond to a real dispatch case. Both directions, so neither gap nor staleness can reappear silently.
- Classify the 14 unregistered commands on evidence of what each actually does, and remove the two stale entries (`autofix`, `help`).
- Because parity is then mechanically enforced, the `read_only` default in ARR-4 stops being reachable through ordinary drift.

## Migration / rollout

- SCOPE-1 is additive (new library, new selftest, stricter lint) and lands first; it is what makes SCOPE-3's parity check expressible.
- SCOPE-2 is behavior-changing but only for inputs that are meaningless today; it depends on SCOPE-1's shared vocabulary.
- SCOPE-3 depends on SCOPE-1 and will surface real registry edits. Each scope is independently landable and independently revertible.
- No downstream repo action is required; the risk gate and registry ship inside `bubbles/` and propagate through the normal installer.

## Risks & mitigations

- **R1** SCOPE-2 could block a workflow that today relies on a misspelled class being silently allowed → such a path is already unsafe by definition; the full registry is validated first in SCOPE-1, so any offender is found and fixed before the gate turns strict.
- **R2** SCOPE-3's classification of 14 commands could be wrong in the conservative or the permissive direction → classify from observed behavior, not from the command's name; a command that writes state is never left `read_only`. Where evidence is ambiguous, choose the stricter class and record why.
- **R3** The parity check could be brittle against `cli.sh` dispatch formatting → extract only from the authoritative `main()` case block, and cover the extractor in the selftest so a formatting change fails loudly instead of silently emptying the check.
- **R4** A stricter lint could fail the tier on first run → run it against the real registry before landing and fix any offender in the same change, so the tier stays green.

## Acceptance criteria (when implemented)

- The lint validates all 39 registered commands; mutations M2, M3, and M4 above each exit non-zero, while the control M1 still exits non-zero and a clean registry still exits 0.
- `action-risk-registry-lint-selftest.sh` exists, passes, and is proven able to fail by mutation.
- `pre-tool-risk-gate.sh --risk-class destructive_mutuation` (and the hyphen, case, and garbage variants) exit non-zero with `reason=unknown-risk-class`; all currently valid classes keep their present verdicts.
- The class vocabulary appears in exactly one file; the lint and the gate both source it.
- Every `cli.sh` top-level command has a registry entry and every registry entry maps to a real command; the lint fails if either direction breaks.
- A full `framework-validate` run is green with the new checks executing, evidenced by an increased executed-check count.

## Files to touch (on approval)

`bubbles/scripts/action-risk-classes-lib.sh` (new shared vocabulary authority), `bubbles/scripts/action-risk-registry-lint.sh` (validate all commands, real whole-file assertion, parity check), `bubbles/scripts/action-risk-registry-lint-selftest.sh` (new coverage), `bubbles/scripts/pre-tool-risk-gate.sh` (fail closed on unrecognized class), `bubbles/scripts/pre-tool-risk-gate-selftest.sh` (fall-through cases), `bubbles/action-risk-registry.yaml` (register 14, drop 2 stale), `bubbles/scripts/framework-validate.sh` (register the new selftest), `bubbles/registry/gates.yaml` (gate id for the strengthened classification contract) — framework-owned surfaces, implemented under the Bubbles maintainer flow and certified by a full-tier run.
