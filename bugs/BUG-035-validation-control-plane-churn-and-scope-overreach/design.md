# BUG-035 Design - Validation Control-Plane Churn And Scope Overreach

## Root-Cause Analysis

### Investigation Summary

The session audit separated validation value from coordination cost. Product
checks found real defects. The surrounding workflow still required 119 manual
continuation or retry turns across 406 turns. Seven of ten sessions required a
handoff.

The write distribution showed that the sessions worked mainly on products.
The defect therefore sits in the control path around productive work, not in a
framework loop that replaced all product work.

### Root Cause

Four architectural choices compose into the observed churn.

1. Phase occurrence identity does not extend uniformly to every test leaf and
   certification consumer.
2. Lifecycle truth is stored in several independently owned fields.
3. A global gate failure remains coupled to the current task after ownership
   routing identifies a different work boundary.
4. Risk and session-budget resolution do not cover every mutable entry path.

The source bug filing contradiction has a separate root. The packet registry
declares only a single-file source form, while the source repository maintains
root packet directories outside that vocabulary. The executable artifact lint
also requires `spec.md`, which the registry omits from its full packet.

Two validation-runner defects have narrower roots. Payload closure uses quiet
terminal greps in filtered pipelines under `pipefail`, making early-reader
termination part of the verdict. The changed-only selftest forces `--branch
main`, so a detached revision is reconstructed against stale branch bytes.

The same quiet-pipeline defect exists in large-output assertion helpers. The
performance gate has a separate sampling defect: one wall-clock measurement on
a shared host cannot distinguish regression from transient CPU contention.
Core-tier pattern lint repeats the quiet-pipeline defect against the complete
scheduled-label inventory.

### Impact Analysis

- **Affected components:** phase coordination, validation closure, state
  transition, work-boundary routing, workflow mode resolution, session caps,
  and bug-packet governance.
- **Affected data:** execution receipts and version 3 lifecycle state.
- **Affected users:** every downstream repository that installs Bubbles.
- **Risk:** a broad relaxation could hide real regressions. Every fix must keep
  fail-loud behavior when proof inputs change or a shared release floor fails.

## Fix Design

### 1. Extend occurrence identity to assurance leaves

Complete the execution-receipt foundation defined by `IMP-048`. Give each test
leaf an identity derived from the candidate, declared inputs, environment, and
command contract. Store the exit code and output hash.

A compatible consumer must use `REUSED <receipt-id>`. It must not execute the
leaf again. A changed input invalidates only the covering receipts.

### 2. Add an assurance-closure record

After all resolved mode obligations pass, write one closure record containing:

- resolved workflow mode and risk tier
- candidate and input-closure digests
- required scenario and gate identifiers
- accepted receipt identifiers
- unresolved routed findings
- a closure outcome

The closed outcomes are `ASSURED`, `ROUTE_ONLY`, and `BLOCKED_RELEASE_FLOOR`.
Another validation run over the same closure must report `REUSED`. A rerun needs
an invalidation or a named reason.

### 3. Make certification one atomic projection

Keep validate ownership of certification. Stop treating compatibility mirrors
as independently writable facts. Validate writes one authoritative
certification transaction. A generator projects top-level compatibility fields
from that transaction.

During migration, a stale projection reports `STALE_PROJECTION`. It does not
make the underlying packet unresolvable. A projection repair must not rerun
product tests.

### 4. Separate finding ownership from release-floor impact

Classify every out-of-boundary finding as one of three outcomes:

- `ROUTE_ONLY` records an owned packet and lets the parent continue.
- `BLOCKED_RELEASE_FLOOR` blocks because the resolved mode names the failing
  shared floor.
- `IN_BOUNDARY` remains part of the current fix loop.

The diagnostic must name the mode rule or gate that established a shared floor.
Zero-deferral continues to require an owner packet. It no longer means every
finding takes over the current scope.

### 5. Resolve risk for every mutable entry path

Run the existing risk resolver before the first mutable action in direct,
continuation, ad hoc, and workflow-driven sessions. Low-risk work receives
focused checks and one aggregate release check. High-risk traits retain the
full chain.

The resolver must fail closed when risk cannot be determined.

### 6. Make rollover automatic

Use the bounded lifecycle from `IMP-048`. At the soft boundary, persist the
first unresolved occurrence and emit a continuation packet. The host starts the
continuation without requiring repeated `continue` prompts.

The rollover never marks product work blocked. It records that the session is
full, not that the work is defective.

