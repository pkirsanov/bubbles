# BUG-033 — Check 43 accuses honest re-runs of evidence forgery

- **Filed:** 2026-08-16 (BUGS.md entry) · **Packet opened:** 2026-08-17
- **Severity:** high
- **Disposition:** open framework defect, filed from a downstream repository
  (research-lab), now picked up in the canonical source repo as the S-C
  prerequisite named by IMP-047 (see `improvements/INDEX.md`).
- **Affects:** `bubbles/scripts/state-transition-guard.sh`, Check 43
  (`deterministic_siblings`), introduced with the BUG-032 D3 sibling work.

## Packet Route

The compact micro-fix packet is the DEFAULT route since IMP-047 S-D. This bug
does not clear it. The admission answers below are read mechanically by
`bubbles/scripts/micro-fix-admission.sh`; two of them fail, so the bug
escalates automatically to the full packet. Escalation is not a judgement call
and there is no override.

- micro-fix-admission: no-new-behavior = yes
- micro-fix-admission: no-schema-change = no
- micro-fix-admission: no-auth-surface = no
- micro-fix-admission: no-payment-surface = no
- micro-fix-admission: no-secret-surface = no
- micro-fix-admission: no-deployment-surface = no
- micro-fix-admission: no-cross-product-effect = yes
- micro-fix-admission: contract-preserving = yes

`no-new-behavior` fails because a transition the guard REFUSED today is
ACCEPTED after the fix, and a verdict flip is the most observable behavior
change a guard has. `no-cross-product-effect` fails because
`state-transition-guard.sh` is installed into every downstream consumer
repository, so the blast radius is every repo that upgrades.

## Symptom

A downstream transition is refused with:

```
Evidence receipt CLONE — one substantive stdout is cited across incompatible
command/category identities or receipts that cannot prove independent
target/execution provenance
```

naming `family=artifact-lint.sh category=lint`, on a log whose nine receipts
each carry a distinct `sessionId`/`ts` pair.

## Root Cause

Two independent identity-normalization defects in one check. Both make Check 43
allege forgery against honest work, which is the exact false positive the
check's own comments promise it will never produce.

### Facet 1 — target distinctness is measured per RECEIPT, not per IDENTITY

`deterministic_siblings` binds:

```jq
| ($rows | map(target_identity)) as $targets
```

— one entry per receipt — and then requires `all_distinct_nonempty`. A
validator is routinely re-run over one subject, so an honest log repeats that
subject and the distinctness test fails **on shape alone**, before any question
of forgery is asked. Nine receipts over two specs yield two distinct targets and
nine values, so `unique | length == length` is false and the group is refused.

The other four sibling conditions all pass on the real downstream log:

| Condition | Observed |
| --- | --- |
| `command_family` distinct | 1 (`artifact-lint.sh`) |
| `evidence_category` distinct | 1 (`lint`) |
| `exitCode` distinct | 1 (`0`) |
| `provenance_identity` distinct | 9 of 9 |
| `target_identity` distinct | **2 of 9** |

### Facet 2 — `cmd_parts` unwraps only a bare leading `bash`/`sh`

```jq
def cmd_parts:
  ( . / " " | map(select(length > 0)) ) as $raw
  | ( if (($raw[0] // "") == "bash") or (($raw[0] // "") == "sh")
      then $raw[1:] else $raw end );
```

One command spelled three ordinary ways resolves to three different families:

| Recorded command | `command_family` today |
| --- | --- |
| `node -e <script>` | `node` |
| `env PAGE=p node -e <script>` | `env` |
| `zsh -c 'PAGE=p node -e <script>'` | `zsh` |

Because the families differ, the group is a multi-identity collision and is
refused — again the re-spelling case the check promises to tolerate.
`bash -c <script>` is affected too: the current strip removes `bash` and leaves
`-c` as the family, so the family is a flag.

The two facets are separable but not independently sufficient: fixing only
facet 1 leaves the wrapper case blocking, and fixing only facet 2 leaves the
re-run case blocking.

## Reproduction

Both facets reproduce against the real guard through a hermetic fixture log.
See `report.md` for the executed reproduction, its exit code, and the raw
output.

## Fix

Facet 1 — take one target per command IDENTITY rather than per receipt:

```jq
| ($rows | group_by(.cmd | cmd_identity) | map(.[0] | target_identity)) as $targets
```

Provenance distinctness is unchanged, so each receipt must still prove
independent execution, and two identities sharing a single target remain a
refusal.

Facet 2 — generalize the strip to shell wrappers, `env`, and leading
`VAR=value` assignments so all three spellings collapse to `family=node`:

```jq
def strip_wrappers:
  if ((.[0] // "") | test("^(bash|sh|zsh|ksh|dash)$"))
    then (if ((.[1] // "") == "-c") then .[2:] else .[1:] end | strip_wrappers)
  elif ((.[0] // "") == "env") then (.[1:] | strip_wrappers)
  elif ((.[0] // "") | test("^[A-Za-z_][A-Za-z0-9_]*=")) then (.[1:] | strip_wrappers)
  else . end;
```

## Why This Is Not A Widening

The relaxation is bounded on both facets and the bound is tested:

- Facet 1 keeps `provenance_identity` distinctness per RECEIPT, so a log that
  cannot prove independent execution is still refused. It also keeps the
  requirement that the DISTINCT identities have distinct targets, so
  `npm run lint` and `npm run test` over ONE target still refuse.
- Facet 2 normalizes only wrappers that are transparent by construction: a
  shell invoked with `-c`, `env`, and leading environment assignments do not
  change WHICH program ran. `cargo test` and `npm run lint` remain different
  families.

Both bounds carry an adversarial regression case that must still REFUSE.
