# Bug: BUG-023 Result-Envelope Outcome Contract Drift

## Summary

Framework-shipped skills publish an active result/status contract that conflicts
with the authoritative shared governance modules. The result-envelope skill
omits `completed_diagnostic`, presents `done_with_concerns` as a new outcome,
and teaches a four-value set different from validation. Three related skills
retain active `done_with_concerns` semantics even though completion governance
permits that value only for explicitly marked legacy read-only compatibility.

## Severity

- [ ] Critical - Framework cannot run
- [x] High - Agents can emit or persist noncanonical workflow outcomes
- [ ] Medium - Localized guidance defect with no routing impact
- [ ] Low - Cosmetic wording only

## Status

- [x] Reported
- [x] Confirmed by current source inspection
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Current-Truth Source Evidence

**Claim Source:** interpreted

**Interpretation:** The cited files were read from the clean canonical clone at
`origin/main` commit `aa78e91`. No shell reproduction, regression test, lint,
or validation command was run for this intake.

The current sources disagree as follows:

1. `skills/bubbles-result-envelope/SKILL.md` advertises
   `completed_owned | route_required | blocked | done_with_concerns` in its
   terminal envelope and canonical outcome table.
2. `agents/bubbles_shared/validation-core.md` requires a concrete outcome from
   `completed_owned`, `completed_diagnostic`, `route_required`, or `blocked`.
3. `agents/bubbles_shared/completion-governance.md` states that
   `done_with_concerns` is legacy read-only compatibility, is not a valid new
   RESULT-ENVELOPE outcome, and must migrate to `done` plus `observations[]` or
   `blocked` on recertification.
4. `skills/bubbles-feature-template/SKILL.md` still describes
   `state.json.followUps[]` as active only under `done_with_concerns`.
5. `skills/bubbles-fix-cycle-protocol/SKILL.md` still permits finding closure
   through `followUps[]` under `done_with_concerns`.
6. `skills/bubbles-status-transition/SKILL.md` names
   `in_progress` to `done_with_concerns` as an ordinary status transition in
   its active description.

## Reproduction Steps

1. Read the terminal envelope shape and outcome table in
   `skills/bubbles-result-envelope/SKILL.md`.
2. Compare that set with Tier 1 item 5 in
   `agents/bubbles_shared/validation-core.md`.
3. Compare the active `done_with_concerns` guidance with the legacy-status
   section in `agents/bubbles_shared/completion-governance.md`.
4. Inspect the three related skills for active new-write semantics.
5. Observe that an agent following skills-first guidance can omit
   `completed_diagnostic` or emit a status that authoritative validation must
   reject.

## Expected Behavior

- Every active framework guidance surface exposes exactly
  `completed_owned`, `completed_diagnostic`, `route_required`, and `blocked`
  as RESULT-ENVELOPE outcomes.
- `completed_diagnostic` has an explicit, usable definition for diagnostic
  agents that completed their owned analysis without claiming delivery.
- New non-blocking notes use `completed_owned` with `observations[]` and valid
  certification uses `done` with `observations[]`.
- Any retained `done_with_concerns` text is isolated under an explicit
  legacy-read-only heading and states that new writes are forbidden.
- A deterministic regression compares active skill semantics with the
  authoritative modules and rejects drift.

## Actual Behavior

Skills-first consumers receive a stale outcome set and stale status-writing
instructions. The authoritative validator and completion rules therefore
disagree with the guidance agents are most likely to load at the end of a run.

## Impact

- Diagnostic agents may lack a documented valid outcome.
- Orchestrators may receive an outcome that current validation does not allow.
- New packets may perpetuate a legacy status that Gate G092 forbids.
- Finding accounting may be routed into legacy `followUps[]` instead of the
  current addressed/unresolved/observations contract.

## Root-Cause Hypothesis

The skills were not updated atomically when completion governance introduced
`completed_diagnostic` and replaced active `done_with_concerns` semantics with
`done` plus `observations[]`. A deterministic parity check does not currently
bind the discovery skills to the authoritative vocabulary.

## Change Boundary And Exact Owners

| Surface | Owner | Authorized responsibility |
| --- | --- | --- |
| `design.md` | `bubbles.design` | Confirm one canonical active-outcome and legacy-read parsing model. |
| `scopes.md`, `scenario-manifest.json`, `test-plan.json`, `uservalidation.md` | `bubbles.plan` | Reconcile executable scope, scenario parity, and DoD. |
| Four cited `skills/**/SKILL.md` files | `bubbles.implement` | Remove stale active semantics and align guidance with authority. |
| `tests/regression/test_30_result_envelope_outcome_contract_drift.sh` | `bubbles.test` | Own RED/GREEN bytes, parser fixtures, and adversarial mutations. |
| Regression registration and install-provenance assertions | `bubbles.test` | Register only after focused GREEN and preserve source/managed classification. |
| Generated release identity | `bubbles.releases` | Reconcile only after canonical source and test bytes settle. |
| `state.json::certification.*` and terminal status | `bubbles.validate` | Independently certify after all evidence exists. |

This intake may create only this packet directory. It does not authorize edits
to source, tests, generated manifests, `BUGS.md`, `improvements/INDEX.md`, or
downstream copies.

## Protected Authority

`agents/bubbles_shared/validation-core.md` and
`agents/bubbles_shared/completion-governance.md` are the authority against
which the stale skills are repaired. They remain unchanged unless a later
owner demonstrates a separate authority defect and routes it independently.

## Related Files

- `skills/bubbles-result-envelope/SKILL.md`
- `skills/bubbles-feature-template/SKILL.md`
- `skills/bubbles-fix-cycle-protocol/SKILL.md`
- `skills/bubbles-status-transition/SKILL.md`
- `agents/bubbles_shared/validation-core.md`
- `agents/bubbles_shared/completion-governance.md`
