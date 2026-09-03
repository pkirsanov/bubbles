# BUG-033 Design — Receipt Target Grouping And Wrapper Normalization

## Design Brief

### Current State

Check 43 in
[state-transition-guard.sh](../../bubbles/scripts/state-transition-guard.sh)
already contains the facet-1 target grouping and facet-2 recursive shell,
`env`, and assignment normalization. Those two facets remain active but
uncertified. The same normalizer does not recognize bounded process launchers.
The current refusal is one truncated prose line rather than the stable terminal
contract now required by [spec.md](spec.md).

### Target State

Check 43 will classify direct, `timeout`, `gtimeout`, and the exact portable
Perl alarm launcher by the command that produced the receipt. Unsupported
launcher syntax will remain identity-bearing data. Every classified collision
group will emit a plain-text, machine-extractable accepted or refused verdict.

### Patterns to Follow

- Keep identity derivation inside the single Check 43 jq program in
  [state-transition-guard.sh](../../bubbles/scripts/state-transition-guard.sh).
- Extend the existing decreasing recursive `strip_wrappers` pattern instead of
  adding a shell parser or executing recorded text.
- Extract the production jq definitions in
  [receipt-identity-selftest.sh](../../bubbles/scripts/receipt-identity-selftest.sh)
  so focused tests cannot drift into a second implementation.
- Drive the complete guard in
  [state-transition-guard-selftest.sh](../../bubbles/scripts/state-transition-guard-selftest.sh)
  for exit behavior and terminal diagnostics.

### Patterns to Avoid

- Do not treat any `perl -e` program as transparent. Only the exact
  alarm-and-`exec` program is a supported launcher.
- Do not accept timeout options or infer missing operands. Unsupported grammar
  must remain visible in identity and diagnostics.
- Do not reuse the current one-line clone sentence or its 800-byte truncation.
  It cannot expose one stable reason or preserve complete compared identities.
- Do not reparse command text with `eval`, a shell, or a new general parser.

### Resolved Decisions

- Launcher recognition is an exact token-prefix match over the current command
  tokenization.
- Every recognized branch consumes at least one token and recurses, so wrapper
  order does not change the result and recursion always terminates.
- Command identity, target proof, provenance proof, category validity, and exit
  compatibility remain separate classification dimensions.
- Diagnostics use ordered ASCII `key=value` fields and never depend on color.
- Facets 1 and 2, the empty-stdout exemption, and BUG-032 provenance bounds stay
  active without relaxation.

### Open Questions

None. The reconciled specification fixes the accepted grammar, refusal bounds,
diagnostic vocabulary, and test surfaces.

## Root-Cause Analysis

Check 43 asks whether two incompatible claims cite the same substantive stdout.
It groups receipts on `stdoutHash`, then tests whether each collision contains
**deterministic siblings**. Such siblings use the same validator, category, and
exit status over different targets. They also carry independent execution
provenance.

Both defects live in how "the same validator" and "different targets" are
computed, not in the question itself.

### Facet 1 — the distinctness test is applied to the wrong list

```jq
| ($rows | map(target_identity)) as $targets
...
and ($targets | all_distinct_nonempty)
```

`$rows` is every colliding RECEIPT. `all_distinct_nonempty` requires
`unique | length == length`. So the predicate is not "the identities ran over
different targets" — it is "no target appears twice in the log". Re-running a
validator is normal and expected, so the second run of anything fails it.

The intent was to prevent one target from vouching for two identities. That
intent is preserved exactly by taking one representative target **per command
identity**:

```jq
| ($rows | group_by(.cmd | cmd_identity) | map(.[0] | target_identity)) as $targets
```

Now the list has one entry per identity. Two identities over one target still
produce a duplicate and still refuse. N re-runs of one identity contribute one
entry and cannot fail on repetition.

`provenance_identity` distinctness stays measured **per receipt**, deliberately.
That is the condition that proves each receipt is an independent execution, and
weakening it would be the actual widening.

### Facet 2 — the family is read off the wrong token

```jq
( . / " " | map(select(length > 0)) ) as $raw
| ( if (($raw[0] // "") == "bash") or (($raw[0] // "") == "sh")
    then $raw[1:] else $raw end )
```

This strips ONE token, and only if it is literally `bash` or `sh`. Consequences,
all observed:

