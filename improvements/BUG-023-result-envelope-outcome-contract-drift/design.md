# Bug Fix Design: BUG-023 Result-Envelope Outcome Contract Drift

## Design Brief

### Current State

The skills-first result-envelope contract and three adjacent status/finding
skills lag behind `validation-core.md` and `completion-governance.md`. Because
agents load skills lazily, this drift occurs directly on the routing path used
at invocation closeout.

### Target State

All active skill guidance uses one four-value result outcome set, current
`observations[]` semantics, and explicit diagnostic completion. Legacy status
text remains only where a heading and surrounding prose make read-only
compatibility unambiguous. A deterministic parser regression binds these
surfaces together.

### Local Hypothesis And Discriminator

The defect is guidance drift rather than an authority conflict. Replacing only
the four stale skill semantics should make an exact-set parser pass without
changing either authoritative module. A regression that derives the canonical
set from `validation-core.md` and classifies Markdown by active versus
legacy-read-only section can disconfirm that hypothesis before broader checks.

## Source Reconciliation Design

### `skills/bubbles-result-envelope/SKILL.md`

- Change the terminal envelope outcome line and canonical table to exactly the
  four active outcomes.
- Add a concrete `completed_diagnostic` row.
- Describe non-blocking notes as `observations[]` attached to
  `completed_owned`.
- Remove active `done_with_concerns` finding accounting and common-mistake
  semantics.
- If legacy compatibility is mentioned, place it under an exact
  `Legacy read-only compatibility` heading and state that new writes are
  forbidden.

### `skills/bubbles-feature-template/SKILL.md`

- Replace the active `state.json.followUps[] under done_with_concerns` control
  plane bullet with validate-owned `certification.observations[]` under
  `status: done`.
- Retain legacy-read information only in an explicitly marked read-only note
  when it materially helps readers inspect old packets.

### `skills/bubbles-fix-cycle-protocol/SKILL.md`

- Require each input finding to remain in `addressedFindings`,
  `unresolvedFindings`, or a concrete blocked result.
- Permit `observations[]` only for genuinely non-blocking notes on
  `completed_owned`; never use observations to remove an unresolved input
  finding.
- Remove the active `followUps[] under done_with_concerns` route.

### `skills/bubbles-status-transition/SKILL.md`

- Remove `done_with_concerns` from ordinary transition examples and active
  lifecycle guidance.
- Add only an explicit legacy-read-only reference consistent with Gate G092,
  if retaining the token improves historical inspection guidance.

## Deterministic Regression Design

The test owner reserves
`tests/regression/test_30_result_envelope_outcome_contract_drift.sh`.
The regression must:

1. Extract the four backticked active outcomes from Tier 1 item 5 of
   `agents/bubbles_shared/validation-core.md` and fail if the authority is
   ambiguous or duplicated.
2. Parse the result-envelope skill's canonical outcome table as Markdown and
   compare a normalized, sorted set plus per-token cardinality against the
   authority.
3. Scan all four affected skills by heading. A `done_with_concerns` token is
   accepted only under an exact legacy-read-only heading whose prose also says
   new writes are forbidden.
4. Reject active `followUps[]` routing coupled to the legacy status.
5. Verify `completed_diagnostic` has a nonempty semantic definition, not only
   a token occurrence.
6. Run isolated fixtures for a missing diagnostic outcome, an extra legacy
   outcome, a duplicate canonical row, an unmarked legacy instruction, and a
   correctly marked read-only paragraph.
7. Mutate each repaired source family in a disposable copy and prove the
   regression fails without changing canonical bytes.

The parser must fail closed on malformed tables or ambiguous headings. Plain
token-count grep is insufficient because authoritative legacy prose is allowed
and active semantics must be distinguished structurally.

## Change Boundary

### Packet-Creation Invocation

Only the nine files under this bug directory may be created. No framework
source, test, registration, generated manifest, shared index, or downstream
file is in the current invocation boundary.

### Authorized Delivery Boundary

| Owner | Exact surfaces | Permitted work |
| --- | --- | --- |
| `bubbles.implement` | Four cited `skills/**/SKILL.md` files | Contract-alignment prose only; no authority or unrelated skill edits. |
| `bubbles.test` | `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | Deterministic parser, fixtures, RED/GREEN, and source mutations. |
| `bubbles.test` | Focused framework registration/provenance surfaces | Add one collision-safe source-only regression registration after GREEN. |
| `bubbles.releases` | Generated release identity | Reconcile generated hashes after stable canonical inputs. |
| `bubbles.validate` | Certification fields and terminal status | Independently certify exact parity and all gates. |

### Protected Surfaces

- `agents/bubbles_shared/validation-core.md`
- `agents/bubbles_shared/completion-governance.md`
- all unrelated agents and skills
- `BUGS.md` and `improvements/INDEX.md`
- product/downstream repositories and installed managed copies

## Preserved Contracts

- RESULT-ENVELOPE field names and finding-accounting visibility.
- CONTINUATION-ENVELOPE routing through workflow.
- Validate-owned certification and status mirroring.
- Legacy packet readability when compatibility metadata is present.
- No new dependency, configuration value, API, UI, storage, deployment, or
  feature flag.

## Failure And Rollback

The four skill edits are one atomic contract repair. If focused parity fails,
rollback restores all four skill files to their exact pre-edit hashes; a
partial state where only the result-envelope skill changes is not accepted.
Generated release identity is reconciled only after source and tests are
stable.

## Owner Route

1. `bubbles.design` validates the active/legacy parser boundary.
2. `bubbles.plan` reconciles the exact Test Plan and DoD.
3. `bubbles.test` captures final-byte RED before source changes.
4. `bubbles.implement` applies only the four-skill repair.
5. `bubbles.test` runs identical-byte GREEN, adversarial fixtures, and broader
   framework checks.
6. `bubbles.releases` reconciles generated release identity.
7. `bubbles.validate` owns certification and any terminal transition.
