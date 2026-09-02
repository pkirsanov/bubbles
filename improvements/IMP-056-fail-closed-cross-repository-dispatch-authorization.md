# IMP-056 — Fail-Closed Cross-Repository Dispatch Authorization

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** A source audit of the cross-repository dispatch path found that the framework can classify ownership and repository routing without mechanically proving that a mutable callback is authorized. The audit compared the resolver, G134 guard, receipt producer, result-envelope schema, repository-binding authority path, four mutable orchestrator definitions, and their focused selftests. This proposal records the remedy only; it makes no framework change.
**Verified gaps addressed:** GF-16 — resolver success is not mutation authorization; GF-17 — repository ownership is conflated with dispatch authority; HO-7 — mutable runners lack one mandatory authorization gateway; EV-17 — dispatch receipts are optional evidence; COV-22 — production callback suppression is not adversarially tested

## Problem (verified against source)

- **GF-16 — resolver success is not mutation authorization:** `bubbles/scripts/work-boundary-resolve.sh` returns exit 0 after printing any normal disposition, including routing and refusal dispositions. A consumer that checks only process success can therefore continue after a result other than exact `in-boundary`.
- **GF-17 — repository ownership is not mutation authority:** `bubbles/scripts/repository-binding.sh` validates the actionable repository packet and treats external host control as authoritative over the local session mirror. That establishes which repository is actionable. It does not authorize a particular mutable dispatch, and a routed owner match must not be treated as that authorization.
- **HO-7 — no canonical mutable-dispatch gateway:** `agents/bubbles.goal.agent.md`, `agents/bubbles.workflow.agent.md`, `agents/bubbles.sprint.agent.md`, and `agents/bubbles.iterate.agent.md` describe dispatch behavior, but the audited definitions do not directly invoke `goal-fidelity-guard.sh` or `goal-boundary-receipt.sh` at one shared callback seam. Enforcement is therefore distributed across prose and caller discipline rather than one fail-closed mechanism.
- **EV-17 — receipt proof is optional:** `bubbles/scripts/goal-boundary-receipt.sh emit` mints a receipt only after the guard succeeds, and `verify` rejects edited, stale, substituted, or wrong-boundary receipts. However, `boundaryReceiptDigest` remains an optional property in `bubbles/schemas/result-envelope.schema.json`; no mutable-dispatch condition requires the receipt to be present and verified before callback invocation.
- **COV-22 — mechanics are tested, callback suppression is not:** focused selftests cover resolver dispositions, exact G134 refusal, mint-on-success behavior, and adversarial receipt verification. The audited coverage does not execute a production-shaped mutation callback and prove that every non-`in-boundary`, missing-authority, missing-receipt, malformed-receipt, stale-receipt, and substituted-receipt case suppresses that callback.

**Sanitized incident reproduction:** Current-session execution against a boundary declaring one downstream repository and `crossRepoPolicy: forbidden` emitted `disposition=refuse-cross-repo`, `repoMatch=false`, and a reason that another repository must not be touched unless authorized, while the resolver exited 0.

## Proposal

### SCOPE-1 — Canonical fail-closed dispatch gateway (GF-16)

- Add one shared gateway for every mutable specialist dispatch. The gateway must capture and parse the resolver output, require exactly one recognized disposition, and authorize continuation only when that value is exactly `in-boundary`.
- Treat a missing, duplicate, malformed, unknown, routed, or refused disposition as denial. Resolver exit 0 remains a successful classification result and must never be interpreted as authorization.
- Accept the mutation as a callback or command vector. Invoke it only after every authorization stage succeeds. The gateway must return before callback construction or execution on denial where practical, so denied inputs cannot create partial mutation state.
- Emit a closed, machine-readable denial reason that preserves the resolver disposition without converting routing advice into permission.

### SCOPE-2 — Separate repository authority from routing and mutation authority (GF-17)

- Require the gateway to validate the current actionable repository packet through the repository-binding contract before evaluating the candidate dispatch.
- Consume the host-authoritative `repositoryResolution`, session identity, control file, and expected control revision. A stale control revision must force a fresh host observation; a repo-local mirror, current working directory, active editor, workspace order, or target owner name must never substitute for authority.
- Keep three decisions explicit and independent: repository authority answers which repository this session may act on; work-boundary resolution answers whether work is inline, routed, or refused; receipt verification answers whether this exact dispatch crossed the current pre-dispatch boundary.
- A cross-repository owner match may produce a route packet, but it cannot invoke the mutation callback. The destination session must establish its own host authority and mint its own receipt.

### SCOPE-3 — Route mutable orchestrators through the gateway (HO-7)

