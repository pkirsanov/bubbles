# BUG-038 Design - Train Metadata Assignment Mode

## Design Brief

### Current State

`bubbles.train` exclusively owns `state.json.releaseTrain` and
`state.json.flagsIntroduced`. The assignment mode now exists. Its helper rejects
the valid wildcard grants held by top-level workflow runners because it treats
the complete effective runner set as the mutation-authority boundary. The helper
also treats `BUBBLES_AGENT_NAME` as sufficient apply authority even though that
environment value is not authenticated runner identity.

### Target State

Keep `release-train-assign-metadata`, resolved from
`ship action:assign target:train-metadata`. Keep its exact mode grant on
`bubbles.train`. Preserve exact, wildcard, default-deny, and exclusion-aware mode
admission. Apply succeeds only during a direct invocation whose authenticated
active top-level runner is exactly `bubbles.train`. A wildcard-admitted runner is
admitted to the mode but cannot mutate because the current runtime cannot
dispatch the pure top-level `bubbles.train` runner. The helper updates only the
two train-owned fields and has no release lifecycle effect.

### Patterns to Follow

- Use `bubbles/workflows/modes.yaml`, `bubbles/workflows/aliases.yaml`, and
	`bubbles/agent-capabilities.yaml` as the mode, alias, and runner-grant
	authorities.
- Use `bubbles/agent-ownership.yaml` as the mutation-owner authority.
- Reuse the wildcard-aware `runner_allows_mode()` policy from
	`bubbles/scripts/workflow-runner-grants-lint.sh` with only the extraction
	needed by the assignment boundary and its focused tests.
- Validate `.trains[].id` from `config/release-trains.yaml`, matching
	`bubbles/scripts/release-train-guard.sh`.
- Follow the dry-run and explicit `--apply` shape used by existing state
	reconciliation helpers.
- Treat `BUBBLES_AGENT_NAME` as non-authoritative diagnostic context. Never use
	it to authenticate the runner or prove mutation ownership.
- Follow Bash 3.2 and GNU/BSD portability rules.

### Patterns to Avoid

- Do not reuse a lifecycle mode or the read-only status mode.
- Do not accept a caller-controlled `--agent` option.
- Do not create the replacement file on another filesystem.
- Do not create a persistent root `specs/` packet in this source repository.

### Resolved Decisions

- Helper: `bubbles/scripts/release-train-metadata-assign.sh`.
- Dry-run is the default; mutation requires `--apply`.
- Runner admission and mutation ownership are independent checks.
- Exact mode grants and wildcard grants both participate in runner admission.
- Exclusions override exact and wildcard grants.
- Apply requires the authenticated active top-level runner to be exactly
	`bubbles.train`.
- A wildcard-admitted non-train runner cannot mutate. The current runtime cannot
	dispatch `bubbles.train` from that pure top-level runner.
- `BUBBLES_AGENT_NAME` cannot satisfy, override, or repair runner authentication.
- Omitted flags preserve `flagsIntroduced`; explicit `[]` clears it.
- Unknown trains refuse before candidate creation or destination writes.
- Identical assignment is a successful no-op without file replacement.
- A candidate is created beside `state.json` and renamed atomically.
- The root-level packet remains under `bugs/` to preserve Gate G085.

### Open Questions

None.

## Root-Cause Analysis

### Investigation Summary

The investigation compared four authorities. The ownership registry gives `bubbles.train` exclusive write authority over `releaseTrain` and `flagsIntroduced`. The agent contract repeats that ownership.

The mode registry originally defined cut, promote, rollback, retire, and all-train status. The train grant listed those modes explicitly. Top-level workflow runners also received wildcard grants under the default-deny registry.

The current alias registry resolves `ship action:assign target:train-metadata`
to `release-train-assign-metadata`. The remaining defect is confined to the
authorization model used by the helper and its selftests.

### Root Cause

The original defect omitted a mutation capability for train-owned metadata. The implemented repair added the capability, but its authorization check conflated effective runner admission with mutation authority and then relied on an unauthenticated environment declaration for apply. This design treats `SF-01` and `ES-02` as operator-reported review findings. No repository-local source record for those identifiers was located, so they are not cited as execution evidence.

The missing capability cannot safely reuse a lifecycle mode. Cut starts candidate production. Promote changes a deployment pointer. Retire changes train phase. Status is read-only. None expresses a bounded spec metadata write.

