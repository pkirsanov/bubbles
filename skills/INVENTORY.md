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
| **CONSOLIDATE** | Overlaps with a sibling skill; merge candidate. Decision routed to a follow-up minor with explicit consumer-impact review. |
| **POINTER-DELETE** | Pure redirect to an authoritative module with no added rules. Safe to delete in a follow-up minor. |
| **REVIEW** | Substantive but compact (<80 LOC). Manual review needed before pruning. |

## Inventory

| Skill | LOC | Status | Notes |
|---|---:|---|---|
| `bubbles-anti-fabrication` | 50 | KEEP | Auto-loaded discovery skill — anti-fab heuristics and gates G020-G025. |
| `bubbles-artifact-ownership-routing` | 63 | KEEP | Routes foreign-artifact changes to owning agent. Triggered by every cross-owner edit. |
| `bubbles-backup-bcdr-doctrine` | 100 | KEEP | Tier model + RTO/RPO + `OFFSITE_BACKEND` contract. Concrete operator rules. |
| `bubbles-bug-template` | 50 | KEEP | Bug artifact template. Filed-with-bug enforcement. |
| `bubbles-capability-foundation-design` | 157 | KEEP | Gate G094 enforcement details + provider/foundation split rules. |
| `bubbles-cinematic-design` | 56 | KEEP | Opt-in design-language skill (premium/cinematic presets + pattern library) selected by `bubbles.ux`, applied by `bubbles.implement`; presets/patterns from the retired `bubbles.cinematic-designer` agent. Vendored only where `.github/bubbles-project.yaml` `designLanguages.enabled` lists it. |
| `bubbles-config-bundle-per-train` | 143 | KEEP | Per-train flag bundle authoring — G081 mechanics. |
| `bubbles-config-sst` | 276 | KEEP | Configuration single-source-of-truth governance. Largest substantive skill. |
| `bubbles-cross-platform-shell` | 94 | KEEP | GNU/BSD (Linux + macOS) shell portability — guard-lib helpers, pitfall→portable table, selftest graceful-degradation. |
| `bubbles-datastore-isolation` | 133 | KEEP | Production stateful-store isolation doctrine — bundle-by-default + 4-part share-cleanly bar + stateful-vs-shared-safe split. Isolation-doctrine pair with `bubbles-isolated-ml-sidecar`. |
| `bubbles-deployment-target-adapter` | 542 | KEEP | Adapter authoring rules — central to G074 / G081. Largest skill overall. |
| `bubbles-docker-lifecycle-governance` | 50 | KEEP | Docker resource classes + cleanup safety + label-aware pruning. |
| `bubbles-docker-port-standards` | 40 | KEEP | 10k Rule + Dual-URL standard. Concrete operator-visible rules. |
| `bubbles-dod-validation` | 65 | KEEP | Auto-loaded discovery skill — DoD validation tiers. |
| `bubbles-env-pollution-isolation` | 81 | KEEP | Test code MUST NOT write to prod paths. Gate G115. |
| `bubbles-evidence-capture` | 71 | KEEP | Auto-loaded discovery skill — evidence-format standards. |
| `bubbles-external-browser-auth-capture` | 63 | KEEP | Human-in-the-loop external-Playwright-browser capture behind interactive auth (Google/YouTube login, SSO, cookie/bot gates); YouTube-transcript worked example. Not the internal VS Code webview. |
| `bubbles-feature-template` | 45 | KEEP | Canonical artifact templates (spec/design/scopes/report/uservalidation/state). |
| `bubbles-fix-cycle-protocol` | 37 | KEEP | Fix-cycle round semantics, finding-set closure. |
| `bubbles-flag-lifecycle` | 83 | KEEP | Flag introduce -> retire mechanics. Gate-adjacent. |
| `bubbles-isolated-ml-sidecar` | 127 | KEEP | Compute-only Python/ML sidecar invariant — service-gated (protobuf) or bus-gated realization + python-compute-only-guard shape. Isolation-doctrine pair with `bubbles-datastore-isolation`. |
| `bubbles-long-running-commands` | 110 | KEEP | Long-command discipline — background/await-notification + optional signal-file heartbeat; the anti-polling companion to terminal-discipline. |
| `bubbles-observability-adapter` | 184 | KEEP | Adapter contract (4 verbs) + trace-driven defect discovery during live-category tests — phil-collins lineage. |
| `bubbles-product-principle-discovery` | 111 | KEEP | Surface principles from evidence; non-fabricating ratification rules. |
| `bubbles-propagation-policy` | 120 | KEEP | J-Roc policy + ledger authoring. |
| `bubbles-quality-gates-catalog` | 69 | KEEP | Lookup-style discovery skill (G024-G095+ by ID/symptom/script). |
| `bubbles-release-packet-template` | 80 | KEEP | Sonny's 8-doc packet template. |
| `bubbles-release-train-model` | 99 | KEEP | DVS train lifecycle. |
| `bubbles-repo-readiness` | 70 | KEEP | Verify-first hygiene check. Auto-loaded discovery skill. |
| `bubbles-result-envelope` | 79 | KEEP | RESULT-ENVELOPE composition rules. Auto-loaded discovery skill. |
| `bubbles-scope-workflow-runtime` | 76 | KEEP | Scope artifact runtime rules. Auto-loaded discovery skill. |
| `bubbles-skill-authoring` | 115 | KEEP | Sam's specialties — how to author a skill safely. Carries the IP-2 **When NOT to use** / **Works well with** sections + the promote-to-skill decision rule + creation quality bar (IMP-016). |
| `bubbles-skills-first-discovery` | 58 | KEEP | The router that surfaces every other discovery skill. CRITICAL — never delete. |
| `bubbles-spec-template-bdd` | 46 | KEEP | Spec template enforcement (BDD shape). |
| `bubbles-status-transition` | 87 | KEEP | Status-transition discovery skill — wraps `state-transition-guard.sh`. |
| `bubbles-supply-chain-source-locking` | 178 | KEEP | Build-time dependency-source allowlist policy; complementary to (distinct from) deploy-time provenance. |
| `bubbles-test-environment-isolation` | 182 | KEEP | Ephemeral-only test backing store policy. |
| `bubbles-test-integrity` | 250 | KEEP | Trinity's field manual — substantive 6-gate decision tree. |
| `bubbles-upkeep-cadence` | 116 | KEEP | Calendar + ledger mechanics for upkeep tasks. |
| `bubbles-workflow-execution-loops` | 29 | KEEP | Compact but enforceable — synchronous dispatch-and-wait rules. |
| `bubbles-workflow-mode-resolution` | 54 | KEEP | Mode resolver + alias + status ceiling rules. |