| Spelling | Family before | Correct family |
| --- | --- | --- |
| `node -e x` | `node` | `node` |
| `env P=1 node -e x` | `env` | `node` |
| `zsh -c node -e x` | `zsh` | `node` |
| `P=1 node -e x` | `P=1` | `node` |
| `bash -c node -e x` | `-c` | `node` |

Four of five spellings of one command produce a wrong family. One spelling
produces a FLAG as the family. The repair recursively strips these transparent
prefixes:

```jq
def strip_wrappers:
  if ((.[0] // "") | test("^(bash|sh|zsh|ksh|dash)$"))
    then (if ((.[1] // "") == "-c") then (.[2:] | strip_wrappers) else (.[1:] | strip_wrappers) end)
  elif ((.[0] // "") == "env") then (.[1:] | strip_wrappers)
  elif ((.[0] // "") | test("^[A-Za-z_][A-Za-z0-9_]*=")) then (.[1:] | strip_wrappers)
  else . end;
```

Recursion matters: `env A=1 zsh -c cargo test` has three stacked prefixes, and a
single-pass strip would collapse one of them and stop.

### Facet 3 — bounded launchers replace the evidence-producing command

The current recursion stops on `timeout`, `gtimeout`, and `/usr/bin/perl`.
`command_family` and `cmd_identity` therefore describe the launcher rather than
the underlying validator. This splits direct and bounded spellings of one
command, while two different commands behind the same launcher can collapse to
one launcher identity.

The repair must add only the two launcher grammars named by the specification.
A supported launcher prefix is transparent for command identity, but its
receipt `exitCode` remains unchanged and continues through the independent exit
compatibility check. A malformed or unsupported prefix remains part of the
identity. Recorded command text remains data and is never executed.

## Impact Analysis

- **Blast radius:** every repository that installs `state-transition-guard.sh`.
  A false CLONE refuses a transition while alleging forgery, so the defect both
  blocks honest work and mislabels it.
- **Direction of the change:** strictly toward ACCEPTING more logs. That makes
  the bound the whole safety argument, so each facet ships with an adversarial
  case that must still REFUSE.
- **Nothing else in Check 43 moves.** The empty-stdout exemption (BUG-007) and
  provenance requirement are untouched. The category and family compatibility
  rules are also untouched. Each keeps a pin in the regression set.

## Purpose And Scope

This design extends Check 43's existing receipt-identity calculation and its
terminal verdict. It does not change the receipt schema, evidence categories,
empty-output policy, guard entry point, certification state, or any other guard
check.

The behavior is local to three planned implementation surfaces:

1. The Check 43 jq classifier and its terminal renderer in
   [state-transition-guard.sh](../../bubbles/scripts/state-transition-guard.sh).
2. Focused production-definition extraction in
   [receipt-identity-selftest.sh](../../bubbles/scripts/receipt-identity-selftest.sh).
3. Whole-guard functional coverage in
   [state-transition-guard-selftest.sh](../../bubbles/scripts/state-transition-guard-selftest.sh).

### Single-Implementation Justification

BUG-033 is a bounded repair inside the existing Check 43 capability. It adds no
provider, adapter, plugin, service, screen, or reusable parser contract. A
launcher abstraction outside the current jq normalizer would duplicate one
identity rule and create a drift surface without serving a second consumer.

## Architecture Overview

Check 43 keeps one linear pipeline:

1. Read receipts from the tool-call log as data.
2. Exclude empty stdout and incomplete receipt rows under the existing rules.
3. Group remaining rows by substantive `stdoutHash`.
4. Tokenize each recorded `cmd` without invoking a shell.
5. Recursively strip only recognized transparent wrappers and launchers.
6. Derive family, program identity, command identity, target, provenance,
   category, and exit result.
7. Compare each collision group across those independent dimensions.
8. Build one structured verdict object, then render it as ordered terminal
   fields and preserve the existing pass-or-block effect.

The classifier owns meaning. The renderer owns presentation. Rendering must not
recompute compatibility or infer a different reason from prose.

## API And Invocation Contract

BUG-033 adds no HTTP endpoint or network API. The existing CLI invocation is the
external contract.

| Contract item | Value |
| --- | --- |
| Command | `bash bubbles/scripts/state-transition-guard.sh FEATURE_DIR` |
| Receipt input | `.specify/runtime/tool-calls.jsonl` resolved by the guard |
| Classifier input | All receipt rows read by jq as inert JSON data |
| Accepted Check 43 effect | Continue to later guard checks |
| Refused Check 43 effect | Record a guard failure and return nonzero after guard evaluation |
| Diagnostic encoding | Ordered ASCII fields defined below |
| HTTP request/response schema | Not applicable; no endpoint is introduced |