### Impact Analysis

- **Affected components:** workflow modes, aliases, runner grants, train agent contract, and train documentation.
- **Affected data:** `releaseTrain` and `flagsIntroduced` in downstream spec state.
- **Affected users:** release owners and downstream repositories that need classification or backfill.
- **Safety impact:** valid wildcard orchestration is rejected, while a weakened fix could let a runner impersonate the field owner.

## Fix Design

### Solution Approach

Retain the mode named `release-train-assign-metadata`. Keep its explicit exact-mode grant on `bubbles.train`. Do not remove intentional wildcard grants from top-level runners.

The operation accepts a spec state path, one declared train ID, and an optional explicit flag list. It validates all inputs before writing. It changes only the two train-owned fields.

Use `bubbles/scripts/release-train-metadata-assign.sh` for deterministic field
isolation. The helper operates on one existing spec state path and validates the
requested train against the target repository registry.

Reuse the existing runner-admission evaluator for exact, wildcard, default-deny,
and exclusion precedence. Do not introduce a generic actor framework. The apply
boundary independently requires the authenticated active top-level runner to be
exactly `bubbles.train`, requires `bubbles.train` to remain the sole
`release-train-state` owner, and requires the assignment mode to own every
requested field.

Write updated state through a same-directory temporary file and atomic rename.
Preserve every unrelated JSON value. Refused and idempotent operations preserve
the target bytes. A successful changed write may normalize JSON formatting but
must not change the semantic value of any unrelated field.

The helper must not read or write generated config bundles. It must not alter release-train config, feature-flag bundles, manifests, tags, or train phases.

### Proposed Registry Contract

- **Mode key:** `release-train-assign-metadata`
- **Primitive:** `ship`
- **Tags:** `action: assign`, `target: train-metadata`
- **Exact mode grantee:** `bubbles.train`
- **Effective runners:** registered top-level runners with an exact or wildcard
	grant that is not excluded
- **Apply runner:** authenticated active top-level runner exactly `bubbles.train`
- **State owner:** sole `release-train-state` owner exactly `bubbles.train`
- **Mutation class:** metadata-only
- **Status ceiling and terminal alias:** `train_metadata_assigned`
- **Required validation:** declared train exists
- **Forbidden semantics:** cut, promote, rollback, retire, build, deploy, pointer-swap
- **Lifecycle effect:** none

### Proposed Implementation Surfaces

- `bubbles/workflows/modes.yaml`
- `bubbles/workflows/aliases.yaml`
- `bubbles/agent-capabilities.yaml`
- `bubbles/agent-ownership.yaml` as a read-only ownership authority
- `agents/bubbles.train.agent.md`
- `docs/recipes/release-train-lifecycle.md`
- `docs/guides/WORKFLOW_MODES.md`
- A narrowly scoped production metadata assignment helper
- The smallest reusable runner-admission evaluator extracted from the existing
	grant lint, without a generic mutation-actor abstraction
- A focused adversarial helper selftest
- Existing alias and runner-grant selftests
- `bubbles/release-manifest.json` after validation

### Exact Helper Interface

The command contract is:

`release-train-metadata-assign.sh <spec-dir|state.json> --train <train-id> [--flags-json <json-array>] [--dry-run|--apply]`

- A directory target resolves to its `state.json`; a file target must be named
	`state.json`. The target and train registry must already exist.
- `--train` is required exactly once and accepts one non-empty registry ID.
- `--flags-json` is optional and accepts a JSON array of unique, non-empty
	strings. Omission preserves the existing field. Explicit `[]` clears it.
- Dry-run is the default. `--dry-run` is an explicit synonym. `--apply` is the
	only mutating form, and the two mode options are mutually exclusive.
- The workflow runtime supplies the authenticated active top-level runner to the
	apply boundary through its existing top-level invocation context. The helper
	must not infer that identity from `BUBBLES_AGENT_NAME` or accept a caller-
	controlled identity option.
- Unknown options, duplicate singleton options, missing values, malformed JSON,
	and extra positional arguments refuse.
- No `--agent`, `--force`, `--skip`, train-creation, or lifecycle option exists.

### Authorization Boundary

The workflow runtime must resolve the exact tuple before invoking the helper and
must provide its authenticated active top-level runner context to the apply
boundary. There is no separate mutable actor identity.

