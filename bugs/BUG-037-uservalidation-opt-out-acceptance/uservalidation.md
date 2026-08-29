# BUG-037 User Validation

## Automation Readiness

Written by automation. Records that the delivered behavior was verified far
enough to be worth a human's time. Grants no acceptance.

- [x] The defect was reproduced mechanically through the shared reader Gate G136 itself sources, with a real exit code
- [x] The `9e41da4` inversion was corroborated against git history rather than asserted from memory
- [x] Every stale governance surface named in the packet was confirmed present at HEAD by search
- [x] The affected-surface inventory was assembled by repository-wide search and its incompleteness is declared

## Checklist

Human acceptance, opt-out. Ships CHECKED. The user's only required act is to
UNCHECK an item whose behavior does not meet their expectation.

- [x] A user who reviews the delivered behavior and unchecks nothing reaches a terminal status without any further act
- [x] An item the user unchecks blocks the terminal transition and is named in the refusal
- [x] The BUG-029 shape is still refused: one checked item plus five unchecked never reaches terminal
- [x] No agent, guard, or lint ever re-checks an item the user unchecked
- [x] The optional acceptance record is still validated when a human chooses to author one
- [x] Every governance surface describing Gate G136 matches what the guard and lint actually do

An item the user has unchecked blocks a terminal transition until the behavior
is fixed and the USER re-checks it. Unchecking nothing is acceptance.

## Human Acceptance Record

Optional. Not required at a terminal transition. Author it only where an
external UAT, an explicit sign-off, or a compliance context wants a named
acceptor.

- acceptedBy: [human name or handle — never an agent id]
- acceptedAt: [YYYY-MM-DDTHH:MM:SSZ]
- method: [human-interactive | external-record]
- record: [pointer to the external acceptance artifact — required only for external-record]

## Goal

- Goal: accept delivered work by saying nothing when nothing is wrong, and reject it by unchecking the one item that is
- Success signal: a satisfied reviewer performs zero actions and the work reaches terminal; an unsatisfied reviewer unchecks one line and the work stops
