# Fixture Scopes: Shell-Heavy Discovery

## Scope 01: Honest Shell-Heavy Inventory

**Status:** [~] In Progress

### Implementation Files

- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/shell-heavy-feature/scripts/review_only_import.sh`
- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/shell-heavy-feature/config/interop-registry.yaml`
- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/shell-heavy-feature/config/source-map.yml`
- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/shell-heavy-feature/release/release-manifest.json`
- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/shell-heavy-feature/docs/review-only-intake.md`

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FX-001 | SCN-BUG-001-01 | Regression E2E | e2e-api | `bubbles/scripts/implementation-reality-scan.sh` | Shell-heavy fixture resolves real implementation inventory without shim files. | `timeout 180 bash bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/shell-heavy-feature --verbose` | Yes |