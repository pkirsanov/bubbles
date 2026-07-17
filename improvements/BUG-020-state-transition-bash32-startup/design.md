# Bug Fix Design: BUG-020 State Transition Bash 3.2 Startup

## Design Brief

### Current State

`bubbles/scripts/state-transition-guard.sh` still enables
`set -euo pipefail` and sources `bubbles/scripts/fun-mode.sh` before contract
resolution. The committed baseline of `fun-mode.sh` uses `declare -A` and
`local -n`, and the intake reproduction records the resulting Bash 3.2
`gate_passed: unbound variable` abort before Check 8.

The current working-tree `fun-mode.sh` is different: it already contains the
candidate closed `case` dispatcher and positional-argument pool selector. That
candidate predates the final `test_27` bytes, so it has no valid scenario-first
RED lineage. Current direct API probes show that it sources and behaves on Bash
3.2 and Bash 5.3, but current full Bash 3.2 guard cases stop at the next two
independent boundaries: the resolver requires `jq` and `yq`, and its
fail-closed `block_contract` path then reaches BUG-022's empty-array nounset
abort.

### Target State

`fun-mode.sh` is one Bash-3.2-compatible shared implementation with the same
public functions, event messages, random pools, banner, output prefix, and
opt-in environment contract. Sourcing it performs no Bash-4-only operation, so
disabled fun mode is an immediate no-op and explicitly enabled fun mode remains
fully functional on both the declared Bash 3.2 baseline and newer Bash.

The full production guard is validated through a parser-aware Bash 3.2 lane
that keeps system directories first and appends only the real `jq`/`yq`
directories. The strict system-only lane validates the earlier startup boundary:
the guard passes fun-mode loading and reaches the resolver's explicit
`E009-REGISTRY-MISSING` precondition result rather than Check 8. After BUG-022
repairs result emission, that precondition must produce one complete BLOCKED
envelope with exit `2`.

The state-transition guard retains nounset, its source operation, all check
ordering, Check 8 bytes, structured result schema, and exit behavior. A genuine
governance finding still reaches the normal finding branch and exits nonzero;
BUG-020 creates no alternate guard path and absorbs no parser or empty-array
source change.

### Patterns to Follow

- Keep one shared fun-mode API in `bubbles/scripts/fun-mode.sh`; all current
   callers continue using `fun_mode_active`, `fun_message`, `fun_pass`,
   `fun_fail`, `fun_warn`, `fun_banner`, and `fun_summary` unchanged.
- Use the Bash-3.2-safe indexed arrays already present for the three random
   pools, shell `case` dispatch for named events, positional arguments for pool
   selection, and `printf`/existing output forms.
- Follow the production-process fixture style in
   `tests/regression/test_26_state_transition_spec_mjs_path.sh`: create complete
   disposable packets and invoke the canonical guard rather than a copied shell
   snippet.
- Follow `bubbles/scripts/state-transition-guard-selftest.sh` for managed-byte
   positive and genuine-finding twins, while keeping BUG-019 Check 8 fixtures
   and assertions unchanged.
- Use actual `/bin/bash` under a system-only `PATH` for parser-free source/API
   proof and resolver-precondition proof. Use a distinct parser-aware path,
   with system directories first, for full production Check 8 proof.
- Print the selected Bash version, resolved `bash`, `jq`, and `yq` paths, and
   timeout-tool absence so a newer shell or missing parser can never be
   mislabeled as Bash 3.2 integration evidence.
- Treat the current dirty fun-mode candidate as patch input only. Establish a
   new isolated RED-then-patch-then-GREEN lineage before any source blob becomes
   delivery-eligible.

### Patterns to Avoid

- Do not conditionally skip or locally redefine fun functions in
   `state-transition-guard.sh`; that would create a second presentation API and
   leave the shared startup defect in other consumers.
- Do not suppress source errors with `2>/dev/null`, `|| true`, `set +u`, or a
   subshell. Those forms hide optional-module failure instead of repairing it.
- Do not require Homebrew Bash, prepend a test-only executable to `PATH`, or
   treat GNU `timeout` as part of startup compatibility.
- Do not require a parser-dependent full guard to reach Check 8 on a PATH that
   intentionally excludes the required parsers. Do not copy or shim `jq`/`yq`;
   resolve the real binaries fail-loud for the integration lane.
