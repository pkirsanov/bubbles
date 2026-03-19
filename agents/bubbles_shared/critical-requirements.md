<!-- governance-version: 2.2.0 -->
# Bubbles Critical Requirements (Project-Agnostic)

> **Purpose:** Define hard, universal, non-negotiable implementation and testing requirements for all `bubbles.*` agents.
>
> **Scope:** Portable across projects. Contains no project-specific commands, paths, ports, or stack assumptions.
>
> **Priority:** **TOP PRIORITY**. If any instruction conflicts with this file, this file wins unless a stricter safety or legal policy applies.

---

## Absolute Policy Set (Non-Negotiable)

1. **Use-Case Truthfulness**
   - All tests MUST validate defined use cases and required behavior exactly as specified.
   - Tests that do not validate required outcomes are invalid for completion.

2. **Real Code Execution in Tests**
   - Tests MUST execute actual production code paths.
   - Mocks are allowed only for true external dependencies (third-party APIs, external services, non-owned infrastructure boundaries).
   - Internal business logic, internal modules, and owned service boundaries MUST NOT be mocked when validating integration or end-to-end behavior.

3. **Zero Fabrication / Zero Hallucination**
   - Never fabricate test status, output, evidence, files, commands, or completion claims.
   - Never claim pass/fail or completion without current-session execution evidence.

4. **No TODO Debt / No Deferral Language**
   - Never leave `TODO`, `FIXME`, placeholders, or deferred implementation markers.
   - If full implementation cannot be completed, do not mark the work complete.
   - **NEVER write deferral language** into DoD items, scope files, or report files:
     - FORBIDDEN: "deferred", "future scope", "follow-up", "out of scope", "will address later", "separate ticket", "punt", "postpone", "skip for now", "not implemented yet", "placeholder", "temporary workaround"
   - Deferral language in artifacts = spec CANNOT be marked "done" (mechanically enforced by state-transition-guard Gate G040).
   - If a DoD item cannot be completed: fix the issue NOW, remove the item with justification, or leave status as "In Progress".

5. **No Stubs**
   - Stub implementations are forbidden in production and completion-bound test code.
   - Replace all stubs with full, working implementations before completion.

6. **No Fake/Sample Data in Verification**
   - Do not use fake/sample/demo/placeholder data as proof of real behavior in required validation.
   - Required tests must use realistic, representative data sources appropriate to the test category.

7. **No Defaults**
   - Do not hide missing configuration or required inputs using defaults.
   - Missing required values must fail explicitly.

8. **No Fallbacks — Fail Fast**
   - Do not mask failures with fallback branches that simulate success.
   - Surface errors immediately with explicit failure paths.

9. **Full-Fidelity Implementation Required**
   - Do not simplify away required behavior, edge cases, error handling, or domain constraints.
   - Implement complete feature behavior with production-quality robustness.

10. **No Shortcuts**
    - No partial implementation presented as complete.
    - No reduced-scope tests presented as full validation.
    - No incomplete docs for completed work; documentation must match shipped behavior.

---

## Enforcement Rules

- A scope/feature/bug cannot be marked complete if any policy above is violated.
- Evidence must be execution-backed, current-session, and specific to claimed outcomes.
- Optional or proxy assertions cannot substitute for required behavior checks.
- If uncertainty exists, agent must report uncertainty and keep status in progress instead of inventing conclusions.

## Detection Scans (MANDATORY before marking scope "Done")

These scans enforce policies 4-8 mechanically. Agents MUST run the implementation reality scan which covers all of these:

```bash
# Run the comprehensive reality scan (covers stubs, fakes, hardcoded data, defaults, fallbacks)
bash .github/bubbles/scripts/implementation-reality-scan.sh {FEATURE_DIR} --verbose
# Exit code 0 = pass, Exit code 1 = BLOCKED
```

### What the scan detects:

| Policy | Scan | Patterns Detected |
|--------|------|-------------------|
| No Stubs (5) | Scan 1 | `fn fake_/mock_/stub_/placeholder_`, `generate_fake/mock/stub`, static RESPONSES/ITEMS arrays |
| No Fake Data (6) | Scan 1+2 | `MOCK_DATA`, `SAMPLE_DATA`, `getSimulationData()`, `useMockData()`, import mock modules |
| No Defaults (7) | Scan 5 | `unwrap_or()`, `unwrap_or_default()`, `\\|\\| "default"`, `?? "fallback"`, `os.getenv("K", "default")` |
| No Fallbacks (8) | Scan 5 | Same as defaults — any pattern that masks missing config with a silent value |
| Real Implementation (9) | Scan 3 | Data hooks/services with ZERO fetch/axios/API calls — returning hardcoded data |

**If the reality scan exits with code 1, the scope CANNOT be "Done". Fix ALL violations first.**

---

## Completion Gate (Mandatory)

Before reporting completion, all answers must be **YES**:

1. Did tests validate the defined use cases and required outcomes?
2. Did required tests execute real code paths (with mocks only for true external dependencies)?
3. Are all claims backed by actual current-session execution evidence?
4. Are there zero TODOs, stubs, fake/sample verification artifacts, defaults, and fallbacks masking failures?
5. Is the implementation full-featured, edge-case complete, high-quality, and documented without shortcuts?

If any answer is **NO**, completion is prohibited.
