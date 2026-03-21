# E2E Regression

Purpose: canonical source for regression permanence requirements.

## Rules
- Every changed or fixed behavior needs persistent scenario-specific E2E regression coverage.
- A broad rerun of existing suites is not enough by itself.
- UI changes require user-visible assertions; API changes require consumer-visible behavior checks.
- Rename/removal work requires consumer-facing regression coverage, not just producer-surface checks.
