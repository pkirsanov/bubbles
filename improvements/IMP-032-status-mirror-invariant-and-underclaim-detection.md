# IMP-032 — Status-mirror invariant: name it, explain it at failure time, and give it a legal repair path

**Status:** APPLIED 2026-08-02 — SCOPE-2a, SCOPE-3, SCOPE-4a and SCOPE-5 landed. SCOPE-1 WITHDRAWN (premise falsified against source). SCOPE-2b and SCOPE-4b DEFERRED under their own entry conditions, recorded below.
**Surface:** framework-health (G125) — human-reviewed; no scope landed before its premise was re-verified against source
**Motivation:** A downstream audit of `research-lab` (commits `d61017f2` status reconciliation, `9ac151ae` spec-016 promotion) found six specs left in a state no guard can resolve. More importantly it found that the framework's own error output led the diagnosing agent to file a **false upstream bug against working framework code**. This targets the ergonomics failure, not just the state.
**Verified gaps addressed:** `EV-4` status mirrors diverge silently and the failure does not name its own cause · `COV-4` under-claimed status is undetectable · `DOC-4` the documented rule states a precondition, not a write-time obligation · ~~`REG-5` the invariant has no gate ID~~ — **FALSIFIED during implementation, see below**

## Problem (verified against source)

The trigger was a routine, well-intentioned bookkeeping correction. Six specs had run
implement/test/validate phases without anyone advancing their lifecycle status. An
orchestrator corrected the top-level `status` on all six and **deliberately left
`certification.*` untouched**, correctly citing `bubbles.validate` ownership. Every
one of those six specs is now unresolvable.