Runner admission answers one question: may this top-level runner execute this
mode? Apply authority answers another question: is this a direct
`bubbles.train` invocation allowed to mutate train-owned fields? Both checks must
pass before apply.

An explicit `release-train-assign-metadata` grant on `bubbles.train` remains the
only exact grant for the mode. Intentional wildcard grants remain valid for
top-level orchestration. The effective runner set may therefore contain more
than `bubbles.train`.

Dry-run may evaluate and report admission or ownership findings because it does
not mutate. Apply must refuse unless the authenticated active top-level runner
is exactly `bubbles.train`. Setting `BUBBLES_AGENT_NAME=bubbles.train` cannot
turn a wildcard, wrong, or missing runner into an authorized apply.

The current runtime marks `bubbles.train` as a pure top-level runner and forbids
nested workflow-runner dispatch. Therefore a wildcard-admitted runner can reach
the admission decision but cannot reach mutation by dispatching
`bubbles.train`. Direct `bubbles.train` execution is the only success path.

### Minimal Authorization Evaluator Reuse

Extract only the existing `runner_allows_mode()` decision from
`bubbles/scripts/workflow-runner-grants-lint.sh` into a sourceable helper, or
expose the same function from that script without changing its semantics. The
assignment helper and the focused admission tests must call that one function.
Do not create a generic workflow-mutation authorization library.

The admission evaluator receives the capabilities authority, active runner, and
resolved mode. It decides in this order:

1. Require a registered runner grant.
2. Require an exact grant or `"*"`.
3. Apply `excludedModes` last so an explicit exclusion overrides either grant.
4. Otherwise refuse under the existing default-deny policy.

After admission, the assignment helper performs three direct-only checks:

1. Require authenticated active top-level runner identity and require it to be
	exactly `bubbles.train` for apply.
2. Require `bubbles.train` to be the one and only owner of
	`release-train-state` in `bubbles/agent-ownership.yaml`.
3. Require every requested field to appear in the mode's `ownedStateFields`.

The requested field set is `releaseTrain` when flags are omitted and
`releaseTrain` plus `flagsIntroduced` when flags are supplied. Missing or wrong
runner context, malformed authorities, missing or duplicate ownership, and
owned-field mismatches fail closed before candidate creation. Admission never
grants ownership, ownership never grants admission, and neither can be inferred
from `BUBBLES_AGENT_NAME`.

### Validation and Atomic Write

Before creating a candidate or writing the destination, the helper must:

1. Validate arguments and resolve one existing state file.
2. Parse the state as a JSON object.
3. Parse `config/release-trains.yaml` at the target repository root.
4. Require a unique, non-empty set of `.trains[].id` values.
5. Match the requested train exactly.
6. Validate the optional flags array when present.
7. Read the authenticated active top-level runner from the runtime invocation
	context without consulting `BUBBLES_AGENT_NAME` as authority.
8. Evaluate effective runner admission with the shared evaluator.
9. For apply, require the runner to be exactly `bubbles.train`.
10. Independently validate sole artifact ownership and requested-field
	containment.

An unknown train refusal names the requested ID, exits nonzero, and preserves
the original state bytes.

Build the candidate with `jq`. Set `.releaseTrain`, and set
`.flagsIntroduced` only when its option was supplied. Compare source and
candidate after deleting only those two owned paths. The projections must be
semantically equal. Verify the candidate's owned values separately. This
preserves `status`, `execution`, `certification`, `policySnapshot`, work
boundaries, histories, unknown future fields, and every other value.

For apply, create the candidate with a portable `mktemp` template in the target
directory. Install cleanup traps before creation. Fully write and validate the
candidate, preserve the target mode through a portable repository helper where
available, then rename it over `state.json` on the same filesystem. Any failure
before rename removes the candidate and preserves the destination.

If the requested owned values already match, return success without replacing
the file. Dry-run emits the complete candidate JSON to standard output and does
not create a candidate beside the target.

### Closed Side-Effect Boundary

The mode and helper must not create or edit train configuration, feature-flag
bundles, generated config bundles, artifacts, build manifests, deployment
manifests, or pointers. They must not build, cut, tag, sign, publish, retrieve,
deploy, promote, roll back, or retire. They must not change train phase, target
slot, spec or scope status, execution metadata, or certification data.

A successful result says metadata was assigned. It must not claim any lifecycle
operation completed.

