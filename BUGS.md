# Bubbles Framework — Known Bugs

> **Why this file exists:** the Bubbles source repo cannot keep `specs/` (G085 dogfood guard), so framework-internal defects are tracked here as the operator-visible bug log. Downstream consumer repos file their bugs in their own `specs/<feature>/bugs/BUG-NNN-*/` structure as usual.
>
> Every entry below has an explicit disposition per Gate G095 (Discovered-Issue Disposition).

---

## BUG-001 — state-transition-guard.sh hangs in Check 3G (Framework Ownership And Result Contract)

- **Filed:** 2026-05-27
- **Disposition:** mitigated + items 2/4 hypothesis-invalidated (2026-06-11 empirical re-test) — fail-safe timeout shipped AND the suspected filesystem-walk root cause does NOT exist in the actual Check 3G sub-guard; no hang reproduces in source or any of the 5 downstream layouts. See "Empirical Re-Test (2026-06-11)" below.
- **Discovered by:** `bubbles.goal` session implementing G022/G060/G061 fixes
- **Severity:** low (was medium) — the guard now fails cleanly instead of hanging; selftest converges
- **Affects:** `bubbles/scripts/state-transition-guard.sh` Check 3G (Framework Ownership And Result Contract — gates G042/G063/G064)

### Mitigation Shipped (partial)

Check 3G now wraps its sub-guard invocation in a hard timeout and reports its
wall-clock cost, so the indefinite hang is gone — the check fails safe with a
named error instead of blocking forever:

- `state-transition-guard.sh` ~L765: `bubbles_run_with_timeout 30 bash "$framework_ownership_lint_script"` — on overrun it emits `Framework ownership lint TIMED OUT after 30s (BUG-001 guard)` and counts a failure (item 1 — done for Check 3G).
- `state-transition-guard.sh` ~L779: `warn "Check 3G wall-clock ${_c3g_elapsed}s exceeded the 30s budget"` (item 3 — per-check budget surfaced for Check 3G).
- The same `bubbles_run_with_timeout` wrapper now guards the other heavy sub-invocations (artifact-lint ~L2158, freshness-guard ~L2176, reality-scan ~L2352).

Items 2 & 4 are RECLASSIFIED as hypothesis-invalidated (not a live defect) — see the
Empirical Re-Test below. A full Checks 3–34 timeout audit (item 1 broadened to every
check) remains advisable but is not blocking.

### Empirical Re-Test (2026-06-11)

Re-investigated under a `bubbles.goal` monitoring session. Findings:

- Check 3G's ONLY sub-guard is `agent-ownership-lint.sh` (`state-transition-guard.sh`
  L364: `framework_ownership_lint_script="$SCRIPT_DIR/agent-ownership-lint.sh"`).
- That script contains **no** `find` / `grep -r` / `ls -R` recursive walk, so the
  "filesystem-walk exclusions" root cause (item 2) does not apply to it — it only
  greps a fixed set of known files.
- Measured runtime: **~0.3s** in the source layout and RC=0 / "Agent ownership lint
  passed." in all 5 downstream installed layouts. No hang anywhere.
- The only way its `grep -nE "$pattern" "$file"` helpers could hang is if `grep`
  received **zero** file args and fell back to stdin (verified: that path does hang,
  RC=124 under `timeout`). But every call passes a quoted `"$file"`, and
  `set -euo pipefail` makes an unset path a hard error — so grep always gets exactly
  one file arg and can never block on stdin. A missing/empty file arg returns RC=2
  (clean error), not a hang.

Conclusion: the documented hang does not reproduce in the current sub-guard; items 2
(walk exclusions) and 4 (500-spec walk perf fixture) target a root cause that is not
present. The shipped 30s timeout already makes any hypothetical future regression
fail-safe. If a hang ever recurs, root-cause it in `state-transition-guard.sh`'s own
Check-3G framing or a *different* check — not in a (nonexistent) sub-guard walk.

### Reproduction

```bash
cd /path/to/any/downstream/repo/with/real/spec
timeout 15 bash <bubbles>/bubbles/scripts/state-transition-guard.sh specs/<NNN-feature>
# Observed: process times out (exit 124); last printed line is "--- Check 3G: Framework Ownership And Result Contract (G042/G063/G064) ---"
# Hang occurs AFTER Check 3F completes successfully.
```

Concrete observation during the G022/G060/G061 fix session:

```
✅ PASS: state.json transitionRequests queue is empty
✅ PASS: state.json reworkQueue is empty
✅ PASS: Transition and rework routing is closed

--- Check 3G: Framework Ownership And Result Contract (G042/G063/G064) ---
<hangs indefinitely until SIGTERM>
```

### Suspected Root Cause

> **INVALIDATED 2026-06-11** (see Empirical Re-Test above): the actual Check 3G
> sub-guard `agent-ownership-lint.sh` performs NO recursive filesystem walk and
> runs in ~0.3s across source + all 5 downstream layouts. The walk hypothesis below
> is retained for history only.

Check 3G appears to invoke a sub-guard (likely `agent-ownership-lint.sh` or a packet-routing scanner) without a timeout, OR performs a recursive filesystem walk that touches large generated directories (`.git/`, `node_modules/`, `target/`, `vendor/`, `dist/`, container build caches) without exclusions. Needs root-cause investigation.

### Impact

- `state-transition-guard.sh` cannot complete on real downstream spec dirs in reasonable time (observed >60s, killed at 300s during selftest).
- `state-transition-guard-selftest.sh` runs all 1230 lines through the guard repeatedly and exceeds wall-clock budget on developer machines.
- Forces operators to invoke individual sub-guards instead of the unified entry point.

### Required Fix

1. ~~Add a 30s hard timeout around every sub-guard invocation in Check 3G (and audit Checks 3-34 for the same pattern).~~ **DONE for Check 3G + the heavy sub-invocations** (see Mitigation Shipped above); a full Checks 3–34 audit is still advisable.
2. Add exclusion globs (`.git`, `node_modules`, `target`, `vendor`, `dist`, `__pycache__`, `.bubbles-cache`, container build dirs) to any filesystem walks in Check 3G's sub-guards. **INVALIDATED 2026-06-11** — the Check 3G sub-guard has no filesystem walk; nothing to exclude (see Empirical Re-Test).
3. ~~Add a per-check wall-clock budget reported in the verdict so future regressions surface immediately.~~ **DONE for Check 3G** (budget warn at ~L779); broaden to all checks if the pattern recurs.
4. Add a hermetic perf regression to `tests/regression/` that runs Check 3G against a synthetic 500-spec fixture and fails if elapsed > 5s. **MOOT 2026-06-11** — the sub-guard does not walk specs, so a 500-spec fixture exercises no slow path; a generic per-check wall-clock budget (item 3, broadened) is the better guard if regressions recur.

### Acceptance

- `timeout 60 bash bubbles/scripts/state-transition-guard.sh specs/<real-feature>` returns exit code (any) within 60s on every downstream repo.
- `state-transition-guard-selftest.sh` completes within 5 minutes.
- Per-check wall-clock budget appears in verdict block.

### Cross-References

- Discovered while implementing G022/G060/G061 (commit `1d79931`).
- This bug is the canonical demonstration of Gate G095 (Discovered-Issue Disposition) — it was previously deflected with "pre-existing and unrelated" and is now filed properly.

---

## BUG-002 — MCP stdio transport used Content-Length framing; VS Code's newline-delimited JSON-RPC hung the server

- **Filed:** 2026-06-11
- **Disposition:** fixed (working tree; not committed) — fix + adversarial regression landed across canonical + all 5 vendored copies
- **Discovered by:** operator report — VS Code "Configure Tools" could not populate the `bubbles-<slug>` MCP tool list (the checkbox would not stick; "Update Tools" spun forever)
- **Severity:** high — the stdio MCP server was unusable from VS Code (the primary MCP client): no tool list, no tool calls
- **Affects:** `bubbles/mcp/server.py` → `StdioTransport.read_message` / `write_message` (and the byte-identical vendored copies in all 5 product repos). HTTP transport unaffected.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact
> (reproduction + root cause + expected-behavior spec + fix design + scope/DoD +
> evidence), standing in for the `specs/<feature>/bugs/BUG-NNN-*/` six-file set
> that downstream consumer repos use.

### Reproduction

The MCP stdio transport frames each JSON-RPC message as newline-delimited JSON
(one object per line). VS Code sends exactly that. The pre-fix server used
LSP-style `Content-Length:` header framing for stdio read AND write, so the
line VS Code sends was parsed as an HTTP header block, `Content-Length` was
never found, `read_message` looped on `readline()` and blocked forever — the
server never replied, so "Configure Tools" could not populate the tool list.

Driving the pre-fix server (materialized via `git worktree add --detach HEAD`)
through the adversarial regression suite reproduces the failure modes:

```
test_newline_delimited_object_parses ... FAIL
    AssertionError: None != {'jsonrpc': '2.0', 'id': 1, 'method': 'initialize', 'params': {}}
test_writes_newline_terminated_json_without_header ... FAIL
    AssertionError: b'Content-Length: 45\r\n\r\n{"jsonrpc":"2.0","id":1,"result":{"ok":true}}'
test_newline_framed_handshake_lists_ten_tools ... FAIL
    AssertionError: 1 not found in {} : no initialize reply; stdout=b'' stderr=b''
test_content_length_backcompat ... ok
Ran 7 tests ... FAILED (failures=3, errors=1)
```

### Root Cause (proven)

`StdioTransport.read_message` assumed an LSP-style `Content-Length:` header
block and `write_message` emitted one. MCP stdio is newline-delimited
JSON-RPC 2.0. VS Code sends `{...}\n`; the header parser never finds
`Content-Length`, leaves `content_length=None`, loops on `readline()`, and
blocks indefinitely.

### Expected Behavior (spec)

- stdio read and write MUST be newline-delimited JSON-RPC 2.0 (one object per
  line, terminated by `\n`) per the MCP stdio transport spec.
- A legacy LSP-style `Content-Length` header block MUST still be accepted on
  READ for back-compat.
- The HTTP transport (which legitimately uses `Content-Length`) MUST be
  untouched.

### The Fix

`bubbles/mcp/server.py`:
- `read_message` reads a line, skips blank separator lines, and parses it as a
  JSON object (newline-delimited, primary path). If the line begins with
  `content-length:` it falls back to consuming the legacy header block + body.
- `write_message` writes `payload + b"\n"` with no header.
- The module docstring transport line and the framing comment block above
  `class StdioTransport` were corrected to describe newline-delimited framing
  (legacy Content-Length accepted on read).

`bubbles/scripts/mcp-server-selftest.sh`:
- The in-harness `read_frame()` now reads newline-delimited replies (with a
  legacy Content-Length fallback), mirroring the server. `frame()` still WRITES
  Content-Length so the selftest keeps exercising the server's back-compat read
  path. All T1–T19 stay green.

The `StdioTransport` class body + comment block + docstring transport line are
byte-identical across all 6 copies (canonical + 5 vendored).

### Regression Test

`tests/test_mcp_stdio_framing.py` — stdlib `unittest`, adversarial:
- (a) newline `read_message` returns the parsed dict;
- (b) `write_message` emits JSON + `\n` and contains NO `Content-Length`;
- (c) legacy Content-Length is still accepted on read (back-compat);
- (d) full subprocess handshake (initialize → notifications/initialized →
  tools/list) over NEWLINE framing returns exactly the 10 tools, with a hard
  15 s timeout so a regression fails the test instead of hanging the suite.

Parameterizable via `BUBBLES_MCP_SERVER_PATH` to run the same suite against any
vendored copy.

### Evidence (2026-06-11)

Fixed canonical server — 7/7 pass:

```
server under test: bubbles/mcp/server.py
test_newline_framed_handshake_lists_ten_tools ... ok
test_blank_lines_between_messages_skipped ... ok
test_content_length_backcompat ... ok
test_eof_returns_none ... ok
test_newline_delimited_object_parses ... ok
test_write_read_roundtrip ... ok
test_writes_newline_terminated_json_without_header ... ok
----------------------------------------------------------------------
Ran 7 tests in 0.100s
OK
```

Newline-framed handshake (canonical AND a downstream `~/<repo>/.github/bubbles/mcp/server.py`):

```
initialize.protocolVersion = 2024-11-05
initialize.serverInfo = {"name": "bubbles", "version": "7.7.0"}
tools/list count = 10
tools/list names = ['check_gate', 'list_open_findings', 'query_tool_log', 'read_spec', 'record_evidence', 'resolve_mode', 'route_finding', 'search_code', 'validate_dod', 'verify_status_transition']
MATCHES_EXPECTED_10 = True
```

Existing framework selftest stays green:

```
$ bash bubbles/scripts/mcp-server-selftest.sh
PASS: T1 .. T19 (all)
mcp-server-selftest passed: MCP server boots, dispatches, and surfaces verbatim script output.
MCP_SELFTEST_EXIT=0
```

All 6 `server.py` copies byte-identical after the fix (single sha256
`ee8358600ccc385ef8e59ec0b7cf3342d4b85e8bc892bbf93880ef642a60f7b0`).

### Scope / DoD

- [x] `read_message` newline-primary + Content-Length fallback (canonical)
- [x] `write_message` newline-delimited, no header (canonical)
- [x] docstring + framing comment block corrected (canonical)
- [x] identical code fix propagated to all 5 vendored copies (byte-identical)
- [x] `mcp-server-selftest.sh` `read_frame()` updated; T1–T19 green
- [x] adversarial regression test added; passes fixed, fails pre-fix (3 FAIL + 1 ERROR)
- [x] newline handshake verified on canonical + a downstream copy (10 tools each)

### Vendored-Copy Integrity Guard

Editing the vendored `server.py` in each product repo changes its sha256, which
diverges from the value recorded in that repo's `.github/bubbles/.checksums` and
`.github/bubbles/release-manifest.json` (`bubbles/mcp/server.py` was `bf8ee84…`,
now `ee835860…`). This is detected by `framework-write-guard` / `cli.sh doctor`.
Per Bubbles policy the resolution is NOT to repair the checksum locally but to
land the fix upstream and re-vendor (`/bubbles.setup` / `install.sh`), which
copies the fixed file AND regenerates the snapshot. No guard was disabled,
bypassed, or `--skip`-ed.

### Acceptance

- VS Code "Configure Tools" populates the `bubbles-<repo>` MCP tool list.
- `python3 tests/test_mcp_stdio_framing.py` passes (7/7) against the fixed
  server and fails against the pre-fix server.
- `bash bubbles/scripts/mcp-server-selftest.sh` exits 0 (T1–T19).
- A newline-framed handshake against any of the 6 copies returns the 10 tools.

### Cross-References

- Design surface: `docs/v6-mcp-design.md`, `docs/MCP.md`.
- Regression: `tests/test_mcp_stdio_framing.py`.
- Adjacent selftest: `bubbles/scripts/mcp-server-selftest.sh` (T1–T19).
- Vendored copies (re-sync via `/bubbles.setup`): all 5 downstream installs — each at `.github/bubbles/mcp/server.py`.

---

## BUG-003 — runSubagent dispatch fails with Anthropic 400 — thinking blocks in the latest assistant message are mutated during sub-agent payload construction (extended-thinking + tool-use)

- **Filed:** 2026-06-11
- **Disposition:** external/upstream — NOT a Bubbles framework defect and not fixable in this repo; workaround documented; upstream fix recommended to `microsoft/vscode-copilot-chat` (filing pending a one-time SAML PAT authorization). Per Gate G095 this entry is a tracked EXTERNAL dependency, not an open framework defect.
- **Discovered by:** operator report during a `bubbles.goal` orchestrator session (4 consecutive dispatch failures in one turn)
- **Severity:** high for orchestrator/delegation modes (`bubbles.goal`, `bubbles.workflow`, `bubbles.sprint`) — these perform all implementation via `runSubagent`, so a failed dispatch halts progress for the rest of that turn. No impact on non-orchestrator agents.
- **Affects:** the VS Code Copilot Chat agent runtime's `runSubagent` dispatch payload serializer (`microsoft/vscode-copilot-chat`). NOT any file in this repo. The Bubbles agent definitions are correct.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact. Because
> the defect is UPSTREAM (in the VS Code Copilot Chat agent runtime, not in this
> repo), the entry documents reproduction + root cause + recommended upstream fix
> + confirmed workaround IN LIEU OF an in-repo fix. No code changed in this repo
> for this bug, and none can — there is nothing here to fix.

### Reproduction

Extended-thinking model with interleaved thinking enabled; a long parent turn
with many tool calls and accumulated thinking blocks, including at least one
large (greater than ~8 KB) tool result that triggers the runtime's "large tool
result written to file" content-substitution rewrite; then a `runSubagent`
call. The dispatch fails with an Anthropic `400 invalid_request_error` at
`messages.N.content.M` where that block is a `thinking` / `redacted_thinking`
block (observed locus: `messages.1.content.4` — message index 1, content block
index 4).

### Root Cause (hypothesis)

The sub-agent dispatch harness rebuilds the outbound message array and mutates a
prior assistant message's `thinking` / `redacted_thinking` blocks
(re-serialization, whitespace/key-order normalization, content-block
re-ordering, signature drop, or splicing injected content such as the
large-result-to-file pointer or reminder text) instead of forwarding them
verbatim. Anthropic requires `thinking` blocks on extended-thinking + tool-use
round-trips to be returned byte-for-byte unchanged INCLUDING the signature and
in their original position relative to the `tool_use` block; any change yields a
400.

Tell-tale: a clean stateless sub-agent payload is `[system, user(dispatch
prompt)]` — content index 4 of message 1 (a user message) is never a thinking
block, so a thinking block there is direct evidence the harness is replaying a
parent assistant turn into the sub-agent request and then mutating it.

### Recommended Upstream Fix

Priority order:

1. **Start sub-agents with a clean message history** — build the payload from
   system prompt + dispatch prompt only; do not replay parent thinking-bearing
   assistant turns. If parent context is needed, forward a plain-text summary as
   user content, never replayed assistant thinking blocks. (Primary fix;
   directly explains the `messages.1.content.4` tell.)
2. **(Reframed) Preserve `thinking` / `redacted_thinking` blocks verbatim** —
   applies to the PARENT turn-continuation after the sub-agent returns (text +
   signature, original position). For sub-agent dispatch itself, fix 1
   supersedes (do not forward them at all).
3. **Decouple harness content-substitution from thinking blocks** — the
   large-tool-result-to-file rewrite and reminder injection must touch user-role
   messages ONLY (`tool_result` blocks live in user-role messages and carry no
   signature). Pass assistant messages through verbatim; if an assistant message
   must be edited, strip its thinking blocks entirely and consistently, never
   partially. (Primary fix for the parent-continuation manifestation.)
4. **Fail soft** — detect the modified-thinking-block condition pre-flight (or
   on the 400) and retry once with a thinking-stripped history instead of
   surfacing a raw 400; self-verify by diffing outbound thinking bytes against
   what the model originally returned. (Safety net.)

### Confirmed Workaround

A fresh user turn clears it — the mutated in-turn assistant message is no longer
the latest, so the next turn's dispatch succeeds; no data lost. Operationally
for orchestrator modes: dispatch sub-agents earlier in a turn (before
accumulating many large tool results + thinking blocks) to reduce trigger
probability.

### Triage Note

An earlier note linked the failure to a source file in a downstream product
(an internal agent file that was merely open in the editor at failure time).
That was a RED HERRING — that file uses a plain `Role`+`Content` string message
model over a Python sidecar and cannot emit Anthropic content-block errors.
Route the upstream issue to the sub-agent request serialization path in
`microsoft/vscode-copilot-chat`, NOT to any downstream product or the framework.

---

## BUG-004 — agnosticity-lint flags the installer's own per-repo MCP-id substitution (bubbles-<repo>) downstream; hardcoded project-name list also omits unlisted products

- **Filed:** 2026-06-12
- **Disposition:** fixed (working tree; not committed) — `agnosticity-lint.sh` now derives the repo's own project slug instead of a hardcoded name list, and exempts the installer's `bubbles-<slug>` MCP-id token on agent `tools:` lines; an adversarial selftest case was added. Per Gate G095 this is a resolved discovered-issue. See "The Fix (landed)" below.
- **Discovered by:** a downstream framework upgrade (7.7.0 → 7.11.2) where `bubbles doctor` reported 15 passed / 1 failed in a downstream repo whose project name was on the hardcoded list, while the byte-identical upgrade in another downstream repo (not on the list) reported 16 passed / 0 failed.
- **Severity:** medium — makes `bubbles doctor` report a Framework Integrity failure ("Portable Bubbles surfaces contain project/tool drift") in every downstream repo whose project name is on the hardcoded list. It is **advisory**: it does NOT block the consumer repo's own pre-push, because Bubbles-managed pre-commit/pre-push hooks are installed in the Bubbles SOURCE repo only — consumer repos run their own product pre-push, which does not invoke `bubbles agnosticity-lint` against installed files. But it makes `doctor` permanently red and erodes trust in the check.
- **Affects:** `bubbles/scripts/agnosticity-lint.sh` (the `PROJECT_NAME` rule, around line 157 in canonical) as consumed by `cli.sh doctor` against downstream-installed agent files. Also implicates `bubbles/agnosticity-allowlist.txt` (framework-managed) and the installer's MCP-id substitution in `install.sh`.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this single entry is the full bug artifact —
> reproduction + proven root cause + the fix that landed.

### Reproduction

1. Install/upgrade Bubbles into a downstream repo whose project name was one of
   the hardcoded names in the old `PROJECT_NAME` list — e.g.
   `bash .github/bubbles/scripts/cli.sh upgrade --local-source <bubbles>`.
2. The installer substitutes the per-repo MCP server id into the `tools:` line
   (line 3) of the 5 restricted-orchestrator agents (`bubbles.bug`,
   `bubbles.goal`, `bubbles.iterate`, `bubbles.sprint`, `bubbles.workflow`):
   canonical `tools: [..., bubbles, ...]` becomes
   `tools: [..., bubbles-<slug>, ...]`.
3. `bubbles doctor` (or `agnosticity-lint` run on the INSTALLED files) reports
   `❌ [PROJECT_NAME] agents/bubbles.goal.agent.md:3` for each of the 5 agents,
   then `❌ Portable Bubbles surfaces contain project/tool drift`, giving
   `doctor` a "1 failed" result.

### Root Cause (proven)

- `agnosticity-lint.sh` built its `PROJECT_NAME` detector from a HARDCODED list
  of specific downstream product names (~L157), written with intra-string
  concatenation so the lint script itself did not contain its own banned token:

  ```bash
  grep_project_name="$(printf '%s|' "<product-a>" "<product-b>" "<product-c>")"
  grep_project_name="${grep_project_name%|}"
  ```

- The case-insensitive bounded grep (~L165) then matched a hardcoded product
  name *inside* the installer-substituted token `bubbles-<slug>`
  on the `tools:` line and raised a `PROJECT_NAME` violation:

  ```bash
  grep -niE "(^|[^[:alnum:]_])(${grep_project_name})([^[:alnum:]_]|$)" ...
  ```

  The leading boundary `(^|[^[:alnum:]_])` is satisfied by the `-` in
  `bubbles-<slug>` (a hyphen is not alphanumeric/underscore), and the trailing
  boundary is satisfied by the following `,`/`]`/space — so the embedded project
  name matched.
- The substitution is LEGITIMATE: `install.sh` deliberately rewrites the MCP
  server id to a unique per-repo id (`bubbles-<slug>`) so each repo's
  `.vscode/mcp.json` server is uniquely addressable. The lint has no exemption
  for this installer-owned token, so it flags the framework's own output.

### Why It Was Asymmetric (an unlisted repo passed)

- A downstream repo NOT on the hardcoded list never had its `bubbles-<slug>`
  token matched, so its `doctor` reported 16 / 0 / 0.
- That repo passed by ACCIDENT — and this is itself a coverage hole: a genuine
  project-name leak from an unlisted product into a portable surface would NOT
  be caught.
- So the same bug both (a) false-positived on listed repos and (b) under-checked
  unlisted repos.

### Expected Behavior

- `agnosticity-lint`, when checking downstream-installed agent files, MUST NOT
  flag the installer's own per-repo MCP-id substitution token (`bubbles-<slug>`)
  as project drift. The `PROJECT_NAME` rule should target genuine project-name
  leaks in portable surfaces, not the framework's deliberate per-repo id.
- The check should not depend on a hand-maintained, per-product hardcoded name
  list (which is guaranteed to drift — it already omitted at least one product).

### The Fix (landed)

1. **Exempt the per-repo MCP-id token on `tools:` lines.** When linting
   installed files, derive the repo's own MCP id (from `.vscode/mcp.json` or
   `.github/bubbles-project.yaml`) and skip that exact `bubbles-<slug>` token,
   OR generically treat a `bubbles-<slug>` token on an agent `tools:` array as
   an installer substitution and exempt it. This removes the false positive for
   every downstream repo without weakening real drift detection.
2. **Replace the hardcoded project-name list with a derived value** (the repo's
   own project name/slug) so the check is correct for ANY project and cannot
   omit one (closes the unlisted-product under-checking hole).
3. **Do NOT fix this by adding an entry to `bubbles/agnosticity-allowlist.txt`
   downstream** — that file is framework-managed (listed in
   `release-manifest.json`, overwritten on every upgrade), so a per-repo
   allowlist entry would be wiped on the next upgrade. The fix belongs in
   canonical `agnosticity-lint.sh` + its selftest
   (`agnosticity-lint-selftest.sh`).
4. **Any fix MUST update `agnosticity-lint-selftest.sh`** with an adversarial
   case proving (a) `bubbles-<slug>` on a `tools:` line is allowed, and (b) a
   genuine bare project-name leak in prose/comments is still flagged — so the
   exemption cannot become a hole.

### Workaround

Not needed — the fix has landed. Before the fix, the failure was an advisory
`doctor` result (not a push gate) and the substitution was correct, so operators
could safely ignore the single `doctor` `PROJECT_NAME` failure on the 5
restricted-orchestrator agents.

### Scope Note

The fix (agnosticity-lint slug derivation + `bubbles-<slug>` exemption +
adversarial selftest) landed in the working tree as part of the v7.12.0
PII/agnosticity hardening, alongside scrubbing real downstream product names out
of the framework's docs and test fixtures. Pre-existing: the substituted token
was identical at 7.7.0, so the 7.11.2 upgrade did not introduce this; it merely
made it visible during a `doctor` run.

---

## BUG-005 — state-transition-guard.sh Check 11 is O(forks): ~126s on a large report.md (downstream sweeps appear to "hang")

- **Filed:** 2026-06-14
- **Disposition:** fixed (working tree; not committed) — Check 11's per-line/per-block `echo|grep` fork-storm converted to zero-fork bash builtins; the 8 per-block signal greps collapsed into per-line DISTINCT-category flag accumulation (verdict byte-identical: block legit iff ≥3 lines AND ≥2 distinct categories); the sibling hot loops (Check 4A DoD-format, Check 9 evidence-marker, Check 12 duplicate-evidence) also de-forked; a perf+correctness regression was added to `state-transition-guard-perf-selftest.sh`; `release-manifest.json` regenerated (guard + perf-selftest checksums change). Canonical Bubbles source ONLY — downstream re-vendor of the 5 copies via the release manifest is a separate propagation follow-up. Per Gate G095 this is a resolved discovered-issue, distinct from BUG-001 (Check 3G / `agent-ownership-lint.sh`, which does not cover this inline loop). See "Fix Applied" below.
- **Discovered by:** `bubbles.goal` session driving knb deploy-test-drift remediation (downstream repo `knb`, spec-019 sweep test)
- **Severity:** medium — not a wrong result, but a ~2-minute wall-clock cost per large `report.md` that makes any downstream test/gate invoking the guard with no timeout look hung; CI/pre-push wall-clock inflation
- **Affects:** `bubbles/scripts/state-transition-guard.sh` **Check 11** (Report.md required sections / evidence-block legitimacy), the inline `while IFS= read -r line` loop (canonical ~L2069). Every downstream repo that vendors the guard inherits it (confirmed in `knb`).

### Symptom

A downstream knb test (`tests/deploy/spec_019_sweep_test.sh`, G2 SWEEP-GOVERNANCE) invokes `state-transition-guard.sh specs/019-...` with **no timeout** and captures its output. Against `specs/019-.../report.md` (4888 lines) the guard takes:

```
$ /usr/bin/time -v timeout 200 bash bubbles/scripts/state-transition-guard.sh specs/019-zero-manual-deploy-orchestrator
        Elapsed (wall clock) time (h:mm:ss or m:ss): 2:06.13
  exit: 1
```

2:06 wall clock — long enough that an un-timed caller (the sweep test) reads as a hang. The guard *does* finish and returns a correct verdict (exit 1: the spec is legitimately `blocked`); it is purely a performance defect, not a correctness one.

### Root Cause

Check 11's evidence-block-legitimacy loop forks a subshell **per line** and **8× per closed code block** via the `echo "$var" | grep` anti-pattern:

```bash
while IFS= read -r line; do
  if [[ "$in_block" -eq 0 ]] && echo "$line" | grep -qE '^```'; then      # fork/line
    ...
  elif [[ "$in_block" -eq 1 ]] && echo "$line" | grep -qE '^```$'; then   # fork/line
    ...
    echo "$block_content" | grep -qiE '(passed|failed|ok$|...)' && ...     # 8 forks
    echo "$block_content" | grep -qiE '(exit code|...)'          && ...     #   per
    ... (8 signal greps total) ...                                          #  block
  fi
done < "$report_path"
```

On a 4888-line file that is ~9.8k `echo|grep` forks for the per-line fence test alone, plus 8 more per block. `grep -cE 'echo "\$(line|block_content)" \| grep'` counts **23** such calls in hot per-line/per-block loops; **48** `echo "$x" | grep` anti-patterns exist in the script overall.

BUG-001 shipped `bubbles_run_with_timeout` around heavy **sub-script** invocations (artifact-lint, freshness-guard, reality-scan), but Check 11 is an **inline bash loop**, so it is not wrapped — the fail-safe timeout does not apply here.

### Recommended Fix (not yet implemented)

1. Replace every per-line/per-block `echo "$x" | grep -qE 'pat'` with a **bash builtin** `[[ "$x" =~ pat ]]` (zero fork). Fence detection becomes `[[ "$line" == '```'* ]]`.
2. Collapse the 8 per-block signal greps into a single pass — e.g. accumulate `block_content` and run one `grep -cE '(alt1|alt2|...)'`, or evaluate the 8 alternations with bash regex against the accumulated string — so a block costs O(1) forks (ideally zero) instead of 8.
3. Apply the same builtin conversion to the other hot loops flagged by `grep -nE 'echo "\$(line|...)" \| grep'` (canonical ~L849 DoD scan, ~L1752, ~L1928 evidence-link scan).
4. Re-propagate the canonical fix into the 5 vendored downstream copies via `release-manifest.json` (the guard is framework-managed downstream; `downstream-framework-write-guard.sh` rejects per-repo edits, so the fix MUST land canonical).
5. Add a perf regression guard: a selftest fixture with a synthetic ~5000-line `report.md` asserting the guard completes well under a budget (e.g. < 10s), so the fork-storm cannot regress.

### Reproduction

```
# In any repo with the vendored guard and a large report.md:
/usr/bin/time -v bash .github/bubbles/scripts/state-transition-guard.sh \
  specs/<feature-with-4000+line-report>/   # ~2 min wall clock; dominated by Check 11
