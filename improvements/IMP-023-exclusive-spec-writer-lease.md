# IMP-023 — Exclusive Spec/Artifact Writer Lease

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** Multi-session convergence observations (2026-07, Research Lab Feature 010) — overlapping `bubbles.implement` attempts and two concurrent `bubbles.test` replays ran against one dirty worktree. One owner restored files another owner had removed, validators changed after an independent replay, and `report.md` repeatedly appended "concurrent reconciliation" sections. No mechanism refused the second live writer.
**Verified gaps addressed:** no artifact-writer exclusivity (WL1), shared-state contract is documented but unenforced (WL2), no stale/crash takeover for artifact writers (WL3).

## Problem (verified against source)

- **WL1 — the existing lease covers runtime capacity, not spec artifacts.** `bubbles/scripts/runtime-leases.sh` (session-aware runtime coordination, resource-weighted admission, ownership/compatibility/exclusivity, documented in `docs/recipes/runtime-coordination.md` + `docs/issues/session-aware-runtime-coordination.md`) coordinates Docker/Compose host capacity. It does NOT arbitrate concurrent WRITERS of a spec's `state.json` / `report.md` / `spec.md` / owned source / owned tests in one worktree — exactly the Feature 010 collision. (WL1)
- **WL2 — the shared-state ownership rule is prose, not a lock.** IMP-004 SCOPE-2 documents the parent-owned shared-state contract for `parallelScopes=dag` (shared `state.json`/`spec.md`/`design.md`/`scenario-manifest.json` are orchestrator-owned; worktree scopes write only their own `scope.md`/`report.md` + code). It is a *documented* contract with no mechanical writer lease behind it, so two live writers in one worktree are not refused. (WL2)
- **WL3 — no takeover/recovery for a dead artifact writer.** The runtime lease has TTL/stale downgrade for capacity leases, but there is no equivalent acquire-before-mutate + heartbeat + stale-takeover path for spec-artifact writers, so a crashed writer would either block forever or be silently overwritten. (WL3)

## Proposal

**Extend the existing `runtime-leases.sh` with an artifact-writer lease class** — do NOT fork a second lease store, and do NOT duplicate the IMP-004 SCOPE-2 parent-owned shared-state contract (this MECHANIZES it).

### SCOPE-1 — artifact-writer lease identity + storage (WL1)

- Add an `artifact-writer` lease kind persisted under `.specify/runtime/` (the existing lease registry home), recording: repository root, target (spec/bug/ops dir), scope, session ID, agent, worktree/branch, owned path families, `acquiredAt`/`renewedAt`, TTL, and parent orchestrator. Reuse the existing lease record format + `format_lease_line`/`lookup`/`list` surface so one store shows both capacity and writer leases.

### SCOPE-2 — acquire-before-mutate + reader/writer semantics (WL1)

- Require an `artifact-writer` lease acquisition before the FIRST mutable tool call against a spec or its owned source/test paths. **Multiple readers are always allowed; exactly one writer per (target, worktree) is allowed.** A read-only lens (audit, review, status) never needs the lease.

### SCOPE-3 — mechanize the IMP-004 parent-owned shared-state contract (WL2)

- Parallel scopes may run ONLY in isolated git worktrees under the existing parent-owned shared-state contract. Child scopes MUST NOT write shared `state.json`, `scenario-manifest.json`, `spec.md`/`design.md`, or another scope's `report.md` — the writer lease refuses such a write with the parent named as owner. This scope makes IMP-004 SCOPE-2 enforceable rather than advisory.

### SCOPE-4 — heartbeat, release, stale takeover, crash recovery (WL3)

- Add heartbeat renewal, clean release on scope completion, stale detection (TTL, matching the capacity-lease downgrade), **explicit** takeover (audited, never silent), abandoned-worktree cleanup, and crash recovery. There is **no silent takeover and no bypass flag** (matches G082/G128).

### SCOPE-5 — structured early refusal (WL1)

- A conflict fails EARLY with a structured `route_required`/`blocked` result-envelope naming the current owner (session, agent, scope) and a safe remediation. The framework MUST NEVER "reconcile" two live writers by appending more evidence to `report.md` — that Feature 010 anti-pattern is explicitly forbidden.

### SCOPE-6 — integration points (WL1–WL3)

- Wire the lease into orchestrator dispatch, direct specialist invocation, handoff/continuation envelopes, state snapshots, and the pre-tool risk check. Define behavior for nested subagents (the parent holds the target lease; a child gets a scoped worktree lease) and multi-repo runs (lease keyed by repository root, so a cross-repo scenario holds one lease per repo).

### SCOPE-7 — IMP-004 amendment recommendation (governance)

- **Recommendation:** AMEND IMP-004 SCOPE-2 (rather than superseding it) to cross-reference this lease as its enforcement mechanism — IMP-004 keeps ownership of the *documented contract*; this IMP owns the *mechanism*. Per G125 this proposal does NOT edit IMP-004; the amendment is performed on approval alongside implementation.

## Migration / rollout (additive + default-preserving)

- The artifact-writer lease is **opt-in** and default-inactive: with no lease acquired (today's single-writer sessions), behavior is unchanged — the refusal only fires when a SECOND writer attempts a mutable call against a held target. Sequencing: SCOPE-1/2 (lease + acquire) → SCOPE-4 (heartbeat/takeover) → SCOPE-3/5 (shared-state enforcement + refusal) → SCOPE-6 (integration) → SCOPE-7 (IMP-004 amendment).

## Risks & mitigations

- **R1** a stale lease blocking a legitimate resume → TTL + explicit audited takeover (never silent); crash recovery path proven by selftest.
- **R2** lease overhead on normal single-writer runs → acquire is a no-op fast path when uncontended; readers never lease.
- **R3** forking a competing lease store → SCOPE-1 extends `runtime-leases.sh` in place; one registry, one format.

## Acceptance criteria (when implemented)

- Hermetic concurrency selftest proves: two writers on the same scope → second refused; reader + writer → allowed; isolated worktree scopes → allowed; a child write to shared `state.json`/scenario-manifest → refused with the parent named; a stale lease → audited takeover; a clean release → next owner acquires.
- The refusal is a structured `route_required`/`blocked` envelope; no "concurrent reconciliation" evidence-append path exists.
- `framework-validate.sh` passes; the extended lease + selftest are wired in; `docs/recipes/runtime-coordination.md` documents the artifact-writer kind.

## Files to touch (on approval)

`bubbles/scripts/runtime-leases.sh` + `runtime-lease-selftest.sh` (artifact-writer lease kind + concurrency selftest, wired into `framework-validate.sh`), `agents/bubbles_shared/workflow-execution-loops.md` + `scope-workflow.md` (acquire-before-mutate + parent-owned enforcement), `agents/bubbles_shared/*` orchestration/dispatch modules (lease acquisition on dispatch/handoff), `improvements/IMP-004-verification-boundaries-and-coverage-gaps.md` (SCOPE-2 cross-reference amendment, on approval), `docs/recipes/runtime-coordination.md` + `docs/issues/session-aware-runtime-coordination.md` (document the writer-lease kind) — name the owning agent/gate for each surface. Extends the existing runtime-lease primitive; composes with IMP-004 SCOPE-2.