### Data Model and Migration

No state schema migration is required. The helper writes the existing top-level
`releaseTrain` string and optional `flagsIntroduced` string array. It neither
adds a state field nor rewrites absent unrelated fields.

The workflow registries change additively. Existing mode keys, aliases, grants,
train records, state files, and lifecycle behavior remain valid. No backfill is
automatic. Existing specs change only when the authorized assignment action
targets them explicitly.

### API and UI Contracts

There is no HTTP, protobuf, UI, or database surface. The shell command is the
complete machine-facing contract. Operator documentation must show the v7 tuple
and distinguish dry-run from apply without teaching direct state editing.

### Security and Failure Handling

Treat identities, paths, train IDs, and flag strings as data. Quote every expansion and
never evaluate JSON as shell input. Refusal output may name the invalid train or
option but must not print state contents. Invalid JSON, invalid YAML, duplicate
train IDs, unknown trains, unauthorized apply, projection mismatch, and rename
failure all return nonzero without a partial destination write.

`BUBBLES_AGENT_NAME` is diagnostic policy context, not caller authentication.
Repository binding remains mandatory. A wildcard-admitted runner must be
reported as admitted and refused for apply because it is not the authenticated
top-level `bubbles.train` runner.

The helper must not recover by creating a train, selecting another train,
dropping invalid flags, or preserving only a known allowlist of state fields.

### Observability

The command reports one deterministic result category: dry-run candidate,
applied assignment, idempotent no-op, or refusal. Messages identify the target
path and train ID but not the state payload. It emits no release lifecycle
event, deployment audit record, build receipt, certification evidence, or
telemetry claiming an operational release transition.

### Cross-Platform Shell Contract

The helper and selftest must run on GNU/Linux and macOS/BSD under Bash 3.2 or
newer. Use `#!/usr/bin/env bash`, `set -euo pipefail`, quoted expansions,
portable same-directory `mktemp` templates, and `LC_ALL=C` where ordering
matters. Avoid associative arrays, `mapfile`, GNU-only `sed -i`, `readlink -f`,
`realpath`, platform-specific `stat` and `date` flags, and assumptions that
`timeout` exists. Prefer shared guard-library portability helpers. Do not
require optional Python modules.

### Source-Repository Artifact Policy

Keep this packet at `bugs/BUG-038-train-metadata-assignment-mode-gap`. Gate G085
forbids a persistent root `specs/` directory in the canonical framework source
repository. Hermetic temporary downstream fixtures may contain `specs/`, but
the source checkout must not. Source evidence comes from focused selftests,
framework validation, release readiness, and the generated release manifest.

### Test Design

Create one hermetic repository fixture with two declared trains, a spec state
containing unrelated execution and certification fields, and sentinels for
configuration, flag bundles, generated output, and manifests. The focused
helper selftest owns the mutation, refusal, field-isolation, and side-effect
assertions. The existing runner-grant and alias selftests own admission and
compatibility assertions. All focused tests reuse the production admission
evaluator instead of reproducing its policy.

| Scenario | Required behavior |
| --- | --- |
| `SCN-B038-001` | A direct authenticated `bubbles.train` apply for an existing train persists the requested canonical fields and preserves every non-owned value. |
| `SCN-B038-002` | A wildcard non-train runner is admitted to the mode, then refused for apply with byte-identical state. |
| `SCN-B038-003` | An explicit assignment-mode exclusion overrides a wildcard grant and preserves state. |
| `SCN-B038-004` | A wrong authenticated runner is refused even when `BUBBLES_AGENT_NAME` says `bubbles.train`. |
| `SCN-B038-005` | Missing authenticated runner context fails closed before mutation. |
| `SCN-B038-006` | Missing, duplicate, or mismatched sole ownership of `release-train-state` refuses without mutation. |
| `SCN-B038-007` | Any requested canonical field absent from `ownedStateFields` refuses without mutation. |
| `SCN-B038-008` | Default and explicit dry-run report the candidate and admission or ownership findings without changing the destination or leaving a sibling candidate. |
| `SCN-B038-009` | The assignment tuple resolves and all existing train lifecycle and status aliases retain their current targets. |
| `SCN-B038-010` | An unknown train produces a named refusal, byte-identical state, and no candidate residue. |
| `SCN-B038-011` | Omitted flags preserve, explicit empty flags clear, valid flags replace, and malformed or duplicate flags refuse. |
| `SCN-B038-012` | Sentinel digests and forbidden-command instrumentation prove no lifecycle, build, bundle, manifest, pointer, or deployment side effect or claim. |
| `SCN-B038-013` | Repeating an identical authorized apply preserves bytes, file mode, and modification time. |

