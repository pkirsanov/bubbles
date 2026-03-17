---
agent: bubbles.chaos
---

Run chaos-style live-system scenario execution using Playwright browser automation and HTTP API probes.

**Execution method (MANDATORY):**
1. Load the `chaos-execution` skill (`.github/skills/chaos-execution/SKILL.md`) for project-specific Playwright config, routes, selectors, endpoints, and startup commands.
2. Start the live system using instructions from the skill (synthetic data mode preferred).
3. Discover routes, selectors, and endpoints using the skill's discovery commands.
4. Create temporary Playwright test files with stochastic user behavior (random navigation, rapid clicking, toggling, interactions, back/forward stress, cross-feature journeys).
5. Run them using the chaos run command from the skill.
6. Capture raw Playwright terminal output as evidence.
7. Clean up temporary test files after the run.

**PROHIBITED:** Do NOT run lint, existing test suites, or build commands as a substitute for chaos execution. Chaos means generating NEW random user behavior and executing it via Playwright against the live UI and/or API.