- Do not relabel the earlier HEAD-restored fixture run as final-byte RED. It is
   historical diagnostic evidence only and cannot repair the original
   working-tree chronology.
- Do not replace associative arrays with `eval`, dynamically generated code, a
   dependency, a provider registry, or duplicated catalogs.
- Do not touch Check 8 extraction, BUG-019's `test_26`, downstream installed
   copies, certification, or generator-owned release metadata by hand.

### Resolved Decisions

- Repair the shared module itself; do not modify the state-transition
   entrypoint for shell-version branching.
- Replace associative event storage with one closed `case` dispatcher.
- Replace nameref pool selection with a positional-argument picker over the
   existing indexed arrays.
- Preserve full fun output when `BUBBLES_FUN_MODE=true`, including on Bash 3.2;
   there is no degraded or partially initialized mode.
- Preserve the existing absent/unset fun-mode contract as disabled and retain
   exact event text, random-pool membership, output prefix, and summary choice.
- Split validation into parser-free module, system-only resolver-precondition,
   and parser-aware full-guard contracts.
- Keep parser availability as a mandatory resolver precondition; BUG-020 does
   not weaken or reimplement registry parsing.
- Keep empty-array result emission owned by BUG-022; BUG-020 depends on its
   completion for Bash 3.2 full-guard and structured BLOCKED-result evidence.
- Supersede the invalid retroactive RED claim with a prospective isolated TDD
   restart: final test bytes first, known pre-fix fun-mode bytes second, RED,
   candidate patch application third, then identical-byte GREEN.
- Require newer-Bash compatibility, genuine pass/finding twins, adversarial
   construct checks, source/install/release provenance, and exact rollback.
- Leave status and certification blocked. The current requirement text must be
   reconciled by `bubbles.analyst` before `bubbles.plan` rewrites the executable
   test handoff.

### Open Questions

None for the technical architecture. One upstream contract contradiction is
open: `BR-020-001` and `BR-020-006` currently require Check 8 under a
system-only PATH, while the canonical resolver intentionally requires `jq` and
`yq`. The requirements owner must separate system-only startup proof from
parser-aware full-guard proof before planning can become coherent.

## Purpose and Scope

BUG-020 restores mandatory transition-governance startup on the repository's
declared macOS system-shell baseline without weakening governance or turning
fun mode into a state-transition-specific special case. The repair changes the
implementation mechanism of the existing optional presentation module, not its
observable contract.

The primary consumer is `state-transition-guard.sh`. The shared change makes
the same fun API sourceable by every direct consumer on Bash 3.2. It does not
redesign those consumers, remove their existing local compatibility shims,
change resolver prerequisites, repair guard result arrays, or broaden this bug
into repository-wide shell modernization.

## Root Cause and Falsifiable Boundary

### Startup Sequence

The controlling production path is:

```text
/bin/bash state-transition-guard.sh <packet>
   -> set -euo pipefail
   -> source fun-mode.sh
          -> resolve optional mode value
      -> committed baseline initializes associative catalog [BUG-020]
      -> committed baseline defines nameref picker          [BUG-020]
   -> source guard-lib.sh
   -> source scan-lib.sh
   -> resolve transition contract using jq + yq                [precondition]
      -> block_contract on unavailable parser
      -> empty failed_check_ids expansion                  [BUG-022]
   -> run Checks 1..N, including Check 8
   -> emit TRANSITION_GUARD_RESULT_V1
```

In Bash 3.2, `declare -A` is not an associative-array declaration. The first
`[gate_passed]=...` initializer is interpreted through indexed-array arithmetic
semantics, and caller nounset turns the key token into the observed unbound
variable. `local -n` is a second unsupported construct that would fail only
after enabled fun mode reached random selection.

### Discriminating Checks

The BUG-020 source hypothesis is falsified if the known pre-fix fun-mode blob
sources successfully under Bash 3.2 nounset, if the current candidate still
emits an associative-array/nameref startup diagnostic, or if any public event,
pool, banner, summary, mode, output, or return contract differs between the
candidate and the committed baseline on a supported newer Bash.

The full-guard hypothesis is evaluated separately. A strict system-only PATH
must stop at `E009-REGISTRY-MISSING` after fun-mode loading; reaching Check 8
there would mean parser policy changed. A parser-aware Bash 3.2 lane must pass
the resolver and reach Check 8; stopping at `failed_check_ids[@]` or another
empty array is BUG-022 evidence, not evidence against the fun-mode repair.

