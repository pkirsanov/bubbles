# Bug Fix Design: BUG-025 Skills-First Map Merged Rows

## Design Brief

### Current State

The situation map is intended to be a two-column Markdown table, but two lines
contain a complete second row after `||`. Human readers can infer the intended
four mappings; deterministic consumers cannot safely do so.

### Target State

The source contains four ordinary rows, and a small source-only parser validates
the entire map's shape and references. The parser fails closed on ambiguous
physical structure rather than trying to repair malformed input heuristically.

### Local Hypothesis And Discriminator

The defect is limited to two accidental line merges. Splitting those lines
should make the canonical map pass a strict two-column parser while an exact
copy of either current merged shape remains red. A parser fixture matrix is the
cheapest check that can disconfirm this hypothesis.

## Source Repair Design

`bubbles.implement` changes only
`skills/bubbles-skills-first-discovery/SKILL.md`:

1. Replace the scope/feature merged line with two rows in the same logical
   order.
2. Replace the fix-cycle/skill-authoring merged line with two rows in the same
   logical order.
3. Preserve every word, code span, target, surrounding row, heading, and
   rationale outside the insertion of two newline boundaries and canonical
   row delimiters.

No target names or situation wording need to change.

## Structural Parser Design

The test owner reserves
`tests/regression/test_32_skills_first_map_merged_rows.sh`. The regression uses
portable shell plus a deterministic text parser and must:

1. Locate exactly one `## Situation -> Skill map` section and its next level-2
   heading boundary.
2. Require one canonical two-cell header row and one canonical separator row.
3. Parse each physical data row with leading and trailing `|` delimiters and
   exactly two top-level cells. Backticks do not create additional cells.
4. Reject `||`, extra cells, missing leading/trailing delimiters, and data-like
   physical lines outside a valid row.
5. Normalize each situation by trimming and collapsing whitespace, then reject
   duplicates while reporting both row numbers.
6. Extract every backticked target from the target cell, require at least one,
   reject duplicates within a row, and resolve each to
   `skills/<target>/SKILL.md`.
7. Reject unrecognized non-target prose in the target cell except canonical
   comma separators between targets.
8. Report total parsed mappings and target references for the valid control.

## Adversarial Fixture Matrix

| Fixture | Required result |
| --- | --- |
| Canonical repaired table | Pass with all mappings retained and the four named situations independent. |
| Exact scope/feature `| ||` line | Fail row cardinality. |
| Exact fix-cycle/skill-authoring `| ||` line | Fail row cardinality. |
| Duplicate normalized situation on a new row | Fail uniqueness and name both rows. |
| Unknown `bubbles-does-not-exist` target | Fail target resolution. |
| Mapping line without leading or trailing separator | Fail separator integrity. |
| Three-cell ordinary row without doubled pipes | Fail row cardinality. |
| Two valid comma-separated targets | Pass and resolve both targets. |

Each invalid fixture runs independently in a disposable location. The
canonical source file remains unchanged by fixture execution.

## Change Boundary

### Packet-Creation Invocation

Only the nine files under this BUG-025 directory may be created. No skill
source, test, generated manifest, shared index, Git history, or downstream file
is in the current invocation boundary.

### Authorized Delivery Boundary

| Owner | Exact surface | Permitted work |
| --- | --- | --- |
| `bubbles.implement` | `skills/bubbles-skills-first-discovery/SKILL.md` | Split exactly two merged lines into four rows. |
| `bubbles.test` | `tests/regression/test_32_skills_first_map_merged_rows.sh` | Parser, fixture matrix, RED/GREEN, and mutations. |
| `bubbles.test` | Focused registration/provenance surfaces | Add source-only regression after GREEN. |
| `bubbles.releases` | Generated release identity | Reconcile stable final source/test inputs. |
| `bubbles.validate` | Certification fields and terminal status | Independent certification only. |

### Protected Surfaces

- every other byte in `bubbles-skills-first-discovery/SKILL.md`
- all target skill files
- unrelated tests and agents
- `BUGS.md` and `improvements/INDEX.md`
- product/downstream repositories and installed copies

## Preserved Contracts

- Existing table heading and two-column meaning.
- Existing mapping wording and target order.
- Multi-target rows such as configuration guidance.
- Skills-first rationale, authority links, and grandfather clause.
- No new dependency, API, UI, configuration, storage, or deployment change.

## Failure And Rollback

If the focused parser or fixture matrix fails, restore the skill file to its
exact pre-edit hash. Do not weaken cardinality, target resolution, or separator
rules to accept malformed source. Release identity changes only after focused
and broad checks settle.

## Owner Route

1. `bubbles.design` confirms strict parser boundaries and valid multi-target
   syntax.
2. `bubbles.plan` reconciles scenario/test/DoD parity.
3. `bubbles.test` captures final-byte RED against current merged rows.
4. `bubbles.implement` splits only the two malformed lines.
5. `bubbles.test` runs identical-byte GREEN, fixture matrix, mutation checks,
   and framework validation.
6. `bubbles.releases` reconciles generated release identity.
7. `bubbles.validate` owns certification and terminal state.
