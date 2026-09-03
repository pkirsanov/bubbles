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

Three identity-normalization defects live in one check. The first two were
implemented before this amendment. The third remains unfixed. All three can
make Check 43 allege forgery against honest work, which is the exact false
positive the check's own comments promise it will never produce.

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

### Facet 3 — bounded process launchers are treated as the command

`strip_wrappers` stops when its first token is `timeout`, `gtimeout`, or the
macOS portable alarm launcher:

```text
/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' <seconds> <command...>
```

That creates two opposite identity failures from one root cause:

1. A direct invocation and a launcher-wrapped invocation of the same command
  and target become different identities. Their stable substantive output is
  reported as cloned evidence.
2. Two different underlying commands wrapped by the same launcher and duration
  collapse to the launcher's identity. Check 43 then sees only one identity
  and does not inspect the substantive-output collision at all.

The current identities observed from the real Check 43 definitions are
`artifact-lint.sh <target>`, `timeout 120`, `gtimeout 120`, and `perl shift`.
The latter three describe process-control syntax, not the command that produced
the evidence.

This belongs to BUG-033 rather than a new bug. It changes the same
`strip_wrappers` decision in Check 43, violates the same command-identity
contract, and was discovered while BUG-033 remained `in_progress` and
uncertified. A second packet would split one live root cause and make the two
wrapper contracts independently stale.

## Reproduction

The original two facets reproduce against the real guard through a hermetic
fixture log. See `report.md` for their historical red/green evidence.

Facet 3 was reproduced on 2026-08-23 with a temporary probe outside the
repository. The probe extracts the Check 43 jq definitions from the canonical
guard. It does not reimplement identity logic.

**Phase:** bug
**Command:** `/usr/bin/perl -e 'alarm shift @ARGV; exec @ARGV' 60 zsh -lc 'bash /tmp/bug033-timeout-alarm-red.sh; probe_exit=$?; printf "PROBE_EXIT=%s\n" "$probe_exit"; exit "$probe_exit"'`
**Exit Code:** 1
**Claim Source:** executed

```text
=== BUG-033 timeout/alarm wrapper RED ===
guard=bubbles/scripts/state-transition-guard.sh
direct.family=artifact-lint.sh
direct.identity=artifact-lint.sh bugs/BUG-033-receipt-target-grouping-and-wrapper-normalization
timeout.family=timeout
timeout.identity=timeout 120
gtimeout.family=gtimeout
gtimeout.identity=gtimeout 120
alarm.family=perl
alarm.identity=perl shift
equivalent.uniqueIdentities=4
equivalent.cloneGroups=1
FAIL: same command/target splits across 4 identities and 1 clone group(s)
timeout-bound.identityA=timeout 120
timeout-bound.identityB=timeout 120
timeout-bound.cloneGroups=0
FAIL: timeout launcher hides different underlying commands (identities 'timeout 120' and 'timeout 120'; clones=0)
alarm-bound.identityA=perl shift
alarm-bound.identityB=perl shift
alarm-bound.cloneGroups=0
FAIL: alarm launcher hides different underlying commands (identities 'perl shift' and 'perl shift'; clones=0)
BUG-033 timeout/alarm wrapper RED: 0 passed, 3 failed
PROBE_EXIT=1
```

The non-zero exit is the expected RED result. No source fix or repository test
was added by this discovery pass.

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

Facet 3 remains for implementation. The behavior contract is:

- unwrap `timeout` and `gtimeout` only when a recognized launcher grammar has a
  duration and a non-empty underlying command;
- unwrap only the exact portable Perl alarm/exec launcher shape above, never an
  arbitrary `perl -e` program;
- recurse into the already-supported shell, `env`, and assignment wrappers
  after removing the process-control prefix;
- preserve the first token of the underlying command so different programs
  remain different families and identities;
- leave malformed or unsupported launcher syntax unchanged so normalization
  fails closed rather than guessing.

The launcher may alter termination behavior, but Check 43 already compares
`exitCode` independently. Removing a recognized launcher only from command
identity must not remove that exit-status bound.

## Why This Is Not A Widening

The relaxation is bounded on all facets. The original two bounds are tested;
facet 3's bounds are required before implementation can be called complete:

- Facet 1 keeps `provenance_identity` distinctness per RECEIPT, so a log that
  cannot prove independent execution is still refused. It also keeps the
  requirement that the DISTINCT identities have distinct targets, so
  `npm run lint` and `npm run test` over ONE target still refuse.
- Facet 2 normalizes only wrappers that are transparent by construction: a
  shell invoked with `-c`, `env`, and leading environment assignments do not
  change WHICH program ran. `cargo test` and `npm run lint` remain different
  families.
- Facet 3 must prove that direct, `timeout`, `gtimeout`, and exact alarm-wrapped
  spellings of one command become one identity. Its adversarial partners must
  prove that `artifact-lint.sh` and `state-transition-guard.sh` remain distinct
  behind each launcher, arbitrary `perl -e` is not stripped, malformed timeout
  syntax is not guessed through, and differing exit codes remain incompatible.

Every bound must carry an adversarial regression case that would fail if
launcher stripping consumed or hid the underlying program.