Targeted source and execution reject the old one-boundary model: direct fun API
cases pass on Bash 3.2 and Bash 5.3, `transition-contract-resolver.sh` explicitly
requires `jq` and `yq`, and `state-transition-guard.sh::block_contract` records
its first failed check through the BUG-022-owned empty array.

## Multi-Boundary Architecture

| Boundary | Input contract | BUG-020 success signal | Ownership on failure |
| --- | --- | --- | --- |
| Fun module source/API | Bash 3.2 or newer Bash; system-only tools are sufficient | source succeeds under nounset; disabled calls are silent; enabled event, pool, banner, and summary contracts are unchanged | BUG-020 |
| Resolver precondition | Bash 3.2; exact system-only PATH with no `jq`/`yq` | no fun startup error; resolver emits `E009-REGISTRY-MISSING`; after BUG-022, one BLOCKED result and exit `2` | parser policy remains canonical; result truncation is BUG-022 |
| Production guard integration | Bash 3.2 or newer Bash; system directories first; real `jq`/`yq` directories appended fail-loud | pass and genuine-finding fixtures reach Check 8 once, emit one result, and preserve exits with fun mode false and true | BUG-022 for empty-array aborts; other guards route by their own finding IDs |
| Release/install projection | settled canonical source/test set | managed fun-mode and selftest bytes install identically; `test_27` stays source-only; release identity is generated and verified | `bubbles.releases` |

These are sequential evidence boundaries, not alternate implementations. The
same `fun-mode.sh` bytes execute in every lane. Parser-aware PATH construction
is dependency availability for the real resolver, not a production fix, test
shim, or shell-selection fallback.

## Selected Architecture

### Portable Event Dispatch

Replace `_FUN_MESSAGES` with one internal dispatcher that accepts an event name
and selects its existing canonical message through a closed `case` statement.
Every current event remains a distinct branch. The dispatcher writes the
message only for a recognized event and returns no message for an unknown event,
preserving the current `${_FUN_MESSAGES[$event]:-}` behavior without a default
message.

`fun_message` keeps its public sequence:

1. return `0` immediately when fun mode is disabled;
2. require its existing event argument;
3. ask the internal dispatcher for that event's canonical text; and
4. emit the unchanged `🫧` line prefix only when text exists.

No event is inferred, substituted, or mapped to another event. Unknown events
remain silent optional presentation events and do not alter governance output
or status.

### Portable Random-Pool Selection

Keep `_FUN_PASS_POOL`, `_FUN_FAIL_POOL`, and `_FUN_WARN_POOL` as indexed arrays,
which Bash 3.2 supports. Change `_fun_random_pick` to receive pool elements as
ordinary positional arguments. It computes the same `RANDOM % count` index,
shifts to that element, and prints it without a nameref or `eval`.

The three wrappers pass their existing pool expansions to the helper. Pool
membership, random modulo behavior, output prefix, and wrapper return behavior
remain unchanged. An empty internal pool is an implementation defect, not a
reason to invent a default quip; the implementation must keep all declared
pools nonempty and its focused test must exercise each wrapper.

### Optional-Mode Semantics

The environment contract remains closed:

| `BUBBLES_FUN_MODE` input | Behavior on Bash 3.2 and newer Bash |
| --- | --- |
| unset | source succeeds; all public fun calls are no-ops |
| `false` | source succeeds; all public fun calls are no-ops |
| `true` | source succeeds; banner, named messages, wrappers, and summary emit their existing fun output |
| any other value | preserve current non-active behavior; do not invent truthy aliases |

Unset-to-disabled is the pre-existing optional feature contract, not a fallback
for missing required configuration. No required governance input is defaulted,
and shell capability does not choose a different implementation.

### Governance Isolation

`state-transition-guard.sh` remains unchanged. In particular:

- `set -euo pipefail` stays active before the source operation;
- source failures are not swallowed;
- `fun_banner` and `fun_message guard_start` remain after the guard header;
- `fail()` and `warn()` retain their existing governance counters and call fun
   output only after recording the normal operator-visible diagnostic;
- Check 8 extraction, path validation, failure attribution, and
   `Check-8-file-existence` identifiers remain byte-for-byte unchanged; and
