# IMP-102 — Assurance-Integrity & Delivery Hardening

**Status:** PROPOSED (not yet applied) — awaiting owner review
**Surface:** framework-health (G125) — human-reviewed; NO auto-mutation of `bubbles/*` until approved
**Motivation:** Two independent read-only review rounds against `HEAD 59fb6a0` (`framework-validate` and `release-check` both PASS at that SHA) executed discriminators that live *outside* the current check surface. They found that the framework's central promise — *mechanically-verified, non-fabricatable "done"* — has several admissible bypasses, that the CI backstop meant to catch fabrication is itself unparseable, that the ordered-workflow resolver silently drops repeated phases, that a guard interpolates an un-sanitized path into `python3 -c`, and that a portion of the shipped command surface cannot run on the documented macOS Bash 3.2 baseline. None of these are caught by `release-check` today.
**Verified gaps addressed:** AF (evidence-admission bypasses), FLOW (ordered-phase loss), CI (dead promotion guard / unvalidated workflow YAML), RCE (path interpolation in guard), PORT (bash-3.2 breakage in shipped scripts), PKG (installer/upgrade transactionality + completeness), MCP (unauthenticated tool RPC), RT (runtime-state races + read-only mutation), TRUTH (source-repo governance + generated-doc + ledger drift), COST (validation cost / payload weight / positioning).

Every claim below was re-checked against a real file and line at `59fb6a0`. Claims that could not be re-verified are quarantined in **Appendix A (verify-first)** and are NOT part of the proposal.

---

## Severity rollup

| Prio | Scope | Theme | Headline gap |
|------|-------|-------|--------------|
| **P0** | SCOPE-1 | AF | DoD "done" is admissible without real evidence (marker / bare link / forgeable tool-log / uppercase `[X]` / prose block / cross-spec bleed) |
| **P0** | SCOPE-2 | FLOW | `mode-resolver` `unique` deletes intentionally-repeated phases in **8** modes (post-remediation `validate` silently removed) |
| **P0** | SCOPE-3 | CI | The one CI anti-fabrication workflow is invalid YAML → never runs; no workflow-YAML validation exists |
| **P0** | SCOPE-4 | RCE | Guard interpolates un-sanitized `feature_dir` into `python3 -c "open('$state_file')"` (×4) |
| **P0→P1** | SCOPE-5 | PORT | `declare -A` / `${x,,}` in the shipped command surface break stock macOS Bash 3.2; `cli.sh` returns exit 0 while dead |
| **P1** | SCOPE-6 | PKG | `upgrade` is fail-open + non-transactional; payload verify cannot prove completeness; eval schemas ship source-only (BUG-015) |
| **P1** | SCOPE-7 | MCP | Tokenless non-loopback bind runs bash tools; no `inputSchema` validation; `record_evidence` drops its args; unbounded body read |
| **P1** | SCOPE-8 | RT | Lease/run-state locks have no stale recovery; read-only commands mutate run-state; session-snapshot RMW is lock-free (cap under-count) |
| **P2** | SCOPE-9 | TRUTH | Source-repo instructions/constitution self-contradict; two generated docs are malformed; gate→mode coverage is not legible; batch-promotion override is a replayable env flag |
| **P3** | SCOPE-10 | COST | Full validation (~14–17 min) runs twice; ~410 MiB media rides every source-archive install; positioning under-sells the real moat |

---

## Problem (verified against source)

### AF — evidence-admission bypasses (SCOPE-1)

The promotion guard's Check 9 ("every completed DoD item carries evidence") admits several non-evidence forms:

