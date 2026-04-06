# Bug Fix Design: [BUG-001]

## Root Cause Analysis

### Investigation Summary
- Scope 05 lists real implementation files in `specs/001-competitive-framework-parity/scopes.md`, including `bubbles/interop-registry.yaml`, multiple `bubbles/scripts/*.sh` surfaces, `bubbles/release-manifest.json`, `install.sh`, and docs updates.
- Running `timeout 180 bash .github/bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose` exits with `ZERO_FILES_RESOLVED`.
- The historical discovery rule only extracted backticked paths ending in `rs|ts|tsx|js|jsx|py|go|java|dart|scala|brs`, and it harvested backtick-wrapped candidates too broadly instead of staying anchored to the declared implementation inventory.
- The final repair was applied to `bubbles/scripts/implementation-reality-scan.sh` after restoring that source file from the clean baseline.

### Root Cause
Reality-scan discovery had two coupled defects. The primary defect was language-extension gating instead of implementation-inventory gating, which prevented legitimate shell, registry, manifest, and docs-heavy files from entering the scan set. The secondary defect was over-broad backtick harvesting, which let discovery look beyond the declared implementation inventory contract instead of only honoring the intended implementation file listing.

### Impact Analysis
- Affected components: `implementation-reality-scan.sh`, `state-transition-guard.sh` Gate G028 flow, and any framework scope whose implementation inventory is dominated by shell, YAML, JSON, or docs surfaces.
- Affected data: Validation and certification evidence only.
- Affected users: Bubbles framework maintainers and downstream evaluators who rely on honest certification.

## Fix Design

### Solution Approach
Repair upstream discovery so implementation inventories declared in scope or design artifacts can include legitimate shell, registry, manifest, and docs-heavy framework surfaces when those files exist on disk, while also constraining harvesting to the declared inventory instead of every backtick-wrapped token in the packet. Preserve the zero-files block for scopes that truly do not declare any real implementation files.

### Final Repair Shape
1. Restore `bubbles/scripts/implementation-reality-scan.sh` from the clean baseline before applying the final patch so the fix lands on a known-good source surface.
2. Limit scope-file implementation harvesting to the `### Implementation Files` section instead of sweeping every backtick-wrapped candidate from the full scope artifact.
3. Expand the implementation discovery pattern to include `.sh`, `.yaml`, `.yml`, `.json`, and `.md` so declared shell-heavy inventories resolve when the files exist on disk.
4. Keep the `design.md` fallback as a bounded fallback path rather than replacing scope-owned inventory truth.

### Closure Notes
- Current-session evidence shows `implementation-reality-scan-selftest.sh`, the live `implementation-reality-scan.sh specs/001-competitive-framework-parity --verbose` rerun, `generate-release-manifest.sh`, `release-manifest-selftest.sh`, and `framework-validate.sh` all passing.
- These notes close the root-cause and repair-shape analysis only. They do not claim validate-owned certification, verification, or bug closure.

### Alternative Approaches Considered
1. Add fake `.rs`, `.py`, or `.js` wrapper entries to `scopes.md`.
   Rejected because it fabricates coverage and weakens the reality-scan contract.
2. Create temporary shim files solely to satisfy the current extension allowlist.
   Rejected because artificial supported-language wrappers are forbidden.
3. Patch `.github/bubbles/scripts/implementation-reality-scan.sh` during Scope 05 delivery.
   Rejected because framework-managed files require explicit upstream bug ownership and tracked fix flow.