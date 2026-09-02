# IMP-057 — Native Host Budget Interception

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed. NO auto-mutation of bubbles/* until approved
**Motivation:** A follow-on audit of G128 and the applied IMP-055 runtime found that budget accounting is available after activity is observed, but the native host can still begin a measured resource-consuming dispatch without first presenting an IMP-055 permit. Reference routing covers only framework-mediated child commands. This proposal defines the missing host interception boundary and makes no framework change.
**Verified gaps addressed:** COST-13 — native controlled dispatches can begin without permit admission. HO-8 — native host interception has no declared capability contract. EV-18 — permit consumption is not bound to native dispatch evidence. COV-23 — native bypass and suppression are not comprehensively tested. REG-21 — enforce mode can be selected without proven host support.

## Problem (verified against source)

- **COST-13 — native controlled dispatches lack pre-dispatch admission:** G128 observes aggregate usage after execution and declares `preDispatchAdmission=false`. It can report that a cap was exceeded, but it cannot deny the next controlled dispatch before resources are consumed.
- **HO-8 — framework routing is not native interception:** `reference-broker.sh` can govern framework-routed child arguments. It does not intercept every model, tool, retry, continuation, or host-managed dispatch initiated through the native VS Code runtime.
- **EV-18 — native activity is not causally bound to a permit:** IMP-055 defines reservation, permit, settlement, retry, and epoch mechanics. The audited host path does not require a verified permit identifier before starting the corresponding controlled dispatch, so later usage evidence cannot prove that admission occurred first.
- **COV-23 — bypass suppression is unproven:** Existing budget tests exercise framework scripts and adapters. They do not enumerate every native controlled-dispatch family and prove that missing, stale, exhausted, replayed, wrong-epoch, or wrong-dispatch permits suppress host execution.
- **REG-21 — unsupported enforce mode can fail open:** The `none` dispatch adapter cannot enforce permits, and the current host hook registry does not declare comprehensive native controlled-dispatch interception. A configuration can therefore request enforcement without a mechanically verified interception capability.

## Proposal

### SCOPE-1 — Native controlled-dispatch taxonomy (HO-8)

- Define one closed registry of native controlled-dispatch families that require admission. Include root model requests, native subagent dispatches, web calls, browser calls, MCP or tool calls, and retries. Include any other configured resource-consuming dispatch family.
- Assign each family a stable dispatch identity and interception point. In enforce mode, deny unknown dispatch families rather than treating them as unmeasured or free.
- Keep action cost and reservation semantics in IMP-055. This scope names interception coverage only.

### SCOPE-2 — Host capability handshake (REG-21)

- Add a versioned host capability declaration that states which native controlled-dispatch families the host can intercept before execution.
- Discover host and API capabilities before activation. Require exact coverage of the active controlled-dispatch registry before permit enforcement can start.
- Missing, malformed, stale, partial, or unknown capability declarations must refuse enforce mode with an operator-actionable reason.
- Preserve observe-only operation when enforcement is not requested. Never report observe-only or post-hoc accounting as pre-action enforcement.
- Unsupported hosts must remain observe-only or off and cannot claim enforcement.

### SCOPE-3 — Permit admission before native execution (COST-13)

- Introduce one host-facing admission contract that accepts the dispatch identity, session epoch, reservation identity, and IMP-055 permit immediately before a native controlled dispatch starts.
- Verify the permit through the IMP-055 authority. Allow execution only after an exact, current, unconsumed permit is accepted for that dispatch and epoch.
- Deny missing, stale, expired, exhausted, replayed, substituted, wrong-dispatch, wrong-session, and wrong-epoch permits before provider or tool invocation.
- Keep IMP-056 authorization independent. A mutable dispatch must satisfy both mutation authorization and budget admission, and neither decision can satisfy the other.

### SCOPE-4 — Atomic consumption and settlement evidence (EV-18)

- Consume the accepted permit atomically with native dispatch start so concurrent callbacks cannot spend one permit twice.
- Emit a host receipt that binds permit, dispatch, epoch, attempt, start decision, completion outcome, and measured usage where the configured usage adapter supplies it.
- Route settlement and retry accounting back through IMP-055. Do not create a second budget ledger or infer usage when the adapter reports it as unavailable.
- Record denied actions without fabricating provider usage or settlement.

### SCOPE-5 — Comprehensive interception and bypass tests (COV-23)

- Build a host-contract test harness with a sentinel callback for every registered native controlled-dispatch family. Prove one execution for a valid permit and zero execution for every denial class.
- Cover root model requests, native subagent dispatches, web calls, browser calls, MCP or tool calls, retries, continuations, concurrent replay, dispatch substitution, epoch rollover, host restart, and capability downgrade.
- Cover unknown-family behavior. Unknown families must fail closed only in enforce mode.
- Add a coverage check that compares the controlled-dispatch registry with host interception declarations and test cases in both directions. New dispatch families must fail validation until interception and adversarial coverage exist.
- Mutation-prove callback suppression and registry completeness by weakening each check and observing a focused test failure.

### SCOPE-6 — Fail-closed activation and rollout (REG-21)

- Add an explicit `observe` to `enforce` activation transition guarded by the capability handshake, complete registry coverage, fresh epoch state, and passing interception tests.
- In enforce mode, loss or downgrade of host capability must stop new controlled dispatches. It must not silently fall back to G128 post-hoc reporting, the `none` dispatch adapter, prompt instructions, or framework-only routing.
- Keep G128 as aggregate post-hoc evidence and a defense-in-depth signal. Do not extend it into an admission mechanism it cannot implement.
- Publish one status surface that distinguishes unsupported, observe-only, enforcement-ready, enforcing, and fail-closed states without claiming cost savings that have not been measured.

## Migration / rollout

1. Land the controlled-dispatch registry, host capability schema, and contract tests without enabling enforcement.
2. Add host receipt production in observe-only mode and compare observed native actions with the declared registry. Observation must never mint or consume a permit after an action starts.
3. Connect permit verification, atomic consumption, and IMP-055 settlement behind an explicit activation setting. Keep the default posture unchanged until the host proves complete interception.
4. Run the adversarial coverage suite and a bounded observation window. Any unclassified controlled dispatch or missing interception point blocks activation.
5. Enable enforce mode only on a host version whose capability declaration exactly covers the registry. Capability loss after activation must fail closed for new controlled dispatches.

## Risks & mitigations

- **R1 — an unregistered native path bypasses admission** → use a closed controlled-dispatch registry, bidirectional host coverage checks, and unknown-family denial in enforce mode.
- **R2 — interception races consume one permit twice** → make permit acceptance and consumption atomic and test concurrent replay with a sentinel callback.
- **R3 — host capability drift blocks legitimate work** → expose an actionable capability mismatch report and retain explicit observe-only operation when enforcement is not requested.
- **R4 — budget admission is conflated with mutation authorization** → keep separate decisions, receipts, and failure reasons, and require both when a dispatch can mutate state.
- **R5 — post-hoc evidence is presented as causal savings** → require pre-action host receipts for enforcement claims and report savings as unmeasured until a usage adapter provides causal measurements.

## Acceptance criteria (when implemented)

- [ ] Every registered native controlled-dispatch family reaches one pre-execution admission contract before provider or tool invocation.
- [ ] The registry covers root model requests, native subagent dispatches, web calls, browser calls, MCP or tool calls, retries, and every other configured resource-consuming dispatch family.
- [ ] A valid current IMP-055 permit executes its exact dispatch once and produces a receipt bound to the dispatch, epoch, attempt, and settlement path.
- [ ] Missing, stale, expired, exhausted, replayed, substituted, wrong-dispatch, wrong-session, and wrong-epoch permits suppress the native callback.
- [ ] Enforce mode cannot activate unless host and API capability discovery proves exact coverage of the controlled-dispatch registry and the adversarial suite passes.
- [ ] Unsupported hosts remain observe-only or off and cannot claim enforcement.
- [ ] Capability loss or downgrade while enforcing stops new controlled dispatches and cannot fall back to post-hoc or prompt-only enforcement.
- [ ] Registry, host declarations, and tests are checked bidirectionally so a new controlled-dispatch family cannot ship without interception coverage.
- [ ] IMP-055 remains the sole budget reservation and settlement authority, IMP-056 remains the separate mutable-action authorization authority, and G128 remains post-hoc evidence only.
- [ ] Observe-only status never claims prevention, admission, or measured savings.
- [ ] G125 remains satisfied: this proposal stays `PROPOSED` until owner approval and no framework implementation changes land with it.

## Files to touch (on approval)

| Surface | Proposed file(s) | Change | Owning agent / gate |
|---|---|---|---|
| Native dispatch registry | proposed registry and schema | Define the closed controlled-dispatch vocabulary and interception requirements | `bubbles.design`, proposed REG-21 registry obligation |
| Host capability contract | `bubbles/schemas/native-host-budget-capability.schema.json` and host adapter contract | Declare versioned pre-execution interception coverage | `bubbles.design`, proposed HO-8 capability boundary |
| Permit admission | IMP-055 budget runtime scripts and the native host adapter | Verify and atomically consume permits before callback invocation | `bubbles.implement`, IMP-055 budget authority |
| Evidence and settlement | IMP-055 ledger and usage adapter surfaces | Bind host receipts to settlement without inferred usage | `bubbles.implement`, EV-18 evidence obligation |
| Adversarial coverage | focused native interception selftests and registry coverage lint | Prove callback suppression, concurrency safety, and bidirectional completeness | `bubbles.test`, proposed COV-23 coverage obligation |
| Activation and gate wiring | project config schema, `bubbles/registry/gates.yaml`, generated catalogs, validation wiring, and release manifest | Refuse unsupported enforcement and ship approved contracts | `bubbles.validate`, G125 plus proposed REG-21 gate |

The implementation owner must resolve exact file names against current source after approval. This map does not authorize changes outside the normal ownership and transition workflow.

## Provenance

This proposal derives from repository-authorized source inspection on 2026-09-02. The inspected evidence included G128 metadata and enforcement scripts, the applied IMP-055 design recovered from Git, IMP-056, `session-cap-guard.sh`, `reference-broker.sh`, the `none` dispatch adapter, the native hook registry, gate registration, workflow registration, and focused searches for native pre-execution permit interception.

The evidence establishes that current accounting is post-hoc or framework-routed and that comprehensive native interception is not declared or proven. It does not establish that every host implementation lacks private controls, that an unauthorized charge occurred, or that the proposed file names are already accepted.

## Non-goals

- Implementing host, adapter, permit, ledger, gate, registry, workflow, test, or release changes in this proposal session.
- Replacing or extending IMP-055 budget accounting with a second reservation or settlement authority.
- Replacing IMP-056 mutable-action authorization or treating a budget permit as mutation permission.
- Recasting G128 post-hoc aggregate evidence as pre-execution admission.
- Treating prompt instructions, framework-only routing, or provider-only wrapping as comprehensive native interception.
- Enabling enforcement on a host that cannot prove complete interception coverage.
- Estimating token use, credits, or savings when no configured usage adapter measured them.