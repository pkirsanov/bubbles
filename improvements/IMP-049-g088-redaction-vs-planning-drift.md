# IMP-049 — G088 cannot tell a mandated redaction from planning-truth drift

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A downstream consumer measurement found that 40 of 99 certified specs fail Gate G088, and that 76% of the flagged edits are mandated PII/genericization redactions that change no requirement. The gate's own remediation menu has no proportionate response at that scale, so the failures are carried. A blocking gate whose failures are routinely carried stops being read, and that precedent is the real damage.
**Verified gaps addressed:** EV-13 (certification-drift detection is path-level, so a mandated mechanical redaction is indistinguishable from a requirements change); EV-14 (the only escape from a G088 finding is an unvalidated boolean, so the gate's remediation menu offers no proportionate, evidence-backed response)

## Problem (verified against source)

All line citations below were re-checked against `bubbles/scripts/post-cert-spec-edit-guard.sh`
at 436 lines in this repository during this session. Line numbers carried into
this proposal from the reporting session were verified as exact and are marked
CONFIRMED; two claims required correction and are marked CORRECTED.

- **EV-13 — detection is path-level, never content-level.** The guard resolves
  its tracked set at lines 347-349 (`spec.md`, `design.md`, `scopes.md`)
  (CONFIRMED), then inspects history with `git log --name-only` at line 370 and
  the worktree with `git diff --name-only` at lines 375 and 380. Every one of the
  three inspections is `--name-only`. The guard never reads a hunk, so it has no
  mechanism by which it *could* distinguish one kind of edit from another. A file
  appearing in that name list is the entire finding. This is architectural, not a
  threshold that is set too tight.

- **EV-13 — the exposed surface is wider than three files (CORRECTED).** The
  reporting session described the tracked set as `spec.md`, `design.md`, and
  `scopes.md`. Line 350 also registers `scopes/_index.md`, and lines 352-356
  register every `scopes/*/scope.md` discovered by `find`. The registry entry at
  `bubbles/registry/gates.yaml:626` confirms all five path shapes. Per-scope
  `scope.md` files carry the same environment-specific values that a redaction
  policy compels a consumer to scrub, so the conflict reaches more files than the
  original report stated, not fewer.

- **EV-13 — obeying a mandated redaction policy necessarily produces findings.**
  Downstream Bubbles consumers operate under a non-negotiable policy that no real
  hostname, IP address, operator username, or tailnet identifier may appear in any
  committed file, `spec.md` included. Scrubbing such a value requires editing a
  certified planning file. Because the guard flags by path, that edit is a G088
  finding. A consumer that correctly obeys its own policy therefore accumulates
  G088 violations continuously, with no planning-truth drift at all. The two
  policies are individually correct and jointly unsatisfiable.

- **EV-13 — uncommitted redaction is flagged too.** Line 403 emits
  `commit=WORKTREE date=uncommitted file=$dirty_path subject=uncommitted planning
  truth edit` (CONFIRMED), and line 380 folds the staged index into the same
  check. A consumer cannot stage a redaction and run the gate chain before
  committing without the gate refusing.

- **EV-13 — a content-level comparison already exists in this script, but is a
  narrower thing than reported (CORRECTED).** The reporting session cited an
  "invariant-rule-level comparison path" as adjacent prior art. That path is real:
  line 270 reads `# Certified (as-of-certifiedAt) invariant rules from git
  history.` and line 299 emits `invariant $rid rule edited after certifiedAt=`
  (both CONFIRMED). Three qualifications matter before it is treated as a
  foundation. It is declared `ADVISORY ONLY` at line 207 and never changes the
  exit code. It is a strict no-op unless the repository declares a `domainModel:`
  block and at least one scenario carries `invariantRefs`. It compares the
  domain-model source file, not `spec.md`, `design.md`, or `scopes.md`. It is
  therefore a precedent that content-level comparison is tractable inside this
  script, delivered by IMP-106 SCOPE-3 (DOM-LINEAGE). It is not a partial
  implementation of content comparison over planning files.

- **EV-14 — the sole escape is an unvalidated boolean.** Lines 406-410 short
  circuit to `exit 0` whenever `requiresRevalidation == "true"`, regardless of how
  many post-certification edits were found. Nothing validates that a revalidation
  is genuinely pending or will ever occur. The framework already ships an
  unconditional pass-flag on this gate, which is the relevant precedent when
  judging any newly proposed exemption channel.

- **EV-14 — the remediation menu has no proportionate option at portfolio scale.**
  Line 420 offers exactly three responses: demote status out of `done`, set
  `requiresRevalidation: true`, or recertify through a current
  `bubbles.spec-review` and advance `certifiedAt`. Demoting dozens of specs whose
  work is genuinely complete is dishonest. Recertifying dozens of specs against
  redactions nobody disputes is large make-work. Setting the boolean is the
  unvalidated bypass above. The practical fourth option, carrying the failure, is
  the one that is actually taken, and it is the one the framework never records.

- **EV-14 — the gate penalizes reconciling a spec to its own truth.** Downstream
  evidence below includes a post-certification edit whose subject is `docs(092):
  SR-09 reconcile spec header Status to done (matches state.json)`. An agent
  repairing a stale status banner so that `spec.md` agreed with `state.json`
  thereby created a G088 finding. Stated precisely: the guard reports three
  post-certification edits on that spec, so this commit is one of its causes and
  not the sole cause.

### Downstream evidence (measured in the `smackerel` consumer, not in this repository)

The following numbers were measured in the `smackerel` Bubbles consumer at HEAD
`57bcb187` on 2026-08-18. They are reported here as downstream evidence and were
not reproduced in this framework repository. This repository holds no persistent
`specs/` execution packets (Gate G085), so the population does not exist here to
re-measure.

Running `post-cert-spec-edit-guard.sh` over every spec whose
`state.json.status == "done"`:

| Measure | Value |
|---|---|
| Certified specs evaluated | 99 |
| PASS | 59 |
| FAIL | 40 |
| Certified portfolio in G088 violation | 40% |

Grouping the reported `subject=` lines across all certified specs yields 90
post-certification file-touches:

| Count | Commit subject | Class |
|---|---|---|
| 60 | `refactor(deploy): enforce generic self-hosted boundary` | redaction |
| 12 | `docs(specs): portfolio evidence + state.json sweep` | reconciliation |
| 7 | `chore(genericize): remove machine-local and deployment-specific values` | redaction |
| 2 | `fix(ml): BUG-067-001 ML_LOG_LEVEL fail-loud SST + portfolio reconciliation` | mixed |
| 2 | `feat(056): User-Context OAuth 2.0 PKCE auth + quality sweep + reconcile` | mixed |
| 2 | `docs(specs): reconcile stale spec annotations to committed reality` | reconciliation |
| 2 | `docs(review): address MVP/deploy/ops readiness-review findings (reconcile to truth)` | reconciliation |
| 1 | `wip(smackerel): spec-092 card-rewards UI + chaos-saga saga test + mobile client lock/tooling refresh` | mixed |
| 1 | `docs(specs): land remaining spec evidence + BUG-042-007 (env-host refs redacted to placeholders)` | redaction |
| 1 | `docs(092): SR-09 reconcile spec header Status to done (matches state.json)` | reconciliation |

68 of 90 touches, 76%, are pure redaction: the 60 `refactor(deploy)`, the 7
`chore(genericize)`, and the 1 explicitly-redacted commit. None of the 68 changes
a requirement, a scenario, or an acceptance criterion. The remaining 22, 24%, are
reconciliation sweeps and mixed commits, which a redaction-only remedy would not
clear.

## Proposal

Three scopes. SCOPE-1 deliberately does **not** select a remedy. It records four
candidate mechanisms with their tradeoffs and leaves the choice to the owner,
because each one trades a different amount of implementation cost against a
different amount of residual bypass risk, and that tradeoff is an owner call.
SCOPE-2 states the constraint that binds whichever mechanism is chosen. SCOPE-3
settles the debt that already exists, and is landable independently of the other
two.

### SCOPE-1 — Decide how G088 discriminates a mechanical redaction from planning drift (EV-13)

No recommendation is made here. The four candidates below are presented with
their costs, their residual risk, and the share of the measured 90 touches each
would clear. The owner selects one, or a composition, before any implementation
begins.

**Option A — content-semantic diff.** Compare normalized planning *content*
(requirements, scenarios, acceptance criteria, invariant rules) between the
certified revision and the current revision, rather than comparing file paths. A
hostname or username substitution changes no normalized content and produces no
finding.

- Clears: all 90 touches, including the 24% reconciliation class, because a
  reconciliation sweep that changes no requirement is likewise not drift.
- Cost: highest. Requires a normalization model for planning prose and a
  defensible definition of what content is load-bearing.
- Residual risk: a normalization bug silently suppresses a real requirements
  change. This is the failure mode that most deserves adversarial tests.
- Prior art in this script: the invariant-rule comparison at lines 207-303 proves
  that reading a certified revision from git and comparing structured content
  against the working tree is tractable here. Note its qualifications recorded
  above: it is advisory, opt-in, and reads the domain model rather than a
  planning file. It is a starting point, not a partial implementation.

**Option B — declared redaction-class commits.** Recognize an explicit commit
trailer or conventional-commit type, for example `chore(genericize)` or a
`Redaction-Only: true` trailer, as a non-drift class.

- Clears: 68 of 90 touches, 76%, if the redaction commits carry the marker.
- Cost: low.
- Residual risk: **high, and disqualifying unless mechanically validated.** An
  unvalidated trailer is a self-asserted exemption from a blocking gate. The
  framework forbids exactly this shape elsewhere, and this gate already carries
  one such escape in `requiresRevalidation` at lines 406-410, so adding a second
  unvalidated channel would compound a known weakness rather than resolve one.
  Option B is only viable in the form described in SCOPE-2, where the guard
  asserts against the diff that the commit does only what its marker claims.

**Option C — placeholder-aware diff filter.** Ignore a hunk whose only change
replaces a concrete value with a placeholder token.

- Clears: the redaction class only, up to 68 of 90 touches, and only for hunks
  that are purely substitutions. A redaction commit that also rewraps a paragraph
  would still be flagged.
- Cost: moderate. Requires the guard to read hunks for the first time, which is a
  real change to lines 370-380, though a smaller one than Option A.
- Residual risk: low. The filter is narrow and its judgment is mechanical.
- Limitation: it does nothing for the 24% reconciliation class, so it does not on
  its own make the gate's output actionable at the measured scale.

**Option D — keep G088 strict and record the carry.** Change no detection logic.
Add a first-class, auditable record so that carrying a G088 finding is a
deliberate, attributable decision with an owner and a date rather than silence.

- Clears: nothing. The findings remain.
- Cost: lowest.
- Value: it converts an invisible erosion into a visible ledger, which is
  honest, and which makes the size of the problem legible for a later decision.
- Limitation: it accepts a permanently red gate. If the ledger becomes routine,
  the authority erosion this proposal is about continues, just with a paper trail.

### SCOPE-2 — Bind any exemption channel to mechanical validation (EV-14)

Whichever mechanism SCOPE-1 selects, one constraint holds. An exemption from a
blocking gate must be *validated*, never *trusted*.

- If Option B is selected, the marker alone must not clear the finding. The guard
  must read the diff for the marked commit and assert that every changed hunk is a
  concrete-value-to-placeholder substitution. A marked commit containing any other
  change is a finding, and the marker's presence becomes an aggravating fact
  rather than a mitigating one.
- The same constraint applies to any new field, trailer, or flag introduced by
  Options A, C, or D.
- Record the existing `requiresRevalidation` short circuit at lines 406-410 as the
  precedent being consciously not repeated. Whether that existing escape should
  itself gain validation is a separate question this proposal raises but does not
  decide.

### SCOPE-3 — Settle the existing carried debt honestly (EV-14)

Independently of SCOPE-1, the measured downstream state is 40 specs whose
findings are being carried with no record. Give that carry a shape.

- Provide a means for a consumer to record, per spec, that a G088 finding is
  carried, with the reason class, the deciding owner, and the date.
- Report the carried total. A count that is visible can be argued about; a count
  that is invisible becomes the norm, which is the mechanism this proposal exists
  to interrupt.
- This scope is deliberately compatible with all four SCOPE-1 options. Under
  Options A, B, or C the ledger should shrink toward zero as the mechanism clears
  the redaction class. Under Option D the ledger is the deliverable.

## Migration / rollout

- SCOPE-1 is a decision, not code. Nothing lands until the owner selects an
  option. This proposal must remain `PROPOSED` until then.
- SCOPE-3 is additive, consumer-side, and independent. It can land before SCOPE-1
  is decided, and doing so would make the decision better informed by producing a
  measured carry count across more than one consumer.
- SCOPE-2 lands with, and only with, whichever mechanism SCOPE-1 selects. It has
  no standalone deliverable.
- Any change to detection is a behavior change to a blocking gate that is invoked
  as state-transition-guard Check 30. Sequence it so the hermetic selftest
  `bubbles/scripts/post-cert-spec-edit-guard-selftest.sh` and the persistent
  regression `tests/regression/test_11_post_cert_spec_edit.sh` are extended in the
  same change, never after it.
- Existing certified specs must not be retroactively re-flagged by a detection
  change. A mechanism that newly reports findings on specs that pass today is a
  regression, not an improvement, and must be caught before it lands.

## Risks & mitigations

- **R1 A normalization or filter bug silently suppresses a real requirements
  change.** This is the worst outcome, because it converts a noisy gate into a
  quiet one that is wrong. → Require adversarial coverage as an entry condition
  for Options A and C: a test that mutates a requirement, a scenario, and an
  acceptance criterion, and asserts the guard still fails. A mechanism without
  such coverage must not land.
- **R2 A declared-redaction marker becomes an unvalidated bypass.** → SCOPE-2
  makes mechanical diff validation a precondition of Option B rather than a
  follow-up. State plainly in the implementation that a marker the guard does not
  verify is indistinguishable from `--skip`, which this framework does not ship.
- **R3 The carry ledger of SCOPE-3 normalizes carrying.** A record that is easy to
  write and never reviewed is a worse outcome than the current silence, because it
  launders the erosion. → Give each carry entry a reason class and require the
  aggregate to be surfaced, so that a growing ledger is itself a finding.
- **R4 The measurement is from a single consumer.** 40 of 99 is one repository's
  ratio and may not generalize. → Treat the numbers as evidence that the conflict
  is real and material in at least one conformant consumer, which is sufficient to
  justify a decision. Do not treat the ratio as a framework-wide constant. SCOPE-3
  produces the multi-consumer number if one is wanted.
- **R5 Scope creep into the 24% reconciliation class.** Options B and C do not
  address it, and pretending otherwise would leave the gate still failing after
  the work is declared done. → Whichever option is chosen, state its expected
  residual failure count up front and verify it against a real consumer before
  the scope is closed.
- **R6 The guard grows a second responsibility and becomes hard to reason about.**
  It already carries an advisory domain-lineage path alongside its blocking path.
  → Keep the blocking path and any advisory path structurally separate, and keep
  the advisory path's inability to change the exit code intact.

## Acceptance criteria (when implemented)

- The owner has recorded a SCOPE-1 selection, with the rejected options and the
  reason each was rejected, so the decision survives the session that made it.
- For the selected mechanism, a redaction commit that replaces a concrete
  hostname, IP address, username, or tailnet identifier with a placeholder token
  in a certified `spec.md` produces no G088 finding.
- A commit that changes a requirement, a scenario, or an acceptance criterion in a
  certified `spec.md` still produces a G088 finding. This is asserted by a test
  that fails if the discrimination is inverted.
- If Option B was selected, a commit carrying the redaction marker whose diff
  contains a non-substitution change produces a G088 finding. The marker alone
  never clears the gate.
- Re-running the guard across a real consumer's certified portfolio yields a
  failure count consistent with the residual predicted for the selected option,
  and the difference is explained rather than absorbed.
- No spec that passes G088 before the change fails it after.
- The hermetic selftest and the persistent regression both cover the new behavior
  and pass under `bubbles/scripts/framework-validate.sh`.
- If SCOPE-3 landed, a carried G088 finding is attributable to a named owner, a
  reason class, and a date, and the aggregate carried count is reportable.

## Files to touch (on approval)

`bubbles/scripts/post-cert-spec-edit-guard.sh` (detection logic at lines 347-356
and 370-380, plus any exemption validation; owning gate: **G088
post_certification_spec_edit_gate**), `bubbles/registry/gates.yaml` (the G088
description at lines 619-626 and the enforcement map entry at line 1138, which
must continue to name every enforcing script; owning gate: **G088**),
`bubbles/scripts/post-cert-spec-edit-guard-selftest.sh` (hermetic coverage of the
new discrimination and of R1's adversarial cases; owning gate: **G088**),
`tests/regression/test_11_post_cert_spec_edit.sh` (persistent regression; owning
gate: **G088**), and — only if SCOPE-3 is approved — a consumer-side carry record
whose location and schema are decided with the SCOPE-1 selection. Recertification
remains the authority of the **`bubbles.spec-review`** agent, which the guard
already names at lines 320 and 420; no change to that agent is proposed.
`bubbles/workflows.yaml` is **not** touched: G088's registration at line 534 is
correct and this proposal changes the gate's discrimination, not its wiring.
