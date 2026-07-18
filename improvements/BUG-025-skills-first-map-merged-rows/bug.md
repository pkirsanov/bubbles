# Bug: BUG-025 Skills-First Map Merged Rows

## Summary

`skills/bubbles-skills-first-discovery/SKILL.md` contains two malformed
Markdown table lines that each combine two independent situation-to-skill
mappings with `| ||`. The first merges scope-workflow-runtime with
feature-template; the second merges fix-cycle-protocol with skill-authoring.
Markdown consumers can treat each malformed line as one over-wide row, so two
situations are not represented as valid independent map entries.

## Severity

- [ ] Critical - Framework cannot run
- [ ] High - Unsafe state or delivery corruption
- [x] Medium - Skills-first discovery can omit or misparse four routing entries
- [ ] Low - Cosmetic formatting only

## Status

- [x] Reported
- [x] Confirmed by current source inspection
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Current-Truth Source Evidence

**Claim Source:** interpreted

**Interpretation:** The canonical skill file was read with an editor file tool
from the clean clone at `origin/main` commit `aa78e91`. No Markdown parser,
test, lint, or framework-validation command was run.

The current `Situation -> Skill map` contains these malformed physical lines:

```text
| Author or revise `scopes.md` / `scopes/*/scope.md` | `bubbles-scope-workflow-runtime` || Creating or refreshing a feature folder | `bubbles-feature-template` |
| Running a fix-cycle round; finding-set closure | `bubbles-fix-cycle-protocol` || Write or extend a Bubbles skill | `bubbles-skill-authoring` |
```

Each physical line should instead be two valid two-column rows, yielding four
independent mappings.

## Reproduction Steps

1. Read the `Situation -> Skill map` table in
   `skills/bubbles-skills-first-discovery/SKILL.md`.
2. Locate the scope-authoring/feature-folder line and the fix-cycle/skill-
   authoring line.
3. Count Markdown cells or separators on each physical line.
4. Observe that each line encodes four logical cells after the normal two-cell
   row has already closed.
5. Observe that no deterministic structural regression currently guarantees
   row cardinality, situation uniqueness, target resolution, or separator
   integrity.

## Expected Behavior

The map contains four independent valid rows:

| Situation | Skill target |
| --- | --- |
| Author or revise `scopes.md` / `scopes/*/scope.md` | `bubbles-scope-workflow-runtime` |
| Creating or refreshing a feature folder | `bubbles-feature-template` |
| Running a fix-cycle round; finding-set closure | `bubbles-fix-cycle-protocol` |
| Write or extend a Bubbles skill | `bubbles-skill-authoring` |

A deterministic parser regression validates every map row and fails on:

- wrong row cardinality;
- duplicate normalized situations;
- unknown skill targets;
- data-like lines missing table separators; and
- the exact merged-row shape represented by a fixture.

## Actual Behavior

Two physical lines each contain two mappings. Consumers that expect exactly
two columns may ignore trailing cells, merge text incorrectly, or reject the
table, weakening discovery for all four situations.

## Impact

- Scope authoring may not route to `bubbles-scope-workflow-runtime` reliably.
- Feature-folder creation may not route to `bubbles-feature-template`.
- Fix-cycle work may not route to `bubbles-fix-cycle-protocol`.
- Skill creation may not route to `bubbles-skill-authoring`.
- Future malformed rows can recur unnoticed because current validation lacks a
  structural map contract.

## Root-Cause Hypothesis

Two adjacent mappings were appended onto existing Markdown rows rather than
inserted as new lines. Review focused on visible tokens rather than parsed row
shape, and no parser regression bound the map to a two-column schema.

## Change Boundary And Exact Owners

| Surface | Owner | Authorized responsibility |
| --- | --- | --- |
| `design.md` | `bubbles.design` | Confirm structural parser and fail-closed target-resolution design. |
| `scopes.md`, `scenario-manifest.json`, `test-plan.json`, `uservalidation.md` | `bubbles.plan` | Reconcile the one-scope executable plan and parity. |
| `skills/bubbles-skills-first-discovery/SKILL.md` | `bubbles.implement` | Split exactly two malformed lines into four rows. |
| `tests/regression/test_32_skills_first_map_merged_rows.sh` | `bubbles.test` | Own parser, fixtures, RED/GREEN, and adversarial cases. |
| Regression registration and install provenance | `bubbles.test` | Register focused source-only coverage after GREEN. |
| Generated release identity | `bubbles.releases` | Reconcile final stable bytes. |
| `state.json::certification.*` and terminal status | `bubbles.validate` | Independently certify after complete evidence. |

This intake creates only this packet. It does not authorize source, test,
generated-manifest, `BUGS.md`, `improvements/INDEX.md`, commit, push, or
downstream changes.

## Related Files

- `skills/bubbles-skills-first-discovery/SKILL.md`
- `skills/bubbles-scope-workflow-runtime/SKILL.md`
- `skills/bubbles-feature-template/SKILL.md`
- `skills/bubbles-fix-cycle-protocol/SKILL.md`
- `skills/bubbles-skill-authoring/SKILL.md`