- `emit_transition_result` remains the only structured result authority.

The shared fun module has no permission to mutate guard counters, state files,
transition contracts, check arrays, exit status, or result fields. Presentation
output can decorate a result but cannot suppress, replace, or manufacture one.

The unchanged guard is a consumer, not proof that all of its own prerequisites
and internals are BUG-020-owned. Registry parser availability is resolved by
`transition-contract-resolver.sh`. Empty-array traversal and result emission are
owned by BUG-022. BUG-020 may consume their verified behavior but may not edit
either boundary or claim their failures as fun-mode GREEN.

### Single-Implementation Justification

This is a narrow compatibility repair inside the existing shared fun-mode
utility. One portable implementation can satisfy Bash 3.2 and every newer Bash
consumer while preserving one public contract. A version-selected loader,
adapter registry, duplicate catalog, or state-transition-only no-op layer would
add divergence without representing a real second implementation.

## Public Contract and Error Model

No CLI, endpoint, persisted schema, or external API changes. The internal shell
contract remains:

| Function | Input | Disabled result | Enabled result |
| --- | --- | --- | --- |
| `fun_mode_active` | none | nonzero predicate | zero predicate |
| `fun_message` | one known/unknown event | exit `0`, no output | known event emits canonical line; unknown event emits nothing |
| `fun_pass` | none | exit `0`, no output | one existing pass-pool line |
| `fun_fail` | none | exit `0`, no output | one existing fail-pool line |
| `fun_warn` | none | exit `0`, no output | one existing warn-pool line |
| `fun_banner` | none | exit `0`, no output | existing three-line banner |
| `fun_summary` | result and optional failure count | exit `0`, no output | existing pass/blocked/failed event selection |

Required arguments retain normal nounset behavior; this bug does not loosen API
misuse into a default. The source operation itself must return zero on every
supported Bash version because it performs only definitions and portable static
initialization.

## Consumer Impact

### Direct Shared-Module Consumers

Current direct consumers are:

- `agnosticity-lint.sh`, `artifact-freshness-guard.sh`, `artifact-lint.sh`,
   `cli.sh`, `done-spec-audit.sh`, `handoff-cycle-check.sh`,
   `regression-quality-guard.sh`, `report-section-autofix.sh`,
   `spec-dashboard.sh`, `state-transition-guard.sh`, and
   `value-selection-lint.sh`, which source the shared module directly;
- `implementation-reality-scan.sh` and `traceability-guard.sh`, which currently
   install local no-op functions instead of sourcing it below Bash 4; and
- `project-scan-setup.sh`, which currently suppresses an optional source
   failure.

The selected implementation preserves every public function used by those
consumers. Newer-Bash callers see the same disabled silence and enabled text.
The primary state-transition caller gains Bash-3.2 startup. Existing local
fallbacks in implementation reality and traceability remain unchanged and
therefore preserve their current Bash-3.2 behavior; removing that duplication
would be a separate consumer cleanup, not BUG-020 work. Project-scan's existing
source suppression is likewise not changed here.

### Downstream and Release Consumers

`fun-mode.sh` and `state-transition-guard.sh` are managed framework files.
Canonical tests must prove their intended classification, then generated
release metadata must be regenerated by its owner. Downstream repositories
receive the repaired managed byte only through the supported Bubbles
install/upgrade path. No product repository may receive a direct
`.github/bubbles/scripts/` patch.

## Data, Configuration, Security, and Privacy

There is no data model, storage, migration, network, authentication, secret,
PII, telemetry, deployment, or release-train configuration change. No new
environment variable or feature flag is introduced.

The implementation must not use `eval`, indirect code generation, command
execution, or external input as a `case` body. Event names select only constant
repository-owned strings. Random pool values remain constant strings passed as
arguments. This removes unsupported shell features without creating a command
injection or dynamic lookup surface.

## Portability Strategy

### Runtime Baselines

The same source must run under:

- macOS `/bin/bash` 3.2.57 with `PATH=/usr/bin:/bin:/usr/sbin:/sbin` for direct
   module and resolver-precondition evidence;
- macOS `/bin/bash` 3.2.57 with system directories first and the real resolved
   `jq`/`yq` directories appended for full guard evidence; and
- the repository's newer Bash environment on Linux/macOS for compatibility.

