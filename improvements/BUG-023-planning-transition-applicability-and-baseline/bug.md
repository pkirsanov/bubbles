# Bug: BUG-023 Planning Transition Applicability And Baseline

## Summary

The target-aware state-transition guard can reject a source-locked
`product-to-planning` packet at its `specs_hardened` ceiling for three reasons
that do not describe work performed by that planning run: runtime RED-to-GREEN
evidence is applied outside its delivery profile, legitimate planning nouns are
classified as incomplete work, and unrelated source changes already present in
the shared worktree are attributed to the planning packet.

## Severity

- [ ] Critical - System unusable or data loss
- [x] High - A planning-only certification path is structurally blocked
- [ ] Medium - Feature broken with a reliable workaround
- [ ] Low - Minor or cosmetic issue

## Status

- [x] Reported
- [x] Confirmed by downstream target-aware guard output supplied at intake
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Reporter And Unblocking Target

- Downstream consumer: QuantitativeFinance Spec 097
- Requested outcome: unblock and finish the upstream framework bug, then return
  a supported propagation/setup handoff
- Canonical repository: `/Users/pkirsanov/Projects/bubbles`
- Forbidden mutation surface:
  `/Users/pkirsanov/Projects/QuantitativeFinance/.github/bubbles/**`
- Framework versions observed by the reporter: canonical and downstream
  `7.20.0`, with identical relevant guard code

The downstream spec is not certified by this packet. Upstream repair,
canonical validation, release selection, supported downstream upgrade, and a
fresh downstream transition run are distinct evidence boundaries.

## Reproduction Steps

1. Start with a `product-to-planning` state whose transition audit resolves to
   profile `planning-maturity-v1`, target `specs_hardened`, and
   `planningOnly: true`.
2. Keep implementation source locked and omit runtime RED-to-GREEN evidence,
   because no implementation tests may execute in this mode.
3. Include active planning language using domain labels such as Authorized
   Outcome Follow-Up, a follow-up projection noun, and a statement defining
   the exact MVP surface.
4. Run the planning workflow in a shared Git worktree that already contains an
   unrelated source or configuration modification created before the planning
   run.
5. Execute the target-aware state-transition guard for `specs_hardened`.
6. Observe failed gates G060, G040, and G073, with blocking code
   `SOURCE_EDIT_LOCKOUT`, despite the planning structural gates passing.

## Expected Behavior

- `planning-maturity-v1` treats runtime scenario-first RED-to-GREEN execution
  evidence as not applicable.
- Delivery profiles, including full delivery and bugfix fastlane, continue to
  enforce G060 without a bypass.
- G040 blocks actual statements that postpone required work but accepts noun
  labels and active statements that define the present implementation surface.
- G073 ignores only exact source/config path states cryptographically proven
  to predate the planning run.
- A new path, changed staged blob, changed worktree content, status transition,
  malformed baseline, mismatched binding, or unproven path remains blocking.
- A legacy packet with no baseline contract retains the existing whole-worktree
  source lockout behavior.

## Actual Behavior

- The sourced control-plane check evaluates G060 from policy activation even
  when the resolved planning audit does not list runtime TDD evidence as an
  applicable check.
- Check 18 relies on broad lexical matching that conflates `follow-up` noun
  compounds and active MVP descriptions with postponement.
- Check 3B scans the current worktree as one undifferentiated set and has no
  trustworthy run-start snapshot against which to distinguish pre-existing
  foreign dirt from a new planning-run mutation.

## Intake Evidence

**Claim Source:** interpreted

The reporter supplied a verified downstream run with exit `1`, failed gates
`[G073,G060,G040]`, and blocking code `SOURCE_EDIT_LOCKOUT`. This canonical
packet records those observations as interpreted intake facts until
`bubbles.test` executes the final hermetic regression against unchanged
canonical production bytes.

## Environment

- Canonical version: `7.20.0`
- Downstream version: `7.20.0`
- Platform: macOS
- Canonical revision at intake: `cd286d15b9de010dd40f43b747fe02dab8771b19`
- Canonical worktree at intake: clean according to `git status --short`
- Primary production files:
  - `bubbles/scripts/state-transition-guard.sh`
  - `bubbles/scripts/guards/control-plane-checks.sh`
- Primary managed regression:
  - `bubbles/scripts/state-transition-guard-selftest.sh`
- Reserved persistent regression:
  - `tests/regression/test_30_planning_transition_applicability_and_baseline.sh`

## Root Cause Intake

The local hypothesis is that all three failures come from incomplete
consumption of the resolved transition contract:

1. G060 decides activation from TDD policy without first applying the resolved
   transition audit's planning-versus-delivery applicability.
2. G040 decides from isolated tokens instead of grammatical intent and local
   artifact context.
3. G073 has only the current Git status and therefore cannot prove whether a
   dirty source state existed before or appeared after workflow start.

This hypothesis is falsified if a hermetic fixture that varies only profile,
phrase context, or baseline timing does not change the corresponding gate
result while all other fixture bytes remain fixed.

### Canonical Source Confirmation

Canonical inspection confirmed the three missing inputs:

- `guards/control-plane-checks.sh` resolves TDD mode and immediately evaluates
  RED-to-GREEN ordering without consulting `transition_audit_profile`.
- `state-transition-guard.sh` Check 18 includes bare `follow-up`, `follow up`,
  and `followup` alternatives in `deferral_pattern`.
- `state-transition-guard.sh` Check 3B enumerates staged and unstaged path names
  from the current worktree and compares neither stream with a run-start
  identity.

The repository's existing `state-snapshot.sh` records append-only turn metadata
but no Git HEAD, status, index object, worktree digest, or target binding. It is
a candidate lifecycle integration point, not an already sufficient baseline.

## Change Boundary

### Candidate production and contract surfaces

- `bubbles/scripts/state-transition-guard.sh`
- `bubbles/scripts/guards/control-plane-checks.sh`
- `bubbles/scripts/state-transition-guard-selftest.sh`
- a narrowly owned baseline capture/validation helper if design proves one is
  needed
- the canonical state schema and state template if a persisted baseline
  reference is selected
- direct gate/transition operator documentation and skill text
- `tests/regression/test_30_planning_transition_applicability_and_baseline.sh`
- installer/release provenance surfaces only under their named owners

### Excluded surfaces

- every QuantitativeFinance managed Bubbles file
- QuantitativeFinance Spec 097 planning or certification artifacts
- unrelated canonical dirty work and sibling bug packets
- delivery-mode evidence weakening, bypass flags, skip flags, or force flags
- broad state-transition refactors not required by these three gate contracts

## Related

- Gate G040: deferral language detection
- Gate G060: scenario-first TDD evidence
- Gate G073: planning-only source edit lockout
- Downstream blocked target: QuantitativeFinance `specs/097-tenant-entity-ownership-kernel`
- Canonical mode: `bugfix-fastlane`

## Routing

The required planning chain is `bubbles.analyst` -> `bubbles.ux` ->
`bubbles.design` -> `bubbles.plan`. The final regression must be executed RED
by `bubbles.test` before `bubbles.implement` changes production bytes.

The current runtime does not expose the VS Code `agent` / `runSubagent`
capability required to invoke those owners. No specialist execution is claimed,
and implementation is not permitted until a top-level authorized runtime with
that capability resumes this packet.
