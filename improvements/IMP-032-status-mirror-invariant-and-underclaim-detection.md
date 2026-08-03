# IMP-032 — Status-mirror invariant: name it, explain it at failure time, and give it a legal repair path

**Status:** APPLIED 2026-08-03 — SCOPE-2a/2b/3/4a/5 landed; SCOPE-1 withdrawn; SCOPE-4b deferred
**Closeout:** SCOPE-1's gate premise was falsified against source. SCOPE-2b landed 2026-08-03: its recorded blocker assumed the structured block needed a NEW field. It did not. `state-transition-guard.sh` already parses the resolver's `E009-*` code and passes it through to the existing `blockingCode` field, so emitting `E009-STATUS-MIRROR` makes the mirror cause machine-distinguishable with no schema change, no field-count change, and no downstream parser migration. SCOPE-4b requires a validate-owned recertification workflow rather than a standalone writer. The full rationale and unmet acceptance criterion are preserved in `CHANGELOG.md` under `[Unreleased]`.
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A downstream audit of `research-lab` (commits `d61017f2` status reconciliation, `9ac151ae` spec-016 promotion) found six specs left in a state no guard can resolve, and — more importantly — found that the framework's own error output led the diagnosing agent to file a **false upstream bug against working framework code**. The proposal targets the ergonomics failure, not just the state.
**Verified gaps addressed:** `EV-4` status mirrors can diverge silently and have no legal repair path · `COV-4` under-claimed status is undetectable · `DOC-4` the documented rule states a precondition, not a write-time obligation · `REG-5` the invariant has no gate ID

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

- **`REG-5` — the invariant has no gate ID.**
  `grep -cE 'mirrors disagree|status mirror' bubbles/registry/gates.yaml` → **0**. The rule
  is enforced by two scripts and named by none. It cannot be cited in a DoD, waived,
  measured, or reasoned about as a gate, and a reader auditing `gates.yaml` for "what can
  block me" will not find it.

**Explicitly NOT a framework gap (recorded so nobody builds for it).** The same audit
examined a derived-ledger regression in `research-lab` (merge `b5b24dd2`, repaired by
`37375463`). It is entirely product-owned: the ledger backfills from committed append-only
source files that the merge unioned, and the repo's own selftest caught it honestly. It
required no framework change and should not motivate one.

## Original proposal

Every scope is additive and default-preserving. SCOPE-2 and SCOPE-3 are the high-value,
low-risk pair and are independently landable.

### SCOPE-1 — Register the invariant as a named gate (`REG-5`)

- Add a gate entry to `bubbles/registry/gates.yaml` for status-mirror consistency,
  `enforcedBy: [ script:bubbles/scripts/transition-contract-resolver.sh, script:bubbles/scripts/artifact-lint.sh ]`.
- **No new enforcement.** This is registry truth catching up to shipped behavior, in the
  same spirit as REG-2 (a gate declared but with no script was the mirror-image defect).
- Keep the `gates.yaml` → `workflows.yaml` mirror in sync through the existing generation
  path rather than hand-editing both copies.

### SCOPE-2 — Make the failure self-explaining at the point of failure (`EV-4`) ⭐ highest value

- In `transition-contract-resolver.sh` L144, include **both observed values and the
  remediation owner**, matching what `artifact-lint.sh` L640 already does:
  `top-level status 'specs_hardened' does not match certification.status 'not_started' — certification.* is bubbles.validate-owned; route the reconciliation there`.
- Emit a **distinct sub-code** (recommended: `E009-STATUS-MIRROR`) so the four current
  `E009-TARGET-MISMATCH` causes are distinguishable. Recommendation: keep
  `E009-TARGET-MISMATCH` as the exit-69 class and add the sub-code additively, so existing
  selftest assertions on the class string continue to hold (see R2).
- Rationale: this single change is what would have prevented the false upstream bug report.
  A resolver that names its own cause ends the investigation in one step.

### SCOPE-3 — Restate the documented rule as a write-time obligation (`DOC-4`)

- Rewrite `feature-templates.md` L432 so it states the invariant, not a precondition:
  *`status` and `certification.status` are two mirrors of one fact. Any write to one MUST
  carry a matching write to the other. `certification.*` is `bubbles.validate`-owned, so a
  non-validate actor that finds `status` stale MUST route the correction to
  `bubbles.validate` rather than advance `status` alone — a half-write makes the spec
  unresolvable (`E009-TARGET-MISMATCH`).*
- Doc-only, no behavior change, unblocks the field immediately.

### SCOPE-4 — Give the divergence a legal repair path (`EV-4`)

Two halves; **recommend landing 4a first** because it is doc-only and closes the
"no third move" trap today.

- **4a (guidance).** State in the ownership/routing guidance that a status-mirror
  divergence is a `route_required` to `bubbles.validate`, and supply the packet shape.
  This makes the correct move explicit instead of leaving an agent to choose between two
  wrong ones.
