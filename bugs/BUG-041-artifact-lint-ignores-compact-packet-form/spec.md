# Spec: BUG-041 — packet-form-aware artifact resolution

## Problem statement

`bubbles/registry/bug-packet.yaml` declares three packet forms and the artifact
set each form requires. Two enforcement surfaces ignore it and apply the `full`
form's set to every packet. The `compact` form has been the default route since
IMP-047 S-D, so the declared default route cannot pass enforcement.

## Expected behavior

### EB-1 — the registry governs the artifact set

`artifact-lint.sh` and `state-transition-guard.sh` derive their required artifact
set from `bubbles/registry/bug-packet.yaml`. Neither carries a literal list.

### EB-2 — a compact packet passes the artifact check

A packet that declares the compact form, survives admission, and carries
`bug.md`, `report.md`, and `state.json` produces zero missing-artifact failures.

### EB-3 — an undeclared packet is unchanged

A packet with no form declaration is linted against the `full` form. Its verdict
is byte-identical to the verdict before this change.

### EB-4 — declaring the compact form is not a bypass

A packet that declares the compact form but fails any admission condition is
linted against the `full` form. There is no override.

### EB-5 — the framework refuses rather than degrades

A missing, unparseable, or empty-for-the-resolved-form registry causes a
non-zero exit that names the registry. It never causes an empty requirement set.

### EB-6 — the form declaration is contractual

`bug-packet.yaml` declares the state.json field name, its accepted vocabulary,
the canonical form each accepted word maps to, and the form applied when the
field is absent.

### EB-7 — the evidence contract is not relaxed

The `alwaysRequired` sections in `report-sections.yaml` continue to apply to
every `report.md`. No form receives a section exemption from this change.

## Acceptance criteria

| # | Criterion | Verified by |
|---|---|---|
| AC-1 | `grep -c "bug-packet.yaml" bubbles/scripts/artifact-lint.sh` is non-zero | command |
| AC-2 | No literal artifact array remains in either enforcement surface | source read |
| AC-3 | `bugs/BUG-038-progress-timeout-bsd-wc-padding` produces zero missing-artifact failures | `artifact-lint.sh` |
| AC-4 | The same packet still fails on exactly the two report-section issues | `artifact-lint.sh` |
| AC-5 | All six packets with no declaration produce byte-identical output before and after | captured diff |
| AC-6 | A forged compact declaration that fails admission is linted as full | fixture |
| AC-7 | An absent registry exits non-zero and names the registry | fixture |
| AC-8 | A form resolving to zero artifacts is refused | fixture |

## Out of scope

- Repairing `bugs/BUG-038-progress-timeout-bsd-wc-padding/report.md`. It is
  correctly formed against its artifact contract. Its two missing report
  sections are routed to its owner as a separate finding.
- Adding a form dimension to `report-sections.yaml`. Recorded as an open owner
  decision in `design.md` §2.2.
- Retiring the `micro` alias. That requires editing BUG-038, which is outside
  this packet's boundary.

## Non-goals

This change does not widen admission, does not add an override, and does not
reduce any preserved obligation of the compact form.
