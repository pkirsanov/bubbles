# Bug: BUG-054 Session Cap Charges Cross-Session History

- **Filed:** 2026-09-01
- **Severity:** high
- **Disposition:** open framework defect
- **Gate:** G128 `session_cap_enforcement_gate`
- **Affects:** session-budget measurement and its session-state producers

## Summary

Gate G128 measures repository-wide history instead of one active host session.
Historical and concurrent sessions can therefore consume a new session's caps.

## Canonical Identity Adjudication

The canonical identity for this packet is `BUG-054`. The earlier
`BUG-037-session-cap-cross-session-attribution` name was an untracked local
draft identity and was never canonical. Canonical `BUG-037` remains
`BUG-037-uservalidation-opt-out-acceptance` and is unchanged.

Historical command lines, captured output, receipt tags, and hashes emitted
before this adjudication retain the old draft label verbatim. Those immutable
records refer to this packet's pre-adjudication execution epoch. They do not
refer to canonical `BUG-037`.

A byte-identical retained copy now lives at
`bugs/_superseded-draft-037-session-cap-cross-session-attribution`. Its
underscore prefix keeps it outside the canonical `bugs/BUG-*` namespace. This
copy is a superseded draft archive. It is not a canonical bug or delivery
evidence.

The report preserves the dirty-worktree reconciliation and failed IDE deletion
probes as historical evidence. Those probes correctly describe their prior
worktree. They do not describe this clean checkpoint candidate.

A current-session bounded assertion on committed checkpoint
`851881e7b945c20d865b2894c60fde385851756c` found the old path physically
absent. The assertion also confirmed both retained packets contain exactly the
nine required regular files. Exactly one direct canonical `BUG-054` directory
exists, and the canonical bug IDs are unique.

`ID-DELETE-001` is closed for identity adjudication. The superseded archive
remains preserved outside the canonical namespace. This closure does not
verify Scope 4. Route Scope 4 to `bubbles.test` for isolated `TP-04-02`
execution. Scope 5 remains unstarted, and certification remains unchanged.

## Packet Route

This defect changes a shared blocking gate and several session-state contracts.
It therefore uses a full root bug packet under `bugs/`.

Gate G085 forbids a `specs/` directory in the Bubbles source repository. The
operator explicitly selected the existing root packet convention for this task.

## Severity

- [ ] Critical - system unusable or data loss
- [x] High - a healthy session can be stopped by unrelated session activity
- [ ] Medium - behavior degraded with a reliable workaround
- [ ] Low - minor or cosmetic issue

## Status

- [x] Reported
- [x] Controlling readers and producers confirmed by current-session source inspection
- [ ] Executable pre-fix regression captured
- [ ] Fixed
- [ ] Validate-certified
- [ ] Closed

## Confirmed Source Path

`bubbles/scripts/session-cap-guard.sh` currently performs five unscoped reads.

1. It sums every `convergenceLoops[].iterationCount` entry.
2. It computes wall time across every `turnSnapshots[].timestamp` entry.
3. It reads one repository-level `toolCallCount` scalar.
4. It aggregates every byte-bearing row in `tool-calls.jsonl`.
5. It invokes the usage adapter's `session` verb without a session identifier.

The producer contracts already contain part of the needed identity.

- `state-snapshot.sh` writes `turnSnapshots[].hostSessionId`.
- Its convergence entry has no `hostSessionId` and is keyed only by spec and agent.
- `tool-log.sh` writes `sessionId` on each row.
- `tool-log.sh` generates a process-derived ID when no host ID is supplied.
- The source tree has no writer for the repository-level `toolCallCount` scalar.
- The VS Code usage adapter accepts an optional filename-prefix filter.
- Current G128 production callers pass no active host-session identifier.

## Reproduction Steps

1. Stage one session store with records for `host-old` and `host-current`.
2. Give `host-old` convergence, elapsed time, and tool usage above every cap.
3. Give `host-current` usage below every cap.
4. Invoke G128 for `host-current`.
5. Observe the current implementation charge both sessions together.
6. Repeat with interleaved byte-bearing tool-log rows from both sessions.
7. Observe the largest and cumulative byte measurements include both sessions.

## Expected Behavior

G128 must measure only records attributed to the active host session. It must
receive that identity from an explicit host-supplied input.

Records attributed to another session must remain readable history. They must
not affect the active session's verdict.

Legacy records without exact session attribution must remain unmeasurable. The
guard must never assign them to the newest, oldest, or only visible session.

## Actual Behavior

The guard has no active-session input. It aggregates shared repository files as
if every retained record belonged to the invocation being checked.

## Root Cause

The session store became append-preserving and multi-session, but G128 retained
its original single-session reader model. Identity exists on turn snapshots and
tool-log rows, yet the guard ignores it. Convergence and tool-call counters do
not carry an equivalent exact-session identity.

## Impact

- An old long-running session can stop a newly opened session immediately.
- Concurrent sessions can consume each other's event and byte caps.
- One session's oversized tool result can block every other session in the repo.
- A legacy unattributed record can be misrepresented as current usage.
- Soft-boundary percentages can recommend rollover for the wrong session.
- Check 40 can block an unrelated feature transition.

## Hard Constraints

- Preserve every existing cap name and configured numeric value.
- Preserve the current comparison rule. Equality remains within the cap.
- Preserve default-off behavior when every cap is null.
- Preserve all historical records. Do not delete, truncate, or rewrite history.
- Do not assign legacy records to a session using time, process, CWD, or recency.
- Do not raise a cap or add a bypass.
- Do not edit installed downstream framework copies.

## Change Boundary

The expected source boundary includes the G128 guard, its focused selftest, its
persistent regression, and verified session-state producer contracts. It also
includes exact-session usage filtering and G128 production callers.

The release manifest must be regenerated after source changes. Documentation
must change only where it currently describes unscoped G128 aggregation.

The change must not alter G082's per-spec cap, repository binding authority,
workflow mode cap values, product state, or downstream installed files.

## Related

- `bugs/BUG-035-validation-control-plane-churn-and-scope-overreach/` covers the
  broader session lifecycle and validation convergence problem.
- `improvements/IMP-055-measured-budget-and-session-epoch-runtime.md` proposes
  broader pre-dispatch admission. This bug remains a bounded G128 correctness
  repair and does not depend on that proposal being adopted.

## Evidence Status

Current-session source inspection confirmed the unscoped reader path. No
regression test or production fix ran during this packet-creation phase.