- **`EV-4` — the invariant is real, undocumented as an obligation, and has no legal repair path.**
  [`transition-contract-resolver.sh` L142-145](../bubbles/scripts/transition-contract-resolver.sh#L142-L145)
  fails `69 E009-TARGET-MISMATCH` whenever `.certification.status` is present and differs
  from `.status`. Artifact ownership says only `bubbles.validate` may write
  `certification.*`. Those two rules together mean **any non-validate actor that corrects
  a stale `status` necessarily produces an unresolvable spec** — while an actor that
  leaves it alone knowingly retains a false record. There is no third move. Verified
  2026-08-02: all six reconciled specs return `rc=69`
  (`001` → `blocked`, `004`/`006`/`008` → `in_progress`, `007` → `blocked`,
  `016` → `specs_hardened`; every one with `certification.status: not_started`).

- **`EV-4` (second face) — the failure message does not identify its own cause, and cost a false bug report.**
  The resolver emits `E009-TARGET-MISMATCH: top-level and certification status mirrors
  disagree` — no observed values, no remediation owner. The **same code** is emitted by
  four unrelated conditions (L144 mirror, L291 terminal contradiction, L296 planning+done,
  L402/405/408 expectation mismatch). Because L144 runs *before* the registry lookup at
  L147, the guard then reports `workflowMode`/`auditProfile`/`targetStatus` as
  `UNRESOLVED`. The diagnosing agent read that `UNRESOLVED` as evidence that a status
  ceiling was unsupported and recorded, in `specs/016-.../state.json`, that
  "`specs_hardened` … [is] never in the ceiling resolution map" with an operator action to
  "track upstream in the Bubbles framework."
  **That conclusion is false.** 30 specs across smackerel/GuestHost/QuantitativeFinance/knb
  sit at `specs_hardened` and resolve exit 0; QF `specs/100-m0-truth-freeze` returns
  `statusCeiling=targetStatus=currentStatus=specs_hardened` against a **byte-identical**
  resolver and `modes.yaml` (`aa0af8cc006c` / `1f689b425c44`). The framework was working;
  the message pointed nowhere; an operator was dispatched to "fix" correct code.
  Note that [`artifact-lint.sh` L640](../bubbles/scripts/artifact-lint.sh#L640) **already
  emits the good message** — `Top-level status 'X' does not match certification.status 'Y'`
  — in the same run, two lines after the ❌. The information exists; the resolver discards it.

- **`DOC-4` — the one documented sentence describes a precondition, not an obligation.**
  [`feature-templates.md` L432](../agents/bubbles_shared/feature-templates.md#L432) reads:
  *"certification is the validate-owned authoritative state that must match top-level
  `status` **before promotion**."* Read literally, that instructs an agent to *check
  agreement before promoting*. The runtime rule is stronger and different: **any write to
  `status` must carry a matching `certification.status` write, or the artifact becomes
  unresolvable afterwards.** An agent following the documented sentence exactly still
  produces the broken state — which is what happened.

- **`COV-4` — enforcement is asymmetric; under-claimed status is invisible.**
  [`state-transition-guard.sh` Check-5-all-done](../bubbles/scripts/state-transition-guard.sh#L1195-L1203)
  blocks promotion when scopes are not Done (over-claiming). Nothing detects the inverse.
  Verified: `cli.sh doctor` in `research-lab` returned **18 passed / 0 failed / 9 advisory**
  while six specs read `not_started` against Done scopes and shipped, git-tracked code
  (`trend-dynamics-cycle-lab.html`, 313 KB; `technical-analysis-decision-lab.html`, 92 KB).
  This asymmetry is a *reasonable* consequence of an anti-fabrication-first design —
  under-claiming asserts nothing false — but it is not harmless: work-pickers select by
  status, so an under-claimed spec is silently re-picked or skipped.

- **`REG-5` — FALSIFIED during implementation. The proposal was wrong; the framework is right.**
  The proposal claimed the invariant is defective because it has no gate ID. Re-checked
  against source before touching the registry: `grep -n 'transition-contract-resolver'
  bubbles/registry/gates.yaml` returns **nothing**, and `grep -c 'E009'` on the same file
  returns **0**. No `E009` resolution precondition anywhere — usage, registry-missing,
  state-malformed, mode-unknown, mode-mismatch, target-mismatch, audit-profile-contradiction
  — carries a gate ID. That is coherent design, not an omission: these run BEFORE a mode is
  resolved, so they cannot be a mode's `requiredGates` entry, and the guard records them as
  `failedChecks: [contract-resolution]` rather than a gate. Minting a gate for the mirror
  check alone would have made it the single exception and introduced the inconsistency it
  claimed to fix. SCOPE-1 is WITHDRAWN.

**Explicitly NOT a framework gap (recorded so nobody builds for it).** The same audit
examined a derived-ledger regression in `research-lab` (merge `b5b24dd2`, repaired by
`37375463`). It is entirely product-owned: the ledger backfills from committed append-only
source files that the merge unioned, and the repo's own selftest caught it honestly. It
required no framework change and should not motivate one.

## Proposal

Every landed scope is additive and default-preserving. No scope changed an exit code.

### SCOPE-1 — WITHDRAWN: register the invariant as a named gate (`REG-5`)

Not implemented. The premise was re-checked against source before any registry edit and did
not survive. No `E009` resolution precondition carries a gate ID, because these checks run
before a mode is resolved and therefore cannot belong to a mode's `requiredGates`. See the
corrected `REG-5` entry above. Registering a gate here would have created the only exception
in the registry.

### SCOPE-2a — LANDED: make the failure name its own cause (`EV-4`) ⭐ highest value

`transition-contract-resolver.sh` now reports both observed values and the owning agent.

- Before: `E009-TARGET-MISMATCH: top-level and certification status mirrors disagree`
- After: `E009-TARGET-MISMATCH: top-level status 'specs_hardened' does not match certification.status 'not_started' — certification.* is bubbles.validate-owned, so route the reconciliation there instead of advancing status alone`

Verified against the real spec that caused the misdiagnosis. An agent reading the new line
cannot conclude that a status ceiling is unsupported. The resolver selftest gained an
assertion that both values and the owner are present, so the message cannot silently
regress to a value-free string.

### SCOPE-2b — DEFERRED: carry the detail into the structured result (`EV-4`)

Tracing the propagation path surfaced the higher-value half of SCOPE-2 and its blocker in
the same step. `block_contract` prints the enriched detail to stderr, but
`emit_transition_result` writes only `blockingCode` into the `TRANSITION_GUARD_RESULT_V1`
block. The misdiagnosing agent recorded exactly those structured fields, so the detail never
reached the record.

Adding a `blockingDetail` field is not a local change. `state-transition-guard-selftest.sh`
validates the block **positionally against an exact field count**
(`if (begin_count != 1 || end_count != 1 || field_index != field_count) invalid = 1`),
`audit-result-contract-lint.sh` carries two further field lists, and installed copies of the
parser exist in seven downstream repos.

**Entry condition:** an owner decision on whether the field is v1-additive or requires
`transition-guard-result/v2`, plus a coordinated downstream migration. Until then the
enriched stderr line is the operator's path.

### SCOPE-3 — LANDED: restate the documented rule as a write-time obligation (`DOC-4`)

`feature-templates.md` said certification "must match top-level `status` **before
promotion**", which reads as a precondition to check. An agent following it literally still
produces the broken state. It now declares the invariant, states the routing rule, and names
the failure code a half-write produces.

### SCOPE-4a — LANDED: give the divergence a legal move (`EV-4`)

`skills/bubbles-status-transition/SKILL.md` gained a section stating that the two mirrors are
one fact, that `UNRESOLVED` in the guard output is a symptom of the early exit rather than a
ceiling defect, and that the only legal move is a `route_required` to `bubbles.validate`. It
carries the packet shape and states that the rule holds in both directions.

### SCOPE-4b — DEFERRED BY DESIGN: a reconciliation writer

The proposal asked for a dry-run-default tool that brings the mirrors into agreement. On
contact with the ownership model the operation splits in two, and neither half wants this
shape.

Reverting `status` down to match `certification.status` is safe, but it is a one-line undo
that discards the true observation that work shipped. Advancing `certification.status`
forward is what an operator actually wants, and that is a certification rather than a file
edit. A script that writes `certification.*` outside `bubbles.validate` would create exactly
the forging vector the mirror invariant exists to prevent.

The safe and genuinely useful half — reporting a divergence without repairing it — was
folded into SCOPE-5 instead.

**Entry condition:** a `bubbles.validate` workflow that re-runs the guard and records real
certification evidence. Not a standalone script.

### SCOPE-5 — LANDED: read-only detection of both drift classes (`COV-4`)

New `bubbles/scripts/state-consistency-scan.sh` reports two classes and never writes:

| Class | Condition | Why it matters |
|---|---|---|
| `mirror-divergence` | `status` differs from `certification.status` | the spec is unresolvable |
| `status-behind-evidence` | `status: not_started` with a Done scope or a completed phase claim | work-pickers select by status, so the spec is skipped |

Advisory, and always exit 0. A spec parked with a `blockedReason` is a deliberate hold and is
not flagged. Wired into `cli.sh doctor` under the existing readiness advisory band, because
doctor reports Bubbles-managed hooks as framework-source-only and a downstream repo therefore
runs no guard automatically.

`state-consistency-scan-selftest.sh` covers ten cases, including both finding classes, the
deliberate-hold exclusion, a malformed `state.json`, and the absence of a bypass flag. It
also caught a real defect during authoring: `pipefail` turned a no-match `grep` into a scan
abort.

**The scan found more than the manual audit did.** Against `research-lab` it reported eight
findings across 26 specs: the six known reconciled specs, plus a seventh mirror divergence in
`specs/_bugs/BUG-001-central-provider-credential-security` (`blocked` against `in_progress`,
a different cause) and a live under-claim in
`specs/012-.../bugs/BUG-002-scope-baseline-head-drift-antipattern` (`not_started` with two
Done scopes).

## Outcome

- SCOPE-2a, SCOPE-3, SCOPE-4a and SCOPE-5 landed. None changes an exit code or a control flow.
- SCOPE-1 is withdrawn because its premise was falsified against source.
- SCOPE-2b and SCOPE-4b are deferred under the entry conditions recorded above.
- No downstream repo needs to re-install or re-wire anything. Downstream repos pick these up
  through the normal installed-surface refresh.

## Risks & mitigations

- **R1** ~~SCOPE-1 desynchronises the gate mirror~~ — withdrawn, no registry edit was made.
- **R2** The message change breaks selftests asserting the old string → the
  `E009-TARGET-MISMATCH` class token is unchanged and `assert_failure` matches on the code
  prefix. Verified green.
- **R3** ~~SCOPE-4b writes the most trust-sensitive field in the schema~~ — deferred by
  design, no writer shipped.
- **R4** SCOPE-5 is noisy on legitimately parked work → advisory only, and a non-empty
  `blockedReason` excludes the spec.
- **R5** ~~A newly named gate alarms downstream repos~~ — withdrawn, no gate registered.
- **R6** The scan reports a large backlog on first run in an established repo → it is
  advisory, and every finding names the spec and the owning agent, so the backlog is
  actionable rather than blocking.

## Acceptance criteria

| Criterion | Result |
|---|---|
| The mirror refusal names both values and `bubbles.validate` | MET — verified on `research-lab` spec 016 |
| A selftest prevents the message regressing to a value-free string | MET — one new resolver-selftest assertion |
| `feature-templates.md` states the rule as an obligation on every `status` write | MET |
| An agent that finds `status` stale has a documented, non-contradictory move | MET — route packet in the status-transition skill |
| `doctor` reports under-claimed status as an advisory with an unchanged exit code | MET — verified against `research-lab` |
| A gate ID names the invariant | WITHDRAWN — premise falsified, no `E009` precondition is a gate |
| The structured guard result carries the failure detail | DEFERRED — SCOPE-2b entry condition |
| The six `research-lab` specs are repairable without a hand-edit | NOT MET — needs the `bubbles.validate` workflow named in SCOPE-4b's entry condition. They are now detected and the route is documented, which is the honest current state. |

## Files touched

`bubbles/scripts/transition-contract-resolver.sh` (SCOPE-2a) ·
`bubbles/scripts/transition-contract-resolver-selftest.sh` (SCOPE-2a assertion) ·
`agents/bubbles_shared/feature-templates.md` (SCOPE-3) ·
`skills/bubbles-status-transition/SKILL.md` (SCOPE-4a) ·
`bubbles/scripts/state-consistency-scan.sh` (new, SCOPE-5) ·
`bubbles/scripts/state-consistency-scan-selftest.sh` (new, SCOPE-5) ·
`bubbles/scripts/cli.sh` (SCOPE-5 doctor advisory).

Untouched by design: `bubbles/registry/gates.yaml`, `bubbles/workflows.yaml`, and the
`TRANSITION_GUARD_RESULT_V1` schema.

## Provenance

Independent read-only audit, 2026-08-02, of the `bubbles` framework source and the
`research-lab` downstream repo. Every claim below was re-derived by execution, not inferred.

| Evidence | Source |
|---|---|
| Six specs unresolvable, `rc=69`, `certification.status: not_started` | `transition-contract-resolver.sh` run against `research-lab` specs 001/004/006/007/008/016 |
| `specs_hardened` resolves cleanly when mirrors agree | `transition-contract-resolver.sh specs/100-m0-truth-freeze` (QuantitativeFinance) → exit 0, `statusCeiling=targetStatus=currentStatus=specs_hardened` |
| Framework parity across repos (rules out a version skew) | `shasum -a 256` of `transition-contract-resolver.sh` (`aa0af8cc006c`) and `workflows/modes.yaml` (`1f689b425c44`) — identical in research-lab / QuantitativeFinance / smackerel |
| 30 specs at `specs_hardened` with agreeing mirrors across 5 repos | status/certification scan of `specs/*/state.json` + `specs/*/*/state.json` |
| `artifact-lint` accepts the ceiling and reports the true cause | `artifact-lint.sh specs/016-auction-gamma-playbook` → ❌ mirror at line 94, ✅ *"permits current status 'specs_hardened'"* at line 96 |
| Under-claim invisible to `doctor` | `cli.sh doctor` (research-lab) → 18 passed / 0 failed / 9 advisory during the divergence |
| Downstream repos run no guard automatically | `.git/hooks` empty, `core.hooksPath` unset; doctor: *"expected — Bubbles-managed hooks are framework-source-only"* |
| The invariant is unnamed | `grep -cE 'mirrors disagree\|status mirror' bubbles/registry/gates.yaml` → 0 |
| Audited downstream commits | `d61017f2` (six-spec status reconciliation), `9ac151ae` (spec-016 promotion), `b5b24dd2`/`37375463` (derived-ledger merge pair — context only, out of scope) |
