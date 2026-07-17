# User Validation: BUG-012 G085 First-Adoption Deadlock

Evidence source: [report.md](report.md)

## Checklist

Checked items record the user-visible acceptance baseline included in the plan. They do not claim implementation completion or executed delivery evidence; those claims remain gated by [scopes.md](scopes.md) and [report.md](report.md).

### Planning Baseline

- [x] **Baseline:** The canonical Bubbles repository owns this repair; downstream installed `.github/bubbles/**` copies and `certification.*` remain outside implementation ownership.
  - **Basis:** Ratified change boundary in [design.md](design.md) and [scopes.md](scopes.md).

### Permitted Success Paths

- [x] **What:** A genuinely first adopted repository can advance its first current numbered feature without fabricated done history.
  - **Steps:** Run the production G085 guard against a full, exact-root Git fixture with one or more valid current numbered nonterminal states, zero current done states, and no historical numbered done blob across any reachable ref.
  - **Expected:** Exit `0` with `G085-FIRST-ADOPTION`, `currentDone=0`, `historicalDone=0`, and `historyIntegrity=complete`.
  - **Verify:** Focused guard selftest and persistent G085 regression.
  - **Evidence:** [report.md](report.md)

- [x] **What:** Ordinary current dogfood evidence remains the fast path.
  - **Steps:** Run the production G085 guard against a downstream fixture with at least one valid current numbered state whose exact top-level status is `done`.
  - **Expected:** Exit `0` with `G085-CURRENT-DONE` without requiring history classification.
  - **Verify:** Focused guard selftest and framework validation.
  - **Evidence:** [report.md](report.md)

### Existing Repository Enforcement

- [x] **What:** An established repository cannot re-enter bootstrap by changing or deleting its current done state.
  - **Steps:** Compare real Git fixtures with identical current numbered nonterminal states: one with no reachable historical done blob and one with a prior numbered done blob that was changed or deleted.
  - **Expected:** Only clean history passes; reachable prior done history exits `1` with `E085-ESTABLISHED-DONE-REMOVED` and identifies the commit/path without printing state content.
  - **Verify:** Focused guard selftest and adversarial persistent regression.
  - **Evidence:** [report.md](report.md)

- [x] **What:** State-transition failure guidance describes both valid downstream G085 pass paths.
  - **Steps:** Force delegated G085 failure guidance to render after installing the canonical change.
  - **Expected:** The guidance names ordinary current-done evidence and proven first adoption; it does not claim that a current done spec is the only valid downstream path.
  - **Verify:** Focused guard selftest and full framework validation.
  - **Evidence:** [report.md](report.md)

### Fail-Closed Evidence Integrity

- [x] **What:** Missing or incomplete repository history cannot be mistaken for zero historical done evidence.
  - **Steps:** Run the production guard against missing/non-root Git metadata, an effective shallow clone, separate `extensions.partialClone` and `remote.*.promisor=true` fixtures, and forced commit/tree/blob traversal failures.
  - **Expected:** Exit `2` with `E085-HISTORY-UNAVAILABLE`, `E085-HISTORY-SHALLOW`, `E085-HISTORY-PARTIAL`, or `E085-HISTORY-QUERY-FAILED` as applicable.
  - **Verify:** Focused guard selftest plus persistent incomplete-history regression.
  - **Evidence:** [report.md](report.md)

- [x] **What:** Invalid current or historical numbered state JSON fails distinctly.
  - **Steps:** Run the production guard against malformed current state JSON and separately against a reachable malformed historical numbered state with a valid current nonterminal state.
  - **Expected:** Exit `2` with `E085-CURRENT-STATE-MALFORMED` or `E085-HISTORICAL-STATE-MALFORMED` respectively.
  - **Verify:** Focused guard selftest.
  - **Evidence:** [report.md](report.md)

- [x] **What:** An empty current numbered-spec inventory is not a bootstrap transition.
  - **Steps:** Run the production guard against a full Git repository with no current numbered `state.json`.
  - **Expected:** Exit `1` with `E085-NO-CURRENT-SPEC`.
  - **Verify:** Focused guard selftest.
  - **Evidence:** [report.md](report.md)

### Source and Propagation Invariance

- [x] **What:** Canonical source-repository behavior remains unchanged.
  - **Steps:** Run source-clean and source-with-persistent-`specs/` canaries through the production guard and full framework validation.
  - **Expected:** Existing source evidence passes; a persistent source `specs/` tree remains prohibited.
  - **Verify:** Focused guard selftest and framework validation.
  - **Evidence:** [report.md](report.md)

- [x] **What:** Downstream consumers receive the repair only through the canonical framework release/install/upgrade path.
  - **Steps:** After canonical release validation, use the standard downstream upgrade flow, then run framework write guard and the installed G085 guard.
  - **Expected:** The installed guard reports the same decision contract with zero manual managed-copy edits or drift.
  - **Verify:** Downstream framework write guard, installed guard, and original transition command.
  - **Evidence:** [report.md](report.md)