```

### Downstream Impact / Workaround

- `knb` `tests/deploy/spec_019_sweep_test.sh` invokes the guard untimed and so appears to hang for ~2 min before the guard's (correct) exit 1 surfaces. That sweep also fails on the merits (spec-019 is `blocked`), so the perf defect is not what's blocking knb — but it masks the real signal behind a 2-minute stall.
- Downstream workaround until the canonical fix lands: wrap the guard call in `timeout` in the consuming test/gate so a slow run fails fast with a named timeout rather than appearing to hang. This is a band-aid; the real fix is the builtin conversion above.

### Fix Applied (2026-06-14)

All four hot loops in `bubbles/scripts/state-transition-guard.sh` were converted from per-line/per-block `echo "$x" | grep -qE` subshell forks to zero-fork bash builtins:

1. **Check 11 (evidence-block legitimacy — the hot path):** fence detection is now `[[ "$line" == '```'* ]]` (open) / `[[ "$line" == '```' ]]` (close). The 8 per-block signal greps are collapsed into **8 per-line category flags** OR'd as each in-block line streams by; at block close `signals` is the sum of the 8 flags and the unchanged `signals < 2` rule applies. The verdict is **byte-identical** — distinct-CATEGORY counting (threshold ≥2), NOT matching-line counting. Case-insensitive categories (i/ii/iv/v/vii — original `grep -qiE`) run under `shopt -s nocasematch`; case-sensitive categories (iii/vi/viii — original `grep -qE`) run with it off. Per-line testing also preserves grep's line-oriented `^`/`$` anchors. The now-unused `block_content` accumulator (an O(n²) string concat) was removed.
2. **Check 4A** (DoD format manipulation), **Check 9** (per-`[x]` evidence-marker scan), and **Check 12** (duplicate-evidence fence detection) had their per-line boolean `echo|grep` tests converted to `[[ =~ ]]` / glob builtins. `grep -oE | sed` EXTRACTION pipelines (which run at most once per matched line) were intentionally left as-is.

A new BUG-005 section in `state-transition-guard-perf-selftest.sh` builds a synthetic ~5000-line `report.md` (≈1000 legitimate filler blocks + one exactly-2-category legit block + one single-category-repeated illegitimate block) and runs the real guard with `BUBBLES_STATE_TRANSITION_GUARD_SELFTEST_FAST=1`. It asserts the guard completes well under budget AND that exactly one illegitimate block is detected (proving the distinct-category semantics survived — a regression to line-counting would pass the repeated-single-category block and fail this assert):

```
  PASS: guard over 6036-line report.md completes in 3s (< 30s; fork-storm was ~126s)
  PASS: Check 11 distinct-category semantics preserved (exactly 1 illegitimate block detected)

[state-transition-guard-perf-selftest] 7 passed, 0 failed
[state-transition-guard-perf-selftest] OK
```

The existing `state-transition-guard-selftest.sh` stays green (≈50 assertions; verdict semantics unchanged), and `release-manifest.json` was regenerated so the guard + perf-selftest checksum changes are recorded. Shipped as v7.12.1.

---

## BUG-006 — state-transition-guard Check 4B (G041) flags a header summary blockquote `> **Status:** …` as a non-canonical scope status

- **Filed:** 2026-06-17
- **Disposition:** fixed (working tree; not committed) — Check 4B (canonicality) and Check 5 (per-scope status counting) now exclude `^>`-prefixed blockquote lines, so a header/summary rollup is never read as a scope status. An adversarial selftest pair was added to `state-transition-guard-selftest.sh`: (a) a fixture with a `> **Status:** all scopes Not Started (planning refreshed …)` header blockquote still passes; (b) a plain `**Status:** Deferred` scope line is STILL flagged non-canonical (no over-exclusion). Selftest green (50+ assertions), perf-selftest green (2s), shellcheck clean. Canonical source only; re-vendors downstream via `release-manifest.json`. Per Gate G095 this is a resolved discovered-issue.
- **Discovered by:** session review of QuantitativeFinance planning-refresh work (2026-06-17) — a `scopes.md` whose top-of-file rollup blockquote read `> **Status:** all scopes Not Started (planning refreshed …)` tripped Check 4B.
- **Severity:** low-medium — no incorrect PASS, but it forces agents to **reword legitimate human-readable summary blockquotes** to satisfy a guard that should ignore them. That inversion (artifact bent to fit the regex) is the exact anti-pattern the framework warns against, and it erodes trust in the guard.
- **Affects:** `bubbles/scripts/state-transition-guard.sh` **Check 4B** (Scope Status Canonicality — Gate G041), canonical ~L900–945. Vendored byte-identical into all 5 downstream repos.

> **Artifact convention:** the Bubbles source repo cannot keep `specs/` (Gate
> G085 dogfood guard), so this entry is the full bug artifact — reproduction +
> proven root cause + expected-behavior spec + scoped fix.

### Reproduction

A `scopes.md` (or `scopes/_index.md`) that carries a top-of-file summary blockquote, e.g.:

```markdown
> **Status:** all scopes Not Started (planning refreshed 2026-06-17)

## Scope 1: …
**Status:** Not Started
```

Run `state-transition-guard.sh specs/<feature>`. Check 4B fails:

```
--- Check 4B: Scope Status Canonicality (Gate G041) ---
❌ Non-canonical scope status detected in scopes.md: 'all scopes Not Started (planning refreshed 2026-06-17)' …
```

### Root Cause (proven)

Check 4B enumerates status lines with an UNANCHORED grep:

```bash
done < <(grep -E '\*\*Status:\*\*' "$scope_path" || true)
```

That matches ANY line containing `**Status:**`, including a Markdown blockquote
(`>`-prefixed) rollup in the header preamble. The value `all scopes Not Started
(planning refreshed …)` strips its parenthetical to base `all scopes Not Started`,
which is not one of the four canonical values (`Not Started` / `In Progress` /
`Done` / `Blocked`) → FAIL. A canonical scope status is a **plain** `**Status:**
<value>` line under a `## Scope N:` heading, never a `>`-quoted summary.

### Expected Behavior

Check 4B validates only genuine per-scope status declarations. A `>`-prefixed
blockquote `**Status:**` line is a human-readable summary/annotation and MUST NOT
be treated as a scope status value.

### Scoped Fix

1. In Check 4B, skip blockquote lines — filter out `^[[:space:]]*>` before the
   canonicality test (e.g. `grep -E '\*\*Status:\*\*' | grep -vE '^[[:space:]]*>'`).
2. **Safety (no bypass):** confirm the completion-reading path (Gate G024
   all-scopes-Done, and any scope-status enumeration that decides Done-ness) also
   ignores blockquote `**Status:**` lines, so a fake `> **Status:** Done` cannot
   smuggle a scope to Done. Align if needed.
3. `state-transition-guard-selftest.sh` gains an adversarial pair: (a) a header
   `> **Status:** all scopes Not Started (planning refreshed)` blockquote no
   longer fails Check 4B; (b) a plain `**Status:** Deferred` scope line is STILL
   flagged non-canonical.
4. Canonical source only; re-vendors downstream via `release-manifest.json`.

---

## BUG-007 — state-transition-guard Check 8C (Shared-Infra Blast-Radius) trigger over-matches benign prose (`session` + `flow`)

- **Filed:** 2026-06-17
- **Disposition:** fixed (working tree; not committed) — the Check 8C trigger's middle-alternation second arm was tightened from `(fixture|fixtures|harness|setup|bootstrap|contract|flow)` to `(fixture|fixtures|harness|bootstrap)`, so a real test-infrastructure noun must co-occur with the infra subject; the `shared|global|common|core` qualifier arm and the specific multi-word-phrase arm (which signal GENUINE shared infra) are unchanged. An adversarial selftest was added: a benign "regression session re-runs the booking user flow" note no longer trips 8C, while the existing genuine shared-fixture positive/negative fixtures STILL trigger it. Selftest green, shellcheck clean. Canonical source only; re-vendors downstream via `release-manifest.json`. Per Gate G095 this is a resolved discovered-issue.
- **Discovered by:** session review of QuantitativeFinance planning work (2026-06-17) — a scope whose Test Plan row described a "regression session" exercising a user "flow" tripped Check 8C's shared-infrastructure trigger, demanding an inapplicable Shared Infrastructure Impact Sweep.
- **Severity:** low-medium — over-broad trigger forces agents to either add an **inapplicable** Shared Infrastructure Impact Sweep (+ canary DoD item + rollback DoD item + canary Test Plan row + downstream-contract enumeration) or **reword legitimate prose** to dodge the keywords. False gating + artifact churn.
- **Affects:** `bubbles/scripts/guards/planning-checks.sh` **Check 8C** (Shared Infrastructure Blast-Radius Planning), canonical ~L129–180; sourced by `state-transition-guard.sh`. Vendored into all 5 downstream repos.

### Reproduction

A scope whose prose / Test Plan contains a benign co-occurrence of a trigger noun
(`session`, `auth`, `login`, `token`, `role`, `context`) and a generic second-arm
word (`flow`, `contract`), e.g. a Test Plan row:

```markdown
| Regression E2E | e2e | … | Regression session re-runs the booking user flow end to end | … |
```

Run the guard. Check 8C fires:

```
--- Check 8C: Shared Infrastructure Blast-Radius Planning ---
❌ Scope touches shared fixture/bootstrap infrastructure but has no Shared Infrastructure Impact Sweep section: Scope N
❌ … missing the canary DoD item …
❌ … missing the rollback/restore DoD item …
```

### Root Cause (proven)

The Check 8C trigger alternation includes generic single words that appear
constantly in ordinary test prose:

```bash
if grep -Eiq '… \b(auth|login|session|password reset|token refresh|tenant context|role detection|storage injection|init script|addinitscript)\b.*\b(fixture|fixtures|harness|setup|bootstrap|contract|flow)\b …' "$scope_path"; then
```

`session … flow` (or `… contract`) on a single line satisfies it. The trigger is
meant to fire on genuine SHARED test-infrastructure changes (global Playwright
setup, auth-fixture bootstrap, `storageState` / `addInitScript` injection), not
any sentence that mentions a session and a flow.

### Expected Behavior

Check 8C fires only when a scope genuinely modifies SHARED fixture / bootstrap /
global-setup infrastructure — not when benign prose co-mentions trigger keywords.

### Scoped Fix

1. Tighten the trigger so a match requires a **shared-scope qualifier**
   (`shared` / `global` / `common` / `core` / `global setup` / `playwright setup`
   / `storageState` / `addInitScript` / `auth fixture` / `login fixture` /
   `bootstrap helper`) **co-occurring with** an infrastructure noun. Drop the bare
   `flow` / `contract` second-arm words and the standalone `session`/`role`/`context`
   arms that over-match generic prose.
2. `state-transition-guard-selftest.sh` (which already exercises a positive Check
   8C fixture at ~L1033) gains an adversarial pair: (a) a benign "regression
   session re-runs the booking user flow" Test Plan row no longer trips 8C;
   (b) a real "modifies the shared Playwright global-setup auth fixture" scope
   STILL requires the Impact Sweep + canary + rollback items.
3. Canonical source only; re-vendors downstream via `release-manifest.json`.

### Relationship to BUG-006 / IMP-009

BUG-006 and BUG-007 are two instances of the same class: a guard trigger/scan
that matches ordinary artifact wording and forces the agent to bend the artifact
to the regex. `improvements/IMP-009` proposes the systemic hardening (structural
matching + a meta-selftest that proves guards do not flag their own fixtures);
these two bugs are the concrete fixes that land first.

---

## BUG-008 — control-plane gates G055–G060 are declared-but-inert (no SST fallback); G060 scenario-first evidence is a keyword rubber-stamp

- **Filed:** 2026-06-18
- **Disposition:** fixed (working tree; not committed) — a two-layer fix landed in `bubbles/scripts/guard-lib.sh` (new `resolve_effective_policy` precedence resolver + `policy_spec_grandfathered` + `detect_red_green_ordering` helpers) and `bubbles/scripts/guards/control-plane-checks.sh` (Checks 3A/3D/3E rewired). Layer 1 ACTIVATES the SST defaults; Layer 2 replaces the G060 keyword grep with a real red→green ordering check; a grandfather clause (cutoff `2026-06-18`, mirroring G094) protects historical snapshot-less specs. A hermetic selftest (`control-plane-policy-activation-selftest.sh`, wired into `framework-validate.sh`) and a persistent regression (`tests/regression/test_21_control_plane_activation.sh`, exercising the REAL guard) prove cases A–E incl. the adversarial keyword-only case. Selftests green, shellcheck clean. Canonical source only; re-vendors downstream via `release-manifest.json`. Per Gate G095 this is a resolved discovered-issue.
- **Discovered by:** control-plane audit (2026-06-18) — empirically ~93% of downstream specs carry no `policySnapshot`, so the v3 control-plane gates that source effective policy ONLY from `policySnapshot` never fired, leaving the SST-declared `grill`/`tdd`/`autoCommit`/`lockdown`/`regression`/`validation` settings inert.
- **Severity:** high — the entire control-plane settings surface (declared in `.specify/memory/bubbles.config.json`) was unenforced for the vast majority of specs, and the one gate that did run for forced-TDD modes (G060) passed on the mere presence of the word "tdd"/"scenario-first" in a report or template, proving nothing about real test-first ordering.
- **Affects:** `bubbles/scripts/guards/control-plane-checks.sh` Checks 3A (G055), 3D (G058/G059), 3E (G060); `bubbles/scripts/guard-lib.sh`; sourced by `state-transition-guard.sh`. Vendored into all 5 downstream repos.

### Reproduction

1. Take any spec whose `state.json` has NO `policySnapshot` (the common case).
2. Run `state-transition-guard.sh` against it. Check 3A (G055) HARD-FAILS on the
   missing snapshot even though the repo SST config declares the provenance, and
   the effective `tdd`/`grill`/`lockdown`/… values are never resolved from the
   SST — the gates are inert.
3. Separately, give any TDD-active spec a `report.md` whose only TDD-related
   content is the literal word `tdd` (no failing-then-fixed proof). Check 3E
   (G060) PASSES via `grep -qiE '…|tdd'` — a rubber stamp.

### Root Cause (proven)

- Checks 3A/3E read effective policy via inline `python3` that consults ONLY
  `state.json.policySnapshot.<section>`; there is no fallback to the repo SST
  defaults in `.specify/memory/bubbles.config.json`. A missing snapshot → inert
  gates (3E silently skips; 3A hard-fails).
- Check 3E's evidence test was `grep -qiE 'red[[:space:]-]*green|failing targeted|red evidence|green evidence|scenario-first|tdd'` — it matches the template word "tdd", so it never proved red-before-green ordering.

### Expected Behavior

- Effective control-plane policy resolves through a precedence chain:
  per-spec `policySnapshot` → repo SST `defaults.<section>.<key>` → framework
  default. A missing snapshot uses the SST config as the provenance of record
  (Check 3A passes with an INFO note); the SST-declared settings actually take
  effect (Check 3E activates when `tdd.mode=scenario-first`).
- G060 passes ONLY when a failing-proof (RED) marker precedes a passing-proof
  (GREEN) marker in the same report; the word "tdd" alone is not evidence.

### The Fix (landed)

1. `guard-lib.sh`: `resolve_effective_policy` / `resolve_effective_policy_source`
   (snapshot → SST config → framework-default precedence, python3-backed, graceful
   when the config is absent), `policy_snapshot_present`, `policy_spec_grandfathered`,
   and `detect_red_green_ordering` (first-RED-line strictly before first-GREEN-line).
2. `control-plane-checks.sh` Check 3A: missing snapshot is no longer a hard fail —
   provenance resolves from the SST config and PASSES; only a missing snapshot AND
   missing SST config remains a fail. Check 3D: surfaces the effective
   `regression.immutability` via the chain. Check 3E: Layer 1 resolves the mode via
   the chain (framework default `scenario-first`); Layer 2 enforces real red→green
   ordering. Existing exempt-handling and the bugfix-fastlane/chaos-hardening
   forced-scenario-first behavior are unchanged.

### Grandfather Clause

A spec with NO `policySnapshot` whose `state.json.createdAt` is missing or strictly
before the cutoff `2026-06-18` has the newly-activated G060 enforcement downgraded
to a grandfathered INFO (never a blocking fail), mirroring the G094 pattern. New
specs (`createdAt ≥ cutoff`) and any spec that DOES carry a `policySnapshot` get
full enforcement. This prevents retro-breaking the ~93% of historical done specs
across the 5 downstream repos.

### Regression / Selftest

- `bubbles/scripts/control-plane-policy-activation-selftest.sh` (hermetic; wired
  into `framework-validate.sh`) — 19 assertions across cases A (activation-from-config),
  B (adversarial keyword-only fails hardened G060 while matching the old grep),
  C (red→green ordering passes), D (grandfather), E (precedence legs + bool).
- `tests/regression/test_21_control_plane_activation.sh` — exercises the REAL
  `state-transition-guard.sh` against staged fixture specs and asserts the Check
  3A fallback + Check 3E activation/fail/pass/grandfather output lines.

### Doc Fix (bundled)

`agents/bubbles.iterate.agent.md` mislabeled the zero-deferral check as "Gate
G036" (which is `red_green_traceability_gate`); corrected to "Gate G040"
(`incomplete_work_language_gate`), matching `agents/bubbles.implement.agent.md`.

---

## BUG-009 — planning-only audit unconditionally requires delivery completion and cannot certify `specs_hardened`

- **Filed:** 2026-07-10
- **Disposition:** confirmed / analyst, UX, technical-design, and implementation
  planning contracts complete; S01-S04 terminal. S04 binds Audit 0-pre/A1 to
  the registry-derived guard result, freezes the profile-aware audit-result and
  attempt contract, and preserves delivery verdict semantics. Current-session
  closeout evidence passes the 22-assertion contract selftest and 24-assertion
  persistent audit-path regression. S05 is Done: validate and finalize now
  re-resolve and bind certification to the one current audit attempt, planning
  promotion is status-only, and the focused cross-boundary regression passes
  48/48. S06 is Not Started; no full-framework, release, propagation,
  downstream, overall fix, or bug closure claim is made
- **Discovered by:** top-level `bubbles.workflow` planning-only auto-escalation,
  parent finding `F151-AUDIT-005`
- **Severity:** high — a valid planning-only workflow cannot complete its
  required audit/finalize chain without either failing audit or fabricating
  implementation files, execution evidence, checked DoD, and Done scopes
- **Affects:** `bubbles/workflows/modes.yaml` (`product-to-planning` and
  `spec-scope-hardening`), the shared mode/transition resolver contract,
  `agents/bubbles.audit.agent.md` Audit 0-pre,
  `agents/bubbles.validate.agent.md`,
  `agents/bubbles_shared/validation-profiles.md` Audit A1,
  `agents/bubbles_shared/scope-workflow.md` finalization,
  `bubbles/scripts/state-transition-guard.sh` Checks 3/4/5/8/11, and the
  associated resolver, guard, audit-contract, installer-provenance, and
  regression selftests
- **Consumer reproduction:** GuestHost
  `specs/151-self-hosted-appliance-packaging`, macOS, workflow mode
  `product-to-planning`, status ceiling `specs_hardened`

> **Source-repo artifact convention:** Gate G085 forbids persistent `specs/` in
> the Bubbles source checkout. Per this file's repository convention, this
> BUG-009 entry is the complete framework-source bug artifact standing in for
> the downstream `bug.md`, `spec.md`, `design.md`, `scopes.md`, `report.md`,
> `uservalidation.md`, `scenario-manifest.json`, and `state.json` packet. It
> therefore contains reproduction, expected-behavior specification, root-cause
> analysis, preliminary design inputs, planning scopes, regression requirements,
> acceptance criteria, evidence, status, and routing in one entry.

### Summary

`product-to-planning` is a planning-only workflow whose registry ceiling is
`specs_hardened`; it deliberately has no implementation or test phase. The mode
still requires `audit`. The audit contract, however, unconditionally treats a
nonzero full `state-transition-guard.sh` result as an automatic failure, while
the guard unconditionally requires delivery-completion state: all DoD checked,
all scopes Done, every planned test file present, and execution-evidence blocks
in every scope report. An honest planning packet therefore cannot pass its
required audit even when its planning gates pass.

GuestHost Spec 151 is the discriminating case: all 18 scopes are intentionally
`Not Started`, all 449 scope DoD items are intentionally unchecked, 203 planned
test contracts name future implementation-owned files, all 203 scope-report
anchors honestly state that no execution evidence exists, all 42 scenarios are
`planned`, and no completed scope or delivery claim exists.

### Reproduction — Before Fix

The canonical source guard and GuestHost-installed guard are byte-identical:

**Phase:** `framework-bug-document`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && shasum -a 256 bubbles/scripts/state-transition-guard.sh /Users/pkirsanov/Projects/GuestHost/.github/bubbles/scripts/state-transition-guard.sh && cmp -s bubbles/scripts/state-transition-guard.sh /Users/pkirsanov/Projects/GuestHost/.github/bubbles/scripts/state-transition-guard.sh; compare_exit=$?; printf 'CANONICAL_INSTALLED_CMP_EXIT=%s\n' "$compare_exit"; exit "$compare_exit"`

**Exit Code:** 0

**Claim Source:** executed

```text
c2ec930748e6c810e75232e72e19284de8c3a27483643113c0ddcd552410f5b7  bubbles/scripts/state-transition-guard.sh
c2ec930748e6c810e75232e72e19284de8c3a27483643113c0ddcd552410f5b7  /Users/pkirsanov/Projects/GuestHost/.github/bubbles/scripts/state-transition-guard.sh
CANONICAL_INSTALLED_CMP_EXIT=0
```

The canonical source guard was then run directly against the consumer target:

**Phase:** `framework-bug-document`

**Command:** `cd /Users/pkirsanov/Projects/GuestHost && bash /Users/pkirsanov/Projects/bubbles/bubbles/scripts/state-transition-guard.sh specs/151-self-hosted-appliance-packaging; guard_exit=$?; printf '\nCANONICAL_GUARD_EXIT=%s\n' "$guard_exit"; exit "$guard_exit"`

**Exit Code:** 1

**Claim Source:** executed

**Output:** bounded raw windows from the preserved 1,030-line transcript; long
terminal lines wrapped at the terminal width

```text
🔴 BLOCK: Test Plan references non-existent file: dashboard/e2e/tests/appliance-supported-surfaces.api.spec.ts
🔴 BLOCK: Test Plan references non-existent file: dashboard/e2e/tests/appliance-acquisition.spec.ts
🔴 BLOCK: Test Plan references non-existent file: tests/shell/appliance_managed_docs_truth_test.sh
✅ PASS: Test file exists: tests/shell/capability_ledger_consistency_test.sh
🔴 BLOCK: Test Plan references non-existent file: tests/shell/appliance_mvp_release_truth_test.sh
🔴 BLOCK: Test Plan references non-existent file: dashboard/e2e/tests/appliance-readiness.spec.ts
🔴 BLOCK: Test Plan references non-existent file: backend/internal/appliance/supported_surfaces_test.go
🔴 BLOCK: Test Plan references non-existent file: backend/tests/integration/appliance_supported_surfaces_integration_test.go
🔴 BLOCK: Test Plan references non-existent file: dashboard/src/features/appliance/support/__tests__/SupportedSurfaceTruth.test.tsx
🔴 BLOCK: 170 of 212 test files from Test Plan DO NOT EXIST
--- Check 8A: Scenario-Specific Regression E2E Coverage ---
ℹ️  INFO: Scope-Kind 'contract-only' for scopes/01-appliance-capability-foundation/scope.md — E2E regression rows not required (v4.1.0 scopeKinds opt-out)
✅ PASS: Scope DoD includes scenario-specific regression E2E requirement: scopes/02-offering-truth-and-support-disclosure/scope.md
✅ PASS: Scope DoD includes broader E2E regression suite requirement: scopes/02-offering-truth-and-support-disclosure/scope.md
✅ PASS: Scope Test Plan includes explicit regression E2E row(s): scopes/02-offering-truth-and-support-disclosure/scope.md
```

```text
--- Check 11: Report.md Required Sections ---
✅ PASS: scopes/01-appliance-capability-foundation/report.md has required report section
✅ PASS: scopes/01-appliance-capability-foundation/report.md has required report section
✅ PASS: scopes/01-appliance-capability-foundation/report.md has required report section
🔴 BLOCK: scopes/01-appliance-capability-foundation/report.md has ZERO evidence code blocks — no execution evidence exists
✅ PASS: No narrative summary phrases detected outside code blocks in scopes/01-appliance-capability-foundation/report.md
✅ PASS: scopes/02-offering-truth-and-support-disclosure/report.md has required report section
✅ PASS: scopes/02-offering-truth-and-support-disclosure/report.md has required report section
✅ PASS: scopes/02-offering-truth-and-support-disclosure/report.md has required report section
🔴 BLOCK: scopes/02-offering-truth-and-support-disclosure/report.md has ZERO evidence code blocks — no execution evidence exists
✅ PASS: No narrative summary phrases detected outside code blocks in scopes/02-offering-truth-and-support-disclosure/report.md
✅ PASS: scopes/03-entitlement-and-release-channel/report.md has required report section
✅ PASS: scopes/03-entitlement-and-release-channel/report.md has required report section
✅ PASS: scopes/03-entitlement-and-release-channel/report.md has required report section
🔴 BLOCK: scopes/03-entitlement-and-release-channel/report.md has ZERO evidence code blocks — no execution evidence exists
```

```text
--- Check 18: Deferral Language Scan (Gate G040) ---
✅ PASS: Zero deferral language found in scope and report artifacts (Gate G040)
--- Check 22: DoD-Gherkin Content Fidelity (Gate G068) ---
✅ PASS: All 42 Gherkin scenarios have faithful DoD items (Gate G068)
--- Check 28: Planning Workflow Chain Enforcement (Gate G091) ---
✅ PASS: Planning workflow chain preserves analyst -> ux -> design -> plan (Gate G091)
--- Check 29: Planning Packet Implementation Linkage (Gate G087) ---
✅ PASS: Planning packet implementation linkage is coherent (Gate G087)
--- Check 29B: Delivery Implementation Delta (Gate G093) ---
✅ PASS: Delivery implementation delta is present or mode ceiling exempts it (Gate G093)
--- Check 34: Capability Foundation Enforcement (Gate G094) ---
✅ PASS: Capability foundation requirements are satisfied, not applicable, or grandfathered (Gate G094)
🔴 TRANSITION BLOCKED: 196 failure(s), 5 warning(s)
state.json status MUST NOT be set to 'done'.
Fix ALL blocking failures above before attempting promotion.
CANONICAL_GUARD_EXIT=1
```

The canonical-path total is 196 because Check 33 also invokes its G090 helper
with the Bubbles source checkout as `--repo-root`, adding one cross-repository
context failure unrelated to this bug. Running the byte-identical installed
guard in its native GuestHost context removes that extra failure and reproduces
the parent finding's exact total:

**Phase:** `framework-bug-document`

**Command:** `cd /Users/pkirsanov/Projects/GuestHost && bash .github/bubbles/scripts/state-transition-guard.sh specs/151-self-hosted-appliance-packaging; installed_guard_exit=$?; printf '\nINSTALLED_GUARD_EXIT=%s\n' "$installed_guard_exit"; exit "$installed_guard_exit"`

**Exit Code:** 1

**Claim Source:** executed

```text
--- Check 28: Planning Workflow Chain Enforcement (Gate G091) ---
✅ PASS: Planning workflow chain preserves analyst -> ux -> design -> plan (Gate G091)
--- Check 29: Planning Packet Implementation Linkage (Gate G087) ---
✅ PASS: Planning packet implementation linkage is coherent (Gate G087)
--- Check 29B: Delivery Implementation Delta (Gate G093) ---
✅ PASS: Delivery implementation delta is present or mode ceiling exempts it (Gate G093)
--- Check 33: Retro Convergence Health Evidence (Gate G090) ---
✅ PASS: Retro convergence health SLO is pass/degraded (Gate G090)
--- Check 34: Capability Foundation Enforcement (Gate G094) ---
✅ PASS: Capability foundation requirements are satisfied, not applicable, or grandfathered (Gate G094)
--- Check 35: Discovered-Issue Disposition (Gate G095) ---
✅ PASS: Discovered-issue disposition clean — no unfiled deferrals (Gate G095)
--- Check 36: Requirement-Mechanism Correspondence (Gate G097) ---
✅ PASS: Requirement-mechanism correspondence satisfied, disclosed, not applicable, or grandfathered (Gate G097)
============================================================
  TRANSITION GUARD VERDICT