Portable implementation forms are limited to Bash-3.2 functions, `case`,
indexed arrays, positional parameters, arithmetic expansion, `[[ ... ]]`, and
existing output commands. Do not add associative arrays, namerefs,
`mapfile`/`readarray`, `[[ -v ]]`, Bash-4 case conversion expansions, GNU-only
utilities, or a `uname` branch.

### Mechanical-Lint Limitation

`bubbles/scripts/macos-portability-guard.sh` currently checks 13 construct
classes but does not detect `declare -A`, `local -n`, or `declare -n`. Therefore
the already planned 13-class lint is useful but cannot prove this root cause is
absent. BUG-020 must add a focused known-root-cause assertion in its dedicated
regression or managed selftest and must execute the real source under actual
Bash 3.2. Extending the generic portability guard is outside this packet's
minimal change boundary.

The parser-aware lane resolves `jq` and `yq` before sanitizing the child
environment, rejects missing binaries, de-duplicates their directories, keeps
`/usr/bin:/bin:/usr/sbin:/sbin` before them, and asserts that child `bash`
resolves to `/bin/bash`. It does not create replacement executables or add a
newer Bash directory.

On a host where `/bin/bash` is newer than 3.2, the regression still proves the
production flow and fun behavior but must label Bash-3.2 proof as unavailable.
Completion requires current executed evidence from a real macOS system Bash
3.2 run; a Linux or newer macOS Bash pass is additional compatibility proof.

## Scenario-First RED/GREEN Architecture

### Persistent Production Regression

`tests/regression/test_27_state_transition_bash32_startup.sh` is the source-only
production-path regression. Its next planner/test-owned revision must split the
three boundaries above instead of requiring all guard cases to reach Check 8 on
the parser-free PATH. It resolves the canonical guard and fun module, creates
one unique temporary repository, copies the minimum canonical managed surfaces
needed by the real code, builds complete isolated packet fixtures, and removes
the temporary parent on `EXIT`, `INT`, and `TERM`.

No `timeout`, `gtimeout`, newer-Bash substitution, parser shim, test-only fun
function, copied catalog, copied resolver, or copied result emitter
participates. Each child output is captured for assertions and printed in full
with its exit.

### Scenario Matrix

| Lane | Shell and PATH | Cases | Required assertions |
| --- | --- | --- | --- |
| Module API | Bash 3.2 system-only, then newer Bash | false and true | source under nounset; all seven public functions; all events; unknown silence; pool membership; banner; summary; exact mode and return behavior |
| Resolver precondition | Bash 3.2 system-only | false and true | no fun startup error; no Check 8 claim; exact `E009-REGISTRY-MISSING`; after BUG-022, one BLOCKED envelope and exit `2` |
| Full guard | Bash 3.2 parser-aware, then newer Bash parser-aware | false/true pass and false/true genuine finding | Check 8 once; one result; fixture-controlled exit; disabled silence; enabled output; exact genuine failed-check identity |
| Root-cause adversary | canonical source inspection plus both runtime roles | candidate bytes | reject `declare -A`, `local -n`, and `declare -n`; reject event/pool drift; reject early success or missing case counts |

The current `scopes.md`, `test-plan.json`, and `scenario-manifest.json` still
encode the falsified system-only full-guard matrix and contain independent
machine-handoff drift. `bubbles.plan` must reconcile those artifacts only after
the requirements owner separates the two PATH contracts.

### Evidence Lineage Classification

The report's earlier run that copied current framework surfaces and restored
`HEAD:bubbles/scripts/fun-mode.sh` is useful diagnostic evidence: it proves the
known pre-fix blob still triggers the intended Bash 3.2 startup failure. It is
not `T-BUG-020-00` evidence because the working-tree candidate edit preceded
the final regression bytes. Neither byte equality nor a later fixture can
rewrite that chronology.

The current-source run is also not RED or GREEN. It proves the candidate clears
the fun startup boundary, then stops at parser availability and BUG-022. Its
direct API passes remain controls inside an overall nonzero execution.

### Prospective TDD Restart

BUG-020 recovers scenario-first integrity only through a new, explicitly
superseding isolated lineage:

