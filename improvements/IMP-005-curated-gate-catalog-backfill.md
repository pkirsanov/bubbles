# IMP-005 — Curated Gate-Catalog Docs Backfill (close the G082+ documentation gap)

> **Type:** Framework self-improvement execution plan
> **Owner surface:** Bubbles framework docs (`agents/bubbles_shared/quality-gates.md`,
> `skills/bubbles-quality-gates-catalog/SKILL.md`)
> **Status:** FRAMEWORK SHIPPED — v7.11.3 delivered both scopes. SCOPE-1
> backfilled `quality-gates.md` with a grouped `## Gate Family Reference
> (G082–G127)` (registry-accurate names + rationale + enforcing guard, registry
> cited as source of truth, range statement corrected to G001–G127). SCOPE-2
> shipped `bubbles/scripts/gate-catalog-freshness.sh` — a NON-BLOCKING (always
> exit 0) advisory wired into `framework-validate.sh` that WARNs when the
> registry gate-ceiling exceeds a curated catalog's ceiling. The SKILL quick-ref
> G110–G127 band was already landed in v7.11.1.
> **Created:** 2026-06-11

> ⚠️ **Why this lives in `improvements/` and not `specs/`:** the Bubbles source
> repo MUST NOT keep persistent `specs/` execution packets — Gate **G085**
> (`framework_dogfood_evidence_gate`) fails if `specs/` exists in the canonical
> checkout. This is the portable execution plan (mirrors IMP-001/002/003/004).

---

## Provenance

The v7.11.0 critical review (the IMP-004 / G127 delivery) audited the two
curated gate-reference surfaces against the authoritative registry
(`bubbles/registry/gates.yaml`, which defines gates through **G127**) and found
both curated docs materially stale:

- **`agents/bubbles_shared/quality-gates.md`** — the module the
  `bubbles-quality-gates-catalog` skill names as "the full gate catalog with
  rationale" — enumerates gates only through roughly **G081**. The entire
  **G082–G127** band (convergence cap, compaction discipline, dogfood evidence,
  orchestrator persistence, planning-packet linkage, post-cert edits,
  inter-spec deps, retro convergence, planning chain, strict terminal status,
  delivery delta, capability foundation, discovered-issue disposition,
  requirement-mechanism correspondence, the observability G098–G100 band, the
  release-train/upkeep/propagation/incident/framework-health G110–G126 band,
  and G127 itself) is **absent**.
- **`skills/bubbles-quality-gates-catalog/SKILL.md`** — the quick-reference
  ID-lookup skill — previously stopped at **G100**. The v7.11.0 review added a
  compact `G110–G126` band row + a dedicated `G127` row as an interim fix, so
  the quick-ref is now ID-current; the rationale-bearing module is not.

This is a documentation-completeness gap, not an enforcement gap: every gate is
correctly defined and enforced in `bubbles/registry/gates.yaml` +
`bubbles/workflows.yaml` + its guard script. The curated *human/agent reference*
docs simply drifted behind the registry as gates were added across the v6–v7
release line. It predates IMP-004 (the observability G098–G100 band was added to
the SKILL quick-ref by IMP-001 but never to `quality-gates.md`).

---

## Outcome Contract

- **Intent:** Bring the two curated gate-reference surfaces back to parity with
  the authoritative registry so "look up any gate by ID and read its rationale"
  works for the full current gate set, not just the pre-G082 era.
- **Success Signal:**
  1. `agents/bubbles_shared/quality-gates.md` documents every gate present in
     `bubbles/registry/gates.yaml` (rationale-level entries for G082–G127),
     OR explicitly and accurately scopes itself to a curated subset with a
     correct range statement + a pointer to the registry for the remainder.
  2. The `bubbles-quality-gates-catalog` SKILL quick-ref stays ID-current
     (already true after the v7.11.0 interim band addition).
  3. A lightweight freshness check (optional) flags when the registry's highest
     gate ID exceeds the highest ID documented in the curated catalog, so the
     drift cannot silently re-open.
- **Hard Constraints:**
  - Docs-only. No new enforcement gate, no schema change, no guard that could
    block real work. (A freshness *advisory* is acceptable; a hard blocker is
    out of scope — it would retroactively block every historical doc edit.)
  - Agnostic + no PII. Generic gate descriptions only.
  - Each backfilled entry's rationale MUST match the registry description +
    the enforcing guard — no invented behavior. Derive from `gates.yaml` and
    the guard scripts, not from memory.
  - Do NOT duplicate the registry verbatim into prose — the docs add *rationale
    and grouping*, the registry remains the single source of truth for the
    canonical name + enforcement.
- **Failure Condition:** The backfilled rationale contradicts the registry or a
  guard's actual behavior (fabricated doc), OR a hard freshness blocker is added
  that fails historical/unrelated doc edits.

---

## SCOPE-1 — Backfill `quality-gates.md` (G082–G127, rationale-level)

**Tasks**
- T1.1 — For each gate G082–G127 in `bubbles/registry/gates.yaml`, add a
  rationale-level entry to `agents/bubbles_shared/quality-gates.md` grouped by
  family (convergence/compaction, planning-integrity, terminal-status,
  capability, observability, release-train/upkeep, propagation, incident,
  framework-self). Each entry: gate ID, one-line rationale, enforcing guard.
  Derive every line from the registry description + the guard script; never from
  memory.
- T1.2 — If full per-gate rationale is too heavy for some families, group them
  (mirroring the SKILL quick-ref's compact band rows) but keep the range
  statement accurate (no "G024–G100+" when the real ceiling is G127).
- T1.3 — Cross-check: the highest gate ID in `quality-gates.md` equals the
  highest in `bubbles/registry/gates.yaml`.

## SCOPE-2 — Optional curated-catalog freshness advisory

**Tasks**
- T2.1 — Add a small advisory check (selftest-only or a non-blocking lint) that
  compares the highest `G<NNN>` in `bubbles/registry/gates.yaml` against the
  highest documented in the curated catalog(s) and WARNS on drift. NON-blocking
  by default — this is a maintenance nudge, not a completion gate.
- T2.2 — Wire the advisory into `framework-validate.sh` as an informational
  check (like the existing "Repository drift report (informational)") so a new
  gate without a catalog entry surfaces a visible reminder without failing CI.

---

## Risk register

| Risk | Severity | Mitigation |
|------|----------|------------|
| Backfilled rationale contradicts the registry/guard (fabricated doc) | High | Derive every entry from `gates.yaml` + the guard script; cross-check IDs |
| A hard freshness blocker retroactively fails unrelated doc edits | Med | Advisory is NON-blocking (informational), mirroring the existing repo-drift report |
| Doc bloat from per-gate prose | Low | Group low-traffic families into compact band rows (SKILL quick-ref precedent) |
| Drift silently re-opens after the backfill | Med | Optional SCOPE-2 advisory surfaces the registry-vs-catalog ceiling gap |

---

## Handoff

1. **Prioritize** against other framework work. This is documentation hygiene,
   not an enforcement or correctness gap — every gate is already defined and
   enforced in the registry; only the curated rationale docs lag.
2. Drive SCOPE-1 (backfill) → SCOPE-2 (optional advisory) through
   `bubbles.plan` → `bubbles.implement` (hermetic / source-repo docs work; no
   `specs/` packet per G085).
3. The v7.11.0 review already landed the SKILL quick-ref interim band rows
   (G110–G126 + G127), so the ID-lookup surface is current; this packet is the
   rationale-doc parity follow-up.
