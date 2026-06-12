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
  passed." in all 5 downstream installed layouts (wanderaide, knb, quantitativeFinance,
  guestHost, smackerel). No hang anywhere.
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
- **Discovered by:** operator report — VS Code "Configure Tools" could not populate the `bubbles-smackerel` MCP tool list (the checkbox would not stick; "Update Tools" spun forever)
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

Newline-framed handshake (canonical AND `~/smackerel/.github/bubbles/mcp/server.py`):

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
- [x] newline handshake verified on canonical + smackerel (10 tools each)

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
- Vendored copies (re-sync via `/bubbles.setup`): smackerel, quantitativeFinance,
  wanderaide, guestHost, knb — each at `.github/bubbles/mcp/server.py`.

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

An earlier note linked the failure to a smackerel file
(`internal/assistant/openknowledge/agent/agent.go` around line 253). That was a
RED HERRING — it was merely the file open in the editor at failure time. That
file uses a plain `Role`+`Content` string message model over a Python sidecar
and cannot emit Anthropic content-block errors. Route the upstream issue to the
sub-agent request serialization path in `microsoft/vscode-copilot-chat`, NOT to
smackerel / bubbles / knb.