The whole-guard test fixture must satisfy unrelated checks before its process
exit can prove Check 43 behavior. Focused jq assertions isolate classifier
meaning from the rest of the guard.

### Authorization And Invocation Matrix

Check 43 adds no role store or authorization decision. It inherits filesystem
and process permissions from the guard invocation.

| Surface | Transition requester | Evidence reviewer | Consumer workflow | Public network caller |
| --- | --- | --- | --- | --- |
| Invoke guard | Allowed by existing process access | Not required for review | Allowed by existing workflow access | No network surface |
| Read verdict | Yes | Yes | Yes | No network surface |
| Override refusal | No | No | No | No network surface |
| Mutate certification | No new authority | No new authority | No new authority | No network surface |

### Terminal Component Specification

The terminal output is a small rendering tree, not a second classifier.

```text
Check43CollisionPanel
  VerdictHeader(check, verdict)
  ReasonField(reason)
  IdentityFields(identity records)
  CompatibilityFields(target, provenance, category, exit)
  EffectField(effect)
```

`Check43CollisionPanel` receives one immutable classifier result. It owns no
persistent state. Guard evaluation creates the result, renders it once, then
continues or records a failure. Width affects wrapping only. It cannot change
field order, reason selection, or effect.

## Data Model

No persisted data model or receipt schema changes. The existing receipt fields
remain the source inputs.

| Value | Source | Design use |
| --- | --- | --- |
| `cmd` | Receipt | Preserved as `recordedCommand`; tokenized for identity |
| `stdoutHash`, `stdoutBytes` | Receipt | Identify substantive collision groups and empty-output exemption |
| `exitCode` | Receipt | Compared independently after command normalization |
| `tags` | Receipt | Feed the existing category derivation |
| `inputClosure`, `spec`, `scope` | Receipt | Feed the existing target derivation |
| `sessionId`, `ts`, `durationMs` | Receipt | Feed the existing provenance derivation |
| `normalizedTokens` | Derived | Tokens remaining after exact recursive stripping |
| `wrappersStripped` | Derived | Ordered wrapper kinds removed during recursion |
| `launcher` | Derived | `direct`, `timeout`, `gtimeout`, `portable-perl-alarm`, or `unsupported` |
| `identitySource` | Derived | `underlying-command`, `normalized-underlying-command`, or `recorded-command` |
| `normalization` | Derived | `normalized` or `unchanged` |
| `incompatibilities` | Derived | Stable set of failed classification dimensions |

Each receipt retains its raw command alongside derived fields. Unsupported
syntax therefore cannot disappear merely because an outer `env`, assignment,
or shell wrapper was recognized first.

## Command Normalization Contract

### Tokenization

Use the existing literal-space tokenization and removal of empty tokens. Quotes
remain data. The normalizer does not perform shell expansion, quote evaluation,
path lookup, or command execution.

### Recognized Grammar

| Kind | Exact accepted token shape | Tokens removed | Rejection rule |
| --- | --- | --- | --- |
| Shell | `bash`, `sh`, `zsh`, `ksh`, or `dash`, optional `-c`, then `REST...` | Shell and optional `-c` | Preserve existing facet-2 behavior |
| Environment | `env <rest...>` | `env` | Preserve existing facet-2 behavior |
| Assignment | `[A-Za-z_][A-Za-z0-9_]*=... <rest...>` | One assignment per recursion | Preserve existing facet-2 behavior |
| Timeout | `timeout` or `gtimeout`, `DURATION`, then `UNDERLYING...` | Launcher and duration | Duration must be nonempty, must not begin with `-`, and underlying tokens must be nonempty |
| Portable alarm | `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' <seconds> <underlying...>` | Exact Perl prefix and seconds | Every fixed token, the seconds operand, and a nonempty underlying command are required |

Under current tokenization, the portable alarm program is recognized only as
this exact prefix vector:

```text
/usr/bin/perl
-e
'alarm
shift
@ARGV;
exec
@ARGV'
<seconds>
<underlying-0> ...
```

The seconds operand is one nonempty, non-option token. The normalizer does not
add a numeric range policy that the specification does not define. `perl`, a
different Perl path, different quoting, a different `-e` body, missing seconds,
or missing underlying tokens does not match.

