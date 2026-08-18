# Bug: BUG-035 Validation Control-Plane Churn And Scope Overreach

- **Filed:** 2026-08-18
- **Severity:** high
- **Disposition:** open framework defect
- **Registry update:** intentionally excluded by operator instruction
- **Affects:** session lifecycle, evidence reuse, certification state,
  work-boundary routing, risk resolution, and source bug filing

## Summary

Bubbles catches material defects, but its control plane adds avoidable work
after the required assurance is available. Active delivery sessions require
manual continuation, replay accepted proof, reconcile duplicated state, and
expand narrow work into unrelated global remediation.

The validation substance is not the defect. The defect is how Bubbles
schedules, records, repeats, and certifies that validation.

## Packet Route

This defect changes shared behavior and artifact contracts across downstream
repositories. It does not qualify for the compact packet.

The source bug registry declares `BUGS.md` as the only source-repository filing
form. The source repository also contains two root bug packets under `bugs/`.
The operator explicitly prohibited a `BUGS.md` update and requested new files.
This packet follows the existing root-packet precedent and records the contract
contradiction as D7. It does not claim that contradiction is already resolved.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - valid delivery is delayed and narrow work can expand materially
- [ ] Medium - feature degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Current-session coordination sample captured
- [ ] Persistent framework reproduction added
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Observed Sample

A current-session query inspected ten top-level chats involved in active or
recent Bubbles-governed delivery. The sample contained 406 turns.

- 119 user turns were only `continue` or `try again`.
- Seven sessions required `/bubbles.handoff`.
- Four sessions exceeded 40 turns.
- The sessions recorded 413 write-tool interactions.
- Seven writes targeted direct Bubbles framework paths.
- The remaining writes targeted product code, tests, docs, or tracked packets.

Write counts do not measure wall-clock cost. They show that Bubbles surrounds
productive work rather than replacing it. The continuation and handoff counts
show that its coordination path is not converging efficiently.

## Defect Inventory

| ID | Defect | Observed effect | Required invariant |
| --- | --- | --- | --- |
| D1 | Ordinary delivery sessions have no effective bounded continuation lifecycle. | Users repeatedly issue `continue` or create handoffs to keep accepted work moving. | A bounded session rolls over automatically and resumes at the first unresolved occurrence. |
| D2 | Accepted test proof is not reusable across every execution and certification consumer. | Later phases replay passing leaves or restate the same evidence instead of consuming one receipt. | Frozen candidate, input, and environment identities allow one accepted receipt to satisfy every compatible consumer. |
| D3 | Lifecycle truth is duplicated across execution, scope status, top-level status, and validate-owned certification mirrors. | Packets can report completed execution while another mirror remains empty, stale, or `not_started`. Reconciliation requires another owner round trip. | One authoritative lifecycle fact projects compatibility fields atomically. A stale projection never makes the packet unresolvable. |
| D4 | Repository-wide findings can take over a narrower bounded task. | A documentation repair with no local security defect expanded into remediation of unrelated global security findings. | Out-of-boundary findings route to an owned packet. They block the parent only when a named shared release floor applies. |
| D5 | Risk-proportional validation is not applied uniformly to ordinary and ad hoc mutable work. | Low-risk documentation or metadata changes can enter the same broad chain used for security and deployment changes. | Every mutable run resolves risk before validation. Low-risk work uses focused proof plus one release aggregate. High-risk work keeps full assurance. |
| D6 | Bubbles has no durable assurance-closure outcome that stops equivalent validation on unchanged inputs. | Sessions continue through repeated validation, evidence reconciliation, and handoff after scenario and gate proof is already green. | Closure records the satisfied obligations and input digest. Another run requires an invalidation or a stated rerun reason. |
| D7 | The source bug-packet authority, executable lint, and source practice disagree. | The registry allows only a `BUGS.md` entry and omits `spec.md` from full packets. The lint requires `spec.md`. Two root source packets use an undeclared form. | One authority declares the source form and required files. The registry, lint, and repository agree. |
| D8 | Payload-closure recognition can return different verdicts or reject self-contained fixtures. | Full validation reported a self-only scheduler reference, while an immediate focused rerun passed unchanged. Full-reading recognition then exposed a generated `install.sh` fixture as an external dependency. | Recognition consumes full input, accepts self-only scheduling and same-script fixture materialization, and still refuses unguarded external dependencies. |
| D9 | The changed-only selftest clones branch `main` instead of the revision under validation. | Validation from a detached worktree cloned a stale primary branch, then failed to apply the current revision's diff. | The fixture starts from the exact source HEAD and establishes that revision as its upstream baseline. |
| D10 | Large-output assertions use quiet terminal greps in pipelines under `pipefail`. | Implementation-reality and system-only-PATH checks intermittently report a missing string that exists in captured output. | Assertions read the captured string directly and never depend on upstream pipe completion after a quiet match. |
| D11 | The guard performance check relies on wall time alone and cannot identify sustained host contention. | Aggregate runs took 51 seconds and then 30 seconds twice on an oversubscribed host, while unchanged focused runs took 12-23 seconds. | Each sample records wall and process-tree CPU time. A wall-only breach is contention; repeated wall-and-CPU breaches fail. |
| D12 | Core-tier pattern matching uses a quiet terminal grep under `pipefail`. | The unchanged production lint passed 95 times and failed 5 times, causing release readiness to report `shipped validator is clean` as failed. | Pattern matching consumes the complete scheduled-label string and returns one stable verdict. |
| D13 | Downstream install validation uses one fixed wall timeout and does not consistently bind execution to the installed repository root. | A healthy installed-tree validation exceeded 3,600 seconds under contention while still producing output, then emitted derivative missing-skip failures. Later, a downstream Check-9 fixture passed its target check but inherited source-CWD tail/custom gates and was reported failed. A nonzero child with no `Failed checks:` block could also be reported as an enumerated-known-defect pass. | Idle and absolute bounds distinguish silence from active progress; downstream commands execute from the installed root; guard config, ownership, convergence, and custom gates consume the guarded root; timeout diagnostics do not cascade; unexplained nonzero exits fail closed. |
| D14 | Evidence capture stores command output in an unnamespaced generic temp file and does not verify that it survived. | A full validation run lost `/tmp/tmp.*` while the child executed, then emitted evidence-shaped output with `lines: 0` and a blank `sha256`, obscuring the child verdict. | Capture output lives in a private namespaced directory; disappearance exits 2 with a concrete diagnostic and never emits an empty evidence hash. |

