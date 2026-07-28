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

> **Invocation** (IMP-021 SCOPE-5) records the authoring decision for each skill:
> `auto-discovery-required` — a broadly-triggered policy/discovery skill the model
> should always be able to surface; or `explicit-invocation-sufficient` — a narrow
> skill reached only via a specific agent/recipe. This VS Code harness auto-loads
> EVERY skill's `description:` frontmatter, so the class is a recorded judgment for
> future pruning, NOT a host toggle (no unsupported SKILL.md frontmatter). **DescBytes**
> is the byte length of that `description:` value; the aggregate auto-discovery load is
> reported by `bubbles/scripts/skill-description-load.sh` (report-only, no threshold).

| Skill | LOC | Invocation | DescBytes | Status | Notes |
|---|---:|---|---:|---|---|
| `bubbles-anti-fabrication` | 50 | auto-discovery-required | 361 | KEEP | Auto-loaded discovery skill — anti-fab heuristics and gates G020-G025. |
| `bubbles-artifact-ownership-routing` | 63 | auto-discovery-required | 355 | KEEP | Routes foreign-artifact changes to owning agent. Triggered by every cross-owner edit. |
| `bubbles-backup-bcdr-doctrine` | 100 | explicit-invocation-sufficient | 277 | KEEP | Tier model + RTO/RPO + `OFFSITE_BACKEND` contract. Concrete operator rules. |
| `bubbles-bug-template` | 50 | auto-discovery-required | 312 | KEEP | Bug artifact template. Filed-with-bug enforcement. |
| `bubbles-capability-foundation-design` | 157 | auto-discovery-required | 291 | KEEP | Gate G094 enforcement details + provider/foundation split rules. Borderline; default-to-auto (high-cost-if-missed design trigger). |
| `bubbles-cinematic-design` | 56 | explicit-invocation-sufficient | 411 | KEEP | Opt-in design-language skill (premium/cinematic presets + pattern library) selected by `bubbles.ux`, applied by `bubbles.implement`; presets/patterns from the retired `bubbles.cinematic-designer` agent. Vendored only where `.github/bubbles-project.yaml` `designLanguages.enabled` lists it. |
| `bubbles-code-index-adapter` | 149 | explicit-invocation-sufficient | 613 | KEEP | Optional, default-off code-index adapter seam — lets a repository expose derived structural source facts (symbols, blast radius, affected tests, route inventory) through a swappable provider instead of hand-maintained lists. Explicit like its adapter-seam siblings `bubbles-observability-adapter` and `bubbles-deployment-target-adapter`: consulted when wiring `codeIndex.adapter`, not needed on every turn. |
| `bubbles-config-bundle-per-train` | 143 | explicit-invocation-sufficient | 222 | KEEP | Per-train flag bundle authoring — G081 mechanics. |
| `bubbles-config-sst` | 276 | auto-discovery-required | 359 | KEEP | Configuration single-source-of-truth governance. Largest substantive skill. |
| `bubbles-cross-platform-shell` | 132 | auto-discovery-required | 630 | KEEP | GNU/BSD (Linux + macOS) shell portability — guard-lib helpers, pitfall→portable table, selftest graceful-degradation, + the `macos-portability-guard.sh` mechanical lint (reusable, caller-supplied surface; `# portable-ok:` pragma). |
| `bubbles-datastore-isolation` | 133 | explicit-invocation-sufficient | 820 | KEEP | Production stateful-store isolation doctrine — bundle-by-default + 4-part share-cleanly bar + stateful-vs-shared-safe split. Isolation-doctrine pair with `bubbles-isolated-ml-sidecar`. |
| `bubbles-deployment-target-adapter` | 542 | explicit-invocation-sufficient | 632 | KEEP | Adapter authoring rules — central to G074 / G081. Largest skill overall. |
| `bubbles-docker-lifecycle-governance` | 50 | explicit-invocation-sufficient | 218 | KEEP | Docker resource classes + cleanup safety + label-aware pruning. |
| `bubbles-docker-port-standards` | 40 | explicit-invocation-sufficient | 206 | KEEP | 10k Rule + Dual-URL standard. Concrete operator-visible rules. |
| `bubbles-dod-validation` | 65 | auto-discovery-required | 398 | KEEP | Auto-loaded discovery skill — DoD validation tiers. |
| `bubbles-env-pollution-isolation` | 81 | auto-discovery-required | 374 | KEEP | Test code MUST NOT write to prod paths. Gate G115. Borderline; default-to-auto (test-authoring pollution policy, pairs with `bubbles-test-environment-isolation`). |
| `bubbles-evidence-capture` | 71 | auto-discovery-required | 413 | KEEP | Auto-loaded discovery skill — evidence-format standards. |
| `bubbles-external-browser-auth-capture` | 63 | explicit-invocation-sufficient | 730 | KEEP | Human-in-the-loop external automated-browser capture behind interactive auth (SSO/OAuth, cookie/bot gates), including transcript extraction. Not the internal VS Code webview. |
| `bubbles-feature-template` | 45 | auto-discovery-required | 390 | KEEP | Canonical artifact templates (spec/design/scopes/report/uservalidation/state). |
| `bubbles-fix-cycle-protocol` | 37 | auto-discovery-required | 315 | KEEP | Fix-cycle round semantics, finding-set closure. |
| `bubbles-flag-lifecycle` | 83 | explicit-invocation-sufficient | 300 | KEEP | Flag introduce -> retire mechanics. Gate-adjacent. |
| `bubbles-isolated-ml-sidecar` | 127 | explicit-invocation-sufficient | 752 | KEEP | Compute-only Python/ML sidecar invariant — service-gated (protobuf) or bus-gated realization + python-compute-only-guard shape. Isolation-doctrine pair with `bubbles-datastore-isolation`. |
| `bubbles-long-running-commands` | 110 | auto-discovery-required | 483 | KEEP | Long-command discipline — background/await-notification + optional signal-file heartbeat; the anti-polling companion to terminal-discipline. |
| `bubbles-observability-adapter` | 184 | explicit-invocation-sufficient | 375 | KEEP | Adapter contract (4 verbs) + trace-driven defect discovery during live-category tests — phil-collins lineage. |
| `bubbles-product-principle-discovery` | 111 | explicit-invocation-sufficient | 302 | KEEP | Surface principles from evidence; non-fabricating ratification rules. |
| `bubbles-propagation-policy` | 120 | explicit-invocation-sufficient | 145 | KEEP | J-Roc policy + ledger authoring. |
| `bubbles-quality-gates-catalog` | 69 | auto-discovery-required | 331 | KEEP | Lookup-style discovery skill (G024-G095+ by ID/symptom/script). |
| `bubbles-release-packet-template` | 80 | explicit-invocation-sufficient | 356 | KEEP | Sonny's 8-doc packet template. |
| `bubbles-release-train-model` | 99 | explicit-invocation-sufficient | 232 | KEEP | DVS train lifecycle. |
| `bubbles-repo-readiness` | 70 | auto-discovery-required | 271 | KEEP | Verify-first hygiene check. Auto-loaded discovery skill. |
| `bubbles-result-envelope` | 79 | auto-discovery-required | 407 | KEEP | RESULT-ENVELOPE composition rules. Auto-loaded discovery skill. |
| `bubbles-scope-workflow-runtime` | 76 | auto-discovery-required | 317 | KEEP | Scope artifact runtime rules. Auto-loaded discovery skill. |
| `bubbles-skill-authoring` | 141 | auto-discovery-required | 185 | KEEP | Sam's specialties — how to author a skill safely. Carries the IP-2 **When NOT to use** / **Works well with** sections + the promote-to-skill decision rule + creation quality bar (IMP-016) + the invocation-class / description-load authoring decision (IMP-021 SCOPE-5). |
| `bubbles-skills-first-discovery` | 58 | auto-discovery-required | 360 | KEEP | The router that surfaces every other discovery skill. CRITICAL — never delete. |
| `bubbles-spec-template-bdd` | 46 | auto-discovery-required | 129 | KEEP | Spec template enforcement (BDD shape). |
| `bubbles-status-transition` | 87 | auto-discovery-required | 351 | KEEP | Status-transition discovery skill — wraps `state-transition-guard.sh`. |
| `bubbles-supply-chain-source-locking` | 178 | explicit-invocation-sufficient | 799 | KEEP | Build-time dependency-source allowlist policy; complementary to (distinct from) deploy-time provenance. |
| `bubbles-test-environment-isolation` | 182 | auto-discovery-required | 613 | KEEP | Ephemeral-only test backing store policy. |
| `bubbles-test-integrity` | 250 | auto-discovery-required | 346 | KEEP | Trinity's field manual — substantive 6-gate decision tree. |
| `bubbles-upkeep-cadence` | 116 | explicit-invocation-sufficient | 332 | KEEP | Calendar + ledger mechanics for upkeep tasks. |
| `bubbles-vscode-agent-constraints` | 203 | auto-discovery-required | 652 | KEEP | VS Code agent-runtime constraints — depth-1 subagent limit, `handoffs:`/`agents:`/`disable-model-invocation:`/`user-invocable:` semantics, allowlist-overrides-flag precedence, dual-role invocability, frontmatter-vs-body authority. Prevents multi-level-dispatch designs and prose-only delegation laws. |
| `bubbles-workflow-execution-loops` | 29 | auto-discovery-required | 345 | KEEP | Compact but enforceable — synchronous dispatch-and-wait rules. |
| `bubbles-workflow-mode-resolution` | 54 | auto-discovery-required | 378 | KEEP | Mode resolver + alias + status ceiling rules. |