============================================================
🔴 TRANSITION BLOCKED: 195 failure(s), 5 warning(s)
state.json status MUST NOT be set to 'done'.
Fix ALL blocking failures above before attempting promotion.
INSTALLED_GUARD_EXIT=1
```

### Observed Versus Expected

**Observed:** mode-aware checks correctly recognize that
`product-to-planning` does not require implementation delta, phase-scope
coherence, implementation reality, or delivery status. Planning gates G040,
G068, G087, G091, G093, G094, G095, and G097 pass. The same guard nevertheless
fails on delivery-only facts that the mode intentionally cannot produce:

- Check 4 collapses 449 honest unchecked DoD items into a blocking completion
  failure.
- Check 5 treats 18 honest `Not Started` scopes as a blocking requirement that
  all scopes be Done.
- Check 8 finds 170 absent future test files among 212 extracted Test Plan file
  references and blocks.
- Check 11 blocks once per scope report because all 18 reports honestly contain
  zero execution-evidence code blocks.
- Audit 0-pre and Audit profile A1 require the aggregate guard to exit 0, so the
  audit cannot issue a clean planning-ceiling verdict.

**Expected:** a workflow whose registry ceiling is below `done` must be audited
against its mode-required planning gates and planning-artifact maturity. It must
not be required to manufacture delivery files, execute future tests, mark
implementation DoD complete, or mark implementation scopes Done. Delivery
completion checks must remain strict and unchanged for modes whose ceiling is
`done`.

### Root Cause (confirmed from exact control paths)

1. **The mode contract and audit phase conflict.**
   `bubbles/workflows/modes.yaml::product-to-planning` declares
   `statusCeiling: specs_hardened`, phase order
   `[analyze, select, bootstrap, harden, docs, validate, audit, finalize]`, no
   implementation/test phase, `focus: planning_only`, and
   `allowImplementationForFindings: false`. Its required gate list is planning
   oriented and does not include delivery-completion gates.
2. **Audit has no ceiling-aware preflight.**
   `agents/bubbles.audit.agent.md::Audit Checklist 0-pre` says the full
   transition guard must run first, any failure automatically yields
   `DO_NOT_SHIP`, and its checklist explicitly requires all DoD checked, all
   scopes Done, Test Plan files on disk, and evidence blocks. Independently,
   `agents/bubbles_shared/validation-profiles.md::Audit A1` requires the state
   transition guard to have no blocking failures. Neither branch resolves the
   mode's ceiling or required gates before applying delivery criteria.
3. **The guard resolves the ceiling but does not use it to activate completion
   checks.** `state-transition-guard.sh` Check 3 resolves
   `state_status_ceiling`; later Checks 4, 5, 8, and 11 do not consult that
   value, the mode's `requiredGates`, `planningOnly`, or whether the requested
   transition is delivery completion. They always require checked DoD, Done
   scopes, physical planned tests, and report evidence respectively.
4. **The current positive selftest is completion-shaped.**
   `state-transition-guard-selftest.sh::emit_base_fixture` creates real test
   files, a `Done` scope, checked DoD, and terminal-style evidence. The
   `product-to-planning/specs_hardened` case clones that fixture and
   `mutate_planning_mode_status` changes only mode/status fields. It proves the
   ceiling token is accepted when delivery evidence already exists; it does not
   exercise an honest planning packet with `Not Started` scopes, unchecked DoD,
   planned absent test files, and explicitly unexecuted reports. No existing
   regression test exercises `bubbles.audit` on that planning-ceiling path.

### BUG-009 Impact

- `product-to-planning` cannot complete its own required phase order on an
  honest, unimplemented packet.
- Auto-escalation can loop between audit and planning/validation even though the
  mode-required planning gates are green.
- The only artifact-level ways to make the aggregate guard green are invalid:
  create implementation-owned test files early, insert fake execution blocks,
  check unperformed DoD, or mark unimplemented scopes Done.
- Anti-fabrication policy and the audit contract therefore pull in opposite
  directions: honest artifacts are rejected, while fabricated delivery shape
  would satisfy the unconditional checks.
- The defect directly applies to the two planning-maturity modes whose phase
  order includes audit but excludes implementation and test:
  `product-to-planning` and `spec-scope-hardening`. Other non-`done` audit modes
  have documentation, validation, pre-activation delivery, or operational
  outcome semantics and MUST NOT inherit a planning exemption merely because
  their ceiling token is not `done`.

### Expected Behavior Specification

1. Audit MUST resolve `workflowMode`, `statusCeiling`, and effective
   `requiredGates` from the workflow registry before selecting transition
   checks.
2. For `product-to-planning`, audit MUST certify at most `specs_hardened` and
   MUST require the planning gates declared by that mode, planning artifact
   coherence, source-edit lockout, ownership/routing closure, and honest
   not-executed state.
3. A planning-only audit MUST accept planned test contracts whose implementation
   files do not yet exist and reports that explicitly carry no execution
   evidence. It MUST reject any claim that those tests ran or those scopes are
   Done.
4. Checks 4, 5, 8, and 11 MUST remain blocking when evaluating a delivery
   transition for a mode whose ceiling is `done`.
5. Unknown modes, unresolved ceilings, contradictory state, source edits under
   G073, and failures in mode-required planning gates MUST fail loud. There may
   be no skip/force/ignore bypass.
6. Audit 0-pre, Audit A1, the guard, and status promotion MUST share one
   registry-derived interpretation of the target ceiling; they must not encode
   separate hardcoded profiles that can drift.

#### Analyst-Owned Outcome Contract

**Intent:** Let the workflow runner, validator, and audit agent confirm that a
planning packet has reached the registry-declared planning maturity ceiling
without representing that packet as implemented, tested, merge-ready,
releasable, or shipped.

**Success signal:** For an otherwise clean `product-to-planning` or
`spec-scope-hardening` packet at `specs_hardened`, the mode-aware audit reports
`PLANNING_AUDIT_CLEAN`; planned-but-absent implementation test files, canonical
`Not Started` implementation scopes, unchecked implementation DoD, and reports
that explicitly state no execution evidence exists do not create delivery
completion failures. The same facts remain blocking under every audit contract
that requires delivered implementation.

**Hard constraints:** The effective audit contract comes from one successfully
resolved workflow registry entry. Planning gates, G073 source-edit lockout,
ownership boundaries, anti-fabrication checks, and status-ceiling enforcement
remain blocking. No mode name, ceiling, gate set, audit class, or caller-supplied
profile may be guessed or defaulted. Planning audit never emits `SHIP_IT`,
`SHIP_WITH_NOTES`, "approved for merge", or equivalent delivery language.

**Failure condition:** The change fails even if a planning fixture turns green
when any delivery mode is weakened, when a planning-gate violation is hidden,
when unknown or contradictory metadata is accepted, when planning maturity is
described as shipment, or when fake files/evidence are needed to obtain the
planning verdict.

#### Single-Capability Justification

BUG-009 is a narrow correction inside the existing workflow-mode resolution,
validation, transition-guard, and audit foundation. It does not introduce a new
provider, plugin, product capability, or independent consumer contract. The
registry already carries the concrete mode variants and their evidence
semantics; requiring those existing consumers to share one resolved contract is
coherence work, not justification for a new capability framework. Technical
foundation/overlay choices remain with `bubbles.design`.

#### Registry-Backed Affected Mode Matrix

Inventory rule: every current entry in `bubbles/workflows/modes.yaml` whose
explicit `statusCeiling` is not `done` and whose `phaseOrder` contains `audit`.
There are 24 such modes. A non-`done` token is an inventory filter, not an audit
policy: the registry's description, phase order, required gates, constraints,
and `modeClass`/`focus` determine the evidence semantics.

| Classification | Modes | Ceiling | Registry evidence and BUG-009 disposition |
| --- | --- | --- | --- |
| Directly affected: planning maturity | `spec-scope-hardening`, `product-to-planning` | `specs_hardened` | Both include `audit`, exclude `implement`/`test`, focus on specs/scopes or `planning_only`, and set `allowImplementationForFindings: false`. They require a planning-maturity audit that does not demand delivery completion. |
| Adjacent, documentation-specific | `docs-only` | `docs_updated` | Declares `modeClass: docs-only`, phase order `[select, docs, validate, audit, finalize]`, and no planning-truth mutation. The unconditional full guard may also be over-broad here, but this mode is not planning maturity and has no BUG-009 reproduction; it requires an explicit docs audit contract, not the planning exemption. |
| Adjacent, validation-specific | `audit-only`, `validate-to-doc` | `validated` | `audit-only` is for "already validated scopes" and declares `modeClass: validate-only`; `validate-to-doc` is final quality verification without rerunning tests. Existing delivery evidence may therefore be a valid precondition. Neither mode may be classified as planning from its ceiling alone. |
| Delivery rigor unchanged | `adapter-readiness-to-packet`, `dark-launch-shipped`, `migration-shipped-pending-cutover` | `delivered_pending_activation` | All include `implement`, `test`, `validate`, and `audit`; require deliverable manifests and per-DoD evidence; and require all scopes Done. Only explicitly declared lockdown evidence may remain pending. Checks 4, 5, 8, and 11 stay strict except where an existing lockdown contract already governs them. |
| Release-train operation | `release-train-cut`, `release-train-promote`, `release-train-rollback`, `release-train-retire`, `release-train-status-all` | `train_cut`, `train_promoted`, `train_rolled_back`, `train_retired`, `train_status_reported` | All declare `modeClass: release-train`; their evidence concerns train registry, signed manifests, soak/backup/restore facts, pointer swaps, flag cleanup, or read-only status. These are operation outcomes, not spec maturity. |
| Upkeep operation | `upkeep-restore-drill`, `upkeep-bcdr-drill`, `upkeep-patch-cycle`, `upkeep-secret-rotation`, `upkeep-flag-cleanup`, `upkeep-compliance-sweep` | `restore_verified`, `bcdr_verified`, `patched`, `secrets_rotated`, `flags_audited`, `compliance_swept` | All declare `modeClass: upkeep`; evidence is calendar-, isolation-, ledger-, security-, or compliance-specific. `upkeep-backup-verify` is excluded because its phase order has no `audit`. |
| Propagation operation | `propagate-forward`, `propagate-backport`, `propagate-audit` | `propagated_forward`, `propagated_backward`, `propagation_audited` | All declare `modeClass: propagation`; evidence concerns policy edges, approval, receiving-train validation, and append-only ledger behavior. They are not planning or feature-delivery transitions. |
| Incident operation | `incident-fastlane` | `incident_mitigated` | Declares `modeClass: incident`; audit confirms severity routing, rollback authority, redeploy, and live rollback validation. It is not eligible for planning exemptions. |
| Framework observation | `framework-health` | `framework_proposal_written` | Declares `modeClass: framework-self-observation`, `auditOnly: true`, and forbids framework auto-mutation. Audit concerns evidence-backed proposal output, not spec delivery. |

Modes with `docs_updated`, `validated`, or another custom terminal status but no
`audit` token in `phaseOrder` are outside this inventory. Modes that inherit a
`done` ceiling remain delivery modes even when the raw mode entry omits an
explicit `statusCeiling`.

#### Actors And Permission Boundaries

| Actor | Goal | Authority and boundary | Grounding |
| --- | --- | --- | --- |
| Workflow runner | Complete the selected mode through its real terminal ceiling | Resolves the registry entry, enforces phase order/source lockout, and passes one immutable effective audit contract downstream; cannot promote beyond the ceiling or reinterpret a planning mode as delivery | `bubbles/workflows/modes.yaml`; `agents/bubbles.workflow.agent.md` planning lockout |
| Audit agent | Independently judge the evidence required for the resolved mode | May emit a class-appropriate verdict and route findings; cannot fabricate delivery evidence, mutate foreign artifacts, or use delivery wording for planning maturity | `agents/bubbles.audit.agent.md` Audit 0-pre and verdict table |
| Validator | Establish the pre-audit gate verdict from the same mode contract | Runs universal and mode-required checks and reports blockers; cannot certify a different target/profile from the audit agent or silently ignore a failed required gate | `agents/bubbles_shared/validation-profiles.md` A1 and `agents/bubbles.validate.agent.md` guard contract |
| Framework maintainer | Change the shared guard/audit behavior without weakening delivery assurance | Owns canonical framework source, regression coverage, release-manifest propagation, and compatibility review; cannot patch downstream installed copies or add bypasses | `.specify/memory/agents.md`; canonical/installed parity evidence above |
| Downstream product owner | Receive an honest statement of planning or delivery maturity | May rely on `specs_hardened` as planning quality only and on delivery verdicts only when delivery evidence passed; is never asked to create fake files or check unperformed work | GuestHost Spec 151 reproduction and `F151-AUDIT-005` provenance |

#### Use Cases

##### UC-009-01 — Resolve A Planning Audit Contract

- **Actor:** Workflow runner
- **Preconditions:** A target packet names a workflow mode present in the
  registry; its persisted mode metadata is internally consistent.
- **Main flow:** Resolve the effective mode; verify `statusCeiling`,
  `phaseOrder`, `requiredGates`, and constraints; classify it as planning
  maturity; pass the same resolved contract to validator and audit; stop final
  status at `specs_hardened`.
- **Alternative flow:** Missing, unknown, malformed, or contradictory metadata
  returns `blocked` before a positive audit verdict or phase-completion claim.
- **Postcondition:** The audit target is explicit and cannot drift between
  runner, validator, guard, and audit agent.

##### UC-009-02 — Audit Honest Planning Maturity

- **Actor:** Audit agent
- **Preconditions:** Validation used the same resolved planning contract and
  found no universal or mode-required planning-gate blocker.
- **Main flow:** Verify planning artifacts, traceability, source lockout,
  ownership/routing closure, canonical incomplete scope state, and absence of
  fabricated execution claims; emit `PLANNING_AUDIT_CLEAN`.
- **Alternative flow:** A planning requirement, planning gate, source lockout,
  ownership rule, or honesty check fails; emit `PLANNING_REWORK_REQUIRED` or a
  machine-readable `blocked`/`route_required` outcome without delivery wording.
- **Postcondition:** The result proves planning maturity only.

##### UC-009-03 — Validate The Same Target The Auditor Sees

- **Actor:** Validator
- **Preconditions:** The workflow runner supplied a resolved effective mode
  contract rather than an untrusted caller-selected exemption.
- **Main flow:** Apply universal checks plus the registry-required planning
  gates; report planned delivery artifacts as not-yet-required; preserve every
  real planning blocker for audit.
- **Alternative flow:** The requested status exceeds the ceiling or metadata
  conflicts with state/policy snapshot; fail loud.
- **Postcondition:** Audit A1 consumes the validator's mode-aware verdict rather
  than reinterpreting a raw full-delivery guard exit.

##### UC-009-04 — Preserve Delivery Assurance

- **Actor:** Framework maintainer
- **Preconditions:** A delivery or pre-activation delivery mode resolves
  successfully.
- **Main flow:** Require completed scopes, applicable DoD evidence, existing
  required tests, report evidence, and all delivery gates exactly as before;
  run an adversarial control using the honest planning fixture under delivery
  semantics.
- **Alternative flow:** Any planning exemption reaches a delivery mode; treat
  the regression as blocking.
- **Postcondition:** No delivery-capable mode becomes easier to pass because of
  BUG-009.

##### UC-009-05 — Interpret The Maturity Result

- **Actor:** Downstream product owner
- **Preconditions:** The audit output names the workflow mode, ceiling, audit
  class, and verdict.
- **Main flow:** Read `PLANNING_AUDIT_CLEAN` as permission to continue the
  mandated planning/delivery chain, not as approval to merge, release, deploy,
  or claim implementation.
- **Alternative flow:** Output contains shipment wording for a planning class
  or omits its ceiling; treat it as invalid and require re-audit.
- **Postcondition:** Human and machine consumers draw the same maturity claim.

#### Lifecycle And Verdict Vocabulary

| Concept | Required vocabulary | Policy |
| --- | --- | --- |
| Planning terminal status | `specs_hardened` | Terminal-for-mode for the two planning modes; never aliases `done`, delivered, merge-ready, or shipped. |
| Planning positive audit verdict | `PLANNING_AUDIT_CLEAN` | Means the mode-required planning contract is clean at its ceiling. It is not a delivery certification and does not authorize status `done`. |
| Planning negative audit verdict | `PLANNING_REWORK_REQUIRED` plus `route_required` or `blocked` machine outcome as applicable | Names the failed planning/universal obligation and owner. It must not say `DO_NOT_SHIP`, because shipment was never under evaluation. |
| Delivery audit verdicts | Existing `SHIP_IT`, `SHIP_WITH_NOTES`, `REWORK_REQUIRED`, `DO_NOT_SHIP` | Remain unchanged for delivery audit semantics, including all anti-fabrication rigor. |
| Scope lifecycle | `Not Started`, `In Progress`, `Done`, `Blocked` | Canonical vocabulary remains unchanged. Planning audit permits honest incomplete implementation scopes; any scope claiming `Done` remains subject to evidence integrity checks. |
| Mode terminal status | Exact registry `statusCeiling`/`terminalAliases` | Documentation, validation, pre-activation delivery, and operational tokens retain their own meaning; they are not inferred from lexical ordering around `done`. |
| Metadata failure | `blocked` with the unresolved field/contradiction named | Unknown mode, unresolved ceiling/gates/audit semantics, conflicting top-level/policy mode, or incompatible phase/constraint metadata cannot fall back to planning or delivery behavior. |

#### Business Policies

1. **BP-009-01 — Registry authority:** Audit obligations MUST be selected from
   one fully resolved registry contract, not from status text, mutable prose,
   mode-name pattern matching, or a caller-provided skip profile.
2. **BP-009-02 — Explicit audit semantics:** A mode is planning maturity only
   when its effective contract explicitly establishes planning-only behavior.
   `statusCeiling != done` alone is never sufficient.
3. **BP-009-03 — Honest absence:** Under planning semantics, absence of future
   implementation/test/evidence artifacts is expected; a contradictory claim
   that they exist or ran is a blocker.
4. **BP-009-04 — Universal checks stay universal:** Registry integrity, mode
   consistency, ceiling enforcement, canonical artifact shape, ownership,
   planning traceability, source lockout, and anti-fabrication remain active.
5. **BP-009-05 — Delivery isolation:** Planning exemptions MUST NOT alter
   delivery or pre-activation delivery evidence requirements.
6. **BP-009-06 — Terminology integrity:** Positive planning output MUST name
   planning maturity and MUST NOT contain shipping, release, deploy, merge
   approval, or delivered language.
7. **BP-009-07 — Fail-loud metadata:** Unknown, missing, malformed, or
   contradictory mode metadata yields no inferred profile and no positive
   phase claim.

#### Acceptance Scenarios

##### Scenario A — Clean product-to-planning packet reaches planning maturity

```gherkin
Given a registry-resolved product-to-planning packet at specs_hardened
And all mode-required planning and universal gates pass
And implementation scopes are Not Started with unchecked implementation DoD
And planned implementation test files and execution evidence do not yet exist
When validator and audit evaluate the same effective mode contract
Then the planning audit verdict is PLANNING_AUDIT_CLEAN
And the terminal status remains specs_hardened
And no shipping, merge, release, deploy, or delivery claim is emitted
```

##### Scenario B — Spec-scope hardening receives the same planning policy

```gherkin
Given spec-scope-hardening resolves to specs_hardened
And its phase order contains audit but no implement or test phase
When an honest unimplemented packet satisfies its required planning gates
Then incomplete delivery facts do not block planning maturity
And delivery completion is not claimed
```

##### Scenario C — A planning violation remains blocking

```gherkin
Given a product-to-planning packet with one failed required planning gate
When audit evaluates the packet
Then the result is PLANNING_REWORK_REQUIRED
And the failed gate and owning route are reported
And absent delivery artifacts do not hide or replace the real planning failure
```

##### Scenario D — Source changes remain forbidden during planning

```gherkin
Given a clean planning packet whose working change set contains an undeclared framework source edit
When the planning audit evaluates G073
Then the audit is blocked
And no planning-clean verdict or phase-completion claim is recorded
```

##### Scenario E — Fabricated planning execution evidence is rejected

```gherkin
Given a planning-only packet that claims a future test ran or an unimplemented scope is Done
And the claim lacks genuine execution evidence
When the planning audit evaluates evidence integrity
Then the audit rejects the fabricated claim
And does not require fabrication as a condition of planning maturity
```

##### Scenario F — The same incomplete packet fails delivery audit

```gherkin
Given the honest planning fixture is evaluated under a done-ceiling delivery contract
When the delivery guard evaluates DoD, scope status, test files, and reports
Then Checks 4, 5, 8, and 11 remain blocking
And no planning exemption is applied
```

##### Scenario G — Pre-activation delivery retains ship-time rigor

```gherkin
Given adapter-readiness-to-packet, dark-launch-shipped, or migration-shipped-pending-cutover is selected
When audit evaluates the resolved delivered_pending_activation contract
Then implementation, test, all-scope-Done, and per-DoD evidence requirements remain active
And only evidence explicitly governed by the existing lockdown contract may remain pending
```

##### Scenario H — A validated mode is not inferred to be planning

```gherkin
Given audit-only or validate-to-doc is selected
When the resolver observes statusCeiling validated
Then it does not classify the mode as planning from the ceiling alone
And it applies the explicit validated-mode evidence contract or fails loud if none can be resolved
```

##### Scenario I — An operational terminal token uses operational evidence

```gherkin
Given an audit-bearing release-train, upkeep, propagation, incident, or framework-health mode is selected
When audit resolves the modeClass and required gates
Then it evaluates that operation's declared evidence
And it neither applies planning exemptions nor treats a generic feature-delivery checklist as proof of the operation
```

##### Scenario J — Unknown mode metadata fails loud

```gherkin
Given state references a workflow mode absent from the effective registry
When validator or audit attempts to resolve its ceiling and required gates
Then the result is blocked
And no fallback audit profile, positive verdict, or phase-completion claim is emitted
```

##### Scenario K — Contradictory mode metadata fails loud

```gherkin
Given top-level state, policy snapshot, or resolved constraints disagree about the active mode or audit semantics
When the workflow runner prepares audit
Then the contradiction is reported as blocking
And neither planning nor delivery semantics are guessed
```

##### Scenario L — Planning output is terminology-safe

```gherkin
Given a planning audit passes every applicable check
When human-readable and machine-readable results are rendered
Then the human verdict is PLANNING_AUDIT_CLEAN
And the output names workflowMode product-to-planning and ceiling specs_hardened
And SHIP_IT, SHIP_WITH_NOTES, approved for merge, and equivalent delivery wording are absent
```

#### Compatibility And Non-Goals

- Preserve the current workflow mode names, terminal aliases, required gates,
  canonical scope-status vocabulary, and downstream state shape unless the
  design owner proves a schema change is necessary.
- Preserve Audit A2-A6 and every delivery anti-fabrication obligation; this bug
  changes selection of applicable completion checks, not the evidentiary bar
  for checks that apply.
- Do not convert `docs-only`, validated, pre-activation delivery, or operational
  modes into planning modes. Their mode-specific audit contracts are adjacent
  compatibility inputs, not permission for a broad non-`done` exemption.
- Do not add skip/force/ignore flags, mode-name hardcodes, mutable-prose
  inference, synthetic files, placeholder evidence, or caller-controlled audit
  profiles.
- Do not change source, agent contracts, workflow registries, tests,
  `CHANGELOG.md`, installer/release manifests, or downstream installed copies
  during this planning chain.
- Do not mark BUG-009 fixed, verified, closed, or delivered until implementation,
  pre-fix/post-fix regression evidence, canonical validation, propagation, and
  the GuestHost consumer reproduction are complete.

#### UX Handoff Contract

`bubbles.ux` owns the next planning step: define the operator-visible audit
flow for `PLANNING_AUDIT_CLEAN`, `PLANNING_REWORK_REQUIRED`, and metadata-blocked
results; make mode, ceiling, applicable check class, skipped-as-not-applicable
delivery checks, and owner routing legible without color or emoji; and ensure
no planning state can be mistaken for merge, release, deploy, or shipment
approval. UX must preserve the existing delivery verdict presentation for
delivery audit semantics.

### UX-Owned Operator Experience Contract

This section specifies the operator-facing control-plane experience. It does
not choose the guard architecture, add a command or flag, alter registry
semantics, or authorize source/test changes. `bubbles.design` owns those
technical decisions. The CLI is a compact audit transcript: no cards, badges,
decorative borders, animated progress, or marketing language.

#### Operator Mental Model And Phase Flow

The operator sees one resolved audit attempt move through six append-only
phases. Every phase line carries the same `runId` and `attemptId`; completed
lines are never rewritten in place.

```text
audit requested
  |
  v
[1/6 resolve contract] -- unknown or contradictory --> blocked
  |
  v
[2/6 open attempt] ---- supersede stale prior result, if any
  |
  v
[3/6 select checks] ---- universal + explicit mode audit class
  |
  v
[4/6 evaluate] --------- PASS | FAIL | NOT_APPLICABLE per check
  |                         |                    |
  |                         | planning class     | delivery class
  |                         v                    v
  |                   planning rework      delivery refused
  v
[5/6 decide] ------------ one verdict from this attempt only
  |
  v
[6/6 persist and route] -- current result + evidence refs + concrete owner
```

| Phase | Required operator-visible facts | Failure behavior |
| --- | --- | --- |
| `1/6 resolve contract` | Target, registry-derived `workflowMode`, `modeClass`, `auditClass`, `statusCeiling`, contract reference, and contract digest | Missing, unknown, malformed, or contradictory values produce `blocked`; no audit class is guessed. |
| `2/6 open attempt` | `runId`, new `attemptId`, target revision/fingerprint, and any superseded attempt | A second current attempt or mismatched provenance produces `blocked` with `AUDIT_PROVENANCE_CONFLICT`. |
| `3/6 select checks` | Applicable check classes and every `NOT_APPLICABLE` check with its registry-derived reason | A delivery check may be `NOT_APPLICABLE` only for an explicitly resolved planning-maturity contract. |
| `4/6 evaluate` | One line per applicable gate/check, stable ID, result, and evidence reference | Planning failures route as planning rework; delivery failures retain existing delivery refusal semantics; G073 blocks before a positive verdict. |
| `5/6 decide` | One verdict, separate planning and delivery evaluation states, and the exact status eligible for certification | No partial, interrupted, or contradictory attempt can emit a positive verdict or status claim. |
| `6/6 persist and route` | Current-result state, complete finding accounting, evidence references, and concrete next owner or `none` | Persistence failure leaves the attempt `INCOMPLETE`; a terminal-only success line is not a certification record. |

#### Reusable CLI Output Primitives

Every view composes the same primitives in this order so operators can scan
different audit classes without relearning the layout:

1. **Identity header:** target, mode, class, ceiling, run, and attempt.
2. **Verdict line:** the class-appropriate verdict token, never a synonym.
3. **Evaluation pair:** separate `planning` and `delivery` statements.
4. **Check ledger:** applicable checks first, then explicit
   `NOT_APPLICABLE` checks; omitted checks are forbidden.
5. **Evidence list:** concise references with provenance, not a replacement for
   preserved raw command output.
6. **Route footer:** current status effect, finding IDs, and one concrete next
   owner or `none`.
7. **Stable result record:** the fixed `AUDIT_RESULT_V1` field block consumed by
   the workflow runner and log tooling.

The primitives are line-oriented. A section does not nest inside another
section, and values that wrap use a two-space continuation indent.

#### Canonical Verdict And Status Vocabulary

| Human text | Stable fields | Exact meaning | Forbidden inference |
| --- | --- | --- | --- |
| `planning ceiling certified` | `auditVerdict: PLANNING_AUDIT_CLEAN`, `planningEvaluation: CERTIFIED` | The explicit planning contract passed and `certifiedStatus` equals its registry ceiling. | Implemented, tested, merge-ready, releasable, deployable, delivered, or shipped. |
| `delivery not evaluated` | `deliveryEvaluation: NOT_EVALUATED` | Delivery-completion checks were outside this explicitly resolved audit class. | Delivery passed, delivery failed, or those checks were silently skipped. |
| `planning rework required` | `auditVerdict: PLANNING_REWORK_REQUIRED`, `planningEvaluation: REWORK_REQUIRED` | The planning contract was evaluable and at least one applicable planning/universal obligation failed. | Metadata uncertainty or a delivery refusal. |
| `delivery refused` | Existing delivery verdict plus `deliveryEvaluation: REFUSED` | A delivery-completion contract was evaluated and failed its unchanged completion requirements. | A planning-only result or a generic metadata block. |
| `blocked` | `auditVerdict: BLOCKED`, `outcome: blocked` | Audit semantics or a universal precondition could not be established safely, so neither maturity class receives a verdict. | Planning rework, delivery refusal, or permission to choose a fallback profile. |
| `interrupted` | `auditVerdict: INTERRUPTED`, `resultState: INCOMPLETE` | The current attempt ended before a persistable decision. | The most recent prior result is still current. |
| `superseded` | `resultState: SUPERSEDED` | A historical attempt was replaced by a newer attempt and remains history only. | Active certification or reusable current provenance. |

For planning-maturity output, `SHIP_IT`, `SHIP_WITH_NOTES`, `DO_NOT_SHIP`,
`approved for merge`, and equivalent delivery language are prohibited. For a
delivery-completion audit, existing `SHIP_IT`, `SHIP_WITH_NOTES`,
`REWORK_REQUIRED`, and `DO_NOT_SHIP` semantics remain unchanged; the mode-aware
renderer adds class and evaluation fields but does not rename or soften them.

#### Stable Machine-Readable Result Record

Every terminal result ends with exactly one plain-text block in the field order
below. Every field is present. Empty scalar values use `none`; empty collections
use `[]`. Tokens, field names, enum values, gate IDs, and agent IDs are ASCII,
case-sensitive, and never localized. Human prose may wrap, but this block does
not depend on terminal color, cursor position, or display width.

```text
BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: [workflow-run-id]
attemptId: [audit-attempt-id]
target: [artifact-path]
targetRevision: [artifact-fingerprint]
workflowMode: [registry-mode-or-UNRESOLVED]
modeClass: [registry-mode-class|none|UNRESOLVED]
auditClass: [planning-maturity|delivery-completion|explicit-mode-class|UNRESOLVED]
statusCeiling: [registry-status-or-UNRESOLVED]
requestedStatus: [requested-status-or-none]
auditVerdict: [verdict-token]
outcome: [completed_diagnostic|route_required|blocked]
resultState: [ACTIVE|SUPERSEDED|INCOMPLETE]
certifiedStatus: [status-or-none]
planningEvaluation: [CERTIFIED|REWORK_REQUIRED|NOT_EVALUATED]
deliveryEvaluation: [CERTIFIED|REFUSED|NOT_EVALUATED]
sourceEditLockout: [PASS|FAIL|NOT_EVALUATED]
applicableCheckClasses: [comma-separated-classes]
notApplicableChecks: [check-ids]
passedGateIds: [gate-ids]
failedGateIds: [gate-ids]
failedChecks: [check-ids]
blockingCode: [stable-code-or-none]
unresolvedFields: [field-names]
contradictions: [field=value-pairs]
contractRef: [registry-reference-or-none]
contractDigest: [digest-or-UNRESOLVED]
evidenceRefs: [ordered-references]
addressedFindings: [finding-ids]
unresolvedFindings: [finding-ids]
nextRequiredOwner: [bubbles.agent-or-none]
supersedesAttemptId: [attempt-id-or-none]
resumeFromPhase: [phase-number-or-none]
END AUDIT_RESULT_V1
```

`resultState: ACTIVE` means only that this is the sole current result for the
exact target revision and contract digest. It does not mean successful.
`certifiedStatus` is non-`none` only after a clean class-appropriate verdict.
The human summary and result block MUST be projections of one result record; a
renderer may not compute or infer either independently.

#### Evidence Presentation

The concise view shows enough provenance to explain the decision without
flooding the terminal with the full guard transcript:

| Evidence class | What is shown | Required provenance behavior |
| --- | --- | --- |
| Effective contract | Registry reference, exact mode/ceiling/class, and digest | All downstream check selection cites this same digest. |
| Target identity | Artifact path and revision/fingerprint | A changed fingerprint invalidates any prior current summary. |
| Applicable checks | Gate/check ID, `PASS` or `FAIL`, and evidence reference | A positive verdict requires a non-empty reference for every applicable check group. |
| Non-applicable delivery checks | Exact check IDs and reason `auditClass=planning-maturity` | Render as `NOT_APPLICABLE`, never `PASS`, `SKIP`, or omission. |
| Source lockout | G073 result plus changed-path evidence when failed | A failure blocks before planning or delivery certification. |
| Honesty state | Scope/DoD/test/report state and anti-fabrication result | Honest absence is described as planning input, not delivery proof. |
| Finding accounting | Stable finding ID, status, evidence reference, and owner | A finding remains addressed or unresolved across rework; it never disappears. |

Raw execution output remains in its canonical evidence location and is reached
through `evidenceRefs`. The summary must not manufacture counts, collapse a
failed gate into a generic message, or present inherited evidence as executed
by the current attempt.

#### Canonical CLI View — Clean Planning Ceiling

```text
AUDIT RESULT
target: specs/151-self-hosted-appliance-packaging
mode: product-to-planning
audit class: planning-maturity
ceiling: specs_hardened
verdict: PLANNING_AUDIT_CLEAN

EVALUATION
planning: planning ceiling certified
delivery: delivery not evaluated
certified status: specs_hardened

CHECKS
applicable: universal, planning-maturity
passed gates: G040, G068, G087, G091, G093, G094, G095, G097
not applicable: delivery-completion Checks 4, 5, 8, 11
failed: none

EVIDENCE
contract: bubbles/workflows/modes.yaml#product-to-planning ([contract-digest])
planning gates: [planning-gate-evidence-ref]
source-edit lockout: G073 PASS ([source-lockout-evidence-ref])
honesty state: unimplemented delivery facts declared, not claimed complete

ROUTE
next owner: none
workflow action: finalize this mode at specs_hardened

BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: [workflow-run-id]
attemptId: [audit-attempt-id]
target: specs/151-self-hosted-appliance-packaging
targetRevision: [artifact-fingerprint]
workflowMode: product-to-planning
modeClass: none
auditClass: planning-maturity
statusCeiling: specs_hardened
requestedStatus: specs_hardened
auditVerdict: PLANNING_AUDIT_CLEAN
outcome: completed_diagnostic
resultState: ACTIVE
certifiedStatus: specs_hardened
planningEvaluation: CERTIFIED
deliveryEvaluation: NOT_EVALUATED
sourceEditLockout: PASS
applicableCheckClasses: [universal,planning-maturity]
notApplicableChecks: [Check-4,Check-5,Check-8,Check-11]
passedGateIds: [G040,G068,G087,G091,G093,G094,G095,G097]
failedGateIds: []
failedChecks: []
blockingCode: none
unresolvedFields: []
contradictions: []
contractRef: bubbles/workflows/modes.yaml#product-to-planning
contractDigest: [contract-digest]
evidenceRefs: [planning-gate-evidence-ref,source-lockout-evidence-ref]
addressedFindings: []
unresolvedFindings: []
nextRequiredOwner: none
supersedesAttemptId: none
resumeFromPhase: none
END AUDIT_RESULT_V1
```

#### Canonical CLI View — Planning-Gate Failure

```text
AUDIT RESULT
target: specs/151-self-hosted-appliance-packaging
mode: product-to-planning
audit class: planning-maturity
ceiling: specs_hardened
verdict: PLANNING_REWORK_REQUIRED

EVALUATION
planning: planning rework required
delivery: delivery not evaluated
certified status: none

FAILED CHECK
gate: G068
reason: scenario SCN-151-012 has no faithful DoD mapping
evidence: [g068-evidence-ref]

NOT APPLICABLE
delivery-completion Checks 4, 5, 8, 11: auditClass=planning-maturity

ROUTE
outcome: route_required
finding: F151-AUDIT-005-G068
next owner: bubbles.plan
required action: repair the named planning traceability contract

BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: [workflow-run-id]
attemptId: [audit-attempt-id]
target: specs/151-self-hosted-appliance-packaging
targetRevision: [artifact-fingerprint]
workflowMode: product-to-planning
modeClass: none
auditClass: planning-maturity
statusCeiling: specs_hardened
requestedStatus: specs_hardened
auditVerdict: PLANNING_REWORK_REQUIRED
outcome: route_required
resultState: ACTIVE
certifiedStatus: none
planningEvaluation: REWORK_REQUIRED
deliveryEvaluation: NOT_EVALUATED
sourceEditLockout: PASS
applicableCheckClasses: [universal,planning-maturity]
notApplicableChecks: [Check-4,Check-5,Check-8,Check-11]
passedGateIds: [G040,G073,G087,G091,G093,G094,G095,G097]
failedGateIds: [G068]
failedChecks: []
blockingCode: PLANNING_GATE_FAILED
unresolvedFields: []
contradictions: []
contractRef: bubbles/workflows/modes.yaml#product-to-planning
contractDigest: [contract-digest]
evidenceRefs: [g068-evidence-ref,source-lockout-evidence-ref]
addressedFindings: []
unresolvedFindings: [F151-AUDIT-005-G068]
nextRequiredOwner: bubbles.plan
supersedesAttemptId: none
resumeFromPhase: none
END AUDIT_RESULT_V1
```

The failed planning gate is the primary problem. Missing future test files,
unchecked implementation DoD, `Not Started` scopes, and no execution evidence
must not be repeated as blockers or used to obscure G068.

#### Canonical CLI View — Delivery-Completion Failure

```text
AUDIT RESULT
target: [delivery-target]
mode: [done-ceiling-delivery-mode]
audit class: delivery-completion
ceiling: done
verdict: DO_NOT_SHIP

EVALUATION
planning: not separately certified
delivery: delivery refused
certified status: none

FAILED CHECKS
Check 4: unchecked delivery DoD ([check-4-evidence-ref])
Check 5: scopes not Done ([check-5-evidence-ref])
Check 8: required test files absent ([check-8-evidence-ref])
Check 11: execution evidence absent ([check-11-evidence-ref])

ROUTE
outcome: route_required
next owner: bubbles.implement
required action: complete the unchanged delivery obligations and revalidate

BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: [workflow-run-id]
attemptId: [audit-attempt-id]
target: [delivery-target]
targetRevision: [artifact-fingerprint]
workflowMode: [done-ceiling-delivery-mode]
modeClass: feature-delivery
auditClass: delivery-completion
statusCeiling: done
requestedStatus: done
auditVerdict: DO_NOT_SHIP
outcome: route_required
resultState: ACTIVE
certifiedStatus: none
planningEvaluation: NOT_EVALUATED
deliveryEvaluation: REFUSED
sourceEditLockout: PASS
applicableCheckClasses: [universal,delivery-completion]
notApplicableChecks: []
passedGateIds: [G073]
failedGateIds: []
failedChecks: [Check-4,Check-5,Check-8,Check-11]
blockingCode: DELIVERY_COMPLETION_FAILED
unresolvedFields: []
contradictions: []
contractRef: [registry-mode-reference]
contractDigest: [contract-digest]
evidenceRefs: [check-4-evidence-ref,check-5-evidence-ref,check-8-evidence-ref,check-11-evidence-ref]
addressedFindings: []
unresolvedFindings: [delivery-completion-finding-ids]
nextRequiredOwner: bubbles.implement
supersedesAttemptId: none
resumeFromPhase: none
END AUDIT_RESULT_V1
```

This view preserves the existing delivery refusal token. It never relabels a
delivery failure as planning maturity and never applies the planning
`NOT_APPLICABLE` set.

#### Canonical CLI View — Unknown Mode Or Ceiling

```text
AUDIT BLOCKED
target: [target]
mode: UNRESOLVED
audit class: UNRESOLVED
ceiling: UNRESOLVED
verdict: BLOCKED

EVALUATION
planning: not evaluated
delivery: not evaluated
certified status: none

BLOCKER
code: AUDIT_CONTRACT_UNRESOLVED
unresolved fields: workflowMode, statusCeiling, auditClass
observed: state.workflowMode=[unknown-mode]
required: one registry-resolved contract with a ceiling and audit semantics
evidence: [contract-resolution-evidence-ref]

ROUTE
outcome: blocked
next owner: bubbles.super
required action: resolve the authoritative mode contract; do not select a fallback

BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: [workflow-run-id]
attemptId: [audit-attempt-id]
target: [target]
targetRevision: [artifact-fingerprint]
workflowMode: UNRESOLVED
modeClass: UNRESOLVED
auditClass: UNRESOLVED
statusCeiling: UNRESOLVED
requestedStatus: [requested-status-or-none]
auditVerdict: BLOCKED
outcome: blocked
resultState: ACTIVE
certifiedStatus: none
planningEvaluation: NOT_EVALUATED
deliveryEvaluation: NOT_EVALUATED
sourceEditLockout: NOT_EVALUATED
applicableCheckClasses: []
notApplicableChecks: []
passedGateIds: []
failedGateIds: []
failedChecks: [contract-resolution]
blockingCode: AUDIT_CONTRACT_UNRESOLVED
unresolvedFields: [workflowMode,statusCeiling,auditClass]
contradictions: []
contractRef: bubbles/workflows/modes.yaml
contractDigest: UNRESOLVED
evidenceRefs: [contract-resolution-evidence-ref]
addressedFindings: []
unresolvedFindings: [audit-contract-finding-id]
nextRequiredOwner: bubbles.super
supersedesAttemptId: none
resumeFromPhase: none
END AUDIT_RESULT_V1
```

Contradictory metadata uses this same view with all conflicting values shown in
`contradictions`, for example
`[state.workflowMode=product-to-planning,policySnapshot.workflowMode=full-delivery]`.
It does not choose whichever value appears newer. If the concrete artifact
owner is already known, `nextRequiredOwner` names that owner; otherwise
`bubbles.super` owns resolution of the routing ambiguity, not remediation of
the artifact itself.

#### Canonical CLI View — Source-Edit Lockout

```text
AUDIT BLOCKED
target: specs/151-self-hosted-appliance-packaging
mode: product-to-planning
audit class: planning-maturity
ceiling: specs_hardened
verdict: BLOCKED

EVALUATION
planning: not evaluated
delivery: delivery not evaluated
certified status: none

BLOCKER
code: SOURCE_EDIT_LOCKOUT
gate: G073
observed changed path: bubbles/scripts/state-transition-guard.sh
required: planning-only change set with no undeclared framework source edits
evidence: [g073-change-set-evidence-ref]

ROUTE
outcome: blocked
next owner: bubbles.super
required action: resolve change ownership without discarding operator work

