# Spec: BUG-042 Same-Revision Receipt Supersession

## Problem Statement

The receipt log is append-only. An operator must be able to append a corrected
same-revision proof chain without deleting historical evidence. The current
resolver can derive the corrected state and still reject certification because
it retains blockers emitted from older rows.

## Outcome Contract

### Outcome

For each scenario and source revision, the resolver selects one authoritative
latest coherent proof chain. It preserves every historical row and reports why
non-authoritative rows did not control the result.

### Success Signal

A fixture with an older substituted or exit-zero receipt and a later coherent
replacement resolves without the historical refusal blocking certification.
The output still accounts for the superseded row.

### Hard Constraints

- Receipt history remains append-only.
- A newer invalid receipt never erases an earlier valid chain silently.
- A true unresolved conflict remains blocking.
- Source revision drift keeps the semantics fixed by `BUG-034`.
- Certification remains owned by validation, not this resolver.
- No bypass or ignore flag is introduced.

## Expected Behavior

### EB-1 Preserve history

The resolver reads every valid JSONL row. It never requires deletion or
rewriting of an earlier receipt to accept a corrected proof chain.

### EB-2 Use deterministic receipt identity and order

The resolver assigns each parsed row its append ordinal. The append ordinal is
the ordering authority. A timestamp is descriptive metadata and cannot select
between same-time rows.

### EB-3 Select one latest coherent chain

A coherent chain has a failing RED receipt, a later IMPLEMENT receipt, and a
later exit-zero GREEN receipt. RED and GREEN share `scenarioId`,
`sourceRevision`, `testIdentity`, and `negativeControl`.

The authoritative chain is the coherent chain whose terminal GREEN has the
greatest append ordinal. A later coherent chain supersedes earlier conflicting
or incomplete candidates at the same revision.

### EB-4 Historical invalid rows become superseded diagnostics

An invalid row before the authoritative terminal GREEN does not remain a
blocking refusal when the selected chain proves the expected discriminator.
The output identifies the row as superseded and retains its refusal reason for
audit.

### EB-5 Unresolved later conflicts still block

An incompatible or invalid row appended after the authoritative terminal GREEN
remains unresolved unless a still-later coherent chain resolves it. The
resolver reports the selected valid chain and the unresolved conflict. It does
not clear derived states or silently choose the invalid row.

### EB-6 Tie behavior is deterministic

Two receipts with the same timestamp are ordered by append ordinal. If an input
source cannot provide a unique append order, the resolver refuses the ambiguity
instead of choosing by iteration accident.

### EB-7 BUG-034 stays narrow

`SCS-REVISION-DRIFT` remains reported but nonblocking after exclusion from
derivation. `SCS-TEST-SUBSTITUTED`, `SCS-CONTROL-SUBSTITUTED`, and
`SCS-RED-NOT-FAILING` remain blocking when they describe the unresolved latest
candidate. This change must not exempt those codes globally.

## Functional Requirements

- **FR-1:** Preserve all receipt rows and expose their selected, superseded, or unresolved disposition.
- **FR-2:** Use append ordinal as the deterministic order within one JSONL log.
- **FR-3:** Group proof candidates by scenario and source revision.
- **FR-4:** Require matching test identity and negative control across RED and GREEN.
- **FR-5:** Select the coherent chain with the latest terminal GREEN.
- **FR-6:** Do not count superseded historical conflicts as blocking refusals.
- **FR-7:** Keep later unresolved conflicts blocking while retaining the prior valid chain in output.
- **FR-8:** Keep revision-drift behavior byte-for-byte compatible with the `BUG-034` contract.
- **FR-9:** Refuse ambiguous order instead of using timestamp or container iteration order.
- **FR-10:** Add no skip, force, ignore, assume, or allow bypass.

## Acceptance Criteria

| ID | Criterion | Verification |
|---|---|---|
| AC-1 | An older substituted-test GREEN is superseded by a later matching GREEN. | `SCN-B042-001` |
| AC-2 | An older substituted-control GREEN is superseded by a later matching GREEN. | `SCN-B042-002` |
| AC-3 | An older exit-zero RED is superseded by a later failing RED and coherent chain. | `SCN-B042-003` |
| AC-4 | Equal timestamps resolve by append order. | `SCN-B042-004` |
| AC-5 | A newer invalid receipt remains a visible blocker and does not erase a prior valid chain. | `SCN-B042-005` |
| AC-6 | The existing revision-drift cases retain the `BUG-034` result. | broader regression |
| AC-7 | Every bypass-shaped flag remains rejected. | existing resolver selftest |

## Out of Scope

- Modifying `scenario-state-resolve.sh` in this bootstrap slice.
- Adding or changing persistent selftest code in this bootstrap slice.
- Changing `BUG-034` or its historical evidence.
- Editing release manifests, framework validation, or transition-guard selftests.
- Reproducing the entire 34-blocker downstream packet.

## Ownership

`bubbles.bug` owns this discovery packet. `bubbles.design` must adjudicate the
selection model before implementation. `bubbles.implement` owns the eventual
source and persistent test changes.