### 7. Reconcile the source bug filing contract

Choose one source-repository contract and enforce it.

The preferred fix adds a declared `source-packet` form for root `bugs/`
directories. Gate G085 still forbids `specs/` in the source repository. The
registry must state whether `BUGS.md` is an index, a legacy form, or both. The
artifact lint must consume the registry's required file set instead of carrying
another answer.

The alternative is to remove root packets and retain only `BUGS.md`. That path
is not compatible with the operator's explicit standalone-file requirement.

### 8. Make payload-closure recognition full-reading

Replace terminal `grep -q` consumers in filtered pipelines with full-reading
matches redirected to `/dev/null`. Preserve single-file quiet checks. Add a
large self-only scheduler fixture and repeat it to pin verdict stability.

### 9. Baseline changed-only fixtures from source HEAD

Initialize the fixture repository from the exact source `HEAD`. Establish that
revision as the fixture's `origin/main` baseline before applying staged and
unstaged changes. Assert the baseline digest before scenario execution.

### 10. Remove quiet assertion pipelines

Use here-strings or direct file reads for captured-output contains assertions.
Keep positive and negative assertions. Do not suppress `pipefail` globally.

### 11. Confirm performance threshold failures with CPU time

Record Bash real, user, and system time for the frozen performance fixture. A
sample passes when either wall time or process-tree CPU stays below the existing
30-second budget: wall-only slowness is host contention, not guard work. Retry
once only when both signals breach. Fail when both wall and CPU breach on both
samples. The historical per-line fork storm performs real process work and
therefore remains above both budgets.

### 12. Make core-tier matching full-reading

Match each core needle against the in-memory scheduled-label string through a
here-string. Run the shipped validator lint 20 times in its selftest. Preserve
the renamed-check adversarial case.

### 13. Bound downstream validation by progress and absolute duration

Run the installed-tree validator through a shared progress-aware helper. Reset
the idle clock whenever its log grows, return 124 after a silent idle interval,
and return 125 at an absolute ceiling even when output continues. Do not run
skip-marker checks on a truncated log. When no known downstream failures exist,
any other nonzero child exit remains a failure even if no trailing `Failed
checks:` block was emitted.

Execute every downstream validation command from the installed repository root.
Within transition guard, resolve project config, ownership linters, convergence
health, and custom gate execution from `guard_repo_root`; ambient caller CWD is
never repository authority. Check-9 fixtures bind their fast path on each guard
invocation so an outer runner cannot re-enable unrelated tail gates.

### 14. Make evidence capture storage private and fail closed

Allocate a namespaced private directory for each capture and expose only its
output path to the child for testability. Preserve the caller's monitor-mode
state. Before counting or hashing, require the output file to still exist; if it
does not, exit 2 with a concrete capture-integrity diagnostic and emit no
evidence block. Pin this with an adversarial child that deletes its own capture
path.

## Alternatives Considered

1. **Remove gates.** Rejected. The reviewed gates found material defects.
2. **Treat every report and spec write as waste.** Rejected. Certification and
   documentation are delivery work when they prove a real outcome.
3. **Increase context limits.** Rejected. More context delays rollover but does
   not eliminate proof replay or state divergence.
4. **Let implementers write certification mirrors.** Rejected. That weakens
   independent certification and creates a self-certification path.
5. **Make every routed finding non-blocking.** Rejected. Security, deployment,
   money, and destructive data paths can establish a shared release floor.
6. **Keep the undeclared root packet convention.** Rejected. An undeclared
   artifact form is the contract drift the registry was created to prevent.

## Complexity Tracking

| Decision | Simpler fix considered | Why rejected |
| --- | --- | --- |
| Add closure records | Stop after one passing command | One command cannot represent scenario, risk, and release obligations. |
| Derive compatibility projections | Keep manual mirrors and add another reconcile script | Another writer preserves the duplicated-fact defect. |
| Add three finding outcomes | Route every out-of-scope finding without blocking | Some findings establish a real shared release floor. |
| Extend the packet registry | Continue the root-directory convention silently | Silent convention contradicts the registry's closed vocabulary. |

## Relationship To IMP-048

`IMP-048` delivered session review, dispatch receipts, test-leaf receipts,
budgets, and state liveness. Its durable record is `improvements/INDEX.md` row
`IMP-048`. BUG-035 does not duplicate those implementations. It adds
certification consumption rules, boundary outcomes, closure semantics, and
source-packet reconciliation that remain outside that delivered foundation.