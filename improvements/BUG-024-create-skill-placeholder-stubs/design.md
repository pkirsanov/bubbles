# Bug Fix Design: BUG-024 Create-Skill Placeholder Stubs

## Design Brief

### Current State

The create-skill agent correctly requires a short interview, deduplication, and
a verified quality bar, but its final rendering rule forces two optional
sections to exist even when their content is unknown. The prescribed fallback
is itself incomplete content.

### Target State

The agent makes an explicit four-way decision for each recommended section:
include concrete content, omit because inapplicable, continue the interview
because missing information is material, or refuse the write when material
information cannot be established. There is no fifth state that emits an
incomplete section.

### Local Hypothesis And Discriminator

The contradiction is isolated to create-skill's scaffolding readiness and
rendering instructions. A structural regression over the agent source plus
rendered fixtures can disconfirm the repair by showing that a current stub
phrase, empty heading, or generic body still survives.

## Readiness Decision Model

For each recommended section:

| Context state | Required decision |
| --- | --- |
| Applicable and concrete content is known | Include the section with specific content. |
| Not applicable to the candidate skill | Omit the section. |
| Applicability is material but information is missing | Continue the interview with one focused question. |
| Material information cannot be obtained or verified | Refuse to scaffold and explain the missing contract. |

Materiality means omission could broaden activation into an unsafe task,
misroute work owned by another skill, or hide a required composition boundary.
Stylistic preference alone is not material.

## Agent Instruction Design

`agents/bubbles.create-skill.agent.md` should:

1. Preserve the three core questions and compact echo-back.
2. Add a write-readiness check after deduplication and the quality bar.
3. State that recommended sections are conditional, consistent with
   `bubbles-skill-authoring`.
4. Require concrete negative triggers to name the excluded task and correct
   route when such routing is known.
5. Require composition pointers to name real sibling skills verified in the
   repository.
6. Omit inapplicable sections without commentary in the generated file.
7. Continue/refuse before writing when a material boundary is unresolved.
8. Forbid empty headings, bracketed author prompts, generic filler, and any
   instruction to complete the generated file later.

## Deterministic Regression Design

The test owner reserves
`tests/regression/test_31_create_skill_placeholder_stubs.sh`. The regression
must parse the agent contract and exercise isolated candidate fixtures:

1. Both optional sections applicable with concrete verified content: both
   render and identify exact tasks/skills.
2. Neither optional section applicable: both headings are absent and the file
   remains complete.
3. Only one section applicable: exactly that section renders.
4. A safety-critical negative boundary is unknown: readiness is non-writing
   and requests the missing boundary.
5. A required sibling dependency is unknown: readiness is non-writing and
   requests or refuses the missing composition contract.
6. Mutants restore the current mandatory-stub sentence, permission to leave
   incomplete content, an empty heading, bracketed prompts, and generic filler;
   each mutant must fail independently.

The regression must verify structure, not only banned words. Historical prose
inside the bug regression fixture cannot make canonical source fail, and a
renamed empty marker must still be detected by heading/body cardinality.

## Change Boundary

### Packet-Creation Invocation

Only the nine files in this BUG-024 directory may be created. No agent source,
test, generated manifest, shared index, commit, push, or downstream file is in
the current invocation boundary.

### Authorized Delivery Boundary

| Owner | Exact surface | Permitted work |
| --- | --- | --- |
| `bubbles.implement` | `agents/bubbles.create-skill.agent.md` | Readiness and rendering contract only. |
| `bubbles.test` | `tests/regression/test_31_create_skill_placeholder_stubs.sh` | Structural fixtures, RED/GREEN, and mutants. |
| `bubbles.test` | Focused registration/provenance surfaces | Collision-safe source-only regression registration after GREEN. |
| `bubbles.releases` | Generated release identity | Reconcile stable final bytes only. |
| `bubbles.validate` | Certification fields and terminal status | Independent certification only. |

### Protected Surfaces

- `skills/bubbles-skill-authoring/SKILL.md`
- unrelated create/update agents and skills
- `BUGS.md` and `improvements/INDEX.md`
- product/downstream repositories and installed copies

## Preserved Contracts

- Existing target classification and artifact gates.
- Dedup-first behavior and anti-hoarding review.
- `Reusable · Non-trivial · Specific · Verified` quality bar.
- `.github/skills/<skill-name>/SKILL.md` output location and frontmatter.
- No additional generated files unless explicitly requested.
- No defaults, environment-specific values, or ad hoc command guidance.

## Failure And Rollback

If the focused regression fails, restore the create-skill agent to its exact
pre-edit hash; do not weaken the skill-authoring authority or teach a renamed
incomplete marker. Release identity is reconciled only after focused and broad
tests settle.

## Owner Route

1. `bubbles.design` confirms the materiality decision model.
2. `bubbles.plan` reconciles scenario/test/DoD parity.
3. `bubbles.test` captures final-byte RED.
4. `bubbles.implement` edits only the create-skill agent.
5. `bubbles.test` runs identical-byte GREEN, fixtures, mutants, and framework
   validation.
6. `bubbles.releases` reconciles generated release identity.
7. `bubbles.validate` owns certification and terminal state.
