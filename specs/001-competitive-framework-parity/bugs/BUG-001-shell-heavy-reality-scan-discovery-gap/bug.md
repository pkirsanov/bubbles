# Bug: [BUG-001] Shell-Heavy Reality Scan Discovery Gap

## Summary
The framework reality scan historically blocked Scope 05 with `ZERO_FILES_RESOLVED` even though the scope listed real on-disk implementation surfaces. The root failure was in the discovery path: it both extension-gated legitimate shell-heavy inventory out of the scan set and harvested backtick-wrapped candidates too broadly. The repaired source surface in `bubbles/scripts/implementation-reality-scan.sh` now resolves the declared shell/YAML/JSON/docs-heavy inventory honestly, but validate-owned closure is still pending.

## Severity
- [ ] Critical - System unusable, data loss
- [x] High - Major feature broken, no workaround
- [ ] Medium - Feature broken, workaround exists
- [ ] Low - Minor issue, cosmetic

## Status
- [x] Reported
- [x] Confirmed (reproduced)
- [ ] In Progress
- [x] Fixed
- [ ] Verified
- [ ] Closed

## Reproduction Steps
1. From `/home/philipk/bubbles`, run `timeout 180 bash .github/bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose`.
2. Inspect Scope 05 in `specs/001-competitive-framework-parity/scopes.md` and confirm it lists real implementation files such as `bubbles/interop-registry.yaml`, `bubbles/scripts/cli.sh`, `bubbles/scripts/interop-intake.sh`, `bubbles/release-manifest.json`, `install.sh`, and docs surfaces.
3. Observe the scan exits with `ZERO_FILES_RESOLVED` after the design fallback also resolves nothing.

## Expected Behavior
The framework reality scan resolves legitimate on-disk implementation inventories for shell, YAML, JSON, and docs-heavy scopes when those files are intentionally declared in scope artifacts. It must preserve blocking behavior for truly missing inventories, but it must not require shim code files or artificial supported-language wrappers.

## Actual Behavior
The discovery regex only resolves backticked paths ending in `rs|ts|tsx|js|jsx|py|go|java|dart|scala|brs`, so Scope 05's real inventory stays invisible and certification is blocked with `ZERO_FILES_RESOLVED`.

## Current State
- The repaired source surface is `bubbles/scripts/implementation-reality-scan.sh`.
- Current-session reruns supplied with this packet show the dedicated selftest, the live feature scan, release-manifest refresh/selftest, and the broader framework validation chain all passing.
- This bug packet does not claim validate-owned verification or closure yet.

## Environment
- Service: Bubbles framework validation tooling
- Version: Current workspace state on 2026-04-04
- Platform: Linux

## Error Output
```text
$ cd /home/philipk/bubbles && timeout 180 bash .github/bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose
ℹ️  INFO: Scopes yielded 0 files — falling back to design.md for file discovery
🔴 VIOLATION [ZERO_FILES_RESOLVED] No implementation file paths resolved from scope files

  This means scopes.md / scope.md files either:
    1. Do not reference implementation files in backtick-wrapped paths, or
    2. Reference files that do not exist on disk

  Scanning nothing = no assurance. This is a blocking failure.
  Fix: Ensure scopes.md lists implementation files as `path/to/file.rs`

============================================================
  REALITY SCAN RESULT: 1 violation(s), 0 warning(s)
  Files scanned: 0
============================================================

Command exited with code 1
```

## Root Cause (filled after analysis)
The final analysis found two coupled defects in the discovery path. First, the implementation discovery pattern was extension-gated instead of inventory-truth-gated, so `.sh`, `.yaml`, `.yml`, `.json`, and `.md` surfaces were ignored even when scopes intentionally declared them as implementation-bearing files. Second, the harvesting approach was too broad because it treated backtick-wrapped path candidates outside the declared implementation inventory as discovery input. The final repair constrained harvesting back to the intended inventory contract while expanding legitimate shell-heavy file support.

## Repair Summary
- The source file `bubbles/scripts/implementation-reality-scan.sh` was restored from the clean baseline before the final patch was applied.
- The final patch constrained scope-file harvesting to the declared implementation inventory and expanded the supported implementation extensions to include `.sh`, `.yaml`, `.yml`, `.json`, and `.md` when those files exist on disk.
- The evidence for this bug packet is bounded to the current-session reruns named in `report.md`; validate-owned certification and closure remain outstanding.

## Forbidden Non-Solutions
- Do not add temporary shim files or artificial `.rs`/`.py`/`.js` wrapper paths just to satisfy discovery.
- Do not add fake supported-language entries to `scopes.md` that do not reflect the real implementation inventory.
- Do not patch `.github/bubbles/scripts/implementation-reality-scan.sh` opportunistically during unrelated feature delivery.

## Related
- Feature: `specs/001-competitive-framework-parity/`
- Related bugs: None
- Related PRs: None