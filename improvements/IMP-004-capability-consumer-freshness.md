# IMP-004 — Capability-Consumer Freshness (close the orphan-foundation root cause)

> **Type:** Framework self-improvement proposal (NOT yet implemented)
> **Owner surface:** Bubbles framework (`bubbles/capability-ledger.yaml`,
> `bubbles/schemas/capability-ledger.schema.json`, `bubbles/scripts/`,
> `bubbles/scripts/framework-validate.sh`, `docs/`)
> **Status:** FRAMEWORK SHIPPED — v7.11.0 delivered Gate **G127**
> (`capability_consumer_freshness_gate`) via
> `bubbles/scripts/capability-consumer-freshness.sh` +
> `bubbles/scripts/capability-consumer-freshness-selftest.sh` (16 cases),
> wired into `framework-validate.sh` (selftest + live guard). SCOPE-1
> (`consumers:` field + schema) was landed in v7.10.1; SCOPE-2 (guard +
> selftest + G127 registry entry) and SCOPE-3 (backfill `consumers:` for all
> 19 shipped capabilities — 61 consumer paths verified) landed in v7.11.0. The
> gate dogfoods itself (registered as a shipped capability with consumers).
> **Created:** 2026-06-11

> ⚠️ **Why this lives in `improvements/` and not `specs/`:** the Bubbles source
> repo MUST NOT keep persistent `specs/` execution packets — Gate **G085**
> (`framework_dogfood_evidence_gate`) fails if `specs/` exists in the canonical
> checkout. This is the portable execution plan (mirrors IMP-001/002/003).

---

## Provenance

IMP-001 (observability) shipped a v5 adapter layer that had **zero executable
consumers** — mechanism + lint + skill + docs, but nothing in code ever invoked
it (R2-B "orphan foundation"). The IMP-001 risk register named the **systemic**
root cause and routed the durable fix to a "candidate IMP-002":

> *"the framework holds its consumers to 'no orphans' (G029 + Consumer Impact
> Sweep) while exempting its own capability ledger — `capability-ledger.yaml`
> has no `consumers:` field and nothing in `framework-validate` asserts a
> shipped capability has a wired consumer."*

That routing was never honoured: IMP-002 shipped as *supply-chain source
locking* (an unrelated capability), so the systemic observability-orphan fix was
silently dropped. The v7.10.0 critical review re-surfaced it. Per Gate G095
(discovered-issue disposition), the finding is now **filed here** rather than
left as a dangling phantom reference.

The v7.10.0 follow-up work (this session) already landed the *first half*:
- A `consumers:` field was **added to `capability-ledger.yaml`** for the two
  observability entries (`observability-adapter-contract`,
  `observability-posture-and-slo-gates`) and declared in
  `capability-ledger.schema.json`.
- Those consumers are now **real**: the P0 fix wired G098/G099/G100 into
  `state-transition-guard.sh` (the universal done-gate), and
  `observability-check.sh` now invokes `observability-endpoint-resolve.sh
  --names-only`, making the resolver a genuine executable consumer.

What remains — and is the durable, framework-wide fix — is the **enforcement**:
make `consumers:` mandatory for `state: shipped` capabilities and verify each
listed consumer path exists and actually references the capability.

---

## Outcome Contract

- **Intent:** A capability cannot be marked `state: shipped` in
  `capability-ledger.yaml` unless it declares a non-empty `consumers:` list AND
  every listed consumer path exists on disk. This is the G029
  (integration-completeness) standard applied to the framework's OWN ledger —
  the framework stops exempting itself from the rule it enforces downstream.
- **Success Signal:**
  1. A new `capability-consumer-freshness.sh` guard exits 1 when any
     `state: shipped` capability has an empty/absent `consumers:` list or names
     a consumer path that does not exist.
  2. `framework-validate.sh` runs the guard (live) + its hermetic selftest.
  3. Backfilling `consumers:` across all existing `shipped` capabilities is
     part of the same change (the guard goes green only after backfill).