## Reproduction Steps

1. Query the active session store with the SQL recorded in `report.md`.
2. Confirm the continuation, handoff, and long-session counts.
3. Inspect a delivery handoff whose execution scope is complete while
   certification or scope mirrors remain incomplete.
4. Run a narrow task through a repository-wide gate and introduce an unrelated
   finding outside the task boundary.
5. Observe whether the finding routes without taking over the parent task.
6. Inspect `bubbles/registry/bug-packet.yaml` and the root `bugs/` directory.
7. Run artifact lint against a full packet with the registry's declared files.
8. Confirm that lint requires `spec.md`, which the registry does not list.
9. Run payload closure twice on unchanged bytes and compare the verdicts.
10. Run the changed-only selftest from a detached worktree whose `main` branch
  points at an older revision.
11. Repeat large-output contains assertions under `pipefail`.
12. Run the performance fixture under aggregate contention, compare wall and
  process-tree CPU time, then run it focused.
13. Run the production core-tier lint repeatedly on unchanged bytes.
14. Run downstream validation under a progress-aware idle and absolute bound,
  then inject silent, chatty, unexplained-nonzero, and hostile ambient-CWD
  adversaries.
15. Delete evidence capture output while its child runs and require a loud
  capture-integrity failure with no evidence block.

## Expected Behavior

Bubbles must preserve its security, deployment, live-system, adversarial, and
anti-fabrication checks. It must execute each required proof once per unchanged
input closure. It must derive certification state atomically, route unrelated
findings, and stop when the resolved assurance contract is satisfied.

## Actual Behavior

The framework obtains valuable proof, then spends additional turns replaying or
reconciling that proof. Narrow work can inherit global remediation. Session
progress depends on repeated user nudges and handoffs. Source bug filing also
uses an undeclared packet form.

## Root Cause

Bubbles models assurance as independently mutable phase, evidence, scope, and
certification records. Runtime resume is phase-granular, while proof identity is
not uniformly consumed below that boundary. Global gate failure and local work
ownership are also coupled too tightly. Risk resolution and session budgets do
not govern every mutable entry path.

## Impact

- High-quality delivery takes longer than its risk requires.
- Agents spend context on control-plane reconciliation.
- Operators must repeatedly prompt sessions to continue.
- Out-of-scope defects can displace the requested work.
- Redundant status fields can disagree without any product regression.
- Framework bug filing has no coherent standalone-file contract.
- Validation can fail because of scheduler parsing or stale branch selection.
- Release readiness can fail nondeterministically on output-pipeline timing or
  one contaminated wall-clock sample.
- Core-tier validation can falsely report dead patterns depending on pipeline
  buffering.
- Full downstream validation can be killed while making progress, then obscure
  the timeout with derivative missing-skip findings.

## Environment

- Repository: Bubbles source repository
- Platform: Linux under VS Code
- Sample date: 2026-08-18
- Sample size: ten top-level Bubbles-governed sessions

## Scope Boundary

### Included

- Session rollover and resume behavior
- Test-leaf and assurance receipt reuse
- Lifecycle and certification state projection
- Work-boundary finding disposition
- Risk-proportional validation selection
- Assurance closure and rerun invalidation
- Source bug-packet contract coherence

### Excluded

- Removing substantive security or deployment checks
- Weakening live-stack or adversarial proof
- Treating certification artifacts as non-productive work
- Implementing a fix in this filing change
- Editing `BUGS.md`
- Editing downstream repositories

## Related

- `improvements/INDEX.md` row `IMP-048` records delivered session review,
  dispatch receipts, leaf receipts, budgets, and state liveness.
- `bugs/BUG-032-planning-maturity-guard-false-positives/` records concrete gate
  overreach and lifecycle classification defects.
- `bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization/` records a
  concrete evidence-identity false positive.

## Deferred Reason

This change files and scopes the defect only. Implementation requires owner
planning across several shared framework surfaces. The packet remains
`in_progress` and makes no fixed or certified claim.