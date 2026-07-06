# IMP-017 — Template Case-Collision Fix + Prevention Guard

**Status:** APPLIED in working tree (SCOPE-1–3 implemented; SCOPE-4 deferred) — awaiting owner review + commit
**Surface:** framework-health (G125) — human-reviewed. Parts 1–3 were implemented in the same change that files this proposal, at the repo owner's direction; the durable record is the shipped guard + `install.sh` fix + this doc.
**Motivation:** A cross-platform bootstrap-contract defect discovered on a case-insensitive (macOS) checkout — `templates/` tracked the SAME command-registry-template blob under two case-colliding names.
**Verified gaps addressed:** C1 (duplicate registry template under two cases → cross-platform git-index collision), C2 (`install.sh` generated the root `AGENTS.md` from the WRONG, case-colliding template), C3 (no mechanical guard against case-only duplicate tracked paths).

## Problem (verified against source)

- **C1 — case-colliding registry template:** `git ls-files templates/` tracked BOTH `templates/AGENTS.md.tmpl` and `templates/agents.md.tmpl`, and `git rev-parse HEAD:templates/AGENTS.md.tmpl` == `HEAD:templates/agents.md.tmpl` == blob `7874afaf…` — two names, one blob (the "Agent Command Registry" template). `core.ignorecase=true` (macOS/Windows) collapses them to ONE physical file, which corrupts downstream git indexes and blocks checkouts/rebases; the derived release manifest also diverges between a case-sensitive and a case-insensitive checkout (`find templates/` sees one file on macOS, two on Linux).
- **C2 — `install.sh` generated the wrong content:** `install.sh` scaffolded the root `AGENTS.md` from `templates/AGENTS.md.tmpl` (the block at ~L883–894). That template is the command REGISTRY, not repo guardrails, so bootstrap generated the WRONG file — dormant only because every repo ships its own hand-written `AGENTS.md`. The correct registry scaffold (`.specify/memory/agents.md` from `templates/agents.md.tmpl`, ~L922–930) was untouched.
- **C3 — no prevention:** no mechanical check existed to stop a case-only duplicate tracked path from re-entering the tree.

## Proposal

### SCOPE-1 — Remove the duplicate template, case-safe git plumbing (C1) — ✅ IMPLEMENTED

Removed the uppercase index entry WITHOUT deleting the shared physical file, exact-case (macOS is case-insensitive, so `ignorecase` MUST be disabled for the op):

```
git -c core.ignorecase=false rm --cached templates/AGENTS.md.tmpl
```

`git ls-files templates/` now lists only `templates/agents.md.tmpl`; the registry blob (`7874afaf…`) and the physical file (2601 bytes, header `# {{PROJECT_NAME}} — Agent Command Registry`) are unchanged.

### SCOPE-2 — Fix `install.sh` (C2) — ✅ IMPLEMENTED

Removed the root-`AGENTS.md` scaffold block (it referenced the case-colliding name AND wrote the wrong content) plus the two installer output claims that bootstrap "Created AGENTS.md" (the `CROSS_PROJECT_SETUP.md` required-files table row + the "📁 Created" summary line). Kept the correct `.specify/memory/agents.md` scaffold from `templates/agents.md.tmpl`. An explanatory `NOTE (IMP-017)` comment replaces the removed block. No new starter template authored (see SCOPE-4).

### SCOPE-3 — Case-collision prevention guard (C3) — ✅ IMPLEMENTED

- `bubbles/scripts/case-collision-guard.sh`: scans `git ls-files` for any two paths differing only by case, exits 1 listing each collision group (exit 0 clean; 0/no-op when git is unavailable or the target is not a git work tree). Portable bash per `bubbles-cross-platform-shell` (`#!/usr/bin/env bash`, `set -euo pipefail`, POSIX awk `tolower`/`split`, `LC_ALL=C sort`, `-h/--help` → exit 0). No bypass flag.
- `bubbles/scripts/case-collision-guard-selftest.sh` (hermetic): a clean staged tree passes; an injected `Foo.md`+`foo.md` index entry (via `git update-index --cacheinfo`, the only way to reproduce the collision on a case-insensitive FS) fails and lists both paths; a non-git dir no-ops.
- Wired BOTH into `bubbles/scripts/framework-validate.sh` via `run_check` (selftest + live scan against the repo), mirroring the sibling `inventory-parity-check` registration.

### SCOPE-4 — Correct starter-`AGENTS.md` scaffold (DEFERRED — separate future feature)

Bootstrap no longer creates a root `AGENTS.md`. Authoring a CORRECT starter guardrails template (distinct from the command-registry template) and re-adding a scaffold step is intentionally OUT OF SCOPE for this bug fix and is tracked as a separate future proposal. Greenfield repos ship their own `AGENTS.md` in the interim — unchanged from today's reality.

## Migration / rollout

All changes are additive or corrective and land in one commit. The `git rm --cached` is index-only (the physical registry file is untouched). The release manifest is regenerated because the template-set change + the two new guard scripts change the managed-file set. No downstream repo is edited; on the next framework sync the guard + `install.sh` fix propagate normally.

## Risks & mitigations

- **R1** Removing the wrong index entry → mitigated by the exact-case `-c core.ignorecase=false` op + `git ls-files` verification (only the lowercase name remains; blob unchanged).
- **R2** The new live guard newly fails a downstream repo that already has a case collision → that is the guard working as intended (surfacing a real defect); the remedy is to de-duplicate, never to skip (there is no bypass flag).
- **R3** Numbering: `improvements/` shows only IMP-001..006 because delivered IMP docs are deleted-on-delivery (per the improvements-doc lifecycle; see `CHANGELOG.md`), but the MONOTONIC IMP sequence has reached IMP-016 (v7.16.0) and IMP-007 is permanently assigned to `regen-derived.sh` (referenced in `framework-validate.sh`, `scaffold-gate.sh`, `CHANGELOG.md`). This proposal therefore takes the next FREE number, **IMP-017**, to avoid a semantic collision with a delivered improvement.

## Acceptance criteria (when implemented)

- `git ls-files templates/ | grep -i agents` lists exactly one path (`templates/agents.md.tmpl`); the registry blob is unchanged.
- `install.sh` no longer references `templates/AGENTS.md.tmpl` and makes no "Created AGENTS.md" claim; it still scaffolds `.specify/memory/agents.md`.
- `bash bubbles/scripts/case-collision-guard.sh` exits 0 on the cleaned repo; the selftest passes; a synthetic `Foo.md`+`foo.md` collision exits 1.
- `bash bubbles/scripts/framework-validate.sh` ends exit 0 with no `FAIL:` lines (after regenerating the release manifest).

## Files to touch (on approval)

`templates/AGENTS.md.tmpl` (untracked via case-safe `git rm --cached`; physical registry file retained as `templates/agents.md.tmpl`), `install.sh` (remove root-`AGENTS.md` scaffold + output claims), `bubbles/scripts/case-collision-guard.sh` + `bubbles/scripts/case-collision-guard-selftest.sh` (new guard + selftest), `bubbles/scripts/framework-validate.sh` (wire both via `run_check`), `bubbles/release-manifest.json` (regenerated), `improvements/INDEX.md` (register this IMP). Owning surface: `framework-health` (G125).