Timeout options are deliberately unsupported. Examples such as
`timeout --preserve-status 120 ...`, `timeout -k 5 120 ...`, and
`gtimeout --signal=TERM 120 ...` remain unstripped. The duration operand is
lexical only, so valid non-option timeout forms such as `120` or `5s` may pass
without turning this repair into a timeout parser.

### Recursive Composition

All recognized cases live in one `strip_wrappers` recursion. Each successful
case removes a strict nonempty prefix and recurses into the suffix. The first
unsupported head returns the current token vector unchanged.

This admits composed orders such as:

- `timeout 120 env PAGE=alpha zsh -c node ...`
- `env PAGE=alpha gtimeout 120 bash -c node ...`
- `zsh -c /usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 120 env PAGE=alpha node ...`
- `PAGE=alpha timeout 120 sh -c node ...`

It does not skip through an unsupported launcher to discover a later command.
For example, stripping an outer assignment may expose
`timeout --preserve-status ...`, but the timeout prefix and its full underlying
text remain identity-bearing.

### Normalization Metadata

- A direct command uses `identitySource=underlying-command`.
- Any exact supported wrapper or launcher removal uses
  `identitySource=normalized-underlying-command`.
- A launcher-like prefix that fails its grammar uses
  `identitySource=recorded-command` and `normalization=unchanged`.
- `wrappersStripped` records recognized kinds in encounter order. The bounded
  launcher list is deduplicated for accepted diagnostics in the stable order
  `direct,timeout,gtimeout,portable-perl-alarm`.

## Identity And Collision Contract

Facet 1 remains unchanged: target distinctness is measured once per derived
`cmd_identity`, while provenance distinctness is measured once per receipt.
Facet 2 remains unchanged: family and positional target derive from the fully
normalized token suffix.

Facet 3 changes only the token suffix presented to those existing derivations.
It must not alter receipt `exitCode`, category, target, provenance, or stdout
fields.

A substantive hash group is accepted as deterministic siblings only when all
of these conditions hold:

1. Every normalized command family is nonempty and compatible.
2. Every normalized program identity is nonempty and compatible.
3. Every category is recognized and not mixed.
4. Every exit result is numeric and all exit results are equal.
5. One target per command identity is nonempty and distinct.
6. One provenance value per receipt is nonempty and distinct.

Different underlying programs remain different after launcher removal. A
launcher match can therefore expose a clone candidate. It can never collapse
`artifact-lint.sh` and `state-transition-guard.sh` into `timeout` or `perl`.

Exit compatibility is evaluated from the original receipts after identity
normalization. Equal underlying commands with exit results `0` and `1` fail
independently with `exit-result-mismatch`.

## Terminal Diagnostic Contract

The jq program returns structured sibling and clone details. A Check 43-specific
renderer emits those details. It must not parse the legacy clone prose.

### Verdict Scope

- Empty stdout remains exempt and emits no collision panel.
- A group with one normalized command identity does not become a clone
  candidate solely because direct and wrapped spellings share stdout.
- A multi-identity group accepted by every sibling predicate emits one accepted
  panel.
- An incompatible or unproven multi-identity group emits one refused panel and
  blocks the transition.
- A classifier failure emits a refused panel with
  `reason=classification-error`. It cannot become a no-clone pass.

### Stable Reason Selection

The classifier records every failed dimension. The renderer chooses one primary
`reason` by this fixed precedence, matching the UX vocabulary:

1. `command-identity-mismatch`
2. `target-conflict`
3. `provenance-conflict`
4. `category-invalid`
5. `exit-result-mismatch`
6. `classification-error`

Exit comparison remains independent even when another reason has higher display
precedence. A group whose only failed dimension is exit compatibility must emit
`reason=exit-result-mismatch` and both exit values.

### Ordered Fields

Every emitted panel has one fixed first line and one fixed last line. The
semantic fields are:

```text
check=43 verdict=ACCEPTED|REFUSED
reason=<stable-reason>
...
effect=COLLISION_ACCEPTED|TRANSITION_BLOCKED
```

An accepted deterministic-sibling panel emits, in order:

```text
identity=<common-normalized-program-identity>
identity_source=<underlying-command|normalized-underlying-command>
launchers=<stable-comma-separated-set>
targets=distinct-per-command-identity
provenance=distinct-per-receipt
exit_results=compatible
```