## Summary

- **41 skills** — one row per real skill directory under `skills/` (every `skills/<name>/` that carries a `SKILL.md`, EXCLUDING any transient `__*` selftest probe such as the gitignored `__manifest_leak_probe/`). Post-`v6.0`-baseline additions include `bubbles-cinematic-design`, the `bubbles-isolated-ml-sidecar` / `bubbles-datastore-isolation` isolation-doctrine pair, `bubbles-long-running-commands`, and `bubbles-external-browser-auth-capture`. 0 deletions.
- **Total LOC:** ~4,293.
- **Pruning candidates** (POINTER-DELETE or CONSOLIDATE): **0**.
- Every current skill carries substantive policy that an agent invokes at trigger time. The "thin pointers" the v6 design contemplated were not authored — every skill in the current set was already substantive when added.

## v6.0.1 / v6.1 follow-ups

If a future skill IS authored as a pure pointer (e.g. an external reference that adds no rules), record it here with status `POINTER-DELETE` and remove it in the next minor release. This file is the single audit point for the skill pruning policy.

## Maintenance

- Updated by `bubbles.create-skill` whenever a skill is added or removed.
- Parity between this inventory and the real skill dirs is enforced by `bubbles/scripts/inventory-parity-check.sh` (wired into `framework-validate.sh` as a selftest + live check). It fails loud if a real skill (a `skills/<name>/` with a `SKILL.md`, excluding `__*` probes) has no row here, or if a row references a `skills/<name>/` that does not exist — so the count above cannot silently drift. [IMP-005]
- Re-checked during `release-check.sh` (planned for v6.1).
- Sized via `wc -l skills/<name>/SKILL.md` — keep accurate by running the inventory generator (planned: `bubbles/scripts/generate-skill-inventory.sh`).