- **Hard Constraints:**
  - No false positives on `partial` / `proposed` / `deprecated` capabilities
    (only `shipped` requires consumers).
  - Agnostic + no PII; hermetic selftest with fixtures (no live ledger
    dependency in the selftest).
  - No new workflow mode; one guard + one selftest + `framework-validate`
    wiring + the schema doc (already done) + the ledger backfill.
  - Grandfather: the guard must ship GREEN, so either all `shipped` entries are
    backfilled in the same change, or pre-existing entries without `consumers:`
    are WARN-only until a declared cutoff (prefer full backfill).
- **Failure Condition:** The guard blocks legitimate non-shipped capabilities,
  or it ships red (forcing a bypass), or it only checks presence without
  verifying the consumer path exists (shape-not-substance — the exact hole
  G097 was created to close elsewhere).

---

## SCOPE-1 — `consumers:` field + schema (PARTIALLY DONE in v7.10.0)

**Done in v7.10.0 follow-up:**
- `consumers:` added to the two observability entries in
  `capability-ledger.yaml`.
- `consumers:` declared in `capability-ledger.schema.json` (`additionalProperties`
  was already `true`, so this is documentation + intent).

**Remaining:**
- Backfill `consumers:` for EVERY other `state: shipped` capability in the
  ledger (each must name the scripts/agents/tools that actually invoke it).

## SCOPE-2 — `capability-consumer-freshness.sh` guard + selftest

**Gherkin**
- Given a `state: shipped` capability with a non-empty `consumers:` list whose every path exists, when the guard runs, then it passes (exit 0).
- Given a `state: shipped` capability with no `consumers:` (or an empty list), when the guard runs, then it fails (exit 1) naming the orphan capability.
- Given a `state: shipped` capability whose `consumers:` names a path that does not exist on disk, when the guard runs, then it fails (exit 1) naming the dangling consumer.
- Given a `partial` / `proposed` / `deprecated` capability with no `consumers:`, when the guard runs, then it is a clean no-op for that entry (exit 0).

**Tasks**
- T2.1 — Author `bubbles/scripts/capability-consumer-freshness.sh`: parse the ledger with `yq`, iterate capabilities, enforce the rule above for `state: shipped` only. NO bypass flag. Missing `yq` fails closed (it is a release-gating check, like the SLO guard) OR WARN-and-skips (decide per how `framework-validate` already treats yq — match the surrounding gates).
- T2.2 — Author `bubbles/scripts/capability-consumer-freshness-selftest.sh`: hermetic fixtures (shipped-with-consumers PASS; shipped-no-consumers FAIL; shipped-dangling-consumer FAIL; proposed-no-consumers PASS-noop).
- T2.3 — Wire both into `framework-validate.sh` (selftest + live guard) and add a `G1xx` gate-registry entry (next free framework gate ID — verify against `bubbles/registry/gates.yaml`; G096 stays burned).
- T2.4 — Regenerate `workflows.yaml` gates block, framework-stats, release manifest; run `framework-validate` green.

## SCOPE-3 — Backfill all shipped capabilities

**Tasks**
- T3.1 — For every `state: shipped` capability, add a `consumers:` list naming real, existing executable surfaces. Where a capability genuinely has no consumer, that is an orphan finding to RESOLVE (wire it or downgrade `state`), not to paper over.
- T3.2 — Re-run the guard; it must exit 0 only after honest backfill.

---

## Risk register

| Risk | Severity | Mitigation |
|------|----------|------------|
| Guard ships red, forcing a bypass | High | Backfill all `shipped` entries in the same change; guard has NO bypass flag |
| Presence-only check (names a consumer that does not exist) | High | T2.1 verifies each consumer path EXISTS on disk (substance, not shape) |
| False positive on non-shipped capabilities | Med | Only `state: shipped` is enforced; selftest covers the proposed/partial no-op |
| `consumers:` becomes stale (consumer deleted later) | Med | The path-existence check catches a deleted consumer on the next run |

---

## Handoff

1. **Prioritize** against other framework work (this is the durable fix for the
   orphan-foundation class of bug; the observability instance is already closed).
2. Drive SCOPE-2 → SCOPE-3 through `bubbles.plan` → `bubbles.implement`
   (hermetic fixtures; no source-repo `specs/` per G085).
3. The v7.10.0 follow-up already proved the pattern on the two observability
   entries; this generalizes it to a mechanical, framework-wide gate.