A refused command mismatch emits
`launcher_a`, `identity_a`, `identity_source_a`, `normalization_a`, then the
corresponding `_b` fields. A target conflict emits `identity_a`, `target_a`,
`identity_b`, and `target_b`. A provenance conflict emits the compared
identities and provenance values. An invalid category emits the identity and
category. An exit mismatch emits `identity_a`, `exit_a`, `identity_b`, and
`exit_b`.

For a group with more than two receipts, the diagnostic pair is the first pair
in receipt-log order that proves the primary incompatibility. This is stable for
the same input log and avoids unordered set rendering.

### Machine Extraction And Accessibility

- Emit semantic fields as ASCII text with no box border and no ANSI escapes.
- Split a field at its first `=`. Values may contain later `=` characters.
- Escape carriage return, line feed, tab, backslash, and escape bytes inside
  recorded values so one command cannot inject a second diagnostic field.
- Never truncate an identity or replace content with an ellipsis. Remove the
  current 800-byte diagnostic cap from this path.
- Keep one logical field per line. Below 60 columns, wrap only at token
  boundaries and prefix continuation lines with two spaces.
- Preserve field order regardless of terminal width. Color may decorate other
  guard output, but no parser or user distinction may depend on it.
- Accepted output contains no clone, forgery, warning, or refusal wording.
- Every refused panel ends with `effect=TRANSITION_BLOCKED` before the guard
  returns nonzero.

## Security And Compliance

- Recorded commands remain inert strings. No `eval`, shell invocation, or
  subprocess is permitted during normalization.
- Exact launcher matching is an allow-list. Unsupported syntax fails closed by
  retaining identity rather than by guessing.
- Diagnostic control-character escaping prevents a recorded command from
  forging `verdict`, `reason`, or `effect` lines.
- The design adds no secret, authentication, payment, network, or deployment
  surface.
- Per-receipt provenance remains mandatory for deterministic siblings.

## Configuration, Migration, Rollout, And Rollback

No configuration key, feature flag, data migration, receipt migration, or new
dependency is required.

Rollout is one source change with focused and whole-guard regression coverage.
Framework release propagation uses the existing Bubbles release and install
path. Product repositories must not receive direct copies or local patches.

Rollback restores only the facet-3 launcher branches and the new Check 43
diagnostic renderer to their pre-change forms. It must retain facet-1 target
grouping and facet-2 shell, `env`, and assignment recursion. A rollback leaves
BUG-033 `in_progress`. It is containment, not certification.

## Observability And Failure Handling

Check 43's terminal contract is the observable surface. No metric, trace, or
remote log sink is added.

| Condition | Classifier action | Terminal action |
| --- | --- | --- |
| Exact supported launcher | Strip prefix, recurse, retain launcher metadata | Show normalized underlying identity when a panel is emitted |
| Unsupported or malformed launcher | Keep launcher-bearing tokens | Show recorded identity with `normalization=unchanged` |
| Different underlying commands | Preserve distinct identities | Refuse with both identities |
| Different exit results | Preserve original exits | Refuse with `exit-result-mismatch` and both exits |
| Missing or repeated provenance | Fail sibling proof | Refuse with `provenance-conflict` |
| Invalid or mixed category | Fail sibling proof | Refuse with `category-invalid` |
| Empty stdout | Apply existing exemption | Emit no collision panel |
| jq or renderer classification failure | Do not synthesize an empty analysis | Refuse with `classification-error` |

## Technical BDD Scenarios

These scenarios bind the analyst scenarios to exact receipt state, guard
invocation, and assertions. Fixture hashes are nonempty except where the
empty-output exemption is the subject.

