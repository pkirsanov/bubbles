# Bug: BUG-024 Create-Skill Placeholder Stubs

## Summary

`agents/bubbles.create-skill.agent.md` requires every generated skill to
contain `When NOT to use` and `Works well with` section stubs, and explicitly
instructs the authoring agent to leave clearly marked stubs when content is
unknown. That scaffolding rule contradicts both the same agent's critical
requirement forbidding stubs and the authoritative skill-authoring guidance,
which makes those sections recommended only when applicable and requires
skill content to be concrete and verified.

## Severity

- [ ] Critical - Framework cannot run
- [ ] High - Unsafe production or state corruption
- [x] Medium - Canonical scaffolding can generate policy-invalid skills
- [ ] Low - Cosmetic wording only

## Status

- [x] Reported
- [x] Confirmed by current source inspection
- [x] In Progress
- [ ] Fixed
- [ ] Verified
- [ ] Closed

## Current-Truth Source Evidence

**Claim Source:** interpreted

**Interpretation:** The cited canonical files were read with editor file tools
from the clean clone at `origin/main` commit `aa78e91`. No create-skill run,
test command, lint, or validation command was executed.

The current contradiction is direct:

1. `agents/bubbles.create-skill.agent.md` imports critical requirements that
   say no stubs are allowed.
2. Its scaffolding rules nevertheless require a `When NOT to use` section stub
   and a `Works well with` section stub.
3. The same sentence instructs the agent to leave those stubs clearly marked
   when content is unknown.
4. `skills/bubbles-skill-authoring/SKILL.md` states that both sections are
   recommended, not mandatory, and should be included when applicable.
5. The authoring quality bar requires procedures to be reusable,
   non-trivial, specific, and verified rather than speculative.

## Reproduction Steps

1. Read the `Critical Requirements Compliance` section in
   `agents/bubbles.create-skill.agent.md`.
2. Read its `Scaffolding Rules` section.
3. Observe the mandatory section-stub and leave-stub instructions.
4. Compare them with `Recommended Body Sections` and `Quality Bar` in
   `skills/bubbles-skill-authoring/SKILL.md`.
5. Observe that following the agent literally requires output that its own
   higher-priority rules classify as incomplete.

## Expected Behavior

- `When NOT to use` and `Works well with` are emitted only when the interview
  or verified repository context provides concrete, applicable content.
- An inapplicable optional section is omitted cleanly.
- If a negative boundary or composition relationship is material to safe skill
  activation but unknown, the agent continues the interview for that specific
  missing information or refuses to scaffold until it is resolved.
- Generated skills never contain empty headings, bracketed prompts, generic
  filler, or clearly marked incomplete content.
- A deterministic scaffolding-contract regression rejects reintroduced stubs
  and accepts both concrete-section and valid-omission cases.

## Actual Behavior

The canonical agent requires incomplete generated text as its fallback when
the interview lacks optional-section content. The instruction creates a
conflict that cannot be satisfied by a literal implementation.

## Impact

- Newly generated skills can fail the framework's own no-stubs quality bar.
- Semantic activation boundaries may be represented by generic filler rather
  than verified routing information.
- Users may receive apparently complete scaffolds that still require manual
  authoring work.
- Auto-detect mode can suppress necessary questions while preserving unknown
  safety boundaries as incomplete text.

## Root-Cause Hypothesis

The create-skill scaffold once treated two useful section headings as a fixed
template. Later skill-authoring governance made them conditional and raised a
verified-content bar, but the agent's fixed-template fallback was not removed
and no scaffold-contract regression enforces the newer rule.

## Change Boundary And Exact Owners

| Surface | Owner | Authorized responsibility |
| --- | --- | --- |
| `design.md` | `bubbles.design` | Confirm omission versus continue/refuse decision rules. |
| `scopes.md`, `scenario-manifest.json`, `test-plan.json`, `uservalidation.md` | `bubbles.plan` | Reconcile one executable scaffold-contract scope. |
| `agents/bubbles.create-skill.agent.md` | `bubbles.implement` | Remove mandatory incomplete-section behavior and encode concrete/omit/continue/refuse rules. |
| `tests/regression/test_31_create_skill_placeholder_stubs.sh` | `bubbles.test` | Own structural fixtures, RED/GREEN, and adversarial mutations. |
| Regression registration and install provenance | `bubbles.test` | Add focused source-only coverage after GREEN. |
| Generated release identity | `bubbles.releases` | Reconcile stable final bytes. |
| `state.json::certification.*` and terminal status | `bubbles.validate` | Independently certify after all evidence exists. |

This intake may create only this bug packet. It does not authorize source,
test, generated-manifest, `BUGS.md`, `improvements/INDEX.md`, commit, push, or
downstream changes.

## Protected Authority

`skills/bubbles-skill-authoring/SKILL.md` is the current policy authority and
remains unchanged by the planned repair unless a separately routed authority
defect is established.

## Related Files

- `agents/bubbles.create-skill.agent.md`
- `skills/bubbles-skill-authoring/SKILL.md`
- `agents/bubbles_shared/critical-requirements.md`
