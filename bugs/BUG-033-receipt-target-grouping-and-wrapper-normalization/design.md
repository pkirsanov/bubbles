# BUG-033 Design — Receipt Target Grouping And Wrapper Normalization

## Root-Cause Analysis

Check 43 answers one question: *is this substantive stdout being cited by two
claims that cannot both be honest?* It answers it by grouping receipts on
`stdoutHash` and then asking whether the colliding receipts are **deterministic
siblings** — the same validator, the same category, the same exit status, over
DIFFERENT targets, with INDEPENDENT execution provenance.

Both defects live in how "the same validator" and "different targets" are
computed, not in the question itself.

### Facet 1 — the distinctness test is applied to the wrong list

```jq
| ($rows | map(target_identity)) as $targets
...
and ($targets | all_distinct_nonempty)
```

`$rows` is every colliding RECEIPT. `all_distinct_nonempty` requires
`unique | length == length`. So the predicate is not "the identities ran over
different targets" — it is "no target appears twice in the log". Re-running a
validator is normal and expected, so the second run of anything fails it.

The intent was to prevent one target from vouching for two identities. That
intent is preserved exactly by taking one representative target **per command
identity**:

```jq
| ($rows | group_by(.cmd | cmd_identity) | map(.[0] | target_identity)) as $targets
```

Now the list has one entry per identity. Two identities over one target still
produce a duplicate and still refuse. N re-runs of one identity contribute one
entry and cannot fail on repetition.

`provenance_identity` distinctness stays measured **per receipt**, deliberately.
That is the condition that proves each receipt is an independent execution, and
weakening it would be the actual widening.

### Facet 2 — the family is read off the wrong token

```jq
( . / " " | map(select(length > 0)) ) as $raw
| ( if (($raw[0] // "") == "bash") or (($raw[0] // "") == "sh")
    then $raw[1:] else $raw end )
```

This strips ONE token, and only if it is literally `bash` or `sh`. Consequences,
all observed:

| Spelling | Family before | Correct family |
| --- | --- | --- |
| `node -e x` | `node` | `node` |
| `env P=1 node -e x` | `env` | `node` |
| `zsh -c node -e x` | `zsh` | `node` |
| `P=1 node -e x` | `P=1` | `node` |
| `bash -c node -e x` | `-c` | `node` |

Four of five spellings of one command produce a wrong family, and one of them
produces a FLAG as the family. The repair is a recursive strip of the prefixes
that are transparent by construction:

```jq
def strip_wrappers:
  if ((.[0] // "") | test("^(bash|sh|zsh|ksh|dash)$"))
    then (if ((.[1] // "") == "-c") then (.[2:] | strip_wrappers) else (.[1:] | strip_wrappers) end)
  elif ((.[0] // "") == "env") then (.[1:] | strip_wrappers)
  elif ((.[0] // "") | test("^[A-Za-z_][A-Za-z0-9_]*=")) then (.[1:] | strip_wrappers)
  else . end;
```

Recursion matters: `env A=1 zsh -c cargo test` has three stacked prefixes, and a
single-pass strip would collapse one of them and stop.

## Impact Analysis

- **Blast radius:** every repository that installs `state-transition-guard.sh`.
  A false CLONE refuses a transition while alleging forgery, so the defect both
  blocks honest work and mislabels it.
- **Direction of the change:** strictly toward ACCEPTING more logs. That makes
  the bound the whole safety argument, so each facet ships with an adversarial
  case that must still REFUSE.
- **Nothing else in Check 43 moves.** The empty-stdout exemption (BUG-007), the
  provenance requirement, the category compatibility rule and the family
  compatibility rule are untouched, and each keeps a pin in the regression set.

## Alternatives Considered

1. **Drop target distinctness entirely.** Rejected: one target vouching for two
   identities is precisely the forgery shape the rule exists for.
2. **Special-case `artifact-lint.sh`.** Rejected: the defect is structural, and
   an allow-list would leave every other deterministic validator broken.
3. **Normalize by re-parsing with a shell.** Rejected: executing recorded
   command strings to determine their identity is a code-execution surface
   inside a guard.
4. **Strip any leading token containing `/` or `=`.** Rejected: over-broad. It
   would strip `./run.sh` and make the family the first argument.

## Fix Design

Two edits inside the single Check 43 jq program in
`bubbles/scripts/state-transition-guard.sh`. No new script, no new flag, no
change to the check's exit contract or its diagnostic format.

## Test Design

`bubbles/scripts/receipt-identity-selftest.sh` extracts the Check 43 jq program
FROM THE GUARD SOURCE and drives it against fixtures. Extraction rather than
re-implementation is deliberate: a second copy of the identity rules would keep
passing while the guard regressed, which is the exact class of defect BUG-033
is. The extractor exits 2 if the guard's shape changes, so it cannot silently
degrade into testing nothing.

Six fixtures: two acceptance cases (one per facet), two adversarial bounds (one
per facet), and three pins carried forward from BUG-007 and BUG-032. Plus a
direct probe of `command_family` over six spellings.

The end-to-end cases run the WHOLE guard and live in
`bubbles/scripts/state-transition-guard-selftest.sh` beside the BUG-032 receipt
matrix.