- **Bare marker.** A same-line `Evidence:` marker with no resolvable link still increments `checked_with_evidence` — [state-transition-guard.sh L2356-L2372](bubbles/scripts/state-transition-guard.sh#L2356-L2372). `- [x] Implemented cosign verification → Evidence: done` passes.
- **Plain link to any existing `report.md`.** Admission is by *file existence*, not content — [L2395-L2401](bubbles/scripts/state-transition-guard.sh#L2395-L2401). An empty `report.md` satisfies it.
- **Prose block masquerading as evidence.** "Evidence by reference" accepts any ≥10 non-blank lines between a slug-matching heading and the next heading — [L2320-L2324](bubbles/scripts/state-transition-guard.sh#L2320-L2324). No requirement that the block be command output; 10 lines of filler pass.
- **Forgeable tool-log.** `_tool_log_covers_dod_item` trusts the caller-writable `.specify/runtime/tool-calls.jsonl`, requiring only `exitCode==0` + ≥2 shared tokens — [L2246-L2266](bubbles/scripts/state-transition-guard.sh#L2246-L2266). The schema is permissive (`required:[ts,sessionId,cmd,exitCode]`, `additionalProperties:true`, hashes optional — [tool-call.schema.json L7](bubbles/schemas/tool-call.schema.json#L7)) and identity defaults to caller-controlled `human` ([tool-log.sh L54](bubbles/scripts/tool-log.sh#L54)). One appended line `{"ts":…,"sessionId":"x","cmd":"pytest integration passed","exitCode":0}` clears any DoD item sharing two tokens.
- **Uppercase `[X]` escapes the evidence scan entirely.** Check 4A (G041) is case-insensitive and accepts `- [X]` as a valid *checked* item ([L1062](bubbles/scripts/state-transition-guard.sh#L1062)), but the Check 9 scan and tokenizer are lowercase-only (`grep -E '^\- \[x\] '` [L2424](bubbles/scripts/state-transition-guard.sh#L2424); `re.sub(r'^- \[x\] '…)` [L2237-L2238](bubbles/scripts/state-transition-guard.sh#L2237-L2238)). A pure-uppercase `- [X]` item is "done + valid format" yet **never evidence-checked**.
- **Cross-spec evidence bleed.** An entry with empty `spec` is never skipped ([L2246-L2249](bubbles/scripts/state-transition-guard.sh#L2246-L2249)), so one repo-level log line satisfies the *same* DoD item across all specs simultaneously. The MCP `record_evidence` form emits exactly such spec-less entries by construction (see MCP below).
- **Duplicate-line window reuse.** Item→evidence resolution uses `grep -nF -- "$line" … | head -1` ([L2342](bubbles/scripts/state-transition-guard.sh#L2342)), so a second identical `- [x] …` line inherits the *first* line's evidence window — a false pass for the duplicate.
- **No runtime schema validator on the live log.** `tool-call.schema.json` is referenced only by a copy, the manifest, and two selftests; nothing validates the live `tool-calls.jsonl` the evidence path consumes.

### FLOW — ordered-phase loss (SCOPE-2)

`mode-resolver.sh` applies `unique` to **every** sequence during resolution — [L246](bubbles/scripts/mode-resolver.sh#L246) `(.. | select(tag == "!!seq")) |= unique` — on the false premise (comment [L243-L245](bubbles/scripts/mode-resolver.sh#L243-L245)) that phase lists "never contain duplicates." They do: a baseline `validate` and a post-remediation certification `validate` are intentionally repeated. Empirically, `harden-to-doc` ([modes.yaml L402](bubbles/workflows/modes.yaml#L402)) resolves `phaseOrder` validate-count 2→1 — the certification pass is deleted. Confirmed affected modes (explicit duplicate phase in `phaseOrder`): **harden-to-doc, gaps-to-doc, harden-gaps-to-doc, reconcile-to-doc, stabilize-to-doc, improve-existing, idea-to-release-completion, stochastic-quality-sweep**. The most safety-relevant loss is the re-validation *after* remediation.

### CI — dead promotion guard (SCOPE-3)

[.github/workflows/state-transition-guard.yml](.github/workflows/state-transition-guard.yml) embeds Python at column 0-2 under a `run: |` block-scalar baseline (col 10) → invalid YAML (`mapping values are not allowed`). GitHub cannot load the workflow, so its `discover`, `batch-promotion-lint`, and per-feature guard steps never run — this is the *only* CI mechanical anti-fabrication enforcement, and it is silently dead. A workflow-YAML validity sweep shows it is the **only** failing workflow (the other three parse); `release-check`/`framework-validate` do not parse workflow YAML at all.

### RCE — path interpolation in the guard (SCOPE-4)

`bubbles/scripts/guards/control-plane-checks.sh` interpolates `$state_file` directly into `python3 -c "…"` source at four sites — [L244](bubbles/scripts/guards/control-plane-checks.sh#L244), [L257](bubbles/scripts/guards/control-plane-checks.sh#L257), [L348](bubbles/scripts/guards/control-plane-checks.sh#L348), [L429](bubbles/scripts/guards/control-plane-checks.sh#L429) — as `with open('$state_file') as f:`. `state_file` derives from `feature_dir="$1"` ([state-transition-guard.sh L170](bubbles/scripts/state-transition-guard.sh#L170)), the un-sanitized directory argument. A spec directory whose name contains a single quote (e.g. `x'); __import__('os').system('…'); ('`) makes the emitted Python execute arbitrary code. Realistic trigger: CI that runs the guard across attacker-authored `specs/*` directory names in a cloned/PR'd repo. The `2>/dev/null || echo false` wrapper also silently mis-evaluates ANY benign quote in a directory name — a correctness bug even without malice.

### PORT — bash-3.2 breakage in the shipped surface (SCOPE-5)

The documented support baseline is stock macOS `/bin/bash` 3.2, but bash-4-only constructs ship in downstream-reachable scripts with no `BASH_VERSINFO` guard:

- `declare -A` at file scope in [aliases.sh L21](bubbles/scripts/aliases.sh#L21), sourced unconditionally by [cli.sh L56](bubbles/scripts/cli.sh#L56) before dispatch → on 3.2 even `bubbles help` dies (`pull: unbound variable`).
- `cli.sh` uses `set -uo pipefail` **without `-e`** ([L50](bubbles/scripts/cli.sh#L50)) and sources non-fatally, so on 3.2 it prints nothing and **returns exit 0** — any installer post-check / `doctor` / CI wrapper testing `$?` believes it succeeded. This *masks* the breakage.
- `${x,,}` in [orchestrator-persistence-lint.sh L189](bubbles/scripts/orchestrator-persistence-lint.sh#L189), [planning-workflow-chain-guard.sh L184](bubbles/scripts/planning-workflow-chain-guard.sh#L184), [trajectory-inspector.sh L235](bubbles/scripts/trajectory-inspector.sh#L235) → `bad substitution` on 3.2. The first two are invoked by tail-gate checks and produce **false G086/G091 failures** downstream (output discarded, so the operator sees a bare gate failure).
- `declare -A` in [intent-routes-lint.sh L79/L88](bubbles/scripts/intent-routes-lint.sh#L79) and [gate-strength-lint.sh L70](bubbles/scripts/gate-strength-lint.sh#L70) (both invoked by `framework-validate`) → those checks abort on 3.2. (Same construct also present in `release-train-rollup.sh`, `release-train-flag-audit.sh`, `release-delivery-reconciliation-guard.sh`, `test-impact-plan.sh`, `interop-apply.sh`, `gate-id-grep.sh`, `scenario-compile-lint.sh` — reached via their own subcommands.)

The framework's own `macos-portability-guard.sh` is by contract never pointed at `bubbles/scripts/`, so it structurally cannot catch these, and the maintainer's Homebrew bash 5 masks them.

### PKG — installer/upgrade (SCOPE-6)

- `cmd_upgrade` runs `bash install.sh …` and `cmd_doctor` **unchecked**, then unconditionally prints `✅ Upgrade complete.` + `fun_summary pass` — [cli.sh L3120-L3162](bubbles/scripts/cli.sh#L3120-L3162) (no `set -e`). A failed or partial upgrade reports success.
- `verify-payload-integrity.sh` **skips** every manifest entry that is absent on disk ([L114-L123](bubbles/scripts/verify-payload-integrity.sh#L114-L123)); only present-but-mismatched bytes fail. It cannot distinguish "legitimately absent" from "dropped by a broken download," so required-profile **completeness is unprovable**. Worse, when the manifest *itself* is missing the check no-ops to a GREEN verdict ([L50 exit table](bubbles/scripts/verify-payload-integrity.sh#L50)).
- The installed `eval-harness.sh` hard-refs `$SCRIPT_DIR/../eval/schemas/*.json` ([L88-L89](bubbles/scripts/eval-harness.sh#L88-L89)) but those schemas are classified `sourceOnlyFileChecksums` in [release-manifest.json](bubbles/release-manifest.json) (not vendored downstream) → downstream failure. Tracked open as **BUG-015** ([BUGS.md](BUGS.md)); a second eval-contract hole (`adversarial-aggregate.sh` timestamp validation) is tracked as **BUG-016**.

### MCP — unauthenticated tool RPC (SCOPE-7)

[bubbles/mcp/server.py](bubbles/mcp/server.py): empty token default ([L1007](bubbles/mcp/server.py#L1007)); `_authorized` returns `True` when no token is set ([L1017-L1021](bubbles/mcp/server.py#L1017-L1021)); binds to a freely-configurable `--host`/`BUBBLES_MCP_HTTP_HOST` (accepts `0.0.0.0`) with no refusal ([L1060](bubbles/mcp/server.py#L1060), [L1120-L1124](bubbles/mcp/server.py#L1120-L1124)) → an unauthenticated remote `tools/call` runs bash scripts. Tool arguments are only *merged with defaults*, never validated against `inputSchema` ([L684-L690](bubbles/mcp/server.py#L684-L690)). `record_evidence.json` uses `argsTemplate:["--","${command}"]` — dropping `${args}`/spec/scope/tags — and `_execute_tool` sets no `env=`, so the wrapped command runs *without* its intended arguments and logs a spec-less entry (feeding the cross-spec bleed above). The `do_POST` handler reads an unbounded `Content-Length` into memory ([L1046-L1049](bubbles/mcp/server.py#L1046-L1049)) → trivial memory-exhaustion DoS.

### RT — runtime-state races (SCOPE-8)

- `runtime-leases.sh` uses a bare `mkdir` mutex that `die`s on a held lock and releases only via trap ([L327-L335](bubbles/scripts/runtime-leases.sh#L327-L335), [L353-L359](bubbles/scripts/runtime-leases.sh#L353-L359)); a SIGKILL/crash strands `.lock` with no PID/mtime stale-break → permanent deadlock. The live `.specify/runtime/workflow-runs.json` currently carries **21** `activeRuns`.
- `cli.sh` opens run-state on **every** invocation, including read-only commands (`begin_cli_run_state` [L3181-L3182](bubbles/scripts/cli.sh#L3181-L3182)), via a single fixed unlocked temp ([L404](bubbles/scripts/cli.sh#L404)) — outside the lease lock → concurrent races and needless mutation on observation.
- `state-snapshot.sh` does a lock-free read-modify-`mv` twice ([L210](bubbles/scripts/state-snapshot.sh#L210), [L244](bubbles/scripts/state-snapshot.sh#L244), [L277](bubbles/scripts/state-snapshot.sh#L277)); two concurrent turns lose an update, and a lost `convergenceLoops[]` entry **undercounts iterations** — the exact signal `convergence-cap-guard.sh` (G082) and `session-cap-guard.sh` (G128) depend on → cap under-enforcement.

### TRUTH — source-of-truth drift (SCOPE-9)

- [.github/copilot-instructions.md](.github/copilot-instructions.md) links a nonexistent `terminal-discipline.instructions.md` ([L47](.github/copilot-instructions.md#L47)), invokes a nonexistent `./bubbles.sh` ([L122](.github/copilot-instructions.md#L122)), mandates `specs/[feature]/` ([L64](.github/copilot-instructions.md#L64)) while [gates.yaml L332](bubbles/registry/gates.yaml#L332) states the SOURCE repo has no persistent `specs/` under G085, and mixes downstream `.github/bubbles/scripts/…` paths.
- Two generated docs are malformed: [competitive-capabilities.md](docs/generated/competitive-capabilities.md) leaks literal `>` folded-scalar indicators into 5 Summary cells; [interop-migration-matrix.md](docs/generated/interop-migration-matrix.md) collapses columns so framework-managed paths appear under "Supported Apply Targets" for Roo/Cursor/Cline while the same paths are "Unsupported" for Claude Code. Root cause in the generator's scalar handling ([generate-capability-ledger-docs.sh L234-L257](bubbles/scripts/generate-capability-ledger-docs.sh#L234-L257), [L421](bubbles/scripts/generate-capability-ledger-docs.sh#L421)).
- `yaml-schema-validate.sh` globs `specs/*/scenario-manifest.json` (one level — [L100](bubbles/scripts/yaml-schema-validate.sh#L100)) while its comment promises `specs/**`; nested manifests (bugs, grouped specs) are silently unvalidated.
- The batch-promotion override is a plain replayable env flag: `BUBBLES_BATCH_PROMOTION_OVERRIDE=1` → exit 0 ([batch-promotion-lint.sh L212-L215](bubbles/scripts/batch-promotion-lint.sh#L212-L215)).
- **Gate→mode coherence (advisory):** 0 of the 109 defined gates are referenced-but-undefined, but **44** are defined and referenced by no mode/template `requiredGates` (`G037/G038/G041/G042/G043/G052/G053/G063/G064/G066-G101/G126-G128`). Most are enforced elsewhere (state-transition-guard checks, `framework-validate`, CI), so this is a **legibility** gap — `requiredGates` is not a complete map of which gates apply — not an "unenforced" claim.

### COST — validation cost / payload weight / positioning (SCOPE-10)

Full `framework-validate` (~14–17 min) is invoked by both the prepush path and `release-check` with no single-run reuse; ~410 MiB of media under `pictures/` rides every source-archive install even though only a minimal payload is needed at runtime; effective agent bundles reach ~462 KB (22 agents >100 KB); and the public positioning under-sells the genuine differentiator (mechanical certification integrity) relative to competitors.

---

## Proposal

Each scope is independently landable and default-preserving: it *adds* an assertion or *narrows* an admission; it does not remove a capability. Where two designs exist, the recommendation is stated.

### SCOPE-1 — Make evidence admission mean "verified command output" (AF)

- **Narrow Check 9 admission.** Reject the bare same-line `Evidence:` marker unless it resolves to a structured evidence block. Require a link *anchor* that resolves to a heading whose block contains at least one fenced command-output region (a fence plus a recognizable command/exit signature), not merely ≥10 non-blank prose lines. Count `report.md` evidence by *matched anchor content*, never file existence.
- **Close the checkbox-case hole.** Make the Check 9 scan and tokenizer case-insensitive for the `[xX]` marker **or** have Check 4A reject `- [X]` as a non-canonical format. Recommendation: make Check 9 case-insensitive (single source of truth for "checked"), then add `- [X]` to the Check 4A manipulation set so the two agree.
- **Scope tool-log evidence to the exact spec.** Treat an empty `spec` field as *non-matching* (never a wildcard). An entry must name the spec/scope it evidences.
- **Fix duplicate-line resolution.** Resolve each DoD item to its own line occurrence (enumerate occurrences; match the Nth item to the Nth line), not `head -1`.
- **Authenticate the tool-log (layered).** Tighten `tool-call.schema.json` (`additionalProperties:false`, require `agent`, `spec`, a content hash, and a per-session HMAC/receipt) and add a real per-line `Draft7Validator` pass over the live `tool-calls.jsonl`, wired into the evidence bridge. Recommendation: keep raw command-output evidence as the *primary* trust path and treat the tool-log as *corroborating* — so tightening the log never weakens honest flows.
- **Adversarial fixtures.** Add a selftest that asserts each bypass above now FAILS: bare marker, empty `report.md` link, prose-only block, forged JSONL line, `- [X]` item, empty-spec entry, duplicate line.

### SCOPE-2 — Preserve ordered-phase multiplicity in the resolver (FLOW)

- Replace the blanket `unique` with field-scoped dedupe: apply `unique` **only** to set-valued fields (`requiredGates`, `tags`, and any explicitly set-typed list), and preserve order + multiplicity for `phaseOrder`, `tailPhases`, and `findingDeliveryPhases`.
- Add a regression asserting the resolved `phaseOrder` for each of the 8 affected modes retains its repeated phase (specifically the post-remediation `validate`).

### SCOPE-3 — Restore + guard CI workflow validity (CI)

- Fix [state-transition-guard.yml](.github/workflows/state-transition-guard.yml): externalize the embedded Python into a committed script the step calls (preferred — keeps YAML trivial), or re-indent it under the block scalar. Confirm the `discover` → `batch-promotion-lint` → per-feature guard chain runs on a real promotion.
- Add workflow-YAML validation (an `actionlint` pass, or a YAML-parse sweep of `.github/workflows/*.yml`) to `framework-validate` and `release-check` so an unparseable workflow becomes a hard failure. Recommendation: `actionlint` (also catches expression/context errors), with the parse sweep as a no-dependency fallback.

### SCOPE-4 — Eliminate path interpolation into `python3 -c` (RCE)

- At all four sites in [control-plane-checks.sh](bubbles/scripts/guards/control-plane-checks.sh#L244), stop interpolating `$state_file` into Python source. Pass it positionally (`python3 -c '…open(sys.argv[1])…' "$state_file"`) or via `os.environ["STATE_FILE"]`. Remove the `2>/dev/null` that hides `SyntaxError` so a genuinely malformed path surfaces.
- Sweep every `python3 -c "…"` heredoc in `bubbles/scripts/**` for interpolated shell variables and convert them to argv/env passing.
- Add a fixture with a quote-bearing directory name that must be handled without executing anything.

### SCOPE-5 — Make the shipped command surface run on Bash 3.2 (or fail loudly) (PORT)

- **Decide the baseline.** Option A: keep the documented 3.2 support and make the ship-set 3.2-safe (`tr '[:upper:]' '[:lower:]'` for `${x,,}`; `sort|uniq -c` or delimited strings for `declare -A`). Option B: require Bash ≥ 4/5, add a loud `BASH_VERSINFO` guard + re-exec at each entrypoint (`cli.sh`, `framework-validate.sh`), and update the documented baseline. **Recommendation: A** — it preserves the advertised macOS default and the "no host mutation" ethos; use B's re-exec only for scripts that genuinely need associative arrays.
- Make `cli.sh` fail **loudly** (nonzero) when a prerequisite (e.g. `aliases.sh`) can't load, so 3.2 breakage can never masquerade as exit 0.
- Point `macos-portability-guard.sh` at a curated ship-set (the downstream-vendored scripts per the manifest) — not the whole `bubbles/scripts/` — so these regressions are caught mechanically going forward.

### SCOPE-6 — Transactional, complete installs (PKG)

- Propagate exits in `cmd_upgrade`: check `install.sh` and `doctor`, and only then print success; on failure, print the failing step and return nonzero.
- Make `install.sh` stage → verify → atomically promote (temp dir + `mv`), with a rollback path on verify failure.
- Add a required/profile-conditional/source-only classification to the manifest and have `verify-payload-integrity.sh` assert **exact-set** completeness for the active profile (absent-but-required = FAIL). Treat a missing manifest during a real (non-advisory) install as FAIL, not GREEN.
- Resolve BUG-015: either vendor `bubbles/eval/schemas/*.json` into the downstream managed set, or exclude `eval-harness.sh` from the downstream set until the schemas ship. (Fold BUG-016 timestamp validation into the same eval-contract fix.)

### SCOPE-7 — Close the MCP trust boundary (MCP)

- Refuse a non-loopback bind unless a token is set (and recommend TLS via a reverse proxy). Default host stays loopback.
- Validate every tool call against its `inputSchema` (`additionalProperties:false`) before execution; reject unknown/oversized fields.
- Fix `record_evidence.json` to render the declared params (`args`, `spec`, `scope`, `tags`) into argv/env, and have `_execute_tool` pass `env=` so `BUBBLES_SPEC/SCOPE/TAGS` reach the wrapped command.
- Cap `Content-Length` and concurrent connections; route mutating tools through the existing pre-tool risk gate.

### SCOPE-8 — Concurrency-safe runtime state (RT)

- Add a portable `flock` helper (with a watchdog fallback per the cross-platform skill) and give the lease + run-state + session-snapshot writers PID/mtime-based stale recovery and unique same-dir temp files.
- Derive the `activeRuns` view from append-only start/complete events with a startup reconciliation sweep (so a crash can't strand a run); reconcile the current 21 stale entries.
- Make read-only CLI commands **not** open run-state (separate observation from mutation), or gate `begin_cli_run_state` behind a mutation classification.
- Wrap the `state-snapshot.sh` compute-and-`mv` critical section (both writes) in a single `flock -x` so `convergenceLoops[]`/`turnNumber` can't be lost.

### SCOPE-9 — Reconcile the source-of-truth surfaces (TRUTH)

- Rewrite [.github/copilot-instructions.md](.github/copilot-instructions.md) to source-repo reality: no `specs/` mandate (or reconcile with G085), the real terminal-discipline link, the real command surface (`bubbles/scripts/cli.sh`, not `./bubbles.sh`), and source-repo (not downstream) paths. Customize the constitution's TODO/placeholder invariants.
- Fix the ledger-docs generator's scalar handling so folded `>`/`|` indicators never leak into cells and the interop matrix maps each tool to its own Supported/Unsupported columns; regenerate both docs.
- Make the scenario-manifest glob recursive (`specs/**/scenario-manifest.json`), scoping out `tests/` fixtures if needed.
- Bind the batch-promotion override to a signed, expiring token (sha + actor + expiry recorded in the ledger) instead of a bare replayable env flag.
- Add a generated **gate-coverage map** (gate → enforcing surface: mode `requiredGates` / state-transition-guard check / `framework-validate` / CI) so the 44 "unreferenced-by-mode" gates are demonstrably enforced and the enforcement graph is legible. Reconcile stale BUGS.md dispositions in the same pass.

### SCOPE-10 — Proportional cost, minimal payload, honest positioning (COST)

- Run the full `framework-validate` **once** per release and have `release-check` consume that result; add per-check deadlines + bounded parallelism so the wall-clock cost is predictable.
- Split a **minimal runtime payload** (scripts + registries + agents) from the source archive; move `pictures/` media to release assets so a downstream install doesn't carry ~410 MiB. Add a ratcheting per-bundle size budget (fail if an agent bundle grows past its recorded ceiling).
- Offer proportional **quick / standard / assured** validation tracks (documented, opt-in) so small changes aren't forced through the full assured suite, while keeping "assured" as the promotion default.
- Reposition public docs to lead with the mechanical certification-integrity moat (evidence gates + adversarial fixtures), and stand up a small held-out benchmark to substantiate it.

---

## Migration / rollout

1. **P0 first, independently:** SCOPE-1 (AF), SCOPE-2 (FLOW), SCOPE-3 (CI), SCOPE-4 (RCE) are separable and should land first; each ships with the regression/fixture that proves the gap closed. SCOPE-4 and SCOPE-2 are small and low-risk; SCOPE-1 and SCOPE-3 are the highest-value.
2. **P0→P1 portability (SCOPE-5):** land the 3.2-safe rewrites + the loud-fail guard together, then extend `macos-portability-guard.sh` coverage so regressions can't return.
3. **P1 (SCOPE-6/7/8):** installer, MCP, and runtime concurrency are independent; sequence by owner availability.
4. **P2 (SCOPE-9):** doc/generator/ledger reconciliation is additive and doc-only except the override-token change (advisory-until-configured).
5. **P3 (SCOPE-10):** cost/payload/positioning is opt-in and additive; the payload split is the only one touching install shape and should follow SCOPE-6.

All scopes are gated behind owner approval per G125; none auto-mutates `bubbles/*`.

## Risks & mitigations

- **R1 — Tightening evidence admission breaks honest in-flight specs.** → Keep raw command-output evidence as the primary path; ship the stricter check in *advisory* mode for one release (report would-fail counts) before making it blocking; provide a one-line migration note.
- **R2 — Field-scoped dedupe misses a set-typed list and reintroduces a duplicate.** → Drive dedupe from an explicit field allowlist in the resolver; the 8-mode regression fails loudly if a phase is lost or an unintended duplicate survives.
- **R3 — Externalizing the CI Python changes behavior.** → Byte-for-byte port the logic into the called script; add a workflow-parse check so a future re-break is caught immediately.
- **R4 — Bash-3.2 rewrites subtly change lint output.** → Cover each rewritten script with a 3.2 + 5.x selftest asserting identical output on both.
- **R5 — MCP auth/validation rejects a currently-working local flow.** → Loopback default stays tokenless; only non-loopback binds require a token; schema `additionalProperties:false` ships after a one-release warn window.
- **R6 — Payload split breaks the documented curl+bash install.** → Ship the minimal-payload installer alongside the current one; flip the default only after the verify-completeness change (SCOPE-6) proves the new set is complete.

## Acceptance criteria (when implemented)

- **SCOPE-1:** A selftest proves each of the seven bypasses (bare marker, empty-`report.md` link, prose-only block, forged JSONL, `- [X]` item, empty-`spec` entry, duplicate line) now FAILS Check 9; honest command-output evidence still PASSES.
- **SCOPE-2:** Resolved `phaseOrder` for all 8 named modes retains its repeated phase; a regression asserts the post-remediation `validate` survives resolution.
- **SCOPE-3:** All `.github/workflows/*.yml` parse; `framework-validate`/`release-check` fail if any workflow is unparseable; a real promotion demonstrably triggers the guard job.
- **SCOPE-4:** No `python3 -c` in `bubbles/scripts/**` interpolates a shell variable into source; a quote-bearing directory-name fixture runs the guard without executing injected code.
- **SCOPE-5:** `cli.sh help/status/doctor`, `framework-validate`, and the three `${x,,}` guards run on stock macOS Bash 3.2 (or fail with a clear nonzero + message); the portability guard covers the ship-set.
- **SCOPE-6:** `upgrade` returns nonzero on a failed install/doctor; `verify-payload-integrity.sh` fails on an absent required-profile entry and on a missing manifest during a real install; BUG-015/BUG-016 closed.
- **SCOPE-7:** A non-loopback bind without a token is refused; a tool call with an unknown/oversized field is rejected; `record_evidence` produces a spec-scoped, fully-argument'd log entry; oversized bodies are capped.
- **SCOPE-8:** A killed lease/run-state holder is recovered on next run (no permanent deadlock); read-only CLI commands do not mutate run-state; concurrent `state-snapshot` writes lose no `convergenceLoops` entry; the 21 stale runs are reconciled.
- **SCOPE-9:** Source-repo instructions contain no dead link / nonexistent CLI / self-contradiction; both generated docs render valid tables; the scenario-manifest glob is recursive; the batch-promotion override requires a signed expiring token; a gate-coverage map shows every defined gate's enforcing surface.
- **SCOPE-10:** Full validation runs once per release; a downstream install payload excludes `pictures/` media; a per-bundle size budget is enforced; quick/standard/assured tracks are documented with "assured" as the promotion default.

## Files to touch (on approval)

- `bubbles/scripts/state-transition-guard.sh` (Check 9 admission, case-insensitive checkbox, empty-spec scoping, duplicate-line resolution) — **owning gate: G024/G068 promotion guard**.
- `bubbles/schemas/tool-call.schema.json` + `bubbles/scripts/tool-log.sh` + `bubbles/scripts/evidence-tool-log-bridge*` (strict schema, authenticated receipt, live-log validator) — **owning gate: G068 evidence**.
- `bubbles/scripts/mode-resolver.sh` + `bubbles/workflows/modes.yaml` (field-scoped dedupe + 8-mode regression) — **owning agent: bubbles.workflow / mode registry**.
- `.github/workflows/state-transition-guard.yml` + `bubbles/scripts/framework-validate.sh` + `release-check` wiring + a new `actionlint`/parse step — **owning gate: CI promotion guard**.
- `bubbles/scripts/guards/control-plane-checks.sh` (argv/env path passing at L244/L257/L348/L429) + a quote-name fixture — **owning gate: G060/G061 control-plane**.
- `bubbles/scripts/aliases.sh`, `bubbles/scripts/cli.sh`, `bubbles/scripts/orchestrator-persistence-lint.sh`, `bubbles/scripts/planning-workflow-chain-guard.sh`, `bubbles/scripts/trajectory-inspector.sh`, `bubbles/scripts/intent-routes-lint.sh`, `bubbles/scripts/gate-strength-lint.sh`, `bubbles/scripts/macos-portability-guard.sh` (3.2-safety + loud-fail + guard coverage) — **owning gate: G-portability / framework-validate**.
- `bubbles/scripts/cli.sh` (`cmd_upgrade`), `install.sh`, `bubbles/scripts/verify-payload-integrity.sh`, `bubbles/release-manifest.json`, `bubbles/scripts/eval-harness.sh` (transactional upgrade + completeness + eval schemas) — **owning agent: installer / release manifest**.
- `bubbles/mcp/server.py`, `bubbles/mcp/tools/record_evidence.json` (auth/bind refusal, schema validation, arg rendering, body cap) — **owning agent: MCP server**.
- `bubbles/scripts/runtime-leases.sh`, `bubbles/scripts/cli.sh` (run-state), `bubbles/scripts/state-snapshot.sh` (locks + stale recovery + read-only non-mutation) — **owning gate: G082/G128 convergence/session caps**.
- `.github/copilot-instructions.md`, `.specify/memory/constitution.md`, `bubbles/scripts/generate-capability-ledger-docs.sh`, `docs/generated/{competitive-capabilities,interop-migration-matrix}.md`, `bubbles/scripts/yaml-schema-validate.sh`, `bubbles/scripts/batch-promotion-lint.sh`, a new gate-coverage generator, `BUGS.md` — **owning agent: bubbles.docs / registry maintenance**.
- Release/prepush orchestration + a payload-split installer + a bundle-size budget check + positioning docs — **owning agent: release/devops**.

---

## Appendix A — verify-first (NOT part of the proposal until confirmed)

- **Secret-scan allowlist breadth.** `.gitleaks.toml` carries broad value/path allowlists (common demo names/emails; `(?i)\.example$`, `\.test\.[a-z]+$`, `_test\.[a-z]+$`). Whether these can mask a *real* secret placed in a fixture path depends on the exact global `[allowlist] paths` scope, which was not fully audited. Confirm the blanket-path scope before treating as a finding.
- **BUGS.md staleness.** Several "fixed (working tree; not committed)" dispositions are inherently ambiguous; a full ledger-vs-commit cross-check was out of scope for these rounds.
- **`install.sh` internal mutation strategy.** SCOPE-6 confirms the *caller* ignores exits; the installer's own staging/rollback internals were not read line-by-line and should be reviewed before the transactional rewrite.

## Appendix B — review method & honesty statement

- Two read-only rounds at `HEAD 59fb6a0` (clean tree). `framework-validate` and `release-check` both PASS at this SHA — every finding above sits *outside* those checks by construction, which is the point.
- Round 2 added: an adversarial falsification pass (all 11 round-1 findings CONFIRMED-SHARPENED, H11 partial only on the BUGS sub-claim) and a fresh code-review of under-covered surfaces (guards, schemas, generators, portability), which produced the RCE (SCOPE-4), the additional portability breakage (SCOPE-5), and the session-snapshot race (SCOPE-8).
- No files were modified during review. This proposal itself is the only artifact produced, and per G125 it does not mutate `bubbles/*` until the owner approves.