- **4b (tooling).** Add a validate-owned reconciliation entry point modeled on the existing
  [`state-linkage-backfill.sh`](../bubbles/scripts/state-linkage-backfill.sh) — a proven
  shape in this repo: **dry-run by default, `--apply` to write**. It brings the mirrors into
  agreement for a status the guard already passed, and MUST refuse to invent a
  `certifiedAt` or to promote a status the guard has not evaluated.

### SCOPE-5 — Advisory detection of status behind evidence (`COV-4`)

- Add a repo-scan that reports specs whose top-level `status` is `not_started` while
  resolved scope artifacts contain ≥1 `Done`, or whose `execution.completedPhaseClaims`
  is non-empty. Surface it in `cli.sh doctor` under the existing advisory bands.
- **Advisory, never blocking.** Under-claiming asserts nothing false; making it blocking
  would invert the framework's anti-fabrication safety posture and could pressure agents
  toward premature promotion — the exact failure this proposal is trying to prevent.
- Deliberately targeted at `doctor` rather than a hook: doctor already reports that
  Bubbles-managed hooks are framework-source-only, so a downstream repo runs **no** guard
  automatically. A detector wired only into hooks would not run where the defect occurs.

## Migration / rollout

- SCOPE-2 and SCOPE-3 are independent and can land first; neither changes control flow.
- SCOPE-1 is registry-only and should land with (or after) SCOPE-2 so the gate entry can
  cite the final message/sub-code.
- SCOPE-4a is doc-only. SCOPE-4b introduces a script that writes `certification.*` and
  should land last, after the guidance exists to constrain its use.
- SCOPE-5 is additive and advisory from the first commit; it changes no exit code.
- No scope requires a downstream repo to re-install or re-wire anything.

## Risks & mitigations

- **R1** SCOPE-1 desynchronises the `gates.yaml` → `workflows.yaml` gate mirror → regenerate
  through the existing generation path, never hand-edit both; verify with the same surface-parity
  check that covers REG-2.
- **R2** SCOPE-2's message change breaks selftests asserting the current string →
  `state-transition-guard-selftest.sh` and `transition-contract-resolver-selftest.sh` assert
  on `E009-TARGET-MISMATCH`; keep that class token stable and add the sub-code additively.
- **R3** SCOPE-4b writes the most trust-sensitive field in the schema → dry-run default,
  explicit `bubbles.validate` ownership, refuse to fabricate `certifiedAt`, refuse any status
  the transition guard has not passed.
- **R4** SCOPE-5 is noisy on legitimately parked work → advisory only; exclude specs whose
  status is `blocked` with a non-empty `blockedReason`.
- **R5** Naming a gate (SCOPE-1) is mistaken for new enforcement and alarms downstream repos →
  state in the gate description that it registers behavior shipped since the resolver's
  introduction and changes no outcome.

## Acceptance criteria (when implemented)

- A `state.json` with `status: specs_hardened` and `certification.status: not_started`
  produces a resolver message that **names both values and `bubbles.validate`** as owner,
  and is distinguishable from the other three `E009-TARGET-MISMATCH` causes.
- `grep -cE 'mirrors disagree|status mirror' bubbles/registry/gates.yaml` returns **> 0**, and
  the gate names both enforcing scripts.
- `feature-templates.md` states the mirror rule as an obligation on every `status` write; a
  reader following it literally cannot produce the half-written state.
- An agent that finds `status` behind evidence has a documented, non-contradictory move
  (route to `bubbles.validate`) that does not require choosing between a false record and an
  unresolvable one.
- `doctor` reports a spec that is `not_started` with ≥1 Done scope as an advisory, and its
  exit code is unchanged.
- The six `research-lab` specs are repairable through the documented path without a hand-edit.

## Files to touch (on approval)

`bubbles/registry/gates.yaml` + generated `bubbles/workflows.yaml` mirror (SCOPE-1 — gate
registration; owner `bubbles.setup`/registry maintainer) · `bubbles/scripts/transition-contract-resolver.sh`
(SCOPE-2 — message + sub-code; owner `bubbles.devops`) · `bubbles/scripts/transition-contract-resolver-selftest.sh`
and `bubbles/scripts/state-transition-guard-selftest.sh` (SCOPE-2 — assertions for the new
message shape; owner `bubbles.test`) · `agents/bubbles_shared/feature-templates.md` (SCOPE-3 —
restate as obligation; owner `bubbles.docs`) · artifact-ownership/routing guidance +
`skills/bubbles-status-transition/SKILL.md` (SCOPE-4a — route-required packet; owner `bubbles.docs`) ·
new `bubbles/scripts/state-certification-reconcile.sh` + selftest (SCOPE-4b — dry-run-default
repair tool; owner `bubbles.validate`) · `bubbles/scripts/cli.sh` doctor advisory band + its scan
(SCOPE-5 — under-claim detector; owner `bubbles.devops`).

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
