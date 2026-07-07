# IMP-018 — Reusable macOS/WSL Portability Guard + Selftest

**Status:** APPLIED in working tree (SCOPE-1–4 implemented) — awaiting owner review + commit
**Surface:** framework-health (G125) — human-reviewed. The guard + selftest + `framework-validate` wiring + doc pointers were implemented in the same change that files this proposal (Lane-A framework-first tooling addition, at the repo owner's direction); the durable record is the shipped guard + selftest + this doc.
**Motivation:** The `bubbles-cross-platform-shell` skill + `wsl-macos-compatibility.instructions.md` define a 13-class GNU/BSD "Pitfall → Portable Form" table, but until now it was enforced only by human review + `shellcheck` (which does NOT catch GNU/BSD runtime divergence). The one existing mechanical check ([`WanderAide/scripts/lint/macos-portability-guard.sh`](../../WanderAide/scripts/lint/macos-portability-guard.sh)) is product-local, covers only 4 classes, and is hard-wired to `wanderaide-scripts/*.sh`.
**Verified gaps addressed:** MP1 (no reusable framework guard), MP2 (13-class table unenforced mechanically), MP3 (no framework-validate selftest locking the contract).

## Problem (verified against source)

- **MP1 — no reusable framework guard:** the only mechanical portability check lived in a product repo (`WanderAide/scripts/lint/macos-portability-guard.sh`), scanned a single hard-coded surface (`wanderaide-scripts/*.sh`), and detected only 4 of the 13 documented classes (`timeout`, `df --output`, `grep -P`, `[[ -v ]]`). No framework-level, surface-agnostic tool existed for the other three products or downstream repos to reuse.
- **MP2 — the 13-class table was unenforced:** `skills/bubbles-cross-platform-shell/SKILL.md` § *Pitfall → Portable Form* and `instructions/wsl-macos-compatibility.instructions.md` § *Forbidden GNU-only Forms* enumerate 13 construct classes, but nothing mechanically blocked a regression. `shellcheck -x` is necessary-but-insufficient (it does not model BSD vs GNU runtime divergence — e.g. `sed -i` / `date -d` / `paste -sd` behave differently, not wrongly, on BSD).
- **MP3 — no framework selftest:** there was no hermetic selftest wired into `framework-validate.sh` proving the portability contract (one adversarial red fixture per class + a clean green fixture) the way IMP-017 wired `case-collision-guard`.

## Proposal

### SCOPE-1 — Reusable, portable-by-design guard (MP1, MP2) — ✅ IMPLEMENTED

`bubbles/scripts/macos-portability-guard.sh`: a self-contained lint that takes the scan surface as CLI args (files/dirs; dirs searched for `*.sh`) and/or the `PORTABILITY_SCAN_PATHS` env var. It has **NO default surface** — with none it prints usage and exits 2 — and is deliberately never pointed at the framework's own `bubbles/scripts/` (those intentionally use raw `timeout`/`sed -i` mediated by `guard-lib.sh` + the `framework-validate` PATH shim). Detects all 13 classes: raw `timeout`, `sed -i`, `date -d`, `stat -c`, `readlink -f`, `grep -P`, `[[ -v ]]`, `mapfile`/`readarray`, `mktemp --suffix`, `df --output`, `/bin/true`·`/bin/false`, `paste -sd` w/o explicit `-` stdin operand, `date +%s%N`. Helper-aware (lines routed through `bubbles_run_with_timeout`/`bubbles_sed_inplace`/… or carrying a BSD fallback are not violations) and honors an inline `# portable-ok:<reason>` pragma (same line or the line above); full-line comments are stripped before scanning. Exit 1 on any violation (each printed `file:line` + a one-line remedy), 0 clean, 2 usage. Portable per `bubbles-cross-platform-shell` (`#!/usr/bin/env bash`, `set -euo pipefail`, POSIX awk, `LC_ALL=C sort`, no GNU-only form in its own source — proven by scanning the guard with the guard). No bypass flag.

### SCOPE-2 — Hermetic selftest (MP3) — ✅ IMPLEMENTED

`bubbles/scripts/macos-portability-guard-selftest.sh`: a GREEN fixture (portable helpers/forms + a same-line `# portable-ok:` pragma + a pragma-on-the-line-above + a `BASH_VERSINFO`-guarded `mapfile` + a full-line comment that MENTIONS raw constructs) passes; one adversarial RED fixture PER class (each reintroducing exactly one GNU-only form) fails and NAMES that class; plus directory-recursion, `PORTABILITY_SCAN_PATHS`, usage-error, and guard-self-portability (`bash -n`, guard-scans-guard → 0, comment-stripped literal-GNU-form grep → none) assertions. Throwaway `/tmp` fixtures, cleaned on exit; SKIP + exit 0 if a required POSIX tool is genuinely absent.

### SCOPE-3 — Wire the selftest into framework-validate (MP3) — ✅ IMPLEMENTED

`bubbles/scripts/framework-validate.sh`: a `run_check` (with the `..._timeout_seconds` variable convention) runs the **selftest** — NOT a scan of the framework's own scripts — registered next to the sibling `case-collision-guard` cross-platform checks.

### SCOPE-4 — Doc pointers (framework copies only) — ✅ IMPLEMENTED

`skills/bubbles-cross-platform-shell/SKILL.md` (new § *Mechanical Enforcement*: how to run the guard, the `# portable-ok:` pragma, downstream-wires-its-own-surface), `instructions/wsl-macos-compatibility.instructions.md` (new § *Mechanical Enforcement*: advisory-until-wired per repo; framework runs the selftest), `skills/INVENTORY.md` (cross-platform-shell row refreshed). No product-repo copy was touched.

## Migration / rollout

All changes are additive and land in one commit. The guard is inert until a caller passes it a surface; downstream repos opt in by wiring it into their existing pre-push/lint gate against their OWN operator script surface (advisory-until-wired). The release manifest is regenerated because two new tracked scripts change the managed-file set. No downstream/product repo is edited; on the next framework sync the guard + selftest propagate normally.

## Risks & mitigations

- **R1** The guard false-positives on the framework's own raw-`timeout`/`sed -i` scripts → mitigated by DESIGN: no default surface, and `framework-validate` runs the guard's SELFTEST, never a scan of `bubbles/scripts/`.
- **R2** The guard's own detector strings (which must name the forbidden constructs) self-flag when it scans itself → mitigated by writing every class pattern with `[[:space:]]`/alternation so the source never self-matches; proven by the selftest asserting guard-scans-guard → exit 0 and a comment-stripped literal-GNU-form grep → none.
- **R3** A legitimate intentional raw usage (Docker-internal entrypoint, curl `--connect-timeout`) is flagged → the inline `# portable-ok:<reason>` pragma exempts it; there is no blanket bypass, so the exemption is auditable per line.
- **R4** IMP numbering: `improvements/` shows IMP-001..006 + IMP-017 (delivered IMP docs are deleted-on-delivery; IMP-007 is permanently assigned to `regen-derived.sh`). This proposal takes the next FREE number after IMP-017, **IMP-018**.

## Acceptance criteria

- `bash bubbles/scripts/macos-portability-guard.sh` with no surface exits 2; with a clean surface exits 0; with a surface containing any of the 13 classes exits 1 naming the class.
- `bash bubbles/scripts/macos-portability-guard.sh bubbles/scripts/macos-portability-guard.sh` exits 0 (guard is self-portable).
- `bash bubbles/scripts/macos-portability-guard-selftest.sh` passes (green clean, every red fixture caught, self-portability assertions green).
- `shellcheck -S warning -x` is clean on both scripts.
- `framework-validate.sh --list-tier=full` enumerates `macOS portability guard selftest (bubbles-cross-platform-shell)`, and the selftest passes via the wired `timeout … bash …` path.

## Files to touch (on approval)

`bubbles/scripts/macos-portability-guard.sh` + `bubbles/scripts/macos-portability-guard-selftest.sh` (new guard + selftest), `bubbles/scripts/framework-validate.sh` (wire the selftest via `run_check`), `skills/bubbles-cross-platform-shell/SKILL.md` + `instructions/wsl-macos-compatibility.instructions.md` (Mechanical Enforcement sections), `skills/INVENTORY.md` (row refresh), `bubbles/release-manifest.json` (regenerated), `improvements/INDEX.md` (register this IMP). Owning surface: `framework-health` (G125).