1. `bubbles.plan` defines the split lane matrix and a restart evidence record.
2. `bubbles.test` finalizes the revised `test_27` bytes and records their digest.
3. In an isolated worktree or owned temporary source projection, test ownership
   stages the current protected dependency snapshot plus the exact known pre-fix
   `fun-mode.sh` blob. The main dirty worktree is not reset or rewritten.
4. The final test bytes run first. Valid RED requires the module/API and
   parser-aware guard lanes to fail at the historical fun-mode discriminator,
   while fixture construction, parser resolution, and protected dependencies
   pass their controls.
5. Only after that RED, implementation applies the portable fun-mode patch to
   the same isolated lineage. The current dirty candidate may supply patch
   content, but its earlier chronology supplies no evidence.
6. Test ownership reruns the identical test digest and commands for GREEN.
7. Only the post-RED source blob produced by that lineage is delivery-eligible;
   it must match the reviewed public-contract and containment assertions before
   integration into the canonical worktree.

This restart supersedes the invalid lineage; it does not relabel or erase it.
There is no `--red`, inverted assertion set, early return, expected-broken
success, or TDD waiver.

### GREEN and Non-Vacuity

After the isolated post-RED shared-module edit, identical regression bytes must
execute every lane and require the planned run/assertion counts. The module lane
must pass on both shells. The system-only guard lane must reach and faithfully
report the resolver precondition, not Check 8. The parser-aware guard lanes must
reach Check 8 and produce fixture-controlled results. No associative, nameref,
unbound-variable, bad-declare-option, or unrelated startup diagnostic may
appear.

The genuine-finding twins prevent a vacuous fix that exits early, prints a fake
Check 8 marker, or forces success. The explicit enabled cases prevent a fix that
silently no-ops fun mode on Bash 3.2. A focused source assertion prevents the
known constructs from returning unnoticed on modern-shell CI, while actual
Bash-3.2 execution remains the authoritative portability proof.

BUG-022 is a hard prerequisite for interpreting complete Bash 3.2 guard result
envelopes. Before BUG-022 GREEN, BUG-020 may report only module-level passes and
the exact foreign blocker; it may not mark ordered test rows complete from a
partially executed aggregate command.

### Managed and Broad Validation

The managed `state-transition-guard-selftest.sh` receives equivalent
disabled/enabled pass and genuine-finding twins using the production guard. The
source-only regression is registered once through `framework-validate.sh`, and
`install-provenance-selftest.sh` asserts that the shared source is managed while
`test_27` remains source-only and release-recorded.

Validation order after upstream contract reconciliation is:

1. final revised regression bytes and protected baseline identities;
2. prospective isolated pre-fix RED;
3. portable shared-module patch in the same isolated lineage;
4. identical-byte module and parser-aware GREEN under actual Bash 3.2;
5. newer-Bash compatibility and system-only resolver-precondition cases;
6. BUG-022 completion evidence and one fresh full BUG-020 matrix rerun;
7. managed state-transition selftest and genuine-finding twins;
8. regression-quality, syntax, root-cause, current 13-class portability, and
   exact changed-file boundary checks;
9. packet artifact lint, freshness, capability-foundation, and traceability;
10. full `framework-validate` after focused checks are green;
11. owner-generated release reconciliation, install provenance, and
   `release-check`; and
12. independent validation/certification only after all findings close.

No design-phase inspection is delivery evidence, and a modern-shell pass never
substitutes for the real Bash-3.2 row.

## Exact Change and Ownership Boundary

### Authorized Later Source and Test Surfaces

- `bubbles/scripts/fun-mode.sh`: portable event dispatch and random selection
   only; event text, pools, public names, mode contract, and output format stay
   stable;
- `tests/regression/test_27_state_transition_bash32_startup.sh`: dedicated
   source-only production regression;
- `bubbles/scripts/state-transition-guard-selftest.sh`: focused BUG-020
   disabled/enabled and genuine-finding twins only;
- `bubbles/scripts/framework-validate.sh`: one source-only regression
   registration;
- `bubbles/scripts/install-provenance-selftest.sh`: exact managed/source-only
   provenance assertions;
- generator-owned `bubbles/release-manifest.json`, only through the release
   owner after source/test bytes settle; and
- BUG-020 artifacts, only by their canonical artifact owners.

No production edit to `state-transition-guard.sh`, the resolver, or parser
policy is selected. BUG-022 may independently change its mapped empty-array
sites under its own packet; BUG-020 consumes those settled bytes without
claiming authorship. If the prospective restart disproves the portable
fun-module repair, implementation must stop and return to `bubbles.design`; it
may not expand this source boundary inline.