```gherkin
Scenario: SCN-B033-001 accepts repeated independent executions
  Given the isolated tool-call log has five alpha and four beta artifact-lint receipts
  And all nine rows share one nonempty stdoutHash, exitCode 0, and distinct provenance
  When the fixture runs `bash bubbles/scripts/state-transition-guard.sh FEATURE_DIR`
  Then Check 43 emits `check=43 verdict=ACCEPTED`
  And it emits `reason=deterministic-siblings`
  And no accepted field contains clone or forgery wording

Scenario: SCN-B033-002 refuses two command identities over one target
  Given one alpha receipt runs `npm run lint`
  And one alpha receipt runs `npm run test`
  And both rows share one nonempty stdoutHash and independent provenance
  When the fixture runs the whole guard
  Then the guard returns nonzero
  And Check 43 emits `reason=command-identity-mismatch`
  And it emits both command identities and `effect=TRANSITION_BLOCKED`

Scenario: SCN-B033-003 preserves existing transparent wrapper equivalence
  Given six receipts spell one node command directly and through shell, env, and assignment wrappers
  When the focused selftest derives each command family from the extracted production definitions
  Then every family equals `node`
  And the whole guard reports no clone solely for wrapper spelling

Scenario: SCN-B033-004 exposes different programs behind existing wrappers
  Given one receipt runs `zsh -c cargo test`
  And another runs `env CI=1 npm run lint`
  And both rows share one nonempty stdoutHash
  When the fixture runs the whole guard
  Then the guard returns nonzero
  And Check 43 emits the normalized cargo and npm identities

Scenario: SCN-B033-005 normalizes simple timeout launchers
  Given direct, `timeout 120`, and `gtimeout 120` receipts run the same artifact-lint command
  When the focused selftest derives command identities
  Then all three identities are equal
  And the whole guard reports no clone solely for either timeout launcher

Scenario: SCN-B033-006 normalizes only the exact portable alarm launcher
  Given direct and exact portable Perl alarm receipts run the same artifact-lint command
  When the focused selftest derives command identities
  Then both identities are equal
  And the whole guard reports no clone solely for the portable launcher

Scenario: SCN-B033-007 composes launchers with existing wrappers
  Given launcher, shell, env, and assignment prefixes occur in each supported composed order
  When the focused selftest derives family and command identity
  Then every complete supported composition exposes `node scripts/check-page.mjs`
  And the whole guard reports no clone solely for prefix order

Scenario: SCN-B033-008 retains arbitrary Perl programs
  Given one receipt runs `/usr/bin/perl -e 'print 1' 120 artifact-lint.sh TARGET`
  And another receipt runs `artifact-lint.sh TARGET`
  And both rows share one nonempty stdoutHash
  When the fixture runs the whole guard
  Then the guard returns nonzero
  And Check 43 emits `identity_source_a=recorded-command`
  And it emits `normalization_a=unchanged`

Scenario: SCN-B033-009 retains malformed and option-bearing launchers
  Given each unsupported timeout or near-match Perl spelling from the specification is recorded
  When the focused selftest derives its identity
  Then the launcher prefix remains in that identity
  And a representative whole-guard collision emits `normalization_a=unchanged`

Scenario: SCN-B033-010 exposes different commands behind every supported launcher
  Given artifact-lint and state-transition-guard receipts use the same supported launcher kind
  And both rows share one nonempty stdoutHash
  When the fixture runs the whole guard for each launcher kind
  Then every run returns nonzero
  And every diagnostic emits distinct `identity_a` and `identity_b` values

Scenario: SCN-B033-011 keeps exit compatibility independent
  Given timeout and gtimeout receipts normalize to one program over distinct targets
  And their exitCode values are 0 and 1
  And both rows share one nonempty stdoutHash and independent provenance
  When the fixture runs the whole guard
  Then the guard returns nonzero
  And Check 43 emits `reason=exit-result-mismatch`, `exit_a=0`, and `exit_b=1`
```

## Testing And Validation Strategy

The focused selftest must continue extracting Check 43's jq program from the
guard source. It must exit 2 if extraction fails. The whole-guard selftest must
use an isolated tool-call log and assert the real guard exit plus raw terminal
fields.

### Scenario-To-Test Mapping

| Scenario | Focused `receipt-identity-selftest.sh` assertion | Whole `state-transition-guard-selftest.sh` assertion |
| --- | --- | --- |
| SCN-B033-001 | Nine re-runs over two targets produce one sibling group and zero clones | Guard exits 0 and emits the accepted deterministic-sibling reason without clone wording |
| SCN-B033-002 | `npm run lint` and `npm run test` over one target produce one clone | Guard exits nonzero with `reason=command-identity-mismatch` and both identities |
| SCN-B033-003 | Six direct/shell/env/assignment spellings derive family `node` | Guard exits 0 and reports no clone solely for wrapper spelling |
| SCN-B033-004 | Wrapped cargo and npm commands remain two identities | Guard exits nonzero and emits both unwrapped identities |
| SCN-B033-005 | Direct, `timeout`, and `gtimeout` spellings derive one command identity | Guard does not report a clone solely for either timeout launcher |
| SCN-B033-006 | The exact portable alarm spelling derives the direct command identity | Guard does not report a clone solely for the exact portable launcher |
| SCN-B033-007 | Launcher-outer, launcher-inner, shell, env, and assignment orders all derive family `node` and retain the script target | Guard accepts one representative composition for each bounded launcher kind |
| SCN-B033-008 | `/usr/bin/perl -e 'print 1' ...` retains its recorded Perl identity and differs from direct | Guard refuses and emits `identity_source_a=recorded-command` plus `normalization_a=unchanged` |
| SCN-B033-009 | Missing operands, timeout options, and near-match Perl bodies remain unchanged | Guard refuses representative malformed timeout and Perl cases without hiding their prefixes |
| SCN-B033-010 | Each supported launcher exposes distinct artifact-lint and state-transition-guard identities | Guard exits nonzero for every launcher kind and emits `identity_a` plus `identity_b` |
| SCN-B033-011 | Equal normalized commands with exits 0 and 1 fail sibling compatibility | Guard exits nonzero with `reason=exit-result-mismatch`, `exit_a=0`, and `exit_b=1` |

