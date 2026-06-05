# Bubbles Skills Inventory

> Source of truth: this file. Maintained by `bubbles.create-skill` and reviewed during release-check.
> Version: v6.0 / B5 baseline. Captures every skill installed under `skills/` with its size, audience, and pruning candidacy.

## Pruning Policy (v6.0 / B5)

v5 grew the skills surface to 35 entries (~3,800 LOC). The v6 design (B5) calls for trimming "thin-pointer skills (<80 LOC each); keep substantive policy skills".

Size alone is NOT the criterion. Many small skills (e.g. `bubbles-workflow-execution-loops` at 29 LOC) carry concrete enforceable policy and stay. Skills that purely point at another module without adding rules go away.

This inventory captures the v6.0 baseline so v6.0.1 can act on operator-reviewed deletions. **No deletions in v6.0 itself** — the operator-visible surface stays identical so downstream installs are not broken by a silent skill removal.

## Decision matrix

| Status | Meaning |
|---|---|
| **KEEP** | Substantive policy with concrete rules an agent invokes. Stays through v7. |
| **CONSOLIDATE** | Overlaps with a sibling skill; merge candidate. Decision deferred to v6.0.1 with explicit consumer-impact review. |
| **POINTER-DELETE** | Pure redirect to an authoritative module with no added rules. Safe to delete in v6.0.1. |
| **REVIEW** | Substantive but compact (<80 LOC). Manual review needed before pruning. |

## Inventory

| Skill | LOC | Status | Notes |
|---|---:|---|---|
| `bubbles-anti-fabrication` | 50 | KEEP | Auto-loaded discovery skill — anti-fab heuristics and gates G020-G025. |
| `bubbles-artifact-ownership-routing` | 63 | KEEP | Routes foreign-artifact changes to owning agent. Triggered by every cross-owner edit. |
| `bubbles-backup-bcdr-doctrine` | 100 | KEEP | Tier model + RTO/RPO + `OFFSITE_BACKEND` contract. Concrete operator rules. |
| `bubbles-bug-template` | 50 | KEEP | Bug artifact template. Filed-with-bug enforcement. |
| `bubbles-capability-foundation-design` | 157 | KEEP | Gate G094 enforcement details + provider/foundation split rules. |
| `bubbles-config-bundle-per-train` | 143 | KEEP | Per-train flag bundle authoring — G081 mechanics. |
| `bubbles-config-sst` | 276 | KEEP | Configuration single-source-of-truth governance. Largest substantive skill. |
| `bubbles-deployment-target-adapter` | 542 | KEEP | Adapter authoring rules — central to G074 / G081. Largest skill overall. |
| `bubbles-docker-lifecycle-governance` | 50 | KEEP | Docker resource classes + cleanup safety + label-aware pruning. |
| `bubbles-docker-port-standards` | 40 | KEEP | 10k Rule + Dual-URL standard. Concrete operator-visible rules. |
| `bubbles-dod-validation` | 65 | KEEP | Auto-loaded discovery skill — DoD validation tiers. |
| `bubbles-env-pollution-isolation` | 81 | KEEP | Test code MUST NOT write to prod paths. Gate G115. |
| `bubbles-evidence-capture` | 71 | KEEP | Auto-loaded discovery skill — evidence-format standards. |
| `bubbles-feature-template` | 45 | KEEP | Canonical artifact templates (spec/design/scopes/report/uservalidation/state). |
| `bubbles-fix-cycle-protocol` | 37 | KEEP | Fix-cycle round semantics, finding-set closure. |
| `bubbles-flag-lifecycle` | 83 | KEEP | Flag introduce -> retire mechanics. Gate-adjacent. |
| `bubbles-observability-adapter` | 98 | KEEP | Adapter contract (4 verbs) — phil-collins lineage. |
| `bubbles-product-principle-discovery` | 111 | KEEP | Surface principles from evidence; non-fabricating ratification rules. |
| `bubbles-propagation-policy` | 120 | KEEP | J-Roc policy + ledger authoring. |
| `bubbles-quality-gates-catalog` | 69 | KEEP | Lookup-style discovery skill (G024-G095+ by ID/symptom/script). |
| `bubbles-release-packet-template` | 80 | KEEP | Sonny's 8-doc packet template. |
| `bubbles-release-train-model` | 99 | KEEP | DVS train lifecycle. |
| `bubbles-repo-readiness` | 70 | KEEP | Verify-first hygiene check. Auto-loaded discovery skill. |
| `bubbles-result-envelope` | 79 | KEEP | RESULT-ENVELOPE composition rules. Auto-loaded discovery skill. |
| `bubbles-scope-workflow-runtime` | 76 | KEEP | Scope artifact runtime rules. Auto-loaded discovery skill. |
| `bubbles-skill-authoring` | 96 | KEEP | Sam's specialties — how to author a skill safely. |
| `bubbles-skills-first-discovery` | 58 | KEEP | The router that surfaces every other discovery skill. CRITICAL — never delete. |
| `bubbles-spec-template-bdd` | 46 | KEEP | Spec template enforcement (BDD shape). |
| `bubbles-status-transition` | 87 | KEEP | Status-transition discovery skill — wraps `state-transition-guard.sh`. |
| `bubbles-test-environment-isolation` | 182 | KEEP | Ephemeral-only test backing store policy. |
| `bubbles-test-integrity` | 250 | KEEP | Trinity's field manual — substantive 6-gate decision tree. |
| `bubbles-upkeep-cadence` | 116 | KEEP | Calendar + ledger mechanics for upkeep tasks. |
| `bubbles-workflow-execution-loops` | 29 | KEEP | Compact but enforceable — synchronous dispatch-and-wait rules. |
| `bubbles-workflow-mode-resolution` | 54 | KEEP | Mode resolver + alias + status ceiling rules. |

## Summary

- **34 skills, 0 deletions** in v6.0 baseline.
- **Total LOC:** ~3,800.
- **Pruning candidates** (POINTER-DELETE or CONSOLIDATE): **0**.
- Every current skill carries substantive policy that an agent invokes at trigger time. The "thin pointers" the v6 design contemplated were not authored — every skill in the current set was already substantive when added.

## v6.0.1 / v6.1 follow-ups

If a future skill IS authored as a pure pointer (e.g. an external reference that adds no rules), record it here with status `POINTER-DELETE` and remove it in the next minor release. This file is the single audit point for the skill pruning policy.

## Maintenance

- Updated by `bubbles.create-skill` whenever a skill is added or removed.
- Re-checked during `release-check.sh` (planned for v6.1).
- Sized via `wc -l skills/<name>/SKILL.md` — keep accurate by running the inventory generator (planned: `bubbles/scripts/generate-skill-inventory.sh`).