### Excluded Surfaces

- Check 8 implementation, result schema, transition profiles, nounset, and
   `tests/regression/test_26_state_transition_spec_mjs_path.sh`;
- BUG-012, BUG-013, BUG-018, BUG-019, BUG-021, BUG-022, IMP-020, and their
   packet/test bytes;
- `transition-contract-resolver.sh`, parser requirements, and every BUG-022
   empty-array/result-emission site in `state-transition-guard.sh`;
- `implementation-reality-scan.sh`, `traceability-guard.sh`, and their existing
   local Bash-3.2 no-op hooks;
- the generic portability guard and its 13-class contract;
- downstream `.github/bubbles/**` installations;
- release-train/feature-flag config, deployment, monitoring, backup, secrets,
   and product repositories;
- hand-edited generated release metadata, certification fields, terminal
   status, commits, and pushes; and
- unrelated dirty or concurrent worktree bytes.

Shared registration files must be edited surgically around concurrent work.
The owner may not revert or normalize unrelated changes to obtain a clean diff.

## Failure Handling, Observability, and Operations

This utility has no runtime service or telemetry plane. Its observable contract
is process output and exit status. Regression output must include the selected
Bash version, fun-mode input classification, full child guard output, guard
exit, run/assertion totals, Check 8 marker count, structured-result marker
count, and final test verdict.

Unexpected source or helper failure remains visible under `set -euo pipefail`;
the design does not catch-and-continue. The optional layer is made safe by
using supported constructs, not by hiding errors. Guard findings remain visible
through existing diagnostics, counters, structured fields, and nonzero exits.

`E009-REGISTRY-MISSING` is the expected fail-closed result when the strict
system-only lane excludes the required parsers. It is not a fun-mode failure
and must not be converted into Check 8 success. A truncated or wrong-status
result after that diagnostic is BUG-022 evidence. The parser-aware lane is the
only lane authorized to make Check 8 and genuine-finding assertions.

## Rollout and Rollback

Rollout begins in isolation. The revised final test is staged against the known
pre-fix fun blob, RED is captured, and the portable patch is applied afterward
in the same owned lineage. If RED is invalid or GREEN fails, remove that owned
lineage and leave the original dirty worktree unchanged; do not reset, checkout,
or rewrite unrelated bytes.

After focused and dependency checks pass, rollout is one canonical release
unit: portable shared source, managed selftest, source-only regression,
framework registration, provenance assertion, owner-generated manifest, then
supported downstream upgrade. No downstream patch precedes canonical release
proof.

Pre-release rollback reverses only the reviewed fun-mode patch against the
recorded isolated base while preserving every other source identity. Released
rollback restores the previous validated canonical release and its generated
manifest together through normal release/install provenance. It does not retain
a state-transition-only shim, disable nounset, remove the regression, patch
BUG-019/BUG-022, or hand-edit downstream copies. Because there is no data or
configuration migration, rollback has no state conversion step.

## Alternatives and Tradeoffs

| Alternative | Decision | Reason |
| --- | --- | --- |
| Gate the source operation on `BASH_VERSINFO` and install local no-op functions | Rejected | Silently discards requested fun behavior on the declared baseline, duplicates the API, and leaves other direct consumers vulnerable. |
| Keep two shared implementations selected by Bash version | Rejected | One portable implementation preserves all behavior; dual catalogs can drift and add unnecessary branching. |
| Disable nounset while sourcing | Rejected | Hides the observed key-expansion symptom, leaves unsupported namerefs, and weakens mandatory guard startup. |
| Suppress source errors and continue | Rejected | Converts initialization defects into silent partial state and violates fail-closed governance. |
| Require Homebrew/newer Bash | Rejected | Contradicts the declared macOS system-Bash baseline and fails under sanitized `PATH`. |
| Replace the catalog with an external file/parser | Rejected | Adds I/O, parser failure modes, and a new dependency for constant optional text. |
| Use `eval` for indexed-array indirection | Rejected | Creates avoidable code-evaluation risk; positional arguments preserve the pool contract directly. |
| Patch BUG-019's test or Check 8 | Rejected | The abort precedes Check 8 and those bytes belong to BUG-019. |
| Make a parser-dependent guard reach Check 8 on the strict system-only PATH | Rejected | Contradicts the resolver's explicit `jq`/`yq` precondition and would require a parser shim, copied parser, or policy weakening. |
| Count the earlier HEAD-restored fixture as final-byte RED | Rejected | The candidate source edit preceded the final test bytes; a later fixture cannot alter that chronology. |
| Waive TDD and use intake reproduction plus current API passes | Rejected | `bugfix-fastlane` requires scenario-first evidence; partial controls cannot replace the missing lineage. |
| Prospective isolated RED then patch then GREEN restart | Selected | Establishes a truthful new chronology without resetting unrelated dirty work or claiming the original edit was test-first. |