### Diagnostic Contract Assertions

The whole-guard suite must assert field order, refusal effect, and complete
untruncated identities. It must also assert control-character escaping,
continuation indentation below 60 columns, and equivalence after ANSI stripping.
The raw semantic block must contain no ANSI bytes.

The implementation validation chain is:

1. Focused receipt-identity selftest.
2. Whole state-transition-guard selftest.
3. Canonical `bash bubbles/scripts/cli.sh framework-validate` closure.

This design records required proof. It does not claim that facet 3 or its tests
have been implemented or executed.

## Alternatives Considered

1. **Drop target distinctness entirely.** Rejected: one target vouching for two
   identities is precisely the forgery shape the rule exists for.
2. **Special-case `artifact-lint.sh`.** Rejected: the defect is structural, and
   an allow-list would leave every other deterministic validator broken.
3. **Normalize by re-parsing with a shell.** Rejected: executing recorded
   command strings to determine their identity is a code-execution surface
   inside a guard.
4. **Strip any leading token containing `/` or `=`.** Rejected: over-broad. It
   would strip `./run.sh` and make the family the first argument.
5. **Recognize every timeout option permutation.** Rejected: it would require a
  launcher-specific parser and would violate the exact grammar boundary.
6. **Match any Perl alarm expression.** Rejected: near-matches can change
  control flow before `exec` and are not transparent launchers.
7. **Keep the legacy prose diagnostic and append more prose.** Rejected: it
  leaves reason selection unstable, keeps truncation, and cannot satisfy the
  plain-text field contract.

## Change Boundary

The implementation design permits behavior changes only in the Check 43 block
of [state-transition-guard.sh](../../bubbles/scripts/state-transition-guard.sh),
corresponding assertions in the two named selftests, and the single migrated
assertion in
[evidence-admission-hardening-selftest.sh](../../bubbles/scripts/evidence-admission-hardening-selftest.sh)
described below. It excludes receipt schema changes, category remapping,
provenance weakening, empty-stdout changes, other guard checks, framework status
changes, downstream installed copies, and unrelated test rewrites.

### Ratified Widening: `evidence-admission-hardening-selftest.sh`

`bubbles/scripts/evidence-admission-hardening-selftest.sh` is inside this
boundary. It is a first-party downstream consumer of the Check 43 refusal
vocabulary that this packet retires: it asserted the free-text
`Evidence receipt CLONE` line, which this packet replaced with the structured
`check=43 verdict=REFUSED` / `reason=<closed set>` fields. The file is migrated
under this packet because the contract change originates here, and because this
packet's own Definition of Done already requires that the consumer impact sweep
leave no stale first-party diagnostic consumer after a field change. Leaving
that consumer unmigrated would make this packet's own DoD unsatisfiable and
would land the retired contract knowingly red.

The widening is bounded to the one assertion that named the retired string. It
authorizes no other change to that file, and no other selftest joins the
boundary by analogy.

The historical facet-1 and facet-2 report remains historical evidence. This
design does not rewrite reports, scopes, scenario manifests, user acceptance,
source, or tests.

## Complexity Tracking

None — simplest viable approach used. The design adds exact decreasing branches
to one existing recursive normalizer and one structured renderer at the owning
classification surface.

## Remaining Risks And Questions

None found. [spec.md](spec.md) defines the launcher grammar, unsupported forms,
diagnostic vocabulary, accessibility behavior, and all eleven scenario bounds.
