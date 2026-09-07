# User Validation - BUG-054 Session Cap Cross-Session Attribution

## Automation Readiness

- [ ] Old-session event history is excluded from current-session totals.
- [ ] Current-session event caps pass at cap and fail above cap.
- [ ] Single-result and cumulative bytes are isolated by exact session ID.
- [ ] Interleaved concurrent writers retain both sessions without lost updates.
- [ ] Legacy unattributed records remain unmeasurable and retained.
- [ ] Prompt-token dimensions require exact session identity.
- [ ] An active budget without one exact session ID returns `INPUT-ERROR` with exit 2.
- [ ] A default-off budget remains identity-free and makes no measurement claim.
- [ ] `maxToolCalls` remains unmeasurable because no exact production source exists.
- [ ] Check 40 and live framework validation distinguish `BREACH` from `INPUT-ERROR`.
- [ ] Normal and quiet diagnostics list all seven dimensions without host-private paths.
- [ ] Changed guard, producer, adapter, and focused test paths run under macOS Bash 3.
- [ ] All seven cap values and no-bypass behavior remain unchanged.
- [ ] Full framework validation and release readiness pass.

Automation readiness does not grant human acceptance.

## Checklist

- [ ] A newly opened session is not charged for historical session activity.
- [ ] Two concurrent sessions receive independent G128 totals and verdicts.
- [ ] An old oversized tool result cannot block a different current session.
- [ ] A current oversized result still blocks its owning session.
- [ ] Legacy records remain visible without being assigned to a new session.
- [ ] Exact-session token accounting never falls back to prefix aggregation.
- [ ] A missing exact ID under an active budget is reported as an input error, not a pass or cap breach.
- [ ] A default-off invocation does not request or infer a host identity.
- [ ] Tool-call count is labeled unmeasurable rather than zero, passed, or inferred from receipts.
- [ ] Required diagnostics expose record classification without exposing private filesystem paths.
- [ ] Check 40 and framework validation preserve the direct guard's exit meaning.
- [ ] Session history remains append-preserved.
- [ ] Configured cap values remain unchanged.

## Human Acceptance Record

Not recorded. A human must complete the checklist and add the acceptance record
before a terminal transition.

## Evidence

- Discovery evidence: [report.md](report.md#source-inspection-evidence)
- Scenario plan: [scopes.md](scopes.md#gherkin-scenarios)