## No-Default and No-Bypass Reasoning

- No shell-version default chooses a substitute implementation; all supported
   shells execute the same portable code.
- No missing required guard input receives a value. The existing unset fun-mode
   value means opt-out because fun mode is optional by contract.
- No unknown event receives a generic message; it remains non-emitting as it
   does today.
- No empty pool receives a default quip; declared pools remain explicit and
   tested.
- No source failure, stderr, finding, check, or nonzero exit is suppressed.
- No `--skip`, `--force`, `--ignore`, `--insecure`, PATH shim, or environment
   bypass is added.
- The parser-aware lane resolves mandatory real dependencies fail-loud and keeps
   system Bash first; it does not invent a parser or substitute a shell.
- No fun-mode branch can mark a gate passed, alter Check 8, or emit the
   structured transition result.

The repair is fail-closed because governance still stops on a real mandatory
error or finding; only the optional module's unsupported implementation is
removed. It does not make governance permissive.

## Complexity Tracking

| Decision | Simpler alternative | Why rejected |
| --- | --- | --- |
| Separate module, resolver-refusal, and parser-aware full-guard lanes | Use one literal system-only command for every assertion | A literal system-only `PATH` removes mandatory `yq` and cannot exercise Check 8; one lane would conflate shell portability with dependency absence. |
| Depend on BUG-022 instead of widening BUG-020 | Patch `failed_check_ids[@]` locally | The observed line is one site in BUG-022's broader masked zero-state defect and requires its own final-byte RED before any guard edit. |
| Prospective isolated RED-patch-GREEN lineage | Treat the later HEAD-restored fixture as valid RED | The candidate source edit preceded final `test_27` bytes; a later fixture cannot retroactively establish test-first chronology. |

## Risks and Open Questions

Technical design has no open decision. Execution remains blocked by owned
upstream and sibling contracts:

- `bubbles.analyst` must reconcile the system-only Check 8 requirement with the
   resolver's mandatory parser precondition;
- `bubbles.plan` must then replace the falsified matrix and malformed/drifted
   `test-plan.json` rows with the split-lane restart contract; and
- BUG-022 must complete its own planned repair before BUG-020 can claim complete
   Bash 3.2 guard envelopes.

Bounded delivery risks are:

- event text or random-pool membership may drift during the mechanical rewrite;
   exact compatibility assertions must compare the closed event inventory and
   pool membership before release;
- modern-shell CI can pass while not proving Bash 3.2; the test must report its
   shell version and completion must include a real macOS `/bin/bash` run;
- the current portability guard does not detect the root-cause constructs; the
   dedicated source assertion and real runtime case are mandatory; and
- shared registration or generated release files may contain concurrent work;
   later owners must preserve it and stop on an unresolved collision.

## Superseded Design Decisions

The following earlier decisions are historical and non-authoritative:

- The one-source architecture that treated portable `fun-mode.sh` as sufficient
   for the complete production path is superseded. It omitted mandatory registry
   parser availability and Bash 3.2 empty-array result semantics.
- The literal system-only `PATH` production Check 8 command is superseded. That
   environment remains valid only for direct fun API and resolver-precondition
   evidence; full guard proof uses system Bash with real parser directories
   appended after system directories.
- The claim that `state-transition-guard.sh` remains byte-identical throughout
   all prerequisites is superseded. BUG-020 still may not edit it, but BUG-022
   may apply its independently planned and tested empty-array repair.
- The earlier final-byte RED claim is superseded. Both the HEAD-restored fixture
   and the parser-blocked current-source run remain historical evidence, not
   authorization for a BUG-020 production edit.