- Make the shared gateway the only supported callback seam for mutable dispatches initiated by `bubbles.goal`, `bubbles.workflow`, `bubbles.sprint`, and `bubbles.iterate`.
- Keep read-only analysis and route-packet composition outside the mutation path, but require the gateway whenever a dispatched agent can write code, tests, specs, state, reports, deployment assets, or other repository artifacts.
- Replace prose-only pre-dispatch obligations with direct invocation at the point immediately before the callback. Do not duplicate parser, authority, or receipt logic in each orchestrator.
- Preserve the one-level VS Code dispatch model. This proposal does not add nested delegation; it constrains the existing top-level runner-to-specialist edge.

### SCOPE-4 — Bind mutable dispatch envelopes to verified receipts (EV-17)

- Extend the result-envelope contract with a typed mutable-dispatch authorization record containing the verified receipt digest, boundary name, authoritative repository identity, goal reference, and gateway decision.
- Require that record for an envelope that claims a mutable specialist was dispatched or that mutation work was completed. Keep it optional for genuinely read-only, advisory, blocked-before-dispatch, and route-only outcomes so existing non-mutable envelopes remain valid.
- Verify the receipt file through `goal-boundary-receipt.sh verify` immediately before callback invocation and compare its digest to the envelope record. A digest string alone is not authorization.
- Refuse absent, stale, edited, substituted, wrong-goal, wrong-repository, wrong-boundary, or digest-mismatched proof. Do not mint, repair, or infer proof after the callback has run.

### SCOPE-5 — Prove callback suppression and caller coverage (COV-22)

- Add an adversarial gateway selftest with a sentinel mutation callback. Assert that the sentinel runs once for a valid exact-`in-boundary` case and never runs for every denial class.
- Cover at least: resolver nonzero; exit 0 plus each routed/refused disposition; missing or duplicate disposition; missing or stale repository authority; missing receipt; failed guard with no receipt; edited receipt; stale receipt; wrong boundary; substituted repository or goal; digest mismatch; and callback failure propagation.
- Add caller-coverage checks that fail when any mutable dispatch in the four orchestrators bypasses the canonical gateway or reimplements its decision logic.
- Mutation-prove the suite by deliberately weakening the exact-disposition check and the callback-suppression check. At least one adversarial assertion must fail for each mutation.

## Migration / rollout

1. Land the gateway and adversarial selftest without switching production callers. Run it in observational mode against existing dispatch decisions, recording only disposition, authority status, receipt status, and the decision that hard enforcement would have taken. It must not execute a second callback.
2. Classify observational differences. Repair callers that lack enough data to establish authority or mint a receipt; do not introduce permissive defaults, inferred repositories, or grandfathered mutable bypasses.
3. Add the conditional envelope schema and producer/consumer support while keeping old read-only and route-only envelopes valid. A mutable envelope without proof remains observationally reported during this stage.
4. Move the four orchestrators to the shared gateway one at a time. Require a clean observational window and the caller-coverage selftest before enabling hard enforcement for the next runner.
5. Enable fail-closed enforcement for all mutable dispatches. Remove the observational compatibility branch in the same approved delivery scope so shadow behavior cannot become a permanent second authorization path.

## Risks & mitigations

- **R1 — existing mutable callers lack receipt inputs and are abruptly blocked** → use a bounded observational rollout, report every missing input by caller, and harden one orchestrator at a time. Do not weaken the final rule or treat unknown as allowed.
- **R2 — authority and receipt checks are duplicated and drift** → keep parsing, host-authority validation, receipt verification, and callback invocation in one gateway; enforce caller coverage mechanically.
- **R3 — a valid receipt is replayed after the goal, control revision, repository, or boundary changes** → verify immediately before dispatch against current authoritative state and bind all identities into the authorization record.
- **R4 — schema hardening breaks read-only or route-only envelopes** → condition the requirement on a closed mutable-dispatch claim rather than making the receipt globally required.
- **R5 — observational mode accidentally performs work twice or becomes a bypass** → observational mode computes and records only the decision, never invokes a callback, has a removal criterion, and cannot authorize a mutation.

## Acceptance criteria (when implemented)

- [ ] A mutable callback executes only after current repository authority validates, the resolver emits exactly `in-boundary`, and the matching G134 receipt verifies immediately before invocation.
- [ ] Exit 0 with `route-same-repo`, `route-cross-repo`, or `refuse-cross-repo` suppresses the callback and produces the corresponding machine-readable denial or route result.
- [ ] Ownership, repository routing, and workspace membership cannot satisfy or bypass mutation authorization.
- [ ] A cross-repository route never reuses the source session's authority or receipt; the destination session establishes both independently.
- [ ] Mutable-dispatch result envelopes require a typed verified authorization record, while read-only, advisory, blocked-before-dispatch, and route-only envelopes remain backward compatible.
- [ ] Missing, malformed, duplicate, stale, edited, substituted, wrong-boundary, wrong-goal, wrong-repository, and digest-mismatched evidence all suppress the callback.
- [ ] All mutable dispatch seams in the four orchestrators are mechanically shown to invoke the canonical gateway, with no duplicate authorization implementation.
- [ ] The adversarial suite proves one valid callback execution, denial-side zero execution, callback error propagation, and mutation sensitivity of both exact-disposition and suppression checks.
- [ ] The observational rollout reports caller incompatibilities without invoking callbacks or changing authorization outcomes, and its compatibility branch is removed when hard enforcement lands.
- [ ] G125 remains satisfied: this proposal stays `PROPOSED` until owner approval and no framework mutation lands as part of authoring it.

