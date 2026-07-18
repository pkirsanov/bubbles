# User Validation: BUG-024 Traceability Sequential Scope And Tiered DoD

Evidence source: [report.md](report.md)

## Checklist

Checked entries describe the accepted contract and reproduced intake baseline.
They do not claim implementation, test GREEN, release readiness, downstream
installation, or validate-owned certification.

### Reproduced Baseline

- [x] **Baseline:** The current canonical guard checks all nine Feature 007
  scope files and exits `1` with 37 findings.
  - **Evidence:** [Before Fix](report.md#bug-reproduction---before-fix)
- [x] **Baseline:** Scope 01's four scenario-to-row, concrete-file, and report
  evidence paths succeed before descendant findings are emitted.
  - **Evidence:** [Before Fix](report.md#bug-reproduction---before-fix)
- [x] **Baseline:** G068 reports zero fidelity scenarios because each tiered
  DoD is truncated at its first deeper heading.
  - **Evidence:** [Canonical Source Inspection](report.md#canonical-source-inspection)

### Sequential Applicability Contract

- [x] **SCN-BUG-024-001:** Current-scope closure omits only exact not_started
  transitive descendants while current and completed prerequisites remain.
  - **Verify:** `T-BUG-024-001`.
- [x] **SCN-BUG-024-002:** A completed prerequisite gap remains blocking.
  - **Verify:** `T-BUG-024-002`.
- [x] **SCN-BUG-024-003:** Independent not_started scopes and
  in_progress/blocked/done descendants remain visible, as do all-scope gaps.
  - **Verify:** `T-BUG-024-003`.
- [x] **SCN-BUG-024-004:** Canonical certification registry entries and
  numeric, digit-string, and scopeId currentScope aliases map one-to-one.
  - **Verify:** `T-BUG-024-004`.
- [x] **SCN-BUG-024-005:** A present execution registry has closed precedence
  and is cross-checked against certification; contradictions refuse.
  - **Verify:** `T-BUG-024-005`.
- [x] **SCN-BUG-024-006:** Malformed JSON/types/aliases/status/dependencies and
  cycles refuse before any partial universe.
  - **Verify:** `T-BUG-024-006`.
- [x] **SCN-BUG-024-007:** Unsafe paths, filesystem mismatch, and completion
  mismatch refuse without fallback.
  - **Verify:** `T-BUG-024-007`.
- [x] **SCN-BUG-024-008:** Terminal status and validate/audit/finalize context
  refuse current-scope evaluation.
  - **Verify:** `T-BUG-024-008`.
- [x] **SCN-BUG-024-009:** Duplicate, conflicting, valued, unknown, additional,
  and bypass-shaped CLI arguments refuse with usage exit `2`.
  - **Verify:** `T-BUG-024-009`.
- [x] **SCN-BUG-024-010:** Per-directory mapping and provable numbered
  single-file mapping work; ambiguous mapping refuses.
  - **Verify:** `T-BUG-024-010`.
- [x] **SCN-BUG-024-011:** No-scenario findings follow applicability and remain
  visible under all-scope execution.
  - **Verify:** `T-BUG-024-011`.

### Tiered DoD Contract

- [x] **SCN-BUG-024-012:** DoD starts at depths 1-4 retain deeper tiers through
  depth 6; depths 5/6 are not accepted starts.
  - **Verify:** `T-BUG-024-012`, `T-BUG-024-015`.
- [x] **SCN-BUG-024-013:** Same/shallow boundaries, fenced/comment false
  starts, rowless, missing, ambiguous, and read failure remain distinct.
  - **Verify:** `T-BUG-024-013`, `T-BUG-024-015`.

### Integration And Delivery Contract

- [x] **SCN-BUG-024-014:** One applicable projection feeds G057/G059, Test
  Plan, physical path, report evidence, and traceability G068 passes.
  - **Verify:** `T-BUG-024-017`, `T-BUG-024-023`, `T-BUG-024-026`.
- [x] **SCN-BUG-024-015:** State-transition Check 4A/22 shares selected-depth
  DoD semantics, remains all-scope, and preserves G068 thresholds.
  - **Verify:** `T-BUG-024-018`, `T-BUG-024-024`.
- [x] **SCN-BUG-024-016:** BUG-018 packet and test_25 bytes remain unchanged
  and its heading-depth regression stays green.
  - **Verify:** `T-BUG-024-019`.
- [x] **SCN-BUG-024-017:** Managed, done-spec, validate, audit, finalize, and
  direct default consumers remain all-scope.
  - **Verify:** `T-BUG-024-020`, `T-BUG-024-025`, `T-BUG-024-026`.
- [x] **SCN-BUG-024-018:** macOS system Bash 3.2 and supported Linux behavior
  remain equivalent across the exact changed shell surface.
  - **Verify:** `T-BUG-024-021`, `T-BUG-024-027`, `T-BUG-024-032`.
- [x] **SCN-BUG-024-019:** Registration, provenance, capability docs, release,
  supported upgrade, and canonical/installed current/all replay agree.
  - **Verify:** `T-BUG-024-022`, `T-BUG-024-033` through `T-BUG-024-040`.

### Safety And Delivery Boundary

- [x] **No bypass:** No scope ID, ignore list, skip, force, allow-once, status
  override, or permissive fallback is part of the accepted contract.
- [x] **Portability:** macOS system Bash 3.2 and supported Linux Bash are
  required before completion.
- [x] **Canonical-only planning:** This invocation changes only the BUG-024 packet
  and leaves source, tests, release metadata, existing bugs, and Research Lab
  unchanged.
  - **Evidence:** [Containment](report.md#containment)
