# Fixture Scopes: Missing Inventory

## Scope 01: Missing Inventory

**Status:** [~] In Progress

### Implementation Files

- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/missing-inventory-feature/scripts/missing-import.sh`
- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/missing-inventory-feature/config/missing-registry.yaml`
- `specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/missing-inventory-feature/docs/missing-guide.md`

### Test Plan

| Row ID | Scenario ID | Test Type | Category | File/Location | Description | Command | Live System |
| --- | --- | --- | --- | --- | --- | --- | --- |
| FX-002 | SCN-BUG-001-02 | Regression E2E | e2e-api | `bubbles/scripts/implementation-reality-scan.sh` | Missing-inventory fixture keeps ZERO_FILES_RESOLVED blocking when no declared files exist on disk. | `timeout 180 bash bubbles/scripts/implementation-reality-scan.sh specs/001-competitive-framework-parity/bugs/BUG-001-shell-heavy-reality-scan-discovery-gap/fixtures/missing-inventory-feature --verbose` | Yes |