## Summary

- **41 skills** — one row per real skill directory under `skills/` (every `skills/<name>/` that carries a `SKILL.md`, EXCLUDING any transient `__*` selftest probe such as the gitignored `__manifest_leak_probe/`). Post-`v6.0`-baseline additions include `bubbles-cinematic-design`, the `bubbles-isolated-ml-sidecar` / `bubbles-datastore-isolation` isolation-doctrine pair, `bubbles-long-running-commands`, and `bubbles-external-browser-auth-capture`. 0 deletions.
- **Total LOC:** ~4,331.
- **Invocation class (IMP-021 SCOPE-5):** **24 `auto-discovery-required`** + **17 `explicit-invocation-sufficient`**. The two borderline calls (`bubbles-capability-foundation-design`, `bubbles-env-pollution-isolation`) defaulted to `auto-discovery-required` per the "when uncertain, default to auto" rule and are noted in their rows.
- **Aggregate description load:** **8,714 bytes** across the 24 `auto-discovery-required` descriptions (the always-loaded model-facing context cost this harness auto-loads), 7,109 bytes across the 17 `explicit-invocation-sufficient` descriptions, **15,823 bytes total**. Reported live (never blocked) by `bubbles/scripts/skill-description-load.sh`; the recorded `DescBytes` column is a per-skill snapshot of each `description:` value's byte length.
- **Pruning candidates** (POINTER-DELETE or CONSOLIDATE): **0**.
- Every current skill carries substantive policy that an agent invokes at trigger time. The "thin pointers" the v6 design contemplated were not authored — every skill in the current set was already substantive when added.

## v6.0.1 / v6.1 follow-ups

If a future skill IS authored as a pure pointer (e.g. an external reference that adds no rules), record it here with status `POINTER-DELETE` and remove it in the next minor release. This file is the single audit point for the skill pruning policy.

## Maintenance

- Updated by `bubbles.create-skill` whenever a skill is added or removed.
- Parity between this inventory and the real skill dirs is enforced by `bubbles/scripts/inventory-parity-check.sh` (wired into `framework-validate.sh` as a selftest + live check). It fails loud if a real skill (a `skills/<name>/` with a `SKILL.md`, excluding `__*` probes) has no row here, or if a row references a `skills/<name>/` that does not exist — so the count above cannot silently drift. [IMP-005]
- Invocation-class + description-load completeness is enforced by `bubbles/scripts/skill-description-load.sh` (wired into `framework-validate.sh` as a hermetic selftest + a live source-only report). It fails loud if a real skill row omits its `Invocation` class or numeric `DescBytes`, and otherwise prints the aggregate description-load figures **report-only (exit 0, no threshold)**. [IMP-021 SCOPE-5]
- Re-checked during `release-check.sh` (planned for v6.1).
- LOC sized via `wc -l skills/<name>/SKILL.md`; `DescBytes` is the byte length of the `description:` frontmatter value (`skill-description-load.sh` recomputes it live and notes any drift from the recorded snapshot) — keep accurate by running the inventory generator (planned: `bubbles/scripts/generate-skill-inventory.sh`).