## Files to touch (on approval)

| Surface | Proposed file(s) | Change | Owning agent / gate |
|---|---|---|---|
| Canonical authorization gateway | `bubbles/scripts/cross-repository-dispatch-authorize.sh` | Add authority validation, exact-disposition parsing, receipt verification, and callback suppression | `bubbles.implement`; G134 goal-fidelity enforcement |
| Gateway verification | `bubbles/scripts/cross-repository-dispatch-authorize-selftest.sh` | Add adversarial callback and mutation-sensitivity coverage | `bubbles.test`; proposed COV-22 coverage obligation |
| Receipt producer/verifier | `bubbles/scripts/goal-boundary-receipt.sh` | Expose only the bindings required by the gateway without creating a second authorization path | `bubbles.implement`; G134 |
| Repository authority | `bubbles/scripts/repository-binding.sh` and its focused selftest | Provide a stable gateway-consumable authority verdict and stale-revision refusal | `bubbles.implement`; repository-binding preflight contract |
| Envelope contract | `bubbles/schemas/result-envelope.schema.json` and schema selftests | Add the conditional mutable-dispatch authorization record | `bubbles.design` for contract, `bubbles.test` for schema coverage |
| Mutable orchestrators | `agents/bubbles.goal.agent.md`, `agents/bubbles.workflow.agent.md`, `agents/bubbles.sprint.agent.md`, `agents/bubbles.iterate.agent.md` | Route each mutable callback through the canonical gateway | Each named runner for its definition; `bubbles.validate` for cross-runner parity |
| Gate and release wiring | `bubbles/registry/gates.yaml`, the generated gate catalogs, framework validation wiring, and `bubbles/release-manifest.json` | Register the new enforcement/coverage surfaces and ship them downstream | `bubbles.validate`; registry and release-manifest gates |

The file list is an approval-time implementation map, not authorization to edit those surfaces. The implementation owner must re-read current source and run the repository's normal ownership and transition checks before landing any scope.

## Provenance

This proposal derives from direct source inspection in the repository-authorized session on 2026-09-02. The inspected evidence set was:

- `bubbles/scripts/work-boundary-resolve.sh` and its focused selftest for the closed disposition set and exit semantics.
- `bubbles/scripts/goal-fidelity-guard.sh`, especially `check_pre_dispatch()`, for exact `in-boundary` acceptance.
- `bubbles/scripts/goal-boundary-receipt.sh` and its focused selftest for mint-on-success and stale, edited, substituted, and wrong-boundary refusal.
- `bubbles/scripts/repository-binding.sh` for host-authoritative repository resolution and session-mirror handling.
- `bubbles/schemas/result-envelope.schema.json` for the optional `boundaryReceiptDigest` property and absence of a mutable-dispatch receipt condition.
- `agents/bubbles.goal.agent.md`, `agents/bubbles.workflow.agent.md`, `agents/bubbles.sprint.agent.md`, and `agents/bubbles.iterate.agent.md` for current mutable runner dispatch definitions.
- Focused searches for direct pre-dispatch guard invocation, canonical mutation callbacks, callback-suppression tests, and the proposed gap codes. The searches found no existing canonical gateway, no direct invocation in the four audited runner definitions, no production-shaped suppression test, and no prior use of `GF-16`, `GF-17`, `HO-7`, `EV-17`, or `COV-22`.

The evidence establishes a framework integration and coverage gap. It does not claim that an unauthorized mutation has occurred in production, that every possible caller was audited, or that the proposed API names are already accepted.

## Non-goals

- Implementing any gateway, schema, guard, runner, registry, test, or release-manifest change in this proposal session.
- Replacing repository binding, G134, the work-boundary resolver, or boundary receipts with a new parallel authority system.
- Converting repository ownership, route destination, workspace membership, process exit 0, or an unverified digest into authorization.
- Adding nested subagent dispatch or changing the VS Code one-level dispatch constraint.
- Allowing cross-repository mutation from the source session after a route decision.
- Making receipts globally mandatory for read-only analysis, route-only packets, or outcomes blocked before dispatch.
- Preserving observational mode as a permanent bypass or second execution path.
- Fixing VS Code Chronicle's first-workspace-root session attribution. This proposal cannot fix that attribution. Chronicle attribution remains advisory and must never be treated as repository authority or edit provenance.