The direct `bubbles.train` case is the positive mutation control. There is no
positive wildcard-mutation case. The wildcard case proves admission and refusal
as separate assertions, matching the current runtime's inability to dispatch
the pure top-level train runner. Focused authorization fixtures must also prove
default deny independently so universal admission or universal refusal cannot
satisfy the matrix.

### Alternative Approaches Considered

1. **Reuse release-train-cut.** Rejected because assignment must not create a candidate or build artifacts.
2. **Reuse release-train-status-all.** Rejected because that mode is explicitly read-only.
3. **Let bubbles.releases write state.** Rejected because the ownership registry reserves these fields for `bubbles.train`.
4. **Use a generic state mutation mode.** Rejected because it would widen write authority beyond two owned fields.
5. **Teach operators to edit state manually.** Rejected because manual mutation bypasses owner and workflow authorization.
6. **Make the backfill planner mutate.** Rejected because recommendation and authorized assignment are distinct responsibilities.
7. **Use a generic temporary directory.** Rejected because rename may cross
	filesystems and lose atomicity.
8. **Always replace flags.** Rejected because omission must preserve existing
	metadata while explicit `[]` must support intentional clearing.
9. **Accept `--agent`.** Rejected because caller-controlled identity is not
	authorization.
10. **Require the complete effective runner set to equal only `bubbles.train`.**
	Rejected because intentional wildcard runners are valid orchestrators. Their
	runner grant does not transfer mutation ownership.
11. **Allow a wildcard runner to nominate `bubbles.train` as a separate actor.**
	Rejected because `bubbles.train` is a pure top-level runner and the current
	runtime forbids nested workflow-runner dispatch.
12. **Authenticate apply with `BUBBLES_AGENT_NAME`.** Rejected because a caller
	can set that environment value. It is not authenticated active-runner proof.

## Concrete Implementation

The capability has one mutating implementation: the dedicated shell helper.
The existing runner-admission evaluator is reused by production and focused
tests with the smallest practical extraction. Direct-runner, ownership, and
owned-field checks remain explicit because this bug does not justify a generic
mutation-actor framework.

### Single-Implementation Justification

The operation has one state format, one train registry, one owning actor, and
one mutation policy. The shared evaluator removes duplicated policy logic. A
provider or plugin abstraction would add no useful variation point.

## Risks and Mitigations

| Risk | Mitigation |
| --- | --- |
| `BUBBLES_AGENT_NAME` is mistaken for authentication | Exclude it from authorization decisions and test contradictory values. |
| Wildcard admission is mistaken for mutation authority | Prove admission first, then require direct authenticated `bubbles.train` for apply. |
| A design silently assumes nested train dispatch | Keep wildcard mutation as a refusal until the runtime contract changes through separate planning. |
| Tests drift from production authorization | Require both to call one shared evaluator. |
| An exclusion is ignored after wildcard matching | Apply exclusions after exact-or-wildcard grant matching. |
| A future field is dropped | Compare non-owned source and candidate projections. |
| Unknown train causes a partial write | Validate the registry before candidate creation. |
| A crash corrupts state | Use traps, complete candidate validation, and same-filesystem rename. |
| Omitted flags erase metadata | Track option presence separately from its value. |
| Assignment implies release completion | Use a metadata-specific mode and terminal token and prohibit lifecycle calls. |
| macOS behavior diverges | Require Bash 3.2 and GNU/BSD-safe constructs. |
| Framework dogfood creates a persistent spec tree | Keep the packet under `bugs/` and retain G085 coverage. |

## Open Questions

None.

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Dedicated metadata-only mode | Add assignment to cut or status | Both existing modes carry incompatible semantics. |
| Dedicated atomic helper | Rely on prose-directed editor changes | A helper supports deterministic field-isolation and adversarial tests. |
| Non-owned projection comparison | Trust the two `jq` assignments | The invariant protects current and future unrelated state fields. |
| Minimal admission-evaluator extraction | Add a generic mutation-actor library | The existing admission policy needs reuse, but direct-only ownership has no second actor or provider variation. |