BEGIN AUDIT_RESULT_V1
schemaVersion: audit-result/v1
runId: [workflow-run-id]
attemptId: [audit-attempt-id]
target: specs/151-self-hosted-appliance-packaging
targetRevision: [artifact-fingerprint]
workflowMode: product-to-planning
modeClass: none
auditClass: planning-maturity
statusCeiling: specs_hardened
requestedStatus: specs_hardened
auditVerdict: BLOCKED
outcome: blocked
resultState: ACTIVE
certifiedStatus: none
planningEvaluation: NOT_EVALUATED
deliveryEvaluation: NOT_EVALUATED
sourceEditLockout: FAIL
applicableCheckClasses: [universal,planning-maturity]
notApplicableChecks: [Check-4,Check-5,Check-8,Check-11]
passedGateIds: []
failedGateIds: [G073]
failedChecks: [source-edit-lockout]
blockingCode: SOURCE_EDIT_LOCKOUT
unresolvedFields: []
contradictions: []
contractRef: bubbles/workflows/modes.yaml#product-to-planning
contractDigest: [contract-digest]
evidenceRefs: [g073-change-set-evidence-ref]
addressedFindings: []
unresolvedFindings: [source-edit-lockout-finding-id]
nextRequiredOwner: bubbles.super
supersedesAttemptId: none
resumeFromPhase: none
END AUDIT_RESULT_V1
```

When change provenance identifies a concrete source owner, the route names that
owner instead of `bubbles.super`. The audit never resets, stashes, overwrites,
or silently accepts the source change.

#### Interruption, Resume, And Audit Rework

An interrupted or reworked audit must never leave a prior clean-looking summary
as the active truth.

1. Opening any resumed or post-rework audit creates a new `attemptId` under the
   same `runId`; it does not append new facts to the prior attempt.
2. Before the new attempt evaluates checks, the prior `ACTIVE` result becomes
   `SUPERSEDED`. The current-summary pointer is empty until phase 6 persists a
   new result.
3. The new attempt always re-resolves the mode contract, target fingerprint,
   status ceiling, audit class, and G073 state. It reruns every applicable audit
   check for the current inputs. Prior raw evidence may remain referenced only
   with its original claim source and immutable evidence reference.
4. Interruption emits `INTERRUPTED` with `resultState: INCOMPLETE`, the last
   completed phase, and `resumeFromPhase`; it emits no planning certification,
   delivery verdict, or phase-completion claim.
5. If the target fingerprint or contract digest changes, every earlier result
   is historical even when its verdict was clean. A stale result is never shown
   under `AUDIT RESULT`; it is available only as `AUDIT HISTORY` with
   `resultState: SUPERSEDED`.
6. Rework preserves each finding ID one-to-one. The next attempt lists every
   prior finding under `addressedFindings` with current evidence or under
   `unresolvedFindings` with a concrete owner. Missing finding IDs block phase
   6 persistence.
7. More than one `ACTIVE` result, an active result whose target/contract digest
   does not match current inputs, or a summary with no originating attempt
   produces `blocked` with `AUDIT_PROVENANCE_CONFLICT`.

Canonical interrupted output:

```text
AUDIT INTERRUPTED
run: [workflow-run-id]
attempt: [audit-attempt-id]
last completed phase: 3/6 select checks
result: no active audit verdict
prior result: SUPERSEDED ([prior-attempt-id])
resume: create a new attempt and restart at 1/6 resolve contract
next owner: bubbles.audit
```

Canonical rework header:

```text
AUDIT REWORK ATTEMPT
run: [workflow-run-id]
attempt: [new-attempt-id]
supersedes: [prior-attempt-id]
target revision: [current-artifact-fingerprint]
contract digest: [current-contract-digest]
open findings: [ordered-finding-ids]
addressed findings: [ordered-finding-ids]
current result: none until 6/6 persist and route
```

#### Accessibility, Plain Text, And Terminal Width

- The canonical representation is the no-color representation. It contains no
  ANSI escapes, emoji, Unicode box drawing, spinner, carriage-return rewrite,
  or status conveyed only by position or hue.
- `NO_COLOR` and non-TTY output MUST use the canonical representation. Optional
  TTY color may decorate existing words only; removing it yields byte-stable
  status tokens and field names.
- Screen readers encounter identity, verdict, evaluation, failed checks,
  evidence, and route in that order. Phase progress appends new lines instead
  of replacing prior speech with an in-place update.
- At narrow widths, one `key: value` pair remains per line and wrapped values
  use a two-space continuation indent. Tables collapse to the same ordered
  labeled lines; no value may be truncated and no horizontal layout is needed
  to understand the result.
- Exit status is never the only result signal. The verdict token,
  `blockingCode`, failed IDs, evidence references, and route remain visible in
  captured logs.
- Stable tokens and the `AUDIT_RESULT_V1` block remain English ASCII for
  interoperability. Any future localization applies only to explanatory human
  prose and must preserve the canonical record unchanged.

#### Routing Rules

| Current result | Outcome | Status effect | Next owner |
| --- | --- | --- | --- |
| Clean planning ceiling | `completed_diagnostic` | Certify only the exact planning ceiling; delivery remains not evaluated | `none`; workflow may finalize the planning mode |
| Planning-gate failure | `route_required` | No planning certification | Concrete owner of the failed planning artifact/gate |
| Delivery-completion failure | Existing delivery route outcome | No delivery certification | Existing concrete implementation/test/planning repair owner; delivery rules are unchanged |
| Unknown or contradictory contract | `blocked` | No maturity status change | Known metadata owner, otherwise `bubbles.super` for routing resolution |
| G073 source-edit lockout | `blocked` | No planning or delivery certification | Provenance owner, otherwise `bubbles.super`; never auto-discard changes |
| Interrupted attempt | Non-terminal `INCOMPLETE` record | No active verdict | `bubbles.audit` under the existing top-level runner |
| Provenance conflict | `blocked` | Invalidate current-summary use | Concrete provenance owner or `bubbles.super` when ownership is unresolved |

These routing rules govern the future audit operator surface. For the current
BUG-009 planning chain, UX ownership is complete and the next required owner is
`bubbles.design`; the bug remains open and no runtime audit result is claimed.

### Superseded Fix-Design Options (Preserved Planning Input)

These options were inputs to the design owner. They remain here for decision
provenance, but they are not active architecture. The selected design below
uses Option 2, with one shared resolver and an explicit registry-bound profile;
Options 1 and 3 are rejected as independent policy-selection paths.

**Constraints:**

- Keep `bubbles/workflows/modes.yaml` as the single source of truth for mode
  ceiling and required-gate selection.
- Do not weaken delivery-mode anti-fabrication checks or infer planning mode
  from mutable prose.
- Do not add `--skip`, `--force`, `--ignore`, environment bypasses, or a
  permissive fallback for unknown modes.
- Keep the canonical and installed guard paths behaviorally identical through
  normal release-manifest propagation; do not patch a consumer copy in place.
- Preserve G073 source-edit lockout and every planning gate currently green in
  the reproduction.

**Options requiring design-owner evaluation:**

1. Make the existing guard classify each check as universal, planning-maturity,
   or delivery-completion and activate it from the registry-resolved target
   ceiling/required gates.
2. Add an explicit registry-derived transition target/profile to the guard and
   have audit request the mode ceiling rather than implicitly requesting
   delivery completion. The profile must be derived and validated, never a
   caller-controlled bypass.
3. Compose separate planning-ceiling and delivery-completion guard entry points
   from shared universal checks, with audit selecting the entry point from the
   resolved mode contract. This has a larger drift surface and therefore needs
   a single shared resolver and cross-profile selftests.

### Technical Design — Registry-Bound Transition Contract

#### Design Brief

**Current State.** `mode-resolver.sh` can resolve inherited workflow mode
definitions, and Check 3 of `state-transition-guard.sh` independently extracts
the persisted mode's `statusCeiling`. Audit 0-pre, Validate Step 2.11, and the
finalize contract nevertheless invoke a guard whose completion portions still
mean only “transition to `done`,” so the resolved ceiling does not control the
evidence contract applied by Checks 4, 5, 8, and 11.

The guard also has a raw-YAML ceiling parser in front of the canonical mode
resolver. That duplicate parser exposes only one scalar and cannot carry the
mode's effective phase order, required gates, constraints, or a stable contract
digest into validate/audit/finalize.

**Target State.** Introduce one registry-bound transition contract resolved
from the target's persisted state and the fully resolved mode definition. The
contract derives the transition target and audit profile; callers may assert
expected values but cannot select or weaken the profile.

`product-to-planning` and `spec-scope-hardening` resolve to
`planning-maturity-v1` at `specs_hardened`. Done-ceiling audit modes resolve to
`delivery-completion-v1`; their present completion checks and verdicts remain
blocking and unchanged. Every unsupported non-done audit mode fails before
check selection rather than inheriting planning semantics.

**Patterns To Follow.** Use `bubbles/scripts/mode-resolver.sh --grandfather`
for persisted v5-key compatibility, the registry-first split in
`bubbles/workflows/modes.yaml`, `bubbles/scripts/trust-metadata.sh` for portable
SHA-256, `guards/planning-checks.sh` for planning-shape checks 8A-8D, the
validate-owned certification boundary in
`agents/bubbles_shared/completion-governance.md`, and broad-copy/checksum
propagation in `install.sh` plus `bubbles/release-manifest.json`.

**Patterns To Avoid.** Do not infer planning semantics from
`statusCeiling != done`, mode-name substrings, mutable descriptions, or a
caller-provided `--profile`. Do not maintain separate audit and guard mode
tables, fork planning and delivery guard scripts, treat `NOT_APPLICABLE` as
`PASS`, synthesize delivery evidence, or patch `.github/bubbles/**` in a
consumer checkout.

**Resolved Decisions:**

- The selected architecture is a **registry-bound transition contract**.
- `transitionAudit.profile` and `transitionAudit.target` are resolved mode
  fields; `target` has the sole allowed value `statusCeiling`.
- A shared resolver reads state and the registry once per invocation and emits
  `transition-contract/v1` plus a canonical digest.
- The guard always invokes that resolver itself. Expectation arguments are
  equality assertions, never policy inputs.
- Checks are split at their behavioral sub-checks, not disabled wholesale.
- Audit persists attempt provenance under audit-owned `execution.audit`; only
  validate may write `certification.*` or mirror the terminal status.
- `AUDIT_RESULT_V1` remains the stable operator/machine projection defined by
  the UX contract; breaking field changes require `AUDIT_RESULT_V2`.
- Canonical source is changed once and propagated only by normal install or
  upgrade mechanics.

**Open Questions:** None. Custom non-done operational audit profiles are not
part of BUG-009 because they have different evidence semantics and no confirmed
planning-maturity reproduction; the resolver must reject them until an
explicit supported contract exists.

#### Selected Architecture And Registry Contract

The effective mode definition gains a closed `transitionAudit` map:

```yaml
transitionAudit:
  profile: planning-maturity-v1 | delivery-completion-v1
  target: statusCeiling
```

The two directly affected mode entries declare:

```yaml
spec-scope-hardening:
  statusCeiling: specs_hardened
  transitionAudit:
   profile: planning-maturity-v1
   target: statusCeiling

product-to-planning:
  statusCeiling: specs_hardened
  transitionAudit:
   profile: planning-maturity-v1
   target: statusCeiling
```

`delivery-completion-v1` is added to the resolved contract of every
audit-bearing `done`-ceiling mode. Put it in the shared delivery template where
inheritance already reaches the mode, and add it explicitly to remaining
done-ceiling audit mode entries. Registry consistency must prove that no
audit-bearing `done` mode resolves without `delivery-completion-v1` and that no
mode below `done` resolves to that profile.

`planning-maturity-v1` is accepted only when all structural invariants below
hold in the fully resolved mode:

1. `statusCeiling == specs_hardened`.
2. `transitionAudit.target == statusCeiling`.
3. `phaseOrder` contains `validate`, `audit`, and `finalize`.
4. `phaseOrder` contains neither `implement` nor `test`.
5. `constraints.allowImplementationForFindings == false`.
6. `constraints.focus` is exactly `planning_only` or
  `specs_and_scopes_only`.
7. `requiredGates` contains G073.

The conjunction matters. A registry edit that adds
`profile: planning-maturity-v1` to a done mode, an implementation-capable mode,
or a mode without source lockout is a malformed contract, not a newly trusted
exemption.

`delivery-completion-v1` is accepted only when `statusCeiling == done`, target
is `statusCeiling`, and the resolved phase order contains `implement`, `test`,
`validate`, and `audit`. Existing compatibility modes whose delivery contract
is intentionally encoded without one of those phases must be enumerated in a
closed resolver selftest before receiving this profile; there is no permissive
phase fallback.

No `transitionAudit` binding is added by BUG-009 to `docs-only`, validated
modes, `delivered_pending_activation` modes, release-train modes, upkeep modes,
propagation modes, incident modes, or `framework-health`. If one of those modes
invokes the new transition audit path, resolution returns
`E009-AUDIT-PROFILE-UNSUPPORTED`. This is intentionally stricter than applying
the wrong feature-planning or feature-delivery contract.

#### Shared Resolver Interface

Add `bubbles/scripts/transition-contract-resolver.sh` as the only state-to-audit
policy resolver.

```text
bash bubbles/scripts/transition-contract-resolver.sh FEATURE_DIR \
  [--expect-mode MODE] \
  [--expect-target STATUS] \
  [--expect-contract-digest sha256:HEX]
```

There is deliberately no `--profile`, `--skip-*`, `--force`, `--ignore`,
environment override, or “planning” switch. The three optional values are
assertions supplied by the workflow runner at a process boundary. The script
first derives the effective values from state and registry, then compares each
assertion byte-for-byte. Removing an assertion never changes the derived
contract; supplying a different value blocks.

Resolver inputs are:

1. `FEATURE_DIR/state.json` top-level `workflowMode`.
2. `policySnapshot.workflowMode`, when present, as an equality constraint.
3. Top-level and `certification.status` as current-state consistency inputs.
4. The canonical source or installed `bubbles/workflows.yaml` and adjacent
  `bubbles/workflows/modes.yaml`.
5. The fully resolved mode emitted by `mode-resolver.sh --grandfather`.
6. Optional expectation assertions from the invoking boundary.

Persisted mode values remain canonical registry keys. Thus existing
`state.json.workflowMode: product-to-planning` resolves through the grandfather
path even though new operator input uses the v6 form
`plan target:product action:analyze-design-plan`. The resolver emits the
canonical key in `workflowMode`; it does not rewrite state or aliases.

On success, stdout is one JSON object with this exact v1 shape:

```json
{
  "schemaVersion": "transition-contract/v1",
  "featureDir": "specs/NNN-feature",
  "workflowMode": "product-to-planning",
  "modeClass": null,
  "auditProfile": "planning-maturity-v1",
  "statusCeiling": "specs_hardened",
  "targetStatus": "specs_hardened",
  "currentStatus": "in_progress",
  "requiredGates": ["G001", "G002", "G006"],
  "phaseOrder": ["analyze", "select", "bootstrap", "harden", "docs", "validate", "audit", "finalize"],
  "sourceEditLockoutRequired": true,
  "contractRef": "bubbles/workflows/modes.yaml#product-to-planning",
  "contractDigest": "sha256:HEX",
  "targetRevision": "sha256:HEX"
}
```

The abbreviated `requiredGates` above demonstrates shape only; real output
contains the complete sorted effective gate list. JSON arrays preserve
`phaseOrder` order and use canonical sorted order for set-like fields.

`contractDigest` hashes a canonical JSON projection of `workflowMode`,
`auditProfile`, `statusCeiling`, `targetStatus`, complete `requiredGates`,
`phaseOrder`, and the seven profile-validation inputs above. Hashing uses
`bubbles_sha256_stdin` from `trust-metadata.sh`, which selects `sha256sum` or
`shasum -a 256` by capability.

`targetRevision` hashes an ordered manifest of the audited artifact inputs:
`spec.md`, `design.md`, `uservalidation.md`, `scenario-manifest.json`,
`test-plan.json` when present, every active scope file, every scope report, and
a canonical state projection. The projection excludes only audit-owned output
(`execution.audit`, the current audit phase marker, audit execution-history
rows, and `lastUpdatedAt`). Report hashing excludes only explicitly delimited
audit-result blocks written by the current audit contract. All planning,
implementation, test, and pre-existing evidence bytes remain in the digest.
This prevents the audit from invalidating its own fingerprint while ensuring
that any foreign artifact or evidence mutation makes the result stale.

#### Resolver Failure Contract

The resolver writes no state. It prints one stable `E009-*` line to stderr and
uses this closed exit contract:

| Exit | Failure code | Condition | Audit mapping |
| --- | --- | --- | --- |
| 0 | none | Contract resolved and all assertions match | Continue |
| 64 | `E009-USAGE` | Missing target, unknown flag, or caller attempts `--profile`/bypass syntax | `BLOCKED` |
| 65 | `E009-STATE-MALFORMED` | Missing/unparseable state or required state field | `BLOCKED` |
| 66 | `E009-REGISTRY-MISSING` | Workflows, modes registry, or canonical resolver unavailable | `BLOCKED` |
| 67 | `E009-MODE-UNKNOWN` | Persisted mode is absent from the effective registry | `BLOCKED` |
| 68 | `E009-STATE-MODE-MISMATCH` | Top-level mode, policy snapshot, or resolved canonical key disagree | `BLOCKED` |
| 69 | `E009-TARGET-MISMATCH` | Expected target/mode/digest, current terminal state, or certification mirror contradicts the derived contract | `BLOCKED` |
| 70 | `E009-AUDIT-PROFILE-MISSING` | Audit-bearing resolved mode has no profile binding | `BLOCKED` |
| 71 | `E009-AUDIT-PROFILE-UNSUPPORTED` | Profile token is unknown or this non-done mode has no BUG-009-supported semantics | `BLOCKED` |
| 72 | `E009-AUDIT-PROFILE-CONTRADICTION` | Profile token conflicts with ceiling, phases, focus, implementation allowance, or G073 | `BLOCKED` |

“Current terminal state” is contradictory when it is a terminal token other
than the derived target, when top-level and certification status differ, when a
planning target is paired with `done`, or when a caller requests a target other
than the ceiling. `not_started`, `in_progress`, and `blocked` are valid
pre-transition states; the exact target is valid for an idempotent re-audit.

#### Guard Interface And Result

Extend the existing guard without adding a second guard entry point:

```text
bash bubbles/scripts/state-transition-guard.sh FEATURE_DIR \
  [--target-status STATUS] \
  [--expect-workflow-mode MODE] \
  [--expect-contract-digest sha256:HEX] \
  [--revert-on-fail]
```

The guard invokes `transition-contract-resolver.sh` itself. The optional values
are forwarded only as assertions. A one-argument legacy invocation remains
valid and derives the same target/profile from state. `--revert-on-fail`
retains its existing done-transition behavior; a planning audit does not use it
to rewrite planning state.

The guard retains exit 0 for all applicable checks passing, exit 1 for one or
more applicable check failures, and exit 2 when no trustworthy contract can be
evaluated. It appends this ordered machine block after the human check ledger:

```text
BEGIN TRANSITION_GUARD_RESULT_V1
schemaVersion: transition-guard-result/v1
workflowMode: product-to-planning
auditProfile: planning-maturity-v1
targetStatus: specs_hardened
contractDigest: sha256:HEX
targetRevision: sha256:HEX
applicableCheckClasses: [universal,mode-required,planning-maturity]
notApplicableChecks: [Check-4-completion,Check-5-all-done,Check-8-file-existence,Check-11-execution-evidence]
passedGateIds: [ordered-gate-ids]
failedGateIds: []
failedChecks: []
blockingCode: none
verdict: PASS
END TRANSITION_GUARD_RESULT_V1
```

Contract-resolution failures still emit the block with unresolved values,
`verdict: BLOCKED`, the exact `E009-*` code, and exit 2. Applicable-check
failures emit `verdict: FAIL`, a profile-specific blocking code, and exit 1.
No consumer is allowed to infer success from a missing block.

#### Check Classification And Activation

The implementation separates structural/integrity portions from completion
portions inside the existing numbered checks. It does not skip whole checks by
number.

| Class | Active behavior |
| --- | --- |
| `universal` | Required artifact/state shape; workflow-mode and certification mirror consistency; status ceiling; G073 when required; control-plane provenance; canonical DoD/status syntax; `_index.md` parity; phantom/completed-scope integrity; phase provenance; timestamp plausibility; checked-item evidence integrity; template/deferral/freshness/ownership/anti-fabrication checks; artifact lint; and every existing conditional integrity gate whose own predicate applies. |
| `mode-required` | Every gate in the fully resolved mode's `requiredGates`, with G008 satisfied only by the current audit verdict and G012 satisfied only during validate-owned finalization. A required gate cannot be removed by the profile. |
| `planning-maturity` | Substantive spec/design/scope structure, scenario/DoD/Test Plan parity, checks 8A-8D, planning-chain provenance, source-edit lockout, honest incomplete implementation state, and exact target `specs_hardened`. |
| `delivery-completion` | All universal and mode-required behavior plus zero unchecked DoD, all scopes Done, physical required test files, execution evidence in reports, implementation/test phase reality, and the existing done-transition anti-fabrication bar. |
| unsupported explicit mode class | No checks are selected. Resolution blocks with `E009-AUDIT-PROFILE-UNSUPPORTED`; this is not a permissive profile. |

Exact treatment of the implicated checks:

| Guard area | Universal/planning behavior | Delivery-completion behavior |
| --- | --- | --- |
| Check 3 | Resolve contract, enforce state/policy/ceiling/target equality, and run G073 when contract requires it. | Same; target must be `done` and profile must be `delivery-completion-v1`. |
| Check 4 | At least one planned DoD item must exist. Unchecked items are expected. Check 4A format integrity remains blocking, and every checked item is still evidence-audited by Check 9. | Existing zero-unchecked rule remains blocking in addition to universal integrity. |
| Check 4B | All status values must remain canonical. Incomplete statuses are allowed. A `Done` claim is audited normally; planning mode does not make it trustworthy by itself. | Same canonicality plus all-scope completion through Check 5. |
| Check 5 | `_index`/scope parity, completedScopes exactness, and phantom detection remain blocking. `Not Started`, `In Progress`, or `Blocked` implementation scopes do not fail merely for being incomplete. | Existing requirement that every resolved scope is Done remains blocking. |
| Check 8 | Parse Test Plan contracts and run checks 8A-8D. Placeholder, malformed, unmapped, or repo-impossible test contracts still fail. Physical absence of a future implementation-owned test file is `NOT_APPLICABLE`. | Existing physical file-existence requirement remains blocking. |
| Check 9 | Any item already marked `[x]` requires genuine evidence under either profile. With zero checked items, there is no fabricated completion claim to satisfy. | Existing per-checked-item evidence requirement applies after Check 4 requires every item checked. |
| Check 11 | Required report sections, placeholder/manual-continuation scan, narrative-fabrication scan, and legitimacy checks for any evidence block that exists remain active. A zero-block report is accepted only for a scope with no checked DoD, no Done claim, no completed-scope entry, and no implement/test phase claim. | Existing requirement for execution-evidence blocks remains blocking. |

For `product-to-planning`, the effective check set is universal + its complete
resolved `requiredGates` + planning maturity, including G032. For
`spec-scope-hardening`, the same policy applies without G032 unless the mode
registry itself requires it. Both stop exactly at `specs_hardened`, preserve
honest scope/DoD incompleteness, and emit no delivery verdict.

For every done-ceiling delivery mode, the effective set is universal + complete
resolved `requiredGates` + delivery completion. Checks 4 completion, 5 all-Done,
8 physical existence, 9 evidence, and 11 execution evidence preserve their
current blocking semantics. The honest planning fixture is an obligatory
negative control for this profile.

#### Validate, Audit, And Finalize Control Flow

1. **Workflow mode resolution.** The authorized runner resolves new v6 operator
  input through `mode-resolver.sh`, persists the canonical backing key in
  top-level and policy-snapshot state, and invokes the transition resolver. It
  carries the resulting mode, target, and contract digest as expectations to
  later phases; it cannot carry a profile override.
2. **Validate.** `bubbles.validate` independently re-resolves the contract,
  compares the runner's expectations, and executes the guard against the
  derived target. Its result envelope references the
  `TRANSITION_GUARD_RESULT_V1` block. Planning validation does not run future
  implementation tests as if they existed; it validates their contracts and
  the planning gates. Validate does not certify the target yet when audit is a
  remaining required phase.
3. **Open audit attempt.** `bubbles.audit` re-resolves the contract a third time
  and compares the validation digest and target revision. It creates a new
  attempt under `execution.audit`, marks any prior active result superseded,
  and clears the current-result pointer before evaluating checks.
4. **Audit preflight and independent checks.** Audit 0-pre invokes the same
  guard with mode/target/digest assertions. Audit A1 becomes “the
  profile-scoped transition guard passes,” not “the done guard passes.” A2-A6
  rerun applicable integrity, planning, or delivery checks independently;
  non-applicable delivery checks are named, never omitted or counted as pass.
5. **Audit decision.** A clean planning result emits
  `PLANNING_AUDIT_CLEAN`; a planning failure emits
  `PLANNING_REWORK_REQUIRED`; contract uncertainty emits `BLOCKED`; a delivery
  evaluation retains the existing delivery verdict tokens. The full result is
  persisted in the audit evidence section and projected into
  `AUDIT_RESULT_V1`.
6. **Finalize.** The workflow runner asks validate to re-resolve the current
  contract and target fingerprint. Validate accepts only one ACTIVE audit
  result whose attempt ID, target revision, contract digest, profile, target,
  finding accounting, and verdict all match. It then writes
  `certification.status` and the top-level mirror. For planning maturity this
  is `specs_hardened`; scope statuses, DoD checkboxes, completedScopes, and
  delivery evaluation remain unchanged. For delivery this remains the current
  all-scopes-Done `done` transition.

The workflow runner owns orchestration expectations and `executionHistory`.
Audit owns its report section and `execution.audit` attempt records. Validate
alone owns `certification.*` and terminal status promotion. Plan owns future
scope/Test Plan/DoD changes. No agent may copy the resolved profile into state
as a new source of truth; persisted profile values are evidence snapshots tied
to a digest, not configuration.

#### Audit Attempt Persistence And Stale-Provenance Rules

Add this audit-owned, additive state projection:

```json
{
  "execution": {
   "audit": {
    "schemaVersion": "audit-run/v1",
    "runId": "run-id",
    "currentAttemptId": "attempt-id-or-null",
    "attempts": [
      {
       "attemptId": "attempt-id",
       "resultState": "ACTIVE",
       "targetRevision": "sha256:HEX",
       "contractDigest": "sha256:HEX",
       "auditProfile": "planning-maturity-v1",
       "targetStatus": "specs_hardened",
       "auditVerdict": "PLANNING_AUDIT_CLEAN",
       "outcome": "completed_diagnostic",
       "evidenceRef": "report.md#audit-attempt-id",
       "addressedFindings": [],
       "unresolvedFindings": []
      }
    ]
   }
  }
}
```

Only one attempt may be ACTIVE, and `currentAttemptId` must point to it. Opening
a new attempt first marks the old ACTIVE record SUPERSEDED, then sets the
pointer to null and appends an INCOMPLETE record. Interruption leaves no active
pointer. Phase 6 persistence changes the current attempt to ACTIVE only after
the result block and finding accounting pass lint.

Any target revision or contract digest change makes all prior attempts
historical. Finalize blocks with `AUDIT_PROVENANCE_CONFLICT` for multiple active
records, a dangling pointer, a stale fingerprint/digest, a missing evidence
reference, an INCOMPLETE result, or a finding that disappears rather than
moving one-to-one between addressed and unresolved arrays.

This state is execution evidence, not certification. A
`PLANNING_AUDIT_CLEAN` record cannot write `certification.status`, cannot add
completed scopes, and cannot set `deliveryEvaluation: CERTIFIED`.

#### Audit Output Versioning And Contract Lint

The UX-owned `BEGIN AUDIT_RESULT_V1` block is normative. V1 requires exactly
one block, the exact field order already specified, every field present, no
unknown field, closed enum values, and agreement with the persisted attempt.
Empty scalars remain `none`; empty collections remain `[]`.

Add `bubbles/scripts/audit-result-contract-lint.sh` with two read-only inputs:

```text
bash bubbles/scripts/audit-result-contract-lint.sh --result FILE
bash bubbles/scripts/audit-result-contract-lint.sh --agent-contract agents/bubbles.audit.agent.md
```

Result lint rejects duplicate/missing boundary markers, reordered or duplicate
fields, malformed collections, invalid enum combinations, a certified status
that differs from target, planning output containing delivery language,
delivery certification with `NOT_EVALUATED`, non-applicable checks reported as
passed, missing digest/fingerprint, and finding-accounting drift. Agent-contract
lint verifies that Audit 0-pre invokes the transition-aware guard, profile
selection is registry-bound, all V1 fields exist in order, and the planning and
delivery verdict vocabularies stay disjoint.

`audit-result/v1` is frozen. Additive or breaking machine-field changes use a
new `BEGIN AUDIT_RESULT_V2` block and dual-read migration; human prose may be
clarified without changing V1 tokens. An implementation must not silently add
fields to V1.

#### Failure And Routing Matrix

| Condition | Guard/audit code | Human verdict | Outcome | Status effect | Owner |
| --- | --- | --- | --- | --- | --- |
| Unknown mode | `E009-MODE-UNKNOWN` | `BLOCKED` | `blocked` | none | Known state owner, otherwise `bubbles.super` |
| Registry/resolver missing | `E009-REGISTRY-MISSING` | `BLOCKED` | `blocked` | none | `bubbles.devops` for install integrity or framework maintainer in source |
| State/argument mode mismatch | `E009-STATE-MODE-MISMATCH` | `BLOCKED` | `blocked` | none | Concrete state owner, otherwise `bubbles.super` |
| Target/status/digest contradiction | `E009-TARGET-MISMATCH` | `BLOCKED` | `blocked` | none | Concrete provenance owner |
| Missing/unsupported non-done profile | `E009-AUDIT-PROFILE-MISSING` or `E009-AUDIT-PROFILE-UNSUPPORTED` | `BLOCKED` | `blocked` | none | `bubbles.design` for a distinct evidence contract |
| Planning profile structural contradiction | `E009-AUDIT-PROFILE-CONTRADICTION` | `BLOCKED` | `blocked` | none | Registry owner |
| G073 source edit | `SOURCE_EDIT_LOCKOUT` | `BLOCKED` | `blocked` | none | Provenance owner; never auto-discard |
| Required planning gate fails | `PLANNING_GATE_FAILED` | `PLANNING_REWORK_REQUIRED` | `route_required` | no planning certification | Owner of the named artifact/gate |
| Planning checks pass | none | `PLANNING_AUDIT_CLEAN` | `completed_diagnostic` | validate may certify only `specs_hardened` | none |
| Delivery completion fails | `DELIVERY_COMPLETION_FAILED` | Existing `REWORK_REQUIRED`/`DO_NOT_SHIP` | existing route outcome | no delivery certification | Existing repair owner |
| Result schema/provenance invalid | `AUDIT_RESULT_LINT_FAILED` or `AUDIT_PROVENANCE_CONFLICT` | `BLOCKED` | `blocked` | none | `bubbles.audit` or provenance owner |

Failed planning gates are reported before non-applicable delivery facts. An
absent future test cannot hide G068, G087, G091, or G073. Conversely, planning
success cannot hide a checked item without evidence, a falsely Done scope, a
source edit, or contradictory metadata because those remain universal.

#### Security And Anti-Fabrication Analysis

The privilege boundary is the profile-selection path. The design prevents a
planning profile from becoming a delivery bypass through five independent
controls:

1. **No caller profile input.** Only the resolved registry object supplies the
  profile. Unknown flags and environment overrides fail.
2. **Conjunctive profile validation.** The planning token is rejected unless
  ceiling, target, phase exclusions, focus, implementation prohibition, and
  G073 all agree. Changing one field cannot create an exemption.
3. **Positive delivery binding.** Every done/audit mode must resolve explicitly
  to `delivery-completion-v1`; absence is a registry-consistency failure, not a
  planning fallback.
4. **Universal honesty checks.** Checked DoD evidence, canonical status/parity,
  phase provenance, source lockout, ownership, artifact freshness, and
  anti-fabrication checks remain active under planning semantics. Honest
  absence is accepted; false presence is rejected.
5. **Certification separation.** Audit can record only `execution.audit`.
  Validate independently re-resolves the contract and alone writes
  certification. A planning result whose `certifiedStatus` is `done`, whose
  delivery evaluation is certified, or whose profile/digest is stale fails
  contract lint and finalize.

The security invariant is therefore:

> A `planning-maturity-v1` result can prove only that the exact registry-bound
> planning contract passed at `specs_hardened`; it cannot satisfy, suppress, or
> represent any delivery-completion obligation, and it cannot mutate delivery
> certification state.

`NOT_APPLICABLE` is evidence-bearing: each delivery sub-check is named with
`auditProfile=planning-maturity-v1` and the contract digest. It is never counted
as pass. This makes omission or profile laundering visible to human and
machine consumers.

#### Adversarial Test Architecture

1. **Pre-fix red evidence.** Before source edits, create the honest planning
  fixture and run the canonical guard plus Audit 0-pre harness. Preserve the
  nonzero result showing Checks 4, 5, 8, and 11. The existing GuestHost
  transcript remains the consumer-level red proof; no expected-failure test is
  mislabeled green.
2. **Honest planning green.** Add one hermetic fixture with Not Started scopes,
  unchecked DoD, absent planned test paths, zero report evidence blocks, no
  implementation/test phase claims, and all planning gates valid. Run it as
  both `product-to-planning` and `spec-scope-hardening`; both must return guard
  PASS and `PLANNING_AUDIT_CLEAN` at `specs_hardened`.
3. **Done negative control.** Change only the fixture's resolved mode/target to
  a done-ceiling delivery contract. Require nonzero exit and explicit failures
  for Check-4-completion, Check-5-all-done, Check-8-file-existence, and
  Check-11-execution-evidence. Assert no `NOT_APPLICABLE` delivery entries.
4. **Planning-gate negatives.** Mutate one fact per fixture: break G068
  scenario-to-DoD fidelity, break G087 linkage, break G091 planning-chain
  provenance, and introduce a G073 source edit. Each must fail on the named
  obligation while delivery facts remain non-applicable.
5. **Metadata adversaries.** Cover unknown mode, missing modes registry,
  malformed state, top-level/policy mode mismatch, caller target mismatch,
  stale contract digest, planning profile on a done mode, implementation/test
  phase added to a planning profile, unsupported custom non-done mode, and
  multiple ACTIVE attempts.
6. **Actual audit path.** Exercise the Audit 0-pre and Audit A1 command contract,
  not merely the resolver or Check 3. The harness must consume the real guard
  result and validate the emitted `AUDIT_RESULT_V1` block.
7. **Audit contract lint.** Positive fixtures cover all five canonical UX views
  plus interruption/rework. Negative fixtures cover a missing/reordered field,
  duplicate block, forbidden planning delivery wording, inconsistent
  evaluation pair, stale digest, disappearing finding, and non-applicable
  check reported as pass.
8. **Alias and install compatibility.** Resolve persisted
  `product-to-planning` with `--grandfather`, resolve the v6 primitive+tag form,
  and require byte-identical transition contracts. Install into a hermetic
  downstream fixture and require source/installed resolver, guard, profile,
  agent contract, and result-lint parity.
9. **Portability.** Run the new scripts/selftests through framework validation
  on macOS/BSD userland and the Linux/WSL compatibility path. Fixtures use
  `guard-lib.sh`, `trust-metadata.sh`, `LC_ALL=C`, portable `mktemp`, and no raw
  GNU-only flags or Bash-4-only arrays.

Extend `state-transition-guard-selftest.sh` for profile activation and add
`transition-contract-resolver-selftest.sh` plus
`audit-result-contract-lint-selftest.sh`. Add persistent regression
`tests/regression/test_23_planning_audit_contract.sh`, wired into the normal
regression/framework validation surface. The existing completed planning
fixture remains a compatibility case but cannot substitute for the honest
unimplemented fixture.

#### Compatibility, Migration, And Propagation

- **Persisted alias:** `product-to-planning` remains a valid persisted v5
  registry key. `aliases.yaml` and operator migration behavior do not change.
  The shared resolver always uses grandfather mode for artifact state and
  always emits the canonical key.
- **Guard CLI:** Existing `state-transition-guard.sh FEATURE_DIR` and
  `--revert-on-fail` calls continue to work. New expectation flags strengthen
  cross-phase assertions; they do not select semantics.
- **State shape:** `execution.audit` is additive and ignored by older readers.
  No migration rewrites historical state. A missing audit profile in an older
  installed registry fails with an upgrade-oriented code instead of guessing.
- **Audit output:** Existing human delivery verdicts remain unchanged.
  `AUDIT_RESULT_V1` is additive machine output; planning verdicts use the UX
  vocabulary and never reuse ship tokens.
- **Canonical propagation:** All edits land under
  `/Users/pkirsanov/Projects/bubbles`. `install.sh` already copies agents,
  shared modules, top-level scripts, guard fragments, workflow registries, and
  the release manifest, then writes `.manifest`/`.checksums`. No downstream
  hand patch or product-specific fork is permitted.
- **Release provenance:** Regenerate derived files in dependency order with
  `regen-derived.sh`; `bubbles/release-manifest.json` is last. Extend install
  provenance/drift selftests to prove the new resolver/lint scripts and changed
  agent/registry/shared files are copied and checksummed.
- **macOS/WSL:** New shell uses `#!/usr/bin/env bash`, capability detection,
  shared portable helpers, explicit stdin operands, locale-stable sorting, and
  no `sed -i`, raw `timeout`, `date -d`, `stat -c`, `readlink -f`, `grep -P`,
  `mapfile`, or `mktemp --suffix` assumptions.

#### Exact Implementation Surfaces

| File/interface | Planned change |
| --- | --- |
| `bubbles/workflows/modes.yaml` | Add resolved `transitionAudit` bindings for the two planning modes and every audit-bearing done mode; preserve all phase/gate/ceiling semantics. |
| `bubbles/schemas/workflows.schema.json` | Define the closed `transitionAudit` shape and profile/target enums. |
| `bubbles/scripts/transition-contract-resolver.sh` | New read-only state + registry resolver and digest/fingerprint producer. |
| `bubbles/scripts/transition-contract-resolver-selftest.sh` | Positive, mismatch, unsupported-mode, alias, digest, and installed-layout cases. |
| `bubbles/scripts/state-transition-guard.sh` | Invoke the resolver once, expose assertion flags/result block, and gate only completion portions of Checks 4/5/8/11 by profile. Remove local profile inference. |
| `bubbles/scripts/guards/planning-checks.sh` | Keep 8A-8D active and expose their IDs/results to the profile ledger without changing planning substance. |
| `bubbles/scripts/state-transition-guard-selftest.sh` | Replace the completion-shaped planning positive as primary proof; add honest planning, done negative, planning-gate, and metadata adversaries. |
| `bubbles/scripts/audit-result-contract-lint.sh` | Enforce exact `AUDIT_RESULT_V1` and canonical audit-agent contract. |
| `bubbles/scripts/audit-result-contract-lint-selftest.sh` | Validate five UX views, interruption/rework, and malformed/adversarial result cases. |
| `agents/bubbles.audit.agent.md` | Make Audit 0-pre profile-aware, add planning verdicts/result persistence, preserve delivery verdicts, and prohibit self-certification. |
| `agents/bubbles.validate.agent.md` | Consume the same contract/guard result and certify only the matching active audit target. |
| `agents/bubbles_shared/validation-profiles.md` | Redefine A1 as profile-scoped guard success and make A2-A6 applicability explicit without weakening anti-fabrication. |
| `agents/bubbles_shared/scope-workflow.md` | Replace done-only finalize checks with contract-target finalization; retain the full done completion chain for delivery. |
| `agents/bubbles_shared/workflow-phase-engine.md` | Require digest/target assertions across validate, audit, and finalize and reject stale audit results. |
| `agents/bubbles_shared/feature-templates.md` and `scope-templates.md` | Document additive `execution.audit` evidence shape and planning finalization invariants. |
| `bubbles/scripts/workflow-registry-consistency.sh` | Enforce planning-profile invariants and complete delivery-profile coverage for audit-bearing done modes. |
| `bubbles/scripts/framework-validate.sh` | Run resolver and audit-contract selftests/lint. |
| `tests/regression/test_23_planning_audit_contract.sh` | Persistent end-to-end framework regression for the real resolver → guard → audit contract. |
| `bubbles/scripts/install-provenance-selftest.sh` | Prove normal install carries and checksums every new/changed managed interface. |
| `bubbles/release-manifest.json` | Regenerated last from canonical source; no hand edits. |
| `CHANGELOG.md` | Record the behavior only when implementation and regression evidence exist; no fixed claim during planning. |
| `BUGS.md` | Preserve this design and later append real implementation/post-fix evidence without rewriting the pre-fix record. |

`install.sh`, `aliases.yaml`, and downstream `.github/**` are inspected
compatibility surfaces but require no direct BUG-009 behavior change. If normal
broad-copy install cannot carry a listed managed file, that is an installer
test failure to repair upstream, not permission for manual copying.

#### Rollback Strategy

The implementation must land as one coherent registry/resolver/guard/agent
contract. If any adversarial, framework, release, or install-provenance check
fails, do not leave only the planning exemption or only the prompt change in
place. Revert the BUG-009 implementation commit, regenerate the release
manifest against the reverted source, and distribute the prior known-good
release through the normal installer.

The state addition is rollback-safe: older framework versions ignore
`execution.audit`, and an INCOMPLETE or stale attempt never authorizes
certification. Rollback does not delete audit history or rewrite downstream
state. No data migration, mode-name migration, or product artifact rewrite is
required.

After rollback, done-ceiling behavior is exactly the pre-change guard. The
planning defect reappears honestly as open BUG-009; it must not be masked with
fake delivery artifacts or a downstream patch.

#### Alternatives And Tradeoffs

1. **Branch directly on `statusCeiling != done`: rejected.** It would grant
  planning exemptions to docs, validated, pre-activation delivery, release,
  upkeep, propagation, incident, and framework-health semantics.
2. **Accept `--profile planning`: rejected.** A caller could weaken a delivery
  audit or accidentally split runner/validator/auditor interpretations.
3. **Separate planning and delivery guard executables: rejected.** Universal
  anti-fabrication checks would fork and drift; Audit A1 could again choose a
  different policy surface.
4. **Keep only an audit-agent prose exception: rejected.** Validate and finalize
  would still invoke done-shaped guard/finalization behavior, and no
  mechanical regression could prove the exception safe.
5. **Registry-bound contract: selected.** It adds one resolver and versioned
  result lint, but gives every boundary the same immutable target/profile and
  makes mismatch, staleness, and bypass attempts mechanically visible.

#### Single-Implementation Justification

This is one correction inside the existing workflow-mode, guard, validation,
audit, and finalization foundation. The resolver is shared infrastructure for
those existing consumers, not a new provider/plugin system. Separate provider
adapters or parallel guard implementations would increase drift without
representing a second domain capability, so a single registry-bound resolver is
the simplest viable architecture.

#### Complexity Tracking

| Deviation from simpler alternative | Simpler alternative | Why rejected |
| --- | --- | --- |
| Shared transition-contract resolver and digest | Add four `if planning` branches inside the guard/audit prose | Independent branches cannot prove state/registry/runner agreement and recreate the current drift. |
| Versioned audit result lint and attempt state | Print a planning verdict only in terminal prose | Terminal-only success becomes stale across interruption/rework and cannot be safely consumed by finalize. |
| Sub-check activation inside Checks 4/5/8/11 | Skip each whole numbered check | Whole-check skipping would also suppress format, parity, checked-item evidence, report integrity, and anti-fabrication signals. |

No additional architectural deviation is introduced.

### Planning Scope Inputs For `bubbles.plan`

1. **Completed analysis input:** the analyst-defined check classes, 24-mode
  inventory, acceptance scenarios, and planning-safe vocabulary remain the
  requirements baseline above.
2. **Completed design input:** the registry-bound transition contract,
  resolver/guard/audit/finalize interfaces, failure enum, security invariants,
  compatibility rules, test architecture, implementation surfaces, and
  rollback strategy in this section are authoritative for planning.
3. **Completed implementation and propagation plan:** the ordered scopes below
  are the implementation-ready handoff. Foundation contract/resolver work
  precedes guard/profile and audit/finalize overlays; no scope may edit a
  downstream installed copy.
4. **Execution and certification (delivery workflow only):** implementation,
   adversarial tests, canonical validation, re-vendoring, and post-fix consumer
  reproduction remain outside this planning-only invocation and cannot be
  claimed by the plan.

### Adversarial Regression Requirements

- Add an honest planning fixture with `workflowMode: product-to-planning`,
  target/terminal status `specs_hardened`, `Not Started` scopes, unchecked
  implementation DoD, planned file paths that do not exist, and scope reports
  that explicitly say no execution evidence was recorded. The planning-ceiling
  audit path must pass when all required planning gates pass.
- Run the same artifact shape under a `done`-ceiling delivery mode and require
  failure on Checks 4, 5, 8, and 11. This is the anti-overexemption control.
- Introduce one real planning-gate violation at a time (for example broken
  G068 traceability, missing G087 linkage, or a G073 source edit) and require
  the planning audit to fail. A broad "skip completion checks" test alone is
  insufficient.
- Exercise the actual `bubbles.audit` 0-pre/A1 path, not only Check 3 ceiling
  parsing in isolation.
- Retain the existing completed-fixture ceiling test as a compatibility case,
  but do not let it stand in for the honest unimplemented planning fixture.
- The regression must fail before the fix and pass after it; no silent-return,
  placeholder-file, fabricated-evidence, or mode-name hardcode may satisfy it.

### Acceptance Criteria

- A registry-resolved `product-to-planning` audit can certify an otherwise
  clean packet to at most `specs_hardened` while its implementation scopes,
  implementation DoD, planned test files, and execution reports remain honestly
  uncompleted.
- The same packet cannot be certified `done`, and the same missing delivery
  facts remain blocking in every `done`-ceiling delivery mode.
- Audit 0-pre and Audit A1 consume the same mode-aware guard verdict and no
  longer require a full-delivery verdict from a planning-only mode.
- The adversarial planning fixture, delivery control, planning-gate negative
  controls, and actual audit-path regression all pass after implementation and
  demonstrably fail on the pre-fix framework.
- Canonical framework validation and release checks pass, the release manifest
  records every changed framework surface, and normal re-vendoring restores
  canonical/installed parity without downstream hand edits.
- The GuestHost Spec 151 reproduction no longer reports missing delivery files
  or execution evidence as blockers to planning-ceiling audit. Any independent
  planning-gate failure remains visible and blocking.

### Implementation-Ready Ordered Scope Plan

This is the sole active BUG-009 execution plan. Gate G085 forbids creating a
framework-source `specs/` packet, so all scope, scenario, Test Plan, DoD,
dependency, rollback, and routing content remains inline in this BUG-009 entry.
Every scope starts `Not Started`; every DoD item is intentionally unchecked.
No entry below is execution evidence or a claim that the fix exists.

#### Execution Outline

**Phase order:**

1. **S01 — Adversarial red contract:** add and register the honest unimplemented
  planning regression, then prove it fails against the unmodified production
  guard and Audit 0-pre path for Checks 4, 5, 8, and 11.
2. **S02 — Registry and resolver foundation (`foundation:true`):** define the
  closed `transitionAudit` schema and implement the sole state-to-contract
  resolver with alias, digest, target, and failure-contract coverage.
3. **S03 — Guard profile activation:** make the existing guard consume the
  resolved contract once and split only the completion portions of Checks 4,
  5, 8, and 11 while retaining universal and planning checks.
4. **S04 — Audit result contract:** implement profile-aware Audit 0-pre/A1,
  audit attempt handling, and the frozen `AUDIT_RESULT_V1` parser/lint without
  changing delivery verdict semantics.
5. **S05 — Validate and finalize coherence:** bind validate and finalize to the
  same target revision and contract digest, preserving validate-only
  certification ownership and stale-result rejection.
6. **S06 — Matrix and persistent regression:** close the full 12-scenario,
  24-mode, done-control, metadata, alias, audit-output, and portability matrix;
  make the red regression green through real framework behavior.
7. **S07 — Documentation contract:** update operator and maintainer docs plus
  the changelog only after executable proof exists, keeping planning maturity
  distinct from delivery.
8. **S08 — Canonical release package:** update version/provenance surfaces,
  regenerate derived registries and the release manifest last, then pass the
  canonical release check and hermetic install-provenance checks.
9. **S09 — Supported GuestHost upgrade:** use the installer/upgrade path only,
  then prove installed bytes, manifest membership, and checksum provenance;
  never edit a downstream managed file directly.
10. **S10 — Consumer audit and transition:** rerun the GuestHost Spec 151
   planning audit and validate-owned transition to exactly `specs_hardened`,
   preserving incomplete delivery state and closing the original finding only
   when the consumer evidence is real.

**New types and signatures:**

- YAML: `transitionAudit: {profile: planning-maturity-v1 |
  delivery-completion-v1, target: statusCeiling}`.
- JSON: `transition-contract/v1` with `workflowMode`, `auditProfile`,
  `statusCeiling`, `targetStatus`, `currentStatus`, complete `requiredGates`,
  ordered `phaseOrder`, `sourceEditLockoutRequired`, `contractRef`,
  `contractDigest`, and `targetRevision`.
- CLI: `transition-contract-resolver.sh FEATURE_DIR [--expect-mode MODE]
  [--expect-target STATUS] [--expect-contract-digest sha256:HEX]`.
- CLI: existing `state-transition-guard.sh FEATURE_DIR` plus assertion-only
  `--target-status`, `--expect-workflow-mode`, and
  `--expect-contract-digest`; `--revert-on-fail` retains its delivery behavior.
- Machine result: ordered `TRANSITION_GUARD_RESULT_V1` and frozen
  `AUDIT_RESULT_V1` blocks.
- State evidence: additive `execution.audit` `audit-run/v1` attempt history;
  it is evidence, not a second policy source or certification authority.

**Validation checkpoints:**

- S01 captures a deliberate red result before any production-source edit. A
  nonzero result is the required red checkpoint, not a passing-suite claim.
- S02, S03, S04, and S05 each run their narrow hermetic selftest first. The
  aggregate BUG-009 regression remains red until all dependent behavior exists;
  unrelated framework checks must not regress in the interim.
- S06 requires the approved aggregate framework command to exit zero before
  docs or release surfaces change.
- S08 requires the approved release command to exit zero against regenerated
  canonical artifacts before any downstream upgrade.
- S09 requires installed-byte and provenance parity before GuestHost audit is
  attempted.
- S10 requires the real installed guard, audit result, and validate-owned
  transition to agree on mode, target, digest, revision, and finding accounting.

#### Scope Inventory And Dependency Graph

| Scope | Primary owner | Depends on | Principal surfaces | Required checkpoint | Status |
| --- | --- | --- | --- | --- | --- |
| S01 Red regression contract | `bubbles.implement` | none | Regression fixture/harness and minimal validation registration | Red for the exact pre-fix behavior | Done — exact intentional RED established |
| S02 Registry/resolver foundation | `bubbles.implement` | S01 | Registry, schema, resolver, resolver selftest | Resolver selftest | Done — 56/56 focused assertions pass |
| S03 Guard profile activation | `bubbles.implement` | S02 | Guard Checks 3/4/5/8/11, planning-check ledger, guard selftest | Guard selftest | Done — focused profile, adversary, compatibility, and A-F checks pass |
| S04 Audit result contract | `bubbles.implement` | S03 | Audit 0-pre/A1, result lint, audit attempts | Audit contract selftest | Done — 22/22 contract and 24/24 persistent audit-path assertions pass |
| S05 Validate/finalize coherence | `bubbles.implement` | S04 | Validate 2.11, phase engine, finalize, templates | Cross-boundary selftest | Done — 48/48 focused assertions pass |
| S06 Matrix and persistent regression | `bubbles.test` | S05 | 12 scenarios, 24-mode matrix, done controls, regression runner | `framework-validate` | Not Started |
| S07 Documentation contract | `bubbles.docs` | S06 | Maintainer/operator docs and changelog | Docs/agnosticity validation | Not Started |
| S08 Canonical release package | `bubbles.releases` with `bubbles.devops` for installer provenance | S07 | Version, derived registries, installer, release manifest | `release-check` | Not Started |
| S09 GuestHost supported upgrade | `bubbles.devops` | S08 | Supported upgrade, installed manifest/checksums, byte parity | Installed provenance parity | Not Started |
| S10 GuestHost audit/transition | `bubbles.audit`, then `bubbles.validate` for certification only | S09 | Spec 151 audit evidence and exact planning transition | Real consumer audit at `specs_hardened` | Not Started |

The next eligible scope is S06. No later scope may start until every dependency
has met its own unchecked DoD with execution-backed evidence.

#### Approved Command And Test Taxonomy Contract

All canonical source validation uses exact commands from
`.specify/memory/agents.md`:

```text
bash bubbles/scripts/cli.sh framework-validate
bash bubbles/scripts/cli.sh release-check
bash bubbles/scripts/cli.sh agnosticity
bash bubbles/scripts/cli.sh doctor
```

Narrow shell selftests may be invoked by their exact script path before the
aggregate command, consistent with the registry's allowance for specific
maintainer scripts. The supported downstream operation is
`bash .github/bubbles/scripts/cli.sh upgrade`; it is an install action, not a
source validation substitute. GuestHost guard/lint checks use the installed
CLI forms `bash .github/bubbles/scripts/cli.sh guard
specs/151-self-hosted-appliance-packaging` and
`bash .github/bubbles/scripts/cli.sh lint
specs/151-self-hosted-appliance-packaging`.

| Canonical category | Applicability to BUG-009 | Required treatment |
| --- | --- | --- |
| Unit / shell selftest | Applicable | Hermetic resolver, guard, and result-lint selftests execute real production scripts and inspect parsed outputs and exit contracts. |
| Functional | Applicable | `framework-validate` exercises registry/schema/agent/static-contract behavior. |
| Integration | Applicable | Real resolver -> guard -> validate/audit/finalize composition runs against an honest temporary packet with no mocked internal boundary. |
| Framework E2E regression | Applicable | `release-check` executes the persistent `test_23_planning_audit_contract.sh` path plus release/install checks. |
| Lint / portability | Applicable | `agnosticity` and framework validation cover Markdown/YAML/shell contracts and macOS/Linux portability. |
| `e2e-api`, `e2e-ui`, UI unit | Not applicable | The framework bug exposes no HTTP or browser surface; a shell fixture must not be mislabeled as an API/UI live system. |
| Stress / load / observability | Not applicable | No throughput, latency, service, or telemetry contract changes; no invented load or trace evidence is permitted. |

Test assertions must consume exit codes, parsed JSON, ordered result blocks,
state transitions, and real check ledgers. Keyword presence alone, an early
return on the buggy condition, a test-created success block, or files created
only to appease Check 8 is not behavioral proof.

#### Global Change Boundary And Blast-Radius Controls

**Allowed source families:** only the exact implementation, selftest,
regression, agent/shared-contract, docs, version, installer-provenance, and
derived-release surfaces named in the design table and scopes below. A newly
required managed-file registration may touch `install.sh`,
`bubbles/scripts/framework-validate.sh`, or the release generator only where
the corresponding selftest proves the need.

**Explicitly excluded:** `aliases.yaml` semantics; mode names; terminal aliases;
existing phase orders, required gates, ceilings, and focus fields except for the
additive `transitionAudit` binding; unrelated guard checks/gates; docs-only,
validated, delivered-pending-activation, train, upkeep, propagation, incident,
and framework-health evidence semantics; product source; release-train config;
and every downstream `.github/bubbles/**`, `.github/agents/**`, or managed
framework file. Collateral cleanup is prohibited unless this BUG-009 plan is
reconciled first.

The high-fan-out surfaces are `modes.yaml`, `state-transition-guard.sh`, Audit
0-pre/A1, validate/finalize, and `install.sh`. Their independent canaries are:
the honest planning positive, the same fixture under done semantics, the 24-mode
classification matrix, persisted-alias/v6-form contract identity, stale/mismatch
metadata failures, all five UX result views plus interruption/rework, and a
hermetic downstream install parity test. Broad validation follows, never
replaces, these canaries.

Rollback is coherent and source-first: revert the complete BUG-009 source
change, regenerate derived outputs and `bubbles/release-manifest.json` from the
reverted source, pass `release-check`, and distribute the prior known-good
version through the supported installer. Never delete `execution.audit`
history, rewrite GuestHost state, hand-copy prior bytes, or leave only the
planning exemption, agent prose, or generated manifest in place. A rollback
honestly reopens the pre-fix audit defect while preserving unchanged delivery
rigor.

#### S01 — Adversarial Red Contract

- **Status:** Done — exact intentional RED established; production behavior unchanged
- **Primary owner:** `bubbles.implement`
- **Depends on:** none
**Change boundary:** `tests/regression/test_23_planning_audit_contract.sh` and
the minimal registration needed for the canonical validation runner. No
production resolver, guard, agent, registry, schema, installer, manifest, docs,
or downstream file may change in this scope.

**Gherkin — TDD red for Acceptance Scenarios A and F:**

```gherkin
Given an honest product-to-planning packet with Not Started scopes, unchecked implementation DoD, absent planned test files, zero execution-evidence blocks, and clean planning gates
When the unmodified canonical guard and actual Audit 0-pre contract evaluate it
Then the regression command exits nonzero because Checks 4, 5, 8, and 11 incorrectly demand delivery completion
And the harness records that result as the required pre-fix red state rather than a passing audit or a fix
```

**Implementation steps:**

1. Build one hermetic temporary packet with real planning artifacts and state;
  do not create the planned implementation test files or evidence blocks.
2. Execute the real `state-transition-guard.sh` and Audit 0-pre/A1 command path;
  do not clone their logic into the test.
3. Assert the nonzero guard/audit result and the four implicated completion
  sub-check failures while the named planning gates remain clean.
4. Register the persistent regression so the same test becomes green only when
  later scopes implement the designed behavior.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| A/F pre-fix | Framework E2E regression, red | `tests/regression/test_23_planning_audit_contract.sh` | Real guard/audit rejects honest planning solely on delivery completion facts; no silent bailout or generated success output | `bash bubbles/scripts/cli.sh framework-validate` (expected nonzero red) |
| Fixture integrity | Functional | same | Removing the production guard/audit invocation or adding fake planned files/evidence makes the regression fail its own integrity assertions | `bash bubbles/scripts/cli.sh agnosticity` |

**Definition of Done:**

- [x] The persistent test executes the real guard and Audit 0-pre/A1 path, not a keyword proxy or copied decision function. Evidence: [S01 terminal intentional RED evidence](#bug-009-s01-terminal-intentional-red-evidence).
- [x] The fixture is honestly unimplemented and contains no synthetic test file, checked DoD, Done scope, or execution block added to satisfy delivery checks. Evidence: [S01 terminal intentional RED evidence](#bug-009-s01-terminal-intentional-red-evidence).
- [x] Current source produces the expected nonzero red result naming Check-4-completion, Check-5-all-done, Check-8-file-existence, and Check-11-execution-evidence. Evidence: [S01 terminal intentional RED evidence](#bug-009-s01-terminal-intentional-red-evidence).
- [x] The red evidence is captured before any BUG-009 production-source edit and is not described as a passing suite or fixed behavior. Evidence: [S01 terminal intentional RED evidence](#bug-009-s01-terminal-intentional-red-evidence).
- [x] No file outside the S01 change boundary changed. Evidence: [S01 change boundary evidence](#bug-009-s01-change-boundary-evidence).

##### BUG-009 S01 Production Invocation And Fixture Integrity

**Historical evidence:** This earlier mismatch packet is preserved unchanged as
the pre-repair record. It is superseded for terminal S01 disposition by
[S01 terminal intentional RED evidence](#bug-009-s01-terminal-intentional-red-evidence).

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_23_planning_audit_contract.sh; regression_exit=$?; printf '\nBUG009_S01_REGRESSION_EXIT=%s\n' "$regression_exit"; exit "$regression_exit"`

**Exit Code:** 2

**Claim Source:** executed

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: integrity adversary 'done-status' is rejected
PASS: integrity adversary 'checked-dod' is rejected
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the state-transition guard blocking verdict
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: direct path records the canonical production invocation
PASS: Audit path records the canonical production invocation
FAIL: Check-4-completion is unconditionally blocking (section=--- Check 4: missing=unchecked DoD item(s) remain)
PASS: Check-5-all-done is unconditionally blocking
PASS: Check-8-file-existence is unconditionally blocking
PASS: Check-11-execution-evidence is unconditionally blocking
PASS: G040 planning integrity is clean
FAIL: G068 planning traceability is clean (missing: Gherkin scenarios have faithful DoD items)
PASS: G091 planning chain is clean
PASS: G087 implementation linkage is clean
FAIL: G093 delivery delta is clean or correctly exempt (missing: Delivery implementation delta is present or mode ceiling exempts it)
PASS: G094 capability foundation is clean
PASS: G095 disposition is clean
PASS: G097 mechanism correspondence is clean
FAIL: guard emitted blockers outside Check 4/5/8/11
--- Check 3H: Validate Certification State (Gate G056) --- :: BLOCK: certification block missing scopeProgress (Gate G056)
--- Check 3E: Scenario-first TDD Evidence (Gate G060) --- :: BLOCK: Effective TDD mode is scenario-first (source: snapshot) but no RED-to-GREEN ordering was found in the scope/report artifacts (Gate G060)
--- Check 8A: Scenario-Specific Regression E2E Coverage --- :: BLOCK: 3 regression E2E planning requirement(s) missing
--- Check 13: Artifact Lint --- :: BLOCK: Artifact lint FAILED
--- Check 23: Convergence Cap Enforcement (Gate G082) --- :: BLOCK: Convergence cap exceeded — Gate G082 violation
--- Check 29B: Delivery Implementation Delta (Gate G093) --- :: BLOCK: Delivery implementation delta guard failed — Gate G093
--- Check 33: Retro Convergence Health Evidence (Gate G090) --- :: BLOCK: Retro convergence health failed — Gate G090
DISCRIMINATOR_MISMATCH: observed guard failure differs from BUG-009 S01 hypothesis (4 harness assertion(s) failed)
DIRECT_GUARD_EXIT=1
AUDIT_0_PRE_A1_EXIT=1

BUG009_S01_REGRESSION_EXIT=2
```

**Result:** FAIL — genuine nonzero execution, but not the required isolated S01
red checkpoint. This is not a passing-suite or fixed-bug claim.

##### BUG-009 S01 Static Validation

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash -n tests/regression/test_23_planning_audit_contract.sh && bash -n bubbles/scripts/framework-validate.sh; syntax_exit=$?; printf 'SYNTAX_EXIT=%s\n' "$syntax_exit"; bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh; quality_exit=$?; printf 'REGRESSION_QUALITY_EXIT=%s\n' "$quality_exit"; bash bubbles/scripts/cli.sh agnosticity; agnosticity_exit=$?; printf 'AGNOSTICITY_EXIT=%s\n' "$agnosticity_exit"; if [[ "$syntax_exit" -eq 0 && "$quality_exit" -eq 0 && "$agnosticity_exit" -eq 0 ]]; then exit 0; fi; exit 1`

**Exit Code:** 0

**Claim Source:** executed

```text
SYNTAX_EXIT=0
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-11T03:18:17Z
  Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_23_planning_audit_contract.sh
✅ Adversarial signal detected in tests/regression/test_23_planning_audit_contract.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
REGRESSION_QUALITY_EXIT=0
ℹ️  Scanning 452 portable file(s) for agnosticity drift
✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
AGNOSTICITY_EXIT=0
```

**Result:** PASS — syntax, adversarial regression-quality, and canonical
agnosticity checks pass independently of the intentional/mismatched RED
behavior. Full framework validation was not run and is not claimed green.

##### BUG-009 S01 Terminal Intentional RED Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_23_planning_audit_contract.sh; regression_exit=$?; printf '\nBUG009_S01_REGRESSION_EXIT=%s\n' "$regression_exit"; exit "$regression_exit"`

**Exit Code:** 1 (intentional RED)

**Claim Source:** executed

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: integrity adversary 'done-status' is rejected
PASS: integrity adversary 'checked-dod' is rejected
PASS: fixture passes artifact lint with real required fields and artifacts
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the state-transition guard blocking verdict
PASS: product-to-planning registry contract does not require G060 or force scenario-first TDD
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: direct path records the canonical production invocation
PASS: Audit path records the canonical production invocation
PASS: Check-4-completion is unconditionally blocking
PASS: Check-5-all-done is unconditionally blocking
PASS: Check-8-file-existence is unconditionally blocking
PASS: Check-11-execution-evidence is unconditionally blocking
PASS: G040 planning integrity is clean
PASS: G056 certification scopeProgress is structurally complete
PASS: G060 correctly follows the planning-only TDD policy without fabricated evidence
PASS: Check 8A scenario-specific regression DoD is planned
PASS: Check 8A broader regression DoD is planned
PASS: Check 8A regression Test Plan row is planned
PASS: G068 planning traceability is clean
PASS: G091 uses the canonical hermetic-fixture posture
PASS: G087 uses the canonical hermetic-fixture posture
PASS: G093 uses the canonical hermetic-fixture posture
PASS: G082 uses the canonical hermetic-fixture posture
PASS: G090 uses the canonical hermetic-fixture posture
PASS: artifact lint is clean for the fixture
PASS: G094 capability foundation is clean
PASS: G095 disposition is clean
PASS: G097 mechanism correspondence is clean
PASS: guard blockers are confined to Check 4/5/8/11
--- BUG-009 S01 canonical RED discriminator ---
--- Check 4: DoD Completion (Zero Unchecked) ---
🔴 BLOCK: Resolved scope artifacts have 3 UNCHECKED DoD items — ALL must be [x] for 'done'
--- Check 5: Scope Status Cross-Reference ---
🔴 BLOCK: Resolved scope artifacts have 1 scope(s) still marked 'Not Started' — ALL scopes must be Done
✅ PASS: completedScopes count matches artifact Done scope count (0)
--- Check 8: Test File Existence ---
🔴 BLOCK: Test Plan references non-existent file: /Users/pkirsanov/Projects/bubbles/tests/fixtures/bubbles-bug009-s01-iKOPcoxL/909-bug009-planning-audit-contract/tests/regression/planning_contract_future_test.sh
🔴 BLOCK: Test Plan references non-existent file: /Users/pkirsanov/Projects/bubbles/tests/fixtures/bubbles-bug009-s01-iKOPcoxL/909-bug009-planning-audit-contract/tests/regression/planning_contract_future_test.sh
🔴 BLOCK: 2 of 2 test files from Test Plan DO NOT EXIST
--- Check 11: Report.md Required Sections ---
✅ PASS: report.md has required report section
✅ PASS: report.md has required report section
✅ PASS: report.md has required report section
🔴 BLOCK: report.md has ZERO evidence code blocks — no execution evidence exists
✅ PASS: No narrative summary phrases detected outside code blocks in report.md
🔴 TRANSITION BLOCKED: 6 failure(s), 1 warning(s)
DIRECT_GUARD_EXIT=1
AUDIT_0_PRE_A1_EXIT=1
RED_REGRESSION_VERDICT=EXPECTED_PRE_FIX_COMPLETION_FAILURE
test_23_planning_audit_contract: 34 integrity/discriminator assertions passed; intentional RED exit follows

BUG009_S01_REGRESSION_EXIT=1
```

**Result:** EXPECTED RED — the unchanged production guard and Audit 0-pre/A1
path both exit 1 solely on the completion portions of Checks 4, 5, 8, and 11.
This is not a passing suite, production fix, audit success, or delivery claim.

##### BUG-009 S01 Terminal Static Validation

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash -n tests/regression/test_23_planning_audit_contract.sh && bash -n bubbles/scripts/framework-validate.sh; syntax_exit=$?; printf 'SYNTAX_EXIT=%s\n' "$syntax_exit"; bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh; quality_exit=$?; printf 'REGRESSION_QUALITY_EXIT=%s\n' "$quality_exit"; bash bubbles/scripts/cli.sh agnosticity; agnosticity_exit=$?; printf 'AGNOSTICITY_EXIT=%s\n' "$agnosticity_exit"; git diff --check; diff_check_exit=$?; printf 'GIT_DIFF_CHECK_EXIT=%s\n' "$diff_check_exit"; if [[ "$syntax_exit" -eq 0 && "$quality_exit" -eq 0 && "$agnosticity_exit" -eq 0 && "$diff_check_exit" -eq 0 ]]; then exit 0; fi; exit 1`

**Exit Code:** 0

**Claim Source:** executed

```text
SYNTAX_EXIT=0
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-11T03:43:37Z
  Bugfix mode: true
============================================================

ℹ️  Scanning tests/regression/test_23_planning_audit_contract.sh
✅ Adversarial signal detected in tests/regression/test_23_planning_audit_contract.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
REGRESSION_QUALITY_EXIT=0
ℹ️  Scanning 452 portable file(s) for agnosticity drift
✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
AGNOSTICITY_EXIT=0
GIT_DIFF_CHECK_EXIT=0
```

**Result:** PASS — shell syntax, adversarial regression quality, canonical
agnosticity, and diff whitespace checks all pass after the terminal intentional
RED. Full framework validation was intentionally not run and is not claimed
green while this persistent regression remains red.

##### BUG-009 S01 Change Boundary Evidence

**Phase:** `implement`

**Command:** `export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"; cd /Users/pkirsanov/Projects/bubbles && boundary_exit=0; for file_path in bubbles/scripts/state-transition-guard.sh bubbles/scripts/mode-resolver.sh agents/bubbles.audit.agent.md agents/bubbles.validate.agent.md bubbles/workflows/modes.yaml bubbles/schemas/workflows.schema.json; do if git diff --quiet -- "$file_path" && [[ -z "$(git status --short --untracked-files=all -- "$file_path")" ]]; then printf 'PASS: protected production surface unchanged: %s\n' "$file_path"; else printf 'FAIL: protected production surface changed: %s\n' "$file_path"; boundary_exit=1; fi; done; printf '%s\n' 'S01_ALLOWED_SURFACES:'; git status --short --untracked-files=all -- BUGS.md bubbles/scripts/framework-validate.sh tests/regression/test_23_planning_audit_contract.sh; printf '%s\n' 'PRESERVED_UNRELATED_SURFACES:'; git status --short --untracked-files=all -- bubbles/scripts/eval-harness.sh bubbles/eval/schemas improvements/INDEX.md improvements/IMP-020-agentic-evaluation-and-trust-hardening.md; printf 'BOUNDARY_EXIT=%s\n' "$boundary_exit"; exit "$boundary_exit"`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: protected production surface unchanged: bubbles/scripts/state-transition-guard.sh
PASS: protected production surface unchanged: bubbles/scripts/mode-resolver.sh
PASS: protected production surface unchanged: agents/bubbles.audit.agent.md
PASS: protected production surface unchanged: agents/bubbles.validate.agent.md
PASS: protected production surface unchanged: bubbles/workflows/modes.yaml
PASS: protected production surface unchanged: bubbles/schemas/workflows.schema.json
S01_ALLOWED_SURFACES:
 M BUGS.md
 M bubbles/scripts/framework-validate.sh
?? tests/regression/test_23_planning_audit_contract.sh
PRESERVED_UNRELATED_SURFACES:
 M bubbles/scripts/eval-harness.sh
 M improvements/INDEX.md
?? bubbles/eval/schemas/evaluator-result.schema.json
?? bubbles/eval/schemas/task-v2.schema.json
?? improvements/IMP-020-agentic-evaluation-and-trust-hardening.md
BOUNDARY_EXIT=0
```

**Result:** PASS — the S01 delta is confined to the persistent regression, its
existing one-line canonical validation registration, and this BUGS.md S01
evidence/status record. The listed evaluation and improvement changes are
unrelated user-owned worktree state and were preserved without modification.

**S01 disposition:** terminal `route_required` to `bubbles.implement` for S02
only. `redRegressionVerdict=EXPECTED_PRE_FIX_COMPLETION_FAILURE` and
`productionBehaviorChanged=false`. S02 remains Not Started and is now the next
required scope; no S02 implementation was started.

#### S02 — Registry And Resolver Foundation

- **Status:** Done — resolver selftest and focused validation passed; S01 RED preserved
- **Primary owner:** `bubbles.implement`
- **Depends on:** S01
- **Foundation:** `true`
**Change boundary:** `bubbles/workflows/modes.yaml`,
`bubbles/schemas/workflows.schema.json`, new
`bubbles/scripts/transition-contract-resolver.sh`, and new
`bubbles/scripts/transition-contract-resolver-selftest.sh`.
`mode-resolver.sh`, `trust-metadata.sh`, and `aliases.yaml` are read-only
dependencies unless an observed failing selftest proves a narrowly planned
compatibility defect.

**Gherkin — Acceptance Scenarios A/B, J/K, and alias compatibility:**

```gherkin
Given product-to-planning or spec-scope-hardening is persisted in consistent state
When the resolver composes the effective registry entry through grandfather-compatible mode resolution
Then it emits planning-maturity-v1 at specs_hardened with a deterministic contract digest and target revision
And caller expectations can only confirm, never select, the contract

Given state, registry, target, profile invariants, or digest expectations are missing, unknown, malformed, stale, or contradictory
When contract resolution runs
Then it fails with the exact closed E009 code and emits no inferred planning or delivery contract

Given persisted product-to-planning and the v6 plan target:product action:analyze-design-plan form resolve to the same canonical mode
When their effective transition contracts are normalized
Then the contracts are byte-identical and aliases.yaml remains unchanged
```

**Implementation steps:**

1. Add the closed `transitionAudit` schema and bindings for the two planning
  modes plus audit-bearing done modes covered by the selected design.
2. Resolve state, policy snapshot, certification mirror, effective mode,
  complete gates, ordered phases, profile invariants, target, and assertions in
  one read-only script.
3. Generate canonical `contractDigest` and `targetRevision` with
  `bubbles_sha256_stdin`; exclude only the design-approved audit-owned fields.
4. Implement exits 64-72 and stable `E009-*` stderr output with no profile,
  skip, force, ignore, or environment override.
5. Cover source and installed layouts, persisted alias/v6 identity, idempotent
  re-audit, and each metadata contradiction in the resolver selftest.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| A/B | Unit / shell selftest | `bubbles/scripts/transition-contract-resolver-selftest.sh` | Parsed JSON contains the complete effective registry contract, stable digests, and exact planning target for both modes | `bash bubbles/scripts/transition-contract-resolver-selftest.sh` |
| J/K | Unit / negative | same | Each malformed/mismatch case returns its exact E009 exit/code and no usable contract | `bash bubbles/scripts/transition-contract-resolver-selftest.sh` |
| Alias compatibility | Integration | same | Persisted v5 key and v6 form produce byte-identical normalized contracts through production `mode-resolver.sh --grandfather` | `bash bubbles/scripts/cli.sh framework-validate` |

**Definition of Done:**

- [x] The schema rejects unknown profile/target fields and profile selection remains registry-only. Evidence: [S02 resolver selftest evidence](#bug-009-s02-resolver-selftest-evidence).
- [x] Both planning modes satisfy all seven planning-profile invariants; every audit-bearing done mode has an explicit delivery binding required by the design. Evidence: [S02 resolver selftest evidence](#bug-009-s02-resolver-selftest-evidence).
- [x] Unknown custom non-done modes and all 22 adjacent non-done audit modes receive their designed non-planning treatment and never inherit the planning profile from their ceiling. Evidence: [S02 resolver selftest evidence](#bug-009-s02-resolver-selftest-evidence).
- [x] All resolver success, mismatch, alias, digest, source/installed-layout, and closed failure-code tests pass against real production resolution. Evidence: [S02 resolver selftest evidence](#bug-009-s02-resolver-selftest-evidence).
- [x] `aliases.yaml` semantics and all pre-existing mode phase/gate/ceiling fields are unchanged. Evidence: [S02 focused validation evidence](#bug-009-s02-focused-validation-evidence).
- [x] No file outside the S02 change boundary changed. Evidence: [S02 focused validation evidence](#bug-009-s02-focused-validation-evidence).

##### BUG-009 S02 Resolver Selftest Evidence

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `bash bubbles/scripts/transition-contract-resolver-selftest.sh`
**Exit Code:** 0
**Output:**

```text
== transition contract resolver selftest ==
PASS: transitionAudit schema is closed to the designed profile and target fields
PASS: schema accepts canonical bindings and rejects unknown profile, target, and selector fields
PASS: product-to-planning resolves through the production resolver
PASS: spec-scope-hardening resolves through the production resolver
PASS: bugfix-fastlane resolves a delivery contract
PASS: planning contract has normalized schema and feature path
PASS: planning contract names the canonical persisted mode
PASS: planning contract derives profile and target from the registry
PASS: planning contract exposes current state and G073 source lockout
PASS: planning contract carries the canonical registry reference
PASS: planning contract carries deterministic SHA-256 identities
PASS: scope hardening satisfies the planning profile invariants
PASS: delivery mode retains explicit completion semantics
PASS: resolver emits the complete sorted effective gate set
PASS: resolver preserves the complete ordered phase list
PASS: v6 planning form maps to the persisted canonical key
PASS: persisted v5 and current v6 forms resolve byte-identical mode definitions
PASS: persisted and v6-derived canonical modes produce byte-identical transition contracts
PASS: repeated resolution is byte-stable
PASS: contract digest is stable across idempotent resolution
PASS: target revision is stable across idempotent resolution
PASS: expectation flags only confirm and never alter the derived contract
PASS: expected mode mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: expected target mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: stale digest mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: caller profile flag returns E009-USAGE with exit 64 and empty stdout
PASS: caller bypass flag returns E009-USAGE with exit 64 and empty stdout
PASS: caller profile environment returns E009-USAGE with exit 64 and empty stdout
PASS: missing feature argument returns E009-USAGE with exit 64 and empty stdout
PASS: audit-owned state and report blocks do not invalidate their own target revision
PASS: artifact mutation does not change the registry contract digest
PASS: non-audit artifact mutation changes the target revision
PASS: source layout resolves byte-identical contracts
PASS: installed .github/bubbles layout resolves byte-identical contracts
PASS: missing registry returns E009-REGISTRY-MISSING with exit 66 and empty stdout
PASS: malformed state returns E009-STATE-MALFORMED with exit 65 and empty stdout
PASS: unknown mode returns E009-MODE-UNKNOWN with exit 67 and empty stdout
PASS: state policy mode mismatch returns E009-STATE-MODE-MISMATCH with exit 68 and empty stdout
PASS: certification mirror mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: terminal target mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: missing delivery profile returns E009-AUDIT-PROFILE-MISSING with exit 70 and empty stdout
PASS: missing designated planning profile returns E009-AUDIT-PROFILE-MISSING with exit 70 and empty stdout
PASS: unsupported adjacent non-done mode returns E009-AUDIT-PROFILE-UNSUPPORTED with exit 71 and empty stdout
PASS: unknown explicit profile returns E009-AUDIT-PROFILE-UNSUPPORTED with exit 71 and empty stdout
PASS: malformed transition audit metadata returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: planning implementation phase contradiction returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: registry target contradiction returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: unsupported transition audit field returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: planning profile on delivery mode returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: every audit-bearing done mode has an explicit delivery binding
PASS: exactly the two designed planning modes have planning bindings
PASS: adjacent non-done audit modes receive no inferred profile
PASS: all 22 adjacent non-done audit modes remain explicitly unsupported
PASS: delivery phase-shape compatibility exceptions are a closed six-mode set
PASS: all 27 audit-bearing done modes resolve through explicit delivery contracts
PASS: all 22 adjacent non-done audit modes fail unsupported through the real resolver
== transition contract resolver selftest summary ==
passes=56
failures=0
skips=0
transition-contract-resolver-selftest: PASS
```

**Result:** PASS. The production resolver and real schema cover both planning
modes, the full explicit delivery set, all 22 adjacent audit modes, alias/current
identity, complete gates/phases, stable digests, source and installed layouts,
assertion-only inputs, and the closed exits 64-72.

##### BUG-009 S02 Focused Validation Evidence

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `printf '%s\n' 'BUG-009 S02 focused validation' 'CHECK 1: shell syntax' && bash -n bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/transition-contract-resolver-selftest.sh bubbles/scripts/framework-validate.sh && printf '%s\n' 'PASS 1: shell syntax' 'CHECK 2: shellcheck' && shellcheck -x bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/transition-contract-resolver-selftest.sh && printf '%s\n' 'PASS 2: shellcheck' 'CHECK 3: mode registry resolution' && bash bubbles/scripts/mode-resolver.sh --validate && printf '%s\n' 'PASS 3: mode registry resolution' 'CHECK 4: mode resolver compatibility' && bash bubbles/scripts/mode-resolver-selftest.sh && printf '%s\n' 'PASS 4: mode resolver compatibility' 'CHECK 5: workflow registry consistency' && bash bubbles/scripts/workflow-registry-consistency.sh --quiet && printf '%s\n' 'PASS 5: workflow registry consistency' 'CHECK 6: framework agnosticity' && bash bubbles/scripts/cli.sh agnosticity && printf '%s\n' 'PASS 6: framework agnosticity' 'CHECK 7: diff integrity' && git diff --check -- BUGS.md bubbles/workflows/modes.yaml bubbles/schemas/workflows.schema.json bubbles/scripts/framework-validate.sh && printf '%s\n' 'PASS 7: diff integrity' 'CHECK 8: executable registration' && test -x bubbles/scripts/transition-contract-resolver.sh && test -x bubbles/scripts/transition-contract-resolver-selftest.sh && grep -Fq 'Transition contract resolver selftest (BUG-009 S02)' bubbles/scripts/framework-validate.sh && printf '%s\n' 'PASS 8: executable registration' 'CHECK 9: protected compatibility surfaces' && for protected_file in bubbles/scripts/mode-resolver.sh bubbles/scripts/trust-metadata.sh bubbles/workflows/aliases.yaml; do git diff --quiet -- "$protected_file" || exit 1; printf 'UNCHANGED: %s\n' "$protected_file"; done && printf '%s\n' 'PASS 9: protected compatibility surfaces' 'CHECK 10: metadata-only mode delta' && baseline_without_contracts="$(git show HEAD:bubbles/workflows/modes.yaml | yq -o=json -I=0 'del(.modes[].transitionAudit)')" && current_without_contracts="$(yq -o=json -I=0 'del(.modes[].transitionAudit)' bubbles/workflows/modes.yaml)" && [[ "$baseline_without_contracts" == "$current_without_contracts" ]] && printf '%s\n' 'PASS 10: all pre-existing mode fields unchanged' 'BUG-009 S02 focused validation: PASS'`
**Exit Code:** 0
**Output:**

```text
BUG-009 S02 focused validation
CHECK 1: shell syntax
PASS 1: shell syntax
CHECK 2: shellcheck
PASS 2: shellcheck
CHECK 3: mode registry resolution
Validation passed: all templates and modes resolve cleanly with no inherits cycles.
PASS 3: mode registry resolution
CHECK 4: mode resolver compatibility
PASS: Case 1: single-template inheritance — scalar flows through
PASS: Case 2: multi-template arrays concat + dedup + sort
PASS: Case 3: override semantics — mode wins over template
PASS: Case 4: cycle detection — resolver rejects template cycle
PASS: Case 5: unknown template reference rejected
PASS: Case 6: real workflows.yaml --validate
PASS: Case 7: SCOPE-13 inherited spec-review default flows from template
PASS: Case 8: SCOPE-13 explicit mode opt-out remains machine-readable
PASS: Case 9: real inherited done-ceiling mode receives spec-review default
PASS: Case 10: SCOPE-13/G091 planning-chain metadata validates without stall

All mode-resolver selftests passed.
PASS 4: mode resolver compatibility
CHECK 5: workflow registry consistency
PASS 5: workflow registry consistency
CHECK 6: framework agnosticity
ℹ️  Scanning 452 portable file(s) for agnosticity drift
✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
PASS 6: framework agnosticity
CHECK 7: diff integrity
PASS 7: diff integrity
CHECK 8: executable registration
PASS 8: executable registration
CHECK 9: protected compatibility surfaces
UNCHANGED: bubbles/scripts/mode-resolver.sh
UNCHANGED: bubbles/scripts/trust-metadata.sh
UNCHANGED: bubbles/workflows/aliases.yaml
PASS 9: protected compatibility surfaces
CHECK 10: metadata-only mode delta
PASS 10: all pre-existing mode fields unchanged
BUG-009 S02 focused validation: PASS
```

**Result:** PASS. The two new scripts are executable and registered minimally;
the protected resolver/trust/alias dependencies are unchanged, and deleting only
`transitionAudit` from the current registry reproduces every pre-existing mode
field from `HEAD` after canonical JSON normalization. Pre-existing unrelated
IMP-020 worktree changes and the S01 regression remain preserved and are not
attributed to S02.

##### BUG-009 S02 S01 Intentional RED Preservation Evidence

The first direct rerun in the dirty development checkout was non-discriminating:
G073 correctly observed the in-progress S02 registry/schema edits and the harness
returned 2. It is not used as S01 evidence. The unchanged S01 regression was then
executed against a disposable clean Git snapshot containing the exact final S01
and S02 bytes. The outer assertion command exited 0 only because the inner
regression exited exactly 1.

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `snapshot_root="$(mktemp -d "${TMPDIR:-/tmp}/bubbles-bug009-s01-final.XXXXXX")" && git clone --quiet --no-hardlinks . "$snapshot_root/bubbles" && cp BUGS.md "$snapshot_root/bubbles/BUGS.md" && cp bubbles/schemas/workflows.schema.json "$snapshot_root/bubbles/bubbles/schemas/workflows.schema.json" && cp bubbles/scripts/framework-validate.sh "$snapshot_root/bubbles/bubbles/scripts/framework-validate.sh" && cp bubbles/workflows/modes.yaml "$snapshot_root/bubbles/bubbles/workflows/modes.yaml" && cp bubbles/scripts/transition-contract-resolver.sh "$snapshot_root/bubbles/bubbles/scripts/transition-contract-resolver.sh" && cp bubbles/scripts/transition-contract-resolver-selftest.sh "$snapshot_root/bubbles/bubbles/scripts/transition-contract-resolver-selftest.sh" && cp tests/regression/test_23_planning_audit_contract.sh "$snapshot_root/bubbles/tests/regression/test_23_planning_audit_contract.sh" && git -C "$snapshot_root/bubbles" add BUGS.md bubbles/schemas/workflows.schema.json bubbles/scripts/framework-validate.sh bubbles/workflows/modes.yaml bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/transition-contract-resolver-selftest.sh tests/regression/test_23_planning_audit_contract.sh && git -C "$snapshot_root/bubbles" -c user.name='Bubbles Validation' -c user.email='validation@invalid' commit --quiet -m 'BUG-009 S01-S02 final validation snapshot' && set +e; (cd "$snapshot_root/bubbles" && bash tests/regression/test_23_planning_audit_contract.sh); regression_exit=$?; set -e; printf 'BUG-009 S01 final clean-snapshot observed exit=%s expected=1\n' "$regression_exit"; rm -rf "$snapshot_root"; [[ "$regression_exit" -eq 1 ]]`
**Exit Code:** 0 (wrapper); inner S01 regression exit code: 1
**Output:**

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: integrity adversary 'done-status' is rejected
PASS: integrity adversary 'checked-dod' is rejected
PASS: fixture passes artifact lint with real required fields and artifacts
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the state-transition guard blocking verdict
PASS: product-to-planning registry contract does not require G060 or force scenario-first TDD
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: direct path records the canonical production invocation
PASS: Audit path records the canonical production invocation
PASS: Check-4-completion is unconditionally blocking
PASS: Check-5-all-done is unconditionally blocking
PASS: Check-8-file-existence is unconditionally blocking
PASS: Check-11-execution-evidence is unconditionally blocking
PASS: G040 planning integrity is clean
PASS: G056 certification scopeProgress is structurally complete
PASS: G060 correctly follows the planning-only TDD policy without fabricated evidence
PASS: Check 8A scenario-specific regression DoD is planned
PASS: Check 8A broader regression DoD is planned
PASS: Check 8A regression Test Plan row is planned
PASS: G068 planning traceability is clean
PASS: G091 uses the canonical hermetic-fixture posture
PASS: G087 uses the canonical hermetic-fixture posture
PASS: G093 uses the canonical hermetic-fixture posture
PASS: G082 uses the canonical hermetic-fixture posture
PASS: G090 uses the canonical hermetic-fixture posture
PASS: artifact lint is clean for the fixture
PASS: G094 capability foundation is clean
PASS: G095 disposition is clean
PASS: G097 mechanism correspondence is clean
PASS: guard blockers are confined to Check 4/5/8/11
--- BUG-009 S01 canonical RED discriminator ---
--- Check 4: DoD Completion (Zero Unchecked) ---
🔴 BLOCK: Resolved scope artifacts have 3 UNCHECKED DoD items — ALL must be [x] for 'done'
--- Check 5: Scope Status Cross-Reference ---
🔴 BLOCK: Resolved scope artifacts have 1 scope(s) still marked 'Not Started' — ALL scopes must be Done
✅ PASS: completedScopes count matches artifact Done scope count (0)
--- Check 8: Test File Existence ---
🔴 BLOCK: Test Plan references non-existent file: /var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-bug009-s01-final.qywrc9/bubbles/tests/fixtures/bubbles-bug009-s01-4twluJDp/909-bug009-planning-audit-contract/tests/regression/planning_contract_future_test.sh
🔴 BLOCK: Test Plan references non-existent file: /var/folders/m_/25mnb8mx4ng1sb7lwd8cl9jw0000gn/T/bubbles-bug009-s01-final.qywrc9/bubbles/tests/fixtures/bubbles-bug009-s01-4twluJDp/909-bug009-planning-audit-contract/tests/regression/planning_contract_future_test.sh
🔴 BLOCK: 2 of 2 test files from Test Plan DO NOT EXIST
--- Check 11: Report.md Required Sections ---
✅ PASS: report.md has required report section
✅ PASS: report.md has required report section
✅ PASS: report.md has required report section
🔴 BLOCK: report.md has ZERO evidence code blocks — no execution evidence exists
✅ PASS: No narrative summary phrases detected outside code blocks in report.md
🔴 TRANSITION BLOCKED: 6 failure(s), 2 warning(s)
DIRECT_GUARD_EXIT=1
AUDIT_0_PRE_A1_EXIT=1
RED_REGRESSION_VERDICT=EXPECTED_PRE_FIX_COMPLETION_FAILURE
test_23_planning_audit_contract: 34 integrity/discriminator assertions passed; intentional RED exit follows
BUG-009 S01 final clean-snapshot observed exit=1 expected=1
```

**Result:** PASS for the S02 checkpoint: S01 remains intentionally RED with the
exact pre-S03 completion discriminator. This is not a green regression claim.

##### BUG-009 S02 Closeout Revalidation Evidence

**Phase:** implement
**Claim Source:** executed
**Executed:** YES (current session)
**Command:** `printf '%s\n' 'BUG-009 S02 closeout validation' 'CHECK: shell syntax' && bash -n bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/transition-contract-resolver-selftest.sh bubbles/scripts/framework-validate.sh && printf '%s\n' 'PASS: shell syntax' 'CHECK: shellcheck' && shellcheck -x bubbles/scripts/transition-contract-resolver.sh bubbles/scripts/transition-contract-resolver-selftest.sh && printf '%s\n' 'PASS: shellcheck' 'CHECK: mode registry' && bash bubbles/scripts/mode-resolver.sh --validate && bash bubbles/scripts/workflow-registry-consistency.sh --quiet && printf '%s\n' 'PASS: mode registry and consistency' 'CHECK: agnosticity' && bash bubbles/scripts/cli.sh agnosticity && printf '%s\n' 'PASS: agnosticity' 'CHECK: git diff' && git diff --check && printf '%s\n' 'PASS: git diff' 'BUG-009 S02 closeout validation: PASS'`
**Exit Code:** 0
**Output:**

```text
BUG-009 S02 closeout validation
CHECK: shell syntax
PASS: shell syntax
CHECK: shellcheck
PASS: shellcheck
CHECK: mode registry
Validation passed: all templates and modes resolve cleanly with no inherits cycles.
PASS: mode registry and consistency
CHECK: agnosticity
ℹ️  Scanning 452 portable file(s) for agnosticity drift
✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
PASS: agnosticity
CHECK: git diff
PASS: git diff
BUG-009 S02 closeout validation: PASS
```

**Result:** PASS. The focused syntax, shellcheck, registry consistency,
agnosticity, and repository-wide diff checks remain green after the terminal
S01 canary. The standalone `yaml-schema-validate.sh` invocation returned its
documented exit-0 `SKIP` because its optional Python PyYAML/jsonschema modules
were unavailable; schema behavior is instead execution-proven above by the
resolver selftest's successful canonical validation plus three rejecting
mutations and by the focused closed-shape assertion.

**Full framework validation:** **Claim Source:** not-run. It is deliberately not
claimed green in S02 because `framework-validate` registers the still-red S01
regression; guard profile activation belongs to S03.

**S02 disposition:** terminal `route_required`; S02 is Done with executed focused
evidence. S03 remains Not Started and no guard, audit/validate/finalize agent,
documentation, version, installer, release, or downstream product surface was
changed.

#### S03 — Guard Profile Activation

- **Status:** Done — final focused A-F validation passes; S04 closeout is recorded below
- **Primary owner:** `bubbles.implement`
- **Depends on:** S02
**Change boundary:** `bubbles/scripts/state-transition-guard.sh`,
`bubbles/scripts/guards/planning-checks.sh`, and
`bubbles/scripts/state-transition-guard-selftest.sh`.

**Gherkin — Acceptance Scenarios A-F:**

```gherkin
Given the resolver returns planning-maturity-v1 for an honest unimplemented planning packet
When the existing guard evaluates the derived target
Then universal, mode-required, planning, and honesty checks remain active
And only the completion portions of Checks 4, 5, 8, and 11 are NOT_APPLICABLE

Given the same packet is evaluated under delivery-completion-v1
When the guard runs
Then Checks 4, 5, 8, and 11 fail and no delivery check is reported NOT_APPLICABLE

Given a planning packet breaks G068, G087, G091, G073, checked-item evidence, or a truthful status invariant
When the planning guard runs
Then the named real violation blocks even though incomplete delivery facts are non-applicable
```

**Implementation steps:**

1. Replace Check 3's local ceiling/profile inference with one resolver call and
  assertion forwarding; retain legacy one-argument and `--revert-on-fail`
  behavior.
2. Split structural/integrity work from completion requirements inside Checks
  4, 5, 8, and 11; do not skip whole numbered checks.
3. Keep Check 4A/4B, 5B/5C, 8A-8D, Check 9 evidence honesty, G073, ownership,
  freshness, and every applicable universal/mode-required gate active.
4. Append exactly one ordered `TRANSITION_GUARD_RESULT_V1` block on PASS, FAIL,
  or BLOCKED, with no success inference from a missing block.
5. Replace the completion-shaped planning fixture as primary proof while
  retaining it as a compatibility control.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| A/B | Unit / shell selftest | `bubbles/scripts/state-transition-guard-selftest.sh` | Both honest planning modes exit zero with explicit completion sub-checks NOT_APPLICABLE | `bash bubbles/scripts/state-transition-guard-selftest.sh` |
| F | Regression negative | same | Done semantics exit nonzero on all four completion sub-checks and contain no planning exemption | `bash bubbles/scripts/state-transition-guard-selftest.sh` |
| C/D/E | Functional negative | same | One-fact mutations fail the exact planning/universal obligation, including false Done/checked claims | `bash bubbles/scripts/cli.sh framework-validate` |
| Result contract | Integration | same | Parsed guard block agrees with resolver mode, profile, target, digest, revision, gate IDs, and exit code | `bash bubbles/scripts/cli.sh framework-validate` |

**Definition of Done:**

- [x] Planning success requires all applicable planning/universal checks and never derives from broad check skipping. Evidence: [S03 planning profile evidence](#bug-009-s03-planning-profile-evidence).
- [x] Delivery completion behavior for Checks 4/5/8/9/11 is unchanged and the honest planning fixture remains a delivery negative control. Evidence: [S03 delivery negative-control evidence](#bug-009-s03-delivery-negative-control-evidence).
- [x] G068, G087, G091, G073, metadata, status, and checked-evidence adversaries fail on actual behavior. Evidence: [S03 adversary evidence](#bug-009-s03-adversary-evidence).
- [x] Legacy guard invocation and delivery-only `--revert-on-fail` compatibility pass. Evidence: [S03 compatibility evidence](#bug-009-s03-compatibility-evidence).
- [x] `TRANSITION_GUARD_RESULT_V1` is complete, ordered, parseable, and consistent on exits 0, 1, and 2. Evidence: [S03 result-contract evidence](#bug-009-s03-result-contract-evidence).
- [x] No file outside the user-authorized S03 execution boundary changed. Evidence: [S03 change-boundary evidence](#bug-009-s03-change-boundary-evidence).

##### BUG-009 S03 Planning Profile Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
Running BUG-009 S03 guard profile activation matrix...
PASS: BUG-009 S03: honest product-to-planning packet passes via legacy one-argument invocation
PASS: BUG-009 S03: planning success emits one complete ordered transition result
PASS: BUG-009 S03: unchecked implementation DoD is explicitly non-applicable
PASS: BUG-009 S03: incomplete implementation scopes are explicitly non-applicable
PASS: BUG-009 S03: future test file presence is explicitly non-applicable
PASS: BUG-009 S03: honest unimplemented reports need no delivery evidence block
PASS: BUG-009 S03: Check 4A remains active under planning
PASS: BUG-009 S03: Check 4B remains active under planning
PASS: BUG-009 S03: Check 5B remains active under planning
PASS: BUG-009 S03: Check 5C remains active under planning
PASS: BUG-009 S03: Check 8A remains active under planning
PASS: BUG-009 S03: Check 8B remains active under planning
PASS: BUG-009 S03: Check 8C remains active under planning
PASS: BUG-009 S03: Check 8D remains active under planning
PASS: BUG-009 S03: checked-item evidence audit remains active under planning
PASS: BUG-009 S03: G073 remains active and clean
PASS: BUG-009 S03: G068 remains active and clean
PASS: BUG-009 S03: honest spec-scope-hardening packet passes
PASS: BUG-009 S03: both designed planning modes share the same explicit profile contract
```

**Result:** PASS — both explicit planning modes pass only after all applicable
universal/planning checks execute; the four delivery-completion sub-checks are
reported `NOT_APPLICABLE`, not passed or omitted.

##### BUG-009 S03 Delivery Negative-Control Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: BUG-009 S03: the honest incomplete packet fails under done-ceiling delivery semantics
PASS: BUG-009 S03: delivery Check 4 completion remains blocking
PASS: BUG-009 S03: delivery Check 5 all-Done remains blocking
PASS: BUG-009 S03: delivery Check 8 file existence remains blocking
PASS: BUG-009 S03: delivery Check 11 execution evidence remains blocking
PASS: BUG-009 S03: delivery mode receives no planning exemption
PASS: BUG-009 S03: done-mode negative control emits one complete delivery failure result
PASS: BUG-009 S03: delivery Check 9 checked-item evidence remains blocking
PASS: BUG-009 S03: checked planning DoD without evidence fails
PASS: BUG-009 S03: Check 9 honesty remains universal
PASS: BUG-009 S03: planning honesty failure retains explicit non-applicable delivery checks
PASS: BUG-009 S03: falsely Done planning scope fails
PASS: BUG-009 S03: planning status honesty remains blocking
```

**Result:** PASS — the same incomplete packet remains a real negative control
under `delivery-completion-v1`; no delivery check is reported non-applicable.

##### BUG-009 S03 Adversary Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: BUG-009 S03: broken Gherkin-to-DoD fidelity fails planning guard
PASS: BUG-009 S03: G068 failure is visible and not hidden by delivery non-applicability
PASS: BUG-009 S03: G068 is machine-readable in the result ledger
PASS: BUG-009 S03: G073 source-edit adversary blocks planning guard
PASS: BUG-009 S03: G073 reports the concrete source edit
PASS: BUG-009 S03: G073 maps to the source-lockout blocking code
PASS: BUG-009 S03: G087 linkage adversary blocks the real planning guard
PASS: BUG-009 S03: G087 remains active under planning profile
PASS: BUG-009 S03: G087 failure is machine-readable
PASS: BUG-009 S03: G091 chain adversary blocks the real planning guard
PASS: BUG-009 S03: G091 remains active under planning profile
PASS: BUG-009 S03: G091 failure is machine-readable
PASS: Contradictory workflow metadata fails loud through the S02 contract
PASS: Contradictory workflow metadata emits a blocked transition result
PASS: Planning-only mode blocks done status through the registry-derived contract
PASS: Planning done contradiction is machine-readable
```

**Result:** PASS — planning-gate, source-lockout, checked-evidence, false-status,
and metadata adversaries remain blocking through real production paths.

##### BUG-009 S03 Compatibility Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: BUG-009 S03: honest product-to-planning packet passes via legacy one-argument invocation
PASS: BUG-009 S03: matching target, mode, and digest assertions preserve the derived planning contract
PASS: BUG-009 S03: assertion flags cannot replace the registry-derived digest
PASS: BUG-009 S03: assertion-only invocation emits the same result contract
PASS: BUG-009 S03: guard resolves the transition contract exactly once per invocation
PASS: BUG-009 S03: --revert-on-fail does not rewrite planning state
PASS: BUG-009 S03: planning reversion refusal is explicit
PASS: BUG-009 S03: delivery --revert-on-fail retains its state rollback behavior
PASS: BUG-006: fixture with a header '> **Status:** …' summary blockquote still passes the transition guard
PASS: BUG-006: real plain scope statuses still validated as canonical
PASS: Check 6/6B: dict-shaped completedPhaseClaims does NOT crash the guard with a Python Traceback
PASS: Check 8 extracts the .sh path token from a command-wrapped Test Plan cell
```

**Result:** PASS — legacy invocation, assertion-only flags, exact-once resolver
use, prior guard regressions, and delivery-only state reversion all remain valid.

##### BUG-009 S03 Result-Contract Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/state-transition-guard-selftest.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: BUG-009 S03: planning success emits one complete ordered transition result
PASS: BUG-009 S03: assertion-only invocation emits the same result contract
PASS: BUG-009 S03: mismatched target assertion blocks with guard exit 2
PASS: BUG-009 S03: target assertion mismatch preserves S02 E009 semantics
PASS: BUG-009 S03: target mismatch emits one complete blocked result
PASS: BUG-009 S03: stale digest assertion blocks with guard exit 2
PASS: BUG-009 S03: stale digest mismatch preserves S02 E009 semantics
PASS: BUG-009 S03: digest mismatch cannot omit or malform the blocked result
PASS: BUG-009 S03: caller-selected profile syntax is rejected
PASS: BUG-009 S03: policy-selecting flags fail loud
PASS: BUG-009 S03: rejected profile syntax still emits the mandatory blocked result
PASS: BUG-009 S03: done-mode negative control emits one complete delivery failure result
```

**Result:** PASS — the parser accepts exactly one ordered V1 block on PASS,
FAIL, and BLOCKED outcomes and checks mode, profile, target, digest, revision,
lists, failure count, blocking code, verdict, and exit status.

##### BUG-009 S03 S01 Red-To-Green Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_23_planning_audit_contract.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: integrity adversary 'done-status' is rejected
PASS: integrity adversary 'checked-dod' is rejected
PASS: fixture passes artifact lint with real required fields and artifacts
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the state-transition guard blocking verdict
PASS: product-to-planning registry contract does not require G060 or force scenario-first TDD
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: direct path records the canonical production invocation
PASS: Audit path records the canonical production invocation
PASS: planning guard no longer requires completed implementation DoD
PASS: planning guard no longer requires Done implementation scopes
PASS: planning guard accepts absent future implementation tests
PASS: planning guard accepts honest zero-evidence reports
GREEN_REGRESSION_VERDICT=PLANNING_AUDIT_CONTRACT_SATISFIED
DIRECT_GUARD_EXIT=0
AUDIT_0_PRE_A1_EXIT=0
test_23_planning_audit_contract: 17 passed, 0 failed
```

**Result:** PASS — S01 changes from intentional red to green because the real
production guard changed; the fixture remains honestly unimplemented and all
four fabrication adversaries remain active.

##### BUG-009 S03 Resolver And Quality Evidence

**Phase:** `implement`

**Commands:**

```text
cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/transition-contract-resolver-selftest.sh
cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh
cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/cli.sh agnosticity
```

**Exit Codes:** 0, 0, 0

**Claim Source:** executed

```text
PASS: missing designated planning profile returns E009-AUDIT-PROFILE-MISSING with exit 70 and empty stdout
PASS: unsupported adjacent non-done mode returns E009-AUDIT-PROFILE-UNSUPPORTED with exit 71 and empty stdout
PASS: unknown explicit profile returns E009-AUDIT-PROFILE-UNSUPPORTED with exit 71 and empty stdout
PASS: malformed transition audit metadata returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: every audit-bearing done mode has an explicit delivery binding
PASS: exactly the two designed planning modes have planning bindings
PASS: all 27 audit-bearing done modes resolve through explicit delivery contracts
PASS: all 22 adjacent non-done audit modes fail unsupported through the real resolver
== transition contract resolver selftest summary ==
passes=56
failures=0
skips=0
transition-contract-resolver-selftest: PASS
REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
Files scanned: 1
Files with adversarial signals: 1
ℹ️  Scanning 452 portable file(s) for agnosticity drift
✅ Portable Bubbles surfaces are project-agnostic and tool-agnostic
```

**Result:** PASS — S02 compatibility remains 56/56, the regression remains
adversarial, and the final shell changes execute cleanly on the current macOS
host while all 452 portable surfaces pass agnosticity. No Linux runtime or full
`framework-validate` execution is claimed in S03.

##### BUG-009 S03 Change-Boundary Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'S03_ALLOWED_STATUS_BEGIN' && git status --short -- BUGS.md bubbles/scripts/state-transition-guard.sh bubbles/scripts/guards/planning-checks.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_23_planning_audit_contract.sh && printf '%s\n' 'S03_ALLOWED_STATUS_END' && bash -n bubbles/scripts/state-transition-guard.sh && printf '%s\n' 'GUARD_BASH_SYNTAX_EXIT=0' && bash -n bubbles/scripts/state-transition-guard-selftest.sh && printf '%s\n' 'SELFTEST_BASH_SYNTAX_EXIT=0' && bash -n tests/regression/test_23_planning_audit_contract.sh && printf '%s\n' 'REGRESSION_BASH_SYNTAX_EXIT=0' && git diff --check -- bubbles/scripts/state-transition-guard.sh bubbles/scripts/state-transition-guard-selftest.sh tests/regression/test_23_planning_audit_contract.sh && printf '%s\n' 'S03_DIFF_CHECK_EXIT=0'`

**Exit Code:** 0

**Claim Source:** executed

```text
S03_ALLOWED_STATUS_BEGIN
 M BUGS.md
 M bubbles/scripts/state-transition-guard-selftest.sh
 M bubbles/scripts/state-transition-guard.sh
?? tests/regression/test_23_planning_audit_contract.sh
S03_ALLOWED_STATUS_END
GUARD_BASH_SYNTAX_EXIT=0
SELFTEST_BASH_SYNTAX_EXIT=0
REGRESSION_BASH_SYNTAX_EXIT=0
S03_DIFF_CHECK_EXIT=0
```

**Result:** PASS — S03 changed the canonical guard, its selftest, the planned
S01 red-to-green regression transition, and this BUGS.md execution record only.
`guards/planning-checks.sh` required no edit. Existing unrelated user work is
not included in or relied upon by this evidence.

**Full framework validation:** **Claim Source:** not-run. Per the requested S03
slice, the narrow A-F sequence was sufficient and did not require a broad run to
disambiguate a failure.

**S03 disposition:** terminal `completed_owned`; S03 is Done with no unresolved
S03 findings. Its next required owner was `bubbles.implement` for S04; the S04
closeout is recorded below.

#### S04 — Audit Result Contract And Attempt Semantics

- **Status:** Done — current-session contract selftest passes 22/22 and the
  persistent real-path regression passes 24/24; S05 remains Not Started
- **Primary owner:** `bubbles.implement`
- **Depends on:** S03
**Change boundary:** new `bubbles/scripts/audit-result-contract-lint.sh`, new
`bubbles/scripts/audit-result-contract-lint-selftest.sh`,
`agents/bubbles.audit.agent.md`, and
`agents/bubbles_shared/validation-profiles.md` Audit A1-A6 wording/applicability.

**Gherkin — Acceptance Scenarios C/L and interruption/rework:**

```gherkin
Given a profile-scoped guard result and matching active audit attempt
When Audit 0-pre and A1 evaluate and persist the attempt
Then planning emits PLANNING_AUDIT_CLEAN or PLANNING_REWORK_REQUIRED while delivery keeps its existing verdict tokens
And exactly one ordered AUDIT_RESULT_V1 block agrees with persisted evidence

Given an audit is interrupted, superseded, stale, duplicated, malformed, or loses a prior finding
When the result contract is linted
Then no active positive verdict survives and the exact provenance or schema failure is reported

Given a planning result contains shipment language or reports a non-applicable delivery check as passed
When result lint evaluates it
Then the result is rejected rather than normalized or silently accepted
```

**Implementation steps:**

1. Make Audit 0-pre invoke the transition-aware guard with assertion-only mode,
  target, and digest inputs; make A1 mean profile-scoped guard success.
2. Preserve A2-A6 where applicable and render every delivery completion
  sub-check as explicit `NOT_APPLICABLE`, never PASS or omission.
3. Implement the six-phase attempt lifecycle, one ACTIVE record invariant,
  supersede-before-open behavior, interruption state, and one-to-one finding
  accounting under `execution.audit`.
4. Parse and validate the frozen V1 field order and enum combinations for both
  result files and the canonical audit-agent contract.
5. Cover all five canonical UX views, plain/no-color and narrow output,
  interruption, resume, and rework without adding a second renderer truth.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| L and five views | Unit / shell selftest | `bubbles/scripts/audit-result-contract-lint-selftest.sh` | Parser validates exact fields/order/evaluation pairs and rejects delivery wording in planning output | `bash bubbles/scripts/audit-result-contract-lint-selftest.sh` |
| C | Integration | `tests/regression/test_23_planning_audit_contract.sh` | Real Audit 0-pre/A1 consumes the guard failure and routes the named planning gate without delivery noise | `bash bubbles/scripts/cli.sh framework-validate` |
| Resume/rework | Functional negative | lint selftest | Multiple ACTIVE, dangling/stale pointer, disappearing finding, duplicate block, stale digest, and malformed field cases fail | `bash bubbles/scripts/cli.sh framework-validate` |

**Definition of Done:**

- [x] Audit 0-pre/A1 consume the real guard result and cannot select a profile independently. Evidence: [S04 persistent audit-path regression evidence](#bug-009-s04-persistent-audit-path-regression-evidence).
- [x] Planning and delivery verdict vocabularies remain disjoint; existing delivery refusal/ship semantics are unchanged. Evidence: [S04 audit result contract selftest evidence](#bug-009-s04-audit-result-contract-selftest-evidence) and [S04 persistent audit-path regression evidence](#bug-009-s04-persistent-audit-path-regression-evidence).
- [x] `AUDIT_RESULT_V1` is frozen, exact, single-source, and consistent with the persisted attempt and finding arrays. Evidence: [S04 audit result contract selftest evidence](#bug-009-s04-audit-result-contract-selftest-evidence).
- [x] Interruption/rework never leaves a prior result current and every prior finding remains addressed or unresolved one-to-one. Evidence: [S04 audit result contract selftest evidence](#bug-009-s04-audit-result-contract-selftest-evidence).
- [x] Result and agent-contract lint tests validate parsed behavior, not token presence alone. Evidence: [S04 audit result contract selftest evidence](#bug-009-s04-audit-result-contract-selftest-evidence) and [S04 persistent audit-path regression evidence](#bug-009-s04-persistent-audit-path-regression-evidence).
- [x] No file outside the S04 change boundary changed. Evidence: [S04 change-boundary and diff-check evidence](#bug-009-s04-change-boundary-and-diff-check-evidence).

##### BUG-009 S04 Audit Result Contract Selftest Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/audit-result-contract-lint-selftest.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
Running BUG-009 S04 audit result contract selftest...
PASS: planning clean view is exact and profile-bound
PASS: planning rework view names a concrete owner
PASS: delivery refusal preserves DO_NOT_SHIP semantics
PASS: metadata uncertainty is BLOCKED without fallback semantics
PASS: source-edit lockout is BLOCKED on G073
PASS: interruption leaves no current pointer or active verdict
PASS: rework supersedes prior result and preserves the finding one-to-one
PASS: duplicate AUDIT_RESULT_V1 block is rejected
PASS: missing frozen field is rejected
PASS: reordered frozen fields are rejected
PASS: malformed collection is rejected
PASS: planning shipment language is rejected
PASS: planning PASS claim for non-applicable delivery check is rejected
PASS: stale contract digest is rejected against guard provenance
PASS: stale target revision is rejected against guard provenance
PASS: delivery verdict drift is rejected
PASS: ANSI/color output is rejected
PASS: multiple ACTIVE attempts are rejected
PASS: dangling currentAttemptId is rejected
PASS: disappearing prior finding is rejected
PASS: canonical audit agent passes structural contract lint
PASS: Audit A1 wording is profile-scoped and registry-resolved
audit-result-contract-lint-selftest: 22 passed, 0 failed
```

**Result:** PASS — all 22 positive, malformed, provenance, presentation,
attempt-lifecycle, finding-accounting, canonical-agent, and A1 assertions pass
against the production lint and current contracts.

##### BUG-009 S04 Persistent Audit-Path Regression Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_23_planning_audit_contract.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: integrity adversary 'done-status' is rejected
PASS: integrity adversary 'checked-dod' is rejected
PASS: fixture passes artifact lint with real required fields and artifacts
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the profile-scoped state-transition guard verdict
PASS: product-to-planning registry contract does not require G060 or force scenario-first TDD
PASS: Audit 0-pre independently resolves the transition contract
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: direct path records the canonical production invocation
PASS: Audit path records the canonical production invocation
PASS: Audit path records target, mode, and digest assertions
PASS: planning guard no longer requires completed implementation DoD
PASS: planning guard no longer requires Done implementation scopes
PASS: planning guard accepts absent future implementation tests
PASS: planning guard accepts honest zero-evidence reports
PASS: real Audit 0-pre result and persisted attempt pass the S04 contract lint
PASS: planning audit transcript contains no delivery or shipment approval language
PASS: copied result block without real guard evidence is rejected
PASS: stale audit digest is rejected against the real guard result
PASS: planning shipment verdict is rejected by the real audit contract
GREEN_REGRESSION_VERDICT=PLANNING_AUDIT_CONTRACT_SATISFIED
DIRECT_GUARD_EXIT=0
AUDIT_0_PRE_A1_EXIT=0
AUDIT_RESULT_LINT_EXIT=0
test_23_planning_audit_contract: 24 passed, 0 failed
```

**Result:** PASS — the persistent regression executes the canonical resolver,
production guard, Audit 0-pre/A1 path, persisted attempt, and S04 result lint;
all four observed exit markers are zero and the honesty adversaries remain
blocking.

##### BUG-009 S04 Change-Boundary And Diff-Check Evidence

**Phase:** `implement`

**Commands:**

```text
cd /Users/pkirsanov/Projects/bubbles && git diff --check -- BUGS.md agents/bubbles.audit.agent.md agents/bubbles_shared/validation-profiles.md bubbles/scripts/audit-result-contract-lint.sh bubbles/scripts/audit-result-contract-lint-selftest.sh tests/regression/test_23_planning_audit_contract.sh
cd /Users/pkirsanov/Projects/bubbles && printf '%s\n' 'S04_CURRENT_SESSION_UNSTAGED_BEGIN' && git diff --name-only && printf '%s\n' 'S04_CURRENT_SESSION_UNSTAGED_END' 'S04_AUTHORIZED_STATUS_BEGIN' && git status --short -- BUGS.md agents/bubbles.audit.agent.md agents/bubbles_shared/validation-profiles.md bubbles/scripts/audit-result-contract-lint.sh bubbles/scripts/audit-result-contract-lint-selftest.sh tests/regression/test_23_planning_audit_contract.sh && printf '%s\n' 'S04_AUTHORIZED_STATUS_END' && git diff --cached --check -- BUGS.md agents/bubbles.audit.agent.md agents/bubbles_shared/validation-profiles.md bubbles/scripts/audit-result-contract-lint.sh bubbles/scripts/audit-result-contract-lint-selftest.sh tests/regression/test_23_planning_audit_contract.sh && printf '%s\n' 'S04_CACHED_DIFF_CHECK_EXIT=0' && git diff --check -- BUGS.md agents/bubbles.audit.agent.md agents/bubbles_shared/validation-profiles.md bubbles/scripts/audit-result-contract-lint.sh bubbles/scripts/audit-result-contract-lint-selftest.sh tests/regression/test_23_planning_audit_contract.sh && printf '%s\n' 'S04_WORKTREE_DIFF_CHECK_EXIT=0'
```

**Exit Codes:** 0, 0

**Claim Source:** executed

The exact required closeout command emitted no stdout or stderr. The boundary
snapshot emitted:

```text
S04_CURRENT_SESSION_UNSTAGED_BEGIN
BUGS.md
bubbles/scripts/trust-doctor-selftest.sh
S04_CURRENT_SESSION_UNSTAGED_END
S04_AUTHORIZED_STATUS_BEGIN
MM BUGS.md
M  agents/bubbles.audit.agent.md
M  agents/bubbles_shared/validation-profiles.md
A  bubbles/scripts/audit-result-contract-lint-selftest.sh
A  bubbles/scripts/audit-result-contract-lint.sh
A  tests/regression/test_23_planning_audit_contract.sh
S04_AUTHORIZED_STATUS_END
S04_CACHED_DIFF_CHECK_EXIT=0
S04_WORKTREE_DIFF_CHECK_EXIT=0
```

**Result:** PASS — the authorized S04 set is exactly the two audit-result
scripts, audit agent, shared validation profile, persistent regression, and
this BUGS.md execution record; both staged and unstaged diffs pass whitespace
validation. The initial current-session baseline did not list
`bubbles/scripts/trust-doctor-selftest.sh`; that separate concurrent reorder
appeared later, was inspected read-only, and remains unmodified and excluded
from S04.

**Full framework validation:** **Claim Source:** not-run. S04 closeout claims
only its planned narrow contract selftest, persistent regression, and diff
checks; framework-wide validation remains in S06.

**S04 disposition:** terminal `route_required`; S04 was Done with no unresolved
S04 findings. At S04 closeout, S05 was Not Started and the next required owner
was `bubbles.implement`; the successor execution is recorded below.

#### S05 — Validate And Finalize Coherence

- **Status:** Done — current-session cross-boundary regression passes 48/48;
  resolver, audit-result, guard-compatibility, regression-quality,
  agnosticity, and scoped diff checks pass; S06 remains Not Started
- **Primary owner:** `bubbles.implement`
- **Depends on:** S04
**Change boundary:** `agents/bubbles.validate.agent.md` Step 2.11 and terminal
transition flow, `agents/bubbles_shared/scope-workflow.md` finalize contract,
`agents/bubbles_shared/workflow-phase-engine.md`,
`agents/bubbles_shared/feature-templates.md`, and
`agents/bubbles_shared/scope-templates.md` additive audit-evidence shape.

**Gherkin — Acceptance Scenarios A, J, and K:**

```gherkin
Given validate, audit, and finalize receive the same runner assertions
When each boundary independently resolves the contract and current target revision
Then only one matching ACTIVE planning result can authorize validate to certify specs_hardened
And scope status, DoD, completedScopes, and delivery evaluation remain unchanged

Given the audit result is stale, incomplete, duplicated, points to a different digest or revision, or certifies beyond the ceiling
When finalize requests the transition
Then certification is blocked with no fallback result and no state rewrite beyond audit-owned history
```

**Implementation steps:**

1. Re-resolve at validate and finalize boundaries and compare mode, target,
  digest, revision, attempt ID, result state, verdict, and finding accounting.
2. Prevent pre-audit validation from certifying when audit remains in the mode's
  phase order.
3. Permit validate alone to mirror top-level and `certification.status` to
  `specs_hardened` after a matching clean planning audit; leave execution
  scope state untouched.
4. Preserve the existing all-scopes-Done delivery finalization path.
5. Document `execution.audit` as additive evidence in both templates without
  making it configuration or pre-populating a positive attempt.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| A | Integration | `tests/regression/test_23_planning_audit_contract.sh` | Real validate -> audit -> finalize composition certifies only `specs_hardened` and preserves incomplete delivery state | `bash bubbles/scripts/cli.sh framework-validate` |
| J/K | Integration negative | same | Unknown, mismatch, stale, multiple-ACTIVE, dangling, incomplete, and over-ceiling attempts block without mutation | `bash bubbles/scripts/cli.sh framework-validate` |
| Delivery canary | Functional | existing guard/finalize selftests | Existing done transition still requires completed scopes, DoD, files, and evidence | `bash bubbles/scripts/cli.sh framework-validate` |

**Definition of Done:**

- [x] Runner, validate, audit, and finalize prove contract/digest/revision equality independently. Evidence: [S05 cross-boundary regression evidence](#bug-009-s05-cross-boundary-regression-evidence) and [S05 resolver and audit contract evidence](#bug-009-s05-resolver-and-audit-contract-evidence).
- [x] Only validate writes `certification.*` and the terminal status mirror. Evidence: [S05 cross-boundary regression evidence](#bug-009-s05-cross-boundary-regression-evidence).
- [x] Planning finalization changes only the exact planning status and leaves all delivery facts honestly incomplete. Evidence: [S05 cross-boundary regression evidence](#bug-009-s05-cross-boundary-regression-evidence).
- [x] Stale, contradictory, incomplete, duplicate, or over-ceiling results block with no guessed profile or prior-result reuse. Evidence: [S05 cross-boundary regression evidence](#bug-009-s05-cross-boundary-regression-evidence) and [S05 resolver and audit contract evidence](#bug-009-s05-resolver-and-audit-contract-evidence).
- [x] Delivery finalization and anti-fabrication remain behaviorally unchanged. Evidence: [S05 cross-boundary regression evidence](#bug-009-s05-cross-boundary-regression-evidence).
- [x] No file outside the S05 change boundary changed. Evidence: [S05 static, agnosticity, and change-boundary evidence](#bug-009-s05-static-agnosticity-and-change-boundary-evidence).

##### BUG-009 S05 Cross-Boundary Regression Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash tests/regression/test_23_planning_audit_contract.sh`

**Exit Code:** 0

**Claim Source:** executed

```text
PASS: fixture is honestly unimplemented
PASS: integrity adversary 'fake-test' is rejected
PASS: integrity adversary 'fake-evidence' is rejected
PASS: integrity adversary 'done-status' is rejected
PASS: integrity adversary 'checked-dod' is rejected
PASS: fixture passes artifact lint with real required fields and artifacts
PASS: bypassing the production invocation is rejected
PASS: Audit 0-pre resolves the canonical transition guard path
PASS: Audit A1 consumes the profile-scoped state-transition guard verdict
PASS: validate exposes the registry-bound audit certification boundary
PASS: pre-audit validation cannot certify the planning ceiling
PASS: validate owns the exact planning status mirror
PASS: scope workflow exposes the registry-bound finalize boundary
PASS: workflow phase engine independently binds finalization
PASS: finalize delegates the terminal write to validate alone
PASS: feature template initializes a neutral audit evidence pointer
PASS: feature template initializes no audit attempts
PASS: feature template does not pre-populate a positive planning result
PASS: scope template initializes a neutral audit evidence pointer
PASS: scope template initializes no audit attempts
PASS: scope template does not pre-populate a positive planning result
PASS: product-to-planning registry contract does not require G060 or force scenario-first TDD
PASS: Audit 0-pre independently resolves the transition contract
PASS: direct and Audit 0-pre/A1 paths each executed the production guard
PASS: direct path records the canonical production invocation
PASS: Audit path records the canonical production invocation
PASS: Audit path records target, mode, and digest assertions
PASS: pre-audit resolver and guard checks do not certify the ceiling
PASS: planning guard no longer requires completed implementation DoD
PASS: planning guard no longer requires Done implementation scopes
PASS: planning guard accepts absent future implementation tests
PASS: planning guard accepts honest zero-evidence reports
PASS: real Audit 0-pre result and persisted attempt pass the S04 contract lint
PASS: audit evidence alone does not certify or complete planning delivery state
PASS: clean planning certification changes only both status mirrors to specs_hardened
PASS: planning audit transcript contains no delivery or shipment approval language
PASS: copied result block without real guard evidence is rejected
PASS: stale audit digest is rejected against the real guard result
PASS: stale audit revision is rejected at certification
PASS: audit mode mismatch is rejected at certification
PASS: over-ceiling planning certification is rejected
PASS: multiple ACTIVE planning attempts block certification
PASS: dangling current audit pointer blocks certification
PASS: INCOMPLETE clean planning attempt cannot certify
PASS: missing audit evidence reference blocks certification
PASS: disappearing prior finding blocks certification
PASS: planning shipment verdict is rejected by the real audit contract
PASS: done-ceiling delivery path still strictly requires DoD, Done scopes, test files, and evidence
GREEN_REGRESSION_VERDICT=PLANNING_AUDIT_CONTRACT_SATISFIED
DIRECT_GUARD_EXIT=0
AUDIT_0_PRE_A1_EXIT=0
AUDIT_RESULT_LINT_EXIT=0
test_23_planning_audit_contract: 48 passed, 0 failed
```

**Result:** PASS — validate and finalize independently bind the fresh contract
and current audit evidence; pre-audit checks do not certify; planning promotion
changes only the two status mirrors; every requested persistence/provenance
adversary blocks; and the done-ceiling delivery control remains strict.

##### BUG-009 S05 Resolver And Audit Contract Evidence

**Phase:** `implement`

**Commands:**

```text
cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/transition-contract-resolver-selftest.sh
cd /Users/pkirsanov/Projects/bubbles && bash bubbles/scripts/audit-result-contract-lint-selftest.sh
```

**Exit Codes:** 0, 0

**Claim Source:** executed

```text
== transition contract resolver selftest ==
PASS: transitionAudit schema is closed to the designed profile and target fields
PASS: schema accepts canonical bindings and rejects unknown profile, target, and selector fields
PASS: product-to-planning resolves through the production resolver
PASS: spec-scope-hardening resolves through the production resolver
PASS: bugfix-fastlane resolves a delivery contract
PASS: planning contract has normalized schema and feature path
PASS: planning contract names the canonical persisted mode
PASS: planning contract derives profile and target from the registry
PASS: planning contract exposes current state and G073 source lockout
PASS: planning contract carries the canonical registry reference
PASS: planning contract carries deterministic SHA-256 identities
PASS: scope hardening satisfies the planning profile invariants
PASS: delivery mode retains explicit completion semantics
PASS: resolver emits the complete sorted effective gate set
PASS: resolver preserves the complete ordered phase list
PASS: v6 planning form maps to the persisted canonical key
PASS: persisted v5 and current v6 forms resolve byte-identical mode definitions
PASS: persisted and v6-derived canonical modes produce byte-identical transition contracts
PASS: repeated resolution is byte-stable
PASS: contract digest is stable across idempotent resolution
PASS: target revision is stable across idempotent resolution
PASS: expectation flags only confirm and never alter the derived contract
PASS: expected mode mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: expected target mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: stale digest mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: caller profile flag returns E009-USAGE with exit 64 and empty stdout
PASS: caller bypass flag returns E009-USAGE with exit 64 and empty stdout
PASS: caller profile environment returns E009-USAGE with exit 64 and empty stdout
PASS: missing feature argument returns E009-USAGE with exit 64 and empty stdout
PASS: audit-owned state and report blocks do not invalidate their own target revision
PASS: artifact mutation does not change the registry contract digest
PASS: non-audit artifact mutation changes the target revision
PASS: source layout resolves byte-identical contracts
PASS: installed .github/bubbles layout resolves byte-identical contracts
PASS: missing registry returns E009-REGISTRY-MISSING with exit 66 and empty stdout
PASS: malformed state returns E009-STATE-MALFORMED with exit 65 and empty stdout
PASS: unknown mode returns E009-MODE-UNKNOWN with exit 67 and empty stdout
PASS: state policy mode mismatch returns E009-STATE-MODE-MISMATCH with exit 68 and empty stdout
PASS: certification mirror mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: terminal target mismatch returns E009-TARGET-MISMATCH with exit 69 and empty stdout
PASS: missing delivery profile returns E009-AUDIT-PROFILE-MISSING with exit 70 and empty stdout
PASS: missing designated planning profile returns E009-AUDIT-PROFILE-MISSING with exit 70 and empty stdout
PASS: unsupported adjacent non-done mode returns E009-AUDIT-PROFILE-UNSUPPORTED with exit 71 and empty stdout
PASS: unknown explicit profile returns E009-AUDIT-PROFILE-UNSUPPORTED with exit 71 and empty stdout
PASS: malformed transition audit metadata returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: planning implementation phase contradiction returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: registry target contradiction returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: unsupported transition audit field returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: planning profile on delivery mode returns E009-AUDIT-PROFILE-CONTRADICTION with exit 72 and empty stdout
PASS: every audit-bearing done mode has an explicit delivery binding
PASS: exactly the two designed planning modes have planning bindings
PASS: adjacent non-done audit modes receive no inferred profile
PASS: all 22 adjacent non-done audit modes remain explicitly unsupported
PASS: delivery phase-shape compatibility exceptions are a closed six-mode set
PASS: all 27 audit-bearing done modes resolve through explicit delivery contracts
PASS: all 22 adjacent non-done audit modes fail unsupported through the real resolver
== transition contract resolver selftest summary ==
passes=56
failures=0
skips=0
transition-contract-resolver-selftest: PASS
Running BUG-009 S04 audit result contract selftest...
PASS: planning clean view is exact and profile-bound
PASS: planning rework view names a concrete owner
PASS: delivery refusal preserves DO_NOT_SHIP semantics
PASS: metadata uncertainty is BLOCKED without fallback semantics
PASS: source-edit lockout is BLOCKED on G073
PASS: interruption leaves no current pointer or active verdict
PASS: rework supersedes prior result and preserves the finding one-to-one
PASS: duplicate AUDIT_RESULT_V1 block is rejected
PASS: missing frozen field is rejected
PASS: reordered frozen fields are rejected
PASS: malformed collection is rejected
PASS: planning shipment language is rejected
PASS: planning PASS claim for non-applicable delivery check is rejected
PASS: stale contract digest is rejected against guard provenance
PASS: stale target revision is rejected against guard provenance
PASS: delivery verdict drift is rejected
PASS: ANSI/color output is rejected
PASS: multiple ACTIVE attempts are rejected
PASS: dangling currentAttemptId is rejected
PASS: disappearing prior finding is rejected
PASS: canonical audit agent passes structural contract lint
PASS: Audit A1 wording is profile-scoped and registry-resolved
audit-result-contract-lint-selftest: 22 passed, 0 failed
```

**Result:** PASS — registry identity, digest/revision stability, assertion-only
matching, fail-closed resolver classes, current-attempt persistence, evidence
binding, and finding carry-forward all pass through the canonical scripts.

##### BUG-009 S05 Static, Agnosticity, And Change-Boundary Evidence

**Phase:** `implement`

**Command:** `cd /Users/pkirsanov/Projects/bubbles && bash -n tests/regression/test_23_planning_audit_contract.sh && printf 'S05_SHELL_SYNTAX_EXIT=0\n' && bash bubbles/scripts/regression-quality-guard.sh --bugfix tests/regression/test_23_planning_audit_contract.sh && printf 'S05_REGRESSION_QUALITY_EXIT=0\n' && bash bubbles/scripts/cli.sh agnosticity && printf 'S05_AGNOSTICITY_EXIT=0\n' && git diff --check -- agents/bubbles.validate.agent.md agents/bubbles_shared/scope-workflow.md agents/bubbles_shared/workflow-phase-engine.md agents/bubbles_shared/feature-templates.md agents/bubbles_shared/scope-templates.md tests/regression/test_23_planning_audit_contract.sh && printf 'S05_DIFF_CHECK_EXIT=0\nS05_OWNED_STATUS_BEGIN\n' && git status --short -- agents/bubbles.validate.agent.md agents/bubbles_shared/scope-workflow.md agents/bubbles_shared/workflow-phase-engine.md agents/bubbles_shared/feature-templates.md agents/bubbles_shared/scope-templates.md tests/regression/test_23_planning_audit_contract.sh && printf 'S05_OWNED_STATUS_END\n'`

**Exit Code:** 0

**Claim Source:** executed

```text
S05_SHELL_SYNTAX_EXIT=0
============================================================
  BUBBLES REGRESSION QUALITY GUARD
  Repo: /Users/pkirsanov/Projects/bubbles
  Timestamp: 2026-07-11T17:46:11Z
  Bugfix mode: true
============================================================

Scanning tests/regression/test_23_planning_audit_contract.sh
Adversarial signal detected in tests/regression/test_23_planning_audit_contract.sh

============================================================
  REGRESSION QUALITY RESULT: 0 violation(s), 0 warning(s)
  Files scanned: 1
  Files with adversarial signals: 1
============================================================
S05_REGRESSION_QUALITY_EXIT=0
Scanning 456 portable file(s) for agnosticity drift
Portable Bubbles surfaces are project-agnostic and tool-agnostic
S05_AGNOSTICITY_EXIT=0
S05_DIFF_CHECK_EXIT=0
S05_OWNED_STATUS_BEGIN
 M agents/bubbles.validate.agent.md
 M agents/bubbles_shared/feature-templates.md
 M agents/bubbles_shared/scope-templates.md
 M agents/bubbles_shared/scope-workflow.md
 M agents/bubbles_shared/workflow-phase-engine.md
AM tests/regression/test_23_planning_audit_contract.sh
S05_OWNED_STATUS_END
```

**Result:** PASS — shell syntax, adversarial regression quality, portability,
and whitespace checks are clean. The current-session S05 source/test set is
exactly the five planned contracts plus the existing regression; this BUGS.md
record is the only additional owned artifact. Pre-existing S01-S04, eval,
IMP-020, trust-doctor, schema, registry, and release-manifest changes remain
untouched.

**Additional guard compatibility:** `bash bubbles/scripts/state-transition-guard-selftest.sh`
exited 0 in this session with its supported delivery positive, planning profile
matrix, done-mode negative control, G073/G087/G091 adversaries, and all existing
guard canaries passing.

**Full framework validation:** **Claim Source:** not-run. The approved plan
assigns `framework-validate`, the complete 24-mode/12-scenario matrix, and the
persistent regression registration checkpoint to S06. S05 claims only its
focused cross-boundary behavior and supporting compatibility checks.

**S05 disposition:** terminal `route_required`; S05 is Done with no unresolved
S05 findings. BUG-009 remains open, S06 remains Not Started, and the next
required owner is `bubbles.test` for S06 only.

#### S06 — Full Matrix And Persistent Regression

- **Status:** Not Started
- **Primary owner:** `bubbles.test`
- **Depends on:** S05
**Change boundary:** `tests/regression/test_23_planning_audit_contract.sh`,
`bubbles/scripts/transition-contract-resolver-selftest.sh`,
`bubbles/scripts/state-transition-guard-selftest.sh`,
`bubbles/scripts/audit-result-contract-lint-selftest.sh`,
`bubbles/scripts/workflow-registry-consistency.sh`, and test registration in
`bubbles/scripts/framework-validate.sh`.

**Gherkin — Acceptance Scenarios G-I and complete A-L closure:**

```gherkin
Given every one of the 24 non-done audit-bearing modes and every audit-bearing done mode is resolved from the real registry
When the matrix test classifies its effective transition contract
Then only the two designed planning modes receive planning-maturity-v1
And no adjacent or delivery mode gains a planning exemption

Given the S01 honest fixture and all metadata/result adversaries
When the persistent regression runs after S02-S05
Then A-L pass through real resolver, guard, audit, validate, and finalize behavior
And the pre-fix red assertion is now green for the designed reason
```

**Implementation steps:**

1. Enumerate the 24-mode analyst matrix from resolved registry output, not a
  duplicated hardcoded policy table; assert the selected design disposition
  for every entry.
2. Add audit-bearing done-mode coverage and the honest-fixture delivery
  negative to prove positive delivery binding and unchanged completion rigor.
3. Cover G068/G087/G091/G073 negatives, false completion evidence, every
  `E009-*` class, stale digest/revision, alias identity, five V1 views,
  interruption/rework, and install-layout resolution.
4. Make `test_23` execute the actual Audit 0-pre/A1 and finalization contracts;
  remove no assertion merely to obtain green.
5. Run portability paths on macOS/BSD and the framework's Linux/WSL-compatible
  shell surface with full output.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| A-L | Framework E2E regression | `tests/regression/test_23_planning_audit_contract.sh` | Full real contract path produces exact planning, delivery, block, and terminology outcomes | `bash bubbles/scripts/cli.sh framework-validate` |
| 24-mode matrix | Functional/integration | `bubbles/scripts/workflow-registry-consistency.sh` plus resolver selftest | Classification is derived from effective registry values; exactly two planning modes and zero accidental exemptions | `bash bubbles/scripts/cli.sh framework-validate` |
| Release-level regression | Framework E2E | registered regression suite | All framework regressions, including done-mode and alias canaries, pass together | `bash bubbles/scripts/cli.sh release-check` |
| Portability/lint | Lint | changed shell/Markdown/YAML surfaces | No GNU-only, Bash-4-only, hardcoded-mode, bypass, or repo-specific consumer logic | `bash bubbles/scripts/cli.sh agnosticity` |

**Definition of Done:**

- [ ] All 12 acceptance scenarios have behavior-level assertions through production paths.
- [ ] The complete 24-mode non-done audit inventory and audit-bearing done inventory have explicit, design-consistent outcomes with zero planning leakage.
- [ ] Planning positives, done negatives, planning-gate negatives, metadata mismatches, alias compatibility, and audit output contracts all pass.
- [ ] The regression fails on pre-fix source and passes on fixed source without an early return, generated success record, or fake delivery artifact.
- [ ] `bash bubbles/scripts/cli.sh framework-validate` exits zero with full output.
- [ ] `bash bubbles/scripts/cli.sh agnosticity` exits zero with full output.
- [ ] No file outside the S06 change boundary changed.

#### S07 — Documentation Contract

- **Status:** Not Started
- **Primary owner:** `bubbles.docs`
- **Depends on:** S06
**Change boundary:** `README.md`, `docs/guides/AGENT_MANUAL.md`,
`docs/guides/CONTROL_PLANE_DESIGN.md`, `docs/recipes/framework-ops.md`, and
`CHANGELOG.md` only where the effective managed-doc registry requires them.

**Gherkin — Acceptance Scenario L for maintainers/operators:**

```gherkin
Given BUG-009 implementation and framework regression evidence are green
When maintainers read the operator, control-plane, and upgrade documentation
Then planning maturity is described as specs_hardened with delivery not evaluated
And delivery, upgrade, rollback, result-version, and unsupported-profile behavior match the implemented contracts
```

**Implementation steps:**

1. Document registry authority, assertion-only inputs, check applicability,
  result blocks, attempt/resume semantics, and validate-owned certification.
2. Document planning versus delivery vocabulary and the 22 adjacent non-done
  mode boundary without implying a broad non-done exemption.
3. Document canonical-source-first upgrade, installed provenance checks, and
  coherent rollback.
4. Add the changelog entry only after S06 evidence exists; do not backdate or
  claim downstream verification before S10.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| L docs contract | Functional/docs | managed docs above | Documentation examples use valid implemented fields, commands, enums, and ownership boundaries | `bash bubbles/scripts/cli.sh framework-validate` |
| Portability/agnosticity | Lint | same | Docs contain no downstream hardcode presented as framework policy and no unsupported command | `bash bubbles/scripts/cli.sh agnosticity` |

**Definition of Done:**

- [ ] Managed docs describe the implemented registry/resolver/guard/audit/finalize contract with no contradictory legacy instruction.
- [ ] Planning maturity cannot be read as implemented, tested, merge-ready, releasable, deployable, delivered, or shipped.
- [ ] Delivery anti-fabrication and rollback instructions remain explicit.
- [ ] `CHANGELOG.md` claims only behavior proven by S06 and leaves downstream verification to S10 evidence.
- [ ] Framework validation and agnosticity pass after docs changes.
- [ ] No file outside the S07 change boundary changed.

#### S08 — Canonical Version, Installer Provenance, And Release Package

- **Status:** Not Started
**Primary owner:** `bubbles.releases`; `bubbles.devops` owns installer/provenance
mechanics
- **Depends on:** S07
**Change boundary:** `VERSION`, `install.sh`,
`bubbles/scripts/install-provenance-selftest.sh`,
`bubbles/scripts/regen-derived.sh` only if generation logic requires a managed
surface update, generated `bubbles/workflows.yaml`, and
`bubbles/release-manifest.json` regenerated last. No hand edit to derived
content is permitted.

**Gherkin — release and install compatibility:**

```gherkin
Given canonical source, tests, agents, registries, and docs are complete and validated
When the supported derivation and release checks run
Then every new or changed managed interface is in the release manifest with current provenance
And a hermetic install contains byte-identical resolver, guard, agent, profile, registry, and result-lint contracts
```

**Implementation steps:**

1. Apply the repository's versioning policy after S06/S07 are green.
2. Ensure broad-copy installation carries the two new scripts and every changed
  managed contract; change `install.sh` only when its real behavior does not.
3. Extend install-provenance selftests for `.manifest`, `.checksums`, executable
  mode, source/installed byte parity, and removal/drift behavior.
4. Run `regen-derived.sh` in dependency order and generate
  `bubbles/release-manifest.json` last from canonical source.
5. Run the approved release check before any consumer upgrade.

**Test Plan:**

| Scenario | Category | File | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| Hermetic install | Integration | `bubbles/scripts/install-provenance-selftest.sh` | Installed managed interfaces are present, executable where required, checksummed, and byte-identical to canonical source | `bash bubbles/scripts/install-provenance-selftest.sh` |
| Derived consistency | Functional | generated registry/manifest | Regeneration is clean and every changed managed source has correct release provenance | `bash bubbles/scripts/cli.sh framework-validate` |
| Release candidate | Framework E2E | full source release surface | Full validation, regression, docs, install, manifest, and provenance checks pass | `bash bubbles/scripts/cli.sh release-check` |

**Definition of Done:**

- [ ] Version/changelog state follows repository policy and is backed by S06/S07 evidence.
- [ ] Hermetic install proves every new/changed managed interface is copied, executable as needed, listed, checksummed, and byte-identical.
- [ ] Derived registries are regenerated from source and `bubbles/release-manifest.json` is regenerated last, never hand-edited.
- [ ] `bash bubbles/scripts/cli.sh release-check` exits zero with full output.
- [ ] Rollback to the prior release is proven through the same installer/provenance path without history deletion or manual copying.
- [ ] No downstream repository file changed in S08.

#### S09 — Supported GuestHost Upgrade And Provenance Verification

- **Status:** Not Started
- **Primary owner:** `bubbles.devops`
- **Depends on:** S08
**Change boundary:** no authored GuestHost framework-managed file. The only
downstream mutation is the supported installer/upgrade projection from the
released canonical source. Product-owned Spec 151 content and application code
remain untouched.

**Gherkin — canonical-to-consumer propagation:**

```gherkin
Given the canonical BUG-009 release passed release-check
When GuestHost runs the supported framework upgrade
Then installed resolver, guard, audit result lint, agents, shared profiles, templates, and workflow registries match canonical release bytes and provenance
And no direct downstream edit or product-specific fork exists
```

**Implementation steps:**

1. Record a clean canonical `release-check` result and release identity.
2. Run `cd /Users/pkirsanov/Projects/GuestHost && bash
  .github/bubbles/scripts/cli.sh upgrade`; do not copy or patch files manually.
3. Verify `.github/bubbles/.manifest` membership and
  `.github/bubbles/.checksums` for every changed managed surface.
4. Compare canonical and installed bytes for the resolver, guard, result lint,
  workflow registries, audit/validate agents, validation profiles, phase/finalize
  contracts, and templates; verify executable bits for scripts.
5. Run the installed `doctor`/framework integrity surface before consumer audit.

**Test Plan:**

| Scenario | Category | Surface | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| Supported upgrade | Integration/install | GuestHost installed framework | Upgrade succeeds through the supported CLI with no hand mutation | `bash .github/bubbles/scripts/cli.sh upgrade` |
| Byte/provenance parity | Integration | `.manifest`, `.checksums`, canonical/installed managed files | Every expected managed file has matching digest, bytes, and executable mode; no unmanifested copy is accepted | `bash .github/bubbles/scripts/cli.sh doctor` plus read-only `cmp`/SHA-256 checks |
| Installed framework | Functional | GuestHost `.github/bubbles/**` | Installed registry and script self-consistency pass before Spec 151 is evaluated | `bash .github/bubbles/scripts/cli.sh framework-validate` |

**Definition of Done:**

- [ ] Canonical `release-check` evidence predates the GuestHost upgrade.
- [ ] GuestHost was upgraded only with the supported CLI; git diff proves no manual framework-managed edit path.
- [ ] Manifest membership, checksums, bytes, executable bits, and release identity match for every BUG-009 managed surface.
- [ ] Installed doctor/framework validation passes with full output.
- [ ] GuestHost Spec 151 and product source remain unchanged before S10 audit.
- [ ] No other downstream repository is patched or upgraded as part of BUG-009 consumer proof.

#### S10 — GuestHost Spec 151 Audit, Transition, And Finding Closure

- **Status:** Not Started
**Primary owner:** `bubbles.audit`; `bubbles.validate` exclusively owns the
certification transition
- **Depends on:** S09
**Change boundary:** audit-owned evidence and `execution.audit` records for
GuestHost `specs/151-self-hosted-appliance-packaging`, followed by
validate-owned `certification.*` and top-level status mirror only. Scope
statuses, DoD checkboxes, planned files, implementation/test claims, and product
source remain untouched.

**Gherkin — final Acceptance Scenario A with delivery control:**

```gherkin
Given GuestHost has a provenance-verified canonical install and Spec 151 still has honest incomplete delivery facts
When the direct-authorized product-to-planning runner performs validate, audit, and finalize
Then the installed guard and AUDIT_RESULT_V1 report PLANNING_AUDIT_CLEAN for the exact contract digest and target revision
And bubbles.validate transitions only top-level and certification status to specs_hardened
And F151-AUDIT-005 remains one-to-one with BUG-009 until this consumer proof is recorded

Given any independent planning gate or provenance check fails
When the audit runs
Then the transition does not occur and the original finding remains unresolved with the concrete owner
```

**Implementation steps:**

1. Run installed lint and guard against Spec 151 and preserve the complete
  planning-check and `NOT_APPLICABLE` ledger.
2. Have the authorized runner execute the real Audit 0-pre/A1 path; require one
  matching ACTIVE `AUDIT_RESULT_V1`, `PLANNING_AUDIT_CLEAN`, and
  `deliveryEvaluation: NOT_EVALUATED`.
3. Have validate independently resolve and compare mode, target, contract
  digest, target revision, attempt ID, verdict, and finding accounting before
  writing only the planning status.
4. Confirm all 18 scopes remain incomplete, all implementation DoD/test/report
  facts remain honest, and no delivery/merge/release/deploy claim appears.
5. Move `F151-AUDIT-005` from unresolved to addressed only with this real
  consumer evidence; then update BUG-009 implementation/post-fix evidence and
  disposition through the owning bug workflow.

**Test Plan:**

| Scenario | Category | Surface | Behavioral assertion | Exact command |
| --- | --- | --- | --- | --- |
| Spec 151 planning checks | Functional | installed lint/guard | Planning gates pass; Checks 4/5/8/11 completion portions are explicit NOT_APPLICABLE, not omitted or passed | `bash .github/bubbles/scripts/cli.sh lint specs/151-self-hosted-appliance-packaging` and `bash .github/bubbles/scripts/cli.sh guard specs/151-self-hosted-appliance-packaging` |
| Real planning audit | Framework E2E consumer | installed validate/audit/finalize chain | One current result certifies exactly `specs_hardened`, retains delivery NOT_EVALUATED, and preserves incomplete delivery state | direct-authorized `product-to-planning` runner using the installed framework |
| One-to-one control | Integration/state | Spec 151 result and BUG-009 evidence | `F151-AUDIT-005` appears exactly once and cannot disappear, split, or close without matching consumer evidence | installed guard plus audit-result contract lint |

**Definition of Done:**

- [ ] Installed lint and guard pass against the unchanged honest Spec 151 planning packet.
- [ ] Real Audit 0-pre/A1 emits one valid current `AUDIT_RESULT_V1` with `PLANNING_AUDIT_CLEAN`, exact mode/target/digest/revision, and no delivery language.
- [ ] Validate alone certifies exactly `specs_hardened`; all scope, DoD, test-file, report-evidence, completed-scope, and delivery-evaluation facts remain honestly incomplete.
- [ ] Any independent planning/provenance failure blocks rather than being hidden by non-applicable delivery checks.
- [ ] `F151-AUDIT-005` and BUG-009 remain one-to-one and are closed only with canonical source, release, install, and consumer evidence.
- [ ] BUG-009 is not marked fixed, verified, or closed before every prior scope and this consumer transition are evidenced.

#### Planning Verdict And Handoff

The plan is complete at the root mode's `specs_hardened` ceiling. The bug and
parent finding remain open because no implementation, test execution,
validation, release, installation, or post-fix consumer audit occurred in this
planning invocation. The required next owner is `bubbles.implement`, beginning
with S01 under the `bugfix-fastlane` workflow. The top-level runner, not this
planning owner, dispatches that workflow.

### Finding Provenance And One-To-One Accounting

- `F151-AUDIT-005` maps one-to-one to this BUG-009 entry.
- **Addressed by the bug owner:** discovery, independent reproduction,
  canonical/installed parity proof, root-cause documentation, expected-behavior
  specification, preliminary design constraints/options, regression
  requirements, acceptance criteria, and source-repo bug filing.
- **Addressed by the analyst owner:** registry-backed 24-mode inventory and
  classification, outcome contract, actors, use cases, lifecycle/verdict
  vocabulary, business policies, compatibility/non-goals, adversarial
  acceptance scenarios, and terminology-safe UX handoff.
- **Addressed by the UX owner:** operator phase flow, exact planning/delivery/
  blocked vocabulary, reusable CLI primitives, stable result fields, five
  canonical result views, evidence presentation, accessibility/no-color and
  narrow-terminal behavior, interruption/resume provenance, rework accounting,
  and concrete routing rules.
- **Addressed by the design owner:** selected registry-bound transition
  contract; exact resolver, guard, validate, audit, finalize, persistence, and
  output interfaces; check classification; closed failure behavior; security
  and anti-fabrication proof; compatibility/propagation rules; adversarial test
  architecture; implementation surface inventory; alternatives; complexity;
  and rollback strategy.
- **Addressed by the planning owner:** ordered S01-S10 dependency graph,
  explicit owners and change boundaries, exact source/contract surfaces,
  red-before-green sequence, scenario-specific Test Plans, unchecked DoD,
  blast-radius canaries, rollback controls, canonical release/installer order,
  and downstream consumer verification/transition plan.
- **Still unresolved under the same one-to-one finding:** implementation and
  tests, red/green execution evidence, post-fix reproduction, validation,
  docs/release changes, supported propagation, GuestHost consumer transition,
  and closure.
- **Next required owner:** `bubbles.implement`, starting S01 through the
  top-level runner's `bugfix-fastlane` workflow.

### Explicit No-Fix / No-After-Evidence Boundary

This invocation changed only `BUGS.md`. It did not modify
`bubbles/workflows/modes.yaml`, `agents/bubbles.audit.agent.md`, shared agent
contracts, guard code, selftests, regressions, release manifests, downstream
installed files, `CHANGELOG.md`, or GuestHost artifacts. No post-fix command was
run because no fix exists. There is intentionally no After Fix evidence, no
checked implementation DoD, and no `fixed`, `verified`, or `closed` status.

**Current routing:** BUG-009 remains open; planning is complete at the
`specs_hardened` ceiling and routes to `bubbles.implement` through the preferred
`bugfix-fastlane` workflow. No implementation or delivery claim is made.

