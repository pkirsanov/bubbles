# Test Fidelity

Purpose: canonical source for planned-behavior fidelity and use-case-centered testing.

## Rules
- Tests validate `spec.md`, `design.md`, scope artifacts, and DoD.
- Do not weaken tests to match broken implementation.
- If the plan is wrong, correct the owning planning artifact first, then align test and implementation together.
- Required tests must prove real user or API-consumer behavior, not proxy signals.
- Changed behavior needs red then green proof.
- Live-state tests that create or mutate data must use agent-owned fixtures, not borrowed shared fixtures.
- Write paths must not target "first existing" resources from list endpoints unless the scenario is explicitly read-only.
- Shared defaults, host-level settings, and other cross-scenario baseline state require snapshot-and-restore proof before a mutation test can claim completion.
