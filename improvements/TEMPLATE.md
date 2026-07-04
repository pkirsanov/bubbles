<!--
Template for a framework-health improvement proposal (IMP).
Copy to improvements/IMP-NNN-<slug>.md, fill every <...> placeholder, add a row
to improvements/INDEX.md, and leave Status: PROPOSED until the repo owner approves.
Per Gate G125, an IMP does NOT auto-mutate bubbles/*; implementation flows through
the named agents/gates in "Files to touch". Delete this comment in the real proposal.
-->

# IMP-NNN — <Short Title>

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of bubbles/* until approved
**Motivation:** <what audit / observation / incident produced this proposal>
**Verified gaps addressed:** <gap-code(s) — one short phrase each, cross-referenced to INDEX.md legend>

## Problem (verified against source)

- **<gap-code> — <name>:** <what is wrong, stated as a fact verified against a real file/line — not an assumption>.
- <add one bullet per verified gap; discard any claim that could not be re-checked against source>.

## Proposal

### SCOPE-1 — <name> (<gap-code>)

- <the concrete, additive, default-preserving change>. State the decision taken and, if two options exist, the recommendation + why.

### SCOPE-2 — <name> (<gap-code>)

- <...>

<!-- Add SCOPE-N blocks as needed. Keep each scope independently landable where possible. -->

## Migration / rollout

- <ordering, sequencing after any in-flight branch, and whether each scope is additive / doc-only / advisory-until-configured>.

## Risks & mitigations

- **R1** <risk> → <mitigation>.
- **R2** <risk> → <mitigation>.

## Acceptance criteria (when implemented)

- <observable, checkable outcome per scope — the condition that proves the gap is closed>.
- <...>

## Files to touch (on approval)

`<path/one>` (<what changes>), `<path/two>` (<what changes>), … — name the owning agent/gate for each surface so implementation routes correctly